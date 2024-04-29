--------------------------------------------------------
--  DDL for Package CSP_FAILURE_RATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_FAILURE_RATES_PVT" AUTHID CURRENT_USER as
/* $Header: cspvfrts.pls 115.2 2002/11/26 07:31:51 hhaugeru noship $ */

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  failure_rates
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   p_level_id		   		 	  IN   VARCHAR2
--   P_Api_Version_Number         IN   NUMBER
--
--   OUT:
--    retcode				   OUT NOCOPY NUMBER
--    errbuf				   OUT NOCOPY VARCHAR2
--    Version : Current version 1.0
---
---- End of Comments

PROCEDURE failure_rates (
  retcode				   OUT NOCOPY NUMBER,
  errbuf				   OUT NOCOPY VARCHAR2,
  p_level_id			   IN  VARCHAR2,
  P_Api_Version_Number   IN  NUMBER);

End CSP_FAILURE_RATES_PVT;

 

/
