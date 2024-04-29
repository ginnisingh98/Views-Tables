--------------------------------------------------------
--  DDL for Package PA_CCD_TIEBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CCD_TIEBACK" AUTHID CURRENT_USER AS
/* $Header: PACCTIES.pls 115.4 2003/06/04 00:26:19 sbsivara ship $ */

G_bad_lines    NUMBER:= 0 ;

PROCEDURE tieback_ccds_initialize ;
PROCEDURE tieback_ccds_to_pa (
               P_Set_of_Books_id IN Number,
               P_Sob_Type IN VARCHAR2,
               P_Debug_Mode IN  VARCHAR2)  ;
FUNCTION get_reject_count RETURN NUMBER ;
PROCEDURE log_message( p_message IN VARCHAR2) ;
PROCEDURE set_curr_function(p_function IN VARCHAR2) ;
PROCEDURE reset_curr_function ;

END PA_CCD_TIEBACK;

 

/
