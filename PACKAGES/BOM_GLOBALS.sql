--------------------------------------------------------
--  DDL for Package BOM_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: BOMSGLBS.pls 120.22.12010000.2 2008/07/31 01:38:33 liawei ship $ */
/*#
 * This API contains methods to populate the System Information Record with global data.
 * This will store global data like User Id,Login Id,Program Application Id,Program Id etc
 * to the System Information Record.These data are used for checking the access privileges of the
 * user to the Business Object processed.This also stores differene flags like ECO_Impl,ECO_Cancl etc
 * to set the status of the business object and its components.
 * @rep:scope private
 * @rep:product BOM
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:displayname Global API
 */
/**************************************************************************
--
--  FILENAME
--
--      BOMSGLBS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Globals
--
--  NOTES
--
--  HISTORY
--
-- 16-JUL-1999  Rahul Chitko  Initial Creation
--
-- 07-MAY-2001  Refai Farook    EAM related changes
--
-- 08-Apr-2003  snelloli        Added Functions Get_Alternate Get_Structure_Type
****************************************************************************/
  G_OPR_CREATE        CONSTANT    VARCHAR2(30) := 'CREATE';
  G_OPR_UPDATE        CONSTANT    VARCHAR2(30) := 'UPDATE';
  G_OPR_DELETE        CONSTANT    VARCHAR2(30) := 'DELETE';
  G_OPR_LOCK          CONSTANT    VARCHAR2(30) := 'LOCK';
  G_OPR_NONE          CONSTANT    VARCHAR2(30) := NULL;
  G_OPR_CANCEL        CONSTANT    VARCHAR2(30) := 'CANCEL';
  G_RECORD_FOUND      CONSTANT    VARCHAR2(1)  := 'F';
  G_RECORD_NOT_FOUND  CONSTANT    VARCHAR2(1)  := 'N';
  G_MODEL             CONSTANT    NUMBER       := 1;
  G_OPTION_CLASS      CONSTANT    NUMBER       := 2;
  G_PLANNING          CONSTANT    NUMBER       := 3;
  G_STANDARD          CONSTANT    NUMBER       := 4;
  G_PRODUCT_FAMILY    CONSTANT    NUMBER       := 5;
  G_ECO_BO      CONSTANT  VARCHAR2(3)  := 'ECO';
  G_BOM_BO      CONSTANT  VARCHAR2(3)  := 'BOM';
  G_MASS_CHANGE       CONSTANT    VARCHAR2(10)  := 'MASSCHANGE';
  G_BOM_OBJ_TYPE      CONSTANT    VARCHAR2(30)  := null; -- Added by hgelli
  G_COMPS_LIMIT       CONSTANT    NUMBER       := 9999999;
  G_PKG_ST_TYPE_NAME  CONSTANT    VARCHAR2(30)  := 'Packaging Hierarchy';
  G_SKIP_BOMTBICX     VARCHAR2(1) := 'N' ;
  --bug:4162717 Alternate Bom Designator string for primary structure,
  --dependency on oracle.apps.bom.common.util.BomConstants.PRIMARY_UI constant in java
  G_PRIMARY_UI        CONSTANT    VARCHAR2(6)   := '*NULL*';
  G_BATCH_ID          NUMBER        :=NULL;     --4306013
  G_SHOW_IMPL_COMPS_ONLY VARCHAR2(1) := 'N';

  --Flag to decide whether trigger BOMTBICX needs to fire or not.
-- Table type used to hold organization codes
   TYPE OrgID_tbl_type IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;

-- This change is for the Performance testing logging
   G_TIME_LOGGED      NUM_VARRAY;
   G_METHOD_LOGGED    VARCHAR2_VARRAY;
   G_TOP                NUMBER := -1;
   G_FLOW_ID            NUMBER ;
   G_STACK_SIZE       CONSTANT  NUMBER := 500;
   G_PROFILE_ENABLED  CONSTANT VARCHAR2(2) := '1';

  TYPE SYSTEM_INFORMATION_REC_TYPE IS RECORD
  (  Entity               VARCHAR2(30)    := NULL
   , org_id               NUMBER          := NULL
   , Eco_Name             VARCHAR2(10)    := NULL
   , User_Id              NUMBER          := NULL
   , Login_Id             NUMBER          := NULL
   , Prog_AppId           NUMBER          := NULL
   , Prog_Id              NUMBER          := NULL
   , Request_Id           NUMBER          := NULL
   , ECO_Impl             BOOLEAN         := NULL
   , ECO_Cancl            BOOLEAN         := NULL
   , WKFL_Process         BOOLEAN         := NULL
   , ECO_Access           BOOLEAN         := NULL
   , RITEM_Impl           BOOLEAN         := NULL
   , RITEM_Cancl          BOOLEAN         := NULL
   , RCOMP_Cancl          BOOLEAN         := NULL
   , STD_Item_Access      NUMBER          := NULL
   , MDL_Item_Access      NUMBER          := NULL
   , PLN_Item_Access      NUMBER          := NULL
   , OC_Item_Access       NUMBER          := NULL
   , Bill_Sequence_Id     NUMBER          := NULL
   , Current_Revision     VARCHAR2(3)     := NULL
   , BO_Identifier        VARCHAR2(3)     := 'ECO'
   , Unit_Effectivity     BOOLEAN         := FALSE
   , Unit_Controlled_Item BOOLEAN         := FALSE
   , Unit_Controlled_Component BOOLEAN    := FALSE
   , Require_Item_Rev NUMBER    := NULL  -- based on profile
   , debug_flag   VARCHAR2(1) := 'N'
   , routing_sequence_id  NUMBER          := NULL
   , lot_number           VARCHAR2(30)    := NULL
   , from_wip_entity_id   NUMBER          := NULL
   , to_wip_entity_id     NUMBER          := NULL
   , from_cum_qty         NUMBER          := NULL
   , eco_for_production   NUMBER          := 2
   , new_routing_revision VARCHAR2(30)    := NULL
   , assembly_item_id     NUMBER          := NULL
   , validate_for_plm     VARCHAR2(1)     := 'N'
  );
	/*#
	 * This method initializes the System Information Record.It initializes
	 * User_Id, Login_Id, Prog_Appid, Prog_Id in System_Information record.It also
	 * pulls in values of profiles ENG: Standard Item Access, ENG: Model Item Access
	 * and ENG: Planning Item Access into STD_Item_Access, MDL_Item_Access and PLN_Item_Access respectively.
	 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status
  	 * @rep:scope public
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Initialize System Info Record
	 */
  PROCEDURE Init_System_Info_Rec
  (   x_mesg_token_tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  ,   x_return_status     IN OUT NOCOPY VARCHAR2
  );
	/*#
	 * This function returns the information stored in the Systen
	 * Information Record.System Information Record holds User_Id, Login_Id, Prog_Appid, Prog_Id
	 * The System Information Record also conatins profile information like profiles ENG: Standard Item Access, ENG: Model Item Access
	 * and ENG: Planning Item Access into STD_Item_Access, MDL_Item_Access and PLN_Item_Access
	 * @return System Information Record
	 * @rep:scope public
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get System Information
	 */
  FUNCTION Get_System_Information
    RETURN Bom_Globals.System_Information_Rec_Type;

	/*#
	 * This method sets the System Information in the System Information
	 * Record.This sets User_Id, Login_Id, Prog_Appid, Prog_Id in System_Information record
	 * and  profile values like  ENG: Standard Item Access, ENG: Model Item Access
	 * and ENG: Planning Item Access into STD_Item_Access, MDL_Item_Access and PLN_Item_Access
	 * @param p_system_information_rec IN input System Information Record
	 * @paraminfo {@rep:innertype Bom_Globals.System_Information_Rec_Type}
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set System Information
	 */
  PROCEDURE Set_System_Information
          ( p_system_information_rec    IN
                        Bom_Globals.System_Information_Rec_Type);
	/*#
	 * This method sets the Bill Sequence Id.Bill Sequence Id can be used for
	 * identifying a unique BOM Header Record.This procedure sets the Bill Sequence
	 * Id for the BOM Header imported.It sets the value in the System Information Record
	 * @param p_bill_sequence_id IN Bill Sequence Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Bill Sequence Id
	 */
  PROCEDURE Set_Bill_Sequence_id
          ( p_bill_sequence_id  IN  NUMBER);
	/*#
	 * This function returns the Bill Sequence Id for the
	 * Bom Header Record.Bill Sequence Id can uniquely identify
	 * a Bom Header Record.Function returns the value in the System
	 * Information Record.Bill Sequence Id links the Bom Structure Header with the
	 * Components.
	 * @return Bill Sequence Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Bill Sequence Id
	 */

  FUNCTION Get_Bill_Sequence_id RETURN NUMBER;

 	/*#
	 * This method sets the Entity Name.The Entity Name is
	 * stored in the System Information Record.The Entity Name is
	 * a user friendly name to the Business Object processed
	 * @param  p_entity IN Entity Name
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Entity Name
	 */
  PROCEDURE Set_Entity
          ( p_entity    IN  VARCHAR2);
	/*#
	 * This function will return the Entity Name.The Entity Name is
	 * obtained from the System Information Record.
	 * @return Entity Name
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Entity Name
	 */

  FUNCTION Get_Entity RETURN VARCHAR2;
	/*#
	 * This method sets the Organization Id.It sets the value of
	 * Oganization Id attribute in the System Information Record.
	 * @param p_org_id IN Organization Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Organization Id
	 */
  PROCEDURE Set_Org_id
          ( p_org_id    IN  NUMBER);

	/*#
	 * This function retrieves the Organization Id.It gets the value of
	 * Oganization Id attribute from  the System Information Record.
	 * @return Organization Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Organization Id
	 */
  FUNCTION Get_Org_id RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(Get_Org_id, WNDS);
	/*#
	 * This method sets the Engineering ChangeOrder Name.It sets the value of
	 * ECO name attribute in the System Information Record.
	 * @param p_eco_name IN ECO Name
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set ECO Name
	 */
  PROCEDURE Set_Eco_Name
          ( p_eco_name  IN VARCHAR2);

	/*#
	 * This function retrieves the ECO Name.It gets the value of
	 * ECO Name attribute from  the System Information Record.
	 * @return ECO Name
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get ECO Name
	 */
  FUNCTION Get_Eco_Name RETURN VARCHAR2;
	/*#
	 * This method sets the User Id value.It sets the value of
	 * User Id attribute  in the System Information Record.
	 * @param p_user_id IN User Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set User Id
	 */

  PROCEDURE Set_User_Id
          ( p_user_id   IN  NUMBER);

	/*#
	 * This function retrieves the User Id.It gets the value of
	 * User Id attribute from  the System Information Record.
	 * @return User Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get User Id
	 */
  FUNCTION Get_User_ID RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(Get_User_Id, WNDS);

	/*#
	 * This method sets the Login Id value.It sets the value of
	 * Login Id attribute  in the System Information Record.
	 * @param p_login_id  IN Login Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Login Id
	 */
  PROCEDURE Set_Login_Id
          ( p_login_id  IN NUMBER );

	/*#
	 * This function retrieves the Login Id.It gets the value of
	 * Login Id attribute from  the System Information Record.
	 * @return Login Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Login Id
	 */
  FUNCTION Get_Login_Id RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(Get_Login_Id, WNDS);

	/*#
	 * This method sets the Program Application Id value.It sets the value of
	 * Program Application Id attribute  in the System Information Record.
	 * @param  p_prog_Appid IN Program Applcation Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Program Application Id
	 */
  PROCEDURE Set_Prog_AppId
          ( p_prog_Appid        IN  NUMBER );

	/*#
	 * This function retrieves the Program Application Id.It gets the value of
	 * Program Application Id attribute from  the System Information Record.
	 * @return Program Application Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Program Application Id
	 */
  FUNCTION Get_Prog_AppId RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(Get_Prog_AppId, WNDS);

	/*#
	 * This method  sets the Program Id value.It sets the value of
	 * Program Id attribute  in the System Information Record.
	 * @param  p_prog_id IN Program Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Program Id
	 */
  PROCEDURE Set_Prog_Id
          ( p_prog_id   IN  NUMBER );

	/*#
	 * This function retrieves the Program Id.It gets the value of
	 * Program Id attribute from  the System Information Record.
	 * @return Program Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Program Id
	 */
  FUNCTION Get_Prog_Id RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(Get_Prog_Id, WNDS);

	/*#
	 * This method  sets the Request Id value.It sets the value of
	 * Request Id attribute  in the System Information Record.
	 * @param p_request_id IN Request Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Request Id
	 */
  PROCEDURE Set_Request_Id
          ( p_request_id IN  NUMBER );

	/*#
	 * This function retrieves the Request  Id.It gets the value of
	 * Request Id attribute from  the System Information Record.
	 * @return Request Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Request Id
	 */
  FUNCTION Get_Request_id RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(Get_Request_Id, WNDS);

	/*#
	 * This method sets the ECO_Impl value.It sets the value of
	 * ECO_Impl attribute as true or false based on the implemented status of ECO
	 * in the System Information Record.
	 * @param p_eco_impl IN Request Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set ECO Implemented
	 */
  PROCEDURE Set_Eco_Impl
          ( p_eco_impl  IN  BOOLEAN );

	/*#
	 * This function returns true or false based on the implemented
	 * status of ECO_Impl.Returns true if ECO is implemeted and fasle if
	 * ECO is not Implemeted.
	 * @return Boolean
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Is ECO Implemented
	 */
  FUNCTION Is_Eco_Impl RETURN BOOLEAN;

	/*#
	 * This method sets the ECO_Cancel value.It sets true if ECO
	 * is cancelled and false if ECO is not cancelled
	 * in the System Information Record.
	 * @param p_eco_cancl IN Boolean flag for indicating whether ECO is cancelled or not
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set ECO Cancel
	 */
  PROCEDURE Set_Eco_Cancl
          ( p_eco_cancl IN  BOOLEAN );

	/*#
	 * This function returns true or false based on the
	 * status of ECO_Cancl.Returns true if ECO is cancelled and fasle if
	 * ECO is not Cancelled.
	 * @return Boolean
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Is ECO Cancelled
	 */
  FUNCTION Is_Eco_Cancl RETURN BOOLEAN;

	/*#
	 * This method  sets the Work Flow process attribute.It sets true or
	 * false value for the Work Flow Process attribute in the System Information
	 * Record
	 * @param p_wkfl_process IN Boolean flag for indicating whether a Work Flow Process or not
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Work Flow Process
	 */
  PROCEDURE Set_Wkfl_Process
          ( p_wkfl_process      IN  BOOLEAN );

	/*#
	 * This function returns true or false based on the
	 * value of Work Flow process attribute in the System Information Record.
	 * Returns true if a Work Flow Process exists in ECO and false otherwise
	 * @return Boolean
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Is Work Flow Process
	 */
  FUNCTION Is_Wkfl_Process RETURN BOOLEAN;

	/*#
	 * This method  will set the value of the system information record
	 * attribute Eco_Access. True if the user has access to the ECO
	 * and false otherwise.
	 * @param p_eco_access IN Boolean flag for indicating the ECO acess values
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set ECO Acess
	 */
  PROCEDURE Set_Eco_Access
          ( p_eco_access        IN  BOOLEAN );

	/*#
	 * This function returns true or false based on the
	 * value of ECO acess attribute in the System Information Record.
	 * Returns true if ECO acees is true and false otherwise
	 * @return Boolean
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Is ECO Acess
	 */
  FUNCTION Is_Eco_Access RETURN BOOLEAN;

	/*#
	 * This method will set the value of RItem_Impl attribute.It sets
	 * value based on whether the Revised Item is implemented or not in
	 * the system information record
	 * @param p_ritem_impl IN Revision Item Implemented Flag
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set RItem Implemented
	 */
  PROCEDURE Set_RItem_Impl
          ( p_ritem_impl        IN  BOOLEAN );

	/*#
	 * This function returns true or false based on the
	 * value of Ritem_Impl attribute in the System Information Record.
	 * Returns true if Revision Item  is implemented and false otherwise
	 * @return Boolean
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Is Rev Item Implemented
	 */
  FUNCTION Is_RItem_Impl RETURN BOOLEAN;

	/*#
	 * This method  will set the value of RItem_Cancel attribute.It sets
	 * value based on whether the Revised Item is cancelled or not, in
	 * the system information record
	 * @param p_ritem_cancl IN Revision Item Cancelled Flag
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Revised Item Cancel
	 */
  PROCEDURE Set_RItem_Cancl
          ( p_ritem_cancl        IN  BOOLEAN );

	/*#
	 * This function returns true or false based on the
	 * value of Ritem_Cancl attribute in the System Information Record.
	 * Returns true if Revision Item  is cancelled and false otherwise
	 * @return Boolean
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Is Rev Item Cancelled
	 */
  FUNCTION Is_RItem_Cancl RETURN BOOLEAN;

	/*#
	 * This method will set the value of RComp_Cancel attribute.It sets
	 * value based on whether the Revision Component is cancelled or not, in
	 * the system information record
	 * @param p_rcomp_cancl IN Revision Component Cancelled Flag
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Revised Component Cancel
	 */
  PROCEDURE Set_RComp_Cancl
          ( p_rcomp_cancl        IN  BOOLEAN );

	/*#
	 * This function returns true or false based on the
	 * value of RComp_Cancl attribute in the System Information Record.
	 * Returns true if Revision Component  is cancelled and false otherwise
	 * @return Boolean
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Is Rev Component Cancelled
	 */
  FUNCTION Is_RComp_Cancl RETURN BOOLEAN;

	/*#
	 * This method  will set the value of Std_Item_Acess attribute.It sets
	 * value based on whether the Standard Item is accessible not, in
	 * the system information record
	 * @param p_std_item_access IN Standard Item Access Flag
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Standard Item Access
	 */
  PROCEDURE Set_Std_Item_Access
          ( p_std_item_access   IN  NUMBER );

	/*#
	 * This function returns the value of Std_Item_Access
	 * attribute.It retrieves the value from the System Information Record
	 * @return Standard Item Access Value
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Std Item Access
	 */
  FUNCTION Get_Std_Item_Access RETURN NUMBER;

	/*#
	 * This method will set the value of Mdl_Item_Access attribute.It sets
	 * value based on whether the Model Item is accessible not, in
	 * the system information record
	 * @param p_mdl_item_access IN Model Item Access Flag
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Model Item Access
	 */
  PROCEDURE Set_Mdl_Item_Access
          ( p_mdl_item_access   IN  NUMBER );

	/*#
	 * This function returns the value of Mdl_Item_Access
	 * attribute.It retrieves the value from the System Information Record
	 * @return Model Item Access Value
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Model Item Access
	 */
  FUNCTION Get_Mdl_Item_Access RETURN NUMBER;

	/*#
	 * This method  will set the value of Pln_Item_Access attribute.It sets
	 * value based on whether the Planning Item is accessible not, in
	 * the system information record
	 * @param p_Pln_item_access IN Planning Item Access Flag
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Planning Item Access
	 */
  PROCEDURE Set_Pln_Item_Access
          ( p_Pln_item_access   IN  NUMBER );

	/*#
	 * This function returns the value of Pln_Item_Access
	 * attribute.It retrieves the value from the System Information Record
	 * @return Planning Item Access Value
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Planning Item Access
	 */
  FUNCTION Get_Pln_Item_Access RETURN NUMBER;

	/*#
	 * This method  will set the value of OC_Item_Access attribute.It sets
	 * value based on whether the Option Class Item is accessible not, in
	 * the system information record
	 * @param p_oc_item_access IN Option Class Item Access Flag
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Option Calss Item Access
	 */
  PROCEDURE Set_OC_Item_Access
          ( p_oc_item_access   IN  NUMBER );

	/*#
	 * This function returns the value of OC_Item_Access
	 * attribute.It retrieves the value from the System Information Record
	 * whether the Option Class Item is accessible or not
	 * @return Option  Calss Item Access Value
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Option Class Item Access
	 */
  FUNCTION Get_OC_Item_Access RETURN NUMBER;

	/*#
	 * This method will set the value of Current Revision attribute.It sets
	 * value of Current Revision attribute  in
	 * the system information record
	 * @param p_current_revision IN Crrent Revision
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Current Revision
	 */
  PROCEDURE Set_Current_Revision
          ( p_current_revision  IN  VARCHAR2 );

	/*#
	 * This function returns the value of Crrent Revision
	 * attribute.It retrieves the value from the System Information Record
	 * @return Current Revision
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Current Revision
	 */
  FUNCTION Get_Current_Revision RETURN VARCHAR2;

	/*#
	 * This Procedure will set the value of Business Object Identifier.It sets
	 * value of the Identifier in the system information record and this value is checked
	 * at the time of import
	 * @param p_bo_identifier IN Business Object Identifier
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set BO Identifier
	 */
  PROCEDURE Set_BO_Identifier
          ( p_bo_identifier     IN  VARCHAR2 );

	/*#
	 * This function returns the value of Business Object Identifier
	 * It retrieves the value from the System Information Record
	 * @return Business Object Identifier
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get BO Identifier
	 */
  FUNCTION Get_BO_Identifier RETURN VARCHAR2;

	/*#
	 * This method will set the value of Unit Controlled Item Attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_Unit_Controlled_Item IN Unit Controlled Item
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Unit Controlled Item
	 */
  PROCEDURE Set_Unit_Controlled_Item
          ( p_Unit_Controlled_Item IN BOOLEAN);

	/*#
	 * This method will set the value of Unit Controlled Item Attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_inventory_item_id IN Inventory Item Id
	 * @param p_organization_id IN Organization Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Unit Controlled Item
	 */
  PROCEDURE Set_Unit_Controlled_Item
    ( p_inventory_item_id  IN NUMBER
    , p_organization_id    IN NUMBER);

	/*#
	 * This function returns the value of the Unit Controlled Item attribute
	 * It retrieves the value from the System Information Record
	 * @return Unit Controlled Item
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Unit Controlled Item
	 */
  FUNCTION Get_Unit_Controlled_Item RETURN BOOLEAN;

	/*#
	 * This method will set the value of Unit Controlled Component Attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_Unit_Controlled_Component IN Unit Controlled Component
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Unit Controlled Component
	 */
  PROCEDURE Set_Unit_Controlled_Component
          ( p_Unit_Controlled_Component IN BOOLEAN);
	/*#
	 * This method will set the value of Unit Controlled Component Attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_inventory_item_id IN Inventory Item Id
	 * @param p_organization_id IN Organization Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Unit Controlled Component
	 */
        PROCEDURE Set_Unit_Controlled_Component
          ( p_inventory_item_id  IN NUMBER
          , p_organization_id    IN NUMBER);

	/*#
	 * This function returns the value of the Unit Controlled Component attribute
	 * It retrieves the value from the System Information Record
	 * @return Boolean
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Unit Controlled Component
	 */
  FUNCTION Get_Unit_Controlled_Component RETURN BOOLEAN;

	/*#
	 * This method  will set the value of Unit Effectivity Attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_Unit_Effectivity IN Unit Effectivity
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Unit Effectivity
	 */
  PROCEDURE Set_Unit_Effectivity
          ( p_Unit_Effectivity IN  BOOLEAN );

	/*#
	 * This function returns the value of the Unit Effectivity attribute
	 * It retrieves the value from the System Information Record
	 * @return Boolean
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Unit Effecivity
	 */
  FUNCTION Get_Unit_Effectivity RETURN BOOLEAN;

	/*#
	 * This method will set the value of Require Item Rev attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_Require_Rev IN Require Item Revision
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Required Item Revision
	 */
  PROCEDURE Set_Require_Item_Rev
    ( p_Require_Rev      IN NUMBER );

	/*#
	 * This function returns the value of the Require Item Revision  attribute
	 * It retrieves the value from the System Information Record
	 * @return Item Revision Required or not
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Is Item Rev Required
	 */
  FUNCTION Is_Item_Rev_Required RETURN NUMBER;

	/*#
	 * This method will set the value of Routing Sequence Id attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_routing_sequence_id IN Routing Sequence Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Routing Sequence Id
	 */
        PROCEDURE Set_Routing_Sequence_Id
          ( p_routing_sequence_id IN  NUMBER );

	/*#
	 * This function returns the value of the Routing Sequence Id attribute
	 * It retrieves the value from the System Information Record
	 * @return Routing Sequence Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Routing Sequence Id
	 */
        FUNCTION Get_Routing_Sequence_Id RETURN NUMBER;

	/*#
	 * This method  will set the value of Lot Number attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_lot_number IN Lot Number
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Lot Number
	 */
        PROCEDURE Set_Lot_Number
          ( p_lot_number IN  VARCHAR2 );

	/*#
	 * This function returns the value of the Lot Number  attribute
	 * It retrieves the value from the System Information Record
	 * @return Lot Number
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Lot Number
	 */
        FUNCTION Get_Lot_Number RETURN VARCHAR2;

	/*#
	 * This method  will set the value of From WIP Entity Id attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_from_wip_entity_id IN From WIP Entity Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set From WIP Entity Id
	 */
        PROCEDURE Set_From_Wip_Entity_Id
          ( p_from_wip_entity_id IN  NUMBER);

	/*#
	 * This function returns the value of the From WIP Entity Id attribute
	 * It retrieves the value from the System Information Record
	 * @return From WIP Entity Id value
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get From WIP Entity Id
	 */
        FUNCTION Get_From_Wip_Entity_Id RETURN NUMBER;

	/*#
	 * This method will set the value of To  WIP Entity Id attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_to_wip_entity_id IN To WIP Entity Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set To WIP Entity Id
	 */
        PROCEDURE Set_To_Wip_Entity_Id
          ( p_to_wip_entity_id IN  NUMBER);

	/*#
	 * This function returns the value of the To  WIP Entity Id attribute
	 * It retrieves the value from the System Information Record
	 * @return To WIP Entity Id Value
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get To WIP Entity Id
	 */
        FUNCTION Get_To_Wip_Entity_Id RETURN NUMBER;

	/*#
	 * This method  will set the value of From_Cum_Qty attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_from_cum_qty IN  From Cum Qty
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set From Cum Qty
	 */
        PROCEDURE Set_From_Cum_Qty
          ( p_from_cum_qty IN  NUMBER);

	/*#
	 * This function returns the value of the From_Cum_Qty  attribute
	 * It retrieves the value from the System Information Record
	 * @return From Cum Quantity
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get From Cum Qty
	 */
        FUNCTION Get_From_Cum_Qty RETURN NUMBER;

	/*#
	 * This method will set the value of Eco For Production  attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_eco_for_production IN Eco For Production
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set  Eco For Production
	 */
        PROCEDURE Set_Eco_For_Production
          ( p_eco_for_production IN  NUMBER);

	/*#
	 * This function returns the value of the Eco For Production  attribute
	 * It retrieves the value from the System Information Record
	 * @return ECO For Production
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Eco For Production
	 */
        FUNCTION Get_Eco_For_Production RETURN NUMBER;

	/*#
	 * This method will set the value of New Routing Revision  attribute.It sets
	 * value of the attribute in the system information record
	 * @param p_new_routing_revision IN New Routing Revision
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set New Routing Revision
	 */
        PROCEDURE Set_New_Routing_Revision
          ( p_new_routing_revision IN  VARCHAR2 );

	/*#
	 * This function returns the value of the  New Routing Revision attribute
	 * It gets the value in the System Information record.
	 * @return New Routing Revision
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get New Routing Revision
	 */
        FUNCTION Get_New_Routing_Revision RETURN VARCHAR2;


	/*#
	 * This method will set the value of Request For Approval attribute.
	 * @param p_change_notice IN Change Notice
	 * @param p_organization_id IN Organization Id
	 * @param x_err_text IN OUT NOCOPY output Error Text
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Request For Approval
	 */
  PROCEDURE Set_Request_For_Approval
  (   p_change_notice                 IN  VARCHAR2
  ,   p_organization_id               IN  NUMBER
  ,   x_err_text                      IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE Check_Approved_For_Process
  (   p_change_notice                 IN  VARCHAR2
  ,   p_organization_id               IN  NUMBER
  ,   x_processed                     IN OUT NOCOPY BOOLEAN
  ,   x_err_text                      IN OUT NOCOPY VARCHAR2
  );

	/*#
	 * This function returns the value of the Process Name attribute
	 * @return Process Name
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Process Name
	 */
  FUNCTION Get_Process_Name RETURN VARCHAR2;

	/*#
	 * This method will Initialize the porcess name attribute .
	 * @param p_change_order_type_id In Change Order Type Id
	 * @param  p_priority_code IN Priority Code
	 * @param p_organization_id IN organization Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Init Process Name
	 */
  PROCEDURE Init_Process_Name
  (   p_change_order_type_id          IN  NUMBER
  ,   p_priority_code                 IN  VARCHAR2
  ,   p_organization_id               IN  NUMBER
  );

	 /*#
	 * This method will check the validity of the transaction type.The
	 * transaction type should be create,updaet or delete.If teh transaction type
	 * is not of these types then Standard Error is raised.
	 * @param p_transaction_type IN Transaction type
	 * @param p_entity IN Entity Name
	 * @param p_entity_id IN Entity Id
	 * @param x_valid IN OUT NOCOPY Validity flag
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Transaction Type Validity
	 */
  PROCEDURE Transaction_Type_Validity
  (   p_transaction_type          IN  VARCHAR2
  ,   p_entity                    IN  VARCHAR2
  ,   p_entity_id                 IN  VARCHAR2
  ,   x_valid                     IN OUT NOCOPY BOOLEAN
  ,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  );
	/*#
	 * This method sets the debug flag value and enables Debug.Debug Messages will be
	 * added based on the value of this debug flag
	 * @param p_debug_flag IN Debug Flag
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Debug
	 */
  PROCEDURE Set_Debug
  (  p_debug_flag     IN  VARCHAR2
   );

	/*#
	 * This function will retrieve the debug flag value.
	 * @return Debug Flag Value
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Debug
	 */
  FUNCTION Get_Debug RETURN VARCHAR2;

	/*#
	 * This method will set the value of Assembly Item Id attribute.
	 * @param p_assembly_item_id IN Assembly Item Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Assembly Item Id
	 */
        PROCEDURE Set_Assembly_Item_id(p_assembly_item_id IN NUMBER);

	/*#
	 * This function returns the value of the Assembly Item Id attribute
	 * @return Assembly Item Id
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Assembly Item Id
	 */
        FUNCTION  Get_Assembly_Item_id RETURN NUMBER;


	/*#
	 * This Procedure will set the value of Caller Type attribute.It sets
	 * value of the attribute in the Control record
	 * @param  p_Caller_Type IN Caller Type
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Caller Type
	 */
        PROCEDURE Set_Caller_Type
          ( p_Caller_Type IN VARCHAR2 );

	/*#
	 * This function returns the value of the Caller Type attribute
	 * It retrieves the value from the Control Record
	 * @return Caller Type
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Caller Type
	 */
        FUNCTION Get_Caller_Type RETURN VARCHAR2;


	/*#
	 * This function returns the value of the Structure Type attribute.
	 * It will return the display name fot teh structure type.
	 * @param p_bill_sequence_id IN Bill Sequence Id
	 * @param p_organization_id IN Organization Id
	 * @return Structure Type display name
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Structure Type
	 */
  FUNCTION Get_Structure_Type
  (  p_bill_sequence_id   IN NUMBER
   , p_organization_id  IN NUMBER
  )
  RETURN VARCHAR2;

	/*#
	 * This function returns the value of the Alternate BOM Designator attribute
	 * @param p_bill_sequence_id IN Bill Sequence Id
	 * @return Alternate BOM Designator
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Alternate BOM Designator
	 */
  FUNCTION Get_Alternate
  (p_bill_sequence_id NUMBER)
  RETURN VARCHAR2;

	/*#
	 * This function returns the value of the  Item Type Meaning
	 * @param p_item_type IN Item Type
	 * @return Item Type Meaning
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Item Type Meaning
	 */
  FUNCTION get_item_type
  ( p_item_type IN VARCHAR2)
  RETURN VARCHAR2;

	/*#
	 * This function returns the Error or Warning Messages for
	 * that Business Object.It Retrieves the message specified by
	 * the messaeg name
	 * @param p_application_id IN Application Id
	 * @param p_message_name IN Message Name
	 * @return Message
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Retrieve Messsage
	 */
  FUNCTION RETRIEVE_MESSAGE(
    p_application_id  IN VARCHAR2
  , p_message_name  IN VARCHAR2
  ) RETURN VARCHAR2;
        PRAGMA RESTRICT_REFERENCES(RETRIEVE_MESSAGE,WNDS);

	 /*Bug 5737158 Function to get concatenated segments. */
  FUNCTION Get_Concat_Segs(
     p_item_id IN NUMBER,
     p_org_id  IN NUMBER
   ) RETURN VARCHAR2;

	/*#
	 * This function returns the name of the
	 * Refence Designator.The Reference Designator is
	 * Identified by the component Sequence id.
	 * @param p_component_sequence_id  IN Component Sequence Id
	 * @return Reference Designator Name
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Reference Designator
	 */
  FUNCTION get_reference_designators
  ( p_component_sequence_id  IN NUMBER
  ) return VARCHAR2;

   PRAGMA RESTRICT_REFERENCES(get_reference_designators,WNDS);

	/*#
	 * This function returns the Item Name.It identifies the
	 * Item Name with Assembly Item Id and Organization Id
	 * @param p_item_id IN Assembly Item Id
	 * @param p_org_id IN Organization Id
	 * @return Assembly Item Name
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Item Name
	 */
  FUNCTION Get_Item_Name(p_item_id IN NUMBER,p_org_id IN NUMBER) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(Get_Item_Name, WNDS);
	/*#
	 * This method returns the organization list.The Organization List
	 * @param p_org_hier IN Organization Hierarchy
	 * @param p_organization_id IN Organization Id
	 * @param x_org_list IN OUT NOCOPY Organization List
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Get Org List
	 */
  PROCEDURE Get_Orgs
  ( p_org_hier IN VARCHAR2
   , p_organization_id IN NUMBER
   , x_org_list IN OUT NOCOPY BOM_GLOBALS.OrgID_tbl_type
  );

	/*#
	 * This method sets the validate_for_plm flag
	 * It sets the value in the System Information Record
	 * @param p_validate_for_plm_flag IN Validate For Plm Flag
	 * @rep:scope private
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Set Validate For Plm
	 */
  PROCEDURE Set_Validate_For_Plm
  (  p_validate_for_plm_flag     IN  VARCHAR2
   );

	/*#
	 * This function returns the valus of valiidate_for_plm_flag.
	 * It gets the value from the System Information Record.
	 * @return Validate For Plm Flag Value
	 * @rep:scope private
	 * @rep:lifecycle active
	 * @rep:compatibility S
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:displayname Get Plm Flag
	 */


  FUNCTION Get_Validate_For_Plm RETURN VARCHAR2;

  FUNCTION Is_GTIN_Structure_Type_Id (p_Structure_Type_Id IN NUMBER) RETURN BOOLEAN;

  	/*#
  	 * This function will find if PLM is enabled or not
  	 * @return Y or N
  	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
  	 * @rep:compatibility S
  	 * @rep:lifecycle active
  	 * @rep:displayname Get Debug
  	 */
    FUNCTION Is_PLM_Enabled RETURN VARCHAR2;

  	/*#
  	 * This function will find if PIM is enabled or not
  	 * @return Y or N
  	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
  	 * @rep:compatibility S
  	 * @rep:lifecycle active
  	 * @rep:displayname Get Debug
  	 */
    FUNCTION Is_PIM_Enabled RETURN VARCHAR2;

  	/*#
  	 * This function will find if PDS is enabled or not
  	 * @return Y or N
  	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
  	 * @rep:compatibility S
  	 * @rep:lifecycle active
  	 * @rep:displayname Get Debug
  	 */
    FUNCTION Is_PDS_Enabled RETURN VARCHAR2;

  	/*#
  	 * This function will find if PIM or PDS is enabled or not
  	 * @return Y or N
  	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
  	 * @rep:compatibility S
  	 * @rep:lifecycle active
  	 * @rep:displayname Get Debug
  	 */
    FUNCTION Is_PIM_PDS_Enabled RETURN VARCHAR2;


--
  -- With the enhancement to BOM functionality for supporting various PLM
  -- requirements, BOM/Structures can have revisions and the components
  -- can maintain effectivity with respect to these revisions.
  -- We therefore now stamp the component with from_minor_revision_id
  -- and component_minor_revision_id
  -- These values are crucial for the explosion of BOM to work correctly for
  -- a particular minor revision.
  --

  --  This procedure does the following
  -- 1. Based on Component's Effectivity, get the component Revision
  -- and component minor revision.
  -- 2. Based on current db date get the object revision id and from_minor_revision id
  -- 2. Get the max minor revsion id/code for the current bill
  --    object_revision_id is null or object is 'EGO_ITEM' and
  --    object_revision_id = item_revsion_id
  --
/* Procedure to default the New Structure Revision Attributes */
  PROCEDURE GET_DEF_REV_ATTRS
  (     p_bill_sequence_id IN NUMBER
    ,   p_comp_item_id IN NUMBER
    ,   p_effectivity_date IN DATE
    ,   x_object_revision_id OUT NOCOPY VARCHAR2
    ,   x_minor_revision_id OUT NOCOPY VARCHAR2
    ,   x_comp_revision_id OUT NOCOPY VARCHAR2
    ,   x_comp_minor_revision_id OUT NOCOPY VARCHAR2
  );

  FUNCTION Get_Change_Policy_Val (p_bill_seq_id  IN NUMBER,
                                  p_item_revision_code IN VARCHAR2) RETURN VARCHAR2;

  /*Function to return the change policy on a structure type/item/org*/
  FUNCTION Get_Change_Policy_Val (p_item_id  IN NUMBER,
                                  p_org_id IN NUMBER,
				  p_structure_type_id in NUMBER) RETURN VARCHAR2;

  /* bug:4162717 Alternate Bom Designator string for primary structure */
  FUNCTION GET_PRIMARY_UI
           RETURN VARCHAR2;

  FUNCTION Check_ItemAttrGroup_Security(viewPrivilegeName   IN VARCHAR2,
                                        editPrivilegeName   IN VARCHAR2,
  				        partyId             IN VARCHAR2,
  				        inventoryItemId     IN NUMBER,
  				        organizationId      IN NUMBER) RETURN VARCHAR2;

  /*#
   * This function will return Y if the revised component is editable.
	 * @param p_comp_seq_id IN Component Sequence Id of the component
   * @return Y or N
   * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
   * @rep:compatibility S
   * @rep:scope private
   * @rep:lifecycle active
 	 * @rep:displayname Is Revised Component Editable
   */
  FUNCTION Is_Rev_Comp_Editable(p_comp_seq_id IN NUMBER)
           RETURN VARCHAR2;


  /*Function to return the change policy on a structure type/item/org*/

  FUNCTION Get_Change_Policy_Val (p_item_id  IN NUMBER,
                                  p_org_id IN NUMBER,
                                  p_rev_id  IN NUMBER,
                                  p_rev_date IN DATE,
                                  p_structure_type_id in NUMBER) RETURN VARCHAR2;

  FUNCTION Check_Change_Policy_Range (p_item_id IN NUMBER,
                                  p_org_id IN NUMBER,
                                  p_start_revision IN VARCHAR2,
                                  p_end_revision IN VARCHAR2,
                                  p_start_rev_id IN NUMBER,
                                  p_end_rev_id IN NUMBER,
                                  p_effective_date IN DATE,
                                  p_disable_date IN DATE,
                                  p_current_chg_pol IN VARCHAR2,
                                  p_structure_type_id IN NUMBER,
                                  p_use_eco IN VARCHAR2) RETURN VARCHAR2;


  FUNCTION Check_Change_Policy_Range (p_item_id IN NUMBER,
                                      p_org_id IN NUMBER,
                                      p_component_sequence_id IN NUMBER,
                                      p_current_chg_pol IN VARCHAR2,
                                      p_structure_type_id IN NUMBER,
                                      p_context_rev_id IN NUMBER,
                                      p_use_eco IN VARCHAR2) RETURN VARCHAR2;


  /* Function to split the component and copy the user attributes, RFD and Subcomps */
  FUNCTION split_component(p_comp_seq_id IN NUMBER,
	                         p_rev_id IN NUMBER,
                           p_disable_rev_id IN NUMBER,
                           p_disable_date IN DATE)
	RETURN NUMBER;

  /* Function to get the effective component with respect to the passed parent item's revision */
  FUNCTION get_effetive_component(p_comp_seq_id IN NUMBER,
	                                p_rev_id IN NUMBER,
                                  p_explosion_date DATE)
	RETURN NUMBER;

  FUNCTION get_effetive_component(p_comp_seq_id IN NUMBER,
	                                p_rev_id IN NUMBER)
	RETURN NUMBER;

  /* Function to get the catalog category name for the given item_catalog_group_id */
  FUNCTION get_item_catalog_category(p_item_catalog_group_id IN NUMBER)
    RETURN VARCHAR2;

  FUNCTION Get_Bill_Header_ECN(p_bill_seq_id IN NUMBER)
    RETURN VARCHAR2;

  PROCEDURE  uda_attribute_defaulting(p_bill_sequence_id IN VARCHAR2
                             ,p_component_sequence_id  IN VARCHAR2 DEFAULT NULL
                             ,p_object_name            IN VARCHAR2
                             ,p_structure_type_id      IN VARCHAR2
                             ,x_return_status       OUT NOCOPY VARCHAR2
                             ,x_msg_data            OUT NOCOPY VARCHAR2);

  PROCEDURE Init_Logging;

  PROCEDURE Start_Logging(flow_name VARCHAR2,flow_id NUMBER);

  PROCEDURE Log_Start_Time(operation_name VARCHAR2);

  PROCEDURE Log_Exec_Time;

  PROCEDURE Stop_Logging;

  PROCEDURE set_show_Impl_comps_only(p_option IN VARCHAR2);

  /* added for bug 6823980
     Promote procedure copy_Comp_User_Attrs from internal to public procedure
  */
  Procedure copy_Comp_User_Attrs(p_src_comp_seq_id IN NUMBER,
                                p_dest_comp_seq_id IN NUMBER,
                                x_Return_Status OUT NOCOPY VARCHAR2);

  FUNCTION get_show_Impl_comps_only RETURN VARCHAR2;

  FUNCTION check_chg_pol_for_delete(p_bill_seq_id IN NUMBER,
                                    p_comp_seq_id IN NUMBER,
                                    p_start_revision IN VARCHAR2,
                                    p_end_revision IN VARCHAR2,
                                    p_start_rev_id IN NUMBER,
                                    p_end_rev_id IN NUMBER,
                                    p_effective_date IN DATE,
                                    p_disable_date IN DATE,
                                    p_current_chg_pol IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_comp_names(p_comp_seq_ids IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_lookup_meaning(p_lookup_type IN VARCHAR2,
                              p_lookup_code IN VARCHAR2) RETURN VARCHAR2;
/*#
 * This method sets the Profile MFG_ORGANIZATION_ID .It sets the value of
 * Oganization Id for this profile.
 * @param p_org_id IN Organization Id
 * @rep:scope private
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:displayname Set Profile Org id
 */
 PROCEDURE Set_Profile_Org_id( p_org_id    IN  NUMBER);

END BOM_Globals;

/
