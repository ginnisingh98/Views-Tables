--------------------------------------------------------
--  DDL for Package AME_APPROVER_DEVIATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVER_DEVIATION_PKG" AUTHID CURRENT_USER as
/* $Header: ameaprdv.pkh 120.4 2008/01/09 07:52:05 prasashe noship $ */
/*report related attributes*/
P_APPLICATION number;
P_AMEAPPLID number;
P_TXNTYPEID varchar2(100);
P_STARTDATE date;
P_ENDDATE date;
P_REASON varchar2(100);
TEMP_APPLID number;
TEMP_REASON varchar2(50);
/*deviattion related attributes*/
insertReason constant varchar2(20) := 'INSERT';
suppressReason constant varchar2(20) := 'SUPPRESS';
forwardReason constant varchar2(20) := 'FORWARDEE';
timeoutReason constant varchar2(20) := 'SURROGATE';
firstauthReason constant varchar2(20) := 'FIRSTAUTH';
firstauthHandlerInsReason constant varchar2(20) := 'FIRSTAUTHHANDLERINS';
forwarHandlerAuthInsReason constant varchar2(25) := 'FORWARDHANDLERAUTHINS';
reassignStatus constant varchar2(20) := 'REASSIGN';
forwardForwardeeReason constant varchar2(20) := 'FORWARDERREPEAT';
forwardEngInsReason constant varchar2(20) := 'FORWARDENGINS';
forwardRemandReason constant varchar2(20) :='FORWARDREMAND';
/*deviation related attributes*/
transactionDescription constant varchar2(50) := 'TRANSACTION_DESCRIPTION';
  type deviationRecord is record(
      reason varchar2(100)
     ,effectiveDate date);
  type deviationReasonList is table of deviationRecord index by binary_integer;
procedure updateDeviationState( applicationIdIn in number
                            ,tranasactionIdIn in varchar2
                            ,deviationListIn in deviationReasonList
                            ,approvalProcessCompleteYNIn in varchar2
                            ,finalapproverListIn in ame_util.approversTable2);
procedure clearDeviationState( applicationIdIn in number
                              ,transactionIdIn in varchar2 );
function getreasonDescription(reasonIn in varchar2) return varchar2;
function validateDate return boolean;
function getApplicationName return varchar2;
function gettxntype return varchar2;
function getStartDateParam return varchar2;
function getEndDateParam return varchar2;
end ame_approver_deviation_pkg;

/
