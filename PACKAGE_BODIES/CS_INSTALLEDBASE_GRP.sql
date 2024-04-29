--------------------------------------------------------
--  DDL for Package Body CS_INSTALLEDBASE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INSTALLEDBASE_GRP" AS
/* $Header: csgibb.pls 120.1 2005/08/29 16:21:21 epajaril noship $ */

-- -------------------------------------------------------------
-- Define global variables
-- ------------------------------------------------------------
G_PKG_NAME	CONSTANT	VARCHAR2(30)	:= 'CS_InstalledBase_GRP';
PROCEDURE Update_Inst_Details_Order_Line
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_quote_line_shipment_id		IN	NUMBER,
	p_order_line_id		IN	NUMBER
)  IS
BEGIN
  null;
END Update_Inst_Details_Order_Line;


PROCEDURE Split_Installation_Details
(
	p_api_version           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status         OUT NOCOPY     VARCHAR2,
	x_msg_count             OUT NOCOPY    NUMBER,
	x_msg_data              OUT NOCOPY     VARCHAR2,
	p_split_line_tbl        IN      Split_Line_Tbl_Type,
	p_split_line_tbl_count  IN      NUMBER
) IS
BEGIN
   null;
END Split_Installation_Details;

END CS_InstalledBase_GRP;

/
