--------------------------------------------------------
--  DDL for Package IA_WF_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IA_WF_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: IAWFUTLS.pls 120.0 2005/06/04 00:02:04 appldev noship $   */

-- iAssets' Common Constants
FUNCTION ApplicationShortName 	return VARCHAR2;

-- Definition of Profile Option Names
FUNCTION ProfileDebugMode 	return VARCHAR2;
FUNCTION ProfileRuleID 		return VARCHAR2;
FUNCTION ProfileSystemAdministrator	return VARCHAR2;

-- Approval Status for AME

-- Request Type
FUNCTION RequestTypeAssetList		return VARCHAR2;
FUNCTION RequestTypeTransfer		return VARCHAR2;
FUNCTION RequestTypeRetire		return VARCHAR2;

-- Approval History Status
FUNCTION ApprovalStatusSubmitted	return VARCHAR2;
FUNCTION ApprovalStatusPendingApproval	return VARCHAR2;
FUNCTION ApprovalStatusDelegated	return VARCHAR2;
FUNCTION ApprovalStatusApproved 	return VARCHAR2;
FUNCTION ApprovalStatusFinallyApproved	return VARCHAR2;
FUNCTION ApprovalStatusRejected 	return VARCHAR2;

-- Header Status
FUNCTION HeaderStatusSubmitted		return VARCHAR2;
FUNCTION HeaderStatusPendingApproval	return VARCHAR2;
FUNCTION HeaderStatusApproved 		return VARCHAR2;
FUNCTION HeaderStatusRejected 		return VARCHAR2;
FUNCTION HeaderStatusPendingError	return VARCHAR2;
FUNCTION HeaderStatusPost 		return VARCHAR2;

-- Line Status
FUNCTION LineStatusNew 			return VARCHAR2;
FUNCTION LineStatusPending 		return VARCHAR2;
FUNCTION LineStatusPost 		return VARCHAR2;
FUNCTION LineStatusOnReview 		return VARCHAR2;
FUNCTION LineStatusOnHold 		return VARCHAR2;
FUNCTION LineStatusRejected 		return VARCHAR2;
FUNCTION LineStatusPosted 		return VARCHAR2;


-- Responsibility Type for AME

FUNCTION RespTypeRequest 		return VARCHAR2;
FUNCTION RespTypeAll 		return VARCHAR2;

-- Approval Type for AME

FUNCTION ApprovalTypeAll 		return VARCHAR2;
FUNCTION ApprovalTypeReleasing 		return VARCHAR2;
FUNCTION ApprovalTypeDestination 	return VARCHAR2;
FUNCTION ApprovalTypeNone 		return VARCHAR2;

FUNCTION LOVTypeReleasing 		return VARCHAR2;
FUNCTION LOVTypeDestination 		return VARCHAR2;

-- Approval Method for AME

FUNCTION ApprovalMethodHierarchy	return VARCHAR2;
FUNCTION ApprovalMethodCostCenter	return VARCHAR2;

-- Transaction Type for AME

-- FUNCTION AME_LOV_TransactionType 	return VARCHAR2;
FUNCTION AME_RELEASE_TransactionType	return VARCHAR2;
FUNCTION AME_RECEIVE_TransactionType	return VARCHAR2;


-- Approval Groups for AME
-- HierarchyBasedRelGroup	VARCHAR2(30)	:= 'IA_APPROVAL_HRCH_REL';
-- HierarchyBasedRecGroup	CONSTANT	VARCHAR2(30)	:= 'IA_APPROVAL_HRCH_REC';
-- CostCenterBasedGroup	CONSTANT	VARCHAR2(30)	:= 'IA_APPROVAL_CC'; -- Both releasing and receiving are applied

FUNCTION HierarchyBasedRelGroup	return VARCHAR2;
FUNCTION HierarchyBasedRecGroup	return VARCHAR2;
FUNCTION CostCenterBasedGroup	return VARCHAR2;

-- Transaction Type for Workflow
-- WF_TransactionType	CONSTANT	VARCHAR2(15)	:= 'IA_TRX';

FUNCTION WF_TransactionType		return VARCHAR2;
FUNCTION WF_MainProcess			return VARCHAR2;

-- The folloging global variables will be set in each session by calling its corresponding function.
DebugModeEnabledFlag			BOOLEAN		:= NULL;
ApplicationID				NUMBER(15) 	:= NULL;
RuleID					NUMBER(15) 	:= NULL;
TransferEnabled				VARCHAR2(1) 	:= NULL;
TransactionDateAllowed			VARCHAR2(1) 	:= NULL;
ResponsibilityType			VARCHAR2(30) 	:= NULL;
SuperUserApprovalRequired		VARCHAR2(1) 	:= NULL;
ApprovalType				VARCHAR2(30) 	:= NULL;
ApprovalMethod				VARCHAR2(30) 	:= NULL;

PROCEDURE InitializeServerMessage;
PROCEDURE InitializeDebugMessage;

/*
PROCEDURE RaiseException(
        p_calling_fn    IN VARCHAR2,
        p_debug_info    IN VARCHAR2 DEFAULT ''
);
*/

PROCEDURE AddDebugMessage(
        p_calling_fn    IN VARCHAR2,
        p_parameter1    IN VARCHAR2 DEFAULT '',
        p_parameter2    IN VARCHAR2 DEFAULT ''
);

PROCEDURE AddWFDebugMessage(
        p_request_id    IN VARCHAR2,
        p_calling_fn    IN VARCHAR2,
        p_parameter1    IN VARCHAR2 DEFAULT '',
        p_parameter2    IN VARCHAR2 DEFAULT ''
);

FUNCTION GetApplicationID return NUMBER;

FUNCTION DebugModeEnabled return BOOLEAN;

FUNCTION GetRuleID
return NUMBER;

FUNCTION GetRuleID(p_responsibility_id      IN NUMBER)
return NUMBER;

FUNCTION GetSystemAdministrator
return VARCHAR2;

FUNCTION IsTransferEnabled(p_rule_id        IN NUMBER
                          ,p_book_type_code IN VARCHAR2)
return VARCHAR2;

FUNCTION IsTransactionDateAllowed(p_rule_id        IN NUMBER
                                 ,p_book_type_code IN VARCHAR2)
return VARCHAR2;


FUNCTION GetResponsibilityType(p_rule_id        IN NUMBER
                              ,p_book_type_code IN VARCHAR2)
return VARCHAR2;

FUNCTION IsSuperUserApprovalRequired(p_rule_id        IN NUMBER
                                    ,p_book_type_code IN VARCHAR2)
return VARCHAR2;


FUNCTION GetApprovalType(p_rule_id        IN NUMBER
                        ,p_book_type_code IN VARCHAR2)
return VARCHAR2;


FUNCTION GetApprovalMethod(p_rule_id        IN NUMBER
                          ,p_book_type_code IN VARCHAR2)
return VARCHAR2;

FUNCTION ResetRuleSetup(p_rule_id        IN NUMBER
                       ,p_book_type_code IN VARCHAR2)
return BOOLEAN;

FUNCTION GetLookupMeaning(p_lookup_type    IN VARCHAR2
                         ,p_lookup_code    IN VARCHAR2)
return VARCHAR2;


FUNCTION InitializeProfile(p_user_id            IN NUMBER
                          ,p_responsibility_id  IN NUMBER)
return BOOLEAN;


END IA_WF_UTIL_PKG;

 

/
