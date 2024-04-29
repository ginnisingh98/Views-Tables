--------------------------------------------------------
--  DDL for Package Body HZ_MAP_PARTY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MAP_PARTY_PUB" AS
/*$Header: ARHMAPSB.pls 120.70.12000000.3 2007/10/05 11:32:52 idali ship $*/

/*
| MODIFICATION HISTORY
| Jan 2003        VJN Introduced Changes for the Mapping Program to call
|                 the conform party procedure, which would conform the purchased
|                 party to the DNB Hierarchy.
|
 +===========================================================================*/

G_PKG_NAME CONSTANT VARCHAR2(30) := 'HZ_MAP_PARTY_PUB';

--Bug 1736056: Default country to 'US' if it is NULL.
G_DEFAULT_COUNTRY_CODE   VARCHAR2(30) := 'US';
-- isMixNMatchEnabled       VARCHAR2(1) ;

-- Bug 3107162
G_ERROR_FLAG             VARCHAR2(1) := 'N';
G_PARTY_INTERFACE_ID     NUMBER(15);

TYPE related_duns_rec_type IS RECORD(
        DUNS_NUMBER		hz_party_interface.HQ_DUNS_NUMBER%TYPE,
        NAME			hz_party_interface.HQ_NAME%TYPE,
        COUNTRY			hz_party_interface.HQ_COUNTRY%TYPE,
        ADDRESS1		hz_party_interface.HQ_ADDRESS1%TYPE,
        CITY			hz_party_interface.HQ_CITY%TYPE,
        PRIMARY_GEO_AREA        hz_party_interface.HQ_PRIMARY_GEO_AREA%TYPE,
        COUNTY                  hz_party_interface.HQ_COUNTY%TYPE,
        POSTAL_CODE             hz_party_interface.HQ_POSTAL_CODE%TYPE,
        PHONE_NUMBER            hz_party_interface.HQ_PHONE_NUMBER%TYPE,
        RELATIONSHIP_CODE       hz_relationships.relationship_code%type,
        RELATIONSHIP_TYPE       hz_relationships.relationship_type%type,
        MAIN_PARTY_ID           NUMBER,
	MAIN_DUNS_NUMBER	VARCHAR2(15),
        CONTENT_SOURCE_TYPE     VARCHAR2(30)
);


procedure do_map(
        p_interface_rec         IN OUT NOCOPY 	HZ_PARTY_INTERFACE%ROWTYPE,
        x_return_status         IN OUT NOCOPY  VARCHAR2
);

procedure check_mosr_mapping (
        p_duns_number_c            IN            VARCHAR2,
	--4227564
	p_party_id		   IN		 VARCHAR2,
        p_inactivate_flag          IN            VARCHAR2,
        x_return_status            IN OUT NOCOPY VARCHAR2,
	x_msg_count                   OUT NOCOPY NUMBER,
        x_msg_data                    OUT NOCOPY VARCHAR2
);

procedure populate_to_classification(
        p_code_assignment_rec   IN OUT NOCOPY  hz_classification_v2pub.code_assignment_rec_type,
        p_interface_rec	        IN OUT NOCOPY    HZ_PARTY_INTERFACE%ROWTYPE,
--	p_is_new_party		IN BOOLEAN ,
        x_return_status         IN OUT NOCOPY  VARCHAR2
) ;
-- Bug 3417357 : Added parameter p_create_new
procedure store_location(
        p_location_rec          IN OUT NOCOPY  hz_location_v2pub.location_rec_type,
        p_party_id              IN      NUMBER,
	p_create_new		IN	BOOLEAN,
        x_return_status         IN OUT NOCOPY  VARCHAR2
);


procedure store_financial_report(
        --p_fin_rep_rec           IN OUT NOCOPY  hz_org_info_pub.financial_reports_rec_type,
        p_fin_rep_rec           IN OUT NOCOPY  HZ_ORGANIZATION_INFO_V2PUB.financial_report_rec_type,
        p_interface_rec         IN OUT NOCOPY  HZ_PARTY_INTERFACE%ROWTYPE,
        x_return_status         IN OUT NOCOPY  VARCHAR2
);


procedure store_financial_number(
	p_interface_rec 	IN OUT NOCOPY 	HZ_PARTY_INTERFACE%ROWTYPE,
	--p_fin_num_rec           IN OUT NOCOPY 	hz_org_info_pub.financial_numbers_rec_type,
	p_fin_num_rec           IN OUT NOCOPY 	HZ_ORGANIZATION_INFO_V2PUB.financial_number_rec_type,
        p_new_fin_report        IN   	VARCHAR2,
	p_type_of_financial_report    IN      VARCHAR2,
        x_return_status         IN OUT NOCOPY  VARCHAR2
);


procedure store_related_duns(
	p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
	p_group_id              IN      NUMBER,
    x_return_status         IN OUT NOCOPY  VARCHAR2
);

-- VJN Added a new OUT parameter for conforming DNB Purchasee
procedure do_store_related_duns(
        p_related_duns_rec      IN 	related_duns_rec_type,
        x_return_status         IN OUT NOCOPY  VARCHAR2,
        x_conform_party_id      OUT NOCOPY number
);


procedure store_error(
        p_status        	VARCHAR2,
        p_party_interface_id    NUMBER
);


procedure do_assign_org_record(
        p_interface_rec         IN OUT NOCOPY  HZ_PARTY_INTERFACE%ROWTYPE,
        l_organization_rec      OUT NOCOPY     HZ_PARTY_V2PUB.organization_rec_type
);


procedure do_assign_location_record(
        p_interface_rec         IN      HZ_PARTY_INTERFACE%ROWTYPE,
        l_location_rec          OUT NOCOPY     hz_location_v2pub.location_rec_type
);

procedure do_assign_credit_ratings(
	p_interface_rec		IN 	HZ_PARTY_INTERFACE%ROWTYPE,
	p_organization_rec      IN      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
	--l_credit_ratings_rec    OUT NOCOPY     HZ_PARTY_INFO_PUB.CREDIT_RATINGS_REC_TYPE
	l_credit_ratings_rec    OUT NOCOPY     HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE
);

procedure do_assign_financial_report(
        p_interface_rec             IN 	   HZ_PARTY_INTERFACE%ROWTYPE,
        --l_fin_rep_rec               IN OUT NOCOPY HZ_ORG_INFO_PUB.FINANCIAL_REPORTS_REC_TYPE,
        l_fin_rep_rec               IN OUT NOCOPY HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE,
        p_type_of_financial_report  IN     HZ_FINANCIAL_REPORTS.TYPE_OF_FINANCIAL_REPORT%type
);

PROCEDURE create_dynamic_lookups(
    p_party_interface_rec              IN     HZ_PARTY_INTERFACE%ROWTYPE,
    x_return_status                    IN OUT NOCOPY VARCHAR2
);

PROCEDURE create_lookup(
    p_lookup_code                      IN VARCHAR2,
    p_lookup_type                      IN VARCHAR2,
    x_return_status                    IN OUT NOCOPY VARCHAR2
);

PROCEDURE rectify_error_fields(
    p_interface_rec                    IN OUT NOCOPY HZ_PARTY_INTERFACE%ROWTYPE
);

PROCEDURE set_hz_dnb_invalid_data(
    p_column_name                      IN VARCHAR2,
    p_dnb_value                        IN VARCHAR2,
    p_tca_value                        IN VARCHAR2
);

PROCEDURE check_new_duns(
        p_organization_rec IN HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
        x_return_status OUT NOCOPY VARCHAR2
);

/*===========================================================================+
 | FUNCTION
 |              set_hz_dnb_invalid_data
 |
 | DESCRIPTION
 |           o  If value for any field passed by DNB is not valid, then this
 |              information is stored in hz_party_interface_errors
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_column_name (Column Name)
 |                    p_dnb_value   (Invalid Value passed by DNB)
 |                    p_tca_type    (Rectified TCA value)
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |  19-AUG-2004    Rajib Ranjan Borah   o Bug 3107162. Creted.
 |  13-OCT-2004    Sravanthi A          o Bug 3107162: Modified to set token
 |                                        to 'NULL' when p_tca_value is null
 |
 +===========================================================================*/

PROCEDURE set_hz_dnb_invalid_data(
    p_column_name                      IN VARCHAR2,
    p_dnb_value                        IN VARCHAR2,
    p_tca_value                        IN VARCHAR2
)IS
    l_message_text          VARCHAR2(2000) := NULL;
BEGIN
     FND_MESSAGE.SET_NAME('AR','HZ_DNB_INVALID_DATA');
     FND_MESSAGE.SET_TOKEN('FIELD_NAME',p_column_name);
     FND_MESSAGE.SET_TOKEN('DNB_VALUE',p_dnb_value);
     --bug 3107162: when a field is rectified to NULL error message should
     --be that the field is set to 'NULL' instead of blank
     IF p_tca_value IS NULL THEN
        FND_MESSAGE.SET_TOKEN('TCA_VALUE','NULL');
     ELSE
     	FND_MESSAGE.SET_TOKEN('TCA_VALUE',p_tca_value);
     END IF;
     l_message_text := FND_MESSAGE.GET;

     INSERT INTO hz_party_interface_errors (
                             interface_error_id,
			     party_interface_id,
			     message_text,
			     created_by,
			     creation_date,
			     last_updated_by,
			     last_update_date,
			     last_update_login)
     VALUES (
                             hz_party_interface_errors_s.nextval,
			     G_PARTY_INTERFACE_ID,
			     l_message_text,
			     hz_utility_v2pub.created_by,
			     hz_utility_v2pub.creation_date,
			     hz_utility_v2pub.last_updated_by,
			     hz_utility_v2pub.last_update_date,
                             hz_utility_v2pub.last_update_login);
     G_ERROR_FLAG:='Y';

END set_hz_dnb_invalid_data;


/*===========================================================================+
 | PROCEDURE
 |              rectify_error_fields
 |
 | DESCRIPTION
 |              o  If the value passed by DNB for any field is not a valid one,
 |                 this procedure replaces the same with a valid value.
 |                 ( So that information bought from DNB does not error out NOCOPY ).
 |                   ~ Yes/ No lookups will be defaulted to N.
 |                   ~ Currency code columns will be set to NULL.
 |                   ~ Other lookup code columns will be set to NULL.
 |              o  Status in hz_party_interface will be W1, W2 instead of P1,
 |                 P2 respectively if this procedure modifies any errorneous
 |                 DNB data.
 |              o  Inserts a record in hz_party_interface_errors for each field
 |                 rectified.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 |              o  set_hz_dnb_invalid_data
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT: p_interface_rec
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |  18-AUG-2004   Rajib Ranjan Borah   o Bug 3107162. Created.
 |  13-SEP-2004   Rajib Ranjan Borah   o Bug 3848365. Dynamic lookups will be
 |                                       created for invalid sic code values
 |                                       instead of nullifying them.
 |  13-OCT-2004   Sravanthi A	       o Bug 3107162: Commented out NOCOPY code for
 |                                       validation of det_history_ind
 |                                       Commented out NOCOPY code that sets local_activity_code
 |                                       of interface record to 'NACE'.
 +===========================================================================*/

PROCEDURE rectify_error_fields(
    p_interface_rec                    IN OUT NOCOPY HZ_PARTY_INTERFACE%ROWTYPE
) IS

    CURSOR c_currency_field (p_currency_code IN VARCHAR2) IS
        SELECT '1'
        FROM   FND_CURRENCIES
        WHERE  currency_code = p_currency_code AND
               currency_flag = 'Y' AND
	       enabled_flag  IN ('Y','N') AND
	       (
	       start_date_active IS NULL OR
	       start_date_active <= SYSDATE
	       ) AND
	       (
	       end_date_active IS NULL OR
	       end_date_active >= SYSDATE
	       );

    CURSOR c_ar_lookup_field (p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2) IS
        SELECT '1'
        FROM   AR_LOOKUPS
        WHERE  lookup_type  = p_lookup_type AND
               lookup_code  = p_lookup_code AND
	       enabled_flag = 'Y' AND
               (
     	       start_date_active IS NULL OR
               start_date_active <= SYSDATE
               ) AND
               (
               end_date_active IS NULL OR
               END_DATE_ACTIVE >= SYSDATE
               );
    l_temp_cur_var VARCHAR2(1);
BEGIN
    G_ERROR_FLAG := 'N';
    G_PARTY_INTERFACE_ID := p_interface_rec.party_interface_id;

    /*----------------------------------------------------------------------*/
    -- Currency related columns are set to NULL if the value is not present --
    -- in FND_CURRENCIES.currency.code.                                     --
    --                                                                      --
    -- Such columns include:                                                --
    --   ~ ANNUAL_SALES_CURRENCY                                            --
    --   ~ CAPITAL_CURRENCY_CODE                                            --
    --   ~ FINANCIAL_NUMBER_CURRENCY                                        --
    --   ~ MAX_CREDIT_CURRENCY                                              --
    --   ~ PREF_FUNCTIONAL_CURRENCY                                         --
    --   ~ TANGIBLE_NET_WORTH_CURR                                          --
    /*----------------------------------------------------------------------*/

    IF p_interface_rec.annual_sales_currency IS NOT NULL THEN
        OPEN c_currency_field( p_interface_rec.annual_sales_currency);
	FETCH c_currency_field INTO l_temp_cur_var;
        IF c_currency_field%NOTFOUND THEN
            set_hz_dnb_invalid_data( p_column_name => 'ANNUAL_SALES_CURRENCY',
	                             p_dnb_value   => p_interface_rec.annual_sales_currency,
				     p_tca_value   => NULL);
            p_interface_rec.annual_sales_currency := NULL;
	END IF;
        CLOSE c_currency_field;
    END IF;

    IF p_interface_rec.capital_currency_code IS NOT NULL THEN
        OPEN c_currency_field( p_interface_rec.capital_currency_code);
	FETCH c_currency_field INTO l_temp_cur_var;
        IF c_currency_field%NOTFOUND THEN
            set_hz_dnb_invalid_data( p_column_name => 'CAPITAL_CURRENCY_CODE',
	                             p_dnb_value   => p_interface_rec.capital_currency_code,
				     p_tca_value   => NULL);
            p_interface_rec.capital_currency_code := NULL;
	END IF;
        CLOSE c_currency_field;
    END IF;

    IF p_interface_rec.financial_number_currency IS NOT NULL THEN
        OPEN c_currency_field( p_interface_rec.financial_number_currency);
	FETCH c_currency_field INTO l_temp_cur_var;
        IF c_currency_field%NOTFOUND THEN
            set_hz_dnb_invalid_data( p_column_name => 'FINANCIAL_NUMBER_CURRENCY',
	                             p_dnb_value   => p_interface_rec.financial_number_currency,
				     p_tca_value   => NULL);
            p_interface_rec.financial_number_currency := NULL;
	END IF;
        CLOSE c_currency_field;
    END IF;

    IF p_interface_rec.max_credit_currency IS NOT NULL THEN
        OPEN c_currency_field( p_interface_rec.max_credit_currency);
	FETCH c_currency_field INTO l_temp_cur_var;
        IF c_currency_field%NOTFOUND THEN
            set_hz_dnb_invalid_data( p_column_name => 'MAX_CREDIT_CURRENCY',
	                             p_dnb_value   => p_interface_rec.max_credit_currency,
				     p_tca_value   => NULL);
            p_interface_rec.max_credit_currency := NULL;
	END IF;
        CLOSE c_currency_field;
    END IF;

    IF p_interface_rec.pref_functional_currency IS NOT NULL THEN
        OPEN c_currency_field( p_interface_rec.pref_functional_currency);
	FETCH c_currency_field INTO l_temp_cur_var;
        IF c_currency_field%NOTFOUND THEN
            set_hz_dnb_invalid_data( p_column_name => 'PREF_FUNCTIONAL_CURRENCY',
	                             p_dnb_value   => p_interface_rec.pref_functional_currency,
				     p_tca_value   => NULL);
            p_interface_rec.pref_functional_currency := NULL;
	END IF;
        CLOSE c_currency_field;
    END IF;

    IF p_interface_rec.tangible_net_worth_curr IS NOT NULL THEN
        OPEN c_currency_field( p_interface_rec.tangible_net_worth_curr);
	FETCH c_currency_field INTO l_temp_cur_var;
	IF c_currency_field%NOTFOUND THEN
            set_hz_dnb_invalid_data( p_column_name => 'TANGIBLE_NET_WORTH_CURR',
	                             p_dnb_value   => p_interface_rec.tangible_net_worth_curr,
				     p_tca_value   => NULL);
	    p_interface_rec.tangible_net_worth_curr := NULL;
	END IF;
        CLOSE c_currency_field;
    END IF;

    /*--------------------------------------------------------------------*/
    -- Phone_country_code should be a valid value in HZ_PHONE_COUNTRY_CODES.
    --
    -- Set to NULL otherwise.
    /*--------------------------------------------------------------------*/

    BEGIN
        IF p_interface_rec.phone_country_code IS NOT NULL THEN
            SELECT '1'
            INTO   l_temp_cur_var
            FROM   HZ_PHONE_COUNTRY_CODES
            WHERE  phone_country_code = p_interface_rec.phone_country_code AND
	           ROWNUM = 1;
	END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            set_hz_dnb_invalid_data(
	         p_column_name => 'PHONE_COUNTRY_CODE',
                 p_dnb_value   => p_interface_rec.phone_country_code,
                 p_tca_value => NULL );
	    p_interface_rec.phone_country_code := NULL;
    END;

    /*--------------------------------------------------------------------*/
    -- Local_activity_code_type should be a valid lookup code in lookup   --
    -- type LOCAL_ACTIVITY_CODE_TYPE                                      --
    --                                                                    --
    -- If local_activity_code_type is not a valid value, nullify both     --
    -- local_activity_code_type and loacl_activity_code.                  --
    /*--------------------------------------------------------------------*/

    BEGIN
        IF p_interface_rec.local_activity_code_type IS NOT NULL THEN
	    OPEN c_ar_lookup_field ('LOCAL_ACTIVITY_CODE_TYPE',p_interface_rec.local_activity_code_type);
            FETCH c_ar_lookup_field INTO l_temp_cur_var;

	    IF c_ar_lookup_field%NOTFOUND THEN
                set_hz_dnb_invalid_data(
  	             p_column_name => 'LOCAL_ACTIVITY_CODE_TYPE',
                     p_dnb_value   => p_interface_rec.local_activity_code_type,
                     p_tca_value => NULL);
                p_interface_rec.local_activity_code_type := NULL;

                IF p_interface_rec.local_activity_code IS NOT NULL THEN
                    set_hz_dnb_invalid_data(
		         p_column_name => 'LOCAL_ACTIVITY_CODE',
                         p_dnb_value   => p_interface_rec.local_activity_code,
                         p_tca_value => NULL);
                    p_interface_rec.local_activity_code      := NULL;
 	        END IF;
	   --bug 3107162: Commented out this code
	  --  ELSIF p_interface_rec.local_activity_code_type IN ('4','5') THEN
	      --  p_interface_rec.local_activity_code_type := 'NACE';
            ELSIF p_interface_rec.local_activity_code_type IN ('4','5') THEN
               p_interface_rec.local_activity_code := SUBSTRB(REPLACE(p_interface_rec.local_activity_code,' ',''),1,4);
	    END IF;
	    CLOSE c_ar_lookup_field;
	ELSE  -- Local activity code type is NULL
	    IF p_interface_rec.local_activity_code IS NOT NULL THEN
	        -- Local activity code is not NULL but type is NULL, so nullify code also.
	        set_hz_dnb_invalid_data(
  	             p_column_name => 'LOCAL_ACTIVITY_CODE',
                     p_dnb_value   => p_interface_rec.local_activity_code,
                     p_tca_value => NULL);
	        p_interface_rec.local_activity_code := NULL;
	    END IF;
	END IF;
    END;

    -- Rectification of hq_branch_ind, local_bus_iden_type, rent_own_ind.
    BEGIN
        IF p_interface_rec.hq_branch_ind = 'H' THEN
	    p_interface_rec.hq_branch_ind := 'HQ';
	ELSIF  p_interface_rec.hq_branch_ind = 'B' THEN
            p_interface_rec.hq_branch_ind := 'BR';
	ELSIF p_interface_rec.hq_branch_ind = 'S' THEN
            p_interface_rec.hq_branch_ind := 'SL';
	ELSIF p_interface_rec.hq_branch_ind IS NOT NULL THEN
	    OPEN c_ar_lookup_field ('HQ_BRANCH_IND',p_interface_rec.hq_branch_ind);
            FETCH c_ar_lookup_field INTO l_temp_cur_var;
	    IF c_ar_lookup_field%NOTFOUND THEN
	        set_hz_dnb_invalid_data( p_column_name  => 'HQ_BRANCH_IND',
		                         p_dnb_value    => p_interface_rec.hq_branch_ind,
					 p_tca_value    => NULL);
	        p_interface_rec.hq_branch_ind := NULL;
	    END IF;
	    CLOSE c_ar_lookup_field;
        END IF;
    END;

    IF p_interface_rec.local_bus_iden_type IS NOT NULL THEN
        OPEN c_ar_lookup_field ('LOCAL_BUS_IDEN_TYPE',p_interface_rec.local_bus_iden_type );
        FETCH c_ar_lookup_field INTO l_temp_cur_var;
	IF c_ar_lookup_field%NOTFOUND THEN
            set_hz_dnb_invalid_data( p_column_name  => 'LOCAL_BUS_IDEN_TYPE',
				     p_dnb_value    => p_interface_rec.local_bus_iden_type,
				     p_tca_value    => NULL);
            p_interface_rec.local_bus_iden_type := NULL;
	END IF;
	CLOSE c_ar_lookup_field;
    END IF;

    IF p_interface_rec.rent_own_ind IS NOT NULL THEN
        OPEN c_ar_lookup_field( 'OWN_RENT_IND',p_interface_rec.rent_own_ind );
        FETCH c_ar_lookup_field INTO l_temp_cur_var;
	IF c_ar_lookup_field%NOTFOUND THEN
	    set_hz_dnb_invalid_data( p_column_name => 'RENT_OWN_IND',
	                             p_dnb_value   => p_interface_rec.rent_own_ind,
				     p_tca_value   => NULL);
	    p_interface_rec.rent_own_ind := NULL;
	END IF;
	CLOSE c_ar_lookup_field;
    END IF;

    /*-------------------------------------------------------*/
    -- Bug 4086866: If the passed value for YEAR_ESTABLISHED or INCORP_YEAR
    -- has more than 4 characters, set the field to NULL.
    /*-------------------------------------------------------*/
    IF p_interface_rec.year_established > 9999 or p_interface_rec.year_established < 0 THEN
	    set_hz_dnb_invalid_data( p_column_name => 'YEAR_ESTABLISHED',
	                             p_dnb_value   => p_interface_rec.year_established,
				     p_tca_value   => NULL);
	    p_interface_rec.year_established := NULL;
    END IF;

    IF p_interface_rec.incorp_year > 9999 or p_interface_rec.incorp_year < 0 THEN
	    set_hz_dnb_invalid_data( p_column_name => 'INCORP_YEAR',
	                             p_dnb_value   => p_interface_rec.incorp_year,
				     p_tca_value   => NULL);
	    p_interface_rec.incorp_year := NULL;
    END IF;

    /*---------------------------------------------------------------------*/
    -- If the value for SIC_CODE_TYPE is not a valid lookup_code of lookup --
    -- type 'SIC_CODE_TYPE', set the value of SIC_CODE_TYPE and SIC_CODE1, --
    -- SIC_CODE2,..SIC_CODE6 to NULL.                                      --
    -- Furthermore, if any of the sic codes have a value, and sic code     --
    -- type is NULL, then default it to '1985 SIC'                         --
    /*---------------------------------------------------------------------*/
    DECLARE
        p_sic_code_substrb_flag BOOLEAN := FALSE;
    BEGIN
        IF replace(p_interface_rec.sic_code_type, ' ','') IN ('1972','1977','1987') THEN
	    p_interface_rec.sic_code_type := replace(p_interface_rec.sic_code_type,' ','') || ' SIC';
	END IF;

        IF p_interface_rec.sic_code_type IS NOT NULL THEN
	   OPEN c_ar_lookup_field( 'SIC_CODE_TYPE',p_interface_rec.sic_code_type);
           FETCH c_ar_lookup_field INTO l_temp_cur_var;
	   IF c_ar_lookup_field%NOTFOUND THEN
    	        -- SIC_CODE_TYPE is an invalid value.
    	        -- Nullify SIC_CODE_TYPE and SIC_CODE1...SIC_CODE6.
		CLOSE c_ar_lookup_field;

         	set_hz_dnb_invalid_data(
    	                        p_column_name  => 'SIC_CODE_TYPE',
    				p_dnb_value    => p_interface_rec.sic_code_type,
    	                        p_tca_value    => NULL);
    	        p_interface_rec.sic_code_type := NULL;

                IF p_interface_rec.sic_code1 IS NOT NULL THEN
    	            set_hz_dnb_invalid_data(
    		                p_column_name  => 'SIC_CODE1',
    				p_dnb_value    => p_interface_rec.sic_code1,
    	                        p_tca_value    => NULL);
    		    p_interface_rec.sic_code1 := NULL;
    	        END IF;

                IF p_interface_rec.sic_code2 IS NOT NULL THEN
    	            set_hz_dnb_invalid_data(
    		                p_column_name  => 'SIC_CODE2',
    				p_dnb_value    => p_interface_rec.sic_code2,
    	                        p_tca_value    => NULL);
    		    p_interface_rec.sic_code2 := NULL;
    	        END IF;

                IF p_interface_rec.sic_code3 IS NOT NULL THEN
    	            set_hz_dnb_invalid_data(
    		                p_column_name  => 'SIC_CODE3',
    				p_dnb_value    => p_interface_rec.sic_code3,
    		                p_tca_value    => NULL);
    		    p_interface_rec.sic_code3 := NULL;
    	        END IF;

                IF p_interface_rec.sic_code4 IS NOT NULL THEN
    	            set_hz_dnb_invalid_data(
    		                p_column_name  => 'SIC_CODE4',
    				p_dnb_value    => p_interface_rec.sic_code4,
    		                p_tca_value    => NULL);
    		    p_interface_rec.sic_code4 := NULL;
    	        END IF;

                IF p_interface_rec.sic_code5 IS NOT NULL THEN
    	            set_hz_dnb_invalid_data(
    		                p_column_name  => 'SIC_CODE5',
    				p_dnb_value    => p_interface_rec.sic_code5,
    		                p_tca_value    => NULL);
    		    p_interface_rec.sic_code5 := NULL;
    	        END IF;

                IF p_interface_rec.sic_code6 IS NOT NULL THEN
    	            set_hz_dnb_invalid_data(
    		                p_column_name  => 'SIC_CODE6',
    				p_dnb_value    => p_interface_rec.sic_code6,
              	                p_tca_value    => NULL);
    		    p_interface_rec.sic_code6 := NULL;
    	        END IF;

	    ELSE

	        CLOSE c_ar_lookup_field;
		IF (
                   p_interface_rec.sic_code1 IS  NULL AND
	           p_interface_rec.sic_code2 IS  NULL AND
                   p_interface_rec.sic_code3 IS  NULL AND
                   p_interface_rec.sic_code4 IS  NULL AND
                   p_interface_rec.sic_code5 IS  NULL AND
                   p_interface_rec.sic_code6 IS  NULL
	           )
		THEN
        	    -- Either both sic code type and sic code should have a value or none
		    -- should have a value.
		    -- As sic codes are NULL, therefore Nullify sic_code_type.
		    set_hz_dnb_invalid_data(
		                    p_column_name  => 'SIC_CODE_TYPE',
				    p_dnb_value    => p_interface_rec.sic_code_type,
				    p_tca_value    => NULL);
		    p_interface_rec.sic_code_type := NULL;
                ELSE
		    p_sic_code_substrb_flag := TRUE;
                END IF;
	    END IF;
    	ELSE
            IF (
	       p_interface_rec.sic_code1 IS NOT NULL OR
	       p_interface_rec.sic_code2 IS NOT NULL OR
               p_interface_rec.sic_code3 IS NOT NULL OR
               p_interface_rec.sic_code4 IS NOT NULL OR
               p_interface_rec.sic_code5 IS NOT NULL OR
               p_interface_rec.sic_code6 IS NOT NULL
	       )
	    THEN
	        -- Set default value of sic_code_type.
                p_interface_rec.sic_code_type := '1987 SIC';
		p_sic_code_substrb_flag := TRUE;
	    END IF;
        END IF;
        IF p_sic_code_substrb_flag = TRUE THEN
	-- Need to modify this when a decision on enhancement request 3848373 is done.
	    p_interface_rec.sic_code1 := SUBSTRB(REPLACE(p_interface_rec.sic_code1,' ',''),1,4);
	    p_interface_rec.sic_code2 := SUBSTRB(REPLACE(p_interface_rec.sic_code2,' ',''),1,4);
            p_interface_rec.sic_code3 := SUBSTRB(REPLACE(p_interface_rec.sic_code3,' ',''),1,4);
	    p_interface_rec.sic_code4 := SUBSTRB(REPLACE(p_interface_rec.sic_code4,' ',''),1,4);
	    p_interface_rec.sic_code5 := SUBSTRB(REPLACE(p_interface_rec.sic_code5,' ',''),1,4);
	    p_interface_rec.sic_code6 := SUBSTRB(REPLACE(p_interface_rec.sic_code6,' ',''),1,4);
	END IF;
    END;

    /*---------------------------------------------------------------------*/
    -- Columns which are validated against Y/N are changed to 'N' if the
    -- value is something other than 'Y'/'N'.
    --
    -- Such columns include:
    --   ~ ANNUAL_SALES_CONSOL_IND     ~ AUDIT_IND           ~ BANKRUPTCY_IND
    --   ~ BRANCH_FLAG                 ~ CLAIMS_IND          ~ CONSOLIDATED_IND
    --   ~ CRIMINAL_PROCEEDING_IND     ~ DET_HISTORY_IND     ~ DISADV_8A_IND
    --   ~ DISASTER_IND                ~ ESTIMATED_IND       ~ EXPORT_IND
    --   ~ FINAL_IND                   ~ FINCL_EMBT_IND      ~ FINCL_LGL_EVENT_IND
    --   ~ FISCAL_IND                  ~ FORECAST_IND        ~ IMPORT_IND
    --   ~ JUDGEMENT_IND               ~ LABOR_SURPLUS_IND   ~ LIEN_IND
    --   ~ MINORITY_OWNED_IND          ~ NO_TRADE_IND        ~ OOB_IND
    --   ~ OPENING_IND                 ~ OPRG_SPEC_EVNT_IND  ~ OTHER_SPEC_EVNT_IND
    --   ~ PARENT_SUB_IND              ~ PRNT_HQ_BKCY_IND    ~ PROFORMA_IND
    --   ~ QUALIFIED_IND               ~ RESTATED_IND        ~ SECURED_FLNG_IND
    --   ~ SIGNED_BY_PRINCIPALS_IND    ~ SMALL_BUS_IND       ~ SUIT_IND
    --   ~ TRIAL_BALANCE_IND           ~ UNBALANCED_IND      ~ WOMAN_OWNED_IND
    /*---------------------------------------------------------------------*/
    IF p_interface_rec.annual_sales_consol_ind NOT IN ('Y' ,'N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'ANNUAL_SALES_CONSOL_IND',
				    p_dnb_value    => p_interface_rec.annual_sales_consol_ind,
				    p_tca_value    => 'N');
        p_interface_rec.annual_sales_consol_ind := 'N';
    END IF;

    IF p_interface_rec.audit_ind NOT IN ('Y' ,'N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'AUDIT_IND',
				    p_dnb_value    => p_interface_rec.audit_ind,
				    p_tca_value    => 'N');
        p_interface_rec.audit_ind := 'N';
    END IF;

    IF p_interface_rec.bankruptcy_ind IS NULL THEN
        p_interface_rec.bankruptcy_ind := 'N';
    ELSIF p_interface_rec.bankruptcy_ind = 'B' THEN
        p_interface_rec.bankruptcy_ind := 'Y';
    ELSIF p_interface_rec.bankruptcy_ind NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'BANKRUPTCY_IND',
				    p_dnb_value    => p_interface_rec.bankruptcy_ind,
				    p_tca_value    => 'N');
        p_interface_rec.bankruptcy_ind := 'N';
    END IF;

    IF p_interface_rec.branch_flag NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'BRANCH_FLAG',
				    p_dnb_value    => p_interface_rec.branch_flag,
				    p_tca_value    => 'N');
        p_interface_rec.branch_flag := 'N';
    END IF;

    IF p_interface_rec.claims_ind NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'CLAIMS_IND',
				    p_dnb_value    => p_interface_rec.claims_ind,
				    p_tca_value    => 'N');
        p_interface_rec.claims_ind := 'N';
    END IF;

    IF p_interface_rec.consolidated_ind = 'C' THEN
        p_interface_rec.consolidated_ind := 'Y';
    ELSIF p_interface_rec.consolidated_ind NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'CONSOLIDATED_IND',
				    p_dnb_value => p_interface_rec.consolidated_ind,
				    p_tca_value => 'N');
	p_interface_rec.consolidated_ind := 'N';
    END IF;

    IF p_interface_rec.criminal_proceeding_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'CRIMINAL_PROCEEDING_IND',
				    p_dnb_value    => p_interface_rec.criminal_proceeding_ind,
				    p_tca_value    => 'N');
	p_interface_rec.criminal_proceeding_ind := 'N';
    END IF;

    --bug 3107162: commented validation of det_history_ind for the present.
/*    IF p_interface_rec.det_history_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'DET_HISTORY_IND',
				    p_dnb_value    => p_interface_rec.det_history_ind,
				    p_tca_value    => 'N');
        p_interface_rec.det_history_ind := 'N';
    END IF;*/

    IF p_interface_rec.disadv_8a_ind NOT IN ( 'Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'DISADV_8A_IND',
                            	    p_dnb_value    => p_interface_rec.disadv_8a_ind,
				    p_tca_value    => 'N');
        p_interface_rec.disadv_8a_ind := 'N';
    END IF;

    IF p_interface_rec.disaster_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'DISASTER_IND',
				    p_dnb_value    => p_interface_rec.disaster_ind,
                                    p_tca_value    => 'N');
        p_interface_rec.disaster_ind := 'N';
    END IF;

    IF p_interface_rec.estimated_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'ESTIMATED_IND',
				    p_dnb_value    => p_interface_rec.estimated_ind,
                                    p_tca_value    => 'N');
	p_interface_rec.estimated_ind := 'N';
    END IF;

    IF p_interface_rec.export_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'EXPORT_IND',
				    p_dnb_value => p_interface_rec.export_ind,
                                    p_tca_value => 'N');
        p_interface_rec.export_ind := 'N';
    END IF;

    IF p_interface_rec.final_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'FINAL_IND',
				    p_dnb_value    => p_interface_rec.final_ind,
                                    p_tca_value    => 'N');
        p_interface_rec.final_ind := 'N';
    END IF;

    IF p_interface_rec.fincl_embt_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'FINCL_EMBT_IND',
				    p_dnb_value    => p_interface_rec.fincl_embt_ind,
                                    p_tca_value    => 'N');
        p_interface_rec.fincl_embt_ind := 'N';
    END IF;

    IF p_interface_rec.fincl_lgl_event_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'FINCL_LGL_EVETN_IND',
				    p_dnb_value    => p_interface_rec.fincl_lgl_event_ind,
                                    p_tca_value    => 'N');
        p_interface_rec.fincl_lgl_event_ind := 'N';
    END IF;

    IF p_interface_rec.fiscal_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data(    p_column_name  => 'FISCAL_IND',
				    p_dnb_value    => p_interface_rec.fiscal_ind,
                                    p_tca_value => 'N');
	p_interface_rec.fiscal_ind := 'N';
    END IF;

    IF p_interface_rec.forecast_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'FORECAST_IND',
				 p_dnb_value    => p_interface_rec.forecast_ind,
                                 p_tca_value => 'N');
        p_interface_rec.forecast_ind := 'N';
    END IF;

    IF p_interface_rec.import_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'IMPORT_IND',
				 p_dnb_value    => p_interface_rec.import_ind,
                                 p_tca_value => 'N');
        p_interface_rec.import_ind := 'N';
    END IF;

    IF p_interface_rec.judgement_ind IS NULL THEN
        p_interface_rec.judgement_ind := 'N';
    ELSIF p_interface_rec.judgement_ind = 'J' THEN
        p_interface_rec.judgement_ind := 'Y';
    ELSIF p_interface_rec.judgement_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'JUDGEMENT_IND',
				 p_dnb_value    => p_interface_rec.judgement_ind,
                                 p_tca_value => 'N');
        p_interface_rec.judgement_ind := 'N';
    END IF;

    IF p_interface_rec.labor_surplus_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'LABOR_SURPLUS_IND',
				 p_dnb_value    => p_interface_rec.labor_surplus_ind,
                                 p_tca_value => 'N');
        p_interface_rec.labor_surplus_ind := 'N';
    END IF;

    IF p_interface_rec.lien_ind IS NULL THEN
        p_interface_rec.lien_ind := 'N';
    ELSIF p_interface_rec.lien_ind = 'L' THEN
        p_interface_rec.lien_ind := 'Y';
    ELSIF p_interface_rec.lien_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'LIEN_IND',
				 p_dnb_value    => p_interface_rec.lien_ind,
                                 p_tca_value => 'N');
        p_interface_rec.lien_ind := 'N';
    END IF;

    IF p_interface_rec.minority_owned_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'MINORITY_OWNED_IND',
				 p_dnb_value    => p_interface_rec.minority_owned_ind,
                                 p_tca_value => 'N');
        p_interface_rec.minority_owned_ind := 'N';
    END IF;

    IF p_interface_rec.no_trade_ind IS NULL THEN
        p_interface_rec.no_trade_ind := 'Y';
    ELSIF p_interface_rec.no_trade_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'NO_TRADE_IND',
				 p_dnb_value    => p_interface_rec.no_trade_ind,
                                 p_tca_value => 'N');
        p_interface_rec.no_trade_ind := 'N';
    END IF;

    IF p_interface_rec.oob_ind = 'OB' THEN
        p_interface_rec.oob_ind := 'Y';
    ELSIF p_interface_rec.oob_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'OOB_IND',
				 p_dnb_value    => p_interface_rec.oob_ind,
                                 p_tca_value => 'N');
        p_interface_rec.oob_ind	:= 'N';
    END IF;

    IF p_interface_rec.opening_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'OPENING_IND',
				 p_dnb_value    => p_interface_rec.opening_ind,
                                 p_tca_value => 'N');
        p_interface_rec.opening_ind := 'N';
    END IF;

    IF p_interface_rec.oprg_spec_evnt_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'OPRG_SPEC_EVNT_IND',
				 p_dnb_value    => p_interface_rec.oprg_spec_evnt_ind,
                                 p_tca_value => 'N');
        p_interface_rec.oprg_spec_evnt_ind := 'N';
    END IF;

    IF p_interface_rec.other_spec_evnt_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'OTHER_SPEC_EVNT_IND',
				 p_dnb_value    => p_interface_rec.other_spec_evnt_ind,
                                 p_tca_value => 'N');
        p_interface_rec.other_spec_evnt_ind := 'N';
    END IF;

    IF p_interface_rec.parent_sub_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'PARENT_SUB_IND',
				 p_dnb_value    => p_interface_rec.parent_sub_ind,
                                 p_tca_value => 'N');
        p_interface_rec.parent_sub_ind := 'N';
    END IF;

    IF p_interface_rec.prnt_hq_bkcy_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'PRNT_HQ_BKCY_IND',
				 p_dnb_value    => p_interface_rec.prnt_hq_bkcy_ind,
                                 p_tca_value => 'N');
        p_interface_rec.prnt_hq_bkcy_ind := 'N';
    END IF;

    IF p_interface_rec.proforma_ind IS NULL THEN
        p_interface_rec.proforma_ind := 'N';
    ELSIF p_interface_rec.proforma_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'PROFORMA_IND',
				 p_dnb_value    => p_interface_rec.proforma_ind,
                                 p_tca_value => 'N');
        p_interface_rec.proforma_ind := 'N';
    END IF;

    IF p_interface_rec.qualified_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'QUALIFIED_IND',
				 p_dnb_value    => p_interface_rec.qualified_ind,
                                 p_tca_value => 'N');
        p_interface_rec.qualified_ind := 'N';
    END IF;

    IF p_interface_rec.restated_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'RESTATED_IND',
				 p_dnb_value    => p_interface_rec.restated_ind,
                                 p_tca_value => 'N');
        p_interface_rec.restated_ind := 'N';
    END IF;

    IF p_interface_rec.secured_flng_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'SECURED_FLNG_IND',
				 p_dnb_value    => p_interface_rec.secured_flng_ind,
                                 p_tca_value => 'N');
        p_interface_rec.secured_flng_ind := 'N';
    END IF;

    IF p_interface_rec.signed_by_principals_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'SIGNED_BY_PRINCIPALS_IND',
				 p_dnb_value    => p_interface_rec.signed_by_principals_ind,
                                 p_tca_value => 'N');
        p_interface_rec.signed_by_principals_ind := 'N';
    END IF;

    IF p_interface_rec.small_bus_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'SMALL_BUS_IND',
				 p_dnb_value    => p_interface_rec.small_bus_ind,
                                 p_tca_value => 'N');
        p_interface_rec.small_bus_ind := 'N';
    END IF;

    IF p_interface_rec.suit_ind IS NULL THEN
        p_interface_rec.suit_ind := 'N';
    ELSIF p_interface_rec.suit_ind = 'S' THEN
        p_interface_rec.suit_ind := 'Y';
    ELSIF p_interface_rec.suit_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'SUIT_IND',
				 p_dnb_value    => p_interface_rec.suit_ind,
                                 p_tca_value => 'N');
        p_interface_rec.suit_ind := 'N';
    END IF;

    IF p_interface_rec.trial_balance_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'TRIAL_BALANCE_IND',
				 p_dnb_value    => p_interface_rec.trial_balance_ind,
				 p_tca_value =>'N');
        p_interface_rec.trial_balance_ind := 'N';
    END IF;

    IF p_interface_rec.unbalanced_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'UNBALANCED_IND',
				 p_dnb_value    => p_interface_rec.unbalanced_ind,
				 p_tca_value =>'N');
        p_interface_rec.unbalanced_ind := 'N';
    END IF;

    IF p_interface_rec.woman_owned_ind  NOT IN ('Y','N') THEN
        set_hz_dnb_invalid_data( p_column_name  => 'WOMAN_OWNED_IND',
				 p_dnb_value    => p_interface_rec.woman_owned_ind,
				 p_tca_value =>'N');
        p_interface_rec.woman_owned_ind := 'N';
    END IF;

END rectify_error_fields;


procedure do_add_policy_function
IS

     l_ar_schema          VARCHAR2(30);
     l_apps_schema        VARCHAR2(30);
     l_aol_schema         VARCHAR2(30);
     l_apps_mls_schema    VARCHAR2(30);

     l_status             VARCHAR2(30);
     l_industry           VARCHAR2(30);
     l_return_value       BOOLEAN;

BEGIN

arp_util.debug('do_add_policy_function (+) ');

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
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_ORGANIZATION_PROFILES', 'content_source_type_sec', l_apps_schema, 'hz_common_pub.content_source_type_security');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_PERSON_PROFILES', 'content_source_type_sec', l_apps_schema, 'hz_common_pub.content_source_type_security');

     /* SSM SST Integration and Extension
      * Policy functions will not be added to non-profile entities as the concept of
      *	select/de-select data sources for other entities is obsoleted.

     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_RELATIONSHIPS', 'content_source_type_sec', l_apps_schema, 'hz_common_pub.content_source_type_security');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_LOCATIONS', 'content_source_type_sec', l_apps_schema, 'hz_common_pub.content_source_type_security');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_CONTACT_POINTS', 'content_source_type_sec', l_apps_schema, 'hz_common_pub.content_source_type_security');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_CREDIT_RATINGS', 'content_source_type_sec', l_apps_schema, 'hz_common_pub.content_source_type_security');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_FINANCIAL_REPORTS', 'content_source_type_sec', l_apps_schema, 'hz_common_pub.content_source_type_security');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_FINANCIAL_NUMBERS', 'content_source_type_sec', l_apps_schema, 'hz_common_pub.content_source_type_security');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_CODE_ASSIGNMENTS', 'content_source_type_sec', l_apps_schema, 'hz_common_pub.content_source_type_security');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_ORGANIZATION_INDICATORS', 'content_source_type_sec', l_apps_schema, 'hz_common_pub.content_source_type_security');
     FND_ACCESS_CONTROL_UTIL.ADD_POLICY(l_ar_schema, 'HZ_PARTY_SITES', 'content_source_type_sec', l_apps_schema, 'hz_common_pub.content_source_type_security');
     */
arp_util.debug('do_add_policy_function (-) ');

END do_add_policy_function;

/*===========================================================================+
 | PROCEDURE
 |              do_create_request_log
 |
 | DESCRIPTION
 |              Insert the a corresponding record into requst log.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_interface_rec
 |                    p_request_log_id
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure do_create_request_log(
        p_interface_rec         IN      HZ_PARTY_INTERFACE%ROWTYPE,
        l_request_log_id        OUT NOCOPY     NUMBER
) IS PRAGMA AUTONOMOUS_TRANSACTION;

        l_party_interface_id    NUMBER;

BEGIN
	INSERT INTO hz_dnb_request_log(
           REQUEST_ID,
           PARTY_ID,
           REQUESTED_PRODUCT,
           DUNS_NUMBER,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE )
        VALUES(
           HZ_DNB_REQUEST_LOG_S.nextval,
           p_interface_rec.PARTY_ID,
           p_interface_rec.GDP_NAME,
           p_interface_rec.DUNS_NUMBER,
           hz_utility_v2pub.CREATED_BY,
           hz_utility_v2pub.CREATION_DATE,
           hz_utility_v2pub.LAST_UPDATED_BY,
           hz_utility_v2pub.LAST_UPDATE_DATE )
        RETURNING REQUEST_ID INTO l_request_log_id;

	UPDATE hz_party_interface
        SET    REQUEST_LOG_ID = l_request_log_id
        WHERE  party_interface_id = p_interface_rec.party_interface_id;

	COMMIT;

END do_create_request_log;

/*===========================================================================+
 | PROCEDURE
 |              do_update_request_log
 |
 | DESCRIPTION
 |              update the a corresponding record in requst log.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_interface_rec
 |                    p_request_log_id
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/
procedure do_update_request_log(
        p_request_log_id        IN      NUMBER,
        p_party_id              IN      NUMBER,
        p_status                IN      VARCHAR2
) IS PRAGMA AUTONOMOUS_TRANSACTION;

        l_request_id            NUMBER;

BEGIN

        UPDATE hz_dnb_request_log
        SET  PARTY_ID = p_party_id,
             STATUS   = p_status,
             LAST_UPDATED_BY = hz_utility_v2pub.LAST_UPDATED_BY,
             LAST_UPDATE_DATE = hz_utility_v2pub.LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN = hz_utility_v2pub.LAST_UPDATE_LOGIN
        WHERE REQUEST_ID = p_request_log_id;

        COMMIT;

END do_update_request_log;

/*===========================================================================+
 | PROCEDURE
 |              map
 |
 | DESCRIPTION
 |              Map DNB info. stored in party interface table into
 |              HZ tables.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_group_id
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |           IN/OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |       DUNS and ENQUIRY DUNS (see DNB Content HLD)
 |         In countries outside of North America, DNB does not keep
 |         information abt a Branch location. If the user requests for
 |         a party which is a Branch it actually reurns back data for
 |         its HQ. In such a case, DUNS has the HQ DUNS and the
 |         ENQUIRY DUNS has the DUNS of the party (Branch that you
 |         requested). In North America, DUNS and ENQUIRY DUNS have
 |         the same values as DNB has Branch info. as well.
 |
 |         So party interface stores:
 |           o Origianl info. of the asking duns if DUNS = ENQUIRY DUNS
 |           o HQ info. of the asking duns if DUNS <> ENQUIRY DUNS.
 |                and ENQUIRY DUNS stores the asking duns.
 |
 |         When DUNS = ENQUIRY DUNS, we need to use the current row in
 |         party interface table to:
 |           o If it is a new party, we create 'USER_ENTERED' and 'DNB'
 |             organization profiles and party sites (through DNB
 |             location). We also need to create other DNB related info.
 |             like credit ratings, financial reports etc.
 |           o If it is an existing party, update corresponding 'DNB'
 |             info. for this party.
 |
 |         When DUNS <> ENQUIRY DUNS, we need to use the current row in
 |         party interface table to:
 |           o Create/update HQ party. We create 'USER_ENTERED' and 'DNB'
 |             organization profiles and party sites (through DNB location)
 |             and other DNB stuff if HQ party do not exist. Otherwise, we
 |             update HQ DNB info.
 |           o Create/update BRANCH party. We create 'USER_ENTERED' and
 |             'DNB' organization profiles.
 |           o Create/update party relationship between HQ and BRANCH.
 |
 | MODIFICATION HISTORY
 |
 |  19-AUG-2004  Rajib Ranjan Borah   o Bug 3107162. Added call to
 |                                      rectify_error_fields
 |                                    o Status in HZ_PARTY_INTERFACE will
 |                                      be set to W1 and not P1 if any column
 |                                      value passed by DNB is invalid.
 |                                    o IF G_ERROR_FLAG = 'Y', push message
 |                                      HZ_DNB_INVALID_NULL to stack.
 |  14-OCT-2004  Sravanthi A          o Bug 3107162: Added local variable to store
 |                                      p_inactivate_flag and make it 'Y' if
 |                                      passed value is NULL.
 +===========================================================================*/

procedure map(
	p_api_version   	IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN 	VARCHAR2:= FND_API.G_FALSE,
	p_group_id		IN	NUMBER := NULL,
	x_return_status 	OUT NOCOPY     VARCHAR2,
	x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2,
        p_inactivate_flag       IN      VARCHAR2, --4227564 := 'Y',
        p_validation_level      IN      NUMBER:= FND_API.G_VALID_LEVEL_FULL

) IS
        l_api_name              CONSTANT VARCHAR2(30) := 'map';
        l_api_version           CONSTANT  NUMBER       := 1.0;

	CURSOR c1 IS
	SELECT  * FROM
	HZ_PARTY_INTERFACE
	WHERE NVL(group_id, FND_API.G_MISS_NUM) = NVL(p_group_id, FND_API.G_MISS_NUM)
	AND status = 'N';

	l_interface_rec         HZ_PARTY_INTERFACE%ROWTYPE;
	l_organization_rec      HZ_PARTY_V2PUB.organization_rec_type;
	l_party_rel_rec         HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
	l_location_rec		HZ_LOCATION_V2PUB.location_rec_type;

	l_displayed_duns_party_id	NUMBER := NULL;
	l_party_id		NUMBER := NULL;
        l_original_party_id     NUMBER;
        l_final_party_id        NUMBER;
	l_count			NUMBER;
	l_duns_number		VARCHAR2(30);
	num_of_rec		NUMBER := 0;

	l_organization_profile_id	NUMBER;

        l_policy_exist          VARCHAR2(10);
        l_exist                 VARCHAR2(1);
        l_result                BOOLEAN;
        l_relationship_exist    BOOLEAN := FALSE;
	l_orig_system_reference VARCHAR2(240);
--	l_update_third_party    VARCHAR2(1);
        l_mixnmatch_global_id   NUMBER;
        l_user_data_creation_rule_id    varchar2(100);

	--bug 3107162: local variable to store p_inactivate_flag
	l_inactivate_flag       VARCHAR2(1) := p_inactivate_flag;
	l_any_rectification_in_batch BOOLEAN:= FALSE;
BEGIN
        --Bug 3107162: When null is passed for p_inactivate_flag make it 'Y'
	--4227564 commented this code
        /*IF p_inactivate_flag IS NULL
	THEN
	   l_inactivate_flag := 'Y';
	END IF;*/
	--end of bug 3107162

        --Bug 1772241: Add policies if this is the
        --first time user uses DNB

        l_policy_exist := FND_PROFILE.VALUE_WNPS('HZ_DNB_POLICY_EXIST');
        IF l_policy_exist IS NULL OR l_policy_exist <> 'Y' THEN
           do_add_policy_function;

           l_result := FND_PROFILE.SAVE('HZ_DNB_POLICY_EXIST', 'Y', 'SITE');
           IF NOT l_result THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           --Cache profile in current session
           l_policy_exist := FND_PROFILE.VALUE('HZ_DNB_POLICY_EXIST');

        END IF;

        hz_common_pub.disable_cont_source_security;
--	l_update_third_party := NVL(FND_PROFILE.value('HZ_UPDATE_THIRD_PARTY_DATA'), 'N');
	-- set the profile to allow dnb data updatable
--	FND_PROFILE.put('HZ_UPDATE_THIRD_PARTY_DATA', 'Y');

	-- disable user data creation rule
	l_user_data_creation_rule_id := fnd_profile.value('HZ_USER_DATA_CREATION_RULE');
	if l_user_data_creation_rule_id is not null then
            fnd_profile.put('HZ_USER_DATA_CREATION_RULE',null);
        end if;

--	isMixNMatchEnabled := HZ_MIXNM_UTILITY.isMixNMatchEnabled('HZ_ORGANIZATION_PROFILES', l_mixnmatch_global_id);
--        arp_util.debug('isMixNMatchEnabled=' || isMixNMatchEnabled);

        arp_util.debug('HZ_MAP_PARTY_PUB.MAP (+) ');

        --Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

       --
       --Process records one by one.
       --

         OPEN c1;
         LOOP
          BEGIN
           FETCH c1 INTO l_interface_rec;
           EXIT WHEN c1%NOTFOUND;


       num_of_rec := num_of_rec + 1;
       arp_util.debug('HZ_MAP_PARTY_PUB.MAP: fetched record from cursor: num_of_rec = '|| to_char(num_of_rec));
-- Bug 3220024 : Donot reset session related variables inside the cursor

       l_displayed_duns_party_id := NULL;
       l_party_id		 := NULL;
       l_original_party_id       := NULL;
       l_final_party_id          := NULL;
       l_duns_number             := NULL;
       l_organization_profile_id := NULL;
--       l_policy_exist            := NULL;
       l_exist                   := NULL;
--       l_result                  := NULL;
       l_relationship_exist      := FALSE;
       --l_orig_system_reference   := NULL;
--       l_update_third_party      := NULL;
--       l_mixnmatch_global_id     := NULL;
--       l_user_data_creation_rule_id    := NULL;

       --Set SAVEPOINT.
           SAVEPOINT map_pub;

       --MOSR Changes
       --If p_inactivate_flag is 'Y' then in activate Source System mapping
       -- for HZ_PARTIES, HZ_PARTY_SITES and HZ_CONTACT_POINTS
       --bug 3107162: Passed local variable l_inactivate flag instead of p_inactivate_flag
       --bug 4287144: pass enquiry duns
        check_mosr_mapping (
                lpad(to_char(nvl(l_interface_rec.enquiry_duns,l_interface_rec.duns_number)),9,'0'),
		l_interface_rec.party_id,
		--p_inactivate_flag,
                l_inactivate_flag,
                x_return_status,
                x_msg_count,
                x_msg_data
        );

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END IF;
       --
       --Create a row in hz_dnb_request_log if request_log_id is NULL
       --

       IF l_interface_rec.request_log_id IS NULL THEN

           do_create_request_log(l_interface_rec,
                                 l_interface_rec.request_log_id );
       END IF;

       -- Bug 3107162
       rectify_error_fields(l_interface_rec);

       --Bug 2802598: verify whether the lookups sent by DNB are correct. Call create_dynamic_lookups
       create_dynamic_lookups(
           p_party_interface_rec        =>      l_interface_rec,
           x_return_status              =>      x_return_status
           );

       --store original party id. The party id will be used to update
       --hz_dnb_request_log
       --store original and final party id.
       l_original_party_id := l_interface_rec.party_id;
       l_final_party_id := l_original_party_id;

       --Decide if the data in party interface is for HQ or is real data we want.
       --
       IF l_interface_rec.DUNS_NUMBER = l_interface_rec.ENQUIRY_DUNS
          OR l_interface_rec.ENQUIRY_DUNS IS NULL
       THEN

          --DNB has provided original party's data
          arp_util.debug('HZ_MAP_PARTY_PUB.MAP: DUNS = ENQUIRY_DUNS');

          --Create  DNB data
          --Create  USER_ENTERED data if the party doesn't exist

          arp_util.debug('HZ_MAP_PARTY_PUB.MAP: create DNB data, create USER_ENTERED data if party not exist');
          do_map(
                l_interface_rec,
                x_return_status
          );
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END IF;

	  IF l_final_party_id IS NULL THEN
             l_final_party_id := l_interface_rec.party_id;

             update hz_party_interface set party_id = l_final_party_id
             where party_interface_id = l_interface_rec.party_interface_id;
          END IF;

       ELSE

          arp_util.debug('HZ_MAP_PARTY_PUB.MAP: DUNS <> ENQUIRY_DUNS');
          --Party requested is a Branch location. DNB has provided HQ's data.

          --Since this is a HQ, store it as HQ.
          l_interface_rec.HQ_BRANCH_IND := 'HQ';

          --Check if party with DUNS as HQ's DUNS exists.
          --Need to check the DUNS in the latest record because
          --DUNS might have changed over time.

          BEGIN
             SELECT 'Y' INTO l_exist
             FROM   hz_organization_profiles
             --  Bug 4956756 : use DUNS_NUMBER_C
             WHERE  DUNS_NUMBER_C = lpad(to_char(l_interface_rec.DUNS_NUMBER), 9, '0')
             AND    actual_content_source = l_interface_rec.content_source_type
             AND    (SYSDATE BETWEEN effective_start_date
             AND    NVL(effective_end_date, to_date('12/31/4712','MM/DD/YYYY')))
             AND    ROWNUM=1;

          EXCEPTION

             WHEN NO_DATA_FOUND THEN
                l_exist := 'N';
          END;

          IF l_exist = 'N' THEN
             arp_util.debug('HZ_MAP_PARTY_PUB.MAP: DUNS <> ENQUIRY_DUNS: no party exists for HQs DUNS');

             --no party exists with DUNS as HQ's DUNS.
             --create new party for HQ DUNS. And organization profiles with
               --   USER_ENTERED
               --   DNB

             l_interface_rec.party_id := null;
	     l_organization_rec.party_rec.orig_system_reference := l_interface_rec.orig_system_reference;
             --l_interface_rec.orig_system_reference := NULL;

             --Create new party and do mapping.
             arp_util.debug('HZ_MAP_PARTY_PUB.MAP: create DNB and USER_ENTERED data for HQ (+)');
             do_map(
                   l_interface_rec,
                   x_return_status
             );

             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
             END IF;

             arp_util.debug('HZ_MAP_PARTY_PUB.MAP: create  DNB and USER_ENTERED data for HQ (-)');

             l_displayed_duns_party_id := l_interface_rec.party_id;
          ELSE
             --party exists with DUNS as HQ's DUNS.

	     arp_util.debug('HZ_MAP_PARTY_PUB.MAP: DUNS <> ENQUIRY_DUNS: party exists for HQs DUNS (+)');

             IF l_original_party_id IS NOT NULL THEN    /*Branch party exists. */

             --Branch party exists.
             BEGIN

                   SELECT displayed_duns_party_id
                   INTO   l_displayed_duns_party_id
                   FROM   hz_organization_profiles
                   WHERE  party_id = l_original_party_id
                   AND    actual_content_source = l_interface_rec.content_source_type
                   AND    (SYSDATE BETWEEN effective_start_date
                   AND    NVL(effective_end_date, to_date('12/31/4712','MM/DD/YYYY')));

                   arp_util.debug('HZ_MAP_PARTY_PUB.MAP: party exists for HQs DUNS: org profile for Branch exists');

                   --DNB org profile for Branch exists. Check if HQ DUNS = DUNS of
                   --Branch's displayed_duns_party_id.

                   IF l_displayed_duns_party_id IS NOT NULL THEN

                      SELECT duns_number_c INTO l_duns_number
                      FROM   hz_organization_profiles
                      WHERE  party_id = l_displayed_duns_party_id
                      AND    actual_content_source = l_interface_rec.content_source_type
                      AND    (SYSDATE BETWEEN effective_start_date
                      AND    NVL(effective_end_date, to_date('12/31/4712','MM/DD/YYYY')));

		      IF lpad(to_char(l_interface_rec.DUNS_NUMBER),9,'0') = l_duns_number THEN
                         arp_util.debug('HZ_MAP_PARTY_PUB.MAP: branchs DISPLAYED_DUNS_NUMBER = HQs DUNS_NUMBER');
                         l_relationship_exist := TRUE;
                      ELSE
                         arp_util.debug('HZ_MAP_PARTY_PUB.MAP: branchs DISPLAYED_DUNS_NUMBER <> HQs DUNS_NUMBER ');
                         l_displayed_duns_party_id := NULL;

                         --don't need to check  in party rel for HQ because it
                         --should give the same record as l_displayed_duns_party_id.
                      END IF;

                   END IF;

                EXCEPTION

                   WHEN NO_DATA_FOUND THEN
                        --org profile does not exist. i.e.
                        --DNB data does not exist, so partyrel also will not exist.

                       arp_util.debug('HZ_MAP_PARTY_PUB.MAP: party exists for HQs DUNS: org profile for Branch does not exist');

                       l_displayed_duns_party_id := NULL;
                END;

             END IF; /*Branch party exists. */

             IF l_displayed_duns_party_id IS NULL THEN

                --
                --We had confirmed earlier that party exists with DUNS as HQ's DUNS.
                --get party_id having DUNS as HQ DUNS having max(last_update_date)
                --as there may be multiple such parties.

                SELECT party_id
                INTO   l_displayed_duns_party_id
                FROM   hz_organization_profiles
                --  Bug 4956756 : use DUNS_NUMBER_C
                WHERE  DUNS_NUMBER_C = lpad(to_char(l_interface_rec.DUNS_NUMBER), 9, '0')
                AND    actual_content_source = l_interface_rec.content_source_type
                AND    ( SYSDATE BETWEEN effective_start_date
                AND    NVL(effective_end_date, to_date('12/31/4712','MM/DD/YYYY')))
                AND    last_update_date = (
                        SELECT max(last_update_date)
                        FROM   hz_organization_profiles
                        --  Bug 4956756 : use DUNS_NUMBER_C
                        WHERE  DUNS_NUMBER_C = lpad(to_char(l_interface_rec.DUNS_NUMBER), 9, '0')
                        AND    actual_content_source = l_interface_rec.content_source_type
                        AND    (SYSDATE BETWEEN effective_start_date
                        AND    NVL(effective_end_date, to_date('12/31/4712','MM/DD/YYYY'))))
                AND    ROWNUM = 1;

                arp_util.debug('HZ_MAP_PARTY_PUB.MAP: new l_displayed_duns_party_id=' || l_displayed_duns_party_id);
             END IF;

	     --bug 4287144: call check mosr_mapping for duns_number when duns<>enquiry_duns

		check_mosr_mapping (
			lpad(to_char(l_interface_rec.duns_number),9,'0'),
			l_displayed_duns_party_id,
			--p_inactivate_flag,
			l_inactivate_flag,
			x_return_status,
			x_msg_count,
			x_msg_data
		);

		IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		    RAISE FND_API.G_EXC_ERROR;
		ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
		END IF;

	     --Update HQ's DNB info.
             l_interface_rec.party_id := l_displayed_duns_party_id;
	     l_orig_system_reference := l_interface_rec.orig_system_reference;
             --l_interface_rec.orig_system_reference := NULL;

             arp_util.debug('HZ_MAP_PARTY_PUB.MAP: update DNB for HQs');

             do_map(
                 l_interface_rec,
                 x_return_status
             );

             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
             END IF;

	     l_interface_rec.orig_system_reference :=  l_orig_system_reference;

          END IF; /*party exists with DUNS as HQ's DUNS. */

          --create/ update party/ org profile for the branch party.
          --We need to create org profile as actual_content_source =
          --   USER_ENTERED
          --   DNB

          arp_util.debug('HZ_MAP_PARTY_PUB.MAP: DUNS <> ENQUIRY_DUNS: create/ update party/org profile for the original party');

          l_organization_rec.party_rec.party_id := l_original_party_id;
	  --bug 4287144: pass padded duns_number to make it 9 in length
          --l_organization_rec.DUNS_NUMBER_C := l_interface_rec.ENQUIRY_DUNS;
          l_organization_rec.DUNS_NUMBER_C := lpad(to_char(l_interface_rec.ENQUIRY_DUNS),9,'0');
          l_organization_rec.DISPLAYED_DUNS_PARTY_ID := l_displayed_duns_party_id;
          l_organization_rec.organization_name := l_interface_rec.party_name;
          l_organization_rec.party_rec.orig_system_reference := l_interface_rec.orig_system_reference;
          l_organization_rec.actual_content_source := l_interface_rec.content_source_type;
          l_organization_rec.created_by_module :=  'TCA_DNB_MAPPING';
          l_organization_rec.party_rec.party_number := null;

          store_org(
               l_organization_rec,
               l_organization_profile_id,
               x_return_status
          );

	  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END IF;

          l_final_party_id := l_organization_rec.party_rec.party_id;

	  --bug 4287144
	  IF l_original_party_id is not null THEN
               check_new_duns(l_organization_rec,x_return_status);
	        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	           return;
		END IF;
	  END IF;

          IF NOT l_relationship_exist THEN

             --create party rel b/w the new party (HQ) and original party.
             --Require this because through GDPs, we may not get back Family Tree.

             arp_util.debug('HZ_MAP_PARTY_PUB.MAP: DUNS <> ENQUIRY_DUNS:  create party rel b/w the new party (HQ) and original party');

             l_party_rel_rec.subject_id := l_displayed_duns_party_id;
             l_party_rel_rec.object_id := l_final_party_id;
	     l_party_rel_rec.relationship_type := 'HEADQUARTERS/DIVISION';
             l_party_rel_rec.relationship_code := 'HEADQUARTERS_OF';
             l_party_rel_rec.actual_content_source := l_interface_rec.content_source_type;
             l_party_rel_rec.subject_type := 'ORGANIZATION';
             l_party_rel_rec.object_type := 'ORGANIZATION';
             l_party_rel_rec.subject_table_name := 'HZ_PARTIES';
             l_party_rel_rec.object_table_name := 'HZ_PARTIES';
             l_party_rel_rec.created_by_module := 'TCA_DNB_MAPPING';

             store_party_rel(
                  l_party_rel_rec,
                  x_return_status
             );

	     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
             END IF;

          END IF;

       END IF;

      -- Bug 5554518
      IF l_interface_rec.ENQUIRY_DUNS IS NOT NULL
         AND l_interface_rec.DUNS_NUMBER <> l_interface_rec.ENQUIRY_DUNS
      THEN
            l_final_party_id := l_displayed_duns_party_id;
      END IF;


      --
      --Check return status.
      --

      IF x_return_status = 'S' THEN
          IF G_ERROR_FLAG = 'N' THEN -- Bug 3107162
              UPDATE hz_party_interface
              SET    status = 'P1',
                     party_id = l_final_party_id -- Bug 5440525
              WHERE  party_interface_id = l_interface_rec.party_interface_id;
	  ELSE
              UPDATE hz_party_interface
              SET    status = 'W1',
                     party_id = l_final_party_id -- Bug 5440525
              WHERE  party_interface_id = l_interface_rec.party_interface_id;
	      l_any_rectification_in_batch := TRUE;
	  END IF;

	  do_update_request_log(
             l_interface_rec.request_log_id,
             l_interface_rec.party_id,
             'S1' );
          IF FND_API.to_Boolean(p_commit) THEN
              commit;
          END IF;

      ELSE
        ROLLBACK to map_pub;
        --  need to rollback the successful transactions for this record prior to failure.

	do_update_request_log(
           l_interface_rec.request_log_id,
           l_original_party_id,
           'E1' );

	store_error(
        	p_status => 'E1',
        	p_party_interface_id => l_interface_rec.party_interface_id);

      END IF;

   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

		ROLLBACK TO map_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;

		arp_util.debug('HZ_MAP_PARTY_PUB.MAP: FND_API.G_EXC_ERROR');

                do_update_request_log(
                   l_interface_rec.request_log_id,
                   l_original_party_id,
                   'E1' );

                store_error(
                        p_status => 'E1',
                        p_party_interface_id => l_interface_rec.party_interface_id);

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO map_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		arp_util.debug('HZ_MAP_PARTY_PUB.MAP: G_EXC_UNEXPECTED_ERROR');

                do_update_request_log(
                   l_interface_rec.request_log_id,
                   l_original_party_id,
                   'E1' );

                store_error(
                        p_status => 'E1',
                        p_party_interface_id => l_interface_rec.party_interface_id);

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN

                ROLLBACK TO map_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		arp_util.debug('HZ_MAP_PARTY_PUB.MAP: OTHERS EXCEPTION');

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                do_update_request_log(
                   l_interface_rec.request_log_id,
                   l_original_party_id,
                   'E1' );

                store_error(
                        p_status => 'E1',
                        p_party_interface_id => l_interface_rec.party_interface_id);

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   END;

  END LOOP;
  CLOSE c1;



--
-- Store Related DUNS.
--

  store_related_duns(	p_commit,
			p_group_id,
			x_return_status);


-- Bug 3107162

IF l_any_rectification_in_batch THEN
              FND_MESSAGE.SET_NAME('AR','HZ_DNB_INVALID_NULL');
	      FND_MSG_PUB.ADD;
END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
arp_util.debug('HZ_MAP_PARTY_PUB.MAP (-)');

hz_common_pub.enable_cont_source_security;
--FND_PROFILE.put('HZ_UPDATE_THIRD_PARTY_DATA', l_update_third_party);

if l_user_data_creation_rule_id is not null then
fnd_profile.put('HZ_USER_DATA_CREATION_RULE',l_user_data_creation_rule_id);
end if;


END map;


procedure check_mosr_mapping (
        p_duns_number_c            IN            VARCHAR2,
	p_party_id    		   IN 		 VARCHAR2,
        p_inactivate_flag          IN            VARCHAR2,
        x_return_status            IN OUT NOCOPY VARCHAR2,
	x_msg_count                   OUT NOCOPY NUMBER,
        x_msg_data                    OUT NOCOPY VARCHAR2
) IS
        l_orig_sys_reference_rec HZ_ORIG_SYSTEM_REF_PUB.orig_sys_reference_rec_type;
        l_orig_system_ref_id    NUMBER;
        l_object_version_number NUMBER;
        l_start_date_active date;
        l_orig_system  HZ_ORIG_SYS_REFERENCES.orig_system%type;
        l_orig_system_reference  HZ_ORIG_SYS_REFERENCES.orig_system_reference%type;
        l_owner_table_name  HZ_ORIG_SYS_REFERENCES.owner_table_name%type;
        l_status varchar2(1);

        --MOSR Changes
	--4227564: Modified the cursors to check for records of other parties having same
	--orig_system_reference.
        CURSOR c_check_party_mapping
        IS
        SELECT  hosr.orig_system_ref_id,
                hosr.object_version_number,
                hosr.start_date_active,
                hosr.orig_system,
                hosr.orig_system_reference,
                hosr.owner_table_name
        FROM   -- hz_organization_profiles org_pro,
                hz_orig_sys_references hosr
        WHERE   -- nvl(org_pro.party_id, '-999') = hosr.owner_table_id AND
                hosr.orig_system = 'DNB'
        AND     hosr.owner_table_name = 'HZ_PARTIES'
        AND     trunc(nvl(hosr.end_date_active, sysdate)) >= trunc(sysdate)
        AND     hosr.status='A'
        AND     hosr.orig_system_reference = p_duns_number_c
        AND     hosr.party_id <> nvl(p_party_id,-1);
	--4227564

        CURSOR c_check_party_site_mapping
        IS
        SELECT  hosr.orig_system_ref_id,
                hosr.object_version_number,
                hosr.start_date_active,
                hosr.orig_system,
                hosr.orig_system_reference,
                hosr.owner_table_name
        FROM    --hz_party_sites ps,
                hz_orig_sys_references hosr
        WHERE   --nvl(ps.party_site_id, '-999') = hosr.owner_table_id
        --AND     ps.status = 'A' AND
             hosr.orig_system = 'DNB'
        AND     hosr.owner_table_name = 'HZ_PARTY_SITES'
        AND     trunc(nvl(hosr.end_date_active, sysdate)) >= trunc(sysdate)
        AND     hosr.status='A'
        AND     hosr.orig_system_reference like p_duns_number_c || '%'
        AND     hosr.party_id <> nvl(p_party_id,-1);
	--4227564

        CURSOR c_check_contact_point_mapping
        IS
        SELECT  hosr.orig_system_ref_id,
                hosr.object_version_number,
                hosr.start_date_active,
                hosr.orig_system,
                hosr.orig_system_reference,
                hosr.owner_table_name
        FROM   -- hz_contact_points cp,
                hz_orig_sys_references hosr
        WHERE   --nvl(cp.contact_point_id, '-999') = hosr.owner_table_id
--        AND     cp.status = 'A' AND
             hosr.orig_system = 'DNB'
        AND     hosr.owner_table_name = 'HZ_CONTACT_POINTS'
        AND     trunc(nvl(hosr.end_date_active, sysdate)) >= trunc(sysdate)
        AND     hosr.status='A'
        AND     hosr.orig_system_reference like p_duns_number_c || '%'
	AND     hosr.party_id <> nvl(p_party_id,-1);
	--4227564
BEGIN
     --Inactivate HZ_PARTIES records
      BEGIN
         OPEN c_check_party_mapping;

         FETCH c_check_party_mapping INTO  l_orig_system_ref_id, l_object_version_number, l_start_date_active,
                                     l_orig_system, l_orig_system_reference, l_owner_table_name;
         IF c_check_party_mapping%FOUND THEN
	 --4227564
         --  IF p_inactivate_flag = 'Y' THEN
             l_orig_sys_reference_rec.ORIG_SYSTEM_REF_ID := l_orig_system_ref_id;
             l_orig_sys_reference_rec.orig_system := l_orig_system;
             l_orig_sys_reference_rec.orig_system_reference := l_orig_system_reference;
             l_orig_sys_reference_rec.owner_table_name := l_owner_table_name;
             l_orig_sys_reference_rec.start_date_active := l_start_date_active;
             l_orig_sys_reference_rec.END_DATE_ACTIVE := sysdate;
             l_orig_sys_reference_rec.status := 'I';

             HZ_ORIG_SYSTEM_REF_PUB.update_orig_system_reference(
                 p_init_msg_list            => 'T',
                 p_orig_sys_reference_rec   => l_orig_sys_reference_rec,
                 p_object_version_number    => l_object_version_number,
                 x_return_status            => x_return_status,
                 x_msg_count                => x_msg_count,
                 x_msg_data                 => x_msg_data
             );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RETURN;
             END IF;
          -- END IF;
         END IF;
         CLOSE c_check_party_mapping;
       EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RETURN;
       END;


       --Inactivate HZ_PARTY_SITES records
       BEGIN

         OPEN c_check_party_site_mapping;
         LOOP
           FETCH c_check_party_site_mapping INTO  l_orig_system_ref_id, l_object_version_number, l_start_date_active,
                                                  l_orig_system, l_orig_system_reference, l_owner_table_name;

           EXIT WHEN c_check_party_site_mapping%NOTFOUND;
	  --4227564
          -- IF p_inactivate_flag = 'Y' THEN
             l_orig_sys_reference_rec.ORIG_SYSTEM_REF_ID := l_orig_system_ref_id;
             l_orig_sys_reference_rec.orig_system := l_orig_system;
             l_orig_sys_reference_rec.orig_system_reference := l_orig_system_reference;
             l_orig_sys_reference_rec.owner_table_name := l_owner_table_name;
             l_orig_sys_reference_rec.start_date_active := l_start_date_active;
             l_orig_sys_reference_rec.END_DATE_ACTIVE := sysdate;
             l_orig_sys_reference_rec.status := 'I';

             HZ_ORIG_SYSTEM_REF_PUB.update_orig_system_reference(
                 p_init_msg_list            => 'T',
                 p_orig_sys_reference_rec   => l_orig_sys_reference_rec,
                 p_object_version_number    => l_object_version_number,
                 x_return_status            => x_return_status,
                 x_msg_count                => x_msg_count,
                 x_msg_data                 => x_msg_data
             );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RETURN;
             END IF;

          -- END IF;
         END LOOP;
         CLOSE c_check_party_site_mapping;
       EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RETURN;
       END;

       --Inactivate HZ_CONTACT_POINTS records
       BEGIN
         OPEN c_check_contact_point_mapping;
         LOOP
           FETCH c_check_contact_point_mapping INTO  l_orig_system_ref_id, l_object_version_number, l_start_date_active,
                                                     l_orig_system, l_orig_system_reference, l_owner_table_name;

           EXIT WHEN c_check_contact_point_mapping%NOTFOUND;
	--4227564
          -- IF p_inactivate_flag = 'Y' THEN
             l_orig_sys_reference_rec.ORIG_SYSTEM_REF_ID := l_orig_system_ref_id;
             l_orig_sys_reference_rec.orig_system := l_orig_system;
             l_orig_sys_reference_rec.orig_system_reference := l_orig_system_reference;
             l_orig_sys_reference_rec.owner_table_name := l_owner_table_name;
             l_orig_sys_reference_rec.start_date_active := l_start_date_active;
             l_orig_sys_reference_rec.END_DATE_ACTIVE := sysdate;
             l_orig_sys_reference_rec.status := 'I';

             HZ_ORIG_SYSTEM_REF_PUB.update_orig_system_reference(
                 p_init_msg_list            => 'T',
                 p_orig_sys_reference_rec   => l_orig_sys_reference_rec,
                 p_object_version_number    => l_object_version_number,
                 x_return_status            => x_return_status,
                 x_msg_count                => x_msg_count,
                 x_msg_data                 => x_msg_data
             );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RETURN;
             END IF;
          -- END IF;
         END LOOP;
         CLOSE c_check_contact_point_mapping;
       EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       END;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_mosr_mapping;

-- Bug 3223595 : Added new procedure check_new_duns

PROCEDURE check_new_duns(
        p_organization_rec IN HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
        x_return_status OUT NOCOPY VARCHAR2
) IS

        l_orig_sys_reference_rec HZ_ORIG_SYSTEM_REF_PUB.orig_sys_reference_rec_type;
        l_orig_system_ref_id    NUMBER;
        l_object_version_number NUMBER;
        l_start_date_active date;
        l_orig_system  HZ_ORIG_SYS_REFERENCES.orig_system%type;
        l_orig_system_reference  HZ_ORIG_SYS_REFERENCES.orig_system_reference%type;
		l_orig_system_reference_p  HZ_ORIG_SYS_REFERENCES.orig_system_reference%type;
        l_owner_table_name  HZ_ORIG_SYS_REFERENCES.owner_table_name%type;
	l_owner_table_id  HZ_ORIG_SYS_REFERENCES.owner_table_id%type;
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(2000);
	p_duns_number_c VARCHAR2(10);
		--MOSR Changes
        CURSOR c_check_party_mapping
        IS
        SELECT  hosr.orig_system_ref_id,
                hosr.object_version_number,
                hosr.start_date_active,
                hosr.orig_system,
                hosr.orig_system_reference,
                hosr.owner_table_name,
		hosr.owner_table_id
        FROM
--hz_organization_profiles org_pro,
                hz_orig_sys_references hosr
        WHERE
--nvl(org_pro.party_id, '-999') = hosr.owner_table_id AND
		hosr.orig_system = 'DNB'
        AND     hosr.owner_table_name = 'HZ_PARTIES'
--        AND     trunc(nvl(hosr.end_date_active, sysdate)) >= trunc(sysdate)
        AND     hosr.status='A'
        AND     hosr.orig_system_reference <> p_duns_number_c
	AND	hosr.owner_table_id = p_organization_rec.party_rec.party_id;

        CURSOR c_check_party_site_mapping
        IS
        SELECT  hosr.orig_system_ref_id,
                hosr.object_version_number,
                hosr.start_date_active,
                hosr.orig_system,
                hosr.orig_system_reference,
                hosr.owner_table_name,
		hosr.owner_table_id
        FROM
--hz_party_sites ps,
                hz_orig_sys_references hosr
        WHERE
--nvl(ps.party_site_id, '-999') = hosr.owner_table_id AND
	     	hosr.orig_system = 'DNB'
        AND     hosr.owner_table_name = 'HZ_PARTY_SITES'
--        AND     trunc(nvl(hosr.end_date_active, sysdate)) >= trunc(sysdate)
        AND     hosr.status='A'
	AND	hosr.party_id = p_organization_rec.party_rec.party_id
        AND     hosr.orig_system_reference not like p_duns_number_c || '%';

        CURSOR c_check_contact_point_mapping
        IS
        SELECT  hosr.orig_system_ref_id,
                hosr.object_version_number,
                hosr.start_date_active,
                hosr.orig_system,
                hosr.orig_system_reference,
                hosr.owner_table_name,
		hosr.owner_table_id
        FROM
--hz_contact_points cp,
                hz_orig_sys_references hosr
        WHERE
--nvl(cp.contact_point_id, '-999') = hosr.owner_table_id AND
		hosr.orig_system = 'DNB'
        AND     hosr.owner_table_name = 'HZ_CONTACT_POINTS'
--        AND     trunc(nvl(hosr.end_date_active, sysdate)) >= trunc(sysdate)
        AND     hosr.status='A'
	AND	hosr.party_id = p_organization_rec.party_rec.party_id
        AND     hosr.orig_system_reference not like p_duns_number_c || '%';

BEGIN
     --bug 4287144
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     --Inactivate HZ_PARTIES records
      BEGIN
	p_duns_number_c := p_organization_rec.duns_number_c;

         OPEN c_check_party_mapping;

         FETCH c_check_party_mapping INTO  l_orig_system_ref_id, l_object_version_number, l_start_date_active,
                                     l_orig_system, l_orig_system_reference_p, l_owner_table_name,l_owner_table_id;
         IF c_check_party_mapping%FOUND THEN

             l_orig_sys_reference_rec.orig_system := l_orig_system;
             l_orig_sys_reference_rec.ORIG_SYSTEM_REF_ID := null;
             l_orig_sys_reference_rec.orig_system_reference := p_duns_number_c;
             l_orig_sys_reference_rec.owner_table_name := l_owner_table_name;
             l_orig_sys_reference_rec.owner_table_id := l_owner_table_id;
             l_orig_sys_reference_rec.start_date_active := sysdate;
             l_orig_sys_reference_rec.END_DATE_ACTIVE := NULL;
             l_orig_sys_reference_rec.party_id := p_organization_rec.party_rec.party_id;
             l_orig_sys_reference_rec.status := 'A';
             l_orig_sys_reference_rec.created_by_module := 'TCA_DNB_MAPPING';
             l_orig_sys_reference_rec.old_orig_system_reference := l_orig_system_reference_p;

             hz_orig_system_ref_pub.create_orig_system_reference(
				FND_API.G_FALSE,
				l_orig_sys_reference_rec,
				x_return_status,
				l_msg_count,
				l_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RETURN;
             END IF;

       --Inactivate HZ_PARTY_SITES records
       BEGIN
         OPEN c_check_party_site_mapping;
         LOOP
           FETCH c_check_party_site_mapping INTO  l_orig_system_ref_id, l_object_version_number, l_start_date_active,
                                                  l_orig_system, l_orig_system_reference, l_owner_table_name, l_owner_table_id;

           EXIT WHEN c_check_party_site_mapping%NOTFOUND;

              l_orig_sys_reference_rec.orig_system := l_orig_system;
              l_orig_sys_reference_rec.ORIG_SYSTEM_REF_ID := null;
              l_orig_sys_reference_rec.orig_system_reference := p_duns_number_c||substr(l_orig_system_reference, length(l_orig_system_reference_p)+1);
              l_orig_sys_reference_rec.owner_table_name := l_owner_table_name;
              l_orig_sys_reference_rec.owner_table_id := l_owner_table_id;
              l_orig_sys_reference_rec.start_date_active := sysdate;
              l_orig_sys_reference_rec.END_DATE_ACTIVE := NULL;
              l_orig_sys_reference_rec.party_id := p_organization_rec.party_rec.party_id;
              l_orig_sys_reference_rec.status := 'A';
              l_orig_sys_reference_rec.created_by_module := 'TCA_DNB_MAPPING';

              l_orig_sys_reference_rec.old_orig_system_reference := l_orig_system_reference;
              hz_orig_system_ref_pub.create_orig_system_reference(
				FND_API.G_FALSE,
				l_orig_sys_reference_rec,
				x_return_status,
				l_msg_count,
				l_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RETURN;
             END IF;
         END LOOP;
         CLOSE c_check_party_site_mapping;
       EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RETURN;
       END;

       --Inactivate HZ_CONTACT_POINTS records
       BEGIN
         OPEN c_check_contact_point_mapping;
         LOOP
           FETCH c_check_contact_point_mapping INTO  l_orig_system_ref_id, l_object_version_number, l_start_date_active,
                                                     l_orig_system, l_orig_system_reference, l_owner_table_name,l_owner_table_id;

           EXIT WHEN c_check_contact_point_mapping%NOTFOUND;
                l_orig_sys_reference_rec.orig_system := l_orig_system;
                l_orig_sys_reference_rec.ORIG_SYSTEM_REF_ID := null;
                l_orig_sys_reference_rec.orig_system_reference := p_duns_number_c||substr(l_orig_system_reference, length(l_orig_system_reference_p)+1);
                l_orig_sys_reference_rec.owner_table_name := l_owner_table_name;
                l_orig_sys_reference_rec.owner_table_id := l_owner_table_id;
                l_orig_sys_reference_rec.start_date_active := sysdate;
                l_orig_sys_reference_rec.END_DATE_ACTIVE := NULL;
                l_orig_sys_reference_rec.party_id := p_organization_rec.party_rec.party_id;
                l_orig_sys_reference_rec.status := 'A';
                l_orig_sys_reference_rec.created_by_module := 'TCA_DNB_MAPPING';
                l_orig_sys_reference_rec.old_orig_system_reference := l_orig_system_reference;
                hz_orig_system_ref_pub.create_orig_system_reference(
				FND_API.G_FALSE,
				l_orig_sys_reference_rec,
				x_return_status,
				l_msg_count,
				l_msg_data);

               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RETURN;
               END IF;
         END LOOP;
         CLOSE c_check_contact_point_mapping;
       EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RETURN;
       END;
 END IF;
         CLOSE c_check_party_mapping;
       EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       END;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
end check_new_duns;


/*===========================================================================+
 | PROCEDURE
 |              do_map
 |
 | DESCRIPTION
 |              Create necessary USER_ENTERED/DNB data for new party and
 |              map DNB data for this party.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_content_source_type
 |                    p_store_orig_system_ref
 |              OUT:
 |          IN/ OUT:
 |                    p_interface_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure do_map(
        p_interface_rec	        IN OUT NOCOPY    HZ_PARTY_INTERFACE%ROWTYPE,
        x_return_status         IN OUT NOCOPY    VARCHAR2
) IS
	l_organization_rec      HZ_PARTY_V2PUB.organization_rec_type;
	l_location_rec          hz_location_v2pub.location_rec_type;
	--l_credit_ratings_rec    hz_party_info_pub.credit_ratings_rec_type;
	l_credit_ratings_rec    hz_party_info_v2pub.credit_rating_rec_type;
	--l_fin_rep_rec           hz_org_info_pub.financial_reports_rec_type;
	l_fin_rep_rec           HZ_ORGANIZATION_INFO_V2PUB.financial_report_rec_type;
	--l_fin_num_rec           hz_org_info_pub.financial_numbers_rec_type;
	l_fin_num_rec           HZ_ORGANIZATION_INFO_V2PUB.financial_number_rec_type;
	l_contact_points_rec    hz_contact_point_v2pub.contact_point_rec_type;
	l_phone_rec     	hz_contact_point_v2pub.phone_rec_type := HZ_CONTACT_POINT_V2PUB.G_MISS_PHONE_REC;
        l_code_assignment_rec   hz_classification_v2pub.code_assignment_rec_type;
	l_organization_profile_id	NUMBER;
	l_is_new_party		BOOLEAN := FALSE;
	x_new_fin_report	VARCHAR2(1);

-- Bug 3223595 : Added local variable
	l_exist	VARCHAR2(1);

-- Bug 3492084 : Added orig_sys_reference_rec
	l_orig_sys_reference_rec HZ_ORIG_SYSTEM_REF_PUB.orig_sys_reference_rec_type;
	l_msg_count NUMBER;
	l_msg_data VARCHAR2(2000);
	l_orig_sys_ref_id NUMBER;

BEGIN

arp_util.debug('HZ_MAP_PARTY_PUB.DO_MAP (+) ');

--
-- Create party.
--

  do_assign_org_record(
		p_interface_rec,
		l_organization_rec);

  store_org(l_organization_rec,
	  l_organization_profile_id,
	  x_return_status);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RETURN;
  END IF;

  --
  --get back party_id from org rec
  --

  IF p_interface_rec.party_id IS NULL THEN
	p_interface_rec.party_id := l_organization_rec.party_rec.party_id;
	l_is_new_party := TRUE;
  END IF;


-- Bug 3223595 : Check if the party is enriched or it is new party
--               If it is update party, call check_new_duns to check
--               whether the duns number has changed and do MOSR table modifications.
-- START OF CODE

if(l_is_new_party = FALSE) THEN
	check_new_duns(l_organization_rec, x_return_status);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		return;
	end if;
end if;

-- END OF CODE FOR BUG 3223595

-- Bug 3492084 : While enriching a party, if there is no enrty in SSM table for
--		 this party, create an entry with passed duns_number.

if(l_is_new_party = FALSE) THEN
BEGIN
	SELECT  hosr.orig_system_ref_id INTO l_orig_sys_ref_id
        FROM 	hz_orig_sys_references hosr
        WHERE 	hosr.orig_system = 'DNB'
        AND     hosr.owner_table_name = 'HZ_PARTIES'
        AND     hosr.status='A'
        AND     hosr.owner_table_id = l_organization_rec.party_rec.party_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN

        l_orig_sys_reference_rec.orig_system := 'DNB';
        l_orig_sys_reference_rec.orig_system_reference := l_organization_rec.duns_number_c;
        l_orig_sys_reference_rec.owner_table_name := 'HZ_PARTIES';
	l_orig_sys_reference_rec.owner_table_id := l_organization_rec.party_rec.party_id;
        l_orig_sys_reference_rec.start_date_active := sysdate;
	l_orig_sys_reference_rec.party_id := l_organization_rec.party_rec.party_id;
        l_orig_sys_reference_rec.status := 'A';
        l_orig_sys_reference_rec.created_by_module := 'TCA_DNB_MAPPING';


	hz_orig_system_ref_pub.create_orig_system_reference(
			FND_API.G_FALSE,
			l_orig_sys_reference_rec,
			x_return_status,
			l_msg_count,
			l_msg_data);
	if x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RETURN;
        end if;
END;
end if;
 populate_to_classification(
        p_code_assignment_rec   => l_code_assignment_rec,
        p_interface_rec         => p_interface_rec,
--	p_is_new_party		=> l_is_new_party,
        x_return_status         => x_return_status
 );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RETURN;
  END IF;


  --
  -- Store Business Information Report.
  --

  IF p_interface_rec.GDP_NAME = 'BIR' THEN

      store_business_report(
	l_organization_profile_id,
       	p_interface_rec.business_report
      );

  END IF;


  --
  -- Create Location.
  --

  do_assign_location_record(
                    p_interface_rec,
                    l_location_rec);

  -- store actual_content_source = 'DNB'

  --MOSR Changes. Create MOSR mapping for Party_site
  l_location_rec.orig_system_reference := l_organization_rec.duns_number_c;
-- Bug 3417357 : pass l_is_new_party to store_location. l_is_new_party = TRUE
--		for new parties
  store_location( l_location_rec,
	p_interface_rec.party_id,
	l_is_new_party,
	x_return_status);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RETURN;
  END IF;
-- Bug 3070330 : Comment the code to store location for USER_ENTERED
/*
  IF  l_is_new_party  THEN
      -- store actual_content_source = 'USER ENTERED'
      l_location_rec.location_id := NULL;
      l_location_rec.actual_content_source := HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE;
      --MOSR Changes. Create MOSR mapping for Party_site
      l_location_rec.orig_system_reference := l_organization_rec.duns_number_c;
      store_location( l_location_rec,
          p_interface_rec.party_id,
          x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RETURN;
      END IF;
  END IF;
*/
  --
  -- Create contact points.
  --

  l_contact_points_rec.owner_table_id 	        :=    l_organization_rec.party_rec.party_id;
  l_phone_rec.PHONE_COUNTRY_CODE := LTRIM(p_interface_rec.PHONE_COUNTRY_CODE, '0');

  --MOSR Changes. Create MOSR mapping for contact_points
  l_contact_points_rec.ORIG_SYSTEM_REFERENCE :=  l_organization_rec.DUNS_NUMBER_C;

  --
  -- Create Phone.
  --

  --Don't need to check if l_phone_rec.RAW_PHONE_NUMBER is NULL here. This is being checked in store_contact_point. If this is null, and if it existed in database, needs to be updated to NULL.


  IF p_interface_rec.GDP_NAME <> 'BIR' THEN

      IF p_interface_rec.TELEPHONE_NUMBER IS NOT NULL THEN
          l_phone_rec.PHONE_LINE_TYPE     :=      'GEN';

          -- actual_content_source = 'DNB'
	  l_contact_points_rec.actual_content_source :=  p_interface_rec.content_source_type;
          l_phone_rec.RAW_PHONE_NUMBER    :=  p_interface_rec.TELEPHONE_NUMBER        ;
	  l_contact_points_rec.created_by_module := 'TCA_DNB_MAPPING';

          store_contact_point (
              l_contact_points_rec,
              l_phone_rec,
              x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RETURN;
          END IF;
      END IF;

      --
      -- Create Fax.
      --
      IF p_interface_rec.FAX_NUMBER IS NOT NULL THEN

          l_phone_rec.PHONE_LINE_TYPE     :=      'FAX';

          -- actual_content_source = 'DNB'
          l_contact_points_rec.contact_point_id    := NULL;
          l_contact_points_rec.ORIG_SYSTEM_REFERENCE :=  l_organization_rec.DUNS_NUMBER_C; /* Bug 6129275 */
          l_contact_points_rec.actual_content_source :=  p_interface_rec.content_source_type;
          l_phone_rec.RAW_PHONE_NUMBER             :=  p_interface_rec.FAX_NUMBER        ;
          l_phone_rec.PHONE_NUMBER             :=  NULL;
	  l_contact_points_rec.created_by_module   := 'TCA_DNB_MAPPING';

          store_contact_point (
              l_contact_points_rec,
              l_phone_rec,
              x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
          END IF;

      END IF;

      --
      -- Create credit ratings.
      --

      --Bug 1674651: Business Verification Product provide Credit Ratings.
      --Need to remove 'BIZ_VER' from NOT IN list.

      do_assign_credit_ratings(
	      p_interface_rec		  => p_interface_rec,
	      p_organization_rec      => l_organization_rec,
	      l_credit_ratings_rec    => l_credit_ratings_rec
      );

      -- actual_content_source = 'DNB'
      l_credit_ratings_rec.actual_content_source :=   p_interface_rec.content_source_type;

      store_credit_ratings(
        l_credit_ratings_rec,
        x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;

  END IF;   -- END IF p_interface_rec.GDP_NAME <> 'BIR'


   --
   -- Create Financial Reports.
   --

  IF p_interface_rec.GDP_NAME NOT IN ('BIZ_VER', 'BIR') THEN

  --Business Verification Product does not provide Financial info.

      do_assign_financial_report(
	p_interface_rec		   =>  	  p_interface_rec,
	l_fin_rep_rec              =>     l_fin_rep_reC,
        p_type_of_financial_report =>     'BALANCE_SHEET');

      arp_util.debug('HZ_MAP_PARTY_PUB.DO_MAP: BALANCE_SHEET');

      -- actual_content_source = 'DNB'

      store_financial_report(
        l_fin_rep_rec,
        p_interface_rec,
        x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
  END IF;


  --IF figures not null
	 	--Sales
		--Previous Sales
                --Cost of Sales
                --Gross Income
                --Profit Before Tax
                --Net Income
                --Dividends

  IF
  ( p_interface_rec.SALES IS NOT NULL
  OR p_interface_rec.PREVIOUS_SALES IS NOT NULL
  OR p_interface_rec.COST_OF_SALES IS NOT NULL
  OR p_interface_rec.GROSS_INCOME IS NOT NULL
  OR p_interface_rec.PROFIT_BEFORE_TAX IS NOT NULL
  OR p_interface_rec.NET_INCOME IS NOT NULL
  OR p_interface_rec.DIVIDENDS IS NOT NULL)
  THEN

      arp_util.debug('HZ_MAP_PARTY_PUB.DO_MAP: INCOME_STATEMENT');

      do_assign_financial_report(
	p_interface_rec		   =>  	  p_interface_rec,
	l_fin_rep_rec              =>     l_fin_rep_reC,
        p_type_of_financial_report =>     'INCOME_STATEMENT');

      -- actual_content_source = 'DNB'
      store_financial_report(
        l_fin_rep_rec,
        p_interface_rec,
        x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
  END IF;


  IF  p_interface_rec.TANGIBLE_NET_WORTH IS NOT NULL THEN

      arp_util.debug('HZ_MAP_PARTY_PUB.DO_MAP: TANGIBLE_NET_WORTH');

      do_assign_financial_report(
	p_interface_rec		   =>  	  p_interface_rec,
	l_fin_rep_rec              =>     l_fin_rep_reC,
        p_type_of_financial_report =>     'TANGIBLE_NET_WORTH');

      -- actual_content_source = 'DNB'
      store_financial_report(
        l_fin_rep_rec,
        p_interface_rec,
        x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
  END IF;


  IF p_interface_rec.ANNUAL_SALES_VOLUME IS NOT NULL THEN

      arp_util.debug('HZ_MAP_PARTY_PUB.DO_MAP: ANNUAL_SALES_VOLUME');

      do_assign_financial_report(
	p_interface_rec		   =>  	  p_interface_rec,
	l_fin_rep_rec              =>     l_fin_rep_reC,
        p_type_of_financial_report =>     'ANNUAL_SALES_VOLUME');

      -- actual_content_source = 'DNB'
      store_financial_report(
        l_fin_rep_rec,
        p_interface_rec,
        x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
  END IF;

  arp_util.debug('HZ_MAP_PARTY_PUB.DO_MAP (-)');

END do_map;


/*===========================================================================+
 | PROCEDURE
 |              do_assign_org_record
 |
 | DESCRIPTION
 |              assign interface data to org record.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_interface_rec
 |              OUT:
 |                    l_organization_rec
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure do_assign_org_record(
	p_interface_rec		IN OUT NOCOPY 	HZ_PARTY_INTERFACE%ROWTYPE,
	l_organization_rec	OUT NOCOPY	HZ_PARTY_V2PUB.organization_rec_type
) IS
BEGIN

-- set default value to SIC_CODE_TYPE when  purchase 'Commercial Credit Score' GDP
/* Bug 3107162. This is handled in rectify_error_fields
IF p_interface_rec.GDP_NAME = 'COMM_CREDIT_SCORE'  AND
     ( p_interface_rec.SIC_CODE1 is not null or
       p_interface_rec.SIC_CODE2 is not null or
       p_interface_rec.SIC_CODE3 is not null or
       p_interface_rec.SIC_CODE4 is not null or
       p_interface_rec.SIC_CODE5 is not null or
       p_interface_rec.SIC_CODE6 is not null  ) AND
     p_interface_rec.SIC_CODE_TYPE is null
  THEN
      p_interface_rec.SIC_CODE_TYPE := '1987 SIC';
      p_interface_rec.SIC_CODE1 := SUBSTRB(replace(p_interface_rec.SIC_CODE1, ' ', ''), 1, 4);
      p_interface_rec.SIC_CODE2 := SUBSTRB(replace(p_interface_rec.SIC_CODE2, ' ', ''), 1, 4);
      p_interface_rec.SIC_CODE3 := SUBSTRB(replace(p_interface_rec.SIC_CODE3, ' ', ''), 1, 4);
      p_interface_rec.SIC_CODE4 := SUBSTRB(replace(p_interface_rec.SIC_CODE4, ' ', ''), 1, 4);
      p_interface_rec.SIC_CODE5 := SUBSTRB(replace(p_interface_rec.SIC_CODE5, ' ', ''), 1, 4);
      p_interface_rec.SIC_CODE6 := SUBSTRB(replace(p_interface_rec.SIC_CODE6, ' ', ''), 1, 4);

  END IF;
*/
  l_organization_rec.party_rec.party_id   :=      p_interface_rec.party_id;
  IF l_organization_rec.displayed_duns_party_id = FND_API.G_MISS_NUM OR
     l_organization_rec.displayed_duns_party_id = NULL THEN
     l_organization_rec.displayed_duns_party_id := l_organization_rec.party_rec.party_id;
  END IF;
  l_organization_rec.DUNS_NUMBER_C        :=      lpad(to_char(p_interface_rec.DUNS_NUMBER),9,'0');
  l_organization_rec.ORGANIZATION_NAME    :=      p_interface_rec.PARTY_NAME;
  l_organization_rec.KNOWN_AS             :=      p_interface_rec.KNOWN_AS1;
  l_organization_rec.KNOWN_AS2            :=      p_interface_rec.KNOWN_AS2;
  l_organization_rec.KNOWN_AS3            :=      p_interface_rec.KNOWN_AS3;
  l_organization_rec.KNOWN_AS4            :=      p_interface_rec.KNOWN_AS4;
  l_organization_rec.KNOWN_AS5            :=      p_interface_rec.KNOWN_AS5;
  l_organization_rec.LOCAL_BUS_IDENTIFIER :=      p_interface_rec.LOCAL_BUS_IDENTIFIER;
  l_organization_rec.LOCAL_BUS_IDEN_TYPE  :=      p_interface_rec.LOCAL_BUS_IDEN_TYPE;
  l_organization_rec.PREF_FUNCTIONAL_CURRENCY     := p_interface_rec.PREF_FUNCTIONAL_CURRENCY;
  l_organization_rec.CONTROL_YR           :=      p_interface_rec.CONTROL_YR;
  l_organization_rec.INCORP_YEAR          :=      p_interface_rec.INCORP_YEAR;
  l_organization_rec.YEAR_ESTABLISHED     :=      p_interface_rec.YEAR_ESTABLISHED;
  l_organization_rec.EMPLOYEES_TOTAL      :=      p_interface_rec.EMPLOYEES_TOTAL;
  l_organization_rec.TOTAL_EMPLOYEES_TEXT :=      p_interface_rec.TOTAL_EMPLOYEES_TEXT;
  l_organization_rec.TOTAL_EMPLOYEES_IND  :=      p_interface_rec.TOTAL_EMPLOYEES_IND;
  l_organization_rec.TOTAL_EMP_EST_IND    :=      p_interface_rec.TOTAL_EMP_EST_IND;
  l_organization_rec.TOTAL_EMP_MIN_IND    :=      p_interface_rec.TOTAL_EMP_MIN_IND;
  l_organization_rec.EMP_AT_PRIMARY_ADR   :=      p_interface_rec.EMP_AT_PRIMARY_ADR;
  l_organization_rec.EMP_AT_PRIMARY_ADR_TEXT      :=      p_interface_rec.EMP_AT_PRIMARY_ADR_TEXT;
  l_organization_rec.EMP_AT_PRIMARY_ADR_EST_IND   :=      p_interface_rec.EMP_AT_PRIMARY_ADR_EST_IND;
  l_organization_rec.EMP_AT_PRIMARY_ADR_MIN_IND   :=      p_interface_rec.EMP_AT_PRIMARY_ADR_MIN_IND;

  l_organization_rec.SIC_CODE_TYPE      :=  p_interface_rec.SIC_CODE_TYPE;
  l_organization_rec.SIC_CODE           :=  p_interface_rec.SIC_CODE1;


/* Bug 3107162
  IF p_interface_rec.SIC_CODE_TYPE IN ('1972', '1977', '1987') THEN
    l_organization_rec.SIC_CODE_TYPE      :=  p_interface_rec.SIC_CODE_TYPE || ' SIC';
  END IF;


  IF l_organization_rec.SIC_CODE_TYPE IN ('1972 SIC', '1977 SIC', '1987 SIC') THEN
    l_organization_rec.SIC_CODE           := SUBSTRB(replace(p_interface_rec.SIC_CODE1, ' ', ''), 1, 4);
  END IF;
*/
  l_organization_rec.LOCAL_ACTIVITY_CODE  :=      p_interface_rec.LOCAL_ACTIVITY_CODE;
  l_organization_rec.LOCAL_ACTIVITY_CODE_TYPE     :=      p_interface_rec.LOCAL_ACTIVITY_CODE_TYPE;
  l_organization_rec.LINE_OF_BUSINESS     :=      p_interface_rec.LINE_OF_BUSINESS;
  l_organization_rec.PARENT_SUB_IND       :=      p_interface_rec.PARENT_SUB_IND;
  l_organization_rec.HQ_BRANCH_IND        :=      p_interface_rec.HQ_BRANCH_IND;
  /* Bug 3107162
  IF p_interface_rec.GDP_NAME = 'COMM_CREDIT_SCORE' THEN
       IF l_organization_rec.HQ_BRANCH_IND = 'H' THEN
          l_organization_rec.HQ_BRANCH_IND := 'HQ';
       ELSIF l_organization_rec.HQ_BRANCH_IND = 'B' THEN
          l_organization_rec.HQ_BRANCH_IND := 'BR';
       ELSIF l_organization_rec.HQ_BRANCH_IND = 'S' THEN
          l_organization_rec.HQ_BRANCH_IND := 'SL';
       END IF;
    END IF;
*/
  l_organization_rec.LEGAL_STATUS         :=      p_interface_rec.LEGAL_STATUS;
  l_organization_rec.REGISTRATION_TYPE    :=      p_interface_rec.REGISTRATION_TYPE;
  l_organization_rec.RENT_OWN_IND         :=      p_interface_rec.RENT_OWN_IND;
  l_organization_rec.CEO_NAME             :=      p_interface_rec.CEO_NAME;
  l_organization_rec.CEO_TITLE            :=      p_interface_rec.CEO_TITLE;
  l_organization_rec.PRINCIPAL_TITLE      :=      p_interface_rec.PRINCIPAL_TITLE;
  l_organization_rec.PRINCIPAL_NAME       :=      p_interface_rec.PRINCIPAL_NAME;
  l_organization_rec.TOTAL_PAYMENTS       :=      p_interface_rec.TOTAL_PAYMENTS;
  l_organization_rec.OOB_IND              :=      p_interface_rec.OOB_IND;
 /* Bug 3107162
 IF l_organization_rec.OOB_IND = 'OB' THEN
     l_organization_rec.OOB_IND              :=   'Y';
  END IF;
*/
  l_organization_rec.IMPORT_IND			:=      p_interface_rec.IMPORT_IND;
  l_organization_rec.EXPORT_IND		        :=      p_interface_rec.EXPORT_IND;
  l_organization_rec.BRANCH_FLAG                :=      p_interface_rec.BRANCH_FLAG;
  l_organization_rec.PARENT_SUB_IND             :=      p_interface_rec.PARENT_SUB_IND;
  l_organization_rec.CONG_DIST_CODE             :=      p_interface_rec.CONG_DIST_CODE1;
  l_organization_rec.LABOR_SURPLUS_IND          :=      p_interface_rec.LABOR_SURPLUS_IND;
  l_organization_rec.SMALL_BUS_IND              :=      p_interface_rec.SMALL_BUS_IND;
  l_organization_rec.WOMAN_OWNED_IND            :=      p_interface_rec.WOMAN_OWNED_IND;
  l_organization_rec.MINORITY_OWNED_IND         :=      p_interface_rec.MINORITY_OWNED_IND;
  l_organization_rec.DISADV_8A_IND              :=      p_interface_rec.DISADV_8A_IND;
  l_organization_rec.party_rec.ORIG_SYSTEM_REFERENCE := p_interface_rec.ORIG_SYSTEM_REFERENCE;
  l_organization_rec.DO_NOT_CONFUSE_WITH        :=      p_interface_rec.DO_NOT_CONFUSE_WITH;

-- the following column has been moved to credit rating. but we keep supporting these column
-- so do not populate to credit rating record directly
  l_organization_rec.DB_RATING                    :=  p_interface_rec.DB_RATING;
  l_organization_rec.AVG_HIGH_CREDIT              :=  p_interface_rec.AVG_HIGH_CREDIT;
  l_organization_rec.CREDIT_SCORE                 :=  p_interface_rec.CREDIT_SCORE;
  l_organization_rec.CREDIT_SCORE_AGE             :=  p_interface_rec.CREDIT_SCORE_AGE;
  l_organization_rec.CREDIT_SCORE_CLASS           :=  p_interface_rec.CREDIT_SCORE_CLASS;
  l_organization_rec.CREDIT_SCORE_COMMENTARY      :=  p_interface_rec.CREDIT_SCORE_COMMENTARY1;
  l_organization_rec.CREDIT_SCORE_COMMENTARY2     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY2;
  l_organization_rec.CREDIT_SCORE_COMMENTARY3     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY3;
  l_organization_rec.CREDIT_SCORE_COMMENTARY4     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY4;
  l_organization_rec.CREDIT_SCORE_COMMENTARY5     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY5;
  l_organization_rec.CREDIT_SCORE_COMMENTARY6     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY6;
  l_organization_rec.CREDIT_SCORE_COMMENTARY7     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY7;
  l_organization_rec.CREDIT_SCORE_COMMENTARY8     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY8;
  l_organization_rec.CREDIT_SCORE_COMMENTARY9     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY9;
  l_organization_rec.CREDIT_SCORE_COMMENTARY10    :=  p_interface_rec.CREDIT_SCORE_COMMENTARY10;
  l_organization_rec.CREDIT_SCORE_DATE            :=  p_interface_rec.CREDIT_SCORE_DATE;
  l_organization_rec.CREDIT_SCORE_INCD_DEFAULT    :=  p_interface_rec.CREDIT_SCORE_INCD_DEFAULT;
  l_organization_rec.CREDIT_SCORE_NATL_PERCENTILE :=  p_interface_rec.CREDIT_SCORE_NATL_PERCENTILE;
  l_organization_rec.FAILURE_SCORE                :=  p_interface_rec.FAILURE_SCORE;
  l_organization_rec.FAILURE_SCORE_COMMENTARY     :=  p_interface_rec.FAILURE_SCORE_COMMENTARY1;
  l_organization_rec.FAILURE_SCORE_COMMENTARY2    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY2;
  l_organization_rec.FAILURE_SCORE_COMMENTARY3    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY3;
  l_organization_rec.FAILURE_SCORE_COMMENTARY4    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY4;
  l_organization_rec.FAILURE_SCORE_COMMENTARY5    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY5;
  l_organization_rec.FAILURE_SCORE_COMMENTARY6    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY6;
  l_organization_rec.FAILURE_SCORE_COMMENTARY7    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY7;
  l_organization_rec.FAILURE_SCORE_COMMENTARY8    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY8;
  l_organization_rec.FAILURE_SCORE_COMMENTARY9    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY9;
  l_organization_rec.FAILURE_SCORE_COMMENTARY10   :=  p_interface_rec.FAILURE_SCORE_COMMENTARY10;
  l_organization_rec.FAILURE_SCORE_CLASS          :=  p_interface_rec.FAILURE_SCORE_CLASS;
  l_organization_rec.FAILURE_SCORE_NATNL_PERCENTILE :=  p_interface_rec.FAILURE_SCORE_NATL_PERCENTILE;
  l_organization_rec.FAILURE_SCORE_INCD_DEFAULT   :=  p_interface_rec.FAILURE_SCORE_INCD_DEFAULT;
  l_organization_rec.FAILURE_SCORE_AGE            :=  p_interface_rec.FAILURE_SCORE_AGE;
  l_organization_rec.FAILURE_SCORE_OVERRIDE_CODE  :=  p_interface_rec.FAILURE_SCORE_OVERRIDE_CODE;
  l_organization_rec.FAILURE_SCORE_DATE           :=  p_interface_rec.FAILURE_SCORE_DATE;
  l_organization_rec.GLOBAL_FAILURE_SCORE         :=  p_interface_rec.GLOBAL_FAILURE_SCORE;
  l_organization_rec.DEBARMENTS_COUNT             :=  p_interface_rec.DEBARMENTS_COUNT;
  l_organization_rec.DEBARMENTS_DATE              :=  p_interface_rec.DEBARMENTS_DATE;
  l_organization_rec.HIGH_CREDIT                  :=  p_interface_rec.HIGH_CREDIT;
  l_organization_rec.MAXIMUM_CREDIT_CURRENCY_CODE :=  p_interface_rec.MAX_CREDIT_CURRENCY;
  l_organization_rec.MAXIMUM_CREDIT_RECOMMENDATION :=  p_interface_rec.MAX_CREDIT_RECOMMEND;
  l_organization_rec.PAYDEX_NORM                  :=  p_interface_rec.PAYDEX_NORM;
  l_organization_rec.PAYDEX_SCORE                 :=  p_interface_rec.PAYDEX_SCORE;
  l_organization_rec.PAYDEX_THREE_MONTHS_AGO      :=  p_interface_rec.PAYDEX_THREE_MONTHS_AGO;


  l_organization_rec.CONTENT_SOURCE_NUMBER	:= 	to_char(p_interface_rec.DUNS_NUMBER);
  l_organization_rec.ACTUAL_CONTENT_SOURCE	:=	p_interface_rec.CONTENT_SOURCE_TYPE;
  l_organization_rec.created_by_module          :=      'TCA_DNB_MAPPING';
  --bug 4161092
  IF p_interface_rec.SALES IS NOT NULL THEN
     l_organization_rec.CURR_FY_POTENTIAL_REVENUE := p_interface_rec.SALES;
  ELSE
     --Bug 3770469 . Map annual_sales_volume passed by DNB to CURR_FY_POTENTIAL_REVENUE
     l_organization_rec.CURR_FY_POTENTIAL_REVENUE := p_interface_rec.ANNUAL_SALES_VOLUME;
     -- end of bug 3770469
  END IF;

END do_assign_org_record;


procedure do_assign_location_record(
        p_interface_rec         IN      HZ_PARTY_INTERFACE%ROWTYPE,
        l_location_rec      	OUT NOCOPY     hz_location_v2pub.location_rec_type
) IS
BEGIN

        l_location_rec.ADDRESS1         :=      NVL(p_interface_rec.ADDRESS1, 'Not provided by DNB');
        l_location_rec.ADDRESS2         :=      NVL(p_interface_rec.ADDRESS2, FND_API.G_MISS_CHAR);
        l_location_rec.ADDRESS3         :=      NVL(p_interface_rec.ADDRESS3, FND_API.G_MISS_CHAR);
        l_location_rec.ADDRESS4         :=      NVL(p_interface_rec.ADDRESS4, FND_API.G_MISS_CHAR);
        l_location_rec.CITY             :=      NVL(p_interface_rec.CITY, FND_API.G_MISS_CHAR);
        l_location_rec.STATE            :=      NVL(p_interface_rec.STATE, FND_API.G_MISS_CHAR);
        l_location_rec.COUNTY           :=      NVL(p_interface_rec.COUNTY, FND_API.G_MISS_CHAR);
        l_location_rec.POSTAL_CODE      :=      NVL(p_interface_rec.POSTAL_CODE, FND_API.G_MISS_CHAR);

        --Bug 1736056: Default country to 'US' if it is NULL. Convert
        --lower case to upper case.
        l_location_rec.COUNTRY          :=      NVL(UPPER(p_interface_rec.COUNTRY), G_DEFAULT_COUNTRY_CODE);

        l_location_rec.PROVINCE         :=      NVL(p_interface_rec.PROVINCE, FND_API.G_MISS_CHAR);
        l_location_rec.orig_system_reference := p_interface_rec.orig_system_reference;
        l_location_rec.actual_content_source  :=  p_interface_rec.content_source_type;
        l_location_rec.created_by_module := 'TCA_DNB_MAPPING';

END do_assign_location_record;

procedure do_assign_credit_ratings(
	p_interface_rec		IN 	HZ_PARTY_INTERFACE%ROWTYPE,
	p_organization_rec      IN      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
	--l_credit_ratings_rec    OUT NOCOPY     HZ_PARTY_INFO_PUB.CREDIT_RATINGS_REC_TYPE
	l_credit_ratings_rec    OUT NOCOPY     HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE
) IS
BEGIN
  arp_util.debug('HZ_MAP_PARTY_PUB.do_assign_credit_ratings (+) ');
    l_credit_ratings_rec.PARTY_ID                     :=  p_organization_rec.party_rec.party_id;
    l_credit_ratings_rec.RATED_AS_OF_DATE             :=  sysdate;
    l_credit_ratings_rec.RATING_ORGANIZATION          :=  'DNB';
    l_credit_ratings_rec.FINCL_EMBT_IND               :=  p_interface_rec.FINCL_EMBT_IND;
    l_credit_ratings_rec.FINCL_LGL_EVENT_IND          :=  p_interface_rec.FINCL_LGL_EVENT_IND;
    l_credit_ratings_rec.OPRG_SPEC_EVNT_IND           :=  p_interface_rec.OPRG_SPEC_EVNT_IND;
    l_credit_ratings_rec.OTHER_SPEC_EVNT_IND          :=  p_interface_rec.OTHER_SPEC_EVNT_IND;
    l_credit_ratings_rec.DET_HISTORY_IND              :=  p_interface_rec.DET_HISTORY_IND;
--  obsolete SUIT_JUDGE_IND
--  l_credit_ratings_rec.SUIT_JUDGE_IND               :=  p_interface_rec.SUIT_JUDGE_IND;
    l_credit_ratings_rec.CLAIMS_IND                   :=  p_interface_rec.CLAIMS_IND;
    l_credit_ratings_rec.SECURED_FLNG_IND             :=  p_interface_rec.SECURED_FLNG_IND;
    l_credit_ratings_rec.CRIMINAL_PROCEEDING_IND      :=  p_interface_rec.CRIMINAL_PROCEEDING_IND;
    l_credit_ratings_rec.DISASTER_IND                 :=  p_interface_rec.DISASTER_IND;
    l_credit_ratings_rec.ACTUAL_CONTENT_SOURCE        :=  p_interface_rec.CONTENT_SOURCE_TYPE;

-- the follow columns are migrated from org profile
    l_credit_ratings_rec.RATING                       :=  p_interface_rec.DB_RATING;
    l_credit_ratings_rec.AVG_HIGH_CREDIT              :=  p_interface_rec.AVG_HIGH_CREDIT;
    l_credit_ratings_rec.CREDIT_SCORE                 :=  p_interface_rec.CREDIT_SCORE;
    l_credit_ratings_rec.CREDIT_SCORE_AGE             :=  p_interface_rec.CREDIT_SCORE_AGE;
    l_credit_ratings_rec.CREDIT_SCORE_CLASS           :=  p_interface_rec.CREDIT_SCORE_CLASS;
    l_credit_ratings_rec.CREDIT_SCORE_COMMENTARY      :=  p_interface_rec.CREDIT_SCORE_COMMENTARY1;
    l_credit_ratings_rec.CREDIT_SCORE_COMMENTARY2     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY2;
    l_credit_ratings_rec.CREDIT_SCORE_COMMENTARY3     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY3;
    l_credit_ratings_rec.CREDIT_SCORE_COMMENTARY4     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY4;
    l_credit_ratings_rec.CREDIT_SCORE_COMMENTARY5     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY5;
    l_credit_ratings_rec.CREDIT_SCORE_COMMENTARY6     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY6;
    l_credit_ratings_rec.CREDIT_SCORE_COMMENTARY7     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY7;
    l_credit_ratings_rec.CREDIT_SCORE_COMMENTARY8     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY8;
    l_credit_ratings_rec.CREDIT_SCORE_COMMENTARY9     :=  p_interface_rec.CREDIT_SCORE_COMMENTARY9;
    l_credit_ratings_rec.CREDIT_SCORE_COMMENTARY10    :=  p_interface_rec.CREDIT_SCORE_COMMENTARY10;
    l_credit_ratings_rec.CREDIT_SCORE_DATE            :=  p_interface_rec.CREDIT_SCORE_DATE;
    l_credit_ratings_rec.CREDIT_SCORE_INCD_DEFAULT    :=  p_interface_rec.CREDIT_SCORE_INCD_DEFAULT;
    l_credit_ratings_rec.CREDIT_SCORE_NATL_PERCENTILE :=  p_interface_rec.CREDIT_SCORE_NATL_PERCENTILE;
    l_credit_ratings_rec.FAILURE_SCORE                :=      p_interface_rec.FAILURE_SCORE;
    l_credit_ratings_rec.FAILURE_SCORE_COMMENTARY     :=  p_interface_rec.FAILURE_SCORE_COMMENTARY1;
    l_credit_ratings_rec.FAILURE_SCORE_COMMENTARY2    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY2;
    l_credit_ratings_rec.FAILURE_SCORE_COMMENTARY3    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY3;
    l_credit_ratings_rec.FAILURE_SCORE_COMMENTARY4    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY4;
    l_credit_ratings_rec.FAILURE_SCORE_COMMENTARY5    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY5;
    l_credit_ratings_rec.FAILURE_SCORE_COMMENTARY6    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY6;
    l_credit_ratings_rec.FAILURE_SCORE_COMMENTARY7    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY7;
    l_credit_ratings_rec.FAILURE_SCORE_COMMENTARY8    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY8;
    l_credit_ratings_rec.FAILURE_SCORE_COMMENTARY9    :=  p_interface_rec.FAILURE_SCORE_COMMENTARY9;
    l_credit_ratings_rec.FAILURE_SCORE_COMMENTARY10   :=  p_interface_rec.FAILURE_SCORE_COMMENTARY10;
    l_credit_ratings_rec.FAILURE_SCORE_CLASS          :=  p_interface_rec.FAILURE_SCORE_CLASS;
    l_credit_ratings_rec.FAILURE_SCORE_NATNL_PERCENTILE :=  p_interface_rec.FAILURE_SCORE_NATL_PERCENTILE;
    l_credit_ratings_rec.FAILURE_SCORE_INCD_DEFAULT   :=  p_interface_rec.FAILURE_SCORE_INCD_DEFAULT;
    l_credit_ratings_rec.FAILURE_SCORE_AGE            :=  p_interface_rec.FAILURE_SCORE_AGE;
    l_credit_ratings_rec.FAILURE_SCORE_OVERRIDE_CODE  :=  p_interface_rec.FAILURE_SCORE_OVERRIDE_CODE;
    l_credit_ratings_rec.FAILURE_SCORE_DATE           :=  p_interface_rec.FAILURE_SCORE_DATE;
    l_credit_ratings_rec.GLOBAL_FAILURE_SCORE         :=  p_interface_rec.GLOBAL_FAILURE_SCORE;
    l_credit_ratings_rec.DEBARMENTS_COUNT             :=  p_interface_rec.DEBARMENTS_COUNT;
    l_credit_ratings_rec.DEBARMENTS_DATE              :=  p_interface_rec.DEBARMENTS_DATE;
    l_credit_ratings_rec.HIGH_CREDIT                  :=  p_interface_rec.HIGH_CREDIT;
    l_credit_ratings_rec.MAXIMUM_CREDIT_CURRENCY_CODE :=  p_interface_rec.MAX_CREDIT_CURRENCY;
    l_credit_ratings_rec.MAXIMUM_CREDIT_RCMD          :=  p_interface_rec.MAX_CREDIT_RECOMMEND;
    l_credit_ratings_rec.PAYDEX_NORM                  :=  p_interface_rec.PAYDEX_NORM;
    l_credit_ratings_rec.PAYDEX_SCORE                 :=  p_interface_rec.PAYDEX_SCORE;
    l_credit_ratings_rec.PAYDEX_THREE_MONTHS_AGO      :=  p_interface_rec.PAYDEX_THREE_MONTHS_AGO;
-- end of column from org profile

    l_credit_ratings_rec.CREDIT_SCORE_OVERRIDE_CODE   :=  p_interface_rec.CREDIT_SCORE_OVERRIDE_CODE;
    l_credit_ratings_rec.CR_SCR_CLAS_EXPL             :=  p_interface_rec.CR_SCR_CLAS_EXPL;
    l_credit_ratings_rec.LOW_RNG_DELQ_SCR             :=  p_interface_rec.LOW_RNG_DELQ_SCR;
    l_credit_ratings_rec.HIGH_RNG_DELQ_SCR            :=  p_interface_rec.HIGH_RNG_DELQ_SCR;
    l_credit_ratings_rec.DELQ_PMT_RNG_PRCNT           :=  p_interface_rec.DELQ_PMT_RNG_PRCNT;
    l_credit_ratings_rec.DELQ_PMT_PCTG_FOR_ALL_FIRMS  :=  p_interface_rec.DELQ_PMT_PCTG_FOR_ALL_FIRMS;
    l_credit_ratings_rec.NUM_TRADE_EXPERIENCES        :=  p_interface_rec.NUM_TRADE_EXPERIENCES;
    l_credit_ratings_rec.PAYDEX_FIRM_DAYS             :=  p_interface_rec.PAYDEX_FIRM_DAYS;
    l_credit_ratings_rec.PAYDEX_FIRM_COMMENT          :=  p_interface_rec.PAYDEX_FIRM_COMMENT;
    l_credit_ratings_rec.PAYDEX_INDUSTRY_DAYS         :=  p_interface_rec.PAYDEX_INDUSTRY_DAYS;
    l_credit_ratings_rec.PAYDEX_INDUSTRY_COMMENT      :=  p_interface_rec.PAYDEX_INDUSTRY_COMMENT;
    l_credit_ratings_rec.PAYDEX_COMMENT               :=  p_interface_rec.PAYDEX_COMMENT;
    l_credit_ratings_rec.SUIT_IND                     :=  p_interface_rec.SUIT_IND;
    l_credit_ratings_rec.LIEN_IND                     :=  p_interface_rec.LIEN_IND;
    l_credit_ratings_rec.JUDGEMENT_IND                :=  p_interface_rec.JUDGEMENT_IND;
    l_credit_ratings_rec.BANKRUPTCY_IND               :=  p_interface_rec.BANKRUPTCY_IND;
    l_credit_ratings_rec.NO_TRADE_IND                 :=  p_interface_rec.NO_TRADE_IND;
    l_credit_ratings_rec.PRNT_HQ_BKCY_IND             :=  p_interface_rec.PRNT_HQ_BKCY_IND;

/*  Bug 3107162
       IF p_interface_rec.GDP_NAME = 'COMM_CREDIT_SCORE' THEN
       IF l_credit_ratings_rec.SUIT_IND is null THEN
          l_credit_ratings_rec.SUIT_IND := 'N';
       ELSIF l_credit_ratings_rec.SUIT_IND = 'S' THEN
          l_credit_ratings_rec.SUIT_IND := 'Y';
       END IF;

       IF l_credit_ratings_rec.LIEN_IND is null THEN
           l_credit_ratings_rec.LIEN_IND := 'N';
       ELSIF l_credit_ratings_rec.LIEN_IND = 'L' THEN
           l_credit_ratings_rec.LIEN_IND := 'Y';
       END IF;

       IF l_credit_ratings_rec.JUDGEMENT_IND is null THEN
           l_credit_ratings_rec.JUDGEMENT_IND := 'N';
       ELSIF l_credit_ratings_rec.JUDGEMENT_IND = 'J' THEN
           l_credit_ratings_rec.JUDGEMENT_IND := 'Y';
       END IF;

       IF l_credit_ratings_rec.BANKRUPTCY_IND is null THEN
           l_credit_ratings_rec.BANKRUPTCY_IND := 'N';
       ELSIF l_credit_ratings_rec.BANKRUPTCY_IND = 'B' THEN
           l_credit_ratings_rec.BANKRUPTCY_IND := 'Y';
       END IF;

       IF l_credit_ratings_rec.NO_TRADE_IND is null THEN
           l_credit_ratings_rec.NO_TRADE_IND := 'Y';
       END IF;

       IF l_credit_ratings_rec.PRNT_HQ_BKCY_IND is null THEN
           l_credit_ratings_rec.PRNT_HQ_BKCY_IND := 'N';
       END IF;
    END IF;*/

    l_credit_ratings_rec.NUM_PRNT_BKCY_FILING         :=  p_interface_rec.NUM_PRNT_BKCY_FILING;
    l_credit_ratings_rec.PRNT_BKCY_FILG_TYPE          :=  p_interface_rec.PRNT_BKCY_FILG_TYPE;
    l_credit_ratings_rec.PRNT_BKCY_FILG_CHAPTER       :=  p_interface_rec.PRNT_BKCY_FILG_CHAPTER;
    l_credit_ratings_rec.PRNT_BKCY_FILG_DATE          :=  p_interface_rec.PRNT_BKCY_FILG_DATE;
    l_credit_ratings_rec.NUM_PRNT_BKCY_CONVS          :=  p_interface_rec.NUM_PRNT_BKCY_CONVS;
    l_credit_ratings_rec.PRNT_BKCY_CONV_DATE          :=  p_interface_rec.PRNT_BKCY_CONV_DATE;
    l_credit_ratings_rec.PRNT_BKCY_CHAPTER_CONV       :=  p_interface_rec.PRNT_BKCY_CHAPTER_CONV;
    l_credit_ratings_rec.SLOW_TRADE_EXPL              :=  p_interface_rec.SLOW_TRADE_EXPL;
    l_credit_ratings_rec.NEGV_PMT_EXPL                :=  p_interface_rec.NEGV_PMT_EXPL;
    l_credit_ratings_rec.PUB_REC_EXPL                 :=  p_interface_rec.PUB_REC_EXPL;
    l_credit_ratings_rec.BUSINESS_DISCONTINUED        :=  p_interface_rec.BUSINESS_DISCONTINUED;
    l_credit_ratings_rec.SPCL_EVENT_COMMENT           :=  p_interface_rec.SPCL_EVENT_COMMENT;
    l_credit_ratings_rec.NUM_SPCL_EVENT               :=  p_interface_rec.NUM_SPCL_EVENT;
    l_credit_ratings_rec.SPCL_EVENT_UPDATE_DATE       :=  p_interface_rec.SPCL_EVENT_UPDATE_DATE;
    l_credit_ratings_rec.SPCL_EVNT_TXT                :=  p_interface_rec.SPCL_EVNT_TXT;

END do_assign_credit_ratings;


procedure do_assign_financial_report(
	p_interface_rec		    IN      HZ_PARTY_INTERFACE%ROWTYPE,
	--l_fin_rep_rec               IN OUT NOCOPY  HZ_ORG_INFO_PUB.FINANCIAL_REPORTS_REC_TYPE,
	l_fin_rep_rec               IN OUT NOCOPY  HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE,
        p_type_of_financial_report  IN      HZ_FINANCIAL_REPORTS.TYPE_OF_FINANCIAL_REPORT%type
) IS
BEGIN

        l_fin_rep_rec.financial_report_id := NULL;
	l_fin_rep_rec.PARTY_ID          :=      p_interface_rec.party_id;

/*      Bug 3539597.Date_report_issued will always be set to NULL.
        -- bug 3200870
	l_fin_rep_rec.DATE_REPORT_ISSUED:=      nvl(p_interface_rec.STATEMENT_DATE, sysdate);*/

	l_fin_rep_rec.AUDIT_IND 	:=      p_interface_rec.AUDIT_IND;
/* Bug 3107162
	IF p_interface_rec.CONSOLIDATED_IND = 'C' THEN
		l_fin_rep_rec.CONSOLIDATED_IND  := 'Y';
	ELSIF p_interface_rec.CONSOLIDATED_IND = 'N' THEN
		l_fin_rep_rec.CONSOLIDATED_IND  := 'N';
	END IF;
*/
        l_fin_rep_rec.CONSOLIDATED_IND  :=      p_interface_rec.CONSOLIDATED_IND;
	l_fin_rep_rec.ESTIMATED_IND     :=      p_interface_rec.ESTIMATED_IND;
	l_fin_rep_rec.FORECAST_IND      :=      p_interface_rec.FORECAST_IND;
	l_fin_rep_rec.FISCAL_IND        :=      p_interface_rec.FISCAL_IND;
	l_fin_rep_rec.FINAL_IND 	:=      p_interface_rec.FINAL_IND;
	l_fin_rep_rec.SIGNED_BY_PRINCIPALS_IND  :=      p_interface_rec.SIGNED_BY_PRINCIPALS_IND;
	l_fin_rep_rec.RESTATED_IND      :=      p_interface_rec.RESTATED_IND;
	l_fin_rep_rec.UNBALANCED_IND    :=      p_interface_rec.UNBALANCED_IND;
	l_fin_rep_rec.QUALIFIED_IND     :=      p_interface_rec.QUALIFIED_IND;
	l_fin_rep_rec.OPENING_IND       :=      p_interface_rec.OPENING_IND;
	l_fin_rep_rec.PROFORMA_IND      :=      p_interface_rec.PROFORMA_IND;
	l_fin_rep_rec.TRIAL_BALANCE_IND :=      p_interface_rec.TRIAL_BALANCE_IND;
	l_fin_rep_rec.ACTUAL_CONTENT_SOURCE :=    p_interface_rec.content_source_type;

        IF p_type_of_financial_report = 'BALANCE_SHEET' THEN
            l_fin_rep_rec.type_of_financial_report := 'BALANCE_SHEET';

            -- Bug 3539597.
	    l_fin_rep_rec.REPORT_START_DATE := NULL;
	    l_fin_rep_rec.REPORT_END_DATE   := NULL;
	    l_fin_rep_rec.ISSUED_PERIOD     := NVL(TO_CHAR(p_interface_rec.STATEMENT_DATE),
	                                           TO_CHAR(SYSDATE,'YYYY'));

        ELSIF p_type_of_financial_report = 'INCOME_STATEMENT' THEN
            arp_util.debug('HZ_MAP_PARTY_PUB.DO_MAP: INCOME_STATEMENT');
            l_fin_rep_rec.type_of_financial_report 	:= 	'INCOME_STATEMENT';


/*   Bug 3539597.Replaced the previous mapping rules.
 |          l_fin_rep_rec.REPORT_START_DATE 	        := 	p_interface_rec.INCOME_STMT_START_DATE;
 |          l_fin_rep_rec.REPORT_END_DATE   	        :=      p_interface_rec.INCOME_STMT_END_DATE;
 |
 |           --Bug 2995642: Modified do_assign_financial_report, such that DATE_REPORT_ISSUED should be
 |           --INCOME_STMT_DATE. If this is null, then INCOME_STMT_END_DATE. If this is null, then
 |           --INCOME_STMT_START_DATE. If this is also null, then STATEMENT_DATE.
 |           --If one of INCOME_STMT_START_DATE or INCOME_STMT_END_DATE is null, then making the other null too.
 |           --So, either pass both as null or both as 'not null'.
 |
 |           IF p_interface_rec.INCOME_STMT_START_DATE IS NULL THEN
 |              l_fin_rep_rec.REPORT_END_DATE  := NULL;
 |           END IF;
 |           IF p_interface_rec.INCOME_STMT_END_DATE IS NULL THEN
 |              l_fin_rep_rec.REPORT_START_DATE  := NULL;
 |           END IF;
 |
 |-- Bug 2995642 : Modified the assignment to DATE_REPORT_ISSUED.
 |-- bug 3200870 on top of 2995642
 |
 |           l_fin_rep_rec.DATE_REPORT_ISSUED            :=       nvl(
 |	                                                         nvl(p_interface_rec.INCOME_STMT_DATE,
 |                                                                nvl(p_interface_rec.INCOME_STMT_END_DATE,
 |								 nvl(p_interface_rec.STATEMENT_DATE,
 |                                                                  p_interface_rec.INCOME_STMT_START_DATE))), sysdate);
 |
 */
             IF p_interface_rec.INCOME_STMT_START_DATE IS NULL OR
                p_interface_rec.INCOME_STMT_START_DATE = FND_API.G_MISS_DATE OR
                p_interface_rec.INCOME_STMT_END_DATE IS NULL OR
                p_interface_rec.INCOME_STMT_END_DATE = FND_API.G_MISS_DATE
             THEN
	         l_fin_rep_rec.REPORT_START_DATE := NULL;
		 l_fin_rep_rec.REPORT_END_DATE   := NULL;
		 l_fin_rep_rec.ISSUED_PERIOD     := NVL(
		                                     NVL(
						      TO_CHAR(p_interface_rec.INCOME_STMT_END_DATE),
						      p_interface_rec.INCOME_STMT_DATE),
						     TO_CHAR(SYSDATE,'YYYY') );
             ELSE
                 l_fin_rep_rec.REPORT_START_DATE := p_interface_rec.INCOME_STMT_START_DATE;
                 l_fin_rep_rec.REPORT_END_DATE   := p_interface_rec.INCOME_STMT_END_DATE;
		 l_fin_rep_rec.ISSUED_PERIOD := NULL;
	     END IF;



        ELSIF  p_type_of_financial_report = 'TANGIBLE_NET_WORTH' THEN
            arp_util.debug('HZ_MAP_PARTY_PUB.DO_MAP: TANGIBLE_NET_WORTH');
            l_fin_rep_rec.type_of_financial_report := 'TANGIBLE_NET_WORTH';

            IF p_interface_rec.TANGIBLE_NET_WORTH_IND = '1' THEN
                l_fin_rep_rec.ESTIMATED_IND := 'N';
            ELSIF p_interface_rec.TANGIBLE_NET_WORTH_IND = '2' THEN
                l_fin_rep_rec.ESTIMATED_IND := 'Y';
            END IF;

            -- Bug 3539597.
	    l_fin_rep_rec.REPORT_START_DATE := NULL;
	    l_fin_rep_rec.REPORT_END_DATE   := NULL;
	    l_fin_rep_rec.ISSUED_PERIOD     := NVL(TO_CHAR(p_interface_rec.STATEMENT_DATE),
	                                           TO_CHAR(SYSDATE,'YYYY'));

        ELSIF p_type_of_financial_report = 'ANNUAL_SALES_VOLUME' THEN
            arp_util.debug('HZ_MAP_PARTY_PUB.DO_MAP: ANNUAL_SALES_VOLUME');
            l_fin_rep_rec.type_of_financial_report := 'ANNUAL_SALES_VOLUME';
            l_fin_rep_rec.CONSOLIDATED_IND := p_interface_rec.ANNUAL_SALES_CONSOL_IND;

            -- Bug 3539597.
	    l_fin_rep_rec.REPORT_START_DATE := NULL;
	    l_fin_rep_rec.REPORT_END_DATE   := NULL;
	    l_fin_rep_rec.ISSUED_PERIOD     := NVL(TO_CHAR(p_interface_rec.STATEMENT_DATE),
	                                           TO_CHAR(SYSDATE,'YYYY'));

        END IF;


        /*Bug 3456205*/
/*      Commenting out changes made in initial fix for 3456205.

        IF l_fin_rep_rec.REPORT_START_DATE is NULL
	   OR l_fin_rep_rec.REPORT_START_DATE = FND_API.G_MISS_DATE
	THEN
	   l_fin_rep_rec.REPORT_END_DATE := NULL;
	   l_fin_rep_rec.ISSUED_PERIOD := 'Not Provided By DNB';

	ELSIF l_fin_rep_rec.REPORT_END_DATE is NULL
	   OR l_fin_rep_rec.REPORT_END_DATE = FND_API.G_MISS_DATE
	THEN
	   l_fin_rep_rec.REPORT_START_DATE := NULL;
	   l_fin_rep_rec.ISSUED_PERIOD := 'Not Provided By DNB';

	ELSE
	   l_fin_rep_rec.ISSUED_PERIOD := NULL;
	END IF;
*/

END do_assign_financial_report;

--
-- Create party.
--
/*===========================================================================+
 | PROCEDURE
 |              store_org
 |
 | DESCRIPTION
 |              Store party and organization profile info.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_organization_profile_id
 |          IN/ OUT:
 |                    p_organization_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure store_org(
	p_organization_rec 		IN OUT NOCOPY 	HZ_PARTY_V2PUB.organization_rec_type,
	x_organization_profile_id	OUT NOCOPY	NUMBER,
	x_return_status			IN OUT NOCOPY	VARCHAR2
) IS
	l_msg_count                  	NUMBER;
        l_msg_data                   	VARCHAR2(2000);
	l_count				NUMBER;
	l_object_version_number		NUMBER;

        l_profile                       VARCHAR2(1);
        l_exist                         VARCHAR2(1);
        l_mosr_mapping_exist            VARCHAR2(1);
        l_ue_exist                      VARCHAR2(1);
        l_profile_obsolete_col          VARCHAR2(1);
        l_party_id                      HZ_PARTIES.PARTY_ID%TYPE;
        l_party_number                  HZ_PARTIES.PARTY_NUMBER%TYPE;

        CURSOR check_party_mosr_mapping (p_orig_system IN VARCHAR2,
                                         p_orig_system_ref IN VARCHAR2,
                                         p_owner_table_name IN VARCHAR2)
        IS
        select 'Y'
        from hz_orig_sys_references
        where orig_system = p_orig_system
        and orig_system_reference = p_orig_system_ref
        and owner_table_name = p_owner_table_name
        and status = 'A'
        and trunc(nvl(end_date_active, sysdate)) >= trunc(sysdate);

BEGIN

  arp_util.debug('HZ_MAP_PARTY_PUB.STORE_ORG (+) ');

  IF p_organization_rec.party_rec.party_id IS NULL THEN

	--
	--party does not exist. Create party.
	--
  	arp_util.debug('HZ_MAP_PARTY_PUB.STORE_ORG: party does not exist');

        l_exist := 'N';
        l_ue_exist := 'N';

  ELSE

  	arp_util.debug('HZ_MAP_PARTY_PUB.STORE_ORG: party exists . party_id =' || to_char(p_organization_rec.party_rec.party_id));

	BEGIN

           SELECT 'Y' INTO l_ue_exist
           FROM hz_organization_profiles
           WHERE party_id = p_organization_rec.party_rec.party_id
           AND actual_content_source = HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE
           AND effective_end_date is null
           AND ROWNUM = 1;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_ue_exist := 'N';
        END;

	BEGIN

           SELECT 'Y' INTO l_exist
           FROM hz_organization_profiles
           WHERE party_id = p_organization_rec.party_rec.party_id
           AND actual_content_source = p_organization_rec.ACTUAL_CONTENT_SOURCE
           AND effective_end_date is null
           AND ROWNUM = 1;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_exist := 'N';
        END;
  END IF;

  l_profile_obsolete_col := fnd_profile.value('HZ_API_ERR_ON_OBSOLETE_COLUMN');
  IF l_profile_obsolete_col = 'Y' THEN
     fnd_profile.put('HZ_API_ERR_ON_OBSOLETE_COLUMN', 'N');
  END IF;

  IF l_exist = 'N' THEN

        --
        --party exists. org profile does not. Create org profile
        --

        arp_util.debug('HZ_MAP_PARTY_PUB.STORE_ORG: party exists, org profile does not exist ');

        --Bug 1721094: generate party number by sequence.
	IF fnd_profile.value('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
	   fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'Y');
	   l_profile := 'N';
	END IF;

        p_organization_rec.application_id := 222;
        p_organization_rec.created_by_module := 'TCA_DNB_MAPPING';
        OPEN check_party_mosr_mapping ( 'DNB', p_organization_rec.DUNS_NUMBER_C, 'HZ_PARTIES');
        FETCH check_party_mosr_mapping into l_mosr_mapping_exist;
        IF l_mosr_mapping_exist = 'Y' THEN
          p_organization_rec.party_rec.orig_system := NULL;
        ELSE
          p_organization_rec.party_rec.orig_system := 'DNB';
        END IF;
        p_organization_rec.party_rec.orig_system_reference := p_organization_rec.DUNS_NUMBER_C;

	HZ_PARTY_V2PUB.create_organization(
		'F',
		p_organization_rec,
		x_return_status,
		l_msg_count,
		l_msg_data,
                l_party_id,
                l_party_number,
		x_organization_profile_id);
        /* Bug Fix : 2770991 */
        IF l_party_id IS NOT NULL THEN
           p_organization_rec.party_rec.party_id := l_party_id;
        END IF;
        IF l_party_number IS NOT NULL THEN
           p_organization_rec.party_rec.party_number := l_party_number;
        END IF;

	--Bug 1721094: reset profile option.
	IF l_profile = 'N' THEN
	   fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'N');
	END IF;

	arp_util.debug('HZ_MAP_PARTY_PUB.STORE_ORG: party does not exist: created party with party_id ='  || to_char(p_organization_rec.party_rec.party_id));

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RETURN;
	END IF;

        IF p_organization_rec.displayed_duns_party_id IS NULL THEN
	    IF l_ue_exist = 'N' THEN

	        arp_util.debug('HZ_MAP_PARTY_PUB.STORE_ORG: party does not exist: update DNB and USER_ENTERED displayed_duns_party_id');

	        UPDATE hz_organization_profiles
	        SET displayed_duns_party_id = p_organization_rec.party_rec.party_id
                WHERE  party_id = p_organization_rec.party_rec.party_id  AND
	               effective_end_date is null;
            ELSE
	        arp_util.debug('HZ_MAP_PARTY_PUB.STORE_ORG: party does not exist: update DNB displayed_duns_party_id');
                UPDATE hz_organization_profiles
                SET displayed_duns_party_id = p_organization_rec.party_rec.party_id
                WHERE  party_id = p_organization_rec.party_rec.party_id  AND
                    actual_content_source =  p_organization_rec.ACTUAL_CONTENT_SOURCE AND
		    effective_end_date is null;
	    END IF;
	END IF;

  ELSE

	--
	--party exists. org profile exists. Update it.
	--

	arp_util.debug('HZ_MAP_PARTY_PUB.STORE_ORG: party exists, org profile exists ');

	SELECT object_version_number INTO l_object_version_number
	FROM hz_parties
	WHERE party_id= p_organization_rec.party_rec.party_id;
        p_organization_rec.party_rec.orig_system := NULL;
        --p_organization_rec.party_rec.orig_system_reference := NULL;
        p_organization_rec.created_by_module := NULL;
        p_organization_rec.application_id := NULL;

	HZ_PARTY_V2PUB.update_organization(
                'F',
                p_organization_rec,
		l_object_version_number,
		x_organization_profile_id,
                x_return_status,
                l_msg_count,
                l_msg_data);

  END IF;

  IF l_profile_obsolete_col = 'Y' THEN
  fnd_profile.put('HZ_API_ERR_ON_OBSOLETE_COLUMN', 'Y');
  END IF;

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_ORG (-) ');

END store_org;



/*
--
-- populate to classification.
--
/*===========================================================================+
 | PROCEDURE
 |              populate_to_classification
 |
 | DESCRIPTION
 |              populate data to code assignment
 |
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  :  IN:
  |
 |              OUT:
 |          IN/ OUT:
 |                    p_code_assignment_rec
 |                    p_interface_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY   Kate Shan Created
 |	17-Feb-2004	Dhaval Mehta	Bug 3346302 : Modified the class code assignment
 |					for SIC type class categories.
 |					1. End date all those existing code assignments which
 |					   are not passed in updated data.
 |					2. If the existing primary class code is different
 |					   than sic_code1, make the existing one as non primary
 |					   and sic_code1 as primary.
 |
 +===========================================================================*/

procedure populate_to_classification(
        p_code_assignment_rec   IN OUT NOCOPY  hz_classification_v2pub.code_assignment_rec_type,
        p_interface_rec	        IN OUT NOCOPY  HZ_PARTY_INTERFACE%ROWTYPE,
--        p_is_new_party		IN BOOLEAN ,
        x_return_status         IN OUT NOCOPY  VARCHAR2
) IS

-- Bug 3397674 : Added local variables and cursor to pick existing code assignments for this party and sic_code_type.

l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_code_assignment_id    NUMBER;
l_object_version_number NUMBER;

CURSOR old_code_assignment IS
select code_assignment_id, object_version_number
from hz_code_assignments
where
owner_table_name = p_code_assignment_rec.owner_table_name AND
owner_table_id = p_code_assignment_rec.owner_table_id AND
class_category = p_code_assignment_rec.class_category AND
--bug 4169070
--content_source_type = p_code_assignment_rec.content_source_type AND
actual_content_source = p_code_assignment_rec.actual_content_source AND
class_code not in (
/*nvl(SUBSTRB(replace(p_interface_rec.sic_code1, ' ', ''), 1, 4),FND_API.G_MISS_CHAR),
nvl(SUBSTRB(replace(p_interface_rec.sic_code2, ' ', ''), 1, 4),FND_API.G_MISS_CHAR),
nvl(SUBSTRB(replace(p_interface_rec.sic_code3, ' ', ''), 1, 4),FND_API.G_MISS_CHAR),
nvl(SUBSTRB(replace(p_interface_rec.sic_code4, ' ', ''), 1, 4),FND_API.G_MISS_CHAR),
nvl(SUBSTRB(replace(p_interface_rec.sic_code5, ' ', ''), 1, 4),FND_API.G_MISS_CHAR),
nvl(SUBSTRB(replace(p_interface_rec.sic_code6, ' ', ''), 1, 4),FND_API.G_MISS_CHAR)
*/
NVL(p_interface_rec.sic_code1,FND_API.G_MISS_CHAR),
NVL(p_interface_rec.sic_code2,FND_API.G_MISS_CHAR),
NVL(p_interface_rec.sic_code3,FND_API.G_MISS_CHAR),
NVL(p_interface_rec.sic_code4,FND_API.G_MISS_CHAR),
NVL(p_interface_rec.sic_code5,FND_API.G_MISS_CHAR),
NVL(p_interface_rec.sic_code6,FND_API.G_MISS_CHAR)
)
 AND
-- (END_DATE_ACTIVE IS NULL OR (END_DATE_ACTIVE IS not NULL and trunc(END_DATE_ACTIVE) >= trunc(SYSDATE)));
(END_DATE_ACTIVE IS NULL OR (END_DATE_ACTIVE IS not NULL and END_DATE_ACTIVE >= SYSDATE));

 l_start_date date := sysdate + 1/(24*3600);
 l_end_date date := sysdate;

BEGIN
  --
  -- store classification
  --
  p_code_assignment_rec.code_assignment_id := null;
  p_code_assignment_rec.owner_table_name := 'HZ_PARTIES';
  p_code_assignment_rec.owner_table_id := p_interface_rec.party_id;
  p_code_assignment_rec.class_category := p_interface_rec.sic_code_type;
  --bug 4169070
--  p_code_assignment_rec.content_source_type := NVL( p_interface_rec.content_source_type, HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE);
  p_code_assignment_rec.actual_content_source := NVL( p_interface_rec.content_source_type, HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE);
  p_code_assignment_rec.start_date_active := l_start_date;
  p_code_assignment_rec.primary_flag := 'N';
  p_code_assignment_rec.created_by_module := 'TCA_DNB_MAPPING';


-- Change START for bug 3397674

IF p_code_assignment_rec.class_category IN ('1972', '1977', '1987') THEN
	p_code_assignment_rec.class_category      := p_code_assignment_rec.class_category || ' SIC';
END IF;


IF p_code_assignment_rec.class_category IN ('1972 SIC', '1977 SIC', '1987 SIC') THEN
	p_code_assignment_rec.class_code          := SUBSTRB(replace(p_code_assignment_rec.class_code, ' ', ''), 1, 4);
END IF;

-- The below for loop will pick all code assignment records whose class code is
-- not present in SIC_CODE1 to SIC_CODE6 in hz_party_interface for this party.
-- It will end date all these code assignments because as per new data they
-- are not valid and should not be active in TCA Registry.

FOR codes in old_code_assignment
LOOP
	p_code_assignment_rec.code_assignment_id := codes.code_assignment_id;
	p_code_assignment_rec.primary_flag := NULL;
	p_code_assignment_rec.created_by_module := NULL;
	p_code_assignment_rec.application_id := NULL;
	p_code_assignment_rec.start_date_active := NULL;
	p_code_assignment_rec.end_date_active := l_end_date;  -- sysdate - 1/(24*60*60); --bug4287144
	l_object_version_number := codes.object_version_number;
HZ_CLASSIFICATION_V2PUB.update_code_assignment (
		p_code_assignment_rec     => p_code_assignment_rec,
		p_object_version_number   => l_object_version_number,
		x_return_status           => x_return_status,
		x_msg_count               => l_msg_count,
		x_msg_data                => l_msg_data
		);
END LOOP;

-- Below sql will check if the existing primary code for this party
-- is same  as SIC_CODE1 in hz_party_interface for this party.
-- If the two codes are different, it will update the existing
-- code assignment to Non-Primary as the party has another primary SIC code.
BEGIN
	select code_assignment_id, object_version_number
	into l_code_assignment_id, l_object_version_number
	from hz_code_assignments
	where
	owner_table_name = p_code_assignment_rec.owner_table_name AND
	owner_table_id = p_code_assignment_rec.owner_table_id AND
	class_category = p_code_assignment_rec.class_category AND
	--bug  4169070
	--content_source_type = p_code_assignment_rec.content_source_type AND
	actual_content_source = p_code_assignment_rec.actual_content_source AND
	class_code <> nvl(p_interface_rec.sic_code1,FND_API.G_MISS_CHAR)  AND
	primary_flag = 'Y' AND
	(END_DATE_ACTIVE IS NULL OR (END_DATE_ACTIVE IS not NULL and
	END_DATE_ACTIVE >= SYSDATE));
	--trunc(END_DATE_ACTIVE) >= trunc(SYSDATE))); --bug 4287144

	p_code_assignment_rec.code_assignment_id := l_code_assignment_id;
	--p_code_assignment_rec.primary_flag := 'N';4287144
	p_code_assignment_rec.primary_flag := null;
	p_code_assignment_rec.created_by_module := NULL;
	p_code_assignment_rec.application_id := NULL;
	p_code_assignment_rec.start_date_active := NULL;
	--p_code_assignment_rec.end_date_active := NULL; 4287144
	p_code_assignment_rec.end_date_active := l_end_date; -- sysdate-1/(24*60*60);

	HZ_CLASSIFICATION_V2PUB.update_code_assignment (
		p_code_assignment_rec     => p_code_assignment_rec,
		p_object_version_number   => l_object_version_number,
		x_return_status           => x_return_status,
		x_msg_count               => l_msg_count,
		x_msg_data                => l_msg_data
		);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
END;

-- Reinitialize the below columns before we process the SIC codes
-- start_date_active should be sysdate
-- primary flag should be 'Y'. It will be changed to 'N' for SIC_CODE2 to
-- SIC_CODE6 if there is SIC_CODE1
-- end_date_active should be null
p_code_assignment_rec.start_date_active := l_start_date;
p_code_assignment_rec.code_assignment_id := null;
p_code_assignment_rec.primary_flag := 'Y';
p_code_assignment_rec.end_date_active := NULL;

-- Change END for bug 3397674

  IF p_interface_rec.sic_code1 IS NOT NULL AND
     p_interface_rec.content_source_type <>  HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE THEN

     p_code_assignment_rec.code_assignment_id := null;
     p_code_assignment_rec.class_code := p_interface_rec.sic_code1;
     p_code_assignment_rec.primary_flag := 'Y';

     -- store content_source_type = 'DNB'
     --bug 4169070
     --p_code_assignment_rec.content_source_type := p_interface_rec.content_source_type;
     p_code_assignment_rec.actual_content_source := p_interface_rec.content_source_type;
     store_classification (
        p_code_assignment_rec   => p_code_assignment_rec,
        x_return_status         => x_return_status
     );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RETURN;
     END IF;

/*
     IF  p_is_new_party AND isMixNMatchEnabled = 'N'  THEN

         -- store content_source_type = 'USER ENTERED'
         p_code_assignment_rec.content_source_type := HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE;
         store_classification (
             p_code_assignment_rec   => p_code_assignment_rec,
             x_return_status         => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RETURN;
         END IF;

     END IF;
*/
  END IF;


  IF p_interface_rec.sic_code2 IS NOT NULL THEN

     p_code_assignment_rec.code_assignment_id := null;
     p_code_assignment_rec.class_code := p_interface_rec.sic_code2;
     IF p_interface_rec.sic_code1 IS NOT NULL THEN
	  p_code_assignment_rec.primary_flag := 'N';
     END IF;

     -- store content_source_type = 'DNB'
     --bug 4169070
     --p_code_assignment_rec.content_source_type := p_interface_rec.content_source_type;
     p_code_assignment_rec.actual_content_source := p_interface_rec.content_source_type;
     store_classification (
        p_code_assignment_rec   => p_code_assignment_rec,
        x_return_status         => x_return_status
     );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RETURN;
     END IF;
/*
     IF  p_is_new_party AND isMixNMatchEnabled = 'N' THEN

         -- store content_source_type = 'USER ENTERED'
         p_code_assignment_rec.content_source_type := HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE;
         store_classification (
            p_code_assignment_rec   => p_code_assignment_rec,
            x_return_status         => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RETURN;
         END IF;
     END IF;
*/
  END IF;

  IF p_interface_rec.sic_code3 IS NOT NULL THEN

     p_code_assignment_rec.code_assignment_id := null;
     p_code_assignment_rec.class_code := p_interface_rec.sic_code3;
     IF p_interface_rec.sic_code1 IS NOT NULL OR
        p_interface_rec.sic_code2 IS NOT NULL
     THEN
	  p_code_assignment_rec.primary_flag := 'N';
     END IF;

     -- store content_source_type = 'DNB'
     --bug 4169070
     --p_code_assignment_rec.content_source_type := p_interface_rec.content_source_type;
     p_code_assignment_rec.actual_content_source := p_interface_rec.content_source_type;
     store_classification (
        p_code_assignment_rec   => p_code_assignment_rec,
        x_return_status         => x_return_status
     );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RETURN;
     END IF;
/*
     IF  p_is_new_party AND isMixNMatchEnabled = 'N' THEN
         -- store content_source_type = 'USER ENTERED'
         p_code_assignment_rec.content_source_type := HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE;
         store_classification (
             p_code_assignment_rec   => p_code_assignment_rec,
             x_return_status         => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RETURN;
         END IF;
     END IF;
*/
  END IF;

  IF p_interface_rec.sic_code4 IS NOT NULL THEN
     p_code_assignment_rec.code_assignment_id := null;
     p_code_assignment_rec.class_code := p_interface_rec.sic_code4;
     IF p_interface_rec.sic_code1 IS NOT NULL OR
        p_interface_rec.sic_code2 IS NOT NULL OR
        p_interface_rec.sic_code3 IS NOT NULL
     THEN
	  p_code_assignment_rec.primary_flag := 'N';
     END IF;

     -- store content_source_type = 'DNB'
     --bug 4169070
     --p_code_assignment_rec.content_source_type := p_interface_rec.content_source_type;
     p_code_assignment_rec.actual_content_source := p_interface_rec.content_source_type;
     store_classification (
        p_code_assignment_rec   => p_code_assignment_rec,
        x_return_status         => x_return_status
     );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RETURN;
     END IF;
/*
     IF  p_is_new_party AND isMixNMatchEnabled = 'N' THEN
         -- store content_source_type = 'USER ENTERED'
         p_code_assignment_rec.content_source_type := HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE;
         store_classification (
             p_code_assignment_rec   => p_code_assignment_rec,
             x_return_status         => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RETURN;
         END IF;
     END IF;
*/
  END IF;

  IF p_interface_rec.sic_code5 IS NOT NULL THEN
     p_code_assignment_rec.code_assignment_id := null;
     p_code_assignment_rec.class_code := p_interface_rec.sic_code5;
     IF p_interface_rec.sic_code1 IS NOT NULL OR
        p_interface_rec.sic_code2 IS NOT NULL OR
        p_interface_rec.sic_code3 IS NOT NULL OR
        p_interface_rec.sic_code4 IS NOT NULL
     THEN
	  p_code_assignment_rec.primary_flag := 'N';
     END IF;

     -- store content_source_type = 'DNB'
     --bug 4169070
     --p_code_assignment_rec.content_source_type := p_interface_rec.content_source_type;
     p_code_assignment_rec.actual_content_source := p_interface_rec.content_source_type;
     store_classification (
        p_code_assignment_rec   => p_code_assignment_rec,
        x_return_status         => x_return_status
     );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RETURN;
     END IF;
/*
     IF  p_is_new_party AND isMixNMatchEnabled = 'N' THEN
         -- store content_source_type = 'USER ENTERED'
         p_code_assignment_rec.content_source_type := HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE;
         store_classification (
            p_code_assignment_rec   => p_code_assignment_rec,
            x_return_status         => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RETURN;
         END IF;
     END IF;
*/
  END IF;


  IF p_interface_rec.sic_code6 IS NOT NULL THEN
     p_code_assignment_rec.code_assignment_id := null;
     p_code_assignment_rec.class_code := p_interface_rec.sic_code6;
     IF p_interface_rec.sic_code1 IS NOT NULL OR
        p_interface_rec.sic_code2 IS NOT NULL OR
        p_interface_rec.sic_code3 IS NOT NULL OR
        p_interface_rec.sic_code4 IS NOT NULL OR
        p_interface_rec.sic_code5 IS NOT NULL
     THEN
	  p_code_assignment_rec.primary_flag := 'N';
     END IF;

     -- store content_source_type = 'DNB'
     --bug 4169070
     --p_code_assignment_rec.content_source_type := p_interface_rec.content_source_type;
     p_code_assignment_rec.actual_content_source := p_interface_rec.content_source_type;
     store_classification (
        p_code_assignment_rec   => p_code_assignment_rec,
        x_return_status         => x_return_status
     );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RETURN;
     END IF;
/*
     IF  p_is_new_party AND isMixNMatchEnabled = 'N' THEN
         -- store content_source_type = 'USER ENTERED'
         p_code_assignment_rec.content_source_type := HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE;
         store_classification (
             p_code_assignment_rec   => p_code_assignment_rec,
             x_return_status         => x_return_status
         );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RETURN;
         END IF;
     END IF;
*/
  END IF;
END populate_to_classification;

--
-- create classification.
--
/*===========================================================================+
 | PROCEDURE
 |              store_classification
 |
 | DESCRIPTION
 |              create/update assignment code
 |
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  :  IN:
 |
 |              OUT:
 |          IN/ OUT:
 |                    p_code_assignment_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY   Kate Shan Created
 |
 +===========================================================================*/

procedure store_classification(
        p_code_assignment_rec   IN OUT NOCOPY  hz_classification_v2pub.code_assignment_rec_type,
        x_return_status         IN OUT NOCOPY  VARCHAR2
) IS

        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_code_assignment_id    NUMBER;
        l_create                BOOLEAN := FALSE;
        l_object_version_number NUMBER;
        l_code_assignment_rec   hz_classification_v2pub.code_assignment_rec_type := p_code_assignment_rec;
        l_primary_flag          VARCHAR2(1);


BEGIN

    /* update code assignment or create code assignment */

    arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CLASSIFICATION (+) ');

    IF p_code_assignment_rec.class_category IN ('1972', '1977', '1987') THEN
      p_code_assignment_rec.class_category      :=  p_code_assignment_rec.class_category || ' SIC';
      l_code_assignment_rec.class_category      :=  p_code_assignment_rec.class_category;
    END IF;


    IF p_code_assignment_rec.class_category IN ('1972 SIC', '1977 SIC', '1987 SIC') THEN
      p_code_assignment_rec.class_code          := SUBSTRB(replace(p_code_assignment_rec.class_code, ' ', ''), 1, 4);
      l_code_assignment_rec.class_code          := p_code_assignment_rec.class_code;
    END IF;

    arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CLASSIFICATION : CONTENT_SOURCE_TYPE =  ' || p_code_assignment_rec.CONTENT_SOURCE_TYPE);
    arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CLASSIFICATION : l_code_assignment_rec.class_category = ' || l_code_assignment_rec.class_category);
    arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CLASSIFICATION : l_code_assignment_rec.class_code = ' || l_code_assignment_rec.class_code);
    arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CLASSIFICATION : l_code_assignment_rec.owner_table_id = ' || l_code_assignment_rec.owner_table_id);

    BEGIN
        select code_assignment_id, object_version_number , primary_flag
        into l_code_assignment_id, l_object_version_number, l_primary_flag
        from hz_code_assignments
        where
          owner_table_name = l_code_assignment_rec.owner_table_name AND
          owner_table_id = l_code_assignment_rec.owner_table_id AND
          class_category = l_code_assignment_rec.class_category AND
          class_code = l_code_assignment_rec.class_code AND
	  --bug 4169070
          --content_source_type = l_code_assignment_rec.content_source_type AND
          actual_content_source = l_code_assignment_rec.actual_content_source AND
          (END_DATE_ACTIVE IS NULL OR
          (END_DATE_ACTIVE IS not NULL and
	  END_DATE_ACTIVE >= SYSDATE))
	  --AND trunc(END_DATE_ACTIVE) >= trunc(SYSDATE)))
	  AND rownum = 1; --bug 4287144: removed trunc

         --
         --Code Assignment already exist. Only need to update Code Assignment
	 --bug 4169070
         --IF p_code_assignment_rec.CONTENT_SOURCE_TYPE <> HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE THEN

	 --4287144
         --IF p_code_assignment_rec.CONTENT_SOURCE_TYPE <> HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE THEN
	   IF (l_primary_flag <> p_code_assignment_rec.primary_flag) THEN

             arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CLASSIFICATION: Code Assignment already exist, code_assignment_id=' || to_char(l_code_assignment_id));
             l_code_assignment_rec.code_assignment_id := l_code_assignment_id;
-- Bug 3397674 : the primary flag should be updated as per new data, instead
--		 of rataining it by l_primary_flag from above select statement.
--             l_code_assignment_rec.primary_flag := l_primary_flag;
             --l_code_assignment_rec.primary_flag := p_code_assignment_rec.primary_flag;
             l_code_assignment_rec.primary_flag := null;
             l_code_assignment_rec.created_by_module := NULL;
             l_code_assignment_rec.application_id := NULL;
-- Bug 3397674 : While updating, start_date_active should not be modified. make it NULL
             l_code_assignment_rec.start_date_active := NULL;
             l_code_assignment_rec.end_date_active := sysdate  - 1 / (24 * 60 * 60);
             HZ_CLASSIFICATION_V2PUB.update_code_assignment (
                   p_code_assignment_rec     => l_code_assignment_rec,
                   p_object_version_number   => l_object_version_number,
                   x_return_status           => x_return_status,
                   x_msg_count               => l_msg_count,
                   x_msg_data                => l_msg_data
             );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RETURN;
             END IF;
     	     l_create := TRUE;
          END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          l_create := TRUE;
    END;

    IF l_create THEN

        arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CLASSIFICATION: No Code Assignment exists, create ' || p_code_assignment_rec.CONTENT_SOURCE_TYPE);

        p_code_assignment_rec.application_id := 222;
        p_code_assignment_rec.created_by_module := 'TCA_DNB_MAPPING';

        HZ_CLASSIFICATION_V2PUB.create_code_assignment(
            p_code_assignment_rec       => p_code_assignment_rec,
            x_return_status             => x_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            x_code_assignment_id        => l_code_assignment_id
        );

    END IF;

END store_classification;



--
-- create location.
--
/*===========================================================================+
 | PROCEDURE
 |              store_location
 |
 | DESCRIPTION
 |              Update location or create/update party_site or
 |              create location and party site
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_party_id
 |              OUT:
 |          IN/ OUT:
 |                    p_location_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure store_location(
	p_location_rec 		IN OUT NOCOPY 	hz_location_v2pub.location_rec_type,
	p_party_id		IN	NUMBER,
	p_create_new		IN	BOOLEAN,
	x_return_status         IN OUT NOCOPY  VARCHAR2
) IS
        l_msg_count                  NUMBER;
        l_msg_data                   VARCHAR2(2000);
	l_object_version_number      NUMBER;
        l_create                     BOOLEAN := FALSE;
	l_valid_tax_location         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_party_site_id	             NUMBER;

-- Bug 2882305 : Local variable to store address1

	l_address1		     VARCHAR2(240);
        --4227564
	l_duns_number_c              hz_organization_profiles.duns_number_c%type;
	l_orig_sys_reference_rec     HZ_ORIG_SYSTEM_REF_PUB.orig_sys_reference_rec_type;
	l_count			     NUMBER;
	l_orig_sys_ref_id            NUMBER;
BEGIN
	--4227564
	l_duns_number_c := p_location_rec.orig_system_reference;

    /* update location or create party_site or (create location and party site). */

    arp_util.debug('HZ_MAP_PARTY_PUB.STORE_LOCATION (+) ');
-- Bug 3417357 : if p_create_new = TRUE, we need to create new location
    IF p_create_new = TRUE or p_location_rec.actual_content_source = HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE THEN
        --  actual_content_source = "USER_ENTERED" , create new location and party site
	l_create := TRUE;
    ELSE
        --  actual_content_source = "DNB"

        BEGIN

            arp_util.debug('HZ_MAP_PARTY_PUB.STORE_LOCATION : actual_content_source =  ' || p_location_rec.actual_content_source);

            --  there is only one dnb party site record with end_date_active as null

-- Bug 2882305 : Add address1 to select statement
            SELECT ps.location_id, ps.party_site_id, loc.object_version_number,loc.address1
            INTO p_location_rec.location_id, l_party_site_id,  l_object_version_number, l_address1
            FROM hz_party_sites ps, hz_locations loc
            WHERE ps.party_id = p_party_id
            AND ps.location_id = loc.location_id
            AND loc.actual_content_source = p_location_rec.actual_content_source
	    AND ps.end_date_active is NULL
-- Bug 3473497 : Added condition status='A' in where clause
	    AND ps.status = 'A'
	    AND rownum = 1;

            arp_util.debug('HZ_MAP_PARTY_PUB.STORE_LOCATION: Location and party site already exist');

            hz_registry_validate_v2pub.tax_location_validation(
	        p_location_rec,
		'U',
		l_valid_tax_location );
            arp_util.debug('HZ_MAP_PARTY_PUB.STORE_LOCATION: l_valid_tax_location =' || l_valid_tax_location);

	    IF l_valid_tax_location <> fnd_api.g_ret_sts_error THEN
	        -- if the existing location record has same taxable components, update this record

/*            SELECT ps.location_id, loc.object_version_number
            INTO p_location_rec.location_id, l_object_version_number
            FROM hz_party_sites ps, hz_locations loc
            WHERE ps.party_id = p_party_id
            AND ps.location_id = loc.location_id
            AND loc.actual_content_source = p_location_rec.actual_content_source
            AND UPPER(loc.ADDRESS1 || loc.ADDRESS2 || loc.ADDRESS3 || loc.ADDRESS4 ||
                loc.CITY || loc.STATE || loc.COUNTY || loc.POSTAL_CODE || loc.PROVINCE) =
                UPPER( p_location_rec.ADDRESS1 || p_location_rec.ADDRESS2 || p_location_rec.ADDRESS3 || p_location_rec.ADDRESS4 ||
                p_location_rec.CITY || p_location_rec.STATE || p_location_rec.COUNTY ||
                p_location_rec.POSTAL_CODE || p_location_rec.PROVINCE )
            AND rownum =1;
*/
                --
                --Location and party site already exist. Only need to update location.
                --

                --p_location_rec.orig_system_reference := NULL;
                p_location_rec.created_by_module := NULL;
                p_location_rec.application_id := NULL;


                arp_util.debug('HZ_MAP_PARTY_PUB.STORE_LOCATION: update Location and party site');

-- Bug 2882305 : Check if null is  passed for address1, retain the previous address1.

		if(p_location_rec.address1 =  'Not provided by DNB') then
			p_location_rec.address1 := l_address1;
		end if;

	        hz_location_v2pub.update_location(
                    'F',
                    p_location_rec,
                    l_object_version_number,
                    x_return_status,
                    l_msg_count,
                    l_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RETURN;
                END IF;
--4227564
	BEGIN
		SELECT  hosr.orig_system_ref_id INTO l_orig_sys_ref_id
		FROM 	hz_orig_sys_references hosr
		WHERE 	hosr.orig_system = 'DNB'
		AND     hosr.owner_table_name = 'HZ_PARTY_SITES'
		AND     hosr.status='A'
		AND     hosr.owner_table_id = l_party_site_id;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
        select count(1)
        into   l_count
        from   hz_orig_sys_references
        where  owner_table_name = 'HZ_PARTY_SITES'
        and    orig_system = 'DNB'
        and    status = 'A'
        and    trunc(nvl(end_date_active, sysdate)) >= trunc(sysdate)
        and    orig_system_reference like l_duns_number_c || '%';
          /* Bug Fix: 4305055  */
          l_orig_sys_reference_rec.orig_system_reference := l_duns_number_c || '-PS' || to_char(l_count + 1);
		l_orig_sys_reference_rec.orig_system := 'DNB';
		l_orig_sys_reference_rec.owner_table_name := 'HZ_PARTY_SITES';
		l_orig_sys_reference_rec.owner_table_id := l_party_site_id;
		l_orig_sys_reference_rec.start_date_active := sysdate;
		l_orig_sys_reference_rec.party_id := p_party_id;
		l_orig_sys_reference_rec.status := 'A';
                l_orig_sys_reference_rec.created_by_module := 'TCA_DNB_MAPPING';

		hz_orig_system_ref_pub.create_orig_system_reference(
				FND_API.G_FALSE,
				l_orig_sys_reference_rec,
				x_return_status,
				l_msg_count,
				l_msg_data);
		if x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RETURN;
		end if;
	END;

            ELSE
	        -- if the existing record has same taxable components, create a new location
		p_location_rec.location_id := null;
                arp_util.debug('HZ_MAP_PARTY_PUB.STORE_LOCATION: Location Tax Components changed, create new location');
                l_create := TRUE;
	    END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_create := TRUE;
        END;
    END IF;

    IF l_create THEN
        arp_util.debug('HZ_MAP_PARTY_PUB.STORE_LOCATION: No party site exists for this party, create ' || p_location_rec.actual_content_source );
-- Bug 3417357 : Pass p_create_new to do_store_location.
	do_store_location(
			p_location_rec,
			p_party_id,
			l_party_site_id,
			p_create_new,
			x_return_status
	);
    END IF;

   arp_util.debug('HZ_MAP_PARTY_PUB.STORE_LOCATION (-) ');


END store_location; /* update location or create party_site or (create location and party site). */


procedure do_store_location(
        p_location_rec          IN OUT NOCOPY  hz_location_v2pub.location_rec_type,
        p_party_id              IN      NUMBER,
	p_old_party_site_id     IN      NUMBER,
	p_create_new		IN	BOOLEAN,
        x_return_status         IN OUT NOCOPY  VARCHAR2
) IS
	l_party_site_rec       HZ_PARTY_SITE_V2PUB.party_site_rec_type;
        l_msg_count            NUMBER;
        l_msg_data             VARCHAR2(2000);
--	l_party_site_exist     VARCHAR2(1) := 'N';
        l_location_id          HZ_LOCATIONS.LOCATION_ID%TYPE;

BEGIN
-- Bug 3417357 : If p_create_new = TRUE, its a new party. ALWAYS create a new
--	location for new party. For party being enriched, if location is not chagned,
--	donot do anything. Else update the location.
    IF p_create_new = TRUE THEN
        p_location_rec.application_id := 222;
        p_location_rec.created_by_module := 'TCA_DNB_MAPPING';
        /* Bug Fix : 2770991 */
       	hz_location_v2pub.create_location(
                'F',
                p_location_rec,
                l_location_id,
                x_return_status,
                l_msg_count,
                l_msg_data
                );
        IF l_location_id IS NOT NULL THEN
           p_location_rec.location_id := l_location_id;
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    ELSE
    BEGIN
        --use decode function for address2, etc. because we already assigned
        --G_MISS_XXX to those columns.
        --select by UPPER(ADDRESS1) to prevent dulicate.
	SELECT location_id INTO p_location_rec.location_id
        FROM hz_locations
        WHERE UPPER(ADDRESS1)                        = UPPER(p_location_rec.ADDRESS1) AND
        UPPER(NVL(ADDRESS2, FND_API.G_MISS_CHAR))    = UPPER(decode(p_location_rec.ADDRESS2, NULL, FND_API.G_MISS_CHAR,  p_location_rec.ADDRESS2)) AND
	UPPER(NVL(ADDRESS3, FND_API.G_MISS_CHAR))    = UPPER(decode(p_location_rec.ADDRESS3, NULL, FND_API.G_MISS_CHAR,  p_location_rec.ADDRESS3)) AND
	UPPER(NVL(ADDRESS4, FND_API.G_MISS_CHAR))    = UPPER(decode(p_location_rec.ADDRESS4, NULL, FND_API.G_MISS_CHAR,  p_location_rec.ADDRESS4)) AND
	UPPER(NVL(CITY, FND_API.G_MISS_CHAR))        = UPPER(decode(p_location_rec.CITY, NULL, FND_API.G_MISS_CHAR, p_location_rec.CITY)) AND
	UPPER(NVL(STATE, FND_API.G_MISS_CHAR))       = UPPER(decode(p_location_rec.STATE, NULL, FND_API.G_MISS_CHAR, p_location_rec.STATE)) AND
	UPPER(NVL(COUNTY, FND_API.G_MISS_CHAR))      = UPPER(decode(p_location_rec.COUNTY, NULL, FND_API.G_MISS_CHAR, p_location_rec.COUNTY)) AND
	UPPER(NVL(POSTAL_CODE, FND_API.G_MISS_CHAR)) = UPPER(decode(p_location_rec.POSTAL_CODE, NULL, FND_API.G_MISS_CHAR, p_location_rec.POSTAL_CODE)) AND
	UPPER(COUNTRY)                               = UPPER(p_location_rec.COUNTRY) AND
	UPPER(NVL(PROVINCE, FND_API.G_MISS_CHAR))    = UPPER(decode(p_location_rec.PROVINCE, NULL, FND_API.G_MISS_CHAR, p_location_rec.PROVINCE)) AND
	actual_content_source                        = p_location_rec.actual_content_source AND
        rownum =1;

     EXCEPTION WHEN NO_DATA_FOUND THEN

     --
     --Location does not exist.
     --

     arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_LOCATION: No party site exists for this party: Location does not exist');
     --arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_LOCATION: p_location_rec.ORIG_SYSTEM_REFERENCE=' || p_location_rec.ORIG_SYSTEM_REFERENCE);
     --arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_LOCATION: p_location_rec.actual_content_source =' || p_location_rec.actual_content_source);

        p_location_rec.application_id := 222;
        p_location_rec.created_by_module := 'TCA_DNB_MAPPING';
        /* Bug Fix : 2770991 */
       	hz_location_v2pub.create_location(
                'F',
                p_location_rec,
                l_location_id,
                x_return_status,
                l_msg_count,
                l_msg_data
                );
        IF l_location_id IS NOT NULL THEN
           p_location_rec.location_id := l_location_id;
        END IF;

	arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_LOCATION: created location with location_id  '|| to_char(p_location_rec.location_id));

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;

     END;
    END IF;

    l_party_site_rec.party_id              := p_party_id;
    l_party_site_rec.location_id           := p_location_rec.location_id;
    l_party_site_rec.orig_system_reference := p_location_rec.orig_system_reference;
    l_party_site_rec.orig_system := 'DNB';
/*
    BEGIN

        SELECT 'Y' INTO l_party_site_exist
        FROM HZ_PARTY_SITES
        WHERE location_id = p_location_rec.location_id
        AND party_id = p_party_id
        AND actual_content_source = p_location_rec.actual_content_source
        AND status = 'A'
        AND (SYSDATE BETWEEN START_DATE_ACTIVE AND NVL(END_DATE_ACTIVE, to_date('12/31/4712','MM/DD/YYYY')))
	AND ROWNUM = 1;

    arp_util.debug(' l_party_site_exist = '|| l_party_site_exist );

    EXCEPTION WHEN NO_DATA_FOUND THEN
*/
        store_party_site(l_party_site_rec,
        	 x_return_status);

        -- if there is old party site record, end it.
        IF p_old_party_site_id IS NOT NULL THEN
	    UPDATE hz_party_sites SET END_DATE_ACTIVE = sysdate , status = 'I' WHERE party_site_id = p_old_party_site_id;
        END IF;
  --  END;
END do_store_location;



procedure store_party_site(
        p_party_site_rec	IN OUT NOCOPY 	HZ_PARTY_SITE_V2PUB.party_site_rec_type,
        x_return_status		IN OUT NOCOPY 	VARCHAR2
) IS
        l_msg_count                  NUMBER;
        l_msg_data                   VARCHAR2(2000);

        l_profile                VARCHAR2(1);
        l_mosr_mapping_exist     VARCHAR2(1);
        l_party_site_id          HZ_PARTY_SITES.PARTY_SITE_ID%TYPE;
        l_party_site_number      HZ_PARTY_SITES.PARTY_SITE_NUMBER%TYPE;
        l_count                  NUMBER;
        l_duns_number_c          hz_organization_profiles.duns_number_c%TYPE;

        CURSOR check_party_site_mosr_mapping (p_orig_system IN VARCHAR2,
                                              p_orig_system_ref IN VARCHAR2,
                                              p_owner_table_name IN VARCHAR2)
        IS
        select 'Y'
        from hz_orig_sys_references
        where orig_system = p_orig_system
        and orig_system_reference = p_orig_system_ref
        and owner_table_name = p_owner_table_name
        and status = 'A'
        and trunc(nvl(end_date_active, sysdate)) >= trunc(sysdate);

BEGIN

        arp_util.debug('HZ_MAP_PARTY_PUB.STORE_PARTY_SITE (+) ');

        --Bug 1721094: generate party site number by sequence.
	IF fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER') = 'N' THEN
           fnd_profile.put('HZ_GENERATE_PARTY_SITE_NUMBER', 'Y');
           l_profile := 'N';
	END IF;

        --MOSR changes
        --Increment the orig_system_reference counter
        IF ( instrb ( p_party_site_rec.orig_system_reference, 'PS', 1, 1) <> 0) THEN
          --get the duns_number_c from orig_system_reference
          l_duns_number_c :=
            substrb(p_party_site_rec.orig_system_reference, 0,
            instrb(p_party_site_rec.orig_system_reference, 'PS', 1 ,1)-1);
        ELSE
          l_duns_number_c := p_party_site_rec.orig_system_reference;
        END IF;

        select count(1)
        into   l_count
        from   hz_orig_sys_references
        where  owner_table_name = 'HZ_PARTY_SITES'
        and    orig_system = 'DNB'
        and    status = 'A'
        and    trunc(nvl(end_date_active, sysdate)) >= trunc(sysdate)
        and    orig_system_reference like l_duns_number_c || '%';
        /* Bug Fix: 4305055 */
        p_party_site_rec.orig_system_reference := l_duns_number_c || '-PS' || to_char(l_count + 1);

        open check_party_site_mosr_mapping ( 'DNB', p_party_site_rec.orig_system_reference, 'HZ_PARTY_SITES');
        FETCH check_party_site_mosr_mapping into l_mosr_mapping_exist;
        IF l_mosr_mapping_exist = 'Y' THEN
          p_party_site_rec.orig_system := NULL;
        ELSE
          p_party_site_rec.orig_system := 'DNB';
        END IF;
        p_party_site_rec.created_by_module     := 'TCA_DNB_MAPPING';
        p_party_site_rec.application_id := 222;
        /* Bug Fix : 2770991 */
	HZ_PARTY_SITE_V2PUB.create_party_site(
                'F',
                p_party_site_rec,
                l_party_site_id,
                l_party_site_number,
                x_return_status,
                l_msg_count,
                l_msg_data
                );
        IF l_party_site_id IS NOT NULL THEN
           p_party_site_rec.party_site_id := l_party_site_id;
        END IF;
        IF l_party_site_number IS NOT NULL THEN
           p_party_site_rec.party_site_number := l_party_site_number;
        END IF;

       --Bug 1721094: reset profile option.
       IF l_profile = 'N' THEN
          fnd_profile.put('HZ_GENERATE_PARTY_SITE_NUMBER', 'N');
       END IF;

       arp_util.debug('HZ_MAP_PARTY_PUB.STORE_PARTY_SITE: created party site with party_site_id '|| to_char(p_party_site_rec.party_site_id));
       arp_util.debug('HZ_MAP_PARTY_PUB.STORE_PARTY_SITE (-) ');


END store_party_site;


--
-- For Phone and Fax
--
/*===========================================================================+
 | PROCEDURE
 |              store_contact_point
 |
 | DESCRIPTION
 |              store contact point
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_contact_points_rec
 |                    p_phone_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure store_contact_point(
	p_contact_points_rec	IN OUT NOCOPY  hz_contact_point_v2pub.contact_point_rec_type,
        p_phone_rec	IN OUT NOCOPY 	hz_contact_point_v2pub.phone_rec_type,
        x_return_status	IN OUT NOCOPY 	VARCHAR2
) IS
	l_edi_rec       hz_contact_point_v2pub.edi_rec_type := HZ_CONTACT_POINT_v2PUB.G_MISS_EDI_REC;
	l_email_rec     hz_contact_point_v2pub.email_rec_type := HZ_CONTACT_POINT_v2PUB.G_MISS_EMAIL_REC;
	l_telex_rec     hz_contact_point_v2pub.telex_rec_type := HZ_CONTACT_POINT_v2PUB.G_MISS_TELEX_REC;
	l_web_rec       hz_contact_point_v2pub.web_rec_type := HZ_CONTACT_POINT_v2PUB.G_MISS_WEB_REC;

        l_mosr_mapping_exist         VARCHAR2(1);
        l_msg_count                  NUMBER;
        l_msg_data                   VARCHAR2(2000);
	l_object_version_number      NUMBER;
	l_contact_point_id           NUMBER;
        l_create                     BOOLEAN := FALSE;
        l_count                      NUMBER;
        l_orig_system_reference      hz_orig_sys_references.orig_system_reference%TYPE;
        l_duns_number_c              hz_organization_profiles.duns_number_c%TYPE;
	--4227564
	l_orig_sys_reference_rec     HZ_ORIG_SYSTEM_REF_PUB.orig_sys_reference_rec_type;
        l_orig_sys_ref_id	     NUMBER;

        CURSOR check_cont_point_mosr_mapping (p_orig_system IN VARCHAR2,
                                              p_orig_system_ref IN VARCHAR2,
                                              p_owner_table_name IN VARCHAR2)
        IS
        select 'Y'
        from hz_orig_sys_references
        where orig_system = p_orig_system
        and orig_system_reference = p_orig_system_ref
        and owner_table_name = p_owner_table_name
        and status = 'A'
        and trunc(nvl(end_date_active, sysdate)) >= trunc(sysdate);
BEGIN

    arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CONTACT_POINT (+) ');

    p_contact_points_rec.contact_point_type := 'PHONE';
    p_contact_points_rec.owner_table_name := 'HZ_PARTIES';
    p_contact_points_rec.contact_point_id := NULL; --Reset it.

    arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CONTACT_POINT: actual_content_source =  ' || p_contact_points_rec.actual_content_source);

	--4227564: initialize l_duns_number_c
        IF ( instrb ( p_contact_points_rec.orig_system_reference, 'CP', 1, 1) <> 0) THEN
          --get the duns_number_c from orig_system
          l_duns_number_c :=
            substrb(p_contact_points_rec.orig_system_reference, 0,
            instrb(p_contact_points_rec.orig_system_reference, '-CP', 1 ,1)-1);
        ELSE
          l_duns_number_c := p_contact_points_rec.orig_system_reference;
        END IF;

        select count(1)
        into   l_count
        from   hz_orig_sys_references
        where  owner_table_name = 'HZ_CONTACT_POINTS'
        and    orig_system = 'DNB'
        and    status = 'A'
        and    trunc(nvl(end_date_active, sysdate)) >= trunc(sysdate)
        and    orig_system_reference like l_duns_number_c || '%';

    BEGIN
    -- Bug 6002398. Modified query logic.
        SELECT contact_point_id, object_version_number, orig_system_reference
        INTO p_contact_points_rec.contact_point_id, l_object_version_number, l_orig_system_reference
        FROM
      ( SELECT contact_point_id, object_version_number, orig_system_reference,rank() over (
          partition by owner_table_id order by last_update_date desc,object_version_number desc,contact_point_id desc) r
        FROM hz_contact_points hcp
        WHERE owner_table_name = 'HZ_PARTIES'
        AND owner_table_id	 = p_contact_points_rec.owner_table_id
        AND contact_point_type = 'PHONE'
        AND phone_line_type = p_phone_rec.PHONE_LINE_TYPE
        AND actual_content_source = p_contact_points_rec.actual_content_source
        AND status = 'A'
      )
      WHERE r=1;
	arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CONTACT_POINT: contact point exists, contact_point_id =' || to_char(p_contact_points_rec.contact_point_id));

        IF p_contact_points_rec.actual_content_source <> HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE THEN
            arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CONTACT_POINT: update contact point');

            p_contact_points_rec.orig_system := NULL;
	    p_contact_points_rec.orig_system_reference := l_orig_system_reference;
            p_contact_points_rec.created_by_module := NULL;
            p_contact_points_rec.application_id := NULL;
            hz_contact_point_v2pub.update_contact_point(
                   'F',
                   p_contact_points_rec,
                   l_edi_rec,
                   l_email_rec,
                   p_phone_rec,
                   l_telex_rec,
                   l_web_rec,
                   l_object_version_number,
                   x_return_status,
                   l_msg_count,
                   l_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RETURN;
            END IF;
	--4227564
	BEGIN
		SELECT  hosr.orig_system_ref_id INTO l_orig_sys_ref_id
		FROM 	hz_orig_sys_references hosr
		WHERE 	hosr.orig_system = 'DNB'
		AND     hosr.owner_table_name = 'HZ_CONTACT_POINTS'
		AND     hosr.status='A'
		AND     hosr.owner_table_id = p_contact_points_rec.contact_point_id;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
          /* Bug Fix: 4305055 */
	  IF p_phone_rec.phone_line_type = 'GEN' THEN
	    	l_orig_sys_reference_rec.orig_system_reference := l_duns_number_c || '-CP-P'||to_char(l_count + 1);
	  ELSE
		l_orig_sys_reference_rec.orig_system_reference := l_duns_number_c || '-CP-F'||to_char(l_count + 1);
	  END IF;
		l_orig_sys_reference_rec.orig_system := 'DNB';
		l_orig_sys_reference_rec.owner_table_name := 'HZ_CONTACT_POINTS';
		l_orig_sys_reference_rec.owner_table_id := p_contact_points_rec.contact_point_id;
		l_orig_sys_reference_rec.start_date_active := sysdate;
		l_orig_sys_reference_rec.party_id := p_contact_points_rec.owner_table_id;
		l_orig_sys_reference_rec.status := 'A';
                l_orig_sys_reference_rec.created_by_module := 'TCA_DNB_MAPPING';


		hz_orig_system_ref_pub.create_orig_system_reference(
				FND_API.G_FALSE,
				l_orig_sys_reference_rec,
				x_return_status,
				l_msg_count,
				l_msg_data);
		if x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RETURN;
		end if;
	END;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           l_create := TRUE;
    END;

    IF l_create THEN
        arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CONTACT_POINT: contact point does not exist');

        --MOSR Changes
        --Increment the orig_system_reference counter
	--4227564: Moved this code to beginning of the procedure.
        /*IF ( instrb ( p_contact_points_rec.orig_system_reference, 'CP', 1, 1) <> 0) THEN
          --get the duns_number_c from orig_system
          l_duns_number_c :=
            substrb(p_contact_points_rec.orig_system_reference, 0,
            instrb(p_contact_points_rec.orig_system_reference, 'CP', 1 ,1)-1);
        ELSE
          l_duns_number_c := p_contact_points_rec.orig_system_reference;

        END IF;

        select count(1)
        into   l_count
        from   hz_orig_sys_references
        where  owner_table_name = 'HZ_CONTACT_POINTS'
        and    orig_system = 'DNB'
        and    status = 'A'
        and    trunc(nvl(end_date_active, sysdate)) >= trunc(sysdate)
        and    orig_system_reference like l_duns_number_c || '%';*/

        IF p_phone_rec.PHONE_LINE_TYPE = 'GEN'
        THEN
          p_contact_points_rec.orig_system_reference := l_duns_number_c || '-CP' || '-P' || to_char(l_count + 1);
        ElSIF p_phone_rec.PHONE_LINE_TYPE = 'FAX' AND p_phone_rec.RAW_PHONE_NUMBER IS NOT NULL THEN
          p_contact_points_rec.orig_system_reference := l_duns_number_c || '-CP' || '-F' || to_char(l_count + 1);
        END IF;

        open check_cont_point_mosr_mapping ( 'DNB', p_contact_points_rec.orig_system_reference, 'HZ_CONTACT_POINTS');
        fetch check_cont_point_mosr_mapping into l_mosr_mapping_exist;
        IF l_mosr_mapping_exist = 'Y' THEN
          p_contact_points_rec.orig_system := NULL;
        ELSE
          p_contact_points_rec.orig_system := 'DNB';
        END IF;

        p_contact_points_rec.application_id := 222;
        p_contact_points_rec.created_by_module := 'TCA_DNB_MAPPING';
     	hz_contact_point_v2pub.create_contact_point(
                'F',
                p_contact_points_rec,
                l_edi_rec,
                l_email_rec,
                p_phone_rec,
                l_telex_rec,
                l_web_rec,
		l_contact_point_id,
                x_return_status,
                l_msg_count,
                l_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;

        arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CONTACT_POINT: created contact point, contact_point_id = ' || l_contact_point_id);

    END IF;

    arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CONTACT_POINT (-) ');

END store_contact_point;



--
-- Create credit ratings.
--
/*===========================================================================+
 | PROCEDURE
 |              store_credit_ratings
 |
 | DESCRIPTION
 |              store credit ratings
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_credit_ratings_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure store_credit_ratings(
        --p_credit_ratings_rec	IN OUT NOCOPY  hz_party_info_pub.credit_ratings_rec_type,
        p_credit_ratings_rec	IN OUT NOCOPY  hz_party_info_v2pub.credit_rating_rec_type,
        x_return_status IN OUT NOCOPY  VARCHAR2
) IS
	l_rated_as_of_date	DATE;
        l_max_rated_as_of_date  DATE;
	l_credit_rating_id	NUMBER;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
	l_last_update_date1     DATE;
        l_create_credit_rating  BOOLEAN := FALSE;
        l_ovn NUMBER;

BEGIN

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CREDIT_RATINGS (+) '  );
arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CREDIT_RATINGS actual_content_source =  ' || p_credit_ratings_rec.actual_content_source );
arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CREDIT_RATINGS party_id =  ' || p_credit_ratings_rec.party_id );

     BEGIN

        SELECT MAX(rated_as_of_date)
        INTO   l_max_rated_as_of_date
        FROM   hz_credit_ratings
        WHERE  party_id = p_credit_ratings_rec.party_id
        AND    actual_content_source = p_credit_ratings_rec.actual_content_source;

        SELECT rated_as_of_date, credit_rating_id, last_update_date, object_version_number
        INTO   l_rated_as_of_date, l_credit_rating_id, l_last_update_date1, l_ovn
        FROM   hz_credit_ratings
        WHERE  party_id = p_credit_ratings_rec.party_id
        AND    actual_content_source = p_credit_ratings_rec.actual_content_source
        AND    NVL(rated_as_of_date, TO_DATE('31-12-4712', 'DD-MM-YYYY'))=
               NVL(l_max_rated_as_of_date, TO_DATE('31-12-4712', 'DD-MM-YYYY'))
        AND    rownum = 1;

        arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CREDIT_RATINGS: credit rating record exists');


        IF trunc(l_rated_as_of_date) = trunc(sysdate) THEN

	   p_credit_ratings_rec.credit_rating_id := l_credit_rating_id;
--	   p_credit_ratings_rec.actual_content_source := null;

p_credit_ratings_rec.created_by_module := NULL;
HZ_PARTY_INFO_V2PUB.update_credit_rating(
  'F',
  p_credit_ratings_rec,
  l_ovn,
  x_return_status,
  l_msg_count,
  l_msg_data);
/*
	   hz_party_info_pub.update_credit_ratings(
                1,
                'F',
                'F',
                p_credit_ratings_rec,
                l_last_update_date1,
                x_return_status,
                l_msg_count,
                l_msg_data);
*/

	   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RETURN;
           END IF;

       ELSE
          arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CREDIT_RATINGS: the existing credit rating record  is not in the same day as the new one');
          l_create_credit_rating := TRUE;
       END IF;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CREDIT_RATINGS: credit rating record not exist');
          l_create_credit_rating := TRUE;
    END;

    IF l_create_credit_rating THEN
        arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CREDIT_RATINGS: creating credit rating record ');

p_credit_ratings_rec.created_by_module := 'TCA_DNB_MAPPING';
HZ_PARTY_INFO_V2PUB.create_credit_rating(
  'F',
  p_credit_ratings_rec,
  p_credit_ratings_rec.credit_rating_id,
  x_return_status,
  l_msg_count,
  l_msg_data);
/*
	hz_party_info_pub.create_credit_ratings(
                1,
                'F',
                'F',
                p_credit_ratings_rec,
                x_return_status,
                l_msg_count,
                l_msg_data,
                p_credit_ratings_rec.credit_rating_id);
*/
  END IF;

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_CREDIT_RATINGS (-) ');

END store_credit_ratings;

--
-- Create Financial Reports.
--
/*===========================================================================+
 | PROCEDURE
 |              do_store_financial_report
 |
 | DESCRIPTION
 |              store financial report
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_new_fin_report
 |          IN/ OUT:
 |                    p_fin_rep_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure do_store_financial_report(
	p_fin_rep_rec		IN OUT NOCOPY	HZ_ORGANIZATION_INFO_V2PUB.financial_report_rec_type,
	--p_fin_rep_rec		IN OUT NOCOPY	hz_org_info_pub.financial_reports_rec_type,
	x_new_fin_report	OUT NOCOPY	VARCHAR2,
	x_return_status 	IN OUT NOCOPY  VARCHAR2
) IS
        l_msg_count                  NUMBER;
        l_msg_data                   VARCHAR2(2000);
	l_last_update_date1		DATE;
        l_create                     BOOLEAN := FALSE;
        l_ovn NUMBER;
BEGIN

  arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_REPORT (+) ');
  arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_REPORT actual_content_source =  ' || p_fin_rep_rec.actual_content_source );


  BEGIN
      SELECT financial_report_id, last_update_date, object_version_number
      INTO p_fin_rep_rec.financial_report_id, l_last_update_date1, l_ovn
      FROM hz_financial_reports
      WHERE party_id = p_fin_rep_rec.party_id
      AND ACTUAL_CONTENT_SOURCE = p_fin_rep_rec.ACTUAL_CONTENT_SOURCE

-- Bug 3202840 : User trunc while checking for DATE_REPORT_ISSED so that if it is purchased on
--		 same day, the report gets updated.
-- Bug 3223038 : Modify NVL conditions for columns DATE_REPORT_ISSUED, REPORT_START_DATE
--		 REPORT_END_DATE and ISSUED_PERIOD.

 AND (NVL(trunc(DATE_REPORT_ISSUED), to_date('12/30/4712','MM/DD/YYYY'))
        	= NVL(trunc(p_fin_rep_rec.DATE_REPORT_ISSUED), to_date('12/31/4712','MM/DD/YYYY'))

              OR (NVL(REPORT_START_DATE, to_date('12/30/4712','MM/DD/YYYY'))
		= NVL(p_fin_rep_rec.REPORT_START_DATE, to_date('12/31/4712','MM/DD/YYYY'))
	      AND NVL(REPORT_END_DATE, to_date('12/30/4712','MM/DD/YYYY'))
		= NVL(p_fin_rep_rec.REPORT_END_DATE, to_date('12/31/4712','MM/DD/YYYY')))
          OR NVL(ISSUED_PERIOD, 'Y') = NVL(p_fin_rep_rec.ISSUED_PERIOD, 'X'))
      AND NVL(TYPE_OF_FINANCIAL_REPORT, 'X') = NVL(p_fin_rep_rec.TYPE_OF_FINANCIAL_REPORT, 'X')
      AND rownum=1;

      x_new_fin_report := 'N';

-- Bug 3223038 : Pass NULL for the non updatable columns while updating the report
--		 For relationships, V1 API is used, so pass G_MISS values when
--		 we want to retain the previous values.

/*  Bug 4507494 : Pass NULL for non updatable columns
	p_fin_rep_rec.DATE_REPORT_ISSUED := FND_API.G_MISS_DATE;
	p_fin_rep_rec.REPORT_START_DATE := FND_API.G_MISS_DATE;
	p_fin_rep_rec.REPORT_END_DATE := FND_API.G_MISS_DATE;
	p_fin_rep_rec.ISSUED_PERIOD := FND_API.G_MISS_CHAR;
*/
	p_fin_rep_rec.DATE_REPORT_ISSUED := NULL;
	p_fin_rep_rec.REPORT_START_DATE := NULL;
	p_fin_rep_rec.REPORT_END_DATE := NULL;
	p_fin_rep_rec.ISSUED_PERIOD := NULL;

      arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_REPORT: Fin report already exists, contact_point_id =' || to_char(p_fin_rep_rec.financial_report_id));

      IF p_fin_rep_rec.ACTUAL_CONTENT_SOURCE <> HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE THEN
          --
          --Fin report already exists. Update it.
          --
          arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_REPORT: update financial report for DNB');

p_fin_rep_rec.created_by_module := NULL;
HZ_ORGANIZATION_INFO_V2PUB.update_financial_report(
  'F',
  p_fin_rep_rec,
  l_ovn,
  x_return_status,
  l_msg_count,
  l_msg_data);
/*
          hz_org_info_pub.update_financial_reports(
                1,
                'F',
                'F',
                p_fin_rep_rec,
                l_last_update_date1,
                x_return_status,
                l_msg_count,
                l_msg_data);
*/

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RETURN;
          END IF;
       END IF;
   EXCEPTION WHEN NO_DATA_FOUND THEN
          l_create := TRUE;
   END;


  IF l_create THEN

  --
  --Fin Report does not exist. Need to create a new one.
  --

      arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_REPORT: Fin report does not exist');

      x_new_fin_report := 'Y';

p_fin_rep_rec.created_by_module := 'TCA_DNB_MAPPING';
HZ_ORGANIZATION_INFO_V2PUB.create_financial_report(
  'F',
  p_fin_rep_rec,
  p_fin_rep_rec.financial_report_id,
  x_return_status,
  l_msg_count,
  l_msg_data);
/*
      hz_org_info_pub.create_financial_reports(
                1,
                'F',
                'F',
                p_fin_rep_rec,
                x_return_status,
                l_msg_count,
                l_msg_data,
                p_fin_rep_rec.financial_report_id);
*/

  END IF;

  arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_REPORT (-) ');

END do_store_financial_report;

/*===========================================================================+
 | PROCEDURE
 |              store_financial_report
 |
 | DESCRIPTION
 |              store financial report and financial numbers
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_fin_rep_rec
 |                    p_interface_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure store_financial_report(
        --p_fin_rep_rec   	IN OUT NOCOPY  hz_org_info_pub.financial_reports_rec_type,
        p_fin_rep_rec   	IN OUT NOCOPY  HZ_ORGANIZATION_INFO_V2PUB.financial_report_rec_type,
        p_interface_rec         IN OUT NOCOPY  HZ_PARTY_INTERFACE%ROWTYPE,
        x_return_status 	IN OUT NOCOPY  VARCHAR2
) IS
	--l_fin_num_rec           hz_org_info_pub.financial_numbers_rec_type;
	l_fin_num_rec           HZ_ORGANIZATION_INFO_V2PUB.financial_number_rec_type;
	l_new_fin_report	VARCHAR2(1);
BEGIN


  do_store_financial_report(
        	p_fin_rep_rec,
        	l_new_fin_report,
        	x_return_status);


  --
  -- Financial Numbers.
  --

  IF x_return_status = 'S' THEN
        l_fin_num_rec.financial_report_id := p_fin_rep_rec.financial_report_id;
--bug 3942332:l_fin_num_rec.content_source_type should be same as content_source_type in p_fin_rep_rec
        --l_fin_num_rec.CONTENT_SOURCE_TYPE := p_fin_rep_rec.ACTUAL_CONTENT_SOURCE;
	  l_fin_num_rec.CONTENT_SOURCE_TYPE := 'USER_ENTERED';--p_fin_rep_rec.CONTENT_SOURCE_TYPE;

        store_financial_number(
        p_interface_rec,
        l_fin_num_rec,
        l_new_fin_report,
        p_fin_rep_rec.type_of_financial_report,
        x_return_status
        );
   END IF;


END store_financial_report;


/*===========================================================================+
 | PROCEDURE
 |              store_financial_number
 |
 | DESCRIPTION
 |              store financial numbers
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_new_fin_report
 |                    p_type_of_financial_report
 |              OUT:
 |          IN/ OUT:
 |                    p_interface_rec
 |                    p_fin_num_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure store_financial_number(
        p_interface_rec         IN OUT NOCOPY  HZ_PARTY_INTERFACE%ROWTYPE,
        --p_fin_num_rec           IN OUT NOCOPY     hz_org_info_pub.financial_numbers_rec_type,
        p_fin_num_rec           IN OUT NOCOPY     HZ_ORGANIZATION_INFO_V2PUB.financial_number_rec_type,
        p_new_fin_report        IN 	VARCHAR2,
	p_type_of_financial_report	IN	VARCHAR2,
        x_return_status         IN OUT NOCOPY  VARCHAR2
) IS
        l_fin_num_tab     fin_num_table;
        i       NUMBER :=1;

        CURSOR c1 IS
        SELECT *
        FROM hz_financial_numbers
        WHERE financial_report_id = p_fin_num_rec.financial_report_id;
BEGIN

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_NUMBER (+) ');
  --bug 3953178: in case financial_number_currecy is null use pref_functional_currency of interface record.
  IF p_interface_rec.FINANCIAL_NUMBER_CURRENCY IS NULL
  THEN
     p_fin_num_rec.FINANCIAL_NUMBER_CURRENCY := p_interface_rec.PREF_FUNCTIONAL_CURRENCY;
  ELSE
     p_fin_num_rec.FINANCIAL_NUMBER_CURRENCY := p_interface_rec.FINANCIAL_NUMBER_CURRENCY;
  END IF;
  -- end of bug 3953178
  IF p_new_fin_report = 'N' THEN

	--
	--Fin report exists. fetch all fin num names.
	--

	arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_NUMBER: Fin report exists. fetch all fin num names');

        OPEN c1;
        LOOP
                FETCH c1 INTO l_fin_num_tab(i);
                i := i+1;
                EXIT WHEN c1%NOTFOUND;
        END LOOP;
        CLOSE c1;
  END IF;


  IF p_type_of_financial_report = 'BALANCE_SHEET' THEN

  --
  --Balance Sheet
  --

  arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_NUMBER: BALANCE_SHEET');

    IF p_interface_rec.CURRENT_RATIO IS NOT NULL THEN

        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'CURRENT_RATIO';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.CURRENT_RATIO;

        arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_NUMBER:' || p_fin_num_rec.FINANCIAL_NUMBER_NAME);

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;

    END IF;

    IF p_interface_rec.CASH_LIQ_ASSETS IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'CASH_LIQ_ASSETS';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.CASH_LIQ_ASSETS;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
				x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;

    END IF;

    IF p_interface_rec.ACCOUNTS_RECEIVABLE IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'ACCOUNTS_RECEIVABLE';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.ACCOUNTS_RECEIVABLE;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.ACCOUNTS_PAYABLE IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'ACCOUNTS_PAYABLE';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.ACCOUNTS_PAYABLE;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.INVENTORY IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'INVENTORY';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.INVENTORY;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.FIXED_ASSETS IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'FIXED_ASSETS';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.FIXED_ASSETS;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.TOTAL_CURRENT_ASSETS IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'TOTAL_CURRENT_ASSETS';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.TOTAL_CURRENT_ASSETS;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.TOTAL_CURR_LIABILITIES IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'TOTAL_CURR_LIABILITIES';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.TOTAL_CURR_LIABILITIES;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF x_return_status = 'S' AND p_interface_rec.TOTAL_ASSETS IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'TOTAL_ASSETS';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.TOTAL_ASSETS;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.INTANGIBLE_ASSETS IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'INTANGIBLE_ASSETS';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.INTANGIBLE_ASSETS;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.LONG_TERM_DEBT IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'LONG_TERM_DEBT';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.LONG_TERM_DEBT;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.TOT_LONG_TERM_LIAB IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'TOT_LONG_TERM_LIAB';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.TOT_LONG_TERM_LIAB;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.TOTAL_LIABILITIES IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'TOTAL_LIABILITIES';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.TOTAL_LIABILITIES;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.RETAINED_EARNINGS IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'RETAINED_EARNINGS';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.RETAINED_EARNINGS;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.NET_WORTH IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'NET_WORTH';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.NET_WORTH;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.PREVIOUS_NET_WORTH IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'PREV_NET_WORTH';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.PREVIOUS_NET_WORTH;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

-- bug fix 1502068
    IF p_interface_rec.PREVIOUS_WORKING_CAPITAL IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'PREV_WORKING_CAPITAL';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.PREVIOUS_WORKING_CAPITAL;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;


    IF p_interface_rec.TOTAL_LIAB_EQUITY IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'TOTAL_LIAB_EQUITY';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.TOTAL_LIAB_EQUITY;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.QUICK_RATIO IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'QUICK_RATIO';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.QUICK_RATIO;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;


    IF p_interface_rec.CAPITAL_AMOUNT IS NOT NULL THEN
	IF p_interface_rec.CAPITAL_TYPE_IND = '1' THEN
        	p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'ISSUED_CAPITAL';
	ELSIF p_interface_rec.CAPITAL_TYPE_IND = '2' THEN
		p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'PAID_IN_CAPITAL';
	ELSIF p_interface_rec.CAPITAL_TYPE_IND = '3' THEN
		p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'NOMINAL_CAPITAL';
	ELSIF p_interface_rec.CAPITAL_TYPE_IND = '4' THEN
		p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'AUTHORIZED_CAPITAL';
	END IF;

        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.CAPITAL_AMOUNT;
	--bug 3953178: in case capital_currency_code is null use pref_functional_currency
	IF p_interface_rec.CAPITAL_CURRENCY_CODE IS NOT NULL THEN
		p_fin_num_rec.FINANCIAL_NUMBER_CURRENCY := p_interface_rec.CAPITAL_CURRENCY_CODE;
	ELSE
	  	p_fin_num_rec.FINANCIAL_NUMBER_CURRENCY := p_interface_rec.PREF_FUNCTIONAL_CURRENCY;
	END IF;
	--end of 3953178
        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;


  ELSIF p_type_of_financial_report = 'INCOME_STATEMENT' THEN

  --
  --INCOME STATEMENT
  --

  arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_NUMBER: INCOME_STATEMENT');

  --Following financial numbers come under 'INCOME_STATEMENT':
		--Sales
                --Previous Sales
		--Cost of Sales
		--Gross Income
		--Profit Before Tax
		--Net Income
		--Dividends

    IF p_interface_rec.SALES IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'SALES';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.SALES;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.PREVIOUS_SALES IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'PREVIOUS_SALES';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.PREVIOUS_SALES;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.COST_OF_SALES IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'COST_OF_SALES';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.COST_OF_SALES;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.GROSS_INCOME IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'GROSS_INCOME';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.GROSS_INCOME;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.PROFIT_BEFORE_TAX IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'PROFIT_BEFORE_TAX';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.PROFIT_BEFORE_TAX;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.NET_INCOME IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'NET_INCOME';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.NET_INCOME;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;

    IF p_interface_rec.DIVIDENDS IS NOT NULL THEN
        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'DIVIDENDS';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.DIVIDENDS;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;
    END IF;



  ELSIF p_type_of_financial_report = 'TANGIBLE_NET_WORTH' THEN

  --
  --TANGIBLE_NET_WORTH
  --

  arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_NUMBER: TANGIBLE_NET_WORTH');

	p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'TANGIBLE_NET_WORTH';
	p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.TANGIBLE_NET_WORTH;
	--bug 3953178: in case tangible_net_worth_curr is null use pref_functional_currency
	IF p_interface_rec.TANGIBLE_NET_WORTH_CURR IS NOT NULL THEN
		p_fin_num_rec.FINANCIAL_NUMBER_CURRENCY := p_interface_rec.TANGIBLE_NET_WORTH_CURR;
	ELSE
		p_fin_num_rec.FINANCIAL_NUMBER_CURRENCY := p_interface_rec.PREF_FUNCTIONAL_CURRENCY;
	END IF;
	--end of3953178.
--	p_fin_num_rec.PROJECTED_ACTUAL_FLAG := p_interface_rec.TANGIBLE_NET_WORTH_IND;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);

  ELSIF p_type_of_financial_report = 'ANNUAL_SALES_VOLUME' THEN

  --
  --ANNUAL_SALES_VOLUME
  --

  arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_NUMBER: ANNUAL_SALES_VOLUME');

        p_fin_num_rec.FINANCIAL_NUMBER_NAME := 'ANNUAL_SALES_VOLUME';
        p_fin_num_rec.FINANCIAL_NUMBER := p_interface_rec.ANNUAL_SALES_VOLUME;
	--bug 3953178: in case annual_sales_currency is null use pref_functional_currency
	IF p_interface_rec.ANNUAL_SALES_CURRENCY IS NOT NULL THEN
        	p_fin_num_rec.FINANCIAL_NUMBER_CURRENCY := p_interface_rec.ANNUAL_SALES_CURRENCY;
	ELSE
		p_fin_num_rec.FINANCIAL_NUMBER_CURRENCY := p_interface_rec.PREF_FUNCTIONAL_CURRENCY;
	END IF;
	--end of 3953178
        --possible values of ANNUAL_SALES_EST_IND:
                --1=Actual
                --2=Estimated
                --3=Forecast
                --4=Projected
                --5=Calculated

	IF p_interface_rec.ANNUAL_SALES_EST_IND = '1' THEN
		p_fin_num_rec.PROJECTED_ACTUAL_FLAG := 'A';
	ELSIF p_interface_rec.ANNUAL_SALES_EST_IND = '2' THEN
                p_fin_num_rec.PROJECTED_ACTUAL_FLAG := 'E';
        ELSIF p_interface_rec.ANNUAL_SALES_EST_IND = '3' THEN
                p_fin_num_rec.PROJECTED_ACTUAL_FLAG := 'F';
        ELSIF p_interface_rec.ANNUAL_SALES_EST_IND = '4' THEN
                p_fin_num_rec.PROJECTED_ACTUAL_FLAG := 'P';
        ELSIF p_interface_rec.ANNUAL_SALES_EST_IND = '5' THEN
                p_fin_num_rec.PROJECTED_ACTUAL_FLAG := 'C';
	END IF;

        do_store_financial_number(p_fin_num_rec,
                                p_new_fin_report,
                                l_fin_num_tab,
                                x_return_status);
  END IF;

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_FINANCIAL_NUMBER (-) ');

  END store_financial_number;


--
-- Create Financial Numbers.
--
/*===========================================================================+
 | PROCEDURE
 |              do_store_financial_number
 |
 | DESCRIPTION
 |              store financial numbers
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_new_fin_report
 |                    p_fin_num_tab
 |              OUT:
 |          IN/ OUT:
 |                    p_fin_num_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure do_store_financial_number(
	--p_fin_num_rec		IN OUT NOCOPY hz_org_info_pub.financial_numbers_rec_type	,
	p_fin_num_rec		IN OUT NOCOPY HZ_ORGANIZATION_INFO_V2PUB.financial_number_rec_type,
        p_new_fin_report	IN 	VARCHAR2,
        p_fin_num_tab		IN	fin_num_table,
        x_return_status		IN OUT NOCOPY	VARCHAR2
) IS
	l_fin_name_exists	VARCHAR2(1) := 'N';
	l_financial_number_id	NUMBER;
        l_msg_count                  NUMBER;
        l_msg_data                   VARCHAR2(2000);
	l_last_update_date1	DATE;
        l_ovn NUMBER;
BEGIN

  arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_FINANCIAL_NUMBER (+) ');

  IF p_new_fin_report = 'Y' THEN /* financial report is new. */

  arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_FINANCIAL_NUMBER: financial report is new');

p_fin_num_rec.created_by_module := 'TCA_DNB_MAPPING';
HZ_ORGANIZATION_INFO_V2PUB.create_financial_number(
  'F',
  p_fin_num_rec,
  l_financial_number_id,
  x_return_status,
  l_msg_count,
  l_msg_data);

/*
	hz_org_info_pub.create_financial_numbers(
                1,
                'F',
                'F',
                p_fin_num_rec,
                x_return_status,
                l_msg_count,
                l_msg_data,
                l_financial_number_id);
*/
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
        END IF;

--else some fin num may be existing. check in db to see if fin num exists. If it does, update it, else create it.

  ELSE /* financial report is not new. */

     arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_FINANCIAL_NUMBER: financial report exists');

     p_fin_num_rec.financial_number_id := NULL;

     IF p_fin_num_tab.COUNT > 0 THEN
        FOR i IN p_fin_num_tab.FIRST..p_fin_num_tab.LAST LOOP
                IF p_fin_num_rec.financial_number_name = p_fin_num_tab(i).financial_number_name THEN
                    l_fin_name_exists := 'Y';
                    p_fin_num_rec.financial_number_id := p_fin_num_tab(i).financial_number_id;
                    l_last_update_date1	:= p_fin_num_tab(i).last_update_date;
                    l_ovn := p_fin_num_tab(i).object_version_number;
		    EXIT;
                END IF;
        END LOOP;
    END IF;

    IF l_fin_name_exists = 'Y' THEN

    arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_FINANCIAL_NUMBER: financial report exists: fin num exists');


p_fin_num_rec.created_by_module := NULL;
HZ_ORGANIZATION_INFO_V2PUB.update_financial_number(
  'F',
  p_fin_num_rec,
  l_ovn,
  x_return_status,
  l_msg_count,
  l_msg_data);
/*
  	hz_org_info_pub.update_financial_numbers(
                1,
                'F',
                'F',
                p_fin_num_rec,
                l_last_update_date1,
                x_return_status,
                l_msg_count,
                l_msg_data);
*/
    ELSE

	arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_FINANCIAL_NUMBER: financial report is not new: fin num does not exist');

p_fin_num_rec.created_by_module := 'TCA_DNB_MAPPING';
HZ_ORGANIZATION_INFO_V2PUB.create_financial_number(
  'F',
  p_fin_num_rec,
  l_financial_number_id,
  x_return_status,
  l_msg_count,
  l_msg_data);

/*
	hz_org_info_pub.create_financial_numbers(
                1,
                'F',
                'F',
                p_fin_num_rec,
                x_return_status,
                l_msg_count,
                l_msg_data,
                l_financial_number_id);
*/
    END IF;

  END IF; /* financial report is new. */

arp_util.debug('HZ_MAP_PARTY_PUB.D_STORE_FINANCIAL_NUMBER (-) ');

END do_store_financial_number;

/*===========================================================================+
 | PROCEDURE
 |              store_related_duns
 |
 | DESCRIPTION
 |              store financial numbers
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_commit
 |                    p_group_id
 |              OUT:
 |          IN/ OUT:
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |  19-AUG-2004  Rajib Ranjan Borah   o Bug 3107162.Status in hz_party_interface
 |                                      can be either P1 or W1. Therefore added
 |                                      W1 in cursor c1.
 |                                    o If previous status was P1, set it to P2.
 |                                      If previous status was W1, set it to W2.
 +===========================================================================*/

procedure store_related_duns(
	p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
	p_group_id		IN	NUMBER,
	x_return_status		IN OUT NOCOPY	VARCHAR2
) IS
        CURSOR c1 IS
        SELECT  * FROM
        HZ_PARTY_INTERFACE
        WHERE NVL(group_id, FND_API.G_MISS_NUM) = NVL(p_group_id, FND_API.G_MISS_NUM)
        AND status IN ('P1','W1'); -- Bug 3107162

	l_interface_rec         HZ_PARTY_INTERFACE%ROWTYPE;
	l_related_duns_rec	related_duns_rec_type;
	num_of_rec		NUMBER;
        l_profile                    VARCHAR2(1);

/* VJN INTRODUCED CHANGE BEGINS */
	    conform_party_id number;
	    conform_parent_party_id number ;
	    conform_dup_party_id number;
	    conform_gup_party_id number;
	    conform_parent_flag varchar2(1);
	    x_msg_count number;
	    x_msg_data varchar2(200) ;
/* VJN INTRODUCED CHANGE ENDS*/


--For related DUNS, open cursor here again.
BEGIN

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_RELATED_DUNS (+) ');
  OPEN c1;
  LOOP
   BEGIN
     FETCH c1 INTO l_interface_rec;
     EXIT WHEN c1%NOTFOUND;

     num_of_rec := num_of_rec + 1;

     arp_util.debug('HZ_MAP_PARTY_PUB.STORE_RELATED_DUNS: fetched record from cursor: '|| to_char(num_of_rec));


--Set Savepoint
     SAVEPOINT store_related_duns_pub;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

--VJN :: Initialize dnb hierarchy variables

	    conform_party_id := null;
	    conform_parent_party_id := null ;
	    conform_dup_party_id := null;
	    conform_gup_party_id := null;
	    conform_parent_flag := null;

     IF l_interface_rec.GDP_NAME IN ('BATCH', 'VENDOR_MGMT', 'ENT_MGMT') THEN

	arp_util.debug('HZ_MAP_PARTY_PUB.STORE_RELATED_DUNS: GDP_NAME IN (BATCH, VENDOR_MGMT, ENT_MGMT)');

	--Related DUNS info. is provided only by above products.

	l_related_duns_rec.MAIN_PARTY_ID 	:=	l_interface_rec.party_id;
	l_related_duns_rec.MAIN_DUNS_NUMBER	:=	l_interface_rec.DUNS_NUMBER; -- Bug 5440525
	l_related_duns_rec.CONTENT_SOURCE_TYPE	:=	l_interface_rec.CONTENT_SOURCE_TYPE;


	-- VJN :: GET THE DNB PURCHASEE PARTY ID
        conform_party_id := l_related_duns_rec.MAIN_PARTY_ID ;

	--
	--HQ
	--

	IF l_interface_rec.HQ_DUNS_NUMBER IS NOT NULL THEN

		arp_util.debug('HZ_MAP_PARTY_PUB.STORE_RELATED_DUNS: HQ');

		l_related_duns_rec.DUNS_NUMBER       :=      l_interface_rec.HQ_DUNS_NUMBER  ;
		l_related_duns_rec.NAME      :=      l_interface_rec.HQ_NAME ;
		l_related_duns_rec.COUNTRY   :=      l_interface_rec.HQ_COUNTRY;
		l_related_duns_rec.ADDRESS1  :=      l_interface_rec.HQ_ADDRESS1     ;
		l_related_duns_rec.CITY      :=      l_interface_rec.HQ_CITY ;
		l_related_duns_rec.PRIMARY_GEO_AREA  :=      l_interface_rec.HQ_PRIMARY_GEO_AREA     ;
		l_related_duns_rec.COUNTY    :=      l_interface_rec.HQ_COUNTY       ;
		l_related_duns_rec.POSTAL_CODE       :=      l_interface_rec.HQ_POSTAL_CODE ;
		l_related_duns_rec.PHONE_NUMBER      :=      l_interface_rec.HQ_PHONE_NUMBER ;
		l_related_duns_rec.RELATIONSHIP_TYPE := 'HEADQUARTERS/DIVISION';
		l_related_duns_rec.RELATIONSHIP_CODE := 'HEADQUARTERS_OF';

		-- VJN :::: Get the HQ party Id Information from the out variable
		do_store_related_duns(l_related_duns_rec, x_return_status, conform_parent_party_id);
                conform_parent_flag := 'H';

	END IF;
	--
	--PARENT
	--

	--
	--If DUNS=Parent DUNS (DNB should be sending the Parent data if the company is the final Parent.),
	--do_store_related_duns will not be called.
	--

	IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
	   l_interface_rec.PARENT_DUNS_NUMBER IS NOT NULL THEN

		arp_util.debug('HZ_MAP_PARTY_PUB.STORE_RELATED_DUNS: PARENT');

		l_related_duns_rec.DUNS_NUMBER   :=      l_interface_rec.PARENT_DUNS_NUMBER      ;
		l_related_duns_rec.NAME  :=      l_interface_rec.PARENT_NAME     ;
		l_related_duns_rec.COUNTRY       :=      l_interface_rec.PARENT_COUNTRY ;
		l_related_duns_rec.ADDRESS1      :=      l_interface_rec.PARENT_ADDRESS1 ;
		l_related_duns_rec.CITY  :=      l_interface_rec.PARENT_CITY     ;
		l_related_duns_rec.PRIMARY_GEO_AREA      :=      l_interface_rec.PARENT_PRIMARY_GEO_AREA ;
		l_related_duns_rec.COUNTY        :=      l_interface_rec.PARENT_COUNTY   ;
		l_related_duns_rec.POSTAL_CODE   :=      l_interface_rec.PARENT_POSTAL_CODE      ;
		l_related_duns_rec.PHONE_NUMBER  :=      l_interface_rec.PARENT_PHONE_NUMBER     ;
		l_related_duns_rec.RELATIONSHIP_TYPE := 'PARENT/SUBSIDIARY';
		l_related_duns_rec.RELATIONSHIP_CODE := 'PARENT_OF';

		-- VJN :::: Get the parent party Id Information from the out variable
		do_store_related_duns(l_related_duns_rec, x_return_status, conform_parent_party_id);
                conform_parent_flag := 'P';

	END IF;

	--
	--DOM_ULT
	--

	IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
           l_interface_rec.DOM_ULT_DUNS_NUMBER IS NOT NULL THEN

		arp_util.debug('HZ_MAP_PARTY_PUB.STORE_RELATED_DUNS: DOM_ULT');

		l_related_duns_rec.DUNS_NUMBER  :=      l_interface_rec.DOM_ULT_DUNS_NUMBER     ;
		l_related_duns_rec.NAME :=      l_interface_rec.DOM_ULT_NAME    ;
		l_related_duns_rec.COUNTRY      :=      l_interface_rec.DOM_ULT_COUNTRY;
		l_related_duns_rec.ADDRESS1     :=      l_interface_rec.DOM_ULT_ADDRESS1        ;
		l_related_duns_rec.CITY :=      l_interface_rec.DOM_ULT_CITY    ;
		l_related_duns_rec.PRIMARY_GEO_AREA:=l_interface_rec.DOM_ULT_PRIMARY_GEO_AREA;
		l_related_duns_rec.COUNTY       :=      l_interface_rec.DOM_ULT_COUNTY  ;
		l_related_duns_rec.POSTAL_CODE  :=      l_interface_rec.DOM_ULT_POSTAL_CODE    ;
		l_related_duns_rec.PHONE_NUMBER :=      l_interface_rec.DOM_ULT_PHONE_NUMBER    ;
		l_related_duns_rec.RELATIONSHIP_TYPE := 'DOMESTIC_ULTIMATE';
		l_related_duns_rec.RELATIONSHIP_CODE := 'DOMESTIC_ULTIMATE_OF';

		-- VJN :::: Get the DUP party Id Information from the out variable
		do_store_related_duns(l_related_duns_rec, x_return_status, conform_dup_party_id);

	END IF;

	--
	--GLB_ULT
	--

	IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
	   l_interface_rec.GLB_ULT_DUNS_NUMBER IS NOT NULL THEN

        	arp_util.debug('HZ_MAP_PARTY_PUB.STORE_RELATED_DUNS: GLB_ULT');

		l_related_duns_rec.DUNS_NUMBER  :=      l_interface_rec.GLB_ULT_DUNS_NUMBER     ;
		l_related_duns_rec.NAME :=      l_interface_rec.GLB_ULT_NAME    ;
		l_related_duns_rec.COUNTRY      :=      l_interface_rec.GLB_ULT_COUNTRY;
		l_related_duns_rec.ADDRESS1     :=      l_interface_rec.GLB_ULT_ADDRESS1        ;
		l_related_duns_rec.CITY :=      l_interface_rec.GLB_ULT_CITY    ;
		l_related_duns_rec.PRIMARY_GEO_AREA     :=l_interface_rec.GLB_ULT_PRIMARY_GEO_AREA;
		l_related_duns_rec.COUNTY       :=      l_interface_rec.GLB_ULT_COUNTY  ;
		l_related_duns_rec.POSTAL_CODE  :=      l_interface_rec.GLB_ULT_POSTAL_CODE     ;
		l_related_duns_rec.PHONE_NUMBER :=      l_interface_rec.GLB_ULT_PHONE_NUMBER    ;
		l_related_duns_rec.RELATIONSHIP_TYPE := 'GLOBAL_ULTIMATE';
		l_related_duns_rec.RELATIONSHIP_CODE := 'GLOBAL_ULTIMATE_OF';

		-- VJN :::: Get the GUP party Id Information from the out variable
		do_store_related_duns(l_related_duns_rec, x_return_status, conform_gup_party_id);

	END IF;

       -- VJN ::::::  CALL CONFORM PARTY SCRIPT , DEPENDING ON THE PROFILE OPTION
       --             Y --- STOP/DONT CONFORM
       --             N --- GO AHEAD AND CONFORM
       -- THE PROFILE OPTION 'HZ_DNB_HIER_STOP_CONFORM' IS INTRODUCED FOR DEBUGGING PURPOSES.
       -- IF THIS OPTION DOES NOT EXIST, THE MAPPING PROGRAM WILL ALWAYS CONFORM A PURCHASED PARTY
       -- IF THIS OPTION EXISTS, THEN CONFORMATION WILL BE AS PER THE FLAGS MENTIONED ABOVE.

       IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
          nvl(fnd_profile.value('HZ_DNB_HIER_STOP_CONFORM'),'N') = 'N'
       THEN
            IF fnd_profile.value('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
               fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'Y');
               l_profile := 'N';
            END IF;
            HZ_DNB_HIERARCHY_PVT. conform_party_to_dnb_hierarchy ( 'T', conform_party_id, conform_parent_party_id,
                                                               conform_dup_party_id, conform_gup_party_id ,
                                                               conform_parent_flag ,
                                                               x_return_status, x_msg_count, x_msg_data );
            IF l_profile = 'N' THEN
               fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'N');
            END IF;
       END IF;



     END IF; /* GDP_NAME */

	--
	--Check return status
	--

      	IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	    IF l_interface_rec.status = 'W1' THEN -- Bug 3107162
        	UPDATE hz_party_interface
        	SET status = 'W2'
        	WHERE party_interface_id = l_interface_rec.party_interface_id;
            ELSE -- i.e. previous status was 'P1'
        	UPDATE hz_party_interface
        	SET status = 'P2'
        	WHERE party_interface_id = l_interface_rec.party_interface_id;
	    END IF;

                arp_util.debug('HZ_MAP_PARTY_PUB.STORE_RELATED_DUNS: update party interface status to P2 for party_interface_id = ' || l_interface_rec.party_interface_id );

                do_update_request_log(
                    l_interface_rec.request_log_id,
                    l_interface_rec.party_id,
                    'S'
                );

                arp_util.debug('HZ_MAP_PARTY_PUB.STORE_RELATED_DUNS: update request log status to S');
		IF FND_API.to_Boolean(p_commit) THEN
                	commit;
        	END IF;

      	ELSE
		ROLLBACK to store_related_duns_pub;
                /* need to rollback the successful transactions for this record prior to failure. */
                do_update_request_log(
                    l_interface_rec.request_log_id,
                    l_interface_rec.party_id,
                    'E2'
                );

		store_error(
			p_status => 'E2',
                	p_party_interface_id => l_interface_rec.party_interface_id);


      	END IF; /* IF x_return_status = */



   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO store_related_duns_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;

                do_update_request_log(
                    l_interface_rec.request_log_id,
                    l_interface_rec.party_id,
                    'E2'
                );

		store_error(
	                p_status => 'E2',
                	p_party_interface_id => l_interface_rec.party_interface_id);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO store_related_duns_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                do_update_request_log(
                    l_interface_rec.request_log_id,
                    l_interface_rec.party_id,
                    'E2'
                );

                store_error(
                        p_status => 'E2',
                        p_party_interface_id => l_interface_rec.party_interface_id);

        WHEN OTHERS THEN
                ROLLBACK TO store_related_duns_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                do_update_request_log(
                    l_interface_rec.request_log_id,
                    l_interface_rec.party_id,
                    'E2'
                );

                store_error(
                        p_status => 'E2',
                        p_party_interface_id => l_interface_rec.party_interface_id);

   END;

  END LOOP;
  CLOSE c1;

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_RELATED_DUNS (-) ');

END store_related_duns;

/*===========================================================================+
 | PROCEDURE
 |              do_store_related_duns
 |
 | DESCRIPTION
 |              store financial numbers
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_related_duns_rec
 |              OUT:
 |          IN/ OUT:
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |	07-APR-2004	Dhaval Mehta	Bug 3550989 : Pass orig_system and orig_system_reference
 |					to org_profile record type when calling create_org API
 |	19-APR-2004     Dhaval Mehta    Bug 3020636 : While creating relationships for related parties,
 |                                         create relationships with parties having active record in
 |                                         SSM table. Do not create rel with all parties having
 |                                         active org profile records. exists - do_store_related_duns
 |
 +===========================================================================*/

procedure do_store_related_duns(
	p_related_duns_rec	IN related_duns_rec_type,
	x_return_status		IN OUT NOCOPY	VARCHAR2,
    x_conform_party_id      OUT NOCOPY number
) IS

-- Bug 3020636 : Modify the cursor to include SSM table
--		 to find active profile for related party.

	CURSOR c1 IS
	SELECT org.party_id
	FROM hz_organization_profiles org, hz_orig_sys_references ssm
	WHERE org.duns_number_c = lpad(to_char(p_related_duns_rec.DUNS_NUMBER),9,'0')
        AND org.actual_content_source = p_related_duns_rec.content_source_type
        AND org.effective_end_date is NULL
	AND org.party_id = ssm.owner_table_id
	AND ssm.owner_table_name = 'HZ_PARTIES'
	AND ssm.orig_system = 'DNB'
	AND ssm.status = 'A'
	AND rownum = 1;


	l_organization_rec      HZ_PARTY_V2PUB.organization_rec_type;
	l_location_rec          hz_location_v2pub.location_rec_type;
	l_contact_points_rec    hz_contact_point_v2pub.contact_point_rec_type;
	l_phone_rec             hz_contact_point_v2pub.phone_rec_type := HZ_CONTACT_POINT_V2PUB.G_MISS_PHONE_REC;
	l_party_rel_rec		HZ_RELATIONSHIP_V2PUB.relationship_rec_type;

	l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
	l_count			NUMBER;
	l_count2		NUMBER;
	l_organization_profile_id	NUMBER;
	l_party_id		NUMBER;
        l_profile               VARCHAR2(1);
        l_last_update_date1     DATE;
        x_party_id                      HZ_PARTIES.PARTY_ID%TYPE;
        x_party_number                  HZ_PARTIES.PARTY_NUMBER%TYPE;


BEGIN

 arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_RELATED_DUNS (+) ');

 l_organization_rec.actual_content_source := p_related_duns_rec.content_source_type;
 l_organization_rec.created_by_module :=  'TCA_DNB_MAPPING';

 l_party_rel_rec.actual_content_source	:= p_related_duns_rec.content_source_type;
 l_party_rel_rec.object_id := p_related_duns_rec.main_party_id;
 l_party_rel_rec.relationship_type := p_related_duns_rec.RELATIONSHIP_TYPE;
 l_party_rel_rec.relationship_code := p_related_duns_rec.RELATIONSHIP_CODE;
 l_party_rel_rec.subject_type := 'ORGANIZATION';
 l_party_rel_rec.object_type := 'ORGANIZATION';
 l_party_rel_rec.subject_table_name := 'HZ_PARTIES';
 l_party_rel_rec.object_table_name := 'HZ_PARTIES';
 l_party_rel_rec.created_by_module := 'TCA_DNB_MAPPING';

 l_contact_points_rec.actual_content_source	:= p_related_duns_rec.content_source_type;
 l_contact_points_rec.created_by_module :=  'TCA_DNB_MAPPING';
 l_phone_rec.PHONE_LINE_TYPE     :=      'GEN';
 -- for related duns,  only create dnb data
 l_phone_rec.RAW_PHONE_NUMBER := p_related_duns_rec.PHONE_NUMBER;

 --Bug 1736056: Default country to 'US' if it is NULL. Convert
 --lower case to upper case.
 l_location_rec.COUNTRY      :=      NVL(UPPER(p_related_duns_rec.COUNTRY), G_DEFAULT_COUNTRY_CODE) ;
 l_location_rec.ADDRESS1     :=      NVL(p_related_duns_rec.ADDRESS1, 'Not provided by DNB');
 l_location_rec.CITY         :=      p_related_duns_rec.CITY    ;
 l_location_rec.STATE	     :=      p_related_duns_rec.PRIMARY_GEO_AREA        ;
 l_location_rec.PROVINCE     :=      p_related_duns_rec.PRIMARY_GEO_AREA        ;
 l_location_rec.COUNTY       :=      p_related_duns_rec.COUNTY  ;
 l_location_rec.POSTAL_CODE  :=      p_related_duns_rec.POSTAL_CODE     ;
 l_location_rec.actual_content_source := p_related_duns_rec.content_source_type;
 l_location_rec.created_by_module :=  'TCA_DNB_MAPPING';

 --
 --If DUNS = Related DUNS, only create party relationship.
 --

 IF p_related_duns_rec.DUNS_NUMBER = p_related_duns_rec.MAIN_DUNS_NUMBER THEN
    l_party_rel_rec.subject_id := p_related_duns_rec.main_party_id;

	store_party_rel(
                        l_party_rel_rec,
                        x_return_status);
    -- VJN ::: POPULATE PASSED IN OUT VARIABLE
    x_conform_party_id := l_party_rel_rec.subject_id ;
 ELSE

   SELECT COUNT(*) INTO l_count
   FROM hz_organization_profiles
   WHERE duns_number_c = lpad(to_char(p_related_duns_rec.DUNS_NUMBER),9,'0')
   AND actual_content_source = p_related_duns_rec.content_source_type
   AND (SYSDATE BETWEEN effective_start_date AND NVL(effective_end_date, to_date('12/31/4712','MM/DD/YYYY')));

   IF l_count = 0 THEN

 --
 --party does not exist in system. create party and org profile.
 --

 arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_RELATED_DUNS: party does not exist');

	l_organization_rec.organization_name 	:= p_related_duns_rec.NAME;
	l_organization_rec.DUNS_NUMBER_C	:= lpad(to_char(p_related_duns_rec.DUNS_NUMBER),9,'0');
--Bug 3550989 : Pass orig_system and orig_system_reference to create_org API
	l_organization_rec.party_rec.orig_system := 'DNB';
        l_organization_rec.party_rec.orig_system_reference := lpad(to_char(p_related_duns_rec.DUNS_NUMBER),9,'0');

        --Bug 1721094: generate party number by sequence.
        IF fnd_profile.value('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
	   fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'Y');
           l_profile := 'N';
        END IF;

        l_organization_rec.created_by_module :=  'TCA_DNB_MAPPING';
        HZ_PARTY_V2PUB.create_organization(
                'F',
                l_organization_rec,
                x_return_status,
                l_msg_count,
                l_msg_data,
                x_party_id,
                x_party_number,
                l_organization_profile_id);
        /* Bug Fix : 2770991 */
        IF x_party_id IS NOT NULL THEN
           l_organization_rec.party_rec.party_id := x_party_id;
        END IF;
        IF x_party_number IS NOT NULL THEN
           l_organization_rec.party_rec.party_number := x_party_number;
        END IF;

        --Bug 1721094: reset profile option.
        IF l_profile = 'N' THEN
           fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'N');
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RETURN;
        END IF;

	arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_RELATED_DUNS: party does not exist: created party with party_id  ' || to_char(l_organization_rec.party_rec.party_id));
        --
        --update displayed_duns_party_id.
        --

        --arp_util.debug('HZ_MAP_PARTY_PUB.STORE_ORG: party does not exist: update displayed_duns_party_id');

        UPDATE hz_organization_profiles
        SET displayed_duns_party_id = l_organization_rec.party_rec.party_id
        WHERE  organization_profile_id = l_organization_profile_id;

       --     party_id = l_organization_rec.party_rec.party_id  AND
       --     effective_end_date is null;

       l_party_rel_rec.subject_id := l_organization_rec.party_rec.party_id;

       store_party_rel(
           l_party_rel_rec,
           x_return_status);

       -- VJN ::: POPULATE PASSED IN OUT VARIABLE
       x_conform_party_id := l_party_rel_rec.subject_id ;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RETURN;
        END IF;

        l_contact_points_rec.owner_table_id := l_organization_rec.party_rec.party_id;
--Bug 3550989 : Pass orig_system and orig_system_reference to create_org API
        l_contact_points_rec.orig_system := 'DNB';
	l_contact_points_rec.orig_system_reference := lpad(to_char(p_related_duns_rec.DUNS_NUMBER),9,'0');

        IF l_phone_rec.raw_phone_number is not null then
            store_contact_point (
                l_contact_points_rec,
                l_phone_rec,
                x_return_status);
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RETURN;
        END IF;

--Bug 3550989 : Pass orig_system and orig_system_reference to create_org API
	l_location_rec.orig_system_reference := lpad(to_char(p_related_duns_rec.DUNS_NUMBER),9,'0');
-- Bug 3417357 : Pass p_creatE_new=TRUE for new parties
        store_location (
            l_location_rec,
            l_organization_rec.party_rec.party_id,
	    TRUE,
            x_return_status);

   ELSE

 --
 --party exists. get all party ids having this DUNS.
 --

 arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_RELATED_DUNS: party exists');


    OPEN c1;
    LOOP
	FETCH c1 INTO l_party_id;
	EXIT WHEN c1%NOTFOUND;

	l_party_rel_rec.subject_id := l_party_id;
	store_party_rel(l_party_rel_rec,
			x_return_status);
	-- VJN ::: POPULATE PASSED IN OUT VARIABLE
    x_conform_party_id := l_party_rel_rec.subject_id ;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RETURN;
        END IF;

        l_contact_points_rec.owner_table_id := l_party_id;
        -- Bug 4534494: need to pass OSR
        l_contact_points_rec.orig_system := 'DNB';
    	l_contact_points_rec.orig_system_reference := lpad(to_char(p_related_duns_rec.DUNS_NUMBER),9,'0');

        IF l_phone_rec.raw_phone_number is not null then

                 store_contact_point (l_contact_points_rec,
                                      l_phone_rec,
                                      x_return_status);
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RETURN;
        END IF;
-- Bug 3417357 : Pass p_create_new=FALSE when party is updated
        -- Bug 4534494: need to pass OSR
	l_location_rec.orig_system_reference := lpad(to_char(p_related_duns_rec.DUNS_NUMBER),9,'0');

	store_location( l_location_rec,
                       	l_party_id,
			FALSE,
			x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RETURN;
        END IF;


    END LOOP;
    CLOSE c1;
   END IF;

 END IF;

 arp_util.debug('HZ_MAP_PARTY_PUB.DO_STORE_RELATED_DUNS (-) ');

END do_store_related_duns;

/*===========================================================================+
 | PROCEDURE
 |              store_party_rel
 |
 | DESCRIPTION
 |              store party relationship
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_party_rel_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |	19-APR-2004     Dhaval Mehta    o Bug 3020636 :
 |                                      1. A party can have only either a HQ or a Parent but not
 |                                         both together. For relationship_type = HEADQUARTERS/DIVISION
 |                                         or relationship_type = PARENT/SUBSIDIARY End date the previous
 |                                         relationship if exists
 |                                      2. While checking for existing relationships, end date only those
 |                                         the rel with changed duns number for subject_id
 +===========================================================================*/

procedure store_party_rel(
	p_party_rel_rec         IN OUT NOCOPY     HZ_RELATIONSHIP_V2PUB.relationship_rec_type,
        x_return_status         IN OUT NOCOPY     VARCHAR2
) IS

        CURSOR c_old_party_rel IS
           SELECT rel.relationship_id, rel.subject_id
           FROM   hz_relationships rel
           WHERE  rel.object_id = p_party_rel_rec.object_id
  	   AND    rel.relationship_code = p_party_rel_rec.relationship_code
  	   AND    rel.relationship_type = p_party_rel_rec.relationship_type
           AND    rel.actual_content_source = p_party_rel_rec.actual_content_source
  	   AND    rel.start_date <= sysdate
	   AND    NVL(rel.end_date, to_date('12/31/4712','MM/DD/YYYY')) > sysdate
           AND    rel.subject_table_name = 'HZ_PARTIES'
           AND    rel.object_table_name = 'HZ_PARTIES';
--           AND    rel.DIRECTIONAL_FLAG = 'F';

        l_msg_count                  NUMBER;
        l_msg_data                   VARCHAR2(2000);
	l_object_version_number1     NUMBER;
	l_object_version_number2     NUMBER;

	x_relationship_id	     NUMBER;
	x_party_id		     NUMBER;
        x_party_number		     hz_parties.party_number%TYPE;

        l_profile                    VARCHAR2(1);

        TYPE l_old_rel_id_table IS TABLE OF hz_relationships.relationship_id%TYPE
        INDEX BY BINARY_INTEGER;

        TYPE l_old_sub_id_table IS TABLE OF hz_relationships.subject_id%TYPE
        INDEX BY BINARY_INTEGER;

        l_old_rel_ids                l_old_rel_id_table;
        l_old_sub_ids                l_old_sub_id_table;

        l_old_duns_number            hz_organization_profiles.duns_number_c%TYPE;
        l_new_duns_number            hz_organization_profiles.duns_number_c%TYPE;
        l_old_subject_id             NUMBER;

        l_party_rel_rec              HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
        l_create_rel                 BOOLEAN := TRUE;

        i                            NUMBER := 0;

-- Bug 3020636 : Added Local variables and cursor

        l_rel_type      hz_relationships.relationship_type%TYPE;
        l_rel_code      hz_relationships.relationship_code%TYPE;
        l_rel_id        hz_relationships.relationship_id%TYPE;
        l_obj_ver_no    hz_relationships.object_version_number%TYPE;

        CURSOR c_old_parent_hq IS
           SELECT rel.relationship_id
           FROM   hz_relationships rel
           WHERE  rel.object_id = p_party_rel_rec.object_id
           AND    rel.relationship_code = l_rel_code
           AND    rel.relationship_type = l_rel_type
           AND    rel.actual_content_source = p_party_rel_rec.actual_content_source
           AND    rel.start_date <= sysdate
           AND    NVL(rel.end_date, to_date('12/31/4712','MM/DD/YYYY')) > sysdate
           AND    rel.subject_table_name = 'HZ_PARTIES'
           AND    rel.object_table_name = 'HZ_PARTIES';


BEGIN

-- Bug 3020636 : for relationship_type = HEADQUARTERS/DIVISION or
--                   relationship_type = PARENT/SUBSIDIARY
--               Check if the other type exists for the object_id.
--               a party can have only either a HQ or a Parent but not both together.
--               End date the previous relationship if exists.
if(p_party_rel_rec.relationship_type = 'PARENT/SUBSIDIARY' OR
   p_party_rel_rec.relationship_type = 'HEADQUARTERS/DIVISION') then

        if(p_party_rel_rec.relationship_code = 'PARENT_OF' and
           p_party_rel_rec.relationship_type = 'PARENT/SUBSIDIARY') then
                l_rel_type := 'HEADQUARTERS/DIVISION';
                l_rel_code := 'HEADQUARTERS_OF';
        end if;
        if(p_party_rel_rec.relationship_code = 'HEADQUARTERS_OF' and
                p_party_rel_rec.relationship_type = 'HEADQUARTERS/DIVISION') then
                l_rel_type := 'PARENT/SUBSIDIARY';
                l_rel_code := 'PARENT_OF';
        end if;

        OPEN c_old_parent_hq;
        LOOP
                FETCH c_old_parent_hq
                INTO l_rel_id;
                EXIT WHEN c_old_parent_hq%NOTFOUND;

                SELECT object_version_number INTO l_obj_ver_no
                 FROM   hz_relationships
                 WHERE  relationship_id = l_rel_id
                 AND    subject_table_name = 'HZ_PARTIES'
                 AND    object_table_name = 'HZ_PARTIES'
                 AND    DIRECTIONAL_FLAG = 'F';


                l_party_rel_rec.actual_content_source := p_party_rel_rec.actual_content_source;
                l_party_rel_rec.end_date := SYSDATE;
                l_object_version_number2 := NULL;
                l_party_rel_rec.relationship_id := l_rel_id;
                l_party_rel_rec.created_by_module := NULL;
                l_party_rel_rec.application_id := NULL;

                HZ_RELATIONSHIP_V2PUB.update_relationship(
                    'F',
                    l_party_rel_rec,
                    l_obj_ver_no,
                    l_object_version_number2,
                    x_return_status,
                    l_msg_count,
                    l_msg_data);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RETURN;
                 END IF;
        END LOOP;
        CLOSE c_old_parent_hq;
end if;

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_PARTY_REL (+) ');

        OPEN c_old_party_rel;
        LOOP
           FETCH c_old_party_rel
              INTO l_old_rel_ids(i), l_old_sub_ids(i);
           i := i+1;
           EXIT WHEN c_old_party_rel%NOTFOUND;
        END LOOP;
        CLOSE c_old_party_rel;

        IF l_old_rel_ids.COUNT = 0 THEN
           --Create party rel.
           l_create_rel := TRUE;

        ELSE
-- Bug 3020636 : Change start
-- End date only relationships with changed duns number
        l_create_rel := FALSE;
	FOR i IN l_old_rel_ids.FIRST..l_old_rel_ids.LAST LOOP
	l_old_subject_id := l_old_sub_ids(i);

	--Find the old duns number
        SELECT duns_number_c INTO l_old_duns_number
        FROM   hz_organization_profiles o
        WHERE  o.party_id = l_old_subject_id
        AND    o.effective_end_date IS NULL
        AND    o.actual_content_source = p_party_rel_rec.actual_content_source;

	--Find the new duns number
        SELECT duns_number_c INTO l_new_duns_number
        FROM   hz_organization_profiles o
        WHERE  o.party_id = p_party_rel_rec.subject_id
        AND    o.effective_end_date IS NULL
        AND    o.actual_content_source = p_party_rel_rec.actual_content_source;

	IF l_old_duns_number = l_new_duns_number THEN
              	IF l_old_sub_ids(i) = p_party_rel_rec.subject_id THEN
                	l_create_rel := FALSE;
			RETURN;
		END IF;

	ELSE
		--End date old party rel.
                SELECT object_version_number INTO l_object_version_number1
                FROM   hz_relationships
                WHERE  relationship_id = l_old_rel_ids(i)
                AND    subject_table_name = 'HZ_PARTIES'
                AND    object_table_name = 'HZ_PARTIES'
                AND    DIRECTIONAL_FLAG = 'F';

		--do not need to pass in LUD of parties as party is not updated.

                l_party_rel_rec.actual_content_source := p_party_rel_rec.actual_content_source;
                l_party_rel_rec.end_date := SYSDATE;
                l_object_version_number2 := NULL;
                l_party_rel_rec.relationship_id := l_old_rel_ids(i);
                l_party_rel_rec.created_by_module := NULL;
                l_party_rel_rec.application_id := NULL;
		HZ_RELATIONSHIP_V2PUB.update_relationship(
                    'F',
                    l_party_rel_rec,
                    l_object_version_number1,
                    l_object_version_number2,
                    x_return_status,
                    l_msg_count,
                    l_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                	RETURN;
                END IF;
		l_create_rel := TRUE;
	END IF;
	END LOOP;

-- End changes for bug 3020636
	END IF;

        IF l_create_rel THEN
            p_party_rel_rec.start_date := SYSDATE;

            --Bug 1721094: generate party number by sequence.
            IF fnd_profile.value('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
               fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'Y');
               l_profile := 'N';
            END IF;

            arp_util.debug('HZ_MAP_PARTY_PUB.store_party_rel  p_party_rel_rec.subject_id = ' || p_party_rel_rec.subject_id  );
            arp_util.debug('HZ_MAP_PARTY_PUB.store_party_rel  p_party_rel_rec.subject_type = ' || p_party_rel_rec.subject_type  );

            p_party_rel_rec.created_by_module := 'TCA_DNB_MAPPING';
            HZ_RELATIONSHIP_V2PUB.create_relationship(
                	'F',
                	p_party_rel_rec,
                	x_relationship_id,
                	x_party_id,
                	x_party_number,
                	x_return_status,
                	l_msg_count,
                	l_msg_data);

            --Bug 1721094: reset profile option.
            IF l_profile = 'N' THEN
               fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'N');
            END IF;

        END IF;

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_PARTY_REL (-) ');

END store_party_rel;

/*===========================================================================+
 | PROCEDURE
 |              store_error
 |
 | DESCRIPTION
 |              store error message
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_status
 |                    p_party_interface_id
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure store_error(
	p_status	VARCHAR2,
	p_party_interface_id	NUMBER
) IS
--	l_interface_error_id    NUMBER;
	l_message_text		VARCHAR2(2000);
	l_msg_count		NUMBER;
BEGIN

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_ERROR (+) ');


	UPDATE hz_party_interface
        SET status = p_status
        WHERE party_interface_id = p_party_interface_id;

--reset the message table index used in reading messages to point to the top of the message table.

	FND_MSG_PUB.RESET;

        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
             --   SELECT hz_party_interface_errors_s.nextval INTO l_interface_error_id from dual;

		l_message_text := FND_MSG_PUB.Get(
						p_encoded => FND_API.G_FALSE );

                INSERT INTO hz_party_interface_errors (
                        interface_error_id,
                        party_interface_id,
                        message_text,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login)
                VALUES (
                        hz_party_interface_errors_s.nextval ,
                        p_party_interface_id,
                	l_message_text,
			hz_utility_v2pub.created_by,
                        hz_utility_v2pub.creation_date,
                        hz_utility_v2pub.last_updated_by,
                        hz_utility_v2pub.last_update_date,
                        hz_utility_v2pub.last_update_login);

	END LOOP;

        COMMIT; /* commit update to hz_party_interface and inserts into hz_party_interface_errors */

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_ERROR (-) ');

END store_error;

/*===========================================================================+
 | PROCEDURE
 |              store_business_report
 |
 | DESCRIPTION
 |              Store business report into org profile.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_organization_profile_id
 |                    p_business_report
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure store_business_report(
	p_organization_profile_id	NUMBER,
	p_business_report		CLOB
) IS
BEGIN

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_BUSINESS_REPORT(+) ');

	UPDATE hz_organization_profiles
	SET business_report = p_business_report
	WHERE organization_profile_id = p_organization_profile_id;

arp_util.debug('HZ_MAP_PARTY_PUB.STORE_BUSINESS_REPORT(-) ');

END;


procedure map_conc_wrapper(
        errbuf                  OUT NOCOPY     VARCHAR2,
        retcode                 OUT NOCOPY     VARCHAR2,
        p_group_id              IN      VARCHAR2 := NULL
) IS
        l_group_id              NUMBER;

        l_x_return_status       VARCHAR2(1);
        l_x_msg_count           NUMBER;
        l_x_msg_data            VARCHAR2(2000);
        l_validation_level      NUMBER := FND_API.G_VALID_LEVEL_FULL;

        l_count                 NUMBER;
        l_msg_data              VARCHAR2(2000);
BEGIN

--convert char to number
    l_group_id         := TO_NUMBER( p_group_id );

    FND_FILE.PUT_LINE( FND_FILE.LOG,
             'Concurrent program ARHMAPSB - Map DNB data(+)' );

    map(
         1,
         FND_API.G_TRUE,
         FND_API.G_TRUE,
         l_group_id,
         l_x_return_status,
         l_x_msg_count,
         l_x_msg_data,
         null,
         l_validation_level
    );

--handle return values
    IF ( l_x_return_status <> 'S' ) THEN
       errbuf := FND_MESSAGE.GET || '     ' || SQLERRM;
       retcode := 2;
    END IF;
--reset the message table index used in reading messages to point to the top of the message table.
        FND_MSG_PUB.RESET;

--write error message into log file
       FOR l_count IN 1..l_x_msg_count LOOP
           l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
                                         FND_API.G_FALSE);
           FND_FILE.PUT_LINE( FND_FILE.LOG,
                    TO_CHAR(l_count) || ' : ' || l_msg_data );
       END LOOP;
--    END IF;

    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Concurrent program ARHMAPSB - Map DNB data(-)');

END map_conc_wrapper;

--Bug 2802598: If DNB sends lookups which do not present in TCA tables, create them dynamically.
PROCEDURE create_lookup(
    p_lookup_code                      IN VARCHAR2,
    p_lookup_type                      IN VARCHAR2,
    x_return_status                    IN OUT NOCOPY VARCHAR2
) IS

    row_id varchar2(64);
    l_dummy  VARCHAR2(1);
    l_class_code_rec  HZ_CLASSIFICATION_V2PUB.class_code_rec_type;
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);

-- Bug 3822690 : Modify the cursor for better performance
--		 1. Remove upper for lookup type
--		 2. Remove upper for lookup code
--		 3. Add view_application_id = 222
--		 4. Use fnd_lookup_values_vl for translation issues
    CURSOR c_check_lookups
    IS
    SELECT   'Y'
    FROM     fnd_lookup_values_vl
--    WHERE    upper(lookup_type) = upper(p_lookup_type)
--    AND      upper(lookup_code) = upper(p_lookup_code)
    WHERE    lookup_type = p_lookup_type
    AND	     lookup_code = p_lookup_code
    AND	     view_application_id = 222
    AND      (enabled_flag = 'Y' AND
              trunc(sysdate) BETWEEN
              trunc(NVL(start_date_active, sysdate)) AND
              trunc(NVL(end_date_active, sysdate))
             );

  BEGIN

    SAVEPOINT create_lookup;

    OPEN  c_check_lookups;
    FETCH c_check_lookups INTO l_dummy;

    IF c_check_lookups%NOTFOUND
    THEN

      --create new lookup
      Fnd_Lookup_Values_Pkg.Insert_Row(
       X_ROWID               => row_id,
       X_LOOKUP_TYPE         => p_lookup_type,
       X_SECURITY_GROUP_ID   => 0,
       X_VIEW_APPLICATION_ID => /*HZ_UTILITY_V2PUB.application_id*/222,-- Bug 3107162
       X_LOOKUP_CODE         => p_lookup_code,
       X_TAG                 => null,
       X_ATTRIBUTE_CATEGORY  => null,
       X_ATTRIBUTE1          => null,
       X_ATTRIBUTE2          => null,
       X_ATTRIBUTE3          => null,
       X_ATTRIBUTE4          => null,
       X_ENABLED_FLAG        => 'Y',
       X_START_DATE_ACTIVE   => sysdate,
       X_END_DATE_ACTIVE     => null,
       X_TERRITORY_CODE      => null,
       X_ATTRIBUTE5          => null,
       X_ATTRIBUTE6          => null,
       X_ATTRIBUTE7          => null,
       X_ATTRIBUTE8          => null,
       X_ATTRIBUTE9          => null,
       X_ATTRIBUTE10         => null,
       X_ATTRIBUTE11         => null,
       X_ATTRIBUTE12         => null,
       X_ATTRIBUTE13         => null,
       X_ATTRIBUTE14         => null,
       X_ATTRIBUTE15         => null,
       X_MEANING             => p_lookup_code,
       X_DESCRIPTION         => p_lookup_code,
       X_CREATION_DATE       => HZ_UTILITY_V2PUB.CREATION_DATE,
       X_CREATED_BY          => HZ_UTILITY_V2PUB.CREATED_BY,
       X_LAST_UPDATE_DATE    => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY     => HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN);

    END IF;
    CLOSE c_check_lookups;
    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK TO create_lookup;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
           p_encoded => FND_API.G_FALSE,
           p_count => x_msg_count,
           p_data  => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        ROLLBACK TO create_lookup ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
           p_encoded => FND_API.G_FALSE,
           p_count => x_msg_count,
           p_data  => x_msg_data);

      WHEN OTHERS THEN

        ROLLBACK TO create_lookup;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
           p_encoded => FND_API.G_FALSE,
           p_count => x_msg_count,
           p_data  => x_msg_data);

  END create_lookup;

--Bug 2802598: If DNB sends lookups which do not present in TCA tables, create them
--dynamically for
--   FAILURE_SCORE_COMMENTARY,
--   CREDIT_SCORE_COMMENTARY,
--   FAILURE_SCORE_OVERRIDE_CODE,
--   REGISTRATION_TYPE
--   LEGAL_STATUS
-- Bug 3809276
--   local_activity_code.
-- Bug 3107162.
--   TOTAL_EMP_MIN_IND,
--   TOTAL_EMPLOYEES_IND,
--   EMP_AT_PRIMARY_ADR_EST_IND
--   EMP_AT_PRIMARY_ADR_MIN_IND.
-- Bug 3848365
--   SIC_CODE1 to SIC_CODE6

PROCEDURE create_dynamic_lookups(
    p_party_interface_rec              IN     HZ_PARTY_INTERFACE%ROWTYPE,
    x_return_status                    IN OUT NOCOPY VARCHAR2
) IS

      -- bug 3809276: added a local variable to store local_activity_code_type
      l_local_activity_code_type varchar2(30);

    BEGIN

      --FAILURE_SCORE_COMMENTARY lookups
      IF p_party_interface_rec.failure_score_commentary1 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.failure_score_commentary1,
                          p_lookup_type => 'FAILURE_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.failure_score_commentary2 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.failure_score_commentary2,
                          p_lookup_type => 'FAILURE_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.failure_score_commentary3 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.failure_score_commentary3,
                          p_lookup_type => 'FAILURE_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.failure_score_commentary4 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.failure_score_commentary4,
                          p_lookup_type => 'FAILURE_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.failure_score_commentary5 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.failure_score_commentary5,
                          p_lookup_type => 'FAILURE_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.failure_score_commentary6 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.failure_score_commentary6,
                          p_lookup_type => 'FAILURE_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.failure_score_commentary7 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.failure_score_commentary7,
                          p_lookup_type => 'FAILURE_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.failure_score_commentary8 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.failure_score_commentary8,
                          p_lookup_type => 'FAILURE_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.failure_score_commentary9 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.failure_score_commentary9,
                          p_lookup_type => 'FAILURE_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.failure_score_commentary10 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.failure_score_commentary10,
                          p_lookup_type => 'FAILURE_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      --CREDIT_SCORE_COMMENTARY lookups
      IF p_party_interface_rec.credit_score_commentary1 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.credit_score_commentary1,
                          p_lookup_type => 'CREDIT_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.credit_score_commentary2 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.credit_score_commentary2,
                          p_lookup_type => 'CREDIT_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.credit_score_commentary3 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.credit_score_commentary3,
                          p_lookup_type => 'CREDIT_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.credit_score_commentary4 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.credit_score_commentary4,
                          p_lookup_type => 'CREDIT_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.credit_score_commentary5 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.credit_score_commentary5,
                          p_lookup_type => 'CREDIT_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.credit_score_commentary6 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.credit_score_commentary6,
                          p_lookup_type => 'CREDIT_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.credit_score_commentary7 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.credit_score_commentary7,
                          p_lookup_type => 'CREDIT_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.credit_score_commentary8 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.credit_score_commentary8,
                          p_lookup_type => 'CREDIT_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.credit_score_commentary9 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.credit_score_commentary9,
                          p_lookup_type => 'CREDIT_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.credit_score_commentary10 IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.credit_score_commentary10,
                          p_lookup_type => 'CREDIT_SCORE_COMMENTARY',
                          x_return_status => x_return_status
                        );
      END IF;
      --FAILURE_SCORE_OVERRIDE_CODE lookups
      IF p_party_interface_rec.failure_score_override_code IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.failure_score_override_code,
                          p_lookup_type => 'FAILURE_SCORE_OVERRIDE_CODE',
                          x_return_status => x_return_status
                        );
      END IF;
      IF p_party_interface_rec.credit_score_override_code IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.credit_score_override_code,
                          p_lookup_type => 'FAILURE_SCORE_OVERRIDE_CODE',
                          x_return_status => x_return_status
                        );
      END IF;
      --legal_status
      IF p_party_interface_rec.legal_status IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.legal_status,
                          p_lookup_type => 'LEGAL_STATUS',
                          x_return_status => x_return_status
                        );
      END IF;
      --REGISTRATION_TYPE
      IF p_party_interface_rec.registration_type IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.registration_type,
                          p_lookup_type => 'REGISTRATION_TYPE',
                          x_return_status => x_return_status
                        );
      END IF;

      --Bug: 3809276
      --LOCAL_ACTIVITY_CODE_TYPE
      l_local_activity_code_type := p_party_interface_rec.local_activity_code_type;

      IF l_local_activity_code_type = '4' OR l_local_activity_code_type = '5'
      THEN
           l_local_activity_code_type := 'NACE';
      END IF;
      IF p_party_interface_rec.local_activity_code IS NOT NULL THEN
           --create new lookup
           create_lookup(
                          p_lookup_code => p_party_interface_rec.local_activity_code,
                          p_lookup_type => l_local_activity_code_type,
                          x_return_status => x_return_status
                        );
      END IF;

      --End of bug 3809276

      -- Bug    3107162.
      IF p_party_interface_rec.total_emp_est_ind IS NOT NULL THEN
           create_lookup(
                          p_lookup_code => p_party_interface_rec.total_emp_est_ind,
                          p_lookup_type => 'TOTAL_EMP_EST_IND',
                          x_return_status => x_return_status
                        );
      END IF;

      IF p_party_interface_rec.total_emp_min_ind IS NOT NULL THEN
           create_lookup(
                          p_lookup_code => p_party_interface_rec.total_emp_min_ind,
                          p_lookup_type => 'TOTAL_EMP_MIN_IND',
                          x_return_status => x_return_status
                        );
      END IF;


      IF p_party_interface_rec.total_employees_ind IS NOT NULL THEN

           create_lookup(
                          p_lookup_code => p_party_interface_rec.total_employees_ind,
                          p_lookup_type => 'TOTAL_EMPLOYEES_INDICATOR',
                          x_return_status => x_return_status
                        );
      END IF;

      IF p_party_interface_rec.emp_at_primary_adr_est_ind IS NOT NULL THEN
           create_lookup(
                          p_lookup_code => p_party_interface_rec.emp_at_primary_adr_est_ind,
                          p_lookup_type => 'EMP_AT_PRIMARY_ADR_EST_IND',
                          x_return_status => x_return_status
                        );
      END IF;

      IF p_party_interface_rec.emp_at_primary_adr_min_ind IS NOT NULL THEN
           create_lookup(
                          p_lookup_code => p_party_interface_rec.emp_at_primary_adr_min_ind,
                          p_lookup_type => 'EMP_AT_PRIMARY_ADR_MIN_IND',
                          x_return_status => x_return_status
                        );
      END IF;

      IF p_party_interface_rec.sic_code1 IS NOT NULL THEN
           create_lookup(
                          p_lookup_code => p_party_interface_rec.sic_code1,
                          p_lookup_type => p_party_interface_rec.sic_code_type,
                          x_return_status => x_return_status
                        );
      END IF;

      IF p_party_interface_rec.sic_code2 IS NOT NULL THEN
           create_lookup(
                          p_lookup_code => p_party_interface_rec.sic_code2,
                          p_lookup_type => p_party_interface_rec.sic_code_type,
                          x_return_status => x_return_status
                        );
      END IF;

      IF p_party_interface_rec.sic_code3 IS NOT NULL THEN
           create_lookup(
                          p_lookup_code => p_party_interface_rec.sic_code3,
                          p_lookup_type => p_party_interface_rec.sic_code_type,
                          x_return_status => x_return_status
                        );
      END IF;

      IF p_party_interface_rec.sic_code4 IS NOT NULL THEN
           create_lookup(
                          p_lookup_code => p_party_interface_rec.sic_code4,
                          p_lookup_type => p_party_interface_rec.sic_code_type,
                          x_return_status => x_return_status
                        );
      END IF;

      IF p_party_interface_rec.sic_code5 IS NOT NULL THEN
           create_lookup(
                          p_lookup_code => p_party_interface_rec.sic_code5,
                          p_lookup_type => p_party_interface_rec.sic_code_type,
                          x_return_status => x_return_status
                        );
      END IF;

      IF p_party_interface_rec.sic_code6 IS NOT NULL THEN
           create_lookup(
                          p_lookup_code => p_party_interface_rec.sic_code6,
                          p_lookup_type => p_party_interface_rec.sic_code_type,
                          x_return_status => x_return_status
                        );
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;
  END create_dynamic_lookups;

END HZ_MAP_PARTY_PUB;


/
