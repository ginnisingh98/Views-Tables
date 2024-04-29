--------------------------------------------------------
--  DDL for Package Body AR_EXCHANGE_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_EXCHANGE_INTERFACE_PKG" as
/*$Header: AREXINPB.pls 120.7 2005/07/19 12:58:10 naneja noship $ */

custcount			NUMBER := 0;
g_commit_level 			NUMBER := 100;
g_org_id 			NUMBER;
g_oper_id 			NUMBER;
l_sql_stmt			varchar2(2000);
g_oexdblink 			varchar2(100);
init_error			EXCEPTION;
g_bank_name			varchar2(60);
g_branch_name			varchar2(60);
g_inv_trxtype_name		varchar2(20);
g_cred_trxtype_name		varchar2(20);
g_payment_method_billme 	varchar2(240) ;
g_payment_method_credit 	varchar2(240) ;
g_payment_method_eft    	varchar2(240) ;
g_error_msg_nobankerr		varchar2(255);
g_error_msg_nobankact		varchar2(255);
g_error_msg_custintferr		varchar2(255);
g_error_msg_custintfact		varchar2(255);
g_error_msg_invintferr		varchar2(255);
g_error_msg_invintfact		varchar2(255);
g_is_debug_enabled		varchar2(10) := 'N';



TYPE OexCustRecTyp IS RECORD (
operator_id 		NUMBER,
billing_customer_id 	NUMBER(15),
orig_sys_cust_ref 	VARCHAR2(240),
orig_sys_addr_ref 	varchar2(240),
bill_to_party_id  	number(15),
site_use_id  		number(15),
contact_party_id  	number(15),
creation_date		DATE,
last_update_date	DATE,
customer_name		VARCHAR2(50),
party_number		VARCHAR2(30),
address1		varchar2(240),
address2		varchar2(240),
address3		varchar2(240),
address4		varchar2(240),
city			varchar2(60),
county			varchar2(60),
state			varchar2(60),
country			varchar2(60),
postal_plus4_code	varchar2(10),
bank_name		varchar2(30),
account_name		varchar2(80),
account_number		varchar2(80),
account_currency	varchar2(15),
account_description	varchar2(240),
account_exp_date	DATE,
payment_method_code	varchar2(30),
insert_update_flag	varchar2(10),
org_id			number(15)
);

g_osr_cust_prefix varchar2(100) ;
g_osr_addr_prefix varchar2(100) ;

l_invalid_value			varchar2(255);
l_action_reqd_msg		varchar2(255);

LEVEL0 CONSTANT NUMBER := 0;
LEVEL2 CONSTANT NUMBER := 2;
LEVEL4 CONSTANT NUMBER := 4;
LEVEL_MIDDLE CONSTANT NUMBER := 16;
OUTPUT_LINE_WIDTH CONSTANT NUMBER := 40;

FUNCTION billing_cycle_end_date(
	p_cutoff_date IN date,
	p_last_billed_date IN date ) return date IS
l_cycle_end_date date;
BEGIN
	l_cycle_end_date := p_last_billed_date;

	while (add_months(l_cycle_end_date,1) <= p_cutoff_date) loop
		l_cycle_end_date := add_months(l_cycle_end_date,1);
	end loop;

	return l_cycle_end_date;

END billing_cycle_end_date;

FUNCTION  get_fnd_lookup(
	p_lookup_type IN VARCHAR2,
	p_lookup_code IN VARCHAR2 ) RETURN VARCHAR2 IS
CURSOR c_lkp IS
	select  meaning
	from    fnd_lookup_values
	where   lookup_type = p_lookup_type
	and 	lookup_code = p_lookup_code
	and 	language = userenv('LANG');
l_meaning varchar2(240);
BEGIN
	for crec in c_lkp
	loop
		l_meaning := crec.meaning;
		exit;
	end loop;
	return l_meaning;
EXCEPTION
	WHEN OTHERS THEN
		raise;
END get_fnd_lookup;

PROCEDURE print_debug(
	p_indent IN NUMBER,
	p_text IN VARCHAR2 ) IS
BEGIN
	fnd_file.put_line( FND_FILE.LOG, RPAD(' ', (1+p_indent)*2)||p_text );
EXCEPTION
	WHEN OTHERS THEN
		null;
END print_debug;

/* Get new request id from sequence. For 6.1, just create on-account credit memos */
function get_inv_request_id RETURN NUMBER IS
BEGIN
	null;
EXCEPTION
	WHEN OTHERS THEN
		raise;
END get_inv_request_id;

/* Get related invoice number for a credit memo to be created against */
procedure get_related_invoice (
	p_party_id		IN number,
	p_trans_num 		IN varchar2,
	p_cm_amount		IN number,
	p_reg_cm_flag 		OUT NOCOPY varchar2,
	p_related_inv_reqid	OUT NOCOPY number
	) IS
BEGIN
	/*
	Logic:
	*	get orig transaction's request id
	*	get orig invoice number/trx_id from the request id
	*	if bal > cm_amount, invoice is still open. this becomes a regular cm.
	*	else this is on-acc cm.
	*/
	null;
EXCEPTION
	WHEN OTHERS THEN
		raise;
END get_related_invoice;

/*
 Transaction to insert into all interface records relating
 to one exchange billing customer record.
*/
PROCEDURE transfer_customer_record (
	cust_rec 	IN OexCustRecTyp,
	p_transfer_flag OUT NOCOPY varchar2
	) IS

TYPE OexContactRecTyp is RECORD (
person_title		varchar2(255),
person_first_name	varchar2(255),
person_last_name	varchar2(255),
contact_point_id	NUMBER(15),
contact_point_type	varchar2(255),
phone_line_type		varchar2(255),
phone_area_code		varchar2(255),
phone_number		varchar2(255),
phone_extension		varchar2(255),
email_address		varchar2(2000)
);

l_sql_is_dup_pay_meth varchar2(4000);
l_set_oex_cust_status  varchar2(4000);
l_set_oex_cust_errstatus  varchar2(4000);
l_oex_contacts varchar2(4000) ;


TYPE OexContactCurTyp IS REF CURSOR;
contrec_cv	OexContactCurTyp;	-- cursor variable
l_cont_rec	OexContactRecTyp; 	-- store fetched cv record into local record
						-- to pass as parameter to other procedures.

l_cust_upd_ins_flag		varchar2(10) := 'I';
						--  if customer/address(reference) exists in AR,
						--  'U'(update), else 'I'(insert)
l_payment_method_name    	varchar2(240);
l_error_code			varchar2(30);
l_error_msg			varchar2(255);
l_contact_ref			varchar2(255);
l_telephone_ref			varchar2(255);
l_telephone_type		varchar2(30);
l_account_number		varchar2(30);
l_a_null			char(1);  -- represents NULL in the dynamic statement
l_site_use_code			varchar2(100); -- site use code
l_primary_su_flag		varchar2(100); -- primary site use flag

l_sql_customers_interface	varchar2(4000) := '
INSERT INTO ra_customers_interface_all (
org_id, orig_system_customer_ref, orig_system_address_ref, insert_update_flag,
customer_name, customer_number, address1, address2, address3, address4,
city, county, state, country, postal_code,
customer_prospect_code, customer_status, customer_type,
primary_site_use_flag, site_use_code,
created_by, creation_date, last_updated_by, last_update_date
)
SELECT
:1, :2, :3, :4,
:5, :6, :7, :8, :9,
:10, :11, :12, :13, :14,
:15, :16, :17,
:18, :19,
:20, :21, :22, :23, :24
FROM DUAL ';

l_sql_profiles_interface 	varchar2(4000) := '
INSERT INTO ra_customer_profiles_int_all (
org_id, orig_system_customer_ref, insert_update_flag,
customer_profile_class_name, credit_hold,
created_by, creation_date, last_updated_by, last_update_date
)
SELECT
:1, :2, :3,
:4, :5,
:6, :7, :8, :9
FROM DUAL';

l_sql_pay_methods_interface 	varchar2(4000) := '
INSERT INTO ra_cust_pay_method_int_all (
org_id, orig_system_customer_ref, orig_system_address_ref,
payment_method_name, start_date, primary_flag,
created_by, creation_date, last_updated_by, last_update_date
)
SELECT
:1, :2, :3,
:4, :5, :6,
:7, :8, :9, :10
FROM DUAL';

l_sql_banks_interface	varchar2(4000) := '
INSERT INTO ra_customer_banks_int_all (
org_id, orig_system_customer_ref, orig_system_address_ref,
bank_account_num, bank_account_currency_code, bank_account_inactive_date,
bank_account_name,
bank_name,
bank_branch_name,
start_date, primary_flag,
created_by, creation_date, last_updated_by, last_update_date
)
SELECT
:1, :2, :3,
:4, :5, :6,
:7,
decode(:8, :9, :10, :11),
decode(:12, :13, :14, :15),
:16, :17, :18,
:19, :20, :21
FROM DUAL';

l_sql_eml_contacts_interface	varchar2(4000) := '
INSERT INTO ra_contact_phones_int_all (
org_id, orig_system_customer_ref, orig_system_address_ref,
orig_system_contact_ref,
contact_first_name, contact_last_name, contact_title,
insert_update_flag, email_address,
created_by, creation_date, last_updated_by, last_update_date
)
SELECT
:1, :2, :3,
:4,
:5, :6, :7,
:8, :9,
:10, :11, :12, :13
FROM DUAL';

l_sql_contacts_interface	varchar2(4000) := '
INSERT INTO ra_contact_phones_int_all (
org_id, orig_system_customer_ref, orig_system_address_ref,
orig_system_contact_ref, orig_system_telephone_ref,
contact_first_name, contact_last_name, contact_title,
insert_update_flag, telephone_type, telephone,
telephone_area_code, telephone_extension, email_address,
created_by, creation_date, last_updated_by, last_update_date
)
SELECT
:1, :2, :3,
:4, :5,
:6, :7, :8,
:9,
decode(:10, :11, :12, :13),
decode(:14, :15, :16, :17),
:18, :19, :20,
:21, :22, :23, :24
FROM DUAL';

TYPE PayMethodTyp IS REF CURSOR ;
pay_meth_cv		   PayMethodTyp;
l_existing_pm_name	   varchar2(30);
l_pm_ins_upd_flag 	   varchar2(10) := 'N';


BEGIN

/* Initialize dyn.sql.stmt strings */
l_oex_contacts := '
 select
 hpcont.person_pre_name_adjunct	person_title,
 hpcont.person_first_name	person_first_name,
 hpcont.person_last_name		person_last_name,
 hcp1.contact_point_id		contact_point_id,
 hcp1.contact_point_type		contact_point_type,
 hcp1.phone_line_type		phone_line_type,
 hcp1.phone_area_code		phone_area_code,
 hcp1.phone_number		phone_number,
 hcp1.phone_extension		phone_extension,
 hcp1.email_address		email_address
 from
 hz_parties'||g_oexdblink||' hpcont,
 hz_contact_points'||g_oexdblink||' hcp1
 where 	hpcont.party_id 	= :1
 and	hcp1.owner_table_id 	= hpcont.party_id
 and	hcp1.owner_table_name 	= ''HZ_PARTIES''
';

l_sql_is_dup_pay_meth := '
SELECT  rm.name
FROM 	hz_cust_accounts'||g_oexdblink||' hca,
	ar_receipt_methods rm,
	ra_cust_receipt_methods rcrm
WHERE 	hca.orig_system_reference = :1
AND	rm.name = :2
AND 	rcrm.customer_id = hca.cust_account_id
AND     rcrm.receipt_method_id = rm.receipt_method_id
AND	sysdate <= nvl(rcrm.end_date,sysdate)
';

l_set_oex_cust_status  := '
UPDATE  pom_billing_customers'||g_oexdblink||'
 SET     ar_transfer_flag = null,
    insert_update_flag = null,
    last_update_date = sysdate
WHERE   billing_customer_id = :1
';

l_set_oex_cust_errstatus  := '
UPDATE  pom_billing_customers'||g_oexdblink||'
 SET     ar_transfer_flag = ''E'',
	 request_id = null,
    	 last_update_date = sysdate
WHERE   billing_customer_id = :1
';

		custcount := custcount + 1;
		print_debug(0,'----------------------------------------- # '||to_char(custcount)||' ----');
		print_debug(0,'transfer_customer_interface + ');
		print_debug(0,'org id  is :'||to_char(cust_rec.org_id));
		print_debug(0,'customer_ref is :'||cust_rec.orig_sys_cust_ref);
		print_debug(0,'customer_name : '||cust_rec.customer_name);

		/*  Interface tables:
			-	customer interface
			-	profile interface
			-	bank interface
			-	payment method interface
			-	contact interface
		*/
		BEGIN

		if (nvl(cust_rec.insert_update_flag,'~') = 'I') then
			l_primary_su_flag := 'Y';
			l_site_use_code  := 'BILL_TO';
		else
			l_primary_su_flag := null;
			l_site_use_code  := null;
		end if;

		print_debug(0,'Begin data transfer');
		EXECUTE IMMEDIATE l_sql_customers_interface
		USING
			cust_rec.org_id,
			cust_rec.orig_sys_cust_ref,
			nvl(cust_rec.orig_sys_addr_ref,l_a_null),
			cust_rec.insert_update_flag,
			cust_rec.customer_name,
			cust_rec.party_number,
			nvl(cust_rec.address1,l_a_null),
			nvl(cust_rec.address2,l_a_null),
			nvl(cust_rec.address3,l_a_null),
			nvl(cust_rec.address4,l_a_null),
			nvl(cust_rec.city,l_a_null),
			nvl(cust_rec.county,l_a_null),
			nvl(cust_rec.state,l_a_null),
			nvl(cust_rec.country,l_a_null),
			nvl(cust_rec.postal_plus4_code,l_a_null),
			'CUSTOMER',
			'A',
			'R',
		 	nvl(l_primary_su_flag,l_a_null),
			nvl(l_site_use_code,l_a_null),
			-1,
			sysdate,
			-1,
			sysdate	;
		print_debug(0,'-inserted customer interface record.');


		if (nvl(cust_rec.insert_update_flag,'~') = 'I') then
			EXECUTE IMMEDIATE l_sql_profiles_interface
			USING
				cust_rec.org_id,
				cust_rec.orig_sys_cust_ref,
				'I',
				'DEFAULT',
				'N',
				-1,
				sysdate,
				-1,
				sysdate;
		 end if;
		 print_debug(0,'-inserted profile interface record.');

		 IF (cust_rec.payment_method_code IS NOT NULL) THEN

			IF (cust_rec.payment_method_code = 'BILL_ME') THEN
				l_payment_method_name := g_payment_method_billme;
			ELSIF (cust_rec.payment_method_code = 'EFT') THEN
				l_payment_method_name := g_payment_method_eft;
			ELSE
				l_payment_method_name := g_payment_method_credit;
			END IF;

		        OPEN pay_meth_cv FOR l_sql_is_dup_pay_meth
			    USING cust_rec.orig_sys_cust_ref, l_payment_method_name;
		        FETCH pay_meth_cv INTO  l_existing_pm_name;
		        IF  (pay_meth_cv%NOTFOUND) THEN

			    -- no payment method exists for sysdate, insert one
			    l_pm_ins_upd_flag := 'I';
		        END IF;

		        IF (pay_meth_cv%ISOPEN) THEN
		    	    CLOSE pay_meth_cv;
		        END IF;

			IF ( l_pm_ins_upd_flag = 'I') THEN
				EXECUTE IMMEDIATE l_sql_pay_methods_interface
				USING
					cust_rec.org_id,
					cust_rec.orig_sys_cust_ref,
					cust_rec.orig_sys_addr_ref,
					l_payment_method_name,
					sysdate,
					'N',
					-1,
					sysdate,
					-1,
					sysdate;
			END IF;
		    END IF; -- if cust_rec.payment_method_code
		    print_debug(0,'-inserted payment method interface record.');

		    --
		    -- Insert bank account information only for automatic payment methods
		    -- like credit_card  and eft. For bill_me (manual payment), we do not
		    -- capture account number during registration.
		    --
		    IF ( (cust_rec.payment_method_code <> 'BILL_ME') AND
		         (cust_rec.account_number IS NOT NULL) ) THEN

			l_account_number := null;
			print_debug(0,'-inserting bank interface record.');
			EXECUTE IMMEDIATE '
			   BEGIN
			     pom_billing_util_pkg.get_util_info_w'||g_oexdblink||'(
				i_old_info => :a,
				i_info	   => :b );
			   END;
			'
			USING IN cust_rec.account_number, IN OUT l_account_number;



			print_debug(0,'l_account_number = ['||l_account_number||']');
			EXECUTE IMMEDIATE l_sql_banks_interface
			USING
				cust_rec.org_id,
				cust_rec.orig_sys_cust_ref,
				nvl(cust_rec.orig_sys_addr_ref,l_a_null),
				l_account_number,
				nvl(cust_rec.account_currency,l_a_null),
				nvl(cust_rec.account_exp_date,	l_a_null),
				nvl(cust_rec.account_name,cust_rec.customer_name),
				cust_rec.payment_method_code,'CREDIT_CARD',g_bank_name,cust_rec.bank_name,
				cust_rec.payment_method_code,'CREDIT_CARD',g_branch_name,cust_rec.bank_name,
				sysdate,
				'N',
				-1,
				sysdate,
				-1,
				sysdate;
			print_debug(0,'-inserted bank account interface record.');
		    END IF; -- if cust_rec.payment_method_code

		    print_debug(0,'-inserting contact interface record.');
		    IF (cust_rec.contact_party_id IS NOT NULL) THEN

	  	        l_contact_ref := cust_rec.orig_sys_addr_ref||'_CONT'||cust_rec.contact_party_id;

			OPEN contrec_cv FOR l_oex_contacts
			USING
				cust_rec.contact_party_id;

			LOOP
			    FETCH contrec_cv INTO l_cont_rec;
			    EXIT WHEN contrec_cv%NOTFOUND;

			    if (l_cont_rec.contact_point_type = 'EMAIL') then
				print_debug(0,'- EMAIL contact .');

				-- for email contact type, phone_ref, phone_number and phone_type are null.
				EXECUTE IMMEDIATE l_sql_eml_contacts_interface
				USING
				cust_rec.org_id,
				cust_rec.orig_sys_cust_ref,
				cust_rec.orig_sys_addr_ref,
				l_contact_ref,
				l_cont_rec.person_first_name,
				l_cont_rec.person_last_name,
				l_cont_rec.person_title,
				cust_rec.insert_update_flag,
				l_cont_rec.email_address,
				-1,
				sysdate,
				-1,
				sysdate;
			    else
				print_debug(0,'- PHONE/FAX contact .');
				-- for contact types other than email.
				-- Deliberately making decode of contact_point_type result in phone_line_type
				-- and phone_number by using '1' and '2'.
				-- Valid contact point types are 'FAX','PHONE'.
				--
			    	l_telephone_ref := cust_rec.orig_sys_addr_ref||'_PHONE'||l_cont_rec.contact_point_id;
				EXECUTE IMMEDIATE l_sql_contacts_interface
				USING
				cust_rec.org_id,
				cust_rec.orig_sys_cust_ref,
				cust_rec.orig_sys_addr_ref,
				l_contact_ref,
				l_telephone_ref,
				l_cont_rec.person_first_name,
				l_cont_rec.person_last_name,
				l_cont_rec.person_title,
				cust_rec.insert_update_flag,
				l_cont_rec.contact_point_type, '1','2',l_cont_rec.phone_line_type,
				l_cont_rec.contact_point_type, '1','2',l_cont_rec.phone_number,
				l_cont_rec.phone_area_code,
				l_cont_rec.phone_extension,
				l_cont_rec.email_address,
				-1,
				sysdate,
				-1,
				sysdate;
			    end if;
			    print_debug(0,'-inserted contact-telephone interface record.');
			END LOOP;

			IF (contrec_cv%ISOPEN) THEN
				CLOSE contrec_cv;
			END IF;
		    END IF;

		    -- success
		    EXECUTE IMMEDIATE l_set_oex_cust_status
		    USING
			cust_rec.billing_customer_id;
		    p_transfer_flag := 'T';

		    print_debug(0,'-updated transfer flag .');

		print_debug(0,'transfer_customer_interface - ');

	        EXCEPTION
		    WHEN OTHERS THEN
		        -- failure
			p_transfer_flag := 'E';

		        EXECUTE IMMEDIATE l_set_oex_cust_errstatus
		        USING
			    cust_rec.billing_customer_id;

			print_debug(0,'Insert error: '||sqlerrm);

			raise;
	        END;
END transfer_customer_record;


/*
 Create customer record in AR for billing party in Exchange.
*/

procedure customer_interface (
	p_bill_to_party_id 	IN NUMBER default null,
	p_bill_to_site_use_id 	IN NUMBER default null,
	p_conc_request_id	IN NUMBER default null,
	x_error_code 		OUT NOCOPY varchar2,
	x_error_msg  		OUT NOCOPY varchar2
	) IS

l_oex_cust 		varchar2(8000);
l_error_code		varchar2(30);
l_error_msg		varchar2(255);
l_transfer_flag		varchar2(10);   --  Indicates success/failure of customer record transfer
l_request_id 		NUMBER(15);


l_set_oex_cust_err varchar2(4000);
l_set_pom_cust_upd varchar2(4000);
TYPE OexCustCurTyp IS REF CURSOR;
oex_cust_rec_cv 	OexCustCurTyp;	-- cursor variable
l_oex_cust_rec		OexCustRecTyp; 	-- store fetched cv record into local record

l_sql_get_bank_info  varchar2(4000) := '
SELECT  bbr.bank_name, bbr.bank_branch_name
FROM    ce_bank_branches_v  bbr
WHERE 	bbr.branch_party_id = arp_global.CC_BANK_BRANCH_ID
';

BEGIN
	print_debug(0,'customer_interface +');

/* Initialize dyn.sql.stmt strings */
l_oex_cust := '
SELECT
pbc.operator_id			operator_id,
pbc.billing_customer_id		billing_customer_id, '||
''''||g_osr_cust_prefix||''''||' ||to_char(pbc.bill_to_party_id)	orig_sys_cust_ref,'||
''''||g_osr_cust_prefix||''''||' ||to_char(pbc.bill_to_party_id)|| '||''''||g_osr_addr_prefix||''''||' ||to_char(pbc.bill_to_site_use_id)  orig_sys_addr_ref,
pbc.bill_to_party_id		bill_to_party_id,
pbc.bill_to_site_use_id		site_use_id,
pbc.bill_to_contact_party_id	contact_party_id,
pbc.creation_date		creation_date,
pbc.last_update_date		last_update_date,
substr(hp.party_name,1,50)	customer_name,
hp.party_number			party_number,
hloc.address1			address1,
hloc.address2			address2,
hloc.address3			address3,
hloc.address4			address4,
hloc.city			city,
hloc.county			county,
hloc.state			state,
hloc.country			country,
hloc.postal_plus4_code		postal_plus4_code,
pbc.bank_name			bank_name,
pbc.account_name		account_name,
pbc.account_number		account_number,
pbc.account_currency		account_currency,
pbc.account_description		account_description,
pbc.account_inactive_date 	account_exp_date,
pbc.payment_method_name		payment_method_code,
nvl(pbc.insert_update_flag,''I'')	insert_update_flag,
pbsp.org_id			org_id
FROM
pom_billing_customers'||g_oexdblink||' pbc,
hz_party_site_uses'||g_oexdblink||' hpsu,
hz_party_sites'||g_oexdblink||' hps,
hz_locations'||g_oexdblink||' hloc,
hz_parties'||g_oexdblink||' hp,
pom_billing_seat_parameters'||g_oexdblink||' pbsp
WHERE   hp.party_id 		= pbc.bill_to_party_id
AND     hps.party_id 		= hp.party_id
AND     hpsu.party_site_use_id 	= pbc.bill_to_site_use_id
AND	hpsu.site_use_type	= ''EXCHANGE_BILLING''
AND     hpsu.party_site_id 	= hps.party_site_id
AND     hps.location_id 	= hloc.location_id
AND	pbsp.operator_id	= pbc.operator_id
AND     pbc.request_id 		= :1
';

l_set_oex_cust_err := '
UPDATE  pom_billing_customers'||g_oexdblink||'
 SET 	ar_transfer_flag = ''E'',
	request_id = null,
	last_update_date = sysdate
WHERE   ar_transfer_flag = ''N''
AND	request_id = :1
';

l_set_pom_cust_upd := '
UPDATE  pom_billing_customers'||g_oexdblink||'
 SET 	request_id = :1,
ar_transfer_flag = ''N'',
last_update_date = sysdate
WHERE   ( ((nvl(ar_transfer_flag,''~'') = ''N'') AND request_id is null)
OR	(nvl(ar_transfer_flag,''~'') = ''E'')
)
';

	custcount := 0; -- running count of # of customer records imported

	l_request_id := p_conc_request_id;

	print_debug(0,'Updating pbc with request_id : '||to_char(l_request_id));
	begin


		EXECUTE IMMEDIATE l_set_pom_cust_upd
		USING
			l_request_id;

		print_debug(0,'Rows updated: '||to_char(sql%rowcount));
	exception
		when others then
			raise;
	end;

	BEGIN
		/* get  bank branch information */
		EXECUTE IMMEDIATE l_sql_get_bank_info
		INTO  g_bank_name, g_branch_name;
		print_debug(LEVEL0, 'CC Bank Name: '||g_bank_name);
		print_debug(LEVEL0, 'CC Bank Branch Name: '||g_branch_name);

		IF ( g_bank_name is null ) THEN
		   l_error_code := 'AR_OEX_CC_BANK_FETCH_ERR';
		   print_debug(0,' Unable to fetch bank_name,bank_branch_name for automatic payment method.');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			print_debug(LEVEL0, 'Error from l_sql_get_bank_info'||sqlerrm);
	END;

	print_debug(0,'-----------------------------');
	print_debug(0,'SQL for oex_cust_rec_cv is : ');
	print_debug(0,'-----------------------------');

	print_debug(0, l_oex_cust );

	print_debug(0,'-----------------------------');
	print_debug(0,'Opening cursor variable oex_cust_rec_cv ...');
	OPEN oex_cust_rec_cv FOR l_oex_cust USING l_request_id;

	print_debug(0,'Fetching data...');
	LOOP

	    FETCH oex_cust_rec_cv INTO l_oex_cust_rec;
	    EXIT WHEN oex_cust_rec_cv%NOTFOUND;

	    BEGIN
		l_error_code := null;
		l_error_msg := null;

		-- Transaction to transfer all related interface records for one customer.

		if (mod(custcount,g_commit_level) = 0) then
			-- set savepoint once for each batch of g_commit_level records
			savepoint A;
		end if;

		transfer_customer_record (
			l_oex_cust_rec ,
			l_transfer_flag
			);

		if (mod(custcount,g_commit_level) = 0) then
			-- commit for each batch of g_commit_level records imported
			commit;
		end if;

	    EXCEPTION
		WHEN OTHERS THEN
			l_error_msg := g_error_msg_custintferr;
			l_action_reqd_msg := g_error_msg_custintfact;

			rollback to A;

			ar_exchange_interface_pkg.record_error(
			   p_billing_activity_id 	=> null,
			   p_billing_customer_id 	=> null,
			   p_customer_name 		=> null,
			   p_error_code 		=> 'POM_BILL_CUST_INTF_ERR',
			   p_additional_message		=> l_error_msg||' '||sqlerrm,
			   p_action_required		=> l_action_reqd_msg,
			   p_invalid_value		=> l_invalid_value
			);
	    END;

	END LOOP;

	IF (oex_cust_rec_cv%ISOPEN) THEN
		print_debug(0,'Closing cursor.');
		CLOSE oex_cust_rec_cv;
	END IF;

	commit; -- commit last batch of records
	x_error_code := 'S';

	print_debug(0,'customer_interface -');

EXCEPTION
	WHEN OTHERS THEN
		/*
		Update records with error flag. Req-id stays so we can report
		on failed requests. Additionally we should insert failure
		codes/messages into pom_billing_interface_errors.(tablename, pk_of_table,
		error_code, error_msg, status) where status can be 'ERROR','CORRECTED'
		*/
		print_debug(0,'ar_exchange_interface_pkg.customer_interface raised following exception: ');
		l_error_code := 'AR_INTERFACE_PROGRAM_ERROR';
		l_action_reqd_msg := g_error_msg_custintfact;

		print_debug(0,'SQLERRM: '||sqlerrm);
		print_debug(0,'PROGRAM ERROR CODE: '||l_error_code);
		print_debug(0,'Check Exceptions page for more information and action required.');


		--EXECUTE IMMEDIATE l_set_oex_cust_err USING l_request_id;

		ar_exchange_interface_pkg.record_error(
		   p_billing_activity_id 	=> null,
		   p_billing_customer_id 	=> null,
		   p_customer_name 		=> null,
		   p_error_code 		=> l_error_code,
		   p_additional_message		=> sqlerrm,
		   p_action_required		=> l_action_reqd_msg,
		   p_invalid_value		=> l_invalid_value
		);
		x_error_code := l_error_code;

		IF (oex_cust_rec_cv%ISOPEN) THEN
			CLOSE oex_cust_rec_cv;
		END IF;

END customer_interface;

/* Invoice interface */
procedure invoice_interface (
	p_cutoff_date 		IN date default null ,
	p_customer_name 	IN VARCHAR2 default null ,
	p_conc_request_id	IN NUMBER default null,
	x_error_code 		OUT NOCOPY varchar2,
	x_error_msg  		OUT NOCOPY varchar2
	) IS


TYPE BillActivityCurTyp IS REF CURSOR;
bill_act_cv	BillActivityCurTyp;	-- cursor variable

l_sql_billing_activities varchar2(4000) := '
	SELECT
		pba.bill_to_party_id			bill_to_party_id,
		pba.transaction_type 			trans_type,
		rtrim(pbat.billing_activity_type_name) 	activity_type_name,
		pbat.billing_activity_type_id		activity_type_id,
		pba.transaction_num 			trans_num,
		sum(pba.total_fee)			total_fee
	FROM
		pom_billing_activities'||g_oexdblink||' pba,
		pom_billing_activity_types_tl'||g_oexdblink||' pbat
	WHERE   pba.request_id = :1
	AND	pbat.billing_activity_type_id = pba.billing_activity_type_id
	AND	pbat.language_code = ''US''
	GROUP BY
		pba.bill_to_party_id,
		pba.transaction_type,
		rtrim(pbat.billing_activity_type_name),
		pbat.billing_activity_type_id,
		pba.transaction_num
	ORDER BY
		pba.bill_to_party_id,
		pba.transaction_type,
		pbat.billing_activity_type_id,
		pba.transaction_num
';
TYPE BillActivityRec IS RECORD (
	bill_to_party_id	number(15),
	trans_type		varchar2(80),
	activity_type_name	varchar2(255),
	activity_type_id	number(15),
	trans_num		varchar2(80),
	total_fee		NUMBER
);
ba_rec  	BillActivityRec;


TYPE CustDetailsCurTyp IS REF CURSOR;
cust_details_cv	CustDetailsCurTyp;	-- cursor variable
l_sql_cust_details varchar2(4000);

TYPE CustDetailsRec IS RECORD (
	customer_name		varchar2(50),
	billing_customer_id	NUMBER(15),
	bill_to_site_use_id	NUMBER(15),
	payment_method_code	varchar2(30),
	account_number		varchar2(80),
	org_id			NUMBER(15),
	set_of_books_id		NUMBER(15),
	orig_system_prefix	varchar2(100),
	cust_trxtype_name	varchar2(20),
	payment_term_name	varchar2(100),
	batch_source_name	varchar2(100),
	interface_line_context	varchar2(240),
	orig_sys_cust_ref	varchar2(240),
	orig_sys_addr_ref	varchar2(240)
);
custrec 	CustDetailsRec;

TYPE BankAccountTyp IS REF CURSOR ;
bank_acc_cv	BankAccountTyp;
TYPE ra_intf_line_rectype is RECORD (
	bill_to_party_id	number(15),
	activity_type_name	varchar2(255) := null,
	activity_type_id	number(15),
	trans_type		varchar2(80) := null,
	trans_num		varchar2(80),
	total_fee		number,
	related_inv_reqid	number(15),
	reqid			number(15),
	quantity		number(15)
);

TYPE  invtabtype IS TABLE OF ra_intf_line_rectype index by binary_integer;
TYPE  cmtabtype IS TABLE OF ra_intf_line_rectype index by binary_integer;
TYPE  oacmtabtype IS TABLE OF ra_intf_line_rectype index by binary_integer;

invtab	invtabtype;
cmtab	cmtabtype;
oacmtab	oacmtabtype;

l_invline_index		number := 0;
l_cm_index		number := 0;
l_oacmline_index	number := 0;
l_reg_cm_flag		varchar2(10) := 'N';
l_related_inv_reqid 	number;

l_inv_prev_acttypeid 	number(15) := -1;
l_cm_prev_acttypeid  	number(15) := -1;
l_oacm_prev_acttypeid 	number(15) := -1;
l_tmp_request_id	number(15);
l_cm_request_id	 	number;

-- Dynamic sql statement holders
l_sql_bank_acc 		varchar2(4000) ;
l_sql_invoice_interface	varchar2(4000) ;
l_sql_get_pom_param 	varchar2(4000) ;
l_temp_sql		varchar2(4000);

-- Local variables
	l_request_id 			number(15);
	l_error_code			varchar2(30);
	l_error_msg			varchar2(255);
	l_cutoff_date			date ;
	l_uom_code    			varchar2(240) := 'Ea';
	l_gl_date			DATE := sysdate;
	l_cycle_start_date		DATE ;
	l_cycle_end_date		DATE ;
	l_bank_account_id    		NUMBER(15); -- from pom_billing_customers
	l_billing_period		varchar2(30);
	l_party_id			NUMBER(15) := null;
	l_prev_party_id			NUMBER(15) := -1;
	l_skip_party			varchar2(5) := 'N'; -- If error occurs, skip all records for this party
	l_a_null			char(1);  -- represents NULL in the dynamic statement
	l_exit_prog			varchar2(1) := 'N';
  	l_default_currency 		varchar2(10);
	l_rounded_amount		number;
	l_ba_row_num			number(15) := 1;
	l_payment_method_name    	varchar2(240);
	l_cc_number			varchar2(30); /* Bank account num */

-- User-defined exceptions
  	no_default_currency 		EXCEPTION;
	interface_program_error 	EXCEPTION;

-- Cust details (for new party row in cursor)
	l_bill_to_party_id		NUMBER(15) := -99;
	l_customer_name			varchar2(255);
	l_billing_customer_id		NUMBER(15) := -1;
	l_bill_to_site_use_id		NUMBER(15) := -1;
	l_payment_method_code    	varchar2(240);
	l_account_number		varchar2(80); /* Bank account num */
	l_org_id			NUMBER(15) := -1;
	l_set_of_books_id		NUMBER(15) := -1;
	l_orig_system_prefix		varchar2(240);
	l_payment_term_name		varchar2(50);
	l_batch_source_name		varchar2(50);
	l_interface_line_context	varchar2(50);
	l_orig_sys_cust_ref	varchar2(240);
	l_orig_sys_addr_ref	varchar2(240);

-- Cust details (for previous party row in cursor)
	l_prev_bill_to_party_id		NUMBER(15) := -99;
	l_prev_customer_name		varchar2(255);
	l_prev_billing_customer_id	NUMBER(15) := -1;
	l_prev_bill_to_site_use_id	NUMBER(15) := -1;
	l_prev_payment_method_code    	varchar2(240);
	l_prev_account_number		varchar2(80); /* Bank account num */
	l_prev_org_id			NUMBER(15) := -1;
	l_prev_set_of_books_id		NUMBER(15) := -1;
	l_prev_orig_system_prefix	varchar2(240);
	l_prev_payment_term_name	varchar2(50);
	l_prev_batch_source_name	varchar2(50);
	l_prev_interface_line_context	varchar2(50);
	l_prev_orig_sys_cust_ref	varchar2(240);
	l_prev_orig_sys_addr_ref	varchar2(240);

BEGIN

	print_debug(LEVEL0,'invoice_interface +');
-- Initialize dynamic sql statements.
l_sql_cust_details := '
	SELECT
		hp.party_name				customer_name,
		pbc.billing_customer_id			billing_customer_id,
		pbc.bill_to_site_use_id			bill_to_site_use_id,
		pbc.payment_method_name			payment_method_code,
		pbc.account_number			account_number,
		pbsp.org_id				org_id,
		pbsp.set_of_books_id			set_of_books_id,
		pbsp.orig_system_prefix			orig_system_prefix,
		pbsp.cust_trxtype_name			cust_trxtype_name,
		pbsp.payment_term_name			payment_term_name,
		pbsp.batch_source_name			batch_source_name,
		pbsp.interface_line_context		interface_line_context,'||
		''''||g_osr_cust_prefix||''''||'||to_char(pbc.bill_to_party_id)	orig_sys_cust_ref,'||
		''''||g_osr_cust_prefix||''''||'||to_char(pbc.bill_to_party_id)||'||''''||g_osr_addr_prefix||''''||' ||to_char(pbc.bill_to_site_use_id)  orig_sys_addr_ref
	FROM
		hz_parties'||g_oexdblink||' hp,
		pom_billing_customers'||g_oexdblink||' pbc,
		pom_billing_seat_parameters'||g_oexdblink||' pbsp
	WHERE
		hp.party_id 	     = pbc.bill_to_party_id
 	AND	pbsp.operator_id     = pbc.operator_id
	AND	pbc.bill_to_party_id = :1
';

l_sql_bank_acc := '
 SELECT ba.bank_account_id
 FROM 	ap_bank_account_uses_all bau,
	ap_bank_accounts_all ba,
	hz_cust_accounts_all hca
 WHERE 	bau.customer_id = hca.cust_account_id
 AND    hca.orig_system_reference = :1
 AND	ba.bank_account_num = :2
 AND	bau.external_bank_account_id = ba.bank_account_id
';

l_sql_invoice_interface := '
INSERT INTO ra_interface_lines_all
(
org_id, batch_source_name, set_of_books_id, line_type,
currency_code, conversion_rate, conversion_type, description, memo_line_name,
amount, cust_trx_type_name, orig_system_bill_customer_ref, orig_system_bill_address_ref,
term_name, uom_code, trx_date, gl_date,
receipt_method_name, customer_bank_account_id ,
interface_line_context, interface_line_attribute1, interface_line_attribute2,
interface_line_attribute3 , interface_line_attribute4 , interface_line_attribute5 ,
reference_line_context, reference_line_attribute1, reference_line_attribute2,
reference_line_attribute3 , reference_line_attribute4 , reference_line_attribute5 ,
created_by, creation_date, last_updated_by, last_update_date,
quantity
)
SELECT
:1, :2, :3, :4,
:5, :6, :7, :8, :9,
:10, :11, :12, :13,
:14, :15, :16, :17,
:18, :19,
:20, :21, :22,
:23, :24, :25,
:26, :27, :28,
:29, :30, :31,
:32, :33, :34, :35,
:36
FROM DUAL';

l_sql_get_pom_param := '
 SELECT parameter_value
 FROM pom_operator_parameters'||g_oexdblink||'
 WHERE operator_party_id = '||g_oper_id||'
 AND parameter_name = ''oexOperDefaultCurrency''
';

	BEGIN
		/* get default operator currency */
		EXECUTE IMMEDIATE l_sql_get_pom_param
		INTO  l_default_currency;
		print_debug(LEVEL0, 'Operator default currency is :'||l_default_currency);

		IF ( l_default_currency is null ) THEN
		   l_error_code := 'POM_NO_DEFAULT_CURRENCY';
		   print_debug(0,' no_default_currency exception raised. Terminating program.');
		   RAISE no_default_currency;
		END IF;
	END;


	IF ( (p_cutoff_date IS NULL) or (p_cutoff_date > sysdate) ) THEN
		l_cutoff_date := sysdate;
	ELSE
		l_cutoff_date := p_cutoff_date;
	END IF;

	l_request_id := p_conc_request_id;

	l_cycle_end_date := to_date('01'||'-'||to_char(sysdate,'MM')||'-'||to_char(sysdate,'YYYY'),'DD-MM-YYYY');
	l_cycle_start_date := add_months(l_cycle_end_date,-1);
	l_billing_period := to_char(l_cycle_start_date) ||' - '||to_char(l_cycle_end_date-1);
	print_debug(LEVEL0,'-----------------------------------------');
	print_debug(LEVEL0, 'Cut off date: '||to_char(l_cutoff_date)||', Request ID: '||to_char(l_request_id));
	print_debug(LEVEL0,'Billing period: '||l_billing_period);
	print_debug(LEVEL0,'-----------------------------------------');

l_temp_sql := '
	UPDATE  pom_billing_activities'||g_oexdblink||'
	set 	request_id = :1
	WHERE	billing_activity_id in
		(select pba.billing_activity_id
		 from   pom_billing_activities'||g_oexdblink||' pba,
			pom_billing_customers'||g_oexdblink||' pbc,
			pom_billing_activity_types_tl'||g_oexdblink||' pbat
		where   pbc.bill_to_party_id 	= pba.bill_to_party_id
		AND	pbat.billing_activity_type_id = pba.billing_activity_type_id
		AND	pbat.language_code 	= ''US''
		and	pbc.operator_id 	= '||g_oper_id||'
		and	pbc.ar_transfer_flag is null
		and	pba.priced_flag is null
		and 	transaction_date < :2
		and 	( (nvl(pba.ar_transfer_flag,''~'') = ''N'' AND pba.request_id is null)
			OR
			(nvl(pba.ar_transfer_flag,''~'') = ''E'')
			)
		)
';

	EXECUTE IMMEDIATE l_temp_sql
	USING l_request_id,l_cycle_end_date;

	IF (sql%rowcount = 0) THEN
		print_debug(LEVEL0, 'No data to process ');
		l_exit_prog := 'Y';
	ELSE
		print_debug(LEVEL0, 'Rows to process : '||to_char(sql%rowcount));
	END IF;


	IF (l_exit_prog = 'N') THEN --{

	-- Get billing activities
	print_debug(LEVEL0,'Opening cursor variable bill_act_cv...');
	OPEN bill_act_cv FOR l_sql_billing_activities
	USING l_request_id;

	print_debug(LEVEL0,'Fetching data...');
	LOOP	--{
		FETCH bill_act_cv INTO ba_rec;
		EXIT WHEN bill_act_cv%NOTFOUND;

		l_error_code 	:= null;
		l_error_msg 	:= null;

		IF (ba_rec.bill_to_party_id <> l_prev_party_id) THEN --{
			print_debug(0,'New party id record from bill_act_cv');

			-- Billing records for new party.
			l_skip_party 		:= 'N';
			l_prev_party_id 	:= ba_rec.bill_to_party_id;

			-- Invoice table specific prev value checks. Initialize so the table gets
			-- a new row when the party_id in the ba cursor changes.
			l_inv_prev_acttypeid 	:= -1;
			l_oacm_prev_acttypeid 	:= -1;
			l_tmp_request_id 	:= null;

			IF (l_ba_row_num = 1) THEN --{
				-- Initialize party specific local variables.
				l_bank_account_id 	:= null;
				l_payment_term_name	:= null;
				l_customer_name	  	  := null;
				l_billing_customer_id	  := -99;
				l_bill_to_site_use_id	  := -99;
				l_payment_method_code  	  := null;
				l_account_number  	  := null;
				l_cc_number	  	  := null;
				l_org_id		  := -99;
				l_set_of_books_id	  := -99;
				l_orig_system_prefix	  := null;
				l_payment_term_name	  := null;
				l_batch_source_name	  := null;
				l_interface_line_context  := null;
				l_orig_sys_cust_ref  := null;
				l_orig_sys_addr_ref  := null;

				print_debug(LEVEL0,'l_sql_cust_details: '||l_sql_cust_details);
				print_debug(LEVEL0,'ba_rec.bill_to_party_id: '||to_char(ba_rec.bill_to_party_id));
				print_debug(LEVEL0,'g_osr_cust_prefix: '||g_osr_cust_prefix);
				print_debug(LEVEL0,'g_osr_addr_prefix: '||g_osr_addr_prefix);
				print_debug(LEVEL0,'First rec: Opening cursor variable cust_details_cv...');
				OPEN cust_details_cv FOR l_sql_cust_details
				USING  	ba_rec.bill_to_party_id;

				print_debug(LEVEL0,'First rec: Fetching data...');
				LOOP
					FETCH cust_details_cv INTO custrec;
					EXIT WHEN cust_details_cv%NOTFOUND;

					l_bill_to_party_id 	  := ba_rec.bill_to_party_id;
					l_customer_name	  	  := custrec.customer_name;
					l_billing_customer_id	  := custrec.billing_customer_id;
					l_bill_to_site_use_id	  := custrec.bill_to_site_use_id;
					l_payment_method_code  	  := custrec.payment_method_code;
					l_account_number	  := custrec.account_number;
					l_org_id		  := custrec.org_id;
					l_set_of_books_id	  := custrec.set_of_books_id;
					l_orig_system_prefix	  := custrec.orig_system_prefix;
					l_payment_term_name	  := custrec.payment_term_name;
					l_batch_source_name	  := custrec.batch_source_name;
					l_interface_line_context  := custrec.interface_line_context;
					l_orig_sys_cust_ref  := custrec.orig_sys_cust_ref;
					l_orig_sys_addr_ref  := custrec.orig_sys_addr_ref;
					EXIT;
				END LOOP;

				IF (cust_details_cv%ISOPEN) THEN
					CLOSE cust_details_cv;
				END IF;

				-- Row 1 of cursor: store cust details for first party in cursor
				l_prev_bill_to_party_id		:= 	l_bill_to_party_id;
				l_prev_customer_name		:= 	l_customer_name;
				l_prev_billing_customer_id	:= 	l_billing_customer_id;
				l_prev_bill_to_site_use_id	:= 	l_bill_to_site_use_id;
				l_prev_payment_method_code	:= 	l_payment_method_code;
				l_prev_account_number		:= 	l_account_number;
				l_prev_org_id			:= 	l_org_id;
				l_prev_set_of_books_id		:= 	l_set_of_books_id;
				l_prev_orig_system_prefix	:= 	l_orig_system_prefix;
				l_prev_payment_term_name	:= 	l_payment_term_name;
				l_prev_batch_source_name	:= 	l_batch_source_name;
				l_prev_interface_line_context	:= 	l_interface_line_context;
				l_prev_orig_sys_cust_ref  	:= 	l_orig_sys_cust_ref;
				l_prev_orig_sys_addr_ref  	:= 	l_orig_sys_addr_ref;
			ELSE
				-- First, store cust details for previous party in cursor
				l_prev_bill_to_party_id		:= 	l_bill_to_party_id;
				l_prev_customer_name		:= 	l_customer_name;
				l_prev_billing_customer_id	:= 	l_billing_customer_id;
				l_prev_bill_to_site_use_id	:= 	l_bill_to_site_use_id;
				l_prev_payment_method_code	:= 	l_payment_method_code;
				l_prev_account_number		:= 	l_account_number;
				l_prev_org_id			:= 	l_org_id;
				l_prev_set_of_books_id		:= 	l_set_of_books_id;
				l_prev_orig_system_prefix	:= 	l_orig_system_prefix;
				l_prev_payment_term_name	:= 	l_payment_term_name;
				l_prev_batch_source_name	:= 	l_batch_source_name;
				l_prev_interface_line_context	:= 	l_interface_line_context;
				l_prev_orig_sys_cust_ref  	:= 	l_orig_sys_cust_ref;
				l_prev_orig_sys_addr_ref  	:= 	l_orig_sys_addr_ref;

				-- Initialize party specific local variables.
				l_bank_account_id 	:= null;
				l_payment_term_name	:= null;
				l_customer_name	  	  := null;
				l_billing_customer_id	  := -99;
				l_bill_to_site_use_id	  := -99;
				l_payment_method_code  	  := null;
				l_account_number  	  := null;
				l_cc_number	  	  := null;
				l_org_id		  := -99;
				l_set_of_books_id	  := -99;
				l_orig_system_prefix	  := null;
				l_payment_term_name	  := null;
				l_batch_source_name	  := null;
				l_interface_line_context  := null;
				l_orig_sys_cust_ref  	  := null;
				l_orig_sys_addr_ref  	  := null;

				-- Get cust details for current party in cursor
				OPEN cust_details_cv FOR l_sql_cust_details
				USING  ba_rec.bill_to_party_id;

				LOOP
					FETCH cust_details_cv INTO custrec;
					EXIT WHEN cust_details_cv%NOTFOUND;

					l_bill_to_party_id 	  := ba_rec.bill_to_party_id;
					l_customer_name	  	  := custrec.customer_name;
					l_billing_customer_id	  := custrec.billing_customer_id;
					l_bill_to_site_use_id	  := custrec.bill_to_site_use_id;
					l_payment_method_code  	  := custrec.payment_method_code;
					l_account_number	  := custrec.account_number;
					l_org_id		  := custrec.org_id;
					l_set_of_books_id	  := custrec.set_of_books_id;
					l_orig_system_prefix	  := custrec.orig_system_prefix;
					l_payment_term_name	  := custrec.payment_term_name;
					l_batch_source_name	  := custrec.batch_source_name;
					l_interface_line_context  := custrec.interface_line_context;
					l_orig_sys_cust_ref  := custrec.orig_sys_cust_ref;
					l_orig_sys_addr_ref  := custrec.orig_sys_addr_ref;
					EXIT;
				END LOOP;
				IF (cust_details_cv%ISOPEN) THEN
					CLOSE cust_details_cv;
				END IF;
			END IF; --}


			l_ba_row_num := l_ba_row_num + 1;

			IF (l_prev_billing_customer_id = '-1') THEN
				-- skip party
				l_skip_party := 'Y';
				print_debug(0,'Cursor c_cust_details returned no rows. Skipping party [party_id='||to_char(ba_rec.bill_to_party_id)||']');
			END IF;

			-- Get cust related values
			IF (l_prev_payment_method_code = 'BILL_ME') THEN --{
				l_payment_method_name := g_payment_method_billme;

			ELSE -- CREDIT_CARD or EFT
			    IF (l_prev_payment_method_code = 'EFT') THEN
				l_payment_method_name := g_payment_method_eft;
			    ELSE
				l_payment_method_name := g_payment_method_credit;
			    END IF;

			    /* For payment types CREDIT_CARD and EFT, due date is immediate */
			    l_payment_term_name := 'IMMEDIATE';

			    /* IF payment_method is Automatic, bank_account is must be passed in
			       to the invoice interface table */
			    l_cc_number := null;
			    EXECUTE IMMEDIATE '
			       BEGIN
			         pom_billing_util_pkg.get_util_info_w'||g_oexdblink||'(
				    i_old_info => :a,
				    i_info     => :b );
			       END;
			    '
			    USING IN l_prev_account_number, IN OUT l_cc_number;

			    OPEN bank_acc_cv FOR l_sql_bank_acc
				USING l_prev_orig_sys_cust_ref , l_cc_number;
			    FETCH bank_acc_cv INTO l_bank_account_id;
			    IF  (bank_acc_cv%NOTFOUND) THEN
				l_error_msg := g_error_msg_nobankerr;
				l_action_reqd_msg := g_error_msg_nobankact;
				l_skip_party := 'Y';
			    ELSIF (l_bank_account_id IS NULL) THEN
				l_error_msg := g_error_msg_nobankerr;
				l_action_reqd_msg := g_error_msg_nobankact;
				l_skip_party := 'Y';
			    END IF;

			    IF (bank_acc_cv%ISOPEN) THEN
				CLOSE bank_acc_cv;
			    END IF;

			END IF;  --} if payment_method = 'BILL_ME'


			-- Populate AR Invoice Interface table for the previous party
			if (l_invline_index > 0) then --{
				print_debug(0,'Bill-to Party = 	'||l_prev_customer_name||' ('||to_char(l_prev_bill_to_party_id)||')') ;

		        FOR ix in 1..l_invline_index LOOP

				/* list of trx lines in an invoice. transfer the lines*/
				l_rounded_amount := null;
			   	l_rounded_amount := gl_mc_currency_pkg.currround(invtab(ix).total_fee, l_default_currency);

				--print_debug(0,'INV: amount=['||to_char(invtab(ix).total_fee)||'],rounded amount = ['||to_char(l_rounded_amount)||']');

			   print_debug(LEVEL2,'INV: Transfering: '||
				invtab(ix).activity_type_name ||','||
				to_char(l_rounded_amount) );

				l_error_msg := g_error_msg_invintferr;
				l_action_reqd_msg := g_error_msg_invintfact;

				EXECUTE IMMEDIATE l_sql_invoice_interface
				USING
				g_org_id,
				l_prev_batch_source_name,
				l_prev_set_of_books_id,
				'LINE',
				l_default_currency,
				1,
				'User',
				invtab(ix).activity_type_name,
				invtab(ix).activity_type_name,
				l_rounded_amount,
				g_inv_trxtype_name,
				l_prev_orig_sys_cust_ref,
				nvl(l_prev_orig_sys_addr_ref,l_a_null),
				nvl(l_prev_payment_term_name,l_a_null),
				nvl(l_uom_code,l_a_null),
				sysdate,
				sysdate,
				l_payment_method_name,
				nvl(l_bank_account_id,l_a_null),
				l_prev_interface_line_context,
				invtab(ix).bill_to_party_id,
				l_prev_bill_to_site_use_id,
				l_request_id,
				l_billing_period,
				invtab(ix).activity_type_id,
				l_a_null,
				l_a_null,
				l_a_null,
				l_a_null,
				l_a_null,
				l_a_null,
				-1,
				sysdate,
				-1,
				sysdate,
				invtab(ix).quantity;

			   l_error_msg := null;
			   l_action_reqd_msg := null;

		        END LOOP; -- for each invoice line

				-- successfully transfered all invoice components to AR.
				l_temp_sql := '
				UPDATE  pom_billing_activities'||g_oexdblink ||'
				SET     ar_transfer_flag = NULL,
					last_billed_date  = :1,
					last_update_date = sysdate
				WHERE   bill_to_party_id = :2
				AND	request_id = :3
				';
				EXECUTE IMMEDIATE l_temp_sql
				USING  l_cycle_end_date, l_prev_bill_to_party_id, l_request_id;

				print_debug(0,to_char(sql%rowcount)||' rows updated in pba for INV [req_id = '||to_char(l_request_id)||']');

			end if; --}

			IF (l_oacmline_index > 0) THEN --{

		        FOR ix in 1..l_oacmline_index LOOP
			/* list of trx lines in an on-account credit memo. transfer the lines*/

				l_rounded_amount := null;
				l_rounded_amount := gl_mc_currency_pkg.currround(oacmtab(ix).total_fee, l_default_currency);

				--print_debug(0,'CM: amount=['||to_char(oacmtab(ix).total_fee)||'],rounded amount = ['||to_char(l_rounded_amount)||']');

			   	print_debug(LEVEL2,'CM: Transfering: '|| oacmtab(ix).activity_type_name ||','|| to_char(l_rounded_amount) );

				l_error_msg := g_error_msg_invintferr;
				l_action_reqd_msg := g_error_msg_invintfact;

				EXECUTE IMMEDIATE l_sql_invoice_interface
				USING
				g_org_id,
				l_prev_batch_source_name,
				l_prev_set_of_books_id,
				'LINE',
				l_default_currency,
				1,
				'User',
				oacmtab(ix).activity_type_name,
				oacmtab(ix).activity_type_name,
				l_rounded_amount,
				g_cred_trxtype_name,
				l_prev_orig_sys_cust_ref,
				nvl(l_prev_orig_sys_addr_ref,l_a_null),
				l_a_null,
				nvl(l_uom_code,l_a_null),
				sysdate,
				sysdate,
				l_payment_method_name,
				nvl(l_bank_account_id,l_a_null),
				l_prev_interface_line_context,
				oacmtab(ix).bill_to_party_id,
				l_prev_bill_to_site_use_id,
				l_cm_request_id,
				l_billing_period,
				oacmtab(ix).activity_type_id,
				l_a_null,
				l_a_null,
				l_a_null,
				l_a_null,
				l_a_null,
				l_a_null,
				-1,
				sysdate,
				-1,
				sysdate,
				oacmtab(ix).quantity;

			   l_error_msg := null;
			   l_action_reqd_msg := null;

		        END LOOP; -- for each on-account credit memo line

				-- successfully transfered all CM records to AR.
				l_temp_sql := '
				UPDATE  pom_billing_activities'||g_oexdblink||'
				SET 	ar_transfer_flag = NULL,
					last_billed_date  = :1,
					last_update_date = sysdate
				WHERE   bill_to_party_id = :2
				AND     request_id = :3
				';
				EXECUTE IMMEDIATE l_temp_sql
				USING  l_cycle_end_date, l_prev_bill_to_party_id, l_cm_request_id;

				print_debug(0,to_char(sql%rowcount)||' rows updated in pba for CM [req_id = '||to_char(l_cm_request_id)||']');
			END IF; --}

		        -- Update last_billed_date in pom_billing_customers as the last step.
			IF ( (l_invline_index > 0) or (l_oacmline_index > 0) ) THEN
				begin
					l_temp_sql := '
					UPDATE pom_billing_customers'||g_oexdblink||'
					set last_billed_date  = :1
					where bill_to_party_id = :2
					';
					EXECUTE IMMEDIATE l_temp_sql
					USING  l_cycle_end_date, l_prev_bill_to_party_id;


					print_debug(0,'Committing transfer.');

					-- reset plsql table indices
					l_invline_index := 0;
					l_cm_index := 0;
					l_oacmline_index := 0;

					COMMIT;

				exception
				    when others then
				      raise;
				end;
			END IF;

		END IF; --} if party <> prev_party

		IF (l_skip_party = 'N') then --{

			/*
			 * Logic to split activities into Invoice and On-Account Credit Memo.
			 *
			 * In each cursor iteration here, we get a transaction type and several transaction
			 * numbers within it. Since billing activities in the cursor are grouped by
			 * transaction numbers, it is possible that the original transaction with +ve
			 * total_fee amt and the same transaction with an equal -ve total-fee amt (a reject),
			 * appear in the same cycle and the sum(total_fee) for the cursor row equals zero.
			 *
			 * If total_fee for a cursor row line = 0, it is not transfered.
			 * If total_fee for a cursor row > 0, it goes into an invoice.
			 * If total_fee for a cursor row < 0, it goes into an on-account credit memo.
			 *
			 * Since we know how many transaction numbers go into an invoice line, we can tell
			 * the quantity of the invoice line. The unit price however cannot be determined as
			 * we don't have a way of storing the pricing for each transaction in the invoice
			 * interface table.
			 *
			 * Thus from an invoice, we can tell the number of spot purchases or the number of
			 * transaction deliveries that made up that invoice, the sum of charges for that
			 * invoice line type (activity type), but not the unit price.
			 *
				print_debug(0,'Trans type, num :'||ba_rec.trans_type||','||
						ba_rec.trans_num||',activityrecfee='||
						to_char(ba_rec.total_fee));
			*/

			--{
			if (ba_rec.total_fee > 0) then --{
				/*
				 * Invoice: store in invtab table.
				 */
				if (ba_rec.activity_type_id <> l_inv_prev_acttypeid) then --{
					/*
					 * A different transaction type. Start accumulating total_fee
					 * for all transaction_num under this type to create an invoice
					 * invoice line.
					 */
					l_invline_index := l_invline_index + 1;
					l_inv_prev_acttypeid := ba_rec.activity_type_id;

					invtab(l_invline_index).bill_to_party_id	:= ba_rec.bill_to_party_id;
					invtab(l_invline_index).activity_type_name 	:= ba_rec.activity_type_name;
					invtab(l_invline_index).activity_type_id 	:= ba_rec.activity_type_id;
					invtab(l_invline_index).trans_type 		:= ba_rec.trans_type;

				 	invtab(l_invline_index).quantity := 1;
					invtab(l_invline_index).total_fee := ba_rec.total_fee;
				else
				 	invtab(l_invline_index).quantity := invtab(l_invline_index).quantity + 1;
					invtab(l_invline_index).total_fee := invtab(l_invline_index).total_fee
								    + ba_rec.total_fee;
				end if; --}

				IF (g_is_debug_enabled = 'Y') THEN
				    print_debug(LEVEL0,'INV TABLE: '||
					'Party_ID: '||to_char(ba_rec.bill_to_party_id)||
					', ('||to_char(l_invline_index)||') '||
					', ('||to_char(invtab(l_invline_index).quantity)||') '||
					', Activity: '||invtab(l_invline_index).activity_type_name||
					', Total-fee: '||to_char(invtab(l_invline_index).total_fee) );
				END IF;
			elsif (ba_rec.total_fee < 0) then --}{
				/*
				 * Credit Memo or On-Account Credit Memo
				 */
				l_reg_cm_flag 		:= 'N';
				l_related_inv_reqid	:= null;

				get_related_invoice (
					ba_rec.bill_to_party_id,
					ba_rec.trans_num,
					ba_rec.total_fee,
					l_reg_cm_flag,
					l_related_inv_reqid
				);
				if (l_reg_cm_flag = 'Y') then --{
					/*
					 * Regular Credit Memo
					 */
					--print_debug(0,'Regular cm');
					l_cm_index := l_cm_index + 1;
					cmtab(l_cm_index).bill_to_party_id	:= ba_rec.bill_to_party_id;
					cmtab(l_cm_index).activity_type_name 	:= ba_rec.activity_type_name;
					cmtab(l_cm_index).activity_type_id 	:= ba_rec.activity_type_id;
					cmtab(l_cm_index).trans_type 		:= ba_rec.trans_type;
					cmtab(l_cm_index).trans_num 		:= ba_rec.trans_num;
					cmtab(l_cm_index).total_fee 		:= ba_rec.total_fee;
					cmtab(l_cm_index).related_inv_reqid 	:= l_related_inv_reqid;
					/*
					Get the next request id from sequence. Interface line contexts info must be different
					for different transaction groups, otherwise autoinvoice will reject the lines.
					*/
					cmtab(l_cm_index).reqid 	:= to_number(to_char(l_request_id)||'.1');

				else --} On-account {

					/*
					 * 	On-Account Credit Memo
					 */
					if (ba_rec.activity_type_id <> l_oacm_prev_acttypeid) then
						l_oacmline_index := l_oacmline_index + 1;
						l_oacm_prev_acttypeid := ba_rec.activity_type_id;
						oacmtab(l_oacmline_index).bill_to_party_id	:= ba_rec.bill_to_party_id;
						oacmtab(l_oacmline_index).activity_type_name 	:= ba_rec.activity_type_name;
						oacmtab(l_oacmline_index).activity_type_id := ba_rec.activity_type_id;
						oacmtab(l_oacmline_index).trans_num 	 := ba_rec.trans_num;
						oacmtab(l_oacmline_index).trans_type 	 := ba_rec.trans_type;
				 		oacmtab(l_oacmline_index).quantity 	:= 1;
				 		oacmtab(l_oacmline_index).total_fee 	:= ba_rec.total_fee;
						-- no trans_num here, since we are accumulating the charges for all rejects that have had their invoice paid.
					        print_debug(0,'oacm: trans_num: '||oacmtab(l_oacmline_index).trans_num);
					else
				 		oacmtab(l_oacmline_index).quantity := oacmtab(l_oacmline_index).quantity + 1;
						oacmtab(l_oacmline_index).total_fee	:= oacmtab(l_oacmline_index).total_fee + ba_rec.total_fee;
					end if;

				        IF (g_is_debug_enabled = 'Y') THEN
					    print_debug(LEVEL0,'OACM TABLE: '||
					    'Party_ID: '||to_char(ba_rec.bill_to_party_id)||
					    ', ('||to_char(l_oacmline_index)||') '||
					    ', Activity: '||oacmtab(l_oacmline_index).activity_type_name||
					    ', Total-fee: '||to_char(oacmtab(l_oacmline_index).total_fee) );
					END IF;

					/*
					Get the next request id from sequence. Interface line contexts info must be different
					for different transaction groups, otherwise autoinvoice will reject the lines.
					All OnAccountCMs are grouped into one CM.This is given a new request id different from
					the invoice request IDs.
					*/
				        if (l_cm_request_id is null) then
						/* Assign next sequence to cm request id, for reference in exchange . This new request however does not correspond to a valid conc.request in AR. Here we need a unique reference */
						l_cm_request_id	:= l_request_id + 1;
					end if;
					    l_temp_sql := '
					    UPDATE  pom_billing_activities'||g_oexdblink||'
					    SET     request_id = :1
					    WHERE   bill_to_party_id = :2
			   		    AND	    transaction_type = :3
					    AND	    transaction_num = :4
					    AND	    request_id = :5
					    ';
					    EXECUTE IMMEDIATE l_temp_sql
					    USING  l_cm_request_id,
						   ba_rec.bill_to_party_id,
						   ba_rec.trans_type,
						   oacmtab(l_oacmline_index).trans_num,
						   l_request_id;

					print_debug(0,to_char(sql%rowcount)||' rows updated in pba for credit activities with [req_id = '||to_char(l_cm_request_id)||']');

				end if;  --}on-account

			else --}total_fee = 0 {

			   --total_fee = 0, nothing to interface for now, just say billed.
			   l_temp_sql := '
			   UPDATE  pom_billing_activities'||g_oexdblink||'
			   SET 	   ar_transfer_flag = ''P'',
				   last_billed_date = :1,
				   last_update_date = sysdate
			   WHERE   bill_to_party_id = :2
			   AND	   transaction_type = :3
			   AND	   transaction_num =  :4
			   AND	   request_id = :5
			   ';

			    EXECUTE IMMEDIATE l_temp_sql
			    USING  l_cycle_end_date,
				   ba_rec.bill_to_party_id,
				   ba_rec.trans_type,
				   ba_rec.trans_num,
				   l_request_id;
			   --print_debug(0,'Total fee = 0, updating trans['||ba_rec.trans_num||'] with status P, rows updated = '||to_char(sql%rowcount));

			end if; --} if (total_fee = 0)
			--}

		else
			print_debug(0,'Skipped party. Error = '||l_error_msg);

		end if; --} if l_skip_party

	END LOOP; --} cursor c_billing_activities

	IF (bill_act_cv%ISOPEN) THEN
		CLOSE bill_act_cv;
	END IF;

		-- Populate AR Invoice Interface table for the last party in the cursor
		print_debug(0, ' Last party in cursor ');
		if (l_invline_index > 0) then --{

			print_debug(0,'Bill-to Party = 	'||l_customer_name||' ('||to_char(l_bill_to_party_id)||')') ;
			FOR ix in 1..l_invline_index LOOP

				/* list of trx lines in an invoice. transfer the lines*/
				l_rounded_amount := null;
				l_rounded_amount := gl_mc_currency_pkg.currround(invtab(ix).total_fee, l_default_currency);

				--print_debug(0,'INV: amount=['||to_char(invtab(ix).total_fee)||'],rounded amount = ['||to_char(l_rounded_amount)||']');

			   print_debug(LEVEL2,'INV: Transfering: '|| invtab(ix).activity_type_name ||','|| to_char(l_rounded_amount) );

				l_error_msg := g_error_msg_invintferr;
				l_action_reqd_msg := g_error_msg_invintfact;

				EXECUTE IMMEDIATE l_sql_invoice_interface
				USING
				g_org_id,
				l_batch_source_name,
				l_set_of_books_id,
				'LINE',
				l_default_currency,
				1,
				'User',
				invtab(ix).activity_type_name,
				invtab(ix).activity_type_name,
				l_rounded_amount,
				g_inv_trxtype_name,
				l_orig_sys_cust_ref,
				nvl(l_orig_sys_addr_ref,l_a_null),
				nvl(l_payment_term_name,l_a_null),
				nvl(l_uom_code,l_a_null),
				sysdate,
				sysdate,
				l_payment_method_name,
				nvl(l_bank_account_id,l_a_null),
				l_interface_line_context,
				invtab(ix).bill_to_party_id,
				l_bill_to_site_use_id,
				l_request_id,
				l_billing_period,
				invtab(ix).activity_type_id,
				l_a_null,
				l_a_null,
				l_a_null,
				l_a_null,
				l_a_null,
				l_a_null,
				-1,
				sysdate,
				-1,
				sysdate,
				invtab(ix).quantity;

			   l_error_msg := null;
			   l_action_reqd_msg := null;

			END LOOP; -- for each invoice line

			-- successfully transfered all invoice components to AR.
			l_temp_sql := '
			UPDATE  pom_billing_activities'||g_oexdblink||'
			SET     ar_transfer_flag = NULL,
				last_billed_date  = :1,
				last_update_date = sysdate
			WHERE   bill_to_party_id = :2
			AND	request_id = :3
			';

			    EXECUTE IMMEDIATE l_temp_sql
			    USING  l_cycle_end_date,
				   l_bill_to_party_id,
				   l_request_id;

			print_debug(0,to_char(sql%rowcount)||' rows updated in pba for INV [req_id = '||to_char(l_request_id)||']');
		end if; --}

		IF (l_oacmline_index > 0) THEN --{

		FOR ix in 1..l_oacmline_index LOOP
		/* list of trx lines in an on-account credit memo. transfer the lines*/

			l_rounded_amount := null;
			l_rounded_amount := gl_mc_currency_pkg.currround(oacmtab(ix).total_fee, l_default_currency);

			--print_debug(0,'CM: amount=['||to_char(oacmtab(ix).total_fee)||'],rounded amount = ['||to_char(l_rounded_amount)||']');

			print_debug(LEVEL2,'CM: Transfering: '|| oacmtab(ix).activity_type_name ||','|| to_char(l_rounded_amount) );

			l_error_msg := g_error_msg_invintferr;
			l_action_reqd_msg := g_error_msg_invintfact;

			EXECUTE IMMEDIATE l_sql_invoice_interface
			USING
			g_org_id,
			l_batch_source_name,
			l_set_of_books_id,
			'LINE',
			l_default_currency,
			1,
			'User',
			oacmtab(ix).activity_type_name,
			oacmtab(ix).activity_type_name,
			l_rounded_amount,
			g_cred_trxtype_name,
			l_orig_sys_cust_ref,
			nvl(l_orig_sys_addr_ref,l_a_null),
			l_a_null,
			nvl(l_uom_code,l_a_null),
			sysdate,
			sysdate,
			l_payment_method_name,
			nvl(l_bank_account_id,l_a_null),
			l_interface_line_context,
			oacmtab(ix).bill_to_party_id,
			l_bill_to_site_use_id,
			l_cm_request_id,
			l_billing_period,
			oacmtab(ix).activity_type_id,
			l_a_null,
			l_a_null,
			l_a_null,
			l_a_null,
			l_a_null,
			l_a_null,
			-1,
			sysdate,
			-1,
			sysdate,
			oacmtab(ix).quantity;

		   l_error_msg := null;
		   l_action_reqd_msg := null;

		END LOOP; -- for each on-account credit memo line

			-- successfully transfered all CM records to AR.
			l_temp_sql := '
			UPDATE  pom_billing_activities'||g_oexdblink||'
			SET 	ar_transfer_flag = NULL,
				last_billed_date  = :1,
				last_update_date = sysdate
			WHERE   bill_to_party_id = :2
			AND     request_id = :3
			';
			EXECUTE IMMEDIATE l_temp_sql
			USING  l_cycle_end_date, l_bill_to_party_id, l_cm_request_id;

			print_debug(0,to_char(sql%rowcount)||' rows updated in pba for CM [req_id = '||to_char(l_cm_request_id)||']');
		END IF; --}

		-- Update last_billed_date in pom_billing_customers as the last step.
		IF ( (l_invline_index > 0) or (l_oacmline_index > 0) ) THEN
			begin
				l_temp_sql := '
				UPDATE pom_billing_customers'||g_oexdblink||'
				set last_billed_date  = :1
				where bill_to_party_id = :2
				';
				EXECUTE IMMEDIATE l_temp_sql
				USING  l_cycle_end_date, l_bill_to_party_id;

				print_debug(0,'Committing transfer.');

				-- reset plsql table indices
				l_invline_index := 0;
				l_cm_index := 0;
				l_oacmline_index := 0;

				COMMIT;
			exception
			    when others then
			      raise;
			end;
		END IF;

	END IF; --} if l_exit_prog = 'N'


	x_error_code := l_error_code;
	x_error_msg := l_error_msg||sqlerrm;

	COMMIT;

	print_debug(LEVEL0,'invoice_interface -');

EXCEPTION
	WHEN interface_program_error THEN
		RAISE;

	WHEN OTHERS THEN
		/*
		Update records with error flag. Req-id stays so we can report
		on failed requests. Additionally we should insert failure
		codes/messages into pom_billing_interface_errors.(tablename, pk_of_table,
		error_code, error_msg, status) where status can be 'ERROR','CORRECTED'
		*/
		print_debug(0,'invoice_interface raised following exception: ');
		print_debug(0,'SQLERRM: '||sqlerrm);
		print_debug(0,'PROGRAM ERROR CODE: '||l_error_code);
		print_debug(0,'Check Exceptions Page for more information and action required.');


		print_debug(0,'Rolling back.');
		ROLLBACK ;

		l_temp_sql := '
		UPDATE  pom_billing_activities'||g_oexdblink||'
		SET 	ar_transfer_flag = ''E'',
			request_id = null,
			last_update_date = sysdate
		WHERE   request_id = :1
		';
		EXECUTE IMMEDIATE l_temp_sql
		USING  l_request_id;

		ar_exchange_interface_pkg.record_error(
		   p_billing_activity_id 	=> null,
		   p_billing_customer_id 	=> null,
		   p_customer_name 		=> nvl(l_customer_name, p_customer_name),
		   p_error_code 		=> l_error_code,
		   p_additional_message		=> l_error_msg,
		   p_action_required		=> l_action_reqd_msg,
		   p_invalid_value		=> l_invalid_value
		);

		COMMIT;

		x_error_code := l_error_code;
		x_error_msg := l_error_msg||sqlerrm;

		print_debug(LEVEL0,'invoice_interface: '||l_error_msg);
		print_debug(LEVEL0,'invoice_interface: '||sqlerrm);

		print_debug(LEVEL0,'invoice_interface -');

END invoice_interface;

procedure record_error (
	p_billing_activity_id	IN number default null,
	p_billing_customer_id	IN number default null,
	p_customer_name		IN varchar2 default null,
	p_error_code		IN varchar2,
	p_additional_message	IN varchar2 default null,
	p_action_required	IN varchar2 default null,
	p_invalid_value		IN varchar2
	) IS

l_insert_pom_err varchar2(4000) ;

BEGIN

l_insert_pom_err := '
INSERT INTO pom_billing_interface_errors'||g_oexdblink||'
(
billing_activity_id, billing_customer_id, customer_name,
error_code,
additional_message,
action_required,
invalid_value,
creation_date
)
SELECT
:1, :2, :3, :4,
:5, :6, :7, :8
FROM DUAL
';

	print_debug(LEVEL0,'--------  ERROR -------------------------- ');
	print_debug(LEVEL0,'ar_exchange_interface_pkg.record_error + : ');
	print_debug(LEVEL4,'p_billing_activity_id : '||to_char(p_billing_activity_id));
	print_debug(LEVEL4,'p_billing_customer_id : '||to_char(p_billing_customer_id));
	print_debug(LEVEL4,'p_customer_name       : '||p_customer_name);
	print_debug(LEVEL4,'p_error_code          : '||p_error_code);
	print_debug(LEVEL4,'p_invalid_value       : '||p_invalid_value);
	print_debug(LEVEL4,'p_additional_message  : '||p_additional_message);
	print_debug(LEVEL4,'p_action_required     : '||p_action_required);
	print_debug(LEVEL0,'------------------------------------------ ');
	-- operation can be 'INVOICE' or 'CUSTOMER'

		EXECUTE IMMEDIATE l_insert_pom_err
		USING
		p_billing_activity_id,
		p_billing_customer_id,
		p_customer_name,
		p_error_code,
		p_additional_message,
		p_action_required,
		nvl(p_invalid_value,'-'),
		sysdate;

EXCEPTION
	WHEN OTHERS THEN
		raise;
END record_error;

BEGIN
	print_debug(0,'ar_exchange_interface_pkg +');
	print_debug(0,'Package initialization section +');

/* Pkg initialization section */
	g_osr_cust_prefix := 'EXCHANGE_CUST';
	g_osr_addr_prefix := '_ADDR';

	g_inv_trxtype_name := arp_standard.ar_lookup('ORACLE_EXCHANGE_TRX_TYPES','INVOICE');
	g_cred_trxtype_name := arp_standard.ar_lookup('ORACLE_EXCHANGE_TRX_TYPES','CREDIT');
	print_debug(0,'INV Trxtype in AR = ['||g_inv_trxtype_name||']');
	print_debug(0,'CM Trxtype in AR = ['||g_cred_trxtype_name||']');

	g_payment_method_billme := arp_standard.ar_lookup('ORACLE_EXCHANGE_PAY_METHODS','BILL_ME');
	g_payment_method_credit := arp_standard.ar_lookup('ORACLE_EXCHANGE_PAY_METHODS','CREDIT_CARD');
	g_payment_method_eft    := arp_standard.ar_lookup('ORACLE_EXCHANGE_PAY_METHODS','EFT');
	print_debug(0,'BILL_ME Pay method = ['||g_payment_method_billme||']');
	print_debug(0,'CREDIT_CARD Pay method = ['||g_payment_method_credit||']');
	print_debug(0,'EFT Pay method = ['||g_payment_method_eft||']');

	g_oexdblink := fnd_profile.value('ORACLE_EXCHANGE_DATABASE_LINK');
	IF (g_oexdblink is null) THEN
		print_debug(0,'Error: Could not get value for profile ORACLE_EXCHANGE_DATABASE_LINK. Terminating program...');
		RAISE init_error;
	ELSE
		g_oexdblink := '@'||g_oexdblink;
		print_debug(0, 'DBlink name (g_oexdblink) is '||g_oexdblink);
	END IF;

	EXECUTE IMMEDIATE 'select org_id from ar_system_parameters'
	INTO g_org_id;

	IF (g_org_id is null) THEN
		RAISE init_error;
	END IF;

l_sql_stmt := '
 select operator_id
 from pom_billing_seat_parameters'||g_oexdblink||'
 where org_id = :1
';

	BEGIN
		EXECUTE IMMEDIATE l_sql_stmt
		INTO g_oper_id
		USING g_org_id;
	EXCEPTION
		WHEN TOO_MANY_ROWS THEN
		   print_debug(0,'More than one seat parameter row in exchange is configured with org id: '||to_char(g_org_id));
		   print_debug(0,'Resolve and re-run this program. Terminating...');
		   RAISE;
	END;

	IF (g_oper_id is null) THEN
		RAISE init_error;
	END IF;

	print_debug(0,'Org_id: '||to_char(g_org_id)||', Operator ID: '||to_char(g_oper_id));


	-- Get message from POM product in exchange and cache it locally
	l_sql_stmt := 'select fnd_message.get_string'||g_oexdblink||'(''POM'',''POM_BILL_NO_BANKACC_ERR'')
		       from dual';
	execute immediate l_sql_stmt into g_error_msg_nobankerr;

	l_sql_stmt := 'select fnd_message.get_string'||g_oexdblink||'(''POM'',''POM_BILL_NO_BANKACC_ACT'')
		       from dual';
	execute immediate l_sql_stmt into g_error_msg_nobankact;

	l_sql_stmt := 'select fnd_message.get_string'||g_oexdblink||'(''POM'',''POM_BILL_CUST_INTF_ERR'')
		       from dual';
	execute immediate l_sql_stmt into g_error_msg_custintferr;

	l_sql_stmt := 'select fnd_message.get_string'||g_oexdblink||'(''POM'',''POM_BILL_CUST_INTF_ACT'')
		       from dual';
	execute immediate l_sql_stmt into g_error_msg_custintfact;

	l_sql_stmt := 'select fnd_message.get_string'||g_oexdblink||'(''POM'',''POM_BILL_INV_INTF_ERR'')
		       from dual';
	execute immediate l_sql_stmt into g_error_msg_invintferr;

	l_sql_stmt := 'select fnd_message.get_string'||g_oexdblink||'(''POM'',''POM_BILL_INV_INTF_ACT'')
		       from dual';
	execute immediate l_sql_stmt into g_error_msg_invintfact;

	l_sql_stmt := null;

	IF (fnd_profile.value_specific('AFLOG_ENABLED',fnd_global.user_id) = 'Y') THEN
		g_is_debug_enabled := 'Y';
	END IF;

	print_debug(0,'Pkg initialization section -');

EXCEPTION
	WHEN OTHERS THEN
		RAISE;
END ar_exchange_interface_pkg;

/
