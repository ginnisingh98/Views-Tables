--------------------------------------------------------
--  DDL for Package Body ARH_CSU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_CSU_PKG" as
/* $Header: ARHCSUB.pls 120.9.12000000.2 2007/08/22 13:20:59 rmanikan ship $*/
--
--
--
-- PROCEDURE
--     maintain_denormalized_data
--
-- DESCRIPTION
--		This procedure coordinates the calling of routines to maintains
--		denormailized site_use data.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:     p_customer_id
--			p_address_id
--			p_site_use_id
--			p_site_use_code
--			p_primary_flag
--              OUT:
--
-- NOTES
--
--
--
--
FUNCTION INIT_SWITCH
( p_date   IN DATE,
  p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
RETURN DATE
IS
 res_date date;
BEGIN
 IF    p_switch = 'NULL_GMISS' THEN
   IF p_date IS NULL THEN
     res_date := FND_API.G_MISS_DATE;
   ELSE
     res_date := p_date;
   END IF;
 ELSIF p_switch = 'GMISS_NULL' THEN
   IF p_date = FND_API.G_MISS_DATE THEN
     res_date := NULL;
   ELSE
     res_date := p_date;
   END IF;
 ELSE
   res_date := TO_DATE('31/12/1800','DD/MM/RRRR');
 END IF;
 RETURN res_date;
END;

FUNCTION INIT_SWITCH
( p_char   IN VARCHAR2,
  p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
RETURN VARCHAR2
IS
 res_char varchar2(2000);
BEGIN
 IF    p_switch = 'NULL_GMISS' THEN
   IF p_char IS NULL THEN
     return FND_API.G_MISS_CHAR;
   ELSE
     return p_char;
   END IF;
 ELSIF p_switch = 'GMISS_NULL' THEN
   IF p_char = FND_API.G_MISS_CHAR THEN
     return NULL;
   ELSE
     return p_char;
   END IF;
 ELSE
   return ('INCORRECT_P_SWITCH');
 END IF;
END;

FUNCTION INIT_SWITCH
( p_num   IN NUMBER,
  p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
RETURN NUMBER
IS
 BEGIN
 IF    p_switch = 'NULL_GMISS' THEN
   IF p_num IS NULL THEN
     return FND_API.G_MISS_NUM;
   ELSE
     return p_num;
   END IF;
 ELSIF p_switch = 'GMISS_NULL' THEN
   IF p_num = FND_API.G_MISS_NUM THEN
     return NULL;
   ELSE
     return p_num;
   END IF;
 ELSE
   return ('9999999999');
 END IF;
END;


procedure  maintain_denormalized_data ( p_customer_id 	in number,
					p_address_id  	in number,
					p_site_use_id 	in number,
					p_site_use_code in varchar2,
					p_status        in varchar2,
					p_primary_flag  in varchar2 ) is
--
l_site_use_flag varchar2(1);
--
BEGIN
    --
    --
   if ( p_site_use_code in  ('BILL_TO','SHIP_TO','MARKET' )) then
        --
        --
    if ( p_status = 'A' ) then
      if ( p_primary_flag = 'Y' ) then
        l_site_use_flag := 'P';
      else
        l_site_use_flag := 'Y';
      end if;
	else
      l_site_use_flag := null;
	end if;
        --
    arh_addr_pkg.update_site_use_flag(p_address_id    => p_address_id,
                                      p_site_use_code => p_site_use_code,
                                      p_site_use_flag => l_site_use_flag);
   end if;
   --
end maintain_denormalized_data;
--
--
--
  PROCEDURE delete_customer_alt_names(p_rowid in varchar2,
                                    p_status in varchar2,
                                    p_customer_id in number,
                                    p_site_use_id in number
                                    ) is
l_status varchar2(1);
l_lock_status number;
begin
        --
        --
        if (
 --               ( nvl ( fnd_profile.value('AR_ALT_NAME_SEARCH') , 'N' ) = 'Y' ) and
                ( p_status = 'I')
            ) then
              --
      select status
        into l_status
        from hz_cust_site_uses
       where site_use_id = p_site_use_id;

              --
              if ( l_status = 'A' ) then
                 --
                 arp_cust_alt_match_pkg.lock_match ( p_customer_id,
                              p_site_use_id,
                              l_lock_status );
                 --
                 if ( l_lock_status = 1 ) then
                    --
                    -- Fixed bug 928111: added alt_name to call, since
                    -- not derivable from this location, I am passing NULL
                    arp_cust_alt_match_pkg.delete_match ( p_customer_id,
                                p_site_use_id, NULL );
                    --
                 end if;
              --
              end if;
              --
        end if;
        --
        --
exception
        when OTHERS then
              arp_standard.debug('EXCEPTION: arh_csu_pkg.delete_customer_alt_names');
end delete_customer_alt_names;
--
--
--
-- PROCEDURE
--     site_use_exists
--
-- DESCRIPTION
--    This procedure determins if an address has a site use of a particular
--    Type.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			p_address_id -
--			p_site_use_code  - type of site use to create
--              OUT:
--                      p_site_use_id - id of site use type
--			p_site_use_status - status of site use type
--
-- RETURNS  null
--
-- NOTES
--
PROCEDURE site_use_exists( 	p_address_id in number,
				p_site_use_code in varchar2,
				p_site_use_id out nocopy number,
				p_site_use_status out nocopy varchar2,
                               x_msg_count                  OUT NOCOPY number,
                                x_msg_data                   OUT NOCOPY VARCHAR2,
                                x_return_status              OUT NOCOPY VARCHAR2
 ) is
--
--
-- An address may only have one active site_use per type
-- However an address may have many number of inactive site_uses
--
-- The order by in the cursor ensures that we test the for active
-- site uses first. If there ar multiple inactive we simply return the
-- first we encounter.
--
cursor c_site_use is	select su.site_use_id,
			       su.status
			from   hz_cust_site_uses su
			where  su.cust_acct_site_id = p_address_id
			and    su.site_use_code = p_site_use_code
			order
			by     su.status;
begin
	open c_site_use;
	fetch c_site_use into p_site_use_id,p_site_use_status;
	close 	c_site_use;
end site_use_exists;
--
--
--
-- PROCEDURE
--     update_su_status
--
-- DESCRIPTION
--		This procedure updates the staus of a row in hz_cust_site_uses
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			p_customer_id
--			p_address_id
--			p_site_use_code
--			p_site_use_id	- id of row to be updated
--			p_status	- status to update row to(A,I)
--              OUT:
--
-- NOTES
--
--
--
--
  PROCEDURE update_su_status (	p_customer_id in number,
				p_address_id in number,
				p_site_use_id in number,
				p_site_use_code in varchar2,
				p_status in varchar2 ) is
  --
  --
  begin
	--
	--
	update hz_cust_site_uses su
	set    su.status = p_status
	where  su.site_use_id = p_site_use_id;
	--
	--
	if (SQL%NOTFOUND) then
		raise NO_DATA_FOUND;
	end if;
	--
	--
/* bug3297313 : The call to procedure maintain_denormalized_data is commented out
                as this will be taken care in TCA API
*/
/*
        maintain_denormalized_data ( p_customer_id   => p_customer_id,
				     p_address_id    => p_address_id,
				     p_site_use_id   => p_site_use_id,
				     p_site_use_code => p_site_use_code,
				     p_status	     => p_status,
				     p_primary_flag  => 'N'
			   );
*/
	--
  end update_su_status;
  --
  --
--
--
--
-- PROCEDURE
--     check_unique_site_use_code
--
-- DESCRIPTION
--		This procedure ensures validates to ensure
--			1). An addres has only active site use per type.
--			2). A Customer only has one primary active site use of each type
--				DUN
--				STMTS
--				LEGAL
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			- p_site_use_id
--			- p_customer_id
--			- p_address_id,
--			- p_site_use_code
--
--              OUT:
--
-- NOTES
--
--
--
procedure check_unique_site_use_code(	p_site_use_id in number,
					p_customer_id in number,
					p_address_id  in number,
					p_site_use_code in varchar2 ) is
--
--
dummy number;
begin
	--
	-- A customer can only have one primary active DUN,STMTS,LEGAL site use
	--
	if ( 	p_site_use_code in ('STMTS', 'DUN', 'LEGAL' ) )then
		--
		--
		select	count(1)
		into    dummy
		from	hz_cust_site_uses su,
			hz_cust_acct_sites a
		where	su.cust_acct_site_ID 	= a.cust_acct_site_ID
                and 	a.cust_account_id 		= p_customer_id
               	and 	su.site_use_code 	= p_site_use_code
               	and	su.status 		= 'A'
                and     ( ( p_site_use_id is null ) or ( p_site_use_id <> site_use_id));
		--
		--
		if (dummy >= 1 ) then
			if (p_site_use_code = 'DUN' ) then
				fnd_message.set_name('AR','AR_CUST_ONE_ACTIVE_DUN_SITE');
			elsif ( p_site_use_code = 'LEGAL' ) then
				fnd_message.set_name('AR','AR_CUST_ONE_ACTIVE_LEGAL_SITE');
			elsif ( p_site_use_code = 'STMTS' ) then
				fnd_message.set_name('AR','AR_CUST_ONE_ACTIVE_STMTS_SITE');
			end if;
			--
			app_exception.raise_exception;
		end if;
		--
	end if;
	--
	-- An address can only have one active site use of each type.
	--
	select 	count(1)
	into	dummy
	from	hz_cust_site_uses
	where   site_use_code	= p_site_use_code
	and     cust_acct_site_ID     	= p_address_id
	and	status		= 'A'
	and     ( ( p_site_use_id  is null ) or site_use_id <> p_site_use_id);
	--
	if (dummy >= 1) then
		fnd_message.set_name('AR','AR_CUST_ONE_ACTIVE_BS_PER_ADDR');
		app_exception.raise_exception;
	end if;
	--
	--
end check_unique_site_use_code;

-- PROCEDURE
--     check_unique_site_use_code
--
-- DESCRIPTION
--              This procedure ensures validates to ensure
--                      1). An addres has only active site use per type.
--                      2). A Customer only has one primary active site use of each type
--                              DUN
--                              STMTS
--                              LEGAL
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--                      - p_site_use_id
--                      - p_customer_id
--                      - p_address_id,
--                      - p_site_use_code
--
--              OUT: x_return_status
--                   x_msg_count
--                   x_msg_data
-- NOTES Overloaded the method so that instead of rasing an exception, it add the mesage to FND stack, for graceful handling of error situation.
--
--
--
procedure check_unique_site_use_code(   p_site_use_id in number,
                                        p_customer_id in number,
                                        p_address_id  in number,
                                        p_site_use_code in varchar2,
                                        x_return_status out nocopy  varchar2,
                                        x_msg_count out nocopy number,
                                        x_msg_data out nocopy varchar2 ) is
--
--
dummy number;
begin
        --
        -- A customer can only have one primary active DUN,STMTS,LEGAL site use
        --
        if (    p_site_use_code in ('STMTS', 'DUN', 'LEGAL' ) )then
                --
                --
                select  count(1)
                into    dummy
                from    hz_cust_site_uses su,
                        hz_cust_acct_sites a
                where   su.cust_acct_site_ID    = a.cust_acct_site_ID
                and     a.cust_account_id               = p_customer_id
                and     su.site_use_code        = p_site_use_code
                and     su.status               = 'A'
                and     ( ( p_site_use_id is null ) or ( p_site_use_id <> site_use_id));
                --
                --
                if (dummy >= 1 ) then
                        if (p_site_use_code = 'DUN' ) then
                                fnd_message.set_name('AR','AR_CUST_ONE_ACTIVE_DUN_SITE');
                                x_msg_data := 'AR_CUST_ONE_ACTIVE_DUN_SITE';
                        elsif ( p_site_use_code = 'LEGAL' ) then
                                fnd_message.set_name('AR','AR_CUST_ONE_ACTIVE_LEGAL_SITE');
                                x_msg_data := 'AR_CUST_ONE_ACTIVE_LEGAL_SITE';
                        elsif ( p_site_use_code = 'STMTS' ) then
                                fnd_message.set_name('AR','AR_CUST_ONE_ACTIVE_STMTS_SITE');
                                x_msg_data := 'AR_CUST_ONE_ACTIVE_STMTS_SITE';
                        end if;
                        --
                        --app_exception.raise_exception;
                        FND_MSG_PUB.ADD;
                        x_return_status :=  FND_API.G_RET_STS_ERROR;
                        x_msg_count := 1;
                return;
                end if;
                --
        end if;
        --
        -- An address can only have one active site use of each type.
        --
        select  count(1)
        into    dummy
        from    hz_cust_site_uses
        where   site_use_code   = p_site_use_code
        and     cust_acct_site_ID       = p_address_id
        and     status          = 'A'
        and     ( ( p_site_use_id  is null ) or site_use_id <> p_site_use_id);
        --
        if (dummy >= 1) then
                fnd_message.set_name('AR','AR_CUST_ONE_ACTIVE_BS_PER_ADDR');
                --app_exception.raise_exception;
                FND_MSG_PUB.ADD;
                x_return_status :=  FND_API.G_RET_STS_ERROR;
                x_msg_count := 1;
                x_msg_data := 'AR_CUST_ONE_ACTIVE_BS_PER_ADDR';
                return;

        end if;
        --
        --
end check_unique_site_use_code;


--
--
--
--
--
-- PROCEDURE
--     check_unique_location
--
-- DESCRIPTION
--		This procedure ensures validates to ensure rows
--		in hz_cust_site_uses have unique locations within
--		customer/site_use_code
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			- p_site_use_id
--			- p_customer_id
--			- p_site_use_code
--			- p_location
--
--              OUT:
--
-- NOTES
--
--
--
PROCEDURE check_unique_location
  ( p_site_use_id    IN NUMBER,
    p_customer_id    IN NUMBER,
    p_site_use_code  IN VARCHAR2,
    p_location       IN VARCHAR2)
IS
 dummy number;
--
BEGIN
	--
	--
	-- Site Use location must be unique within customer,site_use_code
	--
--Bug No : 2998504. Status check added to the where clause.

    BEGIN

   	select  1
         into  dummy
         from hz_cust_site_uses su,
              hz_cust_acct_sites addr
        where su.cust_acct_site_ID = addr.cust_acct_site_ID
          and su.site_use_code     = p_site_use_code
          and su.location          = p_location
          and addr.cust_account_ID = p_customer_id
          and ( ( p_site_use_id is null ) or ( site_use_id <> p_site_use_id ))
	  and su.STATUS = 'A'
          and rownum = 1;
	--
       IF ( dummy >= 1 ) THEN
           fnd_message.set_name('AR','AR_CUST_DUP_CODE_LOCATION');
           app_exception.raise_exception;
	END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL;
    END;
	--
	--
END check_unique_location;
--

--
-- PROCEDURE
--     check_unique_location
--
-- DESCRIPTION
--              This procedure ensures validates to ensure rows
--              in hz_cust_site_uses have unique locations within
--              customer/site_use_code
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--                      - p_site_use_id
--                      - p_customer_id
--                      - p_site_use_code
--                      - p_location
--
--              OUT:
--                      - x_return_status
--                      - x_msg_count
--                      - x_msg_data
-- NOTES Overloaded the method so that instead of rasing an exception, it add the mesage to FND stack, for graceful handling of error situation.
--
--
--
PROCEDURE check_unique_location
  ( p_site_use_id    IN NUMBER,
    p_customer_id    IN NUMBER,
    p_site_use_code  IN VARCHAR2,
    p_location       IN VARCHAR2,
    x_return_status out nocopy  varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2)
IS
 dummy number;
--
BEGIN
        --
        --
        -- Site Use location must be unique within customer,site_use_code
        --
--Bug No : 2998504. Status check added to the where clause.
     BEGIN

        select  1
         into  dummy
         from hz_cust_site_uses su,
              hz_cust_acct_sites addr
        where su.cust_acct_site_ID = addr.cust_acct_site_ID
          and su.site_use_code     = p_site_use_code
          and su.location          = p_location
          and addr.cust_account_ID = p_customer_id
          and ( ( p_site_use_id is null ) or ( site_use_id <> p_site_use_id ))
	  and su.org_id = (select org_id from hz_cust_site_uses where site_use_id=p_site_use_id)         -- 6066859
          and su.STATUS = 'A'
          and rownum = 1;
        --
       IF ( dummy >= 1 ) THEN
           fnd_message.set_name('AR','AR_CUST_DUP_CODE_LOCATION');
           --app_exception.raise_exception;
           FND_MSG_PUB.ADD;
           x_return_status :=  FND_API.G_RET_STS_ERROR;
           x_msg_count := 1;
           x_msg_data := 'AR_CUST_DUP_CODE_LOCATION';
           return;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL;
    END;
        --
        --
END check_unique_location;
--



--
--
-- PROCEDURE
--     check_primary
--
-- DESCRIPTION
--		This procedure ensures that an address only has one active
--		site use per type.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			- p_site_use_id
--			- p_customer_id,
--			- p_site_use_code
--
--              OUT:
--
-- NOTES
--
--
--
  PROCEDURE check_primary ( p_site_use_id in number, p_customer_id in number, p_site_use_code in varchar2) is
  --
  dummy number;
  l_site_use_meaning varchar2(80);
  --
  begin
	select 	count(1)
	into   	dummy
	from   	hz_cust_accounts cust,
	       	hz_cust_acct_sites addr,
		hz_cust_site_uses su
	where 	su.cust_acct_site_ID 		= addr.cust_acct_site_ID
	and 	addr.cust_account_ID 	= cust.cust_account_ID
	and 	cust.cust_account_ID	= p_customer_id
	and 	site_use_code 		= p_site_use_code
	and 	su.primary_flag 	= 'Y'
	and 	su.status 		= 'A'
	and	( ( p_site_use_id is null) or (site_use_id <> p_site_use_id));
	--
	if ( dummy >= 1 ) then
		--
		--
		select 	meaning
		into   	l_site_use_meaning
		from 	ar_lookups
		where 	lookup_type = 'SITE_USE_CODE'
		and	lookup_code = p_site_use_code;
		--
		fnd_message.set_name('AR','AR_CUST_ONE_PRIMARY_SU');
		fnd_message.set_token('SITE_CODE',l_site_use_meaning);
		app_exception.raise_exception;
	end if;
  --
  end   check_primary;
--
--
--
  PROCEDURE Insert_Row(
                       X_Site_Use_Id             IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Site_Use_Code                  VARCHAR2,
		         X_customer_id			  NUMBER,
                       X_Address_Id                     NUMBER,
                       X_Primary_Flag                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Location               IN OUT NOCOPY  VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Bill_To_Site_Use_Id            NUMBER,
                       X_Sic_Code                       VARCHAR2,
                       X_Payment_Term_Id                NUMBER,
                       X_Gsa_Indicator                  VARCHAR2,
                       X_Ship_Partial                   VARCHAR2,
                       X_Ship_Via                       VARCHAR2,
                       X_Fob_Point                      VARCHAR2,
                       X_Order_Type_Id                  NUMBER,
                       X_Price_List_Id                  NUMBER,
                       X_Freight_Term                   VARCHAR2,
                       X_Warehouse_Id                   NUMBER,
                       X_Territory_Id                   NUMBER,
                       X_Tax_Code                       VARCHAR2,
                       X_Tax_Reference                  VARCHAR2,
                       X_Demand_Class_Code              VARCHAR2,
                       x_inventory_location_id		  NUMBER,
		         x_inventory_organization_id      NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Tax_Classification             VARCHAR2,
                       X_Tax_Header_Level_Flag          VARCHAR2,
                       X_Tax_Rounding_Rule              VARCHAR2,
                       X_Global_Attribute_Category      VARCHAR2,
                       X_Global_Attribute1              VARCHAR2,
                       X_Global_Attribute2              VARCHAR2,
                       X_Global_Attribute3              VARCHAR2,
                       X_Global_Attribute4              VARCHAR2,
                       X_Global_Attribute5              VARCHAR2,
                       X_Global_Attribute6              VARCHAR2,
                       X_Global_Attribute7              VARCHAR2,
                       X_Global_Attribute8              VARCHAR2,
                       X_Global_Attribute9              VARCHAR2,
                       X_Global_Attribute10             VARCHAR2,
                       X_Global_Attribute11             VARCHAR2,
                       X_Global_Attribute12             VARCHAR2,
                       X_Global_Attribute13             VARCHAR2,
                       X_Global_Attribute14             VARCHAR2,
                       X_Global_Attribute15             VARCHAR2,
                       X_Global_Attribute16             VARCHAR2,
                       X_Global_Attribute17             VARCHAR2,
                       X_Global_Attribute18             VARCHAR2,
                       X_Global_Attribute19             VARCHAR2,
                       X_Global_Attribute20             VARCHAR2,
                       X_Primary_Salesrep_Id            NUMBER  DEFAULT NULL,
                       X_Finchrg_Receivables_Trx_Id     NUMBER  DEFAULT NULL,
 		         X_GL_ID_Rec                      NUMBER,
		         X_GL_ID_Rev	                     NUMBER,
                       X_GL_ID_Tax	                     NUMBER,
		         X_GL_ID_Freight                  NUMBER,
                       X_GL_ID_Clearing                 NUMBER,
		         X_GL_ID_Unbilled                 NUMBER,
		         X_GL_ID_Unearned                 NUMBER,
                       X_GL_ID_Unpaid_rec               NUMBER,
                       X_GL_ID_Remittance               NUMBER,
                       X_GL_ID_Factor                   NUMBER,
                       X_DATES_NEGATIVE_TOLERANCE       NUMBER,
                       X_DATES_POSITIVE_TOLERANCE       NUMBER,
                       X_DATE_TYPE_PREFERENCE           VARCHAR2,
                       X_OVER_SHIPMENT_TOLERANCE        NUMBER,
                       X_UNDER_SHIPMENT_TOLERANCE       NUMBER,
                       X_ITEM_CROSS_REF_PREF            VARCHAR2,
                       X_OVER_RETURN_TOLERANCE          NUMBER,
                       X_UNDER_RETURN_TOLERANCE         NUMBER,
                       X_SHIP_SETS_INCLUDE_LINES_FLAG   VARCHAR2,
                       X_ARRIVALSETS_INCL_LINES_FLAG    VARCHAR2,
                       X_SCHED_DATE_PUSH_FLAG           VARCHAR2,
                       X_INVOICE_QUANTITY_RULE          VARCHAR2,
                       x_msg_count                  OUT NOCOPY number,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2
 		  )

   IS

    suse_rec        hz_cust_account_site_v2pub.cust_site_use_rec_type;
    profile_rec     hz_customer_profile_v2pub.customer_profile_rec_type;
    tmp_var         VARCHAR2(2000);
    i               NUMBER;
    tmp_var1        VARCHAR2(2000);

   BEGIN


     IF X_SITE_USE_CODE <> FND_API.G_MISS_CHAR AND X_SITE_USE_CODE IS NOT NULL THEN


       x_return_status  := FND_API.G_RET_STS_SUCCESS;


       select hz_cust_site_uses_s.nextval into x_site_use_id from dual;
       --
       --
       --
       -- Location will be null if automatic site number = 'Y'
       -- or form parameter :parameter.addr_mode = 'QUICK'
       --
       if ( x_location is null ) then
		x_location := x_site_use_id ;
       end if;
       --
       --

       if ( x_status = 'A' ) then
       --Calling overloaded check_unique_site_use_code, for graceful handling of error situation
		check_unique_site_use_code( p_site_use_id   => x_site_use_id,
					   p_customer_id   => x_customer_id,
					   p_address_id    => x_address_id,
					   p_site_use_code => x_site_use_code,
					   x_return_status => x_return_status,
                                           x_msg_count => x_msg_count,
                                           x_msg_data => x_msg_data
                                           );
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
       return;
       end if;
       end if;
       --
       --Calling overloaded check_unique_site_use_location, for graceful handling of error situation

       check_unique_location (	p_site_use_id 	=> x_site_use_id,
				p_customer_id 	=> x_customer_id,
				p_site_use_code => x_site_use_code,
				p_location      => x_location,
			        x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data
                                );
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
       return;
       end if;
       --
       --
       -- Bug#3170887: Commented out no longer necessary logic handled by V2 api
       --{
       --if (x_primary_flag = 'Y' and x_status = 'A' ) then
       --  check_primary( p_site_use_id   => x_site_use_id,
       --                 p_customer_id   => x_customer_id,
       --                 p_site_use_code => x_site_use_code);
       --end if;
       --}
    --
    -- If inventory_location_id is not null insert a row into
    -- po_location_associations
    --

    if ( x_site_use_code = 'SHIP_TO' and x_inventory_location_id is not null ) then
    --
    --
   	arp_clas_pkg.insert_po_loc_associations( p_inventory_location_id	=> x_inventory_location_id,
						p_inventory_organization_id	=> x_inventory_organization_id,
						p_customer_id 			=> x_customer_id,
						p_address_id			=> x_address_id,
						p_site_use_id			=> x_site_use_id,
                                                x_return_status                 => x_return_status,
                                                x_msg_count                     => x_msg_count,
                                                x_msg_data                      => x_msg_data
                                                );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
      END IF;
    end if;


    suse_rec.site_use_id                   := x_site_use_id;
    suse_rec.cust_acct_site_id             := X_Address_Id;
    suse_rec.site_use_code                 := X_Site_Use_Code;
    suse_rec.primary_flag                  := X_Primary_Flag;
    suse_rec.location                      := X_Location;
    suse_rec.contact_id                    := X_Contact_id;
    suse_rec.Bill_To_Site_Use_Id           := X_Bill_To_Site_Use_Id;
    suse_rec.sic_code                      := X_Sic_Code;
    suse_rec.payment_term_id               := X_Payment_Term_Id;
    suse_rec.Gsa_Indicator                 := X_Gsa_Indicator;
    suse_rec.ship_partial                  := X_Ship_Partial;
    suse_rec.ship_via                      := X_Ship_Via;
    suse_rec.fob_point                     := X_Fob_Point;
    suse_rec.order_type_id                 := X_Order_Type_Id;
    suse_rec.price_list_id                 := X_Price_List_Id;
    suse_rec.freight_term                  := X_Freight_Term;
    suse_rec.warehouse_id                  := X_Warehouse_Id;
    suse_rec.territory_id                  := X_Territory_Id;
    suse_rec.Tax_Reference                 := X_Tax_Reference;
    suse_rec.status                        := x_status;
    suse_rec.tax_code                      := X_Tax_Code;
    suse_rec.Demand_Class_Code             := X_Demand_Class_Code;
    suse_rec.Tax_Header_Level_Flag         := X_Tax_Header_Level_Flag;
    suse_rec.Tax_Rounding_Rule             := X_Tax_Rounding_Rule;
    suse_rec.Primary_Salesrep_Id           := X_Primary_Salesrep_Id;
    suse_rec.Finchrg_Receivables_Trx_Id    := X_Finchrg_Receivables_Trx_Id;
    suse_rec.DATES_NEGATIVE_TOLERANCE      := X_DATES_NEGATIVE_TOLERANCE;
    suse_rec.DATES_POSITIVE_TOLERANCE      := X_DATES_POSITIVE_TOLERANCE;
    suse_rec.DATE_TYPE_PREFERENCE          := X_DATE_TYPE_PREFERENCE;
    suse_rec.OVER_SHIPMENT_TOLERANCE       := X_OVER_SHIPMENT_TOLERANCE;
    suse_rec.UNDER_SHIPMENT_TOLERANCE      := X_UNDER_SHIPMENT_TOLERANCE;
    suse_rec.ITEM_CROSS_REF_PREF           := X_ITEM_CROSS_REF_PREF;
    suse_rec.SHIP_SETS_INCLUDE_LINES_FLAG  := X_SHIP_SETS_INCLUDE_LINES_FLAG;
    suse_rec.ARRIVALSETS_INCLUDE_LINES_FLAG:= X_ARRIVALSETS_INCL_LINES_FLAG;
    suse_rec.SCHED_DATE_PUSH_FLAG          := X_SCHED_DATE_PUSH_FLAG;
    suse_rec.INVOICE_QUANTITY_RULE         := X_INVOICE_QUANTITY_RULE;
    suse_rec.OVER_RETURN_TOLERANCE         := X_OVER_RETURN_TOLERANCE;
    suse_rec.UNDER_RETURN_TOLERANCE        := X_UNDER_RETURN_TOLERANCE;
    suse_rec.GL_ID_Rec                     := X_GL_ID_Rec;
    suse_rec.GL_ID_Rev                     := X_GL_ID_Rev;
    suse_rec.GL_ID_Tax                     := X_GL_ID_Tax;
    suse_rec.GL_ID_Freight                 := X_GL_ID_Freight;
    suse_rec.GL_ID_Clearing                := X_GL_ID_Clearing;
    suse_rec.GL_ID_Unbilled                := X_GL_ID_Unbilled;
    suse_rec.GL_ID_Unearned                := X_GL_ID_Unearned;
    suse_rec.GL_ID_unpaid_rec              := X_GL_ID_Unpaid_rec;
    suse_rec.GL_ID_remittance              := X_GL_ID_remittance;
    suse_rec.GL_ID_factor                  := X_GL_ID_factor;
    suse_rec.attribute_category            := x_attribute_category;
    suse_rec.attribute1                    := X_Attribute1;
    suse_rec.attribute2                    := X_Attribute2;
    suse_rec.attribute3                    := X_Attribute3;
    suse_rec.attribute4                    := X_Attribute4;
    suse_rec.attribute5                    := X_Attribute5;
    suse_rec.attribute6                    := X_Attribute6;
    suse_rec.attribute7                    := X_Attribute7;
    suse_rec.attribute8                    := X_Attribute8;
    suse_rec.attribute9                    := X_Attribute9;
    suse_rec.attribute10                   := X_Attribute10;
    suse_rec.attribute11                   := X_Attribute11;
    suse_rec.attribute12                   := X_Attribute12;
    suse_rec.attribute13                   := X_Attribute13;
    suse_rec.attribute14                   := X_Attribute14;
    suse_rec.attribute15                   := X_Attribute15;
    suse_rec.attribute16                   := X_Attribute16;
    suse_rec.attribute17                   := X_Attribute17;
    suse_rec.attribute18                   := X_Attribute18;
    suse_rec.attribute19                   := X_Attribute19;
    suse_rec.attribute20                   := X_Attribute20;
    suse_rec.attribute21                   := X_Attribute21;
    suse_rec.attribute22                   := X_Attribute22;
    suse_rec.attribute23                   := X_Attribute23;
    suse_rec.attribute24                   := X_Attribute24;
    suse_rec.attribute25                   := X_Attribute25;
    suse_rec.Global_Attribute_Category     := X_Global_Attribute_Category;
    suse_rec.Global_Attribute1             := X_Global_Attribute1;
    suse_rec.Global_Attribute2             := X_Global_Attribute2;
    suse_rec.Global_Attribute3             := X_Global_Attribute3;
    suse_rec.Global_Attribute4             := X_Global_Attribute4;
    suse_rec.Global_Attribute5             := X_Global_Attribute5;
    suse_rec.Global_Attribute6             := X_Global_Attribute6;
    suse_rec.Global_Attribute7             := X_Global_Attribute7;
    suse_rec.Global_Attribute8             := X_Global_Attribute8;
    suse_rec.Global_Attribute9             := X_Global_Attribute9;
    suse_rec.Global_Attribute10            := X_Global_Attribute10;
    suse_rec.Global_Attribute11            := X_Global_Attribute11;
    suse_rec.Global_Attribute12            := X_Global_Attribute12;
    suse_rec.Global_Attribute13            := X_Global_Attribute13;
    suse_rec.Global_Attribute14            := X_Global_Attribute14;
    suse_rec.Global_Attribute15            := X_Global_Attribute15;
    suse_rec.Global_Attribute16            := X_Global_Attribute16;
    suse_rec.Global_Attribute17            := X_Global_Attribute17;
    suse_rec.Global_Attribute18            := X_Global_Attribute18;
    suse_rec.Global_Attribute19            := X_Global_Attribute19;
    suse_rec.Global_Attribute20            := X_Global_Attribute20;
    suse_rec.tax_classification            := x_tax_classification;
    suse_rec.created_by_module             := 'TCA_FORM_WRAPPER';

    HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use (
            p_cust_site_use_rec                 => suse_rec,
            p_customer_profile_rec              => profile_rec,
            p_create_profile                    => fnd_api.g_false,
            p_create_profile_amt                => fnd_api.g_false,
            x_site_use_id                       => x_site_use_id,
            x_return_status                     => x_return_status,
            x_msg_count                         => x_msg_count,
            x_msg_data                          => x_msg_data    );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

    --
    --  Update denormalized site_use_id's on RA_CUSTOMERS,RA_ADDRESSES
    --
    --
/* bug3297313 : The call to procedure maintain_denormalized_data is commented out
                as this will be taken care in TCA API
*/
/*
    maintain_denormalized_data(
          p_customer_id     => x_customer_id,
          p_address_id      => x_address_id,
          p_site_use_id     => x_site_use_id,
          p_site_use_code   => x_site_use_code,
          p_status          => x_status,
          p_primary_flag    => x_primary_flag );
*/
    --
    --
    --
  END IF;

 END Insert_Row;
--
--

  PROCEDURE Update_Row(
                       X_Site_Use_Id            IN OUT NOCOPY  NUMBER,
                       X_Last_Update_Date       IN OUT NOCOPY  DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Site_Use_Code                  VARCHAR2,
                       X_customer_id                    NUMBER,
                       X_Address_Id                     NUMBER,
                       X_Primary_Flag                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Location                       VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Bill_To_Site_Use_Id            NUMBER,
                       X_Sic_Code                       VARCHAR2,
                       X_Payment_Term_Id                NUMBER,
                       X_Gsa_Indicator                  VARCHAR2,
                       X_Ship_Partial                   VARCHAR2,
                       X_Ship_Via                       VARCHAR2,
                       X_Fob_Point                      VARCHAR2,
                       X_Order_Type_Id                  NUMBER,
                       X_Price_List_Id                  NUMBER,
                       X_Freight_Term                   VARCHAR2,
                       X_Warehouse_Id                   NUMBER,
                       X_Territory_Id                   NUMBER,
                       X_Tax_Code                       VARCHAR2,
                       X_Tax_Reference                  VARCHAR2,
                       X_Demand_Class_Code              VARCHAR2,
                       x_inventory_location_id          NUMBER,
                       x_inventory_organization_id      NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Tax_Classification             VARCHAR2,
                       X_Tax_Header_Level_Flag          VARCHAR2,
                       X_Tax_Rounding_Rule              VARCHAR2,
                       X_Global_Attribute_Category      VARCHAR2,
                       X_Global_Attribute1              VARCHAR2,
                       X_Global_Attribute2              VARCHAR2,
                       X_Global_Attribute3              VARCHAR2,
                       X_Global_Attribute4              VARCHAR2,
                       X_Global_Attribute5              VARCHAR2,
                       X_Global_Attribute6              VARCHAR2,
                       X_Global_Attribute7              VARCHAR2,
                       X_Global_Attribute8              VARCHAR2,
                       X_Global_Attribute9              VARCHAR2,
                       X_Global_Attribute10             VARCHAR2,
                       X_Global_Attribute11             VARCHAR2,
                       X_Global_Attribute12             VARCHAR2,
                       X_Global_Attribute13             VARCHAR2,
                       X_Global_Attribute14             VARCHAR2,
                       X_Global_Attribute15             VARCHAR2,
                       X_Global_Attribute16             VARCHAR2,
                       X_Global_Attribute17             VARCHAR2,
                       X_Global_Attribute18             VARCHAR2,
                       X_Global_Attribute19             VARCHAR2,
                       X_Global_Attribute20             VARCHAR2,
                       X_Primary_Salesrep_Id            NUMBER  DEFAULT NULL,
                       X_Finchrg_Receivables_Trx_Id     NUMBER  DEFAULT NULL,
                       X_GL_ID_Rec                      NUMBER,
		           X_GL_ID_Rev                    NUMBER,
                       X_GL_ID_Tax	                      NUMBER,
                       X_GL_ID_Freight                  NUMBER,
                       X_GL_ID_Clearing                 NUMBER,
                       X_GL_ID_Unbilled                 NUMBER,
                       X_GL_ID_Unearned                 NUMBER,
                       X_GL_ID_Unpaid_rec               NUMBER,
                       X_GL_ID_Remittance               NUMBER,
                       X_GL_ID_Factor                   NUMBER,
                       X_DATES_NEGATIVE_TOLERANCE       NUMBER,
                       X_DATES_POSITIVE_TOLERANCE       NUMBER,
                       X_DATE_TYPE_PREFERENCE           VARCHAR2,
                       X_OVER_SHIPMENT_TOLERANCE        NUMBER,
                       X_UNDER_SHIPMENT_TOLERANCE       NUMBER,
                       X_ITEM_CROSS_REF_PREF            VARCHAR2,
                       X_OVER_RETURN_TOLERANCE          NUMBER,
                       X_UNDER_RETURN_TOLERANCE         NUMBER,
                       X_SHIP_SETS_INCLUDE_LINES_FLAG   VARCHAR2,
                       X_ARRIVALSETS_INCL_LINES_FLAG    VARCHAR2,
                       X_SCHED_DATE_PUSH_FLAG           VARCHAR2,
                       X_INVOICE_QUANTITY_RULE          VARCHAR2,
                       x_msg_count                  OUT NOCOPY number,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2,
                       x_object_version             IN  NUMBER  DEFAULT -1

  ) IS
 --

   l_inventory_location_id number;
   suse_rec        hz_cust_account_site_v2pub.cust_site_use_rec_type;
   profile_rec     hz_customer_profile_v2pub.customer_profile_rec_type;
   x_date          date;
   tmp_var         VARCHAR2(2000);
   i               number;
   tmp_var1        VARCHAR2(2000);
   ExpAcctSiteUse  EXCEPTION;

  CURSOR cu_version IS
  SELECT ROWID,
         OBJECT_VERSION_NUMBER,
         LAST_UPDATE_DATE
    FROM hz_cust_site_uses
   WHERE site_use_id = X_Site_Use_Id;

  l_site_object_version_number   NUMBER;
  l_site_use_rowid               ROWID;
  l_site_use_last_update_date    DATE;
 --
  BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- For Backward compatibility when Object Version Number is not entered
   --
   IF x_object_version = -1 THEN
     OPEN cu_version;
     FETCH cu_version INTO
           l_site_use_rowid            ,
           l_site_object_version_number,
           l_site_use_last_update_date ;
     IF cu_version%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD','hz_cust_site_uses');
        FND_MESSAGE.SET_TOKEN('ID',x_site_use_id);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     CLOSE cu_version;

     IF TO_CHAR(X_Last_Update_Date,'DD-MON-YYYY HH:MI:SS') <>
        TO_CHAR(l_site_use_last_update_date,'DD-MON-YYYY HH:MI:SS')
     THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'hz_cust_site_uses');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSE
     l_site_object_version_number := x_object_version;
   END IF;
   --
   --
   --
    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;
   --
   --
   -- In update case for V2 record type data need to switch from NULL to G_MISS
   --
   --
   --
    suse_rec.site_use_id                    := x_site_use_id;
    suse_rec.cust_acct_site_id              := X_Address_Id;
    suse_rec.site_use_code                  := INIT_SWITCH(X_Site_Use_Code);
    suse_rec.primary_flag                   := INIT_SWITCH(X_Primary_Flag);
    suse_rec.location                       := INIT_SWITCH(X_Location);
    suse_rec.contact_id                     := INIT_SWITCH(X_Contact_id);
    suse_rec.Bill_To_Site_Use_Id            := INIT_SWITCH(X_Bill_To_Site_Use_Id);
    suse_rec.sic_code                       := INIT_SWITCH(X_Sic_Code);
    suse_rec.payment_term_id                := INIT_SWITCH(X_Payment_Term_Id);
    suse_rec.Gsa_Indicator                  := INIT_SWITCH(X_Gsa_Indicator);
    suse_rec.ship_partial                   := INIT_SWITCH(X_Ship_Partial);
    suse_rec.ship_via                       := INIT_SWITCH(X_Ship_Via);
    suse_rec.fob_point                      := INIT_SWITCH(X_Fob_Point);
    suse_rec.order_type_id                  := INIT_SWITCH(X_Order_Type_Id);
    suse_rec.price_list_id                  := INIT_SWITCH(X_Price_List_Id);
    suse_rec.freight_term                   := INIT_SWITCH(X_Freight_Term);
    suse_rec.warehouse_id                   := INIT_SWITCH(X_Warehouse_Id);
    suse_rec.territory_id                   := INIT_SWITCH(X_Territory_Id);
    suse_rec.Tax_Reference                  := INIT_SWITCH(X_Tax_Reference);
    suse_rec.status                         := INIT_SWITCH(x_status);
    suse_rec.tax_code                       := INIT_SWITCH(X_Tax_Code);
    suse_rec.Demand_Class_Code              := INIT_SWITCH(X_Demand_Class_Code);
    suse_rec.Tax_Header_Level_Flag          := INIT_SWITCH(X_Tax_Header_Level_Flag);
    suse_rec.Tax_Rounding_Rule              := INIT_SWITCH(X_Tax_Rounding_Rule);
    suse_rec.Primary_Salesrep_Id            := INIT_SWITCH(X_Primary_Salesrep_Id);
    suse_rec.Finchrg_Receivables_Trx_Id     := INIT_SWITCH(X_Finchrg_Receivables_Trx_Id);
    suse_rec.DATES_NEGATIVE_TOLERANCE       := INIT_SWITCH(X_DATES_NEGATIVE_TOLERANCE);
    suse_rec.DATES_POSITIVE_TOLERANCE       := INIT_SWITCH(X_DATES_POSITIVE_TOLERANCE);
    suse_rec.DATE_TYPE_PREFERENCE           := INIT_SWITCH(X_DATE_TYPE_PREFERENCE);
    suse_rec.OVER_SHIPMENT_TOLERANCE        := INIT_SWITCH(X_OVER_SHIPMENT_TOLERANCE);
    suse_rec.UNDER_SHIPMENT_TOLERANCE       := INIT_SWITCH(X_UNDER_SHIPMENT_TOLERANCE);
    suse_rec.ITEM_CROSS_REF_PREF            := INIT_SWITCH(X_ITEM_CROSS_REF_PREF);
    suse_rec.SHIP_SETS_INCLUDE_LINES_FLAG   := INIT_SWITCH(X_SHIP_SETS_INCLUDE_LINES_FLAG);
    suse_rec.ARRIVALSETS_INCLUDE_LINES_FLAG := INIT_SWITCH(X_ARRIVALSETS_INCL_LINES_FLAG);
    suse_rec.SCHED_DATE_PUSH_FLAG           := INIT_SWITCH(X_SCHED_DATE_PUSH_FLAG);
    suse_rec.INVOICE_QUANTITY_RULE          := INIT_SWITCH(X_INVOICE_QUANTITY_RULE);
    suse_rec.OVER_RETURN_TOLERANCE          := INIT_SWITCH(X_OVER_RETURN_TOLERANCE);
    suse_rec.UNDER_RETURN_TOLERANCE         := INIT_SWITCH(X_UNDER_RETURN_TOLERANCE);
    suse_rec.GL_ID_Rec                      := INIT_SWITCH(X_GL_ID_Rec);
    suse_rec.GL_ID_Rev                      := INIT_SWITCH(X_GL_ID_Rev);
    suse_rec.GL_ID_Tax                      := INIT_SWITCH(X_GL_ID_Tax);
    suse_rec.GL_ID_Freight                  := INIT_SWITCH(X_GL_ID_Freight);
    suse_rec.GL_ID_Clearing                 := INIT_SWITCH(X_GL_ID_Clearing);
    suse_rec.GL_ID_Unbilled                 := INIT_SWITCH(X_GL_ID_Unbilled);
    suse_rec.GL_ID_Unearned                 := INIT_SWITCH(X_GL_ID_Unearned);
    suse_rec.GL_ID_unpaid_rec               := INIT_SWITCH(X_GL_ID_Unpaid_rec);
    suse_rec.GL_ID_remittance               := INIT_SWITCH(X_GL_ID_remittance);
    suse_rec.GL_ID_factor                   := INIT_SWITCH(X_GL_ID_factor);
    suse_rec.attribute_category             := INIT_SWITCH(x_attribute_category);
    suse_rec.attribute1                     := INIT_SWITCH(X_Attribute1);
    suse_rec.attribute2                     := INIT_SWITCH(X_Attribute2);
    suse_rec.attribute3                     := INIT_SWITCH(X_Attribute3);
    suse_rec.attribute4                     := INIT_SWITCH(X_Attribute4);
    suse_rec.attribute5                     := INIT_SWITCH(X_Attribute5);
    suse_rec.attribute6                     := INIT_SWITCH(X_Attribute6);
    suse_rec.attribute7                     := INIT_SWITCH(X_Attribute7);
    suse_rec.attribute8                     := INIT_SWITCH(X_Attribute8);
    suse_rec.attribute9                     := INIT_SWITCH(X_Attribute9);
    suse_rec.attribute10                    := INIT_SWITCH(X_Attribute10);
    suse_rec.attribute11                    := INIT_SWITCH(X_Attribute11);
    suse_rec.attribute12                    := INIT_SWITCH(X_Attribute12);
    suse_rec.attribute13                    := INIT_SWITCH(X_Attribute13);
    suse_rec.attribute14                    := INIT_SWITCH(X_Attribute14);
    suse_rec.attribute15                    := INIT_SWITCH(X_Attribute15);
    suse_rec.attribute16                    := INIT_SWITCH(X_Attribute16);
    suse_rec.attribute17                    := INIT_SWITCH(X_Attribute17);
    suse_rec.attribute18                    := INIT_SWITCH(X_Attribute18);
    suse_rec.attribute19                    := INIT_SWITCH(X_Attribute19);
    suse_rec.attribute20                    := INIT_SWITCH(X_Attribute20);
    suse_rec.attribute21                    := INIT_SWITCH(X_Attribute21);
    suse_rec.attribute22                    := INIT_SWITCH(X_Attribute22);
    suse_rec.attribute23                    := INIT_SWITCH(X_Attribute23);
    suse_rec.attribute24                    := INIT_SWITCH(X_Attribute24);
    suse_rec.attribute25                    := INIT_SWITCH(X_Attribute25);
    suse_rec.Global_Attribute_Category      := INIT_SWITCH(X_Global_Attribute_Category);
    suse_rec.Global_Attribute1              := INIT_SWITCH(X_Global_Attribute1);
    suse_rec.Global_Attribute2              := INIT_SWITCH(X_Global_Attribute2);
    suse_rec.Global_Attribute3              := INIT_SWITCH(X_Global_Attribute3);
    suse_rec.Global_Attribute4              := INIT_SWITCH(X_Global_Attribute4);
    suse_rec.Global_Attribute5              := INIT_SWITCH(X_Global_Attribute5);
    suse_rec.Global_Attribute6              := INIT_SWITCH(X_Global_Attribute6);
    suse_rec.Global_Attribute7              := INIT_SWITCH(X_Global_Attribute7);
    suse_rec.Global_Attribute8              := INIT_SWITCH(X_Global_Attribute8);
    suse_rec.Global_Attribute9              := INIT_SWITCH(X_Global_Attribute9);
    suse_rec.Global_Attribute10             := INIT_SWITCH(X_Global_Attribute10);
    suse_rec.Global_Attribute11             := INIT_SWITCH(X_Global_Attribute11);
    suse_rec.Global_Attribute12             := INIT_SWITCH(X_Global_Attribute12);
    suse_rec.Global_Attribute13             := INIT_SWITCH(X_Global_Attribute13);
    suse_rec.Global_Attribute14             := INIT_SWITCH(X_Global_Attribute14);
    suse_rec.Global_Attribute15             := INIT_SWITCH(X_Global_Attribute15);
    suse_rec.Global_Attribute16             := INIT_SWITCH(X_Global_Attribute16);
    suse_rec.Global_Attribute17             := INIT_SWITCH(X_Global_Attribute17);
    suse_rec.Global_Attribute18             := INIT_SWITCH(X_Global_Attribute18);
    suse_rec.Global_Attribute19             := INIT_SWITCH(X_Global_Attribute19);
    suse_rec.Global_Attribute20             := INIT_SWITCH(X_Global_Attribute20);
    suse_rec.tax_classification             := INIT_SWITCH(x_tax_classification);

    if ( x_status = 'A' ) then
    --Calling overloaded check_unique_site_use_code, for graceful handling of error situation
                check_unique_site_use_code( p_site_use_id   => x_site_use_id,
                                           p_customer_id   => x_customer_id,
                                           p_address_id    => x_address_id,
                                           p_site_use_code => x_site_use_code,
                                           x_return_status => x_return_status,
                                           x_msg_count => x_msg_count,
                                           x_msg_data => x_msg_data
                                           );
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
       return;
       end if;
       end if;
    --
    --Calling oveloaded check_uniqute_location for graceful handling of error situation
    check_unique_location (  p_site_use_id   => x_site_use_id,
                                p_customer_id   => x_customer_id,
                                p_site_use_code => x_site_use_code,
                                p_location      => x_location,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data
                                );
       if x_return_status <> FND_API.G_RET_STS_SUCCESS then
       return;
       end if;
   --
   --
   -- Bug#3170887: Commented out no longer necessary logic handled by V2 api
   --{
   --if ( x_primary_flag = 'Y' and x_status = 'A' ) then
   --check_primary(	p_site_use_id   => x_site_use_id,
   --               p_customer_id   => x_customer_id,
   --               p_site_use_code => x_site_use_code );
   --end if;
   --}
   --
   -- If the current SHIP_TO site is associated with a different inventory location
   -- delete the row in po_location_associations and insert a new row.
   --
   if ( x_site_use_code = 'SHIP_TO' ) then
	--
	arp_clas_pkg.update_po_loc_associations(
		p_site_use_id 			=> x_site_use_id,
		p_address_id  			=> x_address_id,
		p_customer_id 			=> x_customer_id,
		p_inventory_organization_id 	=> x_inventory_organization_id,
		p_inventory_location_id		=> x_inventory_location_id,
                x_return_status                 => x_return_status,
                x_msg_count                     => x_msg_count,
                x_msg_data                      => x_msg_data
                                        	);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
      END IF;
	--
   end if;
   --
   --
   --
   -- call V2 API
   HZ_CUST_ACCOUNT_SITE_V2PUB.update_cust_site_use (
         p_cust_site_use_rec                 => suse_rec,
         p_object_version_number             => l_site_object_version_number,
         x_return_status                     => x_return_status,
         x_msg_count                         => x_msg_count,
         x_msg_data                          => x_msg_data
        );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;
   --
   -- Backward compatibility
   --
   SELECT last_update_date
     into x_last_update_date
     from hz_cust_site_uses
    where site_use_id = x_site_use_id;
   --
   --
   --
/* bug3297313 : The call to procedure maintain_denormalized_data is commented out
                as this will be taken care in TCA API
*/
/*
   maintain_denormalized_data ( p_customer_id   => x_customer_id,
                                p_address_id    => x_address_id,
                                p_site_use_id   => x_site_use_id,
                                p_site_use_code => x_site_use_code,
                                p_status        => x_status,
                                p_primary_flag  => x_primary_flag );
*/
  --
  END Update_Row;
--
--
END arh_csu_pkg;

/
