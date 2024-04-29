--------------------------------------------------------
--  DDL for Package Body INL_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_TAX_PVT" AS
/* $Header: INLVTAXB.pls 120.8.12010000.23 2009/08/17 19:09:42 aicosta ship $ */

-- Utl name   : Delete_PreviousTaxLines
-- Type       : Private
-- Function   : Delete previous Tax Lines
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id        IN  NUMBER,
--
-- OUT        : x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Delete_PreviousTaxLines (
    p_ship_header_id    IN  NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2
) IS
    l_proc_name  CONSTANT VARCHAR2(100) := 'Delete_PreviousTaxLines';
    l_debug_info    VARCHAR2(240);
    l_return_status VARCHAR2(1);
BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name
    );

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Deleting all Tax records
    l_debug_info := 'Deleting Tax records.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info
    );

    DELETE FROM inl_tax_lines tl
     WHERE tl.ship_header_id = P_ship_Header_Id
     OR (tl.ship_header_id is null
         AND EXISTS (SELECT 1
                     FROM inl_associations assoc
                     WHERE assoc.ship_header_id = P_ship_Header_Id
                     AND assoc.from_parent_table_name = 'INL_TAX_LINES'
                     AND assoc.from_parent_table_id = tl.tax_line_id)
         AND NOT EXISTS (SELECT 1
                     FROM inl_associations assoc, inl_ship_headers sh
                     WHERE assoc.ship_header_id <> P_ship_Header_Id
                     AND assoc.ship_header_id = sh.ship_header_id
                     AND sh.ship_status_code = 'COMPLETED'
                     AND from_parent_table_name = 'INL_TAX_LINES'
                     AND from_parent_table_id = tl.tax_line_id))
    ;

    --Deleting all association records from Taxes
    l_debug_info := 'Deleting association records.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info
    );

    DELETE FROM inl_associations assoc
     WHERE assoc.from_parent_table_name = 'INL_TAX_LINES'
     AND NOT EXISTS (SELECT 1
                     FROM inl_tax_lines tl
                     WHERE assoc.from_parent_table_id = tl.tax_line_id)
    ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                         p_procedure_name => l_proc_name);
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                           p_procedure_name => l_proc_name);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                           p_procedure_name => l_proc_name);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,l_proc_name);
    END IF;
END Delete_PreviousTaxLines;



-- Utl name   : Prorate_TaxValues
-- Type       : Private
-- Function   : Import Tax Lines from PO
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_po_line_location_id         IN NUMBER
--              p_sl_currency_code            IN VARCHAR2
--              p_sl_currency_conversion_type IN VARCHAR2
--              p_sl_currency_conversion_date IN DATE
--              p_sl_currency_conversion_rate IN NUMBER
--              p_sl_txn_qty                  IN NUMBER
--              p_sl_txn_unit_price           IN NUMBER
--
-- OUT        : x_tax_amt                     IN OUT NOCOPY NUMBER
--              x_rec_tax_amt                 IN OUT NOCOPY NUMBER
--              x_return_status                  OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Prorate_TaxValues (
    p_po_line_location_id         IN NUMBER,
    p_sl_currency_code            IN VARCHAR2,
    p_sl_currency_conversion_type IN VARCHAR2,
    p_sl_currency_conversion_date IN DATE,
    p_sl_txn_qty                  IN NUMBER,
    p_sl_txn_unit_price           IN NUMBER,
    x_tax_amt                     IN OUT NOCOPY NUMBER,
    x_rec_tax_amt                 IN OUT NOCOPY NUMBER,
    x_return_status               OUT NOCOPY VARCHAR2
) IS
    l_proc_name  CONSTANT VARCHAR2(100) := 'Prorate_TaxValues';
    l_debug_info    VARCHAR2(240);
    l_return_status VARCHAR2(1);

    l_qty               NUMBER;
    l_amt               NUMBER;
    l_po_curr_code      VARCHAR2(15);
    l_po_curr_rate_type VARCHAR2(30);
    l_po_curr_rate_date DATE;
    l_proration_rate    NUMBER;
BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name
    );

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Getting PO_LINE_LOCATION data
    l_debug_info := 'Getting PO_LINE_LOCATION data';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info
    );

    SELECT pll.quantity,
           (pll.quantity * pL.unit_price) amount,
           pH.currency_code,
           pH.rate_type,
           pH.rate_date
    INTO   l_qty,
           l_amt,
           l_po_curr_code,
           l_po_curr_rate_type,
           l_po_curr_rate_date
    FROM po_line_locations pll,
         po_lines_all pL,
         po_headers pH
    WHERE pll.line_location_id = p_po_line_location_id
    AND pll.po_line_id         = pL.po_line_id
    AND pll.po_header_id       = pH.po_header_id
    ;
    --Verify if currency convertion is required
    l_debug_info := 'Verify if currency convertion is required';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info
    );
    IF p_sl_currency_code <> l_po_curr_code THEN
        --Use LCM INL_LANDEDCOST_PVT.Converted_Amt to get the converted amount
        l_debug_info := 'Use LCM INL_LANDEDCOST_PVT.Converted_Amt to get the converted amount';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info
        );
        l_debug_info := 'l_amt';
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => l_debug_info,
            p_var_value      => l_amt
        );
        l_debug_info := 'l_po_curr_code';
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => l_debug_info,
            p_var_value      => l_po_curr_code
        );
        l_debug_info := 'p_sl_currency_code';
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => l_debug_info,
            p_var_value      => p_sl_currency_code
        );
        l_debug_info := 'nvl(l_po_curr_rate_type, p_sl_currency_conversion_type)';
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => l_debug_info,
            p_var_value      => nvl(l_po_curr_rate_type, p_sl_currency_conversion_type)
        );
        l_debug_info := 'nvl(l_po_curr_rate_date, p_sl_currency_conversion_date)';
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => l_debug_info,
            p_var_value      => nvl(l_po_curr_rate_date, p_sl_currency_conversion_date)
        );
        l_amt := INL_LANDEDCOST_PVT.Converted_Amt(
                    p_amt                      => l_amt,
                    p_from_currency_code       => l_po_curr_code,
                    p_to_currency_code         => p_sl_currency_code,
                    p_currency_conversion_type => nvl(l_po_curr_rate_type, p_sl_currency_conversion_type),
                    p_currency_conversion_date => nvl(l_po_curr_rate_date, p_sl_currency_conversion_date)
                    )
        ;
        l_debug_info := 'l_amt';
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => l_debug_info,
            p_var_value      => l_amt
        );

    END IF;
    --Calculates the proration rate
    l_debug_info := 'Calculates the proration rate';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info
    );
    l_proration_rate := (p_sl_txn_unit_price*p_sl_txn_qty) / l_amt;

    --Calculates the proration of tax
    l_debug_info := 'Calculates the proration of tax (proration_rate= '||l_proration_rate||')';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info     => l_debug_info
    );

    x_rec_tax_amt := x_rec_tax_amt * l_proration_rate;
    l_debug_info := 'x_rec_tax_amt';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name       => l_debug_info,
        p_var_value      => x_rec_tax_amt
    );

    x_tax_amt := x_tax_amt * l_proration_rate;
    l_debug_info := 'x_tax_amt';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name       => l_debug_info,
        p_var_value      => x_tax_amt
    );

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                         p_procedure_name => l_proc_name);
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                           p_procedure_name => l_proc_name);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                           p_procedure_name => l_proc_name);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,l_proc_name);
    END IF;
END Prorate_TaxValues;

-- API name   : Generate_TaxesFromPO
-- Type       : Private
-- Function   : Import Tax Lines from PO
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id    IN NUMBER      Required
--
-- OUT          p_tax_ln_tbl        OUT tax_ln_tbl,
--              x_return_status     OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Generate_TaxesFromPO (
    p_ship_header_id    IN  NUMBER,
    p_tax_ln_tbl        OUT NOCOPY INL_TAX_PVT.tax_ln_tbl,
    x_return_status     OUT NOCOPY VARCHAR2
) IS
    l_proc_name  CONSTANT VARCHAR2(100) := 'Generate_TaxesFromPO';
    l_debug_info    VARCHAR2(240);
    l_return_status VARCHAR2(1);

    CURSOR zlines is
        SELECT
            sl_zx.tax,
            sl_zx.tax_line_id,
            nvl(sl_zx.tax_amt_tax_curr,0)       tax_amt_tax_curr,       --BUG#8307904
            nvl(sl_zx.rec_tax_amt_tax_curr,0)   rec_tax_amt_tax_curr,   --BUG#8307904
            sl_zx.tax_currency_code,
            sl_zx.tax_currency_conversion_type,
            sl_zx.tax_currency_conversion_date,
            sl_zx.tax_amt_included_flag,
            nvl(sl_zx.trx_line_quantity,0)      trx_line_quantity,      --BUG#8307904
            nvl(sl_zx.line_amt,0)               line_amt,               --BUG#8307904
            sl_zx.trx_currency_code,
            sl_zx.ship_line_id,
            sl_zx.po_line_location_id,
            sl_zx.sl_currency_code,
            sl_zx.sl_currency_conversion_type,
            sl_zx.sl_currency_conversion_date,
            nvl(sl_zx.sl_txn_qty,0)             sl_txn_qty,             --BUG#8307904
            nvl(sl_zx.sl_txn_unit_price,0)      sl_txn_unit_price,      --BUG#8307904
            tl_assoc.inl_tax_line_id,
            tl_assoc.inl_tax_line_num
        FROM (SELECT
                zl.tax,
                zl.tax_line_id,
                zl.tax_amt_tax_curr,
                zl.rec_tax_amt_tax_curr,
                zl.tax_currency_code,
                zl.tax_currency_conversion_type,
                zl.tax_currency_conversion_date,
                zl.tax_amt_included_flag,
                zl.trx_line_quantity,
                zl.line_amt,
                zl.trx_currency_code,
                sl.ship_header_id,
                sl.ship_line_source_id      po_line_location_id,
                sl.currency_code            sl_currency_code,
                sl.currency_conversion_type sl_currency_conversion_type,
                sl.currency_conversion_date sl_currency_conversion_date,
                sl.txn_qty                  sl_txn_qty,
                sl.txn_unit_price           sl_txn_unit_price,
                sl.ship_line_id
              FROM
                inl_ship_lines sl,
                zx_lines zl
              WHERE sl.ship_header_id            = p_ship_header_id
              AND sl.ship_line_src_type_code      = 'PO'
              AND sl.ship_line_source_id         = zl.trx_line_id
              AND zl.application_id              = 201
              ) sl_zx
             ,(SELECT
                tl.tax_line_num inl_tax_line_num,
                tl.tax_line_id inl_tax_line_id,
                assoc.to_parent_table_id,
                tl.source_parent_table_id
               FROM inl_adj_tax_lines_v tl,
                    inl_associations assoc
               WHERE assoc.from_parent_table_name = 'INL_TAX_LINES'
               AND assoc.from_parent_table_id  = tl.tax_line_id
               AND assoc.to_parent_table_name  = 'INL_SHIP_LINES'
               AND tl.ship_header_id           = p_ship_header_id
               AND tl.source_parent_table_name = 'ZX_LINES'
              ) tl_assoc
        WHERE tl_assoc.source_parent_table_id(+) = sl_zx.tax_line_id
        AND tl_assoc.to_parent_table_id(+)     = sl_zx.ship_line_id
    ;
    zlines_rec zlines%ROWTYPE;
    TYPE zlines_tbl_tp IS TABLE OF zlines%ROWTYPE INDEX BY BINARY_INTEGER;
    zlines_tbl zlines_tbl_tp;
    l_tax_amt_prorated NUMBER;
    l_rec_tax_amt_prorated NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name
    );

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Uses the zlines cursor
    l_debug_info := 'Uses the zlines cursor ';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info
    );

    OPEN    zlines;
    FETCH   zlines
    BULK    COLLECT INTO zlines_tbl;
    CLOSE   zlines;

    IF ( NVL(zlines_tbl.COUNT,0) > 0) THEN
        -- loop in all taxes of current shipment
        FOR i IN zlines_tbl.FIRST..zlines_tbl.LAST LOOP
        -- when eBTax recalculates the taxes the tax_line_id in zx_lines remains the same

            p_tax_ln_tbl(i).tax_code                 := zlines_tbl(i).tax;
            p_tax_ln_tbl(i).ship_header_id           := p_ship_header_id;
            p_tax_ln_tbl(i).source_parent_table_name := 'ZX_LINES';
            p_tax_ln_tbl(i).source_parent_table_id   := zlines_tbl(i).tax_line_id;
            p_tax_ln_tbl(i).to_parent_table_name     := 'INL_SHIP_LINES';
            p_tax_ln_tbl(i).to_parent_table_id       := zlines_tbl(i).ship_line_id;
            p_tax_ln_tbl(i).currency_code            := zlines_tbl(i).tax_currency_code;
            p_tax_ln_tbl(i).currency_conversion_type := zlines_tbl(i).tax_currency_conversion_type;
            p_tax_ln_tbl(i).currency_conversion_date := zlines_tbl(i).tax_currency_conversion_date;
            p_tax_ln_tbl(i).tax_amt_included_flag    := zlines_tbl(i).tax_amt_included_flag;

            -- sometimes the shipment line doesn't receive a whole PO Line
            -- in these cases a proration is necessary

            l_tax_amt_prorated     := zlines_tbl(i).tax_amt_tax_curr;
            l_rec_tax_amt_prorated := zlines_tbl(i).rec_tax_amt_tax_curr;

            l_debug_info := 'l_tax_amt_prorated';
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => l_debug_info,
                p_var_value      => l_tax_amt_prorated
            );

            l_debug_info := 'l_rec_tax_amt_prorated';
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => l_debug_info,
                p_var_value      => l_rec_tax_amt_prorated
            );

            prorate_TaxValues(
                p_po_line_location_id         => zlines_tbl(i).po_line_location_id,
                p_sl_currency_code            => zlines_tbl(i).sl_currency_code,
                p_sl_currency_conversion_type => zlines_tbl(i).sl_currency_conversion_type,
                p_sl_currency_conversion_date => zlines_tbl(i).sl_currency_conversion_date,
                p_sl_txn_qty                  => zlines_tbl(i).sl_txn_qty,
                p_sl_txn_unit_price           => zlines_tbl(i).sl_txn_unit_price,
                x_tax_amt                     => l_tax_amt_prorated,
                x_rec_tax_amt                 => l_rec_tax_amt_prorated,
                x_return_status               => l_return_status
            );
            -- If any errors happen abort the process.
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;


            l_debug_info := 'l_tax_amt_prorated';
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => l_debug_info,
                p_var_value      => l_tax_amt_prorated
            );

            l_debug_info := 'l_rec_tax_amt_prorated';
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => l_debug_info,
                p_var_value      => l_rec_tax_amt_prorated
            );

            p_tax_ln_tbl(i).tax_amt                  := l_tax_amt_prorated;
            p_tax_ln_tbl(i).nrec_tax_amt             := l_tax_amt_prorated - l_rec_tax_amt_prorated;

        END LOOP;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (p_module_name    => g_module_name,
                                 p_procedure_name => l_proc_name);


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                         p_procedure_name => l_proc_name);
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                           p_procedure_name => l_proc_name);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                           p_procedure_name => l_proc_name);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,l_proc_name);
    END IF;
END Generate_TaxesFromPO;

-- API name   : Generate_Taxes
-- Type       : Private
-- Function   : Generate Tax Lines automatically from a source for now
--              can be the PO or any other logic defined inside the Taxes Hook.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version       IN NUMBER      Required
--              p_init_msg_list     IN VARCHAR2    Optional  Default = FND_API.G_FALSE
--              p_commit            IN VARCHAR2    Optional  Default = FND_API.G_FALSE
--              p_ship_header_id    IN NUMBER      Required
--              p_source            IN VARCHAR2    Optional  Default = FND_API.G_FALSE
--
-- OUT          x_return_status     OUT NOCOPY VARCHAR2
--              x_msg_count         OUT NOCOPY  NUMBER
--              x_msg_data          OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Generate_Taxes(
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE,
    p_commit         IN VARCHAR2 := FND_API.G_FALSE,
    p_ship_header_id IN NUMBER,
    p_source         IN VARCHAR2 := 'PO',
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2
) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'Generate_Taxes';
    l_api_version   CONSTANT NUMBER := 1.0;
    l_debug_info    VARCHAR2(240);
    l_return_status VARCHAR2(1);
    l_override_default_processing BOOLEAN;
    l_tax_line_id   NUMBER;
    l_tax_line_num  NUMBER;

    l_tax_ln_tbl        INL_TAX_PVT.tax_ln_tbl;

    -- group ln
    l_ship_groups_tbl   INL_TAX_PVT.sh_group_ln_tbl_tp;

    -- ship ln
    l_ship_lines_tbl    INL_TAX_PVT.ship_ln_tbl_tp;

    -- charge ln
    l_charge_lines_tbl  INL_TAX_PVT.charge_ln_tbl_tp;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name
    );

    -- Standard Start of API savepoint
    SAVEPOINT Generate_Taxes_PVT;

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

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_debug_info := 'Step 1a: Delete data from previous tax Generation/Calculation';
    -- logging message
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );
    Delete_PreviousTaxLines (
         p_ship_header_id => p_ship_header_id,
         x_return_status  => l_return_status
    );
    -- If any errors happen abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Getting all Shipment Information to send to Hook
    l_debug_info := 'Getting all Shipment Information to send to Hook';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info);


    l_debug_info := 'Getting Shipment Header Information.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );

    OPEN  Shipment_Header(p_ship_header_id);
    FETCH Shipment_Header INTO l_ship_header_rec;
    CLOSE Shipment_Header;

    --Getting Shipment Line Group Information
    l_debug_info := 'Getting Shipment Line Group Information.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );

    SELECT *
    BULK COLLECT INTO l_ship_groups_tbl
    FROM inl_ship_line_groups lg
    WHERE lg.ship_header_id = p_ship_header_id
    order by ship_line_group_id;

    l_debug_info := sql%rowcount||' records have been retrieved.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );

    --Getting Shipment Line Information
    l_debug_info := 'Getting Shipment Line Information.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );

    SELECT *
    BULK COLLECT INTO l_ship_lines_tbl
    FROM inl_adj_ship_lines_v sl
    WHERE sl.ship_header_id = p_ship_header_id
    order by sl.ship_line_group_id, sl.ship_line_id;

    l_debug_info := sql%rowcount||' records have been retrieved.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );

    --Getting Charge Line Information
    l_debug_info := 'Getting Charge Line Information.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );

    OPEN  charge_ln(p_ship_header_id);
    FETCH charge_ln
        BULK COLLECT INTO l_charge_lines_tbl
    ;
    CLOSE charge_ln;

    l_debug_info := sql%rowcount||' records have been retrieved.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );

    l_debug_info := ' Generating taxes from hook (inl_custom_pub.Get_Taxes).';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );

    inl_custom_pub.Get_Taxes(
        p_ship_header_rec             => l_ship_header_rec,
        p_ship_ln_groups_tbl          => l_ship_groups_tbl,
        p_ship_lines_tbl              => l_ship_lines_tbl,
        p_charge_lines_tbl            => l_charge_lines_tbl,
        x_tax_ln_tbl                  => l_tax_ln_tbl,
        x_override_default_processing => l_override_default_processing,
        x_return_status               => l_return_status
    );

    -- If any errors happen abort the process.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF NOT (l_override_default_processing) THEN
        l_debug_info := 'Calls the rotine to generate tax according parameter: ';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name   => g_module_name,
            p_procedure_name=> l_api_name,
            p_debug_info    => l_debug_info
        );
        IF p_source = 'PO' THEN
            Generate_TaxesFromPO(
                p_ship_header_id => p_ship_header_id,
                p_tax_ln_tbl     => l_tax_ln_tbl,
                x_return_status  => l_return_status
            );
            -- If any errors happen abort the process.
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;

    IF ( NVL(l_tax_ln_tbl.COUNT,0) > 0) THEN
        -- Persists the generated taxes
        l_debug_info := 'Persists the generated taxes';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        );

        FOR i IN l_tax_ln_tbl.FIRST..l_tax_ln_tbl.LAST LOOP
            --Insert IN INL_TAX_LINES getting ID from sequence
            l_debug_info := 'Insert IN INL_TAX_LINES getting ID from sequence';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info
            );

            SELECT inl_tax_lines_s.NEXTVAL
            INTO l_tax_line_id
            FROM DUAL;

            SELECT  NVL(MAX(tl.tax_line_num),0)+1
            INTO    l_tax_line_num
            FROM inl_tax_lines tl
            WHERE tl.ship_header_id = l_tax_ln_tbl(i).ship_header_id
            ;

            --Inserting record in INL_TAX_LINES
            l_debug_info := 'Inserting record in INL_TAX_LINES';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info
            );

            INSERT
            INTO inl_tax_lines (
                tax_line_id             ,                 /* 01 */
                tax_line_num            ,                 /* 02 */
                tax_code                ,                 /* 03 */
                ship_header_id          ,                 /* 04 */
                adjustment_num          ,                 /* 06 */
                source_parent_table_name,                 /* 08 */
                source_parent_table_id  ,                 /* 09 */
                tax_amt                 ,                 /* 10 */
                nrec_tax_amt            ,                 /* 11 */
                currency_code           ,                 /* 12 */
                currency_conversion_type,                 /* 13 */
                currency_conversion_date,                 /* 14 */
                currency_conversion_rate,                 /* 15 */
                tax_amt_included_flag   ,                 /* 16 */
                created_by              ,                 /* 17 */
                creation_date           ,                 /* 18 */
                last_updated_by         ,                 /* 19 */
                last_update_date        ,                 /* 20 */
                last_update_login                         /* 21 */
            )
            VALUES (
                l_tax_line_id                           , /* 01 */
                l_tax_line_num                          , /* 02 */
                l_tax_ln_tbl(i).tax_code                , /* 03 */
                l_tax_ln_tbl(i).ship_header_id          , /* 04 */
                0                                       , /* 06 */
                l_tax_ln_tbl(i).source_parent_table_name, /* 08 */
                l_tax_ln_tbl(i).source_parent_table_id  , /* 09 */
                l_tax_ln_tbl(i).tax_amt                 , /* 10 */
                l_tax_ln_tbl(i).nrec_tax_amt            , /* 11 */
                l_tax_ln_tbl(i).currency_code           , /* 12 */
                l_tax_ln_tbl(i).currency_conversion_type, /* 13 */
                l_tax_ln_tbl(i).currency_conversion_date, /* 14 */
                l_tax_ln_tbl(i).currency_conversion_rate, /* 15 */
                l_tax_ln_tbl(i).tax_amt_included_flag   , /* 16 */
                fnd_global.user_id                      , /* 17 */
                SYSDATE                                 , /* 18 */
                fnd_global.user_id                      , /* 19 */
                SYSDATE                                 , /* 20 */
                fnd_global.login_id                       /* 21 */
            );
            --Inserting record in INL_ASSOCIATIONS
            l_debug_info := 'Inserting record in INL_ASSOCIATIONS';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info
            );

            INSERT
            INTO inl_associations (
                association_id                          , /* 01 */
                ship_header_id                          , /* 02 */
                from_parent_table_name                  , /* 03 */
                from_parent_table_id                    , /* 04 */
                to_parent_table_name                    , /* 05 */
                to_parent_table_id                      , /* 06 */
                allocation_basis                        , /* 07 */
                allocation_uom_code                     , /* 08 */
                created_by                              , /* 09 */
                creation_date                           , /* 10 */
                last_updated_by                         , /* 11 */
                last_update_date                        , /* 12 */
                last_update_login                         /* 13 */
            )
            VALUES (
                inl_associations_s.NEXTVAL              , /* 01 */
                l_tax_ln_tbl(i).ship_header_id          , /* 02 */
                'INL_TAX_LINES'                         , /* 03 */
                l_tax_line_id                           , /* 04 */
                l_tax_ln_tbl(i).to_parent_table_name    , /* 05 */
                l_tax_ln_tbl(i).to_parent_table_id      , /* 06 */
                'VALUE'                                 , /* 07 */
                null                                    , /* 08 */
                fnd_global.user_id                      , /* 09 */
                SYSDATE                                 , /* 10 */
                fnd_global.user_id                      , /* 11 */
                SYSDATE                                 , /* 12 */
                fnd_global.login_id                       /* 13 */
            );
        END LOOP;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (p_module_name => g_module_name,
                                 p_procedure_name => l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (p_module_name => g_module_name,
                                        p_procedure_name => l_api_name);
        ROLLBACK TO Generate_Taxes_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Generate_Taxes_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Generate_Taxes_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => g_pkg_name,
                                  p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
END Generate_Taxes;

--==============================================================================
--==============================================================================
--==============================================================================
-- Utility name: Get_Event_Class_Code
--
-- Type        : Private
--
-- Function    : It will get the event class code required to call
--               the eTax services based on the category code of the shipment type.
--               These event class code is LCM specific.
--               eTax will convert this event class code to the tax class
--               code used by eTax.
--
-- Pre-reqs    : None
--
-- Parameters  :
-- IN          : p_ship_type_id       IN         NUMBER,
--
-- OUT         : x_return_status    OUT NOCOPY VARCHAR2,
--               x_event_class_code OUT NOCOPY VARCHAR2)
--
-- Version     : Current version 1.0
--
-- Notes       :
   PROCEDURE Get_Event_Class_Code(p_ship_type_id      IN  NUMBER,
                                  x_return_status     OUT NOCOPY VARCHAR2,
                                  x_event_class_code  OUT NOCOPY VARCHAR2)
   IS
      l_function_name     CONSTANT VARCHAR2(100) := 'Get_Event_Class_Code ';
      l_debug_info                 VARCHAR2(240);
      l_category_code              VARCHAR2(100);

   BEGIN
-- logging message
      INL_LOGGING_PVT.Log_BeginProc (p_module_name    => g_module_name,
                                     p_procedure_name => l_function_name);

      x_return_status := FND_API.G_RET_STS_SUCCESS;

-- get category to derivate Event_Class_Code
      x_Event_Class_Code := 'ARRIVALS';
-- logging message
      INL_LOGGING_PVT.Log_EndProc (p_module_name    => g_module_name,
                                        p_procedure_name => l_function_name);
   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
-- logging message
       INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                            p_procedure_name => l_function_name);
       x_return_status := FND_API.G_RET_STS_ERROR;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
-- logging message
       INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                              p_procedure_name => l_function_name);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     WHEN OTHERS THEN
-- logging message
       INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                              p_procedure_name => l_function_name);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_function_name);
       END IF;
   END Get_Event_Class_Code;


-- Utility name: Get_Po_Info
--
-- Type        : Private
--
-- Function    : It get the Po Info.
--
-- Pre-reqs    : None
--
-- Parameters  :
-- IN          : p_po_line_location_id       IN         NUMBER,
--
-- OUT         : x_return_status             OUT NOCOPY VARCHAR2,
--               x_po_header_id              OUT NOCOPY NUMBER,
--               x_po_header_curr_conv_rate  OUT NOCOPY NUMBER
--
-- Version     : Current version 1.0
--
-- Notes       :

   PROCEDURE Get_Po_Info(p_po_line_location_id      IN  NUMBER,
                         x_return_status            OUT NOCOPY VARCHAR2,
                         x_po_header_id             OUT NOCOPY NUMBER,
                         x_po_header_curr_conv_rate OUT NOCOPY NUMBER) IS
      l_debug_info                 VARCHAR2(240);
      l_function_name     CONSTANT VARCHAR2(100) := 'Get_Po_Info ';
   BEGIN
-- logging message
      INL_LOGGING_PVT.Log_BeginProc (p_module_name    => g_module_name,
                                          p_procedure_name => l_function_name);

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- get PO_Header_id
      SELECT pll.po_header_id, nvl(ph.rate ,1)
        INTO x_po_header_id,   x_po_header_curr_conv_rate
        FROM po_line_locations pll, po_headers ph
       WHERE pll.line_location_id = P_Po_Line_Location_Id
         AND pll.po_header_id = ph.po_header_id
         AND rownum = 1;

-- logging message
      INL_LOGGING_PVT.Log_EndProc (p_module_name    => g_module_name,
                                        p_procedure_name => l_function_name);

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
-- logging message
       INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                            p_procedure_name => l_function_name);
       x_return_status := FND_API.G_RET_STS_ERROR;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
-- logging message
       INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                              p_procedure_name => l_function_name);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     WHEN OTHERS THEN
       INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                              p_procedure_name => l_function_name);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_function_name);
       END IF;
   END Get_Po_Info;

-- Utility name: Populate_Headers_GT
--
-- Type        : Private
--
-- Function    : It populate the temporary zx table: zx_trx_headers_gt
--               but it remove any record of the same ship_Header_id before
--
-- Pre-reqs    : None
--
-- Parameters  :
-- IN          : p_etax_already_called_flag  IN VARCHAR2
--               p_event_class_code          IN VARCHAR2
--
-- OUT           x_event_type_code           OUT NOCOPY VARCHAR2,
--               x_return_status             OUT NOCOPY VARCHAR2
--
-- Version     : Current version 1.0
--
-- Notes       :
   PROCEDURE Populate_Headers_GT(p_etax_already_called_flag  IN VARCHAR2,
                                 p_event_class_code          IN VARCHAR2,
                                 x_event_type_code           OUT NOCOPY VARCHAR2,
                                 x_return_status             OUT NOCOPY VARCHAR2)IS

      l_function_name   CONSTANT VARCHAR2(100) := 'Populate_Headers_GT ';
      l_debug_info                 VARCHAR2(240);
      l_application_id             NUMBER;

      -- This flag is always N except when the calculate service is called for
      -- quote for the recurring invoices and distributions sets.
      l_quote_flag                 VARCHAR2(1);

      l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_ship_to_organization_id    NUMBER;
      l_ledger_id                  NUMBER;
      l_tax_event_type_code        VARCHAR2(30);
      l_doc_level_recalc_flag      VARCHAR2(1):='Y';
      l_step VARCHAR2(10);
   BEGIN
-- logging message
      INL_LOGGING_PVT.Log_BeginProc (p_module_name    => g_module_name,
                                          p_procedure_name => l_function_name);

      x_return_status := FND_API.G_RET_STS_SUCCESS;

    -------------------------------------------------------------------
      l_debug_info := 'Step 3: Populate product specific attributes';
    -------------------------------------------------------------------
      l_application_id := 9004;   -- Landed Cost Management
    -------------------------------------------------------------------
      l_debug_info := 'Step 6: Get Ship to party id';
    -------------------------------------------------------------------
-- logging message
      INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                          p_procedure_name => l_function_name,
                                          p_debug_info     => l_debug_info);

      l_ship_to_organization_id := l_ship_header_rec.organization_id;

    -------------------------------------------------------------------
      l_debug_info := 'Step 7: Get ledger_id. l_ship_header_rec.inv_org_id: '||l_ship_header_rec.organization_id;
    -------------------------------------------------------------------
-- logging message
      INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                          p_procedure_name => l_function_name,
                                          p_debug_info     => l_debug_info);
      l_step:='02';
      SELECT ood.set_of_books_id
        INTO l_ledger_id
        FROM org_organization_definitions ood
       WHERE ood.organization_id = l_ship_header_rec.organization_id
         AND rownum             = 1;
      l_step:='02a';
    -------------------------------------------------------------------
      l_debug_info := 'Step 7a: Get tax_event_type_code';
-- logging message
      INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                          p_procedure_name => l_function_name,
                                          p_debug_info     => l_debug_info);
    -------------------------------------------------------------------
      IF p_etax_already_called_flag = 'Y' THEN
         l_tax_event_type_code := 'UPDATE';
         x_event_type_code := 'ARRIVAL UPDATED';
      ELSE
         l_tax_event_type_code := 'CREATE';
         x_event_type_code := 'ARRIVAL CREATED';
      END IF;
      l_step:='03';
    -------------------------------------------------------------------
      l_debug_info := 'Step 8: Populate zx_trx_headers_gt';
    -------------------------------------------------------------------
      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
-- logging message
         INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                             p_procedure_name => l_function_name,
                                             p_debug_info     => l_debug_info);
-- Delete records of the current shipment
         DELETE FROM zx_trx_headers_gt
          WHERE trx_id=l_ship_header_rec.ship_header_id;
-- Insert records
      l_step:='04';

         INSERT INTO zx_trx_headers_gt(
/*01*/               internal_organization_id,
/*02*/               internal_org_location_id,
/*03*/               application_id,
/*04*/               entity_code,
/*05*/               event_class_code,
/*06*/               event_type_code,
/*07*/               trx_id,
/*08*/               hdr_trx_user_key1,
/*09*/               hdr_trx_user_key2,
/*10*/               hdr_trx_user_key3,
/*11*/               hdr_trx_user_key4,
/*12*/               hdr_trx_user_key5,
/*13*/               hdr_trx_user_key6,
/*14*/               trx_date,
/*15*/               trx_doc_revision,
/*16*/               ledger_id,
/*17*/               trx_currency_code,
/*18*/               currency_conversion_date,
/*19*/               currency_conversion_rate,
/*20*/               currency_conversion_type,
/*21*/               minimum_accountable_unit,
/*22*/               precision,
/*23*/               legal_entity_id,
/*24*/               rounding_ship_to_party_id,
/*25*/               rounding_ship_from_party_id,
/*26*/               rounding_bill_to_party_id,
/*27*/               rounding_bill_from_party_id,
/*28*/               rndg_ship_to_party_site_id,
/*29*/               rndg_ship_from_party_site_id,
/*30*/               rndg_bill_to_party_site_id,
/*31*/               rndg_bill_from_party_site_id,
/*32*/               establishment_id,
/*33*/               receivables_trx_type_id,
/*34*/               related_doc_application_id,
/*35*/               related_doc_entity_code,
/*36*/               related_doc_event_class_code,
/*37*/               related_doc_trx_id,
/*38*/               rel_doc_hdr_trx_user_key1,
/*39*/               rel_doc_hdr_trx_user_key2,
/*40*/               rel_doc_hdr_trx_user_key3,
/*41*/               rel_doc_hdr_trx_user_key4,
/*42*/               rel_doc_hdr_trx_user_key5,
/*43*/               rel_doc_hdr_trx_user_key6,
/*44*/               related_doc_number,
/*45*/               related_doc_date,
/*46*/               default_taxation_country,
/*47*/               quote_flag,
/*48*/               ctrl_total_hdr_tx_amt,
/*49*/               trx_number,
/*50*/               trx_description,
/*51*/               trx_communicated_date,
/*52*/               batch_source_id,
/*53*/               batch_source_name,
/*54*/               doc_seq_id,
/*55*/               doc_seq_name,
/*56*/               doc_seq_value,
/*57*/               trx_due_date,
/*58*/               trx_type_description,
/*59*/               document_sub_type,
/*60*/               supplier_tax_invoice_number,
/*61*/               supplier_tax_invoice_date ,
/*62*/               supplier_exchange_rate,
/*63*/               tax_invoice_date,
/*64*/               tax_invoice_number,
/*65*/               tax_event_class_code,
/*66*/               tax_event_type_code,
/*67*/               doc_event_status,
/*68*/               rdng_ship_to_pty_tx_prof_id,
/*69*/               rdng_ship_from_pty_tx_prof_id,
/*70*/               rdng_bill_to_pty_tx_prof_id,
/*71*/               rdng_bill_from_pty_tx_prof_id,
/*72*/               rdng_ship_to_pty_tx_p_st_id,
/*73*/               rdng_ship_from_pty_tx_p_st_id,
/*74*/               rdng_bill_to_pty_tx_p_st_id,
/*75*/               rdng_bill_from_pty_tx_p_st_id,
/*76*/               bill_third_pty_acct_id,
/*77*/               bill_third_pty_acct_site_id,
/*78*/               ship_third_pty_acct_id,
/*79*/               ship_third_pty_acct_site_id,
/*80*/               doc_level_recalc_flag
         )
         VALUES (
/*01*/               l_ship_header_rec.organization_id,                --internal_organization_id
/*02*/               l_ship_header_rec.location_id,                    --internal_org_location_id
/*03*/               l_application_id,                                      --application_id
/*04*/               G_ENTITY_CODE,                                         --entity_code
/*05*/               p_event_class_code,                                    --event_class_code
/*06*/               x_event_type_code,                                     --event_type_code
/*07*/               l_ship_header_rec.ship_header_id,                   --trx_id
/*08*/               NULL,                                                  --hdr_trx_user_key1
/*09*/               NULL,                                                  --hdr_trx_user_key2
/*10*/               NULL,                                                  --hdr_trx_user_key3
/*11*/               NULL,                                                  --hdr_trx_user_key4
/*12*/               NULL,                                                  --hdr_trx_user_key5
/*13*/               NULL ,                                                  --hdr_trx_user_key6
/*14*/               l_ship_header_rec.ship_date,                        --trx_date
/*15*/               NULL,                                                  --trx_doc_revision
/*16*/               l_ledger_id,                                           --ledger_id
/*17*/               null,                                                  -- 07/2007 Currency columns was transfer to lines l_ship_header_rec.CURRENCY_CODE,
/*18*/               null,                                                  -- l_ship_header_rec.CURRENCY_CONVERSION_DATE,
/*19*/               null,                                                  -- l_ship_header_rec.CURRENCY_CONVERSION_RATE,
/*20*/               null,                                                  -- l_ship_header_rec.CURRENCY_CONVERSION_TYPE,
/*21*/               null,                                                  -- l_minimum_accountable_unit,
/*22*/               null,                                                  -- l_precision,
/*23*/               l_ship_header_rec.legal_entity_id,                --legal_entity_id
/*24*/               l_ship_to_organization_id,                             --rounding_ship_to_party_id
/*25*/               NULL,                                                  --rounding_ship_from_party_id
/*26*/               NULL,                                                  --rounding_bill_to_party_id
/*27*/               NULL,                                                  --rounding_bill_from_party_id
/*28*/               NULL,                                                  --rndg_ship_to_party_site_id
/*29*/               NULL,                                                  --rndg_ship_from_party_site_id
/*30*/               NULL,                                                  --rndg_bill_to_party_site_id
/*31*/               NULL,                                                  --rndg_bill_from_party_site_id
/*32*/               NULL,                                                  --establishment_id
/*33*/               NULL,                                                  --receivables_trx_type_id
/*34*/               NULL,                                                  --related_doc_application_id
/*35*/               NULL,                                                  --related_doc_entity_code
/*36*/               NULL,                                                  --related_doc_event_class_code
/*37*/               NULL,                                                  --related_doc_trx_id
/*38*/               NULL,                                                  --rel_doc_hdr_trx_user_key1
/*39*/               NULL,                                                  --rel_doc_hdr_trx_user_key2
/*40*/               NULL,                                                  --rel_doc_hdr_trx_user_key3
/*41*/               NULL,                                                  --rel_doc_hdr_trx_user_key4
/*42*/               NULL,                                                  --rel_doc_hdr_trx_user_key5
/*43*/               NULL,                                                  --rel_doc_hdr_trx_user_key6
/*44*/               NULL,                                                  --related_doc_number
/*45*/               NULL,                                                  --related_doc_date
/*46*/               l_ship_header_rec.taxation_country,               --default_taxation_country
/*47*/               l_quote_flag,                                          --quote_flag
/*48*/               NULL,                                                  --ctrl_total_hdr_tx_amt
/*49*/               l_ship_header_rec.ship_num,                         --trx_number
/*50*/               NULL, --'INL_SHIPMENT',                                        --trx_description
/*51*/               NULL,                                                  --trx_communicated_date
/*52*/               NULL,                                                  --batch_source_id
/*53*/               NULL,                                                  --batch_source_name
/*54*/               NULL,                                                  --doc_seq_id
/*55*/               NULL,                                                  --doc_seq_name
/*56*/               NULL,                                                  --doc_seq_value
/*57*/               NULL,                                                  --trx_due_date
/*58*/               NULL,                                                  --trx_type_description
/*59*/               l_ship_header_rec.document_sub_type,              --document_sub_type
/*60*/               NULL,                                                  --supplier_tax_invoice_number
/*61*/               NULL,                                                  --supplier_tax_invoice_date
/*62*/               NULL,                                                  --supplier_exchange_rate
/*63*/               NULL,                                                  --tax_invoice_date
/*64*/               NULL,                                                  --tax_invoice_number
/*65*/               NULL,                                                  --tax_event_class_code
/*66*/               l_tax_event_type_code,                                 --tax_event_type_code
/*67*/               NULL,                                                  --doc_event_status
/*68*/               NULL,                                                  --rdng_ship_to_pty_tx_prof_id
/*69*/               NULL,                                                  --rdng_ship_from_pty_tx_prof_id
/*70*/               NULL,                                                  --rdng_bill_to_pty_tx_prof_id
/*71*/               NULL,                                                  --rdng_bill_from_pty_tx_prof_id
/*72*/               NULL,                                                  --rdng_ship_to_pty_tx_p_st_id
/*73*/               NULL,                                                  --rdng_ship_from_pty_tx_p_st_id
/*74*/               NULL,                                                  --rdng_bill_to_pty_tx_p_st_id
/*75*/               NULL,                                                  --rdng_bill_from_pty_tx_p_st_id
/*76*/               NULL,                                                  --bill_third_pty_acct_id
/*77*/               NULL,                                                  --bill_third_pty_acct_site_id
/*78*/               NULL,                                                  --ship_third_pty_acct_id
/*79*/               NULL,                                                  --ship_third_pty_acct_site_id
/*80*/               l_doc_level_recalc_flag
         );
      l_step:='05';
      END IF;
-- logging message
      INL_LOGGING_PVT.Log_EndProc (p_module_name    => g_module_name,
                                        p_procedure_name => l_function_name);

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
-- logging message
       INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                            p_procedure_name => l_function_name||l_step);
       x_return_status := FND_API.G_RET_STS_ERROR;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
-- logging message
       INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                              p_procedure_name => l_function_name||l_step);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     WHEN OTHERS THEN
-- logging message
       INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                              p_procedure_name => l_function_name||l_step);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_function_name);
       END IF;

   END Populate_Headers_GT;

-- Utility name: Populate_Lines_GT
--
-- Type        : Private
--
-- Function    : It populate zx_transaction_lines_gt. The records of this table will be processed for
--               zx_api_pub.calculate_tax procedure to generate taxes (zx_lines)
--
-- Pre-reqs    : None
--
-- Parameters  :
-- IN          : p_event_class_code        IN VARCHAR2,
--               p_line_number             IN NUMBER DEFAULT NULL,
--
-- OUT         : x_return_status             OUT NOCOPY VARCHAR2
--
-- Version     : Current version 1.0
--
-- Notes       :
   PROCEDURE Populate_Lines_GT(p_event_class_code IN VARCHAR2,
                               p_line_number      IN NUMBER DEFAULT NULL,
                               x_return_status    OUT NOCOPY VARCHAR2)
   IS
      l_function_name         CONSTANT VARCHAR2(100) := 'Populate_Lines_GT ';
      l_debug_info                     VARCHAR2(240);

      -- This structure to populate all the lines information previous to insert
      -- in eTax global temporary table.
      TYPE Trans_Lines_Tab_Type IS TABLE OF zx_transaction_lines_gt%ROWTYPE;
      trans_lines                     Trans_Lines_Tab_Type := Trans_Lines_Tab_Type();
      l_ctrl_hdr_tx_appl_flag         VARCHAR2(1);
      l_line_level_action             VARCHAR2(30);
      l_line_class                    VARCHAR2(30);
      l_product_org_id                NUMBER :=l_ship_header_rec.organization_id;
      l_bill_to_location_id           NUMBER;
      -- This variables for PO doc info
      l_ref_doc_application_id        NUMBER;
      l_ref_doc_entity_code           VARCHAR2(30);
      l_ref_doc_event_class_code      VARCHAR2(30);
      l_ref_doc_line_quantity         NUMBER;
      l_po_header_curr_conv_rate      NUMBER;
      l_ref_doc_trx_level_type        VARCHAR2(30);
      l_ref_doc_line_id               NUMBER;
      l_ref_doc_trx_id                NUMBER;
      l_line_amt_includes_tax_flag    VARCHAR2(1);
      l_line_amount                   NUMBER;
      l_fob_point                     VARCHAR2(30);
      l_ship_from_location_id         NUMBER;
      l_dflt_tax_class_code           VARCHAR2(30);
      l_allow_tax_code_override       VARCHAR2(10);
      l_ship_line_type_code           VARCHAR2(30);
      l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_to_parent_table_name          VARCHAR2(30);
      l_to_parent_table_id            NUMBER;
      l_precision                     NUMBER(1);
      l_minimum_accountable_unit      NUMBER;

   BEGIN
-- logging message
      INL_LOGGING_PVT.Log_BeginProc (p_module_name    => g_module_name,
                                          p_procedure_name => l_function_name);

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -----------------------------------------------------------------
      l_debug_info := 'IN Populating shipment lines collection';
-- logging message
      INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                          p_procedure_name => l_function_name,
                                          p_debug_info     => l_debug_info);
      -----------------------------------------------------------------
      l_debug_info := 'Step 1: Get l_bill_to_location_id for org_id';
-- logging message
      INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                          p_procedure_name => l_function_name,
                                          p_debug_info     => l_debug_info);
      ----------------------------------------------------------------------
      -- if is a dispatch the location is the same from ship from in a Arrival
      -- else it is null
      ----------------------------------------------------------------------
      l_debug_info := 'Step 2: Go through taxable lines'||' l_ship_line_list.COUNT: '||l_ship_line_list.COUNT;
-- logging message
      INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                          p_procedure_name => l_function_name,
                                          p_debug_info     => l_debug_info);
      ----------------------------------------------------------------------
      IF ( l_ship_line_list.COUNT > 0) THEN
         -- For non-tax only lines
         trans_lines.EXTEND(l_ship_line_list.COUNT);

-- loop in all lines of current shipment
         FOR i IN l_ship_line_list.FIRST..l_ship_line_list.LAST LOOP
          /* 10/07/07 Currency columns was transfer to lines   */
            -------------------------------------------------------------------
            l_debug_info := 'Step 3: Get transaction line currency details';
            -------------------------------------------------------------------
            IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               BEGIN
                  SELECT NVL(precision, 0), NVL(minimum_accountable_unit,(1/power(10,precision)))
                    INTO l_precision, l_minimum_accountable_unit
                    FROM fnd_currencies
                   WHERE currency_code = l_ship_line_list(i).currency_code;
               EXCEPTION
                  WHEN OTHERS THEN
                     IF (SQLCODE <> -20001) THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- logging message
                       INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                                              p_procedure_name => l_function_name);
                     END IF;
                     APP_EXCEPTION.RAISE_EXCEPTION;
               END;
            END IF;
-- For now only ARRIVALS are treaded
            IF P_Event_Class_Code = 'ARRIVALS'
            then

               IF l_ship_line_list(i).ship_to_organization_id IS NULL THEN
                  trans_lines(i).ship_to_party_id               := l_ship_header_rec.organization_id;
               ELSE
                  trans_lines(i).ship_to_party_id               := l_ship_line_list(i).ship_to_organization_id;
               END IF;

               IF l_ship_line_list(i).ship_from_party_id IS NULL THEN
                  trans_lines(i).ship_from_party_id             := l_ship_line_list(i).party_id;
               ELSE
                  trans_lines(i).ship_from_party_id             := l_ship_line_list(i).ship_from_party_id;
               END IF;
               IF l_ship_line_list(i).ship_from_party_site_id IS NULL THEN
                  trans_lines(i).ship_from_party_site_id        := l_ship_line_list(i).party_site_id;
               ELSE
                  trans_lines(i).ship_from_party_site_id        := l_ship_line_list(i).ship_from_party_site_id;
               END IF;
               IF l_ship_line_list(i).ship_to_location_id IS NULL THEN
                  trans_lines(i).ship_to_location_id            := l_ship_header_rec.location_id;
               ELSE
                  trans_lines(i).ship_to_location_id            := l_ship_line_list(i).ship_to_location_id;
               END IF;
               trans_lines(i).ship_from_location_id          := l_ship_from_location_id;
            ELSE
               trans_lines(i).ship_to_party_id               := l_ship_line_list(i).ship_to_organization_id;
               trans_lines(i).ship_from_party_id             := l_ship_line_list(i).ship_from_party_id;
               trans_lines(i).ship_from_party_site_id        := l_ship_line_list(i).ship_from_party_site_id;
               trans_lines(i).ship_to_location_id            := l_ship_line_list(i).ship_to_location_id;
            END IF;
            ----------------------------------------------------------------------
            l_debug_info := 'Step 6: Get fob_lookup_code from po_vendor_sites';
-- logging message
            INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                                p_procedure_name => l_function_name,
                                                p_debug_info     => l_debug_info);
            ----------------------------------------------------------------------
            BEGIN
               SELECT fob_lookup_code   -- From lookup FOB
                 INTO l_fob_point
                 FROM po_vendor_sites
                WHERE party_site_id = l_ship_line_list(i).party_site_id
                  AND rownum = 1;
            EXCEPTION
               WHEN no_data_found THEN
                  l_fob_point := null;
            END;
            -------------------------------------------------------------------
            l_debug_info := 'Step 7: Get ship_line_type_code and default Fiscal Classifications for line number:'||
                             l_ship_line_list(i).ship_line_num;
-- logging message
            INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                                p_procedure_name => l_function_name,
                                                p_debug_info     => l_debug_info);
            -------------------------------------------------------------------
            IF l_ship_line_list(i).source = 'CHARGE' THEN
               l_ship_line_type_code      := 'MISC';
            ELSE
               l_ship_line_type_code      := 'ITEM';
            END IF;
            -------------------------------------------------------------------
            l_debug_info := 'Step 8: Get line_level_action for line number:'
                          || l_ship_line_list(i).ship_line_num
                          ||'l_ship_line_list(i).tax_already_calculated_flag'|| l_ship_line_list(i).tax_already_calculated_flag
                          ;

-- logging message
            INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                                p_procedure_name => l_function_name,
                                                p_debug_info     => l_debug_info);
            -------------------------------------------------------------------
            IF nvl(l_ship_line_list(i).tax_already_calculated_flag,'N') = 'Y' THEN
               l_line_level_action := 'UPDATE';
            ELSE
               l_line_level_action := 'CREATE';
            END IF;
            ------------------------------------------------------------------
            l_debug_info := 'Step 9: Get Additional PO matched  info (l_line_level_action = '||l_line_level_action||')';
-- logging message
            INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                                p_procedure_name => l_function_name,
                                                p_debug_info     => l_debug_info);
            ------------------------------------------------------------------
-- For now src_type_code can be PO = PO Shipment, RMA = Return Material Authorization Line OR IR = Internal Requisition
            IF l_ship_line_list(i).src_type_code IS NOT NULL THEN

               IF l_ship_line_list(i).src_type_code='PO' AND l_ship_line_list(i).src_id IS NOT NULL THEN
                  Get_PO_Info(
                     p_po_line_location_id         => l_ship_line_list(i).src_id,
                     x_po_header_id                => l_ref_doc_trx_id,
                     x_po_header_curr_conv_rate    => l_po_header_curr_conv_rate,
                     x_return_status               => l_return_status);

                  -- If any errors happen abort API.
                  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                  l_ref_doc_trx_level_type := 'SHIPMENT';
                  l_ref_doc_line_id := l_ship_line_list(i).src_id;
               ELSE
                  l_ref_doc_application_id       := Null;
                  l_ref_doc_entity_code          := Null;
                  l_ref_doc_event_class_code     := Null;
                  l_ref_doc_line_quantity        := Null;
                  l_product_org_id               := Null;
                  l_ref_doc_trx_id               := Null;
                  l_ref_doc_trx_level_type       := Null;
                  l_ref_doc_line_id              := Null;
               END IF;
            ELSE
               l_ref_doc_application_id       := Null;
               l_ref_doc_entity_code          := Null;
               l_ref_doc_event_class_code     := Null;
               l_ref_doc_line_quantity        := Null;
               l_product_org_id               := Null;
               l_ref_doc_trx_id               := Null;
               l_ref_doc_trx_level_type       := Null;
               l_ref_doc_line_id              := Null;
            END IF;
            ------------------------------------------------------------------
            l_debug_info := 'Step 9: Get line_amt_includes_tax_flag';
-- logging message
            INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                                p_procedure_name => l_function_name,
                                                p_debug_info     => l_debug_info);
            ------------------------------------------------------------------
            l_line_amt_includes_tax_flag := 'S';
            ------------------------------------------------------------------
            l_debug_info := 'Step 10: Get ctrl_hdr_tx_appl_flag';
            ------------------------------------------------------------------
            l_ctrl_hdr_tx_appl_flag := 'N';
            ------------------------------------------------------------------
            l_line_amount := nvl(l_ship_line_list(i).unit_price * l_ship_line_list(i).line_qty,0);
            ------------------------------------------------------------------
            l_debug_info := 'Step 10.1: Get line_class';
-- logging message
            INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                                p_procedure_name => l_function_name,
                                                p_debug_info     => l_debug_info);
            ------------------------------------------------------------------
            l_line_Class := 'STANDARD'; -- Possible values are 'STANDARD', 'ADJUSTMENT', 'APPLICATION', 'UNAPPLICATION', 'AMOUNT_MATCHED'
            ------------------------------------------------------------------
            l_debug_info := 'Step 12: Populate pl/sql table';
-- logging message
            INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                                p_procedure_name => l_function_name,
                                                p_debug_info     => l_debug_info);
            ------------------------------------------------------------------
-- Will populate a dinamic table to include in zx_transaction_lines_gt
            IF (l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
               trans_lines(i).application_id                 := 9004;
               trans_lines(i).entity_code                    := G_ENTITY_CODE;
               trans_lines(i).event_class_code               := p_event_class_code;
               trans_lines(i).trx_line_precision             := l_precision;
               trans_lines(i).trx_line_mau                   := l_minimum_accountable_unit;
               trans_lines(i).trx_line_currency_code         := l_ship_line_list(i).currency_code          ;
               trans_lines(i).trx_line_currency_conv_rate    := l_ship_line_list(i).currency_conversion_rate ;
               trans_lines(i).trx_line_currency_conv_date    := l_ship_line_list(i).currency_conversion_date;
               trans_lines(i).trx_line_currency_conv_type    := l_ship_line_list(i).currency_conversion_type;
               trans_lines(i).trx_id                         := l_ship_line_list(i).ship_header_id;
               trans_lines(i).trx_level_type                 := l_ship_line_list(i).SOURCE;
               trans_lines(i).trx_line_id                    := l_ship_line_list(i).ship_line_id;
               trans_lines(i).line_level_action              := l_line_level_action;
               trans_lines(i).line_class                     := l_line_class;
               trans_lines(i).trx_receipt_date               := l_ship_header_rec.ship_date;
               trans_lines(i).trx_line_type                  := l_ship_line_type_code;
               trans_lines(i).trx_line_date                  := l_ship_header_rec.ship_date;
               trans_lines(i).trx_business_category          := l_ship_line_list(i).trx_business_category;
               trans_lines(i).line_intended_use              := l_ship_line_list(i).intended_use;
               trans_lines(i).user_defined_fisc_class        := l_ship_line_list(i).user_def_fiscal_class;
               trans_lines(i).product_category               := l_ship_line_list(i).product_category;
               trans_lines(i).product_fisc_classification    := l_ship_line_list(i).product_fiscal_class;
               trans_lines(i).assessable_value               := 0; -- l_line_amount; --updated above
               trans_lines(i).line_amt                       := l_line_amount;
               trans_lines(i).trx_line_quantity              := l_ship_line_list(i).line_qty;
               trans_lines(i).unit_price                     := l_ship_line_list(i).unit_price;
               trans_lines(i).product_id                     := l_ship_line_list(i).inventory_item_id;
               trans_lines(i).product_org_id                 := nvl(l_product_org_id,l_ship_header_rec.organization_id);
               trans_lines(i).uom_code                       := l_ship_line_list(i).uom_code;
               trans_lines(i).product_type                   :=  l_ship_line_list(i).product_type;
               trans_lines(i).fob_point                      := l_fob_point;
               trans_lines(i).bill_from_party_id             := l_ship_line_list(i).bill_from_party_id     ;
               trans_lines(i).bill_from_party_site_id        := l_ship_line_list(i).bill_from_party_site_id;
               trans_lines(i).bill_to_party_id               := l_ship_line_list(i).bill_to_organization_id       ;
               trans_lines(i).bill_to_location_id            := l_ship_line_list(i).bill_to_location_id    ;
               trans_lines(i).poa_party_id                   := l_ship_line_list(i).poa_party_id           ;
               trans_lines(i).poa_party_site_id              := l_ship_line_list(i).poa_party_site_id      ;
               trans_lines(i).poo_party_id                   := l_ship_line_list(i).poo_organization_id           ;
               trans_lines(i).poo_location_id                := l_ship_line_list(i).poo_location_id        ;
               trans_lines(i).ref_doc_application_id         := l_ref_doc_application_id;
               trans_lines(i).ref_doc_entity_code            := l_ref_doc_entity_code;
               trans_lines(i).ref_doc_event_class_code       := l_ref_doc_event_class_code;
               trans_lines(i).ref_doc_trx_id                 := l_ref_doc_trx_id;
               trans_lines(i).ref_doc_trx_level_type         := l_ref_doc_trx_level_type;
               trans_lines(i).ref_doc_line_quantity          := l_ref_doc_line_quantity;
               trans_lines(i).ref_doc_line_id                := l_ref_doc_line_id;
               trans_lines(i).trx_line_number                := l_ship_line_list(i).ship_line_num;
               trans_lines(i).trx_line_description           := NULL; --'INL_SHIPMENT_LINE';
               trans_lines(i).trx_line_gl_date               := SYSDATE;
               trans_lines(i).product_description            := l_ship_line_list(i).inventory_item_id;--to report only
               trans_lines(i).line_amt_includes_tax_flag     := l_line_amt_includes_tax_flag;
               trans_lines(i).historical_flag                := 'N'; -- NVL(l_ship_header_rec.historical_flag, 'N');
               trans_lines(i).ctrl_hdr_tx_appl_flag          := l_ctrl_hdr_tx_appl_flag;
               trans_lines(i).ctrl_total_line_tx_amt         := NULL;
               trans_lines(i).source_application_id          := NULL;
               trans_lines(i).source_entity_code             := NULL;
               trans_lines(i).source_event_class_code        := NULL;
               trans_lines(i).source_trx_id                  := NULL;
               trans_lines(i).source_line_id                 := NULL;
               trans_lines(i).source_trx_level_type          := NULL;
               trans_lines(i).input_tax_classification_code  := l_ship_line_list(i).tax_classification_code;
            ------------------------------------------------------------------
               l_debug_info := 'Step 14: Populate pl/sql table: trans_lines(i).trx_line_id='||trans_lines(i).trx_line_id;
               -- logging message
               INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                              p_procedure_name => l_function_name,
                                              p_debug_info     => l_debug_info);
            ------------------------------------------------------------------
            END IF;
         END LOOP;
      END IF;
      IF ( l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
         -- if exist any row from this shipment it will be removed
         DELETE FROM zx_transaction_lines_gt
         WHERE trx_id= l_ship_header_rec.ship_header_id;
     -------------------------------------------------------------------
         l_debug_info := 'Step 15: Bulk Insert into global temp table';
     -------------------------------------------------------------------
         -- logging message
         INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                        p_procedure_name => l_function_name,
                                        p_debug_info     => l_debug_info);
         -- populate the table
         FORALL m IN trans_lines.FIRST..trans_lines.LAST
           INSERT INTO zx_transaction_lines_gt
           VALUES trans_lines(m);
     -------------------------------------------------------------------

         l_debug_info := 'Step 15: Populate pl/sql table inserted: '||sql%rowcount||' line(s)';
         -- logging message
         INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                        p_procedure_name => l_function_name,
                                        p_debug_info     => l_debug_info);
     -------------------------------------------------------------------
      END IF;
       -- logging message
      INL_LOGGING_PVT.Log_EndProc (p_module_name    => g_module_name,
                                   p_procedure_name => l_function_name);

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       -- logging message
       INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                       p_procedure_name => l_function_name);
       x_return_status := FND_API.G_RET_STS_ERROR;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       -- logging message
       INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                         p_procedure_name => l_function_name);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     WHEN OTHERS THEN
       -- logging message
       INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                         p_procedure_name => l_function_name);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_function_name);
       END IF;

   END Populate_Lines_GT;

-- Utility name: Adjust_Tax_Lines
--
-- Type        : Private
--
-- Function    : It makes adjusts (Insert, Delete or Both) in tax_line table.
--               For a given Ship_Header_Id DEL will remove all rows from this shipment of the
--               INL_tax_lines and from INL_associations
--               INS will insert in INL_tax_lines all lines from zx_lines
--               If the zx_line has recover amount two lines will be generated in INL_tax_lines.
--
-- Pre-reqs    : None
--
-- Parameters  :
-- IN          : p_ship_header_id   IN  NUMBER
--
-- OUT         : x_return_status             OUT NOCOPY VARCHAR2
--
-- Version     : Current version 1.0
--
-- Notes       :
PROCEDURE Adjust_Tax_Lines(
    p_ship_header_id   IN  NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2
) IS
    l_procedure_name  CONSTANT    VARCHAR2(100) := 'Adjust_Tax_Lines ';
    l_debug_info                  VARCHAR2(240);
    l_tax_line_id                 NUMBER;
    l_allocation_basis            VARCHAR2(30)    := 'VALUE';
    l_allocation_uom_code         VARCHAR2(30) := NULL;
    l_proc                        VARCHAR2(1):='N';
BEGIN
-- logging message
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_procedure_name
    );

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR curTax in (SELECT zl.tax_line_id
                          ,zl.tax_line_number
                          ,zl.tax_code
                          ,zl.trx_id
                          ,zl.trx_line_id
                          ,zl.tax_amt
                          ,nvl(zl.Nrec_tax_amt,0) Nrec_tax_amt
                          ,zl.tax_amt_included_flag
                          ,zl.tax_currency_code
                          ,zl.tax_currency_conversion_type
                          ,zl.tax_currency_conversion_date
                          ,zl.tax_currency_conversion_rate
                          ,zl.created_by
                          ,zl.creation_date
                          ,zl.last_updated_by
                          ,zl.last_update_date
                          ,zl.last_update_login
                          ,DECODE(lv.source, 'SHIP_LINE'    ,'INL_SHIP_LINES'
                                           , 'CHARGE' ,'INL_CHARGE_LINES') source
                          ,oh.ship_TYPE_ID
                          ,inl_tax_lines_s.NEXTVAL tax_line_id_s
                      FROM zx_lines              zl
                          ,inl_ebtax_lines_v lv
                          ,inl_ship_headers   oh
                     WHERE zl.application_id     = 9004
                       AND zl.trx_id             = P_ship_Header_Id
                       AND oh.ship_Header_Id     = P_ship_Header_Id
                       AND lv.ship_line_id       = zl.trx_line_id
                       AND lv.ship_header_id     = P_ship_Header_Id)
    LOOP
        IF l_proc  = 'N' THEN
            l_proc  := 'Y';
            -- logging message
            l_debug_info := 'It will mark the calculated line: curTax';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name    => g_module_name,
                p_procedure_name => l_procedure_name,
                p_debug_info     => l_debug_info
            );
        END IF;
        -----------------------------------------------------------------
        l_debug_info := 'Step 6a: Persisting zl.tax_code: '||curTax.tax_code||' zl.tax_line_id:'||curTax.tax_line_id;
-- logging message
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_procedure_name,
            p_debug_info     => l_debug_info
        );
        -----------------------------------------------------------------
        -----------------------------------------------------------------
        l_debug_info := ' P_Ship_Header_Id: '||p_ship_Header_Id
                      ||' zl.tax_line_id: '||curTax.tax_line_id
        ;
-- logging message
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_procedure_name,
            p_debug_info     => l_debug_info
        );
        -----------------------------------------------------------------
-- It will insert in LCM tax Table the information from eBTax tax Table
        INSERT INTO inl_tax_lines (
                     tax_line_id
                    ,tax_line_num
                    ,tax_code
                    ,ship_header_id
                    ,adjustment_num
                    ,source_parent_table_name
                    ,source_parent_table_id
                    ,tax_amt
                    ,nrec_tax_amt
                    ,currency_code
                    ,currency_conversion_type
                    ,currency_conversion_date
                    ,currency_conversion_rate
                    ,tax_amt_included_flag
                    ,created_by
                    ,creation_date
                    ,last_updated_by
                    ,last_update_date
                    ,last_update_login)
        VALUES(
                     curTax.tax_line_id_s
                    ,curTax.tax_line_number
                    ,curTax.tax_code
                    ,curTax.trx_id
                    ,0
                    ,'ZX_LINES'
                    ,curTax.tax_line_id
                    ,curTax.tax_amt
                    ,curTax.nrec_tax_amt
                    ,curTax.tax_currency_code
                    ,curTax.tax_currency_conversion_type
                    ,curTax.tax_currency_conversion_date
                    ,curTax.tax_currency_conversion_rate
                    ,curTax.tax_amt_included_flag
                    ,fnd_global.user_id
                    ,SYSDATE
                    ,fnd_global.user_id
                    ,SYSDATE
                    ,fnd_global.login_id
        );
        -----------------------------------------------------------------
        l_debug_info := 'Step 6b: Persisting zl.tax_code(Associations): '||curTax.tax_code||' zl.tax_line_id:'||curTax.tax_line_id;
-- logging message
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_procedure_name,
            p_debug_info     => l_debug_info
        );
        -----------------------------------------------------------------
-- It will create the association of new tax line with the correspondent component
        INSERT INTO inl_associations (
                      association_id                   /* 01 */
                     ,ship_header_id                   /* 02 */
                     ,from_parent_table_name           /* 03 */
                     ,from_parent_table_id             /* 04 */
                     ,to_parent_table_name             /* 05 */
                     ,to_parent_table_id               /* 06 */
                     ,allocation_basis                 /* 07 */
                     ,allocation_uom_code              /* 08 */
                     ,created_by                       /* 09 */
                     ,creation_date                    /* 10 */
                     ,last_updated_by                  /* 11 */
                     ,last_update_date                 /* 12 */
                     ,last_update_login)               /* 13 */
        VALUES(
                      inl_associations_s.NEXTVAL       /* 01 */
                     ,curTax.trx_id                    /* 02 */
                     ,'INL_TAX_LINES'                  /* 03 */
                     ,curTax.tax_line_id_s             /* 04 */
                     ,curTax.source                    /* 05 */
                     ,curTax.trx_line_id               /* 06 */
                     ,l_allocation_basis               /* 07 */
                     ,l_allocation_uom_code            /* 08 */
                     ,fnd_global.user_id               /* 09 */
                     ,SYSDATE                          /* 10 */
                     ,fnd_global.user_id               /* 11 */
                     ,SYSDATE                          /* 12 */
                     ,fnd_global.login_id);            /* 13 */
    END LOOP;
    UPDATE inl_ship_lines
    SET tax_already_calculated_flag = 'Y',
         last_updated_by = fnd_global.user_id,
         last_update_date = SYSDATE
    WHERE ship_header_id =  p_ship_header_Id;

    UPDATE inl_charge_lines
    SET tax_already_calculated_flag = 'Y',
         last_updated_by = fnd_global.user_id,
         last_update_date = SYSDATE
    WHERE NVL(parent_charge_line_id,charge_line_id) IN (SELECT assoc.from_parent_table_id
                                                        FROM inl_associations assoc
                                                        WHERE assoc.from_parent_table_name = 'INL_CHARGE_LINES'
                                                        AND assoc.ship_header_id = p_ship_header_id);
-- logging message
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_procedure_name
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
-- logging message
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_procedure_name
        );
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
-- logging message
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_procedure_name
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
-- logging message
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_procedure_name
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_procedure_name);
        END IF;

END Adjust_Tax_Lines;

-- API name   : Calculate_Tax
-- Type       : Private
-- Function   : It populate the ZX temporary GT tables and then call eBTax Calculate Tax for a given LCM Shipment.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version        IN NUMBER,
--              p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
--              p_commit             IN VARCHAR2 := FND_API.G_FALSE,
--              p_ship_header_id     IN NUMBER,
--
-- OUT        : x_return_status      OUT NOCOPY VARCHAR2
--              x_msg_count          OUT NOCOPY   NUMBER
--              x_msg_data           OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :

PROCEDURE Calculate_Tax(
    p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN VARCHAR2 := FND_API.G_FALSE,
    p_ship_header_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Calculate_Tax';
    l_api_version            CONSTANT NUMBER := 1.0;

    l_debug_info             VARCHAR2(240);

    l_event_class_code       VARCHAR2(30);
    l_event_type_code        VARCHAR2(30);
    l_tax_already_calculated VARCHAR2(1);

    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(4000);
    l_msg                     VARCHAR2(4000);
    l_error_code              VARCHAR2(30);

    l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_no_tax_lines            VARCHAR2(1) := 'N';
    l_inv_rcv_matched         VARCHAR2(1) := 'N';

    l_ledger_list             GL_MC_INFO.r_sob_list;
    l_denominator_rate        NUMBER;
    l_numerator_rate          NUMBER;


BEGIN
    -- logging message
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name
    );

    -- Standard Start of API savepoint
    SAVEPOINT   Calculate_Tax_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -------------------------------------------------------------------
    l_debug_info := 'FND_API.Compatible_API_Call';
    -------------------------------------------------------------------
    -- logging message
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;



--- VPILAN 11-Jun-2008
--- This RETURN is due to the fact we don't have EBTAX events model yet.
RETURN;


    -------------------------------------------------------------------
    l_debug_info := 'Step 0: Get Entity Code mapping on eBTax';
    -------------------------------------------------------------------
    -- logging message
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );

    SELECT entity_code INTO G_ENTITY_CODE
      FROM zx_evnt_cls_mappings
     WHERE application_id = 9004
       AND ROWNUM         = 1;
    -----------------------------------------------------------------
    l_debug_info := 'Step 1: call LCM Calculation for all types of lines';
    -- logging message
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );
    -----------------------------------------------------------------
    IF ( l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        l_debug_info := 'Step 1a: Delete data from previous tax Generation/Calculation';
        -- logging message
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info     => l_debug_info
        );
        Delete_PreviousTaxLines (
             p_ship_header_id => p_ship_header_id,
             x_return_status  => l_return_status
        );
        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
            -----------------------------------------------------------------
        l_debug_info := 'Step 2: Populating shipment header local record';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info     => l_debug_info
        );
        -----------------------------------------------------------------

        BEGIN
           OPEN  Shipment_Header(p_ship_header_id);
           FETCH Shipment_Header INTO l_ship_header_rec;
           CLOSE Shipment_Header;
        END;
        -----------------------------------------------------------------
        l_debug_info := 'Step 2a: Populating shipment lines collection';
        -- logging message
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info     => l_debug_info
        );
        -----------------------------------------------------------------
-- Collect INL_eBTax_Line_v lines in l_ship_line_list dinamic table
-- The view INL_eBTax_Line_v has Shipment_Lines and Charge_Lines froma given shipment
        BEGIN
            OPEN    Shipment_Lines(p_ship_header_id);
            FETCH   Shipment_Lines
            BULK    COLLECT INTO l_ship_line_list;
            CLOSE   Shipment_Lines;
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;
        -- The eTax_Already_called_flag is in lines
        -- adjustments generate version of lines and charge lines
        -- to decide the value of flag we are seeing zx table

        -------------------------------------------------------------------
        l_debug_info := 'Step 2b: Get event class code';
        -------------------------------------------------------------------

        Get_Event_Class_Code(
            p_ship_type_id     => l_ship_header_rec.ship_type_id,
            x_event_class_code => l_event_class_code,
            x_return_status    => l_return_status
        );
        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -----------------------------------------------------------------
        l_debug_info := 'Step 2c: Getting l_tax_already_calculated. trx_id= '||l_ship_header_rec.ship_header_id
                      ||' application_id: 9004'
                      ||' event_class_code: '||l_event_class_code
                      ||' entity_code: '||G_ENTITY_CODE;
         -- logging message
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info     => l_debug_info
        );
        -----------------------------------------------------------------
        BEGIN
           SELECT 'Y'
           INTO  l_tax_already_calculated
           FROM  zx_lines_det_factors
           WHERE trx_id = l_ship_header_rec.ship_header_id
           AND   application_id    = 9004
           AND   entity_code       = G_ENTITY_CODE
           AND   event_class_code = l_event_class_code
           AND   ROWNUM < 2;
        EXCEPTION
           WHEN OTHERS THEN l_tax_already_calculated := 'N';
        END;
        -----------------------------------------------------------------
        l_debug_info := 'Step 3: Populate Header';
         -- logging message
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info     => l_debug_info
        );
        -----------------------------------------------------------------

        -- Populate eBTax temporary table (Header)
        INL_TAX_PVT.Populate_Headers_GT(
            p_etax_already_called_flag => l_tax_already_calculated,
            p_event_class_code         => l_event_class_code,
            x_event_type_code          => l_event_type_code,
            x_return_status            => l_return_status
        );

        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -----------------------------------------------------------------
        l_debug_info := 'Step 4: Populate TRX lines';
        -- logging message
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info     => l_debug_info
        );
        -----------------------------------------------------------------
        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         -- Populate eBTax temporary table (Lines)

            INL_TAX_PVT.Populate_Lines_GT(
                P_Event_Class_Code        => l_event_class_code,
                P_Line_Number             => 1,
                x_return_status           => l_return_status
            );
            -- If any errors happen abort API.
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;


            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                -- logging message
                INL_LOGGING_PVT.Log_APICallIn (
                    p_module_name     => g_module_name,
                    p_procedure_name  => l_api_name,
                    p_call_api_name   => 'ZX_API_PUB.Calculate_Tax',
                    p_in_param_name1  => 'p_api_version',
                    p_in_param_value1 => 1.0,
                    p_in_param_name2  => 'p_init_msg_list',
                    p_in_param_value2 => FND_API.G_TRUE,
                    p_in_param_name3  => 'p_commit',
                    p_in_param_value3 => FND_API.G_FALSE,
                    p_in_param_name4  => 'p_validation_level',
                    p_in_param_value4 => FND_API.G_VALID_LEVEL_FULL
                );
--- It will run the calculate_tax procedure from eBTax
--- This procedure will calculate the tax from the current transaction
--- and populate zx_lines

/*
           FROM ZX_TRANSACTION_LINES_GT
           WHERE TRX_ID = l_ship_header_rec.ship_header_id
*/
                zx_api_pub.calculate_tax(
                    p_api_version      => 1.0,
                    p_init_msg_list    => FND_API.G_FALSE,
                    p_commit           => FND_API.G_FALSE,
                    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                    x_return_status    => l_return_status,
                    x_msg_count        => l_msg_count,
                    x_msg_data         => l_msg_data
                );

                -- logging message
                INL_LOGGING_PVT.Log_APICallOut (
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_api_name,
                    p_call_api_name    => 'ZX_API_PUB.Calculate_Tax',
                    p_out_param_name1  => 'l_return_status',
                    p_out_param_value1 => l_return_status,
                    p_out_param_name2  => 'l_msg_count',
                    p_out_param_value2 => l_msg_count,
                    p_out_param_name3  => 'l_msg_data',
                    p_out_param_value3 => l_msg_data);

                -- If any errors happen abort API.
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                -----------------------------------------------------------------
                l_debug_info := 'Step 6: Adjust_Tax_Lines to Persist tax records in INL_ASSOCIATIONS and INL_TAX_LINES';
                -- logging message
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_api_name,
                    p_debug_info     => l_debug_info);
                -----------------------------------------------------------------
                -- It will answer the updates done in zx_lines in INL_tax_lines
                Adjust_Tax_Lines(p_ship_header_id, l_return_status);
                 -- If any errors happen abort API.
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                -----------------------------------------------------------------
                l_debug_info := 'Step 7: call LCM Calculation for tax lines';
                -- logging message
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_api_name,
                    p_debug_info     => l_debug_info
                );
                -----------------------------------------------------------------
            END IF;
        END IF;
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
        p_data    => x_msg_data);

    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name);
        ROLLBACK TO Calculate_Tax_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    =>  x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name);
        ROLLBACK TO Calculate_Tax_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
    WHEN OTHERS THEN
        -- logging message
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name);
        ROLLBACK TO Calculate_Tax_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END Calculate_Tax;

-- API name   : Get_DefaultTaxDetAttribs
-- Type       : Private
-- Function   : Get default tax attributes
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version         IN NUMBER,
--              p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
--              p_commit              IN VARCHAR2 := FND_API.G_FALSE,
--              p_application_id      IN NUMBER,
--              p_entity_code         IN VARCHAR2,
--              p_event_class_code    IN VARCHAR2,
--              p_org_id              IN VARCHAR2,
--              p_item_id             IN NUMBER,
--              p_country_code        IN VARCHAR2,
--              p_effective_date      IN DATE,
--              p_source_type_code    IN VARCHAR2,
--              p_po_line_location_id IN NUMBER,
--
-- OUT          x_return_status        OUT NOCOPY VARCHAR2
--              x_msg_count            OUT NOCOPY   NUMBER
--              x_msg_data             OUT NOCOPY VARCHAR2
--              x_trx_biz_category     OUT NOCOPY VARCHAR2,
--              x_intended_use          OUT NOCOPY VARCHAR2,
--              x_prod_category         OUT NOCOPY VARCHAR2,
--              x_prod_fisc_class_code OUT NOCOPY VARCHAR2,
--              x_product_type         OUT NOCOPY VARCHAR2
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_DefaultTaxDetAttribs(p_api_version             IN NUMBER,
                                   p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
                                   p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
                                   p_application_id          IN NUMBER,
                                   p_entity_code             IN VARCHAR2,
                                   p_event_class_code        IN VARCHAR2,
                                   p_org_id                  IN VARCHAR2,
                                   p_item_id                 IN NUMBER,
                                   p_country_code            IN VARCHAR2,
                                   p_effective_date          IN DATE,
                                   p_source_type_code        IN VARCHAR2,
                                   p_po_line_location_id     IN NUMBER,
                                   x_return_status           OUT NOCOPY VARCHAR2,
                                   x_msg_count               OUT NOCOPY NUMBER,
                                   x_msg_data                OUT NOCOPY VARCHAR2,
                                   x_trx_biz_category        OUT NOCOPY VARCHAR2,
                                   x_intended_use           OUT NOCOPY VARCHAR2,
                                   x_prod_category          OUT NOCOPY VARCHAR2,
                                   x_prod_fisc_class_code    OUT NOCOPY VARCHAR2,
                                   x_product_type            OUT NOCOPY VARCHAR2) IS

  l_api_name       CONSTANT VARCHAR2(30) := 'Get_DefaultTaxDetAttribs';
  l_api_version    CONSTANT NUMBER := 1.0;

  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_debug_info      VARCHAR2(200);
  l_po_country_code VARCHAR2(20);
BEGIN

  -- Standard Beginning of Procedure/Function Logging
   INL_LOGGING_PVT.Log_BeginProc (p_module_name    => g_module_name,
                                  p_procedure_name => l_api_name);

  -- Standard Start of API savepoint
  SAVEPOINT Get_DefaultTaxDetAttribs_PVT;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API Body
  BEGIN

    l_debug_info := 'p_source_type_code: ' || p_source_type_code;
    -- logging message
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info);

      IF(p_source_type_code = 'PO') THEN
        BEGIN
          SELECT  zx.default_taxation_country,
                  zx.trx_business_category,
                  zx.product_fisc_classification,
                  zx.product_category,
                  zx.line_intended_use,
                  zx.product_type
          INTO    l_po_country_code,
                  x_trx_biz_category,
                  x_prod_fisc_class_code,
                  x_prod_category,
                  x_intended_use,
                  x_product_type
          FROM    zx_lines_det_factors zx,
                  po_line_locations pll
          WHERE   zx.application_id   = 201
          AND     zx.event_class_code = 'PO_PA'
          AND     zx.entity_code      = 'PURCHASE_ORDER'
          AND     zx.trx_id           = pll.po_header_id
          AND     zx.trx_line_id      = pll.line_location_id
          AND     zx.trx_level_type   = 'SHIPMENT'
          AND     trx_line_id         = p_po_line_location_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_po_country_code := NULL;
        END;

        l_debug_info := 'l_po_country_code: ' || l_po_country_code;
        -- logging message
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info     => l_debug_info);

        l_debug_info := 'p_country_code: ' || p_country_code;
        -- logging message
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info     => l_debug_info);

        IF(l_po_country_code IS NULL OR l_po_country_code <> p_country_code) THEN

          ZX_API_PUB.get_default_tax_det_attribs(p_api_version             => 1.0,
                                                 p_init_msg_list           => FND_API.G_FALSE,
                                                 p_commit                  => FND_API.G_FALSE,
                                                 p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                                                 x_return_status           => l_return_status,
                                                 x_msg_count               => l_msg_count,
                                                 x_msg_data                => l_msg_data,
                                                 p_application_id          => p_application_id,
                                                 p_entity_code             => p_entity_code,
                                                 p_event_class_code        => p_event_class_code,
                                                 p_org_id                  => p_org_id,
                                                 p_item_id                 => p_item_id,
                                                 p_country_code            => p_country_code,
                                                 p_effective_date          => p_effective_date,
                                                 p_source_event_class_code => NULL,
                                                 x_trx_biz_category        => x_trx_biz_category,
                                                 x_intended_use            => x_intended_use,
                                                 x_prod_category           => x_prod_category,
                                                 x_prod_fisc_class_code    => x_prod_fisc_class_code,
                                                 x_product_type            => x_product_type);
          -- If any errors happen abort API.
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
      ELSE

          ZX_API_PUB.get_default_tax_det_attribs(p_api_version      => 1.0,
                                                 p_init_msg_list    => FND_API.G_FALSE,
                                                 p_commit           => FND_API.G_FALSE,
                                                 p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                                 x_return_status    => l_return_status,
                                                 x_msg_count        => l_msg_count,
                                                 x_msg_data         => l_msg_data  ,
                                                 p_application_id   => p_application_id,
                                                 p_entity_code      => p_entity_code,
                                                 p_event_class_code => p_event_class_code,
                                                 p_org_id           => p_org_id,
                                                 p_item_id          => p_item_id,
                                                 p_country_code     => p_country_code,
                                                 p_effective_date   => p_effective_date,
                                                 p_source_event_class_code => NULL,
                                                 x_trx_biz_category => x_trx_biz_category,
                                                 x_intended_use     => x_intended_use,
                                                 x_prod_category    => x_prod_category,
                                                 x_prod_fisc_class_code => x_prod_fisc_class_code,
                                                 x_product_type => x_product_type);

        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
  END;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
    (p_encoded => FND_API.g_false,
     p_count   => x_msg_count,
     p_data    =>  x_msg_data);

  -- Standard End of Procedure/Function Logging
  INL_LOGGING_PVT.Log_EndProc (p_module_name    => g_module_name,
                               p_procedure_name => l_api_name);


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                    p_procedure_name => l_api_name);
    ROLLBACK TO Get_DefaultTaxDetAttribs_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                      p_procedure_name => l_api_name);
    ROLLBACK TO Get_DefaultTaxDetAttribs_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                      p_procedure_name => l_api_name);
    ROLLBACK TO Get_DefaultTaxDetAttribs_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
END Get_DefaultTaxDetAttribs;

END INL_TAX_PVT;

/
