--------------------------------------------------------
--  DDL for Package Body OZF_ACTIVITY_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACTIVITY_DENORM_PVT" AS
/* $Header: ozfvacdb.pls 120.4.12000000.2 2007/04/16 08:01:38 kdass ship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='OZF_ACTIVITY_DENORM_PVT';

PROCEDURE prepare_customer_full_load
IS

--  CURSOR c_customer_indexes IS
--  SELECT index_name
--    FROM all_indexes
--   WHERE table_name = 'OZF_ACTIVITY_CUSTOMERS'
--     AND table_owner = 'OZF';

BEGIN

    EXECUTE IMMEDIATE 'ALTER TABLE ozf_activity_customers PARALLEL';
--    FOR k IN c_customer_indexes LOOP
--      EXECUTE IMMEDIATE 'DROP INDEX ozf.' || k.index_name;
--    END LOOP;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ozf_activity_customers_temp';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ozf_activity_customers';

END;

PROCEDURE prepare_product_full_load
IS

--  CURSOR c_product_indexes IS
--  SELECT index_name
--    FROM all_indexes
--   WHERE table_name = 'OZF_ACTIVITY_PRODUCTS'
--     AND table_owner = 'OZF';

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE ozf_activity_products PARALLEL';
--    FOR k IN c_product_indexes LOOP
--      EXECUTE IMMEDIATE 'DROP INDEX ozf.' || k.index_name;
--    END LOOP;
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ozf_activity_products_temp';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ozf_activity_products';

END;

PROCEDURE create_customer_indexes

IS

  l_index_tablespace  VARCHAR2(100);

BEGIN

    EXECUTE IMMEDIATE
            'CREATE INDEX ozf_activity_customers_n1 ON ozf_activity_customers(party_id) TABLESPACE '
                      || l_index_tablespace
                      || ' COMPUTE STATISTICS';

    EXECUTE IMMEDIATE
            'CREATE INDEX ozf_activity_customers_n2 ON ozf_activity_customers(site_use_id) TABLESPACE '
                      || l_index_tablespace
                      || ' COMPUTE STATISTICS';

    EXECUTE IMMEDIATE
            'CREATE INDEX ozf_activity_customers_n4 ON ozf_activity_customers(object_id) TABLESPACE '
                      || l_index_tablespace
                      || ' COMPUTE STATISTICS';
    EXECUTE IMMEDIATE
            'CREATE INDEX ozf_activity_customers_n5 ON ozf_activity_customers(object_id,party_id) TABLESPACE '
                      || l_index_tablespace
                      || ' COMPUTE STATISTICS';

END;

PROCEDURE create_product_indexes

IS
  l_index_tablespace  VARCHAR2(100);
BEGIN

    EXECUTE IMMEDIATE
            'CREATE INDEX ozf_activity_products_n1 ON ozf_activity_products(item,item_type) TABLESPACE '
                      || l_index_tablespace
                      || ' COMPUTE STATISTICS';
    EXECUTE IMMEDIATE
            'CREATE INDEX ozf_activity_products_n2 ON ozf_activity_products(object_id) TABLESPACE '
                      || l_index_tablespace
                      || ' COMPUTE STATISTICS';
    EXECUTE IMMEDIATE
            'CREATE INDEX ozf_activity_products_n3 ON ozf_activity_products(object_id,item,item_type) TABLESPACE '
                      || l_index_tablespace
                      || ' COMPUTE STATISTICS';

END;


PROCEDURE refresh_denorm(
  ERRBUF           OUT NOCOPY VARCHAR2,
  RETCODE          OUT NOCOPY VARCHAR2,
  p_increment_flag IN  VARCHAR2 := 'N',
  p_offer_id       IN  NUMBER
)
IS
  CURSOR c_app_id IS
  SELECT application_id
    FROM fnd_application
   WHERE application_short_name='OZF';

  CURSOR get_conc_program_id(l_app_id NUMBER) IS
  SELECT concurrent_program_id
   FROM fnd_concurrent_programs
  WHERE application_id = l_app_id
    AND concurrent_program_name = 'OZFOEPD';

  CURSOR c_get_latest_comp_date(l_conc_program_id NUMBER, l_app_id NUMBER) IS
  SELECT max(actual_completion_date)
    FROM fnd_concurrent_requests
   WHERE program_application_id = l_app_id
     AND concurrent_program_id =  l_conc_program_id
     --16-APR-2007 kdass added for bug 5975207
     AND (argument2 = NVL(p_offer_id,0) OR argument2 IS NULL)
     AND status_code = 'C'
     AND phase_code = 'C';

  l_conc_program_id   NUMBER;
  l_app_id            NUMBER;
  l_latest_comp_date  DATE;
  x_return_status     VARCHAR2(1);
  l_status            VARCHAR2(5);
  l_industry          VARCHAR2(5);
  l_schema            VARCHAR2(30);
  l_return            BOOLEAN;


BEGIN

   OPEN c_app_id;
   FETCH c_app_id INTO l_app_id;
   CLOSE c_app_id;

   OPEN get_conc_program_id(l_app_id);
   FETCH get_conc_program_id INTO l_conc_program_id;
   CLOSE get_conc_program_id;

   OPEN c_get_latest_comp_date(l_conc_program_id, l_app_id);
   FETCH c_get_latest_comp_date INTO l_latest_comp_date;
   CLOSE c_get_latest_comp_date;

   ozf_utility_pvt.write_conc_log('-- Last Refresh Date is : ' || l_latest_comp_date );
   ozf_utility_pvt.write_conc_log('-- Increment Flag is    : ' || p_increment_flag );
   ozf_utility_pvt.write_conc_log('-- Start refresh offers --');

   l_return  := fnd_installation.get_app_info('OZF', l_status, l_industry, l_schema);

   ozf_utility_pvt.write_conc_log('-- After getting schema name --');
   ozf_utility_pvt.write_conc_log('-- After getting schema name --' || l_schema );

   if p_increment_flag = 'N' then
      EXECUTE IMMEDIATE 'ALTER table '||l_schema||'.ozf_activity_products_temp NOLOGGING';
      EXECUTE IMMEDIATE 'ALTER table '||l_schema||'.ozf_activity_customers_temp NOLOGGING';
   end if;

   ozf_utility_pvt.write_conc_log('-- After altering  --');

   if p_increment_flag = 'N' then
      EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.ozf_activity_products_temp';
      EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.ozf_activity_customers_temp';
   end if;

   ozf_utility_pvt.write_conc_log('-- After truncating --');

   OZF_OFFR_ELIG_PROD_DENORM_PVT.refresh_offers(
           ERRBUF,
           RETCODE,
           x_return_status,
           p_increment_flag,
           NVL(l_latest_comp_date, TO_DATE('01/01/1952','MM/DD/YYYY')),
           p_offer_id
           );

   IF    x_return_status = FND_API.g_ret_sts_error
   THEN
        RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
   END IF;

   ozf_utility_pvt.write_conc_log('-- End refresh Offers --');
   IF p_offer_id IS NULL THEN
      ozf_utility_pvt.write_conc_log('-- Start refresh schedules --');
      OZF_SCHEDULE_DENORM_PVT.refresh_schedules(
           ERRBUF,
           RETCODE,
           x_return_status,
           p_increment_flag,
           NVL(l_latest_comp_date, TO_DATE('01/01/1952','MM/DD/YYYY'))
           );
     ozf_utility_pvt.write_conc_log('-- End refresh schedules --');


     IF    x_return_status = FND_API.g_ret_sts_error
     THEN
       RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
     END IF;
   END IF;


  EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
      ozf_utility_pvt.write_conc_log('-- Unexpected Error:  --'||ERRBUF);

    WHEN OTHERS THEN
      ozf_utility_pvt.write_conc_log('-- Error:  --'||ERRBUF);

END;

END OZF_ACTIVITY_DENORM_PVT;

/
