--------------------------------------------------------
--  DDL for Package OZF_SCHEDULE_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SCHEDULE_DENORM_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvscds.pls 115.3 2004/01/23 21:37:05 gramanat noship $ */

TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE char_tbl_type IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;


PROCEDURE initial_load(l_org_id IN NUMBER);

PROCEDURE refresh_schedules(
  ERRBUF           OUT NOCOPY VARCHAR2,
  RETCODE          OUT NOCOPY VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  p_increment_flag IN  VARCHAR2 := 'N',
  p_latest_comp_date IN DATE
);

END OZF_SCHEDULE_DENORM_PVT;

 

/
