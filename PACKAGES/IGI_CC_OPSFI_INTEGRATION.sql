--------------------------------------------------------
--  DDL for Package IGI_CC_OPSFI_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CC_OPSFI_INTEGRATION" AUTHID CURRENT_USER AS
/* $Header: igiaolas.pls 120.3.12000000.1 2007/07/02 08:29:51 smannava ship $ */

    PROCEDURE Switch_Options;

    FUNCTION Is_CC_On (p_org_id igi_gcc_inst_options_all.org_id%TYPE) RETURN BOOLEAN;

    FUNCTION Is_CBC_On_For_CC_PO RETURN BOOLEAN;
END IGI_CC_OPSFI_INTEGRATION;

 

/
