--------------------------------------------------------
--  DDL for Package Body PO_HR_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HR_LOCATION" AS
/* $Header: POXPRPOB.pls 120.5.12010000.3 2012/12/17 06:21:55 jozhong ship $*/

g_address_details PO_HR_LOCATION.address; -- Its a PL/SQL table of po_address_details_gt rowtype

g_addr_prompt_query PO_HR_LOCATION.addr_prompt_query; --PL/SQL table for storing style code, query and prompt list.

-- Debugging booleans used to bypass logging when turned off
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

-- Logging constants
g_pkg_name CONSTANT VARCHAR2(30) := 'PO_HR_LOCATION';
g_module_prefix CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.';
-- <R12 PO OTM Integration START>
/********************************************************************************
**   Procedure get_address
********************************************************************************/
PROCEDURE get_address
( p_location_id          IN         NUMBER
, x_address_line_1       OUT NOCOPY VARCHAR2
, x_address_line_2       OUT NOCOPY VARCHAR2
, x_address_line_3       OUT NOCOPY VARCHAR2
, x_town_or_city         OUT NOCOPY VARCHAR2
, x_state_or_province    OUT NOCOPY VARCHAR2
, x_postal_code          OUT NOCOPY VARCHAR2
, x_territory_short_name OUT NOCOPY VARCHAR2
, x_iso_territory_code   OUT NOCOPY VARCHAR2
)
IS
  l_temp_location_id    NUMBER;

  d_progress         VARCHAR2(3);
  d_module           CONSTANT VARCHAR2(100) := g_module_prefix || 'GET_ADDRESS';

BEGIN

  d_progress := '000';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_begin(d_module);
    PO_DEBUG.debug_var(d_module, d_progress, 'p_location_id', p_location_id);
  END IF;

  d_progress := '100';

  -- See if this location is in HR_LOCATIONS or if it
  -- is a drop ship location
  BEGIN
    SELECT hrl.location_id
    INTO   l_temp_location_id
    FROM   hr_locations hrl
    WHERE  hrl.location_id = p_location_id;

    d_progress := '110';

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     d_progress := '120';
     l_temp_location_id := NULL;
  END;

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_var(d_module, d_progress, 'l_temp_location_id', l_temp_location_id);
  END IF;

  d_progress := '130';

  IF (l_temp_location_id IS NOT NULL) THEN
   -- Regular HR location
   d_progress := '200';

    BEGIN
    /*Bug 5084855 Adding the NVL to get the Country value for Generic Address Style */
      SELECT hrl.address_line_1
           , hrl.address_line_2
           , hrl.address_line_3
            --, hrl.town_or_city  -- bug#15993315 commented to take town_or_city from fnd_lookup_values
 	   , Decode(hrl.town_or_city,flv4.lookup_code,flv4.meaning,hrl.town_or_city)
           , NVL(DECODE(hrl.region_1,NULL,hrl.region_2,
                        DECODE(flv1.meaning,NULL,
                               DECODE(flv2.meaning,NULL,flv3.meaning,flv2.lookup_code)
                , flv1.lookup_code)), hrl.region_2)
           , hrl.postal_code
           , NVL(ftel.territory_short_name,hrl.country)
           , fte.iso_territory_code
      INTO   x_address_line_1
           , x_address_line_2
           , x_address_line_3
           , x_town_or_city
           , x_state_or_province
           , x_postal_code
           , x_territory_short_name
           , x_iso_territory_code
      FROM   hr_locations_all hrl
           , fnd_territories fte
           , fnd_territories_tl ftel
           , fnd_lookup_values flv1
           , fnd_lookup_values flv2
           , fnd_lookup_values flv3
	   , fnd_lookup_values flv4
      WHERE  hrl.location_id             = p_location_id
        AND  hrl.country                 = fte.territory_code (+)
        AND  hrl.country                 = ftel.territory_code (+)
        AND  DECODE(ftel.territory_code, NULL, '1', ftel.language) =
                   DECODE(ftel.territory_code, NULL, '1', USERENV('LANG'))
        AND  hrl.region_1                = flv1.lookup_code (+)
        AND  hrl.country || '_PROVINCE'  = flv1.lookup_type (+)
        AND  DECODE(flv1.lookup_code, NULL, '1', flv1.security_group_id) =
                   DECODE(flv1.lookup_code, NULL, '1',
                        FND_GLOBAL.lookup_security_group(flv1.lookup_type, flv1.view_application_id))
        AND  DECODE(flv1.lookup_code, NULL, '1', flv1.view_application_id) =
                   DECODE(flv1.lookup_code, NULL, '1', 3)
        AND  DECODE(flv1.lookup_code, NULL, '1', flv1.language) =
                   DECODE(flv1.lookup_code, NULL, '1', USERENV('LANG'))
        AND  hrl.region_2 = flv2.lookup_code (+)
        AND  hrl.country || '_STATE' = flv2.lookup_type (+)
        AND  DECODE(flv2.lookup_code, NULL, '1', flv2.security_group_id) =
                   DECODE(flv2.lookup_code, NULL, '1',
                        FND_GLOBAL.lookup_security_group(flv2.lookup_type, flv2.view_application_id))
        AND  DECODE(flv2.lookup_code, NULL, '1', flv2.view_application_id) =
                   DECODE(flv2.lookup_code, NULL, '1', 3)
        AND  DECODE(flv2.lookup_code, NULL, '1', flv2.language) =
                   DECODE(flv2.lookup_code, NULL, '1', USERENV('LANG'))
        AND  hrl.region_1 = flv3.lookup_code (+)
        AND  hrl.country || '_COUNTY' = flv3.lookup_type (+)
        AND  DECODE(flv3.lookup_code, NULL, '1', flv3.security_group_id) =
                   DECODE(flv3.lookup_code, NULL, '1',
                         FND_GLOBAL.lookup_security_group(flv3.lookup_type, flv3.view_application_id))
        AND  DECODE(flv3.lookup_code, NULL, '1', flv3.view_application_id) =
                   DECODE(flv3.lookup_code, NULL, '1', 3)
        AND  DECODE(flv3.lookup_code, NULL, '1', flv3.language) =
                   DECODE(flv3.lookup_code, NULL, '1', USERENV('LANG'))
         AND  hrl.town_or_city = flv4.lookup_code(+)
 	 AND  hrl.country || '_PROVINCE'  = flv4.lookup_type (+)
 	      	AND  DECODE(flv4.lookup_code, NULL, '1', flv4.security_group_id) =
 	                     DECODE(flv4.lookup_code, NULL, '1',
 	                          FND_GLOBAL.lookup_security_group(flv4.lookup_type, flv4.view_application_id))
 	         AND  DECODE(flv4.lookup_code, NULL, '1', flv4.view_application_id) =
 	                     DECODE(flv4.lookup_code, NULL, '1', 3)
 	         AND  DECODE(flv4.lookup_code, NULL, '1', flv4.language) =
 	                     DECODE(flv4.lookup_code, NULL, '1', USERENV('LANG'))
      ;

      d_progress := '210';

    EXCEPTION
      WHEN OTHERS THEN
        IF (g_debug_unexp) THEN
          PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception occurred retrieving location');
        END IF;
          x_address_line_1 := '';
          x_address_line_2 := '';
          x_address_line_3 := '';
          x_town_or_city := '';
          x_state_or_province := '';
          x_postal_code := '';
          x_territory_short_name := '';
          x_iso_territory_code := '';

    END;

  ELSE
    -- HZ Location
    d_progress := '300';

    BEGIN
      /*Bug 5084855 Adding the NVL to get the Country value for Generic Address Style */
      SELECT hzl.address1
           , hzl.address2
           , hzl.address3
           , hzl.city
           , NVL(DECODE(hzl.county,NULL,hzl.state,
                        DECODE(flv1.meaning,NULL,
                               DECODE(flv2.meaning,NULL,flv3.meaning,flv2.lookup_code)
                , flv1.lookup_code)), hzl.state)|| Decode (hzl.province, NULL , '', ', ' || hzl.province) --bug10245785
           , hzl.postal_code
           , NVL(ftel.territory_short_name, hzl.country)
           , fte.iso_territory_code
      INTO   x_address_line_1
           , x_address_line_2
           , x_address_line_3
           , x_town_or_city
           , x_state_or_province
           , x_postal_code
           , x_territory_short_name
           , x_iso_territory_code
      FROM   hz_locations hzl
           , fnd_territories fte
           , fnd_territories_tl ftel
           , fnd_lookup_values flv1
           , fnd_lookup_values flv2
           , fnd_lookup_values flv3
      WHERE  hzl.location_id             = p_location_id
        AND  hzl.country                 = fte.territory_code (+)
        AND  hzl.country                 = ftel.territory_code (+)
        AND  DECODE(ftel.territory_code, NULL, '1', ftel.language) =
                   DECODE(ftel.territory_code, NULL, '1', USERENV('LANG'))
        AND  hzl.county                = flv1.lookup_code (+)
        AND  hzl.country || '_PROVINCE'  = flv1.lookup_type (+)
        AND  DECODE(flv1.lookup_code, NULL, '1', flv1.security_group_id) =
                   DECODE(flv1.lookup_code, NULL, '1',
                        FND_GLOBAL.lookup_security_group(flv1.lookup_type, flv1.view_application_id))
        AND  DECODE(flv1.lookup_code, NULL, '1', flv1.view_application_id) =
                   DECODE(flv1.lookup_code, NULL, '1', 3)
        AND  DECODE(flv1.lookup_code, NULL, '1', flv1.language) =
                   DECODE(flv1.lookup_code, NULL, '1', USERENV('LANG'))
        AND  hzl.state = flv2.lookup_code (+)
        AND  hzl.country || '_STATE' = flv2.lookup_type (+)
        AND  DECODE(flv2.lookup_code, NULL, '1', flv2.security_group_id) =
                   DECODE(flv2.lookup_code, NULL, '1',
                        FND_GLOBAL.lookup_security_group(flv2.lookup_type, flv2.view_application_id))
        AND  DECODE(flv2.lookup_code, NULL, '1', flv2.view_application_id) =
                   DECODE(flv2.lookup_code, NULL, '1', 3)
        AND  DECODE(flv2.lookup_code, NULL, '1', flv2.language) =
                   DECODE(flv2.lookup_code, NULL, '1', USERENV('LANG'))
        AND  hzl.county = flv3.lookup_code (+)
        AND  hzl.country || '_COUNTY' = flv3.lookup_type (+)
        AND  DECODE(flv3.lookup_code, NULL, '1', flv3.security_group_id) =
                   DECODE(flv3.lookup_code, NULL, '1',
                         FND_GLOBAL.lookup_security_group(flv3.lookup_type, flv3.view_application_id))
        AND  DECODE(flv3.lookup_code, NULL, '1', flv3.view_application_id) =
                   DECODE(flv3.lookup_code, NULL, '1', 3)
        AND  DECODE(flv3.lookup_code, NULL, '1', flv3.language) =
                   DECODE(flv3.lookup_code, NULL, '1', USERENV('LANG'))
      ;

      d_progress := '310';

    EXCEPTION
      WHEN OTHERS THEN
        IF (g_debug_unexp) THEN
          PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception occurred retrieving location');
        END IF;
        x_address_line_1 := '';
        x_address_line_2 := '';
        x_address_line_3 := '';
        x_town_or_city := '';
        x_state_or_province := '';
        x_postal_code := '';
        x_territory_short_name := '';
        x_iso_territory_code := '';

    END;

  END IF; -- IF (l_temp_location_id IS NOT NULL) THEN

  d_progress := '140';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_var(d_module, d_progress, 'x_address_line_1', x_address_line_1);
    PO_DEBUG.debug_var(d_module, d_progress, 'x_address_line_2', x_address_line_2);
    PO_DEBUG.debug_var(d_module, d_progress, 'x_address_line_3', x_address_line_3);
    PO_DEBUG.debug_var(d_module, d_progress, 'x_town_or_city', x_town_or_city);
    PO_DEBUG.debug_var(d_module, d_progress, 'x_state_or_province', x_state_or_province);
    PO_DEBUG.debug_var(d_module, d_progress, 'x_postal_code', x_postal_code);
    PO_DEBUG.debug_var(d_module, d_progress, 'x_territory_short_name', x_territory_short_name);
    PO_DEBUG.debug_var(d_module, d_progress, 'x_iso_territory_code', x_iso_territory_code);
    PO_DEBUG.debug_end(d_module);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
     IF (g_debug_unexp) THEN
       PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception occurred retrieving location');
     END IF;

     x_address_line_1 := '';
     x_address_line_2 := '';
     x_address_line_3 := '';
     x_town_or_city := '';
     x_state_or_province := '';
     x_postal_code := '';
     x_territory_short_name := '';
     x_iso_territory_code := '';

END get_address;
-- <R12 PO OTM Integration END>

/********************************************************************************
**
**   Procedure get_address
**   Created for ER 2291745
**   Logic
**     1. The x_temp_location_id will be set if the location exists in hr_Locations
**     2. Based on the x_temp_location_id the address will be selected from either
**        hr_locations or from hz_locations
**
********************************************************************************/

PROCEDURE get_address
( x_location_id        IN  Number,
  Address_line_1       OUT NOCOPY Varchar2,
  Address_line_2       OUT NOCOPY Varchar2,
  Address_line_3       OUT NOCOPY Varchar2,
  Territory_short_name OUT NOCOPY VArchar2,
  Address_info         OUT NOCOPY Varchar2 )
  IS
  l_town_or_city         HR_LOCATIONS_ALL.town_or_city%TYPE;
  l_state_or_province    HR_LOCATIONS_ALL.region_1%TYPE;
  l_postal_code          HR_LOCATIONS_ALL.postal_code%TYPE;
  l_iso_territory_code   FND_TERRITORIES.iso_territory_code%TYPE;

Begin

get_address (
  p_location_id          => x_location_id
, x_address_line_1       => address_line_1
, x_address_line_2       => address_line_2
, x_address_line_3       => address_line_3
, x_town_or_city         => l_town_or_city
, x_state_or_province    => l_state_or_province
, x_postal_code          => l_postal_code
, x_territory_short_name => territory_short_name
, x_iso_territory_code   => l_iso_territory_code );

IF (l_town_or_city IS NULL) THEN
  address_info := l_state_or_province || ' ' || l_postal_code;
ELSE
  address_info := l_town_or_city || ',' || l_state_or_province || ' ' ||     l_postal_code;
END IF;


END GET_ADDRESS;

/********************************************************************************
**
**   Procedure get_address (with over loading)
**   Created for FPJ PO Communication Enhancement
**   Logic
**     1. The x_temp_location_id will be set if the location exists in hr_Locations
**     2. Based on the x_temp_location_id the address will be selected from either
**        hr_locations or from hz_locations
**--Change Hisotry: bug#3438608 added the out variables x_town_or_city
--x_postal_code and x_state_or_province
********************************************************************************/
PROCEDURE get_address
    ( p_location_id		IN  Number,
      x_address_line_1		OUT NOCOPY Varchar2,
      x_address_line_2		OUT NOCOPY Varchar2,
      x_address_line_3		OUT NOCOPY Varchar2,
      x_territory_short_name	OUT NOCOPY VArchar2,
      x_address_info		OUT NOCOPY Varchar2,
      x_location_name		OUT NOCOPY  Varchar2,
      x_contact_phone		OUT NOCOPY  Varchar2,
      x_contact_fax		OUT NOCOPY  Varchar2,
      x_address_line_4		OUT NOCOPY  Varchar2,
      x_town_or_city		OUT NOCOPY HR_LOCATIONS.town_or_city%type,
      x_postal_code		OUT NOCOPY HR_LOCATIONS.postal_code%type,
      x_state_or_province	OUT NOCOPY varchar2)

      IS
 l_town_or_city        Varchar2(240);
 l_state_or_province   Varchar2(240);
 l_postal_code         Varchar2(240);
 l_temp_location_id  Number   := NULL ;
Begin

   /* Select the location id from hr_locations. If the location is in hr_locations
      it will be populated. Else the l_temp_location_id will be made NULL */

  Begin
   Select location_id into l_temp_location_id
   from hr_locations
   where location_id = p_location_id;
  exception
   WHEN NO_DATA_FOUND THEN
     l_temp_location_id := NULL;
  end;


   if (l_temp_location_id is not null) then

  /* If the l_addr_select_qry location id is not null then get the address from hr_locations */

   Begin
    /*Bug 5084855 Adding the NVL to get the Country value for Generic Address Style */
     Select  HLC.ADDRESS_LINE_1,
             HLC.ADDRESS_LINE_2,
             HLC.ADDRESS_LINE_3,
            -- HLC.TOWN_OR_CITY, --bug#15993315 commented to fetch town_or_city from fnd_looup_values
 	     Decode(HLC.TOWN_OR_CITY,FCL4.lookup_code,FCL4.meaning,HLC.TOWN_OR_CITY),
             NVL(DECODE(HLC.REGION_1, NULL, HLC.REGION_2,
                          DECODE(FCL1.MEANING, NULL,
                               DECODE(FCL2.MEANING, NULL,FCL3.MEANING, FCL2.LOOKUP_CODE),
                          FCL1.LOOKUP_CODE)), HLC.REGION_2) ,
   	     HLC.POSTAL_CODE,
	     NVL(FTE.TERRITORY_SHORT_NAME,HLC.COUNTRY),
	     HLC.LOCATION_CODE,
	     HLC.TELEPHONE_NUMBER_1,
	     HLC.TELEPHONE_NUMBER_2
     INTO
             x_address_line_1 ,
             x_address_line_2 ,
	     x_address_line_3 ,
             l_town_or_city   ,
             l_state_or_province,
             l_postal_code,
	     x_territory_short_name,
	     x_location_name,
	     x_contact_phone,
	     x_contact_fax
     FROM
             HR_LOCATIONS             HLC,
             FND_TERRITORIES_TL       FTE,
             FND_LOOKUP_VALUES        FCL1,
             FND_LOOKUP_VALUES        FCL2,
             FND_LOOKUP_VALUES        FCL3,
	     FND_LOOKUP_VALUES        FCL4
     Where
            HLC.LOCATION_ID  = p_location_id AND
            HLC.COUNTRY = FTE.TERRITORY_CODE (+) AND
            DECODE(FTE.TERRITORY_CODE, NULL, '1', FTE.LANGUAGE) =
                  DECODE(FTE.TERRITORY_CODE, NULL, '1', USERENV('LANG')) AND
            HLC.REGION_1 = FCL1.LOOKUP_CODE (+) AND
            HLC.COUNTRY || '_PROVINCE' = FCL1.LOOKUP_TYPE (+) AND
            DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.SECURITY_GROUP_ID) =
                  DECODE(FCL1.LOOKUP_CODE, NULL, '1',
                       FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL1.LOOKUP_TYPE, FCL1.VIEW_APPLICATION_ID)) AND
            DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.VIEW_APPLICATION_ID) =
                  DECODE(FCL1.LOOKUP_CODE, NULL, '1', 3) AND
            DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.LANGUAGE) =
                  DECODE(FCL1.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
            HLC.REGION_2 = FCL2.LOOKUP_CODE (+) AND
            HLC.COUNTRY || '_STATE' = FCL2.LOOKUP_TYPE (+) AND
            DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.SECURITY_GROUP_ID) =
                  DECODE(FCL2.LOOKUP_CODE, NULL, '1',
                       FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL2.LOOKUP_TYPE, FCL2.VIEW_APPLICATION_ID)) AND
            DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.VIEW_APPLICATION_ID) =
                  DECODE(FCL2.LOOKUP_CODE, NULL, '1', 3) AND
            DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.LANGUAGE) =
                  DECODE(FCL2.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
            HLC.REGION_1 = FCL3.LOOKUP_CODE (+) AND
            HLC.COUNTRY || '_COUNTY' = FCL3.LOOKUP_TYPE (+) AND
            DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.SECURITY_GROUP_ID) =
                  DECODE(FCL3.LOOKUP_CODE, NULL, '1',
                        FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL3.LOOKUP_TYPE, FCL3.VIEW_APPLICATION_ID)) AND
            DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.VIEW_APPLICATION_ID) =
                  DECODE(FCL3.LOOKUP_CODE, NULL, '1', 3) AND
            DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.LANGUAGE) =
                  DECODE(FCL3.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
 	             HLC.TOWN_OR_CITY = FCL4.LOOKUP_CODE (+) AND
 	             HLC.COUNTRY || '_PROVINCE' = FCL4.LOOKUP_TYPE (+) AND
 	    DECODE(FCL4.LOOKUP_CODE, NULL, '1', FCL4.SECURITY_GROUP_ID) =
 	           DECODE(FCL4.LOOKUP_CODE, NULL, '1',
 	              FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL4.LOOKUP_TYPE, FCL4.VIEW_APPLICATION_ID)) AND
 	       DECODE(FCL4.LOOKUP_CODE, NULL, '1', FCL4.VIEW_APPLICATION_ID) =
 	            DECODE(FCL4.LOOKUP_CODE, NULL, '1', 3) AND
 	      DECODE(FCL4.LOOKUP_CODE, NULL, '1', FCL4.LANGUAGE) =
 	         DECODE(FCL4.LOOKUP_CODE, NULL, '1', USERENV('LANG'))  ;


     Exception
       WHEN OTHERS then
        x_address_line_1    := '';
        x_address_line_2    := '';
        x_address_line_3    := '';
        l_town_or_city      := '';
        l_state_or_province := '';
        l_postal_code       := '';
--bug#3438608
	x_town_or_city      := '';
	x_state_or_province := '';
	x_postal_code       := '';
--bug#3438608

        x_territory_short_name := '';
	x_location_name := '';
        x_contact_phone := '';
        x_contact_fax := '';

     End; /* hr_locations */

   else

     /* If the l_addr_select_qry location id is null then select the address from hz_locations */
     /*
	bug#3463617: address4 is selected from hz_locations.
     */
     Begin
      /*Bug 5084855 Adding the NVL to get the Country value for Generic Address Style */
         SELECT
	           HLC.ADDRESS1,
	           HLC.ADDRESS2,
                   HLC.ADDRESS3,
	           HLC.CITY,
                   NVL(DECODE(HLC.county, NULL, HLC.state,
                           DECODE(FCL1.MEANING, NULL,
                                  DECODE(FCL2.MEANING, NULL,FCL3.MEANING, FCL2.LOOKUP_CODE),
                           FCL1.LOOKUP_CODE)), HLC.state)|| Decode (HLC.province, NULL , '', ', ' || HLC.province) , --bug10245785
                   HLC.POSTAL_CODE,
	           NVL(FTE.TERRITORY_SHORT_NAME, HLC.COUNTRY),
		   HLC.ADDRESS4
        INTO
                   x_address_line_1 ,
		   x_address_line_2 ,
		   x_address_line_3 ,
		   l_town_or_city   ,
		   l_state_or_province,
		   l_postal_code,
		   x_territory_short_name,
		   x_address_line_4
         FROM
		   HZ_LOCATIONS             HLC,
		   FND_TERRITORIES_TL       FTE,
   	 	   FND_LOOKUP_VALUES        FCL1,
   		   FND_LOOKUP_VALUES        FCL2,
   		   FND_LOOKUP_VALUES        FCL3
  	WHERE
  	 	HLC.LOCATION_ID  = p_location_id AND
 		HLC.COUNTRY = FTE.TERRITORY_CODE (+) AND
 		DECODE(FTE.TERRITORY_CODE, NULL, '1', FTE.LANGUAGE) =
                DECODE(FTE.TERRITORY_CODE, NULL, '1', USERENV('LANG')) AND
  		HLC.county = FCL1.LOOKUP_CODE (+) AND
  		HLC.COUNTRY || '_PROVINCE' = FCL1.LOOKUP_TYPE (+) AND
  		DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.SECURITY_GROUP_ID) =
                      DECODE(FCL1.LOOKUP_CODE, NULL, '1',
                           FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL1.LOOKUP_TYPE, FCL1.VIEW_APPLICATION_ID)) AND
  		DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.VIEW_APPLICATION_ID) =
                      DECODE(FCL1.LOOKUP_CODE, NULL, '1', 3) AND
 		DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.LANGUAGE) =
                      DECODE(FCL1.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
  		HLC.state = FCL2.LOOKUP_CODE (+) AND
 		HLC.COUNTRY || '_STATE' = FCL2.LOOKUP_TYPE (+) AND
   		DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.SECURITY_GROUP_ID) =
                      DECODE(FCL2.LOOKUP_CODE, NULL, '1',
                           FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL2.LOOKUP_TYPE, FCL2.VIEW_APPLICATION_ID)) AND
   		DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.VIEW_APPLICATION_ID) =
                      DECODE(FCL2.LOOKUP_CODE, NULL, '1', 3) AND
  		DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.LANGUAGE) =
                      DECODE(FCL2.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
  		HLC.county = FCL3.LOOKUP_CODE (+) AND
  		HLC.COUNTRY || '_COUNTY' = FCL3.LOOKUP_TYPE (+) AND
  		DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.SECURITY_GROUP_ID) =
                      DECODE(FCL3.LOOKUP_CODE, NULL, '1',
                           FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL3.LOOKUP_TYPE, FCL3.VIEW_APPLICATION_ID)) AND
   		DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.VIEW_APPLICATION_ID) =
                      DECODE(FCL3.LOOKUP_CODE, NULL, '1', 3) AND
  		DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.LANGUAGE) =
                      DECODE(FCL3.LOOKUP_CODE, NULL, '1', USERENV('LANG')) ;
		/*
			In hz_locations table there is no columns for location code, phone and fax.
		*/
--bug#3438608 nulling out the columns for hz_locations table where there is no column for location_code
--phone and fax..
		x_location_name := null;
		x_contact_phone :=null;
		x_contact_fax :=null;

       Exception
         WHEN OTHERS then
--bug# 3438608
		x_address_line_1    := '';
		x_address_line_2    := '';
		x_address_line_3    := '';
--bug#3438608
		l_town_or_city      := '';
		l_state_or_province := '';
		l_postal_code       := '';
		x_town_or_city      := '';
		x_state_or_province := '';
		x_postal_code       := '';
		x_territory_short_name := '';
		x_location_name := '';
		x_contact_phone := '';
		x_contact_fax := '';
		x_address_line_4    := '';

     END; /* HZ_LOCATIONS */

 end if;

        If (l_town_or_city is null) then
           x_address_info := l_state_or_province||' '|| l_postal_code;
        else
           x_address_info := l_town_or_city||', '||l_state_or_province||' '||l_postal_code;
        end if;
--bug#3438608 copy the values of l_town_or_city,l_postal_code and
--l_state_or_province to their respective out variables
	x_town_or_city:=l_town_or_city;
	x_postal_code:=l_postal_code;
	x_state_or_province:=l_state_or_province;

 Exception
  /* If thers is any error null out all the fields */
   WHEN OTHERS THEN
        x_address_line_1    := '';
	x_address_line_2    := '';
	x_address_line_3    := '';
--bug#3438608
	x_town_or_city      := '';
	x_state_or_province := '';
	x_postal_code       := '';
--bug#3438608

	x_territory_short_name := '';
	x_location_name := '';
	x_contact_phone := '';
	x_contact_fax := '';
	x_address_line_4    := '';

END GET_ADDRESS;


/*********************************************************************************************
**
**   Procedure: get_alladdress_lines
**   This procedure is used to retriev the address values mapped to
**   HR_LOCATIONS or HZ_LOCATIONS.
**
**   The prompts and the columns names where the prompts are mapped to
**   HR_LOCATIONS table is retrieved by using fnd_dflex package. fnd_dflex package is
**   is having functions and procedures to retrieve prompts names and the column names
**   of HR_LOCATIONS where the address details are stored.
**   Note: Some look up codes  are stored in HR_LOCATIONS table. Current procedure is not
**   retrieving the loop up values for these codes.
**
**   There is no package available to retrieve the prompts and column names
**   that are mapped to HZ_LOCATIONS. But HZ_FORMAT_PUB package is having a procedure
**   FORMAT_ADDRESS which returns the formatted address values for a given location id
**   and style code. This procedure doesn't give the prompts and column names of
**   HZ_LOCATIONS table where the address details are stored. Only address values are
**   retrieved for HZ_LOCATIONS.
**
**   Note: Since address are customizable and there is no limitaion in using the
**   number of segments, this procedure assumed that a max of 20 segments are enabled.
**   If more than 20 values are enabled this procedure will retrieve first 20 segment values.
**
**--Change Hisotry:
*********************************************************************************************/
PROCEDURE get_alladdress_lines
    ( p_location_id		IN  Number,
      x_address_line_1		OUT NOCOPY Varchar2,
      x_address_line_2		OUT NOCOPY Varchar2,
      x_address_line_3		OUT NOCOPY Varchar2,
      x_territory_short_name	OUT NOCOPY VArchar2,
      x_address_info		OUT NOCOPY Varchar2,
      x_location_name		OUT NOCOPY  Varchar2,
      x_contact_phone		OUT NOCOPY  Varchar2,
      x_contact_fax		OUT NOCOPY  Varchar2,
      x_address_line_4		OUT NOCOPY  Varchar2,
      x_town_or_city		OUT NOCOPY HR_LOCATIONS.town_or_city%type,
      x_postal_code		OUT NOCOPY HR_LOCATIONS.postal_code%type,
      x_state_or_province	OUT NOCOPY varchar2)

      IS

	/* Variables used in retreiving segments, prompts and column name from fnd_dflex*/

	flexfield fnd_dflex.dflex_r;
	flexinfo  fnd_dflex.dflex_dr;
	lcontext  fnd_dflex.context_r;
	i BINARY_INTEGER;
	segments  fnd_dflex.segments_dr;
	l_addr_prompts_array vchar_array := vchar_array(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	l_addr_col_names_array vchar_array := vchar_array('NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL');
	l_addr_values_array   vchar_array := vchar_array(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	l_count number := 0;
	l_addr_col_names varchar2(4000) :=NULL; -- Contains list of column names
	--l_addr_into_qry varchar2(4000) :=NULL;

        /*Bug 5854013 l_style_code holds the address_style from hz_locations also.Hence declaring the variable
	 to hold the length same as of HZ_LOCATIONS.ADDRESS_STYLE which is bigger than  HR_LOCATIONS.STYLE
	l_style_code HR_LOCATIONS.STYLE%type := null; */
	l_style_code HZ_LOCATIONS.ADDRESS_STYLE%type := null;

	l_temp_location_id  Number   := NULL ;
	l_addr_select_qry varchar2(4000);
	l_table_count number := 0;

	/*end of variables*/

	/* Variables used in HZ_FORMAT_PUB.FORMAT_ADDRESS procedure */

	x_formatted_address_tbl HZ_FORMAT_PUB.string_tbl_type;
	x_return_status		VARCHAR2(2) ;
	x_msg_count		NUMBER ;
	x_msg_data		VARCHAR2(4000) ;
	x_formatted_address	VARCHAR2(4000) ;
	x_formatted_lines_cnt	NUMBER ;

	/*end of variables */

	l_addr_prompt_query_count number := 0;
	l_location_id_exists varchar2(1) := 'N';
	l_style_code_exists varchar2(1) := 'N';

	c_log_head    CONSTANT VARCHAR2(30) := 'PO_HR_LOCATION.';
	l_api_name CONSTANT VARCHAR2(30):= 'GET_ALLADDRESS_LINES';


Begin

   /* Select the location id from hr_locations. If the location is in hr_locations
      it will be populated. Else the l_temp_location_id will be made NULL */

  Begin
   Select location_id, style  into l_temp_location_id, l_style_code
   from hr_locations
   where location_id = p_location_id;
  exception
   WHEN NO_DATA_FOUND THEN
     l_temp_location_id := NULL;
     l_style_code := NULL;
  end;


   if (l_temp_location_id is not null) then

  /* If location id is not null then get the address from hr_locations */

   Begin
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
	  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'Retreiving data from HR_LOCATIONS');
	END IF;
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
	  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'location Id:'|| p_location_id);
	END IF;
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
	  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'Style code:'|| l_style_code);
	END IF;

/*Bug 5084855 Adding the NVL to get the Country value for Generic Address Style */
     Select  HLC.ADDRESS_LINE_1,
             HLC.ADDRESS_LINE_2,
             HLC.ADDRESS_LINE_3,
            -- HLC.TOWN_OR_CITY, --bug#15993315 commented to fetch town_or_city from fnd_lookup_values
 	     Decode(HLC.TOWN_OR_CITY,FCL4.lookup_code,FCL4.meaning,HLC.TOWN_OR_CITY),
             NVL(DECODE(HLC.REGION_1, NULL, HLC.REGION_2,
                          DECODE(FCL1.MEANING, NULL,
                               DECODE(FCL2.MEANING, NULL,FCL3.MEANING, FCL2.LOOKUP_CODE),
                          FCL1.LOOKUP_CODE)), HLC.REGION_2) ,
   	     HLC.POSTAL_CODE,
	     NVL(FTE.TERRITORY_SHORT_NAME, HLC.COUNTRY),
	     HLC.LOCATION_CODE,
	     HLC.TELEPHONE_NUMBER_1,
	     HLC.TELEPHONE_NUMBER_2
     INTO
             x_address_line_1 ,
             x_address_line_2 ,
	     x_address_line_3 ,
             x_town_or_city   ,
             x_state_or_province,
             x_postal_code,
	     x_territory_short_name,
	     x_location_name,
	     x_contact_phone,
	     x_contact_fax
     FROM
             HR_LOCATIONS             HLC,
             FND_TERRITORIES_TL       FTE,
             FND_LOOKUP_VALUES        FCL1,
             FND_LOOKUP_VALUES        FCL2,
             FND_LOOKUP_VALUES        FCL3,
	     FND_LOOKUP_VALUES        FCL4
     Where
            HLC.LOCATION_ID  = p_location_id AND
            HLC.COUNTRY = FTE.TERRITORY_CODE (+) AND
            DECODE(FTE.TERRITORY_CODE, NULL, '1', FTE.LANGUAGE) =
                  DECODE(FTE.TERRITORY_CODE, NULL, '1', USERENV('LANG')) AND
            HLC.REGION_1 = FCL1.LOOKUP_CODE (+) AND
            HLC.COUNTRY || '_PROVINCE' = FCL1.LOOKUP_TYPE (+) AND
            DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.SECURITY_GROUP_ID) =
                  DECODE(FCL1.LOOKUP_CODE, NULL, '1',
                       FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL1.LOOKUP_TYPE, FCL1.VIEW_APPLICATION_ID)) AND
            DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.VIEW_APPLICATION_ID) =
                  DECODE(FCL1.LOOKUP_CODE, NULL, '1', 3) AND
            DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.LANGUAGE) =
                  DECODE(FCL1.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
            HLC.REGION_2 = FCL2.LOOKUP_CODE (+) AND
            HLC.COUNTRY || '_STATE' = FCL2.LOOKUP_TYPE (+) AND
            DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.SECURITY_GROUP_ID) =
                  DECODE(FCL2.LOOKUP_CODE, NULL, '1',
                       FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL2.LOOKUP_TYPE, FCL2.VIEW_APPLICATION_ID)) AND
            DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.VIEW_APPLICATION_ID) =
                  DECODE(FCL2.LOOKUP_CODE, NULL, '1', 3) AND
            DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.LANGUAGE) =
                  DECODE(FCL2.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
            HLC.REGION_1 = FCL3.LOOKUP_CODE (+) AND
            HLC.COUNTRY || '_COUNTY' = FCL3.LOOKUP_TYPE (+) AND
            DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.SECURITY_GROUP_ID) =
                  DECODE(FCL3.LOOKUP_CODE, NULL, '1',
                        FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL3.LOOKUP_TYPE, FCL3.VIEW_APPLICATION_ID)) AND
            DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.VIEW_APPLICATION_ID) =
                  DECODE(FCL3.LOOKUP_CODE, NULL, '1', 3) AND
            DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.LANGUAGE) =
                  DECODE(FCL3.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
 	     HLC.TOWN_OR_CITY = FCL4.LOOKUP_CODE (+) AND
 	       HLC.COUNTRY || '_PROVINCE' = FCL4.LOOKUP_TYPE (+) AND
 	       DECODE(FCL4.LOOKUP_CODE, NULL, '1', FCL4.SECURITY_GROUP_ID) =
 	          DECODE(FCL4.LOOKUP_CODE, NULL, '1',
 	              FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL4.LOOKUP_TYPE, FCL4.VIEW_APPLICATION_ID)) AND
 	        DECODE(FCL4.LOOKUP_CODE, NULL, '1', FCL4.VIEW_APPLICATION_ID) =
 	             DECODE(FCL4.LOOKUP_CODE, NULL, '1', 3) AND
 	         DECODE(FCL4.LOOKUP_CODE, NULL, '1', FCL4.LANGUAGE) =
 	           DECODE(FCL4.LOOKUP_CODE, NULL, '1', USERENV('LANG'))  ;

	/*******************************************************************************************************
	 Logic used to improve performance.
	 1. Check whether the given location id exists in g_address_details PL/SQL table.
	 2. FND_DFLEX package is not called if location id exists.
	 3. IF location id is not in PL/SQL table check whether the style code exists
	    in g_addr_prompt_query PL/SQL table.
	 4. If the style code exists retrieve select query and prompts list from g_addr_prompt_query PL/SQL table,
            else use FND_DFLEX package to retrieve the column names and prompts and add them to
	    g_addr_prompt_query PL/SQL table.
	*******************************************************************************************************/

	l_table_count := g_address_details.count; -- Number of rows in the PL/SQl table
	l_addr_prompt_query_count :=  g_addr_prompt_query.count; -- Number of records in g_addr_prompt_query PL/SQL table

	/* Check whether the location id exists in g_address_details PL/SQL table.*/
	FOR i IN 1 .. l_table_count LOOP

		IF g_address_details(i).location_id = p_location_id THEN
			l_location_id_exists := 'Y';
			EXIT ;
		END IF;
	END LOOP;


        /* IF location id is not in g_address_details table enter into  IF condition*/
	IF (l_location_id_exists <> 'Y') THEN

		FOR i IN 1 .. l_addr_prompt_query_count LOOP

			IF g_addr_prompt_query(i).address_style = l_style_code THEN
				l_addr_select_qry := g_addr_prompt_query(i).query;
				-- Start bug#3622675: Removed l_addr_prompts_array and added 20 variables
				-- to hold the prompt names.

				l_addr_prompts_array(1):= g_addr_prompt_query(i).addr_label_1;
				l_addr_prompts_array(2):= g_addr_prompt_query(i).addr_label_2;
				l_addr_prompts_array(3):= g_addr_prompt_query(i).addr_label_3;
				l_addr_prompts_array(4):= g_addr_prompt_query(i).addr_label_4;
				l_addr_prompts_array(5):= g_addr_prompt_query(i).addr_label_5;
				l_addr_prompts_array(6):= g_addr_prompt_query(i).addr_label_6;
				l_addr_prompts_array(7):= g_addr_prompt_query(i).addr_label_7;
				l_addr_prompts_array(8):= g_addr_prompt_query(i).addr_label_8;
				l_addr_prompts_array(9):= g_addr_prompt_query(i).addr_label_9;
				l_addr_prompts_array(10):= g_addr_prompt_query(i).addr_label_10;
				l_addr_prompts_array(11):= g_addr_prompt_query(i).addr_label_11;
				l_addr_prompts_array(12):= g_addr_prompt_query(i).addr_label_12;
				l_addr_prompts_array(13):= g_addr_prompt_query(i).addr_label_13;
				l_addr_prompts_array(14):= g_addr_prompt_query(i).addr_label_14;
				l_addr_prompts_array(15):= g_addr_prompt_query(i).addr_label_15;
				l_addr_prompts_array(16):= g_addr_prompt_query(i).addr_label_16;
				l_addr_prompts_array(17):= g_addr_prompt_query(i).addr_label_17;
				l_addr_prompts_array(18):= g_addr_prompt_query(i).addr_label_18;
				l_addr_prompts_array(19):= g_addr_prompt_query(i).addr_label_19;
				l_addr_prompts_array(20):= g_addr_prompt_query(i).addr_label_20;
				-- end of bug#3622675 -->
				l_style_code_exists := 'Y';
				EXIT ;
			END IF;
		END LOOP;

		/* If style code not exists use FND_DFLEX package to retireve prompts and column names. */

		IF l_style_code_exists <> 'Y' THEN

			fnd_dflex.get_flexfield('PER', 'Address Location', flexfield, flexinfo);
			lcontext.flexfield := flexfield;
			lcontext.context_code := l_style_code;
			fnd_dflex.get_segments(lcontext, segments);
			IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
			  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'Retrieved Values from descriptive flex');
			END IF;
			IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
			  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'Number of values retrieved:'||segments.nsegments);
			END IF;

			FOR i IN 1 .. segments.nsegments LOOP

				if(l_count = 20) then
					EXIT;
				END IF;

				l_addr_prompts_array(i) := segments.segment_name(i);
				l_addr_col_names_array(i) := segments.application_column_name(i);
				l_count := l_count+1;

			END LOOP;

			/* Concatinate the column names separated by ',' */
			FOR i IN 1 .. 20 LOOP

				IF l_addr_col_names is NULL THEN
					l_addr_col_names := l_addr_col_names_array(i);
				ELSE
					l_addr_col_names := l_addr_col_names || ', '|| l_addr_col_names_array(i) ;

				END IF;

			END LOOP;

			-- Query to retrieve the address values from HR_LOCATIONS.
			l_addr_select_qry := 'select '|| l_addr_col_names || ' from hr_locations where location_id = :1 ' ;
			IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
			  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'select query:'||l_addr_select_qry);
			END IF;

		END IF;

		/* Assign the values to g_address_details PL/SQL table */
		l_table_count := l_table_count  + 1;
		g_address_details(l_table_count).location_id := p_location_id;
		g_address_details(l_table_count).address_style := l_style_code;
		g_address_details(l_table_count).addr_label_1 := l_addr_prompts_array(1);
		g_address_details(l_table_count).addr_label_2 := l_addr_prompts_array(2);
		g_address_details(l_table_count).addr_label_3 := l_addr_prompts_array(3);
		g_address_details(l_table_count).addr_label_4 := l_addr_prompts_array(4);
		g_address_details(l_table_count).addr_label_5 := l_addr_prompts_array(5);
		g_address_details(l_table_count).addr_label_6 := l_addr_prompts_array(6);
		g_address_details(l_table_count).addr_label_7 := l_addr_prompts_array(7);
		g_address_details(l_table_count).addr_label_8 := l_addr_prompts_array(8);
		g_address_details(l_table_count).addr_label_9 := l_addr_prompts_array(9);
		g_address_details(l_table_count).addr_label_10 := l_addr_prompts_array(10);
		g_address_details(l_table_count).addr_label_11 := l_addr_prompts_array(11);
		g_address_details(l_table_count).addr_label_12 := l_addr_prompts_array(12);
		g_address_details(l_table_count).addr_label_13 := l_addr_prompts_array(13);
		g_address_details(l_table_count).addr_label_14 := l_addr_prompts_array(14);
		g_address_details(l_table_count).addr_label_15 := l_addr_prompts_array(15);
		g_address_details(l_table_count).addr_label_16 := l_addr_prompts_array(16);
		g_address_details(l_table_count).addr_label_17 := l_addr_prompts_array(17);
		g_address_details(l_table_count).addr_label_18 := l_addr_prompts_array(18);
		g_address_details(l_table_count).addr_label_19 := l_addr_prompts_array(19);
		g_address_details(l_table_count).addr_label_20 := l_addr_prompts_array(20);


		--Add style code, address prompts array and select query to PL/SQL if the style code is not in PL/SQL table.
		IF l_style_code_exists <> 'Y' THEN
			l_addr_prompt_query_count :=  l_addr_prompt_query_count+1;
			g_addr_prompt_query(l_addr_prompt_query_count).address_style :=  l_style_code;

			-- Start bug#3622675
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_1 := l_addr_prompts_array(1) ;
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_2 := l_addr_prompts_array(2) ;
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_3 := l_addr_prompts_array(3) ;
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_4 := l_addr_prompts_array(4) ;
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_5 := l_addr_prompts_array(5) ;
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_6 := l_addr_prompts_array(6) ;
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_7 := l_addr_prompts_array(7) ;
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_8 := l_addr_prompts_array(8) ;
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_9 := l_addr_prompts_array(9) ;
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_10:= l_addr_prompts_array(10);
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_11:= l_addr_prompts_array(11);
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_12:= l_addr_prompts_array(12);
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_13:= l_addr_prompts_array(13);
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_14:= l_addr_prompts_array(14);
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_15:= l_addr_prompts_array(15);
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_16:= l_addr_prompts_array(16);
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_17:= l_addr_prompts_array(17);
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_18:= l_addr_prompts_array(18);
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_19:= l_addr_prompts_array(19);
			g_addr_prompt_query(l_addr_prompt_query_count).addr_label_20:= l_addr_prompts_array(20);
			-- End bug#3622675
			g_addr_prompt_query(l_addr_prompt_query_count).query := l_addr_select_qry;
		END IF;
		IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'Before executing the HR_LOCATIONS query');
		END IF;

		execute immediate l_addr_select_qry INTO g_address_details(l_table_count).addr_data_1, g_address_details(l_table_count).addr_data_2, g_address_details(l_table_count).addr_data_3,
			    g_address_details(l_table_count).addr_data_4, g_address_details(l_table_count).addr_data_5, g_address_details(l_table_count).addr_data_6,
			    g_address_details(l_table_count).addr_data_7, g_address_details(l_table_count).addr_data_8, g_address_details(l_table_count).addr_data_9,
			    g_address_details(l_table_count).addr_data_10, g_address_details(l_table_count).addr_data_11, g_address_details(l_table_count).addr_data_12,
			    g_address_details(l_table_count).addr_data_13, g_address_details(l_table_count).addr_data_14, g_address_details(l_table_count).addr_data_15,
			    g_address_details(l_table_count).addr_data_16, g_address_details(l_table_count).addr_data_17, g_address_details(l_table_count).addr_data_18,
			    g_address_details(l_table_count).addr_data_19, g_address_details(l_table_count).addr_data_20 USING p_location_id ;
		IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'After executing the HR_LOCATIONS query');
		END IF;



	END IF;


     Exception
       WHEN OTHERS then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'Exception while retrieving data from HR_LOCATIONS');
       END IF;
	x_address_line_1    := '';
        x_address_line_2    := '';
        x_address_line_3    := '';
        x_town_or_city      := '';
	x_state_or_province := '';
	x_postal_code       := '';
        x_territory_short_name := '';
	x_location_name := '';
        x_contact_phone := '';
        x_contact_fax := '';

     End; /* hr_locations */

   else

     /* If location id is null then select the address from hz_locations */
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'Before executing the HZ_LOCATIONS query');
          END IF;
     Begin
      /*Bug 5084855 Adding the NVL to get the Country value for Generic Address Style */
         SELECT
	           HLC.ADDRESS1,
	           HLC.ADDRESS2,
                   HLC.ADDRESS3,
	           HLC.CITY,
                   NVL(DECODE(HLC.county, NULL, HLC.state,
                           DECODE(FCL1.MEANING, NULL,
                                  DECODE(FCL2.MEANING, NULL,FCL3.MEANING, FCL2.LOOKUP_CODE),
                           FCL1.LOOKUP_CODE)), HLC.state)|| Decode (HLC.province, NULL , '', ', ' || HLC.province)  ,--bug10245785
                   HLC.POSTAL_CODE,
	            NVL(FTE.TERRITORY_SHORT_NAME, HLC.COUNTRY),
		   HLC.ADDRESS4,
		   ADDRESS_STYLE
        INTO
                   x_address_line_1 ,
		   x_address_line_2 ,
		   x_address_line_3 ,
		   x_town_or_city   ,
		   x_state_or_province,
		   x_postal_code,
		   x_territory_short_name,
		   x_address_line_4,
		   l_style_code
         FROM
		   HZ_LOCATIONS             HLC,
		   FND_TERRITORIES_TL       FTE,
   	 	   FND_LOOKUP_VALUES        FCL1,
   		   FND_LOOKUP_VALUES        FCL2,
   		   FND_LOOKUP_VALUES        FCL3
  	WHERE
  	 	HLC.LOCATION_ID  = p_location_id AND
 		HLC.COUNTRY = FTE.TERRITORY_CODE (+) AND
 		DECODE(FTE.TERRITORY_CODE, NULL, '1', FTE.LANGUAGE) =
                DECODE(FTE.TERRITORY_CODE, NULL, '1', USERENV('LANG')) AND
  		HLC.county = FCL1.LOOKUP_CODE (+) AND
  		HLC.COUNTRY || '_PROVINCE' = FCL1.LOOKUP_TYPE (+) AND
  		DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.SECURITY_GROUP_ID) =
                      DECODE(FCL1.LOOKUP_CODE, NULL, '1',
                           FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL1.LOOKUP_TYPE, FCL1.VIEW_APPLICATION_ID)) AND
  		DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.VIEW_APPLICATION_ID) =
                      DECODE(FCL1.LOOKUP_CODE, NULL, '1', 3) AND
 		DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.LANGUAGE) =
                      DECODE(FCL1.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
  		HLC.state = FCL2.LOOKUP_CODE (+) AND
 		HLC.COUNTRY || '_STATE' = FCL2.LOOKUP_TYPE (+) AND
   		DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.SECURITY_GROUP_ID) =
                      DECODE(FCL2.LOOKUP_CODE, NULL, '1',
                           FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL2.LOOKUP_TYPE, FCL2.VIEW_APPLICATION_ID)) AND
   		DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.VIEW_APPLICATION_ID) =
                      DECODE(FCL2.LOOKUP_CODE, NULL, '1', 3) AND
  		DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.LANGUAGE) =
                      DECODE(FCL2.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
  		HLC.county = FCL3.LOOKUP_CODE (+) AND
  		HLC.COUNTRY || '_COUNTY' = FCL3.LOOKUP_TYPE (+) AND
  		DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.SECURITY_GROUP_ID) =
                      DECODE(FCL3.LOOKUP_CODE, NULL, '1',
                           FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL3.LOOKUP_TYPE, FCL3.VIEW_APPLICATION_ID)) AND
   		DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.VIEW_APPLICATION_ID) =
                      DECODE(FCL3.LOOKUP_CODE, NULL, '1', 3) AND
  		DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.LANGUAGE) =
                      DECODE(FCL3.LOOKUP_CODE, NULL, '1', USERENV('LANG')) ;
		IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'After executing the HZ_LOCATIONS query');
		END IF;

		/* hz_locations table doesn't have columns for location code, phone and fax. */

		x_location_name := null;
		x_contact_phone :=null;
		x_contact_fax :=null;

		l_table_count := g_address_details.count; -- Number of rows in the PL/SQl table
		IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'l_table_count:'||l_table_count);
		END IF;

		/* Check whether the location id exists in g_address_details PL/SQL table.*/
		FOR i IN 1 .. l_table_count LOOP

			IF g_address_details(i).location_id = p_location_id THEN
				l_location_id_exists := 'Y';
				EXIT ;
			END IF;
		END LOOP;
		IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'l_location_id_exists:'||l_location_id_exists);
		END IF;

		IF l_location_id_exists <> 'Y' THEN

			l_table_count := l_table_count + 1;
			g_address_details(l_table_count).location_id := p_location_id;
			g_address_details(l_table_count).address_style := l_style_code;
						IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
						  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'p_location_id:'|| p_location_id);
						END IF;


			HZ_FORMAT_PUB.FORMAT_ADDRESS(p_location_id => p_location_id,
						-- output parameters
						x_return_status => x_return_status, x_msg_count => x_msg_count,
						x_msg_data => x_msg_data, x_formatted_address => x_formatted_address,
						x_formatted_lines_cnt => x_formatted_lines_cnt,
						x_formatted_address_tbl => x_formatted_address_tbl) ;
									IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
									  /* assign address values to l_addr_values_array list */

			FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'x_formatted_lines_cnt:'|| x_formatted_lines_cnt);
									END IF;


			IF x_formatted_lines_cnt > 0 THEN
				FOR i IN 1 .. x_formatted_lines_cnt
				LOOP
					l_addr_values_array(i) :=  x_formatted_address_tbl(i);
					IF (i = 20)  then
						EXIT;
					END IF;
				END LOOP;
			END IF;
					IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
					  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'Before adding HZ_LOCATIONS to PL/SQL tables');
					END IF;
			/* Assigning the values to global  PL/SQL table */
			g_address_details(l_table_count).addr_data_1 := l_addr_values_array(1);
			g_address_details(l_table_count).addr_data_2 := l_addr_values_array(2);
			g_address_details(l_table_count).addr_data_3 := l_addr_values_array(3);
			g_address_details(l_table_count).addr_data_4 := l_addr_values_array(4);
			g_address_details(l_table_count).addr_data_5 := l_addr_values_array(5);
			g_address_details(l_table_count).addr_data_6 := l_addr_values_array(6);
			g_address_details(l_table_count).addr_data_7 := l_addr_values_array(7);
			g_address_details(l_table_count).addr_data_8 := l_addr_values_array(8);
			g_address_details(l_table_count).addr_data_9 := l_addr_values_array(9);
			g_address_details(l_table_count).addr_data_10 := l_addr_values_array(10);
			g_address_details(l_table_count).addr_data_11 := l_addr_values_array(11);
			g_address_details(l_table_count).addr_data_12 := l_addr_values_array(12);
			g_address_details(l_table_count).addr_data_13 := l_addr_values_array(13);
			g_address_details(l_table_count).addr_data_14 := l_addr_values_array(14);
			g_address_details(l_table_count).addr_data_15 := l_addr_values_array(15);
			g_address_details(l_table_count).addr_data_16 := l_addr_values_array(16);
			g_address_details(l_table_count).addr_data_17 := l_addr_values_array(17);
			g_address_details(l_table_count).addr_data_18 := l_addr_values_array(18);
			g_address_details(l_table_count).addr_data_19 := l_addr_values_array(19);
			g_address_details(l_table_count).addr_data_20 := l_addr_values_array(20);
						IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
						  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'After adding HZ_LOCATIONS to PL/SQL tables');
						END IF;

	END IF;

       Exception
         WHEN OTHERS then
		IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head,  l_api_name ||'Exception in retrieving data from HZ_LOCATIONS');
		END IF;
		x_address_line_1    := '';
		x_address_line_2    := '';
		x_address_line_3    := '';
		x_town_or_city      := '';
		x_state_or_province := '';
		x_postal_code       := '';
		x_territory_short_name := '';
		x_location_name := '';
		x_contact_phone := '';
		x_contact_fax := '';
		x_address_line_4    := '';

     END; /* HZ_LOCATIONS */

 end if;

        If (x_town_or_city is null) then
           x_address_info := x_state_or_province||'  '|| x_postal_code;
        else
           x_address_info := x_town_or_city||', '||x_state_or_province||'  '||x_postal_code;
        end if;

 Exception
  /* If thers is any error null out all the fields */
   WHEN OTHERS THEN
        x_address_line_1    := '';
	x_address_line_2    := '';
	x_address_line_3    := '';
	x_town_or_city      := '';
	x_state_or_province := '';
	x_postal_code       := '';
	x_territory_short_name := '';
	x_location_name := '';
	x_contact_phone := '';
	x_contact_fax := '';
	x_address_line_4    := '';

END GET_ALLADDRESS_LINES;

/***********************************************************************************
  Procedure:populate_gt

  Why: As the function get_alladdress_lines is callled from the XML views,
	DML queries cannot be used in the select queries. The work around for this
	is populate the PL/SQL table when the function is called in the select query
	and then insert values into global temp table after selecting the values.

 Why Global temp table: XML cannot be  generated from global PL/SQL table.

***********************************************************************************/
PROCEDURE populate_gt is

	l_count number := 0;
begin

	l_count := g_address_details.count ;
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,'PO_HR_LOCATION',  'populate_gt Before inserting values in global temp table');
     END IF;
	FOR i IN 1..l_count   LOOP
		INSERT INTO po_address_details_gt
                    (location_id,
                    address_style,
                    addr_label_1,
                    addr_label_2,
                    addr_label_3,
                    addr_label_4,
                    addr_label_5,
                    addr_label_6,
                    addr_label_7,
                    addr_label_8,
                    addr_label_9,
                    addr_label_10,
                    addr_label_11,
                    addr_label_12,
                    addr_label_13,
                    addr_label_14,
                    addr_label_15,
                    addr_label_16,
                    addr_label_17,
                    addr_label_18,
                    addr_label_19,
                    addr_label_20,
                    addr_data_1,
                    addr_data_2,
                    addr_data_3,
                    addr_data_4,
                    addr_data_5,
                    addr_data_6,
                    addr_data_7,
                    addr_data_8,
                    addr_data_9,
                    addr_data_10,
                    addr_data_11,
                    addr_data_12,
                    addr_data_13,
                    addr_data_14,
                    addr_data_15,
                    addr_data_16,
                    addr_data_17,
                    addr_data_18,
                    addr_data_19,
                    addr_data_20)
             VALUES(
                    g_address_details(i).location_id,
                    g_address_details(i).address_style,
                    g_address_details(i).addr_label_1,
                    g_address_details(i).addr_label_2,
                    g_address_details(i).addr_label_3,
                    g_address_details(i).addr_label_4,
                    g_address_details(i).addr_label_5,
                    g_address_details(i).addr_label_6,
                    g_address_details(i).addr_label_7,
                    g_address_details(i).addr_label_8,
                    g_address_details(i).addr_label_9,
                    g_address_details(i).addr_label_10,
                    g_address_details(i).addr_label_11,
                    g_address_details(i).addr_label_12,
                    g_address_details(i).addr_label_13,
                    g_address_details(i).addr_label_14,
                    g_address_details(i).addr_label_15,
                    g_address_details(i).addr_label_16,
                    g_address_details(i).addr_label_17,
                    g_address_details(i).addr_label_18,
                    g_address_details(i).addr_label_19,
                    g_address_details(i).addr_label_20,
                    g_address_details(i).addr_data_1,
                    g_address_details(i).addr_data_2,
                    g_address_details(i).addr_data_3,
                    g_address_details(i).addr_data_4,
                    g_address_details(i).addr_data_5,
                    g_address_details(i).addr_data_6,
                    g_address_details(i).addr_data_7,
                    g_address_details(i).addr_data_8,
                    g_address_details(i).addr_data_9,
                    g_address_details(i).addr_data_10,
                    g_address_details(i).addr_data_11,
                    g_address_details(i).addr_data_12,
                    g_address_details(i).addr_data_13,
                    g_address_details(i).addr_data_14,
                    g_address_details(i).addr_data_15,
                    g_address_details(i).addr_data_16,
                    g_address_details(i).addr_data_17,
                    g_address_details(i).addr_data_18,
                    g_address_details(i).addr_data_19,
                    g_address_details(i).addr_data_20);
	end loop;
		     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,'PO_HR_LOCATION',  'populate_gt: After inserting values in global temp table');
		     END IF;

	g_address_details.delete;

	EXCEPTION
		WHEN OTHERS THEN
			IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
			  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,'PO_HR_LOCATION',  'populate_gt: Error while inserting values in global temp table');
			END IF;
end;

-----------------------------------------------------------
-- HTML Orders R12
-- Function : get_formatted_address
--
-- Description : Gets the concatenated address given the location
--
-- IN
-- p_location_id
--   HR or HZ location Id
-- Testing: None
--
------------------------------------------------------------
FUNCTION get_formatted_address(p_location_id IN NUMBER)
RETURN VARCHAR2
IS
l_address_line_1  Varchar2(240) := '';
l_address_line_2  Varchar2(240) := '';
l_address_line_3  Varchar2(240) := '';
l_territory       Varchar2(240);
l_address_info    Varchar2(2000);
l_address_lines   Varchar2(2000);
l_formatted_address Varchar2(2000);
l_location_name   Varchar2(240) := '';
l_contact_phone   Varchar2(240) := '';
l_contact_fax   Varchar2(240) := '';
l_address_line_4  Varchar2(240) := '';
l_town_or_city   Varchar2(240) := '';
l_postal_code   Varchar2(240) := '';
l_state_or_province Varchar2(240) := '';

BEGIN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,'PO_HR_LOCATION',  'Call the get_address procedure');
   END IF;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,'PO_HR_LOCATION',  'Location Id: '|| p_location_id);
   END IF;

   get_address
     (p_location_id       => p_location_id,
      x_address_line_1       => l_address_line_1,
      x_address_line_2       => l_address_line_2,
      x_address_line_3       => l_address_line_3,
      x_territory_short_name => l_territory,
      x_address_info         => l_address_info,
      x_location_name        => l_location_name,
      x_contact_phone	     =>	l_contact_phone,
      x_contact_fax	     =>	l_contact_fax,
      x_address_line_4	     => l_address_line_4,
      x_town_or_city	     => l_town_or_city,
      x_postal_code	     => l_postal_code,
      x_state_or_province    => l_state_or_province 	);

   if l_address_line_2  is not null then
      l_address_line_2 := l_address_line_2 ||', ';
   end if;

   if l_address_line_3  is not null then
      l_address_line_3 := l_address_line_3 ||', ';
   end if;

   if l_address_line_4  is not null then
      l_address_line_4 := l_address_line_4 ||', ';
   end if;

   l_address_lines := l_address_line_1 || ', ' || l_address_line_2 ||
                      l_address_line_3 || l_address_line_4;
   l_formatted_address := substrb(l_address_lines || l_address_info || ', '|| l_territory, 1,2000);
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,'PO_HR_LOCATION',
                      'Complete address: '|| l_formatted_address);
      END IF;

   Return l_formatted_address;

Exception
When Others then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,'PO_HR_LOCATION','Error in Retrieving address');
  END IF;
  l_formatted_address := null;
END;

END PO_HR_LOCATION;

/
