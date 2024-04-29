--------------------------------------------------------
--  DDL for Package Body IBY_ADDRESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_ADDRESS_PKG" as
/*$Header: ibyadrsb.pls 120.1 2005/10/30 05:49:33 appldev noship $*/
/*
** Function: createAddress
** Purpose:  Creates an entry in the iby_address table and assigns an id
**           to identify it.
** Parameters:
**
**    In  : i_address1, i_address2, i_address3, i_city, i_county,
**          i_state, i_country, i_postalcode.
**    Out : io_addressid.
**
*/
procedure createAddress( i_address1 hz_locations.address1%type,
                      i_address2 hz_locations.address2%type,
                      i_address3 hz_locations.address3%type,
                      i_city hz_locations.city%type,
                      i_county hz_locations.county%type,
                      i_state hz_locations.state%type,
                      i_country hz_locations.country%type,
                      i_postalcode hz_locations.postal_code%type,
                      o_addressid  out nocopy hz_locations.location_id%type)
is

p_api_version   NUMBER := 1;
p_init_msg_list VARCHAR2(1) := fnd_api.G_TRUE;
p_commit        VARCHAR2(1) := fnd_api.G_FALSE;
  l_hz_location_v2_rec                 HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
--location_rec 	hz_location_pub.location_rec_type;
l_location_id 	number;
msg_txt varchar2(2000);
l_return_status         varchar2(100);

l_msg_count             number;
l_msg_data              varchar2(2000);

begin
--fnd_client_info.set_org_context(204);

l_hz_location_v2_rec.address1 := i_address1;
l_hz_location_v2_rec.address2 := i_address2;
l_hz_location_v2_rec.address3 := i_address3;
l_hz_location_v2_rec.city := i_city;
l_hz_location_v2_rec.state := i_state;
l_hz_location_v2_rec.county := i_county;
l_hz_location_v2_rec.postal_code := i_postalcode;
l_hz_location_v2_rec.country := i_country;
l_hz_location_v2_rec.created_by_module := 'IBY';

--dbms_output.put_line('Before hz_location.create ');

    hz_location_v2pub.create_location(
      p_location_rec             =>  l_hz_location_v2_rec,
      x_location_id              =>  l_location_id,
      x_return_status            =>  l_return_status,
      x_msg_count                =>  l_msg_count,
      x_msg_data                 =>  l_msg_data);
/*
    HZ_LOCATION_PUB.create_location(
                p_api_version,
                p_init_msg_list,
                p_commit,
                location_rec,
                l_return_status,
                l_msg_count,
                l_msg_data,
                l_location_id);
*/
  --dbms_output.put_line('x_msg_count = '||to_char(l_msg_count));
  --dbms_output.put_line('l_return_status = '||l_return_status);
  --dbms_output.put_line('x_msg_data = '||l_msg_data);
  --dbms_output.put_line('location_id = '||to_char(l_location_id));

  /*
   ** Catch the exception if create not successful
   */
  if l_return_status <> 'S' then
      if l_msg_count = 1 then
         msg_txt := l_msg_data;
      else
         for i in 1..l_msg_count loop

           msg_txt := msg_txt ||' '|| FND_MSG_PUB.GET(i,'F');

         end loop;

        -- o_msg := msg_txt;
      end if;
       --dbms_output.put_line('text is : '||msg_txt);
       --raise_application_error(-20000,'IBY_204550#CCM_API_MSG=' || msg_txt,FALSE);
       raise_application_error(-20000,'IBY_20496#CCM_API_MSG=' || msg_txt,FALSE);
       -- returns message 'Could not create or modify address information. Data entered could be invalid.'
       --dbms_output.put_line('Error : '||'Location not created');
      --ROLLBACK TO CreateOrganization;
   end if;

  o_addressid := l_location_id;
end createAddress;
/*
** Function: modAddress
** Purpose:  modifies the entry in the hz_locations table that matches addressid
**           passed with the values specified.
** Parameters:
**
**    In  : i_addressid, i_address1, i_address2, i_address3, i_city,
**          i_county, i_state, i_country, i_postalcode.
**    Out : None.
**
*/
procedure    modAddress(i_addressid hz_locations.location_id%type,
                      i_address1 hz_locations.address1%type,
                      i_address2 hz_locations.address2%type,
                      i_address3 hz_locations.address3%type,
                      i_city hz_locations.city%type,
                      i_county hz_locations.county%type,
                      i_state hz_locations.state%type,
                      i_country hz_locations.country%type,
                      i_postalcode hz_locations.postal_code%type)
is
p_api_version   NUMBER := 1;
p_init_msg_list VARCHAR2(1) := fnd_api.G_TRUE;
p_commit        VARCHAR2(1) := fnd_api.G_FALSE;
-- location_rec    hz_location_pub.location_rec_type;
  l_hz_location_v2_rec                 HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
  l_ovn                                NUMBER;
l_location_id   number;
msg_txt varchar2(2000);
l_return_status         varchar2(100);
l_msg_count             number;
l_msg_data              varchar2(2000);
p_last_update_date	date;
begin

/*
** Get the last update date from hz_location
*/
--fnd_client_info.set_org_context(204);
l_hz_location_v2_rec.address1 := i_address1;
l_hz_location_v2_rec.address2 := i_address2;
l_hz_location_v2_rec.address3 := i_address3;
l_hz_location_v2_rec.city := i_city;
l_hz_location_v2_rec.state := i_state;
l_hz_location_v2_rec.county := i_county;
l_hz_location_v2_rec.postal_code := i_postalcode;
l_hz_location_v2_rec.country := i_country;
l_hz_location_v2_rec.location_id := i_addressid;

/*
** Get the last update date from hz_location
*/
-- it doesn't make sense to change the payment API signature
-- for the OVN. we are assuming that no body has changed the
-- hz_location record since the user for our transaction read
-- the record. otherwise the change will simply be overwritten
select last_update_date, object_version_number into p_last_update_date, l_ovn
from hz_locations
where location_id = l_hz_location_v2_rec.location_id;

      hz_location_v2pub.update_location(
        p_location_rec             =>  l_hz_location_v2_rec,
        p_object_version_number    =>  l_ovn,
        x_return_status            =>  l_return_status,
        x_msg_count                =>  l_msg_count,
        x_msg_data                 =>  l_msg_data
      );
/*
    HZ_LOCATION_PUB.update_location(

                p_api_version,
                p_init_msg_list,
                p_commit,
                location_rec,
                p_last_update_date,
                l_return_status,
                l_msg_count,
                l_msg_data);
*/

  --dbms_output.put_line('x_msg_count = '||to_char(l_msg_count));

  --dbms_output.put_line('l_return_status = '||l_return_status);
  --dbms_output.put_line('x_msg_data = '||l_msg_data);

  /*
   ** Catch the exception if create not successful
   */

  if l_return_status <> 'S' then
      if l_msg_count = 1 then
         msg_txt := l_msg_data;
      else

         for i in 1..l_msg_count loop
           msg_txt := msg_txt ||' '|| FND_MSG_PUB.GET(i,'F');
         end loop;
        -- o_msg := msg_txt;
      end if;
       --dbms_output.put_line('text is : '||msg_txt);
       --raise_application_error(-20000,'IBY_204550#CCM_API_MSG=' || msg_txt,FALSE);
       raise_application_error(-20000,'IBY_20496#CCM_API_MSG=' || msg_txt,FALSE);
       -- returns message 'Could not create or modify address information. Data entered could be invalid.'
       --dbms_output.put_line('Error : '||'Location not updated');
      --ROLLBACK TO CreateOrganization;

   end if;

        --raise_application_error(-20902, 'NO Address Info matched ', FALSE);
end modAddress;
end iby_address_pkg;


/
