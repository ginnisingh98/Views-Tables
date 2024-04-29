--------------------------------------------------------
--  DDL for Package BOM_DEFAULT_RTG_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEFAULT_RTG_HEADER" AUTHID CURRENT_USER AS
/* $Header: BOMDRTGS.pls 120.1 2006/01/03 21:54:25 bbpatel noship $*/
/*#
 * This API contains procedures that will copy values from Routing Header record provided by the user.
 * In old record, atrributes having null values or not provided by the user, will be defaulted
 * to appropriate value. In the case of create, attributes will be defaulted to appropriate value.
 *
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Default Routing Header record attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDRTGS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Default_Rtg_Header
--
--  NOTES
--
--  HISTORY
--  07-AUG-2000 Biao Zhang   Initial Creation
--
****************************************************************************/

        /*#
         * Procedure to default values for exposed Routing Header record.
         * In old record, atrributes, having null values or not provided by the user, will be defaulted
         * to appropriate value. For CREATEs, there is no OLD record. So procedure will default
         * individual attribute values, independent of each other. This
         * feature enables the user to enter minimal information for the
         * operation to go through.
         *
         * @param p_rtg_header_rec IN Routing Header Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
         * @param p_rtg_header_unexp_rec  IN Routing Header Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
         * @param x_rtg_header_rec IN OUT NOCOPY Routing Header Exposed Record after defaulting
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
         * @param x_rtg_header_unexp_rec IN OUT NOCOPY Routing Header Unexposed Record after defaulting
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
         * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
         * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
         * @param x_return_status IN OUT NOCOPY Return Status of the Business Object
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Default Routing Header record attributes
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Attribute_Defaulting
        (  p_rtg_header_rec     IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , p_rtg_header_unexp_rec IN  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_rtg_header_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , x_rtg_header_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status      IN OUT NOCOPY VARCHAR2
         );

        /*#
         * Procedure to default values for unexposed Routing Header record.
         * In old record, atrributes, having null values or not provided by the user, will be defaulted
         * to appropriate value. For CREATEs, there is no OLD record. So procedure will default
         * individual attribute values, independent of each other.
         *
         * @param p_rtg_header_rec IN Routing Header Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
         * @param p_rtg_header_unexp_rec  IN Routing Header Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
         * @param x_rtg_header_rec IN OUT NOCOPY Routing Header Exposed Record after defaulting
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
         * @param x_rtg_header_unexp_rec IN OUT NOCOPY Routing Header Unexposed Record after defaulting
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
         * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
         * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
         * @param x_return_status IN OUT NOCOPY Return Status of the Business Object
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Default Routing Header entity attributes
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Entity_Attribute_Defaulting
        (  p_rtg_header_rec     IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , p_rtg_header_unexp_rec IN  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_rtg_header_rec       IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , x_rtg_header_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status        IN OUT NOCOPY VARCHAR2
         );

        /*#
         * Procedure to copy the existing values from old Routing Header record, when the user has not
         * given the attribute values. This procedure will not be called in CREATE case.
         *
         * @param p_rtg_header_rec IN Routing Header Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
         * @param p_rtg_header_unexp_rec  IN Routing Header Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
         * @param p_old_rtg_header_rec IN Old Routing Header Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
         * @param p_old_rtg_header_unexp_rec  IN Old Routing Header Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
         * @param x_rtg_header_rec IN OUT NOCOPY Routing Header Exposed Record after processing
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
         * @param x_rtg_header_unexp_rec IN OUT NOCOPY Routing Header Unexposed Record after processing
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Populate Null Routing Header attributes
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Populate_Null_Columns
        (  p_rtg_header_rec     IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , p_rtg_header_unexp_rec IN  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , p_old_rtg_header_rec IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , p_old_rtg_header_unexp_rec IN Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_rtg_header_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , x_rtg_header_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
        );


        /*#
         * Function to get new Routing Sequence Id
         *
         * @return Routing Sequence Id
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Get Routing Sequence Id
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        -- Get Routing Sequence Id
        FUNCTION Get_routing_Sequence
        RETURN NUMBER ;

        /*#
         * Function to get the default CFM Routing Flag. Returns 2(Standard Routing).
         *
         * @return CFM Routing Flag
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Get CFM Routing Flag
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        -- Get_Cfm_Routing_Flag
        FUNCTION Get_Cfm_Routing_Flag
        RETURN NUMBER ;

        /*#
         * Function to get the default Mixed Model Map flag. Returns 2(No).
         *
         * @return Mixed Model Map flag
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Get Mixed Model Map flag
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        -- Get_Mixed_Model_Map_Flag
        FUNCTION  Get_Mixed_Model_Map_Flag
        RETURN NUMBER ;

        /*#
         * Function to get the default CTP flag. Returns 2(No).
         *
         * @return CTP flag
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Get CTP flag
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        -- Get_Ctp_Flag
        FUNCTION   Get_Ctp_Flag
        RETURN NUMBER ;



END BOM_Default_Rtg_Header;

 

/
