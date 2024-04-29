--------------------------------------------------------
--  DDL for Package Body AP_WEB_ARCHIVE_PURGE_ER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_ARCHIVE_PURGE_ER" AS
/* $Header: apwxprgb.pls 120.0.12010000.3 2009/08/11 15:08:14 rveliche noship $ */

PROCEDURE ArchiveData(p_source_date	IN DATE,
                     p_org_id		IN NUMBER,
		     p_request_id	IN NUMBER) IS


l_debug_info	     VARCHAR2(2000);

BEGIN

 -- Use GT for best performance, insert into select from can be used.

 ---------------------------------------------------------------------
 l_debug_info := 'Insert into the GT table.';
 ---------------------------------------------------------------------
 IF (p_org_id IS NULL) THEN
	 insert into AP_EXP_REPORT_HEADERS_GT
         (report_header_id)
	 (select report_header_id
	 from
	 (
	   select report_header_id
		from ap_expense_report_headers_all
		where source in ('CREDIT CARD', 'SelfService', 'XpenseXpress')
		and trunc(creation_date) < p_source_date
		and expense_status_code = 'PAID'
	   UNION
		-- For Both Pay reports, make sure that the parent report is also paid.
	   select a.report_header_id
		from ap_expense_report_headers_all a,
		     ap_expense_report_headers_all b
		where a.source = 'Both Pay'
		and trunc(a.creation_date) < p_source_date
		and a.expense_status_code = 'PAID'
		and a.bothpay_parent_id = b.report_header_id
		and b.expense_status_code = 'PAID'
		and trunc(b.creation_date) < p_source_date
	 ));
 ELSE
	 insert into AP_EXP_REPORT_HEADERS_GT
         (report_header_id)
	 (select report_header_id
	 from
	 (
	   select report_header_id
		from ap_expense_report_headers_all
		where source in ('CREDIT CARD', 'SelfService', 'XpenseXpress')
		and trunc(creation_date) < p_source_date
		and org_id = p_org_id
		and expense_status_code = 'PAID'
	   UNION
		-- For Both Pay reports, make sure that the parent report is also paid.
	   select a.report_header_id
		from ap_expense_report_headers_all a,
		     ap_expense_report_headers_all b
		where a.source = 'Both Pay'
		and trunc(a.creation_date) < p_source_date
		and a.org_id = p_org_id
		and a.expense_status_code = 'PAID'
		and a.bothpay_parent_id = b.report_header_id
		and b.expense_status_code = 'PAID'
		and trunc(b.creation_date) < p_source_date
	 ));

 END IF;

 -- Insert into Headers
 ---------------------------------------------------------------------
 l_debug_info := 'Insert into Headers.';
 ---------------------------------------------------------------------

 insert into ap_expense_report_headers_arc
                     (select p_request_id arc_req_id, sysdate archive_date,a.*
		      from ap_expense_report_headers_all a, AP_EXP_REPORT_HEADERS_GT gt
		      where gt.report_header_id = a.report_header_id);
 fnd_file.put_line(fnd_file.log,'Archived ' || SQL%ROWCOUNT || ' Headers');

 -- Insert into Lines
 ----------------------------------------------------------------------
 l_debug_info := 'Insert into Lines.';
 ----------------------------------------------------------------------
 insert into ap_expense_report_lines_arc
                     (select p_request_id arc_req_id, sysdate archive_date, a.*
		      from ap_expense_report_lines_all a, AP_EXP_REPORT_HEADERS_GT gt
		      where gt.report_header_id = a.report_header_id);

 fnd_file.put_line(fnd_file.log,'Archived ' || SQL%ROWCOUNT || ' Lines');

 -- Insert into Dists
 ----------------------------------------------------------------------
 l_debug_info := 'Insert into Dists.';
 ----------------------------------------------------------------------

 insert into ap_exp_report_dists_arc
                     (select p_request_id arc_req_id, sysdate archive_date, a.*
		      from ap_exp_report_dists_all a, AP_EXP_REPORT_HEADERS_GT gt
		      where gt.report_header_id = a.report_header_id);

 fnd_file.put_line(fnd_file.log,'Archived ' || SQL%ROWCOUNT || ' Dists');

 -- Insert into CC transactions
 ----------------------------------------------------------------------
 l_debug_info := 'Insert into CC Transactions.';
 ----------------------------------------------------------------------

 insert into ap_credit_card_trxns_arc
                     (select p_request_id arc_req_id, sysdate archive_date, a.*
		      from ap_credit_card_trxns_all a, AP_EXP_REPORT_HEADERS_GT gt
		      where gt.report_header_id = a.report_header_id);

 fnd_file.put_line(fnd_file.log,'Archived ' || SQL%ROWCOUNT || ' CC Transactions');

 ----------------------------------------------------------------------
 l_debug_info := 'Insert into CC Transaction Details.';
 ----------------------------------------------------------------------

 insert into ap_cc_trx_details_arc
                     (select p_request_id arc_req_id, sysdate archive_date, a.*
		      from ap_cc_trx_details a, ap_credit_card_trxns_all b, AP_EXP_REPORT_HEADERS_GT gt
		      where gt.report_header_id = b.report_header_id
		      and a.trx_id = b.trx_id);

 fnd_file.put_line(fnd_file.log,'Archived ' || SQL%ROWCOUNT || ' CC Transaction Details');

 -- Insert into Add On Mileage Rates
 ----------------------------------------------------------------------
 l_debug_info := 'Insert into Add On Mileage Rates.';
 ----------------------------------------------------------------------

 insert into oie_addon_mileage_rates_arc
                     (select p_request_id arc_req_id, sysdate archive_date, a.*
		      from oie_addon_mileage_rates a, AP_EXP_REPORT_HEADERS_GT gt,
		      ap_expense_report_lines_all b
		      where gt.report_header_id = b.report_header_id
		      and a.report_line_id = b.report_line_id);

 fnd_file.put_line(fnd_file.log,'Archived ' || SQL%ROWCOUNT || ' Add On Mileage Rates');

 -- Insert into Perdiem Daily Breakups
 ----------------------------------------------------------------------
 l_debug_info := 'Insert into Perdiem Daily Breakups.';
 ----------------------------------------------------------------------

 insert into oie_pdm_daily_breakups_arc
                     (select p_request_id arc_req_id, sysdate archive_date, a.*
		      from oie_pdm_daily_breakups a, AP_EXP_REPORT_HEADERS_GT gt,
		      ap_expense_report_lines_all b
		      where gt.report_header_id = b.report_header_id
		      and a.report_line_id = b.report_line_id);

 fnd_file.put_line(fnd_file.log,'Archived ' || SQL%ROWCOUNT || ' Perdiem Daily Breakups');

 -- Insert into Perdiem Destinations
 ----------------------------------------------------------------------
 l_debug_info := 'Insert into Perdiem Destinations.';
 ----------------------------------------------------------------------

 insert into oie_pdm_destinations_arc
                     (select p_request_id arc_req_id, sysdate archive_date, a.*
		      from oie_pdm_destinations a, AP_EXP_REPORT_HEADERS_GT gt,
		      ap_expense_report_lines_all b
		      where gt.report_header_id = b.report_header_id
		      and a.report_line_id = b.report_line_id);

 fnd_file.put_line(fnd_file.log,'Archived ' || SQL%ROWCOUNT || ' Perdiem Destinations');

 -- Insert into OIE Attendees
 ----------------------------------------------------------------------
 l_debug_info := 'Insert into OIE Attendees.';
 ----------------------------------------------------------------------

 insert into oie_attendees_arc
                     (select p_request_id arc_req_id, sysdate archive_date, a.*
		      from oie_attendees_all a, AP_EXP_REPORT_HEADERS_GT gt,
		      ap_expense_report_lines_all b
		      where gt.report_header_id = b.report_header_id
		      and a.report_line_id = b.report_line_id);

 fnd_file.put_line(fnd_file.log,'Archived ' || SQL%ROWCOUNT || ' Attendees');

 -- Insert into Audit Reasons
 ----------------------------------------------------------------------
 l_debug_info := 'Insert into Audit Reasons.';
 ----------------------------------------------------------------------

 insert into ap_aud_audit_reasons_arc
                     (select p_request_id arc_req_id, sysdate archive_date, a.*
		      from ap_aud_audit_reasons a, AP_EXP_REPORT_HEADERS_GT gt
		      where gt.report_header_id = a.report_header_id);

 fnd_file.put_line(fnd_file.log,'Archived ' || SQL%ROWCOUNT || ' Audit Reasons');

 -- Insert into Violations
 ----------------------------------------------------------------------
 l_debug_info := 'Insert into Violations.';
 ----------------------------------------------------------------------

 insert into ap_pol_violations_arc
                     (select p_request_id arc_req_id, sysdate archive_date, a.*
		      from ap_pol_violations_all a, AP_EXP_REPORT_HEADERS_GT gt
		      where gt.report_header_id = a.report_header_id);

 fnd_file.put_line(fnd_file.log,'Archived ' || SQL%ROWCOUNT || ' Policy Violations');

 -- Insert into AP Notes
 ----------------------------------------------------------------------
 l_debug_info := 'Insert into AP Notes.';
 ----------------------------------------------------------------------

 insert into ap_notes_arc
                     (select p_request_id arc_req_id, sysdate archive_date, a.*
		      from ap_notes a, AP_EXP_REPORT_HEADERS_GT gt
		      where gt.report_header_id = a.source_object_id);

 fnd_file.put_line(fnd_file.log,'Archived ' || SQL%ROWCOUNT || ' Notes');

EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Exception when archiving data ' || SQLERRM);
    fnd_file.put_line(fnd_file.log,'When Performing ' || l_debug_info);
    RAISE;
END ArchiveData;

PROCEDURE PurgeData(p_request_id		IN    NUMBER,
		    p_purge_wf_attach_flag	IN    VARCHAR2) IS

l_debug_info		VARCHAR2(2000);
CURSOR c_exp_reports(l_request_id IN NUMBER) is
	select report_header_id
	from ap_expense_report_headers_arc
	where arc_req_id = l_request_id;
CURSOR c_exp_report_lines(l_request_id IN NUMBER) is
	select report_line_id
	from ap_expense_report_lines_arc
	where arc_req_id = l_request_id;
l_report_header_id	ap_expense_report_headers_arc.report_header_id%TYPE;
l_report_line_id	ap_expense_report_lines_arc.report_line_id%TYPE;
l_childItemKeySeq       NUMBER;
l_wf_active		BOOLEAN := FALSE;
l_wf_exist		BOOLEAN := FALSE;
l_end_date		wf_items.end_date%TYPE;
l_child_item_key	varchar2(2000);

BEGIN
 -- The where clause in all the delete sqls below make sure that only the records
 -- that were archived in this run are deleted.

 -- Delete AP Notes.
 ----------------------------------------------------------------------
 l_debug_info := 'Delete AP Notes.';
 ----------------------------------------------------------------------

 DELETE FROM ap_notes
 WHERE source_object_id IN (
	SELECT source_object_id
	FROM ap_notes_arc
	WHERE arc_req_id = p_request_id);

 fnd_file.put_line(fnd_file.log,'Purged ' || SQL%ROWCOUNT || ' Notes');

 -- Delete Policy Violations.
 ----------------------------------------------------------------------
 l_debug_info := 'Delete Policy Violations.';
 ----------------------------------------------------------------------

 DELETE FROM ap_pol_violations_all
 WHERE report_header_id IN (
	SELECT report_header_id
	FROM ap_pol_violations_arc
	WHERE arc_req_id = p_request_id);

 fnd_file.put_line(fnd_file.log,'Purged ' || SQL%ROWCOUNT || ' Policy Violations');

 -- Delete Audit reasons.
 ----------------------------------------------------------------------
 l_debug_info := 'Delete Audit reasons.';
 ----------------------------------------------------------------------

 DELETE FROM ap_aud_audit_reasons
 WHERE audit_reason_id IN (
        SELECT audit_reason_id
	FROM ap_aud_audit_reasons_arc
	WHERE arc_req_id = p_request_id);

 fnd_file.put_line(fnd_file.log,'Purged ' || SQL%ROWCOUNT || ' Audit Reasons');

 -- Delete Attendee information
 ----------------------------------------------------------------------
 l_debug_info := 'Delete Attendee information.';
 ----------------------------------------------------------------------

 DELETE FROM oie_attendees_all
 WHERE attendee_line_id IN (
        SELECT attendee_line_id
	FROM oie_attendees_arc
	WHERE arc_req_id = p_request_id);

 fnd_file.put_line(fnd_file.log,'Purged ' || SQL%ROWCOUNT || ' Attendees');

 -- Delete Perdiem destinations
 ----------------------------------------------------------------------
 l_debug_info := 'Delete Perdiem destinations.';
 ----------------------------------------------------------------------

 DELETE FROM oie_pdm_destinations
 WHERE pdm_destination_id IN (
        SELECT pdm_destination_id
	FROM oie_pdm_destinations_arc
	WHERE arc_req_id = p_request_id);

 fnd_file.put_line(fnd_file.log,'Purged ' || SQL%ROWCOUNT || ' Perdiem Destinations');

 -- Delete Perdiem Daily Beakups.
 ----------------------------------------------------------------------
 l_debug_info := 'Delete Perdiem Daily Beakups.';
 ----------------------------------------------------------------------

 DELETE FROM oie_pdm_daily_breakups
 WHERE pdm_daily_breakup_id IN (
        SELECT pdm_daily_breakup_id
	FROM oie_pdm_daily_breakups_arc
	WHERE arc_req_id = p_request_id);

 fnd_file.put_line(fnd_file.log,'Purged ' || SQL%ROWCOUNT || ' Perdiem Daily Breakups');

 -- Delete Add On Mileage rates.
 ----------------------------------------------------------------------
 l_debug_info := 'Delete Add On Mileage rates.';
 ----------------------------------------------------------------------

 DELETE FROM oie_addon_mileage_rates
 WHERE report_line_id IN (
        SELECT report_line_id
	FROM oie_addon_mileage_rates_arc
	WHERE arc_req_id = p_request_id);

 fnd_file.put_line(fnd_file.log,'Purged ' || SQL%ROWCOUNT || ' Add On Mileage Rates');

 -- Delete CC transactions.
 ----------------------------------------------------------------------
 l_debug_info := 'Delete CC Transaction Details.';
 ----------------------------------------------------------------------

 DELETE FROM ap_cc_trx_details
 WHERE trx_detail_id IN (
        SELECT trx_detail_id
	FROM ap_cc_trx_details_arc
	WHERE arc_req_id = p_request_id);

 fnd_file.put_line(fnd_file.log,'Purged ' || SQL%ROWCOUNT || ' CC Transaction Details');

 -- Delete CC transactions.
 ----------------------------------------------------------------------
 l_debug_info := 'Delete CC Transactions.';
 ----------------------------------------------------------------------

 DELETE FROM ap_credit_card_trxns_all
 WHERE report_header_id IN (
        SELECT report_header_id
	FROM ap_credit_card_trxns_arc
	WHERE arc_req_id = p_request_id);

 fnd_file.put_line(fnd_file.log,'Purged ' || SQL%ROWCOUNT || ' CC Transactions');

 -- Delete Distributions.
 ----------------------------------------------------------------------
 l_debug_info := 'Delete Distributions.';
 ----------------------------------------------------------------------

 DELETE FROM ap_exp_report_dists_all
 WHERE report_distribution_id IN (
        SELECT report_distribution_id
	FROM ap_exp_report_dists_arc
	WHERE arc_req_id = p_request_id);

 fnd_file.put_line(fnd_file.log,'Purged ' || SQL%ROWCOUNT || ' Dists');

 -- Delete Lines.
 ----------------------------------------------------------------------
 l_debug_info := 'Delete Lines.';
 ----------------------------------------------------------------------

 DELETE FROM ap_expense_report_lines_all
 WHERE report_line_id IN (
        SELECT report_line_id
	FROM ap_expense_report_lines_arc
	WHERE arc_req_id = p_request_id);

 fnd_file.put_line(fnd_file.log,'Purged ' || SQL%ROWCOUNT || ' Lines');

 -- Delete Headers.
 ----------------------------------------------------------------------
 l_debug_info := 'Delete Headers.';
 ----------------------------------------------------------------------

 DELETE FROM ap_expense_report_headers_all
 WHERE report_header_id IN (
        SELECT report_header_id
	FROM ap_expense_report_headers_arc
	WHERE arc_req_id = p_request_id);

 fnd_file.put_line(fnd_file.log,'Purged ' || SQL%ROWCOUNT || ' Headers');

 -- Purge Workflow.
 ----------------------------------------------------------------------
 l_debug_info := 'Purge Workflow.';
 ----------------------------------------------------------------------
 IF (p_purge_wf_attach_flag ='Y') THEN

	fnd_file.put_line(fnd_file.log,'Purging Workflow and Attachments');

	-- Delete Line Attachments
	open c_exp_report_lines(p_request_id);
	LOOP
		fetch c_exp_report_lines into l_report_line_id;
		exit when c_exp_report_lines%NOTFOUND;
		l_debug_info := 'Delete Line Attachements for report Line ' || to_char(l_report_line_id);
		FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(
				   X_entity_name => 'OIE_LINE_ATTACHMENTS',
				   X_pk1_value => to_char(l_report_line_id),
				   X_delete_document_flag => 'N');

	END LOOP;
	open c_exp_reports(p_request_id);
	LOOP
		fetch c_exp_reports into l_report_header_id;
		exit when c_exp_reports%NOTFOUND;

		begin
			select   end_date
			into     l_end_date
			from     wf_items
			where    item_type = 'APEXP'
			and      item_key  = to_char(l_report_header_id);
			if l_end_date is NULL then
				l_wf_active := TRUE;
			else
				l_wf_active := FALSE;
			end if;
			l_wf_exist  := TRUE;
		exception
			when no_data_found then
				l_wf_active := FALSE;
				l_wf_exist  := FALSE;
		end;
		IF l_wf_exist THEN
			fnd_file.put_line(fnd_file.log,'Purging Workflow');
			-- Abort the parent workflow if active
			IF l_wf_active THEN
				l_debug_info := 'WF Exists, abort process';
				fnd_file.put_line(fnd_file.log,'Abort Existing Workflow');
				wf_engine.AbortProcess (itemtype => 'APEXP',
						itemkey  => to_char(l_report_header_id),
						cascade  => TRUE);
			END IF;

			l_debug_info := 'Purge WF for report ' || to_char(l_report_header_id);
			-- Check the child item keys
			begin
			  l_childItemKeySeq := WF_ENGINE.GetItemAttrNumber('APEXP',
							 l_report_header_id,
							 'AME_CHILD_ITEM_KEY_SEQ');
			exception
			  when others then
			     if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
				l_childItemKeySeq := 0;
			     else
				raise;
			     end if;
			end;

			l_debug_info := 'Purge Child Workflow, Child Item Count ' || l_childItemKeySeq;

			IF (l_childItemKeySeq IS NOT NULL AND l_childItemKeySeq > 0) THEN
				FOR i in 1 .. l_childItemKeySeq LOOP
					l_child_item_key := to_char(l_report_header_id) || '-' || to_char(i);
					begin
						select   end_date
						into     l_end_date
						from     wf_items
						where    item_type = 'APEXP'
						and      item_key  = l_child_item_key;
						if l_end_date is NULL then
							l_wf_active := TRUE;
						else
							l_wf_active := FALSE;
						end if;
						l_wf_exist  := TRUE;
					exception
						when no_data_found then
							l_wf_active := FALSE;
							l_wf_exist  := FALSE;
					end;
					IF (l_wf_exist) THEN
						-- Abort the child workflow if active
						IF l_wf_active THEN
							l_debug_info := 'WF Exists, abort process';
							fnd_file.put_line(fnd_file.log,'Abort Existing Workflow');
							wf_engine.AbortProcess (itemtype => 'APEXP',
									itemkey  => l_child_item_key,
									cascade  => TRUE);
						END IF;
						wf_purge.Items(itemtype => 'APEXP',
							itemkey  => l_child_item_key);

						wf_purge.TotalPerm(itemtype => 'APEXP',
							itemkey  => l_child_item_key,
							runtimeonly => TRUE);
					END IF;
				END LOOP;
			END IF;

			l_debug_info := 'Purge Parent Workflow.';
			wf_purge.Items(itemtype => 'APEXP',
					itemkey  => to_char(l_report_header_id));

			wf_purge.TotalPerm(itemtype => 'APEXP',
					itemkey  => to_char(l_report_header_id),
					runtimeonly => TRUE);
		END IF;
		l_debug_info := 'Delete Header Attachements for report ' || to_char(l_report_header_id);
		FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(
				   X_entity_name => 'OIE_HEADER_ATTACHMENTS',
				   X_pk1_value => to_char(l_report_header_id),
				   X_delete_document_flag => 'N');

	END LOOP;
	fnd_file.put_line(fnd_file.log,'Purged Workflow and Attachments');
 END IF;


EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Exception when purging data ' || SQLERRM);
    fnd_file.put_line(fnd_file.log,'When Performing ' || l_debug_info);
    RAISE;
END PurgeData;

PROCEDURE RunProgram(errbuf          		OUT NOCOPY VARCHAR2,
                     retcode         		OUT NOCOPY NUMBER,
                     p_org_id                   IN NUMBER DEFAULT NULL,
		     p_source_date		IN VARCHAR2,
		     p_purge_wf_attach_flag	IN VARCHAR2) IS

l_request_id         NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
l_source_date	     DATE;
l_count		     NUMBER;
BEGIN
  -- p_source_date is a required parameter, no need to check for null.
  l_source_date := fnd_date.canonical_to_date(p_source_date);

  fnd_file.put_line(fnd_file.log, '=================================================================');
  fnd_file.put_line(fnd_file.log, 'Archive and Purge Parameters');
  fnd_file.put_line(fnd_file.log, '=================================================================');
  fnd_file.put_line(fnd_file.log, 'Request Id: ' || l_request_id);
  fnd_file.put_line(fnd_file.log, 'Source Date: ' || l_source_date);
  fnd_file.put_line(fnd_file.log, 'Purge WF and Attachments: ' || p_purge_wf_attach_flag);
  IF (p_org_id IS NULL) THEN
    fnd_file.put_line(fnd_file.log, 'Operating Unit: ' || 'Processing all operating units');
  ELSE
    fnd_file.put_line(fnd_file.log, 'Operating Unit: ' || p_org_id);
  END IF;
  fnd_file.put_line(fnd_file.log, '=================================================================');

  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, ' ');

  fnd_file.put_line(fnd_file.log, '=================================================================');
  fnd_file.put_line(fnd_file.log, 'Archiving the selected Expense Reports');
  fnd_file.put_line(fnd_file.log, '=================================================================');

  -- Archive the data.
  ArchiveData(l_source_date, p_org_id, l_request_id);

  fnd_file.put_line(fnd_file.log, '=================================================================');
  fnd_file.put_line(fnd_file.log, 'Archive Complete');
  fnd_file.put_line(fnd_file.log, '=================================================================');

  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, ' ');

  fnd_file.put_line(fnd_file.log, '=================================================================');
  fnd_file.put_line(fnd_file.log, 'Purging the selected Expense Reports');
  fnd_file.put_line(fnd_file.log, '=================================================================');

  -- Purge the data.
  PurgeData(l_request_id, p_purge_wf_attach_flag);

  fnd_file.put_line(fnd_file.log, '=================================================================');
  fnd_file.put_line(fnd_file.log, 'Purge Complete');
  fnd_file.put_line(fnd_file.log, '=================================================================');

  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, ' ');

  select count(*) into l_count from AP_EXP_REPORT_HEADERS_GT;

  fnd_file.put_line(fnd_file.log, '=================================================================');
  fnd_file.put_line(fnd_file.log, 'Total Expenses processed: ' || l_count);
  fnd_file.put_line(fnd_file.log, '=================================================================');

  delete from AP_EXP_REPORT_HEADERS_GT;

  fnd_file.put_line(fnd_file.log, '=================================================================');
  fnd_file.put_line(fnd_file.log, 'Cleared Temp Contents');
  fnd_file.put_line(fnd_file.log, '=================================================================');

  commit;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END RunProgram;


END AP_WEB_ARCHIVE_PURGE_ER;

/
