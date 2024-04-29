--------------------------------------------------------
--  DDL for Package IEM_ENCRYPT_TAGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_ENCRYPT_TAGS_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvencs.pls 120.0 2005/06/02 13:37:51 appldev noship $ */
--
--
-- Purpose: Mantain Encrypted Tags
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   02/25/2002    Created
--  Liang Xia   10/24/2002    Added reset_tag API
--  Liang Xia   12/05/2002    Fixed GSCC warning: NOCOPY, no G_MISS...
--  Liang Xia   07/22/2004    Added duplicate_tags for reuse tag
-- ---------   ------  ------------------------------------------
TYPE email_tag_type IS RECORD (
          email_tag_key   varchar2(256),
          email_tag_value varchar2(256));

TYPE email_tag_tbl IS TABLE OF email_tag_type
           INDEX BY BINARY_INTEGER;

--  Start of Comments
--  API name    : create_item
--  Type        : Private
--  Function    : This procedure creates record in the table IEM_ENCRYPTED_TAGS table
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE create_item (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_agent_id            IN   number,
                 p_interaction_id      IN   number,
                 p_email_tag_tbl       IN   email_tag_tbl,
                 x_encripted_id        OUT  NOCOPY number,
                 x_token               OUT  NOCOPY VARCHAR2,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) ;

--  Start of Comments
--  API name    : delete_item_by_msg_id
--  Type        : Private
--  Function    : This procedure delete record in the table IEM_ENCRYPTED_TAGS table by msg_id
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE delete_item_by_msg_id
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_message_id              IN  NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

--  Start of Comments
--  API name    : update_item_on_mess_id
--  Type        : Private
--  Function    : This procedure update record in the table IEM_ENCRYPTED_TAGS table by enrypted_id
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE update_item_on_mess_id (
                 p_api_version_number   IN   NUMBER,
    	  	     p_init_msg_list        IN   VARCHAR2 := null,
    	    	 p_commit	            IN   VARCHAR2 := null,
                 p_encrypted_id         IN   NUMBER,
    			 p_message_id           IN   NUMBER,
			     x_return_status	    OUT	NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT	NOCOPY VARCHAR2
			 );


--  Start of Comments
--  API name    : create_encrypted_tag_dtls
--  Type        : Private
--  Function    : This procedure creates record in the table IEM_ENCRYPTED_TAG_DTLS table
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE create_encrypted_tag_dtls (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_key                 IN   VARCHAR2,
                 p_val                 IN   VARCHAR2,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 );

--  Start of Comments
--  API name    : reset_tag
--  Type        : Private
--  Function    : This procedure set message id to NULL in  IEM_ENCRYPTED_TAGS table
--                for p_message_id. Reset_tag makes the tag re-usable, in case of
--                the need of re-process the email.
--  Pre-reqs    : None.
--  Parameters  : p_message_id The message_id that need to reset.
--  Version     : This is shipped in MP-Q ( 115.9 )
 PROCEDURE reset_tag
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_message_id              IN  NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

 --  Start of Comments
--  API name    : duplicate_tags
--  Type        : Private
--  Function    : This procedure duplicate record for encypted and stamp with msg_id
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE duplicate_tags
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_encrypted_id            IN  NUMBER,
              p_message_id              IN  NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

END IEM_ENCRYPT_TAGS_PVT;

 

/
