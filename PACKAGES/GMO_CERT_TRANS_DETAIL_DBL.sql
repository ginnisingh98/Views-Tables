--------------------------------------------------------
--  DDL for Package GMO_CERT_TRANS_DETAIL_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_CERT_TRANS_DETAIL_DBL" AUTHID CURRENT_USER AS
/* $Header: GMOVGCDS.pls 120.1 2007/06/21 06:14:00 rvsingh noship $ */
/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |       GMOVGCDS.pls
 |
 |   DESCRIPTION
 |      Spec of package gmo_oper_cert_trans_dbl
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   12-MAR-07 Pawan Kumar  Created
 |
 |      - insert_row
 |      - fetch_row
 |      - update_row
 |      - lock_row
 |
 |
 =============================================================================
*/
   PROCEDURE INSERT_ROW (

   p_trans_detail_id          IN OUT NOCOPY    NUMBER
  ,p_operator_certificate_id  IN               NUMBER
  ,p_header_id                IN               NUMBER
  ,p_Qualification_id         IN               NUMBER
  ,p_Qualification_type       IN               NUMBER
  ,p_PROFICIENCY_LEVEL_ID     IN               NUMBER
  ,x_return_Status          OUT   NOCOPY     VARCHAR2 );



END gmo_cert_trans_detail_dbl;

/
