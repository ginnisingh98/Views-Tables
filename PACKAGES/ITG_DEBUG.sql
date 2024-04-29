--------------------------------------------------------
--  DDL for Package ITG_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_DEBUG" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgdbugs.pls 115.2 2002/11/23 07:31:46 ecoe noship $
 * CVS:  itgdbugs.pls,v 1.7 2002/11/23 03:56:32 ecoe Exp
 */

  G_ERROR_PREFIX CONSTANT VARCHAR2(100) := '@@';

  PROCEDURE setup(
    p_reset     BOOLEAN  := FALSE,
    p_msg_level NUMBER   := NULL,
    p_pkg_name  VARCHAR2 := NULL,
    p_proc_name VARCHAR2 := NULL
  );

  PROCEDURE msg(
    p_text      VARCHAR2,
    p_error     BOOLEAN  := FALSE
  );

  PROCEDURE msg(
    p_sect      VARCHAR2,
    p_text      VARCHAR2,
    p_error     BOOLEAN  := FALSE
  );

  PROCEDURE msg(
    p_sect      VARCHAR2,
    p_prompt    VARCHAR2,
    p_value     VARCHAR2,
    p_quote     BOOLEAN  := FALSE,
    p_error     BOOLEAN  := FALSE
  );

  PROCEDURE msg(
    p_sect      VARCHAR2,
    p_prompt    VARCHAR2,
    p_value     NUMBER,
    p_error     BOOLEAN  := FALSE
  );

  PROCEDURE msg(
    p_sect      VARCHAR2,
    p_prompt    VARCHAR2,
    p_value     DATE,
    p_error     BOOLEAN  := FALSE
  );

  PROCEDURE add_error(
    p_level     NUMBER   := FND_MSG_PUB.G_MSG_LVL_ERROR
  );

  PROCEDURE add_exc_error(
    p_pkg_name  VARCHAR2,
    p_api_name  VARCHAR2,
    p_level     NUMBER   := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
  );

  PROCEDURE flush_to_logfile(
    p_dir_name  VARCHAR2 := NULL,
    p_file_name VARCHAR2 := NULL
  );

END ITG_Debug;

 

/
