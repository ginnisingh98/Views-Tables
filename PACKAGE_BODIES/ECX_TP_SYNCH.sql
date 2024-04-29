--------------------------------------------------------
--  DDL for Package Body ECX_TP_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_TP_SYNCH" as
-- $Header: ECXTPSYNB.pls 120.10 2006/10/11 06:19:48 gsingh noship $
procedure synch_ecx_tp

	  IS

	TYPE t_party_id_tl is TABLE of ecx_tp_headers.party_id%type;
	TYPE t_orig_system_id_tl is TABLE of wf_local_roles.orig_system_id%type;
	TYPE t_party_site_id_tl is TABLE of ecx_tp_headers.party_site_id%type;

	v_party_id_tl t_party_id_tl;

	V_PARTY_SITE_ID_TL  ecx_tp_headers.party_site_id%type;
	V_PARTY_TYPE_TL ecx_tp_headers.party_type%type;

	P_COMPANY_EMAIL_ADDR varchar2(320);
	l_event_name varchar2(250);

party_name_params wf_parameter_list_t;
site_name_params wf_parameter_list_t;
org_table_name varchar2(350);
party_name varchar2(350);
org_site_table_name varchar2(350);
site_name varchar2(350);

cursor get_party_id  is
select party_id  from ecx_tp_headers;

cursor get_mail(p_party_id in ecx_tp_headers.party_id%type) is
select company_admin_email from ecx_tp_headers where party_id=p_party_id;

cursor get_party_type(p_party_id in ecx_tp_headers.party_id%type) is
select party_type from ecx_tp_headers where party_id=p_party_id;

cursor get_party_site_id(p_party_id in ecx_tp_headers.party_id%type) is
select party_site_id from ecx_tp_headers where party_id=p_party_id;

cursor internal_party_name(v_party_id varchar) is
 select LOCATION_CODE  from hr_locations  where LOCATION_ID=v_party_id ;

   cursor internal_site_name(v_party_id varchar) is
 select ADDRESS_LINE_1||ADDRESS_LINE_2||ADDRESS_LINE_3 ||town_or_city||country||postal_code from hr_locations
 where location_id =v_party_id ;

 cursor bank_party_name(v_party_id varchar) is
select BANK_NAME from CE_BANK_BRANCHES_V where BRANCH_PARTY_ID=v_party_id;

cursor bank_site_name(v_party_id varchar) is
select address_line1||' '||address_line2||' '||address_line3||' '||CITY||' '||ZIP from CE_BANK_BRANCHES_V where BRANCH_PARTY_ID=v_party_id;

  cursor supplier_party_name(v_party_id varchar) is
select p.vendor_name from PO_VENDORS p  where p.vendor_ID =v_party_id;

  cursor supplier_site_name(v_party_id varchar,v_party_site_id varchar) is
select p1.ADDRESS_LINE1||' '||p1.ADDRESS_LINE2||' '||p1.ADDRESS_LINE3||' '||p1.CITY||p1.ZIP from  PO_VENDOR_SITES_ALL p1
  where  p1.VENDOR_SITE_ID =v_party_site_id and p1.VENDOR_ID=v_party_id;


 cursor customer_party_name(v_party_id varchar) is
select PARTY_NAME from hz_parties where party_id=v_party_id;

    cursor customer_site_name(v_party_id varchar,v_party_site_id varchar) is
select ADDRESS1||' '||ADDRESS2||' ' || ADDRESS3 ||' '|| ADDRESS4||' ' ||CITY||' ' ||POSTAL_CODE||' ' ||
STATE ||' '||PROVINCE ||' '||COUNTY||' '||COUNTRY from hz_locations
where location_id =(select location_id from hz_party_sites where party_id=v_party_id and party_site_id=v_party_site_id);

   cursor org_table(v_party_id varchar) is
select  decode(party_type,'C','HZ_PARTIES','EXCHANGE','HZ_PARTIES','CARRIER','HZ_PARTIES','S','PO_VENDORS','I','HR_LOCATIONS','B','CE_BANK_BRANCHES_V') from ecx_tp_headers where party_id =v_party_id ;

  cursor org_table_site(v_party_id varchar) is
select  decode(party_type,'C','HZ_PARTY_SITES','EXCHANGE','HZ_PARTY_SITES','CARRIER','HZ_PARTY_SITES','S','PO_VENDOR_SITES_ALL','I','HR_LOCATIONS_SITES','B','CE_BANK_BRANCHES_SITE') from ecx_tp_headers where party_id =v_party_id ;


begin
OPEN get_party_id;
FETCH get_party_id BULK COLLECT INTO v_party_id_tl;
CLOSE get_party_id;





               for i in 1..v_party_id_tl.count loop
		       OPEN get_party_type(v_party_id_tl(i));
                       FETCH get_party_type into v_party_type_tl;
		       CLOSE get_party_type;

		       OPEN get_party_site_id(v_party_id_tl(i));
                       FETCH get_party_site_id into V_PARTY_SITE_ID_TL;
		       CLOSE get_party_site_id;

		        party_name_params := wf_parameter_list_t();
                        site_name_params := wf_parameter_list_t();

		        if (v_party_type_tl='I') then
	         open internal_party_name (v_party_id_tl(i));
                 fetch internal_party_name into party_name;
                 close internal_party_name;

		 open internal_site_name (v_party_id_tl(i));
                 fetch internal_site_name into site_name;
                 close internal_site_name;
		 end if;

                     if(v_party_type_tl='S')  then
                  open supplier_party_name(v_party_id_tl(i));
                  fetch supplier_party_name into party_name;
                  close supplier_party_name;

		 open supplier_site_name(v_party_id_tl(i),V_PARTY_SITE_ID_TL);
                 fetch supplier_site_name into site_name;
                 close supplier_site_name;
		     end if;

                    if(v_party_type_tl='B')  then
                 open bank_party_name(v_party_id_tl(i));
                 fetch bank_party_name into party_name;
                 close bank_party_name;

		 open bank_site_name(v_party_id_tl(i));
                 fetch bank_site_name into site_name;
                 close bank_site_name;
                    end if;

                 if(v_party_type_tl='C' OR v_party_type_tl='CARRIER' OR v_party_type_tl='EXCHANGE' ) then
                 open customer_party_name(v_party_id_tl(i));
                 fetch customer_party_name into party_name;
                 close customer_party_name;

		 open customer_site_name(v_party_id_tl(i),V_PARTY_SITE_ID_TL);
                 fetch customer_site_name into site_name;
                 close customer_site_name;
		 end if;

	         open get_mail(v_party_id_tl(i));
	         fetch get_mail into p_company_email_addr;
	         close get_mail;

	         open org_table(v_party_id_tl(i));
                 fetch org_table into org_table_name;
                 close org_table;

		 open org_table_site(v_party_id_tl(i));
                 fetch org_table_site into org_site_table_name;
                 close org_table_site;




              wf_event.addParameterToList(
                                    p_name          => 'USER_NAME',
                                    p_value         => org_table_name ||':'||v_party_id_tl(i),
                                    p_parameterlist => party_name_params);

              wf_event.addParameterToList(
                                    p_name          => 'DisplayName',
                                    p_value         => party_name,
                                    p_parameterlist => party_name_params);

              wf_event.addParameterToList(
                                    p_name          => 'mail',
                                    p_value         => p_company_email_addr,
                                    p_parameterlist => party_name_params);

	       wf_event.addParameterToList(
                                    p_name          => 'USER_NAME',
                                    p_value         => org_site_table_name||':'||V_PARTY_SITE_ID_TL,
                                    p_parameterlist => site_name_params);

              wf_event.addParameterToList(
                                    p_name          => 'DisplayName',
                                    p_value         => site_name,
                                    p_parameterlist => site_name_params);

              wf_event.addParameterToList(
                                    p_name          => 'mail',
                                    p_value         => p_company_email_addr,
                                    p_parameterlist => site_name_params);



	  wf_local_synch.propagate_role(
                 p_orig_system => org_table_name,
                 p_orig_system_id =>v_party_id_tl(i) ,
                 p_attributes => party_name_params,
                 p_start_date => sysdate
               );
	      wf_local_synch.propagate_role(
                 p_orig_system => org_site_table_name,
                 p_orig_system_id =>V_PARTY_SITE_ID_TL ,
                 p_attributes => site_name_params,
                 p_start_date => sysdate
                );

end loop;



End;
End;

/
