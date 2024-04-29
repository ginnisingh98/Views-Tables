--------------------------------------------------------
--  DDL for Package Body PAYWSFGT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAYWSFGT_PKG" AS
-- $Header: pyfgtpkg.pkb 115.4 2002/12/10 18:44:45 dsaxby noship $
--
-- +---------------------------------------------------------------------------+
-- | Global Constants                                                          |
-- +---------------------------------------------------------------------------+
  -- The end-of-line character to use in generated PL/SQL
  g_eol CONSTANT VARCHAR2(10) := fnd_global.newline;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : write_fgt_check                                              |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE write_fgt_check(
    p_id      IN     NUMBER,
    p_sql     IN OUT NOCOPY VARCHAR2,
    p_has_bus IN     BOOLEAN,
    p_has_pay IN     BOOLEAN
  ) IS
  BEGIN
    p_sql := p_sql||'  /* Is the trigger in an enabled functional area */';
    p_sql := p_sql||g_eol;
    --
    p_sql := p_sql||'  IF paywsfgt_pkg.trigger_is_not_enabled('||g_eol;
    --
    p_sql := p_sql||'    p_event_id          => '||TO_CHAR(p_id)||','||g_eol;
    --
    p_sql := p_sql||'    p_legislation_code  => ';
    IF p_has_bus THEN
      p_sql := p_sql||'l_legislation_code,'||g_eol;
    ELSE
      p_sql := p_sql||'NULL,'||g_eol;
    END IF;
    --
    p_sql := p_sql||'    p_business_group_id => ';
    IF p_has_bus THEN
      p_sql := p_sql||'l_business_group_id,'||g_eol;
    ELSE
      p_sql := p_sql||'NULL,'||g_eol;
    END IF;
    --
    p_sql := p_sql||'    p_payroll_id        => ';
    IF p_has_pay THEN
      p_sql := p_sql||'l_payroll_id'||g_eol;
    ELSE
      p_sql := p_sql||'NULL'||g_eol;
    END IF;
    --
    p_sql := p_sql||'  ) THEN'||g_eol;
    p_sql := p_sql||'    RETURN;'||g_eol;
    p_sql := p_sql||'  END IF;'||g_eol;
    p_sql := p_sql||'  --'||g_eol;
    --
  END write_fgt_check;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : trigger_is_not_enabled                                       |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: See header                                                   |
-- +---------------------------------------------------------------------------+
  FUNCTION trigger_is_not_enabled(
    p_event_id          IN NUMBER,
    p_legislation_code  IN VARCHAR2 DEFAULT NULL,
    p_business_group_id IN NUMBER   DEFAULT NULL,
    p_payroll_id        IN NUMBER   DEFAULT NULL
  ) RETURN BOOLEAN IS
    --
    CURSOR csr_in_area(cp_id IN NUMBER) IS
      SELECT  'Y'
      FROM    pay_functional_triggers
      WHERE   event_id = cp_id;
    --
    CURSOR csr_leg_enb(
      cp_id   IN NUMBER,
      cp_leg  IN VARCHAR2
    ) IS
      SELECT  'Y'
      FROM    pay_functional_usages   pfu,
              pay_functional_areas    pfa,
              pay_functional_triggers pft
      WHERE   pfu.legislation_code   IN (cp_leg,'-1')
      AND     pfu.area_id          = pfa.area_id
      AND     pfa.area_id          = pft.area_id
      AND     pft.event_id         = cp_id;
    --
    CURSOR csr_bus_enb(
      cp_id   IN NUMBER,
      cp_bus  IN NUMBER
    ) IS
      SELECT  'Y'
      FROM    pay_functional_usages   pfu,
              pay_functional_areas    pfa,
              pay_functional_triggers pft
      WHERE   pfu.business_group_id   IN (cp_bus,-1)
      AND     pfu.area_id           = pfa.area_id
      AND     pfa.area_id           = pft.area_id
      AND     pft.event_id          = cp_id;
    --
    CURSOR csr_pay_enb(
      cp_id   IN NUMBER,
      cp_pay  IN VARCHAR2
    ) IS
      SELECT  'Y'
      FROM    pay_functional_usages   pfu,
              pay_functional_areas    pfa,
              pay_functional_triggers pft
      WHERE   pfu.payroll_id   IN (cp_pay,-1)
      AND     pfu.area_id    = pfa.area_id
      AND     pfa.area_id    = pft.area_id
      AND     pft.event_id   = cp_id;
    --
    l_execute BOOLEAN;
    l_exists  VARCHAR2(1);
    --
  BEGIN
    --
    -- If the trigger is not in any functional area then execute the code
    --
    OPEN csr_in_area(p_event_id);
    FETCH csr_in_area INTO l_exists;
    IF csr_in_area%NOTFOUND THEN
      l_exists := 'N';
    END IF;
    CLOSE csr_in_area;
    IF l_exists = 'N' THEN
      hr_utility.trace('Trigger not in any area, execute code');
      l_execute := TRUE;
    ELSE
      --
      -- Otherwise do not execute the trigger code by default
      --
      l_execute := FALSE;
      --
      -- If the trigger is firing for a specific legislation and belongs to a functional
      -- area that is enabled for all legislations or the current specific legislation
      -- then the code should be executed
      --
      IF p_legislation_code IS NOT NULL THEN
        OPEN csr_leg_enb(p_event_id,p_legislation_code);
        FETCH csr_leg_enb INTO l_exists;
        IF csr_leg_enb%NOTFOUND THEN
          l_exists := 'N';
        END IF;
        CLOSE csr_leg_enb;
        IF l_exists = 'Y' THEN
          hr_utility.trace('Trigger enabled by legislation, execute code');
          l_execute := TRUE;
        END IF;
      END IF;
      --
      -- If we have not already decided to execute the trigger code and
      -- the trigger is firing for a specific business group and belongs to a functional
      -- area that is enabled for all business groups or the current specific business group
      -- then the code should be executed
      --
      IF l_execute = FALSE AND p_business_group_id IS NOT NULL THEN
        OPEN csr_bus_enb(p_event_id,p_business_group_id);
        FETCH csr_bus_enb INTO l_exists;
        IF csr_bus_enb%NOTFOUND THEN
          l_exists := 'N';
        END IF;
        CLOSE csr_bus_enb;
        IF l_exists = 'Y' THEN
          hr_utility.trace('Trigger enabled by business group, execute code');
          l_execute := TRUE;
        END IF;
      END IF;
      --
      -- If we have not already decided to execute the trigger code and
      -- the trigger is firing for a specific payroll and belongs to a functional
      -- area that is enabled for all payrolls or the current specific payroll
      -- then the code should be executed
      --
      IF l_execute = FALSE AND p_payroll_id IS NOT NULL THEN
        OPEN csr_pay_enb(p_event_id,p_payroll_id);
        FETCH csr_pay_enb INTO l_exists;
        IF csr_pay_enb%NOTFOUND THEN
          l_exists := 'N';
        END IF;
        CLOSE csr_pay_enb;
        IF l_exists = 'Y' THEN
          hr_utility.trace('Trigger enabled by payroll, execute code');
          l_execute := TRUE;
        END IF;
      END IF;
      --
    END IF;
    --
    -- Logic works out if trigger _SHOULD_ execute, so reverse it before returning
    --
    RETURN (l_execute = FALSE);
    --
  END trigger_is_not_enabled;
--
END paywsfgt_pkg;

/
