--------------------------------------------------------
--  DDL for Package PAY_1099R_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_1099R_PKG" AUTHID CURRENT_USER as
 /* $Header: pyus109r.pkh 120.1 2006/11/08 13:15:40 alikhar noship $*/
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************  */
/*
rem    Name        :PYUS109R.PKH
rem   Description  :This package defines the cursors needed to run 1099R Information Return
rem                 Multi-Thread.

rem Change List
     -----------
rem   Date         Name        Vers   Description
      -----        ----        -----  -----------
rem  08-SEP-2000  Fusman      115.0    Created
rem  19-JAN-2002  meshah      115.1    dbdrv.
rem  22-JAN-2002  meshah      115.2    dbdrv, checkfile syntax.
rem  09-JAN-2003  asasthan    115.4    nocopy changes
rem  08-NOV-2006  alikhar     115.5    Modified for 1099R PDF conversion
*/

level_cnt number;

procedure range_cursor ( pactid in  number,
                         sqlstr out nocopy varchar2
                       );
procedure action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );
procedure sort_action ( payactid   in     varchar2,
                        sqlstr     in out nocopy  varchar2,
                        len        out  nocopy   number
                      );
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);

PROCEDURE generate_detail_xml;

PROCEDURE generate_header_xml;

PROCEDURE generate_footer_xml;

CURSOR c_1099R_detail IS
SELECT   'TRANSFER_ACT_ID=P',
	 paa1.assignment_action_id
    FROM pay_assignment_actions paa1,
         pay_payroll_actions ppa1,
         pay_assignment_actions paa
   WHERE ppa1.payroll_action_id = pay_magtape_generic.get_parameter_value
                                          ('TRANSFER_PAYROLL_ACTION_ID')
     AND paa1.payroll_action_id = ppa1.payroll_action_id
     AND paa.assignment_action_id = paa1.serial_number
ORDER BY DECODE
            (pay_1099r_pkg.get_parameter ('SORT_1',
                                          ppa1.legislative_parameters
                                         ),
             'Employee_Name', hr_us_w2_rep.get_per_item
                                                    (paa.assignment_action_id,
                                                     'A_PER_LAST_NAME'
                                                    )
              || hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                            'A_PER_FIRST_NAME'
                                           )
              || DECODE
                    (hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                                'A_PER_MIDDLE_NAMES'
                                               ),
                     NULL, NULL,
                     SUBSTR
                        (hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                                    'A_PER_MIDDLE_NAMES'
                                                   ),
                         1,
                         1
                        )
                    ),
             'Social_Security_Number', NVL
                      (hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                                  'A_PER_NATIONAL_IDENTIFIER'
                                                 ),
                       'Applied For'
                      ),
             'Zip_Code', hr_us_w2_rep.get_w2_postal_code
                                                (TO_NUMBER (paa.serial_number),
                                                 ppa1.effective_date
                                                ),
                hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                           'A_PER_LAST_NAME'
                                          )
             || hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                           'A_PER_FIRST_NAME'
                                          )
             || DECODE
                   (hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                               'A_PER_MIDDLE_NAMES'
                                              ),
                    NULL, NULL,
                    SUBSTR
                        (hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                                    'A_PER_MIDDLE_NAMES'
                                                   ),
                         1,
                         1
                        )
                   )
            ),
         DECODE
            (pay_1099r_pkg.get_parameter ('SORT_2',
                                          ppa1.legislative_parameters
                                         ),
             'Employee_Name', hr_us_w2_rep.get_per_item
                                                    (paa.assignment_action_id,
                                                     'A_PER_LAST_NAME'
                                                    )
              || hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                            'A_PER_FIRST_NAME'
                                           )
              || DECODE
                    (hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                                'A_PER_MIDDLE_NAMES'
                                               ),
                     NULL, NULL,
                     SUBSTR
                        (hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                                    'A_PER_MIDDLE_NAMES'
                                                   ),
                         1,
                         1
                        )
                    ),
             'Social_Security_Number', NVL
                      (hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                                  'A_PER_NATIONAL_IDENTIFIER'
                                                 ),
                       'Applied For'
                      ),
             'Zip_Code', hr_us_w2_rep.get_w2_postal_code
                                                (TO_NUMBER (paa.serial_number),
                                                 ppa1.effective_date
                                                ),
             NULL
            ),
         DECODE
            (pay_1099r_pkg.get_parameter ('SORT_3',
                                          ppa1.legislative_parameters
                                         ),
             'Employee_Name', hr_us_w2_rep.get_per_item
                                                    (paa.assignment_action_id,
                                                     'A_PER_LAST_NAME'
                                                    )
              || hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                            'A_PER_FIRST_NAME'
                                           )
              || DECODE
                    (hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                                'A_PER_MIDDLE_NAMES'
                                               ),
                     NULL, NULL,
                     SUBSTR
                        (hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                                    'A_PER_MIDDLE_NAMES'
                                                   ),
                         1,
                         1
                        )
                    ),
             'Social_Security_Number', NVL
                      (hr_us_w2_rep.get_per_item (paa.assignment_action_id,
                                                  'A_PER_NATIONAL_IDENTIFIER'
                                                 ),
                       'Applied For'
                      ),
             'Zip_Code', hr_us_w2_rep.get_w2_postal_code
                                                (TO_NUMBER (paa.serial_number),
                                                 ppa1.effective_date
                                                ),
             NULL
            );


CURSOR c_1099R_hf IS
SELECT  'PAYROLL_ACTION_ID=P'
      ,pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
FROM  dual;

CURSOR c_1099R_asg_actions IS
SELECT  'TRANSFER_ACT_ID=P'
      ,pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
FROM  dual;
--
end pay_1099R_pkg;

/
