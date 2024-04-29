--------------------------------------------------------
--  DDL for Package Body PO_R12_CAT_UPG_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_R12_CAT_UPG_DEBUG" AS
/* $Header: PO_R12_CAT_UPG_DEBUG.plb 120.2 2006/01/30 23:17:44 pthapliy noship $ */

g_log_level NUMBER := 1;
g_is_logging_enabled BOOLEAN := TRUE;

PROCEDURE set_logging_options
(
  p_log_level NUMBER
)
IS
BEGIN
  g_log_level := p_log_level;

  IF (NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N') <> 'N') THEN
    IF (p_log_level = 1) THEN
      g_is_logging_enabled := TRUE;
    ELSE
      g_is_logging_enabled := FALSE;
    END IF;
  ELSE
    g_is_logging_enabled := FALSE;
  END IF;
END set_logging_options;

FUNCTION is_logging_enabled
RETURN BOOLEAN
IS
BEGIN
  return g_is_logging_enabled;
END is_logging_enabled;

PROCEDURE log
(
  p_log_level NUMBER
, p_module    VARCHAR2
, p_progress  VARCHAR2
, p_message   VARCHAR2
)
IS
BEGIN
  -- PO_DEBUG.put_line(p_module||','||p_progress||','||p_message);
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= p_log_level) THEN
    FND_LOG.string(log_level => p_log_level
                 , module    => p_module
                 , message   => p_progress||','||p_message);
  END IF;
END log;

PROCEDURE log_stmt
(
  p_module    VARCHAR2
, p_progress  VARCHAR2
, p_message   VARCHAR2
)
IS
BEGIN
  log(p_log_level => 1
    , p_module    => p_module
    , p_progress  => p_progress
    , p_message   => p_message);
END log_stmt;


END PO_R12_CAT_UPG_DEBUG;

/
