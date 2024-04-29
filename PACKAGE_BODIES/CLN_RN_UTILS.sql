--------------------------------------------------------
--  DDL for Package Body CLN_RN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_RN_UTILS" AS
/* $Header: CLNRNUTB.pls 120.8 2006/04/06 01:41:36 amchaudh noship $ */
    -- Name
    --   CONVERT_TO_RN_TIMEZONE (Internal Function)
    -- Purpose
    --   Converts a date value from server time zone into RosettaNet time zone
    -- Arguments
    --   Date
    -- Notes
    --
l_debug_level NUMBER  := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
  PROCEDURE CONVERT_TO_RN_TIMEZONE(
     p_input_date               IN DATE,
     x_utc_date                 OUT NOCOPY DATE )
  IS
     l_error_code               NUMBER;
     l_db_timezone              VARCHAR2(30);
     l_rn_timezone              VARCHAR2(30);
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN
     IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('----- Entering CONVERT_TO_RN_TIMEZONE API ------- ',2);
     END IF;
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('Date Entered by the user    -->'||p_input_date,1);
     END IF;
     -- get the timezone of the db server
     l_db_timezone := FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE;
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('TimeZone of the DB server   -->'||l_db_timezone,1);
     END IF;
     l_rn_timezone := fnd_profile.value('CLN_RN_TIMEZONE');
     IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('TimeZone of the UTC        -->'||l_rn_timezone,1);
     END IF;
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('Calling function to convert the datetime to UTC',1);
     END IF;
     -- this function converts the datetime from the user entered/db timezone to UTC
     x_utc_date         := FND_TIMEZONES_PVT.adjust_datetime(p_input_date,l_db_timezone,l_rn_timezone);
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('Date in UTC format          -->'||x_utc_date,1);
     END IF;
     IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('----- Exiting CONVERT_TO_RN_TIMEZONE API ------- ',2);
     END IF;
  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- ERROR: Exiting CONVERT_TO_RN_TIMEZONE API --------- ',5);
             END IF;
  END CONVERT_TO_RN_TIMEZONE;
    -- Name
    --   CONVERT_TO_RN_DATETIME
    -- Purpose
    --   Converts a date value into RosettaNet datetime format
    --   RosettaNet Datetime Format: YYYYMMDDThhmmss.SSSZ
    -- Arguments
    --   Date
    -- Notes
    --   If the date passed is NULL, then sysdate is considered.
  PROCEDURE CONVERT_TO_RN_DATETIME(
     p_server_date              IN DATE,
     x_rn_datetime              OUT NOCOPY VARCHAR2)
  IS
     l_error_code               NUMBER;
     l_utc_date                 DATE;
     l_milliseconds             VARCHAR2(5);
     l_server_timezone          VARCHAR2(30);
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN
     IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('----- Entering CONVERT_TO_RN_DATETIME API ------- ',2);
     END IF;
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('User Entered Date      --> '||p_server_date,1);
     END IF;
     IF(p_server_date is null) THEN
        x_rn_datetime := null;
        IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('Null is passed. So exiting the procedure with null as return',1);
        END IF;
        RETURN;
     END IF;
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('Call CONVERT_TO_RN_TIMEZONE API....... ',1);
     END IF;
     CONVERT_TO_RN_TIMEZONE(
        p_input_date          =>  p_server_date,
        x_utc_date            =>  l_utc_date );
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('TimeStamp as per UTC       '||l_utc_date,1);
     END IF;
     l_milliseconds := '000'; --We wont get milliseconds
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('Truncated Millisecond       '||l_milliseconds,1);
     END IF;
     x_rn_datetime := TO_CHAR(l_utc_date,'YYYYMMDD')||'T'||TO_CHAR(l_utc_date,'hh24miss')||'.'||l_milliseconds||'Z';
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('Date in Rosettanet Format '||x_rn_datetime,1);
     END IF;
     IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('----- Exiting CONVERT_TO_RN_DATETIME API ------- ',2);
     END IF;
  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- ERROR: Exiting CONVERT_TO_RN_DATETIME API --------- ',5);
             END IF;
  END CONVERT_TO_RN_DATETIME;
    -- Name
    --   CONVERT_TO_RN_DATE
    -- Purpose
    --   Converts a date value into RosettaNet date format
    --   RosettaNet Date Format: YYYYMMDDZ
    -- Arguments
    --   Date
    -- Notes
    --   If the date passed is NULL, then sysdate is considered.
  PROCEDURE CONVERT_TO_RN_DATE(
     p_server_date              IN DATE,
     x_rn_date                  OUT NOCOPY VARCHAR2)
  IS
     l_utc_date                 DATE;
     l_milliseconds             VARCHAR2(5);
     l_server_timezone          VARCHAR2(50);
     l_error_code               NUMBER;
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN
      IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('----- Entering CONVERT_TO_RN_DATETIME API ------- ',2);
      END IF;
      IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('User Entered Date '||p_server_date,1);
      END IF;
     IF(p_server_date is null) THEN
        x_rn_date := null;
        IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('Null is passed. So exiting the procedure with NULL as return',1);
        END IF;
        RETURN;
     END IF;
      x_rn_date :=  TO_CHAR(p_server_date,'YYYYMMDD')||'Z';
      IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('Date in Rosettanet Format '||x_rn_date,1);
      END IF;
      IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('----- Exiting CONVERT_TO_RN_DATE API ------- ',2);
      END IF;
  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- ERROR: Exiting CONVERT_TO_RN_DATE API --------- ',5);
             END IF;
  END CONVERT_TO_RN_DATE;
      -- Name
      --   CONVERT_TO_DB_DATE
      -- Purpose
      --   Converts a date value from RosettaNet date/datetime format to db format
      --   RosettaNet Datetime Format: YYYYMMDDThhmmss.SSSZ
      --   RosettaNet Date Format    : YYYYMMDDZ
      -- Arguments
      --   Date
      -- Notes
      --   If the date passed is NULL, then sysdate is considered.
  PROCEDURE CONVERT_TO_DB_DATE(
     p_rn_date                  IN VARCHAR2,
     x_db_date                  OUT NOCOPY DATE)
  IS
     l_server_date              DATE;
     l_utc_datetime             DATE;
     l_count_t_appearanace      NUMBER;
     l_error_code               NUMBER;
     l_rn_frmt_date             VARCHAR2(30);
     l_rn_timezone              VARCHAR2(30);
     l_db_timezone              VARCHAR2(30);
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN
       IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('----- Entering CONVERT_TO_DB_DATE API ------- ',2);
       END IF;
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('Rosettanet Date '||p_rn_date,1);
       END IF;
        IF(p_rn_date is null) THEN
           x_db_date := null;
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Null is passed. So exiting the procedure with NULL as return',1);
           END IF;
           RETURN;
        END IF;
       l_count_t_appearanace := instr(p_rn_date,'T');
       IF (l_count_t_appearanace > 0) THEN
           --Datetime Format: YYYYMMDDThhmmss.SSSZ
           l_rn_timezone := fnd_profile.value('CLN_RN_TIMEZONE');
           IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('TimeZone of the UTC          '||l_rn_timezone,1);
           END IF;
           -- get the timezone of the db server
           l_db_timezone := FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE;
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('TimeZone of the DB server    '||l_db_timezone,1);
           END IF;
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Datetime Format: YYYYMMDDThhmmss.SSSZ',1);
           END IF;
           l_rn_frmt_date     :=    substr(p_rn_date,1,8)||substr(p_rn_date,10,6);
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Date After Formatting (String)'||l_rn_frmt_date,1);
           END IF;
           l_utc_datetime := TO_DATE(l_rn_frmt_date,'YYYYMMDDHH24MISS');
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Date After Formatting (Date)'||l_utc_datetime,1);
           END IF;
           -- this function converts the datetime from the user entered/db timezone to UTC
           x_db_date    := FND_TIMEZONES_PVT.adjust_datetime(l_utc_datetime,l_rn_timezone,l_db_timezone);
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Date after conversion     '||x_db_date,1);
           END IF;
       ELSE
           --Date Format    : YYYYMMDDZ
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Date Format    : YYYYMMDDZ',1);
           END IF;
           l_rn_frmt_date       :=      substr(p_rn_date,1,8);
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Date After Formatting (String) '||l_rn_frmt_date,1);
           END IF;
           x_db_date := TO_DATE(l_rn_frmt_date,'YYYYMMDD');
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Date After Formatting (Date)'||l_utc_datetime,1);
           END IF;
       END IF;
      IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('----- Exiting CONVERT_TO_DB_DATE API ------- ',2);
      END IF;
  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- ERROR: Exiting CONVERT_TO_DB_DATE API --------- ',5);
             END IF;
  END CONVERT_TO_DB_DATE;
    -- Name
    --   CONVERT_Number_To_Char
    -- Purpose
    --   Converts a Number value into a character with the given format
    -- Arguments
    --   Number
    --   Format
    -- Notes
    --   If the date passed is NULL, then sysdate is considered.
   PROCEDURE CONVERT_NUMBER_TO_CHAR(
     p_number               IN NUMBER,
     p_format               IN VARCHAR2,
     x_char                 OUT NOCOPY VARCHAR2)
  IS
     l_error_code               NUMBER;
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN
       IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('----- Entering CONVERT_NUMBER_TO_CHAR API ------- ',2);
       END IF;
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('Passed Number '||p_number,1);
             cln_debug_pub.Add('Passed Format '||p_format,1);
       END IF;
       x_char := TO_CHAR(p_number,p_format);
       IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Number After Formatting'||x_char,1);
       END IF;
       IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('----- Exiting CONVERT_NUMBER_TO_CHAR API ------- ',2);
       END IF;
  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error in CONVERT_NUMBER_TO_CHAR -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- ERROR: Exiting CONVERT_NUMBER_TO_CHAR API --------- ',5);
             END IF;
  END CONVERT_NUMBER_TO_CHAR;
    -- Name
    --   GET_FROM_ROLE
    -- Purpose
    --   Gets the fromRole details
    --   based on the Organization ID
    -- Arguments
    --   Date
    -- Notes
    --   Organization ID
  PROCEDURE GET_FROM_ROLE(
     p_org_id                   IN VARCHAR2,
     x_name                     OUT NOCOPY VARCHAR2,
     x_email                    OUT NOCOPY VARCHAR2,
     x_telephone                OUT NOCOPY VARCHAR2,
     x_fax                      OUT NOCOPY VARCHAR2,
     x_ece_location_code        OUT NOCOPY VARCHAR2  )
  IS
     l_error_code               NUMBER;
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN
     IF (l_Debug_Level <= 5) THEN
            cln_debug_pub.Add('----- Entering GET_FROM_ROLE -----',2);
     END IF;
     IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Organization ID  ' || p_org_id, 1);
     END IF;
     IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Executing the Query........', 1);
     END IF;
     SELECT org.name
     , null
     , loc.telephone_number_1
     , loc.telephone_number_2
     , loc.ece_tp_location_code
     INTO x_name
     , x_email
     , x_telephone
     , x_fax
     , x_ece_location_code
     FROM hr_locations_all loc,  hr_all_organization_units_vl org
     WHERE org.location_id      = loc.location_id
     AND org.organization_id    = p_org_id;
     IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Result From the Query........', 1);
     END IF;
     IF (l_Debug_Level <= 1) THEN
        cln_debug_pub.Add('Name (From)          :' || x_name, 1);
        cln_debug_pub.Add('Email                :' || x_email, 1);
        cln_debug_pub.Add('Telephone            :' || x_telephone, 1);
        cln_debug_pub.Add('Fax                  :' || x_fax, 1);
        cln_debug_pub.Add('ECE Location Code    :' || x_ece_location_code, 1);
     END IF;
     IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('----- Exiting GET_FROM_ROLE -----',2);
     END IF;
  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- ERROR: Exiting GET_FROM_ROLE API --------- ',5);
             END IF;
  END GET_FROM_ROLE;
    -- Name
    --   GET_TO_ROLE
    -- Purpose
    --   Gets the toRole details
    --   based on the TP Header ID
    -- Arguments
    --   TP Header ID
    -- Notes
    --   No special notes
  PROCEDURE GET_TO_ROLE(
     p_tp_header_id             IN VARCHAR2,
     x_name                     OUT NOCOPY VARCHAR2,
     x_email                    OUT NOCOPY VARCHAR2,
     x_telephone                OUT NOCOPY VARCHAR2,
     x_fax                      OUT NOCOPY VARCHAR2,
     x_ece_location_code        OUT NOCOPY VARCHAR2 )
  IS
     l_party_type               VARCHAR2(30);
     l_party_id                 NUMBER;
     l_party_site_id            NUMBER;
     l_error_code               NUMBER;
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN
     IF (l_Debug_Level <= 2) THEN
        cln_debug_pub.Add('---- Entering GET_TO_ROLE -------',2);
     END IF;
     IF (l_Debug_Level <= 1) THEN
        cln_debug_pub.Add('Trading Partner header_id:' || p_tp_header_id, 1);
     END IF;
     SELECT party_type, party_id, party_site_id
     INTO l_party_type, l_party_id, l_party_site_id
     FROM ECX_TP_HEADERS
     WHERE tp_header_id = p_tp_header_id;
     IF (l_Debug_Level <= 1) THEN
        cln_debug_pub.Add('Party Type        :' || l_party_type, 1);
        cln_debug_pub.Add('Party ID          :' || l_party_id, 1);
        cln_debug_pub.Add('Party Site ID     :' || l_party_site_id, 1);
     END IF;
     IF (l_party_type = 'S') THEN
        SELECT pv.vendor_name,  pvsa.area_code || ' ' || pvsa.phone, pvsa.fax_area_code || ' ' || pvsa.fax,
               pvsa.ece_tp_location_code, pvsa.email_address
        INTO x_name, x_telephone, x_fax, x_ece_location_code, x_email
        FROM  po_vendors pv, po_vendor_sites_all pvsa
        WHERE pv.vendor_id = pvsa.vendor_id
          AND pv.vendor_id = l_party_id
          AND pvsa.vendor_site_id = l_party_site_id;
     ELSIF (l_party_type = 'B') THEN
        SELECT BANK_BRANCH_NAME,hcp.RAW_PHONE_NUMBER,hcp.EDI_ECE_TP_LOCATION_CODE
	INTO x_name, x_telephone, x_ece_location_code
        FROM CE_BANK_BRANCHES_V bb, HZ_PARTIES hp, HZ_contact_points hcp
        WHERE bb.BRANCH_PARTY_ID = l_party_id
              AND  bb.BRANCH_PARTY_ID = hp.party_id
	      AND  hp.PRIMARY_PHONE_CONTACT_PT_ID = hcp.CONTACT_POINT_ID;
     ELSIF (l_party_type = 'I') THEN
        SELECT location_code, telephone_number_1, ece_tp_location_code
        INTO x_name, x_telephone, x_ece_location_code
        FROM HR_LOCATIONS
        WHERE location_id = l_party_id;
     ELSIF (l_party_type = 'C') or  (l_party_type = 'CARRIER')  THEN
        SELECT hz.party_name
        INTO x_name
        FROM hz_parties hz
        WHERE hz.party_id = l_party_id;
        BEGIN
           Select phone_number, email_address
           Into   x_telephone, x_email
           From   hz_contact_points
           Where  owner_table_name = 'HZ_PARTIES'
             and  owner_table_id = l_party_id
             and rownum < 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             --Contact information not available
              IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Contact information not available', 1);
              END IF;
        END;
     END IF;
     IF (l_Debug_Level <= 1) THEN
        cln_debug_pub.Add('Party Name        :' || x_name, 1);
        cln_debug_pub.Add('Phone             :' || x_telephone, 1);
        cln_debug_pub.Add('Fax               :' || x_fax, 1);
        cln_debug_pub.Add('Email ID          :' || x_email, 1);
        cln_debug_pub.Add('ECE TP Location ID:' || x_ece_location_code, 1);
     END IF;
     IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('----- Exiting GET_TO_ROLE -----',2);
     END IF;
  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- ERROR: Exiting GET_TO_ROLE API --------- ',5);
             END IF;
  END GET_TO_ROLE;
    -- Name
    --   FROM_RN_TO_ORCL_FORMAT (Internal Function)
    -- Purpose
    --   Convers the Number format from RN to Oracle Undersandable Way
    -- Arguments
    --   Format As per RN Spec
    -- Return
    --   Format in Oracle Syntax
    -- Notes
    --   No special notes
    FUNCTION FROM_RN_TO_ORCL_FORMAT(
         p_format           IN VARCHAR2) RETURN VARCHAR2
    IS
         l_pos              NUMBER;
         l_temp_format      VARCHAR2(30);
         l_number_of_nines  NUMBER;
         l_orcl_format      VARCHAR2(30);
    BEGIN
        IF (l_Debug_Level <= 2) THEN
          cln_debug_pub.Add('-----------Entering FROM_RN_TO_ORCL_FORMAT-----------', 2);
          cln_debug_pub.Add('Format :' || p_format,2);
        END IF;
        l_temp_format := p_format;
        l_orcl_format := '';--Initialize
        l_pos := INSTR(p_format,'V');
        IF (l_Debug_Level <= 1) THEN
          cln_debug_pub.Add('l_pos :' || l_pos,1);
        END IF;
        IF (l_pos > 0) THEN
                l_temp_format := substr(p_format,1, l_pos-1);
                IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('l_temp_format :' || l_temp_format,1);
                END IF;
                IF instr(l_temp_format,'(') > 0 THEN -- In the form of 9(n)
                        l_number_of_nines := to_number(SUBSTR( SUBSTR(l_temp_format,3), 1, length(l_temp_format) - 3));
                        IF (l_Debug_Level <= 1) THEN
                          cln_debug_pub.Add('l_number_of_nines :' || l_number_of_nines,1);
                        END IF;
                        l_orcl_format:= lpad('.',l_number_of_nines+1,'9');
                ELSE -- In the form of 9999
                        l_orcl_format:= l_temp_format || '.';
                END IF;
                l_temp_format:= substr(p_format,l_pos+1);
        END IF;
        IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('l_temp_format after making for first part :' || l_temp_format,1);
        END IF;
        IF instr(l_temp_format,'(') > 0 THEN -- In the form of 9(n)
                l_number_of_nines := to_number(SUBSTR( SUBSTR(l_temp_format,3), 1, length(l_temp_format) - 3));
                IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('l_number_of_nines :' || l_number_of_nines,1);
                END IF;
                l_orcl_format := l_orcl_format || ltrim(rpad(' ',l_number_of_nines+1,'9')) ;
        ELSE -- In the form of 9999
                l_orcl_format := l_orcl_format || l_temp_format;
        END IF;
        IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('l_orcl_format before return :' || l_orcl_format,1);
        END IF;
        IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('-----------Exiting FROM_RN_TO_ORCL_FORMAT-----------', 2);
        END IF;
        RETURN l_orcl_format;
    EXCEPTION
          WHEN OTHERS THEN
             IF (l_Debug_Level <= 5) THEN
                cln_debug_pub.Add('-----------When others in FROM_RN_TO_ORCL_FORMAT-----------', 6);
             END IF;
             --Failed Format Conversion Validation
             Return NULL;
    END;
    FUNCTION IS_VALID_DATE_FORMAT(
         p_value            IN VARCHAR2,
         p_format           IN VARCHAR2) RETURN BOOLEAN
    IS
         l_date  DATE;
    BEGIN
           IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('-----------Entering IS_VALID_DATE_FORMAT-----------', 2);
              cln_debug_pub.Add('Value :' || p_value,2);
              cln_debug_pub.Add('Format :' || p_format,2);
           END IF;
           l_date := to_date(p_value,p_format);
           IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('-----------Exiting IS_VALID_DATE_FORMAT successfully-----------', 2);
           END IF;
           RETURN TRUE;
    EXCEPTION
          WHEN OTHERS THEN
                 IF (l_Debug_Level <= 2) THEN
                     cln_debug_pub.Add('-----------Exiting IS_VALID_DATE_FORMAT errornously-----------', 2);
                 END IF;
                 --Failed Date Validation
                 Return FALSE;
    END;
    FUNCTION IS_VALID_NUMBER_FORMAT(
         p_value            IN VARCHAR2,
         p_format           IN VARCHAR2 DEFAULT NULL) RETURN BOOLEAN
    IS
       l_temp NUMBER;
    BEGIN
           IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('-----------Entering IS_VALID_NUMBER_FORMAT-----------', 2);
              cln_debug_pub.Add('Value :' || p_value,2);
              cln_debug_pub.Add('Format :' || p_format,2);
           END IF;
           IF p_format is NULL THEN
                l_temp := to_number(p_value);
           ELSE
                l_temp := to_number(p_value,p_format);
           END IF;
           IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('-----------Exiting IS_VALID_NUMBER_FORMAT successfully-----------', 2);
           END IF;
           RETURN TRUE;
    EXCEPTION
          WHEN OTHERS THEN
                 IF (l_Debug_Level <= 2) THEN
                     cln_debug_pub.Add('-----------Exiting IS_VALID_NUMBER_FORMAT errornously-----------', 2);
                 END IF;
                 --Failed Number Validation
                 Return FALSE;
    END;
    FUNCTION CONVERT_TO_NUMBER(
         p_value            IN VARCHAR2,
         p_return           IN OUT NOCOPY NUMBER) RETURN BOOLEAN
    IS
    BEGIN
           IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('-----------Entering CONVERT_TO_NUMBER-----------', 2);
              cln_debug_pub.Add('Value :' || p_value,2);
           END IF;
           p_return := to_number(p_value);
           IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('-----------Exiting CONVERT_TO_NUMBER-----------', 2);
              cln_debug_pub.Add('Return :' || p_return,2);
           END IF;
           RETURN TRUE;
    EXCEPTION
          WHEN OTHERS THEN
                 IF (l_Debug_Level <= 2) THEN
                     cln_debug_pub.Add('-----------Exiting CONVERT_TO_NUMBER errornously-----------', 2);
                 END IF;
                 --Failed Number Validation
                 Return FALSE;
    END;
   FUNCTION VALIDATE_ELEMENT(
         p_name            IN VARCHAR2,
         p_value           IN VARCHAR2,
         p_min_length      IN NUMBER,
         p_max_length      IN NUMBER,
         p_type            IN VARCHAR2,
         p_format          IN VARCHAR2,
         x_error_message   IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN
    IS
         l_field_length    NUMBER;
         l_value           VARCHAR2(1000);
         l_part_of_value   VARCHAR2(100);
         l_num_value       NUMBER;
         l_orcl_format     VARCHAR2(100);
         VALIDATION_FAILED EXCEPTION;
         l_validation_info VARCHAR2(1000);
    BEGIN
       IF (l_Debug_Level <= 2) THEN
          cln_debug_pub.Add('-----------ENTERING VALIDATE_ELEMENT-----------', 2);
          cln_debug_pub.Add('Node Name :' || p_name,2);
          cln_debug_pub.Add('Node Value:' || p_value,2);
          cln_debug_pub.Add('Validation Information. Min Len : ' || p_min_length ||
                                                               ',Max Len : ' ||p_max_length ||
                                                               ',Type : ' ||p_type ||
                                                               ',Format : ' ||p_Format ,2);
       END IF;
       -- In case of error following error message is thrown
       l_field_length := nvl(length(p_value),0);
       IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('About to do minimum lenght validation, l_field_lenght : ' || l_field_length,1);
       END IF;
       IF (p_min_length is not null) and (l_field_length <  p_min_length) THEN
            x_error_message := x_error_message || 'Minimum Length Validation Failed';
            IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add(x_error_message,1);
            END IF;
            l_validation_info := 'Minimum Length Validation';
            RAISE VALIDATION_FAILED;
       END IF;
       IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('About to do maximum lenght validation',1);
       END IF;
       IF (p_max_length is not null) and (l_field_length >  p_max_length) THEN
            l_validation_info := 'Maximum Length Validation';
            RAISE VALIDATION_FAILED;
       END IF;
       IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('About to do type validation : '|| p_type,1);
       END IF;
       IF p_type is not null THEN
             l_validation_info := 'Data Type Validation';
             IF p_type = 'Date' THEN
                l_value := rtrim(ltrim(p_value));
                IF(length(l_value) <> 9) THEN
                     RAISE VALIDATION_FAILED;
                END IF;
                l_part_of_value := substr(l_value,1,8);
                IF (l_Debug_Level <= 1) THEN
                     cln_debug_pub.Add('Part of Value : '|| l_part_of_value,1);
                END IF;
                IF NOT is_valid_date_format(l_part_of_value,'YYYYMMDD') THEN
                     RAISE VALIDATION_FAILED;
                END IF;
             ELSIF p_type = 'DateTime' THEN
                l_value := rtrim(ltrim(p_value));
                IF(length(l_value) <> 20) THEN
                     RAISE VALIDATION_FAILED;
                END IF;
                l_part_of_value := substr(l_value,1,8);
                IF (l_Debug_Level <= 1) THEN
                     cln_debug_pub.Add('Part of Value : '|| l_part_of_value,1);
                END IF;
                IF NOT is_valid_date_format(l_part_of_value,'YYYYMMDD') THEN
                     RAISE VALIDATION_FAILED;
                END IF;
                l_part_of_value := substr(l_value,10,6);
                IF (l_Debug_Level <= 1) THEN
                     cln_debug_pub.Add('Part of Value : '|| l_part_of_value,1);
                END IF;
                IF NOT is_valid_date_format(l_part_of_value,'HH24MISS') THEN
                     RAISE VALIDATION_FAILED;
                END IF;
                BEGIN
                   l_part_of_value := substr(l_value,17,3);
                   IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Part of Value : '|| l_part_of_value,1);
                   END IF;
                   IF NOT is_valid_number_format(l_part_of_value) THEN
                        RAISE VALIDATION_FAILED;
                   END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    NULL;-- ignore the exception
                END;
             ELSIF p_type = 'Time' THEN
                l_value := rtrim(ltrim(p_value));
                IF(length(l_value) <> 11) THEN
                     RAISE VALIDATION_FAILED;
                END IF;
                l_part_of_value := substr(l_value,1,6);
                IF NOT is_valid_date_format(l_part_of_value,'HH24MISS') THEN
                     RAISE VALIDATION_FAILED;
                END IF;
                BEGIN
                   l_part_of_value := substr(rtrim(ltrim(l_value)),8,3);
                   IF NOT is_valid_number_format(l_part_of_value) THEN
                        RAISE VALIDATION_FAILED;
                   END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    NULL;
                END;
             ELSIF p_type = 'Integer' or p_type = 'NaturalNumber'
                OR p_type = 'PositiveInteger' or p_type = 'Real'
             THEN
                IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('About to do format validation : '|| l_orcl_format,1);
                END IF;
                IF p_format is NOT NULL THEN
                    IF( NOT is_valid_number_format(l_value,p_format) ) THEN
                        RAISE VALIDATION_FAILED;
                    END IF;
                ELSE --Format not specified, so do datatype validation
                    IF not convert_to_number(p_value,l_num_value) THEN
                        RAISE VALIDATION_FAILED;
                    END IF;
                    IF p_type = 'Integer' THEN
                        IF( l_num_value - round(l_num_value) <> 0 ) THEN
                           RAISE VALIDATION_FAILED;
                        END IF;
                    ELSIF p_type = 'PositiveInteger' THEN
                        IF( l_num_value - round(l_num_value) <> 0  or l_num_value < 0 ) THEN
                           RAISE VALIDATION_FAILED;
                        END IF;
                    ELSIF p_type = 'NaturalNumber' THEN
                        IF( l_num_value - round(l_num_value) <> 0  or l_num_value <= 0 ) THEN
                           RAISE VALIDATION_FAILED;
                        END IF;
                    END IF;
                END IF;
             END IF;
       END IF;
       IF (l_Debug_Level <= 2) THEN
          cln_debug_pub.Add('-----------EXITING VALIDATE_ELEMENT-----------', 2);
       END IF;
       RETURN TRUE;
    EXCEPTION
       WHEN VALIDATION_FAILED THEN
          x_error_message := 'Validation Failed For the element : '|| p_name || ' Value : '|| p_value || ' Validation : ' || l_validation_info;
          IF (l_Debug_Level <= 5) THEN
             cln_debug_pub.Add(x_error_message, 6);
          END IF;
         RETURN FALSE;
       WHEN OTHERS THEN
          x_error_message := 'Unknown exception while doing the validations for element : '|| p_name || ' Value : '|| p_value || ' Validation : ' || l_validation_info;
          IF (l_Debug_Level <= 5) THEN
             cln_debug_pub.Add(x_error_message, 6);
          END IF;
         RETURN FALSE;
    END VALIDATE_ELEMENT;
    PROCEDURE VALIDATE_XML(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2
)
   IS
         l_xmlDoc               CLOB;
         l_payload              CLOB;
         l_parser               xmlparser.parser;
         l_domDoc               xmldom.DOMDocument;
         l_node                 xmldom.domNode;
         l_nodelist             xmldom.DOMNodeList;
         l_nodelistlen          NUMBER;
         l_error_code           VARCHAR2(255);
         l_error_msg            VARCHAR2(1000);
         l_msg_data             VARCHAR2(1000);
         l_ini_pos              NUMBER;
         l_fin_pos              NUMBER;
         l_amount               INTEGER;
         l_eventmsg             WF_EVENT_T;
         l_name                 VARCHAR2(1000);
         l_value                VARCHAR2(1000);
         l_error_message        VARCHAR2(1000);
         l_start_timestamp      date;
         l_root_element         VARCHAR2(100);
         VALIDATION_FAILED      EXCEPTION;
         l_fnd_error_msg        VARCHAR2(1000);
         TYPE t_min_len_list is TABLE of NUMBER INDEX BY BINARY_INTEGER;
         TYPE t_max_len_list is TABLE of NUMBER INDEX BY BINARY_INTEGER;
         TYPE t_data_type_list is TABLE of VARCHAR2(100) INDEX BY BINARY_INTEGER;
         TYPE t_format_list is TABLE of VARCHAR2(100) INDEX BY BINARY_INTEGER;
         TYPE t_xml_element is TABLE of VARCHAR2(255) INDEX BY BINARY_INTEGER;
         l_min_lengths          t_min_len_list;
         l_max_lengths          t_min_len_list;
         l_types                t_data_type_list;
         l_formats              t_format_list;
         l_xml_elements         t_xml_element;
         TYPE t_validations_tables  is TABLE of CLN_RN_VALIDATIONS%ROWTYPE INDEX BY BINARY_INTEGER;
         l_tab_validations   t_validations_tables;
         CURSOR c_validations(p_document_type in varchar2) IS SELECT XML_ELEMENT, MINIMUM_LENGTH, MAXIMUM_LENGTH, DATA_TYPE, oracle_format_mask
               FROM CLN_RN_VALIDATIONS
               WHERE document_type = p_document_type;
   BEGIN
      x_resultout := 'SUCCESS';
      l_parser   := xmlparser.newParser;
      l_start_timestamp := sysdate;
      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('-----------ENTERING VALIDATE_XML-----------', 2);
      END IF;
      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('WITH PARAMETERS', 1);
              cln_debug_pub.Add('p_itemtype:' || p_itemtype, 1);
              cln_debug_pub.Add('p_itemkey:' || p_itemkey, 1);
              cln_debug_pub.Add('p_actid:' || p_actid, 1);
              cln_debug_pub.Add('p_funcmode:' || p_funcmode, 1);
      END IF;
      l_eventmsg := wf_engine.getActivityAttrEvent(p_itemtype, p_itemkey, p_actid, 'CLN_EVENT_MESSAGE');
      l_xmlDoc :=  l_eventmsg.getEventData;
      l_ini_pos := -1;
      l_ini_pos := dbms_lob.instr(l_xmlDoc, '!DOCTYPE ');
      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('Init Position:' || l_ini_pos, 1);
      END IF;
      IF (l_ini_pos > 0) THEN
         l_fin_pos := dbms_lob.instr(l_xmlDoc, '>', l_ini_pos);
         l_fin_pos := l_fin_pos + 1;
         l_amount  := dbms_lob.getlength(l_xmlDoc);
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Final Position:' || l_fin_pos, 1);
                 cln_debug_pub.Add('Length:' || l_amount, 1);
         END IF;
         DBMS_LOB.CREATETEMPORARY(l_payload, TRUE, DBMS_LOB.SESSION);
         dbms_lob.copy(l_payload, l_xmlDoc, l_amount - l_fin_pos + 10, 1, l_fin_pos);
      END IF;
      l_parser := xmlparser.newparser;
      xmlparser.setValidationMode(l_parser,FALSE);
      xmlparser.showWarnings(l_parser,FALSE);
      BEGIN
         IF (l_ini_pos > 0) THEN
            xmlparser.parseClob(l_parser,l_payload);
         ELSE
            xmlparser.parseClob(l_parser,l_xmlDoc);
         END IF;
         l_domDoc      := xmlparser.getDocument(l_parser);
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('About to get root element', 1);
         END IF;
         l_root_element:= xmldom.getNodeName( xmldom.makeNode(xmldom.getDocumentElement(l_domDoc))); -- Getting the root element of the document
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Root element :' || l_root_element, 1);
         END IF;
         OPEN  c_validations(l_root_element);
         FETCH c_validations BULK COLLECT INTO l_xml_elements, l_min_lengths,l_max_lengths,l_types, l_formats;
         IF c_validations%NOTFOUND THEN
           Null; --Error
         END IF;
         CLOSE c_validations;
         FOR i in 1..l_xml_elements.count LOOP
           IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('In the loop for iteration:' || i, 1);
              cln_debug_pub.Add('l_xml_elements:' || l_xml_elements(i), 1);
              cln_debug_pub.Add('l_min_lengths:' || l_min_lengths(i), 1);
              cln_debug_pub.Add('l_max_lengths:' || l_max_lengths(i), 1);
              cln_debug_pub.Add('l_types:' || l_types(i), 1);
              cln_debug_pub.Add('l_formats:' || l_formats(i), 1);
           END IF;
           l_nodelist    := xmldom.getElementsByTagName(l_domDoc, l_xml_elements(i));
           l_nodelistlen := xmldom.getLength(l_nodelist);
           IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('Number of element found :' || l_nodelistlen, 1);
           END IF;
           FOR l_counter IN 0..l_nodelistlen-1 LOOP
              IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Trying to do validation - loop counter:' || l_counter, 1);
              END IF;
              l_node := xmldom.item(l_nodelist, l_counter);
              --l_name := xmldom.getNodeName(l_node);
              l_node := xmldom.getFirstChild(l_node);
              IF xmldom.isNull(l_node) THEN
                 l_value := null;
                 IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Value is null. So no need to do validation', 1);
                 END IF;
                 -- Need not do validation for null nodes
                 /*IF NOT VALIDATE_ELEMENT(l_xml_elements(i),l_value, l_min_lengths(i),l_max_lengths(i),l_types(i),l_formats(i), l_error_message) THEN
                    --Validation failed
                    RAISE Validation_Failed;
                 END IF;*/
              ELSIF xmldom.getNodeType(l_node) = xmldom.TEXT_NODE THEN -- get the text node associated with the element node
                 l_value := xmldom.getNodeValue(l_node);
                 IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Value of the tag : ' || l_value , 1);
                 END IF;
                 IF( (l_value is not null)) THEN -- Need not do validation for nodes that doesnt have values
                    IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('About to call validate element', 1);
                    END IF;
                    IF NOT VALIDATE_ELEMENT(l_xml_elements(i),l_value, l_min_lengths(i),l_max_lengths(i),l_types(i),l_formats(i), l_error_message) THEN
                       --Validation failed
                       RAISE Validation_Failed;
                    END IF;
                 END IF;
              END IF;
           END LOOP;
         END LOOP;
      EXCEPTION
         WHEN Validation_FAILED THEN
            x_resultout := 'FAIL:'||l_error_message;
            IF (l_Debug_Level <= 5) THEN
                cln_debug_pub.Add('Validation Failed With messge :'||l_error_message ,6);
            END IF;
          -- Added for 3C4 messages
            FND_MESSAGE.SET_NAME('CLN','M4R_3C4_XML_VALIDATION_FAIL');
            FND_MESSAGE.SET_TOKEN('ERRMSG',l_error_message);
            l_fnd_error_msg:= FND_MESSAGE.GET;
            wf_engine.SetItemAttrText(p_itemtype,p_itemkey,'CH_MESSAGE_VALIDATION_FAILED',l_fnd_error_msg);
            CLN_NP_PROCESSOR_PKG.Notify_administrator('RosettaNet Validations Failed for the XML message in the Workflow '  || ' ' ||
                                                      'Item Type: ' || p_itemtype || ', ' ||
                                                      'Item Key: ' || p_itemkey || ', ' ||
                                                      'Error: ' || l_error_message);
         WHEN OTHERS THEN
            l_error_code := SQLCODE;
            l_error_msg := SQLERRM;
            l_msg_data := l_error_code||' : '||l_error_msg;
            x_resultout := 'ERROR:'||l_msg_data;
            IF (l_Debug_Level <= 5) THEN
                 cln_debug_pub.Add(l_msg_data,6);
            END IF;
            l_error_message := l_msg_data;
      END;
      IF (l_ini_pos > 0) THEN
        DBMS_LOB.FREETEMPORARY(l_payload);
      END IF;
      xmlparser.freeparser(l_parser);
      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('EXITING VALIDATE_XML normally', 2);
              cln_debug_pub.Add('Time Taken in seconds : ' || to_char(24.0*60.0*60.0*(sysdate - l_start_timestamp),'99999999999.9999999'),1);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         l_msg_data := l_error_code||' : '||l_error_msg;
         x_resultout := 'ERROR:'||l_msg_data;
         IF (l_Debug_Level <= 5) THEN
                 cln_debug_pub.Add(l_msg_data,6);
                 cln_debug_pub.Add('EXITING VALIDATE_XML with others error', 1);
         END IF;
   END VALIDATE_XML;
   PROCEDURE GET_ITEM_CONFIG_PARAMS(
		p_item_config_dtl_tag	IN  VARCHAR2,
		x_top_model_line_id	OUT NOCOPY VARCHAR2,
		x_link_to_line_id		OUT NOCOPY VARCHAR2
		)
   IS
	delim_pos NUMBER;
   BEGIN
		IF (l_debug_level <= 2) THEN
			cln_debug_pub.Add('----- Entering cln_rn_utl.get_item_config_params API ------- ',2);
		END IF;
		IF (l_debug_level <= 1) THEN
			cln_debug_pub.Add('----- received parameters ------- ',1);
			cln_debug_pub.Add('p_item_config_dtl_tag - ' || p_item_config_dtl_tag,1);
		END IF;
		x_top_model_line_id	:= NULL;
		x_link_to_line_id	:= NULL;
		delim_pos := instr(p_item_config_dtl_tag,':',1,1);
		IF delim_pos > 0 THEN
			x_top_model_line_id     := substr(p_item_config_dtl_tag,1,delim_pos-1);
			x_link_to_line_id	      := substr(p_item_config_dtl_tag,delim_pos+1);
		END IF;
		IF (l_debug_level <= 1) THEN
			cln_debug_pub.Add('----- returning values ------- ',1);
			cln_debug_pub.Add('x_top_model_line_id - ' || x_top_model_line_id, 1);
			cln_debug_pub.Add('x_link_to_line_id   - ' || x_link_to_line_id  , 1);
		END IF;
		IF (l_debug_level <= 2) THEN
			cln_debug_pub.Add('----- Exiting cln_rn_utl.get_item_config_params API ------- ',2);
		END IF;
  END;
  PROCEDURE CREATE_ITEM_CONFIG_TAG(
			p_top_model_line_id	IN	VARCHAR2,
			p_link_to_line_id		IN	VARCHAR2,
			x_item_config_dtl_tag	OUT 	NOCOPY VARCHAR2
		)
  IS
  BEGIN
		IF (l_debug_level <= 2) THEN
			cln_debug_pub.Add('----- Entering cln_rn_utl.create_item_config_tag API ------- ',2);
		END IF;
		IF (l_debug_level <= 1) THEN
			cln_debug_pub.Add('----- received parameters ------- ',1);
			cln_debug_pub.Add('p_top_model_line_id - ' || p_top_model_line_id, 1);
			cln_debug_pub.Add('p_link_to_line_id   - ' || p_link_to_line_id  , 1);
		END IF;
		IF (p_top_model_line_id IS NULL) AND (p_link_to_line_id IS NULL) THEN
			x_item_config_dtl_tag := NULL;
		ELSE
			x_item_config_dtl_tag := p_top_model_line_id || ':' || p_link_to_line_id;
		END IF;
		IF (l_debug_level <= 1) THEN
			cln_debug_pub.Add('----- returning values ------- ',1);
			cln_debug_pub.Add('x_item_config_dtl_tag   - ' || x_item_config_dtl_tag, 1);
		END IF;
		IF (l_debug_level <= 2) THEN
			cln_debug_pub.Add('----- Exiting cln_rn_utl.create_item_config_tag API ------- ',2);
		END IF;
  END;


Procedure get_user_id
   (p_user_name IN VARCHAR,
    x_user_id OUT NOCOPY NUMBER,
    x_error_code OUT NOCOPY NUMBER,
    x_error_message OUT NOCOPY VARCHAR) is
   l_count NUMBER;
   BEGIN
   x_error_code := 0;
   select count(*)
   into l_count
   from fnd_user
   where user_name = p_user_name;
  if (l_count = 0) then
     x_error_code := 1;
     x_user_id := 0;
     x_error_message := 'Invalid User Name ' || p_user_name;
  else
   select user_id
   into x_user_id
   from fnd_user
   where user_name = p_user_name;
  end if;
END get_user_id;


PROCEDURE getPurchaseOrderNum(p_PoAndRel        IN     VARCHAR2,
                                x_PoNum           OUT    NOCOPY  VARCHAR2) IS
      l_RelExists                     VARCHAR2(100);
      l_error_code                  NUMBER;
      l_error_msg                   VARCHAR2(1000);
   BEGIN
     IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('----- Entering cln_rn_util.getPurchaseOrderNum API ------- ',2);
     END IF;
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('p_PoAndRel:' || p_PoAndRel,1);
     END IF;
      l_RelExists := INSTR(p_PoAndRel, '-', 1, 1);
      if(l_RelExists = 0) then
         x_PoNum := p_PoAndRel;
      else
         x_PoNum := RTRIM(RTRIM(p_PoAndRel, '0123456789'), '-');
      end if;
     IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('----- Exiting cln_rn_util.getPurchaseOrderNum API ------- ',2);
     END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg,1);
         END IF;
END getPurchaseOrderNum;

PROCEDURE getRelNum(p_PoAndRel        IN     VARCHAR2,
                       x_RelNum          OUT    NOCOPY   VARCHAR2) IS
      l_modifiedString                VARCHAR2(100) := '000';
      l_error_code                  NUMBER;
      l_error_msg                   VARCHAR2(1000);
   BEGIN
      x_RelNum := LTRIM(LTRIM(p_PoAndRel, '0123456789'), '-');
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg,1);
         END IF;
END getRelNum;

PROCEDURE getRelNum(p_PoAndRel        IN     VARCHAR2,
                       x_RelNum          OUT    NOCOPY   NUMBER) IS
      l_modifiedString                VARCHAR2(100) := '000';
      l_error_code                  NUMBER;
      l_error_msg                   VARCHAR2(1000);
   BEGIN
      x_RelNum :=TO_NUMBER( LTRIM(LTRIM(p_PoAndRel, '0123456789'), '-'));
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg,1);
         END IF;
END getRelNum;

PROCEDURE getRevNum
    (p_PORELANDREV       IN   varchar2,
     x_porel           OUT  NOCOPY varchar2,
         x_revnum          OUT  NOCOPY VARCHAR2) IS
     l_modifiedString                VARCHAR2(100) := '000';
      l_error_code                  NUMBER;
      l_error_msg                   VARCHAR2(1000);
   BEGIN
     IF (l_Debug_Level <= 5) THEN
           cln_debug_pub.Add('Entered get RevNum(p_PORELANDREV,x_porel,x_revnum)');
           cln_debug_pub.Add('p_PORELANDREV   :' || p_PORELANDREV,1);
     END IF;

      x_RevNum :=LTRIM(LTRIM(p_PORELANDREV, '0123456789-'), ':');
      x_porel  :=RTRIM(RTRIM(p_PORELANDREV, '0123456789-'), ':');

     IF (l_Debug_Level <= 5) THEN
           cln_debug_pub.Add('x_porel         :' || x_porel);
           cln_debug_pub.Add('x_revnum        :' || x_revnum ,1);
     END IF;


   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg,1);
         END IF;
END getRevNum;


PROCEDURE CONCAT_PO_RELNUM
    (p_ponum IN VARCHAR2,
     p_porelnum IN VARCHAR2,
     x_poandrelnum OUT NOCOPY VARCHAR2) IS
  BEGIN
    if (p_porelnum is NULL) or (p_porelnum = 0) then
    x_poandrelnum := p_ponum;
    else
    x_poandrelnum := p_ponum || '-' || p_porelnum;
    end if;
END CONCAT_PO_RELNUM;


PROCEDURE CONCAT_PORELNUM_REVNUM
    (p_porelnum IN VARCHAR2,
     p_porevnum IN VARCHAR2,
     x_porelrevnum OUT NOCOPY VARCHAR2) IS
  BEGIN
    if (p_porevnum is NULL) or (p_porevnum = 0) then
    x_porelrevnum := p_porelnum;
    else
    x_porelrevnum := p_porelnum || ':' || p_porevnum;
    end if;
END CONCAT_PORELNUM_REVNUM;



PROCEDURE getTagParamValue(
			p_xml_tag	IN VARCHAR2,
			p_param		IN vARCHAR2,
			x_value		OUT NOCOPY VARCHAR2) IS
      l_PipeExists                  NUMBER;
      l_EqualExists                 NUMBER;
      l_error_code                  NUMBER;
      l_error_msg                   VARCHAR2(1000);
      l_remaining_part              VARCHAR2(1000);
      l_part                        VARCHAR2(1000);
      l_name                        VARCHAR2(1000);

BEGIN
     IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('----- Entering cln_rn_util.getTagParamValue API ------- ',2);
     END IF;
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('p_xml_tag:' || p_xml_tag,1);
           cln_debug_pub.Add('p_param:' || p_param,1);
     END IF;
      x_value := null;
      l_remaining_part := p_xml_tag;
      while length(l_remaining_part) > 0  loop
	   l_PipeExists := INSTR(l_remaining_part, '|', 1, 1);
	   if(l_PipeExists > 0) then
		 l_part := substr(l_remaining_part,1,l_PipeExists-1);
		 l_remaining_part := substr(l_remaining_part,l_PipeExists+1);
	   else
		 l_part := l_remaining_part;
		 l_remaining_part := '';
	   end if;
	   l_EqualExists := INSTR(l_part, '=', 1, 1);
	   if(l_EqualExists > 0) then
		 l_name := substr(l_part,1,l_EqualExists-1);
		 if (l_name = p_param) then
		    x_value := substr(l_part,l_EqualExists+1);
		     IF (l_Debug_Level <= 2) THEN
			   cln_debug_pub.Add('----- Exiting cln_rn_util.getTagParamValue API - param found ' || substr(l_part,l_EqualExists+1) ,2);
		     END IF;
		    return;
		 end if;
	   end if;
	   IF (l_Debug_Level <= 1) THEN
		   cln_debug_pub.Add('l_remaining_part:' || l_remaining_part,1);
	   END IF;
      end loop;
     IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('----- Exiting cln_rn_util.getTagParamValue API - Param not found ------- ',2);
     END IF;
EXCEPTION
  when others then
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         IF (l_Debug_Level <= 5) THEN
             cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg,1);
         END IF;
	 x_value := null;
END getTagParamValue;

    PROCEDURE Get_tag_value_from_xml(
         p_internal_control_num    IN  NUMBER,
         p_tag_path                IN  VARCHAR2,
         x_tag_value               IN OUT NOCOPY VARCHAR2
	 )
   IS
         l_xmlDoc               CLOB;
         l_parser               xmlparser.parser := xmlparser.newParser;
         l_domDoc               xmldom.DOMDocument;
         l_node                 xmldom.domNode;
         l_element              xmldom.domElement;
         l_nodeList             xmldom.domNodeList;
         l_size                 number;
         l_Nname                varchar2(255);
         l_Nvalue               varchar2(255);
         l_error_code           VARCHAR2(255);
         l_error_msg            VARCHAR2(1000);
         l_msg_data             VARCHAR2(1000);
         l_payload              CLOB;
         l_ini_pos              NUMBER(38);
         l_fin_pos              NUMBER(38);
         l_amount               INTEGER;
         l_PipeExists           NUMBER;
         l_remaining_part       VARCHAR2(1000);
         l_part                 VARCHAR2(1000);
   BEGIN
      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('-----------ENTERING Get_tag_value_from_xml-----------', 2);
      END IF;
      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('WITH PARAMETERS', 1);
              cln_debug_pub.Add('p_internal_control_num:' || p_internal_control_num, 1);
              cln_debug_pub.Add('p_tag_path:' || p_tag_path, 1);
      END IF;

      x_tag_value := NULL;

      SELECT payload into l_xmlDoc FROM ecx_doclogs  WHERE internal_control_number = p_internal_control_num;

      l_ini_pos := -1;
      l_ini_pos := dbms_lob.instr(l_xmlDoc, '!DOCTYPE ');
      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('Init Position:' || l_ini_pos, 1);
      END IF;

      IF (l_ini_pos > 0) THEN
         l_fin_pos := dbms_lob.instr(l_xmlDoc, '>', l_ini_pos);
         l_fin_pos := l_fin_pos + 1;
         l_amount  := dbms_lob.getlength(l_xmlDoc);

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('Final Position:' || l_fin_pos, 1);
                 cln_debug_pub.Add('Length:' || l_amount, 1);
         END IF;

         DBMS_LOB.CREATETEMPORARY(l_payload, TRUE, DBMS_LOB.SESSION);

         dbms_lob.copy(l_payload, l_xmlDoc, l_amount - l_fin_pos + 10, 1, l_fin_pos);

      END IF;

      l_parser := xmlparser.newparser;
      xmlparser.setValidationMode(l_parser,FALSE);
      xmlparser.showWarnings(l_parser,FALSE);

      BEGIN

         IF (l_ini_pos > 0) THEN
            xmlparser.parseClob(l_parser,l_payload);
         ELSE
            xmlparser.parseClob(l_parser,l_xmlDoc);
         END IF;

         l_domDoc       := xmlparser.getDocument(l_parser);
	 l_element      := xmldom.getDocumentElement(l_domDoc);

         --l_nodeList     := Xmldom.getElementsByTagName(l_domDoc, 'CNTROLAREA');
         --l_element      := xmldom.makeElement(xmldom.item( l_nodeList, 0 ));
         --l_nodeList     := Xmldom.getElementsByTagName(l_element, 'REFERENCEID');


	 l_remaining_part := p_tag_path;
	 while length(l_remaining_part) > 0  loop
	   l_PipeExists := INSTR(l_remaining_part, '/', 1, 1);
	   if(l_PipeExists > 0) then
		 l_part := substr(l_remaining_part,1,l_PipeExists-1);
		 l_remaining_part := substr(l_remaining_part,l_PipeExists+1);

		 l_nodeList     := Xmldom.getElementsByTagName(l_element, l_part);
		 l_element      := xmldom.makeElement(xmldom.item( l_nodeList, 0 ));
	   else
		 l_part := l_remaining_part;
		 l_remaining_part := '';

                 l_nodeList     := Xmldom.getElementsByTagName(l_element, l_part);
	   end if;

	   IF (l_Debug_Level <= 1) THEN
		   cln_debug_pub.Add('l_remaining_part:' || l_remaining_part,1);
	   END IF;
         end loop;

	 --l_nodeList     := Xmldom.getElementsByTagName(l_domDoc, l_part);
         l_node         := xmldom.item( l_nodeList, 0 );
         l_Nvalue       := xmldom.getNodeName(l_node);
         l_node         := xmldom.getFirstChild(l_node);

         IF NOT xmldom.IsNull(l_node) THEN
            x_tag_value := xmldom.getNodeValue(l_node);
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            x_tag_value := NULL;
            l_error_code := SQLCODE;
            l_error_msg := SQLERRM;
            l_msg_data := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add(l_msg_data,6);
            END IF;
      END;

      IF (l_ini_pos > 0) THEN
        DBMS_LOB.FREETEMPORARY(l_payload);
      END IF;
      xmlparser.freeparser(l_parser);

      IF (l_Debug_Level <= 5) THEN
              cln_debug_pub.Add('Application Reference ID:' || x_tag_value,1);
      END IF;
      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('EXITING Get_tag_value_from_xml', 2);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         l_msg_data := l_error_code||' : '||l_error_msg;
         IF (l_Debug_Level <= 5) THEN
                 cln_debug_pub.Add(l_msg_data,6);
                 cln_debug_pub.Add('EXITING Get_tag_value_from_xml', 1);
         END IF;
         x_tag_value := NULL;
   END Get_tag_value_from_xml;



    -- Name
    --   CONVERT_TO_RN_DATE_EVENT
    -- Purpose
    --   Converts a date value into RosettaNet date format and time format
    --   RosettaNet Date Format: YYYYMMDDZ  Time Format : hhmmss.SSSZ
    -- Arguments
    --   Date
    -- Notes
    --   If the date passed is NULL, then sysdate is considered.
  PROCEDURE CONVERT_TO_RN_DATE_EVENT(
     p_server_date              IN DATE,
     x_rn_date                  OUT NOCOPY VARCHAR2,
     x_rn_time                  OUT NOCOPY VARCHAR2)
  IS
     l_error_code               NUMBER;
     l_utc_date                 DATE;
     l_milliseconds             VARCHAR2(5);
     l_server_timezone          VARCHAR2(30);
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN
     IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('----- Entering CONVERT_TO_RN_DATE_EVENT API ------- ',2);
     END IF;
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('User Entered Date      --> '||p_server_date,1);
     END IF;
     IF(p_server_date is null) THEN
        x_rn_date := null;
        x_rn_time := null;
        IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('Null is passed. So exiting the procedure with null as return',1);
        END IF;
        RETURN;
     END IF;
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('Call CONVERT_TO_RN_TIMEZONE API....... ',1);
     END IF;
     CONVERT_TO_RN_TIMEZONE(
        p_input_date          =>  p_server_date,
        x_utc_date            =>  l_utc_date );
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('TimeStamp as per UTC       '||l_utc_date,1);
     END IF;
     l_milliseconds := '000'; --We wont get milliseconds
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('Truncated Millisecond       '||l_milliseconds,1);
     END IF;
     x_rn_date := TO_CHAR(l_utc_date,'YYYYMMDD')||'Z';
     x_rn_time := TO_CHAR(l_utc_date,'hh24miss')||'.'||l_milliseconds||'Z';
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('Date in Rosettanet Format '||x_rn_date,1);
           cln_debug_pub.Add('Time in Rosettanet Format '||x_rn_time,1);
     END IF;
     IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('----- Exiting CONVERT_TO_RN_DATE_EVENT API ------- ',2);
     END IF;
  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- ERROR: Exiting CONVERT_TO_RN_DATE_EVENT API --------- ',5);
             END IF;
             x_rn_date := null;
             x_rn_time := null;
  END CONVERT_TO_RN_DATE_EVENT;

      -- Name
      --   CONVERT_TO_DB_DATE
      -- Purpose
      --   Converts a date value from RosettaNet date/datetime format to db format
      --   RosettaNet Date Format    : YYYYMMDDZ
      --   RosettaNet Time Format    : hhmmss.SSSZ
      -- Arguments
      --   Date
      -- Notes
      --   If the date passed is NULL, then sysdate is considered.
  PROCEDURE CONVERT_TO_DB_DATE(
     p_rn_date                  IN VARCHAR2,
     p_rn_time                  IN VARCHAR2,
     x_db_date                  OUT NOCOPY DATE)
  IS
     l_server_date              DATE;
     l_utc_datetime             DATE;
     l_count_t_appearanace      NUMBER;
     l_error_code               NUMBER;
     l_rn_frmt_date             VARCHAR2(30);
     l_rn_timezone              VARCHAR2(30);
     l_db_timezone              VARCHAR2(30);
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN
       IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('----- Entering CONVERT_TO_DB_DATE API ------- ',2);
       END IF;
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('Rosettanet Date '||p_rn_date,1);
             cln_debug_pub.Add('Rosettanet Time '||p_rn_time,1);
       END IF;
        IF(p_rn_date is null) THEN
           x_db_date := null;
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Null is passed. So exiting the procedure with NULL as return',1);
           END IF;
           RETURN;
        END IF;
       IF (p_rn_time is not null) THEN
           --Datetime Format: YYYYMMDDThhmmss.SSSZ
           l_rn_timezone := fnd_profile.value('CLN_RN_TIMEZONE');
           IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('TimeZone of the UTC          '||l_rn_timezone,1);
           END IF;
           -- get the timezone of the db server
           l_db_timezone := FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE;
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('TimeZone of the DB server    '||l_db_timezone,1);
           END IF;
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Datetime Format: YYYYMMDDThhmmss.SSSZ',1);
           END IF;
           l_rn_frmt_date     :=    substr(p_rn_date,1,8)||substr(p_rn_time,1,6);
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Date After Formatting (String)'||l_rn_frmt_date,1);
           END IF;
           l_utc_datetime := TO_DATE(l_rn_frmt_date,'YYYYMMDDHH24MISS');
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Date After Formatting (Date)'||l_utc_datetime,1);
           END IF;
           -- this function converts the datetime from the user entered/db timezone to UTC
           x_db_date    := FND_TIMEZONES_PVT.adjust_datetime(l_utc_datetime,l_rn_timezone,l_db_timezone);
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Date after conversion     '||x_db_date,1);
           END IF;
       ELSE
           --Date Format    : YYYYMMDDZ
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Date Format    : YYYYMMDDZ',1);
           END IF;
           l_rn_frmt_date       :=      substr(p_rn_date,1,8);
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Date After Formatting (String) '||l_rn_frmt_date,1);
           END IF;
           x_db_date := TO_DATE(l_rn_frmt_date,'YYYYMMDD');
           IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Date After Formatting (Date)'||l_utc_datetime,1);
           END IF;
       END IF;
      IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('----- Exiting CONVERT_TO_DB_DATE API ------- ',2);
      END IF;
  -- Exception Handling
  EXCEPTION
        WHEN OTHERS THEN
             x_db_date := null;
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- ERROR: Exiting CONVERT_TO_DB_DATE API --------- ',5);
             END IF;
  END CONVERT_TO_DB_DATE;


  PROCEDURE TRUNCATE_STRING(
     p_instring in varchar2,
     p_numofchar in number,
     x_outstring out nocopy varchar2 )
  IS
     l_error_code               NUMBER;
     l_error_msg                VARCHAR2(255);
     l_msg_data                 VARCHAR2(255);
  BEGIN
    IF (l_Debug_Level <=2 ) THEN
        cln_debug_pub.Add('-------- ENTERING TRUNCATE_STRING  ----------');
    END IF;

    IF (l_Debug_Level <= 1) THEN
         cln_debug_pub.Add('input_string :'||p_instring ,1);
         cln_debug_pub.Add('num_char :'||p_numofchar,1);
    END IF;

    select substr (p_instring,1,p_numofchar) into x_outstring from dual;

    IF (l_Debug_Level <= 1) THEN
         cln_debug_pub.Add('output string :'||x_outstring ,1);
    END IF;

    IF (l_Debug_Level <=2) THEN
        cln_debug_pub.Add('-------- EXITING TRUNCATE_STRING   ----------');
    END IF;


  EXCEPTION
     WHEN OTHERS THEN
             l_error_code       := SQLCODE;
             l_error_msg        := SQLERRM;
             l_msg_data         := 'Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- EXCEPTION IN TRUNCATE STRING--------- ',5);
             END IF;
  END TRUNCATE_STRING;

END CLN_RN_UTILS;

/
