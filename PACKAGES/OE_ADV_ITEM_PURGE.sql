--------------------------------------------------------
--  DDL for Package OE_ADV_ITEM_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ADV_ITEM_PURGE" AUTHID CURRENT_USER AS
/* $Header: OEXADPRS.pls 120.0 2005/05/31 23:41:57 appldev noship $ */

--  Start of Comments
--  API name    Purge_Used_Sessions
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
PROCEDURE Purge_Used_sessions (retcode OUT NOCOPY VARCHAR2,
			       errbuf  OUT NOCOPY VARCHAR2 );

END OE_ADV_ITEM_PURGE;

 

/
