--------------------------------------------------------
--  DDL for Package INV_VALIDATE_TROHDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_VALIDATE_TROHDR" AUTHID CURRENT_USER AS
/* $Header: INVLTRHS.pls 120.1 2005/06/17 14:23:37 appldev  $ */

SUBTYPE org IS mtl_parameters%ROWTYPE;
SUBTYPE transaction IS mtl_transaction_types%ROWTYPE;



-- Header level validation functions

T CONSTANT NUMBER := 1;
F CONSTANT NUMBER := 0;

FUNCTION Date_Required(p_date_required IN DATE)RETURN NUMBER;

FUNCTION Header(p_header_id IN NUMBER)RETURN NUMBER;

FUNCTION Header_Status(p_header_status IN NUMBER)RETURN NUMBER;

FUNCTION Request(p_request_id IN NUMBER)RETURN NUMBER;

/*** Organization is given for the org-id used for request number validation***/
FUNCTION Request_Number(p_request_number IN VARCHAR2,
			p_org IN ORG)RETURN NUMBER;

FUNCTION Status_Date(p_status_date IN DATE)RETURN NUMBER;


--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT nocopy VARCHAR2
,   p_trohdr_rec                    IN  INV_Move_Order_PUB.Trohdr_Rec_Type
,   p_old_trohdr_rec                IN  INV_Move_Order_PUB.Trohdr_Rec_Type :=
                                        INV_Move_Order_PUB.G_MISS_TROHDR_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT nocopy VARCHAR2
,   p_trohdr_rec                    IN OUT nocopy INV_Move_Order_PUB.Trohdr_Rec_Type
,   p_trohdr_val_rec                IN  INV_Move_Order_PUB.Trohdr_Val_Rec_Type
,   p_old_trohdr_rec                IN  INV_Move_Order_PUB.Trohdr_Rec_Type :=
                                        INV_Move_Order_PUB.G_MISS_TROHDR_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT nocopy VARCHAR2
,   p_trohdr_rec                    IN  INV_Move_Order_PUB.Trohdr_Rec_Type
);


g_org org;
g_transaction transaction;

END INV_Validate_Trohdr;

 

/
