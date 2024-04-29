--------------------------------------------------------
--  DDL for Package FV_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_AR_PKG" AUTHID CURRENT_USER AS
    /* $Header: FVARPDRS.pls 115.1 2003/07/02 19:40:01 snama noship $ */
    --  ==============================================================================
    --              Parameters
    --  ==============================================================================

PROCEDURE delete_offsetting_unapp(p_posting_control_id IN NUMBER,
	                              p_sob_id IN NUMBER,
				      p_status OUT NUMBER) ;

END fv_ar_pkg;

 

/
