--------------------------------------------------------
--  DDL for Package Body PON_PRINTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_PRINTING_PKG" as
/* $Header: PONPRNB.pls 120.72.12010000.32 2014/11/03 09:57:29 spapana ship $ */

-------------------------------------------------------------------------------

--------------------------  HELPER FUNCTIONS ----------------------------------

-------------------------------------------------------------------------------

FUNCTION GET_SUFFIX_FOR_MESSAGES(p_auction_header_id in VARCHAR2) return VARCHAR2;

PROCEDURE SET_AUCTION_MASKS(p_currency_code IN VARCHAR2,
                            p_price_precision IN NUMBER,
                            p_price_mask OUT NOCOPY VARCHAR2,
                            p_amount_mask OUT NOCOPY VARCHAR2);

FUNCTION GET_MASK(p_precision in NUMBER) return VARCHAR2;

-------------------------------------------------------------------------------

--------------------------  END HELPER FUNCTIONS ------------------------------

-------------------------------------------------------------------------------


  ----------------------------------------------------------------
  -- Returns the suffix for document specific messages for a    --
  -- particular negotiation id                                  --
  ----------------------------------------------------------------
  FUNCTION GET_SUFFIX_FOR_MESSAGES(p_auction_header_id in VARCHAR2) return VARCHAR2 is
    l_message_suffix       varchar2(2);
    BEGIN

      /* SLM UI Enhancement : If slm document return _Z  */
      IF PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(p_auction_header_id) = 'Y' THEN

          l_message_suffix := PON_SLM_UTIL_PKG.SLM_MESSAGE_SUFFIX_UNDERSCORE;
      ELSE
          select d.MESSAGE_SUFFIX into l_message_suffix
          from pon_auc_doctypes d , pon_auction_headers_all pah
          where pah.auction_header_id = p_auction_header_id
          and pah.DOCTYPE_ID = d.DOCTYPE_ID;

          l_message_suffix := '_'||l_message_suffix;

      END IF;

    return l_message_suffix;

  END GET_SUFFIX_FOR_MESSAGES;

  ----------------------------------------------------------------
  -- Sets the price mask and amount mask for a particular       --
  -- negotiation                                                --
  ----------------------------------------------------------------
  PROCEDURE SET_AUCTION_MASKS(p_currency_code IN VARCHAR2,
                              p_price_precision IN NUMBER,
                              p_price_mask OUT NOCOPY VARCHAR2,
                              p_amount_mask OUT NOCOPY VARCHAR2) IS
    l_currency_precision     NUMBER;
    l_ext_precision          NUMBER;
    l_min_acct_unit          NUMBER;
  BEGIN

    p_price_mask := GET_MASK(p_price_precision);

    fnd_currency.get_info(p_currency_code,l_currency_precision,l_ext_precision,l_min_acct_unit);
    p_amount_mask := GET_MASK(l_currency_precision);

  END SET_AUCTION_MASKS;

  ----------------------------------------------------------------
  -- Adds the suffix to the message to generate the  document   --
  -- specific messages name                                     --
  ----------------------------------------------------------------
  FUNCTION GET_DOCUMENT_MESSAGE_NAME(p_message_name in VARCHAR2,
																	p_message_suffix in VARCHAR2)
																	return VARCHAR2 is
  begin

    return p_message_name||'_'||p_message_suffix;
  end;


  ----------------------------------------------------------------
  -- Returns the corresponding value of the mesage name after   --
  -- substituting it with the token                             --
  ----------------------------------------------------------------
  FUNCTION GET_MESSAGES(p_message_name in VARCHAR2,
                        p_token_name in VARCHAR2,
                        p_token_value in VARCHAR2) return VARCHAR2 is

  l_message       fnd_new_messages.message_text%TYPE;

  BEGIN

		fnd_message.set_name('PON',p_message_name);
    fnd_message.set_token(p_token_name,p_token_value);
    l_message := fnd_message.get;

    return l_message;

  END;

  ----------------------------------------------------------------
  -- Returns the corresponding value of the mesage name after   --
  -- substituting it with the the two token                   --
  ----------------------------------------------------------------
  FUNCTION GET_MESSAGES(p_message_name in VARCHAR2,
                        p_token_name1 in VARCHAR2,
                        p_token_value1 in VARCHAR2,
                        p_token_name2 in VARCHAR2,
                        p_token_value2 in VARCHAR2) return VARCHAR2 is

  l_message       fnd_new_messages.message_text%TYPE;

  BEGIN

		fnd_message.set_name('PON',p_message_name);
    fnd_message.set_token(p_token_name1,p_token_value1);
    fnd_message.set_token(p_token_name2,p_token_value2);
    l_message := fnd_message.get;

    return l_message;

  END;

  ----------------------------------------------------------------
  -- Returns the corresponding value of the mesage name after   --
  -- substituting it with the the three token                   --
  ----------------------------------------------------------------
  FUNCTION GET_MESSAGES(p_message_name in VARCHAR2,
                        p_token_name1 in VARCHAR2,
                        p_token_value1 in VARCHAR2,
                        p_token_name2 in VARCHAR2,
                        p_token_value2 in VARCHAR2,
                        p_token_name3 in VARCHAR2,
                        p_token_value3 in VARCHAR2) return VARCHAR2 is

  l_message       fnd_new_messages.message_text%TYPE;

  BEGIN

		fnd_message.set_name('PON',p_message_name);
    fnd_message.set_token(p_token_name1,p_token_value1);
    fnd_message.set_token(p_token_name2,p_token_value2);
    fnd_message.set_token(p_token_name3,p_token_value3);
    l_message := fnd_message.get;

    return l_message;

  END;

  ----------------------------------------------------------------
  -- Returns the corresponding value of the mesage name after   --
  -- substituting it with the token. The message name is formed --
  -- by joining the message name and message suffix parameters  --
  ----------------------------------------------------------------
  FUNCTION GET_MESSAGES(p_message_name in VARCHAR2,
                        p_message_suffix in VARCHAR2,
                        p_token_name in VARCHAR2,
                        p_token_value in VARCHAR2) return VARCHAR2 is

  l_message       fnd_new_messages.message_text%TYPE;

  BEGIN

		l_message := get_messages(p_message_name||p_message_suffix,
															p_token_name,
															p_token_value);

    return l_message;

  END;

  ----------------------------------------------------------------
  -- Calculate Response Total for supplier view.                --
  ----------------------------------------------------------------
  FUNCTION get_supplier_bid_total
             (p_auction_header_id    IN NUMBER,
              p_bid_number           IN NUMBER,
              p_buyer_bid_total           IN NUMBER,
              p_outcome              IN pon_auction_headers_all.contract_type%TYPE,
              p_doctype_group_name   IN VARCHAR2,
              p_bid_status           IN VARCHAR2
              ) RETURN NUMBER

  IS

  v_bid_total NUMBER;
  v_has_est_qty_on_all_bid_lines   VARCHAR2(1);

  BEGIN

    IF p_buyer_bid_total is null OR p_buyer_bid_total = '' OR p_buyer_bid_total < 0 THEN
      IF (p_bid_status = 'DRAFT') THEN
        IF ((p_doctype_group_name = 'REQUEST_FOR_INFORMATION') OR (p_outcome = 'BLANKET' OR p_outcome = 'CONTRACT')) THEN
          v_has_est_qty_on_all_bid_lines := PON_TRANSFORM_BIDDING_PKG.check_est_qty_on_all_bid_lines(p_auction_header_id, p_bid_number);
          IF (v_has_est_qty_on_all_bid_lines = 'N') THEN
            RETURN null;
          END IF;
        END IF;
      ELSE
        return null;
      END IF;
    END IF;

    SELECT sum(decode(paip.order_type_lookup_code, 'FIXED PRICE', 1,
                      decode(p_outcome, 'STANDARD', nvl(pbip.quantity, 0), paip.quantity)) *
               nvl(pbip.bid_currency_price,0)) bid_total
    INTO   v_bid_total
    FROM   pon_bid_item_prices pbip,
           pon_auction_item_prices_all paip
    WHERE  pbip.auction_header_id = p_auction_header_id AND
           pbip.bid_number = p_bid_number AND
           nvl(pbip.has_bid_flag, 'N') = 'Y' AND
           pbip.auction_header_id = paip.auction_header_id AND
           pbip.line_number = paip.line_number AND
           paip.group_type in ('LOT', 'LINE', 'GROUP_LINE');

    RETURN v_bid_total;

  END get_supplier_bid_total;

  ----------------------------------------------------------------
  -- Formats the number based on the precision pased. If the    --
  -- precision is passed as any then no formatting is done.     --
  ----------------------------------------------------------------
	FUNCTION GET_MASK(p_precision in NUMBER) return VARCHAR2 is

  l_mask 					varchar2(80);

  BEGIN
    if (p_precision = 10000) then
    --{
			l_mask := 'FM999G999G999G999G999G999G999G999G999G999G999G999G990D0999999999'; -- consider a big mask to accomodate big numbers
			return l_mask;
    --}
    elsif (p_precision = 0) then
    --{ For 0 precision we need to hide the decimal seperator
       l_mask := 'FM999G999G999G999G999G999G999G999G999G999G999G999G999G999G999G999'; -- consider a big mask to accomodate big numbers
       return l_mask;
	  --}
	  else
    --{
       l_mask := 'FM999G999G999G999G999G999G999G999G999G999G999G999G990D'; -- consider a big mask to accomodate big numbers
       l_mask := rpad(l_mask, (length(l_mask) + p_precision), '0');
       return l_mask;
    --}
    end if;
  END;

  ----------------------------------------------------------------
  -- Formats the number based passed. If the number does not    --
  -- decimal part then the decimal separator will not be        --
  -- displayed. If the number is less that 0 then 0 will        --
  -- be displayed before the decimal separator                  --
  ----------------------------------------------------------------
	FUNCTION FORMAT_NUMBER(p_number in NUMBER) return VARCHAR2 is

  l_mask 					varchar2(80);

  BEGIN
    if (p_number is null) then
    --{
			return null;
    --}
    elsif ((ceil(p_number) - p_number) >0) then
    --{ if number does not have decimal seperator then the decimal will not be displayed
       l_mask := 'FM999G999G999G999G999G999G999G999G999G999G990D9999999999999999'; -- consider a big mask to accomodate big numbers
	  --}
	  else
    --{
       l_mask := 'FM999G999G999G999G999G999G999G999G999G999G999G999G999G999G999G999'; -- consider a big mask to accomodate big numbers
    --}
    end if;

    return to_char(p_number,l_mask);
  END;

  ----------------------------------------------------------------
  -- Formats the number which is a varchar.                 --
  ----------------------------------------------------------------
  FUNCTION FORMAT_NUMBER_STRING(p_value in VARCHAR2) return VARCHAR2 is

  BEGIN
    if (p_value is null) then
	return null;

    elsif (instr(p_value, '.')>0) then
      return pon_printing_pkg.format_number(to_number(p_value,'9999999999999999999999999999999999999999.9999999999999999'));
    else
      return pon_printing_pkg.format_number(to_number(p_value,'9999999999999999999999999999999999999999'));
    end if;

  EXCEPTION
    when others then
        return p_value;

  END;
  -----------------------------------------------------------------
  -- For Bug 4373655
  -- Returns the carrier name based on the carrier code and      --
  -- inventory org id corresponding to the org_id passed a       --
  -- parameter                                                   --
  -----------------------------------------------------------------
  FUNCTION get_carrier_description(p_org_id in NUMBER,p_carrier_code in VARCHAR2)
  return varchar2
  is

  l_carrier     org_freight.description%TYPE;

  begin

     select
     orgf.description carrier
     into
     l_carrier
     from
     financials_system_params_all fsp,
     org_freight orgf
     where
     nvl(fsp.org_id, -9999)= nvl(p_org_id, -9999)
     and orgf.organization_id = fsp.inventory_organization_id
     and orgf.freight_code = p_carrier_code
     and orgf.language = userenv('lang');

     return l_carrier;

  exception
     when NO_DATA_FOUND then
     l_carrier := null;
     return l_carrier;

  END get_carrier_description;


  ----------------------------------------------------------------
  -- Formats the price passed based on the format passed.       --
  -- If the price does have a decimal part then the decimal     --
  -- separator will not be displayed. If the price is less      --
  -- that 0 then 0 will be displayed before the decimal         --
  -- separator                                                  --
  ----------------------------------------------------------------
  FUNCTION FORMAT_PRICE(p_price in NUMBER,
                        p_format_mask in VARCHAR2,
                        p_precision IN NUMBER)
                        return VARCHAR2 is
  l_mask 					varchar2(80);

  BEGIN
    if (p_price is null) then
    --{
			return null;
    --}
    elsif ((ceil(p_price) - p_price) =0 and p_precision = 10000) then
    --{ if price does not have decimal seperator and precision is 'Any' then
    --  the decimal will not be displayed
       l_mask := 'FM999G999G999G999G999G999G999G999G999G999G999G999G999G999G999G999'; -- consider a big mask to accomodate big numbers
	  --}
	  else
    --{
       l_mask := p_format_mask; -- consider the original mask
    --}
    end if;

    return to_char(p_price,l_mask);

  END;

  ----------------------------------------------------------------
  -- Returns Y if XDO is installed                              --
  -- NOTES         : valid installation status:                 --
  --              I - Product is installed                      --
  --              S - Product is partially installed            --
  --              N - Product is not installed                  --
  --              L - Product is a local (custom) application   --
  ----------------------------------------------------------------

  FUNCTION is_xdo_installed RETURN VARCHAR2 IS
    x_progress     VARCHAR2(3) := NULL;
    x_app_id       NUMBER;
    x_install      BOOLEAN;
    x_status       VARCHAR2(1);
    x_org          VARCHAR2(1);
    x_temp_product_name varchar2(10);
    x_is_xdo_installed varchar2(1);
  begin
    --Retreive product id from fnd_application based on product name
    x_progress := 10;

    select application_id
    into   x_app_id
    from   fnd_application
    where application_short_name = 'XDO' ;

    --get product installation status
    x_progress := 20;
    x_install := fnd_installation.get(x_app_id,x_app_id,x_status,x_org);

    if x_status = 'I' then
         x_is_xdo_installed := 'Y';
    else
         x_is_xdo_installed := 'N';
    end if;

    RETURN(x_is_xdo_installed);

    EXCEPTION
      WHEN NO_DATA_FOUND then
         RETURN('N');
  end is_xdo_installed;

  ----------------------------------------------------------------
	-- Formats the response value of the attributes         --
  ----------------------------------------------------------------

  FUNCTION PRINT_ATTRIBUTE_RESPONSE_VALUE(
                                        p_value in VARCHAR2,
                                        p_datatype in VARCHAR2,
                                        p_client_time_zone in VARCHAR2,
                                        p_server_time_zone in VARCHAR2,
                                        p_date_format in VARCHAR2,
                                        p_attribute_sequence_number in NUMBER
                                        )
                                        RETURN VARCHAR2 is
  l_datetime_flag VARCHAR2(1);
  begin

    if (p_datatype='DAT') then
       if (p_attribute_sequence_number = -10) then
          l_datetime_flag := 'Y'; -- need-by date is datetime
       else
          l_datetime_flag := 'N';
       end if;
      return pon_resp_scores_pkg.display_db_date_string(p_value, p_client_time_zone, p_server_time_zone, l_datetime_flag, p_date_format);

    elsif (p_datatype='NUM') then

      return format_number_string(p_value);

    else

      return p_value;

    end if;
 END PRINT_ATTRIBUTE_RESPONSE_VALUE;
  ----------------------------------------------------------------
	-- Formats the target value of the attributes           --
  ----------------------------------------------------------------
  FUNCTION PRINT_ATTRIBUTE_TARGET_VALUE(p_show_target_value  in VARCHAR2,
                                        p_value in VARCHAR2,
                                        p_datatype in VARCHAR2,
                                        p_sequence_number in VARCHAR2,
                                        p_client_time_zone in VARCHAR2,
                                        p_server_time_zone in VARCHAR2,
                                        p_date_format in VARCHAR2,
                                        p_user_view_type IN VARCHAR2)
                                        RETURN VARCHAR2 is
  begin

    if ((p_show_target_value = 'N' and p_user_view_type <> 'BUYER') or p_value is null) then

      return NULL;

    elsif (p_datatype='DAT' and p_sequence_number <> -10) then

      return pon_resp_scores_pkg.display_db_date_string(p_value, p_client_time_zone, p_server_time_zone, 'N', p_date_format);

    elsif (p_datatype='NUM') then

        return format_number_string(p_value);

    else

      return p_value;

    end if;

  END PRINT_ATTRIBUTE_TARGET_VALUE;


  -----------------------------------------------------------------
  -- Returns the email of the user. Creating this method instead --
  -- of an outer join as in hz contact points table same email   --
  -- record with active status of type MAILHTML existed. This was--
  -- leading 2 records for all the queries.                      --
  -----------------------------------------------------------------
  FUNCTION GET_USER_EMAIL(p_user_party_id in NUMBER)
                          return VARCHAR2 is

  x_usermail 		per_all_people_f.email_address%type;

  begin


    Select
    papf.email_address into
      x_usermail
    from
    per_all_people_f papf, fnd_user
    where
    fnd_user.person_party_id = p_user_party_id
    and fnd_user.employee_id = papf.person_id
    and papf.effective_end_date = (SELECT MAX(per1.effective_end_date)
			           FROM per_all_people_f per1
				   WHERE papf.person_id = per1.person_id)
    and rownum = 1;

    return x_usermail;

    EXCEPTION
      WHEN NO_DATA_FOUND then
         RETURN('');

  end;


  ----------------------------------------------------------------
  -- Retunrs the range / value of a for an attribute along with --
  -- the score. The score will be displayed only if             --
  -- p_show_bidder_scores is 'Y'                                --
  ----------------------------------------------------------------
  FUNCTION GET_ACCEPTABLE_VALUE(p_show_bidder_scores  in VARCHAR2,
                                p_attribute_sequence_number NUMBER,
                                p_score_data_type  in VARCHAR2,
                                p_from_range  in VARCHAR2,
                                p_to_range  in VARCHAR2,
                                p_value  in VARCHAR2,
                                p_score  in VARCHAR2,
                                p_client_time_zone in VARCHAR2,
                                p_server_time_zone in VARCHAR2,
                                p_date_format in VARCHAR2,
                                p_user_view_score IN VARCHAR2)
                                RETURN VARCHAR2 is


    x_acc_values 		varchar2(2000);

    -- set up all the translatable msgs to
    -- be inserted in the returned string

    msgAtMost 	VARCHAR2(2000); -- PON_AUC_AT_MOST
    msgAtLeast 	VARCHAR2(2000); -- PON_AUC_AT_LEAST
    msgOnOrBefore 	VARCHAR2(2000); -- PON_AUC_ON_OR_BEFORE
    msgOnOrAfter 	VARCHAR2(2000); -- PON_AUC_ON_OR_AFTER
    msgTo 		VARCHAR2(2000); -- PON_AUC_TO
    msgFrom		VARCHAR2(2000); -- PON_AUCTS_FROM
    msgGreaterThan VARCHAR2(200); -- PON_AUC_GREATER_THAN
    msgUpTo        VARCHAR2(200); -- PON_AUC_UP_TO

    msgSeparator 	VARCHAR2(2) := ' ';

    dateFmtMask	VARCHAR2(24);
    dateFmtSave	VARCHAR2(24);
    l_datetime_flag VARCHAR2(1);

  begin

    --need to get this based on user language
    --NEED TO SEE IF PON_PRINTING_PKG.UNSET_SESSION_LAGUAGE is to be called
    PON_AUCTION_PKG.SET_SESSION_LANGUAGE(null, USERENV('LANG'));

    msgAtMost   := PON_AUCTION_PKG.getMessage('PON_AUC_AT_MOST');
    msgAtLeast   := PON_AUCTION_PKG.getMessage('PON_AUC_AT_LEAST');
    msgOnOrBefore   := PON_AUCTION_PKG.getMessage('PON_AUC_ON_OR_BEFORE');
    msgOnOrAfter   := PON_AUCTION_PKG.getMessage('PON_AUC_ON_OR_AFTER');
    msgTo     := PON_AUCTION_PKG.getMessage('PON_AUC_TO');
    msgFrom    := PON_AUCTION_PKG.getMessage('PON_AUCTS_FROM');
    msgGreaterThan := PON_AUCTION_PKG.getMessage('PON_AUC_GREATER_THAN');
    msgUpTo := PON_AUCTION_PKG.getMessage('PON_AUC_UP_TO');

    dateFmtMask   := p_date_format;
    dateFmtSave  := 'DD-MM-RRRR';


    if (p_score_data_type = 'TXT') then

    -- if the attribute datatype is text, then
    -- simply print the acceptable values
    -- no need to add to, from etc.

    --{

         x_acc_values := p_value || msgSeparator;

    --}

    elsif(p_score_data_type = 'NUM' OR p_score_data_type = 'INT')  then

    --{

      if(p_from_range = '' OR p_from_range is null ) then

        x_acc_values := msgUpTo || msgSeparator || format_number_string(p_to_range) || msgSeparator;

      elsif (p_to_range = '' OR p_to_range is null) then

        x_acc_values := msgGreaterThan || msgSeparator || format_number_string(p_from_range)  || msgSeparator;

      else

        x_acc_values := format_number_string(p_from_range) || msgSeparator || msgTo || msgSeparator || format_number_string(p_to_range) || msgSeparator;

      end if;

    --}

    elsif(p_score_data_type = 'DAT') then

    --{

       if (p_attribute_sequence_number = -10) then
          l_datetime_flag := 'Y'; -- need-by date is datetime
       else
          l_datetime_flag := 'N';
       end if;

       if(p_from_range = '' OR p_from_range is null) then

         x_acc_values := x_acc_values  || msgOnOrBefore || msgSeparator || pon_resp_scores_pkg.display_db_date_string(p_to_range, p_client_time_zone, p_server_time_zone, l_datetime_flag, p_date_format) || msgSeparator;

       elsif (p_to_range = '' OR p_to_range is null) then

         x_acc_values := x_acc_values  || msgOnOrAfter || msgSeparator || pon_resp_scores_pkg.display_db_date_string(p_from_range, p_client_time_zone, p_server_time_zone, l_datetime_flag, p_date_format)  || msgSeparator;

       else

         x_acc_values := x_acc_values  || msgFrom || msgSeparator || pon_resp_scores_pkg.display_db_date_string(p_from_range, p_client_time_zone, p_server_time_zone, l_datetime_flag, p_date_format)  || msgSeparator || msgTo
         || msgSeparator || pon_resp_scores_pkg.display_db_date_string(p_to_range, p_client_time_zone, p_server_time_zone, l_datetime_flag, p_date_format) || msgSeparator;

       end if;

    --}
    end if;


    if((p_user_view_score = 'Y' OR p_show_bidder_scores = 'Y' OR p_show_bidder_scores = 'SCORE_WEIGHT') and p_score is not null) then
    --{

     x_acc_values := x_acc_values ||  '(' || p_score || ')';

    end if;

    --}

    --dbms_output.put_line('Returning AccValues = ' || x_acc_values || ' Scores = ' || p_score||' p_show_bidder_scores='||p_show_bidder_scores ||' p_score ='||p_score);

     return x_acc_values;


  END GET_ACCEPTABLE_VALUE;


  ----------------------------------------------------------------
  -- Returns the rate to be displayed                           --
  ----------------------------------------------------------------
  FUNCTION GET_DISPLAY_RATE(p_rate_dsp in NUMBER,
		                        p_rate_type in VARCHAR2,
                            p_rate_date in DATE,
                            p_auction_currency_code in VARCHAR2,
                            p_bid_currency_code in VARCHAR2) return VARCHAR2 is

  l_display_rate NUMBER;
  l_printing_text VARCHAR2(200);

  BEGIN

   begin

  	if (p_rate_type= 'User') then

  	  l_display_rate := p_rate_dsp;

  	else

      l_display_rate := (1/PON_AUCTION_PKG.getClosestRate(p_auction_currency_code,p_bid_currency_code,p_rate_date,p_rate_type,0));

    end if;

     l_printing_text := pon_printing_pkg.get_messages('PON_AUC_DISPLAY_RATE','AUCTION_CURRENCY',p_auction_currency_code,'RATE',pon_printing_pkg.format_number(l_display_rate),'BID_CURRENCY',p_bid_currency_code);

    exception

      when others then

        select message_text
        into l_printing_text
        from fnd_new_messages
        where message_name = 'PON_AUC_CONTACT_BUYER'
        and language_code = USERENV('LANG')
        and application_id = 396;

      end;

  return l_printing_text;

  END GET_DISPLAY_RATE;

  ----------------------------------------------------------------------
  -- Returns whether the buyer has price visibility in scoring team   --
  ----------------------------------------------------------------------
  FUNCTION is_price_visible( p_auction_header_id          IN NUMBER,
                             p_user_id             IN NUMBER
                           ) RETURN VARCHAR2 IS
    l_has_scoring_teams_flag     VARCHAR2(1) := NULL;
    l_is_price_visible     VARCHAR2(1) := 'Y';
    l_is_scorer     VARCHAR2(1) := 'N';

  begin
    --The logic comes from: java/response/inquiry/webui/ViewBidCO.java
    --java/schema/server/ScoringTeamPriceVisibilityVVO, java/schema/server/STMemberAccessVVO

    select has_scoring_teams_flag
    into l_has_scoring_teams_flag
    from pon_auction_headers_all
    where auction_header_id = p_auction_header_id;

    if l_has_scoring_teams_flag = 'Y' then
      BEGIN
      SELECT 'Y'
      into l_is_scorer
      FROM   pon_neg_team_members
      WHERE menu_name = 'PON_SOURCING_SCORENEG'
      AND auction_header_id = p_auction_header_id
      AND user_id = p_user_id;
      EXCEPTION
        WHEN NO_DATA_FOUND then
         l_is_scorer := 'N';
      END;
      if (l_is_scorer = 'Y') then
      BEGIN
      SELECT pst.price_visible_flag
      INTO l_is_price_visible
      FROM    pon_scoring_team_members pstm,
              pon_scoring_teams pst
      WHERE   pstm.auction_header_id = p_auction_header_id
      	AND     pstm.user_id = p_user_id
 	AND     pst.auction_header_id = pstm.auction_header_id
 	AND     pstm.team_id = pst.team_id;
      EXCEPTION
          WHEN NO_DATA_FOUND then
            l_is_price_visible := 'N';
      END;
      end if;
    end if;
    RETURN  (l_is_price_visible);
  end is_price_visible;

--  Overloaded version of the following procedure without trading_partner_contact_id
--  Kept here for backward compatibility - can be removed once all the dependent
--  changes are done.

  FUNCTION generate_auction_xml(p_auction_header_id          IN NUMBER,
                                p_client_time_zone           IN VARCHAR2,
                                p_server_time_zone           IN VARCHAR2,
                                p_date_format                IN VARCHAR2,
                                p_trading_partner_id         IN NUMBER,
                                p_trading_partner_name       IN VARCHAR2,
                                p_vendor_site_id             IN NUMBER,
                                p_user_view_type             IN VARCHAR2,
                                p_printing_warning_flag      IN VARCHAR2  DEFAULT 'N',
                                p_neg_printed_with_contracts IN VARCHAR2  DEFAULT 'N',
                                p_requested_supplier_id      IN NUMBER,
                                p_requested_supplier_name    IN VARCHAR2)
  RETURN CLOB IS

  result CLOB;

  BEGIN

    result  :=       generate_auction_xml(p_auction_header_id          =>  p_auction_header_id,
                                p_client_time_zone           =>  p_client_time_zone,
                                p_server_time_zone           =>  p_server_time_zone,
                                p_date_format                =>  p_date_format,
                                p_trading_partner_id         =>  p_trading_partner_id,
                                p_trading_partner_name       =>  p_trading_partner_name,
                                p_vendor_site_id             =>  p_vendor_site_id,
                                p_user_view_type             =>  p_user_view_type,
                                p_printing_warning_flag      =>  p_printing_warning_flag,
                                p_neg_printed_with_contracts =>  p_neg_printed_with_contracts,
                                p_requested_supplier_id      =>  p_requested_supplier_id,
                                p_requested_supplier_name    =>  p_requested_supplier_name,
				p_trading_partner_contact_id => NULL);
     RETURN result;
  END;

    FUNCTION generate_auction_xml(p_auction_header_id          IN NUMBER,
                                p_client_time_zone           IN VARCHAR2,
                                p_server_time_zone           IN VARCHAR2,
                                p_date_format                IN VARCHAR2,
                                p_trading_partner_id         IN NUMBER,
                                p_trading_partner_name       IN VARCHAR2,
                                p_vendor_site_id             IN NUMBER,
                                p_user_view_type             IN VARCHAR2,
                                p_printing_warning_flag      IN VARCHAR2  DEFAULT 'N',
                                p_neg_printed_with_contracts IN VARCHAR2  DEFAULT 'N',
                                p_requested_supplier_id      IN NUMBER,
                                p_requested_supplier_name    IN VARCHAR2,
                                p_trading_partner_contact_id IN NUMBER)
  RETURN CLOB IS

  result CLOB;

  BEGIN

    result  :=       generate_auction_xml(p_auction_header_id          =>  p_auction_header_id,
                                p_client_time_zone           =>  p_client_time_zone,
                                p_server_time_zone           =>  p_server_time_zone,
                                p_date_format                =>  p_date_format,
                                p_trading_partner_id         =>  p_trading_partner_id,
                                p_trading_partner_name       =>  p_trading_partner_name,
                                p_vendor_site_id             =>  p_vendor_site_id,
                                p_user_view_type             =>  p_user_view_type,
                                p_printing_warning_flag      =>  p_printing_warning_flag,
                                p_neg_printed_with_contracts =>  p_neg_printed_with_contracts,
                                p_requested_supplier_id      =>  p_requested_supplier_id,
                                p_requested_supplier_name    =>  p_requested_supplier_name,
				p_trading_partner_contact_id =>  p_trading_partner_contact_id,
                                p_bid_number                 =>  -1,
                                p_user_id                    =>  null);
     RETURN result;
  END;

  ----------------------------------------------------------------------------------------
  --Function: GENERATE_EMD_XML for negotiation emd report
  --12-Nov-2008   Chaoqun   Create
  -----------------------------------------------------------------------------------------
  FUNCTION generate_emd_xml(p_auction_header_id IN NUMBER) RETURN CLOB IS
    result CLOB;
    TYPE emd_header_cursor_type IS REF CURSOR;
    xml_query_cursor      emd_header_cursor_type;
    xml_stmt              varchar2(500);
    l_printing_language   VARCHAR2(3) := userenv('lang');
    l_start_time          DATE;
    l_end_time            DATE;
    l_current_log_level   NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_module_name         VARCHAR2(80) := 'pon.plsql.PON_PRINTING_PKG.GENERATE_EMD_XML';

  BEGIN

    OPEN xml_query_cursor FOR
      SELECT pah.AUCTION_HEADER_ID AS NEGOTIATION_NUMBER,
             pah.AUCTION_TITLE AS NEGOTIATION_TITLE,
             (SELECT COUNT(*)
              FROM pon_bidding_parties     pbp
              WHERE pbp.AUCTION_HEADER_ID = pah.AUCTION_HEADER_ID
             ) AS NUMBER_OF_SUPPLIERS,
             pah.CLOSE_BIDDING_DATE AS NEGOTIATION_CLOSE_DATE,  --Modify by Chaoqun 04-Mar-2009
             pah.CURRENCY_CODE as EMD_QUOTE_CURRENCY,
             pah.EMD_ENABLE_FLAG,
             pah.EMD_AMOUNT,
             pah.EMD_DUE_DATE,
             pah.EMD_TYPE,
             flv.MEANING AS EMD_TYPE_MEANING,
             pah.EMD_GUARANTEE_EXPIRY_DATE AS EMD_GUARANTEE_EXPIRY_DAYS,
             CURSOR (SELECT ROWNUM                   AS SERIAL_NUM,
                            pbp.trading_partner_name AS SUPPLIER_NAME,
                            pbp.trading_partner_contact_name AS SUPPLIER_USER,
                            pbp.vendor_site_code     AS SUPPLIER_SITE,
                            decode(pbp.exempt_flag, null, 'N',pbp.exempt_flag) as EMD_EXEMPTED,
                            decode(decode(pet.status_lookup_code,
                                          null,
                                          decode(pbp.exempt_flag,
                                                 null, 'NOT_PAID',
                                                 'N',  'NOT_PAID',
                                                 'Y',  'EXEMPTED'),
                                          pet.status_lookup_code),
                                   'NOT_PAID',
                                   'N',
                                   'EXEMPTED',
                                   'N',
                                   'RECEIVING',  --Modify by Chaoqun 05-Mar-2009
                                   'N',
                                   'RECEIVE_ERROR',
                                   'N',
                                   'Y') as EMD_RECEIVED,
                            (select petr.amount
                                      from pon_emd_transactions petr
                                      where petr.auction_header_id = p_auction_header_id
                                        and petr.supplier_sequence= pbp.sequence
                                        and pbp.AUCTION_HEADER_ID = petr.AUCTION_HEADER_ID
                                and (petr.status_lookup_code = 'RECEIVING'
                                  or petr.status_lookup_code = 'RECEIVED'
                                  or petr.status_lookup_code = 'RECEIVE_ERROR')
                             ) as EMD_RECEIVED_AMOUNT,
                             (select petr.TRANSACTION_DATE
                                      from pon_emd_transactions petr
                                      where petr.auction_header_id = p_auction_header_id
                                        and petr.supplier_sequence= pbp.sequence
                                        and pbp.AUCTION_HEADER_ID = petr.AUCTION_HEADER_ID
                                 and (petr.status_lookup_code = 'RECEIVING'
                                      or petr.status_lookup_code = 'RECEIVED'
                                      or petr.status_lookup_code = 'RECEIVE_ERROR')
                              ) as EMD_RECEIVED_DATE,
                            decode(decode(pet.status_lookup_code,
                                          null,
                                          decode(pbp.exempt_flag,
                                                 null, 'NOT_PAID',
                                                 'N',  'NOT_PAID',
                                                 'Y',  'EXEMPTED'),
                                          pet.status_lookup_code),
                                    'REFUNDING', pet.amount,
                                    'REFUNDED', pet.amount,
                                    'REFUND_ERROR', pet.amount,
                                    'FORFEITING', pet.amount,
                                    'FORFEITED', pet.amount,
                                    'FORFEIT_ERROR', pet.amount,
                                     null) as EMD_RF_AMOUNT,
                             decode(decode(pet.status_lookup_code,
                                          null,
                                          decode(pbp.exempt_flag,
                                                 null, 'NOT_PAID',
                                                 'N',  'NOT_PAID',
                                                 'Y',  'EXEMPTED'),
                                          pet.status_lookup_code),
                                    'REFUNDING', pet.TRANSACTION_DATE,
                                    'REFUNDED', pet.TRANSACTION_DATE,
                                    'REFUND_ERROR', pet.TRANSACTION_DATE,
                                    'FORFEITING', pet.TRANSACTION_DATE,
                                    'FORFEITED', pet.TRANSACTION_DATE,
                                    'FORFEIT_ERROR', pet.TRANSACTION_DATE,
                                     null) as EMD_RF_DATE,
                                decode(decode(pet.status_lookup_code, --Modify by Chaoqun 05-Mar-2009
                                       null,
                                       decode(pbp.exempt_flag,
                                              null, 'NOT_PAID',
                                              'N',  'NOT_PAID',
                                              'Y',  'EXEMPTED'),
                                          pet.status_lookup_code),
                                    'NOT_PAID',null,
                                    'EXEMPTED',null,
                                    'RECEIVING',pet.transaction_currency_code,
                                    'RECEIVE_ERROR',pet.transaction_currency_code,
                                    'RECEIVED',pet.transaction_currency_code,
                                    (select petr.transaction_currency_code
                                       from pon_emd_transactions petr
                                      where petr.auction_header_id = p_auction_header_id
                                        and petr.supplier_sequence= pbp.sequence
                                        and pbp.AUCTION_HEADER_ID = petr.AUCTION_HEADER_ID
                                        and petr.status_lookup_code = 'RECEIVED')
                                     ) AS EMD_RECEIVED_CURRENCY,
                                (select flv.meaning                    --Modify by Chaoqun 05-Mar-2009
                                   from fnd_lookup_values flv
                                  where flv.lookup_type = 'PON_EMD_SUPPLIER_STATUS'
                                    AND flv.language = USERENV('LANG')
                                    AND flv.lookup_code = decode(pet.status_lookup_code,
                                                                    null,
                                                                    decode(pbp.exempt_flag,
                                                                    null, 'NOT_PAID',
                                                                    'N',  'NOT_PAID',
                                                                    'Y',  'EXEMPTED'),
                                                                     pet.status_lookup_code)
                                  ) as EMD_CURRENT_STATUS,
                                 pet.Justification as EMD_JUSTIFICATION
                       FROM PON_bidding_parties  pbp,
                            PON_EMD_TRANSACTIONS pet
                      WHERE pbp.AUCTION_HEADER_ID = p_auction_header_id
                        AND pbp.AUCTION_HEADER_ID = pet.AUCTION_HEADER_ID(+) --Modify by Chaoqun 05-Mar-2009
                        AND pbp.sequence = pet.supplier_sequence(+)
                        AND decode(pet.current_row_flag,null,'Y',pet.current_row_flag) = 'Y') AS EMD_SUMMARY,
             CURSOR (select message_name, message_text
                       from fnd_new_messages
                      where message_name in
                            ('PON_NEGOTIATION_NUMBER',
                             'PON_NEGOTIATION_TITLE', 'PON_NEG_CLOSE_DATE',
                             'PON_EMD_QUOTE_CURRENCY', 'PON_EMD_TYPE' -- EMD Type
                            , 'PON_EMD_DUE_DATE' -- EMD Due Date
                            , 'PON_EMD_AMOUNT' -- EMD Amount
                            , 'PON_EMD_GUARANTEE_EXPIRY_DATE' -- Bank Guarantee Expiry Date
                            , 'PON_EMD_SUMMARY', 'PON_EMD_SERIAL_NUM',
                             'PON_EMD_SUPPLIER_NAME', 'PON_EMD_SUPPLIER_USER',
                             'PON_EMD_SUPPLIER_SITE',
                             'PON_EMD_NUM_OF_SUPPLIERS', 'PON_EMD_EXEMPTED',
                             'PON_EMD_RECEIVED', 'PON_EMD_RECEIVED_CURRENCY',
                             'PON_EMD_RECEIVED_AMOUNT',
                             'PON_EMD_RECEIVED_DATE',
                             'PON_EMD_RF_AMOUNT', 'PON_EMD_RF_DATE',
                             'PON_EMD_CURRENT_STATUS',
                             'PON_EMD_JUSTIFICATION',
                             'PON_CREATED_BY', 'PON_EMD_REPORT_HEADING' --Added by Chaoqun on 16-Apr-2009 for UI Change
                            )
                        and application_id = 396
                        and language_code = l_printing_language) as GENERIC_MESSAGES
        FROM pon_auction_headers_all pah
           , fnd_lookup_values flv
          -- , FND_USER fu
       WHERE pah.auction_header_id = p_auction_header_id  --Using the variable p_auction_header_id
         and flv.lookup_type(+) = 'PON_AUCTION_EMD_TYPE'
         and flv.language(+) = USERENV('LANG')
         and flv.lookup_code(+) = pah.EMD_TYPE;
        -- and fu.USER_ID = pah.CREATED_BY;

    dbms_lob.createtemporary(result, TRUE);

    SELECT CURRENT_DATE INTO l_start_time FROM DUAL;

    xml_stmt := 'DECLARE
       queryCtx DBMS_XMLGEN.ctxHandle;
       BEGIN
        queryCtx := DBMS_XMLGEN.newContext(:xml_query_cursor);
        DBMS_XMLGEN.getXML(queryCtx, :result, DBMS_XMLGEN.NONE);
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
          END;';
    execute immediate xml_stmt
      USING IN OUT xml_query_cursor, IN OUT result;

    SELECT CURRENT_DATE INTO l_end_time FROM DUAL;

    CLOSE xml_query_cursor;

    IF l_statement_log_level >= l_current_log_level THEN
      FND_LOG.string(l_statement_log_level,
                     l_module_name,
                     'PDF: generating XML time: ' ||
                     (l_end_time - l_start_time) * 24 * 60 * 60);
    END IF;

    return result;

  END GENERATE_EMD_XML;

  -------------------------------------------------------------------------*\
  --   13-Nov-2008 Yao Zhang Create                                         |
  --   Function Name: GENERATE_SUPPLIER_XML                                 |
  --   This function is used to query data for individual supplier report   |
  -------------------------------------------------------------------------*/

  FUNCTION generate_supplier_xml(p_auction_header_id IN NUMBER,
                                 p_supplier_sequence IN NUMBER) RETURN CLOB IS
    result CLOB;
    TYPE emd_supplier_cursor_type IS REF CURSOR;
    xml_query_cursor      emd_supplier_cursor_type;
    xml_stmt              varchar2(500);
    l_printing_language   VARCHAR2(3) := userenv('lang');
    l_start_time          DATE;
    l_end_time            DATE;
    l_current_log_level   NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_module_name         VARCHAR2(80) := 'pon.plsql.PON_PRINTING_PKG.GENERATE_SUPPLIER_XML';
    l_emd_current_status  varchar2(20);
   --Begin: Added by Chaoqun on 11-Jan_2009
    l_cust_trx_id         NUMBER;
    l_cust_trx_num        VARCHAR2(20);
    x_rec_rec_num         VARCHAR2(50);
    l_org_id              NUMBER;
    x_cash_receipt_id     NUMBER;
    x_receivable_app_id   NUMBER;
    x_receipt_status      VARCHAR2(20);
    x_receipt_status_code VARCHAR2(20);
    x_return_status       VARCHAR2(20);
    --End: Added by Chaoqun on 11-Jan_2009

  BEGIN

  BEGIN
    select  decode(petr.status_lookup_code,
                          null,
                          decode(pbp.exempt_flag,
                                  null, 'NOT_PAID',
                                  'N',  'NOT_PAID',
                                  'Y',  'EXEMPTED'),
                petr.status_lookup_code)
     into l_emd_current_status
    from pon_emd_transactions  petr,
         pon_bidding_parties   pbp
    where    pbp.sequence=p_supplier_sequence
         and pbp.auction_header_id= p_auction_header_id
         and petr.auction_header_id(+) = pbp.auction_header_id
         and petr.supplier_sequence(+) = pbp.sequence
         and decode(petr.current_row_flag,null,'Y',petr.current_row_flag) = 'Y';
  --Begin: Added by Chaoqun on 11-Jan_2009
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     l_emd_current_status := 'NOT_PAID';
  END;

  BEGIN
  select  petr.cust_trx_id,
          petr.Cust_Trx_Number,
          petr.Org_Id
    into  l_cust_trx_id,
          l_cust_trx_num,
          l_org_id
    from  pon_emd_transactions  petr
   where  petr.auction_header_id = p_auction_header_id
         and petr.status_lookup_code = 'RECEIVED'
         and petr.supplier_sequence = p_supplier_sequence;
   exception
     when NO_DATA_FOUND then
     l_cust_trx_id := null;
     l_cust_trx_num := null;
   END;

   IF l_cust_trx_id IS NOT NULL AND l_cust_trx_num IS NOT NULL THEN
   PON_EMD_VALIDATION_PKG.getReceiptInfoOfTrx(l_cust_trx_id,
                                                        l_cust_trx_num,
                                                        l_org_id,
                                                        x_rec_rec_num,
                                                        x_cash_receipt_id,
                                                        x_receivable_app_id,
                                                        x_receipt_status,
							x_receipt_status_code,
                                                        x_return_status
                                                        );
   END IF;
   --End: Added by Chaoqun on 11-Jan_2009

--Begin: Add by Chaoqun on 05-Mar-2009
   IF l_emd_current_status = 'NOT_PAID' OR l_emd_current_status = 'EXEMPTED' THEN
    OPEN xml_query_cursor FOR
      select 'Y' as SUPPLIER_REPORT,
             paha.document_number as NEGOTIATION_NUMBER,
             paha.auction_title as NEGOTIATION_TITLE,
             pbp.trading_partner_name as SUPPLIER_NAME,
             pbp.vendor_site_code as SUPPLIER_SITE,
             paha.emd_amount as EMD_AMOUNT,
             paha.emd_due_date as EMD_DUE_DATE,
             paha.emd_type as EMD_TYPE,
             fl.meaning as EMD_TYPE_MEANING,
             paha.emd_guarantee_expiry_date as EMD_GUARANTEE_EXPIRY_DATE,
             paha.currency_code as EMD_CURR_CODE,
             (select flv.meaning
                from fnd_lookup_values flv
               where flv.lookup_type = 'PON_EMD_SUPPLIER_STATUS'
                 AND flv.language = USERENV('LANG')
                 AND flv.lookup_code = l_emd_current_status
              ) as EMD_CURRENT_STATUS,
             PON_LOCALE_PKG.party_display_name(hz.person_first_name,
                                               hz.PERSON_LAST_NAME,
                                               hz.person_middle_name,
                                               fl1.MEANING,
                                               hz.PERSON_NAME_SUFFIX,
                                               userenv('LANG')) AS CREATED_BY,
             decode(pbp.exempt_flag,
                    null, 'N',
                    pbp.exempt_flag) as EMD_EXEMPTED_FLAG,
             'N' as EMD_RECEIVED_FLAG,
             'N' as EMD_REFUNDED_FLAG,
             'N' as EMD_FORFEITED_FLAG,
             cursor (select message_name, message_text
                       from fnd_new_messages
                      where message_name in
                            ('PON_EMD_NEGOTIATION_NO',
                             'PON_EMD_NEGOTIATION_TITLE',
                             'PON_EMD_SUPPLIER_NAME', 'PON_EMD_SUPPLIER_SITE',
                             'PON_EMD_AMOUNT', 'PON_EMD_DUE_DATE',
                             'PON_EMD_TYPE', 'PON_EMD_GUARANTEE_EXPIRY_DATE',
                             'PON_EMD_QUOTE_CURRENCY',
                             'PON_EMD_CURRENT_STATUS', 'PON_EMD_SUMMARY',
                             'PON_EMD_PAYMENT_DETAILS',
                             'PON_EMD_REFUND_DETAILS',
                             'PON_EMD_FORFEIT_DETAILS', 'PON_EMD_EXEMPTED',
                             'PON_EMD_RECEIVED', 'PON_EMD_RECEIVED_AMOUNT',
                             'PON_EMD_RECEIVED_DATE', 'PON_EMD_REFUNDED',
                             'PON_EMD_REFUNDED_AMOUNT',
                             'PON_EMD_REFUNDED_DATE', 'PON_EMD_FORFEITED',
                             'PON_EMD_FORFEIT_AMOUNT', 'PON_EMD_FORFEIT_DATE',
                             'PON_EMD_BANK_NAME', 'PON_EMD_BRANCH_NAME',
                             'PON_EMD_DETAIL_BANK_ACCOUNT',
                             'PON_EMD_PAYMENT_TYPE', 'PON_EMD_CURRENCY',
                             'PON_EMD_PAYMENT_DATE', 'PON_EMD_DETAIL_AMOUNT',
                             'PON_EMD_CREATED_BY', 'PON_EMD_SUPPLIER_HEADING' --Added by Chaoqun on 15-Mar-2009 for UI Change
                             )
                        and application_id = 396
                        and language_code = l_printing_language) as GENERIC_MESSAGES
          from pon_auction_headers_all paha,
               pon_bidding_parties     pbp,
               fnd_lookup_values       fl,
               fnd_lookups             fl1,
               pon_auc_doctypes        doc,
               HZ_PARTIES              hz
       where paha.auction_header_id = p_auction_header_id
         and pbp.auction_header_id = paha.auction_header_id
         and pbp.sequence = p_supplier_sequence
         and fl.lookup_type(+) = 'PON_AUCTION_EMD_TYPE'
         and fl.language(+) = USERENV('LANG')
         and fl.LOOKUP_CODE(+) = paha.EMD_TYPE
         and fl1.lookup_type = 'PON_AUCTION_DOC_TYPES'
         and fl1.lookup_code = doc.internal_name
         and paha.doctype_id = doc.doctype_id
         and HZ.party_id(+) = paha.trading_partner_contact_id
         and rownum = 1;
   ELSE
--END: Add by Chaoqun on 05-Mar-2009
    OPEN xml_query_cursor FOR
      select 'Y' as SUPPLIER_REPORT,
             paha.document_number as NEGOTIATION_NUMBER,
             paha.auction_title as NEGOTIATION_TITLE,
             pbp.trading_partner_name as SUPPLIER_NAME,
             pbp.vendor_site_code as SUPPLIER_SITE,
             paha.emd_amount as EMD_AMOUNT,
             paha.emd_due_date as EMD_DUE_DATE,
             paha.emd_type as EMD_TYPE,
             fl.meaning as EMD_TYPE_MEANING,
             paha.emd_guarantee_expiry_date as EMD_GUARANTEE_EXPIRY_DATE,
             paha.currency_code as EMD_CURR_CODE,
             (select flv.meaning
                from fnd_lookup_values flv
               where flv.lookup_type = 'PON_EMD_SUPPLIER_STATUS'
                 AND flv.language = USERENV('LANG')
                 AND flv.lookup_code = l_emd_current_status
              ) as EMD_CURRENT_STATUS,   --Modify by Chaoqun 09-Mar-2009
             PON_LOCALE_PKG.party_display_name(hz.person_first_name,
                                               hz.PERSON_LAST_NAME,
                                               hz.person_middle_name,
                                               fl1.MEANING,
                                               hz.PERSON_NAME_SUFFIX,
                                               userenv('LANG')) AS CREATED_BY, --Modify by Chaoqun 09-Mar-2009
             decode(pbp.exempt_flag,
                    null, 'N',
                    pbp.exempt_flag) as EMD_EXEMPTED_FLAG,
             decode(l_emd_current_status,
                    'NOT_PAID',
                    'N',
                    'EXEMPTED',
                    'N',
                    'RECEIVING',  --Modify by Chaoqun 04-Mar-2009
                    'N',
                    'RECEIVE_ERROR',
                    'N',
                    'Y') as EMD_RECEIVED_FLAG,
               (select petr.amount
                       from pon_emd_transactions petr
                       where petr.auction_header_id = p_auction_header_id
                        and petr.supplier_sequence= p_supplier_sequence
                   and (petr.status_lookup_code = 'RECEIVING'
                      or petr.status_lookup_code = 'RECEIVED'
                      or petr.status_lookup_code = 'RECEIVE_ERROR')) as EMD_RECEIVED_AMOUNT,
               (select petr.TRANSACTION_DATE
                       from pon_emd_transactions petr
                       where petr.auction_header_id = p_auction_header_id
                        and petr.supplier_sequence= p_supplier_sequence
                   and (petr.status_lookup_code = 'RECEIVING'
                      or petr.status_lookup_code = 'RECEIVED'
                      or petr.status_lookup_code = 'RECEIVE_ERROR')) as EMD_RECEIVED_DATE,
                (select flv.meaning
                  from PON_EMD_TRANSACTIONS petr,
                       fnd_lookup_values flv
                 where petr.AUCTION_HEADER_ID = p_auction_header_id
                  AND  petr.SUPPLIER_SEQUENCE = p_supplier_sequence
                  AND flv.lookup_type = 'PON_EMD_PAYMENT_METHOD'
                  AND flv.language = USERENV('LANG')
                  AND flv.lookup_code = petr.PAYMENT_TYPE_CODE
                  and (petr.status_lookup_code = 'RECEIVING'
                    or petr.status_lookup_code = 'RECEIVED'
                    or petr.status_lookup_code = 'RECEIVE_ERROR')) as EMD_PAYMENT_TYPE,
             decode(l_emd_current_status, 'REFUNDED', 'Y', 'N') as EMD_REFUNDED_FLAG,
             (select petr.amount
                      from pon_emd_transactions petr
                       where petr.auction_header_id = p_auction_header_id
                        and petr.supplier_sequence= p_supplier_sequence
                   and (petr.status_lookup_code = 'REFUNDING'
                     or petr.status_lookup_code = 'REFUNDED'
                     or petr.status_lookup_code = 'REFUND_ERROR')) as EMD_REFUNDED_AMOUNT,
              (select petr.TRANSACTION_DATE
                       from pon_emd_transactions petr
                       where petr.auction_header_id = p_auction_header_id
                        and petr.supplier_sequence= p_supplier_sequence
                   and (petr.status_lookup_code = 'REFUNDING'
                      or petr.status_lookup_code = 'REFUNDED'
                      or petr.status_lookup_code = 'REFUND_ERROR')) as EMD_REFUNDED_DATE,
             decode(l_emd_current_status, 'FORFEITED', 'Y', 'N') as EMD_FORFEITED_FLAG,
             (select petr.amount
                      from pon_emd_transactions petr
                       where petr.auction_header_id = p_auction_header_id
                        and petr.supplier_sequence= p_supplier_sequence
                 and (petr.status_lookup_code = 'FORFEITING'
                   or petr.status_lookup_code = 'FORFEITED'
                   or petr.status_lookup_code = 'FORFEIT_ERROR')) as EMD_FORFEITED_AMOUNT,
             (select petr.TRANSACTION_DATE
                     from pon_emd_transactions petr
                       where petr.auction_header_id = p_auction_header_id
                        and petr.supplier_sequence= p_supplier_sequence
                and (petr.status_lookup_code = 'FORFEITING'
                  or petr.status_lookup_code = 'FORFEITED'
                  or petr.status_lookup_code = 'FORFEIT_ERROR')) as EMD_FORFEITED_DATE,
             cursor (select petr.status_lookup_code        as EMD_DETAIL_STATUS,
                            petr.bank_name                 as EMD_DETAIL_BANKNAME,
                            petr.bank_branch_name          as EMD_DETAIL_BRANCHNAME,
                            petr.transaction_currency_code as EMD_DETAIL_CURRCODE,
                            petr.amount                    as EMD_DETAIL_AMOUNT,
                            petr.TRANSACTION_DATE          as EMD_DETAIL_TRXDATE,
                            petr.justification             as EMD_DETAIL_JUSTIFICATION,
                            petr.cust_trx_number           as EMD_DETAIL_TRX_NO,
                            --Begin: Addde by Chaoqun on 22-DEC-2008
                            paha.emd_type                  as EMD_TYPE,
                            cc.masked_cc_number            as EMD_DETAIL_CRE_NO,
                            petr.payment_type_code         as EMD_PAYMENT_TYPE_CODE,
                            petr.CHEQUE_NUMBER             as EMD_CHEQUE_NUM,
                            decode(petr.status_lookup_code,
                                   'REFUNDED',
                                    petr.emd_transaction_id,
                                    null)                  as EMD_REFUND_ID,
                            decode(petr.status_lookup_code,
                                   'RECEIVED',
                                    petr.DOCUMENT_NUMBER,
                                    null)                  as EMD_REC_DOCUMENT_NUM,
                            decode(petr.status_lookup_code,
                                   'REFUNDED',
                                    petr.DOCUMENT_NUMBER,
                                    null)                  as EMD_REF_DOCUMENT_NUM,
                            decode(petr.status_lookup_code,
                                   'RECEIVED',
                                    petr.bank_account_num,
                                    null)                  as EMD_REC_BANK_ACCOUNT_NUM,
                            decode(petr.status_lookup_code,
                                   'REFUNDED',
                                    petr.bank_account_num,
                                    null)                  as EMD_REF_BANK_ACCOUNT_NUM,
                            petr.CASH_BEARER_NAME          as EMD_CASH_BEARER_NAME,
                            petr.DEMAND_DRAFT_NUM          as EMD_DEMAND_DRAFT_NUM,
                            petr.PAYABLE_AT                as EMD_PAYABLE_AT,
                            petr.BANK_GURANTEE_NUMBER      as EMD_BANK_GUR_NUM,
                            petr.In_Favor_Of               as EMD_IN_FAVOR_OF,
                            petr.NAME_ON_CARD              as EMD_CARD_HOLDER_NAME,
                            petr.EXPIRY_DATE               as EMD_EXPIRATION_DATE,
                            petr.TYPE_OF_CARD              as EMD_TYPE_OF_CARD,
                            flv.meaning                    as EMD_DETAIL_PAYTYPE,
                            decode(petr.status_lookup_code,
                                   'RECEIVED',
                                    petr.Cust_Trx_Number,
                                    null)                  as EMD_REC_TRAN_NUM,
                            decode(petr.status_lookup_code,
                                   'RECEIVED',
                                    x_rec_rec_num,
                                    null)                  as EMD_REC_REC_NUM,
                            decode(petr.status_lookup_code,
                                   'REFUNDED',
                                    petr.Cust_Trx_Number,
                                    null)                  as EMD_CREDIT_MEMO_NUM,
                            decode(petr.status_lookup_code,
                                   'FORFEITED',
                                    petr.Cust_Trx_Number,
                                    null)                  as EMD_FORFEIT_TRANS_NUM,
                            decode(petr.status_lookup_code,
                                   'REFUNDED',
                                   (select aia.invoice_num
                                      from ap_invoices_all aia
                                     where aia.invoice_id = petr.application_ref_id),
                                    null)                  as EMD_PAY_INV_NUM,
                            decode(petr.status_lookup_code,
                                   'REFUNDED',
                                    (select apsa.payment_num
                                      from ap_payment_schedules_all apsa
                                     where apsa.invoice_id = petr.application_ref_id),
                                    null)                  as EMD_PAY_PAY_NUM,
                            decode(petr.status_lookup_code,
                                   'REFUNDED',
                                    petr.JUSTIFICATION,
                                    null)                  as EMD_REFUND_JUSTIFICATION,
                            decode(petr.status_lookup_code,
                                   'FORFEITED',
                                    petr.JUSTIFICATION,
                                    null)                  as EMD_FORFEIT_JUSTIFICATION,
                            --End: Addde by Chaoqun on 22-DEC-2008
                            petr.emd_transaction_id as TRX_ID
                       from pon_emd_transactions petr,
                            pon_bidding_parties  pbp,
                            fnd_lookup_values    flv,
                            IBY_CREDITCARD       cc
                       where petr.auction_header_id = p_auction_header_id
                        and  pbp.auction_header_id= p_auction_header_id
                        and  pbp.sequence= p_supplier_sequence
                        and petr.supplier_sequence(+)=pbp.sequence
                        --Added by Chaoqun on 22-DEC-2008
                        and cc.CARD_OWNER_ID(+) = petr.card_owner_id
                        and cc.CARD_ISSUER_CODE(+) = petr.CARD_ISSUER_CODE
                        and cc.CHNAME(+) = petr.NAME_ON_CARD
                        and cc.CCNUMBER(+) = petr.credit_card_num
                        and flv.lookup_type(+) = 'PON_EMD_PAYMENT_METHOD'
                        and flv.language(+) = USERENV('LANG')
                        and flv.LOOKUP_CODE(+) = petr.Payment_Type_Code
                        -----------------------------------
                      order by TRX_ID) as EMD_DETAILS,
             cursor (select message_name, message_text
                       from fnd_new_messages
                      where message_name in
                            ('PON_EMD_NEGOTIATION_NO',
                             'PON_EMD_NEGOTIATION_TITLE',
                             'PON_EMD_SUPPLIER_NAME', 'PON_EMD_SUPPLIER_SITE',
                             'PON_EMD_AMOUNT', 'PON_EMD_DUE_DATE',
                             'PON_EMD_TYPE', 'PON_EMD_GUARANTEE_EXPIRY_DATE',
                             'PON_EMD_QUOTE_CURRENCY',
                             'PON_EMD_CURRENT_STATUS', 'PON_EMD_SUMMARY',
                             'PON_EMD_PAYMENT_DETAILS',
                             'PON_EMD_REFUND_DETAILS',
                             'PON_EMD_FORFEIT_DETAILS', 'PON_EMD_EXEMPTED',
                             'PON_EMD_RECEIVED', 'PON_EMD_RECEIVED_AMOUNT',
                             'PON_EMD_RECEIVED_DATE', 'PON_EMD_REFUNDED',
                             'PON_EMD_REFUNDED_AMOUNT',
                             'PON_EMD_REFUNDED_DATE', 'PON_EMD_FORFEITED',
                             'PON_EMD_FORFEIT_AMOUNT', 'PON_EMD_FORFEIT_DATE',
                             'PON_EMD_BANK_NAME', 'PON_EMD_BRANCH_NAME',
                             'PON_EMD_DETAIL_BANK_ACCOUNT',
                             'PON_EMD_PAYMENT_TYPE', 'PON_EMD_CURRENCY',
                             'PON_EMD_PAYMENT_DATE', 'PON_EMD_DETAIL_AMOUNT',
                             --Added by Chaoqun on 22-DEC-2008
                             'PON_EMD_CHEQUE_NUM','PON_EMD_CASH_BEARER_NAME',
                             'PON_EMD_DEMAND_DRAFT_NUM', 'PON_EMD_PAYABLE_AT' ,
                             'PON_EMD_BANK_GUR_NUM','PON_EMD_IN_FAVOR_OF',
                             'PON_EMD_CARD_HOLDER_NAME','PON_EMD_EXPIRATION_DATE',
                             'PON_EMD_TYPE_OF_CARD', 'PON_EMD_REC_TRAN_NUM',
                             'PON_EMD_REC_REC_NUM', 'PON_EMD_CREDIT_CARD_NUM',
                             'PON_EMD_DOCUMENT_NUM', 'PON_EMD_JUSTIFICATION',
                             'PON_EMD_REC_CREDIT_NUM',
                             'PON_EMD_PAY_INV_NUM', 'PON_EMD_PAY_PAY_NUM',
                             'PON_EMD_REFUND_ID', 'PON_EMD_CREATED_BY' ,
                             'PON_EMD_SUPPLIER_HEADING' --Added by Chaoqun on 15-Mar-2009 for UI Change
                             ---------------------------------
                             )
                        and application_id = 396
                        and language_code = l_printing_language) as GENERIC_MESSAGES
        from pon_auction_headers_all paha,
             pon_emd_transactions    petr,
             pon_bidding_parties     pbp,
             fnd_lookup_values       fl,
             fnd_lookups             fl1,
             pon_auc_doctypes        doc,
             HZ_PARTIES              hz
       where paha.auction_header_id = p_auction_header_id
         and pbp.auction_header_id = paha.auction_header_id
         --Begin: Added by Chaoqun on 22-DEC-2008
         and pbp.sequence = petr.supplier_sequence
         and petr.auction_header_id = paha.auction_header_id
         and petr.supplier_sequence = p_supplier_sequence
         and decode(petr.current_row_flag,null,'Y',petr.current_row_flag) = 'Y'
         and fl.lookup_type(+) = 'PON_AUCTION_EMD_TYPE'
         and fl.language(+) = USERENV('LANG')
         and fl.LOOKUP_CODE(+) = paha.EMD_TYPE
         and fl1.lookup_type = 'PON_AUCTION_DOC_TYPES'
         and fl1.lookup_code = doc.internal_name
         and paha.doctype_id = doc.doctype_id
         and HZ.party_id(+) = paha.trading_partner_contact_id;
         --END: Added by Chaoqun on 22-DEC-2008
      END IF;

    dbms_lob.createtemporary(result, TRUE);

    SELECT CURRENT_DATE INTO l_start_time FROM DUAL;

    xml_stmt := 'DECLARE
       queryCtx DBMS_XMLGEN.ctxHandle;
       BEGIN
        queryCtx := DBMS_XMLGEN.newContext(:xml_query_cursor);
        DBMS_XMLGEN.getXML(queryCtx, :result, DBMS_XMLGEN.NONE);
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
          END;';
    execute immediate xml_stmt
      USING IN OUT xml_query_cursor, IN OUT result;

    SELECT CURRENT_DATE INTO l_end_time FROM DUAL;

    CLOSE xml_query_cursor;

    IF l_statement_log_level >= l_current_log_level THEN
      FND_LOG.string(l_statement_log_level,
                     l_module_name,
                     'PDF: generating XML time: ' ||
                     (l_end_time - l_start_time) * 24 * 60 * 60);
    END IF;

    return result;
  END generate_supplier_xml;

  -------------------------------------------------------------------------*\
  --   10-Dec-2008 Lion Li Create                                         |
  --   Function Name: GENERATE_EMD_FORFEIT_XML                                 |
  --   This function is used to query data for receipt to individual supplier  |
  -------------------------------------------------------------------------*/

  FUNCTION generate_receipt_xml(p_auction_header_id IN NUMBER,
                                 p_supplier_sequence IN NUMBER) RETURN CLOB IS
    result CLOB;
    TYPE emd_supplier_cursor_type IS REF CURSOR;
    xml_query_cursor      emd_supplier_cursor_type;
    xml_stmt              varchar2(500);
    l_printing_language   VARCHAR2(3) := userenv('lang');
    l_start_time          DATE;
    l_end_time            DATE;
    l_current_log_level   NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_module_name         VARCHAR2(80) := 'pon.plsql.PON_PRINTING_PKG.GENERATE_RECEIPT_XML';
    --p_supplier_id          := 12438;
    --l_emd_current_status pon_emd_transactions.status_lookup_code%type;
    TYPE emd_current_status_type is ref cursor;
    emd_current_status emd_current_status_type;

  BEGIN
--Begin: Deleted by Chaoqun on 19-Mar-2009

/*    open emd_current_status for
      select petr.status_lookup_code
        from pon_emd_transactions petr
       where petr.auction_header_id = p_auction_header_id
         and petr.supplier_sequence= p_supplier_sequence
       order by petr.emd_transaction_id;

    loop
      fetch emd_current_status
        into l_emd_current_status;
      exit when emd_current_status%notfound;
    end loop;
    close emd_current_status;*/

--End: Deleted by Chaoqun on 19-Mar-2009


    OPEN xml_query_cursor FOR
      select 'Y' as SUPPLIER_REPORT,
             paha.document_number as NEGOTIATION_NUMBER,
             paha.auction_title as NEGOTIATION_TITLE,
             pbp.trading_partner_name as SUPPLIER_NAME,
             pbp.vendor_site_code as SUPPLIER_SITE,
             paha.emd_amount as EMD_AMOUNT,
             paha.emd_due_date as EMD_DUE_DATE,
             paha.emd_type as EMD_TYPE,
             flv.meaning as EMD_TYPE_MEANING,
             paha.emd_guarantee_expiry_date as EMD_GUARANTEE_EXPIRY_DATE,
             --pbp.bid_currency_code as EMD_CURR_CODE,
             paha.currency_code as EMD_CURR_CODE, --Modify by Chaoqun on 19-Mar-2009
             --l_emd_current_status as EMD_CURRENT_STATUS,
             pbp.exempt_flag as EMD_EXEMPTED_FLAG,
             PON_LOCALE_PKG.party_display_name(hz.person_first_name,
                                                  hz.PERSON_LAST_NAME,
                                                  hz.person_middle_name,
                                                  f1.MEANING,
                                                  hz.PERSON_NAME_SUFFIX,
                                                  userenv('LANG'))
             as EMD_CREATED_BY ,
    --Begin: Added by Chaoqun on 20-Mar-2009
             'Y' as EMD_RECEIVED_FLAG,
             cursor (select petr.status_lookup_code        as EMD_DETAIL_STATUS,
                            petr.bank_name                 as EMD_DETAIL_BANKNAME,
                            petr.bank_branch_name          as EMD_DETAIL_BRANCHNAME,
                            petr.transaction_currency_code as EMD_DETAIL_CURRCODE,
                            petr.amount                    as EMD_DETAIL_AMOUNT,
                            petr.TRANSACTION_DATE          as EMD_DETAIL_TRXDATE,
                            petr.justification             as EMD_DETAIL_JUSTIFICATION,
                            petr.cust_trx_number           as EMD_DETAIL_TRX_NO,
                            paha.emd_type                  as EMD_TYPE,
                            cc.masked_cc_number            as EMD_DETAIL_CRE_NO,
                            petr.payment_type_code         as EMD_PAYMENT_TYPE_CODE,
                            petr.CHEQUE_NUMBER             as EMD_CHEQUE_NUM,
                            petr.bank_account_num          as EMD_REC_BANK_ACCOUNT_NUM,
                            petr.CASH_BEARER_NAME          as EMD_CASH_BEARER_NAME,
                            petr.DEMAND_DRAFT_NUM          as EMD_DEMAND_DRAFT_NUM,
                            petr.PAYABLE_AT                as EMD_PAYABLE_AT,
                            petr.BANK_GURANTEE_NUMBER      as EMD_BANK_GUR_NUM,
                            petr.In_Favor_Of               as EMD_IN_FAVOR_OF,
                            petr.NAME_ON_CARD              as EMD_CARD_HOLDER_NAME,
                            petr.EXPIRY_DATE               as EMD_EXPIRATION_DATE,
                            petr.TYPE_OF_CARD              as EMD_TYPE_OF_CARD,
                            flv.meaning                    as EMD_DETAIL_PAYTYPE,
                            petr.emd_transaction_id        as TRX_ID
                       from pon_emd_transactions petr,
                            fnd_lookup_values    flv,
                            IBY_CREDITCARD       cc
                       where petr.auction_header_id = p_auction_header_id
                        and  petr.supplier_sequence = p_supplier_sequence
                        and  petr.status_lookup_code = 'RECEIVED'
                        and  cc.CARD_OWNER_ID(+) = petr.card_owner_id
                        and  cc.CARD_ISSUER_CODE(+) = petr.CARD_ISSUER_CODE
                        and  cc.CHNAME(+) = petr.NAME_ON_CARD
                        and  cc.CCNUMBER(+) = petr.credit_card_num
                        and  flv.lookup_type(+) = 'PON_EMD_PAYMENT_METHOD'
                        and  flv.language(+) = USERENV('LANG')
                        and  flv.LOOKUP_CODE(+) = petr.Payment_Type_Code
                    order by TRX_ID) as EMD_DETAILS,
      --End: Added by Chaoqun on 20-Mar-2009

      --Begin: Deleted by Chaoqun on 19-Mar-2009
             /*cursor (select decode(petr.status_lookup_code,
                                   'RECEIVED','Y',
                                   'N')                    as EMD_RECEIVED_FLAG,
                            petr.status_lookup_code        as EMD_DETAIL_STATUS,
                            petr.bank_name                 as EMD_DETAIL_BANKNAME,
                            petr.bank_branch_name          as EMD_DETAIL_BRANCHNAME,
                            petr.bank_account_num          as EMD_DETAIL_ACCOUNTNO,
                            petr.transaction_currency_code as EMD_DETAIL_CURRENCY,
                            petr.amount                    as EMD_DETAIL_AMOUNT,
                            petr.TRANSACTION_DATE          as EMD_DETAIL_TRXDATE,
                            petr.Payment_Type_Code         as EMD_DETAIL_PAYTYPE,
                            petr.justification             as EMD_DETAIL_JUSTIFICATION,
                            petr.document_number           as EMD_DETAIL_DOC_NO,
                            petr.cust_trx_number           as EMD_DETAIL_TRX_NO,
                            petr.credit_card_num           as EMD_DETAIL_CRE_NO,
                            petr.emd_transaction_id as TRX_ID
                       from pon_emd_transactions petr
                       where petr.auction_header_id = p_auction_header_id
                        and petr.supplier_sequence= p_supplier_sequence
                        and (petr.status_lookup_code = 'RECEIVED'
                          or petr.status_lookup_code = 'RECEIVE_ERROR'
                          or petr.status_lookup_code = 'RECEIVING'
                         )
                      ) as EMD_DETAILS,*/
     --End: Deleted by Chaoqun on 19-Mar-2009

             cursor (select message_name, message_text
                       from fnd_new_messages
                      where message_name in
                            ('PON_EMD_NEGOTIATION_NO',
                             'PON_EMD_NEGOTIATION_TITLE',
                             'PON_EMD_SUPPLIER_NAME', 'PON_EMD_SUPPLIER_SITE',
                             'PON_EMD_AMOUNT', 'PON_EMD_DUE_DATE',
                             'PON_EMD_TYPE', 'PON_EMD_GUARANTEE_EXPIRY_DATE',
                             'PON_EMD_QUOTE_CURRENCY',
                             'PON_EMD_CURRENT_STATUS', 'PON_EMD_SUMMARY',
                             'PON_EMD_PAYMENT_DETAILS', 'PON_EMD_EXEMPTED',
                             'PON_EMD_RECEIVED', 'PON_EMD_RECEIVED_AMOUNT',
                             'PON_EMD_RECEIVED_DATE', 'PON_EMD_RECEIVED_CURRENCY',
                             'PON_EMD_BANK_NAME', 'PON_EMD_BRANCH_NAME',
                             'PON_EMD_DETAIL_BANK_ACCOUNT',
                             'PON_EMD_PAYMENT_TYPE', 'PON_EMD_CURRENCY',
                             'PON_EMD_PAYMENT_DATE', 'PON_EMD_DETAIL_AMOUNT',
                              --Added by Chaoqun on 19-Mar-2008
                             'PON_EMD_CHEQUE_NUM','PON_EMD_CASH_BEARER_NAME',
                             'PON_EMD_DEMAND_DRAFT_NUM', 'PON_EMD_PAYABLE_AT' ,
                             'PON_EMD_BANK_GUR_NUM','PON_EMD_IN_FAVOR_OF',
                             'PON_EMD_CARD_HOLDER_NAME','PON_EMD_EXPIRATION_DATE',
                             'PON_EMD_TYPE_OF_CARD', 'PON_EMD_REC_TRAN_NUM',
                             'PON_EMD_REC_REC_NUM', 'PON_EMD_CREDIT_CARD_NUM',
                             'PON_EMD_CREATED_BY', 'PON_EMD_PAY_REC_BY',
                             ---------------------------------
                             'PON_EMD_RECEIPT_HEADING' --Added by Chaoqun on 16-Apr-2009 for UI Change
                             )
                        and application_id = 396
                        and language_code = l_printing_language) as GENERIC_MESSAGES
        from pon_auction_headers_all paha,
             pon_emd_transactions    petr,
             pon_bidding_parties     pbp,
             fnd_lookup_values            flv,
            HR_ALL_ORGANIZATION_UNITS_TL ou,
            pon_auc_doctypes             doc,
            fnd_lookups                  f1,
             HZ_PARTIES hz
       where paha.auction_header_id = p_auction_header_id
         and petr.auction_header_id = paha.auction_header_id
         and petr.supplier_sequence = p_supplier_sequence
         and pbp.auction_header_id = paha.auction_header_id
         and pbp.sequence = petr.supplier_sequence
         --Begin: Added by Chaoqun on 19-Mar-2009
         and petr.status_lookup_code = 'RECEIVED'
         and flv.lookup_type(+) = 'PON_AUCTION_EMD_TYPE'
         and flv.language(+) = USERENV('LANG')
         and flv.LOOKUP_CODE(+) = paha.EMD_TYPE
         --End: Added by Chaoqun on 19-Mar-2009
         and ou.ORGANIZATION_ID = paha.org_id
         and ou.language = userenv('lang')
         and doc.doctype_id = paha.doctype_id
         and f1.lookup_type = 'PON_AUCTION_DOC_TYPES'
         and f1.lookup_code = doc.internal_name
         and hz.party_id(+) = paha.trading_partner_contact_id;

    dbms_lob.createtemporary(result, TRUE);

    SELECT CURRENT_DATE INTO l_start_time FROM DUAL;

    xml_stmt := 'DECLARE
       queryCtx DBMS_XMLGEN.ctxHandle;
       BEGIN
        queryCtx := DBMS_XMLGEN.newContext(:xml_query_cursor);
        DBMS_XMLGEN.getXML(queryCtx, :result, DBMS_XMLGEN.NONE);
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
          END;';
    execute immediate xml_stmt
      USING IN OUT xml_query_cursor, IN OUT result;

    SELECT CURRENT_DATE INTO l_end_time FROM DUAL;

    CLOSE xml_query_cursor;

    IF l_statement_log_level >= l_current_log_level THEN
      FND_LOG.string(l_statement_log_level,
                     l_module_name,
                     'PDF: generating XML time: ' ||
                     (l_end_time - l_start_time) * 24 * 60 * 60);
    END IF;

    return result;
  END generate_receipt_xml;

  -------------------------------------------------------------------------------
  -- If p_bid_number > 0 , Creates a xml file for the bid number and returns   --
  -- it as a clob. If p_bid_number <= 0, creates a xml file for the auction id --
  -------------------------------------------------------------------------------
  FUNCTION generate_auction_xml(p_auction_header_id          IN NUMBER,
                                p_client_time_zone           IN VARCHAR2,
                                p_server_time_zone           IN VARCHAR2,
                                p_date_format                IN VARCHAR2,
                                p_trading_partner_id         IN NUMBER,
                                p_trading_partner_name       IN VARCHAR2,
                                p_vendor_site_id             IN NUMBER,
                                p_user_view_type             IN VARCHAR2,
                                p_printing_warning_flag      IN VARCHAR2  DEFAULT 'N',
                                p_neg_printed_with_contracts IN VARCHAR2  DEFAULT 'N',
                                p_requested_supplier_id      IN NUMBER,
                                p_requested_supplier_name    IN VARCHAR2,
				p_trading_partner_contact_id IN NUMBER,
                                p_bid_number                 IN NUMBER,
                                p_user_id                    IN NUMBER)
  RETURN CLOB IS
     result CLOB;
     l_suffix        varchar2(2);
     l_resultOffset  number;
		 l_xml_header varchar2(100);
		 l_xml_header_length number;
     TYPE auction_header_cursor_type IS REF CURSOR;
     xml_query_cursor auction_header_cursor_type;

     queryCtx DBMS_XMLGEN.ctxHandle;

     attachments_cursor auction_header_cursor_type;
     doc_rules_cursor auction_header_cursor_type;
     generic_msgs_cursor auction_header_cursor_type;
     doc_msgs_cursor auction_header_cursor_type;
     lines_cursor auction_header_cursor_type;
     collab_team_cursor auction_header_cursor_type;
     scoring_team_cursor auction_header_cursor_type;
     scoring_mems_cursor auction_header_cursor_type;
     scoring_secs_cursor auction_header_cursor_type;
     abstracts_cursor auction_header_cursor_type;
     currency_cursor auction_header_cursor_type;
     invited_supp_cur_cursor auction_header_cursor_type;
     header_attr_cursor auction_header_cursor_type;
     invited_supp_cursor auction_header_cursor_type;
     line_attr_cursor auction_header_cursor_type;
     line_attr_score_cursor auction_header_cursor_type;
     pf_cursor auction_header_cursor_type;
     line_pf_cursor auction_header_cursor_type;
     buyer_pf_cursor auction_header_cursor_type;
     dist_buyer_pf_cursor auction_header_cursor_type;
     large_neg_bur_pf_cursor auction_header_cursor_type;
     item_pb_cursor auction_header_cursor_type;
     item_quan_cursor auction_header_cursor_type;
     pay_items_cursor auction_header_cursor_type;
     pb_loc_cursor auction_header_cursor_type;
     line_price_diff_cursor auction_header_cursor_type;
     item_price_diff_cursor auction_header_cursor_type;
     price_diff_types_cursor auction_header_cursor_type;


     xml_clob CLOB;

     xml_res XMLType;
     attachments_res XMLType;
     doc_rules_res XMLType;
     generic_msgs_res XMLType;
     doc_msgs_res XMLType;
     lines_res XMLType;
     collab_team_res XMLType;
     scoring_team_res XMLType;
     scoring_mems_res XMLType;
     scoring_secs_res XMLType;
     abstracts_res XMLType;
     currency_res XMLType;
     invited_supp_cur_res XMLType;
     header_attr_res XMLType;
     invited_supp_res XMLType;
     line_attr_res XMLType;
     line_attr_score_res XMLType;
     pf_res XMLType;
     line_pf_res XMLType;
     buyer_pf_res XMLType;
     dist_buyer_pf_res XMLType;
     large_neg_bur_pf_res XMLType;
     item_pb_res XMLType;
     item_quan_res XMLType;
     pay_items_res XMLType;
     pb_loc_res XMLType;
     line_price_diff_res XMLType;
     item_price_diff_res XMLType;
     price_diff_types_res XMLType;

     res CLOB;

     xml_stmt varchar2(500);
     l_neg_tp_id pon_auction_headers_all.trading_partner_id%type;
     l_doc_type_id pon_auction_headers_all.DOCTYPE_ID%TYPE;
     l_doc_type VARCHAR2(50);
     l_currency_code pon_auction_headers_all.currency_code%type;
     l_price_precision  pon_auction_headers_all.number_price_decimals%type;
     l_price_mask  varchar2(80); -- mask based on the negotiation price precision
     l_amount_mask varchar2(80); -- mask based on the negotiation currency precision

     l_contracts_installed VARCHAR2(1);
     l_cont_attach_doc_flag VARCHAR2(1);
     l_cont_nonmerge_flag VARCHAR2(1);
     l_printing_language VARCHAR2(3);
     l_supplier_sequence_number NUMBER;
     l_award_approval_enabled VARCHAR2(1);
     l_neg_has_price_breaks VARCHAR2(1);

     l_start_time DATE;
     l_end_time DATE;
     l_current_log_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
     l_module_name VARCHAR2(80) := 'pon.plsql.PON_PRINTING_PKG.GENERATE_AUCTION_XML';


     l_enfrc_prevrnd_bid_price_flag   pon_auction_headers_all.enforce_prevrnd_bid_price_flag%TYPE;
     l_auction_header_id_prev_round   pon_auction_headers_all.auction_header_id_prev_round%TYPE;
     l_start_price_from_prev_rnd  	  VARCHAR2(1);
     l_prev_rnd_bid_number            pon_bid_headers.bid_number%TYPE;
     l_contract_type 				  pon_auction_headers_all.contract_type%TYPE;
     l_supplier_view_type             pon_auction_headers_all.supplier_view_type%TYPE;
     l_pf_type_allowed                pon_auction_headers_all.pf_type_allowed%TYPE;

     --bidpdf:
     l_is_bidpdf VARCHAR2(1) := 'Y';
     l_is_supplier_bidpdf VARCHAR2(1) := 'N';
     l_is_buyer_negpdf VARCHAR2(1) := 'N';

     l_bid_currency_code pon_bid_headers.bid_currency_code%type;
     l_bid_price_precision  pon_bid_headers.number_price_decimals%type;
     -- bidpdf: address of supplier:
     l_supplier_address_line1 hz_parties.address1%type;
     l_supplier_address_line2 hz_parties.address2%type;
     l_supplier_address_line3 hz_parties.address3%type;
     l_supplier_address_city hz_parties.city%type;
     l_supplier_address_state hz_parties.state%type;
     l_supplier_postal_code hz_parties.postal_code%type;
     l_supplier_country_code hz_parties.country%type;
     l_supplier_country fnd_territories_tl.territory_short_name%type;
     l_vendor_site_id NUMBER;
     l_vendor_id NUMBER;
     -- bidpdf: contact details:
     l_contact_details_name varchar2(600);
     l_trading_partner_id NUMBER := p_trading_partner_id;
     -- bidpdf: on buyer side, check whether buyer in scoring team that cannot see price
     l_price_visibility VARCHAR2(1) := 'Y';
     l_is_section_restricted VARCHAR2(1) := 'N';
     l_proxybid_display_flag VARCHAR2(1) := 'N';
     -- bidpdf: currency change rate
     l_rate NUMBER := 1;
     l_bid_rate NUMBER := 1;
     l_is_super_large_neg VARCHAR2(1) := 'N';
     -- previous round doc type, used to decide whether to display
     -- control "enforce supplie's previous round price as bid start price"
     l_prev_rnd_doctype pon_auc_doctypes.internal_name%TYPE;
     -- two-part RFQ
     l_hide_comm_part VARCHAR2(1) := 'N';
     l_two_part_flag pon_auction_headers_all.two_part_flag%TYPE;	-- two-part flag
     -- commercial lock status
     l_commercial_lock_status pon_auction_headers_all.sealed_auction_status%TYPE;
	-- technical shortlist status
     l_tech_shortlist_flag pon_bid_headers.technical_shortlist_flag%type;
     --added by Allen Yang for Surrogate Bid 2008/09/04
     ---------------------------------------------------------------
     l_tech_evaluation_status PON_AUCTION_HEADERS_ALL.Technical_Evaluation_Status%TYPE;
     l_surrogate_bid_flag     PON_BID_HEADERS.Surrog_Bid_Flag%TYPE;
     CURSOR tech_surrogate_bid_cur IS
       SELECT
         paha.Technical_Evaluation_Status
       , pbh.SURROG_BID_FLAG
       FROM
         pon_auction_headers_all paha, pon_bid_headers pbh
       WHERE paha.auction_header_id=pbh.auction_header_id
         AND paha.auction_header_id=p_auction_header_id
         AND pbh.bid_number = p_bid_number;
     ----------------------------------------------------------------

     -- used to set what categories are shown in quote pdf.
     -- this option can have 3 values:
     -- 1 	(`FromSupplier')
     -- 2  	(`FromSupplierTechnical')
     -- 3  	(`FromSupplierTechnical', `FromSupplierCommercial')
     l_attach_categ_option NUMBER := 1;

     -- three variables to store two-part messages.
     l_two_part_general_msg	fnd_new_messages.message_text%TYPE;
     l_two_part_tech_msg	fnd_new_messages.message_text%TYPE;
     l_two_part_comm_msg	fnd_new_messages.message_text%TYPE;

     linesCtx DBMS_XMLGEN.ctxHandle;
     attrsCtx DBMS_XMLGEN.ctxHandle;
     payItemsCtx DBMS_XMLGEN.ctxHandle;
     linepdiffCtx DBMS_XMLGEN.ctxHandle;
     itempbreaksCtx DBMS_XMLGEN.ctxHandle;
     itempdiffsCtx DBMS_XMLGEN.ctxHandle;
     quanTiersCtx DBMS_XMLGEN.ctxHandle;
     pfCtx DBMS_XMLGEN.ctxHandle;
     attrsScoreCtx DBMS_XMLGEN.ctxHandle;

     --Bug 18953351
     --ORDER BY disp_line_number was not there
     --Hence the lines were shown in wrong order
     CURSOR line_num_cur IS SELECT line_number FROM pon_auction_item_prices_all WHERE auction_header_id = p_auction_header_id ORDER BY disp_line_number;
     line_num NUMBER;

  BEGIN
  IF p_bid_number <= 0 THEN
    l_is_bidpdf := 'N';
  ELSE
    l_is_bidpdf := 'Y';
    BEGIN
      select
           bid_currency_code,
           number_price_decimals,
           vendor_site_id,
           vendor_id,
           trading_partner_id,
           rate,
	   technical_shortlist_flag
      into
           l_bid_currency_code,
           l_bid_price_precision,
           l_vendor_site_id,
           l_vendor_id,
           l_trading_partner_id,
           l_bid_rate,
	   l_tech_shortlist_flag
      from pon_bid_headers
      where bid_number = p_bid_number;
    EXCEPTION
      WHEN no_data_found THEN
        l_is_bidpdf := 'N';
    END;
  END IF;
  select
    trading_partner_id,
    doctype_id,
    currency_code,
    number_price_decimals,
    enforce_prevrnd_bid_price_flag,
    auction_header_id_prev_round,
    contract_type,
    supplier_view_type,
    pf_type_allowed,
    nvl(two_part_flag, 'N'),
    nvl(sealed_auction_status,' ')
  into
    l_neg_tp_id,
    l_doc_type_id,
    l_currency_code,
    l_price_precision,
    l_enfrc_prevrnd_bid_price_flag,
    l_auction_header_id_prev_round,
    l_contract_type,
    l_supplier_view_type,
    l_pf_type_allowed,
    l_two_part_flag,
    l_commercial_lock_status
  from pon_auction_headers_all
  where auction_header_id = p_auction_header_id;

  IF l_auction_header_id_prev_round IS NOT NULL
  THEN
    BEGIN
       SELECT doctypes.internal_name
         INTO l_prev_rnd_doctype
         FROM pon_auction_headers_all pah, pon_auc_doctypes doctypes
        WHERE pah.auction_header_id  =  l_auction_header_id_prev_round
              and pah.doctype_id = doctypes.doctype_id;
    EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
          l_prev_rnd_doctype := '';
    END;
  END IF;

  IF l_statement_log_level >= l_current_log_level THEN
    FND_LOG.string(l_statement_log_level, l_module_name, 'Two-Part related variables: l_two_part_flag: ' || l_two_part_flag || '; l_commercial_lock_status: '||l_commercial_lock_status);
  END IF;

  l_printing_language := userenv('lang') ;

  if (PON_LARGE_AUCTION_UTIL_PKG.is_super_large_neg(p_auction_header_id)) then
    l_is_super_large_neg := 'Y';
  else
    l_is_super_large_neg := 'N';
  end if;

 -- bidpdf: get address and contact name
 -- If the negotiation did not invite any supplier, get the company address
 -- Otherwise, get the site address
  IF l_is_bidpdf = 'Y' THEN

    IF p_user_view_type = 'SUPPLIER' THEN
      l_is_supplier_bidpdf := 'Y';
      l_currency_code := l_bid_currency_code;
      l_price_precision := l_bid_price_precision;
      l_rate := l_bid_rate;
    ELSE
      l_price_visibility := is_price_visible(p_auction_header_id, p_user_id);
      --To decide whether need to check which sections in requirement should be displayed
      --As in ViewBidCO, hasScoringTeamsFlag  !isScoringLocked isScorer
      BEGIN
      SELECT 'Y'
      INTO l_is_section_restricted
      FROM   pon_neg_team_members pntm, pon_auction_headers_all pah
      WHERE pah.auction_header_id = p_auction_header_id
      AND pntm.menu_name = 'PON_SOURCING_SCORENEG'
      AND pntm.auction_header_id = pah.auction_header_id
      AND pntm.user_id = p_user_id
      AND pah.has_scoring_teams_flag = 'Y'
      AND pah.scoring_lock_date is null;
      EXCEPTION
        WHEN NO_DATA_FOUND then
         l_is_section_restricted := 'N';
      END;
    END IF;

    IF l_vendor_site_id <= 0 THEN
     BEGIN
    -- bidpdf: address/contact of supplier company
     select hz_parties.address1, hz_parties.address2, hz_parties.address3, hz_parties.city, hz_parties.state, hz_parties.postal_code, hz_parties.country, nvl(entity_terr.territory_short_name,hz_parties.country)
        ,PON_LOCALE_PKG.get_party_display_name(pon_bid_headers.trading_partner_contact_id)
     into l_supplier_address_line1,l_supplier_address_line2,l_supplier_address_line3,l_supplier_address_city,l_supplier_address_state,l_supplier_postal_code,l_supplier_country_code,l_supplier_country
        ,l_contact_details_name
     from hz_parties, pon_bid_headers, fnd_territories_tl entity_terr
     where pon_bid_headers.trading_partner_id = hz_parties.party_id
     	and pon_bid_headers.bid_number = p_bid_number
     	and entity_terr.territory_code(+) = hz_parties.country
	and entity_terr.territory_code(+) NOT IN ('ZR','FX','LX')
        and entity_terr.language(+) = l_printing_language
        and rownum = 1;
     EXCEPTION
        WHEN no_data_found THEN
           l_supplier_address_line1 := '';
     END;
    ELSE
     BEGIN
      -- get supplier site address/contact, reference from java/poplist/server/VendorSitesAllVO.xml
      SELECT pvsa.address_line1,pvsa.address_line2,pvsa.address_line3,pvsa.city,pvsa.state,pvsa.zip,pvsa.country, nvl(entity_terr.territory_short_name,pvsa.country),
        decode(pbp.trading_partner_contact_id, null, pbp.requested_supp_contact_name, PON_LOCALE_PKG.get_party_display_name(pbp.trading_partner_contact_id)) contact_name
      into l_supplier_address_line1,l_supplier_address_line2,l_supplier_address_line3,l_supplier_address_city,l_supplier_address_state,l_supplier_postal_code,l_supplier_country_code,l_supplier_country,l_contact_details_name
      FROM PO_VENDOR_SITES_ALL pvsa, pon_auction_headers_all pah, pon_bidding_parties pbp, fnd_territories_tl entity_terr
      WHERE
        pah.auction_header_id = p_auction_header_id
        AND pvsa.org_id = pah.org_id
        AND PURCHASING_SITE_FLAG = 'Y'
        AND SYSDATE< NVL(INACTIVE_DATE, SYSDATE + 1)
        AND vendor_id=l_vendor_id
        AND nvl(rfq_only_site_flag, 'N')='N'
        AND pvsa.vendor_site_id = l_vendor_site_id
        AND pbp.auction_header_id = pah.auction_header_id
        AND pbp.vendor_site_id = pvsa.vendor_site_id
     	and entity_terr.territory_code(+) = pvsa.country
	and entity_terr.territory_code(+) NOT IN ('ZR','FX','LX')
        and entity_terr.language(+) = l_printing_language
        and rownum = 1;
     EXCEPTION
           WHEN no_data_found THEN
           l_supplier_address_line1 := '';
     END;
    END IF;
  ELSIF p_user_view_type = 'BUYER' THEN
      l_is_buyer_negpdf := 'Y';
  END IF;
    --dbms_application_info.set_client_info(204);
  SET_AUCTION_MASKS(l_currency_code, l_price_precision, l_price_mask, l_amount_mask);

  l_suffix := GET_SUFFIX_FOR_MESSAGES(p_auction_header_id);

  -- determine if there are price breaks
  BEGIN
    SELECT 'Y'
    INTO l_neg_has_price_breaks
    FROM pon_auction_shipments_all
    WHERE auction_header_id = p_auction_header_id
      AND ROWNUM = 1;
  EXCEPTION
    WHEN no_data_found THEN
      l_neg_has_price_breaks := 'N';
  END;

  -- bidpdf: add l_is_bidpdf='Y' for case when on buyer side, the buyer cost factor values
  -- can be displayed. If not added,  pf_values.value in cursor PRICE_FACTORS will be null
  -- because of condition pf_values.supplier_seq_number(+) = l_supplier_sequence_number
  IF (p_user_view_type = 'SUPPLIER' or l_is_bidpdf='Y') AND (l_trading_partner_id IS NOT NULL
        OR p_requested_supplier_id IS NOT NULL) THEN
    BEGIN
      SELECT sequence
      INTO l_supplier_sequence_number
      FROM pon_bidding_parties
      WHERE
            auction_header_id = p_auction_header_id
        AND ((trading_partner_id = l_trading_partner_id AND
              vendor_site_id = p_vendor_site_id) OR
             requested_supplier_id = p_requested_supplier_id);
    EXCEPTION
      WHEN no_data_found THEN
        l_supplier_sequence_number := NULL;
    END;
  ELSE
    l_supplier_sequence_number := NULL;
  END IF;

  l_award_approval_enabled := fnd_profile.value('PON_AWARD_APPROVAL_ENABLED');
  l_contracts_installed := fnd_profile.value('POC_ENABLED');

  --We do not want the warning about attached document in case the user does not
  --have privilege to view contract terms
  if (p_printing_warning_flag = 'Y' OR nvl(l_contracts_installed, 'N') = 'N') then
    l_cont_attach_doc_flag := 'N';
  else
    l_doc_type := PON_CONTERMS_UTL_PVT.get_negotiation_doc_type(l_doc_type_id);
    if (PON_CONTERMS_UTL_PVT.isDocumentMergeable(l_doc_type, to_number(p_auction_header_id)) = 'N') then
      l_cont_nonmerge_flag := 'Y';
    else
      l_cont_nonmerge_flag := 'N';
    end if;

    if (PON_CONTERMS_UTL_PVT.isAttachedDocument (l_doc_type, to_number(p_auction_header_id)) = 'Y') then
      l_cont_attach_doc_flag := 'Y';
    else
      l_cont_attach_doc_flag := 'N';
    end if;
  end if;

  -- If the Enforce previous round flag is set, then there may be a
  -- change to the way the start price is displayed
  -- Rules:
  -- Show start price from the negotiation if:
  --   : this is a buyer
  --   : this is a supplier who does not have a bid in the previous round
  -- If the supplier has a bid in the previous round and the flag is
  -- set, then
  -- Start price = Previous round active bid line price
  --                   + effect of previous round supplier price factors
  --                   + effect of current round buyer price factors
  -- Since it will not be possible or performant to determine this for
  -- every line, we will call a PL/SQL function. In order to save the
  -- function the trouble of determining information common to every
  -- row, we will derive the necessary parameters here and pass it in

  l_start_price_from_prev_rnd := 'N';


  IF (l_is_buyer_negpdf = 'N')  AND
     l_auction_header_id_prev_round IS NOT NULL    AND
     l_enfrc_prevrnd_bid_price_flag = 'Y'          AND
     p_trading_partner_id           IS NOT NULL              AND
     p_trading_partner_contact_id   IS NOT NULL --{
  THEN
   -- Check if the supplier had an active bid in the previous round

    BEGIN
       SELECT pbh.bid_number
         INTO l_prev_rnd_bid_number
         FROM pon_bid_headers pbh
        WHERE pbh.auction_header_id  =  l_auction_header_id_prev_round
          AND pbh.bid_status         = 'ACTIVE'
  	AND pbh.trading_partner_id = p_trading_partner_id
  	AND pbh.trading_partner_contact_id = p_trading_partner_contact_id
  	AND pbh.vendor_site_id             = p_vendor_site_id;

       l_start_price_from_prev_rnd := 'Y';

    EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
          l_start_price_from_prev_rnd := 'N';

    END;

  END IF;  -- }

  -- here the rules are checked to determine whether the commercial part is to be hidden
  -- check if it is a two-part RFQ, and that this is a bid pdf call.
  IF l_two_part_flag = 'Y' THEN -- {
	-- initially for two-part, need to show both attachment categories
	l_attach_categ_option := 3;

	IF l_is_bidpdf = 'Y' THEN -- {
	-- make sure it is not the bidder himself
		IF p_trading_partner_id <> l_trading_partner_id THEN -- {
			-- is it commercially unlocked (buyer view) or unsealed (supplier view)?
			IF (p_user_view_type = 'BUYER' and l_commercial_lock_status <> 'LOCKED')
				or (p_user_view_type = 'SUPPLIER' and l_commercial_lock_status = 'ACTIVE') THEN -- {

				-- since it is unlocked, check if bid is shortlisted
				IF l_tech_shortlist_flag <> 'Y' THEN -- {
					-- hide commercial part
					l_hide_comm_part := 'Y';
					-- show only technical attachments
					l_attach_categ_option := 2;
				END IF; -- }
			ELSE
				-- it is commercially locked, hide commercial part
				l_hide_comm_part := 'Y';
				-- show technical attachments
				l_attach_categ_option := 2;
			END IF; -- }
		END IF; -- }
    --added by Allen Yang for Surrogate Bid 2008/09/04
    --------------------------------------------------
    BEGIN
      OPEN tech_surrogate_bid_cur;
      FETCH
        tech_surrogate_bid_cur
      INTO
        l_tech_evaluation_status
      , l_surrogate_bid_flag;
      IF (l_tech_evaluation_status = 'NOT_COMPLETED' AND
         l_surrogate_bid_flag = 'Y' AND
         l_two_part_flag = 'Y')
      THEN
	      l_hide_comm_part := 'Y';
	      l_attach_categ_option :=2;
      END IF;
      CLOSE tech_surrogate_bid_cur;
    END;
    --------------------------------------------------
	END IF; -- }
  END IF; -- }

  IF l_statement_log_level >= l_current_log_level THEN
    FND_LOG.string(l_statement_log_level, l_module_name, 'Two-Part related variables: l_hide_comm_part: '||l_hide_comm_part||';  l_attach_categ_option: '|| l_attach_categ_option);
  END IF;

  -- Two-Part project (adsahay): fetch messages into variables, this is much more efficient than getting them in the query.
  l_two_part_general_msg := pon_printing_pkg.get_messages('PON_TWO_PART_INFO','TECHNICAL',pon_auction_pkg.get_technical_meaning, 'COMMERCIAL',pon_auction_pkg.get_commercial_meaning);
  l_two_part_tech_msg := pon_printing_pkg.get_messages('PON_TWO_PART_SECTION','PART',pon_auction_pkg.get_technical_meaning);
  l_two_part_comm_msg := pon_printing_pkg.get_messages('PON_TWO_PART_SECTION','PART',pon_auction_pkg.get_commercial_meaning);

--Fix for bug 12655380
--Splitting the cursor query and concatenating the xmls from each query to reduce sharable memory usage
  OPEN xml_query_cursor FOR
  SELECT
PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(pah.auction_header_id) is_slm_doc,
pah.auction_header_id,
pah.auction_title,
pah.auction_status,
pah.auction_status_name,
pah.auction_type,
pah.contract_type,
pah.trading_partner_contact_name,
pah.trading_partner_contact_id,
pah.trading_partner_name,
pah.trading_partner_name_upper,
nvl(pah.two_part_flag,'N') two_part_flag,
l_hide_comm_part hide_comm_part,
l_is_super_large_neg is_super_large_neg,
pah.proxy_bidding_enabled_flag,
PON_LOCALE_PKG.GET_PARTY_DISPLAY_NAME(pah.trading_partner_contact_id) auctioneer_display_name,
pah.bill_to_location_id,
bill_territories_tl.territory_short_name bill_country_name,
loc_bill.location_code bill_address_name,
loc_bill.address_line_1 bill_address1,
loc_bill.address_line_2 bill_address2,
loc_bill.address_line_3 bill_address3,
loc_bill.town_or_city bill_city,
loc_bill.region_2 bill_state,
loc_bill.region_3 bill_province_or_region,
loc_bill.postal_code bill_zip_code,
loc_bill.postal_code bill_postal_code,
loc_bill.country bill_country,
loc_bill.region_1 bill_county,
pah.ship_to_location_id,
ship_territories_tl.territory_short_name ship_country_name,
loc_ship.location_code ship_address_name,
loc_ship.address_line_1 ship_address1,
loc_ship.address_line_2 ship_address2,
loc_ship.address_line_3 ship_address3,
loc_ship.town_or_city ship_city,
loc_ship.region_2 ship_state,
loc_ship.region_3 ship_province_or_region,
loc_ship.postal_code ship_zip_code,
loc_ship.postal_code ship_postal_code,
loc_ship.country ship_country,
loc_ship.region_1 ship_county,
entitytl.name entity,
entity_loc.style entity_address_style,
entity_loc.address_line_1 entity_address_line_1,
entity_loc.address_line_2 entity_address_line_2,
entity_loc.address_line_3 entity_address_line_3,
entity_loc.town_or_city entity_city,
entity_loc.postal_code entity_postal_code,
nvl(entity_terr.territory_short_name, entity_loc.country) entity_country,
entity_loc.country entity_country_code,
entity_loc.region_1 entity_region_1,
entity_loc.region_2 entity_region_2,
entity_loc.region_3 entity_region_3,
pon_oa_util_pkg.display_date_time(pah.open_bidding_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') open_bidding_date,
pon_oa_util_pkg.display_date_time(pah.close_bidding_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') close_bidding_date,
pon_oa_util_pkg.display_date_time(pah.original_close_bidding_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') original_close_bidding_date,
pon_oa_util_pkg.display_date_time(pah.view_by_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') view_by_date,
pon_oa_util_pkg.display_date_time(pah.award_by_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') award_by_date,
pon_oa_util_pkg.display_date_time(pah.publish_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') publish_date,
pon_oa_util_pkg.display_date_time(pah.close_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') close_date,
pon_oa_util_pkg.display_date_time(pah.cancel_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') cancel_date,
pah.time_zone,
pon_auction_pkg.get_timezone_description(p_client_time_zone,l_printing_language) display_time_zone,
pah.open_auction_now_flag,
pah.publish_auction_now_flag,
fl.meaning pon_bid_visibility_display,
pah.bid_visibility_code,
pah.bid_list_type,
pah.bid_frequency_code,
pah.bid_scope_code,
pah.auto_extend_flag,
pah.auto_extend_min_trigger_rank,
pah.auto_extend_number,
pah.auto_extend_enabled_flag,
pah.number_of_extensions,
pah.min_bid_decrement,
decode(pah.min_bid_change_type, 'PERCENTAGE', pon_printing_pkg.format_number(pah.min_bid_decrement), pon_printing_pkg.format_price(pah.min_bid_decrement*l_rate, l_price_mask, l_price_precision)) min_bid_decrement_disp,
pah.price_driven_auction_flag,
pah.payment_terms_id,
ap.name payment_terms,
pah.freight_terms_code,
fl_freight_terms.meaning freight_terms,
pah.fob_code,
fl_fob.meaning fob,
pah.carrier_code,
pah.currency_code,
l_currency_code l_currency_code,
pon_printing_pkg.get_carrier_description(pah.org_id,pah.carrier_code) carrier,
currency_tl.name currency_name,
-- bidpdf: whether this is for a bid pdf
l_is_bidpdf is_bidpdf,
l_price_visibility price_visibility,
pah.rate_type,
pah.rate_date,
pah.rate,
pah.note_to_bidders,
pah.attachment_flag,
pah.language_code,
pah.auto_extend_all_lines_flag,
pah.min_bid_increment,
pah.allow_other_bid_currency_flag,
pah.shipping_terms_code,
pah.shipping_terms,
pah.auto_extend_duration,
pah.proxy_bid_allowed_flag,
pah.publish_rates_to_bidders_flag,
pah.attributes_exist,
pah.order_number,
pah.event_title,
pah.sealed_auction_status,
pah.sealed_actual_unlock_date,
pah.sealed_actual_unseal_date,
pah.mode_of_transport,
pah.mode_of_transport_code,
pon_oa_util_pkg.display_date(pah.po_start_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') po_start_date,
pon_oa_util_pkg.display_date(pah.po_end_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') po_end_date,
to_char(pah.po_agreed_amount*l_rate, l_amount_mask) po_agreed_amount,
pah.min_bid_change_type,
pah.full_quantity_bid_code,
pah.number_price_decimals,
pah.auto_extend_type_flag,
pah.auction_origination_code,
pah.multiple_rounds_flag,
pah.auction_header_id_orig_round,
pah.auction_header_id_prev_round,
pah.auction_round_number,
pah.manual_close_flag,
pah.manual_extend_flag,
pah.autoextend_changed_flag,
pah.doctype_id,
pah.approval_required_flag,
pah.max_response_iterations,
pah.payment_terms_neg_flag,
pah.mode_of_transport_neg_flag,
pah.contract_id,
pah.contract_version_num,
pah.show_bidder_notes,
pah.derive_type,
pah.bid_ranking,
flbr.meaning bid_ranking_display,
pah.rank_indicator,
pah.show_bidder_scores,
pah.org_id,
pah.buyer_id,
pah.has_pe_for_all_items,
pah.has_price_elements,
to_char(pah.po_min_rel_amount*l_rate, l_amount_mask) po_min_rel_amount,
pah.global_agreement_flag,
pah.document_number,
pah.amendment_number ,
pah.amendment_description ,
pah.auction_header_id_orig_amend ,
pah.auction_header_id_prev_amend ,
pah.document_number ,
pah.hdr_attr_enable_weights ,
pah.hdr_attr_display_score ,
pah.hdr_attr_maximum_score ,
pah.attribute_line_number ,
pah.conterms_exist_flag ,
pah.award_mode ,
pah.has_hdr_attr_flag ,
nvl(pah.has_items_flag,'Y') has_items_flag,
decode(pah.staggered_closing_interval, null, 'N', 'Y') staggered_closing_enabled,
pah.staggered_closing_interval,
pon_oa_util_pkg.display_date_time(pah.first_line_close_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') first_line_close_date,
doctypes.internal_name,
l_prev_rnd_doctype prev_rnd_internal_name,
po_setup_s1.get_services_enabled_flag() is_services_enabled,
l_contracts_installed as is_contracts_installed,
p_printing_warning_flag print_warning_flag,
l_cont_attach_doc_flag contract_attached_doc,
l_cont_nonmerge_flag contract_non_mergeable,
p_neg_printed_with_contracts neg_printed_with_contracts,
pon_printing_pkg.get_messages('PON_AUCTS_START_CUR_PRICE','CURRENCY_CODE', l_currency_code) start_price_msg,
pon_printing_pkg.get_messages('PON_AUCTS_TARGET_PRICE_CURR','CURRENCY_CODE', l_currency_code) target_price_msg,
pon_printing_pkg.get_messages('PON_AUC_CURRENT_PRICE', 'AUCTION_CURRENCY', l_currency_code) current_price_msg,
pon_printing_pkg.get_messages('PON_AUCTS_MIN_RELEASE_CURR','AUCTION_CURRENCY', l_currency_code) min_release_amt_msg,
pon_printing_pkg.get_messages('PON_AUCTS_AGREEMENT_AMOUNT_CUR','CURRENCY', l_currency_code) agreement_amount_msg,
pon_printing_pkg.get_messages('PON_MAX_RTNGE_AMT_WITH_CURR','AUCTION_CURRENCY', l_currency_code) max_retainage_amt_curr_msg,
pon_printing_pkg.get_messages('PON_ADVANCE_AMT_WITH_CURR','AUCTION_CURRENCY', l_currency_code) advance_amount_curr_msg,
pon_printing_pkg.get_messages('PON_ESTIMATED_TOTAL_AMT_CURR','CURRENCY_CODE', l_currency_code) estimated_amt_msg,
--bug 7592494, call to get_legal_entity_name
pon_printing_pkg.get_messages('PON_AUC_PRN_LEGAL_CONSEQUENCES','LEGAL_ENTITY_NAME',pon_conterms_utl_pvt.GET_LEGAL_ENTITY_NAME(pah.org_id)) legal_consequences_msg,
pon_printing_pkg.get_messages('PON_AUC_INTERVAL_MIN','MINUTES',pah.staggered_closing_interval) stagger_auc_interval_min,
-- two-part project messages
l_two_part_general_msg two_part_general_info_msg,
l_two_part_tech_msg two_part_technical_msg,
l_two_part_comm_msg two_part_commercial_msg,
-- bidpdf: doc title and footer
decode(l_is_bidpdf, 'Y',
       get_messages('PON_BID_PRN_PAGE_HEADING'|| l_suffix,'DOCUMENT_NUMBER',pah.document_number,'BID_NUMBER',p_bid_number),  -- SLM UI Enhancement
       pon_printing_pkg.get_messages('PON_AUCTS_PRN_PAGE_HEADING' || l_suffix,'DOCUMENT_NUMBER',pah.document_number)  -- SLM UI Enhancement
) page_heading_msg,
pbhs.bid_status,
-- bidpdf: document type
doctypes.doctype_group_name,
-- bidpdf: response status
fl_bid.meaning response_status,
-- bidpdf: Response Valid Until
decode(pbhs.bid_expiration_date, null, '', pon_oa_util_pkg.display_date(pbhs.bid_expiration_date, p_client_time_zone, p_server_time_zone, p_date_format,'N')) response_valid_until,
-- bidpdf: supplier address
l_supplier_address_line1 supplier_address_line1,
l_supplier_address_line2 supplier_address_line2,
l_supplier_address_line3 supplier_address_line3,
l_supplier_address_city supplier_address_city,
l_supplier_address_state supplier_address_state,
l_supplier_postal_code supplier_postal_code,
l_supplier_country_code supplier_country_code,
l_supplier_country supplier_address_country,
-- bidpdf: supplier site:
pbhs.vendor_site_code,
-- bidpdf: supplier contact name:
l_contact_details_name contact_details_name,
pbhs.bid_currency_code bid_currency_selected,  --Response Currency
pbhs.bidders_bid_number reference_number,		--Reference Number
pbhs.note_to_auction_owner note_to_buyer,		--Note to Buyer
--bidpdf: Response Received Time value
pon_oa_util_pkg.display_date_time(pbhs.surrog_bid_receipt_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') bid_received_time,
pbhs.surrog_bid_flag surrog_bid_flag,			--Surrogate Bid Flag
pon_printing_pkg.get_user_email(hp1.party_id) email,
pah.abstract_details,
fl_security.meaning security_level,
pah.approval_status,
ps.display_name outcome,
nvl(gdct.description, gdct.user_conversion_type) rate_type_display,
pon_oa_util_pkg.display_date(pah.rate_date,
                             p_client_time_zone,
                             p_server_time_zone,
                             p_date_format, 'N') rate_date_display,
pah.award_approval_flag,
fl_rank_ind.meaning rank_indicator_display,
pah.pf_type_allowed,
fl_pf_type_allowed.meaning pf_type_allowed_display,
pah.supplier_view_type,
nvl2(pah.source_doc_msg_app, nvl2(pah.source_doc_msg, fnd_message.get_string(pah.source_doc_msg_app, pah.source_doc_msg), null), null) source_doc_msg_text,
nvl2(pah.source_doc_msg_app, nvl2(pah.source_doc_line_msg, fnd_message.get_string(pah.source_doc_msg_app, pah.source_doc_line_msg), null), null) source_doc_msg_line_text,
fpg.multi_org_flag,
p_user_view_type as user_view_type,
-- for bidpdf, the Company Name comes from pon_bid_headers.trading_partner_name
decode(l_is_bidpdf, 'Y', pbhs.trading_partner_name,decode(p_trading_partner_id, null, p_requested_supplier_name, p_trading_partner_name)) as user_trading_partner_name,
l_award_approval_enabled as award_approval_enabled,
ns.style_name,
pah.progress_payment_type,
pah.advance_negotiable_flag,
pah.recoupment_negotiable_flag,
pah.progress_pymt_negotiable_flag,
pah.retainage_negotiable_flag,
pah.max_retainage_negotiable_flag,
pah.supplier_enterable_pymt_flag,
pah.project_id sourcing_project_id,
pah.bid_decrement_method,
proj.segment1 sourcing_project_number,
DECODE(pah.contract_type, 'STANDARD', DECODE(progress_payment_type,'NONE','N','Y'),'N') complex_services_enabled,
postyl.advances_flag,
postyl.retainage_flag,
postyl.progress_payment_flag,
postyl.contract_financing_flag,
NVL((SELECT pdsv.enabled_flag FROM po_doc_style_values pdsv WHERE pdsv.style_id = pah.po_style_id AND pdsv.style_attribute_name = 'PAY_ITEM_TYPES' AND  pdsv.style_allowed_value = 'RATE'), 'N') rate_payments_allowed_flag,
pon_auction_pkg.GetPAOUInstalled(pah.org_id) projects_installed_flag,
pon_auction_pkg.GetGMSOUInstalled(pah.org_id)  grants_installed_flag,
pah.large_neg_enabled_flag,
pah.team_scoring_enabled_flag,
pah.has_scoring_teams_flag,
NVL(pah.enforce_prevrnd_bid_price_flag, 'N') enforce_prevrnd_bid_price_flag,
nvl(pah.DISPLAY_BEST_PRICE_BLIND_FLAG,'N') DISPLAY_BEST_PRICE_BLIND_FLAG,
pah.neg_team_enabled_flag,
nvl(pah.hide_terms_flag, 'N') hide_terms_flag,
pah.price_element_enabled_flag,
buyer_phone.phone_number,
buyer_fax.phone_number fax_number,
-- bidpdf: Proxy response decrement
decode(pah.min_bid_change_type, 'PERCENTAGE', pon_printing_pkg.format_number(pbhs.min_bid_change)||'%', pon_printing_pkg.format_price(pbhs.min_bid_change*l_rate, l_price_mask, l_price_precision)) min_bid_currency_change,
pon_printing_pkg.get_messages('PON_AUCTS_CUR_PROXY_DEC','CURRENCY_CODE',l_currency_code) supplier_proxy_dec_msg,
-- bidpdf: response total
decode(p_user_view_type, 'BUYER', to_char(pbhs.buyer_bid_total, l_amount_mask),
    to_char(get_supplier_bid_total(pah.auction_header_id, pbhs.bid_number, pbhs.buyer_bid_total, pah.contract_type, doctypes.doctype_group_name,pbhs.bid_status), l_amount_mask)
) supplier_bid_total,
pon_printing_pkg.get_messages('PON_BID_CUR_TOTAL','CURRENCY_CODE', l_currency_code) supplier_response_total_msg,
pah.price_tiers_indicator,

             --------------------Begin: Add by Chaoqun for addiing EMD info into Printable View on 6-NOV-2008-------------------
             pah.EMD_ENABLE_FLAG,
             pah.CURRENCY_CODE as EMD_CURRENCY_CODE,
             pah.EMD_AMOUNT,
	     To_Char(pah.emd_amount,'FM999G999G999G999G999G999G999G999G999G999D00') emd_amount_formatted,
             pah.EMD_DUE_DATE,
             pah.EMD_TYPE as EMD_TYPE_CODE,
             flv.meaning  as EMD_TYPE,
             pah.emd_guarantee_expiry_date AS EMD_GUARANTEE_EXPIRY_DATE,
             pah.EMD_ADDITIONAL_INFORMATION as EMD_ADDITIONAL_INFO,
             --pah.EMD_STATUS,
             --------------------End: Add by Chaoqun for adding EMD info into Printable View on 6-NOV-2008----------------------
 ------------Added as part of bug 8771921 ---------------
             pah.EXT_ATTRIBUTE_CATEGORY,
                pah.EXT_ATTRIBUTE1,
                pah.EXT_ATTRIBUTE2,
                pah.EXT_ATTRIBUTE3,
                pah.EXT_ATTRIBUTE4,
                pah.EXT_ATTRIBUTE5,
                pah.EXT_ATTRIBUTE6,
                pah.EXT_ATTRIBUTE7,
                pah.EXT_ATTRIBUTE8,
                pah.EXT_ATTRIBUTE9,
                pah.EXT_ATTRIBUTE10,
                pah.EXT_ATTRIBUTE11,
                pah.EXT_ATTRIBUTE12,
                pah.EXT_ATTRIBUTE13,
                pah.EXT_ATTRIBUTE14,
                pah.EXT_ATTRIBUTE15,
                pah.INT_ATTRIBUTE_CATEGORY,
                pah.INT_ATTRIBUTE1,
                pah.INT_ATTRIBUTE2,
                pah.INT_ATTRIBUTE3,
                pah.INT_ATTRIBUTE4,
                pah.INT_ATTRIBUTE5,
                pah.INT_ATTRIBUTE6,
                pah.INT_ATTRIBUTE7,
                pah.INT_ATTRIBUTE8,
                pah.INT_ATTRIBUTE9,
                pah.INT_ATTRIBUTE10,
                pah.INT_ATTRIBUTE11,
                pah.INT_ATTRIBUTE12,
                pah.INT_ATTRIBUTE13,
                pah.INT_ATTRIBUTE14,
                pah.INT_ATTRIBUTE15,
                pah.NEGOTIATION_REQUESTER_ID
              ------------End: Added as part of bug 8771921 ---------------
from
pon_auction_headers_all pah ,
fnd_lookups fl,
fnd_lookups fl2,
fnd_lookups flbr ,
fnd_lookups fl_rank_ind,
fnd_lookups fl_pf_type_allowed,
fnd_lookup_values fl_freight_terms ,
fnd_lookup_values            flv,
ap_terms ap   ,
fnd_lookup_values fl_fob ,
hr_locations_all loc_bill,
fnd_territories_tl bill_territories_tl,
hr_locations_all loc_ship,
fnd_territories_tl ship_territories_tl,
fnd_currencies_tl currency_tl ,
pon_auc_doctypes doctypes,
hz_parties hp1,
hr_operating_units ou,
hr_all_organization_units entity,
hr_all_organization_units_tl entitytl,
hr_locations_all entity_loc,
fnd_territories_tl entity_terr,
fnd_lookups fl_security,
gl_daily_conversion_types gdct,
fnd_product_groups fpg,
pon_negotiation_styles_vl ns,
PO_ALL_DOC_STYLE_LINES ps,
po_doc_style_headers postyl,
pa_projects_all    proj,
fnd_user buyer_user,
per_phones buyer_phone,
per_phones buyer_fax,
pon_bid_headers pbhs,
fnd_lookup_values fl_bid
where pah.auction_header_id = p_auction_header_id
and pbhs.auction_header_id (+) = pah.auction_header_id
and pbhs.bid_number (+) = p_bid_number
and fl_bid.lookup_type(+) = 'PON_BID_STATUS'
and fl_bid.lookup_code(+) = pbhs.bid_status
and fl_bid.language(+) = l_printing_language
and currency_tl.currency_code = pah.currency_code
and currency_tl.language = l_printing_language
and fl.lookup_type = 'PON_BID_VISIBILITY_CODE'
and fl.lookup_code = pah.bid_visibility_code
and flbr.lookup_type = 'PON_BID_RANKING_CODE'
and flbr.lookup_code = pah.bid_ranking
and pah.sealed_auction_status = fl2.lookup_code (+)
and fl2.lookup_type(+) = 'PON_SEALED_AUCTION_STATUS'
and fl_freight_terms.lookup_type(+) = 'FREIGHT TERMS'
and fl_freight_terms.lookup_code(+) = pah.freight_terms_code
and fl_security.lookup_type = 'PON_SECURITY_LEVEL_CODE'
and fl_security.lookup_code = pah.security_level_code
and fl_rank_ind.lookup_type = 'PON_RANK_INDICATOR_CODE'
and fl_rank_ind.lookup_code = pah.rank_indicator
and fl_pf_type_allowed.lookup_type = 'PON_PF_TYPE_ALLOWED'
and fl_pf_type_allowed.lookup_code = pah.pf_type_allowed
and fl_freight_terms.language(+) = l_printing_language
and fl_freight_terms.view_application_id(+) = 201
and fl_freight_terms.security_group_id(+) = 0
and ap.term_id(+) = pah.payment_terms_id
and fl_fob.lookup_type(+) = 'FOB'
and fl_fob.lookup_code(+) = pah.fob_code
and fl_fob.language(+) = l_printing_language
and fl_fob.view_application_id(+) = 201
and fl_fob.security_group_id (+) = 0
and loc_bill.location_id(+) = pah.bill_to_location_id
and bill_territories_tl.territory_code(+) = loc_bill.country
and bill_territories_tl.language(+) = l_printing_language
and loc_bill.bill_to_site_flag(+)='Y'
and sysdate < nvl(loc_bill.inactive_date(+), sysdate + 1)
and nvl(loc_bill.business_group_id(+), nvl(hr_general.get_business_group_id, -99))
    = nvl(hr_general.get_business_group_id, nvl(loc_bill.business_group_id(+), -99))
and loc_ship.location_id(+) = pah.ship_to_location_id
and ship_territories_tl.territory_code(+) = loc_ship.country
and ship_territories_tl.language(+) = l_printing_language
and loc_ship.ship_to_site_flag(+)='Y'
and sysdate < nvl(loc_ship.inactive_date(+), sysdate + 1)
and nvl(loc_ship.business_group_id(+), nvl(hr_general.get_business_group_id, -99))
    = nvl(hr_general.get_business_group_id, nvl(loc_ship.business_group_id(+), -99))
and pah.org_id = ou.organization_id(+)
and nvl(ou.date_from(+),sysdate-1) < sysdate
and nvl(ou.date_to(+),sysdate+1) > sysdate
--bug 7592494
and pah.org_id = entity.organization_id(+)
and entity.organization_id = entitytl.organization_id(+)
and entitytl.language(+) = l_printing_language
and entity.location_id = entity_loc.location_id(+)
and nvl(entity_loc.inactive_date(+), sysdate+1) > sysdate
and entity_terr.territory_code(+) = entity_loc.country
and entity_terr.territory_code(+) NOT IN ('ZR','FX','LX')
and entity_terr.language(+) = l_printing_language
and gdct.conversion_type(+) = pah.rate_type
and hp1.party_id = pah.trading_partner_contact_id
and pah.doctype_id = doctypes.doctype_id
and pah.style_id = ns.style_id
and pah.po_style_id = postyl.style_id(+)
and pah.project_id  = proj.project_id(+)
and pah.po_style_id = ps.style_id(+)
and pah.contract_type = ps.document_subtype(+)
and ps.language(+) = l_printing_language
and pah.trading_partner_contact_name = buyer_user.user_name
and buyer_phone.parent_table(+) = 'PER_ALL_PEOPLE_F'
and buyer_phone.parent_id(+) = buyer_user.employee_id
and buyer_phone.phone_type(+) = 'W1'
and nvl(buyer_phone.date_from(+), trunc(sysdate)) <= trunc(sysdate)
and nvl(buyer_phone.date_to(+), trunc(sysdate)) >= trunc(sysdate)
and buyer_fax.parent_table(+) = 'PER_ALL_PEOPLE_F'
and buyer_fax.parent_id(+) = buyer_user.employee_id
and buyer_fax.phone_type(+) = 'WF'
and nvl(buyer_fax.date_from(+), trunc(sysdate)) <= trunc(sysdate)
         and nvl(buyer_fax.date_to(+), trunc(sysdate)) >= trunc(sysdate)
         --Added by Chaoqun-------------------------------
         and flv.lookup_type(+) = 'PON_AUCTION_EMD_TYPE'
         and flv.language(+) = USERENV('LANG')
         and flv.lookup_code(+) = pah.EMD_TYPE;
         -------------------------------------------------

  --dbms_lob.createtemporary(result, TRUE);

  SELECT CURRENT_DATE INTO l_start_time FROM DUAL;



      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(xml_query_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, null);
        DBMS_XMLGEN.SetRowTag(queryCtx, null);
        DBMS_XMLGEN.getXMLType(queryCtx, xml_res, DBMS_XMLGEN.NONE);
        xml_clob := xml_res.getCLOBVal();
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE xml_query_cursor;

Dbms_Lob.append(xml_clob, '<LINES>');
OPEN line_num_cur;
LOOP
FETCH line_num_cur  INTO line_num;

EXIT WHEN line_num_cur%NOTFOUND;

OPEN lines_cursor FOR
Select paip.item_number ||
                            nvl2(paip.item_revision, ', ', '') ||
                            paip.item_revision || jobs.name item,
paip.line_number,
DECODE(NVL(msi.allow_item_desc_update_flag, 'Y'), 'Y' ,paip.ITEM_DESCRIPTION ,'N' , msit.description)  item_description,
pon_oa_util_pkg.display_date_time(paip.close_bidding_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') line_close_bidding_date,
paip.category_id,
paip.category_name,
paip.ip_category_id,
icx.category_name ip_category_name,
paip.uom_code,
units.unit_of_measure_tl,
pon_printing_pkg.format_number(paip.quantity) quantity,
-- bidpdf: Note to Buyer
pbip.note_to_auction_owner,
-- bidpdf: add bid price info
decode(p_user_view_type, 'BUYER', pon_printing_pkg.format_price(pbip.price, l_price_mask, l_price_precision), pon_printing_pkg.format_price(pbip.bid_currency_price, l_price_mask, l_price_precision)) bid_currency_price,
pon_printing_pkg.format_number(pbip.quantity) bid_quantity,
pon_oa_util_pkg.display_date_time(pbip.promised_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') bid_promised_date,
--in MAS case, pbip.quantity is null, use paip.quantity instead
to_char(decode(p_user_view_type, 'BUYER',pbip.price, pbip.bid_currency_price)*decode(paip.order_type_lookup_code, 'FIXED PRICE', 1,decode(l_contract_type, 'STANDARD', nvl(pbip.quantity, 0), paip.quantity)), l_amount_mask) bid_amount,
--response/inquiry/server/ViewBidItemsVORowImpl.java:getBidTotalDisplay(): exchange_rate * PON_TRANSFORM_BIDDING_PKG.calculate_quote_amount (paip.auction_header_id, pbip.line_number, pbip.bid_number, 'TRANSFORMED', 12637, 12438, -1) bid_amount,
--bidpdf: Bid Minimum Release Amount
decode(p_user_view_type, 'BUYER', to_char(pbip.po_min_rel_amount, l_amount_mask), to_char(pbip.po_bid_min_rel_amount, l_amount_mask)) bid_min_rel_amount,
--bidpdf: MAS Score
pbip.total_weighted_score,
--bidpdf: Proxy Minimum
decode(p_user_view_type, 'BUYER', pon_printing_pkg.format_price(pbip.proxy_bid_limit_price, l_price_mask, l_price_precision), pon_printing_pkg.format_price(pbip.bid_currency_limit_price, l_price_mask, l_price_precision)) bid_currency_limit_price,
paip.ship_to_location_id,

  pon_printing_pkg.format_price(pon_transform_bidding_pkg.calculate_price(p_auction_header_id,
    paip.line_number, paip.target_price*l_rate, paip.quantity, p_trading_partner_id,
    p_trading_partner_contact_id, p_vendor_site_id, p_requested_supplier_id),l_price_mask, l_price_precision)
 target_price,
-- Start price comes from the earlier bid for a supplier if he had bid
-- on the earlier round for the line and if the control for enforcing
-- previous round start price is set. If he did not bid on the line or
-- if it is buyer or other supplier, then we fall back upon the
-- auction start price
--untransform_one_price

DECODE(l_is_supplier_bidpdf, 'Y',
          pon_printing_pkg.format_price(pon_transform_bidding_pkg.calculate_price(p_auction_header_id, paip.line_number,
            nvl(pbip.bid_start_price, paip.bid_start_price)*l_rate, paip.quantity,
            p_trading_partner_id,
            p_trading_partner_contact_id,
            p_vendor_site_id,
            p_requested_supplier_id),l_price_mask, l_price_precision),
          DECODE(l_start_price_from_prev_rnd, 'N',
                  pon_printing_pkg.format_price(
                    pon_transform_bidding_pkg.calculate_price(p_auction_header_id, paip.line_number, paip.bid_start_price, paip.quantity, p_trading_partner_id, p_trading_partner_contact_id, p_vendor_site_id, p_requested_supplier_id),
                    l_price_mask, l_price_precision),
                  pon_printing_pkg.format_price(
                    NVL(pon_auction_headers_pkg.apply_price_factors(p_auction_header_id ,l_prev_rnd_bid_number,paip.line_number, l_contract_type, l_supplier_view_type, l_pf_type_allowed, 'Y'),paip.bid_start_price),
                    l_price_mask, l_price_precision)
          )
) bid_start_price,

paip.note_to_bidders,
paip.display_target_price_flag,
paip.type,
to_char(paip.po_min_rel_amount*l_rate, l_amount_mask) po_min_rel_amount,
paip.unit_of_measure,
paip.has_attributes_flag,
paip.org_id,
paip.has_price_elements_flag,
paip.line_type_id,
paip.order_type_lookup_code,
paip.item_revision,
paip.item_id,
paip.item_number,
paip.price_break_type,
paip.price_break_neg_flag,
paip.has_shipments_flag,
paip.price_disabled_flag,
paip.quantity_disabled_flag,
paip.disp_line_number,
paip.is_quantity_scored,
paip.is_need_by_date_scored,
paip.job_id,
paip.additional_job_details,
to_char(paip.po_agreed_amount*l_rate, l_amount_mask) po_agreed_amount,
paip.has_price_differentials_flag,
paip.price_diff_shipment_number,
paip.differential_response_type,
paip.purchase_basis,
pon_auction_pkg.getNeedByDatesToPrint(paip.auction_header_id,paip.line_number,p_date_format) as need_by_dates_to_print,
paip.document_disp_line_number,
paip.group_type,
decode(paip.parent_line_number, null,to_char(null),
        (select DECODE(NVL(msi2.allow_item_desc_update_flag, 'Y'), 'Y' ,paip2.ITEM_DESCRIPTION ,'N' , msit2.description)
        from pon_auction_item_prices_all paip2
   , FINANCIALS_SYSTEM_PARAMS_ALL fsp2
   , MTL_SYSTEM_ITEMS_TL msit2
   , mtl_system_items_kfv msi2
        where paip2.auction_header_id = paip.auction_header_id
  AND paip2.ORG_ID                                      = fsp2.ORG_ID(+)
  AND msit2.INVENTORY_ITEM_ID(+)                               = paip2.ITEM_ID
  AND NVL(msit2.organization_id,fsp2.inventory_organization_id) = fsp2.inventory_organization_id
  AND msi2.INVENTORY_ITEM_ID(+)                                = paip2.ITEM_ID
  AND NVL(msi2.organization_id,fsp2.inventory_organization_id)  = fsp2.inventory_organization_id
  AND msit2.language(+) = l_printing_language
        and paip2.line_number = paip.parent_line_number)) parent_line_description,
tl.territory_short_name country_name,
hl.location_code address_name,
hl.address_line_1 address1,
hl.address_line_2 address2,
hl.address_line_3 address3,
hl.town_or_city city,
hl.region_2 state,
hl.region_3 province_or_region,
hl.postal_code zip_code,
hl.postal_code postal_code,
hl.country country,
hl.region_1 county,
paip.requisition_number,
paip.line_origination_code,
nvl2(paip.source_doc_number, paip.source_doc_number || nvl2(paip.source_line_number, ' / ' || paip.source_line_number, null), null) source_doc_line_display,
lt.line_type,
pon_printing_pkg.format_price(paip.current_price, l_price_mask, l_price_precision) current_price,
pon_printing_pkg.format_price(paip.unit_target_price, l_price_mask, l_price_precision) unit_target_price,
paip.unit_display_target_flag
,paip.has_payments_flag
,to_char(paip.advance_amount*l_rate, l_amount_mask)           advance_amount
,decode(p_user_view_type, 'BUYER', to_char(pbip.advance_amount, l_amount_mask), to_char(pbip.bid_curr_advance_amount, l_amount_mask)) bid_advance_amount
--bidpdf:remove "," after paip.recoupment_rate_percent and paip.progress_pymt_rate_percent
,paip.recoupment_rate_percent                         recoupment_rate_percent
,pbip.recoupment_rate_percent                         bid_recoupment_rate_percent
,paip.progress_pymt_rate_percent                      progress_pymt_rate_percent
,pbip.progress_pymt_rate_percent                      bid_progress_pymt_rate_percent
,paip.retainage_rate_percent                           retainage_rate_percent
,pbip.retainage_rate_percent                           bid_retainage_rate_percent
,to_char(paip.max_retainage_amount*l_rate, l_amount_mask)      max_retainage_amount
,decode(p_user_view_type, 'BUYER', to_char(pbip.max_retainage_amount, l_amount_mask), to_char(pbip.bid_curr_max_retainage_amt, l_amount_mask))     bid_curr_max_retainage_amt
,paip.project_id                  project_id
,proj.segment1                    project_number
,paip.project_task_id             project_task_id
,task.task_number                 project_task_number
,paip.project_award_id            project_award_id
,awrd.award_number                project_award_number
,paip.project_expenditure_type    project_expenditure_type
,paip.project_exp_organization_id project_exp_organization_id
,hrorg.name                       project_exp_organization_name
,pon_oa_util_pkg.display_date(paip.project_expenditure_item_date, p_client_time_zone,
                 p_server_time_zone, p_date_format, 'N') project_expenditure_item_date
,NVL2(paip.work_approver_user_id, (SELECT per.full_name
                                     FROM per_all_people_f per
				    WHERE per.person_id = fuser.employee_id
			              AND per.effective_end_date =
				            (SELECT MAX(per1.effective_end_date)
					       FROM per_all_people_f per1
				              WHERE per.person_id = per1.person_id)
				  ), NULL)  work_approver_name
,paip.has_quantity_tiers          negline_has_quantity_tiers
,pbip.has_quantity_tiers          bidline_has_quantity_tiers
from
pon_auction_item_prices_all paip ,
hr_locations_all hl,
fnd_territories_tl tl,
per_jobs_vl jobs,
icx_cat_categories_v icx,
mtl_units_of_measure_tl units,
po_line_types_tl lt
,pa_projects_all            proj
,pa_tasks                   task
,gms_awards_all             awrd
,hr_all_organization_units  hrorg
,fnd_user                   fuser
,pon_bid_item_prices pbip
, FINANCIALS_SYSTEM_PARAMS_ALL fsp
, MTL_SYSTEM_ITEMS_TL msit
, mtl_system_items_kfv msi
where
paip.auction_header_id = p_auction_header_id
AND paip.line_number = line_num
AND paip.ORG_ID                                      = fsp.ORG_ID(+)
AND msit.INVENTORY_ITEM_ID(+)                               = paip.ITEM_ID
AND NVL(msit.organization_id,fsp.inventory_organization_id) = fsp.inventory_organization_id
AND msi.INVENTORY_ITEM_ID(+)                                = paip.ITEM_ID
AND NVL(msi.organization_id,fsp.inventory_organization_id)  = fsp.inventory_organization_id
AND msit.language(+)                                        = l_printing_language
and pbip.auction_header_id(+) = paip.auction_header_id
and pbip.bid_number(+) = p_bid_number
and pbip.line_number(+)=paip.line_number
and hl.location_id(+) = paip.ship_to_location_id
and tl.territory_code(+) = hl.country
and tl.language(+) = l_printing_language
and hl.ship_to_site_flag(+)='Y'
and sysdate < nvl(hl.inactive_date(+), sysdate + 1)
and paip.uom_code = units.uom_code(+)
and units.language(+) = l_printing_language
and jobs.job_id(+) = paip.job_id
and paip.ip_category_id = icx.rt_category_id(+)
and icx.language(+) = l_printing_language
and lt.line_type_id(+) = paip.line_type_id
and lt.language(+) = l_printing_language
and nvl(hl.business_group_id(+), nvl(hr_general.get_business_group_id, -99))
    = nvl(hr_general.get_business_group_id, nvl(hl.business_group_id(+), -99))
and (l_is_buyer_negpdf IN (SELECT  'Y' FROM dual)
     or
     (not exists (select 'x'
                    from pon_bidding_parties bp
                   where bp.auction_header_id = paip.auction_header_id
                     and ((bp.trading_partner_id = l_trading_partner_id
                           and bp.vendor_site_id = p_vendor_site_id)
                         OR bp.requested_supplier_id = p_requested_supplier_id)
                     and bp.access_type = 'RESTRICTED')
      or
      nvl(paip.parent_line_number, paip.line_number) not in (
        select line_number
          from pon_party_line_exclusions pple
         where pple.auction_header_id = paip.auction_header_id
           and ((pple.trading_partner_id = l_trading_partner_id
                 and pple.vendor_site_id = p_vendor_site_id)
                OR pple.requested_supplier_id = p_requested_supplier_id))))
AND  paip.project_id                  = proj.project_id(+)
AND  paip.project_task_id             = task.task_id(+)
AND  paip.project_award_id            = awrd.award_id(+)
AND  paip.project_exp_organization_id = hrorg.organization_id(+)
AND  paip.work_approver_user_id       = fuser.user_id(+)
order by paip.disp_line_number;

linesCtx := DBMS_XMLGEN.newContext(lines_cursor);

Dbms_Lob.append(xml_clob, '<LINES_ROW>');
      BEGIN
        DBMS_XMLGEN.SetRowSetTag(linesCtx, null);
        DBMS_XMLGEN.SetRowTag(linesCtx, null);
        lines_res := NULL;
        DBMS_XMLGEN.getXMLType(linesCtx, lines_res, DBMS_XMLGEN.NONE);
        Dbms_Lob.append(xml_clob, lines_res.getCLOBVal());
        exception when others then
            DBMS_XMLGEN.closeContext (linesCtx);
        RAISE;
      END;

OPEN pay_items_cursor FOR SELECT
      pay.payment_id
     ,pay.payment_display_number payment_display_number
     ,pay.ship_to_location_id
     ,terr.territory_short_name              shipto_country_name
     ,hrl.location_code                      shipto_address_name
     ,hrl.address_line_1                     shipto_address1
     ,hrl.address_line_2                     shipto_address2
     ,hrl.address_line_3                     shipto_address3
     ,hrl.town_or_city                       shipto_city
     ,hrl.region_2                           shipto_state
     ,hrl.region_3                           shipto_province_or_region
     ,hrl.postal_code                        shipto_zip_code
     ,hrl.postal_code                        shipto_postal_code
     ,hrl.country                            shipto_country
     ,hrl.region_1                           shipto_county
     ,pay.payment_description
     ,pay.payment_type_code
     ,lkp1.displayed_field                   payment_type_disp
     ,pay.quantity
     ,pay.uom_code
     ,uom_tl.unit_of_measure_tl              unit_of_measure_tl
     ,pon_printing_pkg.format_price(pay.target_price*l_rate, l_price_mask, l_price_precision) target_price
     ,pon_oa_util_pkg.display_date_time(pay.need_by_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') need_by_date
     ,pay.work_approver_user_id
     ,NVL2(pay.work_approver_user_id, (SELECT per.full_name
                                         FROM per_all_people_f per
				        WHERE per.person_id = fuser.employee_id
					  AND per.effective_end_date =
					      (SELECT MAX(per1.effective_end_date)
					         FROM per_all_people_f per1
						WHERE per.person_id = per1.person_id)
					), NULL) work_approver_name
     ,pay.note_to_bidders
     ,pay.project_id                         project_id
     ,proj.segment1                          project_number
     ,pay.project_task_id                    project_task_id
     ,task.task_number                       project_task_number
     ,pay.project_award_id                   project_award_id
     ,awrd.award_number                      project_award_number
     ,pay.project_expenditure_type           project_expenditure_type
     ,pay.project_exp_organization_id        project_exp_organization_id
     ,hrorg.name                             project_exp_organization_name
     ,pon_oa_util_pkg.display_date(pay.project_expenditure_item_date, p_client_time_zone,
                                   p_server_time_zone, p_date_format, 'N') project_expenditure_item_date
     ,null pay_item_price
     ,null amount_display
     ,null bid_promised_date

FROM
      pon_auc_payments_shipments pay,
      pa_projects_all            proj,
      pa_tasks                   task,
      gms_awards_all             awrd,
      hr_locations_all           hrl,
      hr_all_organization_units  hrorg,
      fnd_user                   fuser,
      po_lookup_codes            lkp1,
      fnd_territories_tl         terr,
      mtl_units_of_measure_tl    uom_tl
WHERE pay.auction_header_id   = p_auction_header_id
 AND  pay.line_number         = line_num
 AND  pay.project_id          = proj.project_id(+)
 AND  pay.project_task_id     = task.task_id(+)
 AND  pay.project_award_id    = awrd.award_id(+)
 AND  pay.ship_to_location_id = hrl.location_id(+)
 AND  terr.territory_code(+)  = hrl.country
 AND  terr.language(+)        = l_printing_language
 AND  pay.project_exp_organization_id = hrorg.organization_id(+)
 AND  pay.payment_type_code   = lkp1.lookup_code(+)
 AND  lkp1.lookup_type(+)     = 'PAYMENT TYPE'
 AND  pay.uom_code            = uom_tl.uom_code(+)
 AND  uom_tl.language(+)      = l_printing_language
 AND  fuser.user_id(+)        = pay.work_approver_user_id
 AND not exists (select 1 from pon_bid_item_prices where bid_number = p_bid_number and line_number=pay.line_number)
UNION ALL
 SELECT
      pbp.BID_PAYMENT_ID payment_id
     ,pbp.payment_display_number payment_display_number
     ,pay.ship_to_location_id
     ,terr.territory_short_name              shipto_country_name
     ,hrl.location_code                      shipto_address_name
     ,hrl.address_line_1                     shipto_address1
     ,hrl.address_line_2                     shipto_address2
     ,hrl.address_line_3                     shipto_address3
     ,hrl.town_or_city                       shipto_city
     ,hrl.region_2                           shipto_state
     ,hrl.region_3                           shipto_province_or_region
     ,hrl.postal_code                        shipto_zip_code
     ,hrl.postal_code                        shipto_postal_code
     ,hrl.country                            shipto_country
     ,hrl.region_1                           shipto_county
     ,pbp.payment_description
     ,pbp.payment_type_code
     ,lkp1.displayed_field                   payment_type_disp
     ,pay.quantity
     ,pay.uom_code
     ,uom_tl.unit_of_measure_tl              unit_of_measure_tl
     ,pon_printing_pkg.format_price(pay.target_price*l_rate, l_price_mask, l_price_precision) target_price
     ,pon_oa_util_pkg.display_date_time(pay.need_by_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') need_by_date
     ,pay.work_approver_user_id
     ,NVL2(pay.work_approver_user_id, (SELECT per.full_name
                                         FROM per_all_people_f per
				        WHERE per.person_id = fuser.employee_id
					  AND per.effective_end_date =
					      (SELECT MAX(per1.effective_end_date)
					         FROM per_all_people_f per1
						WHERE per.person_id = per1.person_id)
					), NULL) work_approver_name
     ,pay.note_to_bidders
     ,pay.project_id                         project_id
     ,proj.segment1                          project_number
     ,pay.project_task_id                    project_task_id
     ,task.task_number                       project_task_number
     ,pay.project_award_id                   project_award_id
     ,awrd.award_number                      project_award_number
     ,pay.project_expenditure_type           project_expenditure_type
     ,pay.project_exp_organization_id        project_exp_organization_id
     ,hrorg.name                             project_exp_organization_name
     ,pon_oa_util_pkg.display_date(pay.project_expenditure_item_date, p_client_time_zone,
                                   p_server_time_zone, p_date_format, 'N') project_expenditure_item_date
     ,decode(p_user_view_type, 'BUYER', pon_printing_pkg.format_price(pbp.price, l_price_mask,l_price_precision), pon_printing_pkg.format_price(pbp.bid_currency_price,l_price_mask,l_price_precision)) pay_item_price
     ,to_char(decode(pbp.quantity,null,decode(pbip.quantity, null, 1,pbip.quantity),pbp.quantity)*decode(p_user_view_type, 'BUYER',pbp.price,pbp.bid_currency_price), l_amount_mask) amount_display
     ,pon_oa_util_pkg.display_date_time(pbp.promised_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') bid_promised_date
FROM
      pon_auc_payments_shipments pay,
      pa_projects_all            proj,
      pa_tasks                   task,
      gms_awards_all             awrd,
      hr_locations_all           hrl,
      hr_all_organization_units  hrorg,
      fnd_user                   fuser,
      po_lookup_codes            lkp1,
      fnd_territories_tl         terr,
      mtl_units_of_measure_tl    uom_tl,
      pon_bid_payments_shipments pbp,
      pon_bid_item_prices pbip
WHERE
  pbp.bid_number = p_bid_number
 AND pbp.auction_line_number = line_num
 AND pbp.auction_header_id = pay.auction_header_id(+)
 AND pbip.bid_number = pbp.bid_number
 AND pbip.line_number = pbp.bid_line_number
 AND pbp.bid_line_number = pay.line_number(+)
 AND pbp.auction_payment_id = pay.payment_id(+)
 AND  pay.project_id          = proj.project_id(+)
 AND  pay.project_task_id     = task.task_id(+)
 AND  pay.project_award_id    = awrd.award_id(+)
 AND  pay.ship_to_location_id = hrl.location_id(+)
 AND  terr.territory_code(+)  = hrl.country
 AND  terr.language(+)        = l_printing_language
 AND  pay.project_exp_organization_id = hrorg.organization_id(+)
 AND  pbp.payment_type_code   = lkp1.lookup_code(+)
 AND  lkp1.lookup_type(+)     = 'PAYMENT TYPE'
 AND  pay.uom_code            = uom_tl.uom_code(+)
 AND  uom_tl.language(+)      = l_printing_language
 AND  fuser.user_id(+)        = pay.work_approver_user_id
ORDER BY payment_display_number;

BEGIN
        payItemsCtx := DBMS_XMLGEN.newContext(pay_items_cursor);
        DBMS_XMLGEN.SetRowSetTag(payItemsCtx, 'PAY_ITEMS');
        DBMS_XMLGEN.SetRowTag(payItemsCtx, 'PAY_ITEMS_ROW');
        pay_items_res := NULL;
        DBMS_XMLGEN.getXMLType(payItemsCtx, pay_items_res, DBMS_XMLGEN.NONE);
        IF pay_items_res IS NULL THEN
          pay_items_res := XMLType('<PAY_ITEMS></PAY_ITEMS>');
        END IF;
        Dbms_Lob.append(xml_clob, pay_items_res.getCLOBVal());
        exception when others then
            DBMS_XMLGEN.closeContext (payItemsCtx);
        RAISE;
        END;

       CLOSE pay_items_cursor;

OPEN line_attr_cursor FOR select
 attrGrpFlv.meaning,
 pal.line_number,
 pal.attribute_name,
 pal.description,
 pal.datatype,
 pal.mandatory_flag,
 print_attribute_target_value(pal.display_target_flag, pal.value, pal.datatype,pal.sequence_number, p_client_time_zone, p_server_time_zone, p_date_format, p_user_view_type) value,
 pal.display_prompt,
 pal.display_target_flag,
 pal.display_only_flag,
 pal.sequence_number,
 pal.weight,
 pal.scoring_type,
 NVL(pal.attr_level,'LINE') attr_level,
 NVL(pal.attr_group,'GENERAL') attr_group,
 pal.attr_max_score,
 pal.internal_attr_flag,
 NVL(pal.attr_group_seq_number,10) attr_group_seq_number,
 pal.attr_disp_seq_number,
 -- bidpdf: add attribute response value
 print_attribute_response_value(pbav.value, pbav.datatype, p_client_time_zone, p_server_time_zone, p_date_format, pbav.sequence_number) attr_bid_value
 from
   pon_auction_attributes pal,
   pon_bid_attribute_values pbav,
   fnd_lookups attrGrpFlv
 where
   pal.auction_header_id = p_auction_header_id
   AND pal.line_number = line_num
   and pbav.auction_header_id(+) = pal.auction_header_id
   and pbav.bid_number(+) = p_bid_number
   and pbav.line_number(+) = pal.line_number
   and pbav.sequence_number(+) = pal.sequence_number
   and NVL(pal.attr_group,'GENERAL') = attrGrpFlv.lookup_code
   and NVL(pal.attr_level,'LINE')='LINE'
   and NVL(pal.internal_attr_flag,'N') <> 'Y'
   and attrGrpFlv.lookup_type = 'PON_LINE_ATTRIBUTE_GROUPS'
   and attrGrpFlv.enabled_flag = 'Y'
   and nvl(attrGrpFlv.start_date_active,sysdate) <= sysdate
   and nvl(attrGrpFlv.end_date_active,sysdate) > sysdate-1
   order by NVL(pal.attr_group_seq_number,10),pal.attr_disp_seq_number;

   BEGIN
        attrsCtx := DBMS_XMLGEN.newContext(line_attr_cursor);
        DBMS_XMLGEN.SetRowSetTag(attrsCtx, 'LINE_ATTRIBUTES');
        DBMS_XMLGEN.SetRowTag(attrsCtx, 'LINE_ATTRIBUTES_ROW');
        line_attr_res := NULL;
        DBMS_XMLGEN.getXMLType(attrsCtx, line_attr_res, DBMS_XMLGEN.NONE);
        IF line_attr_res IS NULL THEN
          line_attr_res := XMLType('<LINE_ATTRIBUTES></LINE_ATTRIBUTES>');
        END IF;
        Dbms_Lob.append(xml_clob, line_attr_res.getCLOBVal());
        exception when others then
            DBMS_XMLGEN.closeContext (attrsCtx);
        RAISE;
   END;

       CLOSE line_attr_cursor;

OPEN line_attr_score_cursor FOR select
 pas.attribute_sequence_number,
 pas.value,
 pas.from_range,
 pas.to_range,
 pas.score,
 pas.sequence_number,
 get_acceptable_value(pah.show_bidder_scores,pas.attribute_sequence_number,paa.datatype,pas.from_range,pas.to_range,pas.value,pas.score, p_client_time_zone, p_server_time_zone, p_date_format, l_is_buyer_negpdf) display_score
FROM
 pon_auction_headers_all pah,
 pon_attribute_scores pas,
 pon_auction_attributes paa
where
     pah.auction_header_id = p_auction_header_id
 AND pas.auction_header_id = pah.auction_header_id
 AND pas.line_number = line_num
 and paa.auction_header_id = p_auction_header_id
 and paa.line_number = pas.line_number
 and paa.sequence_number = pas.attribute_sequence_number
 and NVL(paa.attr_level,'LINE')='LINE'
 order by pas.line_number,pas.attribute_sequence_number,pas.sequence_number;


 BEGIN
        attrsScoreCtx := DBMS_XMLGEN.newContext(line_attr_score_cursor);
        DBMS_XMLGEN.SetRowSetTag(attrsScoreCtx, 'LINE_ATTRIBUTE_SCORES');
        DBMS_XMLGEN.SetRowTag(attrsScoreCtx, 'LINE_ATTRIBUTE_SCORES_ROW');
        line_attr_score_res := NULL;
        DBMS_XMLGEN.getXMLType(attrsScoreCtx, line_attr_score_res, DBMS_XMLGEN.NONE);
        IF line_attr_score_res IS NULL THEN
          line_attr_score_res := XMLType('<LINE_ATTRIBUTE_SCORES></LINE_ATTRIBUTE_SCORES>');
        END IF;
        Dbms_Lob.append(xml_clob, line_attr_score_res.getCLOBVal());
        exception when others then
            DBMS_XMLGEN.closeContext (attrsScoreCtx);
        RAISE;
   END;

       CLOSE line_attr_score_cursor;

OPEN pf_cursor FOR SELECT
  pet.name,
  pe.pricing_basis,
  flv.meaning pricing_basis_display,
  pe.value value,
  --only in supplier bid pdf, the target value is in supplier currency and number format
  --in neg pdf and buyer side bid pdf, the target value is in buyer currency
  nvl2(pe.value, decode(pe.pricing_basis, 'PER_UNIT', pon_printing_pkg.format_price(pe.value*l_rate, l_price_mask, l_price_precision) ||' ('||l_currency_code||')',
                                          'FIXED_AMOUNT', to_char(pe.value*l_rate, l_amount_mask) ||' ('||l_currency_code||')',
                                          pon_printing_pkg.format_number(pe.value)),
                 null) target_value_display,
  -- bidpdf: response value
  nvl2(pbpe.bid_currency_value,
       decode(pe.pricing_basis,
             'PER_UNIT', decode(p_user_view_type,
                'BUYER', pon_printing_pkg.format_price(pbpe.auction_currency_value, l_price_mask, l_price_precision)||' ('||l_currency_code||')',
                pon_printing_pkg.format_price(pbpe.bid_currency_value, l_price_mask, l_price_precision)||' ('||l_currency_code||')'),
              'FIXED_AMOUNT', decode(p_user_view_type, 'BUYER',to_char(pbpe.auction_currency_value, l_amount_mask)||' ('||l_currency_code||')',to_char(pbpe.bid_currency_value, l_amount_mask)||' ('||l_currency_code||')'),
              pon_printing_pkg.format_number(pbpe.bid_currency_value)),
       null) bid_value_display,
  pe.price_element_type_id,
  pe.sequence_number,
  pe.display_target_flag,
  pet.description,
  pe.pf_type,
  pe.display_to_suppliers_flag,
  flv2.meaning pf_type_display,
  --only in supplier bid pdf, the buyer response value is in supplier currency and number format
  --in neg pdf and buyer side bid pdf, the buyer response value is in buyer currency
  nvl2(pf_values.value, decode(pe.pf_type, 'BUYER', decode(pe.pricing_basis, 'PER_UNIT', pon_printing_pkg.format_price(pf_values.value*l_rate, l_price_mask, l_price_precision)||' ('||l_currency_code||')',
                                                            'FIXED_AMOUNT', to_char(pf_values.value*l_rate, l_amount_mask)||' ('||l_currency_code||')',
                                                            pon_printing_pkg.format_number(pf_values.value)),
                         null),
       null) buyer_pf_value_display,
  decode(pah.trading_partner_id,
         p_trading_partner_id, 'Y',
         decode(pe.pf_type,
                'SUPPLIER', 'Y',
                decode(pe.display_to_suppliers_flag,
                       'N', 'N',
                       PON_TRANSFORM_BIDDING_PKG.has_pf_values_defined(pe.auction_header_id, pe.line_number, pe.sequence_number, p_trading_partner_id, p_vendor_site_id, p_requested_supplier_id)))) can_view_pf_flag
FROM
  pon_auction_headers_all pah,
  pon_price_elements pe,
  pon_price_element_types_tl pet,
  pon_auction_item_prices_all itm,
  fnd_lookup_values flv,
  fnd_lookup_values flv2,
  pon_pf_supplier_values pf_values,
  -- bidpdf: add bid value for cost factor
  pon_bid_price_elements pbpe
WHERE pah.auction_header_id = p_auction_header_id
  AND pe.auction_header_id = pah.auction_header_id
  AND pe.line_number = line_num
  AND pbpe.auction_header_id(+) = pe.auction_header_id
  AND pbpe.bid_number(+) = p_bid_number
  AND pbpe.line_number(+) = pe.line_number
  AND pbpe.price_element_type_id(+) = pe.price_element_type_id
  AND itm.auction_header_id = pe.auction_header_id
  AND itm.line_number = pe.line_number
  AND pe.price_element_type_id = pet.price_element_type_id
  AND pet.language = l_printing_language
  AND flv.lookup_type = 'PON_PRICING_BASIS'
  AND flv.language = l_printing_language
  AND flv.lookup_code = pe.pricing_basis
  AND flv.view_application_id = 0
  AND flv.security_group_id = 0
  AND flv2.lookup_type = 'PON_PRICE_FACTOR_TYPE'
  AND flv2.language = l_printing_language
  AND flv2.lookup_code = pe.pf_type
  AND flv2.view_application_id = 0
  AND flv2.security_group_id = 0
  AND decode(pe.price_element_type_id, -10, itm.has_price_elements_flag, 'Y') = 'Y'
  AND pf_values.auction_header_id(+) = pe.auction_header_id
  AND pf_values.line_number(+) = pe.line_number
  AND pf_values.pf_seq_number(+) = pe.sequence_number
  AND pf_values.supplier_seq_number(+) = l_supplier_sequence_number
order by pe.line_number, pe.sequence_number ASC;

BEGIN
        pfCtx := DBMS_XMLGEN.newContext(pf_cursor);
        DBMS_XMLGEN.SetRowSetTag(pfCtx, 'PRICE_FACTORS');
        DBMS_XMLGEN.SetRowTag(pfCtx, 'PRICE_FACTORS_ROW');
        pf_res := NULL;
        DBMS_XMLGEN.getXMLType(pfCtx, pf_res, DBMS_XMLGEN.NONE);
        IF pf_res IS NULL THEN
          pf_res := XMLType('<PRICE_FACTORS></PRICE_FACTORS>');
        END IF;
        Dbms_Lob.append(xml_clob, pf_res.getCLOBVal());
        exception when others then
            DBMS_XMLGEN.closeContext (pfCtx);
        RAISE;
       END;

       CLOSE pf_cursor;

OPEN line_price_diff_cursor FOR SELECT
  ppd.shipment_number,
  ppd.price_differential_number,
  ppd.price_type,
  pon_printing_pkg.format_number(ppd.multiplier) as target_multiplier,
  pon_printing_pkg.format_number(pbpd.multiplier) as multiplier
FROM pon_price_differentials ppd,
-- bidpdf: add response multiplier for price differentials
pon_bid_price_differentials pbpd
WHERE ppd.auction_header_id = p_auction_header_id
AND ppd.line_number = line_num
and pbpd.auction_header_id(+) = ppd.auction_header_id
and pbpd.bid_number (+) = p_bid_number
and pbpd.line_number (+) = ppd.line_number
and pbpd.shipment_number(+) = ppd.shipment_number
and ppd.shipment_number = -1
and pbpd.price_differential_number(+) = ppd.price_differential_number;

BEGIN
        linepdiffCtx := DBMS_XMLGEN.newContext(line_price_diff_cursor);
        DBMS_XMLGEN.SetRowSetTag(linepdiffCtx, 'LINE_PRICE_DIFFERENTIALS');
        DBMS_XMLGEN.SetRowTag(linepdiffCtx, 'LINE_PRICE_DIFFERENTIALS_ROW');
        line_price_diff_res := NULL;
        DBMS_XMLGEN.getXMLType(linepdiffCtx, line_price_diff_res, DBMS_XMLGEN.NONE);
        IF line_price_diff_res IS NULL THEN
          line_price_diff_res := XMLType('<LINE_PRICE_DIFFERENTIALS></LINE_PRICE_DIFFERENTIALS>');
        END IF;
        Dbms_Lob.append(xml_clob, line_price_diff_res.getCLOBVal());
        exception when others then
            DBMS_XMLGEN.closeContext (linepdiffCtx);
        RAISE;
       END;

       CLOSE line_price_diff_cursor;

OPEN item_pb_cursor FOR SELECT  pbsm.auction_shipment_number shipment_number,
        pbsm.shipment_number bid_shipment_number,
	pbsm.ship_to_organization_id,
	mp.organization_code ship_to_organization,
	pbsm.ship_to_location_id,
	loc.location_code ship_to_location,
	pon_printing_pkg.format_number(pbsm.quantity) quantity,
        -- in case when supplier add new shipments, there's no target price
        decode(pbsm.auction_shipment_number, null, null,
                      pon_printing_pkg.format_price(
                        pon_transform_bidding_pkg.calculate_price(p_auction_header_id, pas.line_number, pas.price*l_rate, paip.quantity, p_trading_partner_id, p_trading_partner_contact_id, p_vendor_site_id, p_requested_supplier_id),
                        l_price_mask, l_price_precision)
        ) price,

	PON_OA_UTIL_PKG.DISPLAY_DATE(pbsm.effective_start_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') effective_start_date,
	PON_OA_UTIL_PKG.DISPLAY_DATE(pbsm.effective_end_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') effective_end_date,
	nvl2(pbsm.ship_to_location_id, loc.location_code, mp.organization_code) ship_to,
	pbsm.has_price_differentials_flag,
	pas.differential_response_type,
        decode(p_user_view_type, 'BUYER',pon_printing_pkg.format_price(pbsm.price,l_price_mask, l_price_precision), pon_printing_pkg.format_price(pbsm.bid_currency_price,l_price_mask, l_price_precision)) bid_currency_price,
        pbsm.price_type,
        pbsm.price_discount
FROM pon_auction_shipments_all pas,
 pon_auction_item_prices_all paip,
 hr_locations_all loc,
 mtl_parameters mp,
 -- bidpdf: add response price for price breaks
 pon_bid_shipments pbsm
WHERE pbsm.bid_number = p_bid_number
AND pbsm.line_number = line_num
and pbsm.auction_header_id = pas.auction_header_id(+)
and pbsm.line_number = pas.line_number(+)
and pbsm.auction_shipment_number = pas.shipment_number(+)
AND l_neg_has_price_breaks = 'Y'
AND paip.auction_header_id = pbsm.auction_header_id
AND paip.line_number = pbsm.line_number
AND pbsm.shipment_type = 'PRICE BREAK'
AND mp.organization_id(+) = pbsm.ship_to_organization_id
AND loc.location_id(+) = pbsm.ship_to_location_id
and exists (select 1 from pon_bid_item_prices where bid_number=pbsm.bid_number and line_number=pbsm.line_number)

UNION ALL

SELECT  pas.shipment_number,
  pas.shipment_number bid_shipment_number,
	pas.ship_to_organization_id,
	mp.organization_code ship_to_organization,
	pas.ship_to_location_id,
	loc.location_code ship_to_location,
	pon_printing_pkg.format_number(pas.quantity) quantity,
        pon_printing_pkg.format_price(
          pon_transform_bidding_pkg.calculate_price(p_auction_header_id, pas.line_number, pas.price*l_rate, paip.quantity, p_trading_partner_id,p_trading_partner_contact_id,p_vendor_site_id, p_requested_supplier_id),
          l_price_mask,
          l_price_precision
        )  price,
	PON_OA_UTIL_PKG.DISPLAY_DATE(pas.effective_start_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') effective_start_date,
	PON_OA_UTIL_PKG.DISPLAY_DATE(pas.effective_end_date, p_client_time_zone, p_server_time_zone, p_date_format,'N') effective_end_date,
	nvl2(pas.ship_to_location_id, loc.location_code, mp.organization_code) ship_to,
	pas.has_price_differentials_flag,
	pas.differential_response_type,
        null bid_currency_price,
        null price_type,
        null price_discount
FROM pon_auction_shipments_all pas,
 pon_auction_item_prices_all paip,
 hr_locations_all loc,
 mtl_parameters mp
WHERE pas.auction_header_id = p_auction_header_id
AND pas.line_number = line_num
AND l_neg_has_price_breaks = 'Y'
AND paip.auction_header_id = pas.auction_header_id
AND paip.line_number = pas.line_number
AND pas.shipment_type = 'PRICE BREAK'
AND mp.organization_id(+) = pas.ship_to_organization_id
AND loc.location_id(+) = pas.ship_to_location_id
and not exists (select 1 from pon_bid_item_prices where bid_number=p_bid_number and line_number=paip.line_number);

BEGIN
        itempbreaksCtx := DBMS_XMLGEN.newContext(item_pb_cursor);
        DBMS_XMLGEN.SetRowSetTag(itempbreaksCtx, 'ITEM_PRICE_BREAKS');
        DBMS_XMLGEN.SetRowTag(itempbreaksCtx, 'ITEM_PRICE_BREAKS_ROW');
        item_pb_res := NULL;
        DBMS_XMLGEN.getXMLType(itempbreaksCtx, item_pb_res, DBMS_XMLGEN.NONE);
        IF item_pb_res IS NULL THEN
          item_pb_res := XMLType('<ITEM_PRICE_BREAKS></ITEM_PRICE_BREAKS>');
        END IF;
        Dbms_Lob.append(xml_clob, item_pb_res.getCLOBVal());
        exception when others then
            DBMS_XMLGEN.closeContext (itempbreaksCtx);
        RAISE;
       END;

       CLOSE item_pb_cursor;

OPEN item_price_diff_cursor FOR SELECT
  ppd.line_number,
  ppd.shipment_number,
  ppd.price_differential_number,
  ppd.price_type,
  pon_printing_pkg.format_number(ppd.multiplier) as target_multiplier,
  pon_printing_pkg.format_number(pbpd.multiplier) as multiplier
FROM pon_price_differentials ppd,
-- bidpdf: add response multiplier for price differentials
pon_bid_price_differentials pbpd
WHERE ppd.auction_header_id = p_auction_header_id
AND ppd.line_number = line_num
and pbpd.auction_header_id(+) = ppd.auction_header_id
and pbpd.bid_number (+) = p_bid_number
and pbpd.line_number (+) = ppd.line_number
and pbpd.shipment_number(+) = ppd.shipment_number + 1
and ppd.shipment_number <> -1
and pbpd.price_differential_number(+) = ppd.price_differential_number
ORDER BY shipment_number, price_differential_number;

BEGIN
        itempdiffsCtx := DBMS_XMLGEN.newContext(item_price_diff_cursor);
        DBMS_XMLGEN.SetRowSetTag(itempdiffsCtx, 'ITEM_PRICE_DIFFERENTIALS');
        DBMS_XMLGEN.SetRowTag(itempdiffsCtx, 'ITEM_PRICE_DIFFERENTIALS_ROW');
        item_price_diff_res := NULL;
        DBMS_XMLGEN.getXMLType(itempdiffsCtx, item_price_diff_res, DBMS_XMLGEN.NONE);
        IF item_price_diff_res IS NULL THEN
          item_price_diff_res := XMLType('<ITEM_PRICE_DIFFERENTIALS></ITEM_PRICE_DIFFERENTIALS>');
        END IF;
        Dbms_Lob.append(xml_clob, item_price_diff_res.getCLOBVal());
        exception when others then
            DBMS_XMLGEN.closeContext (itempdiffsCtx);
            RAISE;
       END;

       CLOSE item_price_diff_cursor;

OPEN item_quan_cursor FOR SELECT  pbsm.auction_shipment_number shipment_number,
        pbsm.shipment_number bid_shipment_number,
	    pon_printing_pkg.format_number(pbsm.quantity) quantity,
        pon_printing_pkg.format_number(pbsm.max_quantity) max_quantity,
        -- in case when supplier add new shipments, there's no target price
        nvl2(pbsm.auction_shipment_number,
                 pon_printing_pkg.format_price(pon_transform_bidding_pkg.calculate_price(p_auction_header_id,
                                    pas.line_number, pas.price*l_rate, paip.quantity, p_trading_partner_id, p_trading_partner_contact_id, p_vendor_site_id,
                                    p_requested_supplier_id),l_price_mask, l_price_precision)
                 , null
        ) price,
        decode(p_user_view_type, 'BUYER',pon_printing_pkg.format_price(pbsm.unit_price,l_price_mask, l_price_precision), pon_printing_pkg.format_price(pbsm.bid_currency_unit_price,l_price_mask, l_price_precision)) bid_currency_unit_price
FROM pon_auction_shipments_all pas,
 pon_auction_item_prices_all paip,
 pon_bid_shipments pbsm
WHERE pbsm.bid_number = p_bid_number
AND pbsm.line_number = line_num
and pbsm.auction_header_id = pas.auction_header_id(+)
and pbsm.line_number = pas.line_number(+)
and pbsm.auction_shipment_number = pas.shipment_number(+)
AND paip.auction_header_id = pbsm.auction_header_id
AND paip.line_number = pbsm.line_number
AND pbsm.shipment_type = 'QUANTITY BASED'
and exists (select 1 from pon_bid_item_prices where bid_number=pbsm.bid_number and line_number=pbsm.line_number)

UNION ALL

SELECT  pas.shipment_number,
    pas.shipment_number bid_shipment_number,
   	pon_printing_pkg.format_number(pas.quantity) quantity,
   	pon_printing_pkg.format_number(pas.max_quantity) max_quantity,
        pon_printing_pkg.format_price(
          pon_transform_bidding_pkg.calculate_price(p_auction_header_id, pas.line_number, pas.price*l_rate, paip.quantity, p_trading_partner_id,p_trading_partner_contact_id,p_vendor_site_id, p_requested_supplier_id),
          l_price_mask,
          l_price_precision
        )  price,
        null bid_currency_unit_price
FROM pon_auction_shipments_all pas,
    pon_auction_item_prices_all paip
WHERE pas.auction_header_id = p_auction_header_id
AND pas.line_number = line_num
AND paip.auction_header_id = pas.auction_header_id
AND paip.line_number = pas.line_number
AND pas.shipment_type = 'QUANTITY BASED'
and not exists (select 1 from pon_bid_item_prices where bid_number=p_bid_number and line_number=paip.line_number)
ORDER BY bid_shipment_number ASC;

BEGIN
        quanTiersCtx := DBMS_XMLGEN.newContext(item_quan_cursor);
        DBMS_XMLGEN.SetRowSetTag(quanTiersCtx, 'ITEM_QUANTITY_TIERS');
        DBMS_XMLGEN.SetRowTag(quanTiersCtx, 'ITEM_QUANTITY_TIERS_ROW');
        item_quan_res := NULL;
        DBMS_XMLGEN.getXMLType(quanTiersCtx, item_quan_res, DBMS_XMLGEN.NONE);
        IF item_quan_res IS NULL THEN
          item_quan_res := XMLType('<ITEM_QUANTITY_TIERS></ITEM_QUANTITY_TIERS>');
        END IF;
        Dbms_Lob.append(xml_clob, item_quan_res.getCLOBVal());
        exception when others then
            DBMS_XMLGEN.closeContext (quanTiersCtx);
        RAISE;
       END;

       CLOSE item_quan_cursor;

Dbms_Lob.append(xml_clob, '</LINES_ROW>');
CLOSE lines_cursor;
END LOOP;
        DBMS_XMLGEN.closeContext (linesCtx);
        DBMS_XMLGEN.closeContext (payItemsCtx);
        DBMS_XMLGEN.closeContext (attrsCtx);
        DBMS_XMLGEN.closeContext (pfCtx);
        DBMS_XMLGEN.closeContext (linepdiffCtx);
        DBMS_XMLGEN.closeContext (itempbreaksCtx);
        DBMS_XMLGEN.closeContext (itempdiffsCtx);
        DBMS_XMLGEN.closeContext (quanTiersCtx);
	DBMS_XMLGEN.closeContext (attrsScoreCtx);
Dbms_Lob.append(xml_clob, '</LINES>');

CLOSE line_num_cur;

OPEN collab_team_cursor FOR
SELECT
  TM.AUCTION_HEADER_ID,
  P.full_name,
  S.NAME position_name,
  tm.approver_flag,
  tm.menu_name,
  flkp.meaning member_access_type,
  tm.task_name,
  pon_oa_util_pkg.display_date(tm.target_date,
                               p_client_time_zone,
                               p_server_time_zone,
                               p_date_format, 'N') target_date
FROM
  PON_AUCTION_HEADERS_ALL PAH,
  PON_NEG_TEAM_MEMBERS TM,
  FND_USER U,
  PER_ALL_PEOPLE_F P,
  PER_ALL_ASSIGNMENTS_F A,
  PER_ALL_POSITIONS S,
  FND_LOOKUPS flkp
WHERE PAH.auction_header_id = p_auction_header_id
  AND  TM.AUCTION_HEADER_ID = pah.auction_header_id
  AND l_is_buyer_negpdf = 'Y'
  AND pah.neg_team_enabled_flag = 'Y'
  AND TM.LAST_AMENDMENT_UPDATE <= pah.amendment_number
  AND tm.menu_name = flkp.lookup_code
  AND flkp.lookup_type = 'PON_NEG_TEAM_MEMBER_ACCESS'
  AND U.USER_ID = TM.USER_ID
  AND U.EMPLOYEE_ID = P.PERSON_ID
  AND P.EFFECTIVE_END_DATE =
  (SELECT MAX(PP.EFFECTIVE_END_DATE)
   FROM PER_ALL_PEOPLE_F PP
   WHERE PP.PERSON_ID = U.EMPLOYEE_ID)
   AND A.PERSON_ID  = P.PERSON_ID
   AND A.PRIMARY_FLAG  = 'Y'
   AND ((A.ASSIGNMENT_TYPE = 'E' AND P.CURRENT_EMPLOYEE_FLAG = 'Y')
        OR
        (A.ASSIGNMENT_TYPE = 'C' AND P.CURRENT_NPW_FLAG = 'Y'))
   AND A.EFFECTIVE_END_DATE =
   (SELECT MAX(AA.EFFECTIVE_END_DATE)
    FROM PER_ALL_ASSIGNMENTS_F AA
    WHERE AA.PRIMARY_FLAG = 'Y'
    AND AA.ASSIGNMENT_TYPE in ('E', 'C')
    AND AA.PERSON_ID = P.PERSON_ID)
    AND A.POSITION_ID = S.POSITION_ID(+)
    AND TM.AUCTION_HEADER_ID = pah.auction_header_id
    AND TRUNC(SYSDATE) BETWEEN P.EFFECTIVE_START_DATE AND P.EFFECTIVE_END_DATE
ORDER BY P.FULL_NAME, U.USER_NAME;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(collab_team_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'COLLABORATION_TEAM');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'COLLABORATION_TEAM_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, collab_team_res, DBMS_XMLGEN.NONE);
        IF collab_team_res IS NULL THEN
          collab_team_res := XMLType('<COLLABORATION_TEAM></COLLABORATION_TEAM>');
        END IF;
        Dbms_Lob.append(xml_clob, collab_team_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE collab_team_cursor;

OPEN scoring_team_cursor FOR
SELECT sctm.team_id
      ,sctm.team_name
      ,sctm.price_visible_flag
      ,sctm.instruction_text
FROM  pon_auction_headers_all pah,
      pon_scoring_teams sctm
WHERE pah.auction_header_id = p_auction_header_id
  AND sctm.auction_header_id = pah.auction_header_id
  AND pah.has_scoring_teams_flag = 'Y' -- teams present only if flag present
ORDER BY sctm.team_name;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(scoring_team_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'SCORING_TEAMS');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'SCORING_TEAMS_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, scoring_team_res, DBMS_XMLGEN.NONE);
        IF scoring_team_res IS NULL THEN
          scoring_team_res := XMLType('<SCORING_TEAMS></SCORING_TEAMS>');
        END IF;
        Dbms_Lob.append(xml_clob, scoring_team_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE scoring_team_cursor;

OPEN scoring_mems_cursor FOR
SELECT DISTINCT -- Distinct added because sometimes an employee may have
                -- multipler user ids resulting in more rows being returned
       stmem.team_id
      ,stmem.user_id
      ,per.full_name member_name
FROM  pon_auction_headers_all pah
      ,pon_scoring_team_members stmem
      ,fnd_user fuser
      ,per_all_people_f per
WHERE pah.auction_header_id = p_auction_header_id
 AND  stmem.auction_header_id = pah.auction_header_id
 AND  stmem.user_id           = fuser.user_id
 AND  fuser.employee_id        = per.person_id
 AND  pah.has_scoring_teams_flag = 'Y' -- members present only if teams present
 AND  per.effective_end_date = (select max(pp.effective_end_date) from per_all_people_f pp where pp.person_id = per.person_id);

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(scoring_mems_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'SCORING_TEAM_MEMBERS');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'SCORING_TEAM_MEMBERS_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, scoring_mems_res, DBMS_XMLGEN.NONE);
        IF scoring_mems_res IS NULL THEN
          scoring_mems_res := XMLType('<SCORING_TEAM_MEMBERS></SCORING_TEAM_MEMBERS>');
        END IF;
        Dbms_Lob.append(xml_clob, scoring_mems_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE scoring_mems_cursor;


OPEN scoring_secs_cursor for
SELECT team_sections.section_id
      ,sections.section_name
      ,team_sections.auction_header_id
      ,team_sections.team_id
 FROM  pon_auction_headers_all pah,
       pon_scoring_team_sections team_sections
      ,pon_auction_sections sections
WHERE pah.auction_header_id = p_auction_header_id
  AND team_sections.auction_header_id = pah.auction_header_id
  AND sections.section_id             = team_sections.section_id
  AND sections.auction_header_id      = team_sections.auction_header_id
  AND pah.has_scoring_teams_flag = 'Y'; -- sections present only if teams present


      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(scoring_secs_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'SCORING_TEAM_SECTIONS');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'SCORING_TEAM_SECTIONS_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, scoring_secs_res, DBMS_XMLGEN.NONE);
        IF scoring_secs_res IS NULL THEN
          scoring_secs_res := XMLType('<SCORING_TEAM_SECTIONS></SCORING_TEAM_SECTIONS>');
        END IF;
        Dbms_Lob.append(xml_clob, scoring_secs_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE scoring_secs_cursor;


OPEN abstracts_cursor FOR
SELECT
  forms_tl.form_name,
  forms.form_version,
  forms.form_id,
  forms.form_code
FROM
  pon_forms_instances form_instances,
  pon_forms_sections forms,
  pon_forms_sections_tl forms_tl
WHERE
      form_instances.entity_code = 'PON_AUCTION_HEADERS_ALL'
  AND form_instances.entity_pk1 = TO_CHAR(p_auction_header_id)
  AND l_is_buyer_negpdf = 'Y'
  AND forms_tl.language = l_printing_language
  AND form_instances.form_id = forms.form_id
  AND forms.form_id = forms_tl.form_id
ORDER BY form_name;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(abstracts_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'ABSTRACT_AND_FORMS');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'ABSTRACT_AND_FORMS_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, abstracts_res, DBMS_XMLGEN.NONE);
        IF abstracts_res IS NULL THEN
          abstracts_res := XMLType('<ABSTRACT_AND_FORMS></ABSTRACT_AND_FORMS>');
        END IF;
        Dbms_Lob.append(xml_clob, abstracts_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE abstracts_cursor;


OPEN currency_cursor FOR
select
pacr.bid_currency_code,
ftl.name bid_currency_name,
pacr.number_price_decimals,
-- bug 8667493 following column added to display EMD amount, if enabled, in different currencies
to_char((Nvl(pah.emd_amount,0) * pacr.rate),'FM999G999G999G999G999G999G999G999G999G999D00') emd_resp_curr_amount,
pon_printing_pkg.get_display_rate(pacr.rate_dsp,pah.rate_type,pah.rate_date,pah.currency_code,bid_currency_code) display_rate
FROM
pon_auction_headers_all pah,
pon_auction_currency_rates pacr ,
fnd_currencies_tl ftl
where
pah.auction_header_id = p_auction_header_id
AND pacr.auction_header_id = pah.auction_header_id
and ftl.currency_code = pacr.bid_currency_code
and ftl.language = l_printing_language;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(currency_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'CURRENCY');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'CURRENCY_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, currency_res, DBMS_XMLGEN.NONE);
        IF currency_res IS NULL THEN
          currency_res := XMLType('<CURRENCY></CURRENCY>');
        END IF;
        Dbms_Lob.append(xml_clob, currency_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE currency_cursor;


OPEN invited_supp_cur_cursor FOR
SELECT
  pbp.bid_currency_code,
  ftl.name bid_currency_name,
  pbp.number_price_decimals,
  -- bug 8667493 following column added to display EMD amount, if enabled, in different currencies
  to_char((Nvl(pah.emd_amount,0) * pbp.rate),'FM999G999G999G999G999G999G999G999G999G999D00') emd_resp_curr_amount,
  nvl2(pbp.rate_dsp, pon_printing_pkg.format_number(pbp.rate_dsp), null) as display_rate
FROM
  pon_auction_headers_all pah,
  pon_bidding_parties pbp,
  fnd_currencies_tl ftl
WHERE pah.auction_header_id = p_auction_header_id
  AND pbp.auction_header_id = pah.auction_header_id
  AND (l_is_buyer_negpdf = 'N')
  AND ftl.currency_code = pbp.bid_currency_code
  AND ftl.language = l_printing_language
  AND ((pbp.trading_partner_id = l_trading_partner_id
        AND pbp.vendor_site_id = p_vendor_site_id)
       OR pbp.requested_supplier_id = p_requested_supplier_id)
ORDER BY sequence ASC;
--) AS INVITED_SUPPLIER_CURRENCY,

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(invited_supp_cur_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'INVITED_SUPPLIER_CURRENCY');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'INVITED_SUPPLIER_CURRENCY_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, invited_supp_cur_res, DBMS_XMLGEN.NONE);
        IF invited_supp_cur_res IS NULL THEN
          invited_supp_cur_res := XMLType('<INVITED_SUPPLIER_CURRENCY></INVITED_SUPPLIER_CURRENCY>');
        END IF;
        Dbms_Lob.append(xml_clob, invited_supp_cur_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE invited_supp_cur_cursor;


--Fixed GSCC errors
OPEN header_attr_cursor FOR
select sum(nvl(ponaaouter.weight,0)) weight,
sum(nvl(ponaaouter.attr_max_score,0)) score,
 pass.section_name,
 nvl(pass.two_part_section_type,'') two_part_section_type,
cursor (select
  ponaainner.auction_header_id,
  ponaainner.line_number,
  ponaainner.attribute_name as header_attribute_name,
  ponaainner.description,
  ponaainner.datatype,
  ponaainner.mandatory_flag,
  print_attribute_target_value(ponaainner.display_target_flag, ponaainner.value, ponaainner.datatype,10, p_client_time_zone, p_server_time_zone, p_date_format, p_user_view_type) value,
  ponaainner.display_prompt,
  ponaainner.display_target_flag,
  ponaainner.display_only_flag,
  ponaainner.sequence_number,
  nvl(ponaainner.weight,0) weight,
  ponaainner.scoring_type,
  ponaainner.attr_level,
  ponaainner.attr_group,
  ponaainner.attr_max_score,
  ponaainner.internal_attr_flag,
  ponaainner.attr_group_seq_number,
  ponaainner.attr_disp_seq_number,
  ponaainner.knockout_score,
  ponaainner.scoring_method,
  print_attribute_response_value(pbav.value, pbav.datatype, p_client_time_zone, p_server_time_zone, p_date_format, pbav.sequence_number) attribute_bid_value,
  pbav.score attribute_bid_score,
  cursor( select
   pas.auction_header_id,
   pas.line_number,
   pas.attribute_sequence_number,
   pas.value,
   pas.from_range,
   pas.to_range,
   pas.score,
   pas.sequence_number,
   pon_printing_pkg.get_acceptable_value(pah.HDR_ATTR_DISPLAY_SCORE,pas.attribute_sequence_number,ponaainner.datatype,pas.from_range,pas.to_range,pas.value,pas.score, p_client_time_zone, p_server_time_zone, p_date_format, l_is_buyer_negpdf) display_score
  from
   pon_auction_headers_all pah,
   pon_attribute_scores pas
  where
   pah.auction_header_id = p_auction_header_id
   AND pas.auction_header_id = ponaainner.auction_header_id
   and pas.line_number = -1
   and pas.attribute_sequence_number = ponaainner.sequence_number
   order by pas.attribute_sequence_number,pas.sequence_number
  ) as HEADER_ATTRIBUTE_SCORES
  from
  pon_auction_attributes ponaainner, pon_bid_attribute_values pbav
  where
  ponaainner.auction_header_id = ponaaouter.auction_header_id
  --bidpdf: add bid values for attributes from table pon_bid_attribute_values
  -- The table has index on bid_number, line_number, sequence_number
  and pbav.auction_header_id(+) = ponaainner.auction_header_id
  and pbav.bid_number(+) = p_bid_number
  and pbav.line_number(+) = ponaainner.line_number
  and pbav.sequence_number(+) = ponaainner.sequence_number
  and ponaainner.section_name = ponaaouter.section_name
  and ponaainner.line_number = -1
  and ponaainner.attr_level='HEADER'
  and (l_is_buyer_negpdf = 'Y' or ponaainner.internal_attr_flag <> 'Y')
  order by ponaainner.attr_disp_seq_number) as HEADER_ATTRIBUTES_DETAILS
from
pon_auction_attributes ponaaouter,pon_auction_sections pass
where
pass.auction_header_id = p_auction_header_id
and pass.auction_header_id = ponaaouter.auction_header_id(+)
and pass.section_name = ponaaouter.section_name(+)
and ponaaouter.attr_level(+)='HEADER'
and ponaaouter.line_number(+) = -1
and (l_is_buyer_negpdf = 'Y' or ponaaouter.internal_attr_flag <> 'Y')
and (l_is_section_restricted = 'N'
    or l_is_section_restricted = 'Y'
      and ponaaouter.attr_group_seq_number in (
        select pas.attr_group_seq_number
        from pon_scoring_team_members pstm, pon_scoring_team_sections psts, pon_auction_sections pas
        where pstm.auction_header_id = p_auction_header_id
          and pstm.user_id = p_user_id
          and psts.auction_header_id = pstm.auction_header_id
          and psts.team_id = pstm.team_id
          and psts.section_id = pas.section_id
          and psts.auction_header_id = pas.auction_header_id
      )
    )
and ((l_hide_comm_part = 'Y' and pass.two_part_section_type = 'TECHNICAL') or l_hide_comm_part <> 'Y')
group by(pass.section_name,ponaaouter.auction_header_id,ponaaouter.section_name,pass.auction_header_id,pass.attr_group_seq_number, two_part_section_type)
order by pass.attr_group_seq_number;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(header_attr_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'GROUP_HEADER_ATTRIBUTES');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'GROUP_HEADER_ATTRIBUTES_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, header_attr_res, DBMS_XMLGEN.NONE);
        IF header_attr_res IS NULL THEN
          header_attr_res := XMLType('<GROUP_HEADER_ATTRIBUTES></GROUP_HEADER_ATTRIBUTES>');
        END IF;
        Dbms_Lob.append(xml_clob, header_attr_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE header_attr_cursor;


OPEN invited_supp_cursor FOR
SELECT
  decode(pbp.trading_partner_id, null, pbp.requested_supplier_name, pbp.trading_partner_name) trading_partner_name,
  pbp.vendor_site_code,
  decode(pbp.trading_partner_contact_id, null, pbp.requested_supp_contact_name, PON_LOCALE_PKG.get_party_display_name(pbp.trading_partner_contact_id)) contact_name,
  pbp.additional_contact_email,
  pbp.bid_currency_code,
  pbp.rate_dsp,
  nvl2(pbp.rate_dsp, pon_printing_pkg.format_number(pbp.rate_dsp), null) as rate_dsp_display,
  pbp.number_price_decimals,
  pbp.access_type,
  pbp.auction_header_id,
  pbp.trading_partner_id,
  pbp.trading_partner_contact_id,
  pbp.sequence
FROM pon_bidding_parties pbp
WHERE
      pbp.auction_header_id = p_auction_header_id
  AND l_is_buyer_negpdf = 'Y'
ORDER BY sequence ASC;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(invited_supp_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'INVITED_SUPPLIERS');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'INVITED_SUPPLIERS_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, invited_supp_res, DBMS_XMLGEN.NONE);
        IF invited_supp_res IS NULL THEN
          invited_supp_res := XMLType('<INVITED_SUPPLIERS></INVITED_SUPPLIERS>');
        END IF;
        Dbms_Lob.append(xml_clob, invited_supp_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE invited_supp_cursor;


OPEN line_pf_cursor FOR
SELECT
  pet.name,
  flv.meaning pricing_basis_display,
  pet.description,
  flv2.meaning pf_type_display
FROM
  pon_price_element_types_tl pet,
  fnd_lookup_values flv,
  fnd_lookup_values flv2
WHERE
      pet.language = l_printing_language
  AND pet.price_element_type_id = -10
  AND flv.lookup_type = 'PON_PRICING_BASIS'
  AND flv.language = l_printing_language
  AND flv.lookup_code = 'PER_UNIT'
  AND flv.view_application_id = 0
  AND flv.security_group_id = 0
  AND flv2.lookup_type = 'PON_PRICE_FACTOR_TYPE'
  AND flv2.language = l_printing_language
  AND flv2.lookup_code = 'SUPPLIER'
  AND flv2.view_application_id = 0
  AND flv2.security_group_id = 0;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(line_pf_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'LINE_PRICE_PF_DETAILS');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'LINE_PRICE_PF_DETAILS_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, line_pf_res, DBMS_XMLGEN.NONE);
        IF line_pf_res IS NULL THEN
          line_pf_res := XMLType('<LINE_PRICE_PF_DETAILS></LINE_PRICE_PF_DETAILS>');
        END IF;
        Dbms_Lob.append(xml_clob, line_pf_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE line_pf_cursor;


OPEN buyer_pf_cursor FOR
SELECT
  pf_values.auction_header_id,
  pf_values.line_number,
  pf_values.pf_seq_number,
  pf_values.supplier_seq_number,
  pf_values.value,
  pfs.price_element_type_id,
  pfs.pricing_basis
FROM
  pon_auction_headers_all pah,
  pon_price_elements pfs,
  pon_pf_supplier_values pf_values
WHERE pah.auction_header_id = p_auction_header_id
  and pf_values.auction_header_id = pah.auction_header_id
  AND pah.large_neg_enabled_flag = 'N'
  AND l_is_buyer_negpdf = 'Y'
  AND pf_values.auction_header_id = pfs.auction_header_id
  AND pf_values.line_number = pfs.line_number
  AND pf_values.pf_seq_number = pfs.sequence_number
ORDER BY pf_values.supplier_seq_number, pf_values.line_number, pf_values.pf_seq_number;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(buyer_pf_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'BUYER_PF_VALUES');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'BUYER_PF_VALUES_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, buyer_pf_res, DBMS_XMLGEN.NONE);
        IF buyer_pf_res IS NULL THEN
          buyer_pf_res := XMLType('<BUYER_PF_VALUES></BUYER_PF_VALUES>');
        END IF;
        Dbms_Lob.append(xml_clob, buyer_pf_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE buyer_pf_cursor;


OPEN dist_buyer_pf_cursor FOR
SELECT DISTINCT
  ppe.price_element_type_id,
  ppe.pricing_basis,
  ppett.name,
  fl.meaning as pricing_basis_meaning
FROM
  pon_auction_headers_all pah,
  pon_price_elements ppe,
  pon_price_element_types_tl ppett,
  fnd_lookups fl
WHERE pah.auction_header_id = p_auction_header_id
  and ppe.auction_header_id = pah.auction_header_id
  AND pah.large_neg_enabled_flag = 'N'
  AND l_is_buyer_negpdf = 'Y'
  AND ppe.pf_type = 'BUYER'
  AND ppe.price_element_type_id = ppett.price_element_type_id
  AND ppett.language = l_printing_language
  AND ppe.pricing_basis = fl.lookup_code
  AND fl.lookup_type = 'PON_PRICING_BASIS'
ORDER BY name, pricing_basis_meaning;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(dist_buyer_pf_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'DISTINCT_BUYER_PFS');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'DISTINCT_BUYER_PFS_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, dist_buyer_pf_res, DBMS_XMLGEN.NONE);
        IF dist_buyer_pf_res IS NULL THEN
          dist_buyer_pf_res := XMLType('<DISTINCT_BUYER_PFS></DISTINCT_BUYER_PFS>');
        END IF;
        Dbms_Lob.append(xml_clob, dist_buyer_pf_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE dist_buyer_pf_cursor;


OPEN large_neg_bur_pf_cursor FOR
    select
    pon_large_neg_pf_values.supplier_seq_number,
    priceelementtypesvl.name||'('||lookuptable.meaning||')' pf_name,
    pon_large_neg_pf_values.value
    from
    pon_auction_headers_all pah,
    pon_large_neg_pf_values pon_large_neg_pf_values,
    pon_price_element_types_vl priceelementtypesvl,
    fnd_lookups lookuptable
    WHERE pah.auction_header_id = p_auction_header_id
    AND pon_large_neg_pf_values.auction_header_id = pah.auction_header_id
    and pah.large_neg_enabled_flag = 'Y'
    AND l_is_buyer_negpdf = 'Y'
    AND priceelementtypesvl.price_element_type_id = pon_large_neg_pf_values.price_element_type_id
    AND lookuptable.lookup_code = pon_large_neg_pf_values.pricing_basis
    AND lookuptable.lookup_type =  'PON_PRICING_BASIS'
    AND pon_large_neg_pf_values.value is not null
    order by pon_large_neg_pf_values.supplier_seq_number,pf_name;

       BEGIN
        queryCtx := DBMS_XMLGEN.newContext(large_neg_bur_pf_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'LARGE_NEG_BUYER_PF_VALUES');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'LARGE_NEG_BUYER_PF_VALUES_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, large_neg_bur_pf_res, DBMS_XMLGEN.NONE);
        IF large_neg_bur_pf_res IS NULL THEN
          large_neg_bur_pf_res := XMLType('<LARGE_NEG_BUYER_PF_VALUES></LARGE_NEG_BUYER_PF_VALUES>');
        END IF;
        Dbms_Lob.append(xml_clob, large_neg_bur_pf_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE large_neg_bur_pf_cursor;


OPEN pb_loc_cursor FOR
select
distinct loc.location_id id,
loc.location_code name,
ship_territories_tl.territory_short_name country_name,
loc.location_code address_name,
loc.address_line_1 address1,
loc.address_line_2 address2,
loc.address_line_3 address3,
loc.town_or_city city,
loc.region_2 state,
loc.region_3 province_or_region,
loc.postal_code zip_code,
loc.postal_code postal_code,
loc.country country,
loc.region_1 county
from
hr_locations_all loc,
pon_auction_shipments_all pas,
fnd_territories_tl ship_territories_tl
WHERE
pas.auction_header_id = p_auction_header_id
and l_is_buyer_negpdf = 'N'
and l_neg_has_price_breaks = 'Y'
and pas.shipment_type = 'PRICE BREAK'
and loc.ship_to_site_flag='Y'
and sysdate < nvl(loc.inactive_date, sysdate + 1)
and loc.location_id = pas.ship_to_location_id
and ship_territories_tl.territory_code(+) = loc.country
and ship_territories_tl.language(+) = l_printing_language
and nvl(loc.business_group_id, nvl(hr_general.get_business_group_id, -99))
    = nvl(hr_general.get_business_group_id, nvl(loc.business_group_id, -99))
union
(select
mp.organization_id id,
mp.organization_code name,
ship_territories_tl.territory_short_name country_name,
loc.location_code address_name,
loc.address_line_1 address1,
loc.address_line_2 address2,
loc.address_line_3 address3,
loc.town_or_city city,
loc.region_2 state,
loc.region_3 province_or_region,
loc.postal_code zip_code,
loc.postal_code postal_code,
loc.country country,
loc.region_1 county
from
hr_locations_all loc,
hr_all_organization_units haou,
fnd_territories_tl ship_territories_tl,
mtl_parameters mp ,
( SELECT
   distinct pas.ship_to_organization_id
   FROM pon_auction_shipments_all pas
   WHERE
   pas.auction_header_id = p_auction_header_id
   AND l_is_buyer_negpdf = 'N'
   AND l_neg_has_price_breaks = 'Y'
   AND pas.shipment_type = 'PRICE BREAK'
   and pas.ship_to_location_id is null) pb_organizations
where
    l_is_buyer_negpdf = 'N'
and l_neg_has_price_breaks = 'Y'
and haou.organization_id = mp.organization_id
and haou.organization_id = pb_organizations.ship_to_organization_id
and loc.ship_to_site_flag = 'Y'
and (loc.inventory_organization_id is null  or nvl(loc.inventory_organization_id, -1) = nvl(pb_organizations.ship_to_organization_id,-1))
and sysdate < nvl(loc.inactive_date, sysdate + 1)
and ship_territories_tl.territory_code(+) = loc.country
and ship_territories_tl.language(+) = l_printing_language
and nvl(loc.business_group_id, nvl(haou.business_group_id, -99))
    = nvl(haou.business_group_id, nvl(loc.business_group_id, -99))
)
order
by name;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(pb_loc_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'PRICE_BREAK_LOCATIONS');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'PRICE_BREAK_LOCATIONS_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, pb_loc_res, DBMS_XMLGEN.NONE);
        IF pb_loc_res IS NULL THEN
          pb_loc_res := XMLType('<PRICE_BREAK_LOCATIONS></PRICE_BREAK_LOCATIONS>');
        END IF;
        Dbms_Lob.append(xml_clob, pb_loc_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE pb_loc_cursor;


OPEN price_diff_types_cursor FOR
SELECT DISTINCT
  pov.price_differential_dsp,
  pov.price_differential_desc,
	pov.price_differential_type
FROM po_price_diff_lookups_v pov;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(price_diff_types_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'PRICE_DIFFERENTIAL_TYPES');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'PRICE_DIFFERENTIAL_TYPES_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, price_diff_types_res, DBMS_XMLGEN.NONE);
        IF price_diff_types_res IS NULL THEN
          price_diff_types_res := XMLType('<PRICE_DIFFERENTIAL_TYPES></PRICE_DIFFERENTIAL_TYPES>');
        END IF;
        Dbms_Lob.append(xml_clob, price_diff_types_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE price_diff_types_cursor;


OPEN attachments_cursor FOR
select ad.attached_document_id,
      d.datatype_name,
      d.file_name file_name,
      d.description,
      d.title as attachment_title,
      d.url,
      'PON_AUCTION_ITEM_PRICES_ALL' as entity_name,
      to_char(paip.auction_header_id) pk1_value,
      to_char(paip.line_number) pk2_value,
      ad.pk3_value,
      categories_tl.user_name category_name
from pon_auction_headers_all pah,
fnd_documents_vl d,
fnd_attached_documents ad,
fnd_document_categories categories,
fnd_document_categories_tl categories_tl,
pon_auction_item_prices_all paip,
financials_system_params_all fsp
where d.document_id = ad.document_id
and
ad.entity_name = 'MTL_SYSTEM_ITEMS'
AND pah.auction_header_id = p_auction_header_id
AND paip.auction_header_id = pah.auction_header_id
and fsp.org_id = pah.org_id
and ad.pk1_value = to_char(fsp.inventory_organization_id)
AND ad.pk2_value = to_char(paip.item_id)
and categories.name='Vendor'
and categories.category_id = d.category_id
and categories.category_id = categories_tl.category_id
and categories_tl.language = l_printing_language
UNION ALL
select ad.attached_document_id,
      d.datatype_name,
      d.file_name file_name,
      d.description,
      d.title,
      d.url,
      ad.entity_name,
      ad.pk1_value,
      ad.pk2_value,
      ad.pk3_value,
      categories_tl.user_name category_name
from fnd_documents_vl d,
fnd_attached_documents ad,
fnd_document_categories categories,
fnd_document_categories_tl categories_tl
where d.document_id = ad.document_id
and
ad.entity_name IN ('PON_AUCTION_ITEM_PRICES_ALL',
                   'PON_AUCTION_HEADERS_ALL')
and ad.pk1_value = to_char(p_auction_header_id)
and (l_is_buyer_negpdf = 'Y' or categories.name='Vendor')
and categories.category_id = d.category_id
and categories.category_id = categories_tl.category_id
and categories_tl.language = l_printing_language
--bidpdf:attachments in bid
UNION ALL
select ad.attached_document_id,
      d.datatype_name,
      d.file_name file_name,
      d.description,
      d.title,
      d.url,
      ad.entity_name,
      ad.pk1_value,
      ad.pk2_value,
      ad.pk3_value,
      categories_tl.user_name category_name
from pon_bid_headers pbhs,
fnd_documents_vl d,
fnd_attached_documents ad,
fnd_document_categories categories,
fnd_document_categories_tl categories_tl
where d.document_id = ad.document_id
AND
pbhs.auction_header_id (+) = p_auction_header_id
and pbhs.bid_number (+) = p_bid_number
AND ad.entity_name IN ('PON_BID_HEADERS',
                   'PON_BID_ITEM_PRICES')
and ad.pk1_value = to_char(p_auction_header_id)
and ad.pk2_value = to_char(pbhs.bid_number)
--and categories.name=pon_auction_pkg.g_supplier_attachment
and ((l_attach_categ_option = 1 AND categories.name = pon_auction_pkg.g_supplier_attachment)
	or (l_attach_categ_option = 2 and categories.name = pon_auction_pkg.g_technical_attachment)
	or (l_attach_categ_option = 3 and categories.name in (pon_auction_pkg.g_technical_attachment,pon_auction_pkg.g_commercial_attachment)))
and categories.category_id = d.category_id
and categories.category_id = categories_tl.category_id
and categories_tl.language = l_printing_language
--bidpdf:pay item attachments in bid
UNION ALL
select ad.attached_document_id,
      d.datatype_name,
      d.file_name file_name,
      d.description,
      d.title,
      d.url,
      ad.entity_name,
      ad.pk1_value,
      ad.pk2_value,
      ad.pk3_value,
      categories_tl.user_name category_name
from pon_bid_headers pbhs,
fnd_documents_vl d,
fnd_attached_documents ad,
fnd_document_categories categories,
fnd_document_categories_tl categories_tl
where d.document_id = ad.document_id
and pbhs.auction_header_id (+) = p_auction_header_id
and pbhs.bid_number (+) = p_bid_number
and
ad.entity_name IN ('PON_BID_PAYMENTS_SHIPMENTS')
and ad.pk1_value = to_char(pbhs.bid_number)
and categories.name = pon_auction_pkg.g_supplier_attachment
and categories.category_id = d.category_id
and categories.category_id = categories_tl.category_id
and categories_tl.language = l_printing_language
UNION ALL
select ad.attached_document_id,
      d.datatype_name,
      d.file_name file_name,
      d.description,
      d.title,
      d.url,
      ad.entity_name,
      ad.pk1_value,
      ad.pk2_value,
      --for bid pdf, it should be bid_payment_id instead of auction_payment_id,
      decode(l_is_bidpdf, 'Y',
                (select to_char(bid_payment_id) from PON_BID_PAYMENTS_SHIPMENTS pby where bid_number = p_bid_number and pby.auction_payment_id = to_number(ad.pk3_value)),
                ad.pk3_value) pk3_value,
      categories_tl.user_name category_name
from fnd_documents_vl d,
fnd_attached_documents ad,
fnd_document_categories categories,
fnd_document_categories_tl categories_tl
where d.document_id = ad.document_id
and
ad.entity_name IN ('PON_AUC_PAYMENTS_SHIPMENTS')
and ad.pk1_value = to_char(p_auction_header_id)
and (l_is_buyer_negpdf = 'Y' or categories.name = 'Vendor')
and categories.category_id = d.category_id
and categories.category_id = categories_tl.category_id
and categories_tl.language = l_printing_language;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(attachments_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'ATTACHMENTS');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'ATTACHMENTS_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, attachments_res, DBMS_XMLGEN.NONE);
        IF attachments_res IS NULL THEN
          attachments_res := XMLType('<ATTACHMENTS></ATTACHMENTS>');
        END IF;
        Dbms_Lob.append(xml_clob, attachments_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE attachments_cursor;


OPEN doc_rules_cursor FOR
select
bizrules.name
FROM
   pon_auction_headers_all pah
 , pon_auc_doctype_rules doctype_rules
 , pon_auc_bizrules bizrules
WHERE pah.auction_header_id = p_auction_header_id
AND doctype_rules.bizrule_id = bizrules.bizrule_id
and doctype_rules.doctype_id = pah.doctype_id
and doctype_rules.display_flag = 'Y'
and doctype_rules.validity_flag = 'Y'
and bizrules.name in (
'BID_LIST_TYPE',
'SHOW_BIDDER_NOTES',
'ALLOW_MULTIPLE_ROUNDS',
'BID_SCOPE',
'BID_QUANTITY_SCOPE',
'BID_FREQUENCY',
'MIN_BID_DECREMENT',
'MANUAL_CLOSE',
'MANUAL_EXTEND',
'AUTO_EXTENSION',
'RANK_INDICATOR',
'BID_RANKING',
'ALLOW_PRICE_ELEMENT',
'AWARD_APPROVAL_REQUIRED',
'DISPLAY_REQ_LINE_INTEGRATION_SOURCE',
'DISPLAY_LINE_INTEGRATION_SOURCE',
'GLOBAL_AGREEMENT',
'ALLOW_COLLABORATION_TEAM',
'START_PRICE',
'TARGET_PRICE',
'CURRENT_PRICE',
'CONTRACT_TYPE',
'ALLOW_PROXYBID',
'MIN_RELEASE_AMOUNT',
'BEST_PRICE'
);

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(doc_rules_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'DOCUMENT_TYPE_RULES');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'DOCUMENT_TYPE_RULES_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, doc_rules_res, DBMS_XMLGEN.NONE);
        IF doc_rules_res IS NULL THEN
          doc_rules_res := XMLType('<DOCUMENT_TYPE_RULES></DOCUMENT_TYPE_RULES>');
        END IF;
        Dbms_Lob.append(xml_clob, doc_rules_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE doc_rules_cursor;

OPEN generic_msgs_cursor FOR
select message_name,
message_text
from
fnd_new_messages
where message_name in ('PON_AUC_TITLE', --title
'PON_AUCTS_OPEN', -- Open Date
'PON_AUCTS_CLOSE', -- Close Date
'PON_AUCTS_PREVIEW', -- Preview Date
'PON_AUCTS_AWARD',  -- Award Date
'PON_AUC_IMMEDIATELY',  -- Immediately
'PON_AUC_STYLE',  -- Style
'PON_EFFECTIVE_START_DATE',  -- Effective Start Date
'PON_EFFECTIVE_END_DATE',  -- Effective End Date
'PON_ACCTS_BUYER',  -- Buyer
'PON_AUCTS_SHIP_TO_ADDRESS', --Ship-To Address
'PON_AUCTS_BILL_TO_ADDRESS', --Bill-To Address
'PON_AUCTS_PAYMENT_TERMS',  --Payment Terms
'PON_AUCTS_CARRIER',  --Carrier
'PON_AUCTS_FOB',  --FOB
'PON_AUCTS_FREIGHT_TERMS',  --Freight Terms
'PON_INTEL_AMOUNT',  --Amount
'PON_AUCTS_PRICE_PREC', -- Price Precision
'PON_AUCTS_LINE_NO', --Line No.
'PON_AUCTS_UNIT_PRICE', --Unit Price
'PON_AUCTS_NUMBER_OF_UNITS', --Number of Units
'PON_AUCTS_PRN_GENERAL_INFO', -- L.1. General Information
'PON_AUCTS_PRN_TERMS', --I.2 Terms
'PON_AUCTS_PRN_PRICE_SCHEDULE', --2 Price Schedule
'PON_AUCTS_PRN_LINE_INFO', --2.1 Line Information
'PON_AUCTS_EXCHANGE_RATE', --Exchange Rate
'PON_AUCTS_HEADER_INFORMATION', --1 Header Information
'PON_AUC_WEIGHT', --Weight
'PON_AUC_REQUIRES_NO_RESP', --This requires no response.
'PON_AUCTS_OPTIONAL_RESP', --The response is optional.
'PON_AUCTS_MUST_PROVIDE_RESP', --You must provide a response.
'PON_AUCTS_RESP_MUST_BE_NUMERIC', --The response must be a numeric value.
'PON_AUCTS_RESP_MUST_BE_DATE', --The response must be a date value.
'PON_AUC_RESPONSE_VALUE', --Response Value
'PON_AUC_PRN_LINE_ATTR_NOTE', --You must provide a response unless otherwise indicated.
'PON_AUC_ACCEPTABLE_VALUES', --Acceptable Values
'PON_AUC_ATTRIBUTES', --Attributes
'PON_AUC_PRN_REF_ONLY_NO_RESP', --This is for reference only and your response is not required.
'PON_AUC_ANY', --Any
'PON_AUC_NOT_SPECIFIED', --Not Specified
'PON_AUCTION_CURRENCY', --Currency
'PON_AUC_CURRENCY_DESCRIPTION', --Currency escription
'PON_AUC_SHIP_TO', --Ship To
'PON_AUCTS_NEED_BY_DATE', --Need-By Date
'PON_AUC_TARGET_VALUE', --Target value
'PON_AUC_ENSURE_CURR_SELECTED', --Please ensure that you have selected a currency in Section I.2
'PON_AUC_TIME_ZONE', --Time Zone
'PON_AUCTS_EMAIL', --Email
'PON_AUCTS_PHONE', --Phone
'PON_AUCTS_FAX', --Fax
'PON_AUC_CONTACT_DETAILS', --Contact Details
'PON_AUC_YOUR_COMPANY_NAME', --Your Company Name
'PON_AUC_NOTE_TO_SUPPLIER', --Note to Supplier
'PON_AMEND_DESCRIPTION', --Amendment Description
'PON_AMEND_DATE', --Amendment Date
'PON_AUC_RULES_FOR_REFERENCE', --These rules are for your reference. Please do not check any checkboxes.
'PON_AUC_OPTIONAL_PB', --It is optional for you to enter a price for each line in the table. You may propose price breaks in the space provided or on a separate sheet of paper.
'PON_AUC_OPTIONAL_PB_2', -- It is optional for suppliers to enter a price for each line in the table.  Suppliers may propose price breaks.
'PON_AUC_OPTIONAL_PB_3', -- You may propose price breaks in the space provided or on a separate sheet of paper.
'PON_AUC_OPTIONAL_PB_4', -- Suppliers may propose price breaks.
'PON_AUC_REQUIRED_PB', --You must enter a price for each line in the table.
'PON_AUC_REQUIRED_PB_2', -- Suppliers must enter a price for each line in the table.
'PON_AUC_CUMULATIVE_PB', --The break quantity is cumulative.
'PON_AUC_NON_CUMULATVE_PB', --The break quantity is non-cumulative.
'PON_AUC_PB_VIEW_SHIP_TO', --To view Ship-To addresses, refer to section
'PON_AUC_LOCATION_PRICING', --Location Pricing
'PON_AUC_REFER_ATTACH_PE', --Please refer to the attachments for price elements included in this line.
'PON_AUC_REFER_ATTACH_PD', --Please refer to the attachments for price differentials included in this line.
'PON_AUC_RFR_ATTACH_PD_LOC_PRC', --Please refer to the attachments for price differentials included in the location pricing for this line.
'PON_AUC_PART_I_HEADER_INFO_C', --PART I: HEADER INFORMATION
'PON_AUC_HEADER_ATTRIBUTES', --Header Attributes
'PON_AUC_PRN_PRICE_SCHEDULE_C', --2 Price Schedule
'PON_ITEM_DETAILS', --Line Details
'PON_AUC_TABLE_OF_CONTENTS_C', --TABLE OF CONTENTS
'PON_AUC_RESPONSE_RULES', --Response Rules
'PON_AUC_NR_CONTROL_MSG_1', --Negotiation is restricted to invited suppliers
'PON_AUC_PRN_RESTRCT_SUPPLIER', --Restrict to invited suppliers
'PON_AUC_NR_CONTROL_MSG_2', --Suppliers are allowed to view other suppliers notes and attachments
'PON_AUC_NR_CONTROL_MSG_2A', --Suppliers are allowed to view other suppliers' contract terms, notes and attachments
'PON_AUC_NR_CONTROL_MSG_9', --Buyer may create multiple rounds of negotiations
'PON_AUC_NR_CONTROL_MSG_3', --Suppliers are allowed to respond to selected lines
'PON_AUC_NR_CONTROL_MSG_4', --Suppliers are required to respond with full quantity on each line
'PON_AUC_NR_CONTROL_MSG_5', --Allow multiple responses
'PON_AUC_NR_CONTROL_MSG_14', --Suppliers are required to lower the line price when submitting a revised response
'PON_AUC_NR_CONTROL_MSG_7', --Buyer may close the negotiation before the Close Date
'PON_AUC_PRN_ALLOW_MANUAL_CL', -- Allow manual close before the Close Date
'PON_AUC_PRN_ALLOW_MANUAL_EXT', --Buyer may manually extend the negotiation while it is open
'PON_AUC_MANUALEXTEND_FLAG_Z', --Buyer can manually extend the Assessment
'PON_AUCTION_PROMISE_DATE', --Promise Date
'PON_AUCTS_DESCRIPTION', --Description
'PON_AUCTS_NAME', --Name
'PON_AUC_DATA_TYPE', --Data Type
'PON_AUC_UNDEFINED', --Undefined
'PON_AUC_GROUP_WEIGHT', --Group Weight
'PON_AUCTS_ITEM_DESC', -- Description
'PON_ITEM_REV', -- Item, Rev
'PON_ITEM_REV_JOB', --Item, Rev / Job
'PON_AUCTS_CATEGORY', --Category
'PON_SHOPPING_CAT', -- Shopping Category
'PON_AUCTS_UOM', -- Unit
'PON_AUC_CICRLE_RESP_BELOW', --Circle one from the response values below:
'PON_AUC_CIRCLE_RESPONSE_BELOW', -- (Circle one from the response values below):
'PON_AUC_UP_TO', --Up to
'PON_AUC_OPTIONAL_RESP', --It is optional for you to provide a response.
'PON_AUC_MAX_SCORE', --Maximum Score
'PON_AUCTS_RESP_MUST_BE_URL', --The response must be an URL value.
'PON_AUC_PRICE_TYPE_CIRCLE_VAL', --Price Type (Circle one value)
'PON_AUC_EFFECTIVE_FROM_DATE', --Effective From Date
'PON_AUC_EFFECTIVE_TO_DATE', --Effective To Date
'PON_BIDS_PRICE', --Price
'PON_AUC_DISCOUNT_PERCENTAGE', --Discount %
'PON_AUC_ADDRESS', --Address
'PON_AUC_LEAVE_BLANK', --Leave blank
'PON_AUC_ENTER_IN_ATTR_TABLE', --Enter in the Attributes Table below
'PON_AUC_SCORE_FOR_RESPONSE', --(Score for the response)
'PON_AUCTION_QUANTITY', --Quantity
'PON_AUC_PRN_CONTRACT_WARNING', --Note: This document does not include Contract Terms because the buyer does not have permission to view them.
'PON_AUCTS_COMPANY', --Company
'PON_AUC_LOCATION', --Location
'PON_JOB_DETAILS', --Job Details
'PON_AUCTION_LOT', --Lot
'PON_AUCTION_GROUP', --Group
'PON_FO_PROPRIETARY_INFORMATION', --Proprietary and Confidential
'PON_PAGE', -- Page PAGE_NUM of END_PAGE
'PON_AUC_SUBMIT_UR_RESPOSE_TO', -- Please submit your response to:
'PON_AUC_INCLD_FOLLOWING_INFO', -- When submitting your response, please include the following information.
'PON_AUC_BID_VALID_UNTIL', -- Response Valid Until
'PON_AUC_SECURITY_LEVEL', -- Security Level
'PON_AUC_APPROVAL_STATUS', -- Approval Status
'PON_OPERATING_UNIT', -- Operating Unit
'PON_AUC_OUTCOME', -- Outcome
'PON_AUC_NEGOTIATION_STYLE', -- Negotiation Style
'PON_AUC_NEGOTIATION_STYLE_Z', -- Assessment Style
'PON_AUCTS_AUCTION_EVENT', -- Event
'PON_SOURCING_PROJECT', -- Sourcing Project
'PON_AUC_APPROVAL_REQUIRED', -- Requires Approval
'PON_AUC_APPROVAL_NOT_REQUIRED', -- Requires No Approval
'PON_AUC_APPROVAL_APPROVED', -- Approved
'PON_AUC_APPROVAL_REJECTED', -- Rejected
'PON_AUC_APPROVAL_INPROCESS', -- In Process
'PON_AUC_COLLABORATION_TEAM', -- Collaboration Team
'PON_AUC_MEMBER_ROLE', -- Member
'PON_AUC_POSITION', -- Position
'PON_AUC_APPROVER', -- Approver
'PON_AUC_ACCESS', -- Access
'PON_AUC_TASK', -- Task
'PON_AUC_TARGET_DATE', -- Target Date
'PON_CORE_YES', -- Yes
'PON_CORE_NO', -- No
'PON_AUCTS_GLOBAL_AGREEMENT', -- Global Agreement
'PON_AUC_ELIGIBLE_RESP_CURR', -- Eligible Response Currencies
'PON_AUC_CHECK_RESP_CURR', -- Check the one currency in which you will enter your response.
'PON_AUC_EX_RATE_TYPE', -- Exchange Rate Type
'PON_AUC_EX_RATE_DATE', -- Exchange Rate Date
'PON_DISP_TO_SUPPLIERS', -- Display To Suppliers
'PON_DO_NOT_DISP_TO_SUPPLIERS', -- Do Not Display to Suppliers
'PON_AUC_DISPLAY_SCORE_2', -- Display scoring criteria to Suppliers
'PON_ABSTRACT_FORMS', -- Abstract and Forms
'PON_AUC_VERSION', -- Version
'PON_AUC_NR_CONTROL_MSG_6', -- Buyer is required to obtain approval of award decisions
'PON_AUC_NR_CONTROL_MSG_13', -- Negotiation is allowed to AutoExtend
'PON_AUC_NR_CONTROL_MSG_15', -- Negotiation is allowed to AutoExtend based on the following settings
'PON_AUC_NR_CONTROL_MSG_16', -- Show best price to a supplier in a blind negotiation
'PON_AUC_NR_CONTROL_MSG_18', -- Enforce supplier's previous round price as start price for this round
'PON_AUTO_EXTEND_SETTINGS', -- AutoExtend Settings
'PON_START_TIME_EXTEND', -- Start Time of Extensions
'PON_NUMBER_OF_EXTENSIONS', -- Number of Extensions
'PON_AUTO_EXTEND_PERIOD', -- AutoExtend Period
'PON_LINES_TO_AUTO_EXTEND', -- Lines to AutoExtend
'PON_AUCTS_CLOSE_DATE', -- Close Date
'PON_AUTOEXT_TIME_2', -- Receipt time of the triggering winning response
'PON_AUTOEXT_ITEM_2', -- Lines that have received winning responses during the AutoExtend period
'PON_TRIGGERING_RESPONSE', -- Triggering Response
'PON_LOW_TRIGG_RESP_RANK', -- Lowest Triggering Response Rank
'PON_AUTOEXT_RESPONSE_1', -- Response with winning lines
'PON_AUTOEXT_RESPONSE_2', -- Any Response
'PON_AUC_UNLIMITED', -- Unlimited
'PON_AUC_MINUTES', -- Minutes
'PON_AUCTS_ALL_ITEMS', -- All Lines
'PON_AUTOEXT_ITEM_3', -- Lines that have received responses during the AutoExtend period
'PON_AUC_DISPLAY_RANK', -- Display Rank As
'PON_AUC_RANKING', -- Ranking
'PON_AUC_PRICE_ELEMENTS', -- Price Factors
'PON_AUC_SUPPLIER_VIEW', -- Suppliers see their response price transformed
'PON_AUC_ENTER_IN_PF_TABLE', -- Enter in the Cost Factors table below
'PON_AUC_REQUISITION', -- Requisition
'PON_AUC_MULTIPLE', -- Multiple
'PON_AUC_LINE_TYPE', -- Line Type
'PON_AUC_PRICE_ELEMENT', -- Price Factor
'PON_AUC_PRICE_ELEMENT_DESC', -- Description
'PON_AUCTS_TYPE', -- Type
'PON_AUCTS_DISP_TO_BIDDER', -- Display To Suppliers
'PON_AUC_PRICING_BASIS', -- Pricing Basis
'PON_AUCTS_ATTR_D_TARGET', -- Display Target
'PON_AUCTS_BID_VALUE', -- Response Value
'PON_AUCTION_ITEM_PRICE', -- Line Price
'PON_AUC_PRICE_FACTOR_NOTE_1', -- It is required for you to enter a response value for the Supplier Price Factors.
'PON_PRICE_DIFFERENTIAL_DESC', -- Description
'PON_TARGET_MULTIPLIER', -- Target Multiplier
'PON_AUC_RESP_MULTIPLIER', -- Response Multiplier
'PON_PRICE_DIFFERENTIALS', -- Price Differentials
'PON_AUC_PRICE_DIFF_NOTE_1', -- Suppliers must enter a response multiplier for each line in the table.
'PON_AUC_PRICE_DIFF_NOTE_2', -- It is optional for suppliers to enter a response multiplier for each line in the table.
'PON_AUC_PRICE_DIFF_NOTE_3', -- You must enter a response multiplier for each line in the table.
'PON_AUC_PRICE_DIFF_NOTE_4', -- It is optional for you to enter a response multiplier for each line in the table.
'PON_AUCTS_PRICE_BREAKS', -- Price Breaks
'PON_AUCTS_PRICE_BREAK', -- Price Break
'PON_AUCTS_TARGET_PRICE', -- Target Price
'PON_AUC_SHIP_TO_ADDRESSES', -- Ship-To Addresses
'PON_INVITED_SUPPLIERS', -- Invited Suppliers
'PON_ACCTS_SUPPLIER', -- Supplier
'PON_AUCTS_SUPPLIER_SITE', -- Supplier Site
'PON_AUCTS_CONTACT', -- Contact
'PON_AUC_ADDNL_EMAIL', -- Additional Contact Email
'PON_AUC_RESPONSE_CURR', -- Response Currency
'PON_ANY_RESPONSE_CURRENCY', -- Any Response Currencies
'PON_NEG_FULL', -- Full
'PON_NEG_RESTRICTED', -- Restricted
'PON_AUC_BUYER_PF_VALUES', -- Buyer Price Factor Values
'PON_HEADER_INFORMATION', -- Header Information
'PON_PRICE_SCHEDULE', -- Price Schedule
'PON_AUCTS_ATTACHMENTS', -- Attachments
'PON_LINE_BID_OPTIONAL', -- It is optional for you to respond to this line.
'PON_AUC_BIDDER_ADDRESS' --Address
,'PON_DECREMENT_METHOD_MSG' -- Suppliers are required to lower the line price from the best response
,'PON_ADVANCE_AMOUNT_PROMPT'     -- Advance Amount
,'PON_FINANCING'                 -- Financing
,'PON_RETAINAGE'                 -- Retainage
,'PON_DEFAULT_PROJECT_INFO'      -- Default Project Information
,'PON_DEFAULT_OWNER'             -- Default Owner
,'PON_DESCRIPTION'               -- Description
,'PON_EXPENDITURE_ITEM_DATE'     -- Expenditure Item Date
,'PON_EXPENDITURE_ORGANIZATION'  -- Expenditure Organization
,'PON_EXPENDITURE_TYPE'          -- Expenditure Type
,'PON_FLAG_DISPLAY_NO'           -- Yes
,'PON_FLAG_DISPLAY_YES'          -- No
,'PON_GOODS_LINE_PAY_ITEM_MSG'   -- Unit Price for each pay item is based on the Number of Units quoted for this line
,'PON_MAXIMUM_RETAINAGE_AMOUNT'  -- Maximum Retainage Amount
,'PON_PAYMENT_INFORMATION'       -- Pay Item Information
,'PON_PAYMENT_TIP_FINANCE'       -- Total pay item amount may not add up to the line amt
,'PON_PAYMENT_TIP_ACTUAL'        -- Total pay item amount must add up to the line amt
,'PON_PAY_ITEM'                  -- Pay Item
,'PON_NEGOTIABLE'                -- Negotiable
,'PON_FINANCING_ATTRIBUTES'      -- Financing Attributes
,'PON_RETAINAGE_ATTRIBUTES'      -- Retainage Attributes
,'PON_PROGRESS_PAYMENT_RATE'     -- Progress Payment Rate
,'PON_PROJECT'                   -- Project
,'PON_PROJECT_INFORMATION'       -- Project Information
,'PON_RECOUPMENT_RATE'           -- Recoupment Rate
,'PON_RETAINAGE_RATE'            -- Retainage Rate
,'PON_SUPP_ENTERABLE_PYMT_FLAG'  -- Supplier can modify Pay Items
,'PON_SUPP_UPD_PAY_ITEMS_1'      -- Suppliers may propose pay items.
,'PON_SUPP_UPD_PAY_ITEMS_2'      -- You may propose pay items in the space provided or on a separate sheet of paper.
,'PON_SUPP_UPD_PAY_ITEMS_3'      -- Suppliers may propose different pay items.
,'PON_SUPP_UPD_PAY_ITEMS_4'      -- You may propose different pay items in the space provided or on a separate sheet of paper.
,'PON_TASK'                      -- Task
,'PON_UNITS'                     -- Units
,'PON_OWNER'                     -- Owner
,'PON_TEAM_SCORING'              -- Team Scoring
,'PON_TEAM_SCORING_ENABLED'      -- Team Scoring enabled
,'PON_TEAM'                      -- Team
,'PON_MEMBERS'                   -- Members
,'PON_TEAM_INSTRUCTIONS'         -- Team Instructions
,'PON_PRICE_VISIBILITY'          -- Price Visibility
,'PON_SECTION_ASSIGNMENT'        -- Section Assignment
,'PON_AUC_REQUIREMENTS'          -- Requirements
,'PON_SLM_QUES_LIST'             -- Questionnaire List
,'PON_AUC_SECTION_WEIGHT'        -- Section Weight
,'PON_AUC_KO_SCORE'              -- Knockout Score
,'PON_AUC_INTERNAL'              -- Internal
,'PON_AUC_AUTOMATIC'             -- Automatic
,'PON_AUC_NONE'                  -- None
,'PON_AUC_MANUAL'                -- Manual
,'PON_AUCTS_ATTR_DATATYPE'       -- Value Type
,'PON_AUC_SCORING'               -- Scoring
,'PON_AUC_SCORE_DISPLAYED'       -- score displayed in brackets
,'PON_PROVIDE_ANSWER'            -- Provide your answer below
,'PON_STAGGERED_CLOSING_MSG'   -- Staggered Closing
,'PON_AUCTS_STAG_FIRST_CLOSE_DAT' -- First Line Close date
,'PON_STAGGERED_CLOSE_INTERVAL'   -- Staggered Closing Interval
,'PON_BID_RESPONSE_STATUS' --Response Status
,'PON_BID_RESPONSE_SUBMITTED' --Your response has been submitted to:
,'PON_BID_RESPONSE_WILLSUBMITTED' --Your response will be submitted to:
,'PON_BID_YOUR_INFO' --Your information is:
,'PON_AUCTS_YOUR_BID_NUMBER' --Reference Number
,'PON_AUCTS_NOTE_TO_BUYER' --Note to Buyer
,'PON_BID_YOUR_REQ_RESPONSE' -- Your response value:
,'PON_AUC_SURROG_RECVD_TIME' -- Response Received Time
,'PON_BID_BUYER_ATTACHMENTS' -- Buyer Attachments
,'PON_BID_SUP_ATTACHMENTS' -- Supplier Attachments
,'PON_AUCTS_BID_MIN_REL_AMT' -- Bid Minimum Release Amount
,'PON_BIDS_RESPONSE_PRICE' -- Response Price
,'PON_AUC_PRICE_SCORE' -- Price/Total Score
,'PON_AUCTS_PROXY_MIN' --Proxy Minimum
,'PON_AUCTS_PROXY_DEC' --Proxy Response Decrement
,'PON_BID_TOTAL_WARNING' --Cannot be displayed because quantity is not available on all lines
,'PON_AUCTS_PRICE_TYPE' --Price Type
,'PON_BIDS_PRICE_OR_DISCOUNT' --Response Price or Discount%
,'PON_BID_BUYER_PI_ATTACHMENTS' -- Buyer Pay Item Attachments
,'PON_BID_SUP_PI_ATTACHMENTS' -- Supplier Pay Item Attachments
,'PON_BID_YOUR_RESPONSE_BRACKET' -- Your response value (score displayed in brackets):
,'PON_BID_YOUR_SITE' -- Your Company Site
,'PON_BIDS_NO_RESPONSE' -- No Response
,'PON_BUYER_PDF_TXT' -- Message for buyer view pdf
,'PON_SUPPLIER_PDF_TXT' -- Message for supplier view pdf
,'PON_AUCTS_PRICE_TIERS' -- Quantity based price tiers
,'PON_TIERS_MIN_QUANTITY' -- Minimum Quantity
,'PON_TIERS_MAX_QUANTITY' -- Maximum Quantity
,'PON_AUC_TARGET_QUANTITY' --Target Quantity
,'PON_AUCTS_RESP_QUANTITY' --Response Quantity
,'PON_AUCTION_PRICE' -- Price

                            ------------------Begin: Add by Chaoqun for adding EMD info into Printable View on 6-NOV-2008----------
                            , 'PON_PRN_EMD_INFO' -- L.1. EMD Information
                            , 'PON_EMD_TYPE' -- EMD Type
                            , 'PON_EMD_DUE_DATE' -- EMD Due Date
                            , 'PON_EMD_AMOUNT' -- EMD Amount
                            , 'PON_EMD_GUAR_EXPIRY_DES_PRE' -- Bank Guarantee Expiry Date
                            , 'PON_EMD_GUAR_EXPIRY_DES_POST'
                            , 'PON_EMD_ADDITIONAL_INFO' --Additional EMD Information
                            , 'PON_EMD_ENABLE_FLAG' --EMD Enable Flag DEscription
                            ------------------End: Add by Chaoqun for adding EMD info into Printable View on 6-NOV-2008------------
                            , 'PON_EMD_AMT_RESP_CURR' -- bug 8667493 EMD amount in eligible response currencies
                            )
                        and application_id = 396
and language_code = l_printing_language;

      BEGIN
        queryCtx := DBMS_XMLGEN.newContext(generic_msgs_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'GENERIC_MESSAGES');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'GENERIC_MESSAGES_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, generic_msgs_res, DBMS_XMLGEN.NONE);
        IF generic_msgs_res IS NULL THEN
          generic_msgs_res := XMLType('<GENERIC_MESSAGES></GENERIC_MESSAGES>');
        END IF;
        Dbms_Lob.append(xml_clob, generic_msgs_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

      CLOSE generic_msgs_cursor;


OPEN doc_msgs_cursor FOR
select substr(message_name,1,length(message_name)-2) message_name,
message_text
FROM
pon_auction_headers_all pah,
pon_auc_doctypes doctypes,
fnd_new_messages msgs
where pah.auction_header_id = p_auction_header_id
AND doctypes.doctype_id = pah.doctype_id
AND msgs.message_name in (
'PON_CONT_MERGE_WARNING' || l_suffix, -- Note: There are contract terms associated to the RFQ that are not included in this document. The contract terms are an inseparable part of this RFQ.
'PON_RESPONSE_STYLE' || l_suffix   -- SLM UI Enhancement
) and msgs.application_id =396
and msgs.language_code = l_printing_language;


       BEGIN
        queryCtx := DBMS_XMLGEN.newContext(doc_msgs_cursor);
        DBMS_XMLGEN.SetRowSetTag(queryCtx, 'DOCUMENT_SPECIFIC_MESSAGES');
        DBMS_XMLGEN.SetRowTag(queryCtx, 'DOCUMENT_SPECIFIC_MESSAGES_ROW');
        DBMS_XMLGEN.getXMLType(queryCtx, doc_msgs_res, DBMS_XMLGEN.NONE);
        IF doc_msgs_res IS NULL THEN
          doc_msgs_res := XMLType('<DOCUMENT_SPECIFIC_MESSAGES></DOCUMENT_SPECIFIC_MESSAGES>');
        END IF;
        Dbms_Lob.append(xml_clob, doc_msgs_res.getCLOBVal());
        DBMS_XMLGEN.closeContext (queryCtx);
        exception when others then
            DBMS_XMLGEN.closeContext (queryCtx);
            RAISE;
       END;

       CLOSE doc_msgs_cursor;

dbms_lob.createtemporary(res, TRUE);
queryCtx := DBMS_XMLGEN.newContext('select null from dual');
DBMS_XMLGEN.SetRowSetTag(queryCtx, null);
DBMS_XMLGEN.SetRowTag(queryCtx, null);
DBMS_XMLGEN.getXML(queryCtx, res, DBMS_XMLGEN.NONE);
DBMS_XMLGEN.closeContext (queryCtx);

result := res || '<ROWSET>' || '<ROW>' || xml_clob || '</ROW>' || '</ROWSET>';

  SELECT CURRENT_DATE INTO l_end_time FROM DUAL;

    IF l_statement_log_level >= l_current_log_level THEN
      FND_LOG.string(l_statement_log_level, l_module_name, 'PDF: generating XML time: ' || (l_end_time - l_start_time) * 24 * 60 * 60);
    END IF;

    return result;

  END GENERATE_AUCTION_XML;



END PON_PRINTING_PKG;

/
