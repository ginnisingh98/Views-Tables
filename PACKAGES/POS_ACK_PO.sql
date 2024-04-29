--------------------------------------------------------
--  DDL for Package POS_ACK_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ACK_PO" AUTHID CURRENT_USER AS
/* $Header: POSISPAS.pls 120.2.12010000.2 2008/08/02 14:55:44 sthoppan ship $ */
/*Bug 6772960
  Modified the signature which takes l_last_update_date as IN parameter
  and returns x_error as OUT parameter. l_last_update_date is used to
  check the concurrency i.e., to check whether multiple supplier users
  are acting on the same PO simutaneously. If the supplier try to modify
  the PO which has already been modified by other user x_error returns false.
*/
PROCEDURE ACKNOWLEDGE_PO (
   l_po_header_id     IN VARCHAR2,
   l_po_release_id    IN VARCHAR2 default null,
   l_po_buyer_id      IN VARCHAR2,
   l_po_accept_reject IN VARCHAR2,
   l_po_acc_type_code IN VARCHAR2,
   l_po_ack_comments  IN VARCHAR2 ,
   l_user_id          IN VARCHAR2,
   l_last_update_date IN DATE DEFAULT fnd_api.G_NULL_DATE,
   x_error            OUT  NOCOPY VARCHAR2);

PROCEDURE Acknowledge_promise_date (                                -- RDP new procedure to default the promise date with need by date
        p_line_location_id	IN	NUMBER,
  	p_po_header_id		IN	NUMBER,
  	p_po_release_id		IN	NUMBER,
  	p_revision_num		IN	NUMBER,
  	p_user_id		IN	NUMBER);

PROCEDURE CREATE_HEADER_PROCESS(
    pos_po_header_id        IN  VARCHAR2,
    pos_po_release_id       IN  VARCHAR2,
    pos_user_id             IN  NUMBER,
    pos_item_type           OUT  NOCOPY VARCHAR2,
    pos_item_key            OUT  NOCOPY VARCHAR2
    );

PROCEDURE START_HEADER_PROCESS(
          l_item_type        IN  VARCHAR2,
          l_item_key         IN  VARCHAR2
        );

PROCEDURE ADD_SHIPMENT(
          l_item_type               IN  VARCHAR2,
          l_item_key                IN  VARCHAR2,
          l_line_location_id        IN  VARCHAR2,
          l_new_promise_date        IN  VARCHAR2,
          l_old_promise_date        IN  VARCHAR2,
          l_new_need_by_date        IN  VARCHAR2,
          l_old_need_by_date        IN  VARCHAR2,
	  l_reason		    IN  VARCHAR2
        );
/*
PROCEDURE POS_ACK_HEADER_PROCESS(
    pos_po_header_id        IN  VARCHAR2,
    pos_po_release_id       IN  VARCHAR2,
    pos_user_id             IN  NUMBER,
    pos_item_type           OUT  NOCOPY VARCHAR2,
    pos_item_key            OUT  NOCOPY VARCHAR2
    );
*/
END POS_ACK_PO;

/
