--------------------------------------------------------
--  DDL for Package Body ARP_CMERGE_ARCUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CMERGE_ARCUS" AS
/*$Header: ARHCMGNB.pls 120.39.12010000.8 2009/06/26 06:56:34 vsegu ship $*/

g_count		           NUMBER := 0;

--migrating contacts and contact points
procedure do_merge_contacts (
        p_level                      VARCHAR2,
        p_from_account_id            NUMBER,
        p_org_party_id               NUMBER,
        p_org_party_rel_id           NUMBER,
        p_org_contact_id             NUMBER,
        p_to_party_id                NUMBER,
        x_org_party_id           OUT NOCOPY NUMBER,
        p_to_party_site_id           NUMBER DEFAULT NULL );

--account level migrating org contacts
procedure do_cust_merge_contacts (
        p_from_party_id              NUMBER,
        p_to_party_id                NUMBER,
        p_from_account_id            NUMBER,
        p_to_account_id              NUMBER
);

--site level migrating org contacts
procedure do_site_merge_contacts (
        p_from_party_id              NUMBER,
        p_to_party_id                NUMBER,
        p_from_account_id            NUMBER,
        p_to_account_id              NUMBER,
        p_req_id                     NUMBER,
        p_set_num                    NUMBER
);

--migrating contact points
procedure do_copy_contact_points (
        p_owner_table_name           VARCHAR2,
        p_from_id                    NUMBER,
        p_to_id                      NUMBER,
        p_from_account_id            NUMBER
);

--check duplicate org contact
function check_org_contact_dup (
        p_from_org_contact_id        NUMBER,
        p_from_party_rel_id          NUMBER,
        p_to_party_id                NUMBER,
        x_org_contact_id        OUT NOCOPY  NUMBER ,
        p_from_account_id            NUMBER)
return VARCHAR2;

--check duplicate contact point
function check_contact_point_dup (
        p_from_contact_point_id      NUMBER,
        p_to_owner_table_id          NUMBER,
        x_contact_point_id      OUT NOCOPY  NUMBER )
return VARCHAR2;

--account level migrating contact points
procedure do_cust_merge_cpoint (
        p_from_party_id              NUMBER,
        p_to_party_id                NUMBER,
        p_from_account_id            NUMBER,
        p_to_account_id              NUMBER
);

--site level migrating contact points
procedure do_site_merge_cpoint (
        p_from_party_site_id         NUMBER,
        p_to_party_site_id           NUMBER,
        p_from_account_id            NUMBER,
        p_to_account_id              NUMBER
);

--migrate contacts
procedure copy_contacts (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);

--migrate contacts in sites
procedure copy_contacts_in_sites (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);
procedure ra_bill_to_location (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);
--merge account site uses.
procedure ra_su (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);

--merge account sites.
procedure ra_addr (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);

--merge accounts.
procedure ra_cust (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);

--merge customer account roles.
procedure ra_cont (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);

--merge account relate.
procedure ra_cr (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);

--merge customer receipt methods.
procedure ra_crm (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);

--merge customer contact points.
procedure ra_ph (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);

--Inactivate CUSTOMER usages.
procedure ra_usg (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);

/*===========================================================================+
 | PROCEDURE
 |              merge
 |
 | DESCRIPTION
 |              main merge routine.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  26-OCT-00  Bug 1415529: call copy_contacts before
 |                        ra_addr and ra_cust. Otherwise, ra_cont and
 |                        ra_ph throw 'no data found' exception when
 |                        they try to use account id get party id or
 |                        use account site id get party site id because
 |                        account site id has been deleted by ra_addr
 |                        and account id has been deleted by ra_cust.
 |     Jianying Huang  17-DEC-00  Bug 1535542: Since we will not physically
 |                        delete rows till the end of merge, we can move
 |                        the call of 'copy_contacts' right before we migrate
 |                        org contacts and contact points.
 |
 +===========================================================================*/

PROCEDURE merge (
          req_id                NUMBER,
          set_num               NUMBER,
          process_mode          VARCHAR2
) IS

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.MERGE()+' );
    --merge account site uses
    ra_su( req_id, set_num, process_mode );

    --merge account sites
    ra_addr( req_id, set_num, process_mode );

    --merge accounts
    ra_cust( req_id, set_num, process_mode );

    --merge account relate
    ra_cr( req_id, set_num, process_mode );

    -- For bill_to_location
    ra_bill_to_location(req_id, set_num, process_mode );

    --merge customer receipt methods
    ra_crm( req_id, set_num, process_mode );

    --4307679 Inactivate usages 'CUSTOMER'
    ra_usg(req_id, set_num, process_mode );

--because of bug 1535542, we will not physically delete rows in
--account tables until merge is done for one set.

/**N/A
--Bug 1415529: call copy_contacts before ra_addr and ra_cust.
--Otherwise, ra_cont and ra_ph throw 'no data found' exception
--when they try to use account id get party id or use
--account site id get party site id because account site id
--has been deleted by ra_addr and account id has been deleted
--by ra_cust .
**/

    --should not be run in 'LOCK' mood
    IF ( process_mode <> 'LOCK' )
    THEN
       --migrate contact points for org contact and account contacts.
       copy_contacts( req_id, set_num, process_mode );

       --migrate contact points in site level.
       copy_contacts_in_sites( req_id, set_num, process_mode );
    END IF;

    --merge org contact
    ra_cont( req_id, set_num, process_mode );

    --the procedure ra_ph is not being called anymore because table
    --hz_cust_contact_points has been obsoleted.
    --merge contact points: phone
    --ra_ph( req_id, set_num, process_mode );

    arp_message.set_line( 'ARP_CMERGE_ARCUS.MERGE()-' );

END merge;
/*===========================================================================+
 | PROCEDURE
 |              ra_bill_to_location
 |
 | DESCRIPTION
 |              merge in HZ_CUST_SITE_USES.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     P.Suresh         03-25-02              Bug No : 2272750 Created.
 |     P.Suresh         04-05-02              Bug No : 2272750. Modified the
 |                                            update statements for better
 |                                            performance.
 +===========================================================================*/
 PROCEDURE ra_bill_to_location (
          req_id                NUMBER,
          set_num               NUMBER,
          process_mode          VARCHAR2
) IS

    CURSOR c1 IS
        SELECT merge.duplicate_site_id,merge.customer_site_id,
               cust.bill_to_site_use_id,merge.duplicate_site_code,
               merge.customer_createsame,cust.org_id --SSUptake
        FROM hz_cust_site_uses_all cust, ra_customer_merges merge --SSUptake
        WHERE merge.request_id = req_id
        AND   merge.set_number = set_num
	AND   merge.process_flag = 'N'
	AND   cust.site_use_id = merge.duplicate_site_id
        AND   cust.org_id      = merge.org_id    --SSUptake
        FOR UPDATE NOWAIT;
   l_dup_site_id           NUMBER;
   l_cust_site_id          NUMBER;
   l_site_use_code         VARCHAR2(30);
   l_bill_to_site_use_id      NUMBER;
   l_create_same_site      VARCHAR2(30);
   l_ra_bill_to_site_use_id   NUMBER;

   l_org_id                NUMBER(15);

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_BILL_TO_LOCATION()+' );
 OPEN c1;
    LOOP
        FETCH c1 INTO l_dup_site_id,l_cust_site_id,l_bill_to_site_use_id,
                      l_site_use_code,l_create_same_site,l_org_id; --SSUptake
       EXIT WHEN c1%NOTFOUND;

      IF l_site_use_code = 'SHIP_TO' and l_create_same_site = 'Y' THEN
         IF l_bill_to_site_use_id IS NOT NULL THEN
             BEGIN
                  select customer_site_id into l_ra_bill_to_site_use_id
                  from   ra_customer_merges
                  where  duplicate_site_id  = l_bill_to_site_use_id
                  and    process_flag = 'N'
                  and    request_id   = req_id
                  and    set_number   = set_num;
             EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       l_ra_bill_to_site_use_id := l_bill_to_site_use_id;
             END;
             update  hz_cust_site_uses_all --SSUptake
             set     bill_to_site_use_id = l_ra_bill_to_site_use_id
             where   site_use_id = l_cust_site_id
	     and     org_id      = l_org_id; --SSUptake
         END IF;
      ELSIF  l_site_use_code = 'BILL_TO' THEN
             update  hz_cust_site_uses_all --SSUptake
             set     bill_to_site_use_id = l_cust_site_id
	     where   org_id = l_org_id --SSUptake
             and     site_use_id in (
                          SELECT site_use_id
                          FROM   hz_cust_site_uses_all su, --SSUptake
                                 hz_cust_acct_sites_all site --SSUptake
                          WHERE su.org_id         = l_org_id --SSUptake
			  AND   su.org_id         = site.org_id --SSUptake
                          AND   site.cust_acct_site_id = su.cust_acct_site_id
                          AND   su.site_use_code='SHIP_TO'
                          AND   su.bill_to_site_use_id = l_dup_site_id
			  AND   site.cust_account_id in (
                                  SELECT unique(customer_id)
                                  FROM ra_customer_merges merge
                                  WHERE merge.process_flag = 'N'
                                  and merge.request_id = req_id
                                  and merge.set_number = set_num
				  and merge.org_id     = site.org_id --SSUptake
				  UNION
				  SELECT related_cust_account_id
				  FROM   hz_cust_acct_relate_all rel --SSUptake
				  WHERE  rel.org_id = l_org_id --SSUptake
				  AND    rel.cust_account_id in (
					 select unique(customer_id)
					 from ra_customer_merges merge
					 where merge.process_flag = 'N'
					 and merge.request_id = req_id
					 and merge.set_number = set_num
					 and merge.org_id     = rel.org_id )  --SSUptake
                                )
		     );
      END IF;


  END LOOP;
 CLOSE c1;
    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_BILL_TO_LOCATION()-' );
END;
/*===========================================================================+
 | PROCEDURE
 |              ra_su
 |
 | DESCRIPTION
 |              merge in HZ_CUST_SITE_USES.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  25-OCT-00  Modified cursor c2 and c4.
 |                        Since we only allow merging active sites uses,
 |                        the cursors always returned 'no row'.
 |     Jianying Huang  12-DEC-00  Remove cursor c1 and c3. They are sub-cursor
 |                        of c2 and c4.
 |     Jianying Huang  20-DEC-00  Bug 1535542: Since we need to change
 |                        the merging order, merge HZ tables before merging
 |                        products, we need to mark deleted rows here
 |                        first and physically delete them after merging one
 |                        set in 'delete_rows'.
 |     Jianying Huang  08-MAR-01  Bug 1610924: Modified the procedure based on
 |                        the new om enhancement: allow merging all of the site uses
 |                        of a customer.
 |
 +===========================================================================*/

PROCEDURE ra_su (
          req_id                NUMBER,
          set_num               NUMBER,
          process_mode          VARCHAR2
) IS

    l_orig_system_ref_rec          HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
    x_object_version_number   	   NUMBER;
    x_return_status   VARCHAR2(30);
    x_msg_count 	  NUMBER;
    x_msg_data		  VARCHAR2(2000);
    x_site_use_id      NUMBER;
    x_orig_system_reference VARCHAR2(255);
    x_orig_system     VARCHAR2(30);
    x_orig_system_ref_id      NUMBER;
    x_from_site_id     NUMBER;
    x_to_site_id       NUMBER;

    CURSOR c1 IS
        SELECT site_use_id
        FROM hz_cust_site_uses_all su, ra_customer_merges m --SSUptake
	WHERE m.request_id = req_id
        AND   m.process_flag = 'N'
        AND   m.set_number = set_num
        AND   m.org_id     = su.org_id --SSUptake
	AND   su.cust_acct_site_id = m.duplicate_address_id
        FOR UPDATE NOWAIT;


        CURSOR c2 is
                SELECT distinct(m.customer_site_id), m.duplicate_site_id
                FROM   ra_customer_merges m
                WHERE  m.process_flag = 'N'
		AND    m.request_id = req_id
                AND    m.set_number = set_num
                AND    (m.delete_duplicate_flag = 'N' OR m.delete_duplicate_flag = 'Y');

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_SU()+' );

    /* locking tables by opening and closing cursors */
    IF process_mode = 'LOCK' THEN

       arp_message.set_name( 'AR', 'AR_LOCKING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_SITE_USES', FALSE );

       OPEN c1;
       CLOSE c1;

    ELSE

       /*************** 'inactivate' mode ***************/

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_SITE_USES', FALSE );

       --inactivate customer account site uses.

       UPDATE HZ_CUST_SITE_USES_ALL yt  --SSUptake
       SET status = 'I',
           last_update_date = sysdate,
           last_updated_by =hz_utility_v2pub.user_id,-- arp_standard.profile.user_id,
           last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
           request_id =  req_id,
           program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
           program_id =hz_utility_v2pub.program_id,-- arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE EXISTS  (
                        SELECT 'Y'
                        FROM   ra_customer_merges m
                        WHERE  m.duplicate_site_id = yt.site_use_id
			AND    m.org_id  = yt.org_id
			AND    m.process_flag = 'N'
			AND    m.request_id = req_id
                        AND    m.set_number = set_num
                        AND    m.delete_duplicate_flag = 'N' );

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

--Bug 7758559

	arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_SITE_USES', FALSE );

       UPDATE hz_cust_site_uses_all asu
      SET primary_flag = 'Y',
          last_update_date = SYSDATE,
          last_updated_by = arp_standard.PROFILE.user_id,
          last_update_login = arp_standard.PROFILE.last_update_login,
          request_id =  req_id,
          program_application_id = arp_standard.PROFILE.program_application_id,
          program_id = arp_standard.PROFILE.program_id,
          program_update_date = SYSDATE
      WHERE asu.site_use_id IN( SELECT customer_site_id
			        FROM ra_customer_merges m
                                WHERE m.request_id = req_id
	      		        AND   m.set_number = set_num
			        AND  m.customer_createsame = 'N'
				AND  m.org_id = asu.org_id
			        AND  m.process_flag = 'N'
				AND m.duplicate_primary_flag = 'Y'
                                AND not exists (SELECT 'EXISTS'
	                     			FROM hz_cust_acct_sites_all s, hz_cust_site_uses_all su
			      			WHERE s.cust_account_id = m.customer_id
			     			AND su.cust_acct_site_id = s.cust_acct_site_id
					        AND s.org_id = m.org_id
						AND su.org_id = s.org_id
			      			AND su.site_use_code = m.duplicate_site_code
			      			AND su.primary_flag = 'Y'
                              			AND su.status = 'A'));
	g_count := sql%rowcount;
	arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
	arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


/** Bug 1610924: comment out the following code because of new om enhancement:
    allow merging all of the site uses of a customer.

       --Inactivate non-transaction site uses if no active ship_to,
       --bill_to or market site uses remain for the account site.

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_SITE_USES', FALSE );

       UPDATE HZ_CUST_SITE_USES su1
       SET status = 'I',
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id =  req_id,
           program_application_id = arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE cust_acct_site_id IN (
                            SELECT m.duplicate_address_id
			    FROM   ra_customer_merges m
                            WHERE  m.process_flag = 'N'
			    AND    m.request_id = req_id
                            AND    m.set_number = set_num
			    AND    m.delete_duplicate_flag = 'N' )
       AND site_use_code NOT IN ('BILL_TO', 'SHIP_TO', 'MARKET' )
       AND NOT EXISTS (
                            SELECT 'active bill/ship/market site uses exist'
			    FROM   HZ_CUST_SITE_USES su
		            WHERE  su.cust_acct_site_id = su1.cust_acct_site_id
			    AND    su.site_use_code IN
                                       ( 'BILL_TO','SHIP_TO', 'MARKET' )
			    AND    status = 'A' );

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

**/

       /*************** 'delete' mode ***************/

--Bug 1535542: Mark the rows need to be deleted by setting status to 'D'.
--Physically delete them after merge.

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_SITE_USES', FALSE );

       UPDATE HZ_CUST_SITE_USES_ALL yt
       SET status = 'D'
       WHERE EXISTS  (
                        SELECT 'Y'
                        FROM   ra_customer_merges m
                        WHERE  m.duplicate_site_id = yt.site_use_id
			AND    m.org_id  = yt.org_id
			AND    m.process_flag = 'N'
			AND    m.request_id = req_id
                        AND    m.set_number = set_num
                        AND    m.delete_duplicate_flag = 'Y' );

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

/** Bug 1610924: comment out the following code because of new om enhancement:
    allow merging all of the site uses of a customer.

       --'Delete' non-transaction site uses if no ship_to,
       --bill_to, market site uses remain for the account site.

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_SITE_USES', FALSE );

       UPDATE HZ_CUST_SITE_USES su1
       SET status = 'D'
       WHERE cust_acct_site_id IN (
                            SELECT m.duplicate_address_id
			    FROM   ra_customer_merges m
                            WHERE  m.process_flag = 'N'
			    AND    m.request_id = req_id
                            AND    m.set_number = set_num
			    AND    m.delete_duplicate_flag = 'Y' )
       AND site_use_code NOT IN ('BILL_TO', 'SHIP_TO', 'MARKET' )
       AND NOT EXISTS (
                            SELECT 'bill/ship/market site uses exist'
			    FROM   HZ_CUST_SITE_USES su
		            WHERE  su.cust_acct_site_id = su1.cust_acct_site_id
			    AND    su.site_use_code IN
                                       ( 'BILL_TO', 'SHIP_TO', 'MARKET' )
			    AND    status <> 'D' );

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
**/

    END IF;
    open c2;
     loop
     fetch c2 into x_to_site_id, x_from_site_id;
     EXIT WHEN c2%NOTFOUND;
      HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => x_from_site_id,
	                p_new_owner_table_id   => x_to_site_id,
                    p_owner_table_name  =>'HZ_CUST_SITE_USES_ALL',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>x_msg_count,
                    x_msg_data  =>x_msg_data);
             --Handle error message
             IF x_msg_count = 1 THEN
                x_msg_data := x_msg_data || '**remap internal id**';
                arp_message.set_line(
                    'MOSR:remap internal id  ERROR '||
                    x_msg_data);
             ELSIF x_msg_count > 1 THEN

                FOR x IN 1..x_msg_count LOOP
                    x_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                    x_msg_data := x_msg_data || '**remap internal id**';
                    arp_message.set_line(
                        'MOSR:remap internal id  ERROR ' ||
                        x_msg_data );
                END LOOP;
             END IF;

             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
             END IF;

     end loop;
    close c2;

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_SU()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.RA_SU' );
      RAISE;

END ra_su;

/*===========================================================================+
 | PROCEDURE
 |              ra_addr
 |
 | DESCRIPTION
 |              merge in HZ_CUST_SITES.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  25-OCT-00  Remove cursor c1. Use c3 replace c1.
 |                        c1 requires sub-set rows of c3.
 |     Jianying Huang  20-DEC-00  Bug 1535542: Since we need to change
 |                        the merging order, merge HZ tables before merging
 |                        products, we need to mark deleted rows here
 |                        first and physically delete them after merging one
 |                        set in 'delete_rows'.
 |
 +===========================================================================*/

PROCEDURE ra_addr (
          req_id                NUMBER,
          set_num               NUMBER,
          process_mode          VARCHAR2
) IS

    l_orig_system_ref_rec          HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
    x_object_version_number   	   NUMBER;
    x_return_status   VARCHAR2(30);
    x_msg_count 	  NUMBER;
    x_msg_data		  VARCHAR2(2000);
    x_cust_acct_site_id      NUMBER;
    x_orig_system_reference VARCHAR2(255);
    x_orig_system     VARCHAR2(30);
    x_orig_system_ref_id      NUMBER;
    x_to_address_id              NUMBER;
    x_from_address_id            NUMBER;

    --cursor c1 is used in 'inactivate' mode.
    CURSOR c1 IS
        SELECT yt.cust_acct_site_id
        FROM   hz_cust_acct_sites_all yt, ra_customer_merges m --SSUptake
        WHERE  yt.cust_acct_site_id = m.duplicate_address_id
	AND    m.org_id = yt.org_id --SSUptake
	AND    m.request_id = req_id
	AND    m.process_flag = 'N'
	AND    m.set_number = set_num
        AND    m.delete_duplicate_flag = 'N'
        AND NOT EXISTS (
                         SELECT 'active site uses exist'
                         FROM   HZ_CUST_SITE_USES_ALL su --SSUptake
                         WHERE  su.org_id = yt.org_id --SSUptake
			 AND    su.cust_acct_site_id = yt.cust_acct_site_id
                         AND    su.status = 'A' )
        FOR UPDATE NOWAIT;

    --cursor c2 is used in 'delete' mode.
    CURSOR c2 IS
        SELECT yt.cust_acct_site_id
        FROM   hz_cust_acct_sites_all yt, ra_customer_merges m --SSUptake
        WHERE  m.request_id = req_id
        AND    m.process_flag = 'N'
        AND    m.set_number = set_num
        AND    m.delete_duplicate_flag = 'Y'
	AND    m.org_id = yt.org_id --SSUptake
	AND    yt.cust_acct_site_id = m.duplicate_address_id
        AND NOT EXISTS (
                         SELECT 'site uses exist'
                         FROM   HZ_CUST_SITE_USES_ALL su --SSUptake
                         WHERE  su.cust_acct_site_id = yt.cust_acct_site_id
			 AND    su.org_id = yt.org_id --SSUptake
                         AND    su.status <> 'D' )
        FOR UPDATE NOWAIT;

        cursor c3 is
         SELECT distinct(m.customer_address_id), m.duplicate_address_id
         FROM   ra_customer_merges m
         WHERE  m.process_flag = 'N'
	 AND    m.request_id = req_id
	 AND    m.set_number = set_num
         AND    (m.delete_duplicate_flag = 'N' or m.delete_duplicate_flag = 'Y') --5571559
         AND    NOT EXISTS (SELECT 'site uses exist'
                         FROM   HZ_CUST_SITE_USES_ALL su --SSUptake
                         WHERE  su.org_id  = m.org_id --SSUptake
			 AND    su.cust_acct_site_id = m.duplicate_address_id
                         AND    su.status = 'A' );



BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_ADDR()+' );

    /* locking tables by opening and closing cursors */
    IF process_mode = 'LOCK' THEN

       arp_message.set_name( 'AR', 'AR_LOCKING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_SITES', FALSE );

       OPEN c1;
       CLOSE c1;

       OPEN c2;
       CLOSE c2;

    ELSE

       /*************** 'inactivate' mode ***************/

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_SITES', FALSE );

       --inactivate customer account site

       UPDATE HZ_CUST_ACCT_SITES_ALL yt --SSUptake
       SET status = 'I',
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
           last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
           request_id =  req_id,
           program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
           program_id =hz_utility_v2pub.program_id,-- arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE EXISTS  (
                      SELECT 'Y'
                      FROM   ra_customer_merges m
                      WHERE  m.process_flag = 'N'
	              AND    m.request_id = req_id
		      AND    m.set_number = set_num
                      AND    m.delete_duplicate_flag = 'N'
		      AND    m.duplicate_address_id = yt.cust_acct_site_id
		      AND    m.org_id    = yt.org_id) --SSUptake
       AND NOT EXISTS (
                      SELECT 'active site uses exist'
                      FROM   HZ_CUST_SITE_USES_ALL su
                      WHERE  su.cust_acct_site_id = yt.cust_acct_site_id
		      AND    su.org_id   = yt.org_id
                      AND    su.status = 'A' );

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       --Update bill_to_flag

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_SITES', FALSE );

       UPDATE HZ_CUST_ACCT_SITES_ALL yt --SSUptake
       SET bill_to_flag = null,
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
           last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
           request_id =  req_id,
           program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
           program_id =hz_utility_v2pub.program_id,-- arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE EXISTS (
                      SELECT 'Y'
                      FROM   ra_customer_merges m
                      WHERE  m.process_flag = 'N'
		      AND    m.request_id = req_id
		      AND    m.set_number = set_num
		      AND    m.duplicate_address_id = yt.cust_acct_site_id
		      AND    m.org_id  = yt.org_id
                      AND    m.delete_duplicate_flag = 'N' )
       AND NOT EXISTS (
                      SELECT 'no active bill to'
                      FROM   HZ_CUST_SITE_USES_ALL s --SSUptake
                      WHERE  s.cust_acct_site_id = yt.cust_acct_site_id
		      AND    s.org_id  = yt.org_id
                      AND    s.site_use_code = 'BILL_TO'
                      AND    status = 'A' )
       AND NVL(bill_to_flag, 'N') <> 'N';

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       --Update ship_to_flag

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_SITES', FALSE );

       UPDATE HZ_CUST_ACCT_SITES_ALL yt --SSUptake
       SET ship_to_flag = null,
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
           last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
           request_id =  req_id,
           program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
           program_id =hz_utility_v2pub.program_id,-- arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE  EXISTS (
                      SELECT 'Y'
                      FROM   ra_customer_merges m
                      WHERE  m.process_flag = 'N'
		      AND    m.request_id = req_id
		      AND    m.set_number = set_num
                      AND    m.delete_duplicate_flag = 'N'
		      AND    m.duplicate_address_id = yt.cust_acct_site_id
		      AND    m.org_id   = yt.org_id )
       AND NOT EXISTS (
                      SELECT 'no active ship to'
                      FROM   HZ_CUST_SITE_USES_ALL s --SSUptake
                      WHERE  s.cust_acct_site_id = yt.cust_acct_site_id
		      AND    s.org_id = yt.org_id
                      AND    s.site_use_code = 'SHIP_TO'
                      AND    status = 'A' )
       AND NVL(ship_to_flag, 'N') <> 'N';

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       --Update market_flag

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_SITES', FALSE );

       UPDATE HZ_CUST_ACCT_SITES_ALL yt --SSUptake
       SET market_flag = null,
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
           last_update_login = hz_utility_v2pub.last_update_login,--arp_standard.profile.last_update_login,
           request_id =  req_id,
           program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
           program_id =hz_utility_v2pub.program_id,-- arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE EXISTS (
                      SELECT 'Y'
                      FROM   ra_customer_merges m
                      WHERE  m.process_flag = 'N'
		      AND    m.request_id = req_id
		      AND    m.set_number = set_num
                      AND    m.delete_duplicate_flag = 'N'
		      AND    m.org_id = yt.org_id
		      AND    m.duplicate_address_id = yt.cust_acct_site_id)
       AND NOT EXISTS (
                      SELECT 'no active market site'
                      FROM   HZ_CUST_SITE_USES_ALL s --SSUptake
                      WHERE  s.cust_acct_site_id = yt.cust_acct_site_id
		      AND    s.org_id = yt.org_id
                      AND    s.site_use_code = 'MARKET'
                      AND    status = 'A' )
       AND NVL(market_flag, 'N') <> 'N';

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

--Bug 7758559

               UPDATE hz_cust_acct_sites_all yt
	SET bill_to_flag = 'P',
	    last_update_date = sysdate,
            last_updated_by = arp_standard.profile.user_id,
            last_update_login = arp_standard.profile.last_update_login,
            request_id =  req_id,
            program_application_id = arp_standard.profile.program_application_id,
            program_id = arp_standard.profile.program_id,
            program_update_date = sysdate
	WHERE EXISTS (	SELECT 1
 	    	      	FROM hz_cust_site_uses_all su, ra_customer_merges m
	              	WHERE m.request_id = req_id
		        AND   m.set_number = set_num
	     		AND  m.customer_createsame = 'N'
	     		AND  m.process_flag = 'N'
             		AND m.duplicate_primary_flag = 'Y'
             		AND yt.cust_acct_site_id = m.customer_address_id
	     		AND su.site_use_code = 'BILL_TO'
	     		AND su.site_use_code = m.customer_site_code
	     		AND su.site_use_id = m.customer_site_id
	     		AND su.primary_flag = 'Y'
            		AND su.request_id = req_id
			AND yt.org_id = m.org_id
		        AND su.org_id = m.org_id);

	g_count := sql%rowcount;

	arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
	arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

	arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
	arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_SITES', FALSE );

	UPDATE hz_cust_acct_sites_all yt
	SET ship_to_flag = 'P',
	    last_update_date = sysdate,
            last_updated_by = arp_standard.profile.user_id,
            last_update_login = arp_standard.profile.last_update_login,
            request_id =  req_id,
            program_application_id = arp_standard.profile.program_application_id,
            program_id = arp_standard.profile.program_id,
            program_update_date = sysdate
	WHERE EXISTS (	SELECT 1
 	     		FROM hz_cust_site_uses_all su, ra_customer_merges m
	     		WHERE m.request_id = req_id
             		AND   m.set_number = set_num
	     		AND  m.customer_createsame = 'N'
	     		AND  m.process_flag = 'N'
             		AND m.duplicate_primary_flag = 'Y'
             		AND yt.cust_acct_site_id = m.customer_address_id
	     		AND su.site_use_code = 'SHIP_TO'
	     		AND su.site_use_code = m.customer_site_code
	     		AND su.site_use_id = m.customer_site_id
	    		AND su.primary_flag = 'Y'
	     		AND su.request_id = req_id
			AND su.org_id = m.org_id
			AND yt.org_id = m.org_id);

	g_count := sql%rowcount;

	arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
	arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

	arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
	arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_SITES', FALSE );

	UPDATE hz_cust_acct_sites_all yt
	SET market_flag = 'P',
	    last_update_date = sysdate,
            last_updated_by = arp_standard.profile.user_id,
            last_update_login = arp_standard.profile.last_update_login,
            request_id =  req_id,
            program_application_id = arp_standard.profile.program_application_id,
            program_id = arp_standard.profile.program_id,
            program_update_date = sysdate
	WHERE EXISTS (  SELECT 1
 	    		FROM hz_cust_site_uses_all su, ra_customer_merges m
	     		WHERE m.request_id = req_id
             		AND   m.set_number = set_num
	     		AND  m.customer_createsame = 'N'
	     		AND  m.process_flag = 'N'
             		AND m.duplicate_primary_flag = 'Y'
             		AND yt.cust_acct_site_id = m.customer_address_id
	    		AND su.site_use_code = 'MARKET'
	     		AND su.site_use_code = m.customer_site_code
	     		AND su.site_use_id = m.customer_site_id
	     		AND su.primary_flag = 'Y'
	     		AND su.request_id = req_id
			AND su.org_id = m.org_id
			AND yt.org_id = m.org_id);

	g_count := sql%rowcount;
	arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
	arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

--Bug 7758559

       /*************** 'delete' mode ***************/

--Bug 1535542: Mark the rows need to be deleted by setting status to 'D'.
--Physically delete them after merge.

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_SITES', FALSE );

       --'delete' customer account site

       UPDATE HZ_CUST_ACCT_SITES_ALL yt --SSUptake
       SET status = 'D'
       WHERE EXISTS  (
                      SELECT 'Y'
                      FROM   ra_customer_merges m
                      WHERE  m.process_flag = 'N'
		      AND    m.request_id = req_id
                      AND    m.set_number = set_num
                      AND    m.delete_duplicate_flag = 'Y'
		      AND    m.duplicate_address_id = yt.cust_acct_site_id
		      AND    m.org_id = yt.org_id)
       AND NOT EXISTS (
                      SELECT 'site uses exist'
                      FROM   HZ_CUST_SITE_USES_ALL su --SSUptake
                      WHERE  su.cust_acct_site_id = yt.cust_acct_site_id
		      AND    su.org_id = yt.org_id
                      AND    su.status <> 'D' );

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    END IF;

     open c3;
     loop
     fetch c3 into x_to_address_id, x_from_address_id;
     EXIT WHEN c3%NOTFOUND;
      HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => x_from_address_id,
	                p_new_owner_table_id   => x_to_address_id,
                    p_owner_table_name  =>'HZ_CUST_ACCT_SITES_ALL',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>x_msg_count,
                    x_msg_data  =>x_msg_data);
	 --Handle error message
             IF x_msg_count = 1 THEN
                x_msg_data := x_msg_data || '**remap internal id**';
                arp_message.set_line(
                    'MOSR:remap internal id  ERROR '||
                    x_msg_data);
             ELSIF x_msg_count > 1 THEN

                FOR x IN 1..x_msg_count LOOP
                    x_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                    x_msg_data := x_msg_data || '**remap internal id**';
                    arp_message.set_line(
                        'MOSR:remap internal id  ERROR ' ||
                        x_msg_data );
                END LOOP;
             END IF;

             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
             END IF;

     end loop;
    close c3;


     arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_ADDR()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.RA_ADDR' );
      RAISE;

END ra_addr;

/*===========================================================================+
 | PROCEDURE
 |              ra_cust
 |
 | DESCRIPTION
 |              merge in HZ_CUST_ACCOUNTS.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  25-OCT-00  Customer account is global while account
 |                        site is stripped by operating unit. We need to
 |                        check if this account has (active)sites in
 |                        HZ_CUST_ACCT_SITES_ALL.
 |     Jianying Huang  20-DEC-00  Bug 1535542: Since we need to change
 |                        the merging order, merge HZ tables before merging
 |                        products, we need to mark deleted rows here
 |                        first and physically delete them after merging one
 |                        set in 'delete_rows'.
 |
 +===========================================================================*/

PROCEDURE ra_cust (
          req_id                NUMBER,
          set_num               NUMBER,
          process_mode          VARCHAR2
) IS

    l_orig_system_ref_rec          HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
    x_object_version_number   	   NUMBER;
    x_return_status   VARCHAR2(30);
    x_msg_count 	  NUMBER;
    x_msg_data		  VARCHAR2(2000);
    x_cust_account_id      NUMBER;
    x_orig_system_reference VARCHAR2(255);
    x_orig_system     VARCHAR2(30);
    x_orig_system_ref_id      NUMBER;
    x_from_cust_id         NUMBER;
    x_to_cust_id           NUMBER;

    --cursor c1 is used in 'inactivate' mode.
    CURSOR c1 IS
        SELECT yt.cust_account_id
        FROM   hz_cust_accounts yt, ra_customer_merges m
        WHERE  cust_account_id = m.duplicate_id
        AND    m.process_flag = 'N'
	AND    m.request_id = req_id
        AND    m.set_number = set_num
        AND    m.delete_duplicate_flag = 'N'
        /* no active addresses */
        AND NOT EXISTS (
                    SELECT 'active addresses exist'
                    FROM   hz_cust_acct_sites_all addr
                    WHERE  addr.cust_account_id = yt.cust_account_id
                    AND    addr.status = 'A' )
        FOR UPDATE NOWAIT;

    --cursor c2 is used in 'delete' mode.
    CURSOR c2 IS
        SELECT cust_account_id
        FROM   hz_cust_accounts yt, ra_customer_merges m
        WHERE  cust_account_id = m.duplicate_id
        AND    m.process_flag = 'N'
	AND    m.request_id = req_id
        AND    m.set_number = set_num
        AND    m.delete_duplicate_flag = 'Y'
        /* no addresses */
        AND NOT EXISTS (
                    SELECT 'addresses exist'
                    FROM   hz_cust_acct_sites_all addr
                    WHERE  addr.cust_account_id = yt.cust_account_id
                    AND    addr.status <> 'D' )
        FOR UPDATE NOWAIT;

      cursor c3 is
            SELECT distinct(m.customer_id), m.duplicate_id
                 FROM   ra_customer_merges m
                 WHERE  m.process_flag = 'N'
		 AND    m.request_id =req_id
                 AND    m.set_number = set_num
                 AND    (m.delete_duplicate_flag = 'N' OR m.delete_duplicate_flag = 'Y')
                 AND NOT EXISTS (
                    SELECT 'addresses exist'
                    FROM   hz_cust_acct_sites_all addr
                    WHERE  addr.cust_account_id = m.duplicate_id
                    AND    addr.status = 'A');


BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_CUST()+' );

    /* locking tables by opening and closing cursors */
    IF process_mode = 'LOCK' THEN

       arp_message.set_name( 'AR', 'AR_LOCKING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCOUNTS', FALSE );

       OPEN c1;
       CLOSE c1;

       OPEN c2;
       CLOSE c2;

    ELSE

       /*************** 'inactivate' mode ***************/

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCOUNTS', FALSE );

       --inactivate customer account

       UPDATE HZ_CUST_ACCOUNTS yt
       SET status = 'I',
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
           last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
           request_id =  req_id,
           program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
           program_id = hz_utility_v2pub.program_id,--arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE cust_account_id IN (
                 SELECT m.duplicate_id
                 FROM   ra_customer_merges m
                 WHERE  m.process_flag = 'N'
		 AND    m.request_id = req_id
                 AND    m.set_number = set_num
                 AND    m.delete_duplicate_flag = 'N' )
       /* no active addresses */
       AND NOT EXISTS (
                SELECT 'active addresses exist'
                FROM   hz_cust_acct_sites_all addr
                WHERE  addr.cust_account_id = yt.cust_account_id
                AND    addr.status = 'A' );

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       /*************** 'delete' mode ***************/

--Bug 1535542: Mark the rows need to be deleted by setting status to 'D'.
--Physically delete them after merge.

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCOUNTS', FALSE );

       --'delete' customer account

       UPDATE HZ_CUST_ACCOUNTS yt
       SET status = 'D'
       WHERE cust_account_id IN (
                 SELECT m.duplicate_id
                 FROM   ra_customer_merges m
                 WHERE  m.process_flag = 'N'
		 AND    m.request_id = req_id
                 AND    m.set_number = set_num
                 AND    m.delete_duplicate_flag = 'Y' )
       /* no addresses */
       AND NOT EXISTS (
                 SELECT 'addresses exist'
                 FROM   hz_cust_acct_sites_all addr
                 WHERE  addr.cust_account_id = yt.cust_account_id
                 AND    addr.status <> 'D' );

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    END IF;

 open c3;
     loop
     fetch c3 into x_to_cust_id, x_from_cust_id;
     EXIT WHEN c3%NOTFOUND;
      HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => x_from_cust_id,
	                p_new_owner_table_id   => x_to_cust_id,
                    p_owner_table_name  =>'HZ_CUST_ACCOUNTS',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>x_msg_count,
                    x_msg_data  =>x_msg_data);
	 --Handle error message
             IF x_msg_count = 1 THEN
                x_msg_data := x_msg_data || '**remap internal id**';
                arp_message.set_line(
                    'MOSR:remap internal id  ERROR '||
                    x_msg_data);
             ELSIF x_msg_count > 1 THEN

                FOR x IN 1..x_msg_count LOOP
                    x_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                    x_msg_data := x_msg_data || '**remap internal id**';
                    arp_message.set_line(
                        'MOSR:remap internal id  ERROR ' ||
                        x_msg_data );
                END LOOP;
             END IF;

             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
             END IF;

     end loop;
    close c3;

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_CUST()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.RA_CUST' );
      RAISE;

END ra_cust;

--4527935 Private procedure to create cust account relationships
PROCEDURE create_acct_relate(p_cust_acct_relate_id NUMBER,p_customer_id NUMBER, p_cust_account_id NUMBER,
                             p_related_cust_account_id NUMBER,p_rowid ROWID,
			     p_reciprocal_flag boolean);
/*===========================================================================+
 | PROCEDURE
 |              ra_cr
 |
 | DESCRIPTION
 |              merge in HZ_CUST_ACCT_RELATE.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |        This procedure performs a merge (as happens for a product's
 |        tables) as opposed to a delete/inactivate.
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  25-OCT-00  Customer account is global while account
 |                        site is stripped by operating unit. We need to
 |                        check if this account has (active)sites in
 |                        HZ_CUST_ACCT_SITES_ALL.
 |     Jianying Huang  12-DEC-00  Modified cursor c1 and c2. Replace 'active
 |                        account sites exist' with 'active accounts exist'
 |     Jianying Huang  20-DEC-00  Bug 1535542: Since we need to change
 |                        the merging order, merge HZ tables before merging
 |                        products, we need to mark deleted rows here
 |                        first and physically delete them after merging one
 |                        set in 'delete_rows'.
 |     S V Sowjanya    11-APR-06 Bug No: 4527935. Modified the code to handle the customer
 |                                 account relationship merge properly.
 |
 +===========================================================================*/

PROCEDURE ra_cr (
          req_id                NUMBER,
          set_num               NUMBER,
          process_mode          VARCHAR2
) IS

    --cursor c1 is for from cust account
    CURSOR c1 IS
        SELECT yt.cust_account_id
        FROM hz_cust_acct_relate_all yt, ra_customer_merges  m --SSUptake
        WHERE
         --NOT EXISTS (
         --              SELECT 'active accounts exist'
         --             FROM   hz_cust_accounts acct
         --               WHERE  acct.cust_account_id = yt.cust_account_id
         --              AND    acct.status = 'A' )
        m.request_id = req_id
	AND m.process_flag = 'N'
        AND m.set_number = set_num
	AND m.org_id  = yt.org_id --SSUptake
	AND yt.cust_account_id = m.duplicate_id
        FOR UPDATE NOWAIT;

    --cursor c2 is for to cust account
    CURSOR c2 IS
        SELECT yt.related_cust_account_id
        FROM hz_cust_acct_relate_all yt, ra_customer_merges   m --SSUptake
        WHERE
        --NOT EXISTS (
        --               SELECT 'active accounts exist'
        --               FROM   hz_cust_accounts acct
        --               WHERE  acct.cust_account_id = yt.related_cust_account_id
        --               AND    acct.status = 'A' )
        m.request_id = req_id
	AND m.process_flag = 'N'
        AND m.set_number = set_num
	AND m.org_id = yt.org_id --SSUptake
	AND yt.related_cust_account_id = m.duplicate_id
        FOR UPDATE NOWAIT;


 --Start of Bug No: 4527935
  CURSOR c_from_rel_cust_id IS
      SELECT unique yt.cust_acct_relate_id,cm.customer_id,yt.cust_account_id,yt.related_cust_account_id,
             yt.customer_reciprocal_flag,nvl(yt.bill_to_flag,'N') bill_to_flag,
	     nvl(yt.ship_to_flag,'N') ship_to_flag,yt.rowid,yt.org_id
      FROM   hz_cust_acct_relate_all yt, ra_customer_merges cm
      WHERE  cm.request_id = req_id
      AND    cm.process_flag = 'N'
      AND    cm.set_number = set_num
      AND    cm.duplicate_id <> cm.customer_id             --merging sites for same customer
      AND    cm.duplicate_id = yt.cust_account_id
      AND    cm.customer_id  <> yt.related_cust_account_id --relationship to self not allowed
      AND    yt.status ='A'
      AND    cm.org_id = yt.org_id;
  CURSOR c_from_cust_rel_id IS
      SELECT unique yt.cust_acct_relate_id,cm.customer_id,yt.cust_account_id,yt.related_cust_account_id,
             yt.customer_reciprocal_flag,nvl(yt.bill_to_flag,'N') bill_to_flag,
	     nvl(yt.ship_to_flag,'N') ship_to_flag,yt.rowid,yt.org_id
      FROM   hz_cust_acct_relate_all yt, ra_customer_merges cm
      WHERE  cm.request_id = req_id
      AND    cm.process_flag = 'N'
      AND    cm.set_number = set_num
      AND    cm.duplicate_id <> cm.customer_id             --merging sites for same customer
      AND    cm.duplicate_id = yt.related_cust_account_id
      AND    cm.customer_id  <> yt.cust_account_id --relationship to self not allowed
      AND    yt.status ='A'
      AND    cm.org_id = yt.org_id;
  CURSOR c_to_rel_cust_id(p_cust_account_id NUMBER,p_related_cust_account_id NUMBER,p_org_id NUMBER) IS
      SELECT cust_account_id,related_cust_account_id,customer_reciprocal_flag,
	        nvl(bill_to_flag,'N') bill_to_flag,nvl(ship_to_flag,'N') ship_to_flag
      FROM   hz_cust_acct_relate_all yt
      WHERE  yt.cust_account_id = p_cust_account_id
      AND    yt.related_cust_account_id = p_related_cust_account_id
      AND    yt.status = 'A'
      AND    yt.org_id = p_org_id
      AND    ROWNUM =1;
  CURSOR c_acct_num(p_acct_id NUMBER) IS
    SELECT account_number FROM hz_cust_accounts
    WHERE  cust_account_id=p_acct_id;

  l_to_cust_account_id             NUMBER(15);
  l_to_related_cust_account_id     NUMBER(15);
  l_to_customer_reciprocal_flag    VARCHAR2(1);
  l_to_bill_to_flag                VARCHAR2(1);
  l_to_ship_to_flag		   VARCHAR2(1);
  l_update_flag                    BOOLEAN;
  l_from_acct_no                   VARCHAR2(30);
  l_to_acct_no                     VARCHAR2(30);
--End of Bug No: 4527935

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_CR()+' );

    /* locking tables by opening and closing cursors */
    IF process_mode = 'LOCK' THEN

       arp_message.set_name( 'AR', 'AR_LOCKING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_RELATE', FALSE );

       OPEN c1;
       CLOSE c1;

       OPEN c2;
       CLOSE c2;

    ELSE

--Start of Bug No: 4558774

       /************** from account update ************/
       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_RELATE', FALSE );

       g_count := 0;
       FOR from_rec in c_from_rel_cust_id
       LOOP
         l_to_cust_account_id             := null;
	 l_to_related_cust_account_id     := null;
	 l_to_customer_reciprocal_flag    := null;
	 l_to_bill_to_flag                := null;
	 l_to_ship_to_flag		  := null;
	 l_update_flag                    := false;
         OPEN c_to_rel_cust_id(from_rec.customer_id,from_rec.related_cust_account_id,from_rec.org_id);
	 FETCH  c_to_rel_cust_id INTO l_to_cust_account_id,l_to_related_cust_account_id,
	        l_to_customer_reciprocal_flag,l_to_bill_to_flag,l_to_ship_to_flag ;
         CLOSE c_to_rel_cust_id;
         IF(l_to_cust_account_id IS NULL) THEN ---No Relationship Exists.Create a new one
	   create_acct_relate(from_rec.cust_acct_relate_id,from_rec.customer_id, from_rec.cust_account_id,
                             from_rec.related_cust_account_id,from_rec.rowid,
			     false);
	 ELSIF(l_to_customer_reciprocal_flag <> from_rec.customer_reciprocal_flag) THEN --- Display the warning message in the log file.
	   OPEN c_acct_num(from_rec.cust_account_id);
	   FETCH c_acct_num into l_from_acct_no;
	   CLOSE c_acct_num;
	   OPEN c_acct_num(l_to_cust_account_id);
	   FETCH c_acct_num into l_to_acct_no;
	   CLOSE c_acct_num;
           arp_message.set_name( 'AR', 'HZ_ACCT_MERGE_REL_WARNING' );
	   arp_message.set_token( 'MERGE_FROM_ACCT',l_from_acct_no, FALSE );
	   arp_message.set_token( 'MERGE_TO_ACCT',l_to_acct_no, FALSE );
	 ELSE -- blend the two relationships
	   IF(l_to_bill_to_flag <> 'Y' AND l_to_bill_to_flag <> from_rec.bill_to_flag) THEN
	      l_to_bill_to_flag := from_rec.bill_to_flag;
	      l_update_flag := true;
	   END IF;
	   IF(l_to_ship_to_flag <> 'Y' AND l_to_ship_to_flag <> from_rec.ship_to_flag) THEN
	      l_to_ship_to_flag := from_rec.ship_to_flag;
	      l_update_flag := true;
	   END IF;
	   IF(l_update_flag) THEN
             UPDATE hz_cust_acct_relate_all SET bill_to_flag = l_to_bill_to_flag,ship_to_flag=l_to_ship_to_flag
   	     WHERE cust_account_id = l_to_cust_account_id
	     AND   related_cust_account_id = l_to_related_cust_account_id
	     AND   org_id = from_rec.org_id
	     AND   STATUS = 'A';
           END IF;
	 END IF;
	 --Inactivate the from account relationship
	 UPDATE hz_cust_acct_relate_all yt SET
	      status = 'I',
             last_update_date = sysdate,
             last_updated_by = hz_utility_v2pub.user_id,
             last_update_login = hz_utility_v2pub.last_update_login,
             request_id =  req_id,
             program_application_id = hz_utility_v2pub.program_application_id,
             program_id = hz_utility_v2pub.program_id,
             program_update_date = sysdate
         WHERE status = 'A'
         AND   yt.cust_account_id = from_rec.cust_account_id
	 AND   yt.related_cust_account_id = from_rec.related_cust_account_id
	 AND   yt.org_id = from_rec.org_id;
	 g_count := g_count + sql%rowcount;
       END LOOP;

        /************** to account update ************/

       FOR from_rec in c_from_cust_rel_id
       LOOP
         l_to_cust_account_id             := null;
	 l_to_related_cust_account_id     := null;
	 l_to_customer_reciprocal_flag    := null;
	 l_to_bill_to_flag                := null;
	 l_to_ship_to_flag		  := null;
	 l_update_flag                    := false;
         OPEN c_to_rel_cust_id(from_rec.cust_account_id,from_rec.customer_id,from_rec.org_id);
	 FETCH  c_to_rel_cust_id INTO l_to_cust_account_id,l_to_related_cust_account_id,
	        l_to_customer_reciprocal_flag,l_to_bill_to_flag,l_to_ship_to_flag ;
         CLOSE c_to_rel_cust_id;
         IF(l_to_related_cust_account_id IS NULL) THEN ---No Relationship Exists.Create a new one
	   create_acct_relate(from_rec.cust_acct_relate_id,from_rec.customer_id, from_rec.cust_account_id,
                             from_rec.related_cust_account_id,from_rec.rowid,
			     true);
	 ELSIF(from_rec.customer_reciprocal_flag <> 'Y' and l_to_customer_reciprocal_flag <> from_rec.customer_reciprocal_flag) THEN --- Display the warning message in the log file.
	   OPEN c_acct_num(from_rec.related_cust_account_id);
	   FETCH c_acct_num into l_from_acct_no;
	   CLOSE c_acct_num;
	   OPEN c_acct_num(l_to_related_cust_account_id);
	   FETCH c_acct_num into l_to_acct_no;
	   CLOSE c_acct_num;
           arp_message.set_name( 'AR', 'HZ_ACCT_MERGE_REL_WARNING' );
	   arp_message.set_token( 'MERGE_FROM_ACCT',l_from_acct_no, FALSE );
	   arp_message.set_token( 'MERGE_TO_ACCT',l_to_acct_no, FALSE );
	 ELSE -- blend the two relationships
	   IF(l_to_bill_to_flag <> 'Y' AND l_to_bill_to_flag <> from_rec.bill_to_flag) THEN
	      l_to_bill_to_flag := from_rec.bill_to_flag;
	      l_update_flag := true;
	   END IF;
	   IF(l_to_ship_to_flag <> 'Y' AND l_to_ship_to_flag <> from_rec.ship_to_flag) THEN
	      l_to_ship_to_flag := from_rec.ship_to_flag;
	      l_update_flag := true;
	   END IF;
	   IF(l_update_flag) THEN
             UPDATE hz_cust_acct_relate_all SET bill_to_flag = l_to_bill_to_flag,ship_to_flag=l_to_ship_to_flag
   	     WHERE cust_account_id = l_to_cust_account_id
	     AND   related_cust_account_id = l_to_related_cust_account_id
	     AND   org_id = from_rec.org_id
	     AND   STATUS = 'A';
           END IF;
	 END IF;
	 --Inactivate the from account relationships
	 UPDATE hz_cust_acct_relate_all yt SET
	     status = 'I',
             last_update_date = sysdate,
             last_updated_by =hz_utility_v2pub.user_id,
             last_update_login = hz_utility_v2pub.last_update_login,
             request_id =  req_id,
             program_application_id =hz_utility_v2pub.program_application_id,
             program_id = hz_utility_v2pub.program_id,
             program_update_date = sysdate
         WHERE status = 'A'
         AND   yt.cust_account_id = from_rec.cust_account_id
	 AND   yt.related_cust_account_id = from_rec.related_cust_account_id
	 AND   yt.org_id = from_rec.org_id;
	 g_count := g_count + sql%rowcount;
       END LOOP;
       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       /***************  'inactivate' mode *************/
       --inactivate self relationships
       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_RELATE', FALSE );

       --Start bug 7192302
       /*UPDATE HZ_CUST_ACCT_RELATE_ALL yt
       SET status = 'I',
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id =  req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE EXISTS (
	       SELECT 'relationship to self not allowed'
               FROM   ra_customer_merges m
               WHERE  m.customer_id = yt.related_cust_account_id
               AND    m.duplicate_id = yt.cust_account_id
               AND    m.process_flag = 'N'
               AND    m.request_id = req_id
               AND    m.set_number = set_num
	       AND    m.org_id = yt.org_id
               AND    m.delete_duplicate_flag = 'N' )
	OR   EXISTS (
               SELECT 'relationship to self not allowed'
               FROM   ra_customer_merges m
               WHERE  m.customer_id = yt.cust_account_id
               AND    m.duplicate_id = yt.related_cust_account_id
               AND    m.process_flag = 'N'
               AND    m.request_id = req_id
               AND    m.set_number = set_num
	       AND    m.org_id = yt.org_id
               AND    m.delete_duplicate_flag = 'N' );*/

	UPDATE	HZ_CUST_ACCT_RELATE_ALL YT
	SET	STATUS = 'I',
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = hz_utility_v2pub.user_id ,
		LAST_UPDATE_LOGIN = hz_utility_v2pub.last_update_login ,
		REQUEST_ID = req_id,
		PROGRAM_APPLICATION_ID = hz_utility_v2pub.program_application_id ,
		PROGRAM_ID = hz_utility_v2pub.program_id ,
		PROGRAM_UPDATE_DATE = SYSDATE
	WHERE	(RELATED_CUST_ACCOUNT_ID,CUST_ACCOUNT_ID,ORG_ID ) IN
		(SELECT	CUSTOMER_ID,
			DUPLICATE_ID,
			ORG_ID
		FROM	RA_CUSTOMER_MERGES M
		WHERE	M.PROCESS_FLAG = 'N'
		AND	M.REQUEST_ID = req_id
		AND	M.SET_NUMBER = set_num
		AND	M.DELETE_DUPLICATE_FLAG = 'N' );

       g_count := sql%rowcount;

       UPDATE	HZ_CUST_ACCT_RELATE_ALL YT
	SET	STATUS = 'I',
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = hz_utility_v2pub.user_id ,
		LAST_UPDATE_LOGIN = hz_utility_v2pub.last_update_login ,
		REQUEST_ID = req_id,
		PROGRAM_APPLICATION_ID = hz_utility_v2pub.program_application_id ,
		PROGRAM_ID = hz_utility_v2pub.program_id ,
		PROGRAM_UPDATE_DATE = SYSDATE
	WHERE	(CUST_ACCOUNT_ID,RELATED_CUST_ACCOUNT_ID,ORG_ID ) IN
		(SELECT	CUSTOMER_ID,
			DUPLICATE_ID,
			ORG_ID
		FROM	RA_CUSTOMER_MERGES M
		WHERE	M.PROCESS_FLAG = 'N'
		AND	M.REQUEST_ID = req_id
		AND	M.SET_NUMBER = set_num
		AND	M.DELETE_DUPLICATE_FLAG = 'N' );

	g_count :=g_count + sql%rowcount;
	--End bug 7192302
       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

 --End of Bug No: 4527935
       /*************** for 'delete' mode *************/
       --delete those relationships that could not be updated
       --because it would produce:
              --duplicate relationships
              --self-relationship

--Bug 1535542: Mark the rows need to be deleted by setting status to 'D'.
--Physically delete them after merge.

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_RELATE', FALSE );

       /************** from account update ************/

       UPDATE HZ_CUST_ACCT_RELATE_ALL yt --SSUptake
       SET status = 'D'
       WHERE
       --NOT EXISTS (
       --        SELECT 'accounts exist'
       --        FROM   hz_cust_accounts  acct
       --        WHERE  acct.cust_account_id = yt.cust_account_id
       --        AND    acct.status <> 'D' )
       EXISTS  ( --SSUptake
               SELECT 'Y'
               FROM   ra_customer_merges m
               WHERE  m.duplicate_id = yt.cust_account_id
	       AND    m.process_flag = 'N'
               AND    m.request_id = req_id
               AND    m.set_number = set_num
               AND    m.delete_duplicate_flag = 'Y'
	       AND    m.org_id    = yt.org_id ) --SSUptake
       AND ( EXISTS (
               SELECT 'relationship already exists, cannot update'
               FROM   HZ_CUST_ACCT_RELATE_ALL r, --SSUptake
                      ra_customer_merges m
               WHERE  m.customer_id = r.cust_account_id
               AND    m.duplicate_id = yt.cust_account_id
               AND    r.related_cust_account_id = yt.related_cust_account_id
	       AND    r.org_id  = yt.org_id --SSUptake
               AND    m.process_flag = 'N'
               AND    m.request_id = req_id
               AND    m.set_number = set_num
               AND    m.delete_duplicate_flag = 'Y'
	       AND    m.org_id = r.org_id ) --SSUptake
            OR EXISTS (
               SELECT 'relationship to self not allowed'
               FROM   ra_customer_merges m
               WHERE  m.customer_id = yt.related_cust_account_id
               AND    m.duplicate_id = yt.cust_account_id
               AND    m.process_flag = 'N'
               AND    m.request_id = req_id
               AND    m.set_number = set_num
               AND    m.delete_duplicate_flag = 'Y'
	       AND    m.org_id  = yt.org_id ) ) --SSUptake
--Bug fix 2909303
        AND NOT EXISTS(
                select 'merging sites for same customer, cannot update'
                from ra_customer_merges m
                where m.duplicate_id = m.customer_id
                and   m.duplicate_id = yt.cust_account_id
                AND   m.process_flag = 'N'
                AND   m.request_id = req_id
                AND   m.set_number = set_num
		AND   m.org_id     = yt.org_id); --SSUptake

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       /************** to account update ************/

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_RELATE', FALSE );

       UPDATE HZ_CUST_ACCT_RELATE_ALL yt
       SET status = 'D'
       WHERE
       --NOT EXISTS (
       --        SELECT 'accounts exist'
       --        FROM   hz_cust_accounts  acct
       --        WHERE  acct.cust_account_id = yt.related_cust_account_id
       --        AND    acct.status <> 'D' )
        EXISTS  (
               SELECT 'Y'
               FROM   ra_customer_merges m
               WHERE  yt.related_cust_account_id = m.duplicate_id
	       AND    m.org_id   = yt.org_id --SSUptake
	       AND    m.process_flag = 'N'
               AND    m.request_id = req_id
               AND    m.set_number = set_num
               AND    m.delete_duplicate_flag = 'Y')
       AND ( EXISTS (
               SELECT 'relationship already exists, cannot update'
               FROM   HZ_CUST_ACCT_RELATE_ALL r,
                      ra_customer_merges m
               WHERE  m.customer_id = r.related_cust_account_id
               AND    m.duplicate_id = yt.related_cust_account_id
               AND    r.cust_account_id = yt.cust_account_id
	       AND    r.org_id       = yt.org_id --SSUptake
	       AND    m.org_id       = r.org_id
               AND    m.process_flag = 'N'
               AND    m.request_id = req_id
               AND    m.set_number = set_num
               AND    m.delete_duplicate_flag = 'Y')--SSUptake
            OR EXISTS (
               SELECT 'relationship to self not allowed'
               FROM   ra_customer_merges m
               WHERE  m.customer_id = yt.cust_account_id
               AND    m.duplicate_id = yt.related_cust_account_id
	       AND    m.org_id  = yt.org_id --SSUptake
               AND    m.process_flag = 'N'
               AND    m.request_id = req_id
               AND    m.set_number = set_num
               AND    m.delete_duplicate_flag = 'Y' ) )
--Bug fix 2909303
        AND NOT EXISTS(
                select 'merging sites for same customer, cannot update'
                from ra_customer_merges m
                where m.duplicate_id = m.customer_id
                and   m.duplicate_id = yt.related_cust_account_id
		AND   m.org_id = yt.org_id  --SSUptake
                AND   m.process_flag = 'N'
                AND   m.request_id = req_id
                AND   m.set_number = set_num );

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    END IF;

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_CR()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.RA_CR' );
      RAISE;

END ra_cr;

/*===========================================================================+
 | PROCEDURE
 |              ra_crm
 |
 | DESCRIPTION
 |              merge in RA_CUST_RECEIPT_METHODS
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  25-OCT-00  Customer account is global while account
 |                        site is stripped by operating unit. We need to
 |                        check if this account has (active)sites in
 |                        HZ_CUST_ACCT_SITES_ALL.
 |     Jianying Huang  12-DEC-00  Modified cursor c2. Replace 'active addresses
 |                        exist' with 'active accounts exist'
 |     Jianying Huang  20-DEC-00  Bug 1535542: Since we need to change
 |                        the merging order, merge HZ tables before merging
 |                        products and RA_CUST_RECEIPT_METHODS does
 |                        not have status column, we need to move the delete part
 |                        to 'delete_rows' procedure.
 |     Victoria Crisostomo   01-FEB-01
 |                        Bug 1611619 : include customer_id in where condition
 |                        of update statement to force use of an existing index
 |     S.V.Sowjanya  29-JUL-2004  Bug No 3786802: Declared 3 pl/sql tables "header_id,receipt_id,end_date"
 |                                and 1 local variable "new_date".
 |                                Customer_merge_header_id , Cust_receipt_method_id and
 |                                end_date are bulk collected into the pl/sql tables
 |                                header_id,receipt_id,end_date.
 |                                While inserting auditing values into the table
 |                                HZ_CUSTOMER_MERGE_LOG and updating RA_CUST_RECEIPT_METHODS
 |                                , values stored in pl/sql tables are used.
 |                                Commented the insert statement and update statements.
|
 +===========================================================================*/

PROCEDURE ra_crm (
          req_id                NUMBER,
          set_num               NUMBER,
          process_mode          VARCHAR2
) IS

  l_count NUMBER;

    --cursor c1 and c2 are used in 'inactivate' mode
    CURSOR c1 IS
        SELECT CUST_RECEIPT_METHOD_ID
        FROM   RA_CUST_RECEIPT_METHODS ra, ra_customer_merges m
        WHERE ra.customer_id = m.duplicate_id
        AND   site_use_id = m.duplicate_site_id
        AND   m.process_flag = 'N'
	AND   m.request_id = req_id
        AND   m.set_number = set_num
        AND   m.delete_duplicate_flag = 'N'
        FOR UPDATE NOWAIT;

    CURSOR c2 IS
        SELECT CUST_RECEIPT_METHOD_ID
        FROM RA_CUST_RECEIPT_METHODS yt, ra_customer_merges m
        WHERE yt.customer_id = m.duplicate_id
        AND   m.process_flag = 'N'
	AND   m.request_id = req_id
        AND   m.set_number = set_num
        AND   m.delete_duplicate_flag = 'N'
        AND site_use_id IS NULL
        AND NOT EXISTS (
                    SELECT 'active accounts exist'
                    FROM   hz_cust_accounts acct
                    WHERE  acct.cust_account_id = yt.customer_id
                    AND    acct.status = 'A' )
        FOR UPDATE NOWAIT;

    TYPE customer_merge_header_id_tab IS TABLE OF RA_CUSTOMER_MERGES.CUSTOMER_MERGE_HEADER_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE cust_receipt_method_id_tab IS TABLE OF RA_CUST_RECEIPT_METHODS.CUST_RECEIPT_METHOD_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE end_date_tab   IS TABLE OF RA_CUST_RECEIPT_METHODS.END_DATE%TYPE INDEX BY BINARY_INTEGER;

    header_id customer_merge_header_id_tab;
    receipt_id cust_receipt_method_id_tab;
    end_date end_date_tab;
    new_date date;
BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_CRM()+' );

    /* locking tables by opening and closing cursors */
    IF process_mode = 'LOCK' THEN

       arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
       arp_message.set_token( 'TABLE_NAME', 'RA_CUST_RECEIPT_METHODS', FALSE );

       OPEN c1;
       CLOSE c1;

       OPEN c2;
       CLOSE c2;

    ELSE

       /************** account site level inactivate ************/

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'RA_CUST_RECEIPT_METHODS', FALSE );

--- bug 3786802

     SELECT distinct CUSTOMER_MERGE_HEADER_ID,
             CUST_RECEIPT_METHOD_ID,
             END_DATE
     BULK COLLECT INTO header_id,receipt_id,end_date
     FROM RA_CUST_RECEIPT_METHODS yt, ra_customer_merges m
     WHERE   (yt.CUSTOMER_ID = m.DUPLICATE_ID
              AND ( ( yt.SITE_USE_ID IS NULL
                      AND NOT EXISTS (
                     SELECT 'active accounts exist'
                     FROM   hz_cust_accounts acct
                     WHERE  acct.cust_account_id = yt.customer_id
                     AND    acct.status = 'A' )
                    )
                 OR (yt.site_use_id = m.DUPLICATE_SITE_ID)
                 )
              )
            AND    m.process_flag = 'N'
            AND    m.request_id = req_id
            AND    m.set_number = set_num;

       ---Inserting in the log table for Auditing

        new_date := sysdate;
        FORALL i IN 1..header_id.count

       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       MERGE_HEADER_ID,
       TABLE_NAME,
       PRIMARY_KEY_ID,
       DATE_COL1_ORIG,
       DATE_COL1_NEW,
       REQUEST_ID,

-- Bug 2707587 : Added standard who columns (created_by, creation_date,
--		 last_update_by, last_update_date, last_update_login)
--		 and ACTION_FLAG column into insert statemnt.

	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	ACTION_FLAG
      )

      VALUES (
       HZ_CUSTOMER_MERGE_LOG_s.nextval,
       header_id(i),
      'RA_CUST_RECEIPT_METHODS',
       receipt_id(i),
       end_date(i),
       new_date,
       req_id,
       hz_utility_v2pub.CREATED_BY,
       hz_utility_v2pub.CREATION_DATE,
       hz_utility_v2pub.LAST_UPDATED_BY,
       hz_utility_v2pub.LAST_UPDATE_DATE,
       hz_utility_v2pub.LAST_UPDATE_LOGIN,
       'U'
       ) ;

-- Commented for bug 3786802
    /*   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       MERGE_HEADER_ID,
       TABLE_NAME,
       PRIMARY_KEY_ID,
       DATE_COL1_ORIG,
       DATE_COL1_NEW,
       REQUEST_ID,

-- Bug 2707587 : Added standard who columns (created_by, creation_date,
--		 last_update_by, last_update_date, last_update_login)
--		 and ACTION_FLAG column into insert statemnt.

	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	ACTION_FLAG


    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             CUSTOMER_MERGE_HEADER_ID,
             'RA_CUST_RECEIPT_METHODS',
             CUST_RECEIPT_METHOD_ID,
             END_DATE,
             SYSDATE,
             req_id,
	     hz_utility_v2pub.CREATED_BY,
	     hz_utility_v2pub.CREATION_DATE,
	     hz_utility_v2pub.LAST_UPDATED_BY,
	     hz_utility_v2pub.LAST_UPDATE_DATE,
	     hz_utility_v2pub.LAST_UPDATE_LOGIN,
	     'U'

     FROM (
       SELECT distinct CUSTOMER_MERGE_HEADER_ID,
             CUST_RECEIPT_METHOD_ID,
             END_DATE
     FROM RA_CUST_RECEIPT_METHODS yt, ra_customer_merges m
     WHERE   (yt.CUSTOMER_ID = m.DUPLICATE_ID
              AND ( ( yt.SITE_USE_ID IS NULL
                      AND NOT EXISTS (
                     SELECT 'active accounts exist'
                     FROM   hz_cust_accounts acct
                     WHERE  acct.cust_account_id = yt.customer_id
                     AND    acct.status = 'A' )
                    )
                 OR (yt.site_use_id = m.DUPLICATE_SITE_ID)
                 )
              )
            AND    m.process_flag = 'N'
            AND    m.request_id = req_id
            AND    m.set_number = set_num
	);*/

     /*
     |  --- bug 1611619 : put customer_id in where clause to use index
     |  UPDATE RA_CUST_RECEIPT_METHODS yt
     |  SET end_date = sysdate,
     |      last_update_date = sysdate,
     |      last_updated_by = arp_standard.profile.user_id,
     |      last_update_login = arp_standard.profile.last_update_login,
     |      request_id =  req_id,
     |      program_application_id =arp_standard.profile.program_application_id,
     |      program_id = arp_standard.profile.program_id,
     |      program_update_date = sysdate
     |  WHERE (customer_id, site_use_id) IN (
     |            SELECT m.duplicate_id, m.duplicate_site_id
     |          	 FROM   ra_customer_merges m
     |            WHERE  m.process_flag = 'N'
     |   AND    m.request_id = req_id
     |            AND    m.set_number = set_num
     |            AND    m.delete_duplicate_flag = 'N' ); */

-- Commented for bug 3786802
/*
      UPDATE RA_CUST_RECEIPT_METHODS yt SET (
      END_DATE) = (
           SELECT DATE_COL1_NEW
           FROM HZ_CUSTOMER_MERGE_LOG l
           WHERE l.REQUEST_ID = req_id
           AND l.TABLE_NAME = 'RA_CUST_RECEIPT_METHODS'
           AND l.PRIMARY_KEY_ID = CUST_RECEIPT_METHOD_ID
      )
       , LAST_UPDATE_DATE=SYSDATE
       , last_updated_by=arp_standard.profile.user_id
       , last_update_login=arp_standard.profile.last_update_login
       , REQUEST_ID=req_id
       , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
       , PROGRAM_ID=arp_standard.profile.program_id
       , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE (CUST_RECEIPT_METHOD_ID) in (
         SELECT PRIMARY_KEY_ID
         FROM HZ_CUSTOMER_MERGE_LOG l1, RA_CUSTOMER_MERGES h
         WHERE h.CUSTOMER_MERGE_HEADER_ID = l1.MERGE_HEADER_ID
         AND l1.TABLE_NAME = 'RA_CUST_RECEIPT_METHODS'
         AND l1.REQUEST_ID = req_id
         AND h.set_number = set_num);

*/


      FORALL i in 1..receipt_id.count


      UPDATE RA_CUST_RECEIPT_METHODS yt SET
      END_DATE = new_date
      , LAST_UPDATE_DATE=sysdate
      , last_updated_by=hz_utility_v2pub.user_id--arp_standard.profile.user_id
      , last_update_login=hz_utility_v2pub.last_update_login--arp_standard.profile.last_update_login
      , REQUEST_ID=req_id
      , PROGRAM_APPLICATION_ID=hz_utility_v2pub.program_application_id--arp_standard.profile.program_application_id
      , PROGRAM_ID=hz_utility_v2pub.program_id--arp_standard.profile.program_id
      , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE CUST_RECEIPT_METHOD_ID = receipt_id(i);

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       /************** account level inactivate ************/

    /*   arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
    |   arp_message.set_token( 'TABLE_NAME', 'RA_CUST_RECEIPT_METHODS', FALSE );

    |
    |  UPDATE RA_CUST_RECEIPT_METHODS yt
    |   set end_date = sysdate,
    |       last_update_date = sysdate,
    |       last_updated_by = arp_standard.profile.user_id,
    |       last_update_login = arp_standard.profile.last_update_login,
    |       request_id =  req_id,
    |       program_application_id =arp_standard.profile.program_application_id,
    |       program_id = arp_standard.profile.program_id,
    |       program_update_date = sysdate
    |   WHERE customer_id IN (
    |            SELECT m.duplicate_id
    |            FROM   ra_customer_merges m
    |            WHERE  m.process_flag = 'N'
    |            AND    m.request_id = req_id
    |            AND    m.set_number = set_num
    |            AND    m.delete_duplicate_flag = 'N' )
    |   AND site_use_id IS NULL
    |   AND NOT EXISTS (
    |            SELECT 'active accounts exist'
    |            FROM   hz_cust_accounts acct
    |            WHERE  acct.cust_account_id = yt.customer_id
    |            AND    acct.status = 'A' );

    |   g_count := sql%rowcount;

    |   arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    |   arp_message.set_token( 'NUM_ROWS', to_char(g_count) ); */

    END IF;

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_CRM()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.RA_CRM' );
      RAISE;

END ra_crm;

/*===========================================================================+
 | PROCEDURE
 |              copy_contacts
 |
 | DESCRIPTION
 |              Migrate contacts and contact points.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  26-OCT-00  Bug 1415529: The procedure has been added
 |                        to move out do_cust(site)_merge_contacts(cpoint)
 |                        from ra_cont and ra_ph. It should be called before
 |                        ra_addr and ra_cust. The procedure should be called
 |                        after locking tables.
 |     Jianying Huang  17-DEC-00  Bug 1535542: Since we will not physically
 |                        delete rows till the end of merge, we can move
 |                        the call of 'copy_contacts' right before we migrate
 |                        org contacts and contact points.
 |
 +===========================================================================*/

PROCEDURE copy_contacts (
          req_id                NUMBER,
          set_num               NUMBER,
          process_mode          VARCHAR2
) IS

    --party ids
    from_party_id               NUMBER;
    to_party_id                 NUMBER;

    --account ids
    from_account_id             NUMBER;
    to_account_id               NUMBER;

    CURSOR accounts IS
        SELECT DISTINCT duplicate_id, customer_id
        FROM   ra_customer_merges
        WHERE  process_flag = 'N'
        AND    request_id = req_id
        AND    set_number = set_num
        AND    duplicate_id <> customer_id;

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.copy_contacts()+' );

    OPEN accounts;
    LOOP
       FETCH accounts INTO from_account_id, to_account_id;
       EXIT WHEN accounts%NOTFOUND;

/**
       arp_message.set_line(
           'ARP_CMERGE_ARCUS:copy_contacts():from_account_id ' ||
           from_account_id );
       arp_message.set_line(
           'ARP_CMERGE_ARCUS:copy_contacts():to_account_id  ' ||
           to_account_id );
**/

       SELECT party_id into from_party_id
       FROM   hz_cust_accounts
       WHERE  cust_account_id = from_account_id;

       SELECT party_id into to_party_id
       FROM   hz_cust_accounts
       WHERE  cust_account_id = to_account_id;

/**
       arp_message.set_line(
           'ARP_CMERGE_ARCUS:copy_contacts():from_party_id '||
           from_party_id );
       arp_message.set_line(
           'ARP_CMERGE_ARCUS:copy_contacts():to_party_id '||
           to_party_id );
**/

       --Based on customer merge high level design:
       --org contact or contact points that the customer contact
       --record refers to must be copied, if only if the merge-from
       --party and merge-to party are different.

       IF to_party_id = from_party_id THEN

/**
          arp_message.set_line (
              'ARP_CMERGE_ARCUS:copy_contacts(): ' ||
              'merge_from party and merge_to party are same. ' ||
              'Do not need copy org contact and contact points in account level.' );
**/
          NULL;

       ELSE

          --merge cust account roles in account level
          do_cust_merge_contacts (
                  from_party_id, to_party_id,
                  from_account_id, to_account_id );

          --merge cust account roles in account site level.
          do_site_merge_contacts (
                  from_party_id, to_party_id,
                  from_account_id, to_account_id,
                  req_id, set_num );

          --merge cust contact points in account level
          do_cust_merge_cpoint(
                  from_party_id, to_party_id,
                  from_account_id, to_account_id );
       END IF;

    END LOOP;
    CLOSE accounts;

    arp_message.set_line( 'ARP_CMERGE_ARCUS.copy_contacts()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.copy_contacts' );
      RAISE;

END copy_contacts;

/*===========================================================================+
 | PROCEDURE
 |              copy_contacts_in_sites
 |
 | DESCRIPTION
 |              Migrate contact points in site level.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  29-DEC-00  Created. We need to copy contact points
 |                        as long as we are merging different party sites.
 |
 +===========================================================================*/

PROCEDURE copy_contacts_in_sites (
          req_id                NUMBER,
          set_num               NUMBER,
          process_mode          VARCHAR2
) IS

    --party ids
    from_party_site_id               NUMBER;
    to_party_site_id                 NUMBER;

    --account ids
    from_account_id                  NUMBER;
    to_account_id                    NUMBER;

    --account sites
    from_site_id                     NUMBER;
    to_site_id                       NUMBER;

    CURSOR sites IS
        SELECT DISTINCT duplicate_id, customer_id,
               duplicate_address_id, customer_address_id
        FROM   ra_customer_merges
        WHERE  process_flag = 'N'
        AND    request_id = req_id
        AND    set_number = set_num
	AND    duplicate_address_id <> -1; --4693912

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.copy_contacts_in_sites()+' );

    OPEN sites;
    LOOP
       FETCH sites INTO
          from_account_id, to_account_id, from_site_id, to_site_id;
       EXIT WHEN sites%NOTFOUND;

/**
       arp_message.set_line(
           'ARP_CMERGE_ARCUS:copy_contacts_in_sites():from_site_id ' ||
           from_site_id );
       arp_message.set_line(
           'ARP_CMERGE_ARCUS:copy_contacts_in_sites():to_site_id  ' ||
           to_site_id );
**/

       SELECT party_site_id into from_party_site_id
       FROM   hz_cust_acct_sites_all
       WHERE  cust_acct_site_id = from_site_id;

       SELECT party_site_id into to_party_site_id
       FROM   hz_cust_acct_sites_all
       WHERE  cust_acct_site_id = to_site_id;

/**
       arp_message.set_line(
           'ARP_CMERGE_ARCUS:copy_contacts():from_party_site_id '||
           from_party_site_id );
       arp_message.set_line(
           'ARP_CMERGE_ARCUS:copy_contacts():to_party_site_id '||
           to_party_site_id );
**/

       --Based on customer merge high level design:
       --org contact or contact points that the customer contact
       --record refers to must be copied, if only if the merge-from
       --party_site and merge-to party_site are different.

       IF to_party_site_id = from_party_site_id THEN

/**
          arp_message.set_line (
              'ARP_CMERGE_ARCUS:copy_contacts(): ' ||
              'merge_from party and merge_to party site are same. ' ||
              'Do not need copy contact points.' );
**/

          NULL;

       ELSE

          --merge cust contact points in account site level
          do_site_merge_cpoint(
                  from_party_site_id, to_party_site_id,
                  from_account_id, to_account_id );
       END IF;

    END LOOP;
    CLOSE sites;

    arp_message.set_line( 'ARP_CMERGE_ARCUS.copy_contacts_in_sites()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.copy_contacts_in_sites' );
      RAISE;

END copy_contacts_in_sites;

/*===========================================================================+
 | PROCEDURE
 |              ra_cont
 |
 | DESCRIPTION
 |              merge in HZ_CUST_ACCOUNT_ROLES with
 |              role_type = 'CONTACT'
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE ra_cont (
          req_id                NUMBER,
          set_num               NUMBER,
          process_mode          VARCHAR2
) IS

    l_party_id       HZ_CUST_ACCOUNT_ROLES.PARTY_ID%TYPE;

    CURSOR c1 IS
        SELECT cust_account_role_id
        FROM   hz_cust_account_roles yt, ra_customer_merges m
        WHERE  cust_acct_site_id = m.duplicate_address_id
        AND    m.process_flag = 'N'
	AND    m.request_id = req_id
	AND    m.set_number = set_num
        AND    role_type = 'CONTACT'
        FOR UPDATE NOWAIT;

    CURSOR c2 IS
        SELECT cust_account_role_id
        FROM hz_cust_account_roles yt, ra_customer_merges m
        WHERE cust_account_id = m.duplicate_id
        AND   m.process_flag = 'N'
	AND   m.request_id = req_id
        AND   m.set_number = set_num
        AND   cust_acct_site_id IS NULL
        AND   role_type = 'CONTACT'
        FOR UPDATE NOWAIT;
 ----Bug No: 5067291
   CURSOR c3 is
        SELECT yt.party_id
        FROM HZ_CUST_ACCOUNT_ROLES yt,ra_customer_merges m,HZ_CUST_ACCOUNTS ca,hz_relationships rel
        WHERE m.customer_id=ca.cust_account_id
        AND m.duplicate_id = yt.cust_account_id
        AND rel.party_id = yt.party_id
        AND rel.subject_type = 'PERSON'
        AND rel.subject_id = ca.party_id
        AND yt.role_type = 'CONTACT'
        AND m.request_id = req_id
        AND m.process_flag ='N'
        AND m.set_number =set_num
        AND rownum =1;

---Bug NO: 5067291

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_CONT()+' );

    /* locking tables by opening and closing cursors */
    IF process_mode = 'LOCK' then

       arp_message.set_name( 'AR', 'AR_LOCKING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCOUNT_ROLES', FALSE );

       OPEN c1;
       CLOSE c1;

       OPEN c2;
       CLOSE c2;

    ELSE
    OPEN c3;--Bug NO: 5067291
       FETCH c3 INTO l_party_id;
       IF c3%FOUND THEN
          /*********************Inactivate account site/account role...Bug No. 5067291*********/
     arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCOUNT_ROLES', FALSE );
       UPDATE HZ_CUST_ACCOUNT_ROLES yt
      SET  status = 'I',
           last_update_date = sysdate,
           last_updated_by =  hz_utility_v2pub.user_id,
           last_update_login = hz_utility_v2pub.last_update_login,
           request_id =  req_id,
           program_application_id =  hz_utility_v2pub.program_application_id,
           program_id = hz_utility_v2pub.program_id,
           program_update_date = sysdate
       WHERE party_id = l_party_id
       AND nvl(status,'A') ='A';

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCOUNT_ROLES', FALSE );


       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    END IF;

       /************** account site level update ************/

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCOUNT_ROLES', FALSE );

       UPDATE HZ_CUST_ACCOUNT_ROLES yt
       SET (cust_account_id, cust_acct_site_id) = (
                SELECT MIN(m.customer_id), MIN(m.customer_address_id)
                FROM   ra_customer_merges m
                WHERE  yt.cust_account_id = m.duplicate_id
                AND    yt.cust_acct_site_id = m.duplicate_address_id
                AND    m.request_id = req_id
                AND    m.set_number = set_num
                AND    m.process_flag = 'N' ),
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
           last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
           request_id =  req_id,
           program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
           program_id =hz_utility_v2pub.program_id,-- arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE cust_acct_site_id IN (
                SELECT m.duplicate_address_id
                FROM   ra_customer_merges m
                WHERE  m.process_flag = 'N'
		AND    m.request_id = req_id
		AND    m.set_number = set_num )
       AND role_type = 'CONTACT'
      AND party_id <> nvl(l_party_id,-99);---Bug No. 5067291

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       /************** account level update ************/

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCOUNT_ROLES', FALSE );

       UPDATE HZ_CUST_ACCOUNT_ROLES yt
       SET cust_account_id = (
               SELECT m.customer_id
               FROM   ra_customer_merges m
               WHERE  yt.cust_account_id = m.duplicate_id
	       AND    m.request_id = req_id
               AND    m.process_flag = 'N'
	       AND    m.set_number = set_num
               AND    ROWNUM = 1 ),
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
           last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
           request_id =  req_id,
           program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
           program_id =hz_utility_v2pub.program_id,-- arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE cust_account_id IN (
               SELECT m.duplicate_id
               FROM   ra_customer_merges m
               WHERE  m.process_flag = 'N'
	       AND    m.request_id = req_id
               AND    m.set_number = set_num)
       AND cust_acct_site_id IS NULL
       AND role_type = 'CONTACT'
      AND party_id <> nvl(l_party_id,-99);--Bug NO. 5067291


     -- Start Bug 4712462
     FOR rec IN (
       SELECT min(cust_account_role_id) cust_account_role_id, cust_account_id,
              nvl(cust_acct_site_id,-1) cust_acct_site_id,party_id
       FROM   hz_cust_account_roles r, ra_customer_merges m
       where m.request_id = req_id AND    m.set_number = set_num
       AND r.cust_account_id = m.customer_id AND m.process_flag = 'N'
       GROUP BY cust_account_id,cust_acct_site_id,status,party_id
       HAVING NVL(STATUS,'A') ='A' AND count(1) > 1) LOOP
       UPDATE hz_cust_account_roles SET status ='I'
       WHERE  cust_account_role_id     <> rec.cust_account_role_id
       AND    cust_account_id           = rec.cust_account_id
       AND    party_id                  = rec.party_id
       AND    nvl(cust_acct_site_id,-1) = rec.cust_acct_site_id
       AND    nvl(status,'A')           = 'A';

     END LOOP;

    -- End Bug 4712462

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
   CLOSE c3;--5067291
    END IF;

   arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_CONT()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.RA_CONT' );
      RAISE;

END ra_cont;

/*===========================================================================+
 | PROCEDURE
 |              ra_ph
 |
 | DESCRIPTION
 |              merge in HZ_CUST_CONTACT POINTS.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  25-OCT-00  Customer account is global while account
 |                        site is stripped by operating unit. We need to
 |                        check if this account has (active)sites in
 |                        HZ_CUST_ACCT_SITES_ALL.
 |     Jianying Huang  12-DEC-00  Remove cursor c2 and c4 because we
 |                        do not delete rows in hz_cust_contact_points.
 |     Jianying Huang  16-DEC-00  As per discussion with Gautam Prothia,
 |                        since we changed veiw RA_PHONES (see bug 1487607),
 |                        we will migrate phones and org contacts no matter the
 |                        account is active or inactive after merge. Also, we
 |                        will migrate these contact points in party level, not
 |                        in account level.
 |     Jianying Huang  03-APR-01  The procedure is not being calling anymore
 |                        because table hz_cust_contact_points has been obsoleted.
 |
 +===========================================================================*/

PROCEDURE ra_ph (
          req_id                NUMBER,
          set_num               NUMBER,
          process_mode          VARCHAR2
) IS

    --cursor c1 and c2 are used in 'inactivate' mode
    CURSOR c1 IS
        SELECT cust_contact_point_id
        FROM   hz_cust_contact_points yt, ra_customer_merges m
        WHERE  cust_account_site_id = m.duplicate_address_id
        AND    m.process_flag = 'N'
	AND    m.request_id = req_id
	AND    m.set_number = set_num
        FOR UPDATE NOWAIT;

    CURSOR c2 is
        SELECT cust_contact_point_id
        FROM   hz_cust_contact_points yt, ra_customer_merges m
        WHERE  cust_account_id = m.duplicate_id
        AND    m.process_flag = 'N'
        AND    m.request_id = req_id
        AND    m.set_number = set_num
        AND    cust_account_site_id IS NULL
        FOR UPDATE NOWAIT;

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_PH()+' );

    /* locking tables by opening and closing cursors */
    IF process_mode = 'LOCK' THEN

       arp_message.set_name( 'AR', 'AR_LOCKING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_CONTACT_POINTS', FALSE );

       OPEN c1;
       CLOSE c1;

       OPEN c2;
       CLOSE c2;

    ELSE

       /************** account site level inactivate ************/

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_CONTACT_POINTS', FALSE );

       UPDATE HZ_CUST_CONTACT_POINTS yt
       SET (cust_account_id, cust_account_site_id) = (
                SELECT min(m.customer_id), min(m.customer_address_id)
                FROM   ra_customer_merges m
                WHERE  yt.cust_account_id = m.duplicate_id
                AND    yt.cust_account_site_id = m.duplicate_address_id
                AND    m.request_id = req_id
                AND    m.set_number = set_num
                AND    m.process_flag = 'N' ),
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
           last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
           request_id =  req_id,
           program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
           program_id =hz_utility_v2pub.program_id,-- arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE cust_account_site_id IN (
                SELECT m.duplicate_address_id
                FROM   ra_customer_merges m
                WHERE  m.process_flag = 'N'
		AND    m.request_id = req_id
		AND    m.set_number = set_num );

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       /************** account level inactivate ************/

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_CONTACT_POINTS', FALSE );

       UPDATE HZ_CUST_CONTACT_POINTS yt
       SET cust_account_id = (
                SELECT DISTINCT m.customer_id
                FROM   ra_customer_merges m
                WHERE  yt.cust_account_id = m.duplicate_id
                AND    m.request_id = req_id
                AND    m.process_flag = 'N'
                AND    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
           last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
           request_id =  req_id,
           program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
           program_id =hz_utility_v2pub.program_id,-- arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE cust_account_id IN (
                SELECT m.duplicate_id
                FROM   ra_customer_merges m
                WHERE  m.process_flag = 'N'
		AND    m.request_id = req_id
                AND    m.set_number = set_num)
       AND cust_account_site_id IS NULL;

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    END IF;

    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_PH()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.RA_PH' );
      RAISE;

END ra_ph;

--4307679
/*===========================================================================+
 | PROCEDURE
 |              ra_usg
 |
 | DESCRIPTION
 |              Inactivate CUSTOMER usage of merge-from party.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     S V Sowjanya  27-JUL-2005  Created.
 |     S V Sowjanya  17-AUG-2005  Bug No:4558247. Changed the WHERE clause of second UPDATE statement
 |                                               so that it will update only if m.delete_duplicate_flag='Y'
 |
 |
 |      28-OCT-2005  Anuj Singhal Bug No:4558392. In procedure ra_usg,added an update to inactivate active 'CUSTOMER' usage
 |                                of merge-from party when delete after merge is checked for the following condition.If
 |                                there exists any other Inactive accounts AND doesnot exist any active accounts associated
 |                                with the merge-from-party AND there is no other customer usage associated
 |                                with that party. Also changed the where clause of the third update of the                  |                                same procedure so that it deletes the customer usage there are any other
 |                                customer usages associated with that party.
 |                                Also updated the who columns in the HZ_PARTY_USG_ASSIGNMENTS table
 |                                while inactivating the party usg assignment.
 |
 |
 +===========================================================================*/
PROCEDURE ra_usg (
          req_id                NUMBER,
          set_num               NUMBER,
          process_mode          VARCHAR2
) IS
l_dummy varchar2(20);

CURSOR c1 IS

SELECT party_usg_assignment_id
FROM   hz_party_usg_assignments pu
WHERE  party_usage_code = 'CUSTOMER'
AND    EXISTS   (SELECT 'Y'
        	 FROM  ra_customer_merges m, hz_cust_accounts c1
	         WHERE m.duplicate_id = c1.cust_account_id
	         AND c1.party_id = pu.party_id
	         AND m.process_flag = 'N'
                 AND m.request_id = req_id
	         AND m.set_number = set_num
		);


BEGIN

 arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_USG()+' );

    /* locking tables by opening and closing cursors */
    IF process_mode = 'LOCK' THEN

       arp_message.set_name( 'AR', 'AR_LOCKING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_PARTY_USG_ASSIGNMENTS', FALSE );

       OPEN c1;
       CLOSE c1;

    ELSE
       /*************** 'inactivate' mode ***************/

       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_PARTY_USG_ASSIGNMENTS', FALSE );

       --inactivate active 'CUSTOMER' usage  of merge-from party if the merge-from account is the only active account


	UPDATE hz_party_usg_assignments pu
        SET    effective_end_date = trunc(sysdate),
               status_flag = 'I',
               --Bug No. 4558392
               last_update_date=sysdate,
               last_updated_by = hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
               last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
               request_id =  req_id,
               program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
               program_id =hz_utility_v2pub.program_id-- arp_standard.profile.program_id
               --Bug No. 4558392
        WHERE  party_usage_code = 'CUSTOMER'
        AND   nvl(effective_end_date,sysdate+1)>=sysdate
        AND    status_flag = 'A'
	AND NOT EXISTS( SELECT 'Y' FROM hz_cust_accounts c
	                 WHERE c.party_id = pu.party_id
                         AND   c.status ='A'
		       )
        AND  EXISTS (SELECT 'Y'
                       FROM  ra_customer_merges m, hz_cust_accounts c1
                       WHERE m.request_id = req_id
		       AND   m.process_flag = 'N'
		       AND   m.set_number = set_num
		       AND   m.delete_duplicate_flag = 'N'
		       AND   m.customer_id <> c1.cust_account_id --Site merge
		       AND   m.duplicate_id =  c1.cust_account_id
		       AND   c1.party_ID    =  pu.party_id
                       AND   c1.status      =  'I'
		       );
        g_count := sql%rowcount;

        arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
        arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

        /*************** 'delete' mode ***************/
 ---Bug No. 4558392
       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_PARTY_USG_ASSIGNMENTS', FALSE );

       --inactivate active 'CUSTOMER' usage  of merge-from party when delete after merge is checked if
       -- There exists any other Inactive accounts AND doesnot exist any active accounts associated with the merge-from
       --party AND there is no other customer usage associated with that party.


	UPDATE hz_party_usg_assignments pu
        SET    effective_end_date = trunc(sysdate),
               status_flag = 'I',

               last_update_date=sysdate,
               last_updated_by = hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
               last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
               request_id =  req_id,
               program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
               program_id =hz_utility_v2pub.program_id-- arp_standard.profile.program_id

        WHERE  party_usage_code = 'CUSTOMER'
        AND   nvl(effective_end_date,sysdate+1)>=sysdate
        AND    status_flag = 'A'
	AND EXISTS( SELECT 'Y' FROM hz_cust_accounts c
	                 WHERE c.party_id = pu.party_id
                         AND   c.status ='I'
                         AND rownum=1
                       )
 	AND NOT EXISTS( SELECT 'Y' FROM hz_cust_accounts c
	                 WHERE c.party_id = pu.party_id
                         AND   c.status ='A'
                         AND rownum=1
                       )

        AND NOT EXISTS (SELECT 'Y'
                                  from hz_party_usg_assignments
                                  where party_id=pu.party_id
                                  and party_usage_code='CUSTOMER'
                                  and party_usg_assignment_id <> pu.party_usg_assignment_id
                                  and rownum=1)


        AND  EXISTS (SELECT 'Y'
                       FROM  ra_customer_merges m, hz_cust_accounts c1
                       WHERE m.request_id = req_id
		       AND   m.process_flag = 'N'
		       AND   m.set_number = set_num
		       AND   m.delete_duplicate_flag = 'Y'--Bug No. 4558392
		       AND   m.customer_id <> c1.cust_account_id --Site merge
		       AND   m.duplicate_id =  c1.cust_account_id
		       AND   c1.party_ID    =  pu.party_id
                       AND   c1.status      =  'D'--Bug No. 4558392
		       );
        g_count := sql%rowcount;

        arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
        arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

-----Bug No. 4558392
              /*************** 'delete' mode ***************/



        arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
        arp_message.set_token( 'TABLE_NAME', 'HZ_PARTY_USG_ASSIGNMENTS', FALSE );

	--Delete all 'CUSTOMER' usage of merge-from party
	--if the merge-from account is the only account for merge-from party OR there are any other customer usages associated with that party.

	UPDATE hz_party_usg_assignments pu
        SET    effective_end_date = trunc(sysdate),
               status_flag = 'D'
        WHERE  pu.party_usage_code = 'CUSTOMER'

	AND    (
                 NOT EXISTS (SELECT 'Y'
                             FROM hz_cust_accounts c  --delete if from account is the only account for merge-from party
	                     WHERE c.party_id = pu.party_id
	                     AND   c.status in ('A','I')
                            )
--Bug No.4558392
                OR  (   pu.status_flag='A' AND  nvl(pu.effective_end_date,sysdate+1)>=sysdate AND
                           exists (SELECT 'Y'
                                  from hz_party_usg_assignments
                                  where party_id=pu.party_id
                                  and party_usage_code='CUSTOMER'
                                  and party_usg_assignment_id <> pu.party_usg_assignment_id
                                  and rownum=1)
                     )
                  )


                /* OR (pu.status_flag = 'A' AND trunc(sysdate) < pu.effective_end_date  --delete only active usage if merge-from party has inactive accounts
                     AND NOT EXISTS (SELECT 'Y' FROM hz_cust_accounts c
	                             WHERE c.party_id = pu.party_id
		                     AND   c.status = 'A')
                    )*/
----Bug No.4558392
        AND    EXISTS (SELECT 'Y'
                       FROM  ra_customer_merges m, hz_cust_accounts c1
                       WHERE m.request_id = req_id
		       AND   m.process_flag = 'N'
		       AND   m.set_number = set_num
		       AND   m.delete_duplicate_flag = 'Y'
		       AND   m.customer_id <> c1.cust_account_id --Site merge
		       AND   m.duplicate_id =  c1.cust_account_id
		       AND   c1.party_ID    =  pu.party_id
                       AND   c1.status      =  'D'
		       );

        g_count := sql%rowcount;

        arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
        arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


    END IF;
    arp_message.set_line( 'ARP_CMERGE_ARCUS.RA_USG()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.RA_USG' );
      RAISE;
END ra_usg;
--4307679


/*===========================================================================+
 | PROCEDURE
 |              do_cust_merge_contacts
 |
 | DESCRIPTION
 |              merge in HZ_CUST_ACCOUNT_ROLES with
 |              role_type = 'CONTACT' in account level
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_from_party_id
 |                    p_to_party_id
 |                    p_from_account_id
 |                    p_to_account_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  25-OCT-00  Based on customer merge high level
 |                        design (page 12): if party auto-numbering is
 |                        turned on, a new party number should be generated
 |                        for the copy (this has been taken care of by
 |                        HZ_PARTY_PUB API). If auto-numbering is turned
 |                        off, a new party number can be created by
 |                        taking the existing party number and appending
 |                        '-C' to the end of represent the copy.
 |     Jianying Huang  25-OCT-00  Remove call
 |                                  do_update_dup_party_rec
 |                                  do_update_dup_party_rel_rec
 |                        because HZ_PARTY_PUB.create_org_contact will
 |                        create party_relationship and party automatically.
 |                        The new party_relationship_rec =
 |                              org_contact_rec.party_rel_rec ) and
 |                        the new party_rec =
 |                              org_contact_rec.party_rel_rec.party_rec
 |     Jianying Huang  25-OCT-00  After call create_org_contact API,
 |                        if return_status is not 'success', we need to
 |                        populate an exception.
 |     Jianying Huangn 27-OCT-00  Since contacts of 'phone' type also goes
 |                        as customer contact points, we'd better to migrate
 |                        it here because it should be a phone number for
 |                        contacts as well as for accounts.
 |     Jianying Huang  16-DEC-00  Move common code to do_merge_contacts.
 |
 |
 +===========================================================================*/

PROCEDURE do_cust_merge_contacts (
          p_from_party_id          NUMBER,
          p_to_party_id            NUMBER,
          p_from_account_id        NUMBER,
          p_to_account_id          NUMBER
) IS

    l_org_contact_id               NUMBER;
    l_cust_acct_role_id            NUMBER;
    l_org_contact_party_id         NUMBER;
    l_org_contact_party_rel_id     NUMBER;

    x_org_party_id                 NUMBER;

    --select party, party_relationships, and org_contact ID
    --will call API: HZ_PARTY_PUB.get_current_* to get the records
    --This is for the consistence purpose in case of data model changes.
    CURSOR c IS
        SELECT
           --Account Role
           cust_account_role_id,
           --FOR PARTY REC
           rel.party_id,
           --FOR PARTY REL REC
           rel.relationship_id,
           -- FOR ORG-CONTACT REC
	   org.org_contact_id
        FROM  hz_cust_account_roles acct_role,
              hz_org_contacts org,
              hz_relationships rel,
              hz_cust_accounts acct
        WHERE acct_role.role_type = 'CONTACT'
        AND   acct_role.cust_account_id = p_from_account_id
        AND   acct_role.cust_acct_site_id IS NULL
        AND   acct_role.party_id = rel.party_id
        AND   org.party_relationship_id = rel.relationship_id
        AND   rel.subject_table_name = 'HZ_PARTIES'
        AND   rel.object_table_name = 'HZ_PARTIES'
        AND   acct_role.cust_account_id = acct.cust_account_id
        AND   acct.party_id   = rel.object_id
        AND  rel.subject_id <> p_to_party_id ;--5067291
/*      AND   rel.directional_flag = 'F';   */  /* Bug No : 2359461 */

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.do_cust_merge_contacts()+' );

    /* Copy org contact */
    OPEN c;
    LOOP
      FETCH c INTO
         l_cust_acct_role_id,
         -- FOR PARTY REC
         l_org_contact_party_id,
         -- FOR PARTY REL REC
         l_org_contact_party_rel_id,
         -- FOR ORG-CONTACT REC
	 l_org_contact_id;

      EXIT WHEN c%NOTFOUND;

      do_merge_contacts( 'ACCOUNT_LEVEL',
                         p_from_account_id,
                         l_org_contact_party_id,
                         l_org_contact_party_rel_id,
                         l_org_contact_id,
                         p_to_party_id,
                         x_org_party_id );

      -- Update the customer org contact with the new org contact id.
      UPDATE hz_cust_account_roles
      SET    party_id = x_org_party_id
      WHERE  cust_account_role_id = l_cust_acct_role_id;

    END LOOP;
    CLOSE c;

    arp_message.set_line( 'ARP_CMERGE_ARCUS.do_cust_merge_contacts()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.do_cust_merge_contacts' );
      RAISE;

END do_cust_merge_contacts;

/*===========================================================================+
 | PROCEDURE
 |              do_site_merge_contacts
 |
 | DESCRIPTION
 |              merge in HZ_CUST_ACCOUNT_ROLES with
 |              role_type = 'CONTACT' in account site level
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_from_party_id
 |                    p_to_party_id
 |                    p_from_account_id
 |                    p_to_account_id
 |                    p_req_id
 |                    p_set_num
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  25-OCT-00  Based on customer merge high level
 |                        design (page 12): if party auto-numbering is
 |                        turned on, a new party number should be generated
 |                        for the copy (this has been taken care of by
 |                        HZ_PARTY_PUB API). If auto-numbering is turned
 |                        off, a new party number can be created by
 |                        taking the existing party number and appending
 |                        '-C' to the end of represent the copy.
 |     Jianying Huang  25-OCT-00  Remove call
 |                                  do_update_dup_party_rec
 |                                  do_update_dup_party_rel_rec
 |                        because HZ_PARTY_PUB.create_org_contact will
 |                        create party_relationship and party automatically.
 |                        The new party_relationship_rec =
 |                              org_contact_rec.party_rel_rec ) and
 |                        the new party_rec =
 |                              org_contact_rec.party_rel_rec.party_rec
 |     Jianying Huang  25-OCT-00  After call create_org_contact API,
 |                        if return_status is not 'success', we need to
 |                        populate an exception.
 |     Jianying Huangn 27-OCT-00  Since contacts of 'phone' type also goes
 |                        as customer contact points, we'd better to migrate
 |                        it here because it should be a phone number for
 |                        contacts as well as for accounts.
 |     Jianying Huang  16-DEC-00  Move common code to do_merge_contacts.
 |     Jianying Huang  28-DEC-00  Since we ignore hz_org_contacts.party_site_id
 |                        in account merge context, we do not need select merge-to's
 |                        address id.
 |
 +===========================================================================*/

PROCEDURE do_site_merge_contacts(
          p_from_party_id         NUMBER,
          p_to_party_id           NUMBER,
          p_from_account_id       NUMBER,
          p_to_account_id         NUMBER,
          p_req_id                NUMBER,
          p_set_num               NUMBER
) IS

    --account site ids
    from_site_id                  NUMBER;
    to_site_id                    NUMBER;

    --party site ids
    from_party_site_id            NUMBER;
    to_party_site_id              NUMBER;
    l_to_party_site_id            NUMBER;

    l_org_contact_party_id        NUMBER;
    l_org_contact_party_rel_id    NUMBER;
    l_org_contact_id              NUMBER;
    l_cust_acct_role_id           NUMBER;
    l_org_contact_party_site_id   NUMBER;

    x_org_party_id                NUMBER;

    --select party, party_relationships, and org_contact ID
    --will call API: HZ_PARTY_PUB.get_current_* to get the records
    --This is for the consistence purpose in case of data model changes.
    CURSOR c IS
        SELECT
           -- Account Role
           acct_role.cust_account_role_id,
           -- FOR PARTY REC
           rel.party_id,
           -- FOR PARTY REL REC
	   rel.relationship_id,
           -- FOR ORG-CONTACT REC
	   org.org_contact_id
--as per discussion with Gautam Prothia, we ignore party_site_id in customer
--merge context
--         org.party_site_id
        FROM hz_cust_account_roles acct_role,
             hz_org_contacts org,
             hz_relationships rel,
             hz_cust_accounts acct
        WHERE acct_role.role_type = 'CONTACT'
        AND   acct_role.cust_account_id = p_from_account_id
        AND   acct_role.cust_acct_site_id = from_site_id
        AND   acct_role.party_id = rel.party_id
        AND   org.party_relationship_id = rel.relationship_id
        AND   rel.subject_table_name = 'HZ_PARTIES'
        AND   rel.object_table_name = 'HZ_PARTIES'
        AND   acct_role.cust_account_id = acct.cust_account_id
        AND   acct.party_id   = rel.object_id
        AND   rel.subject_id <> p_to_party_id;--5067291
/*      AND   rel.directional_flag = 'F'; */ /* Bug No : 2359461 */

    --select merge_from/to account site id.
    --we will no longer select merge-to address id because
    --party_site_id in hz_org_contacts is ignored in customer
    --merge context.

    CURSOR d IS
        SELECT DISTINCT duplicate_address_id    --, customer_address_id
        FROM   ra_customer_merges
        WHERE  duplicate_id = p_from_account_id
        AND    customer_id = p_to_account_id
        AND    process_flag = 'N'
        AND    request_id = p_req_id
        AND    set_number = p_set_num;

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.do_site_merge_contacts()+' );

    /* For each site level org contact do the following */
    OPEN d;
    LOOP
      FETCH d INTO from_site_id;   --, to_site_id;
      EXIT WHEN d%NOTFOUND;

/* as per discussion with Gautam Prothia, we ignore party_site_id in customer
   merge context

      SELECT ass.party_site_id into from_party_site_id
      FROM hz_cust_acct_sites ass
      WHERE cust_acct_site_id = from_site_id;

      SELECT ass.party_site_id into to_party_site_id
      FROM hz_cust_acct_sites ass
      WHERE cust_acct_site_id = to_site_id;
*/

      --sitet level org contact merge */
      OPEN c;
      LOOP
        FETCH c INTO
           l_cust_acct_role_id,
           -- FOR PARTY REC
           l_org_contact_party_id,
           -- FOR PARTY REL REC
           l_org_contact_party_rel_id,
           -- FOR ORG-CONTACT REC
	   l_org_contact_id;

--as per discussion with Gautam Prothia, we ignore party_site_id in customer
--merge context
--         l_org_contact_party_site_id;

        EXIT WHEN c%NOTFOUND;

--as per discussion with Gautam Prothia, we ignore party_site_id in customer
--merge context
/*
        IF org_contact_party_site_id IS NOT NULL THEN
           l_to_party_site_id := to_party_site_id;
        END IF;
*/

        do_merge_contacts( 'SITE_LEVEL',
                           p_from_account_id,
                           l_org_contact_party_id,
                           l_org_contact_party_rel_id,
                           l_org_contact_id,
                           p_to_party_id,
                           x_org_party_id );

        -- Update the customer org contact with the new org contact id.
        UPDATE hz_cust_account_roles
        SET party_id = x_org_party_id
        WHERE cust_account_role_id = l_cust_acct_role_id;

      END LOOP;
      CLOSE c;

    END LOOP;
    CLOSE d;

    arp_message.set_line( 'ARP_CMERGE_ARCUS.do_site_merge_contacts()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.do_site_merge_contacts' );
      RAISE;

END do_site_merge_contacts;

/*===========================================================================+
 | PROCEDURE
 |              do_merge_contacts
 |
 | DESCRIPTION
 |              Common part of do_cust/site_merge_contacts
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_level
 |                    p_from_account_id
 |                    p_org_party_id
 |                    p_org_party_rel_id
 |                    p_org_contact_id
 |                    p_to_party_id
 |                    p_to_party_site_id
 |
 |          IN/ OUT:
 |              OUT:
 |                    x_org_party_id
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  16-DEC-00  Creaded. Move the common part of
 |                        do_cust_merge_contacts and do_site_merge_contacts into
 |                        this procedure.
 |     Jianying Huang  16-DEC-00  Use API to get party, party_rel, org_contact
 |                        records. This is for the consistence purpose in case of
 |                        data model changes.
 |     Jianying Huang  17-DEC-00  Check duplicate org contact before create a new one.
 |     Jianying Huang  17-DEC-00  As discussion with Gautam Prothia, we should copy
 |                        all types of contact points in party level
 |     Jianying Huang  20-DEC-00  Bug 1535542: Use global temporary table
 |                        to store the mapping of old org_contact_id and new
 |                        org_contact_id when migrate org contacts.
 |     Jyoti Pandey    06-NOV-01 Bug:2098728 Changing all API call outs to call
 |                        Package HZ_CUST_ACCOUNT_MERGE_V2PVT
 |                        Eliminated calls to get_party_rec and get_relationship_rec
 |                        Instead call to get_org_contact gets party and relationship recs
 |
 +===========================================================================*/

PROCEDURE do_merge_contacts (
          p_level                   VARCHAR2,
          p_from_account_id         NUMBER,
          p_org_party_id            NUMBER,
          p_org_party_rel_id        NUMBER,
          p_org_contact_id          NUMBER,
          p_to_party_id             NUMBER,
          x_org_party_id        OUT NOCOPY NUMBER,
          p_to_party_site_id        NUMBER DEFAULT NULL
) IS
    ---|Bug:2098728 don't need this as we internally call relationship and party
    ---|from org_contacts
    ---|l_party_rec                  HZ_PARTY_V2PUB.PARTY_REC_TYPE;
    ---|l_party_rel_rec              HZ_RELATIONSHIP_V2PUB.relationship_rec_type ;
    l_org_contact_rec                 HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;

    --returned by calling create_org_contact API.
    x_org_contact_id             NUMBER;
    x_party_rel_id               NUMBER;
    x_party_number               VARCHAR2(30);

    --error message handling.
    x_msg_count                  NUMBER := 0;
    x_return_status              VARCHAR2(100);
    x_msg_data                   VARCHAR2(2000);

    l_dup_exists                 VARCHAR2(10) := FND_API.G_FALSE;
    l_insert                     VARCHAR2(10) := FND_API.G_FALSE;
    l_sql                        VARCHAR2(1000);
    l_direction_code             VARCHAR2(30);
     --Start of Bug No: 4387523
    CURSOR c_party_type(p_party_id NUMBER) IS SELECT party_type from hz_parties
    where party_id = p_party_id;
    l_party_type varchar2(30);
    --End of Bug No: 4387523
BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.do_merge_contacts()+' );

    --check if the org contact has been migrated
    BEGIN
       l_sql := 'SELECT new_id ' ||
                'FROM ' || g_table_name || ' ' ||
                'WHERE old_id = :id' || ' ' ||
                'AND type = ''ORG_CONTACT''';

       EXECUTE IMMEDIATE l_sql INTO x_org_contact_id USING p_org_contact_id;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
    END;

    --the org contact has been migrated
    IF x_org_contact_id IS NOT NULL THEN

       l_dup_exists := FND_API.G_TRUE;
    ELSE
       --the org contact has not been migrated

       l_dup_exists := check_org_contact_dup (
                             p_org_contact_id,
                             p_org_party_rel_id,
                             p_to_party_id,
                             x_org_contact_id ,
                             p_from_account_id);

--arp_message.set_line( '****' || to_char(x_org_contact_id) ||
--'****' || l_dup_exists );

       IF l_dup_exists = FND_API.G_TRUE THEN
          l_insert := FND_API.G_TRUE;

       END IF;

    END IF;

    IF l_dup_exists = FND_API.G_TRUE THEN
       SELECT party_id INTO x_org_party_id
       FROM hz_relationships
       WHERE relationship_id = (
          SELECT party_relationship_id
          FROM hz_org_contacts
          WHERE org_contact_id = x_org_contact_id )
            AND subject_table_name =  'HZ_PARTIES'
            AND object_table_name = 'HZ_PARTIES'
            AND rownum = 1;
/*          AND directional_flag = 'F';  */ /* Bug No : 2359461 */

    ELSE
       --duplicate not exist. Create new org contacts.
       --call API to get merge-from's org contact info.

      ---Bug:2098728
       --get org contact info.
        HZ_CUST_ACCOUNT_MERGE_V2PVT.get_org_contact_rec (
                              FND_API.G_TRUE,
                              p_org_contact_id,
                              l_org_contact_rec,
                              l_direction_code,
                              x_return_status,
                              x_msg_count,
                              x_msg_data );

      IF x_msg_count = 1 THEN
          x_msg_data := x_msg_data || '**GET_CURRENT_ORG_CONTACT**';
          arp_message.set_line(
              'do_merge_contacts:get_org_contact_rec ERROR ' ||
              x_msg_data );
       ELSIF x_msg_count > 1 THEN

         FOR x IN 1..x_msg_count LOOP
              x_msg_data := FND_MSG_PUB.GET(p_encoded => fnd_api.g_false);
              x_msg_data := x_msg_data || '**GET_CURRENT_ORG_CONTACT**';
              arp_message.set_line(
                  'do_merge_contacts:get_org_contact_rec ERROR ' ||
                  x_msg_data );
          END LOOP;
       END IF;

       --- After call create_org_contact API, if return_status is not
       --- 'success', we need to populate an exception.
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       -------Bug:2098728 Relationship ID is set to null in PKG
       -------Genereating the new party number for new records
       l_org_contact_rec.org_contact_id := NULL;
       l_org_contact_rec.party_rel_rec.party_rec.party_number := NULL;

       -------Update the new party relationship rec with the merge-to party
       l_org_contact_rec.party_rel_rec.object_id :=  p_to_party_id;
        --Start of Bug No: 4387523
	if(l_org_contact_rec.party_rel_rec.object_table_name ='HZ_PARTIES') then
	  open c_party_type(l_org_contact_rec.party_rel_rec.object_id);
	  fetch c_party_type into l_party_type;
	  close c_party_type;
	  l_org_contact_rec.party_rel_rec.object_type := l_party_type;
	end if;
	--End of Bug No: 4387523

      /** Based on the customer merge high level design:
         if party auto-numbering is turned on, a new party number should
         be generated for the copy (this has been taken care of by
         HZ_PARTY_PUB API). If auto-numbering is turned off, a
         new party number can be created by taking the existing
         party number and appending '-C' to the end of represent the copy.*/
     /*|  IF fnd_profile.value('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
       |  l_org_contact_rec.party_rel_rec.party_rec.party_number :=
       |                   l_org_contact_rec.party_rel_rec.party_rec.party_number || '-C';
       |ELSE
       |   l_org_contact_rec.party_rel_rec.party_rec.party_number := NULL;
       |END IF;*/


       ---as per discussion with Gautam Prothia, we ignore party_site_id in customer
       ---merge context
       l_org_contact_rec.party_site_id := NULL;


        ---Bug:2098728
       /* Create the org contact record */
        HZ_CUST_ACCOUNT_MERGE_V2PVT.create_org_contact(
                              p_init_msg_list   =>FND_API.G_TRUE,
                              p_org_contact_rec => l_org_contact_rec,
                              p_direction_code => l_direction_code,
                              x_org_contact_id  => x_org_contact_id,
                              x_party_rel_id    => x_party_rel_id,
                              x_party_id        => x_org_party_id,
                              x_party_number    => x_party_number,
                              x_return_status   => x_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data);

       IF x_msg_count = 1 THEN
          x_msg_data := x_msg_data || '**CREATE_ORG_CONTACT**';
          arp_message.set_line(
              'do_merge_contacts:create_org_contact ERROR ' ||
               x_msg_data );
       ELSIF x_msg_count > 1 THEN

          FOR x IN 1..x_msg_count LOOP
              x_msg_data := FND_MSG_PUB.GET(p_encoded => fnd_api.g_false);
              x_msg_data := x_msg_data || '**CREATE_ORG_CONTACT**';
              arp_message.set_line(
                  'do_cust_merge_contacts:create_org_contact ERROR ' ||
                  x_msg_data );
          END LOOP;
       END IF;

       /** After call create_org_contact API, if return_status is not
        'success', we need to populate an exception. */
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       l_insert := FND_API.G_TRUE;

    END IF;

    IF l_insert = FND_API.G_TRUE THEN

--Bug 1535542: insert the mapping of old org_contact_id and new org_contact_id

       BEGIN
          l_sql := 'INSERT INTO ' || g_table_name || ' ' ||
                   'VALUES (' ||
                   '''ORG_CONTACT''' || ',' ||
                   to_char(p_org_contact_id) || ', ' ||
                   to_char(x_org_contact_id) || ')';

          EXECUTE IMMEDIATE l_sql;

       END;
    END IF;

/**N/A
    --Since contacts of 'phone' type also goes as customer contact
    --points, we'd better to migrate it here because it should be
    --a phone number for contacts as well as for accounts.
**/
    --As discussion with Gautam Prothia, we should copy all types of
    --contact points in party level



    do_copy_contact_points ( 'HZ_PARTIES',
                             p_org_party_id,
                             x_org_party_id,
                             p_from_account_id );

    arp_message.set_line( 'ARP_CMERGE_ARCUS.do_merge_contacts()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.do_merge_contacts' );
      RAISE;

END do_merge_contacts;

/*===========================================================================+
 | PROCEDURE
 |              do_cust_merge_cpoint
 |
 | DESCRIPTION
 |              merge customer contact points in account level.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_from_party_id
 |                    p_to_party_id
 |                    p_from_account_id
 |                    p_to_account_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  25-OCT-00  After call create_contact_points API,
 |                        if return_status is not 'success', we need to
 |                        populate an exception.
 |     Jianying Huang  27-OCT-00  Bug 1415529: If both raw_phone_number and
 |                        phone_number have value, use phone_number and set
 |                        raw_phone_number to NULL. Otherwise, API would
 |                        error out.
 |     Jianying Huang  27-OCT-00  We should migrate those phones only for
 |                        accounts/sites here, not the phones for contact
 |                        persons. Those phones have been taken care of
 |                        by do_cust(site)_merge_contacts.
 |     Jianying Huang  17-DEC-00  As discussion with Gautam Prothia, we
 |                        should copy all types of contact points in party level
 |
 +===========================================================================*/

PROCEDURE do_cust_merge_cpoint (
          p_from_party_id         NUMBER,
          p_to_party_id           NUMBER,
          p_from_account_id       NUMBER,
          p_to_account_id         NUMBER
) IS

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.do_cust_merge_cpoint()+' );

    do_copy_contact_points ( 'HZ_PARTIES',
                             p_from_party_id,
                             p_to_party_id,
                             p_from_account_id );

    arp_message.set_line( 'ARP_CMERGE_ARCUS.do_cust_merge_cpoint()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.do_cust_merge_cpoint' );
      RAISE;

END do_cust_merge_cpoint;

/*===========================================================================+
 | PROCEDURE
 |              do_site_merge_cpoint
 |
 | DESCRIPTION
 |              merge customer contact points in account site level.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    from_party_id
 |                    to_party_id
 |                    from_account_id
 |                    to_account_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  25-OCT-00  After call create_contact_points API,
 |                        if return_status is not 'success', we need to
 |                        populate an exception.
 |     Jianying Huang  27-OCT-00  Bug 1415529: If both raw_phone_number and
 |                        phone_number have value, use phone_number and set
 |                        raw_phone_number to NULL. Otherwise, API would
 |                        error out.
 |     Jianying Huang  27-OCT-00  We should migrate those phones only for
 |                        accounts/sites here, not the phones for contact
 |                        persons. Those phones have been taken care of
 |                        by do_cust(site)_merge_contacts.
 |     Jianying Huang  17-DEC-00  As discussion with Gautam Prothia, we
 |                        should copy all types of contact points in party level
 |
 +===========================================================================*/

PROCEDURE do_site_merge_cpoint (
          p_from_party_site_id         NUMBER,
          p_to_party_site_id           NUMBER,
          p_from_account_id            NUMBER,
          p_to_account_id              NUMBER
) IS

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.do_site_merge_cpoint()+' );

    do_copy_contact_points ( 'HZ_PARTY_SITES',
                             p_from_party_site_id,
                             p_to_party_site_id,
                             p_from_account_id );

    arp_message.set_line( 'ARP_CMERGE_ARCUS.do_site_merge_cpoint()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.do_site_merge_cpoint' );
      RAISE;

END do_site_merge_cpoint;

/*===========================================================================+
 | PROCEDURE
 |              do_copy_contact_points
 |
 | DESCRIPTION
 |              copy contact points
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_owner_table_name
 |                    p_from_id
 |                    p_to_id
 |                    p_from_account_id
 |
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |     Jianying Huang  25-OCT-00  Remove parameter orgContactId. from_party_id
 |                        should be used by cursor. Add new condition:
 |                        hz_contact_points.owner_table_name = 'HZ_PARTIES'
 |     Jianying Huang  25-OCT-00  After call create_contact_point API,
 |                        if return_status is not 'success', we need to
 |                        populate an exception.
 |     Jianying Huang  27-OCT-00  Since contacts of 'phone' type also goes
 |                        as customer contact points, we'd better to migrate
 |                        it here because it should be a phone number for
 |                        contacts as well as for accounts.
 |     Jianying Huang  16-DEC-00  As per discussion with Gautam Prothia,
 |                        since we changed veiw RA_PHONES (see bug 1487607),
 |                        we will migrate all types of contact points in party
 |                        level, not in account level.
 |
 +===========================================================================*/

  PROCEDURE do_copy_contact_points (
    p_owner_table_name         VARCHAR2,
    p_from_id                  NUMBER,
    p_to_id                    NUMBER,
    p_from_account_id          NUMBER
  ) IS

    l_contact_point_id         NUMBER;

    ----Bug:2098728 Changing to V2
    l_contact_point_rec        hz_contact_point_v2pub.contact_point_rec_type;
    l_edi_rec                  hz_contact_point_v2pub.edi_rec_type;
    l_eft_rec                  hz_contact_point_v2pub.eft_rec_type;
    l_email_rec                hz_contact_point_v2pub.email_rec_type;
    l_phone_rec                hz_contact_point_v2pub.phone_rec_type;
    l_telex_rec                hz_contact_point_v2pub.telex_rec_type;
    l_web_rec                  hz_contact_point_v2pub.web_rec_type;

    --error message handling.
    x_contact_point_id         NUMBER;
    x_msg_count                NUMBER := 0;
    x_return_status            VARCHAR2(100);
    x_msg_data                 VARCHAR2(2000);

    --select contact points records.
    --will call API to get records. This is for the consistence purpose
    --in case of data model changes

    CURSOR c IS
      SELECT contact_point_id
      FROM   hz_contact_points
      WHERE  owner_table_name = p_owner_table_name
             AND owner_table_id = p_from_id;

    l_dup_exists                 VARCHAR2(10) := fnd_api.g_false;

  BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.do_copy_contact_points ()+' );

    OPEN c;
    LOOP
      FETCH c INTO l_contact_point_id;

      EXIT WHEN c%NOTFOUND;

      l_dup_exists := check_contact_point_dup (l_contact_point_id,
                                               p_to_id,
                                               x_contact_point_id);

      --arp_message.set_line( '****' || to_char(x_contact_point_id) ||
      --'****' || l_dup_exists );

      IF l_dup_exists <> fnd_api.g_true THEN

        --duplicate not exist. Create new org contacts.
        --call API to get contact points info.
        ----Bug:2098728 Changing to V2
        ----Bug 2116225: Added support for banks (EFT).
        hz_cust_account_merge_v2pvt.get_contact_point_rec (
          p_init_msg_list =>  FND_API.G_TRUE,
          p_contact_point_id  => l_contact_point_id,
          x_contact_point_rec => l_contact_point_rec,
          x_edi_rec           => l_edi_rec,
          x_eft_rec           => l_eft_rec,
          x_email_rec         => l_email_rec,
          x_phone_rec         => l_phone_rec,
          x_telex_rec         => l_telex_rec,
          x_web_rec           => l_web_rec,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data);
        arp_message.set_line('ID ' || l_contact_point_rec.owner_table_id);

        IF x_msg_count = 1 THEN
          x_msg_data := x_msg_data || '**GET_CURRENT_CONTACT_POINTS**';
          arp_message.set_line(
            'do_copy_contact_points:get_current_contact_points ERROR ' ||
            x_msg_data );
        ELSIF x_msg_count > 1 THEN

          FOR x IN 1..x_msg_count LOOP
            x_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
            x_msg_data := x_msg_data || '**GET_CURRENT_CONTACT_POINTS**';
            arp_message.set_line(
              'do_copy_contact_points:get_current_contact_points ERROR ' ||
              x_msg_data );
          END LOOP;
        END IF;

        -- After call create_org_contact API, if return_status is not
        -- 'success', we need to populate an exception.
        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        l_contact_point_rec.contact_point_id :=  NULL;
        l_contact_point_rec.primary_flag :=  NULL;
        l_contact_point_rec.owner_table_id := p_to_id;

        arp_message.set_line('ID ' || l_contact_point_rec.owner_table_id);

        --We should not copy the following columns. They are supposed to be
        --unique
        l_edi_rec.edi_tp_header_id := NULL;
        l_edi_rec.edi_ece_tp_location_code :=  NULL;

        --create contact point with email type
        ----Bug:2098728 Changing to V2
        ----Bug 2116225: Added support for banks (EFT).
        hz_cust_account_merge_v2pvt.create_contact_point (
          fnd_api.g_true,
          l_contact_point_rec,
          l_edi_rec,
          l_eft_rec,
          l_email_rec,
          l_phone_rec,
          l_telex_rec,
          l_web_rec,
          x_contact_point_id,
          x_return_status,
          x_msg_count,
          x_msg_data);

        IF x_msg_count = 1 THEN
           x_msg_data := x_msg_data || '**CREATE_CONTACT_POINTS**';
          arp_message.set_line(
            'do_copy_contact_points:create_contact_points  Error '||
             x_msg_data);
        ELSIF x_msg_count > 1 THEN

          FOR x IN 1..x_msg_count LOOP
            x_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
            x_msg_data := x_msg_data || '**CREATE_CONTACT_POINTS**';
            arp_message.set_line(
              'do_copy_contact_points:create_contact_points ERROR ' ||
              x_msg_data );
          END LOOP;
        END IF;

        -- After call create_org_contact API, if return_status is not
        --  'success', we need to populate an exception.
        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

/**
        arp_message.set_line(
          'ARP_CMERGE_ARCUS:do_copy_contact_points():old contact point id =' ||
          l_contact_point_id );

        arp_message.set_line(
          'ARP_CMERGE_ARCUS.do_copy_contact_points:contact_point_id = ' ||
          x_contact_point_id );
**/

      END IF;

/**
      --comments out the following statement because table hz_cust_contact_points
      --has been obsoleted.
      -- Update the customer contact points with the new contact point id.
      UPDATE hz_cust_contact_points
      SET    contact_point_id = x_contact_point_id
      WHERE  contact_point_id = l_contact_point_id
      AND    cust_account_id = p_from_account_id;
**/
    END LOOP;
    CLOSE c;

    arp_message.set_line( 'ARP_CMERGE_ARCUS.do_copy_contact_points()-' );

  EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.do_copy_contact_points' );
      RAISE;

  END do_copy_contact_points;

/*===========================================================================+
 | FUNCTION
 |              check_org_contact_dup
 |
 | DESCRIPTION
 |              Since org contact can be shared by different accounts, account
 |              sites, when migrate org contacts, before create a new org contact,
 |              we should check if there is an identical one already exist. If yes,
 |              pick it up.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_from_org_contact_id
 |                    p_from_party_rel_id
 |                    p_to_party_id
 |              OUT:
 |                    x_org_contact_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |     Jianying Huang  17-DEC-00  Created to check if there is an identical org
 |                        contact exist in database.
 |
 +===========================================================================*/

FUNCTION check_org_contact_dup (
        p_from_org_contact_id         NUMBER,
        p_from_party_rel_id           NUMBER,
        p_to_party_id                 NUMBER,
        x_org_contact_id         OUT NOCOPY  NUMBER,
        p_from_account_id             NUMBER) RETURN VARCHAR2
IS

    CURSOR dupcheck IS
       SELECT
           MIN(ORG_CONTACT_ID)
       FROM HZ_ORG_CONTACTS org
       WHERE DEPARTMENT_CODE ||
             DEPARTMENT ||
             TITLE ||
             JOB_TITLE ||
             MAIL_STOP ||
             DECISION_MAKER_FLAG ||
             JOB_TITLE_CODE ||
             TO_CHAR(MANAGED_BY) ||
             REFERENCE_USE_FLAG ||
             RANK ||
             STATUS = (
                SELECT DEPARTMENT_CODE ||
                       DEPARTMENT ||
                       TITLE ||
                       JOB_TITLE ||
                       MAIL_STOP ||
                       DECISION_MAKER_FLAG ||
                       JOB_TITLE_CODE ||
                       TO_CHAR(MANAGED_BY) ||
                       REFERENCE_USE_FLAG ||
                       RANK ||
                       STATUS
                FROM HZ_ORG_CONTACTS
                WHERE ORG_CONTACT_ID = p_from_org_contact_id )
       AND EXISTS (
                    SELECT 'same relationships'
                      FROM HZ_RELATIONSHIPS rel
                     WHERE rel.RELATIONSHIP_ID = org.PARTY_RELATIONSHIP_ID
                       AND rel.OBJECT_ID = p_to_party_id
                       AND SUBJECT_TABLE_NAME = 'HZ_PARTIES'
                       AND OBJECT_TABLE_NAME = 'HZ_PARTIES'
                  /*   AND DIRECTIONAL_FLAG = 'F'  */ /* Bug No : 2359461 */
                       AND TO_CHAR(SUBJECT_ID) ||
                                   RELATIONSHIP_CODE = (
                                       SELECT TO_CHAR(SUBJECT_ID) ||
                                                         RELATIONSHIP_CODE
                                         FROM HZ_RELATIONSHIPS,HZ_CUST_ACCOUNTS ACCT
                                        WHERE RELATIONSHIP_ID =
 				                    p_from_party_rel_id
                                          AND OBJECT_ID = ACCT.PARTY_ID
                                          AND ACCT.CUST_ACCOUNT_ID = p_from_account_id
                                          AND SUBJECT_TABLE_NAME = 'HZ_PARTIES'
                                          AND OBJECT_TABLE_NAME = 'HZ_PARTIES'
                                       /* AND DIRECTIONAL_FLAG = 'F' */ /* Bug No : 2359461 */
                                         ) )
       AND ORG_CONTACT_ID <> p_from_org_contact_id;

       l_record_id NUMBER;

BEGIN
    x_org_contact_id := FND_API.G_MISS_NUM;

    OPEN dupcheck;
    FETCH dupcheck INTO l_record_id;
    IF dupcheck%NOTFOUND OR l_record_id IS NULL THEN
       CLOSE dupcheck;
       RETURN FND_API.G_FALSE;
    END IF;

    x_org_contact_id := l_record_id;
    CLOSE dupcheck;
    RETURN FND_API.G_TRUE;

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.check_org_contact_dup' );
      RAISE;

END check_org_contact_dup;

/*===========================================================================+
 | FUNCTION
 |              check_contact_point_dup
 |
 | DESCRIPTION  When migrate contact points, before create a new contact point,
 |              we should check if there is an identical one already exist. If yes,
 |              pick it up.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_from_contact_point_id
 |                    p_to_owner_table_id
 |              OUT:
 |                    x_contact_point_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  17-DEC-00  Created to check if there is a duplicate contact
 |                        point exist in database.
 |
 +===========================================================================*/

FUNCTION check_contact_point_dup (
        p_from_contact_point_id       NUMBER,
        p_to_owner_table_id           NUMBER,
        x_contact_point_id       OUT NOCOPY  NUMBER ) RETURN VARCHAR2
IS

    CURSOR dupcheck IS
       SELECT
          MIN(CONTACT_POINT_ID)
       FROM HZ_CONTACT_POINTS
       WHERE OWNER_TABLE_ID = p_to_owner_table_id
       AND
         OWNER_TABLE_NAME ||
         CONTACT_POINT_TYPE ||
         STATUS ||
         EDI_TRANSACTION_HANDLING ||
         EDI_ID_NUMBER ||
         EDI_PAYMENT_METHOD ||
         EDI_PAYMENT_FORMAT ||
         EDI_REMITTANCE_METHOD ||
         EDI_REMITTANCE_INSTRUCTION ||
         EMAIL_FORMAT ||
         TO_CHAR(BEST_TIME_TO_CONTACT_START, 'DD-MON-YYYY') ||
         TO_CHAR(BEST_TIME_TO_CONTACT_END, 'DD-MON-YYYY') ||
         PHONE_CALLING_CALENDAR ||
         DECLARED_BUSINESS_PHONE_FLAG ||
-- phone_referred_order has been obsoleted.
         -- PHONE_PREFERRED_ORDER ||
         TELEPHONE_TYPE ||
         TIME_ZONE ||
         PHONE_TOUCH_TONE_TYPE_FLAG ||
         PHONE_AREA_CODE ||
         PHONE_COUNTRY_CODE ||
         PHONE_NUMBER ||
         PHONE_EXTENSION ||
         PHONE_LINE_TYPE ||
         TELEX_NUMBER ||
         CONTENT_SOURCE_TYPE ||
         WEB_TYPE
             = (SELECT
                      OWNER_TABLE_NAME ||
                      CONTACT_POINT_TYPE ||
                      STATUS ||
                      EDI_TRANSACTION_HANDLING ||
                      EDI_ID_NUMBER ||
                      EDI_PAYMENT_METHOD ||
                      EDI_PAYMENT_FORMAT ||
                      EDI_REMITTANCE_METHOD ||
                      EDI_REMITTANCE_INSTRUCTION ||
                      EMAIL_FORMAT ||
                      TO_CHAR(BEST_TIME_TO_CONTACT_START, 'DD-MON-YYYY') ||
                      TO_CHAR(BEST_TIME_TO_CONTACT_END, 'DD-MON-YYYY') ||
                      PHONE_CALLING_CALENDAR ||
                      DECLARED_BUSINESS_PHONE_FLAG ||
                      -- PHONE_PREFERRED_ORDER ||
                      TELEPHONE_TYPE ||
                      TIME_ZONE ||
                      PHONE_TOUCH_TONE_TYPE_FLAG ||
                      PHONE_AREA_CODE ||
                      PHONE_COUNTRY_CODE ||
                      PHONE_NUMBER ||
                      PHONE_EXTENSION ||
                      PHONE_LINE_TYPE ||
                      TELEX_NUMBER ||
                      CONTENT_SOURCE_TYPE ||
                      WEB_TYPE
                 FROM HZ_CONTACT_POINTS
                 WHERE CONTACT_POINT_ID = p_from_contact_point_id)
       AND nvl(EMAIL_ADDRESS,'NOEMAIL') = (
               SELECT nvl(EMAIL_ADDRESS,'NOEMAIL')
               FROM HZ_CONTACT_POINTS
               WHERE CONTACT_POINT_ID = p_from_contact_point_id)
       AND nvl(URL, 'NOURL') = (
               SELECT nvl(URL, 'NOURL')
               FROM HZ_CONTACT_POINTS
               WHERE CONTACT_POINT_ID = p_from_contact_point_id)
       AND CONTACT_POINT_ID <> p_from_contact_point_id;

       l_record_id NUMBER;

BEGIN

    x_contact_point_id := FND_API.G_MISS_NUM;

    OPEN dupcheck;
    FETCH dupcheck INTO l_record_id;
    IF dupcheck%NOTFOUND OR l_record_id IS NULL THEN
       CLOSE dupcheck;
       RETURN FND_API.G_FALSE;
    END IF;

    x_contact_point_id := l_record_id;
    CLOSE dupcheck;
    RETURN FND_API.G_TRUE;

EXCEPTION
    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.check_contact_point_dup' );
      RAISE;

END check_contact_point_dup;

/*===========================================================================+
 | PROCEDURE
 |              create_temporary_table
 |
 | DESCRIPTION
 |              create global temporary table.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  20-DEC-00  Created. Bug 1535542: Create global temporary
 |                        table to store the mapping of old org_contact_id and new
 |                        org_contact_id when migrate org contacts.
 |
 +===========================================================================*/

PROCEDURE create_temporary_table
IS

          l_exist                VARCHAR2(1);
          l_sql                  VARCHAR2(1000);

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.create_temporary_table ( ' ||
                           g_table_name || ' )()+' );

    BEGIN

       SELECT 'Y' INTO l_exist
       FROM user_tables
       WHERE table_name = g_table_name
       AND   ROWNUM = 1;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_exist := 'N';
    END;

    --table does not exist
    IF l_exist = 'N' THEN

       --create session-based global temporary table.
       l_sql := 'CREATE GLOBAL TEMPORARY TABLE ' ||
                g_table_name ||
                '(type VARCHAR2(30), ' ||
                'old_id NUMBER, ' ||
                'new_id NUMBER) ' ||
                'ON COMMIT PRESERVE ROWS';
    ELSE

       l_sql := 'DELETE ' || g_table_name;
    END IF;

    EXECUTE IMMEDIATE l_sql;

    arp_message.set_line( 'ARP_CMERGE_ARCUS.create_temporary_table ( ' ||
                           g_table_name || ' )()-' );

EXCEPTION

     WHEN OTHERS THEN
       arp_message.set_error( 'ARP_CMERGE_ARCUS.create_temporary_table ( ' ||
                              g_table_name || ' )' );
       RAISE;

END create_temporary_table;

/*===========================================================================+
 | PROCEDURE
 |              delete_rows
 |
 | DESCRIPTION  physically delete the rows we marked in customer tables after
 |              we merging eact set.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  19-DEC-00  Bug 1535542: physically delete rows in
 |                        customer tables after merging each set.
 |     Jianying Huang  29-DEC-00  Modified 'delete_rows' for performance issue.
 |     Jianying Huang  09-APR-01  Bug 1725662: rewrite sql statement on delete
 |                        ra_cust_receipt_methods to use index.
 |
 +===========================================================================*/

PROCEDURE delete_rows(
          req_id                    NUMBER,
          set_num                   NUMBER
) IS

    CURSOR cust_site_uses IS
       SELECT site_use_id
       FROM HZ_CUST_SITE_USES_ALL su, ra_customer_merges m --SSUptake
       WHERE cust_acct_site_id = m.duplicate_address_id
       AND   m.org_id   = su.org_id --SSUptake
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'Y'
       AND   su.status = 'D'
       FOR UPDATE NOWAIT;

    CURSOR cust_sites IS
       SELECT cust_acct_site_id
       FROM HZ_CUST_ACCT_SITES_ALL addr, ra_customer_merges m --SSUptake
       WHERE cust_acct_site_id = m.duplicate_address_id
       AND   m.org_id = addr.org_id --SSUptake
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'Y'
       AND   addr.status = 'D'
       FOR UPDATE NOWAIT;

    CURSOR cust_accounts IS
       SELECT cust_account_id
       FROM HZ_CUST_ACCOUNTS acct, ra_customer_merges m
       WHERE cust_account_id = m.duplicate_id
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'Y'
       AND   acct.status = 'D'
       FOR UPDATE NOWAIT;

    CURSOR cust_rel1 IS
       SELECT rel.cust_account_id
       FROM HZ_CUST_ACCT_RELATE_ALL rel, ra_customer_merges m --SSUptake
       WHERE cust_account_id = m.duplicate_id
       AND   m.org_id = rel.org_id --SSUptake
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'Y'
       AND   rel.status = 'D'
       FOR UPDATE NOWAIT;

    CURSOR cust_rel2 IS
       SELECT rel.related_cust_account_id
       FROM HZ_CUST_ACCT_RELATE_ALL rel, ra_customer_merges m --SSUptake
       WHERE related_cust_account_id =  m.duplicate_id
       AND   m.org_id  = rel.org_id --SSUptake
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'Y'
       AND   rel.status = 'D'
       FOR UPDATE NOWAIT;

    CURSOR cust_receipt_methods_site IS
       SELECT CUST_RECEIPT_METHOD_ID
       FROM RA_CUST_RECEIPT_METHODS yt, ra_customer_merges m
       WHERE yt.customer_id = m.duplicate_id
       AND   yt.site_use_id = m.duplicate_site_id
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'Y'
      FOR UPDATE NOWAIT;

    CURSOR cust_receipt_methods_acct IS
        SELECT CUST_RECEIPT_METHOD_ID
        FROM RA_CUST_RECEIPT_METHODS yt, ra_customer_merges m
        WHERE yt.customer_id = m.duplicate_id
        AND   m.process_flag = 'N'
        AND   m.request_id = req_id
        AND   m.set_number = set_num
        AND   m.delete_duplicate_flag = 'Y'
        AND   site_use_id IS NULL
        AND NOT EXISTS (
                    SELECT 'accounts exist'
                    FROM   hz_cust_accounts acct
                    WHERE  acct.cust_account_id = yt.customer_id
                    AND    acct.status <> 'D' )
        FOR UPDATE NOWAIT;

    --bug 4307679
    CURSOR cust_usage IS
        SELECT party_usg_assignment_id
        FROM   hz_party_usg_assignments u
        WHERE  party_usage_code = 'CUSTOMER'
        AND    status_flag = 'D'
        AND    party_id in (SELECT DISTINCT c.party_id from hz_cust_accounts c, ra_customer_merges m
                            WHERE c.cust_account_id = m.duplicate_id
                            AND m.process_flag = 'N'
                            AND m.request_id = req_id
                            AND m.set_number = set_num
                            AND m.delete_duplicate_flag = 'Y');

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.delete_rows()+' );

    /*****************************************************/

--4307679
    arp_message.set_name( 'AR', 'AR_DELETING_TABLE' );
    arp_message.set_token( 'TABLE_NAME', 'HZ_PARTY_USG_ASSIGNMENTS', FALSE );

    --lock rows
    OPEN cust_usage;
    CLOSE cust_usage;

    DELETE FROM hz_party_usg_assignments u
    WHERE   party_usage_code = 'CUSTOMER'
    AND    status_flag = 'D'
    AND    party_id in (SELECT DISTINCT c.party_id from hz_cust_accounts c, ra_customer_merges m
                            WHERE c.cust_account_id = m.duplicate_id
                            AND m.process_flag = 'N'
                            AND m.request_id = req_id
                            AND m.set_number = set_num
                            AND m.delete_duplicate_flag = 'Y');

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

--4397679

    arp_message.set_name( 'AR', 'AR_DELETING_TABLE' );
    arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_SITE_USES', FALSE );

    --lock rows
    OPEN cust_site_uses;
    CLOSE cust_site_uses;

    delete from hz_orig_sys_references where
               owner_table_name = 'HZ_CUST_SITE_USES_ALL' and
               owner_table_id in (
                 select site_use_id from hz_cust_site_uses_all su
                 where  status = 'D'
                 and exists ( SELECT 'Y'
                              FROM   ra_customer_merges m
                              WHERE  su.cust_acct_site_id = m.duplicate_address_id
                              AND    su.org_id   = m.org_id
                              AND    m.process_flag = 'N'
                              AND    m.request_id = req_id
                              AND    m.set_number = set_num
                              AND    m.delete_duplicate_flag = 'Y'
                            )
                );

    DELETE FROM HZ_CUST_SITE_USES_ALL su
    WHERE EXISTS  (
                      SELECT 'Y'
                      FROM   ra_customer_merges m
                      WHERE  m.duplicate_address_id = su.cust_acct_site_id
		      AND    m.org_id = su.org_id
		      AND    m.process_flag = 'N'
                      AND    m.request_id = req_id
                      AND    m.set_number = set_num
                      AND    m.delete_duplicate_flag = 'Y' )
    AND status = 'D';


    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    /*****************************************************/

    arp_message.set_name( 'AR', 'AR_DELETING_TABLE' );
    arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_SITES', FALSE );

    --lock rows
    OPEN cust_sites;
    CLOSE cust_sites;

    delete from hz_orig_sys_references where
               owner_table_name = 'HZ_CUST_ACCT_SITES_ALL' and
               owner_table_id in (
               select cust_acct_site_id from hz_cust_acct_sites_all sites --SSuptake
               where  status = 'D'
               and EXISTS
                     ( SELECT 'Y'
                      FROM   ra_customer_merges m
                      WHERE  m.duplicate_address_id = sites.cust_acct_site_id
                      AND    m.org_id = sites.org_id
                      AND    m.process_flag = 'N'
                      AND    m.request_id = req_id
                      AND    m.set_number = set_num
                      AND    m.delete_duplicate_flag = 'Y' ));

    DELETE FROM HZ_CUST_ACCT_SITES_ALL yt --SSUptake
    WHERE EXISTS (
                      SELECT 'Y'
                      FROM   ra_customer_merges m
                      WHERE  m.duplicate_address_id = yt.cust_acct_site_id
		      AND    m.org_id = yt.org_id
		      AND    m.process_flag = 'N'
                      AND    m.request_id = req_id
                      AND    m.set_number = set_num
                      AND    m.delete_duplicate_flag = 'Y' )
    AND status = 'D';

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    /*****************************************************/

    arp_message.set_name( 'AR', 'AR_DELETING_TABLE' );
    arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCOUNTS', FALSE );

    --lock rows
    OPEN cust_accounts;
    CLOSE cust_accounts;

    delete from hz_orig_sys_references where
               owner_table_name = 'HZ_CUST_ACCOUNTS' and
               owner_table_id in (
               select cust_account_id from hz_cust_accounts where
               status = 'D' and cust_account_id in
               ( SELECT m.duplicate_id
                      FROM   ra_customer_merges m
                      WHERE  m.process_flag = 'N'
                      AND    m.request_id = req_id
                      AND    m.set_number = set_num
                      AND    m.delete_duplicate_flag = 'Y' ));

    DELETE FROM HZ_CUST_ACCOUNTS
    WHERE cust_account_id IN (
                 SELECT m.duplicate_id
                 FROM   ra_customer_merges m
                 WHERE  m.process_flag = 'N'
                 AND    m.request_id = req_id
                 AND    m.set_number = set_num
                 AND    m.delete_duplicate_flag = 'Y' )
    AND status = 'D';

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    /*****************************************************/

    arp_message.set_name( 'AR', 'AR_DELETING_TABLE' );
    arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_RELATE', FALSE );

    --lock rows
    OPEN cust_rel1;
    CLOSE cust_rel1;

    DELETE FROM HZ_CUST_ACCT_RELATE_ALL rel --SSUptake
    WHERE  EXISTS (
               SELECT 'Y'
               FROM   ra_customer_merges m
               WHERE  m.duplicate_id = rel.cust_account_id
	       AND    m.org_id  = rel.org_id
	       AND    m.process_flag = 'N'
               AND    m.request_id = req_id
               AND    m.set_number = set_num
               AND    m.delete_duplicate_flag = 'Y'
	       AND    m.org_id  = rel.org_id) --SSUptake
    AND status = 'D';

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_DELETING_TABLE' );
    arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_ACCT_RELATE', FALSE );

    --lock rows
    OPEN cust_rel2;
    CLOSE cust_rel2;

    DELETE FROM HZ_CUST_ACCT_RELATE_ALL rel --SSUptake
    WHERE EXISTS (
               SELECT 'Y'
               FROM   ra_customer_merges m
               WHERE  m.duplicate_id = rel.related_cust_account_id
	       AND    m.org_id = rel.org_id
	       AND    m.process_flag = 'N'
               AND    m.request_id = req_id
               AND    m.set_number = set_num
               AND    m.delete_duplicate_flag = 'Y') --SSUptake
    AND status = 'D';

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    /************** account site level delete ************/

    arp_message.set_name( 'AR', 'AR_DELETING_TABLE' );
    arp_message.set_token( 'TABLE_NAME', 'RA_CUST_RECEIPT_METHODS', FALSE );

    OPEN cust_receipt_methods_site;
    CLOSE cust_receipt_methods_site;

--Bug 1725662: Rewrite the query to use index.

    DELETE FROM RA_CUST_RECEIPT_METHODS yt
    WHERE (customer_id, site_use_id) in (
                SELECT m.duplicate_id, m.duplicate_site_id
                FROM   ra_customer_merges m
                WHERE  m.process_flag = 'N'
                AND    m.request_id = req_id
                AND    m.set_number = set_num
                AND    m.delete_duplicate_flag = 'Y');

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    /************** account level delete ************/

    arp_message.set_name( 'AR', 'AR_DELETING_TABLE' );
    arp_message.set_token( 'TABLE_NAME', 'RA_CUST_RECEIPT_METHODS', FALSE );

    OPEN cust_receipt_methods_acct;
    CLOSE cust_receipt_methods_acct;

    DELETE FROM RA_CUST_RECEIPT_METHODS yt
    WHERE customer_id in (
                SELECT m.duplicate_id
                FROM   ra_customer_merges m
                WHERE  m.process_flag = 'N'
                AND    m.request_id = req_id
                AND    m.set_number = set_num )
    AND site_use_id IS NULL
    AND NOT EXISTS (
                SELECT 'accounts exist'
                FROM   hz_cust_accounts acct
                WHERE  acct.cust_account_id = yt.customer_id
                AND    status <> 'D' );

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_line( 'ARP_CMERGE_ARCUS.delete_rows()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.delete_rows' );
      RAISE;

END delete_rows;

/*===========================================================================+
 | PROCEDURE
 |              create_same_sites
 |
 | DESCRIPTION
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |          Conditions when create new site/site uses.
 |    1. If user tries to create same location
 |       1) if there exsits the same site use, for instance,
 |          in database we have,
 |               merge-from                   merge-to
 |            Address1, Bill-To            Address1, Bill-To
 |          User tries to merge: address1, Bill-To with 'create
 |          same site' checked, In this case, since merge-to
 |          already has account site on address1 and has the
 |          desired business purpose, Bill-To, we should not
 |          create new account site/site use, instead, we need
 |          to merge these two account site use and unset the
 |          value of 'create same site'.
 |       2) if there not exists the same site use, for instance,
 |          in database we have,
 |               merge-from                   merge-to
 |            Address1, Bill-To,           Address1, Ship-To
 |            Address1, Ship-To
 |          User tries to merge: Address1->Address1 with 'create
 |          same site' for Bill-To checked. In this case, since
 |          merge-to already has account site on address1, we should
 |          not create new account site, instead, we need to create
 |          a new account site use, which is for Bill-To purpose.
 |    2. If user tries to create different location, we need to
 |       create (party site)/account site, (party site use)/account site use
 |
 |       The following flow is for merge-to customer. For instance, 'Account
 |       Site not have' means merge-to does not have account site on the
 |       merge-from's location. 'Party Site Use have' means the merge-to party
 |       has a party site use on the merge-from's location with same site use
 |       code. The same meaning is appliable for Party Site etc.
 |
 |                             Account Site
 |                             /          \
 |                  not have  /            \  have
 |                           /              \
 |                     Party Site            Account Site Use
 |                        /   \                      |  \
 |              not have /     \ have       not have |   \ have
 |                      /       \                    |    \
 |         create Party Site   Party Site Use        |   need to do merge
 |               \                  /   \            |
 |                \       not have /     \ have      |
 |                 \              /       \          |
 |               create Party Site Use     \         |
 |                            \            /         |
 |                           create Account Site     |
 |                                    \              /
 |                                 create Account Site Use
 |                                 create Customer Profile
 |                                 create Customer Profile Amount
 |
 |          One of the merge rules is we should not update data in party level.
 |    So we should not update, for example, merge-to's party site with merge-from's
 |    party site if there exists a party site on the location for merge-to's party.
 |
 |          After create account site for merge-to customer,
 |    we need to fill out the columns of ra_customer_merges for later query.
 |         -- customer_address_id    <--  cust_acct_site_id
 |         -- customer_site_id       <--  site_use_id
 |         -- customer_ref           <--  orig_system_reference
 |         -- customer_primary_flag  <--  primary_flag
 |         -- customer_location      <--  location
 |         -- customer_site_code is created by merge form.
 |
 | MODIFICATION HISTORY
 |    Jianying Huang  27-NOV-00  After call create_* API,
 |                       if return_status is not 'success', we need to
 |                       populate an exception.
 |    Jianying Huang  27-NOV-00  Remove 'UPDATE hz_org_contacts ..'
 |                       and 'UPDATE hz_contact_points..' part. We should
 |                       not modify contacts data in party level. Instead,
 |                       we should migrate those data during merge process.
 |    Jianying Huang  27-NOV-00  Added condition that we create profile amts
 |                       if only if there is profile exist for the site use.
 |    Jianying Huang  07-DEC-OO  Bug 1391134: Move the call of createSites
 |                       in set-based merge from merge-form becuase we
 |                       have to commit data for every set.
 |    Jianying Huang  07-DEC-00  Bug 1512300: Modify createSites to copy GL
 |                       accounts.
 |    Jianying Huang  07-DEC-00  Bug 1472578: Modify createSites to
 |                       'create site/site use' in different scenario.
 |    Jianying Huang  07-DEC-00  Bug 1227593: Added column 'ADDRESSEE'
 |                       when we create new party site.
 |    Jianying Huang  07-DEC-OO  Should not copy tp_header_id. It is an unique
 |                       column in hz_cust_acct_sites_all.
 |    Jianying Huang  12-DEC-00  Check 'x_return_status' after call
 |                       'create_cust_prof_amt'
 |    Jianying Huang  20-DEC-00  Bug 1535542: Since we will call customer merge
 |                       before merging prEoducts, we should move 'createSites'
 |                       in arplbmst.sql's merge_customers procedure. However,
 |                       to avoid later calling order change, I rename it to '
 |                       create_same_sites', move it to here(because it is related
 |                       to customer tables), make it public and call it from
 |                       merge report.
 |    Jianying Huang  28-DEC-00  When create new account site use, should not
 |                       copy location. Instead, should enforce the API
 |                       generate location.
 |    Jianying Huang  09-APR-01  When copy site use, should copy 'contact_id'
 |                       because contact_id which references to cust_account_role_id
 |                       will to move to merge-to customer after merge.
 |    Jianying Huang  22-JUL-01  Removed 'FOR UPDATE NOWAIT' for cursor
 |                       'sites_need_to_create'. This is a workaround of
 |                       'fetch out of sequence error' (see bug 1375214)
 |                       on 8.1.6.2 onwards (the fix are done in 8.1.7.2).
 |    Jianying Huang  19-OCT-01  Bug 2062466: Modified procedure 'create_same_sites'
 |                       to reset initial value of local varibles.
 |    Jianying Huang  26-OCT-01  Bug 2077604: Modified procedure 'create_same_sites'
 |                       to add 'cust_account_profile_id = l_cust..' when
 |                       select merge-from site use's profile amounts.
 |    Jyoti Pandey    06-NOV-01 Bug:2098728 Changing all API call outs to call
 |                        Package hz_cust_account_merge_v2pvt
 |    Sisir           13-MAR-02 Bug:2241033;Written code for creating Payment
 |                       Method for Customer Site Use
 |    P.Suresh        05-APR-02 Bug No : 2272750. Populated bill_to_site_use_id.
 |    Rajeshwari P    12-APR-02 Bug 2183072.Handled exception for Select from
 |                              ar_system_parameters.
 |    Jyoti Pandey    20-MAY-02 Bug:2376975 create site use,profiles, amts etc. only
 |                              is dup_site_use_id <> -99 . Form sets to -99 if
 |                              there is no site use for a given site.
 |    P.Suresh        13-JUN-02 Bug No : 2403263. Added contact_id to
 |                              hz_cust_site_uses.
 |    Rajeshwari P    10-OCT-02 Bug No:2529143.Added another parameter 'Credit_classification'
 |                              during creation of Profile for a customer
 |                              in create_same_sites procedure.
 |   Dhaval Mehta     28-JUL-03 Bug 2971149. Added the code back to copy
 |				party_site_uses when the create_same_site
 |				flag is checked. Added a call to
 |				hz_cust_account_merge_v2pvt.create_party_site_use
 |				in procedure create_same_sites.
 |    S.V.Sowjanya    02-DEC-04 Bug No: 3959776. Updated column customer_site_number
 |                                in ra_customer_merges.
 |    S.V.Sowjanya    04-JAN-05 Bug No: 4018346. Assigned null values to l_customer_location,
 |                              l_customer_site_id in the beginning of the loop for
 |				cursor sites_need_to_create and removed nvl condition
 |                              for l_customer_location in the update statement of ra_customer_merges
 |                              at the end  of the loop for cursor sites_need_to_create.
 |   S V Sowjanya     10-AUG-05 Bug No:4492628. Moved code that copies party_site_uses
 |                                to copy party_site_use after the creation of account_site
 |   Kalyana	      12-Oct-07	Bug No: 6469732 Modified the procedure create_same_site so that if already an Active Customer
 |   Chakravarthy		site use of Dunning or Statement exists for TO Party and FROM Party also have an Active use of
 |				Dunning or statement then it create the site use for TO Party in Status Inactive.
 +===========================================================================*/

PROCEDURE create_same_sites(
          req_id                NUMBER,
          set_num               NUMBER,
          status            OUT NOCOPY NUMBER
) IS

    --The rows selected in the cursor are rows we need to create
    --new sites.
    CURSOR sites_need_to_create IS
       SELECT duplicate_id, duplicate_address_id, duplicate_site_id,
              duplicate_site_code, customer_id,org_id --SSUptake
       FROM   ra_customer_merges
       WHERE  duplicate_id <> customer_id
       AND    process_flag = 'N'
       AND    request_id = req_id
       AND    set_number = set_num
       AND    customer_createsame = 'Y'
       ORDER BY duplicate_site_code desc;

    l_duplicate_id                 NUMBER;
    l_duplicate_address_id         NUMBER;
    l_duplicate_site_id            NUMBER;
    l_duplicate_site_code          VARCHAR2(40);
    l_customer_id                  NUMBER;
    m_org_id                       NUMBER(15); --SSUptake

    l_customer_address_id          NUMBER;
    l_customer_site_id             NUMBER;
    l_customer_ref                 VARCHAR2(240);
    l_customer_primary_flag        VARCHAR2(1);
    l_customer_location            VARCHAR2(240);

    party_site_rec         HZ_PARTY_SITE_V2PUB.party_site_rec_type;
    party_site_use_rec     HZ_PARTY_SITE_V2PUB.party_site_use_rec_type;
    cust_site_rec          HZ_CUST_ACCOUNT_SITE_V2PUB.cust_acct_site_rec_type;
    cust_site_use_rec      HZ_CUST_ACCOUNT_SITE_V2PUB.cust_site_use_rec_type;
    cust_prof_rec          HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;
    cust_prof_amt          HZ_CUSTOMER_PROFILE_V2PUB.cust_profile_amt_rec_type;

    l_party_site_id                NUMBER;
    l_party_site_number            VARCHAR2(30);
    l_party_site_use_id            NUMBER;
    l_to_cust_account_profile_id   NUMBER;
    l_cust_acct_profile_amt_id     NUMBER;
    l_cust_account_profile_id      NUMBER;

    CURSOR merge_from_prof_amt IS
       SELECT
          currency_code,
          trx_credit_limit,
          overall_credit_limit,
          min_dunning_amount,
          min_dunning_invoice_amount,
          max_interest_charge,
          min_statement_amount,
          auto_rec_min_receipt_amount,
          interest_rate,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          min_fc_balance_amount,
          min_fc_invoice_amount,
          expiration_date,
           --Bug:2098728 obsoleted wh_update_date,
          jgzz_attribute_category,
          jgzz_attribute1,
          jgzz_attribute2,
          jgzz_attribute3,
          jgzz_attribute4,
          jgzz_attribute5,
          jgzz_attribute6,
          jgzz_attribute7,
          jgzz_attribute8,
          jgzz_attribute9,
          jgzz_attribute10,
          jgzz_attribute11,
          jgzz_attribute12,
          jgzz_attribute13,
          jgzz_attribute14,
          jgzz_attribute15,
          global_attribute1,
          global_attribute2,
          global_attribute3,
          global_attribute4,
          global_attribute5,
          global_attribute6,
          global_attribute7,
          global_attribute8,
          global_attribute9,
          global_attribute10,
          global_attribute11,
          global_attribute12,
          global_attribute13,
          global_attribute14,
          global_attribute15,
          global_attribute16,
          global_attribute17,
          global_attribute18,
          global_attribute19,
          global_attribute20,
          global_attribute_category,
--Bug 5040679 - AR new columns
	exchange_rate_type,
    	min_fc_invoice_overdue_type,
    	min_fc_invoice_percent,
    	min_fc_balance_overdue_type,
    	min_fc_balance_percent,
    	interest_type,
    	interest_fixed_amount,
    	interest_schedule_id,
    	penalty_type,
    	penalty_rate,
    	min_interest_charge,
    	penalty_fixed_amount,
    	penalty_schedule_id

       FROM hz_cust_profile_amts
       WHERE cust_account_id = l_duplicate_id
       AND   site_use_id     = l_duplicate_site_id
       AND   cust_account_profile_id = l_cust_account_profile_id;

 CURSOR merge_from_pay_method IS
	select
	CUST_RECEIPT_METHOD_ID,
	CUSTOMER_ID,
	RECEIPT_METHOD_ID,
	PRIMARY_FLAG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN,
--	REQUEST_ID,
--	PROGRAM_APPLICATION_ID,
--	PROGRAM_ID,
--	PROGRAM_UPDATE_DATE,
	SITE_USE_ID,
	START_DATE,
	END_DATE,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15
 	from 	RA_CUST_RECEIPT_METHODS
	WHERE 	CUSTOMER_ID = l_duplicate_id
	AND   	site_use_id     = l_duplicate_site_id;
	l_row_id 						varchar2(240);
	l_Cust_Receipt_Method_Id 		varchar2(15);
	merge_from_pay_method_row		merge_from_pay_method%rowtype;

    l_profile_option               VARCHAR2(1) := 'Y';
    l_create_profile               VARCHAR2(1) := 'N';
    l_converted_create_profile     VARCHAR2(1);

    l_duplicate_party_site_id      NUMBER;
    l_location_id                  NUMBER;
    l_merge_to_party_id            NUMBER;
    l_create_party_site_use        VARCHAR2(1) := 'N';
    l_create_acct_site_use         VARCHAR2(1) := 'N';
    l_gen_loc                      VARCHAR2(1) := 'Y';

    l_exist                        VARCHAR2(1) := 'N';
    x_return_status                VARCHAR2(20);
    x_msg_data                     VARCHAR2(2000);
    x_msg_count                    NUMBER := 0;
    x_customer_site_id             NUMBER;
    l_count                        NUMBER;
    l_actual_cont_source	   VARCHAR2(30);

    ---to get the value from hz_cust_acct_site and hz_cust_site_uses
    ---create a new one with same org_id

    l_org_id                       NUMBER := NULL ;
    site_use_org_id                NUMBER := NULL;

-- Bug 2971149. Added a local varialbe to store party_site_use_id

    l_duplicate_party_site_use_id  NUMBER := fnd_api.g_miss_num;

    l_dun_exists VARCHAR2(1); --Added for Bug 6469732

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCUS.create_same_sites()+' );

    OPEN sites_need_to_create;
    LOOP
       FETCH sites_need_to_create INTO
         l_duplicate_id, l_duplicate_address_id, l_duplicate_site_id,
         l_duplicate_site_code, l_customer_id,m_org_id;
       EXIT WHEN sites_need_to_create%NOTFOUND;

       --Bug 2062466: Modified procedure 'create_same_sites'
       --             to reset initial value of local varibles.
       l_customer_site_id := null;  -- bug 4018346
       l_customer_location := null;
       l_profile_option := 'Y';
       l_create_profile := 'N';
       l_create_party_site_use := 'N';
       l_create_acct_site_use := 'N';
       l_gen_loc := 'Y';
       l_exist := 'N';
       --Select merge-from's party site id.
       SELECT party_site_id INTO l_duplicate_party_site_id
       FROM hz_cust_acct_sites_all --SSUptake
       WHERE cust_acct_site_id = l_duplicate_address_id
       and   org_id            = m_org_id; --SSUptake

       --Select merge-from's address
       SELECT location_id INTO l_location_id
       FROM hz_party_sites
       WHERE party_site_id = l_duplicate_party_site_id;

       --Select merge-to's party
       SELECT party_id INTO l_merge_to_party_id
       FROM hz_cust_accounts
       WHERE cust_account_id = l_customer_id;

       --Check if user tries to create new address which he/she already has.
       --Since account sites has been stripped by org, we do this check in
       --current org context by using hz_cust_acct_sites
       BEGIN
          --Check if merge-to customer already has the account site
          --on merge-from's address. If yes, do not need to create
          --new party and account site. If not, check if we need to
          --create party site.


          BEGIN

             SELECT 'Y' INTO l_exist
             FROM hz_cust_acct_sites_all --SSUptake
             WHERE cust_account_id = l_customer_id
	     AND   org_id          = m_org_id --SSUptake
             AND party_site_id IN (
                 SELECT party_site_id
                 FROM hz_party_sites
                 WHERE location_id = l_location_id
                 AND party_id = l_merge_to_party_id )
             AND ROWNUM = 1;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                l_exist := 'N';
          END;

          --No account site exsit. Need to check if there exist party site.
          IF l_exist = 'N' THEN

             BEGIN

                SELECT party_site_id INTO l_party_site_id
                FROM hz_party_sites
                WHERE party_id = l_merge_to_party_id
                AND location_id = l_location_id
                AND ROWNUM = 1;

                l_exist := 'Y';

             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_exist := 'N';
             END;

             --Need to create new party site.
             IF l_exist = 'N' THEN

                arp_message.set_line('create_same_sites:create_party_site');

                --Need to create new party site.
                --Build party site records

                --select only ID fields. Will call API: HZ_PARTY_PUB.get_current_*
                --to get the records. This is for the consistence purpose in
                --case of data model changes.
               ---Bug : 2098728 Changing to V2
                hz_cust_account_merge_v2pvt.get_party_site_rec (
                             p_init_msg_list => 'T',
                             p_party_site_id => l_duplicate_party_site_id,
                             x_party_site_rec => party_site_rec,
 			     x_actual_cont_source => l_actual_cont_source,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data );

                IF x_msg_count = 1 THEN
                   x_msg_data := x_msg_data || '**GET_CURRENT_PARTY_SITE**';
                   arp_message.set_line(
                       'do_merge_contacts:get_current_party_site ERROR ' ||
                       x_msg_data );
                ELSIF x_msg_count > 1 THEN

                   FOR x IN 1..x_msg_count LOOP
                    x_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                    x_msg_data := x_msg_data || '**GET_CURRENT_PARTY_SITE**';
                     arp_message.set_line(
                           'do_merge_contacts:get_current_party_site ERROR ' ||
                    x_msg_data );
                   END LOOP;
                END IF;

                /* After call create_org_contact API, if return_status is not
                 'success', we need to populate an exception. */

                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                   RAISE fnd_api.g_exc_error;
                END IF;

                party_site_rec.party_site_id := FND_API.G_MISS_NUM;
                party_site_rec.party_id := l_merge_to_party_id;
                party_site_rec.party_site_number := FND_API.G_MISS_CHAR;

                --We should not set primary flag in customer merge context
                party_site_rec.identifying_address_flag := FND_API.G_MISS_CHAR;

                /* Bug 1365410. Enforce 'create_party_site' API to generate
                   party_site_number even if profile option is 'N'.
                 */

                IF fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER') = 'N' THEN
                   l_profile_option := 'N';
                   fnd_profile.put('HZ_GENERATE_PARTY_SITE_NUMBER', 'Y');
                END IF;

                  ---Bug : 2098728 Changing to V2
                --Create new party site.
                   hz_cust_account_merge_v2pvt.create_party_site(
                             p_init_msg_list => 'T',
                             p_party_site_rec => party_site_rec,
		    	     p_actual_cont_source => l_actual_cont_source,
                             x_party_site_id => l_party_site_id,
                             x_party_site_number => l_party_site_number,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data );

                --Reset profile option
                IF l_profile_option = 'N' THEN
                   fnd_profile.put('HZ_GENERATE_PARTY_SITE_NUMBER', 'N');
                END IF;

                --Handle error message
                IF x_msg_count = 1 THEN
                   x_msg_data := x_msg_data || '**CREATE_PARTY_SITE**';
                   arp_message.set_line(
                       'create_same_sites:create_party_site  ERROR '||
                       x_msg_data);
                ELSIF x_msg_count > 1 THEN

                   FOR x IN 1..x_msg_count LOOP
                       x_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                       x_msg_data := x_msg_data || '**CREATE_PARTY_SITE**';
                       arp_message.set_line(
                           'create_same_sites:create_party_site  ERROR ' ||
                           x_msg_data );
                   END LOOP;
                END IF;

                /** After call create_* API, if return_status is not
                  'success', we need to populate an exception. */
                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                   RAISE fnd_api.g_exc_error;
                END IF;

-- Bug 2971149. Added following code back that was removed due to bug 1722556.

-- START

	     l_create_party_site_use := 'Y';
--Commented out for bug 4492628
/*             ELSE  --Have party site on the location. Do not need to create.

                --Check if there exists party site use with same purpose
                --In case of there exist multiple party site on the address, we
                --pick up the one with mininum id (and same business purpose, if exists)

                SELECT MIN(party_site_id) INTO l_party_site_id
                FROM hz_party_sites ps
                WHERE party_id = l_merge_to_party_id
                AND location_id = l_location_id
                AND EXISTS ( --'same site usage'
                    SELECT party_site_use_id
                    FROM hz_party_site_uses su
                    WHERE su.party_site_id = ps.party_site_id
                    AND site_use_type = l_duplicate_site_code );

                --No corresponding party site use. We need to create a new one.
                IF l_party_site_id IS NULL THEN

                   SELECT MIN(party_site_id) INTO l_party_site_id
                   FROM hz_party_sites
                   WHERE party_id = l_merge_to_party_id
                   AND location_id = l_location_id;

                   l_create_party_site_use := 'Y';

                END IF;
*/
-- END

             END IF;  --l_exist Check party site.


-- Bug 2971149. Added following code back that was removed due to bug 1722556.
-- check for l_create_party_site_use flag and call hz_cust_account_merge_v2pvt.create_party_site_use.

-- START of create_party_site_use
/*--Commented out for bug 4492628
	IF l_create_party_site_use = 'Y' THEN
	   BEGIN

        	arp_message.set_line('create_same_sites:create_party_site_use');

		-- Build party site use record.

		select party_site_use_id into l_duplicate_party_site_use_id
		from hz_party_site_uses
		where site_use_type = l_duplicate_site_code
		and party_site_id = l_duplicate_party_site_id
		and ROWNUM=1;


		 HZ_CUST_ACCOUNT_MERGE_V2PVT.get_party_site_use_rec(
			p_init_msg_list => 'T',
			p_party_site_use_id => l_duplicate_party_site_use_id,
			x_party_site_use_rec => party_site_use_rec,
			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data );

		party_site_use_rec.party_site_id := l_party_site_id;
		party_site_use_rec.primary_per_type := 'N'; --Bug No:3560167

		hz_cust_account_merge_v2pvt.create_party_site_use(
			p_init_msg_list => 'T',
			p_party_site_use_rec => party_site_use_rec,
			x_party_site_use_id => l_party_site_use_id,
			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data );

		--Handle error message.

		IF x_msg_count = 1 THEN
                   x_msg_data := x_msg_data || '**CREATE_PARTY_SITE_USE**';
                   arp_message.set_line( 'create_same_sites:create_party_site_use  ERROR '|| x_msg_data);
                ELSIF x_msg_count > 1 THEN

                   FOR x IN 1..x_msg_count LOOP
                       x_msg_data := FND_MSG_PUB.GET(p_encoded => fnd_api.g_false);
                       x_msg_data := x_msg_data || '**CREATE_PARTY_SITE_USE**';
                       arp_message.set_line( 'create_same_sites:create_party_site_use  ERROR ' || x_msg_data );
                   END LOOP;
                END IF;

                -- After call create_* API, if return_status is not
                -- 'success', we need to populate an exception.
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

             	EXCEPTION

                --The merge-from account site use might not have corresponding
                --party site use.
	                WHEN NO_DATA_FOUND THEN
        	           NULL;

	   END;
        END IF;
-- END of create_party_site_use
*/--Commented out for bug 4492628

             arp_message.set_line('create_same_sites:create_account_site');

             --Create account site.
             --Build account site records
             SELECT  --Bug:2098728 obsoleted wh_update_date,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                global_attribute_category,
                global_attribute1,
                global_attribute2,
                global_attribute3,
                global_attribute4,
                global_attribute5,
                global_attribute6,
                global_attribute7,
                global_attribute8,
                global_attribute9,
                global_attribute10,
                global_attribute11,
                global_attribute12,
                global_attribute13,
                global_attribute14,
                global_attribute15,
                global_attribute16,
                global_attribute17,
                global_attribute18,
                global_attribute19,
                global_attribute20,

--Cannot copy, org_system_reference has unique index.
--If no input, orig_system_reference is defaulted to cust_acct_site_id.
--              orig_system_reference,

                status,
                customer_category_code,
                language,
                key_account_flag,

--Should not copy tp related columns. They are unique columns in hz_cust_acct_sites_all.
--              tp_header_id,
--              ece_tp_location_code,

                 --Bug:2098728 obsoleted service_territory_id,
                primary_specialist_id,
                secondary_specialist_id,
                territory_id,
                territory,
                org_id  ---To pass this org_id to create_cust_acct_site

--Should not copy. The customer name should be merge-to's.
--              translated_customer_name

             INTO
                 --Bug:2098728 obsoleted cust_site_rec.wh_update_date,
                cust_site_rec.attribute_category,
                cust_site_rec.attribute1,
                cust_site_rec.attribute2,
                cust_site_rec.attribute3,
                cust_site_rec.attribute4,
                cust_site_rec.attribute5,
                cust_site_rec.attribute6,
                cust_site_rec.attribute7,
                cust_site_rec.attribute8,
                cust_site_rec.attribute9,
                cust_site_rec.attribute10,
                cust_site_rec.attribute11,
                cust_site_rec.attribute12,
                cust_site_rec.attribute13,
                cust_site_rec.attribute14,
                cust_site_rec.attribute15,
                cust_site_rec.attribute16,
                cust_site_rec.attribute17,
                cust_site_rec.attribute18,
                cust_site_rec.attribute19,
                cust_site_rec.attribute20,
                cust_site_rec.global_attribute_category,
                cust_site_rec.global_attribute1,
                cust_site_rec.global_attribute2,
                cust_site_rec.global_attribute3,
                cust_site_rec.global_attribute4,
                cust_site_rec.global_attribute5,
                cust_site_rec.global_attribute6,
                cust_site_rec.global_attribute7,
                cust_site_rec.global_attribute8,
                cust_site_rec.global_attribute9,
                cust_site_rec.global_attribute10,
                cust_site_rec.global_attribute11,
                cust_site_rec.global_attribute12,
                cust_site_rec.global_attribute13,
                cust_site_rec.global_attribute14,
                cust_site_rec.global_attribute15,
                cust_site_rec.global_attribute16,
                cust_site_rec.global_attribute17,
                cust_site_rec.global_attribute18,
                cust_site_rec.global_attribute19,
                cust_site_rec.global_attribute20,
--              cust_site_rec.orig_system_reference,
                cust_site_rec.status,
                cust_site_rec.customer_category_code,
                cust_site_rec.language,
                cust_site_rec.key_account_flag,
--              cust_site_rec.tp_header_id,
--              cust_site_rec.ece_tp_location_code,
                 --Bug:2098728 obsoleted cust_site_rec.service_territory_id,
                cust_site_rec.primary_specialist_id,
                cust_site_rec.secondary_specialist_id,
                cust_site_rec.territory_id,
                cust_site_rec.territory,
                l_org_id
--              cust_site_rec.translated_customer_name
             FROM hz_cust_acct_sites_all
             WHERE  cust_account_id = l_duplicate_id
             AND    cust_acct_site_id = l_duplicate_address_id;

             cust_site_rec.party_site_id := l_party_site_id;
             cust_site_rec.cust_account_id := l_customer_id;


             --Create account site
             hz_cust_account_merge_v2pvt.create_cust_acct_site(
                                 p_init_msg_list => 'T',
                                 p_cust_acct_site_rec => cust_site_rec,
                                 p_org_id  => l_org_id,
                                 x_cust_acct_site_id  => l_customer_address_id,
                                 x_return_status => x_return_status,
                                 x_msg_count => x_msg_count,
                                 x_msg_data => x_msg_data);

             --Handle error message
             IF x_msg_count = 1 THEN
                x_msg_data := x_msg_data || '**CREATE_ACCOUNT_SITE**';
                arp_message.set_line(
                    'create_same_sites:create_account_site  ERROR '||
                    x_msg_data);
             ELSIF x_msg_count > 1 THEN

                FOR x IN 1..x_msg_count LOOP
                    x_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                    x_msg_data := x_msg_data || '**CREATE_ACCOUNT_SITE**';
                    arp_message.set_line(
                        'create_same_sites:create_account_site  ERROR ' ||
                        x_msg_data );
                END LOOP;
             END IF;

             /** After call create_* API, if return_status is not
               'success', we need to populate an exception. */
             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
             END IF;

             l_create_acct_site_use := 'Y';

          ELSE  --l_exist check for  account site.

          --Check if there exists account site use with same purpose
          --In case of there exist multiple account site on the address, we
          --pick up the one with minum id and same business purpose, if exists


             SELECT MIN(cust_acct_site_id) INTO l_customer_address_id
             FROM hz_cust_acct_sites_all cas --SSUptake
             WHERE cust_account_id = l_customer_id
	     AND   org_id =  m_org_id --SSUptake
             AND party_site_id IN (
                 SELECT party_site_id
                 FROM hz_party_sites
                 WHERE location_id = l_location_id
                 AND party_id = l_merge_to_party_id )
             AND EXISTS ( --'same site usage'
                 SELECT site_use_id
                 FROM HZ_CUST_SITE_USES_ALL csu --SSUptake
                 WHERE cas.cust_acct_site_id = csu.cust_acct_site_id
                 AND   site_use_code = l_duplicate_site_code
		 AND   csu.org_id = cas.org_id ); --SSUptake

             --No corresponding account site use. We need to create a new one.

             IF l_customer_address_id IS NULL THEN

                SELECT MIN(cust_acct_site_id) INTO l_customer_address_id
                FROM hz_cust_acct_sites_all cas --SSUptake
                WHERE cust_account_id = l_customer_id
		and   org_id = m_org_id --SSUptake
                AND party_site_id IN (
                    SELECT party_site_id
                    FROM hz_party_sites
                    WHERE location_id = l_location_id
                    AND party_id = l_merge_to_party_id );

                l_create_acct_site_use := 'Y';

             ELSE --have account site. Do not need to create.

                --In case of multiple usages exist, select the one
                --with mininum id.
                SELECT MIN(site_use_id) INTO l_customer_site_id
                FROM HZ_CUST_SITE_USES_ALL --SSUptake
                WHERE cust_acct_site_id = l_customer_address_id
		AND   org_id  = m_org_id --SSUptake
                AND site_use_code = l_duplicate_site_code;

             END IF;

          END IF; --l_exist Check for account site
--Bug 4492628
--START
          IF l_create_party_site_use = 'N' THEN
		--Check if there exists party site use with same purpose
                --In case of there exist multiple party site on the address, we
                --pick up the one with mininum id (and same business purpose, if exists)

                SELECT MIN(party_site_id) INTO l_party_site_id
                FROM hz_party_sites ps
                WHERE party_id = l_merge_to_party_id
                AND location_id = l_location_id
                AND EXISTS ( --'same site usage'
                    SELECT party_site_use_id
                    FROM hz_party_site_uses su
                    WHERE su.party_site_id = ps.party_site_id
                    AND site_use_type = l_duplicate_site_code );

                --No corresponding party site use. We need to create a new one.
                IF l_party_site_id IS NULL THEN

                   SELECT MIN(party_site_id) INTO l_party_site_id
                   FROM hz_party_sites
                   WHERE party_id = l_merge_to_party_id
                   AND location_id = l_location_id;

                   l_create_party_site_use := 'Y';

                END IF;
           END IF;

              -- check for l_create_party_site_use flag and call hz_cust_account_merge_v2pvt.create_party_site_use.
              -- START of create_party_site_use

	   IF l_create_party_site_use = 'Y' THEN
	   BEGIN

        	arp_message.set_line('create_same_sites:create_party_site_use');

		-- Build party site use record.

		select party_site_use_id into l_duplicate_party_site_use_id
		from hz_party_site_uses
		where site_use_type = l_duplicate_site_code
		and party_site_id = l_duplicate_party_site_id
		and ROWNUM=1;


		 HZ_CUST_ACCOUNT_MERGE_V2PVT.get_party_site_use_rec(
			p_init_msg_list => 'T',
			p_party_site_use_id => l_duplicate_party_site_use_id,
			x_party_site_use_rec => party_site_use_rec,
			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data );

		party_site_use_rec.party_site_id := l_party_site_id;
		party_site_use_rec.primary_per_type := 'N'; --Bug No:3560167

		hz_cust_account_merge_v2pvt.create_party_site_use(
			p_init_msg_list => 'T',
			p_party_site_use_rec => party_site_use_rec,
			x_party_site_use_id => l_party_site_use_id,
			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data );

		--Handle error message.

		IF x_msg_count = 1 THEN
                   x_msg_data := x_msg_data || '**CREATE_PARTY_SITE_USE**';
                   arp_message.set_line( 'create_same_sites:create_party_site_use  ERROR '|| x_msg_data);
                ELSIF x_msg_count > 1 THEN

                   FOR x IN 1..x_msg_count LOOP
                       x_msg_data := FND_MSG_PUB.GET(p_encoded => fnd_api.g_false);
                       x_msg_data := x_msg_data || '**CREATE_PARTY_SITE_USE**';
                       arp_message.set_line( 'create_same_sites:create_party_site_use  ERROR ' || x_msg_data );
                   END LOOP;
                END IF;

                -- After call create_* API, if return_status is not
                -- 'success', we need to populate an exception.
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

             	EXCEPTION

                --The merge-from account site use might not have corresponding
                --party site use.
	                WHEN NO_DATA_FOUND THEN
        	           NULL;

	   END;
        END IF;
	 -- END of create_party_site_use
--END 4492628

          -----Bug:2376975 create only if duplicate_site_id <> -99
          IF l_create_acct_site_use = 'Y' AND l_duplicate_site_id <> -99 THEN
          BEGIN

             arp_message.set_line('create_same_sites:create_account_site_use');


             --Create customer profile and customer profile amts.
             --at site levels. profile is mandatory in account level,
             --and optional in site use level. Every account/account
             --site use can not have more than one profile.

             --Build customer profile.
             SELECT
                cust_account_profile_id,
                status,
                collector_id,
                credit_analyst_id,
                credit_checking,
                next_credit_review_date,
                tolerance,
                discount_terms,
                dunning_letters,
                interest_charges,
                send_statements,
                credit_balance_statements,
                credit_hold,
                profile_class_id,
                credit_rating,
                risk_code,
                standard_terms,
                override_terms,
                dunning_letter_set_id,
                interest_period_days,
                payment_grace_days,
                discount_grace_days,
                statement_cycle_id,
                account_status,
                percent_collectable,
                autocash_hierarchy_id,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                 --Bug:2098728 obsoleted wh_update_date,
                auto_rec_incl_disputed_flag,
                tax_printing_option,
                charge_on_finance_charge_flag,
                grouping_rule_id,
                clearing_days,
                jgzz_attribute_category,
                jgzz_attribute1,
                jgzz_attribute2,
                jgzz_attribute3,
                jgzz_attribute4,
                jgzz_attribute5,
                jgzz_attribute6,
                jgzz_attribute7,
                jgzz_attribute8,
                jgzz_attribute9,
                jgzz_attribute10,
                jgzz_attribute11,
                jgzz_attribute12,
                jgzz_attribute13,
                jgzz_attribute14,
                jgzz_attribute15,
                global_attribute1,
                global_attribute2,
                global_attribute3,
                global_attribute4,
                global_attribute5,
                global_attribute6,
                global_attribute7,
                global_attribute8,
                global_attribute9,
                global_attribute10,
                global_attribute11,
                global_attribute12,
                global_attribute13,
                global_attribute14,
                global_attribute15,
                global_attribute16,
                global_attribute17,
                global_attribute18,
                global_attribute19,
                global_attribute20,
                global_attribute_category,
                cons_inv_flag,
                cons_inv_type,
                autocash_hierarchy_id_for_adr,
                lockbox_matching_option,
                review_cycle,
                last_credit_review_date,
                party_id,
                credit_classification,
	--Bug 5040679 - AR new columns
		cons_bill_level,
    		late_charge_calculation_trx,
    		credit_items_flag,
    		disputed_transactions_flag,
    		late_charge_type,
    		late_charge_term_id,
    		interest_calculation_period,
    		hold_charged_invoices_flag,
    		message_text_id,
    		multiple_interest_rates_flag,
    		charge_begin_date,
		automatch_set_id       --bug 8477178 . AR new column
             INTO
                l_cust_account_profile_id,
                cust_prof_rec.status,
                cust_prof_rec.collector_id,
                cust_prof_rec.credit_analyst_id,
                cust_prof_rec.credit_checking,
                cust_prof_rec.next_credit_review_date,
                cust_prof_rec.tolerance,
                cust_prof_rec.discount_terms,
                cust_prof_rec.dunning_letters,
                cust_prof_rec.interest_charges,
                cust_prof_rec.send_statements,
                cust_prof_rec.credit_balance_statements,
                cust_prof_rec.credit_hold,
                cust_prof_rec.profile_class_id,
                cust_prof_rec.credit_rating,
                cust_prof_rec.risk_code,
                cust_prof_rec.standard_terms,
                cust_prof_rec.override_terms,
                cust_prof_rec.dunning_letter_set_id,
                cust_prof_rec.interest_period_days,
                cust_prof_rec.payment_grace_days,
                cust_prof_rec.discount_grace_days,
                cust_prof_rec.statement_cycle_id,
                cust_prof_rec.account_status,
                cust_prof_rec.percent_collectable,
                cust_prof_rec.autocash_hierarchy_id,
                cust_prof_rec.attribute_category,
                cust_prof_rec.attribute1,
                cust_prof_rec.attribute2,
                cust_prof_rec.attribute3,
                cust_prof_rec.attribute4,
                cust_prof_rec.attribute5,
                cust_prof_rec.attribute6,
                cust_prof_rec.attribute7,
                cust_prof_rec.attribute8,
                cust_prof_rec.attribute9,
                cust_prof_rec.attribute10,
                cust_prof_rec.attribute11,
                cust_prof_rec.attribute12,
                cust_prof_rec.attribute13,
                cust_prof_rec.attribute14,
                cust_prof_rec.attribute15,
                 --Bug:2098728 obsoleted cust_prof_rec.wh_update_date,
                cust_prof_rec.auto_rec_incl_disputed_flag,
                cust_prof_rec.tax_printing_option,
                cust_prof_rec.charge_on_finance_charge_flag,
                cust_prof_rec.grouping_rule_id,
                cust_prof_rec.clearing_days,
                cust_prof_rec.jgzz_attribute_category,
                cust_prof_rec.jgzz_attribute1,
                cust_prof_rec.jgzz_attribute2,
                cust_prof_rec.jgzz_attribute3,
                cust_prof_rec.jgzz_attribute4,
                cust_prof_rec.jgzz_attribute5,
                cust_prof_rec.jgzz_attribute6,
                cust_prof_rec.jgzz_attribute7,
                cust_prof_rec.jgzz_attribute8,
                cust_prof_rec.jgzz_attribute9,
                cust_prof_rec.jgzz_attribute10,
                cust_prof_rec.jgzz_attribute11,
                cust_prof_rec.jgzz_attribute12,
                cust_prof_rec.jgzz_attribute13,
                cust_prof_rec.jgzz_attribute14,
                cust_prof_rec.jgzz_attribute15,
                cust_prof_rec.global_attribute1,
                cust_prof_rec.global_attribute2,
                cust_prof_rec.global_attribute3,
                cust_prof_rec.global_attribute4,
                cust_prof_rec.global_attribute5,
                cust_prof_rec.global_attribute6,
                cust_prof_rec.global_attribute7,
                cust_prof_rec.global_attribute8,
                cust_prof_rec.global_attribute9,
                cust_prof_rec.global_attribute10,
                cust_prof_rec.global_attribute11,
                cust_prof_rec.global_attribute12,
                cust_prof_rec.global_attribute13,
                cust_prof_rec.global_attribute14,
                cust_prof_rec.global_attribute15,
                cust_prof_rec.global_attribute16,
                cust_prof_rec.global_attribute17,
                cust_prof_rec.global_attribute18,
                cust_prof_rec.global_attribute19,
                cust_prof_rec.global_attribute20,
                cust_prof_rec.global_attribute_category,
                cust_prof_rec.cons_inv_flag,
                cust_prof_rec.cons_inv_type,
                cust_prof_rec.autocash_hierarchy_id_for_adr,
                cust_prof_rec.lockbox_matching_option,
                cust_prof_rec.review_cycle,
                cust_prof_rec.last_credit_review_date,
                cust_prof_rec.party_id,
                cust_prof_rec.credit_classification,
--Bug 5040679 - AR new columns
		cust_prof_rec.cons_bill_level,
    		cust_prof_rec.late_charge_calculation_trx,
    		cust_prof_rec.credit_items_flag,
    		cust_prof_rec.disputed_transactions_flag,
    		cust_prof_rec.late_charge_type,
    		cust_prof_rec.late_charge_term_id,
    		cust_prof_rec.interest_calculation_period,
    		cust_prof_rec.hold_charged_invoices_flag,
    		cust_prof_rec.message_text_id,
    		cust_prof_rec.multiple_interest_rates_flag,
    		cust_prof_rec.charge_begin_date,
	        cust_prof_rec.automatch_set_id      --8477178

             FROM hz_customer_profiles
             WHERE cust_account_id = l_duplicate_id
             AND   site_use_id     = l_duplicate_site_id
             AND   ROWNUM = 1; -- in case of data problem: one site use has 2 profiles.

             -- The API will fill in the site_use_id.
             cust_prof_rec.cust_account_id := l_customer_id;

             l_create_profile := 'Y';

          EXCEPTION
             --The merge-from account site might not have profile.
             WHEN NO_DATA_FOUND THEN
                l_cust_account_profile_id := null;
                l_create_profile := 'N';

          END;

             --Build account site use records.
             SELECT site_use_code,

--We should set primary in customer merge context if the two customer doesnt have a same primary site usage in that org_id
              primary_flag,--Bug No.5211233

--Set the merge-to site uses status to 'Active'
--
--Bug 2071810: keep the old status
                status,

--Bug fix 2588321 Changed the logic for copying value into location field
--depending upon certain conditions.
--location is unique per customer+business purpose combination. We should
--not copy it in customer merge context
--              location,

                 contact_id,

--We should not set bill_to_site_use_id in customer merge context
                bill_to_site_use_id,
                orig_system_reference,
                sic_code,
                payment_term_id,
                gsa_indicator,
                ship_partial,
                ship_via,
                fob_point,
                order_type_id,
                price_list_id,
                freight_term,
                warehouse_id,
                territory_id,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                global_attribute_category,
                global_attribute1,
                global_attribute2,
                global_attribute3,
                global_attribute4,
                global_attribute5,
                global_attribute6,
                global_attribute7,
                global_attribute8,
                global_attribute9,
                global_attribute10,
                global_attribute11,
                global_attribute12,
                global_attribute13,
                global_attribute14,
                global_attribute15,
                global_attribute16,
                global_attribute17,
                global_attribute18,
                global_attribute19,
                global_attribute20,
                tax_reference,
                sort_priority,
                tax_code,
                --Bug:2098728 obsoleted last_accrue_charge_date,
                --Bug:2098728 obsoleted second_last_accrue_charge_date,
                --Bug:2098728 obsoleted last_unaccrue_charge_date,
                --Bug:2098728 obsoleted second_last_unaccrue_chrg_date,
                demand_class_code,
                tax_header_level_flag,
                tax_rounding_rule,
                 --Bug:2098728 obsoleted wh_update_date,
                primary_salesrep_id,
                finchrg_receivables_trx_id,
                dates_negative_tolerance,
                dates_positive_tolerance,
                date_type_preference,
                over_shipment_tolerance,
                under_shipment_tolerance,
                item_cross_ref_pref,
                ship_sets_include_lines_flag,
                arrivalsets_include_lines_flag,
                sched_date_push_flag,
                invoice_quantity_rule,
                over_return_tolerance,
                under_return_tolerance,
                pricing_event,

--Bug 1512300: Modify create_same_sites to copy GL accounts.

                gl_id_rec,
                gl_id_rev,
                gl_id_tax,
                gl_id_freight,
                gl_id_clearing,
                gl_id_unbilled,
                gl_id_unearned,
                gl_id_unpaid_rec,
                gl_id_remittance,
                gl_id_factor,
                tax_classification,
                org_id     --To pass org_id while creating cust_site_use
             INTO
                cust_site_use_rec.site_use_code,
                cust_site_use_rec.primary_flag,--Bug No. 5211233
                cust_site_use_rec.status,
--              cust_site_use_rec.location,
                 --Bug:2098728 obsoleted cust_site_use_rec.contact_id,
                 --Bug:2403263 Added cust_site_use_rec.contact_id.
                cust_site_use_rec.contact_id,
--              cust_site_use_rec.bill_to_site_use_id,
                cust_site_use_rec.bill_to_site_use_id,
                cust_site_use_rec.orig_system_reference,
                cust_site_use_rec.sic_code,
                cust_site_use_rec.payment_term_id,
                cust_site_use_rec.gsa_indicator,
                cust_site_use_rec.ship_partial,
                cust_site_use_rec.ship_via,
                cust_site_use_rec.fob_point,
                cust_site_use_rec.order_type_id,
                cust_site_use_rec.price_list_id,
                cust_site_use_rec.freight_term,
                cust_site_use_rec.warehouse_id,
                cust_site_use_rec.territory_id,
                cust_site_use_rec.attribute_category,
                cust_site_use_rec.attribute1,
                cust_site_use_rec.attribute2,
                cust_site_use_rec.attribute3,
                cust_site_use_rec.attribute4,
                cust_site_use_rec.attribute5,
                cust_site_use_rec.attribute6,
                cust_site_use_rec.attribute7,
                cust_site_use_rec.attribute8,
                cust_site_use_rec.attribute9,
                cust_site_use_rec.attribute10,
                cust_site_use_rec.attribute11,
                cust_site_use_rec.attribute12,
                cust_site_use_rec.attribute13,
                cust_site_use_rec.attribute14,
                cust_site_use_rec.attribute15,
                cust_site_use_rec.attribute16,
                cust_site_use_rec.attribute17,
                cust_site_use_rec.attribute18,
                cust_site_use_rec.attribute19,
                cust_site_use_rec.attribute20,
                cust_site_use_rec.attribute21,
                cust_site_use_rec.attribute22,
                cust_site_use_rec.attribute23,
                cust_site_use_rec.attribute24,
                cust_site_use_rec.attribute25,
                cust_site_use_rec.global_attribute_category,
                cust_site_use_rec.global_attribute1,
                cust_site_use_rec.global_attribute2,
                cust_site_use_rec.global_attribute3,
                cust_site_use_rec.global_attribute4,
                cust_site_use_rec.global_attribute5,
                cust_site_use_rec.global_attribute6,
                cust_site_use_rec.global_attribute7,
                cust_site_use_rec.global_attribute8,
                cust_site_use_rec.global_attribute9,
                cust_site_use_rec.global_attribute10,
                cust_site_use_rec.global_attribute11,
                cust_site_use_rec.global_attribute12,
                cust_site_use_rec.global_attribute13,
                cust_site_use_rec.global_attribute14,
                cust_site_use_rec.global_attribute15,
                cust_site_use_rec.global_attribute16,
                cust_site_use_rec.global_attribute17,
                cust_site_use_rec.global_attribute18,
                cust_site_use_rec.global_attribute19,
                cust_site_use_rec.global_attribute20,
                cust_site_use_rec.tax_reference,
                cust_site_use_rec.sort_priority,
                cust_site_use_rec.tax_code,
              --Bug:2098728 obsoleted cust_site_use_rec.last_accrue_charge_date,
              --Bug:2098728 obsoleted cust_site_use_rec.second_last_accrue_charge_date,
              --Bug:2098728 obsoleted cust_site_use_rec.last_unaccrue_charge_date,
              --Bug:2098728 obsoleted cust_site_use_rec.second_last_unaccrue_chrg_date,
                cust_site_use_rec.demand_class_code,
                cust_site_use_rec.tax_header_level_flag,
                cust_site_use_rec.tax_rounding_rule,
                 --Bug:2098728 obsoleted cust_site_use_rec.wh_update_date,
                cust_site_use_rec.primary_salesrep_id,
                cust_site_use_rec.finchrg_receivables_trx_id,
                cust_site_use_rec.dates_negative_tolerance,
                cust_site_use_rec.dates_positive_tolerance,
                cust_site_use_rec.date_type_preference,
                cust_site_use_rec.over_shipment_tolerance,
                cust_site_use_rec.under_shipment_tolerance,
                cust_site_use_rec.item_cross_ref_pref,
                cust_site_use_rec.ship_sets_include_lines_flag,
                cust_site_use_rec.arrivalsets_include_lines_flag,
                cust_site_use_rec.sched_date_push_flag,
                cust_site_use_rec.invoice_quantity_rule,
                cust_site_use_rec.over_return_tolerance,
                cust_site_use_rec.under_return_tolerance,
                cust_site_use_rec.pricing_event,

--Bug 1512300: Modify create_same_sites to copy GL accounts.

                cust_site_use_rec.gl_id_rec,
                cust_site_use_rec.gl_id_rev,
                cust_site_use_rec.gl_id_tax,
                cust_site_use_rec.gl_id_freight,
                cust_site_use_rec.gl_id_clearing,
                cust_site_use_rec.gl_id_unbilled,
                cust_site_use_rec.gl_id_unearned,
                cust_site_use_rec.gl_id_unpaid_rec,
                cust_site_use_rec.gl_id_remittance,
                cust_site_use_rec.gl_id_factor,
                cust_site_use_rec.tax_classification,
                site_use_org_id
             FROM  HZ_CUST_SITE_USES_ALL --SSUptake
             WHERE site_use_id = l_duplicate_site_id
	     AND   org_id = m_org_id; --SSUptake

	   ----Bug 5211233
	   IF cust_site_use_rec.primary_flag = 'Y' THEN
	   BEGIN
	                Select NULL INTO cust_site_use_rec.primary_flag
	                from hz_cust_site_uses_all
	                where CUST_ACCT_SITE_ID in (select CUST_ACCT_SITE_ID from hz_cust_acct_sites_all
	                                             Where cust_account_id = l_customer_id
	                                             AND org_id =  site_use_org_id)
	                AND SITE_USE_CODE = cust_site_use_rec.site_use_code
	                AND PRIMARY_FLAG = 'Y'
	                AND nvl(status,'A') = 'A'
	                AND org_id = site_use_org_id;
	                EXCEPTION

	                WHEN NO_DATA_FOUND THEN
	   	                         cust_site_use_rec.primary_flag := 'Y';
             END;
             END IF;
             ---------Bug 5211233

            -- Bug Fix : 2272750
            if cust_site_use_rec.bill_to_site_use_id is not null then
               -- Check whether the bill_to_site_use_id is valid.
               BEGIN
                  select 1
                  into   l_count
                  from   HZ_CUST_SITE_USES_ALL
                  where  site_use_id   = cust_site_use_rec.bill_to_site_use_id
                  and    site_use_code = 'BILL_TO';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    cust_site_use_rec.bill_to_site_use_id := NULL;
               END;
           end if;

--Bug Fix 2588321
             --since location is madatory. We have to enforce system generate.
             --Only if the customer_location value is NULL.

             SELECT customer_location into l_customer_location
             FROM ra_customer_merges
             WHERE customer_id = l_customer_id
             AND duplicate_site_id = l_duplicate_site_id
--Bug Fix 2929527
             AND ROWNUM=1;

       IF l_customer_location = NULL THEN
           null;
           /* --SSUptake

            BEGIN
               SELECT auto_site_numbering INTO l_gen_loc
               FROM ar_system_parameters;
               l_gen_loc := hz_mo_global_cache.get_auto_site_numbering(cust_site_use_rec.org_id);
--Bug Fix 2183072
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     --arp_message.set_name( 'AR','AR_NO_ROW_IN_SYSTEM_PARAMETERS');
                     RAISE fnd_api.g_exc_error;
            END ;

            IF l_gen_loc = 'N' THEN
                UPDATE ar_system_parameters
                SET auto_site_numbering = 'Y';
            END IF;
         */

--Bug Fix 2588321
      ELSE
              cust_site_use_rec.location := l_customer_location;
      END IF;

             cust_site_use_rec.cust_acct_site_id := l_customer_address_id;

             IF l_create_profile = 'Y' THEN
                l_converted_create_profile := FND_API.G_TRUE;
             ELSE
                l_converted_create_profile := FND_API.G_FALSE;
             END IF;

             cust_prof_rec.party_id := l_merge_to_party_id;
-- bug 6469732 Start
l_dun_exists:='N';
IF (l_duplicate_site_code = 'DUN' or l_duplicate_site_code = 'STMTS') and cust_site_use_rec.status = 'A' THEN
  BEGIN
	SELECT 'Y' INTO l_dun_exists
	FROM hz_cust_acct_sites_all as1, hz_cust_site_uses_all asu
	WHERE as1.cust_account_id = l_customer_id
	AND   asu.cust_acct_site_id = as1.cust_acct_site_id
        AND   as1.org_id = m_org_id
	AND   asu.site_use_code = l_duplicate_site_code
        AND   asu.org_id = m_org_id
	AND   asu.status = 'A'
        AND ROWNUM = 1 ;
  EXCEPTION
  	WHEN NO_DATA_FOUND THEN
     	l_dun_exists := 'N';
  END;
END IF;


    IF l_dun_exists = 'Y' THEN

        cust_site_use_rec.status := 'I';

    END IF;
--bug 6469732 end

             --Create account site use.
             --Create account site use.
             hz_cust_account_merge_v2pvt.create_cust_site_use(
                              p_init_msg_list => 'T',
                              p_cust_site_use_rec => cust_site_use_rec,
                              p_customer_profile_rec => cust_prof_rec,
                              p_create_profile => l_converted_create_profile,
                              p_create_profile_amt => 'F', ----no profile amt
                              p_org_id => site_use_org_id,
                              x_site_use_id => l_customer_site_id ,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data);

             --reset system parameter
	     --SSUptake
             /*IF l_gen_loc = 'N' THEN
                UPDATE ar_system_parameters
                SET auto_site_numbering = 'N';
             END IF;*/

             --Handle error message.
             IF x_msg_count = 1 THEN
                x_msg_data := x_msg_data || '**CREATE_ACCOUNT_SITE_USE**';
                arp_message.set_line(
                    'create_same_sites:create_acct_site_uses  ERROR '||
                    x_msg_data);
             ELSIF x_msg_count > 1 THEN

                FOR x IN 1..x_msg_count LOOP
                    x_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                    x_msg_data := x_msg_data || '**CREATE_ACCOUNT_SITE_USE**';
                    arp_message.set_line(
                        'create_same_sites:create_acct_site_uses  ERROR ' ||
                        x_msg_data );
                END LOOP;
             END IF;

             /** After call create_* API, if return_status is not
               'success', we need to populate an exception. */
             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
             END IF;

             -- Find out the customer profile id.
             IF l_create_profile = 'Y' THEN

                arp_message.set_line('create_same_sites:create_profile_amount');

                SELECT cust_account_profile_id INTO l_to_cust_account_profile_id
                FROM   hz_customer_profiles
                WHERE  cust_account_id = l_customer_id
                AND    site_use_id     = l_customer_site_id;

                -- Create Customer Profile Amts for customer id
                OPEN merge_from_prof_amt;
                LOOP
                  FETCH merge_from_prof_amt INTO
                     cust_prof_amt.currency_code,
                     cust_prof_amt.trx_credit_limit,
                     cust_prof_amt.overall_credit_limit,
                     cust_prof_amt.min_dunning_amount,
                     cust_prof_amt.min_dunning_invoice_amount,
                     cust_prof_amt.max_interest_charge,
                     cust_prof_amt.min_statement_amount,
                     cust_prof_amt.auto_rec_min_receipt_amount,
                     cust_prof_amt.interest_rate,
                     cust_prof_amt.attribute_category,
                     cust_prof_amt.attribute1,
                     cust_prof_amt.attribute2,
                     cust_prof_amt.attribute3,
                     cust_prof_amt.attribute4,
                     cust_prof_amt.attribute5,
                     cust_prof_amt.attribute6,
                     cust_prof_amt.attribute7,
                     cust_prof_amt.attribute8,
                     cust_prof_amt.attribute9,
                     cust_prof_amt.attribute10,
                     cust_prof_amt.attribute11,
                     cust_prof_amt.attribute12,
                     cust_prof_amt.attribute13,
                     cust_prof_amt.attribute14,
                     cust_prof_amt.attribute15,
                     cust_prof_amt.min_fc_balance_amount,
                     cust_prof_amt.min_fc_invoice_amount,
                     cust_prof_amt.expiration_date,
                      --Bug:2098728 obsoleted cust_prof_amt.wh_update_date,
                     cust_prof_amt.jgzz_attribute_category,
                     cust_prof_amt.jgzz_attribute1,
                     cust_prof_amt.jgzz_attribute2,
                     cust_prof_amt.jgzz_attribute3,
                     cust_prof_amt.jgzz_attribute4,
                     cust_prof_amt.jgzz_attribute5,
                     cust_prof_amt.jgzz_attribute6,
                     cust_prof_amt.jgzz_attribute7,
                     cust_prof_amt.jgzz_attribute8,
                     cust_prof_amt.jgzz_attribute9,
                     cust_prof_amt.jgzz_attribute10,
                     cust_prof_amt.jgzz_attribute11,
                     cust_prof_amt.jgzz_attribute12,
                     cust_prof_amt.jgzz_attribute13,
                     cust_prof_amt.jgzz_attribute14,
                     cust_prof_amt.jgzz_attribute15,
                     cust_prof_amt.global_attribute1,
                     cust_prof_amt.global_attribute2,
                     cust_prof_amt.global_attribute3,
                     cust_prof_amt.global_attribute4,
                     cust_prof_amt.global_attribute5,
                     cust_prof_amt.global_attribute6,
                     cust_prof_amt.global_attribute7,
                     cust_prof_amt.global_attribute8,
                     cust_prof_amt.global_attribute9,
                     cust_prof_amt.global_attribute10,
                     cust_prof_amt.global_attribute11,
                     cust_prof_amt.global_attribute12,
                     cust_prof_amt.global_attribute13,
                     cust_prof_amt.global_attribute14,
                     cust_prof_amt.global_attribute15,
                     cust_prof_amt.global_attribute16,
                     cust_prof_amt.global_attribute17,
                     cust_prof_amt.global_attribute18,
                     cust_prof_amt.global_attribute19,
                     cust_prof_amt.global_attribute20,
                     cust_prof_amt.global_attribute_category,
	--Bug 5040679 - AR new columns
		cust_prof_amt.exchange_rate_type,
    		cust_prof_amt.min_fc_invoice_overdue_type,
    		cust_prof_amt.min_fc_invoice_percent,
    		cust_prof_amt.min_fc_balance_overdue_type,
    		cust_prof_amt.min_fc_balance_percent,
    		cust_prof_amt.interest_type,
    		cust_prof_amt.interest_fixed_amount,
    		cust_prof_amt.interest_schedule_id,
    		cust_prof_amt.penalty_type,
    		cust_prof_amt.penalty_rate,
    		cust_prof_amt.min_interest_charge,
    		cust_prof_amt.penalty_fixed_amount,
    		cust_prof_amt.penalty_schedule_id;
                   EXIT WHEN merge_from_prof_amt%NOTFOUND;

                   cust_prof_amt.cust_account_profile_id  := l_to_cust_account_profile_id;
                   cust_prof_amt.cust_account_id          := l_customer_id;
                   cust_prof_amt.site_use_id              := l_customer_site_id;

                   --create custom profile amounts
                   ---Bug:2098728 Calling V2

                      hz_cust_account_merge_v2pvt.create_cust_profile_amt(
                             p_init_msg_list => 'T',
                             p_check_foreign_key =>'T',
                             p_cust_profile_amt_rec => cust_prof_amt,
                             x_cust_acct_profile_amt_id => l_cust_acct_profile_amt_id,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

                   IF x_msg_count = 1 THEN
                      x_msg_data := x_msg_data || '**CREATE_CUST_PROF_AMT**';
                      arp_message.set_line(
                          'create_same_sites:create_cust_prof_amt  ERROR '||
                          x_msg_data);
                   ELSIF x_msg_count > 1 THEN

                      FOR x IN 1..x_msg_count LOOP
                          x_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                          x_msg_data := x_msg_data || '**CREATE_CUST_PROF_AMT**';
                          arp_message.set_line(
                              'create_same_sites:create_cust_prof_amt  ERROR ' ||
                              x_msg_data );
                      END LOOP;
                   END IF;

                  /** After call create_* API, if return_status is not
                   'success', we need to populate an exception. */
                  IF x_return_status <> fnd_api.g_ret_sts_success THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;

                END LOOP;
                CLOSE merge_from_prof_amt;

             END IF;   --there is profile exist for this site use.

/* Bug:2241033; Creating Payment Method for customer site use   */
      begin
    	arp_message.set_line('create_same_sites:create_cust_site_payment_method');
    	savepoint merge_from_pay_method_point;

    	open merge_from_pay_method;
    	loop
      	fetch merge_from_pay_method into merge_from_pay_method_row;
	   EXIT WHEN merge_from_pay_method%NOTFOUND;
	   l_row_id := null;
	   l_Cust_Receipt_Method_Id := null;

       	   arp_CRM_PKG.Insert_Row(X_Rowid        => l_row_id ,
              X_Cust_Receipt_Method_Id  => l_Cust_Receipt_Method_Id,
               X_Created_By         => hz_utility_v2pub.user_id,--arp_standard.profile.user_id ,
               X_Creation_Date      => sysdate,
               X_Customer_Id        => l_customer_id,
               X_Last_Updated_By    =>hz_utility_v2pub.user_id,-- arp_standard.profile.user_id,
               X_Last_Update_Date   => sysdate,
               X_Primary_Flag       => merge_from_pay_method_row.Primary_Flag,
               X_Receipt_Method_Id  => merge_from_pay_method_row.Receipt_Method_Id,
               X_Start_Date         => merge_from_pay_method_row.Start_Date,
               X_End_Date           => merge_from_pay_method_row.End_Date,
               X_Last_Update_Login  =>hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
               X_Site_Use_Id        => l_customer_site_id,
               X_Attribute_Category => merge_from_pay_method_row.Attribute_Category,
               X_Attribute1         => merge_from_pay_method_row.Attribute1,
               X_Attribute2         => merge_from_pay_method_row.Attribute2,
               X_Attribute3         => merge_from_pay_method_row.Attribute3,
               X_Attribute4         => merge_from_pay_method_row.Attribute4,
               X_Attribute5         => merge_from_pay_method_row.Attribute5,
               X_Attribute6         => merge_from_pay_method_row.Attribute6,
               X_Attribute7         => merge_from_pay_method_row.Attribute7,
               X_Attribute8         => merge_from_pay_method_row.Attribute8,
               X_Attribute9         => merge_from_pay_method_row.Attribute9,
               X_Attribute10        => merge_from_pay_method_row.Attribute10,
               X_Attribute11        => merge_from_pay_method_row.Attribute11,
               X_Attribute12        => merge_from_pay_method_row.Attribute12,
               X_Attribute13        => merge_from_pay_method_row.Attribute13,
               X_Attribute14        => merge_from_pay_method_row.Attribute14,
               X_Attribute15        => merge_from_pay_method_row.Attribute15
                       );
		--The above table handler does not insert all the columns of
                --the table.So the following update statement is created to
                --update rest of the fields.

	      if l_row_id is not null then
               	update 	RA_CUST_RECEIPT_METHODS
	       	set
                last_update_date = sysdate,
    	        last_updated_by =hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
                last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
	        request_id = req_id,
                program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
	       	program_id =hz_utility_v2pub.program_id,-- arp_standard.profile.program_id,
	   	program_update_date = sysdate
	        where   rowid = l_row_id;
              end if;

	 end loop;
	 CLOSE merge_from_pay_method;
   exception
     when others then
	rollback to  merge_from_pay_method_point;

        arp_message.set_line('create_same_sites:create_cust_site_payment_method error');
        status := -1;
        RAISE fnd_api.g_exc_error;
    end;
/* --end of creating payment method for customer site use */

          END IF; --end of create account site

       END; --end of creating

       --Will migrate the contacts (phones and emails) during merge process

       --Update ra_customer_merges table with the new info. we created.
       --Select customer orig system reference.
       SELECT orig_system_reference
       INTO l_customer_ref
       FROM hz_cust_acct_sites_all
       WHERE cust_acct_site_id = l_customer_address_id;

      ---Bug: 2376975 Acct merge should happen even if there is no site use
      ---l_customer_site_id is null when site_use is not created
      ---and that happens when duplicate_site_code is null/NONE

      if l_customer_site_id is not null then
       --Select primary flag and location
       SELECT primary_flag, location
       INTO l_customer_primary_flag, l_customer_location
       FROM HZ_CUST_SITE_USES_ALL
       WHERE site_use_id = l_customer_site_id;
      end if;
--bug 3959776
       SELECT party_site_number INTO l_party_site_number
              FROM hz_party_sites
              WHERE party_site_id = ( SELECT party_site_id
                                      FROM hz_cust_acct_sites_all
                                      WHERE cust_acct_site_id = l_customer_address_id);
       UPDATE ra_customer_merges
       SET customer_address_id = l_customer_address_id,
           customer_ref = l_customer_ref,
           customer_primary_flag = nvl(l_customer_primary_flag,'N'),
           customer_site_id = nvl(l_customer_site_id,-99),
           customer_location = l_customer_location,    --bug 4018346 removed nvl condition
	   customer_site_number = nvl(l_party_site_number,-99),              ---bug 3959776 updated customer_site_number
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,--arp_standard.profile.user_id,
           last_update_login =hz_utility_v2pub.last_update_login,-- arp_standard.profile.last_update_login,
           program_application_id =hz_utility_v2pub.program_application_id,-- arp_standard.profile.program_application_id,
           program_id =hz_utility_v2pub.program_id,-- arp_standard.profile.program_id,
           program_update_date = sysdate
       WHERE duplicate_id = l_duplicate_id
       AND duplicate_site_id = l_duplicate_site_id
       AND duplicate_address_id = l_duplicate_address_id -- bug 7851438
       AND customer_id = l_customer_id
       AND process_flag = 'N'
       AND request_id = req_id
       AND set_number = set_num
       AND customer_createsame = 'Y';

    END LOOP;
    CLOSE sites_need_to_create;

    status := 0;

    arp_message.set_line( 'ARP_CMERGE_ARCUS.create_same_sites()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCUS.create_same_sites' );
      status := -1;

END create_same_sites;


/*===========================================================================+
 | PROCEDURE
 |              merge_history
 |
 | DESCRIPTION
 |          For recording the data in the tables modified in TCA registry
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id , set_num
 |              OUT:  status
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY -
 |                       Jyoti Pandey 05-20-2002 Created.
 |
 +===========================================================================*/

PROCEDURE merge_history(req_id  NUMBER,
                        set_num NUMBER,
                        status  OUT NOCOPY NUMBER) IS

l_customer_merge_header_id RA_CUSTOMER_MERGES.customer_merge_header_id%TYPE;


BEGIN

   arp_message.set_line( 'ARP_CMERGE_ARCUS.Merge_History()+' );

  ---------Insert into HZ_CUST_ACCOUNTS_M--------------
  INSERT INTO HZ_CUST_ACCOUNTS_M(
  customer_merge_header_id,
  cust_account_id,
  party_id      ,
  last_update_date ,
  account_number   ,
  last_updated_by  ,
  creation_date   ,
  created_by     ,
  last_update_login,
  request_id       ,
  program_application_id,
  program_id            ,
  program_update_date   ,
  attribute_category    ,
  attribute1            ,
  attribute2            ,
  attribute3            ,
  attribute4            ,
  attribute5            ,
  attribute6            ,
  attribute7,
  attribute8,
  attribute9 ,
  attribute10,
  attribute11,
  attribute12,
  attribute13,
  attribute14,
  attribute15,
  attribute16,
  attribute17,
  attribute18,
  attribute19,
  attribute20,
  global_attribute_category,
  global_attribute1,
  global_attribute2,
  global_attribute3,
  global_attribute4,
  global_attribute5,
  global_attribute6,
  global_attribute7,
  global_attribute8,
  global_attribute9,
  global_attribute10,
  global_attribute11,
  global_attribute12,
  global_attribute13,
  global_attribute14,
  global_attribute15,
  global_attribute16,
  global_attribute17,
  global_attribute18,
  global_attribute19,
  global_attribute20,
  orig_system_reference,
  status,
  customer_type,
  customer_class_code,
  primary_salesrep_id,
  sales_channel_code ,
  order_type_id      ,
  price_list_id      ,
  tax_code           ,
  fob_point          ,
  freight_term      ,
  ship_partial     ,
  ship_via         ,
  warehouse_id     ,
  tax_header_level_flag,
  tax_rounding_rule    ,
  coterminate_day_month,
  primary_specialist_id,
  secondary_specialist_id ,
  account_liable_flag    ,
  current_balance          ,
  account_established_date,
  account_termination_date   ,
  account_activation_date    ,
  department               ,
  held_bill_expiration_date,
  hold_bill_flag           ,
  realtime_rate_flag      ,
  acct_life_cycle_status,
  account_name          ,
  deposit_refund_method ,
  dormant_account_flag  ,
  npa_number            ,
  suspension_date       ,
  Source_code             ,
  competitor_type         ,
  comments                ,
  dates_negative_tolerance,
  dates_positive_tolerance,
  date_type_preference    ,
  over_shipment_tolerance ,
  under_shipment_tolerance,
  over_return_tolerance   ,
  under_return_tolerance  ,
  item_cross_ref_pref     ,
  ship_sets_include_lines_flag ,
  arrivalsets_include_lines_flag,
  sched_date_push_flag      ,
  invoice_quantity_rule     ,
  pricing_event             ,
  status_update_date        ,
  autopay_flag              ,
  notify_flag               ,
  last_batch_id             ,
  org_id                    ,
  object_version_number     ,
  created_by_module         ,
  application_id           ,
  selling_party_id         ,
  merge_request_id
)
  SELECT
  customer_merge_header_id,
  cust_account_id,
  party_id      ,
  c.last_update_date ,
  c.account_number   ,
  c.last_updated_by  ,
  c.creation_date   ,
  c.created_by     ,
  c.last_update_login,
  c.request_id       ,
  c.program_application_id,
  c.program_id            ,
  c.program_update_date   ,
  c.attribute_category    ,
  c.attribute1            ,
  c.attribute2            ,
  c.attribute3            ,
  c.attribute4            ,
  c.attribute5            ,
  c.attribute6            ,
  c.attribute7,
  c.attribute8,
  c.attribute9 ,
  c.attribute10,
  c.attribute11,
  c.attribute12,
  c.attribute13,
  c.attribute14,
  c.attribute15,
  c.attribute16,
  c.attribute17,
  c.attribute18,
  c.attribute19,
  c.attribute20,
  c.global_attribute_category,
  c.global_attribute1,
  c.global_attribute2,
  c.global_attribute3,
  c.global_attribute4,
  c.global_attribute5,
  c.global_attribute6,
  c.global_attribute7,
  c.global_attribute8,
  c.global_attribute9,
  c.global_attribute10,
  c.global_attribute11,
  c.global_attribute12,
  c.global_attribute13,
  c.global_attribute14,
  c.global_attribute15,
  c.global_attribute16,
  c.global_attribute17,
  c.global_attribute18,
  c.global_attribute19,
  c.global_attribute20,
  c.orig_system_reference,
  c.status,
  c.customer_type,
  c.customer_class_code,
  c.primary_salesrep_id,
  c.sales_channel_code ,
  c.order_type_id      ,
  c.price_list_id      ,
  c.tax_code           ,
  c.fob_point          ,
  c.freight_term      ,
  c.ship_partial     ,
  c.ship_via         ,
  c.warehouse_id     ,
  c.tax_header_level_flag,
  c.tax_rounding_rule    ,
  c.coterminate_day_month,
  c.primary_specialist_id,
  c.secondary_specialist_id ,
  c.account_liable_flag    ,
  c.current_balance          ,
  c.account_established_date,
  c.account_termination_date   ,
  c.account_activation_date    ,
  c.department               ,
  c.held_bill_expiration_date,
  c.hold_bill_flag           ,
  c.realtime_rate_flag      ,
  c.acct_life_cycle_status,
  c.account_name          ,
  c.deposit_refund_method ,
  c.dormant_account_flag  ,
  c.npa_number            ,
  c.suspension_date       ,
  c.source_code             ,
  c.competitor_type         ,
  c.comments                ,
  c.dates_negative_tolerance,
  c.dates_positive_tolerance,
  c.date_type_preference    ,
  c.over_shipment_tolerance ,
  c.under_shipment_tolerance,
  c.over_return_tolerance   ,
  c.under_return_tolerance  ,
  c.item_cross_ref_pref     ,
  c.ship_sets_include_lines_flag ,
  c.arrivalsets_include_lines_flag,
  c.sched_date_push_flag      ,
  c.invoice_quantity_rule     ,
  c.pricing_event             ,
  c.status_update_date        ,
  c.autopay_flag              ,
  c.notify_flag               ,
  c.last_batch_id             ,
  c.org_id                    ,
  c.object_version_number     ,
  c.created_by_module         ,
  c.application_id           ,
  c.selling_party_id         ,
  req_id
FROM (select distinct duplicate_id , customer_merge_header_id , customer_id
      from ra_customer_merges cm
      where cm.process_flag = 'N'
      and   cm.request_id = req_id
      and   cm.set_number = set_num) , HZ_CUST_ACCOUNTS c
WHERE  c.cust_account_id = duplicate_id
AND    duplicate_id <> customer_id;

 arp_message.set_line(SQL%ROWCOUNT||' '|| 'Row(s) inserted in HZ_CUST_ACCOUNTS_M');



  ---------Insert into hz_cust_account_roles_m--------------
  --Because roles can be set up at acct and site level, we need to select
  --distict duplicate and customer_merge_header_id if acct with multiple sites
  --have roles set up at account level.

  INSERT INTO hz_cust_account_roles_m(
  customer_merge_header_id,
  cust_account_role_id      ,
  party_id                  ,
  cust_account_id           ,
  cust_acct_site_id          ,
  primary_flag               ,
  role_type                  ,
  last_update_date           ,
  source_code                ,
  last_updated_by            ,
  creation_date              ,
  created_by                 ,
  last_update_login          ,
  request_id                 ,
  program_application_id     ,
  program_id                 ,
  program_update_date        ,
  attribute_category         ,
  attribute1                 ,
  attribute2                 ,
  attribute3                 ,
  attribute4                 ,
  attribute5                 ,
  attribute6                 ,
  attribute7                 ,
  attribute8                ,
  attribute9                ,
  attribute10               ,
  attribute11               ,
  attribute12               ,
  attribute13               ,
  attribute14              ,
  attribute15              ,
  attribute16              ,
  attribute17              ,
  attribute18              ,
  attribute19              ,
  attribute20              ,
  attribute21              ,
  attribute22              ,
  attribute23,
  attribute24,
  global_attribute_category ,
  global_attribute1         ,
  global_attribute2         ,
  global_attribute3         ,
  global_attribute4         ,
  global_attribute5        ,
  global_attribute6        ,
  global_attribute7        ,
  global_attribute8        ,
  global_attribute9        ,
  global_attribute10       ,
  global_attribute11       ,
  global_attribute12       ,
  global_attribute13       ,
  global_attribute14      ,
  global_attribute15      ,
  global_attribute16      ,
  global_attribute17      ,
  global_attribute18      ,
  global_attribute19      ,
  global_attribute20      ,
  orig_system_reference  ,
  attribute25           ,
  status               ,
  object_version_number,
  created_by_module     ,
  application_id         ,
  merge_request_id
 )
 SELECT distinct
  customer_merge_header_id,
  ar.cust_account_role_id      ,
  ar.party_id                  ,
  ar.cust_account_id           ,
  ar.cust_acct_site_id          ,
  ar.primary_flag               ,
  ar.role_type                  ,
  ar.last_update_date           ,
  ar.source_code                ,
  ar.last_updated_by            ,
  ar.creation_date              ,
  ar.created_by                 ,
  ar.last_update_login          ,
  ar.request_id                 ,
  ar.program_application_id     ,
  ar.program_id                 ,
  ar.program_update_date        ,
  ar.attribute_category         ,
  ar.attribute1                 ,
  ar.attribute2                 ,
  ar.attribute3                 ,
  ar.attribute4                 ,
  ar.attribute5                 ,
  ar.attribute6                 ,
  ar.attribute7                 ,
  ar.attribute8                ,
  ar.attribute9                ,
  ar.attribute10               ,
  ar.attribute11               ,
  ar.attribute12               ,
  ar.attribute13               ,
  ar.attribute14              ,
  ar.attribute15              ,
  ar.attribute16              ,
  ar.attribute17              ,
  ar.attribute18              ,
  ar.attribute19              ,
  ar.attribute20              ,
  ar.attribute21              ,
  ar.attribute22              ,
  ar.attribute23,
  ar.attribute24,
  ar.global_attribute_category ,
  ar.global_attribute1         ,
  ar.global_attribute2         ,
  ar.global_attribute3         ,
  ar.global_attribute4         ,
  ar.global_attribute5        ,
  ar.global_attribute6        ,
  ar.global_attribute7        ,
  ar.global_attribute8        ,
  ar.global_attribute9        ,
  ar.global_attribute10       ,
  ar.global_attribute11       ,
  ar.global_attribute12       ,
  ar.global_attribute13       ,
  ar.global_attribute14      ,
  ar.global_attribute15      ,
  ar.global_attribute16      ,
  ar.global_attribute17      ,
  ar.global_attribute18      ,
  ar.global_attribute19      ,
  ar.global_attribute20      ,
  ar.orig_system_reference  ,
  ar.attribute25           ,
  ar.status               ,
  ar.object_version_number,
  ar.created_by_module     ,
  ar.application_id         ,
  req_id
 FROM(select distinct duplicate_id,duplicate_address_id,customer_merge_header_id
      from ra_customer_merges cm
      where cm.process_flag = 'N'
      and cm.request_id = req_id
      and cm.set_number = set_num
      and cm.duplicate_id <> cm.customer_id), hz_cust_account_roles ar
 WHERE ( ar.cust_account_id   = duplicate_id  OR
         ar.cust_acct_site_id = duplicate_address_id  )
 AND ar.role_type = 'CONTACT';

 arp_message.set_line(SQL%ROWCOUNT||' '|| 'Row(s) inserted in HZ_CUST_ACCOUNT_ROLES_M');

  ---------Insert into hz_customer_profiles_m--------------
  --Because profiles can be set up at acct and site use level, we need to select
  --distict duplicate and customer_merge_header_id if acct with multiple sites
  --have profiles set up at account level.

  INSERT INTO hz_customer_profiles_m(
  customer_merge_header_id,
  cust_account_profile_id,
  last_updated_by     ,
  last_update_date    ,
  last_update_login   ,
  created_by          ,
  creation_date       ,
  cust_account_id     ,
  status              ,
  collector_id        ,
  credit_analyst_id   ,
  credit_checking     ,
  next_credit_review_date ,
  tolerance           ,
  discount_terms      ,
  dunning_letters     ,
  interest_charges    ,
  send_statements     ,
  credit_balance_statements,
  credit_hold         ,
  profile_class_id    ,
  site_use_id         ,
  credit_rating      ,
  risk_code           ,
  standard_terms      ,
  override_terms      ,
  dunning_letter_set_id    ,
  interest_period_days     ,
  payment_grace_days       ,
  discount_grace_days      ,
  statement_cycle_id       ,
  account_status           ,
  percent_collectable      ,
  autocash_hierarchy_id    ,
  attribute_category       ,
  attribute1               ,
  attribute2               ,
  attribute3               ,
  attribute4               ,
  attribute5               ,
  attribute6               ,
  attribute7              ,
  attribute8              ,
  attribute9              ,
  attribute10             ,
  program_application_id  ,
  program_id              ,
  program_update_date     ,
  request_id              ,
  wh_update_date         ,
  attribute11           ,
  attribute12          ,
  attribute13         ,
  attribute14        ,
  attribute15       ,
  auto_rec_incl_disputed_flag ,
  tax_printing_option       ,
  charge_on_finance_charge_flag ,
  grouping_rule_id          ,
  clearing_days            ,
  jgzz_attribute_category  ,
  jgzz_attribute1          ,
  jgzz_attribute2          ,
  jgzz_attribute3          ,
  jgzz_attribute4         ,
  jgzz_attribute5         ,
  jgzz_attribute6        ,
  jgzz_attribute7       ,
  jgzz_attribute8      ,
  jgzz_attribute9     ,
  jgzz_attribute10    ,
  jgzz_attribute11  ,
  jgzz_attribute12 ,
  jgzz_attribute13,
  jgzz_attribute14 ,
  jgzz_attribute15,
  global_attribute1,
  global_attribute2,
  global_attribute3,
  global_attribute4,
  global_attribute5,
  global_attribute6,
  global_attribute7,
  global_attribute8,
  global_attribute9,
  global_attribute10,
  global_attribute11 ,
  global_attribute12  ,
  global_attribute13   ,
  global_attribute14    ,
  global_attribute15   ,
  global_attribute16    ,
  global_attribute17     ,
  global_attribute18    ,
  global_attribute19   ,
  global_attribute20  ,
  global_attribute_category  ,
  cons_inv_flag             ,
  cons_inv_type            ,
  autocash_hierarchy_id_for_adr ,
  lockbox_matching_option    ,
  object_version_number     ,
  created_by_module          ,
  application_id            ,
  review_cycle             ,
  party_id                ,
  last_credit_review_date ,
  merge_request_id,
  automatch_set_id      --8477178
 )
 SELECT distinct
  customer_merge_header_id,
  cp.cust_account_profile_id,
  cp.last_updated_by     ,
  cp.last_update_date    ,
  cp.last_update_login   ,
  cp.created_by          ,
  cp.creation_date       ,
  cp.cust_account_id     ,
  cp.status              ,
  cp.collector_id        ,
  cp.credit_analyst_id   ,
  cp.credit_checking     ,
  cp.next_credit_review_date ,
  cp.tolerance           ,
  cp.discount_terms      ,
  cp.dunning_letters     ,
  cp.interest_charges    ,
  cp.send_statements     ,
  cp.credit_balance_statements,
  cp.credit_hold         ,
  cp.profile_class_id    ,
  cp.site_use_id         ,
  cp.credit_rating      ,
  cp.risk_code           ,
  cp.standard_terms      ,
  cp.override_terms      ,
  cp.dunning_letter_set_id    ,
  cp.interest_period_days     ,
  cp.payment_grace_days       ,
  cp.discount_grace_days      ,
  cp.statement_cycle_id       ,
  cp.account_status           ,
  cp.percent_collectable      ,
  cp.autocash_hierarchy_id    ,
  cp.attribute_category       ,
  cp.attribute1               ,
  cp.attribute2               ,
  cp.attribute3               ,
  cp.attribute4               ,
  cp.attribute5               ,
  cp.attribute6               ,
  cp.attribute7              ,
  cp.attribute8              ,
  cp.attribute9              ,
  cp.attribute10             ,
  cp.program_application_id  ,
  cp.program_id              ,
  cp.program_update_date     ,
  cp.request_id              ,
  cp.wh_update_date         ,
  cp.attribute11           ,
  cp.attribute12          ,
  cp.attribute13         ,
  cp.attribute14        ,
  cp.attribute15       ,
  cp.auto_rec_incl_disputed_flag ,
  cp.tax_printing_option       ,
  cp.charge_on_finance_charge_flag ,
  cp.grouping_rule_id          ,
  cp.clearing_days            ,
  cp.jgzz_attribute_category  ,
  cp.jgzz_attribute1          ,
  cp.jgzz_attribute2          ,
  cp.jgzz_attribute3          ,
  cp.jgzz_attribute4         ,
  cp.jgzz_attribute5         ,
  cp.jgzz_attribute6        ,
  cp.jgzz_attribute7       ,
  cp.jgzz_attribute8      ,
  cp.jgzz_attribute9     ,
  cp.jgzz_attribute10    ,
  cp.jgzz_attribute11  ,
  cp.jgzz_attribute12 ,
  cp.jgzz_attribute13,
  cp.jgzz_attribute14 ,
  cp.jgzz_attribute15,
  cp.global_attribute1,
  cp.global_attribute2,
  cp.global_attribute3,
  cp.global_attribute4,
  cp.global_attribute5,
  cp.global_attribute6,
  cp.global_attribute7,
  cp.global_attribute8,
  cp.global_attribute9,
  cp.global_attribute10,
  cp.global_attribute11 ,
  cp.global_attribute12  ,
  cp.global_attribute13   ,
  cp.global_attribute14    ,
  cp.global_attribute15   ,
  cp.global_attribute16    ,
  cp.global_attribute17     ,
  cp.global_attribute18    ,
  cp.global_attribute19   ,
  cp.global_attribute20  ,
  cp.global_attribute_category  ,
  cp.cons_inv_flag             ,
  cp.cons_inv_type            ,
  cp.autocash_hierarchy_id_for_adr ,
  cp.lockbox_matching_option    ,
  cp.object_version_number     ,
  cp.created_by_module          ,
  cp.application_id            ,
  cp.review_cycle             ,
  cp.party_id                ,
  cp.last_credit_review_date ,
  req_id,
  cp.automatch_set_id    --bug 8477178
 FROM(select distinct duplicate_id,duplicate_site_id,customer_merge_header_id
      from ra_customer_merges cm
      where cm.process_flag = 'N'
      and cm.request_id = req_id
      and cm.set_number = set_num
      and cm.duplicate_id <> cm.customer_id ), hz_customer_profiles cp
 WHERE  ( cp.cust_account_id = duplicate_id AND cp.site_use_id is NULL)
       OR (cp.site_use_id = duplicate_site_id );

 arp_message.set_line(SQL%ROWCOUNT||' '|| 'Row(s) inserted in HZ_CUSTOMER_PROFILES_M');

  ---------Insert into hz_cust_profile_amts_m--------------
  --Because profiles can be set up at acct and site use level, we need to select
  --distict duplicate and customer_merge_header_id if acct with multiple sites
  --have profiles set up at account level.

  INSERT INTO hz_cust_profile_amts_m(
  customer_merge_header_id,
  cust_acct_profile_amt_id   ,
  last_updated_by            ,
  last_update_date           ,
  created_by                 ,
  creation_date              ,
  cust_account_profile_id    ,
  currency_code              ,
  last_update_login          ,
  trx_credit_limit           ,
  overall_credit_limit       ,
  min_dunning_amount         ,
  min_dunning_invoice_amount ,
  max_interest_charge        ,
  min_statement_amount       ,
  auto_rec_min_receipt_amount,
  interest_rate              ,
  attribute_category         ,
  attribute1                 ,
  attribute2                 ,
  attribute3                 ,
  attribute4                 ,
  attribute5                 ,
  attribute6                 ,
  attribute7                 ,
  attribute8                 ,
  attribute9                 ,
  attribute10                ,
  attribute11                ,
  attribute12                ,
  attribute13                ,
  attribute14                ,
  attribute15                ,
  min_fc_balance_amount      ,
  min_fc_invoice_amount      ,
  cust_account_id            ,
  site_use_id                ,
  expiration_date            ,
  request_id                 ,
  program_application_id     ,
  program_id                 ,
  program_update_date        ,
  wh_update_date             ,
  jgzz_attribute_category    ,
  jgzz_attribute1            ,
  jgzz_attribute2            ,
  jgzz_attribute3            ,
  jgzz_attribute4            ,
  jgzz_attribute5            ,
  jgzz_attribute6            ,
  jgzz_attribute7            ,
  jgzz_attribute8            ,
  jgzz_attribute9            ,
  jgzz_attribute10           ,
  jgzz_attribute11           ,
  jgzz_attribute12           ,
  jgzz_attribute13           ,
  jgzz_attribute14           ,
  jgzz_attribute15           ,
  global_attribute1          ,
  global_attribute2          ,
  global_attribute3          ,
  global_attribute4          ,
  global_attribute5          ,
  global_attribute6          ,
  global_attribute7          ,
  global_attribute8          ,
  global_attribute9          ,
  global_attribute10         ,
  global_attribute11         ,
  global_attribute12         ,
  global_attribute13         ,
  global_attribute14         ,
  global_attribute15         ,
  global_attribute16         ,
  global_attribute17         ,
  global_attribute18         ,
  global_attribute19         ,
  global_attribute20         ,
  global_attribute_category  ,
  object_version_number      ,
  created_by_module          ,
  application_id             ,
  merge_request_id
 )
 select distinct
  customer_merge_header_id,
  pa.cust_acct_profile_amt_id   ,
  pa.last_updated_by            ,
  pa.last_update_date           ,
  pa.created_by                 ,
  pa.creation_date              ,
  pa.cust_account_profile_id    ,
  pa.currency_code              ,
  pa.last_update_login          ,
  pa.trx_credit_limit           ,
  pa.overall_credit_limit       ,
  pa.min_dunning_amount         ,
  pa.min_dunning_invoice_amount ,
  pa.max_interest_charge        ,
  pa.min_statement_amount       ,
  pa.auto_rec_min_receipt_amount,
  pa.interest_rate              ,
  pa.attribute_category         ,
  pa.attribute1                 ,
  pa.attribute2                 ,
  pa.attribute3                 ,
  pa.attribute4                 ,
  pa.attribute5                 ,
  pa.attribute6                 ,
  pa.attribute7                 ,
  pa.attribute8                 ,
  pa.attribute9                 ,
  pa.attribute10                ,
  pa.attribute11                ,
  pa.attribute12                ,
  pa.attribute13                ,
  pa.attribute14                ,
  pa.attribute15                ,
  pa.min_fc_balance_amount      ,
  pa.min_fc_invoice_amount      ,
  pa.cust_account_id            ,
  pa.site_use_id                ,
  pa.expiration_date            ,
  pa.request_id                 ,
  pa.program_application_id     ,
  pa.program_id                 ,
  pa.program_update_date        ,
  pa.wh_update_date             ,
  pa.jgzz_attribute_category    ,
  pa.jgzz_attribute1            ,
  pa.jgzz_attribute2            ,
  pa.jgzz_attribute3            ,
  pa.jgzz_attribute4            ,
  pa.jgzz_attribute5            ,
  pa.jgzz_attribute6            ,
  pa.jgzz_attribute7            ,
  pa.jgzz_attribute8            ,
  pa.jgzz_attribute9            ,
  pa.jgzz_attribute10           ,
  pa.jgzz_attribute11           ,
  pa.jgzz_attribute12           ,
  pa.jgzz_attribute13           ,
  pa.jgzz_attribute14           ,
  pa.jgzz_attribute15           ,
  pa.global_attribute1          ,
  pa.global_attribute2          ,
  pa.global_attribute3          ,
  pa.global_attribute4          ,
  pa.global_attribute5          ,
  pa.global_attribute6          ,
  pa.global_attribute7          ,
  pa.global_attribute8          ,
  pa.global_attribute9          ,
  pa.global_attribute10         ,
  pa.global_attribute11         ,
  pa.global_attribute12         ,
  pa.global_attribute13         ,
  pa.global_attribute14         ,
  pa.global_attribute15         ,
  pa.global_attribute16         ,
  pa.global_attribute17         ,
  pa.global_attribute18         ,
  pa.global_attribute19         ,
  pa.global_attribute20         ,
  pa.global_attribute_category  ,
  pa.object_version_number      ,
  pa.created_by_module          ,
  pa.application_id             ,
  req_id
FROM (select distinct duplicate_id,duplicate_site_id,customer_merge_header_id
      from ra_customer_merges cm
      where cm.process_flag = 'N'
      and cm.request_id = req_id
      and cm.set_number = set_num ),hz_cust_profile_amts pa
WHERE (pa.cust_account_id = duplicate_id and pa.site_use_id is NULL)
OR    (pa.site_use_id  =  duplicate_site_id);

 arp_message.set_line(SQL%ROWCOUNT||' '|| 'Row(s) inserted in HZ_CUST_PROFILE_AMTS_M');

  ---------Insert into hz_cust_acct_sites_all_m--------------
  INSERT INTO hz_cust_acct_sites_all_m(
  customer_merge_header_id,
  cust_acct_site_id          ,
  cust_account_id            ,
  party_site_id              ,
  last_update_date           ,
  last_updated_by            ,
  creation_date              ,
  created_by                 ,
  last_update_login          ,
  request_id                 ,
  program_application_id     ,
  program_id                 ,
  program_update_date        ,
--wh_update_date             ,
  attribute_category         ,
  attribute1                 ,
  attribute2                 ,
  attribute3                 ,
  attribute4                 ,
  attribute5                 ,
  attribute6                 ,
  attribute7                 ,
  attribute8                 ,
  attribute9                 ,
  attribute10                ,
  attribute11                ,
  attribute12                ,
  attribute13                ,
  attribute14                ,
  attribute15                ,
  attribute16                ,
  attribute17                ,
  attribute18                ,
  attribute19                ,
  attribute20                ,
  global_attribute_category  ,
  global_attribute1          ,
  global_attribute2          ,
  global_attribute3          ,
  global_attribute4          ,
  global_attribute5          ,
  global_attribute6          ,
  global_attribute7          ,
  global_attribute8          ,
  global_attribute9          ,
  global_attribute10         ,
  global_attribute11         ,
  global_attribute12         ,
  global_attribute13         ,
  global_attribute14         ,
  global_attribute15         ,
  global_attribute16         ,
  global_attribute17         ,
  global_attribute18         ,
  global_attribute19         ,
  global_attribute20         ,
  orig_system_reference      ,
  status                     ,
  org_id                     ,
  bill_to_flag               ,
  market_flag                ,
  ship_to_flag               ,
  customer_category_code     ,
  language                   ,
  key_account_flag           ,
  tp_header_id               ,
  ece_tp_location_code       ,
--service_territory_id       ,
  primary_specialist_id      ,
  secondary_specialist_id    ,
  territory_id               ,
  address_text               ,
  territory                  ,
  translated_customer_name   ,
  object_version_number      ,
  created_by_module          ,
  application_id             ,
  merge_request_id
)
 select
  customer_merge_header_id,
  acs.cust_acct_site_id          ,
  acs.cust_account_id            ,
  acs.party_site_id              ,
  acs.last_update_date           ,
  acs.last_updated_by            ,
  acs.creation_date              ,
  acs.created_by                 ,
  acs.last_update_login          ,
  acs.request_id                 ,
  acs.program_application_id     ,
  acs.program_id                 ,
  acs.program_update_date        ,
--wh_update_date             ,
  acs.attribute_category         ,
  acs.attribute1                 ,
  acs.attribute2                 ,
  acs.attribute3                 ,
  acs.attribute4                 ,
  acs.attribute5                 ,
  acs.attribute6                 ,
  acs.attribute7                 ,
  acs.attribute8                 ,
  acs.attribute9                 ,
  acs.attribute10                ,
  acs.attribute11                ,
  acs.attribute12                ,
  acs.attribute13                ,
  acs.attribute14                ,
  acs.attribute15                ,
  acs.attribute16                ,
  acs.attribute17                ,
  acs.attribute18                ,
  acs.attribute19                ,
  acs.attribute20                ,
  acs.global_attribute_category  ,
  acs.global_attribute1          ,
  acs.global_attribute2          ,
  acs.global_attribute3          ,
  acs.global_attribute4          ,
  acs.global_attribute5          ,
  acs.global_attribute6          ,
  acs.global_attribute7          ,
  acs.global_attribute8          ,
  acs.global_attribute9          ,
  acs.global_attribute10         ,
  acs.global_attribute11         ,
  acs.global_attribute12         ,
  acs.global_attribute13         ,
  acs.global_attribute14         ,
  acs.global_attribute15         ,
  acs.global_attribute16         ,
  acs.global_attribute17         ,
  acs.global_attribute18         ,
  acs.global_attribute19         ,
  acs.global_attribute20         ,
  acs.orig_system_reference      ,
  acs.status                     ,
  acs.org_id                     ,
  acs.bill_to_flag               ,
  acs.market_flag                ,
  acs.ship_to_flag               ,
  acs.customer_category_code     ,
  acs.language                   ,
  acs.key_account_flag           ,
  acs.tp_header_id               ,
  acs.ece_tp_location_code       ,
--service_territory_id       ,
  acs.primary_specialist_id      ,
  acs.secondary_specialist_id    ,
  acs.territory_id               ,
  acs.address_text               ,
  acs.territory                  ,
  acs.translated_customer_name   ,
  acs.object_version_number      ,
  acs.created_by_module          ,
  acs.application_id             ,
  req_id
FROM (select distinct duplicate_id,duplicate_address_id,customer_merge_header_id,org_id
      from ra_customer_merges cm
      where cm.process_flag = 'N'
      and cm.request_id = req_id
      and cm.set_number = set_num ) m,hz_cust_acct_sites_all acs
WHERE acs.cust_acct_site_id = duplicate_address_id
AND   acs.org_id  = m.org_id ;

 arp_message.set_line(SQL%ROWCOUNT||' '|| 'Row(s) inserted in HZ_CUST_ACCT_SITES_ALL_M');

  ---------Insert into hz_cust_site_uses_all_m--------------
  INSERT INTO hz_cust_site_uses_all_m(
  customer_merge_header_id,
  site_use_id                ,
  cust_acct_site_id          ,
  last_update_date           ,
  last_updated_by            ,
  creation_date              ,
  created_by                 ,
  site_use_code              ,
  primary_flag               ,
  status                     ,
  location                   ,
  last_update_login          ,
  contact_id                 ,
  bill_to_site_use_id        ,
  orig_system_reference      ,
  sic_code                   ,
  payment_term_id            ,
  gsa_indicator              ,
  ship_partial               ,
  ship_via                   ,
  fob_point                  ,
  order_type_id              ,
  price_list_id              ,
  freight_term               ,
  warehouse_id               ,
  territory_id               ,
  attribute_category         ,
  attribute1                 ,
  attribute2                 ,
  attribute3                 ,
  attribute4                 ,
  attribute5                 ,
  attribute6                 ,
  attribute7                 ,
  attribute8                 ,
  attribute9                 ,
  attribute10                ,
  request_id                 ,
  program_application_id     ,
  program_id                 ,
  program_update_date        ,
  tax_reference              ,
  sort_priority              ,
  tax_code                   ,
  attribute11                ,
  attribute12                ,
  attribute13                ,
  attribute14                ,
  attribute15                ,
  attribute16                ,
  attribute17                ,
  attribute18                ,
  attribute19                ,
  attribute20                ,
  attribute21                ,
  attribute22                ,
  attribute23                ,
  attribute24                ,
  attribute25                ,
  last_accrue_charge_date    ,
  second_last_accrue_charge_date  ,
  last_unaccrue_charge_date  ,
  second_last_unaccrue_chrg_date  ,
  demand_class_code          ,
  org_id,
  tax_header_level_flag      ,
  tax_rounding_rule          ,
  --wh_update_date           ,
  global_attribute1          ,
  global_attribute2          ,
  global_attribute3          ,
  global_attribute4          ,
  global_attribute5          ,
  global_attribute6          ,
  global_attribute7          ,
  global_attribute8          ,
  global_attribute9          ,
  global_attribute10         ,
  global_attribute11         ,
  global_attribute12         ,
  global_attribute13         ,
  global_attribute14         ,
  global_attribute15         ,
  global_attribute16         ,
  global_attribute17         ,
  global_attribute18         ,
  global_attribute19         ,
  global_attribute20         ,
  global_attribute_category  ,
  primary_salesrep_id        ,
  finchrg_receivables_trx_id ,
  dates_negative_tolerance   ,
  dates_positive_tolerance   ,
  date_type_preference       ,
  over_shipment_tolerance    ,
  under_shipment_tolerance   ,
  item_cross_ref_pref        ,
  over_return_tolerance      ,
  under_return_tolerance     ,
  ship_sets_include_lines_flag  ,
  arrivalsets_include_lines_flag  ,
  sched_date_push_flag       ,
  invoice_quantity_rule      ,
  pricing_event              ,
  gl_id_rec                  ,
  gl_id_rev                  ,
  gl_id_tax                  ,
  gl_id_freight              ,
  gl_id_clearing             ,
  gl_id_unbilled             ,
  gl_id_unearned             ,
  gl_id_unpaid_rec           ,
  gl_id_remittance           ,
  gl_id_factor               ,
  tax_classification         ,
  object_version_number      ,
  created_by_module          ,
  application_id             ,
  merge_request_id
)
select
  customer_merge_header_id,
  su.site_use_id                ,
  su.cust_acct_site_id          ,
  su.last_update_date           ,
  su.last_updated_by            ,
  su.creation_date              ,
  su.created_by                 ,
  su.site_use_code              ,
  su.primary_flag               ,
  su.status                     ,
  su.location                   ,
  su.last_update_login          ,
  su.contact_id                 ,
  su.bill_to_site_use_id        ,
  su.orig_system_reference      ,
  su.sic_code                   ,
  su.payment_term_id            ,
  su.gsa_indicator              ,
  su.ship_partial               ,
  su.ship_via                   ,
  su.fob_point                  ,
  su.order_type_id              ,
  su.price_list_id              ,
  su.freight_term               ,
  su.warehouse_id               ,
  su.territory_id               ,
  su.attribute_category         ,
  su.attribute1                 ,
  su.attribute2                 ,
  su.attribute3                 ,
  su.attribute4                 ,
  su.attribute5                 ,
  su.attribute6                 ,
  su.attribute7                 ,
  su.attribute8                 ,
  su.attribute9                 ,
  su.attribute10                ,
  su.request_id                 ,
  su.program_application_id     ,
  su.program_id                 ,
  su.program_update_date        ,
  su.tax_reference              ,
  su.sort_priority              ,
  su.tax_code                   ,
  su.attribute11                ,
  su.attribute12                ,
  su.attribute13                ,
  su.attribute14                ,
  su.attribute15                ,
  su.attribute16                ,
  su.attribute17                ,
  su.attribute18                ,
  su.attribute19                ,
  su.attribute20                ,
  su.attribute21                ,
  su.attribute22                ,
  su.attribute23                ,
  su.attribute24                ,
  su.attribute25                ,
  su.last_accrue_charge_date    ,
  su.second_last_accrue_charge_date  ,
  su.last_unaccrue_charge_date  ,
  su.second_last_unaccrue_chrg_date  ,
  su.demand_class_code          ,
  su.org_id,
  su.tax_header_level_flag      ,
  su.tax_rounding_rule          ,
  --wh_update_date           ,
  su.global_attribute1          ,
  su.global_attribute2          ,
  su.global_attribute3          ,
  su.global_attribute4          ,
  su.global_attribute5          ,
  su.global_attribute6          ,
  su.global_attribute7          ,
  su.global_attribute8          ,
  su.global_attribute9          ,
  su.global_attribute10         ,
  su.global_attribute11         ,
  su.global_attribute12         ,
  su.global_attribute13         ,
  su.global_attribute14         ,
  su.global_attribute15         ,
  su.global_attribute16         ,
  su.global_attribute17         ,
  su.global_attribute18         ,
  su.global_attribute19         ,
  su.global_attribute20         ,
  su.global_attribute_category  ,
  su.primary_salesrep_id        ,
  su.finchrg_receivables_trx_id ,
  su.dates_negative_tolerance   ,
  su.dates_positive_tolerance   ,
  su.date_type_preference       ,
  su.over_shipment_tolerance    ,
  su.under_shipment_tolerance   ,
  su.item_cross_ref_pref        ,
  su.over_return_tolerance      ,
  su.under_return_tolerance     ,
  su.ship_sets_include_lines_flag  ,
  su.arrivalsets_include_lines_flag  ,
  su.sched_date_push_flag       ,
  su.invoice_quantity_rule      ,
  su.pricing_event              ,
  su.gl_id_rec                  ,
  su.gl_id_rev                  ,
  su.gl_id_tax                  ,
  su.gl_id_freight              ,
  su.gl_id_clearing             ,
  su.gl_id_unbilled             ,
  su.gl_id_unearned             ,
  su.gl_id_unpaid_rec           ,
  su.gl_id_remittance           ,
  su.gl_id_factor               ,
  su.tax_classification         ,
  su.object_version_number      ,
  su.created_by_module          ,
  su.application_id             ,
  req_id
FROM (select distinct duplicate_site_id,customer_merge_header_id,org_id
      from ra_customer_merges cm
      where cm.process_flag = 'N'
      and cm.request_id = req_id
      and cm.set_number = set_num ) m,hz_cust_site_uses_all su --SSUptake
WHERE su.site_use_id = duplicate_site_id
AND   su.org_id  = m.org_id; --SSUptake

 arp_message.set_line(SQL%ROWCOUNT||' '|| 'Row(s) inserted in HZ_CUST_SITE_USES_ALL_M');

---------Insert into hz_cust_acct_relate_all_m--------------
INSERT INTO hz_cust_acct_relate_all_m(
  customer_merge_header_id,
  cust_account_id            ,
  related_cust_account_id    ,
  last_update_date           ,
  last_updated_by            ,
  creation_date              ,
  created_by                 ,
  last_update_login          ,
  relationship_type          ,
  comments                   ,
  attribute_category         ,
  attribute1                 ,
  attribute2                 ,
  attribute3                 ,
  attribute4                 ,
  attribute5                 ,
  attribute6                 ,
  attribute7                 ,
  attribute8                 ,
  attribute9                 ,
  attribute10                ,
  request_id                 ,
  program_application_id     ,
  program_id                 ,
  program_update_date        ,
  customer_reciprocal_flag   ,
  status                     ,
  attribute11                ,
  attribute12                ,
  attribute13                ,
  attribute14                ,
  attribute15                ,
  org_id                     ,
  bill_to_flag               ,
  ship_to_flag               ,
  object_version_number      ,
  created_by_module          ,
  application_id             ,
  merge_request_id	     ,
  cust_acct_relate_id            --bug 7593763
)
 SELECT
  customer_merge_header_id,
  yt.cust_account_id            ,
  yt.related_cust_account_id    ,
  yt.last_update_date           ,
  yt.last_updated_by            ,
  yt.creation_date              ,
  yt.created_by                 ,
  yt.last_update_login          ,
  yt.relationship_type          ,
  yt.comments                   ,
  yt.attribute_category         ,
  yt.attribute1                 ,
  yt.attribute2                 ,
  yt.attribute3                 ,
  yt.attribute4                 ,
  yt.attribute5                 ,
  yt.attribute6                 ,
  yt.attribute7                 ,
  yt.attribute8                 ,
  yt.attribute9                 ,
  yt.attribute10                ,
  yt.request_id                 ,
  yt.program_application_id     ,
  yt.program_id                 ,
  yt.program_update_date        ,
  yt.customer_reciprocal_flag   ,
  yt.status                     ,
  yt.attribute11                ,
  yt.attribute12                ,
  yt.attribute13                ,
  yt.attribute14                ,
  yt.attribute15                ,
  yt.org_id                     ,
  yt.bill_to_flag               ,
  yt.ship_to_flag               ,
  yt.object_version_number      ,
  yt.created_by_module          ,
  yt.application_id             ,
  req_id			,
  cust_acct_relate_id
FROM (select distinct duplicate_id, customer_merge_header_id,org_id
      from ra_customer_merges cm
      where cm.process_flag = 'N'
      and cm.request_id = req_id
      and cm.set_number = set_num
      and cm.duplicate_id <> cm.customer_id) m,hz_cust_acct_relate_all yt --SSUptake
WHERE ( yt.cust_account_id = duplicate_id OR
        yt.related_cust_account_id = duplicate_id )
AND   m.org_id = yt.org_id	; --SSUptake

 arp_message.set_line(SQL%ROWCOUNT||' '|| 'Row(s) inserted in HZ_CUST_ACCT_RELATE_ALL_M');


  ---After storing the merge data sucessfully initialize the status to 0
  status := 0;

 arp_message.set_line( 'ARP_CMERGE_ARCUS.Merge_History()-' );

EXCEPTION
 WHEN NO_DATA_FOUND THEN
  NULL;

 WHEN DUP_VAL_ON_INDEX THEN
 arp_message.set_line('Index Violation: ' || SQLERRM );


 WHEN OTHERS THEN
   arp_message.set_error('ARP_CMERGE_ARCUS.Merge_History');
   status := -1;


END merge_history;

--4527935
PROCEDURE create_acct_relate(p_cust_acct_relate_id NUMBER, p_customer_id NUMBER, p_cust_account_id NUMBER,p_related_cust_account_id NUMBER,p_rowid ROWID,p_reciprocal_flag boolean)
IS
p_cust_acct_relate_rec HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE;
x_return_status VARCHAR2(1);
x_msg_count NUMBER;
x_msg_data  varchar2(2000);
l_cust_acct_relate_id HZ_CUST_ACCT_RELATE_ALL.CUST_ACCT_RELATE_ID%TYPE;
BEGIN
HZ_CUST_ACCOUNT_V2PUB.get_cust_acct_relate_rec (
			       FND_API.G_FALSE,
			       p_cust_account_id,
			       p_related_cust_account_id,
			       p_cust_acct_relate_id,
			       p_rowid,
			       p_cust_acct_relate_rec,
			       x_return_status,
			       x_msg_count,
			       x_msg_data
			       );
IF(p_reciprocal_flag) THEN
 p_cust_acct_relate_rec.related_cust_account_id := p_customer_id;
ELSE
 p_cust_acct_relate_rec.cust_account_id := p_customer_id;
END IF;
p_cust_acct_relate_rec.created_by_module     := 'HZ_TCA_CUSTOMER_MERGE';
p_cust_acct_relate_rec.application_id        := arp_standard.profile.program_id;
l_cust_acct_relate_id := NULL;
-- Call table-handler.
    HZ_CUST_ACCT_RELATE_PKG.Insert_Row (
        X_CUST_ACCOUNT_ID                       => p_cust_acct_relate_rec.cust_account_id,
        X_RELATED_CUST_ACCOUNT_ID               => p_cust_acct_relate_rec.related_cust_account_id,
        X_RELATIONSHIP_TYPE                     => p_cust_acct_relate_rec.relationship_type,
        X_COMMENTS                              => p_cust_acct_relate_rec.comments,
        X_ATTRIBUTE_CATEGORY                    => p_cust_acct_relate_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_acct_relate_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_acct_relate_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_acct_relate_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_acct_relate_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_acct_relate_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_acct_relate_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_acct_relate_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_acct_relate_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_acct_relate_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_acct_relate_rec.attribute10,
        X_CUSTOMER_RECIPROCAL_FLAG              => p_cust_acct_relate_rec.customer_reciprocal_flag,
        X_STATUS                                => p_cust_acct_relate_rec.status,
        X_ATTRIBUTE11                           => p_cust_acct_relate_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_acct_relate_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_acct_relate_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_acct_relate_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_acct_relate_rec.attribute15,
        X_BILL_TO_FLAG                          => p_cust_acct_relate_rec.bill_to_flag,
        X_SHIP_TO_FLAG                          => p_cust_acct_relate_rec.ship_to_flag,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_cust_acct_relate_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_acct_relate_rec.application_id,
	X_ORG_ID				=> p_cust_acct_relate_rec.org_id,
	X_CUST_ACCT_RELATE_ID			=> l_cust_acct_relate_id
    );

END;

END arp_cmerge_arcus;

/
