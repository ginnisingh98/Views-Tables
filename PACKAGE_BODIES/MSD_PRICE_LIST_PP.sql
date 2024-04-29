--------------------------------------------------------
--  DDL for Package Body MSD_PRICE_LIST_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_PRICE_LIST_PP" AS
/* $Header: msdplppb.pls 115.1 2004/03/30 12:55:48 sudekuma noship $ */


PROCEDURE price_list_post_process( errbuf           OUT NOCOPY VARCHAR2,
                                   retcode          OUT NOCOPY VARCHAR2,
                                   p_instance_id    IN  VARCHAR2,
                                   p_price_list     IN  VARCHAR2 ) is

CURSOR c_multi_price_list (p_instance_id in varchar2,
                     p_price_list in varchar2 ) IS
select price_list_name, sr_product_lvl_pk, start_date, end_date
from msd_st_price_list a
where instance = p_instance_id
and price_list_name like nvl(p_price_list, price_list_name)
and not exists (select 1 from msd_st_price_list b
                where b.instance = a.instance
                and b.price_list_name = a.price_list_name
                and nvl(b.start_date, to_date('01/01/1000', 'MM/DD/YYYY')) = nvl(a.start_date, to_date('01/01/1000', 'MM/DD/YYYY'))
                and nvl(b.end_date, to_date('01/01/1000', 'MM/DD/YYYY')) = nvl(a.end_date, to_date('01/01/1000', 'MM/DD/YYYY'))
                and b.sr_product_lvl_pk = a.sr_product_lvl_pk
                and b.valid_flag = 1
               )
group by price_list_name, sr_product_lvl_pk, start_date, end_date
having count(*) > 1;


CURSOR c_single_price_list (p_instance_id in varchar2,
                         p_price_list in varchar2 ) IS
select price_list_name, sr_product_lvl_pk, start_date, end_date
from msd_st_price_list
where instance = p_instance_id
and price_list_name like nvl(p_price_list, price_list_name)
and nvl(valid_flag, 0) <> 1
group by price_list_name, sr_product_lvl_pk, start_date, end_date
having count(*) = 1;


type price_list_name_tab   is table of msd_st_price_list.price_list_name%type;
TYPE sr_product_lvl_pk_tab is table of msd_st_price_list.sr_product_lvl_pk%TYPE;
type start_date_tab  is table of msd_st_price_list.start_date%type;
type end_date_tab     is table of msd_st_price_list.end_date%type;


a_price_list_name     price_list_name_tab;
a_sr_product_lvl_pk   sr_product_lvl_pk_tab;
a_start_date          start_date_tab;
a_end_date            end_date_tab;

BEGIN

  /* Select all price list information which has more than on price list lines matches
     with price list name, item, start date and end date

     Update valid flag to 1 for price list, if price list uom matches with item's base uom
  */

  OPEN  c_multi_price_list(p_instance_id, p_price_list);
  FETCH c_multi_price_list BULK COLLECT INTO a_price_list_name, a_sr_product_lvl_pk, a_start_date,  a_end_date;
  CLOSE c_multi_price_list;

  IF a_price_list_name.exists(1) THEN

     FORALL i IN a_price_list_name.FIRST..a_price_list_name.LAST
        update msd_st_price_list
        set valid_flag = 1
        where price_list_uom = (select base_uom
                                from msd_item_list_price
                                where sr_item_pk = a_sr_product_lvl_pk(i)
                                and instance = p_instance_id )
        and price_list_name = a_price_list_name(i)
        and sr_product_lvl_pk = a_sr_product_lvl_pk(i)
        and nvl(start_date, to_date('01/01/1000', 'MM/DD/YYYY')) = nvl(a_start_date(i), to_date('01/01/1000', 'MM/DD/YYYY'))
        and nvl(end_date, to_date('01/01/1000', 'MM/DD/YYYY')) = nvl(a_end_date(i), to_date('01/01/1000', 'MM/DD/YYYY'));

   END IF;

   /* Update valid flag to 1 for price list, If primary uom flag is set to 'Yes'  */

   OPEN  c_multi_price_list(p_instance_id, p_price_list);
   FETCH c_multi_price_list BULK COLLECT INTO a_price_list_name, a_sr_product_lvl_pk, a_start_date,  a_end_date;
   CLOSE c_multi_price_list;

   IF a_price_list_name.exists(1) THEN
      FORALL i IN a_price_list_name.FIRST..a_price_list_name.LAST
         update msd_st_price_list
         set valid_flag = 1
         where primary_uom_flag = 'Y'
         and price_list_name = a_price_list_name(i)
         and sr_product_lvl_pk = a_sr_product_lvl_pk(i)
         and nvl(start_date, to_date('01/01/1000', 'MM/DD/YYYY')) = nvl(a_start_date(i), to_date('01/01/1000', 'MM/DD/YYYY'))
         and nvl(end_date, to_date('01/01/1000', 'MM/DD/YYYY')) = nvl(a_end_date(i), to_date('01/01/1000', 'MM/DD/YYYY'));
   END IF;


   /* Update valid flag to 1 for price list, If the price list has low priority
      If more than one price list lines has same low priority, then update the first price list row
   */

   OPEN  c_multi_price_list(p_instance_id, p_price_list);
   FETCH c_multi_price_list BULK COLLECT INTO a_price_list_name, a_sr_product_lvl_pk, a_start_date,  a_end_date;
   CLOSE c_multi_price_list;

   IF a_price_list_name.exists(1) THEN
      FORALL i IN a_price_list_name.FIRST..a_price_list_name.LAST
         update msd_st_price_list
         set valid_flag = 1
         where price_list_name = a_price_list_name(i)
               and sr_product_lvl_pk = a_sr_product_lvl_pk(i)
               and nvl(priority, -999) = (select nvl(min(b.priority), -999)
                                          from msd_st_price_list b
                                          where b.price_list_name = a_price_list_name(i)
                                          and b.sr_product_lvl_pk = a_sr_product_lvl_pk(i)
                                          and nvl(b.start_date, to_date('01/01/1000', 'MM/DD/YYYY')) = nvl(a_start_date(i), to_date('01/01/1000', 'MM/DD/YYYY'))
                                          and nvl(b.end_date, to_date('01/01/1000', 'MM/DD/YYYY')) = nvl(a_end_date(i), to_date('01/01/1000', 'MM/DD/YYYY'))
                                          )
               and nvl(start_date, to_date('01/01/1000', 'MM/DD/YYYY')) = nvl(a_start_date(i), to_date('01/01/1000', 'MM/DD/YYYY'))
               and nvl(end_date, to_date('01/01/1000', 'MM/DD/YYYY')) = nvl(a_end_date(i), to_date('01/01/1000', 'MM/DD/YYYY'))
               and rownum < 2;

   END IF;

  /* Update valid flag to 1 for price list, If only one price list line matches
     with price list name, item, start date and end date
  */


  OPEN  c_single_price_list(p_instance_id, p_price_list);
  FETCH c_single_price_list BULK COLLECT INTO a_price_list_name, a_sr_product_lvl_pk, a_start_date, a_end_date;
  CLOSE c_single_price_list;

  IF a_price_list_name.exists(1) THEN

     FORALL i IN a_price_list_name.FIRST..a_price_list_name.LAST
        update msd_st_price_list
        set valid_flag = 1
        where price_list_name = a_price_list_name(i)
        and sr_product_lvl_pk = a_sr_product_lvl_pk(i)
        and nvl(start_date, to_date('01/01/1000', 'MM/DD/YYYY')) = nvl(a_start_date(i), to_date('01/01/1000', 'MM/DD/YYYY'))
        and nvl(end_date, to_date('01/01/1000', 'MM/DD/YYYY')) = nvl(a_end_date(i), to_date('01/01/1000', 'MM/DD/YYYY'));

   END IF;

   /* delete all dublicate price list lines which is not set to valid flag to 1 */

   delete from msd_st_price_list
   where instance = p_instance_id
   and price_list_name like nvl(p_price_list, price_list_name)
   and nvl(valid_flag,0) <> 1;

   commit;


   EXCEPTION
     WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log, 'Errors in Price List Post Processing');
        fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
end ;

END MSD_PRICE_LIST_PP;

/
