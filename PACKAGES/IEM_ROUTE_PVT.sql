--------------------------------------------------------
--  DDL for Package IEM_ROUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_ROUTE_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvrous.pls 115.9 2002/12/04 20:20:38 liangxia noship $ */
--
--
-- Purpose: Mantain route related operations
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   4/24/2001    Created
--  Liang Xia   6/7/2001     added checking duplication on IEM_ROUTES.name for PROCEDURE
--                           create_item_routes and update_item_route
--                           added updating priority in IEM_ACCOUNT_ROUTES for delete_item_batch
--  Liang Xia   6/7/2002     added validation for dynamic Route
--  Liang Xia   11/6/2002    release the validation for ALL_EMAILS and fixed part of "No MISS.." GSCC warning.
--  Liang Xia   12/2/2002    Fixed PLSQL standard: "No MISS.." "NOCOPY" GSCC warning.
-- ---------   ------  ------------------------------------------


--  Start of Comments
--  API name    : delete_item_batch
--  Type        : Private
--  Function    : This procedure delete a batch of records in the table IEM_ROUTES
--  Pre-reqs    : None.
--  Parameters  :

--      IN
--      p_api_version_number    IN NUMBER                   Required

--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_route_ids_tbl         IN jtf_varchar2_Table_100   Required
--      p_account_name          IN VARCHAR2 :=FND_API.G_MISS_CHAR,

--      OUT
--      x_return_status     OUT     VARCHAR2
--      x_msg_count         OUT     NUMBER
--      x_msg_data          OUT     VARCHAR2
--
--      Version : 1.0

--      Notes           :

--
-- End of comments
-- ***************************************************************************
/* $Header: iemvrous.pls 115.9 2002/12/04 20:20:38 liangxia noship $ */
PROCEDURE delete_item_batch
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_route_ids_tbl           IN  jtf_varchar2_Table_100,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);



--  Start of Comments
--  API name    : delete_acct_route_by_acct
--  Type        : Private
--  Function    : This procedure delete records in the table IEM_ACCOUT_ROUTES based on email_account_id
--  Pre-reqs    : None.
--  Parameters  :

--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_email_account_id      IN NUMBER                     Required


--      OUT
--      x_return_status     OUT     VARCHAR2
--      x_msg_count         OUT     NUMBER
--      x_msg_data          OUT     VARCHAR2
--
--      Version : 1.0

--      Notes           :
--
-- End of comments
-- ***************************************************************************
PROCEDURE delete_acct_route_by_acct
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_email_account_id        IN  NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);



 --  transfer display date format to canonical date format
 -- ***************************************************************************

 FUNCTION displayDT_to_canonical ( displayDT    IN   VARCHAR2 )return varchar2;

-- ***************************************************************************
--  Start of Comments
--  API name    : create_item_wrap

--  Type        : Private
--  Function    : This procedure is a wrap function to create route involved
--                inserting tuple in iem_routes table and iem_route_rules table
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                   Required

--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_route_name            IN VARCHAR2                 Required
--      p_route_description	    IN VARCHAR2                 Optional Default = FND_API.G_MISS_CHAR
--      p_route_boolean_type_code    IN jtf_varchar2_Table_100      Optional Default = jtf_varchar2_Table_100
--      Post 11.5.7 MP-O         For static route: AND, OR
--                               For dynamic route: DYNAMIC

--      p_rule_operator_typecode_tbl IN jtf_varchar2_Table_100      Optional Default = jtf_varchar2_Table_100

--      p_rule_value_tbl             IN jtf_varchar2_Table_300      Optional Default = jtf_varchar2_Table_300

--      OUT
--      x_return_status         OUT     VARCHAR2
--      x_msg_count             OUT     NUMBER
--      x_msg_data              OUT     VARCHAR2

--
--      Version : 1.0
--      Notes           :
--
-- End of comments
-- ***********************************************************************
PROCEDURE create_item_wrap (

                p_api_version_number        IN   NUMBER,
                p_init_msg_list             IN   VARCHAR2 := null,
                p_commit                    IN   VARCHAR2 := null,
                p_route_name                IN   VARCHAR2,
     	        p_route_description         IN   VARCHAR2:= null,
                p_route_boolean_type_code   IN   VARCHAR2,
                p_proc_name                 IN   VARCHAR2 := null,
                p_all_email                 IN   VARCHAR2:= null,
                p_rule_key_typecode_tbl     IN  jtf_varchar2_Table_100,
                p_rule_operator_typecode_tbl IN  jtf_varchar2_Table_100,
                p_rule_value_tbl            IN  jtf_varchar2_Table_300,
                x_return_status             OUT NOCOPY VARCHAR2,
                x_msg_count                 OUT NOCOPY NUMBER,
                x_msg_data                  OUT NOCOPY VARCHAR2 );





-- ************************************************************************

--  Start of Comments
--  API name    : create_item_routes
--  Type        : Private
--  Function    : This procedure create a route in iem_routes table
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                   Required

--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_name                  IN VARCHAR2                 Required
--      p_description	        IN   VARCHAR2               Optional Default = FND_API.G_MISS_CHAR

--      p_boolean_type_code     IN   VARCHAR2,              Required
--      p_proc_name             IN   VARCHAR2               FND_API.G_MISS_CHAR,
--              11.5.7(MP-O)    For Dynamic Route
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

PROCEDURE create_item_routes (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_name                IN   VARCHAR2,
  				 p_description	       IN   VARCHAR2:= null,
         		 p_boolean_type_code   IN   VARCHAR2,
                 p_proc_name           IN   VARCHAR2 := null,
                 p_all_email           IN   VARCHAR2 := null,
                 p_return_type         IN   VARCHAR2 := null,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 );




-- ************************************************************************
--  Start of Comments
--  API name    : create_item_route_rules
--  Type        : Private
--  Function    : This procedure create a route in iem_route_rules table
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
PROCEDURE create_item_route_rules (
                 p_api_version_number   IN   NUMBER,
 		  	     p_init_msg_list        IN   VARCHAR2 := null,
		    	 p_commit	            IN   VARCHAR2 := null,
  				 p_route_id             IN   NUMBER,
  				 p_key_type_code	    IN   VARCHAR2,
  				 p_operator_type_code	IN   VARCHAR2,
                 p_value                IN VARCHAR2,
                 x_return_status	    OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT	NOCOPY VARCHAR2
			 );



-- ************************************************************************
--  Start of Comments
--  API name    : create_item_accout_routes
--  Type        : Private

--  Function    : This procedure create a tuple in iem_account_routes table

--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_email_account_id      IN VARCHAR2                 Required
--      p_route_id  	        IN   VARCHAR2               Required
--      p_destination_group_id  IN   VARCHAR2,              Required
--      p_default_grp_id        IN VARCHAR2,                Required
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
PROCEDURE create_item_account_routes (
                 p_api_version_number     IN NUMBER,
 		  	     p_init_msg_list          IN VARCHAR2 := null,
		    	 p_commit	              IN VARCHAR2 := null,
                 p_email_account_id       IN NUMBER,
  				 p_route_id               IN NUMBER,
  				 p_destination_group_id	  IN NUMBER,
                 p_default_grp_id         IN NUMBER,
                 p_enabled_flag           IN VARCHAR2,
                 p_priority               IN NUMBER,
                 x_return_status	      OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	          OUT NOCOPY NUMBER,
	  	  	     x_msg_data	              OUT NOCOPY VARCHAR2
			 );



-- ************************************************************************
--  Start of Comments
--  API name    : update_item_wrap
--  Type        : Private
--  Function    : This procedure is a update wraper, involved updating iem_routes table,
--                 updating iem_route_rules table, insert new item into iem_route_rules table, deleting
--                  from iem_route_rules table.
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE


--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--	                         p_route_id      IN   NUMBER:=FND_API.G_MISS_NUM,
--  	p_name          IN   VARCHAR2:=FND_API.G_MISS_CHAR,
--  	p_ruling_chain	        IN   VARCHAR2:=FND_API.G_MISS_CHAR,
--      p_description           IN   VARCHAR2:=FND_API.G_MISS_CHAR,
--      p_update_rule_ids_tbl   IN  jtf_varchar2_Table_100,
--      p_update_rule_keys_tbl  IN  jtf_varchar2_Table_100,
--      p_update_rule_operators_tbl IN  jtf_varchar2_Table_100,
--      p_update_rule_values_tbl    IN  jtf_varchar2_Table_300,
--      p_new_rule_keys_tbl         IN  jtf_varchar2_Table_100,
--      p_new_rule_operators_tbl    IN  jtf_varchar2_Table_100,
--      p_new_rule_values_tbl       IN  jtf_varchar2_Table_300,

--      p_remove_rule_ids_tbl       IN  jtf_varchar2_Table_100,


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

 PROCEDURE update_item_wrap (p_api_version_number   IN   NUMBER,
 	                         p_init_msg_list        IN   VARCHAR2 := null,
	                         p_commit	            IN   VARCHAR2 := null,
	                         p_route_id             IN   NUMBER,
  	                         p_name                 IN   VARCHAR2:= null,
  	                         p_ruling_chain	        IN   VARCHAR2:= null,
                             p_description          IN   VARCHAR2:= null,
                             p_procedure_name       IN   VARCHAR2:= null,
                             p_all_emails           IN   VARCHAR2:= null,
                             --below is the data for update
                             p_update_rule_ids_tbl IN  jtf_varchar2_Table_100,
                             p_update_rule_keys_tbl IN  jtf_varchar2_Table_100,
  	                         p_update_rule_operators_tbl IN  jtf_varchar2_Table_100,

                             p_update_rule_values_tbl IN  jtf_varchar2_Table_300,
                             -- below is the data for insert
                             p_new_rule_keys_tbl IN  jtf_varchar2_Table_100,

  	                         p_new_rule_operators_tbl IN  jtf_varchar2_Table_100,
                             p_new_rule_values_tbl IN  jtf_varchar2_Table_300,
                             --below is the data to be removed
                             p_remove_rule_ids_tbl IN  jtf_varchar2_Table_100,

                             x_return_status         OUT NOCOPY VARCHAR2,
                             x_msg_count             OUT NOCOPY NUMBER,
                             x_msg_data              OUT NOCOPY VARCHAR2 );




-- ************************************************************************
--  Start of Comments
--  API name    : update_item_route
--  Type        : Private
--  Function    : This procedure update route in iem_routes table
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
PROCEDURE update_item_route (
                 p_api_version_number   IN   NUMBER,
    	  	     p_init_msg_list        IN   VARCHAR2 := null,
    	    	 p_commit	            IN   VARCHAR2 := null,
    			 p_route_id             IN   NUMBER,
    			 p_name                 IN   VARCHAR2:= null,
    			 p_description	        IN   VARCHAR2:= null,
                 p_all_emails           IN   VARCHAR2:= null,
                 p_proc_name	        IN   VARCHAR2:= null,
                 p_return_type          IN   VARCHAR2:= null,
    			 p_ruling_chain	        IN   VARCHAR2:= null,
			     x_return_status	    OUT	NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT	NOCOPY VARCHAR2
			 )  ;




-- ************************************************************************
--  Start of Comments
--  API name    : update_item_rule
--  Type        : Private
--  Function    : This procedure update route in iem_routes table
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
PROCEDURE update_item_rule
                (p_api_version_number       IN  NUMBER,
     	  	     p_init_msg_list            IN  VARCHAR2 := null,
    	    	 p_commit	                IN  VARCHAR2 := null,
                 p_route_rule_id            IN  NUMBER   := null,
      			 p_key_type_code            IN  VARCHAR2:= null,
      			 p_operator_type_code	    IN  VARCHAR2:= null,
      			 p_value	                IN   VARCHAR2:= null,
			      x_return_status	        OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	            OUT NOCOPY NUMBER,
	  	  	      x_msg_data	            OUT	NOCOPY VARCHAR2
			 ) ;




-- ************************************************************************
--  Start of Comments
--  API name    : create_wrap_account_routes
--  Type        : Private
--  Function    : This procedure is a wrap function to create account_route in iem_account_routes table
--  Pre-reqs    : None.
--  Parameters  :

--      IN
--      p_api_version_number    IN NUMBER                 Required
--      p_init_msg_list         IN VARCHAR2               Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2               Optional Default = FND_API.G_FALSE
--      p_email_account_id      IN NUMBER                 Required

--      p_route_id	            IN NUMBER                 Requred
--      p_destination_group_id  IN NUMBER,                Required
--      p_default_grp_id        IN NUMBER,                Required
--      p_enabled_flag          IN VARCHAR2               Required
--      p_priority              IN NUMBER                 Required

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
PROCEDURE create_wrap_account_routes (
                     p_api_version_number   IN   NUMBER,
        		  	 p_init_msg_list        IN   VARCHAR2 := null,
        		     p_commit	            IN   VARCHAR2 := null,
                     p_email_account_id     IN   NUMBER,
      				 p_route_id             IN   NUMBER,
      				 p_destination_group_id	IN   NUMBER,
                     p_default_grp_id       IN   NUMBER,
                     p_enabled_flag         IN   VARCHAR2,
                     p_priority             IN   NUMBER,
                     x_return_status	    OUT NOCOPY VARCHAR2,
      		  	     x_msg_count	        OUT NOCOPY NUMBER,
    	  	  	     x_msg_data 	        OUT	NOCOPY VARCHAR2
			 );


-- ************************************************************************
--  Start of Comments
--  API name    : update_account_routes
--  Type        : Private

--  Function    : This procedure update  iem_account_routes table
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_route_id              IN NUMBER                   Optional Default = FND_API.G_MISS_NUM
--      p_email_account_id      IN VARCHAR2                 Optional Default = FND_API.G_MISS_CHAR

--      p_default_grp_id  	     IN VARCHAR2                 Optional Default = FND_API.G_MISS_CHAR
--      p_enabled_flag           IN VARCHAR2,                Optional Default = FND_API.G_MISS_CHAR
--      p_priority               IN NUMBER                   Optional Default = FND_API.G_MISS_NUM

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

PROCEDURE update_account_routes(p_api_version_number    IN   NUMBER,
 	  	            p_init_msg_list         IN   VARCHAR2 := null,
	    	        p_commit	            IN   VARCHAR2 := null,
                    p_route_id              IN   NUMBER,
			        p_email_account_id      IN   NUMBER,
  			        p_destination_grp_id    IN   VARCHAR2:= null,
  			        p_default_grp_id	    IN   VARCHAR2:= null,
  			        p_enabled_flag	        IN   VARCHAR2:= null,
  			        p_priority	            IN   VARCHAR2:= null,
                    x_return_status	        OUT	NOCOPY VARCHAR2,
  		  	        x_msg_count	            OUT	NOCOPY NUMBER,
	  	  	        x_msg_data	            OUT	NOCOPY VARCHAR2
			 );




-- ************************************************************************
--  Start of Comments
--  API name    : delete_acct_route_batch
--  Type        : Private
--  Function    : This procedure delete items from iem_account_routes table
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE

--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE

--      p_route_ids_tbl         IN  jtf_varchar2_Table_100,
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
PROCEDURE delete_acct_route_batch
     (p_api_version_number      IN  NUMBER,
      P_init_msg_list           IN  VARCHAR2 := null,
      p_commit                  IN  VARCHAR2 := null,
      p_route_ids_tbl           IN  jtf_varchar2_Table_100,
      p_account_id              IN  NUMBER,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2);


-- ************************************************************************
--  Start of Comments


--  API name    : update_wrap_account_routes
--  Type        : Private
--  Function    : This procedure is a wrap function to update account_route in iem_account_routes table
--                   involved in update iem_account_routes table and delete from iem_account_routes table
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                 Required
--      p_init_msg_list         IN VARCHAR2               Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2               Optional Default = FND_API.G_FALSE
--      p_email_account_id      IN NUMBER                 Required
--      p_route_id	            IN NUMBER                 Requred
--      p_destination_group_id  IN NUMBER,                Required


--      p_default_grp_id        IN NUMBER,                Required
--      p_enabled_flag          IN VARCHAR2               Required
--      p_priority              IN NUMBER                 Required

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
PROCEDURE update_wrap_account_routes
                (p_api_version_number   IN   NUMBER,
 		  	     p_init_msg_list        IN   VARCHAR2 := null,
		    	 p_commit	            IN   VARCHAR2 := null,
                 p_email_account_id     IN NUMBER,
  				 p_route_ids_tbl        IN  jtf_varchar2_Table_100,
  				 p_upd_dest_ids_tbl     IN  jtf_varchar2_Table_100,

                 p_upd_default_ids_tbl  IN  jtf_varchar2_Table_100,
                 p_upd_enable_flag_tbl  IN  jtf_varchar2_Table_100,
                 --p_upd_priority_tbl IN  jtf_varchar2_Table_100,

                 p_delete_route_ids_tbl IN  jtf_varchar2_Table_100,

                 x_return_status        OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT	NOCOPY VARCHAR2
			 ) ;
END IEM_ROUTE_PVT;

 

/
