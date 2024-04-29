--------------------------------------------------------
--  DDL for Package CST_COSTPROCVALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_COSTPROCVALIDATION_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTVCPVS.pls 120.0 2005/05/25 06:00:28 appldev noship $ */


  -- Start of comments
  -- API name        : Validate_Transactions
  -- Type            : Private
  -- Pre-reqs        : None
  -- Function        : Checks for data corruption in MMT.
  -- Parameters      :
  --                   x_return_status   OUT NOCOPY VARCHAR2 Required
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Validate_Transactions(
    x_return_status            OUT NOCOPY VARCHAR2
  );


END CST_CostProcValidation_PVT;

 

/
