--------------------------------------------------------
--  DDL for Package Body PAY_ES_BENEFIT_UPLIFT_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ES_BENEFIT_UPLIFT_CALC" AS
/* $Header: pyesssbu.pkb 120.0 2005/05/29 04:39:34 appldev noship $ */
--
-- Global Variables
hr_formula_error  EXCEPTION;
g_gross_per_day_formula_exists  BOOLEAN := TRUE;
g_gross_per_day_formula_cached  BOOLEAN := FALSE;
g_gross_per_day_formula_id      ff_formulas_f.formula_id%TYPE;
g_gross_per_day_formula_name    ff_formulas_f.formula_name%TYPE;
--
g_duration_formula_exists       BOOLEAN := TRUE;
g_duration_formula_cached       BOOLEAN := FALSE;
g_duration_formula_id           ff_formulas_f.formula_id%TYPE;
g_duration_formula_name         ff_formulas_f.formula_name%TYPE;
-------------------------------------------------------------------------------
-- FUNCTION  get_gross_per_day
-------------------------------------------------------------------------------
FUNCTION  get_gross_per_day(p_assignment_id              IN NUMBER
                           ,p_business_group_id          IN NUMBER
			               ,p_date_earned                IN DATE
                           ,p_formula_name               IN VARCHAR2
                           ) RETURN NUMBER IS
--
    l_inputs          ff_exec.inputs_t;
    l_outputs         ff_exec.outputs_t;
    l_formula_exists  BOOLEAN := TRUE;
    l_formula_cached  BOOLEAN := FALSE;
    l_formula_id      ff_formulas_f.formula_id%TYPE;
    l_gross_per_day   VARCHAR2(500);
--
BEGIN
    -- hr_utility.trace_on(null,'EFT');
    hr_utility.set_location('--In Gross per Day ',10);
    --
    g_gross_per_day_formula_name := p_formula_name;
    --
    IF  g_gross_per_day_formula_exists THEN
        --
        IF  g_gross_per_day_formula_exists THEN
            --
		    IF g_gross_per_day_formula_cached = FALSE THEN
                cache_formula(p_formula_name,p_business_group_id,p_date_earned,l_formula_id,l_formula_exists,l_formula_cached);
                g_gross_per_day_formula_exists:=l_formula_exists;
                g_gross_per_day_formula_cached:=l_formula_cached;
                g_gross_per_day_formula_id:=l_formula_id;
		    END IF;
		    --
		    IF g_gross_per_day_formula_exists  THEN
                --
                l_inputs(1).name  := 'ASSIGNMENT_ID';
                l_inputs(1).value := p_assignment_id;
                l_inputs(2).name  := 'DATE_EARNED';
                l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
                l_inputs(3).name  := 'BUSINESS_GROUP_ID';
                l_inputs(3).value := p_business_group_id;
                --
                l_outputs(1).name := 'GROSS_PAY_PER_DAY';
                --
                run_formula(p_formula_id       => g_gross_per_day_formula_id,
                            p_effective_date   => p_date_earned,
                            p_formula_name     => g_gross_per_day_formula_name,
                            p_inputs           => l_inputs,
                            p_outputs          => l_outputs);
                --
                l_gross_per_day := substr(l_outputs(1).value,1,32);
                --
		    END IF;

	      END IF;

        --
    END IF;
    hr_utility.set_location('--In Formula Return ',11);
    --
    RETURN l_gross_per_day;
    --
END get_gross_per_day;
--------------------------------------------------------------------------------
-- FUNCTION  get_duration
--------------------------------------------------------------------------------
FUNCTION  get_duration(p_assignment_id              IN NUMBER
                      ,p_business_group_id          IN NUMBER
                      ,p_date_earned                IN DATE
                      ,p_formula_name               IN VARCHAR2
                      ,p_rate1                      OUT NOCOPY NUMBER
                      ,p_value1                     OUT NOCOPY NUMBER
                      ,p_rate2                      OUT NOCOPY NUMBER
                      ,p_value2                     OUT NOCOPY NUMBER
                      ,p_rate3                      OUT NOCOPY NUMBER
                      ,p_value3                     OUT NOCOPY NUMBER
                      ,p_rate4                      OUT NOCOPY NUMBER
                      ,p_value4                     OUT NOCOPY NUMBER
                      ,p_rate5                      OUT NOCOPY NUMBER
                      ,p_value5                     OUT NOCOPY NUMBER
                      ,p_rate6                      OUT NOCOPY NUMBER
                      ,p_value6                     OUT NOCOPY NUMBER
                      ,p_rate7                      OUT NOCOPY NUMBER
                      ,p_value7                     OUT NOCOPY NUMBER
                      ,p_rate8                      OUT NOCOPY NUMBER
                      ,p_value8                     OUT NOCOPY NUMBER
                      ,p_rate9                      OUT NOCOPY NUMBER
                      ,p_value9                     OUT NOCOPY NUMBER
                      ,p_rate10                     OUT NOCOPY NUMBER
                      ,p_value10                    OUT NOCOPY NUMBER
                       ) RETURN VARCHAR2 IS
    --
    l_inputs                ff_exec.inputs_t;
    l_outputs               ff_exec.outputs_t;
    l_formula_exists        BOOLEAN := TRUE;
    l_formula_cached        BOOLEAN := FALSE;
    l_formula_id            ff_formulas_f.formula_id%TYPE;
    l_return_indicator      VARCHAR2(1);
    --
BEGIN
    -- hr_utility.trace_on(null,'EFT');
    hr_utility.set_location('--In Get Duration ',10);
    --
    l_return_indicator := 'N';
    g_duration_formula_name := p_formula_name;
    --
    IF  g_duration_formula_exists = TRUE THEN
        IF  g_duration_formula_cached = FALSE THEN
            cache_formula(p_formula_name,p_business_group_id,p_date_earned,l_formula_id,l_formula_exists,l_formula_cached);
            g_duration_formula_exists:=l_formula_exists;
            g_duration_formula_cached:=l_formula_cached;
            g_duration_formula_id:=l_formula_id;
        END IF;
    --
        IF g_duration_formula_exists  THEN
            --
            l_inputs(1).name  := 'ASSIGNMENT_ID';
            l_inputs(1).value := p_assignment_id;
            l_inputs(2).name  := 'DATE_EARNED';
            l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
            l_inputs(3).name  := 'BUSINESS_GROUP_ID';
            l_inputs(3).value := p_business_group_id;
            --
            l_outputs(1).name := 'RATE1';
            l_outputs(2).name := 'VALUE1';
            l_outputs(3).name := 'RATE2';
            l_outputs(4).name := 'VALUE2';
            l_outputs(5).name := 'RATE3';
            l_outputs(6).name := 'VALUE3';
            l_outputs(7).name := 'RATE4';
            l_outputs(8).name := 'VALUE4';
            l_outputs(9).name := 'RATE5';
            l_outputs(10).name := 'VALUE5';
            l_outputs(11).name := 'RATE6';
            l_outputs(12).name := 'VALUE6';
            l_outputs(13).name := 'RATE7';
            l_outputs(14).name := 'VALUE7';
            l_outputs(15).name := 'RATE8';
            l_outputs(16).name := 'VALUE8';
            l_outputs(17).name := 'RATE9';
            l_outputs(18).name := 'VALUE9';
            l_outputs(19).name := 'RATE10';
            l_outputs(20).name := 'VALUE10';
            --
            run_formula(p_formula_id       => g_duration_formula_id
                       ,p_effective_date   => p_date_earned
                       ,p_formula_name     => g_duration_formula_name
                       ,p_inputs           => l_inputs
                       ,p_outputs          => l_outputs);
            --
            p_rate1     := substr(l_outputs(1).value,1,32);
            p_value1    := substr(l_outputs(2).value,1,32);
            p_rate2     := substr(l_outputs(3).value,1,32);
            p_value2    := substr(l_outputs(4).value,1,32);
            p_rate3     := substr(l_outputs(5).value,1,32);
            p_value3    := substr(l_outputs(6).value,1,32);
            p_rate4     := substr(l_outputs(7).value,1,32);
            p_value4    := substr(l_outputs(8).value,1,32);
            p_rate5     := substr(l_outputs(9).value,1,32);
            p_value5    := substr(l_outputs(10).value,1,32);
            p_rate6     := substr(l_outputs(11).value,1,32);
            p_value6    := substr(l_outputs(12).value,1,32);
            p_rate7     := substr(l_outputs(13).value,1,32);
            p_value7    := substr(l_outputs(14).value,1,32);
            p_rate8     := substr(l_outputs(15).value,1,32);
            p_value8    := substr(l_outputs(16).value,1,32);
            p_rate9     := substr(l_outputs(17).value,1,32);
            p_value9    := substr(l_outputs(18).value,1,32);
            p_rate10    := substr(l_outputs(19).value,1,32);
            p_value10   := substr(l_outputs(20).value,1,32);
            --
            IF p_rate1 IS NULL OR p_rate1 < 0 THEN
                p_rate1 := 0;
            END IF;
            IF p_rate2 IS NULL OR p_rate2 < 0 THEN
                p_rate2 := 0;
            END IF;
            IF p_rate3 IS NULL OR p_rate3 < 0 THEN
                p_rate3 := 0;
            END IF;
            IF p_rate4 IS NULL OR p_rate4 < 0 THEN
                p_rate4 := 0;
            END IF;
            IF p_rate5 IS NULL OR p_rate5 < 0 THEN
                p_rate5 := 0;
            END IF;
            IF p_rate6 IS NULL OR p_rate6 < 0 THEN
                p_rate6 := 0;
            END IF;
            IF p_rate7 IS NULL OR p_rate7 < 0 THEN
                p_rate7 := 0;
            END IF;
            IF p_rate8 IS NULL OR p_rate8 < 0 THEN
                p_rate8 := 0;
            END IF;
            IF p_rate9 IS NULL OR p_rate9 < 0 THEN
                p_rate9 := 0;
            END IF;
            IF p_rate10 IS NULL OR p_rate10 < 0 THEN
                p_rate10 := 0;
            END IF;
            --
            IF p_value1 IS NULL OR p_value1 < 0 THEN
                p_value1 := 0;
            END IF;
            IF p_value2 IS NULL OR p_value2 < 0 THEN
                p_value2 := 0;
            END IF;
            IF p_value3 IS NULL OR p_value3 < 0 THEN
                p_value3 := 0;
            END IF;
            IF p_value4 IS NULL OR p_value4 < 0 THEN
                p_value4 := 0;
            END IF;
            IF p_value5 IS NULL OR p_value5 < 0 THEN
                p_value5 := 0;
            END IF;
            IF p_value6 IS NULL OR p_value6 < 0 THEN
                p_value6 := 0;
            END IF;
            IF p_value7 IS NULL OR p_value7 < 0 THEN
                p_value7 := 0;
            END IF;
            IF p_value8 IS NULL OR p_value8 < 0 THEN
                p_value8 := 0;
            END IF;
            IF p_value9 IS NULL OR p_value9 < 0 THEN
                p_value9 := 0;
            END IF;
            IF p_value10 IS NULL OR p_value10 < 0 THEN
                p_value10 := 0;
            END IF;
            --
            l_return_indicator := 'Y';
            --
        END IF;
        --
    END IF;
    hr_utility.set_location('--In Formula Return ',11);
    --
    RETURN l_return_indicator;
    --
END get_duration;
-------------------------------------------------------------------------------
-- PROCEDURE cache_formula
-------------------------------------------------------------------------------
PROCEDURE cache_formula(p_formula_name           IN VARCHAR2
                        ,p_business_group_id     IN NUMBER
                        ,p_effective_date        IN DATE
                        ,p_formula_id		 IN OUT NOCOPY NUMBER
                        ,p_formula_exists	 IN OUT NOCOPY BOOLEAN
                        ,p_formula_cached	 IN OUT NOCOPY BOOLEAN
                        ) IS

  --
  CURSOR c_compiled_formula_exist IS
  SELECT 'Y'
  FROM   ff_formulas_f ff
        ,ff_compiled_info_f ffci
  WHERE  ff.formula_id           = ffci.formula_id
  AND    ff.effective_start_date = ffci.effective_start_date
  AND    ff.effective_end_date   = ffci.effective_end_date
  AND    ff.formula_id           = p_formula_id
  AND    ff.business_group_id    = p_business_group_id
  AND    p_effective_date        BETWEEN ff.effective_start_date
                                 AND     ff.effective_end_date;
  --
  CURSOR c_get_formula(p_formula_name ff_formulas_f.formula_name%TYPE
                                 ,p_effective_date DATE)  IS
  SELECT ff.formula_id
  FROM   ff_formulas_f ff
  WHERE  ff.formula_name         = p_formula_name
  AND    ff.business_group_id    = p_business_group_id
  AND    p_effective_date        BETWEEN ff.effective_start_date
                                 AND     ff.effective_end_date;
  --
  l_test VARCHAR2(1);
  --
BEGIN
--
  IF p_formula_cached = FALSE THEN
  --
    OPEN c_get_formula(p_formula_name,p_effective_date);
    FETCH c_get_formula INTO p_formula_id;
      IF c_get_formula%FOUND THEN
         OPEN c_compiled_formula_exist;
         FETCH c_compiled_formula_exist INTO l_test;
         IF  c_compiled_formula_exist%NOTFOUND THEN
             p_formula_cached := FALSE;
             p_formula_exists := FALSE;
             --
             fnd_message.set_name('PAY','FFX03A_FORMULA_NOT_FOUND');
             fnd_message.set_token('1', p_formula_name);
             fnd_message.raise_error;
         ELSE
             p_formula_cached := FALSE;
             p_formula_exists := TRUE;
         END IF;
      ELSE
          p_formula_cached := FALSE;
          p_formula_exists := FALSE;
      END IF;
    CLOSE c_get_formula;
  END IF;
--
END cache_formula;
-------------------------------------------------------------------------------
-- PROCEDURE run_formula
-------------------------------------------------------------------------------
PROCEDURE run_formula(p_formula_id      IN NUMBER
                     ,p_effective_date  IN DATE
                     ,p_formula_name    IN VARCHAR2
                     ,p_inputs          IN ff_exec.inputs_t
                     ,p_outputs         IN OUT NOCOPY ff_exec.outputs_t) IS
    --
    l_inputs ff_exec.inputs_t;
    l_outputs ff_exec.outputs_t;
    --
BEGIN
  hr_utility.set_location('--In Formula ',20);
  --
  -- Initialize the formula
  --
  ff_exec.init_formula(p_formula_id, p_effective_date  , l_inputs, l_outputs);
  --
  -- Set up the input values
  --
  IF l_inputs.count > 0 and p_inputs.count > 0 THEN
    FOR i IN l_inputs.first..l_inputs.last LOOP
      FOR j IN p_inputs.first..p_inputs.last LOOP
        IF l_inputs(i).name = p_inputs(j).name THEN
           l_inputs(i).value := p_inputs(j).value;
           exit;
        END IF;
     END LOOP;
    END LOOP;
  END IF;
  --
  -- Run the formula
  --
  ff_exec.run_formula(l_inputs,l_outputs);
  --
  -- Populate the output table
  --
  IF l_outputs.count > 0 and p_inputs.count > 0 then
    FOR i IN l_outputs.first..l_outputs.last LOOP
        FOR j IN p_outputs.first..p_outputs.last LOOP
            IF l_outputs(i).name = p_outputs(j).name THEN
              p_outputs(j).value := l_outputs(i).value;
              exit;
            END IF;
        END LOOP;
    END LOOP;
  END IF;
  hr_utility.set_location('--Leaving Formula ',21);
  EXCEPTION
  WHEN hr_formula_error THEN
      fnd_message.set_name('PER','FFX22J_FORMULA_NOT_FOUND');
      fnd_message.set_token('1', p_formula_name);
      fnd_message.raise_error;
  WHEN OTHERS THEN
    raise;
--
END run_formula;
--
END pay_es_benefit_uplift_calc;

/
