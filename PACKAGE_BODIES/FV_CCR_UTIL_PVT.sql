--------------------------------------------------------
--  DDL for Package Body FV_CCR_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_CCR_UTIL_PVT" as
/* $Header: FVCCRCRB.pls 120.20.12010000.18 2010/06/17 14:56:40 snama ship $*/
G_PKG_NAME 	CONSTANT VARCHAR2(30):='FV_CCR_UTIL_PVT.';


function existing_org_context
RETURN VARCHAR2
IS
    l_ret_value VARCHAR2(10);
    l_module_name VARCHAR2(60);


BEGIN

    l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.existing_org_context';
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');

    -- Retrieve CLIENT_INFO org_id value in the performant method recommended by ATG
    SELECT DECODE(
                  SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
                  NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10)
                 )
    INTO l_ret_value
    FROM dual;

    return l_ret_value;
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');
EXCEPTION
WHEN OTHERS THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
END existing_org_context;

PROCEDURE insert_for_report
(
p_duns 		IN VARCHAR2,
p_record_type	IN NUMBER,
p_reference1	IN VARCHAR2,
p_reference2	IN VARCHAR2,
p_reference3	IN VARCHAR2,
p_reference4	IN VARCHAR2,
p_reference5	IN VARCHAR2
)
IS
	l_module_name VARCHAR2(60);
BEGIN
  l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.insert_for_report';
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');

  INSERT INTO fv_ccr_process_report
  (duns_info,record_type,reference1,reference2,reference3,reference4,reference5)
  VALUES
  (p_duns,p_record_type,p_reference1,p_reference2,p_reference3,p_reference4,
   p_reference5);

  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');
EXCEPTION
WHEN OTHERS THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
END;


/* Procedure to add supplier party id as owner party id to the bank account created */
procedure add_owner_party
(
p_account_owner_party_id IN  NUMBER,
p_bank_account_id IN NUMBER
)
IS
l_api_version CONSTANT NUMBER:= 1.0;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_response IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_joint_acct_owner_id NUMBER;
BEGIN
 IBY_EXT_BANKACCT_PUB.add_joint_account_owner(p_api_version => 1.0,
                                p_init_msg_list => FND_API.G_TRUE,
                                p_bank_account_id => p_bank_account_id,
                                p_acct_owner_party_id => p_account_owner_party_id,
                                x_joint_acct_owner_id=>l_joint_acct_owner_id,
                                x_return_status=>l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data => l_msg_data,
                                x_response => l_response);
 IF (l_joint_acct_owner_id IS NOT NULL) THEN
          IBY_EXT_BANKACCT_PUB.change_primary_acct_owner (p_api_version => 1.0,
                                p_init_msg_list => FND_API.G_TRUE,
                                p_bank_acct_id => p_bank_account_id,
                                p_acct_owner_party_id => p_account_owner_party_id,
                                x_return_status=>l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data => l_msg_data,
                                x_response => l_response);
 END IF;

END;

/* Procedure to get the payee id for the supplier site */
procedure     get_payee_id
(
p_payee_context	IN IBY_DISBURSEMENT_SETUP_PUB.PayeeContext_rec_type,
x_payee_id		OUT NOCOPY iby_external_payees_all.ext_payee_id%TYPE
)
IS
CURSOR c_payee
          (ci_party_id IN p_payee_context.Party_Id%TYPE,
           ci_party_site_id IN p_payee_context.Party_Site_id%TYPE,
           ci_supplier_site_id IN p_payee_context.Supplier_Site_id%TYPE,
           ci_org_type IN p_payee_context.Org_Type%TYPE,
           ci_org_id IN p_payee_context.Org_Id%TYPE,
           ci_pmt_function IN p_payee_context.Payment_Function%TYPE)
    IS
    SELECT ext_payee_id
      FROM iby_external_payees_all payee
     WHERE payee.PAYEE_PARTY_ID = ci_party_id
       AND payee.PAYMENT_FUNCTION = ci_pmt_function
       AND ((ci_party_site_id is NULL and payee.PARTY_SITE_ID is NULL) OR
            (payee.PARTY_SITE_ID = ci_party_site_id))
       AND ((ci_supplier_site_id is NULL and payee.SUPPLIER_SITE_ID is NULL) OR
            (payee.SUPPLIER_SITE_ID = ci_supplier_site_id))
       AND ((ci_org_id is NULL and payee.ORG_ID is NULL) OR
            (payee.ORG_ID = ci_org_id AND payee.ORG_TYPE = ci_org_type));
BEGIN
  IF (c_payee%ISOPEN) THEN
      CLOSE c_payee;
    END IF;

  OPEN c_payee(p_payee_context.Party_Id,
                 p_payee_context.Party_Site_id,
                 p_payee_context.Supplier_Site_id,
                 p_payee_context.Org_Type,
                 p_payee_context.Org_Id,
                 p_payee_context.Payment_Function );
    FETCH c_payee INTO x_payee_id;
    IF c_payee%NOTFOUND THEN x_payee_id := NULL; END IF;
    CLOSE c_payee;
END;



PROCEDURE get_vendor_name
(
p_vendor_id	IN NUMBER,
x_vendor_name	OUT NOCOPY VARCHAR2,
x_num_1099	OUT	NOCOPY VARCHAR2,
x_org_type_lkup OUT NOCOPY VARCHAR2
)
IS
l_vendor_name  VARCHAR2(120);
l_module_name VARCHAR2(60);
BEGIN
  l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.get_vendor_name';
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');

--SELECT vendor_name,num_1099 INTO x_vendor_name,x_num_1099
--FROM po_vendors WHERE vendor_id = p_vendor_id;

SELECT hzp.party_name, NVL(pav.num_1099, pav.individual_1099),
       pav.organization_type_lookup_code
INTO x_vendor_name,x_num_1099, x_org_type_lkup
FROM hz_parties hzp, ap_suppliers pav
WHERE hzp.party_id = pav.party_id
AND pav.vendor_id = p_vendor_id;

FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');
EXCEPTION
WHEN OTHERS THEN
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
x_vendor_name := null;
x_num_1099 := null;
END ;

PROCEDURE update_vendor_org_type
(
p_vendor_id IN NUMBER,
p_vend_org_type IN VARCHAR2,
x_status        OUT NOCOPY VARCHAR2,
x_exception_msg OUT NOCOPY VARCHAR2
)
IS

BEGIN
fnd_file.put_line(fnd_file.log, 'p_vendor_id: '||p_vendor_id);
fnd_file.put_line(fnd_file.log, 'p_vend_org_type: '||p_vend_org_type);

	x_status := 'E';

	UPDATE ap_suppliers
	SET organization_type_lookup_code = p_vend_org_type
	WHERE vendor_id = p_vendor_id;

	IF(SQL%NOTFOUND) THEN
	 x_exception_msg := 'No supplier found with vendor id: '||p_vendor_id;
	 x_status := 'E';
        ELSE
	x_status := 'S';
	END IF;

	EXCEPTION
	WHEN OTHERS THEN
	  x_exception_msg := 'Exception when updating vendor organization type';
	  x_status := 'U';

END update_vendor_org_type;

PROCEDURE duplicate_vendor_site_code
(
p_vendor_id IN NUMBER,
p_site_code IN VARCHAR2,
p_org_id IN NUMBER,
x_dup_site_code OUT NOCOPY VARCHAR2,
x_vendor_site_id OUT NOCOPY NUMBER,
x_duns OUT NOCOPY VARCHAR2
)
IS
l_module_name VARCHAR2(60);


CURSOR site_code_dup_csr(p_supp_id NUMBER,p_site_name VARCHAR2,p_org NUMBER) IS
--SELECT vendor_site_id,duns_number FROM
--po_vendor_sites_all
--WHERE vendor_id=p_supp_id
--AND vendor_site_code=p_site_name
--AND org_id=p_org;
SELECT pavs.vendor_site_id, hps.duns_number_c
FROM ap_supplier_sites_all pavs, hz_party_sites hps
WHERE pavs.vendor_id = p_supp_id
AND pavs.vendor_site_code = p_site_name
AND pavs.org_id = p_org
AND pavs.party_site_id = hps.party_site_id;

BEGIN
x_dup_site_code:='F';
l_module_name:='fv.plsql.FV_CCR_UTIL_PVT.duplicate_vendor_site_code';
OPEN site_code_dup_csr(p_vendor_id,p_site_code,p_org_id);
FETCH site_code_dup_csr INTO x_vendor_site_id,x_duns;
IF(site_code_dup_csr%FOUND) THEN
	x_dup_site_code:='T';
END IF;

EXCEPTION
WHEN OTHERS THEN
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,sqlerrm);

END;



PROCEDURE get_vendor_site_code
(
p_vendor_site_id IN	NUMBER,
x_site_code	 OUT NOCOPY  VARCHAR2
)
IS
l_module_name VARCHAR2(60);
BEGIN
l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.get_vendor_site_code';
SELECT vendor_site_code INTO x_site_code
--FROM po_vendor_sites_all
FROM ap_supplier_sites_all
WHERE vendor_site_id = p_vendor_site_id;
EXCEPTION
WHEN OTHERS THEN
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,sqlerrm);
END;

PROCEDURE get_vendor_id
(
p_taxpayer_number 	IN VARCHAR2,
p_legal_bus_name 	IN VARCHAR2,
p_duns			IN VARCHAR2,
p_fed_check_flag	IN VARCHAR2,
x_vendor_id		OUT NOCOPY NUMBER,
x_vendor_name		OUT NOCOPY VARCHAR2,
x_supp_num_exist	OUT NOCOPY VARCHAR2
)
IS
l_supp_num varchar2(30);
l_module_name VARCHAR2(60);
CURSOR vendor_taxp_csr(p_taxpayer varchar2) IS
--SELECT vendor_id,vendor_name FROM
--po_vendors WHERE num_1099 = p_taxpayer;
SELECT pav.vendor_id, hzp.party_name
FROM hz_parties hzp, ap_suppliers pav
WHERE (pav.num_1099 = p_taxpayer OR
       pav.individual_1099 = p_taxpayer)
AND hzp.party_id = pav.party_id;

CURSOR vendor_lbn_csr(p_legal_bus varchar2) IS
--SELECT vendor_id,vendor_name FROM
--po_vendors WHERE vendor_name = p_legal_bus;
SELECT pav.vendor_id, hzp.party_name
FROM hz_parties hzp, ap_suppliers pav
WHERE hzp.party_name = p_legal_bus
AND hzp.party_id = pav.party_id;

CURSOR vendor_supp_num_csr(p_supp_num varchar2) IS
SELECT segment1
--FROM po_vendors
FROM ap_suppliers
where segment1 = p_supp_num;


BEGIN

l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.get_vendor_id';
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');

FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_duns: '||p_duns);
FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_taxpayer_number: '||p_taxpayer_number);
FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_legal_bus_name: '||p_legal_bus_name);
FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_fed_check_flag: '||p_fed_check_flag);

IF(p_taxpayer_number IS NOT NULL AND length(p_taxpayer_number) = 9) THEN
  OPEN vendor_taxp_csr(p_taxpayer_number);

  FETCH vendor_taxp_csr INTO x_vendor_id,x_vendor_name;

  IF(vendor_taxp_csr%NOTFOUND) THEN
        x_vendor_id := null;
	x_vendor_name := null;

	IF (p_fed_check_flag='N') THEN
	  OPEN vendor_supp_num_csr(p_taxpayer_number);

	  FETCH vendor_supp_num_csr INTO l_supp_num;

	  IF(vendor_supp_num_csr%NOTFOUND) THEN
		x_supp_num_exist := 'N';
	  ELSE 	x_supp_num_exist := 'Y';
	  END IF;
	  CLOSE vendor_supp_num_csr;
	END IF;
   END IF;
   CLOSE vendor_taxp_csr;
ELSE
  OPEN vendor_lbn_csr(p_legal_bus_name);

  FETCH vendor_lbn_csr INTO x_vendor_id,x_vendor_name;

  IF(vendor_lbn_csr%NOTFOUND) THEN
        x_vendor_id := null;
	x_vendor_name := null;
	IF(p_fed_check_flag='N') THEN
	  OPEN vendor_supp_num_csr(p_duns);

	  FETCH vendor_supp_num_csr INTO l_supp_num;

	  IF(vendor_supp_num_csr%NOTFOUND) THEN
		x_supp_num_exist := 'N';
	  ELSE 	x_supp_num_exist := 'Y';
	  END IF;
	  CLOSE vendor_supp_num_csr;
	END IF;
   END IF;
   CLOSE vendor_lbn_csr;

FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');
END IF;
EXCEPTION
WHEN OTHERS THEN
fv_utility.log_mesg(' Exception in get_vendor_id.');
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
	x_vendor_id := null;
	x_vendor_name := null;
END;

PROCEDURE get_bank_branch_information
(
p_routing_num			IN VARCHAR2,
p_bank_branch_id		IN NUMBER,
x_bank_name			OUT NOCOPY VARCHAR2,
x_bank_branch_name		OUT NOCOPY VARCHAR2,
x_bank_branch_id		OUT NOCOPY NUMBER
)
IS
l_routing_num	 VARCHAR2(25);
l_bank_branch_name VARCHAR2(60);
l_bank_name	 VARCHAR2(60);
l_module_name 	 VARCHAR2(60);
CURSOR bank_branch_csr(p_routing VARCHAR2) IS
SELECT branch_party_id, bank_name, bank_branch_name
FROM ce_bank_branches_v
WHERE branch_number = p_routing
AND branch_number IS NOT NULL;
BEGIN

l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.get_bank_branch_information';
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');

   IF(nvl(p_bank_branch_id,0)<>0) THEN
	BEGIN
	SELECT bank_name,bank_branch_name,branch_number
	INTO l_bank_name,l_bank_branch_name,
	l_routing_num FROM ce_bank_branches_v
	WHERE branch_party_id = p_bank_branch_id;
	EXCEPTION
	WHEN OTHERS THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
	'Bank Branch exception for'|| p_bank_branch_id);
	l_bank_name := null;
	l_bank_branch_name := null;
	l_routing_num := null;
	END;
   END IF;
   If(l_routing_num IS NOT NULL AND p_routing_num IS NOT NULL
		AND l_routing_num = p_routing_num) THEN
		x_bank_branch_id := p_bank_branch_id;
		x_bank_name := l_bank_name;
		x_bank_branch_name := l_bank_branch_name;
   ELSIF(p_routing_num IS NOT NULL) THEN
	BEGIN
		OPEN bank_branch_csr(p_routing_num);
		fetch bank_branch_csr INTO x_bank_branch_id,
		x_bank_name,x_bank_branch_name;
		IF(bank_branch_csr%NOTFOUND) THEN
			x_bank_branch_id := null;
			x_bank_name := null;
			x_bank_branch_name := null;
		END IF;
		CLOSE bank_branch_csr;
	EXCEPTION
	WHEN OTHERS THEN
		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,sqlerrm);
		x_bank_branch_id := null;
		x_bank_name := null;
		x_bank_branch_name := null;
		CLOSE bank_branch_csr;
	END;
   ELSE
		x_bank_branch_id := null;
		x_bank_name := null;
		x_bank_branch_name := null;
   END IF;
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');
END;

PROCEDURE get_bank_account_information
(
p_bank_branch_id 		IN NUMBER,
p_bank_account_number	IN VARCHAR2,
p_bank_account_id		IN NUMBER,
p_account_type		IN VARCHAR2,
p_base_currency		IN VARCHAR2,
p_country_code          IN VARCHAR2,
x_bank_account_id		OUT NOCOPY NUMBER,
x_update_account		OUT NOCOPY VARCHAR2
)
IS
CURSOR bank_acct_csr(p_branch_id NUMBER,p_acct_number VARCHAR2,
p_currency VARCHAR2) IS
--Bug8405987
SELECT ext_bank_account_id,
     DECODE(UPPer(bank_account_type),'SAVINGS','S','CHECKING','C',bank_account_type)
FROM iby_ext_bank_accounts
WHERE branch_id = p_branch_id
AND bank_account_num = p_acct_number
AND currency_code  = p_currency
AND country_code = p_country_code;

l_bank_branch_id NUMBER;
l_bank_acct_num VARCHAR2(30);
l_bank_account_type VARCHAR2(25);
l_module_name VARCHAR2(60);
BEGIN
x_update_account:='N';
l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.get_bank_account_information';
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_bank_branch_id->'||p_bank_branch_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_bank_account_number->'||p_bank_account_number);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_bank_account_id->'||p_bank_account_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_account_type->'||p_account_type);
  BEGIN

  IF(nvl(p_bank_account_id,0)<>0) THEN
  --Bug8405987
	SELECT bank_account_num,branch_id,
  DECODE(UPPER(bank_account_type),'SAVINGS','S','CHECKING','C',bank_account_type)
	INTO l_bank_acct_num,l_bank_branch_id,
  l_bank_account_type
	FROM iby_ext_bank_accounts
	WHERE ext_bank_account_id=p_bank_account_id;
  ELSE
	l_bank_branch_id := null;
	l_bank_acct_num:= null;
  END IF;
  EXCEPTION
  WHEN OTHERS THEN
	l_bank_branch_id := null;
	l_bank_acct_num:= null;
  END;

FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_bank_branch_id->'||l_bank_branch_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_bank_acct_num->'||l_bank_acct_num);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_bank_account_type->'||l_bank_account_type);

--Bug 9112680  added space in nvl(if condition) and debug messages
 IF(l_bank_branch_id IS NOT NULL AND l_bank_acct_num IS NOT NULL
	AND l_bank_branch_id = p_bank_branch_id AND l_bank_acct_num=p_bank_account_number) THEN
	x_bank_account_id:=p_bank_account_id;
	IF(nvl(l_bank_Account_type,' ') <> nvl(p_account_type,' ')) THEN
		x_update_account:='Y';
	END IF;
 ELSIF(nvl(p_bank_branch_id,0)<>0) THEN
	OPEN bank_acct_csr(p_bank_branch_id,p_bank_account_number,p_base_currency);
	FETCH bank_acct_csr INTO x_bank_account_id,l_bank_account_type;
	IF(bank_acct_csr%NOTFOUND) THEN
		x_bank_account_id := null;
	ELSIF(nvl(l_bank_Account_type,' ') <> nvl(p_account_type,' ')) THEN
		x_update_account:='Y';
	END IF;
	CLOSE bank_acct_csr;
 ELSE
	x_bank_account_id := null;
 END IF;

FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'x_bank_account_id->'||x_bank_account_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'x_update_account->'||x_update_account);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');
EXCEPTION
WHEN OTHERS THEN
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
x_bank_account_id := null;
END;


procedure get_federal_indicator
(
p_vendor_id		IN NUMBER,
p_taxpayer_number	IN VARCHAR2,
p_legal_bus_name	IN VARCHAR2,
x_federal		OUT NOCOPY VARCHAR2
)
IS
l_api_version CONSTANT NUMBER := 1.0;
l_init_msg_list	VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(200);
l_error_code	NUMBER;
l_module_name VARCHAR2(60);
l_msg_text 	VARCHAR2(500);
l_duns		VARCHAR2(9);
l_vendor_id	NUMBER;
l_vendor_name	VARCHAR2(120);
l_supp_num_exist	VARCHAR2(1);
BEGIN
l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.get_federal_indicator';
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');

l_init_msg_list := fnd_api.g_true;


l_duns:='';
IF(nvl(p_vendor_id,0)=0) THEN
get_vendor_id(p_taxpayer_number,p_legal_bus_name,l_duns,'Y',
l_vendor_id,l_vendor_name,l_supp_num_exist);
ELSE
l_vendor_id:=p_vendor_id;
END IF;



IF(nvl(l_vendor_id,0) <> 0) THEN
	FV_CCR_GRP.is_vendor_federal
	(
  	  p_api_version    => l_api_version,
  	  p_init_msg_list  => l_init_msg_list,
  	  p_vendor_id      => l_vendor_id,
  	  x_return_status  => l_return_status,
  	  x_msg_count      => l_msg_count,
  	  x_msg_data       => l_msg_data,
  	  x_federal        => x_federal,
  	  x_error_code     => l_error_code
	);
	if(nvl(l_return_status,'E')<>FND_API.G_RET_STS_SUCCESS) THEN
  		if(l_msg_count=1) THEN
			FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,l_module_name,
			'Get Federal Indicator:' || l_msg_data);
  		else
	 		for I IN 0 .. l_msg_count
    	 		loop
	   			l_msg_data := fnd_msg_pub.get(p_encoded=>'F');
	   			FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR,l_module_name,
				'Get Federal Indicator:' || l_msg_data);
	 		end loop;
  		end if;
  		x_federal:= 'N';

	end if;
ELSE
	x_federal := 'N';
END IF;
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');
EXCEPTION
WHEN OTHERS THEN
  x_federal:= 'N';
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_EXCEPTION,l_module_name,'Get Federal Indicator:'
	|| ' Exception');
END;

/* Procedure used to create or update vendor
create or update vendor site and update bank_acct_uses table*/

PROCEDURE fv_process_vendor
(
p_ccr_id	   	IN	NUMBER				,
p_prev_ccr_id		IN	VARCHAR2 	,
p_update_type	    IN 	VARCHAR2 ,
x_return_status		OUT	NOCOPY VARCHAR2		  	,
x_msg_count		OUT	NOCOPY NUMBER				,
x_msg_data		OUT	NOCOPY VARCHAR2			,
p_bank_branch_id	IN 	NUMBER		,
p_vendor_id		IN NUMBER,
p_pay_site_id		IN NUMBER,
p_main_add_site_id	IN NUMBER,
p_enabled_flag		IN VARCHAR2,
p_main_address_flag	IN VARCHAR2,
p_taxpayer_number	IN VARCHAR2,
p_legal_bus_name	IN VARCHAR2,
p_duns			IN VARCHAR2,
p_plus4			IN VARCHAR2,
p_main_address_line1	IN VARCHAR2,
p_main_address_line2	IN VARCHAR2,
p_main_address_city		IN VARCHAR2,
p_main_address_state	IN VARCHAR2,
p_main_address_zip		IN VARCHAR2,
p_main_address_country	IN VARCHAR2,
p_pay_address_line1		IN VARCHAR2,
p_pay_address_line2		IN VARCHAR2,
p_pay_address_line3		IN VARCHAR2,
p_pay_address_city		IN VARCHAR2,
p_pay_address_state		IN VARCHAR2,
p_pay_address_zip		IN VARCHAR2,
p_pay_address_country	IN VARCHAR2,
p_old_bank_account_id	IN NUMBER,
p_new_bank_account_id	IN NUMBER,
p_bank_name			IN VARCHAR2,
p_bank_branch_name		IN VARCHAR2,
p_bank_num			IN VARCHAR2,
p_bank_account_num		IN VARCHAR2,
p_org_id			IN NUMBER,
p_update_vendor_flag	IN VARCHAR2,
p_org_name 			IN varchar2,
p_ccr_status			IN varchar2,
p_insert_vendor_flag	IN VARCHAR2,
p_prev_vendor_id		IN NUMBER,
p_file_date			IN DATE,
p_bank_conc_req_status	IN VARCHAR2,
p_header_conc_req_status IN VARCHAR2,
p_assgn_conc_req_status	IN VARCHAR2,
p_base_currency			IN VARCHAR2,
p_valid_bank_info		IN VARCHAR2,
p_federal_vendor		IN VARCHAR2,
p_created_bank_branch_id IN NUMBER,
p_created_bank_account_id IN NUMBER,
x_vendor_id			OUT NOCOPY NUMBER,
x_output			OUT NOCOPY VARCHAR2,
x_react_pay_site_code	OUT NOCOPY VARCHAR2,
x_react_main_site_code	OUT NOCOPY VARCHAR2,
x_tp_changed			OUT NOCOPY VARCHAR2,
x_vendor_name			OUT NOCOPY VARCHAR2,
p_org_type_lookup 	IN VARCHAR2,
p_remit_poc        IN VARCHAR2,
p_mail_poc IN VARCHAR2,
p_ar_us_phone IN VARCHAR2,
p_ar_fax IN VARCHAR2,
p_ar_email IN VARCHAR2,
p_ar_non_us_phone IN VARCHAR2
)
IS


l_api_name			CONSTANT VARCHAR2(30)	:= 'FV_PROCESS_VENDORS';
l_api_version           NUMBER		:= 1.0;
l_old_org_id VARCHAR2(10);
l_vendor_name varchar2(120);
l_vendor_id NUMBER;
l_supplier_number varchar2(30);
l_status varchar2(1);
l_msg varchar2(300);
l_update_bank_flag varchar2(1);
l_account_uses_insert_flag varchar2(1);
l_account_uses_upd_flag varchar2(1);
l_user_id NUMBER;
l_new_bank_account_id NUMBER;
l_bank_branch_id	NUMBER;
l_plus4 varchar2(20);
l_pay_site_flag varchar2(1);
l_pay_site_id NUMBER;
l_main_add_site_id NUMBER;
l_row_id VARCHAR2(30) := null;
l_uses_id NUMBER :=null;
l_login_id NUMBER := null;
l_supp_num_exist VARCHAR2(1);
l_num_1099 VARCHAR2(30);
l_msg_text VARCHAR2(500);
l_duns_for_report VARCHAR2(13);
l_state VARCHAR2(150);
l_province VARCHAR2(150);
l_hold_unmatched_invoices_flag  VARCHAR2(1);
l_hold_all_payments_flag   VARCHAR2(1);
l_module_name VARCHAR2(60);
l_site_code VARCHAR2(15);
l_excp_msg VARCHAR2(1000);
l_dup_site_code VARCHAR2(1);
l_duns_site_code VARCHAR2(9);
l_site_id_site_code NUMBER;
l_uses_reln_exists VARCHAR2(1);
l_end_date DATE;
l_header_conc_req_status VARCHAR2(1);
l_assgn_conc_req_status VARCHAR2(1);
e_supp_exception EXCEPTION;

l_party_site_id NUMBER;

l_org_type_lookup po_lookup_codes.lookup_code%TYPE;

l_legal_bus_name ap_suppliers.vendor_name%TYPE;
l_count NUMBER;


 /*Added for bug  9320586 Starting*/
  l_supplier_sites_count NUMBER;
  l_ss_address_line1     VARCHAR2(240);
  l_ss_address_line2     VARCHAR2(240);
  l_ss_address_line3     VARCHAR2(240);
  l_ss_address_line_alt  VARCHAR2(240);
  l_ss_address_city      VARCHAR2(60);
  l_ss_address_state     VARCHAR2(150);
  l_ss_address_zip       VARCHAR2(60);
  l_ss_address_country   VARCHAR2(60);
  l_ss_vendor_site_id  NUMBER;
  l_change_pay_site_flg VARCHAR2(2) :='N';
  /*Cursor to get the existing address for a DUNS*/

  CURSOR existing_site_address(p_exist_vendor_id NUMBER, p_existing_vendor_site_code VARCHAR2, p_existing_org_id NUMBER)
  IS
     SELECT vendor_site_id,
     address_line1,
      address_line2      ,
      address_line3      ,
      address_lines_alt  ,
      city               ,
      state              ,
      country            ,
      zip
       FROM ap_supplier_sites_all
      WHERE vendor_id   =p_exist_vendor_id
    AND vendor_site_code=p_existing_vendor_site_code
    AND org_id          =p_existing_org_id;

 /*  Code for bug 9320586 Ending */


l_affected_inv_cnt number := 0;
l_update_tin_prf varchar2(3) := 'No';
l_vendor_cnt number := 0;
l_update_tin_flg varchar2(3) := 'No';

BEGIN

l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.fv_process_vendor';
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'----------------------------------------------');
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Some of the Parameters: ');

FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_ccr_id: '||p_ccr_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_prev_ccr_id: '||p_prev_ccr_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_update_type: '|| p_update_type);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_bank_branch_id: '||p_bank_branch_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_vendor_id: '||p_vendor_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_pay_site_id: '||p_pay_site_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_main_add_site_id: '||p_main_add_site_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_enabled_flag: '||p_enabled_flag);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_main_address_flag: '||p_main_address_flag);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_taxpayer_number: '||p_taxpayer_number);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_legal_bus_name: '||p_legal_bus_name);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_duns: '||p_duns);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_plus4: '||p_plus4);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_old_bank_account_id: '||p_old_bank_account_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_new_bank_account_id: '||p_new_bank_account_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_bank_name: '||p_bank_name);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_bank_branch_name: '||p_bank_branch_name);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_bank_num: '||p_bank_num);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_bank_account_num: '||p_bank_account_num);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_org_id: '||p_org_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_update_vendor_flag: '||p_update_vendor_flag);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_ccr_status: '||p_ccr_status);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_insert_vendor_flag: '||p_insert_vendor_flag);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_prev_vendor_id: '||p_prev_vendor_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_file_date: '||p_file_date);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_bank_conc_req_status: '||p_bank_conc_req_status);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_header_conc_req_status: '||p_header_conc_req_status);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_assgn_conc_req_status: '||p_assgn_conc_req_status);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_base_currency: '||p_base_currency);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_valid_bank_info: '||p_valid_bank_info);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_federal_vendor: '||p_federal_vendor);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_created_bank_branch_id: '||p_created_bank_branch_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name, 'p_created_bank_account_id: '||p_created_bank_account_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'----------------------------------------------');


l_legal_bus_name := p_legal_bus_name;
    -- Bug 6238816.  If a vendor with the same name exists,
    -- then append the duns number to the vendor name.
    BEGIN
        l_count := 0;

        SELECT 1
        INTO   l_count
        FROM   ap_suppliers
        WHERE  vendor_name = l_legal_bus_name
        AND    num_1099 <> p_taxpayer_number;

        fv_utility.log_mesg('Another vendor exists with the same
                                name as : '||l_legal_bus_name);
        fv_utility.log_mesg('Appending duns number to '||l_legal_bus_name||
                               ' to keep the name unique.');

        l_legal_bus_name := SUBSTR(l_legal_bus_name,1,231)||p_duns;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN OTHERS THEN
           l_msg_text := l_module_name||': When others error: Error Code:'||SQLCODE||' Error Text:'||SQLERRM;
           FV_UTILITY.LOG_MESG(l_msg_text);
           x_return_status := FND_API.G_RET_STS_ERROR ;
           insert_for_report(l_duns_for_report,19,l_msg_text||nvl(l_excp_msg,''),null,null,null,null);
           RETURN;
    END;




l_dup_site_code:='F';
l_user_id := fnd_global.user_id;
l_login_id := fnd_global.login_id;
l_account_uses_insert_flag := 'N'; --  Do not insert bank acct uses
l_account_uses_upd_flag := 'N';    -- Do not update bank acct uses
l_bank_branch_id := p_bank_branch_id;

IF(nvl(p_bank_conc_req_status,'C')='E') THEN
	l_assgn_conc_req_status:='E';
ELSE
	l_assgn_conc_req_status:='C';
END IF;
l_header_conc_req_status := 'C';

l_duns_for_report := p_duns || nvl(p_plus4,'');

IF(nvl(p_enabled_flag,'Y') = 'N') THEN
	l_hold_unmatched_invoices_flag:='N';
	l_hold_all_payments_flag:='N';
ELSE
	l_hold_unmatched_invoices_flag:=null;
	l_hold_all_payments_flag:=null;
END IF;

FND_MSG_PUB.initialize;


--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;


-- Get the site id if they exist


l_pay_site_id := p_pay_site_id;
l_main_add_site_id := p_main_add_site_id;


-- Process if the record is new or updated

IF (p_ccr_status='A') THEN

-- If bank account id new is null then new account is created and row in acct uses
-- should be created also get account id

  if(p_valid_bank_info='Y'  AND
	(p_new_bank_account_id IS NULL OR p_new_bank_account_id = 0)) THEN

         /* If the bank account id does not in ccr extension tables and got created in Java CP
           then use the created bank account and bank branch id */
        l_new_bank_account_id := p_created_bank_account_id;
        l_bank_branch_id := p_created_bank_branch_id;

	  IF(l_new_bank_account_id IS NULL) THEN
		l_new_bank_account_id :=0;
		l_assgn_conc_req_status:='E';
	  ELSE
	    l_account_uses_insert_flag := 'I';
	    insert_for_report(l_duns_for_report,15,null,'CCR SUPPLIER BANK '
		|| l_duns_for_report,p_bank_branch_name,null,null);
	  END IF;
  ELSIF(p_valid_bank_info='Y') THEN
	  l_new_bank_account_id := p_new_bank_account_id;
  	  l_account_uses_insert_flag := 'U'; -- Update bank acct uses if relation already exist
  ELSE
	  l_new_bank_account_id:=0;
	  l_bank_branch_id:=null;
  END IF;

-- Update bank branch id in extension tables only once per ccr_id.

  IF(p_ccr_id <> p_prev_ccr_id) THEN
        IF(nvl(l_bank_branch_id,0) = 0) THEN
		l_bank_branch_id := null;
		IF(p_federal_vendor='N') THEN
			l_header_conc_req_status := 'E';
		END IF;
	END IF;
        IF(p_bank_branch_id =0 AND l_bank_branch_id IS NOT NULL) THEN
		insert_for_report(l_duns_for_report,14,null,p_bank_branch_name,
		p_bank_num,null,null);
	END IF;

  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
       'Updating fv_ccr_vendors with bank_branch_id: '||l_bank_branch_id);

	UPDATE fv_ccr_vendors
	SET bank_branch_id = l_bank_branch_id
	,enabled ='Y',last_update_date=sysdate,
	last_updated_by=l_user_id,last_update_login=l_login_id
	WHERE ccr_id = p_ccr_id;
  END IF;


-- If old bank acct id is same as new bank acct id no need to
-- update bank acct uses table
  if(nvl(p_old_bank_account_id,0)<>0 AND
	p_old_bank_account_id <> l_new_bank_account_id)THEN
	l_account_uses_upd_flag := 'Y';
  END IF;

-- Do not update vendor for duns4 record for which
-- p_update_vendor_flag='N'

  IF (p_update_vendor_flag = 'Y') THEN

-- Get the vendor id if it already exists

	IF(p_vendor_id <> 0) THEN

		/* Changed the reference to US from USA */
		IF(p_main_address_country = 'US' AND
		(p_taxpayer_number IS NULL or length(p_taxpayer_number)<>9)) THEN
			get_vendor_name(p_vendor_id,l_vendor_name,l_num_1099,l_org_type_lookup);
			FND_MESSAGE.SET_NAME('FV','FV_CCR_TAXPAYER_CHANGE_INVALID');
			FND_MESSAGE.SET_TOKEN('SUPPLIER',l_vendor_name);
			l_msg_text := FND_MESSAGE.GET;
		    	insert_for_report(p_duns,18,l_msg_text,null,null,null,null);
			FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,l_msg_text);
			l_vendor_id := p_vendor_id;
		ELSE
			get_vendor_name(p_vendor_id,l_vendor_name,l_num_1099,l_org_type_lookup);
			IF(nvl(l_pay_site_id,0)=0 AND
			l_num_1099 <> p_taxpayer_number) THEN
			  FND_MESSAGE.SET_NAME('FV','FV_CCR_DUNS_TAXPAYER_ASSIGN');
			  FND_MESSAGE.SET_TOKEN('SUPPLIER',l_vendor_name);
			  l_msg_text := FND_MESSAGE.GET;
			  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				l_module_name,l_msg_text);
			  insert_for_report(p_duns,16,l_msg_text,null,
				null,null,null);
			ELSIF(l_num_1099 <> p_taxpayer_number) THEN

			    l_update_tin_prf := get_profile_option('FV_CCR_UPDATE_TIN');

			    select count(*) into l_vendor_cnt
                from fv_ccr_vendors fcv, fv_ccr_orgs fco
                where fcv.ccr_id = fco.ccr_id
                and fcv.DUNS <> p_duns and fcv.vendor_id = p_vendor_id
                and (fco.pay_site_id is not null or fco.MAIN_ADDRESS_SITE_ID is not null);

			    if ((nvl(l_update_tin_prf, 'No') <> 'Yes') or (l_vendor_cnt > 0))then
    			    l_update_tin_flg := 'No';
                    FND_MESSAGE.SET_NAME('FV','FV_CCR_TAXPAYER_NUM_CHANGED_N');
	     			FND_MESSAGE.SET_TOKEN('DUNS',p_duns);
	     			FND_MESSAGE.SET_TOKEN('VENDOR',l_vendor_name);
		    		l_msg_text := FND_MESSAGE.GET;

                elsif nvl(l_update_tin_prf, 'No') = 'Yes' then

                    l_update_tin_flg := 'Yes';
                    FND_MESSAGE.SET_NAME('FV','FV_CCR_TAXPAYER_NUM_CHANGED_Y');
	      			FND_MESSAGE.SET_TOKEN('DUNS',p_duns);
	     			FND_MESSAGE.SET_TOKEN('VENDOR',l_vendor_name);
	       			l_msg_text := FND_MESSAGE.GET;
                end if;

              --  FND_MESSAGE.SET_NAME('FV','FV_CCR_TAXPAYER_NUM_CHANGED'); Bug 9179317
		--		FND_MESSAGE.SET_TOKEN('DUNS',p_duns);
		--		l_msg_text := FND_MESSAGE.GET;
				FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				l_module_name,l_msg_text);
			    insert_for_report(p_duns,16,l_msg_text,null,
				null,null,null);
				x_vendor_name := l_vendor_name;
			END IF;

			l_vendor_id := p_vendor_id;


		IF (p_org_type_lookup IS NOT NULL) AND
          (NVL(l_org_type_lookup,'-XXX') <> p_org_type_lookup) THEN
        FND_MESSAGE.SET_NAME('FV','FV_CCR_ORG_LKUP_CHANGED');
				FND_MESSAGE.SET_TOKEN('OLDORGTYPE',l_org_type_lookup);
        FND_MESSAGE.SET_TOKEN('NAME', l_vendor_name);
        FND_MESSAGE.SET_TOKEN('TIN', l_num_1099);
        FND_MESSAGE.SET_TOKEN('NEWORGTYPE', p_org_type_lookup);
        FND_MESSAGE.SET_TOKEN('DUNS', p_duns);
				l_msg_text := FND_MESSAGE.GET;

				FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,
				l_module_name,l_msg_text);
			    insert_for_report(p_duns,16,l_msg_text,null,
				null,null,null);
				x_vendor_name := l_vendor_name;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updating org type with: '||p_org_type_lookup);
        update_vendor_org_type(
                               p_vendor_id => l_vendor_id,
                               p_vend_org_type => p_org_type_lookup,
                               x_status => l_status,
                               x_exception_msg => l_msg);

		    IF(nvl(l_status,'F')<>'S') THEN
					RAISE e_supp_exception;
		    END IF;

      END IF;

            IF l_update_tin_flg = 'Yes' then
			BEGIN
			    l_msg := null;

          FV_CCR_UTIL_PVT.update_vendor(
           p_vendor_id=>l_vendor_id,
           p_taxpayer_id=>p_taxpayer_number,
           x_status =>l_status,
           x_exception_msg=>l_msg);
				--p_calling_source=>'CCRImport');

			    IF(nvl(l_status,'F')<>'S') THEN
					RAISE e_supp_exception;
			    END IF;
			EXCEPTION
			WHEN OTHERS THEN
				l_header_conc_req_status := 'E';
				IF(l_msg IS NULL) THEN
					l_excp_msg := FND_MESSAGE.GET;
				ELSE
					l_excp_msg := l_msg;
				END IF;
				FND_MESSAGE.SET_NAME('FV','FV_CCR_VENDOR_UPDATE');
				FND_MESSAGE.SET_TOKEN('VENDORNAME',l_vendor_name);
				l_msg_text := FND_MESSAGE.GET;
				FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,
				l_module_name,l_msg_text||'Error Code:' ||
				SQLCODE ||' Error Text:' || SQLERRM);
			        insert_for_report(p_duns,19,l_msg_text||nvl(l_excp_msg,''),null,null
				,null,null);

				IF 	FND_MSG_PUB.Check_Msg_Level
				(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
				THEN
        				FND_MSG_PUB.Add_Exc_Msg
    	    				(	G_PKG_NAME  	    ,
    	    					l_api_name
	    				);
				END IF;
			END;
			end if;
		END IF;
		BEGIN
			UPDATE fv_ccr_vendors
			SET vendor_id = p_vendor_id,
			last_update_date=sysdate,
			last_updated_by =l_user_id,
      last_update_login=l_login_id
			WHERE DUNS=p_duns;
		EXCEPTION
		WHEN OTHERS THEN
			l_header_conc_req_status := 'E';
			FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
		END;


	ELSE
	  	IF(p_taxpayer_number IS NOT NULL
		 AND length(p_taxpayer_number)=9 ) THEN
			  l_supplier_number := p_taxpayer_number;
		else
			  l_supplier_number := p_duns;
		END IF;
		IF(p_insert_vendor_flag = 'N' AND p_prev_vendor_id <> 0) THEN
		 	l_vendor_id := p_prev_vendor_id;
			get_vendor_name(l_vendor_id,l_vendor_name,l_num_1099,l_org_type_lookup);
                    	FND_MESSAGE.SET_NAME('FV','FV_CCR_VENDOR_TAXPAYER_EXIST');
			FND_MESSAGE.SET_TOKEN('SUPPLIER',l_vendor_name);
			l_msg_text := FND_MESSAGE.GET;
			FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
			l_module_name,l_msg_text);
			insert_for_report(p_duns,16,l_msg_text,null,null,null,null);
		ELSE
			--get_vendor_id(p_taxpayer_number,p_legal_bus_name,p_duns,'N',
      get_vendor_id(p_taxpayer_number,l_legal_bus_name,p_duns,'N',
				l_vendor_id,l_vendor_name,l_supp_num_exist);
fv_utility.log_mesg('l_vendor_id: '||l_vendor_id);
fv_utility.log_mesg('l_vendor_name: '||l_vendor_name);
fv_utility.log_mesg('l_supp_num_exist: '||l_supp_num_exist);

			IF(l_vendor_id IS NULL) THEN
				l_vendor_id :=0;

			  IF(l_supp_num_exist IS NOT NULL
			   AND l_supp_num_exist = 'Y') THEN
				FND_MESSAGE.SET_NAME('FV','FV_CCR_VENDOR_NUM_EXIST');
				FND_MESSAGE.SET_TOKEN('NUM',l_supplier_number);
				l_msg_text:= FND_MESSAGE.GET;
				FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
				l_module_name,l_msg_text);
				insert_for_report(p_duns,18,l_msg_text,null,
				null,null,null);
				l_supplier_number := null;

			  END IF;
			ELSE
			  IF(p_taxpayer_number IS NOT NULL) THEN
			    	FND_MESSAGE.SET_NAME('FV','FV_CCR_VENDOR_TAXPAYER_EXIST');
				FND_MESSAGE.SET_TOKEN('SUPPLIER',l_vendor_name);
				l_msg_text := FND_MESSAGE.GET;
				FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT
				,l_module_name,l_msg_text);
				insert_for_report(p_duns,16,l_msg_text,null,null
				,null,null);
			  END IF;
			END IF;

	        END IF;

		/*** If vendor id does not exist create the vendor else update the vendor ***/
		if(l_vendor_id IS NULL OR l_vendor_id = 0 ) THEN

		  BEGIN
			l_msg := null;
fv_utility.log_mesg('before calling insert_vendor');
                    FV_CCR_UTIL_PVT.insert_vendor
                   (
                        --p_vendor_name => p_legal_bus_name,
                        p_vendor_name => l_legal_bus_name,
                        p_taxpayer_id => p_taxpayer_number,
                        p_supplier_number=>l_supplier_number,
		                    p_org_type_lookup_code => p_org_type_lookup,
                        x_vendor_id =>l_vendor_id,
                        x_status=>l_status,
                        x_exception_msg=>l_msg);

fv_utility.log_mesg('after calling insert_vendor');
fv_utility.log_mesg('l_vendor_id: '||l_vendor_id);
fv_utility.log_mesg('l_status: '||l_status);
fv_utility.log_mesg('l_msg: '||l_msg);


		    IF(nvl(l_status,'F')<> 'S' OR l_vendor_id IS NULL) THEN
				  RAISE e_supp_exception;
fv_utility.log_mesg('raised e_supp_exception');
			  END IF;
			--insert_for_report(p_duns,12,null,p_legal_bus_name,
      insert_for_report(p_duns,12,null,l_legal_bus_name,
			p_taxpayer_number,null,null);
			IF(p_vendor_id = 0) THEN
				UPDATE fv_ccr_vendors
				SET vendor_id =l_vendor_id,
				last_update_date=sysdate,
				last_updated_by=l_user_id,
				last_update_login=l_login_id
				WHERE DUNS = p_duns;
  			END IF;
		  EXCEPTION
		  WHEN OTHERS THEN
			l_header_conc_req_status := 'E';
			IF(l_msg IS NULL) THEN
	 			l_excp_msg := FND_MESSAGE.GET;
			ELSE
				l_excp_msg := l_msg;
			END IF;
			FND_MESSAGE.SET_NAME('FV','FV_CCR_VENDOR_INSERT');
			--FND_MESSAGE.SET_TOKEN('LEGALBUSNAME',p_legal_bus_name);
      FND_MESSAGE.SET_TOKEN('LEGALBUSNAME',l_legal_bus_name);
			l_msg_text := FND_MESSAGE.GET ;
			FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
			l_msg_text||' Error Code:' || SQLCODE ||' Error Text:'
			 || SQLERRM);
			insert_for_report(p_duns,19,l_msg_text||nvl(l_excp_msg,''),null,null,null,null);
			if(l_new_bank_account_id IS NOT NULL AND
				l_new_bank_account_id<>0) THEN
				UPDATE fv_ccr_orgs
				SET bank_account_id = l_new_bank_account_id,
				last_update_date=sysdate,
				last_updated_by=l_user_id,
				last_update_login=l_login_id
				WHERE ccr_id = p_ccr_id
				AND org_id=p_org_id;
			END IF;
			 IF(p_header_conc_req_status = 'S' AND p_ccr_id <> p_prev_ccr_id) THEN
					UPDATE fv_ccr_vendors
					SET conc_request_status=l_header_conc_req_status,
					last_update_date=sysdate,
					last_updated_by=l_user_id,
  					last_update_login=l_login_id
					WHERE ccr_id=p_ccr_id;
  			 END IF;
			RAISE;
		  END;
		ELSE
			BEGIN
			UPDATE fv_ccr_vendors
			SET vendor_id =l_vendor_id,
			last_update_date=sysdate,
			last_updated_by=l_user_id,
			last_update_login=l_login_id
			WHERE DUNS = p_duns;

			EXCEPTION
			WHEN OTHERS THEN
				l_header_conc_req_status := 'E';
				FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
			END;
		END IF;

    END IF;



  ELSE
	--This is the case where DUNS4 is newly inserted and
	--does not have vendor_id update it with DUNS/DUNS4
	--vendor id
	IF(nvl(p_vendor_id,0)<>0) THEN
		l_vendor_id:=p_vendor_id;
	ELSE
		l_vendor_id := p_prev_vendor_id;
	END IF;
  END IF;
  x_vendor_id := l_vendor_id;

  IF(nvl(l_vendor_id,0)<>0 AND l_vendor_name IS NULL) THEN
	get_vendor_name(l_vendor_id,l_vendor_name,l_num_1099,l_org_type_lookup);
  END IF;

  BEGIN
  IF(p_main_address_country = 'CAN') THEN
	l_state := null;
	l_province := p_main_address_state;
  ELSE
	l_state := p_main_address_state;
	l_province:=null;
  END IF;

  l_main_add_site_id := p_main_add_site_id;
  IF(p_main_address_flag = 'Y' and nvl(l_vendor_id,0)<>0 and
      nvl(p_main_add_site_id,0) = 0) THEN

    l_plus4 := 'LOC'||p_duns;
    duplicate_vendor_site_code(l_vendor_id,l_plus4,p_org_id,l_dup_site_code,
						l_main_add_site_id,l_duns_site_code);
    IF(nvl(l_dup_site_code,'F') = 'T') THEN
       IF(l_duns_site_code IS NOT NULL AND l_duns_site_code<>p_duns) THEN
		l_main_add_site_id:=0;
       END IF;
    END IF;
  END IF;

  IF(p_main_address_flag = 'Y' AND nvl(l_main_add_site_id,0) = 0
   AND nvl(l_vendor_id,0) <>0 ) THEN


   l_plus4 := 'LOC'||p_duns;

   IF(nvl(l_dup_site_code,'F') = 'T') THEN
	l_assgn_conc_req_status := 'E';
	FND_MESSAGE.SET_NAME('FV','FV_CCR_SITE_CODE_EXISTS');
        FND_MESSAGE.SET_TOKEN('ORGNAME',p_org_name);
	FND_MESSAGE.SET_TOKEN('DEFAULTCODE',l_plus4);
	l_msg_text := FND_MESSAGE.GET;
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT
				,l_module_name,l_msg_text);
	insert_for_report(p_duns,16,l_msg_text,null,null
				,null,null);
    ELSE
     l_msg := null;

     FV_CCR_UTIL_PVT.insert_vendor_site(
      p_vendor_site_code=>l_plus4,
      p_vendor_id=>l_vendor_id ,
      p_org_id =>p_org_id,
      p_address_line1=>p_main_address_line1,
      p_address_line2=>p_main_address_line2,
      p_address_line3=>null,
      p_address_line4=>null,
      p_city=>p_main_address_city,
      p_state=>l_state,
      p_zip=>p_main_address_zip,
      p_province=>l_province,
      p_country=>p_main_address_country,
      p_duns_number=>p_duns,
      p_pay_site_flag=> NULL,
      p_hold_unvalidated_inv_flag=>'N',
      p_hold_all_payments_flag=>'N',
      p_us_phone => NULL,
      p_fax => NULL,
      p_email => NULL,
      p_non_us_phone => NULL,
      p_purchasing_site_flag => 'Y',
      x_vendor_site_id=>l_main_add_site_id,
      x_party_site_id => l_party_site_id,
      x_status=>l_status,
      x_exception_msg=>l_msg);

      IF(nvl(l_status,'F')<> 'S' OR l_main_add_site_id IS NULL) THEN
		RAISE e_supp_exception;
      END IF;

      -- Added for bug 6238518
      IF (l_status = 'S') THEN
         IF NVL(p_main_address_flag,'N') = 'Y' THEN
            fv_utility.log_mesg('Updating mail poc for main site id:'||l_party_site_id);
            UPDATE hz_party_sites
            SET    addressee = p_mail_poc
            WHERE  party_site_id = l_party_site_id;
         END IF;
      END IF;


      --IF(l_vendor_name IS NULL) THEN l_vendor_name := p_legal_bus_name; END IF;
      IF(l_vendor_name IS NULL) THEN l_vendor_name := l_legal_bus_name; END IF;
       insert_for_report(l_duns_for_report,13,null,l_plus4,l_vendor_name,'M',null);
    END IF;
  ELSIF (p_main_address_flag = 'Y' AND nvl(l_main_add_site_id,0) <> 0) THEN

    l_msg := null;

    FV_CCR_UTIL_PVT.update_vendor_site(
    p_vendor_site_code =>null,
    p_vendor_site_id=>l_main_add_site_id,
    p_org_id => p_org_id,
    p_address_line1=>p_main_address_line1,
    p_address_line2=>p_main_address_line2,
    p_address_line3=>null,
    p_address_line4=>null,
    p_city=>p_main_address_city,
    p_state=>l_state,
    p_zip=>p_main_address_zip,
    p_province=>l_province, --To be populated for canadian vendors.
    p_country=>p_main_address_country,
    p_duns_number=>p_duns,
    p_pay_site_flag => NULL,
    p_hold_unvalidated_inv_flag=>l_hold_unmatched_invoices_flag,
    p_hold_all_payments_flag=>l_hold_all_payments_flag,
    p_us_phone => NULL,
    p_fax =>  NULL,
    p_email => NULL,
    p_non_us_phone => NULL,
    p_purchasing_site_flag => 'Y',
    x_party_site_id => l_party_site_id,
    x_status=>l_status,
    x_exception_msg=>l_msg);
    --p_calling_source=>'CCRImport');

    IF(nvl(l_status,'F') <> 'S' ) THEN
	    RAISE e_supp_exception;
    END IF;

    -- Added for bug 6238518
    IF (l_status = 'S') THEN
       IF NVL(p_main_address_flag,'N') = 'Y' THEN
          fv_utility.log_mesg('Updating mail poc for main site id: '||l_party_site_id);
          UPDATE hz_party_sites
          SET    addressee = p_mail_poc
          WHERE  party_site_id = l_party_site_id;
       END IF;
    END IF;

    IF(p_enabled_flag = 'N') THEN
	get_vendor_site_code(p_main_add_site_id,x_react_main_site_code);
    END IF;


  END IF;
  EXCEPTION
  WHEN OTHERS THEN
    l_assgn_conc_req_status := 'E';
    IF(l_msg IS NULL) THEN
    	l_excp_msg := FND_MESSAGE.GET;
    ELSE
	l_excp_msg := l_msg;
    END IF;
    IF(nvl(l_main_add_site_id,0) = 0) THEN
      FND_MESSAGE.SET_NAME('FV','FV_CCR_MAIN_SITE_INSERT');
      FND_MESSAGE.SET_TOKEN('DUNS',l_duns_for_report);
      l_msg_text := FND_MESSAGE.GET;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,l_msg_text||
	' Error Code:' || SQLCODE ||' Error Text:' || SQLERRM);
      insert_for_report(l_duns_for_report,19,l_msg_text||nvl(l_excp_msg,''),null,null,null,null);
    ELSE
      FND_MESSAGE.SET_NAME('FV','FV_CCR_MAIN_SITE_UPDATE');
      get_vendor_site_code(p_main_add_site_id,l_site_code);
      FND_MESSAGE.SET_TOKEN('VENDORSITECODE',l_site_code);
      l_msg_text := FND_MESSAGE.GET;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,l_msg_text||
	' Error Code:' || SQLCODE ||' Error Text:' || SQLERRM);
      insert_for_report(l_duns_for_report,19,l_msg_text||nvl(l_excp_msg,''),null,null,null,null);
    END IF;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
  	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;
  END;


-- l_plus4 will serve as site code for vendor site

  IF(p_plus4 IS NOT NULL) THEN
		l_plus4 := p_duns || p_plus4;
  ELSE
		l_plus4:= p_duns;
  END IF;
  IF(p_pay_address_country = 'CAN') THEN
	l_state := null;
	l_province := p_pay_address_state;
  ELSE
	l_state := p_pay_address_state;
	l_province:=null;
  END IF;


/*  Code for bug 9320586 Starting ********** */
    /*Validating Address of Supplier site
    */
    BEGIN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Before address comparision: whether new and old site address same or not -> ');
      IF(NVL(l_vendor_id,0) <> 0 AND NVL(p_pay_site_id,0) <> 0) THEN
         SELECT COUNT(*)
           INTO l_supplier_sites_count
           FROM ap_supplier_sites_all
          WHERE vendor_id=l_vendor_id
        AND org_id       =p_org_id;

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_supplier_sites_count-> '||l_supplier_sites_count);
        IF (l_supplier_sites_count >1) THEN
          FOR esa_rec             IN existing_site_address(l_vendor_id,p_duns,p_org_id)
          LOOP
            l_ss_address_line1    :=esa_rec.address_line1;
            l_ss_address_line2    :=esa_rec.address_line2;
            l_ss_address_line3    :=esa_rec.address_line3;
            l_ss_address_line_alt :=esa_rec.address_lines_alt;
            l_ss_address_city     :=esa_rec.city;
            l_ss_address_state    :=esa_rec.state;
            l_ss_address_zip      :=esa_rec.zip;
            l_ss_address_country  :=esa_rec.country;
            l_ss_vendor_site_id   :=esa_rec.vendor_site_id;
          END LOOP;
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_ss_vendor_site_id-> '||l_ss_vendor_site_id);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_ss_address_line1-> '||l_ss_address_line1);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_ss_address_line2-> '||l_ss_address_line2);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_ss_address_line3-> '||l_ss_address_line3);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_ss_address_city-> '||l_ss_address_city);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_ss_address_state-> '||l_ss_address_state);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_ss_address_country-> '||l_ss_address_country);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_ss_address_zip-> '||l_ss_address_zip);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_pay_address_line1-> '||p_pay_address_line1);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_pay_address_line2-> '||p_pay_address_line2);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_pay_address_city-> '||p_pay_address_city);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_pay_address_state-> '||p_pay_address_state);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_pay_address_zip-> '||p_pay_address_zip);
          FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_pay_address_country-> '||p_pay_address_country);
          IF (l_ss_address_line1 <> p_pay_address_line1 OR l_ss_address_city <> p_pay_address_city
              OR l_ss_address_state <>p_pay_address_state OR l_ss_address_zip <> p_pay_address_zip
              OR l_ss_address_country <> p_pay_address_country) THEN
            l_change_pay_site_flg:='Y';
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_change_pay_site_flg-> '||l_change_pay_site_flg);

           /*Inactivating the external payee account created using this old supplier site*/
           Begin

           update iby_external_payees_all
            set inactive_date=sysdate
            where supplier_site_id=l_ss_vendor_site_id
            AND   org_id     = p_org_id;
            exception
            when others then
               FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,l_msg_text|| ' Error Code:' || SQLCODE ||' Error Text:' || SQLERRM);
           end;


           Begin
            update iby_pmt_instr_uses_all
            set end_date=sysdate
            where ext_pmt_party_id in
                  (select distinct ext_payee_id from iby_external_payees_all
                   where supplier_site_id=l_ss_vendor_site_id
                   and org_id     = p_org_id);

            exception
            when others then
               FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,l_msg_text|| ' Error Code:' || SQLCODE ||' Error Text:' || SQLERRM);
           end;

             UPDATE ap_supplier_sites_all
             SET inactive_date = sysdate,
                 vendor_site_code='old_'||p_duns
              WHERE duns_number=p_duns
              AND   vendor_id  =l_vendor_id
              AND   org_id     = p_org_id;
           END IF;
        END IF;
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,l_msg_text|| ' Error Code:' || SQLCODE ||' Error Text:' || SQLERRM);
    END;
    -- Commented for testing Address update bug
    IF(((l_change_pay_site_flg='Y') OR (NVL(p_pay_site_id,0) = 0)) AND NVL(l_vendor_id,0) <> 0) THEN

   /*  Code for bug 9320586 Ending */

  --  Commented for testing Address IF(nvl(p_pay_site_id,0) = 0 AND nvl(l_vendor_id,0) <> 0)THEN
  BEGIN
   duplicate_vendor_site_code(l_vendor_id,l_plus4,p_org_id,l_dup_site_code,
     l_site_id_site_code,l_duns_site_code);
   IF(nvl(l_dup_site_code,'F') = 'T') THEN
	l_assgn_conc_req_status := 'E';
	FND_MESSAGE.SET_NAME('FV','FV_CCR_SITE_CODE_EXISTS');
        FND_MESSAGE.SET_TOKEN('ORGNAME',p_org_name);
	FND_MESSAGE.SET_TOKEN('DEFAULTCODE',l_plus4);
	l_msg_text := FND_MESSAGE.GET;
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT
				,l_module_name,l_msg_text);
	insert_for_report(p_duns,16,l_msg_text,null,null
				,null,null);
	l_account_uses_insert_flag := 'N';
        l_account_uses_upd_flag := 'N';
   ELSE
    l_pay_site_flag := 'Y';
    l_msg := null;

    FV_CCR_UTIL_PVT.insert_vendor_site(
     p_vendor_site_code=>l_plus4,
     p_vendor_id=>l_vendor_id ,
     p_org_id =>p_org_id,
     p_address_line1=>p_pay_address_line1,
     p_address_line2=>p_pay_address_line2,
     p_address_line3=>p_pay_address_line3,
     p_address_line4=>null,
     p_city=>p_pay_address_city,
     p_state=>l_state,
     p_zip=>p_pay_address_zip,
     p_province=>l_province,
     p_country=>p_pay_address_country,
     p_duns_number=>p_duns,
     p_pay_site_flag=>l_pay_site_flag,
     p_hold_unvalidated_inv_flag=>'N',
     p_hold_all_payments_flag=>'N',
     p_us_phone => p_ar_us_phone,
     p_fax =>  p_ar_fax,
     p_email => p_ar_email,
     p_non_us_phone => p_ar_non_us_phone,
     --p_purchasing_site_flag => NULL,
     p_purchasing_site_flag => 'Y',
     x_vendor_site_id=>l_pay_site_id,
     x_party_site_id => l_party_site_id,
     x_status=>l_status,
     x_exception_msg=>l_msg);

     IF(nvl(l_status,'F')<>'S' OR l_pay_site_id IS NULL) THEN
	RAISE e_supp_exception;
     END IF;

     -- Added for bug 6238518
     IF (l_status = 'S') THEN
         IF NVL(l_pay_site_flag,'N') = 'Y' THEN
            fv_utility.log_mesg('Updating remit poc for site id: '||l_party_site_id);
            UPDATE hz_party_sites
            SET    addressee = p_remit_poc
            WHERE  party_site_id = l_party_site_id;
         END IF;
     END IF;

     l_account_uses_insert_flag := 'I';
     l_account_uses_upd_flag := 'N';
     --IF(l_vendor_name IS NULL) THEN l_vendor_name := p_legal_bus_name; END IF;
     IF(l_vendor_name IS NULL) THEN l_vendor_name := l_legal_bus_name; END IF;
       insert_for_report(l_duns_for_report,13,null,l_plus4,l_vendor_name,'P',null);
  END IF;
  EXCEPTION
  WHEN OTHERS THEN
    l_assgn_conc_req_status := 'E';
    IF(l_msg IS NULL) THEN
	l_excp_msg := FND_MESSAGE.GET;
    ELSE
	l_excp_msg := l_msg;
    END IF;
    FND_MESSAGE.SET_NAME('FV','FV_CCR_PAY_SITE_INSERT');
    FND_MESSAGE.SET_TOKEN('DUNS',l_plus4);
    l_msg_text := FND_MESSAGE.GET;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,l_msg_text||
			' Error Code:' || SQLCODE ||' Error Text:' || SQLERRM);
    insert_for_report(l_duns_for_report,19,l_msg_text||nvl(l_excp_msg,''),null,null,null,null);
    l_account_uses_insert_flag := 'N';
    l_account_uses_upd_flag := 'N';

    IF	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;
  END;
  ELSIF(nvl(p_pay_site_id,0)<>0) THEN
  BEGIN


  IF(p_enabled_flag = 'N') THEN
	get_vendor_site_code(p_pay_site_id,x_react_pay_site_code);
  END IF;

   IF(l_account_uses_insert_flag <> 'I' AND l_account_uses_insert_flag<>'N') THEN
	l_account_uses_insert_flag := 'U';
   END IF;
  l_msg := null;

  FV_CCR_UTIL_PVT.update_vendor_site(
    p_vendor_site_code =>null,
    p_vendor_site_id=>p_pay_site_id,
    p_org_id => p_org_id,
    p_address_line1=>p_pay_address_line1,
    p_address_line2=>p_pay_address_line2,
    p_address_line3=>p_pay_address_line3,
    p_address_line4=>null,
    p_city=>p_pay_address_city,
    p_state=>l_state,
    p_zip=>p_pay_address_zip,
    p_province=>l_province,
    p_country=>p_pay_address_country,
    p_duns_number=>p_duns,
    --p_pay_site_flag => NULL, mod for bug 6348043
    p_pay_site_flag => 'Y',
    p_hold_unvalidated_inv_flag=>l_hold_unmatched_invoices_flag,
    p_hold_all_payments_flag=>l_hold_all_payments_flag,
    p_us_phone => p_ar_us_phone,
    p_fax =>  p_ar_fax,
    p_email => p_ar_email,
    p_non_us_phone => p_ar_non_us_phone,
    --p_purchasing_site_flag => NULL,
    p_purchasing_site_flag => 'Y',
    x_party_site_id => l_party_site_id,
    x_status=>l_status,
    x_exception_msg=>l_msg);
    --p_calling_source=>'CCRImport');    Bug#4476059


    IF(nvl(l_status,'F')<>'S') THEN
	    RAISE e_supp_exception;
    END IF;

    -- Added for bug 6238518
    IF (l_status = 'S') THEN
         fv_utility.log_mesg('Updating remit poc for site id: '||l_party_site_id);
         UPDATE hz_party_sites
         SET    addressee = p_remit_poc
         WHERE  party_site_id = l_party_site_id;
    END IF;


   EXCEPTION
   WHEN OTHERS THEN
     l_assgn_conc_req_status := 'E';
     IF(l_msg IS NULL) THEN
     	l_excp_msg:=FND_MESSAGE.GET;
     ELSE
      	l_excp_msg:=l_msg;
     END IF;
     get_vendor_site_code(p_pay_site_id,l_site_code);
     FND_MESSAGE.SET_NAME('FV','FV_CCR_PAY_SITE_UPDATE');
     FND_MESSAGE.SET_TOKEN('VENDORSITECODE',l_site_code);
     l_msg_text := FND_MESSAGE.GET;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,l_msg_text||
			' Error Code:' || SQLCODE ||' Error Text:' || SQLERRM);
     insert_for_report(l_duns_for_report,19,l_msg_text||nvl(l_excp_msg,''),null,null,null,null);

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
     	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
   END;

   END IF;


  BEGIN

   process_bank_account_uses
   (
    l_account_uses_upd_flag,
    l_vendor_id,
    p_federal_vendor,
    p_valid_bank_info,
    p_old_bank_account_id,
    l_pay_site_id,
    p_file_date,
    l_new_bank_account_id,
    l_account_uses_insert_flag,
    p_org_id );

 /*  Code for bug 9320586 Starting */
   /*Updating to move to new pay address*/
   IF(l_change_pay_site_flg='Y') THEN

       UPDATE ap_supplier_sites_all
       SET    duns_number=0,
              party_site_id=0
        WHERE vendor_site_code='old_'||p_duns
        AND   vendor_id  =l_vendor_id
        AND   org_id     = p_org_id;

    END IF;
  /*  Code for bug 9320586 Ending */


  EXCEPTION
  WHEN OTHERS THEN
	l_assgn_conc_req_status := 'E';
        FND_CLIENT_INFO.set_org_context(l_old_org_id);
	FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,l_msg_text||
			' Error Code:' || SQLCODE ||' Error Text:' || SQLERRM);
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     	THEN
     	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     	END IF;
  END;
  IF(l_pay_site_id = 0) THEN l_pay_site_id := null; END IF;
  IF(l_main_add_site_id = 0) THEN l_main_add_site_id := null; END IF;
  IF(l_new_bank_account_id=0) THEN l_new_bank_account_id := null; END IF;
  IF(p_header_conc_req_status = 'S' AND p_ccr_id <> p_prev_ccr_id) THEN
	UPDATE fv_ccr_vendors
	SET conc_request_status=l_header_conc_req_status,
	last_update_date=sysdate,
	last_updated_by=l_user_id,
  	last_update_login=l_login_id
	WHERE ccr_id=p_ccr_id;
  END IF;
  IF(p_assgn_conc_req_status <> 'S') THEN
	l_assgn_conc_req_status:=p_assgn_conc_req_status;
  END IF;


  UPDATE FV_CCR_ORGS
  SET pay_site_id = l_pay_site_id,
  main_address_site_id = l_main_add_site_id,
  bank_account_id = l_new_bank_account_id,
  conc_request_status=l_assgn_conc_req_status,
  last_update_date=sysdate,
  last_updated_by=l_user_id,
  last_update_login=l_login_id
  WHERE ccr_id = p_ccr_id
  AND org_id = p_org_id;


l_affected_inv_cnt :=  AP_AUTOMATIC_PROPAGATION_PKG.Get_Affected_Invoices_Count(
                                 p_external_bank_account_id => p_old_bank_account_id,
                                 p_vendor_id => l_vendor_id,
                                 p_vendor_site_id =>l_pay_site_id,
                                 p_party_Site_Id => null,
                                p_org_id  => p_org_id);

FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_affected_inv_cnt: '||l_affected_inv_cnt);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_old_bank_account_id: '||p_old_bank_account_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_new_bank_account_id: '||l_new_bank_account_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_vendor_id: '||l_vendor_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_vendor_site_id: '||l_pay_site_id);
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_org_id: '||p_org_id);

if l_affected_inv_cnt > 0 then

 AP_AUTOMATIC_PROPAGATION_PKG.Update_Payment_Schedules (
     p_from_bank_account_id => p_old_bank_account_id,
     p_to_bank_account_id =>  l_new_bank_account_id,
     p_vendor_id => l_vendor_id,
     p_vendor_site_id =>l_pay_site_id,
     p_party_Site_Id => null,
     p_org_id  => p_org_id  );


end if;

ELSIF (p_ccr_status='E' or p_ccr_status='D') THEN

  IF(nvl(p_pay_site_id,0)<>0) THEN
    IF(p_pay_address_country = 'CAN') THEN
	l_state := null;
	l_province := p_pay_address_state;
    ELSE
	l_state := p_pay_address_state;
	l_province:=null;
    END IF;
  BEGIN
	l_msg := null;


        FV_CCR_UTIL_PVT.update_vendor_site(
        p_vendor_site_code =>null,
        p_vendor_site_id=>p_pay_site_id,
        p_org_id => p_org_id,
        p_address_line1=>p_pay_address_line1,
        p_address_line2=>p_pay_address_line2,
        p_address_line3=>p_pay_address_line3,
        p_address_line4=>null,
        p_city=>p_pay_address_city,
        p_state=>l_state,
        p_zip=>p_pay_address_zip,
        p_province=>l_province,
        p_country=>p_pay_address_country,
        p_duns_number=>p_duns,
        --p_pay_site_flag => NULL, mod for bug 6348043
        p_pay_site_flag => NULL,
        --p_hold_unvalidated_inv_flag=>'Y',Commented and below for bug 9442110
        --p_hold_all_payments_flag=>'Y',Commented and below for bug 9442110
	p_hold_unvalidated_inv_flag=>l_hold_unmatched_invoices_flag,
	p_hold_all_payments_flag=>l_hold_all_payments_flag,
        p_us_phone => p_ar_us_phone,
        p_fax =>  p_ar_fax,
        p_email => p_ar_email,
        p_non_us_phone => p_ar_non_us_phone,
        p_purchasing_site_flag => NULL,
        x_party_site_id => l_party_site_id,
        x_status=>l_status,
        x_exception_msg=>l_msg);


	IF(nvl(l_status,'F')<>'S') THEN
		RAISE e_supp_exception;
	END IF;
	get_vendor_site_code(p_pay_site_id,x_react_pay_site_code);
  EXCEPTION
  WHEN OTHERS THEN
     l_assgn_conc_req_status := 'E';
     IF(l_msg IS NULL) THEN
	     l_excp_msg := FND_MESSAGE.GET;
     ELSE
	     l_excp_msg := l_msg;
     END IF;
     get_vendor_site_code(p_pay_site_id,l_site_code);
     FND_MESSAGE.SET_NAME('FV','FV_CCR_PAY_SITE_UPDATE');
     FND_MESSAGE.SET_TOKEN('VENDORSITECODE',l_site_code);
     l_msg_text := FND_MESSAGE.GET;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,l_msg_text||
			' Error Code:' || SQLCODE ||' Error Text:' || SQLERRM);
     insert_for_report(l_duns_for_report,19,l_msg_text||nvl(l_excp_msg,''),null,null,null,null);
  END;
  END IF;
  IF(nvl(p_main_add_site_id,0) <> 0) THEN
     IF(p_main_address_country = 'CAN') THEN
	l_state := null;
	l_province := p_main_address_state;
     ELSE
	l_state := p_main_address_state;
	l_province:=null;
     END IF;
  BEGIN
        l_msg := null;

        FV_CCR_UTIL_PVT.update_vendor_site(
        p_vendor_site_code =>null,
        p_vendor_site_id=>p_main_add_site_id,
        p_org_id => p_org_id,
        p_address_line1=>p_main_address_line1,
        p_address_line2=>p_main_address_line2,
        p_address_line3=>null,
        p_address_line4=>null,
        p_city=>p_main_address_city,
        p_state=>l_state,
        p_zip=>p_main_address_zip,
        p_province=>l_province,
        p_country=>p_main_address_country,
        p_duns_number=>p_duns,
        p_pay_site_flag => NULL,
        --p_hold_unvalidated_inv_flag=>'Y',Commented and below for bug 9442110
        --p_hold_all_payments_flag=>'Y',Commented and below for bug 9442110
	p_hold_unvalidated_inv_flag=>l_hold_unmatched_invoices_flag,
	p_hold_all_payments_flag=>l_hold_all_payments_flag,
        p_us_phone => NULL,
        p_fax =>  NULL,
        p_email => NULL,
        p_non_us_phone => NULL,
        p_purchasing_site_flag => NULL,
        x_party_site_id => l_party_site_id,
        x_status=>l_status,
        x_exception_msg=>l_msg);

        IF(nvl(l_status,'F')<>'S') THEN
		RAISE e_supp_exception;
	END IF;
	get_vendor_site_code(p_main_add_site_id,x_react_main_site_code);
  EXCEPTION
  WHEN OTHERS THEN
     l_assgn_conc_req_status := 'E';
     IF(l_msg IS NULL) THEN
     	l_excp_msg := FND_MESSAGE.GET;
     ELSE
        l_excp_msg := l_msg;
     END IF;
     get_vendor_site_code(p_main_add_site_id,l_site_code);
     FND_MESSAGE.SET_NAME('FV','FV_CCR_MAIN_SITE_UPDATE');
     FND_MESSAGE.SET_TOKEN('VENDORSITECODE',l_site_code);
     l_msg_text := FND_MESSAGE.GET;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,l_msg_text||
			' Error Code:' || SQLCODE ||' Error Text:' || SQLERRM);
     insert_for_report(l_duns_for_report,19,l_msg_text||nvl(l_excp_msg,''),null,null,null,null);
  END;
  END IF;
  IF(p_header_conc_req_status = 'S' AND p_ccr_id <> p_prev_ccr_id) THEN
	UPDATE fv_ccr_vendors
	SET conc_request_status=l_header_conc_req_status,
	last_update_date=sysdate,
	last_updated_by=l_user_id,
  	last_update_login=l_login_id
	WHERE ccr_id=p_ccr_id;
  END IF;
  IF(p_assgn_conc_req_status = 'S') THEN
	UPDATE fv_ccr_orgs
	SET conc_request_status=l_assgn_conc_req_status,
	last_update_date=sysdate,
	last_updated_by=l_user_id,
  	last_update_login=l_login_id
	WHERE ccr_id=p_ccr_id
	AND org_id=p_org_id;
  END IF;

END IF;


-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get
(
	p_count         	=>      x_msg_count     	,
       	p_data          	=>      x_msg_data
);
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
		IF(x_vendor_id IS NULL) THEN
			x_vendor_id := p_prev_vendor_id;
		END IF;

		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF(x_vendor_id IS NULL) THEN
			x_vendor_id := p_prev_vendor_id;
		END IF;

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
WHEN OTHERS THEN
		IF(x_vendor_id IS NULL) THEN
			x_vendor_id := p_prev_vendor_id;
		END IF;

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);


END;

FUNCTION get_profile_option(p_name varchar2) RETURN varchar2
as
v_value varchar2(1000) default null;
BEGIN
    FND_PROFILE.GET(p_name, v_value);
 return v_value;
END get_profile_option;


PROCEDURE delete_plusfour_assignments(p_ccrid number)
as
v_plus_four varchar2(100);
l_module_name VARCHAR2(60);
BEGIN
  l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.delete_plusfour_assignments';

  --unassign plus_four's vendor_id (supplier)
  update fv_ccr_vendors
  set vendor_id = null
  where duns = (select duns from fv_ccr_vendors where ccr_id = p_ccrid)
  and plus_four is not null;

  --delete plus_four assignments
  select plus_four into v_plus_four
  from fv_ccr_vendors
  where ccr_id = p_ccrid;

  if v_plus_four is null then
     delete from fv_ccr_orgs
     where ccr_id in (
        select ccr_id
        from fv_ccr_vendors
        where duns = (select duns from fv_ccr_vendors where ccr_id =
p_ccrid)
        and plus_four is not null);
  end if;

EXCEPTION
WHEN OTHERS THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
END delete_plusfour_assignments;


FUNCTION get_org_paysite_id(p_ccrid NUMBER, p_org_id NUMBER)
RETURN NUMBER
AS
v_id number := null;
v_count number := 0;
v_org_id number := null;
BEGIN

--v_org_id := fv_ccr_util_pvt.get_profile_option('ORG_ID');
IF p_org_id is NOT NULL THEN
  for crec in (select pay_site_id
             from fv_ccr_orgs o, hr_organization_units ou, ap_supplier_sites_all vs
			 where o.pay_site_id is not null
			 and o.pay_site_id = vs.VENDOR_SITE_ID
			 and vs.ORG_ID = ou.organization_id
			 and ou.organization_id = nvl(p_org_id,ou.organization_id)
			 and ccr_id=p_ccrid)
  loop
    v_count := v_count + 1;
    v_id := crec.pay_site_id;
  end loop;
END IF;

if v_count > 1 then
 return -99;
else
 return v_id;
end if;

END get_org_paysite_id;


FUNCTION get_org_mainaddrsite_id(p_ccrid NUMBER, p_org_id NUMBER)
RETURN NUMBER
AS
v_id number := null;
v_count number := 0;
v_org_id number := null;
BEGIN

--v_org_id := fv_ccr_util_pvt.get_profile_option('ORG_ID');
IF p_org_id is NOT NULL THEN
  for crec in (select main_address_site_id
             from fv_ccr_orgs o, hr_organization_units ou, po_vendor_sites_all vs
			 where o.main_address_site_id is not null
			 and o.main_address_site_flag = 'Y'
			 and o.main_address_site_id = vs.VENDOR_SITE_ID
			 and vs.ORG_ID = ou.organization_id
			 and ou.organization_id = nvl(v_org_id,ou.organization_id)
			 and ccr_id=p_ccrid)
  loop
    v_count := v_count + 1;
    v_id := crec.main_address_site_id;
  end loop;
END IF;

if v_count > 1 then
 return -99;
else
 return v_id;
end if;

END get_org_mainaddrsite_id;

/*-------------------------------------------------------------------
 Function get_lookup_desc gets the meaning from fnd_lookups
 given a lookup code and type.
 This function is used in FvCcrVendorCodesVO which in turn
 is used in the View Goods and Services page.
-------------------------------------------------------------------*/
FUNCTION get_lookup_desc (p_lookup_type  IN VARCHAR2,
                          p_lookup_code  IN VARCHAR2
) RETURN VARCHAR2
IS

l_lookup_meaning        fnd_lookups.meaning%TYPE;

BEGIN
   l_lookup_meaning := NULL;

   IF p_lookup_code IS NOT NULL
   THEN
       SELECT p_lookup_code||' - '||meaning meaning
       INTO   l_lookup_meaning
       FROM   fnd_lookup_values
       WHERE  lookup_type = p_lookup_type
       AND    lookup_code = p_lookup_code
       AND    language = userenv('LANG');
   END IF;

   RETURN l_lookup_meaning;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN p_lookup_code;
   WHEN OTHERS THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,
                              'fv_ccr_util_pvt.get_lookup_desc',SQLERRM);
        RETURN p_lookup_code;

END  get_lookup_desc;

/*-------------------------------------------------------------------
 Function check_non_user_org_asgnmt checks to see if there are any
 org or supplier assignments which do not belong to the organization
 that the user has access to.
 This function is used in VendorAMImpl.java to check if user should
 be allowed to unassign the supplier assigned to a ccr_id
-------------------------------------------------------------------*/
FUNCTION check_non_user_org_asgnmt (p_ccr_id  IN NUMBER ) RETURN VARCHAR2
IS

l_asgnmt_exists   VARCHAR2(1);
l_count           NUMBER     ;

BEGIN
   l_asgnmt_exists   := 'N';
   l_count           := 0;

   SELECT COUNT(*)
   INTO   l_count
   FROM   fv_ccr_orgs fco
   WHERE  fco.ccr_id = p_ccr_id
   AND    mo_global.check_access(fco.org_id)<>'Y';


   IF l_count > 0
   THEN
       l_asgnmt_exists := 'Y';
   ELSE
       l_asgnmt_exists := 'N';
   END IF;

   RETURN l_asgnmt_exists;

END check_non_user_org_asgnmt;

/*-------------------------------------------------------------------
 Function check_suppl_tobe_merged checks to see if the supplier
 is about to be merged with another supplier.
 This function is used in VendorAMImpl.java to check if user should
 be allowed to assign the supplier to a ccr_id
-------------------------------------------------------------------*/
FUNCTION check_suppl_tobe_merged (p_vendor_id  IN NUMBER ) RETURN VARCHAR2
IS

l_tobe_merged     VARCHAR2(1);
l_count           NUMBER     ;

BEGIN
   l_tobe_merged   := 'N';
   l_count         := 0;

   -- Check if there is any pending supplier merge.
   SELECT COUNT(*)
   INTO   l_count
   FROM   ap_duplicate_vendors_all
   WHERE  duplicate_vendor_id = p_vendor_id
   AND    process_flag <> 'Y';

   IF l_count > 0
   THEN
       l_tobe_merged := 'Y';
   ELSE
       l_tobe_merged := 'N';
   END IF;

   RETURN l_tobe_merged;

END check_suppl_tobe_merged;


PROCEDURE insert_vendor
(
p_vendor_name     IN varchar2,
p_taxpayer_id     IN varchar2,
p_supplier_number IN varchar2,
p_org_type_lookup_code IN VARCHAR2,
x_vendor_id       OUT NOCOPY NUMBER,
x_status          OUT NOCOPY VARCHAR2,
x_exception_msg   OUT NOCOPY VARCHAR2
)
IS
	l_vendor_rec  AP_VENDOR_PUB_PKG.r_vendor_rec_type;
	l_party_id    number;
	l_version number;
	l_msg_count number;
	l_msg_data  varchar2(400);
      l_ret_stat varchar2(50);

BEGIN

	l_version := 1.0;
	l_vendor_rec.vendor_name := p_vendor_name;
	l_vendor_rec.JGZZ_FISCAL_CODE := p_taxpayer_id;
	l_vendor_rec.segment1 := p_supplier_number;

	l_vendor_rec.ORGANIZATION_TYPE_LOOKUP_CODE := p_org_type_lookup_code;

fv_utility.log_mesg('p_vendor_name: '||p_vendor_name);
fv_utility.log_mesg('p_taxpayer_id: '||p_taxpayer_id);
fv_utility.log_mesg('p_supplier_number: '||p_supplier_number);
fv_utility.log_mesg('p_org_type_lookup_code: '||p_org_type_lookup_code);


	AP_VENDOR_PUB_PKG.create_vendor(
	p_api_version => l_version,
	p_init_msg_list => FND_API.G_TRUE,
	p_commit=> FND_API.G_FALSE,
	p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
	x_return_status => l_ret_stat,
	x_msg_count=>l_msg_count,
	x_msg_data=>l_msg_data,
	p_vendor_rec=>l_vendor_rec,
	x_vendor_id=>x_vendor_id,
	x_party_id=>l_party_id);


fv_utility.log_mesg('l_ret_stat: '||l_ret_stat);
fv_utility.log_mesg('l_msg_count: '||l_msg_count);

	if(l_ret_stat <> 'S') THEN
	  if(l_msg_count = 1) THEN
	     x_exception_msg := l_msg_data;
	  else
	    for i in 1..l_msg_count loop
	       x_exception_msg := x_exception_msg || fnd_msg_pub.get(p_msg_index=>i,p_encoded=>'F');
	    end loop;
	  end if;
	end if;

	x_status := l_ret_stat;
fv_utility.log_mesg('x_exception_msg: '||x_exception_msg);

exception
  when others then
       fv_utility.log_mesg('Exception in fv_ccr_util_pvt.insert_vendor.');
       fv_utility.log_mesg(sqlcode||': '||sqlerrm);

END insert_vendor;


PROCEDURE update_vendor
(
p_vendor_id     IN NUMBER,
p_taxpayer_id   IN VARCHAR2,
x_status        OUT NOCOPY VARCHAR2,
x_exception_msg OUT NOCOPY VARCHAR2
)
IS
	l_party_id number;
BEGIN

	x_status := 'E';

	SELECT party_id INTO l_party_id
	FROM ap_suppliers
	WHERE vendor_id = p_vendor_id;

	UPDATE hz_parties
	SET JGZZ_FISCAL_CODE = p_taxpayer_id
	where party_id = l_party_id;


	update hz_organization_profiles
	set JGZZ_FISCAL_CODE = p_taxpayer_id
	where party_id = l_party_id;

	UPDATE ap_suppliers
	SET num_1099 = p_taxpayer_id
	WHERE vendor_id = p_vendor_id;

	x_status := 'S';

	IF(SQL%NOTFOUND) THEN
	 x_exception_msg := 'No party exist for this vendor';
	 x_status := 'E';
	END IF;

	EXCEPTION
	WHEN OTHERS THEN
	  x_exception_msg := 'Exception when getting vendor info';
	  x_status := 'U';
END update_vendor;


PROCEDURE insert_vendor_site
(
p_vendor_site_code IN VARCHAR2,
p_vendor_id        IN NUMBER,
p_org_id           IN NUMBER,
p_address_line1    IN VARCHAR2,
p_address_line2    IN VARCHAR2,
p_address_line3    IN VARCHAR2,
p_address_line4    IN VARCHAR2,
p_city             IN VARCHAR2,
p_state		 IN VARCHAR2,
p_zip		   IN VARCHAR2,
p_province	   IN VARCHAR2,
p_country	   IN VARCHAR2,
p_duns_number	   IN VARCHAR2,
p_pay_site_flag    IN VARCHAR2,
p_hold_unvalidated_inv_flag IN VARCHAR2,
p_hold_all_payments_flag    IN VARCHAR2,
p_us_phone                  IN VARCHAR2,
p_fax                       IN VARCHAR2,
p_email                     IN VARCHAR2,
p_non_us_phone              IN VARCHAR2,
p_purchasing_site_flag      IN VARCHAR2,
x_vendor_site_id            OUT NOCOPY NUMBER,
x_party_site_id             OUT NOCOPY NUMBER,
x_status                    OUT NOCOPY VARCHAR2,
x_exception_msg             OUT NOCOPY VARCHAR2
)
IS
	l_vendor_site_rec  AP_VENDOR_PUB_PKG.r_vendor_site_rec_type;
	l_party_site_id    number;
	l_version number;
	l_ret_stat varchar2(20);
	l_msg_count number;
	l_msg_data  varchar2(400);
	l_location_id number;
	l_cage_code fv_ccr_vendors.cage_code%type;
	l_legal_bus_name fv_ccr_vendors.legal_bus_name%type;
	l_dba_name fv_ccr_vendors.dba_name%type;
	l_division_name fv_ccr_vendors.division_name%type;

BEGIN
      --Bug9790495
      -- Logic to check if user is ISP UI is available or not.
      -- If ISP UI is not available then not include populate attributs
      -- in ap_supplier_sites_all table
      IF (PO_ISPCODELEVEL_PVT.get_curr_isp_supp_code_level
          >= PO_ISPCODELEVEL_PVT.G_ISP_SUP_CODE_LEVEL_CLM_BASE) THEN


	BEGIN
		Select cage_code, legal_bus_name, dba_name, division_name
		into l_cage_code, l_legal_bus_name, l_dba_name, l_division_name
		from fv_ccr_vendors where duns = p_duns_number and rownum<=1;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	null;
	END;

	l_vendor_site_rec.cage_code           := l_cage_code;
	l_vendor_site_rec.legal_business_name := l_legal_bus_name;
	l_vendor_site_rec.doing_bus_as_name    := l_dba_name;
	l_vendor_site_rec.division_name       := l_division_name;
      END IF;

	l_version := 1.0;
	l_vendor_site_rec.VENDOR_SITE_CODE := p_vendor_site_code;
	l_vendor_site_rec.VENDOR_ID := p_vendor_id;
	l_vendor_site_rec.org_id := p_org_id;
	l_vendor_site_rec.ADDRESS_LINE1 := p_address_line1;
	l_vendor_site_rec.ADDRESS_LINE2 := p_address_line2;
	l_vendor_site_rec.ADDRESS_LINE3 := p_address_line3;
	l_vendor_site_rec.ADDRESS_LINE4 := p_address_line4;
	l_vendor_site_rec.city := p_city;
	l_vendor_site_rec.state := p_state;
	l_vendor_site_rec.zip := p_zip;
	l_vendor_site_rec.province := p_province;
	l_vendor_site_rec.country := p_country;
	l_vendor_site_rec.duns_number := p_duns_number;
	l_vendor_site_rec.HOLD_ALL_PAYMENTS_FLAG := p_hold_all_payments_flag;
	l_vendor_site_rec.HOLD_UNMATCHED_INVOICES_FLAG := p_hold_unvalidated_inv_flag;
	l_vendor_site_rec.HOLD_FUTURE_PAYMENTS_FLAG := p_hold_unvalidated_inv_flag;
  l_vendor_site_rec.PURCHASING_SITE_FLAG := p_purchasing_site_flag;

	if(p_pay_site_flag IS NOT NULL) THEN
	   l_vendor_site_rec.pay_site_flag := p_pay_site_flag;
     -- Added for bug 6348043
     IF p_us_phone IS NOT NULL THEN
        l_vendor_site_rec.area_code := SUBSTR(p_us_phone,1,3);
        l_vendor_site_rec.phone := SUBSTR(p_us_phone,4,7);
       ELSIF (p_us_phone IS NULL AND p_non_us_phone IS NOT NULL) THEN
        l_vendor_site_rec.phone := p_non_us_phone;
     END IF;
     l_vendor_site_rec.fax_area_code := SUBSTR(p_fax,1,3);
     l_vendor_site_rec.fax := SUBSTR(p_fax,4,7);
     l_vendor_site_rec.email_address := p_email;
	end if;

	AP_VENDOR_PUB_PKG.create_vendor_site(
	p_api_version => l_version,
	p_init_msg_list => FND_API.G_TRUE,
	p_commit=> FND_API.G_FALSE,
	p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
	x_return_status => l_ret_stat,
	x_msg_count=>l_msg_count,
	x_msg_data=>l_msg_data,
	p_vendor_site_rec=>l_vendor_site_rec,
	x_vendor_site_id=>x_vendor_site_id,
	x_party_site_id=>l_party_site_id,
	x_location_id => l_location_id);

  x_party_site_id := l_party_site_id;

	if(l_ret_stat <> 'S') THEN
	  if(l_msg_count = 1) THEN
	     x_exception_msg := l_msg_data;
	  else
	    for i in 1..l_msg_count loop
	       x_exception_msg := x_exception_msg || fnd_msg_pub.get(p_msg_index=>i,p_encoded=>'F');
	    end loop;
	  end if;
	end if;

	x_status := l_ret_stat;

	EXCEPTION
	WHEN OTHERS THEN
	  x_status := 'U';
	  x_exception_msg := x_exception_msg ||'Exception when creating vendor site';

END insert_vendor_site;


PROCEDURE update_vendor_site
	(
	p_vendor_site_code IN VARCHAR2,
	p_vendor_site_id   IN NUMBER,
	p_org_id           IN NUMBER,
	p_address_line1    IN VARCHAR2,
	p_address_line2    IN VARCHAR2,
	p_address_line3    IN VARCHAR2,
	p_address_line4    IN VARCHAR2,
	p_city             IN VARCHAR2,
	p_state		   IN VARCHAR2,
	p_zip		   IN VARCHAR2,
	p_province	   IN VARCHAR2,
	p_country	   IN VARCHAR2,
	p_duns_number	   IN VARCHAR2,
	p_pay_site_flag    IN VARCHAR2,
	p_hold_unvalidated_inv_flag IN VARCHAR2,
	p_hold_all_payments_flag    IN VARCHAR2,
  p_us_phone                  IN VARCHAR2,
  p_fax                       IN VARCHAR2,
  p_email                     IN VARCHAR2,
  p_non_us_phone              IN VARCHAR2,
  p_purchasing_site_flag      IN VARCHAR2,
  x_party_site_id             OUT NOCOPY NUMBER,
	x_status                    OUT NOCOPY VARCHAR2,
	x_exception_msg             OUT NOCOPY VARCHAR2
	)

	IS
	l_vendor_site_rec  AP_VENDOR_PUB_PKG.r_vendor_site_rec_type;
	l_party_site_id    number;
	l_version number;
	l_ret_stat varchar2(20);
	l_msg_count number;
	l_msg_data  varchar2(400);
	l_location_id number;
	l_party_site_rec HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
	l_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
	l_object_version_number NUMBER;
	l_cage_code fv_ccr_vendors.cage_code%type;
	l_legal_bus_name fv_ccr_vendors.legal_bus_name%type;
	l_dba_name fv_ccr_vendors.dba_name%type;
	l_division_name fv_ccr_vendors.division_name%type;
	BEGIN

       --Bug9790495
       IF (PO_ISPCODELEVEL_PVT.get_curr_isp_supp_code_level
          >= PO_ISPCODELEVEL_PVT.G_ISP_SUP_CODE_LEVEL_CLM_BASE) THEN
	BEGIN
		Select cage_code, legal_bus_name, dba_name, division_name
		into l_cage_code, l_legal_bus_name, l_dba_name, l_division_name
		from fv_ccr_vendors where duns = p_duns_number and rownum<=1;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	null;
	END;

	l_vendor_site_rec.cage_code           := l_cage_code;
	l_vendor_site_rec.legal_business_name := l_legal_bus_name;
	l_vendor_site_rec.doing_bus_as_name    := l_dba_name;
	l_vendor_site_rec.division_name       := l_division_name;
       END IF;

	l_version := 1.0;
	l_vendor_site_rec.VENDOR_SITE_ID := p_vendor_site_id;
	l_vendor_site_rec.org_id := p_org_id;
	l_vendor_site_rec.HOLD_ALL_PAYMENTS_FLAG := p_hold_all_payments_flag;
	l_vendor_site_rec.HOLD_UNMATCHED_INVOICES_FLAG := p_hold_unvalidated_inv_flag;
	l_vendor_site_rec.HOLD_FUTURE_PAYMENTS_FLAG := p_hold_unvalidated_inv_flag;
  l_vendor_site_rec.PURCHASING_SITE_FLAG := p_purchasing_site_flag;

	l_location_rec.ADDRESS1 := p_address_line1;
	l_location_rec.ADDRESS2 := p_address_line2;
	l_location_rec.ADDRESS3 := p_address_line3;
	l_location_rec.ADDRESS4 := p_address_line4;
	l_location_rec.city := p_city;
	l_location_rec.state := p_state;
	l_location_rec.postal_code := p_zip;
	l_location_rec.province := p_province;
	l_location_rec.country := p_country;

	l_party_site_rec.duns_number_c := p_duns_number;

        -- Added for bug 6348043
        IF(p_pay_site_flag IS NOT NULL) THEN
           IF p_us_phone IS NOT NULL THEN
              l_vendor_site_rec.area_code := SUBSTR(p_us_phone,1,3);
              l_vendor_site_rec.phone := SUBSTR(p_us_phone,4,7);
             ELSIF (p_us_phone IS NULL AND p_non_us_phone IS NOT NULL) THEN
              l_vendor_site_rec.phone := p_non_us_phone;
           END IF;
           l_vendor_site_rec.fax_area_code := SUBSTR(p_fax,1,3);
           l_vendor_site_rec.fax := SUBSTR(p_fax,4,7);
           l_vendor_site_rec.email_address := p_email;
	END IF;

	x_status := 'S';

        --Bug 6519638
        l_vendor_site_rec.duns_number := p_duns_number;
        l_vendor_site_rec.pay_site_flag := p_pay_site_flag;

	AP_VENDOR_PUB_PKG.update_vendor_site(
	p_api_version => l_version,
	p_init_msg_list => FND_API.G_TRUE,
	p_commit=> FND_API.G_FALSE,
	p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
	x_return_status => l_ret_stat,
	x_msg_count=>l_msg_count,
	x_msg_data=>l_msg_data,
	p_vendor_site_rec=>l_vendor_site_rec,
	p_vendor_site_id=>p_vendor_site_id,
	p_calling_prog=>'CCRImport');            --Bug 6519638


	if(l_ret_stat <> 'S') THEN
	  x_status := l_ret_stat;
	  if(l_msg_count = 1) THEN
	     x_exception_msg := l_msg_data;
	  else
	    for i in 1..l_msg_count loop
	       x_exception_msg := x_exception_msg || fnd_msg_pub.get(p_msg_index=>i,p_encoded=>'F');
	    end loop;
	  end if;
	end if;

	-- Get the location and party site information
	BEGIN

	SELECT party_site_id,location_id
	INTO  l_party_site_id,l_location_id
	FROM ap_supplier_sites_all
	WHERE vendor_site_id = p_vendor_site_id;

  x_party_site_id := l_party_site_id;

	EXCEPTION
	WHEN OTHERS THEN
	  x_status := 'U';
	  x_exception_msg := x_exception_msg ||'Exception when getting information for vendor site';
	END;


	-- Update the location information

	BEGIN


	select object_version_number
	into l_object_version_number
	from hz_locations
	where location_id = l_location_id;


	l_location_rec.location_id := l_location_id;

	hz_location_v2pub.update_location(
	FND_API.G_TRUE,
	l_location_rec,
	l_object_version_number,
	l_ret_stat,
	l_msg_count,
	l_msg_data);

	if(l_ret_stat <> 'S') THEN
	  x_status := l_ret_stat;
	  if(l_msg_count = 1) THEN
	     x_exception_msg := x_exception_msg || l_msg_data;
	  else
	    for i in 1..l_msg_count loop
	       x_exception_msg := x_exception_msg || fnd_msg_pub.get(p_msg_index=>i,p_encoded=>'F');
	    end loop;
	  end if;
	end if;

	EXCEPTION
	WHEN OTHERS THEN
	  x_status := 'U';
	  x_exception_msg :=x_exception_msg || 'Exception when getting information for location';
	END;


	-- Update party site information

	BEGIN

	l_party_site_rec.party_site_id := l_party_site_id;

	select object_version_number
	into l_object_version_number
	from hz_party_sites
	where party_site_id = l_party_site_id;


	hz_party_site_v2pub.update_party_site(
	FND_API.G_TRUE,
	l_party_site_rec,
	l_object_version_number,
	l_ret_stat,
	l_msg_count,
	l_msg_data);

	if(l_ret_stat <> 'S') THEN
	  x_status := l_ret_stat;
	  if(l_msg_count = 1) THEN
	     x_exception_msg := x_exception_msg || l_msg_data;
	  else
	    for i in 1..l_msg_count loop
	       x_exception_msg := x_exception_msg || fnd_msg_pub.get(p_msg_index=>i,p_encoded=>'F');
	    end loop;
	  end if;
	end if;

	EXCEPTION
	WHEN OTHERS THEN
	  x_status := 'U';
	  x_exception_msg :=x_exception_msg || 'Exception when getting information for party site';
	END;

END update_vendor_site;


PROCEDURE create_bank_account
	(
	p_created_bank_id IN NUMBER,
	p_created_bank_branch_id IN NUMBER,
	p_bank_name  IN VARCHAR2,
	p_branch_name IN VARCHAR2,
	p_bank_num IN VARCHAR2,
	p_eft_user_num IN VARCHAR2,
	p_inst_type IN VARCHAR2,
	p_bank_branch_type IN VARCHAR2,
	p_bank_acct_name  IN VARCHAR2,
	p_bank_acct_num IN VARCHAR2,
	p_currency_code IN VARCHAR2,
	p_bank_account_type IN VARCHAR2,
	p_country_code IN VARCHAR2,
	p_duns_number IN VARCHAR2,
	x_bank_id      OUT NOCOPY NUMBER,
	x_bank_branch_id OUT NOCOPY NUMBER,
	x_bank_account_id OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY VARCHAR2
	)
	IS
	l_api_version CONSTANT NUMBER := 1.0;
	l_return_status VARCHAR2(1);
	l_msg_count NUMBER;
	l_msg_data VARCHAR2(2000);
	l_bank_id NUMBER;
	l_start_date DATE;
	l_end_date DATE;
	l_response IBY_FNDCPT_COMMON_PUB.Result_rec_type;
	l_bank_rec IBY_EXT_BANKACCT_PUB.ExtBank_rec_type;
	l_bank_branch_rec IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type;
	l_bank_acct_rec IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type;
	l_bank_branch_id NUMBER;
	l_bank_account_id NUMBER;
	l_object_version_number NUMBER;
	l_ach_us_phone fv_ccr_vendors.ach_us_phone%type;
	l_ach_non_us_phone fv_ccr_vendors.ach_non_us_phone%type;
	l_ach_email fv_ccr_vendors.ach_email%type;
	l_ach_fax fv_ccr_vendors.ach_fax%type;

	BANK_EXCEPTION  EXCEPTION;
	BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	if(nvl(p_created_bank_branch_id,0)=0) THEN

	   -- Creation of Bank
	   --  Check if bank exists

	   IBY_EXT_BANKACCT_PUB.check_bank_exist(
	   p_api_version => l_api_version,
	   p_init_msg_list => FND_API.G_FALSE,
	   p_country_code=> p_country_code,
	   p_bank_name =>p_bank_name,
         p_bank_number => p_bank_num,
	   x_return_status => l_return_status,
	   x_msg_count => l_msg_count,
	   x_msg_data => l_msg_data,
	   x_bank_id => l_bank_id,
	   x_end_date => l_end_date,
	   x_response => l_response);

	   if(l_bank_id IS NOT NULL) THEN
		if(l_end_date IS NOT NULL) THEN
	          IBY_EXT_BANKACCT_PUB.set_bank_end_date(
	            p_api_version => l_api_version,
			p_init_msg_list => FND_API.G_FALSE,
			p_bank_id => l_bank_id,
			p_end_date => null,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			x_response => l_response);

			if(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			   RAISE BANK_EXCEPTION;
			end if;
		end if;   -- l_end_date
	   ELSE              -- l_bank_id

		l_bank_rec.bank_name := p_bank_name;
		l_bank_rec.institution_type := p_inst_type;
		l_bank_rec.country_code := p_country_code;

		IBY_EXT_BANKACCT_PUB.create_ext_bank(
		p_api_version => l_api_version,
		p_init_msg_list => FND_API.G_FALSE,
		p_ext_bank_rec => l_bank_rec,
		x_bank_id => l_bank_id,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data,
		x_response => l_response);

		if(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				   RAISE BANK_EXCEPTION;
		end if;
	   END IF;

	   if(l_bank_id IS NULL) THEN
		RAISE BANK_EXCEPTION;
	   end if;

	   -- Creation of Bank Branch
	   -- Check if Bank Branch Exists

	   IBY_EXT_BANKACCT_PUB.check_ext_bank_branch_exist(
	   p_api_version => l_api_version,
	   p_init_msg_list => FND_API.G_FALSE,
	   p_bank_id => l_bank_id,
	   p_branch_name => p_branch_name,
	   p_branch_number => p_bank_num,
	   x_return_status => l_return_status,
	   x_msg_count => l_msg_count,
	   x_msg_data => l_msg_data,
	   x_branch_id => l_bank_branch_id,
	   x_end_date => l_end_date,
	   x_response => l_response);

	   if(l_bank_branch_id IS NOT NULL) THEN
		if(l_end_date IS NOT NULL) THEN
                IBY_EXT_BANKACCT_PUB.set_ext_bank_branch_end_date(
                  p_api_version => l_api_version,
			p_init_msg_list => FND_API.G_FALSE,
			p_branch_id => l_bank_branch_id,
			p_end_date => null,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			x_response => l_response);

			if(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			   RAISE BANK_EXCEPTION;
			end if;
		end if;   -- l_end_date

	   ELSE              -- l_bank_branch_id

		l_bank_branch_rec.bank_party_id := l_bank_id;
		l_bank_branch_rec.branch_name := p_branch_name;
		l_bank_branch_rec.branch_number := p_bank_num;
		l_bank_branch_rec.branch_type := p_bank_branch_type;

		if(p_eft_user_num IS NOT NULL) THEN
		 l_bank_branch_rec.eft_number := p_eft_user_num;
		end if;

		IBY_EXT_BANKACCT_PUB.create_ext_bank_branch(
		p_api_version => l_api_version,
		p_init_msg_list => FND_API.G_FALSE,
		p_ext_bank_branch_rec => l_bank_branch_rec,
		x_branch_id => l_bank_branch_id,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data,
		x_response => l_response);

		if(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				   RAISE BANK_EXCEPTION;
		end if;
	   END IF;   -- l_bank_branch_id

	   if(l_bank_branch_id IS NULL) THEN
		RAISE BANK_EXCEPTION;
	   end if;

	ELSE
	   l_bank_id := p_created_bank_id;
	   l_bank_branch_id := p_created_bank_branch_id;
	END IF;

	-- Create Bank Account

	IBY_EXT_BANKACCT_PUB.check_ext_acct_exist(
	p_api_version => l_api_version,
	p_init_msg_list => FND_API.G_FALSE,
	p_bank_id => l_bank_id,
	p_branch_id => l_bank_branch_id,
	p_acct_number => p_bank_acct_num,
	p_acct_name => p_bank_acct_name,
	p_currency => p_currency_code,
	p_country_code => p_country_code,
	x_acct_id => l_bank_account_id,
	x_start_date => l_start_date,
	x_end_date => l_end_date,
	x_return_status => l_return_status,
	x_msg_count => l_msg_count,
	x_msg_data => l_msg_data,
--	x_branch_id => l_bank_branch_id,
--	x_end_date => l_end_date,
	x_response => l_response);

	if(l_bank_account_id IS NOT NULL) THEN
		if(l_end_date IS NOT NULL or l_start_date IS NOT NULL) THEN

 		l_object_version_number := -1;

                IBY_EXT_BANKACCT_PUB.set_ext_bank_acct_dates(
                  p_api_version => l_api_version,
			p_init_msg_list => FND_API.G_FALSE,
			p_acct_id => l_bank_account_id,
			p_start_date => l_start_date,
			p_end_date => null,
			p_object_version_number => l_object_version_number,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			x_response => l_response);

			if(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			   RAISE BANK_EXCEPTION;
			end if;
		end if;   -- l_end_date

	ELSE              -- l_bank_account_id

		l_bank_acct_rec.country_code := p_country_code;
		l_bank_acct_rec.branch_id := l_bank_branch_id;
		l_bank_acct_rec.bank_id := l_bank_id;
		l_bank_acct_rec.bank_account_name := p_bank_acct_name;
		l_bank_acct_rec.bank_account_num := p_bank_acct_num;
		l_bank_acct_rec.currency := p_currency_code;
		l_bank_acct_rec.multi_currency_allowed_flag:= 'N';
          --Bug 7038108
          IF p_bank_account_type = 'C' THEN
             l_bank_acct_rec.acct_type := 'CHECKING';
           ELSIF
             p_bank_account_type = 'S' THEN
             l_bank_acct_rec.acct_type := 'SAVINGS';
          END IF;

          l_bank_acct_rec.acct_owner_party_id := -99;

		if(p_eft_user_num IS NOT NULL) THEN
		 l_bank_branch_rec.eft_number := p_eft_user_num;
		end if;

	BEGIN
		select ach_us_phone, ach_non_us_phone, ach_email, ach_fax
		into l_ach_us_phone, l_ach_non_us_phone, l_ach_email, l_ach_fax from fv_ccr_vendors
		where duns=p_duns_number and rownum<=1;

	EXCEPTION when no_data_found then
	null;
	END;
		l_bank_acct_rec.contact_name   := null;
		if l_ach_us_phone is not null then
			l_bank_acct_rec.contact_phone  := l_ach_us_phone;
		else l_bank_acct_rec.contact_phone  := l_ach_non_us_phone;
		end if;
		l_bank_acct_rec.contact_email     := l_ach_email;
		l_bank_acct_rec.contact_fax       := l_ach_fax;


		IBY_EXT_BANKACCT_PUB.create_ext_bank_acct(
		p_api_version => l_api_version,
		p_init_msg_list => FND_API.G_FALSE,
		p_ext_bank_acct_rec => l_bank_acct_rec,
		x_acct_id => l_bank_account_id,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data,
		x_response => l_response);

		if(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				   RAISE BANK_EXCEPTION;
		end if;
	END IF;   -- l_bank_account_id

	if(l_bank_account_id IS NULL) THEN
		RAISE BANK_EXCEPTION;
	end if;

	x_bank_id := l_bank_id;
	x_bank_branch_id := l_bank_branch_id;
	x_bank_account_id := l_bank_account_id;

	EXCEPTION
	WHEN BANK_EXCEPTION THEN
	x_return_status := fnd_api.g_ret_sts_error;

	-- Print the messages from l_msg_data in log file
	WHEN OTHERS THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	 -- Print SQLERRM in log file

END create_bank_account;

PROCEDURE update_bank_account
(
 p_bank_account_id NUMBER,
 p_bank_account_type VARCHAR2,
 x_return_status OUT NOCOPY VARCHAR2
)
IS
l_bank_account_type iby_ext_bank_accounts.bank_account_type%TYPE;
BEGIN
  --Bug 7038108
  IF p_bank_account_type = 'C' THEN
     l_bank_account_type := 'CHECKING';
   ELSIF
     p_bank_account_type = 'S' THEN
     l_bank_account_type := 'SAVINGS';
  END IF;

  UPDATE iby_ext_bank_accounts
  set BANK_ACCOUNT_TYPE = l_bank_account_type
  where EXT_BANK_ACCOUNT_ID = p_bank_account_id;

  x_return_status := fnd_api.G_RET_STS_SUCCESS;
EXCEPTION
WHEN OTHERS THEN
  x_return_status := fnd_api.g_ret_sts_unexp_error;
  -- Print SQLERRM in log file
  fv_utility.log_mesg('When others error in update_bank_account.');
END update_bank_account;


PROCEDURE process_bank_account_uses
(
	p_account_uses_upd_flag IN VARCHAR2,
	p_vendor_id IN NUMBER,
	p_federal_vendor IN VARCHAR2,
	p_valid_bank_info IN VARCHAR2,
	p_old_bank_account_id IN NUMBER,
	p_pay_site_id IN NUMBER,
	p_file_date IN DATE,
	p_new_bank_account_id IN NUMBER,
	p_account_uses_insert_flag IN VARCHAR2,
	p_org_id IN NUMBER
)
IS
	l_api_version CONSTANT NUMBER:= 1.0;
	l_return_status VARCHAR2(1);
	l_msg_count NUMBER;
	l_msg_data VARCHAR2(2000);
	l_user_id NUMBER;
	l_login_id NUMBER;
	l_uses_reln_exists VARCHAR2(1);
	l_assign_id NUMBER;
	l_party_id NUMBER;
	l_party_site_id NUMBER;
	l_payee_id NUMBER;
	l_payee_level  VARCHAR2(30);
	l_vendor_type_lookup_code VARCHAR2(30);
	l_end_date DATE;
	l_payee IBY_DISBURSEMENT_SETUP_PUB.PayeeContext_Rec_Type;
	l_assignment IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
	l_assignment_tab IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_tbl_type;
	l_response IBY_FNDCPT_COMMON_PUB.Result_rec_type;
	l_payer_attribs IBY_FNDCPT_SETUP_PUB.PayerAttributes_rec_type;
  l_module_name VARCHAR2(2000) := g_pkg_name||'process_bank_account_uses';

	BANK_USES_EXCEPTION EXCEPTION;

BEGIN
	l_user_id := fnd_global.user_id;
	l_login_id := fnd_global.login_id;

	SELECT party_id,vendor_type_lookup_code
	INTO l_party_id,l_vendor_type_lookup_code
	FROM ap_suppliers
	WHERE vendor_id=p_vendor_id;

	SELECT party_site_id INTO l_party_site_id
	FROM ap_supplier_sites_all
	WHERE vendor_site_id = p_pay_site_id;

       if(nvl(l_party_id,0) <> 0 and nvl(p_new_bank_account_id,0) <> 0) THEN
	   add_owner_party(l_party_id,p_new_bank_account_id);
       end if;



	IF l_vendor_type_lookup_code = 'EMPLOYEE' THEN
	             l_payee.payment_function  := 'EMPLOYEE_EXP';
	ELSE
	             l_payee.payment_function  := 'PAYABLES_DISB';
	END IF;

	l_payee.party_id := l_party_id;
	l_payee.Org_Type := 'OPERATING_UNIT';
	l_payee.Org_Id   := p_org_id;
	l_payee.party_site_Id := l_party_site_id;
	l_payee.Supplier_Site_Id := p_pay_site_id;


  get_payee_id
	(
	p_payee_context => l_payee,
	x_payee_id => l_payee_id
	);

	IF (l_payee_id IS NULL) THEN
		raise BANK_USES_EXCEPTION;
	END IF;

	IF (p_account_uses_upd_flag = 'Y' AND nvl(p_vendor_id,0)<>0
		AND (p_federal_vendor='N' OR p_valid_bank_info='Y')) THEN

		l_assignment.Instrument.instrument_Type := 'BANKACCOUNT';
		l_assignment.Instrument.instrument_Id := p_old_bank_account_id;
		--Bug8405987
		--l_assignment.end_date := p_file_date-1;
	        --Bug9142398
		--l_assignment.end_date := p_file_date;
		l_assignment.end_date:= sysdate-1;

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
        'Calling set payee instr assignment');

          IBY_DISBURSEMENT_SETUP_PUB.Set_Payee_Instr_Assignment(
			    p_api_version => l_api_version,
			    p_init_msg_list  => FND_API.G_FALSE,
			    p_commit => FND_API.G_FALSE,
			    x_return_status => l_return_status,
			    x_msg_count => l_msg_count,
			    x_msg_data => l_msg_data,
			    p_payee => l_payee,
			    p_assignment_attribs => l_assignment,
			    x_assign_id => l_assign_id,
			    x_response  => l_response);

		if(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			RAISE BANK_USES_EXCEPTION;
		end if;
	END IF;

	IF(nvl(p_old_bank_account_id,0)=0 AND nvl(p_vendor_id,0)<>0
		 AND nvl(p_pay_site_id,0)<>0  AND
		(p_valid_bank_info='Y' OR p_federal_vendor='N')) THEN

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,
         'Updating iby_pmt_instr_uses_all with end date');

		UPDATE iby_pmt_instr_uses_all
		SET END_DATE = sysdate-1,
	          last_update_date=sysdate,
	          last_updated_by=l_user_id,
	          last_update_login=l_login_id
	        WHERE instrument_id <> p_new_bank_account_id
	        AND EXT_PMT_PARTY_ID = l_payee_id
	        AND END_DATE IS NULL;
	END IF;

	IF(nvl(p_vendor_id,0)<>0 AND
		(p_account_uses_insert_flag = 'I' OR p_account_uses_insert_flag = 'U') AND
		 (p_valid_bank_info='Y' OR p_federal_vendor='N')) THEN

	        l_uses_reln_exists := 'N';
	        IF(p_account_uses_insert_flag = 'U') THEN

			IBY_DISBURSEMENT_SETUP_PUB.Get_Payee_Instr_Assignments(
			p_api_version => l_api_version,
			p_init_msg_list => FND_API.G_FALSE,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			p_payee => l_payee,
			x_assignments => l_assignment_tab,
			x_response => l_response);

			if(l_assignment_tab.count > 0) THEN

	        	FOR i IN l_assignment_tab.FIRST .. l_assignment_tab.LAST
			LOOP
			IF l_assignment_tab(i).Instrument.Instrument_Id = p_new_bank_account_id
			   and l_assignment_tab(i).Instrument.instrument_Type = 'BANKACCOUNT' THEN

			   l_uses_reln_exists := 'Y';
			   if(l_assignment_tab(i).end_date IS NULL) THEN
			      l_end_date := NULL;
			      l_assign_id := l_assignment_tab(i).Assignment_Id;
			      EXIT;
			   elsif (l_end_date IS NULL OR trunc(l_assignment_tab(i).end_date) > trunc(l_end_date)) THEN
			      l_end_date := l_assignment_tab(i).end_date;
			      l_assign_id := l_assignment_tab(i).Assignment_Id;
			   end if;
			END IF;

			END LOOP;

			END IF;

			if(l_uses_reln_exists = 'Y') THEN

				IF(l_end_date IS NOT NULL) THEN
					UPDATE iby_pmt_instr_uses_all
					SET end_date=null,
					 start_date=p_file_date,
					 last_update_date = sysdate,
					 last_updated_by = l_user_id,
				       last_update_login=l_user_id
				WHERE (l_assign_id IS NOT NULL AND INSTRUMENT_PAYMENT_USE_ID=l_assign_id);
				END IF;

			end if;
		END IF;

		IF (l_uses_reln_exists = 'N' OR p_account_uses_insert_flag = 'I') THEN

			l_assignment.Instrument.instrument_Type := 'BANKACCOUNT';
			l_assignment.Instrument.instrument_Id := p_new_bank_account_id;
			l_assignment.end_date := null;

			IBY_DISBURSEMENT_SETUP_PUB.Set_Payee_Instr_Assignment(
					    p_api_version => l_api_version,
					    p_init_msg_list  => FND_API.G_FALSE,
					    p_commit => FND_API.G_FALSE,
					    x_return_status => l_return_status,
					    x_msg_count => l_msg_count,
					    x_msg_data => l_msg_data,
					    p_payee => l_payee,
					    p_assignment_attribs => l_assignment,
					    x_assign_id => l_assign_id,
			    		x_response  => l_response);


			if(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
					RAISE BANK_USES_EXCEPTION;
			end if;
		END IF;
	END IF;

EXCEPTION
WHEN OTHERS THEN
  RAISE ;

END process_bank_account_uses;


FUNCTION check_taxpayerid_diff(p_vendor_id IN number, p_duns varchar2) RETURN VARCHAR2
is
l_ccr_tin varchar2(30);
l_supplier_tin varchar2(30);
l_different_tin varchar2(1) := 'N';

l_module_name varchar2(60);
begin
  l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.check_taxpayerid_diff';
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');

    begin
    select nvl(taxpayer_id, null) into l_ccr_tin from fv_ccr_vendors where duns = p_duns;
    select nvl(num_1099, null) into l_supplier_tin from ap_suppliers where vendor_id = p_vendor_id;

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_ccr_tin: '||l_ccr_tin);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_supplier_tin: '||l_supplier_tin);

    if (l_supplier_tin is null or l_ccr_tin is null)then
        l_different_tin := 'N';
    elsif l_supplier_tin <> l_ccr_tin then
        l_different_tin := 'Y';
    end if;
    exception when others then
        null;
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,sqlerrm);
    end;

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Returning -> l_diffferent_tin: '||l_different_tin);
  FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');

    return l_different_tin;
end check_taxpayerid_diff;

FUNCTION get_ext_cert_val(p_duns varchar2, p_code varchar2) return varchar2
is
    l_ext_cert_val varchar2(200);
	l_module_name VARCHAR2(60);

begin
    l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.get_ext_cert_val';
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');

if (p_code = 'DFD') then
    begin
    select meaning into l_ext_cert_val
    from fnd_lookup_values
    where lookup_type like 'FV_EXTERNAL_CERTIFICATION'
    and lookup_code =(select code from fv_ccr_class_codes where duns = p_duns
                   and codetype like 'External Certification' AND code like 'DFD%'
                   AND ROWNUM <=1)
    and language = Userenv('LANG');
    exception when no_data_found then
    null;
    end;


elsif (p_code = 'EPL') then
    begin
    select meaning into l_ext_cert_val
    from fnd_lookup_values
    where lookup_type like 'FV_EXTERNAL_CERTIFICATION'
    and lookup_code =(select code from fv_ccr_class_codes where duns = p_duns
                   and codetype like 'External Certification' AND code like 'EPL%'
                   AND ROWNUM <=1)
    and language = Userenv('LANG');
    exception when no_data_found then
    null;
    end;

end if;

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Returning meaning :'||l_ext_cert_val);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');
return l_ext_cert_val;

EXCEPTION
WHEN OTHERS THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
	return null;
END get_ext_cert_val;


function get_ccr_flag_code(p_duns varchar2) return varchar2
is
    l_flag_code varchar2(200) := ' ';
    l_module_name VARCHAR2(60);
	l_flagtype varchar2(60);
	l_flagval varchar2(60);

begin
    l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.get_ccr_flag_code';
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');
    select flagtype, flagval into l_flagtype, l_flagval
    from fv_ccr_flags where duns = p_duns and rownum<=1;

    if(l_flagtype = 'NPD' AND l_flagval = 'Y') then
        begin
        select meaning into l_flag_code
        from fnd_lookup_values
        where lookup_type like 'FV_CCR_FLAGS'
        and lookup_code = l_flagtype||l_flagval
        and language = Userenv('LANG');
        exception when no_data_found then
        null;
        end;

     ELSIF (l_flagtype = 'NPD') then
        begin
        select meaning into l_flag_code
        from fnd_lookup_values
        where lookup_type like 'FV_CCR_FLAGS'
        and lookup_code = l_flagtype
        and language = Userenv('LANG');
        exception when no_data_found then
        null;
        end;


    END IF;

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');
return l_flag_code;
EXCEPTION
WHEN OTHERS THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
	return l_flag_code;
end get_ccr_flag_code;


function get_ccr_numerics(p_duns varchar2, p_code varchar2) return number
is
    l_numerics_code number;
    l_module_name VARCHAR2(60);
    l_lse number;
    l_lsr number;
	l_cblc number;
	l_cbla number;
	l_sblc number;
	l_sbla number;
	l_bk number;
	l_pg number;
	l_pt number;

begin
    l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.get_ccr_numerics';

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_duns: '||p_duns);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_code: '||p_code);

    if(p_code in ('LSE', 'LSR')) then
        begin
        select  substr(code, (instr(code, '^', 1,1) + 1), ((instr(code, '^', 1,2)- instr(code, '^', 1,1))-1) ) ,
                substr(code, (instr(code, '^', 1,2) + 1), ((instr(code, '^', 1,3)- instr(code, '^', 1,2))-1) )
        into l_lse, l_lsr
        from fv_ccr_class_codes where duns = p_duns and codetype like 'CCR Numerics' and code like 'LS%'
        and rownum<=1;
        exception when no_data_found then
        null;
        end;
    end if;


    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_lse: '||l_lse);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_lsr: '||l_lsr);

    if (p_code in ('CBLC', 'CBLA', 'SBLC', 'SBLA')) then
        begin
        select  substr(code, (instr(code, '^', 1,1) + 1), ((instr(code, '^', 1,2)- instr(code, '^', 1,1))-1) ) ,
                substr(code, (instr(code, '^', 1,2) + 1), ((instr(code, '^', 1,3)- instr(code, '^', 1,2))-1) ) ,
                substr(code, (instr(code, '^', 1,3) + 1), ((instr(code, '^', 1,4)- instr(code, '^', 1,3))-1) ) ,
                substr(code, (instr(code, '^', 1,4) + 1), ((length(code)- instr(code, '^', 1,4))) )
        into l_cblc, l_cbla, l_sblc, l_sbla
        from fv_ccr_class_codes where duns = p_duns and codetype like 'CCR Numerics' and code like 'BL%'
        and rownum<=1;
        exception when no_data_found then
        null;
        end;
    end if;

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_cblc: '||l_cblc);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_cbla: '||l_cbla);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_sblc: '||l_sblc);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_sbla: '||l_sbla);

    if(p_code = 'BK') then
        begin
        select  substr(code, (instr(code, '^', 1,1) + 1), ((instr(code, '^', 1,2)- instr(code, '^', 1,1))-1) )
        into l_bk
        from fv_ccr_class_codes where duns = p_duns and codetype like 'CCR Numerics' and code like 'BK%'
        and rownum<=1;
        exception when no_data_found then
        null;
        end;
    end if;

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_bk: '||l_bk);
    if(p_code = 'PG') then
        begin
        select  substr(code, (instr(code, '^', 1,1) + 1), ((instr(code, '^', 1,2)- instr(code, '^', 1,1))-1) )
        into l_pg
        from fv_ccr_class_codes where duns = p_duns and codetype like 'CCR Numerics' and code like 'PG%'
        and rownum<=1;
        exception when no_data_found then
        null;
        end;
    end if;

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_pg: '||l_pg);

    if(p_code = 'PT') then
        begin
        select  substr(code, (instr(code, '^', 1,1) + 1), ((instr(code, '^', 1,2)- instr(code, '^', 1,1))-1) )
        into l_pt
        from fv_ccr_class_codes where duns = p_duns and codetype like 'CCR Numerics' and code like 'PT%'
        and rownum<=1;
        exception when no_data_found then
        null;
        end;
    end if;

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_pt: '||l_pt);

    l_numerics_code := case p_code
                            when 'LSE' then l_lse
                            when 'LSR' then l_lsr
                            when 'CBLC' then l_cblc
                            when 'CBLA' then l_cbla
                            when 'SBLC' then l_sblc
                            when 'SBLA' then l_sbla
                            when 'BK' then l_bk
                            when 'PG' then l_pg
                            when 'PT' then l_pt
                        end;

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'l_numerics_code: '||l_numerics_code);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');
return l_numerics_code;

EXCEPTION
WHEN OTHERS THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
	return l_numerics_code;
end get_ccr_numerics;

FUNCTION get_disaster_code(p_duns varchar2, p_code varchar2) return varchar2
is
    l_dis_code_val varchar2(200) := ' ';
	l_module_name VARCHAR2(60);

begin
    l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.get_disaster_code';
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_duns : '||p_duns);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'p_code : '||p_code);

if (substr(p_code, 1, 3) = 'STA') then
    begin
    select lpad('State :', 33)||substr(p_code,4)||' - '||meaning
    into l_dis_code_val
    from fnd_lookup_values flv
    where flv.lookup_type = 'FV_DIS_CODE_STATE'
    and flv.lookup_code = substr(p_code, 4)
    and flv.language = userenv('LANG')
    and rownum<=1;
    exception when no_data_found then
    null;
    end;


elsif (substr(p_code, 1, 3) = 'CTY') then
    begin
    select lpad('County :', 33)||substr(p_code,4)||' - '||meaning
    into l_dis_code_val
    from fnd_lookup_values flv
    where flv.lookup_type = 'FV_DIS_CODE_COUNTY'
    and flv.lookup_code = substr(p_code, 4)
    and flv.language = userenv('LANG')
    and rownum<=1;
    exception when no_data_found then
    null;
    end;


elsif (substr(p_code, 1,3) = 'MSA') then
    begin
    select lpad('Metropolitan Statistical Area :', 33)||substr(p_code,4)||' - '||meaning
    into l_dis_code_val
    from fnd_lookup_values flv
    where flv.lookup_type = 'FV_DIS_CODE_MSA'
    and flv.lookup_code = substr(p_code, 4)
    and flv.language = userenv('LANG')
    and rownum<=1;
    exception when no_data_found then
    null;
    end;


elsif (substr(p_code, 1,3) = 'ANY') then
    begin
    select substr(p_code,4)||' - '||meaning
    into l_dis_code_val
    from fnd_lookup_values flv
    where flv.lookup_type = 'FV_DIS_CODE_ANY'
    and flv.lookup_code = substr(p_code, 4)
    and flv.language = userenv('LANG')
    and rownum<=1;
    exception when no_data_found then
    null;
    end;


end if;

    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'Returning l_dis_code_val :'||l_dis_code_val);
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');
return l_dis_code_val;

EXCEPTION
WHEN OTHERS THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
	return l_dis_code_val;
END get_disaster_code;

function get_supplier_debarred ( p_supplier_id in number,
                                 p_supplier_site_id in number,
                                 p_reference_date in date default sysdate,
                                 x_return_status out nocopy varchar2,
                                 x_msg_data varchar2) return boolean
is
    l_duns_number fv_ccr_vendors.duns%type;
    l_module_name VARCHAR2(60);
    l_debar_code fv_ccr_class_codes.code%type;

begin
    l_module_name := 'fv.plsql.FV_CCR_UTIL_PVT.get_supplier_debarred';
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'BEGIN');

	select fcc.code into l_debar_code
	from fv_ccr_vendors fcv, fv_ccr_class_codes fcc, fv_ccr_orgs fco
	where fcv.duns = fcc.duns(+)
	and fcv.ccr_id = fco.ccr_id(+)
	and fcv.vendor_id = p_supplier_id
	and fco.pay_site_id = p_supplier_site_id;

    if(l_debar_code = 'EPLD') then
    return true;
    else
    return false;

    END IF;

        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,l_module_name,'END');

EXCEPTION
WHEN OTHERS THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name,sqlerrm);
	return false;
end get_supplier_debarred;

END FV_CCR_UTIL_PVT;


/
