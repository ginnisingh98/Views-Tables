--------------------------------------------------------
--  DDL for Package ONT_LINE_SCREDIT_DEF_HDLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_LINE_SCREDIT_DEF_HDLR" AUTHID CURRENT_USER AS
/* $Header: OEXHLSCS.pls 120.0 2005/06/01 22:53:37 appldev noship $ */


--  Global Entity Record

g_record		OE_AK_LINE_SCREDITS_V%ROWTYPE;


--  Default_Record

PROCEDURE Default_Record
(   p_x_rec                         IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
,   p_in_old_rec                    IN  OE_AK_LINE_SCREDITS_V%ROWTYPE
,   p_iteration                     IN  NUMBER default 1
);


END ONT_LINE_Scredit_Def_Hdlr;

 

/
