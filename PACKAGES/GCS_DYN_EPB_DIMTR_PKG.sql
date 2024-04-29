--------------------------------------------------------
--  DDL for Package GCS_DYN_EPB_DIMTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DYN_EPB_DIMTR_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsdyndimtrs.pls 120.1 2005/10/30 05:17:45 appldev noship $ */


  --
  -- Procedure
  --   Gcs_Epb_Tr_Dim
  -- Purpose
  --   Transfer dim from FEM_BALANCES to FEM_DIM11
  -- Arguments
  --   errbuf:             Buffer to store the error message
  --   retcode:            Return code
   -- Example
  --
  -- Notes
  PROCEDURE Gcs_Epb_Tr_Dim (
                errbuf       OUT NOCOPY VARCHAR2,
		retcode      OUT NOCOPY VARCHAR2 );


END GCS_DYN_EPB_DIMTR_PKG;

 

/
