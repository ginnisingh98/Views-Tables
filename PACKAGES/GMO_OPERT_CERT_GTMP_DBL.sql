--------------------------------------------------------
--  DDL for Package GMO_OPERT_CERT_GTMP_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_OPERT_CERT_GTMP_DBL" AUTHID CURRENT_USER AS
/* $Header: GMOVGCTS.pls 120.1 2007/06/21 06:14:43 rvsingh noship $ */
/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |       GMOVGCTS.pls
 |
 |   DESCRIPTION
 |      Spec of package gmo_opert_cert_gtmp
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   12-MAR-07 Pawan Kumar  Created
 |
 |      - insert_row
 |
 |
 |
 =============================================================================
*/
   PROCEDURE INSERT_ROW (
    p_ERECORD_ID               IN NUMBER
   ,p_Operator_certificate_id  IN NUMBER
   ,p_EVENT_KEY                IN VARCHAR2
   ,p_EVENT_NAME               IN VARCHAR2
   ,x_return_status            OUT NOCOPY VARCHAR2);

END gmo_opert_cert_gtmp_dbl;

/
