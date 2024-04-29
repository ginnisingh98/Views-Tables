--------------------------------------------------------
--  DDL for Package Body INV_ENHANCED_TM_PERF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ENHANCED_TM_PERF" AS
/*  $Header: INVENTMB.pls 120.0.12010000.2 2010/04/15 22:45:19 musinha noship $*/

  G_PKG_NAME           CONSTANT VARCHAR2(30) := 'INV_ENHANCED_TM_PERF';
  g_debug              NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  procedure print_debug(msg varchar2) is
  begin
      if (g_debug = 1) then
        inv_log_util.trace(msg,g_pkg_name,15);
      end if;
  end print_debug;

  procedure launch_worker( p_maxrows      in number
                          ,p_applid       in number
                          ,p_progid       in number
                          ,p_userid       in number
                          ,p_reqstid      in number
                          ,p_loginid      in number
                          ,x_ret_status   out nocopy number
                          ,x_ret_message  out nocopy varchar2)  is


       TYPE mti_rec_type IS RECORD (item_id NUMBER, rec_count NUMBER) ;

       type mti_rec_table is table of mti_rec_type index by binary_integer;

       l_mti_rec  mti_rec_table;

       cursor mti_rec is
       select rowid from mtl_transactions_interface mti
       where PROCESS_FLAG = 1
       AND NVL(LOCK_FLAG,2) = 2
       AND TRANSACTION_MODE = 3
       AND EXISTS (
                 SELECT 'X'
                 FROM MTL_TRANSACTION_TYPES MTT
                 WHERE MTT.TRANSACTION_TYPE_ID = MTI.TRANSACTION_TYPE_ID
                 AND MTT.TRANSACTION_SOURCE_TYPE_ID IN (2,8,16))
       and exists (
                 select 1
                 from   org_organization_definitions ood
                 where  ood.organization_id = mti.organization_id
                 and    nvl(ood.disable_date, sysdate + 1) > sysdate)
       order by mti.inventory_item_id;

        l_cur_count  NUMBER := 0;
        l_org_id     NUMBER;
        l_item_id    NUMBER;
        l_total      NUMBER := 0;
        l_done       NUMBER := 0;
        l_header_id  number;
        l_unique     number := 0;
        l_rowcount     NUMBER := 0;

        type rowid_type is table of rowid index by binary_integer;
        l_rowid rowid_type;
        l_req_id   number;

  begin

       print_debug('entered INV_ENHANCED_TM_PERF.launch_worker ');

       print_debug('p_maxrows '|| p_maxrows);
       print_debug('p_applid '|| p_applid);
       print_debug('p_progid '|| p_progid);
       print_debug('p_userid '|| p_userid);
       print_debug('p_reqstid '|| p_reqstid);
       print_debug('p_loginid '|| p_loginid);

       /* Not grouping the records by org_id as the volume test that was conducted by starbucks
          showed that by launching one worker per item across orgs significantly reduces the
          latch contention and increases the throughput by almost 100%.
       */

       select inventory_item_id, count(1) record_count
       bulk collect into l_mti_rec
       from mtl_transactions_interface mti
       where PROCESS_FLAG = 1
       AND NVL(LOCK_FLAG,2) = 2
       AND TRANSACTION_MODE = 3
       AND EXISTS (
                 SELECT 'X'
                 FROM MTL_TRANSACTION_TYPES MTT
                 WHERE MTT.TRANSACTION_TYPE_ID = MTI.TRANSACTION_TYPE_ID
                 AND MTT.TRANSACTION_SOURCE_TYPE_ID IN (2,8,16))
       and exists (
                 select 1
                 from   org_organization_definitions ood
                 where  ood.organization_id = mti.organization_id
                 and    nvl(ood.disable_date, sysdate + 1) > sysdate)
       group by inventory_item_id
       having count(*) >= p_maxrows
       order by record_count desc;

       print_debug('processing '|| l_mti_rec.count || ' items having records more than maxrows ');

       for i in 1..l_mti_rec.COUNT loop

          l_header_id := get_seq_nextval;
          print_debug('updating item_id '|| l_mti_rec(i).item_id || ' with header_id '||l_header_id);

          l_rowcount := 0;

          update mtl_transactions_interface mti
             set transaction_header_id = l_header_id,
                        last_update_date = sysdate,
                        last_updated_by = p_userid,
                        LAST_UPDATE_LOGIN = p_loginid,
                        PROGRAM_APPLICATION_ID = p_applid,
                        program_id = p_progid,
                        REQUEST_ID = p_reqstid,
                        PROGRAM_UPDATE_DATE = SYSDATE,
                        LOCK_FLAG = 1,
                        error_code = null,
                        error_explanation = null
           where inventory_item_id = l_mti_rec(i).item_id
             and process_flag = 1
             and nvl(lock_flag,2) = 2
             and transaction_mode = 3
             and exists (
                   select 'X'
                   FROM MTL_TRANSACTION_TYPES MTT
                   where mtt.transaction_type_id = mti.transaction_type_id
                   and mtt.transaction_source_type_id in (2,8,16))
             and exists (
                   select 1
                   from   org_organization_definitions ood
                   where  ood.organization_id = mti.organization_id
                   and    nvl(ood.disable_date, sysdate + 1) > sysdate);

           l_rowcount := l_rowcount + sql%rowcount;
           print_debug('l_rowcount is '||l_rowcount);

           print_debug('updating rows with same batch_id ');
           update mtl_transactions_interface mti
	            set transaction_header_id = l_header_id,
	                last_update_date = sysdate,
                  last_updated_by = p_userid,
                  LAST_UPDATE_LOGIN = p_loginid,
                  PROGRAM_APPLICATION_ID = p_applid,
                  program_id = p_progid,
                  request_id = p_reqstid,
	                program_update_date = sysdate,
	                lock_flag = 1,
	                error_code = null,
	                error_explanation = null
            where process_flag = 1
	            and nvl(lock_flag,2) = 2
	            and transaction_mode = 3
	            and exists (
		               select 'X'
		               from mtl_transaction_types mtt
                   where mtt.transaction_type_id = mti.transaction_type_id
		               and mtt.transaction_source_type_id in (2,8,16))
	            and transaction_batch_id is not null
	            and transaction_batch_id in (
                   select mti2.transaction_batch_id
                   from mtl_transactions_interface mti2
				           where mti2.transaction_header_id = l_header_id
				           and mti2.transaction_batch_id is not null
				           and mti2.lock_flag = 1
				           and mti2.error_code is null
				           and mti2.error_explanation is null)
	            and exists (                                           /* Bug 6223219 */
			             select 1
			             from   org_organization_definitions ood
		               where  ood.organization_id = mti.organization_id
			             and    nvl(ood.disable_date, sysdate + 1) > sysdate);

           l_rowcount := l_rowcount + sql%rowcount;
           print_debug('l_rowcount is '||l_rowcount);

           print_debug('launching INCTCW Worker');
           l_req_id := fnd_request.submit_request( application => 'INV'
                                       ,program     => 'INCTCW'
                                       ,argument1   => l_header_id
                                       ,argument2   => 3 --l_table
                                       ,argument3   =>''
                                       ,argument4   =>'');

           if (l_req_id = 0) then
             -- Handle submission error --
             print_debug('Error launching INCTCW Worker');
             raise fnd_api.g_exc_error;
           else
             commit;
           END IF;

           print_debug('INCTCW Concurrent Request_id is ' || l_req_id);

       end loop;


       print_debug('processing items having records less than maxrows ');

       loop
          l_rowid.DELETE;

          print_debug('opening mti_rec cursor ');

          open mti_rec;
          EXIT WHEN mti_rec%notfound;

          fetch mti_rec bulk collect into l_rowid limit p_maxrows;

          if l_rowid.first is null then
             print_debug('rowid list is empty... exiting ');
             exit;
          end if;

          print_debug('updating '|| l_rowid.COUNT || ' rows ');

          l_header_id := get_seq_nextval;

          print_debug('l_header_id '|| l_header_id);

          l_rowcount := 0;

          forall j in l_rowid.first..l_rowid.last
                update mtl_transactions_interface
                   SET transaction_header_id = l_header_id,
                        last_update_date = sysdate,
                        last_updated_by = p_userid,
                        LAST_UPDATE_LOGIN = p_loginid,
                        PROGRAM_APPLICATION_ID = p_applid,
                        program_id = p_progid,
                        REQUEST_ID = p_reqstid,
                        PROGRAM_UPDATE_DATE = SYSDATE,
                        LOCK_FLAG = 1,
                        error_code = null,
                        error_explanation = null
                 where  rowid = l_rowid(j);

          l_rowcount := l_rowcount + sql%rowcount;

          print_debug('l_rowcount is '||l_rowcount);

          if (l_rowcount = 0) then
            print_debug('no more rows to process... exiting ');
            exit;
          end if;

          print_debug('updating rows with same item_id ');

          update mtl_transactions_interface mti
            SET TRANSACTION_HEADER_ID = l_header_id,
                last_update_date = sysdate,
                last_updated_by = p_userid,
                LAST_UPDATE_LOGIN = p_loginid,
                PROGRAM_APPLICATION_ID = p_applid,
                program_id = p_progid,
                REQUEST_ID = p_reqstid,
                PROGRAM_UPDATE_DATE = SYSDATE,
                LOCK_FLAG = 1,
                ERROR_CODE = NULL,
                error_explanation = null
          WHERE PROCESS_FLAG = 1
            and nvl(lock_flag,2) = 2
            and transaction_mode = 3
            and exists (
               select 'X'
               from mtl_transaction_types mtt
               where mtt.transaction_type_id = mti.transaction_type_id
               and mtt.transaction_source_type_id in (2,8,16))
            and inventory_item_id in (
                      select mti2.inventory_item_id
                      from mtl_transactions_interface mti2
                      where mti2.transaction_header_id = l_header_id
                      and mti2.LOCK_FLAG = 1
                      and mti2.error_code is null
                      and mti2.ERROR_EXPLANATION is NULL)
            and exists (                                            /* Bug 5951465 */
                SELECT 1
                from   org_organization_definitions ood
                where  ood.organization_id = mti.organization_id
                and    nvl(ood.disable_date, sysdate + 1) > sysdate);

          l_rowcount := l_rowcount + sql%rowcount;

          print_debug('l_rowcount is ' || l_rowcount);

          print_debug('updating rows with same batch_id ');

          update mtl_transactions_interface mti
	            set transaction_header_id = l_header_id,
	                last_update_date = sysdate,
	                last_updated_by = p_userid,
                  last_update_login = p_loginid,
                  program_application_id = p_applid,
                  program_id = p_progid,
                  REQUEST_ID = p_reqstid,
	                program_update_date = sysdate,
	                lock_flag = 1,
	                error_code = null,
	                error_explanation = null
            where process_flag = 1
	            and nvl(lock_flag,2) = 2
	            and transaction_mode = 3
	            and exists (
		               select 'X'
		               from mtl_transaction_types mtt
                   where mtt.transaction_type_id = mti.transaction_type_id
		               and mtt.transaction_source_type_id in (2,8,16))
	            and transaction_batch_id is not null
	            and transaction_batch_id in (
                   select mti2.transaction_batch_id
                   from mtl_transactions_interface mti2
				           where mti2.transaction_header_id = l_header_id
				           and mti2.transaction_batch_id is not null
				           and mti2.lock_flag = 1
				           and mti2.error_code is null
				           and mti2.error_explanation is null)
	            and exists (                                           /* Bug 6223219 */
			             select 1
			             from   org_organization_definitions ood
		               where  ood.organization_id = mti.organization_id
			             and    nvl(ood.disable_date, sysdate + 1) > sysdate);

          l_rowcount := l_rowcount + SQL%ROWCOUNT;

          print_debug('l_rowcount is ' || l_rowcount);

          print_debug('launching INCTCW Worker');
          l_req_id := fnd_request.submit_request( application => 'INV'
                                       ,program     => 'INCTCW'
                                       ,argument1   => l_header_id
                                       ,argument2   => 3 --l_table
                                       ,argument3   =>''
                                       ,argument4   =>'' );

          if (l_req_id = 0) then
             -- Handle submission error --
             print_debug('Error launching INCTCW Worker');
             raise fnd_api.g_exc_error;
          else
             commit;
          END IF;

          print_debug('INCTCW Concurrent Request_id is ' || l_req_id);

          if  mti_rec%isopen then
             close mti_rec;
          END IF;

       end loop;
       x_ret_status := 0;
       print_debug('x_ret_status ' || x_ret_status);

  exception
    WHEN OTHERS THEN
      print_debug('Error :'||substr(sqlerrm, 1, 200));

      IF mti_rec%ISOPEN THEN
          CLOSE mti_rec;
      END IF;

      x_ret_status  := 1;
      x_ret_message := substr(sqlerrm, 1, 200);

  end launch_worker;

  function get_seq_nextval
  RETURN number
  is

    l_value number;
  begin

    select mtl_material_transactions_s.nextval
      into l_value
    from dual;

    return l_value;

  exception
    when others then
       l_value := -1;
       print_debug('Error in get_seq_nextval:'||substr(sqlerrm, 1, 200));
       return l_value;

  END get_seq_nextval;

END INV_ENHANCED_TM_PERF ;

/
