--------------------------------------------------------
--  DDL for Package IEM_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_PARAMETERS_PVT" AUTHID CURRENT_USER as
/* $Header: iemvpars.pls 115.4 2002/12/04 01:23:00 chtang noship $ */

-- Start of Comments
--  API name    : select_profile
--  Type        : Private
--  Function    : This procedure retrieve FND profile
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--  p_api_version_number        IN NUMBER       Required
--  p_init_msg_list     IN VARCHAR2     Optional Default = FND_API.G_FALSE
--  p_commit    IN VARCHAR2     Optional Default = FND_API.G_FALSE
--  p_profile_name IN   VARCHAR2,
--  x_profile_value     OUT   VARCHAR2,
--      OUT
--   x_return_status    OUT     VARCHAR2
--      x_msg_count     OUT     NUMBER
--      x_msg_data      OUT     VARCHAR2
--
--      Version : 1.0
--      Notes           :
--
-- End of comments
-- **********************************************************
PROCEDURE select_profile (p_api_version_number  IN   NUMBER,
 		          p_init_msg_list  	IN   VARCHAR2 := FND_API.G_FALSE,
		          p_commit	    	IN   VARCHAR2 := FND_API.G_FALSE,
  			  p_profile_name    	IN   VARCHAR2,
  			  x_profile_value OUT NOCOPY  VARCHAR2,
             		  x_return_status OUT NOCOPY  VARCHAR2,
  		  	  x_msg_count	       OUT NOCOPY  NUMBER,
	  	  	  x_msg_data	 OUT NOCOPY  VARCHAR2
			 ) ;

-- Start of Comments
--  API name    : update_profile
--  Type        : Private
--  Function    : This procedure updates FND profile
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--  p_api_version_number        IN NUMBER       Required
--  p_init_msg_list     IN VARCHAR2     Optional Default = FND_API.G_FALSE
--  p_commit    IN VARCHAR2     Optional Default = FND_API.G_FALSE
--  p_profile_name IN   VARCHAR2,
--  p_profile_value     IN   VARCHAR2,
--      OUT
--   x_return_status    OUT     VARCHAR2
--      x_msg_count     OUT     NUMBER
--      x_msg_data      OUT     VARCHAR2
--
--      Version : 1.0
--      Notes           :
--
-- End of comments
-- **********************************************************

PROCEDURE update_profile (p_api_version_number  IN   NUMBER,
 		          p_init_msg_list  	IN   VARCHAR2,
		          p_commit	    	IN   VARCHAR2,
  			  p_profile_name    	IN   VARCHAR2,
  			  p_profile_value	IN   VARCHAR2,
             		  x_return_status OUT NOCOPY VARCHAR2,
  		  	  x_msg_count	       OUT NOCOPY NUMBER,
	  	  	  x_msg_data	 OUT NOCOPY VARCHAR2
			 ) ;

PROCEDURE update_profile_wrap (p_api_version_number  IN   NUMBER,
 		          p_init_msg_list  	IN   VARCHAR2,
		          p_commit	    	IN   VARCHAR2,
  			  p_profile_name_tbl 	IN   jtf_varchar2_Table_100,
  			  p_profile_value_tbl	IN   jtf_varchar2_Table_100,
             		  x_return_status OUT NOCOPY VARCHAR2,
  		  	  x_msg_count	       OUT NOCOPY NUMBER,
	  	  	  x_msg_data	 OUT NOCOPY VARCHAR2
			 );

 END IEM_PARAMETERS_PVT ;

 

/
