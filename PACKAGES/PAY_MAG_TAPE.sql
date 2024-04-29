--------------------------------------------------------
--  DDL for Package PAY_MAG_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MAG_TAPE" AUTHID CURRENT_USER as
/* $Header: pymagtpe.pkh 120.6.12010000.1 2008/07/27 23:09:03 appldev ship $ */
   type host_array is table of VARCHAR(81)
         index by binary_integer;
   internal_prm_names host_array;
   internal_prm_values host_array;
   internal_cxt_names host_array;
   internal_cxt_values host_array;
   internal_xml_names host_array;
   internal_xml_values host_array;

   mag_file varchar2(240);
   rep_file varchar2(240);
   pay_top varchar2(100);
   g_blob_value blob;
   g_blob_file_id number;

   procedure run_proc(comm IN varchar2);
   procedure run_xml_proc(comm in varchar2,
                         source_id in number,
                         source_type in varchar2,
                         file_name in varchar2,
 			 sequence in number);

procedure call_leg_xml_proc;


cursor c_asg_actions
IS
SELECT 'TRANSFER_ACT_ID=P', paa.object_action_id
FROM   pay_temp_object_actions paa
WHERE  paa.payroll_action_id =
         pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');

cursor c_header_footer
is
SELECT 'BG_ID=P', ppa.business_group_id
from pay_payroll_actions ppa
WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value
                              ('TRANSFER_PAYROLL_ACTION_ID');

cursor c_asg_details
is
SELECT 'ASG_ID=P', paa.object_id
FROM   pay_temp_object_actions paa
WHERE  paa.object_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID');

level_cnt number;

end pay_mag_tape;

/
