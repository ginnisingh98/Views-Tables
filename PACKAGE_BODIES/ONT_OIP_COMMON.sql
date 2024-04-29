--------------------------------------------------------
--  DDL for Package Body ONT_OIP_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OIP_COMMON" as
/* $Header: ontcomnb.pls 120.4.12010000.2 2009/04/27 08:49:49 ckasera ship $ */

procedure getContactId(lContactid in out NOCOPY varchar2) is
xContactId number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    if (xContactId is not null) then
       lContactId:=XContactId;
    else
       lContactId:=-99;
    end if;
end getContactId;


procedure getContactDetails(lUserId in number,
pContactId out nocopy number,

pUserFName out nocopy varchar2,

pUserLName out nocopy varchar2,

pUserEmail out nocopy varchar2,

pCustName out nocopy varchar2,

pCustomerID out nocopy number,

pCustomerAddrID out nocopy number,

pStatusCode out nocopy number) is

  CURSOR C_PARTY IS
  select roles.cust_account_role_id,
         party.person_first_name,
	 party.person_last_name,
	 party.email_address,
	 party.party_name,
	 roles.cust_account_id,
	 nvl(roles.cust_acct_site_id,0)
  from   fnd_user fnd,
         hz_parties party,
         hz_cust_account_roles roles
  where  fnd.customer_id = party.party_id
  and    party.party_type='PARTY_RELATIONSHIP'
  and    party.party_id = roles.party_id
  and    roles.status ='A'
  and    party.status='A'
  and    fnd.user_id=lUserID
  UNION     -----added the below query for bug# 7456410 ,8467122
   SELECT
   Nvl(NULL,0) ,
   party.person_first_name,
   party.person_last_name,
   party.email_address,
   party.party_name,
   cust.cust_account_id ,
   Nvl(NULL,0)
   FROM
   fnd_user fnd,
   hz_parties party,
   hz_cust_accounts cust
   WHERE fnd.customer_id = party.party_id
   AND party.party_type='PERSON'
   AND party.status = 'A'
   AND cust.party_id=party.party_id
   AND fnd.user_id=lUserID;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF (C_Party%ISOPEN) THEN
    CLOSE C_Party;
  END IF;

  OPEN C_Party;
  FETCH C_Party into   pContactId,
  	    	      pUserFName,
  		      pUserLName,
  		      pUserEmail,
  		      pCustName ,
  		      pCustomerID,
  		      pCustomerAddrID;
  CLOSE C_Party;
EXCEPTION
	when no_data_found then
	  pStatusCode:=-99;
END getContactDetails;

procedure initialize is

lvContactID	varchar2(80);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin


    lvContactID := icx_sec.getID(icx_sec.PV_CUST_CONTACT_ID);

    -- Get the Customer contact information
	gCustFContact := fnd_profile.value_wnps('ONT_FEEDBACK_PROFILE');

	----------------------------------------------------
	-- Set the Global message variables here for caching
	----------------------------------------------------
	gHelp    :=getMessage('ONT_HELP');
	gReload	 :=getMessage('ONT_RELOAD');
	gMenu    :=getMessage('ONT_MENU');
	gSave    :=getMessage('ONT_SAVE');
	gExit    :=getMessage('ONT_EXIT');


    if lvContactID is not NULL then
 	gContactID := to_number(lvContactID);

	Begin
            select party.person_first_name,
                   party.person_last_name,
                   rel_party.email_address,
                   cust_party.party_name,
                   cst.cust_account_id,
                   nvl(con.cust_acct_site_id,0)
	    INTO gUserFName,
		 gUserLName,
		 gUserEmail,
		 gCustName ,
		 gCustomerID,
		 gCustomerAddrID
            from hz_cust_accounts cst,
                 hz_parties cust_party,
                 hz_cust_account_roles con,
                 hz_parties party,
                 hz_parties rel_party,
                 hz_relationships rel,
                 hz_cust_accounts acct
            where
                 cst.cust_account_id = con.cust_account_id
                 and con.cust_account_role_id = gContactID
                 and rownum = 1
                 and cst.party_id = cust_party.party_id
                 and con.party_id = rel.party_id
                 and con.role_type = 'CONTACT'
                 and rel.subject_id = party.party_id
                 and rel.subject_table_name = 'HZ_PARTIES'
                 and rel.object_table_name = 'HZ_PARTIES'
                 and rel.object_id = acct.party_id
                 and acct.cust_account_id = con.cust_account_id
                 and rel.party_id = rel_party.party_id;

	exception
		when no_data_found then
			null;
        end;


    end if;
exception

	when no_data_found then
		null;

end initialize;

function   getMessage(pMsgName      varchar2,
		     pTokenName1    varchar2 DEFAULT NULL,
		     pTokenValue1   varchar2 DEFAULT NULL,
		     pTokenName2    varchar2 DEFAULT NULL,
		     pTokenValue2   varchar2 DEFAULT NULL,
		     pTokenName3    varchar2 DEFAULT NULL,
		     pTokenValue3   varchar2 DEFAULT NULL,
		     pTokenName4    varchar2 DEFAULT NULL,
		     pTokenValue4   varchar2 DEFAULT NULL,
		     pTokenName5    varchar2 DEFAULT NULL,
		     pTokenValue5   varchar2 DEFAULT NULL) return varchar2 is
		     --
		     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
		     --
begin

	FND_MESSAGE.SET_NAME('ONT',pMsgName);

	if (pTokenName1 is NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(pTokenName1,pTokenValue1);
	end if;

	if (pTokenName2 is NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(pTokenName2,pTokenValue2);
	end if;

	if (pTokenName3 is NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(pTokenName3,pTokenValue3);
	end if;

	if (pTokenName4 is NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(pTokenName4,pTokenValue4);
	end if;

	if (pTokenName5 is NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(pTokenName5,pTokenValue5);
	end if;

	return(FND_MESSAGE.GET);

end getMessage;

function     getRecCount(pCurrent   number,
			pPageTot   number,
			pTotal     number) return varchar2 is
			--
			l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
			--
begin
	return(getMessage('ONT_RECORD_COUNT','FIRSTREC',pCurrent,'LASTREC',pPageTot,'TOTALREC',pTotal));
end getRecCount;


FUNCTION  Get_Released_Status_Name(
p_source_code          IN  VARCHAR2,
p_released_status      IN  VARCHAR2,
p_oe_interfaced_flag   IN  VARCHAR2,
p_inv_interfaced_flag  IN  VARCHAR2,
p_move_order_line_id   IN  NUMBER)
RETURN  VARCHAR2 IS

l_released_status_name VARCHAR2(50) := null;

BEGIN
  IF (p_source_code = 'OE'
    AND p_released_status = 'C'
    AND p_oe_interfaced_flag = 'Y'
    AND p_inv_interfaced_flag IN ('X','Y'))
    OR
   (p_source_code <> 'OE'
    AND p_released_status = 'C'
    AND p_inv_interfaced_flag = 'Y') THEN

      BEGIN

        SELECT meaning
        INTO   l_released_status_name
        FROM   wsh_lookups
        WHERE  lookup_type = 'PICK_STATUS'
        AND    lookup_code = 'I';

      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
  ELSE
      BEGIN
        -- bug 4267981
        IF p_released_status = 'S' AND p_move_order_line_id is null THEN
           SELECT meaning
           INTO   l_released_status_name
           FROM   wsh_lookups
           WHERE  lookup_type = 'PICK_STATUS'
           AND    lookup_code = 'K';
        ELSE
           SELECT meaning
           INTO   l_released_status_name
           FROM   wsh_lookups
           WHERE  lookup_type = 'PICK_STATUS'
           AND    lookup_code = p_released_status;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
  END IF;
  RETURN l_released_status_name;

END Get_Released_Status_Name;

PROCEDURE  Get_Price_formatted(
p_transactional_curr_code  IN  VARCHAR2,
p_price IN NUMBER,
p_line_category_code IN VARCHAR2,
x_price_formatted  OUT NOCOPY VARCHAR2
)
IS
l_precision       NUMBER;
l_ext_precision   NUMBER;
l_min_acct_unit   NUMBER;
l_precision_type  VARCHAR2(30);
l_format_mask     VARCHAR2(240);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

  IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Entering ONT_OIP_COMMON.get_price_formatted ');
  END IF ;

  FND_CURRENCY.GET_INFO(Currency_Code => p_transactional_curr_code,
                      precision =>     l_precision,
                      ext_precision => l_ext_precision,
                      min_acct_unit => l_min_acct_unit );

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('precision: '|| l_precision );
    oe_debug_pub.add('ext precision: '|| l_ext_precision );
  END IF;

  fnd_profile.get('ONT_UNIT_PRICE_PRECISION_TYPE', l_precision_type);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('precision_type: '||  l_precision_type);
  END IF;

  IF (l_precision_type = 'EXTENDED') THEN

         FND_CURRENCY.Build_Format_Mask(
                     format_mask   => l_format_mask
                    ,field_length  => 60
                    ,precision     => l_ext_precision
                    ,min_acct_unit => l_min_acct_unit
                    ,disp_grp_sep  => TRUE);
  ELSE

     FND_CURRENCY.Build_Format_Mask(
                     format_mask   => l_format_mask
                    ,field_length  => 60
                    ,precision     => l_precision
                    ,min_acct_unit => l_min_acct_unit
                    ,disp_grp_sep  =>  TRUE);
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('l_format_mask: '|| l_format_mask );
  END IF;

  BEGIN
  select To_Char(p_price*decode(p_line_category_code,'RETURN',-1,1),l_format_mask)
   into x_price_formatted
   from dual;
  END;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('x_price_formatted '|| x_price_formatted,1 );
    oe_debug_pub.add('Exiting ONT_OIP_COMMON.get_price_formatted ',1);
  END IF;

END Get_Price_formatted;

END ONT_OIP_Common;

/
