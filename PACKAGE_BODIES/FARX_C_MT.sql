--------------------------------------------------------
--  DDL for Package Body FARX_C_MT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_C_MT" as
/* $Header: FARXCMTB.pls 120.2.12010000.2 2009/07/19 11:53:27 glchen ship $ */

PROCEDURE insert_to_itf (
                p_book	            in    varchar2,
		p_event_name	    in	  varchar2,
	        p_maint_date_from   in    date,
	        p_maint_date_to     in    date,
 	        p_asset_number_from in    varchar2,
	        p_asset_number_to   in    varchar2,
	        p_dpis_from	    in    date,
	        p_dpis_to 	    in    date,
	        p_cat_id	    in    number,
                p_request_id        in    number,
		retcode 	    out nocopy   varchar2,
		errbuf 		    out nocopy   varchar2) is


  h_cat_structure	number;
  h_loc_structure	number;
  h_key_structure	number;
  h_cat_ccid		number := NULL;

  h_request_id		number;
  h_login_id		number;
  h_user_id		number;
  h_mesg_str		varchar2(2000);
  h_mesg_name		varchar2(50);

  h_concat_cat		varchar2(500);
  h_concat_loc		varchar2(500);
  h_concat_key		varchar2(500);
  h_cat_segs		fa_rx_shared_pkg.Seg_Array;
  h_loc_segs		fa_rx_shared_pkg.Seg_Array;
  h_key_segs		fa_rx_shared_pkg.Seg_Array;


  cursor c_assets is
  select distinct me.asset_event_id,ad.asset_id,ad.asset_number,ad.description,ad.serial_number,
         ad.tag_number, ad.manufacturer_name,ad.model_number,ad.asset_category_id,
         ad.asset_key_ccid, dh.location_id location_id,
         bk.cost asset_cost,bk.book_type_code,me.event_name,me.cost maint_cost,
	 me.maintenance_date,emp1.full_name warr_contact_name,emp1.employee_number warr_contact_number,
         po.vendor_name,po.segment1 vendor_number, war.warranty_number,war.description war_desc,
         war.start_date,war.end_date,emp2.full_name maint_contact_name,
         emp2.employee_number maint_contact_number

  from fa_additions ad,
       fa_distribution_history dh,
       po_vendors po,
       per_people_x emp1,
       per_people_x emp2,
       fa_warranties war,
       fa_add_warranties adw,
       fa_books bk,
       fa_maint_events me
  where me.book_type_code = p_book and
	me.event_name = nvl(p_event_name, me.event_name) and
        me.maintenance_date between
           nvl(p_maint_date_from,me.maintenance_date) and
           nvl(p_maint_date_to,me.maintenance_date) and
        me.asset_id = ad.asset_id and
        ad.asset_number >= nvl(p_asset_number_from,ad.asset_number) and
        ad.asset_number <= nvl(p_asset_number_to,ad.asset_number) and
        ad.asset_category_id = nvl(p_cat_id, ad.asset_category_id) and
        dh.asset_id = ad.asset_id and
        dh.date_ineffective is NULL and
        bk.asset_id = ad.asset_id and
        bk.book_type_code = me.book_type_code and
        bk.date_ineffective is NULL and
	bk.date_placed_in_service between
           nvl(p_dpis_from,bk.date_placed_in_service) and
           nvl(p_dpis_to,bk.date_placed_in_service) and
        adw.asset_id(+) = me.asset_id and
	war.warranty_id(+) = adw.warranty_id and
        emp1.person_id(+) = war.employee_id and
        emp2.person_id(+) = me.employee_id and
        po.vendor_id(+) = me.vendor_id;

  c_mainrec c_assets%rowtype;


  begin

      h_request_id := p_request_id;

      select category_flex_structure,
             location_flex_structure,
             asset_key_flex_structure
      into   h_cat_structure,
             h_loc_structure,
	     h_key_structure
      from   fa_system_controls;


      select fcr.last_update_login,fcr.requested_by
      into   h_login_id,h_user_id
      from  fnd_concurrent_requests fcr
      where fcr.request_id = h_request_id;


/*      if (h_category is not null) then
          --h_value_error := category;
          --h_param_error := 'CATEGORY';
          if fnd_flex_keyval.validate_segs (
        	operation => 'CHECK_COMBINATION',
	        appl_short_name => 'OFA',
	        key_flex_code => 'CAT#',
	        structure_number => h_cat_structure,
	        concat_segments => h_category,
	        values_or_ids  => 'V',
	        validation_date  =>SYSDATE,
	        displayable  => 'ALL',
	        data_set => NULL,
	        vrule => NULL,
	        where_clause => NULL,
	        get_columns => NULL,
	        allow_nulls => FALSE,
	        allow_orphans => FALSE,
	        resp_appl_id => NULL,
	        resp_id => NULL,
	        user_id => NULL) = FALSE then

        	fnd_message.set_name('OFA','FA_WHATIF_NO_CAT');
	        fnd_message.set_token('CAT',p_category,FALSE);
        	h_mesg_str := fnd_message.get;
	        fa_rx_conc_mesg_pkg.log(h_mesg_str);

	        retcode := 2;
	        return;
	  end if;
          h_cat_ccid := fnd_flex_keyval.combination_id;
      end if;

      if (h_location is not null) then
	  --h_value_error := location;
	  --h_param_error := 'LOCATION';

	  if fnd_flex_keyval.validate_segs (
        	operation => 'CHECK_COMBINATION',
	        appl_short_name => 'OFA',
	        key_flex_code => 'LOC#',
	        structure_number => h_loc_structure,
	        concat_segments => h_location,
	        values_or_ids  => 'V',
	        validation_date  =>SYSDATE,
	        displayable  => 'ALL',
	        data_set => NULL,
	        vrule => NULL,
	        where_clause => NULL,
	        get_columns => NULL,
	        allow_nulls => FALSE,
	        allow_orphans => FALSE,
	        resp_appl_id => NULL,
	        resp_id => NULL,
	        user_id => NULL) = FALSE then

	        fnd_message.set_name('OFA','FA_PI_NO_LOCATION');
	        fnd_message.set_token('LOC',p_location,FALSE);
	        h_mesg_str := fnd_message.get;
	        fa_rx_conc_mesg_pkg.log(h_mesg_str);

	        retcode := 2;
	        return;
	  end if;
	  h_loc_ccid := fnd_flex_keyval.combination_id;
      end if;

      if (h_asset_key is not null) then
	  --h_value_error := location;
	  --h_param_error := 'LOCATION';

	  if fnd_flex_keyval.validate_segs (
        	operation => 'CHECK_COMBINATION',
	        appl_short_name => 'OFA',
	        key_flex_code => 'KEY#',
	        structure_number => h_key_structure,
	        concat_segments => h_asset_key,
	        values_or_ids  => 'V',
	        validation_date  =>SYSDATE,
	        displayable  => 'ALL',
	        data_set => NULL,
	        vrule => NULL,
	        where_clause => NULL,
	        get_columns => NULL,
	        allow_nulls => FALSE,
	        allow_orphans => FALSE,
	        resp_appl_id => NULL,
	        resp_id => NULL,
	        user_id => NULL) = FALSE then

	        fnd_message.set_name('OFA','FA_ASSET_MAINT_NO_KEY');
	        fnd_message.set_token('LOC',p_asset_key,FALSE);
	        h_mesg_str := fnd_message.get;
	        fa_rx_conc_mesg_pkg.log(h_mesg_str);

	        retcode := 2;
	        return;
	  end if;
	  h_key_ccid := fnd_flex_keyval.combination_id;
    end if;  */

    open c_assets;
    loop

       fetch c_assets into c_mainrec;

       if (c_assets%NOTFOUND) then
          exit;
       end if;


      -- h_concat_cat := p_category;
       if (c_mainrec.asset_category_id is not null) then

           fa_rx_shared_pkg.concat_category (
              		  struct_id => h_cat_structure,
			  ccid => c_mainrec.asset_category_id,
		          concat_string => h_concat_cat,
		          segarray => h_cat_segs);
       end if;

      -- h_concat_loc := p_location;
       if (c_mainrec.location_id is not null) then

          fa_rx_shared_pkg.concat_location (
        	      struct_id => h_loc_structure,
	              ccid => c_mainrec.location_id,
         	      concat_string => h_concat_loc,
 	              segarray => h_loc_segs);
       end if;

     --  h_concat_key := p_asset_key;
       if (c_mainrec.asset_key_ccid is not null) then

          fa_rx_shared_pkg.concat_asset_key (
          	   	  struct_id => h_key_structure,
		          ccid      => c_mainrec.asset_key_ccid,
		          concat_string => h_concat_key,
		          segarray  => h_key_segs);
       end if;

       h_mesg_name := 'FA_SHARED_INSERT_FAILED';
       insert into fa_maint_rep_itf (
            REQUEST_ID,BOOK_TYPE_CODE,ASSET_ID,ASSET_NUMBER,DESCRIPTION,SERIAL_NUMBER,TAG_NUMBER,
            ASSET_KEY_FF,ASSET_COST,LOCATION_FF,CATEGORY_FF,EVENT_NAME,MAINTENANCE_COST,
            MAINTENANCE_DATE,VENDOR_NAME,VENDOR_NUMBER,CONTACT_NAME,CONTACT_NUMBER,
            WARRANTY_NUMBER,WARRANTY_DESC,WARRANTY_START_DATE,WARRANTY_END_DATE,
            MANUFACTURER_NAME,MODEL_NUMBER,WARRANTY_CONTACT_NAME,WARRANTY_CONTACT_NUMBER,
            LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATED_BY,CREATION_DATE,LAST_UPDATE_LOGIN)
            values (h_request_id,c_mainrec.book_type_code,c_mainrec.asset_id,c_mainrec.asset_number,
            c_mainrec.description,c_mainrec.serial_number,c_mainrec.tag_number,
            h_concat_key,c_mainrec.asset_cost,h_concat_loc,h_concat_cat,c_mainrec.event_name,
            c_mainrec.maint_cost,c_mainrec.maintenance_date,c_mainrec.vendor_name,
            c_mainrec.vendor_number,c_mainrec.maint_contact_name,c_mainrec.maint_contact_number,
            c_mainrec.warranty_number,c_mainrec.war_desc,c_mainrec.start_date,
            c_mainrec.end_date,c_mainrec.manufacturer_name,c_mainrec.model_number,
            c_mainrec.warr_contact_name,c_mainrec.warr_contact_number,sysdate,h_user_id,
            h_user_id,sysdate,h_login_id);

    end loop;

    close c_assets;

    retcode := 0;


  exception
      when others then
         fnd_message.set_name('OFA', h_mesg_name);
         if (h_mesg_name = 'FA_SHARED_INSERT_FAILED') then
	      fnd_message.set_token('TABLE','FA_MAINT_REP_ITF');
	 end if;
         h_mesg_str := fnd_message.get;
         fa_rx_conc_mesg_pkg.log(h_mesg_str);
         retcode := 2;

  end insert_to_itf;



PROCEDURE asset_maintenance (
  errbuf	    out nocopy varchar2,
  retcode	    out nocopy varchar2,
  argument1	    in  varchar2,   -- book
  argument2	    in  varchar2 default  null, -- event_name
  argument3	    in	varchar2 default  null,  -- maint_date_from
  argument4         in  varchar2 default  null,  -- maint_date_to
  argument5         in  varchar2 default  null, -- asset_number_from
  argument6         in  varchar2 default  null,  -- asset_number_to
  argument7         in  varchar2 default  null,  -- dpis_from
  argument8         in  varchar2 default  null,  -- dpis_to
  argument9         in  varchar2 default  null,  -- category flex struct
  argument10        in  varchar2 default  null,  -- category_Id
  argument11        in  varchar2 default  null,
  argument12        in  varchar2 default  null,
  argument13        in  varchar2 default  null,
  argument14        in  varchar2  default  null,
  argument15        in  varchar2  default  null,
  argument16        in  varchar2  default  null,
  argument17        in  varchar2  default  null,
  argument18        in  varchar2  default  null,
  argument19        in  varchar2  default  null,
  argument20        in  varchar2  default  null,
  argument21	    in  varchar2  default  null,
  argument22        in  varchar2  default  null,
  argument23        in  varchar2  default  null,
  argument24        in  varchar2  default  null,
  argument25        in  varchar2  default  null,
  argument26        in  varchar2  default  null,
  argument27        in  varchar2  default  null,
  argument28        in  varchar2  default  null,
  argument29        in  varchar2  default  null,
  argument30        in  varchar2  default  null,
  argument31	    in  varchar2  default  null,
  argument32        in  varchar2  default  null,
  argument33        in  varchar2  default  null,
  argument34        in  varchar2  default  null,
  argument35        in  varchar2  default  null,
  argument36        in  varchar2  default  null,
  argument37        in  varchar2  default  null,
  argument38        in  varchar2  default  null,
  argument39        in  varchar2  default  null,
  argument40        in  varchar2  default  null,
  argument41	    in  varchar2  default  null,
  argument42        in  varchar2  default  null,
  argument43        in  varchar2  default  null,
  argument44        in  varchar2  default  null,
  argument45        in  varchar2  default  null,
  argument46        in  varchar2  default  null,
  argument47        in  varchar2  default  null,
  argument48        in  varchar2  default  null,
  argument49        in  varchar2  default  null,
  argument50        in  varchar2  default  null,
  argument51	    in  varchar2  default  null,
  argument52        in  varchar2  default  null,
  argument53        in  varchar2  default  null,
  argument54        in  varchar2  default  null,
  argument55        in  varchar2  default  null,
  argument56        in  varchar2  default  null,
  argument57        in  varchar2  default  null,
  argument58        in  varchar2  default  null,
  argument59        in  varchar2  default  null,
  argument60        in  varchar2  default  null,
  argument61	    in  varchar2  default  null,
  argument62        in  varchar2  default  null,
  argument63        in  varchar2  default  null,
  argument64        in  varchar2  default  null,
  argument65        in  varchar2  default  null,
  argument66        in  varchar2  default  null,
  argument67        in  varchar2  default  null,
  argument68        in  varchar2  default  null,
  argument69        in  varchar2  default  null,
  argument70        in  varchar2  default  null,
  argument71	    in  varchar2  default  null,
  argument72        in  varchar2  default  null,
  argument73        in  varchar2  default  null,
  argument74        in  varchar2  default  null,
  argument75        in  varchar2  default  null,
  argument76        in  varchar2  default  null,
  argument77        in  varchar2  default  null,
  argument78        in  varchar2  default  null,
  argument79        in  varchar2  default  null,
  argument80        in  varchar2  default  null,
  argument81	    in  varchar2  default  null,
  argument82        in  varchar2  default  null,
  argument83        in  varchar2  default  null,
  argument84        in  varchar2  default  null,
  argument85        in  varchar2  default  null,
  argument86        in  varchar2  default  null,
  argument87        in  varchar2  default  null,
  argument88        in  varchar2  default  null,
  argument89        in  varchar2  default  null,
  argument90        in  varchar2  default  null,
  argument91	    in  varchar2  default  null,
  argument92        in  varchar2  default  null,
  argument93        in  varchar2  default  null,
  argument94        in  varchar2  default  null,
  argument95        in  varchar2  default  null,
  argument96        in  varchar2  default  null,
  argument97        in  varchar2  default  null,
  argument98        in  varchar2  default  null,
  argument99        in  varchar2  default  null,
  argument100       in  varchar2  default null) is


  h_request_id		number;
  h_mesg_str		varchar2(2000);
  h_mesg_name		varchar2(50);
  h_book		varchar2(30);
  h_event_name		varchar2(50);
  h_maint_date_from     date;
  h_maint_date_to	date;
  h_asset_number_from	varchar2(15);
  h_asset_number_to	varchar2(15);
  h_dpis_from		date;
  h_dpis_to		date;

  type segs_arr	is table of varchar2(30)
          index  by binary_integer;
  h_catsegs		segs_arr;
  h_concat_segs		varchar2(200);
  h_cat_structure       number;
  h_cat_ccid		number;
  delim		varchar2(1);

  prog_failed		exception;

  begin

	retcode := 0;

        h_request_id := fnd_global.conc_request_id;
--        fnd_profile.get('USER_ID',h_user_id);

	h_book := argument1;
	h_event_name := argument2;
	if (argument3 is not null) then
	   h_maint_date_from := to_date(argument3,'YYYY/MM/DD HH24:MI:SS');
	end if;
	if (argument4 is not null) then
	   h_maint_date_to := to_date(argument4, 'YYYY/MM/DD HH24:MI:SS');
	end if;
	h_asset_number_from := argument5;
        h_asset_number_to := argument6;
	if (argument7 is not null) then
           h_dpis_from := to_date(argument7,'YYYY/MM/DD HH24:MI:SS');
	end if;
	if (argument8 is not null) then
           h_dpis_to := to_date(argument8, 'YYYY/MM/DD HH24:MI:SS');
	end if;

/*
        h_catsegs(1) := argument9;
        h_catsegs(2) := argument10;
	h_catsegs(3) := argument11;
	h_catsegs(4) := argument12;
	h_catsegs(5) := argument13;
*/

        if (h_book is NULL) then
            h_mesg_name := 'FA_ASSET_MAINT_WRONG_PARAM';
 	    fnd_message.set_name('OFA',h_mesg_name);
      	    h_mesg_str := fnd_message.get;
	    fa_rx_conc_mesg_pkg.log(h_mesg_str);
            raise prog_failed;
        end if;

/*
        select category_flex_structure
        into h_cat_structure
        from fa_system_controls;

        select s.concatenated_segment_delimiter into delim
        FROM fnd_id_flex_structures s, fnd_application a
        WHERE s.application_id = a.application_id
        AND s.id_flex_code = 'CAT#'
        AND s.id_flex_num = h_cat_structure
        AND a.application_short_name = 'OFA';

        h_concat_segs := h_catsegs(1);
        for ctr in 2 .. 5 loop
           if (h_catsegs(ctr) is not null) then
              h_concat_segs :=  h_concat_segs || delim || h_catsegs(ctr);
           end if;
        end loop;


        if (h_concat_segs is not NULL) then
          if fnd_flex_keyval.validate_segs (
        	operation => 'CHECK_COMBINATION',
	        appl_short_name => 'OFA',
	        key_flex_code => 'CAT#',
	        structure_number => h_cat_structure,
	        concat_segments => h_concat_segs,
	        values_or_ids  => 'V',
	        validation_date  =>SYSDATE,
	        displayable  => 'ALL',
	        data_set => NULL,
	        vrule => NULL,
	        where_clause => NULL,
	        get_columns => NULL,
	        allow_nulls => FALSE,
	        allow_orphans => FALSE,
	        resp_appl_id => NULL,
	        resp_id => NULL,
	        user_id => NULL) = FALSE then

        	fnd_message.set_name('OFA','FA_WHATIF_NO_CAT');
	        fnd_message.set_token('CAT',h_concat_segs,FALSE);
        	h_mesg_str := fnd_message.get;
	        fa_rx_conc_mesg_pkg.log(h_mesg_str);
                raise prog_failed;
	  end if;
          h_cat_ccid := fnd_flex_keyval.combination_id;
        end if;
*/
	if (argument10 is not null) then
	   h_cat_ccid := to_number(argument10);
	end if;

        insert_to_itf (
        		p_book		  => h_book,
			p_event_name	  => h_event_name,
	        	p_maint_date_from => h_maint_date_from,
		        p_maint_date_to   => h_maint_date_to,
		        p_asset_number_from => h_asset_number_from,
		        p_asset_number_to => h_asset_number_to,
		        p_dpis_from	=> h_dpis_from,
		        p_dpis_to 	=> h_dpis_to,
		        p_cat_id	=> h_cat_ccid,
		        p_request_id	=> h_request_id,
			retcode 	=> retcode,
			errbuf 		=> errbuf);

        if (retcode <> 0) then
	     raise prog_failed;
	end if;

        commit;
	retcode := 0;

   exception
          when prog_failed then
	  retcode := 2;

   when others then
          fnd_message.set_name('OFA', 'FA_SHARED_SERVER_ERROR');
          h_mesg_str := fnd_message.get;
          fa_rx_conc_mesg_pkg.log(h_mesg_str);
          retcode := 2;


  end asset_maintenance;


  procedure do_insert(
                p_book	            in    varchar2,
		p_event_name	    in	  varchar2,
	        p_maint_date_from   in    date,
	        p_maint_date_to     in    date,
 	        p_asset_number_from in    varchar2,
	        p_asset_number_to   in    varchar2,
		p_dpis_from	    in    date,
		p_dpis_to	    in	  date,
		p_category_id	    in    varchar2,
		p_request_id	    in    number,
		p_retcode	    out nocopy   number) is


  h_maint_date_from     date;
  h_maint_date_to       date;
  h_dpis_from           date;
  h_dpis_to             date;
  h_errbuf              varchar2(200);
  h_mesg_name		varchar2(50);
  h_err_msg		varchar2(2000);
  h_cat_id		number;
  prog_failed	       exception;

  begin
        p_retcode := 0;

        --h_maint_date_from := fnd_date.canonical_to_date(p_maint_date_from);
        --h_maint_date_to := fnd_date.canonical_to_date(p_maint_date_to);
        --h_dpis_from := fnd_date.canonical_to_date(p_dpis_from);
        --h_dpis_to := fnd_date.canonical_to_date(p_dpis_to);
          h_maint_date_from := p_maint_date_from;
          h_maint_date_to := p_maint_date_to;
          h_dpis_from := p_dpis_from;
          h_dpis_to := p_dpis_to;

        if (p_book is NULL) then
            h_mesg_name := 'FA_ASSET_MAINT_WRONG_PARAM';
            fnd_message.set_name('OFA',h_mesg_name);
            h_err_msg := fnd_message.get;
            fa_rx_conc_mesg_pkg.log(h_err_msg);
            p_retcode := 2;
            raise prog_failed;
        end if;

        h_cat_id := to_number(p_category_id);

    insert_to_itf(p_book            => p_book,
		  p_event_name	    => p_event_name,
                  p_maint_date_from => h_maint_date_from,
                  p_maint_date_to   => h_maint_date_to,
                  p_asset_number_from => p_asset_number_from,
                  p_asset_number_to   => p_asset_number_to,
                  p_dpis_from     => h_dpis_from,
                  p_dpis_to       => h_dpis_to,
                  p_cat_id      => h_cat_id,
                  p_request_id    => p_request_id,
                  retcode 	  => p_retcode,
                  errbuf 	  => h_errbuf);

    if (p_retcode <> 0) then
	raise prog_failed;
    end if;

   p_retcode := 0;
exception
    when prog_failed then
        raise;

    when others then
        raise;

end do_insert;

END FARX_C_MT;

/
