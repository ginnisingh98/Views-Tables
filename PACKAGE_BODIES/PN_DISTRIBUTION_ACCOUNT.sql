--------------------------------------------------------
--  DDL for Package Body PN_DISTRIBUTION_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_DISTRIBUTION_ACCOUNT" AS
  -- $Header: PNUPGACB.pls 120.2 2005/12/01 15:02:02 appldev ship $

-------------------------------------------------------------------------------
-- PROCDURE     : CREATE_ACCOUNTS
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-JUL-05 hareesha o Bug 4284035 - Replaced pn_payment_terms,pn_leases,
--                       pn_locations with _ALL table.
-- 25-OCT-05 Hareesha o ATG mandated changes for SQL literals using dbms_sql.
-------------------------------------------------------------------------------
  PROCEDURE create_accounts (
    errbuf                  OUT NOCOPY      VARCHAR2   ,
    retcode                 OUT NOCOPY      VARCHAR2   ,
    p_chart_of_accounts_id  IN              NUMBER     ,
    p_lease_class           IN              VARCHAR2   ,
    p_lease_num_from        IN              VARCHAR2   ,
    p_lease_num_to          IN              VARCHAR2   ,
    p_locn_code_from        IN              VARCHAR2   ,
    p_locn_code_to          IN              VARCHAR2   ,
    p_rec_ccid              IN              NUMBER     ,
    p_accr_asset_ccid       IN              NUMBER     ,
    p_lia_ccid              IN              NUMBER     ,
    p_accr_liab_ccid        IN              NUMBER
  ) IS

  l_payment_term_id      pn_payment_terms.payment_term_id%TYPE;
  l_normalize            pn_payment_terms.normalize%TYPE;
  l_org_id               NUMBER;
  l_project_id           NUMBER;
  l_distribution_set_id  NUMBER;
  l_lease_num            pn_leases.lease_num%TYPE;
  l_lease_class_code     pn_leases.lease_class_code%TYPE;
  l_lia_rec_class        pn_distributions.account_class%TYPE;
  l_lia_rec_acc          pn_distributions.account_id%TYPE;
  l_accr_class           pn_distributions.account_class%TYPE;
  l_accr_acc             pn_distributions.account_id%TYPE;
  l_count                NUMBER := 0;
  l_total_count          NUMBER := 0;
  l_context              VARCHAR2(2000);
  /* v_where_clause         VARCHAR2(2000):= NULL; */
  l_primary_flag         VARCHAR2(30) := 'Y';
  l_accr_acc_exists      VARCHAR2(30) := 'Y';
  l_lia_rec_acc_exists   VARCHAR2(30) := 'Y';
  l_err_msg              VARCHAR2(2000);
  l_cursor               INTEGER;
  l_statement            VARCHAR2(10000);
  l_rows                 INTEGER;
  l_count1               INTEGER;
  l_lease_num_from       VARCHAR2(30);
  l_lease_num_to         VARCHAR2(30);
  l_locn_code_from       VARCHAR2(90);
  l_locn_code_to         VARCHAR2(90);
  x_primary_flag         VARCHAR2(30);
  x_lease_class          VARCHAR2(30);


  BEGIN

    pnp_debug_pkg.log('pn_distribution_account.create_accounts (+)' );

    fnd_message.set_name ('PN','PN_UPGAC_INP_PRM');
    fnd_message.set_token ('LS_CLASS',p_lease_class);
    fnd_message.set_token ('LS_FRM',p_lease_num_from);
    fnd_message.set_token ('LS_TO',p_lease_num_to);
    fnd_message.set_token ('LOC_FRM',p_locn_code_from);
    fnd_message.set_token ('LOC_TO',p_locn_code_to);
    fnd_message.set_token ('LIA_ACC',TO_CHAR(p_lia_ccid));
    fnd_message.set_token ('LIB_ACC',TO_CHAR(p_accr_liab_ccid));
    fnd_message.set_token ('REC_ACC',TO_CHAR(p_rec_ccid));
    fnd_message.set_token ('ASS_ACC',TO_CHAR(p_accr_asset_ccid));
    pnp_debug_pkg.put_log_msg(fnd_message.get);


    IF (p_lease_class IS NULL AND
         (p_rec_ccid IS NULL OR
          p_accr_asset_ccid  IS NULL OR
          p_lia_ccid  IS NULL OR
          p_accr_liab_ccid IS NULL ))
        OR ( p_lease_class = 'DIRECT' AND
             (p_lia_ccid  IS NULL OR
              p_accr_liab_ccid IS NULL))
        OR ( p_lease_class IN ('SUB_LEASE','THIRD_PARTY') AND
             (p_rec_ccid  IS NULL OR
              p_accr_asset_ccid IS NULL)) THEN

                fnd_message.set_name ('PN', 'PN_ALL_ACNT_DIST_MSG');
                l_err_msg := fnd_message.get;
                pnp_debug_pkg.put_log_msg(l_err_msg);
                RETURN;
     END IF;


    l_context := 'forming where clause';

    l_cursor := dbms_sql.open_cursor;
    l_statement :=
    'SELECT ppt.payment_term_id,
               ppt.normalize,
               pl.lease_num,
               ppt.org_id,
               ppt.distribution_set_id,
               ppt.project_id,
               pl.lease_class_code
        FROM pn_payment_terms ppt,
             pn_tenancies_all pt,
             pn_locations_all pln,
             pn_leases_all pl
        WHERE ppt.lease_id        = pl.lease_id
         AND  pt.lease_id (+)     = pl.lease_id
         AND  pt.location_id      = pln.location_id (+)
         AND  pt.primary_flag (+) = :x_primary_flag
         AND  SYSDATE between NVL(pt.occupancy_date,SYSDATE)
         AND NVL(pt.expiration_date,
                TO_DATE(''12/31/4712'',''mm/dd/yyyy''))
         AND  pl.lease_class_code =  NVL(:x_lease_class,pl.lease_class_code)';


    x_primary_flag := l_primary_flag;
    x_lease_class := p_lease_class;

    IF p_lease_num_from IS NOT NULL THEN
       l_lease_num_from := p_lease_num_from;
       l_statement :=
       l_statement || ' AND lease_num >= :l_lease_num_from ';

    END IF;

    IF p_lease_num_to IS NOT NULL THEN
       l_lease_num_to := p_lease_num_to;
       l_statement :=
       l_statement || ' AND lease_num <= :l_lease_num_to ';

    END IF;

    IF p_locn_code_from IS NOT NULL THEN
       l_locn_code_from := p_locn_code_from;
       l_statement :=
       l_statement || ' AND location_code >= :l_locn_code_from ';

    END IF;

    IF p_locn_code_to IS NOT NULL THEN
       l_locn_code_to := p_locn_code_to;
       l_statement :=
       l_statement || ' AND location_code <= :l_locn_code_to ';

    END IF;

    dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);

    dbms_sql.bind_variable
            (l_cursor,'x_primary_flag',x_primary_flag );
    dbms_sql.bind_variable
            (l_cursor,'x_lease_class',x_lease_class );

    IF p_lease_num_from IS NOT NULL THEN
       dbms_sql.bind_variable
            (l_cursor,'l_lease_num_from',l_lease_num_from );
    END IF;

    IF p_lease_num_to IS NOT NULL THEN
       dbms_sql.bind_variable
            (l_cursor,'l_lease_num_to',l_lease_num_to );
    END IF;

    IF p_locn_code_from IS NOT NULL THEN
       dbms_sql.bind_variable
            (l_cursor,'l_locn_code_from',l_locn_code_from );
    END IF;

    IF p_locn_code_to IS NOT NULL THEN
       dbms_sql.bind_variable
            (l_cursor,'l_locn_code_to',l_locn_code_to );
    END IF;

    dbms_sql.define_column (l_cursor, 1,l_payment_term_id);
    dbms_sql.define_column (l_cursor, 2,l_normalize,1);
    dbms_sql.define_column (l_cursor, 3,l_lease_num,30);
    dbms_sql.define_column (l_cursor, 4,l_org_id);
    dbms_sql.define_column (l_cursor, 5,l_distribution_set_id);
    dbms_sql.define_column (l_cursor, 6,l_project_id);
    dbms_sql.define_column (l_cursor, 7,l_lease_class_code,30);

    l_rows   := dbms_sql.execute(l_cursor);

    LOOP

         l_count1 := dbms_sql.fetch_rows( l_cursor );

         EXIT WHEN l_count1 <> 1;

         dbms_sql.column_value (l_cursor, 1,l_payment_term_id);
         dbms_sql.column_value (l_cursor, 2,l_normalize);
         dbms_sql.column_value (l_cursor, 3,l_lease_num);
         dbms_sql.column_value (l_cursor, 4,l_org_id);
         dbms_sql.column_value (l_cursor, 5,l_distribution_set_id);
         dbms_sql.column_value (l_cursor, 6,l_project_id);
         dbms_sql.column_value (l_cursor, 7,l_lease_class_code);

         pnp_debug_pkg.log('Processing ... ' );
         pnp_debug_pkg.log('Lease Num       :' || l_lease_num );
         pnp_debug_pkg.log('Payment Term Id :' || l_payment_term_id );
         pnp_debug_pkg.log('Lease Class :' || l_lease_class_code );

         IF l_lease_class_code = 'DIRECT' AND l_project_id IS NULL AND l_distribution_set_id IS NULL
         THEN

            l_context := 'setting Liability A/Cs ';

            l_lia_rec_class := 'LIA';
            l_lia_rec_acc   := p_lia_ccid;
            l_accr_class    := 'ACC';
            l_accr_acc      := p_accr_liab_ccid ;

         ELSIF l_lease_class_code IN ('SUB_LEASE','THIRD_PARTY') THEN

            l_context := 'setting Receivables A/Cs ';

            l_lia_rec_class := 'REC';
            l_lia_rec_acc   := p_rec_ccid;
            l_accr_class    := 'UNEARN';
            l_accr_acc      := p_accr_asset_ccid;

         END IF;
         l_count := l_count + 1;

         IF (l_lease_class_code = 'DIRECT'
            AND l_project_id IS NULL AND l_distribution_set_id IS NULL) OR
            (l_lease_class_code IN ('SUB_LEASE','THIRD_PARTY')) THEN

            /* Create an Liability/Receivable  a/c distribution */

            pnp_debug_pkg.log('Creating Liability/Receivable A/C ... ' );

            l_context := 'Creating Liability/Receivables A/C ';

            savepoint create_accnts;

            create_accnt_dist (p_payment_term_id   => l_payment_term_id,
                               p_accnt_class       => l_lia_rec_class,
                               p_accnt_ccid        => l_lia_rec_acc,
                               p_percent           =>  100,
                               p_org_id            => l_org_id,
                               p_accnt_exists      => l_lia_rec_acc_exists);

            /* Create an accrued asset/accrued liability  a/c distribution */

            pnp_debug_pkg.log('Creating  Accrued Liability/ Accrued Asset A/C ... ' );

            l_context := 'Creating Accrued Liability/ Accrued Receivables A/C ';

            create_accnt_dist (p_payment_term_id   => l_payment_term_id,
                               p_accnt_class       => l_accr_class,
                               p_accnt_ccid        => l_accr_acc,
                               p_percent           =>  100,
                               p_org_id            => l_org_id,
                               p_accnt_exists      => l_accr_acc_exists);

             IF l_lia_rec_acc_exists = 'Y' AND l_accr_acc_exists = 'Y' THEN
                l_count := l_count - 1;
             END IF;

          END IF;

          IF l_count = 1000 THEN

             l_context := 'Commiting for count of 100';
             pnp_debug_pkg.log('commiting for count of 100 ... ' );
             COMMIT;
             l_total_count := l_total_count + l_count;
             l_count := 0;

          END IF;

     END LOOP;

     l_context := 'exiting from loop';

     IF dbms_sql.is_open (l_cursor) THEN
        dbms_sql.close_cursor (l_cursor);
     END IF;

     COMMIT;
     fnd_message.set_name ('PN','PN_UPGAC_PROC');
     fnd_message.set_token ('NUM', TO_CHAR(l_total_count));
     pnp_debug_pkg.put_log_msg(fnd_message.get);

     pnp_debug_pkg.log('pn_distribution_account.create_accounts (-)' );

     EXCEPTION

     WHEN OTHERS THEN
     pnp_debug_pkg.log(SUBSTRB('Error IN create_accounts - ' || TO_CHAR(sqlcode) || ' - '|| l_context,1,244));
     errbuf := SUBSTRB('Error - ' || TO_CHAR(sqlcode) || ' - '|| l_context,1,244);
     Retcode := sqlcode;
     ROLLBACK TO create_accnts;
     RAISE;

  END create_accounts;

-------------------------------------------------------------------------------
-- PROCDURE     : CREATE_ACCNT_DIST
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_distributions with _ALL.
-- 22-NOV-05  Hareesha o Replaced _all with secured synonyms/baseviews.
-------------------------------------------------------------------------------
  PROCEDURE create_accnt_dist (
    p_payment_term_id       IN              NUMBER   ,
    p_accnt_class           IN              VARCHAR2 ,
    p_accnt_ccid            IN              NUMBER   ,
    p_percent               IN              NUMBER   ,
    p_org_id                IN              NUMBER   ,
    p_accnt_exists          OUT NOCOPY      VARCHAR2
  ) IS

  CURSOR chk_exists IS
  SELECT'Y'
  FROM dual
  WHERE EXISTS (SELECT NULL
                FROM pn_distributions_all
                WHERE payment_term_id = p_payment_term_id
                AND account_class     = p_accnt_class);

   l_exists VARCHAR2(30) := 'N';
   l_context VARCHAR2(2000);
  l_line_number      pn_distributions.line_number%TYPE;

  CURSOR org_cur IS
    SELECT org_id FROM pn_payment_terms_all WHERE payment_term_ID = p_payment_term_id;

  l_org_ID NUMBER;
  BEGIN

      pnp_debug_pkg.log('pn_distribution_account.create_accnt_dist (+)' );

      l_context := 'Opening cursor';
      OPEN chk_exists;

      l_context := 'fetching cursor';
      FETCH chk_exists INTO l_exists;

      CLOSE chk_exists;

      p_accnt_exists := l_exists;

      IF l_exists = 'N' THEN

       /* get the line NUMBER */

       l_context := 'getting line NUMBER';
       SELECT NVL(MAX (line_number),0) + 1
       INTO l_line_number
       FROM pn_distributions_all
       WHERE payment_term_id = p_payment_term_id;

       pnp_debug_pkg.log('Line Number : ' || TO_CHAR(l_line_number) );

       l_context := 'inserting INTO dist.';

       IF p_org_ID IS NULL THEN
         FOR rec IN org_cur LOOP
           l_org_ID := rec.org_id;
         END LOOP;
       ELSE
         l_org_ID := p_org_id;
       END IF;

       INSERT INTO pn_distributions_all (distribution_id,
                                     payment_term_id,
                                     account_id,
                                     account_class,
                                     percentage,
                                     line_number,
                                     last_update_date,
                                     last_update_login,
                                     last_updated_by,
                                     creation_date,
                                     created_by,
                                     org_id)
                          VALUES    (pn_distributions_s.nextval,
                                     p_payment_term_id,
                                     p_accnt_ccid,
                                     p_accnt_class,
                                     p_percent,
                                     l_line_number,
                                     SYSDATE,
                                     FND_GLOBAL.LOGIN_ID,
                                     FND_GLOBAL.USER_ID,
                                     SYSDATE,
                                     FND_GLOBAL.USER_ID,
                                     l_org_ID);

       pnp_debug_pkg.log('Inserted INTO pn_distributions ...' );
       pnp_debug_pkg.log('Payment Term Id : '|| TO_CHAR(p_payment_term_id) );
       pnp_debug_pkg.log('Account Class   : '|| p_accnt_class );
       pnp_debug_pkg.log('Account Id      : '|| TO_CHAR(p_accnt_ccid) );
       pnp_debug_pkg.log('Percentage      : '|| TO_CHAR(p_percent) );
       pnp_debug_pkg.log('Org. Id         : '|| TO_CHAR(p_org_id) );

       END IF;

      l_context := 'done inserting INTO dist.';
      pnp_debug_pkg.log('pn_distribution_account.create_accnt_dist (-)' );

     EXCEPTION
     WHEN OTHERS THEN
     pnp_debug_pkg.log(SUBSTRB('Error IN create_accnt_dist - ' || TO_CHAR(sqlcode) || ' - '|| l_context,1,244));
     ROLLBACK;
     RAISE;

  END create_accnt_dist;

END pn_distribution_account;

/
