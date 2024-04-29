--------------------------------------------------------
--  DDL for Package MST_PQ_WORKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_PQ_WORKS" AUTHID CURRENT_USER AS
/* $Header: MSTPQWKS.pls 115.3 2004/01/10 12:05:43 skakani noship $ */
    PROCEDURE populate_result_table(errbuf		OUT NOCOPY VARCHAR2,
					                retcode		OUT NOCOPY NUMBER,
                                    p_query_id     IN NUMBER,
                                    p_plan_id      IN NUMBER );

    --PROCEDURE populate_result_table(p_query_id     IN NUMBER,
      --                              p_plan_id      IN NUMBER);

                                    --p_where_clause IN VARCHAR2,
                                    --p_execute_flag IN BOOLEAN);

    PROCEDURE remove_query(P_QUERY_ID IN NUMBER,
                           P_QUERY_TYPE IN NUMBER);

    PROCEDURE remove_qry_and_results(P_QUERY_ID IN NUMBER,
                                     P_QUERY_TYPE IN NUMBER);

    PROCEDURE RENAME_QUERY(P_QUERY_ID IN NUMBER,
                           p_query_name IN VARCHAR2,
                           p_description IN VARCHAR2,
                           p_public_flag IN NUMBER);

    PROCEDURE insert_load_selection(p_query_id IN NUMBER);

    PROCEDURE insert_cm_selection(p_query_id IN NUMBER);

    PROCEDURE insert_order_selection(p_query_id IN NUMBER);

    PROCEDURE insert_excep_selection(p_query_id IN NUMBER);

    PROCEDURE save_query_result(p_query_id IN NUMBER);

    PROCEDURE clear_temp_query(p_query_id IN NUMBER);

    FUNCTION launch_request(p_query_id IN NUMBER,p_plan_id IN NUMBER)
     RETURN NUMBER;

END MST_PQ_WORKS;

 

/
