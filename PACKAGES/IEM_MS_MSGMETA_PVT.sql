--------------------------------------------------------
--  DDL for Package IEM_MS_MSGMETA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_MS_MSGMETA_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvhdrs.pls 120.3 2005/08/24 16:01:52 appldev noship $ */
--
--
-- Purpose: Mantain message store header tables
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   10/05/2004   Created
--  Liang Xia   10/16/2004   Redefined interface of create_headers
--  Liang Xia   11/16/2004   Changed to compliance with final odf patch
--  Liang Xia   08/18/2005   Changed create_msg_meta to accept message_id for DPM
-- ---------   ------  ------------------------------------------

TYPE key_tbl_type IS table of VARCHAR(100) INDEX BY BINARY_INTEGER;

PROCEDURE create_msg_meta (
		p_api_version_number  IN   NUMBER,
		p_init_msg_list       IN   VARCHAR2 := null,
		p_commit              IN   VARCHAR2 := null,
  		P_subject             IN   VARCHAR2,
   		p_sent_date   	       IN   VARCHAR2, --DATE,
                 p_priority            IN   VARCHAR2,
                 p_msg_id              IN   VARCHAR2,
                 p_UID                 IN   NUMBER,
                 p_x_mailer            IN   varchar2,
                 p_language            IN   varchar2,
                 p_content_type        IN   varchar2,
                 p_organization        IN   varchar2,
		 p_message_size		IN  NUMBER,
                 p_email_account       IN   NUMBER,
		 p_from		       IN   varchar2,
		 p_to		       IN   varchar2,
		 p_cc		       IN   varchar2,
		 p_reply_to	       IN   varchar2,
		 p_message_id	   IN   number,
                 x_ref_key             OUT NOCOPY varchar2,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		 x_msg_count	       OUT	NOCOPY NUMBER,
	  	 x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) ;


PROCEDURE create_headers(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
                 p_msg_meta_id         IN  jtf_varchar2_Table_100,
                 p_name_tbl            IN  jtf_varchar2_Table_300,
  	             p_value_tbl           IN  jtf_varchar2_Table_2000,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) ;
 --  Start of Comments

PROCEDURE create_string_msg_body(
		 p_api_version_number  IN   NUMBER,
		 p_init_msg_list       IN   VARCHAR2,
		 p_commit              IN   VARCHAR2,
                 p_message_id          IN   NUMBER,
                 p_part_type           IN   varchar2,
                 p_msg_body            IN  jtf_varchar2_Table_2000,
                 x_return_status       OUT  NOCOPY VARCHAR2,
  	  	 x_msg_count	       OUT	NOCOPY NUMBER,
	  	 x_msg_data	       OUT	NOCOPY VARCHAR2

			 );
PROCEDURE insert_preproc_wrapper (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_msg_id              IN   NUMBER,
  				 p_acct_id   	       IN   NUMBER,
                 p_priority            IN   NUMBER,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 );
END IEM_MS_MSGMETA_PVT ;

 

/
