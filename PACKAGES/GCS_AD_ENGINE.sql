--------------------------------------------------------
--  DDL for Package GCS_AD_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_AD_ENGINE" AUTHID CURRENT_USER as
-- $Header: gcsadens.pls 120.1 2005/10/30 05:16:50 appldev noship $

  /*
  ** Procedure
  **   process_transaction
  ** Arguments
  **   p_transaction_id is the transaction_id to process
  ** Synopsis
  */
  PROCEDURE process_transaction (
      errbuf                 IN OUT NOCOPY  VARCHAR2,
      retcode                IN OUT NOCOPY  NUMBER,
      p_transaction_id       IN             NUMBER
  );

end GCS_AD_ENGINE;

 

/
