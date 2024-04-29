--------------------------------------------------------
--  DDL for Package MSC_X_HZ_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_HZ_PLAN" AUTHID CURRENT_USER AS
/*  $Header: MSCXHZPS.pls 120.0 2005/05/25 19:49:12 appldev noship $ */

  Procedure populate_bucketed_quantity(
                             arg_query_id     OUT NOCOPY NUMBER,
                             arg_next_link    OUT NOCOPY VARCHAR2,
                             arg_num_rowset   OUT NOCOPY NUMBER,
                             arg_err_msg      OUT NOCOPY VARCHAR2,
                             arg_default_pref OUT NOCOPY NUMBER,
                             arg_pref_name    IN  VARCHAR2 DEFAULT NULL,
                             arg_start_row    IN  NUMBER   DEFAULT 1,
                             arg_end_row      IN  NUMBER   DEFAULT 25,
                             arg_item_sort    IN  VARCHAR2 DEFAULT 'ASC',
                             arg_from_date    IN  DATE     DEFAULT sysdate,
                             arg_where_clause IN  VARCHAR2 DEFAULT NULL,
                             arg_plan_under   IN  VARCHAR2 DEFAULT 'N',
                             arg_plan_over    IN  VARCHAR2 DEFAULT 'N',
                             arg_actual_under IN  VARCHAR2 DEFAULT 'N',
                             arg_actual_over  IN  VARCHAR2 DEFAULT 'N'
                             );


  FUNCTION get_lookup_name(v_lookup_type IN VARCHAR2, v_lookup_code IN NUMBER) RETURN VARCHAR2 ;


END MSC_X_HZ_PLAN;

 

/
