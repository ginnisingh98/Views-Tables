--------------------------------------------------------
--  DDL for Package Body PN_REC_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_REC_CALC_PKG" as
/* $Header: PNRECALB.pls 120.9.12010000.6 2010/04/26 18:53:55 asahoo ship $ */

/*===========================================================================+
 | PROCEDURE
 |    CALCULATE_REC_AMOUNT_BATCH
 |
 | DESCRIPTION
 |    Calculate recovery amount for a recovery agreement(s)
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_rec_agreement_id
 |                    p_lease_id
 |                    p_location_id
 |                    p_customer_id
 |                    p_cust_site_id
 |                    p_rec_agr_line_id
 |                    p_rec_calc_period_id
 |                    p_calc_period_start_date
 |                    p_calc_period_end_date
 |                    P_as_of_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Calculate recovery amount for a recovery agreement(s)
 |
 | MODIFICATION HISTORY
 |
 |     07-APR-03  Daniel Thota  o Created
 |     29-JUN-06  Hareesha      o Bug #5356744 Used canonical_to_date to convert
 |                                the dates,input parameters to DATE type
 |                                to avoid clash with ICX:date format
 |                                and other user date formats.
 |     18-JUL-06  sdmahesh      o Bug 5332426 Added handling for lazy upgrade
 |                                of Term Templates for E-Tax
 +===========================================================================*/

TYPE template_name_tbl_type IS TABLE OF pn_term_templates_all.name%TYPE INDEX BY BINARY_INTEGER;
TYPE template_id_tbl_type IS TABLE OF pn_term_templates_all.term_template_id%TYPE INDEX BY BINARY_INTEGER;
template_name_tbl template_name_tbl_type;
template_id_tbl template_id_tbl_type;

PROCEDURE CALCULATE_REC_AMOUNT_BATCH(
                                errbuf                  OUT NOCOPY VARCHAR2
                               ,retcode                 OUT NOCOPY VARCHAR2
                               ,p_rec_agreement_id      IN  NUMBER
                               ,p_lease_id              IN  NUMBER
                               ,p_location_id           IN  NUMBER
                               ,p_customer_id           IN  NUMBER
                               ,p_cust_site_id          IN  NUMBER
                               ,p_rec_agr_line_id       IN  NUMBER DEFAULT NULL
                               ,p_rec_calc_period_id    IN  NUMBER DEFAULT NULL
                               ,p_calc_period_startdate IN  VARCHAR2
                               ,p_calc_period_enddate   IN  VARCHAR2
                               ,p_as_ofdate             IN  VARCHAR2
                               ,p_lease_num_from        IN  VARCHAR2
                               ,p_lease_num_to          IN  VARCHAR2
                               ,p_location_code_from    IN  VARCHAR2
                               ,p_location_code_to      IN  VARCHAR2
                               ,p_rec_agr_num_from      IN  VARCHAR2
                               ,p_rec_agr_num_to        IN  VARCHAR2
                               ,p_property_name         IN  VARCHAR2
                               ,p_customer_name         IN  VARCHAR2
                               ,p_customer_site         IN  VARCHAR2
                               ,p_calc_period_ending    IN  VARCHAR2
                               ,p_org_id                IN  NUMBER
                              ) IS

  l_rec_agreement_id   pn_rec_agreements_all.rec_agreement_id%TYPE := NULL;
  l_lease_id           pn_rec_agreements_all.lease_id%TYPE         := NULL;
  l_location_id        pn_rec_agreements_all.location_id%TYPE      := NULL;
  l_customer_id        pn_rec_agreements_all.customer_id%TYPE      := NULL;
  l_cust_site_id       pn_rec_agreements_all.cust_site_id%TYPE     := NULL;

  l_start_date         pn_rec_calc_periods_all.start_date%TYPE;
  l_end_date           pn_rec_calc_periods_all.end_date%TYPE ;
  l_as_of_date         pn_rec_calc_periods_all.as_of_date%TYPE ;
  l_calc_period_ending pn_rec_calc_periods_all.end_date%TYPE :=
                          trunc(fnd_date.canonical_to_date(p_calc_period_ending));

  l_error               VARCHAR2(2000) := 'Success';
  l_error_code          NUMBER := 0;

CURSOR csr_get_agr IS
SELECT rec_agreement_num,
       rec_agreement_name
FROM   pn_rec_agreements_all
WHERE  rec_agreement_id = p_rec_agreement_id;

CURSOR csr_get_lease IS
SELECT name,
       lease_num
FROM   pn_leases_all
WHERE  lease_id = p_lease_id;

CURSOR csr_get_location IS
SELECT location_code
FROM   pn_locations_all
WHERE  location_id = p_location_id
AND    NVL(l_as_of_date,sysdate) between active_start_date and
active_end_date;

CURSOR calc_rec_amount_wloc IS
     SELECT pra.rec_agreement_id
            ,pra.lease_id
            ,pra.location_id
            ,pra.customer_id
            ,pra.cust_site_id
            ,prc.start_date
            ,prc.end_date
            ,prc.as_of_date
            ,prc.rec_calc_period_id
     FROM   pn_leases                pl
            ,pn_rec_agreements_all   pra
            ,pn_rec_calc_periods_all prc
            ,pn_locations_all        ploc
     WHERE  pl.lease_id           = pra.lease_id
     AND    pra.customer_id       = nvl(p_customer_id,pra.customer_id)
     AND    pra.cust_site_id      = nvl(p_cust_site_id,pra.cust_site_id)
     AND    pra.rec_agreement_id  = prc.rec_agreement_id
     AND    prc.end_date          <= nvl(l_calc_period_ending,prc.end_date)
     AND    ploc.location_id      = pra.location_id
     AND    pl.lease_num          >= nvl(p_lease_num_from, pl.lease_num)
     AND    pl.lease_num          <= nvl(p_lease_num_to, pl.lease_num)
     AND    ploc.location_code    >= nvl(p_location_code_from, ploc.location_code)
     AND    ploc.location_code    <= nvl(p_location_code_to, ploc.location_code)
     AND    pra.rec_agreement_num >= nvl(p_rec_agr_num_from,pra.rec_agreement_num)
     AND    pra.rec_agreement_num <= nvl(p_rec_agr_num_to,pra.rec_agreement_num)
     AND   (pl.org_id = p_org_id or p_org_id is null)
     ORDER BY pl.lease_id, pra.rec_agreement_id
     ;

CURSOR calc_rec_amount_woloc IS
     SELECT pra.rec_agreement_id
            ,pra.lease_id
            ,pra.location_id
            ,pra.customer_id
            ,pra.cust_site_id
            ,prc.start_date
            ,prc.end_date
            ,prc.as_of_date
            ,prc.rec_calc_period_id
     FROM   pn_leases                pl
            ,pn_rec_agreements_all   pra
            ,pn_rec_calc_periods_all prc
     WHERE  pl.lease_id           = pra.lease_id
     AND    pra.customer_id       = nvl(p_customer_id,pra.customer_id)
     AND    pra.cust_site_id      = nvl(p_cust_site_id,pra.cust_site_id)
     AND    pra.rec_agreement_id  = prc.rec_agreement_id
     AND    prc.end_date          <= nvl(l_calc_period_ending,prc.end_date)
     AND    pl.lease_num          >= nvl(p_lease_num_from, pl.lease_num)
     AND    pl.lease_num          <= nvl(p_lease_num_to, pl.lease_num)
     AND    pra.rec_agreement_num >= nvl(p_rec_agr_num_from,pra.rec_agreement_num)
     AND    pra.rec_agreement_num <= nvl(p_rec_agr_num_to,pra.rec_agreement_num)
     AND   (pl.org_id = p_org_id or p_org_id is null)
     ORDER BY pl.lease_id, pra.rec_agreement_id
     ;

CURSOR calc_rec_amount_wloc_prop IS
     SELECT pra.rec_agreement_id
            ,pra.lease_id
            ,pra.location_id
            ,pra.customer_id
            ,pra.cust_site_id
            ,prc.start_date
            ,prc.end_date
            ,prc.as_of_date
            ,prc.rec_calc_period_id
     FROM   pn_leases                pl
            ,pn_rec_agreements_all   pra
            ,pn_rec_calc_periods_all prc
            ,pn_locations_all        ploc
            ,pn_properties_all       prop
     WHERE  pl.lease_id           = pra.lease_id
     AND    pra.customer_id       = nvl(p_customer_id,pra.customer_id)
     AND    pra.cust_site_id      = nvl(p_cust_site_id,pra.cust_site_id)
     AND    pra.rec_agreement_id  = prc.rec_agreement_id
     AND    prc.end_date          <= nvl(l_calc_period_ending,prc.end_date)
     AND    ploc.location_id      = pra.location_id
     AND    ploc.property_id      = prop.property_id
     AND    prop.property_code    = p_property_name
     AND    pl.lease_num          >= nvl(p_lease_num_from, pl.lease_num)
     AND    pl.lease_num          <= nvl(p_lease_num_to, pl.lease_num)
     AND    ploc.location_code    >= nvl(p_location_code_from, ploc.location_code)
     AND    ploc.location_code    <= nvl(p_location_code_to, ploc.location_code)
     AND    pra.rec_agreement_num >= nvl(p_rec_agr_num_from,pra.rec_agreement_num)
     AND    pra.rec_agreement_num <= nvl(p_rec_agr_num_to,pra.rec_agreement_num)
     AND   (pl.org_id = p_org_id or p_org_id is null)
     ORDER BY pl.lease_id, pra.rec_agreement_id
     ;

CURSOR calc_rec_amount_woloc_prop IS
     SELECT pra.rec_agreement_id
            ,pra.lease_id
            ,pra.location_id
            ,pra.customer_id
            ,pra.cust_site_id
            ,prc.start_date
            ,prc.end_date
            ,prc.as_of_date
            ,prc.rec_calc_period_id
     FROM   pn_leases                pl
            ,pn_rec_agreements_all   pra
            ,pn_rec_calc_periods_all prc
            ,pn_locations_all        ploc
            ,pn_properties_all       prop
     WHERE  pl.lease_id           = pra.lease_id
     AND    pra.customer_id       = nvl(p_customer_id,pra.customer_id)
     AND    pra.cust_site_id      = nvl(p_cust_site_id,pra.cust_site_id)
     AND    pra.rec_agreement_id  = prc.rec_agreement_id
     AND    prc.end_date          <= nvl(l_calc_period_ending,prc.end_date)
     AND    ploc.location_id      = pra.location_id
     AND    ploc.property_id      = prop.property_id
     AND    prop.property_code    = p_property_name
     AND    pl.lease_num          >= nvl(p_lease_num_from, pl.lease_num)
     AND    pl.lease_num          <= nvl(p_lease_num_to, pl.lease_num)
     AND    pra.rec_agreement_num >= nvl(p_rec_agr_num_from,pra.rec_agreement_num)
     AND    pra.rec_agreement_num <= nvl(p_rec_agr_num_to,pra.rec_agreement_num)
     AND   (pl.org_id = p_org_id or p_org_id is null)
     ORDER BY pl.lease_id, pra.rec_agreement_id
     ;

     l_processed    NUMBER := 0;
     l_success_count NUMBER := 0;
     l_fail_count NUMBER := 0;
     l_rec_calc_period_id    pn_rec_calc_periods_all.rec_calc_period_id%TYPE;

BEGIN

        pnp_debug_pkg.log('PN_REC_CALC_PKG.CALCULATE_REC_AMOUNT_BATCH (+) ');
        l_rec_calc_period_id := p_rec_calc_period_id;

        l_start_date  := TRUNC(fnd_date.canonical_to_date(p_calc_period_startdate));
        l_end_date    := TRUNC(fnd_date.canonical_to_date(p_calc_period_enddate));
        l_as_of_date  := TRUNC(fnd_date.canonical_to_date(p_as_ofdate));

        fnd_message.set_name ('PN','PN_RECALC_AGR_BATCH_INP_PARAM');
        fnd_message.set_token ('AGR_ID',p_rec_agreement_id);
        fnd_message.set_token ('LEASE_ID',l_lease_id);
        fnd_message.set_token ('LOC_ID',p_location_id);
        fnd_message.set_token ('LINE_ID',p_rec_agr_line_id);
        fnd_message.set_token ('PRD_ID',p_rec_calc_period_id);
        fnd_message.set_token ('CUST_ID',p_customer_id);
        fnd_message.set_token ('SITE_ID',p_cust_site_id);
        fnd_message.set_token ('ST_DATE',l_start_date);
        fnd_message.set_token ('END_DT',l_end_date);
        fnd_message.set_token ('AS_DATE',l_as_of_date);
        fnd_message.set_token ('LSNO_FRM',p_lease_num_from);
        fnd_message.set_token ('LSNO_TO',p_lease_num_to);
        fnd_message.set_token ('LOC_FRM',p_location_code_from);
        fnd_message.set_token ('LOC_TO',p_location_code_to);
        fnd_message.set_token ('REC_FRM',p_rec_agr_num_from);
        fnd_message.set_token ('REC_TO',p_rec_agr_num_to);
        fnd_message.set_token ('PROP_NAME',p_property_name);
        fnd_message.set_token ('CUST_NAME',p_customer_name);
        fnd_message.set_token ('CUST_SITE',p_customer_site);
        fnd_message.set_token ('PRD_END',l_calc_period_ending);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        /* PL/SQL Tables to cache term templates which are lazy upgraded for E-Tax*/
        template_name_tbl.DELETE;
        template_id_tbl.DELETE;


        /* if p_org_ID is not null, then set.
           else if in R12, current org is already set
        */
        IF p_org_id is NOT NULL THEN
           pn_mo_cache_utils.fnd_req_set_org_id (p_org_id);
           /* uncomment to debug
              pnp_debug_pkg.log('Set the org id with value:' || to_char(pn_mo_cache_utils.get_current_org_id)); */
        END IF;

        IF ((p_rec_agreement_id IS NOT NULL)
        or (p_lease_id IS NOT NULL)
        or (p_location_id IS NOT NULL)
        or (p_rec_agr_line_id IS NOT NULL)
        or (p_rec_calc_period_id IS NOT NULL)
        or (p_calc_period_startdate IS NOT NULL)
        or (p_calc_period_enddate IS NOT NULL)
        or (p_as_ofdate IS NOT NULL)
        ) THEN
           --Fix for bug#9117940
           IF (l_rec_calc_period_id IS NULL) THEN
               l_rec_calc_period_id := validate_create_calc_period(p_rec_agreement_id => p_rec_agreement_id
                                                                  ,p_start_date => l_start_date
                                                                  ,p_end_date => l_end_date
                                                                  ,p_as_of_date => l_as_of_date);
           END IF;

        IF  l_rec_calc_period_id <> -1 THEN

        l_processed := l_processed + 1;

        PN_REC_CALC_PKG.CALCULATE_REC_AMOUNT(
                               p_rec_agreement_id        => p_rec_agreement_id
                               ,p_lease_id               => p_lease_id
                               ,p_location_id            => p_location_id
                               ,p_customer_id            => p_customer_id
                               ,p_cust_site_id           => p_cust_site_id
                               ,p_rec_agr_line_id        => p_rec_agr_line_id
                               ,p_rec_calc_period_id     => l_rec_calc_period_id
                               ,p_calc_period_start_date => l_start_date
                               ,p_calc_period_end_date   => l_end_date
                               ,p_as_of_date             => l_as_of_date
                               ,p_error                  => l_error
                               ,p_error_code             => l_error_code
                              );

         IF nvl(l_error_code,0) <> -99 THEN

                l_success_count := l_success_count + 1;
         ELSE
                l_fail_count := l_fail_count + 1;

         END IF;

         END IF;

     ELSE

        IF p_location_code_from IS NOT NULL or p_location_code_to IS NOT NULL THEN
           IF p_property_name IS NOT NULL THEN
              OPEN calc_rec_amount_wloc_prop;
           ELSE
              OPEN calc_rec_amount_wloc;
           END IF;
        ELSE
           IF p_property_name IS NOT NULL THEN
              OPEN calc_rec_amount_woloc_prop;
           ELSE
              OPEN calc_rec_amount_woloc;
           END IF;
        END IF;

        LOOP

           IF calc_rec_amount_wloc_prop%ISOPEN THEN
               FETCH calc_rec_amount_wloc_prop INTO
                     l_rec_agreement_id
                     ,l_lease_id
                     ,l_location_id
                     ,l_customer_id
                     ,l_cust_site_id
                     ,l_start_date
                     ,l_end_date
                     ,l_as_of_date
                     ,l_rec_calc_period_id;
               EXIT WHEN calc_rec_amount_wloc_prop%NOTFOUND;
           ELSIF calc_rec_amount_wloc%ISOPEN THEN
               FETCH calc_rec_amount_wloc INTO
                     l_rec_agreement_id
                     ,l_lease_id
                     ,l_location_id
                     ,l_customer_id
                     ,l_cust_site_id
                     ,l_start_date
                     ,l_end_date
                     ,l_as_of_date
                     ,l_rec_calc_period_id;
               EXIT WHEN calc_rec_amount_wloc%NOTFOUND;
           ELSIF calc_rec_amount_woloc_prop%ISOPEN THEN
               FETCH calc_rec_amount_woloc_prop INTO
                     l_rec_agreement_id
                     ,l_lease_id
                     ,l_location_id
                     ,l_customer_id
                     ,l_cust_site_id
                     ,l_start_date
                     ,l_end_date
                     ,l_as_of_date
                     ,l_rec_calc_period_id;
               EXIT WHEN calc_rec_amount_woloc_prop%NOTFOUND;
           ELSIF calc_rec_amount_woloc%ISOPEN THEN
               FETCH calc_rec_amount_woloc INTO
                     l_rec_agreement_id
                     ,l_lease_id
                     ,l_location_id
                     ,l_customer_id
                     ,l_cust_site_id
                     ,l_start_date
                     ,l_end_date
                     ,l_as_of_date
                     ,l_rec_calc_period_id;
               EXIT WHEN calc_rec_amount_woloc%NOTFOUND;
           END IF;

           l_error := 'Success';
           l_error_code := null;

           --Fix for bug#9117940
           IF (l_rec_calc_period_id IS NULL) THEN
               l_rec_calc_period_id := validate_create_calc_period(p_rec_agreement_id => l_rec_agreement_id
                                                                  ,p_start_date => l_start_date
                                                                  ,p_end_date => l_end_date
                                                                  ,p_as_of_date => l_as_of_date);
           END IF;

           IF  l_rec_calc_period_id <> -1 THEN

              l_processed := l_processed + 1;

              PN_REC_CALC_PKG.CALCULATE_REC_AMOUNT(
                                     p_rec_agreement_id        => l_rec_agreement_id
                                     ,p_lease_id               => l_lease_id
                                     ,p_location_id            => l_location_id
                                     ,p_customer_id            => l_customer_id
                                     ,p_cust_site_id           => l_cust_site_id
                                     ,p_rec_agr_line_id        => NULL
                                     ,p_rec_calc_period_id     => l_rec_calc_period_id
                                     ,p_calc_period_start_date => l_start_date
                                     ,p_calc_period_end_date   => l_end_date
                                     ,p_as_of_date             => l_as_of_date
                                     ,p_error                  => l_error
                                     ,p_error_code             => l_error_code
                                    );

              IF nvl(l_error_code,0) <> -99 THEN

                l_success_count := l_success_count + 1;
              ELSE
                l_fail_count := l_fail_count + 1;

              END IF;

           END IF;

        END LOOP;

        fnd_message.set_name ('PN','PN_RECALC_AGR_PROC');
        fnd_message.set_token ('NUM', l_processed);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        fnd_message.set_name ('PN','PN_RECALC_AGR_SUC');
        fnd_message.set_token ('NUM', l_success_count);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        fnd_message.set_name ('PN','PN_RECALC_AGR_FAIL');
        fnd_message.set_token ('NUM', l_fail_count);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        IF calc_rec_amount_wloc_prop%ISOPEN THEN
           CLOSE calc_rec_amount_wloc_prop;
        ELSIF calc_rec_amount_wloc%ISOPEN THEN
           CLOSE calc_rec_amount_wloc;
        ELSIF calc_rec_amount_woloc_prop%ISOPEN THEN
           CLOSE calc_rec_amount_woloc_prop;
        ELSIF calc_rec_amount_woloc%ISOPEN THEN
           CLOSE calc_rec_amount_woloc;
        END IF;


     END IF;

     /*Logging information for upgraded Term Templates*/
     FOR i IN 1 .. template_id_tbl.COUNT LOOP
       pnp_debug_pkg.put_log_msg('Term template '||template_name_tbl(i)||
       ' has an existing tax code or tax group.A corresponding tax classification will replace it');
     END LOOP;

     pnp_debug_pkg.log('PN_REC_CALC_PKG.CALCULATE_REC_AMOUNT_BATCH (-) ');

EXCEPTION

When OTHERS Then
   pnp_debug_pkg.log('Error in PN_REC_CALC_PKG.CALCULATE_REC_AMOUNT_BATCH :'||to_char(sqlcode)||' : '||sqlerrm);
   Errbuf  := SQLERRM;
   Retcode := 2;
   rollback;
   raise;


END CALCULATE_REC_AMOUNT_BATCH;

/*=============================================================================+
 | PROCEDURE
 |    CALCULATE_REC_AMOUNT_BATCH
 |
 | DESCRIPTION
 |    Calculate recovery amount for a recovery agreement(s)
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_rec_agreement_id
 |                    p_lease_id
 |                    p_location_id
 |                    p_customer_id
 |                    p_cust_site_id
 |                    p_rec_agr_line_id
 |                    p_rec_calc_period_id
 |                    p_calc_period_start_date
 |                    p_calc_period_end_date
 |                    P_as_of_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Calculate recovery amount for a recovery agreement(s)
 |
 | MODIFICATION HISTORY
 |
 |  11-SEP-03  Daniel Thota  o Created an overloaded proc to fix bug 3138335
 |  05-FEB-05  piagrawa      o Modified the tokens LOC_CODE_FRM and
 |                             LOC_CODE_TO in message
 |                             PN_RECALC_AGR_INP_PARAM. Bug 4144583.
 |  05-DEC-2007  acprakas    o Bug#6438840. Modified procedure to accept
 |                             start_date, end_date and as_of_date as parameters
 |                             and to pick up the recovery agreements correclty.
 +============================================================================*/
PROCEDURE CALCULATE_REC_AMOUNT_BATCH(
                               errbuf                   OUT NOCOPY VARCHAR2
                               ,retcode                 OUT NOCOPY VARCHAR2
                 	       ,p_calc_period_startdate IN  VARCHAR2	 --Bug#6438840
                               ,p_calc_period_enddate   IN  VARCHAR2	 --Bug#6438840
                               ,p_as_ofdate             IN  VARCHAR2	 --Bug#6438840
                               ,p_lease_num_from        IN  VARCHAR2
                               ,p_lease_num_to          IN  VARCHAR2
                               ,p_location_code_from    IN  VARCHAR2
                               ,p_location_code_to      IN  VARCHAR2
                               ,p_rec_agr_num_from      IN  VARCHAR2
                               ,p_rec_agr_num_to        IN  VARCHAR2
                               ,p_property_name         IN  VARCHAR2
                               ,p_customer_name         IN  VARCHAR2
                               ,p_customer_site         IN  VARCHAR2
                               ,p_calc_period_ending    IN  VARCHAR2
                               ,p_org_id                IN  NUMBER
                              ) IS

  l_rec_agreement_id   pn_rec_agreements_all.rec_agreement_id%TYPE := NULL;
  l_lease_id           pn_rec_agreements_all.lease_id%TYPE         := NULL;
  l_location_id        pn_rec_agreements_all.location_id%TYPE      := NULL;
  l_customer_id        pn_rec_agreements_all.customer_id%TYPE      := NULL;
  l_cust_site_id       pn_rec_agreements_all.cust_site_id%TYPE     := NULL;
  l_start_date         pn_rec_calc_periods_all.start_date%TYPE := fnd_date.canonical_to_date(p_calc_period_startdate); --Bug#6438840
  l_end_date           pn_rec_calc_periods_all.end_date%TYPE   := fnd_date.canonical_to_date(p_calc_period_enddate); --Bug#6438840
  l_as_of_date         pn_rec_calc_periods_all.as_of_date%TYPE := fnd_date.canonical_to_date(p_as_ofdate);  --Bug#6438840
  l_calc_period_ending pn_rec_calc_periods_all.end_date%TYPE :=
                          trunc(fnd_date.canonical_to_date(p_calc_period_ending));

  l_error               VARCHAR2(2000) := 'Success';
  l_error_code          NUMBER := 0;

CURSOR calc_rec_amount_wloc IS
     SELECT pra.rec_agreement_id
            ,pra.lease_id
            ,pra.location_id
            ,pra.customer_id
            ,pra.cust_site_id
     FROM   pn_leases                pl
            ,pn_rec_agreements_all   pra
            ,pn_locations_all        ploc
     WHERE  pl.lease_id           = pra.lease_id
     AND    ploc.location_id      = pra.location_id
     AND    pl.lease_num          >= nvl(p_lease_num_from, pl.lease_num)
     AND    pl.lease_num          <= nvl(p_lease_num_to, pl.lease_num)
     AND    ploc.location_code    >= nvl(p_location_code_from, ploc.location_code)
     AND    ploc.location_code    <= nvl(p_location_code_to, ploc.location_code)
     AND    pra.rec_agreement_num >= nvl(p_rec_agr_num_from,pra.rec_agreement_num)
     AND    pra.rec_agreement_num <= nvl(p_rec_agr_num_to,pra.rec_agreement_num)
     AND   (pl.org_id = p_org_id or p_org_id is null)
     ORDER BY pl.lease_id, pra.rec_agreement_id
     ;

CURSOR calc_rec_amount_woloc IS
     SELECT pra.rec_agreement_id
            ,pra.lease_id
            ,pra.location_id
            ,pra.customer_id
            ,pra.cust_site_id
    FROM   pn_leases                pl
            ,pn_rec_agreements_all   pra
     WHERE  pl.lease_id           = pra.lease_id
     AND    pl.lease_num          >= nvl(p_lease_num_from, pl.lease_num)
     AND    pl.lease_num          <= nvl(p_lease_num_to, pl.lease_num)
     AND    pra.rec_agreement_num >= nvl(p_rec_agr_num_from,pra.rec_agreement_num)
     AND    pra.rec_agreement_num <= nvl(p_rec_agr_num_to,pra.rec_agreement_num)
     AND   (pl.org_id = p_org_id or p_org_id is null)
     ORDER BY pl.lease_id, pra.rec_agreement_id
     ;

CURSOR calc_rec_amount_wloc_prop IS
     SELECT pra.rec_agreement_id
            ,pra.lease_id
            ,pra.location_id
            ,pra.customer_id
            ,pra.cust_site_id
    FROM    pn_leases                pl
            ,pn_rec_agreements_all   pra
            ,pn_locations_all        ploc
            ,pn_properties_all       prop
     WHERE  pl.lease_id           = pra.lease_id
     AND    ploc.location_id      = pra.location_id
     AND    ploc.property_id      = prop.property_id
     AND    prop.property_code    = p_property_name
     AND    pl.lease_num          >= nvl(p_lease_num_from, pl.lease_num)
     AND    pl.lease_num          <= nvl(p_lease_num_to, pl.lease_num)
     AND    ploc.location_code    >= nvl(p_location_code_from, ploc.location_code)
     AND    ploc.location_code    <= nvl(p_location_code_to, ploc.location_code)
     AND    pra.rec_agreement_num >= nvl(p_rec_agr_num_from,pra.rec_agreement_num)
     AND    pra.rec_agreement_num <= nvl(p_rec_agr_num_to,pra.rec_agreement_num)
     AND   (pl.org_id = p_org_id or p_org_id is null)
     ORDER BY pl.lease_id, pra.rec_agreement_id
     ;

CURSOR calc_rec_amount_woloc_prop IS
     SELECT pra.rec_agreement_id
            ,pra.lease_id
            ,pra.location_id
            ,pra.customer_id
            ,pra.cust_site_id
     FROM   pn_leases                pl
            ,pn_rec_agreements_all   pra
            ,pn_locations_all        ploc
            ,pn_properties_all       prop
     WHERE  pl.lease_id           = pra.lease_id
     AND    ploc.location_id      = pra.location_id
     AND    ploc.property_id      = prop.property_id
     AND    prop.property_code    = p_property_name
     AND    pl.lease_num          >= nvl(p_lease_num_from, pl.lease_num)
     AND    pl.lease_num          <= nvl(p_lease_num_to, pl.lease_num)
     AND    pra.rec_agreement_num >= nvl(p_rec_agr_num_from,pra.rec_agreement_num)
     AND    pra.rec_agreement_num <= nvl(p_rec_agr_num_to,pra.rec_agreement_num)
     AND   (pl.org_id = p_org_id or p_org_id is null)
     ORDER BY pl.lease_id, pra.rec_agreement_id
     ;

     l_processed     NUMBER := 0;
     l_success_count NUMBER := 0;
     l_fail_count    NUMBER := 0;
     l_rec_calc_period_id pn_rec_calc_periods_all.rec_calc_period_id%TYPE;

BEGIN

        pnp_debug_pkg.log('PN_REC_CALC_PKG.CALCULATE_REC_AMOUNT_BATCH (+) ');
        fnd_message.set_name ('PN','PN_RECALC_AGR_INP_PARAM');
        fnd_message.set_token ('LEASE_FRM',p_lease_num_from);
        fnd_message.set_token ('LEASE_TO',p_lease_num_to);
        fnd_message.set_token ('LOC_CODE_FRM',p_location_code_from);
        fnd_message.set_token ('LOC_CODE_TO',p_location_code_to);
        fnd_message.set_token ('REC_FRM',p_rec_agr_num_from);
        fnd_message.set_token ('REC_TO',p_rec_agr_num_to);
        fnd_message.set_token ('PROP_NAME',p_property_name);
        fnd_message.set_token ('CUST_NAME',p_customer_name);
        fnd_message.set_token ('CUST_SITE',p_customer_site);
        fnd_message.set_token ('PRD_END',l_calc_period_ending);

        pnp_debug_pkg.put_log_msg(fnd_message.get);

        /* if p_org_ID is not null, then set.
           else if in R12, current org is already set
        */
        IF p_org_id is NOT NULL THEN
           pn_mo_cache_utils.fnd_req_set_org_id (p_org_id);
           /* uncomment to debug
              pnp_debug_pkg.log('Set the org id with value:' || to_char(pn_mo_cache_utils.get_current_org_id)); */
        END IF;

        IF p_location_code_from IS NOT NULL or p_location_code_to IS NOT NULL THEN
           IF p_property_name IS NOT NULL THEN
              OPEN calc_rec_amount_wloc_prop;
           ELSE
              OPEN calc_rec_amount_wloc;
           END IF;
        ELSE
           IF p_property_name IS NOT NULL THEN
              OPEN calc_rec_amount_woloc_prop;
           ELSE
              OPEN calc_rec_amount_woloc;
           END IF;
        END IF;

        LOOP

           IF calc_rec_amount_wloc_prop%ISOPEN THEN
               FETCH calc_rec_amount_wloc_prop INTO
                     l_rec_agreement_id
                     ,l_lease_id
                     ,l_location_id
                     ,l_customer_id
                     ,l_cust_site_id;
               EXIT WHEN calc_rec_amount_wloc_prop%NOTFOUND;
           ELSIF calc_rec_amount_wloc%ISOPEN THEN
               FETCH calc_rec_amount_wloc INTO
                     l_rec_agreement_id
                     ,l_lease_id
                     ,l_location_id
                     ,l_customer_id
                     ,l_cust_site_id;
               EXIT WHEN calc_rec_amount_wloc%NOTFOUND;
           ELSIF calc_rec_amount_woloc_prop%ISOPEN THEN
               FETCH calc_rec_amount_woloc_prop INTO
                     l_rec_agreement_id
                     ,l_lease_id
                     ,l_location_id
                     ,l_customer_id
                     ,l_cust_site_id;
               EXIT WHEN calc_rec_amount_woloc_prop%NOTFOUND;
           ELSIF calc_rec_amount_woloc%ISOPEN THEN
               FETCH calc_rec_amount_woloc INTO
                     l_rec_agreement_id
                     ,l_lease_id
                     ,l_location_id
                     ,l_customer_id
                     ,l_cust_site_id;
               EXIT WHEN calc_rec_amount_woloc%NOTFOUND;
           END IF;

           l_error := 'Success';
           l_error_code := null;

	   l_rec_calc_period_id := validate_create_calc_period(p_rec_agreement_id => l_rec_agreement_id
	                                                      ,p_start_date => l_start_date
							      ,p_end_date => l_end_date
							      ,p_as_of_date => l_as_of_date);
         IF  l_rec_calc_period_id <> -1
	 THEN

           l_processed := l_processed + 1;

           PN_REC_CALC_PKG.CALCULATE_REC_AMOUNT(
                                  p_rec_agreement_id        => l_rec_agreement_id
                                  ,p_lease_id               => l_lease_id
                                  ,p_location_id            => l_location_id
                                  ,p_customer_id            => l_customer_id
                                  ,p_cust_site_id           => l_cust_site_id
                                  ,p_rec_agr_line_id        => NULL
                                  ,p_rec_calc_period_id     => l_rec_calc_period_id
                                  ,p_calc_period_start_date => l_start_date
                                  ,p_calc_period_end_date   => l_end_date
                                  ,p_as_of_date             => l_as_of_date
                                  ,p_error                  => l_error
                                  ,p_error_code             => l_error_code
                                 );

          IF nvl(l_error_code,0) <> -99 THEN

                l_success_count := l_success_count + 1;
          ELSE
                l_fail_count := l_fail_count + 1;

          END IF;

         END IF; --l_rec_calc_period_id <> -1

        END LOOP;

        pnp_debug_pkg.put_log_msg('
===============================================================================');

        fnd_message.set_name ('PN','PN_RECALC_AGR_PROC');
        fnd_message.set_token ('NUM', l_processed);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        fnd_message.set_name ('PN','PN_RECALC_AGR_SUC');
        fnd_message.set_token ('NUM', l_success_count);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        fnd_message.set_name ('PN','PN_RECALC_AGR_FAIL');
        fnd_message.set_token ('NUM', l_fail_count);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        pnp_debug_pkg.put_log_msg('
===============================================================================');

        IF calc_rec_amount_wloc_prop%ISOPEN THEN
           CLOSE calc_rec_amount_wloc_prop;
        ELSIF calc_rec_amount_wloc%ISOPEN THEN
           CLOSE calc_rec_amount_wloc;
        ELSIF calc_rec_amount_woloc_prop%ISOPEN THEN
           CLOSE calc_rec_amount_woloc_prop;
        ELSIF calc_rec_amount_woloc%ISOPEN THEN
           CLOSE calc_rec_amount_woloc;
        END IF;

        pnp_debug_pkg.log('PN_REC_CALC_PKG.CALCULATE_REC_AMOUNT_BATCH (-) ');

EXCEPTION

When OTHERS Then
   pnp_debug_pkg.log('Error in PN_REC_CALC_PKG.CALCULATE_REC_AMOUNT_BATCH :'||to_char(sqlcode)||' : '||sqlerrm);
   Errbuf  := SQLERRM;
   Retcode := 2;
   rollback;
   raise;

END CALCULATE_REC_AMOUNT_BATCH;

/*=============================================================================+
 | PROCEDURE
 |    CALCULATE_REC_AMOUNT
 |
 | DESCRIPTION
 |    Calculate recovery amount for a recovery agreement(s)
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_rec_agreement_id
 |                    p_lease_id
 |                    p_location_id
 |                    p_customer_id
 |                    p_cust_site_id
 |                    p_rec_agr_line_id
 |                    p_rec_calc_period_id
 |                    p_calc_period_start_date
 |                    p_calc_period_end_date
 |                    P_as_of_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Calculate recovery amount for a recovery agreement(s)
 |
 | MODIFICATION HISTORY
 |
 | 07-APR-03  Daniel   o Created
 | 22-NOV-05  Kiran    o Changed csr_check_line_status, csr_check_period_line
 |                       calc_all_cons, calc_all_no_cons, calc_no_cons; replaced
 |                       pn_rec_agr_lines_all with pn_rec_agr_lines
 +============================================================================*/

PROCEDURE CALCULATE_REC_AMOUNT(
                               p_rec_agreement_id        IN NUMBER
                               ,p_lease_id               IN NUMBER
                               ,p_location_id            IN NUMBER
                               ,p_customer_id            IN NUMBER
                               ,p_cust_site_id           IN NUMBER
                               ,p_rec_agr_line_id        IN NUMBER   DEFAULT NULL
                               ,p_rec_calc_period_id     IN NUMBER   DEFAULT NULL
                               ,p_calc_period_start_date IN DATE
                               ,p_calc_period_end_date   IN DATE
                               ,p_as_of_date             IN DATE
                               ,p_error                 IN OUT NOCOPY VARCHAR2
                               ,p_error_code            IN OUT NOCOPY NUMBER
                              ) IS

  l_line_expenses            pn_rec_expcl_dtlln_all.computed_recoverable_amt%TYPE := 0;
  l_fee_before_contr         pn_rec_expcl_dtlln_all.cls_line_fee_before_contr_ovr%TYPE :=0;
  l_fee_after_contr          pn_rec_expcl_dtlln_all.cls_line_fee_after_contr_ovr%TYPE :=0;
  l_tot_prop_area            pn_rec_arcl_dtl_all.TOTAL_assignable_area%TYPE;
  l_ten_recoverable_area_rec ten_recoverable_area_rec;
  l_ten_recoverable_area     pn_rec_arcl_dtlln_all.occupied_area%TYPE:=0;
  l_ten_occupancy_pct        pn_rec_arcl_dtlln_all.occupancy_pct%TYPE:=0;
  l_billed_recovery          pn_rec_period_lines_all.billed_recovery%TYPE:=0;
  l_line_constraints         pn_rec_agr_linconst_all.value%TYPE:=0;
  l_line_abatements          pn_rec_agr_linabat_all.amount%TYPE:=0;
  l_ten_actual_recovery      pn_rec_period_lines_all.actual_recovery%TYPE:=0;
  l_contr_actual_recovery    pn_rec_period_lines_all.actual_recovery%TYPE:=0;
  l_amount_per_sft           NUMBER:=0;
  l_budget_amount_per_sft    NUMBER:=0;
  l_rate                     pn_rec_agr_lines_all.fixed_rate%TYPE:= 0;
  l_constrained_actual       pn_rec_period_lines_all.constrained_actual%TYPE:=0;
  l_constrained_budget       pn_rec_period_lines_all.constrained_actual%TYPE:=0;
  l_actual_prorata_share     pn_rec_period_lines_all.actual_prorata_share%TYPE:=0;
  l_reconciled_amount        pn_rec_period_lines_all.reconciled_amount%TYPE:=0;
  l_rowId                    ROWID:= NULL;
  l_rec_period_lines_id      pn_rec_period_lines_all.rec_period_lines_id%TYPE := NULL;
  l_creation_date            DATE        := SYSDATE;
  l_created_by               NUMBER      := NVL(fnd_profile.value('USER_ID'), 0);
  l_BUDGET_PCT               NUMBER:=0;
  l_TENANCY_START_DATE       DATE;
  l_TENANCY_END_DATE         DATE;
  l_STATUS                   VARCHAR2(30):=NULL;
  l_BUDGET_PRORATA_SHARE     NUMBER:=0;
  l_BUDGET_COST_PER_AREA     NUMBER:=0;
  l_BUDGET_RECOVERY          NUMBER:=0;
  l_BUDGET_EXPENSE           PN_REC_EXPCL_DTLLN_ALL.budgeted_amt%TYPE;
  l_count                    NUMBER := 0;
  i                          NUMBER := 0;
  l_prior_period_amount      pn_rec_period_lines_all.actual_recovery%TYPE:=0;
  l_prior_period_cap         pn_rec_period_lines_all.constrained_actual%TYPE:=0;
  l_rec_agr_line_id          pn_rec_period_lines_all.rec_agr_line_id%TYPE:= NULL;
  l_end_date                 pn_rec_period_lines_all.end_date%TYPE;
  l_billing_type             pn_rec_period_lines_all.billing_type%TYPE;
  l_billing_purpose          pn_rec_period_lines_all.billing_purpose%TYPE;
  l_error_code               NUMBER := 0;
  l_rec_agr_name             pn_rec_agreements_all.REC_AGREEMENT_NAME%TYPE;
  l_rec_agr_num              pn_rec_agreements_all.REC_AGREEMENT_NUM%TYPE;
     --------------------------------------------------------------------------
     -- Cursor to bring all details of a line. This cursor will be used in the
     -- event that the user chooses to hit the 'Calculate All' button and every
     -- line lying within the calc period needs to be picked up for recoery calc
     --------------------------------------------------------------------------

CURSOR csr_currency_code is
SELECT currency_code
       ,negative_recovery
       ,rec_agreement_name
       ,rec_agreement_num
       ,org_id
FROM   pn_rec_agreements_all
WHERE  rec_agreement_id = p_rec_agreement_id;

CURSOR agr_lines_all IS
     SELECT lines.rec_agr_line_id
            ,lines.type
            ,lines.purpose
            ,lines.start_date
            ,lines.end_date
            ,lines.calc_method
            ,lines.fixed_amount
            ,lines.fixed_rate
            ,lines.fixed_pct
            ,lines.multiple_pct
     FROM   pn_rec_agr_lines_all lines
     WHERE  lines.rec_agreement_id =  p_rec_agreement_id
     AND    p_as_of_date between lines.start_date AND end_date ;

     --------------------------------------------------------------------------
     -- Cursor to bring all details of a line. This cursor will be used in the
     -- event that the user chooses to hit the 'Calculate ' button and the line
     -- id is available.
     --------------------------------------------------------------------------
CURSOR agr_lines_one IS
     SELECT lines.rec_agr_line_id
            ,lines.type
            ,lines.purpose
            ,lines.start_date
            ,lines.end_date
            ,lines.calc_method
            ,lines.fixed_amount
            ,lines.fixed_rate
            ,lines.fixed_pct
            ,lines.multiple_pct
     FROM   pn_rec_agr_lines_all lines
     WHERE  lines.rec_agr_line_id =  p_rec_agr_line_id
     AND    p_as_of_date between lines.start_date AND end_date ;

CURSOR csr_check_line_status IS
     SELECT 'Y'
     FROM DUAL
     WHERE exists (SELECT NULL
                   FROM   pn_rec_period_lines_all plines
                          ,pn_rec_agr_lines_all   lines
                          ,pn_rec_calc_periods_all calc_periods
                   WHERE  lines.rec_agreement_id = p_rec_agreement_id
                   AND    p_as_of_date between lines.start_date and lines.end_date
                   AND    plines.rec_agr_line_id = lines.rec_agr_line_id
                   AND    plines.start_date     = p_calc_period_start_date
                   AND    plines.end_date       = p_calc_period_end_date
                   AND    UPPER(plines.status)         <> 'COMPLETE'
                   AND    calc_periods.rec_calc_period_id = plines.rec_calc_period_id
                   AND    calc_periods.start_date       = p_calc_period_start_date
                   AND    calc_periods.end_date         = p_calc_period_end_date
                   AND    calc_periods.as_of_date       = p_as_of_date
                  );

CURSOR csr_check_period_line IS
     SELECT 'Y'
     FROM DUAL
     WHERE not exists (SELECT NULL
                   FROM   pn_rec_period_lines_all plines
                          ,pn_rec_agr_lines_all  lines
                          ,pn_rec_calc_periods_all calc_periods
                   WHERE  lines.rec_agreement_id = p_rec_agreement_id
                   AND    p_as_of_date between lines.start_date and lines.end_date
                   AND    plines.rec_agr_line_id = lines.rec_agr_line_id
                   AND    plines.start_date     = p_calc_period_start_date
                   AND    plines.end_date       = p_calc_period_end_date
                   AND    calc_periods.rec_calc_period_id = plines.rec_calc_period_id
                   AND    calc_periods.start_date       = p_calc_period_start_date
                   AND    calc_periods.end_date         = p_calc_period_end_date
                   AND    calc_periods.as_of_date       = p_as_of_date
                   );
     --------------------------------------------------------------------------------------------------
     -- This cursor to be used in creating one term for all lines and when the user hits 'Calculate All'
     -- and consolidate option is set to 'Y'
     --------------------------------------------------------------------------------------------------

CURSOR calc_all_cons IS
     SELECT NVL(SUM(NVL(plines.reconciled_amount,0)),0) RECONCILED_AMOUNT
     FROM   pn_rec_period_lines_all plines
            ,pn_rec_calc_periods_all calc_periods
            ,pn_rec_agr_lines_all   lines
     WHERE  lines.rec_agreement_id = p_rec_agreement_id
     AND    plines.rec_agr_line_id = lines.rec_agr_line_id
     AND    plines.start_date      = p_calc_period_start_date
     AND    plines.end_date        = p_calc_period_end_date
     AND    UPPER(plines.status)          = 'COMPLETE'
     AND    calc_periods.rec_calc_period_id = plines.rec_calc_period_id
     AND    calc_periods.start_date       = p_calc_period_start_date
     AND    calc_periods.end_date         = p_calc_period_end_date
     AND    calc_periods.as_of_date       = p_as_of_date
     ;

CURSOR calc_all_no_cons IS
     SELECT plines.rec_agr_line_id
            ,plines.end_date
            ,NVL(plines.reconciled_amount,0) RECONCILED_AMOUNT
            ,plines.billing_type
            ,plines.billing_purpose
     FROM   pn_rec_period_lines_all plines
            ,pn_rec_calc_periods_all calc_periods
            ,pn_rec_agr_lines_all   lines
     WHERE  lines.rec_agreement_id = p_rec_agreement_id
     AND    plines.rec_agr_line_id = lines.rec_agr_line_id
     AND    plines.start_date      = p_calc_period_start_date
     AND    plines.end_date        = p_calc_period_end_date
     AND    UPPER(plines.status)          = 'COMPLETE'
     AND    calc_periods.rec_calc_period_id = plines.rec_calc_period_id
     AND    calc_periods.start_date       = p_calc_period_start_date
     AND    calc_periods.end_date         = p_calc_period_end_date
     AND    calc_periods.as_of_date       = p_as_of_date
     ;
     --------------------------------------------------------------------------------------------
     -- This cursor to be used in creating one term for a line and when the user hits 'Calculate'
     --------------------------------------------------------------------------------------------

CURSOR calc_no_cons IS
     SELECT plines.rec_agr_line_id
            ,plines.end_date
            ,nvl(plines.reconciled_amount,0) RECONCILED_AMOUNT
            ,plines.billing_type
            ,plines.billing_purpose
     FROM   pn_rec_period_lines_all plines
            ,pn_rec_calc_periods_all calc_periods
     WHERE  plines.rec_agr_line_id = p_rec_agr_line_id
     AND    plines.start_date      = p_calc_period_start_date
     AND    plines.end_date        = p_calc_period_end_date
     AND    upper(plines.status)   = 'COMPLETE'
     AND    calc_periods.rec_calc_period_id = plines.rec_calc_period_id
     AND    calc_periods.start_date       = p_calc_period_start_date
     AND    calc_periods.end_date         = p_calc_period_end_date
     AND    calc_periods.as_of_date       = p_as_of_date
     ;

/* PL/SQL table to store the constraints details */
line_constr_tbl g_line_constr_type;

  agr_lines_record     agr_lines_all%ROWTYPE;
  calc_all_no_cons_rec calc_all_no_cons%ROWTYPE;
  calc_all_cons_rec    calc_all_cons%ROWTYPE;
  calc_no_cons_rec     calc_no_cons%ROWTYPE;
  l_negative_recovery  pn_rec_agreements_all.negative_recovery%TYPE;
  l_opya_exists        BOOLEAN := FALSE;
  l_opyc_exists        BOOLEAN := FALSE;
  l_rate_amt_exists    BOOLEAN := FALSE;
  l_total_lines        NUMBER := 0;
  l_success_lines      NUMBER := 0;
  l_error_lines        NUMBER := 0;
  l_calculate_all      BOOLEAN := FALSE;
  l_open_exists        VARCHAR2(1) := 'N';
  l_no_prd_line        VARCHAR2(1) := 'N';

  l_consolidate VARCHAR2(30);
  l_org_id      NUMBER;

BEGIN

     pnp_debug_pkg.log('PN_REC_CALC_PKG.CALCULATE_REC_AMOUNT (+) ');

     /* Get currency code and negative recovery value for the agreement */

     FOR rec IN csr_currency_code LOOP
       g_currency_code := rec.currency_code;
       l_negative_recovery := rec.negative_recovery;
       l_rec_agr_name := rec.rec_agreement_name;
       l_rec_agr_num := rec.rec_agreement_num;
       l_org_id := rec.org_id;
     END LOOP;

     l_consolidate := NVL(pn_mo_cache_utils.get_profile_value('PN_REC_CONSOLIDATE_TERMS', l_org_id), 'N');

     pnp_debug_pkg.put_log_msg('                    ');
     fnd_message.set_name ('PN','PN_RECALC_AGR_NAME');
     fnd_message.set_token ('NAME', l_rec_agr_name);
     pnp_debug_pkg.put_log_msg(fnd_message.get);

     fnd_message.set_name ('PN','PN_RECALC_AGR_NUMBER');
     fnd_message.set_token ('NUM', l_rec_agr_num);
     pnp_debug_pkg.put_log_msg(fnd_message.get);

     pnp_debug_pkg.log('calculate_rec_amount - agreement id : '||p_rec_agreement_id);
     pnp_debug_pkg.log('calculate_rec_amount - agreement id : '||p_rec_agreement_id);
     pnp_debug_pkg.log('calculate_rec_amount - currency code : '||g_currency_code);
     pnp_debug_pkg.log('calculate_rec_amount - -ve rent rule : '||l_negative_recovery);

     IF p_rec_agr_line_id IS NULL THEN
        OPEN agr_lines_all;
        l_calculate_all := TRUE;
     ELSE
        OPEN agr_lines_one;
        l_calculate_all := FALSE;
     END IF;

     LOOP

           IF agr_lines_all%ISOPEN THEN
               FETCH agr_lines_all INTO agr_lines_record;
               EXIT WHEN agr_lines_all%NOTFOUND;
           ELSIF agr_lines_one%ISOPEN THEN
               FETCH agr_lines_one INTO agr_lines_record;
               EXIT WHEN agr_lines_one%NOTFOUND;
           END IF;

           l_total_lines := l_total_lines + 1;

           /* Initializing all variables used for calculation */

           p_error := 'Success';
           p_error_code := 0;
           l_line_expenses := 0;
           l_fee_before_contr := 0;
           l_fee_after_contr := 0;
           l_budget_expense := NULL;
           l_contr_actual_recovery := 0;
           l_ten_actual_recovery := 0;
           l_budget_recovery := 0;
           l_status := NULL;
           l_tot_prop_area := NULL;
           l_rate := 0;
           l_budget_cost_per_area := 0;
           l_ten_recoverable_area := 0;
           l_ten_occupancy_pct := 0;
           l_ten_recoverable_area_rec.occupied_area := NULL;
           l_ten_recoverable_area_rec.occupancy_pct := NULL;
           l_amount_per_sft := 0;
           l_budget_amount_per_sft := 0;
           l_billed_recovery := 0;
           l_prior_period_amount := 0;
           l_prior_period_cap := 0;
           l_line_abatements := 0;
           l_constrained_actual := 0;
           l_constrained_budget := 0;
           l_actual_prorata_share := 0;
           l_budget_prorata_share := 0;
           l_reconciled_amount := 0;
           l_rowId := NULL;
           l_rec_period_lines_id := NULL;
           l_BUDGET_PCT := 0;
           l_tenancy_start_date := NULL;
           l_tenancy_end_date := NULL;
           line_constr_tbl.delete;

           pnp_debug_pkg.log('Processing line id : '||agr_lines_record.rec_agr_line_id);

           /* Test for calculation Method */

           pnp_debug_pkg.log('Calculation Method : '||agr_lines_record.calc_method);

           IF agr_lines_record.calc_method <> 'FIXEDAMT' THEN

              -- Only if calculation method is either Prorata Share, Fixed Pct or Fixed Rate

              IF agr_lines_record.calc_method IN('PRORATSH','FIXEDPCT') THEN

                 pnp_debug_pkg.log('Calculation Method : Prorata Share/Fixed Pct - line id :'||agr_lines_record.rec_agr_line_id);
                 -- If calculation method is Prorata Share get the expenses for the line
                 -- and the total area of the property

                 pnp_debug_pkg.log('get_line_expenses....Agr line id : '||agr_lines_record.rec_agr_line_id);
                 pnp_debug_pkg.log('get_line_expenses - Customer id : '||p_customer_id);
                 pnp_debug_pkg.log('get_line_expenses - Lease id : '||p_lease_id);
                 pnp_debug_pkg.log('get_line_expenses - Location id : '||p_location_id);
                 pnp_debug_pkg.log('get_line_expenses - Start Date : '||p_calc_period_start_date);
                 pnp_debug_pkg.log('get_line_expenses - End Date : '||p_calc_period_end_date);

                 PN_REC_CALC_PKG.get_line_expenses(
                                           p_rec_agr_line_id        => agr_lines_record.rec_agr_line_id
                                           ,p_customer_id            => p_customer_id
                                           ,p_lease_id               => p_lease_id
                                           ,p_location_id            => p_location_id
                                           ,p_calc_period_start_date => p_calc_period_start_date
                                           ,p_calc_period_end_date   => p_calc_period_end_date
                                           ,p_calc_period_as_of_date => p_as_of_date
                                           ,p_recoverable_amt        => l_line_expenses
                                           ,p_fee_before_contr       => l_fee_before_contr
                                           ,p_fee_after_contr        => l_fee_after_contr
                                           ,p_error                  => p_error
                                           ,p_error_code             => p_error_code
                                           );

                 pnp_debug_pkg.log('get_line_expenses - Recoverable_amt : '||l_line_expenses);
                 pnp_debug_pkg.log('get_line_expenses - Fee Before Contr : '||l_fee_before_contr);
                 pnp_debug_pkg.log('get_line_expenses - Fee after contr : '||l_fee_after_contr);
                 pnp_debug_pkg.log('get_line_expenses - Return Status : '||p_error);
                 pnp_debug_pkg.log('get_line_expenses - Return Code : '||p_error_code);

                 IF p_error_code <> -99 THEN
                    l_budget_expense := PN_REC_CALC_PKG.get_budget_expenses(
                                          p_rec_agr_line_id         => agr_lines_record.rec_agr_line_id
                                           ,p_customer_id            => p_customer_id
                                           ,p_lease_id               => p_lease_id
                                           ,p_location_id            => p_location_id
                                           ,p_calc_period_start_date => p_calc_period_start_date
                                           ,p_calc_period_end_date   => p_calc_period_end_date
                                           ,p_calc_period_as_of_date => p_as_of_date
                                           );

                    IF l_budget_expense = -99 THEN

                       p_error_code := -99;
                       l_budget_expense := null;

                    ELSE
                       p_error_code := 0;

                    END IF;


                    pnp_debug_pkg.log('get_budget_expenses - Return Code : '||p_error_code);
                    pnp_debug_pkg.log('Budget Expense : '||l_budget_expense);

                 END IF;

                 pnp_debug_pkg.log('Error Code 1 : '||p_error_code);

                 IF p_error_code <> -99 THEN

                    l_contr_actual_recovery := PN_REC_CALC_PKG.get_contr_actual_recovery(
                                           p_rec_agr_line_id         => agr_lines_record.rec_agr_line_id
                                           ,p_customer_id            => p_customer_id
                                           ,p_lease_id               => p_lease_id
                                           ,p_location_id            => p_location_id
                                           ,p_calc_period_start_date => p_calc_period_start_date
                                           ,p_calc_period_end_date   => p_calc_period_end_date
                                           ,p_as_of_date             => p_as_of_date
                                           ,p_called_from            => 'CALC'
                                           );

                    IF l_contr_actual_recovery = -99 THEN

                       p_error_code := -99;
                       l_contr_actual_recovery := null;

                    ELSE
                       p_error_code := 0;

                    END IF;

                    pnp_debug_pkg.log('Contr Actual Recovery : '||l_contr_actual_recovery);

                 END IF;

                 pnp_debug_pkg.log('Error Code 2 : '||p_error_code);

                 /* If total expenses is greater than contributors prorata share
                    then subtract the contributors prorata share from total expenses.
                    Also apply the fee after contributors if the fee before
                    contributors has not been applied */

                 IF p_error_code <> -99 AND
                    nvl(l_line_expenses,0) >= nvl(l_contr_actual_recovery,0) THEN

                    /* Apply fee after contributor only if fee before contributor
                       has not been applied */

                    IF l_fee_before_contr = 0  THEN

                        l_line_expenses := (nvl(l_line_expenses,0) - nvl(l_contr_actual_recovery,0))
                                       + ((l_fee_after_contr / 100) *
                                         (nvl(l_line_expenses,0) - nvl(l_contr_actual_recovery,0)));

                        pnp_debug_pkg.log('get_line_expenses - expense after contr and fee : '||l_line_expenses);
                    ELSE

                        l_line_expenses := nvl(l_line_expenses,0) - nvl(l_contr_actual_recovery,0);
                        pnp_debug_pkg.log('get_line_expenses - expenses after contr : '||l_line_expenses);

                    END IF;


                 ELSIF p_error_code <> -99 AND
                       nvl(l_line_expenses,0) < nvl(l_contr_actual_recovery,0) THEN

                     l_line_expenses := 0;

                 END IF;

                 pnp_debug_pkg.log('Line expenses after contributors : '||l_line_expenses);


                 pnp_debug_pkg.log('Error Code 3 : '||p_error_code);

                 IF p_error_code <> -99 AND
                    agr_lines_record.calc_method = 'FIXEDPCT' AND
                    nvl(agr_lines_record.fixed_pct,0) <> 0 THEN

                 pnp_debug_pkg.log('Error Code 4 : '||p_error_code);
                      l_ten_actual_recovery  := l_line_expenses*agr_lines_record.fixed_pct/100;

                      l_budget_recovery  := l_budget_expense*agr_lines_record.fixed_pct/100;

                      l_status := 'COMPLETE';

                      pnp_debug_pkg.log('Calculation Method : Fixed Pct - tenant actual recovery :'||
                                        l_ten_actual_recovery||l_status);
                      p_error := 'Success';
                      p_error_code := 0;

                 ELSIF p_error_code <> -99 AND
                         agr_lines_record.calc_method = 'FIXEDPCT' AND
                         nvl(agr_lines_record.fixed_pct,0) = 0 THEN

                        pnp_debug_pkg.log('Error Code 5 : '||p_error_code);
                      l_ten_actual_recovery  := 0;
                      l_status               := 'ERROR';

                      fnd_message.set_name ('PN','PN_RECALC_PCT_NOT');
                      pnp_debug_pkg.put_log_msg(fnd_message.get);

                      p_error := 'Percentage not specified for Fixed Percentage calc. method';
                      p_error_code := -99;

                 -- END IF;

                  ELSIF p_error_code <> -99 AND
                    agr_lines_record.calc_method = 'PRORATSH' THEN

                        pnp_debug_pkg.log('Error Code 6 : '||p_error_code);
                 -- Only if calculation method is either Prorata Share, Fixed Pct or Fixed Rate


                 pnp_debug_pkg.log('get_tot_prop_area - Agr line id : '||agr_lines_record.rec_agr_line_id);
                 pnp_debug_pkg.log('get_tot_prop_area - Customer id : '||p_customer_id);
                 pnp_debug_pkg.log('get_tot_prop_area - Lease id : '||p_lease_id);
                 pnp_debug_pkg.log('get_tot_prop_area - Location id : '||p_location_id);
                 pnp_debug_pkg.log('get_tot_prop_area - Start Date : '||p_calc_period_start_date);
                 pnp_debug_pkg.log('get_tot_prop_area - End Date : '||p_calc_period_end_date);
                 pnp_debug_pkg.log('get_tot_prop_area - As of Date : '||p_as_of_date);

                    l_tot_prop_area := PN_REC_CALC_PKG.get_tot_prop_area(
                                          p_rec_agr_line_id         => agr_lines_record.rec_agr_line_id
                                              ,p_customer_id            => p_customer_id
                                              ,p_lease_id               => p_lease_id
                                              ,p_location_id            => p_location_id
                                              ,p_calc_period_start_date => p_calc_period_start_date
                                              ,p_calc_period_end_date   => p_calc_period_end_date
                                              ,p_as_of_date             => p_as_of_date
                                              );

                    IF l_tot_prop_area = -99 THEN

                       fnd_message.set_name ('PN','PN_RECALB_TOT_AR');
                       pnp_debug_pkg.put_log_msg(fnd_message.get);

                       p_error := 'Error while getting Total Property Area ';
                       p_error_code := -99;
                       l_tot_prop_area := 0;

                    ELSE
                       p_error := 'Success';
                       p_error_code := 0;
                       pnp_debug_pkg.log('Total Property Area : '||l_tot_prop_area);

                    END IF;


                        pnp_debug_pkg.log('Error Code 7 : '||p_error_code);
                    IF p_error_code <> -99 AND
                       (nvl(l_tot_prop_area,0) <> 0) AND
                       (nvl(l_line_expenses,0) <> 0) THEN

                        pnp_debug_pkg.log('Error Code 8 : '||p_error_code);
                       -- Compute the rate

                       l_rate := l_line_expenses/l_tot_prop_area;
                       pnp_debug_pkg.log('Calc. Method : Prorata Share - total expense :'||l_line_expenses);
                       pnp_debug_pkg.log('Calc. Method : Prorata Share - total area :'||l_tot_prop_area);

                    END IF;

                        pnp_debug_pkg.log('Error Code 9 : '||p_error_code);
                    IF p_error_code <> -99 AND
                       (nvl(l_tot_prop_area,0) <> 0) AND
                       nvl(l_budget_expense,0) <> 0 THEN

                        pnp_debug_pkg.log('Error Code 10 : '||p_error_code);
                        l_budget_cost_per_area := l_budget_expense/l_tot_prop_area;

                       pnp_debug_pkg.log('Calc. Method : Prorata Share - Budget total expense :'||l_budget_expense);
                       pnp_debug_pkg.log('Calc. Method : Prorata Share - Budget total area :'||l_tot_prop_area);
                    END IF;
                    ------------------------------------------------------------------------
                    -- Compute tenant's share of the area to be used in the calculation
                    -- The procedure returns a record with occupied area and the occupancy %
                    ------------------------------------------------------------------------

                        pnp_debug_pkg.log('Error Code 11 : '||p_error_code);
                    IF p_error_code <> -99 THEN

                        pnp_debug_pkg.log('Error Code 12 : '||p_error_code);
                      pnp_debug_pkg.log('ten_recoverable_areaAgr line id : '||agr_lines_record.rec_agr_line_id);
                      pnp_debug_pkg.log('ten_recoverable_area - Customer id : '||p_customer_id);
                      pnp_debug_pkg.log('ten_recoverable_area - Lease id : '||p_lease_id);
                      pnp_debug_pkg.log('ten_recoverable_area - Location id : '||p_location_id);
                      pnp_debug_pkg.log('ten_recoverable_area - Start Date : '||p_calc_period_start_date);
                      pnp_debug_pkg.log('ten_recoverable_area - End Date : '||p_calc_period_end_date);
                      pnp_debug_pkg.log('ten_recoverable_area - As of Date : '||p_as_of_date);

                      l_ten_recoverable_area_rec := PN_REC_CALC_PKG.ten_recoverable_area(
                                           p_rec_agr_line_id         => agr_lines_record.rec_agr_line_id
                                           ,p_customer_id            => p_customer_id
                                           ,p_lease_id               => p_lease_id
                                           ,p_location_id            => p_location_id
                                           ,p_calc_period_start_date => p_calc_period_start_date
                                           ,p_calc_period_end_date   => p_calc_period_end_date
                                           ,p_as_of_date             => p_as_of_date
                                           );

                       IF l_ten_recoverable_area_rec.occupied_area = -99 AND
                          l_ten_recoverable_area_rec.occupancy_pct = -99 THEN

                          l_ten_recoverable_area := 0;
                          l_ten_occupancy_pct    := 0;
                          p_error := 'Error getting tenant recoverable area';
                          p_error_code := -99;

                       ELSE

                          l_ten_recoverable_area := l_ten_recoverable_area_rec.occupied_area;
                          l_ten_occupancy_pct    := l_ten_recoverable_area_rec.occupancy_pct;
                          p_error := 'Success';
                          p_error_code := 0;

                          pnp_debug_pkg.log('Calc. Method : Prorata Share - tenant rec area :'
                                            ||l_ten_recoverable_area);
                          pnp_debug_pkg.log('Calc. Method : Prorata Share - tenant occ% :'
                                            ||l_ten_occupancy_pct);
                        END IF;

                        pnp_debug_pkg.log('Error Code 13 : '||p_error_code);
                    END IF;
                        pnp_debug_pkg.log('Error Code 14 : '||p_error_code);

                 END IF;   /* end of fixed pct and prorata share */

                        pnp_debug_pkg.log('Error Code 15 : '||p_error_code);
              ELSIF agr_lines_record.calc_method = 'FIXEDRT' THEN

                 pnp_debug_pkg.log('Calculation Method : Fixed Rate - line id :'||agr_lines_record.rec_agr_line_id);
                 -- For fixed rate we have the rate available and since the user puts
                 -- in the recoverable area occupancy % is 100%

                 l_rate := agr_lines_record.fixed_rate;
                 l_ten_recoverable_area := PN_REC_CALC_PKG.get_recoverable_area(
                                               p_rec_calc_period_id => p_rec_calc_period_id
                                              ,p_rec_agr_line_id   => agr_lines_record.rec_agr_line_id
                                                   );
                 IF l_ten_recoverable_area = -99 THEN

                    l_ten_recoverable_area := 0;
                    p_error := 'Error getting tenant rec. area for fixed rate';
                    p_error_code := -99;

                 ELSE

                    l_ten_occupancy_pct := 100;
                    p_error_code := 0;

                    pnp_debug_pkg.log('Calc. Method : Fixed Rate - tenant rec area :'
                                       ||l_ten_recoverable_area);
                    pnp_debug_pkg.log('Calc. Method : Fixed Rate - tenant occ% :'||
                                         l_ten_occupancy_pct);
                  END IF;

              END IF; /* end of all cal. methods */

              -- Calculate tenant's actual recovery

                        pnp_debug_pkg.log('Error Code 16 : '||p_error_code);
              IF p_error_code <> -99 AND
                 agr_lines_record.calc_method in ('FIXEDRT','PRORATSH')AND
                 (nvl(l_rate,0) <> 0) AND
                 (nvl(l_ten_recoverable_area,0) <> 0) AND
                 (nvl(l_ten_occupancy_pct,0) <> 0) THEN

                   l_amount_per_sft := l_rate*agr_lines_record.multiple_pct/100;

                   l_ten_actual_recovery := l_amount_per_sft*((l_ten_recoverable_area*l_ten_occupancy_pct)/100);

                   l_status  := 'COMPLETE';

                 pnp_debug_pkg.log('Calculation Method : Prorata Share/Fixed Rate - amount per sq ft :'||
                                    l_amount_per_sft);
                 pnp_debug_pkg.log('Calculation Method : Prorata Share/Fixed Rate - tenant actual recovery :'||l_ten_actual_recovery||l_status);

                        pnp_debug_pkg.log('Error Code 17 : '||p_error_code);
              ELSIF p_error_code <> -99 AND
                 agr_lines_record.calc_method in ('FIXEDRT','PRORATSH') AND
                 (nvl(l_rate,0) = 0 OR
                  nvl(l_ten_recoverable_area,0) = 0 OR
                  nvl(l_ten_occupancy_pct,0) = 0) THEN

                 l_ten_actual_recovery  := 0;
                 l_status  := 'ERROR';
                 p_error := 'Rate or recoverable Area or Occupancy pct is zero';
                 p_error_code := -99;
                 pnp_debug_pkg.log('Rate or recoverable Area or Occupancy pct is zero');
                 pnp_debug_pkg.log('Rate is ' || to_char(nvl(l_rate,0)));
                 pnp_debug_pkg.log('Recoverable Area is ' || to_char(nvl(l_ten_recoverable_area,0)));
                 pnp_debug_pkg.log('Occ. Pct. is ' || to_char(nvl(l_ten_occupancy_pct,0)));

              END IF;

                        pnp_debug_pkg.log('Error Code 18 : '||p_error_code);
              /* Get budget recovery for prorata share */
              IF p_error_code <> -99 AND
                 agr_lines_record.calc_method = 'PRORATSH' AND
                 nvl(l_budget_cost_per_area,0) <> 0 THEN

                 l_budget_amount_per_sft := l_budget_cost_per_area*agr_lines_record.multiple_pct/100;

                 l_budget_recovery := l_budget_amount_per_sft*((l_ten_recoverable_area*l_ten_occupancy_pct)/100);

              END IF;

           ELSIF p_error_code <> -99 AND agr_lines_record.calc_method = 'FIXEDAMT' THEN

                        pnp_debug_pkg.log('Error Code 19 : '||p_error_code);
              -- Tenant's actual recovery for fixed amount calc. method is user supplied
              l_status  := 'COMPLETE';
              l_ten_actual_recovery  := agr_lines_record.fixed_amount;

              pnp_debug_pkg.log('Calculation Method : Fixed Amount - tenant actual recovery :'||l_ten_actual_recovery);

           END IF; /* end of getting actual recovery for all calculation methods */

                        pnp_debug_pkg.log('Error Code 20 : '||p_error_code);
           IF p_error_code <> -99 THEN

              -- Calculate billed recovery, constraints and abatements.

                 pnp_debug_pkg.log('get_billed_recovery - Agr line id : '||
                                    agr_lines_record.rec_agr_line_id);
                 pnp_debug_pkg.log('get_billed_recovery - Payment Purpose: '||
                                    agr_lines_record.purpose);
                 pnp_debug_pkg.log('get_billed_recovery - Payment Type: '||
                                    agr_lines_record.type);
                 pnp_debug_pkg.log('get_billed_recovery - Lease id : '||p_lease_id);
                 pnp_debug_pkg.log('get_billed_recovery - Location id : '||p_location_id); -- 110403
                 pnp_debug_pkg.log('get_billed_recovery - Start Date : '||p_calc_period_start_date);
                 pnp_debug_pkg.log('get_billed_recovery - End Date : '||p_calc_period_end_date);
                 pnp_debug_pkg.log('get_billed_recovery - Calc Period Id : '||p_rec_calc_period_id);

                 l_billed_recovery := PN_REC_CALC_PKG.get_billed_recovery(
                                           p_payment_purpose        => agr_lines_record.purpose
                                          ,p_payment_type           => agr_lines_record.type
                                          ,p_lease_id               => p_lease_id
                                          ,p_location_id            => p_location_id -- 110403
                                          ,p_calc_period_start_date => p_calc_period_start_date
                                          ,p_calc_period_end_date   => p_calc_period_end_date
                                          ,p_rec_agr_line_id        => agr_lines_record.rec_agr_line_id
                                          ,p_rec_calc_period_id     => p_rec_calc_period_id
                                           );

                 IF l_billed_recovery = -99 THEN
                    p_error := 'error getting billed recovery';
                    p_error_code := -99;
                    l_billed_recovery := 0;
                 ELSE
                    p_error := 'Success';
                    p_error_code := 0;

                 END IF;

                 pnp_debug_pkg.log('Billed Recovery :'||l_billed_recovery);

              END IF;

                        pnp_debug_pkg.log('Error Code 21 : '||p_error_code);
              IF p_error_code <> -99 THEN

                 line_constr_tbl := PN_REC_CALC_PKG.get_line_constraints(
                                        p_rec_agr_line_id         => agr_lines_record.rec_agr_line_id ,
                                        p_as_of_date             => p_as_of_date
                                           );

                 IF (line_constr_tbl.count > 0)
                    AND (line_constr_tbl(1).constr_order = -99) THEN
                    p_error := 'Error getting line constraints';
                    p_error_code := -99;
                    line_constr_tbl.delete;

                 ELSE

                    p_error := 'Success';
                    p_error_code := 0;

                 END IF;

               END IF;

              pnp_debug_pkg.log('After getting constraints error code:'||p_error_code);
                        pnp_debug_pkg.log('Error Code 22 : '||p_error_code);
              IF p_error_code <> -99 THEN

                 l_prior_period_amount := PN_REC_CALC_PKG.get_prior_period_actual_amount(
                                         p_rec_agr_line_id         => agr_lines_record.rec_agr_line_id
                                         ,p_start_date             => p_calc_period_start_date
                                         ,p_as_of_date             => p_as_of_date
                                         ,p_called_from            => 'CALC'
                                           );

                 IF l_prior_period_amount = -99 THEN

                    p_error := 'Error getting prior period actual amount';
                    p_error_code := -99;
                    l_prior_period_amount := 0;

                 ELSE

                    p_error := 'Success';
                    p_error_code := 0;

                 END IF;

              END IF;

                        pnp_debug_pkg.log('Error Code 23 : '||p_error_code);
              IF p_error_code <> -99 THEN

                 l_prior_period_cap := PN_REC_CALC_PKG.get_prior_period_cap(
                                         p_rec_agr_line_id => agr_lines_record.rec_agr_line_id
                                         ,p_start_date     => p_calc_period_start_date
                                         ,p_end_date       => p_calc_period_end_date
                                         ,p_as_of_date     => p_as_of_date
                                         ,p_called_from    => 'CALC'
                                           );

                 IF l_prior_period_cap = -99 THEN

                    p_error := 'Error getting prior period actual cap';
                    p_error_code := -99;
                    l_prior_period_cap := 0;

                 ELSE

                    p_error := 'Success';
                    p_error_code := 0;

                 END IF;

              END IF;

                        pnp_debug_pkg.log('Error Code 24 : '||p_error_code);
              IF p_error_code <> -99 THEN

                  l_line_abatements := PN_REC_CALC_PKG.get_line_abatements(
                                          p_rec_agr_line_id         => agr_lines_record.rec_agr_line_id
                                          ,p_as_of_date             => p_as_of_date
                                           );

                 IF l_line_abatements = -99 THEN

                    p_error := 'Error getting line abatements';
                    p_error_code := -99;
                    l_line_abatements := 0;

                 ELSE

                    p_error := 'Success';
                    p_error_code := 0;

                 END IF;

                  pnp_debug_pkg.log('Abatements :'||l_line_abatements);

              END IF;


                        pnp_debug_pkg.log('Error Code 25 : '||p_error_code);
              IF p_error_code <> -99 THEN

                 /* Now apply the constraints on the actual recovery */

                 l_constrained_actual := l_ten_actual_recovery;
                 l_constrained_budget := l_budget_recovery;

                 /* Apply the Amount and Rate Constraints */

                 l_rate_amt_exists := FALSE;

                 FOR l_count in 1 .. line_constr_tbl.count
                 LOOP

                   IF (line_constr_tbl(l_count).scope = 'PRSH' and
                       line_constr_tbl(l_count).relation = 'MIN') THEN

                      l_rate_amt_exists := TRUE;

                      IF l_ten_actual_recovery < line_constr_tbl(l_count).value THEN
                         l_constrained_actual := line_constr_tbl(l_count).value;
                      ELSE
                         l_constrained_actual := l_ten_actual_recovery;
                      END IF;

                      IF l_budget_recovery < line_constr_tbl(l_count).value THEN
                         l_constrained_budget := line_constr_tbl(l_count).value;
                      ELSE
                         l_constrained_budget := l_budget_recovery;
                      END IF;

                   ELSIF (line_constr_tbl(l_count).scope = 'PRSH' and
                         line_constr_tbl(l_count).relation = 'MAX') THEN

                      l_rate_amt_exists := TRUE;


                      IF l_ten_actual_recovery > line_constr_tbl(l_count).value THEN
                         l_constrained_actual := line_constr_tbl(l_count).value;
                      ELSE
                         l_constrained_actual := l_ten_actual_recovery;
                      END IF;

                      IF l_budget_recovery > line_constr_tbl(l_count).value THEN
                         l_constrained_budget := line_constr_tbl(l_count).value;
                      ELSE
                         l_constrained_budget := l_budget_recovery;
                      END IF;

                   ELSIF (line_constr_tbl(l_count).scope = 'RATE'
                         and line_constr_tbl(l_count).relation = 'MIN') THEN

                      l_rate_amt_exists := TRUE;

                      pnp_debug_pkg.log('Min Rate Cons - amt per sqft : '||l_amount_per_sft);
                      pnp_debug_pkg.log('Min Rate Cons - Cons. value : '||line_constr_tbl(l_count).value);
                      l_rate_amt_exists := TRUE;

                      IF l_amount_per_sft < line_constr_tbl(l_count).value THEN
                         l_constrained_actual :=
                            (line_constr_tbl(l_count).value * agr_lines_record.multiple_pct/100) *
                          ((l_ten_recoverable_area* l_ten_occupancy_pct)/100);
                      ELSE
                         l_constrained_actual := l_ten_actual_recovery;
                      END IF;

                      IF l_budget_amount_per_sft < line_constr_tbl(l_count).value THEN
                         l_constrained_budget :=
                            (line_constr_tbl(l_count).value * agr_lines_record.multiple_pct/100) *
                            ((l_ten_recoverable_area* l_ten_occupancy_pct)/100);
                      ELSE
                         l_constrained_budget := l_budget_recovery;
                      END IF;


                   ELSIF (line_constr_tbl(l_count).scope = 'RATE'
                         and line_constr_tbl(l_count).relation = 'MAX') THEN

                      l_rate_amt_exists := TRUE;

                      pnp_debug_pkg.log('Max Rate Cons - amt per sqft : '||l_amount_per_sft);
                      pnp_debug_pkg.log('Max Rate Cons - Cons. value : '||line_constr_tbl(l_count).value);

                      IF l_amount_per_sft > line_constr_tbl(l_count).value THEN
                         l_constrained_actual :=
                                    (line_constr_tbl(l_count).value * agr_lines_record.multiple_pct/100) *
                             ((l_ten_recoverable_area*l_ten_occupancy_pct)/100);
                      ELSE
                         l_constrained_actual := l_ten_actual_recovery;
                      END IF;

                     IF l_budget_amount_per_sft > line_constr_tbl(l_count).value THEN
                         l_constrained_budget :=
                                    (line_constr_tbl(l_count).value * agr_lines_record.multiple_pct/100) *
                               ((l_ten_recoverable_area*l_ten_occupancy_pct)/100);
                      ELSE
                         l_constrained_budget := l_budget_recovery;
                      END IF;

                   END IF;
                END LOOP;
              END IF;

              pnp_debug_pkg.log('Constrained Actual after min/max cons : '||l_constrained_actual);
              pnp_debug_pkg.log('Constrained Budget after min/max cons : '||l_constrained_budget);

              /* If rate or amount type of constraints do not exists only then
                 apply the %age over prior year amount or %age over prior year
                 cap constraint */

                        pnp_debug_pkg.log('Error Code 26 : '||p_error_code);
              IF p_error_code <> -99 AND not l_rate_amt_exists THEN

                 /* verify that both %age over prior year amount or %age over prior year
                    cap type of constraints DO NOT exist */

                 l_opya_exists := FALSE;
                 l_opyc_exists := FALSE;

                 FOR l_count in 1 .. line_constr_tbl.count
                 LOOP

                      IF (line_constr_tbl(l_count).scope = 'OPYA'
                          and line_constr_tbl(l_count).relation = 'MAX') THEN

                         l_opya_exists := TRUE;

                      ELSIF (line_constr_tbl(l_count).scope = 'OPYC'
                          and line_constr_tbl(l_count).relation = 'MAX') THEN

                         l_opyc_exists := TRUE;

                      END IF;
                 END LOOP;

                 /* Error if both % over prior year actual and % over prior
                     year cap is entered */

                 IF l_opya_exists and l_opyc_exists THEN

                    fnd_message.set_name ('PN','PN_RECALC_CAP_EXT');
                    pnp_debug_pkg.put_log_msg(fnd_message.get);

                    p_error := 'Both cumulative and non-cumulative caps exists.';
                    p_error_code := -99;

                 ELSE

                 /* Apply the % over prior year constraint */

                 FOR l_count in 1 .. line_constr_tbl.count
                 LOOP

                    /* For the 1st calculation period there will be no
                       prior period and hence the l_prior_period_amount
                       is set to -1 */

                    IF (line_constr_tbl(l_count).scope = 'OPYA'
                        and line_constr_tbl(l_count).relation = 'MAX')
                        and l_prior_period_amount <> -1 THEN

                      pnp_debug_pkg.log('Prior Period Amount :'||l_prior_period_amount);
                      pnp_debug_pkg.log('OPYA - Actual Recovery :'||l_ten_actual_recovery);
                      pnp_debug_pkg.log('OPYA - Budget Recovery :'||l_budget_recovery);

                      IF l_ten_actual_recovery <
                         ((line_constr_tbl(l_count).value*l_prior_period_amount/100)+
                           l_prior_period_amount) THEN

                         l_constrained_actual := l_ten_actual_recovery;

                      ELSE

                         l_constrained_actual :=
                         ((line_constr_tbl(l_count).value*l_prior_period_amount/100)+
                           l_prior_period_amount);

                      END IF;

                      IF l_budget_recovery <
                         ((line_constr_tbl(l_count).value*l_prior_period_amount/100)+
                           l_prior_period_amount) THEN

                         l_constrained_budget := l_budget_recovery;

                      ELSE

                         l_constrained_budget :=
                         ((line_constr_tbl(l_count).value*l_prior_period_amount/100) +
                           l_prior_period_amount);

                      END IF;

                   ELSIF (line_constr_tbl(l_count).scope = 'OPYC'
                          and line_constr_tbl(l_count).relation = 'MAX')
                          and l_prior_period_cap <> -1 THEN

                      pnp_debug_pkg.log('Prior Period Cap :'||l_prior_period_cap);
                      pnp_debug_pkg.log('OPYC - Actual Recovery :'||l_ten_actual_recovery);
                      pnp_debug_pkg.log('OPYC - Budget Recovery :'||l_budget_recovery);

                      IF l_ten_actual_recovery < l_prior_period_cap THEN

                         l_constrained_actual := l_ten_actual_recovery;

                      ELSE

                         l_constrained_actual := l_prior_period_cap;

                      END IF;

                      IF l_budget_recovery < l_prior_period_cap THEN

                           l_constrained_budget := l_budget_recovery;

                      ELSE

                         l_constrained_budget := l_prior_period_cap;

                      END IF;

                   END IF;

                END LOOP;

                   pnp_debug_pkg.log('Constrained Actual :'||l_constrained_actual);
                   pnp_debug_pkg.log('Constrained Budget :'||l_constrained_budget);

              END IF;

             END IF;

             pnp_debug_pkg.log('Error Code 27 : '||p_error_code);

             IF p_error_code <> -99 THEN

               /* Apply abatements to actual */

               IF nvl(l_constrained_actual,0)   > nvl(l_line_abatements,0) THEN

                  l_actual_prorata_share := nvl(l_constrained_actual,0) - nvl(l_line_abatements,0);

               ELSE

                  l_actual_prorata_share := 0;

               END IF;

               pnp_debug_pkg.log('Actual Prorata Share :'||l_actual_prorata_share);

               /* Apply abatements to Budget */

               IF nvl(l_constrained_budget,0)   > nvl(l_line_abatements,0) THEN

                  l_budget_prorata_share := nvl(l_constrained_budget,0) - nvl(l_line_abatements,0);

               ELSE

                  l_budget_prorata_share := 0;

               END IF;

               pnp_debug_pkg.log('Budget Prorata Share :'||l_budget_prorata_share);

               /* Apply Billed Recovery to actual */

               IF nvl(l_actual_prorata_share,0) > nvl(l_billed_recovery,0) THEN

                  l_reconciled_amount    := nvl(l_actual_prorata_share,0) - nvl(l_billed_recovery,0);

               ELSE

                  /* If -ve rent, check if we need to credit. If yes then credit else set to 0 */

                  IF NVL(l_negative_recovery,'IGNORE') = 'IGNORE' THEN

                     l_reconciled_amount    := 0;

                  ELSE

                     l_reconciled_amount := nvl(l_actual_prorata_share,0) - nvl(l_billed_recovery,0);

                  END IF;

               END IF;

               pnp_debug_pkg.log('Reconciled Amount :'||l_reconciled_amount);

            END IF;

                        pnp_debug_pkg.log('Error Code 28 : '||p_error_code);
            IF p_error_code <> -99 THEN

              /* Check if recovery amount has already been calculated for the period start and
                 end dates and the as of date.If it has not, then insert a new record into the
                 PN_REC_PERIOD_LINES_ALL table with the calculated values or else update the
                 existing record with the values as a result of the re-calculation. */

              l_rec_period_lines_id  := PN_REC_CALC_PKG.find_if_period_line_exists(
                                            p_rec_agr_line_id     => agr_lines_record.rec_agr_line_id
                                            ,p_rec_calc_period_id => p_rec_calc_period_id);

              IF l_rec_period_lines_id = -99 THEN

                  p_error := 'Error checking for period line ';
                  p_error_code := -99;

              ELSE

                  p_error := 'Success';
                  p_error_code := 0;

              END IF;

              pnp_debug_pkg.log('Recovery period line id :'||l_rec_period_lines_id);

           END IF;

                        pnp_debug_pkg.log('Error Code 29 : '||p_error_code);
           IF p_error_code <> -99 and l_rec_period_lines_id IS NULL THEN

                 pnp_debug_pkg.log('Inserting into PN_REC_PERIOD_LINES_ALL ');

                 IF p_error_code = -99 THEN
                    l_status := 'Error';
                 ELSE
                    l_status := 'COMPLETE';
                 END IF;

                 PN_REC_CALC_PKG.INSERT_PERIOD_LINES_ROW(
                   X_ROWID                 => l_rowId
                   ,X_REC_PERIOD_LINES_ID  => l_rec_period_lines_id
                   ,X_BUDGET_PCT           => l_BUDGET_PCT
                   ,X_OCCUPANCY_PCT        => l_ten_occupancy_pct
                   ,X_MULTIPLE_PCT         => agr_lines_record.MULTIPLE_PCT
                   ,X_FIXED_PCT            => agr_lines_record.fixed_pct
                   ,X_TENANCY_START_DATE   => l_tenancy_start_date
                   ,X_TENANCY_END_DATE     => l_tenancy_end_date
                   ,X_STATUS               => l_status
                   ,X_BUDGET_PRORATA_SHARE => l_BUDGET_PRORATA_SHARE
                   ,X_BUDGET_COST_PER_AREA => l_BUDGET_COST_PER_AREA
                   ,X_TOTAL_AREA           => l_tot_prop_area
                   ,X_TOTAL_EXPENSE        => l_line_expenses
                   ,X_RECOVERABLE_AREA     => l_ten_recoverable_area
                   ,X_ACTUAL_RECOVERY      => l_ten_actual_recovery
                   ,X_CONSTRAINED_ACTUAL   => l_constrained_actual
                   ,X_ABATEMENTS           => l_line_abatements
                   ,X_ACTUAL_PRORATA_SHARE => l_actual_prorata_share
                   ,X_BILLED_RECOVERY      => l_billed_recovery
                   ,X_RECONCILED_AMOUNT    => l_reconciled_amount
                   ,X_BUDGET_RECOVERY      => l_BUDGET_RECOVERY
                   ,X_BUDGET_EXPENSE       => l_BUDGET_EXPENSE
                   ,X_REC_CALC_PERIOD_ID   => p_REC_CALC_PERIOD_ID
                   ,X_REC_AGR_LINE_ID      => agr_lines_record.REC_AGR_LINE_ID
                   ,X_AS_OF_DATE           => p_AS_OF_DATE
                   ,X_START_DATE           => p_calc_period_START_DATE
                   ,X_END_DATE             => p_calc_period_END_DATE
                   ,X_BILLING_TYPE         => agr_lines_record.type
                   ,X_BILLING_PURPOSE      => agr_lines_record.purpose
                   ,X_CUST_ACCOUNT_ID      => p_customer_id
                   ,X_CREATION_DATE        => l_creation_date
                   ,X_CREATED_BY           => l_created_by
                   ,X_LAST_UPDATE_DATE     => l_creation_date
                   ,X_LAST_UPDATED_BY      => l_created_by
                   ,X_LAST_UPDATE_LOGIN    => l_created_by
                   ,X_ERROR_CODE           => l_error_code);

                   IF l_error_code = -99 THEN

                      p_error := 'Error inserting into period lines';
                      p_error_code := -99;

                   ELSE

                      p_error := 'Success';
                      p_error_code := 0;

                   END IF;

              ELSIF p_error_code <> -99 AND l_rec_period_lines_id is not null THEN
                        pnp_debug_pkg.log('Error Code 30 : '||p_error_code);

                 pnp_debug_pkg.log('Updating PN_REC_PERIOD_LINES_ALL ');

                 IF p_error_code = -99 THEN
                    l_status := 'Error';
                 ELSE
                    l_status := 'COMPLETE';
                 END IF;

                 PN_REC_CALC_PKG.UPDATE_PERIOD_LINES_ROW(
                   X_REC_PERIOD_LINES_ID   => l_rec_period_lines_id
                   ,X_BUDGET_PCT           => l_BUDGET_PCT
                   ,X_OCCUPANCY_PCT        => l_ten_occupancy_pct
                   ,X_MULTIPLE_PCT         => agr_lines_record.MULTIPLE_PCT
                   ,X_FIXED_PCT            => agr_lines_record.fixed_pct
                   ,X_TENANCY_START_DATE   => l_TENANCY_START_DATE
                   ,X_TENANCY_END_DATE     => l_TENANCY_END_DATE
                   ,X_STATUS               => l_status
                   ,X_BUDGET_PRORATA_SHARE => l_BUDGET_PRORATA_SHARE
                   ,X_BUDGET_COST_PER_AREA => l_BUDGET_COST_PER_AREA
                   ,X_TOTAL_AREA           => l_tot_prop_area
                   ,X_TOTAL_EXPENSE        => l_line_expenses
                   ,X_RECOVERABLE_AREA     => l_ten_recoverable_area
                   ,X_ACTUAL_RECOVERY      => l_ten_actual_recovery
                   ,X_CONSTRAINED_ACTUAL   => l_constrained_actual
                   ,X_ABATEMENTS           => l_line_abatements
                   ,X_ACTUAL_PRORATA_SHARE => l_actual_prorata_share
                   ,X_BILLED_RECOVERY      => l_billed_recovery
                   ,X_RECONCILED_AMOUNT    => l_reconciled_amount
                   ,X_BUDGET_RECOVERY      => l_BUDGET_RECOVERY
                   ,X_BUDGET_EXPENSE       => l_BUDGET_EXPENSE
                   ,X_REC_CALC_PERIOD_ID   => p_REC_CALC_PERIOD_ID
                   ,X_REC_AGR_LINE_ID      => agr_lines_record.REC_AGR_LINE_ID
                   ,X_AS_OF_DATE           => p_AS_OF_DATE
                   ,X_START_DATE           => p_calc_period_START_DATE
                   ,X_END_DATE             => p_calc_period_END_DATE
                   ,X_BILLING_TYPE         => agr_lines_record.type
                   ,X_BILLING_PURPOSE      => agr_lines_record.purpose
                   ,X_CUST_ACCOUNT_ID      => p_customer_id
                   ,X_LAST_UPDATE_DATE     => l_creation_date
                   ,X_LAST_UPDATED_BY      => l_created_by
                   ,X_LAST_UPDATE_LOGIN    => l_created_by
                   ,X_ERROR_CODE           => l_error_code);

                   IF l_error_code = -99 THEN

                      p_error := 'Error updating into period lines';
                      p_error_code := -99;

                   ELSE

                      p_error := 'Success';
                      p_error_code := 0;

                   END IF;

              END IF;


            IF p_error_code = -99 THEN
               l_error_lines := l_error_lines + 1;
            ELSE
               l_success_lines := l_success_lines + 1;
            END IF;

     END LOOP;

     pnp_debug_pkg.put_log_msg('                                     ');
     pnp_debug_pkg.put_log_msg('===============================================================================');

     fnd_message.set_name ('PN','PN_RECALC_LINE_PROC');
     fnd_message.set_token ('NUM', l_total_lines);
     pnp_debug_pkg.put_log_msg(fnd_message.get);

     fnd_message.set_name ('PN','PN_RECALC_LINE_SUC');
     fnd_message.set_token ('NUM', l_success_lines);
     pnp_debug_pkg.put_log_msg(fnd_message.get);

     fnd_message.set_name ('PN','PN_RECALC_LINE_FAIL');
     fnd_message.set_token ('NUM', l_error_lines);
     pnp_debug_pkg.put_log_msg(fnd_message.get);

     pnp_debug_pkg.put_log_msg('===============================================================================');

     IF agr_lines_all%ISOPEN THEN
        CLOSE agr_lines_all;
     ELSIF agr_lines_one%ISOPEN THEN
        CLOSE agr_lines_one;
     END IF;

     /* Commit the record in pn_rec_period_lines */

     COMMIT;

     IF l_consolidate = 'Y' THEN

        /* Check to see if calculation has been successfully done for all lines */

       /* Check to see if there are period lines with error status */
       OPEN csr_check_line_status;
       FETCH csr_check_line_status into l_open_exists;
       IF csr_check_line_status%NOTFOUND THEN
          l_open_exists := 'N';
       END IF;
       CLOSE csr_check_line_status;

       /* Check to see if calculation has not been done for a line */
       OPEN csr_check_period_line;
       FETCH csr_check_period_line into l_no_prd_line;
       IF csr_check_period_line%NOTFOUND THEN
          l_no_prd_line := 'N';
       END IF;
       CLOSE csr_check_period_line;


      END IF;


       pnp_debug_pkg.log('Consolidate Terms - Yes/No :'||l_consolidate);

       IF l_consolidate = 'Y' and
          (l_open_exists = 'Y' OR l_no_prd_line = 'Y') THEN

         fnd_message.set_name ('PN','PN_RECALC_LN_INCOM');
         pnp_debug_pkg.put_log_msg(fnd_message.get);

         fnd_message.set_name ('PN','PN_RECALC_BT_NOT_CRTD');
         pnp_debug_pkg.put_log_msg(fnd_message.get);

        p_error := 'Calculation not successful for all lines';
        p_error_code := -99;

       ELSIF (l_consolidate = 'Y' and (l_open_exists = 'N' AND l_no_prd_line = 'N')) OR
             (l_consolidate = 'N') THEN

             pnp_debug_pkg.log('Creating Term(s).....');

             pnp_debug_pkg.log('Consolidate Terms - Yes/No :'||l_consolidate);

             IF l_calculate_all AND l_consolidate = 'Y' THEN

               /* get the sum of reconciled amount for all the lines for the
                  recovery agreement */

                pnp_debug_pkg.log('Opening cursor for Calculate All and Consolidate Terms');
                pnp_debug_pkg.log('Agreement Id '|| p_rec_agreement_id);

                OPEN calc_all_cons;

             ELSIF l_calculate_all AND l_consolidate = 'N' THEN

               /* get the reconciled amounts for all the lines of the agreement for which
                  calculation has been successfully */

                pnp_debug_pkg.log('Opening cursor for Calculate All and no consolidation');
                pnp_debug_pkg.log('Agreement Id '|| p_rec_agreement_id);

                OPEN calc_all_no_cons;

             ELSIF not l_calculate_all AND l_consolidate = 'Y' THEN

               /* get the sum of reconciled amount for all the lines for the
                  recovery agreement of the line passed to the routine */

                pnp_debug_pkg.log('Opening cursor for Calculate and Consolidate Terms');
                pnp_debug_pkg.log('Agreement Id '|| p_rec_agreement_id);

                OPEN calc_all_cons;

             ELSIF not l_calculate_all AND l_consolidate = 'N' THEN

               /* get the reconciled amount for the lines which was passed to the calculate
                  routine and for which the calculation has been successful */

                pnp_debug_pkg.log('Opening cursor for Calculate and no consolidation');
                pnp_debug_pkg.log('Agreement Line Id '|| p_rec_agr_line_id);
                OPEN calc_no_cons;

              END IF;

              LOOP

                IF calc_all_cons%ISOPEN THEN

                    FETCH calc_all_cons INTO calc_all_cons_rec;
                    EXIT WHEN calc_all_cons%NOTFOUND;

                ELSIF calc_all_no_cons%ISOPEN THEN

                    FETCH calc_all_no_cons INTO calc_all_no_cons_rec;
                    EXIT WHEN calc_all_no_cons%NOTFOUND;

                ELSIF calc_no_cons%ISOPEN THEN

                    FETCH calc_no_cons INTO calc_no_cons_rec;
                    EXIT WHEN calc_no_cons%NOTFOUND;

                END IF;

                IF (l_consolidate = 'Y')THEN
                    l_rec_agr_line_id   := -1;
                    l_end_date          := p_calc_period_end_date;
                    l_reconciled_amount := calc_all_cons_rec.reconciled_amount;
                    l_rec_agr_line_id   := NULL;
                ELSE

                  IF calc_all_no_cons%ISOPEN THEN

                    l_rec_agr_line_id   := calc_all_no_cons_rec.rec_agr_line_id;
                    l_end_date          := calc_all_no_cons_rec.end_date;
                    l_reconciled_amount := calc_all_no_cons_rec.reconciled_amount;
                    l_billing_type      := calc_all_no_cons_rec.billing_type;
                    l_billing_purpose   := calc_all_no_cons_rec.billing_purpose;

                  ELSIF calc_no_cons%ISOPEN THEN

                    l_rec_agr_line_id   := calc_no_cons_rec.rec_agr_line_id;
                    l_end_date          := calc_no_cons_rec.end_date;
                    l_reconciled_amount := calc_no_cons_rec.reconciled_amount;
                    l_billing_type      := calc_no_cons_rec.billing_type;
                    l_billing_purpose   := calc_no_cons_rec.billing_purpose;

                   END IF;

                END IF;

                pnp_debug_pkg.log('Line Id :'||l_rec_agr_line_id);
                pnp_debug_pkg.log('Term start Date :'||l_end_date);
                pnp_debug_pkg.log(' Lease Id :'||p_lease_id);
                pnp_debug_pkg.log(' Reconciled Amount:'||l_reconciled_amount);
                pnp_debug_pkg.log('Calc Period Id :'||p_rec_calc_period_id);
                pnp_debug_pkg.log('Calc Period End date :'||l_end_date);
                pnp_debug_pkg.log('Agreement Id :'||p_rec_agreement_id);
                pnp_debug_pkg.log('Location Id :'||p_location_id);
                pnp_debug_pkg.log('Billing Type :'||l_billing_type);
                pnp_debug_pkg.log('Billing Purpose :'||l_billing_purpose);

                IF l_rec_agr_line_id is null THEN
                   l_rec_agr_line_id := -1;
                   pnp_debug_pkg.log('Set Line Id to -1');
                END IF;

                pnp_debug_pkg.log('Before calling PN_REC_CALC_PKG.create_payment_terms '|| p_error_code);
                p_error_code := 0; --Initialize p_error_code Fix for bug#9091777

                PN_REC_CALC_PKG.create_payment_terms(
                      p_lease_id             => p_lease_id
                     ,p_payment_amount       => l_reconciled_amount
                     ,p_rec_calc_period_id   => p_rec_calc_period_id
                     ,p_calc_period_end_date => l_end_date
                     ,p_rec_agreement_id     => p_rec_agreement_id
                     ,p_rec_agr_line_id      => l_rec_agr_line_id
                     ,p_location_id          => p_location_id
                     ,p_amount_type          => 'CAM'
                     ,p_org_id               => l_org_id
                     ,p_billing_type         => l_billing_type
                     ,p_billing_purpose      => l_billing_purpose
                     ,p_customer_id          => p_customer_id
                     ,p_cust_site_id         => p_cust_site_id
                     ,p_consolidate          => l_consolidate
                     ,p_error                => p_error
                     ,p_error_code           => p_error_code
                     );
                pnp_debug_pkg.log('After calling PN_REC_CALC_PKG.create_payment_terms '|| p_error_code);

                 IF p_error_code = -99 THEN
                    IF l_consolidate = 'Y' AND l_calculate_all THEN
                pnp_debug_pkg.log('Rolling Back Lines for l_consolidate = Y and l_calculate_all');

                       ROLLBACK;
                       UPDATE pn_rec_period_lines_all
                           SET STATUS = 'Error'
                       WHERE rec_agr_line_id in (SELECT rec_agr_line_id
                                              FROM PN_REC_AGR_LINES_ALL
                                              WHERE rec_agreement_id = p_rec_agreement_id)
                       AND start_date = p_calc_period_start_date
                       AND end_date = p_calc_period_end_date
                       AND rec_calc_period_id = p_rec_calc_period_id;
                       COMMIT;

                    ELSE
                pnp_debug_pkg.log('Rolling Back Lines for Else Part of l_consolidate = Y and l_calculate_all');
                       ROLLBACK;
                       UPDATE pn_rec_period_lines_all
                           SET STATUS = 'Error'
                       WHERE rec_agr_line_id = l_rec_agr_line_id
                       AND start_date = p_calc_period_start_date
                       AND end_date = p_calc_period_end_date
                       AND rec_calc_period_id = p_rec_calc_period_id;
                       COMMIT;

                     END IF;

                  ELSE

                     COMMIT;

                  END IF;

              END LOOP;

        END IF;

        pnp_debug_pkg.log('PN_REC_CALC_PKG.CALCULATE_REC_AMOUNT (-) ');

EXCEPTION

When OTHERS Then
        pnp_debug_pkg.log('PN_REC_CALC_PKG.CALCULATE_REC_AMOUNT '|| to_char(sqlcode));

END CALCULATE_REC_AMOUNT;

/*===========================================================================+
 | FUNCTION
 |    GET_RECOVERABLE_AREA
 |
 | DESCRIPTION
 |    Gets recoverable area from pn_rec_period_lines_all table
 |    for a line if the calc method is 'Fixed rate'
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                  p_rec_period_lines_id
 |                  p_rec_agr_line_id
 |                  p_start_date
 |                  p_end_date
 |                  p_as_of_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gets recoverable area from pn_rec_period_lines_all table
 |              for a line if the calc method is 'Fixed rate'
 |
 | MODIFICATION HISTORY
 |
 |     19-MAY-2003  Daniel Thota  o Created
 +===========================================================================*/
FUNCTION get_recoverable_area (
         p_rec_calc_period_id  pn_rec_period_lines_all.rec_calc_period_id%TYPE
         ,p_rec_agr_line_id    pn_rec_period_lines_all.rec_agr_line_id%TYPE
                              )
      RETURN pn_rec_period_lines_all.recoverable_area%TYPE IS

      l_recoverable_area pn_rec_period_lines_all.recoverable_area%TYPE;

   BEGIN

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_recoverable_area (+) ');

     SELECT NVL(plines.recoverable_area,0)
     INTO   l_recoverable_area
     FROM   pn_rec_period_lines_all plines
     WHERE  plines.rec_agr_line_id    = p_rec_agr_line_id
     AND    plines.rec_calc_period_id = p_rec_calc_period_id
     ;

      pnp_debug_pkg.log('PN_REC_CALC_PKG.get_recoverable_area (-) ');

      RETURN l_recoverable_area;


   EXCEPTION

      WHEN OTHERS
      THEN
        fnd_message.set_name ('PN','PN_RECALB_TNT_AR');
        pnp_debug_pkg.put_log_msg(fnd_message.get||' '||to_char(sqlcode));
         RETURN -99;


END get_recoverable_area;

/*===========================================================================+
 | FUNCTION
 |    GET_TOT_PROP_AREA
 |
 | DESCRIPTION
 |    Gets recoverable area from pn_rec_period_lines_all table
 |    for a line if the calc method is 'Fixed rate'
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                  p_rec_period_lines_id
 |                  p_rec_agr_line_id
 |                  p_start_date
 |                  p_end_date
 |                  p_as_of_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gets recoverable area from pn_rec_period_lines_all table
 |              for a line if the calc method is 'Fixed rate'
 |
 | MODIFICATION HISTORY
 |
 |     19-MAY-2003  Daniel Thota  o Created
 |     22-Aug-2003  Ashish        oBug#3107849 added the code to return
 |                                 the total_area based on area_type
 |     26-Apr-2010  asahoo        o Bug#9579092, fixed the wrong comparision of l_area_class_dtl_id with area_class_dtl_line_id
 +===========================================================================*/
FUNCTION get_tot_prop_area (
         p_rec_agr_line_id         pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_customer_id            pn_rec_agreements_all.customer_id%TYPE
         ,p_lease_id               pn_rec_agreements_all.lease_id%TYPE
         ,p_location_id            pn_rec_agreements_all.location_id%TYPE
         ,p_calc_period_start_date pn_rec_calc_periods_all.start_date%TYPE
         ,p_calc_period_end_date   pn_rec_calc_periods_all.end_date%TYPE
         ,p_as_of_date             pn_rec_calc_periods_all.as_of_date%TYPE
                           )
      RETURN pn_rec_arcl_dtl_all.TOTAL_assignable_area%TYPE IS

      l_tot_prop_area         pn_rec_arcl_dtl_all.TOTAL_assignable_area%TYPE;
      l_total_occp_area       pn_rec_arcl_dtl_all.TOTAL_OCCUPIED_AREA%Type;
      l_total_wgt_avg_area    pn_rec_arcl_dtl_all.TOTAL_WEIGHTED_AVG%Type;
      l_floor_pct             pn_rec_agr_linarea_all.FLOOR_PCT%Type;
      l_area_type             pn_rec_agr_linarea_all.area_type%Type;
      l_area_class_dtl_id     pn_rec_arcl_dtl_all.area_class_dtl_id%Type;
      l_asgn_area_contr       pn_rec_arcl_dtlln_all.ASSIGNABLE_AREA%Type;
      l_occp_area_contr       pn_rec_arcl_dtlln_all.occupied_area%Type;
      l_wgt_avg_area_contr    pn_rec_arcl_dtlln_all.WEIGHTED_AVG%Type;
      l_net_asgn_area         pn_rec_arcl_dtlln_all.ASSIGNABLE_AREA%Type;
      l_net_occp_area        pn_rec_arcl_dtlln_all.ASSIGNABLE_AREA%Type;
      l_net_wgt_avg_area     pn_rec_arcl_dtlln_all.ASSIGNABLE_AREA%Type;
      l_floor_area           pn_rec_arcl_dtl_all.TOTAL_assignable_area%TYPE;
      l_greater_area         pn_rec_arcl_dtlln_all.ASSIGNABLE_AREA%Type;
      l_context               VARCHAR2(2000):= null;

    cursor c_area is
     SELECT area_class_dtl_hdr.TOTAL_assignable_area
            ,nvl(area_class_dtl_hdr.TOTAL_OCCUPIED_AREA_ovr,area_class_dtl_hdr.TOTAL_OCCUPIED_AREA)
            ,nvl(area_class_dtl_hdr.TOTAL_WEIGHTED_AVG_ovr, area_class_dtl_hdr.TOTAL_WEIGHTED_AVG)
            ,linearea.FLOOR_PCT
            ,linearea.area_type
            ,area_class_dtl_hdr.area_class_dtl_id
     FROM   pn_rec_arcl_dtlln_all   area_class_dtl_lines
            ,pn_rec_arcl_dtl_all    area_class_dtl_hdr
            ,pn_rec_agr_linarea_all linearea
            ,pn_rec_arcl_all        aclass
     WHERE  linearea.rec_agr_line_id               = p_rec_agr_line_id
     AND    p_as_of_date between linearea.start_date and linearea.end_date
     AND    linearea.area_class_id                 = aclass.area_class_id
     AND    area_class_dtl_hdr.area_class_id       = aclass.area_class_id
     AND    area_class_dtl_hdr.as_of_date          = p_as_of_date
     AND    area_class_dtl_hdr.from_date           = p_calc_period_start_date
     AND    area_class_dtl_hdr.to_date             = p_calc_period_end_date
     AND    area_class_dtl_lines.area_class_dtl_id = area_class_dtl_hdr.area_class_dtl_id
     AND    area_class_dtl_lines.cust_account_id   = p_customer_id
     AND    area_class_dtl_lines.lease_id          = p_lease_id
     AND    area_class_dtl_lines.location_id       = p_location_id
     ;
   BEGIN

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_tot_prop_area (+) ');

     l_context := 'getting area type';

     open c_area;
     fetch c_area INTO l_tot_prop_area ,
            l_total_occp_area,
            l_total_wgt_avg_area,
            l_floor_pct,
            l_area_type,
            l_area_class_dtl_id;
     if c_area%NotFound then
        l_tot_prop_area := -99;
        close c_area;
        fnd_message.set_name ('PN','PN_RECALB_AR_NF');
        pnp_debug_pkg.put_log_msg(fnd_message.get);
        RETURN l_tot_prop_area;
     end if;

      l_context := 'getting contributors';

      pnp_debug_pkg.log('9579092 l_area_class_dtl_id ' ||l_area_class_dtl_id);
      SELECT NVL(SUM(ASSIGNABLE_AREA),0),
           NVL(SUM(NVL(occupied_area_ovr, occupied_area)),0),
           NVL(SUM (NVL( WEIGHTED_AVG_OVR, WEIGHTED_AVG)),0)
        INTO
             l_asgn_area_contr,
             l_occp_area_contr,
             l_wgt_avg_area_contr
        FROM pn_rec_arcl_dtlln_all area_class_dtl
        --WHERE area_class_dtl_line_id = l_area_class_dtl_id
        -- Fix for bug#9579092, l_area_class_dtl_id is wrongly compared with area_class_dtl_line_id
        WHERE area_class_dtl_id = l_area_class_dtl_id
        AND exclude_area_ovr_flag = 'Y'
        AND include_flag ='Y';

       l_context := 'deriving applicable area ';

       l_net_asgn_area := l_tot_prop_area - l_asgn_area_contr;
       l_net_occp_area := l_total_occp_area - l_occp_area_contr;
       l_net_wgt_avg_area := l_total_wgt_avg_area - l_wgt_avg_area_contr;
       l_floor_area       := l_net_asgn_area*nvl(l_floor_pct,100)/100;
       l_greater_area     := null;

       if l_area_type = 'OCUPD' then
          l_greater_area  := l_net_occp_area;
       elsif l_area_type = 'TAROC' then
           if l_floor_area < l_net_occp_area then
              l_greater_area := l_net_occp_area;
           else
               l_greater_area := l_floor_area;
           end if;
        elsif  l_area_type = 'TARWA' then
           if l_floor_area < l_net_wgt_avg_area then
              l_greater_area := l_net_wgt_avg_area;
           else
               l_greater_area := l_floor_area;
           end if;
        elsif  l_area_type = 'TASGN' then
               l_greater_area := l_net_asgn_area;
        elsif  l_area_type = 'WTAVG' then
              l_greater_area := l_net_wgt_avg_area;
        end if;
        l_tot_prop_area := l_greater_area;

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_tot_prop_area (-) ');

      RETURN l_tot_prop_area;

   EXCEPTION

      WHEN OTHERS THEN
         pnp_debug_pkg.log(substrb('Error in get_tot_prop_area - '|| l_context,1,244));
         pnp_debug_pkg.log('Error in get_tot_prop_area - '|| to_char(sqlcode));
         RETURN -99;


END get_tot_prop_area;

/*===========================================================================+
 | FUNCTION
 |    TEN_RECOVERABLE_AREA
 |
 | DESCRIPTION
 |    Gets recoverable area from pn_rec_period_lines_all table
 |    for a line if the calc method is 'Fixed rate'
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                  p_rec_period_lines_id
 |                  p_rec_agr_line_id
 |                  p_start_date
 |                  p_end_date
 |                  p_as_of_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gets recoverable area from pn_rec_period_lines_all table
 |              for a line if the calc method is 'Fixed rate'
 |
 | MODIFICATION HISTORY
 |
 |     19-MAY-2003  Daniel Thota  o Created
 +===========================================================================*/
FUNCTION ten_recoverable_area (
         p_rec_agr_line_id         pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_customer_id            pn_rec_agreements_all.customer_id%TYPE
         ,p_lease_id               pn_rec_agreements_all.lease_id%TYPE
         ,p_location_id            pn_rec_agreements_all.location_id%TYPE
         ,p_calc_period_start_date pn_rec_calc_periods_all.start_date%TYPE
         ,p_calc_period_end_date   pn_rec_calc_periods_all.end_date%TYPE
         ,p_as_of_date             pn_rec_calc_periods_all.as_of_date%TYPE
                           )
      RETURN ten_recoverable_area_rec IS

      l_ten_recoverable_area_rec ten_recoverable_area_rec;

   BEGIN

        pnp_debug_pkg.log('PN_REC_CALC_PKG.ten_recoverable_area (+) ');

     SELECT nvl(area_class_dtl_lines.occupied_area_ovr, area_class_dtl_lines.occupied_area)
            ,occupancy_pct
     INTO   l_ten_recoverable_area_rec
     FROM    pn_rec_arcl_dtlln_all   area_class_dtl_lines
            ,pn_rec_arcl_dtl_all     area_class_dtl_hdr
            ,pn_rec_agr_linarea_all  linearea
            ,pn_rec_arcl_all         aclass
     WHERE  linearea.rec_agr_line_id               = p_rec_agr_line_id
     AND    p_as_of_date between linearea.start_date and linearea.end_date
     AND    linearea.area_class_id                 = aclass.area_class_id
     AND    area_class_dtl_hdr.area_class_id       = aclass.area_class_id
     AND    area_class_dtl_hdr.as_of_date          = p_as_of_date
     AND    area_class_dtl_hdr.from_date           = p_calc_period_start_date
     AND    area_class_dtl_hdr.to_date             = p_calc_period_end_date
     AND    area_class_dtl_lines.area_class_dtl_id = area_class_dtl_hdr.area_class_dtl_id
     AND    area_class_dtl_lines.cust_account_id   = p_customer_id
     AND    area_class_dtl_lines.lease_id          = p_lease_id
     AND    area_class_dtl_lines.location_id       = p_location_id
     AND    area_class_dtl_lines.include_flag      = 'Y'
     ;

      pnp_debug_pkg.log('PN_REC_CALC_PKG.ten_recoverable_area (-) ');

      RETURN l_ten_recoverable_area_rec;

   EXCEPTION

      WHEN OTHERS
      THEN

          pnp_debug_pkg.log('Error while getting tenant occupied area ' || to_char(sqlcode));
          l_ten_recoverable_area_rec.occupied_area := -99;
          l_ten_recoverable_area_rec.occupancy_pct := -99;
         RETURN l_ten_recoverable_area_rec;


END ten_recoverable_area;

/*===========================================================================+
 | FUNCTION
 |    GET_CONTR_ACTUAL_RECOVERY
 |
 | DESCRIPTION
 |    Gets actual recovery amount of the contributor(s) to be subtracted from the expenses
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                  p_rec_period_lines_id
 |                  p_rec_agr_line_id
 |                  p_start_date
 |                  p_end_date
 |                  p_as_of_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gets recoverable area from pn_rec_period_lines_all table
 |              for a line if the calc method is 'Fixed rate'
 |
 | MODIFICATION HISTORY
 |
 |     19-MAY-2003  Daniel Thota  o Created
 |     04-SEP-2003  Amita Singh   o Added new cursor csr_get_line
 |                                  Added parameters p_line_purpose,p_line_type
 |                                  to cursor chk_contr_calculated.Changed WHERE
 |                                  clause in the cursor to use them.
 |                                  Fix for bug # 3123283
 +===========================================================================*/
FUNCTION get_contr_actual_recovery (
         p_rec_agr_line_id         pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_customer_id            pn_rec_agreements_all.customer_id%TYPE
         ,p_lease_id               pn_rec_agreements_all.lease_id%TYPE
         ,p_location_id            pn_rec_agreements_all.location_id%TYPE
         ,p_calc_period_start_date pn_rec_calc_periods_all.start_date%TYPE
         ,p_calc_period_end_date   pn_rec_calc_periods_all.end_date%TYPE
         ,p_as_of_date             pn_rec_calc_periods_all.as_of_date%TYPE
         ,p_called_from             VARCHAR2
                           )
      RETURN pn_rec_period_lines_all.actual_recovery%TYPE IS

-- Fix for bug # 3123283
CURSOR csr_get_line IS
SELECT purpose, type
FROM pn_rec_agr_lines_all
WHERE rec_agr_line_id = p_rec_agr_line_id;
-- Fix for bug # 3123283

cursor chk_contr_calculated (p_line_purpose VARCHAR2, p_line_type VARCHAR2) is --Fix for bug # 3123283
   SELECT 'Y'
   FROM dual
   WHERE exists(
        SELECT 'Y'
        FROM   pn_rec_period_lines_all period_lines
               ,pn_rec_agreements_all recagr
               ,pn_rec_agr_lines_all lines
     WHERE  nvl(period_lines.actual_prorata_share,0) = 0
     AND    period_lines.start_date      = p_calc_period_start_date
     AND    period_lines.end_date        = p_calc_period_end_date
     AND    period_lines.as_of_date      = p_as_of_date
     and    lines.purpose                = p_line_purpose -- Fix for bug # 3123283
     and    lines.type                   = p_line_type -- Fix for bug # 3123283
     and    lines.rec_agr_line_id        = period_lines.rec_agr_line_id
     and    lines.rec_agreement_id       = recagr.rec_agreement_id
     and    (recagr.location_id, recagr.customer_id, recagr.lease_id) in
            (
            SELECT area_class_dtl_lines.location_id,
                   area_class_dtl_lines.cust_account_id,
                   area_class_dtl_lines.lease_id
            FROM   pn_rec_arcl_dtlln_all   area_class_dtl_lines
            WHERE area_class_dtl_id =
                  (SELECT area_class_dtl_hdr.area_class_dtl_id
                   FROM   pn_rec_arcl_dtlln_all   area_class_dtl_lines
                          ,pn_rec_arcl_dtl_all    area_class_dtl_hdr
                          ,pn_rec_agr_linarea_all linearea
                          ,pn_rec_arcl_all        aclass
                    WHERE  linearea.rec_agr_line_id = p_rec_agr_line_id
                    AND    p_as_of_date between linearea.start_date
                           and linearea.end_date
                    AND    linearea.area_class_id = aclass.area_class_id
                    AND    area_class_dtl_hdr.area_class_id = aclass.area_class_id
                    AND    area_class_dtl_hdr.as_of_date = p_as_of_date
                    AND    area_class_dtl_hdr.from_date  = p_calc_period_start_date
                    AND    area_class_dtl_hdr.to_date = p_calc_period_end_date
                   AND    area_class_dtl_lines.area_class_dtl_id = area_class_dtl_hdr.area_class_dtl_id
                    AND    area_class_dtl_lines.cust_account_id = p_customer_id
                    AND    area_class_dtl_lines.lease_id    = p_lease_id
                    AND    area_class_dtl_lines.location_id = p_location_id)
                    AND    area_class_dtl_lines.include_flag = 'Y'
                    AND    area_class_dtl_lines.exclude_prorata_ovr_flag = 'Y'
                    ));

      l_contr_actual_recovery pn_rec_period_lines_all.actual_recovery%TYPE := 0;
      l_exists VARCHAR2(1) := 'N';

 -- Fix for bug # 3123283
      l_line_purpose            pn_rec_agr_lines_all.PURPOSE%TYPE;
      l_line_type               pn_rec_agr_lines_all.TYPE%TYPE;

   BEGIN

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_contr_actual_recovery (+) ');

-- Fix for bug # 3123283
        OPEN csr_get_line;
        FETCH csr_get_line into l_line_purpose, l_line_type;
        IF csr_get_line%NOTFOUND THEN

            CLOSE csr_get_line;
            IF p_called_from = 'CALCUI' THEN
               return 0;
            ELSE
               return -99;
            END IF;

        END IF;

        CLOSE csr_get_line;
-- Fix for bug # 3123283

        OPEN chk_contr_calculated(l_line_purpose, l_line_type); -- Fix for bug # 3123283
        FETCH chk_contr_calculated into l_exists;
        IF chk_contr_calculated%FOUND and l_exists = 'Y' THEN
            pnp_debug_pkg.log('Calculation has not been done for one of the contributors ');
            close chk_contr_calculated;
            IF p_called_from = 'CALCUI' THEN
               return 0;
            ELSE
               return -99;
            END IF;
        ELSE
            close chk_contr_calculated;

        END IF;

        SELECT NVL(SUM(NVL(period_lines.actual_prorata_share,0)),0)
        INTO   l_contr_actual_recovery
        FROM   pn_rec_period_lines_all period_lines
               ,pn_rec_agreements_all recagr
               ,pn_rec_agr_lines_all lines
        WHERE  period_lines.start_date = p_calc_period_start_date
        AND    period_lines.end_date   = p_calc_period_end_date
        AND    period_lines.as_of_date = p_as_of_date
        AND    lines.rec_agr_line_id   = period_lines.rec_agr_line_id
        AND    lines.rec_agreement_id  = recagr.rec_agreement_id
        AND    lines.purpose           = l_line_purpose
        AND    lines.type              = l_line_type
        AND    (recagr.location_id, recagr.customer_id, recagr.lease_id) in
            (
            SELECT area_class_dtl_lines.location_id,
                   area_class_dtl_lines.cust_account_id,
                   area_class_dtl_lines.lease_id
            FROM   pn_rec_arcl_dtlln_all   area_class_dtl_lines
            WHERE area_class_dtl_id =
                  (SELECT area_class_dtl_hdr.area_class_dtl_id
                   FROM   pn_rec_arcl_dtlln_all   area_class_dtl_lines
                          ,pn_rec_arcl_dtl_all    area_class_dtl_hdr
                          ,pn_rec_agr_linarea_all linearea
                          ,pn_rec_arcl_all        aclass
                    WHERE  linearea.rec_agr_line_id = p_rec_agr_line_id
                    AND    p_as_of_date between linearea.start_date
                           and linearea.end_date
                    AND    linearea.area_class_id = aclass.area_class_id
                    AND    area_class_dtl_hdr.area_class_id = aclass.area_class_id
                    AND    area_class_dtl_hdr.as_of_date = p_as_of_date
                    AND    area_class_dtl_hdr.from_date  = p_calc_period_start_date
                    AND    area_class_dtl_hdr.to_date = p_calc_period_end_date
                    AND    area_class_dtl_lines.area_class_dtl_id = area_class_dtl_hdr.area_class_dtl_id
                    AND    area_class_dtl_lines.cust_account_id = p_customer_id
                    AND    area_class_dtl_lines.lease_id    = p_lease_id
                    AND    area_class_dtl_lines.location_id = p_location_id)
                    AND    area_class_dtl_lines.include_flag = 'Y'
                    AND    area_class_dtl_lines.exclude_prorata_ovr_flag = 'Y'
                    );

        pnp_debug_pkg.log('get_contr_actual_recovery contributor exp ' ||
                           to_char(l_contr_actual_recovery));

        IF p_called_from = 'CALCUI'AND l_contr_actual_recovery = 0 THEN
               RETURN 0;
        ELSE
               RETURN l_contr_actual_recovery;
        END IF;

   EXCEPTION

      WHEN OTHERS
      THEN

        fnd_message.set_name ('PN','PN_RECALC_CAL_NOT_CONTRB');
        pnp_debug_pkg.put_log_msg(fnd_message.get);
        pnp_debug_pkg.put_log_msg(TO_CHAR(sqlcode));
          IF p_called_from = 'CALCUI' THEN
               RETURN 0;
          ELSE
               RETURN -99;
          END IF;

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_contr_actual_recovery (-) ');

END get_contr_actual_recovery;

/*===========================================================================+
 | FUNCTION
 |    GET_LINE_EXPENSES
 |
 | DESCRIPTION
 |    Gets recoverable area from pn_rec_period_lines_all table
 |    for a line if the calc method is 'Fixed rate'
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                  p_rec_period_lines_id
 |                  p_rec_agr_line_id
 |                  p_start_date
 |                  p_end_date
 |                  p_as_of_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gets recoverable area from pn_rec_period_lines_all table
 |              for a line if the calc method is 'Fixed rate'
 |
 | MODIFICATION HISTORY
 |
 |     19-MAY-2003  Daniel Thota  o Created
 +===========================================================================*/
PROCEDURE get_line_expenses (
         p_rec_agr_line_id         IN    NUMBER
         ,p_customer_id            IN    NUMBER
         ,p_lease_id               IN    NUMBER
         ,p_location_id            IN    NUMBER
         ,p_calc_period_start_date IN    DATE
         ,p_calc_period_end_date   IN    DATE
         ,p_calc_period_as_of_date IN    DATE
         ,p_recoverable_amt        IN OUT   NOCOPY NUMBER
         ,p_fee_before_contr       IN OUT   NOCOPY NUMBER
         ,p_fee_after_contr        IN OUT   NOCOPY NUMBER
         ,p_error                  IN OUT NOCOPY VARCHAR2
         ,p_error_code             IN OUT NOCOPY NUMBER
                           ) IS

      l_line_expenses pn_rec_expcl_dtlln_all.computed_recoverable_amt%TYPE;
      l_fee_before    pn_rec_expcl_dtlln_all.cls_line_fee_before_contr_ovr%TYPE;
      l_fee_after     pn_rec_expcl_dtlln_all.cls_line_fee_after_contr_ovr%TYPE;

   BEGIN

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_line_expenses (+) ');

     SELECT nvl(exp_detail_line.computed_recoverable_amt,0),
            nvl(exp_detail_line.cls_line_fee_before_contr_ovr,0),
            nvl(exp_detail_hdr.cls_line_fee_after_contr,0)
     INTO   l_line_expenses, l_fee_before, l_fee_after
     FROM   pn_rec_expcl_all        rec_exp_class
            ,pn_rec_agr_linexp_all  lineexp
            ,pn_rec_expcl_dtl_all   exp_detail_hdr
            ,pn_rec_exp_line_all    exp_extract_hdr
            ,pn_rec_expcl_dtlln_all exp_detail_line
     WHERE exp_detail_hdr.expense_class_dtl_id   = exp_detail_line.expense_class_dtl_id
     AND   exp_detail_line.cust_account_id       = p_customer_id
     AND   exp_detail_line.lease_id              = p_lease_id
     AND   exp_detail_line.location_id           = p_location_id
     AND   exp_extract_hdr.to_date               = p_calc_period_end_date
     AND   exp_extract_hdr.from_date             = p_calc_period_start_date
     AND   exp_extract_hdr.as_of_date             = p_calc_period_as_of_date
     AND   exp_extract_hdr.expense_line_id       = exp_detail_hdr.expense_line_id
     AND   exp_detail_hdr.expense_class_id       = rec_exp_class.expense_class_id
     AND   rec_exp_class.expense_class_id        = lineexp.expense_class_id
     AND   p_calc_period_as_of_date between lineexp.start_date and lineexp.end_date
     AND   lineexp.rec_agr_line_id               = p_rec_agr_line_id
     ;

      p_recoverable_amt := l_line_expenses;
      p_fee_before_contr := l_fee_before;
      p_fee_after_contr := l_fee_after;
      p_error := 'Success in getting line expenses';
      p_error_code := 0;

   EXCEPTION

      WHEN OTHERS
      THEN
        p_recoverable_amt := 0;
        p_fee_before_contr := 0;
        p_fee_after_contr := 0;
        p_error := 'Error getting line expenses' || to_char(sqlcode);
        p_error_code := -99;

        fnd_message.set_name ('PN','PN_RECALB_LNEXP_NF');
        pnp_debug_pkg.put_log_msg(fnd_message.get||' '|| to_char(sqlcode));

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_line_expenses (-) ');

END get_line_expenses;

/*===========================================================================+
 | FUNCTION
 |    GET_BUDGET_EXPENSES
 |
 | DESCRIPTION
 |    Gets recoverable area from pn_rec_period_lines_all table
 |    for a line if the calc method is 'Fixed rate'
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                  p_rec_period_lines_id
 |                  p_rec_agr_line_id
 |                  p_start_date
 |                  p_end_date
 |                  p_as_of_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gets recoverable area from pn_rec_period_lines_all table
 |              for a line if the calc method is 'Fixed rate'
 |
 | MODIFICATION HISTORY
 |
 |   19-MAY-03  dthota   o Created
 |   27-AUG-04  abanerje o Modified the select statement to apply the share%
 |                         to the budgeted amount. Bug 3711709.
 +===========================================================================*/
FUNCTION get_budget_expenses (
         p_rec_agr_line_id         pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_customer_id            pn_rec_agreements_all.customer_id%TYPE
         ,p_lease_id               pn_rec_agreements_all.lease_id%TYPE
         ,p_location_id            pn_rec_agreements_all.location_id%TYPE
         ,p_calc_period_start_date pn_rec_calc_periods_all.start_date%TYPE
         ,p_calc_period_end_date   pn_rec_calc_periods_all.end_date%TYPE
         ,p_calc_period_as_of_date pn_rec_calc_periods_all.as_of_date%TYPE
                           )
      RETURN pn_rec_expcl_dtlln_all.budgeted_amt%TYPE IS

      l_budget_expenses pn_rec_expcl_dtlln_all.budgeted_amt%TYPE;

   BEGIN

     pnp_debug_pkg.log('PN_REC_CALC_PKG.get_budget_expenses (+) ');
     pnp_debug_pkg.log('Agr line ID: '||p_rec_agr_line_id);
     pnp_debug_pkg.log('Cust ID: '||p_customer_id);
     pnp_debug_pkg.log('lease ID: '||p_lease_id);
     pnp_debug_pkg.log('Location ID: '||p_location_id);
     pnp_debug_pkg.log('Start Date : '||p_calc_period_start_date);
     pnp_debug_pkg.log('End Date : ' ||p_calc_period_end_date);
     pnp_debug_pkg.log('As of Date : '||p_calc_period_as_of_date);



     SELECT NVL(
            SUM(
                NVL(expcl_lndtl_alloc.BUDGETED_AMT* (
                           (NVL
                              (NVL
                                  (expcl_lndtl_alloc.CLS_LINE_DTL_SHARE_PCT_OVR,
                                  expcl_lndtl_alloc.CLS_LINE_DTL_SHARE_PCT)
                               ,100)
                             )/100)
                ,0)
          ) ,0)
     INTO   l_budget_expenses
     FROM   pn_rec_expcl_all         rec_exp_class
            ,pn_rec_agr_linexp_all   lineexp
            ,pn_rec_expcl_dtl_all    exp_detail_hdr
            ,pn_rec_exp_line_all     exp_extract_hdr
            ,pn_rec_expcl_dtlln_all  exp_detail_line
            ,pn_rec_expcl_dtlacc_all expcl_lndtl_alloc
     WHERE exp_detail_hdr.expense_class_dtl_id   = exp_detail_line.expense_class_dtl_id
     AND   exp_detail_line.cust_account_id       = p_customer_id
     AND   exp_detail_line.lease_id              = p_lease_id
     AND   exp_detail_line.location_id           = p_location_id
     AND   exp_extract_hdr.to_date               = p_calc_period_end_date
     AND   exp_extract_hdr.from_date             = p_calc_period_start_date
     AND   exp_extract_hdr.as_of_date            = p_calc_period_as_of_date
     AND   exp_extract_hdr.expense_line_id       = exp_detail_hdr.expense_line_id
     AND   exp_detail_hdr.expense_class_id       = rec_exp_class.expense_class_id
     AND   rec_exp_class.expense_class_id        = lineexp.expense_class_id
     AND   p_calc_period_as_of_date between lineexp.start_date AND lineexp.end_date
     AND   lineexp.rec_agr_line_id               = p_rec_agr_line_id
     AND   expcl_lndtl_alloc.expense_class_line_id = exp_detail_line.expense_class_line_id
     ;
   pnp_debug_pkg.log('Cal exp: '||l_budget_expenses);
      RETURN l_budget_expenses;

   EXCEPTION

      WHEN OTHERS
      THEN
         fnd_message.set_name ('PN','PN_RECALB_BDEXP_NF');
         pnp_debug_pkg.put_log_msg(fnd_message.get||' '|| to_char(sqlcode));

         RETURN -99;

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_budget_expenses (-) ');

END get_budget_expenses;

/*===========================================================================+
 | FUNCTION
 |    GET_BILLED_RECOVERY
 |
 | DESCRIPTION
 |    Gets recoverable area from pn_rec_period_lines_all table
 |    for a line if the calc method is 'Fixed rate'
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                  p_rec_period_lines_id
 |                  p_rec_agr_line_id
 |                  p_start_date
 |                  p_end_date
 |                  p_as_of_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gets recoverable area from pn_rec_period_lines_all table
 |              for a line if the calc method is 'Fixed rate'
 |
 | MODIFICATION HISTORY
 |
 |     19-MAY-2003  Daniel Thota  o Created
 |     05-Aug-2003  Ashish Kumar  oBug#3066286 in the function get_billed_recovery
 |                                 remove the code referencing the table PN_REC_LINBILL
 |    18-Aug-2003   Ashish         Bug #3094082 added the condition
 |                                 ppt.currency_code = g_currency_code
 |     04-Nov-2003  Daniel Thota  o Changed the where clause to account for multi-tenancy
 |                                  so that billing terms of a lease are now associated with a location.
 |                                  Added a new parameter p_location_id for the function
 +===========================================================================*/
FUNCTION get_billed_recovery (
         p_payment_purpose         pn_rec_agr_lines_all.purpose%TYPE
         ,p_payment_type           pn_rec_agr_lines_all.type%TYPE
         ,p_lease_id               pn_rec_agreements_all.lease_id%TYPE
         ,p_location_id            pn_rec_agreements_all.location_id%TYPE
         ,p_calc_period_start_date pn_rec_calc_periods_all.start_date%TYPE
         ,p_calc_period_end_date   pn_rec_calc_periods_all.end_date%TYPE
         ,p_rec_agr_line_id        pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_rec_calc_period_id     pn_rec_calc_periods_all.rec_calc_period_id%TYPE
                             )
      RETURN pn_rec_period_lines_all.billed_recovery%TYPE IS

      l_billed_recovery     pn_rec_period_lines_all.billed_recovery%TYPE;
      l_rec_period_lines_id pn_rec_period_lines_all.rec_period_lines_id%TYPE :=
                                      PN_REC_CALC_PKG.find_if_period_line_exists(
                                               p_rec_agr_line_id
                                               ,p_rec_calc_period_id
                                               );

   BEGIN

        pnp_debug_pkg.log('PN_REC_CALC_PKG.billed_recovery (+) ');


        SELECT nvl(SUM(pitem.actual_amount),0)
        INTO   l_billed_recovery
        FROM   pn_payment_items_all pitem
               ,pn_payment_schedules_all psched
               ,pn_payment_terms_all ppt
        WHERE  psched.payment_status_lookup_code = 'APPROVED'
        AND    to_date(to_char(psched.schedule_date,'mm/yyyy'),'mm/yyyy') between
               to_date(to_char( p_calc_period_start_date,'mm/yyyy'),'mm/yyyy')
               and to_date(to_char(p_calc_period_end_date,'mm/yyyy'),'mm/yyyy')
        AND    psched.lease_id = p_lease_id
        AND    psched.payment_schedule_id         = pitem.payment_schedule_id
        AND    pitem.payment_item_type_lookup_code = 'CASH'
        AND    pitem.payment_term_id = ppt.payment_term_id
        AND    nvl(pitem.export_to_ar_flag,'N') = 'Y'
        AND    ppt.payment_purpose_code   = p_payment_purpose
        AND    ppt.payment_term_type_code = p_payment_type
        AND    ppt.start_date <= p_calc_period_end_date
        AND    ppt.end_date >= p_calc_period_start_date
        AND    ppt.currency_code = g_currency_code
        AND    ppt.recoverable_flag       = 'Y'
        AND    ppt.lease_id               = p_lease_id
        AND    ppt.location_id            = p_location_id
        ;

      RETURN l_billed_recovery;

   EXCEPTION

      WHEN OTHERS
      THEN
         fnd_message.set_name ('PN','PN_RECALB_BLREC_NF');
         pnp_debug_pkg.put_log_msg(fnd_message.get||' '|| to_char(sqlcode));
         RETURN -99;

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_billed_recovery (-) ');

END get_billed_recovery;

/*===========================================================================+
 | FUNCTION
 |    GET_LINE_CONSTRAINTS
 |
 | DESCRIPTION
 |    Gets recoverable area from pn_rec_period_lines_all table
 |    for a line if the calc method is 'Fixed rate'
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                  p_rec_period_lines_id
 |                  p_rec_agr_line_id
 |                  p_start_date
 |                  p_end_date
 |                  p_as_of_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gets recoverable area from pn_rec_period_lines_all table
 |              for a line if the calc method is 'Fixed rate'
 |
 | MODIFICATION HISTORY
 |
 |     19-MAY-2003  Daniel Thota  o Created
 +===========================================================================*/
FUNCTION get_line_constraints (
           p_rec_agr_line_id         pn_rec_agr_lines_all.rec_agr_line_id%TYPE
           ,p_as_of_date             pn_rec_calc_periods_all.as_of_date%TYPE
                             )
RETURN g_line_constr_type IS

CURSOR get_line_constr_csr IS
     SELECT CONSTR_ORDER,
            SCOPE,
            RELATION,
            VALUE,
            CPI_INDEX,
            BASE_YEAR
     FROM   PN_REC_AGR_LINCONST_ALL lineconst
     WHERE  lineconst.rec_agr_line_id               = p_rec_agr_line_id
     AND    p_as_of_date between lineconst.start_date and lineconst.end_date
     ;

/* PL/SQL table to store the constraints details */
line_constr_tbl g_line_constr_type;

i NUMBER :=0;

   BEGIN

        pnp_debug_pkg.log('PN_REC_CALC_PKG.line_constraints (+) ');
        pnp_debug_pkg.log('PN_REC_CALC_PKG.line_constraints -line id'|| p_rec_agr_line_id);
        pnp_debug_pkg.log('PN_REC_CALC_PKG.line_constraints -as of date '|| to_char(p_as_of_date));

     FOR line_constr_rec in get_line_constr_csr

     LOOP

     i := i + 1;

     line_constr_tbl(i).constr_order := line_constr_rec.constr_order;
     line_constr_tbl(i).scope        := line_constr_rec.scope;
     line_constr_tbl(i).relation     := line_constr_rec.relation;
     line_constr_tbl(i).value        := line_constr_rec.value;
     line_constr_tbl(i).cpi_index    := line_constr_rec.cpi_index;
     line_constr_tbl(i).base_year    := line_constr_rec.base_year;

     END LOOP;

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_line_constraints (-) ');
RETURN line_constr_tbl;

     EXCEPTION

      WHEN OTHERS
      THEN
         fnd_message.set_name ('PN','PN_RECALB_CONST_NF');
         pnp_debug_pkg.put_log_msg(fnd_message.get||' '|| to_char(sqlcode));

         line_constr_tbl(1).constr_order := -99;
         line_constr_tbl(1).scope        := null;
         line_constr_tbl(1).relation     := null;
         line_constr_tbl(1).value        := null;
         line_constr_tbl(1).cpi_index    := null;
         line_constr_tbl(1).base_year    := null;

         RETURN line_constr_tbl;


END get_line_constraints;

/*===========================================================================+
 | FUNCTION
 |    GET_LINE_ABATEMENTS
 |
 | DESCRIPTION
 |    Gets recoverable area from pn_rec_period_lines_all table
 |    for a line if the calc method is 'Fixed rate'
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                  p_rec_period_lines_id
 |                  p_rec_agr_line_id
 |                  p_start_date
 |                  p_end_date
 |                  p_as_of_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gets recoverable area from pn_rec_period_lines_all table
 |              for a line if the calc method is 'Fixed rate'
 |
 | MODIFICATION HISTORY
 |
 |     19-MAY-2003  Daniel Thota  o Created
 +===========================================================================*/
FUNCTION get_line_abatements (
         p_rec_agr_line_id         pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_as_of_date             pn_rec_calc_periods_all.as_of_date%TYPE
                             )
      RETURN pn_rec_agr_linabat_all.amount%TYPE IS


     CURSOR csr_get_abate IS
     SELECT NVL(SUM(NVL(amount,0)),0)
     FROM   pn_rec_agr_linabat_all abate
     WHERE  abate.rec_agr_line_id = p_rec_agr_line_id
     AND    p_as_of_date between abate.start_date AND abate.end_date;

      l_line_abatements pn_rec_agr_linabat_all.amount%TYPE;

   BEGIN

       OPEN csr_get_abate;
       FETCH csr_get_abate into l_line_abatements;
       CLOSE csr_get_abate;

       pnp_debug_pkg.log('PN_REC_CALC_PKG.line_abatements (+) ');


      RETURN l_line_abatements;

   EXCEPTION

      WHEN OTHERS THEN

         fnd_message.set_name ('PN','PN_RECALB_ABAT_NF');
         pnp_debug_pkg.put_log_msg(fnd_message.get||' '|| to_char(sqlcode));

         RETURN -99;

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_line_abatements (-) ');

END get_line_abatements;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_PERIOD_LINE_EXISTS
 |
 | DESCRIPTION
 |    Finds if period line exists for a line
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Finds if period line exists for a line
 |
 | MODIFICATION HISTORY
 |
 |     22-MAY-2003  Daniel Thota  o Created
 +===========================================================================*/
FUNCTION find_if_period_line_exists (
         p_rec_agr_line_id pn_rec_period_lines_all.rec_agr_line_id%TYPE
         ,p_rec_calc_period_id pn_rec_period_lines_all.rec_calc_period_id%TYPE
                                    )
      RETURN pn_rec_period_lines_all.rec_period_lines_id%TYPE IS

      CURSOR csr_chck_exist IS
         SELECT periods.rec_period_lines_id
         FROM   pn_rec_period_lines_all periods
         WHERE  periods.rec_agr_line_id    = p_rec_agr_line_id
         AND    periods.rec_calc_period_id = p_rec_calc_period_id;

         l_rec_period_lines_id pn_rec_period_lines_all.rec_period_lines_id%TYPE;

   BEGIN

        PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.find_if_period_line_exists (+)');

        OPEN csr_chck_exist;
        FETCH csr_chck_exist INTO l_rec_period_lines_id;
        IF csr_chck_exist%NOTFOUND THEN
           l_rec_period_lines_id := null;
        END IF;
        CLOSE csr_chck_exist;

        PNP_DEBUG_PKG.debug ('PN_VAR_RENT_PKG.find_if_period_line_exists (-)');

        RETURN l_rec_period_lines_id;

   EXCEPTION

      WHEN TOO_MANY_ROWS
      THEN

         fnd_message.set_name ('PN','PN_RECALB_PRDLN');
         pnp_debug_pkg.put_log_msg(fnd_message.get||' '||to_char(sqlcode));
         return -99;

      WHEN OTHERS
      THEN
         fnd_message.set_name ('PN','PN_RECALB_CHK_PRDLN');
         pnp_debug_pkg.put_log_msg(fnd_message.get||' '||to_char(sqlcode));
         RETURN -99;


END find_if_period_line_exists;

/*===========================================================================+
 | PROCEDURE
 |    INSERT_PERIOD_LINES_ROW
 |
 | DESCRIPTION
 |    Create records in the PN_REC_PERIOD_LINES_ALL table
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Create records in the PN_REC_PERIOD_LINES_ALL
 |
 | MODIFICATION HISTORY
 |
 |     21-MAY-2003  Daniel Thota  o Created
 |     25-JUL-2003  Daniel Thota  o Added X_FIXED_PCT to INSERT_PERIOD_LINES_ROW
 |                                  and UPDATE_PERIOD_LINES_ROW.Fix for bug# 3067662
 +===========================================================================*/
procedure INSERT_PERIOD_LINES_ROW (
  X_ROWID                IN OUT NOCOPY VARCHAR2
  ,X_REC_PERIOD_LINES_ID  IN OUT NOCOPY NUMBER
  ,X_BUDGET_PCT           IN NUMBER
  ,X_OCCUPANCY_PCT        IN NUMBER
  ,X_MULTIPLE_PCT         IN NUMBER
  ,X_TENANCY_START_DATE   IN DATE
  ,X_TENANCY_END_DATE     IN DATE
  ,X_STATUS               IN VARCHAR2
  ,X_BUDGET_PRORATA_SHARE IN NUMBER
  ,X_BUDGET_COST_PER_AREA IN NUMBER
  ,X_TOTAL_AREA           IN NUMBER
  ,X_TOTAL_EXPENSE        IN NUMBER
  ,X_RECOVERABLE_AREA     IN NUMBER
  ,X_ACTUAL_RECOVERY      IN NUMBER
  ,X_CONSTRAINED_ACTUAL   IN NUMBER
  ,X_ABATEMENTS           IN NUMBER
  ,X_ACTUAL_PRORATA_SHARE IN NUMBER
  ,X_BILLED_RECOVERY      IN NUMBER
  ,X_RECONCILED_AMOUNT    IN NUMBER
  ,X_BUDGET_RECOVERY      IN NUMBER
  ,X_BUDGET_EXPENSE       IN NUMBER
  ,X_REC_CALC_PERIOD_ID   IN NUMBER
  ,X_REC_AGR_LINE_ID      IN NUMBER
  ,X_AS_OF_DATE           IN DATE
  ,X_START_DATE           IN DATE
  ,X_END_DATE             IN DATE
  ,X_BILLING_TYPE         IN VARCHAR2
  ,X_BILLING_PURPOSE      IN VARCHAR2
  ,X_CUST_ACCOUNT_ID      IN NUMBER
  ,X_CREATION_DATE        IN DATE
  ,X_CREATED_BY           IN NUMBER
  ,X_LAST_UPDATE_DATE     IN DATE
  ,X_LAST_UPDATED_BY      IN NUMBER
  ,X_LAST_UPDATE_LOGIN    IN NUMBER
  ,X_FIXED_PCT            IN NUMBER
  ,X_ERROR_CODE           IN OUT NOCOPY NUMBER
) is

    CURSOR C is
        select ROWID
        from PN_REC_PERIOD_LINES
        where REC_PERIOD_LINES_ID = X_REC_PERIOD_LINES_ID;

    CURSOR org_cur IS
      SELECT org_id
      FROM pn_rec_calc_periods_all
      WHERE rec_calc_period_id = X_REC_CALC_PERIOD_ID;

    l_org_ID NUMBER;

BEGIN

  PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.INSERT_PERIOD_LINES_ROW (+)');

  -------------------------------------------------------
  -- Select the nextval for group date id
  -------------------------------------------------------
  IF ( X_REC_PERIOD_LINES_ID IS NULL) THEN
          select  pn_rec_period_lines_s.nextval
          into    X_REC_PERIOD_LINES_ID
          from    dual;
  END IF;

  FOR org_rec IN org_cur LOOP
    l_org_ID := org_rec.org_id;
  END LOOP;

  IF l_org_ID IS NULL THEN
    l_org_ID := pn_mo_cache_utils.get_current_org_id;
  END IF;


  INSERT INTO PN_REC_PERIOD_LINES_ALL (
    BUDGET_PCT
    ,OCCUPANCY_PCT
    ,MULTIPLE_PCT
    ,TENANCY_START_DATE
    ,TENANCY_END_DATE
    ,STATUS
    ,BUDGET_PRORATA_SHARE
    ,BUDGET_COST_PER_AREA
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_LOGIN
    ,TOTAL_AREA
    ,TOTAL_EXPENSE
    ,RECOVERABLE_AREA
    ,ACTUAL_RECOVERY
    ,CONSTRAINED_ACTUAL
    ,ABATEMENTS
    ,ACTUAL_PRORATA_SHARE
    ,BILLED_RECOVERY
    ,RECONCILED_AMOUNT
    ,BUDGET_RECOVERY
    ,BUDGET_EXPENSE
    ,REC_PERIOD_LINES_ID
    ,REC_CALC_PERIOD_ID
    ,REC_AGR_LINE_ID
    ,AS_OF_DATE
    ,START_DATE
    ,END_DATE
    ,BILLING_TYPE
    ,BILLING_PURPOSE
    ,CUST_ACCOUNT_ID
    ,FIXED_PCT
    ,ORG_ID
  )
values(
    X_BUDGET_PCT
    ,X_OCCUPANCY_PCT
    ,X_MULTIPLE_PCT
    ,X_TENANCY_START_DATE
    ,X_TENANCY_END_DATE
    ,X_STATUS
    ,X_BUDGET_PRORATA_SHARE
    ,X_BUDGET_COST_PER_AREA
    ,X_LAST_UPDATE_DATE
    ,X_LAST_UPDATED_BY
    ,X_CREATION_DATE
    ,X_CREATED_BY
    ,X_LAST_UPDATE_LOGIN
    ,X_TOTAL_AREA
    ,X_TOTAL_EXPENSE
    ,X_RECOVERABLE_AREA
    ,X_ACTUAL_RECOVERY
    ,X_CONSTRAINED_ACTUAL
    ,X_ABATEMENTS
    ,X_ACTUAL_PRORATA_SHARE
    ,X_BILLED_RECOVERY
    ,X_RECONCILED_AMOUNT
    ,X_BUDGET_RECOVERY
    ,X_BUDGET_EXPENSE
    ,X_REC_PERIOD_LINES_ID
    ,X_REC_CALC_PERIOD_ID
    ,X_REC_AGR_LINE_ID
    ,X_AS_OF_DATE
    ,X_START_DATE
    ,X_END_DATE
    ,X_BILLING_TYPE
    ,X_BILLING_PURPOSE
    ,X_CUST_ACCOUNT_ID
    ,X_FIXED_PCT
    ,l_org_ID
    );



  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

        PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.INSERT_PERIOD_LINES_ROW (-)');

  EXCEPTION
  WHEN OTHERS THEN

        X_ERROR_CODE := -99;
        PNP_DEBUG_PKG.log ('Error inserting into period lines'|| to_char(sqlcode));

end INSERT_PERIOD_LINES_ROW;

/*===========================================================================+
 | PROCEDURE
 |    UPDATE_PERIOD_LINES_ROW
 |
 | DESCRIPTION
 |    Update records in the PN_REC_PERIOD_LINES_ALL table
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Update records in the PN_REC_PERIOD_LINES_ALL
 |
 | MODIFICATION HISTORY
 |
 |     21-MAY-2003  Daniel Thota  o Created
 |     25-JUL-2003  Daniel Thota  o Added X_FIXED_PCT to INSERT_PERIOD_LINES_ROW
 |                                  and UPDATE_PERIOD_LINES_ROW.Fix for bug# 3067662
 +===========================================================================*/
procedure UPDATE_PERIOD_LINES_ROW (
  X_REC_PERIOD_LINES_ID  in NUMBER
  ,X_BUDGET_PCT           in NUMBER
  ,X_OCCUPANCY_PCT        in NUMBER
  ,X_MULTIPLE_PCT         in NUMBER
  ,X_TENANCY_START_DATE   in DATE
  ,X_TENANCY_END_DATE     in DATE
  ,X_STATUS               in VARCHAR2
  ,X_BUDGET_PRORATA_SHARE in NUMBER
  ,X_BUDGET_COST_PER_AREA in NUMBER
  ,X_TOTAL_AREA           in NUMBER
  ,X_TOTAL_EXPENSE        in NUMBER
  ,X_RECOVERABLE_AREA     in NUMBER
  ,X_ACTUAL_RECOVERY      in NUMBER
  ,X_CONSTRAINED_ACTUAL   in NUMBER
  ,X_ABATEMENTS           in NUMBER
  ,X_ACTUAL_PRORATA_SHARE in NUMBER
  ,X_BILLED_RECOVERY      in NUMBER
  ,X_RECONCILED_AMOUNT    in NUMBER
  ,X_BUDGET_RECOVERY      in NUMBER
  ,X_BUDGET_EXPENSE       in NUMBER
  ,X_REC_CALC_PERIOD_ID   in NUMBER
  ,X_REC_AGR_LINE_ID      in NUMBER
  ,X_AS_OF_DATE           in DATE
  ,X_START_DATE           in DATE
  ,X_END_DATE             in DATE
  ,X_BILLING_TYPE         in VARCHAR2
  ,X_BILLING_PURPOSE      in VARCHAR2
  ,X_CUST_ACCOUNT_ID      in NUMBER
  ,X_LAST_UPDATE_DATE     in DATE
  ,X_LAST_UPDATED_BY      in NUMBER
  ,X_LAST_UPDATE_LOGIN    in NUMBER
  ,X_FIXED_PCT            in NUMBER
  ,X_ERROR_CODE           in out NOCOPY NUMBER
) is

BEGIN

        PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.UPDATE_PERIOD_LINES_ROW (+)');

  update PN_REC_PERIOD_LINES_ALL set
    BUDGET_PCT           = X_BUDGET_PCT
    ,OCCUPANCY_PCT        = X_OCCUPANCY_PCT
    ,MULTIPLE_PCT         = X_MULTIPLE_PCT
    ,TENANCY_START_DATE   = X_TENANCY_START_DATE
    ,TENANCY_END_DATE     = X_TENANCY_END_DATE
    ,STATUS               = X_STATUS
    ,BUDGET_PRORATA_SHARE = X_BUDGET_PRORATA_SHARE
    ,BUDGET_COST_PER_AREA = X_BUDGET_COST_PER_AREA
    ,TOTAL_AREA           = X_TOTAL_AREA
    ,TOTAL_EXPENSE        = X_TOTAL_EXPENSE
    ,RECOVERABLE_AREA     = X_RECOVERABLE_AREA
    ,ACTUAL_RECOVERY      = X_ACTUAL_RECOVERY
    ,CONSTRAINED_ACTUAL   = X_CONSTRAINED_ACTUAL
    ,ABATEMENTS           = X_ABATEMENTS
    ,ACTUAL_PRORATA_SHARE = X_ACTUAL_PRORATA_SHARE
    ,BILLED_RECOVERY      = X_BILLED_RECOVERY
    ,RECONCILED_AMOUNT    = X_RECONCILED_AMOUNT
    ,BUDGET_RECOVERY      = X_BUDGET_RECOVERY
    ,BUDGET_EXPENSE       = X_BUDGET_EXPENSE
    ,REC_CALC_PERIOD_ID   = X_REC_CALC_PERIOD_ID
    ,REC_AGR_LINE_ID      = X_REC_AGR_LINE_ID
    ,AS_OF_DATE           = X_AS_OF_DATE
    ,START_DATE           = X_START_DATE
    ,END_DATE             = X_END_DATE
    ,BILLING_TYPE         = X_BILLING_TYPE
    ,BILLING_PURPOSE      = X_BILLING_PURPOSE
    ,CUST_ACCOUNT_ID      = X_CUST_ACCOUNT_ID
    ,REC_PERIOD_LINES_ID  = X_REC_PERIOD_LINES_ID
    ,LAST_UPDATE_DATE     = X_LAST_UPDATE_DATE
    ,LAST_UPDATED_BY      = X_LAST_UPDATED_BY
    ,LAST_UPDATE_LOGIN    = X_LAST_UPDATE_LOGIN
    ,FIXED_PCT            = X_FIXED_PCT
  where REC_PERIOD_LINES_ID = X_REC_PERIOD_LINES_ID
    ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

        PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.UPDATE_PERIOD_LINES_ROW (-)');

  EXCEPTION
  WHEN OTHERS THEN

        X_ERROR_CODE := -99;
        PNP_DEBUG_PKG.log ('Error updating into period lines'|| to_char(sqlcode));

end UPDATE_PERIOD_LINES_ROW;

/*===========================================================================+
 | PROCEDURE
 |    DELETE_PERIOD_LINES_ROW
 |
 | DESCRIPTION
 |    Delete records in the PN_REC_PERIOD_LINES_ALL table
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Delete records in the PN_REC_PERIOD_LINES_ALL
 |
 | MODIFICATION HISTORY
 |
 |     21-MAY-2003  Daniel Thota  o Created
 +===========================================================================*/

procedure DELETE_PERIOD_LINES_ROW (
  X_REC_PERIOD_LINES_ID in NUMBER
) is

BEGIN

        PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.DELETE_PERIOD_LINES_ROW (+)');

  delete from PN_REC_PERIOD_LINES_ALL
  where REC_PERIOD_LINES_ID = X_REC_PERIOD_LINES_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

        PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.DELETE_PERIOD_LINES_ROW (-)');

end DELETE_PERIOD_LINES_ROW;

/*===========================================================================+
 | PROCEDURE
 |    INSERT_PERIOD_BILLREC_ROW
 |
 | DESCRIPTION
 |    Create records in the PN_REC_PERIOD_BILL_ALL table
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Create records in the PN_REC_PERIOD_BILL_ALL
 |
 | MODIFICATION HISTORY
 |
 |     21-MAY-2003  Daniel Thota  o Created
 +===========================================================================*/
procedure INSERT_PERIOD_BILLREC_ROW (
  X_ROWID               IN OUT NOCOPY VARCHAR2
  ,X_PERIOD_BILLREC_ID  IN OUT NOCOPY NUMBER
  ,X_REC_AGREEMENT_ID   IN NUMBER
  ,X_REC_AGR_LINE_ID    IN NUMBER
  ,X_REC_CALC_PERIOD_ID IN NUMBER
  ,X_AMOUNT             IN NUMBER
  ,X_CREATION_DATE      IN DATE
  ,X_CREATED_BY         IN NUMBER
  ,X_LAST_UPDATE_DATE   IN DATE
  ,X_LAST_UPDATED_BY    IN NUMBER
  ,X_LAST_UPDATE_LOGIN  IN NUMBER
) is
  CURSOR C is
      SELECT ROWID FROM PN_REC_PERIOD_BILL_ALL
      WHERE PERIOD_BILLREC_ID = X_PERIOD_BILLREC_ID;

  CURSOR org_cur IS
    SELECT org_id
    FROM pn_rec_agreements_all
    WHERE rec_agreement_id = X_REC_AGREEMENT_ID;

  l_org_ID NUMBER;

BEGIN

  PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.INSERT_PERIOD_BILLREC_ROW (+)');

  -------------------------------------------------------
  -- Select the nextval for PERIOD_BILLREC_ID
  -------------------------------------------------------
  IF ( X_PERIOD_BILLREC_ID IS NULL) THEN
          SELECT  PN_REC_PERIOD_BILL_S.nextval
          INTO    X_PERIOD_BILLREC_ID
          FROM    dual;
  END IF;

  FOR org_rec IN org_cur LOOP
    l_org_ID := org_rec.org_id;
  END LOOP;

  IF l_org_ID IS NULL THEN
    l_org_ID := pn_mo_cache_utils.get_current_org_id;
  END IF;

  INSERT INTO PN_REC_PERIOD_BILL_ALL (
    PERIOD_BILLREC_ID
    ,REC_AGREEMENT_ID
    ,REC_AGR_LINE_ID
    ,REC_CALC_PERIOD_ID
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_LOGIN
    ,AMOUNT
    ,ORG_ID
  )
  VALUES(
    X_PERIOD_BILLREC_ID
    ,X_REC_AGREEMENT_ID
    ,X_REC_AGR_LINE_ID
    ,X_REC_CALC_PERIOD_ID
    ,X_LAST_UPDATE_DATE
    ,X_LAST_UPDATED_BY
    ,X_CREATION_DATE
    ,X_CREATED_BY
    ,X_LAST_UPDATE_LOGIN
    ,X_AMOUNT
    ,l_org_ID
  );

  OPEN C;
  FETCH C INTO X_ROWID;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

  PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.INSERT_PERIOD_BILLREC_ROW (-)');

END INSERT_PERIOD_BILLREC_ROW;

/*===========================================================================+
 | PROCEDURE
 |    UPDATE_PERIOD_BILLREC_ROW
 |
 | DESCRIPTION
 |    Update records in the PN_REC_PERIOD_BILL_ALL table
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Update records in the PN_REC_PERIOD_BILL_ALL
 |
 | MODIFICATION HISTORY
 |
 |     21-MAY-2003  Daniel Thota  o Created
 +===========================================================================*/
procedure UPDATE_PERIOD_BILLREC_ROW (
  X_PERIOD_BILLREC_ID   in NUMBER
  ,X_REC_AGREEMENT_ID   in NUMBER
  ,X_REC_AGR_LINE_ID    in NUMBER
  ,X_REC_CALC_PERIOD_ID in NUMBER
  ,X_AMOUNT             in NUMBER
  ,X_LAST_UPDATE_DATE   in DATE
  ,X_LAST_UPDATED_BY    in NUMBER
  ,X_LAST_UPDATE_LOGIN  in NUMBER
) is

BEGIN

        PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.UPDATE_PERIOD_BILLREC_ROW (+)');

  update PN_REC_PERIOD_BILL_ALL set
    REC_AGR_LINE_ID     = X_REC_AGR_LINE_ID
    ,REC_AGREEMENT_ID   = X_REC_AGREEMENT_ID
    ,REC_CALC_PERIOD_ID = X_REC_CALC_PERIOD_ID
    ,AMOUNT             = X_AMOUNT
    ,PERIOD_BILLREC_ID  = X_PERIOD_BILLREC_ID
    ,LAST_UPDATE_DATE   = X_LAST_UPDATE_DATE
    ,LAST_UPDATED_BY    = X_LAST_UPDATED_BY
    ,LAST_UPDATE_LOGIN  = X_LAST_UPDATE_LOGIN
  where PERIOD_BILLREC_ID = X_PERIOD_BILLREC_ID
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

        PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.UPDATE_PERIOD_BILLREC_ROW (-)');

end UPDATE_PERIOD_BILLREC_ROW;

/*===========================================================================+
 | PROCEDURE
 |    DELETE_PERIOD_BILLREC_ROW
 |
 | DESCRIPTION
 |    Delete records in the PN_REC_PERIOD_BILL_ALL table
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Delete records in the PN_REC_PERIOD_BILL_ALL
 |
 | MODIFICATION HISTORY
 |
 |     21-MAY-2003  Daniel Thota  o Created
 +===========================================================================*/
procedure DELETE_PERIOD_BILLREC_ROW (
  X_PERIOD_BILLREC_ID in NUMBER
) is

BEGIN

        PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.DELETE_PERIOD_BILLREC_ROW (+)');

  delete from PN_REC_PERIOD_BILL_ALL
  where PERIOD_BILLREC_ID = X_PERIOD_BILLREC_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

        PNP_DEBUG_PKG.log ('PN_REC_CALC_PKG.DELETE_PERIOD_BILLREC_ROW (-)');

end DELETE_PERIOD_BILLREC_ROW;

/*===========================================================================+
 | PROCEDURE
 |    create_payment_terms
 |
 | DESCRIPTION
 |    Procedure for creation of recovery payment terms.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Procedure for creation of recovery payment terms.
 |
 | MODIFICATION HISTORY
 |
 | 21-MAY-03  Daniel    o Created
 | 15-Aug-03  Ashish    o Bug#3099398 add the alias to the select clause
 |                        in the cursor
 |                        csr_distributions,csr_template and  csr_lease_term
 | 04-Sep-03  Daniel    o assigned l_rec_agr_line_id with p_rec_agr_line_id
 |                        Fix for bug # 3123730,3122264
 | 16-JUN-04  abanerje  o Modified call to pnt_payment_terms_pkg.insert_row
 |                        to pass term_template_id. Bug 3657130.
 | 15-SEP-04  atuppad   o In the call pnt_payment_terms_pkg.insert_row,
 |                        corrected the code to copy the payment DFF into
 |                        payment DFF of new IR term and not in AR Projects
 |                        DFF. Bug # 3841542
 | 21-APR-05  ftanudja  o Added area_type_code, area defaulting. #4324777
 | 15-JUL-05  ftanudja  o R12 change: add logic for tax_clsfctn_cd. #4495054
 | 28-NOV-05  pikhar    o fetched org_id using cursor
 | 18-JUL-06  sdmahesh  o Bug 5332426 Added handling for lazy upgrade
 |                        of Term Templates for E-Tax
 | 24-SEP-06  acprakas  o Bug#6370014. Modified procedure to set schedule day,
 |                        term start and term end date to 28 if it is more than 28.
 +===========================================================================*/

PROCEDURE create_payment_terms(
      p_lease_id               IN  NUMBER
     ,p_payment_amount         IN  NUMBER
     ,p_calc_period_end_date   IN  DATE
     ,p_rec_agreement_id       IN  NUMBER
     ,p_rec_agr_line_id        IN  NUMBER
     ,p_rec_calc_period_id     IN  NUMBER
     ,p_location_id            IN  NUMBER
     ,p_amount_type            IN  VARCHAR2
     ,p_org_id                 IN  NUMBER
     ,p_billing_type           IN VARCHAR2
     ,p_billing_purpose        IN VARCHAR2
     ,p_customer_id            IN NUMBER
     ,p_cust_site_id           IN NUMBER
     ,p_consolidate            IN VARCHAR2
     ,p_error                  IN OUT NOCOPY VARCHAR2
     ,p_error_code             IN OUT NOCOPY NUMBER
   ) IS

l_lease_class_code         pn_leases.lease_class_code%TYPE;
l_distribution_id          pn_distributions.distribution_id%TYPE;
l_payment_term_id          pn_payment_terms.payment_term_id%TYPE;
l_lease_change_id          pn_lease_details.lease_change_id%TYPE;
l_rowid                    ROWID;
l_distribution_count       NUMBER  := 0;
l_payment_start_date       pn_payment_terms.start_date%TYPE;
l_payment_end_date         pn_payment_terms.end_date%TYPE;
l_frequency                pn_payment_terms.frequency_code%type;
l_schedule_day             pn_payment_terms.schedule_day%type;
l_set_of_books_id          gl_sets_of_books.set_of_books_id%type;
l_context                  varchar2(2000);
l_period_billrec_id        PN_REC_PERIOD_BILL_all.period_billrec_id%TYPE:= NULL;
l_payment_amount           pn_payment_terms.actual_amount%type;
l_period_bill_record period_bill_record;
l_is_r12                   BOOLEAN := pn_r12_util_pkg.is_r12;
l_dummy                    VARCHAR2(30);

l_creation_date DATE   := SYSDATE;
l_created_by    NUMBER := NVL(fnd_profile.value('USER_ID'), 0);
l_term_date  DATE; --Bug#6370014

CURSOR csr_temp_dist(p_term_template_id   IN   NUMBER)
IS
SELECT pd.*
FROM pn_distributions_all pd
WHERE pd.term_template_id = p_term_template_id;

CURSOR csr_term_dist(p_term_id   IN   NUMBER)
IS
SELECT pd.*
FROM pn_distributions_all pd
WHERE pd.payment_term_id = p_term_id;

CURSOR csr_template (p_rec_agreement_id   IN   NUMBER)
IS
SELECT ptt.*
FROM pn_term_templates_all ptt,
     pn_rec_agreements_all prec
WHERE ptt.term_template_id = prec.term_template_id
AND   prec.rec_agreement_id = p_rec_agreement_id;

CURSOR csr_template_upg (p_rec_agreement_id   IN   NUMBER)
IS
SELECT ptt.*
FROM pn_term_templates_all ptt,
     pn_rec_agreements_all prec
WHERE ptt.term_template_id = prec.term_template_id
AND   (ptt.tax_code_id IS NOT NULL OR ptt.tax_group_id IS NOT NULL)
AND   ptt.tax_classification_code IS NULL
AND   prec.rec_agreement_id = p_rec_agreement_id;


rec_template pn_term_templates_all%ROWTYPE;

CURSOR csr_lease_term IS
SELECT term.*
FROM   pn_payment_terms_all term
WHERE  term.lease_id               = p_lease_id
AND    term.PAYMENT_TERM_TYPE_CODE = p_billing_type
AND    term.PAYMENT_PURPOSE_CODE   = p_billing_purpose
AND    term.RECOVERABLE_FLAG       = 'Y'
AND    rownum = 1;

rec_lease_term pn_payment_terms_all%ROWTYPE;
l_term_details   VARCHAR2(1) := 'N';
rec_distributions pn_distributions%ROWTYPE;
l_rec_agr_line_id number;
l_area                     pn_payment_terms.area%TYPE;
l_area_type_code           pn_payment_terms.area_type_code%TYPE;


CURSOR org_cur IS
  SELECT org_id
  FROM   pn_leases_all
  WHERE  lease_id = p_lease_id;

 l_org_id NUMBER;


BEGIN

     pnp_debug_pkg.log ('PN_REC_CALC_PKG.create_payment_terms  :   (+)');

     IF p_org_id IS NULL THEN
       FOR rec IN org_cur LOOP
         l_org_id := rec.org_id;
       END LOOP;
     ELSE
       l_org_id := p_org_id;
     END IF;

     l_context := 'Getting lease details';

     BEGIN
        SELECT pl.lease_class_code
               ,pld.lease_change_id
        INTO   l_lease_class_code
               ,l_lease_change_id
        FROM pn_leases_all pl
             ,pn_lease_details_all pld
        WHERE pl.lease_id  = pld.lease_id
        AND   pld.lease_id = p_lease_id;

        EXCEPTION
        WHEN OTHERS THEN
             pnp_debug_pkg.log ('Unable to get Lease Details :'||
                                 to_char(SQLCODE));
        p_error := 'Unable to get Lease Details';
        p_error_code := -99;
        return;

     END;

     IF p_error_code <> -99 THEN

        pnp_debug_pkg.log ('create_payment_terms  - Org id :'||l_org_id);

        l_context := 'Getting SOB ';

        l_set_of_books_id := TO_NUMBER(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID', l_org_id));
        pnp_debug_pkg.log ('create_payment_terms  - Set of books id :'||l_set_of_books_id);

        /*E-Tax lazy upgrade for Term Template*/

        IF l_is_r12 THEN

          OPEN csr_template_upg(p_rec_agreement_id);
          FETCH csr_template_upg INTO rec_template;

          IF csr_template_upg%FOUND THEN

            l_dummy := pn_r12_util_pkg.check_tax_upgrade(rec_template.term_template_id);
            pnp_debug_pkg.log('Term Template '||rec_template.name||' upgraded');
            template_name_tbl(NVL(template_name_tbl.LAST,0)+1) := rec_template.name;
            template_id_tbl(NVL(template_id_tbl.LAST,0)+1) := rec_template.term_template_id;

          END IF;

          CLOSE csr_template_upg;

        END IF;


        l_context := 'Getting template details ';

        OPEN csr_template(p_rec_agreement_id);
        FETCH csr_template INTO rec_template;

        IF csr_template%NOTFOUND THEN

          IF nvl(p_consolidate,'N') = 'N' THEN

             l_context := 'Getting term details ';
             l_term_details := 'Y';
             OPEN csr_lease_term;
             FETCH csr_lease_term INTO rec_lease_term;
             CLOSE csr_lease_term;

          ELSE

              pnp_debug_pkg.log ('With Consolidation Option a term template is needed');
              p_error := 'Unable to get Lease Details';
              p_error_code := -99;
              CLOSE csr_template;
              return;

          END IF;

        END IF;

        CLOSE csr_template;


        l_context := 'Setting term attributes ';
        IF l_lease_class_code = 'DIRECT' THEN

        /* lease is of class: DIRECT */

         rec_template.customer_id := NULL;
         rec_template.customer_site_use_id := NULL;
         rec_template.cust_ship_site_id := NULL;
         rec_template.cust_trx_type_id := NULL;
         rec_template.inv_rule_id := NULL;
         rec_template.account_rule_id := NULL;
         rec_template.salesrep_id := NULL;
         rec_template.cust_po_number := NULL;
         rec_template.receipt_method_id := NULL;
        ELSE

         /* lease is 'sub-lease' or third-party */

         rec_template.project_id := NULL;
         rec_template.task_id := NULL;
         rec_template.organization_id := NULL;
         rec_template.expenditure_type := NULL;
         rec_template.expenditure_item_date := NULL;
         rec_template.vendor_id := NULL;
         rec_template.vendor_site_id := NULL;
         rec_template.tax_group_id := NULL;
         rec_template.distribution_set_id := NULL;
         rec_template.po_header_id := NULL;
        END IF;

        IF l_is_r12 THEN
           rec_template.tax_group_id := NULL;
           rec_template.tax_code_id := NULL;
        ELSE
           rec_template.tax_classification_code := NULL;
        END IF;

        l_frequency          := 'OT';

	--Bug#6370014
	IF to_char(p_calc_period_end_date,'dd') > 28
	THEN
	    l_schedule_day  :=  28;
	    l_term_date :=  p_calc_period_end_date - (to_char(p_calc_period_end_date,'dd') - 28);
        ELSE
	    l_schedule_day  := to_char(p_calc_period_end_date,'dd');
	    l_term_date := p_calc_period_end_date;
	END IF;


        l_context := 'Checking term exists ';
        l_period_bill_record := PN_REC_CALC_PKG.find_if_rec_payterm_exists(
                                            p_rec_agreement_id
                                            ,p_rec_agr_line_id
                                            ,p_rec_calc_period_id
                                            ,p_consolidate
                                            );

        IF l_period_bill_record.period_billrec_id = -99 THEN

           p_error := 'Error checking for payment terms';
           p_error_code := -99;

        ELSE

           l_payment_amount    := nvl(l_period_bill_record.amount,0);
           l_period_billrec_id := l_period_bill_record.period_billrec_id;

        END IF;

        pnp_debug_pkg.log ('create_payment_terms - approved amount '|| l_payment_amount);
        pnp_debug_pkg.log ('create_payment_terms - period_billrec_id '|| l_period_billrec_id);
        IF p_error_code <> -99 and l_period_billrec_id IS NOT NULL THEN

           l_payment_amount := p_payment_amount - l_payment_amount;

           l_context := 'Updating period_billrec ';

           PN_REC_CALC_PKG.update_period_billrec_row (
                     X_PERIOD_BILLREC_ID   => l_period_billrec_id
                     ,X_REC_AGREEMENT_ID   => p_rec_agreement_id
                     ,X_REC_AGR_LINE_ID    => p_rec_agr_line_id
                     ,X_REC_CALC_PERIOD_ID => p_rec_calc_period_id
                     ,X_AMOUNT             => p_payment_amount
                     ,X_LAST_UPDATE_DATE   => l_creation_date
                     ,X_LAST_UPDATED_BY    => l_created_by
                     ,X_LAST_UPDATE_LOGIN  => l_created_by
                    );
        ELSIF p_error_code <> -99 and l_period_billrec_id IS NULL THEN

           l_payment_amount := p_payment_amount;

           l_context := 'Inserting period_billrec ';

         pnp_debug_pkg.log ('insert_period_billrec_row - agr id  :'||p_rec_agreement_id);
         pnp_debug_pkg.log ('insert_period_billrec_row - p_rec_agr_line_id :'||p_rec_agr_line_id);
         pnp_debug_pkg.log ('insert_period_billrec_row - p_rec_calc_period_id :'||p_rec_calc_period_id);
         pnp_debug_pkg.log ('insert_period_billrec_row - amount :'||l_payment_amount);
           PN_REC_CALC_PKG.insert_period_billrec_row (
                   X_ROWID               => l_rowId
                   ,X_PERIOD_BILLREC_ID  => l_period_billrec_id
                   ,X_REC_AGREEMENT_ID   => p_rec_agreement_id
                   ,X_REC_AGR_LINE_ID    => p_rec_agr_line_id
                   ,X_REC_CALC_PERIOD_ID => p_rec_calc_period_id
                   ,X_AMOUNT             => l_payment_amount
                   ,X_CREATION_DATE      => l_creation_date
                   ,X_CREATED_BY         => l_created_by
                   ,X_LAST_UPDATE_DATE   => l_creation_date
                   ,X_LAST_UPDATED_BY    => l_created_by
                   ,X_LAST_UPDATE_LOGIN  => l_created_by
                  );
        END IF;

      IF p_error_code <> -99 AND l_payment_amount <> 0 THEN

         IF p_rec_agr_line_id = -1 THEN

            l_rec_agr_line_id := null;

         ELSE
            -- Fix for bug # 3123730,3122264
            l_rec_agr_line_id := p_rec_agr_line_id;

         END IF;

         pnp_debug_pkg.log ('create_payment_terms  - l_payment_amount :'||l_payment_amount);
         pnp_debug_pkg.log ('create_payment_terms  - Row Id :'||l_rowid);
         pnp_debug_pkg.log ('create_payment_terms  - l_payment_amount :'||l_payment_amount);
         pnp_debug_pkg.log ('create_payment_terms  - Payment Term Id :'||l_payment_term_id);
         pnp_debug_pkg.log ('create_payment_terms  - Billing Purpose :'||p_billing_purpose);
         pnp_debug_pkg.log ('create_payment_terms  - Billing Type :'||p_billing_Type);
         pnp_debug_pkg.log ('create_payment_terms  - Frequency Code :'||l_frequency);
         pnp_debug_pkg.log ('create_payment_terms  - Lease Id :'||p_lease_id);
         pnp_debug_pkg.log ('create_payment_terms  - Lease change Id :'||l_lease_change_id);
         pnp_debug_pkg.log ('create_payment_terms  - Start Date :'||p_calc_period_end_date);
         pnp_debug_pkg.log ('create_payment_terms  - End Date :'||p_calc_period_end_date);
         pnp_debug_pkg.log ('create_payment_terms  - SOB :'||rec_template.set_of_books_id);
         pnp_debug_pkg.log ('create_payment_terms  - SOB :'||l_set_of_books_id);
         pnp_debug_pkg.log ('create_payment_terms  - Currency Code :'||g_currency_code);
         pnp_debug_pkg.log ('create_payment_terms  - Vendor Id :'||rec_template.vendor_id);
         pnp_debug_pkg.log ('create_payment_terms  - Vendor Site Id :'||rec_template.vendor_site_id);
         pnp_debug_pkg.log ('create_payment_terms  - Actual Amount :'||l_payment_amount);
         pnp_debug_pkg.log ('create_payment_terms  - Customer Site Use :'||rec_template.customer_site_use_id);
         pnp_debug_pkg.log ('create_payment_terms  - Location :'||p_location_id);
         pnp_debug_pkg.log ('create_payment_terms  - Schedule Day :'||l_schedule_day);
         pnp_debug_pkg.log ('create_payment_terms  - Customer Ship to :'||rec_template.cust_ship_site_id);
         pnp_debug_pkg.log ('create_payment_terms  - AP Ar Temr Id :'||rec_template.ap_ar_term_id);
         pnp_debug_pkg.log ('create_payment_terms  - Trx Id :'||rec_template.cust_trx_type_id);
         pnp_debug_pkg.log ('create_payment_terms  - Project Id :'||rec_template.project_id);
         pnp_debug_pkg.log ('create_payment_terms  - Task Id :'||rec_template.task_id);
         pnp_debug_pkg.log ('create_payment_terms  - Organization Id :'||rec_template.organization_id);
         pnp_debug_pkg.log ('create_payment_terms  - Exend Type :'||rec_template.expenditure_type);
         pnp_debug_pkg.log ('create_payment_terms  - Exend Item Date :'||rec_template.expenditure_item_date);
         pnp_debug_pkg.log ('create_payment_terms  - Tax Group Id :'||rec_template.tax_group_id);
         pnp_debug_pkg.log ('create_payment_terms  - Tax Code Id :'||rec_template.tax_code_id);
         pnp_debug_pkg.log ('create_payment_terms  - Tax Incl :'||rec_template.tax_included);
         pnp_debug_pkg.log ('create_payment_terms  - Distr Set Id :'||rec_template.distribution_set_id);
         pnp_debug_pkg.log ('create_payment_terms  - Inv rule Id :'||rec_template.inv_rule_id);
         pnp_debug_pkg.log ('create_payment_terms  - Acct rule Id :'||rec_template.account_rule_id);
         pnp_debug_pkg.log ('create_payment_terms  - Sales Rep Id :'||rec_template.salesrep_id);
         pnp_debug_pkg.log ('create_payment_terms  - PO header Id :'||rec_template.po_header_id);
         pnp_debug_pkg.log ('create_payment_terms  - PO # :'||rec_template.cust_po_number);
         pnp_debug_pkg.log ('create_payment_terms  - Receipt method id :'||rec_template.receipt_method_id);
         pnp_debug_pkg.log ('create_payment_terms  - Org id :'||p_org_id);
         pnp_debug_pkg.log ('create_payment_terms  - Period Billrec id :'||l_period_billrec_id);
         pnp_debug_pkg.log ('create_payment_terms  - Rec Agr Line id :'||l_rec_agr_line_id);
         pnp_debug_pkg.log ('create_payment_terms  - Term Template ID :'||rec_template.term_template_id);

         IF p_location_id IS NOT NULL AND
            p_calc_period_end_date IS NOT NULL THEN

             l_area_type_code := 'LOCTN_RENTABLE';
             l_area := pnp_util_func.fetch_tenancy_area(
                          p_lease_id       => p_lease_id,
                          p_location_id    => p_location_id,
                          p_as_of_date     => p_calc_period_end_date,
                          p_area_type_code => l_area_type_code);

         END IF;

         l_context := 'Creating payment term ';

         pnt_payment_terms_pkg.insert_row (
                     x_rowid                       => l_rowid
                    ,x_payment_term_id             => l_payment_term_id
                    ,x_index_period_id             => null
                    ,x_index_term_indicator        => null
                    ,x_var_rent_inv_id             => null
                    ,x_var_rent_type               => null
                    ,x_last_update_date            => SYSDATE
                    ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
                    ,x_creation_date               => SYSDATE
                    ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
                    ,x_payment_purpose_code        => nvl(p_billing_purpose,rec_template.payment_purpose_code)
                    ,x_payment_term_type_code      => nvl(p_billing_type,rec_template.payment_term_type_code)
                    ,x_frequency_code              => l_frequency
                    ,x_lease_id                    => p_lease_id
                    ,x_lease_change_id             => l_lease_change_id
                    ,x_start_date                  => l_term_date --Bug#6370014
                    ,x_end_date                    => l_term_date --Bug#6370014
                    ,x_set_of_books_id             => NVL(rec_template.set_of_books_id,l_set_of_books_id)
                    --,x_currency_code               => NVL(rec_template.currency_code, l_currency_code)
                    ,x_currency_code               => g_currency_code
                    ,x_rate                        => 1 -- not used in application
                    ,x_last_update_login           => NVL(fnd_profile.value('LOGIN_ID'),0)
                    ,x_vendor_id                   => nvl(rec_template.vendor_id,rec_lease_term.vendor_id)
                    ,x_vendor_site_id              => nvl(rec_template.vendor_site_id,rec_lease_term.vendor_site_id)
                    ,x_target_date                 => NULL
                    ,x_actual_amount               => l_payment_amount
                    ,x_estimated_amount            => NULL
                    ,x_attribute_category          => rec_template.attribute_category
                    ,x_attribute1                  => rec_template.attribute1
                    ,x_attribute2                  => rec_template.attribute2
                    ,x_attribute3                  => rec_template.attribute3
                    ,x_attribute4                  => rec_template.attribute4
                    ,x_attribute5                  => rec_template.attribute5
                    ,x_attribute6                  => rec_template.attribute6
                    ,x_attribute7                  => rec_template.attribute7
                    ,x_attribute8                  => rec_template.attribute8
                    ,x_attribute9                  => rec_template.attribute9
                    ,x_attribute10                 => rec_template.attribute10
                    ,x_attribute11                 => rec_template.attribute11
                    ,x_attribute12                 => rec_template.attribute12
                    ,x_attribute13                 => rec_template.attribute13
                    ,x_attribute14                 => rec_template.attribute14
                    ,x_attribute15                 => rec_template.attribute15
                    ,x_project_attribute_category  => rec_lease_term.project_attribute_category
                    ,x_project_attribute1          => rec_lease_term.project_attribute1
                    ,x_project_attribute2          => rec_lease_term.project_attribute2
                    ,x_project_attribute3          => rec_lease_term.project_attribute3
                    ,x_project_attribute4          => rec_lease_term.project_attribute4
                    ,x_project_attribute5          => rec_lease_term.project_attribute5
                    ,x_project_attribute6          => rec_lease_term.project_attribute6
                    ,x_project_attribute7          => rec_lease_term.project_attribute7
                    ,x_project_attribute8          => rec_lease_term.project_attribute8
                    ,x_project_attribute9          => rec_lease_term.project_attribute9
                    ,x_project_attribute10         => rec_lease_term.project_attribute10
                    ,x_project_attribute11         => rec_lease_term.project_attribute11
                    ,x_project_attribute12         => rec_lease_term.project_attribute12
                    ,x_project_attribute13         => rec_lease_term.project_attribute13
                    ,x_project_attribute14         => rec_lease_term.project_attribute14
                    ,x_project_attribute15         => rec_lease_term.project_attribute15
                    ,x_customer_id                 => p_customer_id
                    ,x_customer_site_use_id        => p_cust_site_id
                    ,x_normalize                   => 'N'
                    ,x_location_id                 => p_location_id
                    ,x_schedule_day                => l_schedule_day
                    ,x_cust_ship_site_id           => nvl(rec_template.cust_ship_site_id,rec_lease_term.cust_ship_site_id)
                    ,x_ap_ar_term_id               => nvl(rec_template.ap_ar_term_id,rec_lease_term.ap_ar_term_id)
                    ,x_cust_trx_type_id            => nvl(rec_template.cust_trx_type_id,rec_lease_term.cust_trx_type_id)
                    ,x_project_id                  => nvl(rec_template.project_id,rec_lease_term.project_id)
                    ,x_task_id                     => nvl(rec_template.task_id,rec_lease_term.task_id)
                    ,x_organization_id             => nvl(rec_template.organization_id,rec_lease_term.organization_id)
                    ,x_expenditure_type            => nvl(rec_template.expenditure_type,rec_lease_term.expenditure_type)
                    ,x_expenditure_item_date       => nvl(rec_template.expenditure_item_date,rec_lease_term.expenditure_item_date)
                    ,x_tax_group_id                => nvl(rec_template.tax_group_id,rec_lease_term.tax_group_id)
                    ,x_tax_code_id                 => nvl(rec_template.tax_code_id,rec_lease_term.tax_code_id)
                    ,x_tax_classification_code     => nvl(rec_template.tax_classification_code,rec_lease_term.tax_classification_code)

                    ,x_tax_included                => nvl(rec_template.tax_included,rec_lease_term.tax_included)
                    ,x_distribution_set_id         => nvl(rec_template.distribution_set_id,rec_lease_term.distribution_set_id)
                    ,x_inv_rule_id                 => nvl(rec_template.inv_rule_id,rec_lease_term.inv_rule_id)
                    ,x_account_rule_id             => nvl(rec_template.account_rule_id,rec_lease_term.account_rule_id)
                    ,x_salesrep_id                 => nvl(rec_template.salesrep_id,rec_lease_term.salesrep_id)
                    ,x_approved_by                 => NULL
                    ,x_status                      => 'DRAFT'
                    ,x_po_header_id                => nvl(rec_template.po_header_id,rec_lease_term.po_header_id)
                    ,x_cust_po_number              => nvl(rec_template.cust_po_number,rec_lease_term.cust_po_number)
                    ,x_receipt_method_id           => nvl(rec_template.receipt_method_id,rec_lease_term.receipt_method_id)
                    ,x_calling_form                => 'PNRECALB'
                    ,x_org_id                      => l_org_id
                    ,x_period_billrec_id           => l_period_billrec_id
                    ,x_rec_agr_line_id             => l_rec_agr_line_id
                    ,x_amount_type                 => 'CAM'
                    ,x_recoverable_flag            => NULL
                    ,x_term_template_id            => rec_template.term_template_id
                    ,x_area                        => l_area
                    ,x_area_type_code              => l_area_type_code
                  );


            /* Create a record in pn_distributions */


            l_context := 'Creating Account Distributions ';

            IF l_term_details = 'Y' THEN

               OPEN csr_term_dist(rec_lease_term.payment_term_id);

            ELSE

               OPEN csr_temp_dist(rec_template.term_template_id);

            END IF;

            l_distribution_count := 0;

            LOOP
                    IF csr_term_dist%ISOPEN THEN

                        FETCH csr_term_dist into rec_distributions;
                        EXIT WHEN csr_term_dist%NOTFOUND;

                    ELSIF csr_temp_dist%ISOPEN THEN

                        FETCH csr_temp_dist into rec_distributions;
                        EXIT WHEN csr_temp_dist%NOTFOUND;

                    END IF;

                    pnp_debug_pkg.log(' account_id '||rec_distributions.account_id);
                    pnp_debug_pkg.log(' account_class '||rec_distributions.account_id);

                    l_context := 'Inserting Account Distributions ';
                    pn_distributions_pkg.insert_row (
                       x_rowid                       => l_rowid
                      ,x_distribution_id             => l_distribution_id
                      ,x_account_id                  => rec_distributions.account_id
                      ,x_payment_term_id             => l_payment_term_id
                      ,x_term_template_id            => NULL
                      ,x_account_class               => rec_distributions.account_class
                      ,x_percentage                  => rec_distributions.percentage
                      ,x_line_number                 => rec_distributions.line_number
                      ,x_last_update_date            => SYSDATE
                      ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
                      ,x_creation_date               => SYSDATE
                      ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
                      ,x_last_update_login           => NVL(fnd_profile.value('LOGIN_ID'),0)
                      ,x_attribute_category          => rec_distributions.attribute_category
                      ,x_attribute1                  => rec_distributions.attribute1
                      ,x_attribute2                  => rec_distributions.attribute2
                      ,x_attribute3                  => rec_distributions.attribute3
                      ,x_attribute4                  => rec_distributions.attribute4
                      ,x_attribute5                  => rec_distributions.attribute5
                      ,x_attribute6                  => rec_distributions.attribute6
                      ,x_attribute7                  => rec_distributions.attribute7
                      ,x_attribute8                  => rec_distributions.attribute8
                      ,x_attribute9                  => rec_distributions.attribute9
                      ,x_attribute10                 => rec_distributions.attribute10
                      ,x_attribute11                 => rec_distributions.attribute11
                      ,x_attribute12                 => rec_distributions.attribute12
                      ,x_attribute13                 => rec_distributions.attribute13
                      ,x_attribute14                 => rec_distributions.attribute14
                      ,x_attribute15                 => rec_distributions.attribute15
                      ,x_org_id                      => l_org_id
                    );

                    l_rowid := NULL;
                    l_distribution_id := NULL;
                    l_distribution_count :=   l_distribution_count + 1;

            END LOOP;

      END IF;

    END IF;
      pnp_debug_pkg.log('PN_REC_CALC_PKG.create_payment_terms  (-) ');

     EXCEPTION
     when others then
     pnp_debug_pkg.log('Error while' || l_context || to_char(sqlcode));
     p_error := 'Error creating billing term';
     p_error_code := -99;

END create_payment_terms;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_REC_PAYTERM_EXISTS
 |
 | DESCRIPTION
 |    Find if Recovery Payment Termfor a line/agreement is available
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Find if Recovery Payment Termfor a line/agreement is available
 |
 | MODIFICATION HISTORY
 |
 |     19-MAY-2003  Daniel Thota  o Created
 |     04-SEP-2003  Daniel Thota  o Removed DECODE and used IF..THEN..ELSE instead
 |                                  Fix for bugs 3123730,3122264
 |     05-SEP-2003  Daniel Thota  o Added code to delete from pn_distributions_all,
 |                                  before deleting from pn_payment_terms_all
 |     17-SEP-2003  Daniel Thota  o Put in cursors get_distributions_exist_nocons
 |                                  and cursors get_distributions_exist_cons
 |                                  Fix for bug # 3142328
 +===========================================================================*/
FUNCTION find_if_rec_payterm_exists(
         p_rec_agreement_id PN_REC_PERIOD_BILL_all.period_billrec_id%TYPE
         ,p_rec_agr_line_id PN_REC_PERIOD_BILL_all.rec_agr_line_id%TYPE
         ,p_rec_calc_period_id PN_REC_PERIOD_BILL_all.rec_calc_period_id%TYPE
         ,p_consolidate VARCHAR2
        )
      RETURN period_bill_record IS

      l_period_bill_record period_bill_record;
      l_context  VARCHAR2(2000);
      l_distributions_exist  VARCHAR2(1):= 'N';

      -- Fix for bug # 3142328
      CURSOR get_distributions_exist_nocons IS
        SELECT 'Y'
        FROM   dual
        WHERE EXISTS (SELECT 1
                      FROM  pn_distributions_all dist
                            ,pn_payment_terms_all term
                      WHERE term.payment_term_id = dist.payment_term_id
                      AND   term.period_billrec_id = l_period_bill_record.period_billrec_id
                      AND   term.rec_agr_line_id   = p_rec_agr_line_id
                      AND   term.status            = 'DRAFT')
        ;

      CURSOR get_distributions_exist_cons IS
        SELECT 'Y'
        FROM   dual
        WHERE EXISTS (SELECT 1
                      FROM  pn_distributions_all dist
                            ,pn_payment_terms_all term
                      WHERE term.payment_term_id = dist.payment_term_id
                      AND   term.period_billrec_id = l_period_bill_record.period_billrec_id
                      AND   term.status            = 'DRAFT')
        ;
      -- Fix for bug # 3142328

   BEGIN

        pnp_debug_pkg.log('PN_REC_CALC_PKG.find_if_rec_payterm_exists (+) ');

        l_period_bill_record.amount := 0;
        l_period_bill_record.period_billrec_id:= 0;
        l_distributions_exist := 'N';

     /* check to see if billed amount record exists for agreement or
        period line */

     l_context := 'selecting billed amount record';

     pnp_debug_pkg.log('find_if_rec_payterm_exists - getting billed_rec_id');

     IF (p_consolidate = 'N') THEN
        SELECT period_billrec_id
        INTO   l_period_bill_record.period_billrec_id
        FROM   PN_REC_PERIOD_BILL_all
        WHERE  rec_agreement_id   = p_rec_agreement_id
        AND    rec_agr_line_id    = p_rec_agr_line_id
        AND    rec_calc_period_id = p_rec_calc_period_id;
     ELSIF (p_consolidate = 'Y') THEN
        SELECT period_billrec_id
        INTO   l_period_bill_record.period_billrec_id
        FROM   PN_REC_PERIOD_BILL_all
        WHERE  rec_agreement_id   = p_rec_agreement_id
        AND    rec_calc_period_id = p_rec_calc_period_id;
     END IF;

     pnp_debug_pkg.log('find_if_rec_payterm_exists - bille_rec_id '|| l_period_bill_record.period_billrec_id);

     /* Get the amount of approved terms for the period */

     l_context := 'getting approved billed amount';

     pnp_debug_pkg.log('find_if_rec_payterm_exists - getting approved amount');

     IF (p_consolidate = 'N') THEN
        SELECT NVL(SUM(actual_amount),0)
        INTO   l_period_bill_record.amount
        FROM   pn_payment_terms_all
        WHERE  period_billrec_id = l_period_bill_record.period_billrec_id
        AND    rec_agr_line_id   = p_rec_agr_line_id
        AND    status            = 'APPROVED';
     ELSIF (p_consolidate = 'Y') THEN
        SELECT NVL(SUM(actual_amount),0)
        INTO   l_period_bill_record.amount
        FROM   pn_payment_terms_all
        WHERE  period_billrec_id = l_period_bill_record.period_billrec_id
        AND    status            = 'APPROVED';
     END IF;

     pnp_debug_pkg.log('find_if_rec_payterm_exists - approved amount'|| l_period_bill_record.amount);
     l_context := 'deleting billing terms';

     pnp_debug_pkg.log('find_if_rec_payterm_exists - deleting terms ');

     IF (p_consolidate = 'N') THEN

      -- Fix for bug # 3142328
        OPEN get_distributions_exist_nocons;
        FETCH get_distributions_exist_nocons INTO l_distributions_exist;
        CLOSE get_distributions_exist_nocons;

     pnp_debug_pkg.log('now deleting terms l_distributions_exist: '||l_distributions_exist);
        IF l_distributions_exist = 'Y' THEN

           DELETE pn_distributions_all
           WHERE  payment_term_id in (SELECT payment_term_id
                                      FROM   pn_payment_terms_all
                                      WHERE  period_billrec_id = l_period_bill_record.period_billrec_id
                                      AND    rec_agr_line_id   = p_rec_agr_line_id
                                      AND    status            = 'DRAFT')
           ;

        END IF;


        DELETE pn_payment_terms_all
        WHERE  period_billrec_id = l_period_bill_record.period_billrec_id
        AND    rec_agr_line_id   = p_rec_agr_line_id
        AND    status            = 'DRAFT';

     ELSIF (p_consolidate = 'Y') THEN

        -- Fix for bug # 3142328
        OPEN get_distributions_exist_cons;
        FETCH get_distributions_exist_cons INTO l_distributions_exist;
        CLOSE get_distributions_exist_cons;

        IF l_distributions_exist = 'Y' THEN

           DELETE pn_distributions_all
           WHERE  payment_term_id in (SELECT payment_term_id
                                      FROM   pn_payment_terms_all
                                      WHERE  period_billrec_id = l_period_bill_record.period_billrec_id
                                      AND    status            = 'DRAFT')
           ;

        END IF;

        DELETE pn_payment_terms_all
        WHERE  period_billrec_id = l_period_bill_record.period_billrec_id
        AND    status            = 'DRAFT';

     END IF;

     pnp_debug_pkg.log('find_if_rec_payterm_exists - terms deleted '|| to_char(SQL%ROWCOUNT));
     pnp_debug_pkg.log('PN_REC_CALC_PKG.find_if_rec_payterm_exists (-) ');

     RETURN l_period_bill_record;

   EXCEPTION

     WHEN NO_DATA_FOUND THEN
          RETURN NULL;

      WHEN OTHERS
      THEN
        pnp_debug_pkg.log('Error while '|| l_context || to_char(sqlcode));
        l_period_bill_record.period_billrec_id := -99;
        l_period_bill_record.amount := null;

END find_if_rec_payterm_exists;

/*===========================================================================+
 | FUNCTION
 |    GET_PRIOR_PERIOD_AMOUNT
 |
 | DESCRIPTION
 |    Obtains prior period amount for a line
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Obtains prior period amount for a line
 |
 | MODIFICATION HISTORY
 |
 |     19-MAY-2003  Daniel Thota  o Created
 +===========================================================================*/
FUNCTION get_prior_period_actual_amount(
         p_rec_agr_line_id   pn_rec_period_lines_all.rec_agr_line_id%TYPE
         ,p_start_date       pn_rec_calc_periods_all.start_date%TYPE
         ,p_as_of_date       pn_rec_calc_periods_all.as_of_date%TYPE
         ,p_called_from      VARCHAR2
        )
      RETURN pn_rec_period_lines_all.constrained_actual%TYPE IS

      l_prior_period_amount pn_rec_period_lines_all.actual_recovery%TYPE;
      l_percent          pn_rec_agr_linconst_all.value%TYPE;

      CURSOR csr_get_curr_percent (p_as_of_date date) is
        SELECT lineconst.VALUE
        FROM   pn_rec_agr_linconst_all lineconst
        WHERE  lineconst.rec_agr_line_id    = p_rec_agr_line_id
        AND    p_as_of_date between lineconst.start_date and lineconst.end_date
        AND    lineconst.RELATION = 'MAX'
        AND    lineconst.SCOPE = 'OPYA';

   BEGIN

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_prior_period_actual_amount (+) ');

     SELECT NVL(period_lines.constrained_actual,0)
     INTO   l_prior_period_amount
     FROM   pn_rec_period_lines_all period_lines
     WHERE  rec_agr_line_id    = p_rec_agr_line_id
     AND    end_date = (SELECT max(end_date)
                        FROM   pn_rec_period_lines_all
                        WHERE  start_date < p_start_date
                        AND    end_date < p_start_date
                        AND    rec_agr_line_id = p_rec_agr_line_id) ;


     IF p_called_from = 'CALCUI' THEN

        OPEN csr_get_curr_percent(p_as_of_date);
        FETCH csr_get_curr_percent into l_percent;
        IF csr_get_curr_percent%NOTFOUND THEN

          close csr_get_curr_percent;
          return null;

        END IF;


        l_prior_period_amount := (l_percent * l_prior_period_amount/100)+ l_prior_period_amount;

     END IF;

      RETURN l_prior_period_amount;

   EXCEPTION

      WHEN TOO_MANY_ROWS
      THEN
         pnp_debug_pkg.log('get_prior_period_actual_amount - Multiple prior periods found');

         IF p_called_from = 'CALCUI' THEN
           return null;
         ELSE
           return -99;
         END IF;

      /* if this routine is being called for the 1st calculation period
         prior period actual recovery will not be found. hence set it
         to -1 */

      WHEN NO_DATA_FOUND THEN
         IF p_called_from = 'CALCUI' THEN
           return null;
         ELSE
           RETURN -1;
         END IF;

      WHEN OTHERS
      THEN
         pnp_debug_pkg.log('Error getting prior period actual amount '|| to_char(sqlcode));
         IF p_called_from = 'CALCUI' THEN
           return null;
         ELSE
           return -99;
         END IF;

        pnp_debug_pkg.log('PN_REC_CALC_PKG.get_prior_period_actual_amount (-) ');

END get_prior_period_actual_amount;

/*===========================================================================+
 | FUNCTION
 | get_prior_period_cap
 |
 | DESCRIPTION
 |    Obtains prior period amount for a line
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Obtains prior period cap for a line
 |
 | MODIFICATION HISTORY
 |
 |     23-aug-2003  achauhan o Created
 +===========================================================================*/
FUNCTION get_prior_period_cap(
         p_rec_agr_line_id pn_rec_period_lines_all.rec_agr_line_id%TYPE
         ,p_start_date       pn_rec_calc_periods_all.start_date%TYPE
         ,p_end_date         pn_rec_calc_periods_all.end_date%TYPE
         ,p_as_of_date       pn_rec_calc_periods_all.as_of_date%TYPE
         ,p_called_from      VARCHAR2
        )
      RETURN pn_rec_period_lines_all.actual_recovery%TYPE IS

      l_percent          pn_rec_agr_linconst_all.value%TYPE;
      l_cap_amount       pn_rec_period_lines_all.actual_recovery%TYPE;
      l_start_date       pn_rec_period_lines_all.start_date%TYPE;
      l_end_date         pn_rec_period_lines_all.end_date%TYPE;

   CURSOR csr_get_base_cap is
     SELECT NVL(period_lines.actual_recovery,0), period_lines.start_date, period_lines.end_date
     FROM   pn_rec_period_lines_all period_lines
     WHERE  rec_agr_line_id    = p_rec_agr_line_id
     AND    start_date = (select min(start_date)
                        from   pn_rec_period_lines_all
                        WHERE  rec_agr_line_id = p_rec_agr_line_id) ;

   CURSOR csr_get_prior_periods (p_start_date date, p_fst_end_date date) is
     SELECT lineconst.VALUE
     FROM   pn_rec_period_lines_all period_lines,
            pn_rec_agr_linconst_all lineconst,
            pn_rec_calc_periods_all      recperiod
     WHERE  period_lines.rec_agr_line_id = p_rec_agr_line_id
     AND    recperiod.rec_calc_period_id = period_lines.rec_calc_period_id
     AND    recperiod.start_date         > p_fst_end_date
     AND    recperiod.end_date           > p_fst_end_date
     AND    recperiod.start_date         < p_start_date
     AND    recperiod.end_date           < p_start_date
     AND    lineconst.rec_agr_line_id    = period_lines.rec_agr_line_id
     AND    recperiod.as_of_date between lineconst.start_date and lineconst.end_date
     AND    lineconst.RELATION = 'MAX'
     AND    lineconst.SCOPE = 'OPYC';

   CURSOR csr_get_curr_percent (p_start_date date, p_end_date date, p_as_of_date date) is
     SELECT lineconst.VALUE
     FROM   pn_rec_agr_linconst_all lineconst
     WHERE  lineconst.rec_agr_line_id    = p_rec_agr_line_id
     AND    p_as_of_date between lineconst.start_date and lineconst.end_date
     AND    lineconst.RELATION = 'MAX'
     AND    lineconst.SCOPE = 'OPYC';

   BEGIN

     pnp_debug_pkg.log('PN_REC_CALC_PKG.get_prior_period_cap (+) ');

     OPEN csr_get_base_cap;
     FETCH csr_get_base_cap into l_cap_amount,l_start_date,l_end_date;

     /* If it is the calculation for the 1st period will not get any row in the cursor */

     IF csr_get_base_cap%NOTFOUND THEN

        CLOSE csr_get_base_cap;
         IF p_called_from = 'CALCUI' THEN
           return null;
         ELSE
           RETURN -1;
         END IF;

     /* If it is recalulate of the 1st period then also return back as -1 */

     ELSIF csr_get_base_cap%FOUND AND l_start_date = p_start_date AND l_end_date = p_end_date THEN

        CLOSE csr_get_base_cap;
         IF p_called_from = 'CALCUI' THEN
           return null;
         ELSE
           RETURN -1;
         END IF;

     END IF;
     CLOSE csr_get_base_cap;

     /* Derive the prior period cap */

     OPEN csr_get_prior_periods(p_start_date, l_end_date);

     LOOP

          FETCH csr_get_prior_periods into l_percent;
          EXIT WHEN csr_get_prior_periods%NOTFOUND;
          l_cap_amount := l_cap_amount + (l_cap_amount * l_percent/100);

     END LOOP;

     CLOSE csr_get_prior_periods;

     /* Derive the percent for the current period */

     OPEN csr_get_curr_percent(p_start_date, p_end_date, p_as_of_date);
     FETCH csr_get_curr_percent into l_percent;
     IF csr_get_curr_percent%NOTFOUND THEN

          close csr_get_curr_percent;
          IF p_called_from = 'CALCUI' THEN
             return null;
          ELSE
             RETURN -1;
          END IF;

     ELSE

          l_cap_amount := l_cap_amount + (l_cap_amount * l_percent/100);
          close csr_get_curr_percent;

      END IF;

      pnp_debug_pkg.log('PN_REC_CALC_PKG.get_prior_period_cap (-) ');

      RETURN l_cap_amount;

   EXCEPTION

      WHEN OTHERS
      THEN
         pnp_debug_pkg.log('Error getting prior year cap '|| to_char(sqlcode));
          IF p_called_from = 'CALCUI' THEN
             return null;
          ELSE
             return -99;
          END IF;


END get_prior_period_cap;

/*===========================================================================+
 | PROCEDURE
 | LOCK_AREA_EXP_CLASS_DTL
 |
 | DESCRIPTION
 |   Lock the status of the area class and expense class details for the approved billing term
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN: p_term_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 |     26-aug-2003  Ashish  o Created
 +===========================================================================*/


PROCEDURE lock_area_exp_cls_dtl(p_payment_term_id  in pn_payment_terms_all.payment_term_id%TYPE) is

cursor c_term is
select term.period_billrec_id,
       term.rec_agr_line_id
from   pn_payment_terms_all term
where  term.payment_term_id = p_payment_term_id;

cursor c_lines_cons is
select
     agr.customer_id         as customer_id,
     agr.lease_id            as lease_id,
     agr.location_id         as location_id,
     period.start_date        as start_date,
     period.end_date          as end_date ,
     period.as_of_date        as as_of_date ,
     agrlines.rec_agr_line_id as rec_agr_line_id
from pn_payment_terms_all    term
     ,pn_rec_period_bill_all  bill
     ,pn_rec_calc_periods_all  period
     ,pn_rec_agr_lines_all    agrlines
     ,pn_rec_agreements_all   agr
where term.payment_term_id = p_payment_term_id
 and  bill.period_billrec_id = term.period_billrec_id
 and  period.rec_calc_period_id = bill.rec_calc_period_id
 and  agrlines.rec_agreement_id = bill.rec_agreement_id
 and  period.as_of_date between agrlines.start_date and agrlines.end_date
 and  agr.rec_agreement_id = agrlines.rec_agreement_id
;

cursor c_lines is
select
     agr.customer_id         as customer_id,
     agr.lease_id            as lease_id,
     agr.location_id         as location_id,
     period.start_date        as start_date,
     period.end_date          as end_date ,
     period.as_of_date        as as_of_date ,
     agrlines.rec_agr_line_id as rec_agr_line_id
from pn_payment_terms_all    term
     ,pn_rec_period_bill_all  bill
     ,pn_rec_calc_periods_all  period
     ,pn_rec_agr_lines_all    agrlines
     ,pn_rec_agreements_all   agr
where term.payment_term_id = p_payment_term_id
 and  bill.period_billrec_id = term.period_billrec_id
 and  period.rec_calc_period_id = bill.rec_calc_period_id
 and  agrlines.rec_agreement_id = bill.rec_agreement_id
 and  agrlines.rec_agr_line_id = term.rec_agr_line_id
 and  period.as_of_date between agrlines.start_date and agrlines.end_date
 and  agr.rec_agreement_id = agrlines.rec_agreement_id
;

cursor  c_expense_class_detail(p_customer_id number,
                               p_lease_id    number,
                               p_location_id number,
                               p_calc_period_start_date  date,
                               p_calc_period_end_date    date,
                               p_calc_period_as_of_date    date,
                               p_rec_agr_line_id number) is
     SELECT
            exp_detail_hdr.expense_class_dtl_id as expense_class_dtl_id
     FROM   pn_rec_expcl_all        rec_exp_class
            ,pn_rec_agr_linexp_all  lineexp
            ,pn_rec_expcl_dtl_all   exp_detail_hdr
            ,pn_rec_exp_line_all    exp_extract_hdr
            ,pn_rec_expcl_dtlln_all exp_detail_line
     WHERE exp_detail_hdr.expense_class_dtl_id   = exp_detail_line.expense_class_dtl_id
     AND   exp_detail_line.cust_account_id       = p_customer_id
     AND   exp_detail_line.lease_id              = p_lease_id
     AND   exp_detail_line.location_id           = p_location_id
     AND   exp_extract_hdr.to_date               = p_calc_period_end_date
     AND   exp_extract_hdr.from_date             = p_calc_period_start_date
     AND   exp_extract_hdr.as_of_date             = p_calc_period_as_of_date
     AND   exp_extract_hdr.expense_line_id       = exp_detail_hdr.expense_line_id
     AND   exp_detail_hdr.expense_class_id       = rec_exp_class.expense_class_id
     AND   rec_exp_class.expense_class_id        = lineexp.expense_class_id
     AND   p_calc_period_as_of_date between lineexp.start_date and lineexp.end_date
     AND   lineexp.rec_agr_line_id               = p_rec_agr_line_id
     ;


cursor c_area_class_detail(    p_rec_agr_line_id         number,
                               p_as_of_date              date,
                               p_calc_period_start_date  date,
                               p_calc_period_end_date    date,
                               p_customer_id             number,
                               p_lease_id                number,
                               p_location_id             number
                               ) is
SELECT
        area_class_dtl_hdr.area_class_dtl_id  as area_class_dtl_id
     FROM   pn_rec_arcl_dtlln_all   area_class_dtl_lines
            ,pn_rec_arcl_dtl_all    area_class_dtl_hdr
            ,pn_rec_agr_linarea_all linearea
            ,pn_rec_arcl_all        aclass
     WHERE  linearea.rec_agr_line_id               = p_rec_agr_line_id
     AND    p_as_of_date between linearea.start_date and linearea.end_date
     AND    aclass.area_class_id                   = linearea.area_class_id
     AND    area_class_dtl_hdr.area_class_id       = aclass.area_class_id
     AND    area_class_dtl_hdr.as_of_date          = p_as_of_date
     AND    area_class_dtl_hdr.from_date           = p_calc_period_start_date
     AND    area_class_dtl_hdr.to_date             = p_calc_period_end_date
     AND    area_class_dtl_lines.area_class_dtl_id = area_class_dtl_hdr.area_class_dtl_id
     AND    area_class_dtl_lines.cust_account_id   = p_customer_id
     AND    area_class_dtl_lines.lease_id          = p_lease_id
     AND    area_class_dtl_lines.location_id       = p_location_id
     ;

l_customer_id         pn_rec_agreements_all.customer_id%TYPE;
l_lease_id            pn_rec_agreements_all.lease_id%TYPE;
l_location_id         pn_rec_agreements_all.location_id%TYPE;
l_start_date          pn_rec_calc_periods_all.start_date%TYPE;
l_end_date            pn_rec_calc_periods_all.end_date%TYPE;
l_as_of_date          pn_rec_calc_periods_all.as_of_date%TYPE;
l_rec_agr_line_id     pn_rec_agr_lines_all.rec_agr_line_id%TYPE;

begin

   pnp_debug_pkg.log('PN_REC_CALC_PKG.lock_area_exp_cls_dtl (+) ');

   FOR l_term_rec in c_term
   LOOP

       /* If it is a consolidated term then get all the recovery lines */

       IF nvl(l_term_rec.rec_agr_line_id, -1) = -1 THEN

          OPEN c_lines_cons;

       ELSE

          OPEN c_lines;

       END IF;

       LOOP

          IF c_lines_cons%ISOPEN THEN

             FETCH c_lines_cons INTO
                                    l_customer_id,
                                    l_lease_id,
                                    l_location_id,
                                    l_start_date,
                                    l_end_date,
                                    l_as_of_date,
                                    l_rec_agr_line_id;

             EXIT when c_lines_cons%NOTFOUND;

          ELSIF c_lines%ISOPEN THEN

             FETCH c_lines INTO
                                    l_customer_id,
                                    l_lease_id,
                                    l_location_id,
                                    l_start_date,
                                    l_end_date,
                                    l_as_of_date,
                                    l_rec_agr_line_id ;

             EXIT when c_lines%NOTFOUND;

          END IF;

          FOR l_exp_class_detail_rec in c_expense_class_detail(
                               l_customer_id,
                               l_lease_id,
                               l_location_id,
                               l_start_date,
                               l_end_date,
                               l_as_of_date,
                               l_rec_agr_line_id )
          LOOP
                 update pn_rec_expcl_dtl_all
                 set        status = 'LOCKED',
                            last_update_date = sysdate,
                            last_updated_by = NVL(fnd_profile.value('USER_ID'),0),
                            last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
                  where
                     expense_class_dtl_id = l_exp_class_detail_rec.expense_class_dtl_id;

          END LOOP;

          FOR l_area_class_detail_rec in c_area_class_detail(
                               l_rec_agr_line_id,
                               l_as_of_date,
                               l_start_date,
                               l_end_date,
                               l_customer_id,
                               l_lease_id,
                               l_location_id)
          LOOP
                  update pn_rec_arcl_dtl_all
                   set  status = 'LOCKED' ,
                        last_update_date = sysdate,
                        last_updated_by = NVL(fnd_profile.value('USER_ID'),0),
                        last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
                  where
                     area_class_dtl_id = l_area_class_detail_rec.area_class_dtl_id;
          END LOOP;

       END LOOP;

       IF c_lines_cons%ISOPEN THEN

          CLOSE c_lines_cons;

       ELSIF c_lines%ISOPEN THEN

          CLOSE c_lines;

       END IF;

    END LOOP;
    commit;
         pnp_debug_pkg.log('PN_REC_CALC_PKG.lock_area_exp_cls_dtl (-) ');
  Exception
     when others then
        pnp_debug_pkg.log(' error in PN_REC_CALC_PKG.lock_area_exp_cls_dtl :'||to_char(sqlcode)||' : '||sqlerrm);
        raise;

END lock_area_exp_cls_dtl ;

/*===========================================================================+
 | FUNCTION
 | validate_create_calc_period
 |
 | DESCRIPTION
 |   If the period record already exists for the recovery agreement for the
 |   calculation period specified through start_date, end_date, as_of_date
 |   then returns -1 else, creates a period record and returns rec_calc_period_id.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:  p_rec_agreement_id
 |                   p_start_date
 |		     p_end_date
 |                   p_as_of_date
 |
 | RETURNS    : rec_calc_period_id
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 |     05-Dec-2005  acprakas  o Created
 |     30-Dec-2008  acprakas  o Bug#7645185. Modified the insert stmt to populate org_id also.
 +===========================================================================*/

FUNCTION validate_create_calc_period(p_rec_agreement_id pn_rec_agreements_all.REC_AGREEMENT_ID%TYPE,
                                     p_start_date pn_rec_calc_periods_all.start_date%TYPE,
				     p_end_date   pn_rec_calc_periods_all.end_date%TYPE,
    				     p_as_of_date pn_rec_calc_periods_all.as_of_date%TYPE)
RETURN NUMBER
IS
l_rec_calc_period_id pn_rec_calc_periods_all.rec_calc_period_id%TYPE;
l_period_count NUMBER;
l_org_id NUMBER;
BEGIN
    pnp_debug_pkg.log('PN_REC_CALC_PKG.validate_create_calc_period (+) ');

    SELECT count(1)
    INTO l_period_count
    FROM pn_rec_calc_periods_all
    WHERE rec_agreement_id =  p_rec_agreement_id
    AND start_date =   p_start_date
    AND end_date = p_end_date
    AND as_of_date = p_as_of_date;

    l_org_id := pn_mo_cache_utils.get_current_org_id;

   IF l_period_count = 0
   THEN
	 select pn_rec_calc_periods_s.nextval
	 into l_rec_calc_period_id
	 from dual;

	 insert into pn_rec_calc_periods_all
                                   (rec_calc_period_id,
                                    REC_AGREEMENT_ID,
				    last_update_date,
				    last_updated_by,
				    creation_date,
				    created_by,
				    last_update_login,
				    start_date,
				    end_date,
				    as_of_date,
				    org_id
				   )
			     values
				   (l_rec_calc_period_id,
				    p_rec_agreement_id,
				    sysdate,
				    TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
				    sysdate,
				    TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
				    TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
				    p_start_date,
				    p_end_date,
				    p_as_of_date,
				    l_org_id
				   );
       return l_rec_calc_period_id;
  ELSE
       fnd_message.set_name ('PN','PN_REC_AGRMNT_PERIOD_EXIST');
       pnp_debug_pkg.put_log_msg(fnd_message.get);
       return -1;
  END IF;
pnp_debug_pkg.log('PN_REC_CALC_PKG.validate_create_calculation_period (-) ');

EXCEPTION
WHEN OTHERS THEN
   pnp_debug_pkg.log('error in PN_REC_CALC_PKG.validate_create_calc_period :'||to_char(sqlcode)||' : '||sqlerrm);
   raise;
END validate_create_calc_period;

END PN_REC_CALC_PKG;

/
