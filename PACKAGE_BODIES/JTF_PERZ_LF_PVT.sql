--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_LF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_LF_PVT" as
/* $Header: jtfzvlfb.pls 120.2 2005/11/02 22:19:00 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
--   JTF_PERZ_LF_PVT
--
-- PURPOSE
--   Private API for  the look and feel objects.
--
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for creating, getting and updating look and feel objects
-- 	in the Personalization framework.
--
--
-- HISTORY
--	06/15/99	SMATTEGU	Created
--	08/13/99	SMATTEGU	Removed the handle_lf_object_map
--	08/18/99	SMATTEGU	Changed
--	08/18/99	SMATTEGU	Added
--	09/07/99	SMATTEGU	Re-Written the entire package
--					because of changes in specs
--					and data model
--	09/30/99	SMATTEGU	changed the save() to reflect profile_id fix
--	11/10/99	SMATTEGU	Bug# 1070584 Who column Changes and
--					other name changes
--	11/10/99	SMATTEGU	Bug# 1070665 fixed
--	11/11/99	SMATTEGU	Bug# 1071208 fixed
--	11/15/99	SMATTEGU	Bug# 1075579 fixed
--   12/1/1999 SMATTEGU Bug#1097254 enhancing the scope of
--					update_lf_object to include updating object type.
--   12/2/1999 SMATTEGU Bug#1098513 fixed


-- End of Comments

G_PKG_NAME  	CONSTANT VARCHAR2(30):='JTF_PERZ_LF_PVT';
G_FILE_NAME   	CONSTANT VARCHAR2(12):='jtfvplfb.pls';
G_LOGIN_ID	NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID	NUMBER := FND_GLOBAL.USER_ID;
--

-- ****************************************************************************
-- TABLE HANDLERS
--
--	The following are the table handlers
--
--	1.	insert_jtf_perz_lf_attrib
--	2.	Insert_Row_jtf_perz_lf_object
--	3.	insert_jtf_perz_lf_obj_type
--	4.	insert_jtf_perz_obj_type_map
--	5.	Insert_jtf_perz_lf_value
--	6.	insert_jtf_perz_obj_map

--	7.	update_jtf_perz_lf_obj_type
--	8.	update_jtf_perz_lf_value
--	9.	update_jtf_perz_lf_object

-- ****************************************************************************
PROCEDURE update_jtf_perz_lf_object (
	x_object_id	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_parent_id		IN	NUMBER,
	x_application_id	IN	NUMBER,
	x_object_description	IN	VARCHAR2,
	x_rowid		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	p_OBJECT_VERSION_NUMBER IN	NUMBER
) IS
   CURSOR C IS SELECT rowid FROM JTF_PERZ_LF_OBJECT
	WHERE object_id = x_object_id;
BEGIN
	update JTF_PERZ_LF_OBJECT
	set parent_id = decode( x_parent_id, FND_API.G_MISS_NUM,parent_id,
				 NULL, parent_id, x_parent_id),
	object_description = decode( x_object_description, FND_API.G_MISS_CHAR,
		object_description, NULL, object_description, x_object_description),
	OBJECT_VERSION_NUMBER = decode (p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,
				OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER+1),
	LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATED_BY  = FND_GLOBAL.USER_ID,
	LAST_UPDATE_LOGIN = FND_GLOBAL.CONC_LOGIN_ID
	WHERE object_id = x_object_id
	and OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;

end update_jtf_perz_lf_object;
-- ****************************************************************************
PROCEDURE update_jtf_perz_lf_obj_type (
	x_object_type_desc	IN VARCHAR2,
	x_object_type_id IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_rowid		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	p_OBJECT_VERSION_NUMBER IN	NUMBER
)IS

   CURSOR C IS SELECT rowid FROM JTF_PERZ_LF_OBJECT_TYPE
    	where object_type_id = x_object_type_id;
BEGIN
    Update JTF_PERZ_LF_OBJECT_TYPE
    SET
     OBJECT_TYPE_DESC =
	decode( x_object_type_desc, FND_API.G_MISS_CHAR,
		OBJECT_TYPE_DESC,x_object_type_desc),
	OBJECT_VERSION_NUMBER = decode (p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,
				OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER+1),
	LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATED_BY  = FND_GLOBAL.USER_ID,
	LAST_UPDATE_LOGIN = FND_GLOBAL.CONC_LOGIN_ID
    where object_type_id = x_object_type_id
	and OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
END update_jtf_perz_lf_obj_type;
-- ****************************************************************************
PROCEDURE update_jtf_perz_lf_value(
	x_Rowid                         IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_value_id		 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
        x_PROFILE_ID                    IN NUMBER,
        x_MAP_ID                    IN NUMBER,
        x_ATTRIBUTE_VALUE               IN VARCHAR2,
        x_ACTIVE_FLAG                   IN VARCHAR2,
        x_PRIORITY                      IN NUMBER,
	p_OBJECT_VERSION_NUMBER IN	NUMBER
 ) IS

   CURSOR C IS SELECT rowid FROM JTF_PERZ_LF_VALUE
            WHERE PERZ_LF_VALUE_ID = x_VALUE_ID;

 BEGIN

    Update JTF_PERZ_LF_VALUE
    SET
             PROFILE_ID = decode( x_PROFILE_ID, FND_API.G_MISS_NUM,PROFILE_ID,x_PROFILE_ID),
             OBJ_MAP_ID = decode( x_MAP_ID, FND_API.G_MISS_NUM,OBJ_MAP_ID,x_MAP_ID),
             ATTRIBUTE_VALUE = decode( x_ATTRIBUTE_VALUE, FND_API.G_MISS_CHAR,ATTRIBUTE_VALUE,x_ATTRIBUTE_VALUE),
             ACTIVE_FLAG = decode( x_ACTIVE_FLAG, FND_API.G_MISS_CHAR,ACTIVE_FLAG,x_ACTIVE_FLAG),
             PRIORITY = decode( x_PRIORITY, FND_API.G_MISS_NUM,PRIORITY,x_PRIORITY),
	OBJECT_VERSION_NUMBER = decode (p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,
				OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER+1),
	LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATED_BY  = FND_GLOBAL.USER_ID,
	LAST_UPDATE_LOGIN = FND_GLOBAL.CONC_LOGIN_ID
    where PERZ_LF_VALUE_ID = x_value_id;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;

 END update_jtf_perz_lf_value;
--
-- ****************************************************************************


PROCEDURE insert_jtf_perz_obj_map(
                  x_Rowid OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                  x_OBJ_MAP_ID IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
                  x_TYPE_MAP_ID	IN  NUMBER,
                  x_OBJECT_ID	IN  NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_PERZ_OBJ_MAP
            WHERE OBJ_MAP_ID = x_OBJ_MAP_ID;
   CURSOR C2 IS SELECT JTF_PERZ_OBJ_MAP_s.nextval FROM sys.dual;
BEGIN
   If (x_OBJ_MAP_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_OBJ_MAP_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_PERZ_OBJ_MAP(
        OBJ_MAP_ID,
	MAP_ID,
        OBJECT_ID,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
   ) VALUES (
        x_OBJ_MAP_ID,
	decode(x_TYPE_MAP_ID,FND_API.G_MISS_NUM, NULL,x_TYPE_MAP_ID),
        decode( x_OBJECT_ID, FND_API.G_MISS_NUM, NULL,x_OBJECT_ID),
	G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID);
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End insert_jtf_perz_obj_map;


-- -- ****************************************************************************
--
PROCEDURE Insert_jtf_perz_lf_value(
                  x_Rowid	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
		  x_VALUE_ID	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
                  x_PROFILE_ID		IN NUMBER,
                  x_MAP_ID		IN NUMBER,
                  x_ATTRIBUTE_VALUE	IN VARCHAR2,
                  x_ACTIVE_FLAG		IN VARCHAR2,
                  x_PRIORITY		IN NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_PERZ_LF_VALUE
            WHERE PERZ_LF_VALUE_ID	= x_VALUE_ID;
   CURSOR C2 IS SELECT JTF_PERZ_LF_VALUE_s.nextval FROM sys.dual;


BEGIN

   If ( x_VALUE_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_VALUE_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_PERZ_LF_VALUE(
	   PERZ_LF_VALUE_ID,
           PROFILE_ID,
           OBJ_MAP_ID,
           ATTRIBUTE_VALUE,
           ACTIVE_FLAG,
           PRIORITY,
	OBJECT_VERSION_NUMBER,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
   ) VALUES (
	x_VALUE_ID,
	x_PROFILE_ID,
           decode( x_MAP_ID, FND_API.G_MISS_NUM, NULL,x_MAP_ID),
           decode( x_ATTRIBUTE_VALUE, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE_VALUE),
           decode( x_ACTIVE_FLAG, FND_API.G_MISS_CHAR, NULL,x_ACTIVE_FLAG),
           decode( x_PRIORITY, FND_API.G_MISS_NUM, NULL,x_PRIORITY),
	1,G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID);
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_jtf_perz_lf_value;

-- ****************************************************************************

PROCEDURE insert_jtf_perz_obj_type_map(
                  x_Rowid	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                  x_MAP_ID	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
                  x_OBJECT_TYPE_ID	IN  NUMBER,
                  x_ATTRIBUTE_ID	IN  NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM jtf_perz_obj_type_map
            WHERE obj_type_map_id = x_MAP_ID;
   CURSOR C2 IS SELECT jtf_perz_obj_type_map_s.nextval FROM sys.dual;
BEGIN
   If (x_MAP_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_MAP_ID;
       CLOSE C2;
   End If;
   INSERT INTO jtf_perz_obj_type_map(
           obj_type_map_id,
           OBJECT_TYPE_ID,
           ATTRIBUTE_ID,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
          ) VALUES (
          x_MAP_ID,
           decode( x_OBJECT_TYPE_ID, FND_API.G_MISS_NUM, NULL,x_OBJECT_TYPE_ID),
           decode( x_ATTRIBUTE_ID, FND_API.G_MISS_NUM, NULL,x_ATTRIBUTE_ID),
	G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID);
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End insert_jtf_perz_obj_type_map;


-- ****************************************************************************
/*
PROCEDURE update_row_jtf_perz_lf_attrib(
                  x_Rowid	 IN OUT VARCHAR2,
                  x_ATTRIBUTE_ID	IN NUMBER,
                  x_ATTRIBUTE_NAME	IN VARCHAR2,
                  x_ATTRIBUTE_TYPE	IN VARCHAR2
 ) IS
 BEGIN
    Update JTF_PERZ_LF_ATTRIB
    SET
             ATTRIBUTE_ID = decode( x_ATTRIBUTE_ID, FND_API.G_MISS_NUM,ATTRIBUTE_ID,x_ATTRIBUTE_ID),
             ATTRIBUTE_NAME = decode( x_ATTRIBUTE_NAME, FND_API.G_MISS_CHAR,ATTRIBUTE_NAME,x_ATTRIBUTE_NAME),
             ATTRIBUTE_TYPE = decode( x_ATTRIBUTE_TYPE, FND_API.G_MISS_CHAR,ATTRIBUTE_TYPE,x_ATTRIBUTE_TYPE)
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END update_row_jtf_perz_lf_attrib;
*/

-- ****************************************************************************
PROCEDURE insert_jtf_perz_lf_attrib(
                  x_Rowid	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                  x_ATTRIBUTE_ID OUT NOCOPY /* file.sql.39 change */ NUMBER,
                  x_ATTRIBUTE_NAME	IN	VARCHAR2,
                  x_ATTRIBUTE_TYPE	IN	VARCHAR2
 ) IS

   CURSOR C IS SELECT rowid FROM JTF_PERZ_LF_ATTRIB
            WHERE ATTRIBUTE_ID = x_ATTRIBUTE_ID;

   CURSOR C2 IS SELECT JTF_PERZ_LF_ATTRIB_s.nextval FROM sys.dual;

BEGIN

   If (x_ATTRIBUTE_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_ATTRIBUTE_ID;
       CLOSE C2;
   End If;

   INSERT INTO JTF_PERZ_LF_ATTRIB(
           ATTRIBUTE_ID,
           ATTRIBUTE_NAME,
           ATTRIBUTE_TYPE,
	OBJECT_VERSION_NUMBER,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
    )
    VALUES (
          x_ATTRIBUTE_ID,
           decode( x_ATTRIBUTE_NAME, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE_NAME),
           decode( x_ATTRIBUTE_TYPE, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE_TYPE),
	1,G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID
    );

   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End insert_jtf_perz_lf_attrib;
-- ****************************************************************************

PROCEDURE Insert_jtf_perz_lf_obj_type(
                  x_Rowid	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                  x_OBJECT_TYPE_ID IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
                  x_OBJECT_TYPE		IN	VARCHAR2,
                  x_OBJECT_TYPE_DESC	IN	VARCHAR2
 ) IS

   CURSOR C IS SELECT rowid FROM JTF_PERZ_LF_OBJECT_TYPE
            WHERE OBJECT_TYPE_ID = x_OBJECT_TYPE_ID;
   CURSOR C2 IS SELECT JTF_PERZ_LF_OBJ_TYPE_s.nextval FROM sys.dual;

BEGIN

   If (x_OBJECT_TYPE_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_OBJECT_TYPE_ID;
       CLOSE C2;
   End If;


   INSERT INTO JTF_PERZ_LF_OBJECT_TYPE(
           OBJECT_TYPE_ID,
           OBJECT_TYPE_NAME,
           OBJECT_TYPE_DESC,
	OBJECT_VERSION_NUMBER,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
   )
   VALUES (
	x_OBJECT_TYPE_ID,
	decode( x_OBJECT_TYPE, FND_API.G_MISS_CHAR, NULL,x_OBJECT_TYPE),
	decode( x_OBJECT_TYPE_DESC, FND_API.G_MISS_CHAR, NULL,x_OBJECT_TYPE_DESC),
	1, G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID
   );

   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;

End Insert_jtf_perz_lf_obj_type;

-- ****************************************************************************

PROCEDURE Insert_jtf_perz_lf_object(
                  x_Rowid	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                  x_OBJECT_ID	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
                  x_PARENT_ID		IN 	NUMBER,
                  x_APPLICATION_ID	IN	NUMBER,
                  x_OBJECT_NAME		IN	VARCHAR2,
                  x_OBJECT_DESCRIPTION	IN	VARCHAR2
 ) IS

   CURSOR C IS SELECT rowid FROM JTF_PERZ_LF_OBJECT
            WHERE OBJECT_ID = x_OBJECT_ID;
   CURSOR C2 IS SELECT JTF_PERZ_LF_OBJECT_s.nextval FROM sys.dual;

BEGIN

   If (x_OBJECT_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_OBJECT_ID;
       CLOSE C2;
   End If;

   INSERT INTO JTF_PERZ_LF_OBJECT(
           OBJECT_ID,
	   PARENT_ID,
           APPLICATION_ID,
           OBJECT_NAME,
           OBJECT_DESCRIPTION,
	OBJECT_VERSION_NUMBER,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
   )
   VALUES (
	x_OBJECT_ID,
     decode( x_PARENT_ID, FND_API.G_MISS_NUM, NULL,x_PARENT_ID),
     decode( x_APPLICATION_ID, FND_API.G_MISS_NUM, NULL,x_APPLICATION_ID),
     decode( x_OBJECT_NAME, FND_API.G_MISS_CHAR, NULL,x_OBJECT_NAME),
     decode( x_OBJECT_DESCRIPTION, FND_API.G_MISS_CHAR, NULL,x_OBJECT_DESCRIPTION),
	1, G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID
    );

   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;

End Insert_jtf_perz_lf_object;

-- ***************************************************************************
-- ***************************************************************************
--
--Private  APIs
--
-- check_attribute()
-- Check_duplicate_obj()
-- Check_duplicate_obj_type()
-- get_obj_type_details()

-- ***************************************************************************
-- ***************************************************************************

-- Start of Comments
--
--	API name 	: check_attribute
--	Type		: Private
--	Function	:
		--	Check if attribute exists
--
--	Paramaeters	:
--	IN:
--		p_attribute_type	IN	VARCHAR2,
--		p_attribute_name	IN	VARCHAR2,
--	OUT:
--		x_rowid		 OUT  ROWID,
--		x_attribute_id	 IN OUT  NUMBER,
--		x_return_status	 OUT VARCHAR2
-- *****************************************************************************
procedure	check_attribute(
	p_attribute_name	IN	VARCHAR2,
	p_attribute_type	IN	VARCHAR2,
	x_rowid		 OUT NOCOPY /* file.sql.39 change */ ROWID,
	x_attribute_id	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	)IS

	l_attribute_id		NUMBER := x_attribute_id;
BEGIN

	if (l_attribute_id is null) then
		select rowid, attribute_id
		into x_rowid, x_attribute_id
		from 	jtf_perz_lf_attrib
		where	attribute_name = p_attribute_name
		and 	attribute_type	= p_attribute_type;

		if (x_rowid is not null) then
			x_return_status	:=	FND_API.G_TRUE;
		else
			x_return_status := FND_API.G_FALSE;
		end if;
	else
		select rowid, attribute_id
		into x_rowid, x_attribute_id
		from 	jtf_perz_lf_attrib
		where	attribute_id = l_attribute_id;

		if (x_rowid is not null) then
			x_return_status	:=	FND_API.G_TRUE;
		else
			x_return_status := FND_API.G_FALSE;
		end if;
	end if;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		x_return_status := FND_API.G_FALSE;

	WHEN OTHERS THEN
		x_return_status := FND_API.G_FALSE;

END check_attribute;
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: Check_duplicate_obj_type
--	Type		: Private
--	Function	: Checks if the object already exists or not
--
--	Paramaeters	:
--	IN	:
--		p_object_type		IN VARCHAR2	Required
--
-- OUT  	:
--		x_return_status	 OUT  VARCHAR2
--
--	IN OUT:
--		x_object_type_id IN OUT  NUMBER
-- *****************************************************************************
procedure check_duplicate_obj_type (
	p_object_type		IN 	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
	x_object_type_id IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
	x_OBJECT_VERSION_NUMBER OUT NOCOPY /* file.sql.39 change */ NUMBER
) IS

l_object_type_id NUMBER := NULL;

BEGIN

	if ((p_object_type is not null) and
		(p_object_type <> FND_API.G_MISS_CHAR)) and
		((x_object_type_id is null) OR
		(x_object_type_id = FND_API.G_MISS_NUM))
	then
		select object_type_id, object_version_number
		into l_object_type_id, x_object_version_number
		from jtf_perz_lf_object_type
		where object_type_name = p_object_type;

		x_object_type_id := l_object_type_id;
		x_return_status := FND_API.G_TRUE;

	elsif ((x_object_type_id is not null) and
		(x_object_type_id <> FND_API.G_MISS_NUM)) and
		((p_object_type is null) OR
		(p_object_type <> FND_API.G_MISS_CHAR))
	then

		select object_type_id, object_version_number
		into l_object_type_id, x_object_version_number
		from jtf_perz_lf_object_type
		where object_type_id = x_object_type_id ;

		x_object_type_id := l_object_type_id;
		x_return_status := FND_API.G_TRUE;

	elsif ((p_object_type is not null) and
		(x_object_type_id is not null) and
		(p_object_type <> FND_API.G_MISS_CHAR) and
		(x_object_type_id <> FND_API.G_MISS_NUM))
	then
		select object_type_id, object_version_number
		into l_object_type_id, x_object_version_number
		from jtf_perz_lf_object_type
		where object_type_id = x_object_type_id;
		--and object_type_name	= upper(p_object_type);

		x_object_type_id := l_object_type_id;
		x_return_status := FND_API.G_TRUE;

	else
		x_return_status := FND_API.G_FALSE;
	end if;

EXCEPTION

WHEN NO_DATA_FOUND THEN
	x_return_status := FND_API.G_FALSE;

WHEN OTHERS THEN
	x_return_status := FND_API.G_FALSE;

END check_duplicate_obj_type;
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: Check_duplicate_obj
--	Type		: Private
--	Function	: Checks if the object already exists or not
--
--	Paramaeters	:
--	IN	:
--		p_application_id	IN NUMBER	Required
--		p_object_name		IN VARCHAR2	Required

--
-- OUT  	:
--		x_return_status	 OUT  BOOLEAN
--
--	IN OUT:
--		x_object_id	 IN OUT   NUMBER
-- *****************************************************************************
procedure check_duplicate_obj (
	p_application_id	IN	NUMBER,
	p_object_name		IN 	VARCHAR2,
	x_object_id	 IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
	x_OBJECT_VERSION_NUMBER OUT NOCOPY /* file.sql.39 change */ NUMBER
) IS

l_object_id NUMBER := NULL;

BEGIN

-- Please take care of G_MISS_NUM , G_MISS_CHAR -srikanth
	if (((p_object_name is not null) OR (p_object_name <> FND_API.G_MISS_CHAR))
		and ((x_object_id is null) OR (x_object_id = FND_API.G_MISS_NUM))) then

		select object_id, object_version_number
		   into l_object_id, x_object_version_number
		from jtf_perz_lf_object
		where object_name = p_object_name
		and application_id = p_application_id;

		x_object_id := l_object_id;
		x_return_status := FND_API.G_TRUE;


	elsif (((p_object_name is null) OR (p_object_name = FND_API.G_MISS_CHAR))
		and ((x_object_id is not null) OR (x_object_id <> FND_API.G_MISS_NUM))) then

		select object_id, object_version_number
		   into l_object_id, x_object_version_number
		from jtf_perz_lf_object
		where object_id = x_object_id
		and application_id = p_application_id;

		x_object_id := l_object_id;
		x_return_status := FND_API.G_TRUE;


	elsif (((p_object_name is not null) OR (p_object_name <> FND_API.G_MISS_CHAR))
		and ((x_object_id is not null) OR (x_object_id <> FND_API.G_MISS_NUM))) then

		select object_id, object_version_number
		   into l_object_id, x_object_version_number
		from jtf_perz_lf_object
		where object_id = x_object_id and
		object_name	 = p_object_name
		and application_id = p_application_id;

		x_object_id := l_object_id;
		x_return_status := FND_API.G_TRUE;

	else
		x_return_status := FND_API.G_FALSE;
	end if;
--	dbms_output.put_line(' return status in check duplicate obj is:'||x_return_status);
EXCEPTION

WHEN NO_DATA_FOUND THEN
	x_return_status := FND_API.G_FALSE;
--	dbms_output.put_line(' return status in check duplicate obj is:'||x_return_status);

WHEN OTHERS THEN
	x_return_status := FND_API.G_FALSE;
--	dbms_output.put_line(' return status in check duplicate obj is:'||x_return_status);

END check_duplicate_obj;

-- ***************************************************************************

-- Start of Comments
--
--	API name 	: Get_obj_type_details
--	Type		: Private
--	Function	: Gets the object type and it's associated attributes.
--				If the procedure is not sucessful,
--				then it returns FALSE else TRUE
--
--
--	Paramaeters	:
--	IN	:
--		p_Object_type		VARCHAR2
-- IN OUT  :
--		p_Object_type_Id	NUMBER
--
-- OUT  	:
--		x_object_type_desc	VARCHAR2
--		x_return_status 	VARCHAR2
--		x_attrib_rec_tbl	JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE
--
-- ***************************************************************************
procedure get_obj_type_details
(
	p_Object_type		IN VARCHAR2,
	p_Object_type_Id  IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_object_type_desc OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_attrib_rec_tbl OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
	l_Object_type_Id NUMBER := NULL;
	l_count NUMBER := 0;

	l_attribute_id 	NUMBER;
	l_attribute_name VARCHAR2(30);
	l_attribute_type VARCHAR2(30);

	CURSOR C_GET_ATTRIBUTES (p_Object_type_Id NUMBER) IS
	SELECT  a.attribute_id, b.attribute_name, b.attribute_type
	from jtf_perz_obj_type_map a, jtf_perz_lf_attrib b
		where a.object_type_id = p_object_type_id
		and a.attribute_id = b.attribute_id;
BEGIN

 if ((p_object_type_id is not NULL) OR
    (p_object_type_id <> FND_API.G_MISS_NUM)) then

	select object_type_id, object_type_desc
	into l_object_type_id, x_object_type_desc
	from jtf_perz_lf_object_type
	where object_type_id = p_object_type_id;
	x_return_status := FND_API.G_TRUE;

 elsif (( p_object_type is not null) OR
	( p_object_type <> FND_API.G_MISS_CHAR)) then

	select object_type_id, object_type_desc
	into l_object_type_id, x_object_type_desc
	from jtf_perz_lf_object_type
	where object_type_name = p_object_type;
	x_return_status := FND_API.G_TRUE;

 else
	x_return_status := FND_API.G_FALSE;
 end if;

 if (x_return_status = FND_API.G_TRUE) then

	l_count := 1;
	OPEN C_GET_ATTRIBUTES (l_object_type_id);
--dbms_output.put_line(' 1 l_object_type_id:'||l_object_type_id);
 	loop
 		FETCH C_GET_ATTRIBUTES INTO
			l_attribute_id,
			l_attribute_name,
			l_attribute_type;
		EXIT WHEN C_GET_ATTRIBUTES%NOTFOUND;
		IF (C_GET_ATTRIBUTES%FOUND = TRUE) THEN
			x_attrib_rec_tbl(l_count).attribute_id := l_attribute_id;
			x_attrib_rec_tbl(l_count).attribute_name := l_attribute_name;
			x_attrib_rec_tbl(l_count).attribute_type := l_attribute_type;

			l_count := l_count+ 1;
		END IF;
	end loop;
	CLOSE C_GET_ATTRIBUTES;
	p_object_type_id := l_object_type_id;
--dbms_output.put_line('2 l_object_type_id:'||l_object_type_id);
	x_return_status := FND_API.G_TRUE;

 end if;


EXCEPTION
WHEN NO_DATA_FOUND THEN
	 x_return_status := FND_API.G_FALSE;

WHEN OTHERS THEN
	 x_return_status := FND_API.G_FALSE;
END get_obj_type_details;

-- ****************************************************************************
-- ****************************************************************************
-- PUBLIC APIs
--
-- Create_lf_object()
-- Update_lf_object()
-- get_lf_object()
-- save_lf_object()
-- save_lf_object_type()
-- get_lf_object_type()
-- *****************************************************************************
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: Create_lf_object
--	Type		: Public
--	Function	: Create attribute value pairs for a given object and profile
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN NUMBER	Required
--		p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--		p_commit		IN VARCHAR2	Optional

--		p_profile_id		IN NUMBER	Optional
--		p_profile_name		IN VARCHAR2	Required

--		p_application_id	IN NUMBER	Required
--		p_parent_id		IN NUMBER	Optional
--		p_object_id		IN NUMBER	Optional
--		p_object_name		IN VARCHAR2	Required

--		p_object_type_id	IN NUMBER	Optional
--		p_object_type		IN VARCHAR2	Optional

--		p_attrib_value_tbl	IN	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
--				:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL

-- OUT :
--		x_object_id	 OUT NUMBER
--		x_return_status	 OUT VARCHAR2(1)
--		x_msg_count	 OUT NUMBER
--		x_msg_data	 OUT VARCHAR2(2000)
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes:	Personalization Framework API to create the Object attrib-
--			Value pair with their corresponding profile.
--
--
-- *****************************************************************************

PROCEDURE Create_lf_object
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_profile_id            IN 	NUMBER,
	p_profile_name          IN 	VARCHAR2,

	p_application_id	IN 	NUMBER,
	p_parent_id		IN 	NUMBER,
	p_object_id             IN 	NUMBER,
	p_object_name           IN 	VARCHAR2,

	p_object_type_id        IN 	NUMBER,
	p_object_type           IN 	VARCHAR2,

	p_attrib_value_tbl	IN	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
				:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL,

	x_object_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
       -- ******* Create_lf_object Local Variables ********
--	Following variables are needed to adhere to standards
	l_api_version_number	NUMBER 	:= p_api_version_number;
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'Create_lf_Object';

--	Following variables are needed for implementation
	l_profile_id		NUMBER		:= NULL;
	l_profile_name		VARCHAR2(60)   := NULL;
	l_return_status    	VARCHAR2(240);
	l_object_type		VARCHAR2(60) := p_object_type;
	l_object_type_id	NUMBER := p_object_type_id;
	l_rowid			ROWID		:= NULL;
	l_object_id		NUMBER		:= NULL;
	l_object_name		VARCHAR2(60)   := NULL;
	l_object_description VARCHAR2(240) := NULL;
	l_count		    	NUMBER     	:= p_attrib_value_tbl.count;
     	l_curr_row		NUMBER		:= NULL;
	l_attrib_value_tbl	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
				:= p_attrib_value_tbl;
	l_type_map_id		NUMBER		:= NULL;
	l_obj_map_id		NUMBER		:= NULL;
	l_active_flag		VARCHAR2(1)	:= 'Y';
	l_value_id			NUMBER		:= NULL;
	l_object_version_number NUMBER :=NULL;
	l_obj_type_version_no   NUMBER := NULL;
BEGIN

       -- ******* Create_lf_object Execution Plan ********
-- Create_lf_object execution steps
--1. Check if the profile exists
--			check_duplicate_profiles()
--			If not, raise an error and exit
--2. Check if Type Exists
--			If not, raise an error and exit
--3. Create the Object
--	   		If not successful, raise error and exit
--4. Loop though for each object type - attribute map defined
--	For each map id
--		Create object map
--		Create a value rec

       -- *******Create_lf_object  Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	CREATE_PERZ_LF_PVT;

      -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call (
--		l_api_version_number,
--		p_api_version_number,
--		l_api_name,
--		G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Create_lf_object implementation

--1. Check if the profile exists

  l_profile_id := p_profile_id;
  l_profile_name := p_profile_name;
  l_return_status := FND_API.G_TRUE;
  if ((p_profile_id is NULL) OR
     (p_profile_id = FND_API.G_MISS_NUM)) then
	JTF_PERZ_PROFILE_PVT.check_profile_duplicates(
		l_profile_name,
		l_return_status,
		l_profile_id
	);


-- If profile does not exists, raise an error and exit

   if (l_return_status = FND_API.G_FALSE) then
          RAISE FND_API.G_EXC_ERROR;
   end if;

 end if;

--2. Check if Type Exists

  l_return_status := FND_API.G_TRUE;
  check_duplicate_obj_type (
	l_object_type,
	l_return_status,
	l_object_type_id,
	l_obj_type_version_no
  );

--  If object type is not found raising the error
   if (l_return_status = FND_API.G_FALSE) then
   --dbms_output.put_line('object type check failed');
          RAISE FND_API.G_EXC_ERROR;
   end if;

--3.Create the Object

-- Check if parent exists only if the parent id is given
  l_return_status := FND_API.G_TRUE;
  l_object_id := p_parent_id;
  l_object_name := NULL;
  if (p_parent_id is not null) AND
	(p_parent_id <> FND_API.G_MISS_NUM)then
  	 check_duplicate_obj (
	 	p_application_id,
		l_object_name,
		l_object_id,
		l_return_status,
		l_object_version_number
  	 );

   	 if (l_return_status = FND_API.G_FALSE) then
          RAISE FND_API.G_EXC_ERROR;
	 end if;
  end if;

-- Check if object exists only if the parent id is given
	l_return_status := FND_API.G_TRUE;
	l_object_id := p_object_id;
	l_object_name := p_object_name;
	check_duplicate_obj (
		p_application_id,
		l_object_name,
		l_object_id,
		l_return_status,
		l_object_version_number
	);
	if (l_return_status = FND_API.G_TRUE) then
		--dbms_output.put_line('object check failed ');
		RAISE FND_API.G_EXC_ERROR;
	end if;

-- Create Object
  l_object_name := p_object_name ;
  l_object_id := p_object_id;
  -- Object_description is not a parameter in public and pvt spec. hence
  -- passing null to the table handler - Srikanth 9-3-99
  Insert_jtf_perz_lf_object(
     		l_rowid,
     		l_object_id,
     		p_parent_id,
     		p_application_id,
     		p_object_name,
     		l_object_description
  );

  if (l_rowid is null) then
          RAISE FND_API.G_EXC_ERROR;
  end if;

--	Loop though for each attribute defined in the attrib_value_tbl
--	For each of the object_type - attribute map
--		create object (instance of the obj type) map
--		Create a value rec

  FOR l_curr_row in 1..l_count LOOP

	if ((l_attrib_value_tbl(l_curr_row).attribute_id is null) OR
	  (l_attrib_value_tbl(l_curr_row).attribute_id =FND_API.G_MISS_NUM)) then
		if ((l_attrib_value_tbl(l_curr_row).attribute_name is not null) AND
		    (l_attrib_value_tbl(l_curr_row).attribute_name <> FND_API.G_MISS_CHAR)) AND
		   ((l_attrib_value_tbl(l_curr_row).attribute_type is not null) AND
		    (l_attrib_value_tbl(l_curr_row).attribute_type <> FND_API.G_MISS_CHAR))
		then
			begin
			    select a.obj_type_map_id
			    into l_type_map_id
			    from jtf_perz_obj_type_map a, jtf_perz_lf_attrib b
			    where object_type_id = l_object_type_id
			    and attribute_name = l_attrib_value_tbl(l_curr_row).attribute_name
			    and attribute_type = l_attrib_value_tbl(l_curr_row).attribute_type
			    and a.attribute_id = b.attribute_id
			    and a.object_type_id = l_object_type_id;

			EXCEPTION
			    WHEN NO_DATA_FOUND then
				--dbms_output.put_line('In 1st select 1 exception');
				RAISE FND_API.G_EXC_ERROR;
			    WHEN OTHERS then
				--dbms_output.put_line('In 1st select 2 exception');
				RAISE FND_API.G_EXC_ERROR;
  			end;
		end if;
	else
	   begin
		select a.obj_type_map_id
		into l_type_map_id
		from jtf_perz_obj_type_map a
		where a.object_type_id = l_object_type_id
		and a.attribute_id = l_attrib_value_tbl(l_curr_row).attribute_id;

	   EXCEPTION
		WHEN NO_DATA_FOUND then
			--dbms_output.put_line('In 2nd select 1 exception');
			RAISE FND_API.G_EXC_ERROR;
		WHEN OTHERS then
			--dbms_output.put_line('In 2nd select 2 exception');
			RAISE FND_API.G_EXC_ERROR;
  	   END;

	end if;

	l_rowid := NULL;
	l_obj_map_id := NULL;
	insert_jtf_perz_obj_map(
		l_rowid,
		l_obj_map_id,
		l_type_map_id,
		l_object_id
	);

	if (l_rowid is null) then
		--dbms_output.put_line('In insert into obj map error');
         	 RAISE FND_API.G_EXC_ERROR;
  	end if;

	l_rowid := NULL;
	l_value_id := NULL;
	--dbms_output.put_line('l_obj_map_id '||l_obj_map_id);
	insert_jtf_perz_lf_value(
		l_rowid,
		l_value_id,
		l_profile_id,
		l_obj_map_id,
		l_attrib_value_tbl(l_curr_row).attribute_value,
		l_active_flag,
		l_attrib_value_tbl(l_curr_row).priority
	);

	if (l_rowid is null) then
		--dbms_output.put_line('In insert into lf value  error');
         	 RAISE FND_API.G_EXC_ERROR;
  	end if;
  END LOOP;
  x_object_id := l_object_id;

	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --
--	7.	Commit the whole thing

      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
	p_count      =>      x_msg_count,
       	p_data       =>      x_msg_data
	);


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO CREATE_PERZ_LF_PVT;
	 x_return_status := FND_API.G_RET_STS_ERROR ;
	  --x_return_status := sqlcode||sqlerrm;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO CREATE_PERZ_LF_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN

	  ROLLBACK TO CREATE_PERZ_LF_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

END Create_lf_object;

-- *****************************************************************************
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: Update_lf_object
--	Type		: Public
--	Function	: Update attribute-value pairs for a given LF object and profile
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN 	NUMBER		Required
--		p_init_msg_list		IN 	VARCHAR2 	Optional
--						Default = FND_API.G_FALSE
--		p_commit		IN 	VARCHAR2
--						Default = FND_API.G_FALSE
--
--		p_profile_id		IN 	NUMBER		Optional
--		p_profile_name		IN 	VARCHAR2	Optional
--
--		p_application_id	IN 	NUMBER		Required
--		p_parent_id		IN 	NUMBER		Required
--		p_object_id		IN 	NUMBER		Optional
--		p_object_name		IN 	VARCHAR2	Optional
--		p_active_flag		IN 	VARCHAR2	Optional

--		p_object_type_id	IN 	NUMBER		Optional
--		p_object_type		IN 	VARCHAR2	Optional
--        	p_attrib_value_tbl	IN JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
--             		:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL   Optional
--
-- OUT :
--		x_object_id	 OUT NUMBER
--		x_return_status	 OUT VARCHAR2(1)
--		x_msg_count	 OUT NUMBER
--		x_msg_data	 OUT VARCHAR2(2000)
--
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes: 	Object id or name must be specified.
--			Profile id or name must be specified.
-- 	Current Restrictions: Will not handle the case where the object_type
--		it self is changes on the object - Srikanth 9-8-99
--
-- *****************************************************************************
PROCEDURE Update_lf_object
( 	p_api_version_number	IN	NUMBER,
 	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_profile_id            IN	NUMBER,
	p_profile_name          IN	VARCHAR2 := NULL,

	p_application_id	IN 	NUMBER,
	p_parent_id		IN 	NUMBER := NULL,
	p_object_Id		IN	NUMBER,
	p_object_name		IN 	VARCHAR2 := NULL,
	p_active_flag		IN 	VARCHAR2,

	p_object_type_id	IN 	NUMBER,
	p_object_type		IN 	VARCHAR2 := NULL,

	p_attrib_value_tbl	IN   	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
					:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL,

	x_object_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

       -- ******* Update_lf_object Local Variables - Standards ********
	l_api_name		VARCHAR2(60)  	:= 'Update Object';
	l_api_version_number	NUMBER 	:= p_api_version_number;

       -- ******* Update_lf_object Local Variables ********
	l_return_status    	VARCHAR2(240)    := FND_API.G_TRUE;
	l_Object_Tbl		JTF_PERZ_LF_PUB.LF_OBJECT_OUT_TBL_TYPE;
	l_profile_id		NUMBER		:= NULL;
	l_profile_name		VARCHAR2(60)   	:= NULL;
	l_object_type		VARCHAR2(60) 	:= p_object_type;
	l_object_type_id	NUMBER 		:= p_object_type_id;
	l_rowid			ROWID		:= NULL;
	l_object_name		VARCHAR2(60)   	:= p_object_name;
	l_parent_name		VARCHAR2(60)   	:= NULL;
	l_object_id		NUMBER		:= p_object_id;
	l_parent_id		NUMBER		:= p_parent_id;

	l_attrib_value_tbl	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
						:= p_attrib_value_tbl;
	l_db_attrib_value_tbl	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE;
	l_count		     	NUMBER     	:= p_attrib_value_tbl.count;
    	l_curr_row		NUMBER		:= NULL;
	l_value_id		NUMBER		:= NULL;
	l_active_flag		VARCHAR2(1) 	:= upper(p_active_flag);
	l_db_active_flag		VARCHAR2(1) 	:= NULL;
	l_obj_map_id		NUMBER		:= NULL;
	l_map_id		NUMBER		:= NULL;
	l_attribute_id		NUMBER		:= NULL;
	l_object_description	VARCHAR2(240)	:= NULL;
	l_object_version_number NUMBER :=	NULL;
	l_obj_type_version_no   NUMBER :=	NULL;
	l_parent_version_number NUMBER :=	NULL;
	l_obj_value_ver_no	NUMBER :=	NULL;



BEGIN
       -- ******* Update_lf_object Execution Plan ********
-- update_lf_object execution steps
--
--1. Check Profile, raise exception if error
--2. Check Object Type, raise exception if error
--3. Check Object, raise exception if error
--4. Loop through attribute table supplied (p_Attrib_Value_tbl)
--	and compare the values with the above plsql table type
--	4.1 Check the attribute
--		if different, raise the error
--		if not, compare the values with the database
--			if different, update the values in  DB table
--   End Loop
--
--
--5. Commit the whole thing

     -- ******* Standard Begins ********

	-- Standard Start of API savepoint
	SAVEPOINT     UPDATE_PERZ_LF_PVT;

	-- Standard call to check for call compatibility.
	--IF NOT FND_API.Compatible_API_Call
		--( l_api_version_number, p_api_version_number,
		--  l_api_name, G_PKG_NAME) THEN
		-- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	--END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success
  	x_return_status := FND_API.G_RET_STS_SUCCESS ;


-- Update_lf_object implementation

--1. Check if the profile exists

  l_profile_id := p_profile_id;
  l_profile_name := p_profile_name;
  l_return_status := FND_API.G_TRUE;
  if ((p_profile_id is NULL) OR
     (p_profile_id = FND_API.G_MISS_NUM)) then
	JTF_PERZ_PROFILE_PVT.check_profile_duplicates(
		l_profile_name,
		l_return_status,
		l_profile_id
	);


-- If profile does not exists, raise an error and exit

   if (l_return_status = FND_API.G_FALSE) then
          RAISE FND_API.G_EXC_ERROR;
   end if;
  end if;
--dbms_output.put_line('out 1');
--2. Check if Type Exists

  l_return_status := FND_API.G_TRUE;
  check_duplicate_obj_type (
	l_object_type,
	l_return_status,
	l_object_type_id,
	l_obj_type_version_no
  );

--  If object type is not found raising the error
   if (l_return_status = FND_API.G_FALSE) then
          RAISE FND_API.G_EXC_ERROR;
   end if;

--dbms_output.put_line('out 2');

-- 3. check the object

  l_return_status := FND_API.G_TRUE;
  l_object_name 	:= p_object_name;
  l_object_id	:= p_object_id;
  check_duplicate_obj (
	p_application_id,
	l_object_name,
	l_object_id,
	l_return_status,
	l_object_version_number
  );
  if (l_return_status = FND_API.G_FALSE) then
        RAISE FND_API.G_EXC_ERROR;
  else
	-- Check if the input parent id exists
  	l_return_status := FND_API.G_TRUE;
  	l_parent_name 	:= NULL;
  	l_parent_id	:= p_parent_id;
	if (l_parent_id is not null) then
  		check_duplicate_obj (
			p_application_id,
			l_parent_name,
			l_parent_id,
			l_return_status,
			l_parent_version_number
  		);
  		if (l_return_status = FND_API.G_FALSE) then
			-- parent id does not exist
        		RAISE FND_API.G_EXC_ERROR;
  		else
		-- Update the object with the parent id
			update_jtf_perz_lf_object (
				l_object_id,
				l_parent_id,
				p_application_id,
				l_object_description,
				l_rowid,
				l_object_version_number
			) ;
  		end if;
  	end if;
  end if;

--dbms_output.put_line('out 3');

-- Make sure the active flag is given else default it to Yes(Y)
  if (l_active_flag is null) then
	l_active_flag := 'Y';
   /*
  else
   if (l_active_flag <> 'Y') OR (l_active_flag != 'N') then
--dbms_output.put_line('out 3.2' || l_active_flag);
-- The above comparision must change to FND_API... in final version or later
-- Srikanth - 9-7-99
			RAISE FND_API.G_EXC_ERROR;
	end if;
   */
  end if;

--dbms_output.put_line('out 3.2');
  for l_curr_row in 1..l_count
	LOOP
	-- 4.1 Check the attribute
	   l_rowid := NULL;
  	   l_return_status := FND_API.G_TRUE;
	   l_attribute_id := NULL;
--dbms_output.put_line('attribute name '||l_attrib_value_tbl(l_curr_row).attribute_name);
--dbms_output.put_line('attribute type '||l_attrib_value_tbl(l_curr_row).attribute_type);
	   check_attribute(
		l_attrib_value_tbl(l_curr_row).attribute_name,
		l_attrib_value_tbl(l_curr_row).attribute_type,
		l_rowid,
		l_attribute_id,
		l_return_status
	   );
   	   if (l_return_status = FND_API.G_FALSE) then
--dbms_output.put_line('out 4');
			--RAISE FND_API.G_EXC_ERROR;
			--	Enhancement# 1097254
			-- 	This enhancement is done as a temporary solution to
			--   allow the java layer users to  add an attribute to
			--   the object_type on  the fly.
			--	This was done as there is no API corresponsing to
			--   save_lf_object_type at the Java layer and it is not
			--   exposed as the class to end users.
			--	Once the api is available, the java layer will make
			--   separate calls to save_lf_object_type() and
			--   save_lf_object() to accomplish the same thing.
			--	These are slated to be fixed in future release.
			--   Till then, we can create the attribute record and
			--   that of the attribute - object type map record.
          	-- insert row into the attribute  table
			-- Enhancement 1097254 Begins
			l_rowid := NULL;
			l_attribute_id := NULL;
			insert_jtf_perz_lf_attrib(
				l_rowid,
				l_attribute_id,
				l_attrib_value_tbl(l_curr_row).attribute_name,
				l_attrib_value_tbl(l_curr_row).attribute_type
			);
			if (l_rowid is null) then
			  -- raising the error if unable to insert the attribute record
				RAISE FND_API.G_EXC_ERROR;
			end if;
			 -- create a map entry object_type - attribute in
			--   jtf_perz_obj_type_map table
			l_map_id := null;
			l_rowid := NULL;
			insert_jtf_perz_obj_type_map(
				l_rowid,
				l_map_id,
				l_object_type_id,
				l_attribute_id
			);
			if (l_rowid is null) then
			-- raising the error if unable to insert the map record
				RAISE FND_API.G_EXC_ERROR;
			end if;

			l_attrib_value_tbl(l_curr_row).attribute_id := l_attribute_id;
			l_db_attrib_value_tbl(l_curr_row).attribute_id := l_attribute_id;
			l_value_id := NULL;
			l_rowid := NULL;
			l_obj_map_id := NULL;

			-- Enhancement 1097254 Ends
	   else
		l_attrib_value_tbl(l_curr_row).attribute_id := l_attribute_id;
		l_db_attrib_value_tbl(l_curr_row).attribute_id := l_attribute_id;
		l_value_id := NULL;
		l_rowid := NULL;
		l_obj_map_id := NULL;
	  end if;
--dbms_output.put_line('out 5');
		BEGIN
			select d.perz_lf_value_id, d.obj_map_id, d.attribute_value,
				d.active_flag, d.priority, object_version_number
			into l_value_id, l_obj_map_id,
				l_db_attrib_value_tbl(l_curr_row).attribute_value,
				l_db_active_flag,
				l_db_attrib_value_tbl(l_curr_row).priority,
				l_obj_value_ver_no

			from jtf_perz_lf_value d, jtf_perz_obj_map e,
				jtf_perz_obj_type_map f
			where
				e.object_id = l_object_id
			and	f.object_type_id = l_object_type_id
			and	f.attribute_id = l_attribute_id
			and	d.profile_id = l_profile_id
			and	e.map_id = f.obj_type_map_id
			and	e.obj_map_id = d.obj_map_id;

--dbms_output.put_line('out 6');
			if (( l_db_attrib_value_tbl(l_curr_row).attribute_value <>
				l_attrib_value_tbl(l_curr_row).attribute_value) OR
			    ( l_db_active_flag <> l_active_flag) OR
			    (  l_db_attrib_value_tbl(l_curr_row).priority <>
				l_attrib_value_tbl(l_curr_row).priority))
			THEN
				update_jtf_perz_lf_value
				( l_rowid,
				  l_value_id,
				  l_profile_id,
				  l_obj_map_id,
				  l_attrib_value_tbl(l_curr_row).attribute_value,
				  l_active_flag,
				  l_attrib_value_tbl(l_curr_row).priority,
				  l_obj_value_ver_no);
--dbms_output.put_line('out 7');
			end if;
		EXCEPTION
		    WHEN NO_DATA_FOUND THEN
--dbms_output.put_line('ecode '|| sqlcode);
--dbms_output.put_line('etext '|| sqlerrm);
--dbms_output.put_line('out 8');
			-- insert table handlers must be called for
			-- value and object map here - Srikanth
			-- Check if the attribute - object type map exists
			-- 	if yes
			--		call the table handler for object map
			--		with appropriate map id
			-- 		pass the obj_map_id to insert_jtf_perz_lf_value()
			--	if not raise error

			-- Checking the attribute - object type map
			BEGIN
				l_map_id := NULL;
				select obj_type_map_id into l_map_id
				from jtf_perz_obj_type_map
				where attribute_id = l_attribute_id
				and   object_type_id = l_object_type_id;
			--   SMATTEGU Bug#1098513 changes begin
				BEGIN
					select OBJ_MAP_ID into l_obj_map_id
					from jtf_perz_obj_map
					where MAP_ID = l_map_id
					and OBJECT_ID = l_object_id;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_rowid := NULL;
					l_obj_map_id := NULL;
					insert_jtf_perz_obj_map(
						l_rowid,
						l_obj_map_id,
						l_map_id,
						l_object_id
					);
					if (l_rowid is null) then
						--dbms_output.put_line('while inserting object map');
						RAISE FND_API.G_EXC_ERROR;
					end if;
				END;
			--   SMATTEGU Bug#1098513 changes end

				l_rowid := NULL;
				l_value_id := NULL;
				--dbms_output.put_line('l_obj_map_id '||l_obj_map_id);
				insert_jtf_perz_lf_value(
					l_rowid,
					l_value_id,
					l_profile_id,
					l_obj_map_id,
					l_attrib_value_tbl(l_curr_row).attribute_value,
					l_active_flag,
					l_attrib_value_tbl(l_curr_row).priority
				);

				if (l_rowid is null) then
         	 			RAISE FND_API.G_EXC_ERROR;
  				end if;

			EXCEPTION
		    	WHEN NO_DATA_FOUND THEN
				RAISE FND_API.G_EXC_ERROR;
			WHEN OTHERS THEN
				 RAISE FND_API.G_EXC_ERROR;
			END;
		END;
	END LOOP;
	x_object_id := l_object_id;
   -- End of API body.
      --
--	5.	Commit the whole thing

      -- Standard check of p_commit.
  IF FND_API.To_Boolean ( p_commit )  THEN
          COMMIT WORK;
  END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
	p_count         =>      x_msg_count,
      p_data          =>      x_msg_data
   );
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO UPDATE_PERZ_LF_PVT;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);


	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO UPDATE_PERZ_LF_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

  WHEN OTHERS THEN

	  ROLLBACK TO UPDATE_PERZ_LF_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;
END Update_LF_Object;
-- *****************************************************************************
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: save_lf_object
--	Type		: Public
--	Function	: Create and update if exists, attribute value pairs for
--			a given object and profile in an application_id domain.
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN NUMBER		Required
--		p_init_msg_list		IN VARCHAR2 		Optional
--								Default = FND_API.G_FALSE
--		p_application_id	IN NUMBER		Required
--		p_profile_id		IN NUMBER		Required
--		p_profile_name		IN VARCHAR2		Optional
--		p_profile_type          IN VARCHAR2,
--		p_profile_attrib_tbl	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE	Optional
--		p_parent_id		IN NUMBER		Required
--		p_object_id		IN NUMBER		Optional
--		p_object_name		IN VARCHAR2		Required
--		p_object_description	IN VARCHAR2		Optional
--		p_object_type_id	IN NUMBER		Optional
--		p_object_type		IN VARCHAR2		Required
--		p_active_flag		IN VARCHAR2		Optional
--								Default = NO
--        p_attrib_value_tbl	IN JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
--             := JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL   Optional
--		p_commit		IN VARCHAR2	Optional
--
-- OUT :
--		x_object_id	 OUT  NUMBER
--		x_return_status	 OUT  VARCHAR2(1)
--		x_msg_count	 OUT  NUMBER
--		x_msg_data	 OUT VARCHAR2(2000)
--
--
--	Version	:	Current version	1.0
--			 	Initial version 	1.0
--
--	Notes:
--
-- *****************************************************************************

 PROCEDURE save_lf_object
( 	p_api_version_number	IN NUMBER,
  	p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN VARCHAR2 := FND_API.G_FALSE,

	p_profile_id            IN NUMBER,
	p_profile_name          IN VARCHAR2,
	p_profile_type          IN VARCHAR2,
	p_profile_attrib_tbl	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
				:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

	p_application_id	IN NUMBER,
	p_parent_id		IN NUMBER,
	p_object_type_id	IN NUMBER,
	p_object_type           IN VARCHAR2,

	p_object_id             IN NUMBER,
	p_object_name           IN VARCHAR2,
	p_object_description	IN VARCHAR2,

	p_active_flag		IN VARCHAR2,
	p_attrib_value_tbl	IN JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
				:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL,

	x_object_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
       -- ******* save_lf_object Local Variables - for standards ********
	l_api_name		VARCHAR2(60)  := 'Save LF Object';
	l_api_version_number	NUMBER 	:= p_api_version_number;

	 -- ******* save_lf_object Local Variables - for implementation ********
	l_return_status    	VARCHAR2(240)    := FND_API.G_TRUE;
	l_profile_id		NUMBER		:= NULL;
	l_profile_name		VARCHAR2(60) := p_profile_name;
	l_profile_type		VARCHAR2(30) := p_profile_type;
	l_profile_attrib	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
				:= p_profile_attrib_tbl;
	l_commit		VARCHAR2(1)	:= FND_API.G_TRUE;
	l_attrib_value_tbl	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
					:= p_attrib_value_tbl;
	l_object_type		VARCHAR2(60) 	:= p_object_type;
	l_object_type_id	NUMBER 		:= p_object_type_id;
	l_rowid				ROWID		:= NULL;
	l_object_name		VARCHAR2(60)   	:= p_object_name;
	l_object_id			NUMBER		:= p_object_id;
	l_count		     	NUMBER     	:= p_attrib_value_tbl.count;
    	l_curr_row		NUMBER		:= NULL;
	l_out_object_id		NUMBER		:= NULL;
	l_out_object_type_id	NUMBER 		:= p_object_type_id;
	l_out_obj_type_map_tbl	JTF_PERZ_LF_PVT.OBJ_TYPE_MAP_TBL_TYPE;
	l_attrib_rec_tbl	JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE;
	l_active_flag		VARCHAR2(1) 	:= upper(p_active_flag);
	l_object_type_desc	VARCHAR2(240)	:= NULL;
	l_init_msg_list		VARCHAR2(1)		:= FND_API.G_FALSE;

	l_object_version_number NUMBER :=	NULL;
	l_obj_type_version_no   NUMBER :=	NULL;
	l_parent_version_number NUMBER :=	NULL;
	l_obj_value_ver_no	NUMBER :=	NULL;

BEGIN

       -- ******* Execution Plan ********

-- save_lf_object execution steps
-- 0.	check profile
-- 0.1	if not, create profile
-- 1.	Check if object_type exists,
-- 1.1		If not, call save_lf_object_type()
-- 2.	check if object exists
-- 2.1  	if object exists, Call update_lf_object()
-- 2.2		if not, call create_lf_object()
-- 3.	Commit the whole thing


       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	save_lf_object;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
	( l_api_version_number,
	 p_api_version_number,
	 l_api_name,
	G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;



       -- ******* save_lf_object implementation ********
--1. Check if the profile exists. This check will be performed
--	irrespective of whether profile id is given or not.
--	Because, in case of mobile users they might have created
--	a profile on the mobile client and passing the
--	profile id.

  l_profile_id := p_profile_id;
  l_profile_name := p_profile_name;
  l_profile_type := p_profile_type;
  l_return_status := FND_API.G_TRUE;

--dbms_output.put_line (' profile id'|| l_profile_id);
--dbms_output.put_line (' profile name'|| l_profile_name);
  JTF_PERZ_PROFILE_PVT.check_profile_duplicates(
	l_profile_name,
	l_return_status,
	l_profile_id
  );

--dbms_output.put_line (' out  1');

-- If profile does not exists, create it.
-- 	If not successfuk in creation raise an error and exit

   if (l_return_status = FND_API.G_FALSE) then

--dbms_output.put_line (' out  2');
	l_return_status := FND_API.G_RET_STS_SUCCESS;
	l_commit 	:= FND_API.G_FALSE;
  	l_profile_id := p_profile_id;

	JTF_PERZ_PROFILE_PVT.Create_Profile(
		p_api_version_number	=> l_api_version_number,
  		p_init_msg_list		=> l_init_msg_list,
		p_commit		=> l_commit,
		p_profile_id		=> l_profile_id,
		p_profile_name		=> l_profile_name,
		p_profile_type		=> l_profile_type,
		p_profile_attrib_tbl	=> l_profile_attrib,
		x_profile_name		=> l_profile_name,
		x_profile_id		=> l_profile_id,
		x_return_status		=> l_return_status,
		x_msg_count		=> x_msg_count,
		x_msg_data		=> x_msg_data
	);
	if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
		RAISE FND_API.G_EXC_ERROR;
	end if;
   end if;



--	Enhancement# 1075579
-- 	This enhancement is done as a temporary solution to allow the
--	java layer users to  add an attribute to the object_type on  the fly.
--	This was done as there is no API corresponsing to save_lf_object_type
--	at the Java layer and it is not exposed as the class to end users.
--	Once the api is available, the java layer will make separate calls to
--	save_lf_object_type() and save_lf_object() to accomplish the same thing.
--	These are slated to be fixed in future release. Till then, we can comment
--	the following checking for object type and calling the save_lf_object_type()
--	selectively there by forcing the save_lf_object_api() call for
--	each save_lf_object() call. This might have some performance impact.
	--Srikanth

/* Enhancement# 1075579  comments start
--2. Check if Type Exists

  l_return_status := FND_API.G_TRUE;
  check_duplicate_obj_type (
	l_object_type,
	l_return_status,
	l_object_type_id,
	l_obj_type_version_no
  );

-- If object type  does not exists, create it.
-- 	If not successful in creation raise an error and exit
   if (l_return_status = FND_API.G_FALSE) then

   Enhancement# 1075579  comments end */
	l_return_status := FND_API.G_RET_STS_SUCCESS;
	l_commit 	:= FND_API.G_FALSE;

	for l_curr_row in 1..l_count
	LOOP
	   l_attrib_rec_tbl(l_curr_row).ATTRIBUTE_ID := l_attrib_value_tbl(l_curr_row).ATTRIBUTE_ID;
	   l_attrib_rec_tbl(l_curr_row).ATTRIBUTE_NAME := l_attrib_value_tbl(l_curr_row).ATTRIBUTE_NAME;
	   l_attrib_rec_tbl(l_curr_row).ATTRIBUTE_TYPE := l_attrib_value_tbl(l_curr_row).ATTRIBUTE_TYPE;

	END LOOP;

	save_lf_object_type
	(
		p_api_version_number	=> l_api_version_number,
  		p_init_msg_list		=> l_init_msg_list,
		p_commit		=> l_commit,

		p_object_type_id        => l_object_type_id,
		p_object_type           => l_object_type,
		p_object_type_desc	=> l_object_type_desc,

		p_attrib_rec_tbl	=> l_attrib_rec_tbl,

		x_object_type_id	=> l_out_object_type_id,
		x_obj_type_map_tbl	=> l_out_obj_type_map_tbl,
		x_return_status		=> l_return_status,
		x_msg_count		=> x_msg_count,
		x_msg_data		=> x_msg_data
	);

	if (l_return_status = FND_API.G_RET_STS_SUCCESS) then
		l_object_type_id := l_out_object_type_id;
-- 		dbms_output.put_line(' cre type id' ||l_object_type_id);
	else
--dbms_output.put_line (' out  6');
		RAISE FND_API.G_EXC_ERROR;
	end if;

/* Enhancement# 1075579  comments start
   end if;
   Enhancement# 1075579  comments end */

-- 2.	check if object exists



  l_return_status := FND_API.G_TRUE;
  l_object_name 	:= p_object_name;
  l_object_id	:= p_object_id;

  check_duplicate_obj (
	p_application_id,
	l_object_name,
	l_object_id,
	l_return_status,
	l_object_version_number
  );
--dbms_output.put_line(' out  7');
  if (l_return_status = FND_API.G_FALSE) then
--dbms_output.put_line(' out 8');
	l_return_status := FND_API.G_RET_STS_SUCCESS;
	l_commit 	:= FND_API.G_FALSE;

	Create_lf_object (
		p_api_version_number	=> l_api_version_number,
  		p_init_msg_list		=> l_init_msg_list,
		p_commit		=> l_commit,

		p_profile_id            => l_profile_id,
		p_profile_name          => p_profile_name,

		p_application_id	=> p_application_id,
		p_parent_id		=> p_parent_id,
		p_object_id             => l_object_id,
		p_object_name           => l_object_name,

		p_object_type_id        => l_object_type_id,
		p_object_type           => l_object_type,

		p_attrib_value_tbl	=> l_attrib_value_tbl,

		x_object_id		=> l_out_object_id,
		x_return_status		=> l_return_status,
		x_msg_count		=> x_msg_count,
		x_msg_data		=> x_msg_data
	);

	if (l_return_status = FND_API.G_RET_STS_SUCCESS) then
--dbms_output.put_line(' out  8.5');
		l_object_id 	:= l_out_object_id;
		x_object_id 	:= l_out_object_id;
		x_return_status := FND_API.G_RET_STS_SUCCESS;
	else
--dbms_output.put_line(' out  9');
		RAISE FND_API.G_EXC_ERROR;
	end if;

  else
--dbms_output.put_line(' out 10');
	l_return_status := FND_API.G_RET_STS_SUCCESS;
	l_commit 	:= FND_API.G_FALSE;

	-- Make sure the active flag is given else default it to Yes(Y)
  	if (l_active_flag is null) then
		l_active_flag := 'Y';
  	end if;

	Update_lf_object(
		p_api_version_number	=> l_api_version_number,
  		p_init_msg_list		=> l_init_msg_list,
		p_commit		=> l_commit,

		p_profile_id            => l_profile_id,
		p_profile_name          => p_profile_name,

		p_application_id	=> p_application_id,
		p_parent_id		=> p_parent_id,
		p_object_id             => l_object_id,
		p_object_name           => l_object_name,
		p_active_flag		=> l_active_flag,

		p_object_type_id        => l_object_type_id,
		p_object_type           => l_object_type,

		p_attrib_value_tbl	=> l_attrib_value_tbl,

		x_object_id		=> l_out_object_id,
		x_return_status		=> l_return_status,
		x_msg_count		=> x_msg_count,
		x_msg_data		=> x_msg_data
	);

	if (l_return_status = FND_API.G_RET_STS_SUCCESS) then
--dbms_output.put_line (' out  11');
		l_object_id 	:= l_out_object_id;
		x_object_id 	:= l_out_object_id;
		x_return_status := FND_API.G_RET_STS_SUCCESS;
-- 		dbms_output.put_line(' out  6');
-- 		dbms_output.put_line('object_id '||x_object_id);
	else
--dbms_output.put_line (' out 12');
		RAISE FND_API.G_EXC_ERROR;
	end if;

  end if;

-- 3.	Commit the whole thing

	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --

      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
    	( p_count         	=>      x_msg_count,
          p_data          	=>      x_msg_data
    	);

  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO save_lf_object;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO save_lf_object;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN

	  ROLLBACK TO save_lf_object;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;
END save_lf_object;

-- -- *****************************************************************************
-- -- *****************************************************************************
-- Start of Comments
--
--	API name 	: Get_lf_object
--	Type		: Public
--	Function	: Get attribute value pairs for a given LF object and profile
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN NUMBER		Required
--		p_init_msg_list		IN VARCHAR2 		Optional
--					Default = FND_API.G_FALSE
--		p_profile_id		IN NUMBER	Optional
--		p_profile_name		IN VARCHAR2	Optional
--		p_parent_id		IN NUMBER	Optional
--		p_object_id		IN NUMBER	Optional
--		p_object_name		IN VARCHAR2	Optional
--		p_obj_active_flag	IN VARCHAR2	Optional
--		p_get_children_flag	IN VARCHAR2	Optional
--
-- OUT  :
--		x_object_id	 OUT  Optional
--		x_Object_Tbl	 OUT JTF_PERZ_LF_PUB.LF_OBJECT_OUT_TBL_TYPE,
--		x_return_status	 OUT  VARCHAR2(1)
--		x_msg_count	 OUT  NUMBER
--		x_msg_data	 OUT  VARCHAR2(2000)
--
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes:
--
-- *****************************************************************************

PROCEDURE Get_lf_object
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,

	p_application_id	IN 	NUMBER,
	p_priority		IN 	NUMBER,
	p_profile_id            IN	NUMBER,
	p_profile_name          IN	VARCHAR2,
	P_Object_Id		IN	NUMBER,
	p_Object_Name		IN	VARCHAR,
	p_obj_active_flag	IN 	VARCHAR2,
	p_get_children_flag	IN	VARCHAR2,
	x_Object_Tbl	 OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_LF_PUB.LF_OBJECT_OUT_TBL_TYPE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
	-- local variable in get_lf_object to adhere to standards

	l_api_version_number	NUMBER 	:= p_api_version_number;
 	l_api_name		CONSTANT VARCHAR2(30)
							:= 'Get LF Object';
	-- local variable in get_lf_object to adhere to standards
	l_profile_id		NUMBER		:= NULL;
	l_return_status    	VARCHAR2(240) 	:= FND_API.G_RET_STS_SUCCESS;
	l_profile_name		VARCHAR2(60)	:= NULL;
	l_object_name		VARCHAR2(60)   	:= p_object_name;
	l_object_id		NUMBER		:= p_object_id;
    	l_active_flag		VARCHAR2(1) := upper(p_obj_active_flag);
	l_count			NUMBER;
	l_value_id		NUMBER;

	l_object_out_rec	JTF_PERZ_LF_PUB.LF_OBJECT_OUT_REC_TYPE := NULL;

	l_Object_Tbl		JTF_PERZ_LF_PUB.LF_OBJECT_OUT_TBL_TYPE;

	Cursor C_get_child_pioi(p_profile_id NUMBER, p_application_id NUMBER,
			p_object_id NUMBER, p_active_flag VARCHAR2) IS

		select /*+ first_rows */
			d.perz_lf_value_id, a.parent_id, a.object_id, a.application_id, a.object_name,
			a.object_description, b.object_type_id, b.object_type_name,
			c.attribute_id, c.attribute_name, c.attribute_type,
			d.attribute_value, d.active_flag, d.priority
		from jtf_perz_lf_object a, jtf_perz_lf_object_type b,
			jtf_perz_lf_attrib c, jtf_perz_lf_value d,
			jtf_perz_obj_map e, jtf_perz_obj_type_map f
		where
			a.parent_id = p_object_id
		and	a.application_id = p_application_id
		and	d.profile_id = p_profile_id
		and	d.active_flag = p_active_flag
		and	e.object_id = a.object_id
		and	e.obj_map_id = d.obj_map_id
		and	e.map_id = f.obj_type_map_id
		and	f.object_type_id = b.object_type_id
		and	f.attribute_id = c.attribute_id
		ORDER BY a.object_id;

	Cursor C_get_child_pnoi(p_profile_name VARCHAR2, p_application_id NUMBER,
			p_object_id NUMBER, p_active_flag VARCHAR2) IS

		select /*+ first_rows */
			d.perz_lf_value_id, a.parent_id, a.object_id, a.application_id, a.object_name,
			a.object_description, b.object_type_id, b.object_type_name,
			c.attribute_id, c.attribute_name, c.attribute_type,
			d.attribute_value, d.active_flag, d.priority
		from jtf_perz_lf_object a, jtf_perz_lf_object_type b,
			jtf_perz_lf_attrib c, jtf_perz_lf_value d,
			jtf_perz_obj_map e, jtf_perz_obj_type_map f,
			jtf_perz_profile p
		where
			a.parent_id = p_object_id
		and	a.application_id = p_application_id
		and	d.profile_id = p.profile_id
		and	d.active_flag = p_active_flag
		and	p.profile_name = p_profile_name
		and	e.object_id = a.object_id
		and	e.obj_map_id = d.obj_map_id
		and	e.map_id = f.obj_type_map_id
		and	f.object_type_id = b.object_type_id
		and	f.attribute_id = c.attribute_id
		ORDER BY a.object_id;

	Cursor C_get_child_pnon(p_profile_name VARCHAR2, p_application_id NUMBER,
			p_object_name VARCHAR2, p_active_flag VARCHAR2) IS

		select d.perz_lf_value_id, a.parent_id, a.object_id, a.application_id, a.object_name,
			a.object_description, b.object_type_id, b.object_type_name,
			c.attribute_id, c.attribute_name, c.attribute_type,
			d.attribute_value, d.active_flag, d.priority
		from jtf_perz_lf_object a, jtf_perz_lf_object_type b,
			jtf_perz_lf_attrib c, jtf_perz_lf_value d,
			jtf_perz_obj_map e, jtf_perz_obj_type_map f,
			jtf_perz_lf_object o, jtf_perz_profile p
		where
			o.object_name = p_object_name
		and 	o.object_id = a.parent_id
		and	a.application_id = p_application_id
		and	d.profile_id = p.profile_id
		and	d.active_flag = p_active_flag
		and	p.profile_name = p_profile_name
		and	e.object_id = a.object_id
		and	e.obj_map_id = d.obj_map_id
		and	e.map_id = f.obj_type_map_id
		and	f.object_type_id = b.object_type_id
		and	f.attribute_id = c.attribute_id
		ORDER BY a.object_id;

	Cursor C_get_child_pion(p_profile_id NUMBER, p_application_id NUMBER,
			p_object_name VARCHAR2, p_active_flag VARCHAR2) IS

		select d.perz_lf_value_id, a.parent_id, a.object_id, a.application_id, a.object_name,
			a.object_description, b.object_type_id, b.object_type_name,
			c.attribute_id, c.attribute_name, c.attribute_type,
			d.attribute_value, d.active_flag, d.priority
		from jtf_perz_lf_object a, jtf_perz_lf_object_type b,
			jtf_perz_lf_attrib c, jtf_perz_lf_value d,
			jtf_perz_obj_map e, jtf_perz_obj_type_map f,
			jtf_perz_lf_object o
		where
			o.object_name = p_object_name
		and 	o.object_id = a.parent_id
		and	a.application_id = p_application_id
		and	d.profile_id = p_profile_id
		and	d.active_flag = p_active_flag
		and	e.object_id = a.object_id
		and	e.obj_map_id = d.obj_map_id
		and	e.map_id = f.obj_type_map_id
		and	f.object_type_id = b.object_type_id
		and	f.attribute_id = c.attribute_id
		ORDER BY a.object_id;

	     Cursor C_get_no_child_pioi (p_profile_id NUMBER, p_application_id NUMBER,
			p_object_id NUMBER, p_active_flag VARCHAR2) IS
		select  d.perz_lf_value_id, a.parent_id, a.object_id,
			a.application_id, a.object_name,
			a.object_description, b.object_type_id, b.object_type_name,
			 c.attribute_id, c.attribute_name, c.attribute_type,
			d.attribute_value, d.active_flag, d.priority
		from jtf_perz_lf_object a, jtf_perz_lf_object_type b,
			jtf_perz_lf_attrib c, jtf_perz_lf_value d,
			jtf_perz_obj_map e, jtf_perz_obj_type_map f
		where
			a.object_id	= p_object_id
		and	a.application_id = p_application_id
		and	d.profile_id	= p_profile_id
		and	d.active_flag	= p_active_flag
		and	e.object_id	= a.object_id
		and	e.obj_map_id	= d.obj_map_id
		and	e.map_id	= f.obj_type_map_id
		and	f.object_type_id = b.object_type_id
		and	f.attribute_id	= c.attribute_id
		ORDER BY a.object_id;

	     Cursor C_get_no_child_pnoi (p_profile_name VARCHAR2, p_application_id NUMBER,
			p_object_id NUMBER, p_active_flag VARCHAR2) IS
		select  d.perz_lf_value_id, a.parent_id, a.object_id,
			a.application_id, a.object_name,
			a.object_description, b.object_type_id, b.object_type_name,
			 c.attribute_id, c.attribute_name, c.attribute_type,
			d.attribute_value, d.active_flag, d.priority
		from jtf_perz_lf_object a, jtf_perz_lf_object_type b,
			jtf_perz_lf_attrib c, jtf_perz_lf_value d,
			jtf_perz_obj_map e, jtf_perz_obj_type_map f,
			jtf_perz_profile p
		where
			a.object_id	= p_object_id
		and	a.application_id = p_application_id
		and	d.profile_id	= p.profile_id
		and	p.profile_name	= p_profile_name
		and	d.active_flag	= p_active_flag
		and	e.object_id	= a.object_id
		and	e.obj_map_id	= d.obj_map_id
		and	e.map_id	= f.obj_type_map_id
		and	f.object_type_id = b.object_type_id
		and	f.attribute_id	= c.attribute_id
		ORDER BY a.object_id;

	     Cursor C_get_no_child_pnon (p_profile_name VARCHAR2, p_application_id NUMBER,
			p_object_name VARCHAR2, p_active_flag VARCHAR2) IS
		select  d.perz_lf_value_id, a.parent_id, a.object_id,
			a.application_id, a.object_name,
			a.object_description, b.object_type_id, b.object_type_name,
			 c.attribute_id, c.attribute_name, c.attribute_type,
			d.attribute_value, d.active_flag, d.priority
		from jtf_perz_lf_object a, jtf_perz_lf_object_type b,
			jtf_perz_lf_attrib c, jtf_perz_lf_value d,
			jtf_perz_obj_map e, jtf_perz_obj_type_map f,
			jtf_perz_profile p
		where
			a.object_name	= p_object_name
		and	a.application_id = p_application_id
		and	d.profile_id	= p.profile_id
		and	p.profile_name	= p_profile_name
		and	d.active_flag	= p_active_flag
		and	e.object_id	= a.object_id
		and	e.obj_map_id	= d.obj_map_id
		and	e.map_id	= f.obj_type_map_id
		and	f.object_type_id = b.object_type_id
		and	f.attribute_id	= c.attribute_id
		ORDER BY a.object_id;


	     Cursor C_get_no_child_pion (p_profile_id NUMBER, p_application_id NUMBER,
			p_object_name VARCHAR2, p_active_flag VARCHAR2) IS
		select  d.perz_lf_value_id, a.parent_id, a.object_id,
			a.application_id, a.object_name,
			a.object_description, b.object_type_id, b.object_type_name,
			 c.attribute_id, c.attribute_name, c.attribute_type,
			d.attribute_value, d.active_flag, d.priority
		from jtf_perz_lf_object a, jtf_perz_lf_object_type b,
			jtf_perz_lf_attrib c, jtf_perz_lf_value d,
			jtf_perz_obj_map e, jtf_perz_obj_type_map f
		where
			a.object_name	= p_object_name
		and	a.application_id = p_application_id
		and	d.profile_id	= p_profile_id
		and	d.active_flag	= p_active_flag
		and	e.object_id	= a.object_id
		and	e.obj_map_id	= d.obj_map_id
		and	e.map_id	= f.obj_type_map_id
		and	f.object_type_id = b.object_type_id
		and	f.attribute_id	= c.attribute_id
		ORDER BY a.object_id;



BEGIN

       -- ******* Get_lf_object Execution Plan ********

--	1. Check the validity of the profile name (if only name is given)
--		if not valid raise error and exit
--	2. If object name is given, check it's validity
--	3. If the get_children flag, select the info
--		where object_id supplied is the parent_id
--	4. If get_children_flag is not
--		select the info depensing on the profile, object and
--		application ids.

       -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
--      IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--	THEN
--		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--	END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;


       -- ******* Get_lf_object implementation ********

-- Make sure the active flag is given else default it to Yes(Y)
  if (l_active_flag is null) OR (l_active_flag = FND_API.G_MISS_CHAR)  then
	l_active_flag := 'Y';
  end if;

  l_object_name := p_object_name;
  l_object_id	:= p_object_id;
  l_profile_id := p_profile_id;
  l_profile_name := p_profile_name;

  -- Assumption is application id is provided
  --	irrespective what ever be the case - srikanth Nov 9th 1999
-- 3. If the get_children flag

  if (UPPER(p_get_children_flag) = 'Y') then

		-- get the children only if the parent is active.
		-- Currently this condition is not handled -Srikanth 9-5-99

	if (((p_profile_id IS NOT NULL) AND
		(p_profile_id <> FND_API.G_MISS_NUM)) AND
		((p_object_id IS NOT NULL) AND
		(p_object_id <> FND_API.G_MISS_NUM))) then
		l_count := 1;

		open C_get_child_pioi (l_profile_id, p_application_id,
					l_object_id,l_active_flag);
 		loop

			fetch C_get_child_pioi
			into l_value_id,
				l_object_out_rec.parent_id,
				l_object_out_rec.object_id,
				l_object_out_rec.application_id,
				l_object_out_rec.object_name,
				l_object_out_rec.object_description,
				l_object_out_rec.object_type_id,
				l_object_out_rec.object_type,
				l_object_out_rec.attribute_id,
				l_object_out_rec.attribute_name,
				l_object_out_rec.attribute_type,
				l_object_out_rec.attribute_value,
				l_object_out_rec.active_flag,
				l_object_out_rec.priority;
			exit when C_get_child_pioi%NOTFOUND;
			if ( C_get_child_pioi%FOUND = TRUE) then
				l_object_tbl(l_count).parent_id := l_object_out_rec.parent_id;
				l_object_tbl(l_count).object_id := l_object_out_rec.object_id;
				l_object_tbl(l_count).application_id := l_object_out_rec.application_id;
				l_object_tbl(l_count).object_name := l_object_out_rec.object_name;
				l_object_tbl(l_count).object_description := l_object_out_rec.object_description;
				l_object_tbl(l_count).object_type_id := l_object_out_rec.object_type_id;
				l_object_tbl(l_count).object_type := l_object_out_rec.object_type;
				l_object_tbl(l_count).attribute_id := l_object_out_rec.attribute_id;
				l_object_tbl(l_count).attribute_name := l_object_out_rec.attribute_name;
				l_object_tbl(l_count).attribute_type := l_object_out_rec.attribute_type;
				l_object_tbl(l_count).attribute_value := l_object_out_rec.attribute_value;
				l_object_tbl(l_count).active_flag := l_object_out_rec.active_flag;
				l_object_tbl(l_count).priority := l_object_out_rec.priority;
				l_count := l_count + 1;
			end if;
 		end loop;
		close C_get_child_pioi;

	elsif (((p_profile_name IS NOT NULL) AND
		(p_profile_name <> FND_API.G_MISS_CHAR ))AND
		((p_object_id IS NOT NULL) AND
		(p_object_id <> FND_API.G_MISS_NUM))) then
		l_count := 1;

		open C_get_child_pnoi (l_profile_name, p_application_id,
					l_object_id,l_active_flag);
 		loop

			fetch C_get_child_pnoi
			into l_value_id,
				l_object_out_rec.parent_id,
				l_object_out_rec.object_id,
				l_object_out_rec.application_id,
				l_object_out_rec.object_name,
				l_object_out_rec.object_description,
				l_object_out_rec.object_type_id,
				l_object_out_rec.object_type,
				l_object_out_rec.attribute_id,
				l_object_out_rec.attribute_name,
				l_object_out_rec.attribute_type,
				l_object_out_rec.attribute_value,
				l_object_out_rec.active_flag,
				l_object_out_rec.priority;
			exit when C_get_child_pnoi%NOTFOUND;
			if ( C_get_child_pnoi%FOUND = TRUE) then
				l_object_tbl(l_count).parent_id := l_object_out_rec.parent_id;
				l_object_tbl(l_count).object_id := l_object_out_rec.object_id;
				l_object_tbl(l_count).application_id := l_object_out_rec.application_id;
				l_object_tbl(l_count).object_name := l_object_out_rec.object_name;
				l_object_tbl(l_count).object_description := l_object_out_rec.object_description;
				l_object_tbl(l_count).object_type_id := l_object_out_rec.object_type_id;
				l_object_tbl(l_count).object_type := l_object_out_rec.object_type;
				l_object_tbl(l_count).attribute_id := l_object_out_rec.attribute_id;
				l_object_tbl(l_count).attribute_name := l_object_out_rec.attribute_name;
				l_object_tbl(l_count).attribute_type := l_object_out_rec.attribute_type;
				l_object_tbl(l_count).attribute_value := l_object_out_rec.attribute_value;
				l_object_tbl(l_count).active_flag := l_object_out_rec.active_flag;
				l_object_tbl(l_count).priority := l_object_out_rec.priority;
				l_count := l_count + 1;
			end if;
 		end loop;
		close C_get_child_pnoi;

	elsif (((p_profile_name IS NOT NULL) AND
		(p_profile_name <> FND_API.G_MISS_CHAR) )AND
		((p_object_name IS NOT NULL) AND
		(p_object_name <> FND_API.G_MISS_CHAR))) then
		l_count := 1;

		open C_get_child_pnon (l_profile_name, p_application_id,
					l_object_name,l_active_flag);
 		loop

			fetch C_get_child_pnon
			into l_value_id,
				l_object_out_rec.parent_id,
				l_object_out_rec.object_id,
				l_object_out_rec.application_id,
				l_object_out_rec.object_name,
				l_object_out_rec.object_description,
				l_object_out_rec.object_type_id,
				l_object_out_rec.object_type,
				l_object_out_rec.attribute_id,
				l_object_out_rec.attribute_name,
				l_object_out_rec.attribute_type,
				l_object_out_rec.attribute_value,
				l_object_out_rec.active_flag,
				l_object_out_rec.priority;
			exit when C_get_child_pnon%NOTFOUND;
			if ( C_get_child_pnon%FOUND = TRUE) then
				l_object_tbl(l_count).parent_id := l_object_out_rec.parent_id;
				l_object_tbl(l_count).object_id := l_object_out_rec.object_id;
				l_object_tbl(l_count).application_id := l_object_out_rec.application_id;
				l_object_tbl(l_count).object_name := l_object_out_rec.object_name;
				l_object_tbl(l_count).object_description := l_object_out_rec.object_description;
				l_object_tbl(l_count).object_type_id := l_object_out_rec.object_type_id;
				l_object_tbl(l_count).object_type := l_object_out_rec.object_type;
				l_object_tbl(l_count).attribute_id := l_object_out_rec.attribute_id;
				l_object_tbl(l_count).attribute_name := l_object_out_rec.attribute_name;
				l_object_tbl(l_count).attribute_type := l_object_out_rec.attribute_type;
				l_object_tbl(l_count).attribute_value := l_object_out_rec.attribute_value;
				l_object_tbl(l_count).active_flag := l_object_out_rec.active_flag;
				l_object_tbl(l_count).priority := l_object_out_rec.priority;
				l_count := l_count + 1;
			end if;
 		end loop;
		close C_get_child_pnon;

	elsif (((p_profile_id IS NOT NULL) AND
		(p_profile_id <> FND_API.G_MISS_NUM) )AND
		((p_object_name IS NOT NULL) AND
		(p_object_name <> FND_API.G_MISS_CHAR))) then
		l_count := 1;

		open C_get_child_pion (l_profile_id, p_application_id,
					l_object_name,l_active_flag);
 		loop

			fetch C_get_child_pion
			into l_value_id,
				l_object_out_rec.parent_id,
				l_object_out_rec.object_id,
				l_object_out_rec.application_id,
				l_object_out_rec.object_name,
				l_object_out_rec.object_description,
				l_object_out_rec.object_type_id,
				l_object_out_rec.object_type,
				l_object_out_rec.attribute_id,
				l_object_out_rec.attribute_name,
				l_object_out_rec.attribute_type,
				l_object_out_rec.attribute_value,
				l_object_out_rec.active_flag,
				l_object_out_rec.priority;
			exit when C_get_child_pion%NOTFOUND;
			if ( C_get_child_pion%FOUND = TRUE) then
				l_object_tbl(l_count).parent_id := l_object_out_rec.parent_id;
				l_object_tbl(l_count).object_id := l_object_out_rec.object_id;
				l_object_tbl(l_count).application_id := l_object_out_rec.application_id;
				l_object_tbl(l_count).object_name := l_object_out_rec.object_name;
				l_object_tbl(l_count).object_description := l_object_out_rec.object_description;
				l_object_tbl(l_count).object_type_id := l_object_out_rec.object_type_id;
				l_object_tbl(l_count).object_type := l_object_out_rec.object_type;
				l_object_tbl(l_count).attribute_id := l_object_out_rec.attribute_id;
				l_object_tbl(l_count).attribute_name := l_object_out_rec.attribute_name;
				l_object_tbl(l_count).attribute_type := l_object_out_rec.attribute_type;
				l_object_tbl(l_count).attribute_value := l_object_out_rec.attribute_value;
				l_object_tbl(l_count).active_flag := l_object_out_rec.active_flag;
				l_object_tbl(l_count).priority := l_object_out_rec.priority;
				l_count := l_count + 1;
			end if;
 		end loop;
		close C_get_child_pion;

	else
		RAISE FND_API.G_EXC_ERROR;
	end if;


  else   /* Do Not get children case */

	if (((p_profile_id IS NOT NULL) AND
		(p_profile_id <> FND_API.G_MISS_NUM)) AND
		((p_object_id IS NOT NULL) AND
		(p_object_id <> FND_API.G_MISS_NUM))) then
		l_count := 1;

		open C_get_no_child_pioi (l_profile_id, p_application_id,
					l_object_id,l_active_flag);
 		loop

			fetch C_get_no_child_pioi
			into l_value_id,
				l_object_out_rec.parent_id,
				l_object_out_rec.object_id,
				l_object_out_rec.application_id,
				l_object_out_rec.object_name,
				l_object_out_rec.object_description,
				l_object_out_rec.object_type_id,
				l_object_out_rec.object_type,
				l_object_out_rec.attribute_id,
				l_object_out_rec.attribute_name,
				l_object_out_rec.attribute_type,
				l_object_out_rec.attribute_value,
				l_object_out_rec.active_flag,
				l_object_out_rec.priority;
			exit when C_get_no_child_pioi%NOTFOUND;
			if ( C_get_no_child_pioi%FOUND = TRUE) then
				l_object_tbl(l_count).parent_id := l_object_out_rec.parent_id;
				l_object_tbl(l_count).object_id := l_object_out_rec.object_id;
				l_object_tbl(l_count).application_id := l_object_out_rec.application_id;
				l_object_tbl(l_count).object_name := l_object_out_rec.object_name;
				l_object_tbl(l_count).object_description := l_object_out_rec.object_description;
				l_object_tbl(l_count).object_type_id := l_object_out_rec.object_type_id;
				l_object_tbl(l_count).object_type := l_object_out_rec.object_type;
				l_object_tbl(l_count).attribute_id := l_object_out_rec.attribute_id;
				l_object_tbl(l_count).attribute_name := l_object_out_rec.attribute_name;
				l_object_tbl(l_count).attribute_type := l_object_out_rec.attribute_type;
				l_object_tbl(l_count).attribute_value := l_object_out_rec.attribute_value;
				l_object_tbl(l_count).active_flag := l_object_out_rec.active_flag;
				l_object_tbl(l_count).priority := l_object_out_rec.priority;
				l_count := l_count + 1;
			end if;
 		end loop;
		close C_get_no_child_pioi;

	elsif (((p_profile_name IS NOT NULL) AND
		(p_profile_name <> FND_API.G_MISS_CHAR) )AND
		((p_object_id IS NOT NULL) AND
		(p_object_id <> FND_API.G_MISS_NUM))) then
		l_count := 1;

		open C_get_no_child_pnoi (l_profile_name, p_application_id,
					l_object_id,l_active_flag);
 		loop

			fetch C_get_no_child_pnoi
			into l_value_id,
				l_object_out_rec.parent_id,
				l_object_out_rec.object_id,
				l_object_out_rec.application_id,
				l_object_out_rec.object_name,
				l_object_out_rec.object_description,
				l_object_out_rec.object_type_id,
				l_object_out_rec.object_type,
				l_object_out_rec.attribute_id,
				l_object_out_rec.attribute_name,
				l_object_out_rec.attribute_type,
				l_object_out_rec.attribute_value,
				l_object_out_rec.active_flag,
				l_object_out_rec.priority;
			exit when C_get_no_child_pnoi%NOTFOUND;
			if ( C_get_no_child_pnoi%FOUND = TRUE) then
				l_object_tbl(l_count).parent_id := l_object_out_rec.parent_id;
				l_object_tbl(l_count).object_id := l_object_out_rec.object_id;
				l_object_tbl(l_count).application_id := l_object_out_rec.application_id;
				l_object_tbl(l_count).object_name := l_object_out_rec.object_name;
				l_object_tbl(l_count).object_description := l_object_out_rec.object_description;
				l_object_tbl(l_count).object_type_id := l_object_out_rec.object_type_id;
				l_object_tbl(l_count).object_type := l_object_out_rec.object_type;
				l_object_tbl(l_count).attribute_id := l_object_out_rec.attribute_id;
				l_object_tbl(l_count).attribute_name := l_object_out_rec.attribute_name;
				l_object_tbl(l_count).attribute_type := l_object_out_rec.attribute_type;
				l_object_tbl(l_count).attribute_value := l_object_out_rec.attribute_value;
				l_object_tbl(l_count).active_flag := l_object_out_rec.active_flag;
				l_object_tbl(l_count).priority := l_object_out_rec.priority;
				l_count := l_count + 1;
			end if;
 		end loop;
		close C_get_no_child_pnoi;

	elsif (((p_profile_name IS NOT NULL) AND
		(p_profile_name <> FND_API.G_MISS_CHAR) )AND
		((p_object_name IS NOT NULL) AND
		(p_object_name <> FND_API.G_MISS_CHAR))) then
		l_count := 1;

		open C_get_no_child_pnon (l_profile_name, p_application_id,
					l_object_name,l_active_flag);
 		loop

			fetch C_get_no_child_pnon
			into l_value_id,
				l_object_out_rec.parent_id,
				l_object_out_rec.object_id,
				l_object_out_rec.application_id,
				l_object_out_rec.object_name,
				l_object_out_rec.object_description,
				l_object_out_rec.object_type_id,
				l_object_out_rec.object_type,
				l_object_out_rec.attribute_id,
				l_object_out_rec.attribute_name,
				l_object_out_rec.attribute_type,
				l_object_out_rec.attribute_value,
				l_object_out_rec.active_flag,
				l_object_out_rec.priority;
			exit when C_get_no_child_pnon%NOTFOUND;
			if ( C_get_no_child_pnon%FOUND = TRUE) then
				l_object_tbl(l_count).parent_id := l_object_out_rec.parent_id;
				l_object_tbl(l_count).object_id := l_object_out_rec.object_id;
				l_object_tbl(l_count).application_id := l_object_out_rec.application_id;
				l_object_tbl(l_count).object_name := l_object_out_rec.object_name;
				l_object_tbl(l_count).object_description := l_object_out_rec.object_description;
				l_object_tbl(l_count).object_type_id := l_object_out_rec.object_type_id;
				l_object_tbl(l_count).object_type := l_object_out_rec.object_type;
				l_object_tbl(l_count).attribute_id := l_object_out_rec.attribute_id;
				l_object_tbl(l_count).attribute_name := l_object_out_rec.attribute_name;
				l_object_tbl(l_count).attribute_type := l_object_out_rec.attribute_type;
				l_object_tbl(l_count).attribute_value := l_object_out_rec.attribute_value;
				l_object_tbl(l_count).active_flag := l_object_out_rec.active_flag;
				l_object_tbl(l_count).priority := l_object_out_rec.priority;
				l_count := l_count + 1;
			end if;
 		end loop;
		close C_get_no_child_pnon;

	elsif (((p_profile_id IS NOT NULL) AND
		(p_profile_id <> FND_API.G_MISS_NUM) )AND
		((p_object_name IS NOT NULL) AND
		(p_object_name <> FND_API.G_MISS_CHAR))) then
		l_count := 1;

		open C_get_no_child_pion (l_profile_id, p_application_id,
					l_object_name,l_active_flag);
 		loop

			fetch C_get_no_child_pion
			into l_value_id,
				l_object_out_rec.parent_id,
				l_object_out_rec.object_id,
				l_object_out_rec.application_id,
				l_object_out_rec.object_name,
				l_object_out_rec.object_description,
				l_object_out_rec.object_type_id,
				l_object_out_rec.object_type,
				l_object_out_rec.attribute_id,
				l_object_out_rec.attribute_name,
				l_object_out_rec.attribute_type,
				l_object_out_rec.attribute_value,
				l_object_out_rec.active_flag,
				l_object_out_rec.priority;
			exit when C_get_no_child_pion%NOTFOUND;
			if ( C_get_no_child_pion%FOUND = TRUE) then
				l_object_tbl(l_count).parent_id := l_object_out_rec.parent_id;
				l_object_tbl(l_count).object_id := l_object_out_rec.object_id;
				l_object_tbl(l_count).application_id := l_object_out_rec.application_id;
				l_object_tbl(l_count).object_name := l_object_out_rec.object_name;
				l_object_tbl(l_count).object_description := l_object_out_rec.object_description;
				l_object_tbl(l_count).object_type_id := l_object_out_rec.object_type_id;
				l_object_tbl(l_count).object_type := l_object_out_rec.object_type;
				l_object_tbl(l_count).attribute_id := l_object_out_rec.attribute_id;
				l_object_tbl(l_count).attribute_name := l_object_out_rec.attribute_name;
				l_object_tbl(l_count).attribute_type := l_object_out_rec.attribute_type;
				l_object_tbl(l_count).attribute_value := l_object_out_rec.attribute_value;
				l_object_tbl(l_count).active_flag := l_object_out_rec.active_flag;
				l_object_tbl(l_count).priority := l_object_out_rec.priority;
				l_count := l_count + 1;
			end if;
 		end loop;
		close C_get_no_child_pion;

	else
		RAISE FND_API.G_EXC_ERROR;
	end if;


/*	If we have to raise an error if there are no records in the value table,
	then uncomment the following three lines - Srikanth
	if(l_object_tbl.count = 0) then
          	RAISE FND_API.G_EXC_ERROR;
	end if;

*/
  end if;

	x_object_tbl := l_object_tbl;


 EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

END Get_lf_object;

-- *****************************************************************************
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: Get_lf_object_type
--	Type		: Public
--	Function	: Get attribute pairs for a given LF object_type
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN 	NUMBER		Required
--		p_init_msg_list		IN 	VARCHAR2 		Optional
--						Default = FND_API.G_FALSE
--
--		p_object_type		IN 	VARCHAR2	Optional
--		p_object_type_desc	IN 	VARCHAR2	Optional
--		p_object_type_id	IN 	NUMBER	Optional
--

-- OUT  :
--		x_object_type_id OUT  	NUMBER
--		x_object_type_desc OUT  	VARCHAR,
--		x_attrib_rec_tbl OUT  JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE
--		x_return_status	 OUT  VARCHAR2(1)
--		x_msg_count	 OUT  NUMBER
--		x_msg_data	 OUT  VARCHAR2(2000)
--
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes:
--
-- *****************************************************************************

PROCEDURE Get_lf_object_type
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,

	p_Object_type		IN	VARCHAR,
	p_Object_type_Id	IN 	NUMBER,

	x_Object_type_Id OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_object_type_desc OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2,

	x_attrib_rec_tbl OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

	l_api_version_number	NUMBER 	:= p_api_version_number;
 	l_api_name		CONSTANT VARCHAR2(30) := 'GET_LF_OBJECT_TYPE';
	l_return_status    	VARCHAR2(240) 	:= FND_API.G_RET_STS_SUCCESS;
	l_attrib_rec_tbl	JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE;
	l_Object_type_Id	NUMBER := p_Object_type_Id;
	l_Object_type		VARCHAR2(60) := p_Object_type;
	l_object_type_desc	VARCHAR2(240) := NULL;

BEGIN

-- ******* Execution Plan Get_lf_object_type ********
--1.Call get_obj_type_details()
-- 2. return the output returned by the above function
-- 	along with appropriate return status.
--

-- ******* Standard Begins Get_lf_object_type********

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call
	( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
END IF;

-- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- ******* Get_lf_object_type implementation ********

-- Calling the get_obj_type_details
-- dbms_output.put_line('out 1');
l_return_status := FND_API.G_TRUE;

get_obj_type_details
(
	l_Object_type,
	l_Object_type_Id,
	l_object_type_desc,
	l_attrib_rec_tbl,
	l_return_status
);

-- dbms_output.put_line('out 2');

if (l_return_status = FND_API.G_FALSE) then
-- dbms_output.put_line('out 3');
	  x_return_status := FND_API.G_RET_STS_ERROR ;
else
--dbms_output.put_line('out 4');
	x_Object_type_Id   := l_Object_type_Id;
--dbms_output.put_line('l_Object_type_Id:'||l_Object_type_Id);
	x_object_type_desc := l_object_type_desc;
	x_attrib_rec_tbl   := l_attrib_rec_tbl;
end if;

END Get_lf_object_type;
-- *****************************************************************************
-- *****************************************************************************
-- Start of Comments
--
--	API name 	: save_lf_object_type
--	Type		: Public
--	Function	: This procedure will create or update the given lf
--				object type.
--
--	Paramaeters	:
--	IN	:
--		p_api_version_number	IN NUMBER	Required
--		p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--		p_commit		IN VARCHAR2	Optional

--		p_object_type_id	IN NUMBER	Optional
--		p_object_type		IN VARCHAR2	Optional
--		p_object_type_desc	IN VARCHAR2	Optional

--		p_attribute_rec_tbl	IN JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE Required
--
-- OUT  :
--		x_object_type_id OUT  NUMBER
--		x_obj_type_map_tbl OUT  JTF_PERZ_LF_PUB.OBJ_TYPE_MAP_TBL_TYPE
--		x_return_status	 OUT VARCHAR2
--		x_msg_count	 OUT  NUMBER
--		x_msg_data	 OUT VARCHAR2(2000)
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes:
--
-- *****************************************************************************

PROCEDURE save_lf_object_type
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_object_type_id        IN 	NUMBER,
	p_object_type           IN 	VARCHAR2,
	p_object_type_desc	IN 	VARCHAR2,

	p_attrib_rec_tbl	IN	JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE
				:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_REC_TBL,

	x_object_type_id OUT NOCOPY /* file.sql.39 change */ NUMBER,

	x_obj_type_map_tbl OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_LF_PVT.OBJ_TYPE_MAP_TBL_TYPE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

       -- ******* Local Variables ********
-- Following variables are needed to adhere to standards
	l_api_version_number	NUMBER 	:= p_api_version_number;
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'Save Object Type';

-- Following variables are needed to implement this procedure
	l_return_status    	VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;
	l_rowid			ROWID	:= NULL;
	l_OBJECT_TYPE_ID	NUMBER	:= p_object_type_id;
	l_OBJECT_TYPE		VARCHAR2(60)	:= p_object_type;
	l_OBJECT_TYPE_DESC	VARCHAR2(240)	:= p_object_type_desc;
	l_attrib_rec_tbl	JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE
				:= p_attrib_rec_tbl;
	l_count		     	NUMBER  := p_attrib_rec_tbl.count;
     	l_curr_row		NUMBER	:= NULL;
	l_inserted_map          NUMBER  := 0;
	l_map_id		NUMBER := NULL;
     	l_attribute_id		NUMBER := NULL;

	l_obj_type_version_no   NUMBER :=	NULL;
BEGIN

       -- ******* Execution Plan ********
-- save_lf_object_type execution steps

--Check for duplicate object_type  by calling check_duplicate_obj_type()
-- If the object type exists, loop through each attribute supplied
-- 	compare the supplied attribute and that of the attribute associated
-- 	with the object type in DB.
-- 	For each attribute that is not in the DB, insert the attribute and
-- 	object type - attribute map.
-- If the object does not exist
-- 	Create the object
--	loop through each attribute supplied
--		If the attribute exists in the attribute store already then
--			create the object type - attribute map
--		else
--			create the attribute that is not present in the DB
--			create the object type - attribute map

       -- ******* Standard Begins ********

-- Standard Start of API savepoint
SAVEPOINT	SAVE_PERZ_LF_TYPE_PVT;

-- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
END IF;

-- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS ;

       -- ******* save_lf_object_type implementation ********

-- Check if object type exists

l_return_status := FND_API.G_TRUE;
 check_duplicate_obj_type (
	l_object_type	,
	l_return_status	,
	l_object_type_id,
	l_obj_type_version_no
);


if (l_return_status = FND_API.G_TRUE) then
-- Object Type already exists.
-- Update the Object Type Description
-- Loop through each attribute supplied
-- 	compare the supplied attribute and that of the attribute associated
-- 	with the object type in DB.
-- 	For each attribute that is not associated with the type in the database,
--		Check if the attribute is in the DB
--			If not insert the attribute and create the
--				object type - attribute map
-- 			If yes i.e., attribute exists in the DB, create the
--				object type - attribute map.

-- Copying the object type id to output parameter
   x_object_type_id := l_object_type_id;


-- Update the object
   l_rowid := NULL;
   update_jtf_perz_lf_obj_type(
	l_object_type_desc,
	l_object_type_id,
	l_rowid,
	l_obj_type_version_no
   );

   if (l_rowid is null) then
	RAISE FND_API.G_EXC_ERROR;
   end if;
   IF (l_count> 0) THEN
      FOR l_curr_row in 1..l_count LOOP
	-- Check if the attribute is there in the DB or not
	l_rowid := NULL;
  	l_return_status := FND_API.G_TRUE;
	l_attribute_id := NULL;
	--dbms_output.put_line('attribute name '||l_attrib_value_tbl(l_curr_row).attribute_name);
	--dbms_output.put_line('attribute type '||l_attrib_value_tbl(l_curr_row).attribute_type);
	check_attribute(
		p_attrib_rec_tbl(l_curr_row).ATTRIBUTE_NAME,
		p_attrib_rec_tbl(l_curr_row).ATTRIBUTE_TYPE,
		l_rowid,
		l_attribute_id,
		l_return_status
	);
   	if (l_return_status = FND_API.G_FALSE) then
		--dbms_output.put_line('out 4');
		-- If the attribute is not there in the DB
		--	Create the attribute

		l_rowid := NULL;
		l_attribute_id := NULL;
		insert_jtf_perz_lf_attrib(
			l_rowid,
			l_attribute_id,
                  	l_attrib_rec_tbl(l_curr_row).attribute_name,
                  	l_attrib_rec_tbl(l_curr_row).attribute_type
		);
		if (l_rowid is null) then
			-- unable to insert the attribute record
			RAISE FND_API.G_EXC_ERROR;
		end if;
	end if;

	-- Now, we know we have an attribute in the DB.
	-- inserting record in x_obj_type_map_tbl for output
	x_obj_type_map_tbl(l_inserted_map).ATTRIBUTE_ID := l_attribute_id;
	x_obj_type_map_tbl(l_inserted_map).OBJECT_TYPE_ID := l_object_type_id;


	-- For a given object type Check if the attribute map exists or not

	BEGIN
		select obj_type_map_id into x_obj_type_map_tbl(l_inserted_map).TYPE_MAP_ID
		from jtf_perz_obj_type_map
		where object_type_id = l_object_type_id
		and   attribute_id = l_attribute_id;
		l_inserted_map := l_inserted_map + 1;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		-- There is no map for the given object type and attribute
		-- Create the map
		l_map_id := null;
		l_rowid := NULL;
		insert_jtf_perz_obj_type_map(
			l_rowid,
			l_map_id,
			l_object_type_id,
			l_attribute_id
		);
		if (l_rowid is null) then
			-- raising the error if unable to insert the map record
			RAISE FND_API.G_EXC_ERROR;
		else
			-- inserting record in x_obj_type_map_tbl for output
			x_obj_type_map_tbl(l_inserted_map).TYPE_MAP_ID := l_map_id;
			l_inserted_map := l_inserted_map + 1;
		end if;
	END;

     END LOOP;

   end if;

else

-- Object Type does not exists.

-- Create the object type
-- dbms_output.put_line('l_object_type_id '||l_object_type_id);
-- dbms_output.put_line('l_object_type '||l_OBJECT_TYPE);
-- dbms_output.put_line('l_object_type_desc '||l_OBJECT_TYPE_desc);

   if ((l_OBJECT_TYPE is not null) and
	(l_OBJECT_TYPE <> FND_API.G_MISS_CHAR)) then
   	Insert_JTF_PERZ_LF_OBJ_TYPE(
		l_Rowid,
		l_OBJECT_TYPE_ID,
		l_OBJECT_TYPE,
		l_OBJECT_TYPE_DESC
   	);
  else
	RAISE FND_API.G_EXC_ERROR;
  end if;


   if (l_rowid is null) then
	RAISE FND_API.G_EXC_ERROR;
   else
	x_OBJECT_TYPE_ID := l_OBJECT_TYPE_ID;
   end if;
--	loop through each attribute supplied
--		If the attribute exists in the attribute store already then
--			create the object type - attribute map
--		else
--			create the attribute that is not present in the DB
--			create the object type - attribute map

-- Copying the object type id to output parameter
	x_object_type_id := l_object_type_id;

   IF (l_count> 0) THEN

    FOR l_curr_row in 1..l_count LOOP
	BEGIN
		SELECT attribute_id INTO l_attribute_id
		FROM JTF_PERZ_LF_ATTRIB
		WHERE attribute_name = p_attrib_rec_tbl(l_curr_row).ATTRIBUTE_NAME and
		attribute_type = p_attrib_rec_tbl(l_curr_row).ATTRIBUTE_TYPE;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		-- insert row into the attribute  table
			l_rowid := NULL;
			l_attribute_id := NULL;
			insert_jtf_perz_lf_attrib(
				l_rowid,
				l_attribute_id,
                  		l_attrib_rec_tbl(l_curr_row).attribute_name,
                  		l_attrib_rec_tbl(l_curr_row).attribute_type
			);
			if (l_rowid is null) then
				-- raising the error if unable to insert the attribute record
				   RAISE FND_API.G_EXC_ERROR;
			end if;
	END;
	-- create a map entry object_type - attribute in
	-- 	jtf_perz_obj_type_map table
	l_map_id := null;
	l_rowid := NULL;
	insert_jtf_perz_obj_type_map(
		l_rowid,
		l_map_id,
		l_object_type_id,
		l_attribute_id
	);
	if (l_rowid is null) then
	-- raising the error if unable to insert the map record
		RAISE FND_API.G_EXC_ERROR;
	else
	-- inserting record in x_obj_type_map_tbl for output
		x_obj_type_map_tbl(l_inserted_map).ATTRIBUTE_ID := l_attribute_id;
		x_obj_type_map_tbl(l_inserted_map).OBJECT_TYPE_ID := l_object_type_id;
		x_obj_type_map_tbl(l_inserted_map).TYPE_MAP_ID := l_map_id;
		l_inserted_map := l_inserted_map + 1;
	end if;
     END LOOP;

   end if;
end if;

	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --
--	7.	Commit the whole thing

      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
	( 	p_count	=>      x_msg_count,
       		p_data	=>      x_msg_data
	);


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO SAVE_PERZ_LF_TYPE_PVT;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count	=>      x_msg_count,
        	  p_data	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO SAVE_PERZ_LF_TYPE_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count	=>      x_msg_count,
        	  p_data	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

      WHEN OTHERS THEN

	  ROLLBACK TO SAVE_PERZ_LF_TYPE_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count	=>      x_msg_count,
        	  p_data	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

END save_lf_object_type;
-- *****************************************************************************
-- *****************************************************************************

END  JTF_PERZ_LF_PVT ;

/
