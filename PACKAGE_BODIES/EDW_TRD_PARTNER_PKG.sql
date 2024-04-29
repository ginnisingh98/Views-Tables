--------------------------------------------------------
--  DDL for Package Body EDW_TRD_PARTNER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_TRD_PARTNER_PKG" AS
  /* $Header: poafktpb.pls 120.1 2005/06/13 12:51:45 sriswami noship $ */


 Function supplier_site_fk(p_vendor_site_id in NUMBER,
                           p_org_id         in NUMBER,
                           p_instance_code  in VARCHAR2 := NULL) return VARCHAR2 IS

  l_tp VARCHAR2(120)      := 'NA_EDW';
  l_instance VARCHAR2(30) := NULL;

 BEGIN

      IF(p_vendor_site_id is NULL) then
         return 'NA_EDW';
      END IF;

      IF (p_instance_code is NOT NULL) then
        l_instance := p_instance_code;
      ELSE
        select instance_code into l_instance
          from edw_local_instance;
      END IF;

      l_tp := p_vendor_site_id || '-' || p_org_id
                               || '-' || l_instance
                               || '-' || 'SUPPLIER_SITE';

      return l_tp;

  EXCEPTION
        when others then

        return 'NA_EDW';

 END supplier_site_fk;


 Function supplier_fk(p_vendor_id      in NUMBER,
                      p_instance_code  in VARCHAR2 := NULL) return VARCHAR2 IS
  l_tp VARCHAR2(120) := 'NA_EDW';
  l_instance VARCHAR2(30) := NULL;

 BEGIN

      IF(p_vendor_id is NULL) then
         return 'NA_EDW';
      END IF;

      IF (p_instance_code is NOT NULL) then
        l_instance := p_instance_code;
      ELSE
        select instance_code into l_instance
          from edw_local_instance;
      END IF;

      l_tp := p_vendor_id || '-' || l_instance
                          || '-' || 'SUPPLIER' || '-' || 'TPRT';

      return l_tp;

 EXCEPTION when others then

	return 'NA_EDW';

 END supplier_fk;


 Function customer_fk (p_cust_account_id in NUMBER,
                       p_instance_code   in VARCHAR2 := NULL) return VARCHAR2 IS
  l_tp VARCHAR2(120) := 'NA_EDW';
  l_instance VARCHAR2(30) := NULL;

 BEGIN

      IF(p_cust_account_id is NULL) then
         return 'NA_EDW';
      END IF;

      IF (p_instance_code is NOT NULL) then
        l_instance := p_instance_code;
      ELSE
        select instance_code into l_instance
          from edw_local_instance;
      END IF;

      l_tp := p_cust_account_id || '-' || l_instance
                                || '-' || 'CUST_ACCT' || '-' || 'TPRT';

      return l_tp;

 EXCEPTION when others then

	return 'NA_EDW';

 END customer_fk;


 Function customer_site_fk (p_site_use_id     in NUMBER,
                            p_instance_code   in VARCHAR2 := NULL) return VARCHAR2 IS
  l_tp VARCHAR2(120) := 'NA_EDW';
  l_instance VARCHAR2(30) := NULL;

 BEGIN

      IF(p_site_use_id is NULL) then
         return 'NA_EDW';
      END IF;

      IF (p_instance_code is NOT NULL) then
        l_instance := p_instance_code;
      ELSE
        select instance_code into l_instance
          from edw_local_instance;
      END IF;

      l_tp := p_site_use_id || '-' || l_instance || '-' || 'CUST_SITE_USE';

      return l_tp;

 EXCEPTION when others then

	return 'NA_EDW';
 END customer_site_fk;


 Function party_fk (p_party_id	in NUMBER,
                    p_instance_code   in VARCHAR2 := NULL) return VARCHAR2 IS
  l_tp VARCHAR2(120) := 'NA_EDW';
  l_instance VARCHAR2(30) := NULL;

 BEGIN

      IF(p_party_id is NULL) then
         return 'NA_EDW';
      END IF;

      IF (p_instance_code is NOT NULL) then
        l_instance := p_instance_code;
      ELSE
        select instance_code into l_instance
          from edw_local_instance;
      END IF;

      l_tp := p_party_id || '-' || l_instance || '-' || 'PARTY' || '-' || 'TPRT';

      return l_tp;

 EXCEPTION when others then

	return 'NA_EDW';
 END party_fk;

End EDW_TRD_PARTNER_PKG;

/
