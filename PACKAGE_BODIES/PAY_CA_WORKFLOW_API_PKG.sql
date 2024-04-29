--------------------------------------------------------
--  DDL for Package Body PAY_CA_WORKFLOW_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_WORKFLOW_API_PKG" AS
/* $Header: paycawfapipkg.pkb 120.0 2005/05/29 11:10 appldev noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_ca_workflow_api_pkg

    Description :

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    24-JUN-2004 ssouresr   115.0            Created
  ******************************************************************************/


  /* ************************************************************************
     This procedure gets the ROE assignment info and create the document.
     ************************************************************************ */

PROCEDURE get_roe_assignment_info (document_id       in varchar2,
                                   display_type      in varchar2,
                                   document          in out nocopy varchar2,
                                   document_type     in out nocopy varchar2) IS

    ln_request_id  number(15);
    ln_business_group_id  number(15);
    ld_payroll_date_paid  varchar2(20);
    ln_complete number(9);
    ln_error number(9);
    ln_unprocessed number(9);
    X_Segment1 VARCHAR2(240);
    X_Segment2 VARCHAR2(240);
    X_Segment3 VARCHAR2(240);
    l_space varchar2(25);


    CURSOR asg_roe_info_cur (p_req_id number) IS
    SELECT to_char(count(paa.assignment_action_id)) ASG_COUNT,
           paa.action_status ASG_STATUS
    FROM   pay_assignment_actions paa,
           pay_payroll_actions ppa
    WHERE  paa.payroll_action_id  = ppa.payroll_action_id
    AND    ppa.request_id =  to_number(p_req_id)
    AND    ppa.business_group_id = ln_business_group_id
    AND    ppa.effective_date =
                  trunc(to_date(ld_payroll_date_paid,'YYYY/MM/DD HH24:MI:SS'))
    AND    ppa.action_type = 'X'
    AND    ppa.report_type = 'ROE'
    AND    paa.source_action_id is null
    AND    paa.run_type_id is null
    GROUP BY paa.action_status;


  BEGIN

     l_space        := '  ';
     ln_complete    := 0;
     ln_error       := 0;
     ln_unprocessed := 0;

     hr_utility.trace('Before ROE Assignment Information');
     hr_utility.trace('Document Id '||document_id);

     ln_request_id := substr(document_id,1,instr(document_id,':') -1 );
     ln_business_group_id := substr(document_id,instr(document_id,':',1,1)+1 ,
                                              instr(document_id,':',1,2) -instr(document_id,':',1,1)-1 );
     ld_payroll_date_paid := substr(document_id,instr(document_id,':',1,2)+1  );

     hr_utility.trace('ln_request_id = '||ln_request_id);
     hr_utility.trace('ln_business_group_id = '||ln_business_group_id);
     hr_utility.trace('ld_payroll_date_paid = '||ld_payroll_date_paid);

     FOR asg_roe_info_rec IN asg_roe_info_cur (ln_request_id)
     LOOP

        if asg_roe_info_rec.ASG_STATUS = 'C' then
           ln_complete := asg_roe_info_rec.ASG_COUNT;
        elsif asg_roe_info_rec.ASG_STATUS = 'E' then
           ln_error := asg_roe_info_rec.ASG_COUNT;
        elsif asg_roe_info_rec.ASG_STATUS = 'U' then
           ln_unprocessed := asg_roe_info_rec.ASG_COUNT;
        end if;

     END LOOP ;

     X_segment1 := 'Total Assignments Successfully Processed :'||to_char(ln_complete)||l_space||wf_core.newline;
     X_segment2 := 'Total Assignments With Error :'||to_char(ln_error)||l_space||wf_core.newline;
     X_segment3 := 'Total Assignments Not Processed :'||to_char(ln_unprocessed)||l_space||wf_core.newline;

     document := '<p>'||X_segment1||'<br>'||X_segment2||'<br>'||X_segment3||'<br></p>';

     document := document || l_space||wf_core.newline;

     hr_utility.trace('Document  '||document);


     document_type := 'text/html';

     exception when others then
     hr_utility.trace('Exception Others');

end get_roe_assignment_info;


  /* ************************************************************************
     This procedure gets the ROE Magnetic Media assignment info and creates the document.
     ************************************************************************ */


PROCEDURE get_roe_mag_assignment_info (document_id       in varchar2,
                                       display_type      in varchar2,
                                       document          in out nocopy varchar2,
                                       document_type     in out nocopy varchar2) IS

    ln_request_id  number(15);
    ln_business_group_id  number(15);
    ld_payroll_date_paid  varchar2(20);
    ln_complete number(9);
    ln_error number(9);
    ln_unprocessed number(9);
    X_Segment1 VARCHAR2(240);
    X_Segment2 VARCHAR2(240);
    X_Segment3 VARCHAR2(240);
    l_space varchar2(25);


    CURSOR asg_roe_mag_info_cur (p_req_id number) IS
    SELECT to_char(count(paa.assignment_action_id)) ASG_COUNT,
           paa.action_status ASG_STATUS
    FROM   pay_assignment_actions paa,
           pay_payroll_actions ppa
    WHERE  paa.payroll_action_id  = ppa.payroll_action_id
    AND    ppa.request_id =  to_number(p_req_id)
    AND    ppa.business_group_id = ln_business_group_id
    AND    ppa.effective_date =
                  trunc(to_date(ld_payroll_date_paid,'YYYY/MM/DD HH24:MI:SS'))
    AND    ppa.action_type = 'X'
    AND    ppa.report_type = 'MAG_ROE'
    AND    paa.source_action_id is null
    AND    paa.run_type_id is null
    GROUP BY paa.action_status;


  BEGIN

     l_space        := '  ';
     ln_complete    := 0;
     ln_error       := 0;
     ln_unprocessed := 0;

     hr_utility.trace('Before ROE MAG Assignment Information');
     hr_utility.trace('Document Id '||document_id);

     ln_request_id := substr(document_id,1,instr(document_id,':') -1 );
     ln_business_group_id := substr(document_id,instr(document_id,':',1,1)+1 ,
                                              instr(document_id,':',1,2) -instr(document_id,':',1,1)-1 );
     ld_payroll_date_paid := substr(document_id,instr(document_id,':',1,2)+1  );

     hr_utility.trace('ln_request_id = '||ln_request_id);
     hr_utility.trace('ln_business_group_id = '||ln_business_group_id);
     hr_utility.trace('ld_payroll_date_paid = '||ld_payroll_date_paid);

     FOR asg_roe_mag_info_rec IN asg_roe_mag_info_cur (ln_request_id)
     LOOP

        if asg_roe_mag_info_rec.ASG_STATUS = 'C' then
           ln_complete := asg_roe_mag_info_rec.ASG_COUNT;
        elsif asg_roe_mag_info_rec.ASG_STATUS = 'E' then
           ln_error := asg_roe_mag_info_rec.ASG_COUNT;
        elsif asg_roe_mag_info_rec.ASG_STATUS = 'U' then
           ln_unprocessed := asg_roe_mag_info_rec.ASG_COUNT;
        end if;

     END LOOP ;

     X_segment1 := 'Total Assignments Successfully Processed :'||to_char(ln_complete)||l_space||wf_core.newline;
     X_segment2 := 'Total Assignments With Error :'||to_char(ln_error)||l_space||wf_core.newline;
     X_segment3 := 'Total Assignments Not Processed :'||to_char(ln_unprocessed)||l_space||wf_core.newline;

     document := '<p>'||X_segment1||'<br>'||X_segment2||'<br>'||X_segment3||'<br></p>';

     document := document || l_space||wf_core.newline;

     hr_utility.trace('Document  '||document);

     document_type := 'text/html';

     exception when others then
     hr_utility.trace('Exception Others');

end get_roe_mag_assignment_info;

end pay_ca_workflow_api_pkg;

/
