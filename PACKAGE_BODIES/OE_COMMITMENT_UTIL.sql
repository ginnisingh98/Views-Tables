--------------------------------------------------------
--  DDL for Package Body OE_COMMITMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_COMMITMENT_UTIL" AS
/* $Header: OEXUCMTB.pls 120.0 2005/06/01 03:06:51 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_COMMITMENT_UTIL';

----------------------------------------
-- Procedure Get_Commitment_Info
-- This procedure is provided to be called by OTA team.
-- Abstract: given a line id, return the
--           commitment id, number, start date and end date.
--           Return NULL when there is no commitment on the line.
-- Note: The sql is selecting from oe_order_lines instead of oe_payments
--       This is fine for now while we're still storing the commitment id
--       in oe_order_lines.  This is done to avoid having odf files in
--       the patch.
----------------------------------------

PROCEDURE Get_Commitment_Info
(   p_line_id			IN 	NUMBER  := FND_API.G_MISS_NUM
, x_commitment_id OUT NOCOPY NUMBER

, x_commitment_number OUT NOCOPY VARCHAR2

, x_commitment_start_date OUT NOCOPY DATE

, x_commitment_end_date OUT NOCOPY DATE

)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


    SELECT  oe.commitment_id
    ,	    ra.trx_number
    ,	    ra.start_date_commitment
    ,	    ra.end_date_commitment

    INTO    x_commitment_id
    ,       x_commitment_number
    ,       x_commitment_start_date
    ,       x_commitment_end_date

    FROM    oe_order_lines oe
    ,	    ra_customer_trx_all ra

    WHERE   oe.commitment_id = ra.customer_trx_id
    AND     line_id = p_line_id
    ;


EXCEPTION
    WHEN NO_DATA_FOUND THEN

	x_commitment_id := NULL;
	x_commitment_number := NULL;
	x_commitment_start_date := NULL;
	x_commitment_end_date := NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Commitment_Info'
            );
        END IF;

END Get_Commitment_Info;
---------------------------------------------------------------------

END OE_COMMITMENT_UTIL;

/
