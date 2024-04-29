--------------------------------------------------------
--  DDL for Package Body HZP_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZP_CUST_PKG" AS
/* $Header: ARHCUSTB.pls 120.7 2005/06/16 21:10:13 jhuang ship $*/
  --
  -- PROCEDURE
  --     check_unique_customer_name
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
  --			- p_rowid - rowid of row
  --			- p_customer_name
  --
  --              OUT:
  --			- p_warning_flag  - Tells calling routine that there
  --                                        is a non fatal warning on the message stack
  --
  --   RETURNS  null
  --
  --  NOTES
  --
  --
  PROCEDURE check_unique_customer_name (p_rowid IN VARCHAR2,
                                        p_customer_name IN VARCHAR2,
                                        p_warning_flag IN OUT NOCOPY VARCHAR2) IS
    dummy NUMBER;
  BEGIN

  -- as per Sai... since this code was checking for account_name
  -- and not party_name, The code was modified to use party_name and
  -- then commented out since the initial logic was flawed.    This
  -- appears only in ARXCUDCI and even those calls are commented out.

    NULL;
/******************************************************************
 	select 1
	into   dummy
	from   dual
	where  not exists ( select 1
	         	   from  hz_parties
		 	   where  party_name = p_customer_name
		 	   and    ( ( p_rowid is null ) or (rowid <> p_rowid))
			  );
****************************************************************/
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name ('AR','AR_CUST_NAME_ALREADY_EXISTS');
      p_warning_flag := 'W';
  END check_unique_customer_name;
  --
  --
  --
  --
  --
  -- PROCEDURE
  --     check_unique_customer_number
  --
  -- DESCRIPTION
  --    RRaise error if customer number is duplicate
  --
  -- SCOPE - PUBLIC
  --
  -- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS  : IN:
  --			- p_rowid - rowid of row
  --			- p_customer_number
  --
  --              OUT:
  --
  --   RETURNS  null
  --
  --  NOTES
  --
  --
  PROCEDURE check_unique_customer_number(p_rowid IN VARCHAR2,
                                         p_customer_number IN VARCHAR2) IS
    dummy NUMBER;
  BEGIN

	select 1
	into   dummy
	from   dual
	where  not exists ( select 1
	         	   from   hz_cust_accounts
		 	   where  account_number = p_customer_number
		 	   and    ( ( p_rowid is null ) or (rowid <> p_rowid))
			  );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name ('AR','AR_CUST_NUMBER_EXISTS');
      app_exception.raise_exception;
  END check_unique_customer_number;
--
--
--
--
-- PROCEDURE
--     check_unique_party_number
--
-- DESCRIPTION
--    RRaise error if party number is duplicate
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--                      - p_rowid - rowid of row
--                      - p_party_number
--
--              OUT:
--
--   RETURNS  null
--
--  NOTES
--
--
procedure check_unique_party_number(p_rowid in varchar2,
                                       p_party_number in varchar2
                                      ) is
dummy number;
begin

        select 1
        into   dummy
        from   dual
        where  not exists ( select 1
                           from   hz_parties
                           where  party_number = p_party_number
                           and    ( ( p_rowid is null ) or (rowid <> p_rowid))
                          );

exception
        when NO_DATA_FOUND then
                fnd_message.set_name ('AR','AR_PARTY_NUMBER_EXISTS');
                app_exception.raise_exception;
end check_unique_party_number;
--
--
--
-- PROCEDURE
--      check_unique_orig_system_ref
--
-- DESCRIPTION
--    Raise error if orig_system_referenc is duplicate
--
-- SCOPE - PUBLIC
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			- p_rowid - rowid of row
--			- p_orig_system_reference
--
--              OUT:
--
--   RETURNS  null
--
--  NOTES
--
--
procedure check_unique_orig_system_ref(	p_rowid in varchar2,
			 	     	p_orig_system_reference in varchar2
				      ) is
dummy number;
begin
	select 1
	into   dummy
	from   dual
	where  not exists ( select 1
	         	   from   hz_cust_accounts c
		 	   where  c.orig_system_reference = p_orig_system_reference
		 	   and    ( ( p_rowid is null ) or (c.rowid <> p_rowid)));

exception
	when NO_DATA_FOUND then
		fnd_message.set_name ('AR','AR_CUST_REF_ALREADY_EXISTS');
		app_exception.raise_exception;

end check_unique_orig_system_ref;

  -- PROCEDURE
  --   delete_customer_alt_names
  --
  -- DESCRIPTION
  --   Procedure to delete alternate names.
  --
  -- SCOPE - PUBLIC
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS  : IN:
  --              - p_rowid - rowid of row
  --              - p_status
  --              - p_customer_id
  --              OUT:
  --
  -- RETURNS  null
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   06-Nov-01    Joe del Callar    Fixed bug 2092530.
  --

  PROCEDURE delete_customer_alt_names(p_rowid IN VARCHAR2,
                                      p_status IN VARCHAR2,
                                      p_customer_id IN NUMBER) IS
    l_status VARCHAR2(1);
    l_lock_status NUMBER;
    CURSOR statuscur IS
      SELECT status
      FROM   hz_cust_accounts
      WHERE  rowid = p_rowid;

  BEGIN
    -- bug 2092530: removed the check to the ar_alt_name_search profile
    -- option.  Also cleaned up the select into l_status statement.
    IF p_status = 'I' THEN

      OPEN statuscur;
      FETCH statuscur INTO l_status;
      CLOSE statuscur;

      IF (l_status = 'A') THEN

        arp_cust_alt_match_pkg.lock_match(p_customer_id, NULL, l_lock_status);

        IF (l_lock_status = 1) THEN
          -- bug 928111: added alt_name for delete.  but no way
          -- to derive it from here so we are passing null.
          arp_cust_alt_match_pkg.delete_match(p_customer_id, NULL, NULL) ;
        END IF;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug('EXCEPTION: arp_cust_pkg.delete_customer_alt_names');
  END delete_customer_alt_names;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_statement_site                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |    Returns the site_use_id of a STATEMENT (STMTS) associated with the     |
 |    customers address if present else return NULL.                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_id                                          |
 |              OUT:                                                         |
 |                    site_use_id                                            |
 |                                                                           |
 | RETURNS    : site_use_id where site_use_code = 'STMTS'                    |
 |                                                                           |
 |                                                                           |
 | NOTES      :                                                              |
 |                                                                           |
 |    The function is intended to be used in SQL statements.                 |
 |                                                                           |
 |    The intent of its creation was to minimize the code change for all the |
 |    SQLs which were using :                                                |
 |                                                                           |
 |    ra customers.statement_site_use_id = hz_cust_site_uses.site_use_id (+) |
 |                                                                           |
 |    These queries can now be changed to:                                   |
 |                                                                           |
 |    ARP_CUST_PKG.get_statement_site(hz_cust_accounts.cust_account_id) =    |
 |    hz_cust_site_uses.site_use_id (+)                                      |
 |                                                                           |
 |    Make sure you donot pass a constant as an argument when making use     |
 |    of this function in a query which is supposed to succeed even if the   |
 |    the statement site does not exist for a customer. The outer join does  |
 |    not kick off in an event when the function returns NULL thus making the|
 |    base query to fail.                                                    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |     19-JUN-1997  Neeraj Tandon     Created                                |
 |     04-May-2001  Debbie Jancis	Modified for tca uptake. Removed all |
 |					references of ra/ar customer tables  |
 |					and replaced with hz counterparts    |
 +===========================================================================*/

FUNCTION get_statement_site (
                      p_customer_id  IN hz_cust_accounts.cust_account_id%type
                            )
RETURN NUMBER is

  v_statement_site_use_id hz_cust_site_uses.site_use_id%type;

BEGIN

  select site_uses.site_use_id
  into   v_statement_site_use_id
  from   hz_cust_acct_sites acct_site,
         hz_cust_site_uses site_uses
  where  acct_site.cust_account_id    = p_customer_id
  and    site_uses.cust_acct_site_id    = acct_site.cust_acct_site_id
  and    site_uses.site_use_code = 'STMTS'
  and    site_uses.status        = 'A';

  return v_statement_site_use_id;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      return to_number(NULL);

    WHEN OTHERS THEN
      raise;

END;
--
--
/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_dunning_site                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |    Returns the site_use_id of DUNNING (DUN) associated with the           |
 |    customers address if present else return NULL.                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_id                                          |
 |              OUT:                                                         |
 |                    site_use_id                                            |
 |                                                                           |
 | RETURNS    : site_use_id where site_use_code = 'DUN'                      |
 |                                                                           |
 |                                                                           |
 | NOTES      :                                                              |
 |                                                                           |
 |    The function is intended to be used in SQL statements.                 |
 |                                                                           |
 |    The intent of its creation was to minimize the code change for all the |
 |    SQLs which were using :                                                |
 |                                                                           |
 |    ra customers.dunning_site_use_id  = hz_cust_site_uses.site_use_id (+)  |
 |                                                                           |
 |    These queries can now be changed to:                                   |
 |                                                                           |
 |    ARP_CUST_PKG.get_dunning(hz_cust_accounts.cust_account_id) =           |
 |    hz_cust_site_uses.site_use_id (+)                                      |
 |                                                                           |
 |    Make sure you donot pass a constant as an argument when making use     |
 |    of this function in a query which is supposed to succeed even if the   |
 |    the dunning   site does not exist for a customer. The outer join does  |
 |    not kick off in an event when the function returns NULL thus making the|
 |    base query to fail.                                                    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |     19-JUN-1997  Neeraj Tandon    Created                                 |
 |     04-May-2001  Debbie Jancis	Modified for tca uptake. Removed all |
 |					references of ra/ar customer tables  |
 |					and replaced with hz counterparts    |
 +===========================================================================*/

FUNCTION get_dunning_site (
                       p_customer_id  IN hz_cust_accounts.cust_account_id%type
                          )
RETURN NUMBER is

  v_dunning_site_use_id hz_cust_site_uses.site_use_id%type;

BEGIN

  select site_uses.site_use_id
  into   v_dunning_site_use_id
  from   hz_cust_acct_sites acct_site,
         hz_cust_site_uses site_uses
  where  acct_site.cust_account_id = p_customer_id
  and    site_uses.cust_acct_site_id    = acct_site.cust_acct_site_id
  and    site_uses.site_use_code = 'DUN'
  and    site_uses.status        = 'A';

  return v_dunning_site_use_id;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      return to_number(NULL);

    WHEN OTHERS THEN
      raise;

END;
--
--
/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_current_dunning_type                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |    Returns the current dunning_type associated with a customers profile   |
 |    or BILL_TO profile or Dunning profile                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_id                                          |
 |                    p_bill_to_site_id                                      |
 |              OUT:                                                         |
 |                    dunning_type                                           |
 |                                                                           |
 | NOTES      :                                                              |
 |     To be used in Account Details form to determine whether               |
 |     staged_dunning_level field of ar_payment_schedules is updateable      |
 |     or not.                                                               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |     30-JUN-1997  Neeraj Tandon    Created                                 |
 |                                                                           |
 +===========================================================================+*/
--
FUNCTION get_current_dunning_type (
              p_customer_id     IN hz_cust_accounts.cust_account_id%type,
              p_bill_to_site_id IN NUMBER
                                  )
  return varchar2 is
--
  v_dunning_site hz_cust_site_uses.site_use_id%type;
  v_dunning_type ar_dunning_letter_sets.dunning_type%type;
--
BEGIN
--
  v_dunning_site := get_dunning_site(p_customer_id);
--
  if v_dunning_site is NOT NULL then
--
    select dls.dunning_type
    into   v_dunning_type
    from   hz_customer_profiles    prof,
           ar_dunning_letter_sets  dls
    where  prof.cust_account_id           = p_customer_id
    and    prof.site_use_id          is NULL
    and    prof.dunning_letter_set_id = dls.dunning_letter_set_id;

  else
--
    select dls.dunning_type
    into   v_dunning_type
    from   hz_cust_site_uses       su,
           hz_cust_acct_sites      ad_cus,
           hz_customer_profiles    cust_pro,
           hz_customer_profiles    site_pro,
           ar_dunning_letter_sets  dls,
           hz_cust_accounts        cus
    where  su.site_use_code                = 'BILL_TO'
    and    su.status                       = 'A'
    and    su.site_use_id                  = p_bill_to_site_id
    and    ad_cus.cust_acct_site_id        = su.cust_acct_site_id
    and    ad_cus.status                   = 'A'
    and    cust_pro.cust_account_id        = ad_cus.cust_account_id
    and    cust_pro.site_use_id           is NULL
    and    cust_pro.status                 ='A'
    and    site_pro.site_use_id      (+)   = su.site_use_id
    and    site_pro.status           (+)   ='A'
    and    dls.dunning_letter_set_id    = nvl( site_pro.dunning_letter_set_id,
                                               cust_pro.dunning_letter_set_id )
    and    dls.status                      = 'A'
    and    cus.cust_account_id             = ad_cus.cust_account_id
    and    cus.status                      = 'A'
    and    cus.cust_account_id             = p_customer_id;

  end if;

  return v_dunning_type;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      return NULL;

    WHEN OTHERS THEN
      raise;

END;
--
FUNCTION arxvamai_overall_cr_limit ( p_customer_id NUMBER,
                                     p_currency_code VARCHAR2,
                                     p_customer_site_use_id NUMBER
                                    ) RETURN NUMBER is
  l_overall_cr_limit      NUMBER;
  cursor c_overall IS
    SELECT   overall_credit_limit
    FROM     hz_cust_profile_amts
    WHERE    cust_account_id                  = p_customer_id
    AND      currency_code                    = p_currency_code
    AND      decode( p_customer_site_use_id,
                     NULL, -10,
                     p_customer_site_use_id ) = NVL( site_use_id, -10 );
BEGIN
   l_overall_cr_limit := 0;
   OPEN c_overall;
   FETCH c_overall INTO l_overall_cr_limit;
   CLOSE c_overall;
   RETURN( l_overall_cr_limit);
END;

--
FUNCTION arxvamai_order_cr_limit ( p_customer_id NUMBER,
                                   p_currency_code VARCHAR2,
                                   p_customer_site_use_id NUMBER
                                  ) RETURN NUMBER is
l_order_cr_limit      NUMBER;
CURSOR c_order IS
       SELECT   trx_credit_limit
       FROM     hz_cust_profile_amts
       WHERE    cust_account_id = p_customer_id
       AND      currency_code = p_currency_code
       AND      DECODE( p_customer_site_use_id,
                        NULL, -10, p_customer_site_use_id ) =
                NVL( site_use_id, -10 );
BEGIN
   l_order_cr_limit := 0;
   OPEN c_order;
   FETCH c_order INTO l_order_cr_limit;
   CLOSE c_order;
   RETURN( l_order_cr_limit );
END;

--
FUNCTION get_primary_billto_site (
                        p_customer_id  IN hz_cust_accounts.cust_account_id%type
                                 )
RETURN NUMBER is

  v_billto_site_use_id hz_cust_site_uses.site_use_id%type;

  /* Bug 2625779 - declaring cursor */
       CURSOR   c_site IS
         SELECT su.site_use_id
         FROM  hz_cust_site_uses su,
               hz_cust_acct_sites acct_site
         WHERE su.site_use_code = 'BILL_TO'
         and   su.cust_acct_site_id = acct_site.cust_acct_site_id
         and   acct_site.cust_account_id = p_customer_id
         and   su.primary_flag = 'Y'
         ORDER BY su.status, su.site_use_id DESC;

BEGIN

   IF g_site_use_id_tab.EXISTS(p_customer_id) THEN
      v_billto_site_use_id  := g_site_use_id_tab( p_customer_id );
   ELSE
      BEGIN

         /* Bug 2625779 - replacement logic */
         OPEN   c_site;
         FETCH  c_site INTO v_billto_site_use_id;

         -- mimicking EXCEPTION - no primary, return NULL
         IF c_site%NOTFOUND THEN
            v_billto_site_use_id := NULL;
         END IF;

         CLOSE  c_site;
      END;

      g_site_use_id_tab(p_customer_id) := v_billto_site_use_id;

   END IF;

  return v_billto_site_use_id;

  EXCEPTION

    WHEN OTHERS THEN
      raise;

END;
--
--
END hzp_cust_pkg;


/
