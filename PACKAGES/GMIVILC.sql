--------------------------------------------------------
--  DDL for Package GMIVILC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIVILC" AUTHID CURRENT_USER AS
/* $Header: GMIVILCS.pls 115.10 2002/11/11 20:58:58 jdiiorio ship $
*/

  PROCEDURE Validate_Lot_Conversion
                        (  p_api_version      IN  NUMBER
                         , p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
                         , p_item_cnv_rec     IN GMIGAPI.conv_rec_typ
                         , p_ic_item_mst_row  IN ic_item_mst%ROWTYPE
                         , p_ic_lots_mst_row  IN ic_lots_mst%ROWTYPE
                         , x_ic_item_cnv_row  OUT NOCOPY ic_item_cnv%ROWTYPE
                         , x_return_status    OUT NOCOPY VARCHAR2
                         , x_msg_count        OUT NOCOPY NUMBER
                         , x_msg_data         OUT NOCOPY VARCHAR2
                        );
END GMIVILC;

 

/
