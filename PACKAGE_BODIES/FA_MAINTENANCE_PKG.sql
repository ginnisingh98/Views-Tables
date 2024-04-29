--------------------------------------------------------
--  DDL for Package Body FA_MAINTENANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MAINTENANCE_PKG" as
/* $Header: FAXMTSCB.pls 120.3.12010000.2 2009/07/19 11:08:34 glchen ship $ */

h_progname       varchar2(30) := 'Asset Maintenance Scheduling';

procedure do_schedule(
		errbuf		  out nocopy varchar2,
                retcode           out nocopy varchar2,
		argument1 	  in  varchar2,   -- schedule_id
	  	argument2         in  varchar2  default  null,
		argument3         in  varchar2  default  null,
	  	argument4         in  varchar2  default  null,
	  	argument5         in  varchar2  default  null,
	  	argument6         in  varchar2  default  null,
	  	argument7         in  varchar2  default  null,
	  	argument8         in  varchar2  default  null,
	  	argument9         in  varchar2  default  null,
	  	argument10        in  varchar2  default  null,
	  	argument11        in  varchar2  default  null,
	  	argument12        in  varchar2  default  null,
	  	argument13        in  varchar2  default  null,
		argument14        in  varchar2  default  null,
		argument15        in  varchar2  default  null,
		argument16        in  varchar2  default  null,
		argument17        in  varchar2  default  null,
		argument18        in  varchar2  default  null,
		argument19        in  varchar2  default  null,
		argument20        in  varchar2  default  null,
		argument21        in  varchar2  default  null,
		argument22        in  varchar2  default  null,
		argument23        in  varchar2  default  null,
		argument24        in  varchar2  default  null,
		argument25        in  varchar2  default  null,
		argument26        in  varchar2  default  null,
		argument27        in  varchar2  default  null,
		argument28        in  varchar2  default  null,
		argument29        in  varchar2  default  null,
		argument30        in  varchar2  default  null,
		argument31        in  varchar2  default  null,
		argument32        in  varchar2  default  null,
		argument33        in  varchar2  default  null,
		argument34        in  varchar2  default  null,
		argument35        in  varchar2  default  null,
		argument36        in  varchar2  default  null,
		argument37        in  varchar2  default  null,
		argument38        in  varchar2  default  null,
		argument39        in  varchar2  default  null,
		argument40        in  varchar2  default  null,
		argument41        in  varchar2  default  null,
		argument42        in  varchar2  default  null,
		argument43        in  varchar2  default  null,
		argument44        in  varchar2  default  null,
		argument45        in  varchar2  default  null,
		argument46        in  varchar2  default  null,
		argument47        in  varchar2  default  null,
		argument48        in  varchar2  default  null,
		argument49        in  varchar2  default  null,
		argument50        in  varchar2  default  null,
		argument51        in  varchar2  default  null,
		argument52        in  varchar2  default  null,
		argument53        in  varchar2  default  null,
		argument54        in  varchar2  default  null,
		argument55        in  varchar2  default  null,
		argument56        in  varchar2  default  null,
		argument57        in  varchar2  default  null,
		argument58        in  varchar2  default  null,
		argument59        in  varchar2  default  null,
		argument60        in  varchar2  default  null,
		argument61        in  varchar2  default  null,
		argument62        in  varchar2  default  null,
		argument63        in  varchar2  default  null,
		argument64        in  varchar2  default  null,
		argument65        in  varchar2  default  null,
		argument66        in  varchar2  default  null,
		argument67        in  varchar2  default  null,
		argument68        in  varchar2  default  null,
		argument69        in  varchar2  default  null,
		argument70        in  varchar2  default  null,
		argument71        in  varchar2  default  null,
		argument72        in  varchar2  default  null,
		argument73        in  varchar2  default  null,
		argument74        in  varchar2  default  null,
		argument75        in  varchar2  default  null,
		argument76        in  varchar2  default  null,
		argument77        in  varchar2  default  null,
		argument78        in  varchar2  default  null,
		argument79        in  varchar2  default  null,
		argument80        in  varchar2  default  null,
		argument81        in  varchar2  default  null,
		argument82        in  varchar2  default  null,
		argument83        in  varchar2  default  null,
		argument84        in  varchar2  default  null,
		argument85        in  varchar2  default  null,
		argument86        in  varchar2  default  null,
		argument87        in  varchar2  default  null,
		argument88        in  varchar2  default  null,
		argument89        in  varchar2  default  null,
		argument90        in  varchar2  default  null,
		argument91        in  varchar2  default  null,
		argument92        in  varchar2  default  null,
		argument93        in  varchar2  default  null,
		argument94        in  varchar2  default  null,
		argument95        in  varchar2  default  null,
		argument96        in  varchar2  default  null,
		argument97        in  varchar2  default  null,
		argument98        in  varchar2  default  null,
		argument99        in  varchar2  default  null,
		argument100       in  varchar2  default  null) is


   events_table       events_tbl_type;
   h_num_events	      number;
   h_num_assets	      number:= 0;
   h_mesg_str          varchar2(2000);
   h_mesg_name	      varchar2(30);
   prog_failed	       exception;
   h_schedule_id       number;
   h_start_date        date;
   h_end_date          date;
   h_maint_date	       date;
   h_asset_id	       number;
   h_book_type_code    varchar2(30);
   h_succeed	       boolean:= TRUE;

   cursor assets_to_schedule is
      select ad.asset_id
      from   fa_distribution_history dh,
             gl_code_combinations gc,
             fa_additions ad,
             fa_books bk,
             fa_book_controls bc,
             fa_maint_schedule_hdr msh
      where  msh.schedule_id = h_schedule_id
      and    bc.book_type_code = msh.book_type_code
      and    bc.book_class = 'CORPORATE'
      and    bk.book_type_code = msh.book_type_code
      and    bk.date_ineffective is null
      and    bk.period_counter_fully_retired is null
      and    bk.date_placed_in_service >=
                  nvl(msh.from_date_placed_in_service,bk.date_placed_in_service)
      and    bk.date_placed_in_service <=
                  nvl(msh.to_date_placed_in_service,bk.date_placed_in_service)
      and    bk.asset_id = ad.asset_id
      and    ad.asset_number >=
                  nvl(msh.from_asset_number, ad.asset_number)
      and    ad.asset_number <=
                  nvl(msh.to_asset_number, ad.asset_number)
      and    ad.asset_category_id =
                  nvl(msh.category_id, ad.asset_category_id)
      and    nvl(ad.asset_key_ccid,-9999) =
                  nvl(msh.asset_key_id, nvl(ad.asset_key_ccid,-9999))
      and    ad.asset_id = dh.asset_id
      and    dh.location_id = nvl(msh.location_id, dh.location_id)
      and    dh.date_ineffective is null
      and    dh.code_combination_id = gc.code_combination_id
      group  by ad.asset_id;


   cursor date_cursor is
      SELECT start_date,end_date,book_type_code

      FROM fa_maint_schedule_hdr
      WHERE schedule_id = h_schedule_id;

BEGIN

    retcode := 0;

    savepoint asset_maint;

--  print out arguments

    fnd_message.set_name('OFA','FA_ASSET_MAINT_SCHARG_LIST');
    fnd_message.set_token('SCHID', argument1, FALSE);
    h_mesg_str := fnd_message.get;
    fa_rx_conc_mesg_pkg.log(h_mesg_str);
    fa_rx_conc_mesg_pkg.log('');
    fa_rx_conc_mesg_pkg.out(h_mesg_str);
    fa_rx_conc_mesg_pkg.out('');

-- check if valid argument is passed in

    if (argument1 is NULL) then

        h_mesg_name := 'FA_ASSET_MAINT_WRONG_PARAM';
        upd_status(NULL,h_mesg_name);
        raise prog_failed;
   end if;

   h_schedule_id := to_number(argument1);


   open date_cursor;
   fetch date_cursor into
        h_start_date,h_end_date,h_book_type_code;

   if (date_cursor%NOTFOUND) then
       close date_cursor;
       h_mesg_name := 'FA_ASSET_MAINT_WRONG_PARAM';
       upd_status(h_schedule_id,h_mesg_name);
       raise prog_failed;
   end if;
   close date_cursor;

   if (h_start_date is NULL or h_end_date is NULL) then
       h_mesg_name := 'FA_ASSET_MAINT_WRONG_PARAM';
       upd_status(h_schedule_id,h_mesg_name);
       raise prog_failed;
   end if;


   load_events_records(h_schedule_id,
                       events_table,
                       h_succeed);
   if (NOT h_succeed) then
      h_mesg_name := 'FA_SHARED_INSERT_FAILED';
      upd_status(h_schedule_id,h_mesg_name);
      raise prog_failed;
   end if;

   open assets_to_schedule;

   LOOP
	fetch assets_to_schedule
        into h_asset_id;

        exit when assets_to_schedule%NOTFOUND;

        h_num_assets := h_num_assets + 1;
        FOR i in events_table.first ..
                 events_table.last LOOP

             if (events_table(i).maintenance_date is not null) then

                 h_maint_date := events_table(i).maintenance_date;
                 insert_to_fa_maint_events(h_asset_id,
                                           h_book_type_code,
                                           events_table(i),
                                           h_maint_date,
                                           h_succeed);

                 if (NOT h_succeed) then
                     h_mesg_name := 'FA_SHARED_INSERT_FAILED';
                     upd_status(h_schedule_id,h_mesg_name);
                     raise prog_failed;
                 end if;

             elsif (events_table(i).frequency_in_days is not null) then

                 h_maint_date := h_start_date;
                 WHILE (h_maint_date <= h_end_date) LOOP

                     insert_to_fa_maint_events(h_asset_id,
                                               h_book_type_code,
                                               events_table(i),
                                               h_maint_date,
                                               h_succeed);
                     if (NOT h_succeed) then
                        h_mesg_name := 'FA_SHARED_INSERT_FAILED';
                        upd_status(h_schedule_id,h_mesg_name);
                        raise prog_failed;
                     end if;

                     h_maint_date := h_maint_date +
                                     events_table(i).frequency_in_days;
                 END LOOP;
             else
                 h_mesg_name := 'FA_SHARED_INSERT_FAILED';
                 upd_status(h_schedule_id,h_mesg_name);
	         raise prog_failed;
             end if;
        END LOOP;
   END LOOP;

   close assets_to_schedule;

   update fa_maint_schedule_hdr
   set status = 'COMPLETED'
   where schedule_id = h_schedule_id;
   commit;

   fa_rx_conc_mesg_pkg.log('');
   fa_rx_conc_mesg_pkg.log('');
   fnd_message.set_name('OFA','FA_MASSRCL_NUM_PROC');
   fnd_message.set_token('NUM', to_char(h_num_assets), FALSE);
   h_mesg_str := fnd_message.get;
   fa_rx_conc_mesg_pkg.out(h_mesg_str);
   fa_rx_conc_mesg_pkg.out('');
   fa_rx_conc_mesg_pkg.out('');

   fnd_message.set_name('OFA', 'FA_SHARED_END_SUCCESS');
   fnd_message.set_token('PROGRAM',h_progname,FALSE);
   h_mesg_str := fnd_message.get;
   fa_rx_conc_mesg_pkg.log(h_mesg_str);
   fa_rx_conc_mesg_pkg.log('');
   fa_rx_conc_mesg_pkg.out(h_mesg_str);

   retcode := 0;

EXCEPTION
   when prog_failed then
        if (assets_to_schedule%ISOPEN) then
           close assets_to_schedule;
        end if;
        retcode := 1;

   when others then
        if (assets_to_schedule%ISOPEN) then
           close assets_to_schedule;
        end if;
        fnd_message.set_name('OFA',h_mesg_name);
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);
	fa_rx_conc_mesg_pkg.log('');

	fnd_message.set_name('OFA', 'FA_SHARED_END_WITH_ERROR');
        fnd_message.set_token('PROGRAM',h_progname,FALSE);
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);
	fa_rx_conc_mesg_pkg.out(h_mesg_str);
        retcode := 2;

END do_schedule;


procedure upd_status(
           p_sch_id  in number,
           p_msg_name in varchar2) is

h_mesg_str varchar2(2000);

begin
   	fnd_message.set_name('OFA', p_msg_name);
        if (p_msg_name = 'FA_SHARED_INSERT_FAILED') then
           fnd_message.set_token('TABLE','FA_MAINT_EVENTS',FALSE);
        end if;
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);
	fa_rx_conc_mesg_pkg.log('');

	fnd_message.set_name('OFA', 'FA_SHARED_END_WITH_ERROR');
        fnd_message.set_token('PROGRAM',h_progname,FALSE);
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);
	fa_rx_conc_mesg_pkg.out(h_mesg_str);

        rollback to savepoint asset_maint;
        if (p_sch_id is not NULL) then
           update fa_maint_schedule_hdr
           set status = 'FAILED_RUN'
           where schedule_id = p_sch_id;
           commit;
        end if;

exception
   when others then
       raise;
end;

procedure load_events_records(
             p_schedule_id  in     number,
             p_events_tbl   in out nocopy events_tbl_type,
             p_succeed      out nocopy boolean) is

h_count       number := 0;
h_detail_rec  event_rec_type;
h_mesg_str    varchar2(2000);

cursor events_cursor is
      select schedule_id,event_name,description,frequency_in_days,
             maintenance_date,cost,employee_id,vendor_id,created_by,
             creation_date,last_updated_by,last_update_login,last_update_date,
             attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,
             attribute7,attribute8,attribute9,attribute10,attribute11,attribute12,
             attribute13,attribute14,attribute15,attribute_category
      from fa_maint_schedule_dtl
      where schedule_id = p_schedule_id;

begin
     p_succeed := TRUE;
     p_events_tbl.delete;

     open events_cursor;
     loop

         fetch events_cursor
         into h_detail_rec;
         exit when events_cursor%NOTFOUND;

         h_count := h_count + 1;
         p_events_tbl(h_count) := h_detail_rec;

     end loop;

     close events_cursor;


exception
      when others then
         if (events_cursor%ISOPEN) then
            close events_cursor;
         end if;
         p_succeed := FALSE;

end load_events_records;


procedure insert_to_fa_maint_events(
             p_asset_id       in number,
             p_book_type_code in varchar2,
             p_event_rec      in event_rec_type,
             p_maint_date     in date,
             p_succeed        out nocopy boolean) is

h_status varchar2(10) := 'DUE';
h_mesg_str   varchar2(2000);

begin

        p_succeed := TRUE;

        insert into fa_maint_events
                    (asset_event_id,
                     asset_id,
                     event_name,
                     description,
                     frequency_in_days,
                     maintenance_date,
                     vendor_id,
                     employee_id,
                     cost,
                     book_type_code,
                     status,
                     schedule_id,
                     created_by,
                     creation_date,
                     last_updated_by,
                     last_update_login,
                     last_update_date,
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
                     attribute15,
                     attribute_category)
              values
                    (fa_maint_events_s.nextval,
                     p_asset_id,
                     p_event_rec.event_name,
                     p_event_rec.description,
                     p_event_rec.frequency_in_days,
                     p_maint_date,
                     p_event_rec.vendor_id,
                     p_event_rec.employee_id,
                     p_event_rec.cost,
                     p_book_type_code,
                     h_status,
                     p_event_rec.schedule_id,
                     p_event_rec.created_by,
                     p_event_rec.creation_date,
                     p_event_rec.last_updated_by,
                     p_event_rec.last_update_login,
                     p_event_rec.last_update_date,
                     p_event_rec.attribute1,
                     p_event_rec.attribute2,
                     p_event_rec.attribute3,
                     p_event_rec.attribute4,
                     p_event_rec.attribute5,
                     p_event_rec.attribute6,
                     p_event_rec.attribute7,
                     p_event_rec.attribute8,
                     p_event_rec.attribute9,
                     p_event_rec.attribute10,
                     p_event_rec.attribute11,
                     p_event_rec.attribute12,
                     p_event_rec.attribute13,
                     p_event_rec.attribute14,
                     p_event_rec.attribute15,
                     p_event_rec.attribute_category);

exception
    when others then
         p_succeed := FALSE;

end insert_to_fa_maint_events;

END FA_MAINTENANCE_PKG;

/
