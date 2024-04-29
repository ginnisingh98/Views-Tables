--------------------------------------------------------
--  DDL for Package GL_BC_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BC_GROUP_PKG" AUTHID CURRENT_USER as
/* $Header: glibcgps.pls 120.2 2005/05/05 00:59:38 kvora ship $ */
--
-- Package
--   gl_bc_group_pkg
-- Purpose
--   To contain validation, insertion, and update routines for gl_bc_group
-- History
--   09-12-94   Sharif Rahman 	Created

PROCEDURE check_unique_bc_option_name( X_bc_option_name  VARCHAR2 );

FUNCTION get_unique_id RETURN NUMBER;

END GL_BC_GROUP_PKG;

 

/
