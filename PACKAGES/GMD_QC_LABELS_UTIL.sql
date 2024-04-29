--------------------------------------------------------
--  DDL for Package GMD_QC_LABELS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_LABELS_UTIL" AUTHID CURRENT_USER AS
/*  $Header: GMDULABS.pls 120.1 2005/08/16 05:15:35 svankada noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMDULABS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public definitions For Generating             |
 |     QC LABELS                                                           |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     23-JUL-2002  H.Verdding                                             |
 |     17-APR-2003  magupta   Changed for stability study.                 |
 |     01-JUN-2005  jdiiorio  Changed for OPM Convergence.                 |
 |                            Changed p_orgn_code to p_organization_id.    |
 |                                                                         |
 +=========================================================================+
  API Name  : GMD_QC_LABELS_UTIL
  Type      : UTIL
  Function  : This package contains public procedures for Generating QC labels
  Pre-reqs  : N/A
  Parameters: Per function


  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/

/*   Define Procedures And Functions :   */


PROCEDURE SAMPLE_GEN_SRS
( errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  p_organization_id IN  NUMBER DEFAULT NULL,
  p_from_sample_no  IN  VARCHAR2 DEFAULT NULL,
  p_to_sample_no    IN  VARCHAR2 DEFAULT NULL,
  p_delimiter       IN  VARCHAR2 DEFAULT ',',
  p_variant_id      IN  NUMBER DEFAULT NULL,
  p_time_point_id   IN  NUMBER DEFAULT NULL
);


END GMD_QC_LABELS_UTIL;

 

/
