--------------------------------------------------------
--  DDL for Package Body HR_PAY_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAY_INTERFACE_PKG" AS
/* $Header: pegpipkg.pkb 120.6 2006/01/04 06:24:05 sgelvi noship $ */
--
--  OAB Benefit view functionality
--
--  non split globals
  g_eepyc_rec hr_pay_interface_oab_value_v%ROWTYPE;
  g_erpyc_rec hr_pay_interface_oab_value_v%ROWTYPE;
  g_prtt_enrt_rslt_id ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE;
  TYPE g_coverage_type_typ IS TABLE OF ben_opt_f.name%TYPE INDEX BY BINARY_INTEGER;
  g_coverage_type_tab g_coverage_type_typ;
--
--  split view globals
  g_split_eepyc_rec hr_pay_interface_oab_value1_v%ROWTYPE;
  g_split_erpyc_rec hr_pay_interface_oab_value2_v%ROWTYPE;
  g_split_prtt_enrt_rslt_id ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE;
--
--  Procedures/functions for the non-split oab view
--
--
 FUNCTION GET_COVERAGE_TYPE(P_OIPL_ID IN NUMBER) RETURN VARCHAR2 AS
    l_name ben_opt_f.name%TYPE;
    -- define the cursor
    CURSOR CSR1 IS SELECT opt.name /*coverage_type*/
    FROM   ben_opt_f opt,
           ben_oipl_f cop
    WHERE  opt.opt_id = cop.opt_id
    AND    cop.oipl_id = P_OIPL_ID
    AND    cop.effective_start_date =
          (SELECT max(cop1.effective_start_date)
           FROM   ben_oipl_f cop1
           WHERE  cop1.oipl_id = cop.oipl_id
           AND    cop1.effective_start_date <= hr_pay_interface_pkg.get_extract_date)
    AND    opt.effective_start_date =
          (SELECT max(opt1.effective_start_date)
           FROM   ben_opt_f opt1
           WHERE  opt1.opt_id = opt.opt_id
           AND    opt1.effective_start_date <= hr_pay_interface_pkg.get_extract_date);
  BEGIN
    -- check to see if a P_OIPL_ID exists if not short circuit out returning NULL
    IF P_OIPL_ID IS NULL THEN
      RETURN(NULL);
    END IF;
    -- check to see if the OIPL_ID has already been cached
    BEGIN
      RETURN(g_coverage_type_tab(P_OIPL_ID));
    EXCEPTION
      WHEN OTHERS THEN
        -- not found so select it
        OPEN CSR1;
        FETCH CSR1 INTO l_name;
        IF CSR1%NOTFOUND THEN
          -- not found close cursor and return NULL
          CLOSE CSR1;
          RETURN(NULL);
        END IF;
        CLOSE CSR1;
        -- found so place in cache and return
        g_coverage_type_tab(P_OIPL_ID) := l_name;
        RETURN(l_name);
    END;
  EXCEPTION
    WHEN OTHERS THEN
      -- unexpected error so ensure no cursors are OPEN and return NULL
      IF CSR1%ISOPEN THEN
        CLOSE CSR1;
      END IF;
      RETURN(NULL);
  END GET_COVERAGE_TYPE;
--
PROCEDURE select_rec(p_prtt_enrt_rslt_id IN
                     ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
                     p_effective_start_date IN DATE,
                     p_effective_end_date IN DATE) IS
  CURSOR csr_pay_interface_oab_value_v(c_acty_typ_cd
                                       ben_prtt_rt_val.acty_typ_cd%TYPE) IS
    SELECT pi.*
    FROM   hr_pay_interface_oab_value_v pi
    WHERE  pi.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    AND    pi.acty_typ_cd = c_acty_typ_cd
    AND    pi.rt_strt_dt <= hr_ceridian.get_cer_extract_date;
BEGIN
  -- set the g_prtt_enrt_rslt_id global
  g_prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
  -- get the eepyc record
  OPEN csr_pay_interface_oab_value_v('EEPYC');
  FETCH csr_pay_interface_oab_value_v INTO g_eepyc_rec;
  IF csr_pay_interface_oab_value_v%NOTFOUND THEN
    -- null record as it was not found
    g_eepyc_rec.prtt_enrt_rslt_id := NULL;
  END IF;
  CLOSE csr_pay_interface_oab_value_v;
  -- get the erpyc record
  OPEN csr_pay_interface_oab_value_v('ERPYC');
  FETCH csr_pay_interface_oab_value_v INTO g_erpyc_rec;
  IF csr_pay_interface_oab_value_v%NOTFOUND THEN
    -- null record as it was not found
    g_erpyc_rec.prtt_enrt_rslt_id := NULL;
  END IF;
  CLOSE csr_pay_interface_oab_value_v;
EXCEPTION
  WHEN OTHERS THEN
    -- unexpected error, close cursor if open and set
    -- both eepyc and erpyc records to null
    IF csr_pay_interface_oab_value_v%ISOPEN THEN
      CLOSE csr_pay_interface_oab_value_v;
    END IF;
    -- null both records
    g_eepyc_rec.prtt_enrt_rslt_id := NULL;
    g_erpyc_rec.prtt_enrt_rslt_id := NULL;
END select_rec;
--
FUNCTION eepyc_erpyc_exist
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
         p_effective_start_date IN DATE,
         p_effective_end_date   IN DATE) RETURN VARCHAR2 IS
--
  CURSOR csr_pay_interface_oab_value_v IS
    SELECT 1
    FROM   hr_pay_interface_oab_value_v pi
    WHERE  pi.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    AND    pi.acty_typ_cd IN ('EEPYC','ERPYC')
    AND    pi.rt_strt_dt <= hr_ceridian.get_cer_extract_date;
--
 l_dummy NUMBER(1);
--
BEGIN
  OPEN csr_pay_interface_oab_value_v;
  FETCH csr_pay_interface_oab_value_v INTO l_dummy;
  IF csr_pay_interface_oab_value_v%NOTFOUND THEN
    CLOSE csr_pay_interface_oab_value_v;
    RETURN('N');
  END IF;
  CLOSE csr_pay_interface_oab_value_v;
  -- if we have got this far then at least 1 row was found
  RETURN('Y');
EXCEPTION
  WHEN OTHERS THEN
    -- unexpected error
    IF csr_pay_interface_oab_value_v%ISOPEN THEN
      CLOSE csr_pay_interface_oab_value_v;
    END IF;
    RETURN('N');
END eepyc_erpyc_exist;
--
FUNCTION get_eepyc_varchar2
           (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN VARCHAR2 IS
  --
  l_column_name VARCHAR2(30) := p_column_name;
  --
BEGIN
  IF p_prtt_enrt_rslt_id IS NULL THEN
    RETURN(NULL);
  END IF;
  -- is the current record in the cache?
  IF (p_prtt_enrt_rslt_id <> g_prtt_enrt_rslt_id) OR
     (g_prtt_enrt_rslt_id IS NULL) THEN
    -- row is NOT cached so select information
    select_rec(p_prtt_enrt_rslt_id,p_effective_start_date,p_effective_end_date);
  END IF;
  -- has the eepyc record been populated?
  IF g_eepyc_rec.prtt_enrt_rslt_id IS NULL THEN
    -- no row was found so return NULL
    RETURN(NULL);
  ELSE
    -- return the varchar2 column required
    IF    l_column_name = 'CONTRIBUTION_AMOUNT' THEN
      RETURN(g_eepyc_rec.CONTRIBUTION_AMOUNT);
    ELSIF l_column_name = 'ACTY_TYP_CD' THEN
      RETURN(g_eepyc_rec.ACTY_TYP_CD);
    ELSIF l_column_name = 'ASSIGNMENT_NUMBER' THEN
      RETURN(g_eepyc_rec.ASSIGNMENT_NUMBER);
    ELSIF l_column_name = 'RATE_PERIOD' THEN
      RETURN(g_eepyc_rec.RATE_PERIOD);
    ELSIF l_column_name = 'RT_TYP_CD' THEN
      RETURN(g_eepyc_rec.RT_TYP_CD);
    ELSE
      -- column unknown
      RETURN(NULL);
    END IF;
  END IF;
END get_eepyc_varchar2;
--
FUNCTION get_eepyc_number
           (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN NUMBER IS
  --
  l_column_name VARCHAR2(30) := p_column_name;
  --
BEGIN
  IF p_prtt_enrt_rslt_id IS NULL THEN
    RETURN(NULL);
  END IF;
  -- is the current record in the cache?
  IF (p_prtt_enrt_rslt_id <> g_prtt_enrt_rslt_id) OR
     (g_prtt_enrt_rslt_id IS NULL) THEN
    -- row is NOT cached so select information
    select_rec(p_prtt_enrt_rslt_id,p_effective_start_date,p_effective_end_date);
  END IF;
  -- has the eepyc record been populated?
  IF g_eepyc_rec.prtt_enrt_rslt_id IS NULL THEN
    -- no row was found so return NULL
    RETURN(NULL);
  ELSE
    -- return the varchar2 column required
    IF    l_column_name = 'ASSIGNMENT_ID' THEN
      RETURN(g_eepyc_rec.ASSIGNMENT_ID);
    ELSIF l_column_name = 'RATE_AMOUNT' THEN
      RETURN(g_eepyc_rec.RATE_AMOUNT);
    ELSIF l_column_name = 'MAX_ANNUAL_AMOUNT' THEN
      RETURN(g_eepyc_rec.MAX_ANNUAL_AMOUNT);
    ELSIF l_column_name = 'PRTT_ENRT_RSLT_ID' THEN
      RETURN(g_eepyc_rec.PRTT_ENRT_RSLT_ID);
    ELSIF l_column_name = 'PRTT_RT_VAL_ID' THEN
      RETURN(g_eepyc_rec.PRTT_RT_VAL_ID);
    ELSIF l_column_name = 'ELEMENT_ENTRY_VALUE_ID' THEN
      RETURN(g_eepyc_rec.ELEMENT_ENTRY_VALUE_ID);
    ELSIF l_column_name = 'PERSON_ID' THEN
      RETURN(g_eepyc_rec.PERSON_ID);
    ELSIF l_column_name = 'PER_IN_LER_ID' THEN
      RETURN(g_eepyc_rec.PER_IN_LER_ID);
    ELSE
      -- column unknown
      RETURN(NULL);
    END IF;
  END IF;
END get_eepyc_number;
--
FUNCTION get_eepyc_date
           (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN DATE IS
  --
  l_column_name VARCHAR2(30) := p_column_name;
  --
BEGIN
  IF p_prtt_enrt_rslt_id IS NULL THEN
    RETURN(NULL);
  END IF;
  -- is the current record in the cache?
  IF (p_prtt_enrt_rslt_id <> g_prtt_enrt_rslt_id) OR
     (g_prtt_enrt_rslt_id IS NULL) THEN
    -- row is NOT cached so select information
    select_rec(p_prtt_enrt_rslt_id,p_effective_start_date,p_effective_end_date);
  END IF;
  -- has the eepyc record been populated?
  IF g_eepyc_rec.prtt_enrt_rslt_id IS NULL THEN
    -- no row was found so return NULL
    RETURN(NULL);
  ELSE
    -- return the varchar2 column required
    IF    l_column_name = 'EFFECTIVE_START_DATE' THEN
      RETURN(g_eepyc_rec.EFFECTIVE_START_DATE);
    ELSIF l_column_name = 'EFFECTIVE_END_DATE' THEN
      RETURN(g_eepyc_rec.EFFECTIVE_END_DATE);
    ELSIF l_column_name = 'RT_STRT_DT' THEN
      RETURN(g_eepyc_rec.RT_STRT_DT);
    ELSIF l_column_name = 'RT_END_DT' THEN
      RETURN(g_eepyc_rec.RT_END_DT);
    ELSIF l_column_name = 'MIN_RT_STRT_DT' THEN
      RETURN(g_eepyc_rec.MIN_RT_STRT_DT);
    ELSIF l_column_name = 'MAX_RT_END_DT' THEN
      RETURN(g_eepyc_rec.MAX_RT_END_DT);
    ELSIF l_column_name = 'ELEMENT_ENTRY_ESD' THEN
      RETURN(g_eepyc_rec.ELEMENT_ENTRY_ESD);
    ELSIF l_column_name = 'ELEMENT_ENTRY_EED' THEN
      RETURN(g_eepyc_rec.ELEMENT_ENTRY_EED);
    ELSIF l_column_name = 'OABV_LAST_UPDATE_DATE' THEN
      RETURN(g_eepyc_rec.OABV_LAST_UPDATE_DATE);
    ELSE
      -- column unknown
      RETURN(NULL);
    END IF;
  END IF;
END get_eepyc_date;
--
FUNCTION get_erpyc_varchar2
           (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN VARCHAR2 IS
  --
  l_column_name VARCHAR2(30) := p_column_name;
  --
BEGIN
  IF p_prtt_enrt_rslt_id IS NULL THEN
    RETURN(NULL);
  END IF;
  -- is the current record in the cache?
  IF (p_prtt_enrt_rslt_id <> g_prtt_enrt_rslt_id) OR
     (g_prtt_enrt_rslt_id IS NULL) THEN
    -- row is NOT cached so select information
    select_rec(p_prtt_enrt_rslt_id,p_effective_start_date,p_effective_end_date);
  END IF;
  -- has the erpyc record been populated?
  IF g_erpyc_rec.prtt_enrt_rslt_id IS NULL THEN
    -- no row was found so return NULL
    RETURN(NULL);
  ELSE
    -- return the varchar2 column required
    IF    l_column_name = 'CONTRIBUTION_AMOUNT' THEN
      RETURN(g_erpyc_rec.CONTRIBUTION_AMOUNT);
    ELSIF l_column_name = 'ACTY_TYP_CD' THEN
      RETURN(g_erpyc_rec.ACTY_TYP_CD);
    ELSIF l_column_name = 'ASSIGNMENT_NUMBER' THEN
      RETURN(g_erpyc_rec.ASSIGNMENT_NUMBER);
    ELSIF l_column_name = 'RATE_PERIOD' THEN
      RETURN(g_erpyc_rec.RATE_PERIOD);
    ELSIF l_column_name = 'RT_TYP_CD' THEN
      RETURN(g_erpyc_rec.RT_TYP_CD);
    ELSE
      -- column unknown
      RETURN(NULL);
    END IF;
  END IF;
END get_erpyc_varchar2;
--
FUNCTION get_erpyc_number
           (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN NUMBER IS
  --
  l_column_name VARCHAR2(30) := p_column_name;
  --
BEGIN
  IF p_prtt_enrt_rslt_id IS NULL THEN
    RETURN(NULL);
  END IF;
  -- is the current record in the cache?
  IF (p_prtt_enrt_rslt_id <> g_prtt_enrt_rslt_id) OR
     (g_prtt_enrt_rslt_id IS NULL) THEN
    -- row is NOT cached so select information
    select_rec(p_prtt_enrt_rslt_id,p_effective_start_date,p_effective_end_date);
  END IF;
  -- has the erpyc record been populated?
  IF g_erpyc_rec.prtt_enrt_rslt_id IS NULL THEN
    -- no row was found so return NULL
    RETURN(NULL);
  ELSE
    -- return the varchar2 column required
    IF    l_column_name = 'ASSIGNMENT_ID' THEN
      RETURN(g_erpyc_rec.ASSIGNMENT_ID);
    ELSIF l_column_name = 'RATE_AMOUNT' THEN
      RETURN(g_erpyc_rec.RATE_AMOUNT);
    ELSIF l_column_name = 'MAX_ANNUAL_AMOUNT' THEN
      RETURN(g_erpyc_rec.MAX_ANNUAL_AMOUNT);
    ELSIF l_column_name = 'PRTT_ENRT_RSLT_ID' THEN
      RETURN(g_erpyc_rec.PRTT_ENRT_RSLT_ID);
    ELSIF l_column_name = 'PRTT_RT_VAL_ID' THEN
      RETURN(g_erpyc_rec.PRTT_RT_VAL_ID);
    ELSIF l_column_name = 'ELEMENT_ENTRY_VALUE_ID' THEN
      RETURN(g_erpyc_rec.ELEMENT_ENTRY_VALUE_ID);
    ELSIF l_column_name = 'PERSON_ID' THEN
      RETURN(g_erpyc_rec.PERSON_ID);
    ELSIF l_column_name = 'PER_IN_LER_ID' THEN
      RETURN(g_erpyc_rec.PER_IN_LER_ID);
    ELSE
      -- column unknown
      RETURN(NULL);
    END IF;
  END IF;
END get_erpyc_number;
--
FUNCTION get_erpyc_date
           (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN DATE IS
  --
  l_column_name VARCHAR2(30) := p_column_name;
  --
BEGIN
  IF p_prtt_enrt_rslt_id IS NULL THEN
    RETURN(NULL);
  END IF;
  -- is the current record in the cache?
  IF (p_prtt_enrt_rslt_id <> g_prtt_enrt_rslt_id) OR
     (g_prtt_enrt_rslt_id IS NULL) THEN
    -- row is NOT cached so select information
    select_rec(p_prtt_enrt_rslt_id,p_effective_start_date,p_effective_end_date);
  END IF;
  -- has the erpyc record been populated?
  IF g_erpyc_rec.prtt_enrt_rslt_id IS NULL THEN
    -- no row was found so return NULL
    RETURN(NULL);
  ELSE
    -- return the varchar2 column required
    IF    l_column_name = 'EFFECTIVE_START_DATE' THEN
      RETURN(g_erpyc_rec.EFFECTIVE_START_DATE);
    ELSIF l_column_name = 'EFFECTIVE_END_DATE' THEN
      RETURN(g_erpyc_rec.EFFECTIVE_END_DATE);
    ELSIF l_column_name = 'RT_STRT_DT' THEN
      RETURN(g_erpyc_rec.RT_STRT_DT);
    ELSIF l_column_name = 'RT_END_DT' THEN
      RETURN(g_erpyc_rec.RT_END_DT);
    ELSIF l_column_name = 'MIN_RT_STRT_DT' THEN
      RETURN(g_erpyc_rec.MIN_RT_STRT_DT);
    ELSIF l_column_name = 'MAX_RT_END_DT' THEN
      RETURN(g_erpyc_rec.MAX_RT_END_DT);
    ELSIF l_column_name = 'ELEMENT_ENTRY_ESD' THEN
      RETURN(g_erpyc_rec.ELEMENT_ENTRY_ESD);
    ELSIF l_column_name = 'ELEMENT_ENTRY_EED' THEN
      RETURN(g_erpyc_rec.ELEMENT_ENTRY_EED);
    ELSIF l_column_name = 'OABV_LAST_UPDATE_DATE' THEN
      RETURN(g_erpyc_rec.OABV_LAST_UPDATE_DATE);
    ELSE
      -- column unknown
      RETURN(NULL);
    END IF;
  END IF;
END get_erpyc_date;
--
--  Procedure/Function for split views
--
PROCEDURE select_split_eepyc_rec(p_prtt_enrt_rslt_id    IN
                     ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
                     p_effective_start_date IN DATE,
                     p_effective_end_date   IN DATE) IS
  CURSOR csr_pay_interface_oab_value_v IS
    SELECT pi.*
    FROM   hr_pay_interface_oab_value1_v pi
    WHERE  pi.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    AND    pi.acty_typ_cd = 'EEPYC'
    AND    pi.rt_strt_dt <= hr_ceridian.get_cer_extract_date;
BEGIN
  -- set the g_split_prtt_enrt_rslt_id global
  g_split_prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
  g_prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
    --get the eepyc record
  OPEN csr_pay_interface_oab_value_v;
  FETCH csr_pay_interface_oab_value_v INTO g_split_eepyc_rec;

  IF csr_pay_interface_oab_value_v%NOTFOUND THEN
    -- null record as it was not found
    g_split_eepyc_rec.prtt_enrt_rslt_id := NULL;
  END IF;
  CLOSE csr_pay_interface_oab_value_v;
EXCEPTION
  WHEN OTHERS THEN
    -- unexpected error, close cursor if open and set
    -- eepyc record to null
    IF csr_pay_interface_oab_value_v%ISOPEN THEN
      CLOSE csr_pay_interface_oab_value_v;
    END IF;
    -- null eepyc record
    g_split_eepyc_rec.prtt_enrt_rslt_id := NULL;
END select_split_eepyc_rec;
--
PROCEDURE select_split_erpyc_rec(p_prtt_enrt_rslt_id
                       IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
                     p_effective_start_date IN DATE,
                     p_effective_end_date   IN DATE) IS
  CURSOR csr_pay_interface_oab_value_v IS
    SELECT pi.*
    FROM   hr_pay_interface_oab_value2_v pi
    WHERE  pi.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    AND    pi.acty_typ_cd = 'ERPYC'
    AND    pi.rt_strt_dt <= hr_ceridian.get_cer_extract_date;
BEGIN
  -- set the g_split_prtt_enrt_rslt_id global
  g_split_prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
  g_prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
  --get the erpyc record
  OPEN csr_pay_interface_oab_value_v;
  FETCH csr_pay_interface_oab_value_v INTO g_split_erpyc_rec;
  IF csr_pay_interface_oab_value_v%NOTFOUND THEN
    -- null record as it was not found
    g_split_erpyc_rec.prtt_enrt_rslt_id := NULL;
  END IF;
  CLOSE csr_pay_interface_oab_value_v;
EXCEPTION
  WHEN OTHERS THEN
    -- unexpected error, close cursor if open and set
    -- erpyc record to null
    IF csr_pay_interface_oab_value_v%ISOPEN THEN
      CLOSE csr_pay_interface_oab_value_v;
    END IF;
    -- null erpyc record
    g_split_erpyc_rec.prtt_enrt_rslt_id := NULL;
END select_split_erpyc_rec;
--
FUNCTION split_eepyc_exist
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
         p_effective_start_date IN DATE,
         p_effective_end_date   IN DATE) RETURN VARCHAR2 IS
--
  CURSOR csr_pay_interface_oab_value_v IS
    SELECT 1
    FROM   hr_pay_interface_oab_value1_v pi
    WHERE  pi.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    AND    pi.acty_typ_cd = 'EEPYC'
    AND    pi.rt_strt_dt <= hr_ceridian.get_cer_extract_date;
--
 l_dummy NUMBER(1);
--
BEGIN
  OPEN csr_pay_interface_oab_value_v;
  FETCH csr_pay_interface_oab_value_v INTO l_dummy;
  IF csr_pay_interface_oab_value_v%NOTFOUND THEN
    CLOSE csr_pay_interface_oab_value_v;
    RETURN('N');
  END IF;
  CLOSE csr_pay_interface_oab_value_v;
  -- if we have got this far then at least 1 row was found
  RETURN('Y');
EXCEPTION
  WHEN OTHERS THEN
    -- unexpected error
    IF csr_pay_interface_oab_value_v%ISOPEN THEN
      CLOSE csr_pay_interface_oab_value_v;
    END IF;
    RETURN('N');
END split_eepyc_exist;
--
FUNCTION split_erpyc_exist
        (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
         p_effective_start_date IN DATE,
         p_effective_end_date   IN DATE) RETURN VARCHAR2 IS
--
  CURSOR csr_pay_interface_oab_value_v IS
    SELECT 1
    FROM   hr_pay_interface_oab_value2_v pi
    WHERE  pi.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    AND    pi.acty_typ_cd = 'ERPYC'
    AND    pi.rt_strt_dt <= hr_ceridian.get_cer_extract_date;
--
 l_dummy NUMBER(1);
--
BEGIN
  OPEN csr_pay_interface_oab_value_v;
  FETCH csr_pay_interface_oab_value_v INTO l_dummy;
  IF csr_pay_interface_oab_value_v%NOTFOUND THEN
    CLOSE csr_pay_interface_oab_value_v;
    RETURN('N');
  END IF;
  CLOSE csr_pay_interface_oab_value_v;
  -- if we have got this far then at least 1 row was found
  RETURN('Y');
EXCEPTION
  WHEN OTHERS THEN
    -- unexpected error
    IF csr_pay_interface_oab_value_v%ISOPEN THEN
      CLOSE csr_pay_interface_oab_value_v;
    END IF;
    RETURN('N');
END split_erpyc_exist;
--
FUNCTION get_split_eepyc_varchar2
           (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN VARCHAR2 IS
  --
  l_column_name VARCHAR2(30) := p_column_name;
  --
BEGIN
  IF p_prtt_enrt_rslt_id IS NULL THEN
    RETURN(NULL);
  END IF;
  -- is the current record in the cache?
  IF (p_prtt_enrt_rslt_id <> g_split_prtt_enrt_rslt_id) OR
     (g_prtt_enrt_rslt_id IS NULL) THEN
    -- row is NOT cached so select information
    select_split_eepyc_rec(p_prtt_enrt_rslt_id,p_effective_start_date,p_effective_end_date);
  END IF;
  -- has the eepyc record been populated?
  IF g_split_eepyc_rec.prtt_enrt_rslt_id IS NULL THEN
    -- no row was found so return NULL
    RETURN(NULL);
  ELSE
    -- return the varchar2 column required
    IF    l_column_name = 'CONTRIBUTION_AMOUNT' THEN
      RETURN(g_split_eepyc_rec.CONTRIBUTION_AMOUNT);
    ELSIF l_column_name = 'ACTY_TYP_CD' THEN
      RETURN(g_split_eepyc_rec.ACTY_TYP_CD);
    ELSIF l_column_name = 'ASSIGNMENT_NUMBER' THEN
      RETURN(g_split_eepyc_rec.ASSIGNMENT_NUMBER);
    ELSIF l_column_name = 'RATE_PERIOD' THEN
      RETURN(g_split_eepyc_rec.RATE_PERIOD);
    ELSIF l_column_name = 'RT_TYP_CD' THEN
      RETURN(g_split_eepyc_rec.RT_TYP_CD);
    ELSE
      -- column unknown
      RETURN(NULL);
    END IF;
  END IF;
END get_split_eepyc_varchar2;
--
FUNCTION get_split_eepyc_number
           (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN NUMBER IS
  --
  l_column_name VARCHAR2(30) := p_column_name;
  --
BEGIN
  IF p_prtt_enrt_rslt_id IS NULL THEN
    RETURN(NULL);
  END IF;
  -- is the current record in the cache?
  IF (p_prtt_enrt_rslt_id <> g_split_prtt_enrt_rslt_id) OR
     (g_prtt_enrt_rslt_id IS NULL) THEN
    -- row is NOT cached so select information
    select_split_eepyc_rec(p_prtt_enrt_rslt_id,p_effective_start_date,p_effective_end_date);
  END IF;
  -- has the eepyc record been populated?
  IF g_split_eepyc_rec.prtt_enrt_rslt_id IS NULL THEN
    -- no row was found so return NULL
    RETURN(NULL);
  ELSE
    -- return the varchar2 column required
    IF    l_column_name = 'ASSIGNMENT_ID' THEN
      RETURN(g_split_eepyc_rec.ASSIGNMENT_ID);
    ELSIF l_column_name = 'RATE_AMOUNT' THEN
      RETURN(g_split_eepyc_rec.RATE_AMOUNT);
    ELSIF l_column_name = 'MAX_ANNUAL_AMOUNT' THEN
      RETURN(g_split_eepyc_rec.MAX_ANNUAL_AMOUNT);
    ELSIF l_column_name = 'PRTT_ENRT_RSLT_ID' THEN
      RETURN(g_split_eepyc_rec.PRTT_ENRT_RSLT_ID);
    ELSIF l_column_name = 'PRTT_RT_VAL_ID' THEN
      RETURN(g_split_eepyc_rec.PRTT_RT_VAL_ID);
    ELSIF l_column_name = 'ELEMENT_ENTRY_VALUE_ID' THEN
      RETURN(g_split_eepyc_rec.ELEMENT_ENTRY_VALUE_ID);
    ELSIF l_column_name = 'PERSON_ID' THEN
      RETURN(g_split_eepyc_rec.PERSON_ID);
    ELSIF l_column_name = 'PER_IN_LER_ID' THEN
      RETURN(g_split_eepyc_rec.PER_IN_LER_ID);
    ELSE
      -- column unknown
      RETURN(NULL);
    END IF;
  END IF;
END get_split_eepyc_number;
--
FUNCTION get_split_eepyc_date
           (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN DATE IS
  --
  l_column_name VARCHAR2(30) := p_column_name;
  --
BEGIN
  IF p_prtt_enrt_rslt_id IS NULL THEN
    RETURN(NULL);
  END IF;
  -- is the current record in the cache?
  IF (p_prtt_enrt_rslt_id <> g_split_prtt_enrt_rslt_id) OR
     (g_prtt_enrt_rslt_id IS NULL) THEN
    -- row is NOT cached so select information
    select_split_eepyc_rec(p_prtt_enrt_rslt_id,p_effective_start_date,p_effective_end_date);
  END IF;
  -- has the eepyc record been populated?
  IF g_split_eepyc_rec.prtt_enrt_rslt_id IS NULL THEN
    -- no row was found so return NULL
    RETURN(NULL);
  ELSE
    -- return the varchar2 column required
    IF    l_column_name = 'EFFECTIVE_START_DATE' THEN
      RETURN(g_split_eepyc_rec.EFFECTIVE_START_DATE);
    ELSIF l_column_name = 'EFFECTIVE_END_DATE' THEN
      RETURN(g_split_eepyc_rec.EFFECTIVE_END_DATE);
    ELSIF l_column_name = 'RT_STRT_DT' THEN
      RETURN(g_split_eepyc_rec.RT_STRT_DT);
    ELSIF l_column_name = 'RT_END_DT' THEN
      RETURN(g_split_eepyc_rec.RT_END_DT);
    ELSIF l_column_name = 'MIN_RT_STRT_DT' THEN
      RETURN(g_split_eepyc_rec.MIN_RT_STRT_DT);
    ELSIF l_column_name = 'MAX_RT_END_DT' THEN
      RETURN(g_split_eepyc_rec.MAX_RT_END_DT);
    ELSIF l_column_name = 'ELEMENT_ENTRY_ESD' THEN
      RETURN(g_split_eepyc_rec.ELEMENT_ENTRY_ESD);
    ELSIF l_column_name = 'ELEMENT_ENTRY_EED' THEN
      RETURN(g_split_eepyc_rec.ELEMENT_ENTRY_EED);
    ELSIF l_column_name = 'OABV_LAST_UPDATE_DATE' THEN
      RETURN(g_split_eepyc_rec.OABV_LAST_UPDATE_DATE);
    ELSE
      -- column unknown
      RETURN(NULL);
    END IF;
  END IF;
END get_split_eepyc_date;
--
FUNCTION get_split_erpyc_varchar2
           (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN VARCHAR2 IS
  --
  l_column_name VARCHAR2(30) := p_column_name;
  --
BEGIN
  IF p_prtt_enrt_rslt_id IS NULL THEN
    RETURN(NULL);
  END IF;
  -- is the current record in the cache?
  IF (p_prtt_enrt_rslt_id <> g_split_prtt_enrt_rslt_id) OR
     (g_prtt_enrt_rslt_id IS NULL) THEN
    -- row is NOT cached so select information
    select_split_erpyc_rec(p_prtt_enrt_rslt_id,p_effective_start_date,p_effective_end_date);
  END IF;
  -- has the erpyc record been populated?
  IF g_split_erpyc_rec.prtt_enrt_rslt_id IS NULL THEN
    -- no row was found so return NULL
    RETURN(NULL);
  ELSE
    -- return the varchar2 column required
    IF    l_column_name = 'CONTRIBUTION_AMOUNT' THEN
      RETURN(g_split_erpyc_rec.CONTRIBUTION_AMOUNT);
    ELSIF l_column_name = 'ACTY_TYP_CD' THEN
      RETURN(g_split_erpyc_rec.ACTY_TYP_CD);
    ELSIF l_column_name = 'ASSIGNMENT_NUMBER' THEN
      RETURN(g_split_erpyc_rec.ASSIGNMENT_NUMBER);
    ELSIF l_column_name = 'RATE_PERIOD' THEN
      RETURN(g_split_erpyc_rec.RATE_PERIOD);
    ELSIF l_column_name = 'RT_TYP_CD' THEN
      RETURN(g_split_erpyc_rec.RT_TYP_CD);
    ELSE
      -- column unknown
      RETURN(NULL);
    END IF;
  END IF;
END get_split_erpyc_varchar2;
--
FUNCTION get_split_erpyc_number
           (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN NUMBER IS
  --
  l_column_name VARCHAR2(30) := p_column_name;
  --
BEGIN
  IF p_prtt_enrt_rslt_id IS NULL THEN
    RETURN(NULL);
  END IF;
  -- is the current record in the cache?
  IF (p_prtt_enrt_rslt_id <> g_split_prtt_enrt_rslt_id) OR
     (g_prtt_enrt_rslt_id IS NULL) THEN
    -- row is NOT cached so select information
    select_split_erpyc_rec(p_prtt_enrt_rslt_id,p_effective_start_date,p_effective_end_date);
  END IF;
  -- has the erpyc record been populated?
  IF g_split_erpyc_rec.prtt_enrt_rslt_id IS NULL THEN
    -- no row was found so return NULL
    RETURN(NULL);
  ELSE
    -- return the varchar2 column required
    IF    l_column_name = 'ASSIGNMENT_ID' THEN
      RETURN(g_split_erpyc_rec.ASSIGNMENT_ID);
    ELSIF l_column_name = 'RATE_AMOUNT' THEN
      RETURN(g_split_erpyc_rec.RATE_AMOUNT);
    ELSIF l_column_name = 'MAX_ANNUAL_AMOUNT' THEN
      RETURN(g_split_erpyc_rec.MAX_ANNUAL_AMOUNT);
    ELSIF l_column_name = 'PRTT_ENRT_RSLT_ID' THEN
      RETURN(g_split_erpyc_rec.PRTT_ENRT_RSLT_ID);
    ELSIF l_column_name = 'PRTT_RT_VAL_ID' THEN
      RETURN(g_split_erpyc_rec.PRTT_RT_VAL_ID);
    ELSIF l_column_name = 'ELEMENT_ENTRY_VALUE_ID' THEN
      RETURN(g_split_erpyc_rec.ELEMENT_ENTRY_VALUE_ID);
    ELSIF l_column_name = 'PERSON_ID' THEN
      RETURN(g_split_erpyc_rec.PERSON_ID);
    ELSIF l_column_name = 'PER_IN_LER_ID' THEN
      RETURN(g_split_erpyc_rec.PER_IN_LER_ID);
    ELSE
      -- column unknown
      RETURN(NULL);
    END IF;
  END IF;
END get_split_erpyc_number;
--
FUNCTION get_split_erpyc_date
           (p_prtt_enrt_rslt_id    IN ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE,
            p_column_name          IN VARCHAR2,
            p_effective_start_date IN DATE,
            p_effective_end_date   IN DATE) RETURN DATE IS
  --
  l_column_name VARCHAR2(30) := p_column_name;
  --
BEGIN
  IF p_prtt_enrt_rslt_id IS NULL THEN
    RETURN(NULL);
  END IF;
  -- is the current record in the cache?
  IF (p_prtt_enrt_rslt_id <> g_split_prtt_enrt_rslt_id) OR
     (g_prtt_enrt_rslt_id IS NULL) THEN
    -- row is NOT cached so select information
    select_split_erpyc_rec(p_prtt_enrt_rslt_id,p_effective_start_date,p_effective_end_date);
  END IF;
  -- has the erpyc record been populated?
  IF g_split_erpyc_rec.prtt_enrt_rslt_id IS NULL THEN
    -- no row was found so return NULL
    RETURN(NULL);
  ELSE
    -- return the varchar2 column required
    IF    l_column_name = 'EFFECTIVE_START_DATE' THEN
      RETURN(g_split_erpyc_rec.EFFECTIVE_START_DATE);
    ELSIF l_column_name = 'EFFECTIVE_END_DATE' THEN
      RETURN(g_split_erpyc_rec.EFFECTIVE_END_DATE);
    ELSIF l_column_name = 'RT_STRT_DT' THEN
      RETURN(g_split_erpyc_rec.RT_STRT_DT);
    ELSIF l_column_name = 'RT_END_DT' THEN
      RETURN(g_split_erpyc_rec.RT_END_DT);
    ELSIF l_column_name = 'MIN_RT_STRT_DT' THEN
      RETURN(g_split_erpyc_rec.MIN_RT_STRT_DT);
    ELSIF l_column_name = 'MAX_RT_END_DT' THEN
      RETURN(g_split_erpyc_rec.MAX_RT_END_DT);
    ELSIF l_column_name = 'ELEMENT_ENTRY_ESD' THEN
      RETURN(g_split_erpyc_rec.ELEMENT_ENTRY_ESD);
    ELSIF l_column_name = 'ELEMENT_ENTRY_EED' THEN
      RETURN(g_split_erpyc_rec.ELEMENT_ENTRY_EED);
    ELSIF l_column_name = 'OABV_LAST_UPDATE_DATE' THEN
      RETURN(g_split_erpyc_rec.OABV_LAST_UPDATE_DATE);
    ELSE
      -- column unknown
      RETURN(NULL);
    END IF;
  END IF;
END get_split_erpyc_date;

---------------------------------------------------------------
PROCEDURE disable_ele_entry_delete
---------------------------------------------------------------
IS
--
--  This procedure returns an error if an attempt is being made to
--  perform a Datetrack purge of an element entry. Certain types of Datetrack
--  delete are allowable, so we cannot simply prevent all deletes against
--  pay_element_entries_f.
--
--  If we try to access pay_element_entries_f from a delete trigger on
--  the same table, we hit a mutating table error. So we must perform
--  the delete check against a different table to that against which the
--  delete trigger is created.
--
--  We are making use of the validation rule that states that each
--  element entry must have at least one entry value. Within a commit unit,
--  rows are deleted from pay_element_entries_f before they are deleted from
--  pay_element_entry_values_f.
--
--  So the delete trigger is created against pay_element_entry_values_f, and
--  this procedure looks at pay_element_entries_f. The user is attempting a
--  Datetrack purge if there are no parent element entries that match
--  the element entry value that is being deleted.
--
--  This procedure uses the global g_ele_start_date to verify if the
--  element entry is current or futured dated.
--
--  This procedure uses the global g_ele_entry_id and g_ele_link_id
--  which are assigned in the set_ele_var_ids procedure.
--  The second part of the validation checks the link from the deleted element
--  entry to ensure that the element type does not contain either Y,E or D in
--  the attribute1 column.  If it does then an error is raised.
--  Attribute1 in pay_element_types_f is from this point
--  to be used as a flag to identify that it is a deduction element
--
  dummy     integer;
  l_attrib1 pay_element_entries_f.attribute1%TYPE := NULL;

BEGIN
  --
IF g_ele_start_date <= TRUNC(sysdate) THEN

  SELECT COUNT(element_entry_id)
  INTO dummy
  FROM pay_element_entries_f
  WHERE element_entry_id = g_ele_entry_id;
  --
  IF (dummy = 0) THEN
       SELECT pt.attribute1
       INTO l_attrib1
       FROM pay_element_types_f pt,
            pay_element_links_f pl
       WHERE
       pl.element_link_id      =  g_ele_link_id  AND
       pt.element_type_id      =  pl.element_type_id AND
       pt.effective_start_date = (SELECT max(pt2.effective_start_date)
                                  FROM pay_element_types_f pt2
                                  WHERE
                                  (pt2.effective_start_date <=
                                   TRUNC(sysdate))
                                  AND
                                  (pt2.element_type_id =
                                   pt.element_type_id)) AND
       pl.effective_start_date = (SELECT max(pt2.effective_start_date)
                                  FROM pay_element_links_f pt2
                                  WHERE
                                  (pt2.effective_start_date <=
                                   TRUNC(sysdate))
                                  AND
                                  (pt2.element_link_id =
                                   pl.element_link_id));
       IF l_attrib1 IN ('Y','E','D') THEN
         hr_utility.set_message (800, 'PER_ELE_ENTRY_DISABLE_DELETE');
         hr_utility.raise_error;
       END IF;
  END IF;
END IF;
END disable_ele_entry_delete;


--
-------------------------------------------------------------------------
PROCEDURE set_ele_var_ids(p_ele_link_id
                           pay_element_entries_f.element_link_id%TYPE,
                          p_ele_entry_id
                           pay_element_entries_f.element_entry_id%TYPE,
		 	  p_ele_start_date
			   pay_element_entries_f.effective_start_date%TYPE,
			  p_ele_person_id
		 	   per_all_people_f.person_id%TYPE)
-------------------------------------------------------------------------
-- This procedure stores the global variables for
-- g_ele_link_id, g_ele_entry_id, g_ele_start_date, g_ele_person_id
-- These are used by the disable_ele_entry_delete
-- to identify element entries and the element links.
IS
BEGIN
   g_ele_link_id    := p_ele_link_id;
   g_ele_entry_id   := p_ele_entry_id;
   g_ele_start_date := p_ele_start_date;
   g_ele_person_id  := p_ele_person_id;
END set_ele_var_ids;
--
---------------------------------------------------------------
procedure disable_emp_number_update (p_old_emp_number varchar2 default null,
                                     p_new_emp_number varchar2 default null)
---------------------------------------------------------------
is
--  This procedure returns an error if an attempt is being made to
--  update an employee number.
--  A change in employee number would result in the
--  creation of a new employee record in the vendors payroll.
--
begin
--
  if  p_old_emp_number is not null
  and p_new_emp_number is not null
  and p_old_emp_number <> p_new_emp_number then
       hr_utility.set_message (800, 'PER_EMP_NUMBER_DISABLE_UPDATE');
       hr_utility.raise_error;
  end if;
--
end disable_emp_number_update;
--
-- -------------------------------------------------------------------------
procedure chk_reporting_name_uniqueness
-- -------------------------------------------------------------------------
is
-- This procedure checks to make sure that the reporting name is unique
-- within the business_group and legislation.  If it isn't, then an error
-- is raised. This used to be a constraint on the database, but it was
-- removed for R10.
-- NOTE : This is called from a statement level 'AFTER' trigger, with the values
--  being stored globally from the row level 'BEFORE' trigger.
  --
  CURSOR csr_count_same_rep_name IS
  SELECT 1
  FROM pay_element_types_f et
  WHERE et.business_group_id
    = hr_pay_interface_pkg.g_reporting_details_rec_var.business_group_id
   AND (NVL(et.legislation_code,-99)
   = NVL(hr_pay_interface_pkg.g_reporting_details_rec_var.legislation_code,-99))
   AND UPPER(et.reporting_name)
     = UPPER(hr_pay_interface_pkg.g_reporting_details_rec_var.reporting_name)
   AND (et.element_type_id
      <> hr_pay_interface_pkg.g_reporting_details_rec_var.element_type_id
      OR hr_pay_interface_pkg.g_reporting_details_rec_var.element_type_id ='')
      -- Have to ensure the reporting name doesn't exist on date-tracked
      -- rows (even though reporting_name isn't datetracked, it still is
      -- possible to achieve by altering a datetrack row at the same time)
    AND (hr_pay_interface_pkg.g_reporting_details_rec_var.effective_start_date
      between et.effective_start_date and et.effective_end_date
      OR  hr_pay_interface_pkg.g_reporting_details_rec_var.effective_end_date
      between et.effective_start_date and et.effective_end_date
      OR (hr_pay_interface_pkg.g_reporting_details_rec_var.effective_start_date
	    < et.effective_start_date
         AND hr_pay_interface_pkg.g_reporting_details_rec_var.effective_end_date
	   > et.effective_end_date)
        );
  --
  l_dummy 	VARCHAR2(1);
begin
  --
  OPEN csr_count_same_rep_name;
  FETCH csr_count_same_rep_name INTO l_dummy;
  IF csr_count_same_rep_name%FOUND THEN
    hr_utility.set_message (800, 'PER_REPORTING_NAME_NOT_UNIQUE');
    --
    -- There is a element which has the same reporting_name and
    -- is in the same business_group and legislation_code.
    -- This is an error which will prevent the row from being inserted
    -- or updated.
    --
    CLOSE csr_count_same_rep_name;
    --
    -- Clear out the global record structure
    --
    hr_pay_interface_pkg.g_reporting_details_rec_var.reporting_name
      := '';
    hr_pay_interface_pkg.g_reporting_details_rec_var.business_group_id
      := '';
    hr_pay_interface_pkg.g_reporting_details_rec_var.legislation_code
      := '';
    hr_pay_interface_pkg.g_reporting_details_rec_var.element_type_id
      := '' ;
    hr_pay_interface_pkg.g_reporting_details_rec_var.effective_start_date
      := '' ;
    hr_pay_interface_pkg.g_reporting_details_rec_var.effective_end_date
      := '' ;
    --
    -- Raise an application error
    --
    hr_utility.raise_error;
    --
  ELSE
    --
    -- Clear out the global record structure
    --
    hr_pay_interface_pkg.g_reporting_details_rec_var.reporting_name
      := '';
    hr_pay_interface_pkg.g_reporting_details_rec_var.business_group_id
      := '';
    hr_pay_interface_pkg.g_reporting_details_rec_var.legislation_code
      := '';
    hr_pay_interface_pkg.g_reporting_details_rec_var.element_type_id
      := '' ;
    hr_pay_interface_pkg.g_reporting_details_rec_var.effective_start_date
      := '' ;
    hr_pay_interface_pkg.g_reporting_details_rec_var.effective_end_date
      := '' ;
    --
    CLOSE csr_count_same_rep_name;
    --
  END IF;
  --
end chk_reporting_name_uniqueness;
---------------------------------------------------------------------------
function get_hot_default(p_input_value_id  in number,
                         p_element_link_id in number)
                         return varchar2 is hot_default_value varchar2(60);
----------------------------------------------------------------------------
--
-- This function returns the hot default screen value for
-- an element entry input value.
--
-- Firstly, it looks at the element link level -
-- if there is no value here it will then look at the element type level.
-- If there are no values at either level it will return null.
--
-- The max effective start date select statement are there to get the
-- latest row before sysdate
--
begin
  select decode(pliv.default_value,
                null,
                piv.default_value,
                pliv.default_value) screen_entry_value
  into   hot_default_value
  from   pay_input_values_f         piv,
         pay_link_input_values_f    pliv
  where  pliv.element_link_id = p_element_link_id
    and  pliv.effective_start_date =
         (select max(pliv2.effective_start_date)
            from pay_link_input_values_f pliv2
            where pliv2.effective_start_date <= trunc(sysdate)
              and pliv2.element_link_id       = p_element_link_id
              and pliv2.input_value_id        = p_input_value_id)
    and  pliv.input_value_id  = p_input_value_id
    and  piv.effective_start_date =
         (select max(piv2.effective_start_date)
            from pay_input_values_f piv2
            where piv2.effective_start_date <= trunc(sysdate)
              and piv2.input_value_id        = p_input_value_id
              and hot_default_flag           = 'Y')
    and  piv.input_value_id   = p_input_value_id
    and  piv.hot_default_flag = 'Y';
--
return hot_default_value;

end get_hot_default;
-----------------------------------------------------------------------
procedure set_extract_date (p_payroll_extract_date date)
------------------------------------------------------------------------
is
-- This procedure sets the g_payroll_extract_date variable to the given date.
--
begin
   g_payroll_extract_date := p_payroll_extract_date;
   hr_adp.g_adp_extract_date := p_payroll_extract_date;
   hr_ceridian.g_cer_extract_date := p_payroll_extract_date;
--
end set_extract_date;
--
-----------------------------------------------------------------------
function get_extract_date return date
------------------------------------------------------------------------
is
-- This function returns the g_payroll_extract_date set by the call to
-- set_payroll_extract_date. If set_payroll_extract_date is never called, it
-- returns the sysdate as g_payroll_extract_date.
--
begin
   g_payroll_extract_date := nvl(g_payroll_extract_date, sysdate);
   RETURN g_payroll_extract_date;
--
end get_extract_date;
-------------------------------------------------------------------
procedure disable_ppm_update (p_old_priority varchar2 default null,
                              p_new_priority varchar2 default null)
-------------------------------------------------------------------
is
--  This procedure returns an error if an attempt is being made to
--  update personal payment method priority.
--  A change in priority would result in the
--  creation of a new EFT record in the third party payroll system.
--
begin
--
  if  p_old_priority is not null
  and p_new_priority is not null
  and p_old_priority <> p_new_priority then
       hr_utility.set_message (800, 'PER_PPM_PRI_DISABLE_UPDATE');
       hr_utility.raise_error;
  end if;
--
end disable_ppm_update;
--
---------------------------------------------------------------------
procedure disable_ppm_delete_purge
---------------------------------------------------------------------
is
--  This procedure returns an error if an attempt is being made to
--  delete a personal payment method.
--
CURSOR csr_ppm_delete_purge is
select 1
from  pay_personal_payment_methods_f
where personal_payment_method_id =
HR_PAY_INTERFACE_PKG.g_personal_payment_method_id;
--
CURSOR csr_ppm_post_fpd IS
SELECT 1
FROM per_periods_of_service         pps,
     per_all_assignments_f          paa
WHERE
     HR_PAY_INTERFACE_PKG.g_ppm_ass_id   = paa.assignment_id
AND  paa.person_id                       = pps.person_id
AND ( pps.final_process_date              IS NOT NULL
    OR pps.last_standard_process_date   IS NOT NULL)
AND  HR_PAY_INTERFACE_PKG.g_ppm_start_date > trunc(SYSDATE);
--
l_purge integer := NULL;
l_terminate integer := NULL;
--
begin
--
if (HR_PAY_INTERFACE_PKG.g_personal_payment_method_id IS NOT NULL) AND
  HR_PAY_INTERFACE_PKG.g_ppm_start_date <= trunc(SYSDATE) then
 open  csr_ppm_post_fpd;
 fetch csr_ppm_post_fpd into l_terminate;
 close csr_ppm_post_fpd;
 hr_pay_interface_pkg.g_ppm_start_date := NULL;
 hr_pay_interface_pkg.g_ppm_ass_id := NULL;

 if l_terminate is NULL then
  open  csr_ppm_delete_purge;
  fetch csr_ppm_delete_purge into l_purge;
  close csr_ppm_delete_purge;

  HR_PAY_INTERFACE_PKG.g_personal_payment_method_id := NULL;
  if l_purge IS NULL then
   hr_utility.set_message (800, 'PER_PRS_PAY_MTD_DISABLE_DEL');
   hr_utility.raise_error;
--  else
--   HR_PAY_INTERFACE_PKG.g_personal_payment_method_id := NULL;
  end if;
 end if;
else
  HR_PAY_INTERFACE_PKG.g_personal_payment_method_id := NULL;
end if;
--
end disable_ppm_delete_purge;

procedure disable_asg_cost_delete_purge
---------------------------------------------------------------------
is
--
--  This procedure returns an error if an attempt is being made to
--  delete an assignment costing.
--
CURSOR csr_asg_cost_delete_purge is
select 1
from  pay_cost_allocations_f
where cost_allocation_id =
HR_PAY_INTERFACE_PKG.g_cost_allocation_id;
--
CURSOR csr_asg_cost_post_fpd IS
SELECT 1
FROM per_periods_of_service         pps,
     per_all_assignments_f          paa
WHERE
     HR_PAY_INTERFACE_PKG.g_asg_cost_ass_id = paa.assignment_id
AND  paa.person_id                          = pps.person_id
AND  (pps.final_process_date                 IS NOT NULL
    OR pps.last_standard_process_date   IS NOT NULL)
AND  HR_PAY_INTERFACE_PKG.g_asg_cost_start_date > trunc(SYSDATE);
--
l_purge     integer := NULL;
l_terminate integer := NULL;
--
begin
--
if (HR_PAY_INTERFACE_PKG.g_cost_allocation_id IS NOT NULL) AND
   (HR_PAY_INTERFACE_PKG.g_asg_cost_start_date <= trunc(SYSDATE)) then

 open  csr_asg_cost_post_fpd;
 fetch csr_asg_cost_post_fpd into l_terminate;
 close csr_asg_cost_post_fpd;
 hr_pay_interface_pkg.g_asg_cost_start_date := NULL;
 hr_pay_interface_pkg.g_asg_cost_ass_id   := NULL;

 if l_terminate is NULL then

  open  csr_asg_cost_delete_purge;
  fetch csr_asg_cost_delete_purge into l_purge;
  close csr_asg_cost_delete_purge;

  HR_PAY_INTERFACE_PKG.g_cost_allocation_id := NULL;
  if l_purge IS NULL then
   hr_utility.set_message (800, 'PER_ASG_COST_INF_DIS_PRG_DEL');
   hr_utility.raise_error;
--  else
  -- HR_PAY_INTERFACE_PKG.g_cost_allocation_id := NULL;
  end if;
 end if;
else
  HR_PAY_INTERFACE_PKG.g_cost_allocation_id := NULL;
end if;
--
end disable_asg_cost_delete_purge;

end HR_PAY_INTERFACE_PKG ;

/
