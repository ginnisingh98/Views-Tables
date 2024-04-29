--------------------------------------------------------
--  DDL for Package BOM_DEFAULT_RTG_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEFAULT_RTG_REVISION" AUTHID CURRENT_USER AS
/* $Header: BOMDRRVS.pls 120.1 2006/01/03 22:21:24 bbpatel noship $ */
/*#
 * This API contains procedures that will copy values from Routing Revision record provided by the user.
 * In old record, atrributes having null values or not provided by the user, will be defaulted
 * to appropriate value. In the case of create, attributes will be defaulted to appropriate value.
 *
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Default Routing Revision record attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--    BOMDRRVS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Default_Rtg_Revision
--
--  NOTE
--
--  HISTORY
--  07-AUG-2000 Biao Zhang Initial Creation
--
****************************************************************************/

        /*#
         * Procedure to default values for exposed Routing Revision record.
         * In old record, atrributes, having null values or not provided by the user, will be defaulted
         * to appropriate value. For CREATEs, there is no OLD record. So procedure will default
         * individual attribute values, independent of each other. This
         * feature enables the user to enter minimal information for the
         * operation to go through.
         *
         * @param p_rtg_revision_rec IN Routing Revision Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
         * @param p_rtg_Rev_Unexp_rec  IN Routing Revision Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
         * @param x_rtg_revision_rec IN OUT NOCOPY Routing Revision Exposed Record after defaulting
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
         * @param x_rtg_Rev_Unexp_rec IN OUT NOCOPY Routing Revision Unexposed Record after defaulting
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
         * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
         * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
         * @param x_return_status IN OUT NOCOPY Return Status
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Default Routing Revision record attributes
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Attribute_Defaulting
        (  p_rtg_revision_rec   IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_rtg_Rev_Unexp_rec  IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_rtg_revision_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , x_rtg_Rev_Unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status      IN OUT NOCOPY VARCHAR2
         );

        /*#
         * Procedure to default values for start effectivity date and
         * implementation date.
         *
         * @param p_rtg_revision_rec IN Routing Revision Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
         * @param p_rtg_Rev_Unexp_rec  IN Routing Revision Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
         * @param x_rtg_revision_rec IN OUT NOCOPY Routing Revision Exposed Record after defaulting
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
         * @param x_rtg_Rev_Unexp_rec IN OUT NOCOPY Routing Revision Unexposed Record after defaulting
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
         * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
         * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
         * @param x_return_status IN OUT NOCOPY Return Status
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Default Routing Revision entity attributes
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Entity_Attribute_Defaulting
        (  p_rtg_revision_rec   IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_rtg_Rev_Unexp_rec  IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_rtg_revision_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , x_rtg_Rev_Unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status      IN OUT NOCOPY VARCHAR2
         );

        /*#
         * Procedure to copy the existing values from old Routing Revision record, when the user has not
         * given the attribute values. This procedure will not be called in CREATE case.
         *
         * @param p_rtg_revision_rec IN Routing Revision Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
         * @param p_rtg_Rev_Unexp_rec  IN Routing Revision Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
         * @param p_old_rtg_revision_rec IN Old Routing Revision Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
         * @param p_old_rtg_Rev_Unexp_rec  IN Old Routing Revision Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
         * @param x_rtg_revision_rec IN OUT NOCOPY Routing Revision Exposed Record after processing
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
         * @param x_rtg_Rev_Unexp_rec IN OUT NOCOPY Routing Revision Unexposed Record after processing
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Populate Null Routing Revision attributes
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Populate_Null_Columns
        (  p_rtg_revision_rec      IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_rtg_Rev_Unexp_rec     IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , p_old_rtg_revision_rec  IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_old_rtg_Rev_Unexp_rec IN Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_rtg_revision_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , x_rtg_Rev_Unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
        );


END BOM_Default_Rtg_Revision;


 

/
