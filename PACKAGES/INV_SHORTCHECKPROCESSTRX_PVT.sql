--------------------------------------------------------
--  DDL for Package INV_SHORTCHECKPROCESSTRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SHORTCHECKPROCESSTRX_PVT" AUTHID CURRENT_USER AS
/* $Header: INVSPPVS.pls 120.1 2005/06/21 05:41:00 appldev ship $*/
  -- Start OF comments
  -- API name  : ProcessTransactions
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  :
  -- Parameters:
  --     IN    :
  --
  --	 OUT   :
  --
  --  ERRBUF		 OUT VARCHAR2
  --	Error code
  --
  --  RETCODE		 OUT NUMBER
  --	Return completion status
  --
  -- Version: Current Version 1.0
  --              Changed : Nothing
  --          No Previous Version 0.0
  --          Initial version 1.0
  -- Notes  :
  -- END OF comments
PROCEDURE ProcessTransactions (
  ERRBUF 			OUT NOCOPY VARCHAR2,
  RETCODE			OUT NOCOPY NUMBER
  );
END INV_ShortCheckProcessTrx_PVT;

 

/
