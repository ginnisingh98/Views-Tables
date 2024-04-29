--------------------------------------------------------
--  DDL for Package FEM_SESSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_SESSION_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_session.pls 120.0 2008/02/04 20:33:08 ghall ship $ */

   PROCEDURE start_alter_session (p_enable IN BOOLEAN);

   PROCEDURE stop_alter_session (p_enable IN BOOLEAN);

END fem_session_pkg;

/
