--------------------------------------------------------
--  DDL for Package Body PN_MTM_ROLLFORWARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_MTM_ROLLFORWARD_PKG" AS
/* $Header: PNRLFWDB.pls 120.0.12010000.3 2010/01/22 13:35:19 kmaddi ship $ */

-------------------------------------------------------------------------------
--  PROCEDURE  : ROLLFORWARD_LEASES
--  DESCRIPTION: Called from Concurrent program Month to Month Rollforward Process
--
--  19-OCT-06   Hareesha  o Created
-------------------------------------------------------------------------------

PROCEDURE rollforward_leases( errbuf              OUT NOCOPY VARCHAR2,
                              retcode             OUT NOCOPY VARCHAR2,
                              p_lease_no_low          VARCHAR2,
                              p_lease_no_high         VARCHAR2,
                              p_lease_ext_end_dt      VARCHAR2,
                              p_lease_option          VARCHAR2)
IS

   INCORECT_LEASE_EXCEPTION     EXCEPTION;
   INCORRECT_EXTENSION_END_DATE EXCEPTION;
   INCORRECT_LEASE_OPTION       EXCEPTION;
   INVALID_LEASE_RECORD         EXCEPTION;

   l_lease_ext_end_dt           DATE;
   l_errbuf                     VARCHAR2(100);
   l_retcode                    VARCHAR2(100);
   l_extend_ri                  VARCHAR2(1) := NULL;
   l_requestId                  NUMBER := NULL;

   l_total                      NUMBER := 0;
   l_success                    NUMBER := 0;
   l_fail                       NUMBER := 0;

   /* variables for dbms_sql */
   l_cursor                     INTEGER;
   l_rows                       INTEGER;
   l_count                      INTEGER;
   l_where_clause               VARCHAR2(2000)  := NULL;
   l_lease_no_low               VARCHAR2(30);
   l_lease_no_high              VARCHAR2(30);
   Q_lease_details              VARCHAR2(1000);
   l_lease_id                   NUMBER;
   l_lease_status               VARCHAR2(30);
   l_status                     VARCHAR2(1);
   l_old_ext_dt                 DATE;
   l_lease_change_id            NUMBER;

BEGIN

   pnp_debug_pkg.log('pn_mtm_rollforward_pkg.rollforward_leases +Start+ (+)');
   pnp_debug_pkg.log('Lease Number Low          : '||p_lease_no_low);
   pnp_debug_pkg.log('Lease Number Low          : '||p_lease_no_high);
   pnp_debug_pkg.log('Lease extension end date  : '||p_lease_ext_end_dt);
   pnp_debug_pkg.log('Lease Option              : '||p_lease_option);

   l_lease_ext_end_dt := fnd_date.canonical_to_date(p_lease_ext_end_dt);

   IF l_lease_ext_end_dt IS NULL THEN
      RAISE INCORRECT_EXTENSION_END_DATE;
   END IF;

   IF  p_lease_option IS NULL  OR
       p_lease_option NOT IN ('A','L')
   THEN
      RAISE INCORRECT_LEASE_OPTION;
   END IF;

   l_cursor := dbms_sql.open_cursor;

   IF p_lease_no_low IS NOT NULL AND p_lease_no_high IS NOT NULL THEN
      l_lease_no_low := p_lease_no_low;
      l_lease_no_high := p_lease_no_high;
      l_where_clause := l_where_clause ||' AND lease_num BETWEEN :l_lease_no_low AND :l_lease_no_high ';

   ELSIF p_lease_no_low IS NOT NULL AND p_lease_no_high IS NULL THEN
      l_lease_no_low := p_lease_no_low;
      l_where_clause := l_where_clause ||' AND lease_num >= :l_lease_no_low ';

   ELSIF p_lease_no_high IS NOT NULL AND p_lease_no_low IS NULL THEN
      l_lease_no_high := p_lease_no_high;
      l_where_clause := l_where_clause ||' AND lease_num <= :l_lease_no_high ';

   ELSE
      l_where_clause := NULL;
   END IF;

   Q_lease_details :=
   ' SELECT
    lease.lease_id lease_id,
    lease.lease_status lease_status,
    lease.status status,
    det.lease_extension_end_date lease_extension_end_date,
    det.lease_change_id lease_change_id
    FROM pn_leases_all lease,
         pn_lease_details_all det
    WHERE lease.lease_id = det.lease_id ';

   Q_lease_details := Q_lease_details || l_where_clause;

   /*pnp_debug_pkg.log(' Q_lease_details :'||Q_lease_details);*/

   dbms_sql.parse(l_cursor, Q_lease_details, dbms_sql.native);

   IF p_lease_no_low IS NOT NULL AND p_lease_no_high IS NOT NULL THEN

      dbms_sql.bind_variable
            (l_cursor,'l_lease_no_low',l_lease_no_low );
      dbms_sql.bind_variable
            (l_cursor,'l_lease_no_high',l_lease_no_high );

   ELSIF p_lease_no_low IS NOT NULL AND p_lease_no_high IS NULL THEN
      dbms_sql.bind_variable
            (l_cursor,'l_lease_no_low',l_lease_no_low );

   ELSIF p_lease_no_high IS NOT NULL AND p_lease_no_low IS NULL THEN
      dbms_sql.bind_variable
            (l_cursor,'l_lease_no_high',l_lease_no_high );
   END IF;

   dbms_sql.define_column (l_cursor, 1,l_lease_id);
   dbms_sql.define_column (l_cursor, 2,l_lease_status,30);
   dbms_sql.define_column (l_cursor, 3,l_status,1);
   dbms_sql.define_column (l_cursor, 4,l_old_ext_dt);
   dbms_sql.define_column (l_cursor, 5,l_lease_change_id);

   l_rows   := dbms_sql.execute(l_cursor);

   LOOP

      l_count := dbms_sql.fetch_rows( l_cursor );
      EXIT WHEN l_count <> 1;

      dbms_sql.column_value (l_cursor, 1,l_lease_id);
      dbms_sql.column_value (l_cursor, 2,l_lease_status);
      dbms_sql.column_value (l_cursor, 3,l_status);
      dbms_sql.column_value (l_cursor, 4,l_old_ext_dt);
      dbms_sql.column_value (l_cursor, 5,l_lease_change_id);

      BEGIN

         l_total := l_total + 1;

         IF l_lease_status NOT IN ('MTM','HLD') THEN
            RAISE INVALID_LEASE_RECORD;

         ELSIF ( l_old_ext_dt > l_lease_ext_end_dt OR
                 l_old_ext_dt IS NULL) THEN
            RAISE INVALID_LEASE_RECORD;

         ELSIF l_status <> 'F' THEN
            RAISE INVALID_LEASE_RECORD;

         ELSIF l_lease_status IN ('MTM','HLD') AND
               l_old_ext_dt < l_lease_ext_end_dt AND
               l_status = 'F'
         THEN

            IF p_lease_option = 'A' THEN
               l_extend_ri := 'Y';
            END IF;

            create_amendment(
                      p_lease_id          => l_lease_id
                     ,p_lease_ext_end_dt  => l_lease_ext_end_dt
                     ,p_leaseChangeId     => l_lease_change_id);

            rollforward_tenancies(
                      p_lease_id          => l_lease_id
                     ,p_lease_ext_end_dt  => l_lease_ext_end_dt
                     ,p_old_ext_end_dt    => l_old_ext_dt);

            rollforward_terms (
                      p_lease_id          => l_lease_id
                     ,p_lease_ext_end_dt  => l_lease_ext_end_dt
                     ,p_extend_ri         => l_extend_ri );

            IF p_lease_option = 'A' THEN
               rollforward_var_rent (
                      p_lease_id          =>  l_lease_id
                     ,p_lease_ext_end_dt  =>  l_lease_ext_end_dt
                     ,p_old_ext_end_dt    =>  l_old_ext_dt
                     ,p_lease_change_id   =>  l_lease_change_id );
            END IF;

            print_output (
                      p_lease_id          =>  l_lease_id);

         END IF;

      EXCEPTION
         WHEN INVALID_LEASE_RECORD THEN
            pnp_debug_pkg.log(' invalid lease record ');
            l_fail := l_fail + 1;
      END;
   END LOOP;

   IF l_total <> 0 THEN
      l_success := l_total - l_fail;

      fnd_message.set_name('PN', 'PN_CAFM_SPACE_SUCCESS');
      fnd_message.set_token('SUCCESS', l_success);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

      fnd_message.set_name('PN', 'PN_CAFM_SPACE_FAILURE');
      fnd_message.set_token('FAILURE', l_fail);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

      fnd_message.set_name('PN', 'PN_CAFM_SPACE_TOTAL');
      fnd_message.set_token('TOTAL', l_total);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

   END IF;

   IF dbms_sql.is_open (l_cursor) THEN
      dbms_sql.close_cursor (l_cursor);
   END IF;

   pnp_debug_pkg.log('pn_mtm_rollforward_pkg.rollforward_leases +End+ (-)');
EXCEPTION
   WHEN INCORECT_LEASE_EXCEPTION THEN
      fnd_message.set_name ('PN', 'MISSING_SETUP_CONTEXT');
      errbuf := fnd_message.get;
      pnp_debug_pkg.put_log_msg (errbuf);
      retcode := 2;

   WHEN INCORRECT_EXTENSION_END_DATE THEN
      fnd_message.set_name ('PN', 'MISSING_SETUP_CONTEXT');
      errbuf := fnd_message.get;
      pnp_debug_pkg.put_log_msg (errbuf);
      retcode := 2;

   WHEN INCORRECT_LEASE_OPTION THEN
      fnd_message.set_name ('PN', 'MISSING_SETUP_CONTEXT');
      errbuf := fnd_message.get;
      pnp_debug_pkg.put_log_msg (errbuf);
      retcode := 2;

   WHEN INVALID_LEASE_RECORD THEN
      fnd_message.set_name ('PN', 'MISSING_SETUP_CONTEXT');
      errbuf := fnd_message.get;
      pnp_debug_pkg.put_log_msg (errbuf);
      retcode := 2;

   WHEN OTHERS THEN
      Errbuf  := SQLERRM;
      Retcode := 2;
      ROLLBACK;

END rollforward_leases;


-------------------------------------------------------------------------------
--  PROCEDURE  : CREATE_AMENDMENT
--  DESCRIPTION: Procedure to create amendment for rollforward.
--
--  19-OCT-06   Hareesha  o Created
-------------------------------------------------------------------------------
PROCEDURE CREATE_AMENDMENT( p_lease_id            NUMBER,
                            p_lease_ext_end_dt    DATE,
                            p_leaseChangeId   OUT NOCOPY NUMBER)
IS

   CURSOR get_lease_details (p_lease_id NUMBER) IS
      SELECT lease_num,
             responsible_user,
             GREATEST(lease_termination_date,lease_extension_end_date) old_ext_dt,
             SYSDATE,
             lease.org_id  org_id,
             lease_detail_id,
             expense_account_id,
             accrual_account_id,
             receivable_account_id,
             term_template_id,
             grouping_rule_id,
             lease_commencement_date,
             lease_termination_date,
             lease_execution_date,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15
      FROM pn_leases_all lease,pn_lease_details_all det
      WHERE lease.lease_id = p_lease_id
      AND   det.lease_id = lease.lease_id;

   l_rowid                    VARCHAR2(18) := NULL;
   l_leaseChangeId            NUMBER       := NULL;
   l_leaseChangeNumber        NUMBER       := NULL;
   l_leaseChangeName          VARCHAR2(50) ;
   l_lease_num                VARCHAR2(30);
   l_user_id                  NUMBER := NVL(fnd_profile.value ('USER_ID'), 0);
   l_last_updated_by          NUMBER := NVL(fnd_profile.value ('USER_ID'), 0);
   l_last_update_login        NUMBER := NVL(fnd_profile.value ('LOGIN_ID'),0);
   l_changeCommencementDate   DATE;
   l_changeTerminationdate    DATE;
   l_changeExecutionDate      DATE;
   l_responsibleUser          NUMBER;
   l_creationDate             DATE;
   l_org_id                   NUMBER;
   l_lease_detail_id          NUMBER;
   l_expense_account_id       NUMBER;
   l_accrual_account_id       NUMBER(15);
   l_receivable_account_id    NUMBER(15);
   l_term_template_id         NUMBER(15);
   l_grouping_rule_id         NUMBER(15);
   l_leaseCommencementDate    DATE;
   l_leaseTerminationDate     DATE;
   l_leaseExecutionDate       DATE;
   l_attribute_category       VARCHAR2(250);
   l_attribute1               VARCHAR2(250);
   l_attribute2               VARCHAR2(250);
   l_attribute3               VARCHAR2(250);
   l_attribute4               VARCHAR2(250);
   l_attribute5               VARCHAR2(250);
   l_attribute6               VARCHAR2(250);
   l_attribute7               VARCHAR2(250);
   l_attribute8               VARCHAR2(250);
   l_attribute9               VARCHAR2(250);
   l_attribute10              VARCHAR2(250);
   l_attribute11              VARCHAR2(250);
   l_attribute12              VARCHAR2(250);
   l_attribute13              VARCHAR2(250);
   l_attribute14              VARCHAR2(250);
   l_attribute15              VARCHAR2(250);

BEGIN

   pnp_debug_pkg.log('pn_mtm_rollforward_pkg.create_amendment +Start+ (+)');

   FOR rec IN get_lease_details( p_lease_id ) LOOP
      l_lease_num              := rec.lease_num;
      l_responsibleUser        := rec.responsible_user;
      l_changeCommencementDate := rec.old_ext_dt + 1;
      l_creationDate           := rec.sysdate;
      l_org_id                 := rec.org_id;
      l_lease_detail_id        := rec.lease_detail_id;
      l_expense_account_id     := rec.expense_account_id;
      l_accrual_account_id     := rec.accrual_account_id;
      l_receivable_account_id  := rec.receivable_account_id;
      l_term_template_id       := rec.term_template_id;
      l_grouping_rule_id       := rec.grouping_rule_id;
      l_leaseCommencementDate  := rec.lease_commencement_date;
      l_leaseTerminationDate   := rec.lease_termination_date;
      l_leaseExecutionDate     := rec.lease_execution_date;
      l_attribute_category     := rec.attribute_category ;
      l_attribute1             := rec.attribute1;
      l_attribute2             := rec.attribute2;
      l_attribute3             := rec.attribute3;
      l_attribute4             := rec.attribute4;
      l_attribute5             := rec.attribute5;
      l_attribute6             := rec.attribute6;
      l_attribute7             := rec.attribute7;
      l_attribute8             := rec.attribute8;
      l_attribute9             := rec.attribute9;
      l_attribute10            := rec.attribute10;
      l_attribute11            := rec.attribute11;
      l_attribute12            := rec.attribute12;
      l_attribute13            := rec.attribute13;
      l_attribute14            := rec.attribute14;
      l_attribute15            := rec.attribute15;

   END LOOP;

   l_leaseChangeName := 'Amendment to Lease '||l_lease_num;

   l_changeTerminationdate  := p_lease_ext_end_dt;
   l_changeExecutionDate    := l_changeCommencementDate;

   pn_lease_changes_pkg.Insert_Row
   (
      x_rowid                      => l_rowid
     ,x_lease_change_id            => l_leaseChangeId
     ,x_lease_id                   => p_lease_id
     ,x_lease_change_number        => l_leaseChangeNumber
     ,x_lease_change_name          => l_leaseChangeName
     ,x_responsible_user           => l_user_id
     ,x_change_commencement_date   => l_changeCommencementDate
     ,x_change_termination_date    => l_changeTerminationdate
     ,x_change_type_lookup_code    => 'AMEND'
     ,x_change_execution_date      => l_changeExecutionDate
     ,x_attribute_category         => l_attribute_category
     ,x_attribute1                 => l_attribute1
     ,x_attribute2                 => l_attribute2
     ,x_attribute3                 => l_attribute3
     ,x_attribute4                 => l_attribute4
     ,x_attribute5                 => l_attribute5
     ,x_attribute6                 => l_attribute6
     ,x_attribute7                 => l_attribute7
     ,x_attribute8                 => l_attribute8
     ,x_attribute9                 => l_attribute9
     ,x_attribute10                => l_attribute10
     ,x_attribute11                => l_attribute11
     ,x_attribute12                => l_attribute12
     ,x_attribute13                => l_attribute13
     ,x_attribute14                => l_attribute14
     ,x_attribute15                => l_attribute15
     ,x_abstracted_by_user         => l_responsibleUser
     ,x_creation_date              => l_creationDate
     ,x_created_by                 => l_user_id
     ,x_last_update_date           => l_creationDate
     ,x_last_updated_by            => l_last_updated_by
     ,x_last_update_login          => l_last_update_login
     ,x_org_id                     => l_org_id
     ,x_cutoff_date                => NULL
   );

   p_leaseChangeId := l_leaseChangeId;

   pn_lease_details_pkg.Update_Row
   (
      x_lease_detail_id            => l_lease_detail_id
     ,x_lease_change_id            => l_leaseChangeId
     ,x_lease_id                   => p_lease_id
     ,x_responsible_user           => l_user_id
     ,x_expense_account_id         => l_expense_account_id
     ,x_lease_commencement_date    => l_leaseCommencementDate
     ,x_lease_termination_date     => l_leaseTerminationDate
     ,x_lease_extension_end_date   => p_lease_ext_end_dt
     ,x_lease_execution_date       => l_leaseExecutionDate
     ,x_last_update_date           => l_creationDate
     ,x_last_updated_by            => l_last_updated_by
     ,x_last_update_login          => l_last_update_login
     ,x_accrual_account_id         => l_accrual_account_id
     ,x_receivable_account_id      => l_receivable_account_id
     ,x_term_template_id           => l_term_template_id
     ,x_grouping_rule_id           => l_grouping_rule_id
     ,x_attribute_category         => l_attribute_category
     ,x_attribute1                 => l_attribute1
     ,x_attribute2                 => l_attribute2
     ,x_attribute3                 => l_attribute3
     ,x_attribute4                 => l_attribute4
     ,x_attribute5                 => l_attribute5
     ,x_attribute6                 => l_attribute6
     ,x_attribute7                 => l_attribute7
     ,x_attribute8                 => l_attribute8
     ,x_attribute9                 => l_attribute9
     ,x_attribute10                => l_attribute10
     ,x_attribute11                => l_attribute11
     ,x_attribute12                => l_attribute12
     ,x_attribute13                => l_attribute13
     ,x_attribute14                => l_attribute14
     ,x_attribute15                => l_attribute15
   );

   pnp_debug_pkg.log('pn_mtm_rollforward_pkg.create_amendment +End+ (-)');

END create_amendment;


-------------------------------------------------------------------------------
--  PROCEDURE  : ROLLFORWARD_TENANCIES
--  DESCRIPTION: Procedure to rollforward the tenancies associated with the lease.
--
--  19-OCT-06   Hareesha  o Created
--  08-MAY-07   Hareesha  o Bug #6034970 Check for space conflics when
--                          auto-space-distribution is set to 'N', and display
--                          msg accordingly.
--  22-JAN-2010 kmaddi    o Bug#9059684. Modified cursor chk_conflicts
-------------------------------------------------------------------------------
PROCEDURE ROLLFORWARD_TENANCIES(p_lease_id         NUMBER,
                                p_lease_ext_end_dt  DATE,
                                p_old_ext_end_dt    DATE default NULL)
IS

   CURSOR get_expandable_tenancies( p_lease_id NUMBER,p_lease_ext_end_dt DATE) IS
      SELECT  pta.tenancy_id,
			  pta.location_id,
			  NVL(pta.occupancy_date,pta.estimated_occupancy_date) st_date,
			  pta.org_id
		FROM  pn_tenancies_all pta, pn_lease_details_all plda
		WHERE pta.lease_id = p_lease_id
		AND pta.lease_id = plda.lease_id
		AND pta.expiration_date = NVL(p_old_ext_end_dt, plda.lease_termination_date);

   CURSOR get_lease_class_code (p_lease_id NUMBER) IS
      SELECT lease_class_code
      FROM pn_leases_all
      WHERE lease_id = p_lease_id;

   CURSOR get_loc_type_code (p_location_id NUMBER) IS
      SELECT location_type_lookup_code
      FROM pn_locations_all
      WHERE location_id = p_location_id;

   CURSOR chk_conflicts(p_lease_id NUMBER,
                        p_ten_st_dt DATE,
                        p_ten_end_dt DATE,
                        p_location_id NUMBER)
   IS
      SELECT 'Y'
      FROM   DUAl
      WHERE  100 < (SELECT sum(allocated_area_pct)
                     FROM   pn_leases_all pnl,
                            pn_tenancies_all ten
                     WHERE  pnl.lease_class_code <> 'DIRECT'
                     AND    pnl.lease_id = ten.lease_id
                     AND    ten.location_id = p_location_id
                     AND    NVL(ten.estimated_occupancy_date, ten.occupancy_date)
                            <= p_ten_end_dt
                     AND    ten.expiration_date >= p_ten_st_dt
                    );

   l_lease_class_code VARCHAR2(30);
   l_loc_type_code VARCHAR2(30);

BEGIN
   pnp_debug_pkg.log('pn_mtm_rollforward_pkg.rollforward_tenancies +Start+ (+)');

   IF fnd_profile.value('PN_CHG_TEN_WHEN_LEASE_CHG') = 'Y' THEN

      <<outer_loop>>
      FOR rec IN get_expandable_tenancies(p_lease_id, p_lease_ext_end_dt) LOOP

         FOR rec2 IN get_lease_class_code( p_lease_id) LOOP
            l_lease_class_code := rec2.lease_class_code;
         END LOOP;

         IF NVL(pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION', rec.org_id),'N') = 'N'
         AND l_lease_class_code <> 'DIRECT'
         THEN
            FOR conflict_rec IN chk_conflicts(p_lease_id,
                                              rec.st_date,
                                              p_lease_ext_end_dt,
                                              rec.location_id)
            LOOP
               EXIT outer_loop;
            END LOOP;
         END IF;

         UPDATE pn_tenancies_all
         SET expiration_date    = p_lease_ext_end_dt
            ,fin_oblig_end_date = p_lease_ext_end_dt
         WHERE tenancy_id       = rec.tenancy_id;

         IF l_lease_class_code <> 'DIRECT' THEN
            UPDATE pn_space_assign_cust_all
            SET cust_assign_end_date = p_lease_ext_end_dt
               ,fin_oblig_end_date   = p_lease_ext_end_dt
            WHERE tenancy_id         = rec.tenancy_id;

            FOR rec3 IN get_loc_type_code(rec.location_id) LOOP
               l_loc_type_code := rec3.location_type_lookup_code;
            END LOOP;

            IF NVL(pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION', rec.org_id),'N') = 'Y'
            AND l_loc_type_code IN ('OFFICE', 'SECTION')
            THEN
                 PN_SPACE_ASSIGN_CUST_PKG.assignment_split(
                    p_location_id => rec.location_id,
                    p_start_date  => rec.st_date,
                    p_end_date    => p_lease_ext_end_dt);

            END IF;
         END IF;

      END LOOP outer_loop;
   END IF;

   pnp_debug_pkg.log('pn_mtm_rollforward_pkg.rollforward_tenancies +End+ (-)');

END ROLLFORWARD_TENANCIES;

-------------------------------------------------------------------------------
--  PROCEDURE  : ROLLFORWARD_VAR_RENT
--  DESCRIPTION: Procedure to rollforward the VR agreements associated
--               with the lease.
--
--  19-OCT-06   Hareesha  o Created
-------------------------------------------------------------------------------
PROCEDURE ROLLFORWARD_VAR_RENT( p_lease_id          NUMBER,
                                p_lease_ext_end_dt  DATE,
                                p_old_ext_end_dt    DATE,
                                p_lease_change_id   NUMBER)
IS

   l_requestId           NUMBER := NULL;
   l_lease_ext_dt_can    VARCHAR2(100) := fnd_date.date_to_canonical(p_lease_ext_end_dt);
   l_old_ext_dt_can      VARCHAR2(100) := fnd_date.date_to_canonical(p_old_ext_end_dt);

BEGIN
   pnp_debug_pkg.log('pn_mtm_rollforward_pkg.rollforward_var_rent +Start+ (+)');

   l_requestId := fnd_request.submit_request ( 'PN',
                                               'PNVREXCO',
                                               NULL,
                                               NULL,
                                               FALSE,
                                               p_lease_id, p_lease_change_id,
                                               l_old_ext_dt_can,l_lease_ext_dt_can,
                                               'EXP','Y','Y',chr(0),
                                               '',  '',  '',  '', '',  '',
                                               '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                               '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                               '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                               '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                               '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                               '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                               '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                               '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                               '',  '',  '',  '',  '',  ''
                                             );

   IF (l_requestId = 0 ) THEN
       fnd_message.set_name('PN', 'PN_SCHIT_CONC_FAIL');
       pnp_debug_pkg.put_log_msg(fnd_message.get);
   ELSE
      fnd_message.set_name ( 'PN', 'PN_REQUEST_SUBMITTED' );
      fnd_message.set_token ( 'REQUEST_ID', TO_CHAR(l_requestId), FALSE);
      pnp_debug_pkg.put_log_msg(fnd_message.get);
   END IF;

   pnp_debug_pkg.log('pn_mtm_rollforward_pkg.rollforward_var_rent +End+ (-)');

END ROLLFORWARD_VAR_RENT;


-------------------------------------------------------------------------------
--  PROCEDURE  : ROLLFORWARD_TERMS
--  DESCRIPTION: Procedure to rollforward the main lease terms and
--               RI if needed.
--
--  19-OCT-06   Hareesha  o Created
--  08-MAY-07   Hareesha  o Bug#6031123 Passed ten_trm_context as 'Y' to PNSCHITM
-------------------------------------------------------------------------------
PROCEDURE ROLLFORWARD_TERMS ( p_lease_id              NUMBER,
                              p_lease_ext_end_dt      DATE,
                              p_extend_ri             VARCHAR2)
IS
   l_requestId        NUMBER := NULL;

BEGIN
   pnp_debug_pkg.log('pn_mtm_rollforward_pkg.rollforward_terms +Start+ (+)');

   l_requestId := fnd_request.submit_request ( 'PN',
                                               'PNSCHITM',
                                                NULL,
                                                NULL,
                                                FALSE,
                                                p_lease_id,'ROLLOVER','MAIN',
                                                null, null, 'N', null, p_extend_ri,'Y',chr(0),
                                                '',  '',  '',  '',
                                                '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                                '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                                '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                                '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                                '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                                '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                                '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                                '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                                                '',  '',  '',  '',  '',  ''
                                  );

   IF (l_requestId = 0 ) THEN
      fnd_message.set_name('PN', 'PN_SCHIT_CONC_FAIL');
      pnp_debug_pkg.put_log_msg(fnd_message.get);
   ELSE
      fnd_message.set_name ( 'PN', 'PN_REQUEST_SUBMITTED' );
      fnd_message.set_token ( 'REQUEST_ID', TO_CHAR(l_requestId), FALSE);
      pnp_debug_pkg.put_log_msg(fnd_message.get);
   END IF;

   pnp_debug_pkg.log('pn_mtm_rollforward_pkg.rollforward_terms +End+ (-)');

END ROLLFORWARD_TERMS;


-------------------------------------------------------------------------------
--  PROCEDURE  : PRINT_OUTPUT
--  DESCRIPTION: Procedure to print output of Rollforward concurrent process
--
--  19-OCT-06   Hareesha  o Created
-------------------------------------------------------------------------------
PROCEDURE PRINT_OUTPUT  ( p_lease_id  NUMBER)
IS

   CURSOR get_lease_details( p_lease_id NUMBER) IS
      SELECT prop.property_name                          property_name,
             NVL(loc.building,NVL(loc.floor,loc.office)) location_name,
             lease.lease_num                             lease_num,
             lease_det.lease_termination_date            lease_termination_date,
             lease_det.lease_extension_end_date          lease_extension_end_date,
             /*SUM(NVL(terms.estimated_amount,terms.actual_amount))*/
             NULL                                        charge,
             ilease.index_lease_number                   index_rent_num,
             var.rent_num                                var_rent_num
      FROM  pn_leases_all         lease,
            pn_lease_details_all  lease_det,
            pn_tenancies_all      ten,
            pn_locations_all      loc,
            pn_properties_all     prop,
            pn_index_leases_all   ilease,
            pn_var_rents_all      var,
            pn_payment_terms_all  terms
      WHERE lease.lease_id     = p_lease_id
      AND   ten.primary_flag = 'Y'
      AND   ten.location_id  = loc.location_id
      AND   ten.occupancy_date <= loc.active_start_date
      AND   ten.expiration_date <= loc.active_end_date
      AND   lease.lease_id   = terms.lease_id
      AND   loc.property_id  = prop.property_id (+)
      AND   lease.lease_id   = ten.lease_id
      AND   lease.lease_id   = lease_det.lease_id
      AND   lease.lease_id   = ilease.lease_id (+)
      AND   lease.lease_id   = var.lease_id (+)
      ORDER BY property_name,
               location_name,
               lease_num,
               index_rent_num,
               var_rent_num;

   l_message    VARCHAR2(5000) := NULL;


BEGIN

   pnp_debug_pkg.log('pn_mtm_rollforward_pkg.print_output +Start+ (+)');

   fnd_message.set_name ('PN','PN_ROLFWD_PROP');
   l_message := fnd_message.get||'    ';
   fnd_message.set_name ('PN','PN_ROLFWD_LOC');
   l_message := l_message||fnd_message.get||'   ';
   fnd_message.set_name ('PN','PN_ROLFWD_LEASE_NUM');
   l_message := l_message||fnd_message.get||'  ';
   fnd_message.set_name ('PN','PN_ROLFWD_TRM_DATE');
   l_message := l_message||fnd_message.get||'  ';
   fnd_message.set_name ('PN','PN_ROLFWD_EXT_DATE');
   l_message := l_message||fnd_message.get||'  ';
   fnd_message.set_name ('PN','PN_ROLFWD_CHARGE');
   l_message := l_message||fnd_message.get||' ';
   fnd_message.set_name ('PN','PN_ROLFWD_INDEX_NUM');
   l_message := l_message||fnd_message.get||'  ';
   fnd_message.set_name ('PN','PN_ROLFWD_VAR_NUM');
   l_message := l_message||fnd_message.get||'  ';
   pnp_debug_pkg.put_log_msg(l_message);

   pnp_debug_pkg.put_log_msg
   ('==============  '
     ||' =============  '
     ||' ========= '
     ||' ====================== '
     ||' ======================== '
     ||' ========'
     ||' ================= '
     ||' =================== '
   );

   FOR rec IN get_lease_details (p_lease_id) LOOP

      pnp_debug_pkg.put_log_msg(rec.property_name || '             '
                               ||rec.location_name|| '             '
                               ||rec.lease_num    || '             '
                               ||TO_CHAR(rec.lease_termination_date) || '              '
                               ||TO_CHAR(rec.lease_extension_end_date)|| '             '
                               ||rec.charge ||'               '
                               ||rec.index_rent_num || '             '
                               ||rec.var_rent_num   || '             '
                               );

   END LOOP;

   pnp_debug_pkg.log('pn_mtm_rollforward_pkg.print_output +End+ (-)');

END PRINT_OUTPUT;


END PN_MTM_ROLLFORWARD_PKG;

/
