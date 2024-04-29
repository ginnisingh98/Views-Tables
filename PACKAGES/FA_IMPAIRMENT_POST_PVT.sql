--------------------------------------------------------
--  DDL for Package FA_IMPAIRMENT_POST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_IMPAIRMENT_POST_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVIMPTS.pls 120.3.12010000.1 2009/07/21 12:37:35 glchen noship $ */


FUNCTION process_post(
              p_request_id        IN NUMBER,
              p_book_type_code    IN VARCHAR2,
              p_period_rec        IN FA_API_TYPES.period_rec_type,
              p_worker_id         IN NUMBER,
              p_mrc_sob_type_code IN VARCHAR2,
              p_set_of_books_id   IN NUMBER,
              p_calling_fn        IN VARCHAR2
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null) RETURN BOOLEAN;


END FA_IMPAIRMENT_POST_PVT;

/
