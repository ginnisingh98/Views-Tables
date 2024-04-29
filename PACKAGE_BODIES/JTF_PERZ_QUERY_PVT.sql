--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_QUERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_QUERY_PVT" AS
/* $Header: jtfzvpqb.pls 120.2 2005/11/02 22:47:16 skothe ship $ */
--
--
--
-- Start of Comments
--
-- NAME
--   Jtf_Perz_Query_Pvt
--
-- PURPOSE
--   Private API for saving, retrieving and updating personalized queries.
--
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for saving, retrieving and updating personalized queries
--	 within the personalization framework.
--

-- HISTORY
--	4/18/2000	SMATTEGU	Created

-- *****************************************************************************

G_PKG_NAME  	CONSTANT VARCHAR2(30):='Jtf_Perz_Query_Pvt';
G_FILE_NAME   	CONSTANT VARCHAR2(12):='jtfzvpqb.pls';
G_LOGIN_ID	NUMBER := Fnd_Global.CONC_LOGIN_ID;
G_USER_ID	NUMBER := Fnd_Global.USER_ID;


-- *****************************************************************************
-- *****************************************************************************
--	TABLE HANDLERS
--	1. insert_jtf_perz_query
--	2. insert_jtf_perz_query_order_by
--	3. insert_jtf_perz_query_param
--	4. insert_jtf_perz_query_raw_sql
--	5. update_jtf_perz_query

-- *****************************************************************************
-- *****************************************************************************


PROCEDURE update_jtf_perz_query(
	p_QUERY_ID    	NUMBER,
     p_PROFILE_ID    	NUMBER,
     p_APPLICATION_ID    	NUMBER,
     p_QUERY_NAME    	VARCHAR2,
	p_QUERY_TYPE    	VARCHAR2,
     p_QUERY_DESCRIPTION   VARCHAR2,
     p_QUERY_DATA_SOURCE   VARCHAR2,
	p_OBJECT_VERSION_NUMBER IN	NUMBER)

 IS
 BEGIN
    UPDATE JTF_PERZ_QUERY
    SET
	QUERY_TYPE =
		DECODE( p_QUERY_TYPE, Fnd_Api.G_MISS_CHAR, QUERY_TYPE, p_QUERY_TYPE),
    QUERY_DESCRIPTION =
    	DECODE( p_QUERY_DESCRIPTION, Fnd_Api.G_MISS_CHAR, QUERY_DESCRIPTION,
			p_QUERY_DESCRIPTION),
    QUERY_DATA_SOURCE =
		DECODE( p_QUERY_DATA_SOURCE, Fnd_Api.G_MISS_CHAR, QUERY_DATA_SOURCE,
			p_QUERY_DATA_SOURCE),
	OBJECT_VERSION_NUMBER =
		DECODE (p_OBJECT_VERSION_NUMBER, Fnd_Api.G_MISS_NUM,
					OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER+1),
	LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATED_BY  = Fnd_Global.USER_ID,
	LAST_UPDATE_LOGIN = Fnd_Global.CONC_LOGIN_ID
    WHERE QUERY_ID = p_QUERY_ID
	AND OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER;

    IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END update_jtf_perz_query;

-- *****************************************************************************
-- insert row into query header

PROCEDURE insert_jtf_perz_query(
        x_Rowid                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
        X_QUERY_ID           IN OUT NOCOPY /* file.sql.39 change */     NUMBER,
        x_PROFILE_ID                    NUMBER,
        x_APPLICATION_ID                NUMBER,
        x_QUERY_NAME                    VARCHAR2,
	X_QUERY_TYPE                    VARCHAR2,
        X_QUERY_DESCRIPTION             VARCHAR2,
        X_QUERY_DATA_SOURCE             VARCHAR2
 ) IS
   CURSOR C IS SELECT ROWID FROM JTF_PERZ_QUERY
            WHERE QUERY_ID = x_QUERY_ID;

   CURSOR C2 IS SELECT JTF_PERZ_QUERY_S.NEXTVAL FROM sys.dual;

BEGIN
   IF ((x_QUERY_ID IS NULL) OR
	(x_QUERY_ID = Fnd_Api.G_MISS_NUM)) THEN
       OPEN C2;
       FETCH C2 INTO x_QUERY_ID;
       CLOSE C2;
   END IF;
   INSERT INTO JTF_PERZ_QUERY(
     QUERY_ID,
     PROFILE_ID,
     APPLICATION_ID,
     QUERY_NAME,
	QUERY_TYPE,
     QUERY_DESCRIPTION,
     QUERY_DATA_SOURCE,
	OBJECT_VERSION_NUMBER,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
   ) VALUES
   (
	x_QUERY_ID,
	DECODE( x_PROFILE_ID, Fnd_Api.G_MISS_NUM, NULL ,x_PROFILE_ID ),
	DECODE( x_APPLICATION_ID, Fnd_Api.G_MISS_NUM, NULL ,x_APPLICATION_ID ),
	DECODE( x_QUERY_NAME, Fnd_Api.G_MISS_CHAR, NULL ,x_QUERY_NAME ),
	DECODE( x_QUERY_TYPE, Fnd_Api.G_MISS_CHAR, NULL ,x_QUERY_TYPE ),
	DECODE( x_QUERY_DESCRIPTION, Fnd_Api.G_MISS_CHAR, NULL ,x_QUERY_DESCRIPTION ),
	DECODE( x_QUERY_DATA_SOURCE, Fnd_Api.G_MISS_CHAR, NULL ,x_QUERY_DATA_SOURCE ),
	   1, G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID);
   OPEN C;
   FETCH C INTO x_Rowid;
   IF (C%NOTFOUND) THEN
       CLOSE C;
       RAISE NO_DATA_FOUND;
   END IF;
END insert_jtf_perz_query;

-- *****************************************************************************

-- insert row into query header

PROCEDURE insert_jtf_perz_query_order_by(
                  X_ROWID                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                  X_QUERY_ORDER_BY_ID     IN OUT NOCOPY /* file.sql.39 change */        NUMBER,
                  X_QUERY_ID                      NUMBER,
                  X_PARAMETER_NAME                VARCHAR2,
                  X_ACND_DCND_FLAG                VARCHAR2,
                  X_PARAMETER_SEQUENCE            NUMBER
 ) IS
   CURSOR C IS SELECT ROWID FROM JTF_PERZ_QUERY_ORDER_BY
            WHERE QUERY_ORDER_BY_ID = x_QUERY_ORDER_BY_ID;

   CURSOR C2 IS SELECT JTF_PERZ_QUERY_ORDER_BY_s.NEXTVAL FROM sys.dual;

BEGIN
   IF (x_QUERY_ORDER_BY_ID IS NULL) THEN
       OPEN C2;
       FETCH C2 INTO x_QUERY_ORDER_BY_ID;
       CLOSE C2;
   END IF;
   INSERT INTO JTF_PERZ_QUERY_ORDER_BY(
	QUERY_ORDER_BY_ID,
	QUERY_ID,
	PARAMETER_NAME,
	ACND_DCND_FLAG,
	PARAMETER_SEQUENCE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
   ) VALUES (
	x_QUERY_ORDER_BY_ID,
	x_QUERY_ID,
	DECODE( x_PARAMETER_NAME, Fnd_Api.G_MISS_CHAR, NULL ,x_PARAMETER_NAME ),
	DECODE( x_ACND_DCND_FLAG, Fnd_Api.G_MISS_CHAR, NULL ,x_ACND_DCND_FLAG ),
	DECODE( x_PARAMETER_SEQUENCE, Fnd_Api.G_MISS_NUM, NULL ,x_PARAMETER_SEQUENCE ),
	G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID
  );
   OPEN C;
   FETCH C INTO x_Rowid;
   IF (C%NOTFOUND) THEN
       CLOSE C;
       RAISE NO_DATA_FOUND;
   END IF;
END insert_jtf_perz_query_order_by;

-- *****************************************************************************

-- insert row into query order by

PROCEDURE insert_jtf_perz_query_raw_sql(
          x_Rowid                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
          X_Query_Raw_Sql_ID      IN OUT NOCOPY /* file.sql.39 change */        NUMBER,
          x_Query_ID                      NUMBER,
          x_Select_String                 VARCHAR2,
	X_From_String                   VARCHAR2,
        X_Where_String                  VARCHAR2,
        X_Order_by_String               VARCHAR2,
        X_Group_by_String               VARCHAR2,
        X_Having_String                 VARCHAR2
 ) IS
   CURSOR C IS SELECT ROWID FROM JTF_PERZ_QUERY_RAW_SQL
            WHERE Query_Raw_Sql_ID = X_Query_Raw_Sql_ID;
   CURSOR C2 IS SELECT JTF_PERZ_QUERY_RAW_SQL_s.NEXTVAL FROM sys.dual;

BEGIN
   IF ((X_Query_Raw_Sql_ID IS NULL) OR
	(X_Query_Raw_Sql_ID = Fnd_Api.G_MISS_NUM ))THEN
       OPEN C2;
       FETCH C2 INTO X_Query_Raw_Sql_ID;
       CLOSE C2;
   END IF;
   INSERT INTO JTF_PERZ_QUERY_RAW_SQL(
	QUERY_RAW_SQL_ID,
        QUERY_ID,
        SELECT_STRING,
	FROM_STRING,
        WHERE_STRING,
        ORDER_BY_STRING,
        GROUP_BY_STRING,
        HAVING_STRING,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
   ) VALUES (
        x_QUERY_RAW_SQL_ID,
        x_QUERY_ID,
        DECODE( x_SELECT_STRING, Fnd_Api.G_MISS_CHAR, NULL ,x_SELECT_STRING ),
        DECODE( x_FROM_STRING, Fnd_Api.G_MISS_CHAR, NULL ,x_FROM_STRING ),
        DECODE( x_WHERE_STRING, Fnd_Api.G_MISS_CHAR, NULL ,x_WHERE_STRING ),
        DECODE( x_ORDER_BY_STRING, Fnd_Api.G_MISS_CHAR, NULL ,x_ORDER_BY_STRING ),
	DECODE( x_GROUP_BY_STRING, Fnd_Api.G_MISS_CHAR, NULL ,x_GROUP_BY_STRING ),
        DECODE( x_HAVING_STRING, Fnd_Api.G_MISS_CHAR, NULL ,x_HAVING_STRING ),
	G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID
   );
   OPEN C;
   FETCH C INTO x_Rowid;
   IF (C%NOTFOUND) THEN
       CLOSE C;
       RAISE NO_DATA_FOUND;
   END IF;
END insert_jtf_perz_query_raw_sql;
-- *****************************************************************************

PROCEDURE insert_jtf_perz_query_param(
	x_Rowid                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	X_query_param_id      IN OUT NOCOPY /* file.sql.39 change */        NUMBER,
	x_Query_ID                      NUMBER,
	x_Parameter_Name                 VARCHAR2,
	X_Parameter_Type                   VARCHAR2,
	X_Parameter_Value                  VARCHAR2,
	X_Parameter_condition               VARCHAR2,
	X_Parameter_sequence               VARCHAR2
 ) IS
   CURSOR C IS SELECT ROWID FROM JTF_PERZ_QUERY_PARAM
            WHERE query_param_id = X_query_param_id;
   CURSOR C2 IS SELECT JTF_PERZ_QUERY_PARAM_s.NEXTVAL FROM sys.dual;
BEGIN
   IF ((X_query_param_id IS NULL) OR
   (X_query_param_id = Fnd_Api.G_MISS_NUM)) THEN
       OPEN C2;
       FETCH C2 INTO X_query_param_id;
       CLOSE C2;
   END IF;
   INSERT INTO JTF_PERZ_QUERY_PARAM(
	QUERY_PARAM_ID,
	QUERY_ID,
	PARAMETER_NAME,
	PARAMETER_TYPE,
	PARAMETER_VALUE,
	PARAMETER_CONDITION,
	PARAMETER_SEQUENCE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
   ) VALUES (
	x_QUERY_PARAM_ID,
	x_QUERY_ID,
	DECODE( x_PARAMETER_NAME, Fnd_Api.G_MISS_CHAR, NULL ,x_PARAMETER_NAME ),
	DECODE( x_PARAMETER_TYPE, Fnd_Api.G_MISS_CHAR, NULL ,x_PARAMETER_TYPE ),
	DECODE( x_PARAMETER_VALUE, Fnd_Api.G_MISS_CHAR, NULL ,x_PARAMETER_VALUE ),
	DECODE( x_PARAMETER_CONDITION, Fnd_Api.G_MISS_CHAR, NULL ,x_PARAMETER_CONDITION ),
	DECODE( x_PARAMETER_SEQUENCE, Fnd_Api.G_MISS_CHAR, NULL ,x_PARAMETER_SEQUENCE ),
	G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID
   );
   OPEN C;
   FETCH C INTO x_Rowid;
   IF (C%NOTFOUND) THEN
       CLOSE C;
       RAISE NO_DATA_FOUND;
   END IF;
END insert_jtf_perz_query_param;

-- ****************************************************************************
--******************************************************************************
--
--	APIs
--
-- 1.	Create_Perz_Query
-- 2.	Update_Perz_Query
-- 3.	Delete_Perz_Query
-- 4.	Get_Perz_Query_Summary
-- 5.	Save_Perz_Query
-- 6.	Get_Perz_Query
-- 7.	check_query_duplicates
--
--******************************************************************************
--******************************************************************************
--
-- PROCEDURE	check_query_duplicates()


PROCEDURE check_query_duplicates(
	p_query_name      IN   VARCHAR2,
	p_query_type      IN   VARCHAR2,
	p_application_id  IN   NUMBER,
	p_profile_id	  IN   NUMBER,
	x_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	x_query_id        OUT NOCOPY /* file.sql.39 change */  NUMBER,
	x_object_version_number OUT NOCOPY /* file.sql.39 change */ NUMBER
)
 IS
	l_temp_id NUMBER := NULL;

BEGIN

  IF ( ((p_query_name IS NOT NULL) AND (p_query_name <> Fnd_Api.G_MISS_CHAR)) AND
       ((p_query_type IS NOT NULL) AND (p_query_type <> Fnd_Api.G_MISS_CHAR)) )  THEN

--IF  (p_query_name IS NOT NULL) then

	SELECT query_id, object_version_number
	 INTO x_query_id , x_object_version_number
	FROM  JTF_PERZ_QUERY
	WHERE query_name = p_query_name AND
	      query_type = p_query_type AND
	      application_id = p_application_id AND
	      profile_id = p_profile_id;

	IF (x_query_id IS NOT NULL) THEN
		x_return_status := Fnd_Api.G_TRUE;
	ELSE
		x_return_status := Fnd_Api.G_FALSE;
	END IF;


-- ELSIF (((p_query_name IS NOT NULL) OR
--	(p_query_name <> Fnd_Api.G_MISS_CHAR)) AND
--	((x_query_id IS NULL) OR
--	(x_query_id = Fnd_Api.G_MISS_NUM)))THEN
--
--	SELECT query_id, object_version_number
--	 INTO x_query_id , x_object_version_number
--	FROM  JTF_PERZ_QUERY
--	WHERE query_name = p_query_name AND
--	      application_id = p_application_id AND
--	      profile_id = p_profile_id;
--
--	IF (x_query_id IS NOT NULL) THEN
--		x_return_status := Fnd_Api.G_TRUE;
--	ELSE
--		x_return_status := Fnd_Api.G_FALSE;
--	END IF;
--
--  ELSIF (((x_query_id IS NOT NULL) OR (x_query_id <> Fnd_Api.G_MISS_NUM)) AND
-- 	 ((p_query_name IS NULL) OR (p_query_name = Fnd_Api.G_MISS_CHAR))) THEN
--
--    SELECT Query_id, object_version_number
--	INTO l_temp_id , x_object_version_number
--	FROM JTF_PERZ_QUERY
--	WHERE query_id = x_query_id;
--
--	IF (l_temp_id IS NOT NULL) THEN
--		x_return_status := Fnd_Api.G_TRUE;
--		x_query_id := l_temp_id;
--	ELSE
--		x_return_status := Fnd_Api.G_FALSE;
--	END IF;
--
--  ELSIF (((p_query_name IS NOT NULL) OR (p_query_name <> Fnd_Api.G_MISS_CHAR)) AND
--	 ((x_query_id IS NOT NULL) OR (x_query_id <> Fnd_Api.G_MISS_NUM))) THEN
--
--    SELECT Query_id, object_version_number
--	INTO l_temp_id , x_object_version_number
--	FROM JTF_PERZ_QUERY
--	WHERE query_id = x_query_id;
--
--	IF (l_temp_id IS NOT NULL) THEN
--		x_return_status := Fnd_Api.G_TRUE;
--		x_query_id := l_temp_id;
--	ELSE
--		x_return_status := Fnd_Api.G_FALSE;
--	END IF;

  ELSE
	x_return_status := Fnd_Api.G_FALSE;

  END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_return_status := Fnd_Api.G_FALSE;
	WHEN OTHERS THEN
		x_return_status := Fnd_Api.G_FALSE;
END check_query_duplicates;

-- ****************************************************************************
--******************************************************************************

PROCEDURE Create_Perz_Query
( 	p_api_version_number	IN NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= Fnd_Api.G_FALSE,
	p_commit		IN VARCHAR2	:= Fnd_Api.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id		IN NUMBER,
	p_profile_name		IN VARCHAR2,

	p_query_id		IN NUMBER,
	p_query_name		IN VARCHAR2,
	p_query_type		IN VARCHAR2,
	p_query_desc		IN VARCHAR2,
	p_query_data_source	IN VARCHAR2,

	p_query_param_tbl	IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
			:= Jtf_Perz_Query_Pub.G_MISS_QUERY_PARAMETER_TBL,
    	p_query_order_by_tbl 	IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
			:= Jtf_Perz_Query_Pub.G_MISS_QUERY_ORDER_BY_TBL,
    	p_query_raw_sql_rec	 IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE,

	x_query_id             OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS

     l_query_param_tbl	  Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
						:= p_query_param_tbl;

     l_any_errors        BOOLEAN        := FALSE;
     l_any_row_errors    BOOLEAN        := FALSE;
     l_rowid             ROWID;
     l_return_status     VARCHAR2(240)    := Fnd_Api.G_RET_STS_SUCCESS;
     l_api_name		 CONSTANT VARCHAR2(30)	:= 'Create Perz Query';
     l_curr_row		NUMBER		:= NULL;
     l_query_name	VARCHAR2(60)	:= p_query_name;

     -- Variables for ids
     l_query_string	  		VARCHAR2(1) := NULL;
     l_active_flag	   		VARCHAR2(1)  := 'Y';
     l_profile_id			NUMBER := NULL;
     l_query_id				NUMBER;
	 l_query_order_by_id	NUMBER;
	 l_query_param_id		NUMBER;
	 l_Query_Raw_Sql_ID		NUMBER;
     l_profile_attrib_id	NUMBER;
     l_is_duplicate		 	VARCHAR2(1) := Fnd_Api.G_FALSE;
	l_object_version_number NUMBER :=NULL;

BEGIN
       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	CREATE_PERZ_QUERY_PVT;

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call (
--		l_api_version_number,
--		p_api_version_number,
--		l_api_name,
--		G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
          Fnd_Msg_Pub.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


--  CALL FLOW :
-- 1. check if duplicate exists if TRUE, return error
-- 2. if FALSE, do
-- 3. insert row with query data into query table
-- 4. pick query_id and cycle through parameters insert into parameter table
-- 5. pick query_id and cycle through order by insert into order by table
-- 6. pick query_id and cycle through raw SQL insert into raw SQL table


-- 1. CHECK IF DUPLICATE  EXISTS
-- the duplicacy is defined  having the same query name for the a profile id within an
-- application id.

 	check_query_duplicates (
		p_query_name,
		p_query_type,
		p_application_id,
		p_profile_id,
		l_is_duplicate,
		l_query_id,
		l_object_version_number
	);

	IF (Fnd_Api.To_Boolean(l_is_duplicate)) THEN
		x_return_status := Fnd_Api.G_RET_STS_ERROR ;
	        RAISE Fnd_Api.G_EXC_ERROR;
	END IF;

-- 3. insert row with query data into query table

	insert_jtf_perz_query(
		l_rowid,
		l_query_id,
        p_profile_id,
		p_application_id,
		p_query_name,
		p_query_type,
		p_query_desc,
		p_query_data_source
	);



-- 5. insert records into query orderby table


   IF (p_query_order_by_tbl.COUNT > 0) THEN
      FOR l_curr_row IN 1..p_query_order_by_tbl.COUNT LOOP

	l_rowid := NULL;
	l_query_order_by_id :=p_query_order_by_tbl(l_curr_row).query_order_by_id ;

	insert_jtf_perz_query_order_by(
		l_rowid,
	  	l_query_Order_By_ID,
		l_query_id,
		p_query_order_by_tbl(l_curr_row).Parameter_Name,
		p_query_order_by_tbl(l_curr_row).Acnd_Dcnd_Flag,
		p_query_order_by_tbl(l_curr_row).Parameter_sequence
	);


     END LOOP;
   END IF;


   -- insert records into query param table

   IF (p_query_param_tbl.COUNT > 0) THEN
      FOR l_curr_row IN 1..p_query_param_tbl.COUNT LOOP

	l_rowid := NULL;
	l_query_param_id := p_query_param_tbl(l_curr_row).query_param_id;

	insert_jtf_perz_query_param(
		l_rowid,
		l_query_param_id,
		l_query_id,
		p_query_param_tbl(l_curr_row).Parameter_Name,
		p_query_param_tbl(l_curr_row).Parameter_Type,
		p_query_param_tbl(l_curr_row).Parameter_Value,
		p_query_param_tbl(l_curr_row).Parameter_condition,
		p_query_param_tbl(l_curr_row).Parameter_sequence
	);
     END LOOP;
   END IF;

   -- insert records into query raw SQL table

   IF (p_query_raw_sql_rec.Select_String IS NOT NULL) THEN

	l_rowid := NULL;
	l_Query_Raw_Sql_ID := p_query_raw_sql_rec.Query_Raw_Sql_ID;

	insert_jtf_perz_query_raw_sql(
		l_rowid,
		l_Query_Raw_Sql_ID,
		l_query_id,
		p_query_raw_sql_rec.Select_String,
		p_query_raw_sql_rec.From_String,
		p_query_raw_sql_rec.Where_String,
		p_query_raw_sql_rec.Order_by_String,
		p_query_raw_sql_rec.Group_by_String,
		p_query_raw_sql_rec.Having_String
	);
   END IF;

-- copying ID to output.
   x_query_id := l_query_id;

-- ******** Standard Ends ***********
--
-- End of main API body.

   -- Standard check of p_commit.
   IF (Fnd_Api.To_Boolean(p_commit)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   Fnd_Msg_Pub.Count_And_Get(
	p_count       	=>      x_msg_count,
	p_data        	=>      x_msg_data );

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
	  ROLLBACK TO CREATE_PERZ_QUERY_PVT;
	  x_return_status := Fnd_Api.G_RET_STS_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get(
		p_count    	=>      x_msg_count,
		p_data       	=>      x_msg_data );

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
	  ROLLBACK TO CREATE_PERZ_QUERY_PVT;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
	  --x_return_status := SQLCODE||SUBSTR(SQLERRM,1,100);

	  Fnd_Msg_Pub.Count_And_Get(
		p_count       	=>      x_msg_count,
        	p_data        	=>      x_msg_data );

    WHEN OTHERS THEN
	  ROLLBACK TO CREATE_PERZ_QUERY_PVT;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  --x_return_status := SQLCODE||SUBSTR(SQLERRM,1,100);
	IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

	Fnd_Msg_Pub.Count_And_Get
	( p_count        	=>      x_msg_count,
	p_data          	=>      x_msg_data );

END Create_perz_query;

--******************************************************************************
PROCEDURE Update_Perz_Query
(	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= Fnd_Api.G_FALSE,
	p_commit		IN VARCHAR2		:= Fnd_Api.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        IN NUMBER,

	p_query_id           IN NUMBER,
	p_query_name         IN VARCHAR2,
	p_query_type         IN VARCHAR2,
	p_query_desc		 IN VARCHAR2,
	p_query_data_source  IN VARCHAR2,

	p_query_param_tbl	 IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
				 := Jtf_Perz_Query_Pub.G_MISS_QUERY_PARAMETER_TBL,
    p_query_order_by_tbl IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
				:= Jtf_Perz_Query_Pub.G_MISS_QUERY_ORDER_BY_TBL,
    p_query_raw_sql_rec	 IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE ,

	x_query_id          OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

	l_query_param_tbl	  Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
				:= p_query_param_tbl;

	l_api_version		NUMBER := 1.0;
	l_init_msg_list		VARCHAR2(240);
   	l_any_errors           BOOLEAN  := FALSE;
	l_any_row_errors       BOOLEAN  := FALSE;
	l_found_flag		BOOLEAN := FALSE;
	l_rowid               	ROWID;
	l_return_status        VARCHAR2(240)    := Fnd_Api.G_RET_STS_SUCCESS;
	l_api_name		CONSTANT VARCHAR2(30)	:= 'Update Perz Query';

	l_count			NUMBER  := NULL;
	l_msg_count		NUMBER := NULL;
	l_msg_data		VARCHAR2(200) := NULL;
	l_count_1	     	NUMBER  := NULL;
	l_curr_row		NUMBER	:= NULL;

	l_duplicate            VARCHAR2(240)    := Fnd_Api.G_FALSE;
	l_query_name		VARCHAR2(60)	:= p_query_name;

     -- Variables for ids
	l_query_string	  	VARCHAR2(1) := NULL;
	l_active_flag	   	VARCHAR2(1)  := 'Y';
	l_profile_id		NUMBER := NULL;
	l_query_id		NUMBER;
	l_Query_Order_By_ID	NUMBER;
 	l_query_param_id	NUMBER;
	l_Query_Raw_Sql_ID	NUMBER;
	l_profile_attrib_id	NUMBER;
	l_is_duplicate		VARCHAR2(1) := Fnd_Api.G_FALSE;
	l_profile_name		VARCHAR2(30) := NULL;
	l_object_version_number NUMBER :=NULL;

BEGIN
       -- ******* Standard Begins ********
	   -- Standard Start of API savepoint
      SAVEPOINT	UPDATE_PERZ_QUERY_PVT;

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
          Fnd_Msg_Pub.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


-- CALL FLOW
-- 1. Select query ID from databe
-- 2. Delete all parameters for that Query ID
-- 3. Delete all Order By records for that ID
-- 4. Delete all raw SQL records for that query ID
-- 5. Update query header information
-- 6. Insert all new rocords from input.


-- 1. getting query ID for query Name
   l_query_id := p_query_id;

      check_query_duplicates (
	p_query_name,
	p_query_type,
	p_application_id,
	p_profile_id,
	l_is_duplicate,
	l_query_id,
	l_object_version_number);


   IF (Fnd_Api.To_Boolean(l_is_duplicate)) THEN

	-- 2. Delete all parmeter table entries for this query_id

   	DELETE  FROM JTF_PERZ_QUERY_PARAM WHERE QUERY_ID = l_query_id;

	-- 3. Delete all order by table entries for this query_id
   	DELETE  FROM JTF_PERZ_QUERY_ORDER_BY WHERE QUERY_ID = l_query_id;

	-- 4. Delete all raw sql table entries for this query_id
   	DELETE  FROM JTF_PERZ_QUERY_RAW_SQL WHERE QUERY_ID = l_query_id;

	-- 5. Update query header information
   	-- **** UPDATE CALL HERE
		update_jtf_perz_query(
          		l_QUERY_ID,
          		p_PROFILE_ID,
          		p_APPLICATION_ID,
          		p_QUERY_NAME,
          		p_QUERY_TYPE,
          		p_QUERY_DESC,
          		p_QUERY_DATA_SOURCE,
			l_object_version_number);

	-- 6. Insert new data into the three different tables

   	IF (p_query_order_by_tbl.COUNT > 0) THEN
      		FOR l_curr_row IN 1..p_query_order_by_tbl.COUNT LOOP

			l_rowid := NULL;
			l_Query_Order_By_ID := p_query_order_by_tbl(l_curr_row).Query_Order_By_ID;

	  		insert_jtf_perz_query_order_by(l_rowid,
                		l_Query_Order_By_ID,
                		l_query_id,
                		p_query_order_by_tbl(l_curr_row).Parameter_Name,
                		p_query_order_by_tbl(l_curr_row).Acnd_Dcnd_Flag,
                		p_query_order_by_tbl(l_curr_row).Parameter_sequence );
     		END LOOP;
   	END IF;

   	IF (p_query_param_tbl.COUNT > 0) THEN
      		FOR l_curr_row IN 1..p_query_param_tbl.COUNT LOOP

			l_rowid := NULL;
			l_query_param_id := p_query_param_tbl(l_curr_row).query_param_id;

	  		insert_jtf_perz_query_param(
				l_rowid,
                		l_query_param_id,
                		l_query_id,
                		p_query_param_tbl(l_curr_row).Parameter_Name,
                		p_query_param_tbl(l_curr_row).Parameter_Type,
                		p_query_param_tbl(l_curr_row).Parameter_Value,
                		p_query_param_tbl(l_curr_row).Parameter_condition,
                		p_query_param_tbl(l_curr_row).Parameter_sequence );
     		END LOOP;
   	END IF;

	IF (p_query_raw_sql_rec.Select_String IS NOT NULL) THEN
		l_rowid := NULL;
		l_Query_Raw_Sql_ID := p_query_raw_sql_rec.Query_Raw_Sql_ID;
	  	insert_jtf_perz_query_raw_sql(
			l_rowid,
			l_Query_Raw_Sql_ID,
			l_query_id,
			p_query_raw_sql_rec.Select_String,
			p_query_raw_sql_rec.From_String,
			p_query_raw_sql_rec.Where_String,
			p_query_raw_sql_rec.Order_by_String,
			p_query_raw_sql_rec.Group_by_String,
			p_query_raw_sql_rec.Having_String
		);
   	END IF;
   	x_query_id := l_query_id;

   ELSE
	x_return_status := Fnd_Api.G_RET_STS_ERROR ;
          RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
--	  dbms_output.put_line('stop 1 ');

	  ROLLBACK TO UPDATE_PERZ_QUERY_PVT;
	  --x_return_status := FND_API.G_RET_STS_ERROR ;
	  x_return_status := SQLCODE||SUBSTR(SQLERRM,1,100);

	  Fnd_Msg_Pub.Count_And_Get(
		p_count    	=>      x_msg_count,
	  	p_data       	=>      x_msg_data );

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
--	  dbms_output.put_line('stop 2 ');
	  ROLLBACK TO UPDATE_PERZ_QUERY_PVT;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get(
		p_count       	=>      x_msg_count,
        	p_data        	=>      x_msg_data );

    WHEN OTHERS THEN
--	  dbms_output.put_line('stop 3 ');
	  ROLLBACK TO UPDATE_PERZ_QUERY_PVT;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
	  --x_return_status := SQLCODE||SUBSTR(SQLERRM,1,100);

	IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

	Fnd_Msg_Pub.Count_And_Get( p_count        	=>      x_msg_count,
        	  		   p_data          	=>      x_msg_data );


END update_perz_query;
--******************************************************************************
PROCEDURE Delete_Perz_Query
(	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= Fnd_Api.G_FALSE,
	p_commit				IN VARCHAR2		:= Fnd_Api.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        IN NUMBER,
	p_query_id            IN NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

  	 l_query_id		NUMBER;
     l_api_name		 	CONSTANT VARCHAR2(30)	:= 'Delete Profile';
BEGIN
	   -- Standard Start of API savepoint
      SAVEPOINT	DELETE_PERZ_QUERY_PVT;

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
          Fnd_Msg_Pub.initialize;
      END IF;

   	  -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


-- CALL FLOW
-- 1. Select query ID from databe
-- 2. Delete all parameters for that Query ID
-- 3. Delete all Order By records for that ID
-- 4. Delete all raw SQL records for that query ID
-- 5. Update query header information
-- 6. Insert all new rocords from input.


-- 1. getting query ID for query Name
   l_query_id := p_query_id;

--    IF (p_query_id = NULL) THEN
--       check_query_duplicates ( p_query_name,
-- 			                   p_application_id,
-- 			                   p_profile_id,
-- 			                   l_is_duplicate,
-- 			                   l_query_id);
--    END IF;
--
--   dbms_output.put_line('id from databe ' || l_query_id);

-- 2. Delete all parmeter table entries for this query_id

   DELETE  FROM JTF_PERZ_QUERY_PARAM WHERE QUERY_ID = l_query_id;

-- 3. Delete all order by table entries for this query_id
	DELETE  FROM JTF_PERZ_QUERY_ORDER_BY WHERE QUERY_ID = l_query_id;

-- 4. Delete all raw sql table entries for this query_id
   DELETE  FROM JTF_PERZ_QUERY_RAW_SQL WHERE QUERY_ID = l_query_id;

-- 5. Delete query header table entries for this query_id
   DELETE  FROM JTF_PERZ_QUERY WHERE QUERY_ID = l_query_id;

  EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
	  --dbms_output.put_line('stop 1 ');

	  ROLLBACK TO DELETE_PERZ_QUERY_PVT;
	  x_return_status := Fnd_Api.G_RET_STS_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get( p_count    	=>      x_msg_count,
	  				p_data       	=>      x_msg_data );

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
	  --dbms_output.put_line('stop 2 ');
	  ROLLBACK TO DELETE_PERZ_QUERY_PVT;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get( p_count       	=>      x_msg_count,
        	  			p_data        	=>      x_msg_data );

    WHEN OTHERS THEN
	  --dbms_output.put_line('stop 3 ');
	  ROLLBACK TO DELETE_PERZ_QUERY_PVT;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

	Fnd_Msg_Pub.Count_And_Get( p_count        	=>      x_msg_count,
        	  		p_data          	=>      x_msg_data );


END Delete_perz_query;

--******************************************************************************

PROCEDURE Get_Perz_Query_Summary
( 	p_api_version_number   IN NUMBER,
	p_init_msg_list		IN VARCHAR2 	:= Fnd_Api.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id           IN NUMBER,
	p_profile_name         IN VARCHAR2,

	p_query_id             IN NUMBER,
	p_query_name           IN VARCHAR2,
	p_query_type         IN VARCHAR2,

    x_query_out_tbl	   OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_QUERY_PUB.QUERY_OUT_TBL_TYPE,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS

	 l_api_version		NUMBER := 1.0;
	 l_init_msg_list	VARCHAR2(240);
   	 l_any_errors           BOOLEAN        := FALSE;
     l_any_row_errors       BOOLEAN        := FALSE;
	 l_found_flag		BOOLEAN        := FALSE;
     l_rowid               	ROWID;
     l_return_status        VARCHAR2(240)    := Fnd_Api.G_RET_STS_SUCCESS;
     l_api_name		 	CONSTANT VARCHAR2(30)	:= 'Get Perz Query Summary';

	 l_count		NUMBER     := 0;
	 l_msg_count		NUMBER := NULL;
	 l_msg_data		VARCHAR2(200) := NULL;
	 l_count_1	     	NUMBER     := NULL;
     l_curr_row			NUMBER		:= NULL;

     l_duplicate            VARCHAR2(240)    := Fnd_Api.G_FALSE;
	 l_query_name		VARCHAR2(100)	:= p_query_name;

     -- Variables for ids
	 l_query_string	  	VARCHAR2(1) := NULL;
	 l_active_flag	   	VARCHAR2(1)  := 'Y';
     l_profile_id		NUMBER := p_profile_id;
	 l_query_id		NUMBER;
     l_is_duplicate		VARCHAR2(1);
	 l_profile_name		VARCHAR2(30) := NULL;

	-- Temporary variables
	l_query_id_temp		NUMBER;
	l_profile_id_temp	NUMBER;
	l_application_id_temp	NUMBER;
	l_query_name_temp	VARCHAR2(100);
	l_query_type_temp	VARCHAR2(100);
	l_query_description_temp VARCHAR2(240);
	l_query_data_source_temp VARCHAR2(2000);
--
     -- cursors

     CURSOR C_Get_Query_Summary (p_profile_id NUMBER, p_application_id NUMBER) IS
     SELECT  Query_ID, Profile_ID, Application_id, Query_Name, Query_Type,
		Query_Description, Query_Data_source
     FROM    JTF_PERZ_QUERY
     WHERE   Profile_ID = p_profile_id AND Application_ID = p_application_id;

     CURSOR C_Get_Query_Summary_qid (p_query_id NUMBER ) IS
     SELECT  Query_ID, Profile_ID, Application_id, Query_Name, Query_Type,
		Query_Description, Query_Data_source
     FROM    JTF_PERZ_QUERY
     WHERE   query_id = p_query_id;

     CURSOR C_Get_Query_Summary_qnmty (p_query_name VARCHAR2, p_query_type VARCHAR2,
					p_profile_id NUMBER, p_application_id NUMBER) IS
     SELECT  Query_ID, Profile_ID, Application_id, Query_Name, Query_Type,
		Query_Description, Query_Data_source
     FROM    JTF_PERZ_QUERY
     WHERE   query_type = p_query_type
		AND query_name = p_query_name
		AND Profile_ID = p_profile_id
		AND Application_ID = p_application_id;

     CURSOR C_Get_Query_Summary_qty (p_query_type VARCHAR2, p_profile_id NUMBER, p_application_id NUMBER) IS
     SELECT  Query_ID, Profile_ID, Application_id, Query_Name, Query_Type,
		Query_Description, Query_Data_source
     FROM    JTF_PERZ_QUERY
     WHERE   query_type = p_query_type AND Profile_ID = p_profile_id AND Application_ID = p_application_id;

     CURSOR C_Get_Query_Summary_qnm (p_query_name VARCHAR2, p_profile_id NUMBER, p_application_id NUMBER) IS
     SELECT  Query_ID, Profile_ID, Application_id, Query_Name, Query_Type,
		Query_Description, Query_Data_source
     FROM    JTF_PERZ_QUERY
     WHERE   query_name = p_query_name AND Profile_ID = p_profile_id AND Application_ID = p_application_id;

BEGIN
       -- ******* Standard Begins ********

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
          Fnd_Msg_Pub.initialize;
      END IF;
   	  -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


 IF ((p_query_id IS NOT NULL) AND
	(p_query_id <> Fnd_Api.G_MISS_NUM)) THEN

  	l_count := 1;
	OPEN  C_Get_Query_Summary_qid(p_query_id);
	LOOP
		FETCH C_Get_Query_Summary_qid 	INTO
			l_query_id_temp,
			l_profile_id_temp,
			l_application_id_temp,
			l_query_name_temp,
			l_query_type_temp,
			l_query_description_temp,
			l_query_data_source_temp;
		EXIT WHEN C_Get_Query_Summary_qid%NOTFOUND;

		IF (C_Get_Query_Summary_qid%FOUND = TRUE) THEN
			x_query_out_tbl(l_count).query_id := l_query_id_temp;
			x_query_out_tbl(l_count).profile_id := l_profile_id_temp;
			x_query_out_tbl(l_count).application_id := l_application_id_temp;
			x_query_out_tbl(l_count).query_name := l_query_name_temp;
			x_query_out_tbl(l_count).query_type := l_query_type_temp;
			x_query_out_tbl(l_count).query_description := l_query_description_temp;
			x_query_out_tbl(l_count).query_data_source := l_query_data_source_temp;
           		l_count := l_count + 1;
		END IF;
 	END LOOP;
	CLOSE  C_Get_Query_Summary_qid;

 ELSE
	l_profile_id := p_profile_id;
	l_profile_name := p_profile_name;
	l_return_status := Fnd_Api.G_TRUE;

	IF ( l_profile_id IS NULL ) THEN
	   JTF_PERZ_PROFILE_PVT.check_profile_duplicates(l_profile_name,
		                    l_return_status,
		                    l_profile_id);

	   -- If profile does not exists, raise an error and exit

   	   IF (l_return_status = Fnd_Api.G_FALSE) THEN
       	     RAISE Fnd_Api.G_EXC_ERROR;
   	   END IF;
	END IF;

  	IF (((l_profile_id IS NOT NULL) AND
		(l_profile_id <> Fnd_Api.G_MISS_NUM)) AND
		((p_application_id IS NOT NULL) AND
		(p_application_id <> Fnd_Api.G_MISS_NUM))) THEN

		IF((p_query_name IS NOT NULL) AND (p_query_name <> Fnd_Api.G_MISS_CHAR)
		    AND (p_query_type IS NOT NULL) AND (p_query_type <> Fnd_Api.G_MISS_CHAR)) THEN
		 /* if query name and type was given */
  			l_count := 1;
			OPEN  C_Get_Query_Summary_qnmty(p_query_name,p_query_type,
				 	l_profile_id, p_application_id);
			LOOP
				FETCH C_Get_Query_Summary_qnmty 	INTO
				l_query_id_temp,
				l_profile_id_temp,
				l_application_id_temp,
				l_query_name_temp,
				l_query_type_temp,
				l_query_description_temp,
				l_query_data_source_temp;
				EXIT WHEN C_Get_Query_Summary_qnmty%NOTFOUND;

				IF (C_Get_Query_Summary_qnmty%FOUND = TRUE) THEN
					x_query_out_tbl(l_count).query_id := l_query_id_temp;
					x_query_out_tbl(l_count).profile_id := l_profile_id_temp;
					x_query_out_tbl(l_count).application_id := l_application_id_temp;
					x_query_out_tbl(l_count).query_name := l_query_name_temp;
					x_query_out_tbl(l_count).query_type := l_query_type_temp;
					x_query_out_tbl(l_count).query_description := l_query_description_temp;
					x_query_out_tbl(l_count).query_data_source := l_query_data_source_temp;
           				l_count := l_count + 1;
				END IF;
 			END LOOP;
			CLOSE  C_Get_Query_Summary_qnmty;

			RETURN;
		END IF; -- end for name and type

		IF((p_query_name IS NOT NULL) AND
		(p_query_name <> Fnd_Api.G_MISS_CHAR)) THEN
		 /* if query name was given */
  			l_count := 1;
			OPEN  C_Get_Query_Summary_qnm(p_query_name,
				 	l_profile_id, p_application_id);
			LOOP
				FETCH C_Get_Query_Summary_qnm 	INTO
				l_query_id_temp,
				l_profile_id_temp,
				l_application_id_temp,
				l_query_name_temp,
				l_query_type_temp,
				l_query_description_temp,
				l_query_data_source_temp;
				EXIT WHEN C_Get_Query_Summary_qnm%NOTFOUND;

				IF (C_Get_Query_Summary_qnm%FOUND = TRUE) THEN
					x_query_out_tbl(l_count).query_id := l_query_id_temp;
					x_query_out_tbl(l_count).profile_id := l_profile_id_temp;
					x_query_out_tbl(l_count).application_id := l_application_id_temp;
					x_query_out_tbl(l_count).query_name := l_query_name_temp;
					x_query_out_tbl(l_count).query_type := l_query_type_temp;
					x_query_out_tbl(l_count).query_description := l_query_description_temp;
					x_query_out_tbl(l_count).query_data_source := l_query_data_source_temp;
           				l_count := l_count + 1;
				END IF;
 			END LOOP;
			CLOSE  C_Get_Query_Summary_qnm;

			RETURN;
		END IF; -- end for name

		IF((p_query_type IS NOT NULL) AND
		(p_query_type <> Fnd_Api.G_MISS_CHAR)) THEN
		 /* if query type was given */
  			l_count := 1;
			OPEN  C_Get_Query_Summary_qty(p_query_type,
				 	l_profile_id, p_application_id);
			LOOP
				FETCH C_Get_Query_Summary_qty 	INTO
				l_query_id_temp,
				l_profile_id_temp,
				l_application_id_temp,
				l_query_name_temp,
				l_query_type_temp,
				l_query_description_temp,
				l_query_data_source_temp;
				EXIT WHEN C_Get_Query_Summary_qty%NOTFOUND;

				IF (C_Get_Query_Summary_qty%FOUND = TRUE) THEN
					x_query_out_tbl(l_count).query_id := l_query_id_temp;
					x_query_out_tbl(l_count).profile_id := l_profile_id_temp;
					x_query_out_tbl(l_count).application_id := l_application_id_temp;
					x_query_out_tbl(l_count).query_name := l_query_name_temp;
					x_query_out_tbl(l_count).query_type := l_query_type_temp;
					x_query_out_tbl(l_count).query_description := l_query_description_temp;
					x_query_out_tbl(l_count).query_data_source := l_query_data_source_temp;
           				l_count := l_count + 1;
				END IF;
 			END LOOP;
			CLOSE  C_Get_Query_Summary_qty;

			RETURN;
		END IF; -- end for type

		    /* if query name or type was not given */
 			l_count := 1;
			OPEN C_Get_Query_Summary(l_profile_id, p_application_id);
			LOOP
				FETCH C_Get_Query_Summary  	INTO
				l_query_id_temp,
				l_profile_id_temp,
				l_application_id_temp,
				l_query_name_temp,
				l_query_type_temp,
				l_query_description_temp,
				l_query_data_source_temp;
				EXIT WHEN C_Get_Query_Summary%NOTFOUND;

				IF (C_Get_Query_Summary%FOUND = TRUE) THEN
					x_query_out_tbl(l_count).query_id := l_query_id_temp;
					x_query_out_tbl(l_count).profile_id := l_profile_id_temp;
					x_query_out_tbl(l_count).application_id := l_application_id_temp;
					x_query_out_tbl(l_count).query_name := l_query_name_temp;
					x_query_out_tbl(l_count).query_type := l_query_type_temp;
					x_query_out_tbl(l_count).query_description := l_query_description_temp;
					x_query_out_tbl(l_count).query_data_source := l_query_data_source_temp;
           				l_count := l_count + 1;
				END IF;
 			END LOOP;
			CLOSE  C_Get_Query_Summary;

	END IF; -- endif for profile/appid check

  END IF; -- endif for query id

  EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
	  x_return_status := Fnd_Api.G_RET_STS_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get( p_count    	=>      x_msg_count,
	  				 p_data       	=>      x_msg_data );

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get( p_count       	=>      x_msg_count,
        	  		 p_data        	=>      x_msg_data );

    WHEN OTHERS THEN
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

	Fnd_Msg_Pub.Count_And_Get( p_count        	=>      x_msg_count,
        	  		   p_data          	=>      x_msg_data );


END get_perz_query_summary;


--******************************************************************************


PROCEDURE Get_Perz_Query
( 	p_api_version_number	IN NUMBER,
	p_init_msg_list		IN VARCHAR2 	:= Fnd_Api.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id           IN NUMBER,
	p_profile_name         IN VARCHAR2,

	p_query_id             IN NUMBER,
	p_query_name           IN VARCHAR2,
	p_query_type         IN VARCHAR2,

	x_query_id             OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_query_name           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_query_type	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_query_desc		   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_query_data_source    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,

	x_query_param_tbl OUT NOCOPY /* file.sql.39 change */ Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE,
    x_query_order_by_tbl   OUT NOCOPY /* file.sql.39 change */ Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE,
    x_query_raw_sql_rec	   OUT NOCOPY /* file.sql.39 change */ Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
       -- ******* Get_Perz_Query Local Variables - Standards ********
	l_api_name		VARCHAR2(60)  	:= 'Get_Perz_Query';
	l_api_version_number	NUMBER 	:= p_api_version_number;

       -- ******* Get_Perz_Query Local Variables ********
	l_query_out_tbl		Jtf_Perz_Query_Pub.QUERY_OUT_TBL_TYPE;

	l_count			NUMBER := NULL;

	--Temporary variables
		l_QUERY_PARAM_ID_temp		NUMBER;
		l_QUERY_ID_temp			NUMBER;
		l_PARAMETER_NAME_temp		VARCHAR2(60);
		l_PARAMETER_TYPE_temp		VARCHAR2(30);
		l_PARAMETER_VALUE_temp		VARCHAR2(300);
		l_PARAMETER_CONDITION_temp	VARCHAR2(10);
		l_PARAMETER_SEQUENCE_temp	NUMBER;
		l_QUERY_RAW_SQL_ID_temp		NUMBER;
		l_SELECT_STRING_temp		VARCHAR2(200);
		l_FROM_STRING_temp		VARCHAR2(200);
		l_WHERE_STRING_temp		VARCHAR2(200);
		l_ORDER_BY_STRING_temp		VARCHAR2(200);
		l_GROUP_BY_STRING_temp		VARCHAR2(200);
		l_HAVING_STRING_temp		VARCHAR2(200);
		l_QUERY_ORDER_BY_ID_temp	NUMBER;
		l_ACND_DCND_FLAG_temp		VARCHAR2(1);


     CURSOR C_Get_Query_param (p_query_id NUMBER) IS
	SELECT QUERY_PARAM_ID, QUERY_ID, PARAMETER_NAME,
		PARAMETER_TYPE, PARAMETER_VALUE, PARAMETER_CONDITION,
		PARAMETER_SEQUENCE
	FROM JTF_PERZ_QUERY_PARAM
	WHERE QUERY_ID = p_query_id
	ORDER BY PARAMETER_SEQUENCE;

     CURSOR C_Get_Query_Order_By (p_query_id NUMBER) IS
	SELECT QUERY_ORDER_BY_ID, QUERY_ID, PARAMETER_NAME,
		ACND_DCND_FLAG, PARAMETER_SEQUENCE
	FROM JTF_PERZ_QUERY_ORDER_BY
	WHERE QUERY_ID = p_query_id
	ORDER BY PARAMETER_SEQUENCE;
BEGIN
       -- ******* Standard Begins ********

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
          Fnd_Msg_Pub.initialize;
      END IF;

	-- Initialize API return status to success
  	x_return_status := Fnd_Api.G_RET_STS_SUCCESS ;


       -- ******* Get_Perz_Query Execution Plan ********
--  execution steps
--
--1. Call get_perz_query_summary()
--2. If Sucessfdul and QUERY OUT TABLE returns more than one record,
--	 raise exception if error
--3. If QUERY OUT  TABLE returns one record only, then
--4. 	a. Get QUERY PARAMETERS
--	b. Get RAW SQL
--	c. Get ORDER BY
--	d. sign the results to out parameters
--5. Commit the whole thing

-- Get_Perz_Query Implementation

--1. Call get_perz_query_summary()

Get_Perz_Query_Summary
( 	p_api_version_number   ,
	p_init_msg_list	,
	p_application_id,
	p_profile_id  ,
	p_profile_name ,
	p_query_id,
	p_query_name ,
	p_query_type,
	l_query_out_tbl,
	x_return_status,
	x_msg_count,
	x_msg_data
);

l_count := l_query_out_tbl.COUNT;

--dbms_output.put_line('l_count from summary output '||l_count);
IF ( l_count = 1) THEN

--3. If QUERY OUT  TABLE returns one record only, then
	x_query_id		:= l_query_out_tbl(1).QUERY_ID;
	x_query_name		:= l_query_out_tbl(1).QUERY_NAME;
	x_query_desc		:= l_query_out_tbl(1).QUERY_DESCRIPTION;
	x_query_type		:= l_query_out_tbl(1).QUERY_TYPE;
	x_query_data_source	:= l_query_out_tbl(1).QUERY_DATA_SOURCE;

--4. 	a. Get QUERY PARAMETERS

	l_QUERY_PARAM_ID_temp := NULL;
	l_QUERY_ID_temp		:= NULL;
	l_PARAMETER_NAME_temp		:= NULL;
	l_PARAMETER_TYPE_temp		:= NULL;
	l_PARAMETER_VALUE_temp		:= NULL;
	l_PARAMETER_CONDITION_temp	:= NULL;
	l_PARAMETER_SEQUENCE_temp	:= NULL;

	l_count := 1;
	OPEN C_Get_Query_param(x_query_id);
	LOOP
		FETCH C_Get_Query_param INTO
			l_QUERY_PARAM_ID_temp,
			l_QUERY_ID_temp,
			l_PARAMETER_NAME_temp,
			l_PARAMETER_TYPE_temp,
			l_PARAMETER_VALUE_temp,
			l_PARAMETER_CONDITION_temp,
			l_PARAMETER_SEQUENCE_temp;
		EXIT WHEN C_Get_Query_param%NOTFOUND;
		IF (C_Get_Query_param%FOUND = TRUE) THEN
			x_query_param_tbl(l_count).QUERY_PARAM_ID := l_QUERY_PARAM_ID_temp;
			x_query_param_tbl(l_count).QUERY_ID := l_QUERY_ID_temp;
			x_query_param_tbl(l_count).PARAMETER_NAME := l_PARAMETER_NAME_temp;
			x_query_param_tbl(l_count).PARAMETER_TYPE := l_PARAMETER_TYPE_temp;
			x_query_param_tbl(l_count).PARAMETER_VALUE := l_PARAMETER_VALUE_temp;
			x_query_param_tbl(l_count).PARAMETER_CONDITION := l_PARAMETER_CONDITION_temp;
			x_query_param_tbl(l_count).PARAMETER_SEQUENCE := l_PARAMETER_SEQUENCE_temp;
			l_count := l_count +1;
		END IF;
	END LOOP;
	CLOSE C_Get_Query_param;

--	c. Get ORDER BY


	l_QUERY_ORDER_BY_ID_temp	:= NULL;
	l_QUERY_ID_temp			:= NULL;
	l_PARAMETER_NAME_temp		:= NULL;
	l_ACND_DCND_FLAG_temp		:= NULL;
	l_PARAMETER_SEQUENCE_temp	:= NULL;
	l_count := 1;
	OPEN C_Get_Query_Order_By (x_query_id );
	LOOP
		FETCH C_Get_Query_Order_By INTO
			l_QUERY_ORDER_BY_ID_temp,
			l_QUERY_ID_temp,
			l_PARAMETER_NAME_temp,
			l_ACND_DCND_FLAG_temp,
			l_PARAMETER_SEQUENCE_temp;
		EXIT WHEN C_Get_Query_Order_By%NOTFOUND;
		IF (C_Get_Query_Order_By%FOUND) THEN
			x_query_order_by_tbl(l_count).QUERY_ORDER_BY_ID := l_QUERY_ORDER_BY_ID_temp;
			x_query_order_by_tbl(l_count).QUERY_ID := l_QUERY_ID_temp;
			x_query_order_by_tbl(l_count).PARAMETER_NAME := l_PARAMETER_NAME_temp;
			x_query_order_by_tbl(l_count).ACND_DCND_FLAG := l_ACND_DCND_FLAG_temp;
			x_query_order_by_tbl(l_count).PARAMETER_SEQUENCE := l_PARAMETER_SEQUENCE_temp;
			l_count := l_count +1;
		END IF;
	END LOOP;
	CLOSE C_Get_Query_Order_By;

--	b. Get RAW SQL


	l_QUERY_RAW_SQL_ID_temp	:= NULL;
	l_QUERY_ID_temp		:= NULL;
	l_SELECT_STRING_temp	:= NULL;
	l_FROM_STRING_temp	:= NULL;
	l_WHERE_STRING_temp	:= NULL;
	l_ORDER_BY_STRING_temp	:= NULL;
	l_GROUP_BY_STRING_temp	:= NULL;
	l_HAVING_STRING_temp	:= NULL;

	BEGIN

		SELECT QUERY_RAW_SQL_ID, QUERY_ID, SELECT_STRING,
		FROM_STRING, WHERE_STRING, ORDER_BY_STRING,
		GROUP_BY_STRING, HAVING_STRING
		INTO
			x_query_raw_sql_rec.QUERY_RAW_SQL_ID,
			x_query_raw_sql_rec.QUERY_ID,
			x_query_raw_sql_rec.SELECT_STRING,
			x_query_raw_sql_rec.FROM_STRING,
			x_query_raw_sql_rec.WHERE_STRING,
			x_query_raw_sql_rec.ORDER_BY_STRING,
			x_query_raw_sql_rec.GROUP_BY_STRING,
			x_query_raw_sql_rec.HAVING_STRING
		FROM JTF_PERZ_QUERY_RAW_SQL
		WHERE QUERY_ID = p_query_id;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
	END;

ELSE
--2. If Sucessfdul and QUERY OUT TABLE returns more than one record,
--	 raise exception if error
	RAISE Fnd_Api.G_EXC_ERROR;
END IF;

EXCEPTION

  WHEN Fnd_Api.G_EXC_ERROR THEN
	--  dbms_output.put_line('stop 1 ');
	  x_return_status := Fnd_Api.G_RET_STS_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
	( p_count    	=>      x_msg_count,
	p_data       	=>      x_msg_data );


 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
	  --dbms_output.put_line('stop 2 ');
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
	( p_count    	=>      x_msg_count,
	p_data       	=>      x_msg_data );


 WHEN OTHERS THEN
	  --dbms_output.put_line('stop 3 ');
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
		Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	END IF;


	  Fnd_Msg_Pub.Count_And_Get
	( p_count    	=>      x_msg_count,
	p_data       	=>      x_msg_data );



END Get_Perz_Query;
--******************************************************************************
PROCEDURE Save_Perz_Query
( 	p_api_version_number	IN NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= Fnd_Api.G_FALSE,
	p_commit		IN VARCHAR2	:= Fnd_Api.G_FALSE,
	p_application_id	IN NUMBER,
	p_profile_id        	IN NUMBER,
	p_profile_name      	IN VARCHAR2,
	p_profile_type      	IN VARCHAR2,
	p_Profile_Attrib    IN Jtf_Perz_Profile_Pub.PROFILE_ATTRIB_TBL_TYPE
			:= Jtf_Perz_Profile_Pub.G_MISS_PROFILE_ATTRIB_TBL,
	p_query_id		IN NUMBER,
	p_query_name         	IN VARCHAR2,
	p_query_type		IN VARCHAR2,
	p_query_desc		IN VARCHAR2,
	p_query_data_source  	IN VARCHAR2,
	p_query_param_tbl	IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
			:= Jtf_Perz_Query_Pub.G_MISS_QUERY_PARAMETER_TBL,
    	p_query_order_by_tbl 	IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
			:= Jtf_Perz_Query_Pub.G_MISS_QUERY_ORDER_BY_TBL,
    	p_query_raw_sql_rec	 IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE ,
	x_query_id	    OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
       -- ******* Save_Perz_Query Local Variables - Standards ********
	l_api_name		VARCHAR2(60)  	:= 'Save_Perz_Query';
	l_api_version_number	NUMBER 	:= p_api_version_number;

       -- ******* Save_Perz_Query Local Variables ********

	l_return_status 	VARCHAR2(240) := Fnd_Api.G_RET_STS_SUCCESS;
	l_query_id				NUMBER;
    l_profile_id			NUMBER;
	l_is_duplicate		 	VARCHAR2(1) := Fnd_Api.G_FALSE;


	l_profile_attrib		Jtf_Perz_Profile_Pub.PROFILE_ATTRIB_TBL_TYPE
							:= p_profile_attrib;
	l_profile_name			VARCHAR2(60) := p_profile_name;

	l_commit				VARCHAR2(1)	:= Fnd_Api.G_TRUE;
	l_object_version_number NUMBER :=NULL;



BEGIN
       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	SAVE_PERZ_QUERY_PVT;

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
          Fnd_Msg_Pub.initialize;
      END IF;

  	  -- Initialize API return status to success
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


--  CALL FLOW :
-- 1. Check for profile, if not existing create profile.
-- 2. check if duplicate query exists if TRUE,
--	then call update()
--	else call insert()

-- 1.	check profile

	l_profile_id := p_profile_id;

	Jtf_Perz_Profile_Pvt.check_profile_duplicates(
		l_profile_name,
		l_return_status,
		l_profile_id
	);
--	dbms_output.put_line('profile id is:'||l_profile_id);

-- 1.1	if profile is not available, create profile

	IF (l_return_status = Fnd_Api.G_FALSE) THEN

		l_return_status := Fnd_Api.G_RET_STS_SUCCESS;
		l_commit 		 := Fnd_Api.G_FALSE;
		l_profile_id := p_profile_id;

		Jtf_Perz_Profile_Pvt.Create_Profile(
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

		IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS) THEN
			RAISE Fnd_Api.G_EXC_ERROR;
		END IF;
	--	dbms_output.put_line('2 profile id is:'||l_profile_id);
	END IF;


-- 2. CHECK IF DUPLICATE QUERY  EXISTS
-- the duplicacy is defined  having the same query name
--	for the a profile id within an application id.

	 check_query_duplicates (
		p_query_name,
		p_query_type,
		p_application_id,
		l_profile_id,
		l_is_duplicate,
		l_query_id,
		l_object_version_number
	);


l_commit := Fnd_Api.G_FALSE;
IF (Fnd_Api.To_Boolean(l_is_duplicate)) THEN
	--dbms_output.put_line(' duplicate query exists!'||l_query_id);
--	dbms_output.put_line(' duplicate query exists, profile id is:'||l_profile_id);
-- Call update_perz_query

   Update_Perz_Query
   (	p_api_version_number,
  	p_init_msg_list,
	l_commit,

	p_application_id,
	l_profile_id,

	l_query_id,
	p_query_name ,
	p_query_type,
	p_query_desc,
	p_query_data_source ,

	p_query_param_tbl,

    	p_query_order_by_tbl,
    	p_query_raw_sql_rec	 ,
	x_query_id  ,
	x_return_status	,
	x_msg_count,
	x_msg_data
   );

--dbms_output.put_line('return status from update is'||x_return_status);
ELSE

-- Call create_perz_query
   Create_Perz_Query
   (	p_api_version_number,
  	p_init_msg_list,
	l_commit,

	p_application_id,

	l_profile_id    ,
	p_profile_name  ,

	p_query_id,
	p_query_name ,
	p_query_type,
	p_query_desc,
	p_query_data_source ,

	p_query_param_tbl,

    	p_query_order_by_tbl,
    	p_query_raw_sql_rec	 ,
	x_query_id  ,
	x_return_status	,
	x_msg_count,
	x_msg_data
   );
--dbms_output.put_line('query id is'||x_query_id);
END IF;
-- ******** Standard Ends ***********
--
-- End of main API body.

   -- Standard check of p_commit.
   IF (Fnd_Api.To_Boolean(p_commit)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   Fnd_Msg_Pub.Count_And_Get( p_count       	=>      x_msg_count,
       		              p_data        	=>      x_msg_data );

  EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
	--  dbms_output.put_line('stop 1 ');

	  ROLLBACK TO SAVE_PERZ_QUERY_PVT;
	  x_return_status := Fnd_Api.G_RET_STS_ERROR ;

	  Fnd_Msg_Pub.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
	--  dbms_output.put_line('stop 2 ');
	  ROLLBACK TO SAVE_PERZ_QUERY_PVT;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
	  Fnd_Msg_Pub.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );


    WHEN OTHERS THEN
	 -- dbms_output.put_line('stop 3 ');
	  ROLLBACK TO SAVE_PERZ_QUERY_PVT;
	  x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;

	IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	END IF;

	  Fnd_Msg_Pub.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );


END Save_Perz_Query;
--******************************************************************************
--******************************************************************************

END Jtf_Perz_Query_Pvt;

/
