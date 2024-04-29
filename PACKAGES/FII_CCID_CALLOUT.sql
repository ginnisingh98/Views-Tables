--------------------------------------------------------
--  DDL for Package FII_CCID_CALLOUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_CCID_CALLOUT" AUTHID CURRENT_USER AS
/* $Header: FIIGLUCS.pls 120.1 2005/10/30 05:05:04 appldev noship $ */


-- ************************************************************************
-- Procedure
--   UPDATE_FC          Procedure to update FC based on p_from_ccid
--			and p_to_ccid

-- Arguments
--   p_from_ccid	From CCID
--   p_to_ccid		To CCID

  PROCEDURE UPDATE_FC (p_from_ccid	IN	NUMBER,
		       p_to_ccid	IN	NUMBER);

END FII_CCID_CALLOUT;

 

/
