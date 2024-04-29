--------------------------------------------------------
--  DDL for Package Body MSC_CL_POST_PUBLISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_POST_PUBLISH" AS -- body
/* $Header: MSCXPODB.pls 120.0 2005/05/25 19:06:29 appldev noship $ */

l_site_string varchar2(2000) := NULL;
v_sql_stmt varchar2(4000);

CURSOR excepSummary IS
select plan_id,
	   inventory_item_id,
	   company_id,
	   company_site_id,
	   exception_group,
	   exception_type,
	   count(*)
from   msc_x_exception_details
where  plan_id = -1
and    exception_group IN (1,2,4,6,7,8)
group by plan_id,
	     inventory_item_id,
		 company_id,
		 company_site_id,
		 exception_group,
		 exception_type;

a_plan_id	number_arr;
a_inventory_item_id	number_arr;
a_company_id	number_arr;
a_company_site_id	number_arr;
a_exception_group	number_arr;
a_exception_type	number_arr;
a_count				number_arr;

PROCEDURE LOG_MESSAGE( pBUFF                     IN  VARCHAR2)
IS
BEGIN

  IF fnd_global.conc_request_id > 0 THEN   -- concurrent program

      FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);

  ELSE

       --dbms_output.put_line(pBUFF);
       null;

  END IF;

END LOG_MESSAGE;

PROCEDURE UPDATE_EXCEPTION_SUMMARY(p_summary_status OUT NOCOPY NUMBER) IS
BEGIN

  BEGIN

      OPEN excepSummary;

      FETCH excepSummary BULK COLLECT INTO
          a_plan_id,
          a_inventory_item_id,
          a_company_id,
          a_company_site_id,
          a_exception_group,
          a_exception_type,
          a_count;

       CLOSE excepSummary;

   EXCEPTION WHEN OTHERS THEN
       LOG_MESSAGE('Delete Exceptions : Error while fetching exception summary');
       LOG_MESSAGE(SQLERRM);
       p_summary_status := G_ERROR;
       ROLLBACK;
       RETURN;
   END;

   IF a_plan_id.COUNT > 0 THEN

       LOG_MESSAGE('Updated Exception Summary - '||a_plan_id.COUNT);

       BEGIN

           FORALL i in 1..a_plan_id.COUNT

               update msc_item_exceptions
               set  exception_count = a_count(i)
               where plan_id = a_plan_id(i)
               and   company_id = a_company_id(i)
               and   company_site_id = a_company_site_id(i)
               and   inventory_item_id = a_inventory_item_id(i)
               and   exception_type = a_exception_type(i)
               and   exception_group = a_exception_group(i)
               and   version = 0;

               COMMIT;

       EXCEPTION WHEN OTHERS THEN
           LOG_MESSAGE('Delete Exceptions : Error while updating Exception Summary');
           LOG_MESSAGE(SQLERRM);
           p_summary_status := G_ERROR;
           ROLLBACK;
           RETURN;
       END;

   END IF;

   p_summary_status := G_SUCCESS;

END UPDATE_EXCEPTION_SUMMARY;


--=====================================================
-- This is main type of procedure in this package body.
--=====================================================

PROCEDURE POST_CLEANUP(p_org_str IN VARCHAR2,
					   p_lrtype IN VARCHAR2,
                       p_status	OUT NOCOPY NUMBER) IS
l_summary_status NUMBER;
BEGIN

LOG_MESSAGE('Exception Deletion started');
LOG_MESSAGE('==========================');

IF (p_lrtype = 'C') THEN

l_site_string := p_org_str;

--======================================
-- Step 1. Delete OEM related Exceptions
--======================================

	v_sql_stmt := null;

	BEGIN

	    v_sql_stmt :=
		' delete msc_x_exception_details '
	    ||' where exception_type  '|| G_EXCEP_TYPES
	    ||' and exception_group  '|| G_EXCEP_GROUPS
	    ||' and company_id = 1 '
	    ||' and company_site_id  '|| l_site_string
	    ||' and plan_id = -1 ';

		EXECUTE IMMEDIATE v_sql_stmt;

		LOG_MESSAGE('OEM side Exceptions - '||SQL%ROWCOUNT);

	EXCEPTION WHEN OTHERS THEN
	    LOG_MESSAGE('Error while deleting exceptions in which OEM is Exception owner company');
		LOG_MESSAGE(SQLERRM);
		p_status := G_ERROR;
		RETURN;
	END;


--===========================================
-- Step 2. Delete Customer related Exceptions
--===========================================

	v_sql_stmt := null;

    BEGIN

        v_sql_stmt :=
	    ' delete msc_x_exception_details '
	    ||' where exception_type '|| G_EXCEP_TYPES
	    ||' and exception_group '|| G_EXCEP_GROUPS
	    ||' and customer_id = 1 '
	    ||' and customer_site_id '||l_site_string
	    ||' and plan_id = -1';

		EXECUTE IMMEDIATE v_sql_stmt;

		COMMIT;

		LOG_MESSAGE('Customer side Exceptions - '||SQL%ROWCOUNT);

    EXCEPTION WHEN OTHERS THEN
		LOG_MESSAGE('Error while deleting exceptions in which OEM is Customer');
		LOG_MESSAGE(SQLERRM);
		p_status := G_ERROR;
		ROLLBACK;
		RETURN;
	END;


--===========================================
-- Step 3. Delete Supplier related Exceptions
--===========================================

	v_sql_stmt := null;

    BEGIN

	    v_sql_stmt :=
    	' delete msc_x_exception_details '
	    ||' where exception_type '|| G_EXCEP_TYPES
	    ||' and exception_group '|| G_EXCEP_GROUPS
	    ||' and supplier_id = 1 '
	    ||' and supplier_site_id '|| l_site_string
		||' and plan_id = -1';

		EXECUTE IMMEDIATE v_sql_stmt;

		COMMIT;

		LOG_MESSAGE('Supplier site Exceptions - '||SQL%ROWCOUNT);

	EXCEPTION WHEN OTHERS THEN
		LOG_MESSAGE('Error while deleting exceptions in which OEM is Supplier');
		LOG_MESSAGE(SQLERRM);
		p_status := G_ERROR;
		ROLLBACK;
		RETURN;
	END;

--==================================
-- Step 4. Delete Exception Headers
--==================================

   BEGIN

   delete msc_item_exceptions mie
   where
   plan_id = -1
   and exception_group in (1,2,4,6,7,8)
   and not exists( select 1
				   from msc_x_exception_details med
				   where med.company_id = mie.company_id
				   and   med.company_site_id = mie.company_site_id
				   and   med.plan_id = mie.plan_id
				   and   med.plan_id = -1
				   and   med.inventory_item_id = mie.inventory_item_id
				   and   med.exception_type = mie.exception_type
				   and   med.exception_group = mie.exception_group);

    COMMIT;


	EXCEPTION WHEN OTHERS THEN
		LOG_MESSAGE('Error while deleting msc_item_exceptions');
		LOG_MESSAGE(SQLERRM);
		p_status := G_ERROR;
		ROLLBACK;
		RETURN;
    END;

--==================================
-- Step 4. Update Exception Headers
--==================================

  BEGIN

      OPEN excepSummary;

      FETCH excepSummary BULK COLLECT INTO
	      a_plan_id,
	      a_inventory_item_id,
	      a_company_id,
	      a_company_site_id,
	      a_exception_group,
	      a_exception_type,
	      a_count;

       CLOSE excepSummary;

   EXCEPTION WHEN OTHERS THEN
	   LOG_MESSAGE('Delete Exceptions : Error while fetching exception summary');
	   LOG_MESSAGE(SQLERRM);
	   p_status := G_ERROR;
	   ROLLBACK;
	   RETURN;
   END;

   IF a_plan_id.COUNT > 0 THEN

	   LOG_MESSAGE('Updated Exception Summary - '||a_plan_id.COUNT);

	   BEGIN

           FORALL i in 1..a_plan_id.COUNT

               update msc_item_exceptions
               set  exception_count = a_count(i)
			   where plan_id = a_plan_id(i)
			   and   company_id = a_company_id(i)
			   and   company_site_id = a_company_site_id(i)
			   and   inventory_item_id = a_inventory_item_id(i)
			   and   exception_type = a_exception_type(i)
			   and   exception_group = a_exception_group(i)
			   and	 version = 0;

			   COMMIT;

	   EXCEPTION WHEN OTHERS THEN
		   LOG_MESSAGE('Delete Exceptions : Error while updating Exception Summary');
		   LOG_MESSAGE(SQLERRM);
		   p_status := G_ERROR;
		   ROLLBACK;
		   RETURN;
	   END;

   END IF;

   p_status := G_SUCCESS;

ELSE -- (p_lrtype <> 'C')

	--===============================================================
	-- Delete exceptions which do not have transaction_ids present in
	-- msc_sup_dem_entries
	--===============================================================

	v_sql_stmt := null;

	BEGIN

        v_sql_stmt :=
	    ' delete msc_x_exception_details med '
	    ||' where transaction_id1 is not null'
        ||' and   exception_type  '||G_DUPLICATE_EXCEP_TYPES
	    ||' and   exception_group  '||G_EXCEP_GROUPS
	    ||' and   not exists ( select 1 '
        ||'					   from msc_sup_dem_entries msde'
        ||'					   where msde.transaction_id = med.transaction_id1)';

        EXECUTE IMMEDIATE v_sql_stmt;

        LOG_MESSAGE('No. of deleted exceptions where first transaction does not present in CP transactions - '||SQL%ROWCOUNT);

        COMMIT;

    EXCEPTION WHEN OTHERS THEN
        LOG_MESSAGE('Error while deleting exception details related to first transaction in case of non Complete refresh collection mode');
        LOG_MESSAGE(SQLERRM);
        p_status := G_ERROR;
        ROLLBACK;
        RETURN;
    END;


    v_sql_stmt := null;

    BEGIN

        v_sql_stmt :=
        ' delete msc_x_exception_details med '
	    ||' where transaction_id2 is not null '
        ||' and exception_type  '||G_DUPLICATE_EXCEP_TYPES
	    ||' and exception_group  '||G_EXCEP_GROUPS
	    ||' and not exists ( select 1 '
	    ||' 				 from msc_sup_dem_entries msde '
        ||'					 where msde.transaction_id = med.transaction_id2)';

        EXECUTE IMMEDIATE v_sql_stmt;

        LOG_MESSAGE('No. of deleted exceptions where second transaction does not present in CP transactions - '||SQL%ROWCOUNT);

        COMMIT;

    EXCEPTION WHEN OTHERS THEN
        LOG_MESSAGE('Error while deleting exception details related to second transaction in case of non Complete refresh collection mode');
        LOG_MESSAGE(SQLERRM);
        p_status := G_ERROR;
        ROLLBACK;
        RETURN;
    END;

    UPDATE_EXCEPTION_SUMMARY(l_summary_status);

    P_status := l_summary_status;


END IF; -- (p_lrtype = 'C')
END POST_CLEANUP;

END MSC_CL_POST_PUBLISH;

/
