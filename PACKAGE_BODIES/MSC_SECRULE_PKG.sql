--------------------------------------------------------
--  DDL for Package Body MSC_SECRULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SECRULE_PKG" AS
-- $Header: MSCXVSPB.pls 120.1 2005/06/20 04:26:27 appldev ship $



Procedure      INSERT_SEC_RULE
   ( p_order_type           IN Number,
     p_item_name            IN Varchar2,
     p_customer_name        IN Varchar2,
     p_supplier_name        IN Varchar2,
     p_customer_site_name   IN Varchar2,
     p_supplier_site_name   IN Varchar2,
     p_org_name             IN Varchar2,
     p_grantee_type         IN Varchar2,
     p_grantee_key          IN Varchar2,
     p_start_date           IN Date,
     p_end_date             IN Date,
     p_privilege            IN Varchar2,
     p_order_number         IN Varchar2,
     p_company_name         IN Varchar2,
     p_return_code          OUT NOCOPY Number,
     p_err_msg              OUT NOCOPY Varchar2)
     IS


    l_return_code          Number :=0;
    l_err_msg              Varchar2(1000);

    --   local variables for given inputs

    l_lookup_code           Number;
    l_item_id               Number;
    l_customer_id           Number;
    l_supplier_id           Number;
    l_customer_site_id      Number;
    l_supplier_site_id      Number;
    l_org_id                Number;
    l_grantee_key           Number;
    l_grantee_type          Varchar2(100);
    l_start_date            Date;
    l_end_date              Date;
    l_company_id            Number;
    l_customer_flag         boolean := false;
    l_supplier_flag         boolean  :=false;
    l_customer_item_flag   boolean := true;
    l_supplier_item_flag    boolean :=true;
    l_responsibility_key   varchar2(30);
    l_duplicate_rule_id    Number;

    CURSOR c_old_security_rule
    IS
    SELECT sr.rule_id
    FROM msc_x_security_rules sr
    WHERE decode(p_order_type,null,-1,sr.order_type)           = decode(p_order_type,null,-1,p_order_type)
    AND   decode(l_item_id,null,-1,sr.item_id)                  = decode(l_item_id,null,-1,l_item_id)
    AND   decode(l_customer_id,null,-1,sr.customer_id)          = decode(l_customer_id,null,-1,l_customer_id)
    AND   decode(l_supplier_id,null,-1,sr.supplier_id)          = decode(l_supplier_id,null,-1,l_supplier_id)
    AND   decode(l_customer_site_id,null,-1,sr.customer_site_id)= decode(l_customer_site_id,null,-1,l_customer_site_id)
    AND   decode(l_supplier_site_id,null,-1,sr.supplier_site_id)= decode(l_supplier_site_id,null,-1,l_supplier_site_id)
    AND   decode(l_org_id,null,-1,sr.org_id)                    = decode(l_org_id,null,-1,l_org_id)
    AND   decode(p_order_number,null,'xx',sr.order_number)        = decode(p_order_number,null,'xx',p_order_number)
    AND   sr.grantee_type       = p_grantee_type
    AND   sr.grantee_key        = l_grantee_key
    AND   sr.privilege          = p_privilege
    AND   sr.company_id         = l_company_id;
    --AND   sr.effective_from_date= l_start_date
    --AND   sr.effective_to_date  = l_end_date



BEGIN
   p_return_code:=0;
   l_responsibility_key:=mscx_ui_utilities.get_responsibility_key;
   --dbms_output.put_line('initial resp  id is   ' ||l_responsibility_key);

   -- company validation

   if (l_responsibility_key is not null ) and (l_responsibility_key='MSCX_SC_ADMIN_FULL') then

      validate_company_name(p_company_name,l_company_id,p_return_code, p_err_msg  );
         --dbms_output.put_line('after company name   ' );

   else
     l_company_id:=sys_context('msc','company_id');
         --dbms_output.put_line('initial comp  id is   ' ||l_company_id);
   end if;





     -- order type  validation


  --  validate_order_type(p_order_type,l_lookup_code,p_return_code, p_err_msg  );

      l_lookup_code:=p_order_type;




--  item_name validation

    validate_item_name(p_item_name,p_company_name,l_item_id,p_return_code,p_err_msg  );

--  customer validation

    validate_customer_name(p_customer_name,l_company_id,l_customer_id,l_customer_flag,p_return_code, p_err_msg  );


--  supplier validation

    validate_supplier_name(p_supplier_name,l_company_id,l_supplier_id,l_supplier_flag,p_return_code, p_err_msg  );
       --dbms_output.put_line('supplier name is    ' ||l_supplier_id ||'  '|| p_supplier_name||'return code' ||p_return_code);



--  customer site validation

    validate_customer_site_name(p_customer_site_name,l_company_id,l_customer_id,l_customer_site_id,l_customer_flag,p_return_code, p_err_msg  );
           --dbms_output.put_line('customer name  name is    ' ||l_customer_id ||'  '|| p_customer_name||'return code' ||p_return_code);



--  supplier site validation

    validate_supplier_site_name(p_supplier_site_name,l_company_id,l_supplier_id,l_supplier_site_id,l_supplier_flag,p_return_code, p_err_msg  );
     --dbms_output.put_line('supplier site name is    ' ||p_return_code);

--  org validation

    validate_org_name(p_org_name,l_company_id,l_org_id,p_return_code, p_err_msg );

--  grantee key validation

    validate_grantee_key(p_grantee_type,p_grantee_key,l_grantee_key,p_return_code, p_err_msg );
     --dbms_output.put_line('grantee key ' ||p_return_code );


     ---  Date validations
     if p_start_date is not null then
     BEGIN
         --l_start_date:=trunc(to_date(p_start_date));
	   l_start_date:=p_start_date;
         exception
                    when others then
                        p_return_code := -1;
                        p_err_msg := p_err_msg ||' '||'Invalid Start date';
                        -- --dbms_output.put_line('l_err_msg:=' ||p_err_msg);
     END;
     else
         l_start_date:=sysdate;
     end if ;


            --Check if end date > start date

      if p_end_date is not NULL then
      BEGIN
          --l_end_date:=trunc(to_date(p_end_date));
	  l_end_date:=p_end_date;
          if l_end_date<l_start_date then
               p_return_code := -1;
               p_err_msg := p_err_msg ||' '||'Invalid End date';
               -- --dbms_output.put_line('err message is   ' ||p_err_msg );
          end if;

          exception
                     when others then
                        p_return_code := -1;
                        p_err_msg := p_err_msg ||' '||'Invalid End date';
      END;
      else
          l_end_date := null;   /* reset the value if it is null */
      end if;
      --dbms_output.put_line('return code before insert is ' ||p_return_code);

          if p_return_code=0 then


          --  open the cursor to ceck for duplicacy of the records OK.

          OPEN  c_old_security_rule ;
	  FETCH c_old_security_rule INTO l_duplicate_rule_id;
             if c_old_security_rule%FOUND then
             p_return_code := -1;
             p_err_msg := p_err_msg ||' '||'This rule already exists';
             --dbms_output.put_line('agoel error message for DR' ||p_err_msg);
             end if ;
	     --dbms_output.put_line('agoel return code is ' ||p_return_code);
             CLOSE c_old_security_rule;
           end if ;

           if p_return_code=0 then
             if l_lookup_code>ORDER_TYPE_ZERO  then
	    -- if l_lookup_code IS NOT NULL  then

             insert into msc_x_security_rules(rule_id, order_type,item_id,customer_id,customer_site_id,
                                            supplier_id,supplier_site_id,org_id,order_number,grantee_type,
                                            grantee_key,privilege,company_id,effective_from_date,effective_to_date,
                                            item_name,creation_date,created_by,last_update_date,last_updated_by)
                                            values
                                            (msc_security_rules_s.nextval,l_lookup_code,l_item_id,l_customer_id,l_customer_site_id,
                                             l_supplier_id,l_supplier_site_id,l_org_id,p_order_number,p_grantee_type,
                                             l_grantee_key,p_privilege,l_company_id,l_start_date,l_end_date,
                                             p_item_name,sysdate,fnd_global.user_id,sysdate,fnd_global.user_id);
            else
	    insert into msc_x_security_rules(rule_id, order_type,item_id,customer_id,customer_site_id,
                                            supplier_id,supplier_site_id,org_id,order_number,grantee_type,
                                            grantee_key,privilege,company_id,effective_from_date,effective_to_date,
                                            item_name,creation_date,created_by,last_update_date,last_updated_by)
                                            values
                                            (msc_security_rules_s.nextval,NULL,l_item_id,l_customer_id,l_customer_site_id,
                                             l_supplier_id,l_supplier_site_id,l_org_id,p_order_number,p_grantee_type,
                                             l_grantee_key,p_privilege,l_company_id,l_start_date,l_end_date,
                                             p_item_name,sysdate,fnd_global.user_id,sysdate,fnd_global.user_id);
	   end if;




          end if;
          exception
                      when no_data_found then
                                p_return_code := -1;
                                p_err_msg := p_err_msg ||' '||'Invalid company name';
                                --dbms_output.put_line('l_err_msg:=' ||SQLERRM);

                        when others then
                                p_return_code := -1;
                                p_err_msg := p_err_msg ||' '||'error while inserting the record';
                                --dbms_output.put_line('l_err_msg:=' ||SQLERRM);





 END INSERT_SEC_RULE;

--  edit rule


 Procedure      EDIT_SEC_RULE
   ( p_order_type           IN Number,
     p_item_name            IN Varchar2,
     p_customer_name        IN Varchar2,
     p_supplier_name        IN Varchar2,
     p_customer_site_name   IN Varchar2,
     p_supplier_site_name   IN Varchar2,
     p_org_name             IN Varchar2,
     p_grantee_type         IN Varchar2,
     p_grantee_key          IN Varchar2,
     p_start_date           IN Date,
     p_end_date             IN Date,
     p_privilege            IN Varchar2,
     p_order_number         IN Varchar2,
     p_company_name         IN Varchar2,
     p_rule_id              IN Number,
     p_return_code          OUT NOCOPY Number,
     p_err_msg              OUT NOCOPY Varchar2)
     IS



    l_return_code          Number :=0;
    l_err_msg              Varchar2(1000);

    --   local variables for given inputs

    l_lookup_code           Number;
    l_item_id               Number;
    l_category_id           Number;
    l_customer_id           Number;
    l_supplier_id           Number;
    l_customer_site_id      Number;
    l_supplier_site_id      Number;
    l_org_id                Number;
    l_grantee_key           Number;  -- earlier it was varchar30
    l_grantee_type          Varchar2(100);
    l_start_date            Date;
    l_end_date              Date;
    l_company_id            Number;
    --l_rule_id               Number;
    l_customer_flag         boolean := false;
    l_supplier_flag         boolean  :=false;
    l_customer_item_flag   boolean := true;
    l_supplier_item_flag    boolean :=true;
    l_responsibility_key    Varchar2(30);
    l_duplicate_rule_id     Number;



    CURSOR c_old_security_rule
    IS
    SELECT sr.rule_id
    FROM msc_x_security_rules sr
    WHERE decode(l_lookup_code,null,-1,sr.order_type)           = decode(l_lookup_code,null,-1,l_lookup_code)
    AND   decode(l_item_id,null,-1,sr.item_id)                  = decode(l_item_id,null,-1,l_item_id)
    AND   decode(l_customer_id,null,-1,sr.customer_id)          = decode(l_customer_id,null,-1,l_customer_id)
    AND   decode(l_supplier_id,null,-1,sr.supplier_id)          = decode(l_supplier_id,null,-1,l_supplier_id)
    AND   decode(l_customer_site_id,null,-1,sr.customer_site_id)= decode(l_customer_site_id,null,-1,l_customer_site_id)
    AND   decode(l_supplier_site_id,null,-1,sr.supplier_site_id)= decode(l_supplier_site_id,null,-1,l_supplier_site_id)
    AND   decode(l_org_id,null,-1,sr.org_id)                    = decode(l_org_id,null,-1,l_org_id)
    AND   decode(p_order_number,null,-1,sr.order_number)        = decode(p_order_number,null,-1,p_order_number)
    AND   sr.grantee_type       = p_grantee_type
    AND   sr.grantee_key        = l_grantee_key
    AND   sr.privilege          = p_privilege
    AND   sr.company_id         = l_company_id
    AND   sr.rule_id           <> p_rule_id;


-- ordertype


BEGIN
    p_return_code:=0;
    l_responsibility_key:=mscx_ui_utilities.get_responsibility_key;

    --dbms_output.put_line('initial resp  id is   ' ||l_responsibility_key);

   -- company validation

   if (l_responsibility_key is not null ) and (l_responsibility_key='MSCX_SC_ADMIN_FULL') then

      validate_company_name(p_company_name,l_company_id,p_return_code, p_err_msg  );
      --dbms_output.put_line('after company name   ' );

   else
     l_company_id:=sys_context('msc','company_id');
     --dbms_output.put_line('initial comp  id is   ' ||l_company_id);
   end if;





     -- order type  validation


   -- validate_order_type(p_order_type,l_lookup_code,p_return_code, p_err_msg  );

      l_lookup_code:=p_order_type;



--  item_name validation

    validate_item_name(p_item_name,p_company_name,l_item_id,p_return_code,p_err_msg  );

--  customer validation

    validate_customer_name(p_customer_name,l_company_id,l_customer_id,l_customer_flag,p_return_code, p_err_msg  );


--  supplier validation

    validate_supplier_name(p_supplier_name,l_company_id,l_supplier_id,l_supplier_flag,p_return_code, p_err_msg  );
    --dbms_output.put_line('supplier name is    ' ||l_supplier_id ||'  '|| p_supplier_name||'return code' ||p_return_code);



--  customer site validation

    validate_customer_site_name(p_customer_site_name,l_company_id,l_customer_id,l_customer_site_id,l_customer_flag,p_return_code, p_err_msg  );
    --dbms_output.put_line('customer name  name is    ' ||l_customer_id ||'  '|| p_customer_name||'return code' ||p_return_code);



--  supplier site validation

    validate_supplier_site_name(p_supplier_site_name,l_company_id,l_supplier_id,l_supplier_site_id,l_supplier_flag,p_return_code, p_err_msg  );
     --dbms_output.put_line('supplier site name is    ' ||p_return_code);

--  org validation

    validate_org_name(p_org_name,l_company_id,l_org_id,p_return_code, p_err_msg );

--  grantee key validation

    validate_grantee_key(p_grantee_type,p_grantee_key,l_grantee_key,p_return_code, p_err_msg );
    --dbms_output.put_line('grantee key ' ||p_return_code );


    ---  Date validations
     if p_start_date is not null then
     BEGIN
         --l_start_date:=trunc(to_date(p_start_date));
	 l_start_date:=p_start_date;
         exception
                when others then
                        p_return_code := -1;
                        p_err_msg := p_err_msg ||' '||'Invalid Start date';
                        -- --dbms_output.put_line('l_err_msg:=' ||p_err_msg);
     END;
     else
         l_start_date:=sysdate;
     end if ;


            --Check if end date > start date
      if p_end_date is not NULL then
      BEGIN
          --l_end_date:=trunc(to_date(p_end_date));
	  l_end_date:=p_end_date;
          if l_end_date<l_start_date then
               p_return_code := -1;
               p_err_msg := p_err_msg ||' '||'Invalid End date';
               -- --dbms_output.put_line('err message is   ' ||p_err_msg );
          end if;

          exception
                when others then
                        p_return_code := -1;
                        p_err_msg := p_err_msg ||' '||'Invalid End date';
      END;
      else
          l_end_date := null;   /* reset the value if it is null */
      end if;
      --dbms_output.put_line('return code before insert is ' ||p_return_code);

          if p_return_code=0 then


          --  open the cursor to ceck for duplicacy of the records OK.

          OPEN  c_old_security_rule ;
          FETCH c_old_security_rule INTO l_duplicate_rule_id;
             if c_old_security_rule%FOUND then
             p_return_code := -1;
             p_err_msg := p_err_msg ||' '||'This rule already exists';
             --dbms_output.put_line('agoel error message for DR' ||p_err_msg);
             end if ;
             CLOSE c_old_security_rule;
          end if ;

          if p_return_code=0 then
	      if l_lookup_code>ORDER_TYPE_ZERO  then


             update msc_x_security_rules set
                order_type                  =   l_lookup_code,
                item_id                     =   l_item_id,
                customer_id                 =   l_customer_id,
                customer_site_id            =   l_customer_site_id,
                supplier_id                 =   l_supplier_id,
                supplier_site_id            =   l_supplier_site_id,
                org_id                      =   l_org_id,
                order_number                =   p_order_number,
                grantee_type                =   p_grantee_type,
                grantee_key                 =   l_grantee_key,
                privilege                   =   p_privilege,
                company_id                  =   l_company_id,
                effective_from_date         =   l_start_date,
                effective_to_date           =   l_end_date,
                item_name                   =   p_item_name,
          --      order_type_meaning          =   p_order_type,
                last_update_date            =   sysdate,
                last_updated_by             =   fnd_global.user_id
                where rule_id               =   p_rule_id;

	     else

	     update msc_x_security_rules set
                order_type                  =   null,
                item_id                     =   l_item_id,
                customer_id                 =   l_customer_id,
                customer_site_id            =   l_customer_site_id,
                supplier_id                 =   l_supplier_id,
                supplier_site_id            =   l_supplier_site_id,
                org_id                      =   l_org_id,
                order_number                =   p_order_number,
                grantee_type                =   p_grantee_type,
                grantee_key                 =   l_grantee_key,
                privilege                   =   p_privilege,
                company_id                  =   l_company_id,
                effective_from_date         =   l_start_date,
                effective_to_date           =   l_end_date,
                item_name                   =   p_item_name,
          --      order_type_meaning          =   p_order_type,
                last_update_date            =   sysdate,
                last_updated_by             =   fnd_global.user_id
                where rule_id               =   p_rule_id;

		end if;


          end if;
          exception
                        when no_data_found then
                                p_return_code := -1;
                                p_err_msg := p_err_msg ||' '||'Invalid company name';
                                --dbms_output.put_line('l_err_msg:=' ||p_err_msg);

                        when others then
                                p_return_code := 1;
                                p_err_msg := p_err_msg ||' '||'error during updating the record';
                                -- --dbms_output.put_line('l_err_msg:=' ||p_err_msg);





 END EDIT_SEC_RULE;



/* Procedure      VALIDATE_ORDER_TYPE
   ( p_order_type           IN Varchar2,
     l_lookup_code          OUT  Number,
     p_return_code          IN OUT Number,
     p_err_msg              IN OUT Varchar2)
 IS
 BEGIN
 if p_order_type is not null then
    BEGIN
        select lookup_code into l_lookup_code
        from fnd_lookup_values
        where lookup_type='MSC_X_ORDER_TYPE'
        and meaning=p_order_type
        and language=userenv('lang');


       -- --dbms_output.put_line('order type exists' ||l_lookup_code);

        exception when no_data_found then
        p_return_code:=-1;
        p_err_msg:= p_err_msg ||' '|| 'Invalid Order Type';
       -- --dbms_output.put_line('l_err_msg:=' ||p_err_msg);
    END;
 else
    l_lookup_code:=null;
 end if;
 END  VALIDATE_ORDER_TYPE;*/


-- company validation Binding done to validate name containing ( company's ) to be implemented in all cursors
-- due to time constarint implemented only in one

Procedure      VALIDATE_COMPANY_NAME
  ( p_company_name         IN Varchar2,
    l_company_id               OUT  NOCOPY Number,
    p_return_code          IN OUT NOCOPY Number,
    p_err_msg              IN OUT NOCOPY Varchar2)
 IS

 TYPE SECCurTyp IS REF CURSOR;
 sec_cursor SECCurTyp;
 sql_statement varchar2(500);
 BEGIN
     if p_company_name is not null then
            BEGIN
                --dbms_output.put_line('before the company id select'||p_company_name );
                sql_statement :='Select  mc.company_id
                from msc_companies mc
                where   mc.company_name=:1';

                OPEN sec_cursor FOR sql_statement USING
                p_company_name;


  FETCH sec_cursor INTO l_company_id;
  CLOSE sec_cursor;

                exception when no_data_found then
                p_return_code:=-1;
                p_err_msg:= p_err_msg ||' '|| 'Invalid   Company Name'||sqlcode||sqlerrm;
                --dbms_output.put_line('Company Name Exists' ||p_err_msg);
                raise;
            END;
     end if;
  END  VALIDATE_COMPANY_NAME;




  -- item name validation

  Procedure      VALIDATE_ITEM_NAME
  ( p_item_name         IN Varchar2,
    p_company_name          IN Varchar2,
    l_item_id           OUT  NOCOPY Number,
    p_return_code       IN OUT NOCOPY Number,
    p_err_msg           IN OUT NOCOPY Varchar2)
 IS

  l_customer_item_flag   boolean := true;
  l_supplier_item_flag    boolean :=true;

  BEGIN
     if p_item_name is not null then
        BEGIN
               select s.inventory_item_id into l_item_id
               from
               msc_item_suppliers s
               , msc_trading_partners tp
               where
               s.supplier_id = tp.partner_id
               and tp.partner_type = 1
               and tp.partner_name = nvl(p_company_name,sys_context('msc','company_name'))
               and s.supplier_item_name=p_item_name
	       and s.plan_id=-1
               and rownum<2;

               -- --dbms_output.put_line('item name exists' ||l_item_id);

                exception when others then
               -- p_return_code:=1;
               -- p_err_msg:= p_err_msg ||' '|| 'Invalid Item Name';
               --dbms_output.put_line('l_err_msg:= supplier item does not exist' );
                l_supplier_item_flag:=false;
        END;

    if (p_item_name is not null ) and ( l_supplier_item_flag=false ) then
      BEGIN
        select s.inventory_item_id into l_item_id
        from
                 msc_item_customers s
                , msc_trading_partners tp
       where
       s.customer_id = tp.partner_id
       and tp.partner_type = 2
       and tp.partner_name = nvl(p_company_name,sys_context('msc','company_name'))
       and s.customer_item_name=p_item_name
       and rownum<2;

        -- --dbms_output.put_line('item name exists' ||l_item_id);

        exception when others then
       -- p_return_code:=1;
       -- p_err_msg:= p_err_msg ||' '|| 'Invalid Item Name';
        --dbms_output.put_line('l_err_msg:= customer item does not exist' );
        l_customer_item_flag:=false;
      END;

    end if;

    if (p_item_name is not null ) and ( l_supplier_item_flag=false ) and ( l_customer_item_flag=false ) then
    BEGIN
        select cm.inventory_item_id into l_item_id
        from   msc_items cm
        where
        item_name=p_item_name;

       -- --dbms_output.put_line('item name exists' ||l_item_id);

        exception when no_data_found then
        p_return_code:=-1;
        p_err_msg:= p_err_msg ||' '|| 'Invalid Item Name';
        --dbms_output.put_line('l_err_msg:= Invalid item name' );

    END;
    end if;

    else
       l_item_id:=null;
    end if;
    END  VALIDATE_ITEM_NAME;

  -- customer name validation

  Procedure      VALIDATE_CUSTOMER_NAME
  ( p_customer_name         IN       Varchar2,
    l_company_id            IN       Number,
    l_customer_id           OUT  NOCOPY    Number,
    l_customer_flag         IN OUT  NOCOPY boolean,
    p_return_code           IN OUT  NOCOPY Number,
    p_err_msg               IN OUT  NOCOPY Varchar2)
  IS

     l_cust_company_id      Number:=-999 ;

 BEGIN

     if p_customer_name is not null then
         BEGIN
            select company_id into l_cust_company_id
            from msc_companies where
            company_name=p_customer_name;
            --dbms_output.put_line('Customer company id  exists'|| l_cust_company_id );
            exception when no_data_found then
            p_return_code:=-1;
            -- p_err_msg:= p_err_msg ||' '|| 'Invalid Customer Name ';
            --dbms_output.put_line('l_err_msg:='||p_err_msg);
        END;
        if l_company_id=l_cust_company_id then
            l_customer_id:=l_cust_company_id;
            l_customer_flag:=true;
        else
           BEGIN
              Select  mcr.subject_id into l_customer_id
              from msc_company_relationships mcr,
              msc_companies mc
              where
              mcr.subject_id = mc.company_id
              and   mcr.relationship_type = 2
              and   mcr.object_id =l_company_id
              and   mc.company_name=p_customer_name ;
              l_customer_flag:=true;

              --dbms_output.put_line('Customer Name Exists' ||l_item_id);

             exception when no_data_found then
             p_return_code:=-1;
             p_err_msg:= p_err_msg ||' '|| 'Invalid Customer Name';
             ----dbms_output.put_line('l_err_msg:=' ||p_err_msg);
           END;
        end if ;
    else
       l_customer_id:=null;
    end if;

  END  VALIDATE_CUSTOMER_NAME;


  -- supplier name validation

  Procedure      VALIDATE_SUPPLIER_NAME
  ( p_supplier_name         IN       Varchar2,
    l_company_id            IN       Number,
    l_supplier_id           OUT  NOCOPY    Number,
    l_supplier_flag         IN OUT NOCOPY  boolean,
    p_return_code           IN OUT NOCOPY  Number,
    p_err_msg               IN OUT  NOCOPY Varchar2)
 IS

  l_supp_company_id      Number:=-999 ;

 BEGIN
     if p_supplier_name is not null then
         BEGIN
            Select  company_id into l_supp_company_id
            from msc_companies
            where company_name=p_supplier_name;
            --dbms_output.put_line('Suppliercompany id  exists'|| l_supp_company_id );
            exception when no_data_found then
            p_return_code:=-1;
            -- p_err_msg:= p_err_msg ||' '|| 'Invalid Supplier Name';
            ----dbms_output.put_line('l_err_msg:=' ||p_err_msg);
        END;
        if l_company_id=l_supp_company_id then
            l_supplier_id := l_supp_company_id;
            l_supplier_flag:=true;

        else
           BEGIN
              Select  mcr.subject_id into l_supplier_id
              from msc_company_relationships mcr,
              msc_companies mc
              where
              mcr.subject_id = mc.company_id
              and   mcr.relationship_type = 1
              and   mcr.object_id =l_company_id
              and   mc.company_name=p_supplier_name ;
              l_supplier_flag:=true;

              --dbms_output.put_line('Supplier Name Exists' ||l_supplier_id);

              exception when no_data_found then
              p_return_code:=-1;
              p_err_msg:= p_err_msg ||' '|| 'Invalid Supplier Name';
              ----dbms_output.put_line('l_err_msg:=' ||p_err_msg);
           END;
        end if;
    else
       l_supplier_id:=null ;
    end if;

  END  VALIDATE_SUPPLIER_NAME;

  Procedure      VALIDATE_CUSTOMER_SITE_NAME
  ( p_customer_site_name         IN       Varchar2,
    l_company_id            IN       Number,
    l_customer_id           IN      Number,
    l_customer_site_id      OUT  NOCOPY    Number,
    l_customer_flag         IN OUT  NOCOPY boolean,
    p_return_code           IN OUT  NOCOPY Number,
    p_err_msg               IN OUT NOCOPY  Varchar2)
  IS

     l_cust_site_company_id  Number:=-999 ;
     l_cust_site_company_id_flag boolean  :=true;


  BEGIN
     if (p_customer_site_name is not null ) and (l_customer_flag= true) then

         BEGIN
            select company_site_id into l_cust_site_company_id
            from msc_company_sites
            where company_id=l_company_id
            and company_site_name=p_customer_site_name;
            --dbms_output.put_line('Customer company id  exists'|| l_cust_company_id );
            exception when no_data_found then
            l_cust_site_company_id_flag  :=false;

         END;

         if  (l_cust_site_company_id_flag = true) then
             l_customer_site_id:=l_cust_site_company_id;
        else
             BEGIN
                select cs.company_site_id into l_customer_site_id
                from msc_company_relationships mcr,
                msc_company_sites cs
                where mcr.subject_id = cs.company_id
                and mcr.relationship_type = 2
                and mcr.object_id=l_company_id
                and cs.company_site_name=p_customer_site_name
                and mcr.subject_id=l_customer_id ; -- added to validate if customer site belongs to a customer

                ----dbms_output.put_line('Customer Site Name Exists' ||l_item_id);

                exception when no_data_found then
                p_return_code:=-1;
                p_err_msg:= p_err_msg ||' '|| 'Invalid Customer Site for Customer ';
                -- --dbms_output.put_line('l_err_msg:=' ||p_err_msg);
             END;
        end if;

     elsif (p_customer_site_name is not null )  then
        p_return_code:=-1;
        p_err_msg:= p_err_msg ||' '|| 'Enter Valid Customer for Customer Site';
    else
        l_customer_site_id:=null;
    end if;
  END  VALIDATE_CUSTOMER_SITE_NAME;

  -- supplier_site validation

   Procedure      VALIDATE_SUPPLIER_SITE_NAME
  ( p_supplier_site_name         IN       Varchar2,
    l_company_id            IN       Number,
    l_supplier_id           IN       Number,
    l_supplier_site_id      OUT   NOCOPY   Number,
    l_supplier_flag         IN OUT NOCOPY  boolean,
    p_return_code           IN OUT NOCOPY  Number,
    p_err_msg               IN OUT NOCOPY  Varchar2)
 IS

    l_supp_site_company_id  Number:=-999 ;
    l_supp_site_company_id_flag boolean  :=true;

 BEGIN
     if (p_supplier_site_name is not null)  and (l_supplier_flag=true) then

         BEGIN
            select company_site_id into l_supp_site_company_id
            from msc_company_sites
            where company_id=l_company_id
            and company_site_name=p_supplier_site_name;
            --dbms_output.put_line('Supplier company id  exists'|| l_cust_company_id );
            exception when no_data_found then
            l_supp_site_company_id_flag  :=false;

         END;

         if  (l_supp_site_company_id_flag = true) then
            l_supplier_site_id:=l_supp_site_company_id;
         else

             BEGIN
                select cs.company_site_id into l_supplier_site_id
                from msc_company_relationships mcr,
                msc_company_sites cs
                where mcr.subject_id = cs.company_id
                and mcr.relationship_type = 1--( 'supplier of ' )
                and mcr.object_id=l_company_id
                and cs.company_site_name=p_supplier_site_name
                and mcr.subject_id=l_supplier_id ; -- added to validate if supplier site belongs to a supplier

                --dbms_output.put_line('Supplier Site Name 1' );

                exception when no_data_found then
                p_return_code:=-1;
                p_err_msg:= p_err_msg ||' '|| 'Invalid Supplier Site Name for Supplier ';
                --dbms_output.put_line('supplier site exception 1 :=' ||p_err_msg);
             END;
         end if ;

     elsif (p_supplier_site_name is not null ) then

         p_return_code:=-1;
         p_err_msg:= p_err_msg ||' '|| 'Enter Valid Supplier for Supplier Site';

    else
        l_supplier_site_id:=null;
    end if;

END  VALIDATE_SUPPLIER_SITE_NAME;

  -- validate org name

  Procedure      VALIDATE_ORG_NAME
  ( p_org_name         IN       Varchar2,
    l_company_id       IN       Number,
    l_org_id           OUT   NOCOPY   Number,
    p_return_code      IN OUT NOCOPY  Number,
    p_err_msg          IN OUT NOCOPY  Varchar2)
 IS
 BEGIN
   if p_org_name is not null then
   BEGIN
        select company_site_id into l_org_id
        from msc_company_sites
        where company_id=l_company_id
        and company_site_name=p_org_name;

        -- --dbms_output.put_line('Org Name Exists' ||l_item_id);

        exception when no_data_found then
        p_return_code:=-1;
        p_err_msg:= p_err_msg ||' '|| 'Invalid Org  Name';
        --dbms_output.put_line('l_err_msg:=' ||p_err_msg);
    END;
      else
      l_org_id:=null;
      end if;
  END  VALIDATE_ORG_NAME;


  Procedure      VALIDATE_GRANTEE_KEY
  ( p_grantee_type     IN       Varchar2,
    p_grantee_key      IN       Varchar2,
    l_grantee_key      OUT   NOCOPY   Number,
    p_return_code      IN OUT NOCOPY  Number,
    p_err_msg          IN OUT NOCOPY  Varchar2)
 IS
 BEGIN
   if p_grantee_type = 'COMPANY' then

       if p_grantee_key is not null then
          BEGIN
            select  company_id into l_grantee_key from msc_companies
            where   company_name=p_grantee_key;

            -- --dbms_output.put_line('grantee key Exists' ||l_item_id);

            exception when no_data_found then
            p_return_code:=-1;
            p_err_msg:= p_err_msg ||' '|| 'Invalid Assigned To';
            -- --dbms_output.put_line('l_err_msg:=' ||p_err_msg);
          END;
       else
          --l_grantee_key:=null;
          -- code for grantee key as null
          p_return_code:=-1;
          p_err_msg:= p_err_msg ||' '|| 'Assigned To cannot be null';
       end if;

    elsif p_grantee_type='USER' then

        if p_grantee_key is not null then
          BEGIN
            select user_id into l_grantee_key from fnd_user
            where  user_name=p_grantee_key;

            -- --dbms_output.put_line('Grantee key Exists' ||l_item_id);

            exception when no_data_found then
            p_return_code:=-1;
            p_err_msg:= p_err_msg ||' '|| 'Invalid Assigned To';
            -- --dbms_output.put_line('l_err_msg:=' ||p_err_msg);
          END;
       else
         -- l_grantee_key:=null;
         -- code for grantee key as null
          p_return_code:=-1;
          p_err_msg:= p_err_msg ||' '|| 'Assigned To cannot be null';
       end if;

      elsif p_grantee_type='RESPONSIBILITY' then
        if p_grantee_key is not null then
          BEGIN
            select responsibility_id into l_grantee_key from fnd_responsibility_vl
            where  responsibility_name=p_grantee_key;

            -- --dbms_output.put_line('Grantee key Exists' ||l_item_id);

            exception when no_data_found then
            p_return_code:=-1;
            p_err_msg:= p_err_msg ||' '|| 'Invalid Assigned To';
            -- --dbms_output.put_line('l_err_msg:=' ||p_err_msg);
          END;
        else
         -- l_grantee_key:=null;
         -- code for grantee key as null
          p_return_code:=-1;
          p_err_msg:= p_err_msg ||' '|| 'Assigned To cannot be null';
        end if;

      elsif p_grantee_type='GROUP' then
        if p_grantee_key is not null then
          BEGIN
            select group_id into l_grantee_key from msc_groups
            where group_name =p_grantee_key;

            exception when no_data_found then
            p_return_code:=-1;
            p_err_msg:= p_err_msg ||' '|| 'Invalid Assigned To';
          END;
        else
         -- l_grantee_key:=null;
         -- code for grantee key as null
          p_return_code:=-1;
          p_err_msg:= p_err_msg ||' '|| 'Assigned To cannot be null';
        end if;

      elsif (p_grantee_type='GLOBAL' ) then
        if p_grantee_key is not null then
        p_err_msg:= p_err_msg ||' '|| 'Assigned To should be null';
        p_return_code:=-1;
        -- --dbms_output.put_line('l_err_msg:=' ||p_err_msg);
        else
        l_grantee_key:=null;
        end if;

     end if;

  END  VALIDATE_GRANTEE_KEY;





END MSC_SECRULE_PKG;








/
