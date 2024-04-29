--------------------------------------------------------
--  DDL for Package Body PO_TIMING_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_TIMING_UTL" AS
/* $Header: PO_TIMING_UTL.plb 120.0 2005/07/20 10:42 bao noship $ */

-- Use this pacakge to record timing information of the program modules
-- for the current session.
-- All modules are identified by module name, which will be provided by the
-- caller.
-- To start timing, call procedure start_time
-- To end timing for a particular module, call procedure end_time
-- get_formatted_timing_info() returns a list of modules with the time recorded,
-- represented as strings. The caller can then put these information to log
-- or debug file
-- Internally, each module provided by the caller will be tracked with a
-- number attached, starting from '1'. If the same module gets timed multiple
-- times, there will be multiple entries tracked in this package, with
-- module_name being equal to <module_name>-1, <module_name>-2,... etc.
--
-- Example:
-- DECLARE
--   l_timing PO_TBL_VARCHAR4000;
-- BEGIN
--  PO_TIMING_UTL.init;
--  PO_TIMING_UTL.start_time('A');
--  PO_TIMING_UTL.start_time('B');
--  PO_TIMING_UTL.stop_time('B');
--  PO_TIMING_UTL.start_time('B');
--  PO_TIMING_UTL.stop_time('B');
--  PO_TIMING_UTL.stop_time('A');
--
--  PO_TIMING_UTL.get_formatted_timing_info (FND_API.G_TRUE, l_timing);
-- END;
--
-- In this example, l_timing record will contain entries like the following:
--   A-1: Start=11:33:25.529, End=11:33:25.529, Duration=+00 00:00:00.000140
--   B-1: Start=11:33:25.529, End=11:33:25.529, Duration=+00 00:00:00.000020
--   B-2: Start=11:33:25.529, End=11:33:25.529, Duration=+00 00:00:00.000020

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_TIMING_UTL');

g_module_list PO_TBL_VARCHAR100;

TYPE timing_rec_type IS RECORD (start_time timestamp, end_time timestamp);
TYPE timing_tbl_type IS TABLE OF timing_rec_type INDEX BY VARCHAR2(100);

g_timing_list timing_tbl_type;

TYPE module_index_tbl_type IS TABLE OF NUMBER INDEX BY VARCHAR2(100);

g_module_index_list MODULE_INDEX_TBL_TYPE;

-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: init
--Function:
--  Initialize the structure that tracks the timing information of the
--  modules
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE init IS

d_api_name CONSTANT VARCHAR2(30) := 'init';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;


BEGIN
  d_position := 0;

  g_module_list := PO_TBL_VARCHAR100();
  g_timing_list.DELETE;
  g_module_index_list.DELETE;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END init;


-----------------------------------------------------------------------
--Start of Comments
--Name: start_time
--Function:
--  Starts timing for a given module. If the same module has been
--  recorded previously, a new number will be attached to the module
--  name
--Parameters:
--IN:
--p_module
--  Module name
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE start_time
( p_module IN VARCHAR2
)
IS

d_api_name CONSTANT VARCHAR2(30) := 'start_time';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;


l_module_name VARCHAR2(100);

BEGIN
  d_position := 0;

  IF (NOT g_module_index_list.EXISTS(p_module)) THEN
    g_module_index_list(p_module) := 1;
  ELSE
    g_module_index_list(p_module) := g_module_index_list(p_module) + 1;
  END IF;

  d_position := 10;

  l_module_name := p_module || '-' || g_module_index_list(p_module);

  g_module_list.EXTEND;
  g_module_list(g_module_list.COUNT) := l_module_name;
  g_timing_list(l_module_name).START_TIME := SYSTIMESTAMP;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END start_time;

-----------------------------------------------------------------------
--Start of Comments
--Name: stop_time
--Function:
--  Stop timing for a particular module. If the same module has been
--  recorded multiple times, the latest record will be updated with
--  the stop time information
--Parameters:
--IN:
--p_module
--  Module name
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE stop_time
( p_module IN VARCHAR2
)
IS

d_api_name CONSTANT VARCHAR2(30) := 'stop_time';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_module_name VARCHAR2(100);
BEGIN

  d_position := 0;

  IF (NOT g_module_index_list.EXISTS(p_module)) THEN
    d_position := 10;

    g_module_index_list(p_module) := 1;

    g_module_list.EXTEND;
    g_module_list(g_module_list.COUNT) := p_module || '-' || g_module_index_list(p_module);
  END IF;

  l_module_name := p_module || '-' || g_module_index_list(p_module);

  g_timing_list(l_module_name).end_time := SYSTIMESTAMP;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END stop_time;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_formatted_timing_info
--Function:
--  Returns a record of strings containing timing information for all
--  modules with time recorded
--Parameters:
--IN:
--p_cleanup
--  Whether we should clear all timing information after calling this
--IN OUT:
--OUT:
--x_timing_info
--  Formatted text with module name, start time, end time, and duration info
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_formatted_timing_info
( p_cleanup IN VARCHAR2,
  x_timing_info OUT NOCOPY PO_TBL_VARCHAR4000
)
IS

d_api_name CONSTANT VARCHAR2(30) := 'get_formatted_timing_info';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_start_time timestamp;
l_end_time timestamp;

l_duration INTERVAL DAY TO SECOND;
BEGIN
  d_position := 0;

  x_timing_info := PO_TBL_VARCHAR4000();
  x_timing_info.EXTEND(g_module_list.COUNT);

  FOR i IN 1..g_module_list.COUNT LOOP
    d_position := 10;

    l_start_time := g_timing_list(g_module_list(i)).start_time;
    l_end_time := g_timing_list(g_module_list(i)).end_time;

    l_duration := l_end_time - l_start_time;

    x_timing_info(i) := g_module_list(i) || ': ' ||
            'Start=' || TO_CHAR(l_start_time, 'HH24:MI:SS.FF3') || ', ' ||
            'End=' || TO_CHAR(l_end_time, 'HH24:MI:SS.FF3') || ', ' ||
            'Duration='  || l_duration;

  END LOOP;

  IF (p_cleanup = FND_API.G_TRUE) THEN
    -- reinitialize global variables.
    init;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END get_formatted_timing_info;

END PO_TIMING_UTL;

/
