--------------------------------------------------------
--  DDL for Package Body PAY_CA_DD_MAGTAPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_DD_MAGTAPE_PKG" AS
/* $Header: pycaddmg.pkb 120.8 2006/10/23 19:20:02 pganguly noship $ */


procedure run_formula_or_jcp_xml is
l_ret varchar2(32767);
p_ff_formula_id  varchar2(9);
l_ff_formula_id  varchar2(9);
l_ff_formula_name  varchar2(80);
p_formula_name varchar2(30);
l_outdir varchar2(30);
l_outfile varchar2(30);
l_logfile varchar2(30);
l_xslfile varchar2(30);
l_filename varchar2(30);
l_doctag varchar2(80);
l_fcn varchar2(30);
errbuff varchar2(240);
retcode number;
l_success boolean;
l_originator_id varchar2(25);

cursor c_get_originator_id(cp_payment_method_id number) is
select PMETH_INFORMATION2
from pay_org_payment_methods_f
where org_payment_method_id = cp_payment_method_id;

Begin
/*            hr_utility.trace_on('Y','TESTCADD');  */
     p_formula_name := 'DUMMY_DD_FORMULA';
     g_payroll_action_id := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(3));
    --g_payroll_action_id := 7193;
    hr_utility.trace('g_payroll_action_id = '||to_char(g_payroll_action_id));
--
--   Select all the relevent information using payroll action id
--
     select business_group_id,
            effective_date,
            to_char(overriding_dd_date,'YYMMDD'),
            org_payment_method_id,
            request_id,
            legislative_parameters
       into g_business_group_id,
            g_effective_date,
            g_direct_dep_date,
            g_org_payment_method_id,
            g_request_id,
            g_legislative_parameters
       from pay_payroll_actions
     where  payroll_action_id = g_payroll_action_id;

            if SQL%NOTFOUND then
                hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('PROCEDURE','pay_ca_dd_magtape_pkg');
                hr_utility.set_message_token('STEP','1');
                hr_utility.raise_error;
             end if;

            hr_utility.trace('g_payroll_action_id = '||to_char(g_payroll_action_id));
            hr_utility.trace('g_org_payment_method_id = '||to_char(g_org_payment_method_id));
            hr_utility.trace('g_request_id = '||g_request_id);
    if g_legislative_parameters is not null then

      -- Get the MAGTAPE_REPORT_ID

           g_magtape_report_id := pay_ca_dd_magtape_pkg.get_parameter('MAGTAPE_REPORT_ID',g_legislative_parameters);

            hr_utility.trace('g_magtape_report_id = '||g_magtape_report_id);

      -- Get the File Creation Number Override

           g_fcn_override := pay_ca_dd_magtape_pkg.get_parameter('FILE_CREATION_NUMBER_OVERRIDE',g_legislative_parameters);

            hr_utility.trace('g_fcn_override = '||g_fcn_override);

      -- Get the File Creation Date

           g_file_creation_date := pay_ca_dd_magtape_pkg.get_parameter('FILE_CREATION_DATE',g_legislative_parameters);

            hr_utility.trace('g_file_creation_date = '||g_file_creation_date);

     end if;

     /* Added for FCN Validation */

     if g_org_payment_method_id is not null then
        open c_get_originator_id(g_org_payment_method_id);
        fetch c_get_originator_id into l_originator_id;
        close c_get_originator_id;
     end if;

    /* End for FCN Validation */
/* Testing ---if g_magtape_report_id <> 'BMO' then --'RBC' then --'CIBC' then */
/*            hr_utility.trace_on('Y','MITA'); */
     if g_magtape_report_id not in ('CIBC','NOVA_SCOT','TD','CPA') then
        begin
            hr_utility.trace('In not CIBC');
             pay_magtape_generic.new_formula;

          l_ff_formula_id :=  pay_mag_tape.internal_prm_values(2);

            hr_utility.trace('Formula id is '||l_ff_formula_id);
           if l_ff_formula_id <>  '0'
           then
          begin
           select formula_name
           INTO l_ff_formula_name
             from FF_FORMULAS_F
            where g_effective_date between EFFECTIVE_START_DATE and
                                    EFFECTIVE_END_DATE
              and FORMULA_id     = l_ff_formula_id;
           if l_ff_formula_name  in ('BNC_TRAILER','RBC_TRAILER','BMO_TRAILER')

/* ( 'BNC_HEADER','BNC_MULTI_PAYMENTS',
                                         'BNC_PAYMENT','BNC_REPORT_TITLES' ,
                                         'BNC_TRAILER',
                                         'BMO_BATCH_HEADER',
                                         'BMO_BATCH_TRAILER',
                                         'BMO_HEADER',
                                         'BMO_MULTI_PAYMENTS',
                                         'BMO_PAYMENT','BMO_REPORT_TITLES',
                                         'BMO_TRAILER', 'RBC_HEADER' ,
                                         'RBC_MULTI_PAYMENTS','RBC_PAYMENT',
                                         'RBC_REPORT_TITLES',  'RBC_TRAILER' )
*/
           then
            hr_utility.trace('In raise no_data_found 1');
            raise no_data_found;
         end if;
         exception when no_data_found then
            hr_utility.trace('In raise no_data_found 2');
           raise no_data_found;
        end;
         end if;
        exception when others then
          -- raise no_data_found;
          null;
        end;
     else

      --IF g_magtape_report_id in ('NOVA_SCOT','TD','CIBC') THEN
      --  pay_magtape_generic.new_formula;
      --ELSE
       BEGIN
           select TO_CHAR(FORMULA_ID)
                  INTO p_ff_formula_id
             from FF_FORMULAS_F
            where g_effective_date between EFFECTIVE_START_DATE and
                                    EFFECTIVE_END_DATE
              and FORMULA_NAME     = p_formula_name;


            if SQL%NOTFOUND then
                hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('PROCEDURE','pay_ca_dd_magtape_pkg');
                hr_utility.set_message_token('STEP','1');
                hr_utility.raise_error;
             end if;


            if g_magtape_report_id = 'CIBC' then
              l_xslfile := 'html/pycacibc.xsl'; /* CIBC Bank */
            elsif g_magtape_report_id = 'NOVA_SCOT' then
              l_xslfile := 'html/pycanvsc.xsl'; /*Nova Scotia Bank */
            elsif g_magtape_report_id = 'TD' then
              l_xslfile := 'html/pycatdct.xsl'; /* TD Bank */
            elsif g_magtape_report_id = 'CPA' then
              l_xslfile := 'html/pycacucc.xsl'; /* Credit Union Central
                                                  of Canada */
            end if;


            l_outdir := '/sqlcom/out/';
            l_outfile := 'p'||g_request_id||'.mf';
            l_logfile := 'l'||g_request_id||'.req1';
            l_doctag  := 'PAYMENT_INFO_ROW';

          /* if g_fcn_override is not null then
                 l_fcn := g_fcn_override;
            else
                 l_fcn := pay_ca_direct_deposit_pkg.get_file_creation_number('7000','RBC',null);
            end if;
          */

           /* New FCN validation for XML formats with actual
               parameter values, also includes fix for bug#2790271 */

            if g_fcn_override is not null then
                 l_fcn := pay_ca_direct_deposit_pkg.get_dd_file_creation_number
                          (g_org_payment_method_id,g_magtape_report_id,
                            g_fcn_override,g_payroll_action_id,
                           g_business_group_id);
            else
                 l_fcn := pay_ca_direct_deposit_pkg.get_dd_file_creation_number
                          (g_org_payment_method_id,g_magtape_report_id,
                           null,g_payroll_action_id,g_business_group_id);
            end if;
            hr_utility.trace('l_fcn:'||l_fcn);

            if l_fcn = '1.1'  then
               pay_core_utils.push_message(801,'PAY_74121_FILE_ALREADY_EXISTS','A');
               pay_core_utils.push_token('package','pay_ca_dd_magtape_pkg.run_formula_or_jcp_xml');

               raise hr_utility.hr_error;

            elsif l_fcn = '1.2' then
               pay_core_utils.push_message(801,'PAY_74122_INVALID_FILE_NUMBER','A');
               raise hr_utility.hr_error;

            end if;
            /* New FCN validation for XML formats ends here */

            hr_utility.trace('l_outdir = '||l_outdir);
            hr_utility.trace('l_outfile = '||l_outfile);
            hr_utility.trace('l_logfile = '||l_logfile);
            hr_utility.trace('l_xslfile = '||l_xslfile);
            hr_utility.trace('l_doctag = '||l_doctag);
            hr_utility.trace('l_fcn = '||l_fcn);
            hr_utility.trace('In newdd 6');
           pay_ca_dd_magtape_pkg.submit_xml_mag_jcp(errbuff,
                                                    retcode,
                                                    g_payroll_action_id,
                                                    g_org_payment_method_id,
                                                    l_outdir,
                                                    l_outfile,
                                                    l_logfile,
                                                    l_xslfile,
                                                    l_doctag,
                                                    l_fcn,
                                                    g_request_id,
                                                    l_success
                                                    );
/*        l_ret := pay_xml_magtape_pkg.submit_xml_mag_jcp(7193,1425);    */
           pay_mag_tape.internal_prm_values(1)  := '2';
           pay_mag_tape.internal_prm_values(2)  := p_ff_formula_id;

         if l_success then
            hr_utility.trace('TRUE ' );
         else
            hr_utility.trace('FALSE ' );
         end if;
            hr_utility.trace('retcode = '||to_char(retcode));
            hr_utility.trace('errbuff = '||errbuff );
            hr_utility.trace('In newdd 7');
         if retcode = 2 then
           raise java_conc_error;
         end if;
        exception
           when java_conc_error then
            raise;
        end ;
     -- END IF; -- End IF NOVA_SCOT
     end if;

     if g_magtape_report_id in ('CIBC','NOVA_SCOT','TD','CPA') then
            raise no_data_found;
      else
          l_ff_formula_id :=  pay_mag_tape.internal_prm_values(2);

            hr_utility.trace('Formula id is '||l_ff_formula_id);
          begin
           select formula_name
           INTO l_ff_formula_name
             from FF_FORMULAS_F
            where g_effective_date between EFFECTIVE_START_DATE and
                                    EFFECTIVE_END_DATE
              and FORMULA_id     = l_ff_formula_id;
           if l_ff_formula_name  not in ( 'BNC_HEADER','BNC_MULTI_PAYMENTS',
                                         'BNC_PAYMENT','BNC_REPORT_TITLES' ,
                                         'BNC_TRAILER',
                                         'BMO_BATCH_HEADER',
                                         'BMO_BATCH_TRAILER',
                                         'BMO_HEADER',
                                         'BMO_MULTI_PAYMENTS',
                                         'BMO_PAYMENT','BMO_REPORT_TITLES',
                                         'BMO_TRAILER', 'RBC_HEADER' ,
                                         'RBC_MULTI_PAYMENTS','RBC_PAYMENT',
                                         'RBC_REPORT_TITLES',  'RBC_TRAILER' )
           then
            hr_utility.trace('In raise no_data_found 1');
           select TO_CHAR(FORMULA_ID)
                  INTO p_ff_formula_id
             from FF_FORMULAS_F
            where g_effective_date between EFFECTIVE_START_DATE and
                                    EFFECTIVE_END_DATE
              and FORMULA_NAME     = p_formula_name;
            pay_mag_tape.internal_prm_values(2) :=  p_ff_formula_id;
            raise no_data_found;
         end if;
        end;
        end if;
--            hr_utility.trace_off;

End run_formula_or_jcp_xml;

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
                              ) is

      l6_wait           BOOLEAN;
      l6_phase          VARCHAR2(30);
      l6_status         VARCHAR2(30);
      l6_dev_phase      VARCHAR2(30);
      l6_dev_status     VARCHAR2(30);
      l6_message        VARCHAR2(255);
      l_req_id      NUMBER;
      copies_buffer 	varchar2(80) := null;
      print_buffer  	varchar2(80) := null;
      printer_buffer  	varchar2(80) := null;
      style_buffer  	varchar2(80) := null;
      save_buffer  	    boolean := null;
      save_result  	    varchar2(1) := null;
      req_id 		    VARCHAR2(80) := NULL; /* Request Id of
                                                    the main request */
      x			        BOOLEAN;
      p_result          varchar2(80);
      l_errbuf                VARCHAR2(240);


BEGIN

     BEGIN

      -- initialise variables - 0 is SRS Success, 1 is SRS Warning, 2 is SRS Error
      retcode := 0;

      hr_utility.trace('Before Concurrent Request');

      --      req_id:=fnd_profile.value('CONC_REQUEST_ID');

/*
      l_req_id := fnd_request.submit_request(application    => 'PAY',
                                                 program        => 'JATINJCP',
                                                 argument1      => 'PER');
*/
       hr_utility.trace('payroll_action_id = '||to_char(P_PACTID));
       hr_utility.trace('org_payment_method_id = '||to_char(P_PMETHID));
       hr_utility.trace('P_OUTDIR = '||P_OUTDIR);
       hr_utility.trace('P_OUTFILE = '||P_OUTFILE);
       hr_utility.trace('P_LOGFILE = '||P_LOGFILE);
       hr_utility.trace('P_REQUEST_ID = '||P_REQUEST_ID);
       hr_utility.trace('P_XSLFILE = '||P_XSLFILE);
       hr_utility.trace('P_DOCTAG = '||P_DOCTAG);
       hr_utility.trace('P_FCN = '||P_FCN);

          l_req_id := fnd_request.submit_request(application    => 'PAY',
                                                 program        => 'PYCADDMG',
                                                 argument1      => 'PAY',
                                                 argument2      => P_PACTID,
                                                 argument3      => P_PMETHID,
                                                 argument4      => P_OUTDIR,
                                                 argument5      => P_OUTFILE,
                                                 argument6      => P_REQUEST_ID,
                                                 argument7      => P_XSLFILE,
                                                 argument8      => P_DOCTAG,
                                                 argument9      => P_FCN,
                                                 argument10     => P_LOGFILE
                                                );

    IF(l_req_id = 0) THEN
           p_success := FALSE;
           fnd_message.retrieve(l_errbuf);
           hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);
          -- hr_utility.raise_error;
           raise zero_req_id;
    ELSE
         hr_utility.trace(' Concurrent Request Id  : ' ||to_char(l_req_id));

      COMMIT;

     /* Wait for report request completion */
      hr_utility.trace('Waiting for the application to get completed ');

      /* Check for Report Request Status */

      l6_wait := fnd_concurrent.wait_for_request
                 (request_id => l_req_id
                 ,interval   => 30
                 ,phase      => l6_phase
                 ,status     => l6_status
                 ,dev_phase  => l6_dev_phase
                 ,dev_status => l6_dev_status
                 ,message    => l6_message);

        p_success := TRUE;
       hr_utility.trace('Wait completed');

       hr_utility.trace('phase :'||l6_phase);
       hr_utility.trace('status :'||l6_status);
       hr_utility.trace('dev_phase :'||l6_dev_phase);
       hr_utility.trace('dev_status :'||l6_dev_status);
       hr_utility.trace('message :'||l6_message);

    END IF; /* if l_req_id */

     IF NOT (l6_dev_phase = 'COMPLETE' and l6_dev_status = 'NORMAL') THEN
             hr_utility.trace(' Exited with error ');
             if l6_dev_status = 'WARNING' then
                  retcode := 1;
             else
                  retcode := 2;
             end if;

     ELSE
             hr_utility.trace(' Request completed successfully') ;
             hr_utility.trace('Successful');
     END IF; /* l6_dev_phase */

     -- Set up error message and error return code.
     --
               errbuf  := hr_utility.get_message;


       EXCEPTION
                when zero_req_id then
                raise;

         WHEN NO_DATA_FOUND THEN
              hr_utility.trace('Exception  : No data Found');
              p_success := FALSE;
              l_errbuf := SQLERRM;
              errbuf := l_errbuf;
              hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);
     --
     -- Set up error message and error return code.
     --

               errbuf  := hr_utility.get_message;
         WHEN OTHERS THEN
              hr_utility.trace('Exception    : When Others');
              p_success := FALSE;
              l_errbuf := SQLERRM;
              errbuf := l_errbuf;
              hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);

     --
        END;

             hr_utility.trace('RETCODE : '|| to_char(retcode) ||'ERRBUF: '||errbuf);
--
--

END submit_xml_mag_jcp;
 ----------------------------- get_parameter -------------------------------
 FUNCTION get_parameter(name in varchar2,
                        parameter_list varchar2)
 RETURN VARCHAR2
 IS
   start_ptr number;
   end_ptr   number;
   token_val pay_payroll_actions.legislative_parameters%type;
   par_value pay_payroll_actions.legislative_parameters%type;
 BEGIN

     token_val := name || '=';

     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);

     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list) + 1;
     end if;

     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;

     return par_value;

 END get_parameter;

end pay_ca_dd_magtape_pkg;

/
