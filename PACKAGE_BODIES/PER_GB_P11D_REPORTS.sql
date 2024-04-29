--------------------------------------------------------
--  DDL for Package Body PER_GB_P11D_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GB_P11D_REPORTS" AS
/* $Header: pegbp11d.pkb 120.0 2005/05/31 09:12:53 appldev noship $ */
/*
 Change List
 -----------
   Date        Name          Vers     Bug No   Description
   +-----------+-------------+--------+-------+-----------------------+
   03-Jan-2003  Bhaskar       115.0            (Initial)
   20-FEB-2003  Bhaskar       115.1    2765216 Added parameter
                                               P_PRINT_ADDRESS_PAGE
   09-FEB-2004  Abeesh	      115.3    3201848 Modified function
						submit_gaps_report to print
						gap and overlap report for 2004
   06-DEC-2004  Kthampan      115.6            Modified function
                                               submit_gaps_report to call
                                               report for 2005
   06-DEC-2004  Kthampan      115.7            Revert the change made in version 6
                                               because there should be no
                                               new 6i based reports.
*/
-- For Year 2002
p_p11d_main_report_2002          varchar2(100) := 'PER_GB_P11D_REPORT_2002';
p_p11d_gaps_report_2002          varchar2(100) := 'PERGBGAP_REPORT_2002';
-- For Year 2003
p_p11d_main_report_2003          varchar2(100) := 'PER_GB_P11D_REPORT_2003';
p_p11d_gaps_report_2003          varchar2(100) := 'PERGBGAP_REPORT_2003';
--
--For Year 2004
/*Bug No. 3201848*/
p_p11d_gaps_report_2004          varchar2(100) := 'PERGBGAP_REPORT_2004';

--For Year 2005
/* no new 6i report
p_p11d_gaps_report_2005          varchar2(100) := 'PERGBGAP_REPORT_2005';
*/

procedure submit_main_report(errbuf                  OUT NOCOPY varchar2
                            ,retcode                 OUT NOCOPY number
                            ,P_PRINT_ADDRESS_PAGE    in         varchar2
                            ,P_PRINT_P11D            in         varchar2
                            ,P_PRINT_P11D_SUMMARY    in         varchar2
                            ,P_PRINT_WS              in         varchar2
                            ,P_PAYROLL_ACTION_ID     in         varchar2
                            ,P_ORGANIZATION_ID       in         varchar2
                            ,P_ORG_HIERARCHY         in         varchar2
                            ,P_ASSIGNMENT_SET_ID     in         varchar2
                            ,P_LOCATION_CODE         in         varchar2
                            ,P_ASSIGNMENT_ACTION_ID  in         varchar2
                            ,P_BUSINESS_GROUP_ID     in         varchar2
                            ,P_SORT_ORDER1           in         varchar2
                            ,P_SORT_ORDER2           in         varchar2
                            ) is
  l_p11d_main_request_id number;
  --
  cursor csr_ben_end_date is
  select effective_date benefit_end_date
  from pay_payroll_actions
  where payroll_action_id = to_number(p_payroll_action_id);
  --
  l_ben_end_date date;
  l_report_name  varchar2(100);
begin
  open  csr_ben_end_date;
  fetch csr_ben_end_date into l_ben_end_date;
  close csr_ben_end_date;
  --
  if fnd_date.canonical_to_date(fnd_date.string_to_canonical(l_ben_end_date,'dd-mon-rrrr')) >= fnd_date.canonical_to_date('2002/04/06') then
    l_report_name := p_p11d_main_report_2003;
  else
    l_report_name := p_p11d_main_report_2002;
  end if;
  --
    l_p11d_main_request_id := fnd_request.submit_request
                                (application => 'PER'
                                ,program     => l_report_name
                                ,argument1   => P_PRINT_ADDRESS_PAGE
                                ,argument2   => P_PRINT_P11D
                                ,argument3   => P_PRINT_P11D_SUMMARY
                                ,argument4   => P_PRINT_WS
                                ,argument5   => P_PAYROLL_ACTION_ID
                                ,argument6   => P_ORGANIZATION_ID
                                ,argument7   => P_ORG_HIERARCHY
                                ,argument8   => P_ASSIGNMENT_SET_ID
                                ,argument9   => P_LOCATION_CODE
                                ,argument10  => P_ASSIGNMENT_ACTION_ID
                                ,argument11  => P_BUSINESS_GROUP_ID
                                ,argument12  => P_SORT_ORDER1
                                ,argument13  => P_SORT_ORDER2);
  --
  retcode := 0;
exception
  when others then
    retcode := 1;
end submit_main_report;
--
procedure submit_gaps_report(ERRBUF                      OUT NOCOPY VARCHAR2
                            ,RETCODE                     OUT NOCOPY NUMBER
                            ,P_BENEFIT_START_DATE_CN     IN         VARCHAR2
                            ,P_BENEFIT_START_DATE        IN         VARCHAR2
                            ,P_BENEFIT_END_DATE_CN       IN         VARCHAR2
                            ,P_BENEFIT_END_DATE          IN         VARCHAR2
                            ,P_BENEFIT_TYPE_ID           IN         VARCHAR2
                            ,P_BENEFIT_TYPE              IN         VARCHAR2
                            ,P_OVERLAP                   IN         VARCHAR2
                            ,P_GAP                       IN         VARCHAR2
                            ,P_PAYROLL_ID                IN         VARCHAR2
                            ,P_PAYROLL                   IN         VARCHAR2
                            ,P_PERSON_ID                 IN         VARCHAR2
                            ,P_PERSON                    IN         VARCHAR2
                            ,P_TAX_DISTRICT_REFERENCE_ID IN         VARCHAR2
                            ,P_TAX_DISTRICT_REFERENCE    IN         VARCHAR2
                            ,P_CONSOLIDATION_SET_ID      IN         VARCHAR2
                            ,P_CONSOLIDATION_SET         IN         VARCHAR2
                            ,P_ASSIGNMENT_SET_ID         IN         VARCHAR2
                            ,P_ASSIGNMENT_SET            IN         VARCHAR2
                            ,P_BUSINESS_GROUP_ID         IN         VARCHAR2) is
  l_p11d_gaps_request_id  number;
  l_report_name           varchar2(100);
begin

 /* print report for 2005
  if fnd_date.canonical_to_date(fnd_date.string_to_canonical(p_benefit_end_date,'dd-mon-rrrr')) >= fnd_date.canonical_to_date('2004/04/06') then
    l_report_name := p_p11d_gaps_report_2005;
*/
/* To print Gap and Overlap report for 2004*/
/*Bug No. 3201848*/
  if fnd_date.canonical_to_date(fnd_date.string_to_canonical(p_benefit_end_date,'dd-mon-rrrr')) >= fnd_date.canonical_to_date('2003/04/06') then
    l_report_name := p_p11d_gaps_report_2004;
  elsif fnd_date.canonical_to_date(fnd_date.string_to_canonical(p_benefit_end_date,'dd-mon-rrrr')) >= fnd_date.canonical_to_date('2002/04/06') and
        fnd_date.canonical_to_date(fnd_date.string_to_canonical(p_benefit_end_date,'dd-mon-rrrr')) <= fnd_date.canonical_to_date('2003/04/05') then
    l_report_name := p_p11d_gaps_report_2003;
  else
    l_report_name := p_p11d_gaps_report_2002;
  end if;
  --
  l_p11d_gaps_request_id := fnd_request.submit_request
                                (application => 'PER'
                                ,program     => l_report_name
                                ,argument1   => P_BENEFIT_START_DATE_CN
                                ,argument2   => P_BENEFIT_START_DATE
                                ,argument3   => P_BENEFIT_END_DATE_CN
                                ,argument4   => P_BENEFIT_END_DATE
                                ,argument5   => P_BENEFIT_TYPE_ID
                                ,argument6   => P_BENEFIT_TYPE
                                ,argument7   => P_OVERLAP
                                ,argument8   => P_GAP
                                ,argument9   => P_PAYROLL_ID
                                ,argument10  => P_PAYROLL
                                ,argument11  => P_PERSON_ID
                                ,argument12  => P_PERSON
                                ,argument13  => P_TAX_DISTRICT_REFERENCE_ID
                                ,argument14  => P_TAX_DISTRICT_REFERENCE
                                ,argument15  => P_CONSOLIDATION_SET_ID
                                ,argument16  => P_CONSOLIDATION_SET
                                ,argument17  => P_ASSIGNMENT_SET_ID
                                ,argument18  => P_ASSIGNMENT_SET
                                ,argument19  => P_BUSINESS_GROUP_ID );
  --
  retcode := 0;
exception
  when others then
    retcode := 1;
end submit_gaps_report;
--
end per_gb_p11d_reports;

/
