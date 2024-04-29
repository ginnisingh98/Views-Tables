--------------------------------------------------------
--  DDL for Package IGI_SLS_CONTEXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_SLS_CONTEXT_PKG" AUTHID CURRENT_USER AS
-- $Header: igislsis.pls 120.5.12010000.2 2008/08/04 13:07:54 sasukuma ship $

 PROCEDURE set_sls_context;

 PROCEDURE write_to_log (p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2);
END igi_sls_context_pkg;

/
