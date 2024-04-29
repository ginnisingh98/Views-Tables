--------------------------------------------------------
--  DDL for Package Body ECX_TRADING_PARTNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_TRADING_PARTNER_PVT" AS
-- $Header: ECXTPXFB.pls 120.6.12010000.2 2008/08/22 19:21:32 cpeixoto ship $

/** Returns the trading partners Details as defined in the partner Setup **/
procedure get_tp_info
	(
	p_tp_header_id		IN	pls_integer,
	p_party_id		OUT	NOCOPY NUMBER,
	p_party_site_id		OUT	NOCOPY NUMBER,
	p_org_id		OUT	NOCOPY pls_integer,
	p_admin_email		OUT	NOCOPY varchar2,
	retcode			OUT	NOCOPY pls_integer,
	retmsg			OUT	NOCOPY varchar2
	)
is

p_party_type	varchar2(200);

cursor cinfo is
select	party_id,
	party_site_id,
	party_type,
	company_admin_email
from	ecx_tp_headers
where	tp_header_id = p_tp_header_id;

l_CursorID	NUMBER;
l_result	NUMBER;
l_Select	VARCHAR2(2400);
begin
	for c_info in cinfo
	loop
		p_party_id := c_info.party_id;
		p_party_site_id := c_info.party_site_id;
		p_party_type := c_info.party_type;
		p_admin_email := c_info.company_admin_email;
	end loop;

	if p_party_site_id is null
	then
                retcode :=0;
                retmsg := ecx_debug.getTranslatedMessage('ECX_INVALID_TP_HDR_ID',
                          'p_tp_header_id', p_tp_header_id);
                ecx_debug.setErrorInfo(1,30,
                         'ECX_INVALID_TP_HDR_ID', 'p_tp_header_id', p_tp_header_id);
		return;
	end if;

	/** Try to derive the org_id for the transaction **/
	if p_party_type is not null
	then
		/** Customer **/
		if p_party_type = 'C'
		then
		   l_Select := ' select	haa.org_id' ||
			       ' from   hz_cust_acct_sites_all haa ,' ||
			       '	hz_cust_accounts  ha ' ||
			       ' where	ha.cust_account_id = :party_id' ||
			       ' and	haa.cust_account_id = ha.cust_account_id' ||
			       ' and	haa.cust_acct_site_id= :party_site_id ';

		/** Vendor **/
		elsif p_party_type = 'S'
		then
	 	   l_Select := ' select	org_id' ||
			       ' from	po_vendor_sites_all' ||
			       ' where	vendor_id = :party_id' ||
			       ' and    vendor_site_id = :party_site_id ';

		else
                   ecx_debug.setErrorInfo(1,30, 'ECX_INVALID_PARTY_TYPE', 'p_party_type',p_party_type);
                   retcode := 1;
                   retmsg := ecx_debug.getTranslatedMessage('ECX_INVALID_PARTY_TYPE',
                             'p_party_type',p_party_type);
		   return;
		end if;

		l_CursorID := DBMS_SQL.OPEN_CURSOR;
		DBMS_SQL.PARSE(l_CursorID, l_Select, DBMS_SQL.V7);
		DBMS_SQL.BIND_VARIABLE(l_CursorID, ':party_id', p_party_id);
		DBMS_SQL.BIND_VARIABLE(l_CursorID, ':party_site_id',
							p_party_site_id);
		DBMS_SQL.DEFINE_COLUMN(l_CursorID, 1, p_org_id);
		l_result := DBMS_SQL.EXECUTE(l_CursorID);
		IF DBMS_SQL.FETCH_ROWS(l_CursorID) <> 0 THEN
	           DBMS_SQL.COLUMN_VALUE(l_CursorID, 1, p_org_id);
		END IF;
		DBMS_SQL.CLOSE_CURSOR(l_CursorID);
	end if;

exception
when others then
        ecx_debug.setErrorInfo(2,30, SQLERRM || '- ECX_TRADING_PARTNER_PVT.GET_TP_INFO');
        retcode := 2;
        retmsg := SQLERRM;
end get_tp_info;

PROCEDURE Get_Address_id
	(
   	p_location_code_ext		IN	VARCHAR2,
   	p_info_type			IN	VARCHAR2,
   	p_entity_address_id		OUT	NOCOPY pls_integer,
	p_org_id			OUT	NOCOPY pls_integer,
   	retcode				OUT	NOCOPY pls_integer,
   	retmsg				OUT	NOCOPY varchar2
	)
IS

l_CursorID	NUMBER;
l_result	NUMBER;
l_Select	VARCHAR2(2000);
BEGIN

   if ( p_info_type = ECX_Trading_Partner_PVT.G_CUSTOMER)
   then
	l_Select := ' select  haa.cust_acct_site_id,' ||
		    '	      haa.org_id' ||
		    ' from    hz_cust_acct_sites_all haa' ||
		    ' where   haa.ece_tp_location_code = :location_code_ext ';

   elsif (p_info_type = ECX_Trading_Partner_PVT.G_SUPPLIER)
   then
	l_Select := ' select  pvs.vendor_site_id,' ||
		    ' 	      pvs.org_id' ||
		    ' from    po_vendor_sites_all pvs' ||
		    ' where   pvs.ece_tp_location_code = :location_code_ext ';

   elsif (p_info_type = ECX_Trading_Partner_PVT.G_BANK)
   then
	l_Select := ' select  cbb.branch_party_id, null' ||
		    ' from    ce_bank_branches_v cbb, hz_contact_points hcp' ||
		    ' where   cbb.branch_party_id=hcp.owner_table_id and
		 	      hcp.owner_table_name = ''HZ_PARTIES'' and
			      hcp.contact_point_type = ''EDI'' and
			      hcp.edi_ece_tp_location_code = :location_code_ext ';

   elsif (p_info_type = ECX_Trading_Partner_PVT.G_LOCATION)
   then
	l_Select := ' select  location_id, null' ||
		    ' from    hr_locations_all' ||
		    ' where   ece_tp_location_code = :location_code_ext ';

   else
        ecx_debug.setErrorInfo(1,30, 'ECX_INVALID_ADDRESS_TYPE', 'p_address_type',p_info_type);
        retcode := 1;
        retmsg := ecx_debug.getTranslatedMessage( 'ECX_INVALID_ADDRESS_TYPE',
                  'p_address_type',p_info_type);
	return;
   end if;

   l_CursorID := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(l_CursorID, l_Select, DBMS_SQL.V7);
   DBMS_SQL.BIND_VARIABLE(l_CursorID, ':location_code_ext',
						p_location_code_ext);
   DBMS_SQL.DEFINE_COLUMN(l_CursorID, 1, p_entity_address_id);
   DBMS_SQL.DEFINE_COLUMN(l_CursorID, 2, p_org_id);
   l_result := DBMS_SQL.EXECUTE(l_CursorID);
   IF DBMS_SQL.FETCH_ROWS(l_CursorID) <> 0 THEN
      DBMS_SQL.COLUMN_VALUE(l_CursorID, 1, p_entity_address_id);
      DBMS_SQL.COLUMN_VALUE(l_CursorID, 2, p_org_id);
   END IF;
   DBMS_SQL.CLOSE_CURSOR(l_CursorID);


   if p_entity_address_id is NULL
   then
      ecx_debug.setErrorInfo(1,30,'ECX_ADDR_DERIVATION_ERR', 'p_address_type',p_info_type,
                             'p_location_code', p_location_code_ext);
      retcode := 1;
      retmsg := ecx_debug.getTranslatedMessage('ECX_ADDR_DERIVATION_ERR',
                           'p_address_type',p_info_type,
                           'p_location_code', p_location_code_ext);
   end if;


EXCEPTION
WHEN OTHERS THEN
      ecx_debug.setErrorInfo(2,30,
                SQLERRM ||' - ECX_TRADING_PARTNER_PVT.Get_TP_Address');
      retcode := 2;
      retmsg := SQLERRM;
end Get_Address_id;

/** Receivers TP Info **/
procedure get_receivers_tp_info
	(
	p_party_id		OUT	NOCOPY NUMBER,
	p_party_site_id		OUT	NOCOPY NUMBER,
	p_org_id		OUT	NOCOPY pls_integer,
	p_admin_email		OUT	NOCOPY varchar2,
	retcode			OUT	NOCOPY pls_integer,
	retmsg			OUT	NOCOPY varchar2
	)
is
begin
	if ecx_utils.g_rec_tp_id is not null
	then
		get_tp_info
		(
		p_tp_header_id => ECX_UTILS.G_rec_tp_id,
		p_party_id => p_party_id,
		p_party_site_id => p_party_site_id,
		p_org_id => p_org_id,
		p_admin_email => p_admin_email,
		retcode => retcode,
		retmsg => retmsg
		);
	else
                ecx_debug.setErrorInfo(1,30,'ECX_RCVR_NOT_SETUP', 'p_tp_header_id', ECX_UTILS.G_rec_tp_id);
                retcode := 1;
                retmsg := ecx_debug.getTranslatedMessage('ECX_RCVR_NOT_SETUP');
	end if;
EXCEPTION
WHEN OTHERS THEN
      ecx_debug.setErrorInfo(2,30,
               SQLERRM ||' - ECX_TRADING_PARTNER_PVT. GET_RECEIVERS_TP_INFO');
      retcode := 2;
      retmsg := SQLERRM ||' - ECX_TRADING_PARTNER_PVT. GET_RECEIVERS_TP_INFO';
end get_receivers_tp_info;

/** Senders TP Info **/
procedure get_senders_tp_info
	(
	p_party_id		OUT	NOCOPY NUMBER,
	p_party_site_id		OUT	NOCOPY NUMBER,
	p_org_id		OUT	NOCOPY pls_integer,
	p_admin_email		OUT	NOCOPY varchar2,
	retcode			OUT	NOCOPY pls_integer,
	retmsg			OUT	NOCOPY varchar2
	)
is
begin
	if ecx_utils.g_snd_tp_id is not null
	then
		get_tp_info
		(
		p_tp_header_id => ECX_UTILS.G_snd_tp_id,
		p_party_id => p_party_id,
		p_party_site_id => p_party_site_id,
		p_org_id => p_org_id,
		p_admin_email => p_admin_email,
		retcode => retcode,
		retmsg => retmsg
		);
	else
                ecx_debug.setErrorInfo(1,30, 'ECX_SNDR_NOT_ENABLED','p_tp_header_id',ECX_UTILS.G_snd_tp_id);
                retcode := 1;
                retmsg := ecx_debug.getTranslatedMessage('ECX_SNDR_NOT_SETUP');
	end if;

EXCEPTION
WHEN OTHERS THEN
      ecx_debug.setErrorInfo(2,30,
       SQLERRM ||' - ECX_TRADING_PARTNER_PVT.GET_SENDERS_TP_INFO');
      retcode := 2;
      retmsg := SQLERRM;
end get_senders_tp_info;

/** Get TP Company  email ****/
procedure get_tp_company_email(l_transaction_type        IN varchar2,
                               l_transaction_subtype     IN varchar2,
                               l_party_site_id  	 IN number,
                               l_party_type              IN  varchar2 , --bug #2183619
                               l_email_addr     	OUT NOCOPY varchar2,
	                       retcode          	OUT NOCOPY pls_integer,
			       errmsg		 	OUT NOCOPY varchar2) IS
BEGIN
-- Added check for party type for bug #2183619
	Select eth.company_admin_email
        Into   l_email_addr
	From   ecx_tp_headers eth,
               ecx_transactions et
       where  eth.party_type = et.party_type
       and  et.transaction_type = l_transaction_type
       and  et.transaction_subtype = l_transaction_subtype
       and  eth.party_site_id = l_party_site_id
       and (l_party_type is null or et.party_type = l_party_type);


        ecx_utils.error_type := 10;
	retcode := 0;

	Exception
	When no_data_found Then
          ecx_debug.setErrorInfo(1,30,'ECX_NO_EMAIL_ADDR',
          'p_transaction_type', l_transaction_type,
          'p_transaction_subtype', l_transaction_subtype,
          'p_party_type', l_party_type,
          'p_party_site_id', l_party_site_id);

       /* Start of bug #2183619*/
       when too_many_rows then
                ecx_debug.setErrorInfo(2,30,'ECX_PARTY_TYPE_NOT_SET');
		raise ecx_utils.program_exit;
       /* End of bug #2183619 */

	When Others Then
     	   retcode := 2;
    	   errmsg  := SQLERRM || ' At ECX_TRADING_PARTNER_PVT.GET_TP_COMPANY_EMAIL';
           ecx_debug.setErrorInfo(2,30,SQLERRM);
End Get_TP_Company_Email;

/** Get System Adminstrator Email   ***/
Procedure get_sysadmin_email(email_address OUT NOCOPY varchar2,
                             retcode       OUT NOCOPY pls_integer,
			     errmsg        OUT NOCOPY varchar2)
Is

l_String	VARCHAR2(2000);
l_instlmode	VARCHAR2(100);
l_CursorID	NUMBER;
l_result	NUMBER;
l_profile	VARCHAR2(100) := 'ECX_SYS_ADMIN_EMAIL';
Begin

  -- Obtain the installation type - STANALONE/EMBEDDED.
  l_instlmode := wf_core.translate('WF_INSTALL');

  IF l_instlmode = 'EMBEDDED' THEN
null;

     l_String := 'BEGIN
		  --fnd_profile.get(:profile_name,:email_address);
                  :email_address:=
                     fnd_profile.value_specific(
                     name=>:l_profile,user_id=>0,responsibility_id=>20420,
                     application_id=>174,org_id=>null,server_id=>null);
		  END;';
     l_CursorID := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE(l_CursorID, l_String, DBMS_SQL.V7);
     DBMS_SQL.BIND_VARIABLE(l_CursorID, ':l_profile', l_profile);
     /* Bug# 2243620 - email_address default length is 0 and the email
        address returned is null unless bind_out_value is specified to be 2000*/
     DBMS_SQL.BIND_VARIABLE(l_CursorID, ':email_address', email_address, 2000);
     l_result := DBMS_SQL.EXECUTE(l_CursorID);
     DBMS_SQL.VARIABLE_VALUE(l_CursorID, ':email_address', email_address);
     DBMS_SQL.CLOSE_CURSOR(l_CursorID);
  ELSE
     email_address := wf_core.translate('ECX_SYS_ADMIN_EMAIL');
  END IF;

 ecx_utils.error_type := 10;
 retcode := 0;
Exception
When Others Then
   ecx_debug.setErrorInfo(2,30,
        SQLERRM || ' - ECX_TRADING_PARTNER_PVT.get_sysadmin_email');
   retcode := 2;
   errmsg := SQLERRM;
End;

/** Get TP Details given party_type, party_id, party_site_id, trxn type trxn subtype **/

Procedure get_tp_details (p_party_type          IN  varchar2,
                          p_party_id            IN  number,
			  p_party_site_id       IN  number,
			  p_transaction_type    IN  varchar2,
  			  p_transaction_subtype IN  varchar2,
                          p_protocol_type       OUT NOCOPY varchar2,
			  p_protocol_address    OUT NOCOPY varchar2,
                          p_username            OUT NOCOPY varchar2,
			  p_password            OUT NOCOPY varchar2,
                          p_retcode             OUT NOCOPY pls_integer,
			  p_errmsg              OUT NOCOPY varchar2)  IS

Begin
	If p_party_type     is NOT NULL	 Then
	   If p_party_id       is NOT NULL Then
	      If p_party_site_id  is NOT NULL	 Then

	         Select  etpd.protocol_type, etpd.protocol_address,
		         etpd.username, etpd.password
	         Into    p_protocol_type, p_protocol_address,
		         p_username, p_password
	         From   ECX_TP_HEADERS etph, ECX_TP_DETAILS_V etpd
	         Where  etph.party_type    = p_party_type
	         And	  etph.party_id      = p_party_id
	         And	  etph.party_site_id = p_party_site_id
                 And    etpd.tp_header_id  = etph.tp_header_id
                 And    etpd.transaction_type = p_transaction_type
	         And    etpd.transaction_subtype = p_transaction_subtype;

                 ecx_utils.error_type := 10;
	         p_retcode := 0;
	      Else
                 ecx_debug.setErrorInfo(1,30, 'ECX_PARTY_SITE_ID_NOT_NULL');
            End If;
           Else
              ecx_debug.setErrorInfo(1,30, 'ECX_PARTY_ID_NOT_NULL');
           End If;
         Else
            ecx_debug.setErrorInfo(1,30, 'ECX_PARTY_TYPE_NOT_NULL');
        End IF;
        p_retcode := ecx_utils.i_ret_code;
        p_errmsg := ecx_utils.i_errbuf;
EXCEPTION
When no_data_found Then
     p_retcode := 1;
     p_errmsg :=  ecx_debug.getTranslatedMessage('ECX_NO_UNIQUE_TP_SETUP');
     ecx_debug.setErrorInfo(1,30,
               'ECX_NO_UNIQUE_TP_SETUP');
When Others  Then
     ecx_debug.setErrorInfo(2,30,
               SQLERRM || ' At ECX_TRADING_PARTNER_PVT.GET_TP_DETAILS');
     p_retcode := 2;
     p_errmsg  := SQLERRM || ' At ECX_TRADING_PARTNER_PVT.GET_TP_DETAILS';
END get_tp_details;

/** Get error type***/
Procedure get_error_type ( i_error_type		OUT	NOCOPY pls_integer,
			   retcode		OUT	NOCOPY pls_integer,
			   errmsg		OUT 	NOCOPY varchar2) Is
Begin
       i_error_type := ecx_utils.error_type;
       retcode := 0;
Exception
When Others Then
     ecx_debug.setErrorInfo(2,30, SQLERRM);
     retcode := 0;
     errmsg := SQLERRM;
End get_error_type;

procedure getEnvelopeInformation
	(
	i_internal_control_number	in      pls_integer,
	i_message_type                  OUT     NOCOPY varchar2,
	i_message_standard              OUT     NOCOPY varchar2,
	i_transaction_type              OUT     NOCOPY varchar2,
	i_transaction_subtype           OUT     NOCOPY varchar2,
	i_document_number               OUT     NOCOPY varchar2,
	i_party_id                      OUT     NOCOPY varchar2,
	i_party_site_id                 OUT     NOCOPY varchar2,
	i_protocol_type                 OUT     NOCOPY varchar2,
	i_protocol_address              OUT     NOCOPY varchar2,
	i_username                      OUT     NOCOPY varchar2,
	i_password                      OUT     NOCOPY varchar2,
	i_attribute1                    OUT     NOCOPY varchar2,
	i_attribute2                    OUT     NOCOPY varchar2,
	i_attribute3                    OUT     NOCOPY varchar2,
	i_attribute4                    OUT     NOCOPY varchar2,
	i_attribute5                    OUT     NOCOPY varchar2,
	retcode                         OUT     NOCOPY pls_integer,
	retmsg                          OUT     NOCOPY varchar2
	)
is

cursor get_msg_attributes(p_icn in	pls_integer)
is
select 	message_type,
	message_standard,
       	transaction_type,
       	transaction_subtype,
	document_number,
       	partyid,
       	party_site_id,
	protocol_type,
	protocol_address,
	username,
	password,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5
  from ecx_doclogs
 where internal_control_number = p_icn;

	i_get_msg_attributes	get_msg_attributes%ROWTYPE;
begin
    	open get_msg_attributes(p_icn => i_internal_control_number);
    	fetch get_msg_attributes into i_get_msg_attributes;

		i_message_type 			:= i_get_msg_attributes.message_type;
		i_message_standard 		:= i_get_msg_attributes.message_standard;
          	i_transaction_type 		:= i_get_msg_attributes.transaction_type;
          	i_transaction_subtype 		:= i_get_msg_attributes.transaction_subtype;
          	i_document_number 		:= i_get_msg_attributes.document_number;
          	i_party_id 			:= i_get_msg_attributes.partyid;
          	i_party_site_id 		:= i_get_msg_attributes.party_site_id;
          	i_protocol_type 		:= i_get_msg_attributes.protocol_type;
          	i_protocol_address 		:= i_get_msg_attributes.protocol_address;
          	i_username 			:= i_get_msg_attributes.username;
          	i_password 			:= i_get_msg_attributes.password;
          	i_attribute1 			:= i_get_msg_attributes.attribute1;
          	i_attribute2 			:= i_get_msg_attributes.attribute2;
          	i_attribute3 			:= i_get_msg_attributes.attribute3;
          	i_attribute4 			:= i_get_msg_attributes.attribute4;
          	i_attribute5 			:= i_get_msg_attributes.attribute5;

    	if get_msg_attributes%NOTFOUND
    	then
                ecx_debug.setErrorInfo(1,30, 'ECX_NO_ENVELOPE',
                          'p_icn', i_internal_control_number);
                retcode := 1;
                retmsg := ecx_debug.getTranslatedMessage('ECX_NO_ENVELOPE',
                          'p_icn', i_internal_control_number);
		if get_msg_attributes%ISOPEN
		then
			close get_msg_attributes;
		end if;

		return;
    	end if;

    	retcode :=0;

	if get_msg_attributes%ISOPEN
	then
		close get_msg_attributes;
	end if;
exception
when others then
	if get_msg_attributes%ISOPEN
	then
		close get_msg_attributes;
	end if;

        ecx_debug.setErrorInfo(2,30, SQLERRM || ' -ECX_TRADING_PARTNER_PVT.getEnvelopeInformation');
        retcode :=2;
        retmsg := SQLERRM || ' -ECX_TRADING_PARTNER_PVT.getEnvelopeInformation';
end getEnvelopeInformation;

procedure setOriginalReferenceId
	(
	i_internal_control_number       in      varchar2,
	i_original_reference_id         in      varchar2,
	retcode                 	OUT     NOCOPY pls_integer,
	retmsg                  	OUT     NOCOPY varchar2
	)
is
begin
	retcode := 0;
	retmsg := null;

	update  ecx_doclogs
	set     orig_reference_id = i_original_reference_id
	where   internal_control_number = i_internal_control_number;

exception
when others then
	retcode := 2;
	retmsg  := substr(SQLERRM,1,200);
        ecx_debug.setErrorInfo(2,30,
                  substr(SQLERRM,1,200) || ' -ECX_TRADING_PARTNER_PVT.setOriginalReferenceId');
end setOriginalReferenceId;


function getOAGLOGICALID
	return varchar2
is
i_string        varchar2(2000);
begin
	--- Check for the Installation Type ( Standalone or Embedded );
	ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');
	if ecx_utils.g_install_mode = 'EMBEDDED'
	then
		i_string := 'begin
		fnd_profile.get('||'''ECX_OAG_LOGICALID'''||',ecx_trading_partner_pvt.g_oag_logicalid);
		end;';
		execute immediate i_string ;
	else
		ecx_trading_partner_pvt.g_oag_logicalid := wf_core.translate('ECX_OAG_LOGICALID');
	end if;

	return ecx_trading_partner_pvt.g_oag_logicalid;
exception
when others then
	return null;
end getOAGLOGICALID;

   Function IsUserAuthorized (p_user_name    IN VARCHAR2,
	                      p_tp_header_id IN PLS_INTEGER,
                              p_profile_value  IN VARCHAR2)
   Return Boolean is
   preference_value varchar2(100);
   profile_value varchar2(1);
   Begin
      profile_value := p_profile_value;
      if (profile_value is null)
      then
         fnd_profile.get('ECX_USER_CHECK',profile_value);
      end if;
      if (nvl(profile_value,'N') = 'N') then
         return true;
      end if;
      preference_value := fnd_preference.get(upper(p_user_name),'ECX','TP_ENABLED');
      if (preference_value = p_tp_header_id) then
         return true;
      else
         return false;
      end if;
   Exception
   When Others then
       return false;
   End IsUserAuthorized;

   function validateTPUser (
	  p_transaction_type     IN VARCHAR2,
	  p_transaction_subtype  IN VARCHAR2,
	  p_standard_code        IN VARCHAR2,
	  p_standard_type        IN VARCHAR2,
	  p_party_site_id        IN VARCHAR2,
	  p_user_name            IN VARCHAR2,
	  x_tp_header_id         OUT NOCOPY NUMBER,
	  retcode                OUT NOCOPY VARCHAR2,
	  errmsg                 OUT NOCOPY VARCHAR2)
   return varchar2 is
     x_queue_name varchar2(100);
     p_tp_flag boolean;
     p_user_flag boolean;
     profile_value varchar2(1);
   begin
      fnd_profile.get('ECX_USER_CHECK',profile_value);
      if (nvl(profile_value,'N') = 'N') then
        profile_value := 'N';
        return 'Y';
      end if;

       p_tp_flag := ecx_rule.isTPEnabled ( p_transaction_type,
                                           p_transaction_subtype,
                                           p_standard_code,
                                           p_standard_type,
                                           p_party_site_id,
                                           x_queue_name,
                                           x_tp_header_id);

      if (p_tp_flag) then
      retcode := 0;
      else
      retcode := 1;
      errmsg := ecx_debug.getTranslatedMessage('ECX_RULE_INVALID_TP_SETUP',
                          'p_standard_code', p_standard_code,'p_transaction_type',p_transaction_type,
			 'p_transaction_subtype',p_transaction_subtype,'p_party_site_id',p_party_site_id);

      ecx_debug.setErrorInfo(2,30,
                         'ECX_RULE_INVALID_TP_SETUP', 'p_standard_code', p_standard_code,'p_transaction_type',p_transaction_type,
			 'p_transaction_subtype',p_transaction_subtype,'p_party_site_id',p_party_site_id);

      return 'N';
      end if;


      p_user_flag := IsUserAuthorized( p_user_name,
                                       x_tp_header_id,
                                       profile_value);


      if (p_user_flag) then
      retcode := 0;
      return 'Y';
      else
      retcode := 2;
      errmsg := ecx_debug.getTranslatedMessage('ECX_USER_TP_NOT_VALID',
                          'p_user_name',p_user_name);
      ecx_debug.setErrorInfo(2,30,
                         'ECX_USER_TP_NOT_VALID','p_user_name',p_user_name);
      return 'N';
      end if;
   Exception
   when others then
      retcode := 1;
      return 'N';
   End validateTPUser;

END  ECX_TRADING_PARTNER_PVT;

/
