--------------------------------------------------------
--  DDL for Package ASO_BI_LINE_FACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_BI_LINE_FACT_PVT" AUTHID CURRENT_USER AS
 /* $Header: asovbiqlins.pls 120.0 2005/05/31 01:26:06 appldev noship $ */

  -- This deletes quote lines that have got updated in date range
  -- This is done to remove quote lines that belonged to older versions
  -- of the quote
  PROCEDURE Cleanup_Line_Data;

  -- Inserts Records into ASO_BI_QUOTE_LINES_ALL reading from
  -- ASO_BI_QUOTE_LINES_STG table
  PROCEDURE Populate_Line_Data;

  -- Inserts the quote lines id into ASO_BI_LINE_IDS table
  -- corresponding the quotes that got changed in the given window
  -- of dates
  PROCEDURE initLoad_Quote_Line_ids;

  -- Inserts the updated quote line ids into ASO_BI_LINE_IDS table
  PROCEDURE Populate_Quote_Line_Ids;

  -- Inserts records into ASO_BI_QUOTE_FACT_JOBS as many as the batches
  PROCEDURE Register_Line_Jobs;

  -- Inserts records into ASO_BI_QUOTE_LINES_STG for all Quotes in the
  -- ASO_BI_LINE_IDS table for Initial Load
  Procedure InitiLoad_QotLineStg;

  -- This procedure is called as a part of incremental load of quote lines.
  -- Populates ASO_BI_QUOTE_LINES_STG table
  Procedure Line_Worker(
   Errbuf   IN OUT NOCOPY VARCHAR2,
   Retcode  IN OUT NOCOPY NUMBER,
   p_worker_no IN NUMBER) ;

  -- Initial Load of ASO_BI_QUOTE_LINES_ALL
  -- Called as a part of initial load of quote lines
  Procedure InitiLoad_QotLine;

END  ASO_BI_LINE_FACT_PVT ;

 

/
