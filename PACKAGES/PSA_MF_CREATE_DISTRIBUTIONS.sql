--------------------------------------------------------
--  DDL for Package PSA_MF_CREATE_DISTRIBUTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MF_CREATE_DISTRIBUTIONS" AUTHID CURRENT_USER AS
/* $Header: PSAMFCRS.pls 120.7 2006/09/13 12:28:48 agovil ship $ */

  FUNCTION  create_distributions(
                                 errbuf            OUT NOCOPY VARCHAR2,
                                 retcode           OUT NOCOPY VARCHAR2,
                                 p_mode             IN        VARCHAR2,
                                 p_document_id      IN        NUMBER    DEFAULT NULL,
                                 p_set_of_books_id  IN        NUMBER,
                                 run_num           OUT NOCOPY NUMBER,
                                 p_error_message   OUT NOCOPY VARCHAR2,
                                 p_report_only      IN        VARCHAR2 DEFAULT 'N') RETURN BOOLEAN;

  PROCEDURE submit_create_distributions(
                                        errbuf            OUT NOCOPY VARCHAR2,
                                        retcode           OUT NOCOPY VARCHAR2,
                                        p_mode             IN        VARCHAR2 DEFAULT 'A',
                                        p_document_id      IN        NUMBER   DEFAULT NULL,
                                        p_set_of_books_id  IN        NUMBER,
                                        p_report_only      IN        VARCHAR2 DEFAULT 'N');


  FUNCTION  create_distributions_rpt(
                                 errbuf            OUT NOCOPY VARCHAR2,
                                 retcode           OUT NOCOPY VARCHAR2,
                                 p_mode             IN        VARCHAR2,
                                 p_document_id      IN        NUMBER    DEFAULT NULL,
                                 p_set_of_books_id  IN        NUMBER,
                                 run_num           OUT NOCOPY NUMBER,
                                 p_error_message   OUT NOCOPY VARCHAR2,
                                 p_report_only      IN        VARCHAR2 DEFAULT 'N',
				 p_gl_date_from     IN        DATE,
				 p_gl_date_to       IN        DATE ) RETURN BOOLEAN;

END psa_mf_create_distributions;

 

/
