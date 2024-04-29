--------------------------------------------------------
--  DDL for Package Body CS_INST_DETAIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INST_DETAIL_PUB" AS
-- $Header: cspinsdb.pls 120.0 2005/08/29 15:45:43 epajaril noship $

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CS_Inst_Detail_PUB';
-- ---------------------------------------------------------

-- ---------------------------------------------------------
-- Define private procedures (not in package spec)
-- ---------------------------------------------------------

PROCEDURE Initialize_Line_Inst_Rec
(
	p_line_inst_dtl_rec			IN	CS_Inst_Detail_PUB.Line_Inst_Dtl_Rec_Type,
	p_line_inst_dtl_desc_flex	IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	x_line_inst_dtl_rec			OUT NOCOPY	CS_Inst_Detail_PUB.Line_Inst_Dtl_Rec_Type,
	x_line_inst_dtl_desc_flex	OUT NOCOPY	CS_InstalledBase_PUB.DFF_Rec_Type
) IS


BEGIN
   null;
END Initialize_Line_Inst_Rec;

PROCEDURE Init_Line_Inst_Rec_For_Upd
(
	p_line_inst_dtl_rec			IN	CS_Inst_Detail_PUB.Line_Inst_Dtl_Rec_Type,
	p_line_inst_dtl_desc_flex	IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	p_old_line_inst_dtl_rec		IN	CS_Inst_Detail_PUB.Line_Inst_Dtl_Rec_Type,
	p_old_line_inst_dtl_desc_flex	IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	x_line_inst_dtl_rec			OUT NOCOPY	CS_Inst_Detail_PUB.Line_Inst_Dtl_Rec_Type,
	x_line_inst_dtl_desc_flex	OUT NOCOPY	CS_InstalledBase_PUB.DFF_Rec_Type
) IS

BEGIN
   null;
END Init_Line_Inst_Rec_For_Upd;

PROCEDURE Get_Line_Inst_Details
(
	p_api_version				IN	NUMBER,
	p_init_msg_list     		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit            		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status     		OUT NOCOPY	VARCHAR2,
	x_msg_count         		OUT NOCOPY	NUMBER,
	x_msg_data          		OUT NOCOPY	VARCHAR2,
	p_line_inst_detail_id		IN	NUMBER,
	x_line_inst_dtl_rec			OUT NOCOPY	Line_Inst_Dtl_Rec_Type,
	x_line_inst_dtl_desc_flex	OUT NOCOPY	CS_InstalledBase_PUB.DFF_Rec_Type
) IS


BEGIN
   null;
END Get_Line_Inst_Details;

/* Start of OverLoaded Procedure */

PROCEDURE Get_Line_Inst_Details
(
	p_api_version				IN	NUMBER,
	p_init_msg_list     		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit            		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status     		OUT NOCOPY	VARCHAR2,
	x_msg_count         		OUT NOCOPY	NUMBER,
	x_msg_data          		OUT NOCOPY	VARCHAR2,
	p_order_line_id			IN	NUMBER,
	x_line_inst_dtl_tbl			OUT NOCOPY	Line_Inst_Dtl_Tbl_Type,
	x_line_inst_dtl_tbl_count	OUT NOCOPY	NUMBER
) IS

BEGIN
   null;
END Get_Line_Inst_Details;


PROCEDURE Get_Rma_Line_Inst_Details
(
	p_api_version				IN	NUMBER,
	p_init_msg_list     		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit            		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status     		OUT NOCOPY	VARCHAR2,
	x_msg_count         		OUT NOCOPY	NUMBER,
	x_msg_data          		OUT NOCOPY	VARCHAR2,
	p_rma_only            		IN	VARCHAR2  DEFAULT FND_API.G_TRUE,
	p_order_line_id			IN	NUMBER,
	x_line_inst_dtl_tbl			OUT NOCOPY	CS_INST_DETAIL_PUB.Line_Inst_Dtl_Tbl_Type,
	x_line_inst_dtl_tbl_count	OUT NOCOPY	NUMBER
) IS

BEGIN
   null;
END Get_Rma_Line_Inst_Details;


PROCEDURE Validate_Installation_Details
(
	p_api_version				IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_commit					IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count				OUT NOCOPY	NUMBER,
	x_msg_data				OUT NOCOPY	VARCHAR2,
	p_line_inst_dtl_rec			IN	Line_Inst_Dtl_Rec_Type,
	p_line_inst_dtl_desc_flex	IN	CS_InstalledBase_PUB.DFF_Rec_Type,
    p_upgrade                   IN VARCHAR2  DEFAULT FND_API.G_FALSE
)  IS
BEGIN
   null;
END Validate_Installation_Details;

PROCEDURE Create_Installation_Details
(
	p_api_version           		IN	NUMBER,
	p_init_msg_list         		IN	VARCHAR2   DEFAULT FND_API.G_FALSE,
	p_commit                		IN	VARCHAR2   DEFAULT FND_API.G_FALSE,
	x_return_status         		OUT NOCOPY	VARCHAR2,
	x_msg_count             		OUT NOCOPY	NUMBER,
	x_msg_data              		OUT NOCOPY	VARCHAR2,
	p_line_inst_dtl_rec     		IN	Line_Inst_Dtl_Rec_Type,
	p_line_inst_dtl_desc_flex	IN	CS_InstalledBase_PUB.DFF_Rec_Type,
    p_upgrade                       IN VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_line_inst_detail_id   		OUT NOCOPY	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER -- was commented
) IS

	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Create_Installation_Details';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
BEGIN
   null;
END Create_Installation_Details;

PROCEDURE Update_Installation_Details
(
	p_api_version           		IN	NUMBER,
	p_init_msg_list         		IN	VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                		IN	VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status        		OUT NOCOPY	VARCHAR2,
	x_msg_count             		OUT NOCOPY	NUMBER,
	x_msg_data              		OUT NOCOPY	VARCHAR2,
	p_line_inst_dtl_rec     		IN	Line_Inst_Dtl_Rec_Type,
	p_line_inst_dtl_desc_flex	IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	p_object_version_number		IN	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER -- was commented
) IS


BEGIN
   null;
END Update_Installation_Details;

PROCEDURE Delete_Installation_Details
(
	p_api_version           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status         OUT NOCOPY     VARCHAR2,
	x_msg_count             OUT NOCOPY     NUMBER,
	x_msg_data              OUT NOCOPY     VARCHAR2,
	p_line_inst_detail_id   IN      NUMBER--,
--	p_object_version_number IN	  NUMBER
) IS
BEGIN
   null;
END Delete_Installation_Details;


/* Added this Procedure for RMA returns Bug 1500577 shegde */

PROCEDURE Update_Inst_Details_RMA_Rcpt
(
	p_api_version           		IN	NUMBER,
	p_init_msg_list         		IN	VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                		IN	VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status        		    OUT NOCOPY	VARCHAR2,
	x_msg_count             		OUT NOCOPY	NUMBER,
	x_msg_data              		OUT NOCOPY	VARCHAR2,
	p_rcpt_tbl                		IN	RMA_RCPT_TBL_TYPE,
	p_rcpt_tbl_count             	IN	NUMBER,
	p_order_line_id           		IN	NUMBER,
	p_cp_id                   		IN	NUMBER,
	p_serial_flag              		IN	VARCHAR2,
	p_object_version_number		    IN	NUMBER,
	x_object_version_number		    OUT NOCOPY	NUMBER
) IS

BEGIN
   null;
END Update_Inst_Details_RMA_Rcpt;


END CS_Inst_Detail_PUB;

/
