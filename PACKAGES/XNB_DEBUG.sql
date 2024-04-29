--------------------------------------------------------
--  DDL for Package XNB_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNB_DEBUG" AUTHID CURRENT_USER AS
/* $Header: XNBVLOGS.pls 120.0 2005/05/30 13:44:37 appldev noship $ */

PROCEDURE LOG (MODULE IN VARCHAR2 , MESSAGE_TEXT IN VARCHAR2 );

end XNB_DEBUG;

 

/
