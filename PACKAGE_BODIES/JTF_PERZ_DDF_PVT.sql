--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_DDF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_DDF_PVT" as
/* $Header: jtfzvddb.pls 120.2 2005/11/02 22:19:41 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
--   jtf_perz_ddf_pvt
--
-- PURPOSE
--   Public API for creating, getting, updating and deleteing data defaults
-- 	 in the Personalization Framework.
--
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for creating, getting, updating and deleting personalized data defaults
-- 	 in the Personalization Framework.
--
-- HISTORY
--	09/10/99	SMATTEGU	Created and documented the following
--					save_data_default()
--					create_data_default()
--					update_data_default()
--					delete_data_default()
--	09/30/99	SMATTEGU	changed the save() to reflect profile_id fix
--	11/04/99	SMATTEGU	Modifying the code to take into account
--					the who columns
--					Fixing an extra empty record problem
--					in get() BUG#1063736
--
-- End of Comments

--

G_PKG_NAME  	CONSTANT VARCHAR2(30):='JTF_PERZ_DDF_PVT';
G_FILE_NAME   	CONSTANT VARCHAR2(12):='jtfzvddb.pls';


-- ****************************************************************************
-- TABLE HANDLERS
--
--	The following are the table handlers
--
--	1. insert_jtf_perz_data_default
--	2. update_jtf_perz_data_default
--	3. delete_jtf_perz_data_default
-- ****************************************************************************
-- ****************************************************************************
PROCEDURE insert_jtf_perz_data_default(
	x_PERZ_DDF_ID IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
        p_PROFILE_ID		IN	NUMBER,
        p_APPLICATION_ID	IN	NUMBER,
        p_PERZ_DDF_CONTEXT	IN	VARCHAR2,
        p_GUI_OBJECT_NAME	IN	VARCHAR2,
        p_GUI_OBJECT_ID	IN	NUMBER,
        p_DDF_VALUE		IN	VARCHAR2,
        p_DDF_VALUE_TYPE	IN	VARCHAR2,
	p_OBJECT_VERSION_NUMBER IN	NUMBER
) IS
   CURSOR C2 IS SELECT JTF_PERZ_DATA_DEFAULT_S.nextval FROM sys.dual;
BEGIN
   If (x_PERZ_DDF_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_PERZ_DDF_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_PERZ_DATA_DEFAULT(
           PERZ_DATA_DEFAULT_ID,
           PROFILE_ID,
           APPLICATION_ID,
           PERZ_DDF_CONTEXT,
           GUI_OBJECT_NAME,
           GUI_OBJECT_ID,
           PERZ_DDF_VALUE,
           PERZ_DDF_VALUE_TYPE,
	   OBJECT_VERSION_NUMBER,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN
          ) VALUES (
           x_PERZ_DDF_ID,
           decode( p_PROFILE_ID, FND_API.G_MISS_NUM, NULL, p_PROFILE_ID),
           decode( p_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_APPLICATION_ID),
           decode( p_PERZ_DDF_CONTEXT, FND_API.G_MISS_CHAR, NULL, p_PERZ_DDF_CONTEXT),
           decode( p_GUI_OBJECT_NAME, FND_API.G_MISS_CHAR, NULL, p_GUI_OBJECT_NAME),
           decode( p_GUI_OBJECT_ID, FND_API.G_MISS_NUM, NULL, p_GUI_OBJECT_ID),
           decode( p_DDF_VALUE, FND_API.G_MISS_CHAR, NULL, p_DDF_VALUE),
           decode( p_DDF_VALUE_TYPE, FND_API.G_MISS_CHAR, NULL, p_DDF_VALUE_TYPE),
	   decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, 1, p_OBJECT_VERSION_NUMBER),
	   FND_GLOBAL.USER_ID, SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID
	);
End insert_jtf_perz_data_default;
-- ****************************************************************************

PROCEDURE update_jtf_perz_data_default(
          x_PERZ_DDF_ID	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
          p_PROFILE_ID		IN	NUMBER,
          p_APPLICATION_ID	IN	NUMBER,
          p_PERZ_DDF_CONTEXT	IN	VARCHAR2,
          p_GUI_OBJECT_NAME	IN	VARCHAR2,
          p_GUI_OBJECT_ID	IN	NUMBER,
          p_DDF_VALUE		IN	VARCHAR2,
          p_DDF_VALUE_TYPE	IN	VARCHAR2,
	p_OBJECT_VERSION_NUMBER IN	NUMBER
) IS

l_object_version_number NUMBER := p_OBJECT_VERSION_NUMBER;
BEGIN
    Update JTF_PERZ_DATA_DEFAULT
    SET
--	PROFILE_ID = decode( p_PROFILE_ID, FND_API.G_MISS_NUM, PROFILE_ID, p_PROFILE_ID),
--	APPLICATION_ID = decode( p_APPLICATION_ID, FND_API.G_MISS_NUM, APPLICATION_ID, p_APPLICATION_ID),
--	PERZ_DDF_CONTEXT = decode( p_PERZ_DDF_CONTEXT, FND_API.G_MISS_CHAR, PERZ_DDF_CONTEXT, p_PERZ_DDF_CONTEXT),
--	GUI_OBJECT_NAME = decode( p_GUI_OBJECT_NAME, FND_API.G_MISS_CHAR, GUI_OBJECT_NAME, p_GUI_OBJECT_NAME),
--	GUI_OBJECT_ID = decode( p_GUI_OBJECT_ID, FND_API.G_MISS_NUM, GUI_OBJECT_ID, p_GUI_OBJECT_ID),
	PERZ_DDF_VALUE = decode( p_DDF_VALUE, FND_API.G_MISS_CHAR, PERZ_DDF_VALUE, p_DDF_VALUE),
	PERZ_DDF_VALUE_TYPE = decode( p_DDF_VALUE_TYPE, FND_API.G_MISS_CHAR, PERZ_DDF_VALUE_TYPE, p_DDF_VALUE_TYPE),
	OBJECT_VERSION_NUMBER = decode (p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,
					OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER+1),
	LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATED_BY  = FND_GLOBAL.USER_ID,
	LAST_UPDATE_LOGIN = FND_GLOBAL.CONC_LOGIN_ID
    where PERZ_DATA_DEFAULT_ID = x_PERZ_DDF_ID
	and OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END update_jtf_perz_data_default;
-- ****************************************************************************

PROCEDURE delete_jtf_perz_data_default(
    p_PERZ_DDF_ID  IN NUMBER)
 IS
 BEGIN
   DELETE FROM JTF_PERZ_DATA_DEFAULT
    WHERE PERZ_DATA_DEFAULT_ID = p_PERZ_DDF_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END delete_jtf_perz_data_default;

-- ***************************************************************************
-- ***************************************************************************
--
--Private  APIs
-- Check_ddf()
--  get_ddf(


-- ***************************************************************************
-- ***************************************************************************

PROCEDURE Get_ddf(
	x_PERZ_DDF_ID	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	p_PROFILE_ID		IN	NUMBER,
	p_APPLICATION_ID	IN	NUMBER,
	p_PERZ_DDF_CONTEXT	IN	VARCHAR2,
	p_GUI_OBJECT_NAME	IN	VARCHAR2,
	p_GUI_OBJECT_ID		IN	NUMBER,
	p_ddf_value		IN	VARCHAR2,
	p_ddf_value_type	IN	VARCHAR2,
	x_ddf_out_tbl	 OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_DDF_PUB.DDF_OUT_TBL_TYPE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

l_count NUMBER := NULL;
l_ddf_out_rec_temp JTF_PERZ_DDF_PUB.DDF_OUT_REC_TYPE := NULL;

cursor c_get_ddf_paoc (p_profile_id NUMBER, p_application_id NUMBER,
 		p_gui_object_id NUMBER, p_perz_ddf_context VARCHAR2) is
	select perz_data_default_id, perz_ddf_context,
		profile_id, application_id, gui_object_name,
		gui_object_id, PERZ_ddf_value, PERZ_ddf_value_type
	from JTF_PERZ_DATA_DEFAULT
	where
		PROFILE_ID = p_PROFILE_ID
	and	APPLICATION_ID = p_APPLICATION_ID
	and	GUI_OBJECT_ID = p_GUI_OBJECT_ID
	and	PERZ_DDF_CONTEXT = p_PERZ_DDF_CONTEXT;

cursor c_get_ddf_pao (p_profile_id NUMBER, p_application_id NUMBER,
 		p_gui_object_id NUMBER) is
	select perz_data_default_id, perz_ddf_context,
		profile_id, application_id, gui_object_name,
		gui_object_id, PERZ_ddf_value, PERZ_ddf_value_type
	from JTF_PERZ_DATA_DEFAULT
	where
		PROFILE_ID = p_PROFILE_ID
	and	APPLICATION_ID = p_APPLICATION_ID
	and	GUI_OBJECT_ID = p_GUI_OBJECT_ID;

cursor c_get_ddf_panc (p_profile_id NUMBER, p_application_id NUMBER,
 		p_gui_object_name VARCHAR2, p_perz_ddf_context VARCHAR2) is
	select perz_data_default_id, perz_ddf_context,
		profile_id, application_id, gui_object_name,
		gui_object_id, PERZ_ddf_value, PERZ_ddf_value_type

	from JTF_PERZ_DATA_DEFAULT
	where
		PROFILE_ID = p_PROFILE_ID
	and	APPLICATION_ID = p_APPLICATION_ID
	and	GUI_OBJECT_NAME = p_GUI_OBJECT_NAME
	and	PERZ_DDF_CONTEXT = p_PERZ_DDF_CONTEXT;

cursor c_get_ddf_pan (p_profile_id NUMBER, p_application_id NUMBER,
		p_gui_object_name VARCHAR2) is
	select perz_data_default_id, perz_ddf_context,
		profile_id, application_id, gui_object_name,
		gui_object_id, PERZ_ddf_value, PERZ_ddf_value_type
	from JTF_PERZ_DATA_DEFAULT
	where
		PROFILE_ID = p_PROFILE_ID
	and	APPLICATION_ID = p_APPLICATION_ID
	and	GUI_OBJECT_NAME = p_GUI_OBJECT_NAME;

BEGIN

 if ((( p_PROFILE_ID is NOT NULL) AND
	 ( p_PROFILE_ID <> FND_API.G_MISS_NUM)) AND
	 ((p_APPLICATION_ID is NOT NULL) AND
	 ( p_APPLICATION_ID <> FND_API.G_MISS_NUM))) then

	if ((p_GUI_OBJECT_ID is NOT NULL) AND
	    (p_GUI_OBJECT_ID <>FND_API.G_MISS_NUM)) then
		if (((p_PERZ_DDF_CONTEXT is NOT NULL) AND
	 		(p_PERZ_DDF_CONTEXT <> FND_API.G_MISS_CHAR))) then

			l_ddf_out_rec_temp := NULL;
			l_count := 1;
			open c_get_ddf_paoc (p_profile_id , p_application_id ,
 				p_gui_object_id , p_perz_ddf_context ) ;
		   	LOOP
				FETCH c_get_ddf_paoc into
					l_ddf_out_rec_temp.perz_ddf_id,
					l_ddf_out_rec_temp.perz_ddf_context,
					l_ddf_out_rec_temp.profile_id,
					l_ddf_out_rec_temp.application_id,
					l_ddf_out_rec_temp.gui_object_name,
					l_ddf_out_rec_temp.gui_object_id,
					l_ddf_out_rec_temp.ddf_value,
					l_ddf_out_rec_temp.ddf_value_type;
				EXIT WHEN c_get_ddf_paoc%NOTFOUND;
				IF ( c_get_ddf_paoc%FOUND = TRUE ) THEN
					x_ddf_out_tbl(l_count).perz_ddf_id := l_ddf_out_rec_temp.perz_ddf_id;
					x_ddf_out_tbl(l_count).perz_ddf_context := l_ddf_out_rec_temp.perz_ddf_context;
					x_ddf_out_tbl(l_count).profile_id := l_ddf_out_rec_temp.profile_id;
					x_ddf_out_tbl(l_count).application_id := l_ddf_out_rec_temp.application_id;
					x_ddf_out_tbl(l_count).gui_object_name := l_ddf_out_rec_temp.gui_object_name;
					x_ddf_out_tbl(l_count).gui_object_id := l_ddf_out_rec_temp.gui_object_id;
					x_ddf_out_tbl(l_count).ddf_value := l_ddf_out_rec_temp.ddf_value;
					x_ddf_out_tbl(l_count).ddf_value_type := l_ddf_out_rec_temp.ddf_value_type;
					l_count := l_count +1;
				END IF;
		   	END LOOP;
			close c_get_ddf_paoc;
			x_return_status := FND_API.G_TRUE;
		else

			l_ddf_out_rec_temp := NULL;
			l_count := 1;
			open c_get_ddf_pao (p_profile_id, p_application_id,
 				p_gui_object_id ) ;
		   	LOOP
				FETCH c_get_ddf_pao into
					l_ddf_out_rec_temp.perz_ddf_id,
					l_ddf_out_rec_temp.perz_ddf_context,
					l_ddf_out_rec_temp.profile_id,
					l_ddf_out_rec_temp.application_id,
					l_ddf_out_rec_temp.gui_object_name,
					l_ddf_out_rec_temp.gui_object_id,
					l_ddf_out_rec_temp.ddf_value,
					l_ddf_out_rec_temp.ddf_value_type;
				EXIT WHEN c_get_ddf_pao%NOTFOUND;
				IF ( c_get_ddf_pao%FOUND = TRUE ) THEN
					x_ddf_out_tbl(l_count).perz_ddf_id := l_ddf_out_rec_temp.perz_ddf_id;
					x_ddf_out_tbl(l_count).perz_ddf_context := l_ddf_out_rec_temp.perz_ddf_context;
					x_ddf_out_tbl(l_count).profile_id := l_ddf_out_rec_temp.profile_id;
					x_ddf_out_tbl(l_count).application_id := l_ddf_out_rec_temp.application_id;
					x_ddf_out_tbl(l_count).gui_object_name := l_ddf_out_rec_temp.gui_object_name;
					x_ddf_out_tbl(l_count).gui_object_id := l_ddf_out_rec_temp.gui_object_id;
					x_ddf_out_tbl(l_count).ddf_value := l_ddf_out_rec_temp.ddf_value;
					x_ddf_out_tbl(l_count).ddf_value_type := l_ddf_out_rec_temp.ddf_value_type;
					l_count := l_count +1;
		   		END IF;
		   	END LOOP;
			close c_get_ddf_pao;
			x_return_status := FND_API.G_TRUE;
		end if;

	elsif ((p_GUI_OBJECT_NAME is NOT NULL) AND
	    (p_GUI_OBJECT_NAME <>FND_API.G_MISS_CHAR)) then
		if (((p_PERZ_DDF_CONTEXT is NOT NULL) AND
	 		(p_PERZ_DDF_CONTEXT <> FND_API.G_MISS_CHAR))) then
			l_count := 1;
			l_ddf_out_rec_temp := NULL;
			open c_get_ddf_panc (p_profile_id , p_application_id ,
				p_gui_object_name , p_perz_ddf_context ) ;
			LOOP
				fetch c_get_ddf_panc into
					l_ddf_out_rec_temp.perz_ddf_id,
					l_ddf_out_rec_temp.perz_ddf_context,
					l_ddf_out_rec_temp.profile_id,
					l_ddf_out_rec_temp.application_id,
					l_ddf_out_rec_temp.gui_object_name,
					l_ddf_out_rec_temp.gui_object_id,
					l_ddf_out_rec_temp.ddf_value,
					l_ddf_out_rec_temp.ddf_value_type;
				EXIT WHEN c_get_ddf_panc%NOTFOUND;
				IF ( c_get_ddf_panc%FOUND = TRUE ) THEN
					x_ddf_out_tbl(l_count).perz_ddf_id := l_ddf_out_rec_temp.perz_ddf_id;
					x_ddf_out_tbl(l_count).perz_ddf_context := l_ddf_out_rec_temp.perz_ddf_context;
					x_ddf_out_tbl(l_count).profile_id := l_ddf_out_rec_temp.profile_id;
					x_ddf_out_tbl(l_count).application_id := l_ddf_out_rec_temp.application_id;
					x_ddf_out_tbl(l_count).gui_object_name := l_ddf_out_rec_temp.gui_object_name;
					x_ddf_out_tbl(l_count).gui_object_id := l_ddf_out_rec_temp.gui_object_id;
					x_ddf_out_tbl(l_count).ddf_value := l_ddf_out_rec_temp.ddf_value;
					x_ddf_out_tbl(l_count).ddf_value_type := l_ddf_out_rec_temp.ddf_value_type;
					l_count := l_count +1;
				END IF;
			END LOOP;
			close c_get_ddf_panc ;
			x_return_status := FND_API.G_TRUE;
		else
			l_count := 1;
			open c_get_ddf_pan (p_profile_id ,
				p_application_id ,
				p_gui_object_name ) ;
			LOOP
				FETCH c_get_ddf_pan into
					l_ddf_out_rec_temp.perz_ddf_id,
					l_ddf_out_rec_temp.perz_ddf_context,
					l_ddf_out_rec_temp.profile_id,
					l_ddf_out_rec_temp.application_id,
					l_ddf_out_rec_temp.gui_object_name,
					l_ddf_out_rec_temp.gui_object_id,
					l_ddf_out_rec_temp.ddf_value,
					l_ddf_out_rec_temp.ddf_value_type;
				EXIT WHEN c_get_ddf_pan%NOTFOUND;
				IF ( c_get_ddf_pan%FOUND = TRUE ) THEN
					x_ddf_out_tbl(l_count).perz_ddf_id := l_ddf_out_rec_temp.perz_ddf_id;
					x_ddf_out_tbl(l_count).perz_ddf_context := l_ddf_out_rec_temp.perz_ddf_context;
					x_ddf_out_tbl(l_count).profile_id := l_ddf_out_rec_temp.profile_id;
					x_ddf_out_tbl(l_count).application_id := l_ddf_out_rec_temp.application_id;
					x_ddf_out_tbl(l_count).gui_object_name := l_ddf_out_rec_temp.gui_object_name;
					x_ddf_out_tbl(l_count).gui_object_id := l_ddf_out_rec_temp.gui_object_id;
					x_ddf_out_tbl(l_count).ddf_value := l_ddf_out_rec_temp.ddf_value;
					x_ddf_out_tbl(l_count).ddf_value_type := l_ddf_out_rec_temp.ddf_value_type;
					l_count := l_count +1;
		   		END IF;
		   	END LOOP;
			close c_get_ddf_pan;
			x_return_status := FND_API.G_TRUE;
		end if;
	else
		x_return_status := FND_API.G_FALSE;
	end if;
 else
	x_return_status := FND_API.G_FALSE;
 end if;


END Get_ddf;

-- ***************************************************************************

PROCEDURE  Check_ddf(
          x_PERZ_DDF_ID	 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
          p_PROFILE_ID		IN	NUMBER,
          p_APPLICATION_ID	IN	NUMBER,
          p_PERZ_DDF_CONTEXT	IN	VARCHAR2,
          p_GUI_OBJECT_NAME	IN	VARCHAR2,
          p_GUI_OBJECT_ID	IN	NUMBER,
	x_OBJECT_VERSION_NUMBER OUT NOCOPY /* file.sql.39 change */ NUMBER
) IS

l_perz_ddf_id NUMBER := NULL;

-- Usage Note:
--	If this procedure is supplied with arguments set which
--	cannot uniquely identify a DDF, then this procedre raises error
--	Hence, to correctly use this procedure supply any one of the
--	following combinations:
--
--	1: x_perz_ddf_id
--
--	2:
--	   p_PROFILE_ID
--	   p_APPLICATION_ID
--	   p_PERZ_DDF_CONTEXT
--	   p_GUI_OBJECT_NAME
--
--	3:
--	   p_PROFILE_ID
--	   p_APPLICATION_ID
--	   p_PERZ_DDF_CONTEXT
--	   p_GUI_OBJECT_ID
--

BEGIN

  if ((x_PERZ_DDF_ID is NOT NULL) AND
	(x_PERZ_DDF_ID <> FND_API.G_MISS_NUM)) then

	select PERZ_DATA_DEFAULT_ID, OBJECT_VERSION_NUMBER
	into l_perz_ddf_id, x_OBJECT_VERSION_NUMBER
	from JTF_PERZ_DATA_DEFAULT
	where PERZ_DATA_DEFAULT_ID = x_PERZ_DDF_ID;

	if (SQL%NOTFOUND) then
		RAISE NO_DATA_FOUND;
   	End If;

  elsif ((( p_PROFILE_ID is NOT NULL) AND
	 ( p_PROFILE_ID <> FND_API.G_MISS_NUM)) AND
	 ((p_APPLICATION_ID is NOT NULL) AND
	 ( p_APPLICATION_ID <> FND_API.G_MISS_NUM)) AND
	 ((p_PERZ_DDF_CONTEXT is NOT NULL) AND
	 ( p_PERZ_DDF_CONTEXT <> FND_API.G_MISS_CHAR))) then

	if ((p_GUI_OBJECT_ID is NOT NULL) AND
	    (p_GUI_OBJECT_ID <>FND_API.G_MISS_NUM)) then
	     BEGIN
		select  PERZ_DATA_DEFAULT_ID, OBJECT_VERSION_NUMBER
		into l_perz_ddf_id, x_OBJECT_VERSION_NUMBER
		from JTF_PERZ_DATA_DEFAULT
		where PROFILE_ID = p_PROFILE_ID
		and	APPLICATION_ID = p_APPLICATION_ID
		and	PERZ_DDF_CONTEXT = p_PERZ_DDF_CONTEXT
		and	GUI_OBJECT_ID = p_GUI_OBJECT_ID;

		x_PERZ_DDF_ID := l_perz_ddf_id;

	     EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_PERZ_DDF_ID := NULL;

		WHEN OTHERS THEN
			x_PERZ_DDF_ID := NULL;

   	     END;
	else
		if ((p_GUI_OBJECT_NAME is NOT NULL) AND
		    (p_GUI_OBJECT_NAME <> FND_API.G_MISS_CHAR)) THEN
		    BEGIN
			select  PERZ_DATA_DEFAULT_ID, OBJECT_VERSION_NUMBER
			into l_perz_ddf_id, x_OBJECT_VERSION_NUMBER
			from JTF_PERZ_DATA_DEFAULT
			where PROFILE_ID = p_PROFILE_ID
			and	APPLICATION_ID = p_APPLICATION_ID
			and	PERZ_DDF_CONTEXT = p_PERZ_DDF_CONTEXT
			and	GUI_OBJECT_NAME = p_GUI_OBJECT_NAME;

			x_PERZ_DDF_ID := l_perz_ddf_id;

	     	    EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_PERZ_DDF_ID := NULL;

			WHEN OTHERS THEN
				x_PERZ_DDF_ID := NULL;

   	     	    END;

		else
			RAISE FND_API.G_EXC_ERROR;
   		End If;
   	End If;

  else
	RAISE FND_API.G_EXC_ERROR;

  end if;

END Check_ddf;

-- ***************************************************************************
-- Start of Comments
--
--	API name 	: create_data_default
--	Type		: Public
--	Function	: Create a data default for a given profile and application id.
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER	Required
--   			p_init_msg_list		IN VARCHAR2	Optional
-- 			p_commit		IN VARCHAR	Optional
--
-- 			p_application_id	IN NUMBER	Required

-- 			p_profile_id		IN NUMBER	Required
-- 			p_profile_name		IN VARCHAR2	Optional
--
-- 			p_perz_ddf_id		IN NUMBER	Optional
-- 			p_perz_ddf_context	IN VARCHAR2	Required
-- 			p_gui_object_name	IN VARCHAR2	Required
-- 			p_gui_object_id		IN NUMBER	Optional
-- 			p_ddf_value		IN VARCHAR2	Required
-- 			p_ddf_value_type	IN VARCHAR2	Required
--
-- OUT :
--			x_perz_ddf_id	    OUT  NUMBER
-- 			x_return_status	 OUT  VARCHAR2
-- 			x_msg_count	 OUT  NUMBER
-- 			x_msg_data	 OUT  VARCHAR2
--
--
--	Version	:	Current version	1.0
--			Initial version 1.0
--
--	Notes:
--		This API is used to create a Data Default. A data default is
--		associated with a GUI object, default value and type.
--		The same GUI object can have different values in different
--		(profile_id, application_id, ddf_context) combination.
--
--		Also, for the same profile, applicatin and contgext,
--		different data defaults can be associated with the same
--		GUI object, if one GUI object has GUI Object ID and other
--		does not. If this is not allowed, this can be fixed by
--		creating the unique keyindex on profile id, application id,
--		gui object name
--
--
--

-- *****************************************************************************

PROCEDURE create_data_default
(
	p_api_version_number	IN NUMBER,
	p_init_msg_list		IN VARCHAR2,
	p_commit		IN VARCHAR,

	p_application_id	IN NUMBER,

	p_profile_id		IN NUMBER,
	p_profile_name		IN VARCHAR2,

	p_perz_ddf_id		IN NUMBER,
	p_perz_ddf_context	IN VARCHAR2,

	p_gui_object_name	IN VARCHAR2,
	p_gui_object_id		IN NUMBER,
	p_ddf_value		IN VARCHAR2,
	p_ddf_value_type	IN VARCHAR2,

	x_perz_ddf_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
      -- ******* Create_data_default Local Variables ********
--	Following variables are needed to adhere to standards
	l_api_version_number	NUMBER 	:= p_api_version_number;
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'Create_data_default';
--	Following variables are needed for implementation
	l_profile_id		NUMBER		:= NULL;
	l_profile_name		VARCHAR2(60)   := NULL;
	l_return_status    	VARCHAR2(240);
        l_perz_ddf_id		NUMBER := p_perz_ddf_id;
        l_object_version_number	NUMBER := NULL;

BEGIN

-- ******* create_data_default execution plan ********
--1. Check if the profile exists
--	check_duplicate_profiles()
--	If not, raise an error and exit
--2. call the insert table handler()

-- ******* create_data_default Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	CREATE_PERZ_DDF_PVT;

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

--  Create_data_default implementation

--1. Check if the profile exists. This check will be done
-- irrespective of whether the user had provided the id or not.
-- Beacuse, the mobile users must have created the profile on the
-- client and not on the server.

  l_profile_id := p_profile_id;
  l_profile_name := p_profile_name;
  l_return_status := FND_API.G_TRUE;

  JTF_PERZ_PROFILE_PVT.check_profile_duplicates(
	l_profile_name,
	l_return_status,
	l_profile_id
  );


-- If profile does not exists, raise an error and exit

   if (l_return_status = FND_API.G_FALSE) then
          RAISE FND_API.G_EXC_ERROR;
   end if;

--2 Calling the insert table handler
   l_object_version_number := 1;
   insert_jtf_perz_data_default(
          l_perz_ddf_id,
          l_profile_id,
          p_APPLICATION_ID,
          p_PERZ_DDF_CONTEXT,
          p_GUI_OBJECT_NAME,
          p_GUI_OBJECT_ID,
          p_DDF_VALUE,
          p_DDF_VALUE_TYPE,
	l_object_version_number
   );

    if (( l_perz_ddf_id is NULL)
	OR (l_perz_ddf_id = FND_API.G_MISS_NUM)) then
	RAISE FND_API.G_EXC_ERROR;
    else
	x_perz_ddf_id := l_perz_ddf_id;
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
    	 (
		p_count	=>      x_msg_count,
		p_data	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO CREATE_PERZ_DDF_PVT;
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

	  ROLLBACK TO CREATE_PERZ_DDF_PVT;
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

	  ROLLBACK TO CREATE_PERZ_DDF_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

END create_data_default;

-- *****************************************************************************


-- Start of Comments
--
--	API name 	: update_data_default
--	Type		: Public
--	Function	: Update data default object in the Framework.
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER	Required
--   			p_init_msg_list		IN VARCHAR2	Optional
-- 			p_commit		IN VARCHAR	Optional
--
-- 			p_application_id	IN NUMBER	Optional

-- 			p_profile_id		IN NUMBER	Optional
-- 			p_profile_name		IN VARCHAR2	Optional
--
-- 			p_perz_ddf_id		IN NUMBER	Optional
-- 			p_perz_ddf_context	IN VARCHAR2	Required
-- 			p_gui_object_name	IN VARCHAR2	Required
-- 			p_gui_object_id		IN NUMBER	Optional
-- 			p_ddf_value		IN VARCHAR2	Required
-- 			p_ddf_value_type	IN VARCHAR2	Required
--
-- OUT :
--			x_perz_ddf_id	    OUT  NUMBER
-- 			x_return_status	 OUT  VARCHAR2
-- 			x_msg_count	 OUT NUMBER
-- 			x_msg_data	 OUT  VARCHAR2
--
--
--	Version	:	Current version	1.0
--			Initial version 1.0
--
--	Notes:
--		For a given data default object, this API only updates
--		GUI object name, id and associated value and type fields only.
--
--
-- *****************************************************************************
--

PROCEDURE update_data_default
(
	p_api_version_number	IN NUMBER,
	p_init_msg_list		IN VARCHAR2,
	p_commit		IN VARCHAR,

	p_application_id	IN NUMBER,

	p_profile_id		IN NUMBER,
	p_profile_name		IN VARCHAR2,

	p_perz_ddf_id		IN NUMBER,
	p_perz_ddf_context	IN VARCHAR2,

	p_gui_object_name	IN VARCHAR2,
	p_gui_object_id		IN NUMBER,
	p_ddf_value		IN VARCHAR2,
	p_ddf_value_type	IN VARCHAR2,

	x_perz_ddf_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
      -- ******* Update_data_default Local Variables ********
--	Following variables are needed to adhere to standards
	l_api_version_number	NUMBER 	:= p_api_version_number;
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'Update_data_default';
--	Following variables are needed for implementation
	l_profile_id		NUMBER		:= NULL;
	l_profile_name		VARCHAR2(60)   := NULL;
	l_return_status    	VARCHAR2(240);
        l_perz_ddf_id		NUMBER := p_perz_ddf_id;
        l_object_version_number NUMBER := NULL;

BEGIN

-- ******* Update_data_default execution plan ********
--1. Check if the profile exists
--	check_duplicate_profiles()
--	If not, raise an error and exit
--2. Check if DDF exists
--3. call the update table handler()

-- ******* update_data_default Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	UPDATE_PERZ_DDF_PVT;

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

--  update_data_default implementation
--1. Check if the profile exists. This check will be done
-- irrespective of whether the user had provided the id or not.
-- Beacuse, the mobile users must have created the profile on the
-- client and not on the server.

  l_profile_id := p_profile_id;
  l_profile_name := p_profile_name;
  l_return_status := FND_API.G_TRUE;

  JTF_PERZ_PROFILE_PVT.check_profile_duplicates(
	l_profile_name,
	l_return_status,
	l_profile_id
  );


-- If profile does not exists, raise an error and exit

   if (l_return_status = FND_API.G_FALSE) then
          RAISE FND_API.G_EXC_ERROR;
   end if;

--2. Check if DDF exists in the DB.
-- This must be done to obtain the perz_ddf_id. Other wise,
-- an inline update statement must be written for each of the
-- case (here cases being, what inputs have been provided)

  Check_ddf(
	l_perz_ddf_id,
        l_profile_id,
        p_APPLICATION_ID,
        p_PERZ_DDF_CONTEXT,
        p_GUI_OBJECT_NAME,
        p_GUI_OBJECT_ID,
	l_OBJECT_VERSION_NUMBER
   );

  if (( l_perz_ddf_id is NULL)
	OR (l_perz_ddf_id = FND_API.G_MISS_NUM)) then
	RAISE FND_API.G_EXC_ERROR;
    else

--3. Call the update handler

	update_jtf_perz_data_default(
        	l_perz_ddf_id,
		l_profile_id,
          	p_APPLICATION_ID,
          	p_PERZ_DDF_CONTEXT,
          	p_GUI_OBJECT_NAME,
          	p_GUI_OBJECT_ID,
          	p_DDF_VALUE,
          	p_DDF_VALUE_TYPE,
		l_OBJECT_VERSION_NUMBER
	);

  	if (( l_perz_ddf_id is NULL)
		OR (l_perz_ddf_id = FND_API.G_MISS_NUM)) then
		RAISE FND_API.G_EXC_ERROR;
    	else
		x_perz_ddf_id := l_perz_ddf_id;
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
    	 (
		p_count	=>      x_msg_count,
		p_data	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO UPDATE_PERZ_DDF_PVT;
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

	  ROLLBACK TO UPDATE_PERZ_DDF_PVT;
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

	  ROLLBACK TO UPDATE_PERZ_DDF_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;


END update_data_default;

-- *****************************************************************************
-- Start of Comments
--
--	API name 	: save_data_default
--	Type		: Public
--	Function	: Create or update if exists, a personalized data default
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER	Required
--   			p_init_msg_list		IN VARCHAR2	Optional
-- 			p_commit		IN VARCHAR	Optional
--
-- 			p_application_id	IN NUMBER	Required

-- 			p_profile_id		IN NUMBER	Required
-- 			p_profile_name		IN VARCHAR2	Optional
-- 			p_profile_type		IN VARCHAR2	Optional
-- 			p_profile_attrib	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE Optional
--
-- 			p_perz_ddf_id		IN NUMBER	Optional
-- 			p_perz_ddf_context	IN VARCHAR2	Required
-- 			p_gui_object_name	IN VARCHAR2	Required
-- 			p_gui_object_id		IN NUMBER	Optional
-- 			p_ddf_value		IN VARCHAR2	Required
-- 			p_ddf_value_type	IN VARCHAR2	Required
--
-- OUT  	:
--			x_perz_ddf_id	    OUT  NUMBER
-- 			x_return_status	 OUT  VARCHAR2
-- 			x_msg_count	 OUT NUMBER
-- 			x_msg_data	 OUT  VARCHAR2
--
--
--	Version	:	Current version	1.0
--			Initial version 1.0
--
--	Notes:
--		Data Default is used a single value tied to any given GUI object
--		This Association can be identified by ddf_name. The same GUI object
--		can have different values in different (profile_id, application_id)
--		combination.
--		The perz_ddf_context is used to store under what context the GUI
--		object will have the assigned value for any given profile_id
--		application id combination
--
--
-- *****************************************************************************
--
PROCEDURE save_data_default
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN 	VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN 	NUMBER,

	p_profile_id        	IN 	NUMBER,
	p_profile_name      	IN 	VARCHAR2,
	p_profile_type      	IN 	VARCHAR2,
	p_profile_attrib    	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
				:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

	p_perz_ddf_id		IN NUMBER	,
	p_perz_ddf_context	IN VARCHAR2	,

	p_gui_object_name	IN VARCHAR2	,
	p_gui_object_id		IN NUMBER	,
	p_ddf_value		IN VARCHAR2	,
	p_ddf_value_type	IN VARCHAR2	,

	x_perz_ddf_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS


      -- ******* save_data_default Local Variables ********
--	Following variables are needed to adhere to standards
	l_api_version_number	NUMBER 	:= p_api_version_number;
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'save_data_default';
--	Following variables are needed for implementation
	l_profile_id		NUMBER		:= NULL;
	l_profile_name		VARCHAR2(60) := p_profile_name;
	l_profile_type		VARCHAR2(30) := p_profile_type;
	l_profile_attrib	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
				:= p_profile_attrib;
        l_perz_ddf_id		NUMBER := p_perz_ddf_id;
	l_return_status    	VARCHAR2(240)    := FND_API.G_TRUE;
	l_commit		VARCHAR2(1)	:= FND_API.G_TRUE;
	l_init_msg_list		VARCHAR2(1)		:= FND_API.G_FALSE;
        l_object_version_number NUMBER := NULL;

BEGIN

-- ******* save_data_default execution plan ********
--1. Check if the profile exists
--	check_duplicate_profiles()
--	If not,   call create_profile()
--2. Check if DDF exists
--	If not, call create_data_default()
--	If yes, update_data_default()

-- ******* save_data_default Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	SAVE_PERZ_DDF_PVT;

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

-- save_data_default  implementation
--1. Check if the profile exists. This check will be done
-- irrespective of whether the user had provided the id or not.
-- Beacuse, the mobile users must have created the profile on the
-- client and not on the server.


  l_profile_id := p_profile_id;
  l_profile_name := p_profile_name;
  l_profile_type := p_profile_type;
  l_return_status := FND_API.G_TRUE;

  JTF_PERZ_PROFILE_PVT.check_profile_duplicates(
	l_profile_name,
	l_return_status,
	l_profile_id
  );


-- If profile does not exists, call create_profile()

   if (l_return_status = FND_API.G_FALSE) then


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
	--dbms_output.put_line('profile return status '||l_return_status);
	if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

		RAISE FND_API.G_EXC_ERROR;
	end if;
   end if;



--2. Check if DDF exists in the DB.
-- This must be done to obtain the perz_ddf_id. Other wise,
-- an inline update statement must be written for each of the
-- case (here cases being, what inputs have been provided)

  l_perz_ddf_id := p_perz_ddf_id;
  Check_ddf(
	l_perz_ddf_id,
        l_profile_id,
        p_APPLICATION_ID,
        p_PERZ_DDF_CONTEXT,
        p_GUI_OBJECT_NAME,
        p_GUI_OBJECT_ID,
	l_OBJECT_VERSION_NUMBER
   );

  if (( l_perz_ddf_id is NULL)
	OR (l_perz_ddf_id = FND_API.G_MISS_NUM)) then

--3. If DDF does not exist, create it

	l_return_status := FND_API.G_RET_STS_SUCCESS;
	l_commit 	:= FND_API.G_FALSE;
	l_profile_name := NULL;

	create_data_default
	(
		l_api_version_number,
		l_init_msg_list	,
		l_commit	,
		p_application_id,
		l_profile_id	,
		l_profile_name	,
		l_perz_ddf_id	,
		p_perz_ddf_context,
		p_gui_object_name,
		p_gui_object_id	,
		p_ddf_value	,
		p_ddf_value_type,
		x_perz_ddf_id	,
		x_return_status	,
		x_msg_count	,
		x_msg_data
	);

 	else

--3. If DDF exists, update it

	l_return_status := FND_API.G_RET_STS_SUCCESS;
	l_commit 	:= FND_API.G_FALSE;
	l_profile_name := NULL;

	update_data_default
	(
		l_api_version_number,
		l_init_msg_list	,
		l_commit	,
		p_application_id,
		l_profile_id	,
		l_profile_name	,
		l_perz_ddf_id	,
		p_perz_ddf_context,
		p_gui_object_name,
		p_gui_object_id	,
		p_ddf_value	,
		p_ddf_value_type,
		x_perz_ddf_id	,
		x_return_status	,
		x_msg_count	,
		x_msg_data
	);
  end if ;
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
    	 (
		p_count	=>      x_msg_count,
		p_data	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO SAVE_PERZ_DDF_PVT;
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

	  ROLLBACK TO SAVE_PERZ_DDF_PVT;
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

	  ROLLBACK TO SAVE_PERZ_DDF_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;


END save_data_default;
-- *****************************************************************************
-- Start of Comments
--
--	API name 	: get_data_default
--	Type		: Public
--	Function	: Get personalized data default object, and associated
--				values for a given personalized data object and
--				profile and app id.
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER	Required
--   			p_init_msg_list		IN VARCHAR2	Optional
--
-- 			p_application_id	IN NUMBER	Required

-- 			p_profile_id		IN NUMBER	Required
-- 			p_profile_name		IN VARCHAR2	Optional
--
-- 			p_perz_ddf_id		IN NUMBER	Optional
-- 			p_perz_ddf_context	IN VARCHAR2	Required
-- 			p_gui_object_name	IN VARCHAR2	Required
-- 			p_gui_object_id		IN NUMBER	Optional
-- 			p_ddf_value		IN VARCHAR2	Required
-- 			p_ddf_value_type	IN VARCHAR2	Required
--
-- OUT  	:
--			x_ddf_out_tbl	    OUT JTF_PERZ_DDF_PUB.DDF_OUT_TBL_TYPE
-- 			x_return_status	 OUT  VARCHAR2
-- 			x_msg_count	 OUT NUMBER
-- 			x_msg_data	 OUT  VARCHAR2
--
--
--	Version	:	Current version	1.0
--			Initial version 1.0
--
--	Notes:
--
--	This API can be used in two ways,
--	1. To get the table of DDF by supplying profile id/name, application_id,
--		gui_object_id/name and dddf_context
--		(In this case out put table will have only one row) OR
--	2. To get the table of DDF by supplying profile id/name, application_id,
--		gui_object_id/name .
-- *****************************************************************************

PROCEDURE get_data_default
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN VARCHAR2,

	p_application_id	IN NUMBER,

	p_profile_id		IN NUMBER,
	p_profile_name		IN VARCHAR2,

	p_perz_ddf_id		IN NUMBER,
	p_perz_ddf_context	IN VARCHAR2,

	p_gui_object_name	IN VARCHAR2,
	p_gui_object_id		IN NUMBER,

	p_ddf_value		IN VARCHAR2,
	p_ddf_value_type	IN VARCHAR2,

	x_ddf_out_tbl	    OUT NOCOPY /* file.sql.39 change */ jtf_perz_ddf_pub.DDF_OUT_TBL_TYPE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
 -- ******* get_data_default Local Variables ********
--	Following variables are needed to adhere to standards
	l_api_version_number	NUMBER 	:= p_api_version_number;
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'get_data_default';
--	Following variables are needed for implementation
	l_profile_id		NUMBER		:= NULL;
	l_profile_name		VARCHAR2(60)   := NULL;
	l_return_status    	VARCHAR2(240);
        l_perz_ddf_id		NUMBER := p_perz_ddf_id;
	l_ddf_out_tbl	   	JTF_PERZ_DDF_PUB.DDF_OUT_TBL_TYPE
					:= x_ddf_out_tbl;


BEGIN

-- ******* get_data_default execution plan ********
--1. Check if the profile exists
--	check_duplicate_profiles()
--	If not, raise an error and exit
--2. get the ddf

-- ******* get_data_default Standard Begins ********

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

--  get_data_default implementation

--1. Check if the profile exists. This check will be done
-- irrespective of whether the user had provided the id or not.
-- Beacuse, the mobile users must have created the profile on the
-- client and not on the server.

  l_profile_id := p_profile_id;
  l_profile_name := p_profile_name;
  l_return_status := FND_API.G_TRUE;

  JTF_PERZ_PROFILE_PVT.check_profile_duplicates(
	l_profile_name,
	l_return_status,
	l_profile_id
  );


-- If profile does not exists, raise an error and exit

   if (l_return_status = FND_API.G_FALSE) then
          RAISE FND_API.G_EXC_ERROR;
   end if;

-- get ddf

   l_perz_ddf_id := p_perz_ddf_id;
   l_return_status := FND_API.G_TRUE;
   l_ddf_out_tbl := x_ddf_out_tbl;


   get_ddf(
	l_perz_ddf_id,
        l_profile_id,
        p_APPLICATION_ID,
        p_PERZ_DDF_CONTEXT,
        p_GUI_OBJECT_NAME,
        p_GUI_OBJECT_ID,
	p_ddf_value,
	p_ddf_value_type,
	l_ddf_out_tbl,
	l_return_status
   );

   if (l_return_status = FND_API.G_FALSE) then
	RAISE FND_API.G_EXC_ERROR;
   end if;
    x_ddf_out_tbl := l_ddf_out_tbl;

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

END get_data_default;
-- *****************************************************************************

-- Start of Comments
--
--	API name 	: delete_data_default
--	Type		: Public
--	Function	: Deletes a data dafault object in the framework.
--
--	Paramaeters	:
--	IN		:
-- 			p_api_version_number	IN NUMBER	Required
--   			p_init_msg_list		IN VARCHAR2	Optional
-- 			p_commit		IN VARCHAR	Optional
--
-- 			p_application_id	IN NUMBER	Required
-- 			p_profile_id        	IN NUMBER	Required
-- 			p_perz_ddf_id           IN NUMBER	Required
--
-- OUT 	:
-- 			x_return_status	 OUT  VARCHAR2
-- 			x_msg_count	 OUT  NUMBER
-- 			x_msg_data	 OUT  VARCHAR2
--
--
--
--	Version	:	Current version	1.0
--			Initial version 1.0
--
--	Notes:
--		This API accepts only the ids - profile id, application id
--		and perz_ddf_id to delete the data default object.
--
-- *****************************************************************************

PROCEDURE delete_data_default
(	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN 	VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        	IN NUMBER,
	p_perz_ddf_id           IN NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
      -- ******* Delete_data_default Local Variables ********
--	Following variables are needed to adhere to standards
	l_api_version_number	NUMBER 	:= p_api_version_number;
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'Delete_data_default';
--	Following variables are needed for implementation

BEGIN

-- ******* delete_data_default Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	DELETE_PERZ_DDF_PVT;

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

if ((p_perz_ddf_id is not null)
	AND (p_perz_ddf_id <> FND_API.G_MISS_NUM)) then
	-- Call delete_row()

	delete_jtf_perz_data_default( p_perz_ddf_id);
else
	RAISE FND_API.G_EXC_ERROR;

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
    	 (
		p_count	=>      x_msg_count,
		p_data	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO DELETE_PERZ_DDF_PVT;
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

	  ROLLBACK TO DELETE_PERZ_DDF_PVT;
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

	  ROLLBACK TO DELETE_PERZ_DDF_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;


END delete_data_default;
-- *****************************************************************************
-- *****************************************************************************
END JTF_PERZ_DDF_PVT ;

/
