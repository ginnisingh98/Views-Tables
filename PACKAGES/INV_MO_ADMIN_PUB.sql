--------------------------------------------------------
--  DDL for Package INV_MO_ADMIN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MO_ADMIN_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPMOAS.pls 120.1 2005/06/17 14:17:50 appldev  $ */

--  Global for reference type


--  Start of Comments
--  API name    Cancel_Order
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters   Header ID, x_return_status
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

Procedure Cancel_Order( p_api_version  	      In  Number,
			p_init_msg_list	      In  varchar2 := FND_API.G_FALSE,
			p_commit	      In  varchar2 := FND_API.G_FALSE,
			p_validation_level    In  varchar2 :=
						   FND_API.G_VALID_LEVEL_FULL,
			p_header_Id	    In	  Number,
			x_msg_count	    Out Nocopy   Number,
			x_msg_data	    Out Nocopy   varchar2,
			x_return_status     Out Nocopy	  Varchar2  );




--  Start of Comments
--  API name    Close_Order
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters   Header ID
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

Procedure Close_Order(
			p_api_version	      In  Number,
			p_init_msg_list	      In  varchar2 := FND_API.G_FALSE,
			p_commit	      In  varchar2 := FND_API.G_FALSE,
			p_validation_level    In  varchar2 :=
						   FND_API.G_VALID_LEVEL_FULL,
			p_header_Id	      In    Number,
			x_msg_count	      Out Nocopy   Number,
			x_msg_data	      Out Nocopy   varchar2,
		        x_return_status       Out Nocopy   varchar2  );



--  Start of Comments
--  API name    Purge_Order
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters   Header ID
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

Procedure Purge_Order(  p_api_version	      In  Number,
			p_init_msg_list	      In  varchar2 := FND_API.G_FALSE,
			p_commit	      In  varchar2 := FND_API.G_FALSE,
			p_validation_level    In  varchar2 :=
						   FND_API.G_VALID_LEVEL_FULL,
			p_header_Id	      In    Number,
			x_msg_count	      Out Nocopy   Number,
			x_msg_data	      Out Nocopy   varchar2,
		        x_return_status       Out Nocopy   varchar2  );



--  Start of Comments
--  API name    Cancel_Line
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters   Line ID
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

Procedure Cancel_Line(  p_api_version	      In  Number,
			p_init_msg_list	      In  varchar2 := FND_API.G_FALSE,
			p_commit	      In  varchar2 := FND_API.G_FALSE,
			p_validation_level    In  varchar2 :=
						   FND_API.G_VALID_LEVEL_FULL,
			p_line_id	      In    Number,
			x_msg_count	      Out Nocopy   Number,
			x_msg_data	      Out Nocopy   varchar2,
		        x_return_status       Out Nocopy   varchar2  );


--  Start of Comments
--  API name    Close_Line
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters   Header ID
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

Procedure Close_Line(   p_api_version	      In  Number,
			p_init_msg_list	      In  varchar2 := FND_API.G_FALSE,
			p_commit	      In  varchar2 := FND_API.G_FALSE,
			p_validation_level    In  varchar2 :=
						   FND_API.G_VALID_LEVEL_FULL,
			p_line_id	      In    Number,
			x_msg_count	      Out Nocopy   Number,
			x_msg_data	      Out Nocopy   varchar2,
		        x_return_status       Out Nocopy   varchar2  );


END INV_MO_Admin_Pub;

 

/
