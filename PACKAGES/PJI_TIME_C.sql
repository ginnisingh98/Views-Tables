--------------------------------------------------------
--  DDL for Package PJI_TIME_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_TIME_C" AUTHID CURRENT_USER AS
/*$Header: PJICMT1S.pls 120.0 2005/05/29 12:37:11 appldev noship $*/
PROCEDURE LOAD ( p_period_set_name VARCHAR2 DEFAULT NULL
		, p_period_type VARCHAR2 DEFAULT NULL
		, x_return_status OUT NOCOPY VARCHAR2
		, x_msg_count OUT NOCOPY NUMBER
		, x_msg_data OUT NOCOPY VARCHAR2);

END PJI_TIME_C;

 

/
