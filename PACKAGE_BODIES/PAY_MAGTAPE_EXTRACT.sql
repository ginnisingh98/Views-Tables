--------------------------------------------------------
--  DDL for Package Body PAY_MAGTAPE_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MAGTAPE_EXTRACT" AS
-- $Header: pymagext.pkb 120.1 2005/10/10 16:54:29 meshah noship $
--
-- Copyright (c) Oracle Corporation 1995 All rights reserved
/*
PRODUCT
  Oracle*Payroll
--
NAME
  pymagext.pkb   - PL/SQL Balance User Exit
--
DESCRIPTION
  This package contains the procedures to process a magtape payroll action
  and create archive items for any archive database items contained in the
  magtape report format. The rollback routine will rollback these items
  before rolling back the payroll action itself.
  --
MODIFIED (DD-MON-YYYY)
  Name      Vers  Date        Notes
  --------- ----- ----------- --------------------------------------------------
  cadams    40.0  12-Feb-1996 Created
  cadams    40.1  13-Mar-1996 Changed report output from dbms_output to
                              PAY_MESSAGE_LINES and added code to commit
                              after every CHUNK_SIZE employers/employees
  cadams    40.2  15-Mar-1996 Added explicit deletion of assignment actions
                              to rollback code
  ramurthy  40.3  17-Apr-1996 Made some changes to the way the Archive
                              Differences Report is formatted.
  allee     40.4  17-Apr-1996 Modified l_state(2) -> l_state(10) so that
                              it could handle the Pseudo-State = 'FED'
                              for Federal W2 Reporting;
  bhoman    40.6  17-APR-1998 Changes made to support SQWL diskette reporting.
  achauhan  40.7  08-aug-1998 Commented out the insert into ff_archive_item_contexts
                              The table definition of ff_archive_item_contexts has
                              changed and the old archive process does not need to
                              populate this table since there is only one contxt for the routes
  djoshi    40.8  08-Apr-1999 Verfied for Canonical Complience of Date
  mreid    115.5  30-Nov-1999 Added column names to ff_archive_items insert
  alogue   115.6  15-Feb-2000 Utf8 support : varchar_240_tbl required for item_name.
  mreid    115.7  13-Sep-2001 Added column name to all inserts
  rsirigir 115.8  13-Aug-2002 Bug 2484696, included dbdrv commands to conform to
                              GSCC compliance
  meshah   115.9  10-Oct-2005 Added nocopy to the out parameters

*/
--==============================================================================
--                               TYPES
--
-- The table types are just simple tables or various types. The records are
-- composite types of tables that contain a size (sz) to hold the number of
-- data items currently stored in the table. Data items are stored in the
-- tables within the records contiguously from 1 to sz.
--==============================================================================
  TYPE number_tbl     IS TABLE OF NUMBER      INDEX BY binary_integer;
  TYPE varchar_60_tbl IS TABLE OF VARCHAR(60) INDEX BY binary_integer;
  TYPE varchar_240_tbl IS TABLE OF VARCHAR(2400) INDEX BY binary_integer;
  TYPE varchar_1_tbl  IS TABLE OF VARCHAR(1)  INDEX BY binary_integer;
--
  TYPE archive_items IS RECORD
  (
    item_name      varchar_240_tbl,
    user_entity_id number_tbl,
    data_type      varchar_1_tbl,
    sz             INTEGER
  );
--
  TYPE balances IS RECORD
  (
    item_name      varchar_240_tbl,
    user_entity_id number_tbl,
    balance_id     number_tbl,
    sz             INTEGER
  );
--
--==============================================================================
--                        VARIABLES
--==============================================================================
--------------------------------------------------------------------------------
-- Table variables
--------------------------------------------------------------------------------
  l_balance_dbis           balances;
  l_employer_dbis          archive_items;
  l_assignment_dbis        archive_items;
--------------------------------------------------------------------------------
-- Other variables
--
-- l_payroll_action_id       Global payroll action id
-- l_business_group_id       Global business group id
-- l_legislation_code        Global legislation code
-- l_effective_date          Global effective date
-- l_date_earned             Global date earned
-- l_runmode                 Global run mode ('S'tore, 'R'eport)
-- l_transmitter_tax_unit_id Global transmitter tax unit id
-- l_report_format           Global report format
-- l_report_type             Report type
-- l_media_type              SQWLD - 'PD',  or  'RT'
-- l_state                   State code (eg 'CA')
-- l_last_context            Last context to be printed in report
-- l_next_header             Next header to be printed in report
--------------------------------------------------------------------------------
  l_payroll_action_id       pay_payroll_actions.payroll_action_id%TYPE;
  l_business_group_id       pay_payroll_actions.business_group_id%TYPE;
  l_legislation_code        per_business_groups.legislation_code%TYPE;
  l_effective_date          pay_payroll_actions.effective_date%TYPE;
  l_date_earned             pay_payroll_actions.date_earned%TYPE;
  l_runmode                 VARCHAR2(1);
  l_transmitter_tax_unit_id NUMBER;
  l_report_format           VARCHAR2(32);
  l_report_type             VARCHAR2(32);
  -- SQWLD - track media_type ('PC Diskette', 'Reel Tape'), media value ('D', 'M')
  l_media_type              VARCHAR2(32);
  l_state                   VARCHAR2(10);
  l_last_context            NUMBER := NULL;
  l_next_header             VARCHAR2(1);
  l_chunk_size              NUMBER;
--
--==============================================================================
--                           PROCEDURES
--==============================================================================
--
--==============================================================================
-- ARCH_INITIALISE
--
-- Initialse tables and referance variables.
--
-- jurisdiction_code      Jurisdiction code
-- legislative_parameters Legislative parameters
--==============================================================================
  PROCEDURE arch_initialise (p_payroll_action_id NUMBER) IS
    jurisdiction_code      pay_state_rules.jurisdiction_code%TYPE;
    legislative_parameters pay_payroll_actions.legislative_parameters%TYPE;
  BEGIN
    hr_utility.set_location ('arch_initialise',1);
--
    l_payroll_action_id := p_payroll_action_id;
--------------------------------------------------------------------------------
-- Initialise table sizes
--------------------------------------------------------------------------------
    l_balance_dbis.sz := 0;
    l_employer_dbis.sz := 0;
    l_assignment_dbis.sz := 0;
--
    hr_utility.set_location ('arch_initialise',2);
--------------------------------------------------------------------------------
-- Get business_group and legislation_code
--------------------------------------------------------------------------------
    SELECT pa.business_group_id,
           bg.legislation_code,
           pa.effective_date,
           pa.date_earned,
           pa.legislative_parameters
      INTO l_business_group_id,
           l_legislation_code,
           l_effective_date,
           l_date_earned,
           legislative_parameters
      FROM pay_payroll_actions pa,
           per_business_groups bg
      WHERE pa.payroll_action_id = l_payroll_action_id AND
            pa.business_group_id = bg.business_group_id;
--
    hr_utility.set_location ('arch_initialise',3);
--------------------------------------------------------------------------------
-- Set session date from effective date
--------------------------------------------------------------------------------
    DELETE FROM fnd_sessions WHERE session_id = userenv('SESSIONID');
    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES ( userenv('SESSIONID'),l_effective_date );
--
    hr_utility.set_location ('arch_initialise',4);
--------------------------------------------------------------------------------
-- Derive state, transmitter tax unit and report format from legislative params
--------------------------------------------------------------------------------
    l_report_type :=  LTRIM (SUBSTR(legislative_parameters,11,5),' ');
    l_state :=  LTRIM (SUBSTR(legislative_parameters,17,5),' ');
    l_transmitter_tax_unit_id := fnd_number.canonical_to_number (SUBSTR(legislative_parameters,
                                                   23,5));
--
/* SQWLD - replace this select from pay_report_format_mappings with lookup_format,
           parse media type from leg params

   ORIGINAL CODE (before SQWLD):

    SELECT report_format
      INTO l_report_format
      FROM pay_report_format_mappings
      WHERE report_type = l_report_type AND
            report_qualifier = l_state AND
            l_effective_date BETWEEN effective_start_date AND
                                     effective_end_date;

   NEW SQWLD CODE FOLLOWS:
*/
   -- parse media_value from leg params
	l_media_type := ltrim(substr(legislative_parameters, 29,5));
   -- now we can call lookup_format
   l_report_format := pay_us_magtape_reporting.lookup_format(l_effective_date,
		             														l_report_type,
		             														l_state,
						 														l_media_type);
   -- end new SQWLD code
--
    hr_utility.set_location ('arch_initialise',5);
--------------------------------------------------------------------------------
-- Get jurisdiction code and store as a context
--------------------------------------------------------------------------------
    IF l_state <> 'FED' THEN
      SELECT sr.jurisdiction_code
        INTO jurisdiction_code
        FROM pay_state_rules sr
        WHERE sr.state_code = l_state;
--
      pay_balance_pkg.set_context ('JURISDICTION_CODE',jurisdiction_code);
    END IF;
--
    hr_utility.set_location ('arch_initialise',6);
--------------------------------------------------------------------------------
-- Get CHUNK_SIZE or default to 20 if CHUNK_SIZE does not exist
--------------------------------------------------------------------------------
    BEGIN
      SELECT parameter_value
        INTO l_chunk_size
        FROM pay_action_parameters
        WHERE parameter_name = 'CHUNK_SIZE';
    EXCEPTION
      WHEN no_data_found THEN
        l_chunk_size := 20;
    END;
--
    hr_utility.set_location ('arch_initialise',7);
  END arch_initialise;
--
--==============================================================================
-- ARCH_DB_ITEMS_LOOP
--
-- Loop through db items and store into the three tables
--
-- db_items_csr      Database items cursor for a report format
-- contexts_csr      Contexts cursor for a user entity id
--
-- db_items_row      Row record for cursor
-- contexts_row      Row record for cursor
-- user_entity_id    Current User entity id
-- a_user_entity_id  Archive User entity id
-- a_data_type       Archive data type
-- creator_type      Creator type
-- name              Database item name without prefix
-- flag              Flag to denote which table data to be stored in
--==============================================================================
  PROCEDURE arch_db_items_loop IS
    CURSOR db_items_csr (p_report_format VARCHAR2) IS
      SELECT distinct us.item_name
        FROM pay_magnetic_blocks mb,
             pay_magnetic_records mr,
             ff_fdi_usages_f us
        WHERE mb.report_format = p_report_format AND
              mb.magnetic_block_id = mr.magnetic_block_id AND
              mr.formula_id = us.formula_id AND
              us.usage = 'D';
--
    CURSOR contexts_csr (p_user_entity_id VARCHAR2) IS
      SELECT cx.context_name
        FROM ff_user_entities ue,
             ff_route_context_usages rcu,
             ff_contexts cx
        WHERE ue.user_entity_id = p_user_entity_id AND
              ue.route_id = rcu.route_id AND
              rcu.context_id = cx.context_id;
--
    db_items_row      db_items_csr%ROWTYPE;
    contexts_row      contexts_csr%ROWTYPE;
    user_entity_id    ff_database_items.user_entity_id%TYPE;
    a_user_entity_id  ff_database_items.user_entity_id%TYPE;
    a_data_type       ff_database_items.data_type%TYPE;
    creator_type      ff_user_entities.creator_type%TYPE;
    name              VARCHAR2(240);
    flag              VARCHAR2(1);
  BEGIN
    hr_utility.set_location ('arch_db_items_loop',1);
--
--------------------------------------------------------------------------------
-- Loop through database items
--------------------------------------------------------------------------------
    FOR db_items_row IN db_items_csr (l_report_format) LOOP
      hr_utility.set_location ('arch_db_items_loop',11);
--------------------------------------------------------------------------------
-- Ignore any database item found without a A_ prefix
--------------------------------------------------------------------------------
      IF substr(db_items_row.item_name,1,2) <> 'A_' THEN
        hr_utility.trace ('** Ignoring DB Item without A_ prefix: ' ||
                          db_items_row.item_name || ' **');
      ELSE
        hr_utility.set_location ('arch_db_items_loop',111);
--------------------------------------------------------------------------------
-- Default to an employer database item
--------------------------------------------------------------------------------
        flag := 'R';
        name := substr (db_items_row.item_name,3,
                        length(db_items_row.item_name)-2);
--
        hr_utility.trace ('** Found ' || db_items_row.item_name || ' **');
        hr_utility.set_location ('arch_db_items_loop',112);
--------------------------------------------------------------------------------
-- Get archive entity id and data type
--------------------------------------------------------------------------------
        SELECT dbi.user_entity_id, dbi.data_type
          INTO a_user_entity_id, a_data_type
          FROM ff_database_items dbi
          WHERE dbi.user_name = db_items_row.item_name;
--
--------------------------------------------------------------------------------
-- Get live entity id and creator type
--------------------------------------------------------------------------------
        SELECT dbi.user_entity_id,ue.creator_type
          INTO user_entity_id,creator_type
          FROM ff_database_items dbi,
               ff_user_entities ue
          WHERE dbi.user_name = name AND
                dbi.user_entity_id = ue.user_entity_id;
--
--------------------------------------------------------------------------------
-- Check to see if db_item is balance or assignment
--------------------------------------------------------------------------------
        IF creator_type = 'B' THEN
          flag := 'B';
        ELSE
          FOR contexts_row IN contexts_csr (user_entity_id) LOOP
            IF (contexts_row.context_name = 'ASSIGNMENT_ID') OR
               (contexts_row.context_name = 'ASSIGNMENT_ACTION_ID') THEN
              flag := 'A';
              EXIT;
            END IF;
          END LOOP;
        END IF;
--
        hr_utility.set_location ('arch_db_items_loop',113);
--------------------------------------------------------------------------------
-- Store data in appropriate table
--------------------------------------------------------------------------------
        IF flag = 'B' THEN
          hr_utility.set_location ('arch_db_items_loop',1131);
--
          l_balance_dbis.sz := l_balance_dbis.sz + 1;
          l_balance_dbis.item_name(l_balance_dbis.sz) := name;
          l_balance_dbis.user_entity_id(l_balance_dbis.sz) := a_user_entity_id;
          l_balance_dbis.balance_id(l_balance_dbis.sz) :=
            pay_us_magtape_reporting.bal_db_item (l_balance_dbis.item_name
                                                           (l_balance_dbis.sz));
        ELSIF flag = 'A' THEN
          hr_utility.set_location ('arch_db_items_loop',1132);
--
          l_assignment_dbis.sz := l_assignment_dbis.sz + 1;
          l_assignment_dbis.item_name(l_assignment_dbis.sz) := name;
          l_assignment_dbis.user_entity_id(l_assignment_dbis.sz) :=
                                                               a_user_entity_id;
          l_assignment_dbis.data_type(l_assignment_dbis.sz) := a_data_type;
        ELSE
          hr_utility.set_location ('arch_db_items_loop',1133);
--
          l_employer_dbis.sz := l_employer_dbis.sz + 1;
          l_employer_dbis.item_name(l_employer_dbis.sz) := name;
          l_employer_dbis.user_entity_id(l_employer_dbis.sz) :=
                                                               a_user_entity_id;
          l_employer_dbis.data_type(l_employer_dbis.sz) := a_data_type;
        END IF;
      END IF;
--
      hr_utility.set_location ('arch_db_items_loop',12);
    END LOOP;
--
    hr_utility.set_location ('arch_db_items_loop',2);
  END arch_db_items_loop;
--
--==============================================================================
-- ARCH_OUTPUT
--
-- Output a report line to pay_message_lines
--==============================================================================
  PROCEDURE arch_output (p_line VARCHAR2) IS
  BEGIN
    hr_utility.set_location ('arch_output',1);
--
    INSERT INTO pay_message_lines
    ( line_sequence, payroll_id, message_level,
      source_id, source_type, line_text )
    VALUES
      ( pay_message_lines_s.nextval,
        NULL,
        'I',
        l_payroll_action_id,
        'P',
        p_line );
--
    hr_utility.set_location ('arch_output',2);
  END arch_output;
--
--==============================================================================
-- ARCH_REPORT_HEADER
--
-- Print report headers/footer depending on report section
--
-- now    Current date/time in text form
-- title  Centred title string
--==============================================================================
  PROCEDURE arch_report_header (p_report_section VARCHAR2 := NULL) IS
    now    VARCHAR2(30);
    title  VARCHAR2(100);
    period pay_w2_magnetic_tape_reports.period%TYPE;
--
--------------------------------------------------------------------------------
-- CENTRE
--
-- Return a string centred on a page of l width
--------------------------------------------------------------------------------
    FUNCTION centre (s VARCHAR2,l INTEGER) RETURN VARCHAR2 IS
    BEGIN
      RETURN LPAD(RPAD(s,LENGTH(s) + ((l - LENGTH(s))/2)), l);
    END centre;
--
  BEGIN
    hr_utility.set_location ('arch_report_header',1);
--
    IF l_runmode = 'R' THEN
      hr_utility.set_location ('arch_report_header',11);
--------------------------------------------------------------------------------
-- Print employee report header
--------------------------------------------------------------------------------
      IF p_report_section = 'E' THEN
        hr_utility.set_location ('arch_report_header',111);
--
        arch_output ('');
        arch_output ('Last Name            ' ||
                     'SS Number   ' ||
                     'Item Name                                  ' ||
                     'Current Val ' ||
                     'Archive Val ');
        arch_output ('-------------------- ' ||
                     '----------- ' ||
                     '------------------------------------------ ' ||
                     '----------- ' ||
                     '------------');
--------------------------------------------------------------------------------
-- Print employer report header
--------------------------------------------------------------------------------
      ELSIF p_report_section = 'R' THEN
        hr_utility.set_location ('arch_report_header',112);
--
        arch_output ('');
        arch_output ('Organization Name              ' ||
                     '                     ' ||
                     'Item Name                           ' ||
                     'Calculated Value     ' ||
                     'Archive Value        ');
        arch_output ('------------------------------ ' ||
                     '                     ' ||
                     '----------------------------------- ' ||
                     '-------------------- ' ||
                     '--------------------');
--------------------------------------------------------------------------------
-- Print report footer
--------------------------------------------------------------------------------
      ELSIF p_report_section = 'F' THEN
        hr_utility.set_location ('arch_report_header',113);
--
        arch_output ('');
        arch_output (centre('** End of Listing **',80));
--------------------------------------------------------------------------------
-- Print report main header
--------------------------------------------------------------------------------
      ELSE
        hr_utility.set_location ('arch_report_header',114);
--
        SELECT period
          INTO period
          FROM pay_w2_magnetic_tape_reports
          WHERE payroll_action_id = l_payroll_action_id;
--
        hr_utility.set_location ('arch_report_header',115);
--
        now := fnd_date.date_to_canonical (SYSDATE);
        title := centre ('ARCHIVE DIFFERENCES REPORT',100);
--
        arch_output (title || LPAD(now,100-LENGTH(title)));
        arch_output (centre('==========================',100));
        arch_output ('');
        arch_output ('Payroll Action ID: ' || l_payroll_action_id);
        arch_output ('Effective Date:    ' || fnd_date.date_to_canonical(l_effective_date
                                                      ));
        arch_output ('Report Type:       ' || l_report_type);
        arch_output ('State:             ' || l_state);
        arch_output ('Period:            ' || period);
--
        hr_utility.set_location ('arch_report_header',116);
      END IF;
--
      hr_utility.set_location ('arch_report_header',12);
    END IF;
--
    hr_utility.set_location ('arch_report_header',2);
  END arch_report_header;
--
--==============================================================================
-- ARCH_STORE
--
-- Store the data to the archive tables or print report lines depending on
-- l_runmode
--
-- chk  Currently stored archive value
--==============================================================================
  PROCEDURE arch_store (p_report_section VARCHAR2,
                        p_item_name      VARCHAR2,
                        p_user_entity_id ff_archive_items.user_entity_id%TYPE,
                        p_context1       ff_archive_items.context1%TYPE,
                        p_value          ff_archive_items.value%TYPE,
                        p_context2       ff_archive_item_contexts.context%TYPE
                          := NULL) IS
--
    chk ff_archive_items.value%TYPE;
--
--------------------------------------------------------------------------------
-- ARCH_REPORT_INFO
--
-- Get currently stored archive value for p_item_name with p_context1
--------------------------------------------------------------------------------
    FUNCTION arch_report_info (p_item_name VARCHAR2,
                               p_context1  NUMBER) RETURN VARCHAR2 IS
      r VARCHAR2(80);
    BEGIN
      SELECT ai.value
        INTO r
        FROM ff_database_items dbi,
             ff_archive_items ai
        WHERE dbi.user_entity_id = ai.user_entity_id AND
              dbi.user_name = p_item_name AND
              ai.context1 = p_context1;
--
      RETURN r;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN '** NOT FOUND **';
    END arch_report_info;
--
--------------------------------------------------------------------------------
-- ARCH_REPORT_INFO
--
-- Get organisation name for p_context2
--------------------------------------------------------------------------------
    FUNCTION arch_report_info (p_context2 NUMBER) RETURN VARCHAR2 IS
      r VARCHAR2(80);
    BEGIN
      SELECT name
        INTO r
        FROM hr_organization_units
        WHERE organization_id = p_context2;
--
      RETURN r;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN '** NOT FOUND **';
    END arch_report_info;
--
--------------------------------------------------------------------------------
-- ARCH_REPORT_LINE
--
-- Print a line on the report adding heading lines as necissary
--------------------------------------------------------------------------------
    PROCEDURE arch_report_line (p_item_name VARCHAR2,
                                p_calc_val  VARCHAR2,
                                p_arch_val  VARCHAR2) IS
    BEGIN
      hr_utility.set_location ('arch_report_line',1);
--------------------------------------------------------------------------------
-- If it is the start of a new person/organisation...
--------------------------------------------------------------------------------
      IF (l_last_context <> p_context1) OR (l_last_context IS NULL) THEN
        hr_utility.set_location ('arch_report_line',11);
--------------------------------------------------------------------------------
-- Add a space between the last person/organisation and the new one
--------------------------------------------------------------------------------
        IF l_last_context IS NOT NULL THEN
          hr_utility.set_location ('arch_report_line',111);
          arch_output ('');
        END IF;
--
        l_last_context := p_context1;
--
        hr_utility.set_location ('arch_report_line',12);
--------------------------------------------------------------------------------
-- Print new report header if section has changed
--------------------------------------------------------------------------------
        IF (l_next_header = 'R') OR (l_next_header = 'E') THEN
          hr_utility.set_location ('arch_report_line',121);
          arch_report_header (l_next_header);
          l_next_header := NULL;
        END IF;
--
        hr_utility.set_location ('arch_report_line',13);
--------------------------------------------------------------------------------
-- Print person/organisation details
--------------------------------------------------------------------------------
        IF p_report_section = 'E' THEN
          hr_utility.set_location ('arch_report_line',131);
--
          arch_output (RPAD(arch_report_info('A_PER_LAST_NAME',
                                             p_context1),20) || ' ' ||
                       RPAD(arch_report_info(
                      'A_PER_NATIONAL_IDENTIFIER',p_context1),11));
        ELSE
          hr_utility.set_location ('arch_report_line',132);
--
          arch_output (RPAD(arch_report_info(p_context2),11));
        END IF;
--
        hr_utility.set_location ('arch_report_line',14);
      END IF;
--
      hr_utility.set_location ('arch_report_line',2);
--------------------------------------------------------------------------------
-- Print actual report line
--------------------------------------------------------------------------------
      arch_output ('                     ' ||
                   '            ' ||
                   RPAD(replace(substr(p_item_name,3,42),'_', ' '),42) || ' ' ||
                   RPAD(NVL(p_calc_val,'** NULL **'),11) || ' ' ||
                   RPAD(NVL(p_arch_val,'** NULL **'),12));
--
      hr_utility.set_location ('arch_report_line',3);
    END arch_report_line;
--------------------------------------------------------------------------------
  BEGIN
    hr_utility.set_location ('arch_store',1);
--------------------------------------------------------------------------------
-- If in Validate mode, don't do anything
--------------------------------------------------------------------------------
    IF l_runmode = 'V' THEN
      hr_utility.set_location ('arch_store',111);
--------------------------------------------------------------------------------
-- If in Store mode, store the data into the archive tables
--------------------------------------------------------------------------------
    ELSIF l_runmode = 'S' THEN
      hr_utility.set_location ('arch_store',121);
--
      INSERT INTO ff_archive_items
        ( ARCHIVE_ITEM_ID, USER_ENTITY_ID, CONTEXT1, VALUE)
      VALUES
        ( ff_archive_items_s.nextval,p_user_entity_id,p_context1,p_value );
--
      hr_utility.set_location ('arch_store',122);
--
 /* context2 is not supported in the old archive process. So, commenting this insert */
      IF p_context2 IS NOT NULL THEN
 --       INSERT INTO ff_archive_item_contexts VALUES
  --        ( ff_archive_items_s.currval,2,p_context2 );
--
      hr_utility.set_location ('arch_store',123);
      END IF;
--------------------------------------------------------------------------------
-- Otherwise, you're in Report mode so compare the data with the archive and
-- report any differences
--------------------------------------------------------------------------------
    ELSE
      hr_utility.set_location ('arch_store',131);
--
      BEGIN
        hr_utility.set_location ('arch_store',132);
--
--------------------------------------------------------------------------------
-- Get archived value
--------------------------------------------------------------------------------
        IF p_context2 IS NOT NULL THEN
          hr_utility.set_location ('arch_store',1321);
--
          SELECT value
            INTO chk
            FROM ff_archive_items ai,
                 ff_archive_item_contexts aic
            WHERE ai.archive_item_id = aic.archive_item_id AND
                  ai.user_entity_id = p_user_entity_id AND
                  ai.context1 = p_context1 AND
                  aic.sequence_no = 2 AND
                  aic.context = p_context2;
        ELSE
          hr_utility.set_location ('arch_store',1322);
--
          SELECT value
            INTO chk
            FROM ff_archive_items ai
            WHERE ai.user_entity_id = p_user_entity_id AND
                  ai.context1 = p_context1;
        END IF;
--
        hr_utility.set_location ('arch_store',133);
--------------------------------------------------------------------------------
-- If there is a differance print a line on the report
--------------------------------------------------------------------------------
        IF chk <> p_value THEN
          hr_utility.set_location ('arch_store',1331);
--
          arch_report_line (p_item_name,p_value,chk);
        END IF;
--
        hr_utility.set_location ('arch_store',134);
      EXCEPTION
--------------------------------------------------------------------------------
-- Catch for when there is no corresponding data in the archive table for a
-- calculated value
--------------------------------------------------------------------------------
        WHEN no_data_found THEN
          hr_utility.set_location ('arch_store',14);
--
          arch_report_line (p_item_name,p_value,'** NOT FOUND **');
      END;
--
      hr_utility.set_location ('arch_store',2);
    END IF;
  END arch_store;
--
--==============================================================================
-- ARCH_EMPLOYER_LOOP
--
-- Loop through the employers and for each employer, insert one archive item
-- for every employer db item.
--
-- employer_csr  Employer cursor to select employer tax unit id by payroll
--               action id while UNIONing the transmitter tax unit id passed
--               in
-- employer_row  Row for the cursor
-- result        Result of database item user callback
-- i             Loop variable for employer table
--==============================================================================
  PROCEDURE arch_employer_loop IS
    CURSOR employer_csr (p_payroll_action_id       NUMBER,
                         p_transmitter_tax_unit_id NUMBER) IS
      SELECT DISTINCT aa.tax_unit_id
        FROM pay_assignment_actions aa
        WHERE aa.payroll_action_id = p_payroll_action_id
      UNION
      SELECT p_transmitter_tax_unit_id
        FROM DUAL;
--
    employer_row  employer_csr%ROWTYPE;
    result        ff_archive_items.value%TYPE;
    i             INTEGER;
  BEGIN
    hr_utility.set_location ('arch_employer_loop',1);
    l_next_header := 'R';
--
--------------------------------------------------------------------------------
-- Loop through employers
--------------------------------------------------------------------------------
    FOR employer_row IN employer_csr (l_payroll_action_id,
                                      l_transmitter_tax_unit_id) LOOP
      hr_utility.set_location ('arch_employer_loop',11);
--
--------------------------------------------------------------------------------
-- Set contexts
--------------------------------------------------------------------------------
      pay_balance_pkg.set_context ('TAX_UNIT_ID',employer_row.tax_unit_id);
--
      hr_utility.set_location ('arch_employer_loop',12);
--------------------------------------------------------------------------------
-- Loop through employer db items
--------------------------------------------------------------------------------
      FOR i IN 1..l_employer_dbis.sz LOOP
        hr_utility.set_location ('arch_employer_loop',121);
--
--------------------------------------------------------------------------------
-- Execute user exit
--------------------------------------------------------------------------------
        result := pay_balance_pkg.run_db_item (l_employer_dbis.item_name(i),
                                               l_business_group_id,
                                               l_legislation_code);
--
--------------------------------------------------------------------------------
-- Ensure date is in correct format
--------------------------------------------------------------------------------
-- Commented it out because run_db_item already returns date in proper format.
--      IF l_employer_dbis.data_type(i) = 'D' THEN
--          result := TO_CHAR (fnd_date.canonical_to_date(result));
--	END IF;
--
--------------------------------------------------------------------------------
-- Store data
--------------------------------------------------------------------------------
        arch_store ('R',
                    'A_' || l_employer_dbis.item_name(i),
                    l_employer_dbis.user_entity_id(i),
                    l_payroll_action_id,
                    result,
                    employer_row.tax_unit_id );
--
        hr_utility.set_location ('arch_employer_loop',122);
      END LOOP;
--
      hr_utility.set_location ('arch_employer_loop',13);
--------------------------------------------------------------------------------
-- Commit every 20 employees
--------------------------------------------------------------------------------
      IF (employer_csr%ROWCOUNT > 0) AND
         ((employer_csr%ROWCOUNT MOD l_chunk_size) = 0) THEN
        COMMIT;
      END IF;
--
      hr_utility.set_location ('arch_employer_loop',14);
    END LOOP;
--
    hr_utility.set_location ('arch_employer_loop',2);
  END arch_employer_loop;
--
--==============================================================================
-- ARCH_EMPLOYEE_LOOP
--
-- Loop through the employees and for every employee insert an archive item for
-- every balance db item and every assignment db item
--
-- employee_csr  Employer cursor to select employer tax unit id by payroll
--               action id. The effective date is used to calculate the date
--               earned
-- employee_row  Row for the cursor
-- result        Result of database item/balance user callbacks
-- i             Loop variable for assignment/balance tables
--==============================================================================
  PROCEDURE arch_employee_loop IS
    CURSOR employee_csr (p_payroll_action_id NUMBER,
                         p_effective_date    DATE) IS
      SELECT aa.assignment_action_id,
	     aa.assignment_id,
	     pay_magtape_generic.date_earned (p_effective_date,aa.assignment_id)
               date_earned,
             aa.tax_unit_id
        FROM pay_assignment_actions aa
        WHERE aa.payroll_action_id = p_payroll_action_id;
--
    employee_row    employee_csr%ROWTYPE;
    result          ff_archive_items.value%TYPE;
    aaid            pay_assignment_actions.assignment_action_id%TYPE;
    i               INTEGER;
  BEGIN
    hr_utility.set_location ('arch_employee_loop',1);
    l_next_header := 'E';
--
--------------------------------------------------------------------------------
-- Loop through employees
--------------------------------------------------------------------------------
    FOR employee_row IN employee_csr (l_payroll_action_id,l_effective_date) LOOP
      hr_utility.set_location ('arch_employee_loop',11);
--
--------------------------------------------------------------------------------
-- Setup contexts
--------------------------------------------------------------------------------
      pay_balance_pkg.set_context ('ASSIGNMENT_ID',employee_row.assignment_id);
      pay_balance_pkg.set_context ('DATE_EARNED',
                               fnd_date.date_to_canonical(employee_row.date_earned));
      pay_balance_pkg.set_context ('TAX_UNIT_ID',employee_row.tax_unit_id);
--
      IF l_effective_date > employee_row.date_earned THEN
        SELECT MAX(assignment_action_id)
          INTO aaid
          FROM pay_assignment_actions
          WHERE tax_unit_id = employee_row.tax_unit_id AND
                assignment_id = employee_row.assignment_id;
--
        pay_balance_pkg.set_context ('ASSIGNMENT_ACTION_ID',aaid);
      ELSE
        pay_balance_pkg.set_context ('ASSIGNMENT_ACTION_ID',
                                     employee_row.assignment_action_id);
      END IF;
--
      hr_utility.set_location ('arch_employee_loop',12);
--------------------------------------------------------------------------------
-- Balance Loop
--------------------------------------------------------------------------------
      FOR i IN 1..l_balance_dbis.sz LOOP
--
        hr_utility.set_location ('arch_employee_loop',121);
--
        result := pay_balance_pkg.get_value (l_balance_dbis.balance_id(i),
                                             employee_row.assignment_action_id);
--
        hr_utility.trace ('** Balance Loop ** ' ||
                          l_balance_dbis.item_name(i) || ' = ' || result);
--
        arch_store ('E',
                    'A_' || l_balance_dbis.item_name(i),
                    l_balance_dbis.user_entity_id(i),
                    employee_row.assignment_action_id,
                    result );
--
        hr_utility.set_location ('arch_employee_loop',122);
      END LOOP;
--
      hr_utility.set_location ('arch_employee_loop',13);
--------------------------------------------------------------------------------
-- Assignment Loop
--------------------------------------------------------------------------------
      FOR i IN 1..l_assignment_dbis.sz LOOP
        hr_utility.set_location ('arch_employee_loop',131);
--
--------------------------------------------------------------------------------
-- Execute user exit
--------------------------------------------------------------------------------
	result := pay_balance_pkg.run_db_item (l_assignment_dbis.item_name(i),
                                               l_business_group_id,
                                               l_legislation_code);
--
--------------------------------------------------------------------------------
-- Ensure date is in correct format
--------------------------------------------------------------------------------
-- Commented it out because run_db_item already returns date in proper format.
--      IF l_assignment_dbis.data_type(i) = 'D' THEN
--         result := TO_CHAR (fnd_date.canonical_to_date(result));
--	END IF;
--
        hr_utility.trace ('** Assignments loop ** ' ||
                          l_assignment_dbis.item_name(i) || ' = ' || result);
--
--------------------------------------------------------------------------------
-- Store data
--------------------------------------------------------------------------------
        arch_store ('E',
                    'A_' || l_assignment_dbis.item_name(i),
                    l_assignment_dbis.user_entity_id(i),
                    employee_row.assignment_action_id,
                    result );
--
        hr_utility.set_location ('arch_employee_loop',132);
      END LOOP;
--
      hr_utility.set_location ('arch_employee_loop',14);
--------------------------------------------------------------------------------
-- Commit every 20 employees
--------------------------------------------------------------------------------
      IF (employee_csr%ROWCOUNT > 0) AND
         ((employee_csr%ROWCOUNT MOD l_chunk_size) = 0) THEN
        COMMIT;
      END IF;
--
      hr_utility.set_location ('arch_employee_loop',15);
    END LOOP;
--
    hr_utility.set_location ('arch_employee_loop',2);
  END arch_employee_loop;
--
--==============================================================================
-- ARCH_MAIN
--
-- Extract main program
--==============================================================================
  PROCEDURE arch_main (p_runmode           VARCHAR2,
                       p_payroll_action_id NUMBER) IS
  BEGIN
    hr_utility.set_location ('arch_main',1);
--
    l_runmode := p_runmode;
--
    arch_initialise (p_payroll_action_id);
    arch_report_header;
    arch_db_items_loop;
    arch_employer_loop;
    arch_employee_loop;
    arch_report_header ('F');
    COMMIT;
--
    hr_utility.set_location ('arch_main',2);
  END arch_main;
--
--==============================================================================
-- ARCH_ROLBK
--
-- rollback an archive - delete rows from ff_archive_items and
-- ff_archive_item_contexts that relate to a specified payroll action
--==============================================================================
  PROCEDURE arch_rolbk (p_errmsg            OUT nocopy VARCHAR2,
                        p_errcode           OUT nocopy NUMBER,
                        p_payroll_action_id     NUMBER) IS
  BEGIN
    hr_utility.set_location ('arch_rolbk',1);
--
--------------------------------------------------------------------------------
-- Delete archive items
--------------------------------------------------------------------------------
    DELETE FROM ff_archive_item_contexts ic
      WHERE EXISTS ( SELECT '1'
                       FROM ff_contexts con,
			    ff_route_context_usages rcu,
			    ff_user_entities ue,
                            pay_assignment_actions assact,
			    ff_archive_items i
                       WHERE i.archive_item_id = ic.archive_item_id
                         AND assact.payroll_action_id = p_payroll_action_id
		         AND assact.assignment_action_id = i.context1
                         AND i.user_entity_id = ue.user_entity_id
		         AND rcu.route_id = ue.route_id
                         AND rcu.sequence_no = 1
                         AND rcu.context_id = con.context_id
                         AND con.context_name ||''= 'ASSIGNMENT_ACTION_ID' )
        OR EXISTS ( SELECT '1'
                      FROM ff_contexts con,
			   ff_route_context_usages rcu,
			   ff_user_entities ue,
			   ff_archive_items i
                      WHERE i.archive_item_id = ic.archive_item_id
		        AND i.context1 = p_payroll_action_id
		        AND i.user_entity_id = ue.user_entity_id
		        AND rcu.route_id = ue.route_id
                        AND rcu.sequence_no = 1
                        AND rcu.context_id = con.context_id
                        AND con.context_name ||''= 'PAYROLL_ACTION_ID' );
--
    hr_utility.set_location ('arch_rolbk',2);
--
    DELETE FROM ff_archive_items i
      WHERE EXISTS ( SELECT '1'
                       FROM ff_contexts con,
			    ff_route_context_usages rcu,
			    ff_user_entities ue,
                            pay_assignment_actions assact
                       WHERE assact.payroll_action_id = p_payroll_action_id
		         AND assact.assignment_action_id = i.context1
		         AND i.user_entity_id = ue.user_entity_id
		         AND rcu.route_id = ue.route_id
                         AND rcu.sequence_no = 1
                         AND rcu.context_id = con.context_id
                         AND con.context_name ||''= 'ASSIGNMENT_ACTION_ID' )
        OR EXISTS ( SELECT '1'
                      FROM ff_contexts con,
			   ff_route_context_usages rcu,
			   ff_user_entities ue
		      WHERE i.context1 = p_payroll_action_id
		        AND i.user_entity_id = ue.user_entity_id
		        AND rcu.route_id = ue.route_id
                        AND rcu.sequence_no = 1
                        AND rcu.context_id = con.context_id
                        AND con.context_name ||''= 'PAYROLL_ACTION_ID' );
--
--------------------------------------------------------------------------------
-- Delete assignment actions
--------------------------------------------------------------------------------
    DELETE FROM pay_assignment_actions
      WHERE payroll_action_id = p_payroll_action_id;
--
--------------------------------------------------------------------------------
-- Delete payroll action
--------------------------------------------------------------------------------
    py_rollback_pkg.rollback_payroll_action (p_payroll_action_id);
    COMMIT;
--
    hr_utility.set_location ('arch_rolbk',3);
  END arch_rolbk;
--
END pay_magtape_extract;

/
