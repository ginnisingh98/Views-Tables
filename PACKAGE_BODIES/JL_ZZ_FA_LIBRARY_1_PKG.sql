--------------------------------------------------------
--  DDL for Package Body JL_ZZ_FA_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_FA_LIBRARY_1_PKG" AS
/* $Header: jlzzfl1b.pls 115.4 1999/11/01 17:06:06 pkm ship   $ */


  PROCEDURE get_period_name (book_typ_code IN     VARCHAR2,
                             prd_name      IN OUT VARCHAR2,
                             row_number    IN     NUMBER,
                             Errcd         IN OUT NUMBER) IS
  BEGIN
    Errcd := 0;

     BEGIN
       SELECT period_name
       INTO   prd_name
       FROM   fa_mass_revaluations mr ,
              fa_book_controls bc,
              fa_deprn_periods dp
       WHERE  dp.book_type_code = book_typ_code
         AND  dp.period_close_date IS NULL
         AND  bc.book_type_code = dp.book_type_code
         AND  bc.global_attribute2 = dp.period_counter
         AND  bc.global_attribute1 = 'Y'
         AND  bc.global_attribute3 = mr.mass_reval_id
--         AND  mr.book_type_code = bc.book_type_code -- To fix bug 979165, added above line instead
--         AND  mr.global_attribute1 = dp.period_counter -- To fix bug 1013530
         AND  mr.status = 'COMPLETED'
         AND  rownum = row_number;
     EXCEPTION
       WHEN OTHERS THEN
       Errcd := SQLCODE;
     END;


  END get_period_name;


  PROCEDURE get_check_inflation_adjustment(book_type  IN     VARCHAR2,
                                           book_ctrl  IN OUT VARCHAR2,
                                           row_number IN     NUMBER,
                                           Errcd      IN OUT NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT global_attribute1
    INTO   book_ctrl
    FROM   fa_book_controls
    WHERE  book_type_code = book_type
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_check_inflation_adjustment;

  PROCEDURE get_fa_books (asset_id        IN     NUMBER,
                          attr_category   IN     VARCHAR2,
                          book_type       IN     VARCHAR2,
                          current_reval   IN OUT VARCHAR2,
                          previous_reval  IN OUT VARCHAR2,
                          last_appr_no    IN OUT VARCHAR2,
                          last_appr_date  IN OUT VARCHAR2,
                          last_appr_value IN OUT VARCHAR2,
                          row_number      IN     NUMBER,
                          Errcd           IN OUT NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT SUBSTR (global_attribute2, 1, 15),
           SUBSTR (global_attribute3, 1, 15),
           SUBSTR (global_attribute4, 1, 15),
           SUBSTR (global_attribute5, 1, 25),
           SUBSTR (global_attribute6, 1, 15)
    INTO   current_reval,
           previous_reval,
           last_appr_no,
           last_appr_date,
           last_appr_value
    FROM   fa_books
    WHERE  asset_id = TO_CHAR (asset_id)
    AND    date_ineffective IS NULL
    AND    global_attribute_category = attr_category
    AND    book_type_code = book_type
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_fa_books;


END JL_ZZ_FA_LIBRARY_1_PKG;

/
