--------------------------------------------------------
--  DDL for Package Body ZX_TDS_IMPORT_DOCUMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_IMPORT_DOCUMENT_PKG" AS
 /* $Header: zxdiimpdocmtpkgb.pls 120.61.12010000.17 2010/09/08 18:58:06 prigovin ship $ */

 g_current_runtime_level    NUMBER;
 g_level_statement          CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
 g_level_procedure          CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
 g_level_event              CONSTANT  NUMBER   := FND_LOG.LEVEL_EVENT;
 g_level_unexpected         CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

 NUMBER_DUMMY               CONSTANT  NUMBER   := -999999999999;

 TYPE tax_line_rec_type is RECORD (
  summary_tax_line_number   zx_import_tax_lines_gt.summary_tax_line_number%TYPE,
  internal_organization_id  zx_import_tax_lines_gt.internal_organization_id%TYPE,
  tax_regime_code           zx_import_tax_lines_gt.tax_regime_code%TYPE,
  tax                       zx_import_tax_lines_gt.tax%TYPE,
  tax_status_code           zx_import_tax_lines_gt.tax_status_code%TYPE,
  tax_rate_code             zx_import_tax_lines_gt.tax_rate_code%TYPE,
  tax_rate                  zx_import_tax_lines_gt.tax_rate%TYPE,
  summary_tax_amt           zx_import_tax_lines_gt.tax_amt%TYPE,
  tax_jurisdiction_code     zx_import_tax_lines_gt.tax_jurisdiction_code%TYPE,
  tax_amt_included_flag     zx_import_tax_lines_gt.tax_amt_included_flag%TYPE,
  tax_exception_id          zx_import_tax_lines_gt.tax_exception_id%TYPE,
  tax_exemption_id          zx_import_tax_lines_gt.tax_exemption_id%TYPE,
  exempt_reason_code        zx_import_tax_lines_gt.exempt_reason_code%TYPE,
  exempt_certificate_number zx_import_tax_lines_gt.exempt_certificate_number%TYPE,
  trx_line_id               zx_trx_tax_link_gt.trx_line_id%TYPE,
  line_amt                  zx_trx_tax_link_gt.line_amt%TYPE,
  trx_date                  zx_trx_headers_gt.trx_date%TYPE,
  minimum_accountable_unit  zx_trx_headers_gt.minimum_accountable_unit%TYPE,
  precision                 zx_trx_headers_gt.precision%TYPE,
  trx_level_type            zx_transaction_lines_gt.trx_level_type%TYPE,
  trx_line_date             zx_transaction_lines_gt.trx_line_date%TYPE,
  adjusted_doc_date         zx_transaction_lines_gt.adjusted_doc_date%TYPE,
  line_level_action         zx_transaction_lines_gt.line_level_action%TYPE,
  interface_entity_code     zx_import_tax_lines_gt.interface_entity_code%TYPE,
  interface_tax_line_id     zx_import_tax_lines_gt.interface_tax_line_id%TYPE,
  related_doc_date          zx_trx_headers_gt.related_doc_date%TYPE,
  provnl_tax_determination_date zx_trx_headers_gt.provnl_tax_determination_date%TYPE,
-- added for bug 5018766
  tax_date 		    zx_transaction_lines_gt.tax_date%type,
  tax_determine_date 	    zx_transaction_lines_gt.tax_determine_date%type,
  tax_point_date 	    zx_transaction_lines_gt.tax_point_date%type,
  -- Bug 7117340 -- DFF ER
  attribute1                zx_import_tax_lines_gt.attribute1%TYPE,
  attribute2                zx_import_tax_lines_gt.attribute2%TYPE,
  attribute3                zx_import_tax_lines_gt.attribute3%TYPE,
  attribute4                zx_import_tax_lines_gt.attribute4%TYPE,
  attribute5                zx_import_tax_lines_gt.attribute5%TYPE,
  attribute6                zx_import_tax_lines_gt.attribute6%TYPE,
  attribute7                zx_import_tax_lines_gt.attribute7%TYPE,
  attribute8                zx_import_tax_lines_gt.attribute8%TYPE,
  attribute9                zx_import_tax_lines_gt.attribute9%TYPE,
  attribute10               zx_import_tax_lines_gt.attribute10%TYPE,
  attribute11               zx_import_tax_lines_gt.attribute11%TYPE,
  attribute12               zx_import_tax_lines_gt.attribute12%TYPE,
  attribute13               zx_import_tax_lines_gt.attribute13%TYPE,
  attribute14               zx_import_tax_lines_gt.attribute14%TYPE,
  attribute15               zx_import_tax_lines_gt.attribute15%TYPE,
  attribute_category        zx_import_tax_lines_gt.attribute_category%TYPE
  );

 PROCEDURE create_detail_tax_line (
  p_event_class_rec         IN 	           zx_api_pub.event_class_rec_type,
  p_tax_line_rec	    IN	    	   tax_line_rec_type,
  p_new_row_num		    IN		   NUMBER,
  p_tax_class               IN             zx_rates_b.tax_class%TYPE,
  x_return_status              OUT NOCOPY  VARCHAR2);

PROCEDURE get_taxes_from_applied_from(
  p_event_class_rec	    IN                 zx_api_pub.event_class_rec_type,
  p_trx_line_index	    IN                 BINARY_INTEGER,
  p_tax_date		    IN                 DATE,
  p_tax_determine_date      IN                 DATE,
  p_tax_point_date          IN                 DATE,
  x_begin_index 	    IN OUT NOCOPY      BINARY_INTEGER,
  x_end_index		    IN OUT NOCOPY      BINARY_INTEGER,
  x_return_status	       OUT NOCOPY      VARCHAR2);

PROCEDURE get_taxes_from_adjusted_to(
  p_event_class_rec	   IN 		        zx_api_pub.event_class_rec_type,
  p_trx_line_index	   IN	       	  	BINARY_INTEGER,
  p_tax_date		   IN   	 	DATE,
  p_tax_determine_date     IN   	 	DATE,
  p_tax_point_date         IN   	 	DATE,
  x_begin_index 	   IN OUT NOCOPY	BINARY_INTEGER,
  x_end_index		   IN OUT NOCOPY	BINARY_INTEGER,
  x_return_status	   OUT NOCOPY 	        VARCHAR2);

/*=========================================================================*
 | Public procedure prorate_imported_sum_tax_lines is used to prorate      |
 | imported summary tax lines to create detail tax lines.                  |
 *=========================================================================*/
PROCEDURE prorate_imported_sum_tax_lines (
 p_event_class_rec          IN          zx_api_pub.event_class_rec_type,
 x_return_status            OUT NOCOPY  VARCHAR2) IS

 CURSOR  get_alloc_detail_tax_lines_csr IS
  SELECT /*+ ORDERED
             INDEX(headergt ZX_TRX_HEADERS_GT_U1)
             INDEX(sumgt ZX_IMPORT_TAX_LINES_GT_U1)
             INDEX(allocgt ZX_TRX_TAX_LINK_GT_U1)
             INDEX(linegt ZX_TRANSACTION_LINES_GT_U1 )*/
         sumgt.summary_tax_line_number,
         sumgt.internal_organization_id,
         sumgt.tax_regime_code,
         sumgt.tax,
         sumgt.tax_status_code,
         sumgt.tax_rate_code,
         sumgt.tax_rate,
         sumgt.tax_amt summary_tax_amt,
         sumgt.tax_jurisdiction_code,
         sumgt.tax_amt_included_flag,
         sumgt.tax_exception_id,
         sumgt.tax_exemption_id,
         sumgt.exempt_reason_code,
         sumgt.exempt_certificate_number,
         allocgt.trx_line_id,
         allocgt.line_amt,
         headergt.trx_date,
         headergt.minimum_accountable_unit,
         headergt.precision,
         linegt.trx_level_type,
         linegt.trx_line_date,
         linegt.adjusted_doc_date,
         linegt.line_level_action,
         sumgt.interface_entity_code,
         sumgt.interface_tax_line_id,
         headergt.related_doc_date,
         headergt.provnl_tax_determination_date,
-- added for bug 5018766
	 linegt.tax_date ,
	 linegt.tax_determine_date ,
	 linegt.tax_point_date,
         -- Bug 7117340 -- DFF ER
         sumgt.attribute1,
         sumgt.attribute2,
         sumgt.attribute3,
         sumgt.attribute4,
         sumgt.attribute5,
         sumgt.attribute6,
         sumgt.attribute7,
         sumgt.attribute8,
         sumgt.attribute9,
         sumgt.attribute10,
         sumgt.attribute11,
         sumgt.attribute12,
         sumgt.attribute13,
         sumgt.attribute14,
         sumgt.attribute15,
         sumgt.attribute_category
    FROM zx_trx_headers_gt headergt,
         zx_import_tax_lines_gt sumgt,
         zx_trx_tax_link_gt allocgt,
         zx_transaction_lines_gt linegt
   WHERE headergt.application_id = p_event_class_rec.application_id
     AND headergt.event_class_code = p_event_class_rec.event_class_code
     AND headergt.entity_code = p_event_class_rec.entity_code
     AND headergt.trx_id = p_event_class_rec.trx_id
     AND sumgt.application_id = headergt.application_id
     AND sumgt.entity_code = headergt.entity_code
     AND sumgt.event_class_code = headergt.event_class_code
     AND sumgt.trx_id = headergt.trx_id
     AND sumgt.tax_line_allocation_flag = 'Y'
     AND allocgt.application_id = sumgt.application_id
     AND allocgt.event_class_code = sumgt.event_class_code
     AND allocgt.entity_code = sumgt.entity_code
     AND allocgt.trx_id = sumgt.trx_id
     AND allocgt.summary_tax_line_number = sumgt.summary_tax_line_number
     AND linegt.application_id = allocgt.application_id
     AND linegt.entity_code = allocgt.entity_code
     AND linegt.event_class_code = allocgt.event_class_code
     AND linegt.trx_id = allocgt.trx_id
     AND linegt.trx_line_id = allocgt.trx_line_id
     AND linegt.trx_level_type = allocgt.trx_level_type
     ORDER BY sumgt.summary_tax_line_number;

 CURSOR  get_one_alloc_det_tax_lines_cr IS
  SELECT /*+ ORDERED
             INDEX(headergt ZX_TRX_HEADERS_GT_U1)
             INDEX(sumgt ZX_IMPORT_TAX_LINES_GT_U1)
             INDEX(linegt ZX_TRANSACTION_LINES_GT_U1)*/
         sumgt.summary_tax_line_number,
         sumgt.internal_organization_id,
         sumgt.tax_regime_code,
         sumgt.tax,
         sumgt.tax_status_code,
         sumgt.tax_rate_code,
         sumgt.tax_rate,
         sumgt.tax_amt summary_tax_amt,
         sumgt.tax_jurisdiction_code,
         sumgt.tax_amt_included_flag,
         sumgt.tax_exception_id,
         sumgt.tax_exemption_id,
         sumgt.exempt_reason_code,
         sumgt.exempt_certificate_number,
         linegt.trx_line_id,
         linegt.line_amt,
         headergt.trx_date,
         headergt.minimum_accountable_unit,
         headergt.precision,
         linegt.trx_level_type,
         linegt.trx_line_date,
         linegt.adjusted_doc_date,
         linegt.line_level_action,
         sumgt.interface_entity_code,
         sumgt.interface_tax_line_id,
         headergt.related_doc_date,
         headergt.provnl_tax_determination_date,
-- added for bug 5018766
	 linegt.tax_date ,
	 linegt.tax_determine_date ,
	 linegt.tax_point_date,
         -- Bug 7117340 -- DFF ER
         sumgt.attribute1,
         sumgt.attribute2,
         sumgt.attribute3,
         sumgt.attribute4,
         sumgt.attribute5,
         sumgt.attribute6,
         sumgt.attribute7,
         sumgt.attribute8,
         sumgt.attribute9,
         sumgt.attribute10,
         sumgt.attribute11,
         sumgt.attribute12,
         sumgt.attribute13,
         sumgt.attribute14,
         sumgt.attribute15,
         sumgt.attribute_category
    FROM zx_trx_headers_gt headergt,
         zx_import_tax_lines_gt sumgt,
         zx_transaction_lines_gt linegt
   WHERE headergt.application_id = p_event_class_rec.application_id
     AND headergt.event_class_code = p_event_class_rec.event_class_code
     AND headergt.entity_code = p_event_class_rec.entity_code
     AND headergt.trx_id = p_event_class_rec.trx_id
     AND sumgt.application_id = headergt.application_id
     AND sumgt.entity_code = headergt.entity_code
     AND sumgt.event_class_code = headergt.event_class_code
     AND sumgt.trx_id = headergt.trx_id
     AND sumgt.tax_line_allocation_flag = 'N'
     AND linegt.application_id = sumgt.application_id
     AND linegt.entity_code = sumgt.entity_code
     AND linegt.event_class_code = sumgt.event_class_code
     AND linegt.trx_id = sumgt.trx_id
     AND linegt.trx_line_id = sumgt.trx_line_id
--     AND linegt.trx_level_type = sumgt.trx_level_type
     ORDER BY sumgt.summary_tax_line_number;

 CURSOR  get_all_detail_tax_lines_csr IS
  SELECT /*+ ORDERED
             INDEX(headergt ZX_TRX_HEADERS_GT_U1)
             INDEX(sumgt ZX_IMPORT_TAX_LINES_GT_U1)
             INDEX(linegt ZX_TRANSACTION_LINES_GT_U1) */
         sumgt.summary_tax_line_number,
         sumgt.internal_organization_id,
         sumgt.tax_regime_code,
         sumgt.tax,
         sumgt.tax_status_code,
         sumgt.tax_rate_code,
         sumgt.tax_rate,
         sumgt.tax_amt summary_tax_amt,
         sumgt.tax_jurisdiction_code,
         sumgt.tax_amt_included_flag,
         sumgt.tax_exception_id,
         sumgt.tax_exemption_id,
         sumgt.exempt_reason_code,
         sumgt.exempt_certificate_number,
         linegt.trx_line_id,
         linegt.line_amt,
         headergt.trx_date,
         headergt.minimum_accountable_unit,
         headergt.precision,
         linegt.trx_level_type,
         linegt.trx_line_date,
         linegt.adjusted_doc_date,
         linegt.line_level_action,
         sumgt.interface_entity_code,
         sumgt.interface_tax_line_id,
         headergt.related_doc_date,
         headergt.provnl_tax_determination_date,
-- added for bug 5018766
	 linegt.tax_date ,
	 linegt.tax_determine_date ,
	 linegt.tax_point_date,
         -- Bug 7117340 -- DFF ER
         sumgt.attribute1,
         sumgt.attribute2,
         sumgt.attribute3,
         sumgt.attribute4,
         sumgt.attribute5,
         sumgt.attribute6,
         sumgt.attribute7,
         sumgt.attribute8,
         sumgt.attribute9,
         sumgt.attribute10,
         sumgt.attribute11,
         sumgt.attribute12,
         sumgt.attribute13,
         sumgt.attribute14,
         sumgt.attribute15,
         sumgt.attribute_category
    FROM zx_trx_headers_gt headergt,
         zx_import_tax_lines_gt sumgt,
         zx_transaction_lines_gt linegt
   WHERE headergt.application_id = p_event_class_rec.application_id
     AND headergt.event_class_code = p_event_class_rec.event_class_code
     AND headergt.entity_code = p_event_class_rec.entity_code
     AND headergt.trx_id = p_event_class_rec.trx_id
--     AND NVL(headergt.hdr_trx_user_key1, 'X') = NVL(p_event_class_rec.hdr_trx_user_key1, 'X')
--     AND NVL(headergt.hdr_trx_user_key2, 'X') = NVL(p_event_class_rec.hdr_trx_user_key2, 'X')
--     AND NVL(headergt.hdr_trx_user_key3, 'X') = NVL(p_event_class_rec.hdr_trx_user_key3, 'X')
--     AND NVL(headergt.hdr_trx_user_key4, 'X') = NVL(p_event_class_rec.hdr_trx_user_key4, 'X')
--     AND NVL(headergt.hdr_trx_user_key5, 'X') = NVL(p_event_class_rec.hdr_trx_user_key5, 'X')
--     AND NVL(headergt.hdr_trx_user_key6, 'X') = NVL(p_event_class_rec.hdr_trx_user_key6, 'X')
     AND sumgt.application_id = headergt.application_id
     AND sumgt.entity_code = headergt.entity_code
     AND sumgt.event_class_code = headergt.event_class_code
     AND sumgt.trx_id = headergt.trx_id
     AND sumgt.tax_line_allocation_flag = 'N'
     AND sumgt.trx_line_id IS NULL
--     AND NVL(sumgt.hdr_trx_user_key1, 'X') = NVL(headergt.hdr_trx_user_key1, 'X')
--     AND NVL(sumgt.hdr_trx_user_key2, 'X') = NVL(headergt.hdr_trx_user_key2, 'X')
--     AND NVL(sumgt.hdr_trx_user_key3, 'X') = NVL(headergt.hdr_trx_user_key3, 'X')
--     AND NVL(sumgt.hdr_trx_user_key4, 'X') = NVL(headergt.hdr_trx_user_key4, 'X')
--     AND NVL(sumgt.hdr_trx_user_key5, 'X') = NVL(headergt.hdr_trx_user_key5, 'X')
--     AND NVL(sumgt.hdr_trx_user_key6, 'X') = NVL(headergt.hdr_trx_user_key6, 'X')
     AND linegt.application_id = sumgt.application_id
     AND linegt.entity_code = sumgt.entity_code
     AND linegt.event_class_code = sumgt.event_class_code
     AND linegt.trx_id = sumgt.trx_id
--     AND NVL(linegt.hdr_trx_user_key1, 'X') = NVL(sumgt.hdr_trx_user_key1, 'X')
--     AND NVL(linegt.hdr_trx_user_key2, 'X') = NVL(sumgt.hdr_trx_user_key2, 'X')
--     AND NVL(linegt.hdr_trx_user_key3, 'X') = NVL(sumgt.hdr_trx_user_key3, 'X')
--     AND NVL(linegt.hdr_trx_user_key4, 'X') = NVL(sumgt.hdr_trx_user_key4, 'X')
--     AND NVL(linegt.hdr_trx_user_key5, 'X') = NVL(sumgt.hdr_trx_user_key5, 'X')
--     AND NVL(linegt.hdr_trx_user_key6, 'X') = NVL(sumgt.hdr_trx_user_key6, 'X')
     AND linegt.line_level_action = 'CREATE_WITH_TAX'
     AND linegt.applied_from_application_id IS NULL
     AND linegt.adjusted_doc_application_id IS NULL
     -- AND linegt.applied_to_application_id IS NULL  --bug#6773534
     ORDER BY sumgt.summary_tax_line_number;

 CURSOR  get_total_trx_lines_amt_csr IS
  SELECT /*+ INDEX(ZX_TRANSACTION_LINES_GT ZX_TRANSACTION_LINES_GT_U1) */
         SUM(line_amt)
    FROM zx_transaction_lines_gt
   WHERE application_id = p_event_class_rec.application_id
     AND event_class_code = p_event_class_rec.event_class_code
     AND entity_code = p_event_class_rec.entity_code
     AND trx_id = p_event_class_rec.trx_id
     AND line_level_action = 'CREATE_WITH_TAX'
     AND applied_from_application_id IS NULL
     AND adjusted_doc_application_id IS NULL;
     -- AND applied_to_application_id IS NULL;  --bug#6773534

 CURSOR  get_total_alloc_lines_amt_csr(p_summary_tax_line_number   NUMBER) IS
  SELECT /*+ INDEX(ZX_TRX_TAX_LINK_GT ZX_TRX_TAX_LINK_GT_U1) */
         SUM(line_amt)
    FROM zx_trx_tax_link_gt
   WHERE application_id = p_event_class_rec.application_id
     AND event_class_code = p_event_class_rec.event_class_code
     AND entity_code = p_event_class_rec.entity_code
     AND trx_id = p_event_class_rec.trx_id
     AND summary_tax_line_number = p_summary_tax_line_number;

 l_previous_sum_tax_line_number	  NUMBER;
 l_previous_summary_tax_amt	  NUMBER;
 l_total_trx_lines_amt		  NUMBER;
 l_total_alloc_lines_amt	  NUMBER;
 l_total_rnd_tax_amt		  NUMBER;
 l_rounding_diff		  NUMBER;
 l_max_line_amt			  NUMBER;
 l_max_line_amt_tax_index	  NUMBER;
 l_new_row_num			  NUMBER;
 l_tax_id			  NUMBER;
 l_begin_index			  BINARY_INTEGER;
 l_end_index			  BINARY_INTEGER;
 l_error_buffer			  VARCHAR2(240);
 l_line_level_action              zx_transaction_lines_gt.line_level_action%TYPE;
 l_tax_class                      zx_rates_b.tax_class%TYPE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
                  'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines.BEGIN',
                  'ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- initialize local variables
  --
  l_new_row_num :=
            NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST,0);

  l_previous_sum_tax_line_number := NUMBER_DUMMY;

  --
  -- Bug#5417753- determine tax_class based on product family
  --
  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  -- Create detail tax lines from imported summary tax lines with allocations
  --
  FOR tax_line_rec IN get_alloc_detail_tax_lines_csr LOOP

    l_new_row_num := l_new_row_num + 1;
    l_line_level_action := tax_line_rec.line_level_action;
    -- set l_begin_index
    --
    IF l_begin_index IS NULL THEN
      l_begin_index := l_new_row_num;
    END IF;

    -- create a detail tax line and populate tax info
    --
    create_detail_tax_line (
                   p_event_class_rec     =>  p_event_class_rec,
                   p_tax_line_rec        =>  tax_line_rec,
                   p_new_row_num         =>  l_new_row_num,
                   p_tax_class           =>  l_tax_class,
                   x_return_status       =>  x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
               'Incorrect return_status after calling '||
               'ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line()');
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines.END',
               'ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines(-)');
      END IF;
      RETURN;
    END IF;

    -- For new summary tax line, adjust rounding difference for previous summary
    -- tax line for 'Line' Level rounding (For 'Header' level rounding, rounding
    -- differences are adjusted in Tail End Service as normal detail tax lines).
    --
    IF tax_line_rec.summary_tax_line_number <> l_previous_sum_tax_line_number
    THEN

      IF UPPER(ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level) = 'LINE'  THEN

        IF l_previous_sum_tax_line_number <> NUMBER_DUMMY THEN

          -- calculate rounding difference and adjust rounding difference
          -- (if it exists) to the  tax line with largest line amt.
          --
          l_rounding_diff := l_previous_summary_tax_amt - l_total_rnd_tax_amt;

          IF l_rounding_diff <> 0 THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_max_line_amt_tax_index).tax_amt := l_rounding_diff +
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                l_max_line_amt_tax_index).tax_amt;
          END IF;
        END IF;     -- l_previous_sum_tax_line_number <> NUMBER_DUMMY

        -- Reset local variables for new summary tax line
        --
        l_total_rnd_tax_amt := 0;
        l_max_line_amt := tax_line_rec.line_amt;
        l_max_line_amt_tax_index := l_new_row_num;
        l_rounding_diff := 0;
        l_previous_summary_tax_amt := tax_line_rec.summary_tax_amt;

      END IF;   -- g_rounding_level = 'LINE'

      -- set l_previous_sum_tax_line_number
      --
      l_previous_sum_tax_line_number := tax_line_rec.summary_tax_line_number;

      -- get total line amount of the allocated lines of this summary tax line
      --
      IF tax_line_rec.line_level_action = 'CREATE_WITH_TAX' THEN
        OPEN  get_total_alloc_lines_amt_csr(
                                   tax_line_rec.summary_tax_line_number);
        FETCH get_total_alloc_lines_amt_csr INTO l_total_alloc_lines_amt;
        CLOSE get_total_alloc_lines_amt_csr;
      END IF;
    END IF;   -- summary_tax_line_number <> l_previous_tax_sum_line_number

    -- If line_level_action = 'LINE_INFO_TAX_ONLY', pseudo lines have trx line
    -- amount as null, so when import service allocate summary tax only tax line,
    -- simply copy tax amount from summary tax line to detail tax line.
    --
    IF tax_line_rec.line_level_action = 'LINE_INFO_TAX_ONLY' THEN

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).tax_amt := tax_line_rec.summary_tax_amt;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).unrounded_tax_amt := tax_line_rec.summary_tax_amt;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_new_row_num).tax_only_line_flag := 'Y';

      -- set total rounded tax amount
      --
      l_total_rnd_tax_amt :=
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_amt;

    ELSE

      -- prorate tax_amt with line_amt
      --
      IF l_total_alloc_lines_amt <> 0 THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).unrounded_tax_amt := tax_line_rec.summary_tax_amt *
                                    tax_line_rec.line_amt/l_total_alloc_lines_amt;

      ELSE    -- l_total_alloc_lines_amt = 0

        -- raise error only if tax_line_rec.summary_tax_amt <> 0
        -- If tax_line_rec.summary_tax_amt = 0, set tax_amt to 0
        --
        IF tax_line_rec.summary_tax_amt  <> 0 THEN

          x_return_status := FND_API.G_RET_STS_ERROR;

          IF (g_level_event >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_event,
                   'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                   'tax_amt from summary tax line is not 0, ' ||
                   'but the total line amount for the allocated trx lines is 0.'
                    || 'Cannot do proration.');
            FND_LOG.STRING(g_level_event,
                   'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                   'Summary_tax_line_number = ' ||
                    tax_line_rec.summary_tax_line_number);
            FND_LOG.STRING(g_level_event,
                   'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_event,
                   'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines.END',
                   'ZX_TDS_IMPORT_DOCUMENT_PKG.' ||
                   'prorate_imported_sum_tax_lines(-)');
          END IF;
          RETURN;
        ELSE
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         l_new_row_num).unrounded_tax_amt :=  0;
        END IF;   -- sum_tax_line_rec.tax_amt <> 0 or ELSE
      END IF;     --  l_total_alloc_lines_amt <> 0 or ELSE

      -- Round tax amt for 'LINE' Level rounding. 'HEADER' level rounding
      -- will be done in tail end service as regular detail tax lines.
      --
      IF UPPER(ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level) = 'LINE' THEN

        -- round tax_amt
        --
        l_tax_id := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_id;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_amt :=
           ZX_TDS_TAX_ROUNDING_PKG.round_tax(
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt,
              NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule,
                  ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).rounding_rule_code),
              tax_line_rec.minimum_accountable_unit,
              tax_line_rec.precision,
              x_return_status,
              l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_TAX_ROUNDING_PKG.round_tax()');
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines.END',
                   'ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        -- accumulate rounded tax amount
        --
        l_total_rnd_tax_amt := l_total_rnd_tax_amt +
                    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                          l_new_row_num).tax_amt;

        -- record l_max_line_amt and l_max_line_amt_tax_index
        --
        IF  ABS(l_max_line_amt) < ABS(tax_line_rec.line_amt) THEN
          l_max_line_amt := tax_line_rec.line_amt;
          l_max_line_amt_tax_index := l_new_row_num;
        END IF;
      END IF;   -- g_rounding_level = 'Line'
    END IF;     -- tax_line_rec.line_level_action = 'LINE_INFO_TAX_ONLY' or ELSE
  END LOOP;     -- tax_line_rec IN get_alloc_detail_tax_lines_csr

  -- IF l_line_level_action <> 'LINE_INFO_TAX_ONLY', adjust rounding
  -- difference('Line' Level) for the last summary tax line
  --
  IF l_line_level_action = 'CREATE_WITH_TAX' THEN

    IF UPPER(ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level) = 'LINE' AND
       l_total_alloc_lines_amt IS NOT NULL
    THEN

      -- calculate rounding difference and adjust rounding difference
      -- (if it exists) to the  tax line with largest line amt.
      --
      l_rounding_diff := l_previous_summary_tax_amt - l_total_rnd_tax_amt;

      IF l_rounding_diff <> 0 THEN
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_max_line_amt_tax_index).tax_amt := l_rounding_diff +
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                              l_max_line_amt_tax_index).tax_amt;
      END IF;
    END IF;     -- g_rounding_level = 'Line'
  END IF;       -- line_level_action = 'CREATE_WITH_TAX'

  -- reset l_previous_sum_tax_line_number
  --
  l_previous_sum_tax_line_number := NUMBER_DUMMY;

  -- Create detail tax lines from imported summary tax lines with no allocation
  --
  FOR tax_line_rec IN get_all_detail_tax_lines_csr LOOP

    l_new_row_num := l_new_row_num + 1;

    -- set l_begin_index if it is NULL
    --
    IF l_begin_index IS NULL THEN
      l_begin_index := l_new_row_num;
    END IF;

    -- create a detail tax line and populate tax info
    --
    create_detail_tax_line (
                   p_event_class_rec     =>  p_event_class_rec,
                   p_tax_line_rec        =>  tax_line_rec,
                   p_new_row_num         =>  l_new_row_num,
                   p_tax_class           =>  l_tax_class,
                   x_return_status       =>  x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
               'Incorrect return_status after calling '||
               'ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line()');
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines.END',
               'ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines(-)');
      END IF;
      RETURN;
    END IF;

    -- Do proration and adjust rounding difference
    --
    IF tax_line_rec.summary_tax_line_number <> l_previous_sum_tax_line_number
    THEN

      IF UPPER(ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level) = 'LINE' THEN

        -- New summary tax line number
        --
        -- Adjust rounding difference for previous summary tax line for 'Line'
        -- Level rounding (For 'Header' level rounding, rounding differences
        -- are adjusted in Tail End Service as regular detail tax lines).
        --
        IF l_previous_sum_tax_line_number <> NUMBER_DUMMY THEN

          -- calculate rounding difference and adjust rounding difference
          -- (if it exists) to the  tax line with largest line amt.
          --
          l_rounding_diff := l_previous_summary_tax_amt - l_total_rnd_tax_amt;

          IF l_rounding_diff <> 0 THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_max_line_amt_tax_index).tax_amt := l_rounding_diff +
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                              l_max_line_amt_tax_index).tax_amt;
          END IF;
        END IF;     -- l_previous_sum_tax_line_number <> NUMBER_DUMMY

        -- Reset local variables for new summary tax line
        --
        l_total_rnd_tax_amt := 0;
        l_max_line_amt := tax_line_rec.line_amt;
        l_max_line_amt_tax_index := l_new_row_num;
        l_rounding_diff := 0;
        l_previous_summary_tax_amt := tax_line_rec.summary_tax_amt;

      END IF;       -- g_rounding_level = 'LINE'

      -- get total line amount of the allocated lines of this summary tax line
      --
      IF l_total_trx_lines_amt IS NULL THEN
        OPEN  get_total_trx_lines_amt_csr;
        FETCH get_total_trx_lines_amt_csr INTO l_total_trx_lines_amt;
        CLOSE get_total_trx_lines_amt_csr;
      END IF;

      -- set l_previous_sum_tax_line_number
      --
      l_previous_sum_tax_line_number := tax_line_rec.summary_tax_line_number;

    END IF;    -- summary_tax_line_number <> l_previous_tax_sum_line_number

    -- prorate tax_amt with line_amt
    --
    IF l_total_trx_lines_amt <> 0 THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).unrounded_tax_amt := tax_line_rec.summary_tax_amt *
                                    tax_line_rec.line_amt/l_total_trx_lines_amt;
    ELSE         -- l_total_trx_lines_amt = 0

      -- raise error only if tax_line_rec.summary_tax_amt <> 0
      -- If tax_line_rec.summary_tax_amt = 0, set tax_amt to 0
      --
      IF tax_line_rec.summary_tax_amt  <> 0 THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (g_level_event >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_event,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                 'tax_amt from summary tax line is not 0, ' ||
                 'but the total line amount for the allocated trx lines is 0.'
                  || 'Cannot do proration.');
          FND_LOG.STRING(g_level_event,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                 'Summary_tax_line_number = ' ||
                  tax_line_rec.summary_tax_line_number);
          FND_LOG.STRING(g_level_event,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_event,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines.END',
                 'ZX_TDS_IMPORT_DOCUMENT_PKG.' ||
                 'prorate_imported_sum_tax_lines(-)');
        END IF;
        RETURN;
      ELSE
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                       l_new_row_num).unrounded_tax_amt :=  0;
      END IF;   -- sum_tax_line_rec.tax_amt <> 0 or ELSE
    END IF;     --  l_total_alloc_lines_amt <> 0 or ELSE

    -- Round tax amt for 'LINE' Level rounding. 'HEADER' level rounding
    -- will be done in tail end service as regular detail tax lines.
    --
    IF UPPER(ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level) = 'LINE'
    THEN

      -- round tax_amt
      --
      l_tax_id := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_id;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_amt :=
         ZX_TDS_TAX_ROUNDING_PKG.round_tax(
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt,
            NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule,
                ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).rounding_rule_code),
            tax_line_rec.minimum_accountable_unit,
            tax_line_rec.precision,
            x_return_status,
            l_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_TAX_ROUNDING_PKG.round_tax()');
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines.END',
                 'ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines(-)');
        END IF;
        RETURN;
      END IF;

      -- accumulate rounded tax amount
      --
      l_total_rnd_tax_amt := l_total_rnd_tax_amt +
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                        l_new_row_num).tax_amt;

      -- record l_max_line_amt and l_max_line_amt_tax_index
      --
      IF  ABS(l_max_line_amt) < ABS(tax_line_rec.line_amt) THEN
        l_max_line_amt := tax_line_rec.line_amt;
        l_max_line_amt_tax_index := l_new_row_num;
      END IF;
    END IF;   -- g_rounding_level = 'LINE'
  END LOOP;     -- tax_line_rec IN get_all_detail_tax_lines_csr

  -- Adjust rounding difference('Line' Level) for the last summary tax line
  --
  IF UPPER(ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level) = 'LINE'  AND
       l_total_trx_lines_amt IS NOT NULL
  THEN

    -- calculate rounding difference and adjust rounding difference
    -- (if it exists) to the  tax line with largest line amt.
    --
    l_rounding_diff := l_previous_summary_tax_amt - l_total_rnd_tax_amt;

    IF l_rounding_diff <> 0 THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_max_line_amt_tax_index).tax_amt := l_rounding_diff +
                   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            l_max_line_amt_tax_index).tax_amt;
    END IF;
  END IF;    -- g_rounding_level = 'Line'

  -- Bug 4262870:
  -- Create detail tax lines for imported summary tax lines that carry
  -- allocation information( allocated to one transaction line )
  --
  FOR tax_line_rec IN get_one_alloc_det_tax_lines_cr LOOP

    l_new_row_num := l_new_row_num + 1;
    l_line_level_action := tax_line_rec.line_level_action;
    -- set l_begin_index
    --
    IF l_begin_index IS NULL THEN
      l_begin_index := l_new_row_num;
    END IF;

    -- create a detail tax line and populate tax info
    --
    create_detail_tax_line (
                   p_event_class_rec     =>  p_event_class_rec,
                   p_tax_line_rec        =>  tax_line_rec,
                   p_new_row_num         =>  l_new_row_num,
                   p_tax_class           =>  l_tax_class,
                   x_return_status       =>  x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
               'Incorrect return_status after calling '||
               'ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line()');
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines.END',
               'ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines(-)');
      END IF;
      RETURN;
    END IF;

    -- Copy tax_amt and unrounded_tax_amt from summary tax line
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).tax_amt := tax_line_rec.summary_tax_amt;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).unrounded_tax_amt := tax_line_rec.summary_tax_amt;

    -- Set tax_only_line_flag = 'Y' when line_level_action = 'LINE_INFO_TAX_ONLY'
    --
    IF tax_line_rec.line_level_action = 'LINE_INFO_TAX_ONLY' THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_new_row_num).tax_only_line_flag := 'Y';
    END IF;
  END LOOP;  -- tax_line_rec IN get_alloc_detail_tax_lines_csr. Bug4262870 End

  -- set l_end_index
  --
  IF l_begin_index IS NOT NULL THEN
    l_end_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST;
  END IF;

  --
  -- populate Process_For_Recovery_Flag
  --
  ZX_TDS_TAX_LINES_POPU_PKG.populate_recovery_flg(
                                                l_begin_index,
                                                l_end_index,
                                                p_event_class_rec,
                                                x_return_status,
                                                l_error_buffer);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
    RETURN;
  END IF;

  --
  -- populate WHO columns and tax line id, also
  -- check if all mandatory columns have values
  --
  ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line(
                                                l_begin_index,
                                                l_end_index,
                                                x_return_status,
                                                l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
             'Incorrect return_status after calling ' ||
             'ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line()');
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines.END',
             'ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
           'Detail tax lines created from imported summary tax lines:');
    FND_LOG.STRING(g_level_event,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
           'l_begin_index = ' || l_begin_index);
    FND_LOG.STRING(g_level_event,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
           'l_end_index = ' || l_end_index);
    FND_LOG.STRING(g_level_event,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
           'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_event,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines.END',
           'ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                  sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines.END',
                 'ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines(-)');
    END IF;

END prorate_imported_sum_tax_lines;

/* ======================================================================*
 |  Public PROCEDURE calculate_tax_for_import: This procedure is used    |
 |  to perform additional tax applicability and call internal services   |
 |  to do tax calculation. All the additional tax lines will be marked   |
 |  self_assessed.                                                       |
 * ======================================================================*/
PROCEDURE  calculate_tax_for_import (
 p_trx_line_index         IN             BINARY_INTEGER,
 p_event_class_rec        IN             zx_api_pub.event_class_rec_type,
 p_tax_date               IN             DATE,
 p_tax_determine_date     IN             DATE,
 p_tax_point_date         IN             DATE,
 x_return_status             OUT NOCOPY  VARCHAR2) IS

 CURSOR  get_imported_det_tax_lines_csr  IS
 SELECT  /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
         *
   FROM  zx_detail_tax_lines_gt
  WHERE  application_id =p_event_class_rec.application_id
    AND  entity_code =p_event_class_rec.entity_code
    AND  event_class_code =p_event_class_rec.event_class_code
    AND  trx_id = p_event_class_rec.trx_id
--    AND  NVL(hdr_trx_user_key1, 'X') = NVL(p_event_class_rec.hdr_trx_user_key1, 'X')
--    AND  NVL(hdr_trx_user_key2, 'X') = NVL(p_event_class_rec.hdr_trx_user_key2, 'X')
--    AND  NVL(hdr_trx_user_key3, 'X') = NVL(p_event_class_rec.hdr_trx_user_key3, 'X')
--    AND  NVL(hdr_trx_user_key4, 'X') = NVL(p_event_class_rec.hdr_trx_user_key4, 'X')
--    AND  NVL(hdr_trx_user_key5, 'X') = NVL(p_event_class_rec.hdr_trx_user_key5, 'X')
--    AND  NVL(hdr_trx_user_key6, 'X') = NVL(p_event_class_rec.hdr_trx_user_key6, 'X')
    AND  trx_line_id =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index)
    AND  trx_level_type =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

   CURSOR   get_key_columns_cur
                (c_tax_regime_code   zx_regimes_b.tax_regime_code%TYPE,
                 c_tax               zx_taxes_b.tax%TYPE,
                 c_apportionment_line_number  zx_lines.tax_apportionment_line_number%type) IS
   SELECT tax_line_id FROM zx_lines
    WHERE application_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_trx_line_index)
      AND entity_code =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(p_trx_line_index)
      AND event_class_code  =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(p_trx_line_index)
      AND trx_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id( p_trx_line_index)
      AND trx_line_id =
          NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(
                                                                    p_trx_line_index), trx_line_id)
      AND trx_level_type =
          NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(
                                                                 p_trx_line_index), trx_level_type)
      AND (tax_provider_id IS NULL
           OR ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_trx_line_index) = 'ALLOCATE_TAX_ONLY_ADJUSTMENT')
      AND Cancel_Flag <> 'Y'
      AND offset_link_to_tax_line_id IS NULL
      AND mrc_tax_line_flag = 'N'
      AND tax = c_tax
      AND tax_regime_code = c_tax_regime_code
      AND tax_apportionment_line_number = c_apportionment_line_number;

 l_begin_index             BINARY_INTEGER;
 l_end_index               BINARY_INTEGER;
 l_provider_id	           NUMBER;
 l_error_buffer            VARCHAR2(240);
 l_begin_index_additional  BINARY_INTEGER;
 l_end_index_additional	   BINARY_INTEGER;
 l_new_row_num             BINARY_INTEGER;
 l_tax_regime_id           ZX_REGIMES_B.tax_regime_id%TYPE;
 l_tax_id                  ZX_TAXES_B.tax_id%TYPE;
 l_def_reg_type            ZX_TAXES_B.def_registr_party_type_code%TYPE;
 l_reg_rule_flg            ZX_TAXES_B.registration_type_rule_flag%TYPE;
 l_tax_rate                zx_lines.tax_rate%TYPE;
 l_tax_amt_included_flag   zx_import_tax_lines_gt.tax_amt_included_flag%TYPE;

 l_adjusted_doc_tax_line_id  zx_lines.adjusted_doc_tax_line_id%TYPE;
 l_reporting_code_id         ZX_REPORTING_CODES_B.reporting_code_id%type;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
                  'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.BEGIN',
                  'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- pull in detail tax lines created from summary tax lines and perform
  -- tax registration number determination
  --
  l_new_row_num :=
            NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);

  FOR imported_tax_line_rec IN get_imported_det_tax_lines_csr LOOP

    -- create a new tax line in g_detail_tax_lines_tbl
    --
    l_new_row_num := l_new_row_num + 1;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num) :=
                                                       imported_tax_line_rec;
    -- set l_begin_index
    --
    IF l_begin_index IS NULL THEN
      l_begin_index := l_new_row_num;
    END IF;

    -- populate hq_estb_party_tax_prof_id
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).hq_estb_party_tax_prof_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.hq_estb_party_tax_prof_id(
                                                                p_trx_line_index);
    -- get l_def_reg_type and l_reg_rule_flg from tax chche
    --
    l_tax_id := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                         l_new_row_num).tax_id;
    l_def_reg_type := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                                          l_tax_id).def_registr_party_type_code;
    l_reg_rule_flg := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                                          l_tax_id).registration_type_rule_flag;

    ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration(
                 p_event_class_rec,
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                 l_new_row_num).tax_regime_code,
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                          l_new_row_num).tax_id,
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                             l_new_row_num).tax,
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                              l_new_row_num).tax_determine_date,
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                           l_new_row_num).tax_jurisdiction_code,
                 l_def_reg_type,
                 l_reg_rule_flg,
                 p_trx_line_index,
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         l_new_row_num).tax_registration_number,
                 l_tax_amt_included_flag,
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                              l_new_row_num).self_assessed_flag,
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                       l_new_row_num).tax_reg_num_det_result_id,
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                              l_new_row_num).rounding_rule_code,
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         l_new_row_num).registration_party_type,
                 x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
               'Incorrect return_status after calling ' ||
               'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration');
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
               'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
      END IF;
      RETURN;
    END IF;
    l_reporting_code_id:= ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id(
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_reg_num_det_result_id,
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).trx_date);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).legal_message_trn := l_reporting_code_id;
    -- get registration number for legal entity
    --
    ZX_TDS_APPLICABILITY_DETM_PKG.get_legal_entity_registration(
                                  p_event_class_rec => p_event_class_rec,
                                  p_trx_line_index  => p_trx_line_index,
                                  p_tax_line_index  => l_new_row_num,
                                  x_return_status   => x_return_status,
                                  x_error_buffer    => l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
               'Incorrect return_status after calling ' ||
               'ZX_TDS_APPLICABILITY_DETM_PKG.get_legal_entity_registration');
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
               'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
      END IF;
      RETURN;
    END IF;

    -- If tax_amt_included_flag from summary tax line is null, get
    -- l_tax_amt_included_flag with tax registration and populate it onto
    -- detail tax line
    --
    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               l_new_row_num).tax_amt_included_flag IS NULL THEN
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_amt_included_flag := l_tax_amt_included_flag;

    END IF;

    -- calculate taxable basis for imported tax lines
    --
    l_tax_rate := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                    l_new_row_num).tax_rate;
    IF l_tax_rate <> 0 THEN

      -- Bug 3518261: Calculate taxable_amt for imported tax lines
      --

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                 l_new_row_num).unrounded_taxable_amt:=
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               l_new_row_num).unrounded_tax_amt/l_tax_rate*100;

    ELSE   -- l_tax_rate = 0

      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_new_row_num).unrounded_tax_amt = 0  THEN
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                     l_new_row_num).unrounded_taxable_amt :=
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index);

      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                 'Tax_rate = 0, tax_amt <> 0. ' ||
                 'Cannot calculate taxable basis amount.');
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                 'x_return_status = ' || x_return_status);
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
                 'ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis (-)');
        END IF;

        FND_MESSAGE.SET_NAME('ZX','ZX_IMP_TAX_RATE_AMT_MISMATCH');

        -- FND_MSG_PUB.Add;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

        ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

        RETURN;
      END IF;
    END IF;    -- l_tax_rate <> 0 OR ELSE

    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_trx_line_index) IS NOT NULL
    THEN
      OPEN get_key_columns_cur(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_regime_code,
                               ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax,
			       NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_apportionment_line_number, 1)
                              );

      FETCH get_key_columns_cur INTO l_adjusted_doc_tax_line_id;

       IF get_key_columns_cur%FOUND THEN
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).adjusted_doc_tax_line_id := l_adjusted_doc_tax_line_id;
	 IF (g_level_event >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_event,'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                  'l_adjusted_doc_tax_line_id: ' || l_adjusted_doc_tax_line_id);
         END IF;
      END IF;
      CLOSE get_key_columns_cur;
    END IF;

  END LOOP;    -- imported_tax_line_rec IN get_imported_det_tax_lines_csr

  -- set l_end_index
  --
  IF l_begin_index IS NOT NULL THEN

    l_end_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST;

    -- delete the pulled-in tax lines from zx_detail_tax_lines_gt
    --
    DELETE /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
      FROM  zx_detail_tax_lines_gt
     WHERE application_id =p_event_class_rec.application_id
       AND entity_code =p_event_class_rec.entity_code
       AND event_class_code =p_event_class_rec.event_class_code
       AND trx_id = p_event_class_rec.trx_id
       AND trx_line_id =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index)
       AND trx_level_type =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                    'Begin_index and end_index for detail tax lines created ' ||
                    'from summary tax_line');
      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                    'l_begin_index :=' || l_begin_index);
      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                    'l_end_index :=' || l_end_index);
    END IF;

    -- copy transaction information
    --
    ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines(
      		 p_trx_line_index,
      		 l_begin_index,
      		 l_end_index,
      		 x_return_status,
      		 l_error_buffer );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
               'Incorrect return_status after calling '||
               'ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines');
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
               'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
      END IF;
      RETURN;
    END IF;

    -- bug 6634198: set orig_tax_amt
    --
    FOR i IN NVL(l_begin_index, 0) .. NVL(l_end_index, -1) LOOP
      l_tax_rate := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate;
      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_amt_included_flag = 'Y' THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).orig_tax_amt :=
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).line_amt * l_tax_rate/(100+l_tax_rate);

      ELSE
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).orig_tax_amt :=
           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).line_amt * l_tax_rate/100;
      END IF;
     END LOOP;
  END IF;

  -- set l_begin_index_additional
  --
  l_begin_index_additional :=
        NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0) + 1;

/* Bug 5688340: Rearranged the order of conditions in IF statement (ie. pulled
  adjusted_doc is NOT NULL condition before applied_from).
  The receipt application in AR causes a tax adjustment to be created in eBTax,
  if an earned discount is recognized. In this case, AR passes invoice info
  in adjusted doc columns and cash receipt info in applied from columns.
  In this case, tax calculation must be done using invoice (ie. adjusted doc info).
*/

  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(
                                              p_trx_line_index) IS NOT NULL
  THEN

    get_taxes_from_adjusted_to(
                p_event_class_rec,
                p_trx_line_index,
                p_tax_date,
                p_tax_determine_date,
                p_tax_point_date,
                l_begin_index,
                l_end_index,
                x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF g_level_unexpected >= g_current_runtime_level THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
               'Incorrect return_status after calling ' ||
               'ZX_TDS_TAX_ROUNDING_PKG.get_taxes_from_adjusted_to()');
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
      END IF;
      RETURN;
    END IF;
  ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(
                                              p_trx_line_index) IS NOT NULL
  THEN

    get_taxes_from_applied_from(
                p_event_class_rec,
                p_trx_line_index,
                p_tax_date,
                p_tax_determine_date,
                p_tax_point_date,
                l_begin_index,
                l_end_index,
                x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF g_level_unexpected >= g_current_runtime_level THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
               'Incorrect return_status after calling ' ||
               'ZX_TDS_TAX_ROUNDING_PKG.get_taxes_from_applied_from()');
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
      END IF;
      RETURN;
    END IF;

  ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                  p_trx_line_index) ='LINE_INFO_TAX_ONLY' THEN

    -- Bug 3010729: skip performing additional applicability for trx lines with
    -- line level  action 'LINE_INFO_TAX_ONLY'
    --
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
             'line_ level_action on trx line is LINE_INFO_TAX_ONLY, ' ||
             'skip performing additional applicability ');
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
             'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
    END IF;
    RETURN;

  ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                   p_trx_line_index) ='CREATE'
     OR (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                   p_trx_line_index) ='CREATE_WITH_TAX'
         AND p_event_class_rec.perf_addnl_appl_for_imprt_flag = 'Y')
  THEN

    IF p_event_class_rec.process_for_applicability_flag = 'Y' AND
       NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg, 'Y') = 'Y' AND
         -- for TM, check source_process_for_appl_flag to determine
         -- whether tax needs to be calcualted or not.
         NVL(p_event_class_rec.source_process_for_appl_flag, 'Y') = 'Y'
    THEN

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
               'Start performing additional applicability process. ');
      END IF;

      /* Start: Added for Bug 4959835 */
      -- Based on the Regime Usage code, either direct rate determination
      -- processing has to be performed or it should goto the loop part below.
      -- If the Regime determination template is 'STCC' (non-location based)
      -- then, call get process results directly
      -- Else (for location based) call tax applicability.

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
               'template_usage_code = '||p_event_class_rec.template_usage_code);
      END IF;

      IF p_event_class_rec.template_usage_code = 'TAX_RULES'
      THEN

        -- The direct rate determination is coded in the applicability pkg
        -- in order to reuse some of the existing logic there.
        --
        ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(p_trx_line_index,
                                                          p_tax_date,
                                                          p_tax_determine_date,
                                                          p_tax_point_date,
                                                          p_event_class_rec,
                                                          l_begin_index,
                                                          l_end_index,
                                                          x_return_status);

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF (g_level_unexpected >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results()');
    	       FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                    'RETURN_STATUS = ' || x_return_status);
  	       FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
                    'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
           END IF;
  	     RETURN;
  	   END IF;


      ELSE

        FOR regime_index IN
            NVL(ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.FIRST, 0)..
            NVL(ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.LAST, -1)
        LOOP

          IF  ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(
                            regime_index).trx_line_index = p_trx_line_index  THEN
            -- Get tax_provider_id
            --
            l_tax_regime_id := ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(
                                                      regime_index).tax_regime_id;
            l_provider_id := ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(
                                                 l_tax_regime_id).tax_provider_id;
            IF (l_provider_id IS NULL) THEN

              -- If the provider id is null, OTE needs to calculate tax
              --
              ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes (
                                   l_tax_regime_id,
                                   ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(
                                                l_tax_regime_id).tax_regime_code,
                                   p_trx_line_index,
                                   p_event_class_rec,
                                   p_tax_date,
                                   p_tax_determine_date,
                                   p_tax_point_date,
                                   l_begin_index,
                                   l_end_index,
                                   x_return_status );

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                         'Incorrect return_status after calling ' ||
                         'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes()');
                  FND_LOG.STRING(g_level_unexpected,
                         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                         'RETURN_STATUS = ' || x_return_status);
                  FND_LOG.STRING(g_level_unexpected,
                         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
                         'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
                END IF;
    	      RETURN;
    	    END IF;
            END IF;  -- For provider ID
          END IF;    -- For detail_regime for this transaction line
        END LOOP;    -- Loop For regime_index
      END IF;        -- template_usage_code = 'TAX_RULES
    END IF;          -- NVL(g_process_for_appl_flg, 'Y') = 'Y'
  END IF;            -- Get tax from other doc, or get additional applicable taxes

  -- set l_end_index_additional if l_end_index is not null
  --
  IF l_end_index IS NOT NULL AND l_end_index >= l_begin_index_additional THEN
    l_end_index_additional := l_end_index;
  END IF;

  -- bug fix 3438498
  -- When self_assess_tax_lines_flag is 'Y', set self_assessed_flag = 'Y'
  -- for all the newly founded detail tax lines.to keep the lines as self
  -- assessed for the second time calculation, set overriden_flag
  -- and orig_self_assessed_flag
  --
  IF p_event_class_rec.self_assess_tax_lines_flag ='Y' AND
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                        p_trx_line_index) ='CREATE_WITH_TAX'
  THEN
    FOR i IN NVL(l_begin_index_additional, 0) .. NVL(l_end_index_additional, -1)
    LOOP
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                               i).self_assessed_flag := 'Y';
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                 i).overridden_flag  := 'Y';
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                          i).orig_self_assessed_flag := 'X';
    END LOOP;
  END IF;

  -- call the internal processes only if tax created
  --
  IF l_begin_index_additional IS NOT NULL AND l_end_index_additional IS NOT NULL
  THEN

     -- get tax status
     --
     ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status (
					l_begin_index_additional,
					l_end_index_additional,
					'TRX_LINE_DIST_TBL',
					p_trx_line_index,
					p_event_class_rec,
					x_return_status,
					l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status()');
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
                      'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
      END IF;
      RETURN;
    END IF;

    -- get tax rate
    --
    ZX_TDS_RATE_DETM_PKG.get_tax_rate(
				l_begin_index_additional,
				l_end_index_additional,
				p_event_class_rec,
				'TRX_LINE_DIST_TBL',
				p_trx_line_index,
				x_return_status,
				l_error_buffer );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_RATE_DETM_PKG.get_tax_rate()');
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
                      'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
      END IF;
      RETURN;
    END IF;

    -- Get taxable basis
    --
    ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis(
					l_begin_index_additional,
					l_end_index_additional,
					p_event_class_rec,
					'TRX_LINE_DIST_TBL',
					p_trx_line_index,
					x_return_status,
					l_error_buffer );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                      'Incorrect return_status after calling ' || '
                       ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis()');
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
                      'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
      END IF;
      RETURN;
    END IF;

    -- Calculate tax amount
    --
    ZX_TDS_CALC_PKG.get_tax_amount(
				l_begin_index_additional,
				l_end_index_additional,
				p_event_class_rec,
				'TRX_LINE_DIST_TBL',
				p_trx_line_index,
				x_return_status,
				l_error_buffer );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_CALC_PKG.Get_tax_amount()');
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
                      'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
      END IF;
      RETURN;
    END IF;

    --
    -- populate Process_For_Recovery_Flag
    --
    ZX_TDS_TAX_LINES_POPU_PKG.populate_recovery_flg(
                                                l_begin_index,
                                                l_end_index,
                                                p_event_class_rec,
                                                x_return_status,
                                                l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      RETURN;
    END IF;

    -- Call Internal_Flag Service to check mandatory columns, like WHO columns,
    -- line ids, etc, and populate values if they are missing.
    --
    ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line(
						l_begin_index,
						l_end_index,
						x_return_status,
						l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line()');
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
                      'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
      END IF;
      RETURN;
    END IF;
  END IF;   -- l_begin_index_additional and l_end_index_additional not null

  IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
                  'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                  'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_event,
                  'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
                  'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import.END',
                    'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(-)');
    END IF;
END calculate_tax_for_import;

/* ======================================================================*
 | Private procedure  create_detail_tax_line                            |
 * ======================================================================*/
 PROCEDURE create_detail_tax_line (
  p_event_class_rec         IN 	           zx_api_pub.event_class_rec_type,
  p_tax_line_rec	    IN	    	   tax_line_rec_type,
  p_new_row_num		    IN		   NUMBER,
  p_tax_class               IN             zx_rates_b.tax_class%TYPE,
  x_return_status              OUT NOCOPY  VARCHAR2) IS

 l_tax_regime_rec	ZX_GLOBAL_STRUCTURES_PKG.tax_regime_rec_type;
 l_tax_rec		ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
 l_tax_status_rec	ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
 l_tax_jur_rec	        ZX_TDS_UTILITIES_PKG.zx_jur_info_cache_rec_type;
 l_tax_rate_rec         ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

 l_tax_date             DATE;
 l_tax_determine_date   DATE;
 l_tax_point_date       DATE;
 l_error_buffer		VARCHAR2(240);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line.BEGIN',
               'ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line(+)');

    FND_LOG.STRING(g_level_event,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
               'new tax line created (tax := '|| p_tax_line_rec.tax || ')');
    FND_LOG.STRING(g_level_event,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
               'tax_regime_code := '|| p_tax_line_rec.tax_regime_code);
  END IF;

  -- get tax dates
  --
  -- added for bug 5018766
  IF ( p_tax_line_rec.tax_date IS NULL )  THEN
	  l_tax_date :=
	    NVL(p_tax_line_rec.related_doc_date,
	      NVL(p_tax_line_rec.provnl_tax_determination_date,
	       NVL(p_tax_line_rec.adjusted_doc_date,
		 NVL(p_tax_line_rec.trx_line_date, p_tax_line_rec.trx_date))));
  ELSE
         l_tax_date := p_tax_line_rec.tax_date ;
  END IF ;

  -- added for bug 5018766
  IF ( p_tax_line_rec.tax_determine_date IS NULL )  THEN
	  l_tax_determine_date :=
	    NVL(p_tax_line_rec.related_doc_date,
	      NVL(p_tax_line_rec.provnl_tax_determination_date,
	       NVL(p_tax_line_rec.adjusted_doc_date,
		 NVL(p_tax_line_rec.trx_line_date, p_tax_line_rec.trx_date))));
  ELSE
      l_tax_determine_date := p_tax_line_rec.tax_determine_date;
  END IF ;

  -- added for bug 5018766
  IF ( p_tax_line_rec.tax_point_date IS NULL )  THEN
	  l_tax_point_date :=
	    NVL(p_tax_line_rec.related_doc_date,
	      NVL(p_tax_line_rec.provnl_tax_determination_date,
	       NVL(p_tax_line_rec.adjusted_doc_date,
		 NVL(p_tax_line_rec.trx_line_date, p_tax_line_rec.trx_date))));
 ELSE
    l_tax_point_date := p_tax_line_rec.tax_point_date;
 END IF ;

  -- populate tax_regime_cache_info
  --
  ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
			p_tax_line_rec.tax_regime_code,
			l_tax_determine_date,
			l_tax_regime_rec,
			x_return_status,
			l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_regime_cache_info()');
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
                    'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line.END',
                    'ZX_TDS_IMPORT_DOCUMENT_PKG.' ||
                    'create_detail_tax_line(-)');
    END IF;
    RETURN;
  END IF;

  -- populate tax cache, if it does not exist there.
  --
  ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                        p_tax_line_rec.tax_regime_code,
			p_tax_line_rec.tax,
			l_tax_determine_date,
			l_tax_rec,
			x_return_status,
                        l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_tax_cache_info()');
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
                    'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line.END',
                    'ZX_TDS_IMPORT_DOCUMENT_PKG.' ||
                    'create_detail_tax_line(-)');
    END IF;
    RETURN;
  END IF;
--jurcode
  -- populate jurisdiction cache, if it does not exist there.
  --
  IF p_tax_line_rec.tax_jurisdiction_code IS NOT NULL THEN

    ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info(
                        p_tax_line_rec.tax_regime_code,
			p_tax_line_rec.tax,
			p_tax_line_rec.tax_jurisdiction_code,
			l_tax_determine_date,
			l_tax_jur_rec,
			x_return_status,
                        l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info()');
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line.END',
                      'ZX_TDS_IMPORT_DOCUMENT_PKG.' ||
                      'create_detail_tax_line(-)');
      END IF;
      RETURN;
    END IF;
  END IF;
--endjurcode
  -- populate tax_status_cahce_info
  --
  ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
			p_tax_line_rec.tax,
			p_tax_line_rec.tax_regime_code,
			p_tax_line_rec.tax_status_code,
			l_tax_determine_date,
			l_tax_status_rec,
			x_return_status,
			l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info()');
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
                    'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line.END',
                    'ZX_TDS_IMPORT_DOCUMENT_PKG.' ||
                    'create_detail_tax_line(-)');
    END IF;
    RETURN;
  END IF;

  -- populate tax_rate_id
  --
  -- validate and populate tax_rate_id
  --
  ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
  		p_tax_line_rec.tax_regime_code,
                p_tax_line_rec.tax,
                p_tax_line_rec.tax_jurisdiction_code,
                p_tax_line_rec.tax_status_code,
                p_tax_line_rec.tax_rate_code,
  		l_tax_determine_date,
                p_tax_class,
  		l_tax_rate_rec,
  		x_return_status,
    		l_error_buffer);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_rate_id
      :=   l_tax_rate_rec.tax_rate_id;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
                    'After calling ZX_TDS_UTILITIES_PKG.get_tax_rate_info()');
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
                    'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line.END',
                    'ZX_TDS_IMPORT_DOCUMENT_PKG.' ||
                    'create_detail_tax_line(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
                  'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                  'summary_tax_line_number := '||
                   p_tax_line_rec.summary_tax_line_number);
    FND_LOG.STRING(g_level_event,
                  'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                  'tax_regime_code := ' || p_tax_line_rec.tax_regime_code);
    FND_LOG.STRING(g_level_event,
                  'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines',
                  'tax := ' || p_tax_line_rec.tax);
  END IF;

  -- populate tax_line_id from Sequence
  --
  /*
   * populate in ZX_TDS_TAX_LINES_POPU_PKG
   *
   * SELECT zx_lines_s.NEXTVAL INTO
   *        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   *                                 p_new_row_num).tax_line_id from dual;
   */

  -- populate tax_regime_id, tax_id, tax_status_id, tax_rate_id
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                p_new_row_num).tax_regime_id := l_tax_regime_rec.tax_regime_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                     p_new_row_num).tax_id := l_tax_rec.tax_id;

  -- bug 5077691: populate legal_reporting_status
  IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                p_new_row_num).legal_reporting_status :=
                                     l_tax_rec.legal_reporting_status_def_val;
  END IF;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                     p_new_row_num).tax_jurisdiction_id :=
                                             l_tax_jur_rec.tax_jurisdiction_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                p_new_row_num).tax_status_id := l_tax_status_rec.tax_status_id;

  -- populate data from summary tax line
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          p_new_row_num).tax_regime_code := p_tax_line_rec.tax_regime_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  p_new_row_num).tax := p_tax_line_rec.tax;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          p_new_row_num).tax_status_code := p_tax_line_rec.tax_status_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              p_new_row_num).tax_rate_code := p_tax_line_rec.tax_rate_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        p_new_row_num).tax_rate := p_tax_line_rec.tax_rate;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        p_new_row_num).tax_jurisdiction_code :=
                                       p_tax_line_rec.tax_jurisdiction_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        p_new_row_num).tax_amt_included_flag :=
                                       p_tax_line_rec.tax_amt_included_flag;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         p_new_row_num).tax_exception_id := p_tax_line_rec.tax_exception_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         p_new_row_num).tax_exemption_id := p_tax_line_rec.tax_exemption_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     p_new_row_num).exempt_reason_code := p_tax_line_rec.exempt_reason_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     p_new_row_num).exempt_certificate_number :=
                                   p_tax_line_rec.exempt_certificate_number;

  -- If the value of p_event_class_rec.tax_recovery_flag is 'N',
  -- populate process_for_recovery_flag to 'N'. If it is 'Y', check
  -- reporting_only_flag to set tax_recovery_flag
  --
  /*
   * call populate_recovery_flg in ZX_TDS_TAX_LINES_POPU_PKG instead
   *
   * IF NVL(p_event_class_rec.tax_recovery_flag, 'N') = 'N' THEN
   *   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   *                             p_new_row_num).process_for_recovery_flag := 'N';
   *  ELSE
   *  IF NVL(l_tax_rec.reporting_only_flag, 'N') <> 'Y' THEN
   *                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   *                              p_new_row_num).process_for_recovery_flag := 'Y';
   *  ELSE
   *     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   *                             p_new_row_num).process_for_recovery_flag := 'N';
   *   END IF;
   *  END IF;
   */

  -- populate rounding_lvl_party_tax_prof_id and rounding_level_code
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           p_new_row_num).rounding_lvl_party_tax_prof_id :=
                      ZX_TDS_CALC_SERVICES_PUB_PKG.g_rnd_lvl_party_tax_prof_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  p_new_row_num).rounding_lvl_party_type :=
                        ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_lvl_party_type;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                          p_new_row_num).rounding_level_code :=
                                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level;

  -- populate tax dates
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         p_new_row_num).tax_date := l_tax_date;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     p_new_row_num).tax_determine_date := l_tax_determine_date;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                             p_new_row_num).tax_point_date := l_tax_point_date;

  -- populate the tax_currency_conversion_date as this field is mandatroy
  -- incase trx_currency and tax_currency are different. (8322086)
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          p_new_row_num).tax_currency_conversion_date := l_tax_determine_date;

  -- bug 3282018: set manually_entered_flag='Y', last_manual_entry='TAX_AMOUNT'
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                    p_new_row_num).manually_entered_flag := 'Y';
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               p_new_row_num).last_manual_entry := 'TAX_AMOUNT';

  -- set self_assesses_flag = 'N' for all detail tax lines created from summary
  -- tax lines
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                       p_new_row_num).self_assessed_flag := 'N';

  -- set proration_code
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              p_new_row_num).proration_code := 'REGULAR_IMPORT';

  -- populate mandatory columns
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       p_new_row_num).internal_organization_id :=
                                        p_tax_line_rec.internal_organization_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              p_new_row_num).application_id := p_event_class_rec.application_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    p_new_row_num).entity_code := p_event_class_rec.entity_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          p_new_row_num).event_class_code := p_event_class_rec.event_class_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            p_new_row_num).event_type_code := p_event_class_rec.event_type_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              p_new_row_num).trx_id := p_event_class_rec.trx_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       p_new_row_num).trx_line_id := p_tax_line_rec.trx_line_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 p_new_row_num).trx_level_type := p_tax_line_rec.trx_level_type;

  -- Bug#457200-  populate content_owner_id
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                p_new_row_num).content_owner_id := p_event_class_rec.first_pty_org_id;

  -- populate interface_tax_line_id, interface_entity_code for AR import service
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).interface_tax_line_id := p_tax_line_rec.interface_tax_line_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).interface_entity_code := p_tax_line_rec.interface_entity_code;

  -- Bug 7117340 -- DFF ER
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute1 := p_tax_line_rec.attribute1;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute2 := p_tax_line_rec.attribute2;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute3 := p_tax_line_rec.attribute3;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute4 := p_tax_line_rec.attribute4;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute5 := p_tax_line_rec.attribute5;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute6 := p_tax_line_rec.attribute6;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute7 := p_tax_line_rec.attribute7;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute8 := p_tax_line_rec.attribute8;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute9 := p_tax_line_rec.attribute9;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute10 := p_tax_line_rec.attribute10;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute11 := p_tax_line_rec.attribute11;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute12 := p_tax_line_rec.attribute12;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute13 := p_tax_line_rec.attribute13;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute14 := p_tax_line_rec.attribute14;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute15 := p_tax_line_rec.attribute15;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   p_new_row_num).attribute_category:= p_tax_line_rec.attribute_category;


  /*
   * populate WHO columns in ZX_TDS_TAX_LINES_POPU_PKG
   *
   * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   *                                p_new_row_num).created_by := fnd_global.user_id;
   * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   *                                    p_new_row_num).creation_date :=  sysdate;
   * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   *                         p_new_row_num).last_updated_by := fnd_global.user_id;
   * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   *                                  p_new_row_num).last_update_date :=  sysdate;
   * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   *                     p_new_row_num).last_update_login := fnd_global.login_id;
   */

  IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
                  'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
                  'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_event,
                  'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line.END',
                  'ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line.END',
                    'ZX_TDS_IMPORT_DOCUMENT_PKG.create_detail_tax_line(-)');
    END IF;

END create_detail_tax_line;

----------------------------------------------------------------------
--  PROCEDURE
--   get_taxes_from_applied_from
--
--  DESCRIPTION
--
--  This procedure get detail tax lines from applied from document
--
--  IN      p_trx_line_index
--
--  IN OUT NOCOPY
--          x_begin_index
--          x_end_index
--  OUT NOCOPY     x_return_status

PROCEDURE get_taxes_from_applied_from(
  p_event_class_rec	   IN 		        zx_api_pub.event_class_rec_type,
  p_trx_line_index	   IN	       	  	BINARY_INTEGER,
  p_tax_date		   IN   	 	DATE,
  p_tax_determine_date     IN   	 	DATE,
  p_tax_point_date         IN   	 	DATE,
  x_begin_index 	   IN OUT NOCOPY	BINARY_INTEGER,
  x_end_index		   IN OUT NOCOPY	BINARY_INTEGER,
  x_return_status	   OUT NOCOPY 	        VARCHAR2) IS

 CURSOR get_tax_lines_csr IS
   SELECT * FROM zx_lines
    WHERE application_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_index)
      AND entity_code =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(p_trx_line_index)
      AND event_class_code  =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(p_trx_line_index)
      AND trx_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(p_trx_line_index)
      AND trx_line_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(p_trx_line_index)
      AND trx_level_type =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(p_trx_line_index)
      AND tax_provider_id IS NULL
      AND cancel_flag<> 'Y'
      --AND offset_link_to_tax_line_id IS NULL
      AND mrc_tax_line_flag = 'N';

 l_new_row_num			NUMBER;
 l_error_buffer			VARCHAR2(200);
 l_line_amt_current		NUMBER;
 l_orig_begin_index 		BINARY_INTEGER;
 l_orig_end_index 		BINARY_INTEGER;
 l_tax_tbl_index		NUMBER;

 l_tax_regime_rec   	        zx_global_structures_pkg.tax_regime_rec_type;
 l_tax_rec                      ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
 l_tax_jur_rec	                ZX_TDS_UTILITIES_PKG.zx_jur_info_cache_rec_type;
 l_tax_status_rec               ZX_TDS_UTILITIES_PKG.zx_status_info_rec;

 l_orig_amt                     NUMBER;
 l_appl_tax_amt                 NUMBER;
 l_appl_line_amt                NUMBER;
 l_unrounded_tax_amt            NUMBER;
 l_reporting_code_id          ZX_REPORTING_CODES_B.reporting_code_id%type;
BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from.BEGIN',
       'ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from(+)');
    FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
       'p_trx_line_index = ' || to_char(p_trx_line_index));
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- initialize local variables
  --
  -- bug fix 4867933 begin
  -- l_new_row_num := NVL(x_end_index, 0);
  l_new_row_num := NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);
  l_orig_begin_index := x_begin_index;
  l_orig_end_index := x_end_index;

  FOR tax_line_rec in get_tax_lines_csr LOOP

    l_tax_tbl_index := ZX_TDS_UTILITIES_PKG.get_tax_index (
       tax_line_rec.tax_regime_code,
       tax_line_rec.tax,
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index),
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index),
       l_orig_begin_index,
       l_orig_end_index,
       x_return_status);

    IF l_tax_tbl_index IS NULL THEN

      -- This is a missing tax line, create a new detail tax line in
      -- g_detail_tax_lines_tbl
      --
      l_new_row_num := l_new_row_num +1;

      -- populate tax related information from tax_line_rec
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_regime_code:=tax_line_rec.tax_regime_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                          l_new_row_num).tax := tax_line_rec.tax;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_status_code:=tax_line_rec.tax_status_code;

      -- validate and populate tax_regime_id
      --
      ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
    			tax_line_rec.tax_regime_code,
    			p_tax_determine_date,
    			l_tax_regime_rec,
    			x_return_status,
    			l_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.get_regime_cache_info');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from.END',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_from_applied_from(-)');
        END IF;
        RETURN;
      END IF;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).tax_regime_id :=
                                      l_tax_regime_rec.tax_regime_id;

      -- validate and populate tax_id
      --
      ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
    			tax_line_rec.tax_regime_code,
                        tax_line_rec.tax,
    			p_tax_determine_date,
    			l_tax_rec,
    			x_return_status,
    			l_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.get_tax_cache_info');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from.END',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_from_applied_from(-)');
        END IF;
        RETURN;
      END IF;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                      l_new_row_num).tax_id := l_tax_rec.tax_id;

      -- bug 5077691: populate legal_reporting_status
      IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_new_row_num).legal_reporting_status :=
                                       l_tax_rec.legal_reporting_status_def_val;
      END IF;

      --jurcode
      -- populate jurisdiction cache, if it does not exist there.
      --
      IF tax_line_rec.tax_jurisdiction_code IS NOT NULL THEN

        ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info(
                            tax_line_rec.tax_regime_code,
    			    tax_line_rec.tax,
    			    tax_line_rec.tax_jurisdiction_code,
    			    p_tax_determine_date,
    			    l_tax_jur_rec,
    			    x_return_status,
                            l_error_buffer);


        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
                          'Incorrect return_status after calling ' ||
                          'ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info()');
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
                          'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from.END',
                          'ZX_TDS_IMPORT_DOCUMENT_PKG.' ||
                          'create_detail_tax_line(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                             l_new_row_num).tax_jurisdiction_id :=
                                              l_tax_jur_rec.tax_jurisdiction_id;
      END IF;

      -- validate and populate tax_status_id
      --
      ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                        tax_line_rec.tax,
    			tax_line_rec.tax_regime_code,
                        tax_line_rec.tax_status_code,
    			p_tax_determine_date,
    			l_tax_status_rec,
    			x_return_status,
    			l_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from.END',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_from_applied_from(-)');
        END IF;
        RETURN;
      END IF;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 l_new_row_num).tax_status_id := l_tax_status_rec.tax_status_id;

      -- populate taxable_basis_formula and tax_calculation_formula
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_new_row_num).taxable_basis_formula :=
                                               tax_line_rec.taxable_basis_formula;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_new_row_num).tax_calculation_formula :=
                                             tax_line_rec.tax_calculation_formula;

      -- 1. If applied_amt_handling_flag ='P', populate tax rate percentage from
      --    applied from document. Tax is proarted based the amount applied.
      -- 2. If applied_amt_handling_flag ='R', populate tax rate Code from
      --    applied document. Tax rate is determined in the current document.
      --    Tax is recalculated based one the tax rate in the current document.

      IF ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
           tax_line_rec.tax_id).applied_amt_handling_flag = 'P' THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_rate_code := tax_line_rec.tax_rate_code;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).tax_rate_id := tax_line_rec.tax_rate_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              l_new_row_num).tax_rate :=  tax_line_rec.tax_rate;

      ELSIF ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
           tax_line_rec.tax_id).applied_amt_handling_flag = 'R' THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_rate_code := tax_line_rec.tax_rate_code;

        IF tax_line_rec.line_amt <> 0 THEN

          -- prorate prd_total_tax_amt, prd_total_tax_amt_tax_curr and
          -- prd_total_tax_amt_funcl_curr
          --
          l_line_amt_current :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index);

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).prd_total_tax_amt := tax_line_rec.tax_amt *
                                       (l_line_amt_current/tax_line_rec.line_amt);
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                            l_new_row_num).prd_total_tax_amt_tax_curr :=
                                 tax_line_rec.tax_amt_tax_curr *
                                         l_line_amt_current/tax_line_rec.line_amt;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_new_row_num).prd_total_tax_amt_funcl_curr :=
                                 tax_line_rec.tax_amt_funcl_curr *
                                         l_line_amt_current/tax_line_rec.line_amt;

          -- do rounding. May be moved to rounding package later
          --
          IF tax_line_rec.ledger_id IS NOT NULL THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        l_new_row_num).prd_total_tax_amt_funcl_curr :=
                   ZX_TRD_SERVICES_PUB_PKG.round_amt_to_mau (
                        tax_line_rec.ledger_id,
                        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_new_row_num).prd_total_tax_amt_funcl_curr);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
                   'Incorrect return_status after calling ' ||
                   'ZX_TRD_SERVICES_PUB_PKG.round_amt_to_mau');
                FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
                   'RETURN_STATUS = ' || x_return_status);
                FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from.END',
                   'ZX_APPLICABILITY_DETM_PKG.get_taxes_from_applied_from(-)');
              END IF;
              RETURN;
            END IF;
          END IF;     -- tax_line_rec.line_amt <> 0
        END IF;       -- tax_line_rec.ledger_id IS NOT NULL
      END IF;         -- applied_amt_handling_flag = 'P' or 'R'

      -- Populate other doc line amt, taxable amt and tax amt
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).other_doc_line_amt := tax_line_rec.line_amt;

      -- bug 7024219
      --
      IF NVL(tax_line_rec.historical_flag, 'N') = 'Y' THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).other_doc_line_taxable_amt :=
               NVL(tax_line_rec.unrounded_taxable_amt, tax_line_rec.taxable_amt);

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).other_doc_line_tax_amt :=
                      NVL(tax_line_rec.unrounded_tax_amt, tax_line_rec.tax_amt);

      ELSE

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).other_doc_line_taxable_amt :=
                                              tax_line_rec.unrounded_taxable_amt;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).other_doc_line_tax_amt :=
                                                  tax_line_rec.unrounded_tax_amt;
      END IF;

      -- Set copied_from_other_doc_flag to 'Y'
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                l_new_row_num).copied_from_other_doc_flag := 'Y';

      -- set other_doc_source
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                l_new_row_num).other_doc_source := 'APPLIED_FROM';

      -- populate manually_entered_flag, overridden_flag and last_manual_entry
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                    l_new_row_num).manually_entered_flag := 'Y';
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                           l_new_row_num).overridden_flag := 'Y';
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                l_new_row_num).last_manual_entry := 'TAX_AMOUNT';

      -- populate other columns
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).rounding_level_code := tax_line_rec.rounding_level_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).rounding_rule_code := tax_line_rec.rounding_rule_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            l_new_row_num).tax_date := p_tax_date;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        l_new_row_num).tax_determine_date := p_tax_determine_date;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                l_new_row_num).tax_point_date := p_tax_point_date;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).offset_flag := tax_line_rec.offset_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).offset_tax_rate_code := tax_line_rec.offset_tax_rate_code;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).place_of_supply := tax_line_rec.place_of_supply;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).place_of_supply_type_code :=
                                           tax_line_rec.place_of_supply_type_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).place_of_supply_result_id :=
                                          tax_line_rec.place_of_supply_result_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).legal_message_pos :=
                                          tax_line_rec.legal_message_pos;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_currency_code := tax_line_rec.tax_currency_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).tax_type_code := tax_line_rec.tax_type_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).reporting_only_flag := tax_line_rec.reporting_only_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).tax_jurisdiction_code :=
                                              tax_line_rec.tax_jurisdiction_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          l_new_row_num).tax_jurisdiction_id := tax_line_rec.tax_jurisdiction_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_new_row_num).tax_registration_number :=
                                           tax_line_rec.tax_registration_number;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_new_row_num).registration_party_type :=
                                           tax_line_rec.registration_party_type;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).tax_applicability_result_id :=
                                        tax_line_rec.tax_applicability_result_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).legal_message_appl_2 :=
                                        tax_line_rec.legal_message_appl_2;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).legal_message_appl_2 :=
                                        tax_line_rec.legal_message_appl_2;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).direct_rate_result_id :=
                                             tax_line_rec.direct_rate_result_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).legal_message_rate :=
                                             tax_line_rec.legal_message_rate;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).rounding_lvl_party_tax_prof_id :=
                                     tax_line_rec.rounding_lvl_party_tax_prof_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).rounding_lvl_party_type :=
                                            tax_line_rec.rounding_lvl_party_type;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).self_assessed_flag := tax_line_rec.self_assessed_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                            l_new_row_num).tax_reg_num_det_result_id :=
                                         tax_line_rec.tax_reg_num_det_result_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                            l_new_row_num).legal_message_trn :=
                                         tax_line_rec.legal_message_trn;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
       l_new_row_num).tax_amt_included_flag := tax_line_rec.tax_amt_included_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_only_line_flag := tax_line_rec.tax_only_line_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).tax_provider_id := tax_line_rec.tax_provider_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).status_result_id
        := tax_line_rec.status_result_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).legal_message_status
        := tax_line_rec.legal_message_status ;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).rate_result_id
        := tax_line_rec.rate_result_id;
      -- Bug 7117340 -- DFF ER
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute1
        := tax_line_rec.attribute1;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute2
        := tax_line_rec.attribute2;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute3
        := tax_line_rec.attribute3;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute4
        := tax_line_rec.attribute4;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute5
        := tax_line_rec.attribute5;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute6
        := tax_line_rec.attribute6;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute7
        := tax_line_rec.attribute7;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute8
        := tax_line_rec.attribute8;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute9
        := tax_line_rec.attribute9;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute10
        := tax_line_rec.attribute10;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute11
        := tax_line_rec.attribute11;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute12
        := tax_line_rec.attribute12;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute13
        := tax_line_rec.attribute13;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute14
        := tax_line_rec.attribute14;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute15
        := tax_line_rec.attribute15;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute_category
        := tax_line_rec.attribute_category;
      -- End Bug 7117340 -- DFF ER

      -- Start Bug 8448714
      -- set unrounded taxable amt  and unrounded tax amt from the prepayment
      IF ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
           tax_line_rec.tax_id).applied_amt_handling_flag = 'P' THEN
        -- set unrounded taxable amt  and unrounded tax amt
        --
        -- bug#8203772
        -- check if the prepayment is being applied finally
        -- If yes, then get the tax amt remaning and set it to this
        -- do this check only for Payables.

        l_unrounded_tax_amt := NULL;

        IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index) = 200 THEN
          SELECT line_amt
          INTO l_orig_amt
          FROM zx_lines_det_factors
          WHERE application_id =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_index)
          AND entity_code =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(p_trx_line_index)
          AND event_class_code  =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(p_trx_line_index)
          AND trx_id =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(p_trx_line_index)
          AND trx_line_id =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(p_trx_line_index)
          AND trx_level_type =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(p_trx_line_index);

          SELECT sum(line_amt)
          INTO l_appl_line_amt
          FROM zx_lines_det_factors
          WHERE applied_from_application_id =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_index)
          AND applied_from_entity_code =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(p_trx_line_index)
          AND applied_from_event_class_code  =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(p_trx_line_index)
          AND applied_from_trx_id =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(p_trx_line_index)
          AND applied_from_line_id =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(p_trx_line_index)
          AND applied_from_trx_level_type =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(p_trx_line_index);

          SELECT sum(tax_amt)
          INTO l_appl_tax_amt
          FROM zx_lines
          WHERE applied_from_application_id =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_index)
          AND applied_from_entity_code =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(p_trx_line_index)
          AND applied_from_event_class_code  =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(p_trx_line_index)
          AND applied_from_trx_id =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(p_trx_line_index)
          AND applied_from_line_id =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(p_trx_line_index)
          AND applied_from_trx_level_type =
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(p_trx_line_index)
          AND tax_provider_id IS NULL
          AND Cancel_Flag <> 'Y'
          --AND offset_link_to_tax_line_id IS NULL
          AND mrc_tax_line_flag = 'N';

          IF l_orig_amt + (l_appl_line_amt + ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index)) <= 0 THEN
            -- Final Application
            IF (tax_line_rec.tax_amt + l_appl_tax_amt >= 0)
             THEN
              l_unrounded_tax_amt := sign(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index)) *
                                     (tax_line_rec.tax_amt + l_appl_tax_amt);
            END IF;
          END IF;
        ELSE
          l_unrounded_tax_amt := NULL;
        END IF;

       IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_amt <> 0 THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt:=
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_taxable_amt *
                     ( ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) /
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_amt );

	 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt:=
              NVL(l_unrounded_tax_amt,
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_tax_amt *
                     ( ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) /
                            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_amt ));

       ELSE   -- other_doc_line_amt = 0 OR IS NULL
         -- copy unrounded_taxable_amt from reference document,
         --
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt :=
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_taxable_amt;

         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt :=
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_tax_amt;

       END IF;       -- other_doc_line_amt <> 0

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_amt:= NULL;
     END IF; -- applied_amt_handling_flag = 'P'
      -- End Bug 8448714

      IF (x_begin_index IS NULL) THEN
        x_begin_index := l_new_row_num;
      END IF;
    END IF;   -- l_tax_tbl_index IS NOT NULL
  END LOOP;   -- FOR tax_line_rec in get_tax_lines_csr

  IF (x_begin_index IS NOT NULL) THEN
    x_end_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST;
  END IF;

  -- copy transaction info to new tax lines for new tax_lines created here
  --
  ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines(
				p_trx_line_index ,
--  				l_orig_end_index+1,
  				x_begin_index,
  				x_end_index,
  				x_return_status,
  				l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
         'Incorrect return_status after calling ' ||
         'ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines');
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
         'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from.END',
         'ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
           'x_begin_index = ' || to_char(x_begin_index));
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
           'x_end_index = ' || to_char(x_end_index));
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
           'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from.END',
           'ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from',
          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from.END',
         'ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_applied_from(-)');
    END IF;

END  get_taxes_from_applied_from;

----------------------------------------------------------------------
--  PROCEDURE
--   get_taxes_from_adjusted_to
--
--  DESCRIPTION
--
--  This procedure get detail tax lines from adjusted_to document
--
--  IN      p_trx_line_index
--
--  IN OUT NOCOPY
--          x_begin_index
--          x_end_index
--  OUT NOCOPY     x_return_status

PROCEDURE get_taxes_from_adjusted_to(
  p_event_class_rec	   IN 		        zx_api_pub.event_class_rec_type,
  p_trx_line_index	   IN	       	  	BINARY_INTEGER,
  p_tax_date		   IN   	 	DATE,
  p_tax_determine_date     IN   	 	DATE,
  p_tax_point_date         IN   	 	DATE,
  x_begin_index 	   IN OUT NOCOPY	BINARY_INTEGER,
  x_end_index		   IN OUT NOCOPY	BINARY_INTEGER,
  x_return_status	   OUT NOCOPY 	        VARCHAR2) IS

 CURSOR get_tax_lines_csr IS
   SELECT * FROM zx_lines
    WHERE application_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(
          p_trx_line_index)
      AND entity_code =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(
          p_trx_line_index)
      AND event_class_code  =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(
          p_trx_line_index)
      AND trx_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id(
          p_trx_line_index)
      AND trx_line_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(
          p_trx_line_index)
      AND trx_level_type =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(
          p_trx_line_index)
/* Bug 5131206:
   For partner integration, when the line_level_action is 'ALLOCATE_TAX_ONLY_ADJUSTMENT',
   eBTax needs to create prorated tax lines.
   In other cases, partner tax lines should be excluded.
*/
--      AND tax_provider_id IS  NULL
      AND (tax_provider_id IS NULL
           OR ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_trx_line_index) = 'ALLOCATE_TAX_ONLY_ADJUSTMENT')
      AND cancel_flag<> 'Y'
      --AND offset_link_to_tax_line_id IS NULL
      AND mrc_tax_line_flag = 'N';

 l_new_row_num			NUMBER;
 l_error_buffer			VARCHAR2(200);
 l_line_amt_current		NUMBER;
 l_orig_begin_index 		BINARY_INTEGER;
 l_orig_end_index 		BINARY_INTEGER;
 l_tax_tbl_index		NUMBER;

 l_tax_regime_rec   	        zx_global_structures_pkg.tax_regime_rec_type;
 l_tax_rec                      ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
 l_tax_status_rec               ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
 l_tax_rate_rec                 ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to.BEGIN',
       'ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to(+)');
    FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to',
       'p_trx_line_index = ' || to_char(p_trx_line_index));
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- initialize local variables
  --
  -- bug fix 4867933 begin
  -- l_new_row_num := NVL(x_end_index, 0);
  l_new_row_num := NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);
  l_orig_begin_index := x_begin_index;
  l_orig_end_index := x_end_index;

  FOR tax_line_rec in get_tax_lines_csr LOOP

    IF l_orig_begin_index IS NOT NULL AND l_orig_end_index IS NOT NULL THEN

      l_tax_tbl_index := ZX_TDS_UTILITIES_PKG.get_tax_index (
        tax_line_rec.tax_regime_code,
        tax_line_rec.tax,
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index),
        l_orig_begin_index,
        l_orig_end_index,
        x_return_status);
    ELSE
      l_tax_tbl_index := NULL;
    END IF;

    IF l_tax_tbl_index IS NULL THEN

      -- populate tax cache ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl with this tax_id,
      -- if it does not exists there.
      --
      ZX_TDS_UTILITIES_PKG.populate_tax_cache (
    		p_tax_id   	 => tax_line_rec.tax_id,
    		p_return_status  => x_return_status,
    		p_error_buffer   => l_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to',
             'Incorrect return_status after calling ' ||
             'ZX_TDS_UTILITIES_PKG.populate_tax_cache()');
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to',
             'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to.END',
             'ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to(-)');
        END IF;

        RETURN;
      END IF;

      -- This is a missing tax line, create a new detail tax line in
      -- g_detail_tax_lines_tbl
      --
      l_new_row_num := l_new_row_num +1;

      -- populate tax related information from tax_line_rec
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).tax_regime_code:=tax_line_rec.tax_regime_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                       l_new_row_num).tax := tax_line_rec.tax;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).tax_status_code:=tax_line_rec.tax_status_code;

      -- bug 5077691: populate legal_reporting_status
      IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).legal_reporting_status :=
                      ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                            tax_line_rec.tax_id).legal_reporting_status_def_val;
      END IF;

      -- for adjusted doc, tax regime id, tax id, tax status id, tax rate id
      -- should be the same as the original document since the
      -- tax_determination_date is the same as original

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_regime_id:= tax_line_rec.tax_regime_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_new_row_num).tax_id := tax_line_rec.tax_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_status_id:= tax_line_rec.tax_status_id;


      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_rate_code := tax_line_rec.tax_rate_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).tax_rate_id := tax_line_rec.tax_rate_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              l_new_row_num).tax_rate :=  tax_line_rec.tax_rate;
      -- bug 5508356
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_new_row_num).account_source_tax_rate_id :=
                                        tax_line_rec.account_source_tax_rate_id;

      -- populate taxable_basis_formula and tax_calculation_formula
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_new_row_num).taxable_basis_formula :=
                                             tax_line_rec.taxable_basis_formula;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_new_row_num).tax_calculation_formula :=
                                           tax_line_rec.tax_calculation_formula;


   -- Bug#6729097 --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_apportionment_line_number := tax_line_rec.tax_apportionment_line_number;

      IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust',
           'Tax Apportionment Line Number: Bug6729097 ' ||
           to_char(tax_line_rec.tax_apportionment_line_number));
      END IF;



      -- If line_amt_include_tax_flag on trx line is A, then set to 'Y'
      -- for other cases, set to the one from adjusted doc.
      IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt_includes_tax_flag(
           p_trx_line_index) = 'A'
      THEN
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).tax_amt_included_flag := 'Y';

      ELSE
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).tax_amt_included_flag
              := tax_line_rec.tax_amt_included_flag;
      END IF;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        l_new_row_num).manually_entered_flag := tax_line_rec.manually_entered_flag;

      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                 l_new_row_num).manually_entered_flag = 'Y' THEN

        -- don't recalculate the manually entered tax lines on the original
        -- trx line, butstill keep them so that user can update these
        -- manual tax lines.

        -- Populate other doc line amt, taxable amt and tax amt
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                    l_new_row_num).tax_amt := 0;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                l_new_row_num).taxable_amt := 0;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                          l_new_row_num).unrounded_tax_amt := 0;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                      l_new_row_num).unrounded_taxable_amt := 0;

      ELSE
        -- For system generated tax lines on the original trx line
        -- populate the unrounded taxable basis and tax amount

        IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
             p_trx_line_index) = 'ALLOCATE_TAX_ONLY_ADJUSTMENT'
        THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to',
               'Current trx is a tax only adjustment. ');
          END IF;

          -- for tax only adjustment set the unrounded tax amount to the
          -- unrounded tax amount of the original doc.
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).unrounded_taxable_amt := tax_line_rec.unrounded_taxable_amt;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).unrounded_tax_amt := tax_line_rec.unrounded_tax_amt;

        ELSE
          -- current trx is a regular adjustment or CM
          -- prorate the line amt to get the unrounded taxable/tax amount
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to',
               'tax_amt_included_flag on Current tax line: '||
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 l_new_row_num).tax_amt_included_flag);
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to',
               'tax_amt_included_flag on original tax line: '||
               tax_line_rec.tax_amt_included_flag);
          END IF;

          IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_new_row_num).tax_amt_included_flag ='Y'
             AND tax_line_rec.tax_amt_included_flag = 'N'
          THEN
            -- If current trx is a tax inclusive trx, while the original trx is
            -- tax exclusive trx.
            IF ( tax_line_rec.line_amt + tax_line_rec.tax_amt) <> 0 THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).unrounded_taxable_amt
                  := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
                    ( tax_line_rec.unrounded_taxable_amt /
                      ( tax_line_rec.line_amt + tax_line_rec.tax_amt) );

              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).unrounded_tax_amt
                  := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
                    ( tax_line_rec.unrounded_tax_amt /
                      ( tax_line_rec.line_amt + tax_line_rec.tax_amt) );
            ELSE
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).unrounded_taxable_amt
                  := tax_line_rec.unrounded_taxable_amt;
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).unrounded_tax_amt
                  := tax_line_rec.unrounded_tax_amt;
            END IF;
          ELSE -- both current tax line and original tax line are inclusive and exclusive
            IF tax_line_rec.line_amt <> 0 THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
                  ( tax_line_rec.unrounded_taxable_amt / tax_line_rec.line_amt);

              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
                  ( tax_line_rec.unrounded_tax_amt / tax_line_rec.line_amt );
            ELSE -- equal to that the original trx is a tax only trx
              IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_index) = 'CREDIT_MEMO' THEN
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                  := -1 * tax_line_rec.unrounded_taxable_amt;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                  := -1 * tax_line_rec.unrounded_tax_amt;
              ELSE
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                  := tax_line_rec.unrounded_taxable_amt;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                  := tax_line_rec.unrounded_tax_amt;
              END IF;
            END IF;
          END IF; -- tax_line_rec.tax_amt_included_flag = 'N'

        END IF; -- 'ALLOCATE_TAX_ONLY_ADJUSTMENT' trx and else

      END IF;         -- manually_entered_flag = 'Y'

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).basis_result_id
        := tax_line_rec.basis_result_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).legal_message_basis
        := tax_line_rec.legal_message_basis ;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).calc_result_id
        := tax_line_rec.calc_result_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).legal_message_calc
        := tax_line_rec.legal_message_calc;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_base_modifier_rate
        := tax_line_rec.tax_base_modifier_rate;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).compounding_dep_tax_flag
        := tax_line_rec.compounding_dep_tax_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).compounding_tax_miss_flag
        := tax_line_rec.compounding_tax_miss_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).Compounding_Tax_Flag
        := tax_line_rec.compounding_tax_flag;

      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).tax_amt_included_flag = 'Y' THEN

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_amt_included_flag(
          p_trx_line_index) := 'Y';
      END IF;

      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).compounding_dep_tax_flag = 'Y' THEN

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.compounding_tax_flag(
          p_trx_line_index) := 'Y';
      END IF;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_exemption_id
        := tax_line_rec.tax_exemption_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_rate_before_exemption
        := tax_line_rec.tax_rate_before_exemption;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_rate_name_before_exemption
        := tax_line_rec.tax_rate_name_before_exemption;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).exempt_rate_modifier
        := tax_line_rec.exempt_rate_modifier;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).exempt_certificate_number
        := tax_line_rec.exempt_certificate_number;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).exempt_reason
        := tax_line_rec.exempt_reason;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).exempt_reason_code
        := tax_line_rec.exempt_reason_code;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_exception_id
        := tax_line_rec.tax_exception_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_rate_before_exception
        := tax_line_rec.tax_rate_before_exception;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_rate_name_before_exception
        := tax_line_rec.tax_rate_name_before_exception;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).exception_rate
        := tax_line_rec.exception_rate;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).adjusted_doc_tax_line_id := tax_line_rec.tax_line_id;

      -- populate overridden_flag and last_manual_entry for manual tax line
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                          l_new_row_num).overridden_flag := 'Y';
      -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
      --                         l_new_row_num).last_manual_entry := 'TAX_AMOUNT';

      -- Populate other doc line amt, taxable amt and tax amt
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).other_doc_line_amt := tax_line_rec.line_amt;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).other_doc_line_taxable_amt :=
                                              tax_line_rec.unrounded_taxable_amt;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).other_doc_line_tax_amt :=
                                                  tax_line_rec.unrounded_tax_amt;

      -- Set copied_from_other_doc_flag to 'Y'
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                l_new_row_num).copied_from_other_doc_flag := 'Y';

      -- set other_doc_source
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                l_new_row_num).other_doc_source := 'ADJUSTED';

      -- populate other columns
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).rounding_level_code := tax_line_rec.rounding_level_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).rounding_rule_code := tax_line_rec.rounding_rule_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            l_new_row_num).tax_date := p_tax_date;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        l_new_row_num).tax_determine_date := p_tax_determine_date;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                l_new_row_num).tax_point_date := p_tax_point_date;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).offset_flag := tax_line_rec.offset_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).offset_tax_rate_code := tax_line_rec.offset_tax_rate_code;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).place_of_supply := tax_line_rec.place_of_supply;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).place_of_supply_type_code :=
                                           tax_line_rec.place_of_supply_type_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).place_of_supply_result_id :=
                                          tax_line_rec.place_of_supply_result_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).legal_message_pos :=
                                          tax_line_rec.legal_message_pos;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_currency_code := tax_line_rec.tax_currency_code;

/* Bug 5149379: When the trx currency is different from the tax currency,
                it is necessary to pick the tax_currency_conversion_date,
                tax_currency_conversion_type, tax_currency_conversion_rate
                information from the invoice tax lines.
*/
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_currency_conversion_date := tax_line_rec.tax_currency_conversion_date;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_currency_conversion_type := tax_line_rec.tax_currency_conversion_type;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_currency_conversion_rate := tax_line_rec.tax_currency_conversion_rate;

/* Bug 5131206: For partner integration, when the line_level_action is
                'ALLOCATE_TAX_ONLY_ADJUSTMENT', eBTax needs to create
                prorated tax lines and stamp the tax_provider_id on
                the tax line(s).
*/

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_provider_id := tax_line_rec.tax_provider_id;

    if(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_trx_line_index) = 'ALLOCATE_TAX_ONLY_ADJUSTMENT' and
       tax_line_rec.tax_provider_id is not null ) THEN
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).SYNC_WITH_PRVDR_FLAG := 'Y';
    end if;


      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).tax_type_code := tax_line_rec.tax_type_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).reporting_only_flag := tax_line_rec.reporting_only_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).tax_jurisdiction_code :=
                                              tax_line_rec.tax_jurisdiction_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          l_new_row_num).tax_jurisdiction_id := tax_line_rec.tax_jurisdiction_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_new_row_num).tax_registration_number :=
                                           tax_line_rec.tax_registration_number;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_new_row_num).registration_party_type :=
                                           tax_line_rec.registration_party_type;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).tax_applicability_result_id :=
                                        tax_line_rec.tax_applicability_result_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).legal_message_appl_2 :=
                                        tax_line_rec.legal_message_appl_2;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).legal_message_rate :=
                                             tax_line_rec.legal_message_rate ;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).direct_rate_result_id :=
                                             tax_line_rec.direct_rate_result_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).rounding_lvl_party_tax_prof_id :=
                                     tax_line_rec.rounding_lvl_party_tax_prof_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).rounding_lvl_party_type :=
                                            tax_line_rec.rounding_lvl_party_type;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).self_assessed_flag := tax_line_rec.self_assessed_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                            l_new_row_num).tax_reg_num_det_result_id :=
                                         tax_line_rec.tax_reg_num_det_result_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                            l_new_row_num).legal_message_trn :=
                                         tax_line_rec.legal_message_trn;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_only_line_flag := tax_line_rec.tax_only_line_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).tax_provider_id := tax_line_rec.tax_provider_id;
      -- Added for Bug#7185529
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).hq_estb_reg_number := tax_line_rec.hq_estb_reg_number;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).status_result_id
        := tax_line_rec.status_result_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).legal_message_status
        := tax_line_rec.legal_message_status ;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).rate_result_id
        := tax_line_rec.rate_result_id;

      -- Bug 7117340 -- DFF ER
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute1
        := tax_line_rec.attribute1;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute2
        := tax_line_rec.attribute2;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute3
        := tax_line_rec.attribute3;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute4
        := tax_line_rec.attribute4;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute5
        := tax_line_rec.attribute5;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute6
        := tax_line_rec.attribute6;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute7
        := tax_line_rec.attribute7;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute8
        := tax_line_rec.attribute8;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute9
        := tax_line_rec.attribute9;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute10
        := tax_line_rec.attribute10;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute11
        := tax_line_rec.attribute11;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute12
        := tax_line_rec.attribute12;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute13
        := tax_line_rec.attribute13;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute14
        := tax_line_rec.attribute14;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute15
        := tax_line_rec.attribute15;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).attribute_category
        := tax_line_rec.attribute_category;
      -- End Bug 7117340 -- DFF ER

      IF (x_begin_index IS NULL) THEN
        x_begin_index := l_new_row_num;
      END IF;
    END IF;   -- l_tax_tbl_index IS NOT NULL
  END LOOP;   -- FOR tax_line_rec in get_tax_lines_csr

  IF (x_begin_index IS NOT NULL) THEN
    x_end_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST;
  END IF;

  -- copy transaction info to new tax lines for new tax_lines created here
  --
  ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines(
				p_trx_line_index ,
--  				NVL(l_orig_end_index, 0)+1,
  				x_begin_index,
  				x_end_index,
  				x_return_status,
  				l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to',
         'Incorrect return_status after calling ' ||
         'ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines');
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to',
         'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to.END',
         'ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to',
           'x_begin_index = ' || to_char(x_begin_index));
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to',
           'x_end_index = ' || to_char(x_end_index));
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to',
           'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to.END',
           'ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to',
          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
         'ZX.PLSQL.ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to.END',
         'ZX_TDS_IMPORT_DOCUMENT_PKG.get_taxes_from_adjusted_to(-)');
    END IF;

END  get_taxes_from_adjusted_to;

END ZX_TDS_IMPORT_DOCUMENT_PKG;

/
