--------------------------------------------------------
--  DDL for Package ENG_NIR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_NIR_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: ENGNIRS.pls 120.8 2007/07/16 12:11:12 sdarbha ship $ */

G_ENG_NEW_ITEM_APPROVED   CONSTANT NUMBER        := 13;
G_ENG_NEW_ITEM_SFA        CONSTANT NUMBER        := 1;
G_ENG_NEW_ITEM_REJECTED   CONSTANT NUMBER        := 14;
G_ENG_NEW_ITEM_CANCELLED  CONSTANT NUMBER        := 5;

--TYPE G_ENG_TABLE_NUMBER is table of number;

PROCEDURE set_nir_item_approval_status (
	p_change_id      IN  NUMBER,
	p_approval_status IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count OUT NOCOPY NUMBER,
	x_msg_data OUT NOCOPY VARCHAR2);

PROCEDURE Cancel_NIR(
                    p_change_id IN NUMBER,
                    p_org_id IN NUMBER,
                    p_change_notice IN VARCHAR2,
                    p_auto_commit IN VARCHAR2,
                   -- p_item_action IN VARCHAR2 DEFAULT NULL,
                    p_wf_user_id IN NUMBER,
                    p_fnd_user_id IN NUMBER,
                    p_cancel_comments IN VARCHAR2,
                    p_check_security IN BOOLEAN DEFAULT TRUE,
                    x_nir_cancel_status OUT NOCOPY VARCHAR2
                    );

PROCEDURE Cancel_NIR_FOR_ITEM(
                    p_item_id IN NUMBER,
                    p_org_id IN NUMBER,
--		    p_item_number IN VARCHAR2,
                    p_auto_commit IN VARCHAR2,
--		    p_mode        IN VARCHAR2,
                    p_wf_user_id IN NUMBER,
                    p_fnd_user_id IN NUMBER,
                    p_cancel_comments IN VARCHAR2,
                    p_check_security IN BOOLEAN DEFAULT TRUE,
                    x_nir_cancel_status OUT NOCOPY VARCHAR2
                    );

PROCEDURE Delete_Child_Associations(
                    p_parent_icc_id IN NUMBER,
                    p_item_catalog_group_ids IN VARCHAR2,
                    p_route_people_id IN NUMBER DEFAULT NULL,
                    p_attribute_group_id IN NUMBER DEFAULT NULL,
                    p_commit IN VARCHAR2
                    );

PROCEDURE Create_Child_Associations(
                    p_source_item_catalog_group_id IN VARCHAR2,
                    p_parent_item_catalog_group_id IN VARCHAR2,
                    p_child_item_catalog_group_ids IN VARCHAR2,
                    --   following parameters will be used while calling only when the AG is associated to ICC directly
                    p_route_people_id IN NUMBER DEFAULT NULL,
                    p_attribute_group_id IN NUMBER DEFAULT NULL,
                    p_assoc_creation_date IN DATE DEFAULT NULL,
                    p_assoc_created_by IN NUMBER DEFAULT NULL,
                    p_assoc_last_update_date IN DATE DEFAULT NULL,
                    p_assoc_last_update_login IN NUMBER DEFAULT NULL,
                    p_assoc_last_updated_by IN NUMBER DEFAULT NULL,
                    p_commit IN VARCHAR2
                    );

PROCEDURE Update_Child_Associations(
                    p_parent_item_catalog_group_id IN VARCHAR2,
                    p_child_item_catalog_group_ids IN VARCHAR2,
                    p_route_people_id IN NUMBER DEFAULT NULL,
                    p_attribute_group_id IN NUMBER DEFAULT NULL,
                    p_route_association_id IN NUMBER,
                    p_commit IN VARCHAR2
                    );

FUNCTION Tokenize(
                    p_string IN VARCHAR2,               -- input string
                    p_start_position IN NUMBER,         -- token number
                    p_seperator IN VARCHAR2 DEFAULT ',' -- separator character
                    ) RETURN VARCHAR2;

PROCEDURE Cancel_NIR_Line_Item(
                    p_change_id NUMBER,
                    p_item_id NUMBER,
                    p_org_id NUMBER,
                --    p_mode VARCHAR2,    --   (DELETE/CHANGE_ICC)
                    p_wf_user_id IN NUMBER,
                    p_fnd_user_id IN NUMBER,
                    p_cancel_comments IN VARCHAR2,
                    p_commit IN VARCHAR2 :=FND_API.G_FALSE,
                    x_return_status OUT NOCOPY VARCHAR2
                    );

PROCEDURE Update_Item_Approval_Status (
        p_change_id          IN NUMBER,
	p_change_line_id     IN NUMBER,
	p_approval_status    IN NUMBER,
	x_return_status      OUT NOCOPY VARCHAR2
     );

FUNCTION checkNIRValidForApproval( p_change_id IN NUMBER)
return boolean;

PROCEDURE Update_Line_Items_App_St(
     p_change_id         IN NUMBER,
     p_item_approval_status IN NUMBER,
     x_sfa_line_items_exists   OUT  NOCOPY  VARCHAR2
     );

END ENG_NIR_UTIL_PKG;

/
