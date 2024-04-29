--------------------------------------------------------
--  DDL for Package PAY_JP_WL_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_WL_REPORT_PKG" AUTHID CURRENT_USER AS
-- $Header: payjpwlreportpkg.pkh 120.0.12010000.7 2009/10/22 14:16:55 rdarasi noship $
-- *******************************************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.                              *
-- * All rights reserved                                                                                 *
-- *******************************************************************************************************
-- *                                                                                                     *
-- * PROGRAM NAME                                                                                        *
-- *  PAY_JP_WL_REPORT_PKG.pks                                                                           *
-- *                                                                                                     *
-- * DESCRIPTION                                                                                         *
-- * This script creates the package specification of PAY_JP_WL_REPORT_PKG.                              *
-- *                                                                                                     *
-- * USAGE                                                                                               *
-- *   To install       sqlplus <apps_user>/<apps_pwd> @PAYJPWLREPORTPKG.pkh                             *
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC PAY_JP_WL_REPORT_PKG.<procedure name>        *
-- *                                                                                                     *
-- * PROGRAM LIST                                                                                        *
-- * ==========                                                                                          *
-- * NAME                 DESCRIPTION                                                                    *
-- * -----------------    --------------------------------------------------                             *
-- * CHK_ASS_SET                                                                                         *
-- * GET_AMENDMENT_FLAG                                                                                  *
-- * CHK_ASS_SET_MIXED                                                                                   *
-- * CHK_ALL_EXCLUSIONS                                                                                  *
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
-- * Concurrent Program JP WithHolding Book Report                                                       *
-- *                                                                                                     *
-- * LAST UPDATE DATE                                                                                    *
-- *   Date the program has been modified for the last time                                              *
-- *                                                                                                     *
-- * HISTORY                                                                                             *
-- * =======                                                                                             *
-- *                                                                                                     *
-- * VERSION DATE         AUTHOR(S)             DESCRIPTION                                              *
-- * ------- -----------  ----------------      ----------------------------                             *
-- *  Draft  09/08/2009    RDARASI               intial                                                  *
-- *******************************************************************************************************
TYPE parameters IS RECORD (payroll_action_id                NUMBER
                          ,ass_setid                        NUMBER
                          ,rep_group                        VARCHAR2(50)
                          ,rep_cat                          VARCHAR2(50)
                          ,business_group_id                NUMBER
                          ,include_org_hierarchy            VARCHAR2(1)
                          ,organization_id                  NUMBER
                          ,effective_date                   DATE
                          ,subject_yyyymm                   VARCHAR2(50)
                          ,location                         NUMBER
                          ,payroll                          NUMBER
                          ,income_tax_withholding_agent     NUMBER
                          ,output_terminated_employees      VARCHAR(10)
                          ,termination_date_from            DATE
                          ,termination_date_to              DATE
                          ,sort_order_1                     VARCHAR2(50)
                          ,sort_order_2                     VARCHAR2(50)
                          ,sort_order_3                     VARCHAR2(50)
                         );
--
gr_parameters              parameters;
--
g_msg_circle               fnd_new_messages.message_text%TYPE;
--
g_mag_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
--
TYPE XMLRec IS RECORD( xmlstring CLOB);
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
                                 , len                   OUT   NOCOPY NUMBER);

--
END PAY_JP_WL_REPORT_PKG;

/
