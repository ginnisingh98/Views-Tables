--------------------------------------------------------
--  DDL for Package IEM_GETCUST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_GETCUST_PVT" AUTHID CURRENT_USER as
/* $Header: iemgcsts.pls 115.7 2002/12/06 03:14:06 sboorela shipped $*/
-- Start of Comments
-- API name      : 'GetCustomerInfo`
-- Purpose       : Returns Customer FirstName LastName
-- Pre-reqs  : None
-- Parameters  :
--   IN
--		p_email			IN VARCHAR2 Required
--        p_api_version_number IN NUMBER Required
--        p_init_msg_list          IN   VARCHAR2 Optional  Default =FND_API_G_FALSE
--        p_commit                 IN   VARCHAR2 Optional  Default =FND_API.G_FALSE
--  p_email   IN VARCHAR2 Required
--
--   OUT:
--		p_party_id			OUT	NUMBER
--		p_customer_name		OUT	VARCHAR2
--		p_first_name		OUT	VARCHAR2
--		p_last_name		OUT	VARCHAR2
--       	x_return_status          OUT  VARCHAR2
--       	x_msg_count              OUT  NUMBER
--       	x_msg_data               OUT  VARCHAR2
--
--   Version : Current version 1.0
--   Note:
--
--   End of Comments

TYPE cust_rec_type IS RECORD (
          owner_table_id   number,
          party_type varchar2(30),
		email_address varchar2(500));

TYPE cust_rec_tbl IS TABLE OF cust_rec_type
           INDEX BY BINARY_INTEGER;

PROCEDURE GetCustomerInfo(
 P_Api_Version_Number     IN   NUMBER,
 P_Init_Msg_List          IN   VARCHAR2     ,
 P_Commit                 IN   VARCHAR2     ,
 p_email		   		 IN  VARCHAR2,
 p_party_id               OUT NOCOPY  NUMBER,
 p_customer_name          OUT NOCOPY  VARCHAR2,
 p_first_name 	          OUT NOCOPY  VARCHAR2,
 p_last_name	          OUT NOCOPY  VARCHAR2,
 x_msg_count   		 OUT NOCOPY  NUMBER,
 x_return_status  		 OUT NOCOPY  VARCHAR2,
 x_msg_data   			 OUT NOCOPY VARCHAR2);

PROCEDURE GetCustomerId(
 P_Api_Version_Number     IN   NUMBER,
 p_email		   		 IN  VARCHAR2,
 p_party_id               OUT NOCOPY  NUMBER,
 x_msg_count   		 OUT NOCOPY  NUMBER,
 x_return_status  		 OUT NOCOPY  VARCHAR2,
 x_msg_data   			 OUT NOCOPY VARCHAR2);

PROCEDURE CustomerSearch(
 P_Api_Version_Number     IN   NUMBER,
 p_email		   		 IN  VARCHAR2,
 x_party_id               OUT NOCOPY  NUMBER,
 x_msg_count   		 OUT NOCOPY  NUMBER,
 x_return_status  		 OUT NOCOPY  VARCHAR2,
 x_msg_data   			 OUT NOCOPY VARCHAR2);
End IEM_GETCUST_PVT;

 

/
