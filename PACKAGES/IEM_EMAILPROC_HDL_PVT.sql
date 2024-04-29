--------------------------------------------------------
--  DDL for Package IEM_EMAILPROC_HDL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_EMAILPROC_HDL_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvpros.pls 120.0.12010000.2 2009/07/11 16:49:40 lkullamb ship $ */



 --  transfer display date format to canonical date format
 -- ***************************************************************************

 FUNCTION displayDT_to_canonical ( displayDT    IN   VARCHAR2 )return varchar2;


-- ************************************************************************
--  Start of Comments
--  API name    : create_item_account_emailprocs
--  Type        : Private
--  Function    : This procedure create a tuple in iem_account_emailprocs table
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_email_account_id      IN VARCHAR2                 Required
--      p_emailproc_id  	        IN   VARCHAR2               Required
--      p_enabled_flag          IN   VARCHAR2,              Required
--      p_priority              IN VARCHAR2,                Required

--      OUT
--      x_return_status         OUT     VARCHAR2
--      x_msg_count             OUT     NUMBER
--      x_msg_data              OUT     VARCHAR2
--
--      Version : 1.0
--      Notes           :
--
-- End of comments
-- **********************************************************
PROCEDURE create_item_account_emailprocs (
                 p_api_version_number     IN NUMBER,
 		  	     p_init_msg_list          IN VARCHAR2 := null,
		    	 p_commit	              IN VARCHAR2 := null,
                 p_email_account_id       IN NUMBER,
  				 p_emailproc_id           IN NUMBER,
                 p_enabled_flag           IN VARCHAR2,
                 p_priority               IN NUMBER,
                 x_return_status	      OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	          OUT NOCOPY NUMBER,
	  	  	     x_msg_data	              OUT NOCOPY VARCHAR2
			 );

-- ************************************************************************
--  Start of Comments
--  API name    : update_item_emailproc
--  Type        : Private
--  Function    : This procedure update route in update_item_emailproc table
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE

--      p_route_id              IN NUMBER                   Optional Default = FND_API.G_MISS_NUM
--      p_name  	            IN VARCHAR2                 Optional Default = FND_API.G_MISS_CHAR
--      p_description           IN VARCHAR2,                Optional Default = FND_API.G_MISS_CHAR

--      p_ruling_chain          IN VARCHAR2,                Optional Default = FND_API.G_MISS_CHAR
--      p_proc_name             IN VARCHAR2,                Optional Default = FND_API.G_MISS_CHAR
--                              this is procedure name for dynamic route ( 11.5.7)
--      OUT
--      x_return_status         OUT     VARCHAR2
--      x_msg_count             OUT     NUMBER
--      x_msg_data              OUT     VARCHAR2
--
--      Version : 1.0
--      Notes           :

--
-- End of comments
-- **********************************************************
PROCEDURE update_item_emailproc (
                 p_api_version_number    IN   NUMBER,
    	  	     p_init_msg_list    IN   VARCHAR2 := null,
    	    	 p_commit	        IN   VARCHAR2 := null,
    			 p_emailproc_id     IN   NUMBER,
    			 p_name             IN   VARCHAR2:= null,
                 p_description	    IN   VARCHAR2:= null,
                 p_ruling_chain	    IN   VARCHAR2:= null,
                 p_all_email	    IN   VARCHAR2:= null,
                 p_rule_type	    IN   VARCHAR2:= null,
			     x_return_status	OUT	NOCOPY VARCHAR2,
  		  	     x_msg_count	    OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	        OUT	NOCOPY VARCHAR2
			 );




-- ************************************************************************
--  Start of Comments
--  API name    : update_item_rule
--  Type        : Private
--  Function    : This procedure update route in iem_emailproc_rules table
--  Pre-reqs    : None.

--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_key_type_code         IN NUMBER                 Optional Default = FND_API.G_MISS_NUM
--      p_key_type_code         IN VARCHAR2                 Optional Default = FND_API.G_MISS_CHAR
--      p_operator_type_code  	IN VARCHAR2                 Optional Default = FND_API.G_MISS_CHAR
--      p_value                 IN VARCHAR2,                Optional Default = FND_API.G_MISS_CHAR
--      OUT
--      x_return_status         OUT     VARCHAR2
--      x_msg_count             OUT     NUMBER
--      x_msg_data              OUT     VARCHAR2
--
--      Version : 1.0
--      Notes           :
--
-- End of comments
-- **********************************************************
PROCEDURE update_item_rule (p_api_version_number    IN   NUMBER,
     	  	     p_init_msg_list            IN   VARCHAR2 := null,
    	    	 p_commit	                IN   VARCHAR2 := null,
                 p_emailproc_rule_id        IN   NUMBER,
      			 p_key_type_code            IN   VARCHAR2:= null,
      			 p_operator_type_code	    IN   VARCHAR2:= null,
      			 p_value	                IN   VARCHAR2:= null,
			      x_return_status	        OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	            OUT NOCOPY NUMBER,
	  	  	      x_msg_data	            OUT	NOCOPY VARCHAR2
			 );

-- ************************************************************************
--  Start of Comments
--  API name    : update_account_emailprocs
--  Type        : Private

--  Function    : This procedure update  iem_account_emailprocs table
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER        Required
--      p_init_msg_list         IN VARCHAR2      Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2      Optional Default = FND_API.G_FALSE
--      p_route_id              IN NUMBER        Optional Default = FND_API.G_MISS_NUM
--      p_email_account_id      IN VARCHAR2      Optional Default = FND_API.G_MISS_CHAR
--      p_default_grp_id  	     IN VARCHAR2     Optional Default = FND_API.G_MISS_CHAR
--      p_enabled_flag           IN VARCHAR2,    Optional Default = FND_API.G_MISS_CHAR
--      p_priority               IN NUMBER       Optional Default = FND_API.G_MISS_NUM
--      OUT
--      x_return_status         OUT     VARCHAR2
--      x_msg_count             OUT     NUMBER
--      x_msg_data              OUT     VARCHAR2
--
--      Version : 1.0
--      Notes           :
--
-- End of comments
-- **********************************************************

PROCEDURE update_account_emailprocs
                (p_api_version_number       IN  NUMBER,
 	  	        p_init_msg_list             IN  VARCHAR2 := null,
	    	    p_commit	                IN  VARCHAR2 := null,
                p_emailproc_id              IN  NUMBER,
			    p_email_account_id          IN  NUMBER,
  			    p_enabled_flag	            IN  VARCHAR2:= NULL,
  			    p_priority	                IN  VARCHAR2:= NULL,
                x_return_status	            OUT	NOCOPY VARCHAR2,
  		  	    x_msg_count	                OUT NOCOPY NUMBER,
	  	  	    x_msg_data	                OUT NOCOPY VARCHAR2
			 );


  -- ************************************************************************

--  Start of Comments
--  API name    : create_item_emailprocs
--  Type        : Private
--  Function    : This procedure create a route in iem_emailprocs table
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                   Required

--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_name                  IN VARCHAR2                 Required
--      p_description	        IN   VARCHAR2               Optional Default = FND_API.G_MISS_CHAR
--      p_boolean_type_code     IN   VARCHAR2,              Required

--      OUT
--      x_return_status         OUT     VARCHAR2
--      x_msg_count             OUT     NUMBER
--      x_msg_data              OUT     VARCHAR2
--
--      Version : 1.0
--      Notes           :

--
-- End of comments
-- **********************************************************

PROCEDURE create_item_emailprocs (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_name                IN   VARCHAR2,
  				 p_description	       IN   VARCHAR2:= null,
         		 p_boolean_type_code   IN   VARCHAR2,
                 P_rule_type           IN   VARCHAR2,
                 p_all_email           IN   VARCHAR2,
                 x_emailproc_id        OUT NOCOPY NUMBER,
                 x_return_status	   OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY VARCHAR2
			 );

-- ************************************************************************
--  Start of Comments
--  API name    : create_item_emailproc_rules
--  Type        : Private
--  Function    : This procedure create a route in iem_emailproc_rules table
--  Pre-reqs    : None.
--  Parameters  :

--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_route_id              IN VARCHAR2                 Required
--      p_key_type_code	        IN   VARCHAR2               Optional Default = FND_API.G_MISS_CHAR
--      p_operator_type_code    IN   VARCHAR2,              Required
--      p_value                 IN VARCHAR2,                Required

--      OUT
--      x_return_status         OUT     VARCHAR2
--      x_msg_count             OUT     NUMBER
--      x_msg_data              OUT     VARCHAR2
--
--      Version : 1.0

--      Notes           :
--
-- End of comments
-- *********************************************************************************************
PROCEDURE create_item_emailproc_rules (
                 p_api_version_number   IN   NUMBER,
 		  	     p_init_msg_list        IN   VARCHAR2 := null,
		    	 p_commit	            IN   VARCHAR2 := null,
  				 p_emailproc_id         IN   NUMBER,
  				 p_key_type_code	    IN   VARCHAR2,
  				 p_operator_type_code	IN   VARCHAR2,
                 p_value                IN VARCHAR2,
                 x_return_status	    OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT	NOCOPY VARCHAR2
			 );

PROCEDURE create_item_actions (
                 p_api_version_number     IN NUMBER,
 		  	     p_init_msg_list          IN VARCHAR2 := null,
		    	 p_commit	              IN VARCHAR2 := null,
  				 p_emailproc_id           IN NUMBER,
                 p_action_name            IN VARCHAR2,
                 x_action_id              OUT NOCOPY NUMBER,
                 x_return_status	      OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	          OUT NOCOPY NUMBER,
	  	  	     x_msg_data	              OUT NOCOPY VARCHAR2
			 );

PROCEDURE create_item_action_dtls (
                 p_api_version_number   IN   NUMBER,
 		  	     p_init_msg_list    IN  VARCHAR2 := null,
		    	 p_commit	        IN  VARCHAR2 := null,
  				 p_action_id        IN  NUMBER,
  				 p_param1	        IN  VARCHAR2,
  				 p_param2	        IN  VARCHAR2,
  				 p_param3	        IN  VARCHAR2,
                 p_param_tag        IN  VARCHAR2,
                 x_return_status	OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	    OUT NOCOPY NUMBER,
	  	  	     x_msg_data	        OUT	NOCOPY VARCHAR2
			 );

PROCEDURE delete_acct_emailproc_batch
     (p_api_version_number      IN  NUMBER,
      P_init_msg_list           IN  VARCHAR2 := null,
      p_commit                  IN  VARCHAR2 := null,
      p_emailproc_ids_tbl       IN  jtf_varchar2_Table_100,
      p_account_id              IN NUMBER,
      p_rule_type               IN VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2);

END IEM_EMAILPROC_HDL_PVT;

/
