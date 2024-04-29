--------------------------------------------------------
--  DDL for Package Body FA_MAINT_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MAINT_PURGE_PKG" as
/* $Header: FAXMTPRB.pls 120.1.12010000.2 2009/07/19 11:24:10 glchen ship $ */

h_progname 	varchar2(30) := 'Asset Maintenance Purge';

procedure do_purge(
		errbuf		  out nocopy varchar2,
                retcode           out nocopy varchar2,
		argument1 	  in  varchar2,   -- book_type_code
	  	argument2         in  varchar2,   -- from asset number
		argument3         in  varchar2,   -- to asset number
	  	argument4         in  varchar2,   -- from date
	  	argument5         in  varchar2,   -- to date
	  	argument6         in  varchar2,   -- category_id
	  	argument7         in  varchar2,   -- status
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


   h_mesg_str          varchar2(2000);
   h_mesg_name	      varchar2(30);
   h_book_type_code       varchar2(30);
   h_from_date         date;
   h_to_date          date;
   h_from_asset_number varchar2(15);
   h_to_asset_number   varchar2(15);
   h_status	       varchar2(10);
   h_category_id       number;
   h_cat_struct_id     number;
   h_concat_string     varchar2(500);
   h_cat_segs	       FA_RX_SHARED_PKG.Seg_Array;
   h_arg_exist         boolean:= FALSE;
   savepoint_set       boolean:= FALSE;
   prog_failed	       exception;

/*   cursor for assets_to_purge is
   select me.schedule_id
   from fa_maint_events me,
        fa_additions ad
   where ad.asset_number >= nvl(h_from_asset_number,ad.asset_number) and
         ad.asset_number <= nvl(h_to_asset_number,ad.asset_number) and
         ad.category_id = nvl(h_category_id,ad.category_id) and
         ad.asset_id = me.asset_id and
         me.schedule_id = nvl(h_schedule_id,me.schedule_id) and
         me.maintenance_date between nvl(h_from_date,me.maintenance_date) and
                                     nvl(h_to_date,me.maintenance_date) and
         me.status = nvl(h_status,me.status); */


BEGIN

    retcode := 0;

--  print out arguments

    SELECT  category_flex_structure
    INTO    h_cat_struct_id
    FROM    fa_system_controls;

    fnd_message.set_name('OFA','FA_ASSET_MAINT_PURARG_LIST');
    fnd_message.set_token('SCHID', argument1, FALSE);
    fnd_message.set_token('FROM_ASSET', argument2, FALSE);
    fnd_message.set_token('TO_ASSET', argument3,FALSE);
    fnd_message.set_token('FROM_DATE', fnd_date.date_to_chardate(
                                       fnd_date.canonical_to_date(argument4)),FALSE);
    fnd_message.set_token('TO_DATE', fnd_date.date_to_chardate(
                                     fnd_date.canonical_to_date(argument5)),FALSE);
--    fa_rx_shared_pkg.concat_category(h_cat_struct_id,to_number(argument6),
--                                     h_concat_string,h_cat_segs);
    fnd_message.set_token('CAT',argument6,FALSE);
    fnd_message.set_token('STAT',argument7,FALSE);
    h_mesg_str := fnd_message.get;
    fa_rx_conc_mesg_pkg.log(h_mesg_str);
    fa_rx_conc_mesg_pkg.log('');


-- check if valid arguments are passed into the program

    if (argument1 is not NULL) then
        h_book_type_code := argument1;
        h_arg_exist := TRUE;
    end if;

    if (argument2 is not NULL and
        argument3 is not NULL) then
        h_from_asset_number := argument2;
        h_to_asset_number := argument3;
        h_arg_exist := TRUE;
    elsif ((argument2 is NULL and argument3 is not NULL) or
          (argument2 is not NULL and argument3 is NULL)) then
       fnd_message.set_name('OFA','FA_ASSET_MAINT_WRONG_PARAM');
       h_mesg_str := fnd_message.get;
       fa_rx_conc_mesg_pkg.log(h_mesg_str);
       fa_rx_conc_mesg_pkg.log('');
       fa_rx_conc_mesg_pkg.out(h_mesg_str);
       fa_rx_conc_mesg_pkg.out('');
       retcode := 2;
       raise prog_failed;
    end if;

    if (argument4 is not NULL and
        argument5 is not NULL) then
        h_from_date := fnd_date.canonical_to_date(argument4);
        h_to_date := fnd_date.canonical_to_date(argument5);
        h_arg_exist := TRUE;
    elsif ((argument4 is NULL and argument5 is not NULL) or
          (argument4 is not NULL and argument5 is NULL)) then
        fnd_message.set_name('OFA','FA_ASSET_MAINT_WRONG_PARAM');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);
        fa_rx_conc_mesg_pkg.log('');
        fa_rx_conc_mesg_pkg.out(h_mesg_str);
        fa_rx_conc_mesg_pkg.out('');
        retcode := 2;
        raise prog_failed;
    end if;

    if (argument6 is not NULL) then
        h_category_id := to_number(argument6);
        h_arg_exist := TRUE;
    end if;

    if (argument7 is not NULL) then
        h_status := argument7;
        h_arg_exist := TRUE;
    end if;

    if (NOT h_arg_exist) then
        fnd_message.set_name('OFA','FA_ASSET_MAINT_WRONG_PARAM');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);
        fa_rx_conc_mesg_pkg.log('');
        fa_rx_conc_mesg_pkg.out(h_mesg_str);
        fa_rx_conc_mesg_pkg.out('');
        retcode := 2;
        raise prog_failed;
    end if;


-- delete rows from fa_asset_maint table

    h_mesg_name := 'FA_SHARED_DELETE_FAILED';
    savepoint asset_maint;
    savepoint_set := TRUE;

    delete from fa_maint_events me
    where me.book_type_code = nvl(h_book_type_code,me.book_type_code) and
         me.status = nvl(h_status, me.status) and
         me.maintenance_date between nvl(h_from_date,me.maintenance_date) and
                                     nvl(h_to_date,me.maintenance_date) and
         me.asset_id = (select ad.asset_id
                        from fa_additions ad
                        where ad.asset_number >= nvl(h_from_asset_number,ad.asset_number)
                        and ad.asset_number <= nvl(h_to_asset_number,ad.asset_number)
                        and ad.asset_category_id = nvl(h_category_id,ad.asset_category_id)
                        and ad.asset_id = me.asset_id);


   fnd_message.set_name('OFA', 'FA_SHARED_END_SUCCESS');
   fnd_message.set_token('PROGRAM',h_progname,FALSE);
   h_mesg_str := fnd_message.get;
   fa_rx_conc_mesg_pkg.log(h_mesg_str);
   fa_rx_conc_mesg_pkg.log('');
   fa_rx_conc_mesg_pkg.out(h_mesg_str);

   retcode := 0;

EXCEPTION
   when prog_failed then
        if (savepoint_set) then
           rollback to savepoint asset_maint;
	end if;
      	fnd_message.set_name('OFA', 'FA_SHARED_END_WITH_ERROR');
        fnd_message.set_token('PROGRAM',h_progname,FALSE);
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);
	fa_rx_conc_mesg_pkg.out(h_mesg_str);
        retcode := 2;

   when others then
        if (savepoint_set) then
            rollback to savepoint asset_maint;
	end if;
        fnd_message.set_name('OFA',h_mesg_name);
        fnd_message.set_token('TABLE','FA_MAINT_EVENTS',FALSE);
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);
	fa_rx_conc_mesg_pkg.log('');

	fnd_message.set_name('OFA', 'FA_SHARED_END_WITH_ERROR');
        fnd_message.set_token('PROGRAM',h_progname,FALSE);
	h_mesg_str := fnd_message.get;
	fa_rx_conc_mesg_pkg.log(h_mesg_str);
	fa_rx_conc_mesg_pkg.out(h_mesg_str);
        retcode := 2;

END do_purge;


END FA_MAINT_PURGE_PKG;

/
