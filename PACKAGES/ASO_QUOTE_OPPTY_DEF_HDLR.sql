--------------------------------------------------------
--  DDL for Package ASO_QUOTE_OPPTY_DEF_HDLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_OPPTY_DEF_HDLR" AUTHID CURRENT_USER AS
/* $Header: asodhors.pls 120.0 2005/05/31 11:44:50 appldev noship $ */


--  Global Entity Record

g_record		ASO_AK_QUOTE_OPPTY_V%ROWTYPE;


--  Default_Record

PROCEDURE Default_Record
(   p_x_rec                         IN OUT NOCOPY ASO_AK_QUOTE_OPPTY_V%ROWTYPE
,   p_in_old_rec                    IN  ASO_AK_QUOTE_OPPTY_V%ROWTYPE
,   p_iteration                     IN  NUMBER := 1
);


END ASO_QUOTE_OPPTY_Def_Hdlr;

 

/
