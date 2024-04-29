--------------------------------------------------------
--  DDL for Package Body ZX_TCM_GET_EXEMPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TCM_GET_EXEMPT_PKG" AS
/* $Header: zxcgetexemptb.pls 120.26.12010000.3 2008/12/06 17:49:19 ssanka ship $ */

G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(30) := 'ZX.PLSQL.ZX_TCM_GET_EXEMPT_PKG';
  l_log_msg FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
procedure period_date_range( p_tax_date in date,
                             p_ledger_id IN NUMBER,
                             start_date out NOCOPY date,
                               end_date out NOCOPY date ) is

   cursor sel_date( p_tax_date in date ) is
     select p.start_date, p.end_date
     from gl_period_statuses p, gl_sets_of_books g
    where p.application_id = 222
      and p.set_of_books_id = p_ledger_id
      and trunc(p_tax_date) between p.start_date and p.end_date
      and g.set_of_books_id = p.set_of_books_id
      and g.accounted_period_type = p.period_type;


begin

   open sel_date( p_tax_date );
   fetch sel_date into start_date, end_date;
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'start_date '||to_char(start_date);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions.period_date_range', l_log_msg);
      END IF;


   if sel_date%notfound
   then
IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'No Data found';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions.period_date_range', l_log_msg);
      END IF;

      close sel_date;

   end if;
   if sel_date%isopen then
       close sel_date;
   end if;

end;

PROCEDURE get_exemptions(
                    p_ptp_id              IN NUMBER,
                    p_cust_account_id     IN NUMBER,
                    p_site_use_id         IN NUMBER,
                    p_inventory_item_id   IN NUMBER,
                    p_tax_date            IN DATE,
                    p_exempt_certificate_number IN VARCHAR2,
                    p_reason_code         IN VARCHAR2,
                    p_exempt_control_flag IN VARCHAR2,
                    p_tax_regime_code     IN VARCHAR2,
                    p_tax                 IN VARCHAR2,
                    p_tax_status_code     IN VARCHAR2,
                    p_tax_rate_code       IN VARCHAR2,
                    p_tax_jurisdiction_id IN NUMBER,
                    x_exemption_rec       OUT NOCOPY zx_tcm_get_exempt_pkg.exemption_rec_type) IS

  CURSOR exemptions(p_ptp_id              NUMBER,
                    p_cust_account_id     IN NUMBER,
                    p_site_use_id         IN NUMBER,
                    p_inventory_item_id   NUMBER,
                    p_tax_date            DATE,
                    p_exempt_certificate_number VARCHAR2,
                    p_reason_code         VARCHAR2,
                    p_exempt_control_flag VARCHAR2,
                    p_tax_regime_code     VARCHAR2,
                    p_tax                 VARCHAR2,
                    p_tax_status_code     VARCHAR2,
                    p_tax_rate_code       VARCHAR2,
                    p_tax_jurisdiction_id NUMBER
                     ) IS
    SELECT tax_exemption_id, exemption_type_code, rate_modifier, apply_to_lower_levels_flag,
           decode(product_id, null, decode(site_use_id, null, decode(cust_account_id, null,4,3),2), 1) select_order1,
            decode(exemption_status_code,'PRIMARY',1,'MANUAL',2,'UNAPPROVED',3) select_order2,
            tax_rate_code, tax_jurisdiction_id, tax_status_code, tax, exempt_reason_code, exempt_certificate_number
    FROM zx_exemptions
    WHERE party_tax_profile_id = p_ptp_id
    AND ((p_exempt_control_flag = 'S' and exemption_status_code = 'PRIMARY' )
             OR ( p_exempt_control_flag = 'E'
                  AND exemption_status_code IN ( 'PRIMARY', 'MANUAL', 'UNAPPROVED' )
                  AND exempt_reason_code = p_reason_code
                  AND ( (rtrim(ltrim(exempt_certificate_number)) = p_exempt_certificate_number)
                      or (exempt_certificate_number IS NULL AND
                          p_exempt_certificate_number IS NULL))   ))
    AND duplicate_exemption = 0
    AND tax_regime_code = p_tax_regime_code
    AND (cust_account_id is null or cust_account_id = p_cust_account_id)
    AND (site_use_id is null or site_use_id = p_site_use_id)
    AND (tax is null or tax = p_tax)
    AND (tax_status_code is null or tax_status_code = p_tax_status_code)
    AND (tax_rate_code is null or tax_rate_code = p_tax_rate_code)
    AND (tax_jurisdiction_id is null or tax_jurisdiction_id = p_tax_jurisdiction_id)
    AND (product_id is null or product_id = p_inventory_item_id)
    AND effective_from <= p_tax_date
    AND (effective_to >= p_tax_date or effective_to is null)
order by select_order2,
         select_order1,
         tax_rate_code NULLS LAST, tax_jurisdiction_id NULLS LAST, tax_status_code NULLS LAST, tax NULLS LAST;

  l_tax_exmpt_cr_method_code    VARCHAR2(30);
  l_tax_exmpt_source_tax        VARCHAR2(30);
  l_order_by1                   NUMBER;
  l_order_by2                   NUMBER;
  l_source_tax_jurisdiction_id  NUMBER;
  l_tax_rate_code               VARCHAR2(50);
  l_tax_status_code             VARCHAR2(30);
  l_tax                         VARCHAR2(30);
  l_tax_jurisdiction_id         NUMBER;
  l_tax_rec                     ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
  l_return_status               VARCHAR2(30);
  l_error_buffer		VARCHAR2(240);
  l_exists                      VARCHAR2(10);
BEGIN

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'Get Exemptions';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions', l_log_msg);
    END IF;
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions',
                'p_ptp_id '|| to_char(p_ptp_id) || ' '||
                'p_cust_account_id '||  to_char(p_cust_account_id) || ' '||
               'p_site_use_id '||  to_char(p_site_use_id)  || ' '||
               'p_inventory_item_id '||  to_char(p_inventory_item_id)|| ' '||
               'p_tax_date ' ||  to_char(p_tax_date)|| ' '||
               'p_exempt_certificate_number '||  p_exempt_certificate_number|| ' '||
               'p_reason_code ' || p_reason_code|| ' '||
               'p_exempt_control_flag '||  p_exempt_control_flag|| ' '||
               'p_tax_regime_code ' || p_tax_regime_code|| ' '||
               'p_tax' ||  p_tax|| ' '||
               'p_tax_status_code '||  p_tax_status_code|| ' '||
               'p_tax_rate_code '||  p_tax_rate_code|| ' '||
               'p_tax_jurisdiction_id '||  to_char(p_tax_jurisdiction_id));
     END IF;

  OPEN exemptions(p_ptp_id,
                  p_cust_account_id,
                  p_site_use_id,
                  p_inventory_item_id,
                  p_tax_date,
                  p_exempt_certificate_number,
                  p_reason_code,
                  p_exempt_control_flag,
                  p_tax_regime_code,
                  p_tax,
                  p_tax_status_code,
                  p_tax_rate_code,
                  p_tax_jurisdiction_id);

  LOOP
    FETCH exemptions INTO x_exemption_rec.exemption_id, x_exemption_rec.discount_special_rate,
                          x_exemption_rec.percent_exempt, x_exemption_rec.apply_to_lower_levels_flag,
                          l_order_by1, l_order_by2, l_tax_rate_code, l_tax_jurisdiction_id, l_tax_status_code, l_tax , x_exemption_rec.exempt_reason_code, x_exemption_rec.exempt_certificate_number;
    EXIT WHEN exemptions%NOTFOUND;
    IF x_exemption_rec.exemption_id IS NOT NULL THEN
      IF x_exemption_rec.exempt_reason_code IS NOT NULL THEN
        BEGIN
           SELECT meaning
           INTO x_exemption_rec.exempt_reason
           from FND_LOOKUPS
           where  lookup_type = 'ZX_EXEMPTION_REASON_CODE'
           and    lookup_code = x_exemption_rec.exempt_reason_code;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
             IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME,
                                  'There is no exempt reason lookup type for this exempt reason.');
             END IF;
             RAISE FND_API.G_EXC_ERROR;
           WHEN OTHERS THEN
             IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME,
                                  'Failed when trying to get the meaning for Reason Code due to '||SQLERRM);
             END IF;
             RAISE FND_API.G_EXC_ERROR;
        END;
      END IF;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'Tax Exemptions Id '||to_char(x_exemption_rec.exemption_id) || ' Percent Exempt '||to_char(x_exemption_rec.percent_exempt);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions', l_log_msg);
      END IF;
      EXIT;

    END IF;

  END LOOP;
  CLOSE exemptions;

  IF x_exemption_rec.exemption_id IS NULL AND p_tax IS NOT NULL THEN


  ZX_TDS_UTILITIES_PKG.get_tax_cache_info (
  p_tax_regime_code	=>  p_tax_regime_code,
  p_tax                 =>  p_tax,
  p_tax_determine_date	=>  p_tax_date,
  x_tax_rec            	=>  l_tax_rec,
  p_return_status      	=>  l_return_status,
  p_error_buffer        =>  l_error_buffer);

  l_tax_exmpt_cr_method_code  := l_tax_rec.tax_exmpt_cr_method_code;
  l_tax_exmpt_source_tax      := l_tax_rec.tax_exmpt_source_tax;

   /* Use cache
    SELECT tax_exmpt_cr_method_code, tax_exmpt_source_tax
    INTO   l_tax_exmpt_cr_method_code, l_tax_exmpt_source_tax
    FROM   zx_sco_taxes
    WHERE  tax_regime_code = p_tax_regime_code
    AND    tax = p_tax;
   */


    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'Get Exemptions Source Tax';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions', l_log_msg);
    END IF;

    IF l_tax_exmpt_cr_method_code = 'USE_EXEMPTIONS' THEN
      IF l_tax_exmpt_source_tax IS NOT NULL THEN
        IF p_tax_jurisdiction_id IS NOT NULL THEN
            SELECT TAX_EXMPT_SRC_JURISDICT_ID
            INTO l_source_tax_jurisdiction_id
            FROM zx_jurisdictions_b
            WHERE tax_jurisdiction_id = p_tax_jurisdiction_id
            AND effective_from <= p_tax_date
            AND (effective_to >= p_tax_date or effective_to is null);
        END IF;

        OPEN exemptions(p_ptp_id,
                  p_cust_account_id,
                  p_site_use_id,
                  p_inventory_item_id,
                  p_tax_date,
                  p_exempt_certificate_number,
                  p_reason_code,
                  p_exempt_control_flag,
                  p_tax_regime_code,
                  l_tax_exmpt_source_tax,
                  p_tax_status_code,
                  p_tax_rate_code,
                  l_source_tax_jurisdiction_id);

         LOOP
           FETCH exemptions INTO x_exemption_rec.exemption_id, x_exemption_rec.discount_special_rate,
                        x_exemption_rec.percent_exempt, x_exemption_rec.apply_to_lower_levels_flag,
                        l_order_by1, l_order_by2,l_tax_rate_code, l_tax_jurisdiction_id, l_tax_status_code, l_tax, x_exemption_rec.exempt_reason_code, x_exemption_rec.exempt_certificate_number;
           EXIT WHEN exemptions%NOTFOUND;

           IF x_exemption_rec.exemption_id IS NOT NULL THEN
             IF x_exemption_rec.apply_to_lower_levels_flag = 'Y' THEN
               EXIT;
             ELSE
               x_exemption_rec.exemption_id := null;
               x_exemption_rec.discount_special_rate := null;
               x_exemption_rec.percent_exempt := null;
               x_exemption_rec.apply_to_lower_levels_flag := null;

             END IF;
           END IF;

         END LOOP;
         CLOSE exemptions;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'Tax Exemptions Id '||to_char(x_exemption_rec.exemption_id) || ' Percent Exempt '||to_char(x_exemption_rec.percent_exempt);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions', l_log_msg);
         END IF;
      END IF;
    END IF;
  END IF;
END;

PROCEDURE get_tax_exemptions (p_bill_to_cust_site_use_id      IN NUMBER,
                             p_bill_to_cust_acct_id          IN NUMBER,
                             p_bill_to_party_site_ptp_id     IN NUMBER,
                             p_bill_to_party_ptp_id          IN NUMBER,
                             p_sold_to_party_site_ptp_id     IN NUMBER,
                             p_sold_to_party_ptp_id          IN NUMBER,
                             p_inventory_org_id              IN NUMBER,
                             p_inventory_item_id             IN NUMBER,
                             p_exempt_certificate_number     IN VARCHAR2,
                             p_reason_code                   IN VARCHAR2,
                             p_exempt_control_flag           IN VARCHAR2,
                             p_tax_date                      IN DATE,
                             p_tax_regime_code               IN VARCHAR2,
                             p_tax                           IN VARCHAR2,
                             p_tax_status_code               IN VARCHAR2,
                             p_tax_rate_code                 IN VARCHAR2,
                             p_tax_jurisdiction_id           IN NUMBER,
                             p_multiple_jurisdictions_flag   IN VARCHAR2,
                             p_event_class_rec               IN zx_api_pub.event_class_rec_type,
                             x_return_status                 OUT NOCOPY VARCHAR2,
                             x_exemption_rec                 OUT NOCOPY exemption_rec_type) IS
  l_tax_jurisdiction_code VARCHAR2(30);
  l_ledger_id   NUMBER;
  l_start_date  DATE;
  l_end_date    DATE;
  l_exists      VARCHAR2(1);
  i BINARY_INTEGER;
  n BINARY_INTEGER;
  l_tax_jurisdiction_id NUMBER;
  TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_tax_jurisdiction_id_tbl NUMBER_TBL_TYPE;
  l_precedence_level_tbl NUMBER_TBL_TYPE;
  -----l_log_msg FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
BEGIN
G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   l_log_msg := 'Get Tax Exemptions ' ||
                'p_bill_to_cust_site_use_id= '|| p_bill_to_cust_site_use_id ||
                'p_bill_to_cust_acct_id= '|| p_bill_to_cust_acct_id ||
                'p_bill_to_party_site_ptp_id= '|| p_bill_to_party_site_ptp_id||
                'p_bill_to_party_ptp_id= '||  p_bill_to_party_ptp_id ||
                'p_sold_to_party_site_ptp_id= '|| p_sold_to_party_site_ptp_id||
                'p_sold_to_party_ptp_id= '||  p_sold_to_party_ptp_id ||
                'p_inventory_org_id= '||     p_inventory_org_id     ||
                'p_inventory_item_id= '||    p_inventory_item_id    ||
                'p_exempt_certificate_number= '|| p_exempt_certificate_number||
                'p_reason_code= '||          p_reason_code          ||
                'p_exempt_control_flag= '||  p_exempt_control_flag  ||
                'p_tax_date= '||             p_tax_date             ||
                'p_tax_regime_code= '||      p_tax_regime_code      ||
                'p_tax= '||                  p_tax                  ||
                'p_tax_status_code= '||      p_tax_status_code      ||
                'p_tax_rate_code= '||        p_tax_rate_code        ||
                'p_tax_jurisdiction_id= '||  p_tax_jurisdiction_id  ||
                'p_multiple_jurisdictions_flag= '||p_multiple_jurisdictions_flag ||
                'p_event_class_rec.ledger_id= '||p_event_class_rec.ledger_id
;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions', l_log_msg);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_exempt_control_flag = 'E' and p_reason_code is null THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ZX', 'ZX_TCM_NO_EXEMPT_REASON');
      RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF nvl(p_multiple_jurisdictions_flag,'N') = 'N' THEN
      l_tax_jurisdiction_id_tbl(1) := p_tax_jurisdiction_id;
    ELSE
      SELECT tax_jurisdiction_id, precedence_level
      BULK COLLECT INTO l_tax_jurisdiction_id_tbl, l_precedence_level_tbl
      FROM zx_jurisdictions_gt
      ORDER BY precedence_level;
    END IF;

    FOR i in l_tax_jurisdiction_id_tbl.first..l_tax_jurisdiction_id_tbl.last LOOP
      IF nvl(p_event_class_rec.EXMPTN_PTY_BASIS_HIER_1_CODE,'BILL_TO') = 'BILL_TO' THEN
         -- call ptp_based_exemptions with p_bill_to_party_site_ptp_id,
         get_exemptions(     p_bill_to_party_site_ptp_id,
                             p_bill_to_cust_acct_id,
                             p_bill_to_cust_site_use_id,
                             p_inventory_item_id,
                             p_tax_date,
                             p_exempt_certificate_number,
                             p_reason_code,
                             p_exempt_control_flag,
                             p_tax_regime_code,
                             p_tax,
                             p_tax_status_code,
                             p_tax_rate_code,
                             l_tax_jurisdiction_id_tbl(i),
                             x_exemption_rec);
         IF x_exemption_rec.exemption_id IS NULL THEN
	    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        	l_log_msg := 'Calling get_exemptions with p_bill_to_party_ptp_id';
        	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions', l_log_msg);
    	    END IF;
           -- call ptp_based_exemptions with p_bill_to_party_ptp_id,
           get_exemptions(   p_bill_to_party_ptp_id,
                             p_bill_to_cust_acct_id,
                             p_bill_to_cust_site_use_id,
                             p_inventory_item_id,
                             p_tax_date,
                             p_exempt_certificate_number,
                             p_reason_code,
                             p_exempt_control_flag,
                             p_tax_regime_code,
                             p_tax,
                             p_tax_status_code,
                             p_tax_rate_code,
                             l_tax_jurisdiction_id_tbl(i),
                             x_exemption_rec);

         END IF;

       --
  ELSIF p_event_class_rec.EXMPTN_PTY_BASIS_HIER_1_CODE = 'SOLD_TO' THEN
         -- call ptp_based_exemptions with p_sold_to_party_site_ptp_id,
         get_exemptions(     p_sold_to_party_site_ptp_id,
                             p_bill_to_cust_acct_id,
                             p_bill_to_cust_site_use_id,
                             p_inventory_item_id,
                             p_tax_date,
                             p_exempt_certificate_number,
                             p_reason_code,
                             p_exempt_control_flag,
                             p_tax_regime_code,
                             p_tax,
                             p_tax_status_code,
                             p_tax_rate_code,
                             l_tax_jurisdiction_id_tbl(i),
                             x_exemption_rec);
       IF x_exemption_rec.exemption_id IS NULL THEN
         -- call ptp_based_exemptions with p_sold_to_party_ptp_id,
	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       	      l_log_msg := 'Calling get_exemptions with p_sold_to_party_ptp_id';
        	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions', l_log_msg);
    	END IF;
         get_exemptions(     p_sold_to_party_ptp_id,
                             p_bill_to_cust_acct_id,
                             p_bill_to_cust_site_use_id,
                             p_inventory_item_id,
                             p_tax_date,
                             p_exempt_certificate_number,
                             p_reason_code,
                             p_exempt_control_flag,
                             p_tax_regime_code,
                             p_tax,
                             p_tax_status_code,
                             p_tax_rate_code,
                             l_tax_jurisdiction_id_tbl(i),
                             x_exemption_rec);

       END IF;

  END IF; -- hier_1_code check
  --
  IF x_exemption_rec.exemption_id IS NULL THEN
    -- Need not add nvl for EXMPTN_PTY_BASIS_HIER_2_CODE
    -- since get_exemptions has got executed with 'BILL_TO' earlier
    IF p_event_class_rec.EXMPTN_PTY_BASIS_HIER_2_CODE = 'BILL_TO' THEN

        -- call ptp_based_exemptions with p_bill_to_party_site_ptp_id,
        get_exemptions(      p_bill_to_party_site_ptp_id,
                             p_bill_to_cust_acct_id,
                             p_bill_to_cust_site_use_id,
                             p_inventory_item_id,
                             p_tax_date,
                             p_exempt_certificate_number,
                             p_reason_code,
                             p_exempt_control_flag,
                             p_tax_regime_code,
                             p_tax,
                             p_tax_status_code,
                             p_tax_rate_code,
                             l_tax_jurisdiction_id_tbl(i),
                             x_exemption_rec);
        IF x_exemption_rec.exemption_id IS NULL THEN
          -- call ptp_based_exemptions with p_bill_to_party_ptp_id,
          get_exemptions(    p_bill_to_party_ptp_id,
                             p_bill_to_cust_acct_id,
                             p_bill_to_cust_site_use_id,
                             p_inventory_item_id,
                             p_tax_date,
                             p_exempt_certificate_number,
                             p_reason_code,
                             p_exempt_control_flag,
                             p_tax_regime_code,
                             p_tax,
                             p_tax_status_code,
                             p_tax_rate_code,
                             l_tax_jurisdiction_id_tbl(i),
                             x_exemption_rec);

        END IF;

       --
    ELSIF p_event_class_rec.EXMPTN_PTY_BASIS_HIER_2_CODE = 'SOLD_TO' THEN
         get_exemptions(     p_sold_to_party_site_ptp_id,
                             p_bill_to_cust_acct_id,
                             p_bill_to_cust_site_use_id,
                             p_inventory_item_id,
                             p_tax_date,
                             p_exempt_certificate_number,
                             p_reason_code,
                             p_exempt_control_flag,
                             p_tax_regime_code,
                             p_tax,
                             p_tax_status_code,
                             p_tax_rate_code,
                             l_tax_jurisdiction_id_tbl(i),
                             x_exemption_rec);
       IF x_exemption_rec.exemption_id IS NULL THEN
         -- call ptp_based_exemptions with p_sold_to_party_ptp_id,
         get_exemptions(     p_sold_to_party_ptp_id,
                             p_bill_to_cust_acct_id,
                             p_bill_to_cust_site_use_id,
                             p_inventory_item_id,
                             p_tax_date,
                             p_exempt_certificate_number,
                             p_reason_code,
                             p_exempt_control_flag,
                             p_tax_regime_code,
                             p_tax,
                             p_tax_status_code,
                             p_tax_rate_code,
                             l_tax_jurisdiction_id_tbl(i),
                             x_exemption_rec);

       END IF;

  END IF; -- hier_2_code check

  END IF; -- exemption id null check
  IF x_exemption_rec.exemption_id IS NOT NULL THEN
    EXIT;
  END IF;

END LOOP;


IF x_exemption_rec.exemption_id IS NULL THEN
  IF p_exempt_control_flag = 'E' THEN

    IF p_event_class_rec.ledger_id is null THEN
     IF zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID.exists(1) THEN
       SELECT set_of_books_id
       INTO l_ledger_id
       FROM ar_system_parameters_all
       WHERE org_id = zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(1);
     ELSIF p_event_class_rec.internal_organization_id is not null THEN
       SELECT set_of_books_id
       INTO l_ledger_id
       FROM ar_system_parameters_all
       WHERE org_id = p_event_class_rec.internal_organization_id;
     END IF;

    END IF;
    period_date_range(p_tax_date,
                      nvl(p_event_class_rec.ledger_id, l_ledger_id),
                      l_start_date,
                      l_end_date);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'l_start_date '||to_char(l_start_date);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions', l_log_msg);
      END IF;


   n := l_tax_jurisdiction_id_tbl.last;
   l_tax_jurisdiction_id := l_tax_jurisdiction_id_tbl(n);

    Begin
     select 'Y' into l_exists
     from
     zx_exemptions
     where nvl(tax_rate_code,'X') = nvl(p_tax_rate_code,'X') and
     effective_from = nvl(l_start_date, trunc(sysdate))
     and nvl(exempt_certificate_number,'X') = nvl(p_exempt_certificate_number,'X')
     and exempt_reason_code = p_reason_code
     and party_tax_profile_id = p_bill_to_party_ptp_id
     and tax_regime_code = p_tax_regime_code
     and content_owner_id =
       nvl(p_event_class_rec.first_pty_org_id,ZX_SECURITY.G_FIRST_PARTY_ORG_ID)
     and nvl(tax_status_code,'X') = nvl(p_tax_status_code,'X')
      and nvl(tax,'X') = nvl(p_tax,'X')
     and nvl(tax_jurisdiction_id,-999) = nvl(l_tax_jurisdiction_id,-999)
     and exemption_status_code = 'UNAPPROVED';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions', 'Unapproved exemption exists');
     END IF;

 exception
  when no_data_found THEN
   l_exists := 'N';
  when others then
   l_exists := 'N';
 end;

 IF l_exists = 'N' THEN
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'Create Unapproved Exemption';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions',
l_log_msg);
   END IF;

  SELECT zx_exemptions_s.nextval
  INTO x_exemption_rec.exemption_id
  FROM dual;
  x_exemption_rec.discount_special_rate := 'DISCOUNT';
  x_exemption_rec.percent_exempt := 100;
  x_exemption_rec.apply_to_lower_levels_flag := 'Y';
  x_exemption_rec.exempt_reason_code := p_reason_code;
   x_exemption_rec.exempt_certificate_number := p_exempt_certificate_number;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || 'Get_tax_exemptions',
                      'Exemption Id '|| to_char(x_exemption_rec.exemption_id) || ' '||
                      'Tax Regime Code '|| p_TAX_REGIME_CODE || ' '||
                      'Tax '|| p_TAX || ' '||
                      'Tax Status Code ' ||p_TAX_STATUS_CODE || ' ' ||
                      'Tax Rate Code '||p_tax_rate_code || ' ' ||
                      'Content owner id '||to_char(nvl(p_event_class_rec.first_pty_org_id,ZX_SECURITY.G_FIRST_PARTY_ORG_ID)) || ' ' ||
                      'Exemption Certificate Number '|| p_exempt_certificate_number || ' ' ||
                      'Reason Code '|| p_REASON_CODE || ' ' ||
                      'Start Date '|| to_char(nvl(l_start_date, trunc(sysdate))) || ' ' ||
                      'Bill to party ptp id '|| to_char(p_bill_to_party_ptp_id) || ' ' ||
                      'Tax Jurisdiction id '|| to_char(l_tax_jurisdiction_id));
     END IF;

  INSERT INTO ZX_EXEMPTIONS(
    TAX_EXEMPTION_ID,
    EXEMPTION_TYPE_CODE,
    EXEMPTION_STATUS_CODE,
    TAX_REGIME_CODE,
    TAX,
    TAX_STATUS_CODE,
    tax_rate_code,
    CONTENT_OWNER_ID,
    EXEMPT_CERTIFICATE_NUMBER,
    EXEMPT_REASON_CODE,
    EFFECTIVE_FROM,
    PARTY_TAX_PROFILE_ID,
    RATE_MODIFIER,
    APPLY_TO_LOWER_LEVELS_FLAG,
    TAX_JURISDICTION_ID,
    cust_account_id,
    site_use_id,
    RECORD_TYPE_CODE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    --PROGRAM_LOGIN_ID,
    OBJECT_VERSION_NUMBER,
    duplicate_exemption)
  VALUES (
    x_exemption_rec.exemption_id,
    'DISCOUNT',
    'UNAPPROVED',
    p_TAX_REGIME_CODE,
    p_TAX,
    p_TAX_STATUS_CODE,
    p_tax_rate_code,
    nvl(p_event_class_rec.first_pty_org_id,ZX_SECURITY.G_FIRST_PARTY_ORG_ID),
    p_exempt_certificate_number,
    p_REASON_CODE,
    nvl(l_start_date, trunc(sysdate)),
    p_bill_to_party_ptp_id,
    100,
    'Y',
    l_tax_jurisdiction_id,
    null,
    null,
    'USER_DEFINED',
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.conc_login_id,
    null, -- request id
    null, -- PROGRAM_APPLICATION_ID,
    null, -- PROGRAM_ID,
    --PROGRAM_LOGIN_ID,
    1,
    0);
  END IF;
  END IF;
END IF;

END;
END;

/
