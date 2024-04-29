--------------------------------------------------------
--  DDL for Package Body GL_MC_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_MC_CURRENCY_PKG" AS
/* $Header: glmccurb.pls 120.15 2006/03/29 19:52:50 mgowda ship $ */


    TYPE CurrencyCodeType  IS TABLE OF VARCHAR2(15)  INDEX BY BINARY_INTEGER;
    TYPE PrecisionType     IS TABLE OF NUMBER(1)     INDEX BY BINARY_INTEGER;
    TYPE MauType           IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
    NextElement            BINARY_INTEGER := 0;
    CurrencyCode           CurrencyCodeType;
    Precision              PrecisionType;
    Mau                    MauType;

    G_PKG_NAME            CONSTANT   VARCHAR2(30)  :='GL_MC_CURRENCY_PKG';
    G_DEBUG_LEVEL         CONSTANT    NUMBER        :=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    G_STATEMENT_LEVEL     CONSTANT    NUMBER        :=FND_LOG.LEVEL_STATEMENT;
    G_PROC_LEVEL          CONSTANT    NUMBER        :=FND_LOG.LEVEL_PROCEDURE;
    G_EVENT_LEVEL         CONSTANT    NUMBER        :=FND_LOG.LEVEL_EVENT;
    G_EXCEPTION_LEVEL     CONSTANT    NUMBER        :=FND_LOG.LEVEL_EXCEPTION;
    G_ERROR_LEVEL         CONSTANT    NUMBER        :=FND_LOG.LEVEL_ERROR;
    G_UNEXPECTED_LEVEL    CONSTANT    NUMBER        :=FND_LOG.LEVEL_UNEXPECTED;
    G_DEBUG_PKG_HDR       CONSTANT   VARCHAR2(100) := 'gl.sql.GLMCCURB.';
--
--  R11i.X Changes - Call gl_mc_info instead (merged the code)
--
    FUNCTION get_currency_code (p_set_of_books_id NUMBER) RETURN VARCHAR2 IS
	l_currency_code		VARCHAR2(15);
    BEGIN
        gl_mc_info.get_ledger_currency(p_set_of_books_id, l_currency_code);

        RETURN(l_currency_code);
    END get_currency_code;
--
--  R11i.X Changes - Call gl_mc_info instead (merged the code)
--
    FUNCTION get_mrc_sob_type_code (p_set_of_books_id NUMBER) RETURN VARCHAR2 IS
	l_mrc_sob_type_code		VARCHAR2(1);
    BEGIN
        gl_mc_info.get_sob_type(p_set_of_books_id, l_mrc_sob_type_code);

        RETURN(l_mrc_sob_type_code);
    END get_mrc_sob_type_code;
--
--  R11i.X Changes - modified to refer to the new data model
--
    PROCEDURE  get_rate(p_primary_set_of_books_id   IN NUMBER,
                        p_reporting_set_of_books_id IN NUMBER,
                        p_trans_date                IN DATE,
                        p_trans_currency_code       IN VARCHAR2,
                        p_trans_conversion_type     IN OUT NOCOPY VARCHAR2,
                        p_trans_conversion_date     IN OUT NOCOPY DATE,
                        p_trans_conversion_rate     IN OUT NOCOPY NUMBER,
                        p_application_id            IN NUMBER,
                        p_org_id                    IN NUMBER,
                        p_fa_book_type_code         IN VARCHAR2,
                        p_je_source_name            IN VARCHAR2,
                        p_je_category_name          IN VARCHAR2,
                        p_result_code               IN OUT NOCOPY VARCHAR2,
                        p_denominator_rate          OUT NOCOPY NUMBER,
                        p_numerator_rate            OUT NOCOPY NUMBER ) IS
        l_je_conv_set_id       NUMBER;
        l_target_curr          VARCHAR2(15);
        l_src_curr             VARCHAR2(15);
        l_conversion_type      VARCHAR2(30);
        l_user_conversion_type VARCHAR2(30);
        l_no_rate_action       VARCHAR2(30);
        l_inherit_ctype_Flag   VARCHAR2(1);
        l_conversion_flag      VARCHAR2(1);

        l_tmp_conversion_type       VARCHAR2(30);
        l_inherited_conversion_type VARCHAR2(30);

        l_fixed_rate          BOOLEAN;
        l_relationship        VARCHAR2(15);
        l_xrate               BOOLEAN := FALSE;
        l_trans_currency_code VARCHAR2(15) := NULL;
        l_rate                NUMBER := NULL;
        l_mrc_max_roll_rate   NUMBER := -1;
        l_debug_proc_hdr         VARCHAR2(100);

    BEGIN
      l_debug_proc_hdr   := G_DEBUG_PKG_HDR || 'Get_Rate.';

      IF (G_PROC_LEVEL >= G_DEBUG_LEVEL )
      THEN
        FND_LOG.STRING(G_PROC_LEVEL, l_debug_proc_hdr||'.BEGIN'
                        , 'Entering Get_rate' );
      END IF;

      -- Bug fix 3975695: Moved the codes to assign default values from
	  --                  declaration to here
      l_inherit_ctype_Flag        := 'N';
      l_conversion_flag           := 'Y';
      l_inherited_conversion_type := p_trans_conversion_type;
      p_result_code               := 'HEADER VALID ';

      BEGIN

        IF (G_PROC_LEVEL >= G_STATEMENT_LEVEL )
        THEN
          FND_LOG.STRING(G_PROC_LEVEL, l_debug_proc_hdr||'.BEGIN'
                    , 'retrieving setup data from GL ledger relationships' );
        END IF;
        -- Retrieve setup from GL ledger relationships
        SELECT   glr.gl_je_conversion_set_id
               , glr.target_currency_code
               , glr.alc_default_conv_rate_type
               , glr.alc_no_rate_action_code
               , glr.alc_inherit_conversion_type
               , DECODE(glr.alc_no_rate_action_code,'REPORT_ERROR',0,nvl(glr.alc_max_days_roll_rate,-1))
          INTO   l_je_conv_set_id
               , l_target_curr
               , l_conversion_type
               , l_no_rate_action
               , l_inherit_ctype_flag
               , l_mrc_max_roll_rate
          FROM gl_ledger_relationships glr
         WHERE glr.source_ledger_id = p_primary_set_of_books_id
           AND glr.target_ledger_id = p_reporting_set_of_books_id
           AND glr.relationship_type_code IN ('JOURNAL', 'SUBLEDGER')
           AND glr.target_ledger_category_code = 'ALC'
           AND glr.application_id = p_application_id
           AND glr.relationship_enabled_flag = 'Y'
           AND (p_org_id IS NULL
                OR glr.org_id = -99
                OR glr.org_id = NVL(p_org_id, -99))
           AND (NVL(p_fa_book_type_code, '-99') = '-99'
                OR EXISTS
                   (SELECT 'FA book type is enabled'
                    FROM FA_MC_BOOK_CONTROLS MC
                    WHERE MC.set_of_books_id = glr.target_ledger_id
                    AND MC.book_type_code = p_fa_book_type_code
                    AND MC.primary_set_of_books_id = glr.source_ledger_id
                    AND MC.enabled_flag = 'Y'))
           AND rownum = 1;

        -- Get the source ledger currency
        gl_mc_info.get_ledger_currency(p_primary_set_of_books_id, l_src_curr);
      EXCEPTION
        WHEN OTHERS THEN
            p_result_code := 'RSOB NOT FOUND';
            l_conversion_flag := 'E';
      END;

      IF p_application_id = 101 AND l_conversion_flag = 'Y' -- GL
      THEN
        -- CHeck if it is converted for the passed journal source and category
        -- based on the conversion set rules defined
        BEGIN
          SELECT include_flag
          INTO   l_conversion_flag
          FROM   gl_je_inclusion_rules
          WHERE  je_rule_set_id = l_je_conv_set_id
          AND    je_source_name = p_je_source_name
          AND    je_category_name = p_je_category_name;
        EXCEPTION
          WHEN OTHERS THEN
            BEGIN
             SELECT include_flag
             INTO   l_conversion_flag
             FROM   gl_je_inclusion_rules
             WHERE  je_rule_set_id = l_je_conv_set_id
             AND    je_source_name = p_je_source_name
             AND    je_category_name = 'Other';
            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  SELECT include_flag
                  INTO   l_conversion_flag
                  FROM   gl_je_inclusion_rules
                  WHERE  je_rule_set_id = l_je_conv_set_id
                  AND    je_source_name = 'Other'
                  AND    je_category_name = p_je_category_name;
                EXCEPTION
                  WHEN OTHERS THEN
                    BEGIN
                      SELECT include_flag
                      INTO   l_conversion_flag
                      FROM   gl_je_inclusion_rules
                      WHERE  je_rule_set_id = l_je_conv_set_id
                      AND    je_source_name = 'Other'
                      AND    je_category_name = 'Other';
                    EXCEPTION
                      WHEN OTHERS THEN
                          l_conversion_flag := 'N';
                          p_result_code := 'NO CONVERSION';
                    END;
                END;
            END;
        END;
      END IF;  -- IF p_application_id = 101 AND l_conversion_flag = 'Y'

      l_tmp_conversion_type := l_conversion_type;

      -- The inherit option is ignored if the conversion type in the original
      -- transaction is NULL
      IF (l_inherit_ctype_flag = 'Y')
         AND (l_inherited_conversion_type IS NOT NULL)
         AND (l_inherited_conversion_type <> 'EMU FIXED')
         AND  (l_inherited_conversion_type <> 'User') THEN
        --
        -- The above condition was included so that when inherit
        -- converstion type is enabled and User rate type is used,
        -- the conversion will be done from Primary to reporting
        -- Using conversion type from gl_mc_reporting_options instead
        -- of User.
        l_conversion_type := l_inherited_conversion_type;
      END IF;

      IF l_conversion_flag = 'Y'
      THEN
        IF p_trans_currency_code = l_target_curr OR
           p_trans_currency_code = 'STAT'
        THEN
          p_trans_conversion_type := 'User';
          p_trans_conversion_rate := 1;
          p_denominator_rate      := 1;
          p_numerator_rate        := 1;
        ELSE
          BEGIN
            gl_currency_api.get_relation(p_trans_currency_code,
                                         l_target_curr,
                                         TRUNC(p_trans_conversion_date),
                                         l_fixed_rate,
                                         l_relationship);
          EXCEPTION -- of relation
            WHEN OTHERS THEN
              /* No Proper Relation is found for the calculation of Conversion Rate */
              p_result_code := 'IMPROPER RELATION';
          END;

          IF l_relationship NOT IN ('EURO-EMU','EMU-EURO','EMU-EMU','EURO-EURO')
          THEN
            IF p_trans_currency_code = l_src_curr
            THEN
              /* For Trans = Source <> Target */
              p_trans_conversion_type := l_conversion_type;
              l_trans_currency_code   := p_trans_currency_code;
            ELSE
              IF NVL(p_trans_conversion_type, 'User') = 'User'
              THEN
                /* User defined rate is used for the calculation of the conversion rate */
                l_trans_currency_code := l_src_Curr;
                p_trans_conversion_type := l_conversion_type;
                l_xrate := TRUE;
              ELSE
                l_trans_currency_code := p_trans_currency_code;
                p_trans_conversion_type := l_conversion_type;
              END IF; -- for p_trans_conversion_type.
            END IF; -- IF p_trans_currency_code = l_src_curr
	      ELSE
            /* Fixed Derived Factor is user for calculating the conversion rate */
            p_trans_conversion_type := 'EMU FIXED';
            l_trans_currency_code := p_trans_currency_code;
          END IF; -- IF l_relationship NOT IN ('EURO-EMU', ...

          BEGIN
            gl_currency_api.get_closest_triangulation_rate(
                                       l_trans_currency_code,
                                       l_target_curr,
                                       TRUNC(p_trans_conversion_date),
                                       p_trans_conversion_type,
                                       l_mrc_max_roll_rate,
                                       p_denominator_rate,
                                       p_numerator_rate,
                                       l_rate);
          EXCEPTION
            WHEN OTHERS THEN
              /* No Rate found */
              p_result_code := 'NO RATE FOUND';
          END;

          IF l_xrate AND p_result_code <> 'NO RATE FOUND'
          THEN
            /*calculating the cross rates */
            p_numerator_rate := p_trans_conversion_rate*p_numerator_rate;
            p_trans_conversion_rate := p_trans_conversion_rate*l_rate;
            p_trans_conversion_type := 'User';
          ELSE -- l_xrate
            p_trans_conversion_rate := l_rate;
          END IF; -- IF l_xrate AND p_result_code <> 'NO RATE FOUND'
        END IF; --  IF p_trans_currency_code = l_target_curr OR ...
      ELSIF l_conversion_flag = 'N'
      THEN
        p_result_code := 'NO CONVERSION';
      END IF; -- IF l_conversion_flag = 'Y'

      IF p_application_id <> 101 AND p_result_code <> 'HEADER VALID ' -- NOT GL
      THEN
        IF p_result_code = 'RSOB NOT FOUND'
        THEN
          fnd_message.set_name('SQLGL', 'MRC_RSOB_NOT_FOUND');
          fnd_message.set_token('RSOB', p_reporting_set_of_books_id);
        ELSIF p_result_code = 'NO CONVERSION'
        THEN
          fnd_message.set_name('SQLGL', 'MRC_CONVERSION_RULE_NOT_FOUND');
        ELSIF p_result_code = 'IMPROPER RELATION'
        THEN
          fnd_message.set_name('SQLGL', 'MRC_NO_RELATIONSHIP_FOUND');
          fnd_message.set_token('TCURR', p_trans_currency_code);
          fnd_message.set_token('RCURR', l_trans_currency_code);
        ELSE
          IF p_trans_conversion_type = 'User' THEN
             p_trans_conversion_type := l_tmp_conversion_type;
          END IF;

          BEGIN
            SELECT user_conversion_type
            INTO   l_user_conversion_type
            FROM   gl_daily_conversion_types
            WHERE  conversion_type = p_trans_conversion_type;
          EXCEPTION
            WHEN OTHERS THEN
              l_user_conversion_type := p_trans_conversion_type;
          END;

          fnd_message.set_name('SQLGL', 'MRC_RATE_NOT_FOUND');
          fnd_message.set_token('FROM', l_trans_currency_code);
          fnd_message.set_token('TO', l_target_curr);
          -- 11/23/03 Updated by LPOON: Changed to display 4-digit year
          fnd_message.set_token('TRANS_DATE', TO_CHAR(p_trans_conversion_date,
                                                      'DD-MON-YYYY'));
          fnd_message.set_token('TYPE', l_user_conversion_type);
        END IF; -- IF p_result_code = 'RSOB NOT FOUND'

        fnd_message.set_token('MODULE','GLMCCURB');
        app_exception.raise_exception;
      END IF; -- IF p_application_id <> 101 AND ...
    EXCEPTION
      WHEN OTHERS THEN
       app_exception.raise_exception;
    END get_rate;
--
--  R11i.X Changes - rename the parameters
--
    PROCEDURE  get_rate(p_primary_set_of_books_id   IN NUMBER,
                        p_reporting_set_of_books_id IN NUMBER,
                        p_trans_date                IN DATE,
                        p_trans_currency_code       IN VARCHAR2,
                        p_trans_conversion_type     IN OUT NOCOPY VARCHAR2,
                        p_trans_conversion_date     IN OUT NOCOPY DATE,
                        p_trans_conversion_rate     IN OUT NOCOPY NUMBER,
                        p_application_id            IN NUMBER,
  	                    p_org_id                    IN NUMBER,
                        p_fa_book_type_code         IN VARCHAR2,
                        p_je_source_name            IN VARCHAR2,
                        p_je_category_name          IN VARCHAR2,
                        p_result_code               IN OUT NOCOPY VARCHAR2) IS
      l_numerator_rate       NUMBER;
      l_denominator_rate     NUMBER;
    BEGIN
      GL_MC_CURRENCY_PKG.get_rate(
                        p_primary_set_of_books_id  ,
                        p_reporting_set_of_books_id,
                        p_trans_date               ,
                        p_trans_currency_code      ,
                        p_trans_conversion_type    ,
                        p_trans_conversion_date    ,
                        p_trans_conversion_rate    ,
                        p_application_id           ,
                        p_org_id                   ,
                        p_fa_book_type_code        ,
                        p_je_source_name           ,
                        p_je_category_name         ,
                        p_result_code              ,
                        l_numerator_rate           ,
                        l_denominator_rate);
    END ;
--
    PROCEDURE GetCurrencyDetails( p_currency_code IN  VARCHAR2,
                                  p_precision     OUT NOCOPY NUMBER,
                                  p_mau           OUT NOCOPY NUMBER ) IS
        i BINARY_INTEGER := 0;
    BEGIN
        WHILE i < NextElement
        LOOP
            EXIT WHEN CurrencyCode(i) = p_currency_code;
            i := i + 1;
        END LOOP;

        IF i = NextElement
        THEN

            DECLARE
                l_Precision NUMBER;
                l_Mau       NUMBER;
            BEGIN
              BEGIN
                SELECT  precision,
                        minimum_accountable_unit
                INTO    l_Precision,
                        l_Mau
                FROM    fnd_currencies
                WHERE   currency_code = p_currency_code;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('SQLGL', 'MRC_DOCUMENT_NOT_FOUND');
                  fnd_message.set_token('MODULE','GLMCCURB');
                  fnd_message.set_token('CURRENCY', p_currency_code);
                  RAISE_APPLICATION_ERROR(-20010, fnd_message.get);
                WHEN OTHERS THEN
                  fnd_message.set_name('SQLGL','MRC_TABLE_ERROR');
                  fnd_message.set_token('MODULE','GLMCCURB');
                  fnd_message.set_token('TABLE','FND_CURRENCIES');
                  RAISE_APPLICATION_ERROR(-20020, fnd_message.get);
              END;
              Precision(i)    := l_Precision;
              Mau(i)          := l_Mau;
            END;

            CurrencyCode(i) := p_currency_code;
            NextElement     := i + 1;

        END IF;
        p_precision := Precision(i);
        p_mau       := Mau(i);

    END GetCurrencyDetails;
--
    FUNCTION get_default_rate (
                p_from_currency      VARCHAR2,
                p_to_currency        VARCHAR2,
                p_conversion_date    DATE,
                p_conversion_type    VARCHAR2 DEFAULT NULL ) RETURN NUMBER IS
        l_rate   NUMBER;
    BEGIN
        BEGIN
          l_rate := gl_currency_api.get_rate(p_from_currency,
                                             p_to_currency,
                                             TRUNC(p_conversion_date),
                                             p_conversion_type);
        EXCEPTION
          WHEN OTHERS THEN
              l_rate := NULL;
        END;

        return( l_rate );
    END get_default_rate;
--
    FUNCTION CurrRound( p_amount IN NUMBER, p_currency_code IN VARCHAR2) RETURN NUMBER IS
        l_precision NUMBER(1);
        l_mau       NUMBER;
    BEGIN
        GetCurrencyDetails( p_currency_code, l_precision, l_mau );
        IF l_mau IS NOT NULL
        THEN
            RETURN( ROUND( p_amount / l_mau) * l_mau );
        ELSE
            RETURN( ROUND( p_amount, l_precision ));
        END IF;
    END CurrRound;
--
END gl_mc_currency_pkg;

/
