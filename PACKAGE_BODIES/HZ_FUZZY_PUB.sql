--------------------------------------------------------
--  DDL for Package Body HZ_FUZZY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_FUZZY_PUB" as
/*$Header: ARHFUZYB.pls 120.9 2005/08/29 13:11:22 rchanamo ship $ */

  -- Following two strings would be used in a translate function
  -- to replace punctuation characters etc. The letter 'z' is added
  -- here because the replace string cannot be an empty string for
  -- translate function.
  g_original_text VARCHAR2(50) := 'z!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~';
  g_replace_text  VARCHAR2(50) := 'z';

  -- Bug 3252909.
  -- These variables will be used to store the word_list_id corresponding to
  -- word_list_name = 'ORGANIZATION_NAME_DICTIONARY','PERSON_NAME_DICTIONARY'
  -- and 'ADDRESS_DICTIONARY' respectively.`
  g_org_word_list_id NUMBER(15) := NULL;
  g_per_word_list_id NUMBER(15) := NULL;
  g_add_word_list_id NUMBER(15) := NULL;




  TYPE original_key     IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  TYPE replacement_key  IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

  g_original_key        original_key;
  g_replacement_key     replacement_key;
  g_special_enabled     VARCHAR2(1);

/*************************  Private Routines  *******************************/

/*===========================================================================+
 | FUNCTION                                                                  |
 |     cleanse                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Function takes a string as input. It replaces double         |
 |              consonants by single consonant and removes vowels that       |
 |              appear inside a word.                                        |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | ARGUMENTS  : IN : str                                                     |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : varchar2                                                     |
 |                                                                           |
 | NOTES      :  Function is called solely from Replace_Word function        |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   10-OCT-01  Created                                      |
 |                                                                           |
 +===========================================================================*/

FUNCTION cleanse
    (str IN varchar2
    )
RETURN varchar2
IS
 str2 varchar2(400) := str;
 str3 varchar2(400);

BEGIN

 -- if the input is null, return null as the processing has no
 -- impact on that
 if str is null then
   return str;
 end if;

 -- Step 1. Replace any two or more consecutive same
 --         letters by single letter

 -- get the input string in a temporary string
 str3 := str2;

 -- loop from first letter to last but one letter
 for i in 1..lengthb(str2)-1
 loop
   -- if two consecutive letters match, then replace two such letter
   -- by one letter from the temporary string
   if substrb(str2,i,1) = substrb(str2,i+1,1) then
     str3 := replace(str3, substrb(str2,i,1)||substrb(str2,i+1,1), substrb(str2,i,1));
   end if;
 end loop;

 str2 := str3;

 -- Step 2. Replace Vowels only that occur inside
 -- First we should build a temporary string
 -- which would be the original string str2
 -- stripped off the first letter
 str3 := substrb(str2, 2);

 -- Now call replace to remove all occurrences
 -- of each vowel
 str3 := replace(str3, 'A', '');
 str3 := replace(str3, 'E', '');
 str3 := replace(str3, 'I', '');
 str3 := replace(str3, 'O', '');
 str3 := replace(str3, 'U', '');

 -- Now we have to build str2 back with
 -- first letter of str2 and appending str3
 str2 := substrb(str2, 1, 1)||str3;

 -- return str2 which is the final clean word
 return rtrim(str2);

END cleanse;


/*===========================================================================+
 | FUNCTION                                                                  |
 |     Replace_Word                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Function takes a word (or string of words as input) and converts the  |
 |     word into part of the TCA key needed for Fuzzy find.                  |
 |     The returned string is used in creating the TCA Key.                  |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_word                                                 |
 |                    p_replacement_type                                     |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : l_key                                                        |
 |                                                                           |
 | NOTES      :  Function is called solely from Generate_Key function        |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   10-OCT-01  Created                                      |
 |    P.Suresh       29-MAY-02  Bug No : 2326168. Modified the Replace_Word  |
 |                              function to use word_list_id instead of type.|
 |    Rajib R Borah  21-JAN-04  Bug No : 3252909. Used global variables to   |
 |                              get the word_list_id instead of opening the  |
 |                              cursor c_wl_id inside the loop every time.   |
 |    S.V.Sojwnaya   09-JUL-04  Bug No : 3686983. Modified the cursor c_key  |
 |                              to use word_list_id and word_list_name       |
 |                              instead of Type.                             |
 |    Ramesh Ch	     03-JAN-05  Bug No:4098780.Modified C_Word_Rep and c_key |
 |                              cursors not to pick the conditional          |
 |				word replacements.			     |
 |    V.Ravichandran 08-AUG-05  Bug No:4361061.Modified the procedure replace|
 |                              word to handle encrypted words composed of   |
 |				multi-byte characters correctly.             |
 |									     |
 |     Ramesh Ch.            26-AUG-2005     Modified Replace_Word to pick   |
 |					     the word replacement pairs      |
 |					     based on the staged context.    |
 |					     (DQM Stabilization Project)     |
 +===========================================================================*/


  FUNCTION Replace_Word(p_word              VARCHAR2,
                        p_replacement_type  VARCHAR2)
  RETURN VARCHAR2
  IS
    l_source_text        VARCHAR2(2000);
    l_text_length        NUMBER;
    l_current_word       VARCHAR2(2000);
    l_key                VARCHAR2(2000);
    l_old_word           VARCHAR2(2000);
    l_count              NUMBER := 0;
    l_wl_id              NUMBER;
    l_replacement_type   VARCHAR2(255);
    l_pos                number;
    l_exit_flag          VARCHAR2(1) := 'N';


    CURSOR c_wl_id (c_word_list_name VARCHAR2) IS
         SELECT word_list_id FROM HZ_WORD_LISTS
         WHERE word_list_name = c_word_list_name;

    CURSOR C_Word_Rep (x_current_word VARCHAR2,
                       cp_wl_id NUMBER) IS
      SELECT upper(replacement_word)
      FROM   hz_word_replacements
      WHERE  upper(original_word) = x_current_word
      AND    word_list_id         = cp_wl_id
      AND ((HZ_TRANS_PKG.staging_context = 'Y' AND DELETE_FLAG = 'N')
		OR (nvl(HZ_TRANS_PKG.staging_context,'N') = 'N' AND STAGED_FLAG = 'Y')
	  )
      AND    condition_id IS NULL; --Bug No:4098780

    CURSOR c_key IS
      SELECT HWR.ORIGINAL_WORD,
             HWR.REPLACEMENT_WORD
      FROM   HZ_WORD_LISTS HWL, HZ_WORD_REPLACEMENTS HWR
      WHERE  HWL.WORD_LIST_NAME = 'KEY MODIFIERS' AND HWR.WORD_LIST_ID = HWL.WORD_LIST_ID
      AND ((HZ_TRANS_PKG.staging_context = 'Y' AND HWR.DELETE_FLAG = 'N')
		OR (nvl(HZ_TRANS_PKG.staging_context,'N') = 'N' AND HWR.STAGED_FLAG = 'Y')
	   )
      AND    HWR.CONDITION_ID IS NULL; --Bug No:4098780


  BEGIN

      IF    p_replacement_type = 'ORGANIZATION' THEN
            l_replacement_type := 'ORGANIZATION_NAME_DICTIONARY';
      ELSIF p_replacement_type = 'PERSON' THEN
            l_replacement_type := 'PERSON_NAME_DICTIONARY';
      ELSIF p_replacement_type = 'ADDRESS' THEN
            l_replacement_type := 'ADDRESS_DICTIONARY';
      END IF;

      -- Bug 3252909
      IF g_org_word_list_id is null
      then
            open c_wl_id('ORGANIZATION_NAME_DICTIONARY');
	    fetch c_wl_id into g_org_word_list_id;
	    close c_wl_id;
      end if;

      IF g_per_word_list_id is null
      then
            open c_wl_id('PERSON_NAME_DICTIONARY');
	    fetch c_wl_id into g_per_word_list_id;
	    close c_wl_id;
      end if;

      IF g_add_word_list_id is null
      then
            open c_wl_id('ADDRESS_DICTIONARY');
	    fetch c_wl_id into g_add_word_list_id;
	    close c_wl_id;
      end if;

    -- Steps mentioned here are in the context of complete fuzzy key
    -- generation process. (Step 1 is in Generate_Key)

    -- Step 2.
    -- We need to remove 'S so that WILLIAM'S becomes WILLIAM and
    -- it can become BILL if there is a replacement rule from
    -- original word WILLIAM to replacement word BILL
    l_source_text := replace(p_word, '''S ', ' ');

    -- Step 3.
    -- We need to remove any punctuation characters etc.
    -- For example, this will make 134/3, 134-3 etc mapped to 1343 in key for address.
    l_source_text := ltrim(translate(l_source_text, g_original_text, g_replace_text));

    -- Step 3.5.
    -- This step is for removal of special characters.
    -- The special characters will only be replaced if user has
    -- has set up Key Modifiers rules.
    -- This will replace any number of characters to any number of characters mapping for
    -- many european language. See bug 1868161 for detail.

    IF g_special_enabled IS NULL THEN
        OPEN c_key;
        FETCH c_key INTO g_original_key(l_count), g_replacement_key(l_count);
        IF c_key%NOTFOUND THEN
            g_special_enabled := 'N';
        ELSE
            g_special_enabled := 'Y';
        END IF;

        WHILE c_key%FOUND LOOP
            l_count := l_count + 1;
            FETCH c_key INTO g_original_key(l_count), g_replacement_key(l_count);
        END LOOP;
        CLOSE c_key;
    END IF;

    IF g_special_enabled = 'Y' THEN
        FOR i IN g_original_key.FIRST..g_original_key.LAST LOOP
            l_source_text := REPLACE(l_source_text, g_original_key(i), g_replacement_key(i));
        END LOOP;
    END IF;

    -- Step 4.
    -- We need to continue further processing on each word if a group
    -- of words is the input parameter.
    -- For example INTERNATIONAL BUSINESS MACHINES should have rules
    -- applied to each word (INTERNATIONAL, BUSINESS, MACHINES) individually.
    -- Append a blank space on the end of the text so that the loop can
    -- always end with the last word.
    l_source_text := l_source_text || ' ';

    -- Bug 3252909.
    -- Instead of gettin word_list_id from cursor inside loop( in Step 5),
    -- read from global variable outside loop.



    IF l_replacement_type = 'ORGANIZATION_NAME_DICTIONARY'
    THEN
        l_wl_id := g_org_word_list_id;
    ELSIF  l_replacement_type = 'PERSON_NAME_DICTIONARY'
    THEN
        l_wl_id := g_per_word_list_id;
    ELSIF l_replacement_type = 'ADDRESS_DICTIONARY'
    THEN
        l_wl_id := g_add_word_list_id;
    ELSE
        RETURN p_word;-- RETURN l_source_text seems to be a better option.
    END IF;



    LOOP
      l_text_length := NVL(lengthb(l_source_text),0);
      l_pos := instrb(l_source_text,' ',1);
      IF l_exit_flag='Y' or l_text_length=0
      THEN

          EXIT;
      END IF;
      l_current_word:=substrb(l_source_text,1,l_pos-1);
      l_old_word:=l_current_word;

          -- Fetch the replacement word for the current word.
          -- If no replacement word is found, then use the original
          -- word
          --
          -- Step 5.
          -- Search a replacement word for the original word.
          -- For example WILLIAM will be replaced by BILL if there is such rule.
          -- If a replacement found, substitute the original word by it

	  /*Bug 3252909.Read from global variables instead of using the cursor.
          | OPEN c_wl_id(l_replacement_type);
          | FETCH c_wl_id INTO l_wl_id;
          | IF c_wl_id%NOTFOUND THEN
          | CLOSE c_wl_id;
          | RETURN p_word;
          | END IF;
          | CLOSE c_wl_id;
	  */

          OPEN C_Word_Rep(l_current_word, l_wl_id);
          FETCH C_Word_Rep INTO l_current_word;
          IF (C_Word_Rep%NOTFOUND)
          THEN
            l_current_word := l_old_word;
          END IF;
          CLOSE C_Word_Rep;

          -- Step 7.
          -- If profile for cleansing is set, then cleanse the word.
          -- Cleanse converts double letters to single letter, removes
          -- vowels inside a word.
          -- For example : UNIVERSAL - UNVRSL, LITTLE - LTL etc.
	  -- Bug 2059524,added NVL function in the following line.
          if NVL(fnd_profile.value('HZ_CLEANSE_FUZZY_KEY'),'Y')  = 'Y' then
            l_current_word := cleanse(l_current_word);
          end if;

          -- Step 8.
          -- Build the key in a local variable
          -- This removes the white spaces
          l_key := l_key || l_current_word;
          if l_text_length=l_pos
          then
          l_exit_flag:='Y';
          end if;

          l_source_text := substrb(l_source_text,l_pos+1);
    END LOOP;
    RETURN l_key;
  END Replace_Word;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |     Find_Duplicate_Party                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Checks to see if there is a duplicate party record in the             |
 |     database.  If one is found then TRUE is returned along with the       |
 |     party_id for the existing party. If a duplicate is not found,         |
 |     then FALSE is returned.                                               |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                p_party_name                               |
 |                                p_party_key                                |
 |                                p_key_search_flag                          |
 |              OUT:                                                         |
 |                                p_party_id                                 |
 |                                p_is_duplicate                             |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES      :                                                              |
 |       A matching party is defined as:                                     |
 |        the p_key_search_flag = 'T' and the party keys match               |
 |        the p_key_search_flag = 'F' and the upper party names match        |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

  PROCEDURE Find_Duplicate_Party (
                                  p_party_name         IN VARCHAR2,
                                  p_party_key          IN VARCHAR2,
                                  p_key_search_flag    IN VARCHAR2,
                                  p_party_id          OUT NOCOPY NUMBER,
                                  p_is_duplicate      OUT NOCOPY VARCHAR2)
  IS
    CURSOR C_Duplicate_Names (X_party_Name VARCHAR2) IS
      SELECT  party_id
      FROM    hz_parties
      WHERE   upper(party_name) = upper(X_party_Name);

    CURSOR C_Duplicate_Keys (X_party_Key VARCHAR2) IS
      SELECT  party_id
      FROM    hz_parties
      WHERE   customer_key = X_party_Key;

  BEGIN
    -- if the request is not to use the keys then use match by party name
    IF upper(p_key_search_flag) = FND_API.G_FALSE
    THEN
      OPEN C_Duplicate_Names(p_party_name);
      FETCH C_Duplicate_Names INTO p_party_id;
      IF (C_Duplicate_Names%NOTFOUND)
      THEN
        p_is_duplicate := FND_API.G_FALSE;
      ELSE
        p_is_duplicate := FND_API.G_TRUE;
      END IF;
      CLOSE C_Duplicate_Names;

    ELSIF upper(p_key_search_flag) = FND_API.G_TRUE   -- if the request is to use the keys then use match by key
    THEN
      OPEN C_Duplicate_Keys( p_party_key);
      FETCH C_Duplicate_Keys INTO p_party_id;
      IF (C_Duplicate_Keys%NOTFOUND)
      THEN
        p_is_duplicate := FND_API.G_FALSE;
      ELSE
        p_is_duplicate := FND_API.G_TRUE;
      END IF;
      CLOSE C_Duplicate_Keys;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       p_is_duplicate := FND_API.G_FALSE;

  END Find_Duplicate_Party;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |     Find_Duplicate_Address                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Checks to see if there is a duplicate address/location record in the  |
 |     database.  If one is found then TRUE is returned along with the       |
 |     location_id for the existing address.                                 |
 |     If a duplicate is not found, then FALSE is returned.                  |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                p_address_rec                              |
 |                                p_address_key                              |
 |                                p_key_search_flag                          |
 |              OUT:                                                         |
 |                                p_location_id                              |
 |                                p_is_duplicate                             |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES      :                                                              |
 |     A matching address/location is defined as:                            |
 |     the p_key_search_flag = 'T' and the address keys match                |
 |     the p_key_search_flag = 'F' and the concatenated upper string         |
 |     of address1, address2, address3, address4, postal_code, state,        |
 |     city, and country are equal                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

  PROCEDURE Find_Duplicate_Address (
          p_address_rec        IN HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
          p_address_key        IN VARCHAR2,
          p_key_search_flag    IN VARCHAR2 DEFAULT FND_API.G_TRUE,
          p_location_id       OUT NOCOPY NUMBER,
          p_is_duplicate      OUT NOCOPY VARCHAR2)
  IS
    CURSOR C_Duplicate_Keys (X_Address_Key VARCHAR2) IS
      SELECT  location_id
      FROM    hz_locations
      WHERE   address_key = X_Address_Key;

     CURSOR C_Duplicate_Address (
             X_Address1 VARCHAR2,
             X_Address2 VARCHAR2,
             X_Address3 VARCHAR2,
             X_Address4 VARCHAR2,
             X_Postal_Code VARCHAR2,
             X_State VARCHAR2,
             X_City VARCHAR2,
             X_Country VARCHAR2) IS
        SELECT  location_id
          FROM  hz_locations
         WHERE  upper(replace(translate(
                X_Address1 || X_Address2 || X_Address3 || X_Address4 ||
                X_Postal_Code || X_State || X_City || X_Country,
                '#-_.,/\', ' ') ,' ' ) ) =
                upper(replace(translate(
                  ADDRESS1 || ADDRESS2 || ADDRESS3 || ADDRESS4 ||
                  POSTAL_CODE || STATE || CITY || COUNTRY,
                  '#-_.,/\', ' ') ,' ' ) );

  BEGIN
    -- if the request is not to use the keys then use match by address fields
    IF upper(p_key_search_flag) = FND_API.G_FALSE
    THEN
      OPEN C_Duplicate_Address (rtrim(p_address_rec.Address1,FND_API.G_MISS_CHAR),
                                rtrim(p_address_rec.Address2,FND_API.G_MISS_CHAR),
                                rtrim(p_address_rec.Address3,FND_API.G_MISS_CHAR),
                                rtrim(p_address_rec.Address4,FND_API.G_MISS_CHAR),
                                rtrim(p_address_rec.Postal_Code,FND_API.G_MISS_CHAR),
                                rtrim(p_address_rec.State,FND_API.G_MISS_CHAR),
                                rtrim(p_address_rec.City,FND_API.G_MISS_CHAR),
                                rtrim(p_address_rec.Country,FND_API.G_MISS_CHAR));
      FETCH C_Duplicate_Address into p_location_id;
      IF (C_Duplicate_Address%NOTFOUND)
      THEN
        p_is_duplicate := FND_API.G_FALSE;
      ELSE
        p_is_duplicate := FND_API.G_TRUE;
      END IF;
      CLOSE C_Duplicate_Address;
    ELSIF p_key_search_flag = FND_API.G_TRUE    -- if the request is to use the keys then use match by address key
    THEN
      OPEN C_Duplicate_Keys (p_address_key);
      FETCH C_Duplicate_Keys into p_location_id;
      IF (C_Duplicate_Keys%NOTFOUND)
      THEN
        p_is_duplicate := FND_API.G_FALSE;
      ELSE
        p_is_duplicate := FND_API.G_TRUE;
      END IF;
      CLOSE C_Duplicate_Keys;
    END IF;

  EXCEPTION
      WHEN OTHERS THEN
        p_is_duplicate := FND_API.G_FALSE;

  END Find_Duplicate_Address;


/*===========================================================================+
 | FUNCTION                                                                  |
 |     Get_Party_Rec                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     The function accepts party_id and returns the party record            |
 |     for that particular party_id                                          |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                p_party_id                                 |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : l_party_rec                                                  |
 |                                                                           |
 | NOTES      : This done not return the whole party record structure.       |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

  FUNCTION Get_Party_Rec (p_party_id  NUMBER
                         ) RETURN PARTY_REC_TYPE
  IS
    l_party_rec PARTY_REC_TYPE;
  BEGIN
    SELECT
           PARTY_ID,
           PARTY_NAME,
           PARTY_TYPE,
           PERSON_FIRST_NAME,
           PERSON_LAST_NAME
    INTO
           l_party_rec.PARTY_ID,
           l_party_rec.PARTY_NAME,
           l_party_rec.PARTY_TYPE,
           l_party_rec.FIRST_NAME,
           l_party_rec.LAST_NAME
    FROM   HZ_PARTIES
    WHERE  PARTY_ID = p_party_id;

    RETURN l_party_rec;

  END Get_Party_Rec;


/*===========================================================================+
 | FUNCTION                                                                  |
 |     Get_Location_Rec                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     The function accepts location_id and returns the location record      |
 |     for that particular location_id                                       |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                p_location_id                              |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : l_location_rec                                               |
 |                                                                           |
 | NOTES      : This done not return the whole location record structure.    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

  FUNCTION Get_Location_Rec (p_location_id  NUMBER
                            ) RETURN LOCATION_REC_TYPE
  IS
    l_location_rec LOCATION_REC_TYPE;
  BEGIN
    SELECT
           LOCATION_ID,
           ADDRESS1,
           ADDRESS2,
           ADDRESS3,
           ADDRESS4,
           POSTAL_CODE
    INTO
           l_location_rec.LOCATION_ID,
           l_location_rec.ADDRESS1,
           l_location_rec.ADDRESS2,
           l_location_rec.ADDRESS3,
           l_location_rec.ADDRESS4,
           l_location_rec.POSTAL_CODE
    FROM   HZ_LOCATIONS
    WHERE  LOCATION_ID = p_location_id;

    RETURN l_location_rec;
  END Get_Location_Rec;



/********************************************************/
/*******************  Public Routines *******************/
/********************************************************/


/*===========================================================================+
 | FUNCTION                                                                  |
 |     Generate_Key                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Function to generate a party (organization/perosn/group) key,         |
 |     address key for use in fuzzy find by TCA.                             |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_key_type                                          |
 |                       p_party_name                                        |
 |                       p_address1                                          |
 |                       p_address2                                          |
 |                       p_address3                                          |
 |                       p_address4                                          |
 |                       p_postal_code                                       |
 |                       p_first_name                                        |
 |                       p_last_name                                         |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : l_key                                                        |
 |                                                                           |
 | NOTES      :                                                              |
 |     p_key_type must be 'ORGANIZATION', 'PERSON', 'GROUP', 'ADDRESS'.      |
 |     For key_type 'ORGANIZATION', 'GROUP' party name is needed             |
 |     For key_type 'ADDRESS', address1/address2/address3/address4 and       |
 |      postal_code are required                                             |
 |     For key_type 'PERSON' first_name and last_name should be passed in    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |    Jianying Huang 20-FEB-00  Bug 1651795: Replace 'CUSTOMER' with         |
 |                      P_KEY_TYPE when call Replace_Word for key type =     |
 |                      'ORGANIZATION', 'GROUP' etc.                         |
 |                                                                           |
 |    H. Yu          05-MAR-01  Mod Generate_Key to use hz_common_pub.cleanse|
 |    Indrajit Sen   10-OCT-01  Cleanse function is put in this package      |
 |    Indrajit Sen   25-OCT-01  G_MISS_CHAR is handled properly
 +===========================================================================*/

  FUNCTION Generate_Key (p_key_type      VARCHAR2,
                         p_party_name    VARCHAR2 DEFAULT NULL,
                         p_address1      VARCHAR2 DEFAULT NULL,
                         p_address2      VARCHAR2 DEFAULT NULL,
                         p_address3      VARCHAR2 DEFAULT NULL,
                         p_address4      VARCHAR2 DEFAULT NULL,
                         p_postal_code   VARCHAR2 DEFAULT NULL,
                         p_first_name    VARCHAR2 DEFAULT NULL,
                         p_last_name     VARCHAR2 DEFAULT NULL
                        ) RETURN VARCHAR2
  IS
    l_word_count         NUMBER;
    l_word_length        NUMBER;
    l_address_index      NUMBER;
    l_key                VARCHAR2(2000);
    l_key2               VARCHAR2(2000);
    l_party_word         VARCHAR2(2000);
    l_address_word       VARCHAR2(2000);
    l_postal_word        VARCHAR2(2000);
    l_key_type           VARCHAR2(30);
    l_party_name         VARCHAR2(360);
    l_first_name         VARCHAR2(150);
    l_last_name          VARCHAR2(150);
    l_address1           VARCHAR2(240);
    l_address2           VARCHAR2(240);
    l_address3           VARCHAR2(240);
    l_address4           VARCHAR2(240);
    l_postal_code        VARCHAR2(60);

  BEGIN

    -- Step 1.
    -- Convert all the input information to upper
    -- so that rules are applied to upper words
    l_key_type    := upper(p_key_type);
    l_party_name  := upper(p_party_name);
    l_first_name  := upper(p_first_name);
    l_last_name   := upper(p_last_name);
    l_address1    := upper(p_address1);
    l_address2    := upper(p_address2);
    l_address3    := upper(p_address3);
    l_address4    := upper(p_address4);
    l_postal_code := upper(p_postal_code);

    -- for key type 'ORGANIZATION' / 'GROUP'
    IF (l_key_type = 'ORGANIZATION') OR
       (l_key_type = 'GROUP')
    THEN
      -- since group is similar to organization in terms of key generation
      -- logic, we should set the key_type to ORGANIZATION so that replacement
      -- rules for organization can be applied to group as weel.
      l_key_type := 'ORGANIZATION';

      -- Org or Group key is generated for HZ_CUSTOMER_KEY_WORD_COUNT words in the party name
      -- We need to parse the party name to figure out how much information to pass to
      -- the replace word function
      l_word_count := to_number( (NVL(FND_PROFILE.Value('HZ_KEY_WORD_COUNT'), '4')) );
      l_word_length := instrb(l_party_name, ' ', 1, l_word_count);
      IF l_word_length = 0
      THEN
        l_word_length := lengthb(l_party_name);
      END IF;
      l_party_word := substrb(l_party_name, 1, l_word_length);

      -- Generate the key for Org or Group
      l_key :=  Replace_Word(l_party_word, l_key_type);

    -- for key type 'ADDRESS'
    ELSIF (l_key_type = 'ADDRESS')
    THEN
      -- First generate address line portion of key
      --
      -- The address key is either address1.postal_code or address2.postal_code
      -- or address3.postal_code or address4.postal_code
      -- depending upon profile HZ_ADDRESS_KEY_INDEX
      --
      -- l_address_index := to_number(NVL(FND_PROFILE.Value('HZ_ADDRESS_KEY_INDEX'), '1') );

      -- The above code is remarked now as we want to generate keys using address1
      -- only for the time being. Later when fuzzy search would be related to the
      -- above profile option setting, the address column will be selected based
      -- on the profile value.
      l_address_index := 1;

      IF (l_address_index = 1)
      THEN
        l_address_word := l_address1;
      ELSIF (l_address_index = 2)
      THEN
        l_address_word := l_address2;
      ELSIF (l_address_index = 3)
      THEN
        l_address_word := l_address3;
      ELSE
        l_address_word := l_address4;
      END IF;

      -- if FND_API.G_MISS_CHAR is passed for address word, then treat it as NULL
      if l_address_word = FND_API.G_MISS_CHAR then
        l_address_word := NULL;
      end if;

      -- Generate the address line portion of the key
      --
      l_key := Replace_Word(l_address_word, 'ADDRESS');

      -- Truncate to be the length of the Address Key Length Profile
      --
      l_word_length := to_number(NVL(FND_PROFILE.Value('HZ_ADDRESS_KEY_LENGTH'), '15'));
      l_key := substrb(l_key, 1, l_word_length);

      -- Get the amount of the postal code to use for generating the key
      --
      l_word_length := to_number(NVL(FND_PROFILE.Value('HZ_POSTAL_CODE_KEY_LENGTH'), lengthb(l_postal_code) ));
      l_postal_word := substrb(l_postal_code, 1, l_word_length);

      -- if FND_API.G_MISS_CHAR has been passed for postal code, that should be treated as NULL
      if l_postal_word = FND_API.G_MISS_CHAR then
        l_postal_word := NULL;
      end if;

      -- Generate the postal code portion of key
      --
      l_key2 := Replace_Word(l_postal_word, 'ADDRESS');

      -- Since only the address1 is guaranteed to be NOT NULL, we need to check if the parts
      -- of the key are not NULL
      IF l_key is NOT NULL
      THEN
        IF l_key2 is NOT NULL
        THEN
          l_key := l_key || '.' || l_key2;
        END IF;
      ELSIF l_key2 is NOT NULL
      THEN
        l_key := l_key2;
      END IF;

    -- for key type  'PERSON'
    ELSIF l_key_type = 'PERSON'
    THEN
      -- if FND_API.G_MISS_CHAR has been passed for first name or last name,
      -- then those should be treated as NULL
      if l_first_name = FND_API.G_MISS_CHAR then
        l_first_name := NULL;
      end if;

      if l_last_name = FND_API.G_MISS_CHAR then
        l_last_name := NULL;
      end if;

      -- Generate the person key.
      -- The key is made up of LAST_NAME.FIRST_NAME or LAST_NAME if first name is NULL
      --
      l_key := Replace_Word(l_last_name, 'PERSON');

      IF (l_first_name is NOT NULL)
      THEN
        IF l_key is NOT NULL
        THEN
          l_key := l_key || '.';
        END IF;
        l_key := l_key || Replace_Word(l_first_name, 'PERSON');
      END IF;
    END IF;

    RETURN l_key;

  END Generate_Key;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |     Generate_Full_Table_Key                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Procedure to generate full table key for a particular type of key     |
 |     This program is designed to be run as concurrent program              |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       Errbuf                                              |
 |                       Retcode                                             |
 |                       p_key_type                                          |
 |                       p_new_rows                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : l_location_rec                                               |
 |                                                                           |
 | NOTES      : p_key_type can be PARTY, ADDRESS                             |
 |              p_new_rows can be 'Y', 'N'                                   |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |    Sisir	     26-SEP-01  Bug No:1969345;Added who columns in the      |
 |				update of HZ_PARTIES ,HZ_LOCATIONS tables.   |
 |    Rajib R Borah  12-DEC-03  Bug 3142242.Reverted the changes done in     |
 |                              bug fix 1969345.Who columns should be updated|
 |                              only when a business attribute is updated.   |
 +===========================================================================*/

  PROCEDURE Generate_Full_Table_Key (
                         Errbuf          OUT NOCOPY     VARCHAR2,
                         Retcode         OUT NOCOPY     VARCHAR2,
                         p_key_type      IN      VARCHAR2 DEFAULT NULL,
                         p_new_rows      IN      VARCHAR2 DEFAULT 'Y'
                         )
  IS
    -- cursor to read all the party ids in the parties table.
    CURSOR C_Party_Ids (l_party_id NUMBER) IS
      SELECT  party_id
      FROM    hz_parties
      WHERE   party_id > l_party_id
        AND   party_type in ('PERSON', 'ORGANIZATION', 'GROUP');

    -- cursor to read all the party ids in the parties table where customer_key is null.
    CURSOR C_Party_Ids_New_Rows (l_party_id NUMBER) IS
      SELECT  party_id
      FROM    hz_parties
      WHERE   customer_key is NULL
      AND     party_id > l_party_id
      AND     party_type in ('PERSON', 'ORGANIZATION', 'GROUP');

    -- cursor to read all the location ids in the locations table.
    CURSOR C_Location_Ids (l_location_id NUMBER) IS
      SELECT  location_id
      FROM    hz_locations
      WHERE   location_id > l_location_id;

    -- cursor to read all the location ids in the locations table where address_key is null.
    CURSOR C_Location_Ids_New_Rows (l_location_id NUMBER) IS
      SELECT  location_id
      FROM    hz_locations
      WHERE   address_key is NULL
        AND   location_id > l_location_id;

    l_party_rec     PARTY_REC_TYPE;
    l_location_rec  LOCATION_REC_TYPE;
    l_key           VARCHAR2(2000);
    l_rec_count     NUMBER := 0;
    l_party_id      HZ_PARTIES.PARTY_ID%TYPE ;
    l_last_party_id HZ_PARTIES.PARTY_ID%TYPE := 0;
    l_location_id      HZ_LOCATIONS.LOCATION_ID%TYPE ;
    l_last_location_id HZ_LOCATIONS.LOCATION_ID%TYPE := 0;
    l_flag          VARCHAR2(1);
  BEGIN

    -- send the run details to the log file
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Concurrent program ARXFZKEY - Generate Key.');
    FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Options - ');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Key type : '||p_key_type);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Only new rows : '||p_new_rows);
    FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');

    IF p_key_type = 'PARTY'  -- generate keys for the hz_parties table
    THEN
      IF p_new_rows = 'Y'
      THEN
      LOOP
        OPEN C_Party_Ids_New_Rows(l_last_party_id);
        LOOP
          BEGIN
            FETCH C_Party_Ids_New_Rows INTO  l_party_id;
            EXCEPTION
              WHEN OTHERS THEN
                IF SQLCODE = -1555 THEN
                   CLOSE C_Party_Ids_New_Rows;
                   EXIT;
                ELSE
                   RAISE;
                END IF;
           END;
            IF C_Party_Ids_New_Rows%NOTFOUND THEN
               l_flag := 'Y';
               EXIT;
            END IF;
            l_party_rec := Get_Party_Rec (l_party_id);
            l_key := Generate_Key (
                           p_key_type    => l_party_rec.party_type,
                           p_party_name  => l_party_rec.party_name,
                           p_address1    => NULL,
                           p_address2    => NULL,
                           p_address3    => NULL,
                           p_address4    => NULL,
                           p_postal_code => NULL,
                           p_first_name  => l_party_rec.first_name,
                           p_last_name   => l_party_rec.last_name);
            -- update the parties record with the new key
            UPDATE HZ_PARTIES
            SET customer_key = l_key/*Bug 3142242
	       ,LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
		REQUEST_ID        = HZ_UTILITY_V2PUB.REQUEST_ID,
	 	PROGRAM_APPLICATION_ID=HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
		PROGRAM_ID        = HZ_UTILITY_V2PUB.PROGRAM_ID,
		PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
		LAST_UPDATE_DATE  = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
		LAST_UPDATED_BY   = HZ_UTILITY_V2PUB.LAST_UPDATED_BY */
            WHERE party_id = l_party_id;
            l_last_party_id := l_party_id;
            COMMIT;
        END LOOP;
        IF l_flag = 'Y' THEN
           EXIT;
        END IF;
      END LOOP;
     ELSIF p_new_rows = 'N'
      THEN
       LOOP
        OPEN C_Party_Ids(l_last_party_id);
        LOOP
          BEGIN
            FETCH C_Party_Ids INTO  l_party_id;
            EXCEPTION
              WHEN OTHERS THEN
              IF SQLCODE = -1555 THEN
                CLOSE C_Party_Ids;
                EXIT;
              ELSE
                RAISE;
              END IF;
            END;
            IF C_Party_Ids%NOTFOUND THEN
               l_flag := 'Y';
               EXIT;
            END IF;
            l_party_rec := Get_Party_Rec (l_party_id);
            l_key := Generate_Key (
                           p_key_type    => l_party_rec.party_type,
                           p_party_name  => l_party_rec.party_name,
                           p_address1    => NULL,
                           p_address2    => NULL,
                           p_address3    => NULL,
                           p_address4    => NULL,
                           p_postal_code => NULL,
                           p_first_name  => l_party_rec.first_name,
                           p_last_name   => l_party_rec.last_name);

          -- update the parties record with the new key
          UPDATE HZ_PARTIES
            SET customer_key = l_key/*Bug 3142242
		,LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
		REQUEST_ID        = HZ_UTILITY_V2PUB.REQUEST_ID,
	 	PROGRAM_APPLICATION_ID=HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
		PROGRAM_ID        = HZ_UTILITY_V2PUB.PROGRAM_ID,
		PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
		LAST_UPDATE_DATE  = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
		LAST_UPDATED_BY   = HZ_UTILITY_V2PUB.LAST_UPDATED_BY */
            WHERE party_id = l_party_id;
            l_last_party_id := l_party_id;
            COMMIT;
        END LOOP;
        IF l_flag = 'Y' THEN
           EXIT;
        END IF;
      END LOOP;
     END IF;

    ELSIF p_key_type = 'ADDRESS'
    THEN
      IF p_new_rows = 'Y'
      THEN
        LOOP
         OPEN C_Location_Ids_New_Rows(l_last_location_id);
         LOOP
          BEGIN
             FETCH C_Location_Ids_New_Rows INTO l_location_id;
          EXCEPTION
             WHEN OTHERS THEN
                IF SQLCODE = -1555 THEN
                  CLOSE C_Location_Ids_New_Rows;
                  EXIT;
                ELSE
                  RAISE;
                END IF;
          END;
          IF C_Location_Ids_New_Rows%NOTFOUND THEN
               l_flag := 'Y';
               EXIT;
          END IF;
          l_location_rec := Get_Location_Rec (l_location_id);
          l_key := Generate_Key (
                           p_key_type    => 'ADDRESS',
                           p_party_name  => NULL,
                           p_address1    => l_location_rec.address1,
                           p_address2    => l_location_rec.address2,
                           p_address3    => l_location_rec.address3,
                           p_address4    => l_location_rec.address4,
                           p_postal_code => l_location_rec.postal_code,
                           p_first_name  => NULL,
                           p_last_name   => NULL);
          -- update the locations record with the new key
          UPDATE HZ_LOCATIONS
            SET address_key = l_key/*Bug 3142242
		,LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
		REQUEST_ID        = HZ_UTILITY_V2PUB.REQUEST_ID,
	 	PROGRAM_APPLICATION_ID=HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
		PROGRAM_ID        = HZ_UTILITY_V2PUB.PROGRAM_ID,
		PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
		LAST_UPDATE_DATE  = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
		LAST_UPDATED_BY   = HZ_UTILITY_V2PUB.LAST_UPDATED_BY */
            WHERE location_id = l_location_id;
            l_last_location_id := l_location_id;
            COMMIT;
        END LOOP;
        IF l_flag = 'Y' THEN
           EXIT;
        END IF;
      END LOOP;
      ELSIF p_new_rows = 'N'
      THEN
        LOOP
         OPEN C_Location_Ids(l_last_location_id);
         LOOP
          BEGIN
             FETCH C_Location_Ids INTO l_location_id;
          EXCEPTION
             WHEN OTHERS THEN
               IF SQLCODE = -1555 THEN
                  CLOSE C_Location_Ids;
                  EXIT;
               ELSE
                  RAISE;
              END IF;
          END;
          IF C_Location_Ids%NOTFOUND THEN
               l_flag := 'Y';
               EXIT;
          END IF;
          l_location_rec := Get_Location_Rec (l_location_id);
          l_key := Generate_Key (
                           p_key_type    => 'ADDRESS',
                           p_party_name  => NULL,
                           p_address1    => l_location_rec.address1,
                           p_address2    => l_location_rec.address2,
                           p_address3    => l_location_rec.address3,
                           p_address4    => l_location_rec.address4,
                           p_postal_code => l_location_rec.postal_code,
                           p_first_name  => NULL,
                           p_last_name   => NULL);
          -- update the locations record with the new key
          UPDATE HZ_LOCATIONS
            SET address_key = l_key/*Bug 3142242
		,LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
		REQUEST_ID        = HZ_UTILITY_V2PUB.REQUEST_ID,
	 	PROGRAM_APPLICATION_ID=HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
		PROGRAM_ID        = HZ_UTILITY_V2PUB.PROGRAM_ID,
		PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
		LAST_UPDATE_DATE  = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
		LAST_UPDATED_BY   = HZ_UTILITY_V2PUB.LAST_UPDATED_BY */
            WHERE location_id = l_location_id;
            l_last_location_id := l_location_id;
            COMMIT;
        END LOOP;
        IF l_flag = 'Y' THEN
           EXIT;
        END IF;
        END LOOP;
      END IF;
    END IF;
    COMMIT;
    -- send count info to the log file
    FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE (FND_FILE.LOG, to_char(l_rec_count) || ' ' || p_key_type || ' keys generated.');

  EXCEPTION
    WHEN OTHERS THEN
      arp_util.debug('OTHERS : hz_fuzzy_pub.generate_full_table_key');
      Errbuf := fnd_message.get||'     '||SQLERRM;
      Retcode := 2;

  END Generate_Full_Table_Key;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |     Is_Duplicate_Party                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Public procedure for checking if the passed party information         |
 |     is a duplicate of an existing party. If program finds that it is a    |
 |     duplicate record, it sets p_duplicate to fnd_api.g_true. Also a       |
 |     message is set and one matching party_id is returned.                 |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                               p_party_type                                |
 |                               p_person_first_name                         |
 |                               p_person_last_name                          |
 |                               p_party_name                                |
 |                               p_key_search_flag                           |
 |              OUT:                                                         |
 |                               p_duplicate                                 |
 |                               p_msg_count                                 |
 |                               p_msg_data                                  |
 |                               p_party_id                                  |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : None                                                         |
 |                                                                           |
 | NOTES      : It does not return all the matching parties.                 |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

  PROCEDURE Is_Duplicate_Party  (
                                 p_party_type            IN      VARCHAR2,
                                 p_person_first_name     IN      VARCHAR2 DEFAULT NULL,
                                 p_person_last_name      IN      VARCHAR2 DEFAULT NULL,
                                 p_party_name            IN      VARCHAR2 DEFAULT NULL,
                                 p_key_search_flag       IN      VARCHAR2 DEFAULT FND_API.G_TRUE,
                                 p_duplicate             OUT NOCOPY     VARCHAR2,
                                 p_msg_count             OUT NOCOPY     NUMBER,
                                 p_msg_data              OUT NOCOPY     VARCHAR2,
                                 p_party_id              OUT NOCOPY     NUMBER
                                ) IS

    l_party_key         hz_parties.customer_key%TYPE;
    l_party_id          hz_parties.party_id%TYPE;
    l_party_name        hz_parties.party_name%TYPE;
    l_subject_name      hz_parties.party_name%TYPE;
    l_object_name       hz_parties.party_name%TYPE;
    l_is_duplicate      varchar2(10);

  begin
    p_duplicate := fnd_api.g_false;

    IF p_party_type = 'PERSON'
    THEN
      -- generate the party key for person (necessary for duplicate checking)
      l_party_key := Generate_Key (
                         p_key_type => p_party_type,
                         p_first_name => p_person_first_name,
                         p_last_name  => p_person_last_name);

      -- now check if party record already exists
      -- pass the person name and key for the duplicate checking
      Find_Duplicate_Party (
            p_party_name => p_person_first_name||' '||p_person_last_name,
            p_party_key => l_party_key,
            p_key_search_flag => p_key_search_flag,
            p_party_id => l_party_id,
            p_is_duplicate => l_is_duplicate);
    ELSE
      l_party_name := p_party_name;

      -- generate the party key for organization/group (necessary for duplicate checking)
      l_party_key := Generate_Key (
                         p_key_type => p_party_type,
                         p_party_name => l_party_name);

      -- now check if party record already exists
      -- pass the person name and key for the duplicate checking
      Find_Duplicate_Party (
            p_party_name => l_party_name,
            p_party_key => l_party_key,
            p_key_search_flag => p_key_search_flag,
            p_party_id => l_party_id,
            p_is_duplicate => l_is_duplicate);

    END IF;

    p_duplicate := l_is_duplicate;

    if fnd_api.to_boolean (l_is_duplicate)
    then
      p_party_id := l_party_id;
      p_duplicate := fnd_api.g_true;

      fnd_message.set_name ('AR', 'HZ_MATCHING_PARTY_EXISTS');
      fnd_msg_pub.add;
    end if;

  end Is_Duplicate_Party;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |     Is_Duplicate_Location                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Public procedure for checking if the passed location information      |
 |     is a duplicate of an existing location.If a duplicate location is     |
 |     found, p_duplicate is set to fnd_api.g_true and a message is also set |
 |     stating that. p_key_search_flag determines whether to do a key match  |
 |     or exact match.                                                       |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                               p_address1                                  |
 |                               p_address2                                  |
 |                               p_address3                                  |
 |                               p_address4                                  |
 |                               p_postal_code                               |
 |                               p_state                                     |
 |                               p_city                                      |
 |                               p_country                                   |
 |                               p_key_search_flag                           |
 |              OUT:                                                         |
 |                               p_duplicate                                 |
 |                               p_msg_count                                 |
 |                               p_msg_data                                  |
 |                               p_location_id                               |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : None                                                         |
 |                                                                           |
 | NOTES      : It does not return all the matching locations.               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/


  PROCEDURE Is_Duplicate_Location(
                                  p_address1            IN VARCHAR2 DEFAULT NULL,
                                  p_address2            IN VARCHAR2 DEFAULT NULL,
                                  p_address3            IN VARCHAR2 DEFAULT NULL,
                                  p_address4            IN VARCHAR2 DEFAULT NULL,
                                  p_postal_code         IN VARCHAR2 DEFAULT NULL,
                                  p_state               IN VARCHAR2 DEFAULT NULL,
                                  p_city                IN VARCHAR2 DEFAULT NULL,
                                  p_country             IN VARCHAR2 DEFAULT NULL,
                                  p_key_search_flag     IN  VARCHAR2 DEFAULT FND_API.G_TRUE,
                                  p_duplicate           OUT NOCOPY VARCHAR2,
                                  p_msg_count           OUT NOCOPY NUMBER,
                                  p_msg_data            OUT NOCOPY VARCHAR2,
                                  p_location_id         OUT NOCOPY NUMBER) IS

    l_address_rec   HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
    l_address_key   VARCHAR2(2000);
    l_location_id   NUMBER;
    l_is_duplicate  VARCHAR2(10);

  begin
    p_duplicate := fnd_api.g_false;

    -- generate the address key (necessary for duplicate checking)
    l_address_key := Generate_Key('ADDRESS',
                                  p_address1,
                                  p_address2,
                                  p_address3,
                                  p_address4,
                                  p_postal_code);

    l_address_rec.address1 := p_address1;
    l_address_rec.address2 := p_address2;
    l_address_rec.address3 := p_address3;
    l_address_rec.address4 := p_address4;
    l_address_rec.postal_code := p_postal_code;
    l_address_rec.state := p_state;
    l_address_rec.city := p_city;
    l_address_rec.country := p_country;

    Find_Duplicate_Address (
          p_address_rec => l_address_rec,
          p_key_search_flag => p_key_search_flag,
          p_address_key => l_address_key,
          p_location_id => l_location_id,
          p_is_duplicate => l_is_duplicate);

    p_duplicate := l_is_duplicate;

    if fnd_api.to_boolean (l_is_duplicate)
    then
      p_location_id := l_location_id;
      p_duplicate := fnd_api.g_true;

      fnd_message.set_name ('AR', 'MATCHING_LOCATION_EXISTS');
      fnd_msg_pub.add;
    end if;

  end is_duplicate_location;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |     Fuzzy_Search_Address                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Public procedure for doing fuzzy search for address. Pass the address |
 |     lines and the postal code. The number of duplicate records found      |
 |     is returned in p_count and list of location ids is returned in        |
 |     p_location_tbl.                                                       |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                               p_address1                                  |
 |                               p_address2                                  |
 |                               p_address3                                  |
 |                               p_address4                                  |
 |                               p_postal_code                               |
 |              OUT:                                                         |
 |                               p_location_tbl                              |
 |                               p_count                                     |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : None                                                         |
 |                                                                           |
 | NOTES      : This does fuzzy search based on the generated key only.      |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

  PROCEDURE Fuzzy_Search_Address(
                                  p_address1            IN  HZ_LOCATIONS.ADDRESS1%TYPE DEFAULT NULL,
                                  p_address2            IN  HZ_LOCATIONS.ADDRESS2%TYPE DEFAULT NULL,
                                  p_address3            IN  HZ_LOCATIONS.ADDRESS3%TYPE DEFAULT NULL,
                                  p_address4            IN  HZ_LOCATIONS.ADDRESS4%TYPE DEFAULT NULL,
                                  p_postal_code         IN  HZ_LOCATIONS.POSTAL_CODE%TYPE DEFAULT NULL,
                                  p_location_tbl        OUT NOCOPY LOCATION_TBL_TYPE,
                                  p_count               OUT NOCOPY NUMBER) IS

    l_addr_key     VARCHAR2(2000);
    l_post_key     VARCHAR2(2000);
    l_location_id  NUMBER;
    l_location_tbl LOCATION_TBL_TYPE;
    l_count        NUMBER := 0;

    CURSOR c_locations (X_Addr_Key VARCHAR2, X_Post_Key VARCHAR2)
    IS
      SELECT location_id
      FROM   hz_locations
      WHERE  address_key like X_Addr_Key||'%'||X_Post_Key||'%';

  begin
    -- generate the key with only the address part (not including postal code)
    l_addr_key := Generate_Key (
                                p_key_type => 'ADDRESS',
                                p_address1 => p_address1,
                                p_address2 => p_address2,
                                p_address3 => p_address3,
                                p_address4 => p_address4
                               );

    -- generate the key with only the postal code part (not including address fields)
    l_post_key := Generate_Key (
                                p_key_type => 'ADDRESS',
                                p_postal_code => p_postal_code
                               );

    -- get all the locations which has key value l_addr_key%l_post_key%
    FOR loc in c_locations (l_addr_key, l_post_key)
    LOOP
      l_count := l_count + 1;
      l_location_tbl (l_count) := loc.location_id;
    END LOOP;

    p_location_tbl := l_location_tbl;
    p_count := l_count;

  end Fuzzy_Search_Address;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |     Fuzzy_Search_Party                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Public procedure for doing fuzzy search for party. In case of an      |
 |     organization search, pass party_name and in case of person search     |
 |     pass forst_name and last_name. The number of duplicate records found  |
 |     is returned in p_count and list of party ids is returned in           |
 |     p_party_tbl.                                                          |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                               p_party_type                                |
 |                               p_party_name                                |
 |                               p_first_name                                |
 |                               p_last_name                                 |
 |              OUT:                                                         |
 |                               p_party_tbl                                 |
 |                               p_count                                     |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : None                                                         |
 |                                                                           |
 | NOTES      : This does fuzzy search based on the generated key only.      |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/


  PROCEDURE Fuzzy_Search_Party(
                                  p_party_type          IN  HZ_PARTIES.PARTY_TYPE%TYPE,
                                  p_party_name          IN  HZ_PARTIES.PARTY_NAME%TYPE DEFAULT NULL,
                                  p_first_name          IN  HZ_PARTIES.PERSON_FIRST_NAME%TYPE DEFAULT NULL,
                                  p_last_name           IN  HZ_PARTIES.PERSON_LAST_NAME%TYPE DEFAULT NULL,
                                  p_party_tbl           OUT NOCOPY PARTY_TBL_TYPE,
                                  p_count               OUT NOCOPY NUMBER) IS

    l_first_name_key VARCHAR2(2000);
    l_last_name_key  VARCHAR2(2000);
    l_party_name_key VARCHAR2(2000);
    l_party_id       NUMBER;
    l_party_tbl      PARTY_TBL_TYPE;
    l_count          NUMBER := 0;

    CURSOR c_org_parties (X_Party_Name_Key VARCHAR2)
    IS
      SELECT party_id
      FROM   hz_parties
      WHERE  customer_key like X_Party_Name_Key||'%'
      AND    party_type = 'ORGANIZATION';

    CURSOR c_per_parties (X_First_Name_Key VARCHAR2, X_Last_Name_Key VARCHAR2)
    IS
      SELECT party_id
      FROM   hz_parties
      WHERE  customer_key like X_Last_Name_Key||'%'||X_First_Name_Key||'%'
      AND    party_type = 'PERSON';

  begin
    -- if party type is organization then
    IF p_party_type = 'ORGANIZATION'
    THEN
      -- generate the key for the organization type party
      l_party_name_key := Generate_Key (
                                p_key_type => 'ORGANIZATION',
                                p_party_name => p_party_name
                               );

      -- get all the parties which has key value l_party_name_key%
      FOR org in c_org_parties (l_party_name_key)
      LOOP
        l_count := l_count + 1;
        l_party_tbl (l_count) := org.party_id;
      END LOOP;
    -- else if party type is person then
    ELSIF p_party_type = 'PERSON'
    THEN
      -- generate the key for the person type party
      -- first generate last name key
      l_last_name_key := Generate_Key (
                                p_key_type => 'PERSON',
                                p_last_name => p_last_name
                               );
      -- then generate first name key
      l_first_name_key := Generate_Key (
                                p_key_type => 'PERSON',
                                p_first_name => p_first_name
                               );

      -- get all the parties which has key value l_last_name_key%l_first_name_key%
      FOR per in c_per_parties (l_first_name_key, l_last_name_key)
      LOOP
        l_count := l_count + 1;
        l_party_tbl(l_count) := per.party_id;
      END LOOP;
    END IF;

    -- prepare the return parameters
    p_party_tbl := l_party_tbl;
    p_count := l_count;

  end Fuzzy_Search_Party;

END HZ_FUZZY_PUB;

/
