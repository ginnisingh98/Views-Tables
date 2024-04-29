--------------------------------------------------------
--  DDL for Package Body OZF_SUPP_TRADE_PROFILE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SUPP_TRADE_PROFILE_PUB" as
/* $Header: ozfpstpb.pls 120.0.12010000.12 2010/04/14 06:22:46 amlal noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_SUPP_TRADE_PROFILE_PVT
-- Purpose
-- End of Comments
-- ===============================================================
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_SUPP_TRADE_PROFILE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfpstpb.pls';

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);



---------------------------------------------------------------------
-- PROCEDURE
--    Validate_GL_KeyFlex_val
--
-- PURPOSE
--    This procedure validates the GL Key flex code
--Parameters
--      p_supp_trade_profile_rec   -Header Recordset
--      x_return_status - Result
---------------------------------------------------------------------

 PROCEDURE Validate_GL_KeyFlex_val(
    p_combination_id		IN		VARCHAR2 ,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count                 OUT NOCOPY	NUMBER,
    x_msg_data                  OUT NOCOPY	VARCHAR2
 )
 IS

 L_API_NAME                  CONSTANT         VARCHAR2(30)	               := 'Validate_GL_KeyFlex_val';
 l_combination_id                             NUMBER                           := -1 ;

 CURSOR c_get_comb IS
 SELECT count(1) FROM GL_CODE_COMBINATIONS_KFV
 WHERE code_combination_id = p_combination_id ;

 BEGIN
	IF g_debug THEN
	    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Starts' );
        END IF;
	x_return_status := FND_API.g_ret_sts_success ;

        OPEN c_get_comb;
        FETCH c_get_comb INTO l_combination_id ;

        IF(c_get_comb%NOTFOUND) THEN
	    IF g_debug THEN
	       ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' The Key flex comination Id is invalid' );
            END IF;

	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	        FND_MESSAGE.set_name('OZF', 'The Key flex comination Id is invalid');
		FND_MSG_PUB.add;
            END IF;

	    RAISE FND_API.G_EXC_ERROR ;

        END IF ;

        CLOSE c_get_comb ;

  EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug THEN
	       ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm );
       END IF;

 END Validate_GL_KeyFlex_val ;


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Supp_Trade_Profile
--
-- PURPOSE
--    This procedure validates Supplier trade profile record
--Parameters
--      p_supp_trade_profile_rec   -Header Recordset
--      x_return_status - Result
---------------------------------------------------------------------

PROCEDURE Validate_Supp_Trade_Profile(
    p_init_msg_list              IN		VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY	VARCHAR2,
    x_msg_count                  OUT NOCOPY	NUMBER,
    x_msg_data                   OUT NOCOPY	VARCHAR2,
    p_supp_trade_profile_rec     IN OUT NOCOPY	supp_trade_profile_rec_type
   )

IS

   L_API_NAME                  CONSTANT         VARCHAR2(30)	               := 'Validate_Supp_Trade_Profile';
   l_supp_site_count	                        NUMBER                         := 0  ;
   l_cut_acct_comb_count                        NUMBER                         := 0  ;
   l_comn_chan_count                            NUMBER                         := 0  ;
   l_sett_inc_count                             NUMBER                         := 0  ;
   l_sett_dec_count                             NUMBER                         := 0  ;
   l_cust_sett_count                            NUMBER                         := 0  ;
   l_freq_unit_count                            NUMBER                         := 0  ;
   l_comp_baisis_count                          NUMBER                         := 0  ;
   l_org_count                                  NUMBER			       := 0  ;
   l_cust_count                                 NUMBER                         := 0  ;
   l_exec_error                                 VARCHAR2(1)		       := 'N' ;

BEGIN

   IF g_debug THEN
	       ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Starts' );
    END IF;
   x_return_status := FND_API.g_ret_sts_success;


    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;



   -- The Org_id should not be null
    IF ( (p_supp_trade_profile_rec.supp_trade_profile_id IS NULL OR
         p_supp_trade_profile_rec.supp_trade_profile_id = FND_API.g_miss_num) AND
         (p_supp_trade_profile_rec.org_id IS NULL OR
         p_supp_trade_profile_rec.org_id = FND_API.g_miss_num)) THEN


	IF g_debug THEN
	       ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' The Org Id is null' );
        END IF;
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	        FND_MESSAGE.set_name('OZF', 'OZF_INVALID_ORG_ID');
		FND_MSG_PUB.add;
         END IF;
	 RAISE FND_API.G_EXC_ERROR ;

    ELSE

	SELECT COUNT(1) INTO l_org_count
	FROM hr_operating_units
	WHERE organization_id=p_supp_trade_profile_rec.org_id ;

	IF ( l_org_count = 0 ) THEN
		IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' The Org Id is not valid' );
                END IF;

		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('OZF', 'OZF_INVALID_ORG_ID');
			FND_MSG_PUB.add;
		END IF;
		RAISE FND_API.G_EXC_ERROR ;
	END IF;

    END IF ;



    -- Validate approval_communication,request_communication,claim_communication

    IF (p_supp_trade_profile_rec.approval_communication <>FND_API.g_miss_char AND
        p_supp_trade_profile_rec.approval_communication IS NOT NULL ) THEN

	SELECT COUNT(*) INTO l_comn_chan_count
	FROM ozf_lookups
	WHERE lookup_type='OZF_CLAIM_COMMUNICATION'
	AND lookup_code = p_supp_trade_profile_rec.approval_communication ;

	IF l_comn_chan_count=0 THEN

	     IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid Claim Communication Channel' );
              END IF;

	     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	        FND_MESSAGE.set_name('OZF', 'Invalid Approval Communication channel'); -- Select Valid Approval Communication Channel
		FND_MSG_PUB.add;
             END IF;
	     RAISE FND_API.G_EXC_ERROR ;
	END IF ;

    END IF ;


    IF ( p_supp_trade_profile_rec.pre_approval_flag = 'Y'
	 AND
         (p_supp_trade_profile_rec.approval_communication IS NULL OR p_supp_trade_profile_rec.approval_communication = FND_API.g_miss_char) ) THEN

	    IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid approval Communication Channel' );
             END IF;

	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	        FND_MESSAGE.set_name('OZF', 'OZF_APPR_COMM_VALIDATION');
		FND_MSG_PUB.add;
	        RAISE FND_API.G_EXC_ERROR ;
            END IF;

    END IF ;


    IF (p_supp_trade_profile_rec.request_communication <>FND_API.g_miss_char
        AND p_supp_trade_profile_rec.request_communication IS NOT NULL ) THEN

    	SELECT COUNT(*) INTO l_comn_chan_count
	FROM ozf_lookups
	WHERE lookup_type='OZF_REQ_COMMUNICATION'
	AND lookup_code = p_supp_trade_profile_rec.request_communication ;

	IF l_comn_chan_count=0 THEN

	      IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid request Communication Channel' );
             END IF;

	      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	         FND_MESSAGE.set_name('OZF', 'Invalid Request Communication Channel'); -- Select Valed Request Communication Channel
		 FND_MSG_PUB.add;
	       END IF;
	       RAISE FND_API.G_EXC_ERROR ;
	END IF ;

    END IF ;


    IF (p_supp_trade_profile_rec.claim_communication <>FND_API.g_miss_char
        AND p_supp_trade_profile_rec.claim_communication IS NOT NULL) THEN

    	SELECT COUNT(*) INTO l_comn_chan_count
	FROM ozf_lookups
	WHERE lookup_type='OZF_CLAIM_COMMUNICATION'
	AND lookup_code = p_supp_trade_profile_rec.claim_communication ;

	IF l_comn_chan_count=0 THEN

	    IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid claim Communication Channel' );
             END IF;
	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	        FND_MESSAGE.set_name('OZF', 'Invalid Claim Communication Channel'); -- Select Valid Claim Communication channel
		FND_MSG_PUB.add;
	    END IF;
	     RAISE FND_API.G_EXC_ERROR ;
	END IF ;

    END IF ;

    IF ( p_supp_trade_profile_rec.auto_debit          = 'Y'
	 AND
         (p_supp_trade_profile_rec.claim_communication <>FND_API.g_miss_char AND p_supp_trade_profile_rec.claim_communication IS NOT NULL) ) THEN

	    IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid claim Communication + autodebit combination' );
             END IF;
	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	        FND_MESSAGE.set_name('OZF', 'OZF_AUTO_DEBIT_VALIDATION');
		FND_MSG_PUB.add;
	    END IF;
	    RAISE FND_API.G_EXC_ERROR ;

    END IF ;


    --Validate settlement_method_supplier_inc,settlement_method_supplier_dec and settlement_method_customer

    IF ( p_supp_trade_profile_rec.settlement_method_supplier_inc <>FND_API.g_miss_char
        AND p_supp_trade_profile_rec.settlement_method_supplier_inc IS NOT NULL ) THEN

        SELECT COUNT(*) INTO l_sett_inc_count
	FROM  ozf_claim_sttlmnt_methods_all cs,
	      ozf_lookups ol
        WHERE cs.settlement_method = ol.lookup_code
          AND ol.lookup_type = 'OZF_PAYMENT_METHOD'
          AND cs.source_object_class='PPINCVENDOR'
          AND cs.org_id = p_supp_trade_profile_rec.org_id
	  AND ol.lookup_code = p_supp_trade_profile_rec.settlement_method_supplier_inc ;


	  IF ( l_sett_inc_count=0 ) THEN

	      IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Settelemnt method INC is invalid' );
             END IF;
	      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	        FND_MESSAGE.set_name('OZF', 'OZF_DEF_SET_METH_INC'); -- Select valid value for Default Settlement for Supplier Price Increase Claims
		FND_MSG_PUB.add;
              END IF;
	      RAISE FND_API.G_EXC_ERROR ;
	  END IF ;

    END IF ;


    IF ( p_supp_trade_profile_rec.settlement_method_supplier_dec <>FND_API.g_miss_char
	 AND p_supp_trade_profile_rec.settlement_method_supplier_dec IS NOT NULL ) THEN

        SELECT COUNT(*) INTO l_sett_dec_count
	FROM  ozf_claim_sttlmnt_methods_all cs,
	      ozf_lookups ol
        WHERE cs.settlement_method = ol.lookup_code
          AND ol.lookup_type = 'OZF_PAYMENT_METHOD'
          AND cs.source_object_class='PPVENDOR'
          AND cs.org_id = p_supp_trade_profile_rec.org_id
	  AND ol.lookup_code = p_supp_trade_profile_rec.settlement_method_supplier_dec ;


	  IF ( l_sett_dec_count = 0 ) THEN

		IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Settelemnt method DEC is invalid' );
                END IF;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name('OZF', 'OZF_DEF_SET_METH_DEC'); --Select valid value for Default Settlement for Supplier Price Decrease Claims
		   FND_MSG_PUB.add;
                END IF;
		RAISE FND_API.G_EXC_ERROR ;
	  END IF ;

    END IF ;

    IF ( p_supp_trade_profile_rec.settlement_method_customer <>FND_API.g_miss_char
        AND p_supp_trade_profile_rec.settlement_method_customer IS NOT NULL ) THEN

        SELECT COUNT(*) INTO l_cust_sett_count
	FROM  ozf_claim_sttlmnt_methods_all cs,
	      ozf_lookups ol
        WHERE cs.settlement_method = ol.lookup_code
          AND ol.lookup_type = 'OZF_PAYMENT_METHOD'
          AND cs.source_object_class='PPCUSTOMER'
          AND cs.org_id = p_supp_trade_profile_rec.org_id
	  AND ol.lookup_code = p_supp_trade_profile_rec.settlement_method_customer ;


	  IF ( l_cust_sett_count = 0 ) THEN

		IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Settelemnt method Customer is invalid' );
                END IF;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN

	           FND_MESSAGE.set_name('OZF', 'OZF_DEF_SET_METH_CUST'); -- Select Valid value for Default Settlement for Customer Claims
		   FND_MSG_PUB.add;
                END IF;
		RAISE FND_API.G_EXC_ERROR ;
	  END IF ;

    END IF ;


    -- Validate default_days_covered(4), authorization_period(4), grace_days(4), qty_increase_tolerance(10)

    IF ( p_supp_trade_profile_rec.default_days_covered <>FND_API.g_miss_num
         AND
	 p_supp_trade_profile_rec.default_days_covered IS NOT NULL
	 AND
	 p_supp_trade_profile_rec.default_days_covered NOT BETWEEN 0 AND 9999
	) THEN

		IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid default days covered' );
                END IF;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN

		   FND_MESSAGE.set_name('OZF', 'OZF_DEFAULT_DAYS_INVALID_VAL');
		   FND_MSG_PUB.add;
                END IF;
		 RAISE FND_API.G_EXC_ERROR ;

    END IF ;


    IF ( p_supp_trade_profile_rec.authorization_period <>FND_API.g_miss_num
         AND
	 p_supp_trade_profile_rec.authorization_period IS NOT NULL
	 AND
	 p_supp_trade_profile_rec.authorization_period NOT BETWEEN 0 AND 9999
	) THEN

		IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid authorization period' );
                END IF;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name('OZF', 'OZF_AUTH_PERIOD_INVALID_VAL');
		   FND_MSG_PUB.add;
                END IF;
	        RAISE FND_API.G_EXC_ERROR ;

    END IF ;


    IF ( p_supp_trade_profile_rec.grace_days <>FND_API.g_miss_num
         AND
	 p_supp_trade_profile_rec.grace_days IS NOT NULL
	 AND
	 p_supp_trade_profile_rec.grace_days NOT BETWEEN 0 AND 9999
	) THEN

		IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid grace days' );
                END IF;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name('OZF', 'OZF_GRACE_DAYS_INVALID_VAL');
		   FND_MSG_PUB.add;
	        END IF;
		RAISE FND_API.G_EXC_ERROR ;

    END IF ;

    IF ( p_supp_trade_profile_rec.qty_increase_tolerance <>FND_API.g_miss_num
         AND
	 p_supp_trade_profile_rec.qty_increase_tolerance IS NOT NULL
	 AND
	 p_supp_trade_profile_rec.qty_increase_tolerance NOT BETWEEN 0 AND 99
	) THEN

		IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid value for increase tolerance' );
                END IF;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN

		   FND_MESSAGE.set_name('OZF', 'OZF_QTY_INC_TOLERANCE_INVALID');
		   FND_MSG_PUB.add;
                END IF;
		RAISE FND_API.G_EXC_ERROR ;

    END IF ;



   -- The claim frequency unit and value should be provided together

     IF ((NVL(p_supp_trade_profile_rec.claim_frequency,FND_API.g_miss_num) = FND_API.g_miss_num AND
          NVL(p_supp_trade_profile_rec.claim_frequency_unit,FND_API.g_miss_char)<> FND_API.g_miss_char)
                            OR
          (NVL(p_supp_trade_profile_rec.claim_frequency,FND_API.g_miss_num) <> FND_API.g_miss_num AND
          NVL(p_supp_trade_profile_rec.claim_frequency_unit,FND_API.g_miss_char) = FND_API.g_miss_char)) THEN

                IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' The claim frequency and unit should be provided together' );
                END IF;
       		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	           FND_MESSAGE.set_name('OZF', 'The claim frequency and unit should be provided together');
		   FND_MSG_PUB.add;
                END IF;
		RAISE FND_API.G_EXC_ERROR ;
      END IF ;



     -- Validate the values for claim frequency and unit
      IF ( p_supp_trade_profile_rec.claim_frequency      <>FND_API.g_miss_num
           AND
	   p_supp_trade_profile_rec.claim_frequency IS NOT NULL
	   AND
           p_supp_trade_profile_rec.claim_frequency_unit <>FND_API.g_miss_char ) THEN


	   IF (p_supp_trade_profile_rec.claim_frequency < 0) THEN

		IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid value for claim frequency' );
                END IF;

		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	           FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_FREQ_NEG');
		   FND_MSG_PUB.add;
                END IF;
		RAISE FND_API.G_EXC_ERROR ;
	   END IF ;

	   SELECT COUNT(*) INTO l_freq_unit_count
	   FROM   ozf_lookups
	   WHERE  lookup_type='OZF_AUTOPAY_PERIOD_TYPE'
	   AND lookup_code = p_supp_trade_profile_rec.claim_frequency_unit ;

	   IF ( l_freq_unit_count=0 ) THEN

		IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid value for claim frequency Unit' );
                END IF;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	           FND_MESSAGE.set_name('OZF', 'OZF_INVALID_CLM_FREQ_UNIT');  -- Invalid Claim Frequency Unit
		   FND_MSG_PUB.add;
                END IF;
		RAISE FND_API.G_EXC_ERROR ;

           END IF ;
       END IF ;


       IF ( p_supp_trade_profile_rec.claim_computation_basis <>FND_API.g_miss_num
	   AND p_supp_trade_profile_rec.claim_computation_basis IS NOT NULL ) THEN

           SELECT COUNT(*) INTO l_comp_baisis_count
           FROM qp_price_formulas_vl formula
           WHERE trunc(sysdate) BETWEEN nvl(start_date_active, trunc(sysdate))
	   	                    AND nvl(end_date_active, trunc(sysdate))
           AND formula.price_formula_id = p_supp_trade_profile_rec.claim_computation_basis ;

	   IF (l_comp_baisis_count = 0 ) THEN
	      IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid value for claim computation baisis' );
              END IF;
	     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		FND_MESSAGE.set_name('OZF', 'OZF_INVALID_CLM_COMP_BASIS'); -- Invalid Claim Computation Baisis
		FND_MSG_PUB.add;
             END IF;
	     RAISE FND_API.G_EXC_ERROR ;
          END IF;

       END IF ;

       -- Validate the key flex field values

       IF (p_supp_trade_profile_rec.gl_contra_liability_acct <> FND_API.g_miss_num AND
           p_supp_trade_profile_rec.gl_contra_liability_acct IS NOT NULL ) THEN


		Validate_GL_KeyFlex_val( p_combination_id => p_supp_trade_profile_rec.gl_contra_liability_acct,
					 x_return_status  => x_return_status,
					 x_msg_count      => x_msg_count,
					 x_msg_data	  => x_msg_data ) ;

		IF (x_return_status <> FND_API.g_ret_sts_success) THEN
		       IF g_debug THEN
	                    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid GL Contra Laibility' );
                       END IF;
			RAISE FND_API.G_EXC_ERROR ;
		END IF ;

	END IF ;


	IF (p_supp_trade_profile_rec.gl_cost_adjustment_acct <> FND_API.g_miss_num AND
           p_supp_trade_profile_rec.gl_cost_adjustment_acct IS NOT NULL ) THEN


		Validate_GL_KeyFlex_val( p_combination_id => p_supp_trade_profile_rec.gl_cost_adjustment_acct,
					 x_return_status  => x_return_status,
					 x_msg_count      => x_msg_count,
					 x_msg_data	  => x_msg_data ) ;

		IF (x_return_status <> FND_API.g_ret_sts_success) THEN
		        IF g_debug THEN
	                    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid GL Cost Adjustment' );
                        END IF;
			RAISE FND_API.G_EXC_ERROR ;
		END IF ;

	END IF ;

	IF g_debug THEN
	             ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Ends' );
         END IF;


   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
      IF g_debug THEN
	ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm );
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
     IF g_debug THEN
	ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm );
     END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
     IF g_debug THEN
	ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm );
     END IF;


END Validate_Supp_Trade_Profile ;





---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Code_Cov_rec
--
-- PURPOSE
--    This procedure validates code conversion record
--Parameters
--      p_code_conv_rec   - Code conversion record
--      x_return_status   - Result
---------------------------------------------------------------------



PROCEDURE Validate_Code_Cov_rec(
    p_init_msg_list              IN		VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY	VARCHAR2,
    x_msg_count                  OUT NOCOPY	NUMBER,
    x_msg_data                   OUT NOCOPY	VARCHAR2,
    p_code_conv_rec              IN OUT NOCOPY		OZF_CODE_CONVERSION_PVT.supp_code_conversion_rec_type,
    p_mode                       IN             VARCHAR2
   )

   IS

   CURSOR csr_code_conv(cv_supp_trade_profile_id NUMBER
                             , cv_external_code VARCHAR2
                             , cv_internal_code VARCHAR2
                             , cv_start_date_active DATE
                             , cv_end_date_active DATE
                             , cv_conv_id NUMBER := -1)
   IS
        select code_conversion_id from ozf_supp_code_conversions_all where external_code = cv_external_code
		and code_conversion_id <> cv_conv_id
		and supp_trade_profile_id = cv_supp_trade_profile_id
		and ( to_date(cv_start_date_active,'dd-mm-yyyy')  between
		to_date(start_date_active,'dd-mm-yyyy') and nvl(end_date_active,to_Date('31-12-9999','dd-mm-yyyy'))
		or nvl(to_date(cv_end_date_active,'dd-mm-yyyy'),to_Date('31-12-9999','dd-mm-yyyy')) between
		to_date(start_date_Active,'dd-mm-yyyy') and nvl(to_date(end_date_active,'dd-mm-yyyy'),to_Date('31-12-9999','dd-mm-yyyy')))
                union
		select code_conversion_id from ozf_supp_code_conversions_all where internal_code = cv_internal_code
		and code_conversion_id <> cv_conv_id
		and supp_trade_profile_id = cv_supp_trade_profile_id
		and  ( to_date(cv_start_date_active,'dd-mm-yyyy')  between to_date(start_date_active,'dd-mm-yyyy')
		and nvl(end_date_active,to_Date('31-12-9999','dd-mm-yyyy'))
		or nvl(to_date(cv_end_date_active,'dd-mm-yyyy'),to_Date('31-12-9999','dd-mm-yyyy')) between
		to_date(start_date_Active,'dd-mm-yyyy') and nvl(to_date(end_date_active,'dd-mm-yyyy'),to_Date('31-12-9999','dd-mm-yyyy')));



   CURSOR csr_get_item(cv_item_number varchar2) IS
	SELECT inventory_item_id
		FROM mtl_system_items_vl
		WHERE (organization_id = FND_PROFILE.value('AMS_ITEM_ORGANIZATION_ID'))
		AND ENABLED_FLAG = 'Y'
		AND fnd_date.canonical_to_date(sysdate) BETWEEN fnd_date.canonical_to_date(NVL(START_DATE_ACTIVE,sysdate))
						AND fnd_date.canonical_to_date(NVL(END_DATE_ACTIVE,sysdate))
		AND concatenated_segments = cv_item_number ;

		-- ;



	L_API_NAME                  CONSTANT         VARCHAR2(30)	               := 'Validate_Code_Cov_rec';
	l_int_code_count			     NUMBER                            := 0 ;
        l_dummy					     NUMBER				:= 0;



BEGIN

      IF g_debug THEN
	   ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Starts' );
      END IF;

      x_return_status := FND_API.g_ret_sts_success ;

      -- Validate code conversion type
       IF ( p_code_conv_rec.CODE_CONVERSION_TYPE IS NULL
           OR p_code_conv_rec.CODE_CONVERSION_TYPE = FND_API.g_miss_char
           OR p_code_conv_rec.CODE_CONVERSION_TYPE<>'OZF_PRODUCT_CODES' ) THEN

		IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid claim conversion type' );
		END IF;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CONTYPE_MISSING');
			FND_MSG_PUB.add;
			x_return_status := FND_API.G_RET_STS_ERROR ;
			RETURN ;
		END IF;
	END IF ;



      IF (p_mode = 'C') THEN
      -- Validate internal code

	      OPEN csr_get_item(p_code_conv_rec.INTERNAL_CODE) ;

	      FETCH csr_get_item INTO p_code_conv_rec.INTERNAL_CODE ;

	      IF (csr_get_item%NOTFOUND) THEN

			IF g_debug THEN
				ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid internal code' );
			END IF;
			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
				FND_MESSAGE.set_name('CSS', 'CSS_DEF_INVALID_PRODUCT');
				FND_MSG_PUB.add;
				x_return_status := FND_API.G_RET_STS_ERROR ;
				RETURN ;
			END IF;

		END IF ;

		CLOSE csr_get_item ;
       END IF ;


	-- Validate external code
	IF p_code_conv_rec.external_code =  FND_API.g_miss_char OR
		p_code_conv_rec.external_code IS NULL  THEN

		 IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid External code' );
		 END IF;
		 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			         FND_MESSAGE.set_name('OZF', 'OZF_EXTERNAL_CODE_MISSING'||NVL(p_code_conv_rec.external_code,'NULL'));
			         FND_MSG_PUB.add;
		  END IF;
		   x_return_status := FND_API.G_RET_STS_ERROR ;
		   RETURN ;
	 END IF;


	-- Validate uniquness of code conversion record
	IF (p_mode = 'C') THEN
		OPEN csr_code_conv(p_code_conv_rec.supp_trade_profile_id,
				     p_code_conv_rec.external_code,
				     p_code_conv_rec.internal_code,
				     p_code_conv_rec.start_date_active,
				     p_code_conv_rec.end_date_active);

		FETCH csr_code_conv
			INTO  l_dummy;
		 CLOSE csr_code_conv;

		IF (l_dummy > 0) THEN

			IF g_debug THEN
			  ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Duplicate code conversion' );
			END IF;
			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
				FND_MESSAGE.set_name('OZF', 'OZF_CODE_CONVERSION_DUPLICATE');
				FND_MSG_PUB.add;
			END IF;
			x_return_status := FND_API.G_RET_STS_ERROR ;
			RETURN ;

		END IF;
	END IF ;


	-- Validate start date for code conversion
	IF NVL(p_code_conv_rec.start_date_active,TRUNC(SYSDATE)) < TRUNC(SYSDATE)
        THEN

	 IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid start date' );
	 END IF;

	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CODE_CONV_STDATE_BKDATED');
            FND_MSG_PUB.add;
         END IF;
			x_return_status := FND_API.G_RET_STS_ERROR ;
			RETURN ;
      END IF;

      IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' End' );
      END IF;

 EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug THEN
		ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm );
      END IF;


END Validate_Code_Cov_rec ;



---------------------------------------------------------------------
-- PROCEDURE
--    Populate_code_conv_rec
--
-- PURPOSE
--    This procedure populates the code conversion record with values in DB
--Parameters
--      p_code_con_rec   - Input Code conversion record
--      x_code_con_rec   - Output Code conversion record
---------------------------------------------------------------------



PROCEDURE Populate_code_conv_rec(
    p_init_msg_list              IN		VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY	VARCHAR2,
    x_msg_count                  OUT NOCOPY	NUMBER,
    x_msg_data                   OUT NOCOPY	VARCHAR2,
    p_code_con_rec		 IN OUT NOCOPY             OZF_CODE_CONVERSION_PVT.supp_code_conversion_rec_type)

   IS
	L_API_NAME                  CONSTANT         VARCHAR2(30)	               := 'Populate_code_conv_rec';


	CURSOR c_pop_rec IS
		SELECT 	code_conversion_id,
			object_version_number,
			SYSDATE,
			DECODE(p_code_con_rec.last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.USER_ID,p_code_con_rec.last_updated_by),
			DECODE(p_code_con_rec.last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.CONC_LOGIN_ID,p_code_con_rec.last_update_login),
			ORG_ID,
			supp_trade_profile_id,
			DECODE( p_code_con_rec.code_conversion_type, FND_API.g_miss_char, code_conversion_type, p_code_con_rec.code_conversion_type),
			external_code,
			internal_code,
			DECODE( p_code_con_rec.description, FND_API.g_miss_char, description, p_code_con_rec.description),
			DECODE( p_code_con_rec.start_date_active, FND_API.G_MISS_DATE,start_date_active , p_code_con_rec.start_date_active),
			DECODE( p_code_con_rec.end_date_active, FND_API.G_MISS_DATE,end_date_active , p_code_con_rec.end_date_active),
			DECODE( p_code_con_rec.attribute_category, FND_API.g_miss_char, attribute_category,p_code_con_rec.attribute_category),
			DECODE( p_code_con_rec.attribute1, FND_API.g_miss_char, attribute1, p_code_con_rec.attribute1),
			DECODE( p_code_con_rec.attribute2, FND_API.g_miss_char, attribute2, p_code_con_rec.attribute2),
			DECODE( p_code_con_rec.attribute3, FND_API.g_miss_char, attribute3, p_code_con_rec.attribute3),
			DECODE( p_code_con_rec.attribute4, FND_API.g_miss_char, attribute4, p_code_con_rec.attribute4),
			DECODE( p_code_con_rec.attribute5, FND_API.g_miss_char, attribute5, p_code_con_rec.attribute5),
			DECODE( p_code_con_rec.attribute6, FND_API.g_miss_char, attribute6, p_code_con_rec.attribute6),
			DECODE( p_code_con_rec.attribute7, FND_API.g_miss_char, attribute7, p_code_con_rec.attribute7),
			DECODE( p_code_con_rec.attribute8, FND_API.g_miss_char, attribute8, p_code_con_rec.attribute8),
			DECODE( p_code_con_rec.attribute9, FND_API.g_miss_char, attribute9, p_code_con_rec.attribute9),
			DECODE( p_code_con_rec.attribute10, FND_API.g_miss_char, attribute10, p_code_con_rec.attribute10),
			DECODE( p_code_con_rec.attribute11, FND_API.g_miss_char, attribute11, p_code_con_rec.attribute11),
			DECODE( p_code_con_rec.attribute12, FND_API.g_miss_char, attribute12, p_code_con_rec.attribute12),
			DECODE( p_code_con_rec.attribute13, FND_API.g_miss_char, attribute13, p_code_con_rec.attribute13),
			DECODE( p_code_con_rec.attribute14, FND_API.g_miss_char, attribute14, p_code_con_rec.attribute14),
			DECODE( p_code_con_rec.attribute15, FND_API.g_miss_char, attribute15, p_code_con_rec.attribute15)
		FROM ozf_supp_code_conversions_all
		WHERE supp_trade_profile_id = p_code_con_rec.supp_trade_profile_id
		AND   code_conversion_id = p_code_con_rec.code_conversion_id;



   BEGIN

	 x_return_status := FND_API.g_ret_sts_success ;

	 IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Starts' );
	 END IF;


	 OPEN c_pop_rec ;

	 FETCH c_pop_rec
		INTO	p_code_con_rec.code_conversion_id,
		        p_code_con_rec.OBJECT_VERSION_NUMBER,
			p_code_con_rec.last_update_date,
			p_code_con_rec.last_updated_by,
			p_code_con_rec.last_update_login,
			p_code_con_rec.ORG_ID,
			p_code_con_rec.supp_trade_profile_id,
			p_code_con_rec.code_conversion_type,
			p_code_con_rec.external_code,
			p_code_con_rec.internal_code,
			p_code_con_rec.description,
			p_code_con_rec.start_date_active,
			p_code_con_rec.end_date_active,
			p_code_con_rec.attribute_category,
			p_code_con_rec.attribute1,
			p_code_con_rec.attribute2,
			p_code_con_rec.attribute3,
			p_code_con_rec.attribute4,
			p_code_con_rec.attribute5,
			p_code_con_rec.attribute6,
			p_code_con_rec.attribute7,
			p_code_con_rec.attribute8,
			p_code_con_rec.attribute9,
			p_code_con_rec.attribute10,
			p_code_con_rec.attribute11,
			p_code_con_rec.attribute12,
			p_code_con_rec.attribute13,
			p_code_con_rec.attribute14,
			p_code_con_rec.attribute15  ;
	  IF ( c_pop_rec%NOTFOUND) THEN

		IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' No data found for cursor' );
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  ELSE
		x_return_status := FND_API.g_ret_sts_success ;
	  END IF ;

	CLOSE c_pop_rec;


     EXCEPTION

     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm );
      END IF;



   END Populate_code_conv_rec ;




---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Supp_Trade_Profile
--
-- PURPOSE
--    This procedure Converts the public trade profile record to prive
--Parameters
--      p_supp_trade_profile_rec   - Private trade profile record
--      x_supp_trade_profile_rec   - Public trade profile record
---------------------------------------------------------------------

   PROCEDURE Convert_Supp_Trade_Profile(
    p_init_msg_list              IN		VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY	VARCHAR2,
    x_msg_count                  OUT NOCOPY	NUMBER,
    x_msg_data                   OUT NOCOPY	VARCHAR2,
    p_supp_trade_profile_rec     IN		supp_trade_profile_rec_type,
    x_supp_trade_profile_rec     OUT NOCOPY	OZF_SUPP_TRADE_PROFILE_PVT.supp_trade_profile_rec_type,
    p_action                     IN             VARCHAR2      := 'C'
   )

IS
	  L_API_NAME                  CONSTANT         VARCHAR2(30)	               := 'Convert_Supp_Trade_Profile';
	  l_supp_trade_profile_rec                     OZF_SUPP_TRADE_PROFILE_PVT.supp_trade_profile_rec_type ;
BEGIN

      IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Starts' );
      END IF;


		IF (p_action = 'U') THEN
			-- Default initialization Starts

			l_supp_trade_profile_rec.supp_trade_profile_id                       :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.object_version_number			     :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.last_update_date                            :=   FND_API.G_MISS_DATE ;
			l_supp_trade_profile_rec.last_updated_by                             :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.creation_date                               :=   FND_API.G_MISS_DATE ;
			l_supp_trade_profile_rec.created_by                                  :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.last_update_login                           :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.request_id                                  :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.program_application_id                      :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.program_update_date                         :=   FND_API.G_MISS_DATE ;
			l_supp_trade_profile_rec.program_id                                  :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.created_from                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.supplier_id                                 :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.supplier_site_id                            :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.party_id                                    :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.cust_account_id                             :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.cust_acct_site_id                           :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.site_use_id                                 :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.pre_approval_flag                           := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.approval_communication                      := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.gl_contra_liability_acct                    :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.gl_cost_adjustment_acct                     :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.default_days_covered                        :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.create_claim_price_increase                 := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.skip_approval_flag                          := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.skip_adjustment_flag                        := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.settlement_method_supplier_inc              := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.settlement_method_supplier_dec              := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.settlement_method_customer                  := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.authorization_period                        :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.grace_days                                  :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.allow_qty_increase                          := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.qty_increase_tolerance                      :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.request_communication                       := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.claim_communication                         := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.claim_frequency                             :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.claim_frequency_unit                        := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.claim_computation_basis                     :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.attribute_category                         := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute1                                 := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute2                                 := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute3                                 := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute4                                 := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute5                                 := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute6                                 := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute7                                 := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute8                                 := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute9                                 := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute10                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute11                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute12                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute13                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute14                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute15                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute16                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute17                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute18                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute19                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute20                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute21                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute22                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute23                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute24                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute25                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute26                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute27                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute28                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute29                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.attribute30                                := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute_category                     := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute1                             := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute2                             := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute3                             := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute4                             := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute5                             := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute6                             := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute7                             := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute8                             := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute9                             := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute10                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute11                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute12                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute13                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute14                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute15                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute16                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute17                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute18                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute19                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute20                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute21                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute22                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute23                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute24                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute25                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute26                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute27                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute28                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute29                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.dpp_attribute30                            := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.org_id                                      :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.security_group_id                           :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.claim_currency_code                         := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.min_claim_amt                               :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.min_claim_amt_line_lvl                      :=  FND_API.g_miss_num ;
			l_supp_trade_profile_rec.auto_debit                                  := FND_API.g_miss_char ;
			l_supp_trade_profile_rec.days_before_claiming_debit                  :=  FND_API.g_miss_num ;

			-- Default initialization Ends
	END IF ;


	IF (p_supp_trade_profile_rec.object_version_number<>FND_API.g_miss_num) THEN
		l_supp_trade_profile_rec.object_version_number                       := p_supp_trade_profile_rec.object_version_number                                   ;
	END IF ;

	IF (p_supp_trade_profile_rec.last_update_date <> FND_API.G_MISS_DATE) THEN
		l_supp_trade_profile_rec.last_update_date                            := p_supp_trade_profile_rec.last_update_date                                        ;
	END IF ;

	IF (p_supp_trade_profile_rec.last_updated_by <> FND_API.g_miss_num) THEN
		l_supp_trade_profile_rec.last_updated_by                             := p_supp_trade_profile_rec.last_updated_by                                         ;
	END IF ;

	IF (p_supp_trade_profile_rec.creation_date <> FND_API.G_MISS_DATE) THEN
		l_supp_trade_profile_rec.creation_date                               := p_supp_trade_profile_rec.creation_date                                           ;
	END IF ;

	IF (p_supp_trade_profile_rec.created_by <> FND_API.g_miss_num) THEN
		l_supp_trade_profile_rec.created_by                                  := p_supp_trade_profile_rec.created_by                                              ;
	END IF ;

	IF (p_supp_trade_profile_rec.last_update_login <> FND_API.g_miss_num ) THEN
		l_supp_trade_profile_rec.last_update_login                           := p_supp_trade_profile_rec.last_update_login                                       ;
	END IF ;

	IF (p_supp_trade_profile_rec.request_id <> FND_API.g_miss_num ) THEN
		l_supp_trade_profile_rec.request_id                                  := p_supp_trade_profile_rec.request_id                                              ;
	END IF ;

	IF (p_supp_trade_profile_rec.program_application_id <> FND_API.g_miss_num ) THEN
		l_supp_trade_profile_rec.program_application_id                      := p_supp_trade_profile_rec.program_application_id                                  ;
	END IF ;

	IF (p_supp_trade_profile_rec.program_update_date <> FND_API.G_MISS_DATE) THEN
		l_supp_trade_profile_rec.program_update_date                         := p_supp_trade_profile_rec.program_update_date                                     ;
	END IF ;

	IF(p_supp_trade_profile_rec.program_id <> FND_API.g_miss_num) THEN
		l_supp_trade_profile_rec.program_id                                  := p_supp_trade_profile_rec.program_id                                              ;
	END IF ;

	IF (p_supp_trade_profile_rec.created_from <>  FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.created_from                                := p_supp_trade_profile_rec.created_from                                            ;
	END IF ;



	l_supp_trade_profile_rec.supplier_id                                 := p_supp_trade_profile_rec.supplier_id                                             ;
	l_supp_trade_profile_rec.supplier_site_id                            := p_supp_trade_profile_rec.supplier_site_id                                        ;
	l_supp_trade_profile_rec.party_id                                    := p_supp_trade_profile_rec.party_id                                                ;
	l_supp_trade_profile_rec.cust_account_id                             := p_supp_trade_profile_rec.cust_account_id                                         ;
	l_supp_trade_profile_rec.cust_acct_site_id                           := p_supp_trade_profile_rec.cust_acct_site_id                                       ;
	l_supp_trade_profile_rec.site_use_id                                 := p_supp_trade_profile_rec.site_use_id   						 ;


	IF(p_supp_trade_profile_rec.pre_approval_flag <> FND_API.g_miss_char ) THEN
		l_supp_trade_profile_rec.pre_approval_flag                           := p_supp_trade_profile_rec.pre_approval_flag                                       ;
	END IF ;

	IF(p_supp_trade_profile_rec.approval_communication = FND_API.g_miss_char OR p_supp_trade_profile_rec.approval_communication IS NULL ) THEN

		l_supp_trade_profile_rec.approval_communication                      := FND_API.g_miss_char                                 ;
	ELSE
		l_supp_trade_profile_rec.approval_communication                      := p_supp_trade_profile_rec.approval_communication                                  ;
	END IF ;


	IF (p_supp_trade_profile_rec.gl_contra_liability_acct <> FND_API.g_miss_num ) THEN
		l_supp_trade_profile_rec.gl_contra_liability_acct                    := p_supp_trade_profile_rec.gl_contra_liability_acct                                ;
	END IF ;

	IF (p_supp_trade_profile_rec.gl_cost_adjustment_acct <> FND_API.g_miss_num) THEN
		l_supp_trade_profile_rec.gl_cost_adjustment_acct                     := p_supp_trade_profile_rec.gl_cost_adjustment_acct                                 ;
	END IF ;

	IF (p_supp_trade_profile_rec.default_days_covered <> FND_API.g_miss_num) THEN
		l_supp_trade_profile_rec.default_days_covered                        := p_supp_trade_profile_rec.default_days_covered                                    ;
	END IF ;

	IF(p_supp_trade_profile_rec.create_claim_price_increase<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.create_claim_price_increase                 := p_supp_trade_profile_rec.create_claim_price_increase                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.skip_approval_flag <> FND_API.g_miss_char ) THEN
		l_supp_trade_profile_rec.skip_approval_flag                          := p_supp_trade_profile_rec.skip_approval_flag                                      ;
	END IF ;

	IF(p_supp_trade_profile_rec.skip_adjustment_flag <> FND_API.g_miss_char ) THEN
		l_supp_trade_profile_rec.skip_adjustment_flag                        := p_supp_trade_profile_rec.skip_adjustment_flag                                    ;
	END IF ;

	IF(p_supp_trade_profile_rec.settlement_method_supplier_inc <> FND_API.g_miss_char ) THEN
		l_supp_trade_profile_rec.settlement_method_supplier_inc              := p_supp_trade_profile_rec.settlement_method_supplier_inc                        ;
	END IF ;

	IF(p_supp_trade_profile_rec.settlement_method_supplier_dec <> FND_API.g_miss_char ) THEN
		l_supp_trade_profile_rec.settlement_method_supplier_dec              := p_supp_trade_profile_rec.settlement_method_supplier_dec                         ;
	END IF ;

	IF(p_supp_trade_profile_rec.settlement_method_customer <> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.settlement_method_customer                  := p_supp_trade_profile_rec.settlement_method_customer                              ;
	END IF ;

	IF(p_supp_trade_profile_rec.authorization_period <> FND_API.g_miss_num) THEN
		l_supp_trade_profile_rec.authorization_period                        := p_supp_trade_profile_rec.authorization_period                                    ;
	END IF ;

	IF(p_supp_trade_profile_rec.grace_days <> FND_API.g_miss_num ) THEN
		l_supp_trade_profile_rec.grace_days                                  := p_supp_trade_profile_rec.grace_days                                              ;
	END IF ;

	IF(p_supp_trade_profile_rec.allow_qty_increase <> FND_API.g_miss_char ) THEN
		l_supp_trade_profile_rec.allow_qty_increase                          := p_supp_trade_profile_rec.allow_qty_increase                                      ;
	END IF ;

	IF(p_supp_trade_profile_rec.qty_increase_tolerance <> FND_API.g_miss_num ) THEN
		l_supp_trade_profile_rec.qty_increase_tolerance                      := p_supp_trade_profile_rec.qty_increase_tolerance                                  ;
	END IF ;

	IF(p_supp_trade_profile_rec.request_communication <> FND_API.g_miss_char ) THEN
		l_supp_trade_profile_rec.request_communication                       := p_supp_trade_profile_rec.request_communication                                   ;
	END IF ;

	IF(p_supp_trade_profile_rec.claim_communication<> FND_API.g_miss_char ) THEN
		l_supp_trade_profile_rec.claim_communication                         := p_supp_trade_profile_rec.claim_communication                                     ;
	END IF ;

	IF(p_supp_trade_profile_rec.claim_frequency <> FND_API.g_miss_num ) THEN
		l_supp_trade_profile_rec.claim_frequency                             := p_supp_trade_profile_rec.claim_frequency                                         ;
	END IF ;

	IF(p_supp_trade_profile_rec.claim_frequency_unit <> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.claim_frequency_unit                        := p_supp_trade_profile_rec.claim_frequency_unit                                    ;
	END IF ;

	IF( p_supp_trade_profile_rec.claim_computation_basis <> FND_API.g_miss_num ) THEN
		l_supp_trade_profile_rec.claim_computation_basis                     := p_supp_trade_profile_rec.claim_computation_basis                                 ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute_category <> FND_API.g_miss_char ) THEN
		l_supp_trade_profile_rec.attribute_category                          := p_supp_trade_profile_rec.attribute_category                                      ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute1<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute1                                  := p_supp_trade_profile_rec.attribute1                                              ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute2<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute2                                  := p_supp_trade_profile_rec.attribute2                                              ;
	END IF ;

		IF(p_supp_trade_profile_rec.attribute3<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute3                                  := p_supp_trade_profile_rec.attribute3                                              ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute4<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute4                                  := p_supp_trade_profile_rec.attribute4                                              ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute5<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute5                                  := p_supp_trade_profile_rec.attribute5                                              ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute6<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute6                                  := p_supp_trade_profile_rec.attribute6                                              ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute7<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute7                                  := p_supp_trade_profile_rec.attribute7                                              ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute8<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute8                                  := p_supp_trade_profile_rec.attribute8                                              ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute9<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute9                                  := p_supp_trade_profile_rec.attribute9                                              ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute10<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute10                                 := p_supp_trade_profile_rec.attribute10                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute11<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute11                                 := p_supp_trade_profile_rec.attribute11                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute12<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute12                                 := p_supp_trade_profile_rec.attribute12                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute13<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute13                                 := p_supp_trade_profile_rec.attribute13                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute14<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute14                                 := p_supp_trade_profile_rec.attribute14                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute15<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute15                                 := p_supp_trade_profile_rec.attribute15                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute16<> FND_API.g_miss_char) THEN
			l_supp_trade_profile_rec.attribute16                                 := p_supp_trade_profile_rec.attribute16                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute17<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute17                                 := p_supp_trade_profile_rec.attribute17                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute18<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute18                                 := p_supp_trade_profile_rec.attribute18                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute19<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute19                                 := p_supp_trade_profile_rec.attribute19                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute20<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute20                                 := p_supp_trade_profile_rec.attribute20                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute21<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute21                                 := p_supp_trade_profile_rec.attribute21                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute22<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute22                                 := p_supp_trade_profile_rec.attribute22                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute23<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute23                                 := p_supp_trade_profile_rec.attribute23                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute24<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute24                                 := p_supp_trade_profile_rec.attribute24                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute25<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute25                                 := p_supp_trade_profile_rec.attribute25                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute26<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute26                                 := p_supp_trade_profile_rec.attribute26                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute27<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute27                                 := p_supp_trade_profile_rec.attribute27                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute28<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute28                                 := p_supp_trade_profile_rec.attribute28                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute29<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute29                                 := p_supp_trade_profile_rec.attribute29                                             ;
	END IF ;

	IF(p_supp_trade_profile_rec.attribute30<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.attribute30                                 := p_supp_trade_profile_rec.attribute30                                             ;
	END IF ;


	l_supp_trade_profile_rec.org_id                                      := p_supp_trade_profile_rec.org_id                                                  ;


	IF(p_supp_trade_profile_rec.security_group_id<> FND_API.g_miss_num) THEN
		l_supp_trade_profile_rec.security_group_id                           := p_supp_trade_profile_rec.security_group_id                                       ;
	END IF ;

	IF(p_supp_trade_profile_rec.claim_currency_code<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.claim_currency_code                         := p_supp_trade_profile_rec.claim_currency_code                                     ;
	END IF ;

	IF(p_supp_trade_profile_rec.min_claim_amt<> FND_API.g_miss_num) THEN
		l_supp_trade_profile_rec.min_claim_amt                               := p_supp_trade_profile_rec.min_claim_amt                                           ;
	END IF ;

	IF(p_supp_trade_profile_rec.min_claim_amt_line_lvl<> FND_API.g_miss_num) THEN
		l_supp_trade_profile_rec.min_claim_amt_line_lvl                      := p_supp_trade_profile_rec.min_claim_amt_line_lvl                                  ;
	END IF ;

	IF(p_supp_trade_profile_rec.auto_debit<> FND_API.g_miss_char) THEN
		l_supp_trade_profile_rec.auto_debit                                  := p_supp_trade_profile_rec.auto_debit                                              ;
	END IF ;

	IF(p_supp_trade_profile_rec.days_before_claiming_debit<> FND_API.g_miss_num) THEN
		l_supp_trade_profile_rec.days_before_claiming_debit 		     := p_supp_trade_profile_rec.days_before_claiming_debit 		                 ;
	END IF ;



	x_supp_trade_profile_rec := l_supp_trade_profile_rec ;

	IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Ends' );
        END IF;


 EXCEPTION
WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
     IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm );
     END IF;



 END Convert_Supp_Trade_Profile ;


---------------------------------------------------------------------
-- PROCEDURE
--    Populate_Supp_Trade_Profile
--
-- PURPOSE
--    This procedure Populates the trade profile record with values in DB
--Parameters
--      p_supp_trade_profile_rec   - User Trade profile record
--      x_supp_trade_profile_rec   - DB Trade profile record
---------------------------------------------------------------------

PROCEDURE Populate_Supp_Trade_Profile(
    p_init_msg_list              IN		VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY	VARCHAR2,
    x_msg_count                  OUT NOCOPY	NUMBER,
    x_msg_data                   OUT NOCOPY	VARCHAR2,
    p_supp_trade_profile_rec     IN OUT NOCOPY		supp_trade_profile_rec_type
   )

   IS


   L_API_NAME                  CONSTANT         VARCHAR2(30)	               := 'Populate_Supp_Trade_Profile';
   CURSOR c_trd_prfl IS
      SELECT	DECODE(p_supp_trade_profile_rec.object_version_number,FND_API.g_miss_num,object_version_number,p_supp_trade_profile_rec.object_version_number) object_version_number,
		DECODE(p_supp_trade_profile_rec.party_id,FND_API.g_miss_num,party_id,p_supp_trade_profile_rec.party_id) party_id,
		DECODE(p_supp_trade_profile_rec.site_use_id,FND_API.g_miss_num,site_use_id,p_supp_trade_profile_rec.site_use_id) site_use_id,
		DECODE(p_supp_trade_profile_rec.cust_account_id,FND_API.g_miss_num,cust_account_id,p_supp_trade_profile_rec.cust_account_id) cust_account_id,
		DECODE(p_supp_trade_profile_rec.cust_acct_site_id,FND_API.g_miss_num,cust_acct_site_id,p_supp_trade_profile_rec.cust_acct_site_id) cust_acct_site_id,
                creation_date ,
		supplier_id,
		supplier_site_id,
		DECODE(p_supp_trade_profile_rec.attribute_category,FND_API.g_miss_char,attribute_category,p_supp_trade_profile_rec.attribute_category) attribute_category,
		DECODE(p_supp_trade_profile_rec.attribute1,FND_API.g_miss_char,attribute1,p_supp_trade_profile_rec.attribute1) attribute1,
		DECODE(p_supp_trade_profile_rec.attribute2,FND_API.g_miss_char,attribute2,p_supp_trade_profile_rec.attribute2) attribute2,
		DECODE(p_supp_trade_profile_rec.attribute3,FND_API.g_miss_char,attribute3,p_supp_trade_profile_rec.attribute3) attribute3,
		DECODE(p_supp_trade_profile_rec.attribute4,FND_API.g_miss_char,attribute4,p_supp_trade_profile_rec.attribute4) attribute4,
		DECODE(p_supp_trade_profile_rec.attribute5,FND_API.g_miss_char,attribute5,p_supp_trade_profile_rec.attribute5) attribute5,
		DECODE(p_supp_trade_profile_rec.attribute6,FND_API.g_miss_char,attribute6,p_supp_trade_profile_rec.attribute6) attribute6,
		DECODE(p_supp_trade_profile_rec.attribute7,FND_API.g_miss_char,attribute7,p_supp_trade_profile_rec.attribute7) attribute7,
		DECODE(p_supp_trade_profile_rec.attribute8,FND_API.g_miss_char,attribute8,p_supp_trade_profile_rec.attribute8) attribute8,
		DECODE(p_supp_trade_profile_rec.attribute9,FND_API.g_miss_char,attribute9,p_supp_trade_profile_rec.attribute9) attribute9,
		DECODE(p_supp_trade_profile_rec.attribute10,FND_API.g_miss_char,attribute10,p_supp_trade_profile_rec.attribute10) attribute10,
		DECODE(p_supp_trade_profile_rec.attribute11,FND_API.g_miss_char,attribute11,p_supp_trade_profile_rec.attribute11) attribute11,
		DECODE(p_supp_trade_profile_rec.attribute12,FND_API.g_miss_char,attribute12,p_supp_trade_profile_rec.attribute12) attribute12,
		DECODE(p_supp_trade_profile_rec.attribute13,FND_API.g_miss_char,attribute13,p_supp_trade_profile_rec.attribute13) attribute13,
		DECODE(p_supp_trade_profile_rec.attribute14,FND_API.g_miss_char,attribute14,p_supp_trade_profile_rec.attribute14) attribute14,
		DECODE(p_supp_trade_profile_rec.attribute15,FND_API.g_miss_char,attribute15,p_supp_trade_profile_rec.attribute15) attribute15,
		DECODE(p_supp_trade_profile_rec.attribute16,FND_API.g_miss_char,attribute16,p_supp_trade_profile_rec.attribute16) attribute16,
		DECODE(p_supp_trade_profile_rec.attribute17,FND_API.g_miss_char,attribute17,p_supp_trade_profile_rec.attribute17) attribute17,
		DECODE(p_supp_trade_profile_rec.attribute18,FND_API.g_miss_char,attribute18,p_supp_trade_profile_rec.attribute18) attribute18,
		DECODE(p_supp_trade_profile_rec.attribute19,FND_API.g_miss_char,attribute19,p_supp_trade_profile_rec.attribute19) attribute19,
		DECODE(p_supp_trade_profile_rec.attribute20,FND_API.g_miss_char,attribute20,p_supp_trade_profile_rec.attribute20) attribute20,
		DECODE(p_supp_trade_profile_rec.attribute21,FND_API.g_miss_char,attribute21,p_supp_trade_profile_rec.attribute21) attribute21,
		DECODE(p_supp_trade_profile_rec.attribute22,FND_API.g_miss_char,attribute22,p_supp_trade_profile_rec.attribute22) attribute22,
		DECODE(p_supp_trade_profile_rec.attribute23,FND_API.g_miss_char,attribute23,p_supp_trade_profile_rec.attribute23) attribute23,
		DECODE(p_supp_trade_profile_rec.attribute24,FND_API.g_miss_char,attribute24,p_supp_trade_profile_rec.attribute24) attribute24,
		DECODE(p_supp_trade_profile_rec.attribute25,FND_API.g_miss_char,attribute25,p_supp_trade_profile_rec.attribute25) attribute25,
		DECODE(p_supp_trade_profile_rec.attribute26,FND_API.g_miss_char,attribute26,p_supp_trade_profile_rec.attribute26) attribute26,
		DECODE(p_supp_trade_profile_rec.attribute27,FND_API.g_miss_char,attribute27,p_supp_trade_profile_rec.attribute27) attribute27,
		DECODE(p_supp_trade_profile_rec.attribute28,FND_API.g_miss_char,attribute28,p_supp_trade_profile_rec.attribute28) attribute28,
		DECODE(p_supp_trade_profile_rec.attribute29,FND_API.g_miss_char,attribute29,p_supp_trade_profile_rec.attribute29) attribute29,
		DECODE(p_supp_trade_profile_rec.attribute30,FND_API.g_miss_char,attribute30,p_supp_trade_profile_rec.attribute30) attribute30,
		org_id ,
		DECODE(p_supp_trade_profile_rec.pre_approval_flag ,FND_API.g_miss_char,pre_approval_flag,p_supp_trade_profile_rec.pre_approval_flag) pre_approval_flag,
		DECODE(p_supp_trade_profile_rec.approval_communication ,FND_API.g_miss_char,approval_communication,p_supp_trade_profile_rec.approval_communication) approval_communication,
		DECODE(p_supp_trade_profile_rec.gl_contra_liability_acct ,FND_API.g_miss_num, gl_contra_liability_acct,p_supp_trade_profile_rec.gl_contra_liability_acct) gl_contra_liability_acct,
		DECODE(p_supp_trade_profile_rec.gl_cost_adjustment_acct ,FND_API.g_miss_num,gl_cost_adjustment_acct,p_supp_trade_profile_rec.gl_cost_adjustment_acct) gl_cost_adjustment_acct,
		DECODE(p_supp_trade_profile_rec.default_days_covered ,FND_API.g_miss_num,default_days_covered,p_supp_trade_profile_rec.default_days_covered) default_days_covered,
		DECODE(p_supp_trade_profile_rec.create_claim_price_increase ,FND_API.g_miss_char ,create_claim_price_increase,p_supp_trade_profile_rec.create_claim_price_increase) create_claim_price_increase,
		DECODE(p_supp_trade_profile_rec.skip_approval_flag , FND_API.g_miss_char,skip_approval_flag,p_supp_trade_profile_rec.skip_approval_flag) skip_approval_flag,
		DECODE(p_supp_trade_profile_rec.skip_adjustment_flag ,FND_API.g_miss_char ,skip_adjustment_flag, p_supp_trade_profile_rec.skip_adjustment_flag) skip_adjustment_flag,
		DECODE(p_supp_trade_profile_rec.settlement_method_supplier_inc,FND_API.g_miss_char,settlement_method_supplier_inc,p_supp_trade_profile_rec.settlement_method_supplier_inc) settlement_method_supplier_inc,
		DECODE(p_supp_trade_profile_rec.settlement_method_supplier_dec,FND_API.g_miss_char,settlement_method_supplier_dec,p_supp_trade_profile_rec.settlement_method_supplier_dec) settlement_method_supplier_dec,
		DECODE(p_supp_trade_profile_rec.settlement_method_customer,FND_API.g_miss_char,settlement_method_customer,p_supp_trade_profile_rec.settlement_method_customer) settlement_method_customer,
		DECODE(p_supp_trade_profile_rec.authorization_period ,FND_API.g_miss_num,authorization_period,p_supp_trade_profile_rec.authorization_period) authorization_period ,
		DECODE(p_supp_trade_profile_rec.grace_days ,FND_API.g_miss_num,grace_days,p_supp_trade_profile_rec.grace_days) grace_days,
		DECODE(p_supp_trade_profile_rec.allow_qty_increase ,FND_API.g_miss_char,allow_qty_increase,p_supp_trade_profile_rec.allow_qty_increase) allow_qty_increase,
		DECODE(p_supp_trade_profile_rec.qty_increase_tolerance   ,FND_API.g_miss_num,qty_increase_tolerance,p_supp_trade_profile_rec.qty_increase_tolerance) qty_increase_tolerance,
		DECODE(p_supp_trade_profile_rec.request_communication     ,FND_API.g_miss_char,request_communication,p_supp_trade_profile_rec.request_communication) request_communication,
		DECODE(p_supp_trade_profile_rec.claim_communication       ,FND_API.g_miss_char,claim_communication,p_supp_trade_profile_rec.claim_communication) claim_communication,
		DECODE(p_supp_trade_profile_rec.claim_frequency          ,FND_API.g_miss_num,claim_frequency,p_supp_trade_profile_rec.claim_frequency) claim_frequency,
		DECODE(p_supp_trade_profile_rec.claim_frequency_unit      ,FND_API.g_miss_char,claim_frequency_unit,p_supp_trade_profile_rec.claim_frequency_unit) claim_frequency_unit,
		DECODE(p_supp_trade_profile_rec.claim_computation_basis ,FND_API.g_miss_num, claim_computation_basis, p_supp_trade_profile_rec.claim_computation_basis) claim_computation_basis,
		DECODE(p_supp_trade_profile_rec.claim_currency_code      ,FND_API.g_miss_char, claim_currency_code,p_supp_trade_profile_rec.claim_currency_code) claim_currency_code,
		DECODE(p_supp_trade_profile_rec.min_claim_amt           ,FND_API.g_miss_num ,min_claim_amt,p_supp_trade_profile_rec.min_claim_amt) min_claim_amt,
		DECODE(p_supp_trade_profile_rec.min_claim_amt_line_lvl  ,FND_API.g_miss_num,min_claim_amt_line_lvl,p_supp_trade_profile_rec.min_claim_amt_line_lvl) min_claim_amt_line_lvl,
		DECODE(p_supp_trade_profile_rec.auto_debit              ,FND_API.g_miss_char, auto_debit,p_supp_trade_profile_rec.auto_debit)  auto_debit,
		DECODE(p_supp_trade_profile_rec.days_before_claiming_debit , FND_API.g_miss_num, days_before_claiming_debit,p_supp_trade_profile_rec.days_before_claiming_debit) days_before_claiming_debit,
                security_group_id
	FROM ozf_supp_trd_prfls_all
	WHERE supp_trade_profile_id = p_supp_trade_profile_rec.supp_trade_profile_id ;


        l_ref_supp_trade_profile_rec  c_trd_prfl%ROWTYPE;





   BEGIN

	 IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Starts' );
          END IF;

          OPEN c_trd_prfl ;
           FETCH c_trd_prfl INTO l_ref_supp_trade_profile_rec;
	   IF ( c_trd_prfl%NOTFOUND) THEN
		IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid trade profile Id' );
                END IF;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('OZF', 'OZF_INVALID_TRD_PRF_ID');
			FND_MSG_PUB.add;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	   END IF;
          CLOSE  c_trd_prfl;



         -----------------------------------------------------------------
	 --- Populate the null data
	 -----------------------------------------------------------------

      p_supp_trade_profile_rec.supp_trade_profile_id       :=  p_supp_trade_profile_rec.supp_trade_profile_id      ;
      p_supp_trade_profile_rec.object_version_number       := l_ref_supp_trade_profile_rec.object_version_number      ;
      p_supp_trade_profile_rec.last_update_date            := sysdate           ;
      p_supp_trade_profile_rec.last_updated_by             := p_supp_trade_profile_rec.last_updated_by            ;
      p_supp_trade_profile_rec.supplier_id                 := l_ref_supp_trade_profile_rec.supplier_id                ;
      p_supp_trade_profile_rec.supplier_site_id            := l_ref_supp_trade_profile_rec.supplier_site_id           ;
      p_supp_trade_profile_rec.party_id                    := l_ref_supp_trade_profile_rec.party_id                   ;
      p_supp_trade_profile_rec.cust_account_id             := l_ref_supp_trade_profile_rec.cust_account_id            ;
      p_supp_trade_profile_rec.cust_acct_site_id           := l_ref_supp_trade_profile_rec.cust_acct_site_id          ;
      p_supp_trade_profile_rec.site_use_id                 := l_ref_supp_trade_profile_rec.site_use_id                ;
      p_supp_trade_profile_rec.pre_approval_flag           := l_ref_supp_trade_profile_rec.pre_approval_flag          ;
      p_supp_trade_profile_rec.approval_communication      := l_ref_supp_trade_profile_rec.approval_communication     ;
      p_supp_trade_profile_rec.gl_contra_liability_acct    := l_ref_supp_trade_profile_rec.gl_contra_liability_acct   ;
      p_supp_trade_profile_rec.gl_cost_adjustment_acct     := l_ref_supp_trade_profile_rec.gl_cost_adjustment_acct    ;
      p_supp_trade_profile_rec.default_days_covered        := l_ref_supp_trade_profile_rec.default_days_covered       ;
      p_supp_trade_profile_rec.create_claim_price_increase := l_ref_supp_trade_profile_rec.create_claim_price_increase;
      p_supp_trade_profile_rec.skip_approval_flag          := l_ref_supp_trade_profile_rec.skip_approval_flag         ;
      p_supp_trade_profile_rec.skip_adjustment_flag        := l_ref_supp_trade_profile_rec.skip_adjustment_flag       ;
      p_supp_trade_profile_rec.settlement_method_supplier_dec := l_ref_supp_trade_profile_rec.settlement_method_supplier_dec;
      p_supp_trade_profile_rec.settlement_method_supplier_inc := l_ref_supp_trade_profile_rec.settlement_method_supplier_inc;
      p_supp_trade_profile_rec.settlement_method_customer  := l_ref_supp_trade_profile_rec.settlement_method_customer ;
      p_supp_trade_profile_rec.authorization_period        := l_ref_supp_trade_profile_rec.authorization_period       ;
      p_supp_trade_profile_rec.grace_days                  := l_ref_supp_trade_profile_rec.grace_days                 ;
      p_supp_trade_profile_rec.allow_qty_increase          := l_ref_supp_trade_profile_rec.allow_qty_increase         ;
      p_supp_trade_profile_rec.qty_increase_tolerance      := l_ref_supp_trade_profile_rec.qty_increase_tolerance     ;
      p_supp_trade_profile_rec.request_communication       := l_ref_supp_trade_profile_rec.request_communication      ;
      p_supp_trade_profile_rec.claim_communication         := l_ref_supp_trade_profile_rec.claim_communication        ;
      p_supp_trade_profile_rec.claim_frequency             := l_ref_supp_trade_profile_rec.claim_frequency            ;
      p_supp_trade_profile_rec.claim_frequency_unit        := l_ref_supp_trade_profile_rec.claim_frequency_unit       ;
      p_supp_trade_profile_rec.claim_computation_basis     := l_ref_supp_trade_profile_rec.claim_computation_basis    ;
      p_supp_trade_profile_rec.attribute_category          := l_ref_supp_trade_profile_rec.attribute_category         ;
      p_supp_trade_profile_rec.attribute1                  := l_ref_supp_trade_profile_rec.attribute1                 ;
      p_supp_trade_profile_rec.attribute2                  := l_ref_supp_trade_profile_rec.attribute2                 ;
      p_supp_trade_profile_rec.attribute3                  := l_ref_supp_trade_profile_rec.attribute3                 ;
      p_supp_trade_profile_rec.attribute4                  := l_ref_supp_trade_profile_rec.attribute4                 ;
      p_supp_trade_profile_rec.attribute5                  := l_ref_supp_trade_profile_rec.attribute5                 ;
      p_supp_trade_profile_rec.attribute6                  := l_ref_supp_trade_profile_rec.attribute6                 ;
      p_supp_trade_profile_rec.attribute7                  := l_ref_supp_trade_profile_rec.attribute7                 ;
      p_supp_trade_profile_rec.attribute8                  := l_ref_supp_trade_profile_rec.attribute8                 ;
      p_supp_trade_profile_rec.attribute9                  := l_ref_supp_trade_profile_rec.attribute9                 ;
      p_supp_trade_profile_rec.attribute10                 := l_ref_supp_trade_profile_rec.attribute10                ;
      p_supp_trade_profile_rec.attribute11                 := l_ref_supp_trade_profile_rec.attribute11                ;
      p_supp_trade_profile_rec.attribute12                 := l_ref_supp_trade_profile_rec.attribute12                ;
      p_supp_trade_profile_rec.attribute13                 := l_ref_supp_trade_profile_rec.attribute13                ;
      p_supp_trade_profile_rec.attribute14                 := l_ref_supp_trade_profile_rec.attribute14                ;
      p_supp_trade_profile_rec.attribute15                 := l_ref_supp_trade_profile_rec.attribute15                ;
      p_supp_trade_profile_rec.attribute16                 := l_ref_supp_trade_profile_rec.attribute16                ;
      p_supp_trade_profile_rec.attribute17                 := l_ref_supp_trade_profile_rec.attribute17                ;
      p_supp_trade_profile_rec.attribute18                 := l_ref_supp_trade_profile_rec.attribute18                ;
      p_supp_trade_profile_rec.attribute19                 := l_ref_supp_trade_profile_rec.attribute19                ;
      p_supp_trade_profile_rec.attribute20                 := l_ref_supp_trade_profile_rec.attribute20                ;
      p_supp_trade_profile_rec.attribute21                 := l_ref_supp_trade_profile_rec.attribute21                ;
      p_supp_trade_profile_rec.attribute22                 := l_ref_supp_trade_profile_rec.attribute22                ;
      p_supp_trade_profile_rec.attribute23                 := l_ref_supp_trade_profile_rec.attribute23                ;
      p_supp_trade_profile_rec.attribute24                 := l_ref_supp_trade_profile_rec.attribute24                ;
      p_supp_trade_profile_rec.attribute25                 := l_ref_supp_trade_profile_rec.attribute25                ;
      p_supp_trade_profile_rec.attribute26                 := l_ref_supp_trade_profile_rec.attribute26                ;
      p_supp_trade_profile_rec.attribute27                 := l_ref_supp_trade_profile_rec.attribute27                ;
      p_supp_trade_profile_rec.attribute28                 := l_ref_supp_trade_profile_rec.attribute28                ;
      p_supp_trade_profile_rec.attribute29                 := l_ref_supp_trade_profile_rec.attribute29                ;
      p_supp_trade_profile_rec.attribute30                 := l_ref_supp_trade_profile_rec.attribute30                ;
      p_supp_trade_profile_rec.org_id                      := l_ref_supp_trade_profile_rec.org_id                     ;
      p_supp_trade_profile_rec.security_group_id           := l_ref_supp_trade_profile_rec.security_group_id          ;
      p_supp_trade_profile_rec.claim_currency_code         := l_ref_supp_trade_profile_rec.claim_currency_code        ;
      p_supp_trade_profile_rec.min_claim_amt               := l_ref_supp_trade_profile_rec.min_claim_amt              ;
      p_supp_trade_profile_rec.min_claim_amt_line_lvl      := l_ref_supp_trade_profile_rec.min_claim_amt_line_lvl     ;
      p_supp_trade_profile_rec.auto_debit                  := l_ref_supp_trade_profile_rec.auto_debit                 ;
      p_supp_trade_profile_rec.days_before_claiming_debit  := l_ref_supp_trade_profile_rec.days_before_claiming_debit ;

      IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Ends' );
       END IF;


  EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug THEN
		ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm );
       END IF;

   END Populate_Supp_Trade_Profile ;




---------------------------------------------------------------------
-- PROCEDURE
--    Create_Supp_Trade_Profile
--
-- PURPOSE
--    Public API for creating Supplier Trade Profile
---------------------------------------------------------------------


PROCEDURE Create_Supp_Trade_Profile(
	    p_api_version_number         IN		NUMBER,
	    p_init_msg_list              IN		VARCHAR2     := FND_API.G_FALSE,
	    p_commit                     IN		VARCHAR2     := FND_API.G_FALSE,
	    p_validation_level           IN		NUMBER       := FND_API.G_VALID_LEVEL_FULL,
	    x_return_status              OUT NOCOPY	VARCHAR2,
	    x_msg_count                  OUT NOCOPY	NUMBER,
	    x_msg_data                   OUT NOCOPY	VARCHAR2,
	    p_supp_trade_profile_rec     IN		supp_trade_profile_rec_type ,
	    p_code_conversion_rec_tbl    IN		code_conversion_tbl_type,
	    p_price_protection_set_tbl   IN             process_setup_tbl_type,
	    x_supp_trade_profile_id      OUT NOCOPY	NUMBER,
	    X_created_process_tbl        OUT NOCOPY     OZF_PROCESS_SETUP_PVT.process_setup_tbl_type,
	    X_created_codes_tbl          OUT NOCOPY     OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type
	   )
IS


   CURSOR c_get_cust_dtl IS
      SELECT acct_site.cust_account_id ,
	     acct_site.cust_acct_site_id
	FROM hz_cust_acct_sites_all acct_site ,
	     hz_party_sites party_site ,
	     hz_locations loc ,
	     hz_cust_site_uses_all site ,
	     hz_parties party ,
	     hz_cust_accounts cust_acct
       WHERE site.site_use_code = 'BILL_TO'
       AND   site.cust_acct_site_id = acct_site.cust_acct_site_id
       AND   acct_site.party_site_id= party_site.party_site_id
       AND   party_site.location_id = loc.location_id
       AND   acct_site.status='A'
       AND   acct_site.cust_account_id=cust_acct.cust_account_id
       AND   cust_acct.party_id=party.party_id
       AND   cust_acct.status='A'
       AND   site.status='A'
       AND   cust_acct.party_id = p_supp_trade_profile_rec.cust_account_id
       AND   site.site_use_id =   p_supp_trade_profile_rec.site_use_id ;




   L_API_NAME                  CONSTANT         VARCHAR2(30)	               := 'Create_Supp_Trade_Profile';
   L_API_VERSION_NUMBER        CONSTANT         NUMBER                         := 1.0;
   l_return_status_full                         VARCHAR2(1);
   l_object_version_number                      NUMBER                         := 1  ;
   l_org_id                                     NUMBER ;

   l_supp_prf_count                             NUMBER                         := 0  ;
   l_supp_trade_profile_rec			OZF_SUPP_TRADE_PROFILE_PUB.supp_trade_profile_rec_type ;
   l_supp_site_count                            NUMBER                         := 0  ;

   l_pvt_supp_rec                               OZF_SUPP_TRADE_PROFILE_PVT.supp_trade_profile_rec_type ;
   l_supp_site_comb_count                       NUMBER                          := 0  ;

   l_ref_cust_dtl_rec				c_get_cust_dtl%ROWTYPE                ;

   l_pro_ver_tbl				OZF_PROCESS_SETUP_PVT.process_setup_tbl_type ;

   l_code_conversion_rec			supp_code_conversion_rec_type ;
   l_code_conversion_rec_tbl    		code_conversion_tbl_type := code_conversion_tbl_type() ;

   l_upd_code_con_tbl                           OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type ;
   l_del_code_con_tbl                           OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type ;

   l_exec_error                                 VARCHAR2(1)                 := 'N' ;


BEGIN


   IF g_debug THEN
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||'Starts');
   END IF;



  -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (	   l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       IF g_debug THEN
		ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||'In compatible call');
	END IF;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;



   -------------------------------------------------
   -- Start : Defaulting data
   -------------------------------------------------

   l_supp_trade_profile_rec := p_supp_trade_profile_rec ;

    IF ( l_supp_trade_profile_rec.pre_approval_flag IS NULL
         OR
	 l_supp_trade_profile_rec.pre_approval_flag NOT IN ('Y','N')) THEN

		l_supp_trade_profile_rec.pre_approval_flag := 'N';
    END IF ;


    IF ( l_supp_trade_profile_rec.create_claim_price_increase IS NULL
         OR
	 l_supp_trade_profile_rec.create_claim_price_increase NOT IN ('Y','N')) THEN

		l_supp_trade_profile_rec.create_claim_price_increase := 'N';
    END IF ;

    IF ( l_supp_trade_profile_rec.skip_approval_flag IS NULL
         OR
	 l_supp_trade_profile_rec.skip_approval_flag NOT IN ('Y','N')) THEN

		l_supp_trade_profile_rec.skip_approval_flag := 'N';
    END IF ;


    IF ( l_supp_trade_profile_rec.skip_adjustment_flag IS NULL
         OR
	 l_supp_trade_profile_rec.skip_adjustment_flag NOT IN ('Y','N')) THEN

		l_supp_trade_profile_rec.skip_adjustment_flag := 'N';
    END IF ;


    IF ( l_supp_trade_profile_rec.allow_qty_increase IS NULL
         OR
	 l_supp_trade_profile_rec.allow_qty_increase NOT IN ('Y','N')) THEN

		l_supp_trade_profile_rec.allow_qty_increase := 'N';
    END IF ;


    IF ( l_supp_trade_profile_rec.auto_debit IS NULL
         OR
	 l_supp_trade_profile_rec.auto_debit NOT IN ('Y','N')) THEN

		l_supp_trade_profile_rec.auto_debit := 'N';
    END IF ;

   IF g_debug THEN
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||'Data initialized');
   END IF;

   -------------------------------------------------
   -- End : Defaulting data
   -------------------------------------------------


   -------------------------------------------------
   -- Start data validation
   -------------------------------------------------


     -- Validate supplier_id+supplier_site_id
    SELECT ap.vendor_id INTO  l_supp_site_count
    FROM ap_suppliers ap,
	 ap_supplier_sites_all aps,
	 po_lookup_codes plc,
         hz_party_sites hps,
         hz_locations hzl,
         fnd_territories_vl fndt
    WHERE aps.party_site_id = hps.party_site_id
    AND hps.location_id = hzl.location_id
    AND nvl(hps.end_date_active, sysdate) >= sysdate
    AND hzl.country = fndt.territory_code
    AND aps.vendor_id = ap.vendor_id
    AND ap.vendor_type_lookup_code = plc.lookup_code (+)
    AND plc.lookup_type (+) = 'VENDOR TYPE'
    AND nvl(aps.rfq_only_site_flag, 'N')  ='N'
    AND NVL(aps.inactive_date, SYSDATE +1) > SYSDATE
    AND aps.vendor_site_id = p_supp_trade_profile_rec.supplier_site_id
    AND aps.org_id = p_supp_trade_profile_rec.org_id ;


    l_supp_trade_profile_rec.supplier_id := l_supp_site_count ;



    IF ( (p_supp_trade_profile_rec.supplier_id IS NULL OR p_supp_trade_profile_rec.supplier_id = FND_API.g_miss_num)
        OR
	l_supp_site_count IS NULL
	) THEN

	    IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||'Invalid Supplier Site Id');
	    END IF;

	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	        FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_SUPP_SITE_ID');
		FND_MSG_PUB.add;
	    END IF;

	    RAISE FND_API.G_EXC_ERROR ;
    END IF ;



    -- Existence checking for Supplier + Supplier site combination
    SELECT COUNT(*) INTO l_supp_site_comb_count
    FROM ozf_supp_trd_prfls_all
    WHERE supplier_id = p_supp_trade_profile_rec.supplier_id
    AND   supplier_site_id = p_supp_trade_profile_rec.supplier_site_id ;

    IF ( l_supp_site_comb_count<>0 ) THEN

      	IF g_debug THEN
	  ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Record for supplier+supplier site already exixts');
	END IF;

	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	        FND_MESSAGE.set_name('OZF', 'OZF_SUPP_TRADE_PROFILE_DUPLIC');
		FND_MSG_PUB.add;
         END IF;

	 RAISE FND_API.G_EXC_ERROR ;

    END IF ;



    -- Validate and populate the customer details

    IF ((p_supp_trade_profile_rec.cust_account_id <> FND_API.g_miss_num AND p_supp_trade_profile_rec.cust_account_id IS NOT NULL )
        AND (p_supp_trade_profile_rec.site_use_id <> FND_API.g_miss_num AND p_supp_trade_profile_rec.site_use_id IS NOT NULL)) THEN


	    OPEN c_get_cust_dtl ;
	    FETCH c_get_cust_dtl INTO l_ref_cust_dtl_rec;
	     IF ( c_get_cust_dtl%NOTFOUND) THEN

		IF g_debug THEN
	            ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid customer');
	        END IF;

		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name('OZF', 'OZF_SELECT_CUSTOMER_NAME');
		   FND_MSG_PUB.add;
		END IF;

		RAISE FND_API.G_EXC_ERROR;
	     ELSE
                  l_supp_trade_profile_rec.party_id := l_ref_cust_dtl_rec.cust_account_id ;
                  l_supp_trade_profile_rec.cust_acct_site_id := l_ref_cust_dtl_rec.cust_acct_site_id ;

	     END IF ;
	   CLOSE  c_get_cust_dtl ;

    ELSE
	   IF g_debug THEN
	           ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid customer');
	   END IF;

	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	          FND_MESSAGE.set_name('OZF', 'OZF_SELECT_CUSTOMER_NAME');
		   FND_MSG_PUB.add;
	   END IF;

	   RAISE FND_API.G_EXC_ERROR;

    END IF ;




    -- Common validations for trade profile record
    Validate_Supp_Trade_Profile( p_init_msg_list => p_init_msg_list,
				x_return_status => x_return_status,
				x_msg_count => x_msg_count,
				x_msg_data => x_msg_data,
				p_supp_trade_profile_rec => l_supp_trade_profile_rec ) ;





    IF x_return_status = FND_API.g_ret_sts_error THEN

	IF g_debug THEN
	      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Validation failed');
	END IF;

        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
    	IF g_debug THEN
	      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Validation failed');
	END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



   -------------------------------------------------
   -- End data validation
   -------------------------------------------------

   -------------------------------------------------
   -- Convert the public record to private
   -------------------------------------------------

   Convert_Supp_Trade_Profile(
    p_init_msg_list              => p_init_msg_list,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_supp_trade_profile_rec     => l_supp_trade_profile_rec,
    x_supp_trade_profile_rec     => l_pvt_supp_rec,
    p_action                     => 'C');





    IF x_return_status = FND_API.g_ret_sts_error THEN

	IF g_debug THEN
	      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Conversion failed');
	END IF;

        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN

        IF g_debug THEN
	      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Conversion failed');
	END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


   -------------------------------------------------
   -- Call the private API
   -------------------------------------------------


   OZF_SUPP_TRADE_PROFILE_PVT.Create_Supp_Trade_Profile(
		p_api_version_number =>     p_api_version_number,
		p_init_msg_list      =>     p_init_msg_list,
		p_commit             =>     FND_API.G_FALSE,
		p_validation_level   =>     FND_API.G_VALID_LEVEL_FULL,
		x_return_status      =>     x_return_status,
		x_msg_count          =>     x_msg_count,
		x_msg_data           =>     x_msg_data,
		p_supp_trade_profile_rec => l_pvt_supp_rec,
		x_supp_trade_profile_id  => x_supp_trade_profile_id) ;



   IF x_return_status = FND_API.g_ret_sts_error THEN

	 IF g_debug THEN
	      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Private API call failed');
	 END IF;

         RAISE FND_API.G_EXC_ERROR;

   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN

	 IF g_debug THEN
	      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Private API call failed');
	 END IF;

	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   ELSE
	IF (p_commit = FND_API.G_TRUE) THEN

	  IF g_debug THEN
	      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Private API Successful');
	  END IF;

	  IF(p_commit = FND_API.G_TRUE) THEN
		COMMIT ;
	  END IF ;
	END IF ;
   END IF;


   -------------------------------------------------
   -- Process code conversion
   -------------------------------------------------
   IF (p_code_conversion_rec_tbl IS NOT NULL ) THEN

	     FOR i in 1 .. p_code_conversion_rec_tbl.COUNT
	     LOOP

		 l_code_conversion_rec := p_code_conversion_rec_tbl(i);
		 l_code_conversion_rec.SUPP_TRADE_PROFILE_ID := x_supp_trade_profile_id;

		 l_code_conversion_rec_tbl.extend;
		 l_code_conversion_rec_tbl(l_code_conversion_rec_tbl.COUNT) := l_code_conversion_rec ;

	     END LOOP ;

	     IF g_debug THEN
		      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Calling process code conversion');
	     END IF;

	     Process_code_conversion(
					P_Api_Version_Number  => p_api_version_number,
					P_Init_Msg_List       => p_init_msg_list,
					P_Commit              => FND_API.G_FALSE,
					p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
					X_Return_Status	      => x_return_status,
					X_Msg_Count           => x_msg_count,
					X_Msg_Data            => x_msg_data,
					p_code_conversion_tbl => l_code_conversion_rec_tbl ,
					X_created_code_con_tbl => X_created_codes_tbl ,
					X_updated_code_con_tbl => l_upd_code_con_tbl ,
					X_deleted_code_con_tbl => l_del_code_con_tbl) ;



	   IF (x_return_status <> FND_API.g_ret_sts_success) THEN
		l_exec_error := 'Y' ;
	   END IF ;
  END IF ;
   -------------------------------------------------
   -- Process price protection
   -------------------------------------------------

    IF(p_price_protection_set_tbl IS NOT NULL ) THEN
		    IF g_debug THEN
			      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Calling process price protection');
		    END IF;

		   Process_price_protection(	P_Api_Version_Number  => p_api_version_number,
						P_Init_Msg_List       => p_init_msg_list,
						P_Commit              => FND_API.G_FALSE,
						p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
						X_Return_Status	      => x_return_status,
						X_Msg_Count           => x_msg_count,
						X_Msg_Data            => x_msg_data,
						p_trade_prf_id        => x_supp_trade_profile_id,
						p_process_setup_tbl   => p_price_protection_set_tbl  ,
						X_created_process_tbl =>  X_created_process_tbl,
						X_updated_process_tbl => l_pro_ver_tbl ) ;

		  IF (x_return_status <> FND_API.g_ret_sts_success) THEN
			l_exec_error := 'Y' ;
		  END IF ;
   END IF ;

 IF(p_commit = FND_API.G_TRUE) THEN
	COMMIT ;
 END IF ;

  IF(l_exec_error = 'Y') THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
  END IF ;

  IF g_debug THEN
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Ends');
  END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

    IF g_debug THEN
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm);
    END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

     IF g_debug THEN
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm);
    END IF;


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

    IF g_debug THEN
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm);
    END IF;

 END Create_Supp_Trade_Profile ;



---------------------------------------------------------------------
-- PROCEDURE
--    Update_Supp_Trade_Profile
--
-- PURPOSE
--    Public API for Upfating Supplier Trade Profile along with code
--    conversion and price protection details
---------------------------------------------------------------------



 PROCEDURE Update_Supp_Trade_Profile(
	    p_api_version_number         IN		NUMBER,
	    p_init_msg_list              IN		VARCHAR2     := FND_API.G_FALSE,
	    p_commit                     IN		VARCHAR2     := FND_API.G_FALSE,
	    p_validation_level           IN		NUMBER       := FND_API.G_VALID_LEVEL_FULL,
	    x_return_status              OUT NOCOPY	VARCHAR2,
	    x_msg_count                  OUT NOCOPY	NUMBER,
	    x_msg_data                   OUT NOCOPY	VARCHAR2,
	    p_supp_trade_profile_rec     IN		supp_trade_profile_rec_type ,
	    p_code_conversion_rec_tbl    IN		code_conversion_tbl_type,
	    p_price_protection_set_tbl   IN             process_setup_tbl_type,
	    X_created_process_tbl        OUT NOCOPY     OZF_PROCESS_SETUP_PVT.process_setup_tbl_type,
            X_updated_process_tbl        OUT NOCOPY     OZF_PROCESS_SETUP_PVT.process_setup_tbl_type,
	    X_created_codes_tbl          OUT NOCOPY     OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type,
            X_updated_codes_tbl          OUT NOCOPY     OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type,
	    X_deleted_codes_tbl          OUT NOCOPY     OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type
	   )

IS
	  L_API_NAME                  CONSTANT         VARCHAR2(30)	               := 'Update_Supp_Trade_Profile_all';

	  L_API_VERSION_NUMBER        CONSTANT         NUMBER                          := 1.0;

	  l_crt_code_con_tbl                           OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type ;
	  l_upd_code_con_tbl                           OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type ;
          l_del_code_con_tbl                           OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type ;
	  l_exec_error                                 VARCHAR2(1) := 'N' ;


BEGIN

      IF g_debug THEN
        ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Starts');
      END IF;


   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (	   l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
   THEN

      IF g_debug THEN
        ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' In compatible Call');
      END IF ;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;


      -------------------------------------------------
      -- Update Supplier trade profile
      -------------------------------------------------

       IF g_debug THEN
         ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Calling Update Supplier Trade Profile');
       END IF;
      Update_Supp_Trade_Profile(
                p_api_version_number         => p_api_version_number ,
                p_init_msg_list              => p_init_msg_list ,
                p_commit                     => p_commit,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data,
                p_supp_trade_profile_rec     => p_supp_trade_profile_rec	   );

	IF (x_return_status <> FND_API.g_ret_sts_success) THEN
		l_exec_error := 'Y' ;
	END IF ;



      -------------------------------------------------
      -- Process code conversion
      ------------------------------------------------
      IF g_debug THEN
        ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Calling Process code conversion');
      END IF;

      Process_code_conversion(
            p_api_version_number          => p_api_version_number ,
            p_init_msg_list               => p_init_msg_list ,
            P_Commit                      => p_commit,
            x_return_status               => x_return_status,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_data,
            p_code_conversion_tbl         => p_code_conversion_rec_tbl,
	    X_created_code_con_tbl	  => X_created_codes_tbl ,
	    X_updated_code_con_tbl        => X_updated_codes_tbl ,
	    X_deleted_code_con_tbl        => X_deleted_codes_tbl) ;

	IF (x_return_status <> FND_API.g_ret_sts_success) THEN
		l_exec_error := 'Y' ;
	END IF ;

      -----------------------------------------------
      -- Process price protection
      -----------------------------------------------
       IF g_debug THEN
         ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Calling Process Price Protection');
       END IF;

      Process_price_protection(
          P_Api_Version_Number         => p_api_version_number ,
          P_Init_Msg_List              => p_init_msg_list ,
          P_Commit                     => p_commit,
          X_Return_Status              => x_return_status,
          X_Msg_Count                  => x_msg_count,
          X_Msg_Data                   => x_msg_data,
          p_trade_prf_id               => p_supp_trade_profile_rec.SUPP_TRADE_PROFILE_ID,
          p_process_setup_tbl          => p_price_protection_set_tbl  ,
          X_created_process_tbl        => X_created_process_tbl,
          X_updated_process_tbl        => X_updated_process_tbl) ;

    	IF (x_return_status <> FND_API.g_ret_sts_success) THEN
		l_exec_error := 'Y' ;
	END IF ;

       IF g_debug THEN
         ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Ends');
       END IF;

       IF (l_exec_error = 'Y') THEN
		x_return_status := FND_API.g_ret_sts_error ;
       END IF ;

 END Update_Supp_Trade_Profile ;



---------------------------------------------------------------------
-- PROCEDURE
--    Update_Supp_Trade_Profile
--
-- PURPOSE
--    Public API for Upating Supplier Trade Profile
---------------------------------------------------------------------


PROCEDURE Update_Supp_Trade_Profile(
	    p_api_version_number         IN		NUMBER,
	    p_init_msg_list              IN		VARCHAR2     := FND_API.G_FALSE,
	    p_commit                     IN		VARCHAR2     := FND_API.G_FALSE,
	    p_validation_level           IN		NUMBER       := FND_API.G_VALID_LEVEL_FULL,
	    x_return_status              OUT NOCOPY	VARCHAR2,
	    x_msg_count                  OUT NOCOPY	NUMBER,
	    x_msg_data                   OUT NOCOPY	VARCHAR2,
	    p_supp_trade_profile_rec     IN		supp_trade_profile_rec_type
	   )
IS
	  L_API_NAME                  CONSTANT         VARCHAR2(30)	               := 'Update_Supp_Trade_Profile';
	  L_API_VERSION_NUMBER        CONSTANT         NUMBER                          := 1.0;
	  l_supp_trade_profile_rec   supp_trade_profile_rec_type ;
          l_pvt_supp_rec             OZF_SUPP_TRADE_PROFILE_PVT.supp_trade_profile_rec_type;
          l_ver_num                  number ;

BEGIN

     IF g_debug THEN
         ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Starts');
     END IF;

    -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (	   l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
   THEN
       IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Incompatible Call');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_supp_trade_profile_rec := p_supp_trade_profile_rec ;

    Populate_Supp_Trade_Profile(p_init_msg_list =>  p_init_msg_list ,
				x_return_status =>  x_return_status ,
				x_msg_count     =>  x_msg_count ,
				x_msg_data      =>  x_msg_data ,
				p_supp_trade_profile_rec => l_supp_trade_profile_rec
				) ;

      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' *****The app channel '||l_supp_trade_profile_rec.approval_communication);


      IF x_return_status = FND_API.g_ret_sts_error THEN
        IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Populate Supplier trade profile failed');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Populate Supplier trade profile failed');
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      Validate_Supp_Trade_Profile(  p_init_msg_list   =>  p_init_msg_list ,
                                    x_return_status   =>  x_return_status ,
                                    x_msg_count       =>  x_msg_count ,
                                    x_msg_data        =>  x_msg_data ,
                                    p_supp_trade_profile_rec     => l_supp_trade_profile_rec) ;


       IF x_return_status = FND_API.g_ret_sts_error THEN
         IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Validate Supplier trade profile failed');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Validate Supplier trade profile failed');
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -------------------------------------------------
      -- Convert the public record to private
      -------------------------------------------------

       Convert_Supp_Trade_Profile(
        p_init_msg_list              => p_init_msg_list,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        p_supp_trade_profile_rec     => l_supp_trade_profile_rec,
        x_supp_trade_profile_rec     => l_pvt_supp_rec ,
	p_action                     => 'U');

      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' *****The app channel '||l_pvt_supp_rec.approval_communication);

      IF x_return_status = FND_API.g_ret_sts_error THEN
         IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Convert Supplier trade profile failed');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Convert Supplier trade profile failed');
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


     -------------------------------------------------
     -- Call the private API
     -------------------------------------------------
     l_pvt_supp_rec.supp_trade_profile_id := l_supp_trade_profile_rec.supp_trade_profile_id ;

      IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Calling private Update profile');
      END IF;

     OZF_SUPP_TRADE_PROFILE_PVT.Update_Supp_Trade_Profile( p_api_version_number        => p_api_version_number,
                                                          p_init_msg_list              => p_init_msg_list,
                                                          x_return_status              => x_return_status,
                                                          x_msg_count                  => x_msg_count,
                                                          x_msg_data                   => x_msg_data,
                                                          p_supp_trade_profile_rec     => l_pvt_supp_rec,
                                                          x_object_version_number      => l_ver_num ) ;


      IF x_return_status = FND_API.g_ret_sts_error THEN
        IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Private update profile failed');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Private update profile failed');
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF(p_commit = FND_API.G_TRUE) THEN
        commit;
      END IF ;

      IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Ends');
      END IF;

    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count   => x_msg_count,
                p_data    => x_msg_data
          );

	IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm);
        END IF;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
         FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
         );
	 IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm);
        END IF;

       WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
         -- Standard call to get message count and if count=1, get the message
         FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
         );

	IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm);
        END IF;

END Update_Supp_Trade_Profile ;


---------------------------------------------------------------------
-- PROCEDURE
--    Process_code_conversion
--
-- PURPOSE
--    Public API for processing(create/update/delete) the code conversion
--    details
---------------------------------------------------------------------

PROCEDURE Process_code_conversion(
	p_api_version_number         IN   	 NUMBER,
	p_init_msg_list              IN          VARCHAR2     := FND_API.G_FALSE,
	P_Commit                     IN          VARCHAR2     := FND_API.G_FALSE,
	p_validation_level           IN          NUMBER       := FND_API.G_VALID_LEVEL_FULL,
	x_return_status              OUT NOCOPY  VARCHAR2,
	x_msg_count                  OUT NOCOPY  NUMBER,
	x_msg_data                   OUT NOCOPY  VARCHAR2,
	p_code_conversion_tbl        IN          code_conversion_tbl_type ,
	X_created_code_con_tbl       OUT NOCOPY  OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type ,
	X_updated_code_con_tbl       OUT NOCOPY  OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type ,
	X_deleted_code_con_tbl       OUT NOCOPY  OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type)


IS
	  L_API_NAME                  CONSTANT         VARCHAR2(30)	               := 'Process_code_conversion';

	  L_API_VERSION_NUMBER        CONSTANT         NUMBER                          := 1.0;

	  l_code_conversion_rec	      supp_code_conversion_rec_type ;

	  l_pvt_code_con_rec	      OZF_CODE_CONVERSION_PVT.supp_code_conversion_rec_type ;

	  l_crt_code_conv	      OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type := OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type() ;
	  l_crt_count		      NUMBER := 0 ;

	  l_upd_code_conv	      OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type := OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type() ;
	  l_upd_count		      NUMBER := 0 ;

	  l_del_code_conv	      OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type := OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type() ;
	  l_del_count                 NUMBER := 0 ;

	  l_code_conversion_id_tbl    JTF_NUMBER_TABLE ;

	  l_code_conversion_ver_tbl   JTF_NUMBER_TABLE ;

	  l_int_code_count            NUMBER := 0 ;
	  l_int_cc_count              NUMBER := 0 ;

	  l_exec_err                  VARCHAR2(1) := 'N' ;


	  CURSOR csr_supp_rec(cv_supp_trade_profile_id NUMBER)
          IS
	  select ORG_ID FROM ozf_supp_trd_prfls_all
	  WHERE supp_trade_profile_id= cv_supp_trade_profile_id ;

BEGIN

   IF g_debug THEN
	  ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Starts');
   END IF;

    -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (	   l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
   THEN
      IF g_debug THEN
          ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Incompatible Call');
      END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;



   ------------------------------------------------------------------------
   -- Traverse the code conversion table
   ------------------------------------------------------------------------

   FOR i in 1 .. p_code_conversion_tbl.COUNT
   LOOP

	 l_code_conversion_rec := p_code_conversion_tbl(i);

	OPEN csr_supp_rec( l_code_conversion_rec.supp_trade_profile_id);
	FETCH csr_supp_rec
		INTO  l_code_conversion_rec.ORG_ID;

	IF ( csr_supp_rec%NOTFOUND) THEN

		      IF g_debug THEN
				l_exec_err := 'Y' ;
				ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid record');
		      END IF;

	ELSE

		l_pvt_code_con_rec := NULL ;

		-- Convert to the PRIVATE API format
		l_pvt_code_con_rec.CODE_CONVERSION_ID           := l_code_conversion_rec.CODE_CONVERSION_ID ;
		l_pvt_code_con_rec.LAST_UPDATE_DATE		:= l_code_conversion_rec.LAST_UPDATE_DATE ;
		l_pvt_code_con_rec.LAST_UPDATED_BY		:= l_code_conversion_rec.LAST_UPDATED_BY ;
		l_pvt_code_con_rec.CREATION_DATE		:= l_code_conversion_rec.CREATION_DATE ;
		l_pvt_code_con_rec.CREATED_BY			:= l_code_conversion_rec.CREATED_BY ;
		l_pvt_code_con_rec.LAST_UPDATE_LOGIN		:= l_code_conversion_rec.LAST_UPDATE_LOGIN;
		l_pvt_code_con_rec.ORG_ID			:= l_code_conversion_rec.ORG_ID;
		l_pvt_code_con_rec.SUPP_TRADE_PROFILE_ID	:= l_code_conversion_rec.SUPP_TRADE_PROFILE_ID ;
		l_pvt_code_con_rec.CODE_CONVERSION_TYPE		:= l_code_conversion_rec.CODE_CONVERSION_TYPE;
		l_pvt_code_con_rec.EXTERNAL_CODE		:= l_code_conversion_rec.EXTERNAL_CODE ;
		l_pvt_code_con_rec.INTERNAL_CODE		:= l_code_conversion_rec.INTERNAL_CODE;
		l_pvt_code_con_rec.DESCRIPTION			:= l_code_conversion_rec.DESCRIPTION;

		IF (l_code_conversion_rec.START_DATE_ACTIVE = FND_API.G_MISS_DATE) THEN

			l_pvt_code_con_rec.START_DATE_ACTIVE := SYSDATE ;
		ELSE
			l_pvt_code_con_rec.START_DATE_ACTIVE := l_code_conversion_rec.START_DATE_ACTIVE ;
		END IF ;

		l_pvt_code_con_rec.END_DATE_ACTIVE		:= l_code_conversion_rec.END_DATE_ACTIVE;
		l_pvt_code_con_rec.ATTRIBUTE_CATEGORY		:= l_code_conversion_rec.ATTRIBUTE_CATEGORY;
		l_pvt_code_con_rec.ATTRIBUTE1			:= l_code_conversion_rec.ATTRIBUTE1;
		l_pvt_code_con_rec.ATTRIBUTE2			:= l_code_conversion_rec.ATTRIBUTE2 ;
		l_pvt_code_con_rec.ATTRIBUTE3			:= l_code_conversion_rec.ATTRIBUTE3 ;
		l_pvt_code_con_rec.ATTRIBUTE4			:= l_code_conversion_rec.ATTRIBUTE4 ;
		l_pvt_code_con_rec.ATTRIBUTE5			:= l_code_conversion_rec.ATTRIBUTE5 ;
		l_pvt_code_con_rec.ATTRIBUTE6			:= l_code_conversion_rec.ATTRIBUTE6 ;
		l_pvt_code_con_rec.ATTRIBUTE7			:= l_code_conversion_rec.ATTRIBUTE7 ;
		l_pvt_code_con_rec.ATTRIBUTE8			:= l_code_conversion_rec.ATTRIBUTE8 ;
		l_pvt_code_con_rec.ATTRIBUTE9			:= l_code_conversion_rec.ATTRIBUTE9 ;
		l_pvt_code_con_rec.ATTRIBUTE10			:= l_code_conversion_rec.ATTRIBUTE10 ;
		l_pvt_code_con_rec.ATTRIBUTE11			:= l_code_conversion_rec.ATTRIBUTE11 ;
		l_pvt_code_con_rec.ATTRIBUTE12			:= l_code_conversion_rec.ATTRIBUTE12 ;
		l_pvt_code_con_rec.ATTRIBUTE13			:= l_code_conversion_rec.ATTRIBUTE13 ;
		l_pvt_code_con_rec.ATTRIBUTE14			:= l_code_conversion_rec.ATTRIBUTE14 ;
		l_pvt_code_con_rec.ATTRIBUTE15			:= l_code_conversion_rec.ATTRIBUTE15 ;
		l_pvt_code_con_rec.SECURITY_GROUP_ID		:= l_code_conversion_rec.SECURITY_GROUP_ID ;



		-- Check for action to be performed on the code conversion record

		IF ( l_code_conversion_rec.CODE_CONVERSION_ACTION = 'C') THEN


				-- Validate the internal code

				l_pvt_code_con_rec.OBJECT_VERSION_NUMBER	:= 1;

				Validate_Code_Cov_rec(
					p_init_msg_list	=> p_init_msg_list,
					x_return_status => x_return_status,
					x_msg_count     => x_msg_count,
					x_msg_data      => x_msg_data,
					p_code_conv_rec => l_pvt_code_con_rec,
					p_mode		=> 'C') ;

				      IF g_debug THEN
					ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Validate code conv returned '||x_return_status );
				      END IF;
				-- Add to create list of the record is valid
				IF (x_return_status = FND_API.g_ret_sts_success ) THEN
					l_crt_code_conv.extend ;

					-- initialize the code conversion id
					SELECT ozf_supp_code_conv_all_s.nextval
						INTO l_pvt_code_con_rec.CODE_CONVERSION_ID
						FROM DUAL;

				        IF g_debug THEN
					  ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' New code conversion Id'||l_pvt_code_con_rec.CODE_CONVERSION_ID );
				        END IF;

					l_crt_code_conv(l_crt_code_conv.COUNT) := l_pvt_code_con_rec;

				ELSE
					l_exec_err := 'Y' ;
				END IF ;

		ELSIF (l_code_conversion_rec.CODE_CONVERSION_ACTION = 'U') THEN


				-- Populate the internal code
				Populate_code_conv_rec(
					    p_init_msg_list => p_init_msg_list,
					    x_return_status => x_return_status,
					    x_msg_count     => x_msg_count,
					    x_msg_data      => x_msg_data,
					    p_code_con_rec  => l_pvt_code_con_rec) ;

			        IF g_debug THEN
				  ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Populate code conv returned'||x_return_status );
				END IF;


				IF (x_return_status = FND_API.g_ret_sts_success) THEN

					-- Validate the internal code
					Validate_Code_Cov_rec(
						p_init_msg_list	=> p_init_msg_list,
						x_return_status => x_return_status,
						x_msg_count     => x_msg_count,
						x_msg_data      => x_msg_data,
						p_code_conv_rec => l_pvt_code_con_rec,
						p_mode		=> 'U') ;

					IF g_debug THEN
				             ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Validate code conv returned'||x_return_status );
				        END IF;

					-- Add the valid record to update list
					IF (x_return_status = FND_API.g_ret_sts_success ) THEN

					    l_upd_code_conv.extend ;
					    l_upd_code_conv(l_upd_code_conv.COUNT) := l_pvt_code_con_rec;

					ELSE

						l_exec_err := 'Y' ;
					END IF ;
				END IF ;

		ELSIF (l_code_conversion_rec.CODE_CONVERSION_ACTION = 'D') THEN

			   -- Validate the code conversion Id

			    SELECT COUNT(1) INTO l_int_cc_count
			    FROM ozf_supp_code_conversions_all
			    WHERE code_conversion_id = l_pvt_code_con_rec.CODE_CONVERSION_ID ;

			    IF (l_int_cc_count > 0) THEN
				l_del_code_conv.extend ;
				l_del_code_conv(l_del_code_conv.COUNT) := l_pvt_code_con_rec;

			    END IF ;
		END IF ;


	END IF ; -- cursor record found

	CLOSE csr_supp_rec;

  END LOOP ;


   ------------------------------------------------------------------------
   -- Call the private API based on the record action
   ------------------------------------------------------------------------

   IF ( l_crt_code_conv.count >0 ) THEN

	-- Mass insertion

		-- Perform bulk operation if the DB version is 11G
		$IF DBMS_DB_VERSION.VER_LE_10 $THEN


			FOR indx IN 1..l_crt_code_conv.COUNT LOOP
				  INSERT INTO ozf_supp_code_conversions_all(
				   code_conversion_id,
				   object_version_number,
				   last_update_date,
				   last_updated_by,
				   creation_date,
				   created_by,
				   last_update_login,
				   org_id,
				   supp_trade_profile_id,
				   code_conversion_type,
				   external_code,
				   internal_code,
				   description,
				   start_date_active,
				   end_date_active,
				   attribute_category,
				   attribute1,
				   attribute2,
				   attribute3,
				   attribute4,
				   attribute5,
				   attribute6,
				   attribute7,
				   attribute8,
				   attribute9,
				   attribute10,
				   attribute11,
				   attribute12,
				   attribute13,
				   attribute14,
				   attribute15
			   ) VALUES (
				   l_crt_code_conv(indx).CODE_CONVERSION_ID,
				   l_crt_code_conv(indx).OBJECT_VERSION_NUMBER,
				   SYSDATE,
				   FND_GLOBAL.USER_ID,
				   SYSDATE,
				   FND_GLOBAL.USER_ID,
				   FND_GLOBAL.CONC_LOGIN_ID,
				   l_crt_code_conv(indx).ORG_ID,
				   l_crt_code_conv(indx).SUPP_TRADE_PROFILE_ID,
				   DECODE( l_crt_code_conv(indx).code_conversion_type, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).code_conversion_type),
				   DECODE( l_crt_code_conv(indx).external_code, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).external_code),
				   DECODE( l_crt_code_conv(indx).internal_code, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).internal_code),
				   DECODE( l_crt_code_conv(indx).description, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).description),
				   DECODE( l_crt_code_conv(indx).start_date_active, FND_API.G_MISS_DATE, to_date(NULL), l_crt_code_conv(indx).start_date_active),
				   DECODE( l_crt_code_conv(indx).end_date_active, FND_API.G_MISS_DATE, to_date(NULL), l_crt_code_conv(indx).end_date_active),
				   DECODE( l_crt_code_conv(indx).attribute_category, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute_category),
				   DECODE( l_crt_code_conv(indx).attribute1, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute1),
				   DECODE( l_crt_code_conv(indx).attribute2, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute2),
				   DECODE( l_crt_code_conv(indx).attribute3, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute3),
				   DECODE( l_crt_code_conv(indx).attribute4, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute4),
				   DECODE( l_crt_code_conv(indx).attribute5, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute5),
				   DECODE( l_crt_code_conv(indx).attribute6, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute6),
				   DECODE( l_crt_code_conv(indx).attribute7, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute7),
				   DECODE( l_crt_code_conv(indx).attribute8, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute8),
				   DECODE( l_crt_code_conv(indx).attribute9, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute9),
				   DECODE( l_crt_code_conv(indx).attribute10, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute10),
				   DECODE( l_crt_code_conv(indx).attribute11, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute11),
				   DECODE( l_crt_code_conv(indx).attribute12, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute12),
				   DECODE( l_crt_code_conv(indx).attribute13, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute13),
				   DECODE( l_crt_code_conv(indx).attribute14, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute14),
				   DECODE( l_crt_code_conv(indx).attribute15, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute15)
				   );

				 END LOOP ;



		$ELSE

				FORALL indx IN 1..l_crt_code_conv.count
				  INSERT INTO ozf_supp_code_conversions_all(
				   code_conversion_id,
				   object_version_number,
				   last_update_date,
				   last_updated_by,
				   creation_date,
				   created_by,
				   last_update_login,
				   org_id,
				   supp_trade_profile_id,
				   code_conversion_type,
				   external_code,
				   internal_code,
				   description,
				   start_date_active,
				   end_date_active,
				   attribute_category,
				   attribute1,
				   attribute2,
				   attribute3,
				   attribute4,
				   attribute5,
				   attribute6,
				   attribute7,
				   attribute8,
				   attribute9,
				   attribute10,
				   attribute11,
				   attribute12,
				   attribute13,
				   attribute14,
				   attribute15
			   ) VALUES (
				   l_crt_code_conv(indx).CODE_CONVERSION_ID,
				   l_crt_code_conv(indx).OBJECT_VERSION_NUMBER,
				   SYSDATE,
				   FND_GLOBAL.USER_ID,
				   SYSDATE,
				   FND_GLOBAL.USER_ID,
				   FND_GLOBAL.CONC_LOGIN_ID,
				   l_crt_code_conv(indx).ORG_ID,
				   l_crt_code_conv(indx).SUPP_TRADE_PROFILE_ID,
				   DECODE( l_crt_code_conv(indx).code_conversion_type, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).code_conversion_type),
				   DECODE( l_crt_code_conv(indx).external_code, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).external_code),
				   DECODE( l_crt_code_conv(indx).internal_code, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).internal_code),
				   DECODE( l_crt_code_conv(indx).description, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).description),
				   DECODE( l_crt_code_conv(indx).start_date_active, FND_API.G_MISS_DATE, to_date(NULL), l_crt_code_conv(indx).start_date_active),
				   DECODE( l_crt_code_conv(indx).end_date_active, FND_API.G_MISS_DATE, to_date(NULL), l_crt_code_conv(indx).end_date_active),
				   DECODE( l_crt_code_conv(indx).attribute_category, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute_category),
				   DECODE( l_crt_code_conv(indx).attribute1, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute1),
				   DECODE( l_crt_code_conv(indx).attribute2, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute2),
				   DECODE( l_crt_code_conv(indx).attribute3, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute3),
				   DECODE( l_crt_code_conv(indx).attribute4, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute4),
				   DECODE( l_crt_code_conv(indx).attribute5, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute5),
				   DECODE( l_crt_code_conv(indx).attribute6, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute6),
				   DECODE( l_crt_code_conv(indx).attribute7, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute7),
				   DECODE( l_crt_code_conv(indx).attribute8, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute8),
				   DECODE( l_crt_code_conv(indx).attribute9, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute9),
				   DECODE( l_crt_code_conv(indx).attribute10, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute10),
				   DECODE( l_crt_code_conv(indx).attribute11, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute11),
				   DECODE( l_crt_code_conv(indx).attribute12, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute12),
				   DECODE( l_crt_code_conv(indx).attribute13, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute13),
				   DECODE( l_crt_code_conv(indx).attribute14, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute14),
				   DECODE( l_crt_code_conv(indx).attribute15, FND_API.g_miss_char, NULL, l_crt_code_conv(indx).attribute15)
				   );


		$END


	IF (P_Commit = FND_API.G_TRUE) THEN

		COMMIT ;
		X_created_code_con_tbl := l_crt_code_conv ;
		IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Mass Insertion was successful' );
		END IF;
	END IF ;


   END IF ;


   IF (l_upd_code_conv.count >0 ) THEN

	-- Mass update: Perform bulk operation if the DB versio is 11G
		$IF DBMS_DB_VERSION.VER_LE_10 $THEN

			      FOR indx IN 1..l_upd_code_conv.COUNT LOOP

				   Update ozf_supp_code_conversions_all
				    SET
				      object_version_number	= l_upd_code_conv(indx).object_version_number +1 ,
				      last_update_date		= sysdate,
				      last_updated_by		= FND_GLOBAL.USER_ID,
				      last_update_login		= FND_GLOBAL.CONC_LOGIN_ID,
				      org_id			= l_upd_code_conv(indx).org_id,
				      supp_trade_profile_id	= l_upd_code_conv(indx).supp_trade_profile_id ,
				      code_conversion_type	= l_upd_code_conv(indx).code_conversion_type,
				      external_code		= l_upd_code_conv(indx).external_code,
				      internal_code		= l_upd_code_conv(indx).internal_code,
				      description		= l_upd_code_conv(indx).description,
				      start_date_active		= l_upd_code_conv(indx).start_date_active,
				      end_date_active		= l_upd_code_conv(indx).end_date_active,
				      attribute_category	= l_upd_code_conv(indx).attribute_category,
				      attribute1		= l_upd_code_conv(indx).attribute1,
				      attribute2		= l_upd_code_conv(indx).attribute2,
				      attribute3		= l_upd_code_conv(indx).attribute3,
				      attribute4		= l_upd_code_conv(indx).attribute4,
				      attribute5		= l_upd_code_conv(indx).attribute5,
				      attribute6		= l_upd_code_conv(indx).attribute6,
				      attribute7		= l_upd_code_conv(indx).attribute7,
				      attribute8		= l_upd_code_conv(indx).attribute8,
				      attribute9		= l_upd_code_conv(indx).attribute9,
				      attribute10		= l_upd_code_conv(indx).attribute10,
				      attribute11		= l_upd_code_conv(indx).attribute11,
				      attribute12		= l_upd_code_conv(indx).attribute12,
				      attribute13		= l_upd_code_conv(indx).attribute13,
				      attribute14		= l_upd_code_conv(indx).attribute14,
				      attribute15		= l_upd_code_conv(indx).attribute15
				WHERE
				      code_conversion_id	= l_upd_code_conv(indx).code_conversion_id ;

			      END LOOP ;



			$ELSE

				FORALL indx IN 1..l_upd_code_conv.count

				   Update ozf_supp_code_conversions_all
				    SET
				      object_version_number	= l_upd_code_conv(indx).object_version_number +1 ,
				      last_update_date		= sysdate,
				      last_updated_by		= FND_GLOBAL.USER_ID,
				      last_update_login		= FND_GLOBAL.CONC_LOGIN_ID,
				      org_id			= l_upd_code_conv(indx).org_id,
				      supp_trade_profile_id	= l_upd_code_conv(indx).supp_trade_profile_id ,
				      code_conversion_type	= l_upd_code_conv(indx).code_conversion_type,
				      external_code		= l_upd_code_conv(indx).external_code,
				      internal_code		= l_upd_code_conv(indx).internal_code,
				      description		= l_upd_code_conv(indx).description,
				      start_date_active		= l_upd_code_conv(indx).start_date_active,
				      end_date_active		= l_upd_code_conv(indx).end_date_active,
				      attribute_category	= l_upd_code_conv(indx).attribute_category,
				      attribute1		= l_upd_code_conv(indx).attribute1,
				      attribute2		= l_upd_code_conv(indx).attribute2,
				      attribute3		= l_upd_code_conv(indx).attribute3,
				      attribute4		= l_upd_code_conv(indx).attribute4,
				      attribute5		= l_upd_code_conv(indx).attribute5,
				      attribute6		= l_upd_code_conv(indx).attribute6,
				      attribute7		= l_upd_code_conv(indx).attribute7,
				      attribute8		= l_upd_code_conv(indx).attribute8,
				      attribute9		= l_upd_code_conv(indx).attribute9,
				      attribute10		= l_upd_code_conv(indx).attribute10,
				      attribute11		= l_upd_code_conv(indx).attribute11,
				      attribute12		= l_upd_code_conv(indx).attribute12,
				      attribute13		= l_upd_code_conv(indx).attribute13,
				      attribute14		= l_upd_code_conv(indx).attribute14,
				      attribute15		= l_upd_code_conv(indx).attribute15
				WHERE
				      code_conversion_id	= l_upd_code_conv(indx).code_conversion_id ;


		$END


	IF (P_Commit = FND_API.G_TRUE) THEN

		COMMIT ;
		X_updated_code_con_tbl := l_upd_code_conv ;
		IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Mass Update was successful' );
		END IF;
	END IF ;

   END IF ;

   IF (l_del_code_conv.COUNT >0 ) THEN

	-- Mass delete
		$IF DBMS_DB_VERSION.VER_LE_10 $THEN

			FOR indx IN 1..l_del_code_conv.COUNT LOOP
				DELETE FROM ozf_supp_code_conversions_all
					WHERE
					code_conversion_id	= l_del_code_conv(indx).code_conversion_id ;
			END LOOP ;



		$ELSE

			FORALL indx IN 1..l_del_code_conv.count
				DELETE FROM ozf_supp_code_conversions_all
					WHERE
					code_conversion_id	= l_del_code_conv(indx).code_conversion_id ;


		$END

		IF (P_Commit = FND_API.G_TRUE) THEN

		COMMIT ;
		X_deleted_code_con_tbl := l_del_code_conv ;
		IF g_debug THEN
			ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Mass Delete was successful' );
		END IF;
	END IF ;

   END IF ;


    IF (l_exec_err = 'Y') THEN
	x_return_status := FND_API.g_ret_sts_error ;
    END IF ;

    IF g_debug THEN
	ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' End' );
     END IF;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

      IF g_debug THEN
	ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm );
     END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

     IF g_debug THEN
	ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm );
     END IF;

   WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

     IF g_debug THEN
	ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm );
     END IF;


END Process_code_conversion ;






---------------------------------------------------------------------
-- PROCEDURE
--    Process_price_protection
--
-- PURPOSE
--    Public API for processing(create/update/delete) the price protection
--    details
---------------------------------------------------------------------

 PROCEDURE Process_price_protection(
   P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_trade_prf_id               IN          NUMBER,
    p_process_setup_tbl          IN          process_setup_tbl_type  ,
    X_created_process_tbl        OUT NOCOPY  OZF_PROCESS_SETUP_PVT.process_setup_tbl_type,
    X_updated_process_tbl        OUT NOCOPY  OZF_PROCESS_SETUP_PVT.process_setup_tbl_type)
IS
	  L_API_NAME                  CONSTANT         VARCHAR2(30)	               := 'Process_price_protection';

	  L_API_VERSION_NUMBER        CONSTANT         NUMBER                          := 1.0;
	  CURSOR c_get_pp_data IS
		SELECT	NVL(ps.enabled_flag,'N') enabledFlag,
			ps.process_setup_id processSetupId,
			ps.process_setup_id objId,
			ps.org_id orgId,
			fl.meaning processName,
			ps.object_version_number objVerNum,
			fl.lookup_code processCode,
			ps.supp_trade_profile_id suppTradeProfileId,
			NVL(ps.automatic_flag,'N') automaticFlag,
			ps.SECURITY_GROUP_ID secGrpId,
			ps.attribute_category attribute_category,
			ps.attribute1 attribute1,
			ps.attribute1 attribute2,
			ps.attribute1 attribute3,
			ps.attribute1 attribute4,
			ps.attribute1 attribute5,
			ps.attribute1 attribute6,
			ps.attribute1 attribute7,
			ps.attribute1 attribute8,
			ps.attribute1 attribute9,
			ps.attribute1 attribute10,
			ps.attribute1 attribute11,
			ps.attribute1 attribute12,
			ps.attribute1 attribute13,
			ps.attribute1 attribute14,
			ps.attribute1 attribute15
			FROM dpp_lookups fl , ozf_process_setup_all ps
			WHERE (ps.supp_trade_profile_id(+) =  p_trade_prf_id
			AND fl.lookup_type = 'DPP_EXECUTION_PROCESSES'
			AND fl.lookup_code = ps.process_code (+)
			AND fl.tag is not NULL
			AND fl.enabled_flag = 'Y')
			ORDER BY fl.lookup_code ;

	l_process_exists   VARCHAR2(1) := 'N' ;

	l_process_rec      OZF_PROCESS_SETUP_PVT.process_setup_rec_type  ;
	l_process_crt_tbl   OZF_PROCESS_SETUP_PVT.process_setup_tbl_type := OZF_PROCESS_SETUP_PVT.process_setup_tbl_type() ;
	l_crt_count        NUMBER := 0 ;

	l_process_upd_tbl   OZF_PROCESS_SETUP_PVT.process_setup_tbl_type := OZF_PROCESS_SETUP_PVT.process_setup_tbl_type() ;
	l_upd_count	   NUMBER := 0 ;

	l_org_id           NUMBER := 0 ;

	l_crt_id_tbl       JTF_NUMBER_TABLE ;

	l_exec_err	   VARCHAR2(1) := 'N' ;

	CURSOR c_sel_trd_org IS
	SELECT org_id FROM ozf_supp_trd_prfls_all
	WHERE supp_trade_profile_id =  p_trade_prf_id ;

BEGIN


     IF g_debug THEN
	ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||'Starts' );
     END IF;

    -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (	   l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
   THEN
       IF g_debug THEN
	 ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Incopatible Call' );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;


   x_return_status := FND_API.g_ret_sts_success ;



   -- If the supplier trade profile Id is null, then return

   OPEN c_sel_trd_org ;

   FETCH c_sel_trd_org INTO l_org_id ;


   IF ( c_sel_trd_org%NOTFOUND) THEN

	IF g_debug THEN
	    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid record' );
        END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	RETURN ;
   ELSE
		   ---------------------------------------------------
		   --Traverse the process setup table
		   ---------------------------------------------------

		   FOR r_pp_data IN c_get_pp_data LOOP

			l_process_exists := 'N' ;

			<<api_loop>> FOR indx in 1 .. p_process_setup_tbl.COUNT
			 LOOP

				-- Check if the process code exixts in the table
				IF (p_process_setup_tbl(indx).PROCESS_CODE = r_pp_data.processCode ) THEN

					l_process_exists := 'Y' ;


					---------------------------------------------------------------------
					--- SET THE DATA FOR UPDATE : START
					---------------------------------------------------------------------
					IF (r_pp_data.processSetupId IS NOT NULL ) then


							l_process_rec := null ;

							l_process_rec.PROCESS_SETUP_ID		:= r_pp_data.processSetupId ;
							l_process_rec.OBJECT_VERSION_NUMBER	:= r_pp_data.objVerNum ;
							l_process_rec.LAST_UPDATE_DATE		:= SYSDATE ;

							IF (p_process_setup_tbl(indx).last_updated_by = FND_API.G_MISS_NUM) THEN
								l_process_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID ;
							ELSE
								l_process_rec.LAST_UPDATED_BY := p_process_setup_tbl(indx).last_updated_by ;
							END IF ;


							l_process_rec.ORG_ID                    := r_pp_data.orgId ;
							l_process_rec.SUPP_TRADE_PROFILE_ID     := r_pp_data.suppTradeProfileId ;
							l_process_rec.PROCESS_CODE		:= r_pp_data.processCode ;



							IF(p_process_setup_tbl(indx).ENABLED_FLAG IS NULL OR
							   p_process_setup_tbl(indx).ENABLED_FLAG= FND_API.g_miss_char) THEN

							    l_process_rec.ENABLED_FLAG := r_pp_data.enabledFlag ;

							 ELSE
							   IF(p_process_setup_tbl(indx).ENABLED_FLAG NOT IN ('Y','N')) THEN
								IF g_debug THEN
									ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid Enabled Flag' );
								END IF;
								l_exec_err := 'Y' ;
								EXIT api_loop ;

							   ELSE
								l_process_rec.ENABLED_FLAG              := p_process_setup_tbl(indx).ENABLED_FLAG ;
							   END IF ;

							 END IF ;



							IF(p_process_setup_tbl(indx).AUTOMATIC_FLAG IS NULL OR
							   p_process_setup_tbl(indx).AUTOMATIC_FLAG= FND_API.g_miss_char) THEN

							    l_process_rec.AUTOMATIC_FLAG := r_pp_data.automaticFlag ;

							 ELSE

							   IF (p_process_setup_tbl(indx).AUTOMATIC_FLAG NOT IN ('Y','N')) THEN

								IF g_debug THEN
									ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid Automatic Flag' );
								END IF;
								l_exec_err := 'Y' ;
								EXIT api_loop ;

							   ELSE
								   l_process_rec.AUTOMATIC_FLAG              := p_process_setup_tbl(indx).AUTOMATIC_FLAG ;
							   END IF ;

							 END IF ;



							IF (p_process_setup_tbl(indx).attribute_category = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE_CATEGORY := r_pp_data.attribute_category ;
							ELSE
								l_process_rec.ATTRIBUTE_CATEGORY := p_process_setup_tbl(indx).attribute_category ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute1 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE1 := r_pp_data.attribute1 ;
							ELSE
								l_process_rec.ATTRIBUTE1 := p_process_setup_tbl(indx).attribute1 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute2 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE2 := r_pp_data.attribute2 ;
							ELSE
								l_process_rec.ATTRIBUTE2 := p_process_setup_tbl(indx).attribute2 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute3 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE3 := r_pp_data.attribute3 ;
							ELSE
								l_process_rec.ATTRIBUTE3 := p_process_setup_tbl(indx).attribute3 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute4 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE4 := r_pp_data.attribute4 ;
							ELSE
								l_process_rec.ATTRIBUTE4 := p_process_setup_tbl(indx).attribute4 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute5 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE5 := r_pp_data.attribute5 ;
							ELSE
								l_process_rec.ATTRIBUTE5 := p_process_setup_tbl(indx).attribute5 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute6 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE6 := r_pp_data.attribute6 ;
							ELSE
								l_process_rec.ATTRIBUTE6 := p_process_setup_tbl(indx).attribute6 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute7 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE7 := r_pp_data.attribute7 ;
							ELSE
								l_process_rec.ATTRIBUTE7 := p_process_setup_tbl(indx).attribute7 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute8 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE8 := r_pp_data.attribute8 ;
							ELSE
								l_process_rec.ATTRIBUTE8 := p_process_setup_tbl(indx).attribute8 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute9 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE9 := r_pp_data.attribute9 ;
							ELSE
								l_process_rec.ATTRIBUTE9 := p_process_setup_tbl(indx).attribute9 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute10 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE10 := r_pp_data.attribute10 ;
							ELSE
								l_process_rec.ATTRIBUTE10 := p_process_setup_tbl(indx).attribute10 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute11 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE11 := r_pp_data.attribute11 ;
							ELSE
								l_process_rec.ATTRIBUTE11 := p_process_setup_tbl(indx).attribute11 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute12 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE12 := r_pp_data.attribute12 ;
							ELSE
								l_process_rec.ATTRIBUTE12 := p_process_setup_tbl(indx).attribute12 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute13 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE13 := r_pp_data.attribute13 ;
							ELSE
								l_process_rec.ATTRIBUTE13 := p_process_setup_tbl(indx).attribute13 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute14 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE14 := r_pp_data.attribute14 ;
							ELSE
								l_process_rec.ATTRIBUTE14 := p_process_setup_tbl(indx).attribute14 ;
							END IF ;

							IF (p_process_setup_tbl(indx).attribute15 = FND_API.g_miss_char) THEN
								l_process_rec.ATTRIBUTE15 := r_pp_data.attribute15 ;
							ELSE
								l_process_rec.ATTRIBUTE15 := p_process_setup_tbl(indx).attribute15 ;
							END IF ;



							IF (p_process_setup_tbl(indx).SECURITY_GROUP_ID = FND_API.g_miss_num) THEN
								l_process_rec.SECURITY_GROUP_ID := r_pp_data.secGrpId ;
							ELSE
								l_process_rec.SECURITY_GROUP_ID :=  p_process_setup_tbl(indx).SECURITY_GROUP_ID ;
							END IF ;



							----------------------------------------------------------------------------------------
							-- SET THE DATA FOR UPDATE : END
							----------------------------------------------------------------------------------------
							IF g_debug THEN
								ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Data for update' );
							END IF;
							l_process_upd_tbl.extend ;
							l_process_upd_tbl(l_process_upd_tbl.COUNT) := l_process_rec ;
							l_upd_count := l_upd_count +1 ;



					  ELSE


							--------------------------------------------------------------------------
							-- SET THE DATA FOR CREATE : END
							--------------------------------------------------------------------------
							l_process_rec := null ;


							l_process_rec.ORG_ID                    := l_org_id ;
							l_process_rec.SUPP_TRADE_PROFILE_ID     := p_trade_prf_id ;
							l_process_rec.PROCESS_CODE		:= r_pp_data.processCode ;


							IF(p_process_setup_tbl(indx).ENABLED_FLAG IS NULL OR
							   p_process_setup_tbl(indx).ENABLED_FLAG= FND_API.g_miss_char) THEN

							    l_process_rec.ENABLED_FLAG := 'N' ;-- Default to No

							 ELSE
							   IF(p_process_setup_tbl(indx).ENABLED_FLAG NOT IN ('Y','N')) THEN
								IF g_debug THEN
									ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid Enabled Flag' );
								END IF;
								l_exec_err := 'Y' ;
								EXIT api_loop ;

							   ELSE
								l_process_rec.ENABLED_FLAG  := p_process_setup_tbl(indx).ENABLED_FLAG ;
							   END IF ;

							 END IF ;



							IF(p_process_setup_tbl(indx).AUTOMATIC_FLAG IS NULL OR
							   p_process_setup_tbl(indx).AUTOMATIC_FLAG= FND_API.g_miss_char) THEN

							    l_process_rec.AUTOMATIC_FLAG := 'N' ;-- Default to NO

							 ELSE

							   IF (p_process_setup_tbl(indx).AUTOMATIC_FLAG NOT IN ('Y','N')) THEN

								IF g_debug THEN
									ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Invalid Automatic Flag' );
								END IF;
								l_exec_err := 'Y' ;
								EXIT api_loop ;

							   ELSE
								   l_process_rec.AUTOMATIC_FLAG  := p_process_setup_tbl(indx).AUTOMATIC_FLAG ;
							   END IF ;

							 END IF ;




							l_process_rec.ATTRIBUTE_CATEGORY	:= p_process_setup_tbl(indx).attribute_category ;
							l_process_rec.ATTRIBUTE1		:= p_process_setup_tbl(indx).attribute1 ;
							l_process_rec.ATTRIBUTE2		:= p_process_setup_tbl(indx).attribute2 ;
							l_process_rec.ATTRIBUTE3		:= p_process_setup_tbl(indx).attribute3 ;
							l_process_rec.ATTRIBUTE4		:= p_process_setup_tbl(indx).attribute4 ;
							l_process_rec.ATTRIBUTE5		:= p_process_setup_tbl(indx).attribute5 ;
							l_process_rec.ATTRIBUTE6		:= p_process_setup_tbl(indx).attribute6 ;
							l_process_rec.ATTRIBUTE7		:= p_process_setup_tbl(indx).attribute7 ;
							l_process_rec.ATTRIBUTE8		:= p_process_setup_tbl(indx).attribute8 ;
							l_process_rec.ATTRIBUTE9		:= p_process_setup_tbl(indx).attribute9 ;
							l_process_rec.ATTRIBUTE10		:= p_process_setup_tbl(indx).attribute10 ;
							l_process_rec.ATTRIBUTE11		:= p_process_setup_tbl(indx).attribute11 ;
							l_process_rec.ATTRIBUTE12		:= p_process_setup_tbl(indx).attribute12 ;
							l_process_rec.ATTRIBUTE13		:= p_process_setup_tbl(indx).attribute13 ;
							l_process_rec.ATTRIBUTE14		:= p_process_setup_tbl(indx).attribute14 ;
							l_process_rec.ATTRIBUTE15		:= p_process_setup_tbl(indx).attribute15 ;
							l_process_rec.SECURITY_GROUP_ID		:= p_process_setup_tbl(indx).SECURITY_GROUP_ID ;

							----------------------------------------------------------------------------------------
							-- SET THE DATA FOR CREATE : END
							----------------------------------------------------------------------------------------
							IF g_debug THEN
								ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Data for create' );
							END IF;
							l_process_crt_tbl.extend ;
							l_process_crt_tbl(l_process_crt_tbl.COUNT) := l_process_rec ;
							l_crt_count := l_crt_count +1 ;


					  END IF ;

				END IF ;


				EXIT api_loop WHEN l_process_exists = 'Y' ;

			END LOOP api_loop ;

			-- If the flag is N , it means the DB record needs to be created

			IF (l_process_exists = 'N' AND r_pp_data.processSetupId IS NULL) THEN

				--------------------------------------------------------------------------
				-- The data for respective process code needs to be created
				--------------------------------------------------------------------------
				l_process_rec := null ;

				l_process_rec.ORG_ID                    := l_org_id ;
				l_process_rec.SUPP_TRADE_PROFILE_ID     := p_trade_prf_id ;
				l_process_rec.PROCESS_CODE		:= r_pp_data.processCode ;
				l_process_rec.ENABLED_FLAG              := r_pp_data.enabledFlag ;
				l_process_rec.AUTOMATIC_FLAG		:= r_pp_data.automaticFlag ;

				----------------------------------------------------------------------------------------
				-- SET THE DATA FOR CREATE : END
				----------------------------------------------------------------------------------------
				IF g_debug THEN
					ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Data for create' );
				END IF;
				l_process_crt_tbl.extend ;
				l_process_crt_tbl(l_process_crt_tbl.COUNT) := l_process_rec ;
				l_crt_count := l_crt_count +1 ;


			END IF ;


		   END LOOP ;



		   ----------------------------------------------------
		   -- Call the private API
		   ----------------------------------------------------
		   IF (l_process_crt_tbl.COUNT >0) THEN


			   OZF_PROCESS_SETUP_PVT.create_process_setup(  p_api_version_number         => P_Api_Version_Number ,
								        x_return_status              => X_Return_Status ,
									x_msg_count                  => X_Msg_Count ,
									x_msg_data                   => X_Msg_Data ,
									p_process_setup_tbl          => l_process_crt_tbl,
									x_process_setup_id_tbl       => l_crt_id_tbl
									) ;

			   IF g_debug THEN
				ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Private create process setup returned'||x_return_status );
			   END IF;

			   IF (x_return_status = FND_API.g_ret_sts_success) THEN

			       X_created_process_tbl := l_process_crt_tbl;

			       IF(P_Commit = FND_API.G_TRUE) THEN
					COMMIT ;
			       END IF ;

			   ELSE
			        l_exec_err := 'Y' ;
			   END IF ;

		   END IF ;

		   IF (l_process_upd_tbl.COUNT >0) THEN


			OZF_PROCESS_SETUP_PVT.Update_Process_Setup_Tbl(
								    P_Api_Version_Number  => P_Api_Version_Number ,
								    P_Init_Msg_List       => P_Init_Msg_List ,
								    p_validation_level    => FND_API.G_VALID_LEVEL_FULL ,
								    X_Return_Status       => X_Return_Status ,
								    X_Msg_Count           => X_Msg_Count,
								    X_Msg_Data            => X_Msg_Data,
								    P_process_setup_Tbl   => l_process_upd_tbl) ;

			  IF g_debug THEN
				ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Private Update process setup returned'||x_return_status );
			   END IF;

			  IF g_debug THEN
				ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||' Message returned'||X_Msg_Data );
			   END IF;

			IF (x_return_status = FND_API.g_ret_sts_success) THEN
				X_updated_process_tbl := l_process_upd_tbl ;
				IF(P_Commit = FND_API.G_TRUE) THEN
					COMMIT ;
			       END IF ;
			ELSE
				l_exec_err := 'Y' ;
			END IF ;



		   END IF ;

    END IF ;

    IF (l_exec_err = 'Y') THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF ;

    EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data  );

      IF g_debug THEN
	ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF-STP',G_PKG_NAME||'.'||L_API_NAME||sqlerrm );
      END IF;

END Process_price_protection ;



END OZF_SUPP_TRADE_PROFILE_PUB;



/
