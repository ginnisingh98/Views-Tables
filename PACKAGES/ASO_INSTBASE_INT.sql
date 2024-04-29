--------------------------------------------------------
--  DDL for Package ASO_INSTBASE_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_INSTBASE_INT" AUTHID CURRENT_USER as
/* $Header: asoicsis.pls 120.1 2005/06/29 12:32:57 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_InstBase_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



--
--
-- Record types
--
--
-- API
--
-- Delete_Installation_Details
-- Update_Inst_Details_Order
--




-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;


--------------------------------------------------------------------------

-- Start of comments
--  API name   : Delete_Installation_Details
--  Type       : Public
--  Function   : This API is used to delete Installation details records.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version_number       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */ Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
--   x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2(2000)
--
--  Delete_Installation_Details IN Parameters:
--  p_line_inst_dtl_id        NUMBER                   Required

--  Delete_Installation_Details OUT NOCOPY /* file.sql.39 change */ Parameters:
--  None
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Delete_Installation_Detail
(
	p_api_version_number           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */      NUMBER,
	x_msg_data              OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
	p_line_inst_dtl_id      IN      NUMBER
);

PROCEDURE Update_Inst_Details_ORDER
 (
        p_api_version_number			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_commit	  IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	x_msg_count		 OUT NOCOPY /* file.sql.39 change */  NUMBER,
	x_msg_data		 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	p_quote_line_shipment_id		IN	NUMBER,
	p_order_line_id		IN	NUMBER
);

FUNCTION Get_top_model_line_id(
p_qte_line_id    number
) RETURN  NUMBER;

END ASO_instbase_INT;

 

/
