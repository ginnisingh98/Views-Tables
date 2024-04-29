--------------------------------------------------------
--  DDL for Package Body ARP_CUST_ALT_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CUST_ALT_MATCH_PKG" as
/* $Header: ARCUANMB.pls 115.5 2003/10/10 14:23:46 mraymond ship $ */

--
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE delete_match( p_customer_id in number,
	                p_site_use_id in number,
                        p_alt_name in varchar2
                       ) IS
BEGIN

 IF p_alt_name is NOT NULL then
   IF p_site_use_id is null then
      DELETE ar_customer_alt_names
      WHERE  customer_id = p_customer_id
      and alt_name = p_alt_name;

   ELSE
      DELETE ar_customer_alt_names
      WHERE  customer_id = p_customer_id
      AND    site_use_id = p_site_use_id
      AND    alt_name = p_alt_name;
   END IF;
 ELSE
   IF p_site_use_id is null then
      DELETE ar_customer_alt_names
      WHERE  customer_id = p_customer_id;
   ELSE
      DELETE ar_customer_alt_names
      WHERE  customer_id = p_customer_id
      AND    site_use_id = p_site_use_id;
   END IF;
 END IF;
EXCEPTION
   WHEN OTHERS THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('EXCEPTION: arp_cust_alt_match_pkg.delete_match');
	END IF;
	RAISE;
END delete_match;
--
--
PROCEDURE insert_match( p_alt_name in VARCHAR2,
                        p_customer_id in NUMBER,
                        p_site_use_id in NUMBER,
                        p_term_id in NUMBER
                       ) IS

l_alt_name_id   NUMBER;
l_dummy         NUMBER;
l_user_id       NUMBER;

CURSOR c1 IS
    SELECT 1
    FROM   ar_customer_alt_names
    WHERE  customer_id = p_customer_id
    AND    alt_name = p_alt_name
    AND    decode(site_use_id,'',-1,site_use_id) = decode(p_site_use_id,'',-1,p_site_use_id);

BEGIN

    l_user_id  := fnd_global.user_id;

    open c1;
    fetch c1 into l_dummy;

    IF not c1%FOUND THEN

    SELECT ar_customer_alt_names_s.nextval
    INTO   l_alt_name_id
    FROM   dual;

    INSERT INTO ar_customer_alt_names (
                          alt_name_id,
                          alt_name,
                          customer_id,
                          site_use_id,
                          term_id,
                          created_by,
                          creation_date,
                          last_update_date,
                          last_update_login,
                          last_updated_by
                        ) values (
                          l_alt_name_id,
                          p_alt_name,
                          p_customer_id,
                          p_site_use_id,
                          p_term_id,
                          l_user_id,
                          sysdate,
                          sysdate,
                          l_user_id,
                          l_user_id );
    END IF;

    close c1;

EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: arp_cust_alt_match_pkg.insert_match');
        END IF;
        RAISE;

END insert_match;
--
--
PROCEDURE update_pay_term_id( p_customer_id in number,
			      p_site_use_id in number,
			      p_term_id in number
		   	     ) IS
l_alt_name_id    NUMBER;
l_user_id        NUMBER;

CURSOR c1 IS
    SELECT alt_name_id
    FROM   ar_customer_alt_names
    WHERE  customer_id = p_customer_id
    AND    decode(site_use_id,'',-1,site_use_id) = decode(p_site_use_id,'',-1,p_site_use_id)
    FOR UPDATE;

BEGIN

    l_user_id  := fnd_global.user_id;

    open c1;
    fetch c1 into l_alt_name_id;

    IF c1%FOUND THEN

      UPDATE ar_customer_alt_names
      SET   term_id = p_term_id,
            last_update_date = sysdate,
            last_update_login = l_user_id,
            last_updated_by = l_user_id
      WHERE alt_name_id = l_alt_name_id;

    END IF;
    close c1;

EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('update_pay_term_id: ' || 'EXCEPTION: arp_cust_alt_match_pkg.update_pay_term');
        END IF;

END update_pay_term_id;
--
PROCEDURE lock_match( p_customer_id in number,
                      p_site_use_id in number,
                      p_status out NOCOPY number
                       ) IS
BEGIN

   p_status := 0;

   IF p_site_use_id is null then
      SELECT 1
      INTO p_status
      FROM ar_customer_alt_names
      WHERE customer_id = p_customer_id
      FOR UPDATE OF alt_name_id NOWAIT;

   ELSE
      SELECT 1
      INTO p_status
      FROM ar_customer_alt_names
      WHERE customer_id = p_customer_id
      AND site_use_id = p_site_use_id
      FOR UPDATE OF alt_name_id NOWAIT;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: arp_cust_alt_match_pkg.lock_match');
        END IF;
END lock_match;
--
--

END arp_cust_alt_match_pkg;

/
