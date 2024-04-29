--------------------------------------------------------
--  DDL for Package Body OZF_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_DRT_PKG" AS
/* $Header: ozfvdrtb.pls 120.0.12010000.3 2018/05/15 08:22:43 snsarava noship $ */

  l_package varchar2(33) DEFAULT 'OZF_DRT_PKG. ';

  --
  --- Implement Core HR specific DRC for HR entity type
  --
  PROCEDURE ozf_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'ozf_tca_drc';
    p_person_id number(20);
    l_count number;
    l_earning number;
    l_temp varchar2(20);
  BEGIN
    -- .....
    per_drt_pkg.write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    per_drt_pkg.write_log ('p_person_id: '|| p_person_id,'20');
    --
	---- Check DRC rule# 1
	--
    BEGIN
	        --
		--- Check whether Person Customer has open accruals
		--
		l_earning := null;

		SELECT SUM(amount_remaining) INTO l_earning
		FROM ozf_funds_utilized_all_b ofub, hz_cust_accounts hza
		WHERE ofub.cust_account_id = hza.cust_account_id
		and hza.party_id = p_person_id;
		--
		--- If amount_remaining > 0 then should not delete the person, raise a warning.
		--- Warning Msg : This person is a customer with open offer accruals. Investigate disposition of accruals.
		--
		if NVL(l_earning, 0) > 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'TCA'
			  ,status => 'W'
			  ,msgcode => 'OZF_ACCRUAL_PENDING_CUSTOMER'
			  ,msgaplid => 682
			  ,result_tbl => result_tbl);
		end if;
    END;
    --
	--- Check DRC rule# 2
	--
    BEGIN
		--
		--- Check whether Person Supplier has open accruals
		--
		l_earning := null;

		SELECT SUM(amount_remaining) INTO l_earning
		FROM ozf_funds_utilized_all_b ofub,
		hz_cust_accounts hza, hz_party_usg_assignments HPUA
		WHERE ofub.cust_account_id   = hza.cust_account_id
		and hza.party_id = hpua.party_id
		AND hpua.party_usage_code  = 'SUPPLIER'
		and hza.party_id = p_person_id ;

		--
		--- If amount_remaining > 0 then should not delete the person, raise a warning.
		--- Warning Msg : This person is a supplier with open offer accruals. Investigate disposition of accruals.
		--
		if NVL(l_earning, 0) > 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'TCA'
			  ,status => 'W'
			  ,msgcode => 'OZF_ACCRUAL_PENDING_SUPPLIER'
			  ,msgaplid => 682
			  ,result_tbl => result_tbl);
		end if;
    END;

    --
	--- Check DRC rule# 3
	--
    BEGIN
		--
		--- Check whether Person Supplier has open accruals
		--
		l_count := null;

		SELECT COUNT(*) INTO l_count
		FROM ozf_claims_all oca,
		  hz_cust_accounts hza,
		  hz_parties hzp
		WHERE oca.cust_account_id = hza.cust_account_id
		AND hza.party_id          = hzp.party_id
		AND hzp.party_id          = p_person_id
		AND oca.status_code    IN ('NEW','OPEN','PENDING_CLOSE','PENDING_APPROVAL')
        AND rownum = 1;

		--
		--- If number of OPEN claims for this person account is > 0 then should not delete the person, raise a warning.
		--- Warning Msg : This person is a customer with open claims. Close the claims.
		--
		if NVL(l_count, 0) > 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'TCA'
			  ,status => 'W'
			  ,msgcode => 'OZF_OPEN_CLAIM_PERSON'
			  ,msgaplid => 682
			  ,result_tbl => result_tbl);
		end if;
    END;

    per_drt_pkg.write_log ('Leaving:'|| l_proc,'999');
    -- .....
  END ozf_tca_drc;


PROCEDURE ozf_fnd_drc
	(person_id       IN         number
	,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

  l_proc varchar2(72) := l_package|| 'ozf_fnd_drc';
  p_person_id number(20);

  l_default_ship_debit Number := NVL(fnd_profile.value('OZF_SD_DEFAULT_APPROVER'),0);
  l_default_soft_fund Number := NVL(fnd_profile.value('OZF_SF_DEFAULT_APPROVER'),0);
  l_default_Special_pricing  Number := NVL(fnd_profile.value('OZF_SP_DEFAULT_APPROVER'),0);
  l_user_id number;

  BEGIN

    per_drt_pkg.write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    per_drt_pkg.write_log ('p_person_id: '|| p_person_id,'20');

  --For  OZF: Default Ship & Debit Request Approver--

    l_user_id :=  p_person_id;

    If l_default_ship_debit = l_user_id then

	    per_drt_pkg.add_to_results
		  (person_id => p_person_id
	      ,entity_type => 'FND'
	      ,status => 'E'
	      ,msgcode => 'OZF_SDR_APPROVER_DRT'
	      ,msgaplid => 682
	      ,result_tbl => result_tbl);
    end if;

     -- For OZF: Default Soft Fund Request Approver

    If l_default_soft_fund = l_user_id then

        per_drt_pkg.add_to_results
	     (person_id => p_person_id
	     ,entity_type => 'FND'
	     ,status => 'E'
	     ,msgcode => 'OZF_SFR_APPROVER_DRT'
	     ,msgaplid => 682
	     ,result_tbl => result_tbl);
    end if;

    --For OZF: Default Special Pricing Request Approver

    If l_default_Special_pricing = l_user_id then

       per_drt_pkg.add_to_results
	    (person_id => p_person_id
	    ,entity_type => 'FND'
	    ,status => 'E'
	    ,msgcode => 'OZF_SPR_APPROVER_DRT'
	    ,msgaplid => 682
	    ,result_tbl => result_tbl);
    end if;

    per_drt_pkg.write_log ('Leaving:'|| l_proc,'999');

  END ozf_fnd_drc;

END OZF_DRT_PKG;

/
