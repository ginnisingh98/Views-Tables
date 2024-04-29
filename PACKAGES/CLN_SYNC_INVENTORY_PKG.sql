--------------------------------------------------------
--  DDL for Package CLN_SYNC_INVENTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_SYNC_INVENTORY_PKG" AUTHID CURRENT_USER AS
/* $Header: CLNSINVS.pls 115.3 2003/09/05 10:05:57 rkrishan noship $ */

--  Package
--      CLN_SYNC_INVENTORY_PKG
--
--  Purpose
--      Specs of package CLN_SYNC_INVENTORY_PKG.
--
--  History
--      April-17-2003  Rahul Krishan         Created



   -- Name
   --   RAISE_REPORT_GEN_EVENT
   -- Purpose
   --   The main purpose ofthis API is to capture the parameters reqd. for the generation of the
   --    inventory report as inputted by the user using concurrent program.
   -- Arguments
   --
   -- Notes
   --   No specific notes.

 PROCEDURE RAISE_REPORT_GEN_EVENT(
      x_errbuf                          OUT NOCOPY VARCHAR2,
      x_retcode                         OUT NOCOPY NUMBER,
      p_inv_user                        IN NUMBER,
      p_inv_org                         IN NUMBER,
      p_sub_inv                         IN VARCHAR2,
      p_lot_number                      IN VARCHAR2,
      p_item_category                   IN NUMBER,
      p_item_number_from                IN VARCHAR2,
      p_item_number_to                  IN VARCHAR2,
      p_item_revision_from              IN VARCHAR2,
      p_item_revision_to                IN VARCHAR2,
      p_diposition_available            IN VARCHAR2,
      p_diposition_blocked              IN VARCHAR2,
      p_diposition_allocated            IN VARCHAR2  );


    -- Name
    --   GET_XML_TAG_VALUES
    -- Purpose
    --   The main purpose ofthis API is to call the inventory API - INVPQTTS.pls and
    --   based on the user input through concurrent program and also using the profile
    --   option calculate quantity on hand, avaliable to use , quantity blocked and allocated.
    --
    -- Arguments
    --
    -- Notes
    --   No specific notes.

  PROCEDURE GET_XML_TAG_VALUES(
       x_return_status                   OUT NOCOPY VARCHAR2,
       x_msg_data                        OUT NOCOPY VARCHAR2,
       p_inv_org                         IN NUMBER,
       p_diposition_available            IN VARCHAR2,
       p_diposition_blocked              IN VARCHAR2,
       p_diposition_allocated            IN VARCHAR2,
       p_sub_inv                         IN VARCHAR2,
       p_lot_number                      IN VARCHAR2,
       p_item_number                     IN NUMBER,
       p_item_revision                   IN VARCHAR2,
       p_lot_ctrl_number                 IN NUMBER,
       p_item_revision_ctrl_number       IN NUMBER,
       p_tp_type                         IN VARCHAR2,
       p_tp_id                           IN NUMBER,
       p_tp_site_id                      IN VARCHAR2,
       p_xmlg_transaction_type           IN VARCHAR2, --
       p_xmlg_transaction_subtype        IN VARCHAR2, --
       p_xmlg_document_id                IN VARCHAR2, --
       p_xml_event_key                   IN VARCHAR2, --
       p_xmlg_internal_control_number    IN NUMBER,   --
       x_customer_item_number            OUT NOCOPY VARCHAR2,
       x_quantity_on_hand                OUT NOCOPY NUMBER,
       x_quantity_blocked                OUT NOCOPY NUMBER,
       x_quantity_allocated              OUT NOCOPY NUMBER );

END CLN_SYNC_INVENTORY_PKG;

 

/
