--------------------------------------------------------
--  DDL for Package GMS_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_COMMON_PKG" AUTHID CURRENT_USER as
/* $Header: gmscomns.pls 115.6 2002/08/01 09:43:39 gnema ship $ */

function ISNUMBER(X_string Varchar2)
return Char;
pragma restrict_references(isnumber,WNDS, RNDS,WNPS, RNPS) ;

PROCEDURE set_project_option( x_template varchar2)  ;

FUNCTION IS_project_template( x_string varchar2)
return number ;

PRAGMA restrict_references(is_project_template,WNDS,WNPS) ;

function getmax_award_number return number ;

/** -- Added for GMS-SSP Integration -- **/

TYPE po_req_dist_rec is RECORD( REQUISITION_LINE_ID NUMBER,
                            AWARD_SET_ID NUMBER);

TYPE po_req_dist_tab is TABLE OF po_req_dist_rec
                 INDEX BY BINARY_INTEGER;

x_req_dist_line po_req_dist_tab;
v_NumLines      BINARY_INTEGER := 0;

/** -- ... for GMS-SSP Integration **/


end GMS_COMMON_PKG;

 

/
