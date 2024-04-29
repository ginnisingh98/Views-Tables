--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA_REPORTS_PKG" as
/* $Header: pykryearept.pkb 120.2.12000000.1 2007/02/09 05:46:11 viagarwa noship $ */
--------------------------------------------------------------------------------
function submit_yea_report (
        p_bus_grp_id    number,
        p_bus_plc_id    number,
        p_year          varchar2,
        p_asg_id        number,
        p_assact_id     number,
        p_report_name   varchar2
) return number
is
        --
        l_request_id    number ;
        --
begin
        --
        l_request_id := fnd_request.submit_request(
                application => 'PAY',
                program     => 'PAYKRYEA_XDO',
                description => 'Submit KR YEA Reports (XDO)',
                argument1   => p_bus_grp_id,
                argument2   => p_bus_plc_id,
                argument3   => p_year,
                argument4   => p_asg_id,
                argument5   => p_assact_id,
                argument6   => p_report_name
        ) ;

      -- Check the status
      if l_request_id <> 0 then
         commit;
      end if;
      --
      return l_request_id;
end submit_yea_report ;
--------------------------------------------------------------------------------
function submit_xml_report (
        p_bus_grp_id    in number,
        p_bus_plc_id    in number,
        p_year          in varchar2,
        p_asg_id        in number,
        p_assact_id     in number,
        p_report_name   in varchar2
) return number
is
/* Bug # 5563442 Date passed in the wrong format - Changing l_report_date datatype to VARCHAR2 */
	--
        l_report_date           varchar2(20);
	--
        l_request_id            number ;
        l_phase                 varchar2(100);
        l_status                varchar2(100);
        l_dev_status            varchar2(100);
        l_dev_phase             varchar2(100);
        l_message               varchar2(2000);
        l_action_completed      boolean;
        --
begin
	--
/* Bug # 5563442 Date passed in the wrong format - Passing l_report_date in Canonical form */
        --
        l_report_date := fnd_date.date_to_canonical(to_date('3112'||p_year, 'DDMMYYYY')) ;
        --

        -- Submit the appropriate report by looking at p_report_name
        if p_report_name = 'PAYKRYRS' then -- Submit YEA Reclaim Sheet
                l_request_id := fnd_request.submit_request(
                        application => 'PAY',
                        program     => 'PAYKRYRS_XML',
                        description => 'KR Year End Adjustment Reclaim Sheet - XML',
                        argument1   => p_bus_grp_id,
                        argument2   => p_bus_plc_id,
                        argument3   => p_year,
                        argument4   => p_asg_id
                );
        elsif p_report_name = 'PAYKRYLG' then -- Submit YEA Ledger
                l_request_id := fnd_request.submit_request(
                        application => 'PAY',
                        program     => 'PAYKRYLG_XML',
                        description => 'KR Year End Adjustment Ledger - XML',
                        argument1   => p_bus_plc_id,
                        argument2   => p_asg_id,
                        argument3   => p_assact_id,
                        argument4   => l_report_date
                );
        elsif p_report_name = 'PAYKRYTR' then -- Submit YEA Tax Receipt
                l_request_id := fnd_request.submit_request(
                        application => 'PAY',
                        program     => 'PAYKRYTR_XML',
                        description => 'KR Year End Adjustment Tax Receipt - XML',
                        argument1   => p_bus_plc_id,
                        argument2   => p_asg_id,
                        argument3   => p_assact_id,
                        argument4   => l_report_date,
                        argument5   => 'R',
                        argument6   => 'EK'
                );
        end if ;

        -- Check the status
        if l_request_id <> 0 then
           -- Save the request and wait for completion
           commit;
           l_dev_phase := 'dummy';
           while (l_dev_phase <> 'COMPLETE') loop
                l_action_completed := fnd_concurrent.wait_for_request(
                        request_id  =>      l_request_id,
                        interval    =>      1,
                        max_wait    =>      10,
                        phase       =>      l_phase,
                        status      =>      l_status,
                        dev_phase   =>      l_dev_phase,
                        dev_status  =>      l_dev_status,
                        message     =>      l_message
                );
           end loop;
        end if;

        return l_request_id;
end submit_xml_report ;
--------------------------------------------------------------------------------
end pay_kr_yea_reports_pkg ;

/
