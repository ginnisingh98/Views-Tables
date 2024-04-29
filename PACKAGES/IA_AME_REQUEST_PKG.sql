--------------------------------------------------------
--  DDL for Package IA_AME_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IA_AME_REQUEST_PKG" AUTHID CURRENT_USER AS
/* $Header: IAAMREQS.pls 120.0.12010000.1 2008/07/24 09:53:34 appldev ship $   */

/*
FUNCTION GetLOVApprovers
       (RequesterId             IN              NUMBER,
        ResponsibilityId        IN              NUMBER,
        LOVType		        IN              VARCHAR2,
        BookTypeCode            IN              VARCHAR2,
        CompanyCode             IN              VARCHAR2,
        CostCenter              IN              VARCHAR2,
        ApproverTypesTable      OUT NOCOPY      AME_UTIL.stringList,
        ApproverIdsTable        OUT NOCOPY      AME_UTIL.stringList)
--        ApproversTable          OUT NOCOPY      AME_UTIL.approversTable)
  return BOOLEAN;
*/

/*
FUNCTION GetNextApprover
       (RequestId		IN              NUMBER,
        Approver                OUT NOCOPY      AME_UTIL.approverRecord)
  return BOOLEAN;
*/

FUNCTION GetNextApprover
       (RequestId               IN              NUMBER,
        ChainPhase              IN OUT NOCOPY   VARCHAR2,
        Approver                OUT NOCOPY      AME_UTIL.approverRecord,
        NoMoreApproverFlag      OUT NOCOPY      VARCHAR2)
  return BOOLEAN;

FUNCTION GetAllApprovers
       (RequestId               IN              NUMBER,
        ReleasingApprovers      OUT NOCOPY      AME_UTIL.approversTable,
        ReceivingApprovers      OUT NOCOPY      AME_UTIL.approversTable)
  return BOOLEAN;

FUNCTION UpdateApprovalStatus
       (RequestId		IN              NUMBER,
        ChainPhase              IN              VARCHAR2,
        Approver		IN              AME_UTIL.approverRecord DEFAULT AME_UTIL.emptyApproverRecord,
        Forwardee		IN              AME_UTIL.approverRecord DEFAULT AME_UTIL.emptyApproverRecord)
  return BOOLEAN;

FUNCTION InitializePlsqlContext
       (RequestId               IN              NUMBER)
  return BOOLEAN;

FUNCTION InitializeAME
       (RequestId               IN              NUMBER)
  return BOOLEAN;

END IA_AME_REQUEST_PKG;

/
