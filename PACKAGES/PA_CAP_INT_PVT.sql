--------------------------------------------------------
--  DDL for Package PA_CAP_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CAP_INT_PVT" AUTHID CURRENT_USER AS
-- $Header: PACINTTS.pls 120.1 2005/08/17 12:56:11 ramurthy noship $

 /*
    This package contains the procedures and functions required to process Capitalized
    Interest.  The functions performed are:

        Generation of Capitalized Interest (concurrent request)
        Generation and Auto-Release of Capitalized Interest (concurrent request)
        Release of Capitalized Interest (from form button)
        Purge of Capitalized Interest Source Details (concurrent request)

    When the main procedure, GENERATE_CAP_INTEREST, is called from an Oracle Report, the
    following parameters are used:

        p_from_project_num => Low project to calculate (NULL if no lower bound)
        p_to_project_num   => High project to calculate (NULL if no higher bound)
        p_gl_period        => GL Period for the calculated interest (required)
        p_exp_item_date    => Expenditure Item Date for the calculated interest (required)
        p_source_details   => Y = create source details
        p_autorelease      => Y = auto-release each run batch

    All interest rates setup for the submitter's M/O ORG_ID that exist in schedules associated
    with projects between the parameter project numbers will be processed.  Each rate processed
    will create a single run row.  If any problem are encountered on a project, no transactions
    for that project will be created.  A project can only be successfully processed once per
    month.  Summarized control numbers are reported on the log while the calling report shows
    more detailed results.

    If the release of a Capitalized Interest run is requested from the form, the run_id is
    passed to the GENERATE_CAP_INTEREST procedure through a parameter.

    When the main procedure, PURGE_SOURCE_DETAIL, is called from an Oracle Report, the
    following parameters are used:
        p_gl_period        => GL Period for the source details (required)
        p_from_project_num => Low project to calculate (NULL if no lower bound)
        p_to_project_num   => High project to calculate (NULL if no higher bound)

    The source details from the earliest period through the parameter GL period that belong
    to projects between the parameter project numbers will be purged.  Summarized control
    numbers are reported on the log while the calling report shows more detailed results.

 */
	PROCEDURE generate_cap_interest
		(p_from_project_num IN VARCHAR2 DEFAULT NULL
		,p_to_project_num IN VARCHAR2 DEFAULT NULL
		,p_gl_period IN VARCHAR2
		,p_exp_item_date IN DATE
		,p_source_details IN VARCHAR2 DEFAULT 'N'
		,p_autorelease IN VARCHAR2 DEFAULT 'N'
		,p_mode IN VARCHAR2 DEFAULT 'G'
		,x_run_id IN OUT NOCOPY NUMBER
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2);


	PROCEDURE purge_source_detail
		(p_gl_period IN VARCHAR2
		,p_from_project_num IN VARCHAR2 DEFAULT NULL
		,p_to_project_num IN VARCHAR2 DEFAULT NULL
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2);


	FUNCTION exclude_expenditure_type
		(p_exp_type IN VARCHAR2
		,p_rate_name IN VARCHAR2
		,p_interest_calc_method IN VARCHAR2)
	RETURN VARCHAR2;


	FUNCTION cdl_status
		(p_cutoff_date IN DATE
		,p_expenditure_item_id IN NUMBER
		,p_line_num IN NUMBER)
	RETURN VARCHAR2;


        FUNCTION task_capital_flag
                (p_project_id  IN NUMBER
                 ,p_task_id IN NUMBER
                 ,p_task_bill_flag IN VARCHAR2)
        RETURN VARCHAR2;

	FUNCTION gl_period RETURN VARCHAR2;

	FUNCTION period_end_date RETURN DATE;

	FUNCTION project_id RETURN NUMBER;

	FUNCTION rate_name RETURN VARCHAR2;


END PA_CAP_INT_PVT;

 

/
