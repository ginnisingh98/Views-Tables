--------------------------------------------------------
--  DDL for Package Body INL_MATCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_MATCH_GRP" AS
/* $Header: INLGMATB.pls 120.6.12010000.30 2009/10/01 21:36:43 aicosta ship $ */

-- API name   : Create_MatchIntLines
-- Type       : Private
-- Function   : Create Matching Lines
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version     IN NUMBER
--              p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE
--              p_commit          IN VARCHAR2 := FND_API.G_FALSE
--              p_matches_int_tbl IN OUT NOCOPY inl_matches_type_tbl
--
-- OUT        : x_return_status   OUT NOCOPY VARCHAR2
--              x_msg_count       OUT NOCOPY NUMBER
--              x_msg_data        OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Create_MatchIntLines(
    p_api_version     IN NUMBER,
    p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
    p_commit          IN VARCHAR2 := FND_API.G_FALSE,
    p_matches_int_tbl IN OUT NOCOPY inl_matches_int_type_tbl,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2
) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'Create_MatchIntLines';
    l_api_version  CONSTANT NUMBER := 1.0;

    l_debug_info VARCHAR2(2000);
    l_return_status VARCHAR2(1);
    l_match_id NUMBER;
    l_aux NUMBER;
    l_group_id NUMBER;
    l_parent_match_id NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name
    );

    -- Standard Start of API savepoint
    SAVEPOINT Create_MatchIntLines_GRP;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        p_current_version_number => l_api_version,
        p_caller_version_number  => p_api_version,
        p_api_name               => l_api_name,
        p_pkg_name               => g_pkg_name)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF NVL(p_matches_int_tbl.LAST,0) > 0 THEN
        FOR i IN NVL(p_matches_int_tbl.FIRST,0)..NVL(p_matches_int_tbl.LAST,0) LOOP
            SELECT inl_matches_int_s.NEXTVAL
            INTO p_matches_int_tbl(i).match_int_id
            FROM dual;
            IF l_group_id IS NULL then
               l_group_id := p_matches_int_tbl(i).match_int_id;
            END IF;

            l_debug_info := 'Next Match_id';
            INL_LOGGING_PVT.Log_Variable (
                p_module_name       => g_module_name,
                p_procedure_name    => l_api_name,
                p_var_name          => l_debug_info,
                p_var_value         => p_matches_int_tbl(i).match_id
            );
            -- Insert Match Line

            INSERT INTO inl_matches_int (
                match_int_id                 ,                        /* 01 */
                adj_group_date               ,                        /* 01A*/  -- OPM Integration
                group_id                     ,                        /* 02 */
                processing_status_code       ,                        /* 03 */
                transaction_type             ,                        /* 04 */
                match_type_code              ,                        /* 05 */
                from_parent_table_name       ,                        /* 07 */
                from_parent_table_id         ,                        /* 08 */
                to_parent_table_name         ,                        /* 08 */
                to_parent_table_id           ,                        /* 09 */
                matched_qty                  ,                        /* 11 */
                matched_uom_code             ,                        /* 12 */
                matched_amt                  ,                        /* 13 */
                matched_curr_code            ,                        /* 14 */
                matched_curr_conversion_type ,                        /* 15 */
                matched_curr_conversion_date ,                        /* 16 */
                matched_curr_conversion_rate ,                        /* 17 */
                replace_estim_qty_flag       ,                        /* 18 */
                charge_line_type_id          ,                        /* 19 */
                party_id                     ,                        /* 20 */
                party_number                 ,                        /* 21 */
                party_site_id                ,                        /* 22 */
                party_site_number            ,                        /* 23 */
                tax_code                     ,                        /* 24 */
                nrec_tax_amt                 ,                        /* 25 */
                tax_amt_included_flag        ,                        /* 26 */
                match_amounts_flag           ,                        /* 28 */
                created_by                   ,                        /* 29 */
                creation_date                ,                        /* 30 */
                last_updated_by              ,                        /* 31 */
                last_update_date             ,                        /* 32 */
                last_update_login            ,                        /* 33 */
                request_id                   ,                        /* 34 */
                program_id                   ,                        /* 35 */
                program_application_id       ,                        /* 36 */
                program_update_date                                   /* 37 */
              )
            VALUES (
                p_matches_int_tbl(i).match_int_id                 ,   /* 01 */
                p_matches_int_tbl(i).adj_group_date               ,   /* 01A*/  -- OPM Integration
                l_group_id                                        ,   /* 02 */
                'PENDING'                                         ,   /* 03 */
                'CREATE'                                          ,   /* 04 */
                p_matches_int_tbl(i).match_type_code              ,   /* 05 */
                p_matches_int_tbl(i).from_parent_table_name       ,   /* 07 */
                p_matches_int_tbl(i).from_parent_table_id         ,   /* 08 */
                p_matches_int_tbl(i).to_parent_table_name         ,   /* 08 */
                p_matches_int_tbl(i).to_parent_table_id           ,   /* 09 */
                p_matches_int_tbl(i).matched_qty                  ,   /* 11 */
                p_matches_int_tbl(i).matched_uom_code             ,   /* 12 */
                p_matches_int_tbl(i).matched_amt                  ,   /* 13 */
                p_matches_int_tbl(i).matched_curr_code            ,   /* 14 */
                p_matches_int_tbl(i).matched_curr_conversion_type ,   /* 15 */
                p_matches_int_tbl(i).matched_curr_conversion_date ,   /* 16 */
                p_matches_int_tbl(i).matched_curr_conversion_rate ,   /* 17 */
                p_matches_int_tbl(i).replace_estim_qty_flag       ,   /* 18 */
                p_matches_int_tbl(i).charge_line_type_id          ,   /* 19 */
                p_matches_int_tbl(i).party_id                     ,   /* 20 */
                NULL                                              ,   /* 21 */
                p_matches_int_tbl(i).party_site_id                ,   /* 22 */
                NULL                                              ,   /* 23 */
                p_matches_int_tbl(i).tax_code                     ,   /* 24 */
                p_matches_int_tbl(i).nrec_tax_amt                 ,   /* 25 */
                p_matches_int_tbl(i).tax_amt_included_flag        ,   /* 26 */
                p_matches_int_tbl(i).match_amounts_flag           ,   /* 28 */
                fnd_global.user_id                                ,   /* 29 */
                SYSDATE                                           ,   /* 30 */
                fnd_global.user_id                                ,   /* 31 */
                SYSDATE                                           ,   /* 32 */
                fnd_global.login_id                               ,   /* 33 */
                fnd_global.conc_request_id                        ,   /* 34 */
                fnd_global.conc_program_id                        ,   /* 35 */
                fnd_global.prog_appl_id                           ,   /* 36 */
                SYSDATE                                               /* 37 */
              );
        END LOOP;
    END IF;

    -- If any errors happen abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
        );

    -- Standard End of Procedure/Function Logging
    INL_logging_pvt.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name
        );
        ROLLBACK TO Create_MatchIntLines_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name
        );
        ROLLBACK TO Create_MatchIntLines_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
        );
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name
        );
        ROLLBACK TO Create_MatchIntLines_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(p_message_level=>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_api_name
            );
        END IF;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
        );
END Create_MatchIntLines;


/*=======================================
|
|        Matches From Payables
|
\=======================================*/

-- Api name   : Create_MatchesFromAP
-- Type       : Group
-- Function   : Create matches in LCM for actuals captured from a given AP Invoice.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version      IN NUMBER
--              p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE
--              p_commit           IN NUMBER := FND_API.G_FALSE
--              p_invoice_id       IN NUMBER
--
-- OUT        : x_return_status   OUT NOCOPY VARCHAR2
--              x_msg_count       OUT NOCOPY NUMBER
--              x_msg_data        OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
PROCEDURE Create_MatchesFromAP(p_api_version      IN NUMBER,
                               p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                               p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                               p_invoice_id       IN NUMBER,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               x_msg_count       OUT NOCOPY NUMBER,
                               x_msg_data        OUT NOCOPY VARCHAR2)
IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Create_MatchesFromAP';
   l_api_version    CONSTANT NUMBER := 1.0;

   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(2000);
   l_debug_info VARCHAR2(200);
   l_distr_amount NUMBER;
   l_quantity_invoiced NUMBER;
   l_line_amount NUMBER;
   l_par_cost_factor_id NUMBER;
   l_par_line_type_lookup_code VARCHAR2(25);

   -- This cursor if for retrieving Invoice information at Invoice
   -- Distribution level to be sent to LCM.

   -- It retrives AP Distribution lines that would affect "ITEM", "CHARGE" and "TAX" lines in LCM,
   -- including their corrections.

   -- The invoice line types we are handling for LCM integration are the
   -- following: 'ITEM', 'MISCELLANEOUS', 'FREIGHT', 'TAX'.

   -- Although there are other invoice line types such as 'RETAINAGE RELEASE',
   -- 'AWT','RETROTAX','PREPAY', the invoice line types above are the ones
   -- that appear in the Invoices form, when we are creating invoices.

   CURSOR c_distr (p_sysdate date) IS
      SELECT decode(NVL(l.corrected_inv_id, 0), 0, decode(l.line_type_lookup_code,'ITEM','ITEM', 'TAX', 'TAX', 'CHARGE'), 'CORRECTION') line_type,
             decode(NVL(l.corrected_inv_id, 0), 0, NULL, decode(l.line_type_lookup_code,'ITEM','ITEM', 'TAX', 'TAX', 'CHARGE')) correction_type,
             d.amount distr_amount,
             d.corrected_invoice_dist_id corrected_invoice_dist_id,
             d.invoice_distribution_id invoice_distribution_id,
             d.invoice_id invoice_id,
             d.line_type_lookup_code line_type_lookup_code,
             d.parent_reversal_id parent_reversal_id,
             d.dist_match_type dist_match_type,
             d.charge_applicable_to_dist_id,
             NVL(l.rcv_transaction_id,d.rcv_transaction_id) rcv_transaction_id, --BUG#8485279
--             l.rcv_transaction_id rcv_transaction_id,
             muom.uom_code uom_code,
             i.invoice_currency_code curr_code,
             i.exchange_rate curr_rate,
             i.exchange_rate_type curr_type,
             i.exchange_date curr_date,
             i.party_id party_id,
             i.party_site_id party_site_id,
             decode(l.line_type_lookup_code, 'TAX', l.quantity_invoiced, d.quantity_invoiced) quantity_invoiced,
             l.cost_factor_id cost_factor_id,
             l.tax tax_code,
             decode(l.line_type_lookup_code, 'TAX', decode(d.tax_recoverable_flag,'Y',0,d.amount), NULL) nrec_tax_amt,
             decode(l.line_type_lookup_code, 'TAX', 'N', NULL) tax_amt_included_flag,
             d.accounting_date accounting_date -- LCM-OPM Integration Send to OPM as transaction date
      FROM   rcv_transactions rt,
             ap_invoice_distributions d,
             ap_invoices i,
             ap_invoice_lines l,
             mtl_units_of_measure muom
      WHERE l.line_type_lookup_code IN ('ITEM', 'MISCELLANEOUS', 'FREIGHT', 'TAX')
      AND d.match_status_flag = 'S'
      AND rt.lcm_shipment_line_id IS NOT NULL
      AND muom.unit_of_measure (+) = d.matched_uom_lookup_code
      AND d.invoice_id = l.invoice_id
      AND d.invoice_line_number = l.line_number
      AND rt.transaction_id = NVL(l.rcv_transaction_id,d.rcv_transaction_id) --BUG#8485279
      AND l.invoice_id = i.invoice_id
      AND d.invoice_id = p_invoice_id
      ORDER BY invoice_distribution_id;

   c_distr_rec c_distr%ROWTYPE;
   l_matches_int_tbl inl_matches_int_type_tbl;
   i NUMBER;
   l_invoices_with_charge_tbl   inl_int_tbl;
   l_count_invoices_with_charge NUMBER:=1;
   l_sysdate date := trunc(sysdate);
   l_count_to_match_amt NUMBER;
BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name
    );

    l_debug_info := 'Begining Create_MatchesFromAP';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    );

    -- Standard Start of API savepoint
    SAVEPOINT Create_MatchesFromAP_GRP;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
                p_current_version_number => l_api_version,
                p_caller_version_number => p_api_version,
                p_api_name => l_api_name,
                p_pkg_name => g_pkg_name)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    i := 0;
    -- Getting AP Distribution Lines
    l_debug_info := 'Getting AP Distribution Lines';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    );
    FOR c_distr_rec IN c_distr(l_sysdate) LOOP
        i := i + 1;

        l_debug_info := 'c_distr_rec.line_type_lookup_code: ' || c_distr_rec.line_type_lookup_code;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        );

        -- Distribution
        IF c_distr_rec.line_type_lookup_code = 'ITEM' AND c_distr_rec.parent_reversal_id IS NOT NULL THEN
          l_distr_amount := c_distr_rec.distr_amount * -1;
          l_quantity_invoiced := c_distr_rec.quantity_invoiced * -1;
          l_line_amount := c_distr_rec.distr_amount * -1;
        ELSE
          l_distr_amount := c_distr_rec.distr_amount;
          l_quantity_invoiced := c_distr_rec.quantity_invoiced;
          l_line_amount := c_distr_rec.distr_amount;
        END IF;

        l_debug_info := 'Invoice Distribution id('||i||'): '||c_distr_rec.invoice_distribution_id;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        );

        l_matches_int_tbl(i).from_parent_table_name := 'AP_INVOICE_DISTRIBUTIONS';
        l_matches_int_tbl(i).from_parent_table_id   := c_distr_rec.invoice_distribution_id;
        l_matches_int_tbl(i).adj_group_date         := c_distr_rec.accounting_date;

        -- In order to make the Create Adjust process less
        -- complex, the correction match should use the same
        -- currency that is used by the corrected match.
        -- Although the match represents the new amount of the line and not the variation inl_matches_int will have the variation.
        IF c_distr_rec.line_type = 'CORRECTION'
            AND (c_distr_rec.dist_match_type <> 'NOT_MATCHED'
                 OR c_distr_rec.correction_type = 'ITEM')
        THEN
            -- Correction
            l_debug_info := 'It is a correction. Type: '||c_distr_rec.correction_type;
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info
            );

            l_matches_int_tbl(i).to_parent_table_name := 'AP_INVOICE_DISTRIBUTIONS';
            l_matches_int_tbl(i).to_parent_table_id := c_distr_rec.corrected_invoice_dist_id;
        ELSE
            l_debug_info := 'It is not a correction.';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info
            );

            l_matches_int_tbl(i).to_parent_table_name := 'RCV_TRANSACTIONS';
            l_matches_int_tbl(i).to_parent_table_id := c_distr_rec.rcv_transaction_id;

        END IF;

        IF c_distr_rec.line_type = 'ITEM' OR c_distr_rec.correction_type  = 'ITEM' THEN
            -- The distribution cursor does not get IPV lines
            -- To get the exact qty and amt we access the ap_invoice_lines
            l_matches_int_tbl(i).charge_line_type_id   := NULL;
            l_matches_int_tbl(i).matched_qty           := l_quantity_invoiced; --c_distr_rec.quantity_invoiced;
            l_matches_int_tbl(i).matched_uom_code      := c_distr_rec.uom_code;
            l_matches_int_tbl(i).matched_amt           := l_line_amount; --c_distr_rec.distr_amount;
            l_matches_int_tbl(i).tax_code              := NULL;
            l_matches_int_tbl(i).nrec_tax_amt          := NULL;
            l_matches_int_tbl(i).tax_amt_included_flag := NULL;
            l_matches_int_tbl(i).party_id              := NULL;
            l_matches_int_tbl(i).party_site_id         := NULL;
        ELSE
            l_matches_int_tbl(i).matched_qty           := NULL;

            l_debug_info := 'c_distr_rec.line_type';
            INL_LOGGING_PVT.Log_Variable (
                p_module_name       => g_module_name,
                p_procedure_name    => l_api_name,
                p_var_name          => l_debug_info,
                p_var_value         => c_distr_rec.line_type
            );

            l_debug_info := 'c_distr_rec.correction_type';
            INL_LOGGING_PVT.Log_Variable (
                p_module_name       => g_module_name,
                p_procedure_name    => l_api_name,
                p_var_name          => l_debug_info,
                p_var_value         => c_distr_rec.correction_type
            );
            SELECT count(*)
            INTO l_count_to_match_amt
            FROM ap_invoice_lines_all l
            WHERE l.invoice_id = p_invoice_id
            AND  l.line_type_lookup_code <> 'ITEM';

            IF l_count_to_match_amt < 2 THEN
                l_matches_int_tbl(i).match_amounts_flag := 'N';
            ELSE
                l_matches_int_tbl(i).match_amounts_flag := 'Y';
            END IF;

            IF c_distr_rec.line_type = 'CHARGE'  OR c_distr_rec.correction_type  = 'CHARGE'  THEN

                l_debug_info := 'l_count_invoices_with_charge';
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name       => g_module_name,
                    p_procedure_name    => l_api_name,
                    p_var_name          => l_debug_info,
                    p_var_value         => l_count_invoices_with_charge
                );

                l_matches_int_tbl(i).party_id              := c_distr_rec.party_id;
                l_matches_int_tbl(i).party_site_id         := c_distr_rec.party_site_id;
                l_matches_int_tbl(i).charge_line_type_id   := c_distr_rec.cost_factor_id;
                l_matches_int_tbl(i).matched_amt           := l_distr_amount; --c_distr_rec.distr_amount;
                l_matches_int_tbl(i).tax_code              := NULL;
                l_matches_int_tbl(i).nrec_tax_amt          := NULL;
                l_matches_int_tbl(i).tax_amt_included_flag := NULL;
            ELSE
                l_debug_info := 'c_distr_rec.charge_applicable_to_dist_id';
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name       => g_module_name,
                    p_procedure_name    => l_api_name,
                    p_var_name          => l_debug_info,
                    p_var_value         => c_distr_rec.charge_applicable_to_dist_id
                );
                l_debug_info := 'c_distr_rec.invoice_id';
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name       => g_module_name,
                    p_procedure_name    => l_api_name,
                    p_var_name          => l_debug_info,
                    p_var_value         => c_distr_rec.invoice_id
                );
                -- Gets the "parent" cost factor and line_type_lookup_code
                -- in order to identify whether or not a given Charge that
                -- has taxes, should keep in LCM the same cost factor
                -- defined in its Invoice
                SELECT ail.cost_factor_id,
                       ail.line_type_lookup_code
                INTO l_par_cost_factor_id,
                     l_par_line_type_lookup_code
                FROM ap_invoice_distributions aid,
                     ap_invoice_lines ail
                WHERE aid.invoice_id = ail.invoice_id
                AND aid.invoice_line_number = ail.line_number
                AND aid.invoice_distribution_id = c_distr_rec.charge_applicable_to_dist_id
                AND aid.invoice_id = c_distr_rec.invoice_id;

                IF l_par_line_type_lookup_code IN ('MISCELLANEOUS', 'FREIGHT') THEN
                    l_matches_int_tbl(i).charge_line_type_id   := l_par_cost_factor_id;
                ELSE
                    l_matches_int_tbl(i).charge_line_type_id   := NULL;
                    l_matches_int_tbl(i).match_amounts_flag := 'N';
                END IF;

                l_matches_int_tbl(i).party_id              := NULL;
                l_matches_int_tbl(i).party_site_id         := NULL;
                l_matches_int_tbl(i).matched_amt           := l_distr_amount; --c_distr_rec.distr_amount;
                l_matches_int_tbl(i).tax_code              := c_distr_rec.tax_code;
                l_matches_int_tbl(i).nrec_tax_amt          := c_distr_rec.nrec_tax_amt;
                l_matches_int_tbl(i).tax_amt_included_flag := c_distr_rec.tax_amt_included_flag;
            END IF;
        END IF;

        IF c_distr_rec.line_type = 'CORRECTION'
            AND c_distr_rec.dist_match_type = 'NOT_MATCHED'
            AND c_distr_rec.correction_type <> 'ITEM'
        THEN
            l_matches_int_tbl(i).match_type_code               := c_distr_rec.correction_type;
        ELSE
            l_matches_int_tbl(i).match_type_code               := c_distr_rec.line_type;
        END IF;
        l_matches_int_tbl(i).matched_curr_code             := c_distr_rec.curr_code;
        l_matches_int_tbl(i).matched_curr_conversion_type  := c_distr_rec.curr_type;
        l_matches_int_tbl(i).matched_curr_conversion_date  := c_distr_rec.curr_date;
        l_matches_int_tbl(i).matched_curr_conversion_rate  := c_distr_rec.curr_rate;
        l_debug_info := 'End Loop';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        );

    END LOOP;

    l_debug_info := 'Call Create_MatchIntLines ';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    );
    IF NVL(l_matches_int_tbl.LAST,0) > 0 THEN
        -- Call Create_MatchIntLines to create Matches and
        -- set Pending Matching Flag to 'Y' in Shipment Header.
        Create_MatchIntLines(
            p_api_version     => 1.0,
            p_init_msg_list   => FND_API.G_FALSE,
            p_commit          => FND_API.G_FALSE,
            p_matches_int_tbl => l_matches_int_tbl,
            x_return_status   => l_return_status,
            x_msg_count       => l_msg_count,
            x_msg_data        => l_msg_data
        );

    END IF;

    -- If any errors happen abort the process.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data
    );

    -- Standard End of Procedure/Function Logging
    INL_logging_pvt.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name
        );
        ROLLBACK TO Create_MatchesFromAP_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name
        );
        ROLLBACK TO Create_MatchesFromAP_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
        );
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name
        );
        ROLLBACK TO Create_MatchesFromAP_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name => g_pkg_name,
                p_procedure_name => l_api_name
            );
        END IF;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
        );
END Create_MatchesFromAP;

END INL_MATCH_GRP;

/
