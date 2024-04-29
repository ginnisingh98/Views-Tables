--------------------------------------------------------
--  DDL for Package BOM_RTG_ERROR_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_ERROR_HANDLER" AUTHID CURRENT_USER AS
/* $Header: BOMROEHS.pls 115.4 2002/11/21 05:58:55 djebar ship $ */
/*************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMROEHS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Rtg_Error_Handler
--
--  NOTES   This package is created to make the RTG Business Object
--          independent of Bom Business Object.
--          Log_Error for Routing Bo procedure have been moved here from
--          Error_Handler package. This Log_Error procedure calls
--          Error Handler's functions.
--
--
--  HISTORY
--
--  04-Jan-99   Masanori Kimizuka     Initial Creation
--
--
--
*************************************************************************/
        --  Global constant holding the package name
        G_PKG_NAME              CONSTANT VARCHAR2(30)   := 'Bom_Rtg_Error_Handler';

        G_BO_LEVEL              CONSTANT NUMBER         := 0;
        G_ECO_LEVEL             CONSTANT NUMBER         := 1;
        G_REV_LEVEL             CONSTANT NUMBER         := 2;
        G_RI_LEVEL              CONSTANT NUMBER         := 3;
        G_RC_LEVEL              CONSTANT NUMBER         := 4;
        G_RD_LEVEL              CONSTANT NUMBER         := 5;
        G_SC_LEVEL              CONSTANT NUMBER         := 6;
        G_RTG_LEVEL             CONSTANT NUMBER         := 8;
        G_OP_LEVEL              CONSTANT NUMBER         := 9;
        G_RES_LEVEL             CONSTANT NUMBER         := 10;
        G_SR_LEVEL              CONSTANT NUMBER         := 11;
        G_NWK_LEVEL             CONSTANT NUMBER         := 12;

        G_STATUS_WARNING        CONSTANT VARCHAR2(1)    := 'W';
        G_STATUS_UNEXPECTED     CONSTANT VARCHAR2(1)    := 'U';
        G_STATUS_ERROR          CONSTANT VARCHAR2(1)    := 'E';
        G_STATUS_FATAL          CONSTANT VARCHAR2(1)    := 'F';
        G_STATUS_NOT_PICKED     CONSTANT VARCHAR2(1)    := 'N';

        G_SCOPE_ALL             CONSTANT VARCHAR2(1)    := 'A';
        G_SCOPE_RECORD          CONSTANT VARCHAR2(1)    := 'R';
        G_SCOPE_SIBLINGS        CONSTANT VARCHAR2(1)    := 'S';
        G_SCOPE_CHILDREN        CONSTANT VARCHAR2(1)    := 'C';



     /*******************************************************
     -- Log_Error prodedure used for Routing Business Object
     -- moved from Error_Handler.
     ********************************************************/
     PROCEDURE Log_Error
     ( p_rtg_header_rec          IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
     , p_rtg_revision_tbl        IN  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
     , p_operation_tbl           IN  Bom_Rtg_Pub.Operation_Tbl_Type
     , p_op_resource_tbl         IN  Bom_Rtg_Pub.Op_Resource_Tbl_Type
     , p_sub_resource_tbl        IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
     , p_op_network_tbl          IN  Bom_Rtg_Pub.Op_Network_Tbl_Type
     , p_Mesg_Token_tbl          IN  Error_Handler.Mesg_Token_Tbl_Type
     , p_error_status            IN  VARCHAR2
     , p_error_scope             IN  VARCHAR2
     , p_other_message           IN  VARCHAR2
     , p_other_mesg_appid        IN  VARCHAR2
     , p_other_status            IN  VARCHAR2
     , p_other_token_tbl         IN  Error_Handler.Token_Tbl_Type
     , p_error_level             IN  NUMBER
     , p_entity_index            IN  NUMBER
     , x_rtg_header_rec          IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
     , x_rtg_revision_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
     , x_operation_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Operation_Tbl_Type
     , x_op_resource_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Tbl_Type
     , x_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Tbl_Type
     , x_op_network_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Tbl_Type
     ) ;


END Bom_Rtg_Error_Handler ;

 

/
