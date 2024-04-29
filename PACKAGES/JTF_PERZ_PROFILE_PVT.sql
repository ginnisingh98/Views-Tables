--------------------------------------------------------
--  DDL for Package JTF_PERZ_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_PROFILE_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfzvpfs.pls 120.2 2005/11/02 22:47:53 skothe ship $ */
--
--
-- Start of Comments
--
-- NAME
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
--   06/03/99   SMATTEGU      Created
--   06/10/99   SMATTEGU      Added Update_Profile, Get_Profile
--   06/11/99   SMATTEGU      Added check_profile_duplicates,
--				check_prof_attrib_duplicates
-- 09/30/99  SMATTEGU	Chnaged the create_profile() to handle profile_id also.
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--	Procedure Name: Create_Profile
--		This procedure will insert the profile header and profile attributes
--		This procedure will in turn call
--			insert_profile() to insert Profile.
--			insert_profile_attributes() to insert the attributes
--				for a given profile.
--	Input Paramaters:
--		p_api_version_number
--		p_init_msg_list
--		p_commit
--		p_profile_id
--		p_profile_name
--		p_profile_desc
--		p_Profile_ATTRIB_Tbl
--	Output Paramaters:
--		x_Profile_Tbl
--		x_return_status
--		x_msg_count
--		x_msg_data
-- *****************************************************************************

PROCEDURE Create_Profile
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		    IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit				IN	VARCHAR2 := FND_API.G_FALSE,

	p_profile_id		IN	NUMBER,
	p_profile_name          IN	VARCHAR2 := NULL,
	p_profile_type			IN VARCHAR2 := NULL,
	p_profile_desc          IN	VARCHAR2 := NULL,
	p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
						 	:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

	x_profile_name      OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_profile_id        OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count		 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


-- *****************************************************************************
--
-- USAGE NOTES :
--
--	Procedure Name: Update
--		This procedure will update the profile header and profile attributes
--		This procedure will in turn call
--			update_profile() to update Profile.
--			update_profile_attributes() to update the attributes
--				for a given profile.
--	Input Paramaters:
--		p_api_version_number
--		p_init_msg_list
--		p_profile_name
--		p_profile_desc
--		p_profile_attrib_tbl
--	Output Paramaters:
--		x_Profile_Tbl
--		x_return_status
--		x_msg_count
--		x_msg_data
-- *****************************************************************************

PROCEDURE Update_Profile
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,

	p_profile_id            IN	NUMBER,
	p_profile_name          IN	VARCHAR2,
	p_profile_type		IN VARCHAR2 := NULL,
	p_profile_desc          IN	VARCHAR2,
	p_active_flag		IN VARCHAR2,
	p_Profile_ATTRIB_Tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE,

	x_profile_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


-- *****************************************************************************
PROCEDURE Get_Profile
( 	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2  := FND_API.G_FALSE,

	p_profile_id            IN	NUMBER := NULL,
	p_profile_name          IN	VARCHAR2 := NULL,
	p_profile_type		IN VARCHAR2 := NULL,
	p_profile_attrib_tbl	IN	JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE
				:= JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,

	x_profile_tbl	 OUT NOCOPY /* file.sql.39 change */ JTF_PERZ_PROFILE_PUB.PROFILE_OUT_TBL_TYPE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

-- *****************************************************************************
--
-- USAGE NOTES :
--
--	check_profile_duplicates procedure checks the duplicate  entries in
--	profile table.
--	Input Paramaters:
--		p_profile_name
--			This specifies the profile name which is used to check the
--			duplicates
--	Output Parameters:
--		x_profile_id
--			If the duplicate exists, the profile id of the existing profile
--			will be returned
--		x_return_status
--			This will be Yes if there is already an entry.
--			Otherwise,this will be No.
--		x_return_count
--			This returns the number of duplicates (if any)
--
--
-- *****************************************************************************
PROCEDURE check_profile_duplicates(
	p_profile_name      IN   VARCHAR2,
	x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 	x_profile_id        IN OUT NOCOPY /* file.sql.39 change */  NUMBER
);

-- *****************************************************************************
--
-- USAGE NOTES :
--
--	check_prof_attrib_duplicates procedure checks the duplicate  entries in
--	profile attribute table.
--	Input Paramaters:
--		p_Profile_ATTRIB_Tbl
--			This specifies the profile attribute set which is used to check
--			the duplicates
--	Output Parameters:
--		x_profile_id
--			If the duplicate exists, the profile id of the existing profile
--			will be returned
--		x_return_status
--			This will be Yes if there is already an entry.
--			Otherwise,this will be No.
--		x_return_count
--			This returns the number of duplicates (if any)
--
--
-- *****************************************************************************

-- PROCEDURE check_prof_attrib_duplicates
-- (	p_profile_attrib_tbl    IN   JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE,
--  	x_return_status	 OUT  	BOOLEAN,
-- 	x_profile_id	 OUT  NUMBER
-- );
-- ****************************************************************************
-- ****************************************************************************
END JTF_PERZ_PROFILE_PVT;

 

/
