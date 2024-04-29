--------------------------------------------------------
--  DDL for Package Body ECX_TP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_TP_API" AS
-- $Header: ECXTPXAB.pls 120.5 2006/10/11 05:23:47 gsingh ship $


Procedure retrieve_trading_partner(
                                x_return_status         OUT NOCOPY Pls_integer,
                                x_msg                   OUT NOCOPY Varchar2,
                                x_tp_header_id          OUT NOCOPY Pls_integer,
				p_party_type   		IN  Varchar2,
				p_party_id     		IN  Varchar2,
				p_party_site_id 	IN  Varchar2,
                                x_company_admin_email	OUT NOCOPY Varchar2,
				x_created_by		OUT NOCOPY Varchar2,
				x_creation_date		OUT NOCOPY Varchar2,
				x_last_updated_by	OUT NOCOPY Varchar2,
				x_last_update_date	OUT NOCOPY Varchar2
) IS
Begin
      x_return_status := ECX_UTIL_API.G_NO_ERROR;
      x_msg := null;
      x_tp_header_id := -1;
   -- make sure party_id, party_type, party_site_id are not null.
      If (p_party_type is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
 	  x_msg := ecx_debug.getTranslatedMessage('ECX_PARTY_TYPE_NOT_NULL',
                                                  'p_party_type',p_party_type);
          return;
      elsif
         (p_party_id is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
 	  x_msg := ecx_debug.getTranslatedMessage('ECX_PARTY_ID_NOT_NULL',
                                                  'p_party_id',p_party_id);
          return;
      elsif
         (p_party_site_id is null ) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
 	  x_msg := ecx_debug.getTranslatedMessage('ECX_PARTY_SITE_ID_NOT_NULL',
                                                  'p_party_site_id',p_party_site_id);
          return;
      end if;

      -- make sure p_party_type has a valid value.
      If not(ECX_UTIL_API.validate_party_type(p_party_type)) Then
          x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
          x_msg  := ecx_debug.getTranslatedMessage('ECX_INVALID_PARTY_TYPE',
						'p_party_type',p_party_type);
        return;
      end if;

      -- select data from ECX_TP_HEADERS.
      Select
         TP_HEADER_ID,
         COMPANY_ADMIN_EMAIL,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         CREATED_BY,
         CREATION_DATE
      into
         x_tp_header_id,
         x_company_admin_email,
         x_last_updated_by,
         x_last_update_date,
         x_created_by,
         x_creation_date
      from
         ECX_TP_HEADERS
      where party_type    = p_party_type
      and   party_id      = p_party_id
      and   party_site_id = p_party_site_id;

   Exception
     when no_data_found then
        x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
        x_msg := ecx_debug.getTranslatedMessage('ECX_TP_HDR_NOT_FOUND',
                                   'p_party_type',p_party_type,
                                   'p_party_id', p_party_id ,
                                   'p_party_site_id', p_party_site_id);

     when too_many_rows then
         x_return_status := ECX_UTIL_API.G_TOO_MANY_ROWS;
         x_msg := ecx_debug.getTranslatedMessage('ECX_TP_HDR_TOO_MANY_ROWS',
                                   'p_party_type',p_party_type,
                                   'p_party_id', p_party_id ,
                                   'p_party_site_id', p_party_site_id);
     when others then
        x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
        x_msg := SQLERRM;
   End;

Procedure create_trading_partner(
                                x_return_status         OUT NOCOPY Pls_integer,
                                x_msg                   OUT NOCOPY Varchar2,
                                x_tp_header_id          OUT NOCOPY Pls_integer,
				p_party_type   		IN  Varchar2,
				p_party_id     		IN  Varchar2,
				p_party_site_id 	IN  Varchar2,
                                p_company_admin_email	IN  Varchar2
) IS

l_ret_code   pls_integer := ECX_UTIL_API.G_NO_ERROR;
l_ret_msg    varchar2(2000) := null;
l_event_name varchar2(250) := null;
l_event_key  number := -1;

cursor c_tp_hdr_id is
  select ecx_tp_headers_s.nextval
  from dual;

Begin

      x_return_status := ECX_UTIL_API.G_NO_ERROR;
      x_msg := null;
      x_tp_header_id := -1;

   -- make sure party_id, party_type, party_site_id and p_company_admin_email are not null.
      If (p_party_type is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
 	  x_msg := ecx_debug.getTranslatedMessage('ECX_PARTY_TYPE_NOT_NULL',
                                                  'p_party_type',p_party_type);
          return;
      elsif
         (p_party_id is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
 	  x_msg := ecx_debug.getTranslatedMessage('ECX_PARTY_ID_NOT_NULL',
                                                  'p_party_id',p_party_id);
          return;
      elsif
         (p_party_site_id is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
 	  x_msg := ecx_debug.getTranslatedMessage('ECX_PARTY_SITE_ID_NOT_NULL',
                                                  'p_party_site_id',p_party_site_id);
          return;
      elsif
         (p_company_admin_email is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
 	  x_msg := ecx_debug.getTranslatedMessage('ECX_EMAIL_ADDRESS_NOT_NULL',
                                                  'p_email_address',p_company_admin_email);
          return;

      end if;

      -- make sure p_party_type has a valid value.

      If not (ECX_UTIL_API.validate_party_type(p_party_type)) Then
          x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
          x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_PARTY_TYPE',
						'p_party_type',p_party_type);
          return;
      end if;

      If not(ECX_UTIL_API.validate_party_id(p_party_type,p_party_id)) Then
        x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
        x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_PARTY_ID',
						'p_party_id',p_party_id);
	return;
      End If;

      If p_party_type <> 'E' Then
         If not(ECX_UTIL_API.validate_party_site_id(p_party_type, p_party_id,p_party_site_id)) Then
            x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
            x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_PARTY_SITE_ID',
                                                 'p_party_site_id',p_party_site_id);
	    return;
         End If;
      End If;


      if not(ECX_UTIL_API.validate_email_address(p_company_admin_email)) Then
          x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
          x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_EMAIL_ADDRESS',
                              'p_email_address', p_company_admin_email);
         return;
      end if;

     open c_tp_hdr_id;
     fetch c_tp_hdr_id into x_tp_header_id;
     close c_tp_hdr_id;

      -- Insert data into ECX_TP_HEADERS.
      insert into ECX_TP_HEADERS(
         TP_HEADER_ID,
         PARTY_TYPE,
         PARTY_ID,
         PARTY_SITE_ID,
         COMPANY_ADMIN_EMAIL,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         CREATED_BY,
         CREATION_DATE)
      values (
         x_tp_header_id,
         p_party_type,
         p_party_id,
         p_party_site_id,
         p_company_admin_email,
         0,
         sysdate,
         0,
         sysdate
      )  ;

      /* WFDS changes */

      raise_tp_event(
         x_return_status => l_ret_code,
         x_msg => l_ret_msg,
         x_event_name => l_event_name,
         x_event_key => l_event_key,
         p_mod_type => 'CREATE',
         p_tp_header_id => x_tp_header_id,
         p_party_type => p_party_type,
         p_party_id => p_party_id,
         p_party_site_id => p_party_site_id,
         p_company_email_addr => p_company_admin_email);

     if NOT(l_ret_code = ECX_UTIL_API.G_NO_ERROR) then
        raise ecx_tp_api.tp_event_not_raised;
     end if;

   Exception
     when dup_val_on_index then
        x_tp_header_id := -1;
        x_return_status := ECX_UTIL_API.G_DUP_ERROR;
        x_msg  := ecx_debug.gettranslatedMessage('ECX_TP_HDR_EXISTS',
				'p_party_type', p_party_type,
				'p_party_id',   p_party_id,
				'p_party_site_id', p_party_site_id);
     when ecx_tp_api.tp_event_not_raised then
        x_tp_header_id := -1;
        x_return_status := l_ret_code;
        x_msg := l_ret_msg;
     when others then
        x_tp_header_id := -1;
        x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
        x_msg := SQLERRM;
  End;

Procedure update_trading_partner(
				x_return_status         OUT NOCOPY Pls_integer,
                                x_msg                   OUT NOCOPY Varchar2,
                                p_tp_header_id		IN Pls_integer,
                                p_company_admin_email	IN  Varchar2
) IS

l_ret_code   pls_integer := ECX_UTIL_API.G_NO_ERROR;
l_ret_msg    varchar2(2000) := null;
l_event_name varchar2(250) := null;
l_event_key  number := -1;

l_party_type ecx_tp_headers.party_type%type;
l_party_id   number;
l_party_site_id number;

Begin
   x_return_status := ECX_UTIL_API.G_NO_ERROR;
   x_msg := null;

   -- make sure p_tp_header_id is not null.
   If (p_tp_header_id is null) then
      x_return_status := ECX_UTIL_API.G_NULL_PARAM;
      x_msg  := ecx_debug.getTranslatedMessage('ECX_TP_HDR_ID_NOT_NULL');
      return;
   end if;

   if not(ECX_UTIL_API.validate_email_address(p_company_admin_email))  Then
      x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
      x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_EMAIL_ADDRESS',
                         'p_email_address',p_company_admin_email);
      return;
   end if;

   if NOT (ecx_util_api.validate_trading_partner(p_tp_header_id))
   then
      x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
      x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_TP_HDR_ID',
                                               'p_tp_header_id', p_tp_header_id);
      return;
   end if;

   -- update company_admin_email in ECX_TP_HEADERS.
   Update ECX_TP_HEADERS set
          COMPANY_ADMIN_EMAIL = p_company_admin_email,
          LAST_UPDATED_BY = 0,
          LAST_UPDATE_DATE = sysdate
   where tp_header_id = p_tp_header_id;

   if (sql%rowcount = 0) then
      x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
      x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
                                              'p_table', 'ecx_tp_headers',
                                              'p_param_name', 'Trading partner header ID',
                                              'p_param_id', p_tp_header_id);
      return;
   elsif (sql%rowcount > 0) then
      select party_type,
             party_id,
             party_site_id
        into l_party_type,
             l_party_id,
             l_party_site_id
        from ecx_tp_headers
       where tp_header_id = p_tp_header_id;

      raise_tp_event(
         x_return_status => l_ret_code,
         x_msg => l_ret_msg,
         x_event_name => l_event_name,
         x_event_key => l_event_key,
         p_mod_type => 'UPDATE',
         p_tp_header_id => p_tp_header_id,
         p_party_type => l_party_type,
         p_party_id => l_party_id,
         p_party_site_id => l_party_site_id,
         p_company_email_addr => p_company_admin_email);

     if NOT(l_ret_code = ECX_UTIL_API.G_NO_ERROR) then
        raise ecx_tp_api.tp_event_not_raised;
     end if;
   end if;

exception
   when ecx_tp_api.tp_event_not_raised then
      x_return_status := l_ret_code;
      x_msg := l_ret_msg;
   when others then
      x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
      x_msg := SQLERRM;
End;

Procedure delete_trading_partner(
                                x_return_status         OUT NOCOPY Pls_integer,
                                x_msg                   OUT NOCOPY Varchar2,
				p_tp_header_id		IN Pls_integer
) IS

l_xref_dtl_id	ecx_xref_dtl.xref_dtl_id%type;
l_ret_code   pls_integer := ECX_UTIL_API.G_NO_ERROR;
l_ret_msg    varchar2(2000) := null;
l_event_name varchar2(250) := null;
l_event_key  number := -1;
l_party_type ecx_tp_headers.party_type%type;
l_party_id   number;
l_party_site_id number;
l_company_admin_email ecx_tp_headers.company_admin_email%type;

cursor get_xref_dtl_id is
select xref_dtl_id from ecx_xref_dtl
where  tp_header_id = p_tp_header_id;

Begin
      x_return_status := ECX_UTIL_API.G_NO_ERROR;
      x_msg := null;

     If p_tp_header_id is null then
        x_return_status := ECX_UTIL_API.G_NULL_PARAM;
        x_msg  := ecx_debug.getTranslatedMessage('ECX_TP_HDR_ID_NOT_NULL');
        Return;
     end if;

     if NOT (ecx_util_api.validate_trading_partner(p_tp_header_id))
     then
         x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
         x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_TP_HDR_ID',
                                                  'p_tp_header_id', p_tp_header_id);
        return;
     end if;

     open get_xref_dtl_id;
     fetch get_xref_dtl_id into l_xref_dtl_id;
     close get_xref_dtl_id;

     delete from ecx_tp_details
      where tp_header_id = p_tp_header_id;

     delete from ecx_xref_dtl
      where tp_header_id = p_tp_header_id;

     delete from ecx_xref_dtl_tl
     where xref_dtl_id = l_xref_dtl_id;

     /* For raising event */
     select party_type,
            party_id,
            party_site_id,
            company_admin_email
       into l_party_type,
            l_party_id,
            l_party_site_id,
            l_company_admin_email
       from ecx_tp_headers
      where tp_header_id = p_tp_header_id;

     delete from ecx_tp_headers
     where tp_header_id = p_tp_header_id;

     if (sql%rowcount = 0) then
        x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
        x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_DELETED',
                                                'p_table', 'ecx_tp_headers',
                                                'p_param_name', 'Trading partner header ID',
                                                'p_param_id', p_tp_header_id);
        return;
     elsif (sql%rowcount > 0) then
        raise_tp_event(
           x_return_status => l_ret_code,
           x_msg => l_ret_msg,
           x_event_name => l_event_name,
           x_event_key => l_event_key,
           p_mod_type => 'DELETE',
           p_tp_header_id => p_tp_header_id,
           p_party_type => l_party_type,
           p_party_id => l_party_id,
           p_party_site_id => l_party_site_id,
           p_company_email_addr => l_company_admin_email);

       if NOT(l_ret_code = ECX_UTIL_API.G_NO_ERROR) then
          raise ecx_tp_api.tp_event_not_raised;
       end if;
   end if;

   exception
    when ecx_tp_api.tp_event_not_raised then
      x_return_status := l_ret_code;
      x_msg := l_ret_msg;
    when others then
      if (get_xref_dtl_id%ISOPEN)
      then
         close get_xref_dtl_id;
      end if;
      x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
      x_msg := SQLERRM;
   End;

/* Bug #2183619, Added one additional input parameter for
   source_tp_location_code */
Procedure retrieve_tp_detail(
                        x_return_status                 OUT NOCOPY Pls_integer,
                        x_msg                           OUT NOCOPY Varchar2,
                        x_tp_detail_id                  OUT NOCOPY Pls_integer,
			p_tp_header_id			IN  Pls_integer,
			p_ext_process_id		IN  Pls_integer,
			x_map_code			OUT NOCOPY Varchar2,
			x_connection_type		OUT NOCOPY Varchar2,
			x_hub_user_id			OUT NOCOPY Pls_integer,
			x_protocol_type			OUT NOCOPY Varchar2,
			x_protocol_address		OUT NOCOPY Varchar2,
			x_username			OUT NOCOPY Varchar2,
			x_password			OUT NOCOPY Varchar2,
			x_routing_id			OUT NOCOPY Pls_integer,
			x_source_tp_location_code	OUT NOCOPY Varchar2,
			x_external_tp_location_code	OUT NOCOPY Varchar2,
			x_confirmation			OUT NOCOPY Varchar2,
			x_created_by			OUT NOCOPY Varchar2,
			x_creation_date			OUT NOCOPY Varchar2,
			x_last_updated_by		OUT NOCOPY Varchar2,
			x_last_update_date		OUT NOCOPY Varchar2,
                        p_source_tp_location_code       IN  Varchar2
) IS

i_hub_id   NUMBER;

Begin
 x_return_status := ECX_UTIL_API.G_NO_ERROR;
 x_msg := null;

 If p_tp_header_id is null  Then
      x_return_status := ECX_UTIL_API.G_NULL_PARAM;
      x_msg  := ecx_debug.getTranslatedMessage('ECX_TP_HDR_ID_NOT_NULL');
     return;
 ElsIf
     p_ext_process_id is null then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg  := ecx_debug.getTranslatedMessage('ECX_EXT_PROCESS_ID_NOT_NULL');
          return;
 end if;
/* bug #2183619 , Added check for source_tp_lcoation_code */
 select
         TP_DETAIL_ID,
         MAP_CODE,
         CONNECTION_TYPE,
         HUB_USER_ID,
         HUB_ID,
         PROTOCOL_TYPE,
         PROTOCOL_ADDRESS,
         USERNAME,
         PASSWORD ,
         ROUTING_ID,
         SOURCE_TP_LOCATION_CODE,
         EXTERNAL_TP_LOCATION_CODE,
         CONFIRMATION,
         etd.CREATED_BY,
         etd.LAST_UPDATED_BY,
         etd.CREATION_DATE,
         etd.LAST_UPDATE_DATE
      Into
         x_tp_detail_id,
         x_map_code,
         x_connection_type,
         x_hub_user_id,
         i_hub_id,
         x_protocol_type,
         x_protocol_address,
         x_username,
         x_password,
         x_routing_id,
         x_source_tp_location_code,
         x_external_tp_location_code,
         x_confirmation,
         x_created_by ,
         x_last_updated_by ,
         x_creation_date,
         x_last_update_date
      from ecx_tp_details     etd,
           ecx_mappings       em
      where etd.tp_header_id   = p_tp_header_id
      and   etd.ext_process_id = p_ext_process_id
      and   em.map_id          = etd.map_id
      and   (p_source_tp_location_code is null
             or etd.source_tp_location_code=p_source_tp_location_code);

if (x_connection_type <> 'DIRECT') then
     Begin
         select protocol_type,protocol_address
         into x_protocol_type,x_protocol_address
         from ecx_hubs
         where hub_id=i_hub_id;
         Exception
         When no_data_found then
             x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
             x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_HUB_ID',
                                                      'p_hub_id',i_hub_id);
             return;
    End;
    Begin
       if(x_hub_user_id is not null) then
         select username,password
         into x_username,x_password
         from ecx_hub_users
         where hub_user_id=x_hub_user_id ;
      end if;
       Exception
       When no_data_found then
            x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
            x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_HUB_USER_ID',
                                                'p_hub_user_id',x_hub_user_id);
            return;
    End;
End If;

 Exception
     when no_data_found then
        x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
        x_msg := ecx_debug.getTranslatedMessage('ECX_TP_DTL_NOT_FOUND',
                                   'p_tp_header_id',p_tp_header_id,
                                   'p_ext_process_id', p_ext_process_id );

     when too_many_rows then
         x_return_status := ECX_UTIL_API.G_TOO_MANY_ROWS;
         x_msg := ecx_debug.getTranslatedMessage('ECX_TP_DTL_TOO_MANY_ROWS',
                                   'p_tp_header_id',p_tp_header_id,
                                   'p_ext_process_id', p_ext_process_id );
     when others then
        x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
        x_msg := SQLERRM;
   End;

--Overloaded procedure
/* Bug #2183619, Added three additional input parameters for
   External Type and Subtype and source_tp_location_code*/
Procedure retrieve_tp_detail(
                        x_return_status                 OUT NOCOPY Pls_integer,
                        x_msg                           OUT NOCOPY Varchar2,
                        x_tp_detail_id                  OUT NOCOPY Pls_integer,
                        x_tp_header_id                  OUT NOCOPY Pls_integer,
			p_party_type   			IN  Varchar2,
			p_party_id     			IN  Varchar2,
			p_party_site_id 		IN  Varchar2,
			p_transaction_type		IN  Varchar2,
			p_transaction_subtype		IN  Varchar2,
			p_standard_code			IN  Varchar2,
			p_direction			IN  Varchar2,
			x_ext_type			OUT NOCOPY Varchar2,
			x_ext_subtype			OUT NOCOPY Varchar2,
			x_map_code			OUT NOCOPY Varchar2,
			x_connection_type		OUT NOCOPY Varchar2,
			x_hub_user_id			OUT NOCOPY Pls_integer,
			x_protocol_type			OUT NOCOPY Varchar2,
			x_protocol_address		OUT NOCOPY Varchar2,
			x_username			OUT NOCOPY Varchar2,
			x_password			OUT NOCOPY Varchar2,
			x_routing_id			OUT NOCOPY Pls_integer,
			x_source_tp_location_code	OUT NOCOPY Varchar2,
			x_external_tp_location_code	OUT NOCOPY Varchar2,
			x_confirmation			OUT NOCOPY Varchar2,
			x_created_by			OUT NOCOPY Varchar2,
			x_creation_date			OUT NOCOPY Varchar2,
			x_last_updated_by		OUT NOCOPY Varchar2,
			x_last_update_date		OUT NOCOPY Varchar2,
                        p_ext_type                      IN  Varchar2 ,
                        p_ext_subtype                   IN  Varchar2 ,
                        p_source_tp_location_code       IN  Varchar2

) IS

x_ext_process_id number := 0;
x_transaction_id number := 0;
x_standard_id    number := 0;
x_queue_name              ecx_ext_processes.queue_name%type;
x_transaction_description ecx_transactions_tl.transaction_description%type;

Begin
     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;
     x_tp_detail_id := -1;

     If p_party_type is null  Then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg  := ecx_debug.getTranslatedMessage('ECX_PARTY_TYPE_NOT_NULL');
         return;
     ElsIf
         p_party_id is null then
              x_return_status := ECX_UTIL_API.G_NULL_PARAM;
              x_msg  := ecx_debug.getTranslatedMessage('ECX_PARTY_ID_NOT_NULL');
              return;
     ElsIf
         p_party_site_id is null then
              x_return_status := ECX_UTIL_API.G_NULL_PARAM;
              x_msg  := ecx_debug.getTranslatedMessage('ECX_PARTY_SITE_ID_NOT_NULL');
              return;
     ElsIf
         p_transaction_type is null then
              x_return_status := ECX_UTIL_API.G_NULL_PARAM;
              x_msg  := ecx_debug.getTranslatedMessage('ECX_TRANSACTION_TYPE_NOT_NULL');
              return;
     ElsIf
         p_transaction_subtype is null then
              x_return_status := ECX_UTIL_API.G_NULL_PARAM;
              x_msg  := ecx_debug.getTranslatedMessage('ECX_TRANSACTION_SUBTYPE_NOT_NULL');
              return;
     ElsIf
         p_standard_code is null then
              x_return_status := ECX_UTIL_API.G_NULL_PARAM;
              x_msg  := ecx_debug.getTranslatedMessage('ECX_STANDARD_CODE_NOT_FOUND',
                                               'p_standard_code',p_standard_code);
              return;
     ElsIf
         p_direction is null then
              x_return_status := ECX_UTIL_API.G_NULL_PARAM;
              x_msg  := ecx_debug.getTranslatedMessage('ECX_DIRECTION_NOT_NULL');
              return;
     end if;
    /* Bug #2183619, Added two additional input parameters for
       External Type and Subtype */
     ecx_transactions_api.retrieve_external_transaction(
         p_transaction_type        => p_transaction_type,
         p_transaction_subtype     => p_transaction_subtype,
         p_party_type              => p_party_type,
         p_standard                => p_standard_code,
         p_direction               => p_direction,
         p_ext_type                => p_ext_type,
         p_ext_subtype             => p_ext_subtype,
         x_ext_process_id          => x_ext_process_id,
         x_transaction_id          => x_transaction_id,
         x_transaction_description => x_transaction_description,
         x_ext_type                => x_ext_type,
         x_ext_subtype             => x_ext_subtype,
         x_standard_id             => x_standard_id,
         x_queue_name              => x_queue_name,
         x_created_by              => x_created_by,
         x_creation_date           => x_creation_date,
         x_last_updated_by         => x_last_updated_by,
         x_last_update_date        => x_last_update_date,
         x_return_status           => x_return_status,
         x_msg                     => x_msg);
      if (x_ext_process_id = -1) then return; end if;
      /* Bug #2183619,Added check for source_tp_Location_code */
      select
         etd.TP_HEADER_ID,
         etd.TP_DETAIL_ID,
         em.MAP_CODE,
         etd.CONNECTION_TYPE,
         etd.HUB_USER_ID,
         etd.PROTOCOL_TYPE,
         etd.PROTOCOL_ADDRESS,
         etd.USERNAME,
         etd.PASSWORD,
         etd.ROUTING_ID,
         etd.SOURCE_TP_LOCATION_CODE,
         etd.EXTERNAL_TP_LOCATION_CODE,
         etd.CONFIRMATION,
         etd.CREATED_BY,
         etd.LAST_UPDATED_BY,
         etd.CREATION_DATE,
         etd.LAST_UPDATE_DATE
      Into
         x_tp_header_id,
         x_tp_detail_id,
         x_map_code,
         x_connection_type,
         x_hub_user_id,
         x_protocol_type,
         x_protocol_address,
         x_username,
         x_password,
         x_routing_id,
         x_source_tp_location_code,
         x_external_tp_location_code,
         x_confirmation,
         x_created_by,
         x_last_updated_by,
         x_creation_date,
         x_last_update_date
      from ecx_tp_details     etd,
           ecx_tp_headers     eth,
           ecx_mappings       em
      where eth.party_id       = p_party_id
      and   eth.party_site_id  = p_party_site_id
      and   eth.party_type     = p_party_type
      and   etd.ext_process_id = x_ext_process_id
      and   em.map_id          = etd.map_id
      and   (p_source_tp_location_code is null
             or etd.source_tp_location_code=p_source_tp_location_code);

 Exception
     when no_data_found then
        x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
        x_msg := ecx_debug.getTranslatedMessage('ECX_TP_DTL1_NOT_FOUND',
                                   'p_party_type',p_party_type,
                                   'p_party_id', p_party_id ,
                                   'p_party_site_id', p_party_site_id,
                                   'p_transaction_type', p_transaction_type,
                                   'p_transaction_subtype', p_transaction_subtype,
                                   'p_standard_code', p_standard_code,
				   'p_direction', p_direction);
     when too_many_rows then
         x_return_status := ECX_UTIL_API.G_TOO_MANY_ROWS;
         x_msg := ecx_debug.getTranslatedMessage('ECX_TP_DTL1_TOO_MANY_ROWS',
                                   'p_party_type',p_party_type,
                                   'p_party_id', p_party_id ,
                                   'p_party_site_id', p_party_site_id,
                                   'p_transaction_type', p_transaction_type,
                                   'p_transaction_subtype', p_transaction_subtype,
                                   'p_standard_code', p_standard_code,
				   'p_direction', p_direction);
     when others then
        x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
        x_msg := SQLERRM;
   End;


Procedure create_tp_detail(
                x_return_status                 OUT      NOCOPY pls_integer,
                x_msg                           OUT      NOCOPY Varchar2,
                x_tp_detail_id                  OUT      NOCOPY Pls_integer,
	 	p_tp_header_id	 		IN	 pls_integer,
	 	p_ext_process_id		IN	 pls_integer,
	 	p_map_code	 		IN	 Varchar2,
	 	p_connection_type		IN	 Varchar2,
	 	p_hub_user_id	 		IN	 pls_integer,
	 	p_protocol_type	 		IN	 Varchar2,
	 	p_protocol_address		IN	 Varchar2,
	 	p_username	 		IN	 Varchar2,
	 	p_password	 		IN	 Varchar2,
	 	p_routing_id	 		IN	 pls_integer,
	 	p_source_tp_location_code	IN	 Varchar2	default null,
	 	p_external_tp_location_code	IN	 Varchar2,
	 	p_confirmation	 		IN	 pls_integer
 	 )IS

 l_confirmation			ecx_tp_details.confirmation%type;
 l_connection_type		ecx_tp_details.connection_type%type;
 l_hub_user_id			ecx_hub_users.hub_user_id%type;
 l_source_tp_location_code	ecx_tp_details.source_tp_location_code%type;

 cursor get_src_loc_code (i_hub_id IN pls_integer) is
 select name
 from   ecx_hubs
 where  hub_id = i_hub_id;

 cursor get_hub_entity_code is
 select hub_entity_code
 from   ecx_hub_users
 where  hub_user_id = p_hub_user_id;

 Cursor c1 Is
   select 1 from ecx_tp_headers
   where tp_header_id = p_tp_header_id;

 Cursor c2 Is
   select 1,direction from ecx_ext_processes
   where  ext_process_id = p_ext_process_id;

 Cursor c3 Is
   select map_id  from ecx_mappings
   where  map_code = p_map_code;

 Cursor c4 Is
   select 1 from ecx_hub_users
   where  hub_user_id = p_hub_user_id;

 Cursor c5 Is
   select 1 from ecx_tp_details
   where tp_detail_id = p_routing_id;

/* Start changes for bug #2183619 */
   Cursor c6(p_ext_type_in VARCHAR2,p_ext_subtype_in VARCHAR2,
            p_standard_id_in NUMBER,p_direction_in VARCHAR2,
            p_source_tp_location_code_in VARCHAR2) Is
   Select 1 from ecx_tp_details tp,ecx_ext_processes ep
   where  tp.ext_process_id=ep.ext_process_id
      And ep.ext_type      = p_ext_type_in
      And ep.ext_subtype   = p_ext_subtype_in
      And ep.standard_id   = p_standard_id_in
      And tp.source_tp_Location_code= p_source_tp_location_code_in
      And ep.direction     = p_direction_in ;

     Cursor c7(p_tp_header_id_in NUMBER,p_transaction_type_in VARCHAR2,
               p_transaction_subtype_in VARCHAR2) is
       select 1 from  ecx_tp_details
       where tp_header_id = p_tp_header_id_in
       and   ext_process_id in ( select ext.ext_process_id
                                 from   ecx_ext_processes ext,
                                        ecx_transactions  tran
                                 where  ext.direction = 'OUT'
                                 and    ext.transaction_id
                                        = tran.transaction_id
                                 and    tran.transaction_type
                                        = p_transaction_type_in
                                 and    tran.transaction_subtype
                                        = p_transaction_subtype_in );
      Cursor c8(p_ext_process_id_in NUMBER) is
        select ext_type,ext_subtype,standard_id,direction
        from  ecx_ext_processes
        where ext_process_id=p_ext_process_id_in;

      Cursor c9 (p_ext_process_id_in NUMBER) is
        select transaction_type,transaction_subtype
        from ecx_transactions et,ecx_ext_processes eep
        where eep.ext_process_id    = p_ext_process_id_in
              and et.transaction_id = eep.transaction_id;

/* End of changes for bug #2183619*/

 /*Bug #2449729 , cursor to retrieve hub_id */
 Cursor c10 is
        select 1,hub_id from ecx_hubs
        where name=p_connection_type and
              protocol_type= p_protocol_type;

 Cursor c_tp_dtl_id is
   select ecx_tp_details_s.nextval
   from dual;

 num number := 0;
 i_map_id   number:=0;
 encrypt_password ecx_tp_details.password%type;
 i_direction ecx_ext_processes.direction%type;

/* Added declartions for Bug #2183619 */
 p_ext_type            varchar2(80);
 p_ext_subtype          varchar2(80);
 p_standard_id          NUMBER(15);
 p_direction            varchar2(20);
 p_transaction_type     varchar2(100);
 p_transaction_subtype  varchar2(100);
 x_password             varchar2(500);
 i_hub_id               NUMBER ;

 begin

    x_return_status := ECX_UTIL_API.G_NO_ERROR;
    x_msg := null;
    x_tp_detail_id := -1;
    x_password := p_password;
    If p_tp_header_id is null  Then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg  := ecx_debug.getTranslatedMessage('ECX_TP_HDR_ID_NOT_NULL');
       return;
    ElsIf
       p_ext_process_id is null then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg  := ecx_debug.getTranslatedMessage('ECX_EXT_PROCESS_ID_NOT_NULL');
       return;
    end if;

    -- check if the tp header exists.  If not, return an error.
    num := 0;
    open c1;
    fetch c1 into num;
    close c1;

    if (num = 0) then
        x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
        x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_TP_HDR_ID',
						'p_tp_header_id',p_tp_header_id);
	return;
    end if;

    -- check if the ext_process id exists.  If not, return an error.
    num := 0;
    open c2;
    fetch c2 into num,i_direction;
    close c2;

    if(num = 0) then
        x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
        x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_EXT_PROCESS_ID',
					'p_ext_process_id',p_ext_process_id);
	return;
    end if;

    --  check if the map exists or not.
    open c3;
    fetch c3 into i_map_id;
    close c3;

    if(i_map_id = 0) then
        x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
        x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_MAP_CODE',
						'p_map_code',p_map_code);
	return;
    end if;

    -- confirmation_code should be checked for validity only if it specified.
    -- if not specified set to 0 like forms
    if (p_confirmation is not null)
    then
       if not(ECX_UTIL_API.validate_confirmation_code(p_confirmation)) then
          x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
          x_msg  := ecx_debug.getTranslatedMessage('ECX_INVALID_CONF_CODE',
                                                   'p_confirmation', p_confirmation);
          return;
       end if;
       l_confirmation := p_confirmation;
    else
       l_confirmation := 0;
    end if;

    if (i_direction = 'OUT') Then
       -- validate the connection_type ,protocol_type
       if (p_connection_type is null)
       then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg  := ecx_debug.getTranslatedMessage('ECX_CONNECTION_TYPE_NOT_NULL');
          return;
       end if;

       If p_protocol_type is null Then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg  := ecx_debug.getTranslatedMessage('ECX_PROTOCOL_TYPE_NOT_NULL');
          return;
       elsif
          not(ECX_UTIL_API.validate_protocol_type(p_protocol_type)) then
          x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
          x_msg  := ecx_debug.getTranslatedMessage('ECX_INVALID_PROTOCOL_TYPE',
						'p_protocol_type',p_protocol_type);
          return;
       end if;

       /* Start changes for bug #2183619 */
       /* Check for uniqueness trading partner details row for OUTBOUND transactions */

       open c9(p_ext_process_id);
       fetch c9 into p_transaction_type, p_transaction_subtype;
       close c9;
       num := 0;
       open c7(p_tp_header_id, p_transaction_type, p_transaction_subtype );
       fetch c7 into num;
       close c7;
       if (num <> 0) then
	  x_return_status := ECX_UTIL_API.G_DUP_ERROR;
          x_msg := ecx_debug.getTranslatedMessage('ECX_TP_DTL2_EXISTS',
                          'p_tp_header_id', p_tp_header_id,
                          'p_transaction_type', p_transaction_type,
                          'p_transaction_subtype', p_transaction_subtype
                   );
          return;
       End If;
       /* End of changes for bug #2183619 */

       if (upper(p_connection_type) = 'DIRECT') then
          l_connection_type := 'DIRECT';
          if p_protocol_type NOT IN ('NONE','IAS','ITG03') Then

             if p_protocol_address is null Then
                 x_return_status := ECX_UTIL_API.G_NULL_PARAM;
                 x_msg  := ecx_debug.getTranslatedMessage('ECX_PROTOCOL_ADDR_NOT_NULL');
                 return;
             end if;

             if (p_username is not null) then
                --- Check password length
                if not(ECX_UTIL_API.validate_password_length(p_password)) then
                   x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
                   x_msg  := ecx_debug.getTranslatedMessage('ECX_INVALID_PWD_LEN');
                   return;
                end if;
               /* Added check for bug #2410173 */
               if not(ECX_UTIL_API.validate_password(x_password)) then
                   x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
                  x_msg  := ecx_debug.getTranslatedMessage('ECX_INVALID_PWD');
                   return;
                end if;

                --- Encrypt the password
                ecx_obfuscate.ecx_data_encrypt(
                        l_input_string    => x_password,
                        l_output_string   => encrypt_password,
                        errmsg            => x_msg,
                        retcode           => x_return_status);

             end if;
          end if;

          -- Check source_tp_location_code
          If p_source_tp_location_code is null Then
             x_return_status := ECX_UTIL_API.G_NULL_PARAM;
             x_msg  := ecx_debug.getTranslatedMessage('ECX_LOCATION_NOT_NULL');
             return;
          End If;

          open c_tp_dtl_id;
          fetch c_tp_dtl_id into x_tp_detail_id;
          close c_tp_dtl_id;

          -- insert data into ECX_TP_DETAILS.
          Insert into ECX_TP_DETAILS(
            TP_HEADER_ID,
            TP_DETAIL_ID,
            MAP_ID,
            EXT_PROCESS_ID,
            CONNECTION_TYPE,
            HUB_USER_ID,
            HUB_ID,
            PROTOCOL_TYPE,
            PROTOCOL_ADDRESS,
            USERNAME,
            PASSWORD,
            ROUTING_ID,
            SOURCE_TP_LOCATION_CODE,
            EXTERNAL_TP_LOCATION_CODE,
            CONFIRMATION,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE
          )
          values (
             p_tp_header_id,
             x_tp_detail_id,
             i_map_id,
             p_ext_process_id,
             l_connection_type,
             null,
             null,
             p_protocol_type,
             p_protocol_address,
             p_username,
             encrypt_password,  -- CHECK THIS!
             null,
             p_source_tp_location_code,
             p_external_tp_location_code,
             l_confirmation,
             0,
             0,
             sysdate,
             sysdate
          );
       else  -- Hub connection type
          -- bug #2449729
          -- Retrieve the hub_id from ecx_hubs
          num := 0;
          open c10;
          fetch c10 into num, i_hub_id;
          close c10;
          if(num = 0) then
             x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
             x_msg  := ecx_debug.gettranslatedMessage('ECX_HUB_NOT_EXISTS',
                                     'p_connection_type',p_connection_type,
                                      'p_protocol_type',p_protocol_type);
             return;
          End if;

          -- hub_user information is required only if protocol_type <> SMTP
          if (p_protocol_type <> 'SMTP') then
             if p_hub_user_id is null Then
                x_return_status := ECX_UTIL_API.G_NULL_PARAM;
                x_msg  := ecx_debug.getTranslatedMessage('ECX_HUB_USER_ID_NOT_NULL');
                return;
             end if;
          end if;


          -- for any protocol_type if hub user_id is provided, check if it is valid
          if (p_hub_user_id is not null)
          then
             -- case where protocol_type is non-SMTP or where protocol_type is SMTP and
             -- hub_user_id is provided
             num := 0;
             open c4;
             fetch c4 into num;
             close c4;

             if (num = 0) then
                x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
                x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_HUB_USER_ID',
		      				'p_hub_user_id',p_hub_user_id);
	        return;
             end if;

             open  get_hub_entity_code;
             fetch get_hub_entity_code
             into  l_source_tp_location_code;
             close get_hub_entity_code;

          else -- case for SMTP with no hub_user_id info
             -- set source_tp_location_code to the hub_name
             open  get_src_loc_code (i_hub_id);
             fetch get_src_loc_code into l_source_tp_location_code;
	     close get_src_loc_code;
          end if;
          l_hub_user_id := p_hub_user_id;

          if (not p_source_tp_location_code is null)
          then
             if (l_source_tp_location_code <> p_source_tp_location_code)
             then
                x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
                x_msg := ecx_debug.gettranslatedMessage('ECX_INVALID_LOCATION',
						'p_location_code', p_source_tp_location_code);
                return;
             end if;
          end if;

          open c_tp_dtl_id;
          fetch c_tp_dtl_id into x_tp_detail_id;
          close c_tp_dtl_id;

          -- insert data into ECX_TP_DETAILS.
          Insert into ECX_TP_DETAILS(
            TP_HEADER_ID,
            TP_DETAIL_ID,
            MAP_ID,
            EXT_PROCESS_ID,
            CONNECTION_TYPE,
            HUB_USER_ID,
            HUB_ID,
            PROTOCOL_TYPE,
            PROTOCOL_ADDRESS,
            USERNAME,
            PASSWORD,
            ROUTING_ID,
            EXTERNAL_TP_LOCATION_CODE,
            CONFIRMATION,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE
          )
          values (
            p_tp_header_id,
            x_tp_detail_id,
            i_map_id,
            p_ext_process_id,
            p_connection_type,
            l_hub_user_id,
            i_hub_id,
            null,
            null,
            null,
            null,
            null,
            p_external_tp_location_code,
            l_confirmation,
            0,
            0,
            sysdate,
            sysdate
          );
       end if;
   else -- i_direciton is 'IN'
       -- Validate routing id
       If p_routing_id is not null and
          i_direction = 'IN' then
          num := 0;
          open c5;
          fetch c5 into num;
          close c5;

          if (num = 0) then
             x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
             x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_ROUTING_ID',
						'p_routing_id',p_routing_id);
	     return;
          end if;
       end if;

       --- Check source_tp_location_code
       If p_source_tp_location_code is null Then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg  := ecx_debug.getTranslatedMessage('ECX_LOCATION_NOT_NULL');
          return;
       End If;
       /* Start changes for bug #2183619 */
       /* Check for uniqueness of ext_process_id and source_tp_location_code
        for inbound transactions */

       open c8(p_ext_process_id);
       fetch c8 into p_ext_type,p_ext_subtype,p_standard_id,p_direction;
       num := 0;
       open c6(p_ext_type,p_ext_subtype,p_standard_id,p_direction,
       	p_source_tp_location_code);
       fetch c6 into num;
       close c6;
       if (num <> 0) then
          x_return_status := ECX_UTIL_API.G_DUP_ERROR;
	  x_msg := ecx_debug.getTranslatedMessage('ECX_TP_DTL1_EXISTS',
                   		  'p_ext_type', p_ext_type,
                	  'p_ext_subtype', p_ext_subtype,
                          'p_standard_id', p_standard_id,
                          'p_source_tp_location_code', p_source_tp_location_code
                );
          return;
       end if;
       /* End of changes for bug #2183619*/

       open c_tp_dtl_id;
       fetch c_tp_dtl_id into x_tp_detail_id;
       close c_tp_dtl_id;

       -- insert data into ECX_TP_DETAILS.
       Insert into ECX_TP_DETAILS(
         TP_HEADER_ID,
         TP_DETAIL_ID,
         MAP_ID,
         EXT_PROCESS_ID,
         CONNECTION_TYPE,
         HUB_USER_ID,
         HUB_ID,
         PROTOCOL_TYPE,
         PROTOCOL_ADDRESS,
         USERNAME,
         PASSWORD,
         ROUTING_ID,
         SOURCE_TP_LOCATION_CODE,
         EXTERNAL_TP_LOCATION_CODE,
         CONFIRMATION,
         CREATED_BY,
         LAST_UPDATED_BY,
         CREATION_DATE,
         LAST_UPDATE_DATE
       )
       values (
         p_tp_header_id,
         x_tp_detail_id,
         i_map_id,
         p_ext_process_id,
         null,
         null,
         null,
         null,
         null,
         null,
         null,
         p_routing_id,
         p_source_tp_location_code,
         p_external_tp_location_code,
         l_confirmation,
         0,
         0,
         sysdate,
         sysdate
       );
   end if;
  Exception
     when dup_val_on_index then
        x_return_status := ECX_UTIL_API.G_DUP_ERROR;
        x_msg  := ecx_debug.gettranslatedMessage('ECX_TP_DTL_EXISTS',
				'p_tp_header_id', p_tp_header_id,
				'p_ext_process_id',p_ext_process_id);
     when others then
        x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
        x_msg := SQLERRM;
 end;





---Overloaded
/* Bug 2122579 */
/* Bug #2183619, Added two input additional parameters for
   External Type and Subtype */
Procedure create_tp_detail(
                x_return_status                 OUT      NOCOPY pls_integer,
                x_msg                           OUT      NOCOPY Varchar2,
                x_tp_detail_id                  OUT      NOCOPY Pls_integer,
                x_tp_header_id                  OUT      NOCOPY Pls_integer,
                p_party_type                    IN       Varchar2,
                p_party_id                      IN       number,
	        p_party_site_id                 IN       number,
                p_transaction_type              IN       Varchar2,
                p_transaction_subtype           IN       Varchar2,
                p_standard_code                 IN       Varchar2,
                p_direction                     IN       Varchar2,
                p_map_code                      IN       Varchar2,
                p_connection_type               IN       Varchar2,
                p_hub_user_id                   IN       pls_integer,
                p_protocol_type                 IN       Varchar2,
                p_protocol_address              IN       Varchar2,
                p_username                      IN       Varchar2,
                p_password                      IN       Varchar2,
                p_routing_id                    IN       pls_integer,
                p_source_tp_location_code       IN       Varchar2	default null,
                p_external_tp_location_code     IN       Varchar2,
                p_confirmation                  IN       pls_integer,
                p_ext_type                      IN       Varchar2 ,
                p_ext_subtype                   IN       Varchar2
   ) IS
 i_created_by	varchar2(10);
 i_last_updated_by varchar2(10);
 i_creation_date varchar2(25);
 i_last_update_date varchar2(25);
 i_company_admin_email varchar2(250);
 i_ext_process_id number;
 i_transaction_id number;
 i_standard_id number;
 i_transaction_description ecx_transactions_tl.transaction_description%type;
 i_ext_type ecx_ext_processes.ext_type%type;
 i_ext_subtype ecx_ext_processes.ext_subtype%type;
 i_queue_name ecx_ext_processes.queue_name%type;

 begin
      x_return_status := ECX_UTIL_API.G_NO_ERROR;
      x_msg := null;
      x_tp_detail_id := -1;

   -- make sure party_id, party_type, party_site_id and p_company_admin_email are not null.
      If (p_party_type is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
 	  x_msg := ecx_debug.getTranslatedMessage('ECX_PARTY_TYPE_NOT_NULL',
                                                  'p_party_type',p_party_type);
          return;
      elsif
         (p_party_id is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
 	  x_msg := ecx_debug.getTranslatedMessage('ECX_PARTY_ID_NOT_NULL',
                                                  'p_party_id',p_party_id);
          return;
      elsif
         (p_party_site_id is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
 	  x_msg := ecx_debug.getTranslatedMessage('ECX_PARTY_SITE_ID_NOT_NULL',
                                                  'p_party_site_id',p_party_site_id);
          return;
      end if;

      retrieve_trading_partner(
				p_party_type => p_party_type,
                                p_party_id   => p_party_id,
				p_party_site_id => p_party_site_id,
				x_tp_header_id => x_tp_header_id,
                                x_company_admin_email => i_company_admin_email,
			 	x_created_by  => i_created_by,
			 	x_creation_date  => i_creation_date,
			 	x_last_updated_by  => i_last_updated_by,
			 	x_last_update_date  => i_last_update_date,
                                x_return_status	=>x_return_status,
				x_msg =>x_msg
		     	);

      if (x_tp_header_id = -1) then
        return;
      end if;


    /* Bug #2183619, Added two additional input  parameters for
       External Type and Subtype */
     ecx_transactions_api.retrieve_external_transaction(
         p_transaction_type        => p_transaction_type,
         p_transaction_subtype     => p_transaction_subtype,
         p_party_type              => p_party_type,
         p_standard                => p_standard_code,
         p_direction               => p_direction,
         p_ext_type                => p_ext_type,
         p_ext_subtype             => p_ext_subtype,
         x_ext_process_id          => i_ext_process_id,
         x_transaction_id          => i_transaction_id,
         x_transaction_description => i_transaction_description,
         x_ext_type                => i_ext_type,
         x_ext_subtype             => i_ext_subtype,
         x_standard_id             => i_standard_id,
         x_queue_name              => i_queue_name,
         x_created_by              => i_created_by,
         x_creation_date           => i_creation_date,
         x_last_updated_by         => i_last_updated_by,
         x_last_update_date        => i_last_update_date,
         x_return_status           => x_return_status,
         x_msg                     => x_msg);

      if (i_ext_process_id = -1) then    return; end if;

	create_tp_detail(
	 	p_tp_header_id 			=> x_tp_header_id,
	 	p_ext_process_id 		=> i_ext_process_id,
	 	p_map_code			=> p_map_code,
	 	p_connection_type 		=> p_connection_type,
	 	p_hub_user_id			=> p_hub_user_id,
	 	p_protocol_type			=> p_protocol_type,
	 	p_protocol_address 		=> p_protocol_address,
	 	p_username 			=> p_username,
	 	p_password 			=> p_password,
	 	p_routing_id 		  	=> p_routing_id,
	 	p_source_tp_location_code 	=> p_source_tp_location_code,
	 	p_external_tp_location_code 	=> p_external_tp_location_code,
	 	p_confirmation			=> p_confirmation,
  	 	x_tp_detail_id			=> x_tp_detail_id,
   		x_return_status	 		=> x_return_status,
		x_msg 				=> x_msg);
 end;


Procedure update_tp_detail(
 		x_return_status 		Out	 NOCOPY pls_integer,
 		x_msg	 			Out	 NOCOPY Varchar2,
 		p_tp_detail_id			In	 pls_integer,
 		p_map_code	 		In	 Varchar2,
 		p_ext_process_id		In	 pls_integer,
 		p_connection_type		In	 Varchar2,
 		p_hub_user_id	 		In	 pls_integer,
 		p_protocol_type	 		In	 Varchar2,
 		p_protocol_address		In	 Varchar2,
 		p_username	 		In	 Varchar2,
 		p_password	 		In	 Varchar2,
 		p_routing_id	 		In	 pls_integer,
 		p_source_tp_location_code	In	 Varchar2,
 		p_external_tp_location_code	In	 Varchar2,
 		p_confirmation			In	 pls_integer	 ,
		p_passupd_flag			IN	varchar2
		) Is

 l_confirmation                 ecx_tp_details.confirmation%type;
 l_connection_type              ecx_tp_details.connection_type%type;
 l_source_tp_location_code      ecx_tp_details.source_tp_location_code%type;
 i_passupd_flag                 varchar2(1);

 cursor get_src_loc_code (i_hub_id IN pls_integer) is
 select name
 from   ecx_hubs
 where  hub_id = i_hub_id;

 cursor get_hub_entity_code is
 select hub_entity_code
 from   ecx_hub_users
 where  hub_user_id = p_hub_user_id;

 cursor c1 is
   select map_id from ecx_mappings
   where map_code = p_map_code;

 cursor c2 is
   select direction from ecx_ext_processes
   where ext_process_id = p_ext_process_id;

 cursor c3 is
   select 1 from ecx_tp_details
   where  tp_detail_id = p_tp_detail_id;

 Cursor c4 Is
   select 1 from ecx_hub_users
   where  hub_user_id = p_hub_user_id;

 Cursor c5 Is
   select 1 from ecx_tp_details
   where tp_detail_id = p_routing_id;

/* Start changes for bug #2183619 */
   Cursor c6(p_ext_type_in VARCHAR2,p_ext_subtype_in VARCHAR2,
            p_standard_id_in NUMBER,p_direction_in VARCHAR2,
            p_source_tp_location_code_in VARCHAR2,
	    p_tp_detail_id_in NUMBER) Is
   Select tp_detail_id from ecx_tp_details tp,ecx_ext_processes ep
   where  tp.ext_process_id=ep.ext_process_id
      And ep.ext_type      = p_ext_type_in
      And ep.ext_subtype   = p_ext_subtype_in
      And ep.standard_id   = p_standard_id_in
      And tp.source_tp_Location_code= p_source_tp_location_code_in
      And tp.tp_detail_id <>  p_tp_detail_id_in
      And ep.direction     = p_direction_in ;

   Cursor c7(p_tp_header_id_in NUMBER,p_tp_detail_id_in NUMBER,
 	     p_transaction_type_in VARCHAR2,
             p_transaction_subtype_in VARCHAR2) is
       select 1 from  ecx_tp_details
       where tp_header_id = p_tp_header_id_in
       and   tp_detail_id <> p_tp_detail_id_in
       and   ext_process_id in ( select ext.ext_process_id
                                 from   ecx_ext_processes ext,
                                        ecx_transactions  tran
                                 where  ext.direction = 'OUT'
                                 and    ext.transaction_id
                                        = tran.transaction_id
                                 and    tran.transaction_type
                                        = p_transaction_type_in
                                 and    tran.transaction_subtype
                                        = p_transaction_subtype_in );
    Cursor c8(p_ext_process_id_in NUMBER) is
        select ext_type,ext_subtype,standard_id,direction
        from  ecx_ext_processes
        where ext_process_id=p_ext_process_id_in;

    Cursor c9 (p_ext_process_id_in NUMBER) is
        select transaction_type,transaction_subtype
        from ecx_transactions et,ecx_ext_processes eep
        where eep.ext_process_id    = p_ext_process_id_in
              and et.transaction_id = eep.transaction_id;

    Cursor c10 (p_tp_detail_id_in NUMBER) is
        select tp_header_id
        from ecx_tp_details
        where tp_detail_id=p_tp_detail_id_in;

    /* Bug #2449729 , cursor to retrieve hub_id */
     Cursor c11 is
        select 1,hub_id from ecx_hubs
        where name=p_connection_type and
              protocol_type= p_protocol_type;

/* End of changes for bug #2183619*/

 encrypt_password ecx_tp_details.password%type;
 num number := 0;
 i_map_id number :=0;
 i_direction varchar2(5):= null;
 --Bug #2183619
 p_ext_type            varchar2(80);
 p_ext_subtype         varchar2(80);
 p_standard_id         NUMBER(15);
 p_direction           varchar2(20);
 p_transaction_type     varchar2(100);
 p_transaction_subtype  varchar2(100);
 p_tp_header_id        NUMBER;
 x_password            varchar2(500);
 i_hub_id              NUMBER;

begin
   x_return_status := ECX_UTIL_API.G_NO_ERROR;
   x_msg := null;
   x_password := p_password;

   -- make sure tp_detail_id, map_code and ext_process_id are not null.
   If p_tp_detail_id is null  Then
      x_return_status := ECX_UTIL_API.G_NULL_PARAM;
      x_msg  := ecx_debug.getTranslatedMessage('ECX_TP_DTL_ID_NOT_NULL');
      return;
   ElsIf
      p_ext_process_id is null then
         x_return_status := ECX_UTIL_API.G_NULL_PARAM;
         x_msg  := ecx_debug.getTranslatedMessage('ECX_EXT_PROCESS_ID_NOT_NULL');
         return;
   Elsif
      p_map_code is null then
         x_return_status := ECX_UTIL_API.G_NULL_PARAM;
         x_msg  := ecx_debug.getTranslatedMessage('ECX_MAP_CODE_NOT_NULL');
         return;
   Else
      if (p_passupd_flag is null) then
                i_passupd_flag := 'Y';
      elsif (upper(p_passupd_flag) <>'Y' and
             upper(p_passupd_flag) <> 'N')
      then
         x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
         x_msg  := ecx_debug.getTranslatedMessage('ECX_PASSUPD_INVALID');
         return;
      else
               i_passupd_flag := upper(p_passupd_flag);
      end if;

   end if;

   --- Get transaction direction
   i_direction := null;
   open c2;
   fetch c2 into i_direction;
   close c2;
   if(i_direction is NULL) then
      x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
      x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_EXT_PROCESS_ID',
                                       'p_ext_process_id',p_ext_process_id);
      return;
   end if;

   --- Validate routing id
   If p_routing_id is not null and i_direction = 'IN' then
      num := 0;
      open c3;
      fetch c3 into num;
      close c3;

      if (num = 0) then
         x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
         x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_ROUTING_ID',
						'p_routing_id',p_routing_id);
         return;
      end if;
   end if;

   -- get map_id, if map_id doesn't exists, return an error.
   i_map_id := 0;
   open c1;
   fetch c1 into i_map_id;
   close c1;

   if (i_map_id = 0 ) then
      x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
      x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_MAP_CODE',
					'p_map_code',p_map_code);
      return;
   end if;

   -- validate confirmation
   if (p_confirmation is not null)
   then
      if not(ECX_UTIL_API.validate_confirmation_code(p_confirmation)) then
         x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
         x_msg  := ecx_debug.getTranslatedMessage('ECX_INVALID_CONF_CODE',
                                                   'p_confirmation', p_confirmation);
         return;
       end if;
       l_confirmation := p_confirmation;
   else
      l_confirmation := 0;
   end if;

   -- validate the connection_type ,protocol_type
   if (i_direction = 'OUT') then
      if (p_connection_type is null)
      then
         x_return_status := ECX_UTIL_API.G_NULL_PARAM;
         x_msg  := ecx_debug.getTranslatedMessage('ECX_CONNECTION_TYPE_NOT_NULL');
         return;
      end if;

      if(p_protocol_type is null) then
         x_return_status := ECX_UTIL_API.G_NULL_PARAM;
         x_msg  := ecx_debug.getTranslatedMessage('ECX_PROTOCOL_TYPE_NOT_NULL');
         return;

      elsif (not(ECX_UTIL_API.validate_protocol_type(p_protocol_type))) then
         x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
         x_msg  := ecx_debug.getTranslatedMessage('ECX_INVALID_PROTOCOL_TYPE',
						'p_protocol_type',p_protocol_type);
         return;
      end if;

      /* Start changes for bug #2183619 */
      /* Check for uniqueness trading partner details row for OUTBOUND transactions */

      /* Get the internal transaction type and sub type for corresponding to the
         ext_process_id */
      open c9(p_ext_process_id);
      fetch c9 into p_transaction_type,p_transaction_subtype;
      close c9;

      /* Get the trading partner Header Information */
      open c10(p_tp_detail_id);
      fetch c10 into p_tp_header_id;
      close c10;
      if (p_tp_header_id is NULL) then
         x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
         x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_TP_DETAIL_ID',
                                               'p_tp_detail_id',p_tp_detail_id);
         return;
      end if;
      num := 0;
      open c7(p_tp_header_id,p_tp_detail_id,
              p_transaction_type,p_transaction_subtype );
      fetch c7 into num;
      close c7;
      if (num <> 0) then
         x_return_status := ECX_UTIL_API.G_DUP_ERROR;
         x_msg := ecx_debug.getTranslatedMessage(
                                'ECX_TP_DTL2_EXISTS',
                                'p_tp_header_id', p_tp_header_id,
                                'p_transaction_type', p_transaction_type,
                                'p_transaction_subtype', p_transaction_subtype
                                 );
         return;
      End If;

      /* End of changes for bug #2183619*/

      if (upper(p_connection_type) = 'DIRECT') Then
         l_connection_type := 'DIRECT';
         if p_protocol_type NOT IN ('NONE','IAS','ITG03') Then

             if p_protocol_address is null Then
                 x_return_status := ECX_UTIL_API.G_NULL_PARAM;
                 x_msg  := ecx_debug.getTranslatedMessage('ECX_PROTOCOL_ADDR_NOT_NULL');
                 return;
             end if;


             /***
             If p_username is null Then
                 x_return_status := ECX_UTIL_API.G_NULL_PARAM;
                 x_msg  := ecx_debug.getTranslatedMessage('ECX_USRNAME_NOT_NULL');
                 return;
             end if;
             If p_password is null Then
               x_return_status := ECX_UTIL_API.G_NULL_PARAM;
               x_msg  := ecx_debug.getTranslatedMessage('ECX_PWD_NOT_NULL');
               return;
             End If;
             ***/

   	    if ( i_passupd_flag = 'Y')
   	    then
   	       if (p_username is not null)
   	       then
      		  --- Check password length
            	  if not(ECX_UTIL_API.validate_password_length(p_password)) then
               	     x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
               	     x_msg  := ecx_debug.getTranslatedMessage('ECX_INVALID_PWD_LEN');
               	     return;
                  end if;

                  /* Added check for bug #2410173 */
                  if not(ECX_UTIL_API.validate_password(x_password)) then
                     x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
                     x_msg  := ecx_debug.getTranslatedMessage('ECX_INVALID_PWD');
                     return;
                  end if;

       		  --- Encrypt the password
            	  ecx_obfuscate.ecx_data_encrypt(
                        l_input_string    => x_password,
                        l_output_string   => encrypt_password,
                        errmsg            => x_msg,
                        retcode           => x_return_status);
	       end if;
            end if;
         end if;

         --- Check source_tp_location_code
         If p_source_tp_location_code is null Then
            x_return_status := ECX_UTIL_API.G_NULL_PARAM;
            x_msg  := ecx_debug.getTranslatedMessage('ECX_LOCATION_NOT_NULL');
            return;
         End If;
         -- update ECX_TP_DETAILS.
         if (i_passupd_flag = 'Y')
         then
            Update ECX_TP_DETAILS set
             MAP_ID                    = i_map_id,
             EXT_PROCESS_ID            = p_ext_process_id,
             CONNECTION_TYPE           = l_connection_type,
             HUB_USER_ID               = null,
             HUB_ID                    = null,
             PROTOCOL_TYPE             = p_protocol_type,
             PROTOCOL_ADDRESS          = p_protocol_address,
             USERNAME                  = p_username,
             PASSWORD                  = encrypt_password,
             ROUTING_ID                = null,
             SOURCE_TP_LOCATION_CODE   = p_source_tp_location_code,
             EXTERNAL_TP_LOCATION_CODE = p_external_tp_location_code,
             CONFIRMATION              = l_confirmation,
             LAST_UPDATED_BY           = 0,
             LAST_UPDATE_DATE          = sysdate
             where tp_detail_id        = p_tp_detail_id;
         elsif (i_passupd_flag = 'N')
         then
            Update ECX_TP_DETAILS set
            MAP_ID                    = i_map_id,
            EXT_PROCESS_ID            = p_ext_process_id,
            CONNECTION_TYPE           = l_connection_type,
            HUB_USER_ID               = null,
            HUB_ID                    = null,
            PROTOCOL_TYPE             = p_protocol_type,
            PROTOCOL_ADDRESS          = p_protocol_address,
            ROUTING_ID                = null,
            SOURCE_TP_LOCATION_CODE   = p_source_tp_location_code,
            EXTERNAL_TP_LOCATION_CODE = p_external_tp_location_code,
            CONFIRMATION              = l_confirmation,
            LAST_UPDATED_BY           = 0,
            LAST_UPDATE_DATE          = sysdate
            where tp_detail_id        = p_tp_detail_id;
         end if;

         if (sql%rowcount = 0) then
            x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
            x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
                                                 'p_table', 'ecx_tp_details',
                                                 'p_param_name', 'Trading partner detail ID',
                                                 'p_param_id', p_tp_detail_id);
            return;
         end if;

       else  -- Hub connection type
          --bug #2449729
          --Retrieve the hub_id from ecx_hubs
          num := 0;
          open c11;
          fetch c11 into num,i_hub_id;
          close c11;

          if(num = 0) then
             x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
             x_msg  := ecx_debug.gettranslatedMessage('ECX_HUB_NOT_EXISTS',
                                        'p_connection_type',p_connection_type,
                                        'p_protocol_type',p_protocol_type);
             return;
          End If;

          -- hub_user information is required only if protocol_type <> SMTP
          if (p_protocol_type <> 'SMTP') then
             if p_hub_user_id is null Then
                x_return_status := ECX_UTIL_API.G_NULL_PARAM;
                x_msg  := ecx_debug.getTranslatedMessage('ECX_HUB_USER_ID_NOT_NULL');
                return;
             end if;
          end if;

          -- for any protocol_type if hub user_id is provided, check if it is valid
          if (p_hub_user_id is not null)
          then
             num := 0;
             open c4;
             fetch c4 into num;
             close c4;

             if (num = 0) then
                x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
                x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_HUB_USER_ID',
						'p_hub_user_id',p_hub_user_id);
	        return;
             end if;
             -- get the source_tp_location_code
             open  get_hub_entity_code;
             fetch get_hub_entity_code
             into  l_source_tp_location_code;
             close get_hub_entity_code;

          else -- case for SMTP with no hub_user_id info
             -- set source_tp_location_code to the hub_name
             open  get_src_loc_code (i_hub_id);
             fetch get_src_loc_code into l_source_tp_location_code;
             close get_src_loc_code;
          end if;

          if (not p_source_tp_location_code is null)
          then
             if (l_source_tp_location_code <> p_source_tp_location_code)
             then
                x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
                x_msg := ecx_debug.gettranslatedMessage('ECX_INVALID_LOCATION',
						'p_location_code', p_source_tp_location_code);
                return;
             end if;
          end if;

          -- update ECX_TP_DETAILS.
          if (i_passupd_flag = 'Y')
          then
            Update ECX_TP_DETAILS set
             MAP_ID                    = i_map_id,
             EXT_PROCESS_ID            = p_ext_process_id,
             CONNECTION_TYPE           = p_connection_type,
             HUB_USER_ID               = p_hub_user_id,
             HUB_ID                    = i_hub_id,
             PROTOCOL_TYPE             = null,
             PROTOCOL_ADDRESS          = null,
             USERNAME                  = null,
             PASSWORD                  = null,
             ROUTING_ID                = null,
             EXTERNAL_TP_LOCATION_CODE = p_external_tp_location_code,
             CONFIRMATION              = l_confirmation,
             LAST_UPDATED_BY           = 0,
             LAST_UPDATE_DATE          = sysdate
             where tp_detail_id        = p_tp_detail_id;
          elsif (i_passupd_flag = 'N')
          then
            Update ECX_TP_DETAILS set
            MAP_ID                    = i_map_id,
            EXT_PROCESS_ID            = p_ext_process_id,
            CONNECTION_TYPE           = p_connection_type,
            HUB_USER_ID               = p_hub_user_id,
            HUB_ID                    = i_hub_id,
            PROTOCOL_TYPE             = null,
            PROTOCOL_ADDRESS          = null,
            ROUTING_ID                = null,
            EXTERNAL_TP_LOCATION_CODE = p_external_tp_location_code,
            CONFIRMATION              = l_confirmation,
            LAST_UPDATED_BY           = 0,
            LAST_UPDATE_DATE          = sysdate
            where tp_detail_id        = p_tp_detail_id;
          end if;

          if (sql%rowcount = 0) then
             x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
             x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
                                                 'p_table', 'ecx_tp_details',
                                                 'p_param_name', 'Trading partner detail ID',
                                                 'p_param_id', p_tp_detail_id);
             return;
          end if;
       End IF;

    else -- i_direction is 'IN'
       --- Validate routing id
       If p_routing_id is not null and
          i_direction = 'IN' then
          num := 0;
          open c5;
          fetch c5 into num;
          close c5;

          if (num = 0) then
             x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
             x_msg  := ecx_debug.gettranslatedMessage('ECX_INVALID_ROUTING_ID',
						'p_routing_id',p_routing_id);
	     return;
          end if;
       end if;

       --- Check source_tp_location_code
       If p_source_tp_location_code is null Then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg  := ecx_debug.getTranslatedMessage('ECX_LOCATION_NOT_NULL');
          return;
       End If;
       /* Start changes for bug #2183619 */
       /* Check for uniqueness of ext_process_id and source_tp_location_code
         for inbound transactions */

       open c8(p_ext_process_id);
       fetch c8 into p_ext_type,p_ext_subtype,p_standard_id,p_direction;
       num := 0;
       open c6(p_ext_type,p_ext_subtype,p_standard_id,p_direction,
               p_source_tp_location_code,p_tp_detail_id);
       fetch c6 into num;
       close c6;
       if (num <> 0) then
          x_return_status := ECX_UTIL_API.G_DUP_ERROR;
          x_msg := ecx_debug.getTranslatedMessage('ECX_TP_DTL1_EXISTS',
                          'p_ext_type', p_ext_type,
                          'p_ext_subtype', p_ext_subtype,
                          'p_standard_id', p_standard_id,
                          'p_source_tp_location_code', p_source_tp_location_code
                           );

          return;
       end if;
       /* End of changes for bug #2183619*/

       -- update ECX_TP_DETAILS.
       if (i_passupd_flag = 'Y')
       then
         Update ECX_TP_DETAILS set
         MAP_ID                    = i_map_id,
         EXT_PROCESS_ID            = p_ext_process_id,
         CONNECTION_TYPE           = null,
         HUB_USER_ID               = null,
         HUB_ID                    = null,
         PROTOCOL_TYPE             = null,
         PROTOCOL_ADDRESS          = null,
         USERNAME                  = null,
         PASSWORD                  = null,
         ROUTING_ID                = p_routing_id,
         SOURCE_TP_LOCATION_CODE   = p_source_tp_location_code,
         EXTERNAL_TP_LOCATION_CODE = p_external_tp_location_code,
         CONFIRMATION              = l_confirmation,
         LAST_UPDATED_BY           = 0,
         LAST_UPDATE_DATE          = sysdate
        where tp_detail_id         = p_tp_detail_id;

       elsif (i_passupd_flag = 'N')
       then
         Update ECX_TP_DETAILS set
         MAP_ID                    = i_map_id,
         EXT_PROCESS_ID            = p_ext_process_id,
         CONNECTION_TYPE           = null,
         HUB_USER_ID               = null,
         HUB_ID                    = null,
         PROTOCOL_TYPE             = null,
         PROTOCOL_ADDRESS          = null,
         ROUTING_ID                = p_routing_id,
         SOURCE_TP_LOCATION_CODE   = p_source_tp_location_code,
         EXTERNAL_TP_LOCATION_CODE = p_external_tp_location_code,
         CONFIRMATION              = l_confirmation,
         LAST_UPDATED_BY           = 0,
         LAST_UPDATE_DATE          = sysdate
        where tp_detail_id         = p_tp_detail_id;
       end if;

       if (sql%rowcount = 0) then
         x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
         x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
                                                'p_table', 'ecx_tp_details',
                                                 'p_param_name', 'Trading partner detail ID',
                                                 'p_param_id', p_tp_detail_id);
         return;
        end if;
    end if;
exception
   when others then
      x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
      x_msg := SQLERRM;
End;

Procedure delete_tp_detail( x_return_status	Out	 NOCOPY pls_integer,
			    x_msg	 	Out	 NOCOPY Varchar2,
			    p_tp_detail_id	 In	 pls_integer	 ) Is

begin

   x_return_status := ECX_UTIL_API.G_NO_ERROR;
   x_msg := null;

   If p_tp_detail_id is null Then
      x_return_status := ECX_UTIL_API.G_NULL_PARAM;
      x_msg  := ecx_debug.getTranslatedMessage('ECX_TP_DTL_ID_NOT_NULL');
     return;
  End If;

  delete from ecx_tp_details
  where tp_detail_id = p_tp_detail_id;

  if (sql%rowcount = 0) then
      x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
      x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_DELETED',
                                              'p_table', 'ecx_tp_details',
                                              'p_param_name', 'Trading partner detail ID',
                                              'p_param_id', p_tp_detail_id);
       return;
   end if;

   exception
    when others then
      x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
      x_msg := SQLERRM;
  End;
/* This API will be called to create the parametres and then synch up the
** trading partners with the workflow directories.
**
*/
  procedure ecx_tp_synch_wf(
                            org_name           in Varchar2,
                            party_name_or_site in Varchar2,
                            party_or_site_id   in Varchar2,
                            email_addr         in Varchar2,
                            p_mod_type         in Varchar2
                           )
			   is
p_params wf_parameter_list_t;

begin

    p_params := wf_parameter_list_t();

	   wf_event.addParameterToList(
                                    p_name          => 'USER_NAME',
                                    p_value         => org_name ||':'||party_or_site_id,
                                    p_parameterlist => p_params);

              wf_event.addParameterToList(
                                    p_name          => 'DisplayName',
                                    p_value         => party_name_or_site,
                                    p_parameterlist => p_params);

              wf_event.addParameterToList(
                                    p_name          => 'mail',
                                    p_value         => email_addr,
                                    p_parameterlist => p_params);
if(p_mod_type='DELETE') then
	     wf_local_synch.propagate_role(
                 p_orig_system => org_name,
                 p_orig_system_id =>party_or_site_id ,
                 p_attributes => p_params,
                 p_expiration_date => sysdate
                 );
		 else
		 wf_local_synch.propagate_role(
                 p_orig_system => org_name,
                 p_orig_system_id =>party_or_site_id ,
                 p_attributes => p_params,
                 p_start_date => sysdate
                 );
end if;
END ecx_tp_synch_wf;

procedure raise_tp_event(
                       x_return_status      out NOCOPY pls_integer,
                       x_msg                out NOCOPY varchar2,
                       x_event_name         out NOCOPY varchar2,
                       x_event_key          out NOCOPY number,
                       p_mod_type            in varchar2,
                       p_tp_header_id        in number,
                       p_party_type          in varchar2,
                       p_party_id            in varchar2,
                       p_party_site_id       in varchar2,
                       p_company_email_addr  in varchar2
)
is
l_event_name varchar2(250);
l_event_key number;
l_params wf_parameter_list_t;

org_table_name varchar2(350);
party_name varchar2(350);
org_site_table_name varchar2(350);
org_role_name varchar2(350);
org_site_role_name varchar2(350);
party_site_loc varchar2(350);
/*
 ** This API is called when ecx is synching up the data b/w ecx_tp_headers and the wf directories. **
 ** Please refer to the bug 4734256 for details.
 */
cursor internal_party_name(v_party_id varchar) is
 select LOCATION_CODE  from hr_locations  where LOCATION_ID=v_party_id;

   cursor internal_site_name(v_party_id varchar) is
 select ADDRESS_LINE_1||ADDRESS_LINE_2||ADDRESS_LINE_3 ||town_or_city||country||postal_code from hr_locations
 where location_id =v_party_id ;

 cursor bank_party_name(v_party_id varchar) is
select BANK_NAME from CE_BANK_BRANCHES_V where BRANCH_PARTY_ID=v_party_id;

cursor bank_site_name(v_party_id varchar) is
select address_line1||' '||address_line2||' '||address_line3||' '||CITY||' '||ZIP from CE_BANK_BRANCHES_V where BRANCH_PARTY_ID=v_party_id;

  cursor supplier_party_name(v_party_id varchar) is
select p.vendor_name from PO_VENDORS p  where p.vendor_ID =v_party_id ;

  cursor supplier_site_name(v_party_id varchar,v_party_site_id varchar) is
select p1.ADDRESS_LINE1||' '||p1.ADDRESS_LINE2||' '||p1.ADDRESS_LINE3||' '||p1.CITY||p1.ZIP from  PO_VENDOR_SITES_ALL p1
  where  p1.VENDOR_SITE_ID =v_party_site_id and p1.VENDOR_ID=v_party_id;

 cursor customer_party_name(v_party_id varchar) is
select PARTY_NAME from hz_parties where party_id=v_party_id;

    cursor customer_site_name(v_party_id varchar,v_party_site_id varchar) is
select ADDRESS1 ||ADDRESS2 || ADDRESS3 || ADDRESS4 ||CITY ||POSTAL_CODE ||STATE ||PROVINCE || COUNTY||COUNTRY from hz_locations where location_id =(select location_id from hz_party_sites where party_id=v_party_id and party_site_id=v_party_site_id);
     cursor org_table(v_party_id varchar) is
  select  decode(party_type,'C','HZ_PARTIES','EXCHANGE','HZ_PARTIES','CARRIER','HZ_PARTIES','S','PO_VENDORS','I','HR_LOCATIONS','B','CE_BANK_BRANCHES_V') from ecx_tp_headers where party_id =v_party_id ;

  cursor org_site_table(v_party_id varchar) is
select  decode(party_type,'C','HZ_PARTY_SITES','EXCHANGE','HZ_PARTY_SITES','CARRIER','HZ_PARTY_SITES','S','PO_VENDOR_SITES_ALL','I','HR_LOCATIONS_SITES','B','CE_BANK_BRANCHES_SITE') from ecx_tp_headers where party_id =v_party_id ;


/* This cursor "orig_site_role" is defined to get the  name of the orig_system from wf_local_roles
** This would be used when we are deleting a Trading Partner**
** As the above cursors can not be used, because they are based on the ecx_tp_headers table**
*/
cursor orig_site_role is
select  decode(p_party_type,'C','HZ_PARTY_SITES','EXCHANGE','HZ_PARTY_SITES','CARRIER','HZ_PARTY_SITES','S','PO_VENDOR_SITES','I','HR_LOCATIONS_SITES','B','CE_BANK_BRANCHES_SITE') from dual;

cursor orig_role is
select  decode(p_party_type,'C','HZ_PARTIES','EXCHANGE','HZ_PARTIES','CARRIER','HZ_PARTIES','S','PO_VENDORS','I','HR_LOCATIONS','B','CE_BANK_BRANCHES_V') from dual;

begin
   x_return_status := ECX_UTIL_API.G_NO_ERROR;
   x_msg := null;
   x_event_key := -1;
   x_event_name := null;

   l_event_name := 'oracle.apps.ecx.tp.modified';
   l_event_key := p_tp_header_id || wf_core.random;

   l_params := wf_parameter_list_t();

   wf_event.addParameterToList(p_name          => 'ECX_TP_MOD_TYPE',
                               p_value         => p_mod_type,
                               p_parameterlist => l_params);
   wf_event.addParameterToList(p_name          => 'ECX_TP_HEADER_ID',
                               p_value         => p_tp_header_id,
                               p_parameterlist => l_params);
   wf_event.addParameterToList(p_name          => 'ECX_PARTY_TYPE',
                               p_value         => p_party_type,
                               p_parameterlist => l_params);
   wf_event.addParameterToList(p_name          => 'ECX_PARTY_ID',
                               p_value         => p_party_id,
                               p_parameterlist => l_params);
   wf_event.addParameterToList(p_name          => 'ECX_PARTY_SITE_ID',
                               p_value         => p_party_site_id,
                               p_parameterlist => l_params);
   wf_event.addParameterToList(p_name          => 'ECX_COMPANY_ADMIN_EMAIL',
                               p_value         => p_company_email_addr,
                               p_parameterlist => l_params);

   wf_event.raise(l_event_name, l_event_key, null, l_params);




	 if (p_party_type='I') then
	         open internal_party_name(p_party_id);
                 fetch internal_party_name into party_name;
                 close internal_party_name;

		 open internal_site_name(p_party_id);
                 fetch internal_site_name into party_site_loc;
                 close internal_site_name;
		 end if;

         if(p_party_type='S')  then
        open supplier_party_name(p_party_id);
        fetch supplier_party_name into party_name;
                 close supplier_party_name;

 		 open supplier_site_name(p_party_id,p_party_site_id);
                 fetch supplier_site_name into party_site_loc;
                 close supplier_site_name;

		 end if;

if(p_party_type='B')  then
open bank_party_name(p_party_id);
                 fetch bank_party_name into party_name;
                 close bank_party_name;
open bank_site_name(p_party_id);
                 fetch bank_site_name into party_site_loc;
                 close bank_site_name;

end if;

if(p_party_type='C' OR p_party_type='CARRIER' OR p_party_type='EXCHANGE' ) then

		 open customer_party_name(p_party_id);
                 fetch customer_party_name into party_name;
                 close customer_party_name;

		 open customer_site_name(p_party_id,p_party_site_id);
                 fetch customer_site_name into party_site_loc;
                 close customer_site_name;

		 end if;


if(p_mod_type='DELETE') then
	      open orig_role;
	      fetch orig_role into org_table_name;
	      close orig_role;

	      open orig_site_role;
	      fetch orig_site_role into org_site_table_name;
	      close orig_site_role;

else
                 open org_table(p_party_id);
                 fetch org_table into org_table_name;
                 close org_table;

		  open org_site_table(p_party_id);
                 fetch org_site_table into org_site_table_name;
                 close org_site_table;
	end if;


 ECX_TP_API.ecx_tp_synch_wf(org_table_name,party_name,p_party_id,p_company_email_addr,p_mod_type);
 ECX_TP_API.ecx_tp_synch_wf(org_site_table_name,party_site_loc,p_party_site_id,p_company_email_addr,p_mod_type);



   x_return_status := ECX_UTIL_API.G_NO_ERROR;
   x_msg := null;
   x_event_name := l_event_name;
   x_event_key := l_event_key;
exception
   when others then
      x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
      x_msg := SQLERRM;
End;
End;

/
