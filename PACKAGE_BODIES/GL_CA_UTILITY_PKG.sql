--------------------------------------------------------
--  DDL for Package Body GL_CA_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CA_UTILITY_PKG" AS
/* $Header: glcautb.pls 120.1 2003/03/11 03:44:55 lpoon noship $ */

-- Procedure
--   get_sob_type
--   *Should call gl_mc_info.get_alc_ledger_type() instead and this is for
--    backward
-- Purpose
--   Gets the type of set of books
-- History
--   25-FEB-03       LPOON                 R11i.X changes
PROCEDURE get_sob_type ( p_sob_id   IN  NUMBER,
                         p_sob_type OUT NOCOPY VARCHAR2) IS
  n_alc_ledger_type VARCHAR2(30);
BEGIN

  gl_mc_info.get_alc_ledger_type(p_sob_id, n_alc_ledger_type);

  IF n_alc_ledger_type = 'SOURCE'
  THEN
    p_sob_type := 'P';
  ELSIF n_alc_ledger_type = 'TARGET'
  THEN
    p_sob_type := 'R';
  ELSIF n_alc_ledger_type = 'NONE'
  THEN
    p_sob_type := 'N';
  ELSE
    p_sob_type := NULL;
  END IF;
END;

-- Procedure
--   mrc_enabled
--   *May use gl_mc_info.alc_enabled() but it is a procedure rather than
--    a function returning BOOLEAN
-- Purpose
--   Determines whether MRC is enabled
FUNCTION mrc_enabled ( p_sob_id         IN  NUMBER,
                       p_appl_id        IN  NUMBER,
                       p_org_id         IN  NUMBER,
                       p_fa_book_code   IN  VARCHAR2) RETURN BOOLEAN IS
BEGIN
   RETURN gl_mc_info.alc_enabled(p_sob_id, p_appl_id, p_org_id, p_fa_book_code);
END;

-- Procedure
--   get_associated_sobs
-- Purpose
--   Gets the Primary and Reporting set of books info
-- History
--
PROCEDURE get_associated_sobs ( p_sob_id         IN     NUMBER,
                                p_appl_id        IN     NUMBER,
                                p_org_id         IN     NUMBER,
                                p_fa_book_code   IN     VARCHAR2,
                                p_sob_list       IN OUT NOCOPY r_sob_list) IS
 n_sob_list gl_mc_info.r_sob_list := gl_mc_info.r_sob_list();
BEGIN
  -- This procedure used to exclude primary SOB, so we put 'N' to exclude
  -- ALC source ledger
  gl_mc_info.get_alc_associated_ledgers(  p_sob_id
                                        , p_appl_id
                                        , p_org_id
                                        , p_fa_book_code
                                        , 'N'
                                        , n_sob_list);

  p_sob_list.extend(n_sob_list.count);

  -- Copy the SOB ID, name, and currency from n_sob_list to p_sob_list
  FOR i IN 1..n_sob_list.count LOOP
    SELECT n_sob_list(i).r_sob_id,
           n_sob_list(i).r_sob_name,
           n_sob_list(i).r_sob_curr
    INTO p_sob_list(i).r_sob_id,
         p_sob_list(i).r_sob_name,
         p_sob_list(i).r_sob_curr
    FROM dual;
  END LOOP;

END;

-- Procedure
--   get_rate
-- Purpose
--   Gets the reporting SOBs rate info for a particular transaction
-- History
--
PROCEDURE get_rate( p_primary_set_of_books_id  IN NUMBER,
                    p_trans_date               IN DATE,
                    p_trans_currency_code      IN VARCHAR2,
                    p_application_id           IN NUMBER,
                    p_org_id                   IN NUMBER,
                    p_exchange_rate_date       IN DATE,
                    p_exchange_rate	           IN NUMBER,
                    p_exchange_rate_type       IN VARCHAR2,
                    p_fa_book_type_code        IN VARCHAR2 DEFAULT NULL,
                    p_je_source_name           IN VARCHAR2 DEFAULT NULL,
                    p_je_category_name         IN VARCHAR2 DEFAULT NULL,
                    p_sob_list                 IN OUT NOCOPY r_sob_list ) IS
  l_counter          NUMBER := 1;
  l_conversion_type  VARCHAR2(30);
  l_conversion_date DATE;
  l_conversion_rate  NUMBER;
  l_result_code      VARCHAR2(25);
  l_numerator_rate   NUMBER;
  l_denominator_rate NUMBER;
  l_rep_curr         VARCHAR2(15);

BEGIN
  WHILE (l_counter <= p_sob_list.count) LOOP

    -- Initialize the passed parameters before calling API
    l_conversion_date  := p_exchange_rate_date;
    l_conversion_type  := p_exchange_rate_type;
    l_conversion_rate  := p_exchange_rate;
    l_result_code      := NULL;
    l_numerator_rate   := NULL;
    l_denominator_rate := NULL;

    gl_mc_info.get_ledger_currency(p_sob_list(l_counter).r_sob_id, l_rep_curr);

    IF (l_rep_curr = p_trans_currency_code) THEN
      -- Reporting Currency same as transaction currency so put all
      -- conversion info to NULL and set correct result code
      l_conversion_date := NULL;
      l_conversion_type := NULL;
      l_conversion_rate := NULL;
      l_result_code     := 'HEADER VALID ';
    ELSE
      -- Call API to get the rate for this reporting SOB whose currency is
      -- different with transaction currency
      GL_MC_CURRENCY_PKG.get_rate(
                        p_primary_set_of_books_id,
                        p_sob_list(l_counter).r_sob_id,
                        p_trans_date,
                        p_trans_currency_code,
                        l_conversion_type,
                        l_conversion_date,
                        l_conversion_rate,
                        p_application_id,
                        p_org_id,
                        p_fa_book_type_code,
                        p_je_source_name,
                        p_je_category_name,
                        l_result_code,
                        l_numerator_rate,
                        l_denominator_rate);
    END IF;

    -- Store the returned values back to p_sob_list
    SELECT l_conversion_date,
           l_conversion_type,
           l_conversion_rate,
           l_numerator_rate,
           l_denominator_rate,
           l_result_code
      INTO p_sob_list(l_counter).conversion_date,
           p_sob_list(l_counter).conversion_type,
           p_sob_list(l_counter).conversion_rate,
           p_sob_list(l_counter).numerator_rate,
           p_sob_list(l_counter).denominator_rate,
           p_sob_list(l_counter).result_code
      FROM DUAL;

    l_counter := l_counter + 1;
  END LOOP;
END get_rate;

END gl_ca_utility_pkg;

/
