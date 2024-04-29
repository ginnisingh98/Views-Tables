--------------------------------------------------------
--  DDL for Package PAY_GB_P11D_MILEAGE_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_P11D_MILEAGE_EXTRACT" AUTHID CURRENT_USER as
/* $Header: pygbmxpl.pkh 115.0 2003/04/30 08:31:57 gbutler noship $
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2003 Oracle Corporation UK Ltd.,                *
   *                   Reading, England.                            *
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
   ******************************************************************

    Name        : pay_gb_p11d_mileage_extract

    Description : This package contains functions and procedures to
    		  create the extract file for P11d Mileage Claims

    Uses        :

    Used By     : P11d 2003 Mileage Claims Extract Process


    Change List :

    Version     Date     Author         Description
    -------     -----    --------       ----------------

     115.0      14/4/03  GBUTLER        Created

*/

FUNCTION check_person_inclusion (p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION post_process_rule(p_ext_rslt_id IN NUMBER) RETURN VARCHAR2;

FUNCTION ben_start_date (p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION ben_end_date (p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION mileage_balance (p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION add_pass_balance (p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION asg_start_date (p_assignment_id IN NUMBER) RETURN VARCHAR2;

FUNCTION asg_end_date (p_assignment_id IN NUMBER) RETURN VARCHAR2;



end pay_gb_p11d_mileage_extract;

 

/
