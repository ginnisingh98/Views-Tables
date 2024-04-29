--------------------------------------------------------
--  DDL for Package BOM_VALIDATE_RTG_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE_RTG_REVISION" AUTHID CURRENT_USER AS
/* $Header: BOMLRRVS.pls 120.1 2006/01/03 22:23:31 bbpatel noship $ */
/*#
 * This API performs Attribute and Entity level validations for Routing Revision.
 * Entity level validations include existence and accessibility check for Routing
 * Revision record. Attribute level validations include check for required attributes and
 * business logic validations.
 *
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Validate Routing Revision
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
--   BOMLRRVS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate_Rtg_Revision
--
--  NOTES
--
--  HISTORY
--  07-AUG-2000 Biao Zhang    Initial Creation
--
****************************************************************************/


        /*#
         * Procedure will query the routing revision record and return it in old record variable.
         * If the Transaction Type is Create and the record already exists the return status
         * would be error. If the Transaction Type is Update or Delete and the record does not
         * exist then the return status would be an error as well. Such an error in a record will
         * cause all children to error out, since they are referencing an invalid parent.
         * Mesg_Token_Table will carry the error messsage and the tokens associated with the message.
         *
         * @param p_rtg_revision_rec IN Routing Revision Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
         * @param p_rtg_Rev_Unexp_rec  IN Routing Revision Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
         * @param x_old_rtg_revision_rec IN OUT NOCOPY Old Routing Revision Exposed Record if already exists
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
         * @param x_old_rtg_Rev_Unexp_rec  IN OUT NOCOPY Old Routing Revision Unexposed Record if already exists
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
         * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
         * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
         * @param x_return_status IN OUT NOCOPY Return Status
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Check Existence for Routing Revision record
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Check_Existence
        (  p_rtg_revision_rec       IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_rtg_rev_unexp_rec IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_old_rtg_revision_rec           IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , x_old_rtg_rev_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status          IN OUT NOCOPY VARCHAR2
        );

        /*#
         * This procedure checks the attributes validity. Validations include checking
         * for start effective date in case of update.
         *
         * @param x_return_status IN OUT NOCOPY Return Status
         * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
         * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
         * @param p_rtg_revision_rec IN Routing Revision Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
         * @param p_rtg_Rev_Unexp_rec  IN Routing Revision Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
         * @param p_old_rtg_revision_rec IN Old Routing Revision Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
         * @param p_old_rtg_Rev_Unexp_rec  IN Old Routing Revision Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Check Routing Revision attributes
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Check_Attributes
        (  x_return_status           IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , p_rtg_revision_Rec          IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_rtg_rev_unexp_rec       IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , p_old_rtg_revision_rec      IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_old_rtg_rev_unexp_rec   IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
        );


       /*#
        * Procedure to validate the Routing Revision entity record.
        * The following are checked.
        *	Non-updateable columns (UPDATEs): Certain columns must not be changed by the user when updating the record
        *	Cross-attribute checking: The validity of attributes may be checked, based on factors external to it
        *	Business logic: The record must comply with business logic rules.
        *
        * @param p_rtg_revision_rec IN Routing Revision Exposed Record
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
        * @param p_rtg_Rev_Unexp_rec  IN Routing Revision Unexposed Record
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
        * @param p_old_rtg_revision_rec IN Old Routing Revision Exposed Record
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
        * @param p_old_rtg_Rev_Unexp_rec  IN Old Routing Revision Unexposed Record
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
        * @param x_mesg_token_tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
        * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
        * @param x_return_status IN OUT NOCOPY Return Status
        *
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Check Routing Revision entity
        * @rep:compatibility S
        * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
        */
        PROCEDURE Check_Entity
        (  p_rtg_revision_rec     IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_rtg_rev_unexp_rec  IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , p_old_rtg_revision_rec   IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_old_rtg_rev_unexp_rec  IN Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status      IN OUT NOCOPY VARCHAR2
         );


END BOM_Validate_Rtg_Revision;

 

/
