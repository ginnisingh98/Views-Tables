--------------------------------------------------------
--  DDL for Package BOMPCMBM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPCMBM" AUTHID CURRENT_USER AS
/* $Header: BOMCMBMS.pls 120.9.12010000.6 2015/07/10 12:18:24 nlingamp ship $ */
/*#
 * This package contains all the procedures required for creating and maintaining common Boms.
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Create, Add or Update Bill of Material Business Entities
 * @rep:compatibility S
 */


/*==========================================================================+
|   Copyright (c) 1993, 2015 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMCMBMS.pls                                               |
| DESCRIPTION  : This file is a packaged specification for creating
|                common bill  for the following organization scope :
|                a) Single organization
|                b) Organization Hierarchy
|                c) All Organizations
| Parameters:   scope           1 - Single Organization, 2-Org Hierarchy
|                               3 - All Orgs
|               org_hierarchy   Organization Hierarchy
|               Current_org_id  Organization from where the concprogram launch
|               Common_item_from Item from which commoning to be done
|               alternate       alternate bom designator of the commonitemfrom
|               common_item_to  Item to which commoning to be done for scope=1
|               common_org_to   Org to which commoning to be done for scope=1
|               error_code      error code
|               error_msg       error message
|History :
|29-SEP-00	Shailendra	CREATED
|06-May-05  Abhishek Rudresh Common BOM Attrs update.
+==========================================================================*/
/*#
 * This Procedure is used to create common bills.
 * @param ERRBUF OUT VARCHAR2
 * @param RETCODE OUT VARCHAR2
 * @param scope IN NUMBER
 * @param org_hierarchy IN VARCHAR2
 * @param current_org_id IN NUMBER
 * @param common_item_from IN NUMBER
 * @param alternate IN VARCHAR2
 * @param common_org_to IN NUMBER
 * @param common_item_to IN NUMBER
 * @param enable_attrs_update IN VARCHAR2
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Enable Attributes Update on Common Bom
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE create_common_bills(
	ERRBUF                  IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2,
	RETCODE                 IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2,
        scope                   IN      NUMBER          DEFAULT 1,
        org_hierarchy           IN      VARCHAR2        DEFAULT NULL,
        current_org_id          IN      NUMBER,
        common_item_from        IN      NUMBER,
        alternate               IN      VARCHAR2        DEFAULT NULL,
        common_org_to           IN      NUMBER        DEFAULT NULL,
        common_item_to          IN      NUMBER        DEFAULT NULL
        , enable_attrs_update     IN      VARCHAR2      DEFAULT NULL
        ) ;



/*#
 * This Procedure will modify the bill header attributes of a common BOM to make it updateable.
 * @param p_bill_sequence_id IN Bill Sequence Id of the common BOM
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Enable Attributes Update on Common Bom
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Dereference_Header(p_bill_sequence_id IN NUMBER);


/*#
 * This Procedure will replicate the components of the source BOM as components of the Common BOM.
 * @param p_src_bill_sequence_id IN Bill Sequence Id of the source BOM
 * @param p_dest_bill_sequence_id IN Bill Sequence Id of the common BOM
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Replicate Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Replicate_Components (p_src_bill_sequence_id IN NUMBER
	                              , p_dest_bill_sequence_id IN NUMBER
                                , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                , x_Return_Status   IN OUT NOCOPY VARCHAR2);




/*#
 * This is an overloaded Procedure to replicate the components of the source BOM as components of the Common BOM.
 * @param p_src_bill_sequence_id IN Bill Sequence Id of the source BOM
 * @param p_dest_bill_sequence_id IN Bill Sequence Id of the common BOM
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Replicate Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Replicate_Components (p_src_bill_sequence_id IN NUMBER
	                              , p_dest_bill_sequence_id IN NUMBER);



/*#
 * This Procedure should be called when a component is added to a bom that is commoned by other boms.
 * This will add the component to the common boms.
 * @param p_src_bill_seq_id IN Bill Sequence Id of the source BOM
 * @param p_src_comp_seq_id IN Component Sequence Id of the component added
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Insert Related Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Insert_Related_Components (p_src_bill_seq_id   IN NUMBER
                                     , p_src_comp_seq_id   IN NUMBER
                                     , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                     , x_Return_Status   IN OUT NOCOPY VARCHAR2);


--Bug 9356298 Start
Procedure Delete_Related_Components(p_src_comp_seq IN NUMBER);
--Bug 9356298 End

/*#
 * This is an overloaded Procedure called when a component is added to a bom that is commoned by other boms.
 * This will add the component to the common boms.
 * @param p_src_bill_seq_id IN Bill Sequence Id of the source BOM
 * @param p_src_comp_seq_id IN Component Sequence Id of the component added
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Insert Related Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Insert_Related_Components (p_src_bill_seq_id   IN NUMBER
                                     , p_src_comp_seq_id   IN NUMBER);

--Bug 9238945 begin
PROCEDURE Update_Impl_Rel_Comp(p_src_comp_seq_id   IN NUMBER);
--Bug 9238945 end

/*#
 * This Procedure should be called when a component is updated in a bom that is commoned by other boms.
 * This will update the component in the common boms.
 * @param p_src_comp_seq_id IN Component Sequence Id of the component updated
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Update Related Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Update_Related_Components (p_src_comp_seq_id   IN NUMBER
                                     , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                     , x_Return_Status   IN OUT NOCOPY VARCHAR2);





/*#
 * This overloaded Procedure should be called from java when a component is updated in a bom that is commoned by other boms.
 * This will update the component in the common boms.
 * @param p_src_comp_seq_id IN Component Sequence Id of the component updated
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Update Related Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Update_Related_Components (p_src_comp_seq_id   IN NUMBER);




/*#
 * This Procedure  will replicate the ref designators of components of the source BOM as ref desgs of components of the Common BOM.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Replicate Reference Designators
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Replicate_Ref_Desg(p_component_sequence_id IN NUMBER
                             , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                             , x_Return_Status   IN OUT NOCOPY VARCHAR2);




/*#
 * This overloaded Procedure should be called from java to replicate the ref designators of components of the source BOM as ref desgs of components of the Common BOM.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Replicate Reference Designators
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Replicate_Ref_Desg(p_component_sequence_id IN NUMBER);




/*#
 * This Procedure is used to add reference designators to the related components of the common boms whenever
 * reference designator is added to a component of a source bom.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_ref_desg IN Reference Designator added.
 * @param p_acd_type IN ACD TYPE of the reference disignator, added for bug 20345308
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Insert Related Reference Designators
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Insert_Related_Ref_Desg(p_component_sequence_id IN NUMBER
                                  , p_ref_desg IN VARCHAR2
				  , p_acd_type IN VARCHAR2
                                  , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2);




/*#
 * This overloaded Procedure is called from Java to add reference designators to the related components of the common boms whenever
 * reference designator is added to a component of a source bom.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_ref_desg IN Reference Designator added.
 * @param p_acd_type IN ACD TYPE of the reference disignator, added for bug 20345308
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Insert Related Reference Designators
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Insert_Related_Ref_Desg(p_component_sequence_id IN NUMBER
                                  , p_ref_desg IN VARCHAR2
				  , p_acd_type IN VARCHAR2);





/*#
 * This Procedure is used to update reference designators of the related components of the common boms whenever
 * reference designator of a component of a source bom is updated.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_old_ref_desg IN Original Reference Designator updated.
 * @param p_new_ref_desg IN Modified Reference Designator.
 * @param p_acd_type IN ACD type of the record.
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Update Related Reference Designators
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Update_Related_Ref_Desg(p_component_sequence_id IN NUMBER
                                  , p_old_ref_desg IN VARCHAR2
                                  , p_new_ref_desg IN VARCHAR2
                                  , p_acd_type IN NUMBER
                                  , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2);





/*#
 * This overloaded Procedure is called from Java to update reference designators of the related components of the common boms whenever
 * reference designator of a component of a source bom is updated.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_old_ref_desg IN Original Reference Designator updated.
 * @param p_new_ref_desg IN Modified Reference Designator.
 * @param p_acd_type IN ACD type of the record.
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Update Related Reference Designators
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Update_Related_Ref_Desg(p_component_sequence_id IN NUMBER
                                  , p_old_ref_desg IN VARCHAR2
                                  , p_new_ref_desg IN VARCHAR2
                                  , p_acd_type IN NUMBER);



/*#
 * This Procedure  will replicate the substitutes of components of the source BOM as susbtitutes of components of the Common BOM.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Replicate Substitute Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Replicate_Sub_Comp(p_component_sequence_id IN NUMBER
                             , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                             , x_Return_Status   IN OUT NOCOPY VARCHAR2);





/*#
 * This overloaded Procedure is called from Java to replicate the substitutes of components of the source BOM
 * as susbtitutes of components of the Common BOM.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Replicate Substitute Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Replicate_Sub_Comp(p_component_sequence_id IN NUMBER);



/*#
 * This Procedure is used to add Substitute Components to the related components of the common boms whenever
 * a substitute component is added to a component of a source bom.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_sub_comp_item_id IN Substitute Component Id added.
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Insert Related Substitute Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Insert_Related_Sub_Comp(p_component_sequence_id IN NUMBER
                                  , p_sub_comp_item_id IN NUMBER
                                  , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2);




/*#
 * This overloaded Procedure is called from Java to add Substitute Components to the related components of the common boms whenever
 * a substitute component is added to a component of a source bom.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_sub_comp_item_id IN Substitute Component Id added.
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Insert Related Substitute Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Insert_Related_Sub_Comp(p_component_sequence_id IN NUMBER
                                  , p_sub_comp_item_id IN NUMBER);




/*#
 * This Procedure is used to update substitutes of the related components of the common boms whenever
 * substitute of a component of a source bom is updated.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_old_sub_comp_item_id IN Original Substitute Component Id.
 * @param p_new_sub_comp_item_id IN Substitute Component Id modified.
 * @param p_acd_type IN ACD type of the record.
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Update Related Substitute Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Update_Related_Sub_Comp(p_component_sequence_id IN NUMBER
                                  , p_old_sub_comp_item_id IN NUMBER
                                  , p_new_sub_comp_item_id IN NUMBER
                                  , p_acd_type IN NUMBER
                                  , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2);




/*#
 * This overloaded Procedure is called from Java to update substitutes of the related components of the common boms whenever
 * substitute of a component of a source bom is updated.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_old_sub_comp_item_id IN Original Substitute Component Id.
 * @param p_new_sub_comp_item_id IN Substitute Component Id modified.
 * @param p_acd_type IN ACD type of the record.
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Update Related Substitute Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Update_Related_Sub_Comp(p_component_sequence_id IN NUMBER
                                  , p_old_sub_comp_item_id IN NUMBER
                                  , p_new_sub_comp_item_id IN NUMBER
                                  , p_acd_type IN NUMBER);



/*#
 * This Procedure  will replicate the component operations of the source BOM as component operations of the Common BOM.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Replicate Component Operations
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Replicate_Comp_Ops(p_component_sequence_id IN NUMBER
                             , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                             , x_Return_Status   IN OUT NOCOPY VARCHAR2);





/*#
 * This overloaded Procedure is called from Java to replicate the component operations of the source BOM
 * as component operations of the Common BOM.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Replicate Component Operations
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Replicate_Comp_Ops(p_component_sequence_id IN NUMBER);



/*#
 * This Procedure is used to add Component Operations to the related components of the common boms whenever
 * a component operation is added to a component of a source bom.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_operation_seq_num IN Component Operation sequence number added.
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Insert Related Component Operations
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Insert_Related_Comp_Ops(p_component_sequence_id IN NUMBER
                                  , p_operation_seq_num IN NUMBER
                                  , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2);




/*#
 * This overloaded Procedure is called from Java to add Component Operations to the related components of the common boms whenever
 * a Component Operation is added to a component of a source bom.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_operation_seq_num IN Operation Sequence added.
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Insert Related Component Operations
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Insert_Related_Comp_Ops(p_component_sequence_id IN NUMBER
                                  , p_operation_seq_num IN NUMBER);




/*#
 * This Procedure is used to update Component Operations of the related components of the common boms whenever
 * Component Operations of a source bom is updated.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_old_operation_seq_num IN old Component Operation seq num.
 * @param p_new_operation_seq_num IN new Component Operation seq num modified.
 * @param x_Mesg_Token_Tbl IN OUT Message tokens in the error message thrown.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Update Related Component Operations
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Update_Related_Comp_Ops(p_component_sequence_id IN NUMBER
                                  , p_old_operation_seq_num IN NUMBER
                                  , p_new_operation_seq_num IN NUMBER
                                  , x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2);




/*#
 * This overloaded Procedure is called from Java to update Component Operations of the common boms whenever
 * Component Operations of a source bom is updated.
 * @param p_component_sequence_id IN Component Sequence Id of the component updated
 * @param p_old_operation_seq_num IN old Component Operation seq num.
 * @param p_new_operation_seq_num IN new Component Operation seq num modified.
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Update Related Component Operations
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Update_Related_Comp_Ops(p_component_sequence_id IN NUMBER
                                  , p_old_operation_seq_num IN NUMBER
                                  , p_new_operation_seq_num IN NUMBER);




/*#
 * This Procedure is used to delete related comp ops from the referencing boms when comp ops
 * from the source bom is deleted.
 * @param p_src_comp_seq_id IN Component Sequence Id of the source component.
 * @param p_operation_seq_num  IN Operation sequence number of the dest source component.
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Delete Related Component Operations
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Delete_Related_Comp_Ops(p_src_comp_seq_id IN NUMBER,
                                   p_operation_seq_num IN NUMBER,
                                   x_Return_Status   IN OUT NOCOPY VARCHAR2);


/*#
 * This Procedure is used to validate the operation sequences of the source bom.
 * @param p_src_bill_sequence_id IN Bill Sequence Id of the source bom
 * @param p_assembly_item_id IN Assembly Item Id of the common bom.
 * @param p_organization_id IN Organization Id of the Commmon BOM
 * @param p_alt_desg IN Alternate BOM Designator of the BOM
 * @param x_Return_Status IN OUT Return Status of the api: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Validate Operation Sequence Id
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
PROCEDURE Validate_Operation_Sequence_Id(p_src_bill_sequence_id IN NUMBER
                                         , p_assembly_item_id IN NUMBER
                                         , p_organization_id IN NUMBER
                                         , p_alt_desg IN VARCHAR2
                                         , x_Return_Status  IN OUT NOCOPY VARCHAR2);




/*#
 * This Procedure is used to copy the component user attributes from the source bom.
 * @param p_src_comp_seq_id IN Component Sequence Id of the source source component.
 * @param p_attr_grp_id IN Attribute Group Id of the source component.
 * @param x_Return_Status OUT Return Status of the API: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Validate Operation Sequence Id
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
Procedure Propagate_Comp_User_Attributes(p_src_comp_seq_id IN NUMBER
                                         , p_attr_grp_id IN NUMBER
                                         , x_Return_Status OUT NOCOPY VARCHAR2);


/*#
 * This Function is used to validate the operation seq num from the source bom
 * whenever a component is added to it.
 * @return boolean
 * @param p_src_bill_seq_id IN Bill Sequence Id of the source bom.
 * @param p_op_seq IN Operation Sequence number
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Check Operation Sequence Id in Referring BOMs
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
Function Check_Op_Seq_In_Ref_Boms(p_src_bill_seq_id IN NUMBER
                                   , p_op_seq IN NUMBER)
Return boolean;



/*#
 * This Procedure is used to replicate the component user attributes from the source bom.
 * @param p_src_bill_seq_id IN Bill Sequence Id of the source component.
 * @param p_dest_bill_seq_id IN Bill Sequence Id of the dest source component.
 * @param x_Return_Status OUT Return Status of the API: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Replicate Component User Attributes
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
Procedure Replicate_Comp_User_Attrs(p_src_bill_seq_id IN NUMBER,
                                    p_dest_bill_seq_id IN NUMBER,
                                    x_Return_Status OUT NOCOPY VARCHAR2);



/*#
 * This Procedure is used to delete related ref desgs from the referencing boms when ref desg
 * from the source bom is deleted.
 * @param p_src_comp_seq IN Component Sequence Id of the source component.
 * @param p_ref_desg IN Ref Desg of the dest source component.
 * @param x_Return_Status OUT Return Status of the API: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Delete Related Reference Designators
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
Procedure Delete_Related_Ref_Desg(p_src_comp_seq IN NUMBER
                                  , p_ref_desg IN VARCHAR2
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2);

/*#
 * This Procedure is used to delete related sub comps from the referencing boms when sub comps
 * from the source bom is deleted.
 * @param p_src_comp_seq IN Component Sequence Id of the source component.
 * @param p_sub_comp_item_id IN Sub Comp of the dest source component.
 * @param x_Return_Status OUT Return Status of the API: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Delete Related Substitute Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
Procedure Delete_Related_Sub_Comp(p_src_comp_seq IN NUMBER
                                  , p_sub_comp_item_id IN NUMBER
                                  , x_Return_Status   IN OUT NOCOPY VARCHAR2);

/*#
 * This Function is used to check if the insertion of related records caused overlapping components
 * @param p_dest_bill_sequence_id IN Bill Sequence Id of the dest component.
 * @param p_dest_comp_seq_id IN component seq id of the dest component.
 * @param p_comp_item_id IN component item id
 * @param p_op_seq_num IN op seq of source component
 * @param p_change_notice IN change notice opf the source comp
 * @param p_eff_date IN eff date of component
 * @param p_disable_date IN disable date of component
 * @param p_impl_date IN implementation date of component
 * @param p_rev_item_seq_id IN rev item sequence id of component
 * @param p_src_bill_seq_id IN source bill seq id
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Delete Related Substitute Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
Function Check_Component_Overlap(p_dest_bill_sequence_id IN NUMBER
                                 , p_dest_comp_seq_id IN NUMBER
                                 , p_comp_item_id IN NUMBER
                                 , p_op_seq_num IN NUMBER
                                 , p_change_notice IN VARCHAR2
                                 , p_eff_date IN DATE
                                 , p_disable_date IN DATE
                                 , p_impl_date IN DATE
                                 , p_rev_item_seq_id IN NUMBER
                                 , p_src_bill_seq_id IN NUMBER
                                 )
Return Boolean;


/*#
 * This Procedure is used to delete the unimplemented related components and their child entities.
 * @param p_src_comp_seq_id IN Comp Sequence Id of the source component.
 * @param x_Return_Status IN OUT Return Status of the API: S(uccess)/E(rror)/U(nexpected) error
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Delete Related Substitute Components
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
Procedure Delete_Related_Pending_Comps(p_src_comp_seq_id IN NUMBER
                               , x_Return_Status IN OUT NOCOPY VARCHAR2);

------------------------------------------------------------------------
--  API name    : Copy_Pending_Dest_Components                        --
--  Type        : Private                                             --
--  Pre-reqs    : None.                                               --
--  Procedure   : Propagates the specified ECO                        --
--  Parameters  :                                                     --
--       IN     : p_src_old_comp_seq_id  NUMBER Required              --
--                p_src_comp_seq_id      NUMBER Required              --
--                p_change_notice        vARCHAR2 Required            --
--                p_revised_item_sequence_id  NUMBER Required         --
--                p_effectivity_date     NUMBER Required              --
--       OUT    : x_return_status            VARCHAR2(1)              --
--  Version     : Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       : This API is invoked only when a common bill has     --
--                pending changes associated for its WIP supply type  --
--                attributes and the common component in the source   --
--                bill is being implemented.                          --
--                API Copy_Revised_Item is called and then            --
--                A copy of all the destination changes are then made --
--                to this revised item with the effectivity range of  --
--                the component being implemented.                    --
------------------------------------------------------------------------

PROCEDURE Copy_Pending_Dest_Components (
    p_src_old_comp_seq_id IN NUMBER
  , p_src_comp_seq_id     IN NUMBER
  , p_change_notice       IN VARCHAR2
  , p_organization_id     IN NUMBER
  , p_revised_item_sequence_id IN NUMBER
  , p_effectivity_date    IN DATE
  , x_return_status       OUT NOCOPY VARCHAR2
) ;


PROCEDURE check_comp_rev_in_local_org(p_src_bill_seq_id IN NUMBER,
                                     p_org_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2);

Function get_rev_id_for_local_org(p_rev_id IN NUMBER, p_org_id IN NUMBER)
Return NUMBER;

Function Check_comp_rev_for_Com_Boms(p_rev_id IN NUMBER, p_src_bill_seq_id IN NUMBER)
RETURN VARCHAR2;

END bompcmbm;

/
