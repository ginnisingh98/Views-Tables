--------------------------------------------------------
--  DDL for Package GMD_ITEM_TECHNICAL_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_ITEM_TECHNICAL_DATA_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPITDS.pls 120.3.12010000.1 2008/07/24 09:56:36 appldev ship $ */

-- Header record type
TYPE technical_data_hdr_rec IS RECORD
(Tech_Data_Id           gmd_technical_data_hdr.Tech_Data_Id%TYPE,
 Organization_Id        gmd_technical_data_hdr.Organization_Id%TYPE,
 Inventory_Item_Id      gmd_technical_data_hdr.Inventory_Item_Id%TYPE,
 Lot_Number             gmd_technical_data_hdr.lot_number%TYPE,
 Lot_Organization_Id    gmd_technical_data_hdr.Lot_Organization_Id%TYPE,
 Formula_Id             gmd_technical_data_hdr.Formula_Id%TYPE,
 Batch_Id               gmd_technical_data_hdr.Batch_Id%TYPE,
 Text_Code              gmd_technical_data_hdr.Text_Code%TYPE );

-- Detail record type
TYPE technical_data_dtl_rec IS RECORD
(Tech_Parm_Id           gmd_technical_data_dtl.Tech_Parm_Id%TYPE,
 Sort_Seq               gmd_technical_data_dtl.Sort_Seq%TYPE,
 Tech_Data              VARCHAR2(2000),
 Text_Code              gmd_technical_data_dtl.Text_Code%TYPE);

-- Detail record table
TYPE technical_data_dtl_tab IS TABLE OF technical_data_dtl_rec
INDEX BY BINARY_INTEGER;

--Start of comments
--+========================================================================+
--| API Name    : INSERT_ITEM_TECHNICAL_DATA                               |
--| TYPE        : Public                                                   |
--| Function    : Inserts the Item technical data                          |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE INSERT_ITEM_TECHNICAL_DATA
(
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_header_rec		IN OUT  NOCOPY  technical_data_hdr_rec
, p_dtl_tbl		IN              technical_data_dtl_tab
);

--Start of comments
--+========================================================================+
--| API Name    : UPDATE_ITEM_TECHNICAL_DATA                               |
--| TYPE        : Public                                                   |
--| Function    : Updates the Item technical data                          |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE UPDATE_ITEM_TECHNICAL_DATA
(
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_tech_data_id	IN              NUMBER
, p_dtl_tbl		IN              technical_data_dtl_tab
);

--Start of comments
--+========================================================================+
--| API Name    : DELETE_ITEM_TECHNICAL_DATA                               |
--| TYPE        : Public                                                   |
--| Function    : Deletes the Item technical data                          |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE DELETE_ITEM_TECHNICAL_DATA
(
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
 , x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
 , p_tech_data_id	IN              NUMBER
);

--Start of comments
--+========================================================================+
--| API Name    : FETCH_ITEM_TECHNICAL_DATA                                |
--| TYPE        : Public                                                   |
--| Function    : Fetches the Item technical data based on the input parm's|
--|               passed.                                                  |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE FETCH_ITEM_TECHNICAL_DATA (
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_header_rec		IN              technical_data_hdr_rec
, x_dtl_tbl		OUT 	NOCOPY 	technical_data_dtl_tab
, x_return_status	OUT 	NOCOPY 	VARCHAR2
);

END GMD_ITEM_TECHNICAL_DATA_PUB ;


/
