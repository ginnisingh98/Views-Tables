--------------------------------------------------------
--  DDL for Package PO_R12_CAT_UPG_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_R12_CAT_UPG_DEBUG" AUTHID CURRENT_USER AS
/* $Header: PO_R12_CAT_UPG_DEBUG.pls 120.1 2006/01/30 23:21:06 pthapliy noship $ */

PROCEDURE log
(
  p_log_level NUMBER
, p_module    VARCHAR2
, p_progress  VARCHAR2
, p_message   VARCHAR2
);

PROCEDURE log_stmt
(
  p_module    VARCHAR2
, p_progress  VARCHAR2
, p_message   VARCHAR2
);

PROCEDURE set_logging_options
(
  p_log_level NUMBER
);

FUNCTION is_logging_enabled RETURN BOOLEAN;

END PO_R12_CAT_UPG_DEBUG;

 

/
