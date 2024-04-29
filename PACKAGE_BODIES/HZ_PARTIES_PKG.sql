--------------------------------------------------------
--  DDL for Package Body HZ_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTIES_PKG" AS
/*$Header: ARHPTYTB.pls 120.6 2006/05/05 09:20:42 pkasturi ship $ */

FUNCTION do_copy_duns_number(
  p_duns_number_c                     IN     VARCHAR2
) RETURN NUMBER IS

  l_char                              VARCHAR2(1);
  l_str                               HZ_PARTIES.DUNS_NUMBER_C%TYPE;

BEGIN

  -- if duns_number is null and duns_number_c is not null then get the
  -- value of duns_number_c, convert it to number and copy it to duns_number

/* Bug 3435702.This check is done before calling this procedure and as such is redundant.
 |
 | IF p_duns_number_c IS NOT NULL AND
 |    p_duns_number_c <> FND_API.G_MISS_CHAR
 | THEN
 */
    FOR i IN 1..LENGTHB(p_duns_number_c) LOOP
      l_char := SUBSTRB(p_duns_number_c, i, 1);
      IF (l_char >= '0' AND l_char <= '9') THEN
        l_str  :=  l_str || l_char;
      END IF;
    END LOOP;
    RETURN TO_NUMBER(l_str);
 /* END IF;*/

  RETURN NULL;

END do_copy_duns_number;

PROCEDURE Insert_Row (
    X_PARTY_ID                              IN OUT NOCOPY NUMBER,
    X_PARTY_NUMBER                          IN OUT NOCOPY VARCHAR2,
    X_PARTY_NAME                            IN     VARCHAR2,
    X_PARTY_TYPE                            IN     VARCHAR2,
    X_VALIDATED_FLAG                        IN     VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    IN     VARCHAR2,
    X_ATTRIBUTE1                            IN     VARCHAR2,
    X_ATTRIBUTE2                            IN     VARCHAR2,
    X_ATTRIBUTE3                            IN     VARCHAR2,
    X_ATTRIBUTE4                            IN     VARCHAR2,
    X_ATTRIBUTE5                            IN     VARCHAR2,
    X_ATTRIBUTE6                            IN     VARCHAR2,
    X_ATTRIBUTE7                            IN     VARCHAR2,
    X_ATTRIBUTE8                            IN     VARCHAR2,
    X_ATTRIBUTE9                            IN     VARCHAR2,
    X_ATTRIBUTE10                           IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_ATTRIBUTE16                           IN     VARCHAR2,
    X_ATTRIBUTE17                           IN     VARCHAR2,
    X_ATTRIBUTE18                           IN     VARCHAR2,
    X_ATTRIBUTE19                           IN     VARCHAR2,
    X_ATTRIBUTE20                           IN     VARCHAR2,
    X_ATTRIBUTE21                           IN     VARCHAR2,
    X_ATTRIBUTE22                           IN     VARCHAR2,
    X_ATTRIBUTE23                           IN     VARCHAR2,
    X_ATTRIBUTE24                           IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_SIC_CODE                              IN     VARCHAR2,
    X_HQ_BRANCH_IND                         IN     VARCHAR2,
    X_CUSTOMER_KEY                          IN     VARCHAR2,
    X_TAX_REFERENCE                         IN     VARCHAR2,
    X_JGZZ_FISCAL_CODE                      IN     VARCHAR2,
    X_PERSON_PRE_NAME_ADJUNCT               IN     VARCHAR2,
    X_PERSON_FIRST_NAME                     IN     VARCHAR2,
    X_PERSON_MIDDLE_NAME                    IN     VARCHAR2,
    X_PERSON_LAST_NAME                      IN     VARCHAR2,
    X_PERSON_NAME_SUFFIX                    IN     VARCHAR2,
    X_PERSON_TITLE                          IN     VARCHAR2,
    X_PERSON_ACADEMIC_TITLE                 IN     VARCHAR2,
    X_PERSON_PREVIOUS_LAST_NAME             IN     VARCHAR2,
    X_KNOWN_AS                              IN     VARCHAR2,
    X_PERSON_IDEN_TYPE                      IN     VARCHAR2,
    X_PERSON_IDENTIFIER                     IN     VARCHAR2,
    X_GROUP_TYPE                            IN     VARCHAR2,
    X_COUNTRY                               IN     VARCHAR2,
    X_ADDRESS1                              IN     VARCHAR2,
    X_ADDRESS2                              IN     VARCHAR2,
    X_ADDRESS3                              IN     VARCHAR2,
    X_ADDRESS4                              IN     VARCHAR2,
    X_CITY                                  IN     VARCHAR2,
    X_POSTAL_CODE                           IN     VARCHAR2,
    X_STATE                                 IN     VARCHAR2,
    X_PROVINCE                              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_COUNTY                                IN     VARCHAR2,
    X_SIC_CODE_TYPE                         IN     VARCHAR2,
    X_URL                                   IN     VARCHAR2,
    X_EMAIL_ADDRESS                         IN     VARCHAR2,
    X_ANALYSIS_FY                           IN     VARCHAR2,
    X_FISCAL_YEAREND_MONTH                  IN     VARCHAR2,
    X_EMPLOYEES_TOTAL                       IN     NUMBER,
    X_CURR_FY_POTENTIAL_REVENUE             IN     NUMBER,
    X_NEXT_FY_POTENTIAL_REVENUE             IN     NUMBER,
    X_YEAR_ESTABLISHED                      IN     NUMBER,
    X_GSA_INDICATOR_FLAG                    IN     VARCHAR2,
    X_MISSION_STATEMENT                     IN     VARCHAR2,
    X_ORGANIZATION_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_FIRST_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_LAST_NAME_PHONETIC             IN     VARCHAR2,
    X_LANGUAGE_NAME                         IN     VARCHAR2,
    X_CATEGORY_CODE                         IN     VARCHAR2,
    X_SALUTATION                            IN     VARCHAR2,
    X_KNOWN_AS2                             IN     VARCHAR2,
    X_KNOWN_AS3                             IN     VARCHAR2,
    X_KNOWN_AS4                             IN     VARCHAR2,
    X_KNOWN_AS5                             IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_DUNS_NUMBER_C                         IN     VARCHAR2,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

    l_duns_number                           NUMBER;
    l_success                               VARCHAR2(1) := 'N';
    l_duns_number_c                         HZ_PARTIES.duns_number_c%type := X_DUNS_NUMBER_C;
BEGIN

    IF x_duns_number_c IS NOT NULL AND
       x_duns_number_c <> FND_API.G_MISS_CHAR
    THEN
      l_duns_number := do_copy_duns_number(x_duns_number_c);
    END IF;

   IF x_duns_number_c IS NOT NULL AND
      x_duns_number_c <> FND_API.G_MISS_CHAR AND
      LENGTHB(x_duns_number_c)<9
   THEN
      l_duns_number_c:=lpad(x_duns_number_c,9,'0');
   END IF;

    WHILE l_success = 'N' LOOP
    BEGIN
        INSERT INTO HZ_PARTIES (
            PARTY_ID,
            PARTY_NUMBER,
            PARTY_NAME,
            PARTY_TYPE,
            VALIDATED_FLAG,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            CREATED_BY,
            LAST_UPDATE_DATE,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            ATTRIBUTE16,
            ATTRIBUTE17,
            ATTRIBUTE18,
            ATTRIBUTE19,
            ATTRIBUTE20,
            ATTRIBUTE21,
            ATTRIBUTE22,
            ATTRIBUTE23,
            ATTRIBUTE24,
            ORIG_SYSTEM_REFERENCE,
            SIC_CODE,
            HQ_BRANCH_IND,
            CUSTOMER_KEY,
            TAX_REFERENCE,
            JGZZ_FISCAL_CODE,
            PERSON_PRE_NAME_ADJUNCT,
            PERSON_FIRST_NAME,
            PERSON_MIDDLE_NAME,
            PERSON_LAST_NAME,
            PERSON_NAME_SUFFIX,
            PERSON_TITLE,
            PERSON_ACADEMIC_TITLE,
            PERSON_PREVIOUS_LAST_NAME,
            KNOWN_AS,
            PERSON_IDEN_TYPE,
            PERSON_IDENTIFIER,
            GROUP_TYPE,
            COUNTRY,
            ADDRESS1,
            ADDRESS2,
            ADDRESS3,
            ADDRESS4,
            CITY,
            POSTAL_CODE,
            STATE,
            PROVINCE,
            STATUS,
            COUNTY,
            SIC_CODE_TYPE,
            URL,
            EMAIL_ADDRESS,
            ANALYSIS_FY,
            FISCAL_YEAREND_MONTH,
            EMPLOYEES_TOTAL,
            CURR_FY_POTENTIAL_REVENUE,
            NEXT_FY_POTENTIAL_REVENUE,
            YEAR_ESTABLISHED,
            GSA_INDICATOR_FLAG,
            MISSION_STATEMENT,
            ORGANIZATION_NAME_PHONETIC,
            PERSON_FIRST_NAME_PHONETIC,
            PERSON_LAST_NAME_PHONETIC,
            LANGUAGE_NAME,
            CATEGORY_CODE,
            SALUTATION,
            KNOWN_AS2,
            KNOWN_AS3,
            KNOWN_AS4,
            KNOWN_AS5,
            OBJECT_VERSION_NUMBER,
            DUNS_NUMBER_C,
            DUNS_NUMBER,
            CREATED_BY_MODULE,
            APPLICATION_ID
        )
        VALUES (
            DECODE( X_PARTY_ID, FND_API.G_MISS_NUM, HZ_PARTIES_S.NEXTVAL, NULL, HZ_PARTIES_S.NEXTVAL, X_PARTY_ID ),
            DECODE( X_PARTY_NUMBER, FND_API.G_MISS_CHAR, TO_CHAR( HZ_PARTY_NUMBER_S.NEXTVAL ), NULL, TO_CHAR( HZ_PARTY_NUMBER_S.NEXTVAL ), X_PARTY_NUMBER ),
            DECODE( X_PARTY_NAME, FND_API.G_MISS_CHAR, NULL, X_PARTY_NAME ),
            DECODE( X_PARTY_TYPE, FND_API.G_MISS_CHAR, NULL, X_PARTY_TYPE ),
            DECODE( X_VALIDATED_FLAG, FND_API.G_MISS_CHAR, 'N', NULL, 'N', X_VALIDATED_FLAG ),
            HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
            HZ_UTILITY_V2PUB.CREATION_DATE,
            HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
            HZ_UTILITY_V2PUB.REQUEST_ID,
            HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
            HZ_UTILITY_V2PUB.CREATED_BY,
            HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
            HZ_UTILITY_V2PUB.PROGRAM_ID,
            HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
            DECODE( X_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE_CATEGORY ),
            DECODE( X_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE1 ),
            DECODE( X_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE2 ),
            DECODE( X_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE3 ),
            DECODE( X_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE4 ),
            DECODE( X_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE5 ),
            DECODE( X_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE6 ),
            DECODE( X_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE7 ),
            DECODE( X_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE8 ),
            DECODE( X_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE9 ),
            DECODE( X_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE10 ),
            DECODE( X_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE11 ),
            DECODE( X_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE12 ),
            DECODE( X_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE13 ),
            DECODE( X_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE14 ),
            DECODE( X_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE15 ),
            DECODE( X_ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE16 ),
            DECODE( X_ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE17 ),
            DECODE( X_ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE18 ),
            DECODE( X_ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE19 ),
            DECODE( X_ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE20 ),
            DECODE( X_ATTRIBUTE21, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE21 ),
            DECODE( X_ATTRIBUTE22, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE22 ),
            DECODE( X_ATTRIBUTE23, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE23 ),
            DECODE( X_ATTRIBUTE24, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE24 ),
            DECODE( X_ORIG_SYSTEM_REFERENCE, FND_API.G_MISS_CHAR, TO_CHAR(NVL(X_PARTY_ID,HZ_PARTIES_S.CURRVAL)), NULL, TO_CHAR(NVL(X_PARTY_ID,HZ_PARTIES_S.CURRVAL)), X_ORIG_SYSTEM_REFERENCE ),
            DECODE( X_SIC_CODE, FND_API.G_MISS_CHAR, NULL, X_SIC_CODE ),
            DECODE( X_HQ_BRANCH_IND, FND_API.G_MISS_CHAR, NULL, X_HQ_BRANCH_IND ),
            DECODE( X_CUSTOMER_KEY, FND_API.G_MISS_CHAR, NULL, X_CUSTOMER_KEY ),
            DECODE( X_TAX_REFERENCE, FND_API.G_MISS_CHAR, NULL, X_TAX_REFERENCE ),
            DECODE( X_JGZZ_FISCAL_CODE, FND_API.G_MISS_CHAR, NULL, X_JGZZ_FISCAL_CODE ),
            DECODE( X_PERSON_PRE_NAME_ADJUNCT, FND_API.G_MISS_CHAR, NULL, X_PERSON_PRE_NAME_ADJUNCT ),
            DECODE( X_PERSON_FIRST_NAME, FND_API.G_MISS_CHAR, NULL, X_PERSON_FIRST_NAME ),
            DECODE( X_PERSON_MIDDLE_NAME, FND_API.G_MISS_CHAR, NULL, X_PERSON_MIDDLE_NAME ),
            DECODE( X_PERSON_LAST_NAME, FND_API.G_MISS_CHAR, NULL, X_PERSON_LAST_NAME ),
            DECODE( X_PERSON_NAME_SUFFIX, FND_API.G_MISS_CHAR, NULL, X_PERSON_NAME_SUFFIX ),
            DECODE( X_PERSON_TITLE, FND_API.G_MISS_CHAR, NULL, X_PERSON_TITLE ),
            DECODE( X_PERSON_ACADEMIC_TITLE, FND_API.G_MISS_CHAR, NULL, X_PERSON_ACADEMIC_TITLE ),
            DECODE( X_PERSON_PREVIOUS_LAST_NAME, FND_API.G_MISS_CHAR, NULL, X_PERSON_PREVIOUS_LAST_NAME ),
            DECODE( X_KNOWN_AS, FND_API.G_MISS_CHAR, NULL, X_KNOWN_AS ),
            DECODE( X_PERSON_IDEN_TYPE, FND_API.G_MISS_CHAR, NULL, X_PERSON_IDEN_TYPE ),
            DECODE( X_PERSON_IDENTIFIER, FND_API.G_MISS_CHAR, NULL, X_PERSON_IDENTIFIER ),
            DECODE( X_GROUP_TYPE, FND_API.G_MISS_CHAR, NULL, X_GROUP_TYPE ),
            DECODE( X_COUNTRY, FND_API.G_MISS_CHAR, NULL, X_COUNTRY ),
            DECODE( X_ADDRESS1, FND_API.G_MISS_CHAR, NULL, X_ADDRESS1 ),
            DECODE( X_ADDRESS2, FND_API.G_MISS_CHAR, NULL, X_ADDRESS2 ),
            DECODE( X_ADDRESS3, FND_API.G_MISS_CHAR, NULL, X_ADDRESS3 ),
            DECODE( X_ADDRESS4, FND_API.G_MISS_CHAR, NULL, X_ADDRESS4 ),
            DECODE( X_CITY, FND_API.G_MISS_CHAR, NULL, X_CITY ),
            DECODE( X_POSTAL_CODE, FND_API.G_MISS_CHAR, NULL, X_POSTAL_CODE ),
            DECODE( X_STATE, FND_API.G_MISS_CHAR, NULL, X_STATE ),
            DECODE( X_PROVINCE, FND_API.G_MISS_CHAR, NULL, X_PROVINCE ),
            DECODE( X_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', X_STATUS ),
            DECODE( X_COUNTY, FND_API.G_MISS_CHAR, NULL, X_COUNTY ),
            DECODE( X_SIC_CODE_TYPE, FND_API.G_MISS_CHAR, NULL, X_SIC_CODE_TYPE ),
            DECODE( X_URL, FND_API.G_MISS_CHAR, NULL, X_URL ),
   --Bug 4355133
            SUBSTRB(DECODE( X_EMAIL_ADDRESS, FND_API.G_MISS_CHAR, NULL,
	    X_EMAIL_ADDRESS ),1,320),
            DECODE( X_ANALYSIS_FY, FND_API.G_MISS_CHAR, NULL, X_ANALYSIS_FY ),
            DECODE( X_FISCAL_YEAREND_MONTH, FND_API.G_MISS_CHAR, NULL, X_FISCAL_YEAREND_MONTH ),
            DECODE( X_EMPLOYEES_TOTAL, FND_API.G_MISS_NUM, NULL, X_EMPLOYEES_TOTAL ),
            DECODE( X_CURR_FY_POTENTIAL_REVENUE, FND_API.G_MISS_NUM, NULL, X_CURR_FY_POTENTIAL_REVENUE ),
            DECODE( X_NEXT_FY_POTENTIAL_REVENUE, FND_API.G_MISS_NUM, NULL, X_NEXT_FY_POTENTIAL_REVENUE ),
            DECODE( X_YEAR_ESTABLISHED, FND_API.G_MISS_NUM, NULL, X_YEAR_ESTABLISHED ),
            DECODE( X_GSA_INDICATOR_FLAG, FND_API.G_MISS_CHAR, NULL, X_GSA_INDICATOR_FLAG ),
            DECODE( X_MISSION_STATEMENT, FND_API.G_MISS_CHAR, NULL, X_MISSION_STATEMENT ),
            DECODE( X_ORGANIZATION_NAME_PHONETIC, FND_API.G_MISS_CHAR, NULL, X_ORGANIZATION_NAME_PHONETIC ),
            DECODE( X_PERSON_FIRST_NAME_PHONETIC, FND_API.G_MISS_CHAR, NULL, X_PERSON_FIRST_NAME_PHONETIC ),
            DECODE( X_PERSON_LAST_NAME_PHONETIC, FND_API.G_MISS_CHAR, NULL, X_PERSON_LAST_NAME_PHONETIC ),
            DECODE( X_LANGUAGE_NAME, FND_API.G_MISS_CHAR, NULL, X_LANGUAGE_NAME ),
            DECODE( X_CATEGORY_CODE, FND_API.G_MISS_CHAR, NULL, X_CATEGORY_CODE ),
            DECODE( X_SALUTATION, FND_API.G_MISS_CHAR, NULL, X_SALUTATION ),
            DECODE( X_KNOWN_AS2, FND_API.G_MISS_CHAR, NULL, X_KNOWN_AS2 ),
            DECODE( X_KNOWN_AS3, FND_API.G_MISS_CHAR, NULL, X_KNOWN_AS3 ),
            DECODE( X_KNOWN_AS4, FND_API.G_MISS_CHAR, NULL, X_KNOWN_AS4 ),
            DECODE( X_KNOWN_AS5, FND_API.G_MISS_CHAR, NULL, X_KNOWN_AS5 ),
            DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
            DECODE( X_DUNS_NUMBER_C, FND_API.G_MISS_CHAR, NULL,/*Bug 3435702*/ UPPER(l_duns_number_c)),
            /* Bug 3435702.This is replaced by l_duns_number as l_duns_number will be NULL if
	       X_DUNS_NUMBER_C is NULL or is equal to FND_API.G_MISS_CHAR.
	    DECODE( X_DUNS_NUMBER_C, FND_API.G_MISS_CHAR, NULL, NULL, NULL, l_duns_number ),
	    */
	    l_duns_number,
            DECODE( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
            DECODE( X_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID )
        ) RETURNING
            PARTY_ID,
            PARTY_NUMBER
        INTO
            X_PARTY_ID,
            X_PARTY_NUMBER;

        l_success := 'Y';

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            IF INSTRB( SQLERRM, 'HZ_PARTIES_U1' ) <> 0 OR
               INSTRB( SQLERRM, 'HZ_PARTIES_PK' ) <> 0
            THEN
            DECLARE
                l_count             NUMBER;
                l_dummy             VARCHAR2(1);
            BEGIN
                l_count := 1;
                WHILE l_count > 0 LOOP
                    SELECT HZ_PARTIES_S.NEXTVAL
                    INTO X_PARTY_ID FROM dual;
                    BEGIN
                        SELECT 'Y' INTO l_dummy
                        FROM HZ_PARTIES
                        WHERE PARTY_ID = X_PARTY_ID;
                        l_count := 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_count := 0;
                    END;
                END LOOP;
            END;
            ELSIF INSTRB( SQLERRM, 'HZ_PARTIES_U2' ) <> 0 THEN
            DECLARE
                l_count             NUMBER;
                l_dummy             VARCHAR2(1);
            BEGIN
                l_count := 1;
                WHILE l_count > 0 LOOP
                    SELECT TO_CHAR( HZ_PARTY_NUMBER_S.NEXTVAL )
                    INTO X_PARTY_NUMBER FROM dual;
                    BEGIN
                        SELECT 'Y' INTO l_dummy
                        FROM HZ_PARTIES
                        WHERE PARTY_NUMBER = X_PARTY_NUMBER;
                        l_count := 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_count := 0;
                    END;
                END LOOP;
            END;
            ELSE
                RAISE;
            END IF;

    END;
    END LOOP;

END Insert_Row;

PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_PARTY_ID                              IN     NUMBER,
    X_PARTY_NUMBER                          IN     VARCHAR2,
    X_PARTY_NAME                            IN     VARCHAR2,
    X_PARTY_TYPE                            IN     VARCHAR2,
    X_VALIDATED_FLAG                        IN     VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    IN     VARCHAR2,
    X_ATTRIBUTE1                            IN     VARCHAR2,
    X_ATTRIBUTE2                            IN     VARCHAR2,
    X_ATTRIBUTE3                            IN     VARCHAR2,
    X_ATTRIBUTE4                            IN     VARCHAR2,
    X_ATTRIBUTE5                            IN     VARCHAR2,
    X_ATTRIBUTE6                            IN     VARCHAR2,
    X_ATTRIBUTE7                            IN     VARCHAR2,
    X_ATTRIBUTE8                            IN     VARCHAR2,
    X_ATTRIBUTE9                            IN     VARCHAR2,
    X_ATTRIBUTE10                           IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_ATTRIBUTE16                           IN     VARCHAR2,
    X_ATTRIBUTE17                           IN     VARCHAR2,
    X_ATTRIBUTE18                           IN     VARCHAR2,
    X_ATTRIBUTE19                           IN     VARCHAR2,
    X_ATTRIBUTE20                           IN     VARCHAR2,
    X_ATTRIBUTE21                           IN     VARCHAR2,
    X_ATTRIBUTE22                           IN     VARCHAR2,
    X_ATTRIBUTE23                           IN     VARCHAR2,
    X_ATTRIBUTE24                           IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_SIC_CODE                              IN     VARCHAR2,
    X_HQ_BRANCH_IND                         IN     VARCHAR2,
    X_CUSTOMER_KEY                          IN     VARCHAR2,
    X_TAX_REFERENCE                         IN     VARCHAR2,
    X_JGZZ_FISCAL_CODE                      IN     VARCHAR2,
    X_PERSON_PRE_NAME_ADJUNCT               IN     VARCHAR2,
    X_PERSON_FIRST_NAME                     IN     VARCHAR2,
    X_PERSON_MIDDLE_NAME                    IN     VARCHAR2,
    X_PERSON_LAST_NAME                      IN     VARCHAR2,
    X_PERSON_NAME_SUFFIX                    IN     VARCHAR2,
    X_PERSON_TITLE                          IN     VARCHAR2,
    X_PERSON_ACADEMIC_TITLE                 IN     VARCHAR2,
    X_PERSON_PREVIOUS_LAST_NAME             IN     VARCHAR2,
    X_KNOWN_AS                              IN     VARCHAR2,
    X_PERSON_IDEN_TYPE                      IN     VARCHAR2,
    X_PERSON_IDENTIFIER                     IN     VARCHAR2,
    X_GROUP_TYPE                            IN     VARCHAR2,
    X_COUNTRY                               IN     VARCHAR2,
    X_ADDRESS1                              IN     VARCHAR2,
    X_ADDRESS2                              IN     VARCHAR2,
    X_ADDRESS3                              IN     VARCHAR2,
    X_ADDRESS4                              IN     VARCHAR2,
    X_CITY                                  IN     VARCHAR2,
    X_POSTAL_CODE                           IN     VARCHAR2,
    X_STATE                                 IN     VARCHAR2,
    X_PROVINCE                              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_COUNTY                                IN     VARCHAR2,
    X_SIC_CODE_TYPE                         IN     VARCHAR2,
    X_URL                                   IN     VARCHAR2,
    X_EMAIL_ADDRESS                         IN     VARCHAR2,
    X_ANALYSIS_FY                           IN     VARCHAR2,
    X_FISCAL_YEAREND_MONTH                  IN     VARCHAR2,
    X_EMPLOYEES_TOTAL                       IN     NUMBER,
    X_CURR_FY_POTENTIAL_REVENUE             IN     NUMBER,
    X_NEXT_FY_POTENTIAL_REVENUE             IN     NUMBER,
    X_YEAR_ESTABLISHED                      IN     NUMBER,
    X_GSA_INDICATOR_FLAG                    IN     VARCHAR2,
    X_MISSION_STATEMENT                     IN     VARCHAR2,
    X_ORGANIZATION_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_FIRST_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_LAST_NAME_PHONETIC             IN     VARCHAR2,
    X_LANGUAGE_NAME                         IN     VARCHAR2,
    X_CATEGORY_CODE                         IN     VARCHAR2,
    X_SALUTATION                            IN     VARCHAR2,
    X_KNOWN_AS2                             IN     VARCHAR2,
    X_KNOWN_AS3                             IN     VARCHAR2,
    X_KNOWN_AS4                             IN     VARCHAR2,
    X_KNOWN_AS5                             IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_DUNS_NUMBER_C                         IN     VARCHAR2,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

    l_duns_number                           NUMBER;

    l_duns_number_c                         HZ_PARTIES.duns_number_c%type := X_DUNS_NUMBER_C;
BEGIN

    IF x_duns_number_c IS NOT NULL AND
       x_duns_number_c <> FND_API.G_MISS_CHAR
    THEN
      l_duns_number := do_copy_duns_number(x_duns_number_c);
    END IF;

   IF x_duns_number_c IS NOT NULL AND
      x_duns_number_c <> FND_API.G_MISS_CHAR AND
      LENGTHB(x_duns_number_c)<9
   THEN
      l_duns_number_c:=lpad(x_duns_number_c,9,'0');
   END IF;

    UPDATE HZ_PARTIES SET
        PARTY_ID = DECODE( X_PARTY_ID, NULL, PARTY_ID, FND_API.G_MISS_NUM, NULL, X_PARTY_ID ),
        PARTY_NUMBER = DECODE( X_PARTY_NUMBER, NULL, PARTY_NUMBER, FND_API.G_MISS_CHAR, NULL, X_PARTY_NUMBER ),
        PARTY_NAME = DECODE( X_PARTY_NAME, NULL, PARTY_NAME, FND_API.G_MISS_CHAR, NULL, X_PARTY_NAME ),
        PARTY_TYPE = DECODE( X_PARTY_TYPE, NULL, PARTY_TYPE, FND_API.G_MISS_CHAR, NULL, X_PARTY_TYPE ),
        VALIDATED_FLAG = DECODE( X_VALIDATED_FLAG, NULL, VALIDATED_FLAG, FND_API.G_MISS_CHAR, 'N', X_VALIDATED_FLAG ),
        LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        CREATION_DATE = CREATION_DATE,
        LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID,
        PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        CREATED_BY = CREATED_BY,
        LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        ATTRIBUTE_CATEGORY = DECODE( X_ATTRIBUTE_CATEGORY, NULL, ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE_CATEGORY ),
        ATTRIBUTE1 = DECODE( X_ATTRIBUTE1, NULL, ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE1 ),
        ATTRIBUTE2 = DECODE( X_ATTRIBUTE2, NULL, ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE2 ),
        ATTRIBUTE3 = DECODE( X_ATTRIBUTE3, NULL, ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE3 ),
        ATTRIBUTE4 = DECODE( X_ATTRIBUTE4, NULL, ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE4 ),
        ATTRIBUTE5 = DECODE( X_ATTRIBUTE5, NULL, ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE5 ),
        ATTRIBUTE6 = DECODE( X_ATTRIBUTE6, NULL, ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE6 ),
        ATTRIBUTE7 = DECODE( X_ATTRIBUTE7, NULL, ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE7 ),
        ATTRIBUTE8 = DECODE( X_ATTRIBUTE8, NULL, ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE8 ),
        ATTRIBUTE9 = DECODE( X_ATTRIBUTE9, NULL, ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE9 ),
        ATTRIBUTE10 = DECODE( X_ATTRIBUTE10, NULL, ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE10 ),
        ATTRIBUTE11 = DECODE( X_ATTRIBUTE11, NULL, ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE11 ),
        ATTRIBUTE12 = DECODE( X_ATTRIBUTE12, NULL, ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE12 ),
        ATTRIBUTE13 = DECODE( X_ATTRIBUTE13, NULL, ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE13 ),
        ATTRIBUTE14 = DECODE( X_ATTRIBUTE14, NULL, ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE14 ),
        ATTRIBUTE15 = DECODE( X_ATTRIBUTE15, NULL, ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE15 ),
        ATTRIBUTE16 = DECODE( X_ATTRIBUTE16, NULL, ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE16 ),
        ATTRIBUTE17 = DECODE( X_ATTRIBUTE17, NULL, ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE17 ),
        ATTRIBUTE18 = DECODE( X_ATTRIBUTE18, NULL, ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE18 ),
        ATTRIBUTE19 = DECODE( X_ATTRIBUTE19, NULL, ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE19 ),
        ATTRIBUTE20 = DECODE( X_ATTRIBUTE20, NULL, ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE20 ),
        ATTRIBUTE21 = DECODE( X_ATTRIBUTE21, NULL, ATTRIBUTE21, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE21 ),
        ATTRIBUTE22 = DECODE( X_ATTRIBUTE22, NULL, ATTRIBUTE22, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE22 ),
        ATTRIBUTE23 = DECODE( X_ATTRIBUTE23, NULL, ATTRIBUTE23, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE23 ),
        ATTRIBUTE24 = DECODE( X_ATTRIBUTE24, NULL, ATTRIBUTE24, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE24 ),
        ORIG_SYSTEM_REFERENCE = DECODE( X_ORIG_SYSTEM_REFERENCE, NULL, ORIG_SYSTEM_REFERENCE, FND_API.G_MISS_CHAR, ORIG_SYSTEM_REFERENCE, X_ORIG_SYSTEM_REFERENCE ),
        SIC_CODE = DECODE( X_SIC_CODE, NULL, SIC_CODE, FND_API.G_MISS_CHAR, NULL, X_SIC_CODE ),
        HQ_BRANCH_IND = DECODE( X_HQ_BRANCH_IND, NULL, HQ_BRANCH_IND, FND_API.G_MISS_CHAR, NULL, X_HQ_BRANCH_IND ),
        CUSTOMER_KEY = DECODE( X_CUSTOMER_KEY, NULL, CUSTOMER_KEY, FND_API.G_MISS_CHAR, NULL, X_CUSTOMER_KEY ),
        TAX_REFERENCE = DECODE( X_TAX_REFERENCE, NULL, TAX_REFERENCE, FND_API.G_MISS_CHAR, NULL, X_TAX_REFERENCE ),
        JGZZ_FISCAL_CODE = DECODE( X_JGZZ_FISCAL_CODE, NULL, JGZZ_FISCAL_CODE, FND_API.G_MISS_CHAR, NULL, X_JGZZ_FISCAL_CODE ),
        PERSON_PRE_NAME_ADJUNCT = DECODE( X_PERSON_PRE_NAME_ADJUNCT, NULL, PERSON_PRE_NAME_ADJUNCT, FND_API.G_MISS_CHAR, NULL, X_PERSON_PRE_NAME_ADJUNCT ),
        PERSON_FIRST_NAME = DECODE( X_PERSON_FIRST_NAME, NULL, PERSON_FIRST_NAME, FND_API.G_MISS_CHAR, NULL, X_PERSON_FIRST_NAME ),
        PERSON_MIDDLE_NAME = DECODE( X_PERSON_MIDDLE_NAME, NULL, PERSON_MIDDLE_NAME, FND_API.G_MISS_CHAR, NULL, X_PERSON_MIDDLE_NAME ),
        PERSON_LAST_NAME = DECODE( X_PERSON_LAST_NAME, NULL, PERSON_LAST_NAME, FND_API.G_MISS_CHAR, NULL, X_PERSON_LAST_NAME ),
        PERSON_NAME_SUFFIX = DECODE( X_PERSON_NAME_SUFFIX, NULL, PERSON_NAME_SUFFIX, FND_API.G_MISS_CHAR, NULL, X_PERSON_NAME_SUFFIX ),
        PERSON_TITLE = DECODE( X_PERSON_TITLE, NULL, PERSON_TITLE, FND_API.G_MISS_CHAR, NULL, X_PERSON_TITLE ),
        PERSON_ACADEMIC_TITLE = DECODE( X_PERSON_ACADEMIC_TITLE, NULL, PERSON_ACADEMIC_TITLE, FND_API.G_MISS_CHAR, NULL, X_PERSON_ACADEMIC_TITLE ),
        PERSON_PREVIOUS_LAST_NAME = DECODE( X_PERSON_PREVIOUS_LAST_NAME, NULL, PERSON_PREVIOUS_LAST_NAME, FND_API.G_MISS_CHAR, NULL, X_PERSON_PREVIOUS_LAST_NAME ),
        KNOWN_AS = DECODE( X_KNOWN_AS, NULL, KNOWN_AS, FND_API.G_MISS_CHAR, NULL, X_KNOWN_AS ),
        PERSON_IDEN_TYPE = DECODE( X_PERSON_IDEN_TYPE, NULL, PERSON_IDEN_TYPE, FND_API.G_MISS_CHAR, NULL, X_PERSON_IDEN_TYPE ),
        PERSON_IDENTIFIER = DECODE( X_PERSON_IDENTIFIER, NULL, PERSON_IDENTIFIER, FND_API.G_MISS_CHAR, NULL, X_PERSON_IDENTIFIER ),
        GROUP_TYPE = DECODE( X_GROUP_TYPE, NULL, GROUP_TYPE, FND_API.G_MISS_CHAR, NULL, X_GROUP_TYPE ),
        COUNTRY = DECODE( X_COUNTRY, NULL, COUNTRY, FND_API.G_MISS_CHAR, NULL, X_COUNTRY ),
        ADDRESS1 = DECODE( X_ADDRESS1, NULL, ADDRESS1, FND_API.G_MISS_CHAR, NULL, X_ADDRESS1 ),
        ADDRESS2 = DECODE( X_ADDRESS2, NULL, ADDRESS2, FND_API.G_MISS_CHAR, NULL, X_ADDRESS2 ),
        ADDRESS3 = DECODE( X_ADDRESS3, NULL, ADDRESS3, FND_API.G_MISS_CHAR, NULL, X_ADDRESS3 ),
        ADDRESS4 = DECODE( X_ADDRESS4, NULL, ADDRESS4, FND_API.G_MISS_CHAR, NULL, X_ADDRESS4 ),
        CITY = DECODE( X_CITY, NULL, CITY, FND_API.G_MISS_CHAR, NULL, X_CITY ),
        POSTAL_CODE = DECODE( X_POSTAL_CODE, NULL, POSTAL_CODE, FND_API.G_MISS_CHAR, NULL, X_POSTAL_CODE ),
        STATE = DECODE( X_STATE, NULL, STATE, FND_API.G_MISS_CHAR, NULL, X_STATE ),
        PROVINCE = DECODE( X_PROVINCE, NULL, PROVINCE, FND_API.G_MISS_CHAR, NULL, X_PROVINCE ),
        STATUS = DECODE( X_STATUS, NULL, STATUS, FND_API.G_MISS_CHAR, 'A', X_STATUS ),
        COUNTY = DECODE( X_COUNTY, NULL, COUNTY, FND_API.G_MISS_CHAR, NULL, X_COUNTY ),
        SIC_CODE_TYPE = DECODE( X_SIC_CODE_TYPE, NULL, SIC_CODE_TYPE, FND_API.G_MISS_CHAR, NULL, X_SIC_CODE_TYPE ),
        URL = DECODE( X_URL, NULL, URL, FND_API.G_MISS_CHAR, NULL, X_URL ),
        --Bug 4355133
	EMAIL_ADDRESS = SUBSTRB(DECODE( X_EMAIL_ADDRESS, NULL, EMAIL_ADDRESS,
	FND_API.G_MISS_CHAR, NULL, X_EMAIL_ADDRESS ),1,320),
        ANALYSIS_FY = DECODE( X_ANALYSIS_FY, NULL, ANALYSIS_FY, FND_API.G_MISS_CHAR, NULL, X_ANALYSIS_FY ),
        FISCAL_YEAREND_MONTH = DECODE( X_FISCAL_YEAREND_MONTH, NULL, FISCAL_YEAREND_MONTH, FND_API.G_MISS_CHAR, NULL, X_FISCAL_YEAREND_MONTH ),
        EMPLOYEES_TOTAL = DECODE( X_EMPLOYEES_TOTAL, NULL, EMPLOYEES_TOTAL, FND_API.G_MISS_NUM, NULL, X_EMPLOYEES_TOTAL ),
        CURR_FY_POTENTIAL_REVENUE = DECODE( X_CURR_FY_POTENTIAL_REVENUE, NULL, CURR_FY_POTENTIAL_REVENUE, FND_API.G_MISS_NUM, NULL, X_CURR_FY_POTENTIAL_REVENUE ),
        NEXT_FY_POTENTIAL_REVENUE = DECODE( X_NEXT_FY_POTENTIAL_REVENUE, NULL, NEXT_FY_POTENTIAL_REVENUE, FND_API.G_MISS_NUM, NULL, X_NEXT_FY_POTENTIAL_REVENUE ),
        YEAR_ESTABLISHED = DECODE( X_YEAR_ESTABLISHED, NULL, YEAR_ESTABLISHED, FND_API.G_MISS_NUM, NULL, X_YEAR_ESTABLISHED ),
        GSA_INDICATOR_FLAG = DECODE( X_GSA_INDICATOR_FLAG, NULL, GSA_INDICATOR_FLAG, FND_API.G_MISS_CHAR, NULL, X_GSA_INDICATOR_FLAG ),
        MISSION_STATEMENT = DECODE( X_MISSION_STATEMENT, NULL, MISSION_STATEMENT, FND_API.G_MISS_CHAR, NULL, X_MISSION_STATEMENT ),
        ORGANIZATION_NAME_PHONETIC = DECODE( X_ORGANIZATION_NAME_PHONETIC, NULL, ORGANIZATION_NAME_PHONETIC, FND_API.G_MISS_CHAR, NULL, X_ORGANIZATION_NAME_PHONETIC ),
        PERSON_FIRST_NAME_PHONETIC = DECODE( X_PERSON_FIRST_NAME_PHONETIC, NULL, PERSON_FIRST_NAME_PHONETIC, FND_API.G_MISS_CHAR, NULL, X_PERSON_FIRST_NAME_PHONETIC ),
        PERSON_LAST_NAME_PHONETIC = DECODE( X_PERSON_LAST_NAME_PHONETIC, NULL, PERSON_LAST_NAME_PHONETIC, FND_API.G_MISS_CHAR, NULL, X_PERSON_LAST_NAME_PHONETIC ),
        LANGUAGE_NAME = DECODE( X_LANGUAGE_NAME, NULL, LANGUAGE_NAME, FND_API.G_MISS_CHAR, NULL, X_LANGUAGE_NAME ),
        CATEGORY_CODE = DECODE( X_CATEGORY_CODE, NULL, CATEGORY_CODE, FND_API.G_MISS_CHAR, NULL, X_CATEGORY_CODE ),
        SALUTATION = DECODE( X_SALUTATION, NULL, SALUTATION, FND_API.G_MISS_CHAR, NULL, X_SALUTATION ),
        KNOWN_AS2 = DECODE( X_KNOWN_AS2, NULL, KNOWN_AS2, FND_API.G_MISS_CHAR, NULL, X_KNOWN_AS2 ),
        KNOWN_AS3 = DECODE( X_KNOWN_AS3, NULL, KNOWN_AS3, FND_API.G_MISS_CHAR, NULL, X_KNOWN_AS3 ),
        KNOWN_AS4 = DECODE( X_KNOWN_AS4, NULL, KNOWN_AS4, FND_API.G_MISS_CHAR, NULL, X_KNOWN_AS4 ),
        KNOWN_AS5 = DECODE( X_KNOWN_AS5, NULL, KNOWN_AS5, FND_API.G_MISS_CHAR, NULL, X_KNOWN_AS5 ),
        OBJECT_VERSION_NUMBER = DECODE( X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
        DUNS_NUMBER_C = DECODE( X_DUNS_NUMBER_C, NULL, DUNS_NUMBER_C, FND_API.G_MISS_CHAR, NULL,/*Bug 3435702*/ UPPER(L_DUNS_NUMBER_C)),
        DUNS_NUMBER = DECODE( X_DUNS_NUMBER_C, NULL, DUNS_NUMBER,/* Bug 3435702 FND_API.G_MISS_CHAR, NULL,*/ l_duns_number ),
        CREATED_BY_MODULE = DECODE( X_CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
        APPLICATION_ID = DECODE( X_APPLICATION_ID, NULL, APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID )
    WHERE ROWID = X_RowId;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_PARTY_ID                              IN     NUMBER,
    X_PARTY_NUMBER                          IN     VARCHAR2,
    X_PARTY_NAME                            IN     VARCHAR2,
    X_PARTY_TYPE                            IN     VARCHAR2,
    X_VALIDATED_FLAG                        IN     VARCHAR2,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_REQUEST_ID                            IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_CREATED_BY                            IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_PROGRAM_ID                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_ATTRIBUTE_CATEGORY                    IN     VARCHAR2,
    X_ATTRIBUTE1                            IN     VARCHAR2,
    X_ATTRIBUTE2                            IN     VARCHAR2,
    X_ATTRIBUTE3                            IN     VARCHAR2,
    X_ATTRIBUTE4                            IN     VARCHAR2,
    X_ATTRIBUTE5                            IN     VARCHAR2,
    X_ATTRIBUTE6                            IN     VARCHAR2,
    X_ATTRIBUTE7                            IN     VARCHAR2,
    X_ATTRIBUTE8                            IN     VARCHAR2,
    X_ATTRIBUTE9                            IN     VARCHAR2,
    X_ATTRIBUTE10                           IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_ATTRIBUTE16                           IN     VARCHAR2,
    X_ATTRIBUTE17                           IN     VARCHAR2,
    X_ATTRIBUTE18                           IN     VARCHAR2,
    X_ATTRIBUTE19                           IN     VARCHAR2,
    X_ATTRIBUTE20                           IN     VARCHAR2,
    X_ATTRIBUTE21                           IN     VARCHAR2,
    X_ATTRIBUTE22                           IN     VARCHAR2,
    X_ATTRIBUTE23                           IN     VARCHAR2,
    X_ATTRIBUTE24                           IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_SIC_CODE                              IN     VARCHAR2,
    X_HQ_BRANCH_IND                         IN     VARCHAR2,
    X_CUSTOMER_KEY                          IN     VARCHAR2,
    X_TAX_REFERENCE                         IN     VARCHAR2,
    X_JGZZ_FISCAL_CODE                      IN     VARCHAR2,
    X_PERSON_PRE_NAME_ADJUNCT               IN     VARCHAR2,
    X_PERSON_FIRST_NAME                     IN     VARCHAR2,
    X_PERSON_MIDDLE_NAME                    IN     VARCHAR2,
    X_PERSON_LAST_NAME                      IN     VARCHAR2,
    X_PERSON_NAME_SUFFIX                    IN     VARCHAR2,
    X_PERSON_TITLE                          IN     VARCHAR2,
    X_PERSON_ACADEMIC_TITLE                 IN     VARCHAR2,
    X_PERSON_PREVIOUS_LAST_NAME             IN     VARCHAR2,
    X_KNOWN_AS                              IN     VARCHAR2,
    X_PERSON_IDEN_TYPE                      IN     VARCHAR2,
    X_PERSON_IDENTIFIER                     IN     VARCHAR2,
    X_GROUP_TYPE                            IN     VARCHAR2,
    X_COUNTRY                               IN     VARCHAR2,
    X_ADDRESS1                              IN     VARCHAR2,
    X_ADDRESS2                              IN     VARCHAR2,
    X_ADDRESS3                              IN     VARCHAR2,
    X_ADDRESS4                              IN     VARCHAR2,
    X_CITY                                  IN     VARCHAR2,
    X_POSTAL_CODE                           IN     VARCHAR2,
    X_STATE                                 IN     VARCHAR2,
    X_PROVINCE                              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_COUNTY                                IN     VARCHAR2,
    X_SIC_CODE_TYPE                         IN     VARCHAR2,
    X_URL                                   IN     VARCHAR2,
    X_EMAIL_ADDRESS                         IN     VARCHAR2,
    X_ANALYSIS_FY                           IN     VARCHAR2,
    X_FISCAL_YEAREND_MONTH                  IN     VARCHAR2,
    X_EMPLOYEES_TOTAL                       IN     NUMBER,
    X_CURR_FY_POTENTIAL_REVENUE             IN     NUMBER,
    X_NEXT_FY_POTENTIAL_REVENUE             IN     NUMBER,
    X_YEAR_ESTABLISHED                      IN     NUMBER,
    X_GSA_INDICATOR_FLAG                    IN     VARCHAR2,
    X_MISSION_STATEMENT                     IN     VARCHAR2,
    X_ORGANIZATION_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_FIRST_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_LAST_NAME_PHONETIC             IN     VARCHAR2,
    X_LANGUAGE_NAME                         IN     VARCHAR2,
    X_CATEGORY_CODE                         IN     VARCHAR2,
    X_SALUTATION                            IN     VARCHAR2,
    X_KNOWN_AS2                             IN     VARCHAR2,
    X_KNOWN_AS3                             IN     VARCHAR2,
    X_KNOWN_AS4                             IN     VARCHAR2,
    X_KNOWN_AS5                             IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_DUNS_NUMBER_C                         IN     VARCHAR2,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

    CURSOR C IS
        SELECT * FROM HZ_PARTIES
        WHERE  ROWID = x_Rowid
        FOR UPDATE NOWAIT;
    Recinfo C%ROWTYPE;

BEGIN

    OPEN C;
    FETCH C INTO Recinfo;
    IF ( C%NOTFOUND ) THEN
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;

    IF (
        ( ( Recinfo.PARTY_ID = X_PARTY_ID )
        OR ( ( Recinfo.PARTY_ID IS NULL )
            AND (  X_PARTY_ID IS NULL ) ) )
    AND ( ( Recinfo.PARTY_NUMBER = X_PARTY_NUMBER )
        OR ( ( Recinfo.PARTY_NUMBER IS NULL )
            AND (  X_PARTY_NUMBER IS NULL ) ) )
    AND ( ( Recinfo.PARTY_NAME = X_PARTY_NAME )
        OR ( ( Recinfo.PARTY_NAME IS NULL )
            AND (  X_PARTY_NAME IS NULL ) ) )
    AND ( ( Recinfo.PARTY_TYPE = X_PARTY_TYPE )
        OR ( ( Recinfo.PARTY_TYPE IS NULL )
            AND (  X_PARTY_TYPE IS NULL ) ) )
    AND ( ( Recinfo.VALIDATED_FLAG = X_VALIDATED_FLAG )
        OR ( ( Recinfo.VALIDATED_FLAG IS NULL )
            AND (  X_VALIDATED_FLAG IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATED_BY = X_LAST_UPDATED_BY )
        OR ( ( Recinfo.LAST_UPDATED_BY IS NULL )
            AND (  X_LAST_UPDATED_BY IS NULL ) ) )
    AND ( ( Recinfo.CREATION_DATE = X_CREATION_DATE )
        OR ( ( Recinfo.CREATION_DATE IS NULL )
            AND (  X_CREATION_DATE IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN )
        OR ( ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
            AND (  X_LAST_UPDATE_LOGIN IS NULL ) ) )
    AND ( ( Recinfo.REQUEST_ID = X_REQUEST_ID )
        OR ( ( Recinfo.REQUEST_ID IS NULL )
            AND (  X_REQUEST_ID IS NULL ) ) )
    AND ( ( Recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID )
        OR ( ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
            AND (  X_PROGRAM_APPLICATION_ID IS NULL ) ) )
    AND ( ( Recinfo.CREATED_BY = X_CREATED_BY )
        OR ( ( Recinfo.CREATED_BY IS NULL )
            AND (  X_CREATED_BY IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE )
        OR ( ( Recinfo.LAST_UPDATE_DATE IS NULL )
            AND (  X_LAST_UPDATE_DATE IS NULL ) ) )
    AND ( ( Recinfo.PROGRAM_ID = X_PROGRAM_ID )
        OR ( ( Recinfo.PROGRAM_ID IS NULL )
            AND (  X_PROGRAM_ID IS NULL ) ) )
    AND ( ( Recinfo.PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE )
        OR ( ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
            AND (  X_PROGRAM_UPDATE_DATE IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY )
        OR ( ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
            AND (  X_ATTRIBUTE_CATEGORY IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE1 = X_ATTRIBUTE1 )
        OR ( ( Recinfo.ATTRIBUTE1 IS NULL )
            AND (  X_ATTRIBUTE1 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE2 = X_ATTRIBUTE2 )
        OR ( ( Recinfo.ATTRIBUTE2 IS NULL )
            AND (  X_ATTRIBUTE2 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE3 = X_ATTRIBUTE3 )
        OR ( ( Recinfo.ATTRIBUTE3 IS NULL )
            AND (  X_ATTRIBUTE3 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE4 = X_ATTRIBUTE4 )
        OR ( ( Recinfo.ATTRIBUTE4 IS NULL )
            AND (  X_ATTRIBUTE4 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE5 = X_ATTRIBUTE5 )
        OR ( ( Recinfo.ATTRIBUTE5 IS NULL )
            AND (  X_ATTRIBUTE5 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE6 = X_ATTRIBUTE6 )
        OR ( ( Recinfo.ATTRIBUTE6 IS NULL )
            AND (  X_ATTRIBUTE6 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE7 = X_ATTRIBUTE7 )
        OR ( ( Recinfo.ATTRIBUTE7 IS NULL )
            AND (  X_ATTRIBUTE7 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE8 = X_ATTRIBUTE8 )
        OR ( ( Recinfo.ATTRIBUTE8 IS NULL )
            AND (  X_ATTRIBUTE8 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE9 = X_ATTRIBUTE9 )
        OR ( ( Recinfo.ATTRIBUTE9 IS NULL )
            AND (  X_ATTRIBUTE9 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE10 = X_ATTRIBUTE10 )
        OR ( ( Recinfo.ATTRIBUTE10 IS NULL )
            AND (  X_ATTRIBUTE10 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE11 = X_ATTRIBUTE11 )
        OR ( ( Recinfo.ATTRIBUTE11 IS NULL )
            AND (  X_ATTRIBUTE11 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE12 = X_ATTRIBUTE12 )
        OR ( ( Recinfo.ATTRIBUTE12 IS NULL )
            AND (  X_ATTRIBUTE12 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE13 = X_ATTRIBUTE13 )
        OR ( ( Recinfo.ATTRIBUTE13 IS NULL )
            AND (  X_ATTRIBUTE13 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE14 = X_ATTRIBUTE14 )
        OR ( ( Recinfo.ATTRIBUTE14 IS NULL )
            AND (  X_ATTRIBUTE14 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE15 = X_ATTRIBUTE15 )
        OR ( ( Recinfo.ATTRIBUTE15 IS NULL )
            AND (  X_ATTRIBUTE15 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE16 = X_ATTRIBUTE16 )
        OR ( ( Recinfo.ATTRIBUTE16 IS NULL )
            AND (  X_ATTRIBUTE16 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE17 = X_ATTRIBUTE17 )
        OR ( ( Recinfo.ATTRIBUTE17 IS NULL )
            AND (  X_ATTRIBUTE17 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE18 = X_ATTRIBUTE18 )
        OR ( ( Recinfo.ATTRIBUTE18 IS NULL )
            AND (  X_ATTRIBUTE18 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE19 = X_ATTRIBUTE19 )
        OR ( ( Recinfo.ATTRIBUTE19 IS NULL )
            AND (  X_ATTRIBUTE19 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE20 = X_ATTRIBUTE20 )
        OR ( ( Recinfo.ATTRIBUTE20 IS NULL )
            AND (  X_ATTRIBUTE20 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE21 = X_ATTRIBUTE21 )
        OR ( ( Recinfo.ATTRIBUTE21 IS NULL )
            AND (  X_ATTRIBUTE21 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE22 = X_ATTRIBUTE22 )
        OR ( ( Recinfo.ATTRIBUTE22 IS NULL )
            AND (  X_ATTRIBUTE22 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE23 = X_ATTRIBUTE23 )
        OR ( ( Recinfo.ATTRIBUTE23 IS NULL )
            AND (  X_ATTRIBUTE23 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE24 = X_ATTRIBUTE24 )
        OR ( ( Recinfo.ATTRIBUTE24 IS NULL )
            AND (  X_ATTRIBUTE24 IS NULL ) ) )
    AND ( ( Recinfo.ORIG_SYSTEM_REFERENCE = X_ORIG_SYSTEM_REFERENCE )
        OR ( ( Recinfo.ORIG_SYSTEM_REFERENCE IS NULL )
            AND (  X_ORIG_SYSTEM_REFERENCE IS NULL ) ) )
    AND ( ( Recinfo.SIC_CODE = X_SIC_CODE )
        OR ( ( Recinfo.SIC_CODE IS NULL )
            AND (  X_SIC_CODE IS NULL ) ) )
    AND ( ( Recinfo.HQ_BRANCH_IND = X_HQ_BRANCH_IND )
        OR ( ( Recinfo.HQ_BRANCH_IND IS NULL )
            AND (  X_HQ_BRANCH_IND IS NULL ) ) )
    AND ( ( Recinfo.CUSTOMER_KEY = X_CUSTOMER_KEY )
        OR ( ( Recinfo.CUSTOMER_KEY IS NULL )
            AND (  X_CUSTOMER_KEY IS NULL ) ) )
    AND ( ( Recinfo.TAX_REFERENCE = X_TAX_REFERENCE )
        OR ( ( Recinfo.TAX_REFERENCE IS NULL )
            AND (  X_TAX_REFERENCE IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_FISCAL_CODE = X_JGZZ_FISCAL_CODE )
        OR ( ( Recinfo.JGZZ_FISCAL_CODE IS NULL )
            AND (  X_JGZZ_FISCAL_CODE IS NULL ) ) )
    AND ( ( Recinfo.PERSON_PRE_NAME_ADJUNCT = X_PERSON_PRE_NAME_ADJUNCT )
        OR ( ( Recinfo.PERSON_PRE_NAME_ADJUNCT IS NULL )
            AND (  X_PERSON_PRE_NAME_ADJUNCT IS NULL ) ) )
    AND ( ( Recinfo.PERSON_FIRST_NAME = X_PERSON_FIRST_NAME )
        OR ( ( Recinfo.PERSON_FIRST_NAME IS NULL )
            AND (  X_PERSON_FIRST_NAME IS NULL ) ) )
    AND ( ( Recinfo.PERSON_MIDDLE_NAME = X_PERSON_MIDDLE_NAME )
        OR ( ( Recinfo.PERSON_MIDDLE_NAME IS NULL )
            AND (  X_PERSON_MIDDLE_NAME IS NULL ) ) )
    AND ( ( Recinfo.PERSON_LAST_NAME = X_PERSON_LAST_NAME )
        OR ( ( Recinfo.PERSON_LAST_NAME IS NULL )
            AND (  X_PERSON_LAST_NAME IS NULL ) ) )
    AND ( ( Recinfo.PERSON_NAME_SUFFIX = X_PERSON_NAME_SUFFIX )
        OR ( ( Recinfo.PERSON_NAME_SUFFIX IS NULL )
            AND (  X_PERSON_NAME_SUFFIX IS NULL ) ) )
    AND ( ( Recinfo.PERSON_TITLE = X_PERSON_TITLE )
        OR ( ( Recinfo.PERSON_TITLE IS NULL )
            AND (  X_PERSON_TITLE IS NULL ) ) )
    AND ( ( Recinfo.PERSON_ACADEMIC_TITLE = X_PERSON_ACADEMIC_TITLE )
        OR ( ( Recinfo.PERSON_ACADEMIC_TITLE IS NULL )
            AND (  X_PERSON_ACADEMIC_TITLE IS NULL ) ) )
    AND ( ( Recinfo.PERSON_PREVIOUS_LAST_NAME = X_PERSON_PREVIOUS_LAST_NAME )
        OR ( ( Recinfo.PERSON_PREVIOUS_LAST_NAME IS NULL )
            AND (  X_PERSON_PREVIOUS_LAST_NAME IS NULL ) ) )
    AND ( ( Recinfo.KNOWN_AS = X_KNOWN_AS )
        OR ( ( Recinfo.KNOWN_AS IS NULL )
            AND (  X_KNOWN_AS IS NULL ) ) )
    AND ( ( Recinfo.PERSON_IDEN_TYPE = X_PERSON_IDEN_TYPE )
        OR ( ( Recinfo.PERSON_IDEN_TYPE IS NULL )
            AND (  X_PERSON_IDEN_TYPE IS NULL ) ) )
    AND ( ( Recinfo.PERSON_IDENTIFIER = X_PERSON_IDENTIFIER )
        OR ( ( Recinfo.PERSON_IDENTIFIER IS NULL )
            AND (  X_PERSON_IDENTIFIER IS NULL ) ) )
    AND ( ( Recinfo.GROUP_TYPE = X_GROUP_TYPE )
        OR ( ( Recinfo.GROUP_TYPE IS NULL )
            AND (  X_GROUP_TYPE IS NULL ) ) )
    AND ( ( Recinfo.COUNTRY = X_COUNTRY )
        OR ( ( Recinfo.COUNTRY IS NULL )
            AND (  X_COUNTRY IS NULL ) ) )
    AND ( ( Recinfo.ADDRESS1 = X_ADDRESS1 )
        OR ( ( Recinfo.ADDRESS1 IS NULL )
            AND (  X_ADDRESS1 IS NULL ) ) )
    AND ( ( Recinfo.ADDRESS2 = X_ADDRESS2 )
        OR ( ( Recinfo.ADDRESS2 IS NULL )
            AND (  X_ADDRESS2 IS NULL ) ) )
    AND ( ( Recinfo.ADDRESS3 = X_ADDRESS3 )
        OR ( ( Recinfo.ADDRESS3 IS NULL )
            AND (  X_ADDRESS3 IS NULL ) ) )
    AND ( ( Recinfo.ADDRESS4 = X_ADDRESS4 )
        OR ( ( Recinfo.ADDRESS4 IS NULL )
            AND (  X_ADDRESS4 IS NULL ) ) )
    AND ( ( Recinfo.CITY = X_CITY )
        OR ( ( Recinfo.CITY IS NULL )
            AND (  X_CITY IS NULL ) ) )
    AND ( ( Recinfo.POSTAL_CODE = X_POSTAL_CODE )
        OR ( ( Recinfo.POSTAL_CODE IS NULL )
            AND (  X_POSTAL_CODE IS NULL ) ) )
    AND ( ( Recinfo.STATE = X_STATE )
        OR ( ( Recinfo.STATE IS NULL )
            AND (  X_STATE IS NULL ) ) )
    AND ( ( Recinfo.PROVINCE = X_PROVINCE )
        OR ( ( Recinfo.PROVINCE IS NULL )
            AND (  X_PROVINCE IS NULL ) ) )
    AND ( ( Recinfo.STATUS = X_STATUS )
        OR ( ( Recinfo.STATUS IS NULL )
            AND (  X_STATUS IS NULL ) ) )
    AND ( ( Recinfo.COUNTY = X_COUNTY )
        OR ( ( Recinfo.COUNTY IS NULL )
            AND (  X_COUNTY IS NULL ) ) )
    AND ( ( Recinfo.SIC_CODE_TYPE = X_SIC_CODE_TYPE )
        OR ( ( Recinfo.SIC_CODE_TYPE IS NULL )
            AND (  X_SIC_CODE_TYPE IS NULL ) ) )
    AND ( ( Recinfo.URL = X_URL )
        OR ( ( Recinfo.URL IS NULL )
            AND (  X_URL IS NULL ) ) )
    AND ( ( Recinfo.EMAIL_ADDRESS = X_EMAIL_ADDRESS )
        OR ( ( Recinfo.EMAIL_ADDRESS IS NULL )
            AND (  X_EMAIL_ADDRESS IS NULL ) ) )
    AND ( ( Recinfo.ANALYSIS_FY = X_ANALYSIS_FY )
        OR ( ( Recinfo.ANALYSIS_FY IS NULL )
            AND (  X_ANALYSIS_FY IS NULL ) ) )
    AND ( ( Recinfo.FISCAL_YEAREND_MONTH = X_FISCAL_YEAREND_MONTH )
        OR ( ( Recinfo.FISCAL_YEAREND_MONTH IS NULL )
            AND (  X_FISCAL_YEAREND_MONTH IS NULL ) ) )
    AND ( ( Recinfo.EMPLOYEES_TOTAL = X_EMPLOYEES_TOTAL )
        OR ( ( Recinfo.EMPLOYEES_TOTAL IS NULL )
            AND (  X_EMPLOYEES_TOTAL IS NULL ) ) )
    AND ( ( Recinfo.CURR_FY_POTENTIAL_REVENUE = X_CURR_FY_POTENTIAL_REVENUE )
        OR ( ( Recinfo.CURR_FY_POTENTIAL_REVENUE IS NULL )
            AND (  X_CURR_FY_POTENTIAL_REVENUE IS NULL ) ) )
    AND ( ( Recinfo.NEXT_FY_POTENTIAL_REVENUE = X_NEXT_FY_POTENTIAL_REVENUE )
        OR ( ( Recinfo.NEXT_FY_POTENTIAL_REVENUE IS NULL )
            AND (  X_NEXT_FY_POTENTIAL_REVENUE IS NULL ) ) )
    AND ( ( Recinfo.YEAR_ESTABLISHED = X_YEAR_ESTABLISHED )
        OR ( ( Recinfo.YEAR_ESTABLISHED IS NULL )
            AND (  X_YEAR_ESTABLISHED IS NULL ) ) )
    AND ( ( Recinfo.GSA_INDICATOR_FLAG = X_GSA_INDICATOR_FLAG )
        OR ( ( Recinfo.GSA_INDICATOR_FLAG IS NULL )
            AND (  X_GSA_INDICATOR_FLAG IS NULL ) ) )
    AND ( ( Recinfo.MISSION_STATEMENT = X_MISSION_STATEMENT )
        OR ( ( Recinfo.MISSION_STATEMENT IS NULL )
            AND (  X_MISSION_STATEMENT IS NULL ) ) )
    AND ( ( Recinfo.ORGANIZATION_NAME_PHONETIC = X_ORGANIZATION_NAME_PHONETIC )
        OR ( ( Recinfo.ORGANIZATION_NAME_PHONETIC IS NULL )
            AND (  X_ORGANIZATION_NAME_PHONETIC IS NULL ) ) )
    AND ( ( Recinfo.PERSON_FIRST_NAME_PHONETIC = X_PERSON_FIRST_NAME_PHONETIC )
        OR ( ( Recinfo.PERSON_FIRST_NAME_PHONETIC IS NULL )
            AND (  X_PERSON_FIRST_NAME_PHONETIC IS NULL ) ) )
    AND ( ( Recinfo.PERSON_LAST_NAME_PHONETIC = X_PERSON_LAST_NAME_PHONETIC )
        OR ( ( Recinfo.PERSON_LAST_NAME_PHONETIC IS NULL )
            AND (  X_PERSON_LAST_NAME_PHONETIC IS NULL ) ) )
    AND ( ( Recinfo.LANGUAGE_NAME = X_LANGUAGE_NAME )
        OR ( ( Recinfo.LANGUAGE_NAME IS NULL )
            AND (  X_LANGUAGE_NAME IS NULL ) ) )
    AND ( ( Recinfo.CATEGORY_CODE = X_CATEGORY_CODE )
        OR ( ( Recinfo.CATEGORY_CODE IS NULL )
            AND (  X_CATEGORY_CODE IS NULL ) ) )
    AND ( ( Recinfo.SALUTATION = X_SALUTATION )
        OR ( ( Recinfo.SALUTATION IS NULL )
            AND (  X_SALUTATION IS NULL ) ) )
    AND ( ( Recinfo.KNOWN_AS2 = X_KNOWN_AS2 )
        OR ( ( Recinfo.KNOWN_AS2 IS NULL )
            AND (  X_KNOWN_AS2 IS NULL ) ) )
    AND ( ( Recinfo.KNOWN_AS3 = X_KNOWN_AS3 )
        OR ( ( Recinfo.KNOWN_AS3 IS NULL )
            AND (  X_KNOWN_AS3 IS NULL ) ) )
    AND ( ( Recinfo.KNOWN_AS4 = X_KNOWN_AS4 )
        OR ( ( Recinfo.KNOWN_AS4 IS NULL )
            AND (  X_KNOWN_AS4 IS NULL ) ) )
    AND ( ( Recinfo.KNOWN_AS5 = X_KNOWN_AS5 )
        OR ( ( Recinfo.KNOWN_AS5 IS NULL )
            AND (  X_KNOWN_AS5 IS NULL ) ) )
    AND ( ( Recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER )
        OR ( ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
            AND (  X_OBJECT_VERSION_NUMBER IS NULL ) ) )
    AND ( ( Recinfo.DUNS_NUMBER_C = X_DUNS_NUMBER_C )
        OR ( ( Recinfo.DUNS_NUMBER_C IS NULL )
            AND (  X_DUNS_NUMBER_C IS NULL ) ) )
    AND ( ( Recinfo.CREATED_BY_MODULE = X_CREATED_BY_MODULE )
        OR ( ( Recinfo.CREATED_BY_MODULE IS NULL )
            AND (  X_CREATED_BY_MODULE IS NULL ) ) )
    AND ( ( Recinfo.APPLICATION_ID = X_APPLICATION_ID )
        OR ( ( Recinfo.APPLICATION_ID IS NULL )
            AND (  X_APPLICATION_ID IS NULL ) ) )
    ) THEN
        RETURN;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    X_PARTY_ID                              IN OUT NOCOPY NUMBER,
    X_PARTY_NUMBER                          OUT NOCOPY    VARCHAR2,
    X_PARTY_NAME                            OUT NOCOPY    VARCHAR2,
    X_PARTY_TYPE                            OUT NOCOPY    VARCHAR2,
    X_VALIDATED_FLAG                        OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE1                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE2                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE3                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE4                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE5                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE6                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE7                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE8                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE9                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE10                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE11                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE12                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE13                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE14                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE15                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE16                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE17                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE18                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE19                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE20                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE21                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE22                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE23                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE24                           OUT NOCOPY    VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 OUT NOCOPY    VARCHAR2,
    X_SIC_CODE                              OUT NOCOPY    VARCHAR2,
    X_HQ_BRANCH_IND                         OUT NOCOPY    VARCHAR2,
    X_CUSTOMER_KEY                          OUT NOCOPY    VARCHAR2,
    X_TAX_REFERENCE                         OUT NOCOPY    VARCHAR2,
    X_JGZZ_FISCAL_CODE                      OUT NOCOPY    VARCHAR2,
    X_PERSON_PRE_NAME_ADJUNCT               OUT NOCOPY    VARCHAR2,
    X_PERSON_FIRST_NAME                     OUT NOCOPY    VARCHAR2,
    X_PERSON_MIDDLE_NAME                    OUT NOCOPY    VARCHAR2,
    X_PERSON_LAST_NAME                      OUT NOCOPY    VARCHAR2,
    X_PERSON_NAME_SUFFIX                    OUT NOCOPY    VARCHAR2,
    X_PERSON_TITLE                          OUT NOCOPY    VARCHAR2,
    X_PERSON_ACADEMIC_TITLE                 OUT NOCOPY    VARCHAR2,
    X_PERSON_PREVIOUS_LAST_NAME             OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS                              OUT NOCOPY    VARCHAR2,
    X_PERSON_IDEN_TYPE                      OUT NOCOPY    VARCHAR2,
    X_PERSON_IDENTIFIER                     OUT NOCOPY    VARCHAR2,
    X_GROUP_TYPE                            OUT NOCOPY    VARCHAR2,
    X_COUNTRY                               OUT NOCOPY    VARCHAR2,
    X_ADDRESS1                              OUT NOCOPY    VARCHAR2,
    X_ADDRESS2                              OUT NOCOPY    VARCHAR2,
    X_ADDRESS3                              OUT NOCOPY    VARCHAR2,
    X_ADDRESS4                              OUT NOCOPY    VARCHAR2,
    X_CITY                                  OUT NOCOPY    VARCHAR2,
    X_POSTAL_CODE                           OUT NOCOPY    VARCHAR2,
    X_STATE                                 OUT NOCOPY    VARCHAR2,
    X_PROVINCE                              OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_COUNTY                                OUT NOCOPY    VARCHAR2,
    X_SIC_CODE_TYPE                         OUT NOCOPY    VARCHAR2,
    X_URL                                   OUT NOCOPY    VARCHAR2,
    X_EMAIL_ADDRESS                         OUT NOCOPY    VARCHAR2,
    X_ANALYSIS_FY                           OUT NOCOPY    VARCHAR2,
    X_FISCAL_YEAREND_MONTH                  OUT NOCOPY    VARCHAR2,
    X_EMPLOYEES_TOTAL                       OUT NOCOPY    NUMBER,
    X_CURR_FY_POTENTIAL_REVENUE             OUT NOCOPY    NUMBER,
    X_NEXT_FY_POTENTIAL_REVENUE             OUT NOCOPY    NUMBER,
    X_YEAR_ESTABLISHED                      OUT NOCOPY    NUMBER,
    X_GSA_INDICATOR_FLAG                    OUT NOCOPY    VARCHAR2,
    X_MISSION_STATEMENT                     OUT NOCOPY    VARCHAR2,
    X_ORGANIZATION_NAME_PHONETIC            OUT NOCOPY    VARCHAR2,
    X_PERSON_FIRST_NAME_PHONETIC            OUT NOCOPY    VARCHAR2,
    X_PERSON_LAST_NAME_PHONETIC             OUT NOCOPY    VARCHAR2,
    X_LANGUAGE_NAME                         OUT NOCOPY    VARCHAR2,
    X_CATEGORY_CODE                         OUT NOCOPY    VARCHAR2,
    X_SALUTATION                            OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS2                             OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS3                             OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS4                             OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS5                             OUT NOCOPY    VARCHAR2,
    X_DUNS_NUMBER_C                         OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
) IS

BEGIN

    SELECT
        NVL( PARTY_ID, FND_API.G_MISS_NUM ),
        NVL( PARTY_NUMBER, FND_API.G_MISS_CHAR ),
        NVL( PARTY_NAME, FND_API.G_MISS_CHAR ),
        NVL( PARTY_TYPE, FND_API.G_MISS_CHAR ),
        NVL( VALIDATED_FLAG, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE1, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE2, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE3, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE4, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE5, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE6, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE7, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE8, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE9, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE10, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE11, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE12, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE13, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE14, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE15, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE16, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE17, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE18, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE19, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE20, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE21, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE22, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE23, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE24, FND_API.G_MISS_CHAR ),
        NVL( ORIG_SYSTEM_REFERENCE, FND_API.G_MISS_CHAR ),
        NVL( SIC_CODE, FND_API.G_MISS_CHAR ),
        NVL( HQ_BRANCH_IND, FND_API.G_MISS_CHAR ),
        NVL( CUSTOMER_KEY, FND_API.G_MISS_CHAR ),
        NVL( TAX_REFERENCE, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_FISCAL_CODE, FND_API.G_MISS_CHAR ),
        NVL( PERSON_PRE_NAME_ADJUNCT, FND_API.G_MISS_CHAR ),
        NVL( PERSON_FIRST_NAME, FND_API.G_MISS_CHAR ),
        NVL( PERSON_MIDDLE_NAME, FND_API.G_MISS_CHAR ),
        NVL( PERSON_LAST_NAME, FND_API.G_MISS_CHAR ),
        NVL( PERSON_NAME_SUFFIX, FND_API.G_MISS_CHAR ),
        NVL( PERSON_TITLE, FND_API.G_MISS_CHAR ),
        NVL( PERSON_ACADEMIC_TITLE, FND_API.G_MISS_CHAR ),
        NVL( PERSON_PREVIOUS_LAST_NAME, FND_API.G_MISS_CHAR ),
        NVL( KNOWN_AS, FND_API.G_MISS_CHAR ),
        NVL( PERSON_IDEN_TYPE, FND_API.G_MISS_CHAR ),
        NVL( PERSON_IDENTIFIER, FND_API.G_MISS_CHAR ),
        NVL( GROUP_TYPE, FND_API.G_MISS_CHAR ),
        NVL( COUNTRY, FND_API.G_MISS_CHAR ),
        NVL( ADDRESS1, FND_API.G_MISS_CHAR ),
        NVL( ADDRESS2, FND_API.G_MISS_CHAR ),
        NVL( ADDRESS3, FND_API.G_MISS_CHAR ),
        NVL( ADDRESS4, FND_API.G_MISS_CHAR ),
        NVL( CITY, FND_API.G_MISS_CHAR ),
        NVL( POSTAL_CODE, FND_API.G_MISS_CHAR ),
        NVL( STATE, FND_API.G_MISS_CHAR ),
        NVL( PROVINCE, FND_API.G_MISS_CHAR ),
        NVL( STATUS, FND_API.G_MISS_CHAR ),
        NVL( COUNTY, FND_API.G_MISS_CHAR ),
        NVL( SIC_CODE_TYPE, FND_API.G_MISS_CHAR ),
        NVL( URL, FND_API.G_MISS_CHAR ),
        NVL( EMAIL_ADDRESS, FND_API.G_MISS_CHAR ),
        NVL( ANALYSIS_FY, FND_API.G_MISS_CHAR ),
        NVL( FISCAL_YEAREND_MONTH, FND_API.G_MISS_CHAR ),
        NVL( EMPLOYEES_TOTAL, FND_API.G_MISS_NUM ),
        NVL( CURR_FY_POTENTIAL_REVENUE, FND_API.G_MISS_NUM ),
        NVL( NEXT_FY_POTENTIAL_REVENUE, FND_API.G_MISS_NUM ),
        NVL( YEAR_ESTABLISHED, FND_API.G_MISS_NUM ),
        NVL( GSA_INDICATOR_FLAG, FND_API.G_MISS_CHAR ),
        NVL( MISSION_STATEMENT, FND_API.G_MISS_CHAR ),
        NVL( ORGANIZATION_NAME_PHONETIC, FND_API.G_MISS_CHAR ),
        NVL( PERSON_FIRST_NAME_PHONETIC, FND_API.G_MISS_CHAR ),
        NVL( PERSON_LAST_NAME_PHONETIC, FND_API.G_MISS_CHAR ),
        NVL( LANGUAGE_NAME, FND_API.G_MISS_CHAR ),
        NVL( CATEGORY_CODE, FND_API.G_MISS_CHAR ),
        NVL( SALUTATION, FND_API.G_MISS_CHAR ),
        NVL( KNOWN_AS2, FND_API.G_MISS_CHAR ),
        NVL( KNOWN_AS3, FND_API.G_MISS_CHAR ),
        NVL( KNOWN_AS4, FND_API.G_MISS_CHAR ),
        NVL( KNOWN_AS5, FND_API.G_MISS_CHAR ),
        NVL( DUNS_NUMBER_C, FND_API.G_MISS_CHAR ),
        NVL( CREATED_BY_MODULE, FND_API.G_MISS_CHAR ),
        NVL( APPLICATION_ID, FND_API.G_MISS_NUM )
    INTO
        X_PARTY_ID,
        X_PARTY_NUMBER,
        X_PARTY_NAME,
        X_PARTY_TYPE,
        X_VALIDATED_FLAG,
        X_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1,
        X_ATTRIBUTE2,
        X_ATTRIBUTE3,
        X_ATTRIBUTE4,
        X_ATTRIBUTE5,
        X_ATTRIBUTE6,
        X_ATTRIBUTE7,
        X_ATTRIBUTE8,
        X_ATTRIBUTE9,
        X_ATTRIBUTE10,
        X_ATTRIBUTE11,
        X_ATTRIBUTE12,
        X_ATTRIBUTE13,
        X_ATTRIBUTE14,
        X_ATTRIBUTE15,
        X_ATTRIBUTE16,
        X_ATTRIBUTE17,
        X_ATTRIBUTE18,
        X_ATTRIBUTE19,
        X_ATTRIBUTE20,
        X_ATTRIBUTE21,
        X_ATTRIBUTE22,
        X_ATTRIBUTE23,
        X_ATTRIBUTE24,
        X_ORIG_SYSTEM_REFERENCE,
        X_SIC_CODE,
        X_HQ_BRANCH_IND,
        X_CUSTOMER_KEY,
        X_TAX_REFERENCE,
        X_JGZZ_FISCAL_CODE,
        X_PERSON_PRE_NAME_ADJUNCT,
        X_PERSON_FIRST_NAME,
        X_PERSON_MIDDLE_NAME,
        X_PERSON_LAST_NAME,
        X_PERSON_NAME_SUFFIX,
        X_PERSON_TITLE,
        X_PERSON_ACADEMIC_TITLE,
        X_PERSON_PREVIOUS_LAST_NAME,
        X_KNOWN_AS,
        X_PERSON_IDEN_TYPE,
        X_PERSON_IDENTIFIER,
        X_GROUP_TYPE,
        X_COUNTRY,
        X_ADDRESS1,
        X_ADDRESS2,
        X_ADDRESS3,
        X_ADDRESS4,
        X_CITY,
        X_POSTAL_CODE,
        X_STATE,
        X_PROVINCE,
        X_STATUS,
        X_COUNTY,
        X_SIC_CODE_TYPE,
        X_URL,
        X_EMAIL_ADDRESS,
        X_ANALYSIS_FY,
        X_FISCAL_YEAREND_MONTH,
        X_EMPLOYEES_TOTAL,
        X_CURR_FY_POTENTIAL_REVENUE,
        X_NEXT_FY_POTENTIAL_REVENUE,
        X_YEAR_ESTABLISHED,
        X_GSA_INDICATOR_FLAG,
        X_MISSION_STATEMENT,
        X_ORGANIZATION_NAME_PHONETIC,
        X_PERSON_FIRST_NAME_PHONETIC,
        X_PERSON_LAST_NAME_PHONETIC,
        X_LANGUAGE_NAME,
        X_CATEGORY_CODE,
        X_SALUTATION,
        X_KNOWN_AS2,
        X_KNOWN_AS3,
        X_KNOWN_AS4,
        X_KNOWN_AS5,
        X_DUNS_NUMBER_C,
        X_CREATED_BY_MODULE,
        X_APPLICATION_ID
    FROM HZ_PARTIES
    WHERE PARTY_ID = X_PARTY_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'party_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', TO_CHAR( X_PARTY_ID ) );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    X_PARTY_ID                              IN     NUMBER
) IS

BEGIN

    DELETE FROM HZ_PARTIES
    WHERE PARTY_ID = X_PARTY_ID;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_PARTIES_PKG;

/
