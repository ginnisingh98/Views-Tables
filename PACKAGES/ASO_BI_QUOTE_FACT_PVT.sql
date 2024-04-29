--------------------------------------------------------
--  DDL for Package ASO_BI_QUOTE_FACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_BI_QUOTE_FACT_PVT" AUTHID CURRENT_USER AS
 /* $Header: asovbiqhds.pls 120.0 2005/05/31 01:25:53 appldev noship $ */


  --This procedure is used for extracting the New Quote Ids for
  --initial Load.
  PROCEDURE InitLoad_Quote_Ids (
    p_from_date IN Date,
    p_to_date   IN Date);


  --This procedure is used for extracting the New Quote Ids for
  --incremental Load.
  PROCEDURE Populate_Quote_Ids(
     p_from_date IN DATE,
     p_to_date   IN DATE) ;

  --This procedure is used to register jobs for the subworkers
  --in case of incremental load.
  PROCEDURE Register_Jobs;

  --This procedure populates the base fact table for Quote Headers
  --in initial load.
  Procedure InitiLoad_QotHdr ;

  --This procedure populates the base fact table for Quote Headers
  --in incremental load.
  PROCEDURE Populate_Data;

  --The subworker program called for incremental load.
  Procedure Worker(
   Errbuf   IN OUT NOCOPY VARCHAR2,
   Retcode  IN OUT NOCOPY NUMBER,
   p_worker_no IN NUMBER) ;

END ASO_BI_QUOTE_FACT_PVT ;

 

/
