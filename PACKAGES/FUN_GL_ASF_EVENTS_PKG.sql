--------------------------------------------------------
--  DDL for Package FUN_GL_ASF_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_GL_ASF_EVENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: funglasfevnts.pls 120.0 2006/01/13 09:15:02 bsilveir noship $ */


  -- This procedure is invoked from the GL Accounting Setup Flow page
  -- when a Balancing Segment Value is removed from the Ledger
  -- Event Name = oracle.apps.gl.Setup.Ledger.BalancingSegmentValueRemove
  --
  FUNCTION ledger_bsv_remove(p_subscription_guid IN RAW
                              ,p_event             IN OUT NOCOPY wf_event_t
                              ) RETURN VARCHAR2;

  -- This procedure is invoked from the GL Accounting Setup Flow page
  -- when a Balancing Segment Value is removed from the Legal Entity
  -- Event Name = oracle.apps.gl.Setup.LegalEntity.BalancingSegmentValueRemove
  --
  FUNCTION le_bsv_remove(p_subscription_guid IN RAW
                         ,p_event            IN OUT NOCOPY wf_event_t
                         ) RETURN VARCHAR2;


  -- This procedure is invoked from the GL Accounting Setup Flow page
  -- when a Legal Entity is removed from the Ledger
  -- Event Name = oracle.apps.gl.Setup.Ledger.LegalEntityRemove
  --
  FUNCTION ledger_le_remove(p_subscription_guid IN RAW
                           ,p_event            IN OUT NOCOPY wf_event_t
                           ) RETURN VARCHAR2;

  -- This procedure is invoked from the GL Accounting Setup Flow page
  -- when a secondary ledger is removed from the Ledger
  -- Event Name = oracle.apps.gl.Setup.SecondaryLedger.delete
  --
  FUNCTION secondary_ledger_delete(p_subscription_guid IN RAW
                           ,p_event            IN OUT NOCOPY wf_event_t
                           ) RETURN VARCHAR2;

  -- This procedure is invoked from the GL Accounting Setup Flow page
  -- when a reporting ledger is removed from the Ledger
  -- Event Name = oracle.apps.gl.Setup.ReportingLedger.delete
  --
  FUNCTION reporting_ledger_delete(p_subscription_guid IN RAW
                           ,p_event            IN OUT NOCOPY wf_event_t
                           ) RETURN VARCHAR2;
END;


 

/
