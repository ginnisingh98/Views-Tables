--------------------------------------------------------
--  DDL for Package Body FND_DELIVERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DELIVERY" as
/* $Header: AFCPDELB.pls 120.0.12010000.11 2014/09/08 20:52:53 ckclark noship $ */


  --
  -- PRIVATE FUNCTIONS
  --


  -- Get user_id for given user_name

   function user_id_f(username varchar2) return number is

        userid number;

        begin

          select user_id into userid
            from fnd_user
           where user_name =  username;

         return userid;


         exception
            when no_data_found then
               return (-1);

         end user_id_f;


  --
  -- PUBLIC FUNCTIONS
  --


   function add_email (subject         in varchar2,
		       from_address    in varchar2,
		       to_address      in varchar2,
		       cc              in varchar2 default null,
		       lang            in varchar2 default null) return boolean is

      begin

	 if (subject is null or from_address is null or to_address is null) then
	    return false;
	 end if;

	 return fnd_request.add_delivery_option(type         => fnd_delivery.type_email,
						p_argument1  => subject,
						p_argument2  => from_address,
						p_argument3  => to_address,
						p_argument4  => cc,
						nls_language => lang);

      end add_email;


   function add_ipp_printer (printer_name in varchar2,
			     copies       in number default null,
			     orientation  in varchar2 default null,
			     username     in varchar2 default null,
			     password     in varchar2 default null,
			     lang         in varchar2 default null) return boolean is
      printer_id   number;

      begin

        select delivery_id
	    into printer_id
	    from fnd_cp_ipp_printers
	    where ipp_printer_name = printer_name;

        return add_ipp_printer(printer_id, copies, orientation, username, password, lang);

      exception
	 when others then
	    return false;

      end add_ipp_printer;


   function add_ipp_printer (printer_id   in number,
			     copies       in number default null,
			     orientation  in varchar2 default null,
			     username     in varchar2 default null,
			     password     in varchar2 default null,
			     lang         in varchar2 default null) return boolean is

      cnt     number;
      svc_key varchar2(16) := null;

      begin

	 if (printer_id is null) then
	    return false;
	 end if;

	 if (orientation is not null and
	     orientation <> fnd_delivery.orientation_portrait and
	     orientation <> fnd_delivery.orientation_landscape) then
	    return false;
	 end if;


         select count(*)
	     into cnt
	     from fnd_cp_ipp_printers
	     where delivery_id = printer_id;

         if (cnt = 0) then
	    return false;
	 end if;

         if (username is not null and password is not null) then
            svc_key := set_temp_credentials(username, password);
         end if;


         return fnd_request.add_delivery_option(type         => fnd_delivery.type_ipp_printer,
						p_argument1  => printer_id,
						p_argument2  => copies,
						p_argument3  => orientation,
						p_argument4  => username,
						p_argument5  => null,
						p_argument6  => svc_key,
						nls_language => lang);


      end add_ipp_printer;



   function add_fax ( server_name   in varchar2,
		      fax_number    in varchar2,
		      username      in varchar2 default null,
	              password      in varchar2 default null,
		      lang          in varchar2 default null) return boolean is

      server_id   number;

      begin

        select delivery_id
	    into server_id
	    from fnd_cp_ipp_printers
	    where ipp_printer_name = server_name;

        return add_fax(server_id, fax_number, username, password, lang);

      exception
	 when others then
	    return false;

      end add_fax;



   function add_fax ( server_id     in number,
		      fax_number    in varchar2,
		      username      in varchar2 default null,
	              password      in varchar2 default null,
		      lang          in varchar2 default null) return boolean is
      cnt   number;
      svc_key varchar2(16) := null;

      begin

         if (server_id is null or fax_number is null) then
	    return false;
	 end if;

         select count(*)
	     into cnt
	     from fnd_cp_ipp_printers
	     where delivery_id = server_id
	     and support_fax = 'Y';

         if (cnt = 0) then
	    return false;
	 end if;

         if (username is not null and password is not null) then
            svc_key := set_temp_credentials(username, password);
         end if;

	 return fnd_request.add_delivery_option(type         => fnd_delivery.type_ipp_fax,
						p_argument1  => server_id,
						p_argument2  => fax_number,
						p_argument3  => username,
						p_argument4  => null,
						p_argument5  => svc_key,
						nls_language => lang);

      end add_fax;



   function add_ftp ( server     in varchar2,
		      username   in varchar2,
		      password   in varchar2,
		      remote_dir in varchar2,
		      port       in varchar2 default null,
		      secure     in boolean default FALSE,
		      lang       in varchar2 default null) return boolean is

      stype    varchar2(1) := fnd_delivery.type_ftp;
      svc_key varchar2(16) := null;

      begin

	 if (secure) then
	    stype := fnd_delivery.type_sftp;
	    if (server is null or username is null or password is null) then
	       return false;
	    end if;
         else
	    if (server is null or username is null or password is null or remote_dir is null) then
	       return false;
	    end if;
	 end if;

         svc_key := set_temp_credentials(username, password);

	 return fnd_request.add_delivery_option(type         => stype,
						p_argument1  => server,
						p_argument2  => username,
						p_argument3  => null,
						p_argument4  => remote_dir,
						p_argument5  => port,
						p_argument8  => svc_key,
						nls_language => lang);

      end add_ftp;



    function add_webdav ( server     in varchar2,
                         remote_dir in varchar2,
                         port       in varchar2 default null,
		         username   in varchar2 default null,
		         password   in varchar2 default null,
		         authtype   in varchar2 default null,
                         enctype    in varchar2 default null,
    		         lang       in varchar2 default null) return boolean is

      svc_key varchar2(16) := null;
      begin

        if (server is null or remote_dir is null) then
            return false;
        end if;

         if (username is not null and password is not null) then
            svc_key := set_temp_credentials(username, password);
         end if;
        return fnd_request.add_delivery_option(type          => fnd_delivery.type_webdav,
						p_argument1  => server,
						p_argument2  => remote_dir,
						p_argument3  => port,
						p_argument4  => username,
						p_argument5  => null,
                                                p_argument6  => authtype,
						p_argument7  => enctype,
						p_argument8  => svc_key,
						nls_language => lang);

      end add_webdav;


   function add_http (   server     in varchar2,
                         remote_dir in varchar2,
                         port       in varchar2 default null,
		         username   in varchar2 default null,
		         password   in varchar2 default null,
		         authtype   in varchar2 default null,
                         enctype    in varchar2 default null,
                         method     in varchar2 default null,
		         lang       in varchar2 default null) return boolean is

        svc_key varchar2(16) := null;
        begin

        if (server is null or remote_dir is null) then
            return false;
        end if;

        if (username is not null and password is not null) then
           svc_key := set_temp_credentials(username, password);
        end if;

        return fnd_request.add_delivery_option(type          => fnd_delivery.type_http,
						p_argument1  => server,
						p_argument2  => remote_dir,
						p_argument3  => port,
						p_argument4  => username,
						p_argument5  => null,
                                                p_argument6  => authtype,
						p_argument7  => enctype,
                                                p_argument8  => method,
                                                p_argument9  => svc_key,
						nls_language => lang);

      end add_http;



    function add_custom ( custom_id  in number,
		          lang       in varchar2 default null) return boolean is

      cnt   number;

      begin

         if (custom_id is null) then
	    return false;
	 end if;

         select count(*)
	     into cnt
	     from fnd_cp_delivery_commands
	     where delivery_id = custom_id;

         if (cnt = 0) then
	    return false;
	 end if;

	 return fnd_request.add_delivery_option(type         => fnd_delivery.type_custom,
						p_argument1  => custom_id,
						nls_language => lang);

      end add_custom;


    function add_custom ( custom_name   in varchar2,
		         lang          in varchar2 default null) return boolean is

      custom_id   number;

      begin

        select delivery_id
	    into custom_id
	    from fnd_cp_delivery_options
	    where delivery_name = custom_name;

        return add_custom(custom_id, lang);

      exception
	 when others then
	    return false;

      end add_custom;

    function add_burst return boolean is

      begin

        return fnd_request.add_delivery_option(type => fnd_delivery.type_burst);

      end add_burst;

    procedure set_smtp_credentials( username  in varchar2,
				    smtp_user in varchar2,
				    smtp_pass in varchar2) is

       svc_key varchar2(30);

       begin

         if (lengthb(username) <= 30) then
         	 svc_key := username;
         else
         	 svc_key := to_char(user_id_f(username));
         end if;
         if (svc_key = '-1') then
            fnd_message.set_name('FND', 'CONC-INVALID USERNAME');
            fnd_message.set_token('USERNAME', username);
            app_exception.raise_exception;
         end if;

         fnd_vault.put(SMTP_SERVICE, svc_key, smtp_user || ':' || smtp_pass);

       end set_smtp_credentials;

    procedure get_smtp_credentials( username  in varchar2,
				    smtp_user out nocopy varchar2,
				    smtp_pass out nocopy varchar2) is

       unpw     varchar2(128);
       svc_key  varchar2(30);

       begin

         if (lengthb(username) <= 30) then
         	 svc_key := username;
         else
         	 svc_key := to_char(user_id_f(username));
         end if;

         unpw := fnd_vault.get(SMTP_SERVICE, svc_key);
	  if (unpw is null) then
	     smtp_user := null;
	     smtp_pass := null;
	     return;
	  end if;

	  smtp_user := substr(unpw, 1, instr(unpw, ':') - 1);
	  smtp_pass := substr(unpw, instr(unpw, ':') + 1);

       end get_smtp_credentials;

    function set_temp_credentials (username in varchar2,
                                   password in varchar2) return varchar2 is
       svc_key varchar2(16);

       begin

          select DELIVERY_SERVICE || to_char(FND_CP_DELIVERY_OPTIONS_S.nextval)
            into svc_key
            from dual;

          fnd_vault.put(svc_key, username, password);

          return svc_key;

       end set_temp_credentials;

    function get_temp_credentials (svc_key  in varchar2,
                                    username in varchar2,
                                    delflag  in varchar2 default 'Y') return varchar2 is

       password varchar2(128);

       begin
          password := fnd_vault.get(svc_key, username);

          if (delflag = 'Y') then
             del_temp_credentials(svc_key, username);
          end if;

          return password;

       end get_temp_credentials;

    procedure del_temp_credentials (svc_key  in varchar2,
                                    username in varchar2) is

       begin

          fnd_vault.del(svc_key, username);

       end del_temp_credentials;



    function has_lob_of_type ( prog_app_name  IN varchar2,
                               conc_prog_name IN varchar2,
                               lob_of_type    IN varchar2,
                               nls_lang       IN varchar2 default null,
                               nls_terry      IN varchar2 default null) return boolean is

       iso_lang   fnd_languages.iso_language%TYPE := null;
       iso_terry  fnd_languages.iso_territory%TYPE := null;
       dummy      number;

       begin

         if nls_lang is not null then
           SELECT distinct upper(iso_language)
             INTO iso_lang
             FROM fnd_languages l
            WHERE upper(l.nls_language) = upper(nls_lang);
         end if;

         if nls_terry is not null then
           SELECT distinct upper(iso_territory)
             INTO iso_terry
             FROM fnd_languages l
            WHERE upper(l.nls_territory) = upper(nls_terry);
         end if;

         SELECT count(*)
           INTO dummy
           FROM xdo_lobs
          WHERE lob_code = upper(conc_prog_name)
            AND application_short_name = upper(prog_app_name)
            AND lob_type = upper(lob_of_type)
            AND upper(language) = decode(language, '00', '00', decode(iso_lang,   null, upper(language), iso_lang))
            AND upper(territory) = decode(territory, '00', '00', decode(iso_terry, null, upper(territory), iso_terry));

         if dummy > 0 then
       	    return true;
         else
       	    return false;
         end if;

      exception
	 when others then
	    return false;

      end has_lob_of_type;

   function has_lob_of_type (  reqid          IN number,
                               lob_of_type    IN varchar2)  return boolean is

       prog_app_name  fnd_application.application_short_name%TYPE;
       conc_prog_name fnd_concurrent_programs.concurrent_program_name%TYPE;
       nls_lang       fnd_concurrent_requests.nls_language%TYPE;
       nls_terry      fnd_concurrent_requests.nls_territory%TYPE;

       begin

         SELECT a.application_short_name, p.concurrent_program_name,
                r.nls_language, r.nls_territory
           INTO prog_app_name, conc_prog_name,
                nls_lang, nls_terry
           FROM fnd_concurrent_requests r, fnd_concurrent_programs p,
                fnd_application a
          WHERE r.program_application_id = p.application_id
            AND r.concurrent_program_id = p.concurrent_program_id
            AND p.application_id = a.application_id
            AND r.request_id = reqid;

       return (has_lob_of_type(prog_app_name, conc_prog_name, lob_of_type, nls_lang, nls_terry));

      exception
	 when others then
	    return false;

      end has_lob_of_type;

   function has_delivery_of_type ( reqid          IN number,
                                   delivery_type  IN varchar2)  return boolean is

       dummy  number;

       begin

         SELECT count(*)
           INTO dummy
          FROM fnd_conc_pp_actions pp,
                fnd_concurrent_requests cr
          WHERE pp.concurrent_request_id = reqid
            AND pp.argument1= delivery_type
            AND pp.concurrent_request_id = cr.request_id
            AND action_type in (7,8);

         if dummy > 0 then
       	    return true;
       	 end if;

         SELECT count(*)
           INTO dummy
           FROM fnd_run_req_pp_actions rr
          WHERE rr.parent_request_id = reqid
            AND rr.argument1= delivery_type
            AND action_type in (7,8);

         if dummy > 0 then
       	    return true;
         else
       	    return false;
         end if;

      exception
	 when others then
	    return false;

      end has_delivery_of_type;


   function post_processing_results ( reqid          IN number )
                                                  return varchar2 is

    i number;
    len_sum number;
    len_each number;
    len_save number;
    concat_rows varchar2(32767);

    -- Use tokens to create headers...
    publisher_breaker varchar2(100);
    plen_breaker number;
    delivery_breaker varchar2(100);
    dlen_breaker number;
    burst_breaker varchar2(100);
    blen_breaker number;
    l_newline varchar2(10);
    no_results varchar2(25);
    nr_len number;

    cursor c1 is
         select publisher_return_results, action_type, argument1
           from FND_CONC_PP_ACTIONS
          where concurrent_request_id = reqid
            and action_type >= 6
       order by action_type, argument1;

   begin
      i := 0;
      l_newline := fnd_global.newline;

      -- Get headers
      fnd_message.set_name('FND', 'FND-PUBLISHER_HEADER');
      publisher_breaker := fnd_message.get;
      plen_breaker := lengthb(publisher_breaker);
      fnd_message.set_name('FND', 'FND-DELIVERY_HEADER');
      delivery_breaker := fnd_message.get;
      dlen_breaker := lengthb(delivery_breaker);
      fnd_message.set_name('FND', 'FND-BURST_HEADER');
      burst_breaker := fnd_message.get;
      blen_breaker := lengthb(burst_breaker);
      fnd_message.set_name('FND', 'FND_DEF_ALTERNATE_TEXT');
      no_results := fnd_message.get;
      nr_len := lengthb(no_results);

      len_sum := 0;

      for l_rec in c1 loop
         if (l_rec.publisher_return_results is null) then
            if (l_rec.action_type = 6) then
               concat_rows := concat_rows||l_newline||publisher_breaker||l_newline||no_results||l_newline;
               len_sum := len_sum + plen_breaker + nr_len + 6;
            elsif (l_rec.action_type = 7) then
                concat_rows := concat_rows||l_newline||delivery_breaker||l_newline||no_results||l_newline;
                len_sum := len_sum + dlen_breaker + nr_len + 6;
            elsif (l_rec.action_type = 8) then
                concat_rows := concat_rows||l_newline||burst_breaker||l_newline||no_results||l_newline;
                len_sum := len_sum + blen_breaker + nr_len + 6;
            else
                concat_rows := concat_rows||l_newline||no_results||l_newline;
                len_sum := len_sum + nr_len + 4;
            end if;
         else
            len_each := lengthb(l_rec.publisher_return_results);
            if ((len_sum + len_each + plen_breaker) <= 32767) then
               if (l_rec.action_type = 6) then
                  concat_rows := concat_rows||l_newline||publisher_breaker||l_newline||
                                 l_rec.publisher_return_results||l_newline;
                      len_sum := len_sum + plen_breaker + len_each + 6;
                elsif (l_rec.action_type = 7) then
                    concat_rows := concat_rows||l_newline||delivery_breaker||l_newline||
                                   l_rec.publisher_return_results||l_newline;
                    len_sum := len_sum + dlen_breaker + len_each + 6;
                elsif (l_rec.action_type = 8) then
                    concat_rows := concat_rows||l_newline||burst_breaker||l_newline||
                                   l_rec.publisher_return_results||l_newline;
                    len_sum := len_sum + blen_breaker + len_each + 6;
                else
                    concat_rows := concat_rows||l_newline||
                                   l_rec.publisher_return_results||l_newline;
                    len_sum := len_sum + len_each + 4;
                end if;
            else
                len_save := 32767 - (plen_breaker + len_sum + 6);
                if (len_save > 0) then
                   if (l_rec.action_type = 6) then
                       concat_rows := concat_rows||l_newline||publisher_breaker||l_newline||
                                      substr(l_rec.publisher_return_results,1,len_save)||l_newline;
                       len_sum := len_sum + plen_breaker + len_save + 6;
                   elsif (l_rec.action_type = 7) then
                       concat_rows := concat_rows||l_newline||delivery_breaker||l_newline||
                                      substr(l_rec.publisher_return_results,1,len_save)||l_newline;
                       len_sum := len_sum + dlen_breaker + len_save + 6;
                   elsif (l_rec.action_type = 8) then
                       concat_rows := concat_rows||l_newline||burst_breaker||l_newline||
                                      substr(l_rec.publisher_return_results,1,len_save)||l_newline;
                       len_sum := len_sum + blen_breaker + len_save + 6;
                   else
                       concat_rows := concat_rows||l_newline||
                                      substr(l_rec.publisher_return_results,1,len_save)||l_newline;
                       len_sum := len_sum + len_save + 4;

                   end if;
                end if;
            end if;
            i := i + 1;
         end if;
      end loop;

      return concat_rows;

      exception
	 when others then
	    return concat_rows;

   end post_processing_results;

end FND_DELIVERY;

/
