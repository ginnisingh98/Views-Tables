--------------------------------------------------------
--  DDL for Package Body ITG_SYNCEXCHINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_SYNCEXCHINBOUND_PVT" AS
/* ARCS: $Header: itgvseib.pls 120.6 2006/08/16 09:05:59 bsaratna noship $
 * CVS:  itgvseib.pls,v 1.15 2002/12/23 21:20:30 ecoe Exp
 */
    l_debug_level         NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
    G_PKG_NAME CONSTANT VARCHAR2(30) := 'ITG_SyncExchInbound_PVT';
    g_action VARCHAR2(400);

    FUNCTION valid_rate_type(
        p_ratetype  IN VARCHAR2
    ) RETURN boolean
    IS
        l_number  NUMBER;
    BEGIN
            SELECT    1
            INTO      l_number
            FROM      DUAL
            WHERE EXISTS (SELECT t.conversion_type
                          from gl_daily_conversion_types_v t
                          where t.conversion_type <> 'User'
                          and t.conversion_type <> 'EMU FIXED'
                          and t.modify_privilege = 'Y'
                          and t.conversion_type = p_ratetype);

            RETURN true;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN false;
    END valid_rate_type;

    FUNCTION get_currency_code(
        p_sob           VARCHAR2,
        p_sob_id        VARCHAR2
    ) RETURN VARCHAR2
    IS
        l_currency_code VARCHAR2(15);
    BEGIN
        IF (l_Debug_Level <= 2) THEN
                itg_debug_pub.Add('Entering - GCC :Getting GL currency code' ,2);
        END IF;

        BEGIN
                SELECT currency_code
                INTO   l_currency_code
                FROM   gl_sets_of_books
                WHERE  set_of_books_id = p_sob_id;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('GCC - l_currency_code'||l_currency_code ,1);
                END IF;

        EXCEPTION
                WHEN OTHERS THEN
                        itg_msg.no_gl_currency(p_sob);
                        RAISE FND_API.G_EXC_ERROR;
        END;

        IF (l_Debug_Level <= 2) THEN
                itg_debug_pub.Add('Exiting - GCC :Getting GL currency code' ,2);
        END IF;

        RETURN l_currency_code;
    END;



  PROCEDURE Process_ExchangeRate(
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        p_syncind          IN         VARCHAR2,
        p_quantity         IN         NUMBER,
        p_currency_from    IN         VARCHAR2,
        p_currency_to      IN         VARCHAR2,
        p_factor           IN         VARCHAR2,
        p_sob              IN         VARCHAR2,
        p_ratetype         IN         VARCHAR2,
        p_creation_date    IN         DATE,
        p_effective_date   IN         DATE
        )
  IS
        /* Business object constants. */
        l_api_name    CONSTANT VARCHAR2(30) := 'Process_ExchangeRate';
        l_api_version CONSTANT NUMBER       := 1.0;
        l_quantity             NUMBER;
        l_count                NUMBER;
        l_var                  NUMBER;

        CURSOR currency_csr(
                p_ccode         IN VARCHAR2
        ) IS
        SELECT currency_code,
               precision,
               extended_precision,
               derive_type
        FROM   fnd_currencies
        WHERE  currency_code      =  p_ccode
        AND    enabled_flag       =  'Y'
        AND    currency_flag      =  'Y'
        AND    (start_date_active <= p_effective_date
                OR     start_date_active IS NULL)
        AND    (end_date_active   >= p_effective_date
                OR    end_date_active    IS NULL);

        currency_to_rec        currency_csr%ROWTYPE;
        currency_from_rec      currency_csr%ROWTYPE;
  BEGIN
        /* Initialize return status */
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        g_action := 'Exchange-rate sync';

        IF (l_Debug_Level <= 2) THEN
                        itg_debug_pub.Add('Entering - PER :Process_ExchangeRate' ,2);
        END IF;

        BEGIN
                SAVEPOINT Process_ExchangeRate_PVT;
                ITG_Debug.setup(
                        p_reset     => TRUE,
                        p_pkg_name  => G_PKG_NAME,
                        p_proc_name => l_api_name
                );

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('PER  - Top of procedure.' ,1);
                        itg_debug_pub.Add('PER  - p_syncind'            ||p_syncind          ,1);
                        itg_debug_pub.Add('PER  - p_quantity'           ||p_quantity         ,1);
                        itg_debug_pub.Add('PER  - p_currency_from'      ||p_currency_from    ,1);
                        itg_debug_pub.Add('PER  - p_currency_to'        ||p_currency_to      ,1);
                        itg_debug_pub.Add('PER  - p_factor'             ||p_factor           ,1);
                        itg_debug_pub.Add('PER  - p_sob'                ||p_sob              ,1);
                        itg_debug_pub.Add('PER  - p_ratetype'           ||p_ratetype         ,1);
                        itg_debug_pub.Add('PER  - p_creation_date'      ||p_creation_date    ,1);
                        itg_debug_pub.Add('PER  - p_effective_date'     ||p_effective_date   ,1);
                END IF;

                g_action := 'Exchange-rate parameter validation';
                /* now validate data */
                DECLARE
                        l_param_name   VARCHAR2(30)   := NULL;
                        l_param_value  VARCHAR2(2000) := 'NULL';
                BEGIN
                        IF    p_currency_to IS NULL THEN
                                l_param_name  := 'CURRTO';
                        ELSIF p_quantity IS NULL THEN
                                l_param_name  := 'QUANTITY';
                        ELSIF p_creation_date IS NULL THEN
                                l_param_name  := 'DATETIME qualifier="CREATION"';
                        ELSIF p_effective_date IS NULL THEN
                                l_param_name  := 'DATETIME qualifier="EFFECTIVE"';
                        ELSIF NOT valid_rate_type(p_ratetype) THEN
                                l_param_name  := 'RATETYPE';
                                l_param_value := p_ratetype;
                        ELSIF NVL(UPPER(p_syncind), 'z') NOT IN ('A', 'C') THEN
                                l_param_name  := 'SYNCIND';
                                l_param_value := p_syncind;
                        ELSIF p_factor IS NOT NULL THEN
                                BEGIN
                                        select to_number(p_factor) into l_var from dual;
                                EXCEPTION
                                        WHEN OTHERS THEN
                                          l_param_name   := 'FACTOR';
                                          l_param_value  := p_factor;
                                END;
                        END IF;

                        IF l_param_name IS NOT NULL THEN
                                ITG_MSG.missing_element_value(l_param_name, l_param_value);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;


                        /* validate currency: exist, enabled, date effective. not EMU to EMU. */
                        /* validate currto */
                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('PER -  Checking/getting p_currency_to' ,1);
                        END IF;

                        OPEN  currency_csr(p_currency_to);
                        FETCH currency_csr INTO currency_to_rec;
                        CLOSE currency_csr;

                        IF(currency_to_rec.currency_code IS NULL) THEN
                                ITG_MSG.missing_element_value('CURRTO', p_currency_to);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        /* validate currfrom */
                        IF p_currency_from IS NULL THEN
                                ITG_MSG.missing_element_value('CURRFROM', p_currency_from);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;


                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('PER - Checking/getting p_currency_from' ,1);
                        END IF;

                        OPEN  currency_csr(p_currency_from);
                        FETCH currency_csr INTO currency_from_rec;
                        CLOSE currency_csr;

                        IF (currency_from_rec.currency_code IS NULL) THEN
                                ITG_MSG.missing_element_value('CURRFROM', p_currency_from);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('PER - Some final checks.' ,1);
                        END IF;

                        IF currency_from_rec.currency_code = currency_to_rec.currency_code THEN
                                ITG_MSG.same_currency_code;
                                RAISE FND_API.G_EXC_ERROR;
                        ELSIF(  currency_from_rec.derive_type IS NOT NULL
                                AND currency_from_rec.derive_type <> currency_to_rec.derive_type
                              ) THEN
                              /* Check this condition , I am not sure, it was checking with =
                                originally .I changed that to <> ** */
                                ITG_MSG.no_currtype_match(currency_from_rec.derive_type,currency_to_rec.derive_type);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                END;
                -- Validation ends
                /* NOTE: Create a quantity based on the factor ??
                 * (not sure, copied from the V1 handler)
                 */
                l_quantity := p_quantity / power(10, p_factor);

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('PER  -  l_quantity'||l_quantity,1);
                END IF;


                /* round up to max precision allowed. */
                l_quantity := ROUND(l_quantity, currency_to_rec.extended_precision);

                /* insert data */
                g_action := 'Exchange-rate creation';

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('PER - Processing data.' ,1);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                     itg_debug_pub.Add('PER - Insert into gl_daily_rates_interface' ,1);
                END IF;

                /* Set the Enable Trigger flag to TRUE "gl_crm_utilities_pkg.enable_trigger" */
                gl_crm_utilities_pkg.change_flag(TRUE);

                INSERT INTO gl_daily_rates_interface(
                              from_currency, to_currency,
                              from_conversion_date, to_conversion_date,
                              user_conversion_type, conversion_rate, mode_flag
                 ) VALUES (
                              p_currency_from, p_currency_to,
                              p_effective_date, p_effective_date,
                              p_ratetype, l_quantity, 'I');

                 /* Set the Enable Trigger flag to FALSE "gl_crm_utilities_pkg.enable_trigger" */
                 gl_crm_utilities_pkg.change_flag(FALSE);

                 DECLARE
                     CURSOR get_error_code IS
                              SELECT error_code
                              FROM   gl_daily_rates_interface
                              WHERE  from_currency        = p_currency_from
                              AND    to_currency          = p_currency_to
                              AND    from_conversion_date = p_effective_date
                              AND    to_conversion_date   = p_effective_date
                              AND    user_conversion_type = 'Corporate'
                              AND    mode_flag            = 'X';

                              l_error_code    gl_daily_rates_interface.error_code%TYPE;
                              l_found         BOOLEAN;

                BEGIN
                      IF (l_Debug_Level <= 1) THEN
                             itg_debug_pub.Add('PER - Check errors in gl_daily_rates_interface' ,1);
                      END IF;

                      OPEN  get_error_code;
                      FETCH get_error_code INTO l_error_code;
                      l_found := get_error_code%FOUND;
                      CLOSE get_error_code;

                      IF l_found THEN
                              ITG_MSG.daily_exchange_rate_error(
                                        p_currency_from,
                                        p_currency_to,
                                        l_error_code);
                              RAISE FND_API.G_EXC_ERROR;
                      END IF;
                END;

                COMMIT WORK;

                IF (l_Debug_Level <= 2) THEN
                        itg_debug_pub.Add('EXITING - PER: Process_ExchangeRate.' ,2);
                END IF;
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Process_ExchangeRate_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR;
                ITG_msg.checked_error(g_action);

        WHEN OTHERS THEN
                ROLLBACK TO Process_ExchangeRate_PVT;
                ITG_msg.unexpected_error(g_action);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                itg_debug.msg('Unexpected error (Exchange-rate sync) - ' || substr(SQLERRM,1,255),true);
    END;


   -- Removed FND_MSG_PUB.Count_And_Get
  END Process_ExchangeRate;
END ITG_SyncExchInbound_PVT;

/
