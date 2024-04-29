--------------------------------------------------------
--  DDL for Package JL_ZZ_FA_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_FA_LIBRARY_1_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzfl1s.pls 115.1 99/07/16 03:13:47 porting ship  $ */


PROCEDURE get_period_name (book_typ_code IN     VARCHAR2,
                           prd_name      IN OUT VARCHAR2,
                           row_number    IN     NUMBER,
                           Errcd         IN OUT NUMBER);

PROCEDURE get_check_inflation_adjustment(book_type  IN     VARCHAR2,
                                         book_ctrl  IN OUT VARCHAR2,
                                         row_number IN     NUMBER,
                                         Errcd      IN OUT NUMBER);

PROCEDURE get_fa_books (asset_id        IN     NUMBER,
                        attr_category   IN     VARCHAR2,
                        book_type       IN     VARCHAR2,
                        current_reval   IN OUT VARCHAR2,
                        previous_reval  IN OUT VARCHAR2,
                        last_appr_no    IN OUT VARCHAR2,
                        last_appr_date  IN OUT VARCHAR2,
                        last_appr_value IN OUT VARCHAR2,
                        row_number      IN     NUMBER,
                        Errcd           IN OUT NUMBER);


END JL_ZZ_FA_LIBRARY_1_PKG;

 

/
