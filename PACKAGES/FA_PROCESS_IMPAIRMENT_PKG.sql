--------------------------------------------------------
--  DDL for Package FA_PROCESS_IMPAIRMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_PROCESS_IMPAIRMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: FAPIMPS.pls 120.2.12010000.1 2009/07/21 12:37:28 glchen noship $ */


PROCEDURE process_impairments(
                errbuf                  OUT NOCOPY VARCHAR2,
                retcode                 OUT NOCOPY NUMBER,
                p_book_type_code        IN         VARCHAR2,
                p_mode                  IN         VARCHAR2,
                p_impairment_id         IN         NUMBER DEFAULT NULL,
                p_parent_request_id     IN         NUMBER DEFAULT NULL,
                p_total_requests        IN         NUMBER DEFAULT NULL,
                p_request_number        IN         NUMBER DEFAULT NULL,
                p_set_of_books_id       IN         NUMBER DEFAULT NULL,
                p_mrc_sob_type_code     IN         VARCHAR2 DEFAULT NULL);

END FA_PROCESS_IMPAIRMENT_PKG;

/
