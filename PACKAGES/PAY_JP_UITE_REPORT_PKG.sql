--------------------------------------------------------
--  DDL for Package PAY_JP_UITE_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_UITE_REPORT_PKG" AUTHID CURRENT_USER AS
-- $Header: pyjpuirp.pkh 120.0.12010000.3 2010/04/20 10:46:59 mpothala noship $
-- *******************************************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.                              *
-- * All rights reserved                                                                                 *
-- *******************************************************************************************************
-- *                                                                                                     *
-- * PROGRAM NAME                                                                                        *
-- *  PAY_JP_UITE_REPORT_PKG.pks                                                                         *
-- *                                                                                                     *
-- * DESCRIPTION                                                                                         *
-- * This script creates the package specification of PAY_JP_UITE_REPORT_PKG.                            *
-- *                                                                                                     *
-- * USAGE                                                                                               *
-- *   To Install       sqlplus <apps_user>/<apps_pwd> @PAYJPUITEREPORTPKG.PKH                           *
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC PAY_JP_UITE_REPORT_PKG.<procedure name>      *
-- *                                                                                                     *
-- * PROGRAM LIST                                                                                        *
-- * ==========                                                                                          *
-- * NAME                 DESCRIPTION                                                                    *
-- * -----------------    --------------------------------------------------                             *
-- * RANGE_CURSOR                                                                                        *
-- * ACTION_CREATION                                                                                     *
-- * GEN_XML_HEADER                                                                                      *
-- * GENERATE_XML                                                                                        *
-- * PRINT_CLOB                                                                                          *
-- * GEN_XML_FOOTER                                                                                      *
-- * INIT_CODE                                                                                           *
-- * ARCHIVE_CODE                                                                                        *
-- * ASSACT_XML                                                                                          *
-- * GET_CP_XML                                                                                          *
-- * WRITETOCLOB                                                                                         *
-- * CALLED BY                                                                                           *
-- * Concurrent Program Japan, Terminated Employee Report                                                *
-- *                                                                                                     *
-- * LAST UPDATE DATE                                                                                    *
-- *   Date the program has been modified for the last time                                              *
-- *                                                                                                     *
-- * HISTORY                                                                                             *
-- * =======                                                                                             *
-- *                                                                                                     *
-- * VERSION                DATE          AUTHOR(S)             DESCRIPTION                              *
-- * -------                -----------   ----------------      ----------------------------             *
-- *  120.0.12010000.1      12/02/2010    RDARASI               intial                                   *
-- *  120.0.12010000.2      13/04/2010    RDARASI               Modified as per internal review comments *
-- *  120.0.12010000.3      20/04/2010    RDARASI               Modified as per internal review comments *
-- *******************************************************************************************************
TYPE parameters IS RECORD (payroll_action_id                NUMBER
                          ,ass_setid                        NUMBER
                          ,rep_group                        VARCHAR2(50)
                          ,rep_cat                          VARCHAR2(50)
                          ,business_group_id                NUMBER
                          ,subject_year                     NUMBER
                          ,effective_date                   DATE
                          ,payroll_arch                     NUMBER
                          ,sort_order                       VARCHAR2(50)
                         );
--
gr_parameters              parameters;
--
g_msg_circle               fnd_new_messages.message_text%TYPE;
--
g_mag_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
--
TYPE XMLRec IS RECORD (xmlstring CLOB);
--
TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
--
vXMLTable                  tXMLTable;
--
level_cnt                  NUMBER;
-- *********************
-- Cursors Declaration *
-- *********************
--
CURSOR c_header
IS
SELECT 1
FROM   dual ;
--
CURSOR c_footer
IS
SELECT 1
FROM   dual ;
--
CURSOR eof
IS
SELECT 1
FROM   dual ;
--
CURSOR c_body
IS
SELECT 'TRANSFER_ACT_ID=P'
      , assignment_action_id
FROM   pay_assignment_actions
WHERE  payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
ORDER BY action_sequence;

-- ************************
-- Procedures Declaration *
-- ************************
--

PROCEDURE gen_xml_header;
--
PROCEDURE gen_xml_footer;
--
PROCEDURE generate_xml;
--
PROCEDURE range_cursor           ( P_PAYROLL_ACTION_ID  IN         NUMBER
                                 , P_SQLSTR             OUT NOCOPY VARCHAR2
                                 );
--
PROCEDURE get_numbers  ( p_input      IN               NUMBER
                       , p_input1     IN               VARCHAR2
                       , p_output     OUT      NOCOPY  VARCHAR2
                       );
--
PROCEDURE action_creation        ( P_PAYROLL_ACTION_ID             NUMBER
                                 , P_START_PERSON_ID               NUMBER
                                 , P_END_PERSON_ID                 NUMBER
                                 , P_CHUNK                         NUMBER
                                 );
--
PROCEDURE init_code              ( P_PAYROLL_ACTION_ID    IN       NUMBER) ;
--
PROCEDURE archive_code           ( P_ASSIGNMENT_ACTION_ID IN       NUMBER
                                 , P_EFFECTIVE_DATE       IN       DATE );
--
PROCEDURE assact_xml             ( p_assignment_action_id IN       NUMBER );

--
PROCEDURE deinitialise           ( p_payroll_action_id    IN       NUMBER);
--
PROCEDURE get_cp_xml             ( p_assignment_action_id IN       NUMBER
                                 , p_xml                  OUT NOCOPY CLOB
                                 );
--
PROCEDURE writetoclob            ( p_write_xml            OUT NOCOPY CLOB );
--
PROCEDURE print_clob             ( p_clob                 IN CLOB );
--
--
PROCEDURE sort_action            ( p_payroll_action_id   IN     NUMBER
                                 , sqlstr                IN OUT NOCOPY VARCHAR2
                                 , len                   OUT    NOCOPY NUMBER);

--
END PAY_JP_UITE_REPORT_PKG;

/
