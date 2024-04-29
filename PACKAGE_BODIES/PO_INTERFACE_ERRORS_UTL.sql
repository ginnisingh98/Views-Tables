--------------------------------------------------------
--  DDL for Package Body PO_INTERFACE_ERRORS_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_INTERFACE_ERRORS_UTL" AS
/* $Header: PO_INTERFACE_ERRORS_UTL.plb 120.1 2006/05/25 22:00:12 bao noship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_INTERFACE_ERRORS_UTL');

TYPE errors_tbl_type IS TABLE OF PO_INTERFACE_ERRORS%ROWTYPE;

g_errors_tbl errors_tbl_type;

g_batch_size CONSTANT NUMBER := 5000; -- maximum number of messages the
                                      -- structure will hold before flushing
                                      -- them to PO_INTERFACE ERRORS table

-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: init_errors_tbl
--Function:
--  Initialize the data structure that holds interface errors records
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE init_errors_tbl IS

d_api_name CONSTANT VARCHAR2(30) := 'init_errors_tbl';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  g_errors_tbl := errors_tbl_type();

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END init_errors_tbl;

-----------------------------------------------------------------------
--Start of Comments
--Name: add_to_errors_tbl
--Function:
--  Adds an interface error to the structure. It also derives error
--  message text from the message name.
--Parameters:
--IN:
--p_err_type
--  Type of the record. Possible values are 'FATAL' and 'WARNING'
--p_err_rec
--  Interfac error record that contains additional information about
--  the error
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE add_to_errors_tbl
( p_err_type IN VARCHAR2,
  p_err_rec IN PO_INTERFACE_ERRORS%ROWTYPE
) IS

d_api_name CONSTANT VARCHAR2(30) := 'add_to_errors_tbl';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_unknown_intf_type CONSTANT VARCHAR2(25) := 'UNKNOWN';
l_indx NUMBER;
l_err_type_msg VARCHAR2(2000);

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'err_name', p_err_rec.error_message_name );
  END IF;

  IF (g_errors_tbl IS NULL) THEN
    init_errors_tbl;
  END IF;

  -- add one more record to the plsql table
  g_errors_tbl.extend;
  l_indx := g_errors_tbl.COUNT;
  g_errors_tbl(l_indx) := p_err_rec;

  IF (g_errors_tbl(l_indx).interface_type IS NULL) THEN
    g_errors_tbl(l_indx).interface_type := l_unknown_intf_type;
  END IF;

  d_position := 10;

  SELECT po_interface_errors_s.nextval
  INTO g_errors_tbl(l_indx).interface_transaction_id
  FROM DUAL;

  -- default WHO columns, etc.
  g_errors_tbl(l_indx).processing_date := SYSDATE;
  g_errors_tbl(l_indx).creation_date := SYSDATE;
  g_errors_tbl(l_indx).created_by := FND_GLOBAL.user_id;
  g_errors_tbl(l_indx).last_update_date := SYSDATE;
  g_errors_tbl(l_indx).last_updated_by := FND_GLOBAL.user_id;
  g_errors_tbl(l_indx).last_update_login := FND_GLOBAL.login_id;
  g_errors_tbl(l_indx).request_id := FND_GLOBAL.conc_request_id;
  g_errors_tbl(l_indx).program_application_id := FND_GLOBAL.prog_appl_id;
  g_errors_tbl(l_indx).program_id := FND_GLOBAL.conc_program_id;
  g_errors_tbl(l_indx).program_update_date := SYSDATE;

  IF (p_err_type = 'FATAL') THEN
    FND_MESSAGE.set_name('PO', 'PO_ERROR');
    l_err_type_msg := FND_MESSAGE.get || ' ';
  ELSIF (p_err_type = 'WARNING') THEN
    FND_MESSAGE.set_name('PO', 'PO_WARNING');
    l_err_type_msg := FND_MESSAGE.get || ' ';
  END IF;

  d_position := 20;

  -- Generate error message text
  IF (g_errors_tbl(l_indx).error_message IS NULL AND
      g_errors_tbl(l_indx).error_message_name IS NOT NULL) THEN

    -- bug5247736 - Use app name provided
    FND_MESSAGE.set_name (g_errors_tbl(l_indx).app_name,
                          g_errors_tbl(l_indx).error_message_name);

    IF (g_errors_tbl(l_indx).token1_name IS NOT NULL) THEN
      FND_MESSAGE.set_token(g_errors_tbl(l_indx).token1_name,
                            g_errors_tbl(l_indx).token1_value);
    END IF;

    IF (g_errors_tbl(l_indx).token2_name IS NOT NULL) THEN
      FND_MESSAGE.set_token(g_errors_tbl(l_indx).token2_name,
                            g_errors_tbl(l_indx).token2_value);
    END IF;

    IF (g_errors_tbl(l_indx).token3_name IS NOT NULL) THEN
      FND_MESSAGE.set_token(g_errors_tbl(l_indx).token3_name,
                            g_errors_tbl(l_indx).token3_value);
    END IF;

    IF (g_errors_tbl(l_indx).token4_name IS NOT NULL) THEN
      FND_MESSAGE.set_token(g_errors_tbl(l_indx).token4_name,
                            g_errors_tbl(l_indx).token4_value);
    END IF;

    IF (g_errors_tbl(l_indx).token5_name IS NOT NULL) THEN
      FND_MESSAGE.set_token(g_errors_tbl(l_indx).token5_name,
                            g_errors_tbl(l_indx).token5_value);
    END IF;

    IF (g_errors_tbl(l_indx).token6_name IS NOT NULL) THEN
      FND_MESSAGE.set_token(g_errors_tbl(l_indx).token6_name,
                            g_errors_tbl(l_indx).token6_value);
    END IF;

    g_errors_tbl(l_indx).error_message :=
      SUBSTRB(l_err_type_msg || FND_MESSAGE.get, 1, 2000);
  ELSE
    g_errors_tbl(l_indx).error_message :=
      SUBSTRB(l_err_type_msg || g_errors_tbl(l_indx).error_message, 1, 2000);
  END IF;

  IF (get_error_count = g_BATCH_SIZE) THEN
    flush_errors_tbl;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END add_to_errors_tbl;


-----------------------------------------------------------------------
--Start of Comments
--Name: flush_errors_tbl
--Function:
--  Insert all stored interface error records into database. The structure
--  is reinitialized within this procedure
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE flush_errors_tbl IS
PRAGMA AUTONOMOUS_TRANSACTION;

d_api_name CONSTANT VARCHAR2(30) := 'flush_errors_tbl';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (g_errors_tbl IS NULL) THEN
    RETURN;
  END IF;

  FORALL i IN 1..g_errors_tbl.COUNT
    INSERT INTO po_interface_errors
    VALUES g_errors_tbl(i);

  d_position := 10;

  init_errors_tbl;

  COMMIT;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END flush_errors_tbl;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_error_count
--Function:
--  Get the number of errors that are currently being held in the structure
--Parameters:
--IN:
--IN OUT:
--OUT:
--Returns:
--End of Comments
------------------------------------------------------------------------
FUNCTION get_error_count RETURN NUMBER IS

d_api_name CONSTANT VARCHAR2(30) := 'get_error_count';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  RETURN g_errors_tbl.COUNT;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END get_error_count;


END PO_INTERFACE_ERRORS_UTL;

/
