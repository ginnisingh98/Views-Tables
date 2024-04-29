--------------------------------------------------------
--  DDL for Package Body HZ_FORMAT_PHONE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_FORMAT_PHONE_V2PUB" AS
/*$Header: ARHPHFMB.pls 120.9 2006/02/09 07:03:13 vravicha noship $ */


--------------------------------------
-- declaration of private global types and varibles
--------------------------------------

TYPE num_indexed_table IS TABLE OF VARCHAR2(400) INDEX BY BINARY_INTEGER;
TYPE var_indexed_table IS TABLE OF VARCHAR2(400) INDEX BY VARCHAR2(30);
TYPE var_indexed_num_table IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
TYPE var_table IS TABLE OF VARCHAR(30);
TYPE num_table IS TABLE OF NUMBER;

-- cache party preference
pref_user_territory_code_tab      num_indexed_table;
pref_default_area_code_tab        num_indexed_table;
pref_display_area_code_tab        num_indexed_table;
pref_display_all_prefix_tab       num_indexed_table;
pref_pabx_prefix_tab              num_indexed_table;

-- cache phone country codes based on territory
terr_phone_country_tab            var_indexed_table;
terr_intl_prefix_tab              var_indexed_table;
terr_trunk_prefix_tab             var_indexed_table;

-- cache territory codes via phone country code
phone_territory_tab               var_indexed_table;

-- cache phone formats
format_style_tab                  var_indexed_table;
format_area_code_size_tab         var_indexed_num_table;
format_phone_country_tab          var_indexed_table;

g_debug_count                     NUMBER := 0;
g_international_flag              VARCHAR2(1):= fnd_api.g_miss_char;
g_user_territory_code             HZ_PHONE_COUNTRY_CODES.TERRITORY_CODE%TYPE:=
                                    fnd_api.g_miss_char;
g_user_phone_country_code         HZ_PHONE_COUNTRY_CODES.PHONE_COUNTRY_CODE%TYPE :=
                                    fnd_api.g_miss_char;

--------------------------------------
-- declaration of private procedures
--------------------------------------

PROCEDURE get_user_phone_preferences (
    p_customer_id                 IN     VARCHAR2,
    x_user_phone_preferences_rec  OUT    NOCOPY user_phone_preferences_rec
);

PROCEDURE cache_phone_country_via_terr (
    p_territory_code              IN     VARCHAR2,
    x_phone_country_code          OUT    NOCOPY VARCHAR2,
    x_trunk_prefix                OUT    NOCOPY VARCHAR2,
    x_intl_prefix                 OUT    NOCOPY VARCHAR2
);

PROCEDURE cache_terr_via_phone_country (
    p_phone_country_code          IN     VARCHAR2,
    x_phone_territory_code        OUT    NOCOPY VARCHAR2
);

PROCEDURE get_phone_format (
    p_raw_phone_number            IN     VARCHAR2 := fnd_api.g_miss_char,
    p_territory_code              IN     VARCHAR2 := fnd_api.g_miss_char,
    p_area_code                   IN     VARCHAR2,
    x_phone_country_code          OUT    NOCOPY VARCHAR2,
    x_phone_format_style          OUT    NOCOPY VARCHAR2,
    x_area_code_size              OUT    NOCOPY NUMBER,
    x_msg                         OUT    NOCOPY VARCHAR2
);

PROCEDURE parse_intl_prefix(
          p_with_iprefix     IN VARCHAR2 := fnd_api.g_miss_char,
          p_territory_code   IN VARCHAR2 := fnd_api.g_miss_char,
          x_intl_prefix      OUT NOCOPY VARCHAR2,
          x_without_iprefix  OUT NOCOPY VARCHAR2) ;

PROCEDURE parse_trunk_prefix(
          p_with_tprefix     IN VARCHAR2 := fnd_api.g_miss_char,
          p_territory_code   IN VARCHAR2 := fnd_api.g_miss_char,
          x_trunk_prefix     OUT NOCOPY VARCHAR2,
          x_without_tprefix  OUT NOCOPY VARCHAR2);

PROCEDURE parse_country_code(
          p_with_country_code     IN VARCHAR2 := fnd_api.g_miss_char,
          x_country_code          OUT NOCOPY VARCHAR2,
          x_without_country_code  OUT NOCOPY VARCHAR2);

PROCEDURE parse_area_code(
          p_with_area_code      IN VARCHAR2 := fnd_api.g_miss_char,
          p_phone_country_code  IN VARCHAR2 := fnd_api.g_miss_char,
          x_parsed_area_code    OUT NOCOPY VARCHAR2,
          x_parsed_phone_number OUT NOCOPY VARCHAR2 ) ;

FUNCTION filter_phone_number (
    p_phone_number           IN     VARCHAR2,
    p_isformat               IN     NUMBER := 0
) RETURN VARCHAR2;

PROCEDURE translate_raw_phone_number (
    p_raw_phone_number       IN     VARCHAR2 := fnd_api.g_miss_char,
    p_phone_format_style     IN     VARCHAR2 := fnd_api.g_miss_char,
    x_formatted_phone_number OUT    NOCOPY VARCHAR2
);

--
  -- PROCEDURE phone_parse
  --
  -- DESCRIPTION
  --      parses a phone number
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list       Initialize message stack if it is set to
  --                           FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_raw_phone_number    Raw phone number.
  --     p_territory_code      Optional parameter for supplying the
  --                           territory code of the Phone No.
  --   OUT:
  --     x_phone_country_code  Phone country code.
  --     x_phone_area_code     Phone area code.
  --     x_phone_number        Phone number.
  --     x_mobile_flag         Flag indicating if the Number is mobile
  --     x_return_status       Return status after the call. The status can
  --                           be fnd_api.g_ret_sts_success (success),
  --                           fnd_api.g_ret_sts_error (error),
  --                           fnd_api.g_ret_sts_unexp_error
  --                           (unexpected error).
  --     x_msg_count           Number of messages in message stack.
  --     x_msg_data            Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-10-2002    Jyoti Pandey      o Created.
  --
  --

PROCEDURE phone_parse (
    p_init_msg_list           IN     VARCHAR2 := fnd_api.g_false,
    p_raw_phone_number        IN     VARCHAR2 := fnd_api.g_miss_char,
    p_territory_code          IN     VARCHAR2 := fnd_api.g_miss_char,
    x_phone_country_code      OUT NOCOPY VARCHAR2,
    x_phone_area_code         OUT NOCOPY VARCHAR2,
    x_phone_number            OUT NOCOPY VARCHAR2,
    x_mobile_flag             OUT NOCOPY VARCHAR2,
    x_return_status           OUT    NOCOPY VARCHAR2,
    x_msg_count               OUT    NOCOPY NUMBER,
    x_msg_data                OUT    NOCOPY VARCHAR2
  ) IS
    l_customer_id             NUMBER;
    x_user_phone_preferences_rec user_phone_preferences_rec;

    i_territory_code         HZ_PHONE_COUNTRY_CODES.TERRITORY_CODE%TYPE;
    lp_phone_country_code    HZ_CONTACT_POINTS.PHONE_country_code%TYPE;
    l_phone_area_code        HZ_PHONE_AREA_CODES.AREA_CODE%TYPE;
    l_phone_number           HZ_CONTACT_POINTS.PHONE_NUMBER%TYPE;

    l_filtered_number        HZ_CONTACT_POINTS.RAW_PHONE_NUMBER%TYPE;
    l_raw_phone_number       HZ_CONTACT_POINTS.RAW_PHONE_NUMBER%TYPE;

    l_phone_format_style     HZ_PHONE_FORMATS.PHONE_FORMAT_STYLE%TYPE;
    l_filtered_phone_format_style   HZ_PHONE_FORMATS.PHONE_FORMAT_STYLE%TYPE;
    l_length_style           NUMBER;
    l_length_matches         VARCHAR2(1);
    l_initial_sign           VARCHAR2(1);

    l_p_country_code_check   VARCHAR2(20);
    l_length_cntry_code      NUMBER;

    x_intl_prefix            VARCHAR2(5);
    x_without_intl_prefix    HZ_CONTACT_POINTS.RAW_PHONE_NUMBER%TYPE;
    x_trunk_prefix           VARCHAR2(5);
    x_without_trunk_prefix   HZ_CONTACT_POINTS.RAW_PHONE_NUMBER%TYPE;

    x_parsed_country_code    HZ_PHONE_COUNTRY_CODES.PHONE_COUNTRY_CODE%TYPE;
    x_without_country_code   HZ_CONTACT_POINTS.RAW_PHONE_NUMBER%TYPE;

    x_parsed_area_code       HZ_PHONE_AREA_CODES.AREA_CODE%TYPE;
    x_parsed_phone_number    HZ_CONTACT_POINTS.PHONE_NUMBER%TYPE;

    l_msg_name               VARCHAR2(50) := NULL;
    l_msg_count              NUMBER :=0;
    l_msg_data               VARCHAR2(2000):= NULL;

     CURSOR c_phone_country_code(i_territory_code varchar2) IS
      SELECT phone_country_code
      FROM   hz_phone_country_codes
      WHERE  territory_code = i_territory_code;

     CURSOR c_get_format_length IS
     SELECT PHONE_FORMAT_STYLE
     FROM  hz_phone_formats
     WHERE  territory_code = g_user_territory_code;
    l_debug_prefix            VARCHAR2(30) := '';

BEGIN

    --SAVEPOINT

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'phone_parse (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- Check if raw phone number is passed
    IF p_raw_phone_number IS NOT NULL AND
       p_raw_phone_number <> fnd_api.g_miss_char THEN
       l_raw_phone_number := p_raw_phone_number;
    END IF;


 /*--------------------------------------------------------
  1: Strip out punctuation and spaces  except + sign
  --------------------------------------------------------*/

l_filtered_number := TRANSLATE (
l_raw_phone_number,
'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz()- .''~`\/@#$%^*_,|}{[]?<>=";:',
'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz');

---Check if the first character is the + sign
if SUBSTR(l_filtered_number,1,1) = '+' then
    ---set the initial sign as it is potentially an international number
   l_initial_sign := 'Y';

end if;

---Remove all the occurances of the + sign
l_filtered_number := filter_phone_number (l_filtered_number);

    /*--------------------------------------------------------
     2: Get the user's territory code
     --------------------------------------------------------*/
    l_customer_id :=   fnd_global.customer_id;

    IF l_customer_id IS NOT NULL THEN
      get_user_phone_preferences (
        l_customer_id,
        x_user_phone_preferences_rec);
    END IF;

g_user_territory_code:= x_user_phone_preferences_rec.user_territory_code;

IF g_user_territory_code is not null THEN
    --- Get the user's phone country code based on the territory code
     OPEN c_phone_country_code(g_user_territory_code);
     FETCH c_phone_country_code INTO g_user_phone_country_code;
       IF c_phone_country_code%NOTFOUND THEN
          g_user_phone_country_code := NULL;
       END IF;
     CLOSE c_phone_country_code;
END IF;     ----g_user_territory_code is not null

 /*----------------------------------------------------------------------
 3: Check if the p_territory_code was passed
      if it was passed then just the area code needs to parsed
         g_international_flag='N'
      else try to set g_international_flag by parsing intl or trunk prefix
  ---------------------------------------------------------------------*/
IF p_territory_code is not null THEN
    --- Get the phone country code of the input number
     OPEN c_phone_country_code(p_territory_code);
     FETCH c_phone_country_code INTO lp_phone_country_code;
       IF c_phone_country_code%NOTFOUND THEN
          lp_phone_country_code := NULL;
       END IF;
     CLOSE c_phone_country_code;
ELSE
      lp_phone_country_code:= NULL;
END IF;

IF lp_phone_country_code IS NOT NULL AND
   lp_phone_country_code <> fnd_api.g_miss_char THEN

   --Do not need to parse the country code
   g_international_flag  := 'N';

   --filter off the trunk/international prefix if present

       PARSE_INTL_PREFIX(l_filtered_number,
       nvl(g_user_territory_code,p_territory_code),
       x_intl_prefix,
       x_without_intl_prefix);

       if x_intl_prefix is null then
               PARSE_TRUNK_PREFIX(l_filtered_number,
               nvl(g_user_territory_code,p_territory_code),
               x_trunk_prefix,
               x_without_trunk_prefix);

           l_filtered_number := x_without_trunk_prefix;
        else

           l_filtered_number := x_without_intl_prefix;

       end if;

   --filter off the country code from the number if present
   l_length_cntry_code := LENGTH(lp_phone_country_code);
   l_p_country_code_check:=SUBSTR(l_filtered_number,1,l_length_cntry_code);

   if l_p_country_code_check = lp_phone_country_code then

      ---chop off the cntry code from i/p no.
      l_filtered_number :=
      SUBSTR(l_filtered_number ,l_length_cntry_code+1 ,
             LENGTH(l_filtered_number));
   end if;

   ---set the i/p parameters required for parse_area_code API
   x_parsed_country_code :=  lp_phone_country_code;
   x_without_country_code := l_filtered_number;

ELSE  ---lp_phone_country_code is null (no territory_code)

       PARSE_INTL_PREFIX(l_filtered_number,
       nvl(g_user_territory_code,p_territory_code),
       x_intl_prefix,
       x_without_intl_prefix);

       if x_intl_prefix is not null then
          g_international_flag := 'Y';
       else                    ---if x_intl_prefix could not be parsed

          if   l_initial_sign = 'Y' then  --check if there was a + sign
               g_international_flag := 'Y';
               x_without_intl_prefix := l_filtered_number;
          else                 ---neither x_intl_prefix was parsed nor +

               PARSE_TRUNK_PREFIX(l_filtered_number,
               g_user_territory_code,
               x_trunk_prefix,
               x_without_trunk_prefix);

               if x_trunk_prefix is not null then
                  g_international_flag := 'N';
                  x_without_country_code := x_without_trunk_prefix;
                  x_parsed_country_code := g_user_phone_country_code;
               else
                  g_international_flag := NULL;
               end if;
           end if;
        end if;

END IF ;   ---lp_phone_country_code

 /*----------------------------------------------------------------------
 4: Based on g_international_flag ,parse country_code and/or area_code
  ----------------------------------------------------------------------*/
  IF g_international_flag = 'Y'THEN ---if intl_prefix was parsed

     parse_country_code(
     x_without_intl_prefix,
     x_parsed_country_code,
     x_without_country_code  );

     parse_area_code(
     x_without_country_code,
     x_parsed_country_code,
     x_parsed_area_code,
     x_parsed_phone_number);

     x_phone_country_code := x_parsed_country_code;
     x_phone_area_code := x_parsed_area_code;
     x_phone_number    := x_parsed_phone_number;

  ELSIF g_international_flag = 'N'THEN ---if trunk_prefix was parsed

     parse_area_code(
     x_without_country_code,
     x_parsed_country_code,
     x_parsed_area_code,
     x_parsed_phone_number);
     x_phone_country_code := x_parsed_country_code;
     x_phone_area_code    := x_parsed_area_code;
     x_phone_number       := x_parsed_phone_number;

  ELSE

    begin
       ----first treat the number as international number
          parse_country_code(
          l_filtered_number,
          x_parsed_country_code,
          x_without_country_code  );

          parse_area_code(
          x_without_country_code,
          x_parsed_country_code,
          x_parsed_area_code,
          x_parsed_phone_number);

          IF( (x_parsed_area_code IS NOT NULL)  AND
              (x_parsed_country_code IS NOT NULL) ) THEN
               x_phone_country_code := x_parsed_country_code;
               x_phone_area_code    := x_parsed_area_code;
               x_phone_number       := x_parsed_phone_number;
          ELSE   ---if could not parse the country and area code
               x_phone_area_code    := NULL;
               x_phone_number       := l_filtered_number;
          END IF;

      end;
    END IF; ---g_international_flag

   HZ_FORMAT_PHONE_V2PUB.check_mobile_phone (
     'T',
     x_parsed_country_code,
     x_parsed_area_code,
     x_parsed_phone_number,
     x_mobile_flag,
     x_return_status ,
     x_msg_count ,
     x_msg_data   );


    -- Standard call to get msg count and if count is 1, get msg info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'phone_format (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'phone_format (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

       -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'phone_format (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'phone_format (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

END;
--
  -- PROCEDURE phone_display
  --
  -- DESCRIPTION
  --      displays a phone number
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list       Initialize message stack if it is set to
  --                           FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_id    Contact point id of TYPE PHONE
  --                           territory code of the Phone No.
  --   OUT:
  --     x_formatted_number    Number formatted acc. to defaults set in
  --                           HZ_PHONE_FORMATS or default format
  --     x_return_status       Return status after the call. The status can
  --                           be fnd_api.g_ret_sts_success (success),
  --                           fnd_api.g_ret_sts_error (error),
  --                           fnd_api.g_ret_sts_unexp_error
  --                           (unexpected error).
  --     x_msg_count           Number of messages in message stack.
  --     x_msg_data            Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-10-2002    Jyoti Pandey   o Created.
  --   07-01-2002    V.Srinivasan   Bug 2415007: Handled "No Data Found" error
  --                                whenever the contact point id passed is
  --                                invalid.
  --   11-03-2005    Idris Ali      o Bug 4578945: changed the procedure to return null when the area_code
  --                                country_code and phone_number are all null.
  --
  --
--

 PROCEDURE phone_display(
    p_init_msg_list          IN VARCHAR2 := fnd_api.g_false,
    p_contact_point_id       IN NUMBER,
    x_formatted_phone_number OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2 ) IS

    x_phone_format_style    HZ_PHONE_FORMATS.PHONE_FORMAT_STYLE%TYPE;
    l_default_prefix        VARCHAR2(30) := ''; -- get_phone_format
    l_empty                 BOOLEAN;

    CURSOR c_territory(p_country_code VARCHAR2) IS
    SELECT territory_code
    FROM   hz_phone_country_codes
    WHERE  phone_country_code = p_country_code;

    l_customer_id            NUMBER;
    l_phone_format_style     hz_phone_formats.phone_format_style%TYPE;
    l_phone_country_code     hz_phone_country_codes.phone_country_code%TYPE;
    l_raw_phone_number       HZ_CONTACT_POINTS.raw_phone_number%type;
    --3865843
    l_formatted_phone_number VARCHAR2(120);

    l_format_cntry_code      hz_phone_country_codes.phone_country_code%TYPE;

    --User Preferences
    x_user_phone_preferences_rec    user_phone_preferences_rec;
    l_user_country_code     HZ_CONTACT_POINTS.PHONE_COUNTRY_CODE%TYPE;
    l_user_territory_code   HZ_PHONE_FORMATS.TERRITORY_CODE%TYPE;
    l_default_area_code     HZ_CONTACT_POINTS.PHONE_AREA_CODE%TYPE;
    l_display_area_code     VARCHAR2(1);
    l_display_all_prefixes  VARCHAR2(1);
    l_pabx_prefix           VARCHAR2(1);

    l_phone_intl_prefix     HZ_PHONE_COUNTRY_CODES.INTL_PREFIX%TYPE;
    l_phone_trunk_prefix    HZ_PHONE_COUNTRY_CODES.TRUNK_PREFIX%TYPE;
    l_prefix                VARCHAR2(1) := null;

    l_msg_name              VARCHAR2(100):= NULL;
    l_area_code_size        NUMBER;
    l_contact_point_type    HZ_CONTACT_POINTS.CONTACT_POINT_TYPE%TYPE;
    l_phone_area_code       HZ_CONTACT_POINTS.PHONE_AREA_CODE%TYPE;
    l_phone_number          HZ_CONTACT_POINTS.PHONE_NUMBER%TYPE;
    l_phone_territory_code  HZ_PHONE_FORMATS.TERRITORY_CODE%TYPE;
    l_default_format          VARCHAR2(1):= 'N';
    l_debug_prefix                     VARCHAR2(30) := '';
    --3865843
    l_formatted_phone_area_code        VARCHAR2(12);

    x_area_code_size        NUMBER;

  BEGIN

    -- standard start of API savepoint
    -- SAVEPOINT phone_display;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'phone_display (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Initialize return variables
    x_phone_format_style := fnd_api.g_miss_char;

    --If the contact_point_is of wrong type raise the error
     BEGIN
        select contact_point_type
        into   l_contact_point_type
        from   HZ_CONTACT_POINTS
        where  CONTACT_POINT_ID = p_contact_point_id;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'Contact Point');
        fnd_message.set_token('VALUE', TO_CHAR(p_contact_point_id));
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END ;


      IF l_contact_point_type <> 'PHONE' THEN
         fnd_message.set_name('AR', 'HZ_WRONG_CONTACT_POINT_TYPE');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
      END IF;

    /*--------------------------------------------------------
     Get the user preferences
     --------------------------------------------------------*/

    l_customer_id :=   fnd_global.customer_id;

    IF l_customer_id IS NOT NULL THEN
      get_user_phone_preferences(
        l_customer_id,
        x_user_phone_preferences_rec);
    END IF;

 l_user_territory_code := x_user_phone_preferences_rec.user_territory_code;
 l_default_area_code   := x_user_phone_preferences_rec.default_area_code;
 l_display_area_code   := x_user_phone_preferences_rec.display_area_code;
 l_display_all_prefixes:= x_user_phone_preferences_rec.display_all_prefixes;
 l_pabx_prefix         := x_user_phone_preferences_rec.pabx_prefix;


  ---based on user's territory code get the phone_country_code
  ---for comparision

   if l_user_territory_code is not null then
        select phone_country_code , intl_prefix, trunk_prefix
        into l_user_country_code, l_phone_intl_prefix, l_phone_trunk_prefix
        from hz_phone_country_codes
        where territory_code = l_user_territory_code;
     else
        l_user_country_code := null;
     end if;

   ---Get the phone number info from the contact_point_id
    BEGIN
            select  phone_country_code,phone_area_code, phone_number
            into    l_phone_country_code ,l_phone_area_code, l_phone_number
            from    HZ_CONTACT_POINTS
            where   CONTACT_POINT_ID = p_contact_point_id
            and     CONTACT_POINT_TYPE = 'PHONE';
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'Contact Point');
        fnd_message.set_token('VALUE', TO_CHAR(p_contact_point_id));
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END ;

  IF l_phone_area_code IS NULL OR
     l_phone_area_code = fnd_api.g_miss_char THEN
     l_raw_phone_number := filter_phone_number(l_phone_number);
  ELSE
     l_raw_phone_number := filter_phone_number(l_phone_area_code ||
                                               l_phone_number);
 END IF;

  ---IN NAMP all the participating countries will have same country_code
  ---e.g. US , Canada they will have similar format styles
  ---GET the Phone number's territory from the phone_country_code

    if l_phone_country_code is  null then
        l_formatted_phone_number := null;
    else
       begin
          select pc.territory_code
          into  l_phone_territory_code
          from hz_phone_country_codes pc
          where phone_country_code = l_phone_country_code
          AND exists (select phone_format_style
                     from hz_phone_formats pf
                     where pf.territory_code = pc.territory_code)
          AND rownum =1;

        exception
        when no_data_found then
        l_formatted_phone_number := NULL;

        end;

           if l_phone_territory_code is not null then
            -- Call subroutine to get the format style to be
            --applied for the given raw phone number and territory

            get_phone_format(
               p_raw_phone_number            => l_raw_phone_number,
               p_territory_code              => l_phone_territory_code,
               p_area_code                   => l_phone_area_code,
               x_phone_country_code          => l_format_cntry_code,
               x_phone_format_style          => l_phone_format_style,
               x_area_code_size              => l_area_code_size,
               x_msg                         => l_msg_name);

           if l_phone_format_style is not null then
             -- Apply the format style and get translated number
             translate_raw_phone_number (
             p_raw_phone_number           => l_raw_phone_number,
             p_phone_format_style         => l_phone_format_style,
             x_formatted_phone_number     => l_formatted_phone_number);
           else
             l_formatted_phone_number := null;
           end if;

          end if;   ---l_phone_territory_code is not null
        end if;     --l_phone_countey_code is not null

           if l_formatted_phone_number is null then
              l_default_format := 'Y';
           end if;

           IF l_default_format = 'Y' then

             if l_phone_area_code is null then
	     --3865843
                l_formatted_phone_area_code := '';
             else l_formatted_phone_area_code := '('||l_phone_area_code|| ')';
             end if;

             l_phone_number := filter_phone_number(l_phone_number);
             l_formatted_phone_number := l_formatted_phone_area_code||l_phone_number;

           END IF;


            -- Append country code if user's country is different
            --than the phone_country
            IF ((l_phone_country_code  <> l_user_country_code) OR
               (l_user_country_code IS NULL))
            THEN
              IF l_phone_country_code IS NOT NULL AND
                 l_phone_country_code <> fnd_api.g_miss_char    --Bug 4578945
              THEN
                IF l_display_all_prefixes = 'Y' THEN
                 l_formatted_phone_number := l_phone_country_code ||' '||l_formatted_phone_number;
                ELSE
                 l_formatted_phone_number := '+'||l_phone_country_code ||' '||l_formatted_phone_number;
                END IF;
                l_prefix := 'I';
              ELSE
                l_prefix := null;
              END IF;


            elsif l_phone_country_code = l_user_country_code THEN

            ---check if the user's area code is same as phone's area code
               IF (   (l_phone_area_code    = l_default_area_code)
                  AND (l_DISPLAY_AREA_CODE = 'N' )  ) THEN
                   l_formatted_phone_number := l_phone_number;
               ELSE

                  if l_phone_area_code  is not null
                 and l_phone_area_code <> fnd_api.g_miss_char
                 then
                    l_prefix := 'T';
                 else
                    l_prefix := null;
                 end if; ---l_phone_area_code is not null
               END IF;   ---l_phone_area_code=l_default_area_code
            end if;      ---l_phone_country_code=l_user_country_code

           --Check the DISPLAY_ALL_PREFIXES flag
           --if set then check pabx prefix
           if l_display_all_prefixes = 'Y' AND
              l_formatted_phone_number IS NOT NULL THEN    --Bug 4578945
              if  l_prefix = 'I' then
                  l_formatted_phone_number := l_phone_intl_prefix||' '||
                                               l_formatted_phone_number;
              elsif  l_prefix = 'T' then
                  l_formatted_phone_number := l_phone_trunk_prefix||' '||
                                              l_formatted_phone_number;
              end if;

               ---append the user's PABX prefix if user has set it up
               if l_pabx_prefix is not null then
                   l_formatted_phone_number := l_pabx_prefix||' '||
                                           l_formatted_phone_number;
               end if;

            end if;

     x_formatted_phone_number := l_formatted_phone_number;

     -- Standard call to get msg count and if count is 1, get msg info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'phone_display (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'phone_display (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'phone_display (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'phone_display (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

  END phone_display;

--
  -- PROCEDURE phone_display
  --
  -- DESCRIPTION
  --      displays a phone number
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list       Initialize message stack if it is set to
  --                           FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_territory_code      Optional parameter for supplying the
  --                           territory code of the Phone No.
  --     p_phone_country code  Country code of the phone number
  --     p_phone_area_code     Area code
  --     p_phone_number        Phone Number
  --
  --   OUT:
  --     x_formatted_number    Number formatted acc. to defaults set in
  --                           HZ_PHONE_FORMATS or default format
  --     x_return_status       Return status after the call. The status can
  --                           be fnd_api.g_ret_sts_success (success),
  --                           fnd_api.g_ret_sts_error (error),
  --                           fnd_api.g_ret_sts_unexp_error
  --                           (unexpected error).
  --     x_msg_count           Number of messages in message stack.
  --     x_msg_data            Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-10-2002    Jyoti Pandey      o Created.
  --   10-20-2005    Idris Ali         o Bug 4578945:modified procedure such that x_formatted_phone_number
  --                                     should have a null value when p_territory_code,p_phone_country_code,
  --                                     p_phone_area_code,p_phone_number are null.
  --

PROCEDURE phone_display(
    p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false,
    p_territory_code              IN     VARCHAR2 := fnd_api.g_miss_char,
    p_phone_country_code          IN     VARCHAR2 := fnd_api.g_miss_char,
    p_phone_area_code             IN     VARCHAR2 := fnd_api.g_miss_char,
    p_phone_number                IN     VARCHAR2 := fnd_api.g_miss_char,
    x_formatted_phone_number      OUT    NOCOPY VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    l_default_prefix              VARCHAR2(30) := ''; -- get_phone_format
    x_phone_format_style          HZ_PHONE_FORMATS.PHONE_FORMAT_STYLE%TYPE;
    l_phone_country_code          HZ_CONTACT_POINTS.PHONE_COUNTRY_CODE%TYPE;
    l_phone_area_code             HZ_CONTACT_POINTS.PHONE_AREA_CODE%TYPE;
    l_phone_number                HZ_CONTACT_POINTS.PHONE_NUMBER%TYPE;
    l_customer_id                 NUMBER;
    --3865843
    l_formatted_phone_area_code   VARCHAR2(12);
    --User Preferences
    x_user_phone_preferences_rec  user_phone_preferences_rec := NULL;
    l_user_territory_code         HZ_PHONE_FORMATS.TERRITORY_CODE%TYPE;
    l_default_area_code           HZ_CONTACT_POINTS.PHONE_AREA_CODE%TYPE;
    l_display_area_code           VARCHAR2(1);
    l_display_all_prefixes        VARCHAR2(1);
    l_pabx_prefix                 VARCHAR2(1);
    l_user_country_code           HZ_CONTACT_POINTS.PHONE_COUNTRY_CODE%TYPE;
    l_phone_intl_prefix           HZ_PHONE_COUNTRY_CODES.INTL_PREFIX%TYPE;
    l_phone_trunk_prefix          HZ_PHONE_COUNTRY_CODES.TRUNK_PREFIX%TYPE;
    l_raw_phone_number            HZ_CONTACT_POINTS.raw_phone_number%type;
    l_phone_territory_code        HZ_PHONE_FORMATS.TERRITORY_CODE%TYPE;
    l_msg_name                    VARCHAR2(100):= NULL;
    l_area_code_size              NUMBER;
    l_format_cntry_code           hz_phone_country_codes.phone_country_code%TYPE;
    l_phone_format_style          hz_phone_formats.phone_format_style%TYPE;
    l_empty                       BOOLEAN;
    --3865843
    l_formatted_phone_number      VARCHAR2(120);
    l_prefix                      VARCHAR2(1);
    x_area_code_size              NUMBER;
    p_default_format              VARCHAR2(1):= 'N';
    l_debug_prefix                VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message                 => 'phone_display (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize return variables
    x_phone_format_style := fnd_api.g_miss_char;

    IF p_phone_country_code <> fnd_api.g_miss_char THEN
      l_phone_country_code := p_phone_country_code;
    END IF;
    IF p_phone_area_code <> fnd_api.g_miss_char THEN
      l_phone_area_code := p_phone_area_code;
    END IF;
    IF p_phone_number <> fnd_api.g_miss_char THEN
      l_phone_number := p_phone_number;
    END IF;

    -- Get the user preferences

    l_customer_id :=   fnd_global.customer_id;

    IF l_customer_id IS NOT NULL THEN
      get_user_phone_preferences(
        l_customer_id,
        x_user_phone_preferences_rec);
    END IF;

    l_user_territory_code := x_user_phone_preferences_rec.user_territory_code;
    l_default_area_code   := x_user_phone_preferences_rec.default_area_code;
    l_display_area_code   := x_user_phone_preferences_rec.display_area_code;
    l_display_all_prefixes:= x_user_phone_preferences_rec.display_all_prefixes;
    l_pabx_prefix         := x_user_phone_preferences_rec.pabx_prefix;

    ---based on user's territory code get the user's phone_country_code
    ---for comparision

    IF l_user_territory_code IS NOT NULL THEN
      cache_phone_country_via_terr(
        l_user_territory_code,
        l_user_country_code,
        l_phone_trunk_prefix,
        l_phone_intl_prefix);
    ELSE
      l_user_country_code := null;
    END IF;

    IF l_phone_area_code IS NULL OR
       l_phone_area_code = fnd_api.g_miss_char
    THEN
      l_raw_phone_number := filter_phone_number(l_phone_number);
    ELSE
      l_raw_phone_number := filter_phone_number(l_phone_area_code || l_phone_number);
    END IF;

    ---IN NAMP all the participating countries will have same country_code
    ---e.g. US , Canada they will have similar format styles
    ---GET the Phone number's territory from the phone_country_code

    IF p_territory_code IS NOT NULL AND
       p_territory_code <> fnd_api.g_miss_char
    THEN
      l_phone_territory_code := p_territory_code;
    ELSE
      IF l_phone_country_code IS NOT NULL THEN
        cache_terr_via_phone_country (
          l_phone_country_code,
          l_phone_territory_code
        );
      ELSE
        l_phone_territory_code:= null;
      END IF;
    END IF;

    IF l_phone_territory_code IS NULL THEN  --no territory found
      l_formatted_phone_number := null;
    ELSE
      -- Call subroutine to get the format style to be applied
      --for the given raw phone number and territory

      get_phone_format(
        p_raw_phone_number        => l_raw_phone_number,
        p_territory_code          => l_phone_territory_code,
        p_area_code               => p_phone_area_code,
        x_phone_country_code      => l_format_cntry_code,
        x_phone_format_style      => l_phone_format_style,
        x_area_code_size          => l_area_code_size,
        x_msg                     => l_msg_name);

      IF l_phone_format_style IS NOT NULL THEN
        -- Apply the format style and get translated number
        translate_raw_phone_number (
          p_raw_phone_number           => l_raw_phone_number,
          p_phone_format_style         => l_phone_format_style,
          x_formatted_phone_number     => l_formatted_phone_number);
      ELSE
        l_formatted_phone_number := null;
      END IF;
    END IF;

    IF l_formatted_phone_number IS NULL THEN
      p_default_format := 'Y';
    END IF;

    IF p_default_format = 'Y' THEN
      IF l_phone_area_code IS NULL THEN
        --3865843
        l_formatted_phone_area_code := '';
      ELSE
        l_formatted_phone_area_code :='('||l_phone_area_code|| ')';
      END IF;

      l_phone_number := filter_phone_number(l_phone_number);
      l_formatted_phone_number := l_formatted_phone_area_code||l_phone_number;
    END IF;

    -- Append country code if user's country is different
    --than the phone_country

    IF ((l_phone_country_code  <> l_user_country_code) OR
        (l_user_country_code IS NULL))
    THEN
      IF l_phone_country_code IS NOT NULL AND
         l_phone_country_code <> fnd_api.g_miss_char    --Bug 4578945
      THEN
        IF l_display_all_prefixes = 'Y' THEN
          l_formatted_phone_number := l_phone_country_code ||' '||l_formatted_phone_number;
        ELSE
          l_formatted_phone_number := '+'||l_phone_country_code ||' '||l_formatted_phone_number;
        END IF;
        l_prefix := 'I';
      ELSE
        l_prefix := null;
      END IF;

    ELSIF l_phone_country_code = l_user_country_code THEN
      ---check if the user's area code is same as phone's area code
      IF ((l_phone_area_code = l_default_area_code) AND
          (l_display_area_code = 'N'))
      THEN
        l_formatted_phone_number := l_phone_number;
      ELSE
        l_formatted_phone_number := l_formatted_phone_number;

        IF l_phone_area_code IS NOT NULL AND
           l_phone_area_code <> fnd_api.g_miss_char
        THEN
          l_prefix := 'T';
        ELSE
          l_prefix := null;
        END IF; ---l_phone_area_code is not null
      END IF;  ---l_phone_area_code=l_default_area_code
    END IF;     ---l_phone_country_code=l_user_country_code

    --Check the DISPLAY_ALL_PREFIXES flag
    --if set then check pabx prefix

    IF l_display_all_prefixes = 'Y' AND
       l_formatted_phone_number IS NOT NULL THEN    --Bug 4578945
      IF l_prefix = 'I' THEN
        l_formatted_phone_number := l_phone_intl_prefix||' '||
                                    l_formatted_phone_number;
      ELSIF  l_prefix = 'T' THEN
        l_formatted_phone_number := l_phone_trunk_prefix||' '||
                                    l_formatted_phone_number;
      END IF;

      ---append the user's PABX prefix if user has set it up
      IF l_pabx_prefix IS NOT NULL THEN
        l_formatted_phone_number := l_pabx_prefix||' '||
                                    l_formatted_phone_number;
      END IF;
    END IF;

    x_formatted_phone_number := l_formatted_phone_number;

    -- Standard call to get msg count and if count is 1, get msg info.
    fnd_msg_pub.count_and_get(
      p_encoded                   => fnd_api.g_false,
      p_count                     => x_msg_count,
      p_data                      => x_msg_data);

    -- Debug info.
    IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug_return_messages(
        p_msg_count               => x_msg_count,
        p_msg_data                => x_msg_data,
        p_msg_type                => 'WARNING',
        p_msg_level               => fnd_log.level_error);
    END IF;
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message                 => 'phone_display (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded                 => fnd_api.g_false,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'ERROR',
          p_msg_level             => fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
          p_message               => 'phone_display (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure);
      END IF;


    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded                 => fnd_api.g_false,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'UNEXPECTED ERROR',
          p_msg_level             => fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
          p_message               => 'phone_display (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(
        p_encoded                 => fnd_api.g_false,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'SQL ERROR',
          p_msg_level             => fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
          p_message               => 'phone_display (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure);
      END IF;

END Phone_display;

--
  -- PROCEDURE check_mobile_phone
  --
  -- DESCRIPTION
  --      Checks if the Number is Mobile or not
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list       Initialize message stack if it is set to
  --                           FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_phone_country code  Country code of the phone number
  --     p_phone_area_code     Area code
  --     p_phone_number        Phone Number
  --
  --   OUT:
  --     x_mobile_flag         Flag indicating if the number is mobile
  --                           HZ_PHONE_FORMATS or default format
  --     x_return_status       Return status after the call. The status can
  --                           be fnd_api.g_ret_sts_success (success),
  --                           fnd_api.g_ret_sts_error (error),
  --                           fnd_api.g_ret_sts_unexp_error
  --                           (unexpected error).
  --     x_msg_count           Number of messages in message stack.
  --     x_msg_data            Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-10-2002    Jyoti Pandey      o Created.


 PROCEDURE check_mobile_phone (
     p_init_msg_list      IN  VARCHAR2 := fnd_api.g_false,
     p_phone_country_code IN  VARCHAR2 := fnd_api.g_miss_char,
     p_phone_area_code    IN  VARCHAR2 := fnd_api.g_miss_char,
     p_phone_number       IN  VARCHAR2 := fnd_api.g_miss_char,
     x_mobile_flag        OUT NOCOPY VARCHAR2,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2)IS


    l_debug_prefix       VARCHAR2(30) := ''; -- translate_raw_phone_number
    l_possible_prefix    VARCHAR2(30);
    l_count_mobile_prefix  NUMBER := 0;
    l_length_mobile_prefix NUMBER := 0;
    l_mobile_prefix_check  HZ_MOBILE_PREFIXES.MOBILE_PREFIX%TYPE;
    l_mobile_prefix        HZ_MOBILE_PREFIXES.MOBILE_PREFIX%TYPE;

  BEGIN

   SAVEPOINT check_mobile_phone;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'check_mobile_phone (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF p_phone_country_code is NOT NULL THEN

      l_possible_prefix := p_phone_area_code||p_phone_number;

      l_possible_prefix := filter_phone_number (l_possible_prefix);

       select count(mobile_prefix)
       into l_count_mobile_prefix
       from hz_mobile_prefixes
       where phone_country_code = p_phone_country_code;

       select max(length(mobile_prefix))
       into l_length_mobile_prefix
       from hz_mobile_prefixes
       where phone_country_code = p_phone_country_code;

      IF l_count_mobile_prefix > 0 then

        --parse using that table
        for i in 1..l_length_mobile_prefix
         loop
          begin
           l_mobile_prefix_check := SUBSTR(l_possible_prefix,1,i);

           select mobile_prefix
           into l_mobile_prefix
           from hz_mobile_prefixes
           where mobile_prefix = l_mobile_prefix_check
           and phone_country_code = p_phone_country_code ;

           if l_mobile_prefix_check = l_mobile_prefix then
               x_mobile_flag := 'Y';
               exit;
           else
            null;
           end if;

             exception
             when no_data_found then
             Null;
          end;
          end loop;

          if x_mobile_flag is null then
             x_mobile_flag := 'N';
          end if;

      ELSE
        x_mobile_flag := 'N';  ---l_count_mobile_prefix  <= 0
      END IF;
   ELSE    ---p_phone_country_code  is NULL
     x_mobile_flag := 'N';
   END IF; ---p_phone_country_code  is NULL

       -- Standard call to get msg count and if count is 1, get msg info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'check_mobile_phone (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'check_mobile_phone (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'check_mobile_phone (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'check_mobile_phone (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;


  END check_mobile_phone;


--------------------------------------
  -- private procedures and functions
--------------------------------------

PROCEDURE get_user_phone_preferences(
    p_customer_id                 IN     VARCHAR2,
    x_user_phone_preferences_rec  OUT    NOCOPY user_phone_preferences_rec
) IS

    CURSOR c_party (
      p_party_id                  NUMBER
    ) IS
    SELECT null
    FROM   hz_party_preferences
    WHERE  party_id = p_party_id
    AND    ROWNUM = 1;

    l_dummy                       VARCHAR2(1);
    l_user_territory_code         VARCHAR2(400);
    l_default_area_code           VARCHAR2(400);
    l_display_area_code           VARCHAR2(400);
    l_display_all_prefixes        VARCHAR2(400);
    l_pabx_prefix                 VARCHAR2(400);

BEGIN

    x_user_phone_preferences_rec := NULL;

    IF (NOT (pref_user_territory_code_tab.EXISTS(p_customer_id))) THEN

      OPEN c_party (p_customer_id);
      FETCH c_party INTO l_dummy;

      IF c_party%NOTFOUND THEN
        pref_user_territory_code_tab(p_customer_id) := NULL;
        pref_default_area_code_tab(p_customer_id) := NULL;
        pref_display_area_code_tab(p_customer_id) := NULL;
        pref_display_all_prefix_tab(p_customer_id) := NULL;
        pref_pabx_prefix_tab(p_customer_id) := NULL;

      ELSE
        -- get party preference if it is a valid party and
        -- has preferences

        l_user_territory_code :=
          hz_preference_pub.value_varchar2(
            p_customer_id,'TCA Phone','USER_TERRITORY_CODE');

        l_default_area_code :=
          hz_preference_pub.value_varchar2(
            p_customer_id,'TCA Phone','DEFAULT_AREA_CODE');

        l_display_area_code :=
          hz_preference_pub.value_varchar2(
            p_customer_id,'TCA Phone','DISPLAY_AREA_CODE');

        l_display_all_prefixes :=
          hz_preference_pub.value_varchar2(
            p_customer_id,'TCA Phone','DISPLAY_ALL_PREFIXES');

        l_pabx_prefix :=
          hz_preference_pub.value_varchar2(
            p_customer_id,'TCA Phone','PABX_PREFIX');

        pref_user_territory_code_tab(p_customer_id) := l_user_territory_code;
        pref_default_area_code_tab(p_customer_id) := l_default_area_code;
        pref_display_area_code_tab(p_customer_id) := l_display_area_code;
        pref_display_all_prefix_tab(p_customer_id) := l_display_all_prefixes;
        pref_pabx_prefix_tab(p_customer_id) := l_pabx_prefix;

        -- construct return
        x_user_phone_preferences_rec.user_territory_code := l_user_territory_code;
        x_user_phone_preferences_rec.default_area_code := l_default_area_code;
        x_user_phone_preferences_rec.display_area_code := l_display_area_code;
        x_user_phone_preferences_rec.display_all_prefixes := l_display_all_prefixes;
        x_user_phone_preferences_rec.pabx_prefix := l_pabx_prefix;

      END IF;
      CLOSE c_party;

    ELSE
      -- construct return
      x_user_phone_preferences_rec.user_territory_code := pref_user_territory_code_tab(p_customer_id);
      x_user_phone_preferences_rec.default_area_code := pref_default_area_code_tab(p_customer_id);
      x_user_phone_preferences_rec.display_area_code := pref_display_area_code_tab(p_customer_id);
      x_user_phone_preferences_rec.display_all_prefixes := pref_display_all_prefix_tab(p_customer_id);
      x_user_phone_preferences_rec.pabx_prefix := pref_pabx_prefix_tab(p_customer_id);
    END IF;

END get_user_phone_preferences;


PROCEDURE cache_phone_country_via_terr (
    p_territory_code              IN     VARCHAR2,
    x_phone_country_code          OUT    NOCOPY VARCHAR2,
    x_trunk_prefix                OUT    NOCOPY VARCHAR2,
    x_intl_prefix                 OUT    NOCOPY VARCHAR2
) IS

    CURSOR c_phone_country IS
    SELECT phone_country_code,
           trunk_prefix,
           intl_prefix
    FROM   hz_phone_country_codes
    WHERE  territory_code = p_territory_code;

BEGIN

    IF terr_phone_country_tab.EXISTS(p_territory_code) THEN
      x_phone_country_code := terr_phone_country_tab(p_territory_code);
      x_trunk_prefix := terr_trunk_prefix_tab(p_territory_code);
      x_intl_prefix := terr_intl_prefix_tab(p_territory_code);
    ELSE
      OPEN c_phone_country;
      FETCH c_phone_country INTO
        x_phone_country_code, x_trunk_prefix, x_intl_prefix;

      IF c_phone_country%NOTFOUND THEN
        terr_phone_country_tab(p_territory_code) := NULL;
        terr_trunk_prefix_tab(p_territory_code) := NULL;
        terr_intl_prefix_tab(p_territory_code) := NULL;
      ELSE
        terr_phone_country_tab(p_territory_code) := x_phone_country_code;
        terr_trunk_prefix_tab(p_territory_code) := x_trunk_prefix;
        terr_intl_prefix_tab(p_territory_code) := x_intl_prefix;
      END IF;
      CLOSE c_phone_country;

    END IF;

END cache_phone_country_via_terr;


PROCEDURE cache_terr_via_phone_country (
    p_phone_country_code          IN     VARCHAR2,
    x_phone_territory_code        OUT    NOCOPY VARCHAR2
) IS

    CURSOR c_territory IS
    SELECT pc.territory_code
    FROM   hz_phone_country_codes pc
    WHERE  phone_country_code = p_phone_country_code
    AND    EXISTS (
             SELECT null
             FROM   hz_phone_formats pf
             WHERE  pf.territory_code = pc.territory_code)
    AND    ROWNUM =1;

BEGIN

    IF phone_territory_tab.EXISTS(p_phone_country_code) THEN
      x_phone_territory_code := phone_territory_tab(p_phone_country_code);
    ELSE
      OPEN c_territory;
      FETCH c_territory INTO x_phone_territory_code;

      IF c_territory%NOTFOUND THEN
        phone_territory_tab(p_phone_country_code) := NULL;
      ELSE
        phone_territory_tab(p_phone_country_code) := x_phone_territory_code;
      END IF;
      CLOSE c_territory;
    END IF;

END cache_terr_via_phone_country;


/*----------------------parse_intl_prefix--------------------------*/

PROCEDURE  parse_intl_prefix(
           p_with_iprefix     IN VARCHAR2 := fnd_api.g_miss_char,
           p_territory_code   IN VARCHAR2 := fnd_api.g_miss_char,
           x_intl_prefix      OUT NOCOPY VARCHAR2,
           x_without_iprefix  OUT NOCOPY VARCHAR2)  IS

           l_with_iprefix               VARCHAR2(30);
           l_without_iprefix            VARCHAR2(30);
           l_intl_prefix                VARCHAR2(5);
           l_check_sign                 NUMBER;
           l_prefix_check               VARCHAR2(30);
           l_length_with_iprefix         NUMBER;
           l_length_of_iprefix           NUMBER;
           l_debug_prefix               VARCHAR2(30) := '';
  BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'parse_intl_prefix (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_with_iprefix  := p_with_iprefix;

   ---Get the International prefix for the country
       select intl_prefix
       into l_intl_prefix
       from hz_phone_country_codes
       where territory_code = p_territory_code;

      l_length_with_iprefix := LENGTH(l_with_iprefix);
      l_length_of_iprefix   := LENGTH(l_intl_prefix);

    ---check  for the presence of the intl prefix(max=3) in the number

     if l_intl_prefix is not null then
       l_prefix_check := SUBSTR(l_with_iprefix,1,l_length_of_iprefix);

            if l_prefix_check = l_intl_prefix then
               ---chop off the intl prefix
               l_without_iprefix :=
                SUBSTR(l_with_iprefix ,l_length_of_iprefix+1 ,
                       l_length_with_iprefix);
            else

            ---if could not parse the intl prefix after the loop
              l_prefix_check    := NULL;
              l_without_iprefix := l_with_iprefix;
           end if;

       else       ---if l_intl_prefix is null
          l_prefix_check    := NULL;
          l_without_iprefix := l_with_iprefix;

       end if;    ---for l_intl_prefix not null


   x_intl_prefix := l_prefix_check;
   x_without_iprefix := l_without_iprefix;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'parse_intl_prefix (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
      x_intl_prefix := NULL;
      x_without_iprefix := l_with_iprefix;

    WHEN OTHERS THEN
      RAISE fnd_api.g_exc_unexpected_error;

   END parse_intl_prefix;

/*---------------------parse_trunk_prefix------------------------*/

  PROCEDURE  parse_trunk_prefix(
                  p_with_tprefix     IN VARCHAR2 := fnd_api.g_miss_char,
                  p_territory_code   IN VARCHAR2 := fnd_api.g_miss_char,
                  x_trunk_prefix     OUT NOCOPY VARCHAR2,
                  x_without_tprefix  OUT NOCOPY VARCHAR2) IS

    l_with_tprefix             VARCHAR2(30);
    l_without_tprefix          VARCHAR2(30);
    l_trunk_prefix             VARCHAR2(5);
    l_tprefix_check            VARCHAR2(30);
    l_length_with_tprefix      NUMBER;
    l_length_of_tprefix        NUMBER;
    l_debug_prefix             VARCHAR2(30) := '';


  BEGIN

     -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'parse_trunk_prefix (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_with_tprefix  := p_with_tprefix;

    ---Get the trunk prefix for the country
    select trunk_prefix
    into l_trunk_prefix
    from hz_phone_country_codes
    where territory_code = p_territory_code;

   l_length_with_tprefix := LENGTH(l_with_tprefix);
   l_length_of_tprefix   := LENGTH(l_trunk_prefix);


    ---check  for the presence of the trunk prefix(max=3) in the number

       if l_trunk_prefix is not null then
            l_tprefix_check := SUBSTR(l_with_tprefix,1,l_length_of_tprefix);

            if l_tprefix_check = l_trunk_prefix then
               ---chop off the trunk prefix

               l_without_tprefix :=
                SUBSTR(l_with_tprefix ,l_length_of_tprefix+1 ,
                       l_length_with_tprefix);
               g_international_flag  := 'N';

            else
              l_tprefix_check    := NULL;
              l_without_tprefix  := l_with_tprefix;
           end if;

       else       ---if l_trunk_prefix is null

          l_tprefix_check    := NULL;
          l_without_tprefix := l_with_tprefix;

       end if;    ---for l_trunk_prefix not null

    x_trunk_prefix    := l_tprefix_check;
    x_without_tprefix := l_without_tprefix;

     -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'parse_trunk_prefix (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_trunk_prefix := NULL;
      x_without_tprefix := l_with_tprefix;

    WHEN OTHERS THEN
      RAISE fnd_api.g_exc_unexpected_error;

   END parse_trunk_prefix;

-------PARSE COUNTRY CODE ----------------------
PROCEDURE parse_country_code(
    p_with_country_code     IN VARCHAR2 := fnd_api.g_miss_char,
    x_country_code          OUT NOCOPY VARCHAR2,
    x_without_country_code  OUT NOCOPY VARCHAR2) IS

    x_parsed_country_code           VARCHAR2(5);
    l_with_country_code             VARCHAR2(30);
    l_without_country_code          VARCHAR2(30);
    l_phone_country_code            VARCHAR2(5);
    l_check_sign                    number;
    l_country_code_check            varchar2(30);
    l_length_ccode                  NUMBER;
    l_debug_prefix                  VARCHAR2(30) := '';
BEGIN

-- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'parse_country_code (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

 l_with_country_code := p_with_country_code ;
 l_length_ccode := LENGTH(l_with_country_code);

         for i in 1..4
         loop
          begin
           l_country_code_check := SUBSTR(l_with_country_code,1,i);

          --row num =1 to eliminate where 2 countries with same country_code
           select phone_country_code
           into l_phone_country_code
           from hz_phone_country_codes
           where phone_country_code = l_country_code_check
           and rownum = 1;


           l_without_country_code :=
                        SUBSTR(l_with_country_code ,i+1 ,l_length_ccode);
           x_country_code := l_country_code_check;
           exit;

          exception
          when no_data_found then
           Null;
         end;
        end loop;


     if l_without_country_code is null then
        l_country_code_check := NULL;
        l_without_country_code :=  l_with_country_code;
     end if;

    x_parsed_country_code   := l_country_code_check;
    x_without_country_code  := l_without_country_code;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'parse_country_code (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

   EXCEPTION
    WHEN OTHERS THEN
      RAISE fnd_api.g_exc_unexpected_error;

end parse_country_code;

---------PARSE AREA CODE AND PHONE NUMBER-----------------
PROCEDURE parse_area_code(
          p_with_area_code      IN VARCHAR2 := fnd_api.g_miss_char,
          p_phone_country_code  IN VARCHAR2 := fnd_api.g_miss_char,
          x_parsed_area_code    OUT NOCOPY VARCHAR2,
          x_parsed_phone_number OUT NOCOPY VARCHAR2) IS

          l_with_area_code             varchar2(30);
          l_without_area_code          VARCHAR2(30);
          l_area_code                  varchar2(5);
          l_area_code_check            varchar2(30);
          l_country_code_for_area_code varchar2(5);
          l_length_with_code           NUMBER;
          l_area_code_length              NUMBER;
          l_phone_length                  NUMBER;
          l_count_area_code               NUMBER;
          l_debug_prefix                VARCHAR2(30) := '';


BEGIN

   -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'parse_area_code (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

 l_with_area_code  := p_with_area_code ;
 l_length_with_code := LENGTH(l_with_area_code);

    ----If country code not parsed/provided assume local number
    IF p_phone_country_code is NULL THEN
       l_country_code_for_area_code := g_user_phone_country_code;
    ELSE
       l_country_code_for_area_code :=  p_phone_country_code;
    END IF;

    ----First see if the length of the area code is fixed
    SELECT area_code_length,
           phone_length
    into   l_area_code_length, l_phone_length
    from hz_phone_country_codes
    where phone_country_code = l_country_code_for_area_code
    and rownum = 1;


  IF ( l_area_code_length is not null) then

      if  ((l_phone_length is null) OR (l_phone_length =l_length_with_code) ) then

           l_area_code_check := SUBSTR(l_with_area_code,1,
                                       l_area_code_length);
           l_without_area_code :=
                SUBSTR(l_with_area_code ,l_area_code_length+1 ,
                       l_length_with_code);
           x_parsed_area_code  := l_area_code_check;
      else
           l_area_code_check := NULL;
           l_without_area_code :=  l_with_area_code;
      end if;

 ELSE

     select count(area_code)
     into l_count_area_code
     from hz_phone_area_codes
     where phone_country_code = l_country_code_for_area_code;

    IF l_count_area_code > 0 then

        --parse using that table
        for i in 1..5
         loop
          begin
           l_area_code_check := SUBSTR(l_with_area_code,1,i);

           select area_code
           into l_area_code
           from hz_phone_area_codes
           where area_code = l_area_code_check
           and phone_country_code = l_country_code_for_area_code;



            if l_area_code_check = l_area_code then
               l_without_area_code :=  SUBSTR(l_with_area_code ,i+1 ,
                                              l_length_with_code);
               x_parsed_area_code := l_area_code_check;
               exit;
           else
            null;
           end if;

             exception
             when no_data_found then
             Null;
          end;
          end loop;

         IF l_without_area_code is null then
          l_area_code_check := NULL;
          l_without_area_code :=  l_with_area_code;
         END IF;

     ELSE ---area code list is not there to parse
        l_area_code_check := NULL;
        l_without_area_code :=  l_with_area_code;
     END IF;
  END IF;


    x_parsed_area_code   := l_area_code_check;
    x_parsed_phone_number := l_without_area_code;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'parse_area_code (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

exception
when no_data_found then
 null;


END PARSE_AREA_CODE;

/*-----------------filter_phone_number----------------------------*/
FUNCTION filter_phone_number (
    p_phone_number                IN     VARCHAR2,
    p_isformat                    IN     NUMBER := 0
  ) RETURN VARCHAR2 IS

    l_filtered_number             VARCHAR2(100);
    l_debug_prefix                VARCHAR2(30) := '';

  BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'filter_phone_number (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    IF p_isformat = 0 THEN
      l_filtered_number := TRANSLATE (
      p_phone_number,
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz()- .+''~`\/@#$%^&*_,|}{[]?<>=";:',
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz');
    ELSE
      l_filtered_number := TRANSLATE (
        p_phone_number,
    '9012345678ABCDEFGHIJKLMNOPQRSTUVWXYZ()- .+''~`\/@#$%^&*_,|}{[]?<>=";:',
        '9');
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'filter_phone_number (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    RETURN l_filtered_number;

  END filter_phone_number;


PROCEDURE get_phone_format (
    p_raw_phone_number            IN     VARCHAR2 := fnd_api.g_miss_char,
    p_territory_code              IN     VARCHAR2 := fnd_api.g_miss_char,
    p_area_code                   IN     VARCHAR2,
    x_phone_country_code          OUT    NOCOPY VARCHAR2,
    x_phone_format_style          OUT    NOCOPY VARCHAR2,
    x_area_code_size              OUT    NOCOPY NUMBER,
    x_msg                         OUT    NOCOPY VARCHAR2
) IS

    l_debug_prefix                VARCHAR2(30) := '';
    phone_format_style_tab        var_table := var_table();
    area_code_size_tab            num_table := num_table();
    phone_country_code_tab        var_table := var_table();
    i                             NUMBER;

    -- Query all the format styles along with other flags
    CURSOR c_formats IS
    SELECT pf.phone_format_style,
           pf.area_code_size,
           pcc.phone_country_code
    FROM   hz_phone_country_codes pcc,
           hz_phone_formats pf
    WHERE  pcc.territory_code = p_territory_code
    AND    pcc.territory_code = pf.territory_code;

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message                 => 'get_phone_format (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    -- cache phone formats

    IF (NOT format_style_tab.EXISTS(p_territory_code || '#1')) THEN
      OPEN c_formats;
      FETCH c_formats BULK COLLECT INTO
        phone_format_style_tab, area_code_size_tab, phone_country_code_tab;
      CLOSE c_formats;

      IF phone_format_style_tab.count = 0 THEN
        format_style_tab(p_territory_code || '#' || 1) := null;
        format_area_code_size_tab(p_territory_code || '#' || 1) := null;
        format_phone_country_tab(p_territory_code || '#' || 1) := null;

        RETURN;
      ELSE
        FOR i IN 1..phone_format_style_tab.count LOOP
          format_style_tab(p_territory_code || '#' || i) := phone_format_style_tab(i);
          format_area_code_size_tab(p_territory_code || '#' || i) := area_code_size_tab(i);
          format_phone_country_tab(p_territory_code || '#' || i) := phone_country_code_tab(i);
        END LOOP;
      END IF;

    ELSE -- get value from cache.
      i := 1;
      WHILE (format_style_tab.EXISTS(p_territory_code || '#' || i) AND
             format_style_tab(p_territory_code || '#' || i) IS NOT NULL)
      LOOP
        phone_format_style_tab.extend(1);
        phone_format_style_tab(i) := format_style_tab(p_territory_code || '#' || i);

        area_code_size_tab.extend(1);
        area_code_size_tab(i) := format_area_code_size_tab(p_territory_code || '#' || i);

        phone_country_code_tab.extend(1);
        phone_country_code_tab(i) := format_phone_country_tab(p_territory_code || '#' || i);

        i := i + 1;
      END LOOP;

    END IF;

    FOR i IN 1..phone_format_style_tab.count LOOP
      IF LENGTHB(filter_phone_number(phone_format_style_tab(i), 1)) =
         LENGTHB(p_raw_phone_number)
      THEN
        IF p_area_code IS NULL OR
           (p_area_code IS NOT NULL AND
            LENGTHB(p_area_code) = area_code_size_tab(i))
        THEN
          x_phone_format_style := phone_format_style_tab(i);
          x_area_code_size := area_code_size_tab(i);
          x_phone_country_code := phone_country_code_tab(i);

          EXIT;
         END IF;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message                 => 'get_phone_format (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

END get_phone_format;

/*------------------------translate_raw_phone_number----------------*/

 PROCEDURE translate_raw_phone_number (
    p_raw_phone_number        IN     VARCHAR2 := fnd_api.g_miss_char,
    p_phone_format_style      IN     VARCHAR2 := fnd_api.g_miss_char,
    x_formatted_phone_number  OUT    NOCOPY VARCHAR2
  ) IS

    l_debug_prefix    VARCHAR2(30) := ''; -- translate_raw_phone_number

    l_phone_counter   NUMBER := 1;
    l_format_length   NUMBER;
    l_format_char     VARCHAR2(1);

  BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'translate_raw_phone_number (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_format_length := LENGTH(p_phone_format_style);
    x_formatted_phone_number := '';

    -- Loop through each character of the phone format string
    -- and construct the formatted phone number

    FOR i IN 1..l_format_length LOOP
      l_format_char := SUBSTR(p_phone_format_style, i, 1);

      IF l_format_char = '9' THEN
        x_formatted_phone_number := x_formatted_phone_number ||
                                    SUBSTR(p_raw_phone_number,
                                            l_phone_counter, 1);
        l_phone_counter := l_phone_counter + 1;
      ELSE
        x_formatted_phone_number := x_formatted_phone_number ||
                                    l_format_char;
      END IF;
    END LOOP;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'translate_raw_phone_number (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  END translate_raw_phone_number;


FUNCTION get_formatted_phone(
    p_contact_point_id       IN NUMBER,
    p_display_purpose IN        VARCHAR2 := fnd_api.g_true)
RETURN VARCHAR2 IS
    --3865843
    x_formatted_phone_number VARCHAR2(220);
    x_return_status              VARCHAR2(1);
    x_msg_count                  NUMBER;
    x_msg_data                   VARCHAR2(2000);
    x_phone_line_type        VARCHAR2(30);
    x_phone_extension        VARCHAR2(20);

    l_phone_country_code varchar2(100);
    l_phone_area_code varchar2(100);
    l_phone_number varchar2(100);
    l_phone_extension varchar2(100);
    l_phone_line_type varchar2(100);
BEGIN

    IF p_contact_point_id IS NULL THEN
        RETURN NULL;
    END IF;

    phone_display(
        fnd_api.g_true,
        p_contact_point_id,
        x_formatted_phone_number,
        x_return_status,
        x_msg_count,
        x_msg_data);

    SELECT phone_extension, hz_utility_v2pub.get_lookupmeaning('AR_LOOKUPS', 'PHONE_LINE_TYPE', phone_line_type)
    INTO x_phone_extension, x_phone_line_type
    FROM hz_contact_points
    WHERE contact_point_id = p_contact_point_id;

    IF x_phone_extension IS NOT NULL THEN
            x_formatted_phone_number := x_formatted_phone_number || ' x' || x_phone_extension;
    END IF;

    IF p_display_purpose = fnd_api.g_true THEN
            x_formatted_phone_number := x_formatted_phone_number || ' (' || x_phone_line_type || ')';
    END IF;
    RETURN x_formatted_phone_number;

END get_formatted_phone;


/**
 * FUNCTION get_formatted_phone
 *
 * DESCRIPTION
 *    Overloaded function to return a formatted phone number.
 *
 * ARGUMENTS
 *   IN:
 *     p_phone_country_code     phone country code
 *     p_phone_area_code        phone area code
 *     p_phone_number           phone number
 *     p_phone_extension        phone extension
 *     p_phone_line_type        phone line type
 *     p_display_purpose        If the return is for display purpose.
 *                              When the value is FND_API.G_TRUE, return
 *                              formatted phone number (phone line type)
 *
 *   RETURNS    : VARCHAR2
 *
 */

FUNCTION get_formatted_phone (
    p_phone_country_code          IN     VARCHAR2,
    p_phone_area_code             IN     VARCHAR2,
    p_phone_number                IN     VARCHAR2,
    p_phone_extension             IN     VARCHAR2,
    p_phone_line_type             IN     VARCHAR2,
    p_display_purpose             IN     VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2 IS

    l_display_purpose             VARCHAR2(10);
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_phone_line_meaning          VARCHAR2(80);
    --3865843
    x_formatted_phone_number      VARCHAR2(220);

BEGIN

    IF p_display_purpose IS NULL THEN
      l_display_purpose := fnd_api.g_true;
    ELSE
      l_display_purpose := p_display_purpose;
    END IF;

    phone_display (
      p_phone_country_code        => p_phone_country_code,
      p_phone_area_code           => p_phone_area_code,
      p_phone_number              => p_phone_number,
      x_formatted_phone_number    => x_formatted_phone_number,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data
    );

    IF p_phone_extension IS NOT NULL THEN
      x_formatted_phone_number :=
        x_formatted_phone_number || ' x' || p_phone_extension;
    END IF;


   IF p_phone_line_type IS NOT NULL -- Bug 4917862
      AND p_phone_line_type<>fnd_api.g_miss_char
      AND l_display_purpose = fnd_api.g_true
   THEN
      l_phone_line_meaning :=
        hz_utility_v2pub.get_lookupmeaning('AR_LOOKUPS', 'PHONE_LINE_TYPE', p_phone_line_type);

      x_formatted_phone_number :=
        x_formatted_phone_number || ' (' || l_phone_line_meaning || ')';
    END IF;

    RETURN x_formatted_phone_number;

END get_formatted_phone;


END HZ_FORMAT_PHONE_V2PUB;

/
