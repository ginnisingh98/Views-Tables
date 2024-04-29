--------------------------------------------------------
--  DDL for Package IEM_ROUTE_CLASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_ROUTE_CLASS_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvclxs.pls 120.0 2005/06/02 13:38:07 appldev noship $ */

--
--
-- Purpose: Mantain route related operations
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   5/27/2001     added functions
--  Liang Xia   6/20/2001     added creating folder on OES when association between
--			      email account and classifcation is created
--  Kris Beagle 01/11/2005   updated for 11i compliance
-- ---------   ------  ------------------------------------------


  type t_routeClassification is table of varchar2(30) index by binary_integer;

  PROCEDURE getRouteClassifications(
                p_api_version_number        IN  NUMBER,
                P_init_msg_list             IN  VARCHAR2 := null,
                p_commit                    IN  VARCHAR2 := null,

                emailAccountId              IN  NUMBER,
                routeClassifications        OUT NOCOPY t_routeClassification,
                numberOfClassifications     OUT NOCOPY NUMBER,
                x_return_status             OUT NOCOPY VARCHAR2,
                x_msg_count                 OUT NOCOPY NUMBER,
                x_msg_data                  OUT NOCOPY VARCHAR2);



 PROCEDURE delete_item_batch
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_class_ids_tbl           IN  jtf_varchar2_Table_100,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);




--  Start of Comments
--  API name    : create_item_wrap
--  Type        : Private
--  Function    : This procedure is a wrap function to create route involved
--                inserting tuple in iem_route_classifications table and iem_route_class_rules table
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_class_id              IN VARCHAR2                 Required


--      p_key_type_code	        IN VARCHAR2                 Optional Default = FND_API.G_MISS_CHAR
--      p_operator_type_code    IN VARCHAR2,                Required
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


-- ***********************************************************************
PROCEDURE create_item_wrap (
                p_api_version_number        IN   NUMBER,
                p_init_msg_list             IN   VARCHAR2 := null,
                p_commit                    IN   VARCHAR2 := null,

                p_class_name                IN   VARCHAR2,
     	        p_class_description         IN   VARCHAR2:= null,
                p_class_boolean_type_code   IN   VARCHAR2,
                p_proc_name                 IN   VARCHAR2 := null,

                p_rule_key_typecode_tbl     IN  jtf_varchar2_Table_100,
                p_rule_operator_typecode_tbl IN  jtf_varchar2_Table_100,
                p_rule_value_tbl            IN  jtf_varchar2_Table_300,
                x_return_status             OUT NOCOPY VARCHAR2,
                x_msg_count                 OUT NOCOPY NUMBER,
                x_msg_data                  OUT NOCOPY VARCHAR2 ) ;


--  Start of Comments
--  API name    : create_item_class
--  Type        : Private
--  Function    : This procedure create a route in iem_route_classes table
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
PROCEDURE create_item_class (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_name                IN   VARCHAR2,
  				 p_description	       IN   VARCHAR2:= null,
         		 p_boolean_type_code   IN   VARCHAR2,
                 p_is_sss              IN   VARCHAR2 := null,
                 p_proc_name           IN   VARCHAR2 := null,
                 p_return_type         IN   VARCHAR2 := null,
                 x_return_status	   OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY VARCHAR2
			 ) ;



--  Start of Comments
--  API name    : create_item_class_rules
--  Type        : Private
--  Function    : This procedure create a route in iem_route_rules table
--  Pre-reqs    : None.
--  Parameters  :
--      IN

--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_class_id              IN VARCHAR2                 Required
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

 PROCEDURE create_item_class_rules (
                 p_api_version_number    IN   NUMBER,
 		  	     p_init_msg_list  IN   VARCHAR2 := null,
		    	 p_commit	    IN   VARCHAR2 := null,
  				 p_class_id IN   NUMBER,
  				 p_key_type_code	IN   VARCHAR2,
  				 p_operator_type_code	IN   VARCHAR2,

                 p_value IN VARCHAR2,
                 x_return_status	OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	    OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	        OUT	NOCOPY VARCHAR2
			 );


--  Start of Comments
--  API name    : update_item_wrap
--  Type        : Private
--  Function    : This procedure update items in iem_route_classifications and iem_route_class_rules table
--  Pre-reqs    : None.
--  Parameters  :

--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--	    p_class_id              IN                          Optional NUMBER:=FND_API.G_MISS_NUM,
--  	p_name                  IN                          Optional VARCHAR2:=FND_API.G_MISS_CHAR,
--  	p_ruling_chain	        IN                          Optional VARCHAR2:=FND_API.G_MISS_CHAR,
--      p_description           IN                          Optional VARCHAR2:=FND_API.G_MISS_CHAR,
--      p_update_rule_ids_tbl   IN                          Optional jtf_varchar2_Table_100,
--      p_update_rule_keys_tbl IN                           Optional jtf_varchar2_Table_100,
--  	p_update_rule_operators_tbl IN                      Optional jtf_varchar2_Table_100,
--      p_update_rule_values_tbl IN                         Optional jtf_varchar2_Table_300,
--      p_new_rule_keys_tbl     IN                          Optional jtf_varchar2_Table_100,

--  	p_new_rule_operators_tbl IN                         Optional jtf_varchar2_Table_100,
--      p_new_rule_values_tbl   IN                          Optional jtf_varchar2_Table_300,
--      p_remove_rule_ids_tbl   IN                          Optional jtf_varchar2_Table_100,

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
PROCEDURE update_item_wrap (p_api_version_number    IN   NUMBER,
 	                         p_init_msg_list        IN   VARCHAR2 := null,
	                         p_commit	            IN   VARCHAR2 := null,
	                         p_class_id             IN   NUMBER ,
  	                         p_name                 IN   VARCHAR2:= null,
  	                         p_ruling_chain	        IN   VARCHAR2:= null,
                             p_description          IN   VARCHAR2:= null,
                             p_procedure_name       IN   VARCHAR2:= null,
                             --below is the data for update
                             p_update_rule_ids_tbl IN  jtf_varchar2_Table_100,
                             p_update_rule_keys_tbl IN  jtf_varchar2_Table_100,
  	                         p_update_rule_operators_tbl IN  jtf_varchar2_Table_100,
                             p_update_rule_values_tbl IN  jtf_varchar2_Table_300,
                             --below is the data for insert
                             p_new_rule_keys_tbl IN  jtf_varchar2_Table_100,
  	                         p_new_rule_operators_tbl IN  jtf_varchar2_Table_100,
                             p_new_rule_values_tbl IN  jtf_varchar2_Table_300,
                             --below is the data to be removed
                             p_remove_rule_ids_tbl IN  jtf_varchar2_Table_100,
                             x_return_status         OUT NOCOPY VARCHAR2,
                             x_msg_count             OUT NOCOPY NUMBER,
                             x_msg_data              OUT NOCOPY VARCHAR2 );



--  Start of Comments
--  API name    : update_item_class
--  Type        : Private
--  Function    : This procedure create a classification in iem_route_classifications table
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_class_id              IN NUMBER
--      p_description	        IN   VARCHAR2               Optional Default = FND_API.G_MISS_CHAR

--      p_ruling_chain           IN   VARCHAR2,             Optional Default = FND_API.G_MISS_CHAR
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
PROCEDURE update_item_class (
                 p_api_version_number   IN   NUMBER,
    	  	     p_init_msg_list        IN   VARCHAR2 := null,
    	    	 p_commit	            IN   VARCHAR2 := null,
    			 p_class_id             IN   NUMBER ,
                 p_proc_name	        IN   VARCHAR2:= null,
                 p_return_type          IN   VARCHAR2:= null,
    			 p_description	        IN   VARCHAR2:= null,
    			 p_ruling_chain	        IN   VARCHAR2:= null,
			     x_return_status	    OUT	NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT	NOCOPY VARCHAR2
			 ) ;

--  Start of Comments
--  API name    : update_item_rule

--  Type        : Private
--  Function    : This procedure create rule for classification in iem_route_class_rules table
--  Pre-reqs    : None.
--  Parameters  :

--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_route_class_rule_id   IN NUMBER                   Optional FND_API.G_MISS_NUM,
--      p_key_type_code	        IN   VARCHAR2               Optional Default = FND_API.G_MISS_CHAR
--      p_operator_type_code    IN   VARCHAR2,              Optional VARCHAR2 =FND_API.G_MISS_CHAR,
--      p_value                 IN VARCHAR2,                Optional VARCHAR2 =FND_API.G_MISS_CHAR,


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
PROCEDURE update_item_rule (p_api_version_number    IN   NUMBER,
     	  	     p_init_msg_list  IN   VARCHAR2 := null,
    	    	 p_commit	    IN   VARCHAR2 := null,

                 p_route_class_rule_id IN NUMBER ,
      			 p_key_type_code IN   VARCHAR2:= null,
      			 p_operator_type_code	IN   VARCHAR2:=null,
      			 p_value	IN   VARCHAR2:=null,

			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	    OUT NOCOPY NUMBER,
	  	  	      x_msg_data	    OUT	NOCOPY VARCHAR2
			 );




--  Start of Comments
--  API name    : create_wrap_acct_rt_class
--  Type        : Private
--  Function    : This procedure is wrap function to create assocation between email account and classification
--  Pre-reqs    : None.
--  Parameters  :

--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_email_account_id      IN NUMBER                   Required

--      p_enabled_flag	        IN   NUMBER                 Required
--      p_priority              IN   NUMBER,                Required

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

PROCEDURE create_wrap_acct_rt_class (
                     p_api_version_number    IN   NUMBER,
        		  	 p_init_msg_list     IN   VARCHAR2 := null,
        		     p_commit	       IN   VARCHAR2 := null,
                     p_email_account_id IN NUMBER,
      				 p_class_id IN   NUMBER,
                     p_enabled_flag IN VARCHAR2,
                     p_priority IN NUMBER,

                     x_return_status	OUT NOCOPY VARCHAR2,
      		  	     x_msg_count	    OUT NOCOPY NUMBER,
    	  	  	     x_msg_data	        OUT	NOCOPY VARCHAR2
			 ) ;



--  Start of Comments
--  API name    : create_wrap_acct_rt_class
--  Type        : Private
--  Function    : This procedure is to insert data in iem_account_route_class
--  Pre-reqs    : None.
--  Parameters  :

--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE

--      p_email_account_id      IN NUMBER                   Required
--      p_class_id	            IN   NUMBER                 Required
--      p_enabled_flag          IN   NUMBER,                Required
--      p_priority              IN NUMBER,                  Required
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
 PROCEDURE create_item_account_class (
                 p_api_version_number     IN NUMBER,
 		  	     p_init_msg_list          IN VARCHAR2 := null,
		    	 p_commit	              IN VARCHAR2 := null,
                 p_email_account_id       IN NUMBER,
  				 p_class_id               IN NUMBER,
                 p_enabled_flag           IN VARCHAR2,
                 p_priority               IN NUMBER,
                 x_return_status	      OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	          OUT NOCOPY NUMBER,
	  	  	     x_msg_data	              OUT NOCOPY VARCHAR2

			 );

--  Start of Comments
--  API name    : update_wrap_account_class
--  Type        : Private
--  Function    : This procedure is to update association between email account and classification
--  Pre-reqs    : None.
--  Parameters  :

--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE

--      p_email_account_id      IN NUMBER                   Required
--      p_class_ids_tbl	        IN jtf_varchar2_Table_100   Required
--      p_upd_enable_flag_tbl   IN jtf_varchar2_Table_100   Required
--      p_delete_class_ids_tbl  IN jtf_varchar2_Table_100   Required
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
PROCEDURE update_wrap_account_class (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := null,
		    	  p_commit	    IN   VARCHAR2 := null,

                 p_email_account_id IN NUMBER,
  				 p_class_ids_tbl IN  jtf_varchar2_Table_100,
                 p_upd_enable_flag_tbl IN  jtf_varchar2_Table_100,
                 --p_upd_priority_tbl IN  jtf_varchar2_Table_100,
                 p_delete_class_ids_tbl IN  jtf_varchar2_Table_100,
                 x_return_status	OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	    OUT NOCOPY NUMBER,
	  	  	     x_msg_data	        OUT NOCOPY VARCHAR2

			 );

--  Start of Comments
--  API name    : update_account_class
--  Type        : Private
--  Function    : This procedure is to update data in iem_account_route_class
--  Pre-reqs    : None.
--  Parameters  :


--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_email_account_id      IN NUMBER                   Required
--      p_class_id	            IN NUMBER                   Required
--      p_enabled_flag          IN VARCHAR2                 Optional Default = FND_API.G_MISS_CHAR
--      p_priority              IN VARCHAR2                 Optional Default =FND_API.G_MISS_NUM,
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
PROCEDURE update_account_class(p_api_version_number    IN   NUMBER,
 	  	          p_init_msg_list  IN   VARCHAR2 := null,
	    	      p_commit	    IN   VARCHAR2 := null,
                  p_class_id    IN  NUMBER ,
			      p_email_account_id IN NUMBER,
  			      p_enabled_flag	IN   VARCHAR2:= null,
  			      p_priority	IN   VARCHAR2:= null,
                  x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	    OUT	NOCOPY NUMBER,
	  	  	      x_msg_data	    OUT	NOCOPY VARCHAR2
			 ) ;

--  Start of Comments
--  API name    : delete_acct_class_batch
--  Type        : Private
--  Function    : This procedure is to delete data in iem_account_route_class
--  Pre-reqs    : None.
--  Parameters  :


--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_class_ids_tbl         IN jtf_varchar2_Table_100   Required
--      p_account_id	        IN NUMBER                   Required
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
PROCEDURE delete_acct_class_batch
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 := NULL,

      p_commit          IN  VARCHAR2 := NULL,
      p_class_ids_tbl IN  jtf_varchar2_Table_100,
      p_account_id IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2);


/*
--  ***** Removed for 11i compliancd *****
--  Start of Comments
--  API name    : create_folder
--  Type        : Private
--  Function    : This procedure is to create classifcation folder on OES for the email account
--  Pre-reqs    : None.
--  Parameters  :

--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE

--      p_email_account_id      IN NUMBER                   Required
--      p_classification_name   IN VARCHAR2                 Required
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
PROCEDURE create_folder (

                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_email_account_id    IN   NUMBER,
  				 p_classification_name IN   VARCHAR2,
                 x_return_status	   OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY VARCHAR2
			 ) ;

--  Start of Comments
--  API name    : delete_folder
--  Type        : Private

--  Function    : This procedure is to delete classifcation folder on OES
--  Pre-reqs    : None.
--  Parameters  :

--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_email_account_id      IN NUMBER                   Required
--      p_class_id              IN NUMBER                   Required
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
*/
/*
--  ***** Removed for 11i compliance *****
PROCEDURE delete_folder (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_email_account_id    IN   NUMBER,
  				 p_class_id            IN   NUMBER,
                 x_return_status	   OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY VARCHAR2
			 );

--  Start of Comments
--  API name    : delete_folder_on_classId
--  Type        : Private
--  Function    : This procedure is delete classifcation folder for all email account which associated
--                with the classifcation
--  Pre-reqs    : None.
--  Parameters  :


--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_classification_id     IN NUMBER                   Required
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
*/
/*
--  ***** Removed for 11i compliance *****
PROCEDURE delete_folder_on_classId
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 := null,
      p_commit          IN  VARCHAR2 := null,
      p_classification_id IN  NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2);

--  Start of Comments
--  API name    : delete_association_on_acctId

--  Type        : Private
--  Function    : This procedure is delete association of the email account with classifcations,
--                including delete classification folders and associations
--  Pre-reqs    : None.
--  Parameters  :

--      IN
--      p_api_version_number    IN NUMBER                   Required
--      p_init_msg_list         IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2                 Optional Default = FND_API.G_FALSE
--      p_email_account_id      IN NUMBER                   Required
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
*/
PROCEDURE delete_association_on_acctId
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 := null,
      p_commit          IN  VARCHAR2 := null,
      p_email_account_id IN  NUMBER,

      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2);

END IEM_ROUTE_CLASS_PVT; -- Package Specification IEM_ROUTE_CLASS_PVT


 

/
