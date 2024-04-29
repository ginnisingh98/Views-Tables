--------------------------------------------------------
--  DDL for Package PER_JP_EMPDET_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JP_EMPDET_REPORT_PKG" AUTHID CURRENT_USER
-- $Header: pejperpt.pkh 120.0.12010000.8 2009/09/09 11:55:48 mpothala noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  pejperpt.pkh
-- *
-- * DESCRIPTION
-- * This script creates the package header of per_jp_empdet_report_pkg.
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   08-JUN-2009
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * DATE        AUTHOR(S)  VERSION           BUG NO   DESCRIPTION
-- * -----------+---------+-----------------+---------+--------------------+--------------------------------------------------------------------------------------
-- * 17-APR-2009 SPATTEM    120.0.12010000.1  8574160  Creation
-- * 26-JUN-2009 SPATTEM    120.0.12010000.4  8574160  Added payroll_action_id
-- *                                                   , assignment_set_id to parameters RECORD
-- * 27-JUL-2009 MDARBHA    120.0.12010000.5  8574160  Changed the Variable type of xmlrec from VARCHAR to CLOB
-- * 03-AUG-2009 MDARBHA    120.0.12010000.6  8727238  Changed the cursor c_body for sort order
-- * 19-AUG-2009 RDARASI    120.1.12010000.7  8766043  Changed sort_action Procedure
-- * 09-SEP-2009 MPOTHALA   120.1.12010000.8  8843783  Added job_hist_type Type
-- **********************************************************************************************************
AS
  --
  TYPE job_hist_type IS RECORD(assignment_id   per_assignments_f.assignment_id%TYPE
                              ,start_date      VARCHAR2(20)
                              ,end_date        VARCHAR2(20)
                              ,company_name   hr_organization_units.name%TYPE
                               );
  TYPE gt_job_tbl IS TABLE of job_hist_type INDEX BY binary_integer;
  --
  TYPE parameters IS RECORD (payroll_action_id     NUMBER
                            ,assignment_set_id     NUMBER
                            ,business_group_id     NUMBER
                            ,organization_id       NUMBER
                            ,location_id           NUMBER
                            ,effective_date        DATE
                            ,include_org_hierarchy VARCHAR2(1)
                            ,incl_term_emp         VARCHAR2(10)
                            ,term_date_from        DATE
                            ,term_date_to          DATE
                            ,img_display           VARCHAR2(10)
                            ,sort_order_1          VARCHAR(30)
                            ,sort_order_2          VARCHAR(30)
                            ,sort_order_3          VARCHAR(30)
                            );

  gr_parameters              parameters;
  g_mag_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
--
  TYPE xmlrec IS RECORD(xmlstring CLOB);
  TYPE txmltable IS TABLE OF xmlrec INDEX BY BINARY_INTEGER;
--
  vxmltable txmltable;
  level_cnt      NUMBER;
--
  CURSOR c_header
  IS
  SELECT 1
  FROM dual ;
--
  CURSOR c_footer
  IS
  SELECT 1
  FROM dual ;
--
  CURSOR eof
  IS
  SELECT 1
  FROM dual ;
--
  CURSOR c_body
  IS
  SELECT 'TRANSFER_ACT_ID=P'
         ,assignment_action_id
  FROM   pay_assignment_actions
  WHERE  payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
  ORDER BY action_sequence; --Bug  8727238
--
  PROCEDURE range_cursor      ( p_payroll_action_id IN         NUMBER
                              , p_sqlstr            OUT NOCOPY VARCHAR2
                              );
--
  PROCEDURE sort_action       ( p_payroll_action_id IN            NUMBER  -- Added by RDARASI for Bug#8766043
                              , sqlstr              IN OUT NOCOPY VARCHAR2
                              , len                    OUT NOCOPY NUMBER
                              );
--
  PROCEDURE action_creation   ( p_payroll_action_id IN NUMBER
                              , p_start_person_id   IN NUMBER
                              , p_end_person_id     IN NUMBER
                              , p_chunk             IN NUMBER
                              );
--
  PROCEDURE gen_xml_header;
--
  PROCEDURE generate_xml;
--
  PROCEDURE print_clob        ( p_clob IN CLOB );
--
  PROCEDURE gen_xml_footer;
--
  PROCEDURE init_code         (p_payroll_action_id IN  NUMBER);
--
  PROCEDURE archive_code      ( p_assignment_action_id IN NUMBER
                              , p_effective_date       IN DATE
                              );
--
  PROCEDURE assact_xml        ( p_assignment_action_id IN NUMBER);
--
  PROCEDURE get_cp_xml        ( p_assignment_action_id IN  NUMBER
                              , p_xml                  OUT NOCOPY CLOB
                              );
--
  PROCEDURE writetoclob       ( p_write_xml OUT NOCOPY CLOB);
--
  PROCEDURE deinitialise      (p_payroll_action_id IN NUMBER);
--
END per_jp_empdet_report_pkg;

/
