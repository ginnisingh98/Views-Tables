--------------------------------------------------------
--  DDL for Package Body PYUDET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYUDET" as
/* $Header: pyudet.pkb 120.49.12010000.17 2010/02/16 13:26:49 rlingama ship $ */
/*---------------------------------------------------------------------
 Copyright (c) Oracle Corporation 1995. All rights reserved

 Name          : pyudet
 Description   : Start Of Year Process, used to change Tax Basis to
                 Cumulative, clear Previous Tax Paid and Taxable Pay,
                 uplift Tax Codes or read new Tax Codes from tape.
 Author        : Barry Goodsell
 Date Created  : 15-Aug-95
 Uses          : hr_entry_api, hr_utility

 Change List
 -----------
 Date        Name            Vers     Bug No   Description
 +-----------+---------------+--------+--------+-----------------------+
  10-NOV-2006 K.Thampan       115.74            Rewrite package for SOY 07.
  10-NOV-2006 K.Thampan       115.74            Rewrite package for SOY 07.
                                                Truncate the change list,
                                                see version 115.73 for
                                                previous changes.
                              115.75            Fix GSCC error
  22-NOV-2006 K.Thampan       115.76            Remove check for NI Director
                                                start date.
  11-JAN-2007 K.Thampan       115.79   5757305  Added more validation for mode
                                                3/4.
  23-FEB-2007 K.Thampan       115.80            Fix tax basis error
                              115.81            Change from DO to D0
                              115.82            Added checked for tax_ref
                                                in mode 3,4 for non-aggregated
                                                assignment.
  02-MAR-2007 K.Thampan       115.83   5912261  Apply format mask to tax
                                                district number
  12-MAR-2007 K.Thampan       115.85   5927555  Added table alias
  22-MAR-2007 K.Thampan       115.86   5948728  Amended report for mode 3/4 to
                                                output  unprocess record as
                                                correction.
  26-MAR-2007 K.Thampan       115.87   5953974  Amended update_record procedure
  23-APR-2007 K.Thampan       115.88   5962025  Performance fix.
  30-NOV-2007 Dinesh C.       115.94   6450573  Change for SOY 08-09.
  04-MAR-2008 Rajesh L.       115.96   6741064  Modifed cursors csr_mode12,csr_mode34
                                                as orderby fullname
  26-MAR-2008 Rajesh L.       115.97   6864422  Reverted the fix 6741064 as it was reported
                                                by one cusotomer.
                                                Modified p_m34_rec.full_name to substr
                                                of peo.last_name length
  09-APR-2008 Rajesh.L        115.98   6957644  Modifed cursors csr_mode12,csr_mode34
                                                as orderby fullname
  08-SEP-2008 emunisek        115.99   7373763  Modified procedure process_record to prevent
                                                the false entries in the report of SOY changes
                                                and to prevent date tracks created for unmodified
                                                tax codes
 3-Oct-2008 apmishra         115.101 7373763    Re arcs in the file so as to enable the dual maintainence
                                                The earlier version of the branch file did not contain the fix,
                                                hence rearcs in.
 11-Nov_2008 dchindar        115.102 7532289    Changes has been done in cursor csr_mode12, so that process will
                                                now update all eligible Tax Code For a employee having more than one-person
                                                record with same NI number and other person details.
23-DEC-2008 dwkrishn         115.105 7649174    Modified the cursors/conditions for 3 cases
                                                csr_fetch_asg_asgno Pass assignment number , Ni always Null
                                                csr_fetch_asg_natid -- pass Ni ,Assignment always Null
                                                csr_fetch_asg_other -- Pass Both
                                                Both Null Errors
11-MAY-2009 jvaradra         115.106 8485686    Variable pqp_gb_ad_ee.g_global_paye_validation is
                                                intialized to 'N' before calling hr_entry_api
                                                and reset to 'Y' at the end to ensure row handler validations
                                                are not fired when p6/p9/SOY process are submitted.
21-MAY-2009 rlingama         115.107 8497477    Added Employer's PAYE Reference on the output.
                                                Earlier the report  was sorted by person full name.
                                                Now the report would sort by person name with in the individual tax references.
05-OCT-2009 dwkrishn         115.108 8785270    PAYE changes 2009. D0 can be cumulative from 6th APR 2010
21-OCT-2009 rlingama         115.109 8976778    Modified the logic to ensure, If TAX1 77 and TAX1 81 record
                                                identifiers exist on an incoming P6/P9 file, we should apply
                                                the value which will be either 0.00 or a positive value.
11-NOV-2009 rlingama         115.110 8510399    Added logic to ensure all the aggregated assignments are updated
                                                or ignored.
                                     8505085    We would stamp the authority code even P6/P9 file is received
				                with values which are same as before.
11-NOV-2009 rlingama         115.111 8510399    Incorporated the code review comments.
18-Dec-2009 rlingama         115.112 9215663    Modified the code to ensure that the P6/P9 process changes the tax bais form
                                                Non Cumulative to Cumulative after 6th Apr 2010.
18-Jan-2009 rlingama         115.113 9253974    Extended the "Future change effective: DATE" validation to check against sepecial
                                                authority code if "HR: GB Override SOY Authority" profile value is set to Override is allowed.
						Modified the code to ensure, for Non aggregated assignments, SOY process updates PAYE details
						even though other assignments of the person has future changes.
------------------------------------------------------------------------*/

-----------------------------------------------------
-- Constant variable                               --
-----------------------------------------------------
err_emp_not_found  constant varchar2(255) := 'Emp Data in EDI file does not match application data, or employee is terminated.';
err_multiple_found constant varchar2(255) := 'Emp Data in EDI file matches multiple records on the database.';
err_data_mismatch  constant varchar2(255) := '2 out of 3 values in EDI file required for matching are null.';
err_invalid_tax    constant varchar2(255) := 'Invalid tax code : TAX_CODE.';
err_mode34_ex_emp  constant varchar2(255) := 'No update for Ex-Employee, manual update may be required.';
err_mode2_ex_emp   constant varchar2(255) := 'No bulk uplift for Ex-Employee, manual update may be required.';
err_tax_basis      constant varchar2(255) := 'Invalid Tax Basis flag : TAX_BASIS.';
err_p6_pay_and_tax constant varchar2(255) := 'Previous tax is not zero, therefore previous pay cannot be zero.';
err_p45_p6_figures constant varchar2(255) := 'Discrepancy of over 1000 Pounds between P45/P6 figures.';
err_future_changes constant varchar2(255) := 'Future change effective : DATE.';
err_agg_asg constant varchar2(255) := 'No update due to failure of aggregated assignment/s.'; -- bug 8510399
err_multi_fchanges constant varchar2(255) := 'Multiple future changes detected, manual update may be required.';
err_no_paye_ele    constant varchar2(255) := 'PAYE Details element entries does not exists on DATE.';
err_multi_asg      constant varchar2(255) := 'Record not updated as assignment number is not supplied and multiple assignments exist, manual update may be required.';
err_future_asg     constant varchar2(255) := 'Record not updated as future assignment exists under the same tax district, manual update may be required.';
warning_msg        constant varchar2(255) := 'Tax details updated for assignment with future termination details present.';  /*Added soy 08-09*/
update_mode  constant varchar2(20) := 'UPDATE';
correct_mode constant varchar2(20) := 'CORRECTION';
reject_mode  constant varchar2(20) := 'REJECT';
ignore_mode  constant varchar2(20) := 'IGNORE';

-----------------------------------------------------
-- Record type for holding ASG Info                --
-----------------------------------------------------
TYPE g_typ_paye_record IS RECORD(
     element_entry_id      number,
     effective_start_date  date,
     effective_end_date    date,
     tax_code_id           number,
     tax_code_sv           varchar2(25),
     tax_basis_id          number,
     tax_basis_sv          varchar2(50),
     pay_previous_id       number,
     pay_previous_sv       varchar2(70),
     tax_previous_id       number,
     tax_previous_sv       varchar2(70),
     authority_id          number,
     authority_sv          varchar2(80),
     refundable_id         number,
     refundable_sv         varchar2(50),
     tax_code_prefix       varchar2(20),
     tax_code_value        number,
     tax_code_suffix       varchar2(20),
     tax_code_amended      boolean,
     tax_basis_amended     boolean,
     p45_val_amended       boolean,
     dt_update_mode        varchar2(25),
     creator_id            number);

TYPE g_typ_per_record IS RECORD(
     person_id         number,
     full_name         varchar2(255),
     ni_number         varchar2(20),
     aggregate_flag    varchar2(2),
     director_flag     varchar2(2),
     person_type       varchar2(30),
     term_date         date,
     lsp_date          date,
     effective_date    date,
     start_date        date,
     end_date          date,
     tax_ref           varchar2(20)); -- Bug#8497477

TYPE g_tax_code_interface IS RECORD(
     full_name            varchar2(255),
     national_identifier  varchar2(30),
     assignment_number    varchar2(60),
     payroll_name         varchar2(90),
     effective_date       date,
     date_of_message      date,
     issue_date           date,
     tax_code             varchar2(20),
     tax_basis            varchar2(20),
     previous_pay         number,
     previous_tax         number,
     authority            varchar2(20),
     paye_ref             varchar2(30),
     row_id               rowid);

-- Start of bug#8510399
TYPE g_write_paye_record IS RECORD(
     tax_ref           varchar2(200),
     status            varchar2(1),
     old_paye_rec      g_typ_paye_record,
     paye_rec          g_typ_paye_record,
     per_record        g_typ_per_record,
     assignment_number varchar2(255),
     dir               varchar2(255),
     effective_date    date,
     assignment_id     number,
     m34_rec           g_tax_code_interface,
     err_msg           varchar2(255));

TYPE g_tb_write_paye_rec IS TABLE OF
       g_write_paye_record
       INDEX BY BINARY_INTEGER;

tb_write_paye_rec g_tb_write_paye_rec;
-- end of bug#8510399

-----------------------------------------------------
-- GLOBAL Variables                                --
-----------------------------------------------------
g_business_group_id number;
g_payroll_id        number;
g_element_type_id   number;
g_mode              number;
g_request_id        number;
g_p6_request_id     number;
g_effective_date    date;
g_authority         varchar2(10);
g_current_req_id    number;
g_tax_ref           varchar2(20);
g_payroll_name      varchar2(50);
g_update_count      number;
g_reject_count      number;
g_E_line_count      number;
g_P_line_count      number;
g_T_line_count      number;
g_uplift_suffix     hr_entry.varchar2_table;
g_uplift_value      hr_entry.number_table;
g_validate_only     varchar2(1);     /*Added soy 08-09*/
g_cpe_flag          varchar2(1);     /*Added soy 08-09*/
g_p_print_tax_ref     varchar2(20) := '~'; -- Bug#8497477
g_e_print_tax_ref     varchar2(20) := '~'; -- Bug#8497477
g_SOY_override_profile  varchar2(255); -- Bug#9253974: variable to store profile value

------------------------------------------------------------
-- Cursor to fetch element type id for PAYE Details       --
------------------------------------------------------------
cursor get_element_type_id is
select element_type_id
from   pay_element_types_f
where  element_name = 'PAYE Details';

------------------------------------------------------------
-- Cursor to fetch assignment                             --
-- csr_mode12 = Cursor for select emp for mode 1 and 2    --
------------------------------------------------------------
cursor csr_mode12 is
select /*+ ORDERED
           INDEX(ppt, PER_PERSON_TYPES_PK) */
      -- max(peo.person_id) p_id,
       peo.person_id p_id,
       peo.full_name,
       peo.national_identifier,
       nvl(peo.per_information10,'N') agg_flag,
       nvl(peo.per_information2, 'N') dir_flag,
       ppt.system_person_type,
       pps.actual_termination_date,
       pps.last_standard_process_date,
       g_effective_date,
       peo.effective_start_date,
       peo.effective_end_date,
       scl.segment1 -- Bug#8497477
from   per_all_people_f         peo,
       per_all_assignments_f    asg,
       per_periods_of_service   pps,
       per_person_type_usages_f ptu,
       per_person_types         ppt,
       pay_all_payrolls_f       ppf, -- Bug#8497477
       hr_soft_coding_keyflex   scl  -- Bug#8497477
where  peo.person_id = asg.person_id
and    peo.business_group_id = g_business_group_id
and    (g_payroll_id is null or
        asg.payroll_id = g_payroll_id)
and    peo.person_id = ptu.person_id
and    ptu.person_type_id = ppt.person_type_id
and    pps.period_of_service_id = asg.period_of_service_id
and    asg.payroll_id is not null
-- Start bug#8497477 : added pay_all_payrolls_f and hr_soft_coding_keyflex for tax reference check
and ppf.soft_coding_keyflex_id=scl.soft_coding_keyflex_id
and ppf.payroll_id = asg.payroll_id
and g_effective_date between ppf.effective_start_date and ppf.effective_end_date
-- End bug#8497477
and    g_effective_date between peo.effective_start_date and peo.effective_end_date
and    g_effective_date between asg.effective_start_date and asg.effective_end_date
and    g_effective_date between ptu.effective_start_date and ptu.effective_end_date
and    ( (pps.final_process_date is not null and
          pps.final_process_date > g_effective_date)
          or
         (pps.final_process_date is null))
-- Bug#8497477: changed group by tax reference followed by existing group by.
group by scl.segment1,peo.person_id, peo.full_name, peo.national_identifier, peo.per_information10, peo.per_information2,
         ppt.system_person_type, pps.actual_termination_date, pps.last_standard_process_date,
         g_effective_date, peo.effective_start_date, peo.effective_end_date
         -- Bug 6957644 modified p_id to upper(peo.full_name) to report order by name
	 --Bug 6741064 modified p_id to upper(peo.full_name) to report order by name
	 -- Bug#8497477: changed order by tax reference followed by existing oreder by.
 order by scl.segment1,upper(peo.full_name), decode(system_person_type,'EMP',1,'EMP_APL',2,3);
-- Bug 6864422 reverted the fix 6741064 as it was reported by one customer
-- order by p_id, decode(system_person_type,'EMP',1,'EMP_APL',2,3);

------------------------------------------------------------
-- csr_mode34 = Cursor for select data off the tax code   --
--              interface table                           --
------------------------------------------------------------
cursor csr_mode34 is
select tci.employee_name             full_name,
       tci.national_insurance_number national_identifier,
       tci.works_number              assignment_number,
       tci.employer_reference        payroll_name,
       nvl(tci.effective_date,g_effective_date) effective_date,
       tci.date_of_message           date_of_message,
       tci.issue_date                issue_date,
       ltrim(rtrim(tci.tax_code))    tax_code_sv,
       ltrim(rtrim(tci.non_cumulative_flag)) tax_basis_sv,
       to_char(nvl((tci.tot_pay_prev_emp/100),''))  pay_previous_sv,
       to_char(nvl((tci.tot_tax_prev_emp/100),''))  tax_previous_sv,
       upper(nvl(tci.form_type,''))  authority_sv,
       ltrim(rtrim(to_char(tci.district_number,'000'))) || '/' || ltrim(rtrim(tci.employer_reference)) paye_ref,
       tci.rowid                     row_id
from   pay_gb_tax_code_interface tci
where  tci.processed_flag is null
and    (   tci.request_id is null
        or tci.request_id = g_p6_request_id)
        -- Bug 6957644 modified 6,2 to date_of_message,upper(full_name) to report order by name
	--Bug 6741064 modified 6,2 to date_of_message,upper(full_name) to report order by name
	-- Bug#8497477: changed order by tax reference followed by existing oreder by.
 order by paye_ref,date_of_message,upper(full_name);
-- Bug 6864422 reverted the fix 6741064 as it was reported by one customer
-- order by 6,2;

------------------------------------------------------------
-- Cursor to fetch assignment                             --
-- Cursor for select assignment based on the person_id    --
-- aggr flag                                              --
------------------------------------------------------------
cursor csr_asg_details(p_person_id number,
                       p_aggr_flag varchar2,
                       p_tax_ref   varchar2,
                       p_asg_no    varchar2,
                       p_date      date) is
select assignment_id,
       pay.payroll_id,
       assignment_number,
       per_system_status asg_status,
       sck.segment1 tax_ref
from   per_all_assignments_f       asg,
       pay_all_payrolls_f          pay,
       per_assignment_status_types pat,
       hr_soft_coding_keyflex      sck
where  asg.person_id = p_person_id
and    (   -- no need to fetch payroll, but do check the tax ref
           (p_aggr_flag = 'Y' and
           ((g_payroll_id is not null and sck.segment1 = g_tax_ref)
            or
            (g_payroll_id is null and p_tax_ref is not null and sck.segment1 = p_tax_ref)
            or
            (g_payroll_id is null and p_tax_ref is null)))
        or -- not aggregate then we have to check the payroll is matched.
           (p_aggr_flag = 'N' and
           ((g_payroll_id is null and p_asg_no is null and (p_tax_ref is null or p_tax_ref = sck.segment1) )
             or
            (g_payroll_id is null and p_asg_no is not null and asg.assignment_number = p_asg_no and (p_tax_ref is null or p_tax_ref = sck.segment1))
             or
            (g_payroll_id is not null and asg.payroll_id = g_payroll_id and (p_tax_ref is null or p_tax_ref = sck.segment1) )))
       )
and    asg.payroll_id = pay.payroll_id
and    sck.soft_coding_keyflex_id = pay.soft_coding_keyflex_id
and    asg.assignment_status_type_id = pat.assignment_status_type_id
and    p_date between asg.effective_start_date and asg.effective_end_date
and    p_date between pay.effective_start_date and pay.effective_end_date
-- Bug#8497477: changed order by tax reference followed by existing oreder by.
order by sck.segment1,assignment_id, decode(per_system_status,'ACTIVE_ASSIGN',1,'SUSP_ASSIGN',2,'ACTIVE_APL',3,4);

----------------------------------------------------------
-- This cursor returns those request_ids that are       --
-- greater than or equal to the request_id entered      --
-- by the user in the SRS - Resume definition and       --
-- that are smaller than the current process request_id --
----------------------------------------------------------
cursor get_req_cur (c_creator_id in number) IS
select 1
from   dual
where exists (select fcr.request_id
              from   fnd_concurrent_requests fcr,
                     fnd_concurrent_programs fcp
              where  fcr.concurrent_program_id = fcp.concurrent_program_id
              and    fcr.request_id =  c_creator_id
              and    fcr.request_id <  g_current_req_id
              and    fcr.request_id >= g_request_id
              and   (   fcp.concurrent_program_name = 'PYUDET'
                     or fcp.concurrent_program_name = 'PYUDET_R'));

---------------------------------------------------------
-- This cursor returns tax ref id based on the payroll --
---------------------------------------------------------
cursor get_payroll_details IS
select sck.segment1, payroll_name
from   hr_soft_coding_keyflex sck,
       pay_all_payrolls_f     pay
where  sck.soft_coding_keyflex_id = pay.soft_coding_keyflex_id
and    pay.payroll_id = g_payroll_id
and    g_effective_date between pay.effective_start_date and pay.effective_end_date;

-----------------------------------------------------------------------------------------------
-- This cursor is for Checking active and suspended assignments  at the time of process run  -- /*Added soy 08-09*/
-----------------------------------------------------------------------------------------------
CURSOR get_cpe_flag(p_person_id number, p_paye_ref varchar2, p_date date ) IS
select assignment_id
from   per_all_assignments_f       asg,
       pay_all_payrolls_f          pay,
       per_assignment_status_types pat,
       hr_soft_coding_keyflex      sck
where  asg.person_id = p_person_id
and    sck.segment1 = p_paye_ref
and    asg.payroll_id = pay.payroll_id
and    sck.soft_coding_keyflex_id = pay.soft_coding_keyflex_id
and    asg.assignment_status_type_id = pat.assignment_status_type_id
and    p_date between asg.effective_start_date and asg.effective_end_date
and    p_date between pay.effective_start_date and pay.effective_end_date
AND    per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN') ;

---------------------------------------------------------------------
-- NAME : set_global                                               --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- Set global variable                                             --
---------------------------------------------------------------------
PROCEDURE set_global(p_request_id        in  number default null,
                     p_mode              in  number,
                     p_effective_date    in  date,
                     p_business_group_id in  number,
                     p_payroll_id        in  number,
                     p_authority         in  varchar2 default null,
                     p_p6_request_id     in  number default null,
		     p_validate_only     in varchar2)
IS
BEGIN
     hr_utility.trace('Setting GLOBAL variable');
     open get_element_type_id;
     fetch get_element_type_id into g_element_type_id;
     close get_element_type_id;

     g_business_group_id := p_business_group_id;
     g_payroll_id        := p_payroll_id;
     g_mode              := p_mode;
     g_request_id        := p_request_id;
     g_p6_request_id     := p_p6_request_id;
     g_effective_date    := p_effective_date;
     g_authority         := p_authority;
     g_current_req_id    := nvl(fnd_profile.value('CONC_REQUEST_ID'),-1);
     g_update_count      := 0;
     g_reject_count      := 0;
     -- Insert the G_EFFECTIVE_DATE into FND_SESSION
     hr_utility.fnd_insert(g_effective_date);

     IF p_validate_only = 'GB_VALIDATE' then  /*Added soy 08-09*/
       g_validate_only := 'Y';
     elsif p_validate_only = 'GB_VALIDATE_COMMIT' THEN
       g_validate_only := 'N';
     end if;

     if g_payroll_id is not null then
        open get_payroll_details;
        fetch get_payroll_details into g_tax_ref, g_payroll_name;
        close get_payroll_details;
     end if;

     -- Set up value if running Resume
     if g_request_id is not null then
        select decode(max(decode(type,'E',line_no,0)),
                          null, 0,
                          max(decode(type,'E',line_no,0))),
               decode(max(decode(type,'P',line_no,0)),
                          null, 0,
                          max(decode(type,'P',line_no,0))),
               decode(max(decode(type,'T',line_no,0)),
                          null, 0,
                          max(decode(type,'T',line_no,0)))
        into g_E_line_count,
             g_P_line_count,
             g_T_line_count
        from  pay_gb_soy_outputs
        where request_id = g_request_id;
     end if;
     hr_utility.trace('Running mode    : ' || g_mode);
     hr_utility.trace('Business group  : ' || g_business_group_id);
     hr_utility.trace('PAYE element id : ' || g_element_type_id);
     hr_utility.trace('Payroll ID      : ' || g_payroll_id);
     hr_utility.trace('Resume ID       : ' || g_request_id);
     hr_utility.trace('P6 request ID   : ' || g_p6_request_id);
     hr_utility.trace('Effective date  : ' || g_effective_date);
     hr_utility.trace('Authority code  : ' || g_authority);
     hr_utility.trace('PAYE reference  : ' || g_tax_ref);
EXCEPTION
     when OTHERS then
          raise;
END set_global;

---------------------------------------------------------------------
-- NAME : asg_future_termination                   Added soy 08-09 --
-- Type : Private Function                                         --
-- DESCRIPTION :                                                   --
-- This function will return a Y if assignment is future           --
-- terminated or ended in case of non-aggregated assignment else   --
-- return N.  In case of non-aggregated, if all assignments having --
-- same PAYE ref are ended at a future point and assignment future --
-- terminated then return Y else return N                          --
---------------------------------------------------------------------
FUNCTION asg_future_termination(p_effective_date    in date,
                                p_assignment_id     in number,
				p_person_rec        in g_typ_per_record,
				p_tax_ref           in varchar2) return varchar2
IS
l_future_term_date       date :=NULL;
l_future_end_date        date :=NULL;
l_return_flag            varchar2(1) :='N';
l_future_term_flag       varchar2(1) :='N';
l_future_end_flag        varchar2(1) :='N';
l_cpe_end_date           date;
-------------------------------------------------------------------
-- This cursor is for Checking assignment is teminated in future --
-------------------------------------------------------------------
CURSOR get_future_term_date(p_assignment_id number, p_effective_date date ) IS
select effective_start_date
     from   PER_ALL_ASSIGNMENTS_F paaf,
            per_assignment_status_types past
     where  paaf.effective_start_date >= p_effective_date
     and    paaf.assignment_id = p_assignment_id
     and    paaf.assignment_status_type_id =past.assignment_status_type_id
     and    past.per_system_status IN ('TERM_ASSIGN')
     and    paaf.business_group_id = g_business_group_id;
-------------------------------------------------------------------
-- This cursor is for Checking assignment is ended in future --
-------------------------------------------------------------------
CURSOR get_future_end_asg_date(p_assignment_id number, p_effective_date date ) IS
select max(effective_end_date)
     from   PER_ALL_ASSIGNMENTS_F paaf
     where  paaf.effective_end_date >= p_effective_date
     and    paaf.assignment_id = p_assignment_id
     and    paaf.business_group_id = g_business_group_id;

BEGIN
     hr_utility.trace('     Check assignment is Teminated or Ended in future ');
       open get_future_term_date(p_assignment_id, p_effective_date);
       fetch get_future_term_date into l_future_term_date;
         if get_future_term_date%FOUND then
           l_future_term_flag := 'Y';
         end if;
       close get_future_term_date;

       open get_future_end_asg_date(p_assignment_id, p_effective_date);
       fetch get_future_end_asg_date into l_future_end_date ;
           if l_future_end_date <> TO_DATE('31/12/4712', 'DD/MM/RRRR') then
             l_future_end_flag := 'Y';
           end if;
       close get_future_end_asg_date;

     if p_person_rec.aggregate_flag ='N' then
        --------------------------------------------------
        -- Check if assignment is terminated in future  --
        --------------------------------------------------
            if l_future_term_flag = 'Y' then
              hr_utility.trace('    Assingment Terminated Date is : ' || l_future_term_date);
	          l_return_flag := 'Y';
            end if;

        -------------------------------------------
        --Check if assignment is Ended in future --
        -------------------------------------------
            if l_future_end_flag = 'Y' then
             hr_utility.trace('    Assingment End Date is : ' || l_future_end_date );
             l_return_flag := 'Y';
	        end if;
      elsif p_person_rec.aggregate_flag ='Y' then
        ------------------------------------------------------------------------------------
        -- Check if all the asg having same PAYE terminated or ended in future in future  --
        ------------------------------------------------------------------------------------
         l_cpe_end_date := pay_gb_eoy_archive.get_agg_active_end(p_assignment_id, p_tax_ref , p_effective_date);
         if l_cpe_end_date <> TO_DATE('31/12/4712', 'DD/MM/RRRR') and l_cpe_end_date >= p_effective_date and
                                      (l_future_term_flag = 'Y' or l_future_end_flag = 'Y')then
              l_return_flag := 'Y';
         end if;
     end if;
     return l_return_flag;
EXCEPTION
when others then
        raise;
END asg_future_termination;

----------------------------------------------------------------------
-- NAME : set_cpe_flag                             Added soy 08-09  --
-- Type : Private Function                                          --
-- DESCRIPTION :                                                    --
-- This function will return N if the terminated assignment passed  --
-- to this fuction not in CPE with any of the active or suspended   --
-- assignment having same PAYE refference                           --
----------------------------------------------------------------------
FUNCTION set_cpe_flag(p_person_id       IN NUMBER,
		      p_assignment_id   IN NUMBER ,
		      p_paye_ref        IN VARCHAR2,
		      p_effective_date  IN DATE)

RETURN VARCHAR2 IS
BEGIN
     hr_utility.trace('     Inside set_cpe_flag function for term asg: ' || p_assignment_id);
     for l_record in get_cpe_flag(p_person_id,
                                  p_paye_ref,
                                  p_effective_date)
     loop
     hr_utility.trace('     Active or suspened asg record');
         hr_utility.trace('     Assignment ID : ' || l_record.assignment_id);
         hr_utility.trace('     PAYE Ref      : ' || p_paye_ref);
         if pay_gb_eoy_archive.get_agg_active_end(l_record.assignment_id, p_paye_ref , p_effective_date)=
               pay_gb_eoy_archive.get_agg_active_end(p_assignment_id, p_paye_ref, p_effective_date)
            AND  pay_gb_eoy_archive.get_agg_active_start(l_record.assignment_id, p_paye_ref, p_effective_date)=
                   pay_gb_eoy_archive.get_agg_active_start(p_assignment_id, p_paye_ref, p_effective_date) then

	    hr_utility.trace('     Term Asg is in active CPE ');
	    return 'Y';
         end if;
     end loop;
     hr_utility.trace('     Term Asg is not in active CPE ');
     RETURN 'N';
EXCEPTION
when others then
        raise;
END set_cpe_flag;
---------------------------------------------------------------------
-- NAME : check_commit                                             --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- Function to return TRUE if we have processed a certain number   --
-- of records. This is to allow the main process to commit at      --
-- regular intervals, in order to cut-down on the rollback space   --
-- required.                                                       --
---------------------------------------------------------------------
FUNCTION check_commit return BOOLEAN
IS
     l_commit_point  number  := 10;
BEGIN
     if (mod(g_update_count, l_commit_point) = 0) then
        return(TRUE);
     end if;
     return FALSE;
END check_commit;

---------------------------------------------------------------------
-- NAME : conv_to_table                                            --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- Procedure converts the element entry values from the PAYE       --
-- record into the PL/SQL table format required for the element    --
-- entry API                                                       --
---------------------------------------------------------------------
PROCEDURE conv_to_table(p_paye_rec           in g_typ_paye_record,
                        p_num_entry_values   in out nocopy number,
                        p_input_value_id_tbl in out nocopy hr_entry.number_table,
                        p_entry_value_tbl    in out nocopy hr_entry.varchar2_table)
IS
     l_index number := 0;
BEGIN
     if p_paye_rec.tax_basis_amended then
        l_index := l_index + 1;
        p_input_value_id_tbl(l_index) := p_paye_rec.tax_basis_id;
        p_entry_value_tbl(l_index)    := p_paye_rec.tax_basis_sv;
     end if;
     if p_paye_rec.p45_val_amended then
        l_index := l_index + 1;
        p_input_value_id_tbl(l_index) := p_paye_rec.pay_previous_id;
        p_entry_value_tbl(l_index)    := p_paye_rec.pay_previous_sv;

        l_index := l_index + 1;
        p_input_value_id_tbl(l_index) := p_paye_rec.tax_previous_id;
        p_entry_value_tbl(l_index)    := p_paye_rec.tax_previous_sv;
     end if;
     if p_paye_rec.tax_code_amended then
        l_index := l_index + 1;
        p_input_value_id_tbl(l_index) := p_paye_rec.tax_code_id;
        p_entry_value_tbl(l_index)    := ltrim(p_paye_rec.tax_code_sv);
     end if;
     if l_index > 0 then
        l_index := l_index + 1;
        p_input_value_id_tbl(l_index) := p_paye_rec.authority_id;
        p_entry_value_tbl(l_index)    := p_paye_rec.authority_sv;
     end if;
     -- bug 8505085 : We would stamp the authority code even though there is no
     -- changes in P6/P9 file supplied by HMRC
     if l_index = 0 and trim(g_authority) in ('P6','P6B','P9') then
        l_index := l_index + 1;
        p_input_value_id_tbl(l_index) := p_paye_rec.authority_id;
        p_entry_value_tbl(l_index)    := p_paye_rec.authority_sv;
     end if;
     p_num_entry_values := l_index;
END conv_to_table;

---------------------------------------------------------------------
-- NAME : conv_to_table_ni                                         --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- Procedure converts the element entry values from the NI         --
-- record into the PL/SQL table format required for the element    --
-- entry API                                                       --
---------------------------------------------------------------------
PROCEDURE conv_to_table_ni(p_process_type_updated in varchar2 ,
                           p_input_value_id       in number ,
                           p_num_entry_values     in out nocopy number,
                           p_input_value_id_tbl   in out nocopy hr_entry.number_table,
                           p_entry_value_tbl      in out nocopy hr_entry.varchar2_table)
IS
     l_index number := 0;
BEGIN
     l_index := l_index + 1;
     p_input_value_id_tbl(l_index) := p_input_value_id ;
     p_entry_value_tbl(l_index)    := p_process_type_updated;
     p_num_entry_values := l_index;
END conv_to_table_ni;

---------------------------------------------------------------------
-- NAME : file_output                                              --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- DESCRIPTION                                                     --
-- Procedure inserts a record into the PAY_GB_SOY_OUTPUT table,    --
-- which will be used to created the output files required for     --
-- the PYUDET process                                              --
---------------------------------------------------------------------
PROCEDURE file_output(p_type       in varchar2,
                      p_line_no    in out nocopy number,
                      p_text       in varchar2,
                      p_request_id in number default null)
IS
     l_request_id number  := nvl(fnd_profile.value('CONC_REQUEST_ID'),-1);
BEGIN
     if p_request_id is not null then
        l_request_id := p_request_id;
     end if;
     --
     p_line_no := nvl(p_line_no,0) + 1;
     --
     insert into pay_gb_soy_outputs(request_id, type, line_no, text)
     values(l_request_id, p_type, p_line_no, p_text);
     --
END file_output;

-- Start bug#8497477
---------------------------------------------------------------------
-- NAME : write_Tax_Ref                                            --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- Write Tax Reference output                                      --
---------------------------------------------------------------------
PROCEDURE write_Tax_Ref (p_tax_ref varchar2,
                         p_msg_type varchar2)
IS

begin

if p_msg_type = 'P' then
     if g_p_print_tax_ref <> p_tax_ref then
          g_p_print_tax_ref := p_tax_ref;
          file_output('P', g_P_line_count, ' ', g_request_id);
          file_output('P', g_P_line_count, 'Employer''s PAYE Reference : '|| p_tax_ref, g_request_id);
          file_output('P', g_P_line_count, ' ', g_request_id);
      end if;
elsif p_msg_type = 'E' then
      if g_e_print_tax_ref <> p_tax_ref then
            g_e_print_tax_ref := p_tax_ref;
            file_output('E', g_E_line_count, ' ', g_request_id);
            file_output('E', g_E_line_count, 'Employer''s PAYE Reference : '|| p_tax_ref, g_request_id);
            file_output('E', g_E_line_count, ' ', g_request_id);
       end if;
end if;

END;

-- End bug#8497477

---------------------------------------------------------------------
-- NAME : write_header                                             --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- Write header output                                             --
---------------------------------------------------------------------
PROCEDURE write_header
IS
     cursor c_p6 is
     select count(*)
     from   pay_gb_tax_code_interface
     where  request_id = g_p6_request_id;

     l_process  varchar2(110);
     l_mode     varchar2(100);
     l_run_date varchar2(100);
     l_p6       varchar2(100);
     l_eff_date varchar2(100);
     l_payroll  varchar2(100);
     l_p6_count number;
     l_validate_mode varchar2(150);
BEGIN
     /*Added soy 08-09*/
     if g_validate_only = 'N' then
     l_process  := 'Amendments to ''PAYE Details'' - Records Processed';
     elsif g_validate_only = 'Y' then
     l_process  := 'Amendments to ''PAYE Details'' - Potential Records To Be Processed When Run In Commit Mode';
     end if;
     if g_mode = 1 then
        l_mode := 'Start Of Year';
	if g_validate_only = 'N' then
	         l_process  := 'Amendments to ''PAYE Details'' and ''NI'' - Records Processed';
        elsif g_validate_only = 'Y' then
                 l_process  := 'Amendments to ''PAYE Details'' and ''NI'' - Potential Records To Be Processed When Run In Commit Mode';
	end if;
     elsif g_mode = 2 then
        l_mode := 'Mid Year Tax Code Change';
     elsif g_mode = 3 then
        l_mode := 'Tax Code Uplift From Tape';
     elsif g_mode = 4 then
        l_mode := 'P6/P6B/P9 Upload Process';
        open c_p6;
        fetch c_p6 into l_p6_count;
        close c_p6;
        l_p6 := 'Total number of records in EDI file : ' || l_p6_count;
     end if;
     --
     if g_payroll_name is not null then
        l_payroll := g_payroll_name;
     else
        l_payroll := 'All Payrolls';
     end if;
     -------------
      /*Added soy 08-09*/
     if g_validate_only = 'Y' then
        l_validate_mode :=rpad('Validate Mode',21) || 'Validate Only - Updates Not Applied To The Database';
     else
        l_validate_mode :=rpad('Validate Mode',21) || 'Validate And Commit';
     end if;
     --------------
     l_run_date := rpad('Run Date',21)        || rpad(to_char(sysdate,'DD-MON-YYYY'),50) || 'KEY';
     l_eff_date := rpad('Effective Date',21)  || rpad(to_char(g_effective_date,'DD-MON-YYYY'),50) || 'n/c : No Change';
     l_mode     := rpad('Processing Mode',21) || rpad(l_mode,50)    || 'n/a : Not Applicable';
     l_payroll  := rpad('Payroll',21)         || rpad(l_payroll,50) || 'n/s : Not Supplied';
     --
     file_output('P', g_P_line_count, null,            g_request_id);
     file_output('P', g_P_line_count, l_run_date,      g_request_id);
     file_output('P', g_P_line_count, l_eff_date,      g_request_id);
     file_output('P', g_P_line_count, l_mode,          g_request_id);
     file_output('P', g_P_line_count, l_payroll,       g_request_id);
     file_output('P', g_P_line_count, l_validate_mode, g_request_id);
     file_output('P', g_P_line_count, null,            g_request_id);
     if l_p6 is not null then
        file_output('P', g_P_line_count, null, g_request_id);
        file_output('P', g_P_line_count, l_p6, g_request_id);
        file_output('P', g_P_line_count, null, g_request_id);
     end if;
     file_output('P', g_P_line_count, l_process,  g_request_id);
     file_output('P', g_P_line_count, null, g_request_id);
     if g_validate_only = 'N' then
                file_output('E', g_E_line_count, replace(l_process,'Processed','Not Processed'),  g_request_id);
     elsif g_validate_only = 'Y' then
                file_output('E', g_E_line_count, replace(l_process,'Processed','Rejected'),  g_request_id);
     end if;
END write_header;

---------------------------------------------------------------------
-- NAME : write_group_header                                       --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- Procedure to write a group header to the report files if it is  --
-- required                                                        --
---------------------------------------------------------------------
PROCEDURE write_group_header
IS
     l_line1  varchar2(255);
     l_line2  varchar2(255);
     l_line3  varchar2(255);
     l_line4  varchar2(255);
     l_line5  varchar2(255); /*Added soy 08-09*/
BEGIN
     ----------------------------------------
     -- First write the header for process --
     ----------------------------------------
      if g_mode in (1,2) then
        --         ---------1---------2---------3---------4---------5---------6---------7---------8---------9---------0---------1---------2---------3
        --         1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
        l_line1 :='                                                                Authority Tax     Previous  PAYE       NI       NI          ';
        l_line2 :='Assignment                                        Old    New    Code      Basis   Gross/Tax Update/    Director Update      ';
        l_line3 :='Number     Name                                   Code   Code   Old | New Amended Amended   Correction Old New              ';
        l_line4 :='---------- -------------------------------------- ------ ------ --------- ------- --------- ---------- --- ---  ------------';
     elsif g_mode in (3,4) then
       --         ---------1---------2---------3---------4---------5---------6---------7---------8---------9---------0---------1---------2---------3
        --         1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
        l_line1 :='Assignment                                        Record     Authority Tax    Tax            Previous    Previous   ';
        l_line2 :='Number     Name                                   Type       Code      Code   Basis          Pay         Tax        ';
	l_line5 :='>>Warning                                                                                                           ';
	l_line3 :='---------- -------------------------------------- ---------- --------- ------ -------------- ----------- -----------';
     end if;
     file_output('P', g_P_line_count, l_line1, g_request_id);
     file_output('P', g_P_line_count, l_line2, g_request_id);
      if g_mode in (1,2) then
     file_output('P', g_P_line_count, l_line3, g_request_id);
     file_output('P', g_P_line_count, l_line4, g_request_id);
     elsif  g_mode in (3,4) then
     file_output('P', g_P_line_count, l_line5, g_request_id);
     file_output('P', g_P_line_count, l_line3, g_request_id);
     end if;
/*     if l_line4 is not null then
        file_output('P', g_P_line_count, l_line4, g_request_id);
     end if;*/
     --------------------------------------------
     -- First write the header for not process --
     --------------------------------------------
     l_line1 := null;
     l_line2 := null;
     l_line3 := null;
     l_line4 := null;
     if g_mode in (1,2) then
        --         ---------1---------2---------3---------4---------5---------6---------7---------8---------9---------0---------1---------2---------3
        --         1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
        l_line1 :='Assignment                                                                                                                        ';
        l_line2 :='Number     Name                                   Reason                                                                          ';
        l_line3 :='---------- -------------------------------------- --------------------------------------------------------------------------------';
     elsif g_mode in (3,4) then
        --         ---------1---------2---------3---------4---------5---------6---------7---------8---------9---------0---------1---------2---------3
        --         1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
        l_line1 :='Assignment                                        NI         Tax    Tax            Previous    Previous    Effective       ';
        l_line2 :='Number     Name                                   Number     Code   Basis          Pay         Tax         Date            ';
        l_line3 :='>>Reason for Rejection                                                                                                     ';
        l_line4 :='---------- -------------------------------------- ---------- ------ -------------- ----------- ----------- ----------------';
     end if;
     file_output('E', g_E_line_count, l_line1, g_request_id);
     file_output('E', g_E_line_count, l_line2, g_request_id);
     file_output('E', g_E_line_count, l_line3, g_request_id);
     if l_line4 is not null then
        file_output('E', g_E_line_count, l_line4, g_request_id);
     end if;
END write_group_header;

---------------------------------------------------------------------
-- NAME : write_body                                               --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- This procedure will write lines to the update section in report --
---------------------------------------------------------------------
PROCEDURE write_body(p_old_paye_rec   in g_typ_paye_record,
                     p_new_paye_rec   in g_typ_paye_record,
                     p_person_rec     in g_typ_per_record,
                     p_asg_number     in varchar2,
                     p_dir            in varchar2 default null,
		     p_effective_date in date default null,
                     p_assignment_id  in number,
		     p_tax_ref        in varchar2) /*Extra parameter Added soy 08-09*/
IS
     l_line        varchar2(255);
     l_before      varchar2(255);
     l_after       varchar2(255);
     l_tax_basis   varchar2(20);
     l_p45_figures varchar2(20);
     l_prev_pay    varchar2(20);
     l_prev_tax    varchar2(20);
     l_tax_code    varchar2(20);
     l_director    varchar2(30);
     l_authority   varchar2(30);
     l_mode        varchar2(30);
     l_warn_flag varchar2(1);
BEGIN
     l_line := rpad(p_asg_number,10) || ' ' || rpad(p_person_rec.full_name,38) || ' ';
     l_mode := initcap(lower(p_new_paye_rec.dt_update_mode));
     ------------
     -- Mode 1 --
     ------------
     if g_mode = 1 then
        l_tax_basis   := 'n/c';
        l_p45_figures := 'n/c';
        l_tax_code    := rpad('n/c',7) || rpad('n/c',7);
        if p_new_paye_rec.tax_basis_amended then
           l_tax_basis := 'YES';
        end if;
        if p_new_paye_rec.p45_val_amended then
           l_p45_figures := 'YES';
        end if;
        if p_new_paye_rec.tax_code_amended then
           l_tax_code := rpad(p_old_paye_rec.tax_code_sv,6) || ' ' || rpad(p_new_paye_rec.tax_code_sv,6) || ' ';
        end if;
        l_authority:= rpad(nvl(p_old_paye_rec.authority_sv,' '),4) || '|' || lpad(nvl(p_new_paye_rec.authority_sv,' '),4);
        l_director := p_dir;
        if p_dir is null then
           l_director := 'n/a n/a  n/a';
        end if;
        l_line := l_line || l_tax_code || rpad(l_authority,10) || rpad(l_tax_basis,8) || rpad(l_p45_figures,10) || rpad(l_mode, 11) || l_director;
        file_output('P', g_P_line_count,l_line, g_request_id);
     end if;
     -------------
     -- Mode 2  --
     -------------
     if g_mode = 2 then
        l_director := 'n/a n/a  n/a';
        l_tax_code := rpad(p_old_paye_rec.tax_code_sv,6) || ' ' || rpad(p_new_paye_rec.tax_code_sv,6) || ' ';
        l_authority:= rpad(nvl(p_old_paye_rec.authority_sv,' '),4) || '|' || lpad(nvl(p_new_paye_rec.authority_sv,' '),4);
        l_line := l_line || l_tax_code || rpad(l_authority,10) || rpad('n/a',8) || rpad('n/a',10) || rpad(l_mode, 11) || l_director;
        file_output('P', g_P_line_count,l_line, g_request_id);
     end if;
     -----------------
     -- Mode 3 or 4 --
     -----------------
     if g_mode in (3,4) then
        l_tax_basis   := rpad('n/c',15);
        l_tax_code    := rpad('n/c',7);
        l_prev_pay    := lpad('n/c',11);
        l_prev_tax    := lpad('n/c',11);
        l_authority   := rpad(nvl(p_old_paye_rec.authority_sv,' '),10);
        if p_new_paye_rec.tax_code_amended then
           l_tax_code    := rpad(p_old_paye_rec.tax_code_sv,7);
        end if;
        if p_new_paye_rec.tax_basis_amended then
           l_tax_basis   := rpad(p_old_paye_rec.tax_basis_sv,15);
        end if;
        if p_new_paye_rec.p45_val_amended then
           if to_number(nvl(p_old_paye_rec.pay_previous_sv,'0')) <> to_number(nvl(p_new_paye_rec.pay_previous_sv,'0')) then
              l_prev_pay := lpad(to_char(to_number(nvl(p_old_paye_rec.pay_previous_sv,'0')),9999990.99),11);
           end if;
           if to_number(nvl(p_old_paye_rec.tax_previous_sv,'0')) <> to_number(nvl(p_new_paye_rec.tax_previous_sv,'0')) then
              l_prev_tax := lpad(to_char(to_number(nvl(p_old_paye_rec.tax_previous_sv,'0')),9999990.99),11);
           end if;
        end if;
        l_before := l_line || rpad('Before',11) || l_authority || l_tax_code || l_tax_basis || l_prev_pay || ' ' || l_prev_tax;

        l_tax_basis   := rpad('n/c',15);
        l_tax_code    := rpad('n/c',7);
        l_prev_pay    := lpad('n/c',11);
        l_prev_tax    := lpad('n/c',11);
        l_authority   := rpad(nvl(p_new_paye_rec.authority_sv,' '),10);
        if p_new_paye_rec.tax_code_amended then
           l_tax_code    := rpad(p_new_paye_rec.tax_code_sv,7);
        end if;
        if p_new_paye_rec.tax_basis_amended then
           l_tax_basis   := rpad(p_new_paye_rec.tax_basis_sv,15);
        end if;
        if p_new_paye_rec.p45_val_amended then
           if to_number(nvl(p_old_paye_rec.pay_previous_sv,'0')) <> to_number(nvl(p_new_paye_rec.pay_previous_sv,'0')) then
              l_prev_pay := lpad(to_char(to_number(nvl(p_new_paye_rec.pay_previous_sv,'0')),9999990.99),11);
           end if;
           if to_number(nvl(p_old_paye_rec.tax_previous_sv,'0')) <> to_number(nvl(p_new_paye_rec.tax_previous_sv,'0')) then
              l_prev_tax := lpad(to_char(to_number(nvl(p_new_paye_rec.tax_previous_sv,'0')),9999990.99),11);
           end if;
        end if;
        l_after  := rpad(' ',50) || rpad(l_mode,11) || l_authority || l_tax_code || l_tax_basis || l_prev_pay || ' ' || l_prev_tax;
        file_output('P', g_P_line_count,l_before, g_request_id);
        file_output('P', g_P_line_count,l_after, g_request_id);
        l_warn_flag := asg_future_termination(nvl(p_effective_date,g_effective_date), p_assignment_id, p_person_rec, p_tax_ref) ; /*Added soy 08-09*/
        if l_warn_flag = 'Y'  then
	     file_output('P', g_P_line_count,'>>' || warning_msg , g_request_id);
        end if;
     end if;
 END write_body;

---------------------------------------------------------------------
-- NAME : reject_record                                            --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- This procedure will write message to the reject section         --
---------------------------------------------------------------------
PROCEDURE reject_record(p_per_rec    g_typ_per_record     default null,
                        p_m34_rec    g_tax_code_interface default null,
                        p_msg        varchar2,
                        p_asg_number varchar2 default null,
                        p_tax_ref    varchar2 default null) -- Bug#8497477 : added tax ref parameter to report tax ref on the output.
IS
     l_line        varchar2(255);
     l_ni          varchar2(50);
     l_tax_code    varchar2(50);
     l_tax_basis   varchar2(50);
     l_p45_figures varchar2(50);
BEGIN
     if g_mode in (1,2) then
        l_line := rpad(p_asg_number,10) || ' ' || rpad(p_per_rec.full_name,38) || ' ' || p_msg;
	-- Start bug#8497477 : Report tax ref if current and previous references are not same.
           write_Tax_Ref(p_tax_ref,'E');
	-- End bug#8497477
        file_output('E', g_E_line_count,l_line, g_request_id);
     elsif (g_mode in (3,4)) then
        ----------------------------------------
        -- First update the taxcode interface --
        ----------------------------------------
        update pay_gb_tax_code_interface
        set    processed_flag = 'R'
        where rowid = p_m34_rec.row_id;
        --
        if p_asg_number is not null then
           l_line := rpad(p_asg_number,10) || ' ' || rpad(p_per_rec.full_name,38);
        else
           l_line := rpad(nvl(p_m34_rec.assignment_number,'none'),10) || ' ' || rpad(nvl(p_m34_rec.full_name,' '),38);
        end if;
        l_ni         := rpad(nvl(p_m34_rec.national_identifier,' '),11);
        l_tax_code   := rpad(nvl(p_m34_rec.tax_code,' '),7);
        l_tax_basis  := rpad(nvl(p_m34_rec.tax_basis,' '),15);
        l_p45_figures:= lpad(to_char(nvl(p_m34_rec.previous_pay,0),9999990.99),11) || ' ' ||
                        lpad(to_char(nvl(p_m34_rec.previous_tax,0),9999990.99),11) || ' ';
        l_line := l_line || ' ' || l_ni || l_tax_code || l_tax_basis || l_p45_figures || to_char(p_m34_rec.effective_date,'DD-MON-YYYY');
        -- Start bug#8497477 : Report tax ref if current and previous references are not same.
        write_Tax_Ref(p_tax_ref,'E');
	-- End bug#8497477
	file_output('E', g_E_line_count,l_line, g_request_id);
        file_output('E', g_E_line_count,'>>' || p_msg , g_request_id);
     end if;
     g_reject_count := g_reject_count + 1;
END reject_record;

---------------------------------------------------------------------
-- NAME : write_footer                                             --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- Write footer output                                             --
---------------------------------------------------------------------
PROCEDURE write_footer
IS
     l_p6_count  number;
     cursor p6 is
     select count(*)
     from   pay_gb_tax_code_interface
     where  request_id = g_p6_request_id
     and    processed_flag = 'P';
BEGIN
     file_output('P', g_P_line_count, null, g_request_id);
     file_output('P', g_P_line_count, null, g_request_id);

     if (g_p6_request_id is not null) then
        open p6;
        fetch p6 into l_p6_count;
        close p6;
        file_output('P', g_P_line_count,'Total EDI Records Processed = '|| to_char(l_p6_count), g_request_id);
     end if;
     file_output('P', g_P_line_count, 'Records Updated (inc Multi Assignment) = '|| to_char(g_update_count), g_request_id);
     --
     file_output('E', g_E_line_count, null, g_request_id);
     file_output('E', g_E_line_count, null, g_request_id);
     if (g_p6_request_id is not null) then
        file_output('E', g_E_line_count,'Total EDI Records Not Processed = '|| to_char(g_reject_count), g_request_id);
     else
        file_output('E', g_E_line_count,'Records Not Processed = '|| to_char(g_reject_count), g_request_id);
     end if;
END write_footer;

---------------------------------------------------------------------
-- NAME : lookup_meaning                                           --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- Function returns the MEANING column from HR_LOOKUPS for the     --
-- specified LOOKUP_TYPE and LOOKUP_CODE                           --
---------------------------------------------------------------------
FUNCTION lookup_meaning(p_lookup_type in varchar2,
                        p_lookup_code in varchar2) return VARCHAR2
IS
      l_meaning  hr_lookups.meaning%type  := null;
      cursor c_lookup is
      select lku.meaning
      from   hr_lookups lku
      where  lku.lookup_type = p_lookup_type
      and    lku.lookup_code = p_lookup_code;
BEGIN
     open  c_lookup;
     fetch c_lookup into l_meaning;
     close c_lookup;
     return l_meaning;
END lookup_meaning;

---------------------------------------------------------------------
-- NAME : validate_tax_code                                        --
-- Type : Private Function                                         --
-- DESCRIPTION :                                                   --
-- This Function uses the TAX_CODE validation fast formula and     --
-- returns an error message if an incorrect tax code is entered.   --
---------------------------------------------------------------------
FUNCTION validate_tax_code(p_tax_code       in varchar2,
                           p_effective_date in date,
                           p_assignment_id  in number) return VARCHAR2
IS
     l_formula_id           ff_formulas_f.formula_id%type;
     l_effective_start_date ff_formulas_f.effective_start_date%type;
     l_inputs               ff_exec.inputs_t;
     l_outputs              ff_exec.outputs_t;
     l_return_value         varchar2(50):= null;
     l_formula_mesg         varchar2(50):= null;
     l_status_value         varchar2(2):= null;
BEGIN
     -----------------------------
     -- Fetch formula details   --
     -----------------------------
     select formula_id,
	        effective_start_date
     into   l_formula_id,
	        l_effective_start_date
     from   ff_formulas_f
     where  formula_name='TAX_CODE'
     and    business_group_id is null
     and    legislation_code='GB'
     and    p_effective_date between effective_start_date and effective_end_date;
     ----------------------------
     -- Initialize the formula --
     ----------------------------
     ff_exec.init_formula(l_formula_id,l_effective_start_date,l_inputs,l_outputs);
     -------------------------
     -- Setup formula input --
     -------------------------
     for l_in_cnt in l_inputs.first..l_inputs.last loop
         if l_inputs(l_in_cnt).name = 'ENTRY_VALUE' then
            l_inputs(l_in_cnt).value := ltrim(p_tax_code);
         end if;
         if l_inputs(l_in_cnt).name = 'DATE_EARNED' then
            l_inputs(l_in_cnt).value := to_char(p_effective_date,'DD-MON-YYYY');
         end if;
         if l_inputs(l_in_cnt).name = 'ASSIGNMENT_ID' then
            l_inputs(l_in_cnt).value := to_char(p_assignment_id);
         end if;
     end loop;
     -------------------------
     -- Execute the formula --
     -------------------------
     ff_exec.run_formula(l_inputs,l_outputs);
     --------------------
     -- Reading output --
     --------------------
     for l_out_cnt in l_outputs.first..l_outputs.last loop
         if l_outputs(l_out_cnt).name='FORMULA_MESSAGE' then
            l_formula_mesg := l_outputs(l_out_cnt).value;
         end if;
         if l_outputs(l_out_cnt).name='FORMULA_STATUS' then
            l_status_value := l_outputs(l_out_cnt).value;
         end if;
     end loop;
     if l_status_value = 'E' and l_formula_mesg is null then
        l_return_value := 'TAX_CODE Formula error';
     else
        l_return_value := l_formula_mesg;
     end if;

     return l_return_value;
EXCEPTION
     WHEN no_data_found then
          return l_return_value;
END validate_tax_code;

---------------------------------------------------------------------
-- NAME : post_fetch                                               --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- Parse the tax_code details and place the value back into the    --
-- record                                                          --
---------------------------------------------------------------------
PROCEDURE post_fetch(p_paye_rec in out nocopy g_typ_paye_record)
IS
     l_tax_code varchar2(50);
     l_step     number;
BEGIN
     l_step := 1;
     l_tax_code := ltrim(rtrim(p_paye_rec.tax_code_sv));
     if (l_tax_code <> 'NT'  AND l_tax_code <> 'BR'  AND l_tax_code <> 'FT'  AND
         l_tax_code <> 'D0'  AND l_tax_code <> 'NI'  AND l_tax_code <> 'T0'  AND
         l_tax_code <> 'SBR' AND l_tax_code <> 'SNT' AND l_tax_code <> 'SFT' AND
         l_tax_code <> 'SNI') then
         --
         p_paye_rec.tax_code_prefix := pysoytls.tax_prefix(p_paye_rec.tax_code_sv);
         p_paye_rec.tax_code_value  := pysoytls.tax_value (p_paye_rec.tax_code_sv);
         p_paye_rec.tax_code_suffix := pysoytls.tax_suffix(p_paye_rec.tax_code_sv);
         l_step := 2;
     end if;
     --
     l_step := 3;
     p_paye_rec.tax_basis_sv  := lookup_meaning('GB_TAX_BASIS',  p_paye_rec.tax_basis_sv);
     p_paye_rec.refundable_sv := lookup_meaning('GB_REFUNDABLE', p_paye_rec.refundable_sv);
     p_paye_rec.authority_sv :=  lookup_meaning('GB_AUTHORITY',  p_paye_rec.authority_sv);
EXCEPTION
   WHEN others then
     hr_utility.trace('Error in post_fetch at step ' || l_step);
     hr_utility.trace(SQLERRM(SQLCODE));
     raise;
END post_fetch;

---------------------------------------------------------------------
-- NAME : get_uplift_value                                         --
-- Type : Private Function                                         --
-- DESCRIPTION :                                                   --
-- This function will return uplift value based on effective_date  --
---------------------------------------------------------------------
FUNCTION get_uplift_value (p_tax_suffix in varchar2) return NUMBER
IS
     cursor c_uplift is
     select usr.row_low_range_or_name  suffix,
            fnd_number.canonical_to_number(uci.value)  value
     from   pay_user_tables             ust,
            pay_user_columns            usc,
            pay_user_rows_f             usr,
            pay_user_column_instances_f uci
     where  ust.user_table_name         = 'TAX_CODE_UPLIFT_VALUES'
     and    ust.user_table_id           = usc.user_table_id
     and    ust.user_table_id           = usr.user_table_id
     and    usc.user_column_name        = 'UPLIFT_VALUE'
     and    usc.user_column_id          = uci.user_column_id
     and    usr.user_row_id             = uci.user_row_id
     and    uci.business_group_id       = g_business_group_id
     and    usr.business_group_id       = g_business_group_id
     and    g_effective_date between usr.effective_start_date and usr.effective_end_date
     and    g_effective_date = uci.effective_start_date;
     l_index number  := 0;
BEGIN
     if (g_uplift_value(0) = -1) then
        ---------------------------------------------
        -- Uplift values have not yet been fetched --
        ---------------------------------------------
        for r_uplift in c_uplift loop
            if (r_uplift.value is not null) and (r_uplift.value <> 0) then
               l_index := l_index + 1;
               g_uplift_suffix(l_index) := r_uplift.suffix;
               g_uplift_value(l_index)  := r_uplift.value;
            end if;
        end loop;
        g_uplift_value(0) := l_index;
     end if;
     --------------------------------------------------------
     -- Scan the PL/SQL tables to find the required Suffix --
     --------------------------------------------------------
     for l_index in 1..g_uplift_value(0) loop
         if (g_uplift_suffix(l_index) = p_tax_suffix) then
            return(g_uplift_value(l_index));
         end if;
     end loop;
     -------------------------------------------------------
     -- Suffix was not found in the table, so return NULL --
     -------------------------------------------------------
     return(null);
END get_uplift_value;

---------------------------------------------------------------------
-- NAME : check_future_changes                                     --
-- Type : Private Function                                         --
-- DESCRIPTION :                                                   --
-- This function will return a date if there is a date tracked     --
-- update on or after the given date for PAYE element entries      --
---------------------------------------------------------------------
FUNCTION check_future_changes (p_assignment_id  in number,
                               p_effective_date in date default hr_api.g_date,
                               p_multi_change   out nocopy boolean,
                               p_auth_code out nocopy varchar2) return DATE -- Bug#9253974 -- added authority code parameter
IS
     l_future_date  date := null;
BEGIN
     hr_utility.trace('     Check future change');

     -- Start of bug#9253974
     /*select ele.effective_start_date
     into   l_future_date
     from   pay_element_entries_f ele
     where  ele.effective_start_date >= p_effective_date
     and    ele.assignment_id = p_assignment_id
     and    ele.element_type_id = g_element_type_id
     order by ele.effective_start_date asc;*/

     -- Modified the cursor to fetch authority code as well.
     select ele.effective_start_date,HR_GENERAL.DECODE_LOOKUP('GB_AUTHORITY',eev.screen_entry_value)
     into l_future_date, p_auth_code
     from
     pay_element_entries_f ele,
     pay_element_entry_values_f eev,
     pay_input_values_f inv
     where inv.element_type_id = g_element_type_id
     and inv.name = 'Authority'
     and eev.input_value_id = inv.input_value_id
     and ele.element_type_id = inv.element_type_id
     and eev.element_entry_id = ele.element_entry_id
     and ele.assignment_id = p_assignment_id
     and  ele.effective_start_date >= p_effective_date
     and  eev.effective_start_date >= p_effective_date
     and  p_effective_date  between inv.effective_start_date and inv.effective_end_date
     order by ele.effective_start_date asc;
     -- End of bug#9253974
     hr_utility.trace('     Future change date : ' || l_future_date);
     p_multi_change := FALSE;
     return(l_future_date);
EXCEPTION
   when too_many_rows then
        p_multi_change := TRUE;
        return null;
   when no_data_found then
        p_multi_change := FALSE;
        return null;
   when others then
        raise;
END check_future_changes;

---------------------------------------------------------------------
-- NAME : process_director                                         --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- This procedure will update director details on NI element       --
--  Director Pro Rate        to Director                           --
--  Director Pro Rate Normal to Director Normal                    --
---------------------------------------------------------------------
FUNCTION process_directors(p_per_rec       in g_typ_per_record,
                           p_assignment_id in number) return VARCHAR2
IS
     l_element_entry_id        number;
     l_input_value_id          number;
     l_num_entry_values        number;
     l_process_type            varchar2(3);
     l_process_type_new_code   varchar2(3);
     l_process_type_new        varchar2(20);
     l_process_type_updated    boolean;
     l_input_value_id_tbl      hr_entry.number_table;
     l_entry_value_tbl         hr_entry.varchar2_table;

     cursor csr_get_ni_process_type is
     select element_entry_id,
            process_type,
            input_value_id5
     from   PAY_NI_ELEMENT_ENTRIES_V pneev
     where  pneev.assignment_id = p_assignment_id
     and    g_effective_date between pneev.effective_start_date and pneev.effective_end_date;
BEGIN
     if p_per_rec.director_flag = 'Y' and
        p_per_rec.person_type in ('EMP', 'EMP_APL') then

           open csr_get_ni_process_type;
           fetch csr_get_ni_process_type into l_element_entry_id,
                                              l_process_type,
                                              l_input_value_id ;
           close csr_get_ni_process_type;
           l_process_type_updated := FALSE;
           if l_process_type = 'DP' then
              l_process_type_new := 'Director';
              l_process_type_new_code := 'DY';
              l_process_type_updated := TRUE;
           end if;
           if l_process_type = 'DR' then
              l_process_type_new := 'Director Normal';
              l_process_type_new_code := 'DN';
              l_process_type_updated := TRUE;
           end if;

           if l_process_type_updated  then
              conv_to_table_ni(l_process_type_new,
                               l_input_value_id,
                               l_num_entry_values,
                               l_input_value_id_tbl,
                               l_entry_value_tbl) ;

           if g_validate_only = 'N'   then  /*Added soy 08-09*/
           hr_utility.trace(' In Validate And Commit Mode therefore updating');

              -- For bug 8485686
              pqp_gb_ad_ee.g_global_paye_validation := 'N';

              hr_entry_api.update_element_entry (
                p_dt_update_mode             => 'UPDATE',
                p_session_date               => g_effective_date,
                p_element_entry_id           => l_element_entry_id,
                p_num_entry_values           => l_num_entry_values,
                p_input_value_id_tbl         => l_input_value_id_tbl,
                p_entry_value_tbl            => l_entry_value_tbl  );

		  -- For bug 8485686
              pqp_gb_ad_ee.g_global_paye_validation := 'Y';

           end if;

	      return (l_process_type || '  ' || l_process_type_new_code || '   Update');
           end if;
     end if;

     return null;
END process_directors;

---------------------------------------------------------------------
-- NAME : uplift_taxcode                                           --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- This procedure will uplift tax code for the assignment          --
---------------------------------------------------------------------
PROCEDURE uplift_taxcode(p_asg_typ  in varchar2,
                         p_paye_rec in out nocopy g_typ_paye_record,
			 p_aggregate_flag varchar2)
IS
     l_uplift_value number;
     l_new_value    number;
BEGIN
     -----------------------------------------------------------------------------
     -- See if we need to update the tax code by checking the assignment status --
     -- If assignment is not active or suspend, then don't do anything          --
     -- (In case of non aggregated assignments consider terminated assg also    --
     -- this change is for SOY 08-09)                                           --
     -----------------------------------------------------------------------------
  if p_aggregate_flag ='Y' then
      if (p_asg_typ in ('ACTIVE_ASSIGN','ACTIVE_APL','SUSP_ASSIGN','TERM_ASSIGN') and   /*Added terminated for soy 08-09*/
              p_paye_rec.tax_code_suffix is not null)  then
           l_uplift_value := get_uplift_value(p_paye_rec.tax_code_suffix);
           if nvl(l_uplift_value,0) <> 0 then
                l_new_value := p_paye_rec.tax_code_value + l_uplift_value;
	             if l_new_value < 0 then
                      p_paye_rec.tax_code_sv := '0T';
                 else
                      p_paye_rec.tax_code_sv := pysoytls.trim(p_paye_rec.tax_code_prefix ||
                                                      fnd_number.number_to_canonical(l_new_value) ||
                                                      p_paye_rec.tax_code_suffix);
                 end if;
                 p_paye_rec.tax_code_amended := TRUE;
            end if;
       end if;
  elsif p_aggregate_flag ='N' then
     if (p_asg_typ in ('ACTIVE_ASSIGN','ACTIVE_APL','SUSP_ASSIGN') and
              p_paye_rec.tax_code_suffix is not null) then
             l_uplift_value := get_uplift_value(p_paye_rec.tax_code_suffix);
             if nvl(l_uplift_value,0) <> 0 then
                  l_new_value := p_paye_rec.tax_code_value + l_uplift_value;
	              if l_new_value < 0 then
                     p_paye_rec.tax_code_sv := '0T';
                  else
                     p_paye_rec.tax_code_sv := pysoytls.trim(p_paye_rec.tax_code_prefix ||
                                                      fnd_number.number_to_canonical(l_new_value) ||
                                                      p_paye_rec.tax_code_suffix);
                  end if;
                  p_paye_rec.tax_code_amended := TRUE;
             end if;
       end if;
  end if;
END uplift_taxcode;
---------------------------------------------------------------------
-- NAME : update_p45_taxbasis                                      --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- This procedure will clear down P45 figures n update Tax Basis   --
-- from Non Cumulative to Cumulative                               --
---------------------------------------------------------------------
PROCEDURE update_p45_taxbasis(p_asg_typ  in varchar2,
                              p_paye_rec in out nocopy g_typ_paye_record,
			      p_aggregate_flag varchar2)
IS
BEGIN
     if p_aggregate_flag ='Y' then
     if p_paye_rec.tax_code_sv not in ('D0','SD0') OR g_effective_date >= fnd_date.canonical_to_date('2010/04/06 00:00:00') then  --Bug 8785270:  Paye 2009-2010 Changes
        if p_asg_typ in ('ACTIVE_ASSIGN','ACTIVE_APL','SUSP_ASSIGN','TERM_ASSIGN') and g_cpe_flag ='Y' then
           if p_paye_rec.tax_basis_sv = 'Non Cumulative' THEN /*Added terminated for soy 08-09*/
              p_paye_rec.tax_basis_sv := 'Cumulative';
              p_paye_rec.tax_basis_amended := TRUE;
              hr_utility.trace('     Tax Basis update');
           end if;
        end if;
     end if;
   elsif p_aggregate_flag ='N' then
      if p_paye_rec.tax_code_sv not in ('D0','SD0') OR g_effective_date >= fnd_date.canonical_to_date('2010/04/06 00:00:00') then --Bug 8785270:  Paye 2009-2010 Changes
        if p_asg_typ in ('ACTIVE_ASSIGN','ACTIVE_APL','SUSP_ASSIGN') then
           if p_paye_rec.tax_basis_sv = 'Non Cumulative' then
              p_paye_rec.tax_basis_sv := 'Cumulative';
              p_paye_rec.tax_basis_amended := TRUE;
              hr_utility.trace('     Tax Basis update');
           end if;
        end if;
     end if;
    end if;
     --
     if (to_number(nvl(p_paye_rec.pay_previous_sv,0)) > 0  or
         to_number(nvl(p_paye_rec.tax_previous_sv,0)) > 0) then
        p_paye_rec.pay_previous_sv := '0';
        p_paye_rec.tax_previous_sv := '0';
        p_paye_rec.p45_val_amended := TRUE;
        hr_utility.trace('     P45 Update');
     end if;
END update_p45_taxbasis;

---------------------------------------------------------------------
-- NAME : check_p45_figures                                        --
-- Type : Private Function                                         --
-- DESCRIPTION :                                                   --
-- This function will check the incoming P45 figures from the EDI  --
-- and return any error message.  This function is for mode 4      --
---------------------------------------------------------------------
FUNCTION check_p45_figures(p_m34_rec  in g_tax_code_interface,
                           p_paye_rec in out nocopy g_typ_paye_record) return VARCHAR2
IS
     ex_p45_figures exception;
     l_msg          varchar2(255);
     l_p6_pay       number;
     l_p6_tax       number;
     l_p45_pay      number;
     l_p45_tax      number;
BEGIN
 -- Start of bug 8976778
 -- If TAX1 77 and TAX1 81 record identifiers exist on an incoming P6/P9 file
 -- then only, we should apply the value which will be either 0.00 or a positive value.
 if p_m34_rec.previous_pay is not null
 and p_m34_rec.previous_tax is not null then
 -- End of bug 8976778
     l_p6_pay    := nvl(p_m34_rec.previous_pay,0);
     l_p6_tax    := nvl(p_m34_rec.previous_tax,0);
     l_p45_pay   := nvl(p_paye_rec.pay_previous_sv,0);
     l_p45_tax   := nvl(p_paye_rec.tax_previous_sv,0);
     ---------------------------------------
     -- If value are the same, do nothing --
     ---------------------------------------
     if (l_p6_pay = l_p45_pay) and (l_p6_tax = l_p45_tax) then
        return null;
     end if;
     --------------------------------------------------
     -- If incoming values are zero then, do nothing --
     --------------------------------------------------
     -- Start of bug 8976778
     -- Commented out the below code as we need to update P45 figures for zero values also
    /* if ( l_p6_pay = 0) and (l_p6_tax = 0) then
        return null;
     end if;*/
     -- End of bug 8976778
     --------------------------------------------------------
     -- If incoming prev pay = 0, but prev tax <> 0; error --
     --------------------------------------------------------
     if (l_p6_pay = 0) and (l_p6_tax <> 0) then
        l_msg := err_p6_pay_and_tax;
        raise ex_p45_figures;
     end if;
     --------------------------------------------------------------------------
     -- If the current P45 figures are zero but P6 are not; update the value --
     --------------------------------------------------------------------------
     if ((l_p45_pay = 0) and (l_p45_tax = 0)) and
        ((l_p6_pay <> 0) or (l_p6_tax <> 0)) then
        p_paye_rec.tax_previous_sv := l_p6_tax;
        p_paye_rec.pay_previous_sv := l_p6_pay;
        p_paye_rec.p45_val_amended := TRUE;
        return null;
     end if;
     -------------------------------------------------------------
     -- If P45 and P6 are not zero, check the diff between them --
     -------------------------------------------------------------
     if abs(l_p45_pay - l_p6_pay) >= 1000 or
        abs(l_p45_tax - l_p6_tax) >= 1000 then
        l_msg := err_p45_p6_figures;
        raise ex_p45_figures;
     end if;
     ---------------------------------------------
     -- Getting this far, then assumes no error --
     ---------------------------------------------
     p_paye_rec.tax_previous_sv := l_p6_tax;
     p_paye_rec.pay_previous_sv := l_p6_pay;
     p_paye_rec.p45_val_amended := TRUE;
     return null;
  -- Start of bug 8976778
  else
     return null;
  end if;
  -- End of bug 8976778
EXCEPTION
     WHEN ex_p45_figures THEN
          return l_msg;
END check_p45_figures;



---------------------------------------------------------------------
-- NAME : conv_to_paye_rec                                         --
-- Type : Private Function                                         --
-- DESCRIPTION :                                                   --
-- This function will setup the paye_rec data record and will      --
-- return any error message.  This function is for mode 3 and 4    --
---------------------------------------------------------------------
FUNCTION conv_to_paye_rec(p_asg_id   in number,
                          p_m34_rec  in g_tax_code_interface,
                          p_paye_rec in out nocopy g_typ_paye_record) return VARCHAR2
IS
     ex_error exception;
     l_msg    varchar2(255);
BEGIN
     hr_utility.trace('     Conv to PAYE Rec (mode 3 | 4)');
     hr_utility.trace('     Incoming tax basis: ' || p_m34_rec.tax_basis );
     hr_utility.trace('     Incoming tax code : ' || p_m34_rec.tax_code);
     hr_utility.trace('     Incoming P45 (P|T): ' || nvl(p_m34_rec.previous_pay,0) || ' | ' || nvl(p_m34_rec.previous_tax,0));
     hr_utility.trace('     Current tax basis : ' || p_paye_rec.tax_basis_sv);
     hr_utility.trace('     Current tax code  : ' || p_paye_rec.tax_code_sv);
     hr_utility.trace('     Current P45 (P|T) : ' || nvl(p_paye_rec.pay_previous_sv,0) || ' | ' || nvl(p_paye_rec.tax_previous_sv,0));
     -------------------------------------------
     -- First we check the incoming tax basis --
     -------------------------------------------
     if p_m34_rec.tax_basis is null then
        if p_paye_rec.tax_basis_sv <> 'Cumulative' then
           hr_utility.trace('     Updating tax basis');
           p_paye_rec.tax_basis_sv := 'Cumulative';
           p_paye_rec.tax_basis_amended := TRUE;
        end if;
     elsif p_m34_rec.tax_basis = 'Y' then
        if p_paye_rec.tax_basis_sv <> 'Non Cumulative' then
           hr_utility.trace('     Updating tax basis');
           p_paye_rec.tax_basis_sv := 'Non Cumulative';
           p_paye_rec.tax_basis_amended := TRUE;
        end if;
     else
        l_msg := replace(err_tax_basis,'TAX_BASIS',p_m34_rec.tax_basis);
        raise ex_error;
     end if;
     -------------------------------------------
     -- Now checking the incoming tax code    --
     -------------------------------------------
     if p_m34_rec.tax_code <> p_paye_rec.tax_code_sv then
        l_msg := validate_tax_code(p_m34_rec.tax_code, p_m34_rec.effective_date, p_asg_id);
        if l_msg is not null then
           raise ex_error;
        end if;
        p_paye_rec.tax_code_sv := p_m34_rec.tax_code;
        p_paye_rec.tax_code_amended := TRUE;
        hr_utility.trace('     Updating tax code');
     end if;
     --------------------------------------------
     -- If the incoming tax code is D0,        --
     -- change the tax basis to Non Cumulative --
     -- if effective date is less than 6-Apr-10--
     --------------------------------------------
     --Bug 8785270:  Paye 2009-2010 Changes Start
     if p_paye_rec.tax_basis_sv <> 'Non Cumulative' AND
     -- Bug:9215663 - Modified the code to ensure that the P6/P9 process changes the tax bais form
     -- Non Cumulative to Cumulative after 6th Apr 2010.
     --(p_paye_rec.tax_code_sv in ('D0','SD0') OR g_effective_date >= fnd_date.canonical_to_date('2010/04/06 00:00:00')) then
        (p_paye_rec.tax_code_sv in ('D0','SD0') AND p_m34_rec.effective_date < fnd_date.canonical_to_date('2010/04/06 00:00:00')) then
	p_paye_rec.tax_basis_sv := 'Non Cumulative';
        p_paye_rec.tax_basis_amended := TRUE;
     end if;
     --Bug 8785270:  Paye 2009-2010 Changes End
     -------------------------------------------
     -- Now we check the incoming P45 Figures --
     -------------------------------------------
     if g_mode = 4 then
        l_msg := check_p45_figures(p_m34_rec,p_paye_rec);
        if l_msg is not null then
           raise ex_error;
        end if;
     end if;
     return null;
EXCEPTION
   WHEN ex_error THEN
        return l_msg;
END conv_to_paye_rec;

---------------------------------------------------------------------
-- NAME : set_new_paye_record                                      --
-- Type : Private Function                                         --
-- DESCRIPTION :                                                   --
-- This function will update the PAYE and return any error msg     --
---------------------------------------------------------------------
FUNCTION set_new_paye_record(p_asg_typ  in varchar2,
                             p_asg_id   in number,
                             p_paye_rec in out nocopy g_typ_paye_record,
                             p_m34_rec  in g_tax_code_interface default null,
                             p_aggregate_flag in varchar2 default 'N') return VARCHAR2
IS
     ex_error       exception;
     l_msg          varchar2(255);
     l_multi_change boolean;
     l_future       date;
     l_check_date   date;
     l_auth_code  varchar2(255); -- Bug#9253974: variable to store auth code
BEGIN
     hr_utility.trace('     Set New PAYE Record');
     l_check_date := g_effective_date;
     l_multi_change := FALSE;
     ----------------
     -- For mode 1 --
     ----------------
     if g_mode = 1 then
        hr_utility.trace('     Updating P45 figures');
        update_p45_taxbasis(p_asg_typ,p_paye_rec, p_aggregate_flag);
     ----------------------
     -- For mode 3 and 4 --
     ----------------------
     elsif g_mode in (3,4) and g_cpe_flag ='Y' then  /*CPE condition Added soy 08-09*/
        hr_utility.trace('     Calling conv_to_paye_rec');
        l_msg := conv_to_paye_rec(p_asg_id,p_m34_rec,p_paye_rec);
        if l_msg is not null then
           raise ex_error;
        end if;
        l_check_date := p_m34_rec.effective_date;
     end if;
     hr_utility.trace('     Check Date : ' || l_check_date);
     ----------------------------------
     -- Check for any future changes --
     ----------------------------------
     -- Bug#9253974: added auth code parameter
     l_future := check_future_changes(p_asg_id, l_check_date, l_multi_change,l_auth_code);
     if l_multi_change then
        hr_utility.trace('     Multiple future changes found');
        l_msg := err_multi_fchanges;
        raise ex_error;
     end if;

     if l_future is not null then
        hr_utility.trace('     Future change found');
        if g_mode = 1 then
           -------------------------------------------------------
           -- For mode 1, if exists change on the same date and --
           -- no change to P45, reject the record               --
           -------------------------------------------------------
	   -- Bug#9253974: Don't throw future validation
	   -- if future date track change on soy process run date
	   -- and profile value  is set to "Override is allowed"
	   -- and authority code is "Override SOY"'.
           if  (l_future = g_effective_date)
	   and (l_auth_code = 'Override SOY')
	   and (g_SOY_override_profile = 'OVERRIDE_YES') then
              NULL;
           else
           if l_future = l_check_date and
              not p_paye_rec.p45_val_amended then
              l_msg := replace(err_future_changes,'DATE',to_char(l_future,'DD-MON-YYYY'));
              raise ex_error;
           elsif l_future > l_check_date then
              l_msg := replace(err_future_changes,'DATE',to_char(l_future,'DD-MON-YYYY'));
              raise ex_error;
           end if;
           end if;
           -------------------------------------------------
           -- There is a change on same day, but have to  --
           -- clear down P45/TaxBasis, so Correction mode --
           -------------------------------------------------
           p_paye_rec.dt_update_mode := correct_mode;
        elsif g_mode = 2 then
           ------------------------------------------------
           -- For mode 1 and 2, if exists future changes --
           -- reject the record.                         --
           ------------------------------------------------
           if l_future >= l_check_date then
              l_msg := replace(err_future_changes,'DATE',to_char(l_future,'DD-MON-YYYY'));
              raise ex_error;
           end if;
        elsif g_mode in (3,4) then
           ------------------------------------------------
           -- For mode 3 and 4, if exists future changes --
           -- but the change is on the same day, proceed --
           -- otherwise reject                           --
           ------------------------------------------------
           if l_future = l_check_date then
              p_paye_rec.dt_update_mode := correct_mode;
           else
              l_msg := replace(err_future_changes,'DATE',to_char(l_future,'DD-MON-YYYY'));
              raise ex_error;
           end if;
        end if;
     else
       ----------------------------
       -- Future change is nulll --
       ----------------------------
       p_paye_rec.dt_update_mode := update_mode;
     end if;

     ----------------------
     -- For mode 1 and 2 --  /*CPE condition Added soy 08-09*/
     ----------------------
     -- Bug#9253974: Uplift tax code
     -- if future date track change on soy process run date
     -- and authority code is set to "Override is allowed"
     -- and authority code is "Override SOY"'.
     if ( g_mode in (1,2) and (p_paye_rec.dt_update_mode = update_mode and g_cpe_flag ='Y'))
     or
      ( g_mode = 1
      and (l_future = g_effective_date)
      and (l_auth_code = 'Override SOY')
      and (g_SOY_override_profile = 'OVERRIDE_YES') )then
        uplift_taxcode(p_asg_typ, p_paye_rec,p_aggregate_flag);
     end if;
     -----------------------
     -- Set the authority --
     -----------------------
     hr_utility.trace('     Setting authority');
     p_paye_rec.authority_sv := g_authority;
     hr_utility.trace('     New PAYE Details element:');
     hr_utility.trace('     Tax Code         : ' || p_paye_rec.tax_code_sv );
     hr_utility.trace('     Tax Basis        : ' || p_paye_rec.tax_basis_sv );
     hr_utility.trace('     Previous Pay     : ' || p_paye_rec.pay_previous_sv );
     hr_utility.trace('     Previous Tax     : ' || p_paye_rec.tax_previous_sv );
     hr_utility.trace('     Authority        : ' || p_paye_rec.authority_sv );
     return null;
EXCEPTION
     WHEN ex_error THEN
          return l_msg;
END set_new_paye_record;

---------------------------------------------------------------------
-- NAME : check_leaver                                             --
-- Type : Private Function                                         --
-- DESCRIPTION :                                                   --
-- This function will check for leaver and return the appropriate  --
-- message                                                         --
---------------------------------------------------------------------
FUNCTION check_leaver(p_per_rec  in g_typ_per_record) return VARCHAR2
IS
     ex_exemp exception;
     l_msg     varchar2(255);
BEGIN
     hr_utility.trace('     Check for Leaver');
     if p_per_rec.person_type in ('EX_EMP','EX_APL') then
        --
        hr_utility.trace('     LEAVER = TRUE');
        if g_mode in (3,4) then
           l_msg := err_mode34_ex_emp;
        elsif g_mode = 2 then
           l_msg := err_mode2_ex_emp;
        end if;
        --
        raise ex_exemp;
     end if;
     hr_utility.trace('     Not a leaver');
     return null;
EXCEPTION
     when ex_exemp then
          return l_msg;
END check_leaver;

---------------------------------------------------------------------
-- NAME : get_paye_record                                          --
-- Type : Private Function                                         --
-- DESCRIPTION :                                                   --
-- This function will fetch PAYE element entry                     --
-- Will return message if error found                              --
---------------------------------------------------------------------
FUNCTION get_paye_record(p_assignment_id in number,
                         p_date          in date,
                         p_paye_rec      out nocopy g_typ_paye_record) return VARCHAR2
IS
     ex_tax_code exception;
     l_msg        varchar2(255);
     l_paye_rec   g_typ_paye_record;

	 cursor csr_paye_rec is
	 select ee.element_entry_id ,
            ee.effective_start_date ,
            ee.effective_end_date ,
            min(decode(inv.name, 'Tax Code',     eev.input_value_id, null))     tax_code_id ,
            min(decode(inv.name, 'Tax Code',     eev.screen_entry_value, null)) tax_code_sv ,
            min(decode(inv.name, 'Tax Basis',    eev.input_value_id, null))     tax_basis_id ,
            min(decode(inv.name, 'Tax Basis',    eev.screen_entry_value, null)) tax_basis_sv ,
            min(decode(inv.name, 'Pay Previous', eev.input_value_id, null))     pay_previous_id ,
            min(decode(inv.name, 'Pay Previous', eev.screen_entry_value, null)) pay_previous_sv ,
            min(decode(inv.name, 'Tax Previous', eev.input_value_id, null))     tax_previous_id ,
            min(decode(inv.name, 'Tax Previous', eev.screen_entry_value, null)) tax_previous_sv ,
            min(decode(inv.name, 'Authority',    eev.input_value_id, null))     authority_id ,
            min(decode(inv.name, 'Authority',    eev.screen_entry_value, null)) authority_sv ,
            min(decode(inv.name, 'Refundable',   eev.input_value_id, null))     refundable_id ,
            min(decode(inv.name, 'Refundable',   eev.screen_entry_value, null)) refundable_sv,
            ee.creator_id
     from   pay_element_entries_f      ee,
            pay_element_entry_values_f eev,
            pay_input_values_f         inv
     where  ee.assignment_id = p_assignment_id
     and    ee.element_type_id = g_element_type_id
     and    ee.element_entry_id = eev.element_entry_id
     and    eev.input_value_id = inv.input_value_id
     and    p_date between ee.effective_start_date and ee.effective_end_date
     and    p_date between eev.effective_start_date and eev.effective_end_date
     and    p_date between inv.effective_start_date and inv.effective_end_date
     group by ee.element_entry_id, ee.effective_start_date, ee.effective_end_date,
              ee.creator_id;
BEGIN
     open csr_paye_rec;
     fetch csr_paye_rec into l_paye_rec.element_entry_id,
                             l_paye_rec.effective_start_date,
                             l_paye_rec.effective_end_date,
                             l_paye_rec.tax_code_id,
                             l_paye_rec.tax_code_sv,
                             l_paye_rec.tax_basis_id,
                             l_paye_rec.tax_basis_sv,
                             l_paye_rec.pay_previous_id,
                             l_paye_rec.pay_previous_sv,
                             l_paye_rec.tax_previous_id,
                             l_paye_rec.tax_previous_sv,
                             l_paye_rec.authority_id,
                             l_paye_rec.authority_sv,
                             l_paye_rec.refundable_id,
                             l_paye_rec.refundable_sv,
                             l_paye_rec.creator_id;
     close csr_paye_rec;
     l_paye_rec.tax_code_amended  := FALSE;
     l_paye_rec.tax_basis_amended := FALSE;
     l_paye_rec.p45_val_amended   := FALSE;
     post_fetch(l_paye_rec);
     if g_mode in (1,2) then
        if l_paye_rec.tax_code_value = 999999 then
           l_msg := replace(err_invalid_tax,'TAX_CODE',l_paye_rec.tax_code_sv);
           raise ex_tax_code;
        end if;
     end if;
     p_paye_rec := l_paye_rec;
     hr_utility.trace('     Element Entry ID : ' || p_paye_rec.element_entry_id );
     hr_utility.trace('     Start Date       : ' || p_paye_rec.effective_start_date );
     hr_utility.trace('     End Date         : ' || p_paye_rec.effective_end_date );
     hr_utility.trace('     Tax Code         : ' || p_paye_rec.tax_code_sv );
     hr_utility.trace('     Tax Basis        : ' || p_paye_rec.tax_basis_sv );
     hr_utility.trace('     Previous Pay     : ' || p_paye_rec.pay_previous_sv );
     hr_utility.trace('     Previous Tax     : ' || p_paye_rec.tax_previous_sv );
     hr_utility.trace('     Authority        : ' || p_paye_rec.authority_sv );
     return null;
EXCEPTION
     WHEN ex_tax_code THEN
          return l_msg;
END get_paye_record;

---------------------------------------------------------------------
-- NAME : find_employee                                            --
-- Type : Private Function                                         --
-- DESCRIPTION :                                                   --
-- This function will find employee based on incoming data on the  --
-- EDI.  Function will return 0 if not found, 1 if found and 2 if  --
-- more than 1 match is found                                      --
---------------------------------------------------------------------
FUNCTION find_employee(p_m34_rec  IN OUT nocopy g_tax_code_interface,
                       p_per_rec     OUT nocopy g_typ_per_record) return VARCHAR2
IS
     ex_error exception;
     l_person_rec g_typ_per_record;
     l_last_name  varchar2(255);
     l_counter    number;
     l_null_field number;
     l_count      number;
     l_msg    varchar2(255);
--For Bug 7649174 Start
     /*cursor csr_fetch_asg is
     select max(peo.person_id) p_id,
            peo.last_name,
            peo.full_name,
            peo.national_identifier,
            nvl(peo.per_information10,'N') agg_flag,
            'EMP', --ppt.system_person_type,
            pps.actual_termination_date,
            pps.last_standard_process_date,
            p_m34_rec.effective_date
     from   per_all_people_f         peo,
            per_all_assignments_f    asg,
            per_periods_of_service   pps
     where  asg.business_group_id = g_business_group_id
     and    peo.business_group_id = g_business_group_id
     and    peo.person_id = asg.person_id
     -- Bug 6864422 modified p_m34_rec.full_name to substr of peo.last_name length
     --and    upper(peo.last_name) like upper(substr(rpad(p_m34_rec.full_name,5,'%'), 1, 5))||'%'
       and    upper(peo.last_name) like upper(substr(rpad(substr(p_m34_rec.full_name,1,length(peo.last_name)),5,'%'), 1, 5))||'%'
     --and    upper(substr(rpad(peo.last_name,5,' '),1,5)) = upper(substr(rpad(p_m34_rec.full_name,5,' '), 1, 5))
     and    (p_m34_rec.assignment_number is null or
             asg.assignment_number = p_m34_rec.assignment_number)
     and    (p_m34_rec.national_identifier is null or
             peo.national_identifier like substr(p_m34_rec.national_identifier,1,8)||'%')
     and    pps.period_of_service_id = asg.period_of_service_id
     and    p_m34_rec.effective_date between asg.effective_start_date and asg.effective_end_date
     and    p_m34_rec.effective_date between peo.effective_start_date and peo.effective_end_date
     and    (pps.actual_termination_date is null or
             p_m34_rec.effective_date between pps.date_start and pps.actual_termination_date)
     and    exists (select 1
                    from   per_person_type_usages_f ptu,
                           per_person_types         ppt
                    where  ptu.person_id = peo.person_id
                    and    ptu.person_type_id = ppt.person_type_id
                    and    ppt.system_person_type in ('EMP','EMP_APL')
                    and    p_m34_rec.effective_date between ptu.effective_start_date and ptu.effective_end_date)
     group by peo.last_name, peo.full_name, peo.national_identifier, peo.per_information10,
              'EMP'
              --ppt.system_person_type
              , pps.actual_termination_date, pps.last_standard_process_date
     order by p_id;*/

     cursor csr_fetch_asg_asgno is
     select max(peo.person_id) p_id,
            peo.last_name,
            peo.full_name,
            peo.national_identifier,
            nvl(peo.per_information10,'N') agg_flag,
            'EMP', --ppt.system_person_type,
            pps.actual_termination_date,
            pps.last_standard_process_date,
            p_m34_rec.effective_date
     from   per_all_people_f         peo,
            per_all_assignments_f    asg,
            per_periods_of_service   pps
     where  asg.business_group_id = g_business_group_id
     and    peo.business_group_id = g_business_group_id
     and    peo.person_id = asg.person_id
     -- Bug 6864422 modified p_m34_rec.full_name to substr of peo.last_name length
     --and    upper(peo.last_name) like upper(substr(rpad(p_m34_rec.full_name,5,'%'), 1, 5))||'%'
       and    upper(peo.last_name) like upper(substr(rpad(substr(p_m34_rec.full_name,1,length(peo.last_name)),5,'%'), 1, 5))||'%'
     --and    upper(substr(rpad(peo.last_name,5,' '),1,5)) = upper(substr(rpad(p_m34_rec.full_name,5,' '), 1, 5))
     and    asg.assignment_number = p_m34_rec.assignment_number
     and    p_m34_rec.national_identifier is null
     and    pps.period_of_service_id = asg.period_of_service_id
     and    p_m34_rec.effective_date between asg.effective_start_date and asg.effective_end_date
     and    p_m34_rec.effective_date between peo.effective_start_date and peo.effective_end_date
     and    (pps.actual_termination_date is null or
             p_m34_rec.effective_date between pps.date_start and pps.actual_termination_date)
     and    exists (select 1
                    from   per_person_type_usages_f ptu,
                           per_person_types         ppt
                    where  ptu.person_id = peo.person_id
                    and    ptu.person_type_id = ppt.person_type_id
                    and    ppt.system_person_type in ('EMP','EMP_APL')
                    and    p_m34_rec.effective_date between ptu.effective_start_date and ptu.effective_end_date)
     group by peo.last_name, peo.full_name, peo.national_identifier, peo.per_information10,
              'EMP' /*ppt.system_person_type*/, pps.actual_termination_date, pps.last_standard_process_date
     order by p_id;

     cursor csr_fetch_asg_natid is
     select max(peo.person_id) p_id,
            peo.last_name,
            peo.full_name,
            peo.national_identifier,
            nvl(peo.per_information10,'N') agg_flag,
            'EMP', --ppt.system_person_type,
            pps.actual_termination_date,
            pps.last_standard_process_date,
            p_m34_rec.effective_date
     from   per_all_people_f         peo,
            per_all_assignments_f    asg,
            per_periods_of_service   pps
     where  asg.business_group_id = g_business_group_id
     and    peo.business_group_id = g_business_group_id
     and    peo.person_id = asg.person_id
     -- Bug 6864422 modified p_m34_rec.full_name to substr of peo.last_name length
     --and    upper(peo.last_name) like upper(substr(rpad(p_m34_rec.full_name,5,'%'), 1, 5))||'%'
       and    upper(peo.last_name) like upper(substr(rpad(substr(p_m34_rec.full_name,1,length(peo.last_name)),5,'%'), 1, 5))||'%'
     --and    upper(substr(rpad(peo.last_name,5,' '),1,5)) = upper(substr(rpad(p_m34_rec.full_name,5,' '), 1, 5))
     and    p_m34_rec.assignment_number is null
     and    peo.national_identifier like substr(p_m34_rec.national_identifier,1,8)||'%'
     and    pps.period_of_service_id = asg.period_of_service_id
     and    p_m34_rec.effective_date between asg.effective_start_date and asg.effective_end_date
     and    p_m34_rec.effective_date between peo.effective_start_date and peo.effective_end_date
     and    (pps.actual_termination_date is null or
             p_m34_rec.effective_date between pps.date_start and pps.actual_termination_date)
     and    exists (select 1
                    from   per_person_type_usages_f ptu,
                           per_person_types         ppt
                    where  ptu.person_id = peo.person_id
                    and    ptu.person_type_id = ppt.person_type_id
                    and    ppt.system_person_type in ('EMP','EMP_APL')
                    and    p_m34_rec.effective_date between ptu.effective_start_date and ptu.effective_end_date)
     group by peo.last_name, peo.full_name, peo.national_identifier, peo.per_information10,
              'EMP' /*ppt.system_person_type*/, pps.actual_termination_date, pps.last_standard_process_date
     order by p_id;

     cursor csr_fetch_asg_other is
     select max(peo.person_id) p_id,
            peo.last_name,
            peo.full_name,
            peo.national_identifier,
            nvl(peo.per_information10,'N') agg_flag,
            'EMP', --ppt.system_person_type,
            pps.actual_termination_date,
            pps.last_standard_process_date,
            p_m34_rec.effective_date
     from   per_all_people_f         peo,
            per_all_assignments_f    asg,
            per_periods_of_service   pps
     where  asg.business_group_id = g_business_group_id
     and    peo.business_group_id = g_business_group_id
     and    peo.person_id = asg.person_id
     -- Bug 6864422 modified p_m34_rec.full_name to substr of peo.last_name length
     --and    upper(peo.last_name) like upper(substr(rpad(p_m34_rec.full_name,5,'%'), 1, 5))||'%'
       and    upper(peo.last_name) like upper(substr(rpad(substr(p_m34_rec.full_name,1,length(peo.last_name)),5,'%'), 1, 5))||'%'
     --and    upper(substr(rpad(peo.last_name,5,' '),1,5)) = upper(substr(rpad(p_m34_rec.full_name,5,' '), 1, 5))
     and    asg.assignment_number = p_m34_rec.assignment_number
     and    peo.national_identifier like substr(p_m34_rec.national_identifier,1,8)||'%'
     and    pps.period_of_service_id = asg.period_of_service_id
     and    p_m34_rec.effective_date between asg.effective_start_date and asg.effective_end_date
     and    p_m34_rec.effective_date between peo.effective_start_date and peo.effective_end_date
     and    (pps.actual_termination_date is null or
             p_m34_rec.effective_date between pps.date_start and pps.actual_termination_date)
     and    exists (select 1
                    from   per_person_type_usages_f ptu,
                           per_person_types         ppt
                    where  ptu.person_id = peo.person_id
                    and    ptu.person_type_id = ppt.person_type_id
                    and    ppt.system_person_type in ('EMP','EMP_APL')
                    and    p_m34_rec.effective_date between ptu.effective_start_date and ptu.effective_end_date)
     group by peo.last_name, peo.full_name, peo.national_identifier, peo.per_information10,
              'EMP' /*ppt.system_person_type*/, pps.actual_termination_date, pps.last_standard_process_date
     order by p_id;
 --For Bug 7649174 End
     cursor csr_count_emp(p_tax_district varchar2,
                          p_person_id    number,
                          p_date         date,
                          p_asg_no       varchar2 default null) is
     select count(*)
     from   per_all_assignments_f asg,
            pay_all_payrolls_f    pay,
            hr_soft_coding_keyflex sck
     where  asg.person_id = p_person_id
     and    asg.payroll_id = pay.payroll_id
     and    pay.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
     and    sck.segment1 = p_tax_district
     and    (p_asg_no is null or
             asg.assignment_number = p_asg_no
             )
     and    p_date between asg.effective_start_date and asg.effective_end_date
     and    p_date between pay.effective_start_date and pay.effective_end_date;

     cursor csr_check_future_asg(p_tax_district varchar2,
                                 p_person_id    number,
                                 p_date         date) is
     select count(*)
     from   per_all_people_f      peo,
            per_all_assignments_f asg,
            pay_all_payrolls_f    pay,
            hr_soft_coding_keyflex sck
     where  peo.person_id = p_person_id
     and    asg.person_id = peo.person_id
     and    asg.payroll_id = pay.payroll_id
     and    pay.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
     and    sck.segment1 = p_tax_district
     and    nvl(peo.per_information10,'N') = 'Y'
     and    asg.effective_start_date > p_date
     and    p_date between pay.effective_start_date and pay.effective_end_date
     and    asg.effective_start_date between peo.effective_start_date and peo.effective_end_date
     and    asg.assignment_id not in (select assignment_id
                                      from   per_all_assignments_f asg,
                                             pay_all_payrolls_f    pay,
                                             hr_soft_coding_keyflex sck
                                      where  asg.person_id = p_person_id
                                      and    asg.payroll_id = pay.payroll_id
                                      and    pay.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
                                      and    sck.segment1 = p_tax_district
                                      and    p_date between asg.effective_start_date and asg.effective_end_date
                                      and    p_date between pay.effective_start_date and pay.effective_end_date);

    r_person_rec csr_fetch_asg_other%rowtype;  -- Bug 7649174
BEGIN
     l_null_field := 0;
     if upper(p_m34_rec.national_identifier) like '%NONE%' then
        p_m34_rec.national_identifier := null;
        l_null_field := l_null_field + 1;
     end if;
     if upper(p_m34_rec.assignment_number) like '%NONE%' then
        p_m34_rec.assignment_number := null;
        l_null_field := l_null_field + 1;
     end if;

     if l_null_field > 1 then
        l_msg := err_data_mismatch;
        raise ex_error;
     end if;

     l_counter := 0;
-- For Bug 7649174 Start
/*     for r_person_rec in csr_fetch_asg loop
         l_last_name := r_person_rec.last_name;
         if upper(substr(rpad(l_last_name,5,' '),1,5)) =
	 -- Bug 6864422 modified p_m34_rec.full_name to substr of l_last_name length
         --  upper(substr(rpad(p_m34_rec.full_name,5,' '), 1, 5)) then
	     upper(substr(rpad(substr(p_m34_rec.full_name,1,length(l_last_name)),5,' '), 1, 5)) then
            l_counter := l_counter + 1;
            l_person_rec.person_id       := r_person_rec.p_id;
            l_person_rec.full_name       := r_person_rec.full_name;
            l_person_rec.ni_number       := r_person_rec.national_identifier;
            l_person_rec.aggregate_flag  := r_person_rec.agg_flag;
            l_person_rec.person_type     := 'EMP';
            l_person_rec.term_date       := r_person_rec.actual_termination_date;
            l_person_rec.lsp_date        := r_person_rec.last_standard_process_date;
         end if;
     end loop; */
     if (p_m34_rec.assignment_number is not null and p_m34_rec.national_identifier is null) then
       open csr_fetch_asg_asgno;
     elsif (p_m34_rec.national_identifier is not null and p_m34_rec.assignment_number is null) then
       open csr_fetch_asg_natid;
     else
       open csr_fetch_asg_other;
     end if;
     loop
       if (p_m34_rec.assignment_number is not null and p_m34_rec.national_identifier is null) then
         fetch csr_fetch_asg_asgno into r_person_rec;
         exit when csr_fetch_asg_asgno%notfound;
       elsif (p_m34_rec.national_identifier is not null and p_m34_rec.assignment_number is null) then
         fetch csr_fetch_asg_natid into r_person_rec;
         exit when csr_fetch_asg_natid%notfound;
       else
         fetch csr_fetch_asg_other into r_person_rec;
         exit when csr_fetch_asg_other%notfound;
       end if;
--For Bug 7649174 End
         l_last_name := r_person_rec.last_name;
         if upper(substr(rpad(l_last_name,5,' '),1,5)) =
	 -- Bug 6864422 modified p_m34_rec.full_name to substr of l_last_name length
         --  upper(substr(rpad(p_m34_rec.full_name,5,' '), 1, 5)) then
	     upper(substr(rpad(substr(p_m34_rec.full_name,1,length(l_last_name)),5,' '), 1, 5)) then
            l_counter := l_counter + 1;
            l_person_rec.person_id       := r_person_rec.p_id;
            l_person_rec.full_name       := r_person_rec.full_name;
            l_person_rec.ni_number       := r_person_rec.national_identifier;
            l_person_rec.aggregate_flag  := r_person_rec.agg_flag;
            l_person_rec.person_type     := 'EMP';
            l_person_rec.term_date       := r_person_rec.actual_termination_date;
            l_person_rec.lsp_date        := r_person_rec.last_standard_process_date;
         end if;
     end loop;
 --For Bug 7649174 Start
     if (p_m34_rec.assignment_number is not null and p_m34_rec.national_identifier is null) then
       close csr_fetch_asg_asgno;
     elsif (p_m34_rec.national_identifier is not null and p_m34_rec.assignment_number is null) then
       close csr_fetch_asg_natid;
     else
       close csr_fetch_asg_other;
     end if;
 --For Bug 7649174 End
     if l_counter = 0 then
        raise no_data_found;
     end if;
     if l_counter > 1 then
        raise too_many_rows;
     end if;
     if l_counter = 1 then
        p_per_rec.person_id       := l_person_rec.person_id;
        p_per_rec.full_name       := l_person_rec.full_name;
        p_per_rec.ni_number       := l_person_rec.ni_number;
        p_per_rec.aggregate_flag  := l_person_rec.aggregate_flag;
        p_per_rec.person_type     := l_person_rec.person_type;
        p_per_rec.term_date       := l_person_rec.term_date;
        p_per_rec.lsp_date        := l_person_rec.lsp_date;
        p_per_rec.effective_date  := p_m34_rec.effective_date;
     end if;

     if p_m34_rec.assignment_number is null then
        open csr_count_emp(p_m34_rec.paye_ref,
                           p_per_rec.person_id,
                           p_m34_rec.effective_date);
        fetch csr_count_emp into l_count;
        close csr_count_emp;

        if l_count = 0 then
           l_msg := err_emp_not_found;
           raise ex_error;
        end if;

        if p_per_rec.aggregate_flag = 'N' then
           if l_count > 1 then
              l_msg := err_multi_asg;
              raise ex_error;
           end if;
        end if;
     else -- Even if the assignment number is supplied
          -- we need to check that assignment is on the
          -- given tax district
          open csr_count_emp(p_m34_rec.paye_ref,
                             p_per_rec.person_id,
                             p_m34_rec.effective_date,
                             p_m34_rec.assignment_number);
          fetch csr_count_emp into l_count;
          close csr_count_emp;
          if l_count = 0 then
             l_msg := err_emp_not_found;
             raise ex_error;
          end if;
     end if;

     if p_per_rec.aggregate_flag = 'Y' then
        open csr_check_future_asg(p_m34_rec.paye_ref,
                                  p_per_rec.person_id,
                                  p_m34_rec.effective_date);
        fetch csr_check_future_asg into l_count;
        close csr_check_future_asg;
        if l_count > 0 then
           l_msg := err_future_asg;
           raise ex_error;
        end if;
     end if;

     return null;
EXCEPTION
   when ex_error then
        return l_msg;
   when too_many_rows then
        return err_multiple_found;
   when no_data_found then
        return err_emp_not_found;
   when others then
		--For Bug 7649174 Start
        if csr_fetch_asg_asgno%isopen then
          close csr_fetch_asg_asgno;
        end if;
        if csr_fetch_asg_natid%isopen then
          close csr_fetch_asg_natid;
        end if;
        if csr_fetch_asg_other%isopen then
          close csr_fetch_asg_other;
        end if;
		--For Bug 7649174 End
        raise;
END find_employee;

---------------------------------------------------------------------
-- NAME : update_record                                            --
-- Type : Private Function                                         --
-- DESCRIPTION :                                                   --
-- Function to updates the PAYE Element entries by calling the     --
-- Element Entry API. Returns any message if error found           --
---------------------------------------------------------------------
FUNCTION update_record(p_paye_rec IN g_typ_paye_record,
                       p_per_rec  IN g_typ_per_record,
                       p_m34_rec  IN g_tax_code_interface default null) return VARCHAR2
IS
     l_issue_date         date;
     l_message_date       date;
     l_paye_rec           g_typ_paye_record;
     l_input_value_id_tbl hr_entry.number_table;
     l_entry_value_tbl    hr_entry.varchar2_table;
     l_row_id             rowid;
     l_num_entry_values   number;

     cursor c1 (c_row_id in rowid) is
     select rowid from pay_gb_tax_code_interface
     where rowid = c_row_id
     for update;

BEGIN
     l_paye_rec := p_paye_rec;
     --
     if g_mode in (3,4) then
        l_issue_date := p_m34_rec.issue_date;
        l_message_date := p_m34_rec.date_of_message;
     end if;

     ----------------------------
     -- Convert entry into tbl --
     ----------------------------
     conv_to_table(l_paye_rec,l_num_entry_values,
                   l_input_value_id_tbl,l_entry_value_tbl);
     ----------------------------
     -- Call API to update     --
     ----------------------------

   if g_validate_only ='N'  then /*Added soy 08-09*/
   hr_utility.trace(' In Validate And Commit Mode therefore updating.');

   -- For bug 8485686
   pqp_gb_ad_ee.g_global_paye_validation := 'N';

   hr_entry_api.update_element_entry(
      p_dt_update_mode             => rtrim(p_paye_rec.dt_update_mode),
      p_session_date               => p_per_rec.effective_date,
      p_element_entry_id           => p_paye_rec.element_entry_id,
      p_num_entry_values           => l_num_entry_values,
      p_input_value_id_tbl         => l_input_value_id_tbl,
      p_entry_value_tbl            => l_entry_value_tbl,
      p_entry_information_category => 'GB_PAYE',
      p_entry_information1         => fnd_date.date_to_canonical(l_issue_date),
      p_entry_information2         => fnd_date.date_to_canonical(l_message_date));

   -- For bug 8485686
   pqp_gb_ad_ee.g_global_paye_validation := 'Y';

  end if;

     ---------------------------------------------------
     -- If mode 3 or 4, update the tax code interface --
     ---------------------------------------------------
     if (g_mode in (3,4)) then
        open c1(p_m34_rec.row_id);
        fetch c1 into l_row_id;
        update pay_gb_tax_code_interface
        set    processed_flag = 'P'
        where current of c1;
        close c1;
     end if;
     ------------------------------
     -- Now stamp the creator id --
     ------------------------------
   if g_validate_only ='N' then  /*Added soy 08-09*/
   hr_utility.trace(' In Validate And Commit Mode therefore updating.');
     update pay_element_entries_f pef
     set    pef.creator_id = nvl(g_request_id,g_current_req_id)
     where  pef.element_entry_id     = p_paye_rec.element_entry_id
     and    pef.effective_start_date = p_per_rec.effective_date;
     --and    pef.effective_start_date = p_paye_rec.effective_start_date
     --and    pef.effective_end_date   = p_paye_rec.effective_end_date;
     end if;
     ------------------------------------------
     -- No error, so update the update count --
     ------------------------------------------
     g_update_count := g_update_count + 1;
     --
     return null;
EXCEPTION
     WHEN others THEN
          return substrb(sqlerrm(sqlcode),1,60);
END update_record;

---------------------------------------------------------------------
-- NAME : process_record                                           --
-- Type : Private Procedure                                        --
-- DESCRIPTION :                                                   --
-- This procedure will process the given assignment based on the   --
-- mode                                                            --
---------------------------------------------------------------------
PROCEDURE process_record(p_m12_rec  IN  g_typ_per_record default null,
                         p_m34_rec  IN  g_tax_code_interface default null)
IS
     ex_edi_error      exception;
     ex_resume_mode    exception;
     ex_asg_error      exception;
     ex_not_process    exception;
     l_exists          number;
     l_process         boolean;
     l_dir             varchar2(255);
     l_msg             varchar2(255);
     l_paye_ref        varchar2(30);
     l_asg_number      varchar2(100);
     l_per_record      g_typ_per_record;
     l_paye_rec        g_typ_paye_record;
     l_old_paye_rec    g_typ_paye_record;
     l_m34_rec         g_tax_code_interface;
     -- Start of bug 8510399
     l_count number := 1;
     person_err_status boolean := FALSE;
     -- End of bug 8510399

BEGIN
     l_msg        := null;
     l_paye_ref   := null;
     l_asg_number := null;
     ------------------------------------
     -- First setup the record details --
     ------------------------------------
     if g_mode in (1,2) then
        l_per_record := p_m12_rec;
        l_paye_ref := p_m12_rec.tax_ref; -- Bug#8497477 : assigned tax ref to fetch assignments which has same tax ref.
     elsif g_mode in (3,4) then
        l_m34_rec := p_m34_rec;
        l_msg := find_employee(l_m34_rec, l_per_record);
        -- Start bug#8497477 : Assigned values before the exception as if exception raises we can't assign the values.
        l_paye_ref := l_m34_rec.paye_ref;
        l_asg_number := l_m34_rec.assignment_number;
        if l_msg is not null then
           raise ex_edi_error;
        end if;
	/*l_paye_ref := l_m34_rec.paye_ref;
        l_asg_number := l_m34_rec.assignment_number;*/
        -- End bug#8497477
     end if;
     hr_utility.trace('Start processing record');
     hr_utility.trace('  Person ID   : ' || l_per_record.person_id);
     hr_utility.trace('  NI Number   : ' || l_per_record.ni_number);
     hr_utility.trace('  Aggregated  : ' || l_per_record.aggregate_flag);
     hr_utility.trace('  Director    : ' || l_per_record.director_flag);
     hr_utility.trace('  Person type : ' || l_per_record.person_type);
     hr_utility.trace('  Term date   : ' || l_per_record.term_date);
     hr_utility.trace('  LSP date    : ' || l_per_record.lsp_date);
     hr_utility.trace('  Start date  : ' || l_per_record.start_date);
     hr_utility.trace('  End date    : ' || l_per_record.end_date);

     -----------------------------------------------------------------------
     -- Now, loop through each assignment and see if we should process it --
     -----------------------------------------------------------------------
     -- Start of bug#8510399
     -- New save point is created.
     -- if any of aggregated assignment is failed, we need to rollback the
     -- PAYE uplift changes for all other aggregated assignments.
     -- bug#9253974: -- set save point only for PAYE aggregated person.
        If  l_per_record.aggregate_flag = 'Y' then
           SAVEPOINT  rollback_per_PAYE;
	end if;
     -- End of bug#8510399
     for asg_record in csr_asg_details(l_per_record.person_id,
                                       l_per_record.aggregate_flag,
                                       l_paye_ref,
                                       l_asg_number,
                                       l_per_record.effective_date)
     loop
         hr_utility.trace('Start processing record');
         hr_utility.trace('     Assignment ID : ' || asg_record.assignment_id);
         hr_utility.trace('     Payroll ID    : ' || asg_record.payroll_id);
         hr_utility.trace('     Assignment No : ' || asg_record.assignment_number);
         hr_utility.trace('     Asg Status    : ' || asg_record.asg_status);
         hr_utility.trace('     PAYE Ref      : ' || asg_record.tax_ref);
         --------------------------------------------
         -- Anonymous block to trap non fatal error --
         ---------------------------------------------
           begin

              l_dir := null;
              l_process := true;
	      g_cpe_flag :='Y';    /*Added soy 08-09*/

              ----------------------
              -- Check for EX-EMP --
              ----------------------
              l_msg := check_leaver(l_per_record);
              if l_msg is not null then
                 raise ex_asg_error;
              end if;

              hr_utility.trace('     Fetch PAYE record');
              l_msg := get_paye_record(asg_record.assignment_id,
                                       l_per_record.effective_date,
                                       l_paye_rec);
              ------------------------------
              -- Check for tax code error --
              ------------------------------
              if l_msg is not null then
                 raise ex_asg_error;
              end if;
              --------------------------
              -- See if we found PAYE --
              --------------------------
              if l_paye_rec.element_entry_id is null then
                 if g_mode in (3,4) then
                     l_msg := replace(err_no_paye_ele,'DATE',to_char(l_per_record.effective_date,'DD-MON-YYYY'));
                     raise ex_asg_error;
                 else
                     raise ex_not_process;
                 end if;
              end if;
              ---------------------------
              -- Check for resume mode --
              ---------------------------
              open get_req_cur (l_paye_rec.creator_id);
              fetch get_req_cur into l_exists;
              if get_req_cur%FOUND then
                 l_process := false;
                 hr_utility.trace('     Not processing the assignment');
              end if;
              close get_req_cur;
              ------------------------------------------------------------------
              -- If part of this assignment already been processed            --
              -- we can assumed that the whole person already been processed  --
              -- as the commit is done on a full-person basis                 --
              ------------------------------------------------------------------
              if l_process = false then
                 raise ex_resume_mode;
              end if;

	      --------------------------------------------------------------------------
	      --Check assignment's CPE In case of aggegated and terminated Assignment --
	      --If this terminated assignment is in active CPE then we have to process--
	      --the assignment      Added soy 08-09                                   --
	      --------------------------------------------------------------------------
	      if l_per_record.aggregate_flag ='Y' AND asg_record.asg_status ='TERM_ASSIGN' then
              g_cpe_flag := set_cpe_flag(l_per_record.person_id,
	                                 asg_record.assignment_id,
					 asg_record.tax_ref,
					 l_per_record.effective_date );
              -- Start of bug 8510399
	      if g_cpe_flag = 'N' then
	         raise ex_not_process;
	      end if;
	      -- End of bug 8510399
              end if;
              ------------------------------------
              -- Make a copy of the paye record --
              ------------------------------------
              l_old_paye_rec := l_paye_rec;
              -----------------------------
              -- Set the new PAYE record --
              -----------------------------
	      -- Start of bug#8510399
              l_msg := set_new_paye_record(asg_record.asg_status,
                                           asg_record.assignment_id,
                                           l_paye_rec, l_m34_rec,l_per_record.aggregate_flag);
              if l_msg is not null then
                 if g_payroll_id is not null then
                     if asg_record.payroll_id <> g_payroll_id
                     and l_per_record.aggregate_flag ='N'then
                         raise ex_not_process;
                     else
                         raise ex_asg_error;
                     end if;
                 else
                     raise ex_asg_error;
                 end if;
              end if;
	      -- End of bug#8510399
              hr_utility.trace('     Element Entry ID : ' || l_paye_rec.element_entry_id );
              hr_utility.trace('     Start Date       : ' || l_paye_rec.effective_start_date );
              hr_utility.trace('     End Date         : ' || l_paye_rec.effective_end_date );
              hr_utility.trace('     Tax Code         : ' || l_paye_rec.tax_code_sv );
              hr_utility.trace('     Tax Basis        : ' || l_paye_rec.tax_basis_sv );
              hr_utility.trace('     Previous Pay     : ' || l_paye_rec.pay_previous_sv );
              hr_utility.trace('     Previous Tax     : ' || l_paye_rec.tax_previous_sv );
              hr_utility.trace('     Authority        : ' || l_paye_rec.authority_sv );
              hr_utility.trace('     Done setting new PAYE');
              -----------------------------------------------
              -- If mode 1 then try to process NI director --
              -----------------------------------------------
              if g_mode = 1 then
                 hr_utility.trace('     Check if we need to do any update');
                 l_dir := process_directors(l_per_record,asg_record.assignment_id);
                 if l_paye_rec.tax_basis_amended or l_paye_rec.p45_val_amended or
                     l_paye_rec.tax_code_amended  or l_dir is not null then
                     hr_utility.trace('     Calling update_record to update PAYE');
                     l_msg := update_record(l_paye_rec, l_per_record, l_m34_rec);
                     if l_msg is not null then
                        raise ex_asg_error;
                     end if;
                     hr_utility.trace('     Write out body section');
                     --Start of bug#8510399
		     -- Start bug#8497477 : Report tax ref if current and previous references are not same.
                    -- Bug#9253974 : Write to temporary table if PAYE aggregations is set
                     If  l_per_record.aggregate_flag <> 'Y' then
		     write_Tax_Ref(asg_record.tax_ref,'P');
		     -- End bug#8497477
                     write_body(l_old_paye_rec,l_paye_rec,l_per_record, asg_record.assignment_number,l_dir,
		                 p_m34_rec.effective_date,asg_record.assignment_id, asg_record.tax_ref);
                     else
                     tb_write_paye_rec(l_count).tax_ref := asg_record.tax_ref;
                     tb_write_paye_rec(l_count).status := 'P';
                     tb_write_paye_rec(l_count).old_paye_rec := l_old_paye_rec;
                     tb_write_paye_rec(l_count).paye_rec := l_paye_rec;
                     tb_write_paye_rec(l_count).per_record := l_per_record;
                     tb_write_paye_rec(l_count).assignment_number := asg_record.assignment_number;
                     tb_write_paye_rec(l_count).dir := l_dir;
                     tb_write_paye_rec(l_count).effective_date := p_m34_rec.effective_date;
                     tb_write_paye_rec(l_count).assignment_id := asg_record.assignment_id;
                     l_count := l_count + 1;
		     end if;
		     -- end of bug#8510399
                  end if;
              else
                  hr_utility.trace('     Check if we need to do any update');
     --             if l_paye_rec.tax_basis_amended or l_paye_rec.p45_val_amended or
     --                l_paye_rec.tax_code_amended then
                     hr_utility.trace('     Calling update_record to update PAYE');
           --Added for Bug 7373763
              if g_mode=2 then
                 if l_paye_rec.tax_code_amended=TRUE then
                   l_msg := update_record(l_paye_rec, l_per_record, l_m34_rec);
                   if l_msg is not null then
                      raise ex_asg_error;
                   end if;
                   hr_utility.trace('     Write out body section');
                   --Start of bug#8510399
		   -- Start bug#8497477 : Report tax ref if current and previous references are not same.
                   -- Bug#9253974 : Write to temporary table if PAYE aggregations is set
                   If  l_per_record.aggregate_flag <> 'Y' then
                   write_Tax_Ref(asg_record.tax_ref,'P');
                   -- End bug#8497477
                   write_body(l_old_paye_rec,l_paye_rec,l_per_record, asg_record.assignment_number,l_dir,
                              p_m34_rec.effective_date, asg_record.assignment_id, asg_record.tax_ref);
                    else
                     tb_write_paye_rec(l_count).tax_ref := asg_record.tax_ref;
                     tb_write_paye_rec(l_count).status := 'P';
                     tb_write_paye_rec(l_count).old_paye_rec := l_old_paye_rec;
                     tb_write_paye_rec(l_count).paye_rec := l_paye_rec;
                     tb_write_paye_rec(l_count).per_record := l_per_record;
                     tb_write_paye_rec(l_count).assignment_number := asg_record.assignment_number;
                     tb_write_paye_rec(l_count).dir := l_dir;
                     tb_write_paye_rec(l_count).effective_date := p_m34_rec.effective_date;
                     tb_write_paye_rec(l_count).assignment_id := asg_record.assignment_id;
                     l_count := l_count + 1;
                     end if;
		     -- end of bug#8510399
                 end if;
              else
                   l_msg := update_record(l_paye_rec, l_per_record, l_m34_rec);
                   if l_msg is not null then
                     raise ex_asg_error;
                   end if;
                   hr_utility.trace('     Write out body section');
		   --Start of bug#8510399
                   -- Start bug#8497477 : Report tax ref if current and previous references are not same.
                   -- Bug#9253974 : Write to temporary table if PAYE aggregations is set
                   If  l_per_record.aggregate_flag <> 'Y' then
                   write_Tax_Ref(asg_record.tax_ref,'P');
                   -- End bug#8497477
                   write_body(l_old_paye_rec,l_paye_rec,l_per_record, asg_record.assignment_number,l_dir,
                              p_m34_rec.effective_date, asg_record.assignment_id, asg_record.tax_ref);
	           else
                     tb_write_paye_rec(l_count).tax_ref := asg_record.tax_ref;
                     tb_write_paye_rec(l_count).status := 'P';
                     tb_write_paye_rec(l_count).old_paye_rec := l_old_paye_rec;
                     tb_write_paye_rec(l_count).paye_rec := l_paye_rec;
                     tb_write_paye_rec(l_count).per_record := l_per_record;
                     tb_write_paye_rec(l_count).assignment_number := asg_record.assignment_number;
                     tb_write_paye_rec(l_count).dir := l_dir;
                     tb_write_paye_rec(l_count).effective_date := p_m34_rec.effective_date;
                     tb_write_paye_rec(l_count).assignment_id := asg_record.assignment_id;
                     l_count := l_count + 1;
                    end if;
                     -- end of bug#8510399
              end if;
             --Bug 7373763 ends

     --             end if;
              end if;
         exception
              WHEN ex_not_process THEN
                   null;
              WHEN ex_asg_error THEN
	           -- Bug#8497477 : Passed tax ref to display on output.
		   --Start of bug#8510399
                   -- Bug#9253974 : Write to temporary table if PAYE aggregations is set
                     If  l_per_record.aggregate_flag <> 'Y' then
                     reject_record(l_per_record, l_m34_rec, l_msg, asg_record.assignment_number,asg_record.tax_ref);
		     else
		     person_err_status := TRUE;
                     tb_write_paye_rec(l_count).tax_ref := asg_record.tax_ref;
                     tb_write_paye_rec(l_count).per_record := l_per_record;
                     tb_write_paye_rec(l_count).assignment_number := asg_record.assignment_number;
                     tb_write_paye_rec(l_count).m34_rec := l_m34_rec;
                     tb_write_paye_rec(l_count).err_msg := l_msg;
                     l_count := l_count + 1;
		     end if;
                   -- end of bug#8510399
         end;
         ----------------------------
         -- End of Anonymous block --
         ----------------------------
     end loop;
     --Start of bug#8510399
     -- If any of aggregated assingment is failed, rollback the other aggregated
     -- assingment changes.
      -- Bug#9253974 : Write to temporary table if PAYE aggregations is set
      If  l_per_record.aggregate_flag = 'Y' then
        if person_err_status = TRUE then
           ROLLBACK TO rollback_per_PAYE;
	   For i in 1..tb_write_paye_rec.count
           LOOP
	      reject_record(tb_write_paye_rec(i).per_record,
                          tb_write_paye_rec(i).m34_rec,
                          NVL(tb_write_paye_rec(i).err_msg,err_agg_asg),
                          tb_write_paye_rec(i).assignment_number,
                          tb_write_paye_rec(i).tax_ref);
           END LOOP;
         else
	   For i in 1..tb_write_paye_rec.count
           LOOP
              write_Tax_Ref(tb_write_paye_rec(i).tax_ref,
                            tb_write_paye_rec(i).status);

              write_body(tb_write_paye_rec(i).old_paye_rec,
                         tb_write_paye_rec(i).paye_rec,
                         tb_write_paye_rec(i).per_record,
                         tb_write_paye_rec(i).assignment_number,
                         tb_write_paye_rec(i).dir,
                         tb_write_paye_rec(i).effective_date,
                         tb_write_paye_rec(i).assignment_id,
                         tb_write_paye_rec(i).tax_ref);

            END LOOP;
        end if;
      end if;
        -- Deinitialization
	tb_write_paye_rec.DELETE;
      -- end of bug#8510399

     -- Need to do a commit here
     if g_validate_only ='N' then  /*Added soy 08-09*/
     hr_utility.trace(' In Validate And Commit Mode therefore Commiting.');
        if check_commit then
          commit;
        end if;
     end if;
EXCEPTION
     WHEN ex_edi_error then
          -- Bug#8497477 : Passed tax ref to display on output.
          reject_record(null, l_m34_rec, l_msg, null,l_paye_ref);
     WHEN ex_resume_mode then
          null;
END process_record;

---------------------------------------------------------------------
-- NAME                                                            --
-- pyudet.run_process                             PUBLIC PROCEDURE --
--                                                                 --
-- DESCRIPTION                                                     --
-- The main procedure called from the SRS screen. The success or   --
-- or failure of the process is passed back to the SRS screen in   --
-- the retcode paramater                                           --
---------------------------------------------------------------------
PROCEDURE run_process(errbuf              out nocopy varchar2,
                      retcode             out nocopy varchar2,
                      p_request_id        in  number default null,
                      p_mode              in  number,
                      p_effective_date    in  date,
                      p_business_group_id in  number,
                      p_payroll_id        in  number,
                      p_authority         in  varchar2 default null,
                      p_p6_request_id     in  number default null,
		      p_validate_only     in  VARCHAR2 DEFAULT 'GB_VALIDATE_COMMIT')
IS
     l_m34_rec   g_tax_code_interface;
     l_m12_rec   g_typ_per_record;
     l_person_id per_all_people_f.person_id%type;
     l_process   boolean;
BEGIN
     hr_utility.trace('Start of PYUDET');
     --------------------------------
     -- Setting up GLOBAL variable --
     --------------------------------
     set_global(p_request_id,p_mode,p_effective_date,p_business_group_id,
                p_payroll_id,p_authority,p_p6_request_id,p_validate_only );

     -- Bug#9253974: fetch "HR : GB Override SOY Authority" profile value
     fnd_profile.get('GB_OVERRIDE_SOY', g_SOY_override_profile);

     --------------------------------
     -- Start the process          --
     --------------------------------
     hr_utility.trace('Open main cursor');
     if g_mode in (1,2) then
       open csr_mode12;
     elsif g_mode in (3,4) then
       open csr_mode34;
     end if;
     ------------------
     -- Write header --
     ------------------
     hr_utility.trace('Write report header');
     write_header;
     hr_utility.trace('Write sub-report header');
     write_group_header;

     -- Start the loop
     loop
         hr_utility.trace('In the main loop');
         -- Set l_process to true
         l_process := true;
         --
         if g_mode in(1,2) then
           fetch csr_mode12 into l_m12_rec;
           exit when csr_mode12%notfound;
           -- if the current person = the prev person, don't process
           if l_person_id = l_m12_rec.person_id then
              l_process := false;
           end if;
           -- copy the person id
           l_person_id := l_m12_rec.person_id;
         elsif g_mode in (3,4) then
           fetch csr_mode34 into l_m34_rec;
           exit when csr_mode34%notfound;
         end if;
         -- Process assignment
         if l_process then
            process_record(l_m12_rec,l_m34_rec);
         end if;
     end loop;
     ------------------
     -- Write footer --
     ------------------
     hr_utility.trace('Write report footer');
     write_footer;

      -- Clear out the Tax Code Interface table
     if g_mode in (3,4) then
          hr_utility.trace('Clearing tax code interface');
          delete pay_gb_tax_code_interface
          where  (request_id is null or request_id = g_p6_request_id)
	  and processed_flag = 'P'; /*Added soy 08-09*/
	  commit;
     end if;
 EXCEPTION
    WHEN Others THEN
         hr_utility.trace('Error occurs : ' || sqlerrm);
         if g_mode in (1,2) then
            if csr_mode12%isopen then
               close csr_mode12;
            end if;
         elsif g_mode in (3,4) then
            if csr_mode34%isopen then
               close csr_mode34;
            end if;
         end if;
         rollback;
         errbuf  := sqlerrm;
         retcode := 2;
         raise;
END run_process;

---------------------------------------------------------------------
-- Instantiation Section                                           --
--                                                                 --
-- This section will be executed the first time that the package   --
-- is brought into memory for this session                         --
---------------------------------------------------------------------
BEGIN
     hr_utility.set_location('pyudet',0);
    -------------------------------------------------------------------
    -- Initialize the count variable for the 'uplift_value' function --
    -------------------------------------------------------------------
    g_uplift_value(0) := -1;
    --
    hr_utility.set_location('pyudet',999);
END;

/
