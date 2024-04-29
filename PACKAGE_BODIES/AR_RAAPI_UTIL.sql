--------------------------------------------------------
--  DDL for Package Body AR_RAAPI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAAPI_UTIL" AS
/*$Header: ARXRAAUB.pls 120.28.12010000.13 2009/05/21 18:12:31 mraymond ship $*/
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  /* 5011151 - global for use_inv_acctg */
  g_use_inv_acctg   VARCHAR2(1);

  FUNCTION use_inv_acctg
    RETURN VARCHAR2
  IS
  BEGIN
    IF g_use_inv_acctg IS NULL
    THEN
       fnd_profile.get( 'AR_USE_INV_ACCT_FOR_CM_FLAG',
                        g_use_inv_acctg);
       IF g_use_inv_acctg IS NULL
       THEN
          g_use_inv_acctg := 'N';
       END IF;
    END IF;
    RETURN g_use_inv_acctg;
  END use_inv_acctg;

  PROCEDURE Constant_System_Values IS

    l_segment_num              NUMBER;
    l_enabled_flag             VARCHAR2(1);

    /* Bug 4675438 - removed all ar_system_parameter related fetches */
    CURSOR c_ar_app_id IS
      SELECT application_id
      FROM fnd_application
      WHERE application_short_name = 'AR';

    CURSOR c_get_category_set IS
      SELECT dcs.category_set_id,
             cs.structure_id
      FROM   mtl_default_category_sets dcs,
             mtl_category_sets cs,
             mfg_lookups ml
      WHERE  ml.lookup_type = 'MTL_FUNCTIONAL_AREAS'
             AND ml.lookup_code = dcs.functional_area_id
             AND dcs.category_set_id = cs.category_set_id
             AND ml.lookup_code = '1';
	     -- bug2117242 "meaning" is translatable column
             -- AND ml.meaning = 'Inventory';

  BEGIN
    arp_util.debug('AR_RAAPI_UTIL.constant_system_values()+');

    OPEN c_ar_app_id;
    FETCH c_ar_app_id INTO g_ar_app_id;
    CLOSE c_ar_app_id;

    /* 5126974 - this was raising an error if MOAC not init'd
        so I moved it to inv_org_id function where it initializes
        on the first call
    oe_profile.get('SO_ORGANIZATION_ID',g_inv_org_id);
    */

    OPEN c_get_category_set;
    FETCH c_get_category_set INTO g_category_set_id, g_category_structure_id;
    CLOSE c_get_category_set;

    g_un_meaning := ARPT_SQL_FUNC_UTIL.get_lookup_meaning
                            (p_lookup_type => 'REV_ADJ_TYPE'
                            ,p_lookup_code => 'UN');
    g_ea_meaning := ARPT_SQL_FUNC_UTIL.get_lookup_meaning
                            (p_lookup_type => 'REV_ADJ_TYPE'
                            ,p_lookup_code => 'EA');
    g_sa_meaning := ARPT_SQL_FUNC_UTIL.get_lookup_meaning
                            (p_lookup_type => 'REV_ADJ_TYPE'
                            ,p_lookup_code => 'SA');
    g_nr_meaning := ARPT_SQL_FUNC_UTIL.get_lookup_meaning
                            (p_lookup_type => 'REV_ADJ_TYPE'
                            ,p_lookup_code => 'NR');
    g_ll_meaning := ARPT_SQL_FUNC_UTIL.get_lookup_meaning
                            (p_lookup_type => 'REV_ADJ_TYPE'
                            ,p_lookup_code => 'LL');

    g_system_cache_flag := 'Y';

  EXCEPTION
    WHEN OTHERS THEN
       arp_util.debug('Unexpected error '||sqlerrm||
                     ' at AR_RAAPI_UTIL.constant_system_values()+');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END Constant_System_Values;

  PROCEDURE Initialize_Globals
  IS
  BEGIN
    g_customer_trx_id          := NULL;
    g_last_customer_trx_id     := NULL;
    g_cust_trx_type_id         := NULL;
    g_trx_date                 := NULL;
    g_invoicing_rule_id        := NULL;
    g_trx_currency             := NULL;
    g_trx_curr_format          := NULL;
    g_exchange_rate            := NULL;
    g_trx_precision            := NULL;
    g_from_salesrep_id         := NULL;
    g_to_salesrep_id           := NULL;
/* BEGIN bug 3067675 */
    g_from_salesgroup_id       := NULL;
    g_to_salesgroup_id         := NULL;
/* END bug 3067675 */
    g_from_category_id         := NULL;
    g_to_category_id           := NULL;
    g_from_inventory_item_id   := NULL;
    g_to_inventory_item_id     := NULL;
    g_from_cust_trx_line_id    := NULL;
    g_to_cust_trx_line_id      := NULL;
    g_gl_date                  := NULL;

    /* Bug 3022420 - initialize arp_global and arp_standard globals to ensure
       the correct set of books is accessed */
    arp_global.init_global;
    /* Bug 5547989 - Pass org id as a parameter to arp_standard.init_standard to set the correct org id */
    arp_standard.init_standard(arp_global.sysparam.org_id);
    /* Change for Bug 5547989 ends */

  END Initialize_Globals;


PROCEDURE Constant_Trx_Values
     (p_customer_trx_id       IN NUMBER)
  IS

    CURSOR c_trx IS
      SELECT t.cust_trx_type_id
            ,t.invoice_currency_code
            ,t.exchange_rate
            ,NVL(c.precision,0) -- Bug 3480443
            ,t.trx_date
            ,t.invoicing_rule_id
      FROM ra_customer_trx t
          ,fnd_currencies c
      WHERE  t.invoice_currency_code = c.currency_code
             AND t.customer_trx_id = p_customer_trx_id;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Constant_Trx_Values()+');
    END IF;

    OPEN c_trx;
    FETCH c_trx INTO g_cust_trx_type_id
                    ,g_trx_currency
                    ,g_exchange_rate
                    ,g_trx_precision
                    ,g_trx_date
                    ,g_invoicing_rule_id;
    CLOSE c_trx;

    g_trx_curr_format := fnd_currency.get_format_mask
                         (currency_code => g_trx_currency, field_length => 18);
    g_trx_curr_format := REPLACE(g_trx_curr_format,'FM');
    g_trx_curr_format := REPLACE(g_trx_curr_format,'PR');

    g_last_customer_trx_id  := p_customer_trx_id;

  EXCEPTION

     WHEN OTHERS then
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Constant_Trx_Values: ' || 'Unexpected error '||sqlerrm||
                     ' at AR_RAAPI_UTIL.constant_system_values()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END Constant_Trx_Values;

  PROCEDURE Validate_Parameters
        (p_init_msg_list       IN VARCHAR2
        ,p_rev_adj_rec         IN OUT NOCOPY AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
        ,p_validation_level    IN NUMBER
        ,x_return_status       IN OUT NOCOPY VARCHAR2
        ,x_msg_count           OUT NOCOPY NUMBER
        ,x_msg_data            OUT NOCOPY VARCHAR2)
  IS
    l_gl_date_valid              DATE;  -- Bug 2146970
  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Validate_Parameters()+');
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    Validate_Transaction (p_init_msg_list    => FND_API.G_FALSE
                         ,p_rev_adj_rec      => p_rev_adj_rec
                         ,p_validation_level => p_validation_level
                         ,x_return_status    => x_return_status
                         ,x_msg_count        => x_msg_count
                         ,x_msg_data         => x_msg_data);
    IF x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
      IF NVL(AR_RAAPI_UTIL.g_last_customer_trx_id,
        AR_RAAPI_UTIL.g_customer_trx_id - 1) <> AR_RAAPI_UTIL.g_customer_trx_id
      THEN
        Constant_Trx_Values(AR_RAAPI_UTIL.g_customer_trx_id);
      END IF;
      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
        Validate_Salesreps (p_init_msg_list    => FND_API.G_FALSE
                           ,p_rev_adj_rec      => p_rev_adj_rec
                           ,x_return_status    => x_return_status
                           ,x_msg_count        => x_msg_count
                           ,x_msg_data         => x_msg_data);
        Validate_Category  (p_init_msg_list    => FND_API.G_FALSE
                           ,p_rev_adj_rec      => p_rev_adj_rec
                           ,x_return_status    => x_return_status
                           ,x_msg_count        => x_msg_count
                           ,x_msg_data         => x_msg_data);
        Validate_Item      (p_init_msg_list    => FND_API.G_FALSE
                           ,p_rev_adj_rec      => p_rev_adj_rec
                           ,x_return_status    => x_return_status
                           ,x_msg_count        => x_msg_count
                           ,x_msg_data         => x_msg_data);
        Validate_Line      (p_init_msg_list    => FND_API.G_FALSE
                           ,p_rev_adj_rec      => p_rev_adj_rec
                           ,x_return_status    => x_return_status
                           ,x_msg_count        => x_msg_count
                           ,x_msg_data         => x_msg_data);

        /* Bug 2146970 - replaced call to procedure with function call */

        /* Bug # 2804660- validate_gl_date should only be called here if
                          no gl date is provided, so that a gl date is
                          defaulted. */

        IF (p_rev_adj_rec.gl_date IS NULL) THEN
          l_gl_date_valid := validate_gl_date(
            p_gl_date => p_rev_adj_rec.gl_date);
          p_rev_adj_rec.gl_date := l_gl_date_valid;
        END IF;

        Validate_Other     (p_init_msg_list    => FND_API.G_FALSE
                           ,p_rev_adj_rec      => p_rev_adj_rec
                           ,x_return_status    => x_return_status
                           ,x_msg_count        => x_msg_count
                           ,x_msg_data         => x_msg_data);
      ELSE
        g_from_salesrep_id       := p_rev_adj_rec.from_salesrep_id;
        g_to_salesrep_id         := p_rev_adj_rec.to_salesrep_id;
/* BEGIN bug 3067675 */
        g_from_salesgroup_id     := p_rev_adj_rec.from_salesgroup_id;
        g_to_salesgroup_id       := p_rev_adj_rec.to_salesgroup_id;
/* END bug 3067675 */
        g_from_category_id       := p_rev_adj_rec.from_category_id;
        g_to_category_id         := p_rev_adj_rec.to_category_id;
        g_from_inventory_item_id := p_rev_adj_rec.from_inventory_item_id;
        g_to_inventory_item_id   := p_rev_adj_rec.to_inventory_item_id;
        g_from_cust_trx_line_id  := p_rev_adj_rec.from_cust_trx_line_id;
        g_to_cust_trx_line_id    := p_rev_adj_rec.to_cust_trx_line_id;
        g_gl_date                := p_rev_adj_rec.gl_date;
      END IF;
    ELSE
      RAISE FND_API.G_EXC_ERROR;

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Unexpected error '||sqlerrm||
                     ' at AR_RAAPI_UTIL.Validate_Parameters()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END Validate_Parameters;

  PROCEDURE Validate_Transaction
        (p_init_msg_list         IN VARCHAR2
        ,p_rev_adj_rec           IN  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
        ,p_validation_level      IN  NUMBER
        ,x_return_status         IN OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2)
  IS
    l_customer_trx_id           NUMBER;
    l_trx_type                  ra_cust_trx_types.type%TYPE;
    l_invoice_total             NUMBER;
    l_cm_total                  NUMBER;
    l_inv_and_cm_total          NUMBER;
    l_prev_trx_id               NUMBER;

    CURSOR c_trx_num IS
      SELECT t.customer_trx_id
      FROM   ra_customer_trx t
            ,ra_batch_sources bs
      WHERE  t.batch_source_id = bs.batch_source_id
      AND    t.trx_number = p_rev_adj_rec.trx_number
      AND    bs.name = NVL(p_rev_adj_rec.batch_source_name,bs.name)
      AND    NVL(t.invoicing_rule_id,0) <> -3
      AND NOT EXISTS (SELECT 'X'
                      FROM   ra_customer_trx_lines l
                      WHERE  l.customer_trx_id = t.customer_trx_id
                      AND    l.line_type = 'LINE'
                      AND    autorule_complete_flag IS NOT NULL);

    CURSOR c_trx_id IS
      SELECT t.customer_trx_id
      FROM   ra_customer_trx t
      WHERE  t.customer_trx_id = p_rev_adj_rec.customer_trx_id
      AND    NVL(t.invoicing_rule_id,0) <> -3
      AND NOT EXISTS (SELECT 'X'
                      FROM   ra_customer_trx_lines l
                      WHERE  l.customer_trx_id = t.customer_trx_id
                      AND    l.line_type = 'LINE'
                      AND    autorule_complete_flag IS NOT NULL);

    CURSOR c_trx_type IS
    SELECT tt.type,
           t.previous_customer_trx_id
    FROM   ra_cust_trx_types tt,
           ra_customer_trx t
    WHERE  tt.cust_trx_type_id = t.cust_trx_type_id
    AND    t.customer_trx_id = g_customer_trx_id;

    CURSOR c_invoice_total IS
    SELECT SUM(l.extended_amount)
    FROM   ra_customer_trx_lines l
    WHERE  l.customer_trx_id = g_customer_trx_id
    AND    l.line_type = 'LINE';

    CURSOR c_cm_total IS
    SELECT sum(l.extended_amount)
    FROM   ra_customer_trx_lines l,
           ra_cust_trx_types tt,
           ra_customer_trx cm
    WHERE  l.customer_trx_id =  cm.customer_trx_id
    AND    cm.cust_trx_type_id = tt.cust_trx_type_id
    AND    l.line_type = 'LINE'
    AND    tt.type = 'CM'
    AND    cm.previous_customer_trx_id = g_customer_trx_id;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Validate_Transaction()+');
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
    THEN
      --
      -- Verify the transaction ID
      --
      IF p_rev_adj_rec.customer_trx_id IS NULL
      THEN
        IF p_rev_adj_rec.trx_number IS NOT NULL
        THEN
          OPEN c_trx_num;
          FETCH c_trx_num INTO g_customer_trx_id;
          IF c_trx_num%NOTFOUND
          THEN
            FND_MESSAGE.set_name (application => 'AR',
                                  name => 'AR_RA_TRX_NOTFOUND');
            FND_MESSAGE.set_token('TRX_NUMBER',p_rev_adj_rec.trx_number);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          ELSE
            FETCH c_trx_num INTO l_customer_trx_id;
            IF c_trx_num%FOUND
            THEN
              g_customer_trx_id := NULL;
              FND_MESSAGE.set_name (application => 'AR',
                                    name => 'AR_RA_TRX_TOO_MANY_ROWS');
              FND_MESSAGE.set_token('TRX_NUMBER',p_rev_adj_rec.trx_number);
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;
          END IF;
          CLOSE c_trx_num;
        ELSE
          FND_MESSAGE.set_name (application => 'AR',
                                name => 'AR_RA_NO_TRX_NUMBER');
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;
      ELSE
        OPEN c_trx_id;
        FETCH c_trx_id INTO g_customer_trx_id;
        IF c_trx_id%NOTFOUND
        THEN
          FND_MESSAGE.set_name (application => 'AR',
                                name => 'AR_TAPI_TRANS_NOT_EXIST');
          FND_MESSAGE.set_token('CUSTOMER_TRX_ID',p_rev_adj_rec.customer_trx_id);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;
        CLOSE c_trx_id;
      END IF;
    ELSE
      g_customer_trx_id := p_rev_adj_rec.customer_trx_id;
    END IF;
    OPEN c_trx_type;
    FETCH c_trx_type INTO l_trx_type, l_prev_trx_id;
    CLOSE c_trx_type;
    IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL AND
        g_customer_trx_id IS NOT NULL)
    THEN
      IF l_trx_type = 'CB'
      THEN
        FND_MESSAGE.set_name('AR','AR_RA_CB_DISALLOWED');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
      END IF;
      -- Bug # 4096889
      -- ORASHID
      --      IF l_trx_type = 'DM'
      --      THEN
      --        FND_MESSAGE.set_name('AR','AR_RA_DM_DISALLOWED');
      --        FND_MSG_PUB.Add;
      --        x_return_status := FND_API.G_RET_STS_ERROR ;
      --      END IF;
      IF l_trx_type = 'BR'
      THEN
        FND_MESSAGE.set_name('AR','AR_RA_BR_DISALLOWED');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
      END IF;
      -- Bug # 4096889
      -- ORASHID
      --      IF l_trx_type = 'DEP'
      --      THEN
      --        FND_MESSAGE.set_name('AR','AR_RA_DEP_DISALLOWED');
      --        FND_MSG_PUB.Add;
      --        x_return_status := FND_API.G_RET_STS_ERROR ;
      --      END IF;
      IF l_trx_type = 'GUAR'
      THEN
        FND_MESSAGE.set_name('AR','AR_RA_GUAR_DISALLOWED');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
      END IF;
      /* 5011151 - Only allow revenue adjustments on
         credit memos if they are on-account or use_inv_acct=N  */
      IF l_trx_type = 'CM' AND
         l_prev_trx_id IS NOT NULL
      THEN
        /* Check invoice accounting profile and
            raise error if it is Y */
        IF use_inv_acctg = 'Y'
        THEN
           /* raise error */
           FND_MESSAGE.set_name('AR','AR_RA_CM_DISALLOWED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;
    END IF;
    -- Bug # 4096889
    -- ORASHID
    IF l_trx_type IN ('INV', 'DEP', 'DM')
    THEN
      OPEN c_invoice_total;
      FETCH c_invoice_total INTO l_invoice_total;
      CLOSE c_invoice_total;
      OPEN c_cm_total;
      FETCH c_cm_total INTO l_cm_total;
      CLOSE c_cm_total;

      l_inv_and_cm_total := l_invoice_total + l_cm_total;
      IF l_invoice_total <> l_inv_and_cm_total
      THEN
        IF l_inv_and_cm_total = 0
        THEN
          /* 5011151 - Remove this error, we now handle the
              credit amounts inside the adj code so there is no
              reason to overtly prevent adjustments  */
          --
          -- Fully credit memo'd so raise an error
          --
          FND_MESSAGE.set_name ('AR','AR_RA_FULL_CREDIT');
          FND_MSG_PUB.Add;
        ELSE
          --
          -- Partially credit memo'd so raise a warning only
          --
          FND_MESSAGE.set_name ('AR','AR_RA_PARTIAL_CREDIT');
          FND_MSG_PUB.Add;
        END IF;
      END IF;
    END IF;
    FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  EXCEPTION
     WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Transaction: ' || 'Unexpected error '||sqlerrm||
                  ' at AR_RAAPI_UTIL.Validate_Transaction()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Validate_Transaction;


  PROCEDURE Validate_Salesreps
     (p_init_msg_list          IN  VARCHAR2
     ,p_rev_adj_rec            IN  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,x_return_status          IN OUT NOCOPY VARCHAR2
     ,x_msg_count              OUT NOCOPY NUMBER
     ,x_msg_data               OUT NOCOPY VARCHAR2)
  IS
    l_sales_credit_total       NUMBER;
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
 l_org_id                   NUMBER;
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
--end anuj

/* BEGIN bug 3067675 */
    l_rep_group_changed        BOOLEAN := FALSE;
    l_group_start_date         DATE;
    l_group_end_date           DATE;
/* END bug 3067675 */

    CURSOR c_salesrep_num (p_salesrep_number VARCHAR2) IS
      SELECT salesrep_id
      FROM   ra_salesreps
      WHERE  salesrep_number = p_salesrep_number
      AND SYSDATE BETWEEN NVL(start_date_active,SYSDATE)
                      AND NVL(end_date_active,SYSDATE)
      AND g_trx_date BETWEEN NVL(start_date_active,g_trx_date)
                         AND NVL(end_date_active,g_trx_date) ;

    CURSOR c_salesrep_id (p_salesrep_id NUMBER) IS
      SELECT salesrep_id
      FROM   ra_salesreps
      WHERE  salesrep_id = p_salesrep_id
      AND SYSDATE BETWEEN NVL(start_date_active,SYSDATE)
                      AND NVL(end_date_active,SYSDATE)
      AND g_trx_date BETWEEN NVL(start_date_active,g_trx_date)
                         AND NVL(end_date_active,g_trx_date) ;

/* BEGIN bug 3067675 */
    CURSOR c_salesgroup_id (p_salesgroup_id NUMBER) IS
      SELECT grp.group_id group_id
      FROM   jtf_rs_group_members mem, jtf_rs_groups_b grp,
             jtf_rs_salesreps srp, jtf_rs_group_usages usg,
             jtf_rs_role_relations rrl
      WHERE  srp.resource_id = mem.resource_id
      AND mem.group_id = grp.group_id
      AND mem.group_id = usg.group_id
      AND usg.usage = 'SALES'
      AND mem.delete_flag = 'N'
      AND mem.group_member_id = rrl.role_resource_id
      AND rrl.role_resource_type = 'RS_GROUP_MEMBER'
      AND rrl.delete_flag = 'N'
      AND nvl(rrl.end_date_active, to_date('01/01/4713','MM/DD/RRRR')) >= l_group_start_date
      AND rrl.start_date_active <= l_group_end_date
      AND srp.salesrep_id = g_to_salesrep_id
      AND nvl(srp.org_id, -99) = nvl(arp_standard.sysparm.org_id, -99)
      AND l_group_end_date BETWEEN grp.start_date_active AND nvl(grp.end_date_active, to_date('01/01/4713','MM/DD/RRRR'))
      AND grp.group_id = p_salesgroup_id
      UNION ALL
      SELECT group_id
      FROM jtf_rs_groups_b
      WHERE group_id = -1
      AND group_id = p_salesgroup_id;
/* END bug 3067675 */

    CURSOR c_check_sales_credits IS
      SELECT DECODE(p_rev_adj_rec.sales_credit_type,'N',
            SUM(non_revenue_percent_split), SUM(revenue_percent_split))
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
            ,org_id
/* Multi-Org Access Control Changes for SSA;end;anukumar;11/01/2002*/
--end anuj
      FROM ra_cust_trx_line_salesreps
      WHERE customer_trx_id = g_customer_trx_id
      AND   customer_trx_line_id IS NOT NULL
/* BEGIN bug 3067675 */
      --AND   salesrep_id = g_from_salesrep_id
      --GROUP BY salesrep_id;
      AND   salesrep_id = NVL(g_from_salesrep_id, salesrep_id)
      AND   DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(non_revenue_salesgroup_id, -9999), NVL(revenue_salesgroup_id, -9999)) =
                NVL(g_from_salesgroup_id, DECODE(p_rev_adj_rec.sales_credit_type,'N', NVL(non_revenue_salesgroup_id, -9999), NVL(revenue_salesgroup_id, -9999)))
      GROUP BY  salesrep_id,
		DECODE(p_rev_adj_rec.sales_credit_type,'N', non_revenue_salesgroup_id, revenue_salesgroup_id),
		org_id;
/* END bug 3067675 */

    CURSOR c_line_num (p_line_number NUMBER) IS
      SELECT customer_trx_line_id
      FROM   ra_customer_trx_lines
      WHERE  line_number = p_line_number
      AND    customer_trx_id = g_customer_trx_id
      AND    line_type = 'LINE';

    CURSOR c_line_id (p_line_id NUMBER) IS
      SELECT customer_trx_line_id
      FROM   ra_customer_trx_lines
      WHERE  customer_trx_line_id = p_line_id
      AND    line_type = 'LINE';

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Validate_Salesreps()+');
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    -- Validate from salesrep
    --
    IF g_from_salesrep_id IS NOT NULL AND
       NVL(p_rev_adj_rec.from_salesrep_id,g_from_salesrep_id - 1)
                            = g_from_salesrep_id
    THEN
      --
      -- Don't revalidate if validated previously in this session
      --
      NULL;
    ElSE
      l_rep_group_changed := TRUE; -- bug 3067675
      IF p_rev_adj_rec.adjustment_type <> 'NR'
      THEN
        IF p_rev_adj_rec.from_salesrep_id IS NULL
        THEN
          IF p_rev_adj_rec.from_salesrep_number IS NOT NULL
          THEN
            OPEN c_salesrep_num (p_rev_adj_rec.from_salesrep_number);
            FETCH c_salesrep_num INTO g_from_salesrep_id;
            IF c_salesrep_num%NOTFOUND
            THEN
              /* Bug 2157246 - shortened message */
              /* Bug 2191739 - call to message API for degovtized message */
              FND_MESSAGE.set_name
                      (application => 'AR',
                       name => gl_public_sector.get_message_name
                               (p_message_name => 'AR_RA_INVALID_SALESREP_NUM',
                                p_app_short_name => 'AR'));
              FND_MESSAGE.set_token('SALESREP_NUMBER',
                                    p_rev_adj_rec.from_salesrep_number);
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;
            CLOSE c_salesrep_num;
          END IF;
        ELSE
          OPEN c_salesrep_id(p_rev_adj_rec.from_salesrep_id);
          FETCH c_salesrep_id INTO g_from_salesrep_id;
          IF c_salesrep_id%NOTFOUND
          THEN
            FND_MESSAGE.set_name (application => 'AR',
                                  name => 'AR_TAPI_INVALID_SALESREP_ID');
            FND_MESSAGE.set_token('SALESREP_ID',
                                  p_rev_adj_rec.from_salesrep_id);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
          CLOSE c_salesrep_id;
        END IF;
      END IF;

/* BEGIN bug 3067675 */
    END IF;

    --
    -- Validate from salesgroup
    --
    IF g_from_salesgroup_id IS NOT NULL AND
       NVL(p_rev_adj_rec.from_salesgroup_id,g_from_salesgroup_id - 1)
                            = g_from_salesgroup_id
    THEN
      --
      -- Don't revalidate if validated previously in this session
      --
      NULL;
    ElSE
      l_rep_group_changed := TRUE;
      IF p_rev_adj_rec.adjustment_type <> 'NR'
      THEN
        IF p_rev_adj_rec.from_salesgroup_id IS NOT NULL
        THEN
          g_from_salesgroup_id := p_rev_adj_rec.from_salesgroup_id;
        END IF;
      END IF;
    END IF;

      IF ((l_rep_group_changed) AND ((g_from_salesrep_id IS NOT NULL) OR (g_from_salesgroup_id IS NOT NULL)))
      --IF g_from_salesrep_id IS NOT NULL
/* END bug 3067675 */

      THEN
        --
        --  Check from salesrep,salesgroup has existing sales credits on the transaction
        --
        OPEN c_check_sales_credits;
        FETCH c_check_sales_credits INTO l_sales_credit_total
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
               ,l_org_id;
/* Multi-Org Access Control Changes for SSA;end;anukumar;11/01/2002*/
--end anuj


        CLOSE c_check_sales_credits;
        IF NVL(l_sales_credit_total,0) = 0
        THEN
          /* Bug 2191739 - call to message API for degovtized message */
          FND_MESSAGE.set_name
                  (application => 'AR',
                   name => gl_public_sector.get_message_name
                           (p_message_name => 'AR_RA_SALESREP_NOT_ON_TRX',
                            p_app_short_name => 'AR'));
          FND_MESSAGE.set_token('SALESREP_NAME',
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
       -- ARPT_SQL_FUNC_UTIL.get_salesrep_name_number(g_from_salesrep_id,'NAME'));
        ARPT_SQL_FUNC_UTIL.get_salesrep_name_number(g_from_salesrep_id,'NAME',l_org_id));
/* Multi-Org Access Control Changes for SSA;end;anukumar;11/01/2002*/
--end anuj
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;
      END IF;
    --END IF; -- commented for bug 3067675
    --
    -- Validate To salesrep
    --
    IF g_to_salesrep_id IS NOT NULL AND
       NVL(p_rev_adj_rec.to_salesrep_id,g_to_salesrep_id - 1) = g_to_salesrep_id
    THEN
      --
      -- Don't revalidate if validated previously in this session
      --
      NULL;
    ELSE
      IF p_rev_adj_rec.adjustment_type IN ('NR','SA')
      THEN
        IF p_rev_adj_rec.to_salesrep_id IS NULL
        THEN
          IF p_rev_adj_rec.to_salesrep_number IS NULL
          THEN
            /* Bug 2191739 - call to message API for degovtized message */
            FND_MESSAGE.set_name
                  (application => 'AR',
                   name => gl_public_sector.get_message_name
                           (p_message_name => 'AR_RA_NO_TO_SALESREP',
                            p_app_short_name => 'AR'));
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          ELSE
            OPEN c_salesrep_num (p_rev_adj_rec.to_salesrep_number);
            FETCH c_salesrep_num INTO g_to_salesrep_id;
            IF c_salesrep_num%NOTFOUND
            THEN
              /* Bug 2157246 - shortened message */
              /* Bug 2191739 - call to message API for degovtized message */
              FND_MESSAGE.set_name
                      (application => 'AR',
                       name => gl_public_sector.get_message_name
                               (p_message_name => 'AR_RA_INVALID_SALESREP_NUM',
                                p_app_short_name => 'AR'));
              FND_MESSAGE.set_token('SALESREP_NUMBER',
                                    p_rev_adj_rec.to_salesrep_number);
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;
            CLOSE c_salesrep_num;
          END IF;
        ELSE
          OPEN c_salesrep_id(p_rev_adj_rec.to_salesrep_id);
          FETCH c_salesrep_id INTO g_to_salesrep_id;
          IF c_salesrep_id%NOTFOUND
          THEN
            FND_MESSAGE.set_name (application => 'AR',
                                  name => 'AR_TAPI_INVALID_SALESREP_ID');
            FND_MESSAGE.set_token('SALESREP_ID',
                                  p_rev_adj_rec.to_salesrep_id);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
          CLOSE c_salesrep_id;
        END IF;
      END IF;
    END IF;

/* BEGIN bug 3067675 */
    --
    -- Validate To salesgroup
    --
    IF g_to_salesgroup_id IS NOT NULL AND
       NVL(p_rev_adj_rec.to_salesgroup_id,g_to_salesgroup_id - 1) = g_to_salesgroup_id
    THEN
      --
      -- Don't revalidate if validated previously in this session
      --
      NULL;
    ELSE
      IF p_rev_adj_rec.adjustment_type IN ('NR','SA')
      THEN
        IF p_rev_adj_rec.to_salesgroup_id IS NOT NULL
        THEN
          arp_util.Get_Txn_Start_End_Dates(p_rev_adj_rec.customer_trx_id, l_group_start_date, l_group_end_date);
          OPEN c_salesgroup_id(p_rev_adj_rec.to_salesgroup_id);
          FETCH c_salesgroup_id INTO g_to_salesgroup_id;
          IF c_salesgroup_id%NOTFOUND
          THEN
            FND_MESSAGE.set_name (application => 'AR',
                                  name => 'AR_INVALID_SALESGROUP_ID');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
          CLOSE c_salesgroup_id;
        END IF;
      END IF;
    END IF;
/* END bug 3067675 */

    FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  EXCEPTION
     WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Salesreps: ' || 'Unexpected error '||sqlerrm||
                  ' at AR_RAAPI_UTIL.Validate_Salesreps()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Validate_Salesreps;

  PROCEDURE Validate_Category
     (p_init_msg_list          IN  VARCHAR2
     ,p_rev_adj_rec            IN  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,x_return_status          IN OUT NOCOPY VARCHAR2
     ,x_msg_count              OUT NOCOPY NUMBER
     ,x_msg_data               OUT NOCOPY VARCHAR2)
  IS

    l_segment_rec              Segment_Rec_Type;
    l_cat_count                NUMBER;

    /* Bug 2157246 - replaced CHR(0) with FND_API.G_MISS_CHAR */
    CURSOR c_category_segs (p_segment_rec Segment_Rec_Type) IS
      SELECT category_id
      FROM   mtl_categories_vl
      WHERE  NVL(segment1,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment1,FND_API.G_MISS_CHAR)
      AND    NVL(segment2,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment2,FND_API.G_MISS_CHAR)
      AND    NVL(segment3,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment3,FND_API.G_MISS_CHAR)
      AND    NVL(segment4,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment4,FND_API.G_MISS_CHAR)
      AND    NVL(segment5,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment5,FND_API.G_MISS_CHAR)
      AND    NVL(segment6,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment6,FND_API.G_MISS_CHAR)
      AND    NVL(segment7,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment7,FND_API.G_MISS_CHAR)
      AND    NVL(segment8,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment8,FND_API.G_MISS_CHAR)
      AND    NVL(segment9,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment9,FND_API.G_MISS_CHAR)
      AND    NVL(segment10,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment10,FND_API.G_MISS_CHAR)
      AND    NVL(segment11,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment11,FND_API.G_MISS_CHAR)
      AND    NVL(segment12,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment12,FND_API.G_MISS_CHAR)
      AND    NVL(segment13,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment13,FND_API.G_MISS_CHAR)
      AND    NVL(segment14,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment14,FND_API.G_MISS_CHAR)
      AND    NVL(segment15,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment15,FND_API.G_MISS_CHAR)
      AND    NVL(segment16,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment16,FND_API.G_MISS_CHAR)
      AND    NVL(segment17,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment17,FND_API.G_MISS_CHAR)
      AND    NVL(segment18,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment18,FND_API.G_MISS_CHAR)
      AND    NVL(segment19,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment19,FND_API.G_MISS_CHAR)
      AND    NVL(segment20,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment20,FND_API.G_MISS_CHAR)
      AND    structure_id = g_category_structure_id;

    CURSOR c_category_id(p_category_id NUMBER) IS
      SELECT category_id
      FROM   mtl_categories_vl
      WHERE  category_id = p_category_id
      AND    structure_id = g_category_structure_id;

    CURSOR c_cat_exists_on_trx(p_category_id NUMBER) IS
      SELECT COUNT(*)
      FROM   mtl_item_categories c,
             ra_customer_trx_lines l
      WHERE  c.inventory_item_id = l.inventory_item_id
      AND    l.customer_trx_id = g_customer_trx_id
      AND    c.category_id = p_category_id
      AND    l.line_type = 'LINE'
      AND    c.category_set_id = g_category_set_id
      AND    c.organization_id = g_inv_org_id;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Validate_Category()+');
    END IF;

    /* 5126974 - move initialization to this function
        to avoid org-specific failure in constant_system_values */
    IF g_inv_org_id IS NULL
    THEN
       oe_profile.get('SO_ORGANIZATION_ID',g_inv_org_id);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    -- Validate category
    --
    IF g_from_category_id IS NOT NULL AND
       NVL(p_rev_adj_rec.from_category_id,g_from_category_id - 1)
                                        = g_from_category_id
    THEN
      --
      -- Don't revalidate if validated previously in this session
      --
      NULL;
    ELSE
      IF p_rev_adj_rec.from_category_id IS NULL
      THEN
        IF (p_rev_adj_rec.from_category_segment1 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment2 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment3 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment4 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment5 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment6 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment7 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment8 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment9 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment10 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment11 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment12 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment13 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment14 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment15 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment16 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment17 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment18 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment19 IS NOT NULL OR
            p_rev_adj_rec.from_category_segment20 IS NOT NULL)
        THEN
          l_segment_rec.segment1 := p_rev_adj_rec.from_category_segment1;
          l_segment_rec.segment2 := p_rev_adj_rec.from_category_segment2;
          l_segment_rec.segment3 := p_rev_adj_rec.from_category_segment3;
          l_segment_rec.segment4 := p_rev_adj_rec.from_category_segment4;
          l_segment_rec.segment5 := p_rev_adj_rec.from_category_segment5;
          l_segment_rec.segment6 := p_rev_adj_rec.from_category_segment6;
          l_segment_rec.segment7 := p_rev_adj_rec.from_category_segment7;
          l_segment_rec.segment8 := p_rev_adj_rec.from_category_segment8;
          l_segment_rec.segment9 := p_rev_adj_rec.from_category_segment9;
          l_segment_rec.segment10 := p_rev_adj_rec.from_category_segment10;
          l_segment_rec.segment11 := p_rev_adj_rec.from_category_segment11;
          l_segment_rec.segment12 := p_rev_adj_rec.from_category_segment12;
          l_segment_rec.segment13 := p_rev_adj_rec.from_category_segment13;
          l_segment_rec.segment14 := p_rev_adj_rec.from_category_segment14;
          l_segment_rec.segment15 := p_rev_adj_rec.from_category_segment15;
          l_segment_rec.segment16 := p_rev_adj_rec.from_category_segment16;
          l_segment_rec.segment17 := p_rev_adj_rec.from_category_segment17;
          l_segment_rec.segment18 := p_rev_adj_rec.from_category_segment18;
          l_segment_rec.segment19 := p_rev_adj_rec.from_category_segment19;
          l_segment_rec.segment20 := p_rev_adj_rec.from_category_segment20;
          OPEN c_category_segs(l_segment_rec);
          FETCH c_category_segs INTO g_from_category_id;
          IF c_category_segs%NOTFOUND
          THEN
            FND_MESSAGE.set_name (application => 'AR',
                                  name => 'AR_RA_INVALID_CAT_SEGMENTS');
            FND_MESSAGE.set_token('CONCAT_SEGS', l_segment_rec.segment1||
              l_segment_rec.segment2||l_segment_rec.segment3||
              l_segment_rec.segment4||l_segment_rec.segment5||
              l_segment_rec.segment6||l_segment_rec.segment7||
              l_segment_rec.segment8||l_segment_rec.segment9||
              l_segment_rec.segment10||l_segment_rec.segment11||
              l_segment_rec.segment12||l_segment_rec.segment13||
              l_segment_rec.segment14||l_segment_rec.segment15||
              l_segment_rec.segment16||l_segment_rec.segment17||
              l_segment_rec.segment18||l_segment_rec.segment19||
              l_segment_rec.segment20);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
          CLOSE c_category_segs;
        ELSIF p_rev_adj_rec.line_selection_mode = 'C'
        THEN
          FND_MESSAGE.set_name (application => 'AR',
                                name => 'AR_RA_NO_FROM_CATEGORY');
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;
      ELSE
        OPEN c_category_id(p_rev_adj_rec.from_category_id);
        FETCH c_category_id INTO g_from_category_id;
        IF c_category_id%NOTFOUND
        THEN
          FND_MESSAGE.set_name (application => 'AR',
                                name => 'AR_RA_INVALID_CATEGORY_ID');
          FND_MESSAGE.set_token('CATEGORY_ID', p_rev_adj_rec.from_category_id);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;
        CLOSE c_category_id;
      END IF;
      IF g_from_category_id IS NOT NULL
      THEN
        OPEN c_cat_exists_on_trx(g_from_category_id);
        FETCH c_cat_exists_on_trx INTO l_cat_count;
        CLOSE c_cat_exists_on_trx;
        IF l_cat_count = 0
        THEN
          FND_MESSAGE.set_name (application => 'AR',
                                name => 'AR_RA_CATEGORY_NOT_ON_TRX');
          FND_MESSAGE.set_token('CATEGORY_ID', p_rev_adj_rec.from_category_id);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;
      END IF;
    END IF;
      --
      -- Validate to category if line transfer
      --
    IF g_to_category_id IS NOT NULL AND
       NVL(p_rev_adj_rec.to_category_id,g_to_category_id - 1) = g_to_category_id
    THEN
      --
      -- Don't revalidate if validated previously in this session
      --
      NULL;
    ELSE
      IF p_rev_adj_rec.adjustment_type = 'LL' AND
         p_rev_adj_rec.line_selection_mode = 'C'
      THEN
        IF p_rev_adj_rec.to_category_id IS NULL
        THEN
          IF (p_rev_adj_rec.to_category_segment1 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment2 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment3 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment4 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment5 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment6 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment7 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment8 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment9 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment10 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment11 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment12 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment13 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment14 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment15 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment16 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment17 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment18 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment19 IS NOT NULL OR
              p_rev_adj_rec.to_category_segment20 IS NOT NULL)
          THEN
            l_segment_rec.segment1 := p_rev_adj_rec.to_category_segment1;
            l_segment_rec.segment2 := p_rev_adj_rec.to_category_segment2;
            l_segment_rec.segment3 := p_rev_adj_rec.to_category_segment3;
            l_segment_rec.segment4 := p_rev_adj_rec.to_category_segment4;
            l_segment_rec.segment5 := p_rev_adj_rec.to_category_segment5;
            l_segment_rec.segment6 := p_rev_adj_rec.to_category_segment6;
            l_segment_rec.segment7 := p_rev_adj_rec.to_category_segment7;
            l_segment_rec.segment8 := p_rev_adj_rec.to_category_segment8;
            l_segment_rec.segment9 := p_rev_adj_rec.to_category_segment9;
            l_segment_rec.segment10 := p_rev_adj_rec.to_category_segment10;
            l_segment_rec.segment11 := p_rev_adj_rec.to_category_segment11;
            l_segment_rec.segment12 := p_rev_adj_rec.to_category_segment12;
            l_segment_rec.segment13 := p_rev_adj_rec.to_category_segment13;
            l_segment_rec.segment14 := p_rev_adj_rec.to_category_segment14;
            l_segment_rec.segment15 := p_rev_adj_rec.to_category_segment15;
            l_segment_rec.segment16 := p_rev_adj_rec.to_category_segment16;
            l_segment_rec.segment17 := p_rev_adj_rec.to_category_segment17;
            l_segment_rec.segment18 := p_rev_adj_rec.to_category_segment18;
            l_segment_rec.segment19 := p_rev_adj_rec.to_category_segment19;
            l_segment_rec.segment20 := p_rev_adj_rec.to_category_segment20;
            OPEN c_category_segs(l_segment_rec);
            FETCH c_category_segs INTO g_to_category_id;
            IF c_category_segs%NOTFOUND
            THEN
              FND_MESSAGE.set_name (application => 'AR',
                                    name => 'AR_RA_INVALID_CAT_SEGMENTS');
              FND_MESSAGE.set_token('CONCAT_SEGS', l_segment_rec.segment1||
                l_segment_rec.segment2||l_segment_rec.segment3||
                l_segment_rec.segment4||l_segment_rec.segment5||
                l_segment_rec.segment6||l_segment_rec.segment7||
                l_segment_rec.segment8||l_segment_rec.segment9||
                l_segment_rec.segment10||l_segment_rec.segment11||
                l_segment_rec.segment12||l_segment_rec.segment13||
                l_segment_rec.segment14||l_segment_rec.segment15||
                l_segment_rec.segment16||l_segment_rec.segment17||
                l_segment_rec.segment18||l_segment_rec.segment19||
                l_segment_rec.segment20);
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;
            CLOSE c_category_segs;
          ELSE
            FND_MESSAGE.set_name (application => 'AR',
                                  name => 'AR_RA_NO_TO_CATEGORY');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
        ELSE
          OPEN c_category_id(p_rev_adj_rec.to_category_id);
          FETCH c_category_id INTO g_to_category_id;
          IF c_category_id%NOTFOUND
          THEN
            FND_MESSAGE.set_name (application => 'AR',
                                  name => 'AR_RA_INVALID_CATEGORY_ID');
            FND_MESSAGE.set_token('CATEGORY_ID', p_rev_adj_rec.to_category_id);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
          CLOSE c_category_id;
        END IF;
        IF g_to_category_id IS NOT NULL
        THEN
          OPEN c_cat_exists_on_trx(g_to_category_id);
          FETCH c_cat_exists_on_trx INTO l_cat_count;
          CLOSE c_cat_exists_on_trx;
          IF l_cat_count = 0
          THEN
            FND_MESSAGE.set_name (application => 'AR',
                                  name => 'AR_RA_CATEGORY_NOT_ON_TRX');
            FND_MESSAGE.set_token('CATEGORY_ID', p_rev_adj_rec.to_category_id);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
        END IF;
      END IF;
    END IF;
    FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      FND_MESSAGE.set_name (application => 'AR',
                            name => 'AR_RA_INVALID_CAT_SEGMENTS');
      FND_MESSAGE.set_token('CONCAT_SEGS', l_segment_rec.segment1||
        l_segment_rec.segment2||l_segment_rec.segment3||
        l_segment_rec.segment4||l_segment_rec.segment5||
        l_segment_rec.segment6||l_segment_rec.segment7||
        l_segment_rec.segment8||l_segment_rec.segment9||
        l_segment_rec.segment10||l_segment_rec.segment11||
        l_segment_rec.segment12||l_segment_rec.segment13||
        l_segment_rec.segment14||l_segment_rec.segment15||
        l_segment_rec.segment16||l_segment_rec.segment17||
        l_segment_rec.segment18||l_segment_rec.segment19||
        l_segment_rec.segment20);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Category: ' || 'Unexpected error '||sqlerrm||
                  ' at AR_RAAPI_UTIL.Validate_Category()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Validate_Category;

  PROCEDURE Validate_Item
     (p_init_msg_list          IN  VARCHAR2
     ,p_rev_adj_rec            IN  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,x_return_status          IN OUT NOCOPY VARCHAR2
     ,x_msg_count              OUT NOCOPY NUMBER
     ,x_msg_data               OUT NOCOPY VARCHAR2)
  IS

    l_segment_rec              Segment_Rec_Type;
    l_item_count               NUMBER;

    /* Bug 2157246 - replaced CHR(0) with FND_API.G_MISS_CHAR */
    CURSOR c_item_segs (p_segment_rec Segment_Rec_Type) IS
      SELECT inventory_item_id
      FROM   mtl_system_items
      WHERE  NVL(segment1,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment1,FND_API.G_MISS_CHAR)
      AND    NVL(segment2,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment2,FND_API.G_MISS_CHAR)
      AND    NVL(segment3,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment3,FND_API.G_MISS_CHAR)
      AND    NVL(segment4,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment4,FND_API.G_MISS_CHAR)
      AND    NVL(segment5,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment5,FND_API.G_MISS_CHAR)
      AND    NVL(segment6,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment6,FND_API.G_MISS_CHAR)
      AND    NVL(segment7,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment7,FND_API.G_MISS_CHAR)
      AND    NVL(segment8,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment8,FND_API.G_MISS_CHAR)
      AND    NVL(segment9,FND_API.G_MISS_CHAR) =  NVL(p_segment_rec.segment9,FND_API.G_MISS_CHAR)
      AND    NVL(segment10,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment10,FND_API.G_MISS_CHAR)
      AND    NVL(segment11,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment11,FND_API.G_MISS_CHAR)
      AND    NVL(segment12,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment12,FND_API.G_MISS_CHAR)
      AND    NVL(segment13,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment13,FND_API.G_MISS_CHAR)
      AND    NVL(segment14,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment14,FND_API.G_MISS_CHAR)
      AND    NVL(segment15,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment15,FND_API.G_MISS_CHAR)
      AND    NVL(segment16,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment16,FND_API.G_MISS_CHAR)
      AND    NVL(segment17,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment17,FND_API.G_MISS_CHAR)
      AND    NVL(segment18,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment18,FND_API.G_MISS_CHAR)
      AND    NVL(segment19,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment19,FND_API.G_MISS_CHAR)
      AND    NVL(segment20,FND_API.G_MISS_CHAR) = NVL(p_segment_rec.segment20,FND_API.G_MISS_CHAR)
      AND    organization_id = g_inv_org_id;

    CURSOR c_item_id(p_item_id NUMBER) IS
      SELECT inventory_item_id
      FROM   mtl_system_items
      WHERE  inventory_item_id = p_item_id
      AND    organization_id = g_inv_org_id;

    CURSOR c_item_exists_on_trx(p_item_id NUMBER) IS
      SELECT COUNT(*)
      FROM   ra_customer_trx_lines
      WHERE  customer_trx_id = g_customer_trx_id
      AND    inventory_item_id = p_item_id
      AND    line_type = 'LINE';

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Validate_Item()+');
    END IF;
    /* 5126974 - move initialization to this function
        to avoid org-specific failure in constant_system_values */
    IF g_inv_org_id IS NULL
    THEN
       oe_profile.get('SO_ORGANIZATION_ID',g_inv_org_id);
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    -- Validate from item
    --
    IF g_from_inventory_item_id IS NOT NULL AND
       NVL(p_rev_adj_rec.from_inventory_item_id,g_from_inventory_item_id - 1)
                         = g_from_inventory_item_id
    THEN
      --
      -- Don't revalidate if validated previously in this session
      --
      NULL;
    ELSE
      IF p_rev_adj_rec.from_inventory_item_id IS NULL
      THEN
        IF (p_rev_adj_rec.from_item_segment1 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment2 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment3 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment4 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment5 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment6 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment7 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment8 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment9 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment10 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment11 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment12 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment13 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment14 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment15 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment16 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment17 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment18 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment19 IS NOT NULL OR
            p_rev_adj_rec.from_item_segment20 IS NOT NULL)
        THEN
          l_segment_rec.segment1 := p_rev_adj_rec.from_item_segment1;
          l_segment_rec.segment2 := p_rev_adj_rec.from_item_segment2;
          l_segment_rec.segment3 := p_rev_adj_rec.from_item_segment3;
          l_segment_rec.segment4 := p_rev_adj_rec.from_item_segment4;
          l_segment_rec.segment5 := p_rev_adj_rec.from_item_segment5;
          l_segment_rec.segment6 := p_rev_adj_rec.from_item_segment6;
          l_segment_rec.segment7 := p_rev_adj_rec.from_item_segment7;
          l_segment_rec.segment8 := p_rev_adj_rec.from_item_segment8;
          l_segment_rec.segment9 := p_rev_adj_rec.from_item_segment9;
          l_segment_rec.segment10 := p_rev_adj_rec.from_item_segment10;
          l_segment_rec.segment11 := p_rev_adj_rec.from_item_segment11;
          l_segment_rec.segment12 := p_rev_adj_rec.from_item_segment12;
          l_segment_rec.segment13 := p_rev_adj_rec.from_item_segment13;
          l_segment_rec.segment14 := p_rev_adj_rec.from_item_segment14;
          l_segment_rec.segment15 := p_rev_adj_rec.from_item_segment15;
          l_segment_rec.segment16 := p_rev_adj_rec.from_item_segment16;
          l_segment_rec.segment17 := p_rev_adj_rec.from_item_segment17;
          l_segment_rec.segment18 := p_rev_adj_rec.from_item_segment18;
          l_segment_rec.segment19 := p_rev_adj_rec.from_item_segment19;
          l_segment_rec.segment20 := p_rev_adj_rec.from_item_segment20;
          OPEN c_item_segs(l_segment_rec);
          FETCH c_item_segs INTO g_from_inventory_item_id;
          IF c_item_segs%NOTFOUND
          THEN
            FND_MESSAGE.set_name (application => 'AR',
                                  name => 'AR_RA_INVALID_ITEM_SEGMENTS');
            FND_MESSAGE.set_token('CONCAT_SEGS', l_segment_rec.segment1||
              l_segment_rec.segment2||l_segment_rec.segment3||
              l_segment_rec.segment4||l_segment_rec.segment5||
              l_segment_rec.segment6||l_segment_rec.segment7||
              l_segment_rec.segment8||l_segment_rec.segment9||
              l_segment_rec.segment10||l_segment_rec.segment11||
              l_segment_rec.segment12||l_segment_rec.segment13||
              l_segment_rec.segment14||l_segment_rec.segment15||
              l_segment_rec.segment16||l_segment_rec.segment17||
              l_segment_rec.segment18||l_segment_rec.segment19||
              l_segment_rec.segment20);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
          CLOSE c_item_segs;
        ELSIF p_rev_adj_rec.line_selection_mode = 'I'
        THEN
          FND_MESSAGE.set_name (application => 'AR',
                                name => 'AR_RA_NO_FROM_ITEM');
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;
      ELSE
        OPEN c_item_id(p_rev_adj_rec.from_inventory_item_id);
        FETCH c_item_id INTO g_from_inventory_item_id;
        IF c_item_id%NOTFOUND
        THEN
          FND_MESSAGE.set_name (application => 'AR',
                                name => 'AR_RA_INVALID_ITEM_ID');
          FND_MESSAGE.set_token('ITEM_ID',p_rev_adj_rec.from_inventory_item_id);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;
        close c_item_id;
      END IF;
      IF g_from_inventory_item_id IS NOT NULL
      THEN
        OPEN c_item_exists_on_trx(g_from_inventory_item_id);
        FETCH c_item_exists_on_trx INTO l_item_count;
        CLOSE c_item_exists_on_trx;
        IF l_item_count = 0
        THEN
          FND_MESSAGE.set_name (application => 'AR',
                                name => 'AR_RA_ITEM_NOT_ON_TRX');
          FND_MESSAGE.set_token('ITEM_ID',p_rev_adj_rec.from_inventory_item_id);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;
      END IF;
    END IF;
    --
    -- Validate to item if line transfer
    --
    IF g_to_inventory_item_id IS NOT NULL AND
       NVL(p_rev_adj_rec.to_inventory_item_id,g_to_inventory_item_id - 1)
                            = g_to_inventory_item_id
    THEN
      --
      -- Don't revalidate if validated previously in this session
      --
      NULL;
    ELSE
      IF p_rev_adj_rec.adjustment_type = 'LL' AND
         p_rev_adj_rec.line_selection_mode = 'I'
      THEN
        IF p_rev_adj_rec.to_inventory_item_id IS NULL
        THEN
          IF (p_rev_adj_rec.to_item_segment1 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment2 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment3 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment4 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment5 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment6 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment7 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment8 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment9 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment10 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment11 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment12 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment13 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment14 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment15 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment16 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment17 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment18 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment19 IS NOT NULL OR
              p_rev_adj_rec.to_item_segment20 IS NOT NULL)
          THEN
            l_segment_rec.segment1 := p_rev_adj_rec.to_item_segment1;
            l_segment_rec.segment2 := p_rev_adj_rec.to_item_segment2;
            l_segment_rec.segment3 := p_rev_adj_rec.to_item_segment3;
            l_segment_rec.segment4 := p_rev_adj_rec.to_item_segment4;
            l_segment_rec.segment5 := p_rev_adj_rec.to_item_segment5;
            l_segment_rec.segment6 := p_rev_adj_rec.to_item_segment6;
            l_segment_rec.segment7 := p_rev_adj_rec.to_item_segment7;
            l_segment_rec.segment8 := p_rev_adj_rec.to_item_segment8;
            l_segment_rec.segment9 := p_rev_adj_rec.to_item_segment9;
            l_segment_rec.segment10 := p_rev_adj_rec.to_item_segment10;
            l_segment_rec.segment11 := p_rev_adj_rec.to_item_segment11;
            l_segment_rec.segment12 := p_rev_adj_rec.to_item_segment12;
            l_segment_rec.segment13 := p_rev_adj_rec.to_item_segment13;
            l_segment_rec.segment14 := p_rev_adj_rec.to_item_segment14;
            l_segment_rec.segment15 := p_rev_adj_rec.to_item_segment15;
            l_segment_rec.segment16 := p_rev_adj_rec.to_item_segment16;
            l_segment_rec.segment17 := p_rev_adj_rec.to_item_segment17;
            l_segment_rec.segment18 := p_rev_adj_rec.to_item_segment18;
            l_segment_rec.segment19 := p_rev_adj_rec.to_item_segment19;
            l_segment_rec.segment20 := p_rev_adj_rec.to_item_segment20;
            OPEN c_item_segs(l_segment_rec);
            FETCH c_item_segs INTO g_to_inventory_item_id;
            IF c_item_segs%NOTFOUND
            THEN
              FND_MESSAGE.set_name (application => 'AR',
                                    name => 'AR_RA_INVALID_ITEM_SEGMENTS');
              FND_MESSAGE.set_token('CONCAT_SEGS', l_segment_rec.segment1||
                l_segment_rec.segment2||l_segment_rec.segment3||
                l_segment_rec.segment4||l_segment_rec.segment5||
                l_segment_rec.segment6||l_segment_rec.segment7||
                l_segment_rec.segment8||l_segment_rec.segment9||
                l_segment_rec.segment10||l_segment_rec.segment11||
                l_segment_rec.segment12||l_segment_rec.segment13||
                l_segment_rec.segment14||l_segment_rec.segment15||
                l_segment_rec.segment16||l_segment_rec.segment17||
                l_segment_rec.segment18||l_segment_rec.segment19||
                l_segment_rec.segment20);
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;
            CLOSE c_item_segs;
          ELSE
            FND_MESSAGE.set_name (application => 'AR',
                                  name => 'AR_RA_NO_TO_ITEM');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
        ELSE
          OPEN c_item_id(p_rev_adj_rec.to_inventory_item_id);
          FETCH c_item_id INTO g_to_inventory_item_id;
          IF c_item_id%NOTFOUND
          THEN
            FND_MESSAGE.set_name (application => 'AR',
                                  name => 'AR_RA_INVALID_ITEM_ID');
            FND_MESSAGE.set_token('ITEM_ID',p_rev_adj_rec.to_inventory_item_id);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
          CLOSE c_item_id;
        END IF;
        IF g_to_inventory_item_id IS NOT NULL
        THEN
          OPEN c_item_exists_on_trx(g_to_inventory_item_id);
          FETCH c_item_exists_on_trx INTO l_item_count;
          CLOSE c_item_exists_on_trx;
          IF l_item_count = 0
          THEN
            FND_MESSAGE.set_name (application => 'AR',
                                  name => 'AR_RA_ITEM_NOT_ON_TRX');
            FND_MESSAGE.set_token('ITEM_ID',p_rev_adj_rec.to_inventory_item_id);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
        END IF;
      END IF;
    END IF;
    FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      FND_MESSAGE.set_name (application => 'AR',
                            name => 'AR_RA_INVALID_ITEM_SEGMENTS');
      FND_MESSAGE.set_token('CONCAT_SEGS', l_segment_rec.segment1||
        l_segment_rec.segment2||l_segment_rec.segment3||
        l_segment_rec.segment4||l_segment_rec.segment5||
        l_segment_rec.segment6||l_segment_rec.segment7||
        l_segment_rec.segment8||l_segment_rec.segment9||
        l_segment_rec.segment10||l_segment_rec.segment11||
        l_segment_rec.segment12||l_segment_rec.segment13||
        l_segment_rec.segment14||l_segment_rec.segment15||
        l_segment_rec.segment16||l_segment_rec.segment17||
        l_segment_rec.segment18||l_segment_rec.segment19||
        l_segment_rec.segment20);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Item: ' || 'Unexpected error '||sqlerrm||
                  ' at AR_RAAPI_UTIL.Validate_Item()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Validate_Item;

  PROCEDURE Validate_Line
     (p_init_msg_list          IN  VARCHAR2
     ,p_rev_adj_rec            IN  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,x_return_status          IN OUT NOCOPY VARCHAR2
     ,x_msg_count              OUT NOCOPY NUMBER
     ,x_msg_data               OUT NOCOPY VARCHAR2)
  IS

    CURSOR c_line_num (p_line_number NUMBER) IS
      SELECT customer_trx_line_id
      FROM   ra_customer_trx_lines
      WHERE  line_number = p_line_number
      AND    customer_trx_id = g_customer_trx_id
      AND    line_type = 'LINE';

    CURSOR c_line_id (p_line_id NUMBER) IS
      SELECT customer_trx_line_id
      FROM   ra_customer_trx_lines
      WHERE  customer_trx_line_id = p_line_id
      AND    customer_trx_id = g_customer_trx_id
      AND    line_type = 'LINE';

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Validate_Line()+');
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    -- Validate from line
    --
    IF p_rev_adj_rec.from_cust_trx_line_id IS NULL
    THEN
      IF p_rev_adj_rec.from_line_number IS NOT NULL
      THEN
        OPEN c_line_num(p_rev_adj_rec.from_line_number);
        FETCH c_line_num INTO g_from_cust_trx_line_id;
        IF c_line_num%NOTFOUND
        THEN
          FND_MESSAGE.set_name (application => 'AR',
                                name => 'AR_RA_LINE_NOT_ON_TRX');
          FND_MESSAGE.set_token('LINE_NUMBER', p_rev_adj_rec.from_line_number);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;
        CLOSE c_line_num;
      ELSIF p_rev_adj_rec.line_selection_mode = 'L'
      THEN
        FND_MESSAGE.set_name (application => 'AR',
                              name => 'AR_RA_NO_FROM_LINE');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
      END IF;
    ELSE
      OPEN c_line_id(p_rev_adj_rec.from_cust_trx_line_id);
      FETCH c_line_id INTO g_from_cust_trx_line_id;
      IF c_line_id%NOTFOUND
      THEN
        FND_MESSAGE.set_name (application => 'AR',
                              name => 'AR_RA_INVALID_LINE_ID');
        FND_MESSAGE.set_token('CUST_TRX_LINE_ID',
                                  p_rev_adj_rec.from_cust_trx_line_id);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
      END IF;
      CLOSE c_line_id;
    END IF;

    FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  EXCEPTION
     WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Line: ' || 'Unexpected error '||sqlerrm||
                  ' at AR_RAAPI_UTIL.Validate_Line()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Validate_Line;

  /* Bug 2146970 - changed main in parameter from p_rev_adj_rec to p_gl_date
     and converted from procedure to function */
  FUNCTION Validate_GL_Date
     (p_gl_date                IN DATE)
  RETURN DATE
  IS

    l_gl_date                 DATE;
    l_valid_gl_date           DATE;
    l_default_rule            VARCHAR2(80);
    l_err_mesg                VARCHAR2(2000);

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Validate_GL_Date()+');
    END IF;
--
-- Bug 2030914: need to allow NOT OPENNED periods
--              changed p_allow_not_open_flag from 'N' to 'Y'
--
    l_gl_date := NVL(p_gl_date,SYSDATE);
    l_valid_gl_date := NULL;
    IF ARP_STANDARD.validate_and_default_gl_date
             (gl_date => p_gl_date,
              trx_date => g_trx_date,
              validation_date1 => NULL,
              validation_date2 => NULL,
              validation_date3 => NULL,
              default_date1 => NULL,
              default_date2 => NULL,
              default_date3 => NULL,
              p_allow_not_open_flag   => 'Y',
              p_invoicing_rule_id => g_invoicing_rule_id,
              p_set_of_books_id => arp_global.sysparam.set_of_books_id,
              p_application_id => AR_RAAPI_UTIL.application_id,
              default_gl_date => l_valid_gl_date,
              defaulting_rule_used  => l_default_rule,
              error_message  => l_err_mesg)
    THEN
      IF p_gl_date <> l_valid_gl_date
      THEN
        FND_MESSAGE.set_name('AR','AR_RA_GL_DATE_CHANGED');
        FND_MESSAGE.set_token('GL_DATE',p_gl_date);
        FND_MESSAGE.set_token('NEW_GL_DATE',l_valid_gl_date);
        FND_MSG_PUB.Add;
      END IF;
    END IF;
    RETURN l_valid_gl_date;
  EXCEPTION
     WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_GL_Date: ' || 'Unexpected error '||sqlerrm||
                  ' at AR_RAAPI_UTIL.Validate_GL_Date()+');
       END IF;
       RETURN NULL;
  END Validate_GL_Date;

  FUNCTION bump_gl_date_if_closed
     (p_gl_date                IN DATE)
  RETURN DATE
  IS

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.bump_gl_date_if_closed()+');
    END IF;

    /* Bug 3879222 - replaced proprietary logic with a call to
       arp_auto_rule.assign_gl_date.  That routine caches
       dates and calendar to make for faster returns */
    RETURN arp_auto_rule.assign_gl_date(p_gl_date);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.bump_gl_date_if_closed()-');
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('bump_gl_date_if_closed: ' || 'Unexpected error '||sqlerrm||
                  ' at AR_RAAPI_UTIL.bump_gl_date_if_closed()+');
       END IF;
       RETURN NULL;
  END bump_gl_date_if_closed;

PROCEDURE Validate_Other
     (p_init_msg_list          IN  VARCHAR2
     ,p_rev_adj_rec            IN  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,x_return_status          IN OUT NOCOPY VARCHAR2
     ,x_msg_count              OUT NOCOPY NUMBER
     ,x_msg_data               OUT NOCOPY VARCHAR2)
  IS
    l_meaning                  ar_lookups.meaning%TYPE;
    l_attribute_rec            ar_receipt_api_pub.attribute_rec_type;
    l_df_return_status         VARCHAR2(1);

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Validate_Other()+');
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    IF p_rev_adj_rec.adjustment_type NOT IN ('UN','EA','SA','NR')
--  'LL' temporarily disabled
    THEN
      FND_MESSAGE.set_name (application => 'AR',
                            name => 'AR_RA_INVALID_ADJUST_TYPE');
      FND_MESSAGE.set_token('ADJUST_TYPE', p_rev_adj_rec.adjustment_type);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF;
    IF p_rev_adj_rec.sales_credit_type NOT IN ('R','N','B')
    THEN
      FND_MESSAGE.set_name (application => 'AR',
                            name => 'AR_RA_INVALID_SALESCRED_TYPE');
      FND_MESSAGE.set_token('SALESCRED_TYPE', p_rev_adj_rec.sales_credit_type);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF;
    IF p_rev_adj_rec.amount_mode NOT IN ('T','A','P')
    THEN
      FND_MESSAGE.set_name (application => 'AR',
                            name => 'AR_RA_INVALID_AMOUNT_MODE');
      FND_MESSAGE.set_token('AMOUNT_MODE', p_rev_adj_rec.amount_mode);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF;
    IF p_rev_adj_rec.line_selection_mode NOT IN ('A','C','I','S')
    THEN
      FND_MESSAGE.set_name (application => 'AR',
                            name => 'AR_RA_INVALID_LINE_MODE');
      FND_MESSAGE.set_token('LINE_MODE', p_rev_adj_rec.line_selection_mode);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF;
    IF AR_Revenue_Adjustment_PVT.g_update_db_flag = 'Y'
    THEN
      /* Bug 4304865 - separate lookup for sales credit adjustments */
      IF p_rev_adj_rec.adjustment_type IN ('SA','NR') THEN
         l_meaning := ARPT_SQL_FUNC_UTIL.get_lookup_meaning
                              (p_lookup_type => 'SALESCRED_ADJ_REASON'
                              ,p_lookup_code => p_rev_adj_rec.reason_code);
      ELSE
         l_meaning := ARPT_SQL_FUNC_UTIL.get_lookup_meaning
                              (p_lookup_type => 'REV_ADJ_REASON'
                              ,p_lookup_code => p_rev_adj_rec.reason_code);
      END IF;
      IF l_meaning IS NULL
      THEN
        /* Bug 2312077 - incorrect message replaced */
        FND_MESSAGE.set_name (application => 'AR',
                              name => 'AR_RA_INVALID_REASON');
        FND_MESSAGE.set_token('REASON_CODE', p_rev_adj_rec.reason_code);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
      END IF;
    END IF;

    --
    -- Validate and default the dff attributes
    --
    l_attribute_rec.attribute1     := p_rev_adj_rec.attribute1;
    l_attribute_rec.attribute2     := p_rev_adj_rec.attribute2;
    l_attribute_rec.attribute3     := p_rev_adj_rec.attribute3;
    l_attribute_rec.attribute4     := p_rev_adj_rec.attribute4;
    l_attribute_rec.attribute5     := p_rev_adj_rec.attribute5;
    l_attribute_rec.attribute6     := p_rev_adj_rec.attribute6;
    l_attribute_rec.attribute7     := p_rev_adj_rec.attribute7;
    l_attribute_rec.attribute8     := p_rev_adj_rec.attribute8;
    l_attribute_rec.attribute9     := p_rev_adj_rec.attribute9;
    l_attribute_rec.attribute10    := p_rev_adj_rec.attribute10;
    l_attribute_rec.attribute11    := p_rev_adj_rec.attribute11;
    l_attribute_rec.attribute12    := p_rev_adj_rec.attribute12;
    l_attribute_rec.attribute13    := p_rev_adj_rec.attribute13;
    l_attribute_rec.attribute14    := p_rev_adj_rec.attribute14;
    l_attribute_rec.attribute15    := p_rev_adj_rec.attribute15;
    ar_receipt_lib_pvt.Validate_Desc_Flexfield(
                                            l_attribute_rec,
                                            'AR_REVENUE_ADJUSTMENTS',
                                            l_df_return_status
                                            );
    IF NVL(l_df_return_status,FND_API.G_RET_STS_SUCCESS) <>
                                         FND_API.G_RET_STS_SUCCESS
    THEN
      x_return_status := l_df_return_status;
    END IF;
    FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  EXCEPTION
     WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Other: ' || 'Unexpected error '||sqlerrm||
                  ' at AR_RAAPI_UTIL.Validate_Other()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Validate_Other;

  --
  -- Public function to return the cost center for a given salesrep
  --
  FUNCTION Get_Salesrep_Cost_Ctr
    (p_salesrep_id  IN NUMBER)
  RETURN VARCHAR2
  IS
    l_cost_ctr      VARCHAR2(30);
    CURSOR c_cost_ctr IS
      SELECT get_cost_ctr(gl_id_rev)
      FROM   ra_salesreps
      WHERE  salesrep_id = p_salesrep_id;
  BEGIN
    OPEN c_cost_ctr;
    FETCH c_cost_ctr INTO l_cost_ctr;
    CLOSE c_cost_ctr;
    RETURN l_cost_ctr;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_Salesrep_Cost_Ctr;

  --
  -- Public function to return the cost center segment value for a given ccid
  --
  FUNCTION Get_Cost_Ctr
    (p_code_combination_id  IN NUMBER)
  RETURN VARCHAR2
  IS
    /* Bug 4675438: moved from constant_system_values as is dependent on
       MOAC initialization */
    CURSOR c_cost_ctr_segmt IS
      SELECT b.segment_num
      FROM   fnd_segment_attribute_values a ,
             fnd_id_flex_segments b ,
             gl_sets_of_books c
      WHERE  a.id_flex_num = c.chart_of_accounts_id
             AND c.set_of_books_id = arp_global.sysparam.set_of_books_id
             AND a.application_id = 101
             AND a.id_flex_code = 'GL#'
             AND a.attribute_value = 'Y'
             AND a.segment_attribute_type = 'FA_COST_CTR'
             AND a.application_id = b.application_id
             AND a.id_flex_code = b.id_flex_code
             AND a.id_flex_num = b.id_flex_num
             AND a.application_column_name = b.application_column_name
             AND a.id_flex_num = b.id_flex_num
             AND b.enabled_flag = 'Y';
    l_segnum                     NUMBER;
    l_number_of_segs             NUMBER;
    l_segment_array              fnd_flex_ext.segmentarray;
    l_segment_value              VARCHAR2(30);

  BEGIN
    IF NOT fnd_flex_ext.get_segments ('SQLGL'
                                     ,'GL#'
                                     ,arp_global.chart_of_accounts_id
                                     ,p_code_combination_id
                                     ,l_number_of_segs
                                     ,l_segment_array)
    THEN
      RETURN NULL;
    END IF;
    OPEN c_cost_ctr_segmt;
    FETCH c_cost_ctr_segmt INTO l_segnum;
    CLOSE c_cost_ctr_segmt;

    l_segment_value := l_segment_array(l_segnum);
    RETURN l_segment_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_Cost_Ctr;


  PROCEDURE Validate_Sales_Credits
          (p_init_msg_list         IN VARCHAR2
          ,p_customer_trx_id       IN  NUMBER
          ,p_sales_credit_type     IN  VARCHAR2
          ,p_salesrep_id           IN  NUMBER
          ,p_salesgroup_id         IN  NUMBER DEFAULT NULL  -- bug 3067675
          ,p_customer_trx_line_id  IN  NUMBER
          ,p_item_id               IN  NUMBER
          ,p_category_id           IN  NUMBER
          ,x_return_status         IN OUT NOCOPY VARCHAR2
          ,x_msg_count             OUT NOCOPY NUMBER
          ,x_msg_data              OUT NOCOPY VARCHAR2)
  IS
    l_revenue_percent_total        NUMBER;
    l_non_revenue_percent_total    NUMBER;

    CURSOR c_salesrep_totals IS
    SELECT NVL(SUM(s.revenue_percent_split),0),
           NVL(SUM(s.non_revenue_percent_split),0)
    FROM   ra_cust_trx_line_salesreps s,
           mtl_item_categories mic,
           ra_customer_trx_lines l
    WHERE  s.customer_trx_line_id = l.customer_trx_line_id
    AND    l.customer_trx_id = p_customer_trx_id
    AND    l.line_type = 'LINE'
    AND    s.salesrep_id = NVL(p_salesrep_id,s.salesrep_id)
/* BEGIN bug 3067675 */
    AND    DECODE(p_sales_credit_type,'N', NVL(s.non_revenue_salesgroup_id, -9999), NVL(s.revenue_salesgroup_id, -9999)) =
                NVL(p_salesgroup_id, DECODE(p_sales_credit_type,'N', NVL(s.non_revenue_salesgroup_id, -9999), NVL(s.revenue_salesgroup_id, -9999)))
/* END bug 3067675 */
    AND    l.customer_trx_line_id = NVL(p_customer_trx_line_id,
                                         l.customer_trx_line_id)
    AND    NVL(l.inventory_item_id,0) =
            NVL(p_item_id,NVL(l.inventory_item_id,0))
    AND    mic.organization_id(+) = g_inv_org_id
    AND    l.inventory_item_id = mic.inventory_item_id(+)
    AND    NVL(p_category_id,0) =
                 DECODE(p_category_id,NULL,0,mic.category_id)
    AND    mic.category_set_id(+) = g_category_set_id;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Validate_Sales_Credits()+');
    END IF;
    /* 5126974 - move initialization to this function
        to avoid org-specific failure in constant_system_values */
    IF g_inv_org_id IS NULL
    THEN
       oe_profile.get('SO_ORGANIZATION_ID',g_inv_org_id);
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN c_salesrep_totals;
    FETCH c_salesrep_totals INTO l_revenue_percent_total,
                                 l_non_revenue_percent_total;
    CLOSE c_salesrep_totals;
    IF (p_sales_credit_type = 'R' AND l_revenue_percent_total = 0) OR
       (p_sales_credit_type = 'N' AND l_non_revenue_percent_total = 0) OR
       (p_sales_credit_type = 'B' AND l_revenue_percent_total = 0
                                    AND l_non_revenue_percent_total = 0)
    THEN
      FND_MESSAGE.set_name('AR','AR_RA_NO_SELECTED_SALESCRED');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF;
    FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  EXCEPTION
     WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Sales_Credits: ' || 'Unexpected error '||sqlerrm||
                  ' at AR_RAAPI_UTIL.Validate_Sales_Credits()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Validate_Sales_Credits;

  FUNCTION Total_Selected_Line_Value
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_item_id               IN NUMBER
     ,p_category_id           IN NUMBER
     ,p_salesrep_id           IN NUMBER
     ,p_salesgroup_id         IN NUMBER DEFAULT NULL -- bug 3067675
     ,p_sales_credit_type     IN VARCHAR2)
  RETURN NUMBER
   IS
     l_all_line_total          NUMBER;

     CURSOR c_all_line_total IS
     SELECT NVL(SUM(d.amount),0) amount
     FROM   ra_cust_trx_line_gl_dist d
           ,mtl_item_categories mic
           ,ra_customer_trx_lines l
     WHERE  d.customer_trx_line_id = l.customer_trx_line_id
     AND    l.line_type = 'LINE'
     AND    l.customer_trx_id = p_customer_trx_id
     AND    d.account_class IN ('REV','UNEARN')
     AND    l.customer_trx_line_id = NVL(p_customer_trx_line_id,
                                         l.customer_trx_line_id)
     AND    NVL(l.inventory_item_id,0) =
            NVL(p_item_id,NVL(l.inventory_item_id,0))
     AND    mic.organization_id(+) = g_inv_org_id
     AND    l.inventory_item_id = mic.inventory_item_id(+)
     AND    NVL(p_category_id,0) =
                 DECODE(p_category_id,NULL,0,mic.category_id)
     AND    mic.category_set_id(+) = g_category_set_id
     AND   ((p_salesrep_id IS NULL AND p_salesgroup_id IS NULL AND
             p_sales_credit_type IS NULL)
       OR  EXISTS
            (SELECT 'X'
             FROM   ra_cust_trx_line_salesreps ls
             WHERE  ls.customer_trx_line_id = l.customer_trx_line_id
             AND    ls.salesrep_id = NVL(p_salesrep_id,ls.salesrep_id)
             AND    DECODE(p_sales_credit_type,'N',NVL(ls.non_revenue_salesgroup_id, -9999), NVL(ls.revenue_salesgroup_id, -9999)) =
                        NVL(p_salesgroup_id, DECODE(p_sales_credit_type,'N',NVL(ls.non_revenue_salesgroup_id, -9999), NVL(ls.revenue_salesgroup_id, -9999)))
             GROUP  BY ls.salesrep_id
             HAVING SUM(NVL(DECODE(p_sales_credit_type,'N',
               ls.non_revenue_percent_split,ls.revenue_percent_split),0)) <> 0));

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Total_Selected_Line_Value()+');
    END IF;
    /* 5126974 - move initialization to this function
        to avoid org-specific failure in constant_system_values */
    IF g_inv_org_id IS NULL
    THEN
       oe_profile.get('SO_ORGANIZATION_ID',g_inv_org_id);
    END IF;
    OPEN c_all_line_total;
    FETCH c_all_line_total INTO l_all_line_total;
    CLOSE c_all_line_total;
    RETURN l_all_line_total;
  EXCEPTION
     WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Total_Selected_Line_Value: ' || 'Unexpected error '||sqlerrm||
                  ' at AR_RAAPI_UTIL.Total_Selected_Line_Value()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Total_Selected_Line_Value ;

  /* 7365097 - Centralized some credit memo processing logic
     so that it can be neatly included in both adjustable_revenue
     and adjustable_revenue_total

     RETURNS FALSE if this is a regular credit memo and accounting
      is based on invoice
  */
  FUNCTION check_credit_memos
    (p_customer_trx_id    IN NUMBER,
     p_adjustment_type    IN VARCHAR2)
  RETURN BOOLEAN
  IS
     CURSOR c_unrec_cm(p_target_trx NUMBER) IS
     SELECT cmt.customer_trx_id
     FROM   ra_customer_trx cmt
     WHERE  cmt.previous_customer_trx_id = p_target_trx
     AND    EXISTS ( SELECT 'Unrecognized CM'
                     FROM   ra_customer_trx_lines cmtl
                     WHERE  cmtl.customer_trx_id = cmt.customer_trx_id
                     AND    cmtl.line_type = 'LINE'
                     AND    cmtl.autorule_complete_flag = 'N');

     l_dist_count NUMBER;
     l_cm_flag    VARCHAR2(1);
  BEGIN
     /* 5011151 - If a user attempts to RAM or API an invoice that has
        credits which have not (yet) been through Rev Rec, the UNEARN
        will total incorrectly for the target transaction and allow
        more REV to be earned than it should.  We are going to look
        for CMs that have not been through RR and process them before
        continuing */

        FOR cm IN c_unrec_cm(p_customer_trx_id) LOOP
           l_dist_count := ARP_AUTO_RULE.create_distributions
                              ( p_commit => 'N',
                                p_debug  => 'N',
                                p_trx_id => cm.customer_trx_id);

           IF PG_DEBUG in ('Y','C')
           THEN
               arp_util.debug('trx_id= ' || cm.customer_trx_id || '  dists=' ||
                      l_dist_count);
           END IF;
        END LOOP;

     /* 5555356/5759659 - Another corner case.. if the trx being processed
        is a credit, and use_inv_acctg=Y, then return zero for adjustable
        amounts */
     IF use_inv_acctg = 'Y' AND
        p_adjustment_type in ('EA','UN')
     THEN
        select decode(previous_customer_trx_id, NULL,'N','Y')
        into   l_cm_flag
        from   ra_customer_trx
        where  customer_trx_id = p_customer_trx_id;

        IF l_cm_flag = 'Y'
        THEN
           /* User is not allowed to adjust credits */
           RETURN FALSE; -- trap in callee, and return 0
        END IF;
     END IF;

     RETURN TRUE;  -- successfull, allow to continue
  END check_credit_memos;

  /* Bug 2560048 RAM-C: new out parameter p_acctd_amount_out provided for use
     by collectibility - it is assumed that a salesrep_id will never be passed
     in to this routine otherwise this amount will be wrong.  To be rectified
     when sales credit dependency removed from RAM */
  FUNCTION Adjustable_Revenue
     (p_customer_trx_line_id  IN NUMBER
     ,p_adjustment_type       IN VARCHAR2
     ,p_customer_trx_id       IN NUMBER
     ,p_salesrep_id           IN NUMBER
     ,p_salesgroup_id         IN NUMBER DEFAULT NULL -- bug 3067675
     ,p_sales_credit_type     IN VARCHAR2
     ,p_item_id               IN NUMBER
     ,p_category_id           IN NUMBER
     ,p_revenue_adjustment_id IN NUMBER
     ,p_line_count_out       OUT NOCOPY NUMBER
     ,p_acctd_amount_out     OUT NOCOPY NUMBER)
  RETURN NUMBER
   IS
     l_line_id                  NUMBER;
     l_line_amount              NUMBER;
     l_line_acctd_amount        NUMBER;
     l_cm_line_amount           NUMBER;
     l_cm_line_acctd_amount     NUMBER;
     l_net_line_amount          NUMBER;
     l_net_line_acctd_amount    NUMBER;
     l_line_adjustable          NUMBER;
     l_line_count               NUMBER;
     l_line_salesrep_total      NUMBER;
     l_adjustable_revenue       NUMBER;
     l_dist_count               NUMBER;
     l_cm_flag                  VARCHAR2(1);

     /* Bug 2560048 - credit memo amounts included in adjustable revenue
        calculation */
     /* Bug 3431815 - removed unnecessary extra join to ra_customer_trx
	to get credit memos */
     /* Bug 3536944: c_line broken up into 3 separate queries to improve
        performance */

     CURSOR c_line IS
     SELECT l.customer_trx_line_id,
            lr.deferred_revenue_flag
     FROM   mtl_item_categories mic
           ,ra_customer_trx_lines l
           ,ra_rules lr
     WHERE  l.customer_trx_id = p_customer_trx_id
     AND    l.line_type = 'LINE'
     AND    l.customer_trx_line_id = NVL(p_customer_trx_line_id,l.customer_trx_line_id)
     AND    l.autorule_complete_flag IS NULL
     AND    NVL(l.inventory_item_id,0) =
            NVL(p_item_id,NVL(l.inventory_item_id,0))
     AND    DECODE(p_adjustment_type,'LL',
              DECODE(p_category_id,NULL,
                DECODE(p_item_id,NULL,
                  DECODE(p_customer_trx_line_id,NULL,
                    NVL(l.accounting_rule_duration,0),0),0),0),0) <= 1
     AND    mic.organization_id(+) = g_inv_org_id
     AND    l.inventory_item_id = mic.inventory_item_id(+)
     AND    NVL(p_category_id,0) =
                 DECODE(p_category_id,NULL,0,mic.category_id)
     AND    mic.category_set_id(+) = g_category_set_id
     AND    l.accounting_rule_id = lr.rule_id (+)
     AND   ((p_salesrep_id IS NULL AND p_salesgroup_id IS NULL)
          /*   AND p_sales_credit_type IS NULL) */
       OR  EXISTS
            (SELECT 'X'
             FROM   ra_cust_trx_line_salesreps ls
             WHERE  ls.customer_trx_line_id = l.customer_trx_line_id
             AND    ls.salesrep_id = NVL(p_salesrep_id,ls.salesrep_id)
	     AND    DECODE(p_sales_credit_type,'N',NVL(ls.non_revenue_salesgroup_id, -9999), NVL(ls.revenue_salesgroup_id, -9999)) =
			NVL(p_salesgroup_id, DECODE(p_sales_credit_type,'N',NVL(ls.non_revenue_salesgroup_id, -9999), NVL(ls.revenue_salesgroup_id, -9999)))
             AND    NVL(ls.revenue_adjustment_id,0) <>
                    NVL(p_revenue_adjustment_id,
                                       NVL(ls.revenue_adjustment_id,0) + 1)
             GROUP  BY ls.salesrep_id
             HAVING SUM(NVL(DECODE(p_sales_credit_type,'N',
               ls.non_revenue_percent_split,ls.revenue_percent_split),0)) <> 0));

/*  Bug 7130380 : Added hint to improve performance */
     CURSOR c_line_amount (p_cust_trx_line_id NUMBER) IS
     SELECT /*+ index(d ra_cust_trx_line_gl_dist_n1) push_pred(s)*/
            NVL(SUM(d.amount),0) amount
           ,NVL(SUM(d.acctd_amount),0) acctd_amount
     FROM   ra_cust_trx_line_gl_dist d,
            ra_cust_trx_line_salesreps s
     WHERE  d.customer_trx_line_id = p_cust_trx_line_id
     AND    d.customer_trx_id = p_customer_trx_id
     AND    d.account_class = DECODE(p_adjustment_type,'EA','UNEARN','REV')
     AND    NVL(d.revenue_adjustment_id,0) <> NVL(p_revenue_adjustment_id,
                                       NVL(d.revenue_adjustment_id,0) + 1)
     AND    d.customer_trx_line_id = s.customer_trx_line_id (+)
     AND    d.cust_trx_line_salesrep_id = s.cust_trx_line_salesrep_id (+)
     AND    NVL(s.salesrep_id,-9999) =
               NVL(p_salesrep_id,
               NVL(s.salesrep_id,-9999))
     AND    NVL(s.revenue_salesgroup_id, -9999) =
                NVL(p_salesgroup_id /*group*/,
                NVL(s.revenue_salesgroup_id, -9999));

/*  Bug 7130380 : Added hint to improve performanc */
     CURSOR c_cm_line_amount (p_cust_trx_line_id NUMBER) IS
     SELECT /*+ index(d ra_cust_trx_line_gl_dist_n1) push_pred(s)*/
            NVL(SUM(NVL(d.amount,0)),0) amount
           ,NVL(SUM(NVL(d.acctd_amount,0)),0) acctd_amount
     FROM   ra_cust_trx_line_gl_dist d
           ,ra_customer_trx_lines l
           ,ra_cust_trx_line_salesreps s
     WHERE  l.previous_customer_trx_line_id = p_cust_trx_line_id
     AND    d.customer_trx_id = l.customer_trx_id
     AND    d.customer_trx_line_id = l.customer_trx_line_id
     AND    d.account_class = DECODE(p_adjustment_type,'EA','UNEARN','REV')
     AND    NVL(d.revenue_adjustment_id,0) <> NVL(p_revenue_adjustment_id,
                                       NVL(d.revenue_adjustment_id,0) + 1)
     AND    d.customer_trx_line_id = s.customer_trx_line_id (+)
     AND    d.cust_trx_line_salesrep_id = s.cust_trx_line_salesrep_id (+)
     AND    NVL(s.salesrep_id,-9999) =
                NVL(p_salesrep_id /* sr_id */,
                NVL(s.salesrep_id,-9999))
     AND    NVL(s.revenue_salesgroup_id, -9999) =
                NVL(p_salesgroup_id /*group*/,
                NVL(s.revenue_salesgroup_id, -9999));

     CURSOR c_line_nr_amount (p_cust_trx_line_id NUMBER) IS
     SELECT SUM(NVL(s.non_revenue_amount_split,0)) amount
     FROM   ra_cust_trx_line_salesreps s
     WHERE  s.customer_trx_line_id = p_cust_trx_line_id
     AND    s.salesrep_id = NVL(p_salesrep_id,s.salesrep_id)
     AND    NVL(s.non_revenue_salesgroup_id, -9999) =
                NVL(p_salesgroup_id,
                NVL(s.non_revenue_salesgroup_id, -9999))
     AND    NVL(s.revenue_adjustment_id,0) <> NVL(p_revenue_adjustment_id,
                                       NVL(s.revenue_adjustment_id,0) + 1);

     CURSOR c_cm_line_nr_amount (p_cust_trx_line_id NUMBER) IS
     SELECT NVL(SUM(NVL(s.non_revenue_amount_split,0)),0) amount
     FROM   ra_customer_trx_lines l
           ,ra_cust_trx_line_salesreps s
     WHERE  l.previous_customer_trx_line_id = p_cust_trx_line_id
     AND    l.customer_trx_line_id = s.customer_trx_line_id
     AND    s.salesrep_id = NVL(p_salesrep_id /* sr_id */,s.salesrep_id)
     AND    NVL(s.non_revenue_salesgroup_id, -9999) =
                NVL(p_salesgroup_id /*group*/,
                NVL(s.non_revenue_salesgroup_id, -9999));

     /* 7365097 - if autoaccounting not based on SR, then
        we'll need to get salescredit revenue from salescredits
        table instead of gl_dist */
     CURSOR c_line_rnsr_amount (p_cust_trx_line_id NUMBER) IS
     SELECT SUM(NVL(s.revenue_amount_split,0)) amount
     FROM   ra_cust_trx_line_salesreps s
     WHERE  s.customer_trx_line_id = p_cust_trx_line_id
     AND    s.salesrep_id = NVL(p_salesrep_id,s.salesrep_id)
     AND    NVL(s.revenue_salesgroup_id, -9999) =
                NVL(p_salesgroup_id,
                NVL(s.revenue_salesgroup_id, -9999))
     AND    NVL(s.revenue_adjustment_id,0) <> NVL(p_revenue_adjustment_id,
                                       NVL(s.revenue_adjustment_id,0) + 1);

     CURSOR c_cm_line_rnsr_amount (p_cust_trx_line_id NUMBER) IS
     SELECT NVL(SUM(NVL(s.revenue_amount_split,0)),0) amount
     FROM   ra_customer_trx_lines l
           ,ra_cust_trx_line_salesreps s
     WHERE  l.previous_customer_trx_line_id = p_cust_trx_line_id
     AND    l.customer_trx_line_id = s.customer_trx_line_id
     AND    s.salesrep_id = NVL(p_salesrep_id /* sr_id */,s.salesrep_id)
     AND    NVL(s.revenue_salesgroup_id, -9999) =
                NVL(p_salesgroup_id /*group*/,
                NVL(s.revenue_salesgroup_id, -9999));

  BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_RAAPI_UTIL.Adjustable_Revenue()+');
        arp_util.debug('  p_customer_trx_line_id = ' || p_customer_trx_line_id);
        arp_util.debug('  p_adjustment_type = ' || p_adjustment_type);
        arp_util.debug('  p_customer_trx_id = ' || p_customer_trx_id);
        arp_util.debug('  p_salesrep_id = ' || p_salesrep_id);
        arp_util.debug('  p_salesgroup_id = ' || p_salesgroup_id);
        arp_util.debug('  p_sales_credit_type = ' || p_sales_credit_type);
        arp_util.debug('  p_item_id = ' || p_item_id);
        arp_util.debug('  p_category_id = ' || p_category_id);
        arp_util.debug('  p_revenue_adjustment_id = ' ||
                          p_revenue_adjustment_id);
     END IF;

     /* 5126974 - move initialization to this function
         to avoid org-specific failure in constant_system_values */
     IF g_inv_org_id IS NULL
     THEN
        oe_profile.get('SO_ORGANIZATION_ID',g_inv_org_id);
     END IF;

     /* 7365097 - centralized CM test */
     IF NOT check_credit_memos(p_customer_trx_id, p_adjustment_type)
     THEN
        RETURN 0;
     END IF;

     l_adjustable_revenue := 0;
     l_line_count := 0;
     FOR c1 IN c_line LOOP
       l_line_id := c1.customer_trx_line_id;

       /* 6223281 - Modified method for salescredit type specific
          queries */
       IF NVL(p_sales_credit_type,'X') = 'N'
       THEN
          /* These cursors select only non-revenue salescredits
            (which have no corresponding dist rows) for
             non-revenue SC transfers */
          OPEN  c_line_nr_amount(l_line_id);
          FETCH c_line_nr_amount INTO l_line_amount;
          CLOSE c_line_nr_amount;

          OPEN  c_cm_line_nr_amount(l_line_id);
          FETCH c_cm_line_nr_amount INTO l_cm_line_amount;
          CLOSE c_cm_line_nr_amount;

          l_line_acctd_amount := 0;
          l_cm_line_acctd_amount := 0;
       ELSE
          IF NOT arp_auto_accounting.query_autoacc_def('REV','RA_SALESREPS')
          THEN
             IF p_adjustment_type = 'SA'
             THEN
                /* can't use gl_dist data since it won't have
                   salescredit_ids populated, have to use
                   salescredits directly (almost like non-rev SRs) */
                OPEN  c_line_rnsr_amount(l_line_id);
                FETCH c_line_rnsr_amount INTO l_line_amount;
                CLOSE c_line_rnsr_amount;

                OPEN  c_cm_line_rnsr_amount(l_line_id);
                FETCH c_cm_line_rnsr_amount INTO l_cm_line_amount;
                CLOSE c_cm_line_rnsr_amount;
             ELSE
                /* Use raw gl_dist amounts */
                l_line_amount := adjustable_revenue_total(l_line_id,
                                         p_customer_trx_id,
                                         p_adjustment_type,
                                         p_revenue_adjustment_id);
                l_cm_line_amount := 0; -- total above includes CMs already
             END IF;
          ELSE
             /* These cursors use the dists table to insure that
                we only adjust what truly exists in gl_dist */

             -- Get amount from corresponding invoice lines
             OPEN c_line_amount(l_line_id);
             FETCH c_line_amount INTO l_line_amount, l_line_acctd_amount;
             CLOSE c_line_amount;

             -- ..then for any associated credit memo lines..
             OPEN c_cm_line_amount(l_line_id);
             FETCH c_cm_line_amount INTO l_cm_line_amount,
                                         l_cm_line_acctd_amount;
             CLOSE c_cm_line_amount;
          END IF;
       END IF;

       --  The two are added to give net line amount
       l_net_line_amount := l_line_amount + l_cm_line_amount;
       l_net_line_acctd_amount := l_line_acctd_amount + l_cm_line_acctd_amount;

       IF l_net_line_amount <> 0
       THEN
         l_line_adjustable := l_net_line_amount;
       ELSE
         l_line_adjustable := 0;
         p_acctd_amount_out := 0;
       END IF;

       IF l_line_adjustable <> 0
       THEN
         p_acctd_amount_out := l_net_line_acctd_amount;
         l_line_count := l_line_count + 1;
         l_adjustable_revenue := l_adjustable_revenue + l_line_adjustable;
       END IF;
       p_line_count_out := l_line_count;

     END LOOP;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('  l_adjustable_revenue = ' || l_adjustable_revenue);
        arp_util.debug('AR_RAAPI_UTIL.Adjustable_Revenue()-');
     END IF;

     RETURN l_adjustable_revenue;

  EXCEPTION
     WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Adjustable_Revenue: ' || 'Unexpected error '||sqlerrm||
                         ' at AR_RAAPI_UTIL.Adjustable_Revenue()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END Adjustable_Revenue;

  /* 7365097 - New function for calculating adjustable_revenue
     for top of revenue adjustment form */
  FUNCTION Adjustable_Revenue_Total
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_adjustment_type       IN VARCHAR2
     ,p_revenue_adjustment_id IN NUMBER DEFAULT NULL)
  RETURN NUMBER
   IS

     CURSOR c_line_amount (p_trx_id NUMBER, p_line_id NUMBER,
                           p_adj_type VARCHAR2, p_rev_adj_id NUMBER) IS
     SELECT SUM(NVL(d.amount,0)) amount
     FROM   ra_cust_trx_line_gl_dist_all d
     WHERE  d.customer_trx_line_id = NVL(p_line_id,
                                         d.customer_trx_line_id)
     AND    d.customer_trx_id = p_trx_id
     AND    d.account_class = DECODE(p_adj_type,'EA','UNEARN','REV')
     AND    d.account_set_flag = 'N'
     AND    NVL(d.revenue_adjustment_id,0) <>
               NVL(p_rev_adj_id, NVL(d.revenue_adjustment_id,0) + 1);

     CURSOR c_cm_line_amount (p_trx_id NUMBER, p_line_id NUMBER,
                           p_adj_type VARCHAR2, p_rev_adj_id NUMBER) IS
     SELECT NVL(SUM(NVL(d.amount,0)),0) amount
     FROM   ra_cust_trx_line_gl_dist_all d,
            ra_customer_trx_lines_all l
     WHERE  l.previous_customer_trx_line_id =
                   NVL(p_line_id,
                       l.previous_customer_trx_line_id)
     AND    l.previous_customer_trx_id = p_trx_id
     AND    d.customer_trx_id = l.customer_trx_id
     AND    d.customer_trx_line_id = l.customer_trx_line_id
     AND    d.account_class = DECODE(p_adj_type,'EA','UNEARN','REV')
     AND    d.account_set_flag = 'N'
     AND    NVL(d.revenue_adjustment_id,0) <>
               NVL(p_rev_adj_id, NVL(d.revenue_adjustment_id,0) + 1);

     l_inv_amt NUMBER;
     l_cm_amt  NUMBER;
     l_total_amt NUMBER;

  BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_RAAPI_UTIL.revenue_amount_total()+');
        arp_util.debug(' p_customer_trx_id = ' || p_customer_trx_id);
        arp_util.debug(' p_customer_trx_line_id = ' || p_customer_trx_line_id);
        arp_util.debug(' p_adjustment_type      = ' || p_adjustment_type);
        arp_util.debug(' p_revenue_adjustment_id= ' || p_revenue_adjustment_id);
     END IF;

     /* DO not allow adjustments against certain regular credit memos */
     IF NOT check_credit_memos(p_customer_trx_id, p_adjustment_type)
     THEN
        RETURN 0;
     END IF;

     OPEN c_line_amount(p_customer_trx_id,p_customer_trx_line_id,
                        p_adjustment_type,p_revenue_adjustment_id);
     FETCH c_line_amount INTO l_inv_amt;
     CLOSE c_line_amount;

     OPEN  c_cm_line_amount(p_customer_trx_id,p_customer_trx_line_id,
                            p_adjustment_type,p_revenue_adjustment_id);
     FETCH c_cm_line_amount INTO l_cm_amt;
     CLOSE c_cm_line_amount;

     l_total_amt := l_inv_amt + l_cm_amt;

     IF PG_DEBUG in ('Y', 'C') THEN

        arp_util.debug(' l_inv_amt   = ' || l_inv_amt);
        arp_util.debug(' l_cm_amt    = ' || l_cm_amt);
        arp_util.debug(' l_total_amt = ' || l_total_amt);
        arp_util.debug('AR_RAAPI_UTIL.revenue_amount_total()-');
     END IF;

     RETURN l_total_amt;

  END Adjustable_Revenue_Total;

  PROCEDURE Validate_Amount
     (p_init_msg_list         IN VARCHAR2
     ,p_customer_trx_line_id  IN NUMBER
     ,p_adjustment_type       IN VARCHAR2
     ,p_amount_mode           IN VARCHAR2
     ,p_customer_trx_id       IN NUMBER
     ,p_salesrep_id           IN NUMBER
     ,p_salesgroup_id         IN NUMBER DEFAULT NULL -- bug 3067675
     ,p_sales_credit_type     IN VARCHAR2
     ,p_item_id               IN NUMBER
     ,p_category_id           IN NUMBER
     ,p_revenue_amount_in     IN NUMBER
     ,p_revenue_percent       IN NUMBER
     ,p_revenue_adjustment_id IN NUMBER
     ,p_revenue_amount_out    OUT NOCOPY NUMBER
     ,p_adjustable_amount_out OUT NOCOPY NUMBER
     ,p_line_count_out        OUT NOCOPY NUMBER
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2)
   IS
     l_adjustable_revenue     NUMBER;
     l_revenue_total          NUMBER;
     l_max_percent            NUMBER;
     l_acctd_amount_out       NUMBER;
     l_sales_credit_type      VARCHAR2(15);      -- bug 5644810

     invalid_amount           EXCEPTION;
     invalid_zero             EXCEPTION;
     adjusted_by_other_user   EXCEPTION;

     CURSOR c_revenue_total IS
     SELECT NVL(SUM(d.amount),0) amount
     FROM   ra_cust_trx_line_gl_dist d
           ,mtl_item_categories mic
           ,ra_customer_trx_lines l
     WHERE  d.customer_trx_line_id = l.customer_trx_line_id
     AND    d.account_class IN ('REV','UNEARN')
     AND    NVL(d.revenue_adjustment_id,0) <> NVL(p_revenue_adjustment_id,
                                       NVL(d.revenue_adjustment_id,0) + 1)
     AND    l.line_type = 'LINE'
     AND    l.customer_trx_id = p_customer_trx_id
     AND    l.customer_trx_line_id = NVL(p_customer_trx_line_id,
                                         l.customer_trx_line_id)
     AND    NVL(l.inventory_item_id,0) =
            NVL(p_item_id,NVL(l.inventory_item_id,0))
     AND    mic.organization_id(+) = g_inv_org_id
     AND    l.inventory_item_id = mic.inventory_item_id(+)
     AND    NVL(p_category_id,0) =
                 DECODE(p_category_id,NULL,0,mic.category_id)
     AND    mic.category_set_id(+) = g_category_set_id
     AND    DECODE(p_category_id,NULL,
              DECODE(p_item_id,NULL,
                DECODE(p_customer_trx_line_id,NULL,
                  DECODE(p_adjustment_type,'LL',
                    NVL(l.accounting_rule_duration,0),0),0),0),0) <= 1
     AND    ((p_salesrep_id IS NULL AND p_salesgroup_id IS NULL AND
              p_sales_credit_type IS NULL)
     OR     EXISTS
            (SELECT 'X'
             FROM   ra_cust_trx_line_salesreps ls
             WHERE  ls.customer_trx_line_id = l.customer_trx_line_id
             AND    ls.salesrep_id = NVL(p_salesrep_id,ls.salesrep_id)
             AND    DECODE(p_sales_credit_type,'N',
                      NVL(ls.non_revenue_salesgroup_id, -9999),
                        NVL(ls.revenue_salesgroup_id, -9999)) =
                        NVL(p_salesgroup_id, DECODE(p_sales_credit_type,'N',
                             NVL(ls.non_revenue_salesgroup_id, -9999),
                               NVL(ls.revenue_salesgroup_id, -9999)))
             GROUP  BY ls.salesrep_id
             HAVING SUM(NVL(DECODE(p_sales_credit_type,'N',
               ls.non_revenue_percent_split,ls.revenue_percent_split),0)) <> 0));


  BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('AR_RAAPI_UTIL.Validate_Amount()+');
        arp_util.debug(' p_customer_trx_line_id = ' || p_customer_trx_line_id);
        arp_util.debug(' p_amount_mode          = ' || p_amount_mode);
        arp_util.debug(' p_salesrep_id          = ' || p_salesrep_id);
        arp_util.debug(' p_salesgroup_id        = ' || p_salesgroup_id);
        arp_util.debug(' p_sales_credit_type    = ' || p_sales_credit_type);
        arp_util.debug(' p_revenue_amount_in    = ' || p_revenue_amount_in);
        arp_util.debug(' p_revenue_percent      = ' || p_revenue_percent);
     END IF;

     /* 5126974 - move initialization to this function
         to avoid org-specific failure in constant_system_values */
     IF g_inv_org_id IS NULL
     THEN
        oe_profile.get('SO_ORGANIZATION_ID',g_inv_org_id);
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list )
     THEN
       FND_MSG_PUB.initialize;
     END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF NVL(g_last_customer_trx_id,p_customer_trx_id - 1) <> p_customer_trx_id
     THEN
       constant_trx_values(p_customer_trx_id);
     END IF;
     /* Added IF condition for bug 5644810 */
     IF ((p_salesrep_id IS NULL) and (p_salesgroup_id IS NULL )) THEN
        l_sales_credit_type := NULL;
     ELSE
        l_sales_credit_type := p_sales_credit_type;
     END IF;

     l_adjustable_revenue := Adjustable_Revenue
     (p_customer_trx_line_id  => p_customer_trx_line_id
     ,p_adjustment_type       => p_adjustment_type
     ,p_customer_trx_id       => p_customer_trx_id
     ,p_salesrep_id           => p_salesrep_id
     ,p_salesgroup_id         => p_salesgroup_id -- bug 3067675
     ,p_sales_credit_type     => l_sales_credit_type  -- bug 5644810
     ,p_item_id               => p_item_id
     ,p_category_id           => p_category_id
     ,p_revenue_adjustment_id => p_revenue_adjustment_id
     ,p_line_count_out        => p_line_count_out
     ,p_acctd_amount_out      => l_acctd_amount_out);

     p_adjustable_amount_out := l_adjustable_revenue;
     IF p_amount_mode = 'A'
     THEN
       p_revenue_amount_out := NVL(p_revenue_amount_in,0);
     ELSIF p_amount_mode = 'P'
     THEN
       OPEN c_revenue_total;
       FETCH c_revenue_total INTO l_revenue_total;
       close c_revenue_total;
       p_revenue_amount_out := ROUND(l_revenue_total * p_revenue_percent / 100,
                                 g_trx_precision);
     ELSE
       p_revenue_amount_out := l_adjustable_revenue;
     END IF;

     IF PG_DEBUG = 'Y'
     THEN
        arp_util.debug(' --- after internal validation/calcs ---');
        arp_util.debug(' l_adjustable_revenue   = ' || l_adjustable_revenue);
        arp_util.debug(' l_revenue_total        = ' || l_revenue_total);
        arp_util.debug(' p_revenue_amount_out   = ' || p_revenue_amount_out);
     END IF;

     /* 7454302 - Allow adjustments of zero amounts
     IF p_revenue_amount_out = 0
     THEN
       IF p_revenue_adjustment_id IS NULL
       THEN
         RAISE invalid_zero;
       ELSE
         RAISE adjusted_by_other_user;
       END IF;
     END IF;
     */
     IF p_revenue_amount_out > 0
     THEN
       IF p_revenue_amount_out > l_adjustable_revenue
       THEN
         IF p_revenue_adjustment_id IS NULL
         THEN
           RAISE invalid_amount;
         ELSE
           RAISE adjusted_by_other_user;
         END IF;
       END IF;
     ELSIF p_revenue_amount_out < 0
     THEN
       IF p_revenue_amount_out < l_adjustable_revenue
       THEN
         IF p_revenue_adjustment_id IS NULL
         THEN
           RAISE invalid_amount;
         ELSE
           RAISE adjusted_by_other_user;
         END IF;
       END IF;
     END IF;

  EXCEPTION

    WHEN invalid_amount THEN
      IF p_amount_mode = 'P'
      THEN
        l_max_percent := ROUND(l_adjustable_revenue / l_revenue_total * 100,4);
        FND_MESSAGE.set_name
          (application => 'AR', name => 'AR_RA_PCT_EXCEEDS_AVAIL_PCT');
        FND_MESSAGE.set_token('TOT_AVAIL_PCT',l_max_percent);
      ELSE
        FND_MESSAGE.set_name
          (application => 'AR', name => 'AR_RA_AMT_EXCEEDS_AVAIL_REV');
        FND_MESSAGE.set_token('TOT_AVAIL_REV',
                               g_trx_currency||' '||
                               TO_CHAR(l_adjustable_revenue,g_trx_curr_format));
      END IF;
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN invalid_zero THEN
      FND_MESSAGE.set_name
          (application => 'AR', name => 'AR_RA_ZERO_AMOUNT');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN adjusted_by_other_user THEN
      FND_MESSAGE.set_name
          (application => 'AR', name => 'AR_RA_ADJUSTED_BY_OTHER_USER');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Amount: ' || 'Unexpected error '||sqlerrm||
                      ' at AR_RAAPI_UTIL.Validate_Amount()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END Validate_Amount;

  FUNCTION Revalidate_GL_Dates
       (p_customer_trx_id       IN NUMBER
       ,p_revenue_adjustment_id IN NUMBER
       ,x_msg_count             OUT NOCOPY NUMBER
       ,x_msg_data              OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 IS

    l_change_count            NUMBER;
    l_gl_date                 DATE;
    l_default_rule            VARCHAR2(80);
    l_err_mesg                VARCHAR2(2000);

    CURSOR c_gl_date IS
      SELECT DISTINCT gl_date
      FROM   ra_cust_trx_line_gl_dist
      WHERE  revenue_adjustment_id = p_revenue_adjustment_id;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Revalidate_GL_Dates()+');
    END IF;
    l_change_count := 0;
    FOR c1 IN c_gl_date LOOP
      IF ARP_STANDARD.validate_and_default_gl_date
             (gl_date => c1.gl_date,
              trx_date => g_trx_date,
              validation_date1 => NULL,
              validation_date2 => NULL,
              validation_date3 => NULL,
              default_date1 => c1.gl_date,
              default_date2 => NULL,
              default_date3 => NULL,
              p_allow_not_open_flag   => 'Y',
              p_invoicing_rule_id => g_invoicing_rule_id,
              p_set_of_books_id => arp_global.sysparam.set_of_books_id,
              p_application_id => AR_RAAPI_UTIL.application_id,
              default_gl_date => l_gl_date,
              defaulting_rule_used  => l_default_rule,
              error_message  => l_err_mesg)
      THEN
        IF c1.gl_date <> l_gl_date
        THEN
          UPDATE ra_cust_trx_line_gl_dist
          SET   gl_date = l_gl_date
          WHERE revenue_adjustment_id = p_revenue_adjustment_id
          AND   gl_date = c1.gl_date;
          FND_MESSAGE.set_name('AR','AR_RA_GL_DATE_CHANGED');
          FND_MESSAGE.set_token('GL_DATE',c1.gl_date);
          FND_MESSAGE.set_token('NEW_GL_DATE',l_gl_date);
          FND_MSG_PUB.Add;
          l_change_count := l_change_count + 1;
        END IF;
      ELSE
        FND_MESSAGE.set_name('AR','AR_RA_NO_OPEN_PERIODS');
        RETURN FND_API.G_FALSE;
      END IF;
    END LOOP;
    IF l_change_count > 0
    THEN
      FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
      RETURN FND_API.G_FALSE;
    ELSE
      RETURN FND_API.G_TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Revalidate_GL_Dates: ' || 'Unexpected error '||sqlerrm||
                      ' at AR_RAAPI_UTIL.Revalidate_GL_Dates()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Revalidate_GL_Dates;

  FUNCTION Deferred_GL_Date (p_start_date    IN  DATE,
                             p_period_seq_no IN NUMBER)
  RETURN DATE
  IS
    l_init_start_date          DATE;
    l_init_new_period_num      NUMBER;
    l_current_new_period_num   NUMBER;
    l_current_start_date       DATE;
    l_current_end_date         DATE;
    l_current_gl_date          DATE;

/* Bug 1940911: added period_type to 'where' clause to ensure the correct
                period type is being selected when more than 1 type exists
                in a calendar. */

    CURSOR c_start_period IS
      SELECT p.start_date, p.new_period_num
      FROM   ar_periods p,
             gl_sets_of_books sob,
             ar_period_types tp
      WHERE  sob.period_set_name = p.period_set_name
      AND    sob.set_of_books_id = arp_global.sysparam.set_of_books_id
      AND    sob.accounted_period_type = p.period_type
      AND    sob.accounted_period_type = tp.period_type
      AND    p_start_date BETWEEN p.start_date AND p.end_date;

    CURSOR c_current_period (p_new_period_num NUMBER) IS
      SELECT p.start_date, p.end_date
      FROM   ar_periods p,
             gl_sets_of_books sob,
             ar_period_types tp
      WHERE  sob.period_set_name = p.period_set_name
      AND    sob.set_of_books_id = arp_global.sysparam.set_of_books_id
      AND    sob.accounted_period_type = p.period_type
      AND    sob.accounted_period_type = tp.period_type
      AND    p.new_period_num = p_new_period_num;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('AR_RAAPI_UTIL.Deferred_GL_Date()+');
    END IF;
    IF p_period_seq_no = 1
    THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('AR_RAAPI_UTIL.Deferred_GL_Date()-');
      END IF;
      RETURN p_start_date;
    ELSE
      -- Find the period relating to the start date of revenue recognition
      OPEN c_start_period;
      FETCH c_start_period INTO l_init_start_date, l_init_new_period_num;
      CLOSE c_start_period;
      -- Find the period number of the current period
      l_current_new_period_num := (l_init_new_period_num + p_period_seq_no -1);
      OPEN c_current_period(l_current_new_period_num);
      FETCH c_current_period INTO l_current_start_date, l_current_end_date;
      CLOSE c_current_period;
      -- Calculate the current gl_date
      l_current_gl_date := LEAST((p_start_date - l_init_start_date
                                              + l_current_start_date),
	                         l_current_end_date);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('AR_RAAPI_UTIL.Deferred_GL_Date()-');
      END IF;
      RETURN l_current_gl_date;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Deferred_GL_Date: ' || 'Unexpected error '||sqlerrm||
                      ' at AR_RAAPI_UTIL.Deferred_GL_Date()+');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Deferred_GL_Date;

  --
  -- Read only functions to allow client access to globals
  --
  FUNCTION G_RET_STS_SUCCESS
  RETURN VARCHAR2 IS
  BEGIN
    RETURN FND_API.G_RET_STS_SUCCESS;
  END G_RET_STS_SUCCESS;

  FUNCTION G_RET_STS_ERROR
  RETURN VARCHAR2 IS
  BEGIN
    RETURN FND_API.G_RET_STS_ERROR;
  END G_RET_STS_ERROR;

  FUNCTION G_TRUE
  RETURN VARCHAR2 IS
  BEGIN
    RETURN FND_API.G_TRUE;
  END G_TRUE;

  FUNCTION G_VALID_LEVEL_NONE
  RETURN VARCHAR2 IS
  BEGIN
    RETURN FND_API.G_VALID_LEVEL_NONE;
  END G_VALID_LEVEL_NONE;

  FUNCTION G_VALID_LEVEL_FULL
  RETURN VARCHAR2 IS
  BEGIN
    RETURN FND_API.G_VALID_LEVEL_FULL;
  END G_VALID_LEVEL_FULL;

  FUNCTION G_FALSE
  RETURN VARCHAR2 IS
  BEGIN
    RETURN FND_API.G_FALSE;
  END G_FALSE;

  FUNCTION chart_of_accounts_id
  RETURN NUMBER IS
  BEGIN
    RETURN g_chart_of_accounts_id;
  END chart_of_accounts_id;

  FUNCTION set_of_books_id
  RETURN NUMBER IS
  BEGIN
    RETURN g_set_of_books_id;
  END set_of_books_id;

  FUNCTION application_id
  RETURN NUMBER IS
  BEGIN
    RETURN g_ar_app_id;
  END application_id;

  FUNCTION un_meaning
  RETURN VARCHAR2 IS
  BEGIN
    RETURN g_un_meaning;
  END un_meaning;

  FUNCTION ea_meaning
  RETURN VARCHAR2 IS
  BEGIN
    RETURN g_ea_meaning;
  END ea_meaning;

  FUNCTION sa_meaning
  RETURN VARCHAR2 IS
  BEGIN
    RETURN g_sa_meaning;
  END sa_meaning;

  FUNCTION nr_meaning
  RETURN VARCHAR2 IS
  BEGIN
    RETURN g_nr_meaning;
  END nr_meaning;

  FUNCTION ll_meaning
  RETURN VARCHAR2 IS
  BEGIN
    RETURN g_ll_meaning;
  END ll_meaning;

  FUNCTION cost_ctr_number
  RETURN VARCHAR2 IS
  BEGIN
    RETURN g_cost_ctr_number;
  END cost_ctr_number;

  FUNCTION category_set_id
  RETURN VARCHAR2 IS
  BEGIN
    RETURN g_category_set_id;
  END category_set_id;

  FUNCTION category_structure_id
  RETURN VARCHAR2 IS
  BEGIN
    RETURN g_category_structure_id;
  END category_structure_id;

  FUNCTION inv_org_id
  RETURN VARCHAR2 IS
  BEGIN
    /* NOTE:  This is returned as a varchar.. not sure why */
    /* 5861728 - Initialize the value if null */
    IF g_inv_org_id IS NULL
    THEN
       oe_profile.get('SO_ORGANIZATION_ID',g_inv_org_id);
    END IF;
    RETURN g_inv_org_id;
  END inv_org_id;

  /* 7454302 - Determines if a revenue adjustment is allowed
     on a zero line.  Only allowed first time in.

      returns TRUE if there are no REV lines for current zero line
      returns FALSE if line is not zero or is zero and has REV lines

       p_check_line_amt skips the test of ra_customer_trx_lines when
       that information has already been tested */
  FUNCTION unearned_zero_lines(p_customer_trx_id IN NUMBER,
                               p_customer_trx_line_id IN NUMBER DEFAULT NULL,
                               p_check_line_amt IN VARCHAR DEFAULT 'Y')
  RETURN BOOLEAN IS
    l_zero_lines NUMBER := 99;
    l_unearned_zero_lines NUMBER := 0;
  BEGIN
       IF p_check_line_amt = 'Y'
       THEN
         /* Are there any zero lines? */
         SELECT count(*)
         INTO   l_zero_lines
         FROM   ra_customer_trx_lines l
         WHERE  l.customer_trx_id = p_customer_trx_id
         AND    l.customer_trx_line_id = NVL(p_customer_trx_line_id,
                                             l.customer_trx_line_id)
         AND    l.line_type = 'LINE'
         AND    l.extended_amount = 0;
       END IF;

       IF l_zero_lines = 0
       THEN
          RETURN FALSE;
       ELSE

          /* Do the zero lines have distributions? */
          SELECT count(*)
          INTO   l_unearned_zero_lines
          FROM   ra_customer_trx_lines    l
          WHERE  l.customer_trx_id = p_customer_trx_id
          AND    l.customer_trx_line_id = NVL(p_customer_trx_line_id,
                                              l.customer_trx_line_id)
          AND    l.line_type = 'LINE'
          AND    l.extended_amount = 0
          AND NOT EXISTS
              (SELECT 'x'
               FROM   ra_cust_trx_line_gl_dist g
               WHERE  g.customer_trx_id = l.customer_trx_id
               AND    g.customer_trx_line_id = l.customer_trx_line_id
               AND    g.account_class = 'REV'
               AND    g.account_set_flag = 'N');

          IF l_unearned_zero_lines = 0
          THEN
             RETURN FALSE;
          ELSE
             RETURN TRUE;
          END IF;
      END IF;

  RETURN FALSE;

  EXCEPTION
     WHEN OTHERS THEN
         RETURN FALSE;

  END unearned_zero_lines;

END AR_RAAPI_UTIL;

/
