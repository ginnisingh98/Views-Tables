--------------------------------------------------------
--  DDL for Package CST_PERIODSUMMARY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PERIODSUMMARY_PVT" AUTHID CURRENT_USER AS

  -- Start of comments
  -- API name        : WaitOn_Request
  -- Type            : Private
  -- Pre-reqs        : None
  -- Function        : Waits for GL transfer to be completed successfully,
  --                   updates a period to closed, and submits the period
  --                   close reconciliation report.
  --
  --                   The first two parameters ERRBUF and RETCODE are
  --                   required to allow this function to be called as
  --                   an Oracle Applications executable.
  --
  -- Parameters      : ERRBUF            OUT NOCOPY VARCHAR2
  --                   RETCODE           OUT NOCOPY NUMBER
  --                   p_api_version     IN         NUMBER   Required
  --                   p_request_id      IN         NUMBER   Required
  --                   p_org_id          IN         NUMBER   Required
  --                   p_period_id       IN         NUMBER   Required
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE WaitOn_Request(
    ERRBUF            OUT NOCOPY VARCHAR2,
    RETCODE           OUT NOCOPY NUMBER,
    p_api_version     IN         NUMBER,
    p_request_id      IN         NUMBER,
    p_org_id          IN         NUMBER,
    p_period_id       IN         NUMBER
  );

END CST_PeriodSummary_PVT;

 

/
