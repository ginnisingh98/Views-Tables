--------------------------------------------------------
--  DDL for Package MSC_PQ_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_PQ_UTILS" AUTHID CURRENT_USER as
/* $Header: MSCPQUTS.pls 120.4 2007/06/07 14:19:30 skakani ship $ */
    TYPE among_values_rec IS RECORD(SEQUENCE        NUMBER,
                                    OBJECT_SEQUENCE NUMBER,
                                    FIELD_NAME      VARCHAR2(55),
                                    OR_VALUES       VARCHAR2(250),
                                    HIDDEN_VALUES   VARCHAR2(250));

    TYPE among_values_tab IS TABLE OF among_values_rec INDEX BY BINARY_INTEGER;


FUNCTION build_where_clause(p_query_id    IN NUMBER DEFAULT NULL,
                              P_source_type IN NUMBER DEFAULT NULL)
                              RETURN VARCHAR2;

FUNCTION build_order_where_clause(p_query_id IN NUMBER,
                                  p_plan_id  IN NUMBER)
                       RETURN VARCHAR2;

FUNCTION get_where_clause (sequence            NUMBER,
                             obj_sequence        NUMBER,
                             field_name   IN OUT NOCOPY VARCHAR2,
                             operator            NUMBER,
                             low                 VARCHAR2,
                             high                VARCHAR2,
                             hidden_from         VARCHAR2,
                             data_set     IN OUT NOCOPY varchar2,
                             data_type    IN OUT NOCOPY VARCHAR2,
				             lov_type     IN     NUMBER,
				             p_match_str  IN     VARCHAR2,
				             p_excp_where IN     VARCHAR2)
				             RETURN VARCHAR2;

PROCEDURE retrieve_values (p_folder_id number);

FUNCTION get_among_where_clause (sequence          NUMBER,
                                  obj_sequence     NUMBER,
                                  t_operator        VARCHAR2,
                                  field_name IN OUT NOCOPY VARCHAR2,
                                  operator          NUMBER,
                                  low               VARCHAR2,
                                  high              VARCHAR2,
                                  hidden_from       VARCHAR2,
                                  data_set IN OUT NOCOPY VARCHAR2,
                                  datatype IN OUT NOCOPY VARCHAR2)
                                  RETURN VARCHAR2;

PROCEDURE build_Excp_where(p_query_id        IN NUMBER,
                           p_obj_sequence_id IN NUMBER,
                           p_sequence_id     IN NUMBER,
                           p_plan_id         IN NUMBER,
                           p_where_clause    IN VARCHAR2,
                           p_excp_where_clause IN OUT NOCOPY VARCHAR2,
                           p_match_str IN VARCHAR2 DEFAULT ' AND ');

PROCEDURE store_values(p_sequence      IN NUMBER,
                       p_obj_sequence  IN NUMBER,
                       p_field_name    IN VARCHAR2,
                       p_or_values     IN VARCHAR2,
                       p_hidden_values IN VARCHAR2);

PROCEDURE clear_values;

PROCEDURE delete_rows(p_field_name in varchar2);

--PROCEDURE execute_pquery(p_plan_id IN NUMBER);

--FUNCTION execute_pquery(p_plan_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE execute_one(p_plan_id IN NUMBER,
                      p_calledFromUI IN NUMBER,
                      p_partOfWorklist IN NUMBER,
                      p_query_id IN NUMBER,
                      p_query_type IN NUMBER,
                      p_execute_flag BOOLEAN DEFAULT TRUE,
                      p_master_query_id IN NUMBER DEFAULT NULL);

FUNCTION get_error RETURN VARCHAR2;

PROCEDURE execute_plan_queries(errbuf    OUT NOCOPY VARCHAR2,
                               retcode   OUT NOCOPY NUMBER,
                               p_plan_id IN NUMBER);

PROCEDURE execute_plan_worklists(errbuf    OUT NOCOPY VARCHAR2,
                                 retcode   OUT NOCOPY NUMBER,
                                 p_plan_id IN NUMBER);

END MSC_PQ_UTILS;

/
