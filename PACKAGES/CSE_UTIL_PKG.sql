--------------------------------------------------------
--  DDL for Package CSE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_UTIL_PKG" AUTHID CURRENT_USER AS
-- $Header: CSEUTILS.pls 120.6 2006/05/31 07:30:46 brmanesh ship $
x_cse_install VARCHAR2(1) := NULL;
PROCEDURE Check_item_Trackable(
     p_inventory_item_id IN NUMBER,
     p_nl_trackable_flag OUT NOCOPY VARCHAR2);

PROCEDURE check_lot_control(
     p_inventory_item_id IN NUMBER,
     p_organization_id IN NUMBER,
     p_lot_control OUT NOCOPY VARCHAR2);

PROCEDURE check_serial_control(
     p_inventory_item_id IN NUMBER,
     p_organization_id IN NUMBER,
     p_serial_control OUT NOCOPY VARCHAR2);

PROCEDURE check_depreciable_subinv(
     p_subinventory IN VARCHAR2,
     p_organization_id IN NUMBER,
     p_depreciable OUT NOCOPY VARCHAR2);

PROCEDURE get_asset_creation_code(
     p_inventory_item_id IN NUMBER,
     p_asset_creation_code OUT NOCOPY VARCHAR2);

PROCEDURE check_depreciable(
     p_inventory_item_id IN NUMBER,
     p_depreciable OUT NOCOPY VARCHAR2);

PROCEDURE get_combine_segments(
		p_short_name	    IN  VARCHAR2,
		p_flex_code	    IN  VARCHAR2,
		p_concat_segments   IN  VARCHAR2,
		x_combine_segments  OUT NOCOPY VARCHAR2,
		x_Return_Status     OUT NOCOPY  VARCHAR2,
                x_Error_Message     OUT NOCOPY  VARCHAR2);

PROCEDURE get_concat_segments(
        p_short_name            IN  VARCHAR2,
        p_flex_code             IN  VARCHAR2,
	p_combination_id	IN  NUMBER,
        x_concat_segments       OUT NOCOPY  VARCHAR2,
       	x_Return_Status         OUT NOCOPY  VARCHAR2,
        x_Error_Message         OUT NOCOPY  VARCHAR2);

PROCEDURE get_destination_instance(
          P_Dest_Instance_tbl  IN   csi_datastructures_pub.instance_header_tbl,
          X_Instance_Rec       OUT NOCOPY  csi_datastructures_pub.Instance_Rec,
          X_Return_Status      OUT NOCOPY  VARCHAR2,
          x_Error_Message      OUT NOCOPY  VARCHAR2);

PROCEDURE get_master_organization(p_organization_id          IN  NUMBER,
                                  p_master_organization_id   OUT NOCOPY NUMBER,
                                  x_return_status            OUT NOCOPY VARCHAR2,
                                  x_error_message            OUT NOCOPY VARCHAR2);

PROCEDURE get_hz_location (
         p_network_location_code IN   VARCHAR2,
         x_hz_location_id        OUT NOCOPY  NUMBER,
         x_Return_Status         OUT NOCOPY  VARCHAR2,
         x_Error_Message         OUT NOCOPY  VARCHAR2);

 PROCEDURE get_hz_location (
         p_party_site_id         IN   NUMBER,
         x_hz_location_id        OUT NOCOPY  NUMBER,
         x_Return_Status         OUT NOCOPY  VARCHAR2,
         x_Error_Message         OUT NOCOPY  VARCHAR2);

PROCEDURE get_fa_location (
        p_hz_location_id  IN  NUMBER,
        p_loc_type_code   IN  VARCHAR2,
        x_fa_location_id  OUT NOCOPY NUMBER,
        x_return_status   OUT NOCOPY VARCHAR2,
        x_error_message   OUT NOCOPY VARCHAR2);

PROCEDURE build_error_string (
        p_string            IN OUT NOCOPY VARCHAR2,
        p_attribute         IN     VARCHAR2,
        p_value             IN     VARCHAR2);

PROCEDURE get_string_value (
        p_string            IN      VARCHAR2,
        p_attribute         IN      VARCHAR2,
        x_value             OUT NOCOPY     VARCHAR2);

FUNCTION is_eib_installed RETURN VARCHAR2;

FUNCTION bypass_event_queue RETURN boolean;

PRAGMA RESTRICT_REFERENCES(is_eib_installed, WNDS);

FUNCTION get_neg_inv_code (p_org_id in NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(get_neg_inv_code, WNDS);

FUNCTION Get_Default_Status_Id(p_transaction_id IN NUMBER) RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES(get_default_status_id, WNDS);

FUNCTION Init_Instance_Query_Rec RETURN CSI_DATASTRUCTURES_PUB.Instance_Query_Rec;
FUNCTION Init_Instance_Create_Rec RETURN CSI_DATASTRUCTURES_PUB.Instance_Rec;

FUNCTION Init_Instance_Update_Rec RETURN CSI_DATASTRUCTURES_PUB.Instance_Rec;

FUNCTION Init_Txn_Rec RETURN CSI_DATASTRUCTURES_PUB.TRANSACTION_Rec;

FUNCTION Init_Txn_Error_Rec RETURN CSI_DATASTRUCTURES_PUB.TRANSACTION_Error_Rec;

FUNCTION Init_Party_Tbl RETURN CSI_DATASTRUCTURES_PUB.Party_Tbl;

FUNCTION Init_Account_Tbl RETURN CSI_DATASTRUCTURES_PUB.Party_Account_Tbl;

FUNCTION Init_ext_attrib_values_tbl RETURN CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;

FUNCTION Init_Pricing_Attribs_Tbl RETURN CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;

FUNCTION Init_Org_Assignments_Tbl RETURN CSI_DATASTRUCTURES_PUB.organization_units_tbl;

FUNCTION Init_Asset_Assignment_Tbl RETURN CSI_DATASTRUCTURES_PUB.instance_asset_tbl;

FUNCTION Get_Dflt_Project_Location_Id RETURN NUMBER;

FUNCTION Get_Location_Type_Code(P_Location_Meaning IN VARCHAR2) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(Get_Location_Type_Code, WNDS);

FUNCTION Get_Txn_Type_Id(P_Txn_Type IN VARCHAR2, P_App_Short_Name IN VARCHAR2) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(Get_Txn_Type_Id, WNDS);

FUNCTION Get_Txn_Type_Code(P_Txn_Id IN NUMBER) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(Get_Txn_Type_Code, WNDS);

FUNCTION Get_Txn_Status_Code(P_Txn_Status IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Txn_Action_Code(P_Txn_Action IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Fnd_Employee_Id(P_Last_Updated IN NUMBER) RETURN NUMBER;

FUNCTION Init_Instance_Asset_Query_Rec RETURN CSI_DATASTRUCTURES_PUB.instance_asset_Query_Rec;

FUNCTION Init_Instance_Asset_Rec RETURN CSI_DATASTRUCTURES_PUB.instance_asset_Rec;

FUNCTION Init_Party_Query_Rec RETURN CSI_DATASTRUCTURES_PUB.Party_Query_Rec;

FUNCTION IS_Conc_Prg_Running(P_Request_Id IN NUMBER,P_Executable IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE Write_Log(P_Message IN VARCHAR2);

FUNCTION get_inv_name (p_transaction_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE Check_if_top_assembly(p_instance_id IN NUMBER,
                       x_yes_top_assembly OUT NOCOPY BOOLEAN,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_error_message OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------------
---
---             Added for Redeployment functionality.
---             This procedure returns x_redeploy_flag as 'Y'
---             If there exists a OUT-OF-SERVICE' transaction
---             previous to the p_transaction_date (by default, it is SYSDATE
---
------------------------------------------------------------------------------

PROCEDURE get_redeploy_flag(
              p_inventory_item_id IN NUMBER
             ,p_serial_number     IN VARCHAR2
             ,p_transaction_date  IN DATE
             ,x_redeploy_flag     OUT NOCOPY VARCHAR2
             ,x_return_status     OUT NOCOPY VARCHAR2
             ,x_error_message     OUT NOCOPY VARCHAR2);


------------------------------------------------------------------------------

PROCEDURE get_inst_n_comp_dtls(
             p_instance_id	 IN NUMBER
            ,p_transaction_id    IN NUMBER
            ,p_transaction_date  IN DATE
            ,x_inst_dtls_tbl     OUT NOCOPY csi_datastructures_pub.instance_header_tbl
            ,x_return_status     OUT NOCOPY VARCHAR2
            ,x_error_message     OUT NOCOPY VARCHAR2) ;
-------------------------------------------------------------------------------------


  FUNCTION dump_error_stack RETURN VARCHAR2 ;

  PROCEDURE set_debug;

END CSE_UTIL_PKG;

 

/
