--------------------------------------------------------
--  DDL for Package CLN_ACK_PO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_ACK_PO_PKG" AUTHID CURRENT_USER AS
/* $Header: CLNACKPS.pls 120.2 2006/03/27 00:35:09 kkram noship $ */
--  Package
--      CLN_ACK_PO_PKG
--
--  Purpose
--      Spec of package CLN_ACK_PO_PKG.
--
--  History
--      May-14-2002     Rahul Krishan         Created



  -- Name
  --   PROCESS_HEADER
  -- Purpose
  --    The main purpose of this procedure is to check whether the collaboration exists for
  --    for a particular reference id or not.
  --
  -- Arguments
  --
  -- Notes
  --   No specific notes.


 PROCEDURE PROCESS_HEADER(
        x_return_status             OUT NOCOPY VARCHAR2,
        x_msg_data                  OUT NOCOPY VARCHAR2,
        p_ref_id                    IN  VARCHAR2,
        p_sender_component          IN  VARCHAR2,
        p_po_number                 IN  VARCHAR2,
        p_release_number            IN  NUMBER,
        p_revision_number           IN  NUMBER,
        p_ackcode_header            IN  NUMBER,
        p_note                      IN  LONG,
        p_requestor                 IN  VARCHAR2,
        p_int_cont_num              IN  VARCHAR2,
        p_request_origin            IN  VARCHAR2,
        p_tp_header_id              IN  NUMBER,
        p_tp_id                     OUT NOCOPY VARCHAR2,
        p_tp_site_id                OUT NOCOPY VARCHAR2,
        x_cln_required              OUT NOCOPY VARCHAR2,
        x_collaboration_type        OUT NOCOPY VARCHAR2,
        x_coll_id                   OUT NOCOPY NUMBER,
        x_notification_code         OUT NOCOPY VARCHAR2,
        x_notification_status       OUT NOCOPY VARCHAR2,
        x_return_status_tp          OUT NOCOPY VARCHAR2,
        x_call_po_apis              OUT NOCOPY VARCHAR2 );





    -- Name
    --   PROCESS_HEADER_LINES
    -- Purpose
    --   The main purpose of this procedure is to provide a sequence of actions that
    --   need to be taken depending upon the ACKCODE value at the header level and also
    --   on the Collaboration Type.
    -- Arguments
    --
    -- Notes
    --   No specific notes.

  PROCEDURE PROCESS_HEADER_LINES(
         x_return_status             IN OUT NOCOPY VARCHAR2,
         x_msg_data                  IN OUT NOCOPY VARCHAR2,
         p_requestor                 IN VARCHAR2,
         p_po_number                 IN VARCHAR2,
         p_release_number            IN NUMBER,
         p_revision_number           IN NUMBER,
         p_line_number               IN NUMBER,
         p_previous_line_number      IN OUT NOCOPY NUMBER,
         p_shipment_number           IN NUMBER,
         p_new_quantity              IN NUMBER,
         p_po_quantity_uom           IN VARCHAR2,
         p_po_price_currency         IN VARCHAR2,
         p_po_price_uom              IN VARCHAR2,
         p_new_price                 IN NUMBER,
         p_ackcode_header            IN NUMBER,
         p_ackcode_line              IN NUMBER,
         p_coll_id                   IN NUMBER,
         p_new_promised_date         IN DATE,
         p_collaboration_type        IN VARCHAR2,
         p_org_ref                   IN VARCHAR2,
         p_cln_required              IN VARCHAR2,
         p_internal_control_number   IN VARCHAR2,
         p_supplier_part_number      IN VARCHAR2,
         p_so_num                    IN VARCHAR2,
         p_so_line_num               IN NUMBER,
         p_so_line_status            IN VARCHAR2,
         p_reason                    IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_tp_site_id                IN VARCHAR2,
         p_msg_dtl_screen            IN OUT NOCOPY VARCHAR2,
         p_msg_txt_lines             IN OUT NOCOPY VARCHAR2,
         p_if_collaboration_updated  IN OUT NOCOPY VARCHAR2,
         -- Additional parameters added for new Change_PO API to
         -- support split lines and cancellation at header and schedule level.
         p_supp_doc_ref              IN VARCHAR2 DEFAULT NULL,
         p_supp_line_ref             IN VARCHAR2 DEFAULT NULL,
         p_supplier_shipment_ref     IN VARCHAR2 DEFAULT NULL,
         p_parent_shipment_number    IN VARCHAR2 DEFAULT NULL);


   -- Name
   --   LOAD_CHANGES
   -- Purpose
   --   Call Process Supplier Request of Update_PO API to
   --   load all changes in to interface tables
   -- Arguments
   --   Internal Control Number
   -- Notes
   --   No Specific Notes

      PROCEDURE LOAD_CHANGES(
         p_call_po_apis                 IN  VARCHAR2,
         p_internal_ctrl_num            IN  VARCHAR2,
         p_requestor                    IN  VARCHAR2,
         p_request_origin               IN  VARCHAR2,
         p_tp_id                        IN  VARCHAR2,
         p_tp_site_id                   IN  VARCHAR2,
         x_return_status                IN OUT NOCOPY VARCHAR2,
         x_msg_data                     IN OUT NOCOPY VARCHAR2 );


  -- Name
  --   ACKPO_ERROR_HANDLER
  -- Purpose
  --
  -- Arguments
  --
  -- Notes
  --   No specific notes.

  PROCEDURE ACKPO_ERROR_HANDLER(
         x_return_status             IN OUT NOCOPY VARCHAR2,
         x_msg_data                  IN OUT NOCOPY VARCHAR2,
         p_po_number                 IN VARCHAR2,
         p_org_ref                   IN VARCHAR2,
         p_coll_id                   IN NUMBER,
         p_internal_control_number   IN VARCHAR2,
         x_notification_code         OUT NOCOPY VARCHAR2,
         x_notification_status       OUT NOCOPY VARCHAR2,
         x_return_status_tp          OUT NOCOPY VARCHAR2,
         p_cln_required              IN VARCHAR2 );

    -- Name
    --   PROCESS_HEADER_LINES_RN
    -- Purpose
    --   This procedure is used when message standard is Rosettanet.
    --   The main purpose of this procedure is to provide a sequence of actions that
    --   need to be taken to consume the Acknowledgement depending upon the ACKCODE
    --   value at the header level and on the Collaboration Type.
    -- Arguments
    --
    -- Notes
    --   No specific notes.


  PROCEDURE PROCESS_HEADER_LINES_RN(
         x_return_status             IN OUT NOCOPY VARCHAR2,
         x_msg_data                  IN OUT NOCOPY VARCHAR2,
         p_requestor                 IN VARCHAR2,
         p_po_number                 IN VARCHAR2,
         p_release_number            IN NUMBER,
         p_revision_number           IN NUMBER,
         p_line_number               IN NUMBER,
         p_previous_line_number      IN OUT NOCOPY NUMBER,
         p_shipment_number           IN NUMBER,
         p_new_quantity              IN NUMBER,
         p_po_quantity_uom           IN VARCHAR2,
         p_po_price_currency         IN VARCHAR2,
         p_po_price_uom              IN VARCHAR2,
         p_new_price                 IN NUMBER,
         p_ackcode_header            IN NUMBER,
         p_ackcode_line              IN NUMBER,
         p_coll_id                   IN NUMBER,
         p_new_promised_date         IN DATE,
         p_collaboration_type        IN VARCHAR2,
         p_org_ref                   IN VARCHAR2,
         p_cln_required              IN VARCHAR2,
         p_internal_control_number   IN VARCHAR2,
         p_supplier_part_number      IN VARCHAR2,
         p_so_num                    IN VARCHAR2,
         p_so_line_num               IN NUMBER,
         p_so_line_status            IN VARCHAR2,
         p_reason                    IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_tp_site_id                IN VARCHAR2,
         p_msg_dtl_screen            IN OUT NOCOPY VARCHAR2,
         p_msg_txt_lines             IN OUT NOCOPY VARCHAR2,
         p_if_collaboration_updated  IN OUT NOCOPY VARCHAR2,
         -- Additional parameters added for new Change_PO API to
         -- support split lines and cancellation at header and schedule level.
         p_supp_doc_ref              IN VARCHAR2 DEFAULT NULL,
         p_supp_line_ref             IN VARCHAR2 DEFAULT NULL,
         p_supplier_shipment_ref     IN VARCHAR2 DEFAULT NULL,
         p_parent_shipment_number    IN VARCHAR2 DEFAULT NULL);

 -- Name
  --   PROCESS_HEADER_RN
  -- Purpose
  --    This procedure is used when the message standard is Rosettanet.
  --    This procedure processes the header level
  -- Arguments
  --
  -- Notes
  --   No specific notes.
PROCEDURE PROCESS_HEADER_RN(
        x_return_status             OUT NOCOPY VARCHAR2,
        x_msg_data                  OUT NOCOPY VARCHAR2,
        p_sender_component          IN  VARCHAR2,
        p_po_number                 IN  VARCHAR2,
        p_release_number            IN  NUMBER,
        p_revision_number           IN  NUMBER,
        p_ackcode_header            IN  NUMBER,
        p_note                      IN  LONG,
        p_requestor                 IN  VARCHAR2,
        p_int_cont_num              IN  VARCHAR2,
        p_request_origin            IN  VARCHAR2,
        p_tp_header_id              IN  NUMBER,
        p_collaboration_type        IN  VARCHAR2,
        p_tp_id                     OUT NOCOPY VARCHAR2,
        p_tp_site_id                OUT NOCOPY VARCHAR2,
        x_cln_required              OUT NOCOPY VARCHAR2,
        x_notification_code         OUT NOCOPY VARCHAR2,
        x_notification_status       OUT NOCOPY VARCHAR2,
        x_return_status_tp          OUT NOCOPY VARCHAR2,
        x_call_po_apis              OUT NOCOPY VARCHAR2 );
  -- Name
  --   PROCESS_HEADER_RN
  -- Purpose
  --    This procedure is to get the accode bases on the Acknowledgement Reason Code and
  --    PO Status Code
  -- Arguments
  --
  -- Notes
  --   No specific notes.



PROCEDURE CLN_GET_PO_ACK_CODE_RN (
         p_po_ack_reason_code   IN VARCHAR2,
         p_po_status_code       IN VARCHAR2,
         x_po_ack_code          OUT NOCOPY VARCHAR2);

  -- Name
  --   UPDATE_COLL_FOR_HDR_ONLY_MSG
  -- Purpose
  --    Called to update collaboration for ACK_PO messages, which doent have POLINE
  -- Arguments
  --
  -- Notes
  --   No specific notes.
PROCEDURE UPDATE_COLL_FOR_HDR_ONLY_MSG(
         x_return_status             IN OUT NOCOPY VARCHAR2,
         x_msg_data                  IN OUT NOCOPY VARCHAR2,
         p_ackcode_header            IN NUMBER,
         p_ackcode_line              IN NUMBER,
         p_coll_id                   IN NUMBER,
         p_org_ref                   IN VARCHAR2,
         p_cln_required              IN VARCHAR2,
         p_internal_control_number   IN VARCHAR2,
         p_so_num                    IN VARCHAR2,
         p_message                   IN OUT NOCOPY VARCHAR2,
         p_if_collaboration_updated  IN OUT NOCOPY VARCHAR2);


END CLN_ACK_PO_PKG;


 

/
