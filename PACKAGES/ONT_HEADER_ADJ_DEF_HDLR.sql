--------------------------------------------------------
--  DDL for Package ONT_HEADER_ADJ_DEF_HDLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_HEADER_ADJ_DEF_HDLR" AUTHID CURRENT_USER AS
/* $Header: OEXHHADS.pls 120.0 2005/06/01 00:47:52 appldev noship $ */


--  Global Entity Record

g_record		OE_AK_HEADER_PRCADJS_V%ROWTYPE;


--  Default_Record

PROCEDURE Default_Record
(   p_x_rec                        IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
,   p_in_old_rec                    IN  OE_AK_HEADER_PRCADJS_V%ROWTYPE
,   p_iteration                     IN  NUMBER default 1
);


END ONT_HEADER_ADJ_Def_Hdlr;

 

/
