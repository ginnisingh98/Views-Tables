--------------------------------------------------------
--  DDL for Package AMS_LIST_RUNNING_TOTAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_RUNNING_TOTAL_PVT" AUTHID CURRENT_USER AS
/* $Header: amslruts.pls 120.1.12010000.2 2009/03/05 05:43:48 hbandi ship $*/
-- Start of Comments
--
-- NAME
--   AMS_List_running_total_pvt
--
-- PURPOSE
--   This package calculates the running totals
--
--   Procedures:
--
--
-- NOTES
--
--
-- HISTORY
--   10/29/2003 usingh created
-- End of Comments
TYPE sql_string_4k      IS TABLE OF VARCHAR2(4000) INDEX  BY BINARY_INTEGER;
TYPE t_number        is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
/*
PROCEDURE sample_ds_for_templ (
                            p_template_id                  NUMBER
                            );
*/
PROCEDURE gen_lov_filter_for_templmv (
                            x_filter_sql    OUT NOCOPY     VARCHAR2,
                            x_string_params OUT NOCOPY sql_string_4k,
                            x_num_params    OUT NOCOPY            NUMBER,
                            p_template_id   IN   NUMBER
                            );
/*
PROCEDURE get_total_count_for_templmv (
                            x_count         OUT NOCOPY            NUMBER,
                            p_sql           IN       VARCHAR2,
                            p_string_params IN       sql_string_4k,
                            p_num_params    IN             NUMBER
                            );
*/


PROCEDURE calculate_running_totals (
                            Errbuf          OUT NOCOPY     VARCHAR2,
                            Retcode         OUT NOCOPY     VARCHAR2,
                            p_template_id                  NUMBER
                            );

PROCEDURE generate_mv_for_template (
                            Errbuf          OUT NOCOPY     VARCHAR2,
                            Retcode         OUT NOCOPY     VARCHAR2,
                            p_template_id                  NUMBER
                            );

PROCEDURE calc_tot_for_all_templates (
                            Errbuf          OUT NOCOPY     VARCHAR2,
                            Retcode         OUT NOCOPY     VARCHAR2
                            );


PROCEDURE process_query (
                            p_sql_string     	IN sql_string_4k,
			    p_total_parameters 	IN t_number,
			    p_string_parameters	IN sql_string_4k,
			    p_template_id       IN NUMBER,
                            p_parameters     	IN sql_string_4k,
			    p_parameters_value 	IN t_number,
			    p_sql_results       OUT NOCOPY t_number
                        );

--hbandi added this procedure for resolving the bug #8221231(DB VERSION)
PROCEDURE parse_db_version(
                           db_version_major OUT  NOCOPY NUMBER,
                           db_version_minor OUT  NOCOPY NUMBER
			   );

END AMS_List_running_total_pvt;

/
