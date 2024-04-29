--------------------------------------------------------
--  DDL for Package PJI_RESOURCE_UTILZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_RESOURCE_UTILZ" AUTHID CURRENT_USER AS
/* $Header: PJIPR01S.pls 120.2 2005/12/13 03:58:16 pschandr noship $ */

TYPE   V_TYPE_TAB    IS   TABLE OF VARCHAR2(50)
   INDEX BY BINARY_INTEGER;

TYPE   N_TYPE_TAB    IS   TABLE OF NUMBER(15)
   INDEX BY BINARY_INTEGER;

PROCEDURE GET_PERIOD_DATA
(
         p_calendar_type	IN  VARCHAR2
	,p_org_id		IN  NUMBER
        ,x_calendar_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_accnt_period_type OUT NOCOPY /* file.sql.39 change */ VARCHAR2
        ,x_sets_of_books_id OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE PJI_POP_SIMPLE_UTILZ_DATA
(
	 p_calendar_id 		IN  NUMBER
        ,p_calendar_type	IN  VARCHAR2
        ,p_population_mode	IN  VARCHAR2
        ,p_table_amount_type	IN  NUMBER DEFAULT NULL
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ NUMBER
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE PJI_POP_COMPLEX_UTILZ_DATA
(
	 p_calendar_id 		IN  NUMBER
        ,p_calendar_type	IN  VARCHAR2
        ,p_population_mode	IN  VARCHAR2
	,p_org_id		IN  NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ NUMBER
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE PJI_POP_GRAPH_UTILZ_DATA
(
	 p_person_id   		IN  NUMBER
	,p_period_id   		IN  NUMBER
	,p_period_type 		IN  NUMBER
        ,p_calendar_type	IN  VARCHAR2
	,p_org_id		IN  NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2

);

PROCEDURE PJI_POP_TABLE_UTILZ_DATA
(
	 p_person_id   		IN  NUMBER
	,p_period_id   		IN  NUMBER
	,p_period_type 		IN  NUMBER
        ,p_calendar_type	IN  VARCHAR2
	,p_org_id		IN  NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE PJI_POPULATE_PERIODS
(
	 p_period_type_id	IN  NUMBER
        ,p_calendar_type	IN  VARCHAR2
        ,p_period_id		IN  NUMBER
	,p_org_id		IN  NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE PJI_GET_PERIOD_PROFILE_DATA
(
         p_org_id	 IN  NUMBER
	,x_period_type_id OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_calendar_type OUT NOCOPY /* file.sql.39 change */ VARCHAR2
        ,x_person_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_period_type	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
        ,x_curr_period_id OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_curr_period_name OUT NOCOPY /* file.sql.39 change */ VARCHAR2
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE PJI_POP_UTILIZATION_DATA
(
	 p_person_id		IN  NUMBER
	,p_period_id   		IN  NUMBER
	,p_period_type 		IN  NUMBER
        ,p_calendar_type	IN  VARCHAR2
	,p_org_id		IN  NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE GET_PERSON_FROM_RES
(
         p_resource_id		IN  NUMBER
        ,x_person_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

END PJI_RESOURCE_UTILZ;

 

/
