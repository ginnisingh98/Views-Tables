--------------------------------------------------------
--  DDL for Package CLN_SYNC_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_SYNC_ITEM_PKG" AUTHID CURRENT_USER AS
/* $Header: CLNSYNIS.pls 120.0 2005/05/24 16:22:50 appldev noship $ */

--  Package
--      CLN_SYNC_ITEM_PKG
--
--  Purpose
--      Specs of package CLN_SYNC_ITEM_PKG.
--
--  History
--      July-21-2003        Rahul Krishan         Created


   -- Name
   --    SET_SAVEPOINT_SYNC_RN
   -- Purpose
   --    This procedure sets the savepoint for deletion event.
   --    Incase we find the item status as obselete while processing, we rollback to this point
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE SET_SAVEPOINT_SYNC_RN;


   -- Name
   --    CATEGRY_RESOL_RN
   -- Purpose
   --    This procedure takes an input of concatenated string of category name and
   --    category set name delimited by '|'.
   --    The input would be of the form 'CATNAME=xxxxxx|CATSETNAME=xxxxxxxxx'
   --    The output parameters individually carry the category name and category set name
   --    This procedure is called from the inbound XGM
   -- Arguments
   --
   -- Notes
   --    No specific notes.
   PROCEDURE catgry_resol_RN(
                    p_concatgset            	IN              VARCHAR2,
                    x_insert                	IN  OUT NOCOPY  VARCHAR2,
                    x_catgry                	OUT NOCOPY      VARCHAR2,
                    x_catsetname            	OUT NOCOPY      VARCHAR2);


   -- Name
   --    RAISE_UPDATE_EVENT
   -- Purpose
   --    This is the public procedure which raises an event to update collaboration passing these parameters so
   --    obtained.This procedure requires only p_internal_control_number.
   --    This procedure is called from the root of XGM map
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE RAISE_UPDATE_EVENT(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_internal_control_number      IN NUMBER,
         p_sender_header_id             IN NUMBER,
         p_receiver_header_id           IN NUMBER,
         x_supplier_name                OUT NOCOPY VARCHAR2,
         x_master_organization_id       OUT NOCOPY NUMBER,
         x_set_process_id               OUT NOCOPY NUMBER,
         x_cost_group_id                OUT NOCOPY NUMBER);


   -- Name
   --    RAISE_ADD_MSG_EVENT
   -- Purpose
   --    This is the public procedure which is used to raise an event that add messages into collaboration history passing
   --    these parameters so obtained.This procedure is called
   --    for each Item
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE RAISE_ADD_MSG_EVENT(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_sync_indicator               IN  VARCHAR2,
         p_supplier_name                IN  VARCHAR2,
         p_buyer_part_number            IN  VARCHAR2,
         p_supplier_part_number         IN  VARCHAR2,
         p_item_number                  IN  VARCHAR2,
         p_item_desc                    IN  VARCHAR2,
         p_item_revision                IN  VARCHAR2,
         p_organization_id              IN  NUMBER,
         p_new_revision_flag            IN  OUT NOCOPY VARCHAR2,
         p_new_deletion_flag            IN  OUT NOCOPY VARCHAR2,
         p_internal_control_number      IN  NUMBER,
         p_hazardous_class              IN  VARCHAR2,
         x_hazardous_id                 OUT NOCOPY NUMBER,
         x_notification_code            OUT NOCOPY VARCHAR2,
         x_inventory_item_id            OUT NOCOPY NUMBER );


   -- Name
   --    INSERT_DATA
   -- Purpose
   --    This is the public procedure which checks the status and also the SYNC indicator
   --    Based on this, global variable INSERT_DATA is set to 'TRUE' or 'FALSE'
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE INSERT_DATA(
         p_return_status                IN VARCHAR2,
         p_sync_indicator               IN VARCHAR2,
         x_insert_data                  OUT NOCOPY VARCHAR2 );



  -- Name
  --   ERROR_HANDLER
  -- Purpose
  --
  -- Arguments
  --
  -- Notes
  --   No specific notes.

  PROCEDURE ERROR_HANDLER(
         x_return_status             IN OUT NOCOPY VARCHAR2,
         x_msg_data                  IN OUT NOCOPY VARCHAR2,
         p_org_ref                   IN VARCHAR2,
         p_internal_control_number   IN NUMBER,
         x_notification_code         OUT NOCOPY VARCHAR2,
         x_notification_status       OUT NOCOPY VARCHAR2,
         x_return_status_tp          OUT NOCOPY VARCHAR2,
         x_return_desc_tp            OUT NOCOPY VARCHAR2 );


  -- Name
  --    XGM_CHECK_STATUS
  -- Purpose
  --    This procedure returns 'True' incase the status inputted is 'S' and returns 'False'
  --    incase the status inputted is other then 'S'
  -- Arguments
  --
  -- Notes
  --    No specific notes.

  PROCEDURE XGM_CHECK_STATUS (
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       OUT NOCOPY VARCHAR2 );


  -- Name
  --    ITEM_IMPORT_STATUS_HANDLER
  -- Purpose
  --    This API checks for the status and accordingly updates the collaboration. Also, on the basis
  --    of few parameters, notifications are sent out to Buyer for his necessary actions.
  -- Arguments
  --
  -- Notes
  --    No specific notes.

  PROCEDURE ITEM_IMPORT_STATUS_HANDLER (
         p_itemtype                  IN VARCHAR2,
         p_itemkey                   IN VARCHAR2,
         p_actid                     IN NUMBER,
         p_funcmode                  IN VARCHAR2,
         x_resultout                 OUT NOCOPY VARCHAR2 );



  -- Name
  --    SETUP_CST_INTERFACE_TABLE
  -- Purpose
  --    This API checks for the status and accordingly updates the costing interface table
  --    with the inventory_item_id for the items which got imported and also it deletes the
  --    the records for the items which falied to get imported
  --
  -- Arguments
  --
  -- Notes
  --    No specific notes.

  PROCEDURE SETUP_CST_INTERFACE_TABLE (
         p_itemtype                     IN VARCHAR2,
         p_itemkey                      IN VARCHAR2,
         p_actid                        IN NUMBER,
         p_funcmode                     IN VARCHAR2,
         x_resultout                    OUT NOCOPY VARCHAR2 );



  -- Name
  --    UPDATE_COLLB_STATUS
  -- Purpose
  --    This API updates the collaboration history based on the status after the running of costing
  --    interface concurrent program
  --
  -- Arguments
  --
  -- Notes
  --    No specific notes.

  PROCEDURE UPDATE_COLLB_STATUS (
         p_itemtype                     IN VARCHAR2,
         p_itemkey                      IN VARCHAR2,
         p_actid                        IN NUMBER,
         p_funcmode                     IN VARCHAR2,
         x_resultout                    OUT NOCOPY VARCHAR2 );


  -- Name
  --    MFG_PARTNUM_STATUS_CHECK
  -- Purpose
  --    This API checks for the status of the concurrent program for updating
  --    the manufacturing part number and incase of an error
  --    updates the collaboration history.
  --
  -- Arguments
  --
  -- Notes
  --    No specific notes.

  PROCEDURE MFG_PARTNUM_STATUS_CHECK (
         p_itemtype                     IN VARCHAR2,
         p_itemkey                      IN VARCHAR2,
         p_actid                        IN NUMBER,
         p_funcmode                     IN VARCHAR2,
         x_resultout                    OUT NOCOPY VARCHAR2 );


  -- Name
  --    UPDATE_COLLB_STATUS_RN
  -- Purpose
  --    This API updates the status of the collaboration based on the document status
  --    for Rosettanet supported Framework
  --
  -- Arguments
  --
  -- Notes
  --    No specific notes.

  PROCEDURE UPDATE_COLLB_STATUS_RN (
         p_itemtype                     IN VARCHAR2,
         p_itemkey                      IN VARCHAR2,
         p_actid                        IN NUMBER,
         p_funcmode                     IN VARCHAR2,
         x_resultout                    OUT NOCOPY VARCHAR2 );


   -- Name
   --    ROLLBACK_CHANGES_RN
   -- Purpose
   --    This is the public procedure which is used to raise an event that add messages into collaboration history passing
   --    these parameters so obtained.This procedure is called when the item status in the
   --    inbound document is obselete
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE ROLLBACK_CHANGES_RN(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_supplier_name                IN  VARCHAR2,
         p_buyer_part_number            IN  VARCHAR2,
         p_supplier_part_number         IN  VARCHAR2,
         p_item_number                  IN  VARCHAR2,
         p_item_revision                IN  VARCHAR2,
         p_new_revision_flag            IN  OUT NOCOPY VARCHAR2,
         p_new_deletion_flag            IN  OUT NOCOPY VARCHAR2,
         p_internal_control_number      IN  NUMBER,
         x_notification_code            OUT NOCOPY VARCHAR2 );


END CLN_SYNC_ITEM_PKG;


 

/
