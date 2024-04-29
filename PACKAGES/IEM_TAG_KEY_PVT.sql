--------------------------------------------------------
--  DDL for Package IEM_TAG_KEY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_TAG_KEY_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvtags.pls 120.0 2005/06/02 14:00:41 appldev noship $ */
--
--
-- Purpose: Mantain email tag related operations
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   3/20/2002    Created
--  Liang Xia   5/14/2002    added more validation on Key ID
--  Liang Xia   12/05/2002   Fixed plsql GSCC warning: NOCOPY, No G_MISS..
--  Liang Xia   12/04/2004   changed to iem_mstemail_accounts for 115.11 schema compliance
-- ---------   ------  ------------------------------------------
TYPE key_tbl_type IS table of VARCHAR(100) INDEX BY BINARY_INTEGER;

--  Start of Comments
--  API name    : create_item_tag
--  Type        : Private
--  Function    : This procedure creates record in the table IEM_TAG_KEYS table
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE create_item_tag (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_key_id              IN   VARCHAR2,
  				 p_key_name   	       IN   VARCHAR2,
         		 p_type_type_code      IN   VARCHAR2,
                 p_value               IN   VARCHAR2,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) ;

 --  Start of Comments
--  API name    : create_item_account_tags
--  Type        : Private
--  Function    : This procedure creates record in the table IEM_ACCT_TAG_KEYS table
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE create_item_account_tags (
                 p_api_version_number     IN NUMBER,
 		  	     p_init_msg_list          IN VARCHAR2 := null,
		    	 p_commit	              IN VARCHAR2 := null,
                 p_email_account_id       IN NUMBER,
  				 p_tag_key_id             IN NUMBER,
                 x_return_status	      OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	          OUT NOCOPY NUMBER,
	  	  	     x_msg_data	              OUT NOCOPY VARCHAR2
			 );

 --  Start of Comments
--  API name    : delete_item_batch
--  Type        : Private
--  Function    : This procedure delete batch of records in the table IEM_TAG_KEYS table
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE delete_item_batch
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_tagKey_ids_tbl          IN  jtf_varchar2_Table_100,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

--  Start of Comments
--  API name    : update_item_tag_key
--  Type        : Private
--  Function    : This procedure update records in the table IEM_TAG_KEYS table
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE update_item_tag_key (
                 p_api_version_number       IN   NUMBER,
    	  	     p_init_msg_list            IN   VARCHAR2 := null,
    	    	 p_commit	                IN   VARCHAR2 := null,
    			 p_tag_key_id               IN   NUMBER,
                 p_key_id                   IN   VARCHAR2:= null,
    			 p_key_name                 IN   VARCHAR2:= null,
                 p_type_type_code           IN   VARCHAR2:= null,
    			 p_value	                IN   VARCHAR2:= null,
			     x_return_status	        OUT	 NOCOPY VARCHAR2,
  		  	     x_msg_count	            OUT	 NOCOPY NUMBER,
	  	  	     x_msg_data	                OUT	 NOCOPY VARCHAR2
			 );

 --  Start of Comments
--  API name    : update_acct_tag_wrap
--  Type        : Private
--  Function    : This procedure update records in the table IEM_ACCT_TAG_KEYS table
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE update_acct_tag_wrap (p_api_version_number     IN   NUMBER,
 	                         p_init_msg_list         IN   VARCHAR2 := null,
	                         p_commit	             IN   VARCHAR2 := null,
  	                         p_account_id	         IN   NUMBER,
                             p_in_key_id             IN   VARCHAR2:= null,
                             p_out_key_id            IN   VARCHAR2 := null,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2 );

 --  Start of Comments
--  API name    : delete_acct_tag_on_acct_ID
--  Type        : Private
--  Function    : This procedure delete records in the table IEM_ACCT_TAG_KEYS table based on email_account_id
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE delete_acct_tag_on_acct_ID
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_email_acct_id           IN  iem_mstemail_accounts.email_account_id%type,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

 FUNCTION varChar_to_table ( inString    IN   VARCHAR2 )
        return key_tbl_type;

END IEM_TAG_KEY_PVT;

 

/
