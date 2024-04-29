--------------------------------------------------------
--  DDL for Package Body PN_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_DRT_PKG" AS
/* $Header: PNDRTPB.pls 120.0.12010000.7 2019/10/10 12:55:22 kriraghu noship $ */

g_package  varchar2(33) := 'PN_DRT_DRC.';
P_PN_DEBUG_MODE  VARCHAR2(1) := NVL(FND_PROFILE.value('PN_DEBUG_MODE'),'N');

  PROCEDURE pn_hr_drc
    (p_person_id     IN number
	,result_tbl OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE)
   IS

  l_proc					varchar2(72);
  l_dummy                   varchar2(20);
  l_person_id				number(15);
  --result_tbl    			PER_DRT_PKG.RESULT_TBL_TYPE;
  n                         number;
  l_person_name             varchar2(240);


  BEGIN

	IF P_PN_DEBUG_MODE = 'Y' THEN
	  pnp_debug_pkg.debug(g_package || 'pn_hr_drc 10 - Entering pn_hr_drc');
	  pnp_debug_pkg.debug(g_package || 'pn_hr_drc p_person_id :: ' || p_person_id);
    END IF;

	-- Ref of Person Id in Space Assignment Check.
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pn_space_assign_emp_all ppp
               WHERE ppp.person_id = p_person_id
			     AND (TRUNC(sysdate) BETWEEN ppp.emp_assign_start_date
                                        AND NVL(ppp.emp_assign_end_date, sysdate)
										OR
					  TRUNC(sysdate) <	ppp.emp_assign_start_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'W'
 			  ,msgcode => 'PN_DRT_SPACE_ASSIGN_WARN'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: PN_DRT_SPACE_ASSIGN_WARN');
            END IF;

    END;

    -- Ref of User name in User Responsible By in Lease
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pn_leases_all pl, pn_lease_details_all pld, fnd_user fu -- modified by kriraghu for bug 30358489
               WHERE fu.employee_id = p_person_id
                 AND fu.user_id = pld.responsible_user
                 AND pld.lease_id = pl.lease_id
                 AND pl.lease_status <> 'TER'
			     AND (TRUNC(sysdate) BETWEEN pld.lease_commencement_date
                                        AND NVL(pld.lease_termination_date, sysdate)
										OR
					  TRUNC(sysdate) < 	pld.lease_commencement_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'W'
 			  ,msgcode => 'PN_DRT_USER_RESP_LS_WARN'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: PN_DRT_USER_RESP_LS_WARN');
            END IF;

    END;

  -- Start Added by kriraghu for bug  30358489
  -- Ref of User name in User Responsible By in Equipment Lease
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pn_eqp_leases_all pl, pn_eqp_lease_details_all pld, fnd_user fu
               WHERE fu.employee_id = p_person_id
                 AND fu.user_id = pld.responsible_user
                 AND pld.lease_id = pl.lease_id
                 AND pl.lease_status <> 'TER'
			     AND (TRUNC(sysdate) BETWEEN pld.lease_commencement_date
                                        AND NVL(pld.lease_termination_date, sysdate)
										OR
					  TRUNC(sysdate) < 	pld.lease_commencement_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'W'
 			  ,msgcode => 'PN_EQP_DRT_USER_RESP_LS_WARN'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: EQP_DRT_USER_RESP_LS_WARN');
            END IF;

    END;

  -- End by kriraghu for bug 30358489
   /* -- Ref of User name in Abstracted By in Lease
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pn_leases_all pl, pn_lease_details_all pld, fnd_user fu
               WHERE fu.employee_id = p_person_id
                 AND fu.user_id = pl.abstracted_by_user
                 AND pld.lease_id = pl.lease_id
                 AND pl.lease_status <> 'TER'
			     AND (TRUNC(sysdate) BETWEEN pld.lease_commencement_date
                                        AND NVL(pld.lease_termination_date, sysdate)
										OR
					  TRUNC(sysdate) < 	pld.lease_commencement_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PN_DRT_USER_ABST_LS_ERR'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: PN_DRT_USER_ABST_LS_ERR');
            END IF;

    END;*/

	-- Ref of User name in User Responsible in Rent Increase
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pn_leases_all pl, fnd_user fu, pn_index_leases_all pil  -- modified by kriraghu for bug 30358489
               WHERE fu.employee_id = p_person_id
                 AND fu.user_id = pil.abstracted_by
                 AND pil.lease_id = pl.lease_id
                 AND pl.lease_status <> 'TER'
			     AND (TRUNC(sysdate) BETWEEN pil.commencement_date
                                        AND NVL(pil.termination_date, sysdate)
										OR
					  TRUNC(sysdate) < 	pil.commencement_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'W'
 			  ,msgcode => 'PN_DRT_USER_ABST_IR_WARN'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: PN_DRT_USER_ABST_IR_WARN');
            END IF;

    END;

	/*
	-- Ref of User name in Abstracted by in Var Rent
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pn_leases_all pl, fnd_user fu, pn_var_rents_all pvr
               WHERE fu.employee_id = p_person_id
                 AND fu.user_id = pvr.abstracted_by_user
                 AND pvr.lease_id = pl.lease_id
                 AND pl.lease_status <> 'TER'
			     AND (TRUNC(sysdate) BETWEEN pvr.commencement_date
                                        AND NVL(pvr.termination_date, sysdate)
										OR
					  TRUNC(sysdate) < 	pvr.commencement_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'W'
 			  ,msgcode => 'PN_DRT_USER_RESP_VAR_WARN'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: PN_DRT_USER_RESP_VAR_WARN');
            END IF;

    END;
	*/

	-- Ref of User name in Lease Milestones
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pn_leases_all pl, pn_lease_details_all pld, fnd_user fu, pn_lease_milestones_all plm /* modified by kriraghu for bug 30358489*/
               WHERE fu.employee_id = p_person_id
                 AND fu.user_id = plm.user_id
				 AND plm.lease_id = pl.lease_id
                 AND pld.lease_id = pl.lease_id
                 AND pl.lease_status <> 'TER'
				 AND plm.milestone_date > TRUNC(sysdate)
			     AND (TRUNC(sysdate) BETWEEN pld.lease_commencement_date
                                        AND NVL(pld.lease_termination_date, sysdate)
										OR
					  TRUNC(sysdate) < 	pld.lease_commencement_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'W'
 			  ,msgcode => 'PN_DRT_USER_RESP_MILE_WARN'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: PN_DRT_USER_RESP_MILE_WARN');
            END IF;

    END;

	IF P_PN_DEBUG_MODE = 'Y' THEN
	   pnp_debug_pkg.debug(g_package || 'pn_hr_drc Leaving');
	END IF;

  END pn_hr_drc;


   PROCEDURE pn_tca_drc
    (p_person_id     IN number
	,result_tbl OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE)
   IS

  l_proc					varchar2(72);
  l_dummy                   varchar2(20);
  l_person_id				number(15);
  --result_tbl     			PER_DRT_PKG.RESULT_TBL_TYPE;
  n                         number;
  l_person_name             varchar2(240);


  BEGIN

	IF P_PN_DEBUG_MODE = 'Y' THEN
	  pnp_debug_pkg.debug(g_package || 'pn_tca_drc 20 - Entering pn_tca_drc');
	  pnp_debug_pkg.debug(g_package || 'pn_tca_drc Customer/Vendor Id :: ' || p_person_id);
	END IF;

    /*
	-- Ref of Customer in Location
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
				SELECT NULL
				   FROM hz_cust_accounts hca ,
						pn_tenancies_all pta,
						pn_leases_all pl,
						pn_lease_details_all pld
				  WHERE hca.party_id = p_person_id
				    AND hca.cust_account_id = pta.customer_id
					AND pta.lease_id = pl.lease_id
					AND pld.lease_id = pl.lease_id
					AND pl.lease_status <> 'TER'
					AND (TRUNC(sysdate) BETWEEN pld.lease_commencement_date
											 AND NVL(pld.lease_termination_date, sysdate)
											OR
						  TRUNC(sysdate) < 	pld.lease_commencement_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PN_DRT_CUST_LOC_ERR'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: PN_DRT_CUST_LOC_ERR');
            END IF;

    END;
	*/
	-- Ref of Customer in Lease Header
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
				SELECT NULL
				   FROM hz_cust_accounts hca ,
						pn_leases_all pl,
						pn_lease_details_all pld              -- modified by kriraghu for bug 30358489
				  WHERE hca.party_id = p_person_id
				    AND hca.cust_account_id = pl.customer_id
					AND pld.lease_id = pl.lease_id
					AND pl.lease_status <> 'TER'
					AND (TRUNC(sysdate) BETWEEN pld.lease_commencement_date
											 AND NVL(pld.lease_termination_date, sysdate)
											OR
						  TRUNC(sysdate) < 	pld.lease_commencement_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PN_DRT_CUST_LS_ERR'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: PN_DRT_CUST_LS_ERR');
            END IF;

    END;


    -- Ref of Supplier in Lease
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
				SELECT NULL
				   FROM po_vendors  pv ,
						pn_leases_all pl,
						pn_lease_details_all pld   -- modified by kriraghu for bug 30358489
				  WHERE pv.party_id = p_person_id
				    AND pv.vendor_id = pl.vendor_id
					AND pld.lease_id = pl.lease_id
					AND pl.lease_status <> 'TER'
					AND (TRUNC(sysdate) BETWEEN pld.lease_commencement_date
											 AND NVL(pld.lease_termination_date, sysdate)
											OR
						  TRUNC(sysdate) < 	pld.lease_commencement_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PN_DRT_SUPP_LS_ERR'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: PN_DRT_SUPP_LS_ERR');
            END IF;

    END;

	-- Start Added by kriraghu for bug  30358489
	-- Ref of Supplier in Equipment Lease
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
				SELECT NULL
				   FROM po_vendors  pv ,
						pn_eqp_leases_all pl,
						pn_eqp_lease_details_all pld
				  WHERE pv.party_id = p_person_id
				    AND pv.vendor_id = pl.vendor_id
					AND pld.lease_id = pl.lease_id
					AND pl.lease_status <> 'TER'
					AND (TRUNC(sysdate) BETWEEN pld.lease_commencement_date
											 AND NVL(pld.lease_termination_date, sysdate)
											OR
						  TRUNC(sysdate) < 	pld.lease_commencement_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PN_EQP_DRT_SUPP_LS_ERR'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: EQP_DRT_SUPP_LS_ERR');
            END IF;

    END;
	-- End by kriraghu for bug  30358489

    -- Ref of Supplier in Term
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
				SELECT NULL
				   FROM po_vendors  pv ,
						pn_leases_all pl,
						pn_payment_terms_all ppt       -- Modified by kriraghu for bug  30358489
				  WHERE pv.party_id = p_person_id
				    AND pv.vendor_id = ppt.vendor_id
                    AND ppt.lease_id = pl.lease_id
					AND pl.lease_status <> 'TER'
					AND (TRUNC(sysdate) BETWEEN ppt.start_date
											 AND NVL(ppt.end_date, sysdate)
											OR
						  TRUNC(sysdate) < 	ppt.start_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PN_DRT_SUPP_TERM_ERR'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: PN_DRT_SUPP_TERM_ERR');
            END IF;

    END;

-- Start Added by kriraghu for bug  30358489
-- Ref of Supplier in Equipment Term
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
				SELECT NULL
				   FROM po_vendors  pv ,
						pn_eqp_leases_all pl,
						pn_eqp_payment_terms_all ppt
				  WHERE pv.party_id = p_person_id
				    AND pv.vendor_id = ppt.vendor_id
                    AND ppt.lease_id = pl.lease_id
					AND pl.lease_status <> 'TER'
					AND (TRUNC(sysdate) BETWEEN ppt.start_date
											 AND NVL(ppt.end_date, sysdate)
											OR
						  TRUNC(sysdate) < 	ppt.start_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PN_EQP_DRT_SUPP_TERM_ERR'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: EQP_DRT_SUPP_TERM_ERR');
            END IF;

    END;
-- End by kriraghu for bug  30358489

    -- Ref of Customer in Terms
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
				SELECT NULL
				   FROM hz_cust_accounts hca ,
						pn_leases_all pl,
						pn_payment_terms_all ppt       -- Modified by kriraghu for bug 30358489
				  WHERE hca.party_id = p_person_id
				    AND hca.cust_account_id = ppt.customer_id
					AND ppt.lease_id = pl.lease_id
					AND pl.lease_status <> 'TER'
					AND (TRUNC(sysdate) BETWEEN ppt.start_date
											 AND NVL(ppt.end_date, sysdate)
											OR
						  TRUNC(sysdate) < 	ppt.start_date));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PN_DRT_CUST_TERM_ERR'
 			  ,msgaplid => 240
 			  ,result_tbl => result_tbl);

         	IF P_PN_DEBUG_MODE = 'Y' THEN
			   pnp_debug_pkg.debug(g_package || 'pn_hr_drc msgcode: PN_DRT_CUST_TERM_ERR');
            END IF;

    END;

  END pn_tca_drc;

END PN_DRT_PKG;

/
