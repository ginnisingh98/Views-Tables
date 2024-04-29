--------------------------------------------------------
--  DDL for Package Body OKI_DBI_CURRENCY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_CURRENCY_PVT" as
/* $Header: OKIRICUB.pls 120.0 2005/05/25 17:55:17 appldev noship $ */

/* function that calculates annualization_factor */
FUNCTION get_annualization_factor( p_start_date   DATE,
                                   p_end_date     DATE ) RETURN NUMBER PARALLEL_ENABLE IS
l_years       NUMBER;
l_leap_days   NUMBER;
l_start_date   DATE;
l_end_date     DATE;
l_count       NUMBER;

BEGIN
	   -- Initialize number of years and number of leap days.
	   l_years     := 0;
	   l_leap_days := 0;

	   IF(p_end_date < p_start_date)
	   THEN
	      RETURN  0;
	   END IF;
	   l_start_date := p_start_date;
	   LOOP
	      l_end_date := add_months(l_start_date,12)-1;
	      l_years := l_years+1;

	      IF( (add_months(l_start_date,12) - l_start_date) = 366)
	      THEN
	          IF(p_end_date < l_end_date)
	          THEN
	             IF( p_end_date - (add_months(p_end_date,-12) ) = 366)
	             THEN
	                l_leap_days := l_leap_days + 1;
	             END IF;
	          ELSE
	             l_leap_days := l_leap_days+1;
	          END IF;
	      END IF;
	      l_start_date := add_months(l_start_date,12);
	      EXIT WHEN (l_start_date >= p_end_date );
	   END LOOP;
	   return   1 * (365+ (l_leap_days/l_years)) / (p_end_date+1  - p_start_date);
END get_annualization_factor;


/* *********************************************************
   Function that sets
   1. Transaction to functional currency conversion rate
   2. Functional to global conversion rate
   3. Conversion date
   4. Set global missing_cur flag to FALSE in case of error
   5. set rate values to
      -1     - missing currency
      -10     - too many rows
      -11     - other errors
   Return Value:
     Conversion_date
   ********************************************************* */
 FUNCTION get_conversion_date
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
  ) RETURN DATE PARALLEL_ENABLE IS

     l_trx_func_rate    NUMBER ;
     l_conversion_date  DATE ;
     l_conversion_type  VARCHAR2(40) ;

  BEGIN
    -- Check whether or not the function was already been executed
    -- by calls to oki_dbi_currency_rate.get_dbi_global_rate or
    -- oki_dbi_currency_rate.get_dbi_global_rate
    IF (p_chr_id = NVL(OKI_DBI_CURRENCY_PVT.g_chr_id, 1)) THEN
      RETURN OKI_DBI_CURRENCY_PVT.g_conversion_date ;
    END IF ;

    OKI_DBI_CURRENCY_PVT.g_chr_id := p_chr_id ;
    OKI_DBI_CURRENCY_PVT.g_conversion_date  := NULL ;
    OKI_DBI_CURRENCY_PVT.g_trx_func_rate    := NULL ;
    OKI_DBI_CURRENCY_PVT.g_func_global_rate := NULL ;
    -- Added by Arun for secondary global currency conversion changes
    OKI_DBI_CURRENCY_PVT.g_func_sglobal_rate := NULL ;

    BEGIN
       -- Select user entered conversion rate, date, and type
       SELECT TO_NUMBER(DECODE(okc_currency_api.get_currency_type(
                                       p_func_curr_code
                                     , to_date(rul.rule_information2
                                                ,'YYYY/MM/DD HH24:MI:SS'))
                               , 'EMU',rul.rule_information3
                               , rul.rule_information1)
                           ) trx_func_rate
              , TO_DATE(rul.rule_information2, 'YYYY/MM/DD HH24:MI:SS') conversion_date
              , rul.object1_id1 conversion_type
           INTO   l_trx_func_rate
                , l_conversion_date
                , l_conversion_type
           FROM okc_rules_b rul,
                okc_rule_groups_b rgp
           WHERE rul.rule_information_category = 'CVN'
           AND rul.rgp_id     = rgp.id
           AND rgp.dnz_chr_id = p_chr_id ;

-- NEW SQL to be used from 11.5.10

 /*   select
		       h.conversion_rate trx_func_rate
              ,h.conversion_rate_date conversion_date
              , h.conversion_type
      INTO   l_trx_func_rate
                , l_conversion_date
                , l_conversion_type
      from okc_k_headers_b h
      where h.id = p_chr_id
      AND h.template_yn       = 'N'
      AND h.application_id    = 515
      AND h.scs_code IN ('SERVICE','WARRANTY');
*/
--------------------------
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- No rates was found in the rules table for this contract.
        -- Continue processing to get the default conversion date
        -- rate
        NULL ;

      WHEN TOO_MANY_ROWS THEN
        BIS_COLLECTION_UTILITIES.log(sqlerrm || '  chr_id  '||
                                     to_char(p_chr_id) ,3) ;
        OKI_DBI_CURRENCY_PVT.g_conversion_date  := NULL ;
        OKI_DBI_CURRENCY_PVT.g_trx_func_rate    := -10 ;
        OKI_DBI_CURRENCY_PVT.g_func_global_rate := -10 ;
        -- Added by Arun for secondary global currency conversion changes
        OKI_DBI_CURRENCY_PVT.g_func_sglobal_rate := -10 ;
        RETURN OKI_DBI_CURRENCY_PVT.g_conversion_date ;

      WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.log(sqlerrm || '  chr_id  '||
                                     to_char(p_chr_id) ,3) ;
        OKI_DBI_CURRENCY_PVT.g_conversion_date  := NULL ;
        OKI_DBI_CURRENCY_PVT.g_trx_func_rate    := -11 ;
        OKI_DBI_CURRENCY_PVT.g_func_global_rate := -11 ;
        -- Added by Arun for secondary global currency conversion changes
        OKI_DBI_CURRENCY_PVT.g_func_sglobal_rate := -11 ;
        RETURN OKI_DBI_CURRENCY_PVT.g_conversion_date ;
      END ;

      OKI_DBI_CURRENCY_PVT.g_conversion_date  := get_conversion_rate(p_chr_id, p_curr_code,
                                                                     p_func_curr_code,
                                                                     p_creation_date,
                                                                     l_conversion_date,
                                                                     l_conversion_type,
                                                                     l_trx_func_rate);

    RETURN OKI_DBI_CURRENCY_PVT.g_conversion_date ;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN OKI_DBI_CURRENCY_PVT.g_conversion_date ;

  END get_conversion_date ;

  /****************************************************
      Overloaded get_conversion_date function for incremental load
      Changes as part of DBI 7.0
   ********************************************************* */
  FUNCTION get_conversion_date
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conversion_date      IN  DATE
   ,  p_conversion_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
    ) RETURN DATE PARALLEL_ENABLE IS

  BEGIN

    -- Check whether or not the function was already been executed
    -- by calls to oki_dbi_currency_rate.get_dbi_global_rate or
    -- oki_dbi_currency_rate.get_dbi_global_rate
    IF (p_chr_id = NVL(OKI_DBI_CURRENCY_PVT.g_chr_id, 1)) THEN
      RETURN OKI_DBI_CURRENCY_PVT.g_conversion_date ;
    END IF ;

    OKI_DBI_CURRENCY_PVT.g_chr_id := p_chr_id ;
    OKI_DBI_CURRENCY_PVT.g_conversion_date  := NULL ;
    OKI_DBI_CURRENCY_PVT.g_trx_func_rate    := NULL ;
    OKI_DBI_CURRENCY_PVT.g_func_global_rate := NULL ;
    -- Added by Arun for secondary global currency conversion changes
    OKI_DBI_CURRENCY_PVT.g_func_sglobal_rate := NULL ;

    OKI_DBI_CURRENCY_PVT.g_conversion_date  := get_conversion_rate(p_chr_id, p_curr_code,
                                                                     p_func_curr_code,
                                                                     p_creation_date,
                                                                     p_conversion_date,
                                                                     p_conversion_type,
                                                                     p_trx_func_rate);

    RETURN OKI_DBI_CURRENCY_PVT.g_conversion_date ;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN OKI_DBI_CURRENCY_PVT.g_conversion_date ;

  END get_conversion_date ;

-- -------------------------------
-- get_conversion_rate
-- -------------------------------
/* *******************************************************
   Function to get  conversion rate and initialize gloabl variables.
   This is executed for initial load by bypassing get_conversion_date
   ******************************************************* */

Function get_conversion_rate ( p_chr_id        IN NUMBER
            		    , p_curr_code      IN VARCHAR2
                            , p_func_curr_code IN VARCHAR2
                            , p_creation_date  IN DATE
                            , p_conv_date      IN  DATE
            		    , p_conv_type      IN VARCHAR2
            		    , p_trx_func_rate  in NUMBER
   ) RETURN DATE PARALLEL_ENABLE IS

   l_success_flag     BOOLEAN := TRUE ;
   l_max_roll_days    NUMBER ;
   l_func_global_rate NUMBER ;
   -- Added by Arun for secondary global currency conversion changes
   l_func_sglobal_rate NUMBER ;
   l_conv_date   DATE;
   l_conv_type   VARCHAR2(40);
   l_trx_func_rate NUMBER;
   l_global_curr VARCHAR(30);
   -- Added by Arun for secondary global currency conversion changes
   l_sglobal_curr VARCHAR(30);
  --Added by Arun  Variables used to say whether the functional and global currencies are the same
   l_isFuncGlobalEqual_flag BOOLEAN := FALSE ;
   l_isFuncSGlobalEqual_flag BOOLEAN := FALSE ;

 BEGIN
    l_max_roll_days    := 0 ;
    l_global_curr := bis_common_parameters.get_currency_code;
     -- Added by Arun for secondary global currency conversion changes
    l_sglobal_curr := bis_common_parameters.get_secondary_currency_code;
    -- Check whether or not the function was already been executed
    -- by calls to oki_dbi_currency_rate.get_dbi_global_rate or
    -- oki_dbi_currency_rate.get_dbi_global_rate
    IF ( OKI_DBI_LOAD_CLEB_PVT.g_load_type = 'INITIAL LOAD' and
         p_chr_id = NVL(OKI_DBI_CURRENCY_PVT.g_chr_id, 1)) THEN
      RETURN OKI_DBI_CURRENCY_PVT.g_conversion_date ;
    END IF ;

    OKI_DBI_CURRENCY_PVT.g_chr_id := p_chr_id ;
    OKI_DBI_CURRENCY_PVT.g_conversion_date  := NULL ;
    OKI_DBI_CURRENCY_PVT.g_trx_func_rate    := NULL ;
    OKI_DBI_CURRENCY_PVT.g_func_global_rate := NULL ;
    -- Added by Arun for secondary global currency conversion changes
    OKI_DBI_CURRENCY_PVT.g_func_sglobal_rate := NULL ;
    l_conv_date := p_conv_date;
    l_conv_type := p_conv_type;
    l_trx_func_rate := p_trx_func_rate;

    -- If conversion date is not populated set it to the default
    -- value, creation_date
    IF (l_conv_date IS NULL) THEN
        l_conv_date := p_creation_date ;
    END IF ;

    -- If conversion type is not populated set it to the default
    -- value, BIS global conversion type profile
    IF (l_conv_type IS NULL) THEN
       l_conv_type := bis_common_parameters.get_treasury_rate_type ;
    IF (l_conv_type IS NULL) THEN
       l_conv_type := bis_common_parameters.get_rate_type ;
    END IF ;
    END IF ;



    IF (p_curr_code <> p_func_curr_code) THEN
      -- Transaction is in a currency other than the functional currency
      IF (l_trx_func_rate IS NULL) THEN
        -- Transactional to functional rate does not exist in the contract
        -- Get the transactional rate using the date and conversion type if they are in
        -- the contract, otherwise use the default values
       -- added new FII_CURRENCY pkg fix for trx - > functional euro issues
        l_trx_func_rate := fii_currency.get_rate(p_curr_code,p_func_curr_code,l_conv_date,l_conv_type);

        IF (l_trx_func_rate IS NULL OR l_trx_func_rate < 0) THEN
          -- No rate exists in the contract or no rate exists for the given
          -- conversion date and type
          --l_trx_func_rate := -1 ;
          l_success_flag  := FALSE ;
        END IF ;
      END IF ;

      OKI_DBI_CURRENCY_PVT.g_trx_func_rate    := l_trx_func_rate ;

    ELSE
      -- Transaction is in the same currency as functional currency
      OKI_DBI_CURRENCY_PVT.g_trx_func_rate    := 1 ;
      l_conv_type := null;
      IF (p_curr_code = l_global_curr ) then
        l_func_global_rate:=1;
      --  l_conv_date := null;
      -- Added by Arun for bypassing FII API Calls
        l_isFuncGlobalEqual_flag:= TRUE;
      END IF;
      IF (p_curr_code = l_sglobal_curr ) then
        l_func_sglobal_rate:=1;
      --  l_conv_date := null;
      -- Added by Arun for bypassing FII API Calls
        l_isFuncSGlobalEqual_flag:= TRUE;
      END IF;
    END IF ;

    -- Get the functional to global conversion rate
    --Find the rates only when the functional and global currencies are different
    --If condition added by Arun
    IF(NOT l_isFuncGlobalEqual_flag) THEN
    l_func_global_rate := fii_currency.get_global_rate_primary(
                                        p_func_curr_code
                                      , l_conv_date) ;
    END IF;

    IF (l_func_global_rate IS NULL OR l_func_global_rate < 0) THEN
      -- No rate exists for the given exchange date and rate type
      --l_func_global_rate := -1 ;
      l_success_flag     := FALSE ;
    END IF ;

    -- Added by Arun for secondary global currency conversion changes
    --Get the functional to secondary global conversion rate
    --Find the rates only when the functional and global currencies are different
    --If condition added by Arun
    IF(NOT l_isFuncSGlobalEqual_flag) THEN
     l_func_sglobal_rate := fii_currency.get_global_rate_secondary(
                                         p_func_curr_code
                                      , l_conv_date) ;
    END IF;

    IF (l_func_sglobal_rate IS NULL OR l_func_sglobal_rate < 0) THEN
      -- No rate exists for the given exchange date and rate type
    -- l_func_sglobal_rate := -1 ;
      l_success_flag     := FALSE ;
    END IF ;


    OKI_DBI_CURRENCY_PVT.g_func_global_rate := l_func_global_rate ;
    -- Added by Arun for secondary global currency conversion changes
    OKI_DBI_CURRENCY_PVT.g_func_sglobal_rate := l_func_sglobal_rate ;
    OKI_DBI_CURRENCY_PVT.g_conversion_date  := l_conv_date ;
    OKI_DBI_CURRENCY_PVT.g_trx_rate_type    := l_conv_type ;

    RETURN l_conv_date;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_conv_date;

  END get_conversion_rate ;
-- -------------------------------
-- get_global_currency_rate_init
-- -------------------------------
/* *******************************************************
   Function to get functional to global currency for INITIAL load
   ******************************************************* */
  FUNCTION get_dbi_global_rate_init
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conv_date      IN  DATE
   ,  p_conv_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
  ) RETURN NUMBER PARALLEL_ENABLE IS

        l_conversion_date  DATE ;
  BEGIN
    -- Check whether or not the function was already been executed
    -- by calls to oki_dbi_currency_rate.get_dbi_global_rate or
    -- oki_dbi_currency_rate.get_dbi_global_rate
     IF (p_chr_id <> NVL(OKI_DBI_CURRENCY_PVT.g_chr_id ,1)) THEN
       l_conversion_date :=  OKI_DBI_CURRENCY_PVT.get_conversion_rate(
                                 p_chr_id
                               , p_curr_code
                               , p_func_curr_code
                               , p_creation_date
			       ,p_conv_date
			       , p_conv_type
			       , p_trx_func_rate ) ;

     END IF ;
     RETURN  OKI_DBI_CURRENCY_PVT.g_func_global_rate ;
  EXCEPTION
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_CURRENCY_PVT.get_dbi_global_rate_init ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       bis_collection_utilities.put_line( ' CHR_ID  : ' || to_char(p_chr_id) ) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END get_dbi_global_rate_init ;

/* ***********************************************************************
   Function to get functional to secondary global currency for INITIAL load
   *******************************************************************/
  FUNCTION get_dbi_sglobal_rate_init
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conv_date      IN  DATE
   ,  p_conv_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
  ) RETURN NUMBER PARALLEL_ENABLE IS

     l_conversion_date  DATE ;

  BEGIN
    -- Check whether or not the conversion rate was calculated alredy for the
    -- contract by comparing the  global value of g_chr_id and the p_chr_id
    -- passed in as parameter
     IF (p_chr_id <> NVL(OKI_DBI_CURRENCY_PVT.g_chr_id ,1)) THEN
       l_conversion_date :=  OKI_DBI_CURRENCY_PVT.get_conversion_rate(
                                 p_chr_id
                               , p_curr_code
                               , p_func_curr_code
                               , p_creation_date
 		            	       , p_conv_date
			                   , p_conv_type
			                   , p_trx_func_rate ) ;

     END IF ;
     RETURN  OKI_DBI_CURRENCY_PVT.g_func_sglobal_rate ;
  EXCEPTION
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_CURRENCY_PVT.get_dbi_sglobal_rate_init ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       bis_collection_utilities.put_line( ' CHR_ID  : ' || to_char(p_chr_id) ) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END get_dbi_sglobal_rate_init ;

-- -------------------------------
-- get_global_currency_rate
-- -------------------------------
/* *******************************************************
   Function to get functional to global currency conversion rate
   ******************************************************* */
  FUNCTION get_dbi_global_rate
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conversion_date      IN  DATE
   ,  p_conversion_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
  ) RETURN NUMBER PARALLEL_ENABLE IS

  l_conversion_date  DATE ;

  BEGIN
    -- Check whether or not the function was already been executed
    -- by calls to oki_dbi_currency_rate.get_dbi_global_rate or
    -- oki_dbi_currency_rate.get_dbi_global_rate
     IF (p_chr_id <> NVL(OKI_DBI_CURRENCY_PVT.g_chr_id ,1)) THEN
       l_conversion_date :=  OKI_DBI_CURRENCY_PVT.get_conversion_date(
                                 p_chr_id
                                , p_curr_code
                                , p_func_curr_code
                                , p_creation_date
   				, p_conversion_date
				, p_conversion_type
				, p_trx_func_rate ) ;

     END IF ;
     RETURN  OKI_DBI_CURRENCY_PVT.g_func_global_rate ;
  EXCEPTION
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_CURRENCY_PVT.get_dbi_global_rate ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       bis_collection_utilities.put_line( ' CHR_ID  : ' || to_char(p_chr_id) ) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END get_dbi_global_rate ;

-- -------------------------------
-- get_secondary_global_currency_rate
-- -------------------------------
/* ****************************************************************************
   Function to get functional to secondary  global currency conversion rate
                                                    during Incremental load
   **************************************************************************/
  FUNCTION get_dbi_sglobal_rate
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conversion_date      IN  DATE
   ,  p_conversion_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
  ) RETURN NUMBER PARALLEL_ENABLE IS

     l_conversion_date  DATE ;

  BEGIN
    -- Check whether or not the conversion rate was calculated alredy for the
    -- contract by comparing the  global value of g_chr_id and the p_chr_id
    -- passed in as parameter
     IF (p_chr_id <> NVL(OKI_DBI_CURRENCY_PVT.g_chr_id ,1)) THEN
       l_conversion_date :=  OKI_DBI_CURRENCY_PVT.get_conversion_date(
                                 p_chr_id
                               , p_curr_code
                               , p_func_curr_code
                               , p_creation_date
  			       , p_conversion_date
			       , p_conversion_type
			       , p_trx_func_rate ) ;

     END IF ;
     RETURN  OKI_DBI_CURRENCY_PVT.g_func_sglobal_rate ;
  EXCEPTION
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_CURRENCY_PVT.get_dbi_sglobal_rate ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       bis_collection_utilities.put_line( ' CHR_ID  : ' || to_char(p_chr_id) ) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END get_dbi_sglobal_rate ;

/* *******************************************************
   Function to get transaction to functional currency conversion rate
   ******************************************************* */
  FUNCTION get_trx_func_rate
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conversion_date      IN  DATE
   ,  p_conversion_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
  ) RETURN NUMBER PARALLEL_ENABLE IS

     l_conversion_date   DATE ;

  BEGIN
    -- Check whether or not the function was already been executed
    -- by calls to oki_dbi_currency_rate.get_dbi_global_rate or
    -- oki_dbi_currency_rate.get_dbi_global_rate
     IF (p_chr_id <> NVL(OKI_DBI_CURRENCY_PVT.g_chr_id,1)) THEN
       l_conversion_date :=  OKI_DBI_CURRENCY_PVT.get_conversion_date(
                                 p_chr_id
                               , p_curr_code
                               , p_func_curr_code
                               , p_creation_date
                               , p_conversion_date
                               , p_conversion_type
                               , p_trx_func_rate ) ;

     END IF ;
     RETURN  OKI_DBI_CURRENCY_PVT.g_trx_func_rate ;
  EXCEPTION
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_CURRENCY_PVT.get_trx_func_rate ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       bis_collection_utilities.put_line( ' CHR_ID  : ' || to_char(p_chr_id) ) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END get_trx_func_rate ;

-----------------------
/* *******************************************************
   Function to get transaction to functional conversion rate Initially
   ******************************************************* */
  FUNCTION get_trx_func_rate_init
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conv_date      IN  DATE
   ,  p_conv_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
  ) RETURN NUMBER PARALLEL_ENABLE IS

     l_conversion_date   DATE ;

  BEGIN
    -- Check whether or not the function was already been executed
    -- by calls to oki_dbi_currency_rate.get_dbi_global_rate or
    -- oki_dbi_currency_rate.get_dbi_global_rate
     IF (p_chr_id <> NVL(OKI_DBI_CURRENCY_PVT.g_chr_id,1)) THEN
       l_conversion_date :=  OKI_DBI_CURRENCY_PVT.get_conversion_rate(
                                 p_chr_id
                               , p_curr_code
                               , p_func_curr_code
                               , p_creation_date
			       , p_conv_date
			       , p_conv_type
			       , p_trx_func_rate  ) ;

     END IF ;
     RETURN  OKI_DBI_CURRENCY_PVT.g_trx_func_rate ;
  EXCEPTION
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_CURRENCY_PVT.get_trx_func_rate_init ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       bis_collection_utilities.put_line( ' CHR_ID  : ' || to_char(p_chr_id) ) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END get_trx_func_rate_init ;


/*******************************************************************************
 Description: Function to get functional rate type
*******************************************************************************/
  FUNCTION get_trx_rate_type
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conversion_date      IN  DATE
   ,  p_conversion_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
  ) RETURN VARCHAR2 IS

  l_conversion_date   DATE ;

  BEGIN
    -- If oki_dbi_currency_pvt.get_conversion_date has already been called,
    -- then oki_dbi_currency_pvt.g_trx_rate_type has already been set.
    -- There is no need to call it again to set the value.
    IF (p_chr_id <> NVL(OKI_DBI_CURRENCY_PVT.g_chr_id, 1)) THEN
      l_conversion_date :=  OKI_DBI_CURRENCY_PVT.get_conversion_date(
                                 p_chr_id
                               , p_curr_code
                               , p_func_curr_code
                               , p_creation_date
                               , p_conversion_date
                               , p_conversion_type
                               , p_trx_func_rate ) ;

    END IF ;
    RETURN  OKI_DBI_CURRENCY_PVT.g_trx_rate_type ;
  EXCEPTION
    WHEN OTHERS THEN
      bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
      fnd_message.set_name(  application => 'FND'
                           , name        => 'CRM-DEBUG ERROR' ) ;
      fnd_message.set_token(  token => 'ROUTINE'
                            , value => 'OKI_DBI_CURRENCY_PVT.get_trx_rate_type ' ) ;
      bis_collection_utilities.put_line(fnd_message.get) ;
      bis_collection_utilities.put_line( ' CHR_ID  : ' || to_char(p_chr_id) ) ;
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
  END get_trx_rate_type ;
-----------------------
/*******************************************************************************
 Description: Function to get functional rate type for Initial load
*******************************************************************************/
  FUNCTION get_trx_rate_type_init
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conv_date      IN  DATE
   ,  p_conv_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
  ) RETURN VARCHAR2 PARALLEL_ENABLE IS

  l_conversion_date   DATE ;

  BEGIN
    -- If oki_dbi_currency_pvt.get_conversion_rate has already been called,
    -- then oki_dbi_currency_pvt.g_trx_rate_type has already been set.
    -- There is no need to call it again to set the value.
    IF (p_chr_id <> NVL(OKI_DBI_CURRENCY_PVT.g_chr_id, 1)) THEN
      l_conversion_date :=  OKI_DBI_CURRENCY_PVT.get_conversion_rate(
                                 p_chr_id
                               , p_curr_code
                               , p_func_curr_code
                               , p_creation_date  ,p_conv_date
			       , p_conv_type
			       , p_trx_func_rate ) ;

    END IF ;
    RETURN  OKI_DBI_CURRENCY_PVT.g_trx_rate_type ;
  EXCEPTION
    WHEN OTHERS THEN
      bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
      fnd_message.set_name(  application => 'FND'
                           , name        => 'CRM-DEBUG ERROR' ) ;
      fnd_message.set_token(  token => 'ROUTINE'
                            , value => 'OKI_DBI_CURRENCY_PVT.get_trx_rate_type_init ' ) ;
      bis_collection_utilities.put_line(fnd_message.get) ;
      bis_collection_utilities.put_line( ' CHR_ID  : ' || to_char(p_chr_id) ) ;
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
  END get_trx_rate_type_init ;

END OKI_DBI_CURRENCY_PVT;

/
