--------------------------------------------------------
--  DDL for Package Body ZX_TRD_INTERNAL_SERVICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TRD_INTERNAL_SERVICES_PVT" AS
/* $Header: zxmirecdmsrvpvtb.pls 120.92.12010000.12 2010/08/27 06:22:39 prigovin ship $ */

g_current_runtime_level      NUMBER;
g_level_statement            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
g_level_procedure            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
g_level_event                CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
g_level_unexpected           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
g_level_error                CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;

 TYPE index_amt_rec_type IS RECORD (
   tbl_index		BINARY_INTEGER,
   tbl_amt		NUMBER);

 TYPE index_amt_tbl_type IS TABLE OF index_amt_rec_type
      INDEX BY BINARY_INTEGER;

 PROCEDURE distribute_rounding_diff (
  p_index_amt_tbl     IN OUT NOCOPY index_amt_tbl_type,
  p_rounding_diff     IN 	    NUMBER,
  p_min_acct_unit     IN	    NUMBER,
  p_return_status     OUT NOCOPY    VARCHAR2,
  p_error_buffer      OUT NOCOPY    VARCHAR2);

 PROCEDURE sort_tbl_amt_desc (
  p_index_amt_tbl     IN OUT NOCOPY index_amt_tbl_type,
  p_return_status     OUT NOCOPY    VARCHAR2,
  p_error_buffer      OUT NOCOPY    VARCHAR2);

 PROCEDURE round_tax_dists_trx_curr (
  p_rec_nrec_dist_tbl IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
  p_rnd_begin_index   IN            NUMBER,
  p_rnd_end_index     IN            NUMBER,
  p_tax_line_amt      IN            NUMBER,
  p_return_status     OUT NOCOPY    VARCHAR2,
  p_error_buffer      OUT NOCOPY    VARCHAR2);

 PROCEDURE convert_tax_dists (
  p_rec_nrec_dist_tbl IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
  p_rnd_begin_index          IN            NUMBER,
  p_rnd_end_index            IN            NUMBER,
  p_tax_line_amt_tax_curr    IN            NUMBER,
  p_tax_line_amt_funcl_curr  IN            NUMBER,
  p_return_status            OUT NOCOPY    VARCHAR2,
  p_error_buffer             OUT NOCOPY    VARCHAR2);

PROCEDURE get_recovery_from_applied(
 p_tax_id               IN            NUMBER,
 p_prd_total_tax_amt	IN	      NUMBER,
 p_trx_line_dist_index  IN            NUMBER,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index      IN            NUMBER,
 p_rnd_end_index        OUT NOCOPY    NUMBER,
 p_return_status        OUT NOCOPY    VARCHAR2,
 p_error_buffer         OUT NOCOPY    VARCHAR2);

PROCEDURE get_recovery_from_adjusted(
 p_tax_id               IN            NUMBER,
 p_trx_line_dist_index  IN            NUMBER,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index      IN            NUMBER,
 p_rnd_end_index        OUT NOCOPY    NUMBER,
 p_return_status        OUT NOCOPY    VARCHAR2,
 p_error_buffer         OUT NOCOPY    VARCHAR2);

PROCEDURE enforce_recovery_from_ref(
 p_detail_tax_line_tbl  IN             ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index       IN             NUMBER,
 p_trx_line_dist_index  IN            NUMBER,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index      IN            NUMBER,
 p_rnd_end_index        OUT NOCOPY    NUMBER,
 p_return_status        OUT NOCOPY    VARCHAR2,
 p_error_buffer         OUT NOCOPY    VARCHAR2);

PROCEDURE round_and_adjust_prd_tax_amts (
 p_rec_nrec_dist_tbl  IN OUT NOCOPY  ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index    IN             NUMBER,
 p_rnd_end_index      IN             NUMBER,
 p_return_status      OUT NOCOPY     VARCHAR2,
 p_error_buffer       OUT NOCOPY     VARCHAR2);

PROCEDURE get_variance_related_columns(
 p_detail_tax_line_tbl  IN            ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index       IN            NUMBER,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index      IN            NUMBER,
 p_rnd_end_index        IN            NUMBER,
 p_return_status           OUT NOCOPY VARCHAR2,
 p_error_buffer            OUT NOCOPY VARCHAR2);

PROCEDURE calc_tax_dist(
 p_detail_tax_line_tbl  IN             ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index       IN             NUMBER,
 p_trx_line_dist_index  IN             NUMBER,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY  ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index      IN             NUMBER,
 p_rnd_end_index        IN OUT NOCOPY  NUMBER,
 p_event_class_rec      IN             ZX_API_PUB.event_class_rec_type,
 p_return_status           OUT NOCOPY  VARCHAR2,
 p_error_buffer            OUT NOCOPY  VARCHAR2) IS

 l_index   			NUMBER;
 l_new_index   			NUMBER;
 l_total_count   		NUMBER;
 l_curr_count   		NUMBER;
 l_new_count   			NUMBER;
 l_tax_dist_id   		NUMBER;
 l_max_tax_dist_number          NUMBER;

 CURSOR  get_tax_distribution_cur is
  SELECT *
    FROM zx_rec_nrec_dist
   WHERE NVL(reverse_flag,'N') = 'N'
     AND tax_line_id = p_detail_tax_line_tbl(p_tax_line_index).tax_line_id
     AND trx_line_dist_id =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_dist_id(
                                                       p_trx_line_dist_index)
   ORDER BY rec_nrec_tax_dist_id, recoverable_flag;

 CURSOR  get_maximum_tax_dist_num_csr is
  SELECT max(rec_nrec_tax_dist_number)
    FROM zx_rec_nrec_dist
   WHERE tax_line_id = p_detail_tax_line_tbl(p_tax_line_index).tax_line_id
     AND trx_line_dist_id =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_dist_id(
                                                      p_trx_line_dist_index);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.CALC_TAX_DIST.BEGIN',
                   'ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist(+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;

  l_index:= p_rnd_begin_index - 1;
  l_new_index := NULL;
  l_total_count := 0;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.CALC_TAX_DIST',
                   'p_rnd_begin_index = ' || p_rnd_begin_index||
                   'p_rnd_end_index = ' || p_rnd_end_index);
  END IF;

  OPEN get_tax_distribution_cur;

  LOOP           -- get_tax_distribution_cur
    l_index := l_index + 1;
    FETCH get_tax_distribution_cur INTO p_rec_nrec_dist_tbl(l_index);
    EXIT WHEN get_tax_distribution_cur%NOTFOUND;

  END LOOP;      -- get_tax_distribution_cur

  l_total_count:= get_tax_distribution_cur%ROWCOUNT;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.CALC_TAX_DIST',
                  'l_total_count = ' || l_total_count);
  END IF;

  CLOSE get_tax_distribution_cur;

  IF l_total_count = 0 THEN -- first time processing

   /*
    first fetch all the tax distributions whose reverse_flag <>'Y',
    order by recoverable_flag for the tax line id
    and item distribution id.
    If there is no tax distribution found -- first time calculation
    call recovery type applicability
    */

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.CALC_TAX_DIST',
                  'first time calculation for this tax line and item dist');
    END IF;

    IF NVL(p_event_class_rec.enforce_tax_from_ref_doc_flag, 'N') = 'Y' AND
       p_event_class_rec.tax_event_type_code <> 'OVERRIDE_TAX' AND
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(
                                              p_trx_line_dist_index) IS NULL AND
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(
                                              p_trx_line_dist_index) IS NULL AND
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(
                                            p_trx_line_dist_index) IS NOT NULL
    THEN

      -- If p_event_class_rec.enforce_tax_from_ref_doc_flag = 'Y' AND
      -- trx_line_dist_tbl.ref_doc_application_id IS NOT NULL,
      -- get tax recovery rate code from refefence document
      --
      enforce_recovery_from_ref(
                p_detail_tax_line_tbl,
                p_tax_line_index,
      		p_trx_line_dist_index,
      		p_rec_nrec_dist_tbl,
      		p_rnd_begin_index,
      		p_rnd_end_index,
      		p_return_status,
      		p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist',
                      'Incorrect return_status after calling ' ||
                      'ZX_TRD_INTERNAL_SERVICES_PVT.enforce_recovery_from_ref()'||p_return_status);
        END IF;
        RETURN;
      END IF;

    ELSE

      det_appl_rec_type(
                  p_detail_tax_line_tbl,
                  p_tax_line_index,
                  p_trx_line_dist_index,
                  p_rec_nrec_dist_tbl,
                  p_rnd_begin_index,
                  p_rnd_end_index,
                  p_return_status,
                  p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist',
                      'Incorrect return_status after calling ' ||
                      'ZX_TRD_INTERNAL_SERVICES_PVT.det_appl_rec_type()'||p_return_status);
        END IF;
        RETURN;
      END IF;

    END IF;

    -- get_related_column and call recovery rate determination
    --
    get_tax_related_columns_sta(
                  p_detail_tax_line_tbl,
                  p_tax_line_index,
                  p_trx_line_dist_index,
                  p_rec_nrec_dist_tbl,
                  p_rnd_begin_index,
                  p_rnd_end_index,
                  p_return_status,
                  p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist',
                      'Incorrect return_status after calling ' ||
                      'ZX_TRD_INTERNAL_SERVICES_PVT.get_tax_related_columns_sta()'||p_return_status);
        END IF;
        RETURN;
      END IF;


    get_tax_related_columns_var(
                  p_detail_tax_line_tbl,
                  p_tax_line_index,
                  p_trx_line_dist_index,
                  p_rec_nrec_dist_tbl,
                  p_rnd_begin_index,
                  p_rnd_end_index,
                  p_return_status,
                  p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist',
                      'Incorrect return_status after calling ' ||
                      'ZX_TRD_INTERNAL_SERVICES_PVT.get_tax_related_columns_var()'||p_return_status);
        END IF;
        RETURN;
      END IF;

    IF ZX_TRD_SERVICES_PUB_PKG.g_variance_calc_flag = 'Y' THEN
      get_variance_related_columns(
                  p_detail_tax_line_tbl,
                  p_tax_line_index,
                  p_rec_nrec_dist_tbl,
                  p_rnd_begin_index,
                  p_rnd_end_index,
                  p_return_status,
                  p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist',
                      'Incorrect return_status after calling ' ||
                      'ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns()'||p_return_status);
        END IF;
        RETURN;
      END IF;


    END IF;

    get_rec_rate(
                  p_detail_tax_line_tbl,
                  p_tax_line_index,
                  p_trx_line_dist_index,
                  p_event_class_rec,
                  p_rec_nrec_dist_tbl,
                  p_rnd_begin_index,
                  p_rnd_end_index,
                  p_return_status,
                  p_error_buffer);
   IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist',
                      'Incorrect return_status after calling ' ||
                      'ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate()'||p_return_status);
        END IF;
        RETURN;
   END IF;

  ELSE -- second time calculation

    /*
    If there are tax distribution found -- second time calculation.
    First we need to consider frozen tax distribution case,
    we need to create reverse tax distributions for the frozen tax
    distributions.
    For example, we get
    D1    frozen
    D2    frozen
    D3    frozen
    we can assume if one tax distribution for the same tax line and item
    dist is frozen, all tax distributions for the same tax line and item
    dist are frozen.

    So we need to create
    D1   frozen reverse
    D2   frozen reverse
    D3   frozen reverse
    D4   negative D1 reverse
    D5   negative D2 reverse
    D6   negative D3 reverse
    D7   same as D1
    D8   same as D2
    D9   same as D3
    THEN recovery rate determination need to be ran for D7 - D9.
    */

    IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.CALC_TAX_DIST',
                     'tax dists have been determined before '||
                     'p_rnd_begin_index = ' || p_rnd_begin_index||
                     'p_rnd_end_index = ' || p_rnd_end_index);
    END IF;

    -- get the maximum rec_nrec_tax_dist_number
    --
    OPEN  get_maximum_tax_dist_num_csr;
    FETCH get_maximum_tax_dist_num_csr INTO l_max_tax_dist_number;
    CLOSE get_maximum_tax_dist_num_csr;

    l_max_tax_dist_number := NVL(l_max_tax_dist_number, 0);

    -- set p_rnd_end_index
    --
    p_rnd_end_index:= p_rnd_begin_index + l_total_count - 1;

    FOR i IN p_rnd_begin_Index .. p_rnd_end_Index LOOP

        -- 6709478
      IF NVL(p_rec_nrec_dist_tbl(i).summary_tax_line_id, -999999) <>
         NVL(p_detail_tax_line_tbl(p_tax_line_index).summary_tax_line_id, -999999)
      THEN

        SELECT zx_rec_nrec_dist_s.nextval INTO
                 p_rec_nrec_dist_tbl(i).rec_nrec_tax_dist_id FROM DUAL;

      END IF;

      IF NVL(p_rec_nrec_dist_tbl(i).freeze_flag, 'N') = 'Y' THEN


        p_rec_nrec_dist_tbl(i).reverse_flag:= 'Y';

        SELECT zx_rec_nrec_dist_s.nextval INTO l_tax_dist_id from dual;

        l_new_index:= i + l_total_count;
        p_rec_nrec_dist_tbl(l_new_index):= p_rec_nrec_dist_tbl(i);
        p_rec_nrec_dist_tbl(l_new_index).rec_nrec_tax_dist_id:= l_tax_dist_id;
        p_rec_nrec_dist_tbl(l_new_index).freeze_flag:= 'N';
        p_rec_nrec_dist_tbl(l_new_index).reverse_flag := 'Y';
        p_rec_nrec_dist_tbl(l_new_index).posting_flag := NULL;
        p_rec_nrec_dist_tbl(l_new_index).reversed_tax_dist_id :=
                                   p_rec_nrec_dist_tbl(i).rec_nrec_tax_dist_id;
        p_rec_nrec_dist_tbl(l_new_index).rec_nrec_tax_amt:=
                            -p_rec_nrec_dist_tbl(l_new_index).rec_nrec_tax_amt;
        p_rec_nrec_dist_tbl(l_new_index).rec_nrec_tax_amt_tax_curr:=
                   -p_rec_nrec_dist_tbl(l_new_index).rec_nrec_tax_amt_tax_curr;
        p_rec_nrec_dist_tbl(l_new_index).rec_nrec_tax_amt_funcl_curr :=
                 -p_rec_nrec_dist_tbl(l_new_index).rec_nrec_tax_amt_funcl_curr;
        p_rec_nrec_dist_tbl(l_new_index).trx_line_dist_amt:=
                           -p_rec_nrec_dist_tbl(l_new_index).trx_line_dist_amt;
        p_rec_nrec_dist_tbl(l_new_index).trx_line_dist_tax_amt:=
                       -p_rec_nrec_dist_tbl(l_new_index).trx_line_dist_tax_amt;
        -- 6709478
        p_rec_nrec_dist_tbl(l_new_index).trx_line_dist_qty:=
                           -p_rec_nrec_dist_tbl(l_new_index).trx_line_dist_qty;
        p_rec_nrec_dist_tbl(l_new_index).taxable_amt :=
                                 -p_rec_nrec_dist_tbl(l_new_index).taxable_amt;
        p_rec_nrec_dist_tbl(l_new_index).taxable_amt_tax_curr :=
                        -p_rec_nrec_dist_tbl(l_new_index).taxable_amt_tax_curr;
        p_rec_nrec_dist_tbl(l_new_index).taxable_amt_funcl_curr :=
                      -p_rec_nrec_dist_tbl(l_new_index).taxable_amt_funcl_curr;
        p_rec_nrec_dist_tbl(l_new_index).orig_rec_nrec_tax_amt:=
                       -p_rec_nrec_dist_tbl(l_new_index).orig_rec_nrec_tax_amt;
        p_rec_nrec_dist_tbl(l_new_index).orig_rec_nrec_tax_amt_tax_curr:=
              -p_rec_nrec_dist_tbl(l_new_index).orig_rec_nrec_tax_amt_tax_curr;
        p_rec_nrec_dist_tbl(l_new_index).unrounded_rec_nrec_tax_amt:=
                  -p_rec_nrec_dist_tbl(l_new_index).unrounded_rec_nrec_tax_amt;

        p_rec_nrec_dist_tbl(l_new_index).rec_nrec_tax_dist_number :=
                                                   l_max_tax_dist_number + 1;

        -- bug 6706941: populate gl_date for the reversed tax distribution
        --
        p_rec_nrec_dist_tbl(l_new_index).gl_date :=
              AP_UTILITIES_PKG.get_reversal_gl_date(
                 p_date   => p_rec_nrec_dist_tbl(l_new_index).gl_date,
                 p_org_id => p_rec_nrec_dist_tbl(l_new_index).internal_organization_id);

        l_max_tax_dist_number := l_max_tax_dist_number + 1;

--        p_rec_nrec_dist_tbl(l_new_index).rec_nrec_tax_dist_number :=
--                     -p_rec_nrec_dist_tbl(l_new_index).rec_nrec_tax_dist_number;

--        p_rec_nrec_dist_tbl(l_new_index).invoice_price_variance:=
--                      -p_rec_nrec_dist_tbl(l_new_index).invoice_price_variance;
--        p_rec_nrec_dist_tbl(l_new_index).base_invoice_price_variance:=
--                 -p_rec_nrec_dist_tbl(l_new_index).base_invoice_price_variance;
--        p_rec_nrec_dist_tbl(l_new_index).exchange_rate_variance:=
--                      -p_rec_nrec_dist_tbl(l_new_index).exchange_rate_variance;

        l_new_index:= l_new_index + l_total_count;

        SELECT zx_rec_nrec_dist_s.nextval INTO l_tax_dist_id from dual;

        p_rec_nrec_dist_tbl(l_new_index) := p_rec_nrec_dist_tbl(i);
        p_rec_nrec_dist_tbl(l_new_index).rec_nrec_tax_dist_id := l_tax_dist_id;
        p_rec_nrec_dist_tbl(l_new_index).freeze_flag := 'N';
        p_rec_nrec_dist_tbl(l_new_index).reverse_flag := 'N';
        p_rec_nrec_dist_tbl(l_new_index).posting_flag := NULL;


        IF  (NVL(p_rec_nrec_dist_tbl(l_new_index).historical_flag, 'N') <> 'Y') AND
        (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_trx_line_dist_index) is NULL) and
          (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_dist_index) is  NULL
         AND ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(p_detail_tax_line_tbl(p_tax_line_index).tax_id).applied_amt_handling_flag = 'P') THEN
          p_rec_nrec_dist_tbl(l_new_index).recovery_rate_id := NULL;
        END IF;

        p_rec_nrec_dist_tbl(l_new_index).rec_nrec_tax_dist_number :=
                                                   l_max_tax_dist_number + 1;
        l_max_tax_dist_number := l_max_tax_dist_number + 1;

	-- commented out for bug 5581573
        --IF p_event_class_rec.enforce_tax_from_ref_doc_flag = 'Y' AND
        --   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(
        --                                   p_trx_line_dist_index) IS NOT NULL
        --THEN
          -- set rec_nrec_rate  to NULL
          --
         -- p_rec_nrec_dist_tbl(l_new_index).rec_nrec_rate := NULL;

        --END IF;

        -- Bug 7117340 -- DFF ER
        p_rec_nrec_dist_tbl(l_new_index).attribute1 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute2 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute3 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute4 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute5 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute6 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute7 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute8 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute9 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute10 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute11 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute12 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute13 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute14 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute15 := NULL;
        p_rec_nrec_dist_tbl(l_new_index).attribute_category := NULL;
        -- End Bug 7117340 -- DFF ER

      END IF;    -- freeze_flag = 'Y'
    END LOOP;    -- i IN p_rnd_begin_Index .. p_rnd_end_Index

    IF l_new_index IS NOT NULL THEN
       p_rnd_end_index:= l_new_index;
    END IF;

    get_tax_related_columns_var(
                    p_detail_tax_line_tbl,
                    p_tax_line_index,
                    p_trx_line_dist_index,
                    p_rec_nrec_dist_tbl,
                    p_rnd_begin_index,
                    p_rnd_end_index,
                    p_return_status,
                    p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist',
                      'Incorrect return_status after calling ' ||
                      'ZX_TRD_INTERNAL_SERVICES_PVT.get_tax_related_columns_var()'||p_return_status);
        END IF;
        RETURN;
      END IF;

    IF ZX_TRD_SERVICES_PUB_PKG.g_variance_calc_flag = 'Y' THEN
      get_variance_related_columns(
                  p_detail_tax_line_tbl,
                  p_tax_line_index,
                  p_rec_nrec_dist_tbl,
                  p_rnd_begin_index,
                  p_rnd_end_index,
                  p_return_status,
                  p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist',
                      'Incorrect return_status after calling ' ||
                      'ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns()'||p_return_status);
        END IF;
        RETURN;
      END IF;

    END IF;

    get_rec_rate(
                    p_detail_tax_line_tbl,
                    p_tax_line_index,
                    p_trx_line_dist_index,
                    p_event_class_rec,
                    p_rec_nrec_dist_tbl,
                    p_rnd_begin_index,
                    p_rnd_end_index,
                    p_return_status,
                    p_error_buffer);
    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist',
                      'Incorrect return_status after calling ' ||
                      'ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate()'||p_return_status);
        END IF;
        RETURN;
    END IF;


  END IF; -- no row found

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.CALC_TAX_DIST.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist (-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist',
                     p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.CALC_TAX_DIST.END',
                    'ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist (-)');
    END IF;

END calc_tax_dist;

PROCEDURE cancel_tax_line(
 p_detail_tax_line_tbl        IN      ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index             IN      NUMBER,
 p_rec_nrec_dist_tbl          IN OUT NOCOPY  ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index            IN      NUMBER,
 p_rnd_end_index              IN OUT NOCOPY  NUMBER,
 p_event_class_rec      IN       ZX_API_PUB.event_class_rec_type,
 p_return_status              OUT NOCOPY     VARCHAR2,
 p_error_buffer               OUT NOCOPY     VARCHAR2)
IS
  i          	number;
  i1		number;

 l_max_tax_dist_number          NUMBER;
 l_old_trx_line_dist_id             NUMBER;

 CURSOR  get_maximum_tax_dist_num_csr (
                     c_tax_line_id         NUMBER,
                     c_trx_line_dist_id    NUMBER) IS
  SELECT max(rec_nrec_tax_dist_number)
    FROM zx_rec_nrec_dist
   WHERE tax_line_id = c_tax_line_id
     AND trx_line_dist_id = c_trx_line_dist_id;

 Cursor get_tax_distributions_cur IS
   SELECT * FROM zx_rec_nrec_dist
   WHERE  trx_id =  p_event_class_rec.trx_id
     AND  application_id = p_event_class_rec.application_id
     AND  entity_code = p_event_class_rec.entity_code
     AND  event_class_code = p_event_class_rec.event_class_code
     AND  tax_line_id = p_detail_tax_line_tbl(p_tax_line_index).tax_line_id
     AND  NVL(reverse_flag ,'N') = 'N'
     AND  freeze_flag = 'Y'
     ORDER BY trx_line_dist_id;


begin

 g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.cancel_tax_line.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.cancel_tax_line (+)');
  END IF;

 p_return_status:= FND_API.G_RET_STS_SUCCESS;
 i:= p_rnd_begin_index;
 l_old_trx_line_dist_id := NULL;

 OPEN get_tax_distributions_cur;

 LOOP
        FETCH get_tax_distributions_cur INTO p_rec_nrec_dist_tbl(i);

        exit when get_tax_distributions_cur%notfound;

        p_rec_nrec_dist_tbl(i).reverse_flag:= 'Y';

        -- bug 6906427
        --
        p_rec_nrec_dist_tbl(i).tax_line_number :=
                       p_detail_tax_line_tbl(p_tax_line_index).tax_line_number;

	i1 := i;
        i:= i1 + 1;
        p_rec_nrec_dist_tbl(i):= p_rec_nrec_dist_tbl(i1);

        SELECT zx_rec_nrec_dist_s.NEXTVAL INTO p_rec_nrec_dist_tbl(i).rec_nrec_tax_dist_id FROM DUAL;

        p_rec_nrec_dist_tbl(i).reversed_tax_dist_id:= p_rec_nrec_dist_tbl(i1).rec_nrec_tax_dist_id;
	p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt:= -p_rec_nrec_dist_tbl(i1).rec_nrec_tax_amt;
	p_rec_nrec_dist_tbl(i).REC_NREC_TAX_AMT_TAX_CURR:= -p_rec_nrec_dist_tbl(i1).REC_NREC_TAX_AMT_TAX_CURR;
	p_rec_nrec_dist_tbl(i).REC_NREC_TAX_AMT_FUNCL_CURR:= -p_rec_nrec_dist_tbl(i1).REC_NREC_TAX_AMT_FUNCL_CURR;
	p_rec_nrec_dist_tbl(i).TRX_LINE_DIST_AMT:= -p_rec_nrec_dist_tbl(i1).TRX_LINE_DIST_AMT;
	p_rec_nrec_dist_tbl(i).TRX_LINE_DIST_TAX_AMT:= -p_rec_nrec_dist_tbl(i1).TRX_LINE_DIST_TAX_AMT;
	p_rec_nrec_dist_tbl(i).TAXABLE_AMT := -p_rec_nrec_dist_tbl(i1).TAXABLE_AMT;
	p_rec_nrec_dist_tbl(i).TAXABLE_AMT_TAX_CURR := -p_rec_nrec_dist_tbl(i1).TAXABLE_AMT_TAX_CURR;
	p_rec_nrec_dist_tbl(i).TAXABLE_AMT_FUNCL_CURR := -p_rec_nrec_dist_tbl(i1).TAXABLE_AMT_FUNCL_CURR;
	p_rec_nrec_dist_tbl(i).ORIG_REC_NREC_TAX_AMT:= -p_rec_nrec_dist_tbl(i1).ORIG_REC_NREC_TAX_AMT;
	p_rec_nrec_dist_tbl(i).ORIG_REC_NREC_TAX_AMT_TAX_CURR:= -p_rec_nrec_dist_tbl(i1).ORIG_REC_NREC_TAX_AMT_TAX_CURR;
	p_rec_nrec_dist_tbl(i).UNROUNDED_REC_NREC_TAX_AMT:= -p_rec_nrec_dist_tbl(i1).UNROUNDED_REC_NREC_TAX_AMT;
	p_rec_nrec_dist_tbl(i).REC_NREC_TAX_DIST_NUMBER:= -p_rec_nrec_dist_tbl(i1).REC_NREC_TAX_DIST_NUMBER;
        --p_rec_nrec_dist_tbl(i).INVOICE_PRICE_VARIANCE:= -p_rec_nrec_dist_tbl(i1).INVOICE_PRICE_VARIANCE;
        --p_rec_nrec_dist_tbl(i).BASE_INVOICE_PRICE_VARIANCE:= -p_rec_nrec_dist_tbl(i1).BASE_INVOICE_PRICE_VARIANCE;
        --p_rec_nrec_dist_tbl(i).EXCHANGE_RATE_VARIANCE:= -p_rec_nrec_dist_tbl(i1).EXCHANGE_RATE_VARIANCE;
	p_rec_nrec_dist_tbl(i).freeze_flag := 'N';

        -- bug 6706941: populate gl_date for the reversed tax distribution
        --
        p_rec_nrec_dist_tbl(i).gl_date :=
              AP_UTILITIES_PKG.get_reversal_gl_date(
                 p_date   => p_rec_nrec_dist_tbl(i1).gl_date,
                 p_org_id => p_rec_nrec_dist_tbl(i1).internal_organization_id);

        -- 6881847
        p_rec_nrec_dist_tbl(i).trx_line_dist_qty := -p_rec_nrec_dist_tbl(i1).trx_line_dist_qty;

        -- bug 6906427
        --
        p_rec_nrec_dist_tbl(i).tax_line_number := p_rec_nrec_dist_tbl(i1).tax_line_number;

        IF l_old_trx_line_dist_id IS NULL OR
           l_old_trx_line_dist_id <> p_rec_nrec_dist_tbl(i).trx_line_dist_id
        THEN
          -- get the maximum rec_nrec_tax_dist_number
          --
          OPEN  get_maximum_tax_dist_num_csr
                            (p_rec_nrec_dist_tbl(i).tax_line_id,
                             p_rec_nrec_dist_tbl(i).trx_line_dist_id);
          FETCH get_maximum_tax_dist_num_csr INTO l_max_tax_dist_number;
          CLOSE get_maximum_tax_dist_num_csr;

          l_max_tax_dist_number := NVL(l_max_tax_dist_number, 0);
          l_old_trx_line_dist_id := p_rec_nrec_dist_tbl(i).trx_line_dist_id;

        ELSE

          l_max_tax_dist_number := l_max_tax_dist_number + 1;

        END IF;

        p_rec_nrec_dist_tbl(i).rec_nrec_tax_dist_number := l_max_tax_dist_number + 1;

        i:= i+1;

    END LOOP;

    CLOSE get_tax_distributions_cur;

    p_rnd_end_index:= i-1;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.cancel_tax_line.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.cancel_tax_line (-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.cancel_tax_line',
                      p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.cancel_tax_line.END',
                    'ZX_TRD_INTERNAL_SERVICES_PVT.cancel_tax_line(-)');
    END IF;

end cancel_tax_line;


PROCEDURE det_appl_rec_type(
 p_detail_tax_line_tbl  IN             zx_trd_services_pub_pkg.tax_line_tbl_type,
 p_tax_line_index       IN             NUMBER,
 p_trx_line_dist_index  IN             NUMBER,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY  zx_trd_services_pub_pkg.rec_nrec_dist_tbl_type,
 p_rnd_begin_index      IN             NUMBER,
 p_rnd_end_index           OUT NOCOPY  NUMBER,
 p_return_status           OUT NOCOPY  VARCHAR2,
 p_error_buffer            OUT NOCOPY  VARCHAR2)  IS

 l_tax                              ZX_TAXES_B.tax%TYPE;
 l_tax_id                           NUMBER;
 l_index                            NUMBER;
 l_tax_regime_code                  ZX_STATUS_B.tax_regime_code%TYPE;
 l_rec_nrec_tax_dist_number         NUMBER;

 CURSOR  get_tax_recovery_info_cur(
          c_tax_id                  zx_taxes_b.tax_id%TYPE) IS
  SELECT allow_recoverability_flag,
         primary_recovery_type_code,
         primary_rec_type_rule_flag,
         secondary_recovery_type_code,
         secondary_rec_type_rule_flag,
         primary_rec_rate_det_rule_flag,
         sec_rec_rate_det_rule_flag,
         def_primary_rec_rate_code,
         def_secondary_rec_rate_code,
         effective_from,
         effective_to,
         def_rec_settlement_option_code,
         tax_account_source_tax
    FROM ZX_TAXES_B
   WHERE tax_id =  c_tax_id;

   CURSOR  get_maximum_tax_dist_num_csr is
   SELECT max(rec_nrec_tax_dist_number)
   FROM zx_rec_nrec_dist
   WHERE tax_line_id = p_detail_tax_line_tbl(p_tax_line_index).tax_line_id
   AND trx_line_dist_id = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_dist_id(
                                                      p_trx_line_dist_index);

   l_max_tax_dist_number  NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN  get_maximum_tax_dist_num_csr;
  FETCH get_maximum_tax_dist_num_csr INTO l_max_tax_dist_number;
  CLOSE get_maximum_tax_dist_num_csr;

  l_max_tax_dist_number := NVL(l_max_tax_dist_number, 0);

  l_rec_nrec_tax_dist_number := l_max_tax_dist_number + 1;
  l_index := p_rnd_begin_index;

  IF p_detail_tax_line_tbl(p_tax_line_index).tax_provider_id IS NULL THEN

    l_tax_id := p_detail_tax_line_tbl(p_tax_line_index).tax_id;
    l_tax := p_detail_tax_line_tbl(p_tax_line_index).tax;
    l_tax_regime_code := p_detail_tax_line_tbl(p_tax_line_index).tax_regime_code;

    -- for applied_from(prepayment)/adjusted_to(credit memo) document ,
    --  get the recovery types from applied_from /adjusted_to document.
    --
    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(
                                           p_trx_line_dist_index) IS NOT NULL THEN
      -- If applied_from_application_id IS NOT NULL,
      -- get detail tax lines from applied_from document.
      --
      get_recovery_from_applied(
	  	l_tax_id,
	  	p_detail_tax_line_tbl(p_tax_line_index).prd_total_tax_amt,
	  	p_trx_line_dist_index,
	  	p_rec_nrec_dist_tbl,
	  	p_rnd_begin_index,
	  	p_rnd_end_index,
	  	p_return_status,
	  	p_error_buffer);

      IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
      THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.det_appl_rec_type',
                    'Incorrect return_status after calling ' ||
                    'ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_applied()');
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.det_appl_rec_type.END',
                        'ZX_TRD_INTERNAL_SERVICES_PVT.det_appl_rec_type(-)'||p_return_status);
        END IF;
      END IF;
      RETURN;

    ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(
                                                p_trx_line_dist_index) IS NOT NULL
    THEN
      -- If adjusted_to_application_id IS NOT NULL,
      -- get detail tax lines from adjusted_to document.
      --
       get_recovery_from_adjusted(
	   	l_tax_id,
	   	p_trx_line_dist_index,
	   	p_rec_nrec_dist_tbl,
	          p_rnd_begin_index,
	   	p_rnd_end_index,
 	  	p_return_status,
 	  	p_error_buffer);

      IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
      THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.det_appl_rec_type',
                    'Incorrect return_status after calling ' ||
                    'ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_adjusted()');
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.det_appl_rec_type.END',
                        'ZX_TRD_INTERNAL_SERVICES_PVT.det_appl_rec_type(-)'||p_return_status);
        END IF;
      END IF;

      -- return to the calling point, the normal recovery type determination
      -- process will be skipped.
      --
      RETURN;
    END IF;  -- applied_from_application_id/adjusted_doc_application_id NOT NULL

    -- Populate tax recovery info cache
    -- g_tax_recovery_info_tbl
    --

    IF NOT g_tax_recovery_info_tbl.EXISTS(l_tax_id) THEN

      OPEN  get_tax_recovery_info_cur(l_tax_id);
      FETCH get_tax_recovery_info_cur INTO
              g_tax_recovery_info_tbl(l_tax_id).allow_recoverability_flag,
              g_tax_recovery_info_tbl(l_tax_id).primary_recovery_type_code,
              g_tax_recovery_info_tbl(l_tax_id).primary_rec_type_rule_flag,
              g_tax_recovery_info_tbl(l_tax_id).secondary_recovery_type_code,
              g_tax_recovery_info_tbl(l_tax_id).secondary_rec_type_rule_flag,
              g_tax_recovery_info_tbl(l_tax_id).primary_rec_rate_det_rule_flag,
              g_tax_recovery_info_tbl(l_tax_id).sec_rec_rate_det_rule_flag,
              g_tax_recovery_info_tbl(l_tax_id).def_primary_rec_rate_code,
              g_tax_recovery_info_tbl(l_tax_id).def_secondary_rec_rate_code,
              g_tax_recovery_info_tbl(l_tax_id).effective_from,
              g_tax_recovery_info_tbl(l_tax_id).effective_to,
              g_tax_recovery_info_tbl(l_tax_id).def_rec_settlement_option_code,
              g_tax_recovery_info_tbl(l_tax_id).tax_account_source_tax;

      IF get_tax_recovery_info_cur%NOTFOUND THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE.END',
                         'ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE(-)'||'error: can not find tax info for ' || l_tax_id);
        END IF;
        CLOSE get_tax_recovery_info_cur;
        RETURN;
      END IF;

      CLOSE get_tax_recovery_info_cur;

      g_tax_recovery_info_tbl(l_tax_id).tax_regime_code := l_tax_regime_code;
      g_tax_recovery_info_tbl(l_tax_id).tax := l_tax;
      g_tax_recovery_info_tbl(l_tax_id).tax_id := l_tax_id;

    END IF;

    IF g_tax_recovery_info_tbl(l_tax_id).allow_recoverability_flag = 'Y' THEN

       p_rec_nrec_dist_tbl(l_index).recoverable_flag:= 'Y';
       p_rec_nrec_dist_tbl(l_index).recovery_type_code
           := g_tax_recovery_info_tbl(l_tax_id).primary_recovery_type_code;
       p_rec_nrec_dist_tbl(l_index).rec_type_rule_flag
           := g_tax_recovery_info_tbl(l_tax_id).primary_rec_type_rule_flag;
       p_rec_nrec_dist_tbl(l_index).rec_rate_det_rule_flag
           := g_tax_recovery_info_tbl(l_tax_id).primary_rec_rate_det_rule_flag;
       p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_dist_number:= l_rec_nrec_tax_dist_number;


       l_index:= l_index + 1;
       l_rec_nrec_tax_dist_number:= l_rec_nrec_tax_dist_number + 1;

       IF g_tax_recovery_info_tbl(l_tax_id).secondary_recovery_type_code IS NOT NULL THEN

          p_rec_nrec_dist_tbl(l_index).recoverable_flag:= 'Y';
          p_rec_nrec_dist_tbl(l_index).recovery_type_code
              := g_tax_recovery_info_tbl(l_tax_id).secondary_recovery_type_code;
          p_rec_nrec_dist_tbl(l_index).rec_type_rule_flag
              := g_tax_recovery_info_tbl(l_tax_id).secondary_rec_type_rule_flag;
          p_rec_nrec_dist_tbl(l_index).rec_rate_det_rule_flag
              := g_tax_recovery_info_tbl(l_tax_id).sec_rec_rate_det_rule_flag;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_dist_number:= l_rec_nrec_tax_dist_number;

          l_index:= l_index + 1;    --reserved for non-recoverable line
          l_rec_nrec_tax_dist_number:= l_rec_nrec_tax_dist_number + 1;

       END IF;

    ELSE  -- no recovery allowed

     IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE',
                     'No applicable recovery type found');
     END IF;

    END IF;
  ELSE  --provider calculated tax lines should be 100% non-recoverable.
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE',
                     'Provider calculated tax lines are 100% non-recoverable.');
    END IF;

  END IF;

 p_rnd_end_index:= l_index;
 p_rec_nrec_dist_tbl(l_index).recoverable_flag:= 'N';
 p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_dist_number:= l_rec_nrec_tax_dist_number;

 IF (g_level_procedure >= g_current_runtime_level ) THEN

   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE(-)'||
                  ' begin index = ' || p_rnd_end_index||
                  ' end index = ' || p_rnd_end_index);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE',
                      p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE(-)');
    END IF;

END DET_APPL_REC_TYPE;

PROCEDURE get_tax_related_columns_sta(
 p_detail_tax_line_tbl  IN             ZX_TRD_SERVICES_PUB_PKG.tax_line_tbl_type,
 p_tax_line_index       IN             NUMBER,
 p_trx_line_dist_index  IN             NUMBER,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY  ZX_TRD_SERVICES_PUB_PKG.rec_nrec_dist_tbl_type,
 p_rnd_begin_index      IN             NUMBER,
 p_rnd_end_index        IN             NUMBER,
 p_return_status           OUT NOCOPY  VARCHAR2,
 p_error_buffer            OUT NOCOPY  VARCHAR2) IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_STA.BEGIN',
           'ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_STA(+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;

  FOR i IN p_rnd_begin_index..p_rnd_end_index  LOOP

    p_rec_nrec_dist_tbl(i).application_id :=
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).entity_code :=
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).event_class_code :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).event_type_code :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_type_code(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).tax_event_class_code :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_class_code(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).tax_event_type_code :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).trx_id :=
                ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).trx_number :=
                              p_detail_tax_line_tbl(p_tax_line_index).trx_number;

    p_rec_nrec_dist_tbl(i).trx_line_id :=
                              p_detail_tax_line_tbl(p_tax_line_index).trx_line_id;

    p_rec_nrec_dist_tbl(i).trx_level_type :=
                              p_detail_tax_line_tbl(p_tax_line_index).trx_level_type;

    p_rec_nrec_dist_tbl(i).trx_line_number :=
                              p_detail_tax_line_tbl(p_tax_line_index).trx_line_number;
    p_rec_nrec_dist_tbl(i).trx_line_dist_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_dist_id(p_trx_line_dist_index);


    p_rec_nrec_dist_tbl(i).item_dist_number :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.item_dist_number(p_trx_line_dist_index);

--    need to add later
--    p_rec_nrec_dist_tbl(i).tax_line_dist_number :=
--    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_line_dist_number(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).content_owner_id :=
                              p_detail_tax_line_tbl(p_tax_line_index).content_owner_id;

    p_rec_nrec_dist_tbl(i).ref_doc_application_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).ref_doc_entity_code :=
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_entity_code(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).ref_doc_event_class_code :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_event_class_code(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).ref_doc_trx_id :=
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_trx_id(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).ref_doc_line_id :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_line_id(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).ref_doc_trx_level_type :=
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_trx_level_type(p_trx_line_dist_index);

    p_rec_nrec_dist_tbl(i).ref_doc_dist_id :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_dist_id(p_trx_line_dist_index);

/*
    p_rec_nrec_dist_tbl(i).hdr_trx_user_key1 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.hdr_trx_user_key1(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).hdr_trx_user_key2 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.hdr_trx_user_key2(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).hdr_trx_user_key3 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.hdr_trx_user_key3(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).hdr_trx_user_key4 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.hdr_trx_user_key4(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).hdr_trx_user_key5 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.hdr_trx_user_key5(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).hdr_trx_user_key6 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.hdr_trx_user_key6(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).line_trx_user_key1 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_trx_user_key1(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).line_trx_user_key2 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_trx_user_key2(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).line_trx_user_key3 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_trx_user_key3(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).line_trx_user_key4 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_trx_user_key4(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).line_trx_user_key5 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_trx_user_key5(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).line_trx_user_key6 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_trx_user_key6(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).dist_trx_user_key1 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.dist_trx_user_key1(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).dist_trx_user_key2 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.dist_trx_user_key2(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).dist_trx_user_key3 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.dist_trx_user_key3(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).dist_trx_user_key4 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.dist_trx_user_key4(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).dist_trx_user_key5 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.dist_trx_user_key5(p_trx_line_dist_index);
    p_rec_nrec_dist_tbl(i).dist_trx_user_key6 :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.dist_trx_user_key6(p_trx_line_dist_index);
*/
    p_rec_nrec_dist_tbl(i).tax_regime_id :=
                              p_detail_tax_line_tbl(p_tax_line_index).tax_regime_id;

    p_rec_nrec_dist_tbl(i).tax_regime_code :=
                            p_detail_tax_line_tbl(p_tax_line_index).tax_regime_code;
    p_rec_nrec_dist_tbl(i).tax_id := p_detail_tax_line_tbl(p_tax_line_index).tax_id;
    p_rec_nrec_dist_tbl(i).tax := p_detail_tax_line_tbl(p_tax_line_index).tax;

    p_rec_nrec_dist_tbl(i).tax_line_id :=
                                p_detail_tax_line_tbl(p_tax_line_index).tax_line_id;

    p_rec_nrec_dist_tbl(i).ledger_id :=
                                  p_detail_tax_line_tbl(p_tax_line_index).ledger_id;
    p_rec_nrec_dist_tbl(i).record_type_code :=
                           p_detail_tax_line_tbl(p_tax_line_index).record_type_code;

    p_rec_nrec_dist_tbl(i).legal_entity_id :=
                            p_detail_tax_line_tbl(p_tax_line_index).legal_entity_id;

    p_rec_nrec_dist_tbl(i).mrc_tax_dist_flag :=
                            p_detail_tax_line_tbl(p_tax_line_index).mrc_tax_line_flag;

    -- Bug 7117340 -- DFF ER
    p_rec_nrec_dist_tbl(i).attribute1         := p_detail_tax_line_tbl(p_tax_line_index).attribute1;
    p_rec_nrec_dist_tbl(i).attribute2         := p_detail_tax_line_tbl(p_tax_line_index).attribute2;
    p_rec_nrec_dist_tbl(i).attribute3         := p_detail_tax_line_tbl(p_tax_line_index).attribute3;
    p_rec_nrec_dist_tbl(i).attribute4         := p_detail_tax_line_tbl(p_tax_line_index).attribute4;
    p_rec_nrec_dist_tbl(i).attribute5         := p_detail_tax_line_tbl(p_tax_line_index).attribute5;
    p_rec_nrec_dist_tbl(i).attribute6         := p_detail_tax_line_tbl(p_tax_line_index).attribute6;
    p_rec_nrec_dist_tbl(i).attribute7         := p_detail_tax_line_tbl(p_tax_line_index).attribute7;
    p_rec_nrec_dist_tbl(i).attribute8         := p_detail_tax_line_tbl(p_tax_line_index).attribute8;
    p_rec_nrec_dist_tbl(i).attribute9         := p_detail_tax_line_tbl(p_tax_line_index).attribute9;
    p_rec_nrec_dist_tbl(i).attribute10        := p_detail_tax_line_tbl(p_tax_line_index).attribute10;
    p_rec_nrec_dist_tbl(i).attribute11        := p_detail_tax_line_tbl(p_tax_line_index).attribute11;
    p_rec_nrec_dist_tbl(i).attribute12        := p_detail_tax_line_tbl(p_tax_line_index).attribute12;
    p_rec_nrec_dist_tbl(i).attribute13        := p_detail_tax_line_tbl(p_tax_line_index).attribute13;
    p_rec_nrec_dist_tbl(i).attribute14        := p_detail_tax_line_tbl(p_tax_line_index).attribute14;
    p_rec_nrec_dist_tbl(i).attribute15        := p_detail_tax_line_tbl(p_tax_line_index).attribute15;
    p_rec_nrec_dist_tbl(i).attribute_category := p_detail_tax_line_tbl(p_tax_line_index).attribute_category;
    -- End Bug 7117340 -- DFF ER

    -- IF applied_amt_handling_flag = 'R', copy prd_total_tax_amt,
    -- prd_total_tax_amt_tax_curr, prd_total_tax_amt_funcl_curr from zx_lines
    --
    IF p_rec_nrec_dist_tbl(p_rnd_begin_index).applied_from_tax_dist_id IS NOT NULL THEN

      IF NOT ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl.exists(p_detail_tax_line_tbl(
                    p_tax_line_index).tax_id) then

         ZX_TDS_UTILITIES_PKG.populate_tax_cache (
                p_tax_id         => p_detail_tax_line_tbl(p_tax_line_index).tax_id,
                p_return_status  => p_return_status,
                p_error_buffer   => p_error_buffer);
      END IF;


       IF ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(p_detail_tax_line_tbl(
                    p_tax_line_index).tax_id).applied_amt_handling_flag = 'R'
       THEN
        	p_rec_nrec_dist_tbl(i).prd_total_tax_amt :=
                     p_detail_tax_line_tbl(p_tax_line_index).prd_total_tax_amt;
      		p_rec_nrec_dist_tbl(i).prd_total_tax_amt_tax_curr :=
        	    p_detail_tax_line_tbl(p_tax_line_index).prd_total_tax_amt_tax_curr;
      		p_rec_nrec_dist_tbl(i).prd_total_tax_amt_funcl_curr :=
          		p_detail_tax_line_tbl(p_tax_line_index).prd_total_tax_amt_funcl_curr;
       END IF;

    END IF;

  END LOOP;        -- i in p_rnd_begin_index..p_rnd_end_index

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_STA.END',
           'ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_STA(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_STA',
              p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_STA.END',
             'ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_STA(-)');
    END IF;
END get_tax_related_columns_sta;


PROCEDURE get_tax_related_columns_var(
 p_detail_tax_line_tbl  IN             ZX_TRD_SERVICES_PUB_PKG.tax_line_tbl_type,
 p_tax_line_index       IN             NUMBER,
 p_trx_line_dist_index  IN             NUMBER,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY  ZX_TRD_SERVICES_PUB_PKG.rec_nrec_dist_tbl_type,
 p_rnd_begin_index      IN             NUMBER,
 p_rnd_end_index        IN             NUMBER,
 p_return_status           OUT NOCOPY  VARCHAR2,
 p_error_buffer            OUT NOCOPY  VARCHAR2) IS

 l_temp_line_amt           NUMBER;
 --l_period_name             gl_period_statuses.period_name%TYPE := '';

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR(+)');
  END IF;
  p_return_status:= FND_API.G_RET_STS_SUCCESS;

  FOR i in p_rnd_begin_index..p_rnd_end_index
  LOOP

    IF NVL(p_rec_nrec_dist_tbl(i).reverse_flag, 'N') <> 'Y' AND
       NVL(p_rec_nrec_dist_tbl(i).freeze_flag, 'N') <> 'Y'
    THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR',
                      'Reverse flag and freeze flag are not Y');
      END IF;


      p_rec_nrec_dist_tbl(i).INTENDED_USE:= ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LINE_INTENDED_USE(p_trx_line_dist_index);
      p_rec_nrec_dist_tbl(i).PROJECT_ID:= ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PROJECT_ID(p_trx_line_dist_index);
      p_rec_nrec_dist_tbl(i).TASK_ID:= ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TASK_ID(p_trx_line_dist_index);
      p_rec_nrec_dist_tbl(i).AWARD_ID:= ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.AWARD_ID(p_trx_line_dist_index);
      p_rec_nrec_dist_tbl(i).EXPENDITURE_TYPE:= ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.EXPENDITURE_TYPE(p_trx_line_dist_index);
      p_rec_nrec_dist_tbl(i).EXPENDITURE_ORGANIZATION_ID:= ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.EXPENDITURE_ORGANIZATION_ID(p_trx_line_dist_index);
      p_rec_nrec_dist_tbl(i).EXPENDITURE_ITEM_DATE:= ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.EXPENDITURE_ITEM_DATE(p_trx_line_dist_index);
      p_rec_nrec_dist_tbl(i).ACCOUNT_CCID:= ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ACCOUNT_CCID(p_trx_line_dist_index);
      p_rec_nrec_dist_tbl(i).ACCOUNT_STRING:= ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ACCOUNT_STRING(p_trx_line_dist_index);

      p_rec_nrec_dist_tbl(i).TRX_LINE_DIST_AMT := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_AMT(p_trx_line_dist_index);
      p_rec_nrec_dist_tbl(i).TRX_LINE_DIST_QTY := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_QUANTITY(p_trx_line_dist_index);
      --p_rec_nrec_dist_tbl(i).GL_DATE := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_GL_DATE(p_trx_line_dist_index);  -- copy gl date

      /*AP_UTILITIES_PKG.get_open_gl_date(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_GL_DATE(p_trx_line_dist_index),
                                        l_period_name,
                                        p_rec_nrec_dist_tbl(i).GL_DATE,
                                        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.INTERNAL_ORGANIZATION_ID(p_trx_line_dist_index));

      IF p_rec_nrec_dist_tbl(i).GL_DATE IS NULL THEN

	      p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_CANCEL_NO_OPEN_FUT_PERIOD');
        FND_MESSAGE.SET_TOKEN('DATE', to_char(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_GL_DATE(p_trx_line_dist_index), 'dd-mon-yyyy'));

	      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id := p_detail_tax_line_tbl(p_tax_line_index).trx_line_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type := p_detail_tax_line_tbl(p_tax_line_index).trx_level_type;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.tax_line_id := p_detail_tax_line_tbl(p_tax_line_index).tax_line_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_dist_id := p_rec_nrec_dist_tbl(i).trx_line_dist_id;
        ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

	      IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR',
                      'No Open Period or future period found for the accounting date passed by Payables');
          FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR.END',
                   'ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR(-)');
        END IF;
	      RETURN;
      END IF;*/

      -- tax only line
      IF p_rec_nrec_dist_tbl(i).Tax_Only_Line_Flag = 'Y' THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR',
                      'Tax only line flag is Y');
        END IF;

   	    p_rec_nrec_dist_tbl(i).TRX_LINE_DIST_TAX_AMT := p_detail_tax_line_tbl(p_tax_line_index).TAX_AMT;
      	p_rec_nrec_dist_tbl(i).UNROUNDED_TAXABLE_AMT := p_detail_tax_line_tbl(p_tax_line_index).TAXABLE_AMT;
     ELSE
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR',
                      'Tax only line flag is not Y');
        END IF;

        IF p_detail_tax_line_tbl(p_tax_line_index).applied_from_event_class_code = 'PREPAYMENT INVOICES' THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR',
                      'Prepayment Invoice application');
          END IF;
          l_temp_line_amt := p_detail_tax_line_tbl(p_tax_line_index).line_amt -
                             NVL(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.total_inc_tax_amt(p_trx_line_dist_index), 0);

        ELSE
          -- bug 5019399
	        -- bug 6670955
          l_temp_line_amt := p_detail_tax_line_tbl(p_tax_line_index).line_amt;
          --NVL(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.total_inc_tax_amt(p_trx_line_dist_index), 0);
        END IF;

        IF l_temp_line_amt <> 0 THEN   -- Bug 4932210, 5019399

          p_rec_nrec_dist_tbl(i).TRX_LINE_DIST_TAX_AMT :=
           p_detail_tax_line_tbl(p_tax_line_index).TAX_AMT *
           ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_AMT(p_trx_line_dist_index) /l_temp_line_amt;

          -- comment out for bug 3795178
          /*ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_QUANTITY(p_trx_line_dist_index) /
           ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_QUANTITY(p_trx_line_dist_index); */

          p_rec_nrec_dist_tbl(i).UNROUNDED_TAXABLE_AMT :=
           p_detail_tax_line_tbl(p_tax_line_index).TAXABLE_AMT *
           ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_AMT(p_trx_line_dist_index) /l_temp_line_amt;

          -- comment out for bug 3795178
          /*ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_QUANTITY(p_trx_line_dist_index) /
           ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_QUANTITY(p_trx_line_dist_index); */

        ELSE
          -- Bug 5195602: For reversed item distributions, line_amt is 0,
          -- but TRX_LINE_DIST_AMT might not be 0.
          --
          p_rec_nrec_dist_tbl(i).trx_line_dist_tax_amt := p_detail_tax_line_tbl(p_tax_line_index).tax_amt;
          p_rec_nrec_dist_tbl(i).unrounded_taxable_amt := p_detail_tax_line_tbl(p_tax_line_index).taxable_amt;

        END IF;
      END IF;

      p_rec_nrec_dist_tbl(i).TAX_RATE_ID:= p_detail_tax_line_tbl(p_tax_line_index).TAX_RATE_ID;
      p_rec_nrec_dist_tbl(i).TAX_RATE_CODE:= p_detail_tax_line_tbl(p_tax_line_index).TAX_RATE_CODE;
      p_rec_nrec_dist_tbl(i).TAX_RATE:= p_detail_tax_line_tbl(p_tax_line_index).TAX_RATE;
      p_rec_nrec_dist_tbl(i).Inclusive_Flag:= p_detail_tax_line_tbl(p_tax_line_index).Tax_Amt_Included_Flag;
      -- bug#6709478
      --p_rec_nrec_dist_tbl(i).SUMMARY_TAX_LINE_ID:= p_detail_tax_line_tbl(p_tax_line_index).SUMMARY_TAX_LINE_ID;
      p_rec_nrec_dist_tbl(i).CURRENCY_CONVERSION_DATE:= p_detail_tax_line_tbl(p_tax_line_index).CURRENCY_CONVERSION_DATE;
      p_rec_nrec_dist_tbl(i).CURRENCY_CONVERSION_TYPE:= p_detail_tax_line_tbl(p_tax_line_index).CURRENCY_CONVERSION_TYPE;
      p_rec_nrec_dist_tbl(i).CURRENCY_CONVERSION_RATE:= p_detail_tax_line_tbl(p_tax_line_index).CURRENCY_CONVERSION_RATE;
      p_rec_nrec_dist_tbl(i).TAX_CURRENCY_CONVERSION_DATE:= p_detail_tax_line_tbl(p_tax_line_index).TAX_CURRENCY_CONVERSION_DATE;
      p_rec_nrec_dist_tbl(i).TAX_CURRENCY_CONVERSION_TYPE:= p_detail_tax_line_tbl(p_tax_line_index).TAX_CURRENCY_CONVERSION_TYPE;
      p_rec_nrec_dist_tbl(i).TAX_CURRENCY_CONVERSION_RATE:= p_detail_tax_line_tbl(p_tax_line_index).TAX_CURRENCY_CONVERSION_RATE;
      p_rec_nrec_dist_tbl(i).MINIMUM_ACCOUNTABLE_UNIT:= p_detail_tax_line_tbl(p_tax_line_index).MINIMUM_ACCOUNTABLE_UNIT;
      p_rec_nrec_dist_tbl(i).PRECISION:= p_detail_tax_line_tbl(p_tax_line_index).PRECISION;
      p_rec_nrec_dist_tbl(i).Rounding_Rule_Code:= p_detail_tax_line_tbl(p_tax_line_index).ROUNDING_RULE_CODE;
      p_rec_nrec_dist_tbl(i).TAX_STATUS_ID:= p_detail_tax_line_tbl(p_tax_line_index).TAX_STATUS_ID;
      p_rec_nrec_dist_tbl(i).TAX_STATUS_CODE:= p_detail_tax_line_tbl(p_tax_line_index).TAX_STATUS_CODE;
      p_rec_nrec_dist_tbl(i).TRX_CURRENCY_CODE:= p_detail_tax_line_tbl(p_tax_line_index).TRX_CURRENCY_CODE;
      p_rec_nrec_dist_tbl(i).TAX_CURRENCY_CODE:= p_detail_tax_line_tbl(p_tax_line_index).TAX_CURRENCY_CODE;
      p_rec_nrec_dist_tbl(i).unit_price:= p_detail_tax_line_tbl(p_tax_line_index).unit_price;
      p_rec_nrec_dist_tbl(i).self_assessed_flag := p_detail_tax_line_tbl(p_tax_line_index).self_assessed_flag;
      p_rec_nrec_dist_tbl(i).tax_only_line_flag := p_detail_tax_line_tbl(p_tax_line_index).tax_only_line_flag;

      -- bug 5508356
      p_rec_nrec_dist_tbl(i).internal_organization_id := p_detail_tax_line_tbl(p_tax_line_index).internal_organization_id;
      p_rec_nrec_dist_tbl(i).tax_jurisdiction_id := p_detail_tax_line_tbl(p_tax_line_index).tax_jurisdiction_id;

      -- bug 6879755
      IF ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLICATION_ID(p_trx_line_dist_index) = 200 THEN
      BEGIN
        IF p_rec_nrec_dist_tbl(i).orig_gl_date IS NOT NULL THEN
          p_rec_nrec_dist_tbl(i).gl_date :=
              AP_UTILITIES_PKG.get_reversal_gl_date(
                 p_date   => p_rec_nrec_dist_tbl(i).gl_date,
                 p_org_id => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.INTERNAL_ORGANIZATION_ID(p_trx_line_dist_index));
        ELSE
          p_rec_nrec_dist_tbl(i).gl_date :=
              AP_UTILITIES_PKG.get_reversal_gl_date(
                 p_date   => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_GL_DATE(p_trx_line_dist_index),
                 p_org_id => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.INTERNAL_ORGANIZATION_ID(p_trx_line_dist_index));
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
        IF nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_reporting_flag(p_trx_line_dist_index),'N') = 'Y' THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_CANCEL_NO_OPEN_FUT_PERIOD');
          FND_MESSAGE.SET_TOKEN('DATE', to_char(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_GL_DATE(p_trx_line_dist_index), 'dd-mon-yyyy'));

	        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id := p_detail_tax_line_tbl(p_tax_line_index).trx_line_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type := p_detail_tax_line_tbl(p_tax_line_index).trx_level_type;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.tax_line_id := p_detail_tax_line_tbl(p_tax_line_index).tax_line_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_dist_id := p_rec_nrec_dist_tbl(i).trx_line_dist_id;
          ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

	        IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR',
                      'No Open Period or future period found for the accounting date passed by Payables');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR.END',
                   'ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR(-)');
          END IF;
	        RETURN;
        END IF;
      END;
      ELSIF ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLICATION_ID(p_trx_line_dist_index) = 201 THEN

      p_rec_nrec_dist_tbl(i).gl_date :=
           ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_GL_DATE(p_trx_line_dist_index);

    END IF;

      IF nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_reporting_flag(p_trx_line_dist_index),'N') = 'Y' THEN
        IF p_rec_nrec_dist_tbl(i).GL_DATE IS NULL THEN

          p_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_CANCEL_NO_OPEN_FUT_PERIOD');
          FND_MESSAGE.SET_TOKEN('DATE', to_char(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_GL_DATE(p_trx_line_dist_index), 'dd-mon-yyyy'));

	  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id := p_detail_tax_line_tbl(p_tax_line_index).trx_line_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type := p_detail_tax_line_tbl(p_tax_line_index).trx_level_type;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.tax_line_id := p_detail_tax_line_tbl(p_tax_line_index).tax_line_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_dist_id := p_rec_nrec_dist_tbl(i).trx_line_dist_id;
          ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR',
                      'No Open Period or future period found for the accounting date passed by Payables');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR.END',
                   'ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR(-)');
          END IF;
	RETURN;
       END IF;
      END IF;

    END IF;    -- reverse_flag, 'N') <> 'Y' AND  freeze_flag <> 'Y'

    -- bug#6709478 : populate summary tax line id from detail tax line
    p_rec_nrec_dist_tbl(i).summary_tax_line_id := p_detail_tax_line_tbl(p_tax_line_index).summary_tax_line_id;
    p_rec_nrec_dist_tbl(i).tax_line_number := p_detail_tax_line_tbl(p_tax_line_index).tax_line_number;

  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR.END',
                   'ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR',
                      p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR.END',
                   'ZX_TRD_INTERNAL_SERVICES_PVT.GET_TAX_RELATED_COLUMNS_VAR(-)');
    END IF;

END GET_TAX_RELATED_COLUMNS_VAR;


PROCEDURE get_rec_rate(
 p_detail_tax_line_tbl  IN             ZX_TRD_SERVICES_PUB_PKG.tax_line_tbl_type,
 p_tax_line_index       IN             NUMBER,
 p_trx_line_dist_index  IN             NUMBER,
 p_event_class_rec      IN             ZX_API_PUB.event_class_rec_type,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY  ZX_TRD_SERVICES_PUB_PKG.rec_nrec_dist_tbl_type,
 p_rnd_begin_index      IN             NUMBER,
 p_rnd_end_index        IN OUT NOCOPY  NUMBER,
 p_return_status           OUT NOCOPY  VARCHAR2,
 p_error_buffer            OUT NOCOPY  VARCHAR2) IS

 l_rec_rule_code           VARCHAR2(30);

 l_rec_rate_code           ZX_RATES_B.TAX_RATE_CODE%TYPE;

 l_rec_type_code           VARCHAR2(30);
 l_rec_rate_id             NUMBER;
 l_tax_rate_id             NUMBER;
 l_tax_id                  NUMBER;
 l_non_rec_index           NUMBER;
 l_tax_determine_date      DATE;

 l_tax                     ZX_TAXES_B.tax%TYPE;
 l_tax_date                DATE;
 l_tax_status_code         ZX_STATUS_B.tax_status_code%TYPE;
 l_tax_regime_code         ZX_STATUS_B.tax_regime_code%TYPE;
 l_rec_rate                NUMBER;
 l_total_rec_rate          NUMBER;
 l_tax_jurisdiction_code   zx_rates_b.tax_jurisdiction_code%TYPE;
 l_tax_rate_code           zx_rates_b.tax_rate_code%TYPE;
 l_zx_result_rec           zx_process_results%ROWTYPE;
 l_tbl_index               BINARY_INTEGER;
 l_rec_rate_adhoc_flag     VARCHAR2(1);
 l_def_rec_rate_code       ZX_RATES_B.TAX_RATE_CODE%TYPE;  -- Bug5395277
 l_tax_class               ZX_RATES_B.tax_class%TYPE;
 l_acct_source_tax_rate_id zx_rates_b.tax_rate_id%TYPE;
 l_def_rec_settlement_code zx_rates_b.def_rec_settlement_option_code%TYPE;

 l_def_rec_type_code       ZX_RATES_B.recovery_type_code%TYPE;

/*** Bug#5395227
 CURSOR  get_rec_rule_code_csr(
          c_tax_regime_code       ZX_STATUS_B.tax_regime_code%TYPE,
          c_tax                   ZX_STATUS_B.tax%TYPE,
          c_tax_status_code       ZX_STATUS_B.tax_status_code%TYPE,
          c_tax_rate_code         VARCHAR2,
          c_tax_date              DATE) IS
  SELECT recovery_rule_code
    FROM ZX_SCO_RATES_B_V
   WHERE tax_regime_code = c_tax_regime_code
     AND tax = c_tax
     AND tax_status_code = c_tax_status_code
     AND tax_rate_code = c_tax_rate_code
     AND active_flag   = 'Y'
     AND rate_type_code <> 'RECOVERY'
     AND effective_from <= c_tax_date
     AND (effective_to >= c_tax_date OR effective_to IS NULL)
     --AND rownum = 1
   ORDER BY subscription_level_code;
*******/

 -- Bug#5395227- replace above cursor
 --
CURSOR  get_rec_info_csr(
          c_tax_rate_id       zx_rates_b.tax_rate_id%TYPE) IS

  SELECT recovery_rule_code,
         default_rec_rate_code,
         def_rec_settlement_option_code,
         default_rec_type_code
    FROM ZX_RATES_B
   WHERE tax_rate_id = c_tax_rate_id;


 CURSOR  get_rec_rate_csr(
          c_tax                   ZX_STATUS_B.tax%TYPE,
          c_tax_regime_code       ZX_STATUS_B.tax_regime_code%TYPE,
          c_tax_date              DATE,
--        c_tax_jurisdiction_code zx_rates_b.tax_jurisdiction_code%TYPE,
          c_recovery_type_code    zx_rates_b.recovery_type_code%TYPE,
          c_tax_class             zx_rates_b.tax_class%TYPE,
          c_tax_rate_code         zx_rates_b.tax_rate_code%TYPE)  IS
  SELECT tax_rate_id,
         percentage_rate,
         allow_adhoc_tax_rate_flag
    FROM ZX_SCO_RATES_B_V
   WHERE tax_regime_code = c_tax_regime_code
     AND tax = c_tax
     AND tax_rate_code = c_tax_rate_code
     AND rate_type_code = 'RECOVERY'
     AND recovery_type_code = c_recovery_type_code
     AND active_flag = 'Y'
     AND (tax_class = c_tax_class or tax_class IS NULL)
     AND effective_from <= c_tax_date
     AND (effective_to >= c_tax_date OR effective_to IS NULL)
     --AND rownum = 1
   ORDER BY tax_class NULLS LAST, subscription_level_code;
--   AND rate.tax_jurisdiction_code(+) = c_tax_jurisdiction_code

 CURSOR  get_def_rec_rate_from_type_csr(
          c_tax                 ZX_STATUS_B.tax%TYPE,
          c_tax_regime_code     ZX_STATUS_B.tax_regime_code%TYPE,
          c_tax_date            DATE,
          c_tax_class           zx_rates_b.tax_class%TYPE,
          c_recovery_type_code  zx_rates_b.recovery_type_code%TYPE) IS
  SELECT rate.tax_rate_id,
         rate.tax_rate_code,
         rate.percentage_rate,
         rate.allow_adhoc_tax_rate_flag
    FROM ZX_SCO_RATES_B_V  rate
   WHERE tax = c_tax
     AND tax_regime_code = c_tax_regime_code
     AND active_flag = 'Y'
--   AND tax_jurisdiction_code(+) = c_tax_jurisdiction_code
     AND default_flg_effective_from <= c_tax_date
     AND (default_flg_effective_to >= c_tax_date OR
          default_flg_effective_to IS NULL)
     AND rate_type_code = 'RECOVERY'
     AND rate.recovery_type_code = c_recovery_type_code
     AND (rate.tax_class = c_tax_class or rate.tax_class IS NULL)
     AND default_rate_flag = 'Y'
     --AND rownum = 1
   ORDER BY rate.tax_class NULLS LAST, rate.subscription_level_code;


/*** Bug#5395227- use get_rec_info_csr

 CURSOR  get_def_rec_rate_from_rate_csr(
          c_tax_status_code       ZX_STATUS_B.tax_status_code%TYPE,
          c_tax                   ZX_STATUS_B.tax%TYPE,
          c_tax_regime_code       ZX_STATUS_B.tax_regime_code%TYPE,
          c_tax_date              DATE,
--        c_tax_jurisdiction_code zx_rates_b.tax_jurisdiction_code%TYPE,
          c_recovery_type_code    zx_rates_b.default_rec_type_code%TYPE,
          c_tax_rate_code         zx_rates_b.tax_rate_code%TYPE) IS
  SELECT default_rec_rate_code
    FROM ZX_SCO_RATES_B_V  rate
   WHERE rate.effective_from <= c_tax_date
     AND (rate.effective_to >= c_tax_date  OR  rate.effective_to IS NULL)
     AND rate.tax_rate_code = c_tax_rate_code
     AND rate.tax_status_code = c_tax_status_code
     AND rate.tax = c_tax
     AND rate.active_flag = 'Y'
     AND rate_type_code <> 'RECOVERY'
     AND rate.default_rec_type_code = c_recovery_type_code
     AND rate.tax_regime_code = c_tax_regime_code
     --AND rownum = 1
   ORDER BY rate.subscription_level_code;
--   AND rate.tax_jurisdiction_code(+) = c_tax_jurisdiction_code
***/

 CURSOR  get_tax_rec_info_from_tax_csr(
          c_tax_id                  zx_taxes_b.tax_id%TYPE) IS
  SELECT allow_recoverability_flag,
         primary_recovery_type_code,
         primary_rec_type_rule_flag,
         secondary_recovery_type_code,
         secondary_rec_type_rule_flag,
         primary_rec_rate_det_rule_flag,
         sec_rec_rate_det_rule_flag,
         def_primary_rec_rate_code,
         def_secondary_rec_rate_code,
         effective_from,
         effective_to,
         def_rec_settlement_option_code,
         tax_account_source_tax
    FROM ZX_TAXES_B
   WHERE tax_id =  c_tax_id;

 -- bug 5508356
 CURSOR get_tax_account_entity_id_csr(
            c_recovery_rate_id      zx_rec_nrec_dist.recovery_rate_id%TYPE,
            c_ledger_id             zx_rec_nrec_dist.ledger_id%TYPE,
            c_internal_org_id       zx_rec_nrec_dist.internal_organization_id%TYPE) IS
 SELECT tax_account_entity_id
   FROM zx_accounts
  WHERE  tax_account_entity_id = c_recovery_rate_id
    AND  tax_account_entity_code = 'RATES'
    AND  ledger_id = c_ledger_id
    AND  internal_organization_id = c_internal_org_id;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate(+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;

  l_tax_id:= p_detail_tax_line_tbl(p_tax_line_index).tax_id;
  l_tax := p_detail_tax_line_tbl(p_tax_line_index).tax;
  l_tax_regime_code := p_detail_tax_line_tbl(p_tax_line_index).tax_regime_code;

  IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Tax is '|| l_tax || ' Tax Regime code is '|| l_tax_regime_code);
  END IF;

  -- Bug#5417753- determine tax_class value
  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  -- if recovery info is not exist in the global structure for this tax,
  -- populate the structure for the future usage.
  IF NOT g_tax_recovery_info_tbl.EXISTS(l_tax_id)
  THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Populating tax cache information ');
    END IF;


    OPEN  get_tax_rec_info_from_tax_csr(l_tax_id);
    FETCH get_tax_rec_info_from_tax_csr INTO
      g_tax_recovery_info_tbl(l_tax_id).allow_recoverability_flag,
      g_tax_recovery_info_tbl(l_tax_id).primary_recovery_type_code,
      g_tax_recovery_info_tbl(l_tax_id).primary_rec_type_rule_flag,
      g_tax_recovery_info_tbl(l_tax_id).secondary_recovery_type_code,
      g_tax_recovery_info_tbl(l_tax_id).secondary_rec_type_rule_flag,
      g_tax_recovery_info_tbl(l_tax_id).primary_rec_rate_det_rule_flag,
      g_tax_recovery_info_tbl(l_tax_id).sec_rec_rate_det_rule_flag,
      g_tax_recovery_info_tbl(l_tax_id).def_primary_rec_rate_code,
      g_tax_recovery_info_tbl(l_tax_id).def_secondary_rec_rate_code,
      g_tax_recovery_info_tbl(l_tax_id).effective_from,
      g_tax_recovery_info_tbl(l_tax_id).effective_to,
      g_tax_recovery_info_tbl(l_tax_id).def_rec_settlement_option_code,
      g_tax_recovery_info_tbl(l_tax_id).tax_account_source_tax;

    IF get_tax_rec_info_from_tax_csr%NOTFOUND THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
               'error: ' || 'no tax info can be found for '||l_tax_id);
      END IF;
      CLOSE get_tax_rec_info_from_tax_csr;
      RETURN;
    END IF;

    CLOSE get_tax_rec_info_from_tax_csr;

    g_tax_recovery_info_tbl(l_tax_id).tax_regime_code := l_tax_regime_code;
    g_tax_recovery_info_tbl(l_tax_id).tax := l_tax;
    g_tax_recovery_info_tbl(l_tax_id).tax_id := l_tax_id;

  END IF;

  IF NOT ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl.exists(l_tax_id) then

     ZX_TDS_UTILITIES_PKG.populate_tax_cache (
              p_tax_id         => l_tax_id,
              p_return_status  => p_return_status,
              p_error_buffer   => p_error_buffer);
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Populated tax cache information ');
  END IF;


  -- (If applied_from_application_id IS NOT NULL and
  -- applied_amt_handling_flag = 'P'), or adjusted_doc_application_id is not
  -- null, copy tax recovery rate percentage from applied_from/adjusted_to
  -- document. Skip the tax recovery rate determination process.
  --
  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(
                                           p_trx_line_dist_index) IS NOT NULL OR
    (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(
                                          p_trx_line_dist_index) IS NOT NULL AND
     ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).applied_amt_handling_flag ='P')
  THEN

    IF (g_level_procedure >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate.END',
                    'ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate(-)'||
                    'tax recovery rate is copied from applied_from or adjusted_to document');
    END IF;
    RETURN;

  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Adjusted doc, applied from doc information is null ');
  END IF;


  l_tax_rate_code := p_detail_tax_line_tbl(p_tax_line_index).tax_rate_code;
  l_tax_rate_id := p_detail_tax_line_tbl(p_tax_line_index).tax_rate_id;
  l_tax_determine_date :=
                   p_detail_tax_line_tbl(p_tax_line_index).tax_determine_date;
  l_tax_status_code := p_detail_tax_line_tbl(p_tax_line_index).tax_status_code;
  l_tax_jurisdiction_code :=
                p_detail_tax_line_tbl(p_tax_line_index).tax_jurisdiction_code;
  l_tax_date := p_detail_tax_line_tbl(p_tax_line_index).tax_date;


  l_total_rec_rate:= 0;

  IF p_rnd_begin_index IS NULL OR p_rnd_end_index IS NULL OR
     p_rnd_begin_index > p_rnd_end_index
  THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'begin or end index is null, or begin index > end index');
    END IF;
    RETURN;
  END IF;

  FOR i IN p_rnd_begin_index..p_rnd_end_index LOOP

    IF NVL(p_rec_nrec_dist_tbl(i).reverse_flag, 'N') <> 'Y' AND
       NVL(p_rec_nrec_dist_tbl(i).freeze_flag, 'N') <> 'Y'
    THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Reverse flag and freeze flag are not Y.');
      END IF;


      IF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag,'N') = 'N' THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Recoverable flag is N');
        END IF;

        l_non_rec_index := i;
        IF  p_rec_nrec_dist_tbl(l_non_rec_index).account_source_tax_rate_id IS NULL THEN
           OPEN  get_tax_account_entity_id_csr(
            p_rec_nrec_dist_tbl(l_non_rec_index).tax_rate_id,
            p_rec_nrec_dist_tbl(l_non_rec_index).ledger_id,
            p_rec_nrec_dist_tbl(l_non_rec_index).internal_organization_id);
            FETCH get_tax_account_entity_id_csr INTO l_acct_source_tax_rate_id;
            CLOSE get_tax_account_entity_id_csr;
         IF l_acct_source_tax_rate_id IS NOT NULL THEN
          p_rec_nrec_dist_tbl(l_non_rec_index).account_source_tax_rate_id := l_acct_source_tax_rate_id;
         ELSE
           p_rec_nrec_dist_tbl(l_non_rec_index).account_source_tax_rate_id :=
              p_detail_tax_line_tbl(p_tax_line_index).account_source_tax_rate_id;

         END IF;

        END IF;

      ELSE -- recoverable line
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Recoverable flag is Y');
        END IF;


        l_rec_type_code:= p_rec_nrec_dist_tbl(i).recovery_type_code;
        l_rec_rate_code:= NULL;
        l_rec_rate_id:= NULL;
        l_rec_rate:= NULL;
        l_def_rec_settlement_code := NULL;
        l_acct_source_tax_rate_id := NULL;

        IF NVL(p_rec_nrec_dist_tbl(i).historical_flag, 'N') = 'Y' OR
           NVL(p_rec_nrec_dist_tbl(i).last_manual_entry, 'X') =
                                                       'RECOVERY_RATE_CODE' OR
           NVL(p_rec_nrec_dist_tbl(i).last_manual_entry, 'X') =
                                                       'RECOVERY_RATE' THEN --Bug7250287

          -- For migrated recovery tax distrabutions, or RECOVERY_RATE_CODE
          -- is overridden, accumulate total recovery rate
          --
          l_total_rec_rate :=
                          l_total_rec_rate + p_rec_nrec_dist_tbl(i).rec_nrec_rate;
        ELSE

          IF NVL(p_event_class_rec.enforce_tax_from_ref_doc_flag,'N') = 'Y' AND
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(
                                              p_trx_line_dist_index) IS NOT NULL
             AND p_rec_nrec_dist_tbl(i).recovery_rate_code IS NOT NULL
          THEN

            l_rec_rate_code := p_rec_nrec_dist_tbl(i).recovery_rate_code;

            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                     'Enforce Tax Recovery Code from Reference Document.');
            END IF;

          ELSE

            -- bug 9760322
            --
            IF l_rec_type_code = g_tax_recovery_info_tbl(
                                        l_tax_id).primary_recovery_type_code
            THEN
              p_rec_nrec_dist_tbl(i).rec_rate_det_rule_flag :=
               g_tax_recovery_info_tbl(l_tax_id).primary_rec_rate_det_rule_flag;

            ELSIF l_rec_type_code = g_tax_recovery_info_tbl(
                                      l_tax_id).secondary_recovery_type_code
            THEN
               p_rec_nrec_dist_tbl(i).rec_rate_det_rule_flag :=
                   g_tax_recovery_info_tbl(l_tax_id).sec_rec_rate_det_rule_flag;
            END IF;

            IF p_rec_nrec_dist_tbl(i).rec_rate_det_rule_flag = 'Y' THEN

              -- Bug#5395227- get recovery rule code and default
              -- recovery rate code from zx_rates_b
              --
              OPEN  get_rec_info_csr(l_tax_rate_id);
              FETCH get_rec_info_csr INTO l_rec_rule_code,
                                          l_def_rec_rate_code,
                                          l_def_rec_settlement_code,
                                          l_def_rec_type_code;
              CLOSE get_rec_info_csr;

              -- Bug 6813467 - Removed the check IF l_rec_rule_code IS NOT NULL, it should enter
              -- rules processing unconditionally. Rules Engine will process for the rec_rule_code
              -- that is passed and if not found then will process further.
              IF (g_level_statement >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                             'l_rec_rule_code : '|| l_rec_rule_code);
                      FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                             'l_def_rec_rate_code : ' || l_def_rec_rate_code);
                      FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                             'l_def_rec_settlement_code : ' ||l_def_rec_settlement_code );
                      FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                             'l_rec_type_code : ' || l_rec_type_code );
                      FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                             'l_def_rec_rate_code : ' || l_def_rec_rate_code );
              END IF;

                ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process(
                              'DET_RECOVERY_RATE',
                              'TRX_LINE_DIST_TBL',
                               p_trx_line_dist_index,
                               p_event_class_rec,
                               l_tax_id,
                               NULL,-- l_tax_status_code
                               l_tax_determine_date,
                               l_rec_rule_code,
                               l_rec_type_code,
                               l_zx_result_rec,
                               p_return_status,
                               p_error_buffer);

                l_rec_rate_code:= l_zx_result_rec.alphanumeric_result;
                l_rec_rate_id:= l_zx_result_rec.numeric_result;
                IF (g_level_statement >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                             'l_rec_rate_code : '||l_rec_rate_code );
                      FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                             'l_rec_rate_id : ' || to_char(l_rec_rate_id));

                END IF;


                -- bug 5716167
                IF l_rec_rate_code IS NULL THEN
                  -- bug 9759983
                  IF l_def_rec_type_code <> p_rec_nrec_dist_tbl(i).recovery_type_code THEN
                    NULL;
                  ELSE
                    l_rec_rate_code := l_def_rec_rate_code;
                  END IF;
                END IF;

                -- bug 5386805: populate rec_rate_result_id;
                --
                p_rec_nrec_dist_tbl(i).rec_rate_result_id := l_zx_result_rec.result_id;

            END IF;  -- rec_rate_det_rule_flag

            IF l_rec_rate_code IS NULL THEN
                -- Bug#5457916- need to fetch l_def_rec_rate_code
                -- if rec_rate_det_rule_flag is 'N', the cursor
                -- has not been fetched earlier, the l_rec_rule_code
                -- is fetched in this case but not used
                --
              IF NVL(p_rec_nrec_dist_tbl(i).rec_rate_det_rule_flag, 'N')  = 'N' THEN
                IF (g_level_statement >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'rec_rate_det_rule_flag is N ');
                END IF;

                OPEN  get_rec_info_csr(l_tax_rate_id);
                FETCH get_rec_info_csr INTO l_rec_rule_code,
                                              l_def_rec_rate_code,
                                              l_def_rec_settlement_code,
                                              l_def_rec_type_code;
                CLOSE get_rec_info_csr;
              END IF;
              -- bug 9759983
              IF l_def_rec_type_code <> p_rec_nrec_dist_tbl(i).recovery_type_code THEN
                NULL;
              ELSE
                l_rec_rate_code := l_def_rec_rate_code;
              END IF;

             IF l_rec_rate_code IS NULL THEN

               OPEN get_def_rec_rate_from_type_csr(
                                l_tax,
                                l_tax_regime_code,
                                l_tax_determine_date,
                                l_tax_class,
                                l_rec_type_code);

              FETCH get_def_rec_rate_from_type_csr INTO l_rec_rate_id,
                    l_rec_rate_code, l_rec_rate, l_rec_rate_adhoc_flag;

              CLOSE get_def_rec_rate_from_type_csr;


              IF l_rec_rate_code IS NULL THEN


               /*** Bug#5395227
                OPEN get_def_rec_rate_from_rate_csr(
                                           l_tax_status_code,
                                           l_tax,
                                           l_tax_regime_code,
                                           l_tax_determine_date,
                                           l_rec_type_code,
                                           l_tax_rate_code);

                FETCH get_def_rec_rate_from_rate_csr INTO l_rec_rate_code;
                CLOSE get_def_rec_rate_from_rate_csr;
                ***/

                --
                -- Bug#5457916- need to fetch l_def_rec_rate_code
                -- if rec_rate_det_rule_flag is 'N', the cursor
                -- has not been fetched earlier, the l_rec_rule_code
                -- is fetched in this case but not used
                --
                /***IF NVL(p_rec_nrec_dist_tbl(i).rec_rate_det_rule_flag, 'N')  = 'N' THEN
                  OPEN  get_rec_info_csr(l_tax_rate_id);
                  FETCH get_rec_info_csr INTO l_rec_rule_code,
                                              l_def_rec_rate_code,
                                              l_def_rec_settlement_code;
                  CLOSE get_rec_info_csr;
                END IF;

                l_rec_rate_code := l_def_rec_rate_code;
                ***/


                  -- get def_primary_rec_rate_code or def_secondary_rec_rate_code
                  -- From g_tax_recovery_info_tbl.
                  --

                  IF l_rec_type_code = g_tax_recovery_info_tbl(
                                        l_tax_id).primary_recovery_type_code THEN

                    l_rec_rate_code :=
                      g_tax_recovery_info_tbl(l_tax_id).def_primary_rec_rate_code;

                  ELSIF l_rec_type_code = g_tax_recovery_info_tbl(
                                      l_tax_id).secondary_recovery_type_code THEN

                    l_rec_rate_code := g_tax_recovery_info_tbl(
                                            l_tax_id).def_secondary_rec_rate_code;
                  END IF;

                  IF l_rec_rate_code IS NULL THEN
                    p_return_status := FND_API.G_RET_STS_ERROR;

                    FND_MESSAGE.SET_NAME('ZX','ZX_REC_RATE_CODE_NOT_FOUND');
                    FND_MESSAGE.SET_TOKEN('REGIME_NAME', l_tax_regime_code);
                    FND_MESSAGE.SET_TOKEN('CONTENT_OWNER_NAME',
                           p_detail_tax_line_tbl(p_tax_line_index).content_owner_id);

                    FND_MESSAGE.SET_TOKEN('TAX_NAME', l_tax);
                    FND_MESSAGE.SET_TOKEN('RECOVERY_TYPE', l_rec_type_code);

                    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                       p_detail_tax_line_tbl(p_tax_line_index).trx_line_id;
                    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                       p_detail_tax_line_tbl(p_tax_line_index).trx_level_type;
                    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.tax_line_id :=
                       p_detail_tax_line_tbl(p_tax_line_index).tax_line_id;
                    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_dist_id :=
                       p_rec_nrec_dist_tbl(i).trx_line_dist_id;
                    ZX_API_PUB.add_msg(
                          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

                    IF (g_level_statement >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                             'Cannot find default rec rate code');
                      FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                             'p_return_status := ' || p_return_status);
                      FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate.END',
                             'ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate(-)');
                    END IF;
                    RETURN;
                  END IF; -- default tax recovery rate code not found, raise error
                END IF;   -- default tax recovery rate code at Tax level
              END IF;     -- default tax recovery rate code at recovery type level
            END IF;       -- default tax recovery rate code for Tax Rate

            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                            'l_rec_rate_code = ' || l_rec_rate_code);
            END IF;
          END IF;     -- p_event_class_rec.enforce_tax_from_ref_doc_flag

          -- get l_rec_rate if it is null
          --
          IF l_rec_rate IS NULL THEN

            OPEN get_rec_rate_csr(l_tax,
                                  l_tax_regime_code,
                                  l_tax_determine_date,
                                  l_rec_type_code,
                                  l_tax_class,
                                  l_rec_rate_code);

            FETCH get_rec_rate_csr INTO l_rec_rate_id, l_rec_rate,
                  l_rec_rate_adhoc_flag;
            CLOSE get_rec_rate_csr;
          END IF;   -- _rec_rate IS NULL

          -- Bug 4012677: Support PO item distribution level tax recovery
          -- rate override
          --
          IF ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.overriding_recovery_rate(
                                           p_trx_line_dist_index) IS NOT NULL AND
             p_rec_nrec_dist_tbl(i).recovery_type_code =
                 g_tax_recovery_info_tbl(l_tax_id).primary_recovery_type_code AND
             l_rec_rate_adhoc_flag = 'Y'
          THEN

            p_rec_nrec_dist_tbl(i).orig_rec_nrec_rate := l_rec_rate;
            l_rec_rate :=
             ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.overriding_recovery_rate(
                                                           p_trx_line_dist_index);
          END IF;

          -- For invoice matched to PO and rec_nrec_rate overidden by user in PO,
          -- copy rec_nrec_rate if tax recovery rate is adhoc
          --
          IF NVL(p_event_class_rec.enforce_tax_from_ref_doc_flag,'N') = 'Y' AND
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(
                                         p_trx_line_dist_index) IS NOT NULL AND
             p_rec_nrec_dist_tbl(i).rec_nrec_rate IS NOT NULL AND
             l_rec_rate_adhoc_flag = 'Y'
          THEN

            l_rec_rate := p_rec_nrec_dist_tbl(i).rec_nrec_rate;

          END IF;   -- End Bug 4012677

          -- populate l_rec_rate_id, l_rec_rate_code, l_rec_rate on
          -- this recovery tax distribution
          --
          IF l_rec_rate IS NOT NULL THEN

            p_rec_nrec_dist_tbl(i).recovery_rate_id := l_rec_rate_id;
            p_rec_nrec_dist_tbl(i).recovery_rate_code := l_rec_rate_code;
            p_rec_nrec_dist_tbl(i).rec_nrec_rate := l_rec_rate;

            l_total_rec_rate:= l_total_rec_rate + l_rec_rate;

          ELSE      -- l_rec_rate NULL

            p_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('ZX','ZX_REC_RATE_NOT_FOUND');
            FND_MESSAGE.SET_TOKEN('REGIME_NAME', l_tax_regime_code);
            FND_MESSAGE.SET_TOKEN('CONTENT_OWNER_NAME',
                                  p_detail_tax_line_tbl(p_tax_line_index).content_owner_id);

            FND_MESSAGE.SET_TOKEN('TAX_NAME', l_tax);
            FND_MESSAGE.SET_TOKEN('RECOVERY_TYPE', l_rec_type_code);
            FND_MESSAGE.SET_TOKEN('RECOVERY_RATE_CODE', l_rec_rate_code);

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                     p_detail_tax_line_tbl(p_tax_line_index).trx_line_id;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                     p_detail_tax_line_tbl(p_tax_line_index).trx_level_type;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.tax_line_id :=
                     p_detail_tax_line_tbl(p_tax_line_index).tax_line_id;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_dist_id :=
                     p_rec_nrec_dist_tbl(i).trx_line_dist_id;

            ZX_API_PUB.add_msg(
                        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);


            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                            'error: Recovery rate is not found.');

              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate.END',
                            'ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate(-)');
            END IF;
            RETURN;
          END IF;
        END IF;     -- LME <> 'RECOVERY_RATE_CODE' OR historical_flag <> 'Y'

        -- bug 5508356: populate def_rec_settlement_option_code
        --
        IF l_def_rec_settlement_code IS NULL THEN

          OPEN  get_rec_info_csr(l_tax_rate_id);
          FETCH get_rec_info_csr INTO l_rec_rule_code,
                                      l_def_rec_rate_code,
                                      l_def_rec_settlement_code,
                                      l_def_rec_type_code;
          CLOSE get_rec_info_csr;

          IF l_def_rec_settlement_code IS NULL THEN
            l_def_rec_settlement_code :=
              g_tax_recovery_info_tbl(l_tax_id).def_rec_settlement_option_code;

            IF l_def_rec_settlement_code IS NULL THEN
              l_def_rec_settlement_code := 'IMMEDIATE';
            END IF;
          END IF;
        END IF;     -- l_def_rec_settlement_code IS NULL

        p_rec_nrec_dist_tbl(i).def_rec_settlement_option_code :=
                                                      l_def_rec_settlement_code;

        -- bug 5508356: populate account_source_tax_rate_id
        --
        OPEN  get_tax_account_entity_id_csr(
                       p_rec_nrec_dist_tbl(i).recovery_rate_id,
                       p_rec_nrec_dist_tbl(i).ledger_id,
                       p_rec_nrec_dist_tbl(i).internal_organization_id);
        FETCH get_tax_account_entity_id_csr INTO l_acct_source_tax_rate_id;
        CLOSE get_tax_account_entity_id_csr;

        IF l_acct_source_tax_rate_id IS NOT NULL THEN
            p_rec_nrec_dist_tbl(i).account_source_tax_rate_id :=
                                                    l_acct_source_tax_rate_id;
          IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Tax accounts defined for recovery rate id '|| to_char(p_rec_nrec_dist_tbl(i).recovery_rate_id));

          END IF;

        ELSE
        -- 6900725
        --    p_rec_nrec_dist_tbl(i).account_source_tax_rate_id :=
        --       p_detail_tax_line_tbl(p_tax_line_index).account_source_tax_rate_id;
        -- This ELSE part contains the fix for bug 6900725
          IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Tax accounts not defined for recovery rate id '|| to_char(p_rec_nrec_dist_tbl(i).recovery_rate_id));

          END IF;

          IF g_tax_recovery_info_tbl(l_tax_id).tax_account_source_tax IS NOT NULL THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Getting account source tax rate id from Tax Accounts Source Tax '|| g_tax_recovery_info_tbl(l_tax_id).tax_account_source_tax );

            END IF;


            FOR j in p_rec_nrec_dist_tbl.first..p_rec_nrec_dist_tbl.last LOOP
              IF p_rec_nrec_dist_tbl(j).tax = g_tax_recovery_info_tbl(l_tax_id).tax_account_source_tax AND
                 p_rec_nrec_dist_tbl(j).tax_regime_code = p_rec_nrec_dist_tbl(i).tax_regime_code AND
                 p_rec_nrec_dist_tbl(j).trx_line_dist_id = p_rec_nrec_dist_tbl(i).trx_line_dist_id AND
                 p_rec_nrec_dist_tbl(j).recovery_type_code = g_tax_recovery_info_tbl(p_rec_nrec_dist_tbl(j).tax_id).primary_recovery_type_code AND
                 p_rec_nrec_dist_tbl(i).recovery_type_code = g_tax_recovery_info_tbl(l_tax_id).primary_recovery_type_code
              THEN

                 p_rec_nrec_dist_tbl(i).account_source_tax_rate_id := p_rec_nrec_dist_tbl(j).account_source_tax_rate_id;

              ELSIF p_rec_nrec_dist_tbl(j).tax = g_tax_recovery_info_tbl(l_tax_id).tax_account_source_tax AND
                    p_rec_nrec_dist_tbl(j).tax_regime_code = p_rec_nrec_dist_tbl(i).tax_regime_code AND
                 p_rec_nrec_dist_tbl(j).trx_line_dist_id = p_rec_nrec_dist_tbl(i).trx_line_dist_id AND
                 p_rec_nrec_dist_tbl(j).recovery_type_code = g_tax_recovery_info_tbl(p_rec_nrec_dist_tbl(j).tax_id).secondary_recovery_type_code AND
                 p_rec_nrec_dist_tbl(i).recovery_type_code = g_tax_recovery_info_tbl(l_tax_id).secondary_recovery_type_code
              THEN

                 p_rec_nrec_dist_tbl(i).account_source_tax_rate_id := p_rec_nrec_dist_tbl(j).account_source_tax_rate_id;

              END IF;
            END LOOP;
            IF p_rec_nrec_dist_tbl(i).account_source_tax_rate_id IS NULL THEN
              FOR j in p_rec_nrec_dist_tbl.first..p_rec_nrec_dist_tbl.last LOOP
                IF p_rec_nrec_dist_tbl(j).tax = g_tax_recovery_info_tbl(l_tax_id).tax_account_source_tax AND
                   p_rec_nrec_dist_tbl(j).tax_regime_code = p_rec_nrec_dist_tbl(i).tax_regime_code AND
                  p_rec_nrec_dist_tbl(j).trx_line_dist_id = p_rec_nrec_dist_tbl(i).trx_line_dist_id AND
                  p_rec_nrec_dist_tbl(i).recovery_type_code = g_tax_recovery_info_tbl(l_tax_id).secondary_recovery_type_code AND
                  g_tax_recovery_info_tbl(p_rec_nrec_dist_tbl(j).tax_id).secondary_recovery_type_code IS NULL AND
                  p_rec_nrec_dist_tbl(j).recovery_type_code = g_tax_recovery_info_tbl(p_rec_nrec_dist_tbl(j).tax_id).primary_recovery_type_code
                THEN

                  p_rec_nrec_dist_tbl(i).account_source_tax_rate_id := p_rec_nrec_dist_tbl(j).account_source_tax_rate_id;

                END IF;
              END LOOP;
            END IF;
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Account source tax rate id for recovery rate '|| to_char(p_rec_nrec_dist_tbl(i).account_source_tax_rate_id));

            END IF;


            IF  p_rec_nrec_dist_tbl(i).account_source_tax_rate_id IS NULL THEN
              OPEN  get_tax_account_entity_id_csr(
                       p_rec_nrec_dist_tbl(i).tax_rate_id,
                       p_rec_nrec_dist_tbl(i).ledger_id,
                       p_rec_nrec_dist_tbl(i).internal_organization_id);
              FETCH get_tax_account_entity_id_csr INTO l_acct_source_tax_rate_id;
              CLOSE get_tax_account_entity_id_csr;
              IF l_acct_source_tax_rate_id IS NOT NULL THEN
                p_rec_nrec_dist_tbl(i).account_source_tax_rate_id := l_acct_source_tax_rate_id;
              ELSE
                p_rec_nrec_dist_tbl(i).account_source_tax_rate_id := p_detail_tax_line_tbl(p_tax_line_index).account_source_tax_rate_id;

              END IF;
              IF (g_level_statement >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Final Account source tax rate id '|| to_char(p_rec_nrec_dist_tbl(i).account_source_tax_rate_id));

              END IF;



            END IF;

          END IF;

        END IF;     -- l_account_source_tax_rate_id IS NOT NULL
      END IF;       -- recoverable_flag = 'N' OR ELSE
    END IF;         -- reverse_flag <> 'Y AND freeze_flag <> 'Y'
  END LOOP;         -- i IN p_rnd_begin_index..p_rnd_end_index

  IF l_non_rec_index IS NULL THEN

    p_rnd_end_index:= p_rnd_end_index + 1;
    l_non_rec_index:= p_rnd_end_index;

    p_rec_nrec_dist_tbl(p_rnd_end_index):= p_rec_nrec_dist_tbl(p_rnd_end_index - 1);

    -- bug 5417252
    SELECT zx_rec_nrec_dist_s.nextval INTO
            p_rec_nrec_dist_tbl(p_rnd_end_index).rec_nrec_tax_dist_id from dual;

    p_rec_nrec_dist_tbl(p_rnd_end_index).rec_nrec_tax_dist_number :=
          p_rec_nrec_dist_tbl(p_rnd_end_index-1).rec_nrec_tax_dist_number + 1;

    p_rec_nrec_dist_tbl(p_rnd_end_index).recoverable_flag := 'N';
    p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_type_id := NULL;
    p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_type_code := NULL;
    p_rec_nrec_dist_tbl(p_rnd_end_index).historical_flag := 'N';
    p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_rate_id := NULL;
    p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_rate_code := NULL;
--6900725
    p_rec_nrec_dist_tbl(p_rnd_end_index).account_source_tax_rate_id := NULL;



  END IF;     -- l_non_rec_index IS NULL
  -- 6900725
  p_rec_nrec_dist_tbl(l_non_rec_index).account_source_tax_rate_id := NULL;
  l_acct_source_tax_rate_id := null;
  IF  p_rec_nrec_dist_tbl(l_non_rec_index).account_source_tax_rate_id IS NULL THEN
    OPEN  get_tax_account_entity_id_csr(
          p_rec_nrec_dist_tbl(l_non_rec_index).tax_rate_id,
          p_rec_nrec_dist_tbl(l_non_rec_index).ledger_id,
          p_rec_nrec_dist_tbl(l_non_rec_index).internal_organization_id);
    FETCH get_tax_account_entity_id_csr INTO l_acct_source_tax_rate_id;
    CLOSE get_tax_account_entity_id_csr;
    IF l_acct_source_tax_rate_id IS NOT NULL THEN
      p_rec_nrec_dist_tbl(l_non_rec_index).account_source_tax_rate_id := l_acct_source_tax_rate_id;
    ELSE
      p_rec_nrec_dist_tbl(l_non_rec_index).account_source_tax_rate_id := p_detail_tax_line_tbl(p_tax_line_index).account_source_tax_rate_id;

    END IF;

  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      'Account source tax rate id for non recoverable dist '||p_rec_nrec_dist_tbl(l_non_rec_index).account_source_tax_rate_id);

  END IF;



  p_rec_nrec_dist_tbl(l_non_rec_index).rec_nrec_rate:= 100 - l_total_rec_rate;
  IF p_rec_nrec_dist_tbl(l_non_rec_index).rec_nrec_rate < 0 THEN
    p_return_status := FND_API.G_RET_STS_ERROR;

    FND_MESSAGE.SET_NAME('ZX','ZX_SUM_REC_RATE_OVER');

    FND_MESSAGE.SET_TOKEN('RECOVERY_TYPE_1',
                          g_tax_recovery_info_tbl(
                                    l_tax_id).primary_recovery_type_code);
    FND_MESSAGE.SET_TOKEN('RECOVERY_TYPE_2',
                          g_tax_recovery_info_tbl(
                                  l_tax_id).secondary_recovery_type_code);
    FND_MESSAGE.SET_TOKEN('REGIME_NAME', l_tax_regime_code);
    FND_MESSAGE.SET_TOKEN('TAX_NAME', l_tax);

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
           p_detail_tax_line_tbl(p_tax_line_index).trx_line_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
           p_detail_tax_line_tbl(p_tax_line_index).trx_level_type;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.tax_line_id :=
           p_detail_tax_line_tbl(p_tax_line_index).tax_line_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_dist_id :=
           p_rec_nrec_dist_tbl(l_non_rec_index).trx_line_dist_id;

    ZX_API_PUB.add_msg(
           ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                     'Error: Total Recovery Rate is greater than 100');
    END IF;
    RETURN;

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                   'p_rec_nrec_dist_tbl(' || l_non_rec_index ||
                   ').rec_nrec_rate = '
                   || p_rec_nrec_dist_tbl(l_non_rec_index).rec_nrec_rate);
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate',
                      p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.get_rec_rate(-)');
    END IF;
END get_rec_rate;

PROCEDURE GET_REC_NREC_DIST_AMT(
 p_detail_tax_line_tbl        IN      ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index             IN      NUMBER,
 p_rec_nrec_dist_tbl          IN OUT NOCOPY  ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index            IN      NUMBER,
 p_rnd_end_index              IN      NUMBER,
 p_return_status              OUT NOCOPY     VARCHAR2,
 p_error_buffer               OUT NOCOPY     VARCHAR2)
IS

BEGIN
 g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_REC_NREC_DIST_AMT.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.GET_REC_NREC_DIST_AMT(+)');
 END IF;
   p_return_status:= FND_API.G_RET_STS_SUCCESS;

 For i in p_rnd_begin_index..p_rnd_end_index
 LOOP
   IF NVL(p_rec_nrec_dist_tbl(i).reverse_flag,'N') = 'N' THEN

      p_rec_nrec_dist_tbl(i).unrounded_rec_nrec_tax_amt:=
         p_rec_nrec_dist_tbl(i).trx_line_dist_tax_amt * p_rec_nrec_dist_tbl(i).rec_nrec_rate/100;

   END IF;
 END LOOP;

 IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_REC_NREC_DIST_AMT.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.GET_REC_NREC_DIST_AMT(-)');
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_REC_NREC_DIST_AMT',
                      p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.GET_REC_NREC_DIST_AMT.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.GET_REC_NREC_DIST_AMT(-)');
    END IF;

END GET_REC_NREC_DIST_AMT;


PROCEDURE round_rec_nrec_amt(
 p_rec_nrec_dist_tbl       IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index         IN            NUMBER,
 p_rnd_end_index           IN            NUMBER,
 p_tax_line_amt            IN            NUMBER,
 p_tax_line_amt_tax_curr   IN            NUMBER,
 p_tax_line_amt_funcl_curr IN            NUMBER,
 p_return_status              OUT NOCOPY VARCHAR2,
 p_error_buffer               OUT NOCOPY VARCHAR2)  IS

 l_rounding_rule_code       zx_taxes_b.rounding_rule_code%TYPE;
 l_min_acct_unit            zx_taxes_b.minimum_accountable_unit%TYPE;
 l_precision                zx_taxes_b.tax_precision%TYPE;
 l_trx_currency_code        zx_rec_nrec_dist.trx_currency_code%TYPE;
 l_tax_currency_code        zx_rec_nrec_dist.tax_currency_code%TYPE;
 l_tax_currency_date        zx_rec_nrec_dist.tax_currency_conversion_date%TYPE;
 l_tax_currency_type        zx_rec_nrec_dist.tax_currency_conversion_type%TYPE;
 l_tax_currency_rate        zx_rec_nrec_dist.tax_currency_conversion_rate%TYPE;
 l_tax_amt_tax_currency     zx_rec_nrec_dist.rec_nrec_tax_amt_tax_curr%TYPE;
 l_taxable_amt_tax_currency zx_rec_nrec_dist.taxable_amt_tax_curr%TYPE;
 l_tax_id			     zx_taxes_b.tax_id%TYPE;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.ROUND_REC_NREC_AMT.BEGIN',
                   'ZX_TRD_INTERNAL_SERVICES_PVT.ROUND_REC_NREC_AMT(+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;

  IF p_rnd_begin_index IS NULL OR p_rnd_end_index IS NULL OR
     p_rnd_begin_index > p_rnd_end_index THEN

    --p_return_status:= FND_API.G_RET_STS_ERROR;
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.ROUND_REC_NREC_AMT',
                    'begin or end index is null, or begin index > end index');
    END IF;
    RETURN;
  END IF;

  -- this procedure is called FOR each tax line so rounding rule etc are the same FOR the tax dists.

  l_rounding_rule_code:= p_rec_nrec_dist_tbl(p_rnd_begin_index).rounding_rule_code;
  l_min_acct_unit:= p_rec_nrec_dist_tbl(p_rnd_begin_index).minimum_accountable_unit;
  l_precision:= p_rec_nrec_dist_tbl(p_rnd_begin_index).precision;

  -- call procedure round_tax_dists_trx_curr to round tax amount.
  -- and taxable amount and adjust tax amount rounding difference.
  --
  round_tax_dists_trx_curr ( p_rec_nrec_dist_tbl,
  			     p_rnd_begin_index,
  			     p_rnd_end_index,
  			     p_tax_line_amt,
  			     p_return_status,
  			     p_error_buffer);

  IF p_rec_nrec_dist_tbl(p_rnd_begin_index).mrc_tax_dist_flag = 'N' THEN
    -- call procedure convert_tax_dists to convert and round tax amount
    -- and taxable amount INTO tax currency and functional curremcy.
    --
    convert_tax_dists ( p_rec_nrec_dist_tbl,
          	      p_rnd_begin_index,
      		      p_rnd_end_index,
  		      p_tax_line_amt_tax_curr,
    		      p_tax_line_amt_funcl_curr,
          	      p_return_status,
          	      p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_rec_nrec_amt',
                      'Incorrect return_status after calling ' ||
                      'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists()');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_rec_nrec_amt.END',
                      'ZX_TRD_INTERNAL_SERVICES_PVT.round_rec_nrec_amt(-)'||p_return_status);
      END IF;
      RETURN;
    END IF;

    IF p_rec_nrec_dist_tbl(p_rnd_begin_index).applied_from_tax_dist_id IS NOT NULL
    THEN
      l_tax_id := p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_id;
      IF ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).applied_amt_handling_flag='R'
      THEN
        -- call round_and_adjust_prd_tax_amts to round and adjust prd_tax_amt,
        -- prd_tax_amt_tax_curr, and prd_tax_amt_funcl_curr
        --
        round_and_adjust_prd_tax_amts (
                p_rec_nrec_dist_tbl  => p_rec_nrec_dist_tbl,
                p_rnd_begin_index    => p_rnd_begin_index,
                p_rnd_end_index      => p_rnd_end_index,
                p_return_status      => p_return_status,
                p_error_buffer       => p_error_buffer);

        IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.ROUND_REC_NREC_AMT',
                          'Incorrect return_status after calling ' ||
                          'ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts');
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.ROUND_REC_NREC_AMT',
                          'RETURN_STATUS = ' || p_return_status);
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.ROUND_REC_NREC_AMT.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.ROUND_REC_NREC_AMT(-)');
          END IF;
          RETURN;
        END IF;

      ELSIF ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).applied_amt_handling_flag='P'
      THEN
        -- copy rec_nrec_tax_amt, rec_nrec_tax_amt_tax_curr,
        -- rec_nrec_tax_amt_funcl_curr to prd_tax_amt, prd_tax_amt_tax_curr,
        -- prd_tax_amt_funcl_curr.

        FOR i IN p_rec_nrec_dist_tbl.FIRST.. p_rec_nrec_dist_tbl.LAST LOOP
          p_rec_nrec_dist_tbl(i).prd_tax_amt :=
                                        p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;
          p_rec_nrec_dist_tbl(i).prd_tax_amt_tax_curr :=
                               p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_tax_curr;
          p_rec_nrec_dist_tbl(i).prd_tax_amt_funcl_curr :=
                             p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_funcl_curr;
        END LOOP;
      END IF;     -- applied_amt_handling_flag = 'R' or 'P'
    END IF;       -- applied_from_tax_dist_id IS NOT NULL
  END IF;         -- mrc_tax_dist_flag = 'N'

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.ROUND_REC_NREC_AMT.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.ROUND_REC_NREC_AMT(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.ROUND_REC_NREC_AMT',
                      p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.ROUND_REC_NREC_AMT.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.ROUND_REC_NREC_AMT(-)');
    END IF;

END ROUND_REC_NREC_AMT;

PROCEDURE round_tax_dists_trx_curr (
 p_rec_nrec_dist_tbl IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index   IN            NUMBER,
 p_rnd_end_index     IN            NUMBER,
 p_tax_line_amt	     IN            NUMBER,
 p_return_status     OUT NOCOPY    VARCHAR2,
 p_error_buffer      OUT NOCOPY    VARCHAR2) IS

 l_non_zero_rec_tax_dists_tbl 	     index_amt_tbl_type;
 l_non_zero_nrec_tax_dists_tbl 	     index_amt_tbl_type;

 l_rec_tax_dists_tbl_sort_flg 	     VARCHAR2(1);
 l_nrec_tax_dists_tbl_sort_flg 	     VARCHAR2(1);

 l_non_zero_rec_tax_index	     NUMBER		:= 0;
 l_non_zero_nrec_tax_index	     NUMBER		:= 0;

 l_rec_tax_rnd_diff      	     NUMBER		:= 0;
 l_nrec_tax_rnd_diff    	     NUMBER		:= 0;
 l_tax_line_rnd_diff		     NUMBER;

 l_rnd_total_rec_tax_amt  	     NUMBER		:= 0;
 l_rnd_total_nrec_tax_amt            NUMBER		:= 0;

 l_max_rec_tax_index	     	     NUMBER		:=NULL;
 l_max_nrec_tax_index		     NUMBER		:=NULL;

 l_rec_amt_largest	     	     NUMBER		:= 0;
 l_nrec_amt_largest		     NUMBER		:= 0;

 l_index			     NUMBER;
 l_min_acct_unit                     zx_taxes_b.minimum_accountable_unit%TYPE;
 l_precision                         zx_taxes_b.tax_precision%TYPE;
 l_round_nrec_flag  VARCHAR2(1);

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;

  IF p_rnd_begin_index IS NULL OR p_rnd_end_index IS NULL OR
                                  p_rnd_begin_index > p_rnd_end_index THEN

    --p_return_status:= FND_API.G_RET_STS_ERROR;
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                     'begin or end index is null, or begin index > end index');
    END IF;
    RETURN;
  END IF;

  FOR i IN p_rnd_begin_index .. p_rnd_end_index LOOP
    -- round rec_nrec_tax_amt and taxable_amt
    --

   -- Bugfix: 5388586, do not round reversal pair of tax distributions

   IF NVL(p_rec_nrec_dist_tbl(i).reverse_flag, 'N') = 'N' THEN

    p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt :=
      ZX_TDS_TAX_ROUNDING_PKG.round_tax(
        p_amount             => p_rec_nrec_dist_tbl(i).unrounded_rec_nrec_tax_amt,
        p_Rounding_Rule_Code => p_rec_nrec_dist_tbl(i).rounding_rule_code,
        p_min_acct_unit      => p_rec_nrec_dist_tbl(i).minimum_accountable_unit,
        p_precision          => p_rec_nrec_dist_tbl(i).precision,
        p_return_status      => p_return_status,
        p_error_buffer       => p_error_buffer);

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                     ' i = '||to_char(i) || ' round '|| p_rec_nrec_dist_tbl(i).unrounded_rec_nrec_tax_amt ||
                     ' to '|| p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt);
    END IF;

    p_rec_nrec_dist_tbl(i).taxable_amt :=
      ZX_TDS_TAX_ROUNDING_PKG.round_tax(
        p_amount             => p_rec_nrec_dist_tbl(i).unrounded_taxable_amt,
        p_Rounding_Rule_Code => p_rec_nrec_dist_tbl(i).rounding_rule_code,
        p_min_acct_unit      => p_rec_nrec_dist_tbl(i).minimum_accountable_unit,
        p_precision          => p_rec_nrec_dist_tbl(i).precision,
        p_return_status      => p_return_status,
        p_error_buffer       => p_error_buffer);
   END IF;

   IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_TAX_ROUNDING_PKG.round_tax()');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.END',
                      'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(-)'||p_return_status);
      END IF;
      RETURN;
    END IF;

   -- Bugfix: 5388586, do not adjust reversal pair of tax distributions
    IF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag, 'N') = 'Y' AND NVL(p_rec_nrec_dist_tbl(i).reverse_flag, 'N') = 'N' THEN

      -- Accumulate l_rnd_total_rec_tax_amt
      --
      l_rnd_total_rec_tax_amt := l_rnd_total_rec_tax_amt +
                                       p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;

      -- Accumulate rounding diffrence of recoverable tax dists
      --
      l_rec_tax_rnd_diff := l_rec_tax_rnd_diff +
           p_rec_nrec_dist_tbl(i).unrounded_rec_nrec_tax_amt -
                        p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;

      IF p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt <> 0 THEN
        -- Record non-zero recoverable tax dists
        --
        l_non_zero_rec_tax_index := l_non_zero_rec_tax_index + 1;

        l_non_zero_rec_tax_dists_tbl(l_non_zero_rec_tax_index).tbl_index := i;
        l_non_zero_rec_tax_dists_tbl(l_non_zero_rec_tax_index).tbl_amt :=
                                      p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;

        -- Record the largest rec_nrec_tax_amt of non-zero recoverable tax dists
        --
        IF ABS(p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt) >= ABS(l_rec_amt_largest)
        THEN
          l_max_rec_tax_index := i;
          l_rec_amt_largest := p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;
        END IF;
      END IF;

   -- Bugfix: 5388586, do not adjust reversal pair of tax distributions
    ELSIF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag, 'N') = 'N' AND
          NVL(p_rec_nrec_dist_tbl(i).reverse_flag, 'N') = 'N'  THEN

      -- Accumulate l_rnd_total_nrec_tax_amt
      --
      l_rnd_total_nrec_tax_amt := l_rnd_total_nrec_tax_amt +
                                       p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;

      -- Accumulate rounding diffrence of non-recoverable tax dists
      --
      l_nrec_tax_rnd_diff := l_nrec_tax_rnd_diff +
           p_rec_nrec_dist_tbl(i).unrounded_rec_nrec_tax_amt -
                        p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;

      IF p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt <> 0 THEN

        -- Record non-zero non-recoverable tax dists
        --
        l_non_zero_nrec_tax_index := l_non_zero_nrec_tax_index + 1;

        l_non_zero_nrec_tax_dists_tbl(l_non_zero_nrec_tax_index).tbl_index := i;
        l_non_zero_nrec_tax_dists_tbl(l_non_zero_nrec_tax_index).tbl_amt :=
                                        p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;

        -- Record the largest rec_nrec_tax_amt of non-zero non-recoverable tax
        -- dists
        --
        IF ABS(p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt) >= ABS(l_nrec_amt_largest)
        THEN
          l_max_nrec_tax_index := i;
          l_nrec_amt_largest := p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;
        END IF;
      END IF;
    END IF;      -- recoverable_flag

  END LOOP;

  -- round l_rec_tax_rnd_diff
  --
  l_rec_tax_rnd_diff := ZX_TDS_TAX_ROUNDING_PKG.round_tax(
		l_rec_tax_rnd_diff,
		p_rec_nrec_dist_tbl(p_rnd_begin_index).Rounding_Rule_Code,
		p_rec_nrec_dist_tbl(p_rnd_begin_index).minimum_accountable_unit,
		p_rec_nrec_dist_tbl(p_rnd_begin_index).precision,
		p_return_status,
		p_error_buffer);

  -- round l_nrec_tax_rnd_diff
  --
  l_nrec_tax_rnd_diff := ZX_TDS_TAX_ROUNDING_PKG.round_tax(
		l_nrec_tax_rnd_diff,
		p_rec_nrec_dist_tbl(p_rnd_begin_index).Rounding_Rule_Code,
		p_rec_nrec_dist_tbl(p_rnd_begin_index).minimum_accountable_unit,
		p_rec_nrec_dist_tbl(p_rnd_begin_index).precision,
		p_return_status,
		p_error_buffer);

  IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
  THEN
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_TAX_ROUNDING_PKG.round_tax()');
      FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.END',
                    'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(-)'||p_return_status);
    END IF;
    RETURN;
   END IF;

  IF l_rec_tax_rnd_diff <> 0 THEN

    -- calculate minimum accountable unit if it is not available
    --
    l_precision := p_rec_nrec_dist_tbl(p_rnd_begin_index).precision;
    l_min_acct_unit :=
          NVL(p_rec_nrec_dist_tbl(p_rnd_begin_index).minimum_accountable_unit,
              POWER(10,l_precision*(-1)));

    -- Adjust l_rec_tax_rnd_diff to recoverable tax dists first. If no
    -- non-zero recoverable tax dists exist, adjust rounding_diff to
    -- nonrecoverable tax dists.
    --
    IF l_non_zero_rec_tax_dists_tbl.COUNT > 0 THEN
      -- sort l_non_zero_rec_tax_dists_tbl
      --
      sort_tbl_amt_desc (
     		p_index_amt_tbl    => l_non_zero_rec_tax_dists_tbl,
     		p_return_status    => p_return_status,
     		p_error_buffer     => p_error_buffer);

      IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
      THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                        'Incorrect return_status after calling ' ||
                        'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc()');
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.END',
                        'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(-)'||p_return_status);
        END IF;
        RETURN;
      END IF;

      -- set the sort flag for l_non_zero_rec_tax_dists_tbl
      --
      l_rec_tax_dists_tbl_sort_flg := 'Y';

      -- distribute rounding difference
      --
      ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff (
           p_index_amt_tbl => l_non_zero_rec_tax_dists_tbl,
           p_rounding_diff => l_rec_tax_rnd_diff,
 	   p_min_acct_unit => l_min_acct_unit,
 	   p_return_status => p_return_status,
 	   p_error_buffer  => p_error_buffer);

      IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
      THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                 'Incorrect return_status after calling ' ||
                 'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff()');
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.END',
                        'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(-)'||p_return_status);
        END IF;
        RETURN;
      END IF;

      -- update the amount of other currency in p_rec_nrec_dist_tbl
      --
      FOR i IN l_non_zero_rec_tax_dists_tbl.FIRST ..
                                     l_non_zero_rec_tax_dists_tbl.LAST  LOOP
        l_index := l_non_zero_rec_tax_dists_tbl(i).tbl_index;
        p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt :=
                                      l_non_zero_rec_tax_dists_tbl(i).tbl_amt;
      END LOOP;

    ELSIF l_non_zero_nrec_tax_dists_tbl.COUNT > 0 THEN

      -- sort l_non_zero_nrec_tax_dists_tbl
      --
      sort_tbl_amt_desc (
     		p_index_amt_tbl    => l_non_zero_nrec_tax_dists_tbl,
     		p_return_status    => p_return_status,
     		p_error_buffer     => p_error_buffer);

      IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
      THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                        'Incorrect return_status after calling ' ||
                        'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc()');
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.END',
                        'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(-)'||p_return_status);
        END IF;
        RETURN;
      END IF;

      -- set the sort flag for l_non_zero_nrec_tax_dists_tbl
      --
      l_nrec_tax_dists_tbl_sort_flg := 'Y';

      -- distribute rounding difference
      --
      ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff (
         	l_non_zero_nrec_tax_dists_tbl,
         	l_rec_tax_rnd_diff,
 	 	l_min_acct_unit,
 	 	p_return_status,
 	 	p_error_buffer);

      IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
      THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                 'Incorrect return_status after calling ' ||
                 'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff()');
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.END',
                        'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(-)');
        END IF;
        RETURN;
      END IF;

      -- update the amount of other currency in p_rec_nrec_dist_tbl
      --
      FOR i IN l_non_zero_nrec_tax_dists_tbl.FIRST ..
                                       l_non_zero_nrec_tax_dists_tbl.LAST  LOOP
        l_index := l_non_zero_nrec_tax_dists_tbl(i).tbl_index;
        p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt :=
                                       l_non_zero_nrec_tax_dists_tbl(i).tbl_amt;
      END LOOP;
    END IF;

  END IF;      -- l_rec_tax_rnd_diff <> 0

  IF l_nrec_tax_rnd_diff <> 0 THEN

    -- calculate minimum accountable unit if it is not available
    --
    l_precision := p_rec_nrec_dist_tbl(p_rnd_begin_index).precision;
    l_min_acct_unit :=
          NVL(p_rec_nrec_dist_tbl(p_rnd_begin_index).minimum_accountable_unit,
              POWER(10,l_precision*(-1)));

    -- Adjust rounding_diff to nonrecoverable tax dists first. if there is no
    -- non-zero nonrecoverable tax dists, adjust rounding_diff to recoverable
    -- tax dists.
    --
    IF l_non_zero_nrec_tax_dists_tbl.COUNT > 0 THEN

      IF NVL(l_nrec_tax_dists_tbl_sort_flg, 'N') <> 'Y' THEN
        -- sort l_non_zero_nrec_tax_dists_tbl
        --
        sort_tbl_amt_desc (
	       	p_index_amt_tbl    => l_non_zero_nrec_tax_dists_tbl,
       		p_return_status    => p_return_status,
       		p_error_buffer     => p_error_buffer);

        IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                          'Incorrect return_status after calling ' ||
                          'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(-)');
          END IF;
          RETURN;
        END IF;

        -- set the sort flag for l_non_zero_nrec_tax_dists_tbl
        --
        l_nrec_tax_dists_tbl_sort_flg := 'Y';

      END IF;      -- l_nrec_tax_dists_tbl_sort_flg <> 'Y'

      -- distribute rounding difference
      --
      ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff (
 	     l_non_zero_nrec_tax_dists_tbl,
 	     l_nrec_tax_rnd_diff,
 	     l_min_acct_unit,
 	     p_return_status,
 	     p_error_buffer);

      IF NVL(p_return_status,FND_API.G_RET_STS_ERROR)<>FND_API.G_RET_STS_SUCCESS
      THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                  'Incorrect return_status after calling ' ||
                  'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff()');
          FND_LOG.STRING(g_level_error,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(-)');
        END IF;
        RETURN;
      END IF;

      -- update the amount of other currency in p_rec_nrec_dist_tbl
      --
      FOR i IN l_non_zero_nrec_tax_dists_tbl.FIRST ..
                                        l_non_zero_nrec_tax_dists_tbl.LAST  LOOP
        l_index := l_non_zero_nrec_tax_dists_tbl(i).tbl_index;
        p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt :=
                                       l_non_zero_nrec_tax_dists_tbl(i).tbl_amt;
      END LOOP;

    ELSIF l_non_zero_rec_tax_dists_tbl.COUNT > 0 THEN

      IF NVL(l_rec_tax_dists_tbl_sort_flg, 'N') <> 'Y' THEN
        -- sort l_non_zero_nrec_tax_dists_tbl
        --
        sort_tbl_amt_desc (
		p_index_amt_tbl    => l_non_zero_rec_tax_dists_tbl,
		p_return_status    => p_return_status,
		p_error_buffer     => p_error_buffer);

        IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                          'Incorrect return_status after calling ' ||
                          'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(-)');
          END IF;
          RETURN;
        END IF;

        -- set the sort flag for l_non_zero_rec_tax_dists_tbl
        --
        l_rec_tax_dists_tbl_sort_flg := 'Y';

      END IF;      -- l_nrec_tax_dists_tbl_sort_flg <> 'Y'

      -- distribute rounding difference
      --
      ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff (
 	 l_non_zero_rec_tax_dists_tbl,
 	 l_nrec_tax_rnd_diff,
 	 l_min_acct_unit,
 	 p_return_status,
 	 p_error_buffer);

      IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
      THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                  'Incorrect return_status after calling ' ||
                  'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff()');
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.END',
                        'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(-)'||p_return_status);
        END IF;
        RETURN;
      END IF;

      -- update the amount of other currency in p_rec_nrec_dist_tbl
      --
      FOR i IN l_non_zero_rec_tax_dists_tbl.FIRST ..
                                       l_non_zero_rec_tax_dists_tbl.LAST  LOOP
        l_index := l_non_zero_rec_tax_dists_tbl(i).tbl_index;
        p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt :=
                                       l_non_zero_rec_tax_dists_tbl(i).tbl_amt;
      END LOOP;
    END IF;
  END IF;      -- l_nrec_tax_rnd_diff <> 0

  -- check rounding difference between tax line in zx_lines and
  -- the tax distributions in zx_rec_nrec_tax_dist with the same
  -- tax_line_id.
  --
  IF p_tax_line_amt IS NOT NULL THEN
    -- calculate rounding difference for tax line amount
    --
    l_tax_line_rnd_diff := p_tax_line_amt -
                        (( l_rnd_total_rec_tax_amt + l_rec_tax_rnd_diff ) +
                        (l_rnd_total_nrec_tax_amt + l_nrec_tax_rnd_diff));


    --IF l_tax_line_rnd_diff < 0 THEN

      -- Adjust rounding difference to the largest recoverable tax dists first.
      -- If there is no recoverable tax dists, adjust rounding
      -- difference to the largest nonrecoverable tax dists.
      --
      --IF l_max_rec_tax_index IS NOT NULL THEN

        --p_rec_nrec_dist_tbl(l_max_rec_tax_index).rec_nrec_tax_amt :=
          --p_rec_nrec_dist_tbl(l_max_rec_tax_index).rec_nrec_tax_amt + l_tax_line_rnd_diff;

      --ELSIF l_max_nrec_tax_index IS NOT NULL THEN

        --p_rec_nrec_dist_tbl(l_max_nrec_tax_index).rec_nrec_tax_amt :=
          --p_rec_nrec_dist_tbl(l_max_nrec_tax_index).rec_nrec_tax_amt + l_tax_line_rnd_diff;

      --END IF;

    --ELSIF l_tax_line_rnd_diff > 0 THEN

      -- Adjust rounding_diff to the largest nonrecoverable tax dists first.
      -- if there is no nonrecoverable tax dists, adjust rounding_diff to the
      -- largest recoverable tax dists.
      --
      --IF l_max_nrec_tax_index IS NOT NULL THEN

        --p_rec_nrec_dist_tbl(l_max_nrec_tax_index).rec_nrec_tax_amt :=
          --p_rec_nrec_dist_tbl(l_max_nrec_tax_index).rec_nrec_tax_amt + l_tax_line_rnd_diff;

      --ELSIF l_max_rec_tax_index IS NOT NULL THEN

        --p_rec_nrec_dist_tbl(l_max_rec_tax_index).rec_nrec_tax_amt :=
          --p_rec_nrec_dist_tbl(l_max_rec_tax_index).rec_nrec_tax_amt + l_tax_line_rnd_diff;

      --END IF;
    --END IF;   -- l_tax_line_rnd_diff > 0 OR < 0

    IF p_rec_nrec_dist_tbl(p_rnd_begin_index).Rounding_Rule_Code = 'UP' THEN

      -- When rounding rule code is UP
      -- Adjust rounding difference to the largest non-recoverable tax dists first.
      -- If there is no recoverable tax dists, adjust rounding
      -- difference to the largest recoverable tax dists.
      --
      IF l_max_nrec_tax_index IS NOT NULL THEN

        p_rec_nrec_dist_tbl(l_max_nrec_tax_index).rec_nrec_tax_amt :=
          p_rec_nrec_dist_tbl(l_max_nrec_tax_index).rec_nrec_tax_amt + l_tax_line_rnd_diff;

      ELSIF l_max_rec_tax_index IS NOT NULL THEN

        p_rec_nrec_dist_tbl(l_max_rec_tax_index).rec_nrec_tax_amt :=
          p_rec_nrec_dist_tbl(l_max_rec_tax_index).rec_nrec_tax_amt + l_tax_line_rnd_diff;

      END IF;

    ELSIF p_rec_nrec_dist_tbl(p_rnd_begin_index).Rounding_Rule_Code = 'DOWN' THEN

      -- When rounding rule code is DOWN
      -- Adjust rounding difference to the largest recoverable tax dists first.
      -- If there is no non-recoverable tax dists, adjust rounding
      -- difference to the largest recoverable tax dists.
      --
      IF l_max_rec_tax_index IS NOT NULL THEN

        p_rec_nrec_dist_tbl(l_max_rec_tax_index).rec_nrec_tax_amt :=
          p_rec_nrec_dist_tbl(l_max_rec_tax_index).rec_nrec_tax_amt + l_tax_line_rnd_diff;

      ELSIF l_max_nrec_tax_index IS NOT NULL THEN

        p_rec_nrec_dist_tbl(l_max_nrec_tax_index).rec_nrec_tax_amt :=
          p_rec_nrec_dist_tbl(l_max_nrec_tax_index).rec_nrec_tax_amt + l_tax_line_rnd_diff;

      END IF;

    ELSIF p_rec_nrec_dist_tbl(p_rnd_begin_index).Rounding_Rule_Code = 'NEAREST' THEN

      IF p_rec_nrec_dist_tbl(p_rnd_begin_index).Minimum_Accountable_unit IS NOT NULL THEN

        -- When rounding rule code is NEAREST
        -- Adjust rounding difference to the largest non-recoverable tax dists first.
        -- for 0.5 and above
        -- If there is no recoverable tax dists, adjust rounding
        -- difference to the largest recoverable tax dists.
        --

        IF ABS(l_tax_line_rnd_diff)/p_rec_nrec_dist_tbl(p_rnd_begin_index).Minimum_Accountable_unit >= 5 THEN
          l_round_nrec_flag := 'Y';
        ELSE
          l_round_nrec_flag := 'N';
        END IF;
      ELSE

        -- When rounding rule code is NEAREST
        -- Adjust rounding difference to the largest recoverable tax dists first.
        -- for below 0.5
        -- If there is no non-recoverable tax dists, adjust rounding
        -- difference to the largest recoverable tax dists.
        --

        IF ABS(l_tax_line_rnd_diff)/ POWER(10, (-1) * p_rec_nrec_dist_tbl(p_rnd_begin_index).precision) >= 5 THEN
          l_round_nrec_flag := 'Y';
        ELSE
          l_round_nrec_flag := 'N';
        END IF;
      END IF;
      IF l_round_nrec_flag = 'N' THEN
        IF l_max_rec_tax_index IS NOT NULL THEN

          p_rec_nrec_dist_tbl(l_max_rec_tax_index).rec_nrec_tax_amt :=
            p_rec_nrec_dist_tbl(l_max_rec_tax_index).rec_nrec_tax_amt + l_tax_line_rnd_diff;

        ELSIF l_max_nrec_tax_index IS NOT NULL THEN

          p_rec_nrec_dist_tbl(l_max_nrec_tax_index).rec_nrec_tax_amt :=
            p_rec_nrec_dist_tbl(l_max_nrec_tax_index).rec_nrec_tax_amt + l_tax_line_rnd_diff;

        END IF;
      ELSE
        IF l_max_nrec_tax_index IS NOT NULL THEN

          p_rec_nrec_dist_tbl(l_max_nrec_tax_index).rec_nrec_tax_amt :=
            p_rec_nrec_dist_tbl(l_max_nrec_tax_index).rec_nrec_tax_amt + l_tax_line_rnd_diff;

        ELSIF l_max_rec_tax_index IS NOT NULL THEN

        p_rec_nrec_dist_tbl(l_max_rec_tax_index).rec_nrec_tax_amt :=
          p_rec_nrec_dist_tbl(l_max_rec_tax_index).rec_nrec_tax_amt + l_tax_line_rnd_diff;

        END IF;
      END IF;
    END IF;   -- Rounding_Rule_Code up, down, nearest
  END IF;     -- p_tax_line_amt IS NOT NULL

   IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(-)'||p_return_status);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr',
                     p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr.END',
                    'ZX_TRD_INTERNAL_SERVICES_PVT.round_tax_dists_trx_curr(-)');
      END IF;

END round_tax_dists_trx_curr;

PROCEDURE convert_tax_dists (
 p_rec_nrec_dist_tbl IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index          IN            NUMBER,
 p_rnd_end_index            IN            NUMBER,
 p_tax_line_amt_tax_curr    IN            NUMBER,
 p_tax_line_amt_funcl_curr  IN            NUMBER,
 p_return_status            OUT NOCOPY    VARCHAR2,
 p_error_buffer             OUT NOCOPY    VARCHAR2) IS

 l_non_zero_rec_tax_dists_tbl 	     index_amt_tbl_type;
 l_non_zero_nrec_tax_dists_tbl 	     index_amt_tbl_type;

 l_rec_tax_dists_tbl_sort_flg 	     VARCHAR2(1);
 l_nrec_tax_dists_tbl_sort_flg 	     VARCHAR2(1);

 l_non_zero_rec_tax_index	     NUMBER		:= 0;
 l_non_zero_nrec_tax_index	     NUMBER		:= 0;

 l_total_rec_tax_amt_trx_curr	     NUMBER		:= 0;
 l_total_nrec_tax_amt_trx_curr       NUMBER		:= 0;

 l_sum_of_rnd_rec_tax_amt	     NUMBER		:= 0;
 l_sum_of_rnd_nrec_tax_amt	     NUMBER		:= 0;

 l_total_unrnd_rec_tax_amt           NUMBER		:= 0;
 l_total_unrnd_nrec_tax_amt          NUMBER		:= 0;
 l_rnd_total_rec_tax_amt  	     NUMBER		:= 0;
 l_rnd_total_nrec_tax_amt            NUMBER		:= 0;

 l_rec_tax_rnd_diff_tax_curr	     NUMBER;
 l_nrec_tax_rnd_diff_tax_curr	     NUMBER;
 l_rec_tax_rnd_diff_funcl_curr	     NUMBER;
 l_nrec_tax_rnd_diff_funcl_curr	     NUMBER;

 l_tax_line_rnd_diff_tax_curr	     NUMBER;
 l_tax_line_rnd_diff_funcl_curr	     NUMBER;

 l_min_acct_unit_tax_curr      	     zx_taxes_b.minimum_accountable_unit%TYPE;
 l_precision_tax_curr          	     zx_taxes_b.tax_precision%TYPE;
-- l_rounding_rule_tax_curr	     zx_taxes_b.Rounding_Rule_Code%TYPE;
 l_min_acct_unit_funcl_curr    	     zx_taxes_b.minimum_accountable_unit%TYPE;
 l_precision_funcl_curr        	     zx_taxes_b.tax_precision%TYPE;
 l_funcl_currency_code	     	     fnd_currencies.currency_code%TYPE;
 l_ledger_id		             gl_sets_of_books.set_of_books_id%TYPE;

 l_index			     NUMBER;
 l_tax_id			     zx_taxes_b.tax_id%TYPE;



BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;

  IF p_rnd_begin_index IS NULL OR p_rnd_end_index IS NULL OR
                                  p_rnd_begin_index > p_rnd_end_index THEN

    --p_return_status:= FND_API.G_RET_STS_ERROR;
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                     'begin or end index is null, or begin index > end index');
    END IF;
    RETURN;
  END IF;

  -- /******** START OF CONVERSION AND ROUNDING FOR TAX CURRENCY ********/
  --
  IF p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_currency_code =
                   p_rec_nrec_dist_tbl(p_rnd_begin_index).trx_currency_code THEN

    -- if tax_currency_code is the same as the trx currency_code, it is not
    -- necessary to convert tax amount and taxable amount to tax currency.
    -- Set the following amounts: taxable_amt_tax_curr = taxable_amt (rounded)
    -- and rec_nrec_tax_amt_tax_curr = rec_nrec_tax_amt(rounded)
    --
    FOR i IN p_rnd_begin_index .. p_rnd_end_index LOOP
      p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_tax_curr :=
                        p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;
      p_rec_nrec_dist_tbl(i).taxable_amt_tax_curr :=
                             p_rec_nrec_dist_tbl(i).taxable_amt;
    END LOOP;
  ELSE

    IF p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_currency_code IS NULL THEN
        p_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                       'Tax currency code is NULL');
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                       'p_return_status = ' || p_return_status);
      END IF;
      RETURN;
    END IF;

    -- get l_min_acct_unit_tax_curr l_precision_tax_curr and
    -- l_rounding_rule_tax_curr
    --
    l_tax_id := p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_id;
    ZX_TDS_UTILITIES_PKG.populate_tax_cache (
    				p_tax_id	 => l_tax_id,
    				p_return_status  => p_return_status,
    				p_error_buffer   => p_error_buffer);
    l_precision_tax_curr :=
            ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).tax_precision;
    l_min_acct_unit_tax_curr :=
      NVL(ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).minimum_accountable_unit,
          POWER(10,l_precision_tax_curr*(-1)));

--    l_rounding_rule_tax_curr :=
--                      ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).rounding_rule_code;

    FOR i IN p_rnd_begin_index .. p_rnd_end_index LOOP

      IF NVL(p_rec_nrec_dist_tbl(i).reverse_flag,'N') = 'N' THEN
        -- If rec_nrec_tax_amt is zero, set rec_nrec_tax_amt_tax_curr to zero.
        -- Otherwise, convert rec_nrec_tax_amt to tax currency with
        -- unrounded_rec_nrec_tax_amt.
        --
        IF p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt = 0 THEN

          p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_tax_curr := 0;
          p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_funcl_curr := 0;

        ELSE
          -- convert tax dist amount to rec_nrec_tax_amt_tax_curr
          --
          ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency(
               p_rec_nrec_dist_tbl(i).trx_currency_code,
               p_rec_nrec_dist_tbl(i).tax_currency_code,
               p_rec_nrec_dist_tbl(i).tax_currency_conversion_date,
               p_rec_nrec_dist_tbl(i).tax_currency_conversion_type,
               p_rec_nrec_dist_tbl(i).currency_conversion_type,
               p_rec_nrec_dist_tbl(i).tax_currency_conversion_rate,
               p_rec_nrec_dist_tbl(i).unrounded_rec_nrec_tax_amt,   -- IN  param
               p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_tax_curr,    -- OUT param
               p_return_status,
               p_error_buffer,
               p_rec_nrec_dist_tbl(i).currency_conversion_date);  --Bug7183884

          IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
          THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                            'Incorrect return_status after calling ' ||
                            'ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency()');
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                            'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)');
            END IF;
            RETURN;
          END IF;

          -- round the converted tax dist amount in tax currency
          --
          p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_tax_curr :=
          	 		ZX_TDS_TAX_ROUNDING_PKG.round_tax(
    				p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_tax_curr,
    				p_rec_nrec_dist_tbl(i).Rounding_Rule_Code,
    				l_min_acct_unit_tax_curr,
    				l_precision_tax_curr,
    				p_return_status,
    				p_error_buffer);

          IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
          THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                            'Incorrect return_status after calling ' ||
                            'ZX_TDS_TAX_ROUNDING_PKG.round_tax()');
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                            'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)');
            END IF;
            RETURN;
          END IF;

          IF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag, 'N') = 'N' THEN

            -- Accumulate tax amount of converted non-recoverable tax dists
            --
            l_sum_of_rnd_nrec_tax_amt := l_sum_of_rnd_nrec_tax_amt +
                              p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_tax_curr;

            -- Record the non-zero non-recoverable tax dists
            --
            l_non_zero_nrec_tax_index := l_non_zero_nrec_tax_index + 1;

            l_non_zero_nrec_tax_dists_tbl(l_non_zero_nrec_tax_index).tbl_index := i;
             l_non_zero_nrec_tax_dists_tbl(
                       l_non_zero_nrec_tax_index).tbl_amt :=
                            p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_tax_curr;


          ELSIF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag, 'N') = 'Y' THEN

            -- Accumulate amount of converted recoverable tax dists
            --
            l_sum_of_rnd_rec_tax_amt := l_sum_of_rnd_rec_tax_amt +
                               p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_tax_curr;

            -- Record the non-zero recoverable tax dists
            --
            l_non_zero_rec_tax_index := l_non_zero_rec_tax_index + 1;

            l_non_zero_rec_tax_dists_tbl(l_non_zero_rec_tax_index).tbl_index := i;
            l_non_zero_rec_tax_dists_tbl(
                       l_non_zero_rec_tax_index).tbl_amt :=
                                 p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_tax_curr;

          END IF;      -- recoverable_flag
        END IF;        -- rec_nrec_tax_amt = 0 OR <> 0

        IF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag, 'N') = 'N' THEN

          -- Accumulate rounded non-recoverable tax amount(not converted)
          --
          l_total_nrec_tax_amt_trx_curr := l_total_nrec_tax_amt_trx_curr +
                                       p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;

          -- Accumulate unrounded non-recoverable tax amount(not converted)
          --
          l_total_unrnd_nrec_tax_amt := l_total_unrnd_nrec_tax_amt +
                              p_rec_nrec_dist_tbl(i).unrounded_rec_nrec_tax_amt;

        ELSIF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag, 'N') = 'Y' THEN

          -- Accumulate rounded recoverable tax amount(not converted)
          --
          l_total_rec_tax_amt_trx_curr := l_total_rec_tax_amt_trx_curr +
                                       p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;

          -- Accumulate unrounded recoverable tax amount(not converted)
          --
          l_total_unrnd_rec_tax_amt := l_total_unrnd_rec_tax_amt +
                              p_rec_nrec_dist_tbl(i).unrounded_rec_nrec_tax_amt;
        END IF;
      END IF;      -- NVL(p_rec_nrec_dist_tbl(i).reverse_flag,'N') = 'N'
    END LOOP;      -- i IN p_rnd_begin_index .. p_rnd_end_index

    -- convert l_total_unrnd_nrec_tax_amt to tax currency
    --
    ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency(
  	p_rec_nrec_dist_tbl(p_rnd_begin_index).trx_currency_code,
  	p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_currency_code,
  	p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_currency_conversion_date,
  	p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_currency_conversion_type,
        p_rec_nrec_dist_tbl(p_rnd_begin_index).currency_conversion_type,
  	p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_currency_conversion_rate,
  	l_total_unrnd_nrec_tax_amt,    			    -- IN  param
  	l_rnd_total_nrec_tax_amt,     		            -- OUT param
  	p_return_status,
  	p_error_buffer,
    p_rec_nrec_dist_tbl(p_rnd_begin_index).currency_conversion_date);--Bug7183884

    -- convert l_total_unrnd_rec_tax_amt in tax currency
    --
    ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency(
  	p_rec_nrec_dist_tbl(p_rnd_begin_index).trx_currency_code,
  	p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_currency_code,
  	p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_currency_conversion_date,
  	p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_currency_conversion_type,
        p_rec_nrec_dist_tbl(p_rnd_begin_index).currency_conversion_type,
  	p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_currency_conversion_rate,
  	l_total_unrnd_rec_tax_amt,    			    -- IN  param
  	l_rnd_total_rec_tax_amt,     		            -- OUT param
  	p_return_status,
  	p_error_buffer,
    p_rec_nrec_dist_tbl(p_rnd_begin_index).currency_conversion_date); --Bug7183884

    IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency()');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                      'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)');
      END IF;
      RETURN;
    END IF;

    -- round the converted l_rnd_total_nrec_tax_amt
    --
    l_rnd_total_nrec_tax_amt := ZX_TDS_TAX_ROUNDING_PKG.round_tax(
  			l_rnd_total_nrec_tax_amt,
  			p_rec_nrec_dist_tbl(p_rnd_begin_index).Rounding_Rule_Code,
  			l_min_acct_unit_tax_curr,
  			l_precision_tax_curr,
  			p_return_status,
  			p_error_buffer);

    -- round the converted l_rnd_total_rec_tax_amt
    --
    l_rnd_total_rec_tax_amt := ZX_TDS_TAX_ROUNDING_PKG.round_tax(
  			l_rnd_total_rec_tax_amt,
  			p_rec_nrec_dist_tbl(p_rnd_begin_index).Rounding_Rule_Code,
  			l_min_acct_unit_tax_curr,
  			l_precision_tax_curr,
  			p_return_status,
  			p_error_buffer);

    IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_TAX_ROUNDING_PKG.round_tax()');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                      'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)');
      END IF;
      RETURN;
     END IF;


    -- calculate rounding difference in tax currency for recoverable and
    -- non-recoverable tax distributions
    --
    l_rec_tax_rnd_diff_tax_curr := l_rnd_total_rec_tax_amt -
                                                       l_sum_of_rnd_rec_tax_amt;
    l_nrec_tax_rnd_diff_tax_curr :=l_rnd_total_nrec_tax_amt -
                                                      l_sum_of_rnd_nrec_tax_amt;

    IF l_rec_tax_rnd_diff_tax_curr <> 0 THEN

      -- Adjust rounding_diff to recoverable tax dists first. If there is no
      -- non-zero recoverable tax dists, adjust rounding_diff to nonrecoverable
      -- tax dists.
      --
      IF l_non_zero_rec_tax_dists_tbl.COUNT > 0 THEN

        -- sort l_non_zero_rec_tax_dists_tbl
        --
        ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc (
       		p_index_amt_tbl    => l_non_zero_rec_tax_dists_tbl,
       		p_return_status    => p_return_status,
       		p_error_buffer     => p_error_buffer);

        IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'Incorrect return_status after calling ' ||
                          'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)');
          END IF;
          RETURN;
        END IF;

        -- set the sort flag for l_non_zero_rec_tax_dists_tbl
        --
        l_rec_tax_dists_tbl_sort_flg := 'Y';

        -- distribute rounding difference
        --
        ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff (
   		p_index_amt_tbl => l_non_zero_rec_tax_dists_tbl,
   		p_rounding_diff => l_rec_tax_rnd_diff_tax_curr,
   		p_min_acct_unit => l_min_acct_unit_tax_curr,
   		p_return_status => p_return_status,
   		p_error_buffer  => p_error_buffer);

        IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                   'Incorrect return_status after calling ' ||
                   'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||p_return_status);
          END IF;
          RETURN;
        END IF;

        -- update rec_nrec_tax_amt_tax_curr
        --
        FOR i IN l_non_zero_rec_tax_dists_tbl.FIRST ..
                                       l_non_zero_rec_tax_dists_tbl.LAST  LOOP
          l_index := l_non_zero_rec_tax_dists_tbl(i).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_tax_curr :=
                                        l_non_zero_rec_tax_dists_tbl(i).tbl_amt;
        END LOOP;

      ELSIF l_non_zero_nrec_tax_dists_tbl.COUNT > 0 THEN

        -- sort l_non_zero_nrec_tax_dists_tbl
        --
        ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc (
       		p_index_amt_tbl    => l_non_zero_nrec_tax_dists_tbl,
       		p_return_status    => p_return_status,
       		p_error_buffer     => p_error_buffer);

        IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'Incorrect return_status after calling ' ||
                          'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||p_return_status);
          END IF;
          RETURN;
        END IF;

        -- set the sort flag for l_non_zero_nrec_tax_dists_tbl
        --
        l_nrec_tax_dists_tbl_sort_flg := 'Y';

        -- distribute rounding difference
        --
        ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff (
   		p_index_amt_tbl => l_non_zero_nrec_tax_dists_tbl,
   		p_rounding_diff => l_rec_tax_rnd_diff_tax_curr,
   		p_min_acct_unit => l_min_acct_unit_tax_curr,
   		p_return_status => p_return_status,
   		p_error_buffer  => p_error_buffer);

        IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                   'Incorrect return_status after calling ' ||
                   'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||p_return_status);
          END IF;
          RETURN;
        END IF;

        -- update rec_nrec_tax_amt_tax_curr
        --
        FOR i IN l_non_zero_nrec_tax_dists_tbl.FIRST ..
                                         l_non_zero_nrec_tax_dists_tbl.LAST  LOOP
          l_index := l_non_zero_nrec_tax_dists_tbl(i).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_tax_curr :=
                                         l_non_zero_nrec_tax_dists_tbl(i).tbl_amt;
        END LOOP;
      END IF;

    END IF;      -- l_rec_tax_rnd_diff_tax_curr <> 0

    IF l_nrec_tax_rnd_diff_tax_curr <> 0 THEN

      -- Adjust rounding_diff to nonrecoverable tax dists first. if there is no
      -- non-zero nonrecoverable tax dists, adjust rounding_diff to recoverable
      -- tax dists.
      --
      IF l_non_zero_nrec_tax_dists_tbl.COUNT > 0 THEN

        IF NVL(l_nrec_tax_dists_tbl_sort_flg, 'N') <> 'Y' THEN
          -- sort l_non_zero_nrec_tax_dists_tbl
          --
          ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc (
         		p_index_amt_tbl    => l_non_zero_nrec_tax_dists_tbl,
         		p_return_status    => p_return_status,
         		p_error_buffer     => p_error_buffer);

          IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
          THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                            'Incorrect return_status after calling ' ||
                            'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc()');
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                            'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)');
            END IF;
            RETURN;
          END IF;

          -- set the sort flag for l_non_zero_nrec_tax_dists_tbl
          --
          l_nrec_tax_dists_tbl_sort_flg := 'Y';

        END IF;      -- l_nrec_tax_dists_tbl_sort_flg <> 'Y'

        -- distribute rounding difference
        --
        ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff (
   		p_index_amt_tbl => l_non_zero_nrec_tax_dists_tbl,
   		p_rounding_diff => l_nrec_tax_rnd_diff_tax_curr,
   		p_min_acct_unit => l_min_acct_unit_tax_curr,
   		p_return_status => p_return_status,
   		p_error_buffer  => p_error_buffer);

        IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                    'Incorrect return_status after calling ' ||
                    'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||p_return_status);
          END IF;
          RETURN;
        END IF;

        -- update rec_nrec_tax_amt_tax_curr
        --
        FOR i IN l_non_zero_nrec_tax_dists_tbl.FIRST ..
                                          l_non_zero_nrec_tax_dists_tbl.LAST  LOOP
          l_index := l_non_zero_nrec_tax_dists_tbl(i).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_tax_curr :=
                                         l_non_zero_nrec_tax_dists_tbl(i).tbl_amt;
        END LOOP;

      ELSIF l_non_zero_rec_tax_dists_tbl.COUNT > 0 THEN

        IF NVL(l_rec_tax_dists_tbl_sort_flg, 'N') <> 'Y' THEN
          -- sort l_non_zero_nrec_tax_dists_tbl
          --
          ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc (
         		p_index_amt_tbl    => l_non_zero_rec_tax_dists_tbl,
         		p_return_status    => p_return_status,
         		p_error_buffer     => p_error_buffer);

          IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
          THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                            'Incorrect return_status after calling ' ||
                            'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc()');
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                            'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||p_return_status);
            END IF;
            RETURN;
          END IF;

          -- set the sort flag for l_non_zero_rec_tax_dists_tbl
          --
          l_rec_tax_dists_tbl_sort_flg := 'Y';

        END IF;      -- l_nrec_tax_dists_tbl_sort_flg <> 'Y'

        -- distribute rounding difference
        --
        ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff (
   		p_index_amt_tbl => l_non_zero_rec_tax_dists_tbl,
   		p_rounding_diff => l_nrec_tax_rnd_diff_tax_curr,
   		p_min_acct_unit => l_min_acct_unit_tax_curr,
   		p_return_status => p_return_status,
   		p_error_buffer  => p_error_buffer);

        IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                    'Incorrect return_status after calling ' ||
                    'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||p_return_status);
          END IF;
          RETURN;
        END IF;

        -- update rec_nrec_tax_amt_tax_curr
        --
        FOR i IN l_non_zero_rec_tax_dists_tbl.FIRST ..
                                         l_non_zero_rec_tax_dists_tbl.LAST  LOOP
          l_index := l_non_zero_rec_tax_dists_tbl(i).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_tax_curr :=
                                         l_non_zero_rec_tax_dists_tbl(i).tbl_amt;
        END LOOP;
      END IF;
    END IF;      -- l_nrec_tax_rnd_diff_tax_curr <> 0

    -- check rounding difference between tax line in zx_lines and
    -- the tax distributions in zx_rec_nrec_tax_dist with the same
    -- tax_line_id.
    --
    IF p_tax_line_amt_tax_curr IS NOT NULL THEN
      -- calculate rounding difference for tax line amount
      --
      l_tax_line_rnd_diff_tax_curr := p_tax_line_amt_tax_curr -
                          (l_rnd_total_rec_tax_amt + l_rnd_total_nrec_tax_amt);

      IF l_tax_line_rnd_diff_tax_curr > 0 THEN

        -- Adjust this rounding difference to the largest non-zero
        -- non-recoverabletax distribution (check first), or adjust it to
        -- the largest non-zero recoverable tax distribution.
        --
        IF l_non_zero_nrec_tax_dists_tbl.COUNT > 0 THEN

          l_index := l_non_zero_nrec_tax_dists_tbl(
                                     l_non_zero_nrec_tax_dists_tbl.FIRST).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_tax_curr :=
                  p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_tax_curr +
                                                     l_tax_line_rnd_diff_tax_curr;


        ELSIF l_non_zero_rec_tax_dists_tbl.COUNT > 0 THEN

          l_index := l_non_zero_rec_tax_dists_tbl(
                                     l_non_zero_rec_tax_dists_tbl.FIRST).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_tax_curr :=
                  p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_tax_curr +
                                                     l_tax_line_rnd_diff_tax_curr;

        END IF;

      ELSIF l_tax_line_rnd_diff_tax_curr < 0 THEN

        -- Adjust this rounding difference to the largest non-zero
        -- recoverabletax distribution (check first), or adjust it to
        -- the largest non-zero non-recoverable tax distribution.
        --
        IF l_non_zero_rec_tax_dists_tbl.COUNT > 0  THEN

          l_index := l_non_zero_rec_tax_dists_tbl(
                                     l_non_zero_rec_tax_dists_tbl.FIRST).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_tax_curr :=
                  p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_tax_curr +
                                                       l_tax_line_rnd_diff_tax_curr;


        ELSIF  l_non_zero_nrec_tax_dists_tbl.COUNT > 0  THEN

          l_index := l_non_zero_nrec_tax_dists_tbl(
                                     l_non_zero_nrec_tax_dists_tbl.FIRST).tbl_index;

          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_tax_curr :=
                  p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_tax_curr +
                                                       l_tax_line_rnd_diff_tax_curr;

        END IF;
      END IF;   -- l_tax_line_rnd_diff_tax_curr > 0 OR < 0
    END IF;     -- p_tax_line_amt_tax_curr IS NOT NULL


    -- convert taxable amount to tax currency
    --
    FOR i IN p_rnd_begin_index .. p_rnd_end_index LOOP

      IF NVL(p_rec_nrec_dist_tbl(i).reverse_flag,'N') = 'N' THEN

        ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency(
  		p_rec_nrec_dist_tbl(i).trx_currency_code,
  		p_rec_nrec_dist_tbl(i).tax_currency_code,
  		p_rec_nrec_dist_tbl(i).tax_currency_conversion_date,
  		p_rec_nrec_dist_tbl(i).tax_currency_conversion_type,
                p_rec_nrec_dist_tbl(i).currency_conversion_type,
  		p_rec_nrec_dist_tbl(i).tax_currency_conversion_rate,
  		p_rec_nrec_dist_tbl(i).unrounded_taxable_amt,	 -- IN  param
  		p_rec_nrec_dist_tbl(i).taxable_amt_tax_curr,   	 -- OUT param
  		p_return_status,
  		p_error_buffer,
      p_rec_nrec_dist_tbl(i).currency_conversion_date);--Bug7183884

        IF NVL(p_return_status,FND_API.G_RET_STS_ERROR)<>FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'Incorrect return_status after calling ' ||
                          'ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||p_return_status);
          END IF;
          RETURN;
        END IF;

        -- do rounding
        --
        p_rec_nrec_dist_tbl(i).taxable_amt_tax_curr :=
  	      ZX_TDS_TAX_ROUNDING_PKG.round_tax(
  			p_rec_nrec_dist_tbl(i).taxable_amt_tax_curr,
  			p_rec_nrec_dist_tbl(i).Rounding_Rule_Code,
  			l_min_acct_unit_tax_curr,
  			l_precision_tax_curr,
  			p_return_status,
  			p_error_buffer);

        IF NVL(p_return_status,FND_API.G_RET_STS_ERROR)<>FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'Incorrect return_status after calling ' ||
                          'ZX_TDS_TAX_ROUNDING_PKG.round_tax()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||p_return_status);
          END IF;
          RETURN;
        END IF;
      END IF;     -- NVL(p_rec_nrec_dist_tbl(i).reverse_flag,'N') = 'N'
     END LOOP;
  END IF;       -- tax_currency_code <> trx_currency_code
  --
  -- /******** END OF CONVERSION AND ROUNDING FOR TAX CURRENCY ********/


  -- /****** START OF CONVERSION AND ROUNDING FOR FUNCTIONAL CURRENCY ******/
  --
  IF p_rec_nrec_dist_tbl(p_rnd_begin_index).ledger_id IS NOT NULL THEN

    -- initialize some local varialbles and data structures
    --
    l_sum_of_rnd_rec_tax_amt := 0;
    l_sum_of_rnd_nrec_tax_amt := 0;

    l_rnd_total_rec_tax_amt := 0;
    l_rnd_total_nrec_tax_amt := 0;

    -- get l_min_acct_unit and l_precision and l_funcl_currency_code
    --
    l_ledger_id := p_rec_nrec_dist_tbl(p_rnd_begin_index).ledger_id;

    IF NOT ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl.EXISTS(l_ledger_id) THEN

       ZX_TDS_UTILITIES_PKG.populate_currency_cache (
          p_ledger_id      => l_ledger_id,
          p_return_status  => p_return_status,
          p_error_buffer   => p_error_buffer);

      IF NVL(p_return_status,FND_API.G_RET_STS_ERROR)<>FND_API.G_RET_STS_SUCCESS
      THEN
        IF (g_level_error  >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                        'Incorrect return_status after calling ' ||
                        'ZX_TDS_UTILITIES_PKG.populate_currency_cache()');
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                        'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||p_return_status);
        END IF;
        RETURN;
      END IF;
    END IF;

    l_funcl_currency_code := ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl(
                                                  l_ledger_id).currency_code;
    l_precision_funcl_curr := ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl(
                                                       l_ledger_id).precision;
    l_min_acct_unit_funcl_curr :=
      NVL(ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl(
                                        l_ledger_id).minimum_accountable_unit,
          POWER(10,l_precision_funcl_curr*(-1)));

    IF l_funcl_currency_code =
       p_rec_nrec_dist_tbl(p_rnd_begin_index).trx_currency_code  THEN

      -- if l_funcl_currency_code = trx_currency_code, it is not necessary to
      -- convert tax amount and taxable amount to functional currency.
      -- Set the followings: taxable_amt_funcl_curr = taxable_amt(rounded)
      -- and rec_nrec_tax_amt_funcl_curr = rec_nrec_tax_amt(rounded)
      --
      FOR i IN p_rnd_begin_index .. p_rnd_end_index LOOP
        IF NVL(p_rec_nrec_dist_tbl(i).reverse_flag, 'N') = 'N' THEN
          p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_funcl_curr :=
                          p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;
          p_rec_nrec_dist_tbl(i).taxable_amt_funcl_curr :=
                               p_rec_nrec_dist_tbl(i).taxable_amt;
        END IF;

        -- set func_curr_rounding_adjustment = 0
        --
        p_rec_nrec_dist_tbl(i).func_curr_rounding_adjustment := 0;

      END LOOP;

      IF (g_level_procedure >= g_current_runtime_level ) THEN

        FND_LOG.STRING(g_level_procedure,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                      'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||
                      'Functional currency is the same as transaction currency, no conversion is performed');
      END IF;
      RETURN;
    END IF;

    -- l_funcl_currency_code <> trx_currency_code: need to convert tax amount
    -- and taxable amount to functional currency
    --
    IF p_rec_nrec_dist_tbl(p_rnd_begin_index).trx_currency_code =
                 p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_currency_code THEN

      -- trx_currency_code = tax_currency_code: l_non_zero_nrec_tax_dists_tbl
      -- and l_non_zero_rec_tax_dists_tbl etc need to be built here
      --
      l_non_zero_rec_tax_dists_tbl.DELETE;
      l_non_zero_nrec_tax_dists_tbl.DELETE;

      l_non_zero_rec_tax_index := 0;
      l_non_zero_nrec_tax_index:= 0;

      l_total_unrnd_rec_tax_amt := 0;
      l_total_unrnd_nrec_tax_amt := 0;

      l_total_nrec_tax_amt_trx_curr := 0;
      l_total_rec_tax_amt_trx_curr := 0;

      FOR i IN p_rnd_begin_index .. p_rnd_end_index LOOP
        IF NVL(p_rec_nrec_dist_tbl(i).reverse_flag, 'N') = 'N' THEN
          IF p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt = 0 THEN
              p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_funcl_curr := 0;
          ELSE
            IF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag, 'N') = 'N' THEN

              -- Record the non-zero non-recoverable tax dists
              --
              l_non_zero_nrec_tax_index := l_non_zero_nrec_tax_index + 1;

              l_non_zero_nrec_tax_dists_tbl(l_non_zero_nrec_tax_index).tbl_index := i;
--               l_non_zero_nrec_tax_dists_tbl(
--                         l_non_zero_nrec_tax_index).tbl_amt :=
--                              p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_tax_curr;


            ELSIF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag, 'N') = 'Y' THEN

              -- Record the non-zero recoverable tax dists
              --
              l_non_zero_rec_tax_index := l_non_zero_rec_tax_index + 1;

              l_non_zero_rec_tax_dists_tbl(l_non_zero_rec_tax_index).tbl_index := i;
--              l_non_zero_rec_tax_dists_tbl(
--                         l_non_zero_rec_tax_index).tbl_amt :=
--                                   p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt_tax_curr;

            END IF;      -- recoverable_flag = 'N' or 'Y'
          END IF;        -- rec_nrec_tax_amt = 0 or not

          IF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag, 'N') = 'N' THEN

            -- Accumulate rounded non-recoverable tax amount(not converted)
            --
            l_total_nrec_tax_amt_trx_curr := l_total_nrec_tax_amt_trx_curr +
                                         p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;

            -- Accumulate unrounded non-recoverable tax amount(not converted)
            --
            l_total_unrnd_nrec_tax_amt := l_total_unrnd_nrec_tax_amt +
                                p_rec_nrec_dist_tbl(i).unrounded_rec_nrec_tax_amt;

          ELSIF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag, 'N') = 'Y' THEN

            -- Accumulate rounded recoverable tax amount(not converted)
            --
            l_total_rec_tax_amt_trx_curr := l_total_rec_tax_amt_trx_curr +
                                         p_rec_nrec_dist_tbl(i).rec_nrec_tax_amt;

            -- Accumulate unrounded recoverable tax amount(not converted)
            --
            l_total_unrnd_rec_tax_amt := l_total_unrnd_rec_tax_amt +
                                p_rec_nrec_dist_tbl(i).unrounded_rec_nrec_tax_amt;
          END IF;
        END IF;        -- NVL(p_rec_nrec_dist_tbl(i).reverse_flag, 'N') = 'N'

        -- set func_curr_rounding_adjustment = 0. It may be adjusted later.
        --
        p_rec_nrec_dist_tbl(i).func_curr_rounding_adjustment := 0;

      END LOOP;        -- i IN p_rnd_begin_index .. p_rnd_end_index
    END IF;            -- trx_currency_code = tax_currency_code or ELSE

    IF l_non_zero_rec_tax_dists_tbl.COUNT > 0 THEN
      FOR i IN l_non_zero_rec_tax_dists_tbl.FIRST ..
                                         l_non_zero_rec_tax_dists_tbl.LAST LOOP

        -- convert tax amount to functional currency and perform rounding for
        -- rec_nrec_tax_amt_funcl_curr
        --
        l_index := l_non_zero_rec_tax_dists_tbl(i).tbl_index;
        p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr :=
              p_rec_nrec_dist_tbl(l_index).unrounded_rec_nrec_tax_amt *
                         p_rec_nrec_dist_tbl(l_index).currency_conversion_rate;

        p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr :=
              round(p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr/
                          l_min_acct_unit_funcl_curr)*l_min_acct_unit_funcl_curr;

        -- Accumulate tax amount of converted recoverable tax dists
        --
        l_sum_of_rnd_rec_tax_amt := l_sum_of_rnd_rec_tax_amt +
                         p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr;

        -- Refresh l_non_zero_rec_tax_dists_tbl(i).tbl_amt with
        -- rec_nrec_tax_amt_funcl_curr.
        --
        l_non_zero_rec_tax_dists_tbl(i).tbl_amt :=
                        p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr;

      END LOOP;
    END IF;

    IF l_non_zero_nrec_tax_dists_tbl.COUNT > 0 THEN
      FOR i IN l_non_zero_nrec_tax_dists_tbl.FIRST ..
                                         l_non_zero_nrec_tax_dists_tbl.LAST LOOP
        -- convert tax amount to functional currency and perform rounding for
        -- rec_nrec_tax_amt_funcl_curr
        --
        l_index := l_non_zero_nrec_tax_dists_tbl(i).tbl_index;
        p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr :=
              p_rec_nrec_dist_tbl(l_index).unrounded_rec_nrec_tax_amt *
                         p_rec_nrec_dist_tbl(l_index).currency_conversion_rate;

        p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr :=
              round(p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr/
                          l_min_acct_unit_funcl_curr)*l_min_acct_unit_funcl_curr;

        -- Accumulate tax amount of converted non-recoverable tax dists
        --
        l_sum_of_rnd_nrec_tax_amt := l_sum_of_rnd_nrec_tax_amt +
                       p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr;

        -- Refresh l_non_zero_rec_tax_dists_tbl(i).tbl_amt with
        -- rec_nrec_tax_amt_funcl_curr.
        --
        l_non_zero_nrec_tax_dists_tbl(i).tbl_amt :=
                        p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr;
      END LOOP;
    END IF;

    -- convert l_rnd_total_rec_tax_amt to functional currency and
    -- perform rounding for l_total_unrnd_rec_tax_amt
    --
    l_rnd_total_rec_tax_amt := l_total_unrnd_rec_tax_amt *
                p_rec_nrec_dist_tbl(p_rnd_begin_index).currency_conversion_rate;
    l_rnd_total_rec_tax_amt := round(l_rnd_total_rec_tax_amt/
                         l_min_acct_unit_funcl_curr)*l_min_acct_unit_funcl_curr;

    -- convert l_rnd_total_nrec_tax_amt to functional currency and
    -- perform rounding for l_total_unrnd_nrec_tax_amt
    --
    l_rnd_total_nrec_tax_amt := l_total_unrnd_nrec_tax_amt *
                 p_rec_nrec_dist_tbl(p_rnd_begin_index).currency_conversion_rate;

    l_rnd_total_nrec_tax_amt := round(l_rnd_total_nrec_tax_amt/
                          l_min_acct_unit_funcl_curr)*l_min_acct_unit_funcl_curr;


    -- calculate rounding difference in functional currency for recoverable and
    -- non-recoverable tax distributions
    --
    l_rec_tax_rnd_diff_funcl_curr :=
                               l_rnd_total_rec_tax_amt - l_sum_of_rnd_rec_tax_amt;
    l_nrec_tax_rnd_diff_funcl_curr :=
                               l_rnd_total_nrec_tax_amt-l_sum_of_rnd_nrec_tax_amt;

    IF l_rec_tax_rnd_diff_funcl_curr <> 0 THEN

      -- Adjust rounding_diff to recoverable tax dists first. if there is no
      -- non-zero recoverable tax dists, adjust rounding_diff to nonrecoverable
      -- tax dists.
      --
      IF l_non_zero_rec_tax_dists_tbl.COUNT > 0 THEN

        IF NVL(l_rec_tax_dists_tbl_sort_flg, 'N') <> 'Y' THEN

          -- sort l_non_zero_rec_tax_dists_tbl
          --
          ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc (
         		p_index_amt_tbl    => l_non_zero_rec_tax_dists_tbl,
         		p_return_status    => p_return_status,
         		p_error_buffer     => p_error_buffer);

          IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
          THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                            'Incorrect return_status after calling ' ||
                            'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc()');
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                            'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||p_return_status);
            END IF;
            RETURN;
          END IF;

          -- set the sort flag for l_non_zero_rec_tax_dists_tbl
          --
          l_rec_tax_dists_tbl_sort_flg := 'Y';

        END IF;      -- l_rec_tax_dists_tbl_sort_flg <> 'Y'

        ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff (
 	  	p_index_amt_tbl => l_non_zero_rec_tax_dists_tbl,
 	  	p_rounding_diff => l_rec_tax_rnd_diff_funcl_curr,
 	  	p_min_acct_unit => l_min_acct_unit_funcl_curr,
 	  	p_return_status => p_return_status,
 	  	p_error_buffer  => p_error_buffer);

        -- update rec_nrec_tax_amt_funcl_curr
        --
        FOR i IN l_non_zero_rec_tax_dists_tbl.FIRST ..
                                          l_non_zero_rec_tax_dists_tbl.LAST LOOP
          l_index := l_non_zero_rec_tax_dists_tbl(i).tbl_index;

          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr :=
                                         l_non_zero_rec_tax_dists_tbl(i).tbl_amt;
        END LOOP;

      ELSIF l_non_zero_nrec_tax_dists_tbl.COUNT > 0 THEN

        IF NVL(l_nrec_tax_dists_tbl_sort_flg, 'N') <> 'Y' THEN
          -- sort l_non_zero_nrec_tax_dists_tbl
          --
          ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc (
         		p_index_amt_tbl    => l_non_zero_nrec_tax_dists_tbl,
         		p_return_status    => p_return_status,
         		p_error_buffer     => p_error_buffer);

          IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
          THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                            'Incorrect return_status after calling ' ||
                            'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc()');
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                            'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||p_return_status);
            END IF;
            RETURN;
          END IF;

          -- set the sort flag for l_non_zero_rec_tax_dists_tbl
          --
          l_nrec_tax_dists_tbl_sort_flg := 'Y';

        END IF;      -- l_nrec_tax_dists_tbl_sort_flg <> 'Y'

        ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff (
 	  	p_index_amt_tbl => l_non_zero_nrec_tax_dists_tbl,
 	  	p_rounding_diff => l_rec_tax_rnd_diff_funcl_curr,
 	  	p_min_acct_unit => l_min_acct_unit_funcl_curr,
 	  	p_return_status => p_return_status,
 	  	p_error_buffer  => p_error_buffer);

        IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'Incorrect return_status after calling ' ||
                          'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'RETURN_STATUS = ' || p_return_status);
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)');
          END IF;
          RETURN;
        END IF;

        -- update rec_nrec_tax_amt_funcl_curr
        --
        FOR i IN l_non_zero_nrec_tax_dists_tbl.FIRST ..
                                           l_non_zero_nrec_tax_dists_tbl.LAST LOOP

          l_index := l_non_zero_nrec_tax_dists_tbl(i).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr :=
                                         l_non_zero_nrec_tax_dists_tbl(i).tbl_amt;
        END LOOP;
      END IF;
    END IF;      -- l_rec_tax_rnd_diff_funcl_curr <> 0

    IF l_nrec_tax_rnd_diff_funcl_curr <> 0 THEN

      -- Adjust rounding_diff to nonrecoverable tax dists first. if there is no
      -- nonrecoverable tax dists, adjust rounding_diff to recoverable tax dists.
      --
      IF l_non_zero_nrec_tax_dists_tbl.COUNT > 0 THEN

        IF NVL(l_nrec_tax_dists_tbl_sort_flg, 'N') <> 'Y' THEN
          -- sort l_non_zero_nrec_tax_dists_tbl
          --
          ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc (
         		p_index_amt_tbl    => l_non_zero_nrec_tax_dists_tbl,
         		p_return_status    => p_return_status,
         		p_error_buffer     => p_error_buffer);

          IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
          THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                            'Incorrect return_status after calling ' ||
                            'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc()');
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                            'RETURN_STATUS = ' || p_return_status);
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                            'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)');
            END IF;
            RETURN;
          END IF;

          -- set the sort flag for l_non_zero_nrec_tax_dists_tbl
          --
          l_nrec_tax_dists_tbl_sort_flg := 'Y';

        END IF;      -- l_nrec_tax_dists_tbl_sort_flg <> 'Y'

        ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff (
 	  	p_index_amt_tbl => l_non_zero_nrec_tax_dists_tbl,
 	  	p_rounding_diff => l_nrec_tax_rnd_diff_funcl_curr,
 	  	p_min_acct_unit => l_min_acct_unit_funcl_curr,
 	  	p_return_status => p_return_status,
 	  	p_error_buffer  => p_error_buffer);

        IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'Incorrect return_status after calling ' ||
                          'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'RETURN_STATUS = ' || p_return_status);
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)');
          END IF;
          RETURN;
        END IF;

        -- update rec_nrec_tax_amt_funcl_curr
        --
        FOR i IN l_non_zero_nrec_tax_dists_tbl.FIRST ..
                                         l_non_zero_nrec_tax_dists_tbl.LAST LOOP

          l_index := l_non_zero_nrec_tax_dists_tbl(i).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr :=
                                         l_non_zero_nrec_tax_dists_tbl(i).tbl_amt;
        END LOOP;

      ELSIF l_non_zero_rec_tax_dists_tbl.COUNT > 0 THEN

        IF NVL(l_rec_tax_dists_tbl_sort_flg, 'N') <> 'Y' THEN
          -- sort l_non_zero_rec_tax_dists_tbl
          --
          ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc (
         		p_index_amt_tbl    => l_non_zero_rec_tax_dists_tbl,
         		p_return_status    => p_return_status,
         		p_error_buffer     => p_error_buffer);

          IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
          THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                            'Incorrect return_status after calling ' ||
                            'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc()');
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                            'RETURN_STATUS = ' || p_return_status);
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                            'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)');
            END IF;
            RETURN;
          END IF;

          -- set the sort flag for l_non_zero_rec_tax_dists_tbl
          --
          l_rec_tax_dists_tbl_sort_flg := 'Y';

        END IF;      -- l_rec_tax_dists_tbl_sort_flg <> 'Y'

        ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff (
 	  	p_index_amt_tbl => l_non_zero_rec_tax_dists_tbl,
 	  	p_rounding_diff => l_nrec_tax_rnd_diff_funcl_curr,
 	  	p_min_acct_unit => l_min_acct_unit_funcl_curr,
 	  	p_return_status => p_return_status,
 	  	p_error_buffer  => p_error_buffer);

        IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'Incorrect return_status after calling ' ||
                          'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'RETURN_STATUS = ' || p_return_status);
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                          'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)');
          END IF;
          RETURN;
        END IF;

        -- update rec_nrec_tax_amt_funcl_curr
        --
        FOR i IN l_non_zero_rec_tax_dists_tbl.FIRST ..
                                            l_non_zero_rec_tax_dists_tbl.LAST LOOP

          l_index := l_non_zero_rec_tax_dists_tbl(i).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr :=
                                         l_non_zero_rec_tax_dists_tbl(i).tbl_amt;
        END LOOP;
      END IF;
    END IF;      -- l_nrec_tax_rnd_diff_funcl_curr <> 0

    IF p_tax_line_amt_funcl_curr IS NOT NULL THEN

      -- calculate rounding difference for amount of tax line
      --
      l_tax_line_rnd_diff_funcl_curr := p_tax_line_amt_funcl_curr -
                           (l_rnd_total_rec_tax_amt + l_rnd_total_nrec_tax_amt);


      IF l_tax_line_rnd_diff_funcl_curr > 0 THEN

        -- Adjust this rounding difference to the largest non-zero
        -- non-recoverabletax distribution (check first), or adjust it to
        -- the largest non-zero recoverable tax distribution.
        --
        IF l_non_zero_nrec_tax_dists_tbl.COUNT > 0 THEN

          l_index := l_non_zero_nrec_tax_dists_tbl(
                                     l_non_zero_nrec_tax_dists_tbl.FIRST).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr :=
                  p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr +
                                                     l_tax_line_rnd_diff_funcl_curr;

          -- store rounding adjustment
          --
          p_rec_nrec_dist_tbl(l_index).func_curr_rounding_adjustment :=
                                                     l_tax_line_rnd_diff_funcl_curr;


          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'Rounding Dif adjusted to the largest non-rec tax dist '||l_index);
          END IF;

        ELSIF l_non_zero_rec_tax_dists_tbl.COUNT > 0 THEN

          l_index := l_non_zero_rec_tax_dists_tbl(
                                     l_non_zero_rec_tax_dists_tbl.FIRST).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr :=
                  p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr +
                                                     l_tax_line_rnd_diff_funcl_curr;

          -- store rounding adjustment
          --
          p_rec_nrec_dist_tbl(l_index).func_curr_rounding_adjustment :=
                                                     l_tax_line_rnd_diff_funcl_curr;

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'Rounding Dif adjusted to the largest rec tax dist '||l_index);
          END IF;

        END IF;

      ELSIF l_tax_line_rnd_diff_funcl_curr < 0 THEN

        -- Adjust this rounding difference to the largest non-zero
        -- recoverabletax distribution (check first), or adjust it to
        -- the largest non-zero non-recoverable tax distribution.
        --
        IF l_non_zero_rec_tax_dists_tbl.COUNT > 0  THEN

          l_index := l_non_zero_rec_tax_dists_tbl(
                                     l_non_zero_rec_tax_dists_tbl.FIRST).tbl_index;
          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr :=
                  p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr +
                                                       l_tax_line_rnd_diff_funcl_curr;

          -- store rounding adjustment
          --
          p_rec_nrec_dist_tbl(l_index).func_curr_rounding_adjustment :=
                                                     l_tax_line_rnd_diff_funcl_curr;


          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'Rounding Dif adjusted to the largest rec tax dist '||l_index);
          END IF;


        ELSIF  l_non_zero_nrec_tax_dists_tbl.COUNT > 0  THEN

          l_index := l_non_zero_nrec_tax_dists_tbl(
                                     l_non_zero_nrec_tax_dists_tbl.FIRST).tbl_index;

          p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr :=
                  p_rec_nrec_dist_tbl(l_index).rec_nrec_tax_amt_funcl_curr +
                                                       l_tax_line_rnd_diff_funcl_curr;

          -- store rounding adjustment
          --
          p_rec_nrec_dist_tbl(l_index).func_curr_rounding_adjustment :=
                                                     l_tax_line_rnd_diff_funcl_curr;

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                          'Rounding Dif adjusted to the largest non-rec tax dist '||l_index);
          END IF;

        END IF;
      END IF;   -- l_tax_line_rnd_diff_tax_curr > 0 OR < 0
    END IF;      -- p_tax_line_amt_funcl_curr IS NOT NULL

    -- converting taxable_amt to functional currency.
    --
    FOR i IN p_rnd_begin_index .. p_rnd_end_index LOOP
      IF NVL(p_rec_nrec_dist_tbl(i).reverse_flag, 'N') = 'N' THEN
        IF l_funcl_currency_code <>  p_rec_nrec_dist_tbl(i).trx_currency_code THEN
          -- convert to functional currency
          --
          p_rec_nrec_dist_tbl(i).taxable_amt_funcl_curr :=
                p_rec_nrec_dist_tbl(i).unrounded_taxable_amt *
                                  p_rec_nrec_dist_tbl(i).currency_conversion_rate;
          -- round
          p_rec_nrec_dist_tbl(i).taxable_amt_funcl_curr :=
                round(p_rec_nrec_dist_tbl(i).taxable_amt_funcl_curr/
                           l_min_acct_unit_funcl_curr)*l_min_acct_unit_funcl_curr;
        ELSE
          p_rec_nrec_dist_tbl(i).taxable_amt_funcl_curr :=
                                              p_rec_nrec_dist_tbl(i).taxable_amt;
        END IF;
      END IF;
    END LOOP;

  ELSE    -- p_rec_nrec_dist_tbl(i).ledger_id IS NULL
    IF (g_level_procedure >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                    'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||
                    ' null Ledger_id cannot perform conversion to functional currency');
    END IF;
  END IF;
  --
  --   /****** END OF CONVERSION AND ROUNDING OF FUNCTIONAL CURRENCY ******/

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)'||p_return_status);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists',
                     p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists.END',
                    'ZX_TRD_INTERNAL_SERVICES_PVT.convert_tax_dists(-)');
      END IF;

END convert_tax_dists;


PROCEDURE distribute_rounding_diff (
 p_index_amt_tbl   	IN OUT NOCOPY	index_amt_tbl_type,
 p_rounding_diff	IN 		NUMBER,
 p_min_acct_unit	IN		NUMBER,
 p_return_status        OUT NOCOPY     VARCHAR2,
 p_error_buffer	        OUT NOCOPY     VARCHAR2) IS

 l_num_of_min_units		NUMBER;
 l_num_of_multiples		NUMBER;
 l_remainder                  	NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff(+)'||
                   'p_rounding_diff = ' || p_rounding_diff);
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;

  -- Adjust rounding difference
  --
  IF p_rounding_diff = 0 THEN
    IF (g_level_procedure >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff.END',
                    'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff(-)'||'no diff');
    END IF;
    RETURN;

  ELSE

    l_num_of_min_units := ABS(TRUNC(p_rounding_diff/p_min_acct_unit));

    IF p_index_amt_tbl.COUNT > 0 THEN

      l_num_of_multiples := TRUNC(l_num_of_min_units/ p_index_amt_tbl.COUNT);
      l_remainder := MOD(l_num_of_min_units, p_index_amt_tbl.COUNT);

      IF l_num_of_multiples <> 0 THEN

        FOR i IN p_index_amt_tbl.FIRST .. p_index_amt_tbl.LAST LOOP

          p_index_amt_tbl(i).tbl_amt := p_index_amt_tbl(i).tbl_amt +
                   p_min_acct_unit * l_num_of_multiples * SIGN(p_rounding_diff);

        END LOOP;  -- IN p_index_amt_tbl.FIRST .. p_index_amt_tbl.LAST LOOP

      END IF;      -- l_num_of_multiples <> 0

      IF l_remainder <> 0 THEN

        FOR i IN 1 .. l_remainder LOOP
          p_index_amt_tbl(i).tbl_amt := p_index_amt_tbl(i).tbl_amt +
                                       p_min_acct_unit *  SIGN(p_rounding_diff);

        END LOOP;    -- IN 1 .. l_remainder LOOP

      END IF;        -- l_remainder <> 0
    ELSE             -- p_index_amt_tbl.COUNT = 0
      IF (g_level_procedure >= g_current_runtime_level ) THEN

        FND_LOG.STRING(g_level_procedure,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff.END',
                      'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff(-)'||
                      'p_index_amt_tbl is empty');
      END IF;
      RETURN;
    END IF;          -- p_index_amt_tbl.COUNT > 0 OR NOT
  END IF;            -- p_rounding_diff <> 0 OR NOT

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff(-)'||
                   p_return_status);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff',
                     p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff.END',
                    'ZX_TRD_INTERNAL_SERVICES_PVT.distribute_rounding_diff(-)');
    END IF;

END distribute_rounding_diff;

PROCEDURE sort_tbl_amt_desc (
 p_index_amt_tbl   	IN OUT NOCOPY  index_amt_tbl_type,
 p_return_status        OUT NOCOPY     VARCHAR2,
 p_error_buffer	        OUT NOCOPY     VARCHAR2) IS

 l_length			NUMBER;
 l_incr 			NUMBER;
 l_first        		NUMBER;
 l_temp_amt 			NUMBER;
 l_temp_index			NUMBER;
 l_temp_num     		NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc(+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;

  --  initialize local variables
  --
  l_length := p_index_amt_tbl.COUNT;
  l_incr := TRUNC(l_length/2);
  l_first := p_index_amt_tbl.FIRST;

  -- sorting p_index_amt_tbl using SHELL sort method
  --
  WHILE l_incr >= 1 LOOP

    FOR i IN l_incr + l_first .. l_first + l_length - 1 LOOP

      -- hold the values at the current index intemporary variables
      --
      l_temp_index := p_index_amt_tbl(i).tbl_index;
      l_temp_amt := p_index_amt_tbl(i).tbl_amt;
      l_temp_num := i;

      WHILE ( l_temp_num  >= l_incr + l_first AND l_temp_amt >
              p_index_amt_tbl(l_temp_num - l_incr).tbl_amt ) LOOP


        p_index_amt_tbl(l_temp_num).tbl_index :=
                         p_index_amt_tbl(l_temp_num - l_incr).tbl_index;

        p_index_amt_tbl(l_temp_num).tbl_amt :=
                         p_index_amt_tbl(l_temp_num - l_incr).tbl_amt;

        l_temp_num := l_temp_num - l_incr;

      END LOOP;

      p_index_amt_tbl(l_temp_num).tbl_index := l_temp_index;
      p_index_amt_tbl(l_temp_num).tbl_amt := l_temp_amt;

    END LOOP;    --

    l_incr := trunc(l_incr/2);

  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc(-)'||p_return_status);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc',
                     p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc.END',
                    'ZX_TRD_INTERNAL_SERVICES_PVT.sort_tbl_amt_desc(-)');
    END IF;

END sort_tbl_amt_desc;

PROCEDURE get_recovery_from_applied(
 p_tax_id               IN            NUMBER,
 p_prd_total_tax_amt    IN            NUMBER,
 p_trx_line_dist_index  IN            NUMBER,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index      IN            NUMBER,
 p_rnd_end_index        OUT NOCOPY    NUMBER,
 p_return_status        OUT NOCOPY    VARCHAR2,
 p_error_buffer         OUT NOCOPY    VARCHAR2) IS

 CURSOR  get_tax_dists_csr IS
  SELECT recoverable_flag,
	 recovery_type_code,
	 rec_type_rule_flag,
	 rec_rate_det_rule_flag,
	 recovery_rate_id,
	 recovery_rate_code,
	 rec_nrec_rate,
	 rec_nrec_tax_dist_id,
	 rec_nrec_tax_amt,
	 rec_nrec_tax_amt_tax_curr,
	 rec_nrec_tax_amt_funcl_curr,
	 trx_line_dist_amt,
	 def_rec_settlement_option_code,
	 account_source_tax_rate_id
   FROM  zx_rec_nrec_dist
   WHERE application_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(
                                                           p_trx_line_dist_index)
      AND entity_code =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(
                                                          p_trx_line_dist_index)
      AND event_class_code  =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(
                                                              p_trx_line_dist_index)
      AND trx_id =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(
                                                              p_trx_line_dist_index)
      AND trx_line_id =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(
                                                               p_trx_line_dist_index)
      AND trx_level_type =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(
                                                               p_trx_line_dist_index)
      AND trx_line_dist_id =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_dist_id(
                                                               p_trx_line_dist_index)
      AND tax_id = p_tax_id
      AND NVL(reverse_flag, 'N') <> 'Y'
      ORDER BY rec_nrec_tax_dist_id, recoverable_flag;

 l_rec_nrec_tax_dist_number		NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_applied.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_applied(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  p_rnd_end_index := p_rnd_begin_index -1;
  l_rec_nrec_tax_dist_number:= 0;

  ZX_TDS_UTILITIES_PKG.populate_tax_cache (
    				p_tax_id	 => p_tax_id,
    				p_return_status  => p_return_status,
    				p_error_buffer   => p_error_buffer);

  FOR tax_dist_rec in get_tax_dists_csr LOOP

    l_rec_nrec_tax_dist_number := l_rec_nrec_tax_dist_number + 1;
    p_rnd_end_index := p_rnd_end_index + 1;

    p_rec_nrec_dist_tbl(p_rnd_end_index).recoverable_flag :=
                                                 tax_dist_rec.recoverable_flag;
    p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_type_code :=
                                              tax_dist_rec.recovery_type_code;
    p_rec_nrec_dist_tbl(p_rnd_end_index).rec_type_rule_flag :=
                                              tax_dist_rec.rec_type_rule_flag;
    p_rec_nrec_dist_tbl(p_rnd_end_index).rec_rate_det_rule_flag :=
                                           tax_dist_rec.rec_rate_det_rule_flag;
    p_rec_nrec_dist_tbl(p_rnd_end_index).applied_from_tax_dist_id :=
                                            tax_dist_rec.rec_nrec_tax_dist_id;
    p_rec_nrec_dist_tbl(p_rnd_end_index).rec_nrec_tax_dist_number:=
                                                   l_rec_nrec_tax_dist_number;

    -- 1. If applied_amt_handling_flag ='P', populate recovery_rate_code,
    --    recovery_rate_id and rec_nrec_rate from applied from document.
    --    Tax distributions are proarted based the amount applied.
    -- 2. If applied_amt_handling_flag ='R', populate recovery_rate_code from
    --    applied document. recovery_rate_id and rec_nrec_rate are determined
    --    in the current document. Tax distributions are recalculated based on
    --    the rec_nrec_ratein the current document.
    --
    IF ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                              p_tax_id).applied_amt_handling_flag = 'P' THEN
      p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_rate_code :=
                                              tax_dist_rec.recovery_rate_code;
      p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_rate_id :=
                                                tax_dist_rec.recovery_rate_id;
      p_rec_nrec_dist_tbl(p_rnd_end_index).rec_nrec_rate :=
                                                   tax_dist_rec.rec_nrec_rate;
      -- populate prd_total_tax_amt
      p_rec_nrec_dist_tbl(p_rnd_end_index).prd_total_tax_amt :=
                                                          p_prd_total_tax_amt;
      p_rec_nrec_dist_tbl(p_rnd_end_index).def_rec_settlement_option_code :=
                                  tax_dist_rec.def_rec_settlement_option_code;
      p_rec_nrec_dist_tbl(p_rnd_end_index).account_source_tax_rate_id :=
                                      tax_dist_rec.account_source_tax_rate_id;

    ELSIF ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                                p_tax_id).applied_amt_handling_flag = 'R' THEN
      p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_rate_code :=
                                              tax_dist_rec.recovery_rate_code;

      p_rec_nrec_dist_tbl(p_rnd_end_index).prd_tax_amt :=
        tax_dist_rec.rec_nrec_tax_amt *
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_AMT(p_trx_line_dist_index)/
        tax_dist_rec.trx_line_dist_amt;

      p_rec_nrec_dist_tbl(p_rnd_end_index).prd_tax_amt_tax_curr :=
        tax_dist_rec.rec_nrec_tax_amt_tax_curr *
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_AMT(p_trx_line_dist_index)/
        tax_dist_rec.trx_line_dist_amt;

      IF tax_dist_rec.rec_nrec_tax_amt_funcl_curr IS NOT NULL THEN
        p_rec_nrec_dist_tbl(p_rnd_end_index).prd_tax_amt_funcl_curr :=
          tax_dist_rec.rec_nrec_tax_amt_funcl_curr *
          ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_AMT(p_trx_line_dist_index)/
          tax_dist_rec.trx_line_dist_amt;
      END IF;
    END IF;

  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level) THEN

    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_applied.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_applied(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_applied',
                      p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_applied.END',
                    'ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_applied(-)');
    END IF;

END get_recovery_from_applied;

PROCEDURE get_recovery_from_adjusted(
 p_tax_id               IN            NUMBER,
 p_trx_line_dist_index  IN            NUMBER,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index      IN            NUMBER,
 p_rnd_end_index        OUT NOCOPY    NUMBER,
 p_return_status        OUT NOCOPY    VARCHAR2,
 p_error_buffer         OUT NOCOPY    VARCHAR2) IS

 CURSOR  get_tax_dists_csr IS
  SELECT recoverable_flag,
	 recovery_type_code,
	 rec_type_rule_flag,
	 rec_rate_det_rule_flag,
	 recovery_rate_id,
	 recovery_rate_code,
	 rec_nrec_rate,
	 rec_nrec_tax_dist_id,
	 def_rec_settlement_option_code,
	 account_source_tax_rate_id
    FROM zx_rec_nrec_dist
   WHERE application_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(
                                                           p_trx_line_dist_index)
     AND entity_code =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(
                                                         p_trx_line_dist_index)
     AND event_class_code  =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(
                                                             p_trx_line_dist_index)
     AND trx_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id(
                                                   p_trx_line_dist_index)
     AND trx_line_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(
                                                             p_trx_line_dist_index)
     AND trx_level_type =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(
                                                             p_trx_line_dist_index)
     AND trx_line_dist_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_dist_id(
                                                             p_trx_line_dist_index)
     AND tax_id = p_tax_id
     AND NVL(reverse_flag, 'N') <> 'Y'
     ORDER BY rec_nrec_tax_dist_id, recoverable_flag;

 l_rec_nrec_tax_dist_number		NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_adjusted.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_adjusted(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  p_rnd_end_index := p_rnd_begin_index - 1;

  l_rec_nrec_tax_dist_number := 0;

  FOR tax_dist_rec in get_tax_dists_csr LOOP

    l_rec_nrec_tax_dist_number := l_rec_nrec_tax_dist_number + 1;
    p_rnd_end_index := p_rnd_end_index + 1;

    p_rec_nrec_dist_tbl(p_rnd_end_index).recoverable_flag :=
                                                tax_dist_rec.recoverable_flag;
    p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_type_code :=
                                             tax_dist_rec.recovery_type_code;
    p_rec_nrec_dist_tbl(p_rnd_end_index).rec_type_rule_flag :=
                                             tax_dist_rec.rec_type_rule_flag;
    p_rec_nrec_dist_tbl(p_rnd_end_index).rec_rate_det_rule_flag:=
                                          tax_dist_rec.rec_rate_det_rule_flag;
    p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_rate_id :=
                                               tax_dist_rec.recovery_rate_id;
    p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_rate_code :=
                                             tax_dist_rec.recovery_rate_code;
    p_rec_nrec_dist_tbl(p_rnd_end_index).rec_nrec_rate :=
                                                  tax_dist_rec.rec_nrec_rate;
    p_rec_nrec_dist_tbl(p_rnd_end_index).adjusted_doc_tax_dist_id :=
                                           tax_dist_rec.rec_nrec_tax_dist_id;
    p_rec_nrec_dist_tbl(p_rnd_end_index).rec_nrec_tax_dist_number :=
                                                  l_rec_nrec_tax_dist_number;
    p_rec_nrec_dist_tbl(p_rnd_end_index).def_rec_settlement_option_code :=
                                  tax_dist_rec.def_rec_settlement_option_code;
    p_rec_nrec_dist_tbl(p_rnd_end_index).account_source_tax_rate_id :=
                                      tax_dist_rec.account_source_tax_rate_id;

  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_adjusted.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_adjusted(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_applied',
                     p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_adjusted.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.get_recovery_from_adjusted(-)');
    END IF;

END get_recovery_from_adjusted;

PROCEDURE enforce_recovery_from_ref(
 p_detail_tax_line_tbl        IN   ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index       IN NUMBER,
 p_trx_line_dist_index  IN            NUMBER,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index      IN            NUMBER,
 p_rnd_end_index        OUT NOCOPY    NUMBER,
 p_return_status        OUT NOCOPY    VARCHAR2,
 p_error_buffer         OUT NOCOPY    VARCHAR2) IS

 CURSOR  get_tax_dists_csr IS
  SELECT recoverable_flag,
	 recovery_type_code,
	 rec_type_rule_flag,
	 rec_rate_det_rule_flag,
	 recovery_rate_code,
	 rec_nrec_tax_dist_id,
	 rec_nrec_rate,
	 orig_rec_nrec_rate,
	 rec_rate_result_id
   FROM  zx_rec_nrec_dist
   WHERE application_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(
                                                          p_trx_line_dist_index)
      AND entity_code =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_entity_code(
                                                          p_trx_line_dist_index)
      AND event_class_code  =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_event_class_code(
                                                          p_trx_line_dist_index)
      AND trx_id =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_trx_id(
                                                          p_trx_line_dist_index)
      AND trx_line_id =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_line_id(
                                                          p_trx_line_dist_index)
      AND trx_level_type =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_trx_level_type(
                                                          p_trx_line_dist_index)
      AND trx_line_dist_id =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_dist_id(
                                                          p_trx_line_dist_index)
      AND tax  = p_detail_tax_line_tbl(p_tax_line_index).tax
      AND tax_regime_code = p_detail_tax_line_tbl(p_tax_line_index).tax_regime_code
      AND NVL(reverse_flag, 'N') <> 'Y'
      ORDER BY rec_nrec_tax_dist_id, recoverable_flag;

   CURSOR  get_maximum_tax_dist_num_csr is
   SELECT max(rec_nrec_tax_dist_number)
   FROM zx_rec_nrec_dist
   WHERE tax_line_id = p_detail_tax_line_tbl(p_tax_line_index).tax_line_id
   AND trx_line_dist_id =
ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_dist_id(p_trx_line_dist_index);

 l_rec_nrec_tax_dist_number		NUMBER;
 l_count				NUMBER;
 l_max_tax_dist_number        NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.enforce_recovery_from_ref.BEGIN',
           'ZX_TRD_INTERNAL_SERVICES_PVT.enforce_recovery_from_ref(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  p_rnd_end_index := p_rnd_begin_index -1;

  OPEN  get_maximum_tax_dist_num_csr;
  FETCH get_maximum_tax_dist_num_csr INTO l_max_tax_dist_number;
  CLOSE get_maximum_tax_dist_num_csr;

  l_max_tax_dist_number := NVL(l_max_tax_dist_number, 0);

  l_rec_nrec_tax_dist_number:= l_max_tax_dist_number;

  ZX_TDS_UTILITIES_PKG.populate_tax_cache (
    	 p_tax_id	 => p_detail_tax_line_tbl(p_tax_line_index).tax_id,
    	 p_return_status  => p_return_status,
    	 p_error_buffer   => p_error_buffer);

  l_count := p_rnd_end_index;

  FOR tax_dist_rec in get_tax_dists_csr LOOP

    l_rec_nrec_tax_dist_number := l_rec_nrec_tax_dist_number + 1;
    p_rnd_end_index := p_rnd_end_index + 1;

    p_rec_nrec_dist_tbl(p_rnd_end_index).recoverable_flag :=
                                                 tax_dist_rec.recoverable_flag;
    p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_type_code :=
                                               tax_dist_rec.recovery_type_code;
    p_rec_nrec_dist_tbl(p_rnd_end_index).rec_type_rule_flag :=
                                               tax_dist_rec.rec_type_rule_flag;
    p_rec_nrec_dist_tbl(p_rnd_end_index).rec_rate_det_rule_flag :=
                                           tax_dist_rec.rec_rate_det_rule_flag;
    p_rec_nrec_dist_tbl(p_rnd_end_index).recovery_rate_code :=
                                               tax_dist_rec.recovery_rate_code;
    p_rec_nrec_dist_tbl(p_rnd_end_index).ref_doc_tax_dist_id :=
                                             tax_dist_rec.rec_nrec_tax_dist_id;
    p_rec_nrec_dist_tbl(p_rnd_end_index).rec_nrec_tax_dist_number:=
                                                    l_rec_nrec_tax_dist_number;
    -- bug 5386805: populate rec_rate_result_id from ref_document
    p_rec_nrec_dist_tbl(p_rnd_end_index).rec_rate_result_id :=
                                               tax_dist_rec.rec_rate_result_id;

    -- bug 4012677: If user had overridden recovery rate %, the overridden
    -- rate % needs to be copied to invoice tax distributions
    --

    IF tax_dist_rec.orig_rec_nrec_rate IS NOT NULL THEN
      p_rec_nrec_dist_tbl(p_rnd_end_index).rec_nrec_rate :=
                                                    tax_dist_rec.rec_nrec_rate;

      IF (g_level_statement >= g_current_runtime_level ) THEN

         FND_LOG.STRING(g_level_statement,
                'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE',
                'user had overridden recovery rate on PO, so copy the PO '||
                'recovery rate % to invoice tax distributions.');

      END IF;

    END IF;
  END LOOP;

  -- bugfix: 5166933. some tax lines on invoice are not present on PO,
  -- need to det appliacble recovery types for those tax lines.

  IF l_count = p_rnd_end_index THEN

        IF (g_level_statement >= g_current_runtime_level ) THEN

           FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.DET_APPL_REC_TYPE',
                    'can not find tax distribution on PO, have to call the ' ||
                    'normal det_appl_rec_type to determine rec type.');

        END IF;

	det_appl_rec_type(
                  p_detail_tax_line_tbl,
                  p_tax_line_index,
                  p_trx_line_dist_index,
                  p_rec_nrec_dist_tbl,
                  p_rnd_begin_index,
                  p_rnd_end_index,
                  p_return_status,
                  p_error_buffer);

      IF NVL(p_return_status,FND_API.G_RET_STS_ERROR)<>FND_API.G_RET_STS_SUCCESS
      THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.enforce_recovery_from_ref',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.det_appl_rec_type()');
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.enforce_recovery_from_ref',
                 'RETURN_STATUS = ' || p_return_status);
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.enforce_recovery_from_ref.END',
                 'ZX_TRD_INTERNAL_SERVICES_PVT.enforce_recovery_from_ref(-)');
        END IF;
        RETURN;
      END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level) THEN

    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.enforce_recovery_from_ref.END',
           'ZX_TRD_INTERNAL_SERVICES_PVT.enforce_recovery_from_ref(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.enforce_recovery_from_ref',
              p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.enforce_recovery_from_ref.END',
             'ZX_TRD_INTERNAL_SERVICES_PVT.enforce_recovery_from_ref(-)');
    END IF;

END enforce_recovery_from_ref;

PROCEDURE round_and_adjust_prd_tax_amts  (
 p_rec_nrec_dist_tbl  IN OUT NOCOPY  ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index    IN             NUMBER,
 p_rnd_end_index      IN             NUMBER,
 p_return_status      OUT NOCOPY     VARCHAR2,
 p_error_buffer       OUT NOCOPY     VARCHAR2) IS

 l_rec_tax_index	     	     NUMBER		:=NULL;
 l_nrec_tax_index		     NUMBER		:=NULL;

 l_rec_amt_largest	     	     NUMBER		:= 0;
 l_nrec_amt_largest		     NUMBER		:= 0;
 l_rec_amt_tax_curr_largest    	     NUMBER		:= 0;
 l_nrec_amt_tax_curr_largest	     NUMBER		:= 0;
 l_rec_amt_funcl_curr_largest	     NUMBER		:= 0;
 l_nrec_amt_funcl_curr_largest	     NUMBER		:= 0;

 l_total_prd_tax_amt		     NUMBER		:= 0;
 l_total_prd_tax_amt_tax_curr	     NUMBER		:= 0;
 l_total_prd_tax_amt_funcl_curr	     NUMBER		:= 0;

 l_prd_tax_rnd_diff	     	     NUMBER;
 l_prd_tax_rnd_diff_tax_curr	     NUMBER;
 l_prd_tax_rnd_diff_funcl_curr	     NUMBER;

 l_min_acct_unit_tax_curr      	     zx_taxes_b.minimum_accountable_unit%TYPE;
 l_precision_tax_curr          	     zx_taxes_b.tax_precision%TYPE;
 l_min_acct_unit_funcl_curr    	     zx_taxes_b.minimum_accountable_unit%TYPE;
 l_precision_funcl_curr              zx_taxes_b.tax_precision%TYPE;
 l_ledger_id		             gl_sets_of_books.set_of_books_id%TYPE;

 l_error_buffer			     VARCHAR2(200);
 l_index			     NUMBER;
 l_tax_id			     zx_taxes_b.tax_id%TYPE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts.BEGIN',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts(+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;

  IF p_rnd_begin_index IS NULL OR p_rnd_end_index IS NULL OR
                                  p_rnd_begin_index > p_rnd_end_index THEN

    --p_return_status:= FND_API.G_RET_STS_ERROR;
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts ',
                     'begin or end index is null, or begin index > end index');
    END IF;
    RETURN;
  END IF;

  -- get minimum_accountable_unit and precision in functional currency
  --
  l_ledger_id := p_rec_nrec_dist_tbl(p_rnd_begin_index).ledger_id;
  IF p_rec_nrec_dist_tbl(p_rnd_begin_index).ledger_id IS NOT NULL THEN
    IF NOT ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl.EXISTS(l_ledger_id) THEN

       ZX_TDS_UTILITIES_PKG.populate_currency_cache (
          p_ledger_id      => l_ledger_id,
          p_return_status  => p_return_status,
          p_error_buffer   => p_error_buffer);

      IF NVL(p_return_status,FND_API.G_RET_STS_ERROR)<>FND_API.G_RET_STS_SUCCESS
      THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.populate_currency_cache()');
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts',
                 'RETURN_STATUS = ' || p_return_status);
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts.END',
                 'ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts(-)');
        END IF;
        RETURN;
      END IF;
    END IF;

    l_min_acct_unit_funcl_curr := ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl(
                                        l_ledger_id).minimum_accountable_unit;
    l_precision_funcl_curr := ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl(
                                                       l_ledger_id).precision;
  END IF;

  FOR i IN p_rnd_begin_index .. p_rnd_end_index LOOP
    -- populate g_tax_rec_tbl if this tax_id has not been populated
    --
    l_tax_id := p_rec_nrec_dist_tbl(i).tax_id;

    -- get l_min_acct_unit_tax_curr and l_precision_tax_curr from g_tax_rec_tbl
    --
    l_min_acct_unit_tax_curr :=
            ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).minimum_accountable_unit;
    l_precision_tax_curr :=
            ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).tax_precision;

    -- round prd_tax_amt
    --
    p_rec_nrec_dist_tbl(i).prd_tax_amt :=
 		ZX_TDS_TAX_ROUNDING_PKG.round_tax(
			p_rec_nrec_dist_tbl(i).prd_tax_amt,
			p_rec_nrec_dist_tbl(i).Rounding_Rule_Code,
			p_rec_nrec_dist_tbl(i).minimum_accountable_unit,
			p_rec_nrec_dist_tbl(i).precision,
			p_return_status,
			p_error_buffer);

    -- round prd_tax_amt_tax_curr
    --
    p_rec_nrec_dist_tbl(i).prd_tax_amt_tax_curr :=
    	 	ZX_TDS_TAX_ROUNDING_PKG.round_tax(
			p_rec_nrec_dist_tbl(i).prd_tax_amt_tax_curr,
			p_rec_nrec_dist_tbl(i).Rounding_Rule_Code,
			l_min_acct_unit_tax_curr,
			l_precision_tax_curr,
			p_return_status,
			p_error_buffer);

    IF NVL(p_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts ',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_TAX_ROUNDING_PKG.round_tax()');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts ',
                      'RETURN_STATUS = ' || p_return_status);
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts.END',
                      'ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts (-)');
      END IF;
      RETURN;
    END IF;

    -- round prd_tax_amt_funcl_curr
    --
    IF p_rec_nrec_dist_tbl(i).prd_tax_amt_funcl_curr IS NOT NULL THEN
      p_rec_nrec_dist_tbl(i).prd_tax_amt_funcl_curr :=
    	round( p_rec_nrec_dist_tbl(i).prd_tax_amt_funcl_curr/
  	              l_min_acct_unit_funcl_curr) * l_min_acct_unit_funcl_curr;
    END IF;

    -- Accumulate prd_tax_amt, prd_tax_amt_tax_curr, prd_tax_amt_funcl_curr
    --
    l_total_prd_tax_amt := l_total_prd_tax_amt +
                                             p_rec_nrec_dist_tbl(i).prd_tax_amt;
    l_total_prd_tax_amt_tax_curr := l_total_prd_tax_amt_tax_curr +
                                    p_rec_nrec_dist_tbl(i).prd_tax_amt_tax_curr;
    l_total_prd_tax_amt_funcl_curr := l_total_prd_tax_amt_funcl_curr +
                                  p_rec_nrec_dist_tbl(i).prd_tax_amt_funcl_curr;

    IF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag, 'N') = 'N' THEN
      -- Record the largest prd_tax_amt, prd_tax_amt_tax_curr,
      -- prd_tax_amt_funcl_curr of non-recoverable tax dists
      --
      IF ABS(p_rec_nrec_dist_tbl(i).prd_tax_amt) >= ABS(l_nrec_amt_largest) THEN
        l_nrec_tax_index := i;
        l_nrec_amt_largest := p_rec_nrec_dist_tbl(i).prd_tax_amt;
      END IF;

    ELSIF NVL(p_rec_nrec_dist_tbl(i).recoverable_flag, 'N') = 'Y' THEN

      -- Record the largest prd_tax_amt, prd_tax_amt_tax_curr,
      -- prd_tax_amt_funcl_curr of non-zero recoverable tax dists
      --
      IF ABS(p_rec_nrec_dist_tbl(i).prd_tax_amt) >= ABS(l_rec_amt_largest) THEN
        l_rec_tax_index := i;
        l_rec_amt_largest := p_rec_nrec_dist_tbl(i).prd_tax_amt;
      END IF;
    END IF;      -- recoverable_flag
  END LOOP;

  l_prd_tax_rnd_diff :=
    p_rec_nrec_dist_tbl(p_rnd_begin_index).prd_total_tax_amt-l_total_prd_tax_amt;

  IF l_prd_tax_rnd_diff < 0 THEN

    -- Adjust rounding difference to the largest recoverable tax dists first.
    -- If there is no recoverable tax dists, adjust rounding
    -- difference to the largest nonrecoverable tax dists.
    --
    IF l_rec_tax_index IS NOT NULL THEN

      p_rec_nrec_dist_tbl(l_rec_tax_index).prd_tax_amt :=
        p_rec_nrec_dist_tbl(l_rec_tax_index).prd_tax_amt + l_prd_tax_rnd_diff;

    ELSIF l_nrec_tax_index IS NOT NULL THEN

      p_rec_nrec_dist_tbl(l_nrec_tax_index).prd_tax_amt :=
        p_rec_nrec_dist_tbl(l_nrec_tax_index).prd_tax_amt + l_prd_tax_rnd_diff;

    END IF;

  ELSIF l_prd_tax_rnd_diff > 0 THEN

    -- Adjust rounding_diff to the largest nonrecoverable tax dists first.
    -- if there is no nonrecoverable tax dists, adjust rounding_diff to the
    -- largest recoverable tax dists.
    --
    IF l_nrec_tax_index IS NOT NULL THEN

      p_rec_nrec_dist_tbl(l_nrec_tax_index).prd_tax_amt :=
        p_rec_nrec_dist_tbl(l_nrec_tax_index).prd_tax_amt + l_prd_tax_rnd_diff;

    ELSIF l_rec_tax_index IS NOT NULL THEN

      p_rec_nrec_dist_tbl(l_rec_tax_index).prd_tax_amt :=
        p_rec_nrec_dist_tbl(l_rec_tax_index).prd_tax_amt + l_prd_tax_rnd_diff;

    END IF;
  END IF;      -- l_prd_tax_rnd_diff <> 0

  l_prd_tax_rnd_diff_tax_curr :=
        p_rec_nrec_dist_tbl(p_rnd_begin_index).prd_total_tax_amt_tax_curr -
                                                  l_total_prd_tax_amt_tax_curr;
  IF l_prd_tax_rnd_diff_tax_curr < 0 THEN

    -- Adjust rounding_diff to the largest recoverable tax dists first.
    -- If there is no recoverable tax dists, adjust rounding_diff to the largest
    -- nonrecoverable tax dists.
    --
    IF l_rec_tax_index IS NOT NULL THEN

      p_rec_nrec_dist_tbl(l_rec_tax_index).prd_tax_amt_tax_curr :=
        p_rec_nrec_dist_tbl(l_rec_tax_index).prd_tax_amt_tax_curr +
                                                    l_prd_tax_rnd_diff_tax_curr;
    ELSIF l_nrec_tax_index IS NOT NULL THEN

      p_rec_nrec_dist_tbl(l_nrec_tax_index).prd_tax_amt :=
                 p_rec_nrec_dist_tbl(l_nrec_tax_index).prd_tax_amt +
                                                    l_prd_tax_rnd_diff_tax_curr;
    END IF;

  ELSIF l_prd_tax_rnd_diff_tax_curr > 0 THEN

    -- Adjust rounding_diff to the largest nonrecoverable tax dists first.
    -- if there is no nonrecoverable tax dists, adjust rounding_diff to the
    -- largest recoverable tax dists.
    --
    IF l_nrec_tax_index IS NOT NULL THEN

      p_rec_nrec_dist_tbl(l_nrec_tax_index).prd_tax_amt_tax_curr :=
        p_rec_nrec_dist_tbl(l_nrec_tax_index).prd_tax_amt_tax_curr +
                                                    l_prd_tax_rnd_diff_tax_curr;
    ELSIF l_rec_tax_index IS NOT NULL THEN

      p_rec_nrec_dist_tbl(l_rec_tax_index).prd_tax_amt_tax_curr :=
        p_rec_nrec_dist_tbl(l_rec_tax_index).prd_tax_amt_tax_curr +
                                                    l_prd_tax_rnd_diff_tax_curr;
    END IF;
  END IF;      -- l_prd_tax_rnd_diff_tax_curr <> 0

  -- Functional currency
  --
  IF p_rec_nrec_dist_tbl(p_rnd_begin_index).prd_total_tax_amt_funcl_curr
                                                               IS NOT NULL THEN
    l_prd_tax_rnd_diff_funcl_curr :=
      p_rec_nrec_dist_tbl(p_rnd_begin_index).prd_total_tax_amt_funcl_curr -
                                                 l_total_prd_tax_amt_funcl_curr;

    IF l_prd_tax_rnd_diff_funcl_curr < 0 THEN
      -- Adjust rounding_diff to the largest recoverable tax dists first.
      -- If there is no recoverable tax dists, adjust rounding_diff to
      -- the largest nonrecoverable tax dists.
      --
      IF l_rec_tax_index IS NOT NULL THEN

        p_rec_nrec_dist_tbl(l_rec_tax_index).prd_tax_amt_funcl_curr :=
          p_rec_nrec_dist_tbl(l_rec_tax_index).prd_tax_amt_funcl_curr +
                                                  l_prd_tax_rnd_diff_funcl_curr;

      ELSIF l_nrec_tax_index IS NOT NULL THEN

        p_rec_nrec_dist_tbl(l_nrec_tax_index).prd_tax_amt_funcl_curr :=
          p_rec_nrec_dist_tbl(l_nrec_tax_index).prd_tax_amt_funcl_curr +
                                                  l_prd_tax_rnd_diff_funcl_curr;
      END IF;

    ELSIF l_prd_tax_rnd_diff_funcl_curr > 0 THEN

      -- Adjust rounding_diff to the largest nonrecoverable tax dists first.
      -- if there is no nonrecoverable tax dists, adjust rounding_diff to
      -- the largest recoverable tax dists.
      --
      IF l_nrec_tax_index IS NOT NULL THEN

        p_rec_nrec_dist_tbl(l_nrec_tax_index).prd_tax_amt_funcl_curr :=
          p_rec_nrec_dist_tbl(l_nrec_tax_index).prd_tax_amt_funcl_curr+
                                                  l_prd_tax_rnd_diff_funcl_curr;

      ELSIF l_rec_tax_index IS NOT NULL THEN

        p_rec_nrec_dist_tbl(l_rec_tax_index).prd_tax_amt_funcl_curr :=
          p_rec_nrec_dist_tbl(l_rec_tax_index).prd_tax_amt_funcl_curr+
                                                  l_prd_tax_rnd_diff_funcl_curr;
      END IF;
    END IF;      -- l_prd_tax_rnd_diff_funcl_curr <> 0
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts.END',
                  'ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts (-)'||p_return_status);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts',
                     l_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts.END',
                    'ZX_TRD_INTERNAL_SERVICES_PVT.round_and_adjust_prd_tax_amts (-)');
      END IF;

END round_and_adjust_prd_tax_amts;

PROCEDURE get_variance_related_columns(
 p_detail_tax_line_tbl  IN            ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index       IN            NUMBER,
 p_rec_nrec_dist_tbl    IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index      IN            NUMBER,
 p_rnd_end_index        IN            NUMBER,
 p_return_status           OUT NOCOPY VARCHAR2,
 p_error_buffer            OUT NOCOPY VARCHAR2) IS

 l_dist_id              NUMBER;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns.BEGIN',
           'ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns(+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;

  IF p_rnd_begin_index IS NULL OR p_rnd_end_index IS NULL OR
     p_rnd_begin_index > p_rnd_end_index THEN

    --p_return_status:= FND_API.G_RET_STS_ERROR;
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns',
             'begin or end index is null, or begin index > end index');
    END IF;
    RETURN;
  END IF;

  -- Bug 3631551: Populate variance determining factors that products pass in.
  --
  FOR i IN p_rnd_begin_index .. p_rnd_end_index LOOP

    IF p_rec_nrec_dist_tbl(i).ref_doc_application_id IS NOT NULL THEN

      IF p_rec_nrec_dist_tbl(i).recoverable_flag = 'N' THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns',
             'recoverable_flag is N ');
        END IF;


      l_dist_id := p_rec_nrec_dist_tbl(i).trx_line_dist_id;

      -- bug 6709478
      IF NVL(p_rec_nrec_dist_tbl(i).reverse_flag, 'N') <> 'Y' AND
         NVL(p_rec_nrec_dist_tbl(i).freeze_flag, 'N') <> 'Y'
      THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns',
             'Reverse flag and Freeze flag are not Y ');
        END IF;

        p_rec_nrec_dist_tbl(i).trx_line_dist_qty :=
              ZX_TRD_SERVICES_PUB_PKG.g_tax_variance_info_tbl(
                                                  l_dist_id).trx_line_dist_qty;
      END IF;

      p_rec_nrec_dist_tbl(i).ref_doc_trx_line_dist_qty :=
                 ZX_TRD_SERVICES_PUB_PKG.g_tax_variance_info_tbl(
                                           l_dist_id).ref_doc_trx_line_dist_qty;
      p_rec_nrec_dist_tbl(i).price_diff :=
          ZX_TRD_SERVICES_PUB_PKG.g_tax_variance_info_tbl(l_dist_id).price_diff;

      p_rec_nrec_dist_tbl(i).qty_diff :=
         p_rec_nrec_dist_tbl(i).trx_line_dist_qty -
                              p_rec_nrec_dist_tbl(i).ref_doc_trx_line_dist_qty;
      p_rec_nrec_dist_tbl(i).ref_doc_curr_conv_rate :=
                 ZX_TRD_SERVICES_PUB_PKG.g_tax_variance_info_tbl(
                                              l_dist_id).ref_doc_curr_conv_rate;
      p_rec_nrec_dist_tbl(i).applied_to_doc_curr_conv_rate :=
                 ZX_TRD_SERVICES_PUB_PKG.g_tax_variance_info_tbl(
                                       l_dist_id).applied_to_doc_curr_conv_rate;

      -- set rate_tax_factor
      --
      IF p_detail_tax_line_tbl(p_tax_line_index).tax_rate_type = 'PERCENTAGE' THEN
        p_rec_nrec_dist_tbl(i).rate_tax_factor := 1;
      ELSE       -- quantity based tax rate
        p_rec_nrec_dist_tbl(i).rate_tax_factor := 0;
      END IF;
    END IF;   -- p_rec_nrec_dist_tbl(i).recoverable_flag = 'N'
   ELSE
     IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns',
             'Ref doc application id is null');
     END IF;

   END IF; -- ref_doc_application_id is not null
  END LOOP;  -- i IN p_rnd_begin_index .. p_rnd_end_index

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns.END',
           'ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns',
              p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns.END',
             'ZX_TRD_INTERNAL_SERVICES_PVT.get_variance_related_columns(-)');
    END IF;

END get_variance_related_columns;

PROCEDURE calc_variance_factors(
 p_return_status              OUT NOCOPY     VARCHAR2,
 p_error_buffer               OUT NOCOPY     VARCHAR2) IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_variance_factors.BEGIN',
          'ZX_TRD_INTERNAL_SERVICES_PVT.calc_variance_factors(+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;


  -- Bugfix 5035461: added recoverable_flag and reverse_flag condition in
  --                 the subquery.

  UPDATE zx_rec_nrec_dist_gt gt
     SET  per_trx_curr_unit_nr_amt =
  -- Bugfix 5218651: for amount based matching, when dist qty is 0 or null, return rec_nrec_tax_amt as per unit nr amount
            DECODE(gt.trx_line_dist_qty*gt.unit_price,0, gt.rec_nrec_tax_amt,
                   gt.rec_nrec_tax_amt/(gt.trx_line_dist_qty*gt.unit_price)),
          per_unit_nrec_tax_amt =
             DECODE(gt.trx_line_dist_qty, 0, gt.rec_nrec_tax_amt,
                    gt.rec_nrec_tax_amt/gt.trx_line_dist_qty),
          (ref_doc_tax_dist_id,
          ref_doc_unit_price,
          ref_per_trx_curr_unit_nr_amt,
          ref_doc_per_unit_nrec_tax_amt)=
         (SELECT
           rec_nrec_tax_dist_id,
           --Bug 9470313
           Nvl(unit_price,0),
           DECODE(gt.ref_doc_trx_line_dist_qty,
                  NULL, DECODE(Nvl(dist.unit_price,0), 0, dist.rec_nrec_tax_amt, dist.rec_nrec_tax_amt/dist.unit_price),
                        DECODE(gt.ref_doc_trx_line_dist_qty*dist.unit_price, 0,  dist.rec_nrec_tax_amt,
                               dist.rec_nrec_tax_amt/(gt.ref_doc_trx_line_dist_qty*dist.unit_price))),
           DECODE(Nvl(gt.ref_doc_trx_line_dist_qty,0), 0, dist.rec_nrec_tax_amt,
                             dist.rec_nrec_tax_amt/gt.ref_doc_trx_line_dist_qty)
            FROM zx_rec_nrec_dist dist
           WHERE dist.application_id = gt.ref_doc_application_id
             AND dist.entity_code = gt.ref_doc_entity_code
             AND dist.event_class_code = gt.ref_doc_event_class_code
             AND dist.trx_id = gt.ref_doc_trx_id
             AND dist.trx_line_id = gt.ref_doc_line_id
             AND dist.trx_level_type = gt.ref_doc_trx_level_type
             AND (dist.trx_line_dist_id = gt.ref_doc_dist_id OR
                  gt.tax_only_line_flag = 'Y')
             AND dist.tax_regime_code  = gt.tax_regime_code
             AND dist.tax = gt.tax
             AND dist.recoverable_flag = 'N'
             AND NVL(dist.reverse_flag,'N') = 'N'
             AND dist.mrc_tax_dist_flag = 'N'
         )
   WHERE ref_doc_application_id IS NOT NULL
     AND recoverable_flag = 'N'
     AND NVL(reverse_flag,'N')='N'
     AND mrc_tax_dist_flag = 'N';

  -- update ref_doc_unit_price if it is null (PO has no tax)
  --
  UPDATE zx_rec_nrec_dist_gt gt
     SET ref_doc_unit_price =
         (SELECT  unit_price
            FROM zx_lines_det_factors line
           WHERE line.application_id = gt.ref_doc_application_id
             AND line.entity_code = gt.ref_doc_entity_code
             AND line.event_class_code = gt.ref_doc_event_class_code
             AND line.trx_id = gt.ref_doc_trx_id
             AND line.trx_line_id = gt.ref_doc_line_id
             AND line.trx_level_type = gt.ref_doc_trx_level_type
         )
   WHERE ref_doc_application_id IS NOT NULL
     AND recoverable_flag = 'N'
     AND NVL(reverse_flag,'N')='N'
     AND mrc_tax_dist_flag = 'N'
     AND ref_doc_tax_dist_id IS NULL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
          'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_variance_factors.END',
          'ZX_TRD_INTERNAL_SERVICES_PVT.calc_variance_factors(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_variance_factors',
              p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.calc_variance_factors.END',
             'ZX_TRD_INTERNAL_SERVICES_PVT.calc_variance_factors(-)');
    END IF;

END calc_variance_factors;

/* =====================================================================*
 |  Public Procedures create_mrc_tax_dists creates tax distributions    |
 |   for each reporting currency                                        |
 * =====================================================================*/
PROCEDURE create_mrc_tax_dists (
 p_event_class_rec   IN             zx_api_pub.event_class_rec_type,
 p_rec_nrec_dist_tbl IN OUT NOCOPY  ZX_TRD_SERVICES_PUB_PKG.rec_nrec_dist_tbl_type,
 p_rnd_begin_index   IN             NUMBER,
 p_rnd_end_index     IN OUT NOCOPY  NUMBER,
 p_return_status        OUT NOCOPY  VARCHAR2,
 p_error_buffer         OUT NOCOPY  VARCHAR2) IS

 CURSOR  get_mrc_tax_line_info_csr(
         c_trx_line_id          zx_lines.trx_line_id%TYPE,
         c_trx_level_type       zx_lines.trx_level_type%TYPE,
         c_tax_line_number      zx_lines.tax_line_number%TYPE) IS
  SELECT ledger_id,
         reporting_currency_code,
         currency_conversion_rate,
         currency_conversion_date,
         currency_conversion_type,
         minimum_accountable_unit,
         precision,
         tax_line_id,
         summary_tax_line_id,
         tax_amt
    FROM zx_lines
   WHERE application_id = p_event_class_rec.application_id
     AND entity_code = p_event_class_rec.entity_code
     AND event_class_code = p_event_class_rec.event_class_code
     AND trx_id = p_event_class_rec.trx_id
     AND trx_line_id = c_trx_line_id
     AND trx_level_type = c_trx_level_type
     AND tax_line_number = c_tax_line_number
     AND mrc_tax_line_flag = 'Y';

 l_rnd_begin_index          NUMBER;
 l_end_index                NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.create_mrc_tax_dists.BEGIN',
           'ZX_TRD_INTERNAL_SERVICES_PVT.create_mrc_tax_dists(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_rnd_begin_index IS NULL OR p_rnd_end_index IS NULL OR
     p_rnd_begin_index > p_rnd_end_index THEN

    --p_return_status := FND_API.G_RET_STS_ERROR;
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.create_mrc_tax_dists',
             'begin or end index is null, or begin index > end index');
    END IF;
    RETURN;
  END IF;

  l_end_index := p_rnd_end_index;

  -- create tax distributions in Reporting Currency
  --
  FOR mrc_line_rec IN get_mrc_tax_line_info_csr (
            p_rec_nrec_dist_tbl(p_rnd_begin_index).trx_line_id,
            p_rec_nrec_dist_tbl(p_rnd_begin_index).trx_level_type,
            p_rec_nrec_dist_tbl(p_rnd_begin_index).tax_line_number) LOOP

    l_rnd_begin_index := p_rnd_end_index + 1;

    FOR j IN p_rnd_begin_index .. l_end_index LOOP

      p_rnd_end_index := p_rnd_end_index + 1;
      p_rec_nrec_dist_tbl(p_rnd_end_index) := p_rec_nrec_dist_tbl(j);

      -- set MRC related columns
      --
      SELECT zx_rec_nrec_dist_s.NEXTVAL INTO
             p_rec_nrec_dist_tbl(p_rnd_end_index).rec_nrec_tax_dist_id FROM DUAL;

      p_rec_nrec_dist_tbl(p_rnd_end_index).unrounded_rec_nrec_tax_amt :=
            p_rec_nrec_dist_tbl(j).unrounded_rec_nrec_tax_amt *
                                         mrc_line_rec.currency_conversion_rate;

      p_rec_nrec_dist_tbl(p_rnd_end_index).unrounded_taxable_amt :=
            p_rec_nrec_dist_tbl(j).unrounded_taxable_amt *
                                         mrc_line_rec.currency_conversion_rate;

      p_rec_nrec_dist_tbl(p_rnd_end_index).ledger_id := mrc_line_rec.ledger_id;
      p_rec_nrec_dist_tbl(p_rnd_end_index).currency_conversion_date :=
                                         mrc_line_rec.currency_conversion_date;
      p_rec_nrec_dist_tbl(p_rnd_end_index).currency_conversion_type :=
                                         mrc_line_rec.currency_conversion_type;
      p_rec_nrec_dist_tbl(p_rnd_end_index).currency_conversion_rate :=
                                         mrc_line_rec.currency_conversion_rate;
      p_rec_nrec_dist_tbl(p_rnd_end_index).minimum_accountable_unit :=
                                         mrc_line_rec.minimum_accountable_unit;
      p_rec_nrec_dist_tbl(p_rnd_end_index).precision := mrc_line_rec.precision;
      p_rec_nrec_dist_tbl(p_rnd_end_index).trx_currency_code :=
                                          mrc_line_rec.reporting_currency_code;
      p_rec_nrec_dist_tbl(p_rnd_end_index).tax_line_id :=
                                                      mrc_line_rec.tax_line_id;
      p_rec_nrec_dist_tbl(p_rnd_end_index).summary_tax_line_id :=
                                              mrc_line_rec.summary_tax_line_id;

      p_rec_nrec_dist_tbl(p_rnd_end_index).mrc_tax_dist_flag := 'Y';
      p_rec_nrec_dist_tbl(p_rnd_end_index).mrc_link_to_tax_dist_id :=
                                  p_rec_nrec_dist_tbl(j).rec_nrec_tax_dist_id;

      p_rec_nrec_dist_tbl(p_rnd_end_index).reversed_tax_dist_id := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).rec_nrec_tax_amt_tax_curr := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).rec_nrec_tax_amt_funcl_curr := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).tax_currency_conversion_date := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).tax_currency_conversion_type := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).tax_currency_conversion_rate := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).tax_currency_code := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).taxable_amt_tax_curr := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).taxable_amt_funcl_curr := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).prd_tax_amt := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).prd_tax_amt_tax_curr := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).prd_tax_amt_funcl_curr := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).prd_total_tax_amt := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).prd_total_tax_amt_tax_curr := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).prd_total_tax_amt_funcl_curr := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).func_curr_rounding_adjustment := NULL;

      p_rec_nrec_dist_tbl(p_rnd_end_index).trx_line_dist_tax_amt := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).orig_rec_nrec_rate:= NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).orig_rec_rate_code := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).orig_rec_nrec_tax_amt := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).orig_rec_nrec_tax_amt_tax_curr := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).price_diff := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).qty_diff := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).per_trx_curr_unit_nr_amt := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).ref_per_trx_curr_unit_nr_amt := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).unit_price := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).ref_doc_unit_price := NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).per_unit_nrec_tax_amt:= NULL;
      p_rec_nrec_dist_tbl(p_rnd_end_index).ref_doc_per_unit_nrec_tax_amt := NULL;

    END LOOP;        -- j IN p_rnd_begin_index .. l_end_index LOOP

    ZX_TRD_INTERNAL_SERVICES_PVT.round_rec_nrec_amt(
		p_rec_nrec_dist_tbl,
      		l_rnd_begin_index,
      		p_rnd_end_index,
      		mrc_line_rec.tax_amt,
      		NULL,
      		NULL,
      		p_return_status,
      		p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_SERVICES_PUB_PKG.create_mrc_tax_dists',
                      'After calling ROUND_REC_NREC_AMT p_return_status = '
                       || p_return_status);
  	FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRD_SERVICES_PUB_PKG.create_mrc_tax_dists.END',
                      'ZX_TRD_SERVICES_PUB_PKG.create_mrc_tax_dists(-)');
      END IF;
      RETURN;
    END IF;
  END LOOP;          -- mrc_line_rec IN get_mrc_tax_line_info_csr LOOP

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.create_mrc_tax_dists.END',
           'ZX_TRD_INTERNAL_SERVICES_PVT.create_mrc_tax_dists(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TDS_MRC_PROCESSING_PKG.create_mrc_det_tax_lines',
              sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TRD_INTERNAL_SERVICES_PVT.create_mrc_tax_dists.END',
             'ZX_TRD_INTERNAL_SERVICES_PVT.create_mrc_tax_dists(-)');
    END IF;
END create_mrc_tax_dists;

END ZX_TRD_INTERNAL_SERVICES_PVT;


/
