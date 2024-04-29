--------------------------------------------------------
--  DDL for Package ENG_WORKFLOW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_WORKFLOW_PUB" AUTHID CURRENT_USER AS
/* $Header: ENGBWKFS.pls 120.3 2006/04/11 17:59:48 mkimizuk noship $ */


-- NOT SUPPORTING IN 115.10
-- PROCEDURE CHECK_HEADER_OR_LINE
--
-- Check if this change object is header or line
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE
--           activity has completed
--       - COMPLETE:Y
--           Header
--       - COMPLETE:N
--           Line
--
PROCEDURE CHECK_HEADER_OR_LINE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY  varchar2);


-- PROCEDURE SELECT_ADHOC_PARTY
--
-- Select Adhoc Party and Set users to Adhoc Role
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE
--           activity has completed
--       - COMPLETE:NONE
--           activity could not find any adhoc parties
PROCEDURE SELECT_ADHOC_PARTY(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY  varchar2);

-- PROCEDURE SELECT_ASSIGNEE
--
-- Select Assignees and Set the users to Assignee Role
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
--       - COMPLETE:NONE
--           activity could not find any parties
PROCEDURE SELECT_ASSIGNEE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE SELECT_STD_REVIEWERS
--
-- Select Change Object Standard Reviewers
-- ( Assignee, Requestor and Creator)
-- and set Reviewer Role
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
--       - COMPLETE:NONE
--           activity could not find any parties
PROCEDURE SELECT_STD_REVIEWERS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE SELECT_REVIEWERS
--
-- Select Change Object Reviewers( Requestor and Creator)
-- and set Reviewer Role
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
--       - COMPLETE:NONE
--           activity could not find any parties
PROCEDURE SELECT_REVIEWERS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE SELECT_LINE_ASSIGNEE
--
-- Select Line Assignees and Set the users to Line Assignee Role
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
--       - COMPLETE:NONE
--           activity could not find any parties
PROCEDURE SELECT_LINE_ASSIGNEE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE SELECT_STD_LINE_REVIEWERS
--
-- Select Change Line Object Standard Reviewers
-- ( Line Assignee, Line Creator
--   Header Assignee, Header Requestor and Header Creator)
-- and set Line Reviewer Role
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
--       - COMPLETE:NONE
--           activity could not find any parties
PROCEDURE SELECT_STD_LINE_REVIEWERS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE SELECT_LINE_REVIEWERS
--
-- Select Change Line Object Reviewers
-- ( Line Creator
--   Header Assignee, Header Requestor and Header Creator)
-- and set Line Reviewer Role
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
--       - COMPLETE:NONE
--           activity could not find any line parties
PROCEDURE SELECT_LINE_REVIEWERS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE INITIATE_LINES
--
-- Start ENGCLACT: INITIATE_CHANGE Workflows for
-- the Change Object to initiate the lines
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE INITIATE_LINES(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);



-- PROCEDURE SELECT_ROUTE_PEOPLE
--
-- Select Route People and set to Role People Role
-- Route People: all route people in the route workflow
-- that have already been notified (i.e. completed or in process steps)
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
--       - COMPLETE:NONE
--           activity could not find any adhoc parties
PROCEDURE SELECT_ROUTE_PEOPLE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE SELECT_STEP_PEOPLE
--
-- Select Route Step People and set to Step People Role
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
--       - COMPLETE:NONE
--           activity could not find any adhoc parties
PROCEDURE SELECT_STEP_PEOPLE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE DELETE_ADHOC_ROLES_AND_USERS
--
-- Delete Workflow Adhoc Role and Local Users
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE DELETE_ADHOC_ROLES_AND_USERS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);

-- PROCEDURE SET_REQUEST_OPTIONS
--
-- Set Action: Comment Request Request Option
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE SET_REQUEST_OPTIONS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE SET_STEP_ACT_OPTIONS
--
-- Set Route Step Activity Options
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE SET_STEP_ACT_OPTIONS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE RESPOND_TO_COMMENT_REQUEST
--
-- Process notification response to Comment Request
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE RESPOND_TO_COMMENT_REQUEST(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE RESPOND_TO_ROUTE_APPROVAL_REQ
--
-- Process notification response to seeded Route Approval Request
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE RESPOND_TO_ROUTE_APPROVAL_REQ(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE RESPOND_TO_ROUTE_COMMENT_REQUEST
--
-- Process notification response to seeded Route Comment Request
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE RESPOND_TO_ROUTE_COMMENT_REQ(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE RESPOND_TO_ROUTE_DEF_REQ
--
-- Process notification response to seeded Route Defintion Request
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE RESPOND_TO_ROUTE_DEF_REQ(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE RESPOND_TO_ROUTE_DEF_APPR_REQ
--
-- Process notification response to seeded Route Defintion and Approval Request
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE RESPOND_TO_ROUTE_DEF_APPR_REQ(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE RESPOND_TO_ROUTE_CORRECT_REQ
--
-- Process notification response to seeded Route Correct Defintion Request
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE RESPOND_TO_ROUTE_CORRECT_REQ(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);




--
-- R12B
-- PROCEDURE RESPOND_TO_ROUTE_RESPONSE_REQ
--
-- Process notification response to seeded Route Response Request
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE RESPOND_TO_ROUTE_RESPONSE_REQ(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);



-- PROCEDURE START_ROUTE_STEP
--
-- Start Next Route Step
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
--       - COMPLETE:NONE
--           activity could not find any adhoc parties
PROCEDURE START_ROUTE_STEP(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);



-- PROCEDURE CHECK_STEP_RESULT
--
-- Check Step Result
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<ENG_CHANGE_ROUTE_STATUSES lookup codes>]
--           activity has completed with the step result
PROCEDURE CHECK_STEP_RESULT(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE CHECK_LINE_APPROVALS
--
-- Check if all lines are approved
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<ENG_ECN_APPROVAL_STATUS lookup codes>]
--           If all lins are approved, return status 5: Approved
--           otherwise return else
--
PROCEDURE CHECK_LINE_APPROVALS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE FIND_WAITING_STEP
--
-- Find waiting steps in this route
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE:Boolean(WFSTD_BOOLEAN)
--           activity has completed with the indicated result
PROCEDURE FIND_WAITING_STEP (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2) ;

-- PROCEDURE ROUTE_APPROVE_CHANGE
--
-- Approve Change Object in Route
-- update Change Object Approval Status and Route Status
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE ROUTE_APPROVE_CHANGE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);

-- PROCEDURE ROUTE_REJECT_CHANGE
--
-- Reject Change Object in Route
-- update Change Object Approval Status and Route Status
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE ROUTE_REJECT_CHANGE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);



-- PROCEDURE ROUTE_SET_TIMEOUT
--
-- Set Route as Time Out
-- update Change Object Approval Status and Route Status
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE ROUTE_SET_TIMEOUT(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE STEP_COMPLETE_ACTIVITY
--
-- Set Step Activity as Completed
-- update Route Step Status
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE STEP_COMPLETE_ACTIVITY (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE STEP_APPROVE_CHANGE
--
-- Approve Change in Step
-- update Route Step Status
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE STEP_APPROVE_CHANGE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);

-- PROCEDURE STEP_REJECT_CHANGE
--
-- Reject Change in Step
-- update Route Step Status
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE STEP_REJECT_CHANGE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);

-- PROCEDURE STEP_SET_TIMEOUT
--
-- Set Step as Time Out
-- update Route Step Status
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE STEP_SET_TIMEOUT(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);



-- PROCEDURE GRANT_ROLE_TO_STEP_PEOPLE
--
-- Grant the role which is defined in process attr: DEFAULT_CHANGE_ROLE
-- to step people
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE GRANT_ROLE_TO_STEP_PEOPLE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


--
-- PROCEDURE CHECK_DEFINITIONS
--
--   Check Definitions
--   this is place folder customer can replace with own PL/SQL Function
--   By default, this Activity always returns TRUE
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--       - COMPLETE:Boolean(WFSTD_BOOLEAN)
--           activity has completed with the indicated result
PROCEDURE CHECK_DEFINITIONS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


--
-- PROCEDURE CHECK_ROUTE_OBJECT
--
--   Check Route Object
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<ENG_CHANGE_OBJECTS lookup codes>]
--           based on Route Object
PROCEDURE CHECK_ROUTE_OBJECT(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


--
-- PROCEDURE SYNC_CHANGE_LC_PHASE
--
--   Sync Change Management Lifecycle Phase
--   This activity calls Change Management Lifecycle Phase to integrate with LC Phase
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE SYNC_CHANGE_LC_PHASE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);





--
-- PROCEDURE CHECK_BASE_CM_TYPE_CODE
--
--   Check Approval Status
--   Bug5136260
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<ENG_BASE_CM_TYPE_CODES lookup codes>] or NULL
--           activity has completed with the step result
PROCEDURE CHECK_BASE_CM_TYPE_CODE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);



--
-- PROCEDURE CHECK_CHANGE_APPR_STATUS
--
--   Check Approval Status
--   Bug5136260
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<ENG_ECN_APPROVAL_STATUS lookup codes>] or NULL
--           activity has completed with the step result
PROCEDURE CHECK_CHANGE_APPR_STATUS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


--
-- PROCEDURE SET_CO_MRP_FLAG_ACTIVE
--
--   Set Change Order MRP Flag to Active
--   Bug5136260
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE SET_CO_MRP_FLAG_ACTIVE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


-- PROCEDURE SET_CO_MRP_FLAG_INACTIVE
--
--   Set Change Order MRP Flag to Inactive
--   Bug5136260
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE SET_CO_MRP_FLAG_INACTIVE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);



-- PROCEDURE SET_ADMIN_STATUS_MONITOR_URL
--
--   Set WF Admin Status Monigor URL to Item Attribute: STATUS_MONITOR_URL
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE SET_ADMIN_STATUS_MONITOR_URL(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


--
-- PROCEDURE SET_EVENT_CHANGE_OBJECT_INFO
--
--   Set Change Object information
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE SET_EVENT_CHANGE_OBJECT_INFO(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


/**********************************
--
-- NOT SUPPORTING IN 115.10
-- PROCEDURE CONTINUE_HEADER_ROUTE
--
-- Signal Flow to continue to Header Route
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE CONTINUE_HEADER_ROUTE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);



--
-- NOT SUPPORTING IN 115.10
-- PROCEDURE WAIT_FOR_LINE_ROUTE
--
--   Wait for Line Route flow to complete
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - NULL
--           activity has completed
PROCEDURE WAIT_FOR_LINE_ROUTE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);

*****************************************/

END Eng_Workflow_Pub ;

 

/
