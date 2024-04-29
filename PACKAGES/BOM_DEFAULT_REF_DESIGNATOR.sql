--------------------------------------------------------
--  DDL for Package BOM_DEFAULT_REF_DESIGNATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEFAULT_REF_DESIGNATOR" AUTHID CURRENT_USER AS
/* $Header: BOMDRFDS.pls 120.0 2005/05/25 07:04:44 appldev noship $ */
/*#
 * This API contains methods that will try to copy over values from OLD record for all NULL columns found in
 * business object Reference Designator record and to default in values either by retrieving them from the database,
 * or by having the program  assign values.
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Reference Designator Defaulting
 */

--  Procedure Attributes
	/*#
	 * This method will try to default in values,for all NULL columns found in business object Reference
	 * Designator record either by retrieving them from the database, or by having the program
	 * assign values.For CREATEs, there is no OLD record. So the program must default
	 * in individual attribute values,independently of each other. This
	 * feature enables the user to enter minimal information for the
	 * operation to go through.
	 * @param p_ref_designator_rec IN Reference Designator Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type}
	 * @param p_ref_desg_unexp_rec IN Reference Designator Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type}
	 * @param x_ref_designator_rec IN OUT NOCOPY processed Reference Designator Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type}
	 * @param x_Ref_Desg_Unexp_Rec IN OUT NOCOPY processed Reference Designator Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type}
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_Return_Status IN OUT NOCOPY Return Status of the business object.
	 * @rep:scope public
	 * @rep:lifecycle active
	 * @rep:compatibility S
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:displayname Refernce Designator-Attribute Defaulting
	 */
PROCEDURE Attribute_Defaulting
(   p_ref_designator_rec	IN  Bom_Bo_Pub.Ref_Designator_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
,   p_ref_desg_unexp_rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_ref_designator_rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
,   x_Ref_Desg_Unexp_Rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_Return_Status		IN OUT NOCOPY VARCHAR2
);


        /*#
	 * This method will copy over values from OLD record for all NULL columns found in
	 * business object Reference Designator record of type  Bom_Bo_Pub.Ref_Designator_Rec_Type
	 * The user may send in a record with
	 * certain values set to NULL. Values for all such columns are copied over
	 * from the OLD record. This feature enables the user to enter minimal
	 * information for the operation.
	 * @param p_ref_designator_rec IN Reference Designator Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type}
	 * @param p_ref_desg_unexp_rec IN Reference Designator Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type}
	 * @param  p_old_Ref_Designator_Rec IN Reference Designator Old Record Exposed Column
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type}
	 * @param p_old_ref_desg_unexp_rec IN Reference Designator Old Record Unexposed Column Record.
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type}
	 * @param x_Ref_Designator_Rec IN OUT NOCOPY processed Reference Designator Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Ref_Designator_Rec_Type}
	 * @param x_ref_desg_unexp_rec IN OUT NOCOPY processed Reference Designator Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type}
	 * @rep:scope public
	 * @rep:lifecycle active
	 * @rep:compatibility S
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:displayname Refernce Designator-Populate NULL Columns
	 */
PROCEDURE Populate_Null_Columns
(   p_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_ref_desg_unexp_rec        IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   p_old_Ref_Designator_Rec    IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_old_ref_desg_unexp_rec    IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_Ref_Designator_Rec        IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
,   x_ref_desg_unexp_rec        IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
);


/*
** BOM Business Object Definitions
*/
	/*#
	 * This method will try to default in values,for all NULL columns found in business object Reference
	 * record either by retrieving them from the database, or by having the program
	 * assign values.For CREATEs, there is no OLD record. So the program must default
	 * in individual attribute values,independently of each other. This
	 * feature enables the user to enter minimal information for the
	 * operation to go through.
	 * @param p_bom_ref_designator_rec IN BOM Reference Designator Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type}
	 * @param p_bom_ref_desg_unexp_rec IN BOM Reference Designator Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type}
	 * @param x_bom_ref_designator_rec IN OUT NOCOPY processed BOM Reference Designator Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type}
	 * @param x_bom_Ref_Desg_Unexp_Rec IN OUT NOCOPY processed BOM Reference Designator Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type}
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_Return_Status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Ref Desg-Attribute Defaulting
	 * @rep:compatibility S
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:lifecycle active
	 */
PROCEDURE Attribute_Defaulting
(   p_bom_ref_designator_rec   IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type :=
                                   Bom_Bo_Pub.G_MISS_Bom_REF_DESIGNATOR_REC
,   p_bom_ref_desg_unexp_rec   IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
,   x_bom_ref_designator_rec   IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   x_bom_Ref_Desg_Unexp_Rec   IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
,   x_Mesg_Token_Tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_Return_Status            IN OUT NOCOPY VARCHAR2
);


/*#
	 * This method will copy over values from OLD record for all NULL columns found in
	 * business object Reference Designator record of type  Bom_Bo_Pub.Ref_Designator_Rec_Type
	 * The user may send in a record with
	 * certain values set to NULL. Values for all such columns are copied over
	 * from the OLD record. This feature enables the user to enter minimal
	 * information for the operation.
	 * @param p_bom_ref_designator_rec IN BOM Refence Designator Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type}
	 * @param p_bom_ref_desg_unexp_rec IN BOM Reference Designator Unexposed Cloumn Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type}
	 * @param p_old_bom_Ref_Designator_Rec IN BOM Refence Designator Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type}
	 * @param p_old_bom_ref_desg_unexp_rec IN BOM Reference Designator Old Record Unexposed Cloumn Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type}
	 * @param x_bom_Ref_Designator_Rec IN OUT NOCOPY processed BOM Refence Designator Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type}
	 * @param x_bom_ref_desg_unexp_rec IN OUT NOCOPY processed  BOM Reference Designator Unexposed Cloumn Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Ref Desg-Populate NULL Column
	 * @rep:compatibility S
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:lifecycle active
	 */
PROCEDURE Populate_Null_Columns
(   p_bom_ref_designator_rec     IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   p_bom_ref_desg_unexp_rec     IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
,   p_old_bom_Ref_Designator_Rec IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   p_old_bom_ref_desg_unexp_rec IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
,   x_bom_Ref_Designator_Rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   x_bom_ref_desg_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
);

END BOM_Default_Ref_Designator;

 

/
