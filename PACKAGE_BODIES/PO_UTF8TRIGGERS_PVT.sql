--------------------------------------------------------
--  DDL for Package Body PO_UTF8TRIGGERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_UTF8TRIGGERS_PVT" AS
/* $Header: POXVUTFB.pls 120.0 2005/06/01 14:36:25 appldev noship $ */

/*
 * Record type for storing UTF8 trigger information. column_display_name represents the
 * text that is placed into the fnd_message on errors.
 */
TYPE utf8_trg_rec_type IS RECORD (
  table_name           VARCHAR2(50),
  column_name          VARCHAR2(50),
  column_display_name  VARCHAR2(50),
  max_length           VARCHAR2(50),
  trigger_name         VARCHAR2(50)
);

TYPE utf8_trg_tbl_type IS TABLE OF utf8_trg_rec_type
  INDEX BY BINARY_INTEGER;

/* Global PL/SQL table within this package */
g_utf8_trigger_tbl   utf8_trg_tbl_type;

-- Bug 2766729 START
/**
 *  Private Procedure: column_exists
 *  Modifies: none
 *  Effects: Returns TRUE if the specified column exists in the database,
 *    FALSE otherwise.
 */
FUNCTION column_exists (p_trigger_rec UTF8_TRG_REC_TYPE) RETURN BOOLEAN IS
  invalid_identifier EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_identifier,-00904);
BEGIN
  -- If we can select from the column, then it exists.
  EXECUTE IMMEDIATE 'SELECT '|| p_trigger_rec.column_name || ' FROM ' ||
    p_trigger_rec.table_name || ' WHERE rownum = 1';
  RETURN TRUE;
EXCEPTION
  WHEN invalid_identifier THEN
    RETURN FALSE;
END;
-- Bug 2766729 END

/**
 *  Private Procedure: initialize_globals
 *  Modifies: The PL/SQL table g_utf8_trigger_tbl.
 *  Effects: Initializes g_utf8_trigger_tbl to store all the data for each UTF8
 *           column expanded.
 */
PROCEDURE initialize_globals IS

  n NUMBER := 1;   /* Counter for the PL/SQL table. */

BEGIN
  -- Clear the table
  g_utf8_trigger_tbl.DELETE; -- Bug 2766729

  --
  -- Populate the pl/sql table with details of all the UTF8 triggers
  -- required for PO.
  -- All columns from the same table must be grouped together in order to
  -- process g_utf8_trigger_tbl correctly.
  -- All trigger names follow a standard naming convention, abbreviating
  -- the table name to 3 chars per word, with "_UTF8" appended to the end.
  --

  -- Bug 2766729
  -- The PL/SQL table should only include columns that exist in the database.


  g_utf8_trigger_tbl(n).table_name  := 'PO_APPROVAL_LIST_LINES';
  g_utf8_trigger_tbl(n).column_name := 'COMMENTS';
  g_utf8_trigger_tbl(n).column_display_name := 'Comments';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_APL_LST_LNS_UTF8';
  -- Bug 2766729
  -- Only increment the counter if we want the column to be included.
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_HEADERS_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_VENDOR';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Vendor';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_HDR_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_HEADERS_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_RECEIVER';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Receiver';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_HDR_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_HEADERS_ARCHIVE_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_VENDOR';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Vendor';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_HDR_ARC_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_HEADERS_ARCHIVE_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_RECEIVER';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Receiver';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_HDR_ARC_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_HEADERS_INTERFACE';
  g_utf8_trigger_tbl(n).column_name := 'VENDOR_NAME';
  g_utf8_trigger_tbl(n).column_display_name := 'Vendor Name';
  g_utf8_trigger_tbl(n).max_length  := '80';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_HDR_INT_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_HEADERS_INTERFACE';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_RECEIVER';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Receiver';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_HDR_INT_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_HEADERS_INTERFACE';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_VENDOR';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Vendor';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_HDR_INT_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_LINE_LOCATIONS_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_RECEIVER';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Receiver';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_LNE_LOC_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_LINES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_VENDOR';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Vendor';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_LNS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_LINES_ARCHIVE_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_VENDOR';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Vendor';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_LNS_ARC_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_LINES_INTERFACE';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_RECEIVER';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Receiver';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_LNS_INT_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_LINES_INTERFACE';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_VENDOR';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Vendor';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_LNS_INT_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_RELEASES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_VENDOR';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Vendor';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REL_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_RELEASES_ARCHIVE_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_VENDOR';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Vendor';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REL_ARC_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_REQUISITIONS_INTERFACE_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_BUYER';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Buyer';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REQ_INT_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_REQUISITIONS_INTERFACE_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_RECEIVER';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Receiver';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REQ_INT_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_REQUISITIONS_INTERFACE_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_APPROVER';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Approver';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REQ_INT_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_REQUISITIONS_INTERFACE_ALL';
  g_utf8_trigger_tbl(n).column_name := 'JUSTIFICATION';
  g_utf8_trigger_tbl(n).column_display_name := 'Justification';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REQ_INT_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_REQUISITION_LINES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_AGENT';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Agent';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REQ_LNS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_REQUISITION_LINES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_RECEIVER';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Receiver';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REQ_LNS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_REQUISITION_LINES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'AGENT_RETURN_NOTE';
  g_utf8_trigger_tbl(n).column_display_name := 'Agent Return Note';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REQ_LNS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_REQUISITION_LINES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'NOTE_TO_VENDOR';
  g_utf8_trigger_tbl(n).column_display_name := 'Note To Vendor';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REQ_LNS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_REQUISITION_LINES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'JUSTIFICATION';
  g_utf8_trigger_tbl(n).column_display_name := 'Justification';
  g_utf8_trigger_tbl(n).max_length  := '240';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REQ_LNS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_REQUISITION_LINES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'SUGGESTED_VENDOR_NAME';
  g_utf8_trigger_tbl(n).column_display_name := 'Suggested Vendor Name';
  g_utf8_trigger_tbl(n).max_length  := '80';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REQ_LNS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_REQUISITION_LINES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'MANUFACTURER_NAME';
  g_utf8_trigger_tbl(n).column_display_name := 'Manufacturer Name';
  g_utf8_trigger_tbl(n).max_length  := '30';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_REQ_LNS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_VENDORS';
  g_utf8_trigger_tbl(n).column_name := 'VENDOR_NAME';
  g_utf8_trigger_tbl(n).column_display_name := 'Vendor Name';
  g_utf8_trigger_tbl(n).max_length  := '80';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_VDR_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_VENDOR_SITES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'ADDRESS_LINE1';
  g_utf8_trigger_tbl(n).column_display_name := 'Address Line1';
  g_utf8_trigger_tbl(n).max_length  := '35';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_VDR_STS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_VENDOR_SITES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'ADDRESS_LINE2';
  g_utf8_trigger_tbl(n).column_display_name := 'Address Line2';
  g_utf8_trigger_tbl(n).max_length  := '35';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_VDR_STS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_VENDOR_SITES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'ADDRESS_LINE3';
  g_utf8_trigger_tbl(n).column_display_name := 'Address Line3';
  g_utf8_trigger_tbl(n).max_length  := '35';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_VDR_STS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_VENDOR_SITES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'ADDRESS_LINE4';
  g_utf8_trigger_tbl(n).column_display_name := 'Address Line4';
  g_utf8_trigger_tbl(n).max_length  := '35';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_VDR_STS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_VENDOR_SITES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'STATE';
  g_utf8_trigger_tbl(n).column_display_name := 'State';
  g_utf8_trigger_tbl(n).max_length  := '25';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_VDR_STS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_VENDOR_SITES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'PROVINCE';
  g_utf8_trigger_tbl(n).column_display_name := 'Province';
  g_utf8_trigger_tbl(n).max_length  := '25';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_VDR_STS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  g_utf8_trigger_tbl(n).table_name  := 'PO_VENDOR_SITES_ALL';
  g_utf8_trigger_tbl(n).column_name := 'COUNTY';
  g_utf8_trigger_tbl(n).column_display_name := 'County';
  g_utf8_trigger_tbl(n).max_length  := '25';
  g_utf8_trigger_tbl(n).trigger_name := 'PO_VDR_STS_ALL_UTF8';
  IF column_exists( g_utf8_trigger_tbl(n) ) THEN -- Bug 2766729
    n := n + 1;
  END IF;

  -- Bug 2766729 START
  IF (n = g_utf8_trigger_tbl.LAST) THEN
    -- The counter was not incremented for the last column, so we should
    -- not include it.
    g_utf8_trigger_tbl.DELETE(n);
  END IF;
  -- Bug 2766729 END

END initialize_globals;

/**
 *  Public Procedure: drop_all_triggers
 *  Modifies: Database triggers.
 *  Effects: Drops all triggers found in g_utf8_trigger_tbl from the database.
 */
PROCEDURE drop_all_triggers IS

  trigger_not_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(trigger_not_exists,-04080);
  l_previous_trigger VARCHAR2(50) := NULL;
  l_triggers_dropped NUMBER := 0;

BEGIN
  initialize_globals; -- Bug 2766729

  --
  -- Loop through all triggers in the plsql table
  -- and drop them.
  --
  FOR i IN g_utf8_trigger_tbl.FIRST..g_utf8_trigger_tbl.LAST LOOP
    --
    -- Remove the current trigger only if it is different
    -- from the previous loop's trigger.
    -- This prevents the below code from attempting to
    -- drop the same trigger twice.
    --
    IF (l_previous_trigger <> g_utf8_trigger_tbl(i).trigger_name) OR
       (l_previous_trigger IS NULL) THEN

      BEGIN

        EXECUTE IMMEDIATE 'DROP TRIGGER '|| g_utf8_trigger_tbl(i).trigger_name;
        l_triggers_dropped := l_triggers_dropped + 1;

      EXCEPTION
        WHEN trigger_not_exists THEN
          NULL;
      END;

    END IF;  -- IF l_previous_trigger ...

    l_previous_trigger := g_utf8_trigger_tbl(i).trigger_name;

  END LOOP;

END drop_all_triggers;

/**
 *  Public Procedure: create_all_triggers
 *  Modifies: Database triggers.
 *  Effects: Dynamically creates all triggers found in g_utf8_trigger_tbl in
 *           the database.
 */
PROCEDURE create_all_triggers IS

  l_previous_table     VARCHAR2(50) := NULL;
  l_triggers_created   NUMBER       := 0;
  l_cr                 VARCHAR2(1) := '
';
  l_trigger_text       VARCHAR2(30000);
  l_previous_index     NUMBER;

BEGIN
  initialize_globals; -- Bug 2766729

  --
  -- Loop through all triggers in the cached list
  -- and create them.
  --
  FOR i IN g_utf8_trigger_tbl.FIRST..g_utf8_trigger_tbl.LAST+1 LOOP
    --
    -- g_utf8_trigger_tbl.COUNT + 1 will always be the last
    -- loop, at this point g_utf8_trigger_tbl(i) is null so
    -- all we need to do is execute l_trigger_text
    -- from the previous loop.  All other processing
    -- should be ignored.
    --
    IF (i <= g_utf8_trigger_tbl.COUNT) AND
       (l_previous_table = g_utf8_trigger_tbl(i).table_name) THEN
      --
      -- More than one column should be validated in the
      -- trigger. Append the additional trigger text to
      -- validate this column.
      --
      l_trigger_text := l_trigger_text || l_cr ||
        '  IF LENGTHB(:NEW.'|| g_utf8_trigger_tbl(i).column_name || ') > ' ||
           g_utf8_trigger_tbl(i).max_length || ' THEN  '|| l_cr ||
        '    fnd_message.set_name(''PO'',''PO_UTF8_LENGTH_EXCEEDED'');' || l_cr ||
        '    fnd_message.set_token(''COLUMN_DISPLAY_NAME'', ''' ||
               INITCAP(g_utf8_trigger_tbl(i).column_display_name) || ''');' || l_cr ||
        '    fnd_message.set_token(''OLD_LENGTH'', ' ||
               g_utf8_trigger_tbl(i).max_length || ');' || l_cr ||
        '    fnd_message.set_token(''ENTERED_DATA'', :NEW.' ||
               g_utf8_trigger_tbl(i).column_name || ');' || l_cr ||
        '    fnd_message.raise_error;' || l_cr ||
        '  END IF;' || l_cr;
    ELSE
      --
      -- Execute the dynamic DDL statement only if l_previous_table has
      -- been set (i.e., not the first loop).
      --
      IF (l_previous_table IS NOT NULL) THEN
        --
        -- Add the 'end' statement to the trigger.
        --
        l_trigger_text := l_trigger_text || l_cr ||
          'END ' || g_utf8_trigger_tbl(l_previous_index).trigger_name || ';';

        EXECUTE IMMEDIATE l_trigger_text;

        l_triggers_created := l_triggers_created + 1;

      END IF;  -- IF l_previous_table ...

      IF i <= g_utf8_trigger_tbl.COUNT THEN
        --
        -- Again, only initialize the text for a new trigger
        -- if not in g_utf8_trigger_tbl.COUNT+1.
        --
        l_trigger_text :=
          'CREATE OR REPLACE TRIGGER ' || g_utf8_trigger_tbl(i).trigger_name || l_cr ||
          'BEFORE INSERT OR UPDATE ON '|| g_utf8_trigger_tbl(i).table_name || l_cr ||
          'FOR EACH ROW' || l_cr ||
          'BEGIN' || l_cr || l_cr ||
          '  IF LENGTHB(:NEW.' || g_utf8_trigger_tbl(i).column_name || ') > ' ||
             g_utf8_trigger_tbl(i).max_length || ' THEN  ' || l_cr ||
          '    fnd_message.set_name(''PO'',''PO_UTF8_LENGTH_EXCEEDED'');' || l_cr ||
          '    fnd_message.set_token(''COLUMN_DISPLAY_NAME'', ''' ||
                 INITCAP(g_utf8_trigger_tbl(i).column_display_name) || ''');' || l_cr ||
          '    fnd_message.set_token(''OLD_LENGTH'', ' ||
                 g_utf8_trigger_tbl(i).max_length || ');' || l_cr ||
          '    fnd_message.set_token(''ENTERED_DATA'', :NEW.'||
                 g_utf8_trigger_tbl(i).column_name || ');' || l_cr ||
          '    fnd_message.raise_error;' || l_cr ||
          '  END IF;' || l_cr;
      END IF;  -- IF i <= g_utf8_trigger_tbl.COUNT ...

    END IF;  -- IF (i <= g_utf8_trigger_tbl.COUNT) AND ...

    --
    -- Store the values for the next loop.
    --
    l_previous_index := i;
    IF i <= g_utf8_trigger_tbl.COUNT THEN
      l_previous_table := g_utf8_trigger_tbl(i).table_name;
    END IF;  -- IF i <= g_utf8_trigger_tbl.COUNT

  END LOOP;

  --
  -- A commit is required because this package can be executed directly from
  -- sqlplus.
  --
  COMMIT;

END create_all_triggers;

END po_utf8triggers_pvt;

/
