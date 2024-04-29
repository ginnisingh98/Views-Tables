--------------------------------------------------------
--  DDL for Package Body CS_UPDATE_CP_SHIPPED_FLAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_UPDATE_CP_SHIPPED_FLAG" AS
/* $Header: csushflb.pls 115.3 2000/12/15 17:25:33 pkm ship        $ */

PROCEDURE Update_Shipped_Flag Is

   Type NumTabType is VARRAY(1000) of NUMBER;
   customer_product_mig           NumTabtype;

   Type RowidTabType is VARRAY(1000) of VARCHAR2(30);
   rowid_mig                      RowidTabtype;

   Type StaTabType is VARRAY(1000) of VARCHAR2(1);
   shipped_flag_mig               StaTabType;
   upgraded_status_flag_mig       StaTabType;

   CURSOR m1 is
      select min(customer_product_id)
      from   cs_customer_products_all;

   CURSOR m2 is
      select max(customer_product_id)
      from   cs_customer_products_all;

   CURSOR c1(p_start number, p_end number) is
      select ccp.customer_product_id,
             ccp.shipped_flag,
             nvl(ccp.upgraded_status_flag,'N'),
             ccp.rowid
      from  cs_customer_products_all ccp
      where customer_product_id >= p_start and customer_product_id <= p_end
	 and   ccp.shipped_flag <> 'Y'
	 and   ccp.upgraded_status_flag = 'Y';

   MAX_BUFFER_SIZE           NUMBER := 500;
   v_low                     NUMBER;
   v_high                    NUMBER;
   v_batch                   NUMBER := 10;
   v_start                   NUMBER;
   v_end                     NUMBER;
   v_diff                    NUMBER;
   v_batch_counter           NUMBER := 0;

BEGIN
    OPEN m1;
    FETCH m1 into v_low;
    CLOSE m1;

    OPEN m2;
    FETCH m2 into v_high;
    CLOSE m2;

    v_diff  := ceil((v_high - v_low)/v_batch);
    v_start := v_low;
    v_end   := v_low + v_diff;
    v_batch_counter := 1;

    LOOP
    OPEN c1(v_start, v_end);
    LOOP
       /* Begin Loop 2 */
       fetch c1 bulk collect into customer_product_mig,
                                  shipped_flag_mig,
                                  upgraded_status_flag_mig,
   			          Rowid_mig
                          limit MAX_BUFFER_SIZE ;

        for i in 1..customer_product_mig.count loop
           if upgraded_status_flag_mig(i) = 'Y' then
              shipped_flag_mig(i) := 'Y';
           end if;
        End loop;

        FORALL j in 1..customer_product_mig.count
      	     UPDATE cs_customer_products_all
	     SET    shipped_flag = shipped_flag_mig(j)
             WHERE  rowid = Rowid_mig(j);

         commit;
     exit when c1%notfound;
     END LOOP;

     if c1%isopen then
        close c1;
     end if;

     v_batch_counter := v_batch_counter + 1;
     exit when v_batch_counter > v_batch;

     v_start := v_end + 1;

     if v_batch_counter <> v_batch then
        v_end := v_end + v_diff;
     else
        v_end := v_high;
     end if;
     commit;
  END LOOP;
END;
END CS_UPDATE_CP_SHIPPED_FLAG;

/
