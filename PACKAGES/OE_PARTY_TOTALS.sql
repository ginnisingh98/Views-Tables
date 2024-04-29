--------------------------------------------------------
--  DDL for Package OE_PARTY_TOTALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PARTY_TOTALS" AUTHID CURRENT_USER AS
/* $Header: OEXBTOTS.pls 120.0 2005/06/01 01:19:43 appldev noship $ */


--  Start of Comments
--  API name    Update_Party_Totals
--  Type        Private
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

PROCEDURE Update_Party_Totals(err_buff OUT NOCOPY VARCHAR2,
   retcode out NOCOPY NUMBER);

END OE_Party_TOTALS;

 

/
