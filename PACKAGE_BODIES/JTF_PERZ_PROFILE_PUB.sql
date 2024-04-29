--------------------------------------------------------
--  DDL for Package Body JTF_PERZ_PROFILE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PERZ_PROFILE_PUB" as
/* $Header: jtfzppfb.pls 120.2 2005/11/02 04:20:20 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
--   JTF_PERZ_PROFILE_PUB
--
-- PURPOSE
--   Public API for
--
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for creating, getting and updating profiles in the Personalization
-- 	 framework.
--
-- HISTORY
--   07/26/99   SMATTEGU	Created
--   08/17/99   SMATTEGU	Changed the G_FILE_NAME value
-- 09/30/99	SMATTEGU	Changed update_profile(), create_profile()
--
--
-- End of Comments

--******************************************************************************
--******************************************************************************
G_PKG_NAME  	CONSTANT VARCHAR2(30):='JTF_PERZ_PROFILE_PUB';
G_FILE_NAME   	CONSTANT VARCHAR2(12):='jtfpppfb.pls';
--******************************************************************************
--
--	API name 	: Create_Profile
--	Type		: Public
--	Function	: Create Profile, given a profile name and
--			set of attributes/values
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER				Required
--			p_init_msg_list			IN VARCHAR2 			Optional
--			Default = FND_API.G_FALSE
--			p_profile_id            IN	NUMBER
--			p_profile_name          IN	VARCHAR2
--			p_profile_type			IN VARCHAR2
--			p_profile_desc			IN VARCHAR2
--			p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE,
--
-- OUT :
--			x_return_status	 OUT VARCHAR2(1)
--			x_msg_count		 OUT NUMBER
--			x_msg_data		 OUT VARCHAR2(2000)
--
--
--
--	Version	:	Current version	1.0
--			 	Initial version 1.0
--
--	Notes:	Personalization Framework API to create a profile,
--			This API will create a profile based on profile name,
--			profile attributes and values.
--
-- USAGE NOTES :
--
--	Procedure Name: Create_Profile
--		This procedure will insert the profile header and profile attributes
--		This procedure will in turn call
--		insert_profile() to insert Profile.
--		insert_profile_attributes() to insert the attributes
--		for a given profile.

--******************************************************************************

PROCEDURE Create_Profile
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
	p_profile_id            IN	NUMBER,
	p_profile_name          IN	VARCHAR2 := NULL,
	p_profile_type		IN VARCHAR2 := NULL,
	p_profile_desc		IN VARCHAR2 := NULL,
	p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
				:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

	x_profile_name      OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_profile_id        OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
	l_api_version_number	NUMBER 	:= p_api_version_number;
     l_api_name		CONSTANT VARCHAR2(30)	:= 'Create Profile';
	l_return_status    	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;


BEGIN

       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	CREATE_JTF_PERZ_PROFILE_PUB;

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
      x_return_status := FND_API.G_RET_STS_SUCCESS;

JTF_PERZ_PROFILE_PVT.Create_Profile
( 	l_api_version_number,
	p_init_msg_list,
	p_commit,
	p_profile_id,
	p_profile_name,
	p_profile_type,
	p_profile_desc,
	p_profile_attrib_tbl,
	x_profile_name,
	x_profile_id,
	l_return_status,
	x_msg_count,
	x_msg_data
);
	x_return_status := l_return_status;
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
	p_count     =>      x_msg_count,
       	p_data      =>      x_msg_data
    );

  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO CREATE_JTF_PERZ_PROFILE_PUB;
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

	  ROLLBACK TO CREATE_JTF_PERZ_PROFILE_PUB;
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

	  ROLLBACK TO CREATE_JTF_PERZ_PROFILE_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

END Create_Profile;

--******************************************************************************
--
-- Start of Comments
--
--	API name 	: Update_Profile

-- Start of Comments
--
--	API name 	: Update_Profile
--	Type		: Public
--	Function	: Update a profile with a given set of parameters
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER				Required
--			p_init_msg_list		IN VARCHAR2 	Optional
--						Default = FND_API.G_FALSE
--			p_profile_id            IN	NUMBER				Optional
--			p_profile_name          IN	VARCHAR2			Optional
--			p_profile_type		IN VARCHAR2
--			p_profile_desc		IN VARCHAR2
--			p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE,
--
-- OUT :
--			x_Profile_Tbl OUT JTF_PERZ_PROFILE_PUB.PROFILE_OUT_TBL,
--			x_return_status OUT VARCHAR2(1)
--			x_msg_count	 OUT NUMBER
--			x_msg_data	 OUT VARCHAR2(2000)
--
--
--
--	Version	:	Current version	1.0
--			 Initial version 1.0
--
-- USAGE NOTES :
--
--	Procedure Name: Update
--		This procedure will update the profile header and profile attributes
--		This procedure will in turn call
--			update_profile() to update Profile.
--			update_profile_attributes() to update the attributes
--				for a given profile.

--******************************************************************************
PROCEDURE Update_Profile
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
	p_profile_id            IN	NUMBER,
	p_profile_name          IN	VARCHAR2,
	p_profile_type		IN VARCHAR2,
	p_profile_desc		IN	VARCHAR2,
	p_active_flag		IN VARCHAR2,
	p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
				:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,
	x_profile_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

	l_api_version_number	NUMBER 	:= p_api_version_number;
     l_api_name		CONSTANT VARCHAR2(30)	:= 'Update Profile';
	l_return_status    	VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;


BEGIN

       -- ******* Standard Begins ********

      -- Standard Start of API savepoint
	 SAVEPOINT	UPDATE_JTF_PERZ_PROFILE_PUB;
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
--   	  -- Initialize API return status to success
         if x_return_status is null then
   	  	 x_return_status := FND_API.G_RET_STS_SUCCESS;
   	  end if;


JTF_PERZ_PROFILE_PVT.Update_Profile
( 	p_api_version_number,
	p_init_msg_list,
	p_commit,
	p_profile_id,
	p_profile_name,
	p_profile_type,
	p_profile_desc,
	p_active_flag,
	p_profile_attrib_tbl,
	x_profile_id,
	l_return_status,
	x_msg_count,
	x_msg_data
);
x_return_status := l_return_status;

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

	  ROLLBACK TO UPDATE_JTF_PERZ_PROFILE_PUB;
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

	  ROLLBACK TO UPDATE_JTF_PERZ_PROFILE_PUB;
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

	  ROLLBACK TO UPDATE_JTF_PERZ_PROFILE_PUB;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  FND_MSG_PUB.Count_And_Get
    		( p_count        	=>      x_msg_count,
        	  p_data          	=>      x_msg_data
    		);

	  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	  END IF;

END  Update_Profile;
--******************************************************************************
-- Start of Comments
--
--	API name 	: Get_Profile
--	Type		: Public
--	Function	: Return a profile(s) for a given set of parameters
--
--	Parameters	:
--	IN		:
--			p_api_version_number	IN NUMBER					Required
--			p_init_msg_list			IN VARCHAR2 				Optional
--									Default = FND_API.G_FALSE
--			p_profile_id            IN	NUMBER				Optional
--			p_profile_name          IN	VARCHAR2				Optional
--			p_profile_type			IN VARCHAR2
--			p_profile_desc			IN VARCHAR2
--			p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE,
--
-- OUT :
--			x_profile_tbl OUT JTF_PERZ_PROFILE_PUB.PROFILE_OUT_TBL,
--			x_return_status OUT VARCHAR2(1)
--			x_msg_count	 OUT NUMBER
--			x_msg_data	 OUT VARCHAR2(2000)
--
--
--
--	Version	:	Current version	    1.0
--			 	Initial version 	1.0
--
-- USAGE NOTES :
--
--******************************************************************************

--
PROCEDURE Get_Profile
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2  := FND_API.G_FALSE,

	p_profile_id           	IN	NUMBER,
	p_profile_name          IN	VARCHAR2,
	p_profile_type			IN 	VARCHAR2,
	p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
						:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

	x_profile_tbl	 OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_PROFILE_PUB.PROFILE_OUT_TBL_TYPE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count		 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

	l_api_version_number	NUMBER 	:= p_api_version_number;
     l_api_name		CONSTANT VARCHAR2(30)	:= 'Create Profile';
	l_return_status    	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;


BEGIN

       -- ******* Standard Begins ********

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

JTF_PERZ_PROFILE_PVT.Get_Profile
( 	l_api_version_number,
	p_init_msg_list,
	p_profile_id,
	p_profile_name,
	p_profile_type,
	p_profile_attrib_tbl,
	x_profile_tbl,
	l_return_status,
	x_msg_count,
	x_msg_data
);

	if (l_return_status = FND_API.G_RET_STS_ERROR) then
	  	x_return_status := FND_API.G_RET_STS_ERROR ;
	elsif(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
	  	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	else
      	x_return_status := FND_API.G_RET_STS_SUCCESS;
	end if;
-- x_return_status := FND_API.G_RET_STS_SUCCESS;
-- x_profile_tbl(1).PROFILE_ID := 786;
-- x_profile_tbl(1).PROFILE_NAME := 'cchandra';
-- x_profile_tbl(1).PROFILE_TYPE := 'TYPE';
--
-- x_profile_tbl(1).PROFILE_ATTRIBUTE := 'attrib100';
-- x_profile_tbl(1).attribute_type := 'attribtype1';
-- x_profile_tbl(1).attribute_value := 'attribval1';
end Get_Profile;
--******************************************************************************
--******************************************************************************
END  JTF_PERZ_PROFILE_PUB ;

/
