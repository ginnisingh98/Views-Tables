--------------------------------------------------------
--  DDL for Package Body PQH_FR_SYNC_SAL_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_SYNC_SAL_RATES" as
/* $Header: pqfrssrt.pkb 115.1 2004/01/08 09:14:26 kgowripe noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := ' pqh_fr_sync_sal_rates.';  -- Global package name
g_debug    boolean := hr_utility.debug_enabled; -- check for debug enabled or not
g_status   varchar2(1) := 'S'; -- Status variable defaulted to success
-- point value for the salary as of the effective date
g_sal_point_rate pqh_fr_global_indices_f.basic_salary_rate%TYPE;
g_sal_point_currency pqh_fr_global_indices_f.currency_code%TYPE;
g_gl_cet_id     pqh_copy_entity_txns.copy_entity_txn_id%TYPE := -1;
g_gl_currency_cd pqh_fr_global_indices_f.currency_code%TYPE;
g_conv_factor   NUMBER  := 1;
--
-- ----------------------------------------------------------------------------
-- |                     Private Procedure/Function Definitions                |
-- ----------------------------------------------------------------------------
--
PROCEDURE sync_all_rates(p_effective_date IN DATE);

PROCEDURE sync_rates_for_ib(p_effective_date IN DATE,
                                p_ib  IN NUMBER,
                                p_inm IN NUMBER);
PROCEDURE sync_rates_in_gsp_stage(p_effective_date IN DATE,
                                  p_ib IN NUMBER,
                                  p_inm IN NUMBER);
PROCEDURE get_bareme_point_value(p_effective_date IN DATE
                                ,p_basic_sal_rate OUT NOCOPY NUMBER
                                ,p_bareme_currency_cd OUT NOCOPY VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |                     sync_gsp_sal_rt_with_bareme                          |
-- ----------------------------------------------------------------------------
--

PROCEDURE sync_gsp_sal_rt_with_bareme(errbuf OUT NOCOPY VARCHAR2,
                                      retcode OUT NOCOPY VARCHAR2,
                                      p_effective_date IN DATE,
                                      p_mode IN VARCHAR2,
                                      p_commit_mode IN VARCHAR2,
                                      p_ib1  IN NUMBER Default NULL,
                                      p_ib2  IN NUMBER Default NULL,
                                      p_ib3  IN NUMBER Default NULL,
                                      p_ib4  IN NUMBER Default NULL,
                                      p_ib5  IN NUMBER Default NULL,
                                      p_ib6  IN NUMBER Default NULL,
                                      p_ib7  IN NUMBER Default NULL,
                                      p_ib8  IN NUMBER Default NULL,
                                      p_ib9  IN NUMBER Default NULL,
                                      p_ib10 IN NUMBER Default NULL) IS
l_conc_status boolean;
CURSOR csr_inm_for_ib (p_ib IN Number) IS
  SELECT  increased_index
  FROM    pqh_fr_global_indices_f
  WHERE   p_effective_date BETWEEN effective_start_date AND effective_end_date
  AND     gross_index = p_ib;
  l_inm1  NUMBER;
  l_inm2  NUMBER;
  l_inm3  NUMBER;
  l_inm4  NUMBER;
  l_inm5  NUMBER;
  l_inm6  NUMBER;
  l_inm7  NUMBER;
  l_inm8  NUMBER;
  l_inm9  NUMBER;
  l_inm10 NUMBER;
  l_proc  varchar2(72) := g_package||'sync_gsp_sal_rt_with_bareme';
BEGIN
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering '||l_proc,10);
  end if;
  g_status := 'S';
  IF p_commit_mode = 'VALIDATE' THEN
     SAVEPOINT sync_sal_rates;
  END IF;
--
  get_bareme_point_value(p_effective_date => p_effective_date
			,p_basic_sal_rate => g_sal_point_rate
			,p_bareme_currency_cd => g_sal_point_currency);
  IF p_mode = 'ALL' THEN

    sync_all_rates(p_effective_date => p_effective_date);

  ELSIF p_mode = 'SPECIFIC' THEN
    IF p_ib1 IS NOT NULL THEN
      OPEN csr_inm_for_ib(p_ib1);
      FETCH csr_inm_for_ib INTO l_inm1;
      CLOSE csr_inm_for_ib;
      IF l_inm1 IS NOT NULL THEN
         sync_rates_for_ib(p_effective_date => p_effective_date,
                               p_ib => p_ib1,
                               p_inm => l_inm1);
      END IF;
    END IF;
    IF p_ib2 IS NOT NULL THEN
      OPEN csr_inm_for_ib(p_ib2);
      FETCH csr_inm_for_ib INTO l_inm2;
      CLOSE csr_inm_for_ib;
      IF l_inm2 IS NOT NULL THEN
         sync_rates_for_ib(p_effective_date => p_effective_date,
                               p_ib => p_ib2,
                               p_inm => l_inm2);
      END IF;
    END IF;
    IF p_ib3 IS NOT NULL THEN
      OPEN csr_inm_for_ib(p_ib3);
      FETCH csr_inm_for_ib INTO l_inm3;
      CLOSE csr_inm_for_ib;
      IF l_inm3 IS NOT NULL THEN
         sync_rates_for_ib(p_effective_date => p_effective_date,
                               p_ib => p_ib3,
                               p_inm => l_inm3);
      END IF;
    END IF;
    IF p_ib4 IS NOT NULL THEN
      OPEN csr_inm_for_ib(p_ib4);
      FETCH csr_inm_for_ib INTO l_inm4;
      CLOSE csr_inm_for_ib;
      IF l_inm4 IS NOT NULL THEN
         sync_rates_for_ib(p_effective_date => p_effective_date,
                               p_ib => p_ib4,
                               p_inm => l_inm4);
      END IF;
    END IF;
    IF p_ib5 IS NOT NULL THEN
      OPEN csr_inm_for_ib(p_ib5);
      FETCH csr_inm_for_ib INTO l_inm5;
      CLOSE csr_inm_for_ib;
      IF l_inm5 IS NOT NULL THEN
         sync_rates_for_ib(p_effective_date => p_effective_date,
                               p_ib => p_ib5,
                               p_inm => l_inm5);
      END IF;
    END IF;
    IF p_ib6 IS NOT NULL THEN
      OPEN csr_inm_for_ib(p_ib6);
      FETCH csr_inm_for_ib INTO l_inm6;
      CLOSE csr_inm_for_ib;
      IF l_inm6 IS NOT NULL THEN
         sync_rates_for_ib(p_effective_date => p_effective_date,
                               p_ib => p_ib6,
                               p_inm => l_inm6);
      END IF;
    END IF;
    IF p_ib7 IS NOT NULL THEN
      OPEN csr_inm_for_ib(p_ib7);
      FETCH csr_inm_for_ib INTO l_inm7;
      CLOSE csr_inm_for_ib;
      IF l_inm7 IS NOT NULL THEN
         sync_rates_for_ib(p_effective_date => p_effective_date,
                               p_ib => p_ib7,
                               p_inm => l_inm7);
      END IF;
    END IF;
    IF p_ib8 IS NOT NULL THEN
      OPEN csr_inm_for_ib(p_ib8);
      FETCH csr_inm_for_ib INTO l_inm8;
      CLOSE csr_inm_for_ib;
      IF l_inm8 IS NOT NULL THEN
         sync_rates_for_ib(p_effective_date => p_effective_date,
                               p_ib => p_ib8,
                               p_inm => l_inm8);
      END IF;
    END IF;
    IF p_ib9 IS NOT NULL THEN
      OPEN csr_inm_for_ib(p_ib9);
      FETCH csr_inm_for_ib INTO l_inm9;
      CLOSE csr_inm_for_ib;
      IF l_inm9 IS NOT NULL THEN
         sync_rates_for_ib(p_effective_date => p_effective_date,
                               p_ib => p_ib9,
                               p_inm => l_inm9);
      END IF;
    END IF;
    IF p_ib10 IS NOT NULL THEN
      OPEN csr_inm_for_ib(p_ib10);
      FETCH csr_inm_for_ib INTO l_inm10;
      CLOSE csr_inm_for_ib;
      IF l_inm10 IS NOT NULL THEN
         sync_rates_for_ib(p_effective_date => p_effective_date,
                               p_ib => p_ib10,
                               p_inm => l_inm10);
      END IF;
    END IF;
  END IF;   --End Mode Specific

  IF g_status = 'E' THEN
    l_conc_status := fnd_concurrent.set_completion_status(status => 'ERROR'
                                                         ,message=>SQLERRM);
  END IF;
  IF p_commit_mode = 'VALIDATE' THEN
        ROLLBACK TO sync_sal_rates;
  ELSE
        COMMIT;
  END IF;

  if g_debug then
     hr_utility.set_location('Leaving '||l_proc,20);
  end if;

END sync_gsp_sal_rt_with_bareme;
--
-- ----------------------------------------------------------------------------
-- |                     sync_all_rates                                       |
-- ----------------------------------------------------------------------------
--
PROCEDURE sync_all_rates(p_effective_date IN DATE) IS
CURSOR csr_all_ib_inms IS
  SELECT gross_index,increased_index
  FROM   pqh_fr_global_indices_f
  WHERE  p_effective_date BETWEEN effective_start_date AND effective_end_date;
  l_proc  varchar2(72) := g_package||'.sync_all_rates';
BEGIN
  if g_debug then
     hr_utility.set_location('Entering '||l_proc,10);
  end if;
  FOR l_glb_ind_rec IN csr_all_ib_inms
  LOOP
      sync_rates_for_ib(p_effective_date => p_effective_date,
                        p_ib             => l_glb_ind_rec.gross_index,
                        p_inm            => l_glb_ind_rec.increased_index);
  END LOOP;
  if g_debug then
     hr_utility.set_location('Entering '||l_proc,10);
  end if;
EXCEPTION
   When Others THEN
    fnd_file.put_line(fnd_file.log,SQLERRM);
    g_status := 'E';
END sync_all_rates;
--
-- ----------------------------------------------------------------------------
-- |                     sync_rates_for_ib                                    |
-- ----------------------------------------------------------------------------
--
PROCEDURE sync_rates_for_ib(p_effective_date IN DATE,
                            p_ib  IN NUMBER,
                            p_inm IN NUMBER) IS
 CURSOR  csr_prog_points_with_ib IS
    SELECT pps.parent_spine_id,pps.name,psp.spinal_point_id
    FROM   per_spinal_points psp,
           per_parent_spines pps
    WHERE  psp.information_category = 'FR_PQH'
    AND    psp.information1 = p_ib
    AND    psp.parent_spine_id = pps.parent_spine_id;

/* Update rates that have the name same as the Pay scale name */
 CURSOR csr_hrrate_for_point(p_point_id IN NUMBER, p_scale_name varchar2) IS
    SELECT pgr.grade_rule_id,pgr.currency_code,pgr.value,pgr.object_version_number
    FROM   pay_grade_rules_f pgr,
           pay_rates pr
    WHERE  pgr.rate_type = 'SP'
    AND    pgr.grade_or_spinal_point_id = p_point_id
    AND    p_effective_date BETWEEN pgr.effective_start_date AND pgr.effective_end_date
    AND    pgr.rate_id =pr.rate_id
    AND    pr.name = p_scale_name;
    l_rt_currency_cd  pay_grade_rules_f.currency_code%TYPE;
    l_new_value NUMBER := 0;
    l_conv_factor NUMBER := 1;
    l_dt_upd_mode VARCHAR2(30);
    l_effective_start_date DATE;
    l_effective_end_date   DATE;
    l_proc varchar2(72) := g_package||'.sync_rates_for_ib';
BEGIN

  if g_debug then
     hr_utility.set_location('Entering '||l_proc,10);
  end if;

 FOR l_sp_rec IN csr_prog_points_with_ib
 LOOP
    FOR l_rate_rec IN csr_hrrate_for_point(l_sp_rec.spinal_point_id,l_sp_rec.name)
    LOOP
       IF l_rate_rec.currency_code IS NOT NULL THEN
         BEGIN
             l_conv_factor := hr_currency_pkg.get_rate(p_from_currency => g_sal_point_currency,
                                                       p_to_currency => l_rate_rec.currency_code,
                                                       p_conversion_date => p_effective_date,
                                                       p_rate_type => 'Corporate');
             IF l_conv_factor IS NULL THEN
               l_conv_factor := 1;
             END IF;
         EXCEPTION
            When Others Then
               l_conv_factor := 1;
         END;
       END IF;
-- Now apply the conversion rates to Grade ladder Currency from the Bareme Currency
       l_new_value := (p_inm*g_sal_point_rate)*l_conv_factor;

       l_dt_upd_mode := pqh_gsp_stage_to_ben.get_update_mode(p_table_name => 'PAY_GRADE_RULES_F'
                                                            ,p_key_column_name => 'GRADE_RULE_ID'
                                                            ,p_key_column_value => l_rate_rec.grade_rule_id
                                                            ,p_effective_date => p_effective_date);
       hr_rate_values_api.update_rate_value
       (p_effective_date           => p_effective_date
       ,p_value                    => nvl(l_new_value,0)
       ,p_grade_rule_id            => l_rate_rec.grade_rule_id
       ,p_datetrack_mode           => l_dt_upd_mode
       ,p_object_version_number    => l_rate_rec.object_version_number
       ,p_effective_start_date     => l_effective_start_date
       ,p_effective_end_date       => l_effective_end_date);
    END LOOP;
 END LOOP;
/*
 sync_rates_in_gsp_stage(p_effective_date => p_effective_date,
                         p_ib => p_ib,
                         p_inm => p_inm);
*/
  if g_debug then
     hr_utility.set_location('Leaving '||l_proc,20);
  end if;
EXCEPTION
   When Others THEN
    fnd_file.put_line(fnd_file.log,SQLERRM);
    g_status := 'E';
END sync_rates_for_ib;
--
-- ----------------------------------------------------------------------------
-- |                     get_bareme_point_value                               |
-- ----------------------------------------------------------------------------
--
PROCEDURE get_bareme_point_value(p_effective_date IN DATE
                                ,p_basic_sal_rate OUT NOCOPY NUMBER
                                ,p_bareme_currency_cd OUT NOCOPY VARCHAR2) IS
  CURSOR csr_point_value IS
     SELECT basic_salary_rate,currency_code
     FROM   pqh_fr_global_indices_f
     WHERE  p_effective_date BETWEEN effective_start_date AND effective_end_date
     AND    type_of_record = 'INM';
   l_proc varchar2(72) := g_package||'.get_bareme_point_value';
BEGIN
  if g_debug then
     hr_utility.set_location('Entering '||l_proc,10);
  end if;
    OPEN csr_point_value;
    FETCH csr_point_value INTO p_basic_sal_rate,p_bareme_currency_cd;
    CLOSE csr_point_value;
  if g_debug then
     hr_utility.set_location('Leaving '||l_proc,20);
  end if;
END get_bareme_point_value;
--
-- ----------------------------------------------------------------------------
-- |                     sync_rates_in_gsp_stage                              |
-- ----------------------------------------------------------------------------
--
PROCEDURE sync_rates_in_gsp_stage(p_effective_date IN DATE,
                                  p_ib IN NUMBER,
                                  p_inm IN NUMBER) IS
CURSOR csr_sp_rows_in_stage IS
  SELECT  cer.copy_entity_result_id,cer.copy_entity_txn_id
  FROM    ben_copy_entity_results cer,
          pqh_copy_entity_txns cet
  WHERE   cer.table_alias = 'OPT'
  AND     cer.dml_operation = 'INSERT'
  AND     NVL(cer.information101,'XXX') = 'FR_PQH'
  AND     NVL(cer.information173,-9999) = p_ib
  AND     cer.copy_entity_txn_id = cet.copy_entity_txn_id
  AND     cet.status <> 'COMPLETED'
  ORDER BY cer.copy_entity_txn_id;

  CURSOR csr_gl_currency (p_cet_id IN NUMBER) IS
      SELECT information50
      FROM   ben_copy_entity_results
      WHERE  copy_entity_txn_id = p_cet_id
      AND    table_alias = 'PGM';
--Only Update rates for newly created rows.. as for completed information
--the udpates are done already.
CURSOR csr_hrrate_rows_in_stage(p_sp_cer_id IN NUMBER, p_cet_id IN NUMBER) IS
  SELECT  copy_entity_result_id,information297
  FROM    ben_copy_entity_results
  WHERE   copy_entity_txn_id = p_cet_id
  AND     table_alias = 'HRRATE'
  AND     dml_operation  = 'INSERT'
  AND     information278 = p_sp_cer_id
  AND     information1 IS NULL;

  l_new_value NUMBER := 0;
  l_proc  varchar2(72) := g_package||'sync_rates_in_gsp_stage';
BEGIN
  if g_debug then
     hr_utility.set_location('Entering '||l_proc,10);
  end if;
   FOR l_sp_rec IN csr_sp_rows_in_stage
   LOOP
--get the GL currency code and the corresponding currency value for each CET
   IF NVL(g_gl_cet_id,-1) <> l_sp_rec.copy_entity_txn_id THEN
     OPEN csr_gl_currency(l_sp_rec.copy_entity_txn_id);
     FETCH csr_gl_currency INTO g_gl_currency_cd;
     CLOSE csr_gl_currency;
     IF g_gl_currency_cd IS NOT NULL THEN
       BEGIN
          g_conv_factor := hr_currency_pkg.get_rate(p_from_currency => g_sal_point_currency,
                                                  p_to_currency => g_gl_currency_cd,
                                                  p_conversion_date => p_effective_date,
                                                  p_rate_type => 'Corporate');
          IF g_conv_factor IS NULL THEN
             g_conv_factor := 1;
          END IF;
       EXCEPTION
          When Others Then
             g_conv_factor := 1;
       END;
     END IF;
   END IF;
-- Now apply the conversion rates to Grade ladder Currency from the Bareme Currency
   l_new_value := (p_inm*g_sal_point_rate)*g_conv_factor;


       FOR l_hrrate_rec IN csr_hrrate_rows_in_stage(l_sp_rec.copy_entity_result_id,l_sp_rec.copy_entity_txn_id)
       LOOP
          UPDATE  ben_copy_entity_results
          SET     information297 = NVL(l_new_value,0)
          WHERE   copy_entity_result_id = l_hrrate_rec.copy_entity_result_id;
       END LOOP;
   END LOOP;
  if g_debug then
     hr_utility.set_location('Leaving '||l_proc,20);
  end if;
EXCEPTION
   When Others THEN
    fnd_file.put_line(fnd_file.log,SQLERRM);
    g_status := 'E';
END sync_rates_in_gsp_stage;
END pqh_fr_sync_sal_rates;

/
