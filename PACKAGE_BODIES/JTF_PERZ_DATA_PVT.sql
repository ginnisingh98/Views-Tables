--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_DATA_PVT" as
/* $Header: jtfzvpdb.pls 120.2 2005/11/02 22:31:23 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
--   JTF_PERZ_DATA_PVT

-- HISTORY
--
--	09/20/99	SMATTEGU	Created
--	09/30/99	SMATTEGU	changed the save() to reflect profile_id fix
--	10/26/99	SMATTEGU	fixed bug 1051390 type is considered by
--					get_perz_data_summary() now
--	11/02/99	SMATTEGU	fixed bug 1050713 type is considered by
--					get_perz_data() now
--
--	11/10/99	SMATTEGU	fixed bug 1070584, who column changes
--
--	01/24/2000	SMATTEGU	Enhancement #1165283
--	02/03/2000	SMATTEGU	Enhancement #1181062 changing the
--					perz_data_name size from 60 to 120
-- End of Comments
--
--*****************************************************************************


G_PKG_NAME  	CONSTANT VARCHAR2(30):='JTF_PERZ_DATA_PVT';
G_FILE_NAME   	CONSTANT VARCHAR2(12):='jtfvpzdb.pls';


G_LOGIN_ID	NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID	NUMBER := FND_GLOBAL.USER_ID;



-- *****************************************************************************
-- *****************************************************************************
--	TABLE HANDLERS
--	1. insert_jtf_perz_data
--	2. insert_jtf_perz_data_attrib
--	3. update_jtf_perz_data
-- *****************************************************************************
-- *****************************************************************************
--


PROCEDURE insert_jtf_perz_data(
          px_PERZ_DATA_ID   IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
          p_PROFILE_ID    NUMBER,
          p_APPLICATION_ID    NUMBER,
          p_PERZ_DATA_NAME    VARCHAR2,
          p_PERZ_DATA_TYPE    VARCHAR2,
          p_PERZ_DATA_DESC    VARCHAR2
	)

 IS
   CURSOR C2 IS SELECT JTF_PERZ_DATA_S.nextval FROM sys.dual;
BEGIN
   If (px_PERZ_DATA_ID IS NULL) OR (px_PERZ_DATA_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_PERZ_DATA_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_PERZ_DATA(
           PERZ_DATA_ID,
           PROFILE_ID,
           APPLICATION_ID,
           PERZ_DATA_NAME,
           PERZ_DATA_TYPE,
           PERZ_DATA_DESC,
	   OBJECT_VERSION_NUMBER,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN
          ) VALUES (
           px_PERZ_DATA_ID,
           decode( p_PROFILE_ID, FND_API.G_MISS_NUM, NULL, p_PROFILE_ID),
           decode( p_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_APPLICATION_ID),
           decode( p_PERZ_DATA_NAME, FND_API.G_MISS_CHAR, NULL, p_PERZ_DATA_NAME),
           decode( p_PERZ_DATA_TYPE, FND_API.G_MISS_CHAR, NULL, p_PERZ_DATA_TYPE),
           decode( p_PERZ_DATA_DESC, FND_API.G_MISS_CHAR, NULL, p_PERZ_DATA_DESC),
		1, G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID);
End insert_jtf_perz_data;

-- *****************************************************************************
PROCEDURE insert_jtf_perz_data_attrib(
          px_PERZ_DATA_ATTRIB_ID   IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
          p_PERZ_DATA_ID    NUMBER,
          p_ATTRIBUTE_NAME    VARCHAR2,
          p_ATTRIBUTE_TYPE    VARCHAR2,
          p_ATTRIBUTE_VALUE    VARCHAR2,
          p_ATTRIBUTE_CONTEXT    VARCHAR2)

 IS
   CURSOR C2 IS SELECT JTF_PERZ_DATA_ATTRIBUTES_S.nextval FROM sys.dual;
BEGIN
   If (px_PERZ_DATA_ATTRIB_ID IS NULL) OR (px_PERZ_DATA_ATTRIB_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_PERZ_DATA_ATTRIB_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_PERZ_DATA_ATTRIB(
           PERZ_DATA_ATTRIB_ID,
           PERZ_DATA_ID,
           ATTRIBUTE_NAME,
           ATTRIBUTE_TYPE,
           ATTRIBUTE_VALUE,
           ATTRIBUTE_CONTEXT,
		CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN
          ) VALUES (
           px_PERZ_DATA_ATTRIB_ID,
           decode( p_PERZ_DATA_ID, FND_API.G_MISS_NUM, NULL, p_PERZ_DATA_ID),
           decode( p_ATTRIBUTE_NAME, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_NAME),
           decode( p_ATTRIBUTE_TYPE, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_TYPE),
           decode( p_ATTRIBUTE_VALUE, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_VALUE),
           decode( p_ATTRIBUTE_CONTEXT, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CONTEXT),
	   G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID );

End insert_jtf_perz_data_attrib;

-- *****************************************************************************

PROCEDURE update_jtf_perz_data(
          p_PERZ_DATA_ID    NUMBER,
          p_PROFILE_ID    NUMBER,
          p_APPLICATION_ID    NUMBER,
          p_PERZ_DATA_NAME    VARCHAR2,
          p_PERZ_DATA_TYPE    VARCHAR2,
          p_PERZ_DATA_DESC    VARCHAR2,
	p_OBJECT_VERSION_NUMBER IN	NUMBER)

 IS
 BEGIN
    Update JTF_PERZ_DATA
    SET
              PROFILE_ID = decode( p_PROFILE_ID, FND_API.G_MISS_NUM, PROFILE_ID, p_PROFILE_ID),
              APPLICATION_ID = decode( p_APPLICATION_ID, FND_API.G_MISS_NUM, APPLICATION_ID, p_APPLICATION_ID),
              PERZ_DATA_NAME = decode( p_PERZ_DATA_NAME, FND_API.G_MISS_CHAR, PERZ_DATA_NAME, p_PERZ_DATA_NAME),
              PERZ_DATA_TYPE = decode( p_PERZ_DATA_TYPE, FND_API.G_MISS_CHAR, PERZ_DATA_TYPE, p_PERZ_DATA_TYPE),
              PERZ_DATA_DESC = decode( p_PERZ_DATA_DESC, FND_API.G_MISS_CHAR, PERZ_DATA_DESC, p_PERZ_DATA_DESC),
	OBJECT_VERSION_NUMBER = decode (p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,
					OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER+1),
	LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATED_BY  = FND_GLOBAL.USER_ID,
	LAST_UPDATE_LOGIN = FND_GLOBAL.CONC_LOGIN_ID
    where PERZ_DATA_ID = p_PERZ_DATA_ID
	and OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END update_jtf_perz_data;

-- *****************************************************************************
-- *****************************************************************************
--
--	PRIVATE PROCEDURES
--	check_perz_data()
-- *****************************************************************************
PROCEDURE check_perz_data (
	p_perz_data_name      	IN	VARCHAR2,
 	p_application_id  	IN  	NUMBER,
 	p_profile_id	   	IN	NUMBER,
	p_perz_data_type	IN	VARCHAR2,
 	x_return_status    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 	x_perz_data_id	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
	x_OBJECT_VERSION_NUMBER OUT NOCOPY /* file.sql.39 change */ NUMBER
) IS
	l_temp_id NUMBER;

 BEGIN

--dbms_output.put_line(p_perz_data_name);

	 IF ((p_perz_data_name IS NOT NULL) AND
		(p_perz_data_name <> FND_API.G_MISS_CHAR))  THEN


		--	SMATTEGU	Enhancement #1165283 BEGINS

		if (p_perz_data_type <> FND_API.G_MISS_CHAR)  THEN

			SELECT perz_data_id, object_version_number
			INTO x_perz_data_id,  x_object_version_number
			FROM  jtf_perz_data
			WHERE
			perz_data_name = p_perz_data_name AND
	      		application_id = p_application_id AND
	      		profile_id = p_profile_id	AND
			perz_data_type = p_perz_data_type;

		else -- p_perz_data_type is G_MISS_CHAR

			SELECT perz_data_id, object_version_number
			INTO x_perz_data_id,  x_object_version_number
			FROM  jtf_perz_data
			WHERE perz_data_name = p_perz_data_name AND
	      		application_id = p_application_id AND
	      		profile_id = p_profile_id;
		end if;

		--	SMATTEGU	Enhancement #1165283 ENDS

		if (x_perz_data_id IS NOT NULL) then
			x_return_status := FND_API.G_TRUE;
		else
			x_return_status := FND_API.G_FALSE;
		end if;

  	ELSE
		IF ((x_perz_data_id IS NOT NULL) AND
			(x_perz_data_id <> FND_API.G_MISS_NUM)) THEN

			SELECT perz_data_id, object_version_number
			INTO l_temp_id,  x_object_version_number
			from jtf_perz_data
			where perz_data_id = x_perz_data_id;

			if (l_temp_id IS NOT NULL) then
				x_return_status := FND_API.G_TRUE;
			else
				x_return_status := FND_API.G_FALSE;
			end if;

  		END IF;
 	END IF;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		x_return_status := FND_API.G_FALSE;

END check_perz_data;
-- *****************************************************************************
-- *****************************************************************************
--	APIs
--	Save_Perz_Data
--	Create_Perz_Data
--	Get_Perz_Data
--	Get_Perz_Data_Summary
--	Update_Perz_Data
--	Delete_Perz_Data
-- *****************************************************************************
-- *****************************************************************************

PROCEDURE Save_Perz_Data
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        	IN NUMBER,
	p_profile_name      	IN VARCHAR2,
	p_profile_type      	IN VARCHAR2,
	p_profile_attrib    	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
			:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,
	p_perz_data_id		IN NUMBER,
	p_perz_data_name        IN VARCHAR2,
	p_perz_data_type	IN VARCHAR2,
	p_perz_data_desc	IN VARCHAR2,
	p_data_attrib_tbl	IN JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
				:= JTF_PERZ_DATA_PUB.G_MISS_DATA_ATTRIB_TBL,

	x_perz_data_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

	--******** Save_Perz_Data local variable for standards **********
     	l_api_name		 CONSTANT VARCHAR2(30)	:= 'Save PerzData';
	l_api_version_number	NUMBER 	:= p_api_version_number;

	--******** Save_Perz_Data local variable for implementation *****
	l_return_status 	VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;
	l_perz_data_id		NUMBER := p_perz_data_id;
	l_PERZ_DATA_ATTRIB_ID	NUMBER := NULL;
	l_profile_id		NUMBER;
	l_is_duplicate		VARCHAR2(1) := FND_API.G_FALSE;
	l_profile_attrib	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
				:= p_profile_attrib;
	l_profile_name		VARCHAR2(60) := p_profile_name;
	l_commit		VARCHAR2(1)	:= FND_API.G_FALSE;
	l_object_version_number NUMBER :=NULL;

BEGIN
       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	SAVE_PERZ_DATA_PVT;

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
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


--  CALL FLOW :
-- 1. Check for profile, if not existing create profile.
-- 2. check if duplicate PerzData exists if TRUE,
--	then call update()
--	else call insert()



-- 1.	check profile


	 --dbms_output.put_line('before chk profile ');
  	if ((p_profile_id IS NOT NULL) AND
	    (p_profile_id <> FND_API.G_MISS_NUM)) then
		l_profile_id := p_profile_id;
  	else
		l_profile_id := NULL;
  	end if;


	JTF_PERZ_PROFILE_PVT.check_profile_duplicates(
		l_profile_name,
		l_return_status,
		l_profile_id
	);
	 --dbms_output.put_line('aft chk profile, profileId:'||l_profile_id);

-- 1.1	if profile is not available, create profile

	if (l_return_status = FND_API.G_FALSE) then

		l_return_status := FND_API.G_RET_STS_SUCCESS;
		l_commit 		 := FND_API.G_FALSE;

  		l_profile_id := p_profile_id;

	 	--dbms_output.put_line('before create profile ');
		JTF_PERZ_PROFILE_PVT.Create_Profile(
			p_api_version_number	=> l_api_version_number,
			p_commit		=> l_commit,
			p_profile_id		=> l_profile_id,
			p_profile_name		=> p_profile_name,
			p_profile_type		=> p_profile_type,
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
	 --dbms_output.put_line('aft chk profile, profileId:'||l_profile_id);
	end if;

-- 2. CHECK IF DUPLICATE  EXISTS
-- the duplicacy is defined as having the same perz data  name
--	for the a profile id within an application id.

	--dbms_output.put_line('stop 1');
	check_perz_data (
		p_perz_data_name,
		p_application_id,
		l_profile_id,
		p_perz_data_type,
		l_is_duplicate,
		l_perz_data_id,
		l_object_version_number);

	--dbms_output.put_line(' l_duplicate ' || l_is_duplicate);
l_commit 		 := FND_API.G_FALSE;

 IF (FND_API.To_Boolean(l_is_duplicate)) THEN

   --dbms_output.put_line('stop 3');
-- Call update_perz_data
   Update_Perz_Data
   (	l_api_version_number,
  	p_init_msg_list,
	l_commit,

	p_application_id,
	l_profile_id    ,

	l_perz_data_id,
	p_perz_data_name ,
	p_perz_data_type ,
    	p_perz_data_desc,

	p_data_attrib_tbl,

	x_perz_data_id  ,
	x_return_status	,
	x_msg_count,
	x_msg_data
   );

 ELSE


   --dbms_output.put_line('stop 2');
-- Call create_perz_data
   Create_Perz_Data
   (	l_api_version_number,
  	p_init_msg_list,
	l_commit,

	p_application_id,

	l_profile_id    ,
	p_profile_name  ,

	l_perz_data_id,
	p_perz_data_name ,
	p_perz_data_type ,
    	p_perz_data_desc,

	p_data_attrib_tbl,

	x_perz_data_id  ,
	x_return_status	,
	x_msg_count,
	x_msg_data
   );

 END IF;

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
	 --dbms_output.put_line('stop 4 ');

	  ROLLBACK TO SAVE_PERZ_DATA_PVT;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 --dbms_output.put_line('stop 5 ');
	  ROLLBACK TO SAVE_PERZ_DATA_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );


    WHEN OTHERS THEN
	 --dbms_output.put_line('stop 5 ');
	  ROLLBACK TO SAVE_PERZ_DATA_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	END IF;

	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );


END Save_Perz_Data;


-- *****************************************************************************
--


PROCEDURE Create_Perz_Data
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN VARCHAR	 := FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id            IN NUMBER,
	p_profile_name          IN VARCHAR2,
	p_perz_data_id		IN NUMBER,
    	p_perz_data_name        IN VARCHAR2,
	p_perz_data_type	IN VARCHAR2,
	p_perz_data_desc	IN VARCHAR2,
	p_data_attrib_tbl	IN JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
				:= JTF_PERZ_DATA_PUB.G_MISS_DATA_ATTRIB_TBL,

	x_perz_data_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
	--******** Create_Perz_Data local variable for standards **********
     	l_api_name		 CONSTANT VARCHAR2(30)	:= 'Create PerzData';
	l_api_version_number	NUMBER 	:= p_api_version_number;

       -- ******* Create_Perz_Data Local Variables ********
	l_perz_data_id		NUMBER := p_perz_data_id;
	l_PERZ_DATA_ATTRIB_ID	NUMBER := NULL;
     	l_is_duplicate		VARCHAR2(1) := FND_API.G_FALSE;
	l_curr_row		NUMBER		:= NULL;
	l_object_version_number	NUMBER := NULL;


BEGIN
       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	CREATE_PERZ_DATA_PVT;

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call
--		( l_api_version_number,
--		p_api_version_number, l_api_name, G_PKG_NAME)
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


--  CALL FLOW :
-- 1. check if duplicate exists if TRUE, return error
-- 2. if FALSE, do
-- 3. insert row with perz data into perz data table
-- 4. pick perz_data_id and cycle through attributes
--		insert into attributes table


-- 1. CHECK IF DUPLICATE  EXISTS
-- the duplicacy is defined as having the same perz data  name
--	for the a profile id within an application id.

	check_perz_data (
		p_perz_data_name,
		p_application_id,
		p_profile_id,
		p_perz_data_type,
		l_is_duplicate,
		l_perz_data_id,
		l_object_version_number);

--dbms_output.put_line(' l_duplicate ' || l_is_duplicate);

	IF (FND_API.To_Boolean(l_is_duplicate)) THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
          	RAISE FND_API.G_EXC_ERROR;
	END IF;

	insert_jtf_perz_data(
          l_perz_data_id,
          p_PROFILE_ID,
          p_APPLICATION_ID,
          p_PERZ_DATA_NAME,
          p_PERZ_DATA_TYPE,
          p_PERZ_DATA_DESC
	);

-- copying ID to output.

   x_perz_data_id := l_perz_data_id;


--dbms_output.put_line('perz_data_id from insert ' || l_perz_data_id);

-- 5. insert records into field map table

   IF (p_data_attrib_tbl.COUNT > 0) THEN

      FOR l_curr_row in 1..p_data_attrib_tbl.COUNT LOOP


	l_PERZ_DATA_ATTRIB_ID :=p_data_attrib_tbl(l_curr_row).PERZ_DATA_ATTRIB_ID ;
--dbms_output.put_line('attribute count ' || p_data_attrib_tbl.count);

	insert_jtf_perz_data_attrib(
        	l_PERZ_DATA_ATTRIB_ID,
		l_perz_data_id,
		p_data_attrib_tbl(l_curr_row).ATTRIBUTE_NAME,
		p_data_attrib_tbl(l_curr_row).ATTRIBUTE_TYPE,
		p_data_attrib_tbl(l_curr_row).ATTRIBUTE_VALUE,
		p_data_attrib_tbl(l_curr_row).ATTRIBUTE_CONTEXT);
--dbms_output.put_line('profile attribute id from insert ' || l_perz_data_attrib_id);

     END LOOP;
   END IF;

-- ******** Standard Ends ***********
--
-- End of main API body.

   -- Standard check of p_commit.
   IF (FND_API.To_Boolean(p_commit)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count     =>      x_msg_count,
        		      p_data      =>      x_msg_data );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	  --dbms_output.put_line('stop 1 ');

	  ROLLBACK TO CREATE_PERZ_DATA_PVT;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count   =>      x_msg_count,
	  			     p_data    =>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  --dbms_output.put_line('stop 2 ');
	  ROLLBACK TO CREATE_PERZ_DATA_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count      =>      x_msg_count,
        	  		     p_data       =>      x_msg_data );

    WHEN OTHERS THEN
	  --dbms_output.put_line('stop 3 ');
	  ROLLBACK TO CREATE_PERZ_DATA_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

	FND_MSG_PUB.Count_And_Get( p_count      =>      x_msg_count,
        	  		  p_data        =>      x_msg_data );


END Create_Perz_Data;
-- *****************************************************************************


PROCEDURE Get_Perz_Data
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id       	IN	NUMBER,
	p_profile_name     	IN	VARCHAR2,
	p_perz_data_id          IN NUMBER,
	p_perz_data_name        IN VARCHAR2,
	p_perz_data_type	IN VARCHAR2 := NULL,

    	x_perz_data_id          OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_perz_data_name        OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_perz_data_type OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_perz_data_desc OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_data_attrib_tbl OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS


	--******** Get_Perz_Data local variable for standards **********
     	l_api_name		 CONSTANT VARCHAR2(30)	:= 'Get PerzData';
	l_api_version_number	NUMBER 	:= p_api_version_number;

       -- ******* Get_Perz_Data Local Variables ********
  	l_perz_data_id		NUMBER		:= p_perz_data_id;
	l_count			NUMBER		:= NULL;
	l_data_out_tbl	 JTF_PERZ_DATA_PUB.DATA_OUT_TBL_TYPE;

	-- temp variables

		l_PERZ_DATA_ATTRIB_ID_temp	NUMBER := NULL;
		l_PERZ_DATA_ID_temp		   NUMBER := NULL;
		l_ATTRIBUTE_NAME_temp		VARCHAR2(60) := NULL;
		l_ATTRIBUTE_TYPE_temp		VARCHAR2(30)  := NULL;
		l_ATTRIBUTE_VALUE_temp		VARCHAR2(300)   := NULL;
		l_ATTRIBUTE_CONTEXT_temp	VARCHAR2(360)    := NULL;

     -- cursors
	CURSOR C_Get_Perz_Data (p_perz_data_id NUMBER ) IS
	SELECT  perz_data_attrib_id, perz_data_id, attribute_name,
		attribute_type, attribute_value, attribute_context
     	FROM    jtf_perz_data_attrib
     	WHERE   perz_data_id = p_perz_data_id;


BEGIN
       -- ******* Standard Begins ********

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call
--		( l_api_version_number,
--		p_api_version_number, l_api_name, G_PKG_NAME)
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

--1. CAll Get_Perz_Data_Summary
--2. If the out table has mor ethan one row rasie error
--	else get attributes for given perz data id.

      Get_Perz_Data_Summary(
		p_api_version_number,
  		p_init_msg_list,
		p_application_id,

		p_profile_id    ,
		p_profile_name  ,

		l_perz_data_id,
		p_perz_data_name ,
		p_perz_data_type ,

		l_data_out_tbl,

		x_return_status	,
		x_msg_count,
		x_msg_data
      );

	  --dbms_output.put_line('Summary API return status:'||x_return_status );
	  --dbms_output.put_line('# Summary API returned:'||l_data_out_tbl.count );
      if ( x_return_status = FND_API.G_RET_STS_SUCCESS) then

	l_count := l_data_out_tbl.count;
	if ( l_count = 1) then
		x_perz_data_id	:= l_data_out_tbl(l_count).perz_data_id;
		x_perz_data_name := l_data_out_tbl(l_count).perz_data_name;
		x_perz_data_type := l_data_out_tbl(l_count).perz_data_type;
		x_perz_data_desc := l_data_out_tbl(l_count).perz_data_desc;




		l_PERZ_DATA_ATTRIB_ID_temp	:= NULL;
		l_PERZ_DATA_ID_temp		    := NULL;
		l_ATTRIBUTE_NAME_temp		 := NULL;
		l_ATTRIBUTE_TYPE_temp		  := NULL;
		l_ATTRIBUTE_VALUE_temp		   := NULL;
		l_ATTRIBUTE_CONTEXT_temp	    := NULL;

		l_count := 1;
		Open C_Get_Perz_Data (x_perz_data_id);
		LOOP
			FETCH C_Get_Perz_Data INTO
				l_PERZ_DATA_ATTRIB_ID_temp,
				l_PERZ_DATA_ID_temp,
				l_ATTRIBUTE_NAME_temp,
				l_ATTRIBUTE_TYPE_temp,
				l_ATTRIBUTE_VALUE_temp,
				l_ATTRIBUTE_CONTEXT_temp;

			EXIT WHEN C_Get_Perz_Data%NOTFOUND;

			IF(C_Get_Perz_Data%FOUND) THEN
				x_data_attrib_tbl(l_count).PERZ_DATA_ATTRIB_ID := l_PERZ_DATA_ATTRIB_ID_temp;
				x_data_attrib_tbl(l_count).PERZ_DATA_ID := l_PERZ_DATA_ID_temp;
				x_data_attrib_tbl(l_count).ATTRIBUTE_NAME := l_ATTRIBUTE_NAME_temp;
				x_data_attrib_tbl(l_count).ATTRIBUTE_TYPE := l_ATTRIBUTE_TYPE_temp;
				x_data_attrib_tbl(l_count).ATTRIBUTE_VALUE := l_ATTRIBUTE_VALUE_temp;
				x_data_attrib_tbl(l_count).ATTRIBUTE_CONTEXT := l_ATTRIBUTE_CONTEXT_temp;
				l_count := l_count +1;

			END IF;
		END LOOP;
		CLOSE C_Get_Perz_Data;
      		x_return_status := FND_API.G_RET_STS_SUCCESS;

	else
		-- Currently, this API supports only One PerzData Object
		-- If there are more than one retrieved then, this results in an error
		-- This is a limitation because of Java Layer cannot support more than
		-- one PerzData.

        	 RAISE FND_API.G_EXC_ERROR;
	end if;
      end if;


-- ******** Standard Ends ***********
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count     =>      x_msg_count,
        		      p_data      =>      x_msg_data );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count   =>      x_msg_count,
	  			     p_data    =>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count      =>      x_msg_count,
        	  		     p_data       =>      x_msg_data );

    WHEN OTHERS THEN

	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

	FND_MSG_PUB.Count_And_Get( p_count      =>      x_msg_count,
        	  		  p_data        =>      x_msg_data );



END Get_Perz_Data;
-- *****************************************************************************

PROCEDURE Get_Perz_Data_Summary
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id       	IN	NUMBER,
	p_profile_name     	IN	VARCHAR2,
	p_perz_data_id          IN NUMBER,
	p_perz_data_name        IN VARCHAR2,
	p_perz_data_type	IN VARCHAR2 := NULL,

	x_data_out_tbl OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_DATA_PUB.DATA_OUT_TBL_TYPE,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

	--******** Get_Perz_Data_Summary local variable for standards **********
     	l_api_name		 CONSTANT VARCHAR2(30)	:= 'Create PerzData';
	l_api_version_number	NUMBER 	:= p_api_version_number;

       -- ******* Get_Perz_Data_Summary Local Variables ********
  	l_profile_id 		NUMBER  := p_profile_id;
  	l_profile_name 		VARCHAR2(60):= p_profile_name;
  	l_return_status 	VARCHAR2(240):= FND_API.G_TRUE;
	l_count			NUMBER		:= NULL;

	-- Temporary Variables
--	SMATTEGU	Enhancement #1181062 Begin
	l_perz_data_temp_rec JTF_PERZ_DATA_PUB.DATA_OUT_REC_TYPE;
	-- Instead of individual temp variables, this will be referred in the select
	--	into statements etc.
--	SMATTEGU	Enhancement #1181062 End
/*
	l_perz_data_id_temp number;
	l_profile_id_temp NUMBER;
	l_application_id_temp NUMBER;
	l_perz_data_name_temp VARCHAR2(60);
	l_perz_data_type_temp VARCHAR2(30);
	l_perz_data_desc_temp VARCHAR2(240);
*/
     -- cursors

     CURSOR C_Get_Perz_Summary (p_profile_id NUMBER, p_application_id NUMBER) IS
     SELECT  perz_data_id, Profile_ID, Application_id, perz_data_name,
		 perz_data_type, perz_data_desc
     FROM    jtf_perz_data
     WHERE   Profile_ID = p_profile_id AND
	Application_ID = p_application_id;

     CURSOR C_Get_Perz_Summary_pzdid (p_perz_data_id NUMBER ) IS
     SELECT  perz_data_id, Profile_ID, Application_id, perz_data_name,
		perz_data_type, perz_data_desc
     FROM    jtf_perz_data
     WHERE   perz_data_id = p_perz_data_id;

     CURSOR C_Get_Perz_Summary_pzdn (p_perz_data_name VARCHAR2,
		p_profile_id NUMBER, p_application_id NUMBER) IS
     SELECT  perz_data_id, Profile_ID, Application_id, perz_data_name,
		perz_data_type, perz_data_desc
     FROM    jtf_perz_data
     WHERE   perz_data_name = p_perz_data_name AND
	Profile_ID = p_profile_id AND
	Application_ID = p_application_id;

     CURSOR C_Get_Perz_Summary_pzdt (p_perz_data_type VARCHAR2,
		p_profile_id NUMBER, p_application_id NUMBER) IS
     SELECT  perz_data_id, Profile_ID, Application_id, perz_data_name,
		perz_data_type, perz_data_desc
     FROM    jtf_perz_data
     WHERE   perz_data_type = p_perz_data_type AND
	Profile_ID = p_profile_id AND
	Application_ID = p_application_id;

--	SMATTEGU	Enhancement #1165283 BEGINS

     CURSOR C_Get_Perz_Summary_pzdnt (p_perz_data_name VARCHAR2,
	p_perz_data_type VARCHAR2, p_profile_id NUMBER,
	p_application_id NUMBER) IS
     SELECT  perz_data_id, Profile_ID, Application_id, perz_data_name,
		perz_data_type, perz_data_desc
     FROM    jtf_perz_data
     WHERE    perz_data_name = p_perz_data_name AND
	perz_data_type = p_perz_data_type AND
	Profile_ID = p_profile_id AND
	Application_ID = p_application_id;

--	SMATTEGU	Enhancement #1165283 ENDS

BEGIN
       -- ******* Standard Begins ********

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call
--		( l_api_version_number,
--		p_api_version_number, l_api_name, G_PKG_NAME)
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


  if ((p_perz_data_id IS NOT NULL) AND
	(p_perz_data_id <> FND_API.G_MISS_NUM)) then
	l_perz_data_temp_rec := NULL;
/*
	l_perz_data_id_temp	:= NULL;
	l_profile_id_temp	:= NULL;
	l_application_id_temp := NULL;
	l_perz_data_name_temp := NULL;
	l_perz_data_type_temp := NULL;
	l_perz_data_desc_temp := NULL;
*/
  	l_count := 1;

	OPEN  C_Get_Perz_Summary_pzdid(p_perz_data_id);

  	LOOP
		FETCH C_Get_Perz_Summary_pzdid INTO
			l_perz_data_temp_rec.perz_data_id,
			l_perz_data_temp_rec.profile_id,
			l_perz_data_temp_rec.application_id,
			l_perz_data_temp_rec.perz_data_name,
			l_perz_data_temp_rec.perz_data_type,
			l_perz_data_temp_rec.perz_data_desc;
		EXIT WHEN C_Get_Perz_Summary_pzdid%NOTFOUND;
		IF ( C_Get_Perz_Summary_pzdid%FOUND = TRUE ) THEN
			x_data_out_tbl(l_count).perz_data_id	:=  l_perz_data_temp_rec.perz_data_id;
			x_data_out_tbl(l_count).profile_id 	:= l_perz_data_temp_rec.profile_id;
			x_data_out_tbl(l_count).application_id := l_perz_data_temp_rec.application_id;
			x_data_out_tbl(l_count).perz_data_name := l_perz_data_temp_rec.perz_data_name;
			x_data_out_tbl(l_count).perz_data_type := l_perz_data_temp_rec.perz_data_type;
			x_data_out_tbl(l_count).perz_data_desc := l_perz_data_temp_rec.perz_data_desc;
			l_count := l_count + 1;
		END IF;
 	END LOOP;
	CLOSE  C_Get_Perz_Summary_pzdid;
      	x_return_status := FND_API.G_RET_STS_SUCCESS;

  else

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

	if (((l_profile_id IS NOT NULL) AND
		(l_profile_id <> FND_API.G_MISS_NUM)) AND
		((p_application_id IS NOT NULL) AND
		(p_application_id <> FND_API.G_MISS_NUM))) then

		if ((p_perz_data_name IS NOT NULL) AND
			(p_perz_data_name <> FND_API.G_MISS_CHAR)) then

		--	SMATTEGU	Enhancement #1165283 BEGINS

			if ((p_perz_data_type IS NOT NULL) AND
			(p_perz_data_type <> FND_API.G_MISS_CHAR)) then

				l_perz_data_temp_rec := NULL;
/*
				l_perz_data_id_temp   := NULL;
				l_perz_data_name_temp := NULL;
				l_perz_data_type_temp := NULL;
				l_perz_data_desc_temp := NULL;
				l_application_id_temp := NULL;
				l_profile_id_temp		:= NULL;
*/
  				l_count := 1;
   				OPEN C_Get_Perz_Summary_pzdnt
				(p_perz_data_name,p_perz_data_type,
				 l_profile_id, p_application_id);
				LOOP
					FETCH C_Get_Perz_Summary_pzdnt INTO
						l_perz_data_temp_rec.perz_data_id,
						l_perz_data_temp_rec.profile_id,
						l_perz_data_temp_rec.application_id,
						l_perz_data_temp_rec.perz_data_name,
						l_perz_data_temp_rec.perz_data_type,
						l_perz_data_temp_rec.perz_data_desc;
					EXIT WHEN C_Get_Perz_Summary_pzdnt%NOTFOUND;
					IF (C_Get_Perz_Summary_pzdnt%FOUND = TRUE) THEN
						x_data_out_tbl(l_count).perz_data_id	:=  l_perz_data_temp_rec.perz_data_id;
						x_data_out_tbl(l_count).profile_id 	:= l_perz_data_temp_rec.profile_id;
						x_data_out_tbl(l_count).application_id := l_perz_data_temp_rec.application_id;
						x_data_out_tbl(l_count).perz_data_name := l_perz_data_temp_rec.perz_data_name;
						x_data_out_tbl(l_count).perz_data_type := l_perz_data_temp_rec.perz_data_type;
						x_data_out_tbl(l_count).perz_data_desc := l_perz_data_temp_rec.perz_data_desc;
           				l_count := l_count + 1;
					END IF;
 				END LOOP;
				CLOSE C_Get_Perz_Summary_pzdnt ;
      				x_return_status := FND_API.G_RET_STS_SUCCESS;
			else
				l_perz_data_temp_rec := NULL;
/*

				l_perz_data_id_temp   := NULL;
				l_perz_data_name_temp := NULL;
				l_perz_data_type_temp := NULL;
				l_perz_data_desc_temp := NULL;
				l_application_id_temp := NULL;
				l_profile_id_temp		:= NULL;
*/
  				l_count := 1;
   				OPEN C_Get_Perz_Summary_pzdn (p_perz_data_name,
				 l_profile_id, p_application_id);
				LOOP
					FETCH C_Get_Perz_Summary_pzdn INTO
						l_perz_data_temp_rec.perz_data_id,
						l_perz_data_temp_rec.profile_id,
						l_perz_data_temp_rec.application_id,
						l_perz_data_temp_rec.perz_data_name,
						l_perz_data_temp_rec.perz_data_type,
						l_perz_data_temp_rec.perz_data_desc;
					EXIT WHEN C_Get_Perz_Summary_pzdn%NOTFOUND;
					IF (C_Get_Perz_Summary_pzdn%FOUND = TRUE) THEN
						x_data_out_tbl(l_count).perz_data_id	:=  l_perz_data_temp_rec.perz_data_id;
						x_data_out_tbl(l_count).profile_id 	:= l_perz_data_temp_rec.profile_id;
						x_data_out_tbl(l_count).application_id := l_perz_data_temp_rec.application_id;
						x_data_out_tbl(l_count).perz_data_name := l_perz_data_temp_rec.perz_data_name;
						x_data_out_tbl(l_count).perz_data_type := l_perz_data_temp_rec.perz_data_type;
						x_data_out_tbl(l_count).perz_data_desc := l_perz_data_temp_rec.perz_data_desc;
           				l_count := l_count + 1;
					END IF;
 				END LOOP;
				CLOSE C_Get_Perz_Summary_pzdn ;
      				x_return_status := FND_API.G_RET_STS_SUCCESS;
			end if;

		--	SMATTEGU	Enhancement #1165283 ENDS

		elsif((p_perz_data_type IS NOT NULL) AND
			(p_perz_data_type <> FND_API.G_MISS_CHAR)) then
			l_perz_data_temp_rec := NULL;
/*
			l_perz_data_id_temp   := NULL;
			l_perz_data_name_temp := NULL;
			l_perz_data_type_temp := NULL;
			l_perz_data_desc_temp := NULL;
			l_application_id_temp := NULL;
			l_profile_id_temp		:= NULL;
*/
  			l_count := 1;
   			OPEN C_Get_Perz_Summary_pzdt (p_perz_data_type,
				 l_profile_id, p_application_id);
			LOOP
				FETCH C_Get_Perz_Summary_pzdt INTO
					l_perz_data_temp_rec.perz_data_id,
					l_perz_data_temp_rec.profile_id,
					l_perz_data_temp_rec.application_id,
					l_perz_data_temp_rec.perz_data_name,
					l_perz_data_temp_rec.perz_data_type,
					l_perz_data_temp_rec.perz_data_desc;
				EXIT WHEN C_Get_Perz_Summary_pzdt%NOTFOUND;
				IF (C_Get_Perz_Summary_pzdt%FOUND = TRUE) THEN
					x_data_out_tbl(l_count).perz_data_id	:=  l_perz_data_temp_rec.perz_data_id;
					x_data_out_tbl(l_count).profile_id 	:= l_perz_data_temp_rec.profile_id;
					x_data_out_tbl(l_count).application_id := l_perz_data_temp_rec.application_id;
					x_data_out_tbl(l_count).perz_data_name := l_perz_data_temp_rec.perz_data_name;
					x_data_out_tbl(l_count).perz_data_type := l_perz_data_temp_rec.perz_data_type;
					x_data_out_tbl(l_count).perz_data_desc := l_perz_data_temp_rec.perz_data_desc;
           			l_count := l_count + 1;
				END IF;
 			END LOOP;
			CLOSE C_Get_Perz_Summary_pzdt ;
      			x_return_status := FND_API.G_RET_STS_SUCCESS;

		else
			l_perz_data_temp_rec := NULL;
/*
			l_perz_data_id_temp	:= NULL;
		    	l_perz_data_name_temp := NULL;
			l_perz_data_type_temp := NULL;
			l_perz_data_desc_temp := NULL;
			l_application_id_temp := NULL;
			l_profile_id_temp		:= NULL;
*/
  			l_count := 1;
   			OPEN C_Get_Perz_Summary(l_profile_id, p_application_id);
			LOOP
				FETCH C_Get_Perz_Summary 	into
					l_perz_data_temp_rec.perz_data_id,
					l_perz_data_temp_rec.profile_id,
					l_perz_data_temp_rec.application_id,
					l_perz_data_temp_rec.perz_data_name,
					l_perz_data_temp_rec.perz_data_type,
					l_perz_data_temp_rec.perz_data_desc;
				EXIT WHEN C_Get_Perz_Summary%NOTFOUND;
				IF ( C_Get_Perz_Summary%FOUND) THEN
					x_data_out_tbl(l_count).perz_data_id	:=  l_perz_data_temp_rec.perz_data_id;
					x_data_out_tbl(l_count).profile_id 	:= l_perz_data_temp_rec.profile_id;
					x_data_out_tbl(l_count).application_id := l_perz_data_temp_rec.application_id;
					x_data_out_tbl(l_count).perz_data_name := l_perz_data_temp_rec.perz_data_name;
					x_data_out_tbl(l_count).perz_data_type := l_perz_data_temp_rec.perz_data_type;
					x_data_out_tbl(l_count).perz_data_desc := l_perz_data_temp_rec.perz_data_desc;
           				l_count := l_count + 1;
				END IF;
 			END LOOP;
			CLOSE C_Get_Perz_Summary;
      			x_return_status := FND_API.G_RET_STS_SUCCESS;
 		end if;
  	end if;
  end if;



-- ******** Standard Ends ***********
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count     =>      x_msg_count,
        		      p_data      =>      x_msg_data );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count   =>      x_msg_count,
	  			     p_data    =>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count      =>      x_msg_count,
        	  		     p_data       =>      x_msg_data );

    WHEN OTHERS THEN

	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

	FND_MSG_PUB.Count_And_Get( p_count      =>      x_msg_count,
        	  		  p_data        =>      x_msg_data );


END Get_Perz_Data_Summary;
-- *****************************************************************************
--


PROCEDURE Update_Perz_Data
(	p_api_version_number	IN NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN VARCHAR	:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id   		IN NUMBER,

	p_perz_data_id          IN NUMBER,
	p_perz_data_name        IN VARCHAR2,
	p_perz_data_type	IN VARCHAR2 := NULL,
	p_perz_data_desc	IN VARCHAR2,
	p_data_attrib_tbl	IN JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
				:= JTF_PERZ_DATA_PUB.G_MISS_DATA_ATTRIB_TBL,

	x_perz_data_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

	--******** Update_Perz_Data local variable for standards **********
     	l_api_name		 CONSTANT VARCHAR2(30)	:= 'Update PerzData';
	l_api_version_number	NUMBER 	:= p_api_version_number;

       -- ******* Update_Perz_Data Local Variables ********
	l_perz_data_id		NUMBER := p_perz_data_id;
	l_PERZ_DATA_ATTRIB_ID	NUMBER := NULL;
     	l_is_duplicate		VARCHAR2(1) := FND_API.G_FALSE;
	l_curr_row		NUMBER		:= NULL;
	l_object_version_number NUMBER := NULL;


BEGIN
       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	UPDATE_PERZ_DATA_PVT;

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call
--		( l_api_version_number,
--		p_api_version_number, l_api_name, G_PKG_NAME)
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


-- CALL FLOW
-- 1. Select Perz Data ID from database
-- 2. Delete all the attributes for that Perz Data ID
-- 3. Update Perz Data header information
-- 4. Insert all new rocords from input.



-- 1. CHECK IF DUPLICATE  EXISTS
-- the duplicacy is defined as having the same perz data  name
--	for the a profile id within an application id.

	check_perz_data (
		p_perz_data_name,
		p_application_id,
		p_profile_id,
		p_perz_data_type,
		l_is_duplicate,
		l_perz_data_id,
		l_object_version_number
	);

	IF (FND_API.To_Boolean(l_is_duplicate)) THEN
		-- 2. Delete all the attributes for that Perz Data ID

		DELETE  FROM JTF_PERZ_DATA_ATTRIB WHERE
			PERZ_DATA_ID = l_perz_data_id;

		-- 3. Update Perz Data header information
		update_jtf_perz_data(
          		l_perz_data_id,
          		p_PROFILE_ID,
          		p_APPLICATION_ID,
          		p_PERZ_DATA_NAME,
          		p_PERZ_DATA_TYPE,
          		p_PERZ_DATA_DESC,
			l_object_version_number);


		-- 4. Insert all new rocords from input.

   		IF (p_data_attrib_tbl.COUNT > 0) THEN
      			FOR l_curr_row in 1..p_data_attrib_tbl.COUNT LOOP

				l_PERZ_DATA_ATTRIB_ID :=p_data_attrib_tbl(l_curr_row).PERZ_DATA_ATTRIB_ID ;
				insert_jtf_perz_data_attrib(
        				l_PERZ_DATA_ATTRIB_ID,
					l_perz_data_id,
					p_data_attrib_tbl(l_curr_row).ATTRIBUTE_NAME,
					p_data_attrib_tbl(l_curr_row).ATTRIBUTE_TYPE,
					p_data_attrib_tbl(l_curr_row).ATTRIBUTE_VALUE,
					p_data_attrib_tbl(l_curr_row).ATTRIBUTE_CONTEXT);
			END LOOP;
		END IF;
	ELSE
		-- the perz data id does not exist
		x_return_status := FND_API.G_RET_STS_ERROR ;
          	RAISE FND_API.G_EXC_ERROR;
	END IF;


-- copying ID to output.

   x_perz_data_id := l_perz_data_id;


-- ******** Standard Ends ***********
--
-- End of main API body.

   -- Standard check of p_commit.
   IF (FND_API.To_Boolean(p_commit)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count     =>      x_msg_count,
        		      p_data      =>      x_msg_data );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO UPDATE_PERZ_DATA_PVT;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count   =>      x_msg_count,
	  			     p_data    =>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  ROLLBACK TO UPDATE_PERZ_DATA_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count      =>      x_msg_count,
        	  		     p_data       =>      x_msg_data );

    WHEN OTHERS THEN
	  ROLLBACK TO UPDATE_PERZ_DATA_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

	FND_MSG_PUB.Count_And_Get( p_count      =>      x_msg_count,
        	  		  p_data        =>      x_msg_data );

END Update_Perz_Data;

-- *****************************************************************************

PROCEDURE Delete_Perz_Data
(	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN VARCHAR	 := FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        	IN NUMBER,
	p_perz_data_id          IN NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

	--******** Update_Perz_Data local variable for standards **********
     	l_api_name		 CONSTANT VARCHAR2(30)	:= 'Create PerzData';
	l_api_version_number	NUMBER 	:= p_api_version_number;

       -- ******* Update_Perz_Data Local Variables ********
--	l_perz_data_id		NUMBER := p_perz_data_id;
BEGIN

       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	DELETE_PERZ_DATA_PVT;

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call
--		( l_api_version_number,
--		p_api_version_number, l_api_name, G_PKG_NAME)
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


-- CALL FLOW
--1 Delete all the attributes
--2 Delete the Perz Data

	DELETE  FROM JTF_PERZ_DATA_ATTRIB WHERE
		PERZ_DATA_ID = p_perz_data_id;
	DELETE  FROM JTF_PERZ_DATA WHERE
		PERZ_DATA_ID = p_perz_data_id;


-- ******** Standard Ends ***********
--
-- End of main API body.

   -- Standard check of p_commit.
   IF (FND_API.To_Boolean(p_commit)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count     =>      x_msg_count,
        		      p_data      =>      x_msg_data );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO DELETE_PERZ_DATA_PVT;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count   =>      x_msg_count,
	  			     p_data    =>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  ROLLBACK TO DELETE_PERZ_DATA_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get( p_count      =>      x_msg_count,
        	  		     p_data       =>      x_msg_data );

    WHEN OTHERS THEN
	  ROLLBACK TO DELETE_PERZ_DATA_PVT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

	FND_MSG_PUB.Count_And_Get( p_count      =>      x_msg_count,
        	  		  p_data        =>      x_msg_data );


END Delete_Perz_Data;

-- *****************************************************************************



-- *****************************************************************************
-- *****************************************************************************
END  JTF_PERZ_DATA_PVT;

/
