--------------------------------------------------------
--  DDL for Package DPP_MIG_ADJ_PARA_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_MIG_ADJ_PARA_APPROVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: dppmigss.pls 120.0.12010000.1 2009/06/24 12:31:16 anbbalas noship $ */

  -- Start of Comments
  --
  -- NAME
  --   DPP_MIG_ADJ_PARA_APPROVAL_PVT
  --
  -- PURPOSE
  --   This package contains migration related code for adjustment flow
  -- and parallel approval.
  --
  -- NOTES
  --
  -- HISTORY
  -- anbbalas      10/06/2009           Created
  --
  -- End of Comments

  PROCEDURE update_transaction_status(
              errbuf  OUT NOCOPY VARCHAR2
            , retcode OUT NOCOPY VARCHAR2
  );

END DPP_MIG_ADJ_PARA_APPROVAL_PVT;

/
