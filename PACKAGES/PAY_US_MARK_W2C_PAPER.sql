--------------------------------------------------------
--  DDL for Package PAY_US_MARK_W2C_PAPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_MARK_W2C_PAPER" AUTHID CURRENT_USER AS
/* $Header: payusmarkw2cpapr.pkh 120.0.12010000.1 2008/07/27 21:55:59 appldev ship $*/
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

    Name        : pay_us_mark_w2c_paper
    File Name   : payusmarkw2cpapr.pkh

    Description : Mark all assignment action included in  W-2c Report process
                  confirming W-2c paper submitted to Govt. Once a corrected
                  assignment is marked as submitted, this assignment will not
                  be picked up by "Federeal W-2c Magnetic Media" process.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No   Description
    ----        ----     ------  -------  -----------
    10-Oct-2003 ppanda   115.0            Created.
    02-DEC-2003 ppanda   115.1   3275044  A fatal error will be raised
                                          when no W-2c paper assignment action
                                          picked up by the process
    10-NOV-2004 asasthan 115.2   3264740  Detail Report provided.
  *******************************************************************/

  /*******************************************************************
  ** Function gets the W-2c Mag Report Action Parameters
  ******************************************************************/

  PROCEDURE get_payroll_action_info
  (
        p_payroll_action_id     in      number,
        p_start_date            in out  nocopy date,
        p_end_date              in out  nocopy date,
        p_report_type           in out  nocopy varchar2,
        p_report_qualifier      in out  nocopy varchar2,
        p_business_group_id     in out  nocopy number,
        p_seq_num               in out  nocopy number
  );

  FUNCTION preprocess_check  (p_payroll_action_id   IN NUMBER,
                              p_start_date   	    IN DATE,
                              p_end_date  		    IN DATE,
                              p_business_group_id	IN NUMBER
                              ) RETURN BOOLEAN;


  /*******************************************************************
  ** Range Code to pick all the distinct assignment_ids
  ** that need to be marked as submitted to governement.
  *******************************************************************/
  PROCEDURE mark_w2c_range_cursor( p_payroll_action_id  in         number
                                  ,p_sqlstr             out nocopy varchar2);

  /*******************************************************************
  ** Action Creation Code to create assignment actions for all the
  ** the assignment_ids that need to be marked as submitted to governement
  *******************************************************************/
  PROCEDURE mark_w2c_action_creation( p_payroll_action_id    in number
                                     ,p_start_person_id      in number
                                     ,p_end_person_id        in number
                                     ,p_chunk                in number);

  PROCEDURE select_ee_details(errbuf              OUT nocopy VARCHAR2,
                              retcode             OUT nocopy NUMBER,
                              p_seq_num            IN        VARCHAR2,
                              p_output_file_type   IN        VARCHAR2);

END pay_us_mark_w2c_paper;

/
