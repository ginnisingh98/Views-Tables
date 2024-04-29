--------------------------------------------------------
--  DDL for Package ONT_LINE_PAYMENT_DEF_HDLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_LINE_PAYMENT_DEF_HDLR" AUTHID CURRENT_USER AS
/* $Header: OEXHLPMS.pls 115.1 2003/10/20 06:58:10 appldev ship $ */


--  Global Entity Record

g_record		OE_AK_LINE_PAYMENTS_V%ROWTYPE;


--  Default_Record

PROCEDURE Default_Record
(   p_x_rec                         IN OUT NOCOPY OE_AK_LINE_PAYMENTS_V%ROWTYPE
,   p_in_old_rec                    IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
,   p_iteration                     IN  NUMBER default 1
);


END ONT_LINE_Payment_Def_Hdlr;

 

/
