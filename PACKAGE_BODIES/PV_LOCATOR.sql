--------------------------------------------------------
--  DDL for Package Body PV_LOCATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_LOCATOR" AS
/* $Header: pvxvlcrb.pls 120.5 2006/06/06 20:53:13 dhii ship $ */



FUNCTION ADDRESS_TO_GEOCODEXML (        name     VARCHAR2,
                                        street   VARCHAR2,
                                        city     VARCHAR2,
                                        state    VARCHAR2,
                                        zip_code VARCHAR2)
RETURN VARCHAR2;
PROCEDURE Debug(
   p_msg_string       IN VARCHAR2
) ;
PROCEDURE Set_Error_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2 := NULL ,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
);
---------------------------------------------------------------------
-- PROCEDURE
--    get locator partners
--
-- PURPOSE
--    Based on the sql query, this API queries and get partners information in to
--    adddress record  and find all partners with in the distance range form the
--    customer adress  limited by the max number of partner returned .
--    This API is used from the wrapper API for locator and opportunity matching
--
-- PARAMETERS
--    p_party_address_rec: the record to hold customer address.
--    p_partner_tbl: returns the list of partners sorted based on the distance
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
PROCEDURE Get_Locator_Partners(
   p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2  := FND_API.g_false
  ,p_commit                 IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level       IN  NUMBER    := FND_API.g_valid_level_full
  ,p_customer_address1      IN  HZ_LOCATIONS.ADDRESS1%TYPE
  ,p_customer_address2      IN  HZ_LOCATIONS.ADDRESS2%TYPE
  ,p_customer_address3      IN  HZ_LOCATIONS.ADDRESS3%TYPE
  ,p_customer_city          IN  HZ_LOCATIONS.CITY%TYPE
  ,p_customer_state         IN  HZ_LOCATIONS.STATE%TYPE
  ,p_customer_country       IN  HZ_LOCATIONS.COUNTRY%TYPE
  ,p_customer_postalcode    IN  HZ_LOCATIONS.POSTAL_CODE%TYPE
  ,p_customer_lattitude     IN  VARCHAR2
  ,p_customer_longitude     IN  VARCHAR2
  ,p_max_no_partners        IN  NUMBER
  ,p_distance               IN  NUMBER
  ,p_distance_unit          IN  VARCHAR2
  ,p_sql_query              IN  VARCHAR2
  ,p_attr_id_tbl            IN  OUT NOCOPY  JTF_NUMBER_TABLE
  ,p_attr_value_tbl         IN  OUT NOCOPY  JTF_VARCHAR2_TABLE_4000
  ,p_attr_operator_tbl      IN  OUT NOCOPY  JTF_VARCHAR2_TABLE_100
  ,p_attr_data_type_tbl     IN  OUT NOCOPY  JTF_VARCHAR2_TABLE_100
  ,x_partner_tbl            OUT NOCOPY JTF_NUMBER_TABLE
  ,x_distance_tbl           OUT NOCOPY JTF_NUMBER_TABLE
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
)

IS

   l_api_version        CONSTANT NUMBER       := 1.0;
   l_api_name           CONSTANT VARCHAR2(30) := 'Get_Locator_Partners';
   l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_msg_data           VARCHAR2(10000):='';
   l_msg_count          NUMBER:=0;
   type l_partner_rec_type IS RECORD
   (
   DISTANCE             NUMBER,
   PARTY_RELATION_ID    NUMBER,
   PARTY_NAME           HZ_PARTIES.PARTY_NAME%TYPE,
   ADDRESS_LINE1        HZ_LOCATIONS.ADDRESS1%TYPE,
   ADDRESS_LINE2        HZ_LOCATIONS.ADDRESS2%TYPE,
   ADDRESS_LINE3        HZ_LOCATIONS.ADDRESS3%TYPE,
   CITY                 HZ_LOCATIONS.CITY%TYPE,
   STATE                HZ_LOCATIONS.STATE%TYPE,
   COUNTRY              HZ_LOCATIONS.COUNTRY%TYPE,
   POSTAL_CODE          HZ_LOCATIONS.POSTAL_CODE%TYPE,
   PARTNER_URL          HZ_PARTIES.URL%TYPE,
   PHONE_COUNTRY_CODE   HZ_CONTACT_POINTS.PHONE_COUNTRY_CODE%TYPE,
   PHONE_AREA_CODE      HZ_CONTACT_POINTS.PHONE_AREA_CODE%TYPE,
   PHONE_NUMBER         HZ_CONTACT_POINTS.PHONE_NUMBER%TYPE,
   row_number           NUMBER
   );

   l_partner_rec                       l_partner_rec_type;
   type cur_type                       IS        REF CURSOR;
   --l_parties_cursor                  cur_type;
   l_partner_tbl                       party_address_rec_tbl;
   l_counter                           NUMBER :=0;
   l_return_partner_tbl                party_address_rec_tbl;
   l_customer_rec                      party_address_rec_type;
   l_customer_geocode_object           HZ_LOCATIONS.GEOMETRY%TYPE;
   l_query                             VARCHAR2(4000);
   l_string                            VARCHAR2(4000);
   l_skip_server                       VARCHAR2(4000);
   x_matched_id                        JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();


   cursor l_parties_cursor(l_geo HZ_LOCATIONS.GEOMETRY%TYPE
                           ,l_dist_unit VARCHAR2
                           ,x_matched_id JTF_NUMBER_TABLE
                           ,p_distance  NUMBER
                           ,p_customer_city VARCHAR2) is
   select * from
   (
   select /*+ cardinality( tmp 10 ) */  pv_locator.geocode_distance (l_geo, hzl.geometry, l_dist_unit) dis,
   tmp.party_id, org.party_name, hzl.address1, hzl.address2, hzl.address3,
   hzl.city, hzl.state, hzl.country, hzl.postal_code,
   org.url, cp.phone_country_code, cp.phone_area_code, cp.phone_number, rownum rn
   from
   (
   select p.party_id from
       (SELECT column_value party_id FROM TABLE (CAST( x_matched_id AS JTF_NUMBER_TABLE)) ) p
   ) tmp,
   hz_parties org,
   hz_party_sites hzs,
   hz_locations hzl,
   hz_contact_points cp,
   pv_partner_profiles pvpp
   where tmp.party_id = pvpp.partner_id
   and org.party_id = pvpp.partner_party_id
   and org.party_type = 'ORGANIZATION'
   and org.party_id = cp.owner_table_id (+)
   and cp.owner_table_name (+) = 'HZ_PARTIES'
   and cp.contact_point_type (+) = 'PHONE'
   and cp.primary_flag (+) = 'Y'
   and org.party_id = hzs.party_id
   and hzs.location_id = hzl.location_id
   and hzs.identifying_address_flag = 'Y'
   -- and UPPER(hzl.CITY) = UPPER(p_customer_city)
   and hzl.geometry is not null
   )
   where dis <= p_distance order by 1 asc;


BEGIN


   -- ------------------------------------------------------------------------
   -- Retrieve profile value for stack trace profile option.
   -- ------------------------------------------------------------------------

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
    IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN

           Debug(
                p_msg_string => 'In ' || l_api_name
           );
   END IF;

   -- Storing customer information in customer address record
   l_customer_rec.ADDRESS_LINE1 := p_customer_address1;
   l_customer_rec.ADDRESS_LINE2 := p_customer_address2;
   l_customer_rec.ADDRESS_LINE3 := p_customer_address3;
   l_customer_rec.CITY          := p_customer_city;
   l_customer_rec.STATE         := p_customer_state;
   l_customer_rec.COUNTRY       := p_customer_country;
   l_customer_rec.POSTAL_CODE   := p_customer_postalcode;

   l_msg_data:=l_msg_data || 'Lattitude ' || p_customer_lattitude || 'longitude '
                          || p_customer_longitude || p_customer_state ;

   if(p_customer_lattitude is null or  p_customer_longitude is null) then
   -- creating geocode object for customer
      l_customer_geocode_object := address_to_geometry(null,
          lower(l_customer_rec.ADDRESS_LINE1 || ' ' ||l_customer_rec.ADDRESS_LINE2 || ' ' ||l_customer_rec.ADDRESS_LINE3),
          l_customer_rec.CITY, lower(l_customer_rec.STATE), l_customer_rec.POSTAL_CODE);
   else
      l_customer_geocode_object := MDSYS.SDO_GEOMETRY(g_geometry_param1,
                                                        g_geometry_param2,
                                                        MDSYS.SDO_POINT_TYPE(p_customer_longitude,
                                                                               p_customer_lattitude,
                                                                               NULL),
                                                        NULL,
                                                        NULL);
   end if;

   if(l_customer_geocode_object IS NULL) then

      --raise_application_error(-20502, 'In ' || l_api_name || ' customer address geocode object  is null');

      Set_Error_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_LOCATOR_CUST_ADDR_INVALID',
                  p_token1       => null,
                  p_token1_value => null,
                  p_token2       => null,
                  p_token2_value => null);

      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --x_partner_tbl := p_partner_tbl;


   -- Call to form_where_clause to get partners by attributes
   -- filters.

   PV_MATCH_V2_PUB.Form_Where_Clause(
          p_api_version_number   => p_api_version
          ,p_init_msg_list       => p_init_msg_list
          ,p_commit              => p_commit
          ,p_validation_level    => p_validation_level
          ,p_attr_id_tbl         => p_attr_id_tbl
          ,p_attr_value_tbl      => p_attr_value_tbl
          ,p_attr_operator_tbl   => p_attr_operator_tbl
          ,p_attr_data_type_tbl  => p_attr_data_type_tbl
          ,p_attr_selection_mode => 'AND'
          ,p_att_delmter         => '+++'
          ,p_selection_criteria  => 'ALL'
          ,p_resource_id         => NULL
          ,p_lead_id             => NULL
          ,p_auto_match_flag     => 'N'
          ,x_matched_id          => x_matched_id
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
          );


   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
        Debug( p_msg_string => 'Success String from FormWhere ' || x_return_status);
        Debug( p_msg_string => 'msg_data String from FormWhere ' || x_msg_data);
   END IF;


--   FOR i in 1..ceil((length(p_sql_query)/100)) LOOP
--      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
--          debug(substr(p_sql_query, (i-1)*100+1, 100));
--      END IF;
--      l_msg_data:=l_msg_data || substr(p_sql_query, (i-1)*100+1, 100);
--   END LOOP;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
       debug('# Partners from form_where_clause:::' || x_matched_id.COUNT );
   END IF;

   l_msg_data:=l_msg_data || '# Partners from form_where_clause:::' || x_matched_id.COUNT ;

   IF ( x_matched_id.COUNT <> 0 ) THEN

        IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                Debug(p_msg_string => 'Before opening cursor...');
        END IF;

       OPEN l_parties_cursor(l_customer_geocode_object
                             ,p_distance_unit
                             ,x_matched_id
                             ,p_distance
                             ,p_customer_city);

        IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                --Debug(p_msg_string => 'Values sent to cursor...'||l_customer_geocode_object );
                Debug(p_msg_string => 'Values sent to cursor...'||p_distance_unit );
                FOR ccc in 1..x_matched_id.COUNT LOOP
                    Debug(p_msg_string => 'Values sent to cursor...'||x_matched_id(ccc) );
                END LOOP;
                Debug(p_msg_string => 'Values sent to cursor...'||p_distance );
                Debug(p_msg_string => 'Values sent to cursor...'||p_customer_city );

        END IF;


        LOOP
            IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                Debug(p_msg_string => 'Inside Loop...');
            END IF;

            FETCH l_parties_cursor into l_partner_rec;
            EXIT WHEN l_parties_cursor%NOTFOUND;
            l_counter :=l_counter+1;

            l_partner_tbl(l_counter).PARTY_RELATION_ID  := l_partner_rec.party_relation_id;
            l_partner_tbl(l_counter).PARTY_NAME         := l_partner_rec.party_name;
            l_partner_tbl(l_counter).ADDRESS_LINE1      := l_partner_rec.address_line1;
            l_partner_tbl(l_counter).ADDRESS_LINE2      := l_partner_rec.address_line2;
            l_partner_tbl(l_counter).ADDRESS_LINE3      := l_partner_rec.address_line3;
            l_partner_tbl(l_counter).CITY               := l_partner_rec.city;
            l_partner_tbl(l_counter).STATE              := l_partner_rec.state;
            l_partner_tbl(l_counter).COUNTRY            := l_partner_rec.country;
            l_partner_tbl(l_counter).POSTAL_CODE        := l_partner_rec.postal_code;
            l_partner_tbl(l_counter).distance           := l_partner_rec.distance;

            IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                Debug(p_msg_string => ':::Distance values:::'||l_partner_rec.DISTANCE);
            END IF;

        END LOOP;

        CLOSE l_parties_cursor;

   END IF;  -- END IF FOR x_matched_id_COUNT being non zero

   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                Debug(
                p_msg_string => 'Total No. Of Partners before sending to e_location: ' || l_partner_tbl.count
        );
   END IF;

   l_msg_data:=l_msg_data || 'Total No. Of Partners before sending to e_location: ' || l_partner_tbl.count;

   l_skip_server := fnd_profile.value('PV_LOCATOR_DO_SKIP_SERVER');

   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
        Debug(p_msg_string => 'Do we SKIP E-Location???: ' || l_skip_server);
   END IF;


   IF(l_partner_tbl.count <>0) THEN
       IF l_skip_server = 'Y' THEN
           l_return_partner_tbl := l_partner_tbl;
       ELSE
           Get_Partners_From_ELocation(
                                    p_api_version       =>p_api_version
                                    ,p_init_msg_list    =>p_init_msg_list
                                    ,p_commit           =>p_commit
                                    ,p_validation_level =>p_validation_level
                                    ,p_customer_address =>l_customer_rec
                                    ,p_partner_tbl      =>l_partner_tbl
                                    ,p_max_no_partners  =>p_max_no_partners
                                    ,p_distance         =>p_distance
                                    ,p_distance_unit    =>p_distance_unit
                                    ,x_partner_tbl      =>l_return_partner_tbl
                                    ,x_return_status    =>x_return_status
                                    ,x_msg_count        =>x_msg_count
                                    ,x_msg_data         =>x_msg_data
                                    );
        END IF;
   ELSE
      l_return_partner_tbl := l_partner_tbl;
   END IF;

   x_partner_tbl := JTF_NUMBER_TABLE();
   x_distance_tbl := JTF_NUMBER_TABLE();

   FOR i in 1 .. l_return_partner_tbl.count LOOP
      x_partner_tbl.extend;
      x_distance_tbl.extend;

      x_partner_tbl(i)  :=  l_return_partner_tbl(i).party_relation_id;
      x_distance_tbl(i) :=  l_return_partner_tbl(i).distance;
   END LOOP;

   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
        Debug(p_msg_string => 'Total No. Of Partners  after getting response form e_location: ' || x_partner_tbl.count);
   END IF;

   l_msg_data:=l_msg_data ||'Total No. Of Partners after getting response form e_location: ' || x_partner_tbl.count;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   x_msg_data:=l_msg_data;


   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

         x_return_status := FND_API.G_RET_STS_ERROR ;
         fnd_msg_pub.Count_And_Get
            (
                        p_encoded   =>  FND_API.G_TRUE,
                        p_count     =>  x_msg_count,
                        p_data      =>  x_msg_data
            );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         fnd_msg_pub.Count_And_Get
            (
                        p_encoded   =>  FND_API.G_TRUE,
                        p_count     =>  x_msg_count,
                        p_data      =>  x_msg_data
            );

      WHEN OTHERS THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
         fnd_msg_pub.Count_And_Get
            (
                        p_encoded   =>  FND_API.G_TRUE,
                        p_count     =>  x_msg_count,
                        p_data      =>  x_msg_data
            );
END Get_Locator_Partners;

---------------------------------------------------------------------
-- PROCEDURE
--    get_partners
--
-- PURPOSE
--    Based on the starting address, the API finds the all the partners
--    limited by the max number of partner returned within the distance provided
--    This API is used from the wrapper API for locator and opportunity matching
--
-- PARAMETERS
--    p_party_address_rec: the record to hold customer address.
--    p_partner_tbl: returns the list of partners sorted based on the distance
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
PROCEDURE Get_Partners(
   p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2  := FND_API.g_false
  ,p_commit                 IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level       IN  NUMBER    := FND_API.g_valid_level_full

  ,p_customer_address       IN  party_address_rec_type
  ,p_partner_tbl            IN  JTF_NUMBER_TABLE
  ,p_max_no_partners        IN  NUMBER
  ,p_distance               IN  NUMBER
  ,p_distance_unit          IN  VARCHAR2
  ,p_sort_by_distance       IN  VARCHAR2 := 'T'
  ,x_partner_tbl            OUT NOCOPY  JTF_NUMBER_TABLE
  ,x_distance_tbl           OUT NOCOPY  JTF_NUMBER_TABLE
  ,x_distance_unit          OUT NOCOPY VARCHAR2
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Get_Partners';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_distance_unit    VARCHAR2(30);
   type l_partner_rec_type IS RECORD
   (
   DISTANCE             NUMBER,
   --rownumber            NUMBER,
   PARTY_RELATION_ID    NUMBER,
   PARTY_NAME           HZ_PARTIES.PARTY_NAME%TYPE,
   ADDRESS_LINE1        HZ_LOCATIONS.ADDRESS1%TYPE,
   ADDRESS_LINE2        HZ_LOCATIONS.ADDRESS2%TYPE,
   ADDRESS_LINE3        HZ_LOCATIONS.ADDRESS3%TYPE,
   CITY                 HZ_LOCATIONS.CITY%TYPE,
   STATE                HZ_LOCATIONS.STATE%TYPE,
   COUNTRY              HZ_LOCATIONS.COUNTRY%TYPE,
   POSTAL_CODE          HZ_LOCATIONS.POSTAL_CODE%TYPE,
   row_number           NUMBER
   );


   l_ADDRESS_LINE1      HZ_LOCATIONS.ADDRESS1%TYPE;
   l_ADDRESS_LINE2      HZ_LOCATIONS.ADDRESS2%TYPE;
   l_ADDRESS_LINE3      HZ_LOCATIONS.ADDRESS3%TYPE;
   l_CITY                       HZ_LOCATIONS.CITY%TYPE;
   l_STATE                      HZ_LOCATIONS.STATE%TYPE;
   l_COUNTRY            HZ_LOCATIONS.COUNTRY%TYPE;
   l_POSTAL_CODE                HZ_LOCATIONS.POSTAL_CODE%TYPE;

   l_partner_rec                        l_partner_rec_type;
   type cur_type                        IS        REF CURSOR;
   l_parties_cursor                     cur_type;
   l_partner_tbl                        party_address_rec_tbl;
   l_counter                            NUMBER :=0;
   --l_return_partner_tbl                       party_address_rec_tbl;
   l_return_final_partner_tbl           party_address_rec_tbl;
   l_customer_rec                       party_address_rec_type;
   l_customer_geocode_object            HZ_LOCATIONS.GEOMETRY%TYPE;
   --l_partner_id_string                  VARCHAR2(2000):='';
   l_query                              VARCHAR2(4000);
   l_string                             VARCHAR2(4000);
   l_max_no_partners                    NUMBER;
   l_distance                           NUMBER;
   l_partner_count                      NUMBER;

   CURSOR  lc_geometry (pc_location_id number) IS
        select  hzl.geometry,hzl.address1,hzl.address2,hzl.address3,hzl.city,hzl.state,hzl.country,hzl.postal_code
        from  hz_locations hzl
        where hzl.location_id =pc_location_id;

  l_count NUMBER;
     l_skip_server              CONSTANT VARCHAR(1)     :=nvl(fnd_profile.value('PV_SKIP_ELOCATION_FOR_MATCHING'), 'N');

        my_message VARCHAR2(2000);

BEGIN



   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
          Debug(
                p_msg_string => '........................................................... '
           );
   END IF;
   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
          Debug(
                p_msg_string => 'START OF PV_LOCATOR.GET_PARTNERS() '
           );
   END IF;


   -- Debug Message
   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                Debug(
                p_msg_string => 'In ' || l_api_name
                );
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --x_partner_tbl := p_partner_tbl;

   --Check for distance unit
   if(p_distance_unit is null) then

        --l_distance_unit:= fnd_profile.value('PV_LOCATOR_DEFAULT_DISTANCE_UOM');
        l_distance_unit:= fnd_profile.value('PV_LOCATOR_DISTANCE_UNIT');

        if(l_distance_unit = 'MILES') then
                l_distance_unit:= g_distance_unit_mile;
        elsif(l_distance_unit = 'KILOMETERS') then
                l_distance_unit:= g_distance_unit_km;
        else
                l_distance_unit:= g_distance_unit_mile;
        end if;

   else
        l_distance_unit:=p_distance_unit;
   end if;

   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			Debug(
				p_msg_string => 'Distance unit::::' || l_distance_unit

		);
      END IF;

   -- getting geocode object for customer
   if(p_customer_address.LOCATION_ID is not null) then
     -- dbms_output.put_line('Location id is not null');
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		Debug(
				p_msg_string => 'Location Id::::' || p_customer_address.LOCATION_ID

		);
      END IF;

      OPEN lc_geometry (pc_location_id => p_customer_address.LOCATION_ID);
         FETCH lc_geometry INTO  l_customer_geocode_object, l_ADDRESS_LINE1,l_ADDRESS_LINE2,l_ADDRESS_LINE3,l_city,l_state,l_country,l_postal_code;
      CLOSE lc_geometry;

   end if;





   if(p_partner_tbl IS NULL) then
      --raise_application_error(-20506,  ' partner id table received  is null' ||  '    in ' || l_api_name );
      Set_Error_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_LOCATOR_NO_PARTNERS',
                  p_token1       => null,
                  p_token1_value => null,
                  p_token2       => null,
                  p_token2_value => null);

      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;


    if ( p_distance is null and p_max_no_partners is null and
       (l_customer_geocode_object IS  NULL or (l_customer_geocode_object IS NOT NULL and l_customer_geocode_object.sdo_point.x IS NULL))
       ) then
   --if this condition satisfies, return all partners as it is.
   --else contact Location server and return...



	 x_distance_unit     :=l_distance_unit;
	   x_partner_tbl := JTF_NUMBER_TABLE();
	   x_distance_tbl := JTF_NUMBER_TABLE();
	   FOR i in 1 .. p_partner_tbl.count LOOP
	      x_partner_tbl.extend;
	      x_distance_tbl.extend;
	      x_partner_tbl(i):=p_partner_tbl(i);
	      --x_distance_tbl(i) := l_return_final_partner_tbl(i).distance;
	       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		       Debug(
			p_msg_string => 'id: ' || x_partner_tbl(i) || ' Distance: ' || x_distance_tbl(i)
		       );
		END IF;
	   END LOOP;


	 Debug(
	p_msg_string => ' Returning all partners back as it is'
	);

   else
	   if(p_customer_address.LOCATION_ID is null or l_customer_geocode_object is null) then
		l_customer_geocode_object := address_to_geometry(null, lower(p_customer_address.ADDRESS_LINE1 || ' ' ||p_customer_address.ADDRESS_LINE2 || ' ' ||p_customer_address.ADDRESS_LINE3),
                                                 p_customer_address.CITY, lower(p_customer_address.STATE), p_customer_address.POSTAL_CODE);
	   end if;


	   if(l_customer_geocode_object IS NULL) then

	      --raise_application_error(-20504,  ' customer geocode object  is null' ||  '     in ' || l_api_name );
	      Set_Error_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
			  p_msg_name     => 'PV_LOCATOR_CUST_ADDR_INVALID',
			  p_token1       => null,
			  p_token1_value => null,
			  p_token2       => null,
			  p_token2_value => null);

	      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	   end if;

	   if(l_customer_geocode_object IS NOT NULL and l_customer_geocode_object.sdo_point.x IS NULL) then

	      --raise_application_error(-20505,  'The customer does not have a valid address'  );
	      Set_Error_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
			  p_msg_name     => 'PV_LOCATOR_CUST_ADDR_INVALID',
			  p_token1       => null,
			  p_token1_value => null,
			  p_token2       => null,
			  p_token2_value => null);

	      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	   end if;


	   --Forming a string of all partner ids to use it in query
	   /* --------------------------------------------------------------------------------
	   FOR partner_index IN 1..p_partner_tbl.count LOOP
	      l_partner_id_string:=l_partner_id_string || ',' || p_partner_tbl(partner_index);
	   end loop;
	   l_partner_id_string := substr(l_partner_id_string,2);
            * -------------------------------------------------------------------------------- */

	   l_customer_rec.ADDRESS_LINE1 := l_ADDRESS_LINE1;
	   l_customer_rec.ADDRESS_LINE2 := l_ADDRESS_LINE2;
	   l_customer_rec.ADDRESS_LINE3 := l_ADDRESS_LINE3;
	   l_customer_rec.CITY          := l_city;
	   l_customer_rec.STATE         := l_state;
	   l_customer_rec.COUNTRY       := l_country;
	   l_customer_rec.POSTAL_CODE   := l_postal_code;

Debug(p_msg_string => 'p_partner_tbl.COUNT: ' || p_partner_tbl.count);


      -- ---------------------------------------------------------------------
      -- The "leading" hint is to make sure that the optimizer will make
      -- c (CAST PLSQL table) as the driving table as it is most likely the
      -- smallest "table" in the join.  This, in most cases, speeds up the
      -- performance dramatically.
      -- ---------------------------------------------------------------------
	   l_query:=
	   'select * from ( ' ||
	      ' select  /*+ leading(c) */ pv_locator.geocode_distance(:1,hzl.geometry,:2)  dis, ' ||
		  ' pvpp.partner_id party_id, ' ||
		  ' org.party_name, '||
		  ' hzl.address1, '||
	      ' hzl.address2, '||
		  ' hzl.address3, '||
		  ' hzl.city, '||
		  ' hzl.state, '||
		  ' hzl.country, '||
		  ' hzl.postal_code, '||
		  ' rownum rn '||
	      ' from hz_parties org, ' ||
		  ' hz_party_sites hzs, ' ||
		  ' hz_locations hzl, '||
		  ' pv_partner_profiles pvpp, '||
		  ' (SELECT * ' ||
                  ' FROM (SELECT column_value party_id ' ||
                  '  FROM  (SELECT column_value ' ||
                  '         FROM TABLE (CAST(:p_partner_tbl AS JTF_NUMBER_TABLE))))) c ' ||
	      ' where pvpp.partner_id = c.party_id ' ||
		  ' and org.party_id (+) = pvpp.partner_party_id  '||
	      ' and org.party_type (+) = '||''''||'ORGANIZATION'||''''||
		  ' and org.party_id = hzs.party_id (+) '||
		  ' and hzs.location_id = hzl.location_id  (+) and '||
	      ' hzs.identifying_address_flag (+) = '||''''||'Y'||'''' ;


	   --Here we are changing the query because, when p_distance and p_max_no_partners are both null, then it should resturn al;l partners
	   -- irrespective of geometry object

	   if (p_distance is null and p_max_no_partners is null) then
		l_distance:=0;
		l_query:=l_query || ') where (dis is null or dis >=:3) ';
	   elsif(p_distance is null ) then
		l_distance:=0;
		l_query:=l_query || ' and hzl.geometry is not null) where dis>=:3 ';
	   else
		l_distance:=p_distance;
		l_query:=l_query || ' and hzl.geometry is not null) where dis<=:3 ';
	   end if;

	   --adding order by column
	   if (UPPER(p_sort_by_distance) = 'T') then
		l_query:=l_query || ' order by 1 asc';
	   else
		l_query:=l_query || ' order by 2 ';
	   end if;


	   /*
	   if(p_distance is not null) THEN
	      l_distance:=p_distance;
	      l_query:=l_query || ' where dis<=:3 order by 1 asc';
	   else
	      l_distance:=0;
	      l_query:=l_query || ' where dis>=:3 order by 1 asc';
	   end if;
	 */

	   -- THE QUERY IS
	   -- --------------------------------------------------------------------------------
	   -- The second SELECT statement actually starts with /*+ leading(c) */
	   -- --------------------------------------------------------------------------------
	   /*
           SELECT *
           FROM  (SELECT pv_locator.geocode_distance(:1,hzl.geometry,:2)  dis,
                         pvpp.partner_id party_id,  org.party_name,  hzl.address1,
                         hzl.address2,  hzl.address3,  hzl.city, hzl.state,  hzl.country,
                         hzl.postal_code,  rownum rn
                  FROM   hz_parties org,
                         hz_party_sites hzs,
                         hz_locations hzl,
                         pv_partner_profiles pvpp,
                        (SELECT *
                         FROM   (SELECT column_value party_id
                                 FROM  (SELECT column_value
                                        FROM   TABLE(CAST(:p_partner_tbl AS JTF_NUMBER_TABLE))))) c
                  WHERE  pvpp.partner_id = c.party_id and
                         org.party_id (+) = pvpp.partner_party_id and
                         org.party_type (+) = 'ORGANIZATION' and
                         org.party_id = hzs.party_id (+) and
                         hzs.location_id = hzl.location_id (+) and
                         hzs.identifying_address_flag (+) = 'Y' and
                         hzl.geometry is not null)
           WHERE  dis<=:3
           ORDER  BY 1 ASC;
	   */

	   l_string := l_query;
	   loop
	      exit when l_string is null;
		  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			Debug(
			p_msg_string => substr( l_string, 1, 200 )
			);
		  END IF;
	      l_string := substr( l_string, 201 );
	   end loop;


	   OPEN l_parties_cursor FOR  l_query
	   USING  l_customer_geocode_object, l_distance_unit, p_partner_tbl, l_distance;

	      LOOP

		 FETCH l_parties_cursor into l_partner_rec;
		 EXIT WHEN l_parties_cursor%NOTFOUND;
		 l_counter :=l_counter+1;

		 l_partner_tbl(l_counter).PARTY_RELATION_ID     := l_partner_rec.party_relation_id;
		 l_partner_tbl(l_counter).PARTY_NAME            := l_partner_rec.party_name;
		 l_partner_tbl(l_counter).ADDRESS_LINE1         := l_partner_rec.address_line1;
		 l_partner_tbl(l_counter).ADDRESS_LINE2         := l_partner_rec.address_line2;
		 l_partner_tbl(l_counter).ADDRESS_LINE3         := l_partner_rec.address_line3;
		 l_partner_tbl(l_counter).CITY                  := l_partner_rec.city;
		 l_partner_tbl(l_counter).STATE                 := l_partner_rec.state;
		 l_partner_tbl(l_counter).COUNTRY               := l_partner_rec.country;
		 l_partner_tbl(l_counter).POSTAL_CODE           := l_partner_rec.postal_code;
		 l_partner_tbl(l_counter).distance              := l_partner_rec.distance;


	      END LOOP;

	   CLOSE l_parties_cursor;


	  --dbms_output.put_line('no of partners before sending eLocation' || l_partner_tbl.count || ' distance' || p_distance || 'unit' || l_distance_unit || 'no' || p_max_no_partners);
	   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			Debug(
			p_msg_string => 'Total No. Of Partners before sending to e_location: ' || l_partner_tbl.count
			);
	   END IF;

	   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			Debug(
			p_msg_string => 'Skipping e_location server?? ' || l_skip_server
			);
	   END IF;

	   -- if skip server profile value is set to true, we need to skip the server and return results
	   -- based on the radial distances.
	   if(upper(l_skip_server) = 'Y') then

		  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			Debug(
			p_msg_string => 'Returning partners with out calling Get_Partners_From_ELocation'
			);
		  END IF;

	      if( p_max_no_partners is null) then
		 l_partner_count := l_partner_tbl.count;

	      elsif(p_max_no_partners > l_partner_tbl.count)  then
		 l_partner_count := l_partner_tbl.count;
	      else
		 l_partner_count :=p_max_no_partners;
	      end if;

	      FOR i in 1 .. l_partner_count LOOP
		 l_return_final_partner_tbl(i):=l_partner_tbl(i);
	      END LOOP;


	   elsif(l_partner_tbl.count <>0) then
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			Debug(
			p_msg_string => 'Before calling Get_Partners_From_ELocation'
			);
		  END IF;

		  Get_Partners_From_ELocation(
					p_api_version           =>p_api_version
					,p_init_msg_list        =>p_init_msg_list
					,p_commit               =>p_commit
					,p_validation_level     =>p_validation_level

					,p_customer_address     =>l_customer_rec
					,p_partner_tbl          =>l_partner_tbl
					,p_max_no_partners      =>p_max_no_partners
					,p_distance             =>p_distance
					,p_distance_unit        =>l_distance_unit
					,p_sort_by_distance     =>p_sort_by_distance
					,x_partner_tbl          =>l_return_final_partner_tbl
					,x_return_status        =>x_return_status
					,x_msg_count            =>x_msg_count
					,x_msg_data             =>x_msg_data
				      );


	   else
	      l_return_final_partner_tbl := l_partner_tbl;
	   end if;
	   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		   Debug(
			p_msg_string => 'Total No. Of Partnersafter getting from e_location: ' || l_return_final_partner_tbl.count
		   );
	   END IF;
	   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		   Debug(
			p_msg_string => 'Partners List after getting from eLocation...
			::::'
		   );
	   END IF;

	   x_distance_unit     :=l_distance_unit;
	   x_partner_tbl := JTF_NUMBER_TABLE();
	   x_distance_tbl := JTF_NUMBER_TABLE();
	   FOR i in 1 .. l_return_final_partner_tbl.count LOOP
	      x_partner_tbl.extend;
	      x_distance_tbl.extend;
	      x_partner_tbl(i):=l_return_final_partner_tbl(i).party_relation_id;
	      x_distance_tbl(i) := l_return_final_partner_tbl(i).distance;
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			Debug(
				p_msg_string => 'id: ' || x_partner_tbl(i) || ' Distance: ' || x_distance_tbl(i)
			);
		  END IF;

	   END LOOP;
   end if;



--dbms_output.put_line('no of patners returned' ||  l_return_final_partner_tbl.count);
   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
           Debug(
                p_msg_string => 'END OF PV_LOCATOR.GET_PARTNERS() '
           );
   END IF;
   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
           Debug(
                p_msg_string => '........................................................... '
           );
   END IF;


   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

         x_return_status := FND_API.G_RET_STS_ERROR ;
         fnd_msg_pub.Count_And_Get
            (
                        p_encoded   =>  FND_API.G_TRUE,
                        p_count     =>  x_msg_count,
                        p_data      =>  x_msg_data
            );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         fnd_msg_pub.Count_And_Get
            (
                        p_encoded   =>  FND_API.G_TRUE,
                        p_count     =>  x_msg_count,
                        p_data      =>  x_msg_data
            );

      WHEN OTHERS THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          --Debug(SQLCODE || ':::' || SQLERRM);
         fnd_msg_pub.Count_And_Get
            (
                        p_encoded   =>  FND_API.G_TRUE,
                        p_count     =>  x_msg_count,
                        p_data      =>  x_msg_data
            );
END Get_Partners;

---------------------------------------------------------------------
-- PROCEDURE
--    get_partners
--
-- PURPOSE
--    Based on the starting address, the API finds the all the partners
--    limited by the max number of partner returned within the distance provided
--    This API is used from the wrapper API for locator and opportunity matching
--
-- PARAMETERS
--    p_party_address_rec: the record to hold customer address.
--    p_partner_tbl: returns the list of partners sorted based on the distance
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
PROCEDURE Get_Partners_From_ELocation(
   p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2  := FND_API.g_false
  ,p_commit                 IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level       IN  NUMBER    := FND_API.g_valid_level_full
  ,p_customer_address       IN  party_address_rec_type
  ,p_partner_tbl            IN  party_address_rec_tbl
  ,p_max_no_partners        IN  NUMBER
  ,p_distance               IN  NUMBER
  ,p_distance_unit          IN  VARCHAR2
  ,p_sort_by_distance       IN  VARCHAR2 := 'T'
  ,x_partner_tbl            OUT NOCOPY  party_address_rec_tbl
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS

   l_api_version        CONSTANT NUMBER       := 1.0;
   l_api_name           CONSTANT VARCHAR2(30) := 'Get_Partners_From_ELocation';
   l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_partner_tbl            party_address_rec_tbl;

  /*
   geocoder_host        VARCHAR2(128) := 'virao-pc.us.oracle.com:8888';
   geocoder_path        VARCHAR2(128) := '/servlet/routem';
   */

   xml_request          VARCHAR2(32000);
   cust_xml             VARCHAR2(32000) := '';
   partner_xml          VARCHAR2(32000) := '';
   xml_response         VARCHAR2(32000);
   url                  VARCHAR2(4000);
   l_string             VARCHAR2(32000);
   l_first_quote_loc    NUMBER;
   l_second_quote_loc   NUMBER;
   l_distance_loc       NUMBER;
   l_partyid_loc        NUMBER;
   l_distance           NUMBER;
   l_party_id           NUMBER;
   l_party_id_str       VARCHAR(100);
   l_distance_str       VARCHAR(100);
   l_count              NUMBER :=1;
   l_max_no_partners    NUMBER :=0;
   l_partner_count      NUMBER :=0;
   l_loop_count         NUMBEr :=0;
   l_content_type       VARCHAR2(100);
   l_msg_data           VARCHAR2(10000):='';
   l_sort_by_distance  VARCHAR2(100);
   l_route_id_loc       NUMBER;
   l_error_id_loc       NUMBER;

BEGIN


   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Debug Message
   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
        Debug(
                p_msg_string =>  'In ' || l_api_name
        );
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  --checking sort_by_distance
  if(UPPER(p_sort_by_distance)='T') then
        l_sort_by_distance := 'true';
  else
        l_sort_by_distance := 'false';
  end if;
  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
        Debug(
                p_msg_string =>  'Sort By Distance::::::::::::: ' || l_sort_by_distance
        );
   END IF;

--dbms_output.put_line('in elocation call');
    -- construct customer XML part
   cust_xml:=cust_xml || '<start_location> ' ;
   cust_xml:=cust_xml || '<input_location id="1"> ' ;
   cust_xml:=cust_xml || '<input_address> ' ;
   cust_xml:=cust_xml || '<us_form1 street="' || p_customer_address.ADDRESS_LINE1 || ' ' ||
                                                p_customer_address.ADDRESS_LINE2 || ' ' || p_customer_address.ADDRESS_LINE3 ||
                                                '" lastline="' || p_customer_address.CITY || ', ' || p_customer_address.STATE ||
                                                ' ' || p_customer_address.POSTAL_CODE || '" /> ' ;
   cust_xml:=cust_xml || '</input_address> ' ;
   cust_xml:=cust_xml || '</input_location> ' ;
   cust_xml:=cust_xml || '</start_location> ';


   if(p_partner_tbl IS NULL) then
      --raise_application_error(-20508, 'In ' || l_api_name || ' partner address table is null');
      Set_Error_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_LOCATOR_PARTNERS_NONE',
                  p_token1       => null,
                  p_token1_value => null,
                  p_token2       => null,
                  p_token2_value => null);

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;
   -- max_no-of_partners can not be more than no of entries in the table.
   --even if it is, it wont retrieve those many . so, making max as table count.
   if (p_max_no_partners is null) then
      l_max_no_partners := p_partner_tbl.count;
   elsif (p_max_no_partners >= p_partner_tbl.count) then
      l_max_no_partners := p_partner_tbl.count;
   else
      l_max_no_partners := p_max_no_partners;
   end if;




   --  what this loop does is
   -- It is sending requests for max_no_of_partners at a time.
   -- and gets response from elocation. If it gets max_no_of_partners back , It is going to stop
   -- It sends another set of partners until it gets max no of partners.
   l_msg_data:= l_msg_data || 'The distance' || p_distance || 'unit '||  p_distance_unit || 'max no '|| p_max_no_partners;

  --dbms_output.put_line('in elocation call' || 'The distance' || p_distance || 'unit '||  p_distance_unit || 'max no '|| p_max_no_partners);
   Loop   --main loop exits when you get max no of partners or when you end up sending all partners in partner table
      exit when l_partner_count >= l_max_no_partners or l_loop_count >= p_partner_tbl.count;
      -- construct partners XML part


      l_msg_data:= l_msg_data || 'in main loop ' || ' l_partner_count: ' || l_partner_count ||
                                ' l_max_no_partners: ' || l_max_no_partners  ||
                                ' l_loop_count'|| l_loop_count || ' p_partner_tbl.count: ' ||p_partner_tbl.count;

      partner_xml:='';
      FOR i  IN 1..l_max_no_partners LOOP

         exit when l_loop_count >= p_partner_tbl.count;
         --l_msg_data:= l_msg_data || 'id' || p_partner_tbl(1+l_loop_count).PARTY_RELATION_ID || p_partner_tbl(1+l_loop_count).ADDRESS_LINE1 ||
         --p_partner_tbl(1+l_loop_count).CITY || p_partner_tbl(1+l_loop_count).STATE || p_partner_tbl(1+l_loop_count).POSTAL_CODE || 'gap' ;

         partner_xml:=partner_xml || '<end_location> ';
         partner_xml:=partner_xml || '<input_location id="' || p_partner_tbl(1+l_loop_count).PARTY_RELATION_ID || '"> ' ;
         partner_xml:=partner_xml || '<input_address> ' ;
         partner_xml:=partner_xml || '<us_form1 street="' || p_partner_tbl(1+l_loop_count).ADDRESS_LINE1 || ' ' ||
                                                        p_partner_tbl(1+l_loop_count).ADDRESS_LINE2 || ' ' || p_partner_tbl(1+l_loop_count).ADDRESS_LINE3 ||
                                                        '" lastline="' || p_partner_tbl(1+l_loop_count).CITY || ', ' || p_partner_tbl(1+l_loop_count).STATE ||
                                                        ' ' || p_partner_tbl(1+l_loop_count).POSTAL_CODE || '" /> ' ;
         partner_xml:=partner_xml || '</input_address> ' ;
         partner_xml:=partner_xml || '</input_location> ' ;
         partner_xml:=partner_xml || '</end_location> '  ;

         l_loop_count :=l_loop_count+1;
                --l_msg_data:= l_msg_data ||  partner_xml;
      END LOOP;

      -- construct XML request
      xml_request :=    '<?xml version="1.0" standalone="yes"?> '                       ||
                        ' <batch_route_request id="8" route_preference="fastest" '              ||
                        ' road_preference="highway" return_driving_directions="false" '  ||
                        ' sort_by_distance="' || l_sort_by_distance || '" cutoff_distance="'|| p_distance ||'" ' ||
                        ' distance_unit="'||p_distance_unit||'" time_unit="second"> '                   ||
                        cust_xml                                                        ||
                        partner_xml                                                     ||
                        ' </batch_route_request>';

      --dbms_output.put_line('in elocation call after xml request');
     IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
       Debug(
                p_msg_string => 'XML REQUEST: **************'
       );
          END IF;
     --dbms_output.put_line('XML REQUEST: **************');
      --dbms_output.put_line('in elocation call in loop');
      --printing xml_request
      l_string := xml_request;
      loop
         exit when l_string is null;
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                Debug(
                        p_msg_string => substr( l_string, 1, 200 )
        );
         END IF;
         l_string := substr( l_string, 201 );
      end loop;
      --l_msg_data:= l_msg_data || 'Request is '|| xml_request;
     -- dbms_output.put_line('Sending Request..');
      hz_http_pkg.post(
                doc                     => 'xml_request=' || xml_request,
                content_type            => g_input_content_type,
                url                     => g_route_url,
                resp                    => xml_response,
                resp_content_type       => l_content_type,
                proxyserver             => g_proxy_server,
                proxyport               => g_proxy_port,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
      );

     -- dbms_output.put_line('got the response..');
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                Debug(
                        p_msg_string => 'XML RESPONSE: **************'
                );
          END IF;
      --dbms_output.put_line('XML RESPONSE: **************');
      --printing xml_response
      l_string := xml_response;
      loop
          exit when l_string is null;
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                Debug(
                        p_msg_string => substr( l_string, 1, 200 )
        );
          END IF;
          l_string := substr( l_string, 201 );
      end loop;
      -- l_msg_data:= l_msg_data || 'Response is '|| xml_response || 'got response';


 --what if xml_response is null
   if (xml_response is null) then
        --raise_application_error(-20516, 'In ' || l_api_name || ' Server is not available. Sever may be down right now. Try after some time.');
        Set_Error_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_LOCATOR_SERVICE_UNAVAILABLE',
                  p_token1       => null,
                  p_token1_value => null,
                  p_token2       => null,
                  p_token2_value => null);

      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;


      loop --parsing loop

                --if xml_response is an exception, this will throw an exception so that we can
                --display message like   temporarily unavailable to user
         IF( INSTR(xml_response,'500 Internal Server Error',1, 1) <> 0 or
             INSTR(xml_response,'400 Bad Request',1, 1) <> 0 or
             INSTR(xml_response,'NegativeArraySizeException',1, 1) <> 0 or
             INSTR(xml_response,'Fatal error in file',1, 1) <> 0 or
             INSTR(xml_response,'component_error',1, 1) <> 0 or
             INSTR(xml_response,'generic_error',1, 1) <> 0 or
             INSTR(xml_response,' Error parsing',1, 1) <> 0 )   THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            --raise_application_error(-20509, ' eLocation Server is not available' || 'in ' || l_api_name );
            Set_Error_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_LOCATOR_SERVICE_UNAVAILABLE',
                  p_token1       => null,
                  p_token1_value => null,
                  p_token2       => null,
                  p_token2_value => null);

             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            -- dbms_output.put_line('Error occured in parsing..');
           -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         --exit when xml_response is null or no id string in xml_response;
         --EXIT when INSTR(xml_response, 'route id', 1, 1) =0 ;


         -----------------------------------------------check for both here

         l_route_id_loc := INSTR(xml_response, 'route id', 1, 1);
         l_error_id_loc := INSTR(xml_response, 'router_error id', 1, 1);


         --if 'route id' string and erro_id string does not exist in xml_response , then exit
         --if route_id exists and error_id does not exist, then go to route_partner loop
         --if route_id does not exist and error_id  exists, then go to error_partner loop
         -- if both exists and route_id_loc is greater than erro_id_loc, go to errored partner loop
         -- if both exists and route_id_loc is less than erro_id_loc, go to route partner loop


         if(l_route_id_loc =0 and l_error_id_loc =0) then
                exit;
         elsif(
                 (
                   (l_route_id_loc > 0  and l_error_id_loc > 0) and  ( l_route_id_loc >= l_error_id_loc )
                 )
                 or
                   (l_route_id_loc =0 and  l_error_id_loc>0)
               )
         then

                EXIT when INSTR(xml_response, 'router_error id', 1, 1) =0 ;

                --First find location for id and then find location for " if id exists.
                l_partyid_loc := INSTR(xml_response, 'router_error id', 1, 1);
                IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                        Debug(  p_msg_string => 'partner with invalid geocode (Geometry)' || l_partyid_loc );
                END IF;
                IF l_partyid_loc = 0 THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                        --raise_application_error(-20510,' eLocation Server is not available' || 'in ' || l_api_name);
                        Set_Error_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                p_msg_name     => 'PV_LOCATOR_SERVICE_UNAVAILABLE',
                                p_token1       => null,
                                p_token1_value => null,
                                p_token2       => null,
                                p_token2_value => null);

                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                l_first_quote_loc := INSTR(xml_response, '"', l_partyid_loc, 1);
                l_second_quote_loc := INSTR(xml_response, '"', l_partyid_loc, 2);
                --this line will fetch id value that is between " and "
                l_party_id_str := SUBSTR(
                                        xml_response,
                                        l_first_quote_loc + 1,
                                        (l_second_quote_loc - 1)-(l_first_quote_loc + 1) + 1);

                l_party_id:=to_number(l_party_id_str);

                --at this point, check l_party_id
                                --if l_party_id is 1, that means error comes at geocoding customer address which is start address.
                                -- then eLocation server, will not return any party ids with distances.
                                --So we need to handle this seperately in manual matching case where p_distance is null and p_max_no_partners is null
                IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                        Debug(  p_msg_string => 'partner with invalid geocode (Geometry):party_id:' || l_party_id );
                END IF;
                --if p_distance is null and p_max_no_partners is null, then only we have to return partners with null distance
                -- so checking here
                if (p_distance is null and p_max_no_partners is null) then
                        --add partner_id to partner table and null to distance table
                        if (l_partner_count >= l_max_no_partners) then

                                IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                                        Debug(
                                                p_msg_string => 'max_no_of_partners reached ...exiting..' ||l_api_name
                                        );
                                END IF;
                                exit;
                    --at this point, check l_party_id
                                --if l_party_id is 1, that means error comes at geocoding customer address which is start address.
                                -- then eLocation server, will not return any party ids with distances.
                                --So we need to handle this seperately in manual matching case where p_distance is null and p_max_no_partners is null

                        elsif (l_party_id=1) then
                                IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                                        Debug(  p_msg_string => 'Customer address (start address) is not geocodable, Change customer address and try again'   );
                                END IF;


                                FOR i  IN 1..l_max_no_partners LOOP
                                        l_partner_tbl(l_count).PARTY_RELATION_ID:=p_partner_tbl(i).PARTY_RELATION_ID;
                                        l_partner_tbl(l_count).DISTANCE:=null;
                                        l_partner_count := l_partner_count +1;
                                        l_count := l_count+1;

                                END LOOP;


                                exit;

                        else



                                l_partner_tbl(l_count).PARTY_RELATION_ID:=l_party_id;
                                l_partner_tbl(l_count).DISTANCE:=null;
                                l_partner_count := l_partner_count +1;
                                l_count := l_count+1;
                        end if;

                end if; --end of if (p_distance is null and p_max_no_partners is null) then
                l_first_quote_loc := INSTR(xml_response, 'error_msg', l_partyid_loc, 1);
                xml_response:=substr( xml_response, l_first_quote_loc );


         elsif(
                 (
                   (l_route_id_loc > 0  and l_error_id_loc > 0) and  ( l_route_id_loc < l_error_id_loc )
                 )
                 or
                   (l_route_id_loc >0 and  l_error_id_loc=0)
               )
         then


                --First find location for id and then find location for " if id exists.
                l_partyid_loc := INSTR(xml_response, 'route id', 1, 1);

                IF l_partyid_loc = 0 THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                        --raise_application_error(-20510,' eLocation Server is not available' || 'in ' || l_api_name);
                        Set_Error_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                p_msg_name     => 'PV_LOCATOR_SERVICE_UNAVAILABLE',
                                p_token1       => null,
                                p_token1_value => null,
                                p_token2       => null,
                                p_token2_value => null);

                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                l_first_quote_loc := INSTR(xml_response, '"', l_partyid_loc, 1);
                l_second_quote_loc := INSTR(xml_response, '"', l_partyid_loc, 2);
                --this line will fetch id value that is between " and "
                l_party_id_str := SUBSTR(
                                xml_response,
                                l_first_quote_loc + 1,
                                (l_second_quote_loc - 1)-(l_first_quote_loc + 1) + 1);

                l_party_id:=to_number(l_party_id_str);
                --similarly do for distance
                l_distance_loc := INSTR(xml_response, 'distance', 1, 1);

                IF l_distance_loc = 0 THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                        --raise_application_error(-20511,  ' eLocation Server is not available' || 'in ' || l_api_name );
                        Set_Error_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                p_msg_name     => 'PV_LOCATOR_SERVICE_UNAVAILABLE',
                                p_token1       => null,
                                p_token1_value => null,
                                p_token2       => null,
                                p_token2_value => null);

                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                        --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                l_first_quote_loc := INSTR(xml_response, '"', l_distance_loc, 1);
                l_second_quote_loc := INSTR(xml_response, '"', l_distance_loc, 2);

                l_distance_str := SUBSTR(
                                xml_response,
                                l_first_quote_loc + 1,
                                (l_second_quote_loc - 1)-(l_first_quote_loc + 1) + 1);

                l_msg_data:= l_msg_data || 'The DISTANCE ' ||  l_distance_str || ' ';

                l_distance:=to_number(l_distance_str,'99999999999999999999.99999999999999999999');
                --if(l_distance <= p_distance) then


                if (l_partner_count >= l_max_no_partners) then


                        IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
                                Debug(
                                        p_msg_string => 'max_no_of_partners reached ...exiting..' ||l_api_name
                                );
                        END IF;
                        exit;

                else


                        l_partner_tbl(l_count).PARTY_RELATION_ID:=l_party_id;
                        l_partner_tbl(l_count).DISTANCE:=l_distance;
                        l_partner_count := l_partner_count +1;
                        l_count := l_count+1;
                end if;
               --end if;
                l_first_quote_loc := INSTR(xml_response, 'time_unit', l_distance_loc, 1);
                xml_response:=substr( xml_response, l_first_quote_loc );
        end if; -- end of else if(INSTR(xml_response, 'route id', 1, 1) =0 )...


      end loop; -- end of parsing loop
   end loop; --end of mian loop


   l_msg_data:= l_msg_data || 'size of l_partner Table is ' || l_partner_tbl.count;
   x_partner_tbl:=l_partner_tbl;
   -- dbms_output.put_line('size of l_partner Table is ' || l_partner_tbl.count);

   --************************************************
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
   --x_msg_data:= l_msg_data;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

         x_return_status := FND_API.G_RET_STS_ERROR ;
         fnd_msg_pub.Count_And_Get
            (
                        p_encoded   =>  FND_API.G_TRUE,
                        p_count     =>  x_msg_count,
                        p_data      =>  x_msg_data
            );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         fnd_msg_pub.Count_And_Get
            (
                        p_encoded   =>  FND_API.G_TRUE,
                        p_count     =>  x_msg_count,
                        p_data      =>  x_msg_data
            );

      WHEN OTHERS THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
         fnd_msg_pub.Count_And_Get
            (
                        p_encoded   =>  FND_API.G_TRUE,
                        p_count     =>  x_msg_count,
                        p_data      =>  x_msg_data
            );
END Get_Partners_From_ELocation;

---------------------------------------------------------------------
-- FUNCTION
--    address_to_geometry
--
-- PURPOSE
--    Based on the  address,city,state,zipcode, This function finnds geocode object for that address
--
-- PARAMETERS
--    name,street,city,satte,zip_code
--    returns geocode object
--
-- NOTES
--
---------------------------------------------------------------------


FUNCTION address_to_geometry(   name     VARCHAR2,
                                street   VARCHAR2,
                                city     VARCHAR2,
                                state    VARCHAR2,
                                zip_code VARCHAR2)
RETURN MDSYS.SDO_GEOMETRY
AS
    latitude_loc      NUMBER;
    latitude_str      VARCHAR2(200);
    latitude          NUMBER;
    longitude_loc     NUMBER;
    longitude_str     VARCHAR2(200);
    longitude         NUMBER;
    xml_response      VARCHAR2(4000);
    first_quote_loc   NUMBER;
    second_quote_loc  NUMBER;
    my_message        VARCHAR2(4000);
BEGIN
    -- Get xml geocode response string
    xml_response := address_to_geocodexml(
                                          name,
                                          street,
                                          city,
                                          state,
                                          zip_code);

    -- Extract latitude
    latitude_loc := INSTR(xml_response, 'latitude', 1, 1);
    IF latitude_loc = 0 THEN
       --raise_application_error(-20512, 'latitude is missing');
       Set_Error_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_LOCATOR_CUST_ADDR_INVALID',
                  p_token1       => null,
                  p_token1_value => null,
                  p_token2       => null,
                  p_token2_value => null);

      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    first_quote_loc := INSTR(xml_response, '"', latitude_loc, 1);
    second_quote_loc := INSTR(xml_response, '"', latitude_loc, 2);
    latitude_str := SUBSTR(
                xml_response,
                first_quote_loc + 1,
                                (second_quote_loc - 1)-(first_quote_loc + 1) + 1);
    latitude:= to_number(latitude_str,'99999999999999999999.99999999999999999999');
    /*SELECT latitude_str
    INTO latitude
    FROM DUAL;
    */
    -- Extract longitude
    longitude_loc := INSTR(xml_response, 'longitude', 1, 1);
    IF longitude_loc = 0 THEN
        --raise_application_error(-20513, 'longitude is missing');
        Set_Error_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'PV_LOCATOR_CUST_ADDR_INVALID',
                  p_token1       => null,
                  p_token1_value => null,
                  p_token2       => null,
                  p_token2_value => null);

      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    first_quote_loc := INSTR(xml_response, '"', longitude_loc, 1);
    second_quote_loc := INSTR(xml_response, '"', longitude_loc, 2);
    longitude_str := SUBSTR(
                xml_response,
                first_quote_loc + 1,
                                (second_quote_loc - 1)-(first_quote_loc + 1) + 1);
    longitude:= to_number(longitude_str,'99999999999999999999.99999999999999999999');
    /*SELECT longitude_str
    INTO longitude
    FROM DUAL;
    */
    RETURN MDSYS.SDO_GEOMETRY(2001,
                              8307,
                                                          MDSYS.SDO_POINT_TYPE(longitude,
                                                                                                   latitude,
                                                   NULL),
                                                          NULL,
                                                          NULL);
END address_to_geometry;

---------------------------------------------------------------------
-- FUNCTION
--    ADDRESS_TO_GEOCODEXML
--
-- PURPOSE
--    Based on the  address,city,state,zipcode, This function construct an xml_string
--makes a request to eLocation servlet and gets xml response that contains lattitude and longitude values in it
--
-- PARAMETERS
--    name,street,city,satte,zip_code
--    returns xml_string as varchar2
--
-- NOTES
--
---------------------------------------------------------------------


FUNCTION ADDRESS_TO_GEOCODEXML (        name     VARCHAR2,
                                        street   VARCHAR2,
                                        city     VARCHAR2,
                                        state    VARCHAR2,
                                        zip_code VARCHAR2)
RETURN VARCHAR2
AS
  /*  geocoder_host     VARCHAR2(128) := 'elocation.us.oracle.com';
    geocoder_path       VARCHAR2(128) := '/servlets/lbs';
    */

    us_form2            VARCHAR2(4000);
    xml_request         VARCHAR2(4000);
    xml_response        VARCHAR2(4000);
    url                 VARCHAR2(4000);
    content_type        VARCHAR2(100);
    x_return_status     VARCHAR2(1);
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(4000);

BEGIN
    -- construct us_form2
   us_form2 := '<us_form2 ';
    IF NOT (name IS NULL) THEN
        us_form2 := us_form2 || 'name="' || name || '" ';
    END IF;
    IF NOT (street IS NULL) THEN
        us_form2 := us_form2 || 'street="' || street || '" ';
    END IF;
    IF NOT (city IS NULL) THEN
        us_form2 := us_form2 || 'city="' || city || '" ';
    END IF;
    IF NOT (state IS NULL) THEN
        us_form2 := us_form2 || 'state="' || state || '" ';
    END IF;
    IF NOT (zip_code IS NULL) THEN
        us_form2 := us_form2 || 'zip_code="' || zip_code || '" ';
    END IF;
    us_form2 := us_form2 || '/>';


    -- construct XML request
    xml_request := '<?xml version="1.0" standalone="yes" ?>' ||
                   '<geocode_request vendor="elocation">'    ||
                   '    <address_list>'                      ||
                   '        <input_location id="1">'         ||
                   '            <input_address match_mode='  ||
                   '              "relax_street_type">'      ||
                   us_form2 ||
                   '            </input_address>'            ||
                   '        </input_location>'               ||
                   '    </address_list>'                     ||
                   '</geocode_request>';
    --dbms_output.put_line('Here is the xml_request: ');
    --dbms_output.put_line(xml_request);
    -- replace characters in xml_request with escapes

   hz_http_pkg.post(
                doc                     => 'xml_request=' || xml_request,
                content_type            => g_input_content_type,
                url                     => g_geocode_url,
                resp                    => xml_response,
                resp_content_type       => content_type,
                proxyserver             => g_proxy_server,
                proxyport               => g_proxy_port,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data

        );



   return xml_response;


END ADDRESS_TO_GEOCODEXML;

 --------------------------------------------------------------------------------
  --  CONSTANTS  thar are being used in this function . getting these values from profiles
  --------------------------------------------------------------------------------
 /* PI       number := 3.1415926535897932;
  TWOPI    number := 2.0*PI;
  TORAD    number := PI/180.0;
  EARTHRAD number := 6371007.000;*/ /* WGS-84 authalic radius in meters*/
  --------------------------------------------------------------------------------
  --
  -- This routine computes the distance between two point geometries
  -- using an authalic spherical approximation to the earth ellipsoid.
  --             mdsys.sdo_geometry         geom1,  The first  geometry
  --             mdsys.sdo_geometry         geom2,  The second geometry
  -- Both geometries should be point geometries with geodetic longitude/latitude
  -- coordinates in degrees. Result is returned in meters.
  --------------------------------------------------------------------------------
  FUNCTION geocode_distance (geom1      MDSYS.SDO_GEOMETRY,
                          geom2      MDSYS.SDO_GEOMETRY,
                          distance_unit VARCHAR2)
  RETURN NUMBER IS

  l_ct number;
  l_st number;
  l_cp number;
  l_sp number;
  l_p1x number;
  l_p1y number;
  l_p1z number;
  l_p2x number;
  l_p2y number;
  l_p2z number;
  l_dist number;
  l_PI       number :=3.1415926535897932;-- to_number(g_pi_value); --value is 3.1415926535897932
  --l_TWOPI    number := 2.0*l_PI;
  l_TORAD    number := l_PI/180.0; --to_number(g_torad_degree); --grad degree is 180.0
  l_EARTHRAD number := 6371007.000; --to_number(g_earth_radious); -- earch radious is 6371007.000; /* WGS-84 authalic radius in meters*/

  begin



   if(geom1.sdo_point.y=geom2.sdo_point.y and geom1.sdo_point.x=geom2.sdo_point.x) then
        l_dist :=0;
   else
      l_ct := COS(geom1.sdo_point.y*l_TORAD);
      l_st := SIN(geom1.sdo_point.y*l_TORAD);
      l_cp := COS(geom1.sdo_point.x*l_TORAD);
      l_sp := SIN(geom1.sdo_point.x*l_TORAD);
      l_p1x := l_ct*l_cp;
      l_p1y := l_ct*l_sp;
      l_p1z := l_st;

      l_ct := COS(geom2.sdo_point.y*l_TORAD);
      l_st := SIN(geom2.sdo_point.y*l_TORAD);
      l_cp := COS(geom2.sdo_point.x*l_TORAD);
      l_sp := SIN(geom2.sdo_point.x*l_TORAD);
      l_p2x := l_ct*l_cp;
      l_p2y := l_ct*l_sp;
      l_p2z := l_st;

      l_dist := l_EARTHRAD*ACOS(l_p1x*l_p2x + l_p1y*l_p2y + l_p1z*l_p2z);
   end if;
    -- We got distance in meter. Now we need to convert based on teh distance unit
   if(distance_unit=g_distance_unit_mile) then
      l_dist:= l_dist*g_miles_per_meter;
   elsif(distance_unit=g_distance_unit_km) then
      l_dist:= l_dist/g_meters_per_km;
   elsif(distance_unit=g_distance_unit_meter) then
      l_dist:= l_dist;
   else
      l_dist:= l_dist*g_miles_per_meter;
   end if;

   return l_dist;
END geocode_distance;

--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Debug                                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Debug(
   p_msg_string       IN VARCHAR2
)
IS

BEGIN

   IF
       FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT', p_msg_string);
      FND_MSG_PUB.Add;
   END IF;
END Debug;
-- =================================End of Debug================================



--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Set_Error_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Set_Error_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2 := NULL ,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level) THEN
        FND_MESSAGE.Set_Name('PV', p_msg_name);

        IF (p_token1 IS NOT NULL) THEN
            FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        END IF;

        IF (p_token2 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        END IF;

        IF (p_token3 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token3, p_token3_value);
        END IF;

        FND_MSG_PUB.Add;
    END IF;
END Set_Error_Message;
-- ==============================End of Set_Error_Message==============================

End PV_LOCATOR;


/
