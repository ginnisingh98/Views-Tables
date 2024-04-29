--------------------------------------------------------
--  DDL for Package FA_IMPAIRMENT_DELETE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_IMPAIRMENT_DELETE_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVIMPDS.pls 120.4.12010000.1 2009/07/21 12:37:31 glchen noship $ */

 TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
FUNCTION delete_post(
              p_request_id        IN NUMBER,
              p_book_type_code    IN VARCHAR2,
              p_period_rec        IN FA_API_TYPES.period_rec_type,
              p_worker_id         IN NUMBER,
              p_mrc_sob_type_code IN VARCHAR2,
              p_set_of_books_id    IN NUMBER,
              p_calling_fn        IN VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION process_impair_event(
              p_book_type_code    IN VARCHAR2,
              p_mrc_sob_type_code IN VARCHAR2,
              p_set_of_books_id   IN NUMBER,
              p_calling_fn        IN VARCHAR2 ,
              p_thid              IN tab_num15_type,
              p_log_level_rec     IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION rollback_deprn_event(
              p_book_type_code    IN VARCHAR2,
              p_asset_id          IN NUMBER,
              p_mrc_sob_type_code IN VARCHAR2,
              p_set_of_books_id   IN NUMBER,
              p_log_level_rec     IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION rollback_impair_event(
              p_request_id        IN NUMBER,
              p_book_type_code    IN VARCHAR2,
              p_asset_id          IN NUMBER,
              p_thid              IN NUMBER,
              p_mrc_sob_type_code IN VARCHAR2,
              p_set_of_books_id   IN NUMBER,
              p_log_level_rec     IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_IMPAIRMENT_DELETE_PVT;

/
