--------------------------------------------------------
--  DDL for Package PAY_CA_DD_MAGTAPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_DD_MAGTAPE_PKG" AUTHID CURRENT_USER AS
/* $Header: pycaddmg.pkh 120.3.12000000.1 2007/01/17 16:54:43 appldev noship $ */

-- Global Variable for the Package

   TYPE tt_used_results IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;

   g_effective_date         date          := null;
   g_business_group_id      number        := 0;
   g_payroll_action_id      number        := 0;
   g_assignment_id          number        := 0;
   g_assignment_action_id   number        := 0;
   g_personal_payment_method_id number    := 0;
   g_org_payment_method_id  number        := 0;   /* Tape Level Id*/
   g_csr_org_pay_meth_id    number        := 0;   /* Assignment Level Id */
   g_csr_org_pay_third_party varchar2(1)   := null;
   g_pad_count              number        := 0;
   g_temp_count             number        := 0;
   g_count                  number        := 0;
   g_addenda_count          number        := 0;
   g_hash                   number        := 0;
   g_amount                 number        := 0;
   g_batch_number           number        := 0;
   g_legal_company_id       number        := 0;
   g_addenda_write          varchar2(1)   := 'N';
   g_batch_control_write    varchar2(1)   := 'N';
   g_file_id_modifier       varchar2(1)   := null;
   g_company_entry_desc     varchar2(10)  := null;
   g_descriptive_date       varchar2(6)   := null;
   g_file_header            varchar2(9)   := null;
   g_batch_header           varchar2(9)   := null;
   g_org_pay_dummy          varchar2(9)   := null;
   g_entry_detail           varchar2(9)   := null;
   g_addenda                varchar2(9)   := null;
   g_org_pay_entry_detail   varchar2(9)   := null;
   g_batch_control          varchar2(9)   := null;
   g_file_control           varchar2(9)   := null;
   g_nacha_dest_code        varchar2(8)   := null;
   g_padding                varchar2(8)   := null;
   g_direct_dep_date        varchar2(6)   := null;
   g_legislative_parameters varchar2(240) := null;
   g_date                   varchar2(06)  := TO_CHAR(SYSDATE,'YYMMDD');
   g_time                   varchar2(04)  := TO_CHAR(SYSDATE,'HHMI');
   g_request_id             varchar2(15)  := null;
   g_magtape_report_id      varchar2(50)  := null;
   g_fcn_override           varchar2(50)  := null;
   g_file_creation_date     varchar2(20)  := null;


 --
  -- Exception Handlers
  --
  zero_req_id                 Exception;
  pragma exception_init(zero_req_id, -9999);
  --
  java_conc_error                 Exception;
  pragma exception_init(java_conc_error, -9999);



procedure run_formula_or_jcp_xml;

CURSOR csr_nacha_batch (p_business_group_id number,
			  p_payroll_action_id number) IS

    select distinct
          PREPAY.ORG_PAYMENT_METHOD_ID,
	  decode(nvl(to_char(OPM.DEFINED_BALANCE_ID),'Y'),'Y','Y','N'),
	  HRORGU.ORGANIZATION_ID,
	  opm.pmeth_information6
     from
          PAY_PRE_PAYMENTS                PREPAY,
	  PAY_ORG_PAYMENT_METHODS_F	  OPM,
	  HR_ORGANIZATION_UNITS		  HRORGU,
	  HR_ORGANIZATION_INFORMATION	  HROINF

    where
       OPM.ORG_PAYMENT_METHOD_ID	= PREPAY.ORG_PAYMENT_METHOD_ID
      and  g_effective_date between OPM.EFFECTIVE_START_DATE and
				   OPM.EFFECTIVE_END_DATE
      and HRORGU.BUSINESS_GROUP_ID          = p_business_group_id
      and OPM.BUSINESS_GROUP_ID             = p_business_group_id
      and HRORGU.ORGANIZATION_ID            = HROINF.ORGANIZATION_ID
      and HROINF.ORG_INFORMATION_CONTEXT    = 'CLASS'
      and HROINF.ORG_INFORMATION1           = 'HR_LEGAL'
      and HROINF.ORG_INFORMATION2           = 'Y'
      and EXISTS
          ( select 1
              from PER_ASSIGNMENTS_F          PERASG,
                   PAY_ASSIGNMENT_ACTIONS     PYAACT,
                   HR_SOFT_CODING_KEYFLEX     HRFLEX
             where HRFLEX.SEGMENT1               = to_char(HRORGU.ORGANIZATION_ID)
               and PERASG.SOFT_CODING_KEYFLEX_ID =
                                            HRFLEX.SOFT_CODING_KEYFLEX_ID
               and g_effective_date between PERASG.EFFECTIVE_START_DATE and
                                            PERASG.EFFECTIVE_END_DATE
               and PERASG.ASSIGNMENT_ID          = PYAACT.ASSIGNMENT_ID
	       and PYAACT.PRE_PAYMENT_ID	 = PREPAY.PRE_PAYMENT_ID
               and PYAACT.PAYROLL_ACTION_ID      = p_payroll_action_id);

function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
procedure  submit_xml_mag_jcp(
                              ERRBUF       OUT NOCOPY VARCHAR2,
                              RETCODE      OUT NOCOPY NUMBER,
                              P_PACTID     in number,
                              P_PMETHID    in number,
                              P_OUTDIR     in varchar2,
                              P_OUTFILE    in varchar2,
                              P_LOGFILE    in varchar2,
                              P_XSLFILE    in varchar2,
                              P_DOCTAG     in varchar2,
                              P_FCN        in varchar2,
                              P_REQUEST_ID in out NOCOPY number,
                              P_SUCCESS    out NOCOPY boolean
                              );
end pay_ca_dd_magtape_pkg;
 

/
