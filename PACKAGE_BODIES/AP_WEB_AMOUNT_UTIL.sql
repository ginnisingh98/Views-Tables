--------------------------------------------------------
--  DDL for Package Body AP_WEB_AMOUNT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_AMOUNT_UTIL" AS
/* $Header: apwamtub.pls 120.11 2006/08/22 06:18:27 sbalaji noship $ */

  /* -------------------------------------------------------------------
  -- Function to get user_id for an employee.
  -- Parameters:
  --     IN  p_employee_id
  -- Return Value:
  --     user_id (from fnd_user) or NULL if no user exists for
  --     that employee_id
  --     Note: this will return the first user_id that has an AP SSWA
  --     responsibility, since that is the most likely useful user_id.
  --     In other words, this function is NOT a generic employee_id->user_id
  --     converter!
  -- ---------------------------------------------------------------- */

  function get_user_id(p_employee_id IN NUMBER) RETURN NUMBER IS
    l_user_id NUMBER;
  begin
    begin
     select fu.user_id
      into l_user_id
      from fnd_user fu
      where fu.employee_id = p_employee_id
      and sysdate >= fu.start_date
      and sysdate <= nvl(fu.end_date, sysdate)
      and rownum = 1;

    exception
      when others then
       l_user_id := NULL;
    end;

    return l_user_id;

  end get_user_id;


  /* -------------------------------------------------------------------
  -- Function to round an amount based on a currency code
  -- Parameters:
  --     IN  p_amount           amount to be rounded
  --     IN  p_curr_code        currency code of amount
  -- Return Value:
  --     rounded amount
  -- ---------------------------------------------------------------- */

  function round_amount(
                 p_amount IN NUMBER,
                 p_curr_code IN VARCHAR2) RETURN NUMBER IS
    l_value number;
  begin

--    arp_standard.debug('rounding amount ' || p_amount || ' for curr ' || p_curr_code);

    select round(p_amount, fc.precision)
    into l_value
    from fnd_currencies_vl fc
    where currency_code = p_curr_code;

    return l_value;
  end;


  /* -------------------------------------------------------------------
  -- Function to derive the OIE responsibility for a given user.
  -- Note: We have to make certain assumptions:
  --   1. a self-service responsibility for product AP is an OIE
  --      responsibility.  This isn't necessarily true, but it's
  --      quite unlikely that an internal approver has iInvoicing
  --      access (another type of AP Web Responsibility).  In the
  --      future this would have to be revisited as more and more
  --      products migrate to web UI.
  --   2. a user could have multiple OIE responsibilities (e.g.,
  --      "OIE with Projects" and "OIE without Projects".  We take
  --      the first one.  Since we're using the responsibility to
  --      derive the ORG and thus the functional currency code, it
  --      should in most cases make no difference.
  -- ---------------------------------------------------------------- */

  function get_oie_responsibility(p_user_id IN NUMBER,
                                  p_responsibility_id OUT NOCOPY NUMBER) RETURN VARCHAR2 IS

   l_menu_id NUMBER;
   l_responsibility_id NUMBER;
  begin

    begin
      select menu_id, responsibility_id
      into l_menu_id, l_responsibility_id
      from (
         select fr.menu_id, fr.responsibility_id
         from fnd_responsibility fr,
         fnd_user_resp_groups furg
         where fr.application_id = 200
         and fr.version = 'W'
         and furg.user_id = p_user_id
         and furg.responsibility_id = fr.responsibility_id
         order by furg.start_date desc
      )
      where rownum=1;

      p_responsibility_id := l_responsibility_id;
      return 'Y';

    exception
      when others then
       p_responsibility_id := NULL;
       return 'N';
    end;

  end;


  /* -------------------------------------------------------------------
  -- Function to get the ORG ID for a given user and responsibility.
  -- This is based on a profile
  -- ---------------------------------------------------------------- */


  function get_oie_org_id(p_userid IN NUMBER,
                          p_oie_resp_id IN NUMBER,
                          p_org_id      OUT NOCOPY NUMBER) RETURN VARCHAR2 IS

   l_defined BOOLEAN;
   l_value   VARCHAR2(240);
  begin

    begin

      fnd_profile.get_specific(NAME_Z => 'ORG_ID',
                             USER_ID_Z => p_userid,
                             RESPONSIBILITY_ID_Z => p_oie_resp_id,
			     APPLICATION_ID_Z => 200,  -- SQL*AP product id
                             VAL_Z => l_value,
                             DEFINED_Z => l_defined);

      exception
        when others then
          l_defined := FALSE;
    end;

    if (l_defined) then
      p_org_id := to_number(l_value);
      return 'Y';
    else
      p_org_id := NULL;
      return 'N';
    end if;

  end;


  /* -------------------------------------------------------------------
  -- Function to get the func currency, the set of books id, and the
  -- default exchange rate type for a given org from ap_system_parameters
  -- ---------------------------------------------------------------- */

  function get_ap_setup_data(p_org_id IN NUMBER,
                             p_func_curr_code OUT NOCOPY VARCHAR2,
                             p_sob_id OUT NOCOPY NUMBER,
                             p_default_exchange_rate_type OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
    l_curr_code VARCHAR2(30);
    l_sob_id NUMBER;
    l_default_exchange_rate_type VARCHAR2(30);
  begin

    begin
      select base_currency_code, asp.set_of_books_id, asp.default_exchange_rate_type
      into   l_curr_code, l_sob_id, l_default_exchange_rate_type
      from  ap_system_parameters_all asp
      where asp.org_id = p_org_id;

      p_func_curr_code := l_curr_code;
      p_sob_id := l_sob_id;
      p_default_exchange_rate_type := l_default_exchange_rate_type;
      return 'Y';

    exception
      when others then
        p_func_curr_code := NULL;
        p_sob_id := NULL;
        p_default_exchange_rate_type := NULL;
        return 'N';
    end;

  end;


  /* -------------------------------------------------------------------
  -- Bug 4020295
  -- Function to get the exchange rate for a given from Currency code,
  -- exchange rate type, pair of currencies and date.
  -- This is essentially just a cover on top of a GL API.  It looks
  -- back into the past for up to 60 days if the exchange rate isn't
  -- defined for the requested date.
  -- ---------------------------------------------------------------- */

  function get_exchange_rate(p_from_curr_code IN VARCHAR2,
                             p_to_curr_code   IN VARCHAR2,
                             p_date           IN DATE,
                             p_exchange_rate_type IN VARCHAR2,
                             p_exchange_rate  OUT NOCOPY NUMBER) RETURN VARCHAR2 IS
    l_rate NUMBER;
  begin

    l_rate := gl_currency_api.get_closest_rate_sql(
                    x_from_currency   => p_from_curr_code,
                    x_to_currency     => p_to_curr_code,
                    x_conversion_date => p_date,
                    x_conversion_type => p_exchange_rate_type,
                    x_max_roll_days   => 60);

    if (l_rate < 0) then
      p_exchange_rate := NULL;
      return 'N';
    else
      p_exchange_rate := l_rate;
      return 'Y';
    end if;

  end;


  /* -------------------------------------------------------------------
  -- Function to get the exchange rate for a given set of books,
  -- exchange rate type, pair of currencies and date.
  -- This is essentially just a cover on top of a GL API.  It looks
  -- back into the past for up to 60 days if the exchange rate isn't
  -- defined for the requested date.
  -- ---------------------------------------------------------------- */

  function get_exchange_rate(p_sob_id         IN NUMBER,
                             p_func_curr_code IN VARCHAR2,
                             p_currency_code  IN VARCHAR2,
                             p_date           IN DATE,
                             p_exchange_rate_type IN VARCHAR2,
                             p_exchange_rate  OUT NOCOPY NUMBER) RETURN VARCHAR2 IS
    l_rate NUMBER;
  begin

    l_rate := gl_currency_api.get_closest_rate_sql(
                    x_set_of_books_id => p_sob_id,
                    x_from_currency =>    p_currency_code,
                    x_conversion_date => p_date,
                    x_conversion_type => p_exchange_rate_type,
                    x_max_roll_days   => 60);

    if (l_rate < 0) then
      p_exchange_rate := NULL;
      return 'N';
    else
      p_exchange_rate := l_rate;
      return 'Y';
    end if;

  end;

 /* -------------------------------------------------------------------
  -- Public procedure to get a meaningful exchange rate for a given
  -- user, date, and currency code.
  -- ---------------------------------------------------------------- */

  procedure get_meaningful_rate(
               p_userid        IN NUMBER,
               p_date          IN DATE,
               p_currency_code IN VARCHAR2,
               p_success_flag       OUT NOCOPY VARCHAR2,
               p_conv_date          OUT NOCOPY DATE,
               p_conv_rate          OUT NOCOPY NUMBER,
               p_conv_currency_code IN OUT NOCOPY VARCHAR2) IS

    l_success_flag VARCHAR2(1);


    l_oie_resp_id NUMBER;
    l_org_id      NUMBER;
    l_func_curr_code VARCHAR2(30);
    l_sob_id      NUMBER;
    l_exchange_rate_type VARCHAR2(30);
    l_exchange_rate NUMBER;
    l_pref_curr_code VARCHAR2(30);

  begin

    -- Bug 4020295
    -- Get the preferred currency code from profile for this user if set
    --

--    l_pref_curr_code := get_preferred_currency_code( p_user_id => p_userid );
    l_pref_curr_code := p_conv_currency_code;

    if ( l_pref_curr_code is not null ) then

      --
      -- Get the other information from the employee's HR information
      --

      begin

	    select asp.default_exchange_rate_type
	    into  l_exchange_rate_type
	    from per_employees_x pex,
		 ap_system_parameters_all asp,
		 fnd_user fu
	    where
		pex.set_of_books_id = asp.set_of_books_id  and
		fu.employee_id = pex.employee_id and
		fu.user_id = p_userid and
		rownum = 1;
      exception
      when others then
	p_success_flag := 'N';
	return;
      end;

      --
      -- Get the conversion rate for this preferred currency code
      --

    l_success_flag := get_exchange_rate(
				p_from_curr_code     => p_currency_code,
				p_to_curr_code       => l_pref_curr_code,
                                p_date               => p_date,
                                p_exchange_rate_type => l_exchange_rate_type,
                                p_exchange_rate      => l_exchange_rate);

    if (l_success_flag = 'N') then

      p_success_flag := 'N';
      return;
    else
      p_conv_rate := l_exchange_rate;
      p_conv_currency_code := l_pref_curr_code;
      p_success_flag := 'Y';
    end if;

  else


--    arp_standard.enable_file_debug('/sqlcom/out/aroa55n','osteinme_oie');

--    arp_standard.debug('get_meaningful_value()+');

    l_success_flag := get_oie_responsibility(p_userid, l_oie_resp_id);

--    arp_standard.debug('resp_id = ' || to_char(l_oie_resp_id));
--    arp_standard.debug('success = ' || l_success_flag);

    if (l_success_flag = 'N') then
      p_success_flag := 'N';
      return;
    end if;

    l_success_flag := get_oie_org_id(p_userid, l_oie_resp_id, l_org_id);

--    arp_standard.debug('org_id = ' || to_char(l_org_id));
--    arp_standard.debug('success = ' || l_success_flag);


    if (l_success_flag = 'N') then
      p_success_flag := 'N';
      return;
    end if;

    l_success_flag := get_ap_setup_data(l_org_id, l_func_curr_code, l_sob_id, l_exchange_rate_type);

--    arp_standard.debug('sob_id = ' || to_char(l_sob_id));
--    arp_standard.debug('func curr = ' || l_func_curr_code);
--    arp_standard.debug('def exch type = ' || l_exchange_rate_type);

--    arp_standard.debug('success = ' || l_success_flag);


    if (l_success_flag = 'N') then
      p_success_flag := 'N';
      return;
    end if;


    -- no point in doing conversion if reimbursement amount is already
    -- in desired currency.

    if (l_func_curr_code = p_currency_code) then
      p_success_flag := 'N';
      return;
    end if;


    l_success_flag := get_exchange_rate(l_sob_id,
				        l_func_curr_code,
                                        p_currency_code,
                                        p_date,
                                        l_exchange_rate_type,
                                        l_exchange_rate);


--    arp_standard.debug('rate = ' || to_char(l_exchange_rate));
--    arp_standard.debug('success = ' || l_success_flag);

    if (l_success_flag = 'N') then
      p_success_flag := 'N';
      return;
    else
      p_conv_rate := l_exchange_rate;
      p_conv_currency_code := l_func_curr_code;
      p_success_flag := 'Y';
    end if;

  end if; -- end of if ( l_pref_curr_code is not null )

  end get_meaningful_rate;


 /* -------------------------------------------------------------------
  -- Public procedure to get a meaningful converted amount for a given
  -- user, date, and currency code.
  -- ---------------------------------------------------------------- */

 procedure get_meaningful_amount(
               p_userid        IN NUMBER,
               p_amount        IN NUMBER,
               p_date          IN DATE,
               p_currency_code IN VARCHAR2,
               p_success_flag       OUT NOCOPY VARCHAR2,    -- Y/N
               p_conv_amount        OUT NOCOPY NUMBER,
               p_conv_currency_code IN OUT NOCOPY VARCHAR2) IS

   l_conv_rate NUMBER;
   l_conv_date DATE;
   l_success_flag VARCHAR2(1);

 begin

   get_meaningful_rate(
	p_userid,
	p_date,
        p_currency_code,
        l_success_flag,
        l_conv_date,
        l_conv_rate,
        p_conv_currency_code);

   if (l_success_flag = 'Y') then
     p_conv_amount := round_amount(p_amount * l_conv_rate, p_conv_currency_code);
     p_success_flag := 'Y';
   else
     p_success_flag := 'N';
     p_conv_amount := NULL;
   end if;

 end;


  /* -------------------------------------------------------------------
  -- Public function to get a string returning a translated string of
  -- format "Estimated Reimbursement Amount in <curr>: <amount>
  -- where <amount> is a converted amount in currency <curr>.
  -- ---------------------------------------------------------------- */

 function get_meaningful_amount_msg(
              p_userid        IN NUMBER,
              p_amount        IN NUMBER,
              p_date          IN DATE,
              p_currency_code IN VARCHAR2,
              p_out_currency_code IN VARCHAR2) RETURN VARCHAR2 IS

   l_msg VARCHAR2(240);
   l_success_flag VARCHAR2(1);
   l_conv_amount NUMBER;
   l_conv_amount_formatted VARCHAR2(30);
   l_conv_curr_code VARCHAR2(30);

  begin
    l_conv_curr_code := p_out_currency_code;

    begin
      get_meaningful_amount(
              p_userid,
              p_amount,
              p_date,
              p_currency_code,
              l_success_flag,
              l_conv_amount,
              l_conv_curr_code);

      if l_success_flag = 'N' then
        return null;
      else
        l_conv_amount_formatted := to_char(l_conv_amount,
                                 fnd_currency.get_format_mask(l_conv_curr_code, 20));

        fnd_message.set_name('SQLAP','OIE_MEANINGFUL_AMOUNT_PROMPT');
        fnd_message.set_token('CURRENCY', l_conv_curr_code);
        fnd_message.set_token('AMOUNT', l_conv_amount_formatted);
        l_msg := fnd_message.get;
        return l_msg;
      end if;

      exception
        when others then
          return NULL;
      end;

 end get_meaningful_amount_msg;

  /* -------------------------------------------------------------------
  -- Public function to get a string returning a translated string of
  -- format "Estimated Reimbursement Amount in <curr>: <amount>
  -- where <amount> is a converted amount in currency <curr>.
  -- ---------------------------------------------------------------- */

 function get_meaningful_amount_msg_emp(
              p_employee_id   IN NUMBER,
              p_amount        IN NUMBER,
              p_date          IN DATE,
              p_currency_code IN VARCHAR2,
              p_out_currency_code IN VARCHAR2) RETURN VARCHAR2 IS
   l_user_id NUMBER;
 begin

   -- Bug 5436992 - Do not show any message if the currencies are the same
   if ( (p_out_currency_code IS NOT NULL) AND ( p_out_currency_code = p_currency_code) )
   THEN
     return null;
   END IF;

   l_user_id := get_user_id(p_employee_id);

   if l_user_id is not null then
     return get_meaningful_amount_msg(
             l_user_id,
             p_amount,
             p_date,
             p_currency_code,
	     p_out_currency_code);
   else
     return null;
   end if;

 end get_meaningful_amount_msg_emp;


 procedure get_meaningful_amount_emp(
               p_employee_id        IN NUMBER,
               p_amount             IN NUMBER,
               p_date               IN DATE,
               p_currency_code      IN VARCHAR2,
               p_success_flag       OUT NOCOPY VARCHAR2,
               p_conv_amount        OUT NOCOPY NUMBER,
               p_conv_currency_code OUT NOCOPY VARCHAR2) IS
   l_user_id NUMBER;
 begin

   l_user_id := get_user_id(p_employee_id);

   if l_user_id is not null then
      get_meaningful_amount(
             l_user_id,
             p_amount,
             p_date,
             p_currency_code,
             p_success_flag,
             p_conv_amount,
             p_conv_currency_code);
   else
     p_success_flag := 'N';
   end if;

 end get_meaningful_amount_emp;

end ap_web_amount_util;

/
