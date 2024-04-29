--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_DATA_PUB" as
/* $Header: jtfzppdb.pls 120.2 2005/11/02 03:46:52 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
--   JTF_PERZ_DATA_PUB
--
-- PURPOSE
--   Public API for creating, getting and updating personalized data objects
-- 	 in the Personalization Framework.
--
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for creating, getting and updating personalized data objects
-- 	 in the Personalization Framework.
--
-- HISTORY
--	09/21/99	SMATTEGU	Created
--
-- End of Comments
-- *****************************************************************************


G_PKG_NAME  	CONSTANT VARCHAR2(30):='JTF_PERZ_DATA_PUB';
G_FILE_NAME   	CONSTANT VARCHAR2(12):='jtfppzdb.pls';


-- *****************************************************************************
-- *****************************************************************************

PROCEDURE Save_Perz_Data
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        IN NUMBER,
	p_profile_name      IN VARCHAR2,
	p_profile_type      IN VARCHAR2,
	p_profile_attrib    IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
			:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,
	p_perz_data_id		IN NUMBER,
	p_perz_data_name          IN VARCHAR2,
	p_perz_data_type		IN VARCHAR2,
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
BEGIN
       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	SAVE_PERZ_DATA_PUB;

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


	JTF_PERZ_DATA_PVT.Save_Perz_Data(
	p_api_version_number,
  	p_init_msg_list,
	p_commit,

	p_application_id,

	p_profile_id    ,
	p_profile_name  ,
	p_profile_type  ,
	p_profile_attrib,

	p_perz_data_id,
	p_perz_data_name ,
	p_perz_data_type ,
    	p_perz_data_desc,

	p_data_attrib_tbl,

	x_perz_data_id  ,
	x_return_status	,
	x_msg_count,
	x_msg_data
   	);


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
	--  dbms_output.put_line('stop 1 ');

	  ROLLBACK TO SAVE_PERZ_DATA_PUB;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	--  dbms_output.put_line('stop 2 ');
	  ROLLBACK TO SAVE_PERZ_DATA_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );


    WHEN OTHERS THEN
	 -- dbms_output.put_line('stop 3 ');
	  ROLLBACK TO SAVE_PERZ_DATA_PUB;
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

PROCEDURE Create_Perz_Data
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit		IN VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id            IN NUMBER,
	p_profile_name          IN VARCHAR2,
	p_perz_data_id		IN NUMBER,
    	p_perz_data_name             IN VARCHAR2,
	p_perz_data_type		IN VARCHAR2,
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
BEGIN
       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	CREATE_PERZ_DATA_PUB;

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


	JTF_PERZ_DATA_PVT.Create_Perz_Data(
	p_api_version_number,
  	p_init_msg_list,
	p_commit,

	p_application_id,

	p_profile_id    ,
	p_profile_name  ,

	p_perz_data_id,
	p_perz_data_name ,
	p_perz_data_type ,
    	p_perz_data_desc,

	p_data_attrib_tbl,

	x_perz_data_id  ,
	x_return_status	,
	x_msg_count,
	x_msg_data
   	);


-- ******** Standard Ends ***********
--
-- End of main API body.

   -- Standard check of p_commit.
   IF (FND_API.To_Boolean(p_commit)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
				p_data      =>      x_msg_data );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	--  dbms_output.put_line('stop 1 ');

	  ROLLBACK TO CREATE_PERZ_DATA_PUB;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	--  dbms_output.put_line('stop 2 ');
	  ROLLBACK TO CREATE_PERZ_DATA_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );


    WHEN OTHERS THEN
	 -- dbms_output.put_line('stop 3 ');
	  ROLLBACK TO CREATE_PERZ_DATA_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	END IF;

	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );


END Create_Perz_Data;

-- *****************************************************************************

PROCEDURE Get_Perz_Data
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id       	IN	NUMBER,
	p_profile_name     	IN	VARCHAR2,
	p_perz_data_id            IN NUMBER,
	p_perz_data_name          IN VARCHAR2,
	p_perz_data_type		IN VARCHAR2 := NULL,

    	x_perz_data_id            OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_perz_data_name          OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_perz_data_type	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_perz_data_desc OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_data_attrib_tbl OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS


	--******** Get_Perz_Data_Summary local variable for standards **********
     	l_api_name		 CONSTANT VARCHAR2(30)	:= 'Get PerzData';
	l_api_version_number	NUMBER 	:= p_api_version_number;

       -- ******* Get_Perz_Data_Summary Local Variables ********

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

	JTF_PERZ_DATA_PVT.Get_Perz_Data(
	p_api_version_number,
  	p_init_msg_list,

	p_application_id,

	p_profile_id    ,
	p_profile_name  ,

	p_perz_data_id,
	p_perz_data_name ,
	p_perz_data_type ,

	x_perz_data_id  ,
	x_perz_data_name ,
	x_perz_data_type,
	x_perz_data_desc,
	x_data_attrib_tbl,

	x_return_status	,
	x_msg_count,
	x_msg_data
   	);


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
	p_perz_data_id            IN NUMBER,
	p_perz_data_name          IN VARCHAR2,
	p_perz_data_type			IN VARCHAR2 := NULL,

	x_data_out_tbl OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_DATA_PUB.DATA_OUT_TBL_TYPE,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count		 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

	--******** Get_Perz_Data_Summary local variable for standards **********
     	l_api_name		 CONSTANT VARCHAR2(30)	:= 'Get PerzData Summary';
	l_api_version_number	NUMBER 	:= p_api_version_number;

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

	JTF_PERZ_DATA_PVT.Get_Perz_Data_Summary(
	p_api_version_number,
  	p_init_msg_list,

	p_application_id,

	p_profile_id    ,
	p_profile_name  ,

	p_perz_data_id,
	p_perz_data_name ,
	p_perz_data_type ,

	x_data_out_tbl,
	x_return_status	,
	x_msg_count,
	x_msg_data
   	);

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

PROCEDURE Update_Perz_Data
(	p_api_version_number	IN NUMBER,
  	p_init_msg_list		IN VARCHAR2 	:= FND_API.G_FALSE,
	p_commit			IN VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        IN NUMBER,

	p_perz_data_id            IN NUMBER,
	p_perz_data_name          IN VARCHAR2,
	p_perz_data_type			IN VARCHAR2 := NULL,
	p_perz_data_desc	IN VARCHAR2,
	p_data_attrib_tbl	IN JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
						:= JTF_PERZ_DATA_PUB.G_MISS_DATA_ATTRIB_TBL,

	x_perz_data_id	   	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count		 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS

	--******** Update_Perz_Data local variable for standards **********
     	l_api_name		 CONSTANT VARCHAR2(30)	:= 'Update_Perz_Data';
	l_api_version_number	NUMBER 	:= p_api_version_number;
BEGIN
       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	UPDATE_PERZ_DATA_PUB;

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


	JTF_PERZ_DATA_PVT.Update_Perz_Data(
	p_api_version_number,
  	p_init_msg_list,
	p_commit,

	p_application_id,

	p_profile_id    ,
	p_perz_data_id,
	p_perz_data_name ,
	p_perz_data_type ,
    	p_perz_data_desc,

	p_data_attrib_tbl,

	x_perz_data_id  ,
	x_return_status	,
	x_msg_count,
	x_msg_data
   	);

-- ******** Standard Ends ***********
--
-- End of main API body.

   -- Standard check of p_commit.
   IF (FND_API.To_Boolean(p_commit)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
				p_data      =>      x_msg_data );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	--  dbms_output.put_line('stop 1 ');

	  ROLLBACK TO UPDATE_PERZ_DATA_PUB;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	--  dbms_output.put_line('stop 2 ');
	  ROLLBACK TO UPDATE_PERZ_DATA_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );


    WHEN OTHERS THEN
	 -- dbms_output.put_line('stop 3 ');
	  ROLLBACK TO UPDATE_PERZ_DATA_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	END IF;

	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );


END Update_Perz_Data;

-- *****************************************************************************

PROCEDURE Delete_Perz_Data
(	p_api_version_number	IN	NUMBER,
  	p_init_msg_list			IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit				IN VARCHAR		:= FND_API.G_FALSE,

	p_application_id	IN NUMBER,
	p_profile_id        IN NUMBER,
	p_perz_data_id            IN NUMBER,

	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count		 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

	--******** Delete_Perz_Data local variable for standards **********
     	l_api_name		 CONSTANT VARCHAR2(30)	:= 'Delete_Perz_Data';
	l_api_version_number	NUMBER 	:= p_api_version_number;
BEGIN
       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	DELETE_PERZ_DATA_PUB;

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


	JTF_PERZ_DATA_PVT.Delete_Perz_Data(
	p_api_version_number,
  	p_init_msg_list,
	p_commit,

	p_application_id,

	p_profile_id    ,
	p_perz_data_id,

	x_return_status	,
	x_msg_count,
	x_msg_data
   	);


-- ******** Standard Ends ***********
--
-- End of main API body.

   -- Standard check of p_commit.
   IF (FND_API.To_Boolean(p_commit)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
				p_data      =>      x_msg_data );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	--  dbms_output.put_line('stop 1 ');

	  ROLLBACK TO DELETE_PERZ_DATA_PUB;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	--  dbms_output.put_line('stop 2 ');
	  ROLLBACK TO DELETE_PERZ_DATA_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );


    WHEN OTHERS THEN
	 -- dbms_output.put_line('stop 3 ');
	  ROLLBACK TO DELETE_PERZ_DATA_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	END IF;

	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );




END Delete_Perz_Data;

-- *****************************************************************************
-- *****************************************************************************


END  JTF_PERZ_DATA_PUB;

/
