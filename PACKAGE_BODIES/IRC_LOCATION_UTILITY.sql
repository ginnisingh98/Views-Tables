--------------------------------------------------------
--  DDL for Package Body IRC_LOCATION_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_LOCATION_UTILITY" as
/* $Header: irlocutl.pkb 120.5.12010000.2 2008/08/05 10:49:59 ubhat ship $ */
--Package Variables
--
g_package varchar2(33) := 'irc_location_utility.';
g_conversion number;
--
--
-- Function to remove invalid characters (these cause error when the request
-- is processed by Geocode)
-- -------------------------------------------------------------------------
-- |-------------------------< removeInvalidChars >------------------------|
-- -------------------------------------------------------------------------
function removeInvalidChars(p_address_line varchar2) return varchar2
is
l_address_line varchar2 (240);
begin
  l_address_line := replace(p_address_line,'&',' ');
  return l_address_line;
end;
--
-- -------------------------------------------------------------------------
-- |-------------------------< address2geocodexml >------------------------|
-- -------------------------------------------------------------------------
--
function address2geocodexml
(name     VARCHAR2
,street   VARCHAR2
,city     VARCHAR2
,state    VARCHAR2
,zip_code VARCHAR2)
return VARCHAR2
AS
 geocoder_host VARCHAR2(255);
 us_form2      VARCHAR2(32767);
 xml_request   VARCHAR2(32767);
 url           VARCHAR2(32767);
 return_string VARCHAR2(32767);
 return_string_array utl_http.html_pieces;
 max_pieces binary_integer:=16;
l_proc         varchar2(72) := g_package||'address2geocodexml';
BEGIN
  hr_utility.set_location(' Entering: ' || l_proc, 10);
    -- construct us_form2
    us_form2 := '<us_form2 ';
    IF name IS not NULL THEN
        us_form2 := us_form2 || 'name="' || removeInvalidChars(name) || '" ';
    END IF;
    IF street IS not null THEN
        us_form2 := us_form2 || 'street="' || removeInvalidChars(street) || '" ';
    END IF;
    IF city IS not null THEN
        us_form2 := us_form2 || 'city="' || removeInvalidChars(city) || '" ';
    END IF;
    IF state IS not null THEN
        us_form2 := us_form2 || 'state="' || removeInvalidChars(state) || '" ';
    END IF;
    IF zip_code IS not null THEN
        us_form2 := us_form2 || 'zip_code="' || removeInvalidChars(zip_code) || '" ';
    END IF;
    us_form2 := us_form2 || '/>';
    hr_utility.set_location(l_proc, 20);
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

    -- replace characters in xml_request with escapes
    xml_request := replace(xml_request, '"', '%22');
    xml_request := replace(xml_request, '#', '%23');
    xml_request := replace(xml_request, '''','%27');
    xml_request := replace(xml_request, ' ', '%20');
    xml_request := replace(xml_request, '<', '%3C');
    xml_request := replace(xml_request, '>', '%3E');
    xml_request := replace(xml_request, ';', '%3B');
    xml_request := replace(xml_request, '/', '%2F');
    xml_request := replace(xml_request, '?', '%3F');
    xml_request := replace(xml_request, ':', '%3A');
    xml_request := replace(xml_request, '@', '%40');
    xml_request := replace(xml_request, '&', '%26');
    xml_request := replace(xml_request, '=', '%3D');
    xml_request := replace(xml_request, '+', '%2B');
    xml_request := replace(xml_request, '$', '%24');
    xml_request := replace(xml_request, ',', '%2C');
    hr_utility.set_location(l_proc, 30);

    -- construct URL
    geocoder_host:=fnd_profile.value('IRC_GEOCODE_HOST');


   url :=  geocoder_host   ||
          '?xml_request=' ||
           xml_request;

   return_string_array:= irc_xml_util.http_get_pieces(
                                      url => url,
                                      max_pieces => max_pieces);
   return_string:=null;
   for j in return_string_array.first..return_string_array.last loop
     return_string:=return_string||return_string_array(j);
   end loop;
   return return_string;

   hr_utility.set_location('Leaving :'||l_proc, 40);
end address2geocodexml;
-- -------------------------------------------------------------------------
-- |-------------------------< address2geocodexml >------------------------|
-- -------------------------------------------------------------------------
--
function address2geocodexml
(name                VARCHAR2
,street              VARCHAR2
,intersecting_street VARCHAR2
,builtup_area        VARCHAR2
,order8_area         VARCHAR2
,order2_area         VARCHAR2
,order1_area         VARCHAR2
,country             VARCHAR2
,postal_code         VARCHAR2
,postal_addon_code   VARCHAR2)
return VARCHAR2
AS
 geocoder_host VARCHAR2(255);
 gdf_form      VARCHAR2(32767);
 xml_request   VARCHAR2(32767);
 url           VARCHAR2(32767);
 return_string VARCHAR2(32767);
 return_string_array utl_http.html_pieces;
 max_pieces binary_integer:=16;
l_proc         varchar2(72) := g_package||'address2geocodexml';
BEGIN
  hr_utility.set_location(' Entering: ' || l_proc, 10);
    -- construct gdf_form
    gdf_form := '<gdf_form ';
    IF name IS not NULL THEN
        gdf_form := gdf_form || 'name="' || removeInvalidChars(name) || '" ';
    END IF;
    IF street IS not null THEN
        gdf_form := gdf_form || 'street="' || removeInvalidChars(street) || '" ';
    END IF;
    IF intersecting_street IS not null THEN
        gdf_form := gdf_form || 'intersecting_street="' || removeInvalidChars(intersecting_street) || '" ';
    END IF;
    IF builtup_area IS not null THEN
        gdf_form := gdf_form || 'builtup_area="' || removeInvalidChars(builtup_area) || '" ';
    END IF;
    IF order8_area IS not null THEN
        gdf_form := gdf_form || 'order8_area="' || removeInvalidChars(order8_area) || '" ';
    END IF;
    IF order2_area IS not null THEN
        gdf_form := gdf_form || 'order2_area="' || removeInvalidChars(order2_area) || '" ';
    END IF;
    IF order1_area IS not null THEN
        gdf_form := gdf_form || 'order1_area="' || removeInvalidChars(order1_area) || '" ';
    END IF;
    IF country IS not null THEN
        gdf_form := gdf_form || 'country="' || removeInvalidChars(country) || '" ';
    END IF;
    IF postal_code IS not null THEN
        gdf_form := gdf_form || 'postal_code="' || removeInvalidChars(postal_code) || '" ';
    END IF;
    IF postal_addon_code IS not null THEN
        gdf_form := gdf_form || 'postal_addon_code="' || removeInvalidChars(postal_addon_code) || '" ';
    END IF;
    gdf_form := gdf_form || '/>';
    hr_utility.set_location(l_proc, 20);
    -- construct XML request
    xml_request := '<?xml version="1.0" standalone="yes" ?>' ||
                   '<geocode_request vendor="elocation">'    ||
                   '    <address_list>'                      ||
                   '        <input_location id="1">'         ||
                   '            <input_address match_mode='  ||
                   '              "relax_street_type">'      ||
                   gdf_form ||
                   '            </input_address>'            ||
                   '        </input_location>'               ||
                   '    </address_list>'                     ||
                   '</geocode_request>';
    -- replace characters in xml_request with escapes
    xml_request := replace(xml_request, '"', '%22');
    xml_request := replace(xml_request, '#', '%23');
    xml_request := replace(xml_request, '''','%27');
    xml_request := replace(xml_request, ' ', '%20');
    xml_request := replace(xml_request, '<', '%3C');
    xml_request := replace(xml_request, '>', '%3E');
    xml_request := replace(xml_request, ';', '%3B');
    xml_request := replace(xml_request, '/', '%2F');
    xml_request := replace(xml_request, '?', '%3F');
    xml_request := replace(xml_request, ':', '%3A');
    xml_request := replace(xml_request, '@', '%40');
    xml_request := replace(xml_request, '&', '%26');
    xml_request := replace(xml_request, '=', '%3D');
    xml_request := replace(xml_request, '+', '%2B');
    xml_request := replace(xml_request, '$', '%24');
    xml_request := replace(xml_request, ',', '%2C');
    hr_utility.set_location(l_proc, 30);

    -- construct URL
    geocoder_host:=fnd_profile.value('IRC_GEOCODE_HOST');

    url :=  geocoder_host   ||
           '?xml_request=' ||
            xml_request;

   return_string_array:= irc_xml_util.http_get_pieces(
                                      url => url,
                                      max_pieces => max_pieces);
   return_string:=null;
   for j in return_string_array.first..return_string_array.last loop
     return_string:=return_string||return_string_array(j);
   end loop;
   return return_string;

   hr_utility.set_location('Leaving :'||l_proc, 40);
end address2geocodexml;
-- -------------------------------------------------------------------------
-- |-----------------------------< address2xml >---------------------------|
-- -------------------------------------------------------------------------
--
function address2xml
(address_id          number   default null
,address_line1       varchar2 default null
,address_line2       varchar2 default null
,address_line3       varchar2 default null
,address_line4       varchar2 default null
,address_line5       varchar2 default null
,address_line6       varchar2 default null
,address_line7       varchar2 default null
,address_line8       varchar2 default null
,address_line9       varchar2 default null
,country             varchar2 default null)
return VARCHAR2
AS
 unformatted_form      VARCHAR2(32767);
 xml_request   VARCHAR2(32767);
l_proc         varchar2(72) := g_package||'address2xml';
BEGIN
  hr_utility.set_location(' Entering: ' || l_proc, 10);
    -- construct unformatted_form
    unformatted_form := '<unformatted ';
    IF country IS not NULL THEN
        unformatted_form := unformatted_form || 'country="' || removeInvalidChars(country) || '" ';
    END IF;
    unformatted_form := unformatted_form || '> ';
    unformatted_form := unformatted_form || '<address_line value="'|| removeInvalidChars(address_line1) ||'" /> ';

    IF address_line2 IS not null THEN
       unformatted_form := unformatted_form || '<address_line value="'|| removeInvalidChars(address_line2) ||'" /> ';
    END IF;
    IF address_line3 IS not null THEN
       unformatted_form := unformatted_form || '<address_line value="'|| removeInvalidChars(address_line3) ||'" /> ';
    END IF;
    IF address_line4 IS not null THEN
       unformatted_form := unformatted_form || '<address_line value="'|| removeInvalidChars(address_line4) ||'" /> ';
    END IF;
    IF address_line5 IS not null THEN
       unformatted_form := unformatted_form || '<address_line value="'|| removeInvalidChars(address_line5) ||'" /> ';
    END IF;
    IF address_line6 IS not null THEN
       unformatted_form := unformatted_form || '<address_line value="'|| removeInvalidChars(address_line6) ||'" /> ';
    END IF;
    IF address_line7 IS not null THEN
       unformatted_form := unformatted_form || '<address_line value="'|| removeInvalidChars(address_line7) ||'" /> ';
    END IF;
    IF address_line8 IS not null THEN
       unformatted_form := unformatted_form || '<address_line value="'|| removeInvalidChars(address_line8) ||'" /> ';
    END IF;
    IF address_line9 IS not null THEN
       unformatted_form := unformatted_form || '<address_line value="'|| removeInvalidChars(address_line9) ||'" /> ';
    END IF;
unformatted_form:=unformatted_form||'</unformatted>';
    unformatted_form := '<input_location id="'||nvl(address_id,1)||'"> '
                      ||'<input_address match_mode="relax_street_type">'
                      ||unformatted_form
                      ||'</input_address></input_location>';
    hr_utility.set_location(l_proc, 20);
    return unformatted_form;
end address2xml;
-- -------------------------------------------------------------------------
-- |-------------------------< address2geocodexml >------------------------|
-- -------------------------------------------------------------------------
--
function address2geocodexml
(address_line1       varchar2
,address_line2       varchar2 default null
,address_line3       varchar2 default null
,address_line4       varchar2 default null
,address_line5       varchar2 default null
,address_line6       varchar2 default null
,address_line7       varchar2 default null
,address_line8       varchar2 default null
,address_line9       varchar2 default null
,country             varchar2 default null)
return VARCHAR2
AS
 geocoder_host VARCHAR2(255);
 unformatted_form      VARCHAR2(32767);
 xml_request   VARCHAR2(32767);
 url           VARCHAR2(32767);
 return_string VARCHAR2(32767);
 return_string_array utl_http.html_pieces;
 max_pieces binary_integer:=16;
l_proc         varchar2(72) := g_package||'address2geocodexml';
BEGIN
  hr_utility.set_location(' Entering: ' || l_proc, 10);
    -- construct unformatted_form
    unformatted_form :=address2xml(address_line1       => address_line1
                    ,address_line2       => address_line2
                    ,address_line3       => address_line3
                    ,address_line4       => address_line4
                    ,address_line5       => address_line5
                    ,address_line6       => address_line6
                    ,address_line7       => address_line7
                    ,address_line8       => address_line8
                    ,address_line9       => address_line9
                    ,country             => country);

    hr_utility.set_location(l_proc, 20);
    -- construct XML request
    xml_request := '<?xml version="1.0" standalone="yes" ?>' ||
                   '<geocode_request vendor="elocation">'    ||
                   '    <address_list>'                      ||
                   unformatted_form ||
                   '    </address_list>'                     ||
                   '</geocode_request>';
    -- replace characters in xml_request with escapes
    xml_request := replace(xml_request, '"', '%22');
    xml_request := replace(xml_request, '#', '%23');
    xml_request := replace(xml_request, '''','%27');
    xml_request := replace(xml_request, ' ', '%20');
    xml_request := replace(xml_request, '<', '%3C');
    xml_request := replace(xml_request, '>', '%3E');
    xml_request := replace(xml_request, ';', '%3B');
    xml_request := replace(xml_request, '/', '%2F');
    xml_request := replace(xml_request, '?', '%3F');
    xml_request := replace(xml_request, ':', '%3A');
    xml_request := replace(xml_request, '@', '%40');
    xml_request := replace(xml_request, '&', '%26');
    xml_request := replace(xml_request, '=', '%3D');
    xml_request := replace(xml_request, '+', '%2B');
    xml_request := replace(xml_request, '$', '%24');
    xml_request := replace(xml_request, ',', '%2C');
    hr_utility.set_location(l_proc, 30);
    -- construct URL
    geocoder_host:=fnd_profile.value('IRC_GEOCODE_HOST');

    url :=  geocoder_host  ||
           '?xml_request=' ||
            xml_request;

   return_string_array:= irc_xml_util.http_get_pieces(
                                      url => url,
                                      max_pieces => max_pieces);
   return_string:=null;
   for j in return_string_array.first..return_string_array.last loop
     return_string:=return_string||return_string_array(j);
   end loop;
   return return_string;

   hr_utility.set_location('Leaving :'||l_proc, 40);
end address2geocodexml;
--
-- -------------------------------------------------------------------------
-- |---------------------------< process_return_xml >----------------------|
-- -------------------------------------------------------------------------
--
function process_return_xml
(xml_response varchar2)
return MDSYS.SDO_GEOMETRY
as
  address_doc xmldom.DOMDocument;
  match_nodes xmlDom.DOMNodeList;
  match_node  xmlDom.DOMNode;
  parser xmlparser.parser;
  l_longitude number;
  l_latitude number;
  l_proc            varchar2(72) := g_package||'process_return_xml';
begin

  hr_utility.set_location(' Entering: '||l_proc, 10);
  parser:=xmlparser.newParser;
  xmlparser.parseBuffer(parser,xml_response);
  address_doc:=xmlparser.getDocument(parser);
  xmlparser.freeParser(parser);
  hr_utility.set_location(l_proc, 20);
  match_nodes:=xslprocessor.selectNodes(xmldom.makeNode(address_doc),'/geocode_response/geocode/match');
  if xmldom.getlength(match_nodes)>0 then
  hr_utility.set_location(l_proc, 30);
    match_node     :=xmldom.item(match_nodes,0);
    xslprocessor.valueOf(match_node,'@longitude',l_longitude);
    xslprocessor.valueOf(match_node,'@latitude',l_latitude);
  end if;
  xmldom.freeDocument(address_doc);
    hr_utility.set_location(l_proc, 40);
    if (l_longitude is not null and l_latitude is not null) then
      RETURN MDSYS.SDO_GEOMETRY(2001
                               ,8307
                               ,MDSYS.SDO_POINT_TYPE
                                (l_longitude
                                ,l_latitude
                                ,NULL)
                               ,NULL
                               ,NULL);
    else
      return null;
    end if;
  exception
    when others then
    begin
      hr_utility.set_location(l_proc, 50);
      xmldom.freeDocument(address_doc);
      return null;
    exception
      when others then
        return null;
    end;

  end process_return_xml;
--
-- -------------------------------------------------------------------------
-- |---------------------------< address2geometry >------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION address2geometry
(name     varchar2 default null
,street   varchar2 default null
,city     varchar2 default null
,state    varchar2 default null
,zip_code varchar2 default null)
RETURN MDSYS.SDO_GEOMETRY
AS
    xml_response      VARCHAR2(32767);
    l_proc            varchar2(72) := g_package||'address2geometry';
BEGIN
    hr_utility.set_location('Entering :'||l_proc, 10);
    -- Get xml geocode response string
    xml_response := irc_location_utility.address2geocodexml
                    (name     => name
                    ,street   => street
                    ,city     => city
                    ,state    => state
                    ,zip_code => zip_code);
    return irc_location_utility.process_return_xml(xml_response);
end address2geometry;
--
-- -------------------------------------------------------------------------
-- |---------------------------< address2geometry >------------------------|
-- -------------------------------------------------------------------------
--
function address2geometry
(name                varchar2 default null
,street              varchar2 default null
,intersecting_street varchar2 default null
,builtup_area        varchar2 default null
,order8_area         varchar2 default null
,order2_area         varchar2 default null
,order1_area         varchar2 default null
,country             varchar2 default null
,postal_code         varchar2 default null
,postal_addon_code   varchar2 default null)
return MDSYS.SDO_GEOMETRY
AS
i number;
    xml_response      VARCHAR2(32767);
    l_proc            varchar2(72) := g_package||'address2geometry';
BEGIN
    hr_utility.set_location('Entering :'||l_proc, 10);
    -- Get xml geocode response string
    xml_response := irc_location_utility.address2geocodexml
                    (name                => name
                    ,street              => street
                    ,intersecting_street => intersecting_street
                    ,builtup_area        => builtup_area
                    ,order8_area         => order8_area
                    ,order2_area         => order2_area
                    ,order1_area         => order1_area
                    ,country             => country
                    ,postal_code => postal_code
                    ,postal_addon_code => postal_addon_code);
/*i:=0;
while (i<length(xml_response)) loop
hr_utility.set_location(substr(xml_response,i,70),20);
i:=i+70;
end loop;*/
    return irc_location_utility.process_return_xml(xml_response);
end address2geometry;
--
-- -------------------------------------------------------------------------
-- |---------------------------< address2geometry >------------------------|
-- -------------------------------------------------------------------------
--
function address2geometry
(address_line1       varchar2
,address_line2       varchar2 default null
,address_line3       varchar2 default null
,address_line4       varchar2 default null
,address_line5       varchar2 default null
,address_line6       varchar2 default null
,address_line7       varchar2 default null
,address_line8       varchar2 default null
,address_line9       varchar2 default null
,country             varchar2 default null)
return MDSYS.SDO_GEOMETRY
AS
i number;
    xml_response      VARCHAR2(32767);
    l_proc            varchar2(72) := g_package||'address2geometry';
BEGIN
    hr_utility.set_location('Entering :'||l_proc, 10);
    -- Get xml geocode response string
    xml_response := irc_location_utility.address2geocodexml
                    (address_line1       => address_line1
                    ,address_line2       => address_line2
                    ,address_line3       => address_line3
                    ,address_line4       => address_line4
                    ,address_line5       => address_line5
                    ,address_line6       => address_line6
                    ,address_line7       => address_line7
                    ,address_line8       => address_line8
                    ,address_line9       => address_line9
                    ,country             => country);
/*i:=0;
while (i<length(xml_response)) loop
hr_utility.set_location(substr(xml_response,i,70),20);
i:=i+70;
end loop;*/
    return irc_location_utility.process_return_xml(xml_response);
end address2geometry;
--
-- -------------------------------------------------------------------------
-- |-------------------------< bulk_address2geometry >---------------------|
-- -------------------------------------------------------------------------
--
procedure bulk_address2geometry(address_id    in     t_address_id
                               ,address_line1 in     t_address_line
                               ,address_line2 in     t_address_line
                               ,address_line3 in     t_address_line
                               ,address_line4 in     t_address_line
                               ,address_line5 in     t_address_line
                               ,address_line6 in     t_address_line
                               ,address_line7 in     t_address_line
                               ,address_line8 in     t_address_line
                               ,address_line9 in     t_address_line
                               ,country       in     t_address_line
                               ,latitude         out nocopy t_address_id
                               ,longitude        out nocopy t_address_id
                               ,success          out nocopy number
                               ,failure          out nocopy number) as
  --+
  xml_response   VARCHAR2(32767);
  address_string VARCHAR2(32767):='';
  address_list   VARCHAR2(32767):='';
  url            VARCHAR2(32767);
  return_string  VARCHAR2(32767);
  errorMsg       varchar2(4000);
  l_proc         varchar2(72) := g_package||'bulk_address2geometry';
  id_loc         number;
  i              number;
  k              number;
  latitude_loc   NUMBER;
  longitude_loc  NUMBER;
  l_success      number := 0;
  l_failure      number := 0;
  first_line     number;
  address_doc   xmldom.DOMDocument;
  geocode_nodes xmlDom.DOMNodeList;
  geocode_node  xmlDom.DOMNode;
  match_node    xmlDom.DOMNode;
  parser        xmlparser.parser;
  return_string_array utl_http.html_pieces;
  max_pieces binary_integer:=16;
  --+
  procedure process_addresses is
    begin
    hr_utility.set_location('Entering process_addresses :', 100);
    xml_response:= '<?xml version="1.0" standalone="yes" ?>'
                || '<geocode_request vendor="elocation">'
                || '<address_list>'
                || address_list
                || '</address_list></geocode_request>';
      -- replace characters in xml_request with escapes
      xml_response := replace(xml_response, '"', '%22');
      xml_response := replace(xml_response, '#', '%23');
      xml_response := replace(xml_response, '''','%27');
      xml_response := replace(xml_response, ' ', '%20');
      xml_response := replace(xml_response, '<', '%3C');
      xml_response := replace(xml_response, '>', '%3E');
      xml_response := replace(xml_response, ';', '%3B');
      xml_response := replace(xml_response, '/', '%2F');
      xml_response := replace(xml_response, '?', '%3F');
      xml_response := replace(xml_response, ':', '%3A');
      xml_response := replace(xml_response, '@', '%40');
      xml_response := replace(xml_response, '&', '%26');
      xml_response := replace(xml_response, '=', '%3D');
      xml_response := replace(xml_response, '+', '%2B');
      xml_response := replace(xml_response, '$', '%24');
      xml_response := replace(xml_response, ',', '%2C');
      --+ construct URL
      url := fnd_profile.value('IRC_GEOCODE_HOST')
          || '?xml_request='
          || xml_response;
      hr_utility.set_location('Length of url '||lengthb(url), 110);
      return_string_array :=
               irc_xml_util.http_get_pieces(url        => url
                                           ,max_pieces => max_pieces);
      hr_utility.set_location('recieved the response ', 120);
      return_string := null;
      for j in return_string_array.first .. return_string_array.last loop
        return_string := return_string || return_string_array(j);
      end loop;
      xmlparser.parseBuffer(parser,return_string);
      address_doc := xmlparser.getDocument(parser);
      BEGIN
      geocode_nodes := xslprocessor.selectNodes(xmldom.makeNode(address_doc),'/geocode_response/geocode');
      if xmldom.getLength(geocode_nodes) > 0 then
        for j in 1 .. xmldom.getLength(geocode_nodes) loop
          geocode_node := xmldom.item(geocode_nodes,j-1);
          hr_utility.set_location(xslprocessor.valueOf(geocode_node,'@match_count')||' for line '||j,130);
          if to_number(xslprocessor.valueOf(geocode_node,'@match_count'))>0 then
            match_node     :=xslprocessor.selectSingleNode(geocode_node,'match');
            longitude(first_line+j)    :=xslprocessor.valueOf(match_node,'@longitude');
            latitude(first_line+j)     :=xslprocessor.valueOf(match_node,'@latitude');
            if latitude(first_line+j) is not null and longitude(first_line+j) is not null then
              l_success:=l_success+1;
              hr_utility.set_location('Geometry found for address_id :'||address_id(first_line+j) ,140);
              hr_utility.set_location('Longitude :'||longitude(first_line+j) ,141);
              hr_utility.set_location('Latitude  :'||latitude(first_line+j) ,142);
            end if;
          else
            hr_utility.set_location('Geometry not found for address_id :'||address_id(first_line+j) ,150);
          end if;
        end loop;
      else
        geocode_node := xslprocessor.selectSingleNode(xmldom.makeNode(address_doc),'/component_error');
        errorMsg :=  xslprocessor.valueOf(geocode_node,'/component_error');
        hr_utility.set_location('ERROR thrown from geocode host',155);
        hr_utility.set_location(substrb(substrb(errorMsg,1,instrb(errorMsg,fnd_global.local_chr(10))-1),1,80),160);
      end if;
      xmldom.freeDocument(address_doc);
      EXCEPTION
        when OTHERS then
        xmldom.freeDocument(address_doc);
        hr_utility.set_location('Unexpected error in elocation response processing',194);
        hr_utility.set_location('Unexpected error :'||SQLERRM,195);
        hr_utility.set_location('Unexpected error :'||SQLCODE,196);
      END;
     --+
      hr_utility.set_location('Leaving process_addresses :',170);
     exception
      when others then
      --this is a bulk process, so ignore errors and move on
        hr_utility.set_location('Unexpected error in address processing',197);
        hr_utility.set_location('Unexpected error :'||SQLERRM,198);
        hr_utility.set_location('Unexpected error :'||SQLCODE,199);
    end process_addresses;
BEGIN
  hr_utility.set_location('Entering :'||l_proc, 10);
  first_line := 0;
  parser     := xmlparser.newParser;
  for i in address_id.first..address_id.last loop
    longitude(i):= null;
    latitude(i) := null;
    address_string:=address2xml
              (address_id          =>address_id(i)
               ,address_line1       =>address_line1(i)
               ,address_line2       =>address_line2(i)
               ,address_line3       =>address_line3(i)
               ,address_line4       =>address_line4(i)
               ,address_line5       =>address_line5(i)
               ,address_line6       =>address_line6(i)
               ,address_line7       =>address_line7(i)
               ,address_line8       =>address_line8(i)
               ,address_line9       =>address_line9(i)
               ,country             =>country(i));
    hr_utility.set_location('count of address_id :'||address_id.count,20);
    address_list := address_string;
    first_line := i-1;
    process_addresses();
  end loop;
  --+
  success := l_success;
  failure := address_id.count - l_success;
  xmlparser.freeParser(parser);
  --+
  hr_utility.set_location('Leaving  :'||l_proc, 45);
  exception
    when others then
      -- this is a bulk process, so ignore errors and move on
      xmlparser.freeParser(parser);
      hr_utility.set_location('Unexpected error in bulk processing',50);
      hr_utility.set_location('Unexpected error :'||SQLERRM,55);
      hr_utility.set_location('Unexpected error :'||SQLCODE,56);
end bulk_address2geometry;
--
-- -------------------------------------------------------------------------
-- |---------------------------< address2full >------------------------|
-- -------------------------------------------------------------------------
--
procedure address2full
(address_line1       in     varchar2
,address_line2       in     varchar2 default null
,address_line3       in     varchar2 default null
,address_line4       in     varchar2 default null
,address_line5       in     varchar2 default null
,address_line6       in     varchar2 default null
,address_line7       in     varchar2 default null
,address_line8       in     varchar2 default null
,address_line9       in     varchar2 default null
,country             in     varchar2 default null
,name                   out nocopy varchar2
,house_number           out nocopy varchar2
,street                 out nocopy varchar2
,builtup_area           out nocopy varchar2
,order1_area            out nocopy varchar2
,order2_area            out nocopy varchar2
,order8_area            out nocopy varchar2
,country_name           out nocopy varchar2
,postal_code            out nocopy varchar2
,geometry               out nocopy MDSYS.SDO_GEOMETRY
)
AS
  i number;
  xml_response      VARCHAR2(32767);
  l_proc            varchar2(72) := g_package||'address2full';
  address_doc xmldom.DOMDocument;
  geocode_node xmlDom.DOMNode;
  match_node  xmlDom.DOMNode;
  address_node  xmlDom.DOMNode;
  parser xmlparser.parser;
  l_longitude number;
  l_latitude number;
  l_match_count varchar2(255);
BEGIN
    hr_utility.set_location('Entering :'||l_proc, 10);
    -- Get xml geocode response string
    xml_response := irc_location_utility.address2geocodexml
                    (address_line1       => address_line1
                    ,address_line2       => address_line2
                    ,address_line3       => address_line3
                    ,address_line4       => address_line4
                    ,address_line5       => address_line5
                    ,address_line6       => address_line6
                    ,address_line7       => address_line7
                    ,address_line8       => address_line8
                    ,address_line9       => address_line9
                    ,country             => country);
/*  i:=0;
  while (i<length(xml_response)) loop
    hr_utility.set_location(substr(xml_response,i,70),20);
    i:=i+70;
  end loop;*/
  parser:=xmlparser.newParser;
  xmlparser.parseBuffer(parser,xml_response);
  address_doc:=xmlparser.getDocument(parser);
  xmlparser.freeParser(parser);
  geocode_node:=xslprocessor.selectSingleNode(xmldom.makeNode(address_doc),'/geocode_response/geocode');
  xslprocessor.valueOf(geocode_node,'@match_count',l_match_count);
  if to_number(xslprocessor.valueOf(geocode_node,'@match_count'))>0 then
    match_node     :=xslprocessor.selectSingleNode(geocode_node,'match');
    address_node   :=xslprocessor.selectSingleNode(match_node,'output_address');
    xslprocessor.valueOf(address_node,'@name',name);
    xslprocessor.valueOf(address_node,'@house_number',house_number);
    xslprocessor.valueOf(address_node,'@street',street);
    xslprocessor.valueOf(address_node,'@builtup_area',builtup_area);
    xslprocessor.valueOf(address_node,'@order1_area',order1_area);
    xslprocessor.valueOf(address_node,'@order2_area',order2_area);
    xslprocessor.valueOf(address_node,'@order8_area',order8_area);
    xslprocessor.valueOf(address_node,'@country',country_name);
    xslprocessor.valueOf(address_node,'@postal_code',postal_code);
    xslprocessor.valueOf(match_node,'@longitude',l_longitude);
    xslprocessor.valueOf(match_node,'@latitude',l_latitude);
    if (l_longitude is not null and l_latitude is not null) then
      geometry     :=MDSYS.SDO_GEOMETRY(2001
                               ,8307
                               ,MDSYS.SDO_POINT_TYPE
                                (l_longitude
                                ,l_latitude
                                ,NULL)
                               ,NULL
                               ,NULL);
    else
      geometry     :=null;
    end if;
  end if;
  xmldom.freeDocument(address_doc);
  exception
    when others then
    xmldom.freeDocument(address_doc);
    raise;

end address2full;
--
-- -------------------------------------------------------------------------
-- |---------------------------< sdo_distance >----------------------------|
-- -------------------------------------------------------------------------
--  wrapper for sdo_geom.sdo_distance function
--
function sdo_distance
(geom1         in MDSYS.SDO_GEOMETRY
,geom2         in MDSYS.SDO_GEOMETRY
,tolerance     in number) return number
as
l_retval number;
begin
  if geom1 is not null and geom2 is not null then
    l_retval:=sdo_miles(geom1,geom2,tolerance);
    if l_retval is not null then
      l_retval:=l_retval/69.171;
    end if;
  end if;
return l_retval;
end sdo_distance;
--
-- -------------------------------------------------------------------------
-- |---------------------------< sdo_miles >----------------------------|
-- -------------------------------------------------------------------------
--  wrapper for sdo_geom.sdo_distance function
--
function sdo_miles
(geom1         in MDSYS.SDO_GEOMETRY
,geom2         in MDSYS.SDO_GEOMETRY
,tolerance     in number) return number
as
begin
    if geom1 is null or geom2 is null then
      return to_number(null);
    else
      if g_conversion is null then
        if hr_general2.get_oracle_db_version>=9 then
          g_conversion:=1/1609.344;
        else
          g_conversion:=69.171;
        end if;
      end if;
      return sdo_geom.sdo_distance(geom1,geom2,tolerance)*g_conversion;
    end if;
end sdo_miles;
end irc_location_utility;

/
