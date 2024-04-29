--------------------------------------------------------
--  DDL for Package XXAH_ATTCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_ATTCH_PKG" AS

/**************************************************************************
 * VERSION      : 1.0
 * DESCRIPTION  : Prevent attachment creation on blanket agreement when
 *                created from negotiation
 *
 * Preventing creation would imply patch-sensitive modifications to
 * the OA Framework. Therefore solution by use of package triggers which
 * remove freshly created attachments for contract (created within
 * 1 minute of the contract creation itself).
 *
 * Trigger only removes the records from tables directly connected to the
 * contract. All other tables are left unchanged.
 *
 * Tables on which triggers are implemented:
 *   FAD = FND_ATTACHED_DOCUMENTS
 *   PBH = PON_BID_HEADERS
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 16-SEP-2008 P. Timmermans     Genesis.
 *************************************************************************/

  TYPE fad_rowid_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  fad_rowid_table        fad_rowid_type;
  fad_rowid_table_old    fad_rowid_type;
  fad_rowid_count        NUMBER := 0;
  fad_in_after_statement BOOLEAN := FALSE;

  PROCEDURE init_fad_rowid;

  PROCEDURE add_fad_rowid ( fad_rowid IN NUMBER );

  PROCEDURE clear_fad_rowid;

  PROCEDURE remove_terms ( p_po_header_id IN NUMBER );

END xxah_attch_pkg;
 

/
