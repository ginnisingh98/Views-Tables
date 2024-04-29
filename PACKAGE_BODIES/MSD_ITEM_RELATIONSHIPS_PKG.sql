--------------------------------------------------------
--  DDL for Package Body MSD_ITEM_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_ITEM_RELATIONSHIPS_PKG" AS
/* $Header: msdsupsb.pls 120.2.12010000.1 2008/05/15 08:50:04 vrepaka ship $ */

/* This procedure to collect Supersession data from source instance to DP staging table. */

PROCEDURE collect_supersession_data (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_instance_id           in number
) IS

x_dblink         	varchar2(128);
v_sql_stmt       	varchar2(4000);

BEGIN

   retcode :=0;

   msd_common_utilities.get_db_link(p_instance_id, x_dblink, retcode);
   if (retcode = -1) then
         retcode :=-1;
         errbuf := 'Error while getting db_link for Item Supersession Collection';
         --dbms_output.put_line('Error while getting db_link');
         return;
   end if;

   /* Delete records by instance before collecting supersession data from source instance */

   delete from msd_st_item_relationships
   where instance_id = p_instance_id;

/* Single step collection internally is two step hence colect always inserts it in staging table */
/* Net Change is not needed for this entity */

   v_sql_stmt:= ' insert into msd_st_item_relationships ( '||
                              'instance_id, '||
                              'inventory_item_id, '||
                              'inventory_item, '||
                              'related_item_id, '||
                              'related_item, '||
                              'relationship_type_id, '||
                              'creation_date, '||
                              'created_by, '||
                              'last_update_date, '||
                              'last_updated_by, '||
                              'last_update_login, '||
                              'start_date, '||                   /*--Bug#4707819--*/
                              'end_date) '||                    /*--Bug#4707819--*/
                     'SELECT ''' || p_instance_id || ''','||
                              'inventory_item_id,'||
                              'inventory_item,'||
                              'related_item_id, '||
                              'related_item, '||
                              'relationship_type_id, '||
                              'sysdate, ' ||
                              FND_GLOBAL.USER_ID || ', ' ||
                              'sysdate, ' ||
                              FND_GLOBAL.USER_ID || ', ' ||
                              FND_GLOBAL.USER_ID || ' ,' ||
                               'start_date, '||               /*--Bug#4707819--*/
                              'end_date  '||                  /*--Bug#4707819--*/
                       'FROM  ' ||
                              'msd_sr_item_supersession_v' || x_dblink;

   EXECUTE IMMEDIATE v_sql_stmt;

--   COMMIT;

   EXCEPTION
       when others then
            errbuf := substr(SQLERRM,1,150);
            retcode := -1;
            fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
            rollback;

END collect_supersession_data;


/* This procedure to pull Supersession data from staging table to fact table */

PROCEDURE pull_supersession_data (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2
) IS

l_event_name     varchar2(240);
l_instance_id    number;

CURSOR auto_update_events_c1 IS
SELECT event_name
FROM msd_events
where auto_update_ss_flag = 'Y'
and event_type = 3
and introduction_type = 2;

CURSOR item_instance_c2 IS
select distinct instance_id
from msd_st_item_relationships;

BEGIN

    OPEN item_instance_c2;
    LOOP
        l_instance_id := NULL;

        FETCH item_instance_c2 INTO l_instance_id;
        EXIT WHEN item_instance_c2%NOTFOUND;

   /* Delete records in fact table by instance before pull supersession data from staging table */

        delete from msd_item_relationships
        where instance_id = l_instance_id;

/* Insert Supersession data into DP fact table */

        insert into msd_item_relationships (
                    instance_id,
                    inventory_item_id,
                    inventory_item,
                    related_item_id,
                    related_item,
                    relationship_type_id,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    last_update_login,
                    start_date,                    /*--Bug#4707819--*/
                    end_date )                     /*--Bug#4707819--*/
            SELECT  instance_id,
                    inventory_item_id,
                    inventory_item,
                    related_item_id,
                    related_item,
                    relationship_type_id,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.USER_ID,
                    start_date,                     /*--Bug#4707819--*/
                    end_date                         /*--Bug#4707819--*/
            FROM  msd_st_item_relationships
            WHERE instance_id = l_instance_id;

        commit;

        OPEN auto_update_events_c1;
        LOOP
             l_event_name := NULL;

        /*  Get auto update events list by checking auto_update_ss_flag column in MSD_EVENTS table */

             FETCH auto_update_events_c1 INTO l_event_name;
             EXIT WHEN auto_update_events_c1%NOTFOUND;

             fnd_file.put_line(fnd_file.log, 'Auto Refreshing Event: '|| l_event_name || '    Instance Id: '|| l_instance_id);

             msd_item_relationships_pkg.create_supersession_events (
                                                errbuf => errbuf,
                                                retcode => retcode,
                                                p_instance_id => l_instance_id,
                                                p_event_name => l_event_name );

        END LOOP;
        CLOSE auto_update_events_c1;

    END LOOP;
    CLOSE item_instance_c2;

/* new */
    commit;

    EXCEPTION
       when others then
            errbuf := substr(SQLERRM,1,150);
            retcode := -1;
            fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
            rollback;

END pull_supersession_data;


/* This procedure to delete events data before refreshing */

PROCEDURE delete_events_data (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_instance_id           in number,
  p_event_id              in number
) IS

BEGIN

     delete from msd_evt_product_details
     where event_id = p_event_id
     and instance = p_instance_id;

     delete from msd_evt_prod_relationships
     where event_id = p_event_id
     and instance = p_instance_id;

     delete from msd_event_products
     where event_id = p_event_id
     and instance = p_instance_id;

--    commit;

    EXCEPTION
         when others then
              errbuf := substr(SQLERRM,1,150);
              retcode := -1;
              fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
              rollback;


END delete_events_data;

/* This procedure will insert supersession new item information into MSD_EVENTS_PRODUCTS */

PROCEDURE insert_event_products (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_instance_id           in number,
  l_event_id              in number,
  l_seq_id                in number,
  l_level_id              in number,
  l_inventory_item        in varchar2,
  l_inventory_item_id     in varchar2,
  l_start_time            in date,                 /*--Bug#4707819--*/
  l_end_time              in date                  /*--Bug#4707819--*/
) IS

BEGIN

     INSERT INTO msd_event_products (
            instance,
            event_id,
            seq_id,
            product_lvl_id,
            product_lvl_val,
            sr_product_lvl_pk,
            start_time,                             /*--Bug#4707819--*/
            end_time,                               /*--Bug#4707819--*/
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login )
     VALUES (p_instance_id,
            l_event_id,
            l_seq_id,
            l_level_id,
            l_inventory_item,
            l_inventory_item_id,
            l_start_time,                                 /*--Bug#4707819--*/
            l_end_time,                                   /*--Bug#4707819--*/
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.USER_ID );

--    commit;

    EXCEPTION
         when others then
              errbuf := substr(SQLERRM,1,150);
              retcode := -1;
              fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
              rollback;

END insert_event_products;

/* This procedure will insert supersession related item's relation information into msd_evt_prod_relationships table */

PROCEDURE insert_evt_prod_relationships (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_instance_id           in number,
  l_event_id              in number,
  l_seq_id                in number,
  l_relation_id           in number,
  l_level_id              in number,
  l_related_item          in varchar2,
  l_related_item_id       in varchar2,
  l_qty_mod_type          in number,
  l_qty_mod_factor        in number,
  l_npi_prd_relshp        in number,
  l_start_time		  in date,     /*--Bug#4707819--*/
  l_end_time              in date      /*--Bug#4707819--*/
) IS

BEGIN

     INSERT INTO msd_evt_prod_relationships (
            instance,
            event_id,
            seq_id,
            relation_id,
            product_lvl_id,
            product_lvl_val,
            sr_product_lvl_pk,
            lag,
            qty_modification_type,
            qty_modification_factor,
            npi_prod_relationship,
            start_time,          /*--Bug#4707819--*/
            end_time,            /*--Bug#4707819--*/
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login )
     VALUES (p_instance_id,
            l_event_id,
            l_seq_id,
            l_relation_id,
            l_level_id,
            l_related_item,
            l_related_item_id,
            0,
            l_qty_mod_type,
            l_qty_mod_factor,
            l_npi_prd_relshp,
            l_start_time,            /*--Bug#4707819--*/
            l_end_time,              /*--Bug#4707819--*/
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.USER_ID );

--    commit;

    EXCEPTION
         when others then
              errbuf := substr(SQLERRM,1,150);
              retcode := -1;
              fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
              rollback;

END insert_evt_prod_relationships;


/* This procedure will insert supersession related item's detail information into msd__evt_product_details table */

PROCEDURE insert_evt_product_details (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_instance_id           in number,
  l_event_id              in number,
  l_seq_id                in number,
  l_detail_id             in number,
  l_relation_id           in number,
  l_level_id              in number,
  l_related_item          in varchar2,
  l_related_item_id       in varchar2,
  l_qty_mod_type          in number,
  l_qty_mod_factor        in number
) IS

BEGIN

     INSERT INTO msd_evt_product_details (
            instance,
            event_id,
            seq_id,
            detail_id,
            relation_id,
            product_lvl_id,
            product_lvl_val,
            sr_product_lvl_pk,
            time_lvl_val_from,
            time_lvl_val_to,
            qty_modification_type,
            qty_modification_factor,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login )
     VALUES (p_instance_id,
            l_event_id,
            l_seq_id,
            l_detail_id,
            l_relation_id,
            l_level_id,
            l_related_item,
            l_related_item_id,
            sysdate,
            sysdate,
            l_qty_mod_type,
            l_qty_mod_factor,
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.USER_ID );

--    commit;

    EXCEPTION
         when others then
              errbuf := substr(SQLERRM,1,150);
              retcode := -1;
              fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
              rollback;

END insert_evt_product_details;


/* this procedure will update supersession events based on item relationship information */

PROCEDURE update_supersession_events (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_event_name            in varchar2
) IS

l_instance_id           number;

CURSOR item_instance_c1 IS
select distinct instance_id
from msd_item_relationships;

BEGIN

    OPEN item_instance_c1;
    LOOP
        l_instance_id := NULL;

        FETCH item_instance_c1 INTO l_instance_id;
        EXIT WHEN item_instance_c1%NOTFOUND;

        msd_item_relationships_pkg.create_supersession_events (
                                           errbuf => errbuf,
                                           retcode => retcode,
                                           p_instance_id => l_instance_id,
                                           p_event_name => p_event_name );

   END LOOP;
   CLOSE item_instance_c1;

   EXCEPTION
       when others then
            errbuf := substr(SQLERRM,1,150);
            retcode := -1;
            fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));

END update_supersession_events;


/* This procedure to create events based on supersession data */

PROCEDURE create_supersession_events (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_instance_id           in number,
  p_event_name            in varchar2
) IS

l_event_id         	number;
l_seq_id           	number;
l_relation_id      	number;
l_detail_id      	number;
l_qty_mod_type          varchar2(1);
l_qty_mod_factor  	number;
l_npi_prd_relshp        varchar2(1);
l_inventory_item_id     varchar2(240);
l_inventory_item        varchar2(240);
l_related_item_id       varchar2(240);
l_related_item          varchar2(240);
l_count		        number;
l_level_id		number;
l_start_time		date;      /*--Bug#4707819--*/
l_end_time		date;      /*--Bug#4707819--*/


/*
CURSOR new_item_c1 IS
SELECT lvl.sr_level_pk,
       lvl.level_value
FROM msd_item_relationships rel,
     msd_level_values lvl
WHERE lvl.instance = rel.instance_id
AND lvl.sr_level_pk = rel.inventory_item_id
AND lvl.level_id = 1
AND rel.inventory_item_id not in (SELECT re2.related_item_id
                                  FROM msd_item_relationships re2
                                  WHERE re2.instance_id = to_char(p_instance_id))
AND rel.instance_id = to_char(p_instance_id);
*/

CURSOR new_item_c1 IS
SELECT lvl.sr_level_pk,
       lvl.level_value, rel.start_date, rel.end_date                    /*--Bug#4707819--*/
FROM msd_item_relationships rel,
     msd_level_values lvl
WHERE lvl.instance = rel.instance_id
AND lvl.sr_level_pk = rel.inventory_item_id
AND lvl.level_id = 1
AND rel.instance_id = to_char(p_instance_id)
MINUS
SELECT re2.related_item_id,
       re2.related_item, re2.start_date, re2.end_date                   /*--Bug#4707819--*/
FROM msd_item_relationships re2
WHERE re2.instance_id = to_char(p_instance_id);


CURSOR superseded_item_c1(l_inventory_item_id in number) IS
SELECT related_item_id,
       related_item
FROM msd_item_relationships
START WITH inventory_item_id = l_inventory_item_id
AND instance_id = p_instance_id
CONNECT BY PRIOR related_item_id = inventory_item_id
AND instance_id = p_instance_id;

CURSOR chk_item_exists (p_related_item_id in varchar2) IS
SELECT count(*)
FROM msd_level_values
WHERE instance = p_instance_id
AND sr_level_pk = p_related_item_id
AND level_id = 1;

BEGIN

    select event_id
    into l_event_id
    from msd_events
    where event_name = p_event_name;

/* Delete refresh events before updating with supersession item relationships */

    msd_item_relationships_pkg.delete_events_data (
                               errbuf => errbuf,
                               retcode => retcode,
                               p_instance_id => p_instance_id,
                               p_event_id => l_event_id );

    l_level_id := 1;

    OPEN new_item_c1;
    LOOP

        l_inventory_item_id := NULL;
        l_inventory_item := NULL;

        FETCH new_item_c1 INTO l_inventory_item_id, l_inventory_item, l_start_time, l_end_time;             /*--Bug#4707819--*/
           EXIT WHEN new_item_c1%NOTFOUND;

             l_seq_id := null;

             SELECT msd_event_products_s.nextval
             INTO l_seq_id
             FROM dual;

             /* Insert new items into MSD_EVENT_PRODUCTS table */

             msd_item_relationships_pkg.insert_event_products(
                                  errbuf => errbuf,
                                  retcode => retcode,
                                  p_instance_id => p_instance_id,
                                  l_event_id => l_event_id,
                                  l_seq_id => l_seq_id,
                                  l_level_id => l_level_id,
                                  l_inventory_item => l_inventory_item,
                                  l_inventory_item_id => l_inventory_item_id,
                                  l_start_time=>l_start_time,                                      /*--Bug#4707819--*/
                                  l_end_time => l_end_time );                                      /*--Bug#4707819--*/

            begin

            OPEN superseded_item_c1 (l_inventory_item_id);
            LOOP

                l_related_item_id := NULL;
                l_related_item := NULL;

               begin

                FETCH superseded_item_c1 INTO l_related_item_id, l_related_item;
                  EXIT WHEN superseded_item_c1%NOTFOUND;

                l_count := 0;
/*
                SELECT 1
                INTO l_count
                FROM msd_level_values
                WHERE instance = p_instance_id
                AND sr_level_pk = l_related_item_id
                AND level_id = 1;
*/
                OPEN chk_item_exists(l_related_item_id);
                    FETCH chk_item_exists INTO l_count;
                CLOSE chk_item_exists;

                IF l_count <> 0 THEN

                   l_relation_id := NULL;

                   select msd_evt_prod_relationships_s.nextval
                   into l_relation_id
                   from dual;

                   l_qty_mod_type := 2;
                   l_qty_mod_factor := 0;
                   l_npi_prd_relshp := 1;

                   /* Insert base items into MSD_EVT_PROD_RELATIONSHIPS table */
                   msd_item_relationships_pkg.insert_evt_prod_relationships(
                                     errbuf => errbuf,
                                     retcode => retcode,
                                     p_instance_id => p_instance_id,
                                     l_event_id => l_event_id,
                                     l_seq_id => l_seq_id,
                                     l_relation_id => l_relation_id,
                                     l_level_id => l_level_id,
                                     l_related_item => l_related_item,
                                     l_related_item_id => l_related_item_id,
                                     l_qty_mod_type => l_qty_mod_type,
                                     l_qty_mod_factor => l_qty_mod_factor,
                                     l_npi_prd_relshp => l_npi_prd_relshp,
                                     l_start_time=>null,                                     /*--Bug#4707819--*/
                                     l_end_time=>null );                                     /*--Bug#4707819--*/

                   l_relation_id := NULL;

                   select msd_evt_prod_relationships_s.nextval
                   into l_relation_id
                   from dual;

                   select msd_evt_product_details_s.nextval
                   into l_detail_id
                   from dual;

                   l_qty_mod_type := 2;
                   l_qty_mod_factor := 100;
                   l_npi_prd_relshp := 2;

                   /* Insert cannabilized items into MSD_EVT_PROD_RELATIONSHIPS table */
                   msd_item_relationships_pkg.insert_evt_prod_relationships(
                                     errbuf => errbuf,
                                     retcode => retcode,
                                     p_instance_id => p_instance_id,
                                     l_event_id => l_event_id,
                                     l_seq_id => l_seq_id,
                                     l_relation_id => l_relation_id,
                                     l_level_id => l_level_id,
                                     l_related_item => l_related_item,
                                     l_related_item_id => l_related_item_id,
                                     l_qty_mod_type => l_qty_mod_type,
                                     l_qty_mod_factor => l_qty_mod_factor,
                                     l_npi_prd_relshp => l_npi_prd_relshp,
                                     l_start_time => l_start_time,                                  /*--Bug#4707819--*/
                                     l_end_time =>l_end_time );                           /*--Bug#4707819--*/

                   /* Insert cannabilized items details into MSD_EVT_PRODUCT_DETAILS table */
                   msd_item_relationships_pkg.insert_evt_product_details(
                                     errbuf => errbuf,
                                     retcode => retcode,
                                     p_instance_id => p_instance_id,
                                     l_event_id => l_event_id,
                                     l_seq_id => l_seq_id,
                                     l_detail_id => l_detail_id,
                                     l_relation_id => l_relation_id,
                                     l_level_id => l_level_id,
                                     l_related_item => l_related_item,
                                     l_related_item_id => l_related_item_id,
                                     l_qty_mod_type => l_qty_mod_type,
                                     l_qty_mod_factor => l_qty_mod_factor );

                END IF;

                EXCEPTION
                   when others then
                      errbuf := substr(SQLERRM,1,150);
                      fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
                      rollback;
                     /* Exit the process after an error happens */
                      exit;
               end;

             END LOOP;
             CLOSE superseded_item_c1;

             /* This exception for multiple looping  */
             EXCEPTION
                   when others then
                       fnd_file.put_line(fnd_file.log, 'Item relationship is in loop: '|| l_inventory_item_id);

             end;

    COMMIT;

    END LOOP;
    CLOSE new_item_c1;

    EXCEPTION
         when others then
              errbuf := substr(SQLERRM,1,150);
              retcode := -1;
              fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
              rollback;

END create_supersession_events;

END MSD_ITEM_RELATIONSHIPS_PKG;

/
