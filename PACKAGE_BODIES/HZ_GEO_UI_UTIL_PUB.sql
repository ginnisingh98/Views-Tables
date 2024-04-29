--------------------------------------------------------
--  DDL for Package Body HZ_GEO_UI_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEO_UI_UTIL_PUB" AS
/* $Header: ARHGEOUB.pls 120.10 2008/03/06 13:20:32 nshinde ship $ */
function check_dup_geo ( p_parent_id in NUMBER,
                         p_geo_name  in VARCHAR2,
                         p_geo_code  in VARCHAR2,
						 p_geo_type  in VARCHAR2)
RETURN VARCHAR2 IS



   l_return varchar2(10);

  cursor c_dup( l_parent_id in number
                 , l_geo_type in varchar2
                 , l_geo_name in varchar2
				 , l_geo_code  in varchar2)
      is
   select  hr.child_id,
          geo.geography_name
    from  hz_hierarchy_nodes hr
          , hz_geographies   geo
    where hr.hierarchy_type    = 'MASTER_REF'
     and  hr.parent_id         = l_parent_id
     and  hr.parent_table_name = 'HZ_GEOGRAPHIES'
     and  hr.child_table_name  = 'HZ_GEOGRAPHIES'
     and  hr.child_object_type  = l_geo_type
     and  hr.status            = 'A'
     and  hr.effective_end_date > sysdate
     and  geo.geography_id     =  hr.child_id
     and  nvl(geo.end_date , sysdate)
	                             > sysdate
     and  geo.geography_type   =  hr.child_object_type
     and  (
	       UPPER(geo.geography_name)   =  UPPER(l_geo_name)
	       OR
	       UPPER(geo.geography_code) =  UPPER(l_geo_code)
	       );


    r_dup c_dup%rowtype;



BEGIN
   l_return := 'N';

   open c_dup(p_parent_id, p_geo_type, p_geo_name, p_geo_code);
   fetch c_dup into r_dup;
   if (c_dup%FOUND)
   THEN
      l_return := 'Y';
   END IF;
   close c_dup;

   return l_return;

END check_dup_geo;

FUNCTION check_geo_tax_valid( p_map_id    in NUMBER,
                              p_geo_type  in VARCHAR2,
                              p_geo_tax  in VARCHAR2)
RETURN   VARCHAR2
IS

l_return varchar2(10);
 cursor c_val_chk(l_map_id in number,
                 l_geo_type in varchar2,
                 l_geo_tax  in varchar2)
     is
  select dtl.usage_dtl_id
   from  Hz_address_usages usg,
         Hz_address_usage_dtls dtl
   where usg.map_id   = l_map_id
     and usg.usage_code = l_geo_tax
     and usg.status_flag = 'A'
     and dtl.usage_id = usg.usage_id
     and dtl.geography_type = l_geo_type;

l_dtl_id NUMBER;

BEGIN
l_return := 'N';

open c_val_chk( p_map_id,
                p_geo_type,
                p_geo_tax);
fetch c_val_chk into l_dtl_id;
if(c_val_chk%found)
then
  l_return := 'Y';
end if;
close c_val_chk;

return l_return;

END check_geo_tax_valid;

PROCEDURE  update_map_usages(p_map_id           IN NUMBER,
                             p_tax_tbl          IN    HZ_GEO_UI_UTIL_PUB.tax_geo_tbl_type,
                             p_geo_tbl          IN    HZ_GEO_UI_UTIL_PUB.tax_geo_tbl_type,
                             p_init_msg_list    IN    VARCHAR2 ,
                             x_return_status    OUT   NOCOPY     VARCHAR2,
    						 x_msg_count        OUT   NOCOPY     NUMBER,
                             x_msg_data         OUT   NOCOPY     VARCHAR2,
                             x_show_gnr         OUT   NOCOPY     VARCHAR2
                            )
IS

cursor c_loc_tbl(l_map_id in number)
    is
select st.loc_tbl_name,
       geo.geography_id
 from  Hz_geo_struct_map st,
       hz_geographies geo
where  map_id = l_map_id
AND  st.country_code = geo.country_code
  AND  geo.geography_type = 'COUNTRY';

l_loc_tbl varchar2(2000);
l_geography_id number;
l_show_gnr  varchar2(10);

cursor c_get_usage(l_map_id in number)
    is
select usg.usage_id,
       usg.map_id,
       usg.usage_code
from   hz_address_usages usg
where  map_id = l_map_id
and    status_flag = 'A';

r_get_usage c_get_usage%rowtype;

cursor c_get_dtls(l_usage_id in number,
                  l_geo_type in varchar2)
    is
select usg.usage_dtl_id,
       usg.geography_type
from   hz_address_usage_dtls usg
where  usg.usage_id = l_usage_id
and    usg.geography_type = l_geo_type;

r_get_dtls  c_get_dtls%rowtype;


TYPE val_rec_type IS RECORD (
     usage_id                   NUMBER,
     usage_dtl_id               NUMBER,
     geography_type             VARCHAR2(360)
     );

TYPE val_tbl_type IS TABLE OF val_rec_type
     INDEX BY BINARY_INTEGER;

tax_tbl   val_tbl_type;
geo_tbl   val_tbl_type;

l_tax_usage_id number := 0;
l_geo_usage_id number := 0;
i              number;
j              number;
k              number := 1;
l              number := 0;

l_address_usages_rec       HZ_ADDRESS_USAGES_PUB.address_usages_rec_type;
l_address_usage_dtls_tbl   HZ_ADDRESS_USAGES_PUB.address_usage_dtls_tbl_type;
l_address_usage_dtls_del_tbl   HZ_ADDRESS_USAGES_PUB.address_usage_dtls_tbl_type;

l_return_status  VARCHAR2(10);
l_msg_data       VARCHAR2(2000);
l_msg_count      NUMBER;
l_usg_dtl_id     NUMBER;

l_tax_id_ret     NUMBER;
l_geo_id_ret     NUMBER;

del_usg         boolean := false;
del_all_usg     boolean := true;

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- set gnr regenration message to N initially
    x_show_gnr      := 'N';
    l_show_gnr      := 'N';
IF(p_map_id > 0)
THEN

  -- Fetch values for the usage header for both Tax and Geo if it exists
  open c_get_usage(p_map_id);
  fetch c_get_usage into r_get_usage;
  while(c_get_usage%found)
  loop
     if(r_get_usage.usage_code = 'TAX')
     then
        l_tax_usage_id := r_get_usage.usage_id;
     elsif( r_get_usage.usage_code = 'GEOGRAPHY')
     then
        l_geo_usage_id := r_get_usage.usage_id;
     end if;
     fetch c_get_usage into r_get_usage;
  end loop;
  close c_get_usage;


  -- Fetch the loc_tbl_name
  open c_loc_tbl(p_map_id);
  fetch c_loc_tbl into l_loc_tbl, l_geography_id;
  close c_loc_tbl;

  -- check to see if GNR Results data exists
  l_show_gnr := get_geo_ref(p_geography_id   => l_geography_id,
                            p_loc_table_name => l_loc_tbl);

  -- if tax table is not null and l_tax_usage_id is 0, then insert the tax record
  if((p_tax_tbl.count > 0) AND ( l_tax_usage_id = 0))
  then

  -- insert new usage
      l_address_usages_rec.map_id         := p_map_id;
      l_address_usages_rec.usage_code     := 'TAX';
      l_address_usages_rec.status_flag    := 'A';
      l_address_usages_rec.created_by_module   := 'HZ_GEO_HIERARCHY';
      l_address_usages_rec.application_id      := 222;

      l_address_usage_dtls_tbl.delete;

      j := p_tax_tbl.first;
      FOR i in p_tax_tbl.first..p_tax_tbl.last
      LOOP
        if(p_tax_tbl(i).tax_geo_valid  = 'Y')
        then
          l_address_usage_dtls_tbl(j).geography_type      :=  p_tax_tbl(i).geography_type;
          l_address_usage_dtls_tbl(j).created_by_module   := 'HZ_GEO_HIERARCHY';
          l_address_usage_dtls_tbl(j).application_id      := 222;
          j := j+1;
		 end if;
      END LOOP;
      if(l_address_usage_dtls_tbl.count > 0)
      then
         hz_address_usages_pub.create_address_usages(p_address_usages_rec  => l_address_usages_rec,
	                                              p_address_usage_dtls_tbl => l_address_usage_dtls_tbl,
												  p_init_msg_list => FND_API.G_FALSE,
												  x_usage_id      => l_tax_id_ret,
												  x_return_status => l_return_status,
												  x_msg_count     => l_msg_count,
												  x_msg_data      => l_msg_data);

	     if(l_return_status <> 'S')
	     then
	      RAISE FND_API.G_EXC_ERROR ;
	     end if;
             if(nvl(l_show_gnr, 'N') = 'Y')
             then
               x_show_gnr := 'Y';
             end if;

	 end if;

  elsif((p_tax_tbl.count > 0) AND ( l_tax_usage_id <> 0))
  then


  -- insert new usages where it does not exist, delete those that have been removed
      FOR i in p_tax_tbl.first..p_tax_tbl.last
      LOOP
         open  c_get_dtls(l_tax_usage_id, p_tax_tbl(i).geography_type);
         fetch c_get_dtls into r_get_dtls;
         if((p_tax_tbl(i).tax_geo_valid = 'Y') and (c_get_dtls%found))
         then
--dbms_output.put_line('Sudar...2 tx usg');
            null;
         elsif((p_tax_tbl(i).tax_geo_valid = 'Y') and (c_get_dtls%notfound))
         then
--dbms_output.put_line('Sudar...3 tx usg');
           l_address_usage_dtls_tbl.delete;
           l_address_usage_dtls_tbl(1).geography_type      :=  p_tax_tbl(i).geography_type;
           l_address_usage_dtls_tbl(1).created_by_module   := 'HZ_GEO_HIERARCHY';
           l_address_usage_dtls_tbl(1).application_id      :=  222;
            -- insert dtl record
            hz_address_usages_pub.create_address_usage_dtls(
                                           p_usage_id         => l_tax_usage_id,
                                           p_address_usage_dtls_tbl  => l_address_usage_dtls_tbl,
                                           x_usage_dtl_id           => l_tax_id_ret,
                                           p_init_msg_list       => FND_API.G_FALSE,
                                           x_return_status => l_return_status,
										   x_msg_count     => l_msg_count,
										   x_msg_data      => l_msg_data);
		  if(l_return_status <> 'S')
	      then
	        RAISE FND_API.G_EXC_ERROR ;
	      end if;

	  if(nvl(l_show_gnr, 'N') = 'Y')
          then
           x_show_gnr := 'Y';
          end if;
-- Bug 4726672 : Modified code to call delete_address_usages with all usage records to
--      be deleted as a table instead of calling it individually.
--      Called delete_address_usages with p_address_usage_dtls_tbl = null
--      when all usages are to be deleted.

         elsif((p_tax_tbl(i).tax_geo_valid = 'N')) then
           l := l +1;
          if c_get_dtls%found then
            del_usg := true;
--dbms_output.put_line('Sudar...4 tx usg');
          -- delete detail
          --  l_address_usage_dtls_tbl.delete;
           l_address_usage_dtls_del_tbl(k).geography_type      :=  p_tax_tbl(i).geography_type;
           l_address_usage_dtls_del_tbl(k).created_by_module   := 'HZ_GEO_HIERARCHY';
           l_address_usage_dtls_del_tbl(k).application_id      :=  222;
           k := k +1;

           if i <> l then
	       del_all_usg := false;
	   end if;

          end if;
         end if;
         close c_get_dtls;
      END LOOP;

      if del_usg = true and (del_all_usg = false or l <> p_tax_tbl.last)
      then
          hz_address_usages_pub.delete_address_usages(p_usage_id  => l_tax_usage_id,
      	                                              p_address_usage_dtls_tbl => l_address_usage_dtls_del_tbl,
      		  	     	                      p_init_msg_list       => FND_API.G_FALSE,
                                                      x_return_status => l_return_status,
      				                      x_msg_count     => l_msg_count,
      				                      x_msg_data      => l_msg_data);
         if(nvl(l_show_gnr, 'N') = 'Y')
         then
            x_show_gnr := 'Y';
         end if;

      elsif del_usg = true and (del_all_usg = true and (l = p_tax_tbl.last ))
      then
          l_address_usage_dtls_del_tbl.delete;
          hz_address_usages_pub.delete_address_usages(p_usage_id  => l_tax_usage_id,
                                                      p_address_usage_dtls_tbl => l_address_usage_dtls_del_tbl,
                                                      p_init_msg_list       => FND_API.G_FALSE,
                                                      x_return_status => l_return_status,
                                                      x_msg_count     => l_msg_count,
                                                      x_msg_data      => l_msg_data);

         if(nvl(l_show_gnr, 'N') = 'Y')
         then
           x_show_gnr := 'Y';
         end if;

      end if;

      if(l_return_status <> 'S')
      then
          RAISE FND_API.G_EXC_ERROR ;
      end if;

  end if; -- end of p_tax_tbl.count > 0 check


  del_usg := false;
  del_all_usg := true;
  l := 0;
  k := 1;
  l_address_usage_dtls_del_tbl.delete;


  -- if geo table is not null and l_geo_usage_id is 0, then insert the geo record
  -- if tax table is not null and l_tax_usage_id is 0, then insert the tax record
  if((p_geo_tbl.count > 0) AND ( l_geo_usage_id = 0))
  then

  -- insert new usage
      l_address_usages_rec := null;
      l_address_usages_rec.map_id         := p_map_id;
      l_address_usages_rec.usage_code     := 'GEOGRAPHY';
      l_address_usages_rec.status_flag    := 'A';
      l_address_usages_rec.created_by_module   := 'HZ_GEO_HIERARCHY';
      l_address_usages_rec.application_id      := 222;

      l_address_usage_dtls_tbl.delete;
      j := p_geo_tbl.first;
      FOR i in p_geo_tbl.first..p_geo_tbl.last
      LOOP
        if(p_geo_tbl(i).tax_geo_valid  = 'Y')
        then
          l_address_usage_dtls_tbl(j).geography_type      :=  p_geo_tbl(i).geography_type;
          l_address_usage_dtls_tbl(j).created_by_module   := 'HZ_GEO_HIERARCHY';
          l_address_usage_dtls_tbl(j).application_id      := 222;
          j := j + 1;
        end if;
      END LOOP;
      if(l_address_usage_dtls_tbl.count > 0)
      then
         hz_address_usages_pub.create_address_usages(p_address_usages_rec  => l_address_usages_rec,
	                                              p_address_usage_dtls_tbl => l_address_usage_dtls_tbl,
												  p_init_msg_list => FND_API.G_FALSE,
												  x_usage_id      => l_geo_id_ret,
												  x_return_status => l_return_status,
												  x_msg_count     => l_msg_count,
												  x_msg_data      => l_msg_data);
	     if(l_return_status <> 'S')
	     then
	        RAISE FND_API.G_EXC_ERROR ;
	     end if;
             if(nvl(l_show_gnr, 'N') = 'Y')
             then
               x_show_gnr := 'Y';
             end if;

	  end if;
--dbms_output.put_line('Sudar...4 geo usg'||to_char(l_tax_usage_id)||'..'||l_return_status);

  elsif((p_geo_tbl.count > 0) AND ( l_geo_usage_id <> 0))
  then
  --  check for GNR data exists

  -- insert new usages where it does not exist, delete those that have been removed
      FOR i in p_geo_tbl.first..p_geo_tbl.last
      LOOP
         open  c_get_dtls(l_geo_usage_id, p_geo_tbl(i).geography_type);
         fetch c_get_dtls into r_get_dtls;
         if((p_geo_tbl(i).tax_geo_valid = 'Y') and (c_get_dtls%found))
         then
            null;
         elsif((p_geo_tbl(i).tax_geo_valid = 'Y') and (c_get_dtls%notfound))
         then
           l_address_usage_dtls_tbl.delete;
           l_address_usage_dtls_tbl(1).geography_type      :=  p_geo_tbl(i).geography_type;
           l_address_usage_dtls_tbl(1).created_by_module   := 'HZ_GEO_HIERARCHY';
           l_address_usage_dtls_tbl(1).application_id      :=  222;
            -- insert dtl record
            hz_address_usages_pub.create_address_usage_dtls(
                                           p_usage_id         => l_geo_usage_id,
                                           p_address_usage_dtls_tbl  => l_address_usage_dtls_tbl,
                                           x_usage_dtl_id           => l_geo_id_ret,
                                           p_init_msg_list       => FND_API.G_FALSE,
                                           x_return_status => l_return_status,
										   x_msg_count     => l_msg_count,
										   x_msg_data      => l_msg_data);
		  if(l_return_status <> 'S')
	      then
	        RAISE FND_API.G_EXC_ERROR ;
	      end if;

	      if(nvl(l_show_gnr, 'N') = 'Y')
          then
             x_show_gnr := 'Y';
          end if;

--   Bug 4726672 : Modified code to call delete_address_usages with all usage records to
--      be deleted as a table instead of calling it individually.
--      Called delete_address_usages with p_address_usage_dtl_tbl = null
--      when all usages are to be deleted.

         elsif p_geo_tbl(i).tax_geo_valid = 'N' then
	  l := l +1;
	  if c_get_dtls%found then             -- delete detail
	     del_usg := true;
               --   l_address_usage_dtls_tbl.delete;
	    l_address_usage_dtls_del_tbl(k).geography_type      :=  p_geo_tbl(i).geography_type;
	    l_address_usage_dtls_del_tbl(k).created_by_module   := 'HZ_GEO_HIERARCHY';
	    l_address_usage_dtls_del_tbl(k).application_id      :=  222;
	    k := k + 1;

	    if i <> l then
	       del_all_usg := false;
	    end if;

	   end if;
	  end if;
	  close c_get_dtls;
       END LOOP;

       if del_usg = true and (del_all_usg = false or l <> p_geo_tbl.last)
       then
	  hz_address_usages_pub.delete_address_usages(p_usage_id  => l_geo_usage_id,
	                                             p_address_usage_dtls_tbl => l_address_usage_dtls_del_tbl,
	                                             p_init_msg_list       => FND_API.G_FALSE,
	                                             x_return_status => l_return_status,
	                                             x_msg_count     => l_msg_count,
	                                             x_msg_data      => l_msg_data);
          if(nvl(l_show_gnr, 'N') = 'Y')
          then
            x_show_gnr := 'Y';
          end if;

       elsif del_usg = true and (del_all_usg = true and (l = p_geo_tbl.last ))
       then
          l_address_usage_dtls_del_tbl.delete;
	  hz_address_usages_pub.delete_address_usages(p_usage_id  => l_geo_usage_id,
	                                             p_address_usage_dtls_tbl => l_address_usage_dtls_del_tbl,
	                                             p_init_msg_list       => FND_API.G_FALSE,
	                                             x_return_status => l_return_status,
                                                     x_msg_count     => l_msg_count,
                                                     x_msg_data      => l_msg_data);
          if(nvl(l_show_gnr, 'N') = 'Y')
          then
            x_show_gnr := 'Y';
          end if;
       end if;
       if(l_return_status <> 'S')
       then
           RAISE FND_API.G_EXC_ERROR ;
       end if;
   end if; -- end of p_tax_tbl.count > 0 check
END IF; -- END OF CHECK FOR p_usage_tbl.COUNT > 0


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END update_map_usages;

FUNCTION get_geo_ref(p_geography_id IN NUMBER,
                     p_loc_table_name IN VARCHAR2)
RETURN VARCHAR2
IS

cursor geo_cur(l_geography_id IN number)
    is
 select country_code
   from hz_geographies
  where geography_id = l_geography_id
    and geography_type =  'COUNTRY';

l_country_code varchar2(30);

cursor hz_cur(ll_country_code in varchar2)
    is
select 'Y'
  from hz_geo_name_reference_log geo
 where exists ( select 'Y'
                from   hz_locations loc
				where  loc.country = ll_country_code
				AND    geo.location_id = loc.location_id)
and   location_table_name = 'HZ_LOCATIONS'
and rownum = 1; --bug 6870808

cursor hr_cur(ll_country_code in varchar2)
    is
select 'Y'
  from hz_geo_name_reference_log geo
 where exists ( select 'Y'
                from   hr_locations_all loc
				where  loc.country = ll_country_code
				AND    geo.location_id = loc.location_id)
and   location_table_name = 'HR_LOCATIONS_ALL'
and rownum = 1; --bug 6870808

l_return VARCHAR2(10);
l_value   varchar(1);
BEGIN
l_value := 'N';
l_return := 'N';
-- get country code from hz_geographies
open geo_cur(p_geography_id);
fetch geo_cur into l_country_code;
close geo_cur;
if( l_country_code is not null)
then
   -- check if gnr data exists
   if(p_loc_table_name = 'HZ_LOCATIONS')
   then
      open hz_cur(l_country_code);
      fetch hz_cur into l_value;
      close hz_cur;
   else
      open hr_cur(l_country_code);
      fetch hr_cur into l_value;
      close hr_cur;
   end if;

   if ( nvl(l_value, 'N') = 'Y')
   then
      l_return := 'Y';
   else
      l_return := 'N';
   end if;

end if; -- end of country code null check
return l_return;


END get_geo_ref;

FUNCTION get_country_name(p_geography_id IN NUMBER)
RETURN VARCHAR2
IS
l_return varchar2(2000);

cursor get_ctry(l_geog_id varchar2)
    is
select g2.geography_name
 from  hz_geographies g1,
       hz_geographies g2
where g1.geography_id = l_geog_id
  and g2.geography_id = g1.geography_element1_id
  and g2.geography_type = 'COUNTRY';

BEGIN

 open get_ctry(p_geography_id);
 fetch get_ctry into l_return;
 close get_ctry;

 return l_return;
END get_country_name;

END HZ_GEO_UI_UTIL_PUB;

/
