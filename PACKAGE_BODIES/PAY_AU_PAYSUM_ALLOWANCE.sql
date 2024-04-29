--------------------------------------------------------
--  DDL for Package Body PAY_AU_PAYSUM_ALLOWANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_PAYSUM_ALLOWANCE" as
/* $Header: pyaupsalw.pkb 120.0.12010000.2 2009/02/16 23:56:19 skshin noship $*/
/* ------------------------------------------------------------------------+
***
*** Change History
***
*** Date       Changed By  Version Bug No   Description of Change
*** ---------  ----------  ------- ------   --------------------------------+
*** 18 DEC 08  skshin      115.0   7571001  Initial Version
*** 23 DEC 08  skshin      115.1   7571001  Added Validate/Transfer mode
*** 23 DEC 08  skshin      115.2   7571001  Modified to report save_run_balance set as <> 'Y'
*** 20 JAN 09  skshin      115.3   7571001  Brokeen into small procedures
*** 09 FEB 09  skshin      115.4   8240322  Added join condition to get_allowance_balance_upg cursor to exclude seeded balances
                                   8240361  Added get_dimension_asg_le_ytd cursor and changed get_allowance_balance_upg to fetch
                                            balances without _ASG_LE_YTD dimension
*** 10 FEB 09  skshin      115.5   8240361  Changed check_balance_dimension cursor to report Balances with both _ASG_LE_YTD and _ASG_LE_RUN dimensions
*** ------------------------------------------------------------------------+
*/

procedure upgrade_allowance_bar (
                                  errbuf    out NOCOPY varchar2,
                                  retcode   out NOCOPY varchar2,
                                  p_business_group_id in HR_ALL_ORGANIZATION_UNITS.organization_id%type,
                                  p_mode in varchar2
                                  ) is

CURSOR get_dimension_asg_le_ytd IS
select balance_dimension_id
from pay_balance_dimensions
where  dimension_name = '_ASG_LE_YTD'
     and  legislation_code = 'AU'
;

CURSOR get_allowance_balance_upg (c_balance_dimension_id pay_balance_dimensions.balance_dimension_id%type)
IS
select  distinct pbt.balance_name
     ,      pdb.defined_balance_id
     ,      pbt.balance_type_id
     from   pay_element_types_f         pet
     ,      pay_balance_types           pbt
     ,      pay_defined_balances        pdb
     where pet.business_group_id = p_business_group_id
     and   pet.element_information_category = 'AU_EARNINGS'
     and   pet.element_information1        = 'Y'
     and   pet.element_information2        = pbt.balance_type_id
     and   (pbt.business_group_id is not null or pbt.legislation_code is null)
     and   pbt.balance_type_id             = pdb.balance_type_id(+)
     and   pdb.balance_dimension_id(+) = c_balance_dimension_id
     and   not exists (
                                   select null
                                   from pay_balance_attributes pba,
                                             pay_bal_attribute_definitions pbad
                                   where pba.defined_balance_id = pdb.defined_balance_id
                                        and pbad.attribute_name = 'AU_EOY_ALLOWANCE'
                                        and pbad.attribute_id = pba.attribute_id
                                    )
     order by 1
     ;

CURSOR check_balance_dimension (c_balance_type_id pay_balance_types.balance_type_id%type)
IS
select pbt.balance_name
       ,count(pdb.defined_balance_id) dim_count
from
          pay_defined_balances        pdb
     ,    pay_balance_dimensions  pbd
     ,    pay_balance_types              pbt
where pdb.balance_dimension_id(+) = pbd.balance_dimension_id
and pbd.dimension_name in ( '_ASG_LE_YTD', '_ASG_LE_RUN')
and pbd.legislation_code = 'AU'
and pdb.balance_type_id(+) = c_balance_type_id
and pbt.balance_type_id = c_balance_type_id
group by pbt.balance_name
order by 1
;



CURSOR get_allowance_balance_lst (c_business_group_id in HR_ALL_ORGANIZATION_UNITS.organization_id%type)
IS
select  pbt.balance_name, pbt.balance_type_id
  from  PAY_BAL_ATTRIBUTE_DEFINITIONS pbad
            ,pay_balance_attributes pba
            ,pay_defined_balances        pdb
            ,pay_balance_types           pbt
            ,pay_balance_dimensions pbd
 where  pbad.attribute_name = 'AU_EOY_ALLOWANCE'
     and   pba.attribute_id = pbad.attribute_id
     and   pba.defined_balance_id = pdb.defined_balance_id
     and   pdb.balance_type_id = pbt.balance_type_id
     and   pdb.business_group_id = c_business_group_id
     and   pbd.balance_dimension_id = pdb.balance_dimension_id
     and   pbd.dimension_name = '_ASG_LE_YTD'
     and   pbd.legislation_code = 'AU'
     order by 1
     ;



rec_allowance_balance get_allowance_balance_upg%rowtype;
rec_alw_lst get_allowance_balance_lst%rowtype;
rec_chk_bal_dim check_balance_dimension%rowtype;


TYPE rec_balance IS RECORD (balance_name pay_balance_types.balance_name%type);
TYPE tab_check_balance IS TABLE OF rec_balance INDEX BY BINARY_INTEGER;
t_chk_bal tab_check_balance;
t_chk_bal_lst tab_check_balance;

l_business_group_name per_business_groups.name%type;
l_balance_dimension_id pay_balance_dimensions.balance_dimension_id%type;
counter number := 1;
counter_lst number :=1;
cnt number:= 1;
cntl number:= 1;
l_mode varchar2(10);
error_code number;
error_message varchar2(255);

BEGIN

 t_allowance_balance.delete;
 t_chk_bal.delete;

select name into l_business_group_name
from per_business_groups
where business_group_id = p_business_group_id;

select decode(p_mode, 'V', 'Validate', 'Update') into l_mode from dual;

FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Business Group Name : '|| l_business_group_name);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Running Mode : '|| l_mode);

OPEN get_dimension_asg_le_ytd;
FETCH get_dimension_asg_le_ytd into l_balance_dimension_id;
CLOSE get_dimension_asg_le_ytd;

/* identifying allowance balance for ba upgrade */
OPEN get_allowance_balance_upg(l_balance_dimension_id);
LOOP
FETCH get_allowance_balance_upg into rec_allowance_balance;

   EXIT WHEN get_allowance_balance_upg%NOTFOUND;

        t_allowance_balance(cnt).balance_name := rec_allowance_balance.balance_name;
        t_allowance_balance(cnt).defined_balance_id := rec_allowance_balance.defined_balance_id;
        t_allowance_balance(cnt).balance_type_id := rec_allowance_balance.balance_type_id;

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Allowance balance name to be upgraded is '||t_allowance_balance(cnt).balance_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Allowance defined_balance_id to be upgraded is '||t_allowance_balance(cnt).defined_balance_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Allowance balance_type_id to be upgraded is '||t_allowance_balance(cnt).balance_type_id);

        /* finding balance with missing dimension */
         FOR rec_chk_bal_dim IN check_balance_dimension(rec_allowance_balance.balance_type_id) LOOP
                IF rec_chk_bal_dim.dim_count < 2 THEN
                    t_chk_bal(counter).balance_name := rec_chk_bal_dim.balance_name;
                    counter := counter + 1;
                END IF;
        END LOOP;

    cnt := cnt + 1;

END LOOP;
CLOSE get_allowance_balance_upg;

/* finding balance with ba having missing diemnsions */
OPEN get_allowance_balance_lst(p_business_group_id);
LOOP
FETCH get_allowance_balance_lst INTO rec_alw_lst;

   EXIT WHEN get_allowance_balance_lst%NOTFOUND;

        tl_allowance_balance(cntl).balance_name := rec_alw_lst.balance_name;
        tl_allowance_balance(cntl).balance_type_id := rec_alw_lst.balance_type_id;

         FOR rec_chk_bal_dim_lst IN check_balance_dimension(rec_alw_lst.balance_type_id) LOOP
                IF rec_chk_bal_dim_lst.dim_count < 2 THEN
                    t_chk_bal_lst(counter_lst).balance_name := rec_chk_bal_dim_lst.balance_name;
                    counter_lst := counter_lst + 1;
                END IF;
        END LOOP;

    cntl := cntl + 1;

END LOOP;
CLOSE get_allowance_balance_lst;

IF (t_chk_bal.count > 0) or (t_chk_bal_lst.count > 0) THEN -- for balances with missing dimensions
FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'----------------------------------------------------------------------------');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Allowance Balance(s) with missing _ASG_LE_YTD and/or _ASG_LE_RUN dimension(s)');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'----------------------------------------------------------------------------');

   IF t_chk_bal.count > 0 THEN
    FOR i in t_chk_bal.first .. t_chk_bal.last LOOP

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'The missing dimensions for "'||t_chk_bal(i).balance_name ||'" balance');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, t_chk_bal(i).balance_name);

    END LOOP;
    END IF;

      IF t_chk_bal_lst.count > 0 THEN
      FOR i in t_chk_bal_lst.first .. t_chk_bal_lst.last LOOP

      FND_FILE.PUT_LINE(FND_FILE.LOG,  '*The missing dimensions for "'||t_chk_bal_lst(i).balance_name ||'" balance');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, t_chk_bal_lst(i).balance_name);

    END LOOP;
    END IF;

FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ***** Dimension(s) Missing ERROR ***** ');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'* Check above balance(s) for missing dimensions required in End of Year process before progressing further');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'* After adding the missing dimension(s), re-run the concurrent program');

ELSE

    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'1. List of Allowance balance for Balance Attribute Upgrade');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '1 =====>');

   /* Call for Balance Attribute Upgrade */
    upgrade_ba (cnt, t_allowance_balance, p_business_group_id, p_mode);

    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'---------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'2. List of Allowance balance for Group Level Run dimension Upgrade');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'---------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '2 =====>');

    /* Call for Group Level Run dimension upgrade */
    upgrade_glr ( t_allowance_balance, tl_allowance_balance, l_business_group_name, p_mode);

    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'---------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'3. List of Allowance balance which has not been enabled for Assignment Level Run and Group Level Run');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'---------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '3 =====>');

    /* Call for checking Run balances and upgrade if not exists */
    check_run (t_allowance_balance, tl_allowance_balance, p_mode);

    IF p_mode = 'V' THEN  -- validate mode
        null;
    ELSE
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------------------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'4. List of Allowance balance that will be reported in the Payment Summary');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-------------------------------------------------------------------------');

    FOR rec_allowance_balance_lst in get_allowance_balance_lst(p_business_group_id) LOOP

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rec_allowance_balance_lst.balance_name);

    END LOOP;
    END IF;


END IF;

exception

  when others then

    error_code :=SQLCODE;
    error_message := SQLERRM ;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ***** ERRORS ***** ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' Report to Oracle Support.');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,error_code ||' : '||error_message);

    raise;

END upgrade_allowance_bar;

procedure upgrade_ba (
                                  p_cnt in number,
                                  p_allowance_balance in tab_allowance_balance,
                                  p_business_group_id in HR_ALL_ORGANIZATION_UNITS.organization_id%type,
                                  p_mode in varchar2
                                  ) is

CURSOR get_balance_attribute IS
        select attribute_id
        from    PAY_BAL_ATTRIBUTE_DEFINITIONS
        where attribute_name = 'AU_EOY_ALLOWANCE' ;

l_attribute_id PAY_BAL_ATTRIBUTE_DEFINITIONS.attribute_id%type;
l_validate boolean;
l_balance_attribute_id PAY_BALANCE_ATTRIBUTES.balance_attribute_id%type;
e_bad_global exception;

error_code number;
error_message varchar2(255);

BEGIN

  IF (p_cnt = 1) THEN
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'There is NO balance to be upgraded.');
  ELSIF p_allowance_balance.count > 0 THEN  -- balances for ba upgrade

        OPEN get_balance_attribute;
        FETCH get_balance_attribute into l_attribute_id;
            IF get_balance_attribute%NOTFOUND THEN
                raise e_bad_global;
            END IF;

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Attribute ID for AU_EOY_ALLOWANCE : '||l_attribute_id);

        CLOSE get_balance_attribute;

        FOR i IN p_allowance_balance.first .. p_allowance_balance.last LOOP

            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Defined Balance ID parameter : '|| t_allowance_balance(i).defined_balance_id);

            IF p_mode = 'V' THEN  -- validate mode
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_allowance_balance(i).balance_name);
            ELSE  -- update mode
                      PAY_BALANCE_ATTRIBUTE_API.create_balance_attribute
                            (p_validate                        => l_validate
                            ,p_attribute_id                   => l_attribute_id
                            ,p_defined_balance_id   => p_allowance_balance(i).defined_balance_id
                            ,p_business_group_id   => p_business_group_id
                            ,p_balance_attribute_id  => l_balance_attribute_id
                            );

                          IF l_balance_attribute_id is not null THEN
                              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_allowance_balance(i).balance_name);

                         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Successful Upgrade for '|| p_allowance_balance(i).balance_name);
                          ELSE
                              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_allowance_balance(i).balance_name||' => Unsuccessful *****');

                          FND_FILE.PUT_LINE(FND_FILE.LOG, 'UnSuccessful Upgrade for '|| p_allowance_balance(i).balance_name);
                          END IF;
            END IF;

        END LOOP;

    END IF;

exception
  when e_bad_global then

    close get_balance_attribute;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ***** No Balance Attribute ERROR ***** ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' Report to Oracle Support.');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ***** No Balance Attribute ERROR ***** ');

    raise;

  when others then

    error_code :=SQLCODE;
    error_message := SQLERRM ;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ***** ERRORS ***** ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' Report to Oracle Support.');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,error_code ||' : '||error_message);

     raise;

end upgrade_ba;


procedure upgrade_glr (
                                  p_t_allowance_balance in tab_allowance_balance,
                                  p_tl_allowance_balance in tab_allowance_balance,
                                  p_business_group_name in per_business_groups.name%type,
                                  p_mode in varchar2
                                  ) is

CURSOR get_dimension_le_ytd (c_balance_type_id pay_balance_types.balance_type_id%type) IS
select pdb.defined_balance_id
from pay_balance_dimensions pbd, pay_defined_balances pdb
where pbd.dimension_name = '_LE_YTD'
and pbd.legislation_code = 'AU'
and pbd.balance_dimension_id = pdb.balance_dimension_id
and pdb.balance_type_id = c_balance_type_id
;

CURSOR get_dimension_le_run (c_balance_type_id pay_balance_types.balance_type_id%type) IS
select pdb.defined_balance_id
from pay_balance_dimensions pbd, pay_defined_balances pdb
where pbd.dimension_name = '_LE_RUN'
and pbd.legislation_code = 'AU'
and pbd.balance_dimension_id = pdb.balance_dimension_id
and pdb.balance_type_id = c_balance_type_id
;

l_defined_balance_id pay_defined_balances.defined_balance_id%type;
l_exist number := 0;
error_code number;
error_message varchar2(255);

BEGIN

     IF p_mode = 'V' THEN  -- validate mode

        IF (p_t_allowance_balance.count > 0) THEN

            FOR i in p_t_allowance_balance.first .. p_t_allowance_balance.last LOOP

                open get_dimension_le_ytd (p_t_allowance_balance(i).balance_type_id);
                fetch get_dimension_le_ytd into  l_defined_balance_id;
                    IF get_dimension_le_ytd%NOTFOUND THEN
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(p_t_allowance_balance(i).balance_name,1,30),30,' ') ||' : _LE_YTD' );
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Balance  : '|| p_t_allowance_balance(i).balance_name||' without  _LE_YTD');
                        l_exist := l_exist + 1;
                    END IF;
                close get_dimension_le_ytd;

                open get_dimension_le_run (p_t_allowance_balance(i).balance_type_id);
                fetch get_dimension_le_run into  l_defined_balance_id;
                    IF get_dimension_le_run%NOTFOUND THEN
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(p_t_allowance_balance(i).balance_name,1,30),30,' ') ||' : _LE_RUN' );
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Balance  : '|| p_t_allowance_balance(i).balance_name||' without  _LE_RUN');
                        l_exist := l_exist + 1;
                    END IF;
                close get_dimension_le_run;

            END LOOP;

        END IF;

        IF (p_tl_allowance_balance.count > 0) THEN

            FOR i in p_tl_allowance_balance.first .. p_tl_allowance_balance.last LOOP

                open get_dimension_le_ytd (p_tl_allowance_balance(i).balance_type_id);
                fetch get_dimension_le_ytd into  l_defined_balance_id;
                    IF get_dimension_le_ytd%NOTFOUND THEN
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(p_tl_allowance_balance(i).balance_name,1,30),30,' ') ||' : _LE_YTD' );
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Balance  : '|| p_tl_allowance_balance(i).balance_name||' without  _LE_YTD');
                        l_exist := l_exist + 1;
                    END IF;
                close get_dimension_le_ytd;

                open get_dimension_le_run (p_tl_allowance_balance(i).balance_type_id);
                fetch get_dimension_le_run into  l_defined_balance_id;
                    IF get_dimension_le_run%NOTFOUND THEN
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(p_tl_allowance_balance(i).balance_name,1,30),30,' ') ||' : _LE_RUN' );
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Balance  : '|| p_tl_allowance_balance(i).balance_name||' without  _LE_RUN');
                        l_exist := l_exist + 1;
                    END IF;
                close get_dimension_le_run;

            END LOOP;

        END IF;

    ELSE  -- update mode

        IF (p_t_allowance_balance.count > 0) THEN

            FOR i in p_t_allowance_balance.first .. p_t_allowance_balance.last LOOP

                open get_dimension_le_ytd (p_t_allowance_balance(i).balance_type_id);
                fetch get_dimension_le_ytd into  l_defined_balance_id;
                    IF get_dimension_le_ytd%NOTFOUND THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Balance  : '|| p_t_allowance_balance(i).balance_name||' without _LE_YTD');
                         pay_db_pay_setup.create_defined_balance(
                                        p_balance_name          => p_t_allowance_balance(i).balance_name,
                                        p_balance_dimension     => '_LE_YTD',
                                        p_business_group_name      => p_business_group_name
                                       );
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(p_t_allowance_balance(i).balance_name,1,30),30,' ') ||' : _LE_YTD' );
                        l_exist := l_exist + 1;
                    END IF;
                close get_dimension_le_ytd;

                open get_dimension_le_run (p_t_allowance_balance(i).balance_type_id);
                fetch get_dimension_le_run into  l_defined_balance_id;
                    IF get_dimension_le_run%NOTFOUND THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Balance  : '|| p_t_allowance_balance(i).balance_name||' without _LE_RUN');
                         pay_db_pay_setup.create_defined_balance(
                                        p_balance_name          => p_t_allowance_balance(i).balance_name,
                                        p_balance_dimension     => '_LE_RUN',
                                        p_business_group_name      => p_business_group_name
                                       );
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(p_t_allowance_balance(i).balance_name,1,30),30,' ') ||' : _LE_RUN' );
                        l_exist := l_exist + 1;
                    END IF;
                close get_dimension_le_run;

            END LOOP;

        END IF;

        IF (p_tl_allowance_balance.count > 0) THEN

            FOR i in p_tl_allowance_balance.first .. p_tl_allowance_balance.last LOOP

                open get_dimension_le_ytd (p_tl_allowance_balance(i).balance_type_id);
                fetch get_dimension_le_ytd into  l_defined_balance_id;
                    IF get_dimension_le_ytd%NOTFOUND THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Balance  : '|| p_tl_allowance_balance(i).balance_name||' without _LE_YTD');
                         pay_db_pay_setup.create_defined_balance(
                                        p_balance_name          => p_tl_allowance_balance(i).balance_name,
                                        p_balance_dimension     => '_LE_YTD',
                                        p_business_group_name      => p_business_group_name
                                       );
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(p_tl_allowance_balance(i).balance_name,1,30),30,' ') ||' : _LE_YTD' );
                        l_exist := l_exist + 1;
                    END IF;
                close get_dimension_le_ytd;

                open get_dimension_le_run (p_tl_allowance_balance(i).balance_type_id);
                fetch get_dimension_le_run into  l_defined_balance_id;
                    IF get_dimension_le_run%NOTFOUND THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Balance  : '|| p_tl_allowance_balance(i).balance_name||' without _LE_RUN');
                         pay_db_pay_setup.create_defined_balance(
                                        p_balance_name          => p_tl_allowance_balance(i).balance_name,
                                        p_balance_dimension     => '_LE_RUN',
                                        p_business_group_name      => p_business_group_name
                                       );
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(p_tl_allowance_balance(i).balance_name,1,30),30,' ') ||' : _LE_RUN' );
                        l_exist := l_exist + 1;
                    END IF;
                close get_dimension_le_run;

            END LOOP;

        END IF;

    END IF;

    IF l_exist = 0 THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'There is NO balance to be upgraded.');
    END IF;

exception

  when others then

    error_code :=SQLCODE;
    error_message := SQLERRM ;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ***** ERRORS ***** ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' Report to Oracle Support.');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,error_code ||' : '||error_message);

    raise;

end upgrade_glr;

procedure check_run (
                                  p_t_allowance_balance in tab_allowance_balance,
                                  p_tl_allowance_balance in tab_allowance_balance,
                                  p_mode in varchar2
                                  )  IS

CURSOR get_run_balance (c_balance_type_id pay_balance_types.balance_type_id%type) IS
select pbt.balance_name, pbd.dimension_name, pdb.defined_balance_id, pdb.save_run_balance
from pay_balance_types pbt
          ,pay_defined_balances pdb
          ,pay_balance_dimensions pbd
where pbt.balance_type_id = pdb.balance_type_id
and pbt. balance_type_id = c_balance_type_id
and pbd.balance_dimension_id = pdb.balance_dimension_id
and pbd.dimension_name in ('_ASG_LE_RUN','_LE_RUN')
and nvl(pdb.save_run_balance, 'N') <> 'Y'
order by 1, 2
;

l_dimension_name_run pay_balance_dimensions.dimension_name%type;
l_found number := 1;
error_code number;
error_message varchar2(255);

BEGIN

     IF p_mode = 'V' THEN  -- validate mode

        IF (p_t_allowance_balance.count > 0) THEN

            FOR i in p_t_allowance_balance.first .. p_t_allowance_balance.last LOOP

                FOR rec_run_balance in get_run_balance (p_t_allowance_balance(i).balance_type_id) LOOP
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(p_t_allowance_balance(i).balance_name,1,30),30,' ') ||' : '||rec_run_balance.dimension_name);
                        l_found := l_found + 1;
                END LOOP;

            END LOOP;

        END IF;

        IF (p_tl_allowance_balance.count > 0) THEN

            FOR i in p_tl_allowance_balance.first .. p_tl_allowance_balance.last LOOP

                FOR rec_run_balance in get_run_balance (p_tl_allowance_balance(i).balance_type_id) LOOP
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(p_tl_allowance_balance(i).balance_name,1,30),30,' ') ||' : '||rec_run_balance.dimension_name);
                        l_found := l_found + 1;
                END LOOP;

            END LOOP;

        END IF;

    ELSE  -- update mode

        IF (p_t_allowance_balance.count > 0) THEN

            FOR i in p_t_allowance_balance.first .. p_t_allowance_balance.last LOOP

                FOR rec_run_balance in get_run_balance (p_t_allowance_balance(i).balance_type_id) LOOP
                        FND_FILE.PUT_LINE(FND_FILE.LOG,p_t_allowance_balance(i).balance_name||' with '||rec_run_balance.dimension_name||'('||rec_run_balance.defined_balance_id||') : '||rec_run_balance.save_run_balance);
                        l_found := l_found + 1;

                        UPDATE  pay_defined_balances
                        SET  save_run_balance = 'Y'
                        WHERE  defined_balance_id = rec_run_balance.defined_balance_id;

                        IF SQL%FOUND THEN
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(p_t_allowance_balance(i).balance_name,1,30),30,' ') ||' : '||rec_run_balance.dimension_name);
                        END IF;


                END LOOP;

            END LOOP;

        END IF;

        IF (p_tl_allowance_balance.count > 0) THEN

            FOR i in p_tl_allowance_balance.first .. p_tl_allowance_balance.last LOOP

                FOR rec_run_balance in get_run_balance (p_tl_allowance_balance(i).balance_type_id) LOOP
                        FND_FILE.PUT_LINE(FND_FILE.LOG,p_tl_allowance_balance(i).balance_name||' with '||rec_run_balance.dimension_name||'('||rec_run_balance.defined_balance_id||') : '||rec_run_balance.save_run_balance);
                        l_found := l_found + 1;

                        UPDATE  pay_defined_balances
                        SET  save_run_balance = 'Y'
                        WHERE  defined_balance_id = rec_run_balance.defined_balance_id;

                        IF SQL%FOUND THEN
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(p_tl_allowance_balance(i).balance_name,1,30),30,' ') ||' : '||rec_run_balance.dimension_name);
                        END IF;
                END LOOP;

            END LOOP;

        END IF;

    END IF;

    IF l_found = 1 THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'There is NO balance to be upgraded.');
    END IF;

exception

  when others then

    error_code :=SQLCODE;
    error_message := SQLERRM ;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ***** ERRORS ***** ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' Report to Oracle Support.');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,error_code ||' : '||error_message);

    raise;

end check_run;

END pay_au_paysum_allowance;

/
