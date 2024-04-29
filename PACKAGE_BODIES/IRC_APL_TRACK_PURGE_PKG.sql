--------------------------------------------------------
--  DDL for Package Body IRC_APL_TRACK_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_APL_TRACK_PURGE_PKG" as
/* $Header: ircapltrackpurge.pkb 120.0.12000000.1 2007/03/26 13:02:33 vboggava noship $ */
-- Package variables
--
g_package  varchar2(33) := 'irc_apl_track_purge_pkg.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< print_log_msg >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure print_log_msg
(
  p_print_process in varchar2
) is
  l_header	varchar2(500);
  l_underline	varchar2(500);
begin

	if p_print_process = 'APL' then
	begin
		l_header :=   rpad('SNAPSHOT_ID',20)||'  '||
			      rpad('PERSON_ID',10);
		--
		l_underline := rpad('-',20,'-')||'  '||
			       rpad('-',10,'-');
		--
		fnd_file.put_line(fnd_file.log, 'call to delete Applicant Profile Snapshot');
		fnd_file.put_line(fnd_file.log, 'List of Applicant Profile Snapshots deleted');
		--
		fnd_file.put_line(fnd_file.log,l_header);
		fnd_file.put_line(fnd_file.log,l_underline);
		--
	end;
	elsif p_print_process = 'DOC' then
	begin
		l_underline := rpad('-',75,'-');
		fnd_file.put_line(fnd_file.log,l_underline);
		--
		l_header :=   rpad('DOCUMENT_ID',20)||'  '||
			      rpad('PERSON_ID',10);
		--
		l_underline := rpad('-',20,'-')||'  '||
			       rpad('-',10,'-');
		--
		fnd_file.put_line(fnd_file.log, 'call to delete Applicant Document Snapshot');
		fnd_file.put_line(fnd_file.log, 'List of Applicant Document Snapshots deleted');
		--
		fnd_file.put_line(fnd_file.log,l_header);
		fnd_file.put_line(fnd_file.log,l_underline);
		--
	end;
	elsif p_print_process = 'SRC' then
	begin
		l_underline := rpad('-',75,'-');
		fnd_file.put_line(fnd_file.log,l_underline);
		--
		l_header :=   rpad('SAVED_SEARCH_CRITERIA_ID',30)||'  '||
			      rpad('VACANCY_ID',10);
		--
		l_underline := rpad('-',30,'-')||'  '||
			       rpad('-',10,'-');
		--
		fnd_file.put_line(fnd_file.log, 'call to delete Saved Search Criteria');
		fnd_file.put_line(fnd_file.log, 'List of Saved Search Criteria deleted');
		--
		fnd_file.put_line(fnd_file.log,l_header);
		fnd_file.put_line(fnd_file.log,l_underline);
		--
	end;
	elsif p_print_process = 'ACC' then
	begin
		l_underline := rpad('-',75,'-');
		fnd_file.put_line(fnd_file.log,l_underline);
		--
		l_header :=   rpad('APL_PROFILE_ACCESS_ID',30)||'  '||
			       rpad('PERSON_ID',10);
		--
		l_underline := rpad('-',30,'-')||'  '||
			       rpad('-',10,'-');
		--
		fnd_file.put_line(fnd_file.log, 'call to delete Applicant Profile Access');
		fnd_file.put_line(fnd_file.log, 'List of Applicant Profile Access deleted');
		--
		fnd_file.put_line(fnd_file.log,l_header);
		fnd_file.put_line(fnd_file.log,l_underline);
		--
	end;
	end if;

end print_log_msg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< purge_records >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure purge_records
(
  p_months in Number
) is
--
  l_proc varchar2(72) := g_package ||'purge_records';
  l_effective_date   date := sysdate;
  l_print_info	varchar2(32000);
  l_doc_purge	     varchar2(10) := 'Y';
--
  cursor csr_apl_profile_snapshot  is
  select aps.profile_snapshot_id, aps.person_id, aps.object_version_number
  from	 irc_apl_profile_snapshots  aps
  where	months_between(sysdate,aps.creation_date) > p_months;
  --
  cursor csr_apl_doc_snapshot	is
  select doc.document_id, doc.type,
	 doc.person_id, doc.party_id, doc.end_date,
	 doc.object_version_number
  from	 irc_documents	doc
  where	doc.end_date	is not null
  and   months_between(sysdate,doc.end_date) > p_months;
  --
  cursor csr_saved_search_criteria is
  select iss.saved_search_criteria_id,
	 iss.vacancy_id, iss.object_version_number
  from	 irc_saved_search_criteria  iss
  where  months_between(sysdate,iss.creation_date) > p_months;
  --
  cursor csr_apl_profile_access is
  select apa.apl_profile_access_id,
         apa.person_id,
	 apa.object_version_number
  from	 irc_apl_profile_access  apa
  where  months_between(sysdate,apa.creation_date) > p_months;
  --
--
begin
--
  hr_utility.set_location('Entering Purge Records:'||l_proc, 10);
  hr_utility.set_location('Delete Applicant Profile Snapshot:'||l_proc, 20);



  --To Print the Log For the Applicant Profile Snapshot deletion
  irc_apl_track_purge_pkg.print_log_msg(p_print_process => 'APL');
  --

  For rec_apl_profile_snapshot In csr_apl_profile_snapshot Loop
	irc_apl_prfl_snapshots_api.delete_applicant_snapshot
	( p_effective_date		=> l_effective_date
	 ,p_person_id			=> rec_apl_profile_snapshot.person_id
	 ,p_profile_snapshot_id		=> rec_apl_profile_snapshot.profile_snapshot_id
	 ,p_object_version_number	=> rec_apl_profile_snapshot.object_version_number
	);
	--
	hr_utility.set_location('Print Delete Snapshot:'||l_proc,25);
	l_print_info := rpad(nvl(to_char(rec_apl_profile_snapshot.profile_snapshot_id),' '),20) ||
	                rpad(nvl(to_char(rec_apl_profile_snapshot.person_id),' '),10);
	--
	fnd_file.put_line(fnd_file.log,l_print_info);

  End loop;
  --

  hr_utility.set_location('Delete Applicant Document Snapshot:'||l_proc, 30);

  --To Print the Log For the Document Snapshot deletion
  irc_apl_track_purge_pkg.print_log_msg(p_print_process => 'DOC');
  --

  For rec_apl_doc_snapshot In csr_apl_doc_snapshot Loop
	irc_document_api.delete_document
	( p_effective_date		=> l_effective_date
	 ,p_document_id			=> rec_apl_doc_snapshot.document_id
	 ,p_object_version_number	=> rec_apl_doc_snapshot.object_version_number
	 ,p_person_id			=> rec_apl_doc_snapshot.person_id
	 ,p_party_id			=> rec_apl_doc_snapshot.party_id
	 ,p_end_date			=> rec_apl_doc_snapshot.end_date
	 ,p_type			=> rec_apl_doc_snapshot.type
	 ,p_purge			=> l_doc_purge
	);
	--
	hr_utility.set_location('Print Delete Document:'||l_proc,35);
	l_print_info := rpad(nvl(to_char(rec_apl_doc_snapshot.document_id),' '),20) ||
	                rpad(nvl(to_char(rec_apl_doc_snapshot.person_id),' '),10);
	--
	fnd_file.put_line(fnd_file.log,l_print_info);
  End loop;
  --

  hr_utility.set_location('Delete Saved Search Criteria:'||l_proc, 40);

  --To Print the Log For the Saved Search Criteria deletion
  irc_apl_track_purge_pkg.print_log_msg(p_print_process => 'SRC');
  --

  For rec_saved_search_criteria In csr_saved_search_criteria Loop
	irc_saved_search_criteria_api.delete_search_criteria
	( p_vacancy_id			=> rec_saved_search_criteria.vacancy_id
	 ,p_saved_search_criteria_id	=> rec_saved_search_criteria.saved_search_criteria_id
	 ,p_object_version_number	=> rec_saved_search_criteria.object_version_number
	 );
	--
	hr_utility.set_location('Print Delete Search Criteria:'||l_proc,45);
	l_print_info := rpad(nvl(to_char(rec_saved_search_criteria.saved_search_criteria_id),' '),30) ||
	                rpad(nvl(to_char(rec_saved_search_criteria.vacancy_id),' '),10);
	--
	fnd_file.put_line(fnd_file.log,l_print_info);
  End loop;
  --

  hr_utility.set_location('Delete Applicant Profile Access:'||l_proc, 50);

  --To Print the Log For the Applicant Profile Access deletion
  irc_apl_track_purge_pkg.print_log_msg(p_print_process => 'ACC');
  --

  For rec_apl_profile_access In csr_apl_profile_access Loop
	irc_apl_profile_access_api.delete_apl_profile_access
	( p_person_id		   => rec_apl_profile_access.person_id
	 ,p_apl_profile_access_id  => rec_apl_profile_access.apl_profile_access_id
         ,p_object_version_number  => rec_apl_profile_access.object_version_number
	);
	--
	hr_utility.set_location('Print Delete PROFILE ACCESS:'||l_proc,55);
	l_print_info := rpad(nvl(to_char(rec_apl_profile_access.apl_profile_access_id),' '),30) ||
	                rpad(nvl(to_char(rec_apl_profile_access.person_id),' '),10);
	--
	fnd_file.put_line(fnd_file.log,l_print_info);
  End loop;
  --

  hr_utility.set_location('Leaving Purge Records:'||l_proc, 100);

end purge_records;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< purge_record_process >------------------------|
-- ----------------------------------------------------------------------------
--
procedure purge_record_process (errbuf  out nocopy varchar2
                               ,retcode out nocopy varchar2
                               ,p_months         in number) is
--
  l_proc varchar2(72) := g_package ||'purge_record_process';
  --
begin
--
  hr_utility.set_location('Entering Purge Record Process:'||l_proc, 10);
  --
  irc_apl_track_purge_pkg.purge_records
  (p_months         => p_months
  );
  --
  retcode := 0;
  --
  hr_utility.set_location('Leaving Purge Record Process:'||l_proc, 70);

exception
  when others then
--
    hr_utility.set_location('Leaving Purge Record Process:'||l_proc, 80);
    rollback;
    --
    -- Set the return parameters to indicate failure
    --
    errbuf := sqlerrm;
    retcode := 2;
--
end purge_record_process;
--

end irc_apl_track_purge_pkg;

/
