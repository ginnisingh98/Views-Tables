--------------------------------------------------------
--  DDL for Package GML_UPDATE_CUST_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_UPDATE_CUST_DATA_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMLCUSYS.pls 120.0 2005/05/25 16:18:48 appldev noship $ */

 /*=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMLCUSYS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains definitions of private routines               |
 |     used for update of cust_id as a part of elimination of Customer     |
 |     Synchronization.                                                    |
 |                                                                         |
 | HISTORY                                                                 |
 |     26-JAN-2005  PKANETKA        Created                                |
 |                                                                         |
 +=========================================================================+
  API Name  : GML_UPDATE_CUST_DATA_PVT
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/

FUNCTION GET_BILLCUST_ID
 (
  p_opm_cust_id IN NUMBER
 )
 RETURN NUMBER;

FUNCTION GET_SHIPCUST_ID
 (
  p_opm_cust_id IN NUMBER
 )
 RETURN NUMBER;

FUNCTION GET_ANYCUST_ID
 (
  p_opm_cust_id IN NUMBER
 )
 RETURN NUMBER;

PROCEDURE UPDATE_CUST_ID;


END GML_UPDATE_CUST_DATA_PVT;

 

/
