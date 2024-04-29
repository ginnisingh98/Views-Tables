--------------------------------------------------------
--  DDL for Package PSP_ARCHIVE_RETRIEVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ARCHIVE_RETRIEVE" AUTHID CURRENT_USER as
/* $Header: PSPARRTS.pls 115.4 2002/11/18 09:29:45 ddubey ship $  */
PROCEDURE archive_distribution( errbuf                 	OUT NOCOPY 	VARCHAR2,
                                retcode                 OUT NOCOPY 	VARCHAR2,
                        	p_payroll_id            IN  	NUMBER,
                         	p_begin_period          IN 	NUMBER,
                         	p_end_period            IN 	NUMBER,
                         	p_business_group_id     IN 	NUMBER,
                        	p_set_of_books_id       IN 	NUMBER);

PROCEDURE retrieve_distribution(errbuf                OUT NOCOPY 	VARCHAR2,
                         	retcode                OUT NOCOPY	VARCHAR2,
                         	p_payroll_id           IN  	NUMBER,
                         	p_begin_period         IN 	NUMBER,
                         	p_end_period           IN 	NUMBER,
                         	p_business_group_id    IN 	NUMBER,
                         	p_set_of_books_id      IN 	NUMBER);

PROCEDURE archive_encumbrance(  errbuf                  OUT NOCOPY 	VARCHAR2,
                         	retcode                 OUT NOCOPY 	VARCHAR2,
                         	p_payroll_id            IN  	NUMBER,
                         	p_begin_period		IN 	NUMBER,
                         	p_end_period		IN 	NUMBER,
                         	p_business_group_id     IN 	NUMBER,
                         	p_set_of_books_id       IN	NUMBER);

PROCEDURE  retrieve_encumbrance(errbuf			OUT NOCOPY 	VARCHAR2,
                        	retcode                 OUT NOCOPY 	VARCHAR2,
                        	p_payroll_id            IN  	NUMBER,
                         	p_begin_period          IN 	NUMBER,
                         	p_end_period            IN 	NUMBER,
                         	p_business_group_id     IN 	NUMBER,
                         	p_set_of_books_id       IN 	NUMBER);

/* Following variable is added for bug 2482603 */
g_error_api_path               VARCHAR2(1000) := '';
END PSP_ARCHIVE_RETRIEVE;

 

/
