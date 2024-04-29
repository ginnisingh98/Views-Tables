--------------------------------------------------------
--  DDL for Package Body M4U_UCC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_UCC_UTILS" AS
/* $Header: m4uutilb.pls 120.4 2006/07/13 10:43:44 bsaratna noship $ */
        l_debug_level        NUMBER;
        G_PKG_NAME CONSTANT VARCHAR2(30) := 'm4u_ucc_utils';

        -- converts oracle date into cXML date format
        PROCEDURE convert_to_uccnet_date (  p_ora_date    IN      DATE,
                                            x_ucc_date    OUT     NOCOPY VARCHAR2
                                         )
        IS

           l_year       varchar2(200);
           l_month      varchar2(200);
           l_day        varchar2(200);
        BEGIN

           IF (p_ora_date IS NOT NULL)
           THEN
              l_year := to_char(p_ora_date, 'YYYY');
              l_month := to_char(p_ora_date, 'MM');
              l_day := to_char(p_ora_date, 'DD');

              x_ucc_date := l_year || '-' || l_month || '-' || l_day;
           ELSE
              x_ucc_date := NULL;
           END IF;
        EXCEPTION
                WHEN OTHERS THEN
                   raise ;
        end convert_to_uccnet_date;

        -- converts oracle date into cXML datetime format
        PROCEDURE convert_to_uccnet_datetime ( p_ora_date        IN      DATE,
                                       x_ucc_date        OUT     NOCOPY VARCHAR2
                                     )
        IS
           l_ora_date           varchar2(200);
           l_year               varchar2(200);
           l_month              varchar2(200);
           l_day                varchar2(200);
           l_hour               varchar2(200);
           l_min                varchar2(200);
           l_sec                varchar2(200);
        BEGIN
           l_ora_date := to_char(p_ora_date, 'YYYYMMDD HH24MISS');

           IF (l_ora_date IS NOT NULL)
           THEN
              l_year := to_char(p_ora_date, 'YYYY');
              l_month := to_char(p_ora_date, 'MM');
              l_day := to_char(p_ora_date, 'DD');
              l_hour := to_char(p_ora_date, 'HH');
              l_min := to_char(p_ora_date, 'MI');
              l_sec := to_char(p_ora_date, 'SS');
              x_ucc_date := l_year  || '-' || l_month || '-' || l_day || 'T' || l_hour || ':' ||
                             l_min || ':' || l_sec;
           ELSE
              x_ucc_date := NULL;
           END IF;
        EXCEPTION
        WHEN OTHERS THEN
           raise ;
        END convert_to_uccnet_datetime;


        FUNCTION get_lookup_meaning( p_lookup_type VARCHAR2, p_lookup_code VARCHAR)
          RETURN VARCHAR2
        IS
          v_meaning  fnd_lookups.meaning%TYPE;
        BEGIN
           SELECT meaning INTO v_meaning
                FROM fnd_lookups
                WHERE lookup_type = p_lookup_type
                AND   lookup_code = p_lookup_code
                AND   ROWNUM =1 ;
           RETURN v_meaning;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RETURN null;
          WHEN OTHERS THEN
            RETURN null; -- lets not raise errors here, it will stop the XML Generation
        END;

        FUNCTION get_time       RETURN VARCHAR2
        IS
                l_time  VARCHAR2(50);
        BEGIN
                l_time := to_char(sysdate, 'HH24:MI:SS');
                RETURN l_time;
        EXCEPTION
                WHEN OTHERS THEN
                        RETURN NULL;-- don't want to stop XMLG generation due to this
        END;

        FUNCTION get_time_zone  RETURN VARCHAR2
        IS
                l_time_zone     VARCHAR2(50);
        BEGIN
                l_time_zone := 'EST';
                RETURN l_time_zone;
        EXCEPTION
                WHEN OTHERS THEN
                        RETURN NULL;-- don't want to stop XMLG generation due to this
        END;

        FUNCTION get_sys_date   RETURN VARCHAR2
        IS
           l_date               VARCHAR2(50);
        BEGIN
                l_date := to_char(sysdate, 'YYYY-MM-DD');
                RETURN l_date;
        EXCEPTION
                WHEN OTHERS THEN
                        RETURN NULL; -- don't want to stop XMLG generation due to this
        END;

        FUNCTION get_guid RETURN VARCHAR2
        IS
                l_guid          VARCHAR2(400);
        BEGIN
                l_guid  := SYS_GUID();
                RETURN l_guid;
        EXCEPTION
                WHEN OTHERS THEN
                       RETURN NULL; -- continue if guid fail (not likey!)
        END;


        -- calculate the status type of an item based on the difference between dates if provided
        PROCEDURE process_catalogue_item_status(
                p_cancel_date                   IN  DATE,
                p_discontinue_date              IN  DATE,
                x_catalogue_item_status         OUT NOCOPY VARCHAR2
        )
        IS
                l_current_date                  DATE;
                l_cancel_date                   DATE;
                l_discontinue_date              DATE;

                l_day                           NUMBER;
        BEGIN
                IF (l_debug_level <= 2) THEN
                        cln_debug_pub.Add('M4U:----- Entering process_catalogue_item_status  ------- ',2);
                END IF;

                -- By Default, the status type is REGISTERED
                x_catalogue_item_status := 'REGISTERED';

                -- If cancel date is not null
                IF (p_cancel_date IS NOT NULL) THEN
                        l_current_date       := to_date(to_char(SYSDATE, 'YYYY-MM-DD'),'YYYY-MM-DD');
                        l_cancel_date        := to_date(to_char(p_cancel_date, 'YYYY-MM-DD'),'YYYY-MM-DD');

                        IF (l_debug_level <= 1) THEN
                              cln_debug_pub.Add('Current Date  -> '||l_current_date,1);
                              cln_debug_pub.Add('Cancel Date   -> '||l_cancel_date,1);
                        END IF;

                        l_day        := l_cancel_date - l_current_date;
                        IF (l_debug_level <= 1) THEN
                              cln_debug_pub.Add('Days Difference  -> '||l_day,1);
                        END IF;

                        --IF (l_day = 0) THEN /*bug5368180*/
                        IF (l_day <= 0) THEN
                              x_catalogue_item_status := 'CANCELED';
                        END IF;

                        IF (l_debug_level <= 1) THEN
                              cln_debug_pub.Add('p_catalogue_item_status  -> '||x_catalogue_item_status,1);
                        END IF;


                        IF (l_debug_level <= 2) THEN
                              cln_debug_pub.Add('M4U:----- Exiting process_catalogue_item_status  ------- ',2);
                        END IF;

                        RETURN;
                END IF;

                -- If discontinue date is not null
                IF (p_discontinue_date IS NOT NULL) THEN
                        l_current_date       := to_date(to_char(SYSDATE, 'YYYY-MM-DD'), 'YYYY-MM-DD');
                        l_discontinue_date   := to_date(to_char(p_discontinue_date, 'YYYY-MM-DD'),'YYYY-MM-DD');

                        IF (l_debug_level <= 1) THEN
                              cln_debug_pub.Add('Current Date       -> '||l_current_date,1);
                              cln_debug_pub.Add('Discontinue Date   -> '||l_discontinue_date,1);
                        END IF;

                        l_day        := l_discontinue_date - l_current_date;
                        IF (l_debug_level <= 1) THEN
                              cln_debug_pub.Add('Days Difference  -> '||l_day,1);
                        END IF;

                        --IF (l_day = 0) THEN /*bug5368180*/
                        IF (l_day <= 0) THEN
                              x_catalogue_item_status := 'DISCONTINUED';
                        END IF;

                        IF (l_debug_level <= 1) THEN
                              cln_debug_pub.Add('p_catalogue_item_status  -> '||x_catalogue_item_status,1);
                        END IF;


                        IF (l_debug_level <= 2) THEN
                              cln_debug_pub.Add('M4U:----- Exiting process_catalogue_item_status  ------- ',2);
                        END IF;

                        RETURN;
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                    IF (l_debug_level <= 6) THEN
                          cln_debug_pub.Add('M4U:----- Exiting process_catalogue_item_status  ERROR------- ',6);
                    END IF;

                    raise ;
        END process_catalogue_item_status;

        -- Name
        --    CONVERT_TO_DATE
        -- Purpose
        --    This is internal procedure to convert the string into a date
        --
        FUNCTION CONVERT_TO_DATE(
               p_string                 VARCHAR2
          ) RETURN DATE
          IS
             l_date                     DATE;
          BEGIN
             l_date := NULL;
             BEGIN
               l_date := to_date(p_string,'YYYY/MM/DD HH24:MI:SS');
             EXCEPTION
                WHEN OTHERS THEN
                     BEGIN
                        l_date := to_date(p_string,'YYYY/MM/DD');
                     EXCEPTION
                        WHEN OTHERS THEN
                           l_date := NULL;
                     END;
             END;
             RETURN l_date;
        END;



        -- change the value of the input string as per xslt processing
        PROCEDURE format_industry_ext_string(
                p_industry_column               IN         VARCHAR2,
                x_mutiple_industry_ext          OUT NOCOPY VARCHAR2
        )
        IS

                countchk                         NUMBER;
                strlength                        NUMBER;
                industry_var                     VARCHAR2(3);
        BEGIN
                IF (l_debug_level <= 2) THEN
                        cln_debug_pub.Add('M4U:----- Entering format_industry_ext_string  ------- ',2);
                END IF;

                IF (l_debug_level <= 1) THEN
                      cln_debug_pub.Add('Industry Column value = '||p_industry_column,1);
                END IF;

                IF(p_industry_column IS NULL) THEN
                        IF (l_debug_level <= 1) THEN
                                cln_debug_pub.Add('Industry Column value is null',1);
                        END IF;
                        RETURN;
                END IF;

                strlength       := length(p_industry_column);
                IF (l_debug_level <= 1) THEN
                      cln_debug_pub.Add('Length of the Industry Column String '||strlength,1);
                END IF;

                countchk  := 1;

                LOOP
                     industry_var :=substr(p_industry_column,countchk,1);

                     IF (l_debug_level <= 1) THEN
                           cln_debug_pub.Add('Industry Ext Variable - '||industry_var,1);
                     END IF;

                     IF ( industry_var ='f')THEN
                             IF(length(x_mutiple_industry_ext) <>0) THEN
                                   x_mutiple_industry_ext := x_mutiple_industry_ext||':';
                             END IF;

                             x_mutiple_industry_ext := x_mutiple_industry_ext||'fmcg';

                             IF (l_debug_level <= 1) THEN
                                   cln_debug_pub.Add('Industry Ext value - '||x_mutiple_industry_ext,1);
                             END IF;
                     END IF;

                     IF ( industry_var ='h')THEN
                             IF(length(x_mutiple_industry_ext) <>0) THEN
                                    x_mutiple_industry_ext := x_mutiple_industry_ext||':';
                             END IF;

                             x_mutiple_industry_ext := x_mutiple_industry_ext||'hardlines';

                             IF (l_debug_level <= 1) THEN
                                   cln_debug_pub.Add('Industry Ext value - '||x_mutiple_industry_ext,1);
                             END IF;
                     END IF;

                     IF ( industry_var ='s')THEN
                             IF(length(x_mutiple_industry_ext) <>0) THEN
                                    x_mutiple_industry_ext := x_mutiple_industry_ext||':';
                             END IF;

                             x_mutiple_industry_ext := x_mutiple_industry_ext||'sbdh';
                             IF (l_debug_level <= 1) THEN
                                   cln_debug_pub.Add('Industry Ext value - '||x_mutiple_industry_ext,1);
                             END IF;
                     END IF;

                     countchk  := countchk+2;
                     IF (l_debug_level <= 1) THEN
                           cln_debug_pub.Add('Count Check'||countchk,1);
                     END IF;
                     EXIT WHEN countchk > strlength;
                END LOOP;

                IF (l_debug_level <= 2) THEN
                      cln_debug_pub.Add('M4U:----- Exiting format_industry_ext_string  ------- ',2);
                END IF;

        EXCEPTION
                WHEN OTHERS THEN
                    IF (l_debug_level <= 6) THEN
                          cln_debug_pub.Add('M4U:----- Exiting format_industry_ext_string  ERROR------- ',6);
                    END IF;

                    raise ;
        END format_industry_ext_string;



        FUNCTION validate_checkdigit_gtin(
                        p_gtin                          IN VARCHAR2
                )RETURN BOOLEAN
        IS
                l_right_sum                     NUMBER;
                l_left_sum                      NUMBER;
                l_con_sum                       NUMBER;
                l_calculatedCheckDigit          NUMBER;
                l_remainder                     NUMBER;
                l_checkDigit                    NUMBER;
                l_error_code                    VARCHAR2(50);
                l_error_msg                     VARCHAR2(200);

        BEGIN
                IF (l_debug_level <= 2) THEN
                        cln_debug_pub.Add('M4U:----- Entering validate_checkdigit_gtin  ------- ',2);
                END IF;

                l_checkDigit:=   TO_NUMBER(SUBSTR(p_gtin,14,1 ));

                IF (l_debug_level <= 1) THEN
                        cln_debug_pub.Add('M4U: Checksum Attached : '||l_checkDigit,1);
                END IF;


                l_right_sum :=  TO_NUMBER(SUBSTR(p_gtin,1,1 ))+
                                TO_NUMBER(SUBSTR(p_gtin,3,1 ))+
                                TO_NUMBER(SUBSTR(p_gtin,5,1 ))+
                                TO_NUMBER(SUBSTR(p_gtin,7,1 ))+
                                TO_NUMBER(SUBSTR(p_gtin,9,1 ))+
                                TO_NUMBER(SUBSTR(p_gtin,11,1 ))+
                                TO_NUMBER(SUBSTR(p_gtin,13,1 ));
                IF (l_debug_level <= 1) THEN
                        cln_debug_pub.Add('M4U: Sum Of Odd Numbers: '||l_right_sum,1);
                END IF;


                l_left_sum :=   TO_NUMBER(SUBSTR(p_gtin,2,1 ))+
                                TO_NUMBER(SUBSTR(p_gtin,4,1 ))+
                                TO_NUMBER(SUBSTR(p_gtin,6,1 ))+
                                TO_NUMBER(SUBSTR(p_gtin,8,1 ))+
                                TO_NUMBER(SUBSTR(p_gtin,10,1 ))+
                                TO_NUMBER(SUBSTR(p_gtin,12,1 ));

                IF (l_debug_level <= 1) THEN
                                cln_debug_pub.Add('M4U: Sum Of Even Numbers: '||l_left_sum,1);
                END IF;

                l_con_sum  :=    l_right_sum*3 + l_left_sum;
                IF (l_debug_level <= 1) THEN
                                cln_debug_pub.Add('M4U: consolidated sum   : '||l_con_sum,1);
                END IF;

                l_remainder :=   Mod(l_con_sum,10);
                IF (l_debug_level <= 1) THEN
                                cln_debug_pub.Add('M4U: Remainder          : '||l_remainder,1);
                END IF;

                IF (l_remainder = 0) THEN
                        l_remainder := 10;
                END IF;

                l_calculatedCheckDigit := 10 - l_remainder;
                IF (l_debug_level <= 1) THEN
                        cln_debug_pub.Add('M4U: Calculated Checksum: '||l_calculatedCheckDigit,1);
                END IF;

                IF (l_checkDigit <> l_calculatedCheckDigit) THEN
                        IF (l_debug_level <= 1) THEN
                                cln_debug_pub.Add('M4U: Incorrect Checksum',1);
                                cln_debug_pub.Add('------- Exiting validate_checkdigit_gtin  - ',1);
                        END IF;

                        RETURN FALSE;
                END IF;

                IF (l_debug_level <= 2) THEN
                        cln_debug_pub.Add('------- Exiting validate_checkdigit_gtin   --------- ',2);
                END IF;

                RETURN TRUE;
        EXCEPTION
                WHEN OTHERS THEN
                        l_error_code       :=SQLCODE;
                        l_error_msg        :=SQLERRM;

                        IF (l_debug_level <= 5) THEN
                             cln_debug_pub.Add(' :: '||l_error_code||' :: '||l_error_msg,5);
                        END IF;

                        IF (l_debug_level <= 2) THEN
                             cln_debug_pub.Add('------- Exiting validate_checkdigit_gtin  - Exception --------- ',2);
                        END IF;
                        RETURN FALSE;
        END;


        FUNCTION validate_checkdigit_gln(
                         p_gln                           IN VARCHAR2
                 )RETURN BOOLEAN
        IS
                l_right_sum                     NUMBER;
                l_left_sum                      NUMBER;
                l_con_sum                       NUMBER;
                l_calculatedCheckDigit          NUMBER;
                l_remainder                     NUMBER;
                l_checkDigit                    NUMBER;
                l_error_code                    VARCHAR2(50);
                l_error_msg                     VARCHAR2(200);

        BEGIN
                IF (l_debug_level <= 2) THEN
                        cln_debug_pub.Add('M4U:----- Entering validate_checkdigit_gln  ------- ',2);
                END IF;

                l_checkDigit:=   TO_NUMBER(SUBSTR(p_gln,13,1 ));
                IF (l_debug_level <= 1) THEN
                        cln_debug_pub.Add('M4U: Checksum Attached : '||l_checkDigit,1);
                END IF;


                l_left_sum  :=  TO_NUMBER(SUBSTR(p_gln,1,1 ))+
                                TO_NUMBER(SUBSTR(p_gln,3,1 ))+
                                TO_NUMBER(SUBSTR(p_gln,5,1 ))+
                                TO_NUMBER(SUBSTR(p_gln,7,1 ))+
                                TO_NUMBER(SUBSTR(p_gln,9,1 ))+
                                TO_NUMBER(SUBSTR(p_gln,11,1 ));

                IF (l_debug_level <= 1) THEN
                        cln_debug_pub.Add('M4U: Sum Of Odd Numbers: '||l_right_sum,1);
                END IF;


                l_right_sum :=  TO_NUMBER(SUBSTR(p_gln,2,1 ))+
                                TO_NUMBER(SUBSTR(p_gln,4,1 ))+
                                TO_NUMBER(SUBSTR(p_gln,6,1 ))+
                                TO_NUMBER(SUBSTR(p_gln,8,1 ))+
                                TO_NUMBER(SUBSTR(p_gln,10,1 ))+
                                TO_NUMBER(SUBSTR(p_gln,12,1 ));
                IF (l_debug_level <= 1) THEN
                        cln_debug_pub.Add('M4U: Sum Of Even Numbers: '||l_left_sum,1);
                END IF;

                l_con_sum  :=    l_right_sum*3 + l_left_sum;
                IF (l_debug_level <= 1) THEN
                        cln_debug_pub.Add('M4U: consolidated sum   : '||l_con_sum,1);
                END IF;

                l_remainder :=   Mod(l_con_sum,10);
                IF (l_debug_level <= 1) THEN
                         cln_debug_pub.Add('M4U: Remainder          : '||l_remainder,1);
                END IF;

                if (l_remainder = 0) then
                        l_remainder := 10;
                end if;

                l_calculatedCheckDigit := 10 - l_remainder;
                IF (l_debug_level <= 1) THEN
                        cln_debug_pub.Add('M4U: Calculated Checksum: '||l_calculatedCheckDigit,1);
                END IF;

                IF (l_checkDigit <> l_calculatedCheckDigit) THEN
                        IF (l_debug_level <= 1) THEN
                                cln_debug_pub.Add('M4U: Incorrect Checksum',1);
                                cln_debug_pub.Add('------- Exiting validate_checkdigit_gln  - ',1);
                        END IF;
                        return FALSE;
                END IF;

                IF (l_debug_level <= 2) THEN
                        cln_debug_pub.Add('------- Exiting validate_checkdigit_gln   --------- ',2);
                END IF;

                return TRUE;
        EXCEPTION
                WHEN OTHERS THEN
                        l_error_code       :=SQLCODE;
                        l_error_msg        :=SQLERRM;

                        IF (l_debug_level <= 5) THEN
                                cln_debug_pub.Add(' :: '||l_error_code||' :: '||l_error_msg,5);
                        END IF;

                        IF (l_debug_level <= 2) THEN
                                cln_debug_pub.Add('------- Exiting validate_checkdigit_gln  - Exception --------- ',2);
                        END IF;
                        RETURN FALSE;
        END;

        -- Name
        --      validate_uccnet_attr
        -- Purpose
        --      This procedure is used for validating the GTIN/GLN at the moment
        -- Arguments
        -- Notes
        --
        FUNCTION validate_uccnet_attr(
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_attr_type             IN  VARCHAR2,
                p_attr_value            IN  VARCHAR2
          )RETURN BOOLEAN

        IS
                l_attr_name             VARCHAR2(20);
                l_attr_len              NUMBER;
                l_attr_value            NUMBER;
                l_msg_data              VARCHAR2(100);
                l_error_code            VARCHAR2(50);
                l_error_msg             VARCHAR2(200);
        BEGIN

                IF (l_debug_Level <= 2) THEN
                        cln_debug_pub.Add('M4U:----- Entering validate_uccnet_attr  ------- ',2);
                END IF;

                -- Parameters received
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('++++ PARAMETERS RECEIVED +++ ',1);
                        cln_debug_pub.Add('p_attr_type           - '||p_attr_type,1);
                        cln_debug_pub.Add('p_attr_value          - '||p_attr_value,1);
                        cln_debug_pub.Add('==============================',1);
                END IF;

                IF (p_attr_type = 'GLN') THEN
                        l_msg_data := 'Validation Failed: GLN should be 13 length digits';
                        FND_MESSAGE.SET_NAME('CLN','M4U_ATTRVAL_GLN_1');
                        x_msg_data := FND_MESSAGE.GET;

                        select length(p_attr_value) into l_attr_len from dual;

                        If(l_attr_len <> 13) THEN
                             RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        l_msg_data := 'Validation Failed: GLN should be a numeric value';

                        FND_MESSAGE.SET_NAME('CLN','M4U_ATTRVAL_GLN_2');
                        x_msg_data := FND_MESSAGE.GET;
                        select to_number(p_attr_value,'9999999999999') into l_attr_value from dual;


                        l_msg_data := 'Validation Failed: GLN check digitsum is wrong';

                        FND_MESSAGE.SET_NAME('CLN','M4U_ATTRVAL_GLN_3');
                        x_msg_data := FND_MESSAGE.GET;

                        IF(NOT validate_checkdigit_gln(p_attr_value)) THEN
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        return TRUE;
                        l_msg_data := 'GLN validated';

                        FND_MESSAGE.SET_NAME('CLN','M4U_ATTRVAL_GLN_VALID');
                        x_msg_data := FND_MESSAGE.GET;
                END IF;

                IF (p_attr_type = 'GTIN') THEN
                        -- 1. GTINs submitted in RCI messages must be 14 characters
                        l_msg_data := 'Validation Failed: GTIN should be 14 length digits';
                        FND_MESSAGE.SET_NAME('CLN','M4U_ATTRVAL_GTIN_1');
                        x_msg_data := FND_MESSAGE.GET;

                        select length(p_attr_value) into l_attr_len from dual;

                        If(l_attr_len <> 14) THEN
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;


                        -- 2. GTIN should be a numeric entity
                        l_msg_data := 'Validation Failed: GTIN should be a numeric value';
                        FND_MESSAGE.SET_NAME('CLN','M4U_ATTRVAL_GTIN_2');
                        x_msg_data := FND_MESSAGE.GET;

                        select to_number(p_attr_value,'99999999999999') into l_attr_value from dual;

                        -- 3. Checksum should be correct
                        l_msg_data := 'Validation Failed: GTIN check digitsum is wrong';
                        FND_MESSAGE.SET_NAME('CLN','M4U_ATTRVAL_GTIN_3');
                        x_msg_data := FND_MESSAGE.GET;

                        IF(NOT validate_checkdigit_gtin(p_attr_value)) THEN
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        return TRUE;

                        l_msg_data := 'GTIN validated';
                        FND_MESSAGE.SET_NAME('CLN','M4U_ATTRVAL_GTIN_VALID');
                        x_msg_data := FND_MESSAGE.GET;
                END IF;

                IF (p_attr_type = 'TRGMKT') THEN
                        -- Parameters received
                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('Target Mkt Check    - '||p_attr_value,1);
                        END IF;


                        l_msg_data := 'Validation Failed: Target Market should be 1-3 digits';
                        FND_MESSAGE.SET_NAME('CLN','M4U_ATTRVAL_TRGMKT_1');
                        x_msg_data := FND_MESSAGE.GET;

                        select length(p_attr_value) into l_attr_len from dual;

                        If(l_attr_len > 3) THEN
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        return TRUE;
                END IF;

        -- Exception Handling
        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        x_return_status := FND_API.G_RET_STS_ERROR ;
                        IF (l_Debug_Level <= 4) THEN
                                cln_debug_pub.Add(l_msg_data,4);
                                cln_debug_pub.Add('------- Exiting validate_uccnet_attr API --------- ',2);
                        END IF;

                        return FALSE;
                WHEN OTHERS THEN
                        l_error_code       :=SQLCODE;
                        l_error_msg        :=SQLERRM;

                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                        x_msg_data        :=l_error_code||' : '||l_error_msg||' : '||x_msg_data;

                        IF (l_Debug_Level <= 5) THEN
                                cln_debug_pub.Add(x_msg_data,5);
                        END IF;

                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('------- Exiting validate_uccnet_attr  - Exception --------- ',2);
                        END IF;

                        Return false;

        END;



        BEGIN
        /* Package initialization. */
        l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('... Initialization for UTILS package ...',1);
                END IF;

                SELECT          to_char(e.party_id), to_char(e.party_site_id)
                INTO            g_party_id,          g_party_site_id
                FROM            hr_locations_all h,
                                ecx_tp_headers   e
                WHERE           h.location_id   = e.party_id
                        AND     UPPER(e.party_type)    = UPPER(c_party_type)
                        AND     UPPER(h.location_code) = UPPER(c_party_site_name);

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Party ID set as      '||g_party_id,1);
                      cln_debug_pub.Add('Party Site ID set as '||g_party_site_id,1);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Trading Partner Setup in the XML Gateway Defined',1);
                END IF;

                SELECT          name
                INTO            g_local_system
                FROM            wf_systems
                WHERE           guid = wf_core.translate('WF_SYSTEM_GUID');

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Local System    '||g_local_system,1);
                      cln_debug_pub.Add('wf_core.translate(WF_SYSTEM_GUID) returned normal data',1);
                END IF;

                SELECT          FND_PROFILE.VALUE('ORG_ID'),
                                FND_PROFILE.VALUE('M4U_UCCNET_GLN'),
                                FND_PROFILE.VALUE('M4U_SUPP_GLN')
                INTO            g_org_id,g_host_gln,g_supp_gln
                FROM            DUAL;

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Org ID            -'||g_org_id,1);
                      cln_debug_pub.Add('Host GLN          -'||g_host_gln,1);
                      cln_debug_pub.Add('Supplier GLN      -'||g_supp_gln,1);
                      cln_debug_pub.Add('profile values set for M4U',1);
                END IF;
END m4u_ucc_utils;

/
