--------------------------------------------------------
--  DDL for Package CSP_MO_MTLTXNS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_MO_MTLTXNS_UTIL" AUTHID CURRENT_USER AS
/* $Header: cspgtmus.pls 115.11 2002/11/26 06:48:41 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_MO_MTLTXNS_UTIL
-- Purpose          : This package includes the procedures that handle material transactions associated with any move orders.
-- History
--  29-Dec-99, Vernon Lou.
--
-- NOTE             :
-- End of Comments

/*
PROCEDURE move_order_lines_txn (
-- This procedure takes a move order line ID as parameters. And then call the appropriate API for material
-- transactions.
       P_Api_Version_Number      IN      NUMBER,
       P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
       P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
       p_validation_level        IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_organization_id         IN      NUMBER,
       p_move_order_line_id      IN      NUMBER,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
    );
*/

PROCEDURE update_order_line_status(
       P_Api_Version_Number      IN      NUMBER,
       P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
       P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
       p_validation_level        IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_organization_id         IN      NUMBER,
       p_move_order_line_id      IN      NUMBER,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
 );


FUNCTION validate_mo_line_status (
        p_move_order_header_id IN  NUMBER,
        p_status_to_be_validated IN NUMBER)
        RETURN VARCHAR2;

PROCEDURE confirm_receipt (
       P_Api_Version_Number      IN      NUMBER,
       P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
       P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
       p_validation_level        IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_packlist_line_id        IN      NUMBER,
       p_organization_id         IN      NUMBER,
       p_transaction_temp_id     IN      NUMBER,
       p_quantity_received       IN      NUMBER,
       p_to_subinventory_code    IN      VARCHAR2      := NULL,
       p_to_locator_id           IN      NUMBER        := NULL,
       p_serial_number           IN      VARCHAR2      := NULL,
       p_lot_number              IN      VARCHAR2      := NULL,
       p_revision                IN      VARCHAR2      := NULL,
       p_receiving_option        IN      NUMBER        := 0, --0 = receiving normal, 1 = receipt short, 2 = over receipt (but do not close the packlist and move order, 3 = over receipt (close everything)
       px_transaction_header_id  IN OUT NOCOPY  NUMBER,
       p_process_flag            IN      VARCHAR2      := FND_API.G_FALSE,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
  );

Procedure Transact_Serial_Lots (
-- This procedure was created specifically for CSP confirm receipt transactions.
       p_new_transaction_temp_id IN      NUMBER,
       p_old_transaction_temp_id IN      NUMBER,
       p_lot_number              IN      VARCHAR2,
       p_serial_number           IN      VARCHAR2,
       p_qty_received            IN      NUMBER,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2 );


FUNCTION Convert_Temp_UOM (p_csp_mtltxn_rec IN OUT NOCOPY CSP_MATERIAL_TRANSACTIONS_PVT.CSP_Rec_Type,
                           p_quantity_convert IN NUMBER)
    RETURN VARCHAR2;

Function Clean_Up (p_transaction_temp_id IN NUMBER)
    Return VARCHAR2;

Function Get_CSP_Acccount_ID (p_organization_id NUMBER)
    Return NUMBER;

Procedure Under_Over_Receipt (
     p_transaction_temp_id     IN NUMBER,
     p_receiving_option        IN NUMBER,
     px_transaction_header_id  IN OUT NOCOPY NUMBER,
     p_discrepancy_qty         IN     NUMBER := 0,
     X_Return_Status           OUT NOCOPY    VARCHAR2,
     X_Msg_Count               OUT NOCOPY    NUMBER,
     X_Msg_Data                OUT NOCOPY    VARCHAR2);

Function Call_Online (p_transaction_header_id NUMBER)
    Return Boolean;


END CSP_MO_MTLTXNS_UTIL;

 

/
