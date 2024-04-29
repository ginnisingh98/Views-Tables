--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_PROFILE_PVT" as
/* $Header: jtfzvpfb.pls 120.2 2005/11/02 22:47:33 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
--
--   JTF_PERZ_PROFILE_PVT
--
-- PURPOSE
--   Private API for managing common functionality across the personalization
--	framework.
--
-- NOTES
--   This is used by public as well as private APIs.
--
-- HISTORY
--   06/07/99   SMATTEGU      Created. Added check_profile_duplicates()
--	06/10/99   CCHANDRA      Added table handlers, copy routines etc.
--  06/12/99   CCHANDRA      Added all procedures
--  07/30/99   SMATTEGU		 Modified insert_row_profile_Attribute to handle profile_attrib_id.
--  07/30/99   SMATTEGU		 Modified update_row_profile_attribute, create_profile, update_profile
--			   		to reflect the profile_attrib_id change
--  08/03/99   SMATTEGU		 Added save point and the corresponding
--			   		commit and rollback sections in update_profile()
--  08/04/99   SMATTEGU		Updated update_perz_profile table handler
--			   	* Commented profile_desc it is not sent from update_profile
--				* Commented the profile id section
--				* specified IN, IN OUTs for the parameters
-- 08/04/99   SMATTEGU		done many changes to update_profile()
--
-- 08/04/99    SMATTEGU		Updated the update_row_profile_attrib()
-- 			   	* commented the profile id and attribute id lines
--				* specified IN, IN OUTs for the parameters
--				* where clause must use the profile id and attribute name instead of rowid
-- 09/30/99  SMATTEGU	Updated the create_profile() to handle profile_id also.
--			Updated insert_row_jtf_perz_profile(), insert_row_profile_attrib().
--
-- 11/04/99  SMATTEGU	Changing the names to suite the standards and adding who columns
--
-- End of Comments

G_PKG_NAME  	CONSTANT VARCHAR2(30):='JTF_PERZ_PROFILE_PVT';
G_FILE_NAME   	CONSTANT VARCHAR2(12):='asxvzpfb.pls';


G_LOGIN_ID	NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID	NUMBER := FND_GLOBAL.USER_ID;


-- ****************************************************************************
-- ****************************************************************************
-- TABLE HANDLERS
--	1.	insert_row_jtf_perz_profile()
--	2.	update_row_jtf_perz_profile()
--	4.	delete_row_jtf_perz_profile()
--	5.	update_row_profile_attrib()
--	6.	insert_row_profile_attrib()
--	7.	delete_row_profile_attrib()
--
-- ****************************************************************************

PROCEDURE insert_row_jtf_perz_profile(
	X_ROWID                 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	x_PROFILE_ID            IN OUT NOCOPY /* file.sql.39 change */   NUMBER,
	x_PROFILE_NAME          IN VARCHAR2,
	x_PROFILE_TYPE          IN VARCHAR2,
	x_PROFILE_DESCRIPTION   IN VARCHAR2,
	x_ACTIVE_FLAG           IN VARCHAR2,
	p_OBJECT_VERSION_NUMBER IN	NUMBER
) IS

	CURSOR C IS SELECT rowid FROM JTF_PERZ_PROFILE
            WHERE PROFILE_ID = x_PROFILE_ID;

	CURSOR C2 IS SELECT JTF_PERZ_PROFILE_S.NEXTVAL FROM SYS.DUAL;

BEGIN

   IF (X_PROFILE_ID IS NULL) OR ( X_PROFILE_ID = FND_API.G_MISS_NUM) THEN
       OPEN C2;
       FETCH C2 INTO X_PROFILE_ID;
       CLOSE C2;
   END IF;

   INSERT INTO JTF_PERZ_PROFILE(
	PROFILE_ID,
	PROFILE_NAME,
	PROFILE_TYPE,
	PROFILE_DESCRIPTION,
	ACTIVE_FLAG,
	   OBJECT_VERSION_NUMBER,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN)
   VALUES ( x_PROFILE_ID,
   	decode( x_PROFILE_NAME, FND_API.G_MISS_CHAR, NULL ,x_PROFILE_NAME ),
	decode( x_PROFILE_TYPE, FND_API.G_MISS_CHAR, NULL ,x_PROFILE_TYPE ),
	decode( x_PROFILE_DESCRIPTION, FND_API.G_MISS_CHAR, NULL ,x_PROFILE_DESCRIPTION ),
	decode( x_ACTIVE_FLAG, FND_API.G_MISS_CHAR, NULL ,x_ACTIVE_FLAG ),
	   decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, 1, p_OBJECT_VERSION_NUMBER),
	   G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID);

   OPEN C;
   FETCH C INTO x_Rowid;
   IF (C%NOTFOUND) THEN
       CLOSE C;
       RAISE NO_DATA_FOUND;
   END IF;

END insert_row_jtf_perz_profile;
-- ****************************************************************************
--
-- Procedure to UPDATE a row in the JTF_PERZ_PROFILE table
--

PROCEDURE update_row_jtf_perz_profile(
	X_ROWID                 IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	x_PROFILE_ID            IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
	x_PROFILE_NAME          IN      VARCHAR2,
	x_PROFILE_TYPE          IN	VARCHAR2,
	x_PROFILE_DESCRIPTION   IN      VARCHAR2,
	x_ACTIVE_FLAG           IN      VARCHAR2,
	p_OBJECT_VERSION_NUMBER IN	NUMBER
) IS

l_object_version_number NUMBER := p_OBJECT_VERSION_NUMBER;

BEGIN

  UPDATE JTF_PERZ_PROFILE SET
	PROFILE_NAME = decode( x_PROFILE_NAME, FND_API.G_MISS_CHAR, PROFILE_NAME, x_PROFILE_NAME ),
	PROFILE_TYPE = decode( x_PROFILE_TYPE, FND_API.G_MISS_CHAR, PROFILE_TYPE, x_PROFILE_TYPE ),
	PROFILE_DESCRIPTION = decode( x_PROFILE_DESCRIPTION, FND_API.G_MISS_CHAR,
				PROFILE_DESCRIPTION,x_PROFILE_DESCRIPTION ),
	ACTIVE_FLAG = decode( x_ACTIVE_FLAG, FND_API.G_MISS_CHAR, ACTIVE_FLAG,
				x_ACTIVE_FLAG ),
	OBJECT_VERSION_NUMBER = decode (p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,
					OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER+1),
	LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATED_BY  = FND_GLOBAL.USER_ID,
	LAST_UPDATE_LOGIN = FND_GLOBAL.CONC_LOGIN_ID
  WHERE profile_id = x_PROFILE_ID
	and OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER;

  IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
  END IF;

END update_row_jtf_perz_profile;

 -- ****************************************************************************
PROCEDURE insert_row_profile_attrib(
	X_ROWID		 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	X_PROFILE_ATTRIB_ID IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_PROFILE_ID            IN NUMBER,
	x_PROFILE_ATTRIBUTE     IN  VARCHAR2,
	x_ATTRIBUTE_TYPE        IN  VARCHAR2,
	x_ATTRIBUTE_VALUE       IN  VARCHAR2
 ) IS

   CURSOR C IS SELECT rowid FROM jtf_perz_profile_attrib
            WHERE PROFILE_ID = x_PROFILE_ID AND ROWNUM = 1;
    CURSOR C2 IS SELECT jtf_perz_profile_attrib_s.NEXTVAL FROM SYS.DUAL;

BEGIN
   IF (X_PROFILE_ATTRIB_ID IS NULL) OR
   	(X_PROFILE_ATTRIB_ID = FND_API.G_MISS_NUM) THEN
       OPEN C2;
       FETCH C2 INTO X_PROFILE_ATTRIB_ID;
       CLOSE C2;
   END IF;

   INSERT INTO jtf_perz_profile_attrib(
   	PROFILE_ATTRIB_ID,
	PROFILE_ID,
	PROFILE_ATTRIBUTE,
	ATTRIBUTE_TYPE,
	ATTRIBUTE_VALUE,
	CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN)
   VALUES (
   	X_PROFILE_ATTRIB_ID,
   	x_PROFILE_ID,
	decode (x_PROFILE_ATTRIBUTE, FND_API.G_MISS_CHAR, NULL, x_PROFILE_ATTRIBUTE ),
	decode (x_ATTRIBUTE_TYPE, FND_API.G_MISS_CHAR, NULL ,x_ATTRIBUTE_TYPE),
	decode (x_ATTRIBUTE_VALUE, FND_API.G_MISS_CHAR, NULL ,x_ATTRIBUTE_VALUE),
	   G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID );

   OPEN C;
   FETCH C INTO x_Rowid;
   IF (C%NOTFOUND) THEN
       CLOSE C;
       RAISE NO_DATA_FOUND;
   END IF;

END insert_row_profile_attrib;

 -- ****************************************************************************
PROCEDURE update_row_profile_attrib(
        X_ROWID                 OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
	x_PROFILE_ATTRIB_ID	IN	  NUMBER,
        x_PROFILE_ID            IN      NUMBER,
        x_PROFILE_ATTRIBUTE     IN      VARCHAR2,
        x_ATTRIBUTE_TYPE        IN      VARCHAR2,
        x_ATTRIBUTE_VALUE       IN      VARCHAR2
) IS

BEGIN

	UPDATE jtf_perz_profile_attrib SET
		ATTRIBUTE_TYPE = decode( x_ATTRIBUTE_TYPE, FND_API.G_MISS_CHAR,
					ATTRIBUTE_TYPE, x_ATTRIBUTE_TYPE ),
		ATTRIBUTE_VALUE = decode( x_ATTRIBUTE_VALUE, FND_API.G_MISS_CHAR,
					ATTRIBUTE_VALUE, x_ATTRIBUTE_VALUE ),
	LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATED_BY  = FND_GLOBAL.USER_ID,
	LAST_UPDATE_LOGIN = FND_GLOBAL.CONC_LOGIN_ID
	WHERE profile_id = x_profile_id and
	PROFILE_ATTRIBUTE = x_PROFILE_ATTRIBUTE;

    IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END update_row_profile_attrib;

-- ****************************************************************************
-- ****************************************************************************

-- PROCEDURE	check_profile_duplicates()
--******************************************************************************
-- ****************************************************************************

PROCEDURE check_profile_duplicates(
	p_profile_name      IN   VARCHAR2,
	x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	x_profile_id        IN OUT NOCOPY /* file.sql.39 change */  NUMBER

)
 IS
			l_temp_id NUMBER;

 BEGIN


 IF ((p_profile_name IS NOT NULL) AND (x_profile_id IS NULL)) THEN

--	dbms_output.put_line( 'chk profile '||p_profile_name);
	SELECT profile_id INTO x_profile_id
	FROM jtf_perz_profile
	WHERE profile_name = p_profile_name;

	if (x_profile_id IS NOT NULL) then
		x_return_status := FND_API.G_TRUE;
	else
		x_return_status := FND_API.G_FALSE;
	end if;

  ELSIF ((p_profile_name IS NULL) AND (x_profile_id IS NOT NULL)) THEN

    select profile_id INTO l_temp_id
	from jtf_perz_profile
	where profile_id = x_profile_id;

	if (l_temp_id IS NOT NULL) then
		x_return_status := FND_API.G_TRUE;
	else
		x_return_status := FND_API.G_FALSE;
	end if;

  ELSIF ((p_profile_name IS NOT NULL) AND (x_profile_id IS NOT NULL)) THEN

	SELECT profile_id INTO l_temp_id
	FROM jtf_perz_profile
	WHERE profile_name = p_profile_name
	and   profile_id	= x_profile_id;

	if (l_temp_id IS NOT NULL) then
		x_return_status := FND_API.G_TRUE;
	else
		x_return_status := FND_API.G_FALSE;
	end if;

  else
		x_return_status := FND_API.G_FALSE;
  end if;

--	dbms_output.put_line( 'chk profile rtn status '||x_return_status);
EXCEPTION

WHEN NO_DATA_FOUND THEN
		x_return_status := FND_API.G_FALSE;
when OTHERS then
	 RAISE FND_API.G_EXC_ERROR;
END check_profile_duplicates;

-- ****************************************************************************
-- ****************************************************************************
-- DYNAMIC SQL PROCEDURES
-- ****************************************************************************


-- This precedure defines the columns for the D-SQL query
-- The columns are essentially a mapping of table columns from
-- the query to the output record set.

  PROCEDURE Define_Columns_Profile(
  			p_profile_attrib_rec IN JTF_PERZ_PROFILE_PUB.PROFILE_OUT_REC_TYPE,
            p_cur_profile IN NUMBER ) IS
  BEGIN

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
        -- dbms_output.put_line('JTF_PERZ_PROFILE_PVT Define columns');
		null;
      END IF;

        dbms_sql.define_column(p_cur_profile, 1, p_profile_attrib_rec.PROFILE_ID);
        dbms_sql.define_column(p_cur_profile, 2, p_profile_attrib_rec.PROFILE_NAME, 60);
		dbms_sql.define_column(p_cur_profile, 3, p_profile_attrib_rec.PROFILE_TYPE, 30);
        dbms_sql.define_column(p_cur_profile, 4, p_profile_attrib_rec.PROFILE_DESCRIPTION, 240);
        dbms_sql.define_column(p_cur_profile, 5, p_profile_attrib_rec.ACTIVE_FLAG, 1);
        dbms_sql.define_column(p_cur_profile, 6, p_profile_attrib_rec.PROFILE_ATTRIBUTE, 100);
		dbms_sql.define_column(p_cur_profile, 7, p_profile_attrib_rec.ATTRIBUTE_TYPE, 100);
        dbms_sql.define_column(p_cur_profile, 8, p_profile_attrib_rec.ATTRIBUTE_VALUE, 100);

  END Define_Columns_Profile;
-- ****************************************************************************
  -- This procedure defines the return columns for the D-SQL

  PROCEDURE Get_Columns_Profile(p_cur_profile  	   	 IN NUMBER,
                            	p_profile_attrib_rec OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_PROFILE_PUB.PROFILE_OUT_REC_TYPE ) IS
  BEGIN
        --dbms_output.put_line('JTF_PERZ_PROFILE_PVT Get column values');

		dbms_sql.column_value(p_cur_profile, 1, p_profile_attrib_rec.PROFILE_ID);
        dbms_sql.column_value(p_cur_profile, 2, p_profile_attrib_rec.PROFILE_NAME);
		dbms_sql.column_value(p_cur_profile, 3, p_profile_attrib_rec.PROFILE_TYPE);
        dbms_sql.column_value(p_cur_profile, 4, p_profile_attrib_rec.PROFILE_DESCRIPTION);
        dbms_sql.column_value(p_cur_profile, 5, p_profile_attrib_rec.ACTIVE_FLAG);
        dbms_sql.column_value(p_cur_profile, 6, p_profile_attrib_rec.PROFILE_ATTRIBUTE);
        dbms_sql.column_value(p_cur_profile, 7, p_profile_attrib_rec.ATTRIBUTE_TYPE);
		dbms_sql.column_value(p_cur_profile, 8, p_profile_attrib_rec.ATTRIBUTE_VALUE);

  END Get_Columns_Profile;
 -- ****************************************************************************

-- This procedure will bind the variables for the dynamic SQL query

  PROCEDURE Bind_Variables_Profile(
  			p_cur_profile  	   	     IN NUMBER,
  			p_profile_attrib_tbl   	 IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE,
            p_profile_name 			 IN VARCHAR2,
			p_profile_type 			 IN VARCHAR2,
			p_profile_id		 	 IN NUMBER
  ) IS

  BEGIN

    -- Bind variables
    -- Only those that are not NULL

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          --dbms_output.put_line('JTF_PERZ_PROFILE_PVT Bind variables');
		null;
    END IF;

    If (p_profile_name IS NOT NULL) Then
        dbms_sql.bind_variable(p_cur_profile, 'p_profile_name', p_profile_name);
    End if;

	 If (p_profile_id IS NOT NULL) Then
        dbms_sql.bind_variable(p_cur_profile, 'p_profile_id', p_profile_id);
    End if;

	 If (p_profile_type IS NOT NULL) Then
        dbms_sql.bind_variable(p_cur_profile, 'p_profile_type', p_profile_type);
    End if;

   -- going beyond this only if more than one row
   IF (p_profile_attrib_tbl.count > 0) THEN

	 If (p_profile_attrib_tbl(1).profile_attribute IS NOT NULL) Then
        dbms_sql.bind_variable(p_cur_profile, 'p_profile_attribute', p_profile_attrib_tbl(1).profile_attribute);
    End if;

	 If (p_profile_attrib_tbl(1).attribute_type IS NOT NULL) Then
        dbms_sql.bind_variable(p_cur_profile, 'p_attribute_type', p_profile_attrib_tbl(1).attribute_type);
    End if;

	 If (p_profile_attrib_tbl(1).attribute_value IS NOT NULL) Then
        dbms_sql.bind_variable(p_cur_profile, 'p_attribute_value', p_profile_attrib_tbl(1).attribute_value);
    End if;

   END IF;

  END Bind_Variables_Profile;
-- ****************************************************************************


-- This procedure generates the WHERE clause for Get_Activities

  PROCEDURE Gen_Where_Profile(
  			p_profile_attrib_tbl   	 IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE,
            p_profile_name 			 IN VARCHAR2,
			p_profile_type 			 IN VARCHAR2,
			p_profile_id		 	 IN NUMBER,
            x_head_where 			 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ) IS

  BEGIN

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          --dbms_output.put_line('JTF_PERZ_PROFILE_PVT Generate Where');
	null;
      END IF;


	if (x_head_where is NULL) Then
            x_head_where := 'WHERE prfl.profile_id = prfl_attrib.profile_id ';
         else
            x_head_where := x_head_where || 'AND prfl.profile_id = prfl_attrib.profile_id ';
    End if;

    If (p_profile_name IS NOT NULL) Then
        if (x_head_where is NULL) Then
            x_head_where := 'WHERE ';
		else
            x_head_where := x_head_where || 'AND ';
        End if;
        x_head_where := x_head_where || 'prfl.profile_name=:p_profile_name ';
    End if;

	If (p_profile_type IS NOT NULL) Then
        if (x_head_where is NULL) Then
            x_head_where := 'WHERE ';
		else
            x_head_where := x_head_where || 'AND ';
        End if;
        x_head_where := x_head_where || 'prfl.profile_type=:p_profile_type ';
    End if;

	If (p_profile_id IS NOT NULL) Then
        if (x_head_where is NULL) Then
            x_head_where := 'Where ';
		else
            x_head_where := x_head_where || 'And ';
        End if;
        x_head_where := x_head_where || 'prfl.profile_id=:p_profile_id ';
    End if;

  -- go beyond this only if table count > 0
  IF (p_profile_attrib_tbl.count > 0) THEN

    If ((p_profile_attrib_tbl(1).profile_attribute) IS NOT NULL) Then
        if (x_head_where is NULL) Then
            x_head_where := 'WHERE ';
        else
            x_head_where := x_head_where || 'AND ';
        End if;
        x_head_where := x_head_where || 'prfl_attrib.profile_attribute=:p_profile_attribute ';
    End if;

    If ((p_profile_attrib_tbl(1).attribute_type) IS NOT NULL ) Then
        if (x_head_where is NULL) Then
            x_head_where := 'WHERE ';
        else
            x_head_where := x_head_where || 'AND ';
        End if;
        x_head_where := x_head_where || 'prfl_attrib.attribute_type=:p_attribute_type ';
    End if;

    If ((p_profile_attrib_tbl(1).attribute_value) IS NOT NULL) Then
        if (x_head_where is NULL) Then
            x_head_where := 'WHERE ';
        else
            x_head_where := x_head_where || 'AND ';
        End if;
        x_head_where := x_head_where || 'prfl_attrib.attribute_value=:p_attribute_value ';

    End if;

  END IF;
 --dbms_output.put_line('where in the end  ' || x_head_where);

  END Gen_Where_Profile;
  -- ****************************************************************************

-- This procedure generate the Select and From clause for the profile store

  PROCEDURE Gen_Select_Profile( x_select_cl OUT NOCOPY /* file.sql.39 change */ VARCHAR2 ) IS

  BEGIN

	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          --dbms_output.put_line('JTF_PERZ_PVT GENERATE SELECT');
		null;
      END IF;

      x_select_cl := 'Select ' ||
        'prfl.PROFILE_ID,' ||
        'prfl.PROFILE_NAME,' ||
		'prfl.PROFILE_TYPE,' ||
        'prfl.ACTIVE_FLAG,' ||
        'prfl.PROFILE_DESCRIPTION,' ||
        'prfl_attrib.PROFILE_ATTRIBUTE,' ||
        'prfl_attrib.ATTRIBUTE_TYPE,' ||
        'prfl_attrib.ATTRIBUTE_VALUE ' ||

		' from JTF_PERZ_PROFILE prfl, jtf_perz_profile_attrib prfl_attrib ';

--dbms_output.put_line(x_select_cl);

  END Gen_Select_Profile;
-- ***************************************************************************
-- ****************************************************************************
--	Public APIs
--	Create Profile
--	Update Profile
--	Get Profile
-- ****************************************************************************
-- ****************************************************************************
PROCEDURE Create_Profile
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_profile_id		IN	NUMBER,
	p_profile_name          IN	VARCHAR2 := NULL,
	p_profile_type		IN VARCHAR2 := NULL,
	p_profile_desc          IN	VARCHAR2 := NULL,
	p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
						 	:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

	x_profile_name       OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_profile_id         OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

	l_profile_attrib_tbl	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
						:= p_profile_attrib_tbl;
	l_any_errors           BOOLEAN        := FALSE;
	l_any_row_errors       BOOLEAN        := FALSE;
	l_rowid                ROWID;
	l_return_status        VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
	l_api_name		CONSTANT VARCHAR2(30)	:= 'Create Profile';
	l_count		     	NUMBER     := p_profile_attrib_tbl.count;
     	l_curr_row		NUMBER		:= NULL;

     	l_duplicate            VARCHAR2(240)    := FND_API.G_FALSE;
	l_profile_name		VARCHAR2(60)	:= p_profile_name;

     -- Variables for ids
	l_active_flag	   	VARCHAR2(1)  := 'Y';
     	l_profile_id		NUMBER := NULL;
     	l_profile_attrib_id	NUMBER;
     	l_is_duplicate		VARCHAR2(1);
	l_object_version_number	NUMBER := NULL;

BEGIN
       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	CREATE_PERZ_PROFILE_PVT;

--dbms_output.put_line('creating save point ');
/*
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
*/
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;


-- profiles execution steps :
-- 1. check if duplicate exists
-- 2. if no,
-- 3. insert row with proflie data into profile table
-- 4. pick id and cycle through attributes in profile attribute table
-- 5. insert records into profile attribute table.
-- 6. if profile already exists, return error !


-- 1. CHECK IF DUPLICATE  EXISTS
-- 1.1.	CHECK DUPLICATE PROFILE

 check_profile_duplicates ( p_profile_name,
				l_duplicate,
				l_profile_id );

--dbms_output.put_line(' l_duplicate ' || l_duplicate);

-- 1.2. 	IF PROFILE ALREADY EXISTS, RETURN ERROR !

		IF (FND_API.To_Boolean(l_duplicate)) THEN
		   --     x_return_status := FND_API.G_RET_STS_ERROR ;
          		RAISE FND_API.G_EXC_ERROR;
		END IF;

-- 1.3.	IF NOT, CHECK IF THERE ARE ANY DUPLICATE ENTRIES AT ATTRIBUTES LEVEL

-- 2. if no duplicates, then create a profile

-- 3. insert row with proflie data into profile table

--dbms_output.put_line('inserting into profile table ');

   if ((p_profile_id is not null) and
	(p_profile_id <> FND_API.G_MISS_NUM)) then
		l_profile_id := p_profile_id;
   end if;

    l_object_version_number := 1;
    insert_row_jtf_perz_profile(
	l_rowid,
	l_profile_id,
	p_profile_name,
	p_profile_type,
	p_profile_desc,
	l_active_flag,
	l_object_version_number	 );

-- copying ID to output.

   x_profile_id := l_profile_id;
   x_profile_name := p_profile_name;

-- 5. insert records into profile attribute table

   FOR l_curr_row in 1..l_count LOOP
   	l_rowid := NULL;
	insert_row_profile_attrib(
		l_rowid,
	 	l_profile_attrib_tbl(l_curr_row).ATTRIBUTE_ID,
                l_profile_id,
                l_profile_attrib_tbl(l_curr_row).profile_attribute,
                l_profile_attrib_tbl(l_curr_row).attribute_type,
                l_profile_attrib_tbl(l_curr_row).attribute_value
	);

   END LOOP;

-- ******** Standard Ends ***********
--
-- End of main API body.

   -- Standard check of p_commit.
   IF (FND_API.To_Boolean(p_commit)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count       	=>      x_msg_count,
        			p_data        	=>      x_msg_data );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
--	  dbms_output.put_line('stop 1 ');

	  ROLLBACK TO CREATE_PERZ_PROFILE_PVT;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count    	=>      x_msg_count,
	  				p_data       	=>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--	  dbms_output.put_line('stop 2 ');
	  ROLLBACK TO CREATE_PERZ_PROFILE_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count       	=>      x_msg_count,
        	  			p_data        	=>      x_msg_data );

    WHEN OTHERS THEN
--	  dbms_output.put_line('stop 3 ');
	  ROLLBACK TO CREATE_PERZ_PROFILE_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

	FND_MSG_PUB.Count_And_Get( p_count        	=>      x_msg_count,
        	  		p_data          	=>      x_msg_data );

END Create_Profile;

-- ****************************************************************************

PROCEDURE Get_Profile
(       p_api_version_number    IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2  := FND_API.G_FALSE,

        p_profile_id            IN      NUMBER := NULL,
        p_profile_name          IN      VARCHAR2 := NULL,
        p_profile_type                  IN VARCHAR2 := NULL,
        p_profile_attrib_tbl    IN      JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
                                := JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

        x_profile_tbl           OUT NOCOPY /* file.sql.39 change */     JTF_PERZ_PROFILE_PUB.PROFILE_OUT_TBL_TYPE,
        x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
        x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)IS

          l_profile_attrib_tbl  JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
                                                        := p_profile_attrib_tbl;
      l_profile_out_tbl     JTF_PERZ_PROFILE_PUB.PROFILE_OUT_TBL_TYPE;
          l_profile_out_rec    JTF_PERZ_PROFILE_PUB.PROFILE_OUT_REC_TYPE;

      l_any_errors               BOOLEAN        := FALSE;
      l_any_row_errors           BOOLEAN        := FALSE;
      l_rowid                    ROWID;
      l_return_status            VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
      l_api_name                CONSTANT VARCHAR2(30)   := 'Get Profile';

          l_count                    NUMBER     := p_profile_attrib_tbl.count;
      l_curr_row                 NUMBER         := 0;
          l_cur_profile_attrib  NUMBER  := NULL;

      -- Variables for ids
          l_active_flag                                 VARCHAR2(1)  := 'Y';
      l_key                                                     VARCHAR2(50);
      l_profile_id                                      NUMBER;
      l_profile_attrib_id                       NUMBER;
      l_is_duplicate                            VARCHAR2(1);
      l_ignore                                          NUMBER;
      i                             NUMBER := 1;
      l_select_clause                      VARCHAR2(2000) := '';
          l_head_where                     VARCHAR2(2000) := NULL;
      l_returned_rec_count            NUMBER := 0;

--      l_profile_attrib  VARCHAR2(60) := p_profile_attrib_tbl(1).PROFILE_ATTRIBUTE;
--      l_attribute_type  VARCHAR2(60) :=  p_profile_attrib_tbl(1).ATTRIBUTE_TYPE;

   cursor prof1_curs (l_profname varchar2) is
     SELECT a.PROFILE_ID, a.PROFILE_NAME,
            a.PROFILE_TYPE, a.PROFILE_DESCRIPTION, a.ACTIVE_FLAG,
            b.PROFILE_ATTRIBUTE, b.ATTRIBUTE_TYPE, b.ATTRIBUTE_VALUE
     FROM JTF_PERZ_PROFILE a, JTF_PERZ_PROFILE_ATTRIB b
     WHERE a.profile_id = b.profile_id AND a.profile_name = l_profname ;

   cursor profid1_curs (l_profid number) is
     SELECT a.PROFILE_ID, a.PROFILE_NAME,
            a.PROFILE_TYPE, a.PROFILE_DESCRIPTION, a.ACTIVE_FLAG,
            b.PROFILE_ATTRIBUTE, b.ATTRIBUTE_TYPE, b.ATTRIBUTE_VALUE
     FROM JTF_PERZ_PROFILE a, JTF_PERZ_PROFILE_ATTRIB b
     WHERE a.profile_id = b.profile_id AND a.profile_id = l_profid ;

   cursor proftype1_curs (l_proftype varchar2) is
     SELECT a.PROFILE_ID, a.PROFILE_NAME,
            a.PROFILE_TYPE, a.PROFILE_DESCRIPTION, a.ACTIVE_FLAG,
            b.PROFILE_ATTRIBUTE, b.ATTRIBUTE_TYPE, b.ATTRIBUTE_VALUE
     FROM JTF_PERZ_PROFILE a, JTF_PERZ_PROFILE_ATTRIB b
     WHERE a.profile_id = b.profile_id AND profile_type = l_proftype ;

   cursor proftype2_curs (l_proftype varchar2, l_profile_attrib varchar2) is
     SELECT a.PROFILE_ID, a.PROFILE_NAME,
            a.PROFILE_TYPE, a.PROFILE_DESCRIPTION, a.ACTIVE_FLAG,
            b.PROFILE_ATTRIBUTE, b.ATTRIBUTE_TYPE, b.ATTRIBUTE_VALUE
     FROM JTF_PERZ_PROFILE a, JTF_PERZ_PROFILE_ATTRIB b
     WHERE a.profile_id = b.profile_id
        AND a.profile_type = l_proftype
        AND b.PROFILE_ATTRIBUTE = l_profile_attrib ;

   cursor proftype3_curs (l_proftype varchar2, l_attrib_type varchar2) is
     SELECT a.PROFILE_ID, a.PROFILE_NAME,
            a.PROFILE_TYPE, a.PROFILE_DESCRIPTION, a.ACTIVE_FLAG,
            b.PROFILE_ATTRIBUTE, b.ATTRIBUTE_TYPE, b.ATTRIBUTE_VALUE
     FROM JTF_PERZ_PROFILE a, JTF_PERZ_PROFILE_ATTRIB b
     WHERE a.profile_id = b.profile_id
        AND a.profile_type = l_proftype
        AND b.ATTRIBUTE_TYPE = l_attrib_type ;

  cursor proftype4_curs (l_proftype varchar2, l_profile_attrib varchar2, l_attrib_type varchar2) is
    SELECT a.PROFILE_ID, a.PROFILE_NAME,
            a.PROFILE_TYPE, a.PROFILE_DESCRIPTION, a.ACTIVE_FLAG,
            b.PROFILE_ATTRIBUTE, b.ATTRIBUTE_TYPE, b.ATTRIBUTE_VALUE
    FROM JTF_PERZ_PROFILE a, JTF_PERZ_PROFILE_ATTRIB b
    WHERE a.profile_id = b.profile_id
          AND a.profile_type = l_proftype
          AND b.ATTRIBUTE_TYPE = l_attrib_type
          AND b.PROFILE_ATTRIBUTE = l_profile_attrib;

   cursor profid1attr_curs (l_profid number) is
     SELECT PROFILE_ATTRIBUTE,ATTRIBUTE_TYPE,ATTRIBUTE_VALUE
     FROM     JTF_PERZ_PROFILE_ATTRIB
    WHERE    profile_id = l_profid;

     curso_1prof prof1_curs%ROWTYPE;
     curso_1profid profid1_curs%ROWTYPE;
     curso_1proftype proftype1_curs%ROWTYPE;
     curso_2proftype proftype2_curs%ROWTYPE;
     curso_3proftype proftype3_curs%ROWTYPE;
     curso_4proftype proftype4_curs%ROWTYPE;
     curso_1profattr profid1attr_curs%ROWTYPE;

BEGIN
       -- ******* Standard Begins ********

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

          -- Initialize API return status to success
      l_return_status := FND_API.G_RET_STS_SUCCESS;


   if (p_profile_id IS NOT NULL) then

           for curso_1profid in profid1_curs(p_profile_id) loop
             x_profile_tbl(i).Profile_ID := curso_1profid.PROFILE_ID ;
             x_profile_tbl(i).PROFILE_NAME:= curso_1profid.PROFILE_NAME;
             x_profile_tbl(i).PROFILE_TYPE:= curso_1profid.PROFILE_TYPE;
             x_profile_tbl(i).PROFILE_DESCRIPTION:= curso_1profid.PROFILE_DESCRIPTION;
             x_profile_tbl(i).ACTIVE_FLAG := curso_1profid.ACTIVE_FLAG;
             x_profile_tbl(i).PROFILE_ATTRIBUTE := curso_1profid.PROFILE_ATTRIBUTE ;
             x_profile_tbl(i).ATTRIBUTE_TYPE:= curso_1profid.ATTRIBUTE_TYPE;
             x_profile_tbl(i).ATTRIBUTE_VALUE:= curso_1profid.ATTRIBUTE_VALUE;
           i := i+1;
           end loop;
           x_return_status := FND_API.G_RET_STS_SUCCESS;
           return;

    elsif (p_profile_name IS NOT NULL) then

        for curso_1prof in prof1_curs(p_profile_name) loop
          x_profile_tbl(i).Profile_ID := curso_1prof.PROFILE_ID ;
          x_profile_tbl(i).PROFILE_NAME:= curso_1prof.PROFILE_NAME;
          x_profile_tbl(i).PROFILE_TYPE:= curso_1prof.PROFILE_TYPE;
          x_profile_tbl(i).PROFILE_DESCRIPTION:= curso_1prof.PROFILE_DESCRIPTION;
          x_profile_tbl(i).ACTIVE_FLAG := curso_1prof.ACTIVE_FLAG;
          x_profile_tbl(i).PROFILE_ATTRIBUTE := curso_1prof.PROFILE_ATTRIBUTE ;
          x_profile_tbl(i).ATTRIBUTE_TYPE:= curso_1prof.ATTRIBUTE_TYPE;
          x_profile_tbl(i).ATTRIBUTE_VALUE:= curso_1prof.ATTRIBUTE_VALUE;
          i := i+1;
       end loop;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       return;

   elsif ((p_profile_type IS NOT NULL) AND

          ((p_profile_attrib_tbl(1).PROFILE_ATTRIBUTE IS NOT NULL) AND
          (p_profile_attrib_tbl(1).PROFILE_ATTRIBUTE <> FND_API.G_MISS_CHAR)) AND

          ((p_profile_attrib_tbl(1).ATTRIBUTE_TYPE IS NOT NULL) AND
          (p_profile_attrib_tbl(1).ATTRIBUTE_TYPE <> FND_API.G_MISS_CHAR))) then

        for curso_4proftype in proftype4_curs(p_profile_type, p_profile_attrib_tbl(1).PROFILE_ATTRIBUTE,
                p_profile_attrib_tbl(1).ATTRIBUTE_TYPE) loop
          x_profile_tbl(i).Profile_ID := curso_4proftype.PROFILE_ID ;
          x_profile_tbl(i).PROFILE_NAME:= curso_4proftype.PROFILE_NAME;
              x_profile_tbl(i).PROFILE_TYPE:= curso_4proftype.PROFILE_TYPE;
          x_profile_tbl(i).PROFILE_DESCRIPTION:= curso_4proftype.PROFILE_DESCRIPTION;
          x_profile_tbl(i).ACTIVE_FLAG := curso_4proftype.ACTIVE_FLAG;
          x_profile_tbl(i).PROFILE_ATTRIBUTE := curso_4proftype.PROFILE_ATTRIBUTE ;
          x_profile_tbl(i).ATTRIBUTE_TYPE:= curso_4proftype.ATTRIBUTE_TYPE;
          x_profile_tbl(i).ATTRIBUTE_VALUE:= curso_4proftype.ATTRIBUTE_VALUE;
          i := i+1;
       end loop;

       x_return_status := FND_API.G_RET_STS_SUCCESS;
       return;

   elsif ((p_profile_type IS NOT NULL) AND
          (p_profile_attrib_tbl(1).PROFILE_ATTRIBUTE IS NOT NULL) AND
          (p_profile_attrib_tbl(1).PROFILE_ATTRIBUTE <> FND_API.G_MISS_CHAR)) then

        for curso_2proftype in proftype2_curs(p_profile_type, p_profile_attrib_tbl(1).PROFILE_ATTRIBUTE) loop
          x_profile_tbl(i).Profile_ID := curso_2proftype.PROFILE_ID ;
          x_profile_tbl(i).PROFILE_NAME:= curso_2proftype.PROFILE_NAME;
              x_profile_tbl(i).PROFILE_TYPE:= curso_2proftype.PROFILE_TYPE;
          x_profile_tbl(i).PROFILE_DESCRIPTION:= curso_2proftype.PROFILE_DESCRIPTION;
          x_profile_tbl(i).ACTIVE_FLAG := curso_2proftype.ACTIVE_FLAG;
          x_profile_tbl(i).PROFILE_ATTRIBUTE := curso_2proftype.PROFILE_ATTRIBUTE ;
          x_profile_tbl(i).ATTRIBUTE_TYPE:= curso_2proftype.ATTRIBUTE_TYPE;
          x_profile_tbl(i).ATTRIBUTE_VALUE:= curso_2proftype.ATTRIBUTE_VALUE;
          i := i+1;
       end loop;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       return;

   elsif ((p_profile_type IS NOT NULL) AND
          (p_profile_attrib_tbl(1).ATTRIBUTE_TYPE IS NOT NULL) AND
          (p_profile_attrib_tbl(1).ATTRIBUTE_TYPE <> FND_API.G_MISS_CHAR)) then

        for curso_3proftype in proftype3_curs(p_profile_type, p_profile_attrib_tbl(1).ATTRIBUTE_TYPE) loop
          x_profile_tbl(i).Profile_ID := curso_3proftype.PROFILE_ID ;
          x_profile_tbl(i).PROFILE_NAME:= curso_3proftype.PROFILE_NAME;
          x_profile_tbl(i).PROFILE_TYPE:= curso_3proftype.PROFILE_TYPE;
          x_profile_tbl(i).PROFILE_DESCRIPTION:= curso_3proftype.PROFILE_DESCRIPTION;
          x_profile_tbl(i).ACTIVE_FLAG := curso_3proftype.ACTIVE_FLAG;
          x_profile_tbl(i).PROFILE_ATTRIBUTE := curso_3proftype.PROFILE_ATTRIBUTE ;
          x_profile_tbl(i).ATTRIBUTE_TYPE:= curso_3proftype.ATTRIBUTE_TYPE;
          x_profile_tbl(i).ATTRIBUTE_VALUE:= curso_3proftype.ATTRIBUTE_VALUE;
          i := i+1;
       end loop;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       return;

  else
       for curso_1proftype in proftype1_curs(p_profile_type) loop
          x_profile_tbl(i).Profile_ID := curso_1proftype.PROFILE_ID ;
          x_profile_tbl(i).PROFILE_NAME:= curso_1proftype.PROFILE_NAME;
          x_profile_tbl(i).PROFILE_TYPE:= curso_1proftype.PROFILE_TYPE;
          x_profile_tbl(i).PROFILE_DESCRIPTION:= curso_1proftype.PROFILE_DESCRIPTION;
          x_profile_tbl(i).ACTIVE_FLAG := curso_1proftype.ACTIVE_FLAG;
          x_profile_tbl(i).PROFILE_ATTRIBUTE := curso_1proftype.PROFILE_ATTRIBUTE ;
          x_profile_tbl(i).ATTRIBUTE_TYPE:= curso_1proftype.ATTRIBUTE_TYPE;
          x_profile_tbl(i).ATTRIBUTE_VALUE:= curso_1proftype.ATTRIBUTE_VALUE;
          i := i+1;
       end loop;
       x_return_status := FND_API.G_RET_STS_SUCCESS;

  end if;


      -- End of API body.


      -- Success Message

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
      THEN
          FND_MESSAGE.Set_Name('AS', 'API_SUCCESS');
          FND_MESSAGE.Set_Token('ROW', 'personalize', TRUE);
          FND_MSG_PUB.Add;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         --dbms_output.put_line('personalize');
                null;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count           =>      x_msg_count,
                          p_data                =>      x_msg_data );

 EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
          --dbms_output.put_line('stop 1 ');

          --ROLLBACK TO CREATE_PERZ_PROFILE_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get( p_count            =>      x_msg_count,
                                         p_data         =>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --dbms_output.put_line('stop 2 ');
         -- ROLLBACK TO CREATE_PERZ_PROFILE_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Count_And_Get( p_count            =>      x_msg_count,
                                         p_data         =>      x_msg_data );

    WHEN OTHERS THEN
          --dbms_output.put_line('stop 3 ');
          --ROLLBACK TO CREATE_PERZ_PROFILE_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

        FND_MSG_PUB.Count_And_Get( p_count              =>      x_msg_count,
                                   p_data               =>      x_msg_data );


  END Get_Profile;
-- ****************************************************************************

PROCEDURE Update_Profile
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
	p_profile_id            IN	NUMBER,
	p_profile_name          IN	VARCHAR2,
	p_profile_type		IN 	VARCHAR2 := NULL,
	p_profile_desc          IN	VARCHAR2 ,
	p_active_flag		IN  VARCHAR2,
	p_Profile_ATTRIB_Tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE,
	x_profile_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS
	 -- problem is, this API will not check the validity of the p_active_flag

	l_profile_attrib_tbl	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE;
	l_attributes_from_database JTF_PERZ_PROFILE_PUB.PROFILE_OUT_TBL_TYPE;

	l_api_version		NUMBER := 1.0;
	l_init_msg_list		VARCHAR2(240):= FND_API.G_TRUE;
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(2000);
	l_any_errors           BOOLEAN        := FALSE;
	l_any_row_errors       BOOLEAN        := FALSE;
	l_rowid               	ROWID;
	l_return_status        VARCHAR2(240)    := FND_API.G_RET_STS_SUCCESS;
	l_api_name		CONSTANT VARCHAR2(30)	:= 'Update Profile';
	l_count		     	NUMBER     := p_profile_attrib_tbl.count;
	l_count_1		NUMBER 	   := NULL;
	l_curr_row		NUMBER		:= NULL;
	l_curr_row_1		NUMBER 		:= NULL;
	l_duplicate            VARCHAR2(240)    := FND_API.G_FALSE;
	l_profile_name		VARCHAR2(100)	:= NULL;
	l_profile_desc	  	VARCHAR2(240) := FND_API.G_MISS_CHAR;
	l_active_flag	   	VARCHAR2(1)  := 'Y';
     	l_is_duplicate		VARCHAR2(1);
	l_found_flag		BOOLEAN := FALSE;
	l_profile_type		VARCHAR2(30);

     -- Variables for ids
     l_profile_id		NUMBER := NULL;
     l_profile_attrib_id	NUMBER;
	l_object_version_number	NUMBER := NULL;
	l_attrib_obj_version_no	NUMBER := NULL;

BEGIN
       -- ******* Standard Begins ********
	    -- Standard Start of API savepoint
      SAVEPOINT	UPDATE_PERZ_PROFILE_PVT;
/*
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
*/
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    if (p_profile_id is not null) AND
	(p_profile_id <> FND_API.G_MISS_NUM)  then
		l_profile_id := p_profile_id;
	else
		l_profile_id := NULL;
	end if;
	if (p_profile_name is not null) AND
	(p_profile_name <> FND_API.G_MISS_CHAR) then
		l_profile_name := p_profile_name;
	else
	 	l_profile_name := NULL;
	end if;

	if (l_profile_id is null and l_profile_name is null) then
	   raise FND_API.G_EXC_ERROR;
	end if;
	l_profile_type := NULL;

 	Get_Profile(
		l_api_version,
		l_init_msg_list,
		l_profile_id,
		l_profile_name,
		l_profile_type,
		l_profile_attrib_tbl,
		l_attributes_from_database,
		l_return_status,
		x_msg_count,
		x_msg_data );

	l_profile_attrib_tbl := p_Profile_ATTRIB_Tbl;
	l_profile_id := l_attributes_from_database(1).PROFILE_ID;
	l_profile_name := l_attributes_from_database(1).profile_name;
	l_count_1 := l_attributes_from_database.count;

 IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    l_count := l_profile_attrib_tbl.count;

   if (( p_profile_type is null) OR
   	  (p_profile_type = FND_API.G_MISS_CHAR)) then
	  l_profile_type := FND_API.G_MISS_CHAR;
   else
      l_profile_type := p_profile_type;
   end if;


   if (( p_profile_desc is null) OR
   	  (p_profile_desc = FND_API.G_MISS_CHAR)) then
	  l_profile_desc := FND_API.G_MISS_CHAR;
   else
      l_profile_desc := p_profile_desc;
   end if;

   -- Select the object_version_number that corresponds to the
   -- profile object. This must be done separately as object_version_number
   -- is not part of the get_profile API.

   select object_version_number into l_object_version_number
	from jtf_perz_profile where profile_id = l_profile_id;

   -- In the following call, p_active_flag must be replaced with l_active_flag
   -- and l_active_flag must be initialized like l_profile_type above.
   -- for some reason, I am getting ORA 6502 when I trie to do that.
   -- This must be fixed in future - srikanth

   update_row_jtf_perz_profile(
	l_rowid,
	l_profile_id,
	l_profile_name,
	l_profile_type,
        l_profile_desc,
        p_active_flag,
	l_object_version_number);

   FOR l_curr_row in 1..l_count LOOP

    l_rowid := NULL;
    l_found_flag := FALSE;

	<<l_inner_loop>>
	FOR l_curr_row_1 in 1..l_count_1 LOOP
		IF (l_profile_attrib_tbl(l_curr_row).PROFILE_ATTRIBUTE =
			l_attributes_from_database(l_curr_row_1).PROFILE_ATTRIBUTE)
		 THEN
			--UPDATE row with new attribute values.
			update_row_profile_attrib(
				l_rowid,
		 		l_profile_attrib_tbl(l_curr_row).ATTRIBUTE_ID,
                  		l_profile_id,
                  		l_profile_attrib_tbl(l_curr_row).profile_attribute,
                  		l_profile_attrib_tbl(l_curr_row).attribute_type,
                  		l_profile_attrib_tbl(l_curr_row).attribute_value
			);
		 	l_found_flag := TRUE;
		 	EXIT l_inner_loop;
	  	END IF;

	END LOOP; -- end inner loop

	IF NOT (l_found_flag) THEN

		-- INSERT attribute into table
		insert_row_profile_attrib(
			l_rowid,
	 		l_profile_attrib_tbl(l_curr_row).ATTRIBUTE_ID,
                  	l_profile_id,
                  	l_profile_attrib_tbl(l_curr_row).profile_attribute,
                  	l_profile_attrib_tbl(l_curr_row).attribute_type,
                  	l_profile_attrib_tbl(l_curr_row).attribute_value
		);
	END IF;

   END LOOP; -- end outer loop

   if (x_return_status is not null) then
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   end if;

END IF;  -- for success check
-- ******** Standard Ends ***********
--
-- End of main API body.

   -- Standard check of p_commit.
   IF (FND_API.To_Boolean(p_commit)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count       	=>      x_msg_count,
        			 p_data        	=>      x_msg_data );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	   ROLLBACK TO UPDATE_PERZ_PROFILE_PVT;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count    	=>      x_msg_count,
	  				 p_data       	=>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  ROLLBACK TO UPDATE_PERZ_PROFILE_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count       	=>      x_msg_count,
        	  			 p_data        	=>      x_msg_data );

    WHEN OTHERS THEN
	  ROLLBACK TO UPDATE_PERZ_PROFILE_PVT;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

	FND_MSG_PUB.Count_And_Get( p_count        	=>      x_msg_count,
        	  		   p_data          	=>      x_msg_data );

END Update_Profile;
-- ****************************************************************************
-- ****************************************************************************

END JTF_PERZ_PROFILE_PVT;

/
