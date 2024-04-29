--------------------------------------------------------
--  DDL for Package CSI_GIS_INSTANCE_LOC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_GIS_INSTANCE_LOC_PUB" AUTHID CURRENT_USER as
/* $Header: csipgils.pls 120.0.12010000.1 2008/11/07 13:41:45 jgootyag noship $ */

TYPE csi_instance_geoloc_rec_type IS RECORD
( INSTANCE_ID              NUMBER
 ,INST_LATITUDE            VARCHAR2(100)
 ,INST_LONGITUDE           VARCHAR2(100)
 ,VALID_FLAG               VARCHAR2(1)   :='Y'
 ,GEOCODE_FORMAT           VARCHAR2(3)   := 'DMS'
);

TYPE  csi_instance_geoloc_tbl_type  IS TABLE OF csi_instance_geoloc_rec_type
                                     INDEX BY BINARY_INTEGER;





PROCEDURE CREATEUPDATE_INST_GEOLOC_INFO
(
    p_api_version                IN           NUMBER
   ,p_commit	    	         IN           VARCHAR2 := FND_API.G_FALSE
   ,p_CSI_INSTANCE_geoloc_tbl    IN           CSI_GIS_INSTANCE_LOC_PUB.csi_instance_geoloc_tbl_type
   ,p_asset_context              IN           VARCHAR2 :='EAM'
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count		             OUT  NOCOPY  NUMBER
   ,x_msg_data	                 OUT  NOCOPY  VARCHAR2
);

PROCEDURE IMPORT_INSTANCE_GEO_LOCATION
(
    p_api_version       IN	NUMBER,
    p_commit	    	IN  	VARCHAR2 := FND_API.G_TRUE	,
    x_return_status     OUT     NOCOPY  VARCHAR2                ,
    x_msg_count		OUT	NOCOPY	NUMBER			,
    x_msg_data		OUT	NOCOPY	VARCHAR2
 )  ;

END CSI_GIS_INSTANCE_LOC_PUB;

/
