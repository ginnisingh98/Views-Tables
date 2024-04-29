--------------------------------------------------------
--  DDL for Package PER_ES_COMP_CERT_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ES_COMP_CERT_ARCHIVE_PKG" AUTHID CURRENT_USER as
/* $Header: peesccar.pkh 120.4 2006/06/15 11:37:30 grchandr noship $ */


TYPE XMLRec IS RECORD(
TagName VARCHAR2(240),
TagValue VARCHAR2(240));
TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
vXMLTable tXMLTable;
vCtr NUMBER;

FUNCTION get_parameters(p_payroll_action_id IN  NUMBER,
                        p_token_name        IN  VARCHAR2) RETURN VARCHAR2;
--
PROCEDURE get_all_parameters(p_payroll_action_id  IN         NUMBER
                            ,p_business_group_id  OUT NOCOPY NUMBER
                            ,p_start_date         OUT NOCOPY DATE
                            ,p_end_date           OUT NOCOPY DATE
                            ,p_legal_employer     OUT NOCOPY NUMBER);
--
PROCEDURE range_code(p_actid IN  NUMBER
                    ,sqlstr OUT NOCOPY VARCHAR2);

--
PROCEDURE action_creation_code (p_actid    IN NUMBER
                               ,stperson  IN NUMBER
                               ,endperson IN NUMBER
                               ,chunk     IN NUMBER);
--
PROCEDURE archive_code (p_assactid       in number,
                          p_effective_date in date);

--
PROCEDURE get_person_address(p_person_id          IN NUMBER
                            ,p_assactid              IN NUMBER
                            ,p_assignment_id         IN NUMBER
                            ,p_termination_date      IN DATE
                            ,p_effective_date        IN DATE
                            );
--
PROCEDURE get_employer_address(p_organization_id       IN NUMBER
                              ,p_actid                 IN NUMBER
                              ,p_effective_date        IN DATE
                              );
--
PROCEDURE get_employee_data(p_assactid              IN NUMBER
                           ,p_assignment_id         IN OUT NOCOPY NUMBER
                           ,p_effective_date        IN DATE
                           ,p_person_id             IN OUT NOCOPY NUMBER
                           ,p_end_date              IN OUT NOCOPY DATE
                           ,p_type                  IN OUT NOCOPY VARCHAR2
                           );
--
PROCEDURE get_element_entries(p_assactid             IN NUMBER
                             ,p_assignment_id        IN NUMBER
                             ,p_effective_date       IN DATE
                             ,p_type                 IN VARCHAR2
                             );
--
PROCEDURE clob_to_blob (p_clob clob,
                        p_blob IN OUT NOCOPY Blob);
--PROCEDURE WritetoCLOB (p_xfdf_blob out nocopy blob);
PROCEDURE WritetoCLOB (p_xfdf_blob out nocopy blob
                      ,p_xfdf_string out nocopy clob);
--
PROCEDURE fetch_pdf_blob (p_pdf_blob OUT NOCOPY BLOB);
--
PROCEDURE populate_comp_cert
  (p_request_id IN      NUMBER
  ,p_payroll_action_id  NUMBER
  ,p_legal_employer     NUMBER
  ,p_person_id          NUMBER
  ,p_xfdf_blob          OUT NOCOPY BLOB);
--
PROCEDURE populate_plsql_table
  (p_request_id IN      NUMBER
  ,p_payroll_action_id  NUMBER
  ,p_legal_employer     NUMBER
  ,p_person_id          NUMBER);
--
END per_es_comp_cert_archive_pkg;

 

/
