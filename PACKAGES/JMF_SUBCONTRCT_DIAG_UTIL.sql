--------------------------------------------------------
--  DDL for Package JMF_SUBCONTRCT_DIAG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SUBCONTRCT_DIAG_UTIL" AUTHID CURRENT_USER AS
/* $Header: JMFDUSBS.pls 120.0.12010000.2 2010/06/28 06:29:06 abhissri ship $ */

--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFDUSBS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Package specification file for Subcontracting      |
--|                        Diagnostics Utility Package                        |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   20-DEC-2007          kdevadas  Created.                                 |
--+===========================================================================+


G_STATUS_SUCCESS CONSTANT VARCHAR2(10) := 'SUCCESS';
G_STATUS_FAILURE CONSTANT VARCHAR2(10) := 'FAILURE';

FUNCTION Check_Accounting_Periods RETURN VARCHAR2;
FUNCTION Check_Routings RETURN VARCHAR2 ;
FUNCTION Check_Shipping_Network RETURN VARCHAR2 ;
FUNCTION Check_Shipping_Methods RETURN VARCHAR2 ;
FUNCTION Check_Profiles RETURN VARCHAR2 ;
FUNCTION Check_WIP_Parameters RETURN VARCHAR2 ;
FUNCTION Check_Cust_Supp_Association RETURN VARCHAR2 ;
FUNCTION Check_Price_List RETURN VARCHAR2 ;

END JMF_SUBCONTRCT_DIAG_UTIL;

/
