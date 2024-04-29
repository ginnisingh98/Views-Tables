--------------------------------------------------------
--  DDL for Package Body ARP_APP_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_APP_CALC_PKG" as
/* $Header: ARAPPRUB.pls 120.6.12010000.4 2010/04/21 09:16:35 npanchak ship $ */

-- PL/SQL tables will hold the values of the rules already in memory
TYPE rule_start_tab_typ IS TABLE of number INDEX BY BINARY_INTEGER;
TYPE rule_end_tab_typ IS TABLE of number INDEX BY BINARY_INTEGER;
TYPE rule_set_id_tab_typ IS TABLE of number INDEX BY BINARY_INTEGER;
rule_start_tab rule_start_tab_typ;
rule_end_tab rule_end_tab_typ;
rule_set_id_tab rule_set_id_tab_typ;
j binary_integer:=0;		-- Number of rule-sets cached in a session

subtype varchar2s is dbms_sql.varchar2s;
g_rule_source varchar2s;	-- Rule set cache (table)
g_rule_start number;		-- Starting row-index of a rule-set in cache
g_rule_end number;		-- Ending row-index of a rule-set in the cache

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*===========================================================================+
 | FUNCTION                                                                  |
 |   GET_RULE_SET_ID                                                           |
 | DESCRIPTION                                                               |
 |   Given the cust_trx_type_id from the payment schedule this function will |
 |   return the rule_set_id to be used for this transaction                  |
 |                                                                           |
 | SCOPE                                                                     |
 |     -- Public                                                            |
 |                                                                           |
 | PARAMETERS                                                                |
 |   IN -   cust_trx_type_id - this is the transaction type of the item      |
 |          associated with the payment schedule                             |
 |   OUT NOCOPY    This function will return the rule_set_id to be used while       |
 |          calling the calc_applied_and_remaining procedure                 |
 | MODIFICATION HISTORY                                                      |
 |   06-25-97  Joan Zaman --  Created                                        |
 +===========================================================================*/


 function get_rule_set_id ( p_trx_type_id in number ) return number is

  l_rule_set_id number;

 begin

  arp_util.debug('ARP_APP_CALC_PKG: GET_RULE_SET_ID()+');
   select nvl(rule_set_id,nvl(arp_standard.sysparm.rule_set_id,-1))
   into l_rule_set_id
   from ra_cust_trx_types
   where cust_trx_type_id = p_trx_type_id ;

  if (l_rule_set_id = -1) then
    fnd_message.set_name('AR','AR_NO_RULE_DEFINED');
    app_exception.raise_exception;
  end if;

  arp_util.debug('ARP_APP_CALC_PKG: GET_RULE_SET_ID()- Rule Set Id = '||to_char(l_rule_set_id));

   return(l_rule_set_id);

 EXCEPTION
   WHEN OTHERS THEN
    arp_util.debug('EXCEPTION: ARP_APP_CALC_PKG.GET_RULE_SET_ID() - OTHERS'||SQLERRM);
    RAISE;
 end;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   SET_RULE_SET                                                            |
 | DESCRIPTION                                                               |
 |   This procedure will given a rule_set_id check whether the rule is       |
 |   already loaded in the pl/sql table and or will load the rule in the     |
 |   table when it is not already loaded.                                    |
 |                                                                           |
 |   Note that g_rule_source,g_rule_start and g_rule_end are global variables|
 |   for the package.                                                        |
 |                                                                           |
 | SCOPE                                                                     |
 |     -- Private                                                            |
 |                                                                           |
 | PARAMETERS                                                                |
 |   IN -   rule_set_id                                                      |
 |   OUT NOCOPY    This function will return the start and end of the pl/sql table  |
 |          that holds the respective rule                                   |
 | MODIFICATION HISTORY                                                      |
 |   06-25-97  Joan Zaman --  Created                                        |
 |   11-20-97  Govind Jayanth 	Bug fix 583787 - Grep 583787 for details.    |
 +===========================================================================*/

 procedure set_rule_set ( p_rule_set_id in number ) is

  l_rule_source_lng long;
  l_rule_chunk number;
  l_in_rule_start number;
  l_test_source long;

 begin
  -- First Set global variables back to 0
  g_rule_start := 0;
  g_rule_end :=0;

  for rules_in_cache in 1..j loop
    if p_rule_set_id = rule_set_id_tab(rules_in_cache) then
      g_rule_start := rule_start_tab(rules_in_cache);
      g_rule_end := rule_end_tab(rules_in_cache);
      arp_util.debug('ARP_APP_CALC_PKG.set_rule_set - Rules cached        = '|| to_char(j));
      arp_util.debug('ARP_APP_CALC_PKG.set_rule_set - Current rule-set-id = '|| to_char(p_rule_set_id));
      arp_util.debug('ARP_APP_CALC_PKG.set_rule_set - Cached at index     = '|| to_char(rules_in_cache));
      arp_util.debug('ARP_APP_CALC_PKG.set_rule_set - Rule Start          = '|| to_char(g_rule_start));
      arp_util.debug('ARP_APP_CALC_PKG.set_rule_set - Rule End            = '|| to_char(g_rule_end));
    end if;
  end loop;

  if ((g_rule_start = 0) and ( g_rule_end = 0 )) then

    -- No rule found in cache so we will load the next rule into memory

    select rule_source
    into l_rule_source_lng
    from ar_app_rule_sets
    where rule_set_id = p_rule_set_id ;

    l_in_rule_start := 1;
    -- The rule chunk defines the size of the pieces that we are taken out NOCOPY of
    -- the rule source. It is set to 150 but can be changed. The real size is
    -- defined in the dbms_sys_dbms_sql package but i could not find any
    -- documentation on it. I tried 150 and it seemed to work fine.
    -- Everything smaller than 150 will also work fine.

    l_rule_chunk := 150 ;
--
-- Bug 583787: ON-INSERT error while applying a CM to multiple invoices with different rule-sets.
-- Make sure that each rule that comes into cache starts at the end of the previous.
--
    if (j = 0) then
        g_rule_start := j+1;	-- See note below. Tables starting at index 1
    else
        g_rule_start := rule_end_tab(j)+1;
    end if;
    g_rule_end := nvl(g_rule_start - 1
                    + CEIL( ( length (l_rule_source_lng) / l_rule_chunk ) ),1);

    arp_util.debug('ARP_APP_CALC_PKG: Rule Start      = '  || to_char(g_rule_start));
    arp_util.debug('ARP_APP_CALC_PKG: Rule End        = '  || to_char(g_rule_end)) ;
    arp_util.debug('ARP_APP_CALC_PKG: Rule length     = '  || to_char(length(l_rule_source_lng))) ;
    arp_util.debug('ARP_APP_CALC_PKG: l_in_rule_start = '  || to_char(l_in_rule_start));
    arp_util.debug('ARP_APP_CALC_PKG: l_rule_chunk    = '  || to_char(l_rule_chunk));
    arp_util.debug('ARP_APP_CALC_PKG: rule_set_id     = '  || to_char(p_rule_set_id));

    for i in g_rule_start..g_rule_end loop
      g_rule_source(i) := substr(l_rule_source_lng,l_in_rule_start,l_rule_chunk);
      l_in_rule_start := l_in_rule_start + l_rule_chunk ;
    end loop;


    -- Updating the rules in cache table.
    -- A tricky stuff here: For the 1st rule coming into cache, j happens to be zero
    -- but tables below are starting at index 1. Hence the increment to j each time.
    --
    j := j + 1;
    rule_start_tab(j) := g_rule_start;
    rule_end_tab(j) := g_rule_end;
    rule_set_id_tab(j) := p_rule_set_id;

    for i in g_rule_start..g_rule_end loop
      l_test_source := g_rule_source(i) ;

      -- bug 2389772 : turn off display of source code
      -- arp_util.debug(l_test_source);
    end loop;

   end if;
 EXCEPTION
   WHEN OTHERS THEN
     arp_util.debug('EXCEPTION: ARP_APP_CALC_PKG.SET_RULE_SET()'||SQLERRM);
     RAISE;
 end;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |   EXTRACT_TAXES                                                           |
 | DESCRIPTION                                                               |
 |   Given the Gross Amounts this procedure will calculate the net amount and|
 |   the tax amount given the tax treatment                                  |
 |   The tax Treatment can be : PRORATE , BEFORE , AFTER , NONE              |
 |                                                                           |
 |     PRORATE will use the line and tax remaining amounts to prorate amounts|
 |             the formula used :                                            |
 |               tax_applied = tax_remaining * amt / total_remaining         |
 |     BEFORE will first try to substract the amt from the tax_remaining     |
 |     AFTER  will first try to substract the amt from the line_remaining    |
 |     NONE      will just return the gross amount and make tax_applied = 0  |
 |                                                                           |
 | SCOPE                                                                     |
 |     -- Private                                                            |
 |                                                                           |
 | PARAMETERS                                                                |
 |   IN -   amt   -- This is the gross amount to be split up                 |
 |          tax_treatment  -- One of the above , related to TAX              |
 |          o_tax_treatment -- Tax Treatment for overapplications            |
 |          currency        -- Currency of the amount used for rounding      |
 |          line_remaining  -- The original Line Remaining amount            |
 |          tax_remaining   -- The original Tax Reamaining amount            |
 |   OUT NOCOPY
 |          line_applied    -- The taxable amount calculated using the orig  |
 |                             line_remaining and tax_remaining amounts.     |
 | MODIFICATION HISTORY                                                      |
 |   03-11-97  Joan Zaman --  Created                                        |
 |   12-05-97  Govind J       Prevent zero_divide error by checking if       |
 |                            tax_remaining+line_remaining = 0               |
 +===========================================================================*/

procedure extract_taxes ( amt in number
                         ,tax_treatment in varchar2
                         ,o_tax_treatment in varchar2
                         ,currency in varchar2
                         ,line_remaining in number
                         ,tax_remaining in number
                         ,line_applied out NOCOPY number
                         ,tax_applied  out NOCOPY number ) is

l_tax_applied number:=0;

begin

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_APP_CALC_PKG.extract_taxes()+');
END IF;

if amt < (line_remaining + tax_remaining) then

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('extract_taxes: ' || 'partial');
 END IF;

 if tax_treatment = 'PRORATE' then
    if ((tax_remaining+line_remaining) <> 0) then
   	l_tax_applied := arpcurr.currround((tax_remaining*amt/(tax_remaining+line_remaining)),currency);
    end if;
   line_applied := amt - l_tax_applied;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('extract_taxes: ' || '.. PRORATE : line_applied = ' || to_char(line_applied));
      arp_standard.debug('extract_taxes: ' || '             l_tax_applied = ' || to_char(l_tax_applied));
   END IF;

 elsif tax_treatment = 'BEFORE' then
   if (amt > tax_remaining)  then
     l_tax_applied := tax_remaining ;
     line_applied := amt - tax_remaining ;
   else
     l_tax_applied := amt;
     line_applied := 0;
   end if;
 elsif tax_treatment = 'AFTER' then
   if amt > line_remaining  then
     line_applied := line_remaining ;
     l_tax_applied := amt - line_remaining ;
   else
     line_applied := amt ;
     l_tax_applied := 0;
   end if;
 else /* No Treatment -- > tax not considerated */
    line_applied := amt ;
    l_tax_applied := 0;
 end if;
else
  if o_tax_treatment = 'PRORATE' then
    if ((tax_remaining+line_remaining) <> 0) then
   	l_tax_applied := arpcurr.currround((tax_remaining*amt/(tax_remaining+line_remaining)),currency);
    end if;
    line_applied := amt - l_tax_applied;
 elsif o_tax_treatment = 'BEFORE' then
     line_applied := line_remaining ;
     l_tax_applied := amt - line_remaining ;
 elsif o_tax_treatment = 'AFTER' then
     -- Fix 1378222, Added sign(tax_remaining)
     l_tax_applied := sign(tax_remaining)*tax_remaining ;
     line_applied := amt - sign(tax_remaining)*tax_remaining ;
 else /* No Treatment -- > tax not considerated */
    line_applied := amt ;
    l_tax_applied := 0;
 end if;
end if;

tax_applied := l_tax_applied;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('ARP_APP_CALC_PKG.extract_taxes()-');
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  ARP_APP_CALC_PKG.extract_taxes'||SQLERRM);
    END IF;
    RAISE;

end extract_taxes;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   CALC_APPLIED_AND_REMAINING                                              |
 | DESCRIPTION                                                               |
 |   Given all the remaining amounts this procedure will calculate the new   |
 |   applied amounts and remaining amounts based on the amount you want to   |
 |   apply. The rule used for calculating the applied amounts is the rule    |
 |   currently active in the system options form.                            |
 |                                                                           |
 |                                                                           |
 | SCOPE                                                                     |
 |     -- Public                                                             |
 |                                                                           |
 | PARAMETERS                                                                |
 |   IN -   amt   -- This is the mount to be applied to all parts using      |
 |                   the rule                                                |
 |          currency  -- currency the amount is in , used for rounding when  |
 |                       prorating                                           |
 |       line_remaining -- Remaining line amt at the time of the applic.     |
 |       line_tax_remaining -- Remaining tax amt related to the line         |
 |       freight_remaining -- Remaining line amt at the time of the applic.  |
 |       freight_tax_remaining -- Remaining tax amt related to the freight   |
 |       charges_remaining -- Remaining line amt at the time of the applic.  |
 |       charges_tax_remaining -- Remaining tax amt related to the charges   |
 |   OUT NOCOPY
 |       line_applied - Amount applied for this part                         |
 |       line_tax_applied - Amount applied for this part                     |
 |       freight_applied - Amount applied for this part                      |
 |       freight_tax_applied - Amount applied for this part                  |
 |       charges_applied - Amount applied for this part                      |
 |       charges_tax_applied - Amount applied for this part                  |
 |                                                                           |
 |       Also all the new remaining amounts will be provided back. This is   |
 |       mainly important for the c-functions                                |
 |       Most PL/SQL procedures will calculate their own remaining amounts   |
 | USAGE NOTES                                                               |
 |       1. What happens to negative values :
 |            If remaining amounts are mixed sign -- > error.                |
 |            One remaining amount -ve ---> other remaining zero or -ve      |
 |            AMT -ve , remaining amts +ve ---> new remaining higher.        |
 |                                              Applied amts -ve.            |
 |            AMT +ve , remaining amts -ve ---> new abs remaining higher     |
 |                                              Applied amts +ve             |
 |            AMT -ve , remaining amts -ve ---> new abs remaining lower      |
 |                                              Applied amts -ve             |
 |            AMT +ve , remaining amts +ve ---> new remaining lower          |
 |                                              Applied amts +ve             |
 |       2. Only Line_Tax_ values will be used for now because tax on        |
 |          freight and charges does not yet exists. Pass a zero value for it|
 | MODIFICATION HISTORY                                                      |
 |   03-11-97  Joan Zaman --  Created                                        |
 |   12-05-97  Govind J       Before calling extract_taxes, check the        |
 |                            amount applied that needs to be divide into    |
 |                            line (or freight or charges) and the correspon-|
 |                            ding tax amount, instead of checking the       |
 |                            remaining amounts (e.g., line_remaining +      |
 |                            tax_remaining). This is because, amount can be |
 |                            overapplied, if remaining amounts are zero.    |
 +===========================================================================*/
--131
procedure calc_applied_and_remaining ( amt in number
                               ,rule_set_id number
                               ,currency in varchar2
                               ,line_remaining in out NOCOPY number
                               ,line_tax_remaining in out NOCOPY number
                               ,freight_remaining in out NOCOPY number
                               ,freight_tax_remaining in out NOCOPY number
                               ,charges_remaining in out NOCOPY number
                               ,charges_tax_remaining in out NOCOPY number
                               ,line_applied out NOCOPY number
                               ,line_tax_applied  out NOCOPY number
                               ,freight_applied  out NOCOPY number
                               ,freight_tax_applied  out NOCOPY number
                               ,charges_applied  out NOCOPY number
                               ,charges_tax_applied  out NOCOPY number) is

cursor_name INTEGER;
rows_processed INTEGER;

t_line_remaining number:=0;
t_freight_remaining number:=0;
t_charges_remaining number:=0;
t_line_applied number:=0;
t_freight_applied  number:=0;
t_charges_applied  number:=0;
r_line_applied number:=0;
r_freight_applied  number:=0;
r_charges_applied  number:=0;
l_line_applied number:=0;
l_line_tax_applied number:=0;
l_freight_applied  number:=0;
l_freight_tax_applied number:=0;
l_charges_applied  number:=0;
l_charges_tax_applied  number:=0;

--164
l_line_tax_treatment VARCHAR2(30):='NONE';
l_freight_tax_treatment VARCHAR2(30):='NONE';
l_charges_tax_treatment VARCHAR2(30):='NONE';
o_line_tax_treatment VARCHAR2(30):='NONE';
o_freight_tax_treatment VARCHAR2(30):='NONE';
o_charges_tax_treatment VARCHAR2(30):='NONE';


begin

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_APP_CALC_PKG.calc_applied_and_remaining()+ ');
       arp_standard.debug('calc_applied_and_remaining: ' || ' ..amount applied '||to_char(amt));
       arp_standard.debug('calc_applied_and_remaining: ' || ' ..currency '||currency);
       arp_standard.debug('calc_applied_and_remaining: ' || ' ..line_remaining '||to_char(line_remaining));
       arp_standard.debug('calc_applied_and_remaining: ' || ' ..line_tax_remaining '||to_char(line_tax_remaining));
       arp_standard.debug('calc_applied_and_remaining: ' || ' ..l_line_applied '||to_char(l_line_applied));
       arp_standard.debug('calc_applied_and_remaining: ' || ' ..l_line_tax_applied '||to_char(l_line_tax_applied));
    END IF;

  -- Checking for negative values.
  -- Rule source only expects +ve values , so values will have to be
  -- checked before passing to the cursor.

 IF  (  (sign(line_remaining) * sign(line_tax_remaining) < 0 )
     OR (sign(freight_remaining) * sign(freight_tax_remaining) < 0 )
     OR (sign(charges_remaining) * sign(charges_tax_remaining) < 0 )
     ) THEN

  --error an associated tax line cannot be negative when the main line is positive or viceversa.
  fnd_message.set_name('AR','AR_INVALID_REMAINING');
  app_exception.raise_exception;

 ELSE
  t_line_remaining := line_remaining + line_tax_remaining ;
  t_freight_remaining := freight_remaining + freight_tax_remaining ;
  t_charges_remaining := charges_remaining + charges_tax_remaining ;
 END IF;


 /*
    The following mixed-signs condition should not occur, as the calc_applied_and_remaining
    calling routine, divides a mixed-sign balance application into 2 phases, such that in each
    phase amounts with same sign are passed for application. However the error will notify us
    of a mixed-sign at this point, for debugging.
 */

 IF (   (sign(t_line_remaining) * sign(t_freight_remaining) < 0 )
     OR (sign(t_line_remaining) * sign(t_charges_remaining) < 0 )
     OR (sign(t_freight_remaining) * sign(t_charges_remaining) < 0 )
    ) THEN

   -- error , if one of the remaining amounts is negative then the other have to be
   -- zero or negative.

   fnd_message.set_name('AR','AR_INVALID_REMAINING' );
   app_exception.raise_exception;

 END IF;

  -- This will set the rule start and rule end variables.
  set_rule_set(rule_set_id);

  cursor_name := dbms_sql.open_cursor;

  dbms_sql.parse(cursor_name , g_rule_source , g_rule_start , g_rule_end ,
                  FALSE , dbms_sql.v7);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('calc_applied_and_remaining: ' || '(After Parse): dbms_sql bind variables: ');
     arp_util.debug('calc_applied_and_remaining: ' || ':currency                : '||currency);
     arp_util.debug('calc_applied_and_remaining: ' || ':amt                     : '||to_char(amt));
     arp_util.debug('calc_applied_and_remaining: ' || ':line_remaining          : '||to_char(t_line_remaining));
     arp_util.debug('calc_applied_and_remaining: ' || ':freight_remaining       : '||to_char(t_freight_remaining));
     arp_util.debug('calc_applied_and_remaining: ' || ':charges_remaining       : '||to_char(t_charges_remaining));
     arp_util.debug('calc_applied_and_remaining: ' || ':line_applied            : '||to_char(t_line_applied));
     arp_util.debug('calc_applied_and_remaining: ' || ':freight_applied         : '||to_char(t_freight_applied));
     arp_util.debug('calc_applied_and_remaining: ' || ':charges_applied         : '||to_char(t_charges_applied));
     arp_util.debug('calc_applied_and_remaining: ' || ':line_tax_treatment      : '||l_line_tax_treatment);
     arp_util.debug('calc_applied_and_remaining: ' || ':freight_tax_treatment   : '||l_freight_tax_treatment);
     arp_util.debug('calc_applied_and_remaining: ' || ':charges_tax_treatment   : '||l_charges_tax_treatment);
     arp_util.debug('calc_applied_and_remaining: ' || ':o_line_tax_treatment    : '||o_line_tax_treatment);
     arp_util.debug('calc_applied_and_remaining: ' || ':o_freight_tax_treatment : '||o_freight_tax_treatment);
     arp_util.debug('calc_applied_and_remaining: ' || ':o_charges_tax_treatment : '||o_charges_tax_treatment);
  END IF;

  -- +ve values are passed here. It will not affect the applied amounts
  -- They will be converted back at the end of this procedure.

  dbms_sql.bind_variable(cursor_name ,':currency',currency);
  dbms_sql.bind_variable(cursor_name ,':amt',abs(amt));
  dbms_sql.bind_variable(cursor_name ,':line_remaining',abs(t_line_remaining) );
  dbms_sql.bind_variable(cursor_name ,':freight_remaining',abs(t_freight_remaining));
  dbms_sql.bind_variable(cursor_name ,':charges_remaining',abs(t_charges_remaining));
  dbms_sql.bind_variable(cursor_name , ':line_applied',t_line_applied);
  dbms_sql.bind_variable(cursor_name , ':freight_applied' ,t_freight_applied );
  dbms_sql.bind_variable(cursor_name , ':charges_applied' ,t_charges_applied);
  dbms_sql.bind_variable(cursor_name , ':line_tax_treatment' ,l_line_tax_treatment,30);
  dbms_sql.bind_variable(cursor_name , ':freight_tax_treatment' ,l_freight_tax_treatment,30);
  dbms_sql.bind_variable(cursor_name , ':charges_tax_treatment' ,l_charges_tax_treatment,30);
  dbms_sql.bind_variable(cursor_name , ':o_line_tax_treatment' ,o_line_tax_treatment,30);
  dbms_sql.bind_variable(cursor_name , ':o_freight_tax_treatment' ,o_freight_tax_treatment,30);
  dbms_sql.bind_variable(cursor_name , ':o_charges_tax_treatment' ,o_charges_tax_treatment,30);

  rows_processed := dbms_sql.execute(cursor_name);
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('calc_applied_and_remaining: ' || 'After dbms_sql.execute: rows_processed = : '||to_char(rows_processed));
  END IF;

  dbms_sql.variable_value(cursor_name , ':line_applied',r_line_applied );
  dbms_sql.variable_value(cursor_name , ':freight_applied',r_freight_applied );
  dbms_sql.variable_value(cursor_name , ':charges_applied',r_charges_applied );
  dbms_sql.variable_value(cursor_name , ':line_tax_treatment' ,l_line_tax_treatment);
  dbms_sql.variable_value(cursor_name , ':freight_tax_treatment' ,l_freight_tax_treatment);
  dbms_sql.variable_value(cursor_name , ':charges_tax_treatment' ,l_charges_tax_treatment);
  dbms_sql.variable_value(cursor_name , ':o_line_tax_treatment' ,o_line_tax_treatment);
  dbms_sql.variable_value(cursor_name , ':o_freight_tax_treatment' ,o_freight_tax_treatment);
  dbms_sql.variable_value(cursor_name , ':o_charges_tax_treatment' ,o_charges_tax_treatment);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('calc_applied_and_remaining: ' || '(After Execute): dbms_sql variable values: ');
     arp_util.debug('calc_applied_and_remaining: ' || ':currency                : '||currency);
     arp_util.debug('calc_applied_and_remaining: ' || ':line_applied            : '||to_char(r_line_applied));
     arp_util.debug('calc_applied_and_remaining: ' || ':freight_applied         : '||to_char(r_freight_applied));
     arp_util.debug('calc_applied_and_remaining: ' || ':charges_applied         : '||to_char(r_charges_applied));
     arp_util.debug('calc_applied_and_remaining: ' || ':line_tax_treatment      : '||l_line_tax_treatment);
     arp_util.debug('calc_applied_and_remaining: ' || ':freight_tax_treatment   : '||l_freight_tax_treatment);
     arp_util.debug('calc_applied_and_remaining: ' || ':charges_tax_treatment   : '||l_charges_tax_treatment);
     arp_util.debug('calc_applied_and_remaining: ' || ':o_line_tax_treatment    : '||o_line_tax_treatment);
     arp_util.debug('calc_applied_and_remaining: ' || ':o_freight_tax_treatment : '||o_freight_tax_treatment);
     arp_util.debug('calc_applied_and_remaining: ' || ':o_charges_tax_treatment : '||o_charges_tax_treatment);
  END IF;

  --
  --Sometimes one could overapply on an invoice that has remaining amounts equal to zero.
  --So check the applied amount (instead of remaining), while distributing applied_amount
  --into a line_type (line/freight/charges) and its corresponding tax, based on whatever
  --is the tax-treatment for the line-type. Tax-treatment can be PRORATE,BEFORE,AFTER or NONE.
  --
  --if (line_remaining + line_tax_remaining = 0 ) THEN
  --
  if (r_line_applied = 0 ) THEN
    NULL;
  ELSE
    extract_taxes ( r_line_applied
                 ,l_line_tax_treatment
                 ,o_line_tax_treatment
                 ,currency
                 ,abs(line_remaining)
                 ,abs(line_tax_remaining)
                 ,l_line_applied
                 ,l_line_tax_applied );
  END IF;

  if (r_freight_applied = 0 ) THEN
    NULL;
  ELSE
    extract_taxes ( r_freight_applied
                 ,l_freight_tax_treatment
                 ,o_freight_tax_treatment
                 ,currency
                 ,freight_remaining
                 ,freight_tax_remaining
                 ,l_freight_applied
                 ,l_freight_tax_applied );

  END IF;

  if (r_charges_applied = 0 ) THEN
    NULL;
  ELSE
    extract_taxes ( r_charges_applied
                 ,l_charges_tax_treatment
                 ,o_charges_tax_treatment
                 ,currency
                 ,charges_remaining
                 ,charges_tax_remaining
                 ,l_charges_applied
                 ,l_charges_tax_applied );

  END IF;

  dbms_sql.close_cursor(cursor_name);

  IF  (   (sign(amt) * sign ( t_line_remaining ) < 0 )
      OR  (sign(amt) * sign ( t_freight_remaining ) < 0 )
      OR  (sign(amt) * sign ( t_charges_remaining ) < 0 )
      ) THEN
   -- amount to be applied and remaining amounts have different signs
   -- This means the absolute value of the remaining amount will be higher

   line_remaining := sign(line_remaining) * (abs(line_remaining) + abs(l_line_applied)) ;
   freight_remaining := sign(freight_remaining) * (abs(freight_remaining) + abs(l_freight_applied)) ;
   charges_remaining := sign(charges_remaining) * (abs(charges_remaining) + abs(l_charges_applied)) ;
   line_tax_remaining := sign(line_tax_remaining) * (abs(line_tax_remaining) + abs(l_line_tax_applied)) ;
   freight_tax_remaining := sign(freight_tax_remaining) * (abs(freight_tax_remaining) + abs(l_freight_tax_applied)) ;
   charges_tax_remaining := sign(charges_tax_remaining) * (abs(charges_tax_remaining) + abs(l_charges_tax_applied)) ;

 ELSE
   -- amount to be applied has the same sign as the remaining amounts
   -- This means the absolute value of the remaining amount will be lower

   line_remaining := sign(line_remaining) * (abs(line_remaining) - abs(l_line_applied)) ;
   freight_remaining := sign(freight_remaining) * (abs(freight_remaining) - abs(l_freight_applied)) ;
   charges_remaining := sign(charges_remaining) * (abs(charges_remaining) - abs(l_charges_applied)) ;
   line_tax_remaining := sign(line_tax_remaining) * (abs(line_tax_remaining) - abs(l_line_tax_applied)) ;
   freight_tax_remaining := sign(freight_tax_remaining) * (abs(freight_tax_remaining) - abs(l_freight_tax_applied)) ;
   charges_tax_remaining := sign(charges_tax_remaining) * (abs(charges_tax_remaining) - abs(l_charges_tax_applied)) ;



 END IF;

-- Applied amount will have the same sign as the amount that was applied
--
line_applied := sign(amt) * abs(l_line_applied);
line_tax_applied := sign(amt) * abs(l_line_tax_applied);
freight_applied := sign(amt) * abs(l_freight_applied);
freight_tax_applied := sign(amt) * abs(l_freight_tax_applied);
charges_applied := sign(amt) * abs(l_charges_applied) ;
charges_tax_applied := sign(amt) * abs(l_charges_tax_applied);


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('done with ARP_APP_CALC_PKG.calc_applied_and_remaining()-');
       arp_standard.debug('calc_applied_and_remaining: ' || ' ..amount applied '||to_char(amt));
       arp_standard.debug('calc_applied_and_remaining: ' || ' ..currency '||currency);
       arp_standard.debug('calc_applied_and_remaining: ' || ' ..line_remaining '||to_char(line_remaining));
       arp_standard.debug('calc_applied_and_remaining: ' || ' ..line_tax_remaining '||to_char(line_tax_remaining));
       arp_standard.debug('calc_applied_and_remaining: ' || ' ..line_applied '||to_char(line_applied));
       arp_standard.debug('calc_applied_and_remaining: ' || ' ..line_tax_applied '||to_char(line_tax_applied));
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  ARP_APP_CALC_PKG.calc_applied_and_remaining()'||SQLERRM);
    END IF;
    RAISE;


end calc_applied_and_remaining ;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   CALC_APPLIED_AND_REMAINING                                              |
 | DESCRIPTION                                                               |
 |   This is a cover routine that calls the other calc_applied_and_remaining |
 |  to compute the applied amounts to the various invoice balance components.|
 |  The routine also handles the case where invoice balance is of a mixed    |
 |  sign (e.g., line +ve, tax -ve , freight +ve ). See USAGE NOTES           |
 |									     |
 | SCOPE                                                                     |
 |     -- Public                                                             |
 |                                                                           |
 | PARAMETERS                                                                |
 |   IN -   amt   -- This is the mount to be applied to all parts using      |
 |                   the rule                                                |
 |          currency  -- currency the amount is in , used for rounding when  |
 |                       prorating                                           |
 |       line_remaining -- Remaining line amt at the time of the applic.     |
 |       line_tax_remaining -- Remaining tax amt related to the line         |
 |       freight_remaining -- Remaining line amt at the time of the applic.  |
 |       freight_tax_remaining -- Remaining tax amt related to the freight   |
 |       charges_remaining -- Remaining line amt at the time of the applic.  |
 |       charges_tax_remaining -- Remaining tax amt related to the charges   |
 |   OUT NOCOPY
 |       line_applied - Amount applied for this part                         |
 |       line_tax_applied - Amount applied for this part                     |
 |       freight_applied - Amount applied for this part                      |
 |       freight_tax_applied - Amount applied for this part                  |
 |       charges_applied - Amount applied for this part                      |
 |       charges_tax_applied - Amount applied for this part                  |
 |                                                                           |
 |       Also all the new remaining amounts will be provided back. This is   |
 |       mainly important for the c-functions                                |
 |       Most PL/SQL procedures will calculate their own remaining amounts   |
 |                                                                           |
 | USAGE NOTES                                                               |
 |       1. What happens to mixed-sign balance :			     |
 |            If remaining amounts are of mixed sign -- >                    |
 |		  Apply in 2 phases,passing same-sign values in each phase   |
 |                                                                           |
 |                Phase 1:  MIXED-SIGN TREATMENT                             |
 |                          Pass in amounts that have same sign as applied   |
 |                          amount,to be reduced to zero. Thus in this phase,|
 |                          only the gross of such components will be passed |
 |                          to calc_applied_and_remaining if applied amount  |
 |                          happens to be greater than this gross.           |
 |									     |
 |                Phase 2:  If applied amount happens to be greater than the |
 |                          gross in phase 1 above, pass the balance to      |
 |                          calc_applied_and_remaining again for over-       |
 |                          application. Since some components have          |
 |                          been reduced to zero in phase 1, pass the other  |
 |                          components (+ the zeroed components) this time.  |
 |				               				     |
 |       2.  If there is no mixed_sign balance  --- >                        |
 |                Only Phase 2 is necessary.  				     |
 |				               				     |
 |       3. Only Line_Tax_ values will be used for now because tax on        |
 |          freight and charges does not yet exists. Pass a zero value for it|
 |				               				     |
 | MODIFICATION HISTORY                                                      |
 |   03-11-97  Joan Zaman --  Created                                        |
 |   12-05-97  Govind Jayanth --  Modified to provide mixed-sign treatment.  |
 |   12-09-98  Govind Jayanth --  Bug fix : 772847                           |
 |   01/10/06   V Crisostomo     Bug 4758340 : modify logic to process       |
 |                               mixed sign applications differently when    |
 |                               called from BR                              |
 +===========================================================================*/
procedure calc_applied_and_remaining ( p_amt in number
                               ,p_rule_set_id number
                               ,p_currency in varchar2
                               ,p_line_remaining in out NOCOPY number
                               ,p_line_tax_remaining in out NOCOPY number
                               ,p_freight_remaining in out NOCOPY number
                               ,p_charges_remaining in out NOCOPY number
                               ,p_line_applied out NOCOPY number
                               ,p_line_tax_applied out NOCOPY number
                               ,p_freight_applied  out NOCOPY number
                               ,p_charges_applied  out NOCOPY number
                               ,p_created_from in varchar2 default NULL
                               ) is

/*
 *  LINE, LINE_TAX, FREIGHT, FREIGHT_TAX, CHARGES, CHARGES_TAX are
 *  the 6 components of the invoice balance,that the p_amt is applied to.
 */
l_no_of_balance_components 	CONSTANT number:= 6;

l_mixed_sign_count   	number:= 0;
l_ms_gross_remaining 	ar_payment_schedules.tax_remaining%TYPE:=0;
l_amt_remaining         ar_payment_schedules.tax_remaining%TYPE:=0;
l_ms_applied_amt 	ar_receivable_applications.tax_applied%TYPE:=0;

l_ms_use_line           number:= 0;
l_ms_use_line_tax       number:= 0;
l_ms_use_freight        number:= 0;
l_ms_use_freight_tax    number:= 0;
l_ms_use_charges        number:= 0;
l_ms_use_charges_tax    number:= 0;

/* Amounts applied during mixed sign treatment */
l_ms_applied_line		ar_receivable_applications.tax_applied%TYPE:=0;
l_ms_applied_line_tax		ar_receivable_applications.tax_applied%TYPE:=0;
l_ms_applied_freight		ar_receivable_applications.tax_applied%TYPE:=0;
l_ms_applied_freight_tax	ar_receivable_applications.tax_applied%TYPE:=0;
l_ms_applied_charges		ar_receivable_applications.tax_applied%TYPE:=0;
l_ms_applied_charges_tax	ar_receivable_applications.tax_applied%TYPE:=0;

/* Amounts applied during non-mixed sign treatment */
l_nonms_applied_line		ar_receivable_applications.tax_applied%TYPE:=0;
l_nonms_applied_line_tax	ar_receivable_applications.tax_applied%TYPE:=0;
l_nonms_applied_freight		ar_receivable_applications.tax_applied%TYPE:=0;
l_nonms_applied_freight_tax	ar_receivable_applications.tax_applied%TYPE:=0;
l_nonms_applied_charges		ar_receivable_applications.tax_applied%TYPE:=0;
l_nonms_applied_charges_tax	ar_receivable_applications.tax_applied%TYPE:=0;

/* To hold original values */
l_org_line_remaining 		ar_payment_schedules.tax_remaining%TYPE:=0;
l_org_line_tax_remaining 	ar_payment_schedules.tax_remaining%TYPE:=0;
l_org_fr_remaining 		ar_payment_schedules.tax_remaining%TYPE:=0;
l_org_fr_tax_remaining 		ar_payment_schedules.tax_remaining%TYPE:=0;
l_org_ch_remaining		ar_payment_schedules.tax_remaining%TYPE:=0;
l_org_ch_tax_remaining		ar_payment_schedules.tax_remaining%TYPE:=0;

/*
 *  Currently FREIGHT_TAX and CHARGES_TAX are not treated, so they
 *  appear as local variables.
 */
l_freight_tax_remaining 	number:=0;
l_charges_tax_remaining 	number:=0;
l_freight_tax_applied 		number:=0;
l_charges_tax_applied 		number:=0;

BEGIN
        arp_standard.debug('ARP_APP_CALC_PKG.calc_applied_and_remaining() Wrapper +');

	/*
	 * gjayanth: Bug 772847: When CM is applied to CB, payment
	 * schedule's line_remaining was not getting updated correctly.
	 * Assigning zero to null amount parameters.
	 */
	p_line_remaining 	:= nvl(p_line_remaining, 0);
	p_line_tax_remaining 	:= nvl(p_line_tax_remaining, 0);
	p_freight_remaining 	:= nvl(p_freight_remaining, 0);
	p_charges_remaining 	:= nvl(p_charges_remaining, 0);

        arp_standard.debug('in calc_applied_and_remaining Wrapper, debug');
        arp_standard.debug(' .. p_created_from       = ' || p_created_from);
        arp_standard.debug(' .. p_line_remaining     = ' || to_char(p_line_remaining));
        arp_standard.debug(' .. p_line_tax_remaining = ' || to_char(p_line_tax_remaining));
        arp_standard.debug(' .. p_freight_remaining  = ' || to_char(p_freight_remaining));
        arp_standard.debug(' .. p_charges_remaining  = ' || to_char(p_charges_remaining));
        arp_standard.debug(' .. p_amt                = ' || to_char(p_amt));

	/* Save original values */
	l_org_line_remaining 	  := p_line_remaining;
	l_org_line_tax_remaining  := p_line_tax_remaining;
	l_org_fr_remaining 	  := p_freight_remaining;
	l_org_fr_tax_remaining 	  := l_freight_tax_remaining;
	l_org_ch_remaining	  := p_charges_remaining;
	l_org_ch_tax_remaining	  := l_charges_tax_remaining;

	l_amt_remaining := p_amt;
   	/*
    	 *   First find out NOCOPY which components have signs different
    	 *   from that of 'amt'. Amounts with same signs are treated
	 *   first, unless all happen to have same sign or all are
	 *   different, in which case, we do not have a case of 'mixed-sign'
	 *   balance.

         * Bug 2389772 : changed relational operator below from < to <=
         * so that when p_amt = 0, it is *not* treated as a mixed sign
         * application
         *
    	 */

        IF nvl(p_created_from,'XXX') = 'ARBRMAIB' then

           -- Bug 4758340, if called from BR
           -- re-init all to 0, and set to 1 when they are opposite signs
           -- apply to OPPOSITE sign first

           l_ms_use_line           := 0;
           l_ms_use_line_tax       := 0;
           l_ms_use_freight        := 0;
           l_ms_use_freight_tax    := 0;
           l_ms_use_charges        := 0;
           l_ms_use_charges_tax    := 0;

          IF  sign(p_amt) * sign(p_line_remaining) <= 0   THEN
                l_ms_use_line := 1;
          END IF;

          if sign(p_amt) * sign(p_line_tax_remaining) <= 0  THEN
                l_ms_use_line_tax := 1;
          END IF;

          IF  sign(p_amt) * sign (p_freight_remaining) <= 0  THEN
                l_ms_use_freight := 1;
          END IF;


          IF  sign(p_amt) * sign(l_freight_tax_remaining) <= 0  THEN
                l_ms_use_freight_tax := 1;
          END IF;

          IF  sign(p_amt) * sign(p_charges_remaining) <= 0  THEN
                l_ms_use_charges := 1;
          END IF;

          IF sign(p_amt) * sign(l_charges_tax_remaining) <= 0  THEN
                l_ms_use_charges_tax := 1;
          END IF;

        ELSE

          -- '1' indicates, amount is NOT a candidate for mixed-sign treatment
          -- re-init all to 1, and set to 0 when they are opposite signs
          -- apply to SAME sign first

          l_ms_use_line           := 1;
          l_ms_use_line_tax       := 1;
          l_ms_use_freight        := 1;
          l_ms_use_freight_tax    := 1;
          l_ms_use_charges        := 1;
          l_ms_use_charges_tax    := 1;

          -- Forward Port of Bug 4487954 - See Bug 4592507
          -- reverted the check below from <= to < since
          -- amounts were not getting prorated between line and tax when
          -- prorate all application rule set is used


          IF  sign(p_amt) * sign(p_line_remaining) < 0   THEN
                l_ms_use_line := 0;
          END IF;

          if sign(p_amt) * sign(p_line_tax_remaining) < 0  THEN
                l_ms_use_line_tax := 0;
          END IF;

          IF  sign(p_amt) * sign (p_freight_remaining) < 0  THEN
                l_ms_use_freight := 0;
          END IF;

          IF  sign(p_amt) * sign(l_freight_tax_remaining) < 0  THEN
                l_ms_use_freight_tax := 0;
          END IF;

          IF  sign(p_amt) * sign(p_charges_remaining) < 0  THEN
                l_ms_use_charges := 0;
          END IF;

          IF sign(p_amt) * sign(l_charges_tax_remaining) < 0  THEN
                l_ms_use_charges_tax := 0;
          END IF;


        END IF;

        l_mixed_sign_count :=   l_ms_use_line    + l_ms_use_line_tax +
                                l_ms_use_freight + l_ms_use_freight_tax +
                                l_ms_use_charges + l_ms_use_charges_tax;

        arp_standard.debug(' l_mixed_sign_count = ' || to_char(l_mixed_sign_count));
        arp_standard.debug(' l_ms_use_line = ' || to_char(l_ms_use_line) ||
                           ' l_ms_use_line_tax = ' || to_char(l_ms_use_line_tax));
        arp_standard.debug(' l_ms_use_freight = ' || to_char(l_ms_use_freight) ||
                           ' l_ms_use_freight_tax = ' || to_char(l_ms_use_freight_tax));
        arp_standard.debug(' l_ms_use_charges = ' || to_char(l_ms_use_charges) ||
                           ' l_ms_use_charges_tax = ' || to_char(l_ms_use_charges_tax));

	/*
	 *  If all amounts had sign same as p_amt, l_mixed_sign_count = 6.
	 *  If all amounts had sign opposite to that of p_amt, l_mixed_sign_count = 0.
	 *  If l_mixed_sign_count is between 0 and 6, amounts have a mixed-sign,
	 *  and are treated differently.
	 */
   	IF (l_mixed_sign_count > 0) and (l_mixed_sign_count < l_no_of_balance_components) THEN
		/*
		 *  MIXED-SIGN TREATMENT
		 *
                 *  Temporarily zero out NOCOPY components with sign opposite to that of 'amt',
		 *  so that 'amt' may be applied to the same-sign amounts first.
                 */
		arp_util.debug('Treating invoice components that have mixed signs.');
		arp_util.debug('p_amt = ' || to_char(p_amt));

		p_line_remaining 	:= l_ms_use_line * p_line_remaining;
		p_line_tax_remaining 	:= l_ms_use_line_tax * p_line_tax_remaining;
		p_freight_remaining 	:= l_ms_use_freight * p_freight_remaining;
		l_freight_tax_remaining	:= l_ms_use_freight_tax * l_freight_tax_remaining;
		p_charges_remaining 	:= l_ms_use_charges * p_charges_remaining;
		l_charges_tax_remaining	:= l_ms_use_charges_tax * l_charges_tax_remaining;

		/* Find the gross of same-sign amounts */
		l_ms_gross_remaining := p_line_remaining    + p_line_tax_remaining +
		                        p_freight_remaining + l_freight_tax_remaining +
					p_charges_remaining + l_charges_tax_remaining;

		IF (abs(p_amt) <= abs(l_ms_gross_remaining)) THEN
			l_ms_applied_amt := p_amt;
		ELSE
			l_ms_applied_amt := l_ms_gross_remaining;
		END IF;

                arp_util.debug('1. call calc_applied_and_remaining with params : ');
                arp_util.debug('   l_ms_applied_amt = ' || to_char(l_ms_applied_amt));
                arp_util.debug('   p_rule_set_id = ' || to_char(p_rule_set_id));
                arp_util.debug('   p_line_remaining = ' || to_char(p_line_remaining));
                arp_util.debug('   p_line_tax_remaining = ' || to_char(p_line_tax_remaining));
                arp_util.debug('   p_freight_remaining = ' || to_char(p_freight_remaining));
                arp_util.debug('   l_freight_tax_remaining = ' || to_char(l_freight_tax_remaining));
                arp_util.debug('   p_charges_remaining = ' || to_char(p_charges_remaining));
                arp_util.debug('   l_charges_tax_remaining = ' || to_char(l_charges_tax_remaining));

   		calc_applied_and_remaining ( l_ms_applied_amt
                               		,p_rule_set_id
                               		,p_currency
                               		,p_line_remaining
                               		,p_line_tax_remaining
                               		,p_freight_remaining
                               		,l_freight_tax_remaining
                               		,p_charges_remaining
                               		,l_charges_tax_remaining
                               		,l_ms_applied_line
                               		,l_ms_applied_line_tax
                               		,l_ms_applied_freight
                               		,l_ms_applied_freight_tax
                               		,l_ms_applied_charges
                               		,l_ms_applied_charges_tax  ) ;

		/* Amount remaining for overapplication  */
		l_amt_remaining := sign(p_amt) * ( abs(p_amt) - abs(l_ms_applied_amt) );

		/*
		 *   Restore opp-sign values so they can be treated now.
		 */
		IF (l_ms_use_line = 0) THEN
			p_line_remaining := l_org_line_remaining;
		END IF;

		IF (l_ms_use_line_tax = 0) THEN
			p_line_tax_remaining := l_org_line_tax_remaining;
		END IF;

		IF (l_ms_use_freight = 0) THEN
			p_freight_remaining := l_org_fr_remaining;
		END IF;

		IF (l_ms_use_freight_tax = 0) THEN
			l_freight_tax_remaining := l_org_fr_tax_remaining;
		END IF;

		IF (l_ms_use_charges = 0) THEN
			p_charges_remaining := l_org_ch_remaining;
		END IF;

		IF (l_ms_use_charges_tax = 0) THEN
			l_charges_tax_remaining := l_org_ch_tax_remaining;
		END IF;

   	END IF;	/* MIXED-SIGN TREATMENT */


   	/*
	 *  After mixed sign balances (if any) are treated, balances are now of the
	 *  same sign. This is because those components that had same sign as amt,
	 *  have been reduced to zero by the previous calc_applied_and_remaining().
	 *  If any amt is left, apply.
	 */

	IF ( abs(l_amt_remaining) > 0 ) THEN

		/*
		 *   Still some amt left. Apply as usual.
		 */

		arp_util.debug('Treating invoice components that have the same sign.');

                arp_util.debug('2. call calc_applied_and_remaining with params : ');
                arp_util.debug('   l_amt_remaining = ' || to_char(l_amt_remaining));
                arp_util.debug('   p_rule_set_id = ' || to_char(p_rule_set_id));
                arp_util.debug('   p_line_remaining = ' || to_char(p_line_remaining));
                arp_util.debug('   p_line_tax_remaining = ' || to_char(p_line_tax_remaining));
                arp_util.debug('   p_freight_remaining = ' || to_char(p_freight_remaining));
                arp_util.debug('   l_freight_tax_remaining = ' || to_char(l_freight_tax_remaining));
                arp_util.debug('   p_charges_remaining = ' || to_char(p_charges_remaining));
                arp_util.debug('   l_charges_tax_remaining = ' || to_char(l_charges_tax_remaining));

   		calc_applied_and_remaining ( l_amt_remaining
                               		,p_rule_set_id
                               		,p_currency
                               		,p_line_remaining
                               		,p_line_tax_remaining
                               		,p_freight_remaining
                               		,l_freight_tax_remaining
                               		,p_charges_remaining
                               		,l_charges_tax_remaining
                               		,l_nonms_applied_line
                               		,l_nonms_applied_line_tax
                               		,l_nonms_applied_freight
                               		,l_nonms_applied_freight_tax
                               		,l_nonms_applied_charges
                               		,l_nonms_applied_charges_tax  ) ;

   	END IF;

	p_line_applied 		 := l_ms_applied_line 	     + l_nonms_applied_line ;
	p_line_tax_applied 	 := l_ms_applied_line_tax    + l_nonms_applied_line_tax ;
	p_freight_applied 	 := l_ms_applied_freight     + l_nonms_applied_freight ;
	l_freight_tax_applied 	 := l_ms_applied_freight_tax + l_nonms_applied_freight_tax ;
	p_charges_applied 	 := l_ms_applied_charges     + l_nonms_applied_charges ;
	l_charges_tax_applied 	 := l_ms_applied_charges_tax + l_nonms_applied_charges_tax ;

        arp_standard.debug('done calc_applied_and_remaining Wrapper, debug');
        arp_standard.debug(' .. p_line_applied        = ' || to_char(l_ms_applied_line        + l_nonms_applied_line));
        arp_standard.debug(' .. p_line_tax_applied    = ' || to_char(l_ms_applied_line_tax    + l_nonms_applied_line_tax));
        arp_standard.debug(' .. p_freight_applied     = ' || to_char(l_ms_applied_freight     + l_nonms_applied_freight));
        arp_standard.debug(' .. l_freight_tax_applied = ' || to_char(l_ms_applied_freight_tax + l_nonms_applied_freight_tax));
        arp_standard.debug(' .. p_charges_applied     = ' || to_char(l_ms_applied_charges     + l_nonms_applied_charges));
        arp_standard.debug(' .. l_charges_tax_applied = ' || to_char(l_ms_applied_charges_tax + l_nonms_applied_charges_tax));

	arp_standard.debug('calc_applied_and_remaining() Wrapper -');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION:  ARP_APP_CALC_PKG.calc_applied_and_remaining: Wrapper: '||SQLERRM);
    RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |  COMPILE_RULE ()                                                          |
 | DESCRIPTION                                                               |
 |  This procedure will create a long column that will be                    |
 |  inserted into                                                            |
 |  the ar_app_rule_sets table with the according rule                       |
 |  This compilation makes it possible for the calc_applied_and_remaining    |
 |  procedure not to select multiple times from app_rule... tables           |
 |                                                                           |
 |  This procedure should be called from the application rules set up form   |
 |  from the post_update trigger when the freeze flag gets  set to 'Y'       |
 |                                                                           |
 |  Whenever a rule will be frozen a compiled rule will be created and stored|
 |  in the long           column rule_source.                                |
 |                                                                           |
 |  Before creating the long  column the procedure will check whether        |
 |  the rule is valid. Following checks will be made :                       |
 |    1. Is there one and only one Over Application Rule                     |
 |    2. Are there one or more non-overapplication Rules                     |
 |    3. Is every Line type present in one of the non-overapplication rules  |
 |    4. Has one and only one of the application rule details in every       |
 |       application rule  the rounding correction checked                   |
 |    5. Are the sequence numbers of the application rules  different        |
 |                                                                           |
 |                                                                           |
 |  SCOPE -- Public -- To be called from the application rules set up form   |
 |  PARAMETERS                                                               |
 |     IN -- rule_id -- This is the id from the rule you want to compile.    |
 | RULE_SOURCE (Example Code )
 | -----------
 | DECLARE  Rule Name : Pro Ratio
 | Date Generated : 20-MAR-1997,15:15
 | 1. Pro Ratio Rule
 |      LINE, PRORATE , Rounding Correction : Y
 |      FREIGHT, NONE , Rounding Correction : N
 |      CHARGES, NONE , Rounding Correction : N
 |  Over Application Rule : Pro Ratio Over App
 |      LINE, PRORATE , Rounding Correction : Y
 |      FREIGHT, NONE , Rounding Correction : N
 |      CHARGES, NONE , Rounding Correction : N
 |
 |  l_amt ar_payment_schedules.amount_due_remaining%TYPE;
 |  l_line_remaining ar_payment_schedules.amount_due_remaining%TYPE;
 |  l_freight_remaining ar_payment_schedules.amount_due_remaining%TYPE;
 |  l_charges_remaining ar_payment_schedules.amount_due_remaining%TYPE;
 |  l_gross_remaining ar_payment_schedules.amount_due_remaining%TYPE;
 |  l_line_applied ar_payment_schedules.amount_due_remaining%TYPE:=0;
 |  l_freight_applied ar_payment_schedules.amount_due_remaining%TYPE:=0;
 |  l_charges_applied ar_payment_schedules.amount_due_remaining%TYPE:=0;
 |  l_counter number := 0;
 | BEGIN l_amt := :amt ;
 |       l_line_remaining := :line_remaining ;
 |       l_freight_remaining := :freight_remaining ;
 |       l_charges_remaining := :charges_remaining ;
 |
 |    l_gross_remaining := l_line_remaining + l_freight_remaining  + l_charges_rema
 | ining  ;
 |     if (l_amt > 0) and (l_amt < l_gross_remaining) then
 |
 |           l_freight_applied :=  arpcurr.currround((l_amt * l_freight_remaining /
 |  l_gross_remaining),:currency) ;
 |
 |           l_charges_applied := arpcurr.currround((l_amt * l_charges_remaining /
 | l_gross_remaining),:currency) ;
 |
 |           l_line_applied := l_amt  - l_freight_applied  - l_charges_applied ;
 |
 |        l_amt := 0  ;
 |
 |     elsif (l_amt > l_gross_remaining) then
 |           l_line_applied := l_line_remaining ;
 |
 |           l_freight_applied := l_freight_remaining ;
 |           l_charges_applied := l_charges_remaining ;
 |
 |
 |       l_amt := l_amt - l_gross_remaining ;
 |
 |     end if;
 |
 |    l_gross_remaining :=
 |           l_line_remaining + l_freight_remaining  + l_charges_remaining ;
 |     if (l_amt > 0) then
 |
 |      while l_amt > l_gross_remaining loop
 |
 |          l_line_applied := l_line_applied + l_line_remaining ;
 |          l_amt := l_amt - l_line_remaining ;
 |
 |          l_freight_applied := l_freight_applied + l_freight_remaining ;
 |          l_amt := l_amt - l_freight_remaining ;
 |
 |          l_charges_applied := l_charges_applied + l_charges_remaining ;
 |          l_amt := l_amt - l_charges_remaining ;
 |
 |    end loop;
 |
 |           l_freight_applied :=  l_freight_applied + arpcurr.currround((l_amt * l
 | _freight_remaining / l_gross_remaining),:currency) ;
 |
 |           l_charges_applied := l_charges_applied + arpcurr.currround((l_amt * l_
 | charges_remaining / l_gross_remaining),:currency) ;
 |
 |           l_line_applied := l_line_applied + l_amt  - arpcurr.currround((l_amt *
 |  l_freight_remaining / l_gross_remaining),:currency)  - arpcurr.currround((l_amt
 |  * l_charges_remaining / l_gross_remaining),:currency) ;
 |
 |        l_amt := 0  ;
 |
 |     end if;
 |
 |    :line_applied := l_line_applied ;
 |    :freight_applied := l_freight_applied ;
 |    :charges_applied := l_charges_applied ;
 |    :line_tax_treatment := 'PRORATE' ;
 |    :freight_tax_treatment := 'NONE' ;
 |    :charges_tax_treatment := 'NONE' ;
 |
 |    :o_line_tax_treatment := 'PRORATE' ;
 |    |  :o_freight_tax_treatment := 'NONE' ;
 |    :o_charges_tax_treatment := 'NONE' ;
 | END ;
 |                                                                           |
 |  MODIFICATION HISTORY                                                     |
 |   03-11-97 -- Joan Zaman -- Created                                       |
 |   07-SEP-99 J Rautiainen Bugfix for bug 973520                            |
 +===========================================================================*/

procedure COMPILE_RULE ( p_rule_set_id in ar_app_rule_sets.rule_set_id%TYPE) is


prorate_line_gross varchar2(100) :='arpcurr.currround((l_amt * l_line_remaining / l_gross_remaining),:currency) ';
prorate_freight_gross varchar2(100) :='arpcurr.currround((l_amt * l_freight_remaining / l_gross_remaining),:currency) ';
prorate_charges_gross varchar2(100) :='arpcurr.currround((l_amt * l_charges_remaining / l_gross_remaining),:currency) ';

cursor rules is
select rule_set_name
from ar_app_rule_sets
where rule_set_id = p_rule_set_id;

cursor all_application_blocks is
select rule_name, rule_id,rule_sequence
from ar_app_rules
where rule_set_id = p_rule_set_id
order by rule_sequence;

cursor application_block is
select rule_name, rule_id,rule_sequence
from ar_app_rules
where rule_set_id = p_rule_set_id
and overapp_flag = 'N'
order by rule_sequence;

cursor over_application_block is
select rule_name, rule_id,rule_sequence
from ar_app_rules
where rule_set_id = p_rule_set_id
and overapp_flag = 'Y' ;

cursor all_block (p_rule_id in ar_app_rules.rule_id%TYPE) is
select rule_detail_id , line_type , rounding_correction_flag , tax_treatment
from ar_app_rule_details
where rule_id = p_rule_id ;

cursor round_block (p_rule_id in ar_app_rules.rule_id%TYPE ) is
select rule_detail_id , line_type , rounding_correction_flag , tax_treatment
from ar_app_rule_details
where rule_id = p_rule_id
and rounding_correction_flag = 'Y';

cursor other_block (p_rule_id in ar_app_rules.rule_id%TYPE ) is
select rule_detail_id , line_type , rounding_correction_flag , tax_treatment
from ar_app_rule_details
where rule_id = p_rule_id
and rounding_correction_flag <> 'Y';

cursor over_app_lines (p_rule_id in number ) is
select rule_detail_id , line_type , rounding_correction_flag , tax_treatment
from ar_app_rule_details
where rule_id = p_rule_id;


l_line_tax_treatment ar_app_rule_details.tax_treatment%TYPE:='NONE';
l_freight_tax_treatment ar_app_rule_details.tax_treatment%TYPE:='NONE';
l_charges_tax_treatment ar_app_rule_details.tax_treatment%TYPE:='NONE';
o_line_tax_treatment ar_app_rule_details.tax_treatment%TYPE:='NONE';
o_freight_tax_treatment ar_app_rule_details.tax_treatment%TYPE:='NONE';
o_charges_tax_treatment ar_app_rule_details.tax_treatment%TYPE:='NONE';

l_source long;
l_round_minus long;
l_counter number:=0;
l_else_source long;
l_doc_source long;

-- Error Checking Variables
l_num_overappblock number :=0;
l_num_appblock number :=0 ;
l_num_linetype_line number:=0;
l_num_linetype_freight number :=0;
l_num_linetype_charges number :=0;
l_num_round_error number:=0;
l_num_sequence number:=0;
l_prv_sequence_num number:=-99;

l_num_error_flag number := 0;
l_temp_round number:=0;

begin

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_APP_CALC_PKG.COMPILE_RULE()+');
END IF;

for rulerec in rules loop
  l_doc_source := '/* Rule Set Name : ' || rulerec.rule_set_name ||'
 | Date Generated : ' || to_char(sysdate,'DD-MM-YYYY,HH24:MI') ;
end loop;

/* 07-SEP-99 J Rautiainen Bugfix for bug 973520. Added boolean variable
 * l_force_exit_flag. The flag is used to prevent infinite loops */
l_source := '
 l_amt ar_payment_schedules.amount_due_remaining%TYPE;
 l_line_remaining ar_payment_schedules.amount_due_remaining%TYPE;
 l_freight_remaining ar_payment_schedules.amount_due_remaining%TYPE;
 l_charges_remaining ar_payment_schedules.amount_due_remaining%TYPE;
 l_gross_remaining ar_payment_schedules.amount_due_remaining%TYPE;
 l_line_applied ar_payment_schedules.amount_due_remaining%TYPE:=0;
 l_freight_applied ar_payment_schedules.amount_due_remaining%TYPE:=0;
 l_charges_applied ar_payment_schedules.amount_due_remaining%TYPE:=0;
 l_currency ar_payment_schedules.invoice_currency_code%TYPE;
 l_counter number := 0;
 l_force_exit_flag BOOLEAN := TRUE;

BEGIN l_amt := :amt ;
      l_line_remaining := :line_remaining ;
      l_freight_remaining := :freight_remaining ;
      l_charges_remaining := :charges_remaining ;
      l_currency := :currency;
';

   for blocks in application_block loop

   -- Check whether the data is correct
   l_num_appblock := l_num_appblock + 1;

       l_doc_source := l_doc_source || '
 | ' || blocks.rule_sequence || '. ' || blocks.rule_name  ;

     for all_lines in all_block (blocks.rule_id) loop
       -- Data checking -- one rounding error per block
       l_counter := l_counter + 1;

       l_doc_source := l_doc_source || '
 |      ' || all_lines.line_type || ', Tax Treatment : ' || all_lines.tax_treatment ||
   ' , Rounding Correction : ' || all_lines.rounding_correction_flag  ;


       if l_counter = 1 then

        l_source := l_source || '
   l_gross_remaining := ';

        if all_lines.line_type = 'LINE' then
          -- Data checking
          l_num_linetype_line := l_num_linetype_line + 1;
          --
          l_source := l_source || 'l_line_remaining';
          l_else_source := l_else_source || '
          l_line_applied := l_line_remaining ;
 ';
          l_line_tax_treatment := all_lines.tax_treatment ;

        elsif all_lines.line_type = 'FREIGHT' then
          -- Data checking
          l_num_linetype_freight := l_num_linetype_freight + 1;
          --

          l_source := l_source || 'l_freight_remaining';
          l_else_source := l_else_source || '
          l_freight_applied := l_freight_remaining ;
';
          l_freight_tax_treatment := all_lines.tax_treatment ;
        elsif all_lines.line_type = 'CHARGES' then
          -- Data checking
          l_num_linetype_charges := l_num_linetype_charges + 1;
          --

          l_source := l_source || 'l_charges_remaining';
          l_else_source := l_else_source || '
          l_charges_applied := l_charges_remaining ;
';
          l_charges_tax_treatment := all_lines.tax_treatment ;
        end if;
      else
        if all_lines.line_type = 'LINE' then
          -- Data checking
          l_num_linetype_line := l_num_linetype_line + 1;
          --

          l_source := l_source || ' + l_line_remaining ';
          l_else_source := l_else_source || '
          l_line_applied := l_line_remaining ;
';
          l_line_tax_treatment := all_lines.tax_treatment ;
        elsif all_lines.line_type = 'FREIGHT' then
          -- Data checking
          l_num_linetype_freight := l_num_linetype_freight + 1;
          --

          l_source := l_source || ' + l_freight_remaining ';
          l_else_source := l_else_source || '
          l_freight_applied := l_freight_remaining ;
';
          l_freight_tax_treatment := all_lines.tax_treatment ;
        elsif all_lines.line_type = 'CHARGES' then
          -- Data checking
          l_num_linetype_charges := l_num_linetype_charges + 1;
          --

          l_source := l_source || ' + l_charges_remaining ';
          l_else_source := l_else_source || '
          l_charges_applied := l_charges_remaining ;
';
          l_charges_tax_treatment := all_lines.tax_treatment ;
        end if;
      end if;
     end loop;

     l_source := l_source || ' ; ';

     l_source := l_source || '
    if (l_amt > 0) and (l_amt <= l_gross_remaining) then
       ' ;

      for other_lines in other_block ( blocks.rule_id) loop

        if other_lines.line_type = 'LINE' then
          l_source := l_source || '
          l_line_applied :=  ' || prorate_line_gross ||';
          ' ;
          l_round_minus := l_round_minus || ' - l_line_applied ';
        elsif other_lines.line_type = 'FREIGHT' then
          l_source := l_source || '
          l_freight_applied :=  ' || prorate_freight_gross || ';
          ' ;
          l_round_minus := l_round_minus || ' - l_freight_applied ';
        elsif other_lines.line_type = 'CHARGES' then
          l_source := l_source || '
          l_charges_applied := ' || prorate_charges_gross ||';
          ' ;
          l_round_minus := l_round_minus || ' - l_charges_applied ';
        end if;

      end loop;

      for round_lines in round_block (blocks.rule_id) loop

        if round_lines.line_type = 'LINE' then
          l_source := l_source || '
          l_line_applied := l_amt ' || l_round_minus ||';
          ';
        elsif round_lines.line_type ='FREIGHT' then
          l_source := l_source || '
          l_freight_applied := l_amt ' || l_round_minus || ';
         ' ;
        elsif round_lines.line_type  = 'CHARGES' then
          l_source := l_source || '
          l_charges_applied := l_amt ' || l_round_minus || ';
         ' ;
        end if;

      l_source := l_source || '
       l_amt := 0  ;
      ';

      end loop;

      l_source := l_source || '
    elsif (l_amt > l_gross_remaining) then ' || l_else_source || '
        ';
      l_source := l_source || '
      l_amt := l_amt - l_gross_remaining ;
        ';
      l_source := l_source || '
    end if;
      ';

      l_counter := 0;
      l_else_source := '';
      l_round_minus := '';

  end loop;

  for overapp in over_application_block loop
   -- Data checking
   l_num_overappblock := l_num_overappblock + 1;
   --

     l_doc_source := l_doc_source || '
 | ' || ' Over Application Rule : ' || overapp.rule_name  ;


     for all_lines in all_block (overapp.rule_id) loop
       l_counter := l_counter + 1;

       l_doc_source := l_doc_source || '
 |      ' || all_lines.line_type || ', Tax Treatment : ' || all_lines.tax_treatment ||
   ' , Rounding Correction : ' || all_lines.rounding_correction_flag  ;

       if l_counter = 1 then

        l_source := l_source || '
   l_gross_remaining := ';

        if all_lines.line_type = 'LINE' then
          l_source := l_source || '
          l_line_remaining';
          l_else_source := l_else_source || '
          l_line_applied := l_line_remaining ; ';
          o_line_tax_treatment := all_lines.tax_treatment ;

        elsif all_lines.line_type = 'FREIGHT' then
          l_source := l_source || '
          l_freight_remaining';
          l_else_source := l_else_source || '
          l_freight_applied := l_freight_remaining ; ';
          o_freight_tax_treatment := all_lines.tax_treatment ;
        elsif all_lines.line_type = 'CHARGES' then
          l_source := l_source || '
          l_charges_remaining';
          l_else_source := l_else_source || '
          l_charges_applied := l_charges_remaining ; ';
          o_charges_tax_treatment := all_lines.tax_treatment ;
        end if;
      else
        if all_lines.line_type = 'LINE' then
          l_source := l_source || ' + l_line_remaining ';
          l_else_source := l_else_source || '
          l_line_applied := l_line_remaining ; ';
          o_line_tax_treatment := all_lines.tax_treatment ;
        elsif all_lines.line_type = 'FREIGHT' then
          l_source := l_source || ' + l_freight_remaining ';
          l_else_source := l_else_source || '
          l_freight_applied := l_freight_remaining ; ';
          o_freight_tax_treatment := all_lines.tax_treatment ;
        elsif all_lines.line_type = 'CHARGES' then
          l_source := l_source || ' + l_charges_remaining ';
          l_else_source := l_else_source || '
          l_charges_applied := l_charges_remaining ; ';
          o_charges_tax_treatment := all_lines.tax_treatment ;
        end if;
      end if;
     end loop;
     l_source := l_source || ';' ;

    /* R Yeluri for bug fix 1105018. If a transaction which has a transaction
     * type 'Allow OverApplication' set to Yes, and if that transaction is overapplied
     * after it has been closed(meaning that the amount_due_remaining, line_remaining,
     * tax_remaining, freight_remaining and charges_remaining are all = 0), then the
     * following 'IF' condition for overapplication fails, because it checks to see
     * whether any of the line_remaining,freight_remaining,charges_remaining is > 0.
     * Consequently the statement l_line_applied := l_line_applied + l_amt is never
     * executed, and hence l_line_applied  from which AMOUNT_LINE_ITEMS_REMAINING column
     * ar_payment_schedules is populated is 0. As a result updates in ar_payment_schedules
     * are incorrect.
     * Fix is to remove the condition 'and ((l_line_remaining >0) OR (l_freight_remaining >0)
     * OR (l_charges_remaining >0))' introduced as part of bug fix 840642, while retaining the
     * fix made for bug 973520. Such a fix would resolve all three bugs 840642, 973520 and 1105018.
     */

     l_source := l_source || '
    if (l_amt > 0)then
       ' ;

    /* 07-SEP-99 J Rautiainen Bugfix for bug 973520. Added boolean variable
     * l_force_exit_flag. The flag is used to prevent infinite loops.
     * Ie. if the overapplication is done on LINE, but the transaction against
     * which the application is made, doesn't have any lines (l_line_remaining = 0)
     * then the loop will never exit. */

     l_source := l_source || '
     while l_amt > l_gross_remaining loop
       ';
    for over_app_rec in over_app_lines (overapp.rule_id)  loop

      if over_app_rec.line_type= 'LINE' then

        l_source := l_source || '
         IF l_line_remaining > 0 THEN
           l_line_applied := l_line_applied + l_line_remaining ;
           l_amt := l_amt - l_line_remaining ;
           l_force_exit_flag := FALSE;
         END IF;
';
     elsif over_app_rec.line_type= 'FREIGHT' then

        l_source := l_source || '
         IF l_freight_remaining > 0 THEN
           l_freight_applied := l_freight_applied + l_freight_remaining ;
           l_amt := l_amt - l_freight_remaining ;
           l_force_exit_flag := FALSE;
         END IF;
';
     elsif over_app_rec.line_type= 'CHARGES' then

       l_source := l_source || '
         IF l_charges_remaining > 0 THEN
           l_charges_applied := l_charges_applied + l_charges_remaining ;
           l_amt := l_amt - l_charges_remaining ;
           l_force_exit_flag := FALSE;
         END IF;
';

     end if;
    end loop;

    /* 07-SEP-99 J Rautiainen Bugfix for bug 973520. Forcing exit in case of an
     * infinite loop */
    l_source := l_source || '
    IF l_force_exit_flag THEN
      EXIT;
    END IF;
   end loop;
';
     for other_lines in other_block ( overapp.rule_id) loop

        if other_lines.line_type = 'LINE' then
          l_source := l_source || '
          l_line_applied := l_line_applied +  ' || prorate_line_gross ||';
          ' ;
          l_round_minus := l_round_minus || ' - ' || prorate_line_gross ;
        elsif other_lines.line_type = 'FREIGHT' then
          l_source := l_source || '
          l_freight_applied :=  l_freight_applied + ' || prorate_freight_gross || ';
          ' ;
          l_round_minus := l_round_minus || ' - ' || prorate_freight_gross ;
        elsif other_lines.line_type = 'CHARGES' then
          l_source := l_source || '
          l_charges_applied := l_charges_applied + ' || prorate_charges_gross ||';
          ' ;
          l_round_minus := l_round_minus || ' - ' || prorate_charges_gross ;
        end if;

      end loop;

      for round_lines in round_block (overapp.rule_id) loop

        if round_lines.line_type = 'LINE' then
          l_source := l_source || '
          l_line_applied := l_line_applied + l_amt ' || l_round_minus ||';
          ';
        elsif round_lines.line_type ='FREIGHT' then
          l_source := l_source || '
          l_freight_applied := l_freight_applied + l_amt ' || l_round_minus || ';
         ' ;
        elsif round_lines.line_type  = 'CHARGES' then
          l_source := l_source || '
          l_charges_applied := l_charges_applied + l_amt ' || l_round_minus || ';
         ' ;
        end if;

      l_source := l_source || '
       l_amt := 0  ;
      ';

      l_source := l_source || '
    end if;
      ';


      end loop;

 end loop;

  l_source := l_source || '
   :line_applied := l_line_applied ;
   :freight_applied := l_freight_applied ;
   :charges_applied := l_charges_applied ;

   :line_tax_treatment := ' || '''' || l_line_tax_treatment ||''''|| ' ;
   :freight_tax_treatment := '||'''' || l_freight_tax_treatment || ''''||' ;
   :charges_tax_treatment := '||'''' || l_charges_tax_treatment ||''''|| ' ;
   :o_line_tax_treatment := ' || '''' || o_line_tax_treatment ||''''|| ' ;
   :o_freight_tax_treatment := '||'''' || o_freight_tax_treatment || ''''||' ;
   :o_charges_tax_treatment := '||'''' || o_charges_tax_treatment ||''''|| ' ; ' ;

   l_source := 'DECLARE ' || l_doc_source || ' */'  || '
' || l_source ;

   l_source := l_source || '
END ; ';

-- Checking whether every application rule one and only one time rounding
-- error flag checked.

  for blocks_rec in all_application_blocks loop
    if l_prv_sequence_num = nvl(blocks_rec.rule_sequence,-98) then
      l_num_sequence := l_num_sequence + 1;
      -- l_num_sequence cannot be bigger than 0
    end if;
    for lines_rec in all_block(blocks_rec.rule_id) loop
      if lines_rec.rounding_correction_flag = 'Y' then
        l_temp_round := l_temp_round + 1;
      end if;
    end loop;
    if l_temp_round <> 1 then
      l_num_round_error := 2;
    end if;
    l_temp_round :=0;
    l_prv_sequence_num := nvl(blocks_rec.rule_sequence,-97) ;
  end loop;

  if (   (l_num_overappblock = 1)
     AND (l_num_appblock >= 1)
     AND (l_num_linetype_line = 1)
     AND (l_num_linetype_freight = 1)
     AND (l_num_linetype_charges = 1)
     AND (l_num_sequence = 0)
     AND (l_num_round_error <> 2)
     ) then


    update ar_app_rule_sets
    set rule_source = l_source
     ,  last_updated_by = fnd_global.user_id
     ,  last_update_date = sysdate
     ,  last_update_login = fnd_global.login_id
    where rule_set_id = p_rule_set_id;
  else
   -- Error one of the data check rules is not followed the user has to update
   -- data before the rule can be frozen.
  fnd_message.set_name('AR','AR_INVALID_FREEZE_DATA');
  app_exception.raise_exception;

  end if;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_APP_CALC_PKG.COMPILE_RULE()-');
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  ARP_APP_CALC_PKG.compile_rule'||SQLERRM);
    END IF;
    RAISE;

end COMPILE_RULE;

end ARP_APP_CALC_PKG;

/
