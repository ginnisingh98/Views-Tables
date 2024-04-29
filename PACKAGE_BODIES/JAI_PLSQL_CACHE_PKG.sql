--------------------------------------------------------
--  DDL for Package Body JAI_PLSQL_CACHE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PLSQL_CACHE_PKG" AS
/* $Header: jai_plsql_cache.plb 120.5 2006/08/24 15:33:39 lgopalsa noship $ */

/* Read from cache */
FUNCTION  read_cache
          (p_org_id IN HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE)
 RETURN func_curr_details AS
   l_func_curr_det func_curr_details;
 BEGIN
  IF (g_get_func_curr.EXISTS (p_org_id)) THEN

    l_func_curr_det.ledger_id := g_get_func_curr(p_org_id).ledger_id;
    l_func_curr_det.currency_code  := g_get_func_curr(p_org_id).currency_code;
    l_func_curr_det.chart_of_accounts_id := g_get_func_curr(p_org_id).chart_of_accounts_id;
    l_func_curr_det.organization_code    := g_get_func_curr(p_org_id).organization_code;
    l_func_curr_det.legal_entity         := g_get_func_curr(p_org_id).legal_entity;
    l_func_curr_det.organization_name    := g_get_func_curr(p_org_id).organization_name;
    l_func_curr_det.minimum_acct_unit    := g_get_func_curr(p_org_id).minimum_acct_unit;
    l_func_curr_det.precision            := g_get_func_curr(p_org_id).precision;


  End if;

  RETURN l_func_curr_det;

 EXCEPTION
   WHEN OTHERS THEN
     --NULL ;
     fnd_file.put_line(FND_FILE.LOG, ' Error reading cache' || SQLERRM);

 END read_cache;


/* Write from cache */

PROCEDURE write_cache
          (p_org_id        IN HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE,
           p_func_curr_det IN func_curr_details
          ) AS

BEGIN
  g_get_func_curr(p_org_id).ledger_id := p_func_curr_det.ledger_id;
  g_get_func_curr(p_org_id).currency_code := p_func_curr_det.currency_code;
  g_get_func_curr(p_org_id).chart_of_accounts_id := p_func_curr_det.chart_of_accounts_id;
  g_get_func_curr(p_org_id).organization_code    := p_func_curr_det.organization_code;
  g_get_func_curr(p_org_id).legal_entity         := p_func_curr_det.legal_entity;
  g_get_func_curr(p_org_id).organization_name    := p_func_curr_det.organization_name;
  g_get_func_curr(p_org_id).minimum_acct_unit    := p_func_curr_det.minimum_acct_unit;
  g_get_func_curr(p_org_id).PRECISION            := p_func_curr_det.precision;

EXCEPTION
 WHEN OTHERS THEN
  -- null;
  fnd_file.put_line(FND_FILE.LOG, ' Error writing  cache'|| SQLERRM);
END write_cache;


/* Read from db and write into cache */

FUNCTION read_from_db
         (p_org_id IN HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE)
 RETURN func_curr_details AS
   ln_ledger_id NUMBER;
   lv_curr_code VARCHAR2(10);

   lc_fetch_org_det get_inv_org%ROWTYPE;
   lc_fetch_curr_det get_func_curr%ROWTYPE;
   l_func_curr_det func_curr_details;
   v_debug varchar2(1);
   -- Bug 5243532. Added by Lakshmi Gopalsami
   lc_fetch_curr get_curr_details%ROWTYPE;

 BEGIN
   v_debug := 'N';
   OPEN get_inv_org (p_org_id);
    FETCH get_inv_org INTO lc_fetch_org_det;
   CLOSE get_inv_org;

   /* Print into util file if v_debug ='Y' */

   If v_debug ='Y' Then
      jai_cmn_utils_pkg.print_log('JAI_PLSQL_CACHE_PKG.log', ' read from db ' );
     -- jai_cmn_utils_pkg.print_log('JAI_PLSQL_CACHE_PKG.log',
       --           ' Inv org ledger id ' || lc_fetch_org_det.ledger_id);
   End if;

   --fnd_file.put_line(FND_FILE.LOG, '1. ledger id '
   --|| lc_fetch_org_det.ledger_id);

   IF lc_fetch_org_det.ledger_id IS  NULL THEN
     OPEN get_OU (p_org_id);
       FETCH get_OU INTO lc_fetch_org_det;
     CLOSE get_OU;
     /* Print into util file if v_debug ='Y' */
     If v_debug ='Y' Then
        jai_cmn_utils_pkg.print_log('JAI_PLSQL_CACHE_PKG.log',
	'OU  ledger id ' || lc_fetch_org_det.ledger_id);
     End if;
     --fnd_file.put_line(FND_FILE.LOG, ' 3. ledger id '
     --|| lc_fetch_org_det.ledger_id);
   END if;

   IF lc_fetch_org_det.ledger_id IS NOT NULL THEN
    OPEN get_func_curr(lc_fetch_org_det.ledger_id);
     FETCH get_func_curr INTO lc_fetch_curr_det;
    CLOSE get_func_curr;
      --fnd_file.put_line(FND_FILE.LOG, ' 2. curr code  '
      --                         || lc_fetch_curr_det.curr_code);
    /* Bug 5243532. Added by Lakshmi Gopalsami
       Get the precision and minimum accountable unit
    */
    IF lc_fetch_curr_det.curr_code IS NOT NULL THEN
      OPEN get_curr_details(lc_fetch_curr_det.curr_code);
       Fetch get_curr_details INTO lc_fetch_curr;
      CLOSE get_curr_details;
    END IF;
   END IF;

   /* Bug 5148770. Changed ln_ledger_id to lc_fetch_org_det.ledger_id */

   IF lc_fetch_curr_det.curr_code IS NOT NULL AND lc_fetch_org_det.ledger_id IS NOT NULL THEN
     l_func_curr_det.ledger_id            := lc_fetch_org_det.ledger_id;
     l_func_curr_det.currency_code        := lc_fetch_curr_det.curr_code;
     l_func_curr_det.chart_of_accounts_id := lc_fetch_curr_det.coa;
     l_func_curr_det.organization_code    := lc_fetch_org_det.org_code;
     l_func_curr_det.legal_entity         := lc_fetch_org_det.leg_ent;
     l_func_curr_det.organization_name    := lc_fetch_org_det.org_name;
     -- Bug 5243532. Added by Lakshmi Gopalsami
     l_func_curr_det.minimum_acct_unit    := lc_fetch_curr.minimum_acct_unit;
     l_func_curr_det.precision            :=lc_fetch_curr.precision;

   END IF;

   RETURN l_func_curr_det;

 EXCEPTION
   WHEN OTHERS THEN
    -- null;
    fnd_file.put_line(FND_FILE.LOG, ' Error reading database'|| SQLERRM);
 END read_from_db;


  /* Function which performs reading from cache, if not found
     read from db and write onto the cache and return the same
  */

  FUNCTION return_sob_curr
          (p_org_id  IN HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE)
   RETURN func_curr_details AS

      l_func_curr_det func_curr_details;
      v_debug         varchar2(1);
    BEGIN
      v_debug := 'N';

      l_func_curr_det := read_cache(p_org_id);

       -- Read from cache and display .

       /*
       fnd_file.put_line(FND_FILE.LOG, ' value of org id '
                                      || p_org_id);
       fnd_file.put_line(FND_FILE.LOG, ' Cache values - ledger id '
                                      || l_func_curr_det.ledger_id);
       fnd_file.put_line(FND_FILE.LOG, ' Currency Code '
                                      || l_func_curr_det.currency_code);
       fnd_file.put_line(FND_FILE.LOG, ' Chart of Accounts id '
                                      || l_func_curr_det.chart_of_accounts_id);
       fnd_file.put_line(FND_FILE.LOG, ' Organization code '
                                      || l_func_curr_det.organization_code);
       fnd_file.put_line(FND_FILE.LOG, ' Organization Name  '
                                      || l_func_curr_det.organization_name);
       fnd_file.put_line(FND_FILE.LOG, ' Legal Entity'
                                      || l_func_curr_det.legal_entity);
        */
       /* Print into util file if v_debug ='Y' */

       If v_debug ='Y' Then
        jai_cmn_utils_pkg.print_log('JAI_PLSQL_CACHE_PKG.log', 'from cache ledger id ' ||l_func_curr_det.ledger_id);
        jai_cmn_utils_pkg.print_log('JAI_PLSQL_CACHE_PKG.log',
	                            'Curr code '|| l_func_curr_det.currency_code);
       End if;


       if  l_func_curr_det.ledger_id is null then

        -- Read from db as the details are not available in cache.

        l_func_curr_det := read_from_db(p_org_id);
        /*
        fnd_file.put_line(FND_FILE.LOG, ' Inside cache value null - org id '
	                              || p_org_id);
        fnd_file.put_line(FND_FILE.LOG, ' Cache values - ledger id '
                                      || l_func_curr_det.ledger_id);
        fnd_file.put_line(FND_FILE.LOG, ' Currency Code '
                                      || l_func_curr_det.currency_code);
        fnd_file.put_line(FND_FILE.LOG, ' Chart of Accounts id '
                                      || l_func_curr_det.chart_of_accounts_id);
        fnd_file.put_line(FND_FILE.LOG, ' Organization code '
                                      || l_func_curr_det.organization_code);
        fnd_file.put_line(FND_FILE.LOG, ' Organization Name  '
                                      || l_func_curr_det.organization_name);
        fnd_file.put_line(FND_FILE.LOG, ' Legal Entity'
                                      || l_func_curr_det.legal_entity);
       */
       /* Print into util file if v_debug ='Y' */

       If v_debug ='Y' Then
         jai_cmn_utils_pkg.print_log('JAI_PLSQL_CACHE_PKG.log', 'from db ledger id ' ||l_func_curr_det.ledger_id);
         jai_cmn_utils_pkg.print_log('JAI_PLSQL_CACHE_PKG.log', 'Curr code '|| l_func_curr_det.currency_code);
       End if;

	if  l_func_curr_det.ledger_id is not null then
        /*
          fnd_file.put_line(FND_FILE.LOG, ' Cache values - ledger id '
                                      || l_func_curr_det.ledger_id);
          fnd_file.put_line(FND_FILE.LOG, ' Currency Code '
                                      || l_func_curr_det.currency_code);
          fnd_file.put_line(FND_FILE.LOG, ' Chart of Accounts id '
                                      || l_func_curr_det.chart_of_accounts_id);
          fnd_file.put_line(FND_FILE.LOG, ' Organization code '
                                      || l_func_curr_det.organization_code);
          fnd_file.put_line(FND_FILE.LOG, ' Organization Name  '
                                      || l_func_curr_det.organization_name);
          fnd_file.put_line(FND_FILE.LOG, ' Legal Entity'
                                      || l_func_curr_det.legal_entity);
         */
          /* Print into util file if v_debug ='Y' */

          If v_debug ='Y' Then
            jai_cmn_utils_pkg.print_log('JAI_PLSQL_CACHE_PKG.log',
	    'db value not null ledger id ' ||l_func_curr_det.ledger_id);
            jai_cmn_utils_pkg.print_log('JAI_PLSQL_CACHE_PKG.log',
	    'Curr code '|| l_func_curr_det.currency_code);
          End if;
          -- Write into cache the values got from db.
          write_cache(p_org_id, l_func_curr_det);
        end if; /*  l_func_curr_det.ledger_id is not null */
       end if;  /* l_func_curr_det.ledger_id is  null  */

       RETURN l_func_curr_det;

  END return_sob_curr;

END JAI_PLSQL_CACHE_PKG;

/
