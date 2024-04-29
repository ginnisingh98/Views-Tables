--------------------------------------------------------
--  DDL for Package AME_UTIL2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_UTIL2" AUTHID CURRENT_USER as
/* $Header: ameoutil2.pkh 120.8.12010000.2 2009/03/11 11:34:35 prasashe ship $ */
  /* user-defined data types */
  /* Record to store WF notification details */
  type notificationRecord is record(
     notification_id        number,
     user_comments          varchar2(4000));
  type notificationTable is table of notificationRecord index by binary_integer;
  /*
    None of the empty[whatever] variables below should ever be overwritten. They
    are only to be used as default arguments where empty defaults are required.
  */
  emptyNotificationRecord notificationRecord;
  emptyNotificationTable notificationTable;
  /* valid values for engStApprovalProcessCompleteYN as per bug (4411016) */
  completeFullyApproved     constant varchar2(1) := ame_util.booleanTrue;
  completeFullyRejected     constant varchar2(1) := ame_util.booleanFalse;
  completePartiallyApproved constant varchar2(1) := 'P';
  completeNoApprovers       constant varchar2(1) := 'X';
  notCompleted              constant varchar2(1) := 'W';
  --+
  -- Added new constants for Item Class and Item Id bind variables
  --+
  itemIdPlaceHolder       constant varchar2(10) := 'itemId';
  itemClassPlaceHolder    constant varchar2(10) := 'itemClass';
  type insertionRecord3 is record(
    position integer,
    item_class ame_item_classes.name%type,
    item_id ame_temp_old_approver_lists.item_id%type,
    action_type_id integer,
    group_or_chain_id integer,
    order_type varchar2(50),
    parameter ame_temp_insertions.parameter%type,
    api_insertion varchar2(1),
    authority varchar2(1),
    description ame_temp_insertions.description%type);
  type insertionsTable3 is table of insertionRecord3 index by binary_integer;
  reassignStatus constant varchar2(20) := 'REASSIGN';
  noResponseByRepeatedStatus constant varchar2(20) := 'NORESPONSEBYREPEATED';
  forwardByRepeatedStatus constant varchar2(20) := 'FORWARDBYREPEATED';
  --+
  -- Added constants for bug 4700160
  --+
  attributeObject          constant varchar2(10) := 'ATTRIBUTE';
  actionTypeObject         constant varchar2(10) := 'ACTION';
  approverGroupObject      constant varchar2(10) := 'GROUP';
  itemClassObject          constant varchar2(10) := 'ITEMCLASS';
  specialObject            constant varchar2(20) := 'SPECIALATTRIBUTE';
  --+
  detailedApprovalStatusFlagYN   varchar2(1)  := ame_util.booleanFalse;
  --+
  type productionRecord is record(
       item_class     ame_item_classes.name%type
      ,item_id        ame_temp_old_approver_lists.item_id%type
      ,variable_name  ame_actions.parameter%type
      ,variable_value ame_actions.parameter_two%type);
  --+
  type productionsTable is table of productionRecord index by binary_integer;
  --+
end ame_util2;

/
