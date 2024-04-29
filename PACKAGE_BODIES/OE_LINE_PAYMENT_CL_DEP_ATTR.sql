--------------------------------------------------------
--  DDL for Package Body OE_LINE_PAYMENT_CL_DEP_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_PAYMENT_CL_DEP_ATTR" AS
/* $Header: OEXNLPMB.pls 115.1 2003/10/20 07:03:20 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Line_Payment_Cl_Dep_Attr';

PROCEDURE PAYMENT_LEVEL_CODE
(p_x_line_payment_rec			IN OUT NOCOPY OE_AK_LINE_PAYMENTS_V%ROWTYPE
) IS
BEGIN

OE_Line_Payment_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Payment_Util.G_PAYMENT_LEVEL_CODE
    , p_x_line_payment_rec		=> p_x_line_payment_rec
    );

END PAYMENT_LEVEL_CODE;

PROCEDURE PAYMENT_TYPE_CODE
(p_x_line_payment_rec			IN OUT NOCOPY OE_AK_LINE_PAYMENTS_V%ROWTYPE
) IS
BEGIN

OE_Line_Payment_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Payment_Util.G_PAYMENT_TYPE_CODE
    , p_x_line_payment_rec		=> p_x_line_payment_rec
    );

END PAYMENT_TYPE_CODE;


PROCEDURE PAYMENT_TRX
(p_x_line_payment_rec			IN OUT NOCOPY OE_AK_LINE_PAYMENTS_V%ROWTYPE
) IS
BEGIN

OE_Line_Payment_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Payment_Util.G_PAYMENT_TRX_ID
    , p_x_line_payment_rec		=> p_x_line_payment_rec
    );

END PAYMENT_TRX;

PROCEDURE RECEIPT_METHOD
(p_x_line_payment_rec			IN OUT NOCOPY OE_AK_LINE_PAYMENTS_V%ROWTYPE
) IS
BEGIN

OE_Line_Payment_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Payment_Util.G_RECEIPT_METHOD_ID
    , p_x_line_payment_rec		=> p_x_line_payment_rec
    );

END RECEIPT_METHOD;

PROCEDURE PAYMENT_COLLECTION_EVENT
(p_x_line_payment_rec			IN OUT NOCOPY OE_AK_LINE_PAYMENTS_V%ROWTYPE
) IS
BEGIN

OE_Line_Payment_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Payment_Util.G_PAYMENT_COLLECTION_EVENT
    , p_x_line_payment_rec		=> p_x_line_payment_rec
    );

END PAYMENT_COLLECTION_EVENT;

PROCEDURE CHECK_NUMBER
(p_x_line_payment_rec			IN OUT NOCOPY OE_AK_LINE_PAYMENTS_V%ROWTYPE
) IS
BEGIN

OE_Line_Payment_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Payment_Util.G_CHECK_NUMBER
    , p_x_line_payment_rec		=> p_x_line_payment_rec
    );

END CHECK_NUMBER;

END OE_Line_Payment_Cl_Dep_Attr;

/
