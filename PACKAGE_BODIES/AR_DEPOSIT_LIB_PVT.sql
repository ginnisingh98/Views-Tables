--------------------------------------------------------
--  DDL for Package Body AR_DEPOSIT_LIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_DEPOSIT_LIB_PVT" AS
/* $Header: ARXDEPLB.pls 120.12.12010000.3 2010/03/10 10:09:17 npanchak ship $ */
/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/

G_PKG_NAME   CONSTANT VARCHAR2(30)      := 'AR_DEPOSIT_LIB_PVT';

G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;



/*=======================================================================+
 |  FUNCTION get_salesrep_name_id will find the id  of
 |  salesrep  from salesrep name or validate it
 +=======================================================================*/
FUNCTION get_salesrep_name_id(p_default_salesrep_id in number,
                              p_deposit_date in Date) RETURN NUMBER IS
  l_default_srep_name       VARCHAR2(30);
  l_default_srep_number     VARCHAR2(30);
  l_return number := 1;

BEGIN
 arp_util.debug('ar_deposit_lib_pvt.get_salesrep_name_id() +' );
      SELECT name,
      salesrep_number
      INTO l_default_srep_name,
           l_default_srep_number
      FROM RA_SALESREPS
      WHERE SALESREP_ID = p_default_salesrep_id
      AND NVL(status,'A') ='A'
      AND p_deposit_date between nvl(start_date_active, p_deposit_date) and
                                 nvl(end_date_active, p_deposit_date);

      return(p_default_salesrep_id);
 arp_util.debug('ar_deposit_lib_pvt.get_salesrep_name_id() -' );
EXCEPTION
         WHEN NO_DATA_FOUND THEN

                l_return:= -1;
                arp_util.debug('EXCEPTION :ar_deposit_lib_pvt.
                                get_salesrep_name_id(NO_DATA_FOUND)' );
                return(l_return);
         WHEN OTHERS THEN
                l_return:= -1;
                arp_util.debug('EXCEPTION :
                             ar_deposit_lib_pvt.get_salesrep_name_id(OTHERS)' );
                return(l_return);

END;


/*=======================================================================+
 |  PROCEDURE default_bill_to_contact will find the default bill to contact
 | for bill to customer
 +=======================================================================*/

PROCEDURE default_bill_to_contact(p_contact_id        OUT NOCOPY NUMBER,
                                  p_bill_to_customer_id IN NUMBER,
                                  p_bill_to_site_use_id IN NUMBER)
                                  IS
l_dft_contact_id  NUMBER;
l_contact_id      NUMBER;
l_found           boolean;
l_more_than_one   boolean;

cursor c_customer_contact is
select distinct acct_role.cust_account_role_id contact_id
from hz_cust_account_roles acct_role,
     hz_parties party,
     hz_relationships rel,
     hz_org_contacts  org_cont,
     hz_parties       rel_party
where acct_role.party_id = rel.party_id
  and acct_role.role_type = 'CONTACT'
  and org_cont.party_relationship_id = rel.relationship_id
  and rel.subject_id = party.party_id
  and rel.party_id = rel_party.party_id
  and rel.subject_table_name = 'HZ_PARTIES'
  and rel.object_table_name = 'HZ_PARTIES'
  and rel.directional_flag = 'F'
  and acct_role.cust_account_id = p_bill_to_customer_id
  and acct_role.cust_acct_site_id is null
 /* the contact must be active. however, for credit memos
    against specific transactions, the credited transaction's
    contact may also be used even if it is not active. */
AND    ( acct_role.cust_account_role_id =  NULL
          OR  ( acct_role.status = 'A'))
ORDER BY 1;

cursor c_address_contact is
select distinct acct_role.cust_account_role_id contact_id
from hz_cust_account_roles acct_role,
     hz_parties party,
     hz_relationships rel,
     hz_org_contacts  org_cont,
     hz_parties       rel_party,
     hz_cust_acct_sites acct_site,
     hz_cust_site_uses site_uses
where acct_role.party_id = rel.party_id
  and acct_role.role_type = 'CONTACT'
  and org_cont.party_relationship_id = rel.relationship_id
  and rel.subject_id = party.party_id
  and rel.party_id = rel_party.party_id
  and rel.subject_table_name = 'HZ_PARTIES'
  and rel.object_table_name = 'HZ_PARTIES'
  and rel.directional_flag = 'F'
  and acct_role.cust_account_id = p_bill_to_customer_id
  and site_uses.site_use_id     = p_bill_to_site_use_id
  and acct_site.cust_account_id = acct_role.cust_account_id
                    /* show customer level as well as address level contacts */
  and  acct_role.cust_acct_site_id = site_uses.cust_acct_site_id
  and  acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
  and site_uses.site_use_code = 'BILL_TO'

 /* the contact must be active. however, for credit memos
    against specific transactions, the credited transaction's
    contact may also be used even if it is not active. */
AND    ( acct_role.cust_account_role_id =  NULL
         OR  ( acct_role.status = 'A') )
ORDER BY 1;


BEGIN
 arp_util.debug('ar_deposit_lib_pvt.default_bill_to_contact() +' );
/*
1) If the customer defines one contact at customer level and the contact
   is active and not define a contact at address level, the contact at
   customer level will default.
2) If the customer defines one contact at address level, the contact is
   active and the address level Primary check box in Business Purposes tab
   is checked and not define a contact at customer level, the contact at
    address level will default.
3) If the customer define one contact at both customer and address level
   and:
    3.1) Contact is active just at customer level: contact at customer
         level will default.
    3.2) Contact is active just at address level and the address level
         Primary check box in Business Purposes tab is checked:
         contact at address level will default.
    3.3) Both contacts are active and the address level Primary check
         box in Business Purposes tab is checked: contact at address
         level will default.
4) If the customer defines more than one contact at address level and
   just one contact at customer level, and the contact at customer level
    is active,  the contact at customer level will default.
5) If the customer defines more than one contact at customer level and
   just one contact at address level, and the contact at addrees level
   is active, and the address level Primary check  box in Business
   Purposes tab is checked the contact at address level will default.
6) If the customer defines more than one contact at customer level
   and more than one contact at address level, all of them are actives
   and the address level Primary check box in Business Purposes tab
   is checked, none contact will default and the customer must
   choose the contact from the LOV.
*/

IF p_bill_to_site_use_id is not null
   THEN
        OPEN c_address_contact;
        FETCH c_address_contact INTO l_contact_id;
        l_found := c_address_contact%FOUND;
        IF l_found then
            fetch c_address_contact into l_contact_id;
                  l_more_than_one := c_address_contact%FOUND;
        END IF;
        CLOSE c_address_contact;

        IF l_found and not l_more_than_one THEN

           l_dft_contact_id  :=   l_contact_id;

        ELSE
           OPEN c_customer_contact;
           FETCH c_customer_contact into l_contact_id;
           l_found := c_customer_contact%FOUND;
           IF l_found then
              fetch c_customer_contact into  l_contact_id;
              l_more_than_one := c_customer_contact%FOUND;
           END IF;
           CLOSE c_customer_contact;
           IF l_found and not l_more_than_one THEN
              l_dft_contact_id  :=   l_contact_id;
           ELSE
               l_dft_contact_id  :=   null;
           END IF;
        END IF;

ELSE
     OPEN c_customer_contact;
     FETCH c_customer_contact into l_contact_id;
     l_found := c_customer_contact%FOUND;
     IF l_found then
        fetch c_customer_contact into l_contact_id;
        l_more_than_one := c_customer_contact%FOUND;
     END IF;
     CLOSE c_customer_contact;
     IF l_found and not l_more_than_one THEN
        l_dft_contact_id  :=   l_contact_id;
     ELSE
        l_dft_contact_id  :=   null;
     END IF;
END IF;
p_contact_id :=l_dft_contact_id;

arp_util.debug('ar_deposit_lib_pvt.default_bill_to_contact() -' );
END;
/*=======================================================================+
 |  PROCEDURE get_salesrep_defaults will find the defaulted salesrep
 +=======================================================================*/


PROCEDURE get_salesrep_defaults( p_salesrep_id         OUT NOCOPY NUMBER,
                                 p_bill_to_customer_id IN NUMBER,
                                 p_bill_to_site_use_id IN NUMBER,
                                 p_ship_to_customer_id IN NUMBER,
                                 p_ship_to_site_use_id IN NUMBER,
                                 p_deposit_date  Date) IS

 l_default_srep_id_1      NUMBER;
 l_default_srep_id_2      NUMBER;
 l_default_srep_id_3      NUMBER;
 l_default_srep_id_4      NUMBER;
 l_return                 NUMBER := 1;
 l_default_srep_name      VARCHAR2(30);
 l_default_srep_num       INTEGER;
 l_org_id                 NUMBER;
 l_salesreprequiredflag   VARCHAR2(1);

BEGIN

arp_util.debug('ar_deposit_lib_pvt.get_salesrep_defaults() +' );

p_salesrep_id :=null;
   begin
     SELECT SALESREP_REQUIRED_FLAG,ORG_ID
     into l_salesreprequiredflag,l_org_id
     FROM  AR_SYSTEM_PARAMETERS;

   exception
    when no_data_found then
     arp_util.debug(' profile not defined()- ');
    when others then
     arp_util.debug(' profile others : exception ');
  end;
/* **********************************************************************
Procedure:
        Salesrep Information defaulting.
Description:
        This block is executed after bill to location and ship to location
        are defaulted after selecting the customer.

************************************************************************ */
                  /*-----------------------------------------------------+
                   |  Default the Primary Salesrep : Hierarchy           |
                   |                                                     |
                   |    -- From the Bill to Site Value                   |
                   |    -- From the Ship to Site Value                   |
                   |    -- From Customer defaults (if Not Multi-Org)     |
                   |    -- To 'No Sales Credits' if Required_Flag='Y'    |
                   |_____________________________________________________*/

  /* Bill to */

        begin
        select  su.primary_salesrep_id
        into    l_default_srep_id_1
        from    hz_cust_acct_sites acct_site,
                hz_party_sites party_site,
                hz_locations loc,
                hz_cust_site_uses su,
                fnd_territories_vl t
        where   acct_site.cust_acct_site_id = su.cust_acct_site_id
        and     acct_site.party_site_id = party_site.party_site_id
        and     loc.location_id = party_site.location_id
        and     loc.country = t.territory_code
        and     acct_site.cust_account_id = p_bill_to_customer_id
        and     su.site_use_id = nvl(p_bill_to_site_use_id, su.site_use_id)
        and     su.site_use_code = 'BILL_TO'
        and     ( su.site_use_id = null
                  or ( su.status = 'A'
                       and acct_site.status = 'A'
                     )
                )
        and su.primary_flag = 'Y';
         l_return := get_salesrep_name_id(l_default_srep_id_1,p_deposit_date);

         IF (l_return <> -1 ) THEN
            p_salesrep_id :=l_default_srep_id_1;
         END IF;
          arp_util.debug('l_default_srep_id_1 '||to_char(l_default_srep_id_1));
          return;
      exception
         when no_data_found then
               arp_util.debug('no data : l_default_srep_id_1 ');
             l_default_srep_id_1:=null;
         when others then
              arp_util.debug('others : l_default_srep_id_1 ');
             l_default_srep_id_1:=null;

     end;

    IF l_default_srep_id_1 is null THEN
     begin
        select  asa.primary_salesrep_id
       /* selecting salesrep_id for Rel 11 */
        into    l_default_srep_id_2
        from
        (
          SELECT
            A.CUST_ACCOUNT_ID CUSTOMER_ID ,
            A.STATUS A_STATUS ,
            SU.PRIMARY_FLAG PRIMARY_FLAG ,
            SU.STATUS SU_STATUS ,
            SU.SITE_USE_ID SITE_USE_ID ,
            SU.PRIMARY_SALESREP_ID
          FROM
            HZ_CUST_ACCT_SITES A,
            HZ_CUST_SITE_USES SU
          WHERE
            A.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
            AND SU.SITE_USE_CODE = 'SHIP_TO'
        ) asa
        where   asa.customer_id = p_ship_to_customer_id
        and     ( asa.site_use_id = p_ship_to_site_use_id
                  or ( asa.su_status = 'A'
                       and asa.a_status = 'A'
                     )
                )
        and asa.primary_flag='Y';


       l_return := get_salesrep_name_id(l_default_srep_id_2,p_deposit_date);

         IF (l_return <> -1 ) THEN
            p_salesrep_id :=l_default_srep_id_2;
         END IF;

         arp_util.debug('l_default_srep_id_2 '||to_char(l_default_srep_id_2));
         return;

      exception
         when no_data_found then
             l_default_srep_id_2:=null;

      end;
     END IF;

    IF l_default_srep_id_2 is null THEN

           /* Customer Level - IF no Multi Org */
           IF l_org_id is  NULL
           THEN
               l_default_srep_id_3 := -3;

                 l_return :=
                    get_salesrep_name_id(l_default_srep_id_3,p_deposit_date);

               IF (l_return = -1 )
               THEN

                   /* To 'No Sales Credits' if Required_Flag='Y' */
                  --  ar_system_parameters.salesrep_required_flag%type;
                    IF ( l_salesreprequiredflag ='Y')
                    THEN
                       l_default_srep_id_3 := -3;

                    ELSE
                       l_default_srep_id_3 :=null;
                    END IF; /* To 'No Sales Credits' if Required_Flag='Y' */

               END IF;

           ELSE
        /* Customer Level (Not Req.- IF  Multi Org  - go to Required Flag */
                    IF ( l_salesreprequiredflag ='Y')
                    THEN
                       l_default_srep_id_3 := -3;

                    ELSE
                       l_default_srep_id_3 :=null;
                    END IF; /* To 'No Sales Credits' if Required_Flag='Y' */
           END IF;
         p_salesrep_id :=l_default_srep_id_3;
         return;
END IF;


arp_util.debug('ar_deposit_lib_pvt.get_salesrep_defaults() - ' );
END get_salesrep_defaults;

/*=======================================================================+
 |  Default_commitment_Date  will find the default commitment date
 +=======================================================================*/
PROCEDURE Default_commitment_Date(p_deposit_date IN DATE,
                                   p_start_date_commitment   IN OUT NOCOPY DATE,
                                   p_end_date_commitment     IN OUT NOCOPY DATE,
                                   p_return_status  OUT NOCOPY VARCHAR2) IS
BEGIN
arp_util.debug('ar_deposit_lib_pvt.Default_commitment_Date() +' );
   p_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_start_date_commitment IS NULL THEN
      p_start_date_commitment:=p_deposit_date;
   END IF;


     IF p_start_date_commitment >  nvl(p_end_date_commitment,
                                       p_start_date_commitment) THEN
       FND_MESSAGE.set_name( 'AR', 'AR_TW_BAD_COMMITMT_DATE_RANGE' );
       FND_MESSAGE.set_token( 'START_DATE', TO_CHAR(p_start_date_commitment));
       FND_MESSAGE.set_token( 'END_DATE', TO_CHAR(p_end_date_commitment));
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     IF p_end_date_commitment is not null and
        p_deposit_date > p_end_date_commitment THEN

       FND_MESSAGE.set_name( 'AR', 'AR_TW_COMMIT_END_TRX_DATE' );
       FND_MESSAGE.set_token( 'TRX_DATE', TO_CHAR(p_deposit_date));
       FND_MESSAGE.set_token( 'END_DATE', TO_CHAR(p_end_date_commitment));
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;

     END IF;

    /* IF (p_deposit_date < p_start_date_commitment or
         p_deposit_date > nvl(p_end_date_commitment,
                              p_start_date_commitment)) THEN
       FND_MESSAGE.set_name( 'AR', 'AR_TW_BAD_DATE_COMMITMENT' );
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;*/

arp_util.debug('ar_deposit_lib_pvt.Default_commitment_Date() -' );
END Default_commitment_Date;

/*=======================================================================+
 | FUNCTION Get_Territory_id will find the default Territory_id
 +=======================================================================*/

FUNCTION Get_Territory_id(p_bill_to_customer_id    IN NUMBER,
                          p_bill_to_location       IN VARCHAR2,
                          p_ship_to_customer_id    IN NUMBER,
                          p_ship_to_location       IN VARCHAR2,
                          p_salesrep_id            IN NUMBER,
                          p_deposit_date           IN Date ,
                          p_return_status          OUT NOCOPY VARCHAR2
                         ) RETURN NUMBER IS
l_territory_default VARCHAR2(50);
l_territory_id      NUMBER;
cursor c_salesrep_territory IS
   SELECT st.territory_id territory_id
   FROM   ra_salesrep_territories st
   WHERE  st.salesrep_id = p_salesrep_id
   AND    'A'            = NVL(st.status(+), 'A')
   AND    p_deposit_date  BETWEEN NVL(st.start_date_active(+), p_deposit_date  )
                              AND NVL(st.end_date_active(+), p_deposit_date  );
BEGIN

 arp_util.debug('ar_deposit_lib_pvt.Get_Territory_id() +' );
   p_return_status := FND_API.G_RET_STS_SUCCESS;
  begin
    select DEFAULT_TERRITORY
    into l_territory_default
    from ar_system_parameters;
  exception
     when no_data_found then
         arp_util.debug('System option not defined for the org');
     when others then
             arp_util.debug('EXCEPTIONS: Others system option selection');
  end;

    IF    ( l_territory_default = 'BILL' )  THEN
       declare
         l_Site_Use_Id number := Get_Site_Use_Id(p_bill_to_customer_id,
                                             p_bill_to_location,
                                             'BILL_TO',NULL,p_return_status);
       begin
         select territory_id
         into l_territory_id
         from hz_cust_site_uses_all
         where site_use_id = l_Site_Use_Id ;

         exception
          when no_data_found then
              l_territory_id := null;
          when others then
             arp_util.debug('EXCEPTIONS: Others in territory_id  TO SITE,');
         end;

    ELSIF ( l_territory_default = 'SHIP' )   THEN
        declare
         l_Site_Use_Id number := Get_Site_Use_Id(p_ship_to_customer_id,
                                             p_ship_to_location,
                                             'SHIP_TO',NULL,p_return_status);
        begin
         select territory_id
         into l_territory_id
         from hz_cust_site_uses_all
         where site_use_id =l_Site_Use_Id ;

         exception
          when no_data_found then
              l_territory_id := null;
          when others then
             arp_util.debug('EXCEPTIONS: Others in territory_id  TO SITE,');
         end;

    ELSIF ( l_territory_default = 'SALES' )  THEN

        IF (l_territory_id IS NULL)  THEN

             OPEN c_salesrep_territory;
             LOOP
             FETCH c_salesrep_territory into l_territory_id;
             EXIT when c_salesrep_territory%NOTFOUND;
             END LOOP;
            IF  (c_salesrep_territory%ROWCOUNT > 1)  THEN
               l_territory_id :=null;
            ELSE
               arp_util.debug('Copied Territory_id from Salesperson') ;

            END IF;
            close c_salesrep_territory;

        END IF;


     END IF;
    RETURN(l_territory_id);
    arp_util.debug('ar_deposit_lib_pvt.Get_Territory_id() -' );
END;

/*=======================================================================+
 | FUNCTION Get_Ship_Via will get Ship_Via
 +=======================================================================*/

FUNCTION Get_Ship_Via( p_bill_to_customer_id     IN  NUMBER,
                        p_bill_to_location       IN  VARCHAR2,
                        p_ship_to_customer_id    IN  NUMBER,
                        p_ship_to_location       IN  VARCHAR2,
                        p_return_status          OUT NOCOPY VARCHAR2
                       )
                       RETURN VARCHAR2 IS

l_Ship_Via_ship_default         VARCHAR2(100):=NULL;
l_Ship_Via_bill_default         VARCHAR2(100):=NULL;
l_Ship_Via_ship_site_default    VARCHAR2(100):=NULL;
l_Ship_Via_bill_site_default    VARCHAR2(100):=NULL;

BEGIN
       p_return_status := FND_API.G_RET_STS_SUCCESS;
 arp_util.debug('ar_deposit_lib_pvt.Get_Ship_Via() +' );

       IF   p_ship_to_customer_id IS NOT NULL AND
            p_ship_to_location    IS NOT NULL
       THEN
         declare
         l_Site_Use_Id number := Get_Site_Use_Id(p_ship_to_customer_id,
                                             p_ship_to_location,
                                             'SHIP_TO',NULL, p_return_status);
         begin
         select ship_via
         into l_ship_via_ship_site_default
         from hz_cust_site_uses_all
         where site_use_id =l_Site_Use_Id ;

         exception
          when no_data_found then
              l_ship_via_ship_site_default := null;
          when others then
              l_ship_via_ship_site_default := null;
             arp_util.debug('EXCEPTIONS: Others in
                             SHIP TO SITE,  Get_ship_via_POINT()');
         end;

       END IF;

       IF l_ship_via_ship_site_default IS NULL THEN
        begin
        select ship_via into l_ship_via_ship_default
        from hz_cust_accounts
        where   cust_account_id = p_ship_to_customer_id;
        exception
          when no_data_found then
              l_ship_via_ship_default := null;
          when others then
             l_ship_via_ship_default := null;
             arp_util.debug('EXCEPTIONS: Others in
                             SHIP TO Get_ship_via_POINT()');
         end;
       ELSE
         RETURN(l_ship_via_ship_site_default);
       END IF;

       IF l_ship_via_ship_default IS NULL THEN
         IF   p_bill_to_customer_id IS NOT NULL AND
              p_bill_to_location    IS NOT NULL
         THEN
          declare
          l_Site_Use_Id number := Get_Site_Use_Id(p_bill_to_customer_id,
                                               p_bill_to_location,
                                               'BILL_TO',NULL,p_return_status);
          begin
           select ship_via
           into l_ship_via_bill_site_default
           from hz_cust_site_uses
           where site_use_id = l_Site_Use_Id;

          exception
            when no_data_found then
              l_ship_via_bill_site_default := null;
            when others then
              l_ship_via_bill_site_default := null;
              arp_util.debug('EXCEPTIONS: Others in
			      BILL_TO site,  Get_ship_via_POINT()');
          end;

        END IF;

        IF l_ship_via_bill_site_default IS NULL THEN
          begin
           select ship_via
           into l_ship_via_bill_default
           from hz_cust_accounts
           where   cust_account_id = p_bill_to_customer_id;

            RETURN(l_ship_via_bill_default);
          exception
            when no_data_found then
                 l_ship_via_bill_default := null;
            when others then
                l_ship_via_bill_default := null;
               arp_util.debug('EXCEPTIONS: Others in
			       BILL_TO , Get_ship_via_POINT()');
           end;
         ELSE
           RETURN(l_ship_via_bill_site_default);
         END IF;
       ELSE
       RETURN(l_ship_via_ship_default);
       END IF;
       --if nothing is retreived
      RETURN(l_ship_via_bill_default);

 arp_util.debug('ar_deposit_lib_pvt.Get_Ship_Via() -' );

END Get_Ship_Via;

/*=======================================================================+
 | FUNCTION Get_FOB_POINT will get FOB_POINT
 +=======================================================================*/

FUNCTION Get_FOB_POINT( p_bill_to_customer_id    IN NUMBER,
                        p_bill_to_location       IN VARCHAR2,
                        p_ship_to_customer_id    IN NUMBER,
                        p_ship_to_location       IN VARCHAR2,
                        p_return_status          OUT NOCOPY VARCHAR2
                       )
                       RETURN VARCHAR2 IS

l_fob_ship_default         VARCHAR2(100):=NULL;
l_fob_bill_default         VARCHAR2(100):=NULL;
l_fob_ship_site_default    VARCHAR2(100):=NULL;
l_fob_bill_site_default    VARCHAR2(100):=NULL;

BEGIN

    arp_util.debug('ar_deposit_lib_pvt.Get_FOB_POINT() +' );
      p_return_status := FND_API.G_RET_STS_SUCCESS;

       IF   p_ship_to_customer_id IS NOT NULL AND
            p_ship_to_location    IS NOT NULL
       THEN
        arp_util.debug('p_ship_to_customer_id IS NOT NULL
                       AND p_ship_to_location    IS NOT NULL');
         declare
          l_Site_Use_Id number := Get_Site_Use_Id(p_ship_to_customer_id,
                                             p_ship_to_location,
                                             'SHIP_TO',NULL,p_return_status);
         begin
         select fob_point
         into l_fob_ship_site_default
         from hz_cust_site_uses
         where site_use_id =l_Site_Use_Id ;

         exception
          when no_data_found then
              arp_util.debug('no_data');
              l_fob_ship_site_default := null;
          when others then
              l_fob_ship_site_default := null;
              arp_util.debug('EXCEPTIONS: Others in
                              SHIP TO SITE,  Get_FOB_POINT()');
         end;

       END IF;

       IF l_fob_ship_site_default IS NULL THEN
        begin
        select fob_point into l_fob_ship_default
        from hz_cust_accounts
        where   cust_account_id = p_ship_to_customer_id;
        exception
          when no_data_found then
              l_fob_ship_default := null;
          when others then
             l_fob_ship_default := null;
             arp_util.debug('EXCEPTIONS: Others in SHIP TO Get_FOB_POINT()');
         end;
       ELSE
         RETURN(l_fob_ship_site_default);
       END IF;

       IF l_fob_ship_default IS NULL THEN
         IF   p_bill_to_customer_id IS NOT NULL AND
              p_bill_to_location    IS NOT NULL
         THEN
         declare
          l_Site_Use_Id number := Get_Site_Use_Id(p_ship_to_customer_id,
                                             p_ship_to_location,
                                             'SHIP_TO',NULL,p_return_status);
          begin
           select fob_point
           into l_fob_bill_site_default
           from hz_cust_site_uses
           where site_use_id = l_Site_Use_Id;

          exception
            when no_data_found then
              l_fob_bill_site_default := null;
            when others then
              l_fob_bill_site_default := null;
              arp_util.debug('EXCEPTIONS: Others in
                              BILL_TO site,  Get_FOB_POINT()');
          end;

        END IF;

        IF l_fob_bill_site_default IS NULL THEN
          begin
           select fob_point
           into l_fob_bill_default
           from hz_cust_accounts
           where   cust_account_id = p_bill_to_customer_id;

            RETURN(l_fob_bill_default);
          exception
            when no_data_found then
                 l_fob_bill_default := null;
            when others then
                 l_fob_bill_default := null;
               arp_util.debug('EXCEPTIONS: Others in
                               BILL_TO , Get_FOB_POINT()');
           end;
         ELSE
           RETURN(l_fob_bill_site_default);
         END IF;
       ELSE
        RETURN(l_fob_ship_default);
       END IF;
     --if nothing is in then
      RETURN(l_fob_bill_default);


    arp_util.debug('ar_deposit_lib_pvt.Get_FOB_POINT() -' );

END Get_FOB_POINT;

/*=======================================================================+
 | FUNCTION GET_CONTACT_ID will get CONTACT_ID
 +=======================================================================*/

  FUNCTION GET_CONTACT_ID( p_customer_id         IN NUMBER,
                           p_person_first_name   IN VARCHAR2,
                           p_person_last_name    IN VARCHAR2,
                           p_return_status       OUT NOCOPY VARCHAR2
                           )
                           RETURN VARCHAR2 IS
  l_selected_id NUMBER;
  BEGIN
      arp_util.debug('ar_deposit_lib_pvt.GET_CONTACT_ID() +' );
                begin
                    SELECT acct_role.cust_account_role_id
                    INTO l_selected_id
                    from hz_cust_account_roles acct_role,
                         hz_parties party,
                         hz_relationships rel,
                         hz_org_contacts  org_cont,
                         hz_parties       rel_party
                    where acct_role.party_id = rel.party_id
                         and acct_role.role_type = 'CONTACT'
                         and org_cont.party_relationship_id =
                                             rel.relationship_id
                         and rel.subject_id = party.party_id
                         and rel.party_id = rel_party.party_id
                         and rel.subject_table_name = 'HZ_PARTIES'
                         and rel.object_table_name = 'HZ_PARTIES'
                         and rel.directional_flag = 'F'
                         and acct_role.cust_account_id = p_customer_id
            /* the contact must be active. however, for credit memos
               against specific transactions, the credited transaction's
               contact may also be used even if it is not active. */
                         AND acct_role.status = 'A'
                         AND party.person_last_name  =  p_person_last_name
                         AND party.person_first_name = p_person_first_name;

           exception
            when no_data_found then
                 l_selected_id := null;
                 arp_util.debug('EXCEPTIONS:no data found , GET_CONTACT_ID()');
               --that the customer site use id could not be defaulted.
                  p_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('AR','AR_DAPI_CUS_CONTACT_INVALID');
                  FND_MSG_PUB.Add;

            when others then
                 l_selected_id := null;
                 arp_util.debug('EXCEPTIONS: Others ,  GET_CONTACT_ID()');
          end;

          return(l_selected_id);
 arp_util.debug('ar_deposit_lib_pvt.GET_CONTACT_ID() -' );
END GET_CONTACT_ID;

/*=======================================================================+
 | FUNCTION GET_ID will get GET_ID
 +=======================================================================*/

FUNCTION Get_Id(
                  p_entity    IN VARCHAR2,
                  p_value     IN VARCHAR2,
                  p_return_status OUT NOCOPY VARCHAR2
               ) RETURN VARCHAR2 IS

l_cached_id    VARCHAR2(100);
l_selected_id  VARCHAR2(100);
l_index        BINARY_INTEGER;

BEGIN

      arp_util.debug('Get_Id()+ ');
      l_selected_id := null;

        IF      ( p_entity = 'CUSTOMER_NUMBER' )
                THEN


                    SELECT c.cust_account_id
                    INTO   l_selected_id
                    FROM   hz_cust_accounts c,
                           hz_customer_profiles cp,
                           hz_parties party
                    WHERE  c.cust_account_id = cp.cust_account_id (+) and
                           cp.site_use_id is null and
                           c.account_number = p_value and
                           c.status <> 'I'
                      AND  c.party_id = party.party_id;

                ELSIF   ( p_entity = 'CUSTOMER_NAME' )
                 THEN

                    SELECT cust_acct.cust_account_id
                    INTO   l_selected_id
                    FROM   hz_cust_accounts cust_acct,
                           hz_customer_profiles cp,
                           hz_parties party
                    WHERE  cust_acct.cust_account_id = cp.cust_account_id (+)
                      and  cust_acct.party_id = party.party_id(+)
                      and  cp.site_use_id is null
                      and  cust_acct.status <> 'I'
                      and  party.party_name = p_value;
                 ELSIF   ( p_entity = 'SALESREP_NAME' )
                   THEN

                    SELECT salesrep_id
                    INTO   l_selected_id
                    FROM    ra_salesreps
                    WHERE  name = p_value;

                 ELSIF   ( p_entity = 'BATCH_SOURCE_NAME' )
                   THEN
                      SELECT batch_source_id
                      INTO   l_selected_id
                      FROM   ra_batch_sources
                      WHERE  name      = p_value and
                             nvl(status, 'A') = 'A' and (batch_source_type = 'INV');
                 ELSIF   ( p_entity = 'TERM_NAME' )
                   THEN
                      SELECT term_id
                      INTO   l_selected_id
                      FROM   ra_terms
                      WHERE  name      = p_value;

                 ELSIF  (p_entity = 'RECEIPT_METHOD_NAME' )

                 THEN

                    SELECT receipt_method_id
                    INTO   l_selected_id
                    FROM   ar_receipt_methods
                    WHERE  name = p_value;
/* REMOVED the defaulting of the bank_account_id from CUSTOMER_BANK_ACCOUNT_NUMBER, CUSTOMER_BANK_ACCOUNT_NAME */

/* removed ap_bank_accounts to point to ce_bank_accounts */
                ELSIF  (p_entity = 'REMIT_BANK_ACCOUNT_NUMBER')
                 THEN
                    SELECT bank_account_id
                    INTO   l_selected_id
                    FROM   ce_bank_accounts
                    WHERE  bank_account_num = p_value
                     AND   pg_deposit_date  <  NVL(end_date,
                                               TO_DATE('01/01/2200',
                                                       'DD/MM/YYYY') );

                ELSIF  (p_entity = 'REMIT_BANK_ACCOUNT_NAME')
                  THEN
                    SELECT bank_account_id
                    INTO   l_selected_id
                    FROM   ce_bank_accounts
                    WHERE  bank_account_name = p_value
                     AND   pg_deposit_date  <  NVL(end_date,
                                               TO_DATE('01/01/2200',
                                                       'DD/MM/YYYY') );

                ELSIF   (p_entity = 'CURRENCY_NAME')
                   THEN
                     SELECT currency_code
                     INTO   l_selected_id
                     FROM   fnd_currencies_vl
                     WHERE  name = p_value;

                ELSIF   (p_entity = 'EXCHANGE_RATE_TYPE_NAME')
                   THEN
                      SELECT conversion_type
                      INTO   l_selected_id
                      FROM   gl_daily_conversion_types
                      WHERE  user_conversion_type = p_value ;

                END IF;

               RETURN( l_selected_id );
      arp_util.debug('Get_Id()- ');
EXCEPTION

   WHEN NO_DATA_FOUND THEN
        arp_util.debug('Value not found. Entity: ' ||
                                   p_entity ||'  Value: ' || p_value);
        return(null);
        arp_util.debug('Get_Id()- ');

   WHEN OTHERS THEN
        arp_util.debug('Value not found. Entity: ' ||
                                   p_entity ||'  Value: ' || p_value);
        RAISE;

END Get_Id;

/*=======================================================================+
 | FUNCTION Get_Site_Use_Id will get Site_Use_Id of customer location
 +=======================================================================*/

FUNCTION Get_Site_Use_Id(
     p_customer_id    IN  hz_cust_acct_sites.cust_account_id%TYPE,
     p_location       IN  hz_cust_site_uses.location%TYPE,
     p_site_use_code1 IN  hz_cust_site_uses.site_use_code%TYPE DEFAULT NULL,
     p_site_use_code2 IN  hz_cust_site_uses.site_use_code%TYPE DEFAULT  NULL,
     p_return_status  OUT NOCOPY VARCHAR2)
RETURN hz_cust_site_uses.site_use_id%type IS

l_cached_id    hz_cust_site_uses.site_use_id%type;
l_selected_id  hz_cust_site_uses.site_use_id%type;
l_index        BINARY_INTEGER;
BEGIN

    arp_util.debug('ar_deposit_lib_pvt.Get_Site_Use_Id() +' );
      p_return_status := FND_API.G_RET_STS_SUCCESS;
          IF p_customer_id IS NOT NULL THEN
            IF (p_location IS NOT NULL) THEN
              BEGIN

               SELECT site_use.site_use_id
               INTO   l_selected_id
               FROM   hz_cust_site_uses site_use,
                      hz_cust_acct_sites acct_site
               WHERE  acct_site.cust_account_id   =  p_customer_id
                 AND  acct_site.status        = 'A'
                 AND  site_use.cust_acct_site_id = acct_site.cust_acct_site_id
                 AND  (site_use.site_use_code = nvl(p_site_use_code1,
                                                    site_use.site_use_code) OR
                       site_use.site_use_code = nvl(p_site_use_code1,
                                                    site_use.site_use_code))
                 AND  site_use.status        = 'A'
                 AND  site_use.location = p_location;
              EXCEPTION
               WHEN no_data_found THEN
                  arp_util.debug('No data found in the hz_cust_site_uses
                                  for the location :'||p_location);
                  p_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('AR','AR_DAPI_CUS_LOC_INVALID');
                  FND_MSG_PUB.Add;
          --the error message will be raised in the validation routine.

                END;

            ELSE
          --the case when no location  is specified for the customer.
          --here we are defaulting the primary bill_to loaction.
              BEGIN

               SELECT site_use.site_use_id
               INTO   l_selected_id
               FROM   hz_cust_site_uses site_use,
                      hz_cust_acct_sites acct_site
               WHERE  acct_site.cust_account_id   =  p_customer_id
                 AND  acct_site.status        = 'A'
                 AND  site_use.cust_acct_site_id  = acct_site.cust_acct_site_id
                 AND  (site_use.site_use_code = nvl(p_site_use_code1,
                                                    site_use.site_use_code) OR
                       site_use.site_use_code = nvl(p_site_use_code1,
                                                    site_use.site_use_code))
                 AND  site_use.status        = 'A'
                 AND  site_use.primary_flag  = 'Y';

              EXCEPTION
               WHEN no_data_found THEN
              arp_util.debug('No_data_found : Site use id could
                              not be defaulted for customer_id '
                                 ||to_char(p_customer_id));
                --This is the case where customer site use id is null
                --neither it was supplied by the user nor it could be defaulted
                --a WARNING message raised in the validation routine to indicate
                --that the customer site use id could not be defaulted.
                  p_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('AR','AR_DAPI_CUS_SITE_DFT_INVALID');
                  FND_MSG_PUB.Add;
              END;

           END IF;
        END IF;

 RETURN( l_selected_id );
   arp_util.debug('ar_deposit_lib_pvt.Get_Site_Use_Id() -' );
EXCEPTION
 WHEN others THEN
  arp_util.debug('EXCEPTION: Get_Site_Use_Id.');
  raise;

END Get_Site_Use_Id;


/*=======================================================================+
 | FUNCTION Get_Cross_Validated_Id will validate both name and number
 +=======================================================================*/


FUNCTION Get_Cross_Validated_Id( p_entity        IN VARCHAR2,
                                 p_number_value  IN VARCHAR2,
                                 p_name_value    IN VARCHAR2,
                                 p_return_status OUT NOCOPY VARCHAR2
                                ) RETURN VARCHAR2 IS
l_id_from_name  VARCHAR2(100);
l_id_from_num   VARCHAR2(100);
BEGIN
  arp_util.debug('ar_deposit_lib_pvt.Get_Cross_Validated_Id() +' );
   IF (p_number_value IS NULL) OR
      (p_name_value IS NULL)
    THEN
    RETURN(NULL);
   END IF;

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   l_id_from_name := Get_Id(p_entity||'_NAME',
                            p_name_value,
                            p_return_status
                           );

   l_id_from_num  := Get_Id(p_entity||'_NUMBER',
                            p_number_value,
                            p_return_status
                           );

   IF l_id_from_name = l_id_from_num THEN
     RETURN(l_id_from_name);
   ELSE

     RETURN(NULL);
   END IF;
 arp_util.debug('ar_deposit_lib_pvt.Get_Cross_Validated_Id() -' );
EXCEPTION
 WHEN others THEN
  arp_util.debug('EXCEPTION: Get_Cross_Validated_Id() '||p_entity);
  raise;
END Get_Cross_Validated_Id;



/*=======================================================================+
 | Default_gl_date will find the defaulted value of gl date
 +=======================================================================*/

PROCEDURE Default_gl_date(p_entered_date IN  DATE,
                          p_gl_date      OUT NOCOPY DATE,
                          p_return_status OUT NOCOPY VARCHAR2) IS
l_error_message        VARCHAR2(128);
l_defaulting_rule_used VARCHAR2(50);
l_default_gl_date      DATE;
BEGIN
  p_return_status := FND_API.G_RET_STS_SUCCESS;
 arp_util.debug('ar_deposit_lib_pvt.Default_gl_date() +' );
    IF p_gl_date IS NULL THEN
     IF (arp_util.validate_and_default_gl_date(
                p_entered_date,
                NULL,
                NULL,
                NULL,
                NULL,
                p_entered_date,
                NULL,
                NULL,
                'N',
                NULL,
                arp_global.set_of_books_id,
                222,
                l_default_gl_date,
                l_defaulting_rule_used,
                l_error_message) = TRUE)
     THEN
        p_gl_date := l_default_gl_date;
      arp_util.debug('Defaulted GL Date : '||to_char(p_gl_date,'DD-MON-YYYY'));
     ELSE
      arp_util.debug('GL Date could not be defaulted ');
      -- Raise error message if failure in defaulting the gl_date
      FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_error_message);
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;
 arp_util.debug('ar_deposit_lib_pvt.Default_gl_date() -' );
END default_gl_date;


/*=======================================================================+
 | Find_Exchange_Rate will find the exchanage rate
 +=======================================================================*/

FUNCTION Find_Exchange_Rate(
    p_currency_code      IN ra_customer_trx.invoice_currency_code%TYPE,
    p_exchange_rate_date IN ra_customer_trx.exchange_date%TYPE,
    p_exchange_rate_type IN ra_customer_trx.exchange_rate_type%type
                      )
 RETURN NUMBER IS
l_count                BINARY_INTEGER;
l_index_curr           BINARY_INTEGER;
l_exchange_rate        NUMBER;
l_set_of_books_id      NUMBER        := arp_global.set_of_books_id;
l_functional_currency  VARCHAR2(100) := arp_global.functional_currency;
BEGIN
 arp_util.debug('ar_deposit_lib_pvt.Find_Exchange_Rate() +' );
   IF (p_currency_code IS NOT NULL) AND
      (p_currency_code <> l_functional_currency) AND
      (p_exchange_rate_date IS NOT NULL) AND
      (p_exchange_rate_type IS NOT NULL) AND
      (p_exchange_rate_type <>'User')
    THEN
--  This section of code is commented out as the implementation of the
--  of the caching mechanism has been deferred as of now

     l_exchange_rate := gl_currency_api.get_rate(
                                           l_set_of_books_id,
                                           p_currency_code,
                                           p_exchange_rate_date,
                                           p_exchange_rate_type
                                           );

  END IF;
  RETURN( l_exchange_rate );
 arp_util.debug('ar_deposit_lib_pvt.Find_Exchange_Rate() -' );
EXCEPTION
 WHEN gl_currency_api.NO_RATE THEN
  --rate does not exist set appropriate message.
  --p_return_status := FND_API.G_RET_STS_ERROR ;
  return(null);
  arp_util.debug('Exception : gl_currency_api.NO_RATE ');
 WHEN gl_currency_api.INVALID_CURRENCY  THEN
  -- invalid currency set appropriate message.
  --p_return_status := FND_API.G_RET_STS_ERROR ;
  return(null);
  arp_util.debug('Exception: gl_currency_api.INVALID_CURRENCY ');
 WHEN others THEN
  arp_util.debug('EXCEPTION: Find_Exchange_Rate() ');
  raise;
END Find_Exchange_Rate;

/*=======================================================================+
 | Get_cross_rate will cross_rate between currencies
 +=======================================================================*/

FUNCTION Get_cross_rate (p_from_currency      IN VARCHAR2,
                         p_to_currency        IN VARCHAR2,
                         p_exchange_rate_date IN DATE,
                         p_exchange_rate      IN NUMBER
                         ) RETURN NUMBER IS
l_euro_to_emu_rate  NUMBER;
l_fixed_rate        BOOLEAN;
l_relationship      VARCHAR2(50);
euro_code           VARCHAR2(15);
l_cross_rate        NUMBER;
BEGIN
 arp_util.debug('ar_deposit_lib_pvt.Get_cross_rate() +' );
     gl_currency_api.get_relation(
                       p_from_currency,
                       p_to_currency,
                       trunc(p_exchange_rate_date),
                       l_fixed_rate,
                       l_relationship);
      euro_code := gl_currency_api.get_euro_code;

      IF (l_relationship = 'EMU-OTHER') THEN
                   l_euro_to_emu_rate :=
                                gl_currency_api.get_rate(
                                                   euro_code,
                                                   p_from_currency,
                                                   trunc(p_exchange_rate_date),
                                                   NULL);
      ELSIF (l_relationship = 'OTHER-EMU') THEN
                   l_euro_to_emu_rate :=
                                gl_currency_api.get_rate(
                                                   euro_code,
                                                   p_to_currency,
                                                   trunc(p_exchange_rate_date),
                                                   NULL);
      ELSE
          RAISE gl_euro_user_rate_api.INVALID_RELATION;
      END IF;
              l_cross_rate :=
                    gl_euro_user_rate_api.get_cross_rate(p_from_currency,
                                                p_to_currency,
                                                p_exchange_rate_date,
                                                p_exchange_rate,
                                                l_euro_to_emu_rate);
              return(l_cross_rate);
  arp_util.debug('ar_deposit_lib_pvt.Get_cross_rate() -' );
EXCEPTION
  WHEN gl_euro_user_rate_api.INVALID_RELATION  THEN
    null;
  WHEN gl_euro_user_rate_api.INVALID_CURRENCY  THEN
    null;
  WHEN others THEN
    raise;
END Get_cross_rate;

/*=======================================================================+
 | Default_Currency_info will find the default currency info
 +=======================================================================*/

PROCEDURE Default_Currency_info(
  p_currency_code        IN OUT NOCOPY ra_customer_trx.invoice_currency_code%TYPE,
  p_receipt_date         IN OUT NOCOPY ra_customer_trx.exchange_date%TYPE,
  p_exchange_rate_date   IN OUT NOCOPY ra_customer_trx.exchange_date%TYPE,
  p_exchange_rate_type   IN OUT NOCOPY ra_customer_trx.exchange_rate_type%TYPE,
  p_exchange_rate        IN OUT NOCOPY ra_customer_trx.exchange_rate%TYPE,
  p_return_status        OUT NOCOPY    VARCHAR2
  ) IS

l_euro_to_emu_rate      NUMBER;
l_euro_to_other_prompt  VARCHAR2(30);
l_euro_to_emu_prompt    VARCHAR2(30);
l_emu_to_other_prompt   VARCHAR2(30);
l_cross_rate            NUMBER;
l_conversion_rate       NUMBER;
BEGIN
 arp_util.debug('ar_deposit_lib_pvt.Default_Currency_info() +' );
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_currency_code <> arp_global.functional_currency THEN

    --default exchange rate date if null
    IF (p_exchange_rate_date IS NULL) THEN
      p_exchange_rate_date := p_receipt_date;
    END IF;

    --default exchange rate type if null
    IF p_exchange_rate_type IS NULL THEN
       p_exchange_rate_type := pg_profile_def_x_rate_type;
    END IF;

  IF p_exchange_rate_type IS NOT NULL THEN

    IF p_exchange_rate_type <> 'User' THEN
        --for any exchange_rate type other than 'User',
        --default exchange rate if not entered.
         IF p_exchange_rate IS NULL THEN
            p_exchange_rate := Find_Exchange_Rate(
                                               p_currency_code,
                                               p_exchange_rate_date,
                                               p_exchange_rate_type
                                                );
         ELSE
           --if user has entered exchange rate for type <> User,
           -- raise error message
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('AR','AR_RAPI_X_RATE_INVALID');
            FND_MSG_PUB.Add;
         END IF;
    ELSE
     --case where rate_type is 'User'

      --if the user entered exchange rate is greater than 0 then
      --check for the case of EMU currency
   IF p_exchange_rate >0 THEN

     --This is the case rate_type is User and exchange_rate exists

     -- Returns 'Y' if the current conversion type is User AND
     -- they are converting from EMU -> OTHER or OTHER -> EMU AND
     -- they are not allowed to enter EMU -> OTHER and
     -- OTHER -> EMU rates directly
     -- Returns 'N' Otherwise

     IF (gl_euro_user_rate_api.is_cross_rate(p_currency_code,
                                       arp_global.functional_currency,
                                       p_exchange_rate_date,
                                       p_exchange_rate_type) = 'Y')
       THEN

              gl_euro_user_rate_api.get_prompts_and_rate(
                                               p_currency_code,
                                               arp_global.functional_currency,
                                               p_exchange_rate_date,
                                               l_euro_to_other_prompt,
                                               l_euro_to_emu_prompt,
                                               l_emu_to_other_prompt,
                                               l_euro_to_emu_rate);

              l_cross_rate :=
               gl_euro_user_rate_api.get_cross_rate(
                                                  p_currency_code,
                                                  p_currency_code,
                                                  p_exchange_rate_date,
                                                  p_exchange_rate,
                                                  l_euro_to_emu_rate);

        p_exchange_rate :=  l_cross_rate;
     ELSE
      -- case where gl_euro_user_rate_api.is_cross_rate = 'N'
      -- here the exchange_rate is directly between the EMU and the non-EMU currency.

        p_exchange_rate := round(p_exchange_rate,38);

     END IF; --is_cross_rate

   END IF; -- exchange_rate >0

  END IF; --rate type <> 'User'
  END IF; --if echange rate type IS NOT NULL
 END IF;  --entered_currency <> functional currency

 arp_util.debug('ar_deposit_lib_pvt.Default_Currency_info() -' );
EXCEPTION
 WHEN others THEN
  arp_util.debug('EXCEPTION: Default_Currency_Info() ');
  arp_util.debug('p_currency_code  =  '||p_currency_code);
  raise;
END Default_Currency_Info;

/*=======================================================================+
 | Default_deposit_ids will be called by ar_deposit_api_pub to perform some
 | basic validation and find id's based on name /number combination
 +=======================================================================*/

PROCEDURE Default_deposit_ids(
     x_salesrep_id   		    IN OUT NOCOPY  NUMBER,
     p_salesrep_name 		    IN      VARCHAR2  DEFAULT NULL,
     x_term_id     		    IN OUT NOCOPY     NUMBER ,
     p_term_name     		    IN      VARCHAR2  DEFAULT NULL,
     x_batch_source_id              IN OUT NOCOPY  NUMBER,
     p_batch_source_name            IN      ra_batch_sources.name%type,
     x_cust_trx_type_id             IN OUT NOCOPY  NUMBER,
     p_cust_trx_type                IN      varchar2,
     x_bill_to_customer_id          IN OUT NOCOPY  NUMBER,
     x_bill_to_customer_site_use_id IN OUT NOCOPY  hz_cust_site_uses.site_use_id%TYPE,
     p_bill_to_customer_name        IN      hz_parties.party_name%TYPE,
     p_bill_to_customer_number      IN
                        hz_cust_accounts.account_number%TYPE,
     p_bill_to_location             IN OUT NOCOPY  hz_cust_site_uses.location%type,
     x_bill_to_contact_id           IN OUT NOCOPY  NUMBER,
     p_bill_to_contact_first_name   IN      VARCHAR2,
     p_bill_to_contact_last_name    IN      VARCHAR2,
     x_ship_to_customer_id          IN OUT NOCOPY  NUMBER,
     x_ship_to_customer_site_use_id IN OUT NOCOPY  hz_cust_site_uses.site_use_id%TYPE,
     p_ship_to_customer_name        IN      hz_parties.party_name%TYPE,
     p_ship_to_customer_number      IN
                        hz_cust_accounts.account_number%TYPE,
     p_ship_to_location             IN OUT NOCOPY  hz_cust_site_uses.location%type,
     x_ship_to_contact_id           IN OUT NOCOPY  NUMBER,
     p_ship_to_contact_first_name   IN      VARCHAR2,
     p_ship_to_contact_last_name    IN      VARCHAR2,
     p_usr_currency_code            IN      fnd_currencies_vl.name%TYPE,
     p_usr_exchange_rate_type       IN
                       gl_daily_conversion_types.user_conversion_type%TYPE,
     x_currency_code                IN OUT NOCOPY  ar_cash_receipts.currency_code%TYPE,
     x_exchange_rate_type           IN OUT NOCOPY
                       ar_cash_receipts.exchange_rate_type%TYPE,
     x_remit_to_address_id          IN OUT NOCOPY  NUMBER ,
     p_cust_location_site_num       IN      VARCHAR2,
     x_sold_to_customer_id          IN OUT NOCOPY  NUMBER,
     p_sold_to_customer_name        IN      VARCHAR2,
     p_sold_to_customer_number      IN      VARCHAR2,
     x_paying_customer_id           IN OUT NOCOPY  NUMBER ,
     x_paying_customer_site_use_id  IN OUT NOCOPY  hz_cust_site_uses.site_use_id%TYPE,
     p_paying_customer_name         IN      VARCHAR2,
     p_paying_customer_number       IN      VARCHAR2,
     p_paying_location              IN      VARCHAR2,
     x_receipt_method_id            IN OUT NOCOPY  NUMBER ,
     p_receipt_method_name          IN OUT NOCOPY  VARCHAR2,
     x_cust_bank_account_id         IN OUT NOCOPY  NUMBER,
     p_cust_bank_account_name       IN      VARCHAR2,
     p_cust_bank_account_number     IN      VARCHAR2,
     x_memo_line_id                 IN OUT NOCOPY  NUMBER,
     p_memo_line_name               IN      VARCHAR2,
     x_inventory_id                 IN OUT NOCOPY  NUMBER,
     p_deposit_number               IN  VARCHAR2,
     p_deposit_date                 IN  DATE,
     p_return_status                OUT NOCOPY     VARCHAR2
                              ) IS

l_receipt_method_id          NUMBER;
l_cust_bank_account_id       NUMBER;
l_customer_id                NUMBER;
l_get_id_return_status       VARCHAR2(1);
l_get_x_val_return_status    VARCHAR2(1);
l_dummy_return_status        VARCHAR2(1);
l_site_use_return_status     VARCHAR2(1);
l_contact_return_status      VARCHAR2(1);
l_remit_to_address_rec       ARP_TRX_DEFAULTS_3.address_rec_type;
l_dft_remit_to_address_rec   ARP_TRX_DEFAULTS_3.address_rec_type;
l_dft_remit_to_address_id    NUMBER ;
l_remit_to_address_id        NUMBER;
l_match_state                hz_locations.state%type;
l_match_country              hz_locations.country%type;
l_match_postal_code          hz_locations.postal_code%type;
l_match_address_id           NUMBER :=NULL;
l_match_site_use_id          NUMBER :=NULL;
l_pay_unrelated_invoices_flag
                      ar_system_parameters.pay_unrelated_invoices_flag%type;
l_bill_to_location           hz_cust_site_uses.location%type;
l_ship_to_location           hz_cust_site_uses.location%type;
l_dft_bill_to_location       hz_cust_site_uses.location%type;
l_dft_ship_to_location       hz_cust_site_uses.location%type;
l_dummy                      NUMBER;
l_default_site_use	     varchar2(40);

BEGIN
 arp_util.debug('ar_deposit_lib_pvt.Default_deposit_ids() +' );
p_return_status       := FND_API.G_RET_STS_SUCCESS;
pg_deposit_date := p_deposit_date;
l_bill_to_location    := p_bill_to_location;
l_ship_to_location    := p_ship_to_location;
l_default_site_use    := nvl(FND_PROFILE.value('AR_TRX_DEFAULT_PRIM_SITE_USE'),'BILL_SHIP_TO');


        IF  x_term_id IS  NULL THEN

        IF p_term_name IS NOT NULL THEN
         begin
           SELECT term_id
           INTO   x_term_id
           FROM   ra_terms
           WHERE  name  = p_term_name and
                  nvl(p_deposit_date, trunc(sysdate)) between start_date_active
                             and nvl(end_date_active,nvl(p_deposit_date,trunc(sysdate)));

         exception
           when no_data_found then
                  FND_MESSAGE.SET_NAME('AR','AR_DAPI_TERM_NAME_INVALID');
                  FND_MSG_PUB.Add;
                   p_return_status := FND_API.G_RET_STS_ERROR;

         end;
        END IF;
       ELSE
         begin
           SELECT term_id
           INTO   x_term_id
           FROM   ra_terms
           WHERE  term_id  = x_term_id and
                  nvl(p_deposit_date, trunc(sysdate)) between start_date_active
                             and nvl(end_date_active,nvl(p_deposit_date,trunc(sysdate)));

         exception
           when no_data_found then
                 FND_MESSAGE.SET_NAME('AR','AR_DAPI_TERM_ID_INVALID');
                  FND_MSG_PUB.Add;
                  p_return_status := FND_API.G_RET_STS_ERROR;

         end;

       END IF;


       IF   x_salesrep_id IS  NULL AND
            p_salesrep_name IS NOT NULL
       THEN
        begin
           SELECT salesrep_id
           INTO   x_salesrep_id
           FROM    ra_salesreps
           WHERE  name  = p_salesrep_name and
                  NVL(status,'A') ='A'      and
                  p_deposit_date between nvl(start_date_active, p_deposit_date) and
                                             nvl(end_date_active, p_deposit_date);

         exception
           when no_data_found then
                  FND_MESSAGE.SET_NAME('AR','AR_DAPI_SALESREP_NAME_INVALID');
                  FND_MSG_PUB.Add;
                  p_return_status := FND_API.G_RET_STS_ERROR;

         end;
       ELSIF (x_salesrep_id IS  NOT NULL) THEN

        begin
           SELECT salesrep_id
           INTO   x_salesrep_id
           FROM    ra_salesreps
          WHERE  salesrep_id = x_salesrep_id and
                 NVL(status,'A') ='A'      and
                 p_deposit_date between nvl(start_date_active, p_deposit_date) and
                                             nvl(end_date_active, p_deposit_date);

        exception
           when no_data_found then
                 FND_MESSAGE.SET_NAME('AR','AR_DAPI_SALESREP_ID_INVALID');
                 FND_MSG_PUB.Add;
                 p_return_status := FND_API.G_RET_STS_ERROR;
        end;


       END IF;



   IF   x_memo_line_id IS  NULL THEN
     IF  p_memo_line_name IS NOT NULL
     THEN
       BEGIN
           select memo_line_id
           into   x_memo_line_id
           from ar_memo_lines
           where  line_type='LINE' and
                 sysdate between nvl(trunc(start_date),sysdate)
                         and nvl(trunc(end_date),sysdate) and
                  name = p_memo_line_name;
       EXCEPTION
           when no_data_found then
              FND_MESSAGE.SET_NAME('AR','AR_DAPI_MEMO_NAME_INVALID');
              FND_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
       END;

      END IF;
   ELSE
    IF  p_memo_line_name IS NOT NULL
     THEN
       FND_MESSAGE.SET_NAME('AR','AR_DAPI_MEMO_WRG');
       FND_MSG_PUB.Add;
     END IF;

       BEGIN
           select memo_line_id
           into   l_dummy
           from ar_memo_lines
           where  line_type='LINE' and
                  sysdate between nvl(trunc(start_date),sysdate)
                          and nvl(trunc(end_date),sysdate) and
                  memo_line_id = x_memo_line_id;
       EXCEPTION
           when no_data_found then
              FND_MESSAGE.SET_NAME('AR','AR_DAPI_MEMO_NAME_INVALID');
              FND_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
       END;

   END IF;

IF   x_inventory_id IS  NOT NULL THEN

       BEGIN
           select inventory_item_id
           into   l_dummy
           from   MTL_SYSTEM_ITEMS_B
           where  inventory_item_id = x_inventory_id and
                  ORGANIZATION_ID = oe_profile.value('SO_ORGANIZATION_ID') and
                  ENABLED_FLAG = 'Y';
       EXCEPTION
           when no_data_found then
              FND_MESSAGE.SET_NAME('AR','AR_DAPI_INV_ID_INVALID');
              FND_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
       END;
    IF x_memo_line_id is NOT NULL then
      FND_MESSAGE.SET_NAME('AR','AR_DAPI_INV_MEMO_COM');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

END IF;


   IF   x_batch_source_id IS  NULL THEN
     IF  p_batch_source_name IS NOT NULL
     THEN

      begin
        /* SELECT batch_source_id
         INTO   x_batch_source_id
         FROM   ra_batch_sources
         WHERE  name  = p_batch_source_name and
                batch_source_id not in (11,12) and
                nvl(status,'A')= 'A' and (batch_source_type = 'INV');*/
         SELECT batch_source_id
         INTO   x_batch_source_id
         FROM   ra_batch_sources bs
         WHERE  name  = p_batch_source_name and
                batch_source_id not in (11,12) and
                nvl(status,'A')= 'A' and (batch_source_type = 'INV') and
                (( p_deposit_number is not null and
                   auto_trx_numbering_flag = 'N' )  or
                  ( p_deposit_number is null and
                    auto_trx_numbering_flag = 'Y' ) ) and
                nvl(p_deposit_date, trunc(sysdate)) between nvl(bs.start_date, nvl(p_deposit_date, trunc(sysdate))) and
                                                        nvl(bs.end_date, nvl(p_deposit_date, trunc(sysdate)));

      exception
           when no_data_found then
           arp_util.debug('x_batch_source_id IS NULL');
            FND_MESSAGE.SET_NAME('AR','AR_DAPI_BS_NAME_INVALID');
            FND_MSG_PUB.Add;
            p_return_status := FND_API.G_RET_STS_ERROR;

      end;

     END IF;
   ELSE
         --validate the id here or in vadidate_deposit routine
         IF p_batch_source_name IS NOT NULL then
             arp_util.debug('x_batch_source_id IS ignored');
            FND_MESSAGE.SET_NAME('AR','AR_DAPI_BS_NAME_IGN');
            FND_MSG_PUB.Add;

         END IF;

      begin
        /* SELECT batch_source_id
         INTO   l_dummy
         FROM   ra_batch_sources
         WHERE  batch_source_id  = x_batch_source_id and
                batch_source_id not in (11,12) and
                nvl(status,'A')= 'A' and (batch_source_type = 'INV');*/
        SELECT batch_source_id
         INTO   l_dummy
         FROM   ra_batch_sources bs
         WHERE  batch_source_id  = x_batch_source_id and
                batch_source_id not in (11,12) and
                nvl(status,'A')= 'A' and (batch_source_type = 'INV') and
                (( p_deposit_number is not null and
                   auto_trx_numbering_flag = 'N' )  or
                  ( p_deposit_number is null and
                    auto_trx_numbering_flag = 'Y' ) ) and
                nvl(p_deposit_date, trunc(sysdate)) between nvl(bs.start_date, nvl(p_deposit_date, trunc(sysdate))) and
                                                        nvl(bs.end_date, nvl(p_deposit_date, trunc(sysdate)));
      exception
           when no_data_found then
           arp_util.debug('x_batch_source_id :no_data_found');
                 FND_MESSAGE.SET_NAME('AR','AR_DAPI_BS_ID_INVALID');
                  FND_MSG_PUB.Add;
                  p_return_status := FND_API.G_RET_STS_ERROR;

      end;

   END IF;

 IF   x_cust_trx_type_id IS  NULL THEN
    IF  p_cust_trx_type    IS NOT NULL THEN

      BEGIN
            SELECT  cust_trx_type_id
            INTO x_cust_trx_type_id
            FROM  ra_cust_trx_types
            where type = 'DEP' and
                  nvl(p_deposit_date, trunc(sysdate)) between
                      nvl(start_date(+), nvl(p_deposit_date, trunc(sysdate)))   and
                      nvl(end_date(+), nvl(p_deposit_date, trunc(sysdate)))  and
                  NAME = p_cust_trx_type;
      EXCEPTION

         WHEN NO_DATA_FOUND THEN
                  FND_MESSAGE.SET_NAME('AR','AR_DAPI_TRANS_TYPE_INVALID');
                  FND_MSG_PUB.Add;
                  p_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
             RAISE;
      END;
   /* ELSE
      FND_MESSAGE.SET_NAME('AR','AR_DAPI_TRANS_TYPE_NULL');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;
    */
    END IF;
 ELSE
     IF  p_cust_trx_type    IS NOT NULL THEN
          FND_MESSAGE.SET_NAME('AR','AR_DAPI_TRANS_TYPE_IGN');
          FND_MSG_PUB.Add;
      END IF;

            -- validate x_cust_trx_type_id
         BEGIN
          SELECT  cust_trx_type_id
          INTO   l_dummy
          FROM  ra_cust_trx_types
          where   type = 'DEP' and
                  nvl(p_deposit_date, trunc(sysdate)) between
                      nvl(start_date(+), nvl(p_deposit_date, trunc(sysdate)))   and
                      nvl(end_date(+), nvl(p_deposit_date, trunc(sysdate)))  and
                  cust_trx_type_id = x_cust_trx_type_id;
         EXCEPTION

            WHEN NO_DATA_FOUND THEN
                 FND_MESSAGE.SET_NAME('AR','AR_DAPI_TRANS_TYPE_ID_INVALID');
                 FND_MSG_PUB.Add;
                 p_return_status := FND_API.G_RET_STS_ERROR;
             WHEN OTHERS THEN
                  RAISE;
         END;

  END IF;


-- get BILL to Customer ID/Number/Name
IF (x_bill_to_customer_id is NULL)
  THEN
   IF(p_bill_to_customer_name IS NOT NULL) and
     (p_bill_to_customer_number IS NULL)
    THEN
     x_bill_to_customer_id := Get_Id('CUSTOMER_NAME',
                                      p_bill_to_customer_name,
                                      l_dummy_return_status);
     IF x_bill_to_customer_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NAME_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   ELSIF(p_bill_to_customer_name IS NULL) and
        (p_bill_to_customer_number IS NOT NULL)
    THEN
     x_bill_to_customer_id := Get_Id( 'CUSTOMER_NUMBER',
                              p_bill_to_customer_number,
                              l_dummy_return_status);
     IF x_bill_to_customer_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NUM_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   ELSIF(p_bill_to_customer_name IS NOT NULL) and
        (p_bill_to_customer_number IS NOT NULL)
    THEN
     x_bill_to_customer_id := Get_Cross_Validated_Id( 'CUSTOMER',
                                              p_bill_to_customer_number,
                                              p_bill_to_customer_name,
                                              l_dummy_return_status);
      IF x_bill_to_customer_id IS NULL THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NAME_NUM_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;


   END IF;

ELSE
--In case the ID has been entered by the user
   IF (p_bill_to_customer_name IS NOT NULL) OR
      (p_bill_to_customer_number IS NOT NULL) THEN
       --give a warning message to indicate that the
       -- customer_number and customer_name
       --entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NAME_NUM_IGN');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;
    /*--------------------------------+
     |                                |
     |   Validate Customer_id         |
     |                                |
    +--------------------------------*/
                  BEGIN
                    SELECT cust.cust_account_id
                    INTO   l_customer_id
                    FROM   hz_cust_accounts cust,
                           hz_customer_profiles cp,
                           hz_parties party
                    WHERE  cust.cust_account_id = cp.cust_account_id (+) and
                           cp.site_use_id is null and
                           cust.cust_account_id = x_bill_to_customer_id and
                           cust.status <> 'I'  and
                           cust.party_id = party.party_id;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_ID_INVALID');
                         FND_MSG_PUB.Add;

                    WHEN OTHERS THEN
                         arp_util.debug('EXCEPTION: Cache_Customer_id() ');
                         arp_util.debug('p_customer_id  =  ' ||
                                TO_CHAR(x_bill_to_customer_id));
                         RAISE;
                  END;


END IF;


-- get SHIP to Customer ID/Number/Name
IF (x_ship_to_customer_id IS NOT NULL or
    p_ship_to_customer_name IS NOT NULL or
    p_ship_to_customer_number IS NOT NULL ) THEN

  IF (x_ship_to_customer_id is NULL)
   THEN
     IF(p_ship_to_customer_name IS NOT NULL) and
       (p_ship_to_customer_number IS NULL)
     THEN
        x_ship_to_customer_id := Get_Id('CUSTOMER_NAME',
                                         p_ship_to_customer_name,
                                        l_dummy_return_status);
       IF x_ship_to_customer_id IS NULL THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NAME_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

   ELSIF(p_ship_to_customer_name IS NULL) and
        (p_ship_to_customer_number IS NOT NULL)
    THEN
     x_ship_to_customer_id := Get_Id( 'CUSTOMER_NUMBER',
                              p_ship_to_customer_number,
                              l_dummy_return_status);
       IF x_ship_to_customer_id IS NULL THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NUM_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

   ELSIF(p_ship_to_customer_name IS NOT NULL) and
        (p_ship_to_customer_number IS NOT NULL)
    THEN
     x_ship_to_customer_id := Get_Cross_Validated_Id
                                            ( 'CUSTOMER',
                                              p_ship_to_customer_number,
                                              p_ship_to_customer_name,
                                              l_dummy_return_status);
      IF x_ship_to_customer_id IS NULL THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NAME_NUM_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
   END IF;

  ELSE
   --In case the ID has been entered by the user
    IF (p_ship_to_customer_name IS NOT NULL) OR
      (p_ship_to_customer_number IS NOT NULL) THEN
       --give a warning message to indicate that the customer_number
       --and customer_name
       --entered by the user have been ignored.
        IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	 THEN
          FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NAME_NUM_IGN');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
     END IF;
    /*--------------------------------+
     |                                |
     |   Validate Customer_id         |
     |                                |
    +--------------------------------*/
                  BEGIN
                    SELECT cust.cust_account_id
                    INTO   l_customer_id
                    FROM   hz_cust_accounts cust,
                           hz_customer_profiles cp,
                           hz_parties party
                    WHERE  cust.cust_account_id = cp.cust_account_id (+) and
                           cp.site_use_id is null and
                           cust.cust_account_id = x_ship_to_customer_id and
                           cust.status <> 'I'  and
                           cust.party_id = party.party_id;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_ID_INVALID');
                         FND_MSG_PUB.Add;

                    WHEN OTHERS THEN
                         arp_util.debug('x_ship_to_customer_id = ' ||
                                        TO_CHAR(x_ship_to_customer_id));
                         RAISE;
                  END;


   END IF;


 END IF;

--through an error if both are null
IF x_bill_to_customer_id is null and
   x_ship_to_customer_id is null
THEN
  FND_MESSAGE.SET_NAME('AR','AR_DAPI_BILL_OR_SHIP_CUST_REQ');
  FND_MSG_PUB.Add;
  p_return_status := FND_API.G_RET_STS_ERROR;
END IF;


 -- find default for l_bill_to_location
if l_bill_to_location is null and x_bill_to_customer_id IS NOT NULL then

    if(l_default_site_use in ('BILL_TO','BILL_SHIP_TO')) then

	Begin
	      select  su.location
	      into l_dft_bill_to_location
	      from    hz_cust_acct_sites acct_site,
		      hz_party_sites party_site,
		      hz_locations loc,
		      hz_cust_site_uses su,
		      fnd_territories_vl t
		where   acct_site.cust_acct_site_id = su.cust_acct_site_id
		and     acct_site.party_site_id = party_site.party_site_id
		and     loc.location_id = party_site.location_id
		and     loc.country = t.territory_code
		and     acct_site.cust_account_id = x_bill_to_customer_id
		and     su.site_use_id = nvl(null,su.site_use_id)
		and     su.site_use_code = 'BILL_TO'
		and     ( su.site_use_id = null
			  or ( su.status = 'A'
			       and acct_site.status = 'A'
			     )
			)
		and su.primary_flag = 'Y';

	exception
	   when no_data_found then
	       l_dft_bill_to_location:= null;
	end;

	   l_bill_to_location := l_dft_bill_to_location;
	   p_bill_to_location := l_dft_bill_to_location;
   else
         FND_MESSAGE.SET_NAME('AR','AR_DAPI_BILL_TO_LOC_REQ');
         FND_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
   end if ;
end if;


 -- find default for l_ship_to_location
if l_ship_to_location is null and (x_ship_to_customer_id IS NOT NULL) then
    if( l_default_site_use in ('SHIP_TO','BILL_SHIP_TO')) then

	Begin
	      select  su.location
	      into l_dft_ship_to_location
	      from    hz_cust_acct_sites acct_site,
		      hz_party_sites party_site,
		      hz_locations loc,
		      hz_cust_site_uses su,
		      fnd_territories_vl t
		where   acct_site.cust_acct_site_id = su.cust_acct_site_id
		and     acct_site.party_site_id = party_site.party_site_id
		and     loc.location_id = party_site.location_id
		and     loc.country = t.territory_code
		and     acct_site.cust_account_id = x_ship_to_customer_id
		and     su.site_use_id = nvl(null,su.site_use_id)
		and     su.site_use_code = 'SHIP_TO'
		and     ( su.site_use_id = null
			  or ( su.status = 'A'
			       and acct_site.status = 'A'
			     )
			)
		and su.primary_flag = 'Y';

	exception
	   when no_data_found then
	       l_dft_ship_to_location:= null;
	end;

	   l_ship_to_location := l_dft_ship_to_location;
	   p_ship_to_location := l_dft_ship_to_location;
    else
          FND_MESSAGE.SET_NAME('AR','AR_DAPI_SHIP_TO_LOC_REQ');
          FND_MSG_PUB.Add;
	  p_return_status := FND_API.G_RET_STS_ERROR;
   end if;
end if;

-- default bill to from ship to if bill to is null
IF x_bill_to_customer_id is null THEN

   x_bill_to_customer_id := x_ship_to_customer_id;
   if(l_default_site_use in ('BILL_TO','BILL_SHIP_TO')) then
   	l_bill_to_location := l_ship_to_location;
   	p_bill_to_location := l_ship_to_location;

   	FND_MESSAGE.SET_NAME('AR','AR_DAPI_BILL_VAL_SHIP_IGN');
   	FND_MSG_PUB.Add;
    else
         FND_MESSAGE.SET_NAME('AR','AR_DAPI_BILL_TO_LOC_REQ');
         FND_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
    end if ;
END IF;



 --get bill to Customer site use id
 IF x_bill_to_customer_id IS NOT NULL  THEN
 --we need to validate location here

     x_bill_to_customer_site_use_id := Get_Site_Use_Id(x_bill_to_customer_id,
                                               l_bill_to_location,
                                               'BILL_TO',
                                               'DRAWEE' ,
                                               l_site_use_return_status
                                              );
    if x_bill_to_customer_site_use_id  is null then
              FND_MESSAGE.SET_NAME('AR','AR_DAPI_LOC_INV');
               FND_MSG_PUB.Add;
               p_return_status := FND_API.G_RET_STS_ERROR;
    end if;

 END IF;



 IF (x_bill_to_contact_id is NULL)
  THEN

     IF(p_bill_to_contact_first_name IS NOT NULL) and
       (p_bill_to_contact_last_name IS NOT NULL)

     THEN

        x_bill_to_contact_id :=
                AR_DEPOSIT_LIB_PVT.GET_CONTACT_ID(x_bill_to_customer_id,
                                                  p_bill_to_contact_first_name,
                                                  p_bill_to_contact_last_name,
                                                  l_contact_return_status);
        if  x_bill_to_contact_id is null then
               FND_MESSAGE.SET_NAME('AR','AR_DAPI_BIll_CONTACT_COM_INV');
               FND_MSG_PUB.Add;
               p_return_status := FND_API.G_RET_STS_ERROR;
        end if;

     ELSIF (p_bill_to_contact_first_name IS  NULL and
            p_bill_to_contact_last_name IS NOT NULL) OR
            (p_bill_to_contact_first_name IS NOT NULL and
            p_bill_to_contact_last_name IS  NULL) THEN
       arp_util.debug('Bill_to_contact_id both last and
                       first name are required');
       FND_MESSAGE.SET_NAME('AR','AR_DAPI_BIll_CONTACT_NAME_INV');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;

     END IF;

 ELSE

 --validate contact id
            begin
             SELECT acct_role.cust_account_role_id
             INTO l_dummy
             from hz_cust_account_roles acct_role,
                  hz_parties party,
                  hz_relationships rel,
                  hz_org_contacts  org_cont,
                  hz_parties       rel_party
            where acct_role.party_id = rel.party_id
                  and acct_role.role_type = 'CONTACT'
                  and org_cont.party_relationship_id =
                                         rel.relationship_id
                  and rel.subject_id = party.party_id
                  and rel.party_id = rel_party.party_id
                  and rel.subject_table_name = 'HZ_PARTIES'
                  and rel.object_table_name = 'HZ_PARTIES'
                  and rel.directional_flag = 'F'
                  and acct_role.cust_account_id = x_bill_to_customer_id
    /* the contact must be active. however, for credit memos
    against specific transactions, the credited transaction's
    contact may also be used even if it is not active. */
                 AND acct_role.status = 'A'
                 AND acct_role.cust_account_role_id  = x_bill_to_contact_id;

           exception
            when no_data_found then
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('AR','AR_DAPI_CUS_CONTACT_INVALID');
                 FND_MSG_PUB.Add;

            when others then
                 arp_util.debug('EXCEPTIONS: Others ,  GET_CONTACT_ID()');
          end;

 END IF;


 --get ship to Customer site use id
 IF x_ship_to_customer_id IS NOT NULL  THEN

       x_ship_to_customer_site_use_id :=
                       Get_Site_Use_Id(x_ship_to_customer_id,
                                       l_ship_to_location,
                                       'SHIP_TO',
                                       NULL ,l_site_use_return_status
                                       );
      if x_ship_to_customer_site_use_id  is null then
              FND_MESSAGE.SET_NAME('AR','AR_DAPI_LOC_INV');
              FND_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
      end if;
         IF (x_ship_to_contact_id is NULL)
           THEN
            IF(p_ship_to_contact_first_name IS NOT NULL) and
              (p_ship_to_contact_last_name IS NOT NULL)

            THEN

            x_ship_to_contact_id    :=
               AR_DEPOSIT_LIB_PVT.GET_CONTACT_ID(x_ship_to_customer_id,
                                                 p_ship_to_contact_first_name,
                                                 p_ship_to_contact_last_name,
                                                 l_contact_return_status);
             if  x_ship_to_contact_id is null then
               FND_MESSAGE.SET_NAME('AR','AR_DAPI_SHIP_CONTACT_COM_INV');
               FND_MSG_PUB.Add;
               p_return_status := FND_API.G_RET_STS_ERROR;
             end if;

           ELSIF(p_ship_to_contact_first_name IS  NULL and
                 p_ship_to_contact_last_name  IS  NOT NULL) OR
                (p_ship_to_contact_first_name IS  NOT NULL and
                 p_ship_to_contact_last_name  IS  NULL) THEN

              arp_util.debug('Ship_to_contact_id both last and
                              first name are required');
              FND_MESSAGE.SET_NAME('AR','AR_DAPI_SHIP_CONTACT_NAME_INV');
              FND_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

         ELSE
             --validate x_ship_to_contact_id
            begin
             SELECT acct_role.cust_account_role_id
             INTO l_dummy
             from hz_cust_account_roles acct_role,
                  hz_parties party,
                  hz_relationships rel,
                  hz_org_contacts  org_cont,
                  hz_parties       rel_party
            where acct_role.party_id = rel.party_id
                  and acct_role.role_type = 'CONTACT'
                  and org_cont.party_relationship_id =
                                  rel.relationship_id
                  and rel.subject_id = party.party_id
                  and rel.party_id = rel_party.party_id
                  and rel.subject_table_name = 'HZ_PARTIES'
                  and rel.object_table_name = 'HZ_PARTIES'
                  and rel.directional_flag = 'F'
                  and acct_role.cust_account_id = x_ship_to_customer_id
	/* the contact must be active. however, for credit memos
	against specific transactions, the credited transaction's
	contact may also be used even if it is not active. */
                 AND acct_role.status   = 'A'
                 AND acct_role.cust_account_role_id  = x_ship_to_contact_id;

           exception
            when no_data_found then
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('AR','AR_DAPI_CUS_CONTACT_INVALID');
                 FND_MSG_PUB.Add;

            when others then
                 arp_util.debug('EXCEPTIONS: Others ,  GET_CONTACT_ID()');
          end;

          END IF;

 END IF;

--Receipt method ID,Name
IF x_receipt_method_id IS NULL
  THEN
   IF p_receipt_method_name IS NOT NULL THEN
      x_receipt_method_id := Get_Id('RECEIPT_METHOD_NAME',
                                     p_receipt_method_name,
                                     l_get_id_return_status
                                    );
     IF x_receipt_method_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_MD_NAME_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;

 ELSE
    IF (p_receipt_method_name IS NOT NULL) THEN
       --give a warning message to indicate that the receipt_method_name
       --entered by the user has been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_MD_NAME_IGN');
         FND_MSG_PUB.Add;
       END IF;
    ELSE
        BEGIN
         SELECT name
         INTO   p_receipt_method_name
         FROM   ar_receipt_methods
         WHERE  receipt_method_id = x_receipt_method_id;
        EXCEPTION
         WHEN no_data_found THEN
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_MD_ID_INVALID');
            FND_MSG_PUB.Add;
            arp_util.debug('Invalid receipt method id ');
        END;

    END IF;

 END IF;


--Customer bank account Number,Name,ID
-- REMOVED FOR PAYMENT UPTAKE  there is no need to default the Customer bank account Number,Name,ID

-- Exchange_rate_type
 IF x_exchange_rate_type IS NULL THEN
   IF p_usr_exchange_rate_type IS NOT NULL
    THEN
      x_exchange_rate_type := Get_Id('EXCHANGE_RATE_NAME',
                                     p_usr_exchange_rate_type,
                                     l_get_id_return_status
                                    );
      IF x_exchange_rate_type IS NULL THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_USR_X_RATE_TYP_INVALID');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   END IF;

 ELSE
   IF  (p_usr_exchange_rate_type IS NOT NULL) THEN
       --give a warning message to indicate that the usr_exchange_rate_type
       -- entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_USR_X_RATE_TYPE_IGN');
         FND_MSG_PUB.Add;
       END IF;
   END IF;

 END IF;

--Currency code
IF x_currency_code IS NULL THEN
   IF p_usr_currency_code IS NOT NULL
    THEN
      x_currency_code :=     Get_Id('CURRENCY_NAME',
                                     p_usr_currency_code,
                                     l_get_id_return_status
                                    );
      IF x_currency_code IS NULL THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_USR_CURR_CODE_INVALID');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   ELSE

     x_currency_code := arp_global.functional_currency;
     --Raise a warning message saying that currency was defaulted
     IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_FUNC_CURR_DEFAULTED');
        FND_MSG_PUB.Add;
     END IF;

   END IF;

ELSE
   IF  (p_usr_currency_code IS NOT NULL) THEN

       --give a warning message to indicate that the usr_currency_code
       -- entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_USR_CURR_CODE_IGN');
         FND_MSG_PUB.Add;
       END IF;

   END IF;
END IF;

-- for remit_to_address_id

l_match_site_use_id := x_bill_to_customer_site_use_id;

arp_util.debug('before x_remit_to_address');
 IF  x_remit_to_address_id is NULL THEN
   arp_util.debug('x_remit_to_address_id is null');
   IF p_cust_location_site_num is NULL AND l_match_site_use_id is NULL
   THEN
     arp_util.debug('p_cust_location_site_num is null, hence defaulted');
     begin
     ARP_TRX_DEFAULTS_3.get_default_remit_to(l_dft_remit_to_address_id,
                                            l_dft_remit_to_address_rec);
     x_remit_to_address_id :=   l_dft_remit_to_address_id;
      exception
          when others then
            FND_MESSAGE.SET_NAME('AR','AR_DAPI_REMIT_ADDRESS_DFT_ERR');
            FND_MSG_PUB.Add;
            p_return_status := FND_API.G_RET_STS_ERROR;
     end;
   ELSE
    arp_util.debug('p_cust_location_site_num is not null, hence fetching');
       Begin
       ARP_TRX_DEFAULTS_3.get_remit_to_address(l_match_state,
                                               l_match_country,
                                               l_match_postal_code,
                                               p_cust_location_site_num,
                                          --customer location site number
                                               l_match_site_use_id,
                                          --bill_to_sit
                                               l_remit_to_address_id ,
                                               l_remit_to_address_rec);
      x_remit_to_address_id :=   l_remit_to_address_id;
      exception
          when others then
            FND_MESSAGE.SET_NAME('AR','AR_DAPI_CUST_LOC_SITE_NUM_INV');
            FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
      end ;

   END IF;
 ELSE
     arp_util.debug('x_remit_to_address_id isnot null');
      IF  p_cust_location_site_num is NOT NULL  THEN
        --give a warning message to indicate that the
        --customer_number and customer_name
        --entered by the user have been ignored.
        IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	 THEN
          FND_MESSAGE.SET_NAME('AR','AR_DAPI_LOC_SITE_NUM_IGN');  --new message to be seeded
          FND_MSG_PUB.Add;

        END IF;
      END IF;
      begin
          select address_id into l_dummy
          from ar_active_remit_to_addresses_v
          where address_id = x_remit_to_address_id;
       exception
             when no_data_found then
               arp_util.debug('no_data_found in  is x_remit_to_address');
                 FND_MESSAGE.SET_NAME('AR','AR_DAPI_REMIT_ADDR_ID_INVD');
                 FND_MSG_PUB.Add;
                 p_return_status := FND_API.G_RET_STS_ERROR;
      end;

  END IF;

arp_util.debug('after x_remit_to_address');

IF  (x_sold_to_customer_id    IS NULL) THEN

  IF  (  p_sold_to_customer_name  IS NOT NULL and
       p_sold_to_customer_number IS NULL )
  THEN

     x_sold_to_customer_id := Get_Id('CUSTOMER_NAME',
                                      p_sold_to_customer_name,
                                     l_get_id_return_status);
     IF x_sold_to_customer_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_DAPI_SOLD_CUST_NAME_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
  ELSIF ( p_sold_to_customer_name  IS  NULL and
          p_sold_to_customer_number IS NOT NULL )
  THEN
     x_sold_to_customer_id := Get_Id( 'CUSTOMER_NUMBER',
                              p_sold_to_customer_number,
                              l_get_id_return_status);
     IF x_sold_to_customer_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_DAPI_SOLD_CUST_NUM_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

  ELSIF( p_sold_to_customer_name   IS NOT NULL and
         p_sold_to_customer_number IS NOT NULL )
  THEN
     x_sold_to_customer_id := Get_Cross_Validated_Id( 'CUSTOMER',
                                              p_sold_to_customer_number,
                                              p_sold_to_customer_name,
                                              l_get_x_val_return_status);
     IF x_sold_to_customer_id IS NULL THEN
        FND_MESSAGE.SET_NAME('AR','AR_DAPI_SOLD_CUST_COM_INVALID');
         FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
  ELSIF( p_sold_to_customer_name   IS  NULL and
         p_sold_to_customer_number IS  NULL )
  THEN

      --give a warning message to indicate that the sold_to_customer
     --is defaulted to bill to customer.
        x_sold_to_customer_id := x_bill_to_customer_id;
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_DAPI_SOLD_CUST_DFT');
         FND_MSG_PUB.Add;
       END IF;
   END IF;
ELSE
 IF  (p_sold_to_customer_name IS NOT NULL) OR
      (p_sold_to_customer_number IS NOT NULL) THEN
       --give a warning message to indicate that the customer_number
       --and customer_name
       --entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_DAPI_SOLD_CUS_IGN');
         FND_MSG_PUB.Add;

       END IF;
    END IF;
    /*--------------------------------+
     |                                |
     |   Validate sold to Customer_id |
     |                                |
    +--------------------------------*/
                  BEGIN
                    SELECT cust.cust_account_id
                    INTO   l_customer_id
                    FROM   hz_cust_accounts cust,
                           hz_customer_profiles cp,
                           hz_parties party
                    WHERE  cust.cust_account_id = cp.cust_account_id (+) and
                           cp.site_use_id is null and
                           cust.cust_account_id = x_sold_to_customer_id and
                           cust.status <> 'I'  and
                           cust.party_id = party.party_id;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      p_return_status := FND_API.G_RET_STS_ERROR;
                      FND_MESSAGE.SET_NAME('AR','AR_DAPI_SOLD_CUST_ID_INVALID');
                      FND_MSG_PUB.Add;

                    WHEN OTHERS THEN
                      arp_util.debug('EXCEPTION: sold to Customer_id() ');
                      RAISE;
                  END;

END IF;


IF (x_paying_customer_id IS NULL)
THEN
  --validate x_paying_customer_id
    x_paying_customer_id := x_bill_to_customer_id;

  IF ( p_paying_customer_name  IS NOT NULL and
       p_paying_customer_number IS NULL )
  THEN

     x_paying_customer_id := Get_Id('CUSTOMER_NAME',
                                      p_paying_customer_name,
                                     l_get_id_return_status);
     IF x_paying_customer_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_DAPI_PAY_CUST_NAME_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSIF ( p_paying_customer_name  IS  NULL and
          p_paying_customer_number IS NOT NULL )
    THEN
     x_paying_customer_id := Get_Id( 'CUSTOMER_NUMBER',
                              p_paying_customer_number,
                              l_get_id_return_status);
     IF x_paying_customer_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_DAPI_PAY_CUST_NUM_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

  ELSIF( p_paying_customer_name   IS NOT NULL and
         p_paying_customer_number IS NOT NULL )
    THEN
     x_paying_customer_id := Get_Cross_Validated_Id( 'CUSTOMER',
                                              p_paying_customer_number,
                                              p_paying_customer_name,
                                              l_get_x_val_return_status);
     IF x_paying_customer_id IS NULL THEN
         FND_MESSAGE.SET_NAME('AR','AR_DAPI_PAY_CUST_COM_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSE
      x_paying_customer_id := x_bill_to_customer_id;
   END IF;

ELSE
  IF  (p_paying_customer_name IS NOT NULL) OR
      (p_paying_customer_number IS NOT NULL) THEN
       --give a warning message to indicate that the customer_number
       --and customer_name
       --entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_DAPI_CUS_NAME_NUM_IGN');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;
    /*--------------------------------+
     |                                |
     |   Validate paying Customer_id         |
     |                                |
    +--------------------------------*/
                  BEGIN
                    SELECT cust.cust_account_id
                    INTO   l_customer_id
                    FROM   hz_cust_accounts cust,
                           hz_customer_profiles cp,
                           hz_parties party
                    WHERE  cust.cust_account_id = cp.cust_account_id (+) and
                           cp.site_use_id is null and
                           cust.cust_account_id = x_paying_customer_id and
                           cust.status <> 'I'  and
                           cust.party_id = party.party_id;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       p_return_status := FND_API.G_RET_STS_ERROR;
                       FND_MESSAGE.SET_NAME('AR','AR_DAPI_PAY_CUST_ID_INVALID');
                       FND_MSG_PUB.Add;

                    WHEN OTHERS THEN
                       arp_util.debug('EXCEPTION: paying_Customer_id() ');
                       RAISE;
                  END;
END IF;

 --Customer site use id
 IF x_paying_customer_id IS NOT NULL  THEN

  --we need to validate p_paying_location here

  IF x_paying_customer_site_use_id IS NULL THEN
   IF p_paying_location is not null then
    x_paying_customer_site_use_id :=
         Get_Site_Use_Id(x_paying_customer_id,
                         nvl(p_paying_location,l_bill_to_location),
                         'BILL_TO',
                         'DRAWEE' ,l_site_use_return_status
                                                       );
         arp_util.debug('x_paying_customer_site_use_id'||
                           to_char(x_paying_customer_site_use_id));
    else
      --get default location of paying customer
     Begin
      select   su.site_use_id
      into  x_paying_customer_site_use_id
      from    hz_cust_acct_sites acct_site,
              hz_party_sites party_site,
              hz_locations loc,
              hz_cust_site_uses su,
              fnd_territories_vl t
        where   acct_site.cust_acct_site_id = su.cust_acct_site_id
        and     acct_site.party_site_id = party_site.party_site_id
        and     loc.location_id = party_site.location_id
        and     loc.country = t.territory_code
        and     acct_site.cust_account_id = x_paying_customer_id
        and     su.site_use_id = nvl(null,su.site_use_id)
        and     su.site_use_code = 'BILL_TO'
        and     ( su.site_use_id = null
                  or ( su.status = 'A'
                       and acct_site.status = 'A'
                     )
                )
        and su.primary_flag = 'Y';

     exception
      when no_data_found then
           if x_paying_customer_id = x_bill_to_customer_id and
             l_bill_to_location is not null then
             x_paying_customer_site_use_id := Get_Site_Use_Id(x_paying_customer_id,
                                              l_bill_to_location,
                                              'BILL_TO',
                                              'DRAWEE' ,l_site_use_return_status);
           else
             x_paying_customer_site_use_id :=null;
           end if;
     end;

    end if;


    if x_paying_customer_site_use_id  is null then
           FND_MESSAGE.SET_NAME('AR','AR_DAPI_LOC_INV');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
    end if;
  ELSE
    IF p_paying_location IS NOT NULL THEN
      --raise warning that
      null;
    END IF;
  END IF;
 END IF;

 arp_util.debug('ar_deposit_lib_pvt.Default_deposit_ids() -' );
EXCEPTION
 WHEN others THEN
  arp_util.debug('EXCEPTION:  ar_deposit_lib_pvt.Default_deposit_ids() +',
                            G_MSG_UERROR);
  raise;
END Default_deposit_ids;


PROCEDURE Get_deposit_Defaults(
          p_currency_code           IN OUT NOCOPY
                         ra_customer_trx.invoice_currency_code%TYPE,
          p_exchange_rate_type     IN OUT NOCOPY
                         ra_customer_trx.exchange_rate_type%TYPE,
          p_exchange_rate          IN OUT NOCOPY  ra_customer_trx.exchange_rate%TYPE,
          p_exchange_rate_date     IN OUT NOCOPY ra_customer_trx.exchange_date%TYPE,
          p_start_date_commitmenmt IN OUT NOCOPY  DATE,
          p_end_date_commitmenmt   IN OUT NOCOPY  DATE,
          p_amount                 IN OUT NOCOPY  ar_cash_receipts.amount%TYPE,
          p_deposit_date           IN OUT NOCOPY  DATE,
          p_gl_date                IN OUT NOCOPY  DATE,
          p_bill_to_customer_id    IN NUMBER,
          p_bill_to_site_use_id    IN NUMBER,
          p_ship_to_customer_id    IN NUMBER,
          p_ship_to_site_use_id    IN NUMBER,
          p_salesrep_id            OUT NOCOPY  NUMBER,
          p_bill_to_contact_id     OUT NOCOPY  NUMBER,
          p_called_from            IN  VARCHAR2,
          p_return_status          OUT NOCOPY  VARCHAR2
           )
IS

 l_def_curr_return_status   VARCHAR2(1);
 l_def_rm_return_status     VARCHAR2(1);
 l_def_gl_dt_return_status  VARCHAR2(1);
 l_def_comm_dt_return_status  VARCHAR2(1);
BEGIN
 arp_util.debug('ar_deposit_lib_pvt.Get_deposit_Defaults() +' );
   p_return_status := FND_API.G_RET_STS_SUCCESS;
  -- default the receipt date if NULL
  IF (p_deposit_date IS NULL)
    THEN
    Select trunc(sysdate)
    into p_deposit_date
    from dual;
  END IF;

  -- default the gl_date
  IF p_gl_date IS NULL THEN
    Default_gl_date(p_deposit_date,
                    p_gl_date,
                    l_def_gl_dt_return_status);
    arp_util.debug('l_default_gl_date_return_status : '||
                    l_def_gl_dt_return_status);
  END IF;



    Default_commitment_Date(p_deposit_date,
                        p_start_date_commitmenmt,
                        p_end_date_commitmenmt,
                        l_def_comm_dt_return_status);

 -- Default the Currency parameters
    Default_Currency_info(p_currency_code,
                          p_deposit_date,
                          p_exchange_rate_date,
                          p_exchange_rate_type,
                          p_exchange_rate,
                          l_def_curr_return_status
                         );

--Set the precision of the receipt amount as per currency
  IF p_amount is NOT NULL THEN
   p_amount := arp_util.CurrRound( p_amount,
                                   p_currency_code
                                  );
  END IF;


  get_salesrep_defaults(p_salesrep_id, p_bill_to_customer_id,
                        p_bill_to_site_use_id,p_ship_to_customer_id ,
                        p_ship_to_site_use_id,p_deposit_date);


  default_bill_to_contact(p_bill_to_contact_id ,
                          p_bill_to_customer_id,
                          p_bill_to_site_use_id );


  IF l_def_rm_return_status      <> FND_API.G_RET_STS_SUCCESS OR
     l_def_gl_dt_return_status   <> FND_API.G_RET_STS_SUCCESS OR
     l_def_comm_dt_return_status <> FND_API.G_RET_STS_SUCCESS OR
     l_def_curr_return_status    <> FND_API.G_RET_STS_SUCCESS
  THEN
     p_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  arp_util.debug('************Cash Defaults********************');
  arp_util.debug('p_gl_date          : '||to_char(p_gl_date,'DD-MON-YYYY'));
  arp_util.debug('p_deposit_date     : '||
                       to_char(p_deposit_date,'DD-MON-YYYY'));
  arp_util.debug('p_currency_code    : '||p_currency_code);
  arp_util.debug('p_exchange_rate_date: '||
                       to_char(p_exchange_rate_date,'DD-MON-YYYY'));
  arp_util.debug('p_exchange_rate_type: '||p_exchange_rate_type);
  arp_util.debug('p_exchange_rate     : '||to_char(p_exchange_rate));
 arp_util.debug('ar_deposit_lib_pvt.Get_deposit_Defaults() -' );
END Get_deposit_Defaults;


PROCEDURE get_doc_seq(p_application_id IN NUMBER,
                      p_document_name  IN VARCHAR2,
                      p_sob_id         IN NUMBER,
                      p_met_code	   IN CHAR,
                      p_trx_date       IN DATE,
                      p_doc_sequence_value IN OUT NOCOPY  NUMBER,
                      p_doc_sequence_id    OUT NOCOPY  NUMBER,
                      p_return_status      OUT NOCOPY  VARCHAR2
                      ) AS
l_doc_seq_ret_stat   NUMBER;
l_doc_sequence_name  VARCHAR2(50);
l_doc_sequence_type  VARCHAR2(50);
l_doc_sequence_value NUMBER;
l_db_sequence_name   VARCHAR2(50);
l_seq_ass_id         NUMBER;
l_prd_tab_name       VARCHAR2(50);
l_aud_tab_name       VARCHAR2(50);
l_msg_flag           VARCHAR2(1);
BEGIN
            arp_util.debug('ar_deposit_lib_pvt.get_doc_seq() +' );
            arp_util.debug('SEQ : '||NVL( pg_profile_doc_seq, 'N'));
            arp_util.debug('p_document_name :'||p_document_name);
            arp_util.debug('p_application_id :'||to_char(p_application_id));
            arp_util.debug('p_sob_id  :'||to_char(p_sob_id));
            p_return_status := FND_API.G_RET_STS_SUCCESS;
	     IF   ( NVL( pg_profile_doc_seq, 'N') <> 'N' )
           THEN
             BEGIN
                      /*------------------------------+
                       |  Get the document sequence.  |
                       +------------------------------*/
              l_doc_seq_ret_stat:=
                   fnd_seqnum.get_seq_info (
		                                 p_application_id,
                                         p_document_name,
                                         p_sob_id,
                                         p_met_code,
                                         trunc(p_trx_date),
                                         p_doc_sequence_id,
                                         l_doc_sequence_type,
                                         l_doc_sequence_name,
                                         l_db_sequence_name,
                                         l_seq_ass_id,
                                         l_prd_tab_name,
                                         l_aud_tab_name,
                                         l_msg_flag,
                                         'Y',
                                         'Y');
             arp_util.debug('Doc sequence return status :'||
                             to_char(nvl(l_doc_seq_ret_stat,-99)));
             arp_util.debug('l_doc_sequence_name :'||l_doc_sequence_name);
             arp_util.debug('l_doc_sequence_id :'||
                             to_char(nvl(p_doc_sequence_id,-99)));

               IF l_doc_seq_ret_stat = -8 THEN
                --this is the case of Always Used
                 arp_util.debug('The doc sequence does not exist
                                  for the current document');
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 --Error message
                 FND_MESSAGE.Set_Name( 'AR','AR_RAPI_DOC_SEQ_NOT_EXIST_A');
                 FND_MSG_PUB.Add;
               ELSIF l_doc_seq_ret_stat = -2  THEN
               --this is the case of Partially Used
                arp_util.debug('The doc sequence does not exist
                                for the current document');
                 --Warning
                 IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
                  THEN
                     FND_MESSAGE.SET_NAME('AR','AR_RAPI_DOC_SEQ_NOT_EXIST_P');
                     FND_MSG_PUB.Add;
                 END IF;
               END IF;

                IF ( l_doc_sequence_name IS NOT NULL
                 AND p_doc_sequence_id   IS NOT NULL)
                   THEN
                             /*------------------------------------+
                              |  Automatic Document Numbering case |
                              +------------------------------------*/
                     arp_util.debug('Automatic Document Numbering case ');
                              l_doc_seq_ret_stat :=
                                  fnd_seqnum.get_seq_val (
		                                      p_application_id,
		                                      p_document_name,
		                                      p_sob_id,
                                                      p_met_code,
                                                      TRUNC(p_trx_date),
                                                      l_doc_sequence_value,
                                                      p_doc_sequence_id);
                    IF p_doc_sequence_value IS NOT NULL THEN
                     --raise an error message because the user is
                     --not supposed to pass
                     --in a value for the document sequence number in this case.
                       p_return_status := FND_API.G_RET_STS_ERROR;
                       FND_MESSAGE.Set_Name('AR', 'AR_RAPI_DOC_SEQ_AUTOMATIC');
                        FND_MSG_PUB.Add;
                    END IF;
                    p_doc_sequence_value := l_doc_sequence_value;
                    arp_util.debug('l_doc_sequence_value :'||
                                    to_char(nvl(p_doc_sequence_value,-99)));
                   ELSIF (
                       p_doc_sequence_id    IS NOT NULL
                   AND p_doc_sequence_value IS NOT NULL
                       )
                        THEN
                                 /*-------------------------------------+
                                  |  Manual Document Numbering case     |
                                  |  with the document value specified. |
                                  |  Use the specified value.           |
                                  +-------------------------------------*/

                                  NULL;

                   ELSIF (
                         p_doc_sequence_id    IS NOT NULL
                     AND p_doc_sequence_value IS NULL
                      )
                       THEN
                                 /*-----------------------------------------+
                                  |  Manual Document Numbering case         |
                                  |  with the document value not specified. |
                                  |  Generate a document value mandatory    |
                                  |  error.                                 |
                                  +-----------------------------------------*/
                          IF NVL(pg_profile_doc_seq,'N') = 'A' THEN
                           p_return_status := FND_API.G_RET_STS_ERROR;
                           FND_MESSAGE.Set_Name('AR',
                                                'AR_RAPI_DOC_SEQ_VALUE_NULL_A');
                           FND_MESSAGE.Set_Token('SEQUENCE',
                                                  l_doc_sequence_name);
                           FND_MSG_PUB.Add;
                           ELSIF NVL(pg_profile_doc_seq,'N') = 'P'  THEN
                             --Warning
                             IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
                             THEN
                                FND_MESSAGE.SET_NAME('AR',
					        'AR_RAPI_DOC_SEQ_VALUE_NULL_P');
                                FND_MSG_PUB.Add;
                             END IF;
                           END IF;


                   END IF;

                   EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                           /*------------------------------------------+
                            |  No document assignment was found.       |
                            |  Generate an error if document numbering |
                            |  is mandatory.                           |
                            +------------------------------------------*/
                         arp_util.debug('no_data_found raised');
                         IF   (pg_profile_doc_seq = 'A' ) THEN
                            p_return_status := FND_API.G_RET_STS_ERROR;
                            FND_MESSAGE.Set_Name( 'FND','UNIQUE-ALWAYS USED');
                            FND_MSG_PUB.Add;
                         ELSE
                           p_doc_sequence_id    := NULL;
                           p_doc_sequence_value := NULL;
                         END IF;

                   WHEN OTHERS THEN
                     arp_util.debug('Unhandled exception in doc sequence
			             assignment');
                     raise;

                   END;

             END IF;
 arp_util.debug('ar_deposit_lib_pvt.get_doc_seq() -' );
END get_doc_seq;

PROCEDURE Validate_Desc_Flexfield(
       p_desc_flex_rec       IN OUT NOCOPY   ar_deposit_api_pub.attr_rec_type,
       p_desc_flex_name      IN VARCHAR2,
       p_return_status       IN OUT NOCOPY   varchar2
       ) IS

l_flex_name     fnd_descriptive_flexs.descriptive_flexfield_name%type;
l_count         NUMBER;
l_col_name      VARCHAR2(50);
l_flex_exists   VARCHAR2(1);
CURSOR desc_flex_exists IS
  SELECT 'Y'
  FROM fnd_descriptive_flexs
  WHERE application_id = 222 and
        descriptive_flexfield_name = p_desc_flex_name;
/* Start FP Bug 5467022 */
/* bug 5467021  created get_flex_title to get title of flex field*/
function get_flex_title ( p_flex_name in varchar2) return varchar2 is
l_flex_title			FND_DESCRIPTIVE_FLEXS_VL.title%type;
begin
select title
into   l_flex_title
from   FND_DESCRIPTIVE_FLEXS_VL
where  DESCRIPTIVE_FLEXFIELD_NAME=p_flex_name;

return l_flex_title;
exception
when others then
      arp_util.debug('Exception : Others in get_flex_title function'|| sqlerrm);
 return p_flex_name;
end get_flex_title;
/* End FP Bug 5467022 SPDIXIT */
BEGIN
     arp_util.debug('ar_deposit_lib_pvt.Validate_Desc_Flexfield() +' );
      p_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN desc_flex_exists;
      FETCH desc_flex_exists INTO l_flex_exists;
      IF desc_flex_exists%NOTFOUND THEN
       CLOSE desc_flex_exists;
       p_return_status :=  FND_API.G_RET_STS_ERROR;
       return;
      END IF;
      CLOSE desc_flex_exists;
  /* Start FP Bug 5467022 */
   arp_util.debug('attribute_category  : '||p_desc_flex_rec.attribute_category);
   arp_util.debug('attribute1          : '||p_desc_flex_rec.attribute1);
   arp_util.debug('attribute2          : '||p_desc_flex_rec.attribute2);
   arp_util.debug('attribute3          : '||p_desc_flex_rec.attribute3);
   arp_util.debug('attribute4          : '||p_desc_flex_rec.attribute4);
   arp_util.debug('attribute5          : '||p_desc_flex_rec.attribute5);
   arp_util.debug('attribute6          : '||p_desc_flex_rec.attribute6);
   arp_util.debug('attribute7          : '||p_desc_flex_rec.attribute7);
   arp_util.debug('attribute8          : '||p_desc_flex_rec.attribute8);
   arp_util.debug('attribute9          : '||p_desc_flex_rec.attribute9);
   arp_util.debug('attribute10         : '||p_desc_flex_rec.attribute10);
   arp_util.debug('attribute11         : '||p_desc_flex_rec.attribute11);
   arp_util.debug('attribute12         : '||p_desc_flex_rec.attribute12);
   arp_util.debug('attribute13         : '||p_desc_flex_rec.attribute13);
   arp_util.debug('attribute14         : '||p_desc_flex_rec.attribute14);
   arp_util.debug('attribute15         : '||p_desc_flex_rec.attribute15);
   arp_util.debug('ar_deposit_lib_pvt.Validate_Desc_Flexfield() -' );

IF p_desc_flex_name = 'RA_CUSTOMER_TRX' THEN /* bug 5467021 if-else condition added and get_flex_title called in set_token*/

	fnd_flex_descval.set_context_value(p_desc_flex_rec.attribute_category);
	fnd_flex_descval.set_column_value('ATTRIBUTE1', p_desc_flex_rec.attribute1);
	fnd_flex_descval.set_column_value('ATTRIBUTE2', p_desc_flex_rec.attribute2);
	fnd_flex_descval.set_column_value('ATTRIBUTE3', p_desc_flex_rec.attribute3);
	fnd_flex_descval.set_column_value('ATTRIBUTE4', p_desc_flex_rec.attribute4);
	fnd_flex_descval.set_column_value('ATTRIBUTE5', p_desc_flex_rec.attribute5);
	fnd_flex_descval.set_column_value('ATTRIBUTE6', p_desc_flex_rec.attribute6);
	fnd_flex_descval.set_column_value('ATTRIBUTE7', p_desc_flex_rec.attribute7);
	fnd_flex_descval.set_column_value('ATTRIBUTE8', p_desc_flex_rec.attribute8);
	fnd_flex_descval.set_column_value('ATTRIBUTE9', p_desc_flex_rec.attribute9);
	fnd_flex_descval.set_column_value('ATTRIBUTE10', p_desc_flex_rec.attribute10);
	fnd_flex_descval.set_column_value('ATTRIBUTE11',p_desc_flex_rec.attribute11);
	fnd_flex_descval.set_column_value('ATTRIBUTE12', p_desc_flex_rec.attribute12);
	fnd_flex_descval.set_column_value('ATTRIBUTE13', p_desc_flex_rec.attribute13);
	fnd_flex_descval.set_column_value('ATTRIBUTE14', p_desc_flex_rec.attribute14);
	fnd_flex_descval.set_column_value('ATTRIBUTE15', p_desc_flex_rec.attribute15);
   IF ( NOT fnd_flex_descval.validate_desccols('AR',p_desc_flex_name,'I') ) /*Bug 3291481*/
     THEN

       FND_MESSAGE.SET_NAME('AR', 'AR_RAPI_DESC_FLEX_INVALID');
--     FND_MESSAGE.SET_TOKEN('DFF_NAME',p_desc_flex_name);
       FND_MESSAGE.SET_TOKEN('DFF_NAME',p_desc_flex_name||' - Flex Field Name : "' ||get_flex_title('RA_CUSTOMER_TRX')||'"');
       FND_MSG_PUB.ADD ;
       p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

      l_count := fnd_flex_descval.segment_count;

      FOR i in 1..l_count LOOP
        l_col_name := fnd_flex_descval.segment_column_name(i);

/*Bug 3291481, replaced fnd_flex_descval.segment_value with fnd_flex_descval.segment_id*/

	IF l_col_name = 'ATTRIBUTE1' THEN
          p_desc_flex_rec.attribute1 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE_CATEGORY'  THEN
        p_desc_flex_rec.attribute_category := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE2' THEN
          p_desc_flex_rec.attribute2 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE3' THEN
          p_desc_flex_rec.attribute3 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE4' THEN
          p_desc_flex_rec.attribute4 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE5' THEN
          p_desc_flex_rec.attribute5 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE6' THEN
          p_desc_flex_rec.attribute6 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE7' THEN
          p_desc_flex_rec.attribute7 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE8' THEN
          p_desc_flex_rec.attribute8 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE9' THEN
          p_desc_flex_rec.attribute9 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE10' THEN
          p_desc_flex_rec.attribute10 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE11' THEN
          p_desc_flex_rec.attribute11 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE12' THEN
          p_desc_flex_rec.attribute12 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE13' THEN
          p_desc_flex_rec.attribute13 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE14' THEN
          p_desc_flex_rec.attribute14 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE15' THEN
          p_desc_flex_rec.attribute15 := fnd_flex_descval.segment_id(i);
        END IF;

        IF i > l_count  THEN
          EXIT;
        END IF;
       END LOOP;
   /* Below coded added for bug 5467021. Assigning appropriate columns values based on flex field name before call to fnd api for validation  */

  ELSIF p_desc_flex_name = 'RA_INTERFACE_HEADER' THEN
           fnd_flex_descval.set_context_value(p_desc_flex_rec.attribute_category);

        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE1',
                                p_desc_flex_rec.attribute1);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE2',
                                p_desc_flex_rec.attribute2);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE3',
                                p_desc_flex_rec.attribute3);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE4',
                                p_desc_flex_rec.attribute4);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE5',
                                p_desc_flex_rec.attribute5);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE6',
                                p_desc_flex_rec.attribute6);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE7',
                                p_desc_flex_rec.attribute7);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE8',
                                p_desc_flex_rec.attribute8);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE9',
                                p_desc_flex_rec.attribute9);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE10',
                                p_desc_flex_rec.attribute10);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE11',
                                p_desc_flex_rec.attribute11);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE12',
                                p_desc_flex_rec.attribute12);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE13',
                                p_desc_flex_rec.attribute13);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE14',
                                p_desc_flex_rec.attribute14);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE15',
                                p_desc_flex_rec.attribute15);


        IF ( NOT fnd_flex_descval.validate_desccols('AR',p_desc_flex_name,'I') )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'AR_RAPI_DESC_FLEX_INVALID');
            FND_MESSAGE.SET_TOKEN('DFF_NAME',p_desc_flex_name||' - Flex Field Name : "' ||get_flex_title('RA_INTERFACE_HEADER')||'"');
            FND_MSG_PUB.ADD ;
            p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_count := fnd_flex_descval.segment_count;


        FOR i in 1..l_count LOOP
            l_col_name := fnd_flex_descval.segment_column_name(i);

            IF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE1' THEN
                p_desc_flex_rec.attribute1 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_CONTEXT'  THEN
                p_desc_flex_rec.attribute_category := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE2' THEN
                p_desc_flex_rec.attribute2 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE3' THEN
                p_desc_flex_rec.attribute3 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE4' THEN
                p_desc_flex_rec.attribute4 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE5' THEN
                p_desc_flex_rec.attribute5 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE6' THEN
                p_desc_flex_rec.attribute6 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE7' THEN
                p_desc_flex_rec.attribute7 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE8' THEN
                p_desc_flex_rec.attribute8 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE9' THEN
                p_desc_flex_rec.attribute9 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE10' THEN
                p_desc_flex_rec.attribute10 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE11' THEN
                p_desc_flex_rec.attribute11 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE12' THEN
                p_desc_flex_rec.attribute12 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE13' THEN
                p_desc_flex_rec.attribute13 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE14' THEN
                p_desc_flex_rec.attribute14 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE15' THEN
                p_desc_flex_rec.attribute15 := fnd_flex_descval.segment_id(i);
            END IF;

            IF i > l_count  THEN
                EXIT;
            END IF;
        END LOOP;

  ELSIF p_desc_flex_name = 'RA_INTERFACE_LINES' THEN
           fnd_flex_descval.set_context_value(p_desc_flex_rec.attribute_category);

        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE1',
                                p_desc_flex_rec.attribute1);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE2',
                                p_desc_flex_rec.attribute2);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE3',
                                p_desc_flex_rec.attribute3);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE4',
                                p_desc_flex_rec.attribute4);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE5',
                                p_desc_flex_rec.attribute5);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE6',
                                p_desc_flex_rec.attribute6);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE7',
                                p_desc_flex_rec.attribute7);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE8',
                                p_desc_flex_rec.attribute8);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE9',
                                p_desc_flex_rec.attribute9);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE10',
                                p_desc_flex_rec.attribute10);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE11',
                                p_desc_flex_rec.attribute11);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE12',
                                p_desc_flex_rec.attribute12);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE13',
                                p_desc_flex_rec.attribute13);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE14',
                                p_desc_flex_rec.attribute14);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE15',
                                p_desc_flex_rec.attribute15);


        IF ( NOT fnd_flex_descval.validate_desccols('AR',p_desc_flex_name,'I') )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'AR_RAPI_DESC_FLEX_INVALID');
            FND_MESSAGE.SET_TOKEN('DFF_NAME',p_desc_flex_name||' - Flex Field Name : "' ||get_flex_title('RA_INTERFACE_LINES')||'"');
            FND_MSG_PUB.ADD ;
            p_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;

        l_count := fnd_flex_descval.segment_count;


        FOR i in 1..l_count LOOP
            l_col_name := fnd_flex_descval.segment_column_name(i);

            IF l_col_name = 'INTERFACE_LINE_ATTRIBUTE1' THEN
                p_desc_flex_rec.attribute1 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_CONTEXT'  THEN
                p_desc_flex_rec.attribute_category := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE2' THEN
                p_desc_flex_rec.attribute2 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE3' THEN
                p_desc_flex_rec.attribute3 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE4' THEN
                p_desc_flex_rec.attribute4 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE5' THEN
                p_desc_flex_rec.attribute5 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE6' THEN
                p_desc_flex_rec.attribute6 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE7' THEN
                p_desc_flex_rec.attribute7 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE8' THEN
                p_desc_flex_rec.attribute8 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE9' THEN
                p_desc_flex_rec.attribute9 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE10' THEN
                p_desc_flex_rec.attribute10 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE11' THEN
                p_desc_flex_rec.attribute11 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE12' THEN
                p_desc_flex_rec.attribute12 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE13' THEN
                p_desc_flex_rec.attribute13 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE14' THEN
                p_desc_flex_rec.attribute14 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE15' THEN
                p_desc_flex_rec.attribute15 := fnd_flex_descval.segment_id(i);
            END IF;

            IF i > l_count  THEN
                EXIT;
            END IF;
        END LOOP;


 END IF;/* End p_desc_flex_name=  */
   /* bug 5467021 ends */

   arp_util.debug('attribute_category  : '||p_desc_flex_rec.attribute_category);
   arp_util.debug('attribute1          : '||p_desc_flex_rec.attribute1);
   arp_util.debug('attribute2          : '||p_desc_flex_rec.attribute2);
   arp_util.debug('attribute3          : '||p_desc_flex_rec.attribute3);
   arp_util.debug('attribute4          : '||p_desc_flex_rec.attribute4);
   arp_util.debug('attribute5          : '||p_desc_flex_rec.attribute5);
   arp_util.debug('attribute6          : '||p_desc_flex_rec.attribute6);
   arp_util.debug('attribute7          : '||p_desc_flex_rec.attribute7);
   arp_util.debug('attribute8          : '||p_desc_flex_rec.attribute8);
   arp_util.debug('attribute9          : '||p_desc_flex_rec.attribute9);
   arp_util.debug('attribute10         : '||p_desc_flex_rec.attribute10);
   arp_util.debug('attribute11         : '||p_desc_flex_rec.attribute11);
   arp_util.debug('attribute12         : '||p_desc_flex_rec.attribute12);
   arp_util.debug('attribute13         : '||p_desc_flex_rec.attribute13);
   arp_util.debug('attribute14         : '||p_desc_flex_rec.attribute14);
   arp_util.debug('attribute15         : '||p_desc_flex_rec.attribute15);
  arp_util.debug('ar_deposit_lib_pvt.Validate_Desc_Flexfield() -' );
END Validate_Desc_Flexfield;

END ar_deposit_lib_pvt;


/
