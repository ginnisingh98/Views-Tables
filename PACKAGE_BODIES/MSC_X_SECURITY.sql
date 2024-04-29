--------------------------------------------------------
--  DDL for Package Body MSC_X_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_SECURITY" as
/*$Header: MSCXSECB.pls 115.4 2002/10/04 21:39:54 agoel ship $ */

   procedure set_context is

      v_company_id        NUMBER;
      v_company_name      varchar2(2000);

   begin

      -- Reset context values to null

      dbms_session.set_context('MSC', 'COMPANY_ID', null);
      dbms_session.set_context('MSC', 'COMPANY_NAME', null);

      -- get the company id

      begin

        select c.company_name, c.company_id
        into v_company_name, v_company_id
        from
          MSC_COMPANY_USERS uc,
          msc_companies c
        where
          uc.user_id = FND_GLOBAL.USER_ID
          and c.company_id = uc.company_id;

      exception

        when others then

          v_company_id := -666;
          v_company_name := '###UNDEFINED####';

      end;

      -- set the context values

      dbms_session.set_context('MSC', 'COMPANY_ID', to_char(v_company_id));
      dbms_session.set_context('MSC', 'COMPANY_NAME', v_company_name);


   end set_context;

  /**
    The performace of this function really sucks....
  */

  function get_security_access(p_transaction_id in number) return varchar2 is

    v_privilege varchar2(30) := null;

  begin

    for rec in (
      select
         rule.privilege
      from
         msc_sup_dem_entries supdem,
         MSC_X_SECURITY_RULES rule
      where
         sysdate between nvl(rule.EFFECTIVE_FROM_DATE, sysdate-1) and nvl(rule.EFFECTIVE_TO_DATE, sysdate +1)
         and nvl(rule.company_id, supdem.PUBLISHER_ID) = supdem.PUBLISHER_ID
         and nvl(rule.order_type, supdem.publisher_order_type) = supdem.publisher_order_type
         and nvl(rule.item_id, supdem.inventory_item_id) = supdem.inventory_item_id
         and nvl(rule.customer_id, nvl(supdem.customer_id, -1)) = nvl(supdem.customer_id, -1)
         and nvl(rule.supplier_id, nvl(supdem.supplier_id, -1)) = nvl(supdem.supplier_id, -1)
         and nvl(rule.customer_site_id, nvl(supdem.customer_site_id, -1)) = nvl(supdem.customer_site_id, -1)
         and nvl(rule.supplier_site_id, nvl(supdem.supplier_site_id, -1)) = nvl(supdem.supplier_site_id, -1)
         and nvl(rule.org_id, supdem.PUBLISHER_SITE_ID) = supdem.PUBLISHER_SITE_ID
         and nvl(rule.order_number, nvl(supdem.order_number, -1)) = nvl(supdem.order_number, -1)
         and (rule.grantee_key = decode(upper(rule.grantee_type), 'USER', FND_GLOBAL.USER_ID, 'COMPANY', sys_context('MSC', 'COMPANY_ID'))
                or upper(rule.grantee_type) = 'DOCUMENT OWNER' and supdem.publisher_id = sys_context('MSC', 'COMPANY_ID')
                or upper(rule.grantee_type) = 'TRADING PARTNER' and nvl(supdem.customer_id, supdem.supplier_id) = sys_context('MSC', 'COMPANY_ID')
                or decode(upper(rule.grantee_type),'RESPONSIBILITY', rule.grantee_key) = fnd_global.resp_id
                or (upper(rule.grantee_key) = 'GLOBAL')
              )
         and supdem.transaction_id = transaction_id
      ) loop

        if (v_privilege is null or v_privilege = 'VIEW') then
          v_privilege := upper(rec.privilege);
        end if;

      end loop;

      return v_privilege;

  end get_security_access;

end msc_x_security;

/
