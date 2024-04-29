--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_DATAPOINTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_DATAPOINTS_PVT" AS
/* $Header: OKLRCDPB.pls 120.13.12010000.7 2010/04/28 05:00:25 rpillay ship $ */

  ---------------------------------------------
  -- FUNCTION credit_line_number
  ---------------------------------------------
  FUNCTION credit_line_number(x_resultout	OUT NOCOPY VARCHAR2,
       						  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_credit_line_number VARCHAR2(120);

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
    x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  KHR.CONTRACT_NUMBER
        INTO    l_credit_line_number
        FROM    OKC_K_HEADERS_B KHR, OKL_LEASE_APPLICATIONS_B LAP
        WHERE   KHR.SCS_CODE = 'CREDITLINE_CONTRACT'
        AND     LAP.CREDIT_LINE_ID = KHR.ID
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_credit_line_number := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_credit_line_number) ;

    RETURN to_char(l_credit_line_number );
  END credit_line_number ;

  ---------------------------------------------
  -- FUNCTION credit_line_expiration_date
  ---------------------------------------------
  FUNCTION credit_line_expiration_date(x_resultout	OUT NOCOPY VARCHAR2,
       						 		   x_errormsg	OUT NOCOPY VARCHAR2) RETURN DATE IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_credit_line_expiration_date DATE;

  BEGIN
   mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  KHR.END_DATE
        INTO    l_credit_line_expiration_date
        FROM    OKC_K_HEADERS_B KHR,
				OKL_LEASE_APPLICATIONS_B LAP
        WHERE   KHR.SCS_CODE = 'CREDITLINE_CONTRACT'
        AND     LAP.CREDIT_LINE_ID = KHR.ID
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_credit_line_expiration_date := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

	l_credit_line_expiration_date := to_date(l_credit_line_expiration_date, 'DD-MM-RRRR');

	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
			l_credit_line_expiration_date;

	RETURN l_credit_line_expiration_date;
  END credit_line_expiration_date ;

  ---------------------------------------------
  -- FUNCTION currency
  ---------------------------------------------
  FUNCTION currency(x_resultout	OUT NOCOPY VARCHAR2,
       				x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_currency VARCHAR2(15);

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  CURRENCY_CODE
        INTO    l_currency
        FROM    OKL_LEASE_APPLICATIONS_B
        WHERE   ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_currency := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_currency) ;

	RETURN to_char(l_currency);
  END currency ;

  ---------------------------------------------
  -- FUNCTION sales_rep
  ---------------------------------------------
  FUNCTION sales_rep(x_resultout OUT NOCOPY VARCHAR2,
       				 x_errormsg	 OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_sales_rep VARCHAR2(30);

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  REP.SALESREP_NUMBER
        INTO    l_sales_rep
        FROM    JTF_RS_SALESREPS REP,
				OKL_LEASE_APPLICATIONS_B LAP
        WHERE   LAP.SALES_REP_ID = REP.SALESREP_ID
        AND     REP.ORG_ID = LAP.ORG_ID
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_sales_rep := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_sales_rep) ;

	RETURN to_char(l_sales_rep);
  END sales_rep ;

  ---------------------------------------------
  -- FUNCTION program_vendor
  ---------------------------------------------
  FUNCTION program_vendor(x_resultout	OUT NOCOPY VARCHAR2,
       					  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_program_vendor VARCHAR2(30);

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  PO.SEGMENT1
        INTO    l_program_vendor
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKC_K_HEADERS_B CHR,
				OKC_K_PARTY_ROLES_B CPL, PO_VENDORS PO
        WHERE   LAP.PROGRAM_AGREEMENT_ID = CHR.ID
        AND     CHR.ID = CPL.DNZ_CHR_ID
        AND     CPL.JTOT_OBJECT1_CODE = 'OKL_VENDOR'
        AND     CPL.OBJECT1_ID1 = PO.VENDOR_ID
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_program_vendor := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_program_vendor) ;

	RETURN to_char(l_program_vendor );
  END program_vendor ;

  ---------------------------------------------
  -- FUNCTION program_agreement_number
  ---------------------------------------------
  FUNCTION program_agreement_number(x_resultout	OUT NOCOPY VARCHAR2,
       						 		x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_program_agreement_number VARCHAR2(120);

  BEGIN
   mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  KHR.CONTRACT_NUMBER
        INTO    l_program_agreement_number
        FROM    OKC_K_HEADERS_B KHR, OKL_LEASE_APPLICATIONS_B LAP
        WHERE   KHR.SCS_CODE = 'PROGRAM'
        AND     LAP.PROGRAM_AGREEMENT_ID = KHR.ID
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_program_agreement_number := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_program_agreement_number) ;

	RETURN to_char(l_program_agreement_number );
  END program_agreement_number ;

  ---------------------------------------------
  -- FUNCTION expected_start_date
  ---------------------------------------------
  FUNCTION expected_start_date(x_resultout	OUT NOCOPY VARCHAR2,
       						   x_errormsg	OUT NOCOPY VARCHAR2) RETURN DATE IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_expected_start_date DATE;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  QUOTE.EXPECTED_START_DATE
        INTO    l_expected_start_date
        FROM    OKL_LEASE_QUOTES_B QUOTE,
				OKL_LEASE_APPLICATIONS_B LAP
        WHERE   QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = QUOTE.PARENT_OBJECT_ID
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_expected_start_date := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

	l_expected_start_date := to_date(l_expected_start_date, 'DD-MM-RRRR');

	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					l_expected_start_date;

	RETURN l_expected_start_date;
  END expected_start_date ;

  ---------------------------------------------
  -- FUNCTION expected_delivery_date
  ---------------------------------------------
  FUNCTION expected_delivery_date(x_resultout	OUT NOCOPY VARCHAR2,
       						 	  x_errormsg	OUT NOCOPY VARCHAR2) RETURN DATE IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_expected_delivery_date DATE;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  QUOTE.EXPECTED_DELIVERY_DATE
        INTO    l_expected_delivery_date
        FROM    OKL_LEASE_QUOTES_B QUOTE, OKL_LEASE_APPLICATIONS_B LAP
        WHERE   QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = QUOTE.PARENT_OBJECT_ID
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_expected_delivery_date := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

	l_expected_delivery_date := to_date(l_expected_delivery_date, 'DD-MM-RRRR');

	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					l_expected_delivery_date;

	RETURN l_expected_delivery_date;
  END expected_delivery_date ;

  ---------------------------------------------
  -- FUNCTION expected_funding_date
  ---------------------------------------------
  FUNCTION expected_funding_date(x_resultout	OUT NOCOPY VARCHAR2,
       						     x_errormsg		OUT NOCOPY VARCHAR2) RETURN DATE IS

	l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
	l_expected_funding_date DATE;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  QUOTE.EXPECTED_FUNDING_DATE
        INTO    l_expected_funding_date
        FROM    OKL_LEASE_QUOTES_B QUOTE, OKL_LEASE_APPLICATIONS_B LAP
        WHERE   QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = QUOTE.PARENT_OBJECT_ID
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_expected_funding_date := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

	l_expected_funding_date := to_date(l_expected_funding_date, 'DD-MM-RRRR');

	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					l_expected_funding_date;

	RETURN l_expected_funding_date;
  END expected_funding_date ;

  ---------------------------------------------
  -- FUNCTION lease_application_template
  ---------------------------------------------
  FUNCTION lease_application_template(x_resultout	OUT NOCOPY VARCHAR2,
       						 		  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_lease_application_template VARCHAR2(150);

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  TEMPLATES.NAME
        INTO    l_lease_application_template
        FROM    OKL_LEASEAPP_TEMPLATES TEMPLATES, OKL_LEASE_APPLICATIONS_B LAP
        WHERE   LAP. LEASEAPP_TEMPLATE_ID = TEMPLATES.ID
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_lease_application_template := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_lease_application_template) ;

	RETURN to_char(l_lease_application_template );
  END lease_application_template ;

  ---------------------------------------------
  -- FUNCTION org_unit
  ---------------------------------------------
  FUNCTION org_unit(x_resultout	OUT NOCOPY VARCHAR2,
       				x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_org_unit VARCHAR2(240);

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  ORG.NAME
        INTO    l_org_unit
        FROM    HR_ALL_ORGANIZATION_UNITS ORG, OKL_LEASE_APPLICATIONS_B LAP
        WHERE   ORG.ORGANIZATION_ID = LAP.ORG_ID
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_org_unit := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_org_unit) ;

	RETURN to_char(l_org_unit );
  END org_unit ;

  ---------------------------------------------
  -- FUNCTION prospect_address
  ---------------------------------------------
  FUNCTION prospect_address(x_resultout	OUT NOCOPY VARCHAR2,
     						x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_prospect_address VARCHAR2(30);

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  PARTY_SITES.PARTY_SITE_NUMBER
        INTO    l_prospect_address
        FROM    HZ_PARTY_SITES PARTY_SITES, OKL_LEASE_APPLICATIONS_B LAP
        WHERE   PARTY_SITES.PARTY_SITE_ID = LAP.PROSPECT_ADDRESS_ID
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_prospect_address := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_prospect_address) ;

	RETURN to_char(l_prospect_address );
  END prospect_address ;

  ---------------------------------------------
  -- FUNCTION term_of_deal
  ---------------------------------------------
  FUNCTION term_of_deal(x_resultout	OUT NOCOPY VARCHAR2,
       					x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_term_of_deal NUMBER;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  QUOTE.TERM
        INTO    l_term_of_deal
        FROM    OKL_LEASE_QUOTES_B QUOTE, OKL_LEASE_APPLICATIONS_B LAP
        WHERE   QUOTE.PRIMARY_QUOTE  = 'Y'
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_term_of_deal := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					l_term_of_deal ;

	RETURN l_term_of_deal;
  END term_of_deal ;

  ---------------------------------------------
  -- FUNCTION financial_product
  ---------------------------------------------
  FUNCTION financial_product(x_resultout	OUT NOCOPY VARCHAR2,
       						 x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_financial_product VARCHAR2(150);

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  PRODUCT.NAME
        INTO    l_financial_product
        FROM    OKL_PRODUCTS PRODUCT, OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE
        WHERE   PRODUCT.ID = QUOTE.PRODUCT_ID
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     LAP.ID = l_lease_app_id;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_financial_product := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_financial_product) ;

	RETURN to_char(l_financial_product);
  END financial_product ;

  ---------------------------------------------
  -- FUNCTION item
  ---------------------------------------------
  FUNCTION item(x_resultout	OUT NOCOPY VARCHAR2,
       			x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_item VARCHAR2(40);

        CURSOR  citem IS
        SELECT  ITEM.CONCATENATED_SEGMENTS CONCATENATED_SEGMENTS, ASSET.ID
        FROM    MTL_SYSTEM_ITEMS_KFV ITEM, OKL_ASSET_COMPONENTS_B ASSET_COMP,
				OKL_LEASE_APPLICATIONS_B LAP, OKL_ASSETS_B ASSET,
				OKL_LEASE_QUOTES_B QUOTE
        WHERE   ITEM.INVENTORY_ITEM_ID = ASSET_COMP.INV_ITEM_ID
        --Bug 7030452 :use inventory org id in the following condition
       -- AND     ITEM.ORGANIZATION_ID = LAP.ORG_ID -- ssdeshpa Bug # 6689249 added
        AND     ITEM.ORGANIZATION_ID = LAP.INV_ORG_ID
	--Bug 7030452 :End
        AND     ASSET_COMP.ASSET_ID = ASSET.ID
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'YES'
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;

	ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cItemRec IN cItem LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cItemRec.CONCATENATED_SEGMENTS;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value_id :=
	        cItemRec.ID;

			ln_seq_number := ln_seq_number + 1;
	    END LOOP;

  	   RETURN NULL;
	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_item := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END item;

  ---------------------------------------------
  -- FUNCTION item_description
  ---------------------------------------------
  FUNCTION item_description(x_resultout	OUT NOCOPY VARCHAR2,
       						x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_item_description VARCHAR2(1995);

        CURSOR  citemdesc IS
        -- ssdeshpa Bug#6689249  start
	SELECT  ASSET_TL.SHORT_DESCRIPTION  DESCRIPTION
	-- ssdeshpa Bug#6689249  end
        FROM    OKL_ASSETS_TL ASSET_TL, OKL_ASSETS_B ASSET,
				OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE
        WHERE   ASSET_TL.ID = ASSET.ID
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     ASSET_TL.LANGUAGE = USERENV('LANG')
        AND     LAP.ID = l_lease_app_id;

	    ln_seq_number	NUMBER :=1;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cItemDescRec IN cItemDesc LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cItemDescRec.description;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_item_description := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END item_description ;

  ---------------------------------------------
  -- FUNCTION item_supplier
  ---------------------------------------------
  FUNCTION item_supplier(x_resultout	OUT NOCOPY VARCHAR2,
       					 x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_item_supplier VARCHAR2(120);

        CURSOR  cItemSupp IS
        -- ssdeshpa Bug# 6689249 start
        SELECT  VENDOR.VENDOR_NAME  SUPPLIER
        -- ssdeshpa Bug# 6689249 end
        FROM    PO_VENDORS VENDOR, OKL_ASSET_COMPONENTS_B ASSET_COMP,
				OKL_LEASE_APPLICATIONS_B LAP, OKL_ASSETS_B ASSET,
				OKL_LEASE_QUOTES_B QUOTE
        WHERE   VENDOR.VENDOR_ID = ASSET_COMP.SUPPLIER_ID
        AND     ASSET_COMP.ASSET_ID = ASSET.ID
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'YES'
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;

	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cItemSuppRec IN cItemSupp LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cItemSuppRec.supplier;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_item_supplier := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END item_supplier ;

  ---------------------------------------------
  -- FUNCTION model
  ---------------------------------------------
  FUNCTION model(x_resultout OUT NOCOPY VARCHAR2,
       			 x_errormsg	 OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_model VARCHAR2(40);

        CURSOR  cModelNum IS
        SELECT  ASSET_COMP.MODEL_NUMBER MODEL_NUMBER
        FROM    OKL_ASSET_COMPONENTS_B ASSET_COMP, OKL_LEASE_APPLICATIONS_B LAP,
                OKL_ASSETS_B ASSET, OKL_LEASE_QUOTES_B QUOTE
        WHERE   ASSET_COMP.ASSET_ID = ASSET.ID
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'YES'
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     LAP.ID = l_lease_app_id;

	    ln_seq_number	NUMBER :=1;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cModelNumRec IN cModelNum LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cModelNumRec.model_number;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_model := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END model ;

  ---------------------------------------------
  -- FUNCTION manufacturer
  ---------------------------------------------
  FUNCTION manufacturer(x_resultout	OUT NOCOPY VARCHAR2,
       					x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  --Bug# 9590286
  l_manufacturer VARCHAR2(360);

        CURSOR  cMfgName is
        SELECT  ASSET_COMP.MANUFACTURER_NAME MANUFACTURER_NAME
        FROM    OKL_ASSET_COMPONENTS_B ASSET_COMP, OKL_LEASE_APPLICATIONS_B LAP,
                OKL_ASSETS_B ASSET, OKL_LEASE_QUOTES_B QUOTE
        WHERE   ASSET_COMP.ASSET_ID = ASSET.ID
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'YES'
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;

	    ln_seq_number	NUMBER :=1;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cMfgNameRec IN cMfgName LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cMfgNameRec.manufacturer_name;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_manufacturer := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END manufacturer;

  ---------------------------------------------
  -- FUNCTION year_of_manufacture
  ---------------------------------------------
  FUNCTION year_of_manufacture(x_resultout	OUT NOCOPY VARCHAR2,
       						   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_year_of_manufacture NUMBER;

        CURSOR  cYearMfg IS
        SELECT  ASSET_COMP.YEAR_MANUFACTURED YEAR_MANUFACTURED
        FROM    OKL_ASSET_COMPONENTS_B ASSET_COMP, OKL_LEASE_APPLICATIONS_B LAP,
                OKL_ASSETS_B ASSET, OKL_LEASE_QUOTES_B QUOTE
        WHERE   ASSET_COMP.ASSET_ID = ASSET.ID
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'YES'
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;

        ln_seq_number	NUMBER :=1;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cYearMfgRec IN cYearMfg LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cYearMfgRec.year_manufactured;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_year_of_manufacture := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END year_of_manufacture ;

  ---------------------------------------------
  -- FUNCTION no_of_units
  ---------------------------------------------
  FUNCTION no_of_units(x_resultout	OUT NOCOPY VARCHAR2,
       				   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_no_of_units NUMBER;

        CURSOR  cNoOfUnits IS
        SELECT  ASSET_COMP.NUMBER_OF_UNITS NUMBER_OF_UNITS
        FROM    OKL_ASSET_COMPONENTS_B ASSET_COMP, OKL_LEASE_APPLICATIONS_B LAP,
                OKL_ASSETS_B ASSET, OKL_LEASE_QUOTES_B QUOTE
        WHERE   ASSET_COMP.ASSET_ID = ASSET.ID
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'YES'
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;

	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cNoOfUnitsRec IN cNoOfUnits LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cNoOfUnitsRec.number_of_units;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_no_of_units := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END no_of_units ;

  ---------------------------------------------
  -- FUNCTION unit_cost
  ---------------------------------------------
  FUNCTION unit_cost(x_resultout	OUT NOCOPY VARCHAR2,
       				 x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_unit_cost NUMBER;

        CURSOR  cUnitCost IS
        SELECT  ASSET_COMP.UNIT_COST UNIT_COST
        FROM    OKL_ASSET_COMPONENTS_B ASSET_COMP, OKL_LEASE_APPLICATIONS_B LAP,
                OKL_ASSETS_B ASSET, OKL_LEASE_QUOTES_B QUOTE
        WHERE   ASSET_COMP.ASSET_ID = ASSET.ID
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'YES'
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;

	    ln_seq_number	NUMBER :=1;


  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cUnitCostRec IN cUnitCost LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cUnitCostRec.unit_cost;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_unit_cost := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END unit_cost ;

  ---------------------------------------------
  -- FUNCTION install_site
  ---------------------------------------------
  FUNCTION install_site(x_resultout	OUT NOCOPY VARCHAR2,
       					x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_install_site VARCHAR2(30);

        CURSOR  cInstallSite IS
        SELECT  PARTY_SITE.PARTY_SITE_NUMBER PARTY_SITE_NUMBER
        FROM    HZ_PARTY_SITES PARTY_SITE, OKL_LEASE_APPLICATIONS_B LAP,
                OKL_ASSETS_B ASSET, OKL_LEASE_QUOTES_B QUOTE
        WHERE   PARTY_SITE.PARTY_SITE_ID = ASSET.INSTALL_SITE_ID
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;

	    ln_seq_number	NUMBER :=1;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cInstallSiteRec IN cInstallSite	LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cInstallSiteRec.party_site_number;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_install_site := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END install_site ;

  ---------------------------------------------
  -- FUNCTION usage_of_equipment
  ---------------------------------------------
  FUNCTION usage_of_equipment(x_resultout	OUT NOCOPY VARCHAR2,
       						  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_usage_of_equipment VARCHAR2(30);

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        -- gboomina Bug 7110500 - Start
        SELECT  QUOTE.USAGE_CATEGORY --QUOTE.USAGE_INDUSTRY_CLASS
        INTO    l_usage_of_equipment
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE
        WHERE   QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     LAP.ID = l_lease_app_id;
        -- gboomina Bug 7110500 - End


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_usage_of_equipment := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_usage_of_equipment) ;

	RETURN to_char(l_usage_of_equipment );
  END usage_of_equipment ;

  ---------------------------------------------
  -- FUNCTION usage_industry
  ---------------------------------------------
  FUNCTION usage_industry(x_resultout	OUT NOCOPY VARCHAR2,
       					  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_usage_industry VARCHAR2(1995);

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        -- gboomina Bug 7110500 - Start
        /*
        SELECT  QUOTE.USAGE_INDUSTRY_CODE
        INTO    l_usage_industry
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE
        WHERE   QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     LAP.ID = l_lease_app_id;
        */

        SELECT INDC.MEANING ||' - '||IND.MEANING USAGE_INDUSTRY
        INTO l_usage_industry
        FROM OKL_LEASE_APPLICATIONS_B LAP,AR_LOOKUPS INDC, AR_LOOKUPS IND
        WHERE INDC.LOOKUP_TYPE(+)='SIC_CODE_TYPE'
        AND INDC.LOOKUP_CODE(+)=LAP.INDUSTRY_CLASS
        AND IND.LOOKUP_TYPE(+)=LAP.INDUSTRY_CLASS
        AND IND.LOOKUP_CODE(+)=LAP.INDUSTRY_CODE
        AND LAP.id= l_lease_app_id;

        -- gboomina Bug 7110500 - End

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_usage_industry := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_usage_industry) ;

	RETURN to_char(l_usage_industry);
  END usage_industry ;

  ---------------------------------------------
  -- FUNCTION usage_category
  ---------------------------------------------
  FUNCTION usage_category(x_resultout	OUT NOCOPY VARCHAR2,
       					  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_usage_category VARCHAR2(30);

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  QUOTE.USAGE_CATEGORY
        INTO    l_usage_category
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE
        WHERE   QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     LAP.ID = l_lease_app_id;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_usage_category := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_usage_category) ;

	RETURN to_char(l_usage_category);
  END usage_category ;

  ---------------------------------------------
  -- FUNCTION usage_amount
  ---------------------------------------------
  FUNCTION usage_amount(x_resultout	OUT NOCOPY VARCHAR2,
       					x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_usage_amount NUMBER;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
  x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        -- gboomina Bug 7110500 - Start
        /*
        SELECT  QUOTE.USAGE_AMOUNT
        INTO    l_usage_amount
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE
        WHERE   QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     LAP.ID = l_lease_app_id;
        */
       SELECT LOP.USAGE_AMOUNT
       INTO   l_usage_amount
       FROM   OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_OPPORTUNITIES_B LOP
       WHERE  LOP.ID= LAP.LEASE_OPPORTUNITY_ID
       AND    LAP.ID = l_lease_app_id;

        -- gboomina Bug 7110500 - End

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_usage_amount := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					l_usage_amount;

	RETURN l_usage_amount;
  END usage_amount ;

  ---------------------------------------------
  -- FUNCTION add_on_item
  ---------------------------------------------
  FUNCTION add_on_item(x_resultout	OUT NOCOPY VARCHAR2,
       				   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  l_add_on_item VARCHAR2(40);

        CURSOR  cAddOnItem IS
        SELECT  ITEM.CONCATENATED_SEGMENTS ADD_ON_ITEM
        FROM    MTL_SYSTEM_ITEMS_KFV ITEM, OKL_ASSET_COMPONENTS_B ASSET_COMP
        WHERE   ITEM.INVENTORY_ITEM_ID = ASSET_COMP.INV_ITEM_ID
        AND     ITEM.ORGANIZATION_ID = OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID)
        AND     ASSET_COMP.ASSET_ID = l_asset_id
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'NO';

	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

	    FOR cAddOnItemRec IN cAddOnItem LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id := l_asset_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cAddOnItemRec.add_on_item;

			ln_seq_number := ln_seq_number + 1;
	    END LOOP;

		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_add_on_item := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END add_on_item ;

  ---------------------------------------------
  -- FUNCTION add_on_item_description
  ---------------------------------------------
  FUNCTION add_on_item_description(x_resultout	OUT NOCOPY VARCHAR2,
       						 	   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  l_add_on_item_description VARCHAR2(1995);

        CURSOR  cItemDescription IS
        SELECT  ITEM.CONCATENATED_SEGMENTS ADD_ON_ITEM
        FROM    MTL_SYSTEM_ITEMS_KFV ITEM, OKL_ASSET_COMPONENTS_B ASSET_COMP
        WHERE   ITEM.INVENTORY_ITEM_ID = ASSET_COMP.INV_ITEM_ID
        AND     ITEM.ORGANIZATION_ID = OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID)
        AND     ASSET_COMP.ASSET_ID = l_asset_id
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'NO';

	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cItemDescriptionRec IN cItemDescription LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				l_asset_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cItemDescriptionRec.add_on_item;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_add_on_item_description := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END add_on_item_description ;

  ---------------------------------------------
  -- FUNCTION add_on_item_supplier
  ---------------------------------------------
  FUNCTION add_on_item_supplier(x_resultout	OUT NOCOPY VARCHAR2,
       						    x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  l_add_on_item_supplier VARCHAR2(30);

        CURSOR  cItemSupplier IS
        SELECT  VENDOR.VENDOR_NAME ITEM_SUPPLIER
        FROM    PO_VENDORS VENDOR, OKL_ASSET_COMPONENTS_B ASSET_COMP
        WHERE   VENDOR.VENDOR_ID = ASSET_COMP.SUPPLIER_ID
        AND     ASSET_COMP.ASSET_ID = l_asset_id
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'NO';

	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cItemSupplierRec IN cItemSupplier LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				l_asset_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cItemSupplierRec.item_supplier;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_add_on_item_supplier := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END add_on_item_supplier ;

  ---------------------------------------------
  -- FUNCTION add_on_item_model
  ---------------------------------------------
  FUNCTION add_on_item_model(x_resultout	OUT NOCOPY VARCHAR2,
       						 x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  l_add_on_item_model VARCHAR2(40);

        CURSOR  cItemModel IS
        SELECT  ASSET_COMP.MODEL_NUMBER MODEL_NUMBER
        FROM    OKL_ASSET_COMPONENTS_B ASSET_COMP
        WHERE   ASSET_COMP.ASSET_ID = l_asset_id
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'NO';

	    ln_seq_number	NUMBER :=1;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cItemModelRec IN cItemModel LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id := l_asset_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cItemModelRec.model_number;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_add_on_item_model := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END add_on_item_model ;

  ---------------------------------------------
  -- FUNCTION add_on_item_manufacturer
  ---------------------------------------------
  FUNCTION add_on_item_manufacturer(x_resultout	OUT NOCOPY VARCHAR2,
       						 		x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  --Bug# 9590286
  l_add_on_item_manufacturer VARCHAR2(360);

        CURSOR  cItemMfg IS
        SELECT  ASSET_COMP.MANUFACTURER_NAME MANUFACTURER_NAME
        FROM    OKL_ASSET_COMPONENTS_B ASSET_COMP
        WHERE   ASSET_COMP.ASSET_ID = l_asset_id
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'NO';

	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cItemMfgRec IN cItemMfg LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cItemMfgRec.manufacturer_name;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_add_on_item_manufacturer := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END add_on_item_manufacturer ;

  ---------------------------------------------
  -- FUNCTION add_on_item_amount
  ---------------------------------------------
  FUNCTION add_on_item_amount(x_resultout	OUT NOCOPY VARCHAR2,
       						  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  l_add_on_item_amount NUMBER;

        CURSOR  cAddOnItemAmount IS
        SELECT  ASSET_COMP.UNIT_COST    UNIT_COST
        FROM    OKL_ASSET_COMPONENTS_B ASSET_COMP
        WHERE   ASSET_COMP.ASSET_ID = l_asset_id
        AND     ASSET_COMP.PRIMARY_COMPONENT = 'NO';

	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cAddOnItemAmountRec IN cAddOnItemAmount LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id := l_asset_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cAddOnItemAmountRec.unit_cost;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_add_on_item_amount := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END add_on_item_amount ;

  ---------------------------------------------
  -- FUNCTION asset_residual_value
  ---------------------------------------------
  FUNCTION asset_residual_value(x_resultout	OUT NOCOPY VARCHAR2,
       						    x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_add_on_item_residual_values NUMBER;

        CURSOR  cItemResVal IS
        SELECT  NVL(ASSET.END_OF_TERM_VALUE,ASSET.END_OF_TERM_VALUE_DEFAULT) END_OF_TERM_VALUE
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_ASSETS_B ASSET, OKL_LEASE_QUOTES_B QUOTE
        WHERE     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;

	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cItemResValRec IN cItemResVal LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cItemResValRec.END_OF_TERM_VALUE;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_add_on_item_residual_values := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END asset_residual_value ;

  ---------------------------------------------
  -- FUNCTION down_payment_amount
  ---------------------------------------------
  FUNCTION down_payment_amount(x_resultout	OUT NOCOPY VARCHAR2,
       						   x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_down_payment_amount NUMBER;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  NVL(SUM(ADJ.VALUE), 0)
        INTO    l_down_payment_amount
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_ASSETS_B ASSET,
                OKL_COST_ADJUSTMENTS_B ADJ, OKL_LEASE_QUOTES_B QUOTE
        WHERE   ADJ.ADJUSTMENT_SOURCE_TYPE = 'DOWN_PAYMENT'
        AND     ADJ.PARENT_OBJECT_CODE = 'ASSET'
        AND     ADJ.PARENT_OBJECT_ID = ASSET.ID
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_down_payment_amount := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					l_down_payment_amount;
	RETURN l_down_payment_amount;
  END down_payment_amount ;

  ---------------------------------------------
  -- FUNCTION subsidy_amount
  ---------------------------------------------
  FUNCTION subsidy_amount(x_resultout	OUT NOCOPY VARCHAR2,
       					  x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_subsidy_amount NUMBER;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  SUM(DECODE(ADJ.VALUE, NULL, ADJ.DEFAULT_SUBSIDY_AMOUNT, ADJ.VALUE)) SUBSIDY_AMOUNT
        INTO    l_subsidy_amount
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_ASSETS_B ASSET,
                OKL_COST_ADJUSTMENTS_B ADJ, OKL_LEASE_QUOTES_B QUOTE
        WHERE   ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
        AND     ADJ.PARENT_OBJECT_CODE = 'ASSET'
        AND     ADJ.PARENT_OBJECT_ID = ASSET.ID
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_subsidy_amount := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					l_subsidy_amount ;

	RETURN l_subsidy_amount;
  END subsidy_amount ;

  ---------------------------------------------
  -- FUNCTION trade_in_amount
  ---------------------------------------------
  FUNCTION trade_in_amount(x_resultout	OUT NOCOPY VARCHAR2,
       					   x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_trade_in_amount NUMBER;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  NVL(SUM(ADJ.VALUE), 0)
        INTO    l_trade_in_amount
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_ASSETS_B ASSET,
                OKL_COST_ADJUSTMENTS_B ADJ, OKL_LEASE_QUOTES_B QUOTE
        WHERE   ADJ.ADJUSTMENT_SOURCE_TYPE = 'TRADEIN'
        AND     ADJ.PARENT_OBJECT_CODE = 'ASSET'
        AND     ADJ.PARENT_OBJECT_ID = ASSET.ID
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_trade_in_amount := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					l_trade_in_amount;

	RETURN l_trade_in_amount;
  END trade_in_amount ;

  ---------------------------------------------
  -- FUNCTION trade_in_asset_number
  ---------------------------------------------
  FUNCTION trade_in_asset_number(x_resultout	OUT NOCOPY VARCHAR2,
       						 	 x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_trade_in_asset_number VARCHAR2(15);

        CURSOR  cAssetNumber IS
        SELECT  ASSET.ASSET_NUMBER
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_ASSETS_B ASSET,
				OKL_LEASE_QUOTES_B QUOTE, OKL_COST_ADJUSTMENTS_B ADJ
        WHERE   ADJ.ADJUSTMENT_SOURCE_TYPE = 'TRADEIN'
        AND     ADJ.PARENT_OBJECT_CODE = 'ASSET'
        AND     ADJ.PARENT_OBJECT_ID = ASSET.ID
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;

      ln_seq_number NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cAssetNumberRec IN cAssetNumber
		LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cAssetNumberRec.ASSET_NUMBER;

			ln_seq_number := ln_seq_number + 1;

	   END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_trade_in_asset_number := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

  END trade_in_asset_number ;

  ---------------------------------------------
  -- FUNCTION pmnt_frequency
  ---------------------------------------------
  FUNCTION pmnt_frequency(x_resultout	OUT NOCOPY VARCHAR2,
       					  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  l_pmnt_frequency VARCHAR2(30);

        cursor  cPmntFreq is
        select  FND.MEANING frequency
        from    OKL_CASH_FLOW_OBJECTS CFO, OKL_CASH_FLOWS CFL,
                OKL_CASH_FLOW_LEVELS LVL, FND_LOOKUPS FND
        where   CFO.OTY_CODE  = 'QUOTED_ASSET'
        and     CFO.ID = CFL.CFO_ID
        and     CFL.ID = LVL.CAF_ID
        and     CFO.SOURCE_ID = l_asset_id
        and     CFO.SOURCE_TABLE = 'OKL_ASSETS_B'
        AND     LVL.FQY_CODE = FND.LOOKUP_CODE
        AND     FND.LOOKUP_TYPE = 'OKL_FREQUENCY';

        /*UNION
        select  OKL_CASH_FLOW_LEVELS.FQY_CODE FQY_CODE
        from    okl_lease_applications_b LAP, OKL_FEES_B FEE, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_FEE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = FEE.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_ASSETS_B'
        and     FEE.parent_object_id = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     FEE.parent_object_code = 'LEASEQUOTE'
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id
        UNION
        select  OKL_CASH_FLOW_LEVELS.FQY_CODE FQY_CODE
        from    okl_lease_applications_b LAP, OKL_SERVICES_B SRV, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_SERVICE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = SRV.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_ASSETS_B'
        and     SRV.parent_object_id = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     SRV.parent_object_code = 'LEASEQUOTE'
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id
        UNION
        select  OKL_CASH_FLOW_LEVELS.FQY_CODE FQY_CODE
        from    okl_lease_applications_b LAP, OKL_INSURANCE_ESTIMATES_B INS,         OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_INSURANCE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = INS.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_INSURANCE_ESTIMATES_B'
        and     INS.LEASE_QUOTE_ID = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id;*/


	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cPmntFreqRec IN cPmntFreq
		LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id := l_asset_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cPmntFreqRec.frequency;

			ln_seq_number := ln_seq_number + 1;

	   END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_pmnt_frequency := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END pmnt_frequency ;

  ---------------------------------------------
  -- FUNCTION pmnt_arrears_yn
  ---------------------------------------------
  FUNCTION pmnt_arrears_yn(x_resultout	OUT NOCOPY VARCHAR2,
       					   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  l_pmnt_arrears_yn VARCHAR2(3);

        cursor  cPmntArrYN is
        select  FND.MEANING Arrears
        from    OKL_CASH_FLOW_OBJECTS CFO, OKL_CASH_FLOWS CFL, FND_LOOKUPS FND
        where   CFO.OTY_CODE  = 'QUOTED_ASSET'
        and     CFO.id = CFL.CFO_ID
        --Bug 7030452 :Hardcoded value '23' is removed
	--   and     CFO.source_id = 23
	and     CFO.source_id = l_asset_id
        --Bug 7030452 :End
        and     CFO.source_table = 'OKL_ASSETS_B'
        AND     CFL.due_arrears_yn = FND.LOOKUP_CODE
        AND     FND.LOOKUP_TYPE = 'OKL_YES_NO';

        /*union
        select  OKL_CASH_FLOWS.due_arrears_yn due_arrears_yn
        from    okl_lease_applications_b LAP, OKL_FEES_B FEE, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_FEE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = FEE.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_FEES_B'
        and     FEE.parent_object_id = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     FEE.parent_object_code = 'LEASEQUOTE'
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id
        union
        select  OKL_CASH_FLOWS.due_arrears_yn due_arrears_yn
        from    okl_lease_applications_b LAP, OKL_SERVICES_B SRV, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_SERVICE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = SRV.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_SERVICES_B'
        and     SRV.parent_object_id = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     SRV.parent_object_code = 'LEASEQUOTE'
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id
        union
        select  OKL_CASH_FLOWS.due_arrears_yn due_arrears_yn
        from    okl_lease_applications_b LAP, OKL_INSURANCE_ESTIMATES_B INS, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_INSURANCE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = INS.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_INSURANCE_ESTIMATES_B'
        and     INS.LEASE_QUOTE_ID = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id;*/

	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cPmntArrYNRec IN cPmntArrYN
		LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id := l_asset_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cPmntArrYNRec.Arrears;

			ln_seq_number := ln_seq_number + 1;

	   END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_pmnt_arrears_yn := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END pmnt_arrears_yn ;


  ---------------------------------------------
  -- FUNCTION pmnt_periods
  ---------------------------------------------
  FUNCTION pmnt_periods(x_resultout	OUT NOCOPY VARCHAR2,
       					x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  l_pmnt_periods NUMBER;

        cursor  cPmntPeriods is
        select  LVL.NUMBER_OF_PERIODS
        from    OKL_CASH_FLOW_OBJECTS CFO, OKL_CASH_FLOWS CFL, OKL_CASH_FLOW_LEVELS LVL
        where   CFO.OTY_CODE  = 'QUOTED_ASSET'
        and     CFO.ID = CFL.CFO_ID
        and     CFL.ID = LVL.CAF_ID
        and     CFO.SOURCE_ID = l_asset_id
        and     CFO.SOURCE_TABLE = 'OKL_ASSETS_B';

        /*union
        select  OKL_CASH_FLOW_LEVELS.number_of_periods number_of_periods
        from    okl_lease_applications_b LAP, OKL_FEES_B FEE, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_FEE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = FEE.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_FEES_B'
        and     FEE.parent_object_id = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     FEE.parent_object_code = 'LEASEQUOTE'
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id
        union
        select  OKL_CASH_FLOW_LEVELS.number_of_periods number_of_periods
        from    okl_lease_applications_b LAP, OKL_SERVICES_B SRV, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  =  'QUOTED_SERVICE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = SRV.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_SERVICES_B'
        and     SRV.parent_object_id = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     SRV.parent_object_code = 'LEASEQUOTE'
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id
        union
        select  OKL_CASH_FLOW_LEVELS.number_of_periods number_of_periods
        from    okl_lease_applications_b LAP, OKL_INSURANCE_ESTIMATES_B INS, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  =   'QUOTED_INSURANCE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = INS.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_INSURANCE_ESTIMATES_B'
        and     INS.LEASE_QUOTE_ID = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id;*/

	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cPmntPeriodsRec IN cPmntPeriods
		LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id := l_asset_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cPmntPeriodsRec.number_of_periods;

			ln_seq_number := ln_seq_number + 1;

	   END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_pmnt_periods := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END pmnt_periods ;


  ---------------------------------------------
  -- FUNCTION pmnt_amounts
  ---------------------------------------------
  FUNCTION pmnt_amounts(x_resultout	OUT NOCOPY VARCHAR2,
       						 x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  l_pmnt_amounts NUMBER;

        cursor  cPmntAmount is
        select  LVL.AMOUNT
        from    OKL_CASH_FLOW_OBJECTS CFO, OKL_CASH_FLOWS CFL, OKL_CASH_FLOW_LEVELS LVL
        where   CFO.OTY_CODE  = 'QUOTED_ASSET'
        and     CFO.ID = CFL.CFO_ID
        and     CFL.ID = LVL.CAF_ID
        and     CFO.SOURCE_ID = l_asset_id
        and     CFO.SOURCE_TABLE = 'OKL_ASSETS_B';

        /*union
        select  OKL_CASH_FLOW_LEVELS.amount amount
        from    okl_lease_applications_b LAP, OKL_FEES_B FEE, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_FEE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = FEE.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_FEES_B'
        and     FEE.parent_object_id = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     FEE.parent_object_code = 'LEASEQUOTE'
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id
        union
        select  OKL_CASH_FLOW_LEVELS.amount amount
        from    okl_lease_applications_b LAP, OKL_SERVICES_B SRV, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_SERVICE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = SRV.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_SERVICES_B'
        and     SRV.parent_object_id = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     SRV.parent_object_code = 'LEASEQUOTE'
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id
        union
        select  OKL_CASH_FLOW_LEVELS.amount amount
        from    okl_lease_applications_b LAP, OKL_INSURANCE_ESTIMATES_B INS, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_INSURANCE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = INS.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_INSURANCE_ESTIMATES_B'
        and     INS.LEASE_QUOTE_ID = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id;        */

	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cPmntAmountRec IN cPmntAmount
		LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id := l_asset_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cPmntAmountRec.amount;

			ln_seq_number := ln_seq_number + 1;

	   END LOOP;
		RETURN NULL;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_pmnt_amounts := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END pmnt_amounts ;

  ---------------------------------------------
  -- FUNCTION pmnt_start_date
  ---------------------------------------------
  FUNCTION pmnt_start_date(x_resultout	OUT NOCOPY VARCHAR2,
       					   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  l_pmnt_start_date DATE;

        cursor  cPmntStartDate is
        select  LVL.start_date
        from    OKL_CASH_FLOW_OBJECTS CFO, OKL_CASH_FLOWS CFL, OKL_CASH_FLOW_LEVELS LVL
        where   CFO.OTY_CODE  = 'QUOTED_ASSET'
        and     CFO.ID = CFL.CFO_ID
        and     CFL.ID = LVL.CAF_ID
        and     CFO.SOURCE_ID = l_asset_id
        and     CFO.SOURCE_TABLE = 'OKL_ASSETS_B';

        /*union
        select  OKL_CASH_FLOW_LEVELS.start_date start_date
        from    okl_lease_applications_b LAP, OKL_FEES_B FEE, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  =  'QUOTED_FEE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = FEE.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_FEES_B'
        and     FEE.parent_object_id = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     FEE.parent_object_code = 'LEASEQUOTE'
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id
        union
        select  OKL_CASH_FLOW_LEVELS.start_date start_date
        from    okl_lease_applications_b LAP, OKL_SERVICES_B SRV, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  =  'QUOTED_SERVICE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = SRV.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_SERVICES_B'
        and     SRV.parent_object_id = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     SRV.parent_object_code = 'LEASEQUOTE'
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id
        union
        select  OKL_CASH_FLOW_LEVELS.start_date start_date
        from    okl_lease_applications_b LAP, OKL_INSURANCE_ESTIMATES_B INS, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  =   'QUOTED_INSURANCE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = INS.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_INSURANCE_ESTIMATES_B'
        and     INS.LEASE_QUOTE_ID = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id;*/

	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cPmntStartDateRec IN cPmntStartDate
		LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id := l_asset_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cPmntStartDateRec.start_date;

			ln_seq_number := ln_seq_number + 1;

	   END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_pmnt_start_date := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END pmnt_start_date ;

  ---------------------------------------------
  -- FUNCTION payment_structure
  ---------------------------------------------
  FUNCTION payment_structure(x_resultout	OUT NOCOPY VARCHAR2,
       						 x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  l_payment_structure VARCHAR2(5) := 'LEVEL';

  ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN

        x_resultout := FND_API.G_RET_STS_SUCCESS;

			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id := l_asset_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        l_payment_structure;


		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_payment_structure := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END payment_structure ;

  -------------------------------------
  -- PROCEDURE calculate_level_end_date
  -------------------------------------
  PROCEDURE calculate_level_end_date (
    p_level_start_date    IN DATE
   ,p_contract_term       IN NUMBER
   ,p_frequency_code 	  IN VARCHAR2
   ,p_cashflow_level_tbl  IN OUT NOCOPY OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_tbl_type
   ,x_return_status       OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'calculate_level_end_date';
    l_api_name             CONSTANT VARCHAR2(61) := G_APP_NAME||'.'||l_program_name;

    l_mpp                  PLS_INTEGER;

    l_contract_end_date    DATE;
    l_next_start_date      DATE;
    l_end_date             DATE;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
    IF p_frequency_code = 'A' THEN
      l_mpp := 12;
    ELSIF p_frequency_code = 'S' THEN
      l_mpp := 6;
    ELSIF p_frequency_code = 'Q' THEN
      l_mpp := 3;
    ELSIF p_frequency_code = 'M' THEN
      l_mpp := 1;
    END IF;

    l_next_start_date := p_level_start_date;

    FOR i IN p_cashflow_level_tbl.FIRST .. p_cashflow_level_tbl.LAST LOOP
      IF p_cashflow_level_tbl.EXISTS(i) THEN

        IF p_cashflow_level_tbl(i).stub_days IS NOT NULL THEN
          l_end_date := l_next_start_date + p_cashflow_level_tbl(i).stub_days - 1;
        ELSE
          l_end_date := ADD_MONTHS(l_next_start_date, l_mpp*p_cashflow_level_tbl(i).periods) - 1;
        END IF;

        p_cashflow_level_tbl(i).start_date := l_end_date;
        l_next_start_date                  := l_end_date + 1;

      END IF;
    END LOOP;

    l_contract_end_date := ADD_MONTHS(p_level_start_date, p_contract_term) - 1;

    IF l_end_date > l_contract_end_date THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_EXTENDS_K_END');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END calculate_level_end_date;

  ---------------------------------------------
  -- FUNCTION pmnt_end_date
  ---------------------------------------------
  FUNCTION pmnt_end_date(x_resultout	OUT NOCOPY VARCHAR2,
       					 x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_asset_id     NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);

  l_pmnt_end_date DATE;

        cursor c_level_data is
        select LVL.stub_days, LVL.number_of_periods, LVL.start_date
        from  OKL_CASH_FLOW_OBJECTS CFO, OKL_CASH_FLOWS CFL, OKL_CASH_FLOW_LEVELS LVL
        where   CFO.OTY_CODE  = 'QUOTED_ASSET'
        and     CFO.ID = CFL.CFO_ID
        and     CFL.ID = LVL.CAF_ID
        and     CFO.SOURCE_ID = l_asset_id
        and     CFO.SOURCE_TABLE = 'OKL_ASSETS_B'
        order by LVL.start_date; --Bug # 9116306

        /*union
        select  OKL_CASH_FLOW_LEVELS.start_date end_date
        from    okl_lease_applications_b LAP, OKL_FEES_B FEE, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_FEE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = FEE.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_FEES_B'
        and     FEE.parent_object_id = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     FEE.parent_object_code = 'LEASEQUOTE'
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id
        union
        select  OKL_CASH_FLOW_LEVELS.start_date end_date
        from    okl_lease_applications_b LAP, OKL_SERVICES_B SRV, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_SERVICE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = SRV.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_SERVICES_B'
        and     SRV.parent_object_id = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     SRV.parent_object_code = 'LEASEQUOTE'
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id
        union
        select  OKL_CASH_FLOW_LEVELS.start_date end_date
        from    okl_lease_applications_b LAP, OKL_INSURANCE_ESTIMATES_B INS, OKL_CASH_FLOW_OBJECTS,
                okl_cash_flows, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        where   OKL_CASH_FLOW_objects.OTY_CODE  = 'QUOTED_INSURANCE'
        and     OKL_CASH_FLOW_objects.id = okl_cash_flows.CFO_ID
        and     okl_cash_flows.id = OKL_CASH_FLOW_LEVELS.CAF_ID
        and     OKL_CASH_FLOW_OBJECTS.source_id = INS.id
        and     OKL_CASH_FLOW_OBJECTS.source_table = 'OKL_INSURANCE_ESTIMATES_B'
        and     INS.LEASE_QUOTE_ID = QUOTE.id
        and     QUOTE.parent_object_id = LAP.id
        and     QUOTE.parent_object_code = 'LEASEAPP'
        and     QUOTE.primary_quote = 'Y'
        and     LAP.id = l_lease_app_id;*/

		CURSOR c_get_info IS
        SELECT  OKL_CASH_FLOW_LEVELS.FQY_CODE FQY_CODE, QUOTE.TERM
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_ASSETS_B ASSET, OKL_CASH_FLOW_OBJECTS,
                OKL_CASH_FLOWS, OKL_CASH_FLOW_LEVELS, OKL_LEASE_QUOTES_B QUOTE
        WHERE   OKL_CASH_FLOW_OBJECTS.OTY_CODE  = 'QUOTED_ASSET'
        AND     OKL_CASH_FLOW_OBJECTS.ID = OKL_CASH_FLOWS.CFO_ID
        AND     OKL_CASH_FLOWS.ID = OKL_CASH_FLOW_LEVELS.CAF_ID
        AND     OKL_CASH_FLOW_OBJECTS.SOURCE_ID = ASSET.ID
        AND     OKL_CASH_FLOW_OBJECTS.SOURCE_TABLE = 'OKL_ASSETS_B'
        AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id
        AND     ASSET.ID = l_asset_id
        AND		ROWNUM = 1;

	    ln_seq_number	NUMBER :=1;
	    i               BINARY_INTEGER := 0;

	    cf_level_tbl	OKL_LEASE_QUOTE_CASHFLOW_PVT.cashflow_level_tbl_type;

	    l_freq_code		OKL_CASH_FLOW_LEVELS.FQY_CODE%TYPE;
	    l_term			NUMBER;
	    l_return_status	VARCHAR2(1);
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

        -- Fetch the frequency code, term
        OPEN c_get_info;
        FETCH c_get_info INTO l_freq_code, l_term;
        CLOSE c_get_info;

        -- Populate the level table
    	FOR l_level_data IN c_level_data LOOP
      	  cf_level_tbl(i).stub_days := l_level_data.stub_days;
      	  cf_level_tbl(i).periods := l_level_data.number_of_periods;
      	  cf_level_tbl(i).start_date := l_level_data.start_date;

      	  i := i + 1;
      	END LOOP;

      	IF (l_freq_code IS NOT NULL AND l_term IS NOT NULL AND cf_level_tbl.COUNT > 0) THEN

  		  calculate_level_end_date ( p_level_start_date    => cf_level_tbl(0).start_date
						    	    ,p_contract_term       => l_term
						       	    ,p_frequency_code 	 => l_freq_code
						            ,p_cashflow_level_tbl  => cf_level_tbl
								    ,x_return_status       => l_return_status);
    	  IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      	    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	  ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
    	  END IF;

          FOR j IN cf_level_tbl.FIRST .. cf_level_tbl.LAST LOOP
            IF cf_level_tbl.EXISTS(j) THEN
			  OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			  OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id := l_asset_id;
			  OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			  OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value := cf_level_tbl(j).start_date;

			  ln_seq_number := ln_seq_number + 1;
            END IF;
          END LOOP;

        END IF;

		RETURN NULL;

	EXCEPTION
    	WHEN OKL_API.G_EXCEPTION_ERROR THEN
      	  l_pmnt_end_date := NULL;

    	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          l_pmnt_end_date := NULL;

	    WHEN NO_DATA_FOUND THEN
		  l_pmnt_end_date := NULL;
        WHEN OTHERS THEN
		  x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
		  x_errormsg := sqlerrm;
	END;
  END pmnt_end_date ;

  ---------------------------------------------
  -- FUNCTION fee_name
  ---------------------------------------------
  FUNCTION fee_name  (x_resultout	OUT NOCOPY VARCHAR2,
              		  x_errormsg	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_fee_name VARCHAR2(30);
        -- gboomina:Bug 7110500 :Modified cursor to use correct view
        CURSOR  cFeeName IS
        /*
        SELECT STRM.STY_NAME FEE_NAME
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE,
				OKL_FEES_B FEES, OKL_STRM_TMPT_PRIMARY_UV STRM
        WHERE   STRM.STY_ID = FEES.STREAM_TYPE_ID
        AND     FEES.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     FEES.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;
        */
        SELECT STRM.NAME FEE_NAME
         FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE,
                                 OKL_FEES_B FEES, OKL_STRM_TYPE_V STRM
         WHERE   STRM.ID = FEES.STREAM_TYPE_ID
         AND     FEES.PARENT_OBJECT_CODE = 'LEASEQUOTE'
         AND     FEES.PARENT_OBJECT_ID = QUOTE.ID
         AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
         AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
         AND     QUOTE.PRIMARY_QUOTE = 'Y'
         AND     LAP.ID = l_lease_app_id;

        -- gboomina:Bug 7110500 - End

	    ln_seq_number	NUMBER :=1;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cFeeNameRec IN cFeeName LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cFeeNameRec.fee_name;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_fee_name := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END fee_name ;


  ---------------------------------------------
  -- FUNCTION fee_type
  ---------------------------------------------
  FUNCTION fee_type(x_resultout	OUT NOCOPY VARCHAR2,
       				x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_fee_type VARCHAR2(30);

        CURSOR  cFeeType IS
        SELECT  FEES.FEE_TYPE   FEE_TYPE
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE, OKL_FEES_B FEES
        WHERE   FEES.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     FEES.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;


	    ln_seq_number	NUMBER :=1;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cFeeTypeRec IN cFeeType LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cFeeTypeRec.fee_type;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_fee_type := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END fee_type ;

  ---------------------------------------------
  -- FUNCTION fee_amount
  ---------------------------------------------
  FUNCTION fee_amount(x_resultout	OUT NOCOPY VARCHAR2,
       				  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_fee_amount NUMBER;

        CURSOR  cFeeAmount IS
        SELECT  FEES.FEE_AMOUNT FEE_AMOUNT
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE, OKL_FEES_B FEES
        WHERE   FEES.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     FEES.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;


	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cFeeAmountRec IN cFeeAmount LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cFeeAmountRec.fee_amount;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_fee_amount := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;
  END fee_amount ;

  ---------------------------------------------
  -- FUNCTION fee_date
  ---------------------------------------------
  FUNCTION fee_date(x_resultout	OUT NOCOPY VARCHAR2,
       				x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_fee_date DATE;

        CURSOR  cFeeEffFrom IS
        SELECT  FEES.EFFECTIVE_FROM EFFECTIVE_FROM
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE, OKL_FEES_B FEES
        WHERE   FEES.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     FEES.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     LAP.ID = l_lease_app_id;


	    ln_seq_number	NUMBER :=1;
  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cFeeEffFromRec IN cFeeEffFrom LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cFeeEffFromRec.effective_from;

			ln_seq_number := ln_seq_number + 1;

	    END LOOP;
		RETURN NULL;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_fee_date := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					to_char(l_fee_date) ;

	RETURN to_char(l_fee_date);
  END fee_date ;

  ---------------------------------------------
  -- FUNCTION amount_requested
  ---------------------------------------------
  FUNCTION amount_requested(x_resultout	OUT NOCOPY VARCHAR2,
       					    x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);

  ln_amount_requested 	NUMBER;
  ln_asset_cost			NUMBER;
  ln_addon_cost			NUMBER;
  ln_fee_cost			NUMBER;

  -- added for bug 6596860 --
  CURSOR l_adj_sum_csr(p_lease_app_id IN NUMBER) 	IS
    SELECT   NVL(SUM(VALUE),0 )
  	FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_ASSETS_B ASSET,
  	        OKL_COST_ADJUSTMENTS_B ADJ, OKL_LEASE_QUOTES_B QUOTE
  	WHERE   ADJ.PARENT_OBJECT_CODE = 'ASSET'
  	AND     ADJ.PARENT_OBJECT_ID = ASSET.ID
  	AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
  	AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
  	AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
  	AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
  	AND     QUOTE.PRIMARY_QUOTE = 'Y'
  	AND 	ADJ.ADJUSTMENT_SOURCE_TYPE  IN ('DOWN_PAYMENT', 'TRADEIN')
    AND     LAP.ID = p_lease_app_id;

  l_adj_amount NUMBER;   -- added for bug 6596860 --

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
    x_resultout := FND_API.G_RET_STS_SUCCESS;

	SELECT NVL(SUM(AST.OEC), 0)
	INTO ln_asset_cost
	FROM  OKL_ASSETS_B AST, OKL_LEASE_QUOTES_B QUOTE, OKL_LEASE_APPLICATIONS_B LAP
	WHERE AST.PARENT_OBJECT_ID = QUOTE.ID
	AND   AST.PARENT_OBJECT_CODE = 'LEASEQUOTE'
	AND   QUOTE.PARENT_OBJECT_ID = LAP.ID
	AND   QUOTE.PRIMARY_QUOTE = 'Y'
	AND   QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
	AND LAP.ID = l_lease_app_id;

	/*SELECT NVL(SUM(AST_COMP.UNIT_COST * AST_COMP.NUMBER_OF_UNITS), 0)
	INTO ln_addon_cost
	FROM  OKL_ASSETS_B AST, OKL_ASSET_COMPONENTS_B AST_COMP,
		  OKL_LEASE_QUOTES_B QUOTE, OKL_LEASE_APPLICATIONS_B LAP
	WHERE AST_COMP.ASSET_ID = AST.ID
	AND   AST_COMP.PRIMARY_COMPONENT = 'NO'
	AND   AST.PARENT_OBJECT_ID = QUOTE.ID
	AND   AST.PARENT_OBJECT_CODE = 'LEASEQUOTE'
	AND   QUOTE.PARENT_OBJECT_ID = LAP.ID
	AND   QUOTE.PRIMARY_QUOTE = 'Y'
	AND   QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
	AND   LAP.ID = l_lease_app_id;*/

    SELECT  NVL(SUM(FEES.FEE_AMOUNT), 0)
    INTO    ln_fee_cost
    FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE, OKL_FEES_B FEES
    WHERE   FEES.PARENT_OBJECT_CODE = 'LEASEQUOTE'
    AND     FEES.PARENT_OBJECT_ID = QUOTE.ID
    AND     FEES.FEE_TYPE IN ('ROLLOVER', 'FINANCED', 'CAPITALIZED') --Bug 6697231 Added capitalized fee
    AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
    AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
    AND     QUOTE.PRIMARY_QUOTE = 'Y'
    AND     LAP.ID = l_lease_app_id;

    l_adj_amount :=0;   -- added for bug 6596860 --
    -- added for bug 6596860 --
    OPEN l_adj_sum_csr(l_lease_app_id);
    FETCH l_adj_sum_csr INTO l_adj_amount;
    CLOSE l_adj_sum_csr;

    ln_amount_requested := ln_asset_cost + ln_fee_cost - l_adj_amount ; --  added for bug 6596860 --removded addon and added adj_amount

	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					ln_amount_requested;

    RETURN ln_amount_requested;
  END amount_requested ;

  ---------------------------------------------
  -- FUNCTION total_financed_amount
  ---------------------------------------------
  FUNCTION total_financed_amount(x_resultout	OUT NOCOPY VARCHAR2,
       					         x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  ln_financed_amount	NUMBER;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
    x_resultout := FND_API.G_RET_STS_SUCCESS;

    ln_financed_amount := amount_requested(x_resultout		=> 	x_resultout,
    									   x_errormsg		=>  x_errormsg);

	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					ln_financed_amount ;

    RETURN ln_financed_amount;
  END total_financed_amount ;

  ---------------------------------------------
  -- FUNCTION total_subsidized_cost
  ---------------------------------------------
  FUNCTION total_subsidized_cost(x_resultout	OUT NOCOPY VARCHAR2,
       					         x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);

  ln_subs_cost 				NUMBER;
  ln_down_payment_amount	NUMBER;
  ln_financed_amount		NUMBER;
  ln_subsidy_amount			NUMBER;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
    SELECT  NVL(SUM(ADJ.VALUE), 0)
    INTO    ln_down_payment_amount
    FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_ASSETS_B ASSET,
            OKL_COST_ADJUSTMENTS_B ADJ, OKL_LEASE_QUOTES_B QUOTE
    WHERE   ADJ.ADJUSTMENT_SOURCE_TYPE IN ('DOWN_PAYMENT', 'TRADEIN')
    AND     ADJ.PARENT_OBJECT_CODE = 'ASSET'
    AND     ADJ.PARENT_OBJECT_ID = ASSET.ID
    AND     ASSET.PARENT_OBJECT_ID = QUOTE.ID
    AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
    AND     ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
    AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
    AND     QUOTE.PRIMARY_QUOTE = 'Y'
    AND     LAP.ID = l_lease_app_id;

    x_resultout := FND_API.G_RET_STS_SUCCESS;

    ln_financed_amount := amount_requested(x_resultout		=> 	x_resultout,
    									   x_errormsg		=>  x_errormsg);

	ln_subsidy_amount  := subsidy_amount(x_resultout	=> 	x_resultout,
    									 x_errormsg		=>  x_errormsg);

	ln_subs_cost := ln_financed_amount - ln_down_payment_amount - ln_subsidy_amount;

	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value := ln_subs_cost;

    RETURN ln_subs_cost;
  END total_subsidized_cost ;

  ---------------------------------------------
  -- FUNCTION security_deposit
  ---------------------------------------------
  FUNCTION security_deposit(x_resultout	OUT NOCOPY VARCHAR2,
       					    x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_security_deposit VARCHAR2(120);

        CURSOR  cSecDeposit IS
        SELECT  FEES.FEE_AMOUNT FEE_AMOUNT
        FROM    OKL_LEASE_APPLICATIONS_B LAP, OKL_LEASE_QUOTES_B QUOTE, OKL_FEES_B FEES
        WHERE   FEES.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND     FEES.PARENT_OBJECT_ID = QUOTE.ID
        AND     QUOTE.PARENT_OBJECT_ID = LAP.ID
        AND     QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND     QUOTE.PRIMARY_QUOTE = 'Y'
        AND     FEES.FEE_TYPE = 'SEC_DEPOSIT'
        AND     LAP.ID = l_lease_app_id;


	    ln_seq_number	NUMBER :=1;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
    x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        x_resultout := FND_API.G_RET_STS_SUCCESS;

		FOR cSecDepositRec IN cSecDeposit
		LOOP
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_parent_data_point_id :=
				OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_parent_data_point_id;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_sequence_number := ln_seq_number;
			OCM_ADD_DATA_POINTS.pg_ocm_dp_values_tbl(ln_seq_number).p_data_point_value :=
	        cSecDepositRec.fee_amount;

			ln_seq_number := ln_seq_number + 1;

	   END LOOP;
		RETURN NULL;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_security_deposit := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

  END security_deposit ;

  ---------------------------------------------
  -- FUNCTION billed_tax
  ---------------------------------------------
  FUNCTION billed_tax(x_resultout	OUT NOCOPY VARCHAR2,
       				  x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_billed_tax NUMBER;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
    x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT SUM(TRXD.TAX_AMT)
        INTO l_billed_tax
        FROM
        OKL_TAX_SOURCES TXS, OKL_TAX_TRX_DETAILS TRXD, OKL_LEASE_QUOTES_B LSQ,
        OKL_LEASE_APPLICATIONS_B LAP
        WHERE
        TRXD.TXS_ID = TXS.ID
        AND TRXD.BILLED_YN = 'Y'
        AND TXS.TRX_ID = LSQ.ID
        AND TXS.TAX_CALL_TYPE_CODE = 'UPFRONT_TAX'
        AND TXS.TAX_CALL_TYPE_CODE = TRXD.TAX_CALL_TYPE_CODE
        AND TXS.ENTITY_CODE = 'OKL_LEASE_QUOTES_B'
        AND TXS.TAX_LINE_STATUS_CODE = 'ACTIVE'
        AND LSQ.PARENT_OBJECT_ID = LAP.ID
        AND LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND LAP.ID = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_billed_tax := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

		OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value :=
					l_billed_tax;

    RETURN l_billed_tax;
  END billed_tax ;

  ---------------------------------------------
  -- PROCEDURE fetch_leaseapp_datapoints
  ---------------------------------------------
  PROCEDURE fetch_leaseapp_datapoints(p_api_version     IN   NUMBER
                      				 ,p_init_msg_list   IN   VARCHAR2  DEFAULT OKL_API.G_FALSE
                      				 ,p_leaseapp_id	    IN  	NUMBER
                      				 ,x_lap_dp_tbl_type OUT NOCOPY  lap_dp_tbl_type
                      				 ,x_return_status   OUT NOCOPY  VARCHAR2
                      				 ,x_msg_count       OUT NOCOPY  NUMBER
                      				 ,x_msg_data        OUT NOCOPY  VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'fetch_leaseapp_datapoints';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

	CURSOR c_get_leaseapp_template IS
	SELECT lat.credit_review_purpose,
	       lat.cust_credit_classification
	FROM
		okl_leaseapp_templates lat,
		okl_leaseapp_templ_versions_b latv,
		okl_lease_applications_b lap
	WHERE
		lap.leaseapp_template_id = latv.id
	AND latv.version_status = 'ACTIVE'
	AND latv.valid_from <= lap.valid_from
	AND nvl(latv.valid_to, lap.valid_from) >= lap.valid_from
	AND latv.leaseapp_template_id = lat.id
	AND lap.id = p_leaseapp_id;

	lv_credit_rev_purpose		VARCHAR2(30);
	lv_credit_classification	VARCHAR2(30);

	x_data_points_tbl	OCM_DATA_POINTS_PUB.data_points_tbl;

  BEGIN
      mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    OPEN c_get_leaseapp_template;
    FETCH c_get_leaseapp_template INTO lv_credit_rev_purpose, lv_credit_classification;
    CLOSE c_get_leaseapp_template;

    OCM_DATA_POINTS_PUB.GET_DATA_POINTS(p_api_version       		=> p_api_version,
        								p_init_msg_list     		=> p_init_msg_list,
        								p_validation_level  		=> 'F',
        								p_credit_classification 	=> lv_credit_classification,
        								p_review_type           	=> lv_credit_rev_purpose,
        								p_data_point_category	    => 'ADDITIONAL',
        								p_data_point_sub_category	=> 'OKL_LAP_DATAPOINT',
        								x_return_status         	=> x_return_status,
        								x_msg_count             	=> x_msg_count,
        								x_msg_data              	=> x_msg_data,
        								p_datapoints_tbl        	=> x_data_points_tbl);
    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (x_data_points_tbl.COUNT > 0) THEN
      FOR i IN x_data_points_tbl.FIRST .. x_data_points_tbl.LAST LOOP
        IF x_data_points_tbl.EXISTS(i) THEN
          x_lap_dp_tbl_type(i).data_point_id := x_data_points_tbl(i).data_point_id;
          x_lap_dp_tbl_type(i).data_point_category := x_data_points_tbl(i).data_point_sub_category;
          x_lap_dp_tbl_type(i).data_point_name := x_data_points_tbl(i).data_point_name;
          x_lap_dp_tbl_type(i).description := x_data_points_tbl(i).description;
        END IF;
      END LOOP;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (c_get_leaseapp_template%ISOPEN) THEN
        CLOSE c_get_leaseapp_template;
      END IF;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (c_get_leaseapp_template%ISOPEN) THEN
        CLOSE c_get_leaseapp_template;
      END IF;

    WHEN OTHERS THEN
      IF (c_get_leaseapp_template%ISOPEN) THEN
        CLOSE c_get_leaseapp_template;
      END IF;

  END fetch_leaseapp_datapoints;

  ---------------------------------------------
  -- PROCEDURE store_leaseapp_datapoints
  ---------------------------------------------
  PROCEDURE store_leaseapp_datapoints(p_api_version      IN   NUMBER
                    				  ,p_init_msg_list   IN  VARCHAR2  DEFAULT OKL_API.G_FALSE
                      				  ,p_lap_dp_tbl      IN  lap_dp_tbl_type
                      				  ,x_return_status   OUT NOCOPY  VARCHAR2
                      				  ,x_msg_count       OUT NOCOPY  NUMBER
                      				  ,x_msg_data        OUT NOCOPY  VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'store_leaseapp_datapoints';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    j                      BINARY_INTEGER := 0;

    l_lap_dp_tbl		lap_dp_tbl_type;
    lx_lap_dp_tbl		lap_dp_tbl_type;

    lp_lap_dp_tbl		okl_lad_pvt.ladv_tbl_type;
    lpx_lap_dp_tbl		okl_lad_pvt.ladv_tbl_type;

    ln_index	NUMBER;

  BEGIN
     mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_lap_dp_tbl := p_lap_dp_tbl;

    IF (l_lap_dp_tbl.COUNT > 0) THEN

      FOR i IN l_lap_dp_tbl.FIRST .. l_lap_dp_tbl.LAST LOOP
        IF l_lap_dp_tbl.EXISTS(i) THEN
          lp_lap_dp_tbl(i).id := l_lap_dp_tbl(i).id;
          lp_lap_dp_tbl(i).object_version_number := l_lap_dp_tbl(i).object_version_number;
          lp_lap_dp_tbl(i).leaseapp_id := l_lap_dp_tbl(i).leaseapp_id;
          lp_lap_dp_tbl(i).data_point_id := l_lap_dp_tbl(i).data_point_id;
          lp_lap_dp_tbl(i).data_point_category := l_lap_dp_tbl(i).data_point_category;
          lp_lap_dp_tbl(i).data_point_value := l_lap_dp_tbl(i).data_point_value;
        END IF;
      END LOOP;

      ln_index := lp_lap_dp_tbl.FIRST;
      IF (lp_lap_dp_tbl(ln_index).id is null OR lp_lap_dp_tbl(ln_index).id = OKL_API.G_MISS_NUM) THEN

        okl_lad_pvt.insert_row (p_api_version   => G_API_VERSION
                               ,p_init_msg_list => G_FALSE
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_ladv_tbl       => lp_lap_dp_tbl
                               ,x_ladv_tbl       => lpx_lap_dp_tbl);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        okl_lad_pvt.update_row (p_api_version   => G_API_VERSION
                               ,p_init_msg_list => G_FALSE
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_ladv_tbl       => lp_lap_dp_tbl
                               ,x_ladv_tbl       => lpx_lap_dp_tbl);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
	  END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_ERROR;
  END store_leaseapp_datapoints;

  ---------------------------------------------
  -- PROCEDURE delete_leaseapp_datapoints
  ---------------------------------------------
  PROCEDURE delete_leaseapp_datapoints(p_api_version     IN   NUMBER
                    				  ,p_init_msg_list   IN   VARCHAR2  DEFAULT OKL_API.G_FALSE
                      				  ,p_leaseapp_id	 IN  	NUMBER
                      				  ,x_return_status   OUT NOCOPY  VARCHAR2
                      				  ,x_msg_count       OUT NOCOPY  NUMBER
                      				  ,x_msg_data        OUT NOCOPY  VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'delete_leaseapp_datapoints';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    i                      BINARY_INTEGER := 0;

    lap_dp_tbl			okl_lad_pvt.ladv_tbl_type;
    l_error_tbl_type	OKC_API.ERROR_TBL_TYPE;

	CURSOR c_get_leaseapp_datapoints IS
	SELECT id
	FROM
		okl_leaseapp_datapoints
	WHERE
		leaseapp_id = p_leaseapp_id;

  BEGIN
      mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    FOR l_get_leaseapp_datapoints IN c_get_leaseapp_datapoints LOOP
      lap_dp_tbl(i).id := l_get_leaseapp_datapoints.id;
      i := i + 1;
    END LOOP;

    IF lap_dp_tbl.COUNT > 0 THEN
      okl_lad_pvt.delete_row (
        p_api_version   => G_API_VERSION
       ,p_init_msg_list => G_FALSE
       ,x_return_status => x_return_status
       ,x_msg_count     => x_msg_count
       ,x_msg_data      => x_msg_data
       ,p_ladv_tbl      => lap_dp_tbl
	   ,px_error_tbl	=> l_error_tbl_type );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_ERROR;
  END delete_leaseapp_datapoints;

  ---------------------------------------------
  -- FUNCTION leaseapp_datapoints_exists
  ---------------------------------------------
  FUNCTION leaseapp_datapoints_exists(p_leaseapp_id	   IN  	NUMBER)
  	RETURN BOOLEAN IS

	ln_dp_count		NUMBER;

	CURSOR c_get_leaseapp_datapoints IS
	SELECT count(*)
	FROM
		okl_leaseapp_datapoints
	WHERE
		leaseapp_id = p_leaseapp_id;

  BEGIN
    mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
  	OPEN c_get_leaseapp_datapoints;
  	FETCH c_get_leaseapp_datapoints INTO ln_dp_count;
  	CLOSE c_get_leaseapp_datapoints;

  	IF (ln_dp_count > 0) THEN
  	  RETURN TRUE;
  	ELSE
  	  RETURN FALSE;
  	END IF;
  END leaseapp_datapoints_exists ;

  FUNCTION fetch_data_point_value(x_resultout	OUT NOCOPY VARCHAR2,
       				   			  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_lease_app_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
  l_data_point_id NUMBER := to_number(OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_id);

  lv_data_point_value okl_leaseapp_datapoints.data_point_value%TYPE;

  BEGIN
  mo_global.set_policy_context('S',OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_org_id);	--Bug#7030452
	x_resultout := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        SELECT  DATA_POINT_VALUE
        INTO lv_data_point_value
        FROM  OKL_LEASEAPP_DATAPOINTS
        WHERE DATA_POINT_ID = l_data_point_id
        AND   LEASEAPP_ID   = l_lease_app_id;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		lv_data_point_value := NULL;
       WHEN OTHERS THEN
			x_resultout := FND_API.G_RET_STS_UNEXP_ERROR;
			x_errormsg := sqlerrm;
	END;

	OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value := lv_data_point_value;

	RETURN lv_data_point_value;

  END fetch_data_point_value ;

END OKL_CREDIT_DATAPOINTS_PVT;

/
