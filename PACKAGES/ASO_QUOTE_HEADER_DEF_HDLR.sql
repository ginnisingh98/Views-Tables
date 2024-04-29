--------------------------------------------------------
--  DDL for Package ASO_QUOTE_HEADER_DEF_HDLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_HEADER_DEF_HDLR" AUTHID CURRENT_USER AS
/* $Header: asodhdrs.pls 120.0 2005/05/31 12:04:33 appldev noship $ */
-- Package name     : ASO_QUOTE_HEADER_Def_Hdlr
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


--  Global Entity Record

g_record		ASO_AK_QUOTE_HEADER_V%ROWTYPE;


--  Default_Record

PROCEDURE Default_Record
(   p_x_rec                         IN OUT NOCOPY ASO_AK_QUOTE_HEADER_V%ROWTYPE
,   p_in_old_rec                    IN  ASO_AK_QUOTE_HEADER_V%ROWTYPE
,   p_iteration                     IN  NUMBER := 1
);


END ASO_QUOTE_HEADER_Def_Hdlr;

 

/
