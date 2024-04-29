--------------------------------------------------------
--  DDL for Package PER_JP_WRKREG_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JP_WRKREG_REPORT_PKG" AUTHID CURRENT_USER
-- $Header: pejpwrpt.pkh 120.0.12010000.5 2009/07/30 11:03:39 mdarbha noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  pejpwrpt.pkh
-- *
-- * DESCRIPTION
-- * This script creates the package specification of per_jp_wrkreg_report_pkg.
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   9-JUN-2009
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * DATE                   AUTHOR(S)  VERSION            BUG NO    DESCRIPTION
-- * --------------------+--------------+-----------------------+--------------+------------------+----------------+-----------------+-----------
-- * 19-MAR-2009 MDARBHA    120.0.12010000.1    8558615   Creation
-- * 09-JUN-2009 MDARBHA    120.0.12010000.2   8558615   Changed as per review Comments
-- * 20-JUL-2009 MDARBHA    120.0.12010000.3   8558615   Changed the type of xmlrec from varchar to CLOB
-- ************************************************************************************************
AS
  TYPE parameters IS RECORD (payroll_action_id  NUMBER
                            ,ass_setid         NUMBER
                            ,business_group_id NUMBER
                            ,include_org_hierarchy VARCHAR2(1)
                            ,organization_id   NUMBER
                            ,location_id       NUMBER
                            ,effective_date    DATE
                            ,sort_order_1      VARCHAR(30)
                            ,sort_order_2      VARCHAR(30)
                            ,sort_order_3      VARCHAR(30)
                            ,incl_term_emp      VARCHAR(10)
                            ,term_eff_date_from DATE
                            ,term_eff_date_to   DATE
                           );
--
  gr_parameters parameters;
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
  SELECT 'TRANSFER_ACT_ID=P',
         assignment_action_id
  FROM   pay_assignment_actions
  WHERE  payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
  ORDER BY action_sequence;
--
  PROCEDURE range_cursor      ( p_payroll_action_id IN         NUMBER
                              , p_sqlstr            OUT NOCOPY VARCHAR2
                              );
--
  PROCEDURE sort_action       ( p_payroll_action_id   IN     NUMBER,
                                sqlstr                IN OUT NOCOPY VARCHAR2,
                                len                   OUT   NOCOPY NUMBER
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
END per_jp_wrkreg_report_pkg;

/
