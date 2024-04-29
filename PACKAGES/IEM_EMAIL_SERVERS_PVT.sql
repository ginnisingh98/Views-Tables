--------------------------------------------------------
--  DDL for Package IEM_EMAIL_SERVERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_EMAIL_SERVERS_PVT" AUTHID CURRENT_USER as
/* $Header: iemvevrs.pls 115.7 2002/12/03 20:02:36 chtang shipped $ */

PROCEDURE create_item_sss (p_api_version_number    IN   NUMBER,
 		     p_init_msg_list  IN   VARCHAR2,
		       p_commit	    IN   VARCHAR2,
			 p_server_name IN   VARCHAR2,
			 p_dns_name IN   VARCHAR2,
			 p_ip_address IN   VARCHAR2,
			 p_port IN   NUMBER,
			 p_server_type_id IN   NUMBER,
			 p_rt_availability IN   VARCHAR2,
			 p_server_group_id IN   NUMBER,
			p_CREATED_BY    NUMBER,
          	p_CREATION_DATE    DATE,
         	p_LAST_UPDATED_BY    NUMBER,
          	p_LAST_UPDATE_DATE    DATE,
          	p_LAST_UPDATE_LOGIN    NUMBER,
         	p_ATTRIBUTE1    VARCHAR2,
          	p_ATTRIBUTE2    VARCHAR2,
          	p_ATTRIBUTE3    VARCHAR2,
          	p_ATTRIBUTE4    VARCHAR2,
          	p_ATTRIBUTE5    VARCHAR2,
          	p_ATTRIBUTE6    VARCHAR2,
          	p_ATTRIBUTE7    VARCHAR2,
          	p_ATTRIBUTE8    VARCHAR2,
          	p_ATTRIBUTE9    VARCHAR2,
          	p_ATTRIBUTE10    VARCHAR2,
          	p_ATTRIBUTE11    VARCHAR2,
          	p_ATTRIBUTE12    VARCHAR2,
          	p_ATTRIBUTE13    VARCHAR2,
          	p_ATTRIBUTE14    VARCHAR2,
          	p_ATTRIBUTE15    VARCHAR2,
		      x_return_status OUT NOCOPY VARCHAR2,
  		      x_msg_count	      OUT NOCOPY    NUMBER,
	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );


PROCEDURE create_item_wrap_sss (p_api_version_number    IN   NUMBER,
 		            p_init_msg_list  IN   VARCHAR2,
		            p_commit	    IN   VARCHAR2,
			    p_server_name IN   VARCHAR2,
			 p_dns_name IN   VARCHAR2,
			 p_ip_address IN   VARCHAR2,
			 p_port IN   NUMBER,
			 p_server_type_id IN   NUMBER,
			 p_rt_availability IN   VARCHAR2,
			 p_server_group_id IN   NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2,
  		      x_msg_count	      OUT NOCOPY    NUMBER,
	  	      x_msg_data OUT NOCOPY VARCHAR2
	  	      	   );

-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_EMAIL_SERVERS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_server_id	IN NUMBER:=FND_API.G_MISS_NUM,
--  p_dns_name IN   VARCHAR2 :=FND_API.G_MISS_CHAR,
--  p_ip_address IN   VARCHAR2:=FND_API.G_MISS_CHAR,
--  p_port IN   NUMBER:=FND_API.G_MISS_NUM,
--
--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
 		       p_init_msg_list  IN   VARCHAR2,
		    	p_commit	    IN   VARCHAR2,
			p_email_server_id	IN NUMBER,
			p_dns_name IN   VARCHAR2,
			p_ip_address IN   VARCHAR2,
			p_port IN   NUMBER,
			x_return_status OUT NOCOPY VARCHAR2,
  		  	x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	x_msg_data OUT NOCOPY VARCHAR2
			 );
-- Start of Comments
--  API name 	: update_item
--  Type	: 	Private
--  Function	: This procedure update a record in the table IEM_EMAIL_SERVERS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_server_id IN	NUMBER:=NULL,
--  p_server_name	 IN	varchar2:=NULL,
--  p_dns_name IN   VARCHAR2:=NULL,
--  p_ip_address IN   VARCHAR2:=NULL,
--  p_port IN   NUMBER:=NULL,
--  p_server_type_id IN 	number:=NULL,
--  p_rt_availability	in varchar2:=NULL,
--  p_server_group_id	in number:=NULL,
--
--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE update_item_sss (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2,
		    	      p_commit	    IN   VARCHAR2,
				 p_email_server_id IN	NUMBER,
				 p_server_name	 IN	varchar2,
				 p_dns_name IN   VARCHAR2,
				 p_ip_address IN   VARCHAR2,
				 p_port IN   NUMBER,
				 p_server_type_id IN 	number,
				 p_rt_availability	in varchar2,
				 p_server_group_id	in number,
         	p_LAST_UPDATED_BY    NUMBER,
          	p_LAST_UPDATE_DATE    DATE,
          	p_LAST_UPDATE_LOGIN    NUMBER,
         	p_ATTRIBUTE1    VARCHAR2,
          	p_ATTRIBUTE2    VARCHAR2,
          	p_ATTRIBUTE3    VARCHAR2,
          	p_ATTRIBUTE4    VARCHAR2,
          	p_ATTRIBUTE5    VARCHAR2,
          	p_ATTRIBUTE6    VARCHAR2,
          	p_ATTRIBUTE7    VARCHAR2,
          	p_ATTRIBUTE8    VARCHAR2,
          	p_ATTRIBUTE9    VARCHAR2,
          	p_ATTRIBUTE10    VARCHAR2,
          	p_ATTRIBUTE11    VARCHAR2,
          	p_ATTRIBUTE12    VARCHAR2,
          	p_ATTRIBUTE13    VARCHAR2,
          	p_ATTRIBUTE14    VARCHAR2,
          	p_ATTRIBUTE15    VARCHAR2,
			x_return_status OUT NOCOPY VARCHAR2,
  		  	x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	x_msg_data OUT NOCOPY VARCHAR2
			);

PROCEDURE update_item_wrap_sss (p_api_version_number    IN   NUMBER,
 		       p_init_msg_list  IN   VARCHAR2,
		       p_commit	    IN   VARCHAR2,
		       p_email_server_id IN	NUMBER,
			p_server_name	 IN	varchar2,
			p_dns_name IN   VARCHAR2,
			p_ip_address IN   VARCHAR2,
			p_port IN   NUMBER,
			p_server_type_id IN 	number,
			p_rt_availability	in varchar2,
			p_server_group_id	in number,
			x_return_status OUT NOCOPY VARCHAR2,
  		  	x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	x_msg_data OUT NOCOPY VARCHAR2
			);

PROCEDURE delete_item_batch
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2,
      p_commit          IN  VARCHAR2,
      p_group_tbl IN  jtf_varchar2_Table_100,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2);

END IEM_EMAIL_SERVERS_PVT;

 

/
