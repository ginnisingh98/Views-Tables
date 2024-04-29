--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_LF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_LF_PUB" as
/* $Header: jtfzplfb.pls 120.2 2005/11/02 03:27:07 skothe ship $ */

-- Start of Comments
--
-- NAME
--   JTF_PERZ_LF_PUB
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
--	 06/15/99   SMATTEGU	Created
--	 07/21/99   SMATTEGU	Updated
--
-- End of Comments

G_PKG_NAME  	CONSTANT VARCHAR2(30):='JTF_PERZ_LF_PUB';
G_FILE_NAME   	CONSTANT VARCHAR2(12):='jtfpplfb.pls';

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

	p_object_type_id           	IN 	NUMBER,
	p_object_type           IN 	VARCHAR2,

	p_attrib_value_tbl	IN	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
				:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL,

	x_object_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

       -- ******* Local Variables ********

	l_api_version_number	NUMBER 	:= p_api_version_number;
     l_api_name		CONSTANT VARCHAR2(30)	:= 'Create Object';
	l_return_status    	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN

       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	CREATE_PERZ_LF_PUB;

      -- Standard call to check for call compatibility.
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
      l_return_status := FND_API.G_RET_STS_SUCCESS;

	JTF_PERZ_LF_PVT. Create_lf_object
	( 	p_api_version_number,
  		p_init_msg_list,
		p_commit,
		p_profile_id,
		p_profile_name,
		p_application_id,
		p_parent_id,
		p_object_id,
		p_object_name,
		p_object_type_id,
		p_object_type,
		p_attrib_value_tbl,
		x_object_id,
		l_return_status,
		x_msg_count,
		x_msg_data
	);
	  	x_return_status := l_return_status ;

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
	p_count         	=>      x_msg_count,
       	p_data          	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO CREATE_PERZ_LF_PUB;
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

	  ROLLBACK TO CREATE_PERZ_LF_PUB;
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

	  ROLLBACK TO CREATE_PERZ_LF_PUB;
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
PROCEDURE Update_lf_object
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_profile_id            IN	NUMBER,
	p_profile_name          IN	VARCHAR2,

	p_application_id	IN 	NUMBER,
	p_parent_id		IN 	NUMBER,
	p_object_Id		IN	NUMBER,
	p_object_name		IN 	VARCHAR2,
	p_active_flag		IN 	VARCHAR2,

	p_object_type_id	IN 	NUMBER,
	p_object_type		IN 	VARCHAR2,

	p_attrib_value_tbl	IN   	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
					:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL,

	x_object_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

       -- ******* Update_lf_object Local Variables ********
	l_api_version_number	NUMBER 	:= p_api_version_number;
	l_api_name 			VARCHAR2(60)  	:= 'Update Object';
	l_return_status    		VARCHAR2(1)    := FND_API.G_TRUE;

BEGIN

     -- ******* Standard Begins ********

	-- Standard Start of API savepoint
	SAVEPOINT     UPDATE_PERZ_LF_PUB;

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
	JTF_PERZ_LF_PVT.Update_lf_object
	( 	p_api_version_number,
		p_init_msg_list,
		p_commit,
		p_profile_id,
		p_profile_name,
		p_application_id,
		p_parent_id,
		p_Object_Id,
		p_object_name,
		p_active_flag,
		p_object_type_id,
		p_object_type,
		p_attrib_value_tbl,
		x_object_id,
		x_return_status,
		x_msg_count,
		x_msg_data
	);


	 -- ******** Standard Ends ***********
	  --
      -- End of API body.
      --
--	5.	Commit the whole thing

      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(
		  	p_count         	=>      x_msg_count,
          	p_data          	=>      x_msg_data
    	 );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO UPDATE_PERZ_LF_PUB;
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

	  ROLLBACK TO UPDATE_PERZ_LF_PUB;
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

	  ROLLBACK TO UPDATE_PERZ_LF_PUB;
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

PROCEDURE save_lf_object
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 	:= FND_API.G_FALSE,
	p_commit				IN	VARCHAR2 := FND_API.G_FALSE,
	p_profile_id             IN 	NUMBER,
	p_profile_name           IN 	VARCHAR2,
	p_profile_type           IN 	VARCHAR2,
	p_profile_attrib_tbl	IN JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
						:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,
	p_application_id		IN 	NUMBER,
	p_parent_id			IN 	NUMBER,
	p_object_type_id            IN 	NUMBER,
	p_object_type            IN 	VARCHAR2,
	p_object_id              IN 	NUMBER,
	p_object_name            IN 	VARCHAR2,
	p_object_description	IN VARCHAR2,
	p_active_flag		IN VARCHAR2,
	p_attrib_value_tbl		IN	JTF_PERZ_LF_PUB.ATTRIB_VALUE_TBL_TYPE
						:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_VALUE_TBL,

	x_object_id		 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count		 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

       -- ******* save_lf_object Local Variables ********
	l_api_version_number	NUMBER 	:= p_api_version_number;
	l_return_status   VARCHAR2(60)    := FND_API.G_RET_STS_SUCCESS;
	l_api_name	CONSTANT VARCHAR2(30)	:= 'Personalize LF Object';

BEGIN

       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	PERSONALIZE_LF_OBJECT_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

	JTF_PERZ_LF_PVT.save_lf_object
	( 	p_api_version_number,
  		p_init_msg_list,
		p_commit,
		p_profile_id  ,
		p_profile_name,
		p_profile_type,
		p_profile_attrib_tbl,
		p_application_id,
		p_parent_id,
		p_object_type_id,
		p_object_type,
		p_object_id,
		p_object_name,
		p_object_description,
		p_active_flag ,
		p_attrib_value_tbl,
		x_object_id,
		l_return_status,
		x_msg_count,
		x_msg_data
	);

	x_return_status := l_return_status;

      -- update the description of the object, not being done in the PVT package !
      if (l_return_status = FND_API.G_RET_STS_SUCCESS) then
          UPDATE JTF_PERZ_LF_OBJECT SET OBJECT_DESCRIPTION = p_object_description WHERE OBJECT_ID = x_object_id;
      end if;


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

	  ROLLBACK TO PERSONALIZE_LF_OBJECT_PUB;
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

	  ROLLBACK TO PERSONALIZE_LF_OBJECT_PUB;
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

	  ROLLBACK TO PERSONALIZE_LF_OBJECT_PUB;
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

-- ***************************************************************************
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
	l_api_version_number	NUMBER 	:= p_api_version_number;
	l_return_status   VARCHAR2(60)    := FND_API.G_RET_STS_SUCCESS;
	l_api_name	CONSTANT VARCHAR2(30)	:= 'Personalize LF Object';

BEGIN

       -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;



       -- ******* Get_lf_object implementation ********

	JTF_PERZ_LF_PVT.Get_lf_object
	( 	p_api_version_number,
		p_init_msg_list,
		p_application_id,
		p_priority,
		p_profile_id,
		p_profile_name,
		P_Object_Id,
		p_Object_Name,
		p_obj_active_flag,
		p_get_children_flag,
		x_Object_Tbl,
		l_return_status,
		x_msg_count,
		x_msg_data
	);

	  	x_return_status := l_return_status;

END Get_lf_object;


-- ***************************************************************************
PROCEDURE save_lf_object_type
( 	p_api_version_number	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_object_type_id        IN 	NUMBER,
	p_object_type           IN 	VARCHAR2,
	p_object_type_desc	IN 	VARCHAR2,

	p_attrib_rec_tbl	IN	JTF_PERZ_LF_PUB.ATTRIB_REC_TBL_TYPE
				:= JTF_PERZ_LF_PUB.G_MISS_ATTRIB_REC_TBL,

	x_object_type_id OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

       -- ******* save_lf_object Local Variables ********
	l_api_version_number	NUMBER 	:= p_api_version_number;
	l_return_status   VARCHAR2(60)    := FND_API.G_RET_STS_SUCCESS;
	l_api_name	CONSTANT VARCHAR2(30)	:= 'Personalize LF Object';

	l_obj_type_map_tbl JTF_PERZ_LF_PVT.OBJ_TYPE_MAP_TBL_TYPE;
BEGIN

       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	save_lf_object_type;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

	JTF_PERZ_LF_PVT.save_lf_object_type
	( 	p_api_version_number,
  		p_init_msg_list,
		p_commit,
		p_object_type_id,
		p_object_type,
		p_object_type_desc,
		p_attrib_rec_tbl,
		x_object_type_id,
		l_obj_type_map_tbl,
		l_return_status,
		x_msg_count,
		x_msg_data
	);

	x_return_status := l_return_status;

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

	  ROLLBACK TO save_lf_object_type;
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

	  ROLLBACK TO save_lf_object_type;
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

	  ROLLBACK TO save_lf_object_type;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;
END save_lf_object_type;
-- ***************************************************************************
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
	l_return_status   VARCHAR2(60)    := FND_API.G_RET_STS_SUCCESS;
	l_api_name	CONSTANT VARCHAR2(30)	:= 'Personalize LF Object';

BEGIN

       -- ******* Standard Begins ********

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;




       -- ******* Get_lf_object_type implementation ********

	JTF_PERZ_LF_PVT.Get_lf_object_type
	( 	p_api_version_number,
		p_init_msg_list,
		p_object_type,
		p_object_type_id,
		x_object_type_id,
		x_object_type_desc,
		x_attrib_rec_tbl,
		l_return_status,
		x_msg_count,
		x_msg_data
	);

	  	x_return_status := l_return_status;
END Get_lf_object_type;
END  JTF_PERZ_LF_PUB ;

/
