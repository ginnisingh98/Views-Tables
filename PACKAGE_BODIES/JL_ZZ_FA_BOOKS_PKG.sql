--------------------------------------------------------
--  DDL for Package Body JL_ZZ_FA_BOOKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_FA_BOOKS_PKG" AS
/* $Header: jlzzffbb.pls 120.7 2006/03/06 22:34:38 svaze ship $ */


PROCEDURE get_dist_book IS
BEGIN
  SELECT distribution_source_book
    INTO jl_zz_fa_books_pkg.v_dist_book
    FROM fa_book_controls
    WHERE book_type_code = jl_zz_fa_books_pkg.v_book_type_code;
EXCEPTION
  WHEN NO_DATA_FOUND THEN NULL;
END get_dist_book;

FUNCTION update_insert RETURN BOOLEAN IS
BEGIN

        SELECT global_attribute1,
              global_attribute2,
              global_attribute3,
              global_attribute4,
              global_attribute5,
              global_attribute6,
              global_attribute7,
              global_attribute8,
              global_attribute9,
              global_attribute10,
              global_attribute11,
              global_attribute12,
              global_attribute13,
              global_attribute14,
              global_attribute15,
              global_attribute16,
              global_attribute17,
              global_attribute18,
              global_attribute19,
              global_attribute20,
              global_attribute_category
         INTO jl_zz_fa_books_pkg.v_global_attribute1,
             jl_zz_fa_books_pkg.v_global_attribute2,
             jl_zz_fa_books_pkg.v_global_attribute3,
             jl_zz_fa_books_pkg.v_global_attribute4,
             jl_zz_fa_books_pkg.v_global_attribute5,
             jl_zz_fa_books_pkg.v_global_attribute6,
             jl_zz_fa_books_pkg.v_global_attribute7,
             jl_zz_fa_books_pkg.v_global_attribute8,
             jl_zz_fa_books_pkg.v_global_attribute9,
             jl_zz_fa_books_pkg.v_global_attribute10,
             jl_zz_fa_books_pkg.v_global_attribute11,
             jl_zz_fa_books_pkg.v_global_attribute12,
             jl_zz_fa_books_pkg.v_global_attribute13,
             jl_zz_fa_books_pkg.v_global_attribute14,
             jl_zz_fa_books_pkg.v_global_attribute15,
             jl_zz_fa_books_pkg.v_global_attribute16,
             jl_zz_fa_books_pkg.v_global_attribute17,
             jl_zz_fa_books_pkg.v_global_attribute18,
             jl_zz_fa_books_pkg.v_global_attribute19,
             jl_zz_fa_books_pkg.v_global_attribute20,
             jl_zz_fa_books_pkg.v_global_attribute_category
         FROM fa_books
         WHERE asset_id = jl_zz_fa_books_pkg.v_asset_id
           AND book_type_code = jl_zz_fa_books_pkg.v_book_type_code
           AND transaction_header_id_out = jl_zz_fa_books_pkg.v_transaction_header_id_in ;

   RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
END update_insert;

FUNCTION insert_update RETURN BOOLEAN IS
BEGIN

        SELECT global_attribute1,
              global_attribute2,
              global_attribute3,
              global_attribute4,
              global_attribute5,
              global_attribute6,
              global_attribute7,
              global_attribute8,
              global_attribute9,
              global_attribute10,
              global_attribute11,
              global_attribute12,
              global_attribute13,
              global_attribute14,
              global_attribute15,
              global_attribute16,
              global_attribute17,
              global_attribute18,
              global_attribute19,
              global_attribute20,
              global_attribute_category
         INTO jl_zz_fa_books_pkg.v_global_attribute1,
             jl_zz_fa_books_pkg.v_global_attribute2,
             jl_zz_fa_books_pkg.v_global_attribute3,
             jl_zz_fa_books_pkg.v_global_attribute4,
             jl_zz_fa_books_pkg.v_global_attribute5,
             jl_zz_fa_books_pkg.v_global_attribute6,
             jl_zz_fa_books_pkg.v_global_attribute7,
             jl_zz_fa_books_pkg.v_global_attribute8,
             jl_zz_fa_books_pkg.v_global_attribute9,
             jl_zz_fa_books_pkg.v_global_attribute10,
             jl_zz_fa_books_pkg.v_global_attribute11,
             jl_zz_fa_books_pkg.v_global_attribute12,
             jl_zz_fa_books_pkg.v_global_attribute13,
             jl_zz_fa_books_pkg.v_global_attribute14,
             jl_zz_fa_books_pkg.v_global_attribute15,
             jl_zz_fa_books_pkg.v_global_attribute16,
             jl_zz_fa_books_pkg.v_global_attribute17,
             jl_zz_fa_books_pkg.v_global_attribute18,
             jl_zz_fa_books_pkg.v_global_attribute19,
             jl_zz_fa_books_pkg.v_global_attribute20,
             jl_zz_fa_books_pkg.v_global_attribute_category
         FROM fa_books
         WHERE asset_id = jl_zz_fa_books_pkg.v_asset_id
           AND book_type_code = jl_zz_fa_books_pkg.v_book_type_code
           AND date_ineffective IS NULL
           AND transaction_header_id_in <> jl_zz_fa_books_pkg.v_transaction_header_id_in ;

  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
END insert_update;

PROCEDURE update_row IS
   l_country_code VARCHAR2(10);
BEGIN

   --BUG 2876793. Quick Additions does not populate Global Attribute Category.
   --             This code prevents fa_books.global_attribute_category to
   --             be null, if the country is AR,CL,CO,MX and the
   --             fa_books.global_attribute1 has a value.

   IF jl_zz_fa_books_pkg.v_global_attribute_category is NULL THEN
     --FND_PROFILE.GET('JGZZ_COUNTRY_CODE',l_country_code);
     -------------------------------------------------------------------------
     -- BUG 4650081. Profile for country is replaced by call to JG Shared pkg.
     -------------------------------------------------------------------------
     l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY;

     IF l_country_code in ('AR','CL','CO','MX') THEN
       --BUG 4618564. Due standards we cannot an schema harcoded, but in this case JL is not part
       --             of and schema and really is a false positive. However we will decompose the string
       --             to avoid conflicts with the standards.
       jl_zz_fa_books_pkg.v_global_attribute_category := 'J'||'L'||'.'||l_country_code||'.FAXASSET.FA_BOOKS';

       IF jl_zz_fa_books_pkg.v_global_attribute1 is NULL THEN
         jl_zz_fa_books_pkg.v_global_attribute1 := 'N';
       END IF;
     END IF;

   END IF;

   UPDATE fa_books
     SET  global_attribute1 = decode(global_attribute1,null,
            jl_zz_fa_books_pkg.v_global_attribute1,global_attribute1),
        global_attribute2 = decode(global_attribute2,null,
            jl_zz_fa_books_pkg.v_global_attribute2,global_attribute2),
        global_attribute3 = decode(global_attribute3,null,
            jl_zz_fa_books_pkg.v_global_attribute3,global_attribute3),
        global_attribute4 = decode(global_attribute4,null,
            jl_zz_fa_books_pkg.v_global_attribute4,global_attribute4),
        global_attribute5 = decode(global_attribute5,null,
            jl_zz_fa_books_pkg.v_global_attribute5,global_attribute5),
        global_attribute6 = decode(global_attribute6,null,
            jl_zz_fa_books_pkg.v_global_attribute6,global_attribute6),
        global_attribute7 = decode(global_attribute7,null,
            jl_zz_fa_books_pkg.v_global_attribute7,global_attribute7),
        global_attribute8 = decode(global_attribute8,null,
            jl_zz_fa_books_pkg.v_global_attribute8,global_attribute8),
        global_attribute9 = decode(global_attribute9,null,
            jl_zz_fa_books_pkg.v_global_attribute9,global_attribute9),
        global_attribute10 = decode(global_attribute10,null,
            jl_zz_fa_books_pkg.v_global_attribute10,global_attribute10),
        global_attribute11 = decode(global_attribute11,null,
            jl_zz_fa_books_pkg.v_global_attribute11,global_attribute11),
        global_attribute12 = decode(global_attribute12,null,
            jl_zz_fa_books_pkg.v_global_attribute12,global_attribute12),
        global_attribute13 = decode(global_attribute13,null,
            jl_zz_fa_books_pkg.v_global_attribute13,global_attribute13),
        global_attribute14 = decode(global_attribute14,null,
            jl_zz_fa_books_pkg.v_global_attribute14,global_attribute14),
        global_attribute15 = decode(global_attribute15,null,
            jl_zz_fa_books_pkg.v_global_attribute15,global_attribute15),
        global_attribute16 = decode(global_attribute16,null,
            jl_zz_fa_books_pkg.v_global_attribute16,global_attribute16),
        global_attribute17 = decode(global_attribute17,null,
            jl_zz_fa_books_pkg.v_global_attribute17,global_attribute17),
        global_attribute18 = decode(global_attribute18,null,
            jl_zz_fa_books_pkg.v_global_attribute18,global_attribute18),
        global_attribute19 = decode(global_attribute19,null,
            jl_zz_fa_books_pkg.v_global_attribute19,global_attribute19),
        global_attribute20 = decode(global_attribute20,null,
            jl_zz_fa_books_pkg.v_global_attribute20,global_attribute20),
        global_attribute_category =decode(global_attribute_category,null,
            jl_zz_fa_books_pkg.v_global_attribute_category,global_attribute_category)
         WHERE asset_id = jl_zz_fa_books_pkg.v_asset_id
           AND book_type_code = jl_zz_fa_books_pkg.v_book_type_code
           AND transaction_header_id_in = jl_zz_fa_books_pkg.v_transaction_header_id_in ;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
END update_row;

PROCEDURE get_flag_category IS
BEGIN
        SELECT a.global_attribute1
         INTO jl_zz_fa_books_pkg.v_global_attribute1
         FROM fa_category_books a, fa_additions b
         WHERE b.asset_id = jl_zz_fa_books_pkg.v_asset_id
           AND a.book_type_code = jl_zz_fa_books_pkg.v_book_type_code
           AND a.category_id = b.asset_category_id;
EXCEPTION
 WHEN NO_DATA_FOUND THEN NULL;
END get_flag_category;

PROCEDURE get_ga_dist_book IS

BEGIN
        SELECT
              global_attribute2,
              global_attribute3,
              global_attribute4,
              global_attribute5,
              global_attribute6,
              global_attribute7,
              global_attribute8,
              global_attribute9,
              global_attribute10,
              global_attribute11,
              global_attribute12,
              global_attribute13,
              global_attribute14,
              global_attribute15,
              global_attribute16,
              global_attribute17,
              global_attribute18,
              global_attribute19,
              global_attribute20,
              global_attribute_category
         INTO
             jl_zz_fa_books_pkg.v_global_attribute2,
             jl_zz_fa_books_pkg.v_global_attribute3,
             jl_zz_fa_books_pkg.v_global_attribute4,
             jl_zz_fa_books_pkg.v_global_attribute5,
             jl_zz_fa_books_pkg.v_global_attribute6,
             jl_zz_fa_books_pkg.v_global_attribute7,
             jl_zz_fa_books_pkg.v_global_attribute8,
             jl_zz_fa_books_pkg.v_global_attribute9,
             jl_zz_fa_books_pkg.v_global_attribute10,
             jl_zz_fa_books_pkg.v_global_attribute11,
             jl_zz_fa_books_pkg.v_global_attribute12,
             jl_zz_fa_books_pkg.v_global_attribute13,
             jl_zz_fa_books_pkg.v_global_attribute14,
             jl_zz_fa_books_pkg.v_global_attribute15,
             jl_zz_fa_books_pkg.v_global_attribute16,
             jl_zz_fa_books_pkg.v_global_attribute17,
             jl_zz_fa_books_pkg.v_global_attribute18,
             jl_zz_fa_books_pkg.v_global_attribute19,
             jl_zz_fa_books_pkg.v_global_attribute20,
             jl_zz_fa_books_pkg.v_global_attribute_category
         FROM fa_books
         WHERE asset_id = jl_zz_fa_books_pkg.v_asset_id
           AND book_type_code = jl_zz_fa_books_pkg.v_dist_book
           AND date_ineffective IS NULL
           AND transaction_header_id_in <> jl_zz_fa_books_pkg.v_transaction_header_id_in ;

EXCEPTION
  WHEN NO_DATA_FOUND THEN NULL;
END get_ga_dist_book;

END jl_zz_fa_books_pkg;

/
