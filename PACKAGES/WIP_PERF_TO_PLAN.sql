--------------------------------------------------------
--  DDL for Package WIP_PERF_TO_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_PERF_TO_PLAN" AUTHID CURRENT_USER AS
/* $Header: wipbptps.pls 115.7 2002/11/28 19:22:45 rmahidha ship $ */

PROCEDURE Load_Performance_Info(
	errbuf		 OUT NOCOPY VARCHAR2,
	retcode		 OUT NOCOPY VARCHAR2,
	p_date_from		IN VARCHAR2,
	p_date_to		IN VARCHAR2);

PROCEDURE Populate_Performance(
        p_date_from             IN VARCHAR2,
        p_date_to               IN VARCHAR2,
        p_userid                IN NUMBER,
        p_applicationid         IN NUMBER,
        p_errmesg               OUT NOCOPY VARCHAR2,
        p_errnum                OUT NOCOPY NUMBER);


PROCEDURE Populate_Who(
        p_date_from             IN DATE,
        p_date_to               IN DATE,
        p_userid                IN NUMBER,
        p_applicationid         IN NUMBER,
        p_errmesg               OUT NOCOPY VARCHAR2,
        p_errnum                OUT NOCOPY NUMBER);


PROCEDURE Update_Actual_Quantity(
        p_errmesg               OUT NOCOPY VARCHAR2,
        p_errnum                OUT NOCOPY NUMBER);

PROCEDURE Post_Populate_Perf_Info(
        p_errnum                OUT NOCOPY NUMBER,
        p_errmesg               OUT NOCOPY VARCHAR2);

PROCEDURE Clean_Up_Exception;


END WIP_PERF_TO_PLAN;

 

/
