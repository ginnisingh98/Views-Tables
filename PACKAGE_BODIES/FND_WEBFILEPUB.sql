--------------------------------------------------------
--  DDL for Package Body FND_WEBFILEPUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WEBFILEPUB" as
/* $Header: AFCPWFPB.pls 120.5 2006/07/19 20:21:11 tkamiya ship $ */

g_nlslang  varchar2(30) := '';
g_nlsterr  varchar2(30) := '';


procedure get_nls_values( id IN varchar2)
is
begin
     g_nlslang := '';
     g_nlsterr := '';

     select r.nls_language,
            r.nls_territory
       into g_nlslang, g_nlsterr
       from fnd_concurrent_requests r,
            fnd_file_temp t
      where t.request_id = r.request_id
        and t.file_id = id;

     exception
        when others then
           null;

end get_nls_values;

procedure verify_id(	id   IN varchar2,
                        name IN OUT NOCOPY varchar2,
                        node IN OUT NOCOPY varchar2)
is
  dummy4 fnd_file_temp.mime_type%TYPE;
  dummy5 fnd_file_temp.transfer_mode%TYPE;
  dummy6 fnd_file_temp.request_id%TYPE;
  dummy7 fnd_file_temp.destination_file%TYPE;
  dummy8 fnd_file_temp.destination_node%TYPE;
  dummy9 fnd_file_temp.transfer_type%TYPE;
  dummy10 varchar2(254);

begin

        verify_id (id, name, node, dummy4,
                   dummy5, dummy6, dummy7,
                   dummy8, dummy9, dummy10);

end verify_id;

procedure verify_id(	id	IN varchar2,
			name 	IN OUT NOCOPY varchar2,
                        node 	IN OUT NOCOPY varchar2,
			type    IN OUT NOCOPY varchar2,
			x_mode	IN OUT NOCOPY varchar2)
is
  dummy6 fnd_file_temp.request_id%TYPE;
  dummy7 fnd_file_temp.destination_file%TYPE;
  dummy8 fnd_file_temp.destination_node%TYPE;
  dummy9 fnd_file_temp.transfer_type%TYPE;
  dummy10 varchar2(254);
begin

        verify_id (id, name, node, type,
                   x_mode, dummy6, dummy7,
                   dummy8, dummy9, dummy10);

end verify_id;


procedure verify_id(	id	IN varchar2,
			name 	IN OUT NOCOPY varchar2,
                        node 	IN OUT NOCOPY varchar2,
			type    IN OUT NOCOPY varchar2,
			x_mode  IN OUT NOCOPY varchar2,
			req_id  IN OUT NOCOPY varchar2)
is
  dummy7 fnd_file_temp.destination_file%TYPE;
  dummy8 fnd_file_temp.destination_node%TYPE;
  dummy9 fnd_file_temp.transfer_type%TYPE;
  dummy10 varchar2(254);

begin
        verify_id (id, name, node, type,
                   x_mode, req_id, dummy7,
                   dummy8, dummy9, dummy10);

end verify_id;


procedure verify_id(	id	IN varchar2,
			name 	IN OUT NOCOPY varchar2,
                        node 	IN OUT NOCOPY varchar2,
			type    IN OUT NOCOPY varchar2,
			x_mode  IN OUT NOCOPY varchar2,
			req_id  IN OUT NOCOPY varchar2,
			dest_file IN OUT NOCOPY varchar2,
                        dest_node IN OUT NOCOPY varchar2,
                        tran_type IN OUT NOCOPY varchar2,
			svc_prefix IN OUT NOCOPY varchar2)
is
begin
	select filename, node_name, mime_type, transfer_mode, request_id,
               destination_file, destination_node, NVL(transfer_type, 'R')
	into name, node, type, x_mode, req_id, dest_file, dest_node, tran_type
	from fnd_file_temp
	where 	file_id = id AND
		sysdate <= expires
        for     update;

	delete from fnd_file_temp
	where 	file_id = id OR
		sysdate > expires;
	commit;

        svc_prefix := fnd_profile.value('FS_SVC_PREFIX');

        if ( type = 'apps/bidi' ) then
           get_nls_values(id);
        end if;

	exception
		when NO_DATA_FOUND then
			name := '';
			node := '';
			type := '';
			x_mode := '';
			req_id := -1;
                        dest_file := '';
                        dest_node := '';
                        tran_type := '';
                        svc_prefix := '';

end verify_id;

procedure char_mapping( charset IN OUT NOCOPY varchar2)
is
begin
	select distinct tag
        into charset
        from fnd_lookup_values
        where lookup_code = charset
        and lookup_type = 'FND_ISO_CHARACTER_SET_MAP';
	exception
		when NO_DATA_FOUND then
			charset := '';

end char_mapping;

procedure req_outfile_name( id IN varchar2,
			     outfile_name IN OUT NOCOPY varchar2)
is
   temp_name varchar2(40);
   file_type varchar2(10);
   file_ext  varchar2(10);
   invalid_chr varchar2(40):=' !@#$%^&*()_+|~`\=-{}][:";<>.,?/''';
   replace_chr varchar2(40):='_________________________________';
   client_file_chrset varchar2(20);
   database_chrset    varchar2(20);

begin
   client_file_chrset := upper(fnd_profile.value('FND_CLIENT_FILENAME_CHRSET'));
   if (client_file_chrset IS NULL) then
--
-- bug4509818 - replace all non-numeric and non-alphabetic characters in
--              user_concurrent_program_name with _ before forming
--              temp file name
--
-- bug3436814 - allow NLS characters for filename and convert the characterset
--              for the filename so client OS can handle it....
--              Japanese version of Windows require filename to be in JA16SJIS codeset.
--              Peform cnversion only if profile option Concurrent: Client Filename
--              Characterset is set and characterset of data is not already in the
--              specified characterset.
--
--              Revert back to old functionality if the profile option value is NULL
--
--              moved illegal characterset conversion bug fix4509818 down a little
--
--
-- old functionality
-- profile option is NULL
-- filenames in English only
--
     select substrb(p.user_concurrent_program_name,1,30) || '_' ||
             to_char(r.Actual_Start_Date,'ddmmrr'),
             DECODE(o.file_name, t.filename, o.file_type,
                    DECODE(r.outfile_name, t.filename,
                          NVL(r.output_file_type, 'TEXT'), 'TEXT'))
       into temp_name, file_type
       from fnd_concurrent_programs_vl p,
            fnd_concurrent_requests r,
            fnd_conc_req_outputs o,
            fnd_file_temp t
      where p.concurrent_program_id = r.concurrent_program_id
        and p.application_id = r.program_application_id
        and t.request_id = r.request_id
        and r.request_id = o.concurrent_request_id(+)
        and t.file_id = id;
   else
--
-- new functionality
-- profile option is set to OS filename characterset
-- nls filename allowed
--
     select substrb(p.user_concurrent_program_name,1,30) || '_' ||
             to_char(r.Actual_Start_Date,'ddmmrr'),
             DECODE(o.file_name, t.filename, o.file_type,
                    DECODE(r.outfile_name, t.filename,
                          NVL(r.output_file_type, 'TEXT'), 'TEXT'))
       into temp_name, file_type
       from fnd_concurrent_programs_tl p,
            fnd_concurrent_requests r,
            fnd_conc_req_outputs o,
            fnd_file_temp t,
            fnd_languages l
      where p.concurrent_program_id = r.concurrent_program_id
        and p.application_id = r.program_application_id
        and t.request_id = r.request_id
        and r.request_id = o.concurrent_request_id(+)
        and t.file_id = id
        and p.language = l.language_code
        and r.nls_language = l.nls_language;

      select value into database_chrset
      from v$nls_parameters
      where parameter = 'NLS_CHARACTERSET';

      --
      -- not necessary to do a code conversion if database is already in
      -- the same characterset as specified in profile option
      --
      if (client_file_chrset <> database_chrset) then
           temp_name := convert(temp_name, client_file_chrset, database_chrset);
      end if;

   end if;

--
-- remove characters that are illegal in filenames
--
   temp_name := translate(temp_name, invalid_chr, replace_chr);

     -- hardcoded values for file extentions needs to be removed in major
     -- release.

     if ( file_type in ('TEXT', 'ETEXT') ) then
        file_ext := 'txt';
     elsif ( file_type = 'HTML') then
        file_ext := 'html';
     elsif ( file_type = 'PDF' ) then
        file_ext := 'pdf';
     elsif ( file_type = 'PS' ) then
        file_ext := 'ps';
     elsif ( file_type = 'PCL' ) then
        file_ext := 'pcl';
     elsif ( file_type = 'XML' ) then
        file_ext := 'xml';
     elsif ( file_type = 'EXCEL' ) then
        file_ext := 'xls';
     elsif ( file_type = 'RTF' ) then
        file_ext := 'rtf';

     end if;

     outfile_name := temp_name || '.' || file_ext;

    exception
       when others then
            outfile_name := '';

end req_outfile_name;

procedure req_nls_values( nlslang IN OUT NOCOPY varchar2,
                          nlsterr IN OUT NOCOPY varchar2)
is
begin
     nlslang := g_nlslang;
     nlsterr := g_nlsterr;
end req_nls_values;


procedure check_id( id         IN     varchar2,
                    name       IN OUT NOCOPY varchar2,
                    node       IN OUT NOCOPY varchar2,
                    type       IN OUT NOCOPY varchar2,
                    x_mode     IN OUT NOCOPY varchar2,
                    req_id     IN OUT NOCOPY varchar2,
                    dest_file  IN OUT NOCOPY varchar2,
                    dest_node  IN OUT NOCOPY varchar2,
                    tran_type  IN OUT NOCOPY varchar2,
                    svc_prefix IN OUT NOCOPY varchar2,
                    ncenc      IN OUT NOCOPY varchar2)
is
   dummy   varchar2(1);
begin
   check_id(id, name, node, type, x_mode, req_id, dest_file,
            dest_node, tran_type, svc_prefix, ncenc, dummy);

end check_id;



procedure check_id( id         IN     varchar2,
                    name       IN OUT NOCOPY varchar2,
                    node       IN OUT NOCOPY varchar2,
                    type       IN OUT NOCOPY varchar2,
                    x_mode     IN OUT NOCOPY varchar2,
                    req_id     IN OUT NOCOPY varchar2,
                    dest_file  IN OUT NOCOPY varchar2,
                    dest_node  IN OUT NOCOPY varchar2,
                    tran_type  IN OUT NOCOPY varchar2,
                    svc_prefix IN OUT NOCOPY varchar2,
                    ncenc      IN OUT NOCOPY varchar2,
		    enable_log IN OUT NOCOPY varchar2)
is
begin
    select filename, node_name, mime_type, transfer_mode, request_id,
               destination_file, destination_node,
               NVL(transfer_type, 'R'), NVL(native_client_encoding, 'UNDEF'),
               NVL(enable_logging, 'N')
    into  name, node, type, x_mode, req_id,
          dest_file, dest_node,
          tran_type, ncenc, enable_log
    from  fnd_file_temp
    where file_id = id and
          sysdate <= expires
    for   update;

    if ( type = 'apps/bidi' ) then
       get_nls_values(id);
    end if;

    delete from fnd_file_temp
	where  sysdate > expires;
	commit;

    svc_prefix := fnd_profile.value('FS_SVC_PREFIX');

    exception
        when NO_DATA_FOUND then
            name := '';
            node := '';
            type := '';
            x_mode := '';
            req_id := -1;
            dest_file := '';
            dest_node := '';
            tran_type := '';
            svc_prefix := '';
	    ncenc := '';
	    enable_log := 'N';

end check_id;

-- overloaded procedure for 11.0 compatibility
procedure check_id( id         IN     varchar2,
                    name       IN OUT NOCOPY varchar2,
                    node       IN OUT NOCOPY varchar2,
                    type       IN OUT NOCOPY varchar2,
                    x_mode     IN OUT NOCOPY varchar2,
                    req_id     IN OUT NOCOPY varchar2)
is
  dummy7    fnd_file_temp.destination_file%TYPE;
  dummy8    fnd_file_temp.destination_node%TYPE;
  dummy9    fnd_file_temp.transfer_type%TYPE;
  dummy10   varchar2(254);
  dummy11   fnd_file_temp.native_client_encoding%TYPE;
  dummy12   varchar2(1);

begin

        check_id(id, name, node, type, x_mode, req_id,
                 dummy7, dummy8, dummy9, dummy10, dummy11, dummy12);

end check_id;



procedure get_page_info(	id	     IN varchar2,
			                name 	 IN OUT NOCOPY varchar2,
			                pagenum  IN OUT NOCOPY number,
			                pagesize IN OUT NOCOPY number)
is
begin
	select filename, page_number, page_size
	into   name, pagenum, pagesize
	from   fnd_file_temp
	where  file_id = id
	and    sysdate <= expires
    for    update;

	delete from fnd_file_temp
	where  file_id = id
	or     sysdate > expires;

	commit;



	exception
		when NO_DATA_FOUND then
			name := '';
			pagenum := 0;
			pagesize := 0;


end get_page_info;

end;

/

  GRANT EXECUTE ON "APPS"."FND_WEBFILEPUB" TO "APPLSYSPUB";
