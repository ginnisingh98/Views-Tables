--------------------------------------------------------
--  DDL for Package Body OKE_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DRT_PKG" AS
/* $Header: okedrtapib.pls 120.0.12010000.3 2018/04/26 09:58:19 skuchima noship $ */

  g_debug         CONSTANT VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_pkg_name      CONSTANT VARCHAR2(30) := 'OKE_DRT_PKG';
  g_module_prefix CONSTANT VARCHAR2(50) := 'oke.plsql.' || g_pkg_name || '.';

 procedure print_log(p_module varchar2, p_message varchar2) is
   begin
       if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
           if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
               fnd_log.string(log_level => fnd_log.level_statement,
                               module    => p_module,
                               message   => p_message);
           end if;
       end if;
   end;
  -- DRC function for person type : HR
  -- Does validation if passed in HR person can be masked by validating all
  -- rules and return 'S' for Success, 'W' for Warning and 'E' for Error

    PROCEDURE oke_hr_drc (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy PER_DRT_PKG.RESULT_TBL_TYPE
    ) IS

    l_cnt      NUMBER       := 0;
    l_cnt1      NUMBER       := 0;
    l_cnt2      NUMBER       :=0;
    L_CNT3      NUMBER       :=0;
    l_api_name VARCHAR2(30) := 'oke_hr_drc';


    BEGIN
    print_log( g_module_prefix || l_api_name, 'Start');
    print_log( g_module_prefix || l_api_name, ' Check for user in Project Contracts');

     select count(*)
    into   l_cnt
    FROM PA_PROJECT_PARTIES PP , PA_PROJECT_ROLE_TYPES PR , OKC_K_HEADERS_all_B KH , PER_ALL_PEOPLE_F EMP,okc_statuses_b sts
     WHERE PR.PROJECT_ROLE_ID = PP.PROJECT_ROLE_ID AND PP.OBJECT_TYPE = 'OKE_K_HEADERS'
     AND PP.OBJECT_ID = KH.ID
     AND PP.RESOURCE_TYPE_ID = 101
     AND EMP.PERSON_ID = PP.RESOURCE_SOURCE_ID
     AND emp.person_id = p_person_id
     AND Trunc(PP.CREATION_DATE) BETWEEN EMP.EFFECTIVE_START_DATE AND EMP.EFFECTIVE_END_DATE
     AND kh.sts_code=sts.code
     AND sts.ste_code NOT IN ('EXPIRED','CANCELLED','TERMINATED');




    print_log( g_module_prefix || l_api_name, ' Count for user in Project Contracts :'||l_cnt);

    IF(l_cnt > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'HR',
            status        => 'E',
            msgcode       => 'OKE_DRT_K_EXIST_FOR_USER',
            msgaplid      => 777,
            result_tbl    => result_tbl
        );
    END IF;

    print_log( g_module_prefix || l_api_name, ' Check for user in open Change Requests');


    select count(*)
    into   l_cnt1
    FROM OKE_CHG_REQUESTS_V WHERE chg_status_TYPE_code IN ('ENTERED','SUBMITTED') AND REQUESTED_by_PERSON_ID=p_person_id;

    print_log( g_module_prefix || l_api_name, ' Count for user in Open Change Requests :'||l_cnt1);

    IF(l_cnt1                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'HR',
            status        => 'E',
            msgcode       => 'OKE_DRT_CHG_REQ_EXIST_FOR_USER',
            msgaplid      => 777,
            result_tbl    => result_tbl
        );
    END IF;

    print_log( g_module_prefix || l_api_name, ' Check for user in Funding Workbench');

  /*Administrator Id is not available in 12.2.3 .Check before validating*/

   declare

   l_stmnt VARCHAR2(6000):= 'SELECT Count(*) ' ||
      ' FROM OKE_K_FUNDING_SOURCES okefs ,okc_k_headers_all_b okh,okc_statuses_b sts '||
       'WHERE okefs.administrator_id= :p_person_id '||
      ' AND okefs.object_type=''OKE_K_HEADERS'' '||
      ' AND  okh.id=okefs.object_id AND okh.sts_code=sts.code '||
      ' AND sts.ste_code NOT IN (''EXPIRED'',''CANCELLED'',''TERMINATED'') and rownum=1';

    BEGIN

        FOR rec IN ( SELECT column_name
                       FROM sys.all_tab_columns
                      WHERE table_name = upper('OKE_K_FUNDING_SOURCES')
                        AND column_name = upper('administrator_id')
                        AND ROWNUM = 1)
        LOOP
           EXECUTE IMMEDIATE l_stmnt INTO l_cnt2 USING p_person_id;
        END LOOP;
    print_log( g_module_prefix || l_api_name, ' Count for user in Funding Workbench :'||l_cnt2);

    IF(l_cnt2                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'HR',
            status        => 'E',
            msgcode       => 'OKE_DRT_FUND_EXIST_FOR_USER',
            msgaplid      => 777,
            result_tbl    => result_tbl
        );
    END IF;
    END;


    print_log( g_module_prefix || l_api_name, ' Check for user in Communication Actions setup');

    SELECT Count(*) INTO l_cnt3
    FROM OKE_COMM_ACTIONS_b WHERE owner_id= p_person_id
    AND Trunc(SYSDATE) BETWEEN Nvl(start_date_active,Trunc(SYSDATE)) AND Nvl(end_date_active,Trunc(SYSDATE)) ;

     print_log( g_module_prefix || l_api_name, ' Count for user in Communication Actions setup :'||l_cnt3);

    IF(l_cnt3                              > 0) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'HR',
            status        => 'E',
            msgcode       => 'OKE_DRT_COMM_EXIST_FOR_USER',
            msgaplid      => 777,
            result_tbl    => result_tbl
        );
    END IF;




    -- if no warning/errors so far, record success to process_tbl
     IF ( result_tbl.count < 1 ) THEN
        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'HR',
            status        => 'S',
            msgcode       => NULL,
            msgaplid      => 777,
            result_tbl    => result_tbl
        );
     END IF;

     print_log( g_module_prefix || l_api_name, 'End');

EXCEPTION
    WHEN OTHERS THEN
        IF   ( g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level )   THEN
            fnd_log.string(
                fnd_log.level_procedure,
                g_module_prefix || l_api_name,
                'Exception : sqlcode :'
                 || sqlcode
                 || ' Error Message : '
                 || sqlerrm
            );
        END IF;

        per_drt_pkg.add_to_results(
            person_id     => p_person_id,
            entity_type   => 'HR',
            status        => 'E',
            msgcode       => 'OKE_DRT_DRC_UNEXPECTED',
            msgaplid      => 777,
            result_tbl    => result_tbl
        );
    END oke_hr_drc;

END oke_drt_pkg;

/
