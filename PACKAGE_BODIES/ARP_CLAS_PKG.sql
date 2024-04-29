--------------------------------------------------------
--  DDL for Package Body ARP_CLAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CLAS_PKG" as
/* $Header: AROCLASB.pls 120.8.12010000.2 2008/11/19 11:36:31 ankuagar ship $ */
--
--
-- PROCEDURE
--     check_unique	_inv_location
--
-- DESCRIPTION
--		This procedure ensures an inventory_location is only assigned to
--		one custoemr ship-to site.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			-- p_inventory_location_id
--
--              OUT:
--
-- NOTES
--
--
--
procedure check_unique_inv_location ( p_inventory_location_id in number, x_return_status out nocopy  varchar2,
                                      x_msg_count out nocopy number, x_msg_data out nocopy varchar2, l_org_id in number
                                     ) is
--
dummy number;
--
begin
	select 	count(1)
	into	dummy
	from 	po_location_associations_all
	where	location_id = p_inventory_location_id
	and     org_id = l_org_id;
	--
	if ( dummy >= 1 ) then
		fnd_message.set_name('AR','AR_CUST_DUP_INTERNAL_LOCATION');
		--app_exception.raise_exception;
                FND_MSG_PUB.ADD;
                x_return_status :=  FND_API.G_RET_STS_ERROR;
                x_msg_count := 1;
                x_msg_data := 'AR_CUST_DUP_INTERNAL_LOCATION';
        return;
	end if;
end check_unique_inv_location;
--
--
procedure check_unique_inv_location ( p_inventory_location_id in number ) is
--
dummy number;
--
begin
        select  count(1)
        into    dummy
        from    po_location_associations_all
        where   location_id = p_inventory_location_id;
        --
        if ( dummy >= 1 ) then
                fnd_message.set_name('AR','AR_CUST_DUP_INTERNAL_LOCATION');
                app_exception.raise_exception;
        end if;
end check_unique_inv_location;
--
--

--
-- PROCEDURE
--      insert_po_loc_associations
--
-- DESCRIPTION
--		This procedure inserts rows into the table po_location_associations
--		This table is simple implements a foreign key from ra_site_use.site_use_id
--		to hr_locations.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			-- p_inventory_location_id
--
--              OUT:
--
-- NOTES
--
--
--
procedure insert_po_loc_associations (	p_inventory_location_id		in number,
					p_inventory_organization_id	in number,
					p_customer_id 			in number,
					p_address_id			in number,
					p_site_use_id			in number,
                                        x_return_status                 out nocopy varchar2,
                                        x_msg_count                     out nocopy number,
                                        x_msg_data                      out nocopy varchar2
					) is
--

l_org_id        number;
l_return_status VARCHAR2(1);
begin

         BEGIN
                SELECT  org_id
                INTO    l_org_id
                FROM    HZ_CUST_ACCT_SITES_ALL
                WHERE   cust_acct_site_id
                        = p_address_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
                FND_MESSAGE.SET_TOKEN( 'RECORD', 'customer account site' );
                FND_MESSAGE.SET_TOKEN( 'VALUE',
                    NVL( TO_CHAR(
                        l_org_id ), 'null' ) );
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
          END;

	--
	 check_unique_inv_location( p_inventory_location_id => p_inventory_location_id, x_return_status => x_return_status, x_msg_count => x_msg_count, x_msg_data => x_msg_data, l_org_id => l_org_id );
         if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         return;
         end if;
	--

         BEGIN
           MO_GLOBAL.validate_orgid_pub_api( l_org_id,'N',l_return_status);
           EXCEPTION
           WHEN OTHERS
           THEN
             RAISE FND_API.G_EXC_ERROR;
         END;
	 insert into po_location_associations (
			location_id,
			last_update_date,
			last_updated_by,
			last_update_login,
			creation_date,
			created_by,
			customer_id,
			address_id,
			site_use_id,
			organization_id,
                        org_id
			) values (
			p_inventory_location_id,
			sysdate,
        	      	fnd_global.user_id,
			fnd_global.Login_id,
              		sysdate,
              		fnd_global.user_id,
			p_customer_id,
			p_address_id,
			p_site_use_id,
			p_inventory_organization_id,
                        l_org_id
			);
	--
end insert_po_loc_associations;
--
--

procedure insert_po_loc_associations (  p_inventory_location_id         in number,
                                        p_inventory_organization_id     in number,
                                        p_customer_id                   in number,
                                        p_address_id                    in number,
                                        p_site_use_id                   in number
                                        ) is
--
begin
         --
         check_unique_inv_location( p_inventory_location_id => p_inventory_location_id );
         --
         insert into po_location_associations (
                        location_id,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        creation_date,
                        created_by,
                        customer_id,
                        address_id,
                        site_use_id,
                        organization_id,
                        org_id
                        ) values (
                        p_inventory_location_id,
                        sysdate,
                        fnd_global.user_id,
                        fnd_global.Login_id,
                        sysdate,
                        fnd_global.user_id,
                        p_customer_id,
                        p_address_id,
                        p_site_use_id,
                        p_inventory_organization_id,
                        arp_standard.sysparm.org_id
                        );
        --
end insert_po_loc_associations;
--


procedure update_po_loc_associations ( 	p_site_use_id 			in number,
					p_address_id  			in number,
					p_customer_id 			in number,
					p_inventory_organization_id 	in number,
					p_inventory_location_id 	in number,
                                        x_return_status                 out nocopy varchar2,
                                        x_msg_count                     out nocopy number,
                                        x_msg_data                      out nocopy varchar2
                                     ) is
--
l_dummy number;
l_inventory_location_id number;
l_inventory_organization_id number;
--
begin
	--
	--
/* Bug3246371 : Added variable l_inventory_organization_id
                and modified the select condition to get organization_id
                Modified the 'if' condition to check whether
                organization_id is same*/
	begin
		select 	location_id,organization_id
		into	l_inventory_location_id,l_inventory_organization_id
		from 	po_location_associations
		where   site_use_id	= p_site_use_id;
	exception
		when NO_DATA_FOUND then
			null;
	end;
	-- next 2 commented lines are fix for 5741810
	-- if ( l_inventory_location_id = p_inventory_location_id  ) and
        --    ( l_inventory_organization_id = p_inventory_organization_id) then
        IF     (l_inventory_location_id IS NOT NULL OR l_inventory_organization_id IS NOT NULL)
               AND (NVL(l_inventory_location_id,-9999) = NVL(p_inventory_location_id,-9999) AND
               NVL(l_inventory_organization_id,-9999) = NVL(p_inventory_organization_id,-9999))
        THEN

		return;
	else
		--
		SELECT 	count(1)
		INTO	l_dummy
		FROM   	po_requisition_lines porl
		WHERE  	porl.deliver_to_location_id = l_inventory_location_id
 		AND  	nvl(porl.source_type_code, 'VENDOR') = 'INVENTORY';
		--
		if ( l_dummy >= 1 ) then
			fnd_message.set_name('AR','AR_CUST_INT_REQ_LINES_EXIST');
                         FND_MSG_PUB.ADD;
			--app_exception.raise_exception;
                        x_return_status :=  FND_API.G_RET_STS_ERROR;
                        x_msg_count := 1;
                        x_msg_data := 'AR_CUST_INT_REQ_LINES_EXIST';
                        return;
		end if;
		--
		delete from po_location_associations
		where  site_use_id = p_site_use_id;
		--
	end if;
	--
	if ( p_inventory_location_id is not null ) then
		--
		insert_po_loc_associations( 	p_inventory_location_id		=> p_inventory_location_id,
						p_inventory_organization_id	=> p_inventory_organization_id,
						p_customer_id 			=> p_customer_id,
						p_address_id			=> p_address_id,
						p_site_use_id			=> p_site_use_id,
                                                x_return_status                 => x_return_status,
                                                x_msg_count                     => x_msg_count,
                                                x_msg_data                      => x_msg_data
						);
        	--
	end if;
	--

end update_po_loc_associations;
--
--

procedure update_po_loc_associations (  p_site_use_id                   in number,
                                        p_address_id                    in number,
                                        p_customer_id                   in number,
                                        p_inventory_organization_id     in number,
                                        p_inventory_location_id         in number ) is
--
l_dummy number;
l_inventory_location_id number;
l_inventory_organization_id number;
--
begin
        --
        --
/* Bug3246371 : Added variable l_inventory_organization_id
                and modified the select condition to get organization_id
                Modified the 'if' condition to check whether
                organization_id is same*/
        begin
                select  location_id,organization_id
                into    l_inventory_location_id,l_inventory_organization_id
                from    po_location_associations
                where   site_use_id     = p_site_use_id;
        exception
                when NO_DATA_FOUND then
                        null;
        end;
        --
        if ( l_inventory_location_id = p_inventory_location_id  ) and
           ( l_inventory_organization_id = p_inventory_organization_id) then
                return;
        else
                --
                SELECT  count(1)
                INTO    l_dummy
                FROM    po_requisition_lines porl
                WHERE   porl.deliver_to_location_id = l_inventory_location_id
                AND     nvl(porl.source_type_code, 'VENDOR') = 'INVENTORY';
                --
                if ( l_dummy >= 1 ) then
                        fnd_message.set_name('AR','AR_CUST_INT_REQ_LINES_EXIST');
                        app_exception.raise_exception;
                end if;
                --
                delete from po_location_associations
                where  site_use_id = p_site_use_id;
                --
        end if;
        --
 --
        if ( p_inventory_location_id is not null ) then
                --
                insert_po_loc_associations(     p_inventory_location_id         => p_inventory_location_id,
                                                p_inventory_organization_id     => p_inventory_organization_id,
                                                p_customer_id                   => p_customer_id,
                                                p_address_id                    => p_address_id,
                                                p_site_use_id                   => p_site_use_id
                                                );
                --
        end if;
        --

end update_po_loc_associations;
--
--


--
END arp_clas_pkg;

/
