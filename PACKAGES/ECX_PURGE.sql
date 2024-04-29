--------------------------------------------------------
--  DDL for Package ECX_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_PURGE" AUTHID CURRENT_USER as
/* $Header: ECXPRGS.pls 120.2.12010000.2 2008/08/22 20:01:48 cpeixoto ship $*/
-- Commit Frequency: Default - commit every 500 records.
-- This variable can be changed as needed to control rollback segment
-- growth against performance.
--
commit_frequency number := wf_purge.commit_frequency;
commit_frequency_ecx  number:=500;
--
-- procedure PURGE
--   Delete records from ecx_outbound_logs which don't have item_type, item_key
--	(To delete records which don't have an entry in ecx_doclogs)
-- IN:
--   transaction_type - transaction type to delete, or null for all transaction type
--   transaction_subtype - transaction subtype to delete, or null for all transaction subtype
--   party_id - party id to delete, or null for all party id
--   party_site_id - party site id to delete, or null for all party site id
--   fromdate - from Date or null to start from begining
--   todate - end Date or null to delete till latest record
--   commitFlag- Do not commit if set to false
--
procedure PURGE_OUTBOUND(transaction_type in varchar2 default null,
		transaction_subtype in varchar2 default null,
		party_id in varchar2 default null,
		party_site_id in varchar2 default null,
		fromDate in date default null,
		toDate in date default null,
		commitFlag in boolean default true);

--
-- procedure PURGE
--   Delete ecxlog from given criteria.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   transaction_type - transaction type to delete, or null for all transaction type
--   transaction_subtype - transaction subtype to delete, or null for all transaction subtype
--   party_id - party id to delete, or null for all party id
--   party_site_id - party site id to delete, or null for all party site id
--   fromdate - from Date or null to start from begining
--   todate - end Date or null to delete till latest record
--   docommit- Do not commit if set to false
--   runtimeonly - Delete data which is associated with workflow, if set to true
--

procedure PURGE(item_type in varchar2 default null,
		item_key in varchar2 default null,
		transaction_type in varchar2 default null,
		transaction_subtype in varchar2 default null,
		party_id in varchar2 default null,
		party_site_id in varchar2 default null,
		fromDate in date default null,
		toDate in date default null,
		commitFlag in boolean default true,
		runtimeonly in boolean default false);
--
-- procedure Items
--   Delete items with end_time before argument.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   enddate - Date to obsolete to
--   docommit- Do not commit if set to false

procedure PURGE_ITEMS(itemType in varchar2 default null,
		itemKey in varchar2 default null,
		endDate	in date default null,
		docommit in boolean default true,
		runtimeonly in boolean default false);
-- procedure Purge_Transactions
--This procedure has been incorporated to make the CP for purging obsolete ECX data.
--Delete log details wihin the stipulated date range.
-- IN:
-- transaction_type - Transaction type to delete, or null for all transaction types
-- transaction_subtype - Transaction subtype to delete, or null for all subtypes
-- fromdate - Date from which the data to delete.
-- todate  - Date upto which data has to delete.
-- docommit- Do not commit if set to false.

procedure PURGE_TRANSACTIONS(
                transaction_type in varchar2 default null,
                transaction_subtype in varchar2 default null,
                fromdate in date default null,
                todate in date default null,
		docommit in boolean default true);
--
--Procedure  TotalConcurrent
--   This wil be called from CP to purge obsolete ECX data.
-- IN:
--   errbuf - CPM error message
--   retcode - CPM return code (0 = success, 1 = warning, 2 = error)
--   transactiontype - Transaction type to delete, or null for all transactiontype
--   transactionsubtype - Transaction subtype to delete, or null for all transaction subtype.
--  fromdate - Date from which the data to delete.
-- todate  - Date upto which data has to delete.
-- x_commit_frequency - The freq. at which commit will take place during deletion.
procedure TotalConcurrent(
  errbuf out NOCOPY varchar2,
  retcode out NOCOPY varchar2,
  transaction_type in varchar2 default null,
  transaction_subtype in varchar2 default null,
  fromdate in date default null,
  todate  in date  default null,
  x_commit_frequency  in number default 500
  );
end ECX_PURGE;

/
