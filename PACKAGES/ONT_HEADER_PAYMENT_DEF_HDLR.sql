--------------------------------------------------------
--  DDL for Package ONT_HEADER_PAYMENT_DEF_HDLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_HEADER_PAYMENT_DEF_HDLR" AUTHID CURRENT_USER AS
/* $Header: OEXHHPMS.pls 115.1 2003/10/20 06:58:00 appldev ship $ */


--  Global Entity Record

g_record		OE_AK_HEADER_PAYMENTS_V%ROWTYPE;


--  Default_Record

PROCEDURE Default_Record
(   p_x_rec                         IN OUT NOCOPY OE_AK_HEADER_PAYMENTS_V%ROWTYPE
,   p_in_old_rec                    IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE
,   p_iteration                     IN  NUMBER default 1
);


END ONT_HEADER_Payment_Def_Hdlr;

 

/
