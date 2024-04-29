--------------------------------------------------------
--  DDL for Package CS_INSTALLEDBASE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INSTALLEDBASE_GRP" AUTHID CURRENT_USER AS
/* $Header: csgibs.pls 120.1 2005/08/29 16:21:12 epajaril noship $ */

-- Private datatypes used only by this package

TYPE Split_Line_Rec_Type IS RECORD
(
	split_line_id	NUMBER	DEFAULT FND_API.G_MISS_NUM,
	quantity		NUMBER	DEFAULT FND_API.G_MISS_NUM
);

TYPE Split_Line_Tbl_Type is TABLE OF Split_Line_Rec_Type
INDEX BY BINARY_INTEGER;

-- End private datatypes


PROCEDURE Update_Inst_Details_Order_Line
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_quote_line_shipment_id	IN	NUMBER,
	p_order_line_id		IN	NUMBER
);

--------------------------------------------------------------------------

-- Start of comments
--  API name   : Split_Installation_Details
--  Type       : Public
--  Function   : This API is used to split Installation details records when the--               order line it belongs to is split.This API will be called by
--               the Process Order API only if the first Split Order Line has
--               the ordered quantity lower than the total quantity of the
--               Installation Details. If the first Split Order Line has the
--               ordered quantity greater or equal to the total quantity of the
--               Installation Details, OM will automatically attach all the
--               installation details records to the first split order line and
--               the rest of teh split lines will not have any installation
--               details.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--   x_return_status     OUT  VARCHAR2(1)
--   x_msg_count         OUT  NUMBER
--   x_msg_data          OUT  VARCHAR2(2000)
--
--  Split_Installation_Details IN Parameters:
--  p_split_line_tbl	Split_Line_Tbl_Type  Required.
--  p_split_line_tbl_count NUMBER

--  Split_Installation_Details OUT Parameters:
--  None
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Split_Installation_Details
(
	p_api_version           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status         OUT NOCOPY    VARCHAR2,
	x_msg_count             OUT NOCOPY     NUMBER,
	x_msg_data              OUT NOCOPY    VARCHAR2,
	p_split_line_tbl        IN      Split_Line_Tbl_Type,
	p_split_line_tbl_count  IN      NUMBER
);

END CS_InstalledBase_GRP;

 

/
