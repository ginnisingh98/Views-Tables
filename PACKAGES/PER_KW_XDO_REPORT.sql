--------------------------------------------------------
--  DDL for Package PER_KW_XDO_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KW_XDO_REPORT" AUTHID CURRENT_USER AS
/* $Header: pekwxdor.pkh 120.0 2005/05/31 11:12:51 appldev noship $ */

  TYPE xmlrec IS RECORD
    (tagName VARCHAR2(240)
    ,tagValue VARCHAR2(240));
  TYPE txmltable IS TABLE OF xmlRec INDEX BY BINARY_INTEGER;
  gxmltable txmltable;
  gCtr      NUMBER;


  PROCEDURE get_disability_data
     (p_request_id                IN  NUMBER
     ,p_report_name               IN  VARCHAR2
     ,p_date                      IN  VARCHAR2 DEFAULT NULL
     ,p_business_group_id         IN  NUMBER DEFAULT NULL
     ,p_org_structure_id          IN  NUMBER DEFAULT NULL
     ,p_org_structure_version_id  IN  NUMBER DEFAULT NULL
     ,p_legal_employer            IN  NUMBER DEFAULT NULL
     ,p_disability_type           IN  VARCHAR2 DEFAULT NULL
     ,p_disability_status         IN  VARCHAR2 DEFAULT NULL
     ,l_xfdf_blob                 OUT NOCOPY BLOB);

  PROCEDURE get_contract_data
    (p_request_id                 IN  NUMBER
     ,p_report_name               IN  VARCHAR2
     ,p_date                      IN  VARCHAR2 DEFAULT NULL
     ,p_business_group_id         IN  NUMBER DEFAULT NULL
     ,p_org_structure_id          IN  NUMBER DEFAULT NULL
     ,p_org_structure_version_id  IN  NUMBER DEFAULT NULL
     ,p_legal_employer            IN  NUMBER DEFAULT NULL
     ,p_duration                  IN  NUMBER
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


END per_kw_xdo_report;

 

/
