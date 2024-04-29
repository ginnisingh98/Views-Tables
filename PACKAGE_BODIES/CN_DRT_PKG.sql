--------------------------------------------------------
--  DDL for Package Body CN_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_DRT_PKG" AS
-- $Header: cndrtapib.pls 120.0.12010000.14 2018/07/20 09:05:36 rnagaraj noship $

  l_package     VARCHAR2(33) DEFAULT 'CN_DRT_PKG.';
  l_salesrep_id NUMBER;
  l_org_id      NUMBER;
  v_stmt        VARCHAR2(2000);


  PROCEDURE process_drc(
      p_person_id   IN NUMBER,
      p_entity_type IN VARCHAR2,
      p_salesrep_id IN NUMBER,
      p_org_id      IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type) IS

      l_count       NUMBER;
      l_ret_period  NUMBER;
      l_ret_date    DATE;

  BEGIN

    /* Check the Profile value CN_RECORD_RETENTION_PERIOD
    SELECT FND_PROFILE.VALUE_SPECIFIC('CN_RECORD_RETENTION_PERIOD',null,null,null,p_org_id,null)
    */
    SELECT NVL(FND_PROFILE.VALUE('CN_RECORD_RETENTION_PERIOD'),12000)
    INTO l_ret_period
    FROM dual;

    per_drt_pkg.write_log('Profile OIC: DRT Retention Period in Months (default 12000) is = '||l_ret_period,'25');

    IF ( NVL(l_ret_period,12000) < 2 ) THEN
      per_drt_pkg.add_to_results(person_id => p_person_id
                                ,entity_type => p_entity_type
                                ,status      => 'E'
                                ,msgcode     => 'CN_GDPR_DATA_RETENTION_PERIOD'
                                ,msgaplid    => 283
                                ,result_tbl  => result_tbl);
      RETURN;
    END IF;


    SELECT TRUNC(ADD_MONTHS(SYSDATE, -1*l_ret_period))
           INTO l_ret_date
           FROM DUAL;

    per_drt_pkg.write_log('Checking for Open Paysheets','30');
    l_count := 0;

    BEGIN
      /*  CN_GDPR_OPEN_PYSHTS constraint */
      SELECT 1 INTO l_count FROM DUAL
      WHERE EXISTS ( SELECT 1
                       FROM cn_payment_worksheets_all W,
                         cn_period_statuses_all prd,
                         cn_payruns_all prun
                       WHERE w.salesrep_id    = p_salesrep_id
                       AND w.org_id           = p_org_id
                       AND prun.pay_period_id = prd.period_id
                       AND prun.payrun_id     = w.payrun_id
                       AND prun.status        <> 'PAID'
                       AND prd.org_id         = p_org_id
                       AND w.quota_id      IS NULL
                       AND NVL(prd.end_date,SYSDATE) >= l_ret_date );
                       --  AND   prun.pay_group_id  = c_pay_group_id
                       --  AND (prd.end_date<= sysdate));

      IF ( l_count = 1 )  THEN
        per_drt_pkg.write_log('Paysheets are opened for '||p_person_id,'31');
        per_drt_pkg.add_to_results(person_id    => p_person_id
                                  ,entity_type  => p_entity_type
                                  ,status       => 'E'
                                  ,msgcode      => 'CN_GDPR_OPEN_PYSHTS_'||p_entity_type
                                  ,msgaplid     => 283
                                  ,result_tbl   => result_tbl);
        RETURN;
      END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN
        per_drt_pkg.write_log('Exception section - Paysheets are opened for '||p_person_id,'32');
        per_drt_pkg.write_log('Error Code/Message : '||sqlcode||' - '||SUBSTR(SQLERRM,1,25),'32');
        per_drt_pkg.add_to_results(person_id    => p_person_id
                                  ,entity_type  => p_entity_type
                                  ,status       => 'E'
                                  ,msgcode      => 'CN_GDPR_OPEN_PYSHTS_'||p_entity_type
                                  ,msgaplid     => 283
                                  ,result_tbl   => result_tbl);
        RETURN;

    END;

    per_drt_pkg.write_log('Checking for Plan Assignments ','40');
    l_count := 0;

    BEGIN

      /* CN_GDPR_PLAN_ASSGNMNTS constraint   */

      SELECT 1 INTO l_count FROM DUAL
      WHERE EXISTS ( SELECT 1
                       FROM cn_srp_plan_assigns_all
                       WHERE salesrep_id = p_salesrep_id
                       AND org_id        = p_org_id
                       AND NVL(end_date,SYSDATE)     >= l_ret_date  );

      IF ( l_count = 1 ) THEN
        per_drt_pkg.write_log('Compensation Plan is still assigned to '||p_person_id,'41');
        per_drt_pkg.add_to_results(person_id     => p_person_id
                                  ,entity_type   => p_entity_type
                                  ,status        => 'E'
                                  ,msgcode       => 'CN_GDPR_PLAN_ASSGNMNTS_'||p_entity_type
                                  ,msgaplid      => 283
                                  ,result_tbl    => result_tbl);
        RETURN;
      END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN
        per_drt_pkg.write_log('Exception section - Compensation Plan is still assigned to '||p_person_id,'42');
        per_drt_pkg.write_log('Error Code/Message : '||sqlcode||' - '||SUBSTR(SQLERRM,1,25),'42');
        per_drt_pkg.add_to_results(person_id     => p_person_id
                                  ,entity_type   => p_entity_type
                                  ,status        => 'E'
                                  ,msgcode       => 'CN_GDPR_PLAN_ASSGNMNTS_'||p_entity_type
                                  ,msgaplid      => 283
                                  ,result_tbl    => result_tbl);
        RETURN;

    END;

    per_drt_pkg.write_log('Checking for Territory Assignment ','50');
    l_count := 0;

    /* CN_GDPR_IN_SCA_TERR_ FND,HR,TCA  constraint */
    BEGIN

      SELECT 1 INTO l_count FROM DUAL
      WHERE EXISTS (SELECT 1
                      FROM jtf_rs_salesreps jrs,
                           jtf_terr_rsc_all jtra,
                           jtf_terr_all jtr,
                           jtf_terr_type_usgs_all jttu
                      WHERE jttu.source_id      = -1001
                      AND jtr.territory_type_id = jttu.terr_type_id
                      AND jtr.terr_id           = jtra.terr_id
                      AND jttu.org_id           = p_org_id
                      AND jrs.resource_id       = jtra.resource_id
                      AND jrs.salesrep_id       = p_salesrep_id
                      AND jtra.org_id           = p_org_id
                      AND NVL(jtra.end_date_active,SYSDATE) >= l_ret_date );

      IF ( l_count =  1 ) THEN
        per_drt_pkg.write_log('Territory is still assigned to '||p_person_id,'51');
        per_drt_pkg.add_to_results(person_id     => p_person_id
                                  ,entity_type   => p_entity_type
                                  ,status        => 'E'
                                  ,msgcode       => 'CN_GDPR_IN_SCA_TERR_'||p_entity_type
                                  ,msgaplid      => 283
                                  ,result_tbl    => result_tbl);
        RETURN;
      END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN
        per_drt_pkg.write_log('Exception section - Territory is still assigned to '||p_person_id,'52');
        per_drt_pkg.write_log('Error Code/Message : '||sqlcode||' - '||SUBSTR(SQLERRM,1,25),'52');
        per_drt_pkg.add_to_results(person_id     => p_person_id
                                  ,entity_type   => p_entity_type
                                  ,status        => 'E'
                                  ,msgcode       => 'CN_GDPR_IN_SCA_TERR_'||p_entity_type
                                  ,msgaplid      => 283
                                  ,result_tbl    => result_tbl);
        RETURN;

    END;

    per_drt_pkg.write_log('Checking for Carry over adjustments ','60');
    l_count := 0;

    BEGIN
      /* CN_GDPR_CARRY_OVER_ADJS  constraint */
      SELECT ((csp.balance2_bbd - csp.balance2_bbc) - ( csp.balance2_dtd - csp.balance2_ctd))
      INTO l_count
      FROM cn_srp_periods_all csp,
        cn_period_statuses_all cps
      WHERE csp.salesrep_id = p_salesrep_id
      AND csp.org_id        = p_org_id
      AND csp.org_id        = cps.org_id
      AND csp.period_id     = cps.period_id
      AND csp.quota_id     IS NULL
      AND SYSDATE BETWEEN cps.start_date AND cps.end_date;

      IF l_count <> 0 THEN
        per_drt_pkg.write_log('Found carry over adjustments of '||l_count||' for '||p_person_id,'61');
        per_drt_pkg.add_to_results(person_id      => p_person_id
                                  ,entity_type    => p_entity_type
                                  ,status         => 'W'
                                  ,msgcode        => 'CN_GDPR_CARRY_OVER_ADJS_'||p_entity_type
                                  ,msgaplid       => 283
                                  ,result_tbl     => result_tbl);
      END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN
        per_drt_pkg.write_log('Exception section - Found carry over adjustments for '||p_person_id,'62');
        per_drt_pkg.write_log('Error Code/Message : '||sqlcode||' - '||SUBSTR(SQLERRM,1,25),'62');
        per_drt_pkg.add_to_results(person_id      => p_person_id
                                  ,entity_type    => p_entity_type
                                  ,status         => 'W'
                                  ,msgcode        => 'CN_GDPR_CARRY_OVER_ADJS_'||p_entity_type
                                  ,msgaplid       => 283
                                  ,result_tbl     => result_tbl);
    END;

    per_drt_pkg.write_log('All constraint checks passed ','70');
    l_count := 0;


    /* **********************************************************
    -- the DRT tool will perform the masking based on the defined metadata - Please refer bug 27947986 for more details...........
    --  comment masking code start

    -- Mask the rows for the Salesrep

    BEGIN
    per_drt_pkg.write_log('Masking cn_comm_lines_api_all ','80');


    UPDATE cn_comm_lines_api_all cla
    SET cla.employee_number = '**********',
      cla.salesrep_number   = '**********'
    WHERE cla.org_id        = l_org_id
    AND cla.salesrep_id     = l_salesrep_id;

    per_drt_pkg.write_log('cn_comm_lines_api_all :'||sql%ROWCOUNT||' rows masked','82');

    EXCEPTION WHEN OTHERS THEN
      per_drt_pkg.write_log('Update cn_comm_lines_api_all EXCEPTION -'||SQLCODE,'81');
      per_drt_pkg.add_to_results(person_id     => p_person_id
                                ,entity_type   => p_entity_type
                                ,status        => 'E'
                                ,msgcode       => SQLCODE
                                ,msgaplid      => 283
                                ,result_tbl    => result_tbl);
      RETURN;

    END;

    l_count := 0;

    BEGIN

       SELECT 1
              INTO l_count
              FROM user_objects
              WHERE object_name = 'CN_ARC_COMM_LINES_API';


       IF ( l_count <> 0 ) THEN

         per_drt_pkg.write_log('Masking cn_arc_comm_lines_api ','90');

         v_stmt := 'UPDATE cn_arc_comm_lines_api cla  ';
         v_stmt := v_stmt || ' SET cla.employee_number = ''**********'',';
         v_stmt := v_stmt || ' cla.salesrep_number = ''**********'' ';
         v_stmt := v_stmt || ' WHERE cla.org_id = '||l_org_id;
         v_stmt := v_stmt || '   AND cla.salesrep_id = '||l_salesrep_id;

         EXECUTE IMMEDIATE v_stmt;

         -- UPDATE cn_arc_comm_lines_api cla
         -- SET cla.employee_number = '**********',
         --   cla.salesrep_number   = '**********'
         -- WHERE cla.org_id        = l_org_id
         -- AND cla.salesrep_id     = l_salesrep_id;
         --

         per_drt_pkg.write_log('cn_arc_comm_lines_api rows masked','92');


       END IF;

       EXCEPTION WHEN OTHERS THEN
         per_drt_pkg.write_log('Update cn_arc_comm_lines_api EXCEPTION -'||SQLCODE,'81');
         per_drt_pkg.add_to_results(person_id     => p_person_id
                                   ,entity_type   => p_entity_type
                                   ,status        => 'E'
                                   ,msgcode       => SQLCODE
                                   ,msgaplid      => 283
                                   ,result_tbl    => result_tbl);
         RETURN;
    END;

    --  comment masking code end
    **********************************************************   */


    per_drt_pkg.write_log('Incentive Compensation - '||p_entity_type||' constraint check  process completed. ','100');

    /*
    per_drt_pkg.add_to_results(person_id      => p_person_id
                              ,entity_type    => p_entity_type
                              ,status         => 'S'
                              ,msgcode        => ' -> '||p_entity_type
                              ,msgaplid       => 283
                              ,result_tbl     => result_tbl);
    */

  EXCEPTION
  WHEN OTHERS THEN
    per_drt_pkg.write_log('Incentive Compensation - '||p_entity_type||' constraint check process error with '||SQLCODE||' - '||SUBSTR(SQLERRM,1,64),'110');
    /*
    per_drt_pkg.add_to_results(person_id      => p_person_id
                              ,entity_type    => p_entity_type
                              ,status         => 'E'
                              ,msgcode        => SUBSTR(TO_CHAR(SQLCODE),1,25)
                              ,msgaplid       => 283
                              ,result_tbl     => result_tbl);
    */

  END process_drc;



  --
  --- Implement TCA Core specific DRC for Entity Type TCA
  --
  PROCEDURE cn_tca_drc(
        person_id  IN NUMBER ,
        result_tbl OUT nocopy per_drt_pkg.result_tbl_type
      ) IS

    l_proc      VARCHAR2(72) := l_package|| 'cn_tca_drc';

    CURSOR get_salesrep_id(c_person_id NUMBER) IS
           SELECT jrs.salesrep_id, jrs.org_id
             FROM jtf_rs_salesreps jrs,
		  jtf_rs_roles_b jrb,
	          jtf_rs_role_relations jrr
            WHERE jrb.role_type_code = 'SALES_COMP'
              AND jrr.role_resource_type = 'RS_INDIVIDUAL'
              AND jrr.role_id = jrb.role_id
              AND jrr.role_resource_id = jrs.resource_id
              AND jrs.resource_id  IN
              (
              ( SELECT RESOURCE_ID
                       FROM JTF_RS_RESOURCE_EXTNS
                       WHERE (CATEGORY = 'EMPLOYEE'
                       AND SOURCE_ID  IN
                       ( SELECT PERSON_ID FROM PER_ALL_PEOPLE_F WHERE PARTY_ID = c_person_id ) ) )
              UNION
              ( SELECT RESOURCE_ID
                       FROM JTF_RS_RESOURCE_EXTNS
                       WHERE CATEGORY = 'PARTY'
                       AND SOURCE_ID  = c_person_id )
              UNION
              ( SELECT RESOURCE_ID
                       FROM JTF_RS_RESOURCE_EXTNS
                       WHERE (CATEGORY = 'SUPPLIER_CONTACT'
                       AND SOURCE_ID  IN
                         ( SELECT VENDOR_CONTACT_ID FROM PO_VENDOR_CONTACTS PVC
                           WHERE PER_PARTY_ID = c_person_id ) ) )
              UNION
              (  SELECT RESOURCE_ID
                        FROM JTF_RS_RESOURCE_EXTNS
                        WHERE (CATEGORY = 'PARTNER'
                        AND SOURCE_ID  IN
                        ( SELECT PARTY_ID FROM JTF_RS_PARTNERS_VL JP
                          WHERE JP.PARTY_ID = c_person_id ) ) )
              );

    BEGIN

      -- .....
      per_drt_pkg.write_log ('Entering:' || l_package||'cn_tca_drc','10');
      per_drt_pkg.write_log ('person_id: '|| person_id,'20');

      --
      ---- Check DRC rule# 1

      FOR c_rep IN get_salesrep_id(person_id) LOOP
         l_salesrep_id := c_rep.salesrep_id;
         l_org_id      := c_rep.org_id;
         process_drc(person_id,'TCA', l_salesrep_id,l_org_id,result_tbl);
       END LOOP;

    END cn_tca_drc;



  --
  --- Implement HR Core specific DRC for Entity Type HR
  --
    PROCEDURE cn_hr_drc(
          person_id IN  NUMBER ,
          result_tbl  OUT NOCOPY per_drt_pkg.result_tbl_type
          ) AS

    CURSOR get_salesrep_id (c_person_id NUMBER) IS
    SELECT salesrep_id, org_id
      FROM jtf_rs_salesreps jrs
     WHERE jrs.salesrep_id IN (
             SELECT jrs1.salesrep_id
               FROM jtf_rs_salesreps jrs1,
                    jtf_rs_resource_extns jre,
		    jtf_rs_roles_b jrb,
	            jtf_rs_role_relations jrr
		WHERE jrb.role_type_code = 'SALES_COMP'
		AND jrr.role_resource_type = 'RS_INDIVIDUAL'
		AND jrr.role_id = jrb.role_id
		AND jrr.role_resource_id = jre.resource_id
		AND jre.resource_id = jrs1.resource_id
		AND jre.category = 'EMPLOYEE'
		AND jre.source_id IN ( SELECT person_id
                                         FROM per_all_people_f
                                        WHERE person_id = c_person_id) );

    BEGIN

      -- .....

      -- .... As per bug 27947986 - the HR employee will certainly have a tca - party_id;
      -- .... so it becomes redundant to perform the same set of constraint check using person id and party id
      -- .....henceforth this code is stubbed.......

      per_drt_pkg.write_log ('Entering:' || l_package||'cn_hr_drc','10');
      per_drt_pkg.write_log ('person_id: '|| person_id,'20');

      per_drt_pkg.write_log('Incentive Compensation - '||' HR '||' constraint check process completed. ','100');

      /*
      per_drt_pkg.add_to_results(person_id      => person_id
                              ,entity_type    => 'HR'
                              ,status         => 'S'
                              ,msgcode        => ' -> '||'HR'
                              ,msgaplid       => 283
                              ,result_tbl     => result_tbl);
      */

      RETURN;


      --
      ---- Check DRC rule# 1
      -- FOR c_rep IN get_salesrep_id(person_id) LOOP
      --    l_salesrep_id := c_rep.salesrep_id;
      --    l_org_id := c_rep.org_id;
      --    process_drc(person_id,'HR', l_salesrep_id,l_org_id,result_tbl);
      -- END LOOP;

    END cn_hr_drc;


  --
  --- Implement FND Core specific DRC for Entity Type FND
  --
  PROCEDURE cn_fnd_drc(
          person_id IN  NUMBER ,
          result_tbl  OUT NOCOPY per_drt_pkg.result_tbl_type ) AS

    CURSOR get_salesrep_id (c_person_id NUMBER) IS
    SELECT salesrep_id, org_id
      FROM jtf_rs_salesreps jrs
     WHERE jrs.salesrep_id IN (
              SELECT jrs1.salesrep_id
                FROM jtf_rs_salesreps jrs1,
                     jtf_rs_resource_extns jre,
		     jtf_rs_roles_b jrb,
	             jtf_rs_role_relations jrr
              WHERE jrb.role_type_code = 'SALES_COMP'
                AND jrr.role_resource_type = 'RS_INDIVIDUAL'
                AND jrr.role_id = jrb.role_id
                AND jrr.role_resource_id = jre.resource_id
                AND jre.resource_id = jrs1.resource_id
                AND ( ( jre.category = 'EMPLOYEE'
		           AND jre.source_id IN ( SELECT person_id
					            FROM per_all_people_f p, fnd_user f
                                                   WHERE (p.person_id = f.employee_id
                                                          OR p.party_id = f.person_party_id)
                                                     AND f.user_id = c_person_id) )
                   OR ( jre.category = 'PARTY'
			   AND jre.source_id IN ( SELECT f.person_party_id
                                                    FROM fnd_user f
                                                   WHERE f.user_id = c_person_id ) )
                   OR ( jre.category = 'PARTNER'
                           AND jre.source_id IN (SELECT party_id
                                                   FROM jtf_rs_partners_vl, fnd_user f
                                                  WHERE party_id = f.person_party_id
                                                    AND f.user_id = c_person_id) )
                   OR ( jre.category = 'SUPPLIER_CONTACT'
                           AND jre.source_id IN ( SELECT vendor_contact_id
                                                    FROM po_vendor_contacts pvc,
                                                         po_vendors pv,
                                                         fnd_user f
                                                   WHERE pvc.vendor_id = pv.vendor_id
                                                     AND pv.party_id = f.person_party_id
                                                     AND f.user_id = c_person_id)
                      )));

  BEGIN

      -- .....
      per_drt_pkg.write_log ('Entering:' || l_package||'cn_fnd_drc','10');
      per_drt_pkg.write_log ('person_id: '|| person_id,'20');

      -- .... As per bug 27947986 - the HR employee will certainly have a tca - party_id, and there is no logical relationship
      -- between fnd user to the salesrep_id via the HR/TCA entity. So the call to process_drc is stubbed.


      per_drt_pkg.write_log('Incentive Compensation - '||' FND '||' constraint check process completed. ','100');

      /*
      per_drt_pkg.add_to_results(person_id      => person_id
                              ,entity_type    => 'FND'
                              ,status         => 'S'
                              ,msgcode        => ' -> '||'FND'
                              ,msgaplid       => 283
                              ,result_tbl     => result_tbl);
      */

    RETURN;

      --
      ---- Check DRC rule# 1
      -- FOR c_rep IN get_salesrep_id(person_id) LOOP
      --   l_salesrep_id := c_rep.salesrep_id;
      --   l_org_id := c_rep.org_id;
      --   process_drc(person_id,'FND', l_salesrep_id,l_org_id,result_tbl);
      -- END LOOP;

  END cn_fnd_drc;


END cn_drt_pkg;

/
