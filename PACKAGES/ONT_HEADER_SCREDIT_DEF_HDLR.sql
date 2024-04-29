--------------------------------------------------------
--  DDL for Package ONT_HEADER_SCREDIT_DEF_HDLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_HEADER_SCREDIT_DEF_HDLR" AUTHID CURRENT_USER AS
/* $Header: OEXHHSCS.pls 120.0 2005/06/01 02:40:18 appldev noship $ */


--  Global Entity Record

g_record		OE_AK_HEADER_SCREDITS_V%ROWTYPE;


--  Default_Record

PROCEDURE Default_Record
(   p_x_rec                         IN OUT NOCOPY OE_AK_HEADER_SCREDITS_V%ROWTYPE
,   p_in_old_rec                    IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
,   p_iteration                     IN  NUMBER default 1
);


END ONT_HEADER_Scredit_Def_Hdlr;

 

/
