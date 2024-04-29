--------------------------------------------------------
--  DDL for Package OE_BULK_CONFIG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_CONFIG_UTIL" AUTHID CURRENT_USER As
/* $Header: OEBUCFGS.pls 120.0.12010000.2 2008/11/19 02:02:01 smusanna noship $ */



---------------------------------------------------------------------
--
-- PROCEDURE Pre_Process
--
---------------------------------------------------------------------

PROCEDURE Pre_Process
( p_batch_id                IN NUMBER
 ,p_validate_only	    IN VARCHAR2
 ,p_use_configurator	    IN VARCHAR2
 ,p_validate_configurations IN VARCHAR2
);


---------------------------------------------------------------------
--
-- PROCEDURE Pre_Process_Configurator
--
---------------------------------------------------------------------

PROCEDURE Pre_Process_Configurator
( p_batch_id                IN NUMBER
 ,p_validate_only	    IN VARCHAR2
 ,p_use_configurator	    IN VARCHAR2
 ,p_validate_configurations IN VARCHAR2
);


---------------------------------------------------------------------
--
-- PROCEDURE Pre_Process_Bom
--
---------------------------------------------------------------------

PROCEDURE Pre_Process_Bom
( p_batch_id                IN NUMBER
 ,p_validate_only	    IN VARCHAR2
 ,p_use_configurator	    IN VARCHAR2
 ,p_validate_configurations IN VARCHAR2
);


---------------------------------------------------------------------
--
-- PROCEDURE Delete_Configurations
--
---------------------------------------------------------------------

PROCEDURE  Delete_Configurations
(  p_error_rec          IN 	OE_BULK_ORDER_PVT.INVALID_HDR_REC_TYPE
  ,x_return_status      OUT NOCOPY VARCHAR2
);




PROCEDURE Print_Line_Rec
        ( p_line_rec  	IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE );

-----------------------------------------------------------------
--  Config record type
-----------------------------------------------------------------
TYPE Config_Rec_Type IS RECORD
(

--
-- BOM columns
--
 high_quantity			OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,low_quantity			OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,mutually_exclusive_options	OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,bom_item_type		        OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,replenish_to_order_flag        OE_WSH_BULK_GRP.T_V1  := OE_WSH_BULK_GRP.T_V1()
);


-----------------------------------------------------------------
-- Global Config Record do these global and datatypes need to be here
-----------------------------------------------------------------
G_CONFIG_REC Config_Rec_Type;


END OE_BULK_CONFIG_UTIL;

/
