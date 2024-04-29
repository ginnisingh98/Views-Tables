--------------------------------------------------------
--  DDL for Package WF_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_STANDARD" AUTHID CURRENT_USER as
/* $Header: wfstds.pls 120.2.12010000.1 2008/07/25 14:45:46 appldev ship $ */


-- AbortProcess
--   cover to wf_engine abort process used in error process.
procedure AbortProcess(itemtype   in varchar2,
                       itemkey    in varchar2,
                       actid      in number,
                       funcmode   in varchar2,
                       resultout  in out nocopy varchar2);

-- OrJoin
--   Parallel Or Join.
--   Always returns 'NULL' result immediately, since an 'Or' succeeds
--   as soon as first in-transition activity completes.
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'NULL'
procedure OrJoin(itemtype  in varchar2,
                 itemkey   in varchar2,
                 actid   in number,
                 funcmode  in varchar2,
                 resultout in out nocopy varchar2);

-- AndJoin
--   Parallel And Join
--   Returns 'NULL' if all in-transition activities have completed.
--   Returns 'WAITING' if at least one in-transition activity is not
--   complete, or is complete with the wrong result.
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'WAITING' | 'NULL'
procedure AndJoin(itemtype  in varchar2,
                  Itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2);

-- Assign
--   Assign value to an item attribute
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'NULL'
-- ACTIVITY ATTRIBUTES REFERENCED
--   ATTR         - Item attribute to set
--   DATE_VALUE   - date value
--   NUMBER_VALUE - number value
--   TEXT_VALUE   - text value
procedure Assign(itemtype  in varchar2,
                 itemkey   in varchar2,
                 actid     in number,
                 funcmode  in varchar2,
                 resultout in out nocopy varchar2);

-- Compare
--   Standard Compare function.
--   Compare two values and return TRUE/FALSE.
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   comparison result (WFSTD_COMPARISON lookup code)
-- ACTIVITY ATTRIBUTES REFERENCED
--   VALUE1 - Item attribute reference
--   VALUE2 - Constant value of correct type
procedure Compare(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2);

-- CompareExecutionTime
--   Compare Execution Time function.
-- OUT
--   comparison value (LT, EQ, GT, NULL)
-- ACTIVITY ATTRIBUTES REFERENCED
--   EXECUTIONTIME - Execution time Test value in seconds
procedure CompareExecutionTime(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2);

-- CompareEventProperty
--  Compare a property on an event
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   comparison result (WFSTD_COMPARISON lookup code)
--   GT LT EQ NULL
-- ACTIVITY ATTRIBUTES REFERENCED
--   VALUE1 - Event Property Reference (Based on the lookup of EVENTPROPERTY
--   VALUE2 - Constant value of correct type
procedure CompareEventProperty(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2);

--  SetEventProperty
--  Set the property in an Event to a given value
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   NONE
-- ACTIVITY ATTRIBUTES REFERENCED
--   EVENT - Event whose property is to be compared
--   PROPERTY - Event Property Reference (Based on the lookup of EVENTPROPERTY
--   VALUE - Constant value of correct type
procedure SetEventProperty(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out nocopy varchar2);

--  GetEventProperty
--  Get a property of an Event and assign it to an Item Attribute
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   NONE
-- ACTIVITY ATTRIBUTES REFERENCED
--   EVENT - Event whose property is to be compared
--   PROPERTY - Event Property Reference (Based on the lookup of EVENTPROPERTY
--   VALUE - Constant value of correct type
procedure GetEventProperty(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out nocopy varchar2);

-- LaunchProcess
--   launches a process
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - NULL
-- ACTIVITY ATTRIBUTES REFERENCED
--   START_ITEMTYPE,START_ITEMKEY,START_PROCESS,START_USER_KEY,START_OWNER
procedure LaunchProcess
              (itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2);


-- LaunchProcess
--   Forks the item by creating a duplicate item with the same history.
--   The new forked item will be identical up to the point of this activity.
--   However this activity will be marked as NOTIFIED. It will be upto the user
--   to push it forward using CompleteActivity.
--   NOTE: this is not permitted for #SYNCH items.
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - NULL
-- ACTIVITY ATTRIBUTES REFERENCED
--   NEW_ITEMKEY   - the itemkey for the new item (required)
--   SAME_VERSION  - TRUE creates a duplicate, FALSE uses the latest version
procedure ForkItem(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2);

-- Noop
--   Does nothing
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - NULL
-- ACTIVITY ATTRIBUTES REFERENCED
--   none
procedure Noop(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2);

-- Notify
--   Public wrapper to engine notification call
--   the engine notification package will retrieve the activity attributes.
-- OUT
--   result    - NULL
procedure Notify(itemtype   in varchar2,
                 itemkey    in varchar2,
                 actid      in number,
                 funcmode   in varchar2,
                 resultout  in out nocopy varchar2);

-- Block
--   Stop and wait for external completion
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - NOTIFIED
procedure Block(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2);

-- Block
--   Defers the thread by requesting a wait of zero seconds
-- OUT
--   result    - DEFERRED:sysdate
procedure Defer(itemtype   in varchar2,
                itemkey    in varchar2,
                actid      in number,
                funcmode   in varchar2,
                resultout  in out nocopy varchar2);

-- Wait
--   Wait until given date or elapsed time
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'DEFERRED' or 'NULL'
--     'DEFERRED' if this is the first call and wait is beginning
--     'NULL' if this is the second call and wait period has completed
-- ACTIVITY ATTRIBUTES REFERENCED
--   WAIT_MODE - Lookup
--     'ABSOLUTE' - Wait until date in WAIT_ABSOLUTE_DATE
--     'RELATIVE' - Wait until time WAIT_RELATIVE_TIME after current date
--     'DAY_OF_WEEK' - Wait until next occurrence of day of week
--     'DAY_OF_MONTH' - Wait until next occurrence of day of month
--   WAIT_ABSOLUTE_DATE - Date
--     Date to wait until if WAIT_MODE = 'ABSOLUTE'
--     (Ignored if mode != 'ABSOLUTE')
--   WAIT_RELATIVE_TIME - Number (expressed in <days>.<fraction of days>)
--     Time to wait after current date if WAIT_MODE = 'RELATIVE'
--     (Ignored if mode != 'RELATIVE')
--   WAIT_DAY_OF_WEEK - Lookup
--     Next day of week (SUNDAY, MONDAY, etc) after current date
--     (Ignored if mode != 'DAY_OF_WEEK')
--   WAIT_DAY_OF_MONTH - Lookup
--     Next day of month (1, 2, ..., 31, LAST) after current date
--     (Ignored if mode != 'DAY_OF_MONTH');
--   WAIT_TIME - Date (format HH24:MI)
--     Time of day to complete activity.   Valid for all wait modes.
--     If null default time to 00:00 (midnight), except RELATIVE mode.
--     For RELATIVE mode, if time is null then complete relative to current
--     date and time.
-- NOTE:
--     For all WAIT_MODEs, the completion day is determined by the attribute
--   associated with the mode, and the completion time by the WAIT_TIME
--   attribute.
--     For all modes except RELATIVE, the completion time is WAIT_TIME on
--   the day selected by the mode's attribute.  If WAIT_TIME is null, the
--   default is 00:00 (midnight).
--     For RELATIVE mode, if WAIT_TIME is null the completion time is
--   figured relative to the current date and time.  If WAIT_TIME is not
--   null the completion time is WAIT_TIME on the day selected regardless
--   of the current time.
--
procedure Wait(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2);

-- ResetError
--   Reset the status of an errored activity in an ERROR process.
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'NULL'
-- ACTIVITY ATTRIBUTES REFERENCED
--   COMMAND - 'RETRY' or 'SKIP'
--        'RETRY' clears the errored activity and runs it again
--        'SKIP' marks the errored activity complete and continues processing
--   RESULT - Result code to complete the activity with if COMMAND = 'SKIP'
procedure ResetError(itemtype   in varchar2,
                     itemkey    in varchar2,
                     actid      in number,
                     funcmode   in varchar2,
                     resultout  in out nocopy varchar2);



-- InitializeErrors
--   Called by the  Error Process, this sets up various
--   item attributes.
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'NULL'
PROCEDURE InitializeErrors(     itemtype        VARCHAR2,
                                itemkey         VARCHAR2,
                                actid           NUMBER,
                                funcmode        VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 );


-- CheckErrorActive
--   Called by the  Error Process, this check if errored activity
--   is still in error
--   Use this in an error process to exit out of a timeout loop
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - T/F
PROCEDURE CheckErrorActive(     itemtype        IN VARCHAR2,
                                itemkey         IN VARCHAR2,
                                actid           IN NUMBER,
                                funcmode        IN VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 );


-- RoleResolution
--   Resole A Role which comprises a group to an individual
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'NULL'
-- ACTIVITY ATTRIBUTES REFERENCED
--   COMMAND - 'LOAD_BALANCE' or 'ROUND_ROBIN'
--        'LOAD_BALANCE' Assigns to user with least open notifications
--        'ROUND_ROBIN'  Assigns notification to users sequencially
procedure RoleResolution(itemtype   in varchar2,
                         itemkey    in varchar2,
                         actid      in number,
                         funcmode   in varchar2,
                         resultout  in out nocopy varchar2);

-- WaitForFlow
--   Wait for flow(Master or Detail) to complete
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'NULL'
-- USED BY ACTIVITIES
--
--   WFSTD.WAITFORFLOW
--
-- ACTIVITY ATTRIBUTES REFERENCED
--   CONTINUATION_ACTIVITY - Name of Activity that must be complete to continue
--   CONTINUATION_FLOW     - MASTER or DETAIL
--                           - is Continuation Activity is in master or detail
procedure WaitForFlow(  itemtype   in varchar2,
                        itemkey    in varchar2,
                        actid      in number,
                        funcmode   in varchar2,
                        resultout  in out nocopy varchar2);

-- ContinueFlow
--   Signal Flow(Master or Detail ) to continue
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'NULL'
-- USED BY ACTIVITIES
--   WFSTD.CONTINUEFLOW
--
-- ACTIVITY ATTRIBUTES REFERENCED
--   WAITING_ACTIVITY  - Name of Activity that is waiting
--   WAITING_FLOW      - MASTER or DETAIL
--                       - is waiting activity is in a master or detail flow
procedure ContinueFlow( itemtype   in varchar2,
                        itemkey    in varchar2,
                        actid      in number,
                        funcmode   in varchar2,
                        resultout  in out nocopy varchar2);

-- Loop Counter
--   Count the number of times the activity has been visited.
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - WFSTD_LOOP_COUNTER loookup code
-- ACTIVITY ATTRIBUTES REFERENCED
--   MAX_TIMES
--
procedure LoopCounter(  itemtype   in varchar2,
                        itemkey    in varchar2,
                        actid      in number,
                        funcmode   in varchar2,
                        resultout  in out nocopy varchar2);

-- GetURL
--   Get monitor URL, store in item attribute
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'NULL'
-- ACTIVITY ATTRIBUTES REFERENCED
--   ATTR         - Item attribute to set
--   ADMIN_MODE   - administration mode (Y / N)
procedure GetURL(itemtype  in varchar2,
                 itemkey   in varchar2,
                 actid     in number,
                 funcmode  in varchar2,
                 resultout in out nocopy varchar2);

-- VoteForResultType
--     Standard Voting Function
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   result    -
-- ACTIVITY ATTRIBUTES REFERENCED
--      VOTING_OPTION
--          - WAIT_FOR_ALL_VOTES  - Evaluate voting after all votes are cast
--                                - or a Timeout condition closes the voting
--                                - polls.  When a Timeout occurs the
--                                - voting percentages are calculated as a
--                                - percentage ofvotes cast.
--
--          - REQUIRE_ALL_VOTES   - Evaluate voting after all votes are cast.
--                                - If a Timeout occurs and all votes have not
--                                - been cast then the standard timeout
--                                - transition is taken.  Votes are calculated
--                                - as a percenatage of users notified to vote.
--
--          - TALLY_ON_EVERY_VOTE - Evaluate voting after every vote or a
--                                - Timeout condition closes the voting polls.
--                                - After every vote voting percentages are
--                                - calculated as a percentage of user notified
--                                - to vote.  After a timeout voting
--                                - percentages are calculated as a percentage
--                                - of votes cast.
--
--      "One attribute for each of the activities result type codes"
--
--          - The standard Activity VOTEFORRESULTTYPE has the WFSTD_YES_NO
--          - result type assigned.
--          - Thefore activity has two activity attributes.
--
--                  Y       - Percenatage required for Yes transition
--                  N       - Percentage required for No transition
--
procedure VoteForResultType(    itemtype   in varchar2,
                                itemkey    in varchar2,
                                actid      in number,
                                funcmode   in varchar2,
                                resultout  in out nocopy varchar2);
-- InitializeEventError
--   Called by the  Error Process, this sets up various
--   item attributes.
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'ERROR' or 'WARNING'
procedure InitializeEventError( itemtype   in varchar2,
                                itemkey    in varchar2,
                                actid      in number,
                                funcmode   in varchar2,
                                resultout  out nocopy varchar2);
-- EventDetails
--   PL/SQL Document for Event Attributes
-- IN
--   document_id
--   display_type
--   document
--   document_type
procedure EventDetails   ( document_id   in varchar2,
                           display_type  in varchar2,
                           document      in out nocopy varchar2,
                           document_type in out nocopy varchar2);
-- RetryRaise
--   Called by the  Error Process, raises event
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'NULL'
procedure RetryRaise          ( itemtype in     varchar2,
                                itemkey  in     varchar2,
                                actid    in     number,
                                funcmode in     varchar2,
                                resultout out nocopy    varchar2);
-- GetAgents
--   Gets the Event Subscription Out and To Agent
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'TRUE' and 'FALSE'
procedure GetAgents           ( itemtype in     varchar2,
                                itemkey  in     varchar2,
                                actid    in     number,
                                funcmode in     varchar2,
                                resultout out nocopy   varchar2);
-- GetAckAgent
--   Gets the Acknowledge To Agent based on the Event Message
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'NULL'
procedure GetAckAgent           ( itemtype in     varchar2,
                                itemkey  in     varchar2,
                                actid    in     number,
                                funcmode in     varchar2,
                                resultout out nocopy   varchar2);

-- SubscriptionDetails
--   PL/SQL Document to display subscription parameter details
-- IN
--   document_id
--   display_type
--   document
--   document_type
procedure SubscriptionDetails (document_id   in varchar2,
                               display_type  in varchar2,
                               document      in out nocopy varchar2,
                               document_type in out nocopy varchar2);

-- ErrorDetails
--   PL/SQL Document to display event error details
-- IN
--   document_id
--   display_type
--   document
--   document_type
procedure ErrorDetails (document_id   in varchar2,
                        display_type  in varchar2,
                        document      in out nocopy varchar2,
                        document_type in out nocopy varchar2);

-- Is_WS_Subscription
--   Checks if the current subscription's Action Type is INVOKE_WS_RG
procedure SubscriptionAction(itemtype  in varchar2,
                             itemkey  in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout in out nocopy varchar2);

END WF_STANDARD;

/
