--------------------------------------------------------
--  DDL for Package OE_LINE_PAYMENT_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_PAYMENT_SECURITY" AUTHID CURRENT_USER AS
/* $Header: OEXXLPMS.pls 120.0.12010000.1 2008/07/25 08:09:43 appldev ship $ */


-- Package Globals
g_check_all_cols_constraint VARCHAR2(1) := 'Y';
g_is_caller_defaulting      VARCHAR2(1) := 'N';
-- Entity global record that is used in APIs for validation templates
-- and the generated validation packages to access attribute values
-- on the entity record
g_record                    OE_AK_LINE_PAYMENTS_V%ROWTYPE;


FUNCTION ATTRIBUTE1
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE10
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE11
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE12
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE13
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE14
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE15
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE3
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE4
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE5
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE6
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE7
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE8
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE9
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CONTEXT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

-- End  of fix #1459428
FUNCTION CREATED_BY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION PAYMENT_LEVEL_CODE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION PAYMENT_TYPE_CODE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION PAYMENT_TRX
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION RECEIPT_METHOD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION PAYMENT_COLLECTION_EVENT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CHECK_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION COMMITMENT_APPLIED_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CREDIT_CARD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CREDIT_CARD_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CREDIT_CARD_HOLDER_NAME
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CREDIT_CARD_EXPIRATION_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CREDIT_CARD_APPROVAL
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CREDIT_CARD_APPROVAL_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION PAYMENT_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

PROCEDURE Entity
(   p_LINE_PAYMENT_rec            IN  OE_Order_PUB.LINE_PAYMENT_Rec_Type
, x_result OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Attributes
(   p_LINE_PAYMENT_rec            IN  OE_Order_PUB.LINE_PAYMENT_Rec_Type
,   p_old_LINE_PAYMENT_rec        IN  OE_Order_PUB.LINE_PAYMENT_Rec_Type := OE_Order_PUB.G_MISS_LINE_PAYMENT_REC
, x_result OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

);


END OE_Line_Payment_Security;

/
