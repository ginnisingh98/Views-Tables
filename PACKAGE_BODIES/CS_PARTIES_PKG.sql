--------------------------------------------------------
--  DDL for Package Body CS_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_PARTIES_PKG" AS
/* $Header: csxptsb.pls 115.7 2002/09/13 17:06:07 epajaril ship $ */
FUNCTION Get_Party_Phone
	(
		p_party_id IN NUMBER,
		p_telephone_type IN VARCHAR2
	) RETURN VARCHAR2 IS

CURSOR cur_party_phone IS
	select
		decode(phone_country_code,null,null,phone_country_code||'-')||
		decode(phone_area_code,null,'(  )','('||phone_Area_code||')')||
phone_number||decode(phone_extension,null,null,' x'||phone_extension) phone_number
	from
		hz_contact_points
	where  owner_table_name = 'HZ_PARTIES' and
		owner_table_id = p_party_id and
		contact_point_type = 'PHONE' and
		phone_line_type = p_telephone_type
		order by 1;


CURSOR cur_party_phone_count IS
	select
		count(*)
	from
		hz_contact_points
	where  owner_table_name = 'HZ_PARTIES' and
		owner_table_id = p_party_id and
		contact_point_type = 'PHONE' and
		phone_line_type = p_telephone_type
		order by 1;

CURSOR cur_primary_party_phone IS

	select
		decode(phone_country_code,null,null,phone_country_code||'-')||
		decode(phone_area_code,null,'(  )','('||phone_Area_code||')')||
phone_number||decode(phone_extension,null,null,' x'||phone_extension) phone_number
	from
		hz_contact_points
	where  owner_table_name = 'HZ_PARTIES' and
		owner_table_id = p_party_id and
		contact_point_type = 'PHONE' and
		phone_line_type = p_telephone_type and
		primary_flag = 'Y' order by 1;
l_primary_phone_number	varchar2(50);

l_phone_number			varchar2(60);
l_phone_number_cnt		varchar2(5);
BEGIN
	open cur_party_phone_count;
	fetch cur_party_phone_count into l_phone_number_cnt;
	if cur_party_phone_count%NOTFOUND then
		return(null);
	end if;
	close cur_party_phone_count;


	open cur_party_phone;
	loop

		fetch cur_party_phone into l_phone_number;
		if cur_party_phone%NOTFOUND then
			RETURN(null);
		end if;
		if l_phone_number_cnt > 1 then
		if cur_party_phone%ROWCOUNT > 1 then
			BEGIN
				open cur_primary_party_phone;
				loop
					fetch cur_primary_party_phone into l_primary_phone_number;
					if cur_primary_party_phone%NOTFOUND then
						RETURN(l_phone_number);
					end if;

					if cur_primary_party_phone%FOUND then
						RETURN(l_primary_phone_number);
					end if;
				end loop;
				close cur_primary_party_phone;
			END;
		end if;
		else
			RETURN(l_phone_number);
		end if;
	end loop;
		RETURN(l_phone_number);
	close cur_party_phone;

END;

FUNCTION Get_Party_Email
	(
	p_party_id IN NUMBER
	)
RETURN VARCHAR2 IS
l_email		varchar2(50);
CURSOR cur_email IS
	select email_Address from hz_contact_points
	where
		owner_table_name = 'HZ_PARTIES' and
		owner_table_id = p_party_id and contact_point_type = 'EMAIL'

		order by 1;
Begin
	open cur_email;
		fetch cur_email into l_email;
		if cur_email%NOTFOUND then
			RETURN(NULL);
		end if;
	close cur_email;
	RETURN(l_email);
End;

FUNCTION Get_Party_Fax
	(

		p_party_id IN NUMBER
	) RETURN VARCHAR2 IS
CURSOR cur_party_fax IS
	select
		decode(phone_country_code,null,null,phone_country_code||'-')||
		decode(phone_area_code,null,'(  )','('||phone_Area_code||')')||phone_number||
		decode(phone_extension,null,null,' x'||phone_extension) phone_number
	from
		hz_contact_points
	where  owner_table_name = 'HZ_PARTIES' and
		owner_table_id = p_party_id and
		contact_point_type = 'PHONE'
                and phone_line_type = 'FAX'
		order by 1;

l_fax_number			varchar2(60);
BEGIN
	open cur_party_fax;
		fetch cur_party_fax into l_fax_number;
		if cur_party_fax%NOTFOUND then
			RETURN(null);
		end if;
	close cur_party_fax;
		RETURN(l_fax_number);
END;
END CS_Parties_PKG;

/
