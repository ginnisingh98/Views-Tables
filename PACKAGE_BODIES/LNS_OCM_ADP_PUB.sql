--------------------------------------------------------
--  DDL for Package Body LNS_OCM_ADP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_OCM_ADP_PUB" AS
/*$Header: LNS_ADP_PUBP_B.pls 120.7.12010000.2 2009/10/09 13:53:14 mbolli ship $ */

 g_exchange_rate_type    AR_CMGT_SETUP_OPTIONS.default_exchange_rate_type%TYPE;

/*===========================================================================+
 | FUNCTION    - loan_request_amount
 |
 |
 | DESCRIPTION - Returns the requested amount for loan.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    : Loan Requested Amount
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION loan_request_amount(x_resultout	OUT NOCOPY VARCHAR2,
       						 x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

l_cr_loan_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1  ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_loan_req_amt lns_loan_headers_all.requested_amount%TYPE ;
l_loan_currency lns_loan_headers_all.loan_currency%TYPE ;

BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
	   SELECT requested_amount , loan_currency
	   INTO  l_loan_req_amt , l_loan_currency
	   FROM  lns_loan_headers_all
	   WHERE loan_id = l_cr_loan_id ;


       IF(l_cr_currency<>l_loan_currency) THEN
                l_loan_req_amt := gl_currency_api.convert_amount(l_loan_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_loan_req_amt);
       END IF ;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_loan_req_amt := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char(l_loan_req_amt) ;

RETURN to_char( NVL(l_loan_req_amt,0) );


END loan_request_amount ;




/*===========================================================================+
 | FUNCTION     is_secured_loan
 |
 |
 | DESCRIPTION    Checks if the given loan is secured loan or not
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Y - if the loan is secured
 |		 N - If the loan is not secured
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/


FUNCTION is_secured_loan (x_resultout	OUT NOCOPY VARCHAR2,
       						 x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_cr_loan_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1  ) ;

l_loan_subtype lns_loan_headers_all.loan_subtype%TYPE ;
l_loan_secured VARCHAR2(1) ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
	   SELECT loan_subtype
	   INTO  l_loan_subtype
	   FROM  lns_loan_headers_all
	   WHERE loan_id = l_cr_loan_id ;

       IF(l_loan_subtype = 'SECURED' ) THEN
            l_loan_secured := 'Y' ;
       ELSE
            l_loan_secured := 'N' ;
       END IF ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_loan_secured := 'N' ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					NVL(l_loan_secured,'N') ;

RETURN NVL(l_loan_secured,'N');


END is_secured_loan ;


/*===========================================================================+
 | FUNCTION     loan_collateral_percentage
 |
 |
 | DESCRIPTION
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Collateral percentage required for this loan
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION loan_collateral_percentage (x_resultout	OUT NOCOPY VARCHAR2,
               						 x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_cr_loan_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1 ) ;

l_loan_collateral_perecent lns_loan_headers_all.collateral_percent%TYPE ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
	   SELECT collateral_percent
	   INTO  l_loan_collateral_perecent
	   FROM  lns_loan_headers_all
	   WHERE loan_id = l_cr_loan_id ;



	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_loan_collateral_perecent := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char(l_loan_collateral_perecent) ;

RETURN to_char( NVL(l_loan_collateral_perecent,0) );


END loan_collateral_percentage ;



/*===========================================================================+
 | FUNCTION     initial_intrest_rate
 |
 |
 | DESCRIPTION    Returns the initial interest rate for this loan.
 |		  Thats the interest rate for installement number 1
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Initial Interest Rate
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION initial_intrest_rate (x_resultout	OUT NOCOPY VARCHAR2,
               				   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS
l_cr_loan_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1 ) ;

l_initial_interest_rate lns_rate_schedules.current_interest_rate%TYPE ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
	   SELECT lrs.current_interest_rate
       INTO l_initial_interest_rate
       FROM lns_rate_schedules lrs,
            lns_loan_headers_all llh ,
            lns_terms lt
       WHERE llh.loan_id = l_cr_loan_id
       AND lt.loan_id = llh.loan_id
       AND lrs.term_id = lt.term_id
       AND lrs.begin_installment_number = 1
       AND llh.CURRENT_PHASE = lrs.PHASE;



	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_initial_interest_rate := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char(l_initial_interest_rate) ;

RETURN to_char( NVL(l_initial_interest_rate,0) );


END initial_intrest_rate ;




/*===========================================================================+
 | FUNCTION     number_of_coborrowers
 |
 |
 | DESCRIPTION    Number of co-borrowers for the current loan
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Number of Co-Borrowers
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION number_of_coborrowers (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_cr_loan_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1 ) ;

l_number_of_coborrowers NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
       SELECT  count(*)
       INTO l_number_of_coborrowers
       FROM LNS_PARTICIPANTS  lp
       WHERE lp.loan_id = l_cr_loan_id
       AND lp.loan_participant_type = 'COBORROWER' ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_number_of_coborrowers := 0;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char(l_number_of_coborrowers) ;

RETURN to_char( NVL(l_number_of_coborrowers,0) );


END number_of_coborrowers ;




/*===========================================================================+
 | FUNCTION     is_having_coborrowers
 |
 |
 | DESCRIPTION    Checks if the current loan has co-borrowers or not
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Y - if loan has co-borrower(s)
 |		 N - if loan has no co-borrower
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/


FUNCTION is_having_coborrowers (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_cr_loan_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1 ) ;

l_is_having_coborrowers VARCHAR2(1) ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
	   SELECT NVL ( (SELECT  'Y'
                FROM DUAL
                WHERE EXISTS  ( SELECT null
                FROM LNS_PARTICIPANTS  lp
                WHERE lp.loan_id = l_cr_loan_id
                AND lp.loan_participant_type = 'COBORROWER'))
                ,'N' ) INTO l_is_having_coborrowers
       FROM DUAL ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_is_having_coborrowers := 'N' ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					l_is_having_coborrowers ;

RETURN  l_is_having_coborrowers ;




END is_having_coborrowers ;



/*===========================================================================+
 | FUNCTION     number_of_guarantors
 |
 |
 | DESCRIPTION    Returns the number of guarantors for current loan
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Number of Guarantors
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION number_of_guarantors (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_cr_loan_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1 ) ;

l_number_of_guarantors NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
	   SELECT  count(*)
       INTO l_number_of_guarantors
       FROM LNS_PARTICIPANTS  lp
       WHERE lp.loan_id = l_cr_loan_id
       AND lp.loan_participant_type = 'GUARANTOR' ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_number_of_guarantors := 0;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char(l_number_of_guarantors) ;

RETURN to_char( NVL(l_number_of_guarantors,0) );


END number_of_guarantors ;



/*===========================================================================+
 | FUNCTION     is_having_guarantors
 |
 |
 | DESCRIPTION    Checks if the loan has any guarantors or not
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Y - if the loan has guarantor(s)
 |		 N - if the loan has no guarantor
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/


FUNCTION is_having_guarantors (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_cr_loan_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1  ) ;

l_is_having_guarantors VARCHAR2(1) ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
	   SELECT NVL ( (SELECT  'Y'
                FROM DUAL
                WHERE EXISTS  ( SELECT null
                FROM LNS_PARTICIPANTS  lp
                WHERE lp.loan_id = l_cr_loan_id
                AND lp.loan_participant_type = 'GUARANTOR'))
                ,'N' ) INTO l_is_having_guarantors
       FROM DUAL ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_is_having_guarantors := 'N' ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					l_is_having_guarantors ;

RETURN  l_is_having_guarantors ;


END is_having_guarantors ;



/*===========================================================================+
 | FUNCTION     required_collateral_amount
 |
 |
 | DESCRIPTION    Collateral amount required for this loan , calculated based
 |		  on loan-to-value ratio.
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Required Collateral Amount
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION required_collateral_amount (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_cr_loan_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1  ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_req_coll_amount NUMBER ;
l_loan_currency lns_loan_headers_all.loan_currency%TYPE ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

     SELECT ( loan.requested_amount * nvl(loan.collateral_percent,0) / 100 ) ,
		loan_currency
     INTO l_req_coll_amount , l_loan_currency
     FROM lns_loan_headers_all loan
     WHERE loan.loan_id = l_cr_loan_id ;


     IF(l_cr_currency<>l_loan_currency) THEN
                l_req_coll_amount := gl_currency_api.convert_amount(l_loan_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_req_coll_amount);
       END IF ;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_req_coll_amount := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char(nvl(l_req_coll_amount,0)) ;

RETURN  to_char( NVL(l_req_coll_amount,0) ) ;


END required_collateral_amount ;



/*===========================================================================+
 | FUNCTION     total_collateral_amount
 |
 |
 | DESCRIPTION    Total collateral amount pledged against this loan.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Total Collateral Amount Pledged
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION total_collateral_amount (x_resultout	OUT NOCOPY VARCHAR2,
               				        x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_cr_loan_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1  ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_total_coll_amount NUMBER  ;
l_loan_currency lns_loan_headers_all.loan_currency%TYPE ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

    SELECT (select nvl(sum(laa.pledged_amount),0)
    from lns_asset_assignments laa
    where laa.loan_id = loan.loan_id
    and (laa.end_date_active is null or trunc(laa.end_date_active) > trunc(sysdate))
    and exists (select 1 from lns_assets la where la.asset_id = laa.asset_id)) , loan.loan_currency
    INTO l_total_coll_amount , l_loan_currency
    FROM lns_loan_headers_all loan
    WHERE loan.loan_id = l_cr_loan_id ;

    IF(l_cr_currency<>l_loan_currency) THEN
                l_total_coll_amount := gl_currency_api.convert_amount(l_loan_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_total_coll_amount);
    END IF ;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_coll_amount := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char(nvl(l_total_coll_amount,0) ) ;

RETURN  to_char( NVL(l_total_coll_amount,0) ) ;


END total_collateral_amount ;



/*===========================================================================+
 | FUNCTION     deliquency_cond_amount
 |
 |
 | DESCRIPTION    Deliquency condition amount for this loan.
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Deliquency Condition Amount
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION deliquency_cond_amount (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_cr_loan_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1  ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;


l_deliquency_amount NUMBER  ;
l_loan_currency  lns_loan_headers_all.loan_currency%TYPE ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
	   SELECT lt.delinquency_threshold_amount , llh.loan_currency
       INTO l_deliquency_amount , l_loan_currency
       FROM lns_terms lt , lns_loan_headers_all llh
       WHERE llh.loan_id = l_cr_loan_id
       AND lt.loan_id = llh.loan_id ;


    IF(l_cr_currency<>l_loan_currency) THEN
                l_deliquency_amount := gl_currency_api.convert_amount(l_loan_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_deliquency_amount);
    END IF ;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_deliquency_amount := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( nvl(l_deliquency_amount,0) ) ;

RETURN  to_char( NVL(l_deliquency_amount,0) ) ;


END deliquency_cond_amount ;




/*===========================================================================+
 | FUNCTION     total_assets_valuation_amt
 |
 |
 | DESCRIPTION    Total assets valuation amount for the loan party.
 |		  If the credit request party is Primary Borrower , sum all the
 |		  the assets of Primary Borrower and all Co-Borrower(s) of the loan.
 |		  Else if the credit request party is Guarantor , sum the assets
 |		  of that party only.
 |
 |                Convert the assets value amount to credit request currency.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION total_assets_valuation_amt (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

CURSOR party_total_assets(C_LOAN_ID NUMBER , C_PARTY_ID NUMBER) IS
SELECT sum(VALUATION), CURRENCY_CODE
FROM LNS_ASSETS
WHERE asset_owner_id IN (
            SELECT HZ_PARTY_ID FROM LNS_PARTICIPANTS
            WHERE LOAN_ID = ( select loan_id from lns_participants
		              where loan_id = C_LOAN_ID and hz_party_id = C_PARTY_ID
				and loan_participant_type = 'PRIMARY_BORROWER' )
            AND ( LOAN_PARTICIPANT_TYPE = 'PRIMARY_BORROWER' OR LOAN_PARTICIPANT_TYPE ='COBORROWER' )

            UNION ALL

            SELECT HZ_PARTY_ID FROM LNS_PARTICIPANTS
            WHERE LOAN_ID = C_LOAN_ID
            AND HZ_PARTY_ID = C_PARTY_ID
            AND LOAN_PARTICIPANT_TYPE = 'GUARANTOR'
            )
and (end_date_active is null
or trunc(end_date_active) > trunc(sysdate))
group by CURRENCY_CODE ;


l_cr_loan_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1  ) ;
l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_asset_amount  NUMBER ;
l_asset_currency lns_assets.currency_code%TYPE ;
l_total_assets_amount NUMBER ;




BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

      l_total_assets_amount := 0 ;
      OPEN party_total_assets(l_cr_loan_id , l_cr_party_id) ;

      LOOP

      FETCH party_total_assets INTO l_asset_amount , l_asset_currency ;
      EXIT WHEN party_total_assets%NOTFOUND ;

      IF(l_cr_currency<>l_asset_currency) THEN
                l_asset_amount := gl_currency_api.convert_amount(l_asset_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_asset_amount);
      END IF ;

      l_total_assets_amount := l_total_assets_amount + l_asset_amount ;

      END LOOP ;



	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_assets_amount := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_assets_amount,0) ) ;

RETURN  to_char( NVL(l_total_assets_amount,0) )  ;


END total_assets_valuation_amt ;



/*===========================================================================+
 | FUNCTION      total_assets_pledged_amt
 |
 |
 | DESCRIPTION    Total un-pledged amount of the assets of the party.
 |		  If the credit request party is loan Primary Borrower , sum
 |		  the unpledged amount of all assets of Primary Borrower and
 |		  Co-Borrower of this loan.
 | 		  Else if the credint request party is a Guarantor , then sum
 |		  the unpledged amout of all assets of Guarantor only.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Total Pledged Amount across all Loans of all assets.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION total_assets_pledged_amt (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

CURSOR party_pledged_assets(C_LOAN_ID NUMBER , C_PARTY_ID NUMBER) IS
SELECT sum(nvl( (select sum (assign.pledged_amount) from lns_asset_assignments assign where LnsAssets.asset_id = assign.asset_id(+) and (assign.end_date_active is null or trunc(assign.end_date_active) > trunc(sysdate)) )
         ,0) ), CURRENCY_CODE
FROM LNS_ASSETS LnsAssets
WHERE asset_owner_id IN (
            SELECT HZ_PARTY_ID FROM LNS_PARTICIPANTS
            WHERE LOAN_ID = ( select loan_id from lns_participants
			      where loan_id = C_LOAN_ID and hz_party_id = C_PARTY_ID
				and loan_participant_type = 'PRIMARY_BORROWER' )
            AND ( LOAN_PARTICIPANT_TYPE = 'PRIMARY_BORROWER' OR LOAN_PARTICIPANT_TYPE ='COBORROWER' )

            UNION ALL

            SELECT HZ_PARTY_ID FROM LNS_PARTICIPANTS
            WHERE LOAN_ID = C_LOAN_ID
            AND HZ_PARTY_ID = C_PARTY_ID
            AND LOAN_PARTICIPANT_TYPE = 'GUARANTOR'
            )
and (end_date_active is null
or trunc(end_date_active) > trunc(sysdate))
group by CURRENCY_CODE ;


l_cr_loan_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1  ) ;
l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_asset_pledged_amt  NUMBER ;
l_asset_currency lns_assets.currency_code%TYPE ;
l_total_assets_pledged_amt NUMBER ;




BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

      l_total_assets_pledged_amt := 0 ;
      OPEN party_pledged_assets(l_cr_loan_id , l_cr_party_id) ;

      LOOP

      FETCH party_pledged_assets INTO l_asset_pledged_amt , l_asset_currency ;
      EXIT WHEN party_pledged_assets%NOTFOUND ;

      IF(l_cr_currency<>l_asset_currency) THEN
                l_asset_pledged_amt := gl_currency_api.convert_amount(l_asset_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_asset_pledged_amt);
      END IF ;

      l_total_assets_pledged_amt := l_total_assets_pledged_amt + l_asset_pledged_amt ;

      END LOOP ;



	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_assets_pledged_amt := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_assets_pledged_amt,0) ) ;

RETURN  to_char( NVL(l_total_assets_pledged_amt,0) )  ;


END total_assets_pledged_amt ;



/*===========================================================================+
 | FUNCTION      total_assets_available_amt
 |
 |
 | DESCRIPTION    Total assets available amount for the party.
 |		  If the credit request party is Loan's Primary Borrower , sum the
 |		  available amount for all assets of Primary Borrower and all Co-Borrower(s)
 |		  of the loan.
 |		  Else if the credit request party is Loan's Guarantor , sum the
 |		  available amount for all assets of the guarantor.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Total Available amount of assets to be pledged.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION total_assets_available_amt (x_resultout	OUT NOCOPY VARCHAR2,
               				    x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

CURSOR party_available_assets(C_LOAN_ID  NUMBER , C_PARTY_ID NUMBER) IS
SELECT sum( nvl(LnsAssets.valuation,0) - nvl( (select sum (assign.pledged_amount) from lns_asset_assignments
assign where LnsAssets.asset_id = assign.asset_id(+) and (assign.end_date_active is null or trunc(assign.end_date_active) > trunc(sysdate)) )
         ,0) ), CURRENCY_CODE
FROM LNS_ASSETS LnsAssets
WHERE asset_owner_id IN (
            SELECT HZ_PARTY_ID FROM LNS_PARTICIPANTS
            WHERE LOAN_ID = ( select loan_id from lns_participants where loan_id = C_LOAN_ID and hz_party_id = C_PARTY_ID and loan_participant_type = 'PRIMARY_BORROWER' )
            AND ( LOAN_PARTICIPANT_TYPE = 'PRIMARY_BORROWER' OR LOAN_PARTICIPANT_TYPE ='COBORROWER' )

            UNION ALL

            SELECT HZ_PARTY_ID FROM LNS_PARTICIPANTS
            WHERE LOAN_ID = C_LOAN_ID
            AND HZ_PARTY_ID = C_PARTY_ID
            AND LOAN_PARTICIPANT_TYPE = 'GUARANTOR'
            )
or trunc(end_date_active) > trunc(sysdate)
group by CURRENCY_CODE ;



l_cr_loan_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1  ) ;
l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_asset_available_amt  NUMBER ;
l_asset_currency lns_assets.currency_code%TYPE ;
l_total_assets_available_amt NUMBER ;




BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

      l_total_assets_available_amt := 0 ;
      OPEN party_available_assets(l_cr_loan_id , l_cr_party_id) ;

      LOOP

      FETCH party_available_assets INTO l_asset_available_amt , l_asset_currency ;
      EXIT WHEN party_available_assets%NOTFOUND ;

      IF(l_cr_currency<>l_asset_currency) THEN
                l_asset_available_amt := gl_currency_api.convert_amount(l_asset_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_asset_available_amt);
      END IF ;

      l_total_assets_available_amt := l_total_assets_available_amt + l_asset_available_amt ;

      END LOOP ;



	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_assets_available_amt := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_assets_available_amt,0) ) ;

RETURN  to_char( NVL(l_total_assets_available_amt,0) )  ;


END total_assets_available_amt ;




/*===========================================================================+
 | FUNCTION     number_active_loans
 |
 |
 | DESCRIPTION    Number of active loans where the credit request party is
 |		  Primary Borrower or Co-Borrower.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Number of Active Loans for this Party.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION number_active_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   			   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS


l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;

l_count_active_loans NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        SELECT count(*)
        INTO l_count_active_loans
        FROM lns_loan_headers_all
        WHERE loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id = l_cr_party_id
                            AND ( loan_participant_type = 'PRIMARY_BORROWER'
                                  OR loan_participant_type = 'COBORROWER')
                          )
        AND loan_status = 'ACTIVE' ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_count_active_loans := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_count_active_loans,0) ) ;

RETURN  to_char( NVL(l_count_active_loans,0) )  ;


END number_active_loans ;




/*===========================================================================+
 | FUNCTION     balance_amt_active_loans
 |
 |
 | DESCRIPTION    Total outstanding balance of all active loans where the
 |		  credit request party is Primary Borrower or Co-Borrower.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Outstanding Balance across all Active Loans.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION balance_amt_active_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   				       x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2  IS

CURSOR active_loans_balance(C_PARTY_ID NUMBER) IS
SELECT sum(lps.total_principal_balance) , llh.loan_currency
FROM lns_loan_headers_all llh ,
LNS_PAY_SUM_V lps
WHERE llh.loan_id = lps.loan_id
AND llh.loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id = c_party_id
                            AND ( loan_participant_type = 'PRIMARY_BORROWER'
                                  OR loan_participant_type = 'COBORROWER')
                          )
AND llh.loan_status = 'ACTIVE'
GROUP BY loan_currency ;


l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_loan_balance_amt  NUMBER ;
l_loan_currency lns_loan_headers_all.loan_currency%TYPE ;
l_total_balance_amt  NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

      l_total_balance_amt := 0 ;
      OPEN active_loans_balance(l_cr_party_id) ;

      LOOP

      FETCH active_loans_balance INTO l_loan_balance_amt , l_loan_currency ;
      EXIT WHEN active_loans_balance%NOTFOUND ;

      IF(l_cr_currency<>l_loan_currency) THEN
                l_loan_balance_amt := gl_currency_api.convert_amount(l_loan_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_loan_balance_amt);
      END IF ;

      l_total_balance_amt := l_total_balance_amt + l_loan_balance_amt ;

      END LOOP ;



	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_balance_amt := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_balance_amt,0) ) ;

RETURN  to_char( NVL(l_total_balance_amt,0) )  ;


END balance_amt_active_loans ;




/*===========================================================================+
 | FUNCTION     number_pending_loans
 |
 |
 | DESCRIPTION    Number of loans pending approval where the credit request party is
 |                Primary Borrower or Co-Borrower.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Number of Loans Pending Approval for this Party.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION number_pending_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   			   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS


l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;

l_count_pending_loans NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        SELECT count(*)
        INTO l_count_pending_loans
        FROM lns_loan_headers_all
        WHERE loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id = l_cr_party_id
                            AND ( loan_participant_type = 'PRIMARY_BORROWER'
                                  OR loan_participant_type = 'COBORROWER')
                          )
        AND loan_status = 'PENDING' ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_count_pending_loans := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_count_pending_loans,0) ) ;

RETURN  to_char( NVL(l_count_pending_loans,0) )  ;


END number_pending_loans ;



/*===========================================================================+
 | FUNCTION     balance_amt_pending_loans
 |
 |
 | DESCRIPTION    Total outstanding balance of all loans pending approval where the
 |                credit request party is Primary Borrower or Co-Borrower.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Outstanding Balance across all Loans Pending Approval.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION balance_amt_pending_loans ( x_resultout	OUT NOCOPY VARCHAR2,
       			       x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS


CURSOR pending_loans_balance(C_PARTY_ID NUMBER) IS
SELECT sum(lps.total_principal_balance) , llh.loan_currency
FROM lns_loan_headers_all llh ,
LNS_PAY_SUM_V  lps
WHERE llh.loan_id = lps.loan_id
AND llh.loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id = c_party_id
                            AND ( loan_participant_type = 'PRIMARY_BORROWER'
                                  OR loan_participant_type = 'COBORROWER')
                          )
AND llh.loan_status = 'PENDING'
GROUP BY loan_currency ;


l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_loan_balance_amt  NUMBER ;
l_loan_currency lns_loan_headers_all.loan_currency%TYPE ;
l_total_balance_amt  NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

      l_total_balance_amt := 0 ;
      OPEN pending_loans_balance(l_cr_party_id) ;

      LOOP

      FETCH pending_loans_balance INTO l_loan_balance_amt , l_loan_currency ;
      EXIT WHEN pending_loans_balance%NOTFOUND ;

      IF(l_cr_currency<>l_loan_currency) THEN
                l_loan_balance_amt := gl_currency_api.convert_amount(l_loan_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_loan_balance_amt);
      END IF ;

      l_total_balance_amt := l_total_balance_amt + l_loan_balance_amt ;

      END LOOP ;



	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_balance_amt := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_balance_amt,0) ) ;

RETURN  to_char( NVL(l_total_balance_amt,0) )  ;

END balance_amt_pending_loans ;




/*===========================================================================+
 | FUNCTION     number_delinquent_loans
 |
 |
 | DESCRIPTION    Number of delinquent loans where the credit request party is
 |                Primary Borrower or Co-Borrower.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Number of Delinquent Loans for this Party.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION number_delinquent_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   			   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS


l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;

l_count_delinquent_loans NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        SELECT count(*)
        INTO l_count_delinquent_loans
        FROM lns_loan_headers_all
        WHERE loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id = l_cr_party_id
                            AND ( loan_participant_type = 'PRIMARY_BORROWER'
                                  OR loan_participant_type = 'COBORROWER')
                          )
        AND loan_status = 'DELINQUENT' ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_count_delinquent_loans := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_count_delinquent_loans,0) ) ;

RETURN  to_char( NVL(l_count_delinquent_loans,0) )  ;


END number_delinquent_loans ;




/*===========================================================================+
 | FUNCTION     balance_amt_delinquent_loans
 |
 |
 | DESCRIPTION    Total outstanding balance of all delinquent loans where the
 |                credit request party is Primary Borrower or Co-Borrower.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Outstanding Balance across all Delinquent Loans.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/
FUNCTION balance_amt_delinquent_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   				       x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS


CURSOR delinquent_loans_balance(C_PARTY_ID NUMBER) IS
SELECT sum(lps.total_principal_balance) , llh.loan_currency
FROM lns_loan_headers_all llh ,
LNS_PAY_SUM_V  lps
WHERE llh.loan_id = lps.loan_id
AND llh.loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id = c_party_id
                            AND ( loan_participant_type = 'PRIMARY_BORROWER'
                                  OR loan_participant_type = 'COBORROWER')
                          )
AND llh.loan_status = 'DELINQUENT'
GROUP BY loan_currency ;


l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_loan_balance_amt  NUMBER ;
l_loan_currency lns_loan_headers_all.loan_currency%TYPE ;
l_total_balance_amt  NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

      l_total_balance_amt := 0 ;
      OPEN delinquent_loans_balance(l_cr_party_id) ;

      LOOP

      FETCH delinquent_loans_balance INTO l_loan_balance_amt , l_loan_currency ;
      EXIT WHEN delinquent_loans_balance%NOTFOUND ;

      IF(l_cr_currency<>l_loan_currency) THEN
                l_loan_balance_amt := gl_currency_api.convert_amount(l_loan_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_loan_balance_amt);
      END IF ;

      l_total_balance_amt := l_total_balance_amt + l_loan_balance_amt ;

      END LOOP ;



	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_balance_amt := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_balance_amt,0) ) ;

RETURN  to_char( NVL(l_total_balance_amt,0) )  ;


END balance_amt_delinquent_loans ;




/*===========================================================================+
 | FUNCTION     number_default_loans
 |
 |
 | DESCRIPTION    Number of defaulted loans where the credit request party is
 |                Primary Borrower or Co-Borrower.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Number of Defaulted Loans for this Party.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION number_default_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   			   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS


l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;

l_count_default_loans NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        SELECT count(*)
        INTO l_count_default_loans
        FROM lns_loan_headers_all
        WHERE loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id = l_cr_party_id
                            AND ( loan_participant_type = 'PRIMARY_BORROWER'
                                  OR loan_participant_type = 'COBORROWER')
                          )
        AND loan_status = 'DEFAULT' ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_count_default_loans := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_count_default_loans,0) ) ;

RETURN  to_char( NVL(l_count_default_loans,0) )  ;

END number_default_loans ;



/*===========================================================================+
 | FUNCTION     balance_amt_default_loans
 |
 |
 | DESCRIPTION    Total outstanding balance of all defaulted loans where the
 |                credit request party is Primary Borrower or Co-Borrower.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Outstanding Balance across all Defaulted Loans.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION balance_amt_default_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   				       x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2  IS


CURSOR default_loans_balance(C_PARTY_ID NUMBER) IS
SELECT sum(lps.total_principal_balance) , llh.loan_currency
FROM lns_loan_headers_all llh ,
LNS_PAY_SUM_V lps
WHERE llh.loan_id = lps.loan_id
AND llh.loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id = c_party_id
                            AND ( loan_participant_type = 'PRIMARY_BORROWER'
                                  OR loan_participant_type = 'COBORROWER')
                          )
AND llh.loan_status = 'DEFAULT'
GROUP BY loan_currency ;


l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_loan_balance_amt  NUMBER ;
l_loan_currency lns_loan_headers_all.loan_currency%TYPE ;
l_total_balance_amt  NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

      l_total_balance_amt := 0 ;
      OPEN default_loans_balance(l_cr_party_id) ;

      LOOP

      FETCH default_loans_balance INTO l_loan_balance_amt , l_loan_currency ;
      EXIT WHEN default_loans_balance%NOTFOUND ;

      IF(l_cr_currency<>l_loan_currency) THEN
                l_loan_balance_amt := gl_currency_api.convert_amount(l_loan_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_loan_balance_amt);
      END IF ;

      l_total_balance_amt := l_total_balance_amt + l_loan_balance_amt ;

      END LOOP ;



	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_balance_amt := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_balance_amt,0) ) ;

RETURN  to_char( NVL(l_total_balance_amt,0) )  ;

END balance_amt_default_loans ;




/*===========================================================================+
 | FUNCTION     number_paidoff_loans
 |
 |
 | DESCRIPTION    Number of Paid-Off loans where the credit request party is
 |                Primary Borrower or Co-Borrower.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Number of Paid-Off Loans for this Party.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION number_paidoff_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   			   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS


l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;

l_count_paidoff_loans NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        SELECT count(*)
        INTO l_count_paidoff_loans
        FROM lns_loan_headers_all
        WHERE loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id = l_cr_party_id
                            AND ( loan_participant_type = 'PRIMARY_BORROWER'
                                  OR loan_participant_type = 'COBORROWER')
                          )
        AND loan_status = 'PAIDOFF' ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_count_paidoff_loans := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_count_paidoff_loans,0) ) ;

RETURN  to_char( NVL(l_count_paidoff_loans,0) )  ;


END number_paidoff_loans ;



/*===========================================================================+
 | FUNCTION     balance_amt_paidoff_loans
 |
 |
 | DESCRIPTION    Total outstanding balance of all paid-off loans where the
 |                credit request party is Primary Borrower or Co-Borrower.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Outstanding Balance across all Paid-Off Loans.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/
FUNCTION balance_amt_paidoff_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   				       x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS


CURSOR paidoff_loans_balance(C_PARTY_ID NUMBER) IS
SELECT sum(lps.total_principal_balance) , llh.loan_currency
FROM lns_loan_headers_all llh ,
LNS_PAY_SUM_V lps
WHERE llh.loan_id = lps.loan_id
AND llh.loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id = c_party_id
                            AND ( loan_participant_type = 'PRIMARY_BORROWER'
                                  OR loan_participant_type = 'COBORROWER')
                          )
AND llh.loan_status = 'PAIDOFF'
GROUP BY loan_currency ;


l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_loan_balance_amt  NUMBER ;
l_loan_currency lns_loan_headers_all.loan_currency%TYPE ;
l_total_balance_amt  NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

      l_total_balance_amt := 0 ;
      OPEN paidoff_loans_balance(l_cr_party_id) ;

      LOOP

      FETCH paidoff_loans_balance INTO l_loan_balance_amt , l_loan_currency ;
      EXIT WHEN paidoff_loans_balance%NOTFOUND ;

      IF(l_cr_currency<>l_loan_currency) THEN
                l_loan_balance_amt := gl_currency_api.convert_amount(l_loan_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_loan_balance_amt);
      END IF ;

      l_total_balance_amt := l_total_balance_amt + l_loan_balance_amt ;

      END LOOP ;



	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_balance_amt := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_balance_amt,0) ) ;

RETURN  to_char( NVL(l_total_balance_amt,0) )  ;


END balance_amt_paidoff_loans ;




/*===========================================================================+
 | FUNCTION      total_active_loans
 |
 |
 | DESCRIPTION   Total active loans where credit request party is a Primary Borrower
 |		 or a Co-Borrower.
 |		 If the party is current loan's primary borrower , count all loans of
 |		 primary borrower and all co-borrower(s).
 |		 Else if the party is current loan's guarantor , count all loans of the
 |		 guarantor.
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Total Number of Active Loans for all Party on this Loan Application.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION total_active_loans ( x_resultout	OUT NOCOPY VARCHAR2,
                   				       x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_loan_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1  ) ;

l_total_active_loans NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        SELECT count(*)
        INTO l_total_active_loans
        FROM lns_loan_headers_all
        WHERE loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id IN ( SELECT hz_party_id
                                                   FROM lns_participants
                                                   WHERE loan_id = l_cr_loan_id
                                                   AND (loan_participant_type = 'PRIMARY_BORROWER' or loan_participant_type = 'COBORROWER' )
                                                   AND EXISTS ( select null from lns_participants
                                                                where loan_id = l_cr_loan_id
                                                                and hz_party_id = l_cr_party_id
                                                                and loan_participant_type = 'PRIMARY_BORROWER' )

                                                   UNION ALL

                                                   SELECT hz_party_id
                                                   FROM lns_participants
                                                   WHERE loan_id = l_cr_loan_id
                                                   AND hz_party_id = l_cr_party_id
                                                   AND loan_participant_type = 'GUARANTOR'
                                                  )
                                AND ( loan_participant_type = 'PRIMARY_BORROWER'  OR loan_participant_type = 'COBORROWER' )
                            )
                AND loan_status = 'ACTIVE' ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_active_loans := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_active_loans,0) ) ;

RETURN  to_char( NVL(l_total_active_loans,0) )  ;


End total_active_loans ;




/*===========================================================================+
 | FUNCTION      total_bal_amt_active_loans
 |
 |
 | DESCRIPTION   Total outstanding balance accross all active loans where the
 |		 credit request party is a Primary Borrower or Co-Borrower.
 |               If the party is current loan's primary borrower , sum for all loans of
 |               primary borrower and all co-borrower(s).
 |               Else if the party is current loan's guarantor , sum for all loans of the
 |               guarantor.
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Total Outstanding Balance accross all Active Loans for all Party on this Loan Application.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION total_bal_amt_active_loans (  x_resultout	OUT NOCOPY VARCHAR2,
                   			   x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS


CURSOR total_active_loans_balance(C_LOAN_ID NUMBER , C_PARTY_ID NUMBER) IS
SELECT sum( nvl(lps.total_principal_balance,0) ) , llh.loan_currency
FROM lns_loan_headers_all llh ,
LNS_PAY_SUM_V lps
WHERE llh.loan_id = lps.loan_id
AND llh.loan_id IN (  SELECT loan_id
                    FROM lns_participants
                    WHERE hz_party_id IN ( SELECT hz_party_id
                                           FROM lns_participants
                                           WHERE loan_id = c_loan_id
                                           AND (loan_participant_type = 'PRIMARY_BORROWER' or loan_participant_type = 'COBORROWER' )
                                           AND EXISTS ( select null from lns_participants where loan_id = c_loan_id and 							hz_party_id = c_party_id and loan_participant_type = 'PRIMARY_BORROWER' )

                                           UNION ALL

                                           SELECT hz_party_id
                                           FROM lns_participants
                                           WHERE loan_id = c_loan_id
                                           AND hz_party_id = c_party_id
                                           AND loan_participant_type = 'GUARANTOR'
					)

                    AND ( loan_participant_type = 'PRIMARY_BORROWER'  OR loan_participant_type = 'COBORROWER' )
                    )
AND llh.loan_status = 'ACTIVE'
GROUP BY loan_currency ;


l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_loan_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1 ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_loan_balance_amt  NUMBER ;
l_loan_currency lns_loan_headers_all.loan_currency%TYPE ;
l_total_balance_amt  NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

      l_total_balance_amt := 0 ;
      OPEN total_active_loans_balance(l_cr_loan_id ,l_cr_party_id) ;

      LOOP

      FETCH total_active_loans_balance INTO l_loan_balance_amt , l_loan_currency ;
      EXIT WHEN total_active_loans_balance%NOTFOUND ;

      IF(l_cr_currency<>l_loan_currency) THEN
                l_loan_balance_amt := gl_currency_api.convert_amount(l_loan_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_loan_balance_amt);
      END IF ;

      l_total_balance_amt := l_total_balance_amt + l_loan_balance_amt ;

      END LOOP ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_balance_amt := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_balance_amt,0) ) ;

RETURN  to_char( NVL(l_total_balance_amt,0) )  ;



END total_bal_amt_active_loans ;


/*===========================================================================+
 | FUNCTION      total_deliquent_loans
 |
 |
 | DESCRIPTION   Total deliquent loans where credit request party is a Primary Borrower
 |               or a Co-Borrower.
 |               If the party is current loan's primary borrower , count all loans of
 |               primary borrower and all co-borrower(s).
 |               Else if the party is current loan's guarantor , count all loans of the
 |               guarantor.
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Total Number of Deliquent Loans for all Party on this Loan Application.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION total_deliquent_loans  ( x_resultout	OUT NOCOPY VARCHAR2,
                   			      x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_loan_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1  ) ;

l_total_deliquent_loans NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        SELECT count(*)
        INTO l_total_deliquent_loans
        FROM lns_loan_headers_all
        WHERE loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id IN ( SELECT hz_party_id
                                                   FROM lns_participants
                                                   WHERE loan_id = l_cr_loan_id
                                                   AND (loan_participant_type = 'PRIMARY_BORROWER' or loan_participant_type = 'COBORROWER' )
                                                   AND EXISTS ( select null from lns_participants
                                                                where loan_id = l_cr_loan_id
                                                                and hz_party_id = l_cr_party_id
                                                                and loan_participant_type = 'PRIMARY_BORROWER' )

                                                   UNION ALL

                                                   SELECT hz_party_id
                                                   FROM lns_participants
                                                   WHERE loan_id = l_cr_loan_id
                                                   AND hz_party_id = l_cr_party_id
                                                   AND loan_participant_type = 'GUARANTOR'
                                                  )
                                AND ( loan_participant_type = 'PRIMARY_BORROWER'  OR loan_participant_type = 'COBORROWER' )
                            )
                AND loan_status = 'DELINQUENT' ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_deliquent_loans := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_deliquent_loans,0) ) ;

RETURN  to_char( NVL(l_total_deliquent_loans,0) )  ;

END total_deliquent_loans ;




/*===========================================================================+
 | FUNCTION      total_overdue_amt_active_loans
 |
 |
 | DESCRIPTION   Total overdue amount accross all active loans where the
 |               credit request party is a Primary Borrower or Co-Borrower.
 |               If the party is current loan's primary borrower , sum for all loans of
 |               primary borrower and all co-borrower(s).
 |               Else if the party is current loan's guarantor , sum for all loans of the
 |               guarantor.
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Total Overdue Amount accross all Active Loans for all Party on this Loan Application.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION total_overdue_amt_active_loans (  x_resultout	OUT NOCOPY VARCHAR2,
                   			      x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

CURSOR total_active_loans_overdue(C_LOAN_ID NUMBER , C_PARTY_ID NUMBER) IS
SELECT sum( nvl(lps.total_overdue ,0) ) , llh.loan_currency
FROM lns_loan_headers_all llh ,
LNS_PAY_SUM_OVERDUE_V  lps
WHERE llh.loan_id = lps.loan_id
AND llh.loan_id IN (  SELECT loan_id
                    FROM lns_participants
                    WHERE hz_party_id IN ( SELECT hz_party_id
                                           FROM lns_participants
                                           WHERE loan_id = c_loan_id
                                           AND (loan_participant_type = 'PRIMARY_BORROWER' or loan_participant_type = 'COBORROWER' )
                                           AND EXISTS ( select null from lns_participants where loan_id = c_loan_id and 							hz_party_id = c_party_id and loan_participant_type = 'PRIMARY_BORROWER' )

                                           UNION ALL

                                           SELECT hz_party_id
                                           FROM lns_participants
                                           WHERE loan_id = c_loan_id
                                           AND hz_party_id = c_party_id
                                           AND loan_participant_type = 'GUARANTOR'
					)

                    AND ( loan_participant_type = 'PRIMARY_BORROWER'  OR loan_participant_type = 'COBORROWER' )
                    )
AND llh.loan_status = 'ACTIVE'
GROUP BY loan_currency ;


l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_loan_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1 ) ;
l_cr_currency VARCHAR2(30) := OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_TRX_CURRENCY ;

l_loan_overdue_amt  NUMBER ;
l_loan_currency lns_loan_headers_all.loan_currency%TYPE ;
l_total_overdue_amt  NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

      l_total_overdue_amt := 0 ;
      OPEN total_active_loans_overdue(l_cr_loan_id ,l_cr_party_id) ;

      LOOP

      FETCH total_active_loans_overdue INTO l_loan_overdue_amt , l_loan_currency ;
      EXIT WHEN total_active_loans_overdue%NOTFOUND ;

      IF(l_cr_currency<>l_loan_currency) THEN
                l_loan_overdue_amt := gl_currency_api.convert_amount(l_loan_currency ,l_cr_currency , sysdate, g_exchange_rate_type , l_loan_overdue_amt);
      END IF ;

      l_total_overdue_amt := l_total_overdue_amt + l_loan_overdue_amt ;

      END LOOP ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_overdue_amt := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_overdue_amt,0) ) ;

RETURN  to_char( NVL(l_total_overdue_amt,0) )  ;


END total_overdue_amt_active_loans ;




/*===========================================================================+
 | FUNCTION      total_defaulted_loans
 |
 |
 | DESCRIPTION   Total defaulted loans where credit request party is a Primary Borrower
 |               or a Co-Borrower.
 |               If the party is current loan's primary borrower , count all loans of
 |               primary borrower and all co-borrower(s).
 |               Else if the party is current loan's guarantor , count all loans of the
 |               guarantor.
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_resultout
 |                    x_errormsg
 |              IN/OUT:
 |
 | RETURNS    :  Total Number of Defaulted Loans for all Party on this Loan Application.
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   01-SEP-2005     Hitesh Kumar       Created.
 +===========================================================================*/

FUNCTION total_defaulted_loans (  x_resultout	OUT NOCOPY VARCHAR2,
                      			  x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_cr_party_id    NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_party_id ) ;
l_cr_loan_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_source_column1  ) ;

l_total_default_loans NUMBER ;


BEGIN

x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        SELECT count(*)
        INTO l_total_default_loans
        FROM lns_loan_headers_all
        WHERE loan_id IN (  SELECT loan_id
                            FROM lns_participants
                            WHERE hz_party_id IN ( SELECT hz_party_id
                                                   FROM lns_participants
                                                   WHERE loan_id = l_cr_loan_id
                                                   AND (loan_participant_type = 'PRIMARY_BORROWER' or loan_participant_type = 'COBORROWER' )
                                                   AND EXISTS ( select null from lns_participants
                                                                where loan_id = l_cr_loan_id
                                                                and hz_party_id = l_cr_party_id
                                                                and loan_participant_type = 'PRIMARY_BORROWER' )

                                                   UNION ALL

                                                   SELECT hz_party_id
                                                   FROM lns_participants
                                                   WHERE loan_id = l_cr_loan_id
                                                   AND hz_party_id = l_cr_party_id
                                                   AND loan_participant_type = 'GUARANTOR'
                                                  )
                                AND ( loan_participant_type = 'PRIMARY_BORROWER'  OR loan_participant_type = 'COBORROWER' )
                            )
                AND loan_status = 'DEFAULT' ;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_total_default_loans := 0 ;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;


	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.P_data_point_value :=
					to_char( NVL(l_total_default_loans,0) ) ;

RETURN  to_char( NVL(l_total_default_loans,0) )  ;


END total_defaulted_loans ;

-- Bug#8564946 - Get exchangeRateType from CreditMgmt and use to convert amt in different currencies
BEGIN

     SELECT
     		default_exchange_rate_type into g_exchange_rate_type
      FROM
      		AR_CMGT_SETUP_OPTIONS;


END LNS_OCM_ADP_PUB ;


/
