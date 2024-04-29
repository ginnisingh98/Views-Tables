--------------------------------------------------------
--  DDL for Package PER_QP_INVOCATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QP_INVOCATIONS" AUTHID CURRENT_USER as
/* $Header: ffqti01t.pkh 115.2 2002/12/23 13:12:39 arashid ship $ */
--
function get_qp_session_id return NUMBER;
--
procedure pre_insert_checks(p_qp_session_id             NUMBER
                           ,p_invocation_context        NUMBER
                           ,p_invocation_type           VARCHAR2
                           ,p_qp_report_id              NUMBER
                           ,p_qp_invocation_id   IN OUT NOCOPY NUMBER);
--
procedure populate_fields(p_qp_report_id             NUMBER
                         ,p_invocation_context       NUMBER
                         ,p_invocation_type          VARCHAR2
                         ,p_session_date             DATE
                         ,p_qp_report_name    IN OUT NOCOPY VARCHAR2
                         ,p_assignment_set    IN OUT NOCOPY VARCHAR2
                         ,p_full_name         IN OUT NOCOPY VARCHAR2
                         ,p_assignment_number IN OUT NOCOPY VARCHAR2
                         ,p_user_person_type  IN OUT NOCOPY VARCHAR2);
--
function format_date_line(p_textline VARCHAR2) return VARCHAR2;
--
function load_result(p_assignment_id    NUMBER
                    ,p_qp_invocation_id NUMBER) return VARCHAR2;
--
procedure get_assignment(p_assignment_id            NUMBER
                        ,p_qp_invocation_id         NUMBER
                        ,p_full_name         IN OUT NOCOPY VARCHAR2
                        ,p_user_person_type  IN OUT NOCOPY VARCHAR2
                        ,p_assignment_number IN OUT NOCOPY VARCHAR2
                        ,p_result               OUT NOCOPY VARCHAR2);
--
procedure init_cust(p_customized_restriction_id        NUMBER
                   ,p_restrict_empapl           IN OUT NOCOPY VARCHAR2
                   ,p_restrict_person_type      IN OUT NOCOPY VARCHAR2
                   ,p_restrict_inq              IN OUT NOCOPY VARCHAR2
                   ,p_restrict_use              IN OUT NOCOPY VARCHAR2);
--
function  validate_assignment(p_business_group_id NUMBER
                            ,p_session_date       DATE
                            ,p_full_name          VARCHAR2
                            ,p_assignment_number  VARCHAR2) return NUMBER;
--
procedure delete_quickpaints(p_qp_session_id NUMBER);
--
function print_result(p_business_group_id NUMBER
                      ,p_session_date     DATE
                      ,p_qp_invocation_id NUMBER) return BOOLEAN;
--
END PER_QP_INVOCATIONS;

 

/
