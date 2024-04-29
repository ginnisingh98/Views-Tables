--------------------------------------------------------
--  DDL for Package Body HZ_COMMON_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_COMMON_PUB" AS
/*$Header: ARHCOMMB.pls 120.15.12010000.2 2010/03/04 11:36:43 rgokavar ship $ */

-- Bug 2444678: Removed caching.

-- added for mix-n-match.
-- G_ENTITY_NAME                       VARCHAR2(30);
-- G_ENTITY_ATTR_ID                    NUMBER;
--G_DATA_SOURCES                      VARCHAR2(200);


/* SSM SST Integration and Extension.
 |
 | --  private function for bug fix 2969850
 |
 | FUNCTION getNotSelectedDataSource(
 |    p_data_source                 IN     VARCHAR2
 | ) RETURN VARCHAR2;
 */

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              commit_transaction                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Commits transaction.                                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Rashmi Goyal   08-OCT-99  Created                                      |
 |                                                                           |
 +===========================================================================*/

procedure commit_transaction IS
BEGIN
        commit;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              rollback_transaction                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Rollbacks transaction.                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Rashmi Goyal   08-OCT-99  Created                                      |
 |                                                                           |
 +===========================================================================*/

procedure rollback_transaction IS
BEGIN
        rollback;
END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |              is_TCA_installed                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Checks if TCA is installed.                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Rashmi Goyal   08-OCT-99  Created                                      |
 |                                                                           |
 +===========================================================================*/

function is_TCA_installed RETURN BOOLEAN IS
        l_installed     NUMBER;
        l_user_schema  VARCHAR2(32) := USER;
BEGIN
        -- Bug 4956173
        SELECT 1
        INTO l_installed
        FROM sys.all_source
        WHERE name = 'HZ_PARTY_V2PUB'
        AND type = 'PACKAGE BODY'
        AND owner = l_user_schema
        AND rownum=1;

        IF l_installed = 1 THEN
                RETURN TRUE;
        ELSE
                RETURN FALSE;
        END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END;

/*===========================================================================+
 | PROCEDURE
 |              validate_lookup
 |
 | DESCRIPTION
 |              Validate lookup code.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                     p_lookup_type
 |                     p_column
 |                     p_column_value
 |              OUT:
 |          IN/ OUT:
 |                     x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rashmi Goyal   08-OCT-99  Created
 |    Jianying Huang 31-JAN-01  Bug 1621845: Replace count(*)
 |                       with 'select 'Y'..and rownum=1
 |    Jianying Huang 12-FEB-01  Bug 1639630: Check 'YES/NO' lookup code by comparision
 |                      instead of query.
 |
 +===========================================================================*/

procedure validate_lookup(
        p_lookup_type           IN      VARCHAR2,
        p_column                IN      VARCHAR2,
        p_column_value          IN      VARCHAR2,
        x_return_status         IN OUT NOCOPY  VARCHAR2
) IS

    CURSOR c_exist IS
       SELECT 'Y'
       FROM   ar_lookups
       WHERE  lookup_type = p_lookup_type
       AND    lookup_code = p_column_value
       AND    ROWNUM = 1;

    l_exist    VARCHAR2(1);
    l_error    BOOLEAN;

BEGIN

    IF p_column_value IS NOT NULL AND
       p_column_value <> FND_API.G_MISS_CHAR THEN

       IF p_lookup_type = 'YES/NO' THEN
          IF p_column_value NOT IN ('Y', 'N') THEN
             l_error := TRUE;
          END IF;
       ELSE
          OPEN c_exist;
          FETCH c_exist INTO l_exist;

          IF c_exist%NOTFOUND THEN
             l_error := TRUE;
          END IF;

          CLOSE c_exist;
       END IF;

       IF l_error THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_LOOKUP');
          FND_MESSAGE.SET_TOKEN('COLUMN', p_column);
          FND_MESSAGE.SET_TOKEN('LOOKUP_TYPE', p_lookup_type);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF;

END;

PROCEDURE validate_fnd_lookup
( p_lookup_type   IN     VARCHAR2,
  p_column        IN     VARCHAR2,
  p_column_value  IN     VARCHAR2,
  x_return_status IN OUT NOCOPY VARCHAR2)
IS
 CURSOR c1
 IS
 SELECT 'Y'
   FROM fnd_lookup_values
  WHERE lookup_type = p_lookup_type
    AND lookup_code = p_column_value
    AND ROWNUM      = 1;
 l_exist VARCHAR2(1);
BEGIN
 IF (    p_column_value IS NOT NULL
     AND p_column_value <> fnd_api.g_miss_char ) THEN
   OPEN c1;
    FETCH c1 INTO l_exist;
    IF c1%NOTFOUND THEN
     fnd_message.set_name('AR','HZ_API_INVALID_LOOKUP');
     fnd_message.set_token('COLUMN',p_column);
     fnd_message.set_token('LOOKUP_TYPE',p_lookup_type);
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_error;
    END IF;
   CLOSE c1;
 END IF;
END validate_fnd_lookup;

/*===========================================================================+
 | FUNCTION                                                                  |
 |              get_account_number                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Gets unique account_number.                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Chirag Mehta   17-AUG-00  Created                                      |
 |                                                                           |
 +===========================================================================*/


function get_account_number RETURN NUMBER IS

l_count number;
l_account_number varchar2(30);
BEGIN
l_count :=1;
        WHILE l_count > 0 LOOP
               SELECT to_char(hz_account_num_s.nextval)
               INTO l_account_number FROM dual;
                SELECT COUNT(*) INTO l_count
                        FROM hz_cust_accounts
                        WHERE account_number = l_account_number;

                END LOOP;
                RETURN l_account_number;
END get_account_number;

/*===========================================================================+
 | FUNCTION                                                                  |
 |              get_party_site_number                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Gets unique party_site_number.                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Chirag Mehta   17-AUG-00  Created                                      |
 |                                                                           |
 +===========================================================================*/


function get_party_site_number RETURN NUMBER IS

l_count number;
l_party_site_number varchar2(30);
BEGIN
l_count :=1;
        WHILE l_count > 0 LOOP
               SELECT to_char(hz_party_site_number_s.nextval)
               INTO l_party_site_number FROM dual;
                SELECT COUNT(*) INTO l_count
                        FROM hz_party_sites
                        WHERE party_site_number = l_party_site_number;

                END LOOP;
                RETURN l_party_site_number;
END get_party_site_number ;


FUNCTION content_source_type_security(
    p_object_schema                 IN     VARCHAR2,
    p_object_name                   IN     VARCHAR2
) RETURN VARCHAR2 IS
    l_predicate                     VARCHAR2(4000);
    l_context                       VARCHAR2(10);
    l_entity_attr_id                NUMBER := null;
    l_data_sources                  VARCHAR2(400);
    l_not_data_source               VARCHAR2(4000);
BEGIN

  l_context := NVL(SYS_CONTEXT('hz', 'dnb_used'),'N');

  IF l_context <> 'Y' THEN
    IF p_object_name IN (
         'HZ_ORGANIZATION_PROFILES', 'HZ_PERSON_PROFILES')
    THEN
      --Bug9063717 - Removed NVL Condition.
      --l_predicate := 'NVL(actual_content_source,content_source_type) = ''SST''';
        l_predicate := 'actual_content_source = ''SST''';

	-- SSM SST Integration and Extension
	-- Concept of select/de-select data sources is done away with for non-profile entities.
  /*ELSE
      IF p_object_name NOT IN ('HZ_CODE_ASSIGNMENTS', 'HZ_ORGANIZATION_INDICATORS') THEN

        -- Bug 2444678: Removed caching.

        -- IF p_object_name <> NVL(G_ENTITY_NAME, 'null') THEN
        l_data_sources := HZ_MIXNM_UTILITY.getSelectedDataSources(p_object_name, l_entity_attr_id);
        l_not_data_source := getNotSelectedDataSource (l_data_sources);
        -- G_ENTITY_NAME := p_object_name;
        -- END IF;
*/
/* Bug 2780113- fix for DNB hierarchy project */
/*
        IF p_object_name = 'HZ_PARTY_SITES' THEN
          l_predicate := 'actual_content_source NOT IN ('||l_not_data_source||')';
        ELSE
            l_predicate := 'NVL(actual_content_source,content_source_type) NOT IN ('||l_not_data_source||')';
        END IF;

      ELSE
        l_predicate := 'content_source_type = ''USER_ENTERED''';
      END IF;
    */
    END IF;
  END IF;

/*
  l_predicate := '((SYS_CONTEXT(''hz'', ''dnb_used'')=''Y'')' ||
                 'OR ' ||
                 '((SYS_CONTEXT(''hz'', ''dnb_used'') IS NULL OR ' ||
                 ' SYS_CONTEXT(''hz'', ''dnb_used'')=''N'') and ' ||
                 'content_source_type=''USER_ENTERED''))';
*/

  RETURN l_predicate;

END;


procedure enable_cont_source_security IS
BEGIN
  DBMS_SESSION.SET_CONTEXT('hz', 'dnb_used', 'N');
END;

procedure disable_cont_source_security IS
BEGIN
  DBMS_SESSION.SET_CONTEXT('hz', 'dnb_used', 'Y');
END;


function get_cust_address(v_address_id number) return varchar2 is

v_return varchar2(4000);

cursor c is
select
c.ADDRESS1 || DECODE(c.ADDRESS1, NULL, NULL, ' ') || c.ADDRESS2
 || DECODE(c.ADDRESS2, NULL, NULL, ' ') || c.ADDRESS3 ||
 DECODE(c.ADDRESS3, NULL, NULL, ' ') || c.ADDRESS4 ||
 DECODE(c.ADDRESS1, NULL, NULL, ', ') || c.CITY || DECODE(c.CITY,
 NULL, NULL, ', ') || c.STATE || DECODE(c.STATE, NULL, NULL, ' ') ||
 c.POSTAL_CODE || DECODE(d.TERRITORY_SHORT_NAME, NULL, NULL, ', ')
 || d.TERRITORY_SHORT_NAME
from hz_cust_acct_sites_all a, hz_party_sites b, hz_locations c,fnd_territories_vl d
where a.party_site_id =b.party_site_id
and  b.location_id = c.location_id
and d.territory_code = c.country
and a.cust_acct_site_id = v_address_id;

begin
  if v_address_id is not null then
   open c;
   fetch c into v_return;
   close c;
  end if;

   return  v_return;
end;

function get_cust_name(v_cust_id number) return varchar2 is

v_return hz_parties.party_name%type;

cursor c is
select  b.party_name
from   hz_cust_accounts a, hz_parties b
where a.cust_account_id = v_cust_id
and   a.party_id = b.party_id;

begin
  if v_cust_id is not null then
   open c;
   fetch c into v_return;
   close c;
  end if;

   return  v_return;
end;

function get_cust_contact_name(v_contact_id number) return varchar2 is

v_return hz_parties.party_name%type;

cursor c is
select  b.person_first_name||' '||b.person_last_name
from   hz_cust_account_roles a,
       hz_parties b,
       hz_relationships c
where a.cust_account_role_id = v_contact_id
and   c.party_id =a.party_id
and   c.subject_id = b.party_id
and   c.subject_table_name = 'HZ_PARTIES'
and   c.object_table_name = 'HZ_PARTIES'
and   c.directional_flag = 'F';

begin
  if v_contact_id is not null then
   open c;
   fetch c into v_return;
   close c;
  end if;

   return  v_return;
end;

function get_party_name(v_party_id number) return varchar2 is

v_return hz_parties.party_name%type;

cursor c is
select  b.party_name
from  hz_parties b
where b.party_id = v_party_id;

begin
  if v_party_id is not null then
   open c;
   fetch c into v_return;
   close c;
  end if;

   return  v_return;
end;

procedure check_mandatory_str_col
-- Control mandatory column for varchar2 type
--         create update flag belongs to [C (creation) ,U (update)]
--         Column name
--         Column Value
--         Allow Null in creation mode flag
--         Allow Null in update mode flag
--         Control Status
(       create_update_flag              IN  VARCHAR2,
        p_col_name                              IN  VARCHAR2,
        p_col_val                               IN  VARCHAR2,
        p_miss_allowed_in_c             IN  BOOLEAN,
        p_miss_allowed_in_u             IN  BOOLEAN,
        x_return_status                 IN OUT NOCOPY VARCHAR2)
IS
BEGIN
        IF (p_col_val IS NULL) THEN
                fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                fnd_message.set_token('COLUMN', p_col_name);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
                RETURN;
        END IF;

        IF (create_update_flag = 'C') THEN
                IF ((NOT p_miss_allowed_in_c) AND
                        p_col_val = fnd_api.G_MISS_CHAR )
                THEN
                        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        ELSE
                IF ((NOT p_miss_allowed_in_u) AND
                        p_col_val = fnd_api.G_MISS_CHAR )
                THEN
                        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        END IF;
END check_mandatory_str_col;

procedure check_mandatory_date_col
-- Control mandatory column for date type
--         create update flag belongs to [C (creation) ,U (update)]
--         Column name
--         Column Value
--         Allow Null in creation mode flag
--         Allow Null in update mode flag
--         Control Status
(       create_update_flag              IN  VARCHAR2,
        p_col_name                              IN      VARCHAR2,
        p_col_val                               IN  DATE,
        p_miss_allowed_in_c             IN  BOOLEAN,
        p_miss_allowed_in_u             IN  BOOLEAN,
        x_return_status                 IN OUT NOCOPY VARCHAR2)
IS
BEGIN
        IF (p_col_val IS NULL) THEN
                fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                fnd_message.set_token('COLUMN', p_col_name);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
                RETURN;
        END IF;

        IF (create_update_flag = 'C') THEN
                IF ((NOT p_miss_allowed_in_c) AND
                        p_col_val = fnd_api.G_MISS_DATE )
                THEN
                        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        ELSE
                IF ((NOT p_miss_allowed_in_u) AND
                        p_col_val = fnd_api.G_MISS_DATE )
                THEN
                        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        END IF;
END check_mandatory_date_col;

procedure check_mandatory_num_col
-- Control mandatory column for number type
--         create update flag belongs to [C (creation) ,U (update)]
--         Column name
--         Column Value
--         Allow Null in creation mode flag
--         Allow Null in update mode flag
--         Control Status
(       create_update_flag              IN  VARCHAR2,
        p_col_name                              IN  VARCHAR2,
        p_col_val                               IN  NUMBER,
        p_miss_allowed_in_c             IN  BOOLEAN,
        p_miss_allowed_in_u             IN  BOOLEAN,
        x_return_status                 IN OUT NOCOPY VARCHAR2)
IS
BEGIN
        IF (p_col_val IS NULL) THEN
                fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                fnd_message.set_token('COLUMN', p_col_name);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
                RETURN;
        END IF;

        IF (create_update_flag = 'C') THEN
                IF ((NOT p_miss_allowed_in_c) AND
                        p_col_val = fnd_api.G_MISS_NUM )
                THEN
                        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        ELSE
                IF ((NOT p_miss_allowed_in_u) AND
                        p_col_val = fnd_api.G_MISS_NUM )
                THEN
                        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
                        fnd_message.set_token('COLUMN', p_col_name);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                END IF;
        END IF;
END check_mandatory_num_col;

FUNCTION compare(
        date1 DATE,
        date2 DATE) RETURN NUMBER
IS
  ldate1 date;
  ldate2 date;
BEGIN
  ldate1 := trunc(date1);
  ldate2 := trunc(date2);
        IF (ldate1 IS NULL AND ldate2 IS NULL) THEN
                RETURN 0;
        ELSIF (ldate2 IS NULL) THEN
                RETURN -1;
        ELSIF (ldate1 IS NULL) THEN
                RETURN 1;
        ELSIF ( ldate1 = ldate2 ) THEN
                RETURN 0;
        ELSIF ( ldate1 > ldate2 ) THEN
                RETURN 1;
        ELSE
                RETURN -1;
        END IF;
END compare;

  --
  -- FUNCTION time_compare
  --
  -- DESCRIPTION
  --   Time-sensitive version of compare
  --   NULL indicates infinite date
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     datetime1       Date 1.
  --     datetime2       Date 2.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   13-DEC-2001   Joe del Callar     Bug 2145637: Created.
  --
  FUNCTION time_compare(datetime1 IN DATE, datetime2 IN DATE) RETURN NUMBER IS
  BEGIN
    IF datetime1 IS NULL AND datetime2 IS NULL THEN
      RETURN 0;
    ELSIF datetime2 IS NULL THEN
      RETURN -1;
    ELSIF datetime1 IS NULL THEN
      RETURN 1;
    ELSIF datetime1 = datetime2 THEN
      RETURN 0;
    ELSIF datetime1 > datetime2 THEN
      RETURN 1;
    ELSE
      RETURN -1;
    END IF;
  END time_compare;


-- NULL indicates infinite
FUNCTION is_between
( datex DATE,
  date1 DATE,
  date2 DATE) RETURN BOOLEAN
IS
BEGIN
 IF compare(datex, date1) >= 0 AND
    compare(date2, datex) >=0 THEN
     RETURN TRUE;
 ELSE
     RETURN FALSE;
 END IF;
END is_between;

  --
  -- FUNCTION is_time_between
  --
  -- DESCRIPTION
  --   Returns 'Y' if period datex is between datetime1 and datetime2 with time
  --           considered.
  --           'N' otherwise
  --   NULL indicates infinite date
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     datetimex       Date being tested for "betweenness"
  --     datetime1       Start date/time of period.
  --     datetime2       End date/time of period.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   13-DEC-2001   Joe del Callar     Bug 2145637: Created.
  --
  FUNCTION is_time_between (
    datetimex   IN      DATE,
    datetime1   IN      DATE,
    datetime2   IN      DATE
  ) RETURN BOOLEAN IS
  BEGIN
    IF time_compare(datetimex, datetime1) >= 0
       AND time_compare(datetime2, datetimex) >=0
    THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END is_time_between;

-- NULL indicates infinite
FUNCTION is_overlap
-- Returns 'Y' if period [s1,e1] overlaps [s2,e2]
--         'N' otherwise
--         NULL indicates infinite for END dates
(s1 DATE,
 e1 DATE,
 s2 DATE,
 e2 DATE)
RETURN VARCHAR2
IS
BEGIN
 IF ( is_between(s1, s2, e2) ) OR ( is_between(s2, s1, e1) ) THEN
   RETURN 'Y';
 ELSE
   RETURN 'N';
 END IF;
END is_overlap;

  --
  -- FUNCTION is_time_overlap
  --
  -- DESCRIPTION
  --   Returns 'Y' if period [s1,e1] overlaps [s2,e2] with time factored in
  --           'N' otherwise
  --   NULL indicates infinite for END dates
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     s1              Start date/time of period 1.
  --     e1              End date/time of period 1.
  --     s2              Start date/time of period 1.
  --     e2              End date/time of period 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   13-DEC-2001   Joe del Callar     Bug 2145637: Created.
  --

  FUNCTION is_time_overlap (
    s1          IN      DATE,
    e1          IN      DATE,
    s2          IN      DATE,
    e2          IN      DATE
  ) RETURN VARCHAR2 IS
  BEGIN
    IF (is_time_between(s1, s2, e2)) OR (is_time_between(s2, s1, e1)) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  END is_time_overlap;


-- Return varchar2 with a set of characters non desired.
-- Please pass the input in uppercase as this assumes so.
-- This is currently called just from HZ_FUZZY_PUB, if you
-- intend to call it from any other program, make sure this
-- logic works for that.
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
 for i in 1..length(str2)-1
 loop
   -- if two consecutive letters match, then replace two such letter
   -- by one letter from the temporary string
   if substr(str2,i,1) = substr(str2,i+1,1) then
     str3 := replace(str3, substr(str2,i,1)||substr(str2,i+1,1), substr(str2,i,1));
   end if;
 end loop;

 str2 := str3;

 -- Step 2. Replace Vowels only that occur inside
 -- First we should build a temporary string
 -- which would be the original string str2
 -- stripped off the first letter
 str3 := substr(str2, 2);

 -- Now call replace to remove all occurrences
 -- of each vowel
 str3 := replace(str3, 'A', '');
 str3 := replace(str3, 'E', '');
 str3 := replace(str3, 'I', '');
 str3 := replace(str3, 'O', '');
 str3 := replace(str3, 'U', '');

 -- Now we have to build str2 back with
 -- first letter of str2 and appending str3
 str2 := substr(str2, 1, 1)||str3;

 -- return str2 which is the final clean word
 return rtrim(str2);

END cleanse;

/* SSM SST Integration And Extension.
 * Predicates will not be attached to non-profile tables.(Concept of select / de-select data sources
 * for these entities is done away with)

-- bug fix 2969850
FUNCTION getNotSelectedDataSource(
    p_data_source                 IN     VARCHAR2
) RETURN VARCHAR2 IS

    CURSOR c_content_source_type IS
      SELECT lookup_code FROM ar_lookups
      WHERE lookup_type = 'CONTENT_SOURCE_TYPE' and
            ENABLED_FLAG = 'Y' AND
	    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE));

    l_not_data_source               VARCHAR2(4000);
    l_content_source_type           VARCHAR2(100);
    l_len                           NUMBER;
BEGIN
  l_not_data_source := '';

  open  c_content_source_type;
  LOOP
    FETCH c_content_source_type INTO l_content_source_type;
    EXIT WHEN c_content_source_type%NOTFOUND;

    IF ( instrb(p_data_source, '''' || l_content_source_type || '''') = 0 ) THEN

       l_not_data_source := l_not_data_source||''''||l_content_source_type||''',';

    END IF;

  END LOOP;

  IF l_not_data_source IS NOT NULL THEN
     l_len := LENGTHB(l_not_data_source);
     IF l_len > 1 THEN
       l_not_data_source := SUBSTRB(l_not_data_source,1,l_len-1);
     END IF;
  END IF;


  RETURN l_not_data_source;
END getNotSelectedDataSource;
*/

/*===========================================================================+
 | PROCEDURE                                                                 |
 |            enable_health_care_security                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |            Enables the VPD security for healthcare module.                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Ramesh Ch      31-OCT-03  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE enable_health_care_security IS
BEGIN
  DBMS_SESSION.SET_CONTEXT('hz','hcare_used', 'Y');
END enable_health_care_security;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |            disable_health_care_security                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |            Disables the VPD security for healthcare module.               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Ramesh Ch      31-OCT-03  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE disable_health_care_security IS
BEGIN
  DBMS_SESSION.SET_CONTEXT('hz', 'hcare_used', 'N');
END disable_health_care_security;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |            add_hcare_policy_function                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |            Adds the hcare_created_by_module_sec policy function to        |
 |            HZ_PARTIES,HZ_PERSON_PROFILES,HZ_LOCATIONS,HZ_PARTY_SITES,     |
 |            HZ_PARTY_SITE_USES,HZ_CITIZENSHIP,HZ_PERSON_LANGUAGE and       |
 |            HZ_CONTACT_POINTS.                                             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Ramesh Ch      31-OCT-03  Created                                      |
 |    Ramesh Ch      08-NOV-03 Commented the policy function for             |
 |                             HZ_CITIZENSHIP entity.                        |
 +===========================================================================*/

PROCEDURE add_hcare_policy_function
IS

     l_ar_schema          VARCHAR2(30);
     l_apps_schema        VARCHAR2(30);
     l_aol_schema         VARCHAR2(30);
     l_apps_mls_schema    VARCHAR2(30);

     l_status             VARCHAR2(30);
     l_industry           VARCHAR2(30);
     l_return_value       BOOLEAN;

BEGIN

arp_util.debug('add_hcare_policy_function (+) ');

     --Get ar and apps schema name
     l_return_value := fnd_installation.get_app_info(
           'AR', l_status, l_industry, l_ar_schema);

     IF NOT l_return_value THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_return_value := fnd_installation.get_app_info(
           'FND', l_status, l_industry, l_aol_schema);

     IF NOT l_return_value THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     system.ad_apps_private.get_apps_schema_name(
          1, l_aol_schema, l_apps_schema, l_apps_mls_schema);

     --Add policy functions
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_PARTIES', 'hcare_created_by_module_sec', l_apps_schema, 'hz_common_pub.hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_PERSON_PROFILES', 'hcare_created_by_module_sec', l_apps_schema, 'hz_common_pub.hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_LOCATIONS', 'hcare_created_by_module_sec', l_apps_schema, 'hz_common_pub.hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_PARTY_SITES', 'hcare_created_by_module_sec', l_apps_schema, 'hz_common_pub.hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_PARTY_SITE_USES', 'hcare_created_by_module_sec', l_apps_schema, 'hz_common_pub.hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_CITIZENSHIP', 'hcare_created_by_module_sec', l_apps_schema, 'hz_common_pub.hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_PERSON_LANGUAGE','hcare_created_by_module_sec', l_apps_schema, 'hz_common_pub.hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_CONTACT_POINTS', 'hcare_created_by_module_sec', l_apps_schema, 'hz_common_pub.hcare_created_by_module_sec');

arp_util.debug('add_hcare_policy_function (-) ');

END add_hcare_policy_function;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |            drop_hcare_policy_function                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |            Drops the hcare_created_by_module_sec policy function which    |
 |            was already added to HZ_PARTIES,HZ_PERSON_PROFILES,            |
 |            HZ_LOCATIONS,HZ_PARTY_SITES,HZ_PARTY_SITE_USES,HZ_CITIZENSHIP, |
 |            HZ_PERSON_LANGUAGE and HZ_CONTACT_POINTS.                      |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Ramesh Ch      31-OCT-03  Created                                      |
 |    Ramesh Ch      08-NOV-03 Commented the policy function for             |
 |                             HZ_CITIZENSHIP entity.                        |
 |                                                                           |
 +===========================================================================*/

PROCEDURE drop_hcare_policy_function
IS

     l_ar_schema          VARCHAR2(30);
     l_apps_schema        VARCHAR2(30);
     l_aol_schema         VARCHAR2(30);
     l_apps_mls_schema    VARCHAR2(30);

     l_status             VARCHAR2(30);
     l_industry           VARCHAR2(30);
     l_return_value       BOOLEAN;

BEGIN

arp_util.debug('drop_hcare_policy_function (+) ');

     --Get ar and apps schema name
     l_return_value := fnd_installation.get_app_info(
           'AR', l_status, l_industry, l_ar_schema);

     IF NOT l_return_value THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_return_value := fnd_installation.get_app_info(
           'FND', l_status, l_industry, l_aol_schema);

     IF NOT l_return_value THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     system.ad_apps_private.get_apps_schema_name(
          1, l_aol_schema, l_apps_schema, l_apps_mls_schema);

     --Drop policy functions
     FND_ACCESS_CONTROL_UTIL.DROP_POLICY(l_ar_schema, 'HZ_PARTIES', 'hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.DROP_POLICY(l_ar_schema, 'HZ_PERSON_PROFILES', 'hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.DROP_POLICY(l_ar_schema, 'HZ_LOCATIONS', 'hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.DROP_POLICY(l_ar_schema, 'HZ_PARTY_SITES', 'hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.DROP_POLICY(l_ar_schema, 'HZ_PARTY_SITE_USES', 'hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.DROP_POLICY(l_ar_schema, 'HZ_CITIZENSHIP', 'hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.DROP_POLICY(l_ar_schema, 'HZ_PERSON_LANGUAGE','hcare_created_by_module_sec');
     FND_ACCESS_CONTROL_UTIL.DROP_POLICY(l_ar_schema, 'HZ_CONTACT_POINTS', 'hcare_created_by_module_sec');

arp_util.debug('drop_hcare_policy_function (-) ');

END drop_hcare_policy_function;

/*===========================================================================+
 | FUNCTION                                                                  |
 |            hcare_created_by_module_sec                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |           Policy Function                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_object_schema: Entity Schema Name.                         |
 |              p_object_name  : Entity Name.                                |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : Dynamic where clause based on the context value.             |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Ramesh Ch      31-OCT-03  Created                                      |
 |                                                                           |
 +===========================================================================*/

FUNCTION hcare_created_by_module_sec(p_object_schema IN  VARCHAR2,p_object_name IN VARCHAR2)
RETURN VARCHAR2
IS
l_context VARCHAR2(10);
BEGIN
 l_context := NVL(SYS_CONTEXT('hz', 'hcare_used'),'Y');

 IF l_context <> 'N' THEN
  return 'CREATED_BY_MODULE<>''HTBPERSON''';
 ELSE RETURN NULL;
 END IF;
END hcare_created_by_module_sec;


END;

/
