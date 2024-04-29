--------------------------------------------------------
--  DDL for Package PER_AE_XDO_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_AE_XDO_REPORT" AUTHID CURRENT_USER AS
/* $Header: peaexdor.pkh 120.2.12010000.1 2008/07/28 04:04:49 appldev ship $ */

  TYPE xmlrec IS RECORD
    (tagName VARCHAR2(240)
    ,tagValue VARCHAR2(240));
  TYPE txmltable IS TABLE OF xmlRec INDEX BY BINARY_INTEGER;
  gxmltable txmltable;
  gCtr      NUMBER;


PROCEDURE get_visa_data
    (p_request_id                 IN  NUMBER
     ,p_report_name               IN  VARCHAR2
     ,p_date                      IN  VARCHAR2 DEFAULT NULL
     ,p_business_group_id         IN  NUMBER DEFAULT NULL
     ,p_org_structure_id          IN  NUMBER DEFAULT NULL
     ,p_org_structure_version_id  IN  NUMBER DEFAULT NULL
     ,p_expires_in                IN  NUMBER DEFAULT NULL
     ,p_units                     IN  VARCHAR2 DEFAULT NULL
     ,l_xfdf_blob                 OUT NOCOPY BLOB);

PROCEDURE get_passport_data
    (p_request_id                 IN  NUMBER
     ,p_report_name               IN  VARCHAR2
     ,p_date                      IN  VARCHAR2 DEFAULT NULL
     ,p_business_group_id         IN  NUMBER DEFAULT NULL
     ,p_org_structure_id          IN  NUMBER DEFAULT NULL
     ,p_org_structure_version_id  IN  NUMBER DEFAULT NULL
     ,p_expires_in                IN  NUMBER DEFAULT NULL
     ,p_units                     IN  VARCHAR2 DEFAULT NULL
     ,l_xfdf_blob                 OUT NOCOPY BLOB);

 PROCEDURE get_contract_data
    (p_request_id                 IN  NUMBER
     ,p_report_name               IN  VARCHAR2
     ,p_date                      IN  VARCHAR2 DEFAULT NULL
     ,p_business_group_id         IN  NUMBER DEFAULT NULL
     ,p_org_structure_id          IN  NUMBER DEFAULT NULL
     ,p_org_structure_version_id  IN  NUMBER DEFAULT NULL
     ,p_org_id			  IN  NUMBER DEFAULT NULL
     ,p_expires_in                IN  NUMBER
     ,p_units                     IN  VARCHAR2
     ,l_xfdf_blob                 OUT NOCOPY BLOB);

  PROCEDURE clob_to_blob
    (p_clob       CLOB
    ,p_blob       IN OUT NOCOPY BLOB);

  PROCEDURE Writetoclob
    (p_xfdf_blob    OUT NOCOPY BLOB
    ,p_tot_pg_count IN NUMBER);

  PROCEDURE fetch_pdf_blob
    (p_report     IN  VARCHAR2
    ,P_date       IN  VARCHAR2
    ,p_pdf_blob   OUT NOCOPY BLOB);

  FUNCTION get_lookup_meaning
    (p_lookup_type VARCHAR2
    ,p_lookup_code VARCHAR2) RETURN VARCHAR2;


END per_ae_xdo_report;

/
