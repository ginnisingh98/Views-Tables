--------------------------------------------------------
--  DDL for Package Body IEX_DUNNING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DUNNING_PVT" AS
/* $Header: iexvdunb.pls 120.34.12010000.33 2010/05/27 12:11:53 gnramasa ship $ */


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_DUNNING_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvdunb.pls';

PG_DEBUG NUMBER ;
--Start adding for bug 9503251 gnramasa 2nd Apr 2010
FUNCTION staged_dunn_amt_due_remaining(p_dunning_id number) RETURN NUMBER;
--End adding for bug 9503251 gnramasa 2nd Apr 2010

Procedure WriteLog      (  p_msg                     IN VARCHAR2           ,
                           p_flag                    IN NUMBER DEFAULT NULL)
IS
BEGIN

     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.LogMessage (p_msg);
     END IF;

END WriteLog;


/*
    Returns location_id from hz_locations for specified site_use_id
*/
FUNCTION GET_DUNNING_LOCATION(P_SITE_USE_ID NUMBER) RETURN NUMBER
IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name          CONSTANT VARCHAR2(30) := 'GET_DUNNING_LOCATION';
    l_return            NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
    cursor get_data_crs(P_SITE_USE_ID number) is
        select par_site.location_id
        from
            HZ_CUST_SITE_USES_ALL site_use,
            HZ_CUST_ACCT_SITES_ALL acct_site,
            hz_party_sites par_site
        where
            site_use.site_use_id = P_SITE_USE_ID and
            acct_site.cust_acct_site_id = site_use.cust_acct_site_id and
            par_site.party_site_id = acct_site.party_site_id;

BEGIN

    l_return := null;

    WriteLog(l_api_name || ' input parameters:');
    WriteLog('P_SITE_USE_ID: ' || P_SITE_USE_ID);

    if P_SITE_USE_ID is null then
        WriteLog('Not all input parameters have value');
        return l_return;
    end if;

    OPEN get_data_crs(P_SITE_USE_ID);
    FETCH get_data_crs INTO l_return;
    CLOSE get_data_crs;

    WriteLog(l_api_name || ' returns ' || l_return);
    return l_return;

EXCEPTION
    WHEN OTHERS THEN
        WriteLog (l_api_name || ': In exception');
        return l_return;
END;



/*
    Returns CUSTOMER location_id, contact party_id and contact_pont_id for specified party_id and contact_point_type the OLD WAY
*/
Procedure GET_CUST_DUNNING_DATA_OW(p_api_version             IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2 ,
                                p_commit                  IN VARCHAR2 ,
                                P_PARTY_ID                IN NUMBER,
                                P_CONTACT_POINT_TYPE      IN VARCHAR2,
                                X_LOCATION_ID             OUT NOCOPY NUMBER,
                                X_CONTACT_ID              OUT NOCOPY NUMBER,
                                X_CONTACT_POINT_ID        OUT NOCOPY NUMBER,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2)
IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name                  CONSTANT VARCHAR2(30) := 'GET_CUST_DUNNING_DATA_OW';
    l_primary_flag              VARCHAR2(1);
    l_purpose_flag              varchar2(1);
    l_rel_party_id              NUMBER;
    l_contact_id                NUMBER;
    l_contact_point_id          NUMBER;
    l_location_id               NUMBER;
    l_order                     NUMBER;
    l_rel_type                  VARCHAR2(30);
    l_def_rel_type              VARCHAR2(30);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- get contact_id and contact_point_id
    cursor get_old_contact_crs(P_REL_TYPE varchar2, P_PARTY_ID number, P_CONTACT_POINT_TYPE varchar2) is
        select
            decode(P_REL_TYPE, rel.relationship_type,
                    decode(point.contact_point_purpose,
                      'DUNNING', decode(point.primary_by_purpose, 'Y', 1, decode(point.primary_flag, 'Y', 2, 3
                                                                          )
                                 ), 4
                    ),
                    decode(point.contact_point_purpose,
                      'DUNNING', decode(point.primary_by_purpose, 'Y', 5, decode(point.primary_flag, 'Y', 6, 7
                                                                          )
                                 ), 8
                    )
            ) Display_Order,
            rel.party_id,
            rel.subject_id,
            point.contact_point_id,
            rel.relationship_type
        from HZ_RELATIONSHIPS rel,
            hz_contact_points point
        where rel.object_id = P_PARTY_ID and
            rel.relationship_type in ('DUNNING', 'COLLECTIONS') and
            rel.status = 'A' and
            rel.party_id = point.owner_table_ID and
            point.owner_table_name = 'HZ_PARTIES' and
            upper(point.contact_point_type) = decode(P_CONTACT_POINT_TYPE, 'EMAIL', 'EMAIL', 'PHONE', 'PHONE', 'FAX', 'PHONE') and
            nvl(point.phone_line_type, 'EMAIL') = decode(P_CONTACT_POINT_TYPE, 'EMAIL', 'EMAIL', 'PHONE', 'GEN', 'FAX', 'FAX') and
            NVL(point.do_not_use_flag, 'N') = 'N' and
            (point.status = 'A' OR point.status <> 'I')
        order by Display_Order;

    -- get contact_id
    cursor get_old_contact_crs1(P_REL_TYPE varchar2, P_PARTY_ID number) is
        select
            decode(P_REL_TYPE, rel.relationship_type, 1, 2) Display_Order,
            rel.party_id,
            rel.subject_id,
            rel.relationship_type
        from HZ_RELATIONSHIPS rel
        where rel.object_id = P_PARTY_ID and
            rel.relationship_type in ('DUNNING', 'COLLECTIONS') and
            rel.status = 'A'
        order by Display_Order;

    -- get relationship location_id
    cursor get_old_loc_crs(P_REL_PARTY_ID number) is
        select location_id
        from hz_party_sites
        where party_id = P_REL_PARTY_ID and
            status in ('A', 'I');

    --start for bug 6500750 gnramasa 13-Nov-07
    cursor get_site_loc(P_CONTACT_ID number) is
        select location_id
    --Start for bug 8771065 gnramasa 6th-Aug-09
    --    from ast_locations_v where party_site_id =
        from ast_locations_v where party_site_id in
        	(select party_site_id
    --		from hz_cust_acct_sites_all where cust_acct_site_id =
		from hz_cust_acct_sites_all where cust_acct_site_id in
                      (select address_id
                       from ar_contacts_v where contact_party_id = P_CONTACT_ID
		       AND address_id is not null
		       AND status = 'A'));
     --End for bug 8771065 gnramasa 6th-Aug-09
     --End for bug 6500750 gnramasa 13-Nov-07

    -- get organization location_id
    cursor get_old_loc_crs1(P_ORG_PARTY_ID number) is
        select location_id
        from ast_locations_v
        where party_id = P_ORG_PARTY_ID and
            primary_flag = 'Y';

BEGIN

    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    WriteLog('----------' || l_api_name || '----------');
    WriteLog(l_api_name || ': input parameters:');
    WriteLog(l_api_name || ': P_PARTY_ID: ' || P_PARTY_ID);
    WriteLog(l_api_name || ': P_CONTACT_POINT_TYPE: ' || P_CONTACT_POINT_TYPE);

    X_LOCATION_ID := null;
    X_CONTACT_ID := null;
    X_CONTACT_POINT_ID := null;

    -- verify input parameters and if they are not set return immediately
    if P_PARTY_ID is null or P_CONTACT_POINT_TYPE is null then
        WriteLog(l_api_name || ': Not all input parameters have value');
        return;
    end if;

    WriteLog(l_api_name || ': Searching location_id, contact_id and contact_point_id the old way...');

    l_def_rel_type := nvl(fnd_profile.value('IEX_DEF_CORRESP_REL_TYPE'), 'DUNNING');
    WriteLog(l_api_name || ': IEX_DEF_CORRESP_REL_TYPE profile value: ' || l_def_rel_type);

    if P_CONTACT_POINT_TYPE = 'PRINTER' then

        WriteLog(l_api_name || ': For printer searching for contact only...');

        -- try to get contact_id the old way
        OPEN get_old_contact_crs1(l_def_rel_type, P_PARTY_ID);
        fetch get_old_contact_crs1 into l_order,
                                l_rel_party_id,
                                l_contact_id,
                                l_rel_type;
        CLOSE get_old_contact_crs1;

        if l_rel_party_id is not null then
            WriteLog(l_api_name || ': Found ' || l_rel_type || ' contact:');
            WriteLog(l_api_name || ': l_rel_party_id: ' || l_rel_party_id);
            WriteLog(l_api_name || ': l_contact_id: ' || l_contact_id);
        else
            WriteLog(l_api_name || ': No contact found');
        end if;

    ELSE

        -- try to get contact_id and contact_point_id the old way
        OPEN get_old_contact_crs(l_def_rel_type, P_PARTY_ID, P_CONTACT_POINT_TYPE);
        fetch get_old_contact_crs into l_order,
                                l_rel_party_id,
                                l_contact_id,
                                l_contact_point_id,
                                l_rel_type;
        CLOSE get_old_contact_crs;

        if l_rel_party_id is not null then
          WriteLog(l_api_name || ': Found ' || l_rel_type || ' contact with ' || P_CONTACT_POINT_TYPE || ' contact point:');
          WriteLog(l_api_name || ': l_rel_party_id: ' || l_rel_party_id);
          WriteLog(l_api_name || ': l_contact_id: ' || l_contact_id);
          WriteLog(l_api_name || ': l_contact_point_id: ' || l_contact_point_id);
        else
            WriteLog(l_api_name || ': No contact and contact point found');
        end if;

    END IF;

    if l_rel_party_id is not null then

        WriteLog(l_api_name || ': Searching for relationship location...');

        -- get relationship location_id
        OPEN get_old_loc_crs(l_rel_party_id);
        fetch get_old_loc_crs into l_location_id;
        CLOSE get_old_loc_crs;

        if l_location_id is not null then
            WriteLog(l_api_name || ': Found relationship location: ' || l_location_id);
        else
            WriteLog(l_api_name || ': No relationship location found');

	    --start for bug 6500750 gnramasa 13-Nov-07
	    OPEN get_site_loc(l_contact_id);
            fetch get_site_loc into l_location_id;
            CLOSE get_site_loc;
		if l_location_id is not null then
                    WriteLog(l_api_name || ': Found contact site location: ' || l_location_id);
		else
                    WriteLog(l_api_name || ': No contact site location found');
	    --End for bug 6500750 gnramasa 13-Nov-07

		    WriteLog(l_api_name || ': Searching for organization location...');

		    -- get relationship location_id
		    OPEN get_old_loc_crs1(P_PARTY_ID);
		    fetch get_old_loc_crs1 into l_location_id;
		    CLOSE get_old_loc_crs1;

		    if l_location_id is not null then
			WriteLog(l_api_name || ': Found organization location: ' || l_location_id);
		    else
			WriteLog(l_api_name || ': No organization location found');
		    end if;
		end if;

        end if;

    end if;

    X_LOCATION_ID := l_location_id;
    X_CONTACT_ID := l_contact_id;
    X_CONTACT_POINT_ID := l_contact_point_id;

    WriteLog(l_api_name || ': X_LOCATION_ID = ' || X_LOCATION_ID);
    WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
    WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception error='||SQLERRM);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception error='||SQLERRM);

  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception error='||SQLERRM);
END;

/*
    Returns ACCOUNT SITE location, contact party_id and contact_pont_id based on specified site_use_id and contact_point_type
*/
Procedure GET_SITE_DUNNING_DATA(p_api_version             IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2 ,
                                p_commit                  IN VARCHAR2 ,
                                P_SITE_USE_ID             IN NUMBER,
                                P_CONTACT_POINT_TYPE      IN VARCHAR2,
                                X_LOCATION_ID             OUT NOCOPY NUMBER,
                                X_CONTACT_ID              OUT NOCOPY NUMBER,
                                X_CONTACT_POINT_ID        OUT NOCOPY NUMBER,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2)
IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name              CONSTANT VARCHAR2(30) := 'GET_SITE_DUNNING_DATA';
    l_order                 NUMBER;
    l_per_party_id          NUMBER;
    l_rel_party_id          NUMBER;
    l_contact_point_id      NUMBER;
    l_count                 NUMBER;
    l_responsibility_type   VARCHAR2(30);
    l_dun_contact_level  VARCHAR2(30); --Added for bug 6500750 gnramasa 13-Nov-07

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- get contacts for a cust account site order by responsibility type
    cursor get_data_crs(P_SITE_USE_ID number) is
        select
            decode(role_resp.responsibility_type,
                'DUN', decode(role_resp.primary_flag, 'Y', 1, 2),
                'BILL_TO', decode(role_resp.primary_flag, 'Y', 3, 4),
                'INV', decode(role_resp.primary_flag, 'Y', 5, 6),
                'SHIP_TO', decode(role_resp.primary_flag, 'Y', 7, 8), 9
            ) Display_Order,
            role_resp.responsibility_type,
            party.party_id,
            sub_party.party_id
        from
            HZ_CUST_SITE_USES_ALL site_use,
            HZ_CUST_ACCOUNT_ROLES acct_role,
            HZ_ROLE_RESPONSIBILITY role_resp,
            HZ_RELATIONSHIPS rel,
            hz_parties party,
            hz_parties sub_party
        where
            site_use.site_use_id = P_SITE_USE_ID and
            acct_role.cust_acct_site_id = site_use.cust_acct_site_id and
            acct_role.status = 'A' and
            role_resp.cust_account_role_id = acct_role.cust_account_role_id and
            acct_role.party_id = party.party_id and
            party.status = 'A' and
            rel.party_id = party.party_id and
            rel.subject_type = 'PERSON' and
            rel.status = 'A' and
            decode(rel.object_type, 'PERSON', rel.directional_flag, 1) = decode(rel.object_type, 'PERSON', 'F', 1) and
            sub_party.party_id = rel.subject_id and
            sub_party.status = 'A'
        order by Display_Order, sub_party.party_name;

    -- get CONTACT_POINT_ID for specified CONTACT_POINT_TYPE and party_id
    cursor get_data_crs1(P_PARTY_ID number, P_CONTACT_POINT_TYPE varchar2) is
        select
            decode(cont_point.contact_point_purpose,
                'DUNNING', decode(cont_point.primary_flag, 'Y', 1, decode(cont_point.primary_by_purpose, 'Y', 2, 3)),
                'COLLECTIONS', decode(cont_point.primary_flag, 'Y', 4, decode(cont_point.primary_by_purpose, 'Y', 5, 6)),
                'BUSINESS', decode(cont_point.primary_flag, 'Y', 7, decode(cont_point.primary_by_purpose, 'Y', 8, 9)),
                null, decode(cont_point.primary_flag, 'Y', 10, decode(cont_point.primary_by_purpose, 'Y', 11, 12))
            ) Display_Order
            ,cont_point.CONTACT_POINT_ID
        from hz_contact_points cont_point
        where
            cont_point.owner_table_id = P_PARTY_ID and
            cont_point.owner_table_name = 'HZ_PARTIES' and
            cont_point.contact_point_type = decode(P_CONTACT_POINT_TYPE, 'EMAIL', 'EMAIL', 'PHONE', 'PHONE', 'FAX', 'PHONE') and
            nvl(cont_point.phone_line_type, 'EMAIL') = decode(P_CONTACT_POINT_TYPE, 'EMAIL', 'EMAIL', 'PHONE', 'GEN', 'FAX', 'FAX') and
            NVL(cont_point.do_not_use_flag, 'N') = 'N' and
            (cont_point.status = 'A' OR cont_point.status <> 'I')
        order by Display_Order;

    -- get CONTACT_POINT_ID for specified CONTACT_POINT_TYPE and party_site_id
    cursor get_data_crs2(P_SITE_USE_ID number, P_CONTACT_POINT_TYPE varchar2) is
        select
            decode(cont_point.contact_point_purpose,
                'DUNNING', decode(cont_point.primary_flag, 'Y', 1, decode(cont_point.primary_by_purpose, 'Y', 2, 3)),
                'COLLECTIONS', decode(cont_point.primary_flag, 'Y', 4, decode(cont_point.primary_by_purpose, 'Y', 5, 6)),
                'BUSINESS', decode(cont_point.primary_flag, 'Y', 7, decode(cont_point.primary_by_purpose, 'Y', 8, 9)),
                null, decode(cont_point.primary_flag, 'Y', 10, decode(cont_point.primary_by_purpose, 'Y', 11, 12))
            ) Display_Order
            ,cont_point.CONTACT_POINT_ID
        from
            HZ_CUST_SITE_USES_ALL site_use,
            HZ_CUST_ACCT_SITES_ALL acct_site,
            hz_contact_points cont_point
        where
            site_use.site_use_id = P_SITE_USE_ID and
            acct_site.cust_acct_site_id = site_use.cust_acct_site_id and
            cont_point.owner_table_id = acct_site.party_site_id and
            cont_point.owner_table_name = 'HZ_PARTY_SITES' and
            cont_point.contact_point_type = decode(P_CONTACT_POINT_TYPE, 'EMAIL', 'EMAIL', 'PHONE', 'PHONE', 'FAX', 'PHONE') and
            nvl(cont_point.phone_line_type, 'EMAIL') = decode(P_CONTACT_POINT_TYPE, 'EMAIL', 'EMAIL', 'PHONE', 'GEN', 'FAX', 'FAX') and
            NVL(cont_point.do_not_use_flag, 'N') = 'N' and
            (cont_point.status = 'A' OR cont_point.status <> 'I')
        order by Display_Order;

    -- get LOCATION_ID for specified site_use_id
    cursor get_data_crs3(P_SITE_USE_ID number) is
        select par_site.location_id
        from
            HZ_CUST_SITE_USES_ALL site_use,
            HZ_CUST_ACCT_SITES_ALL acct_site,
            hz_party_sites par_site
        where
            site_use.site_use_id = P_SITE_USE_ID and
            acct_site.cust_acct_site_id = site_use.cust_acct_site_id and
            par_site.party_site_id = acct_site.party_site_id;

BEGIN

    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_dun_contact_level := nvl(fnd_profile.value('IEX_DUNNING_CONTACT_SELECTION_METHOD'), 'ALL');  --Added for bug 6500750 gnramasa 13-Nov-07

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    WriteLog('----------' || l_api_name || '----------');
    WriteLog(l_api_name || ': input parameters:');
    WriteLog(l_api_name || ': P_SITE_USE_ID: ' || P_SITE_USE_ID);
    WriteLog(l_api_name || ': P_CONTACT_POINT_TYPE: ' || P_CONTACT_POINT_TYPE);

    X_LOCATION_ID := null;
    X_CONTACT_ID := null;
    X_CONTACT_POINT_ID := null;

    -- verify input parameters and if they are not set return immediately
    if P_SITE_USE_ID is null or P_CONTACT_POINT_TYPE is null then
        WriteLog(l_api_name || ': Not all input parameters have value');
        return;
    end if;

    WriteLog(l_api_name || ': Searching for ACCOUNT SITE location...');
    OPEN get_data_crs3(P_SITE_USE_ID);
    FETCH get_data_crs3 INTO X_LOCATION_ID;
    CLOSE get_data_crs3;
    WriteLog(l_api_name || ': X_LOCATION_ID = ' || X_LOCATION_ID);

    WriteLog(l_api_name || ': Searching for ACCOUNT SITE level contacts with ' || P_CONTACT_POINT_TYPE || ' contact point...');

    l_count := 0;
    OPEN get_data_crs(P_SITE_USE_ID);
    LOOP

        l_contact_point_id := null;
        fetch get_data_crs into
            l_order,
            l_responsibility_type,
            l_rel_party_id,
            l_per_party_id;
        exit when get_data_crs%NOTFOUND;

	-- Start for bug 6500750 gnramasa 13-Nov-07
	if l_dun_contact_level = 'ALL' or l_dun_contact_level is null then
		WriteLog(l_api_name || ': l_dun_contact_level : ' || l_dun_contact_level);

		l_count := l_count + 1;
		WriteLog(l_api_name || ': Found #' || l_count || ' contact = ' || l_per_party_id);
		WriteLog(l_api_name || ': l_rel_party_id = ' || l_rel_party_id);
		WriteLog(l_api_name || ': l_responsibility_type = ' || l_responsibility_type);

		if P_CONTACT_POINT_TYPE = 'PRINTER' then

		    WriteLog(l_api_name || ': For contact point PRINTER return first found contact');
		    X_CONTACT_ID := l_per_party_id;
		    X_CONTACT_POINT_ID := null;
		    WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
		    WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);
		    return;

		else

		    OPEN get_data_crs1(l_rel_party_id, P_CONTACT_POINT_TYPE);
		    FETCH get_data_crs1 INTO l_order, l_contact_point_id;
		    CLOSE get_data_crs1;

		    if l_contact_point_id is not null then

			WriteLog(l_api_name || ': Found contact_point_id = ' || l_contact_point_id);
			X_CONTACT_ID := l_per_party_id;
			X_CONTACT_POINT_ID := l_contact_point_id;
			WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
			WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);
			return;

		    else

			WriteLog(l_api_name || ': No contact points found for this contact');

		    end if;

		end if;
	elsif l_dun_contact_level ='DUNNING' then
	   WriteLog(l_api_name || ': l_dun_contact_level : ' || l_dun_contact_level);
	   if l_order in (1,2) then
		WriteLog(l_api_name || ': l_order : ' || l_order);
		l_count := l_count + 1;
		WriteLog(l_api_name || ': Found #' || l_count || ' contact = ' || l_per_party_id);
		WriteLog(l_api_name || ': l_rel_party_id = ' || l_rel_party_id);
		WriteLog(l_api_name || ': l_responsibility_type = ' || l_responsibility_type);

		if P_CONTACT_POINT_TYPE = 'PRINTER' then

		    WriteLog(l_api_name || ': For contact point PRINTER return first found contact');
		    X_CONTACT_ID := l_per_party_id;
		    X_CONTACT_POINT_ID := null;
		    WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
		    WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);
		    return;

		else

		    OPEN get_data_crs1(l_rel_party_id, P_CONTACT_POINT_TYPE);
		    FETCH get_data_crs1 INTO l_order, l_contact_point_id;
		    CLOSE get_data_crs1;

		    if l_contact_point_id is not null then

			WriteLog(l_api_name || ': Found contact_point_id = ' || l_contact_point_id);
			X_CONTACT_ID := l_per_party_id;
			X_CONTACT_POINT_ID := l_contact_point_id;
			WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
			WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);
			return;

		    else

			WriteLog(l_api_name || ': No contact points found for this contact');

		    end if;

		end if;
	    end if;  -- l_order
	end if;  -- l_dun_contact_level
        -- End for bug 6500750 gnramasa 13-Nov-07

    END LOOP;
    CLOSE get_data_crs;

    if l_count = 0 then
        WriteLog(l_api_name || ': No ACCOUNT SITE level contacts found');
    end if;

    -- if no ACCOUNT SITE contacts with contact point found - search for ACCOUNT SITE level contact points
    if X_CONTACT_ID is null and X_CONTACT_POINT_ID is null then

        WriteLog(l_api_name || ': Searching for ACCOUNT SITE level ' || P_CONTACT_POINT_TYPE || ' contact point...');
        OPEN get_data_crs2(P_SITE_USE_ID, P_CONTACT_POINT_TYPE);
        FETCH get_data_crs2 INTO l_order, l_contact_point_id;
        CLOSE get_data_crs2;

        if l_contact_point_id is not null then

            WriteLog(l_api_name || ': Found contact_point_id = ' || l_contact_point_id);
            X_CONTACT_ID := null;
            X_CONTACT_POINT_ID := l_contact_point_id;
            WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
            WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);
            return;

        else

            WriteLog(l_api_name || ': No contact points found');

        end if;

    end if;

    WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
    WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);

    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception error='||SQLERRM);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception error='||SQLERRM);

  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception error='||SQLERRM);
END;



/*
    Returns ACCOUNT location, contact party_id and contact_pont_id for specified cust_account_id and contact_point_type
*/
Procedure GET_ACCT_DUNNING_DATA(p_api_version             IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2 ,
                                p_commit                  IN VARCHAR2 ,
                                P_CUST_ACCT_ID            IN NUMBER,
                                P_CONTACT_POINT_TYPE      IN VARCHAR2,
                                X_LOCATION_ID             OUT NOCOPY NUMBER,
                                X_CONTACT_ID              OUT NOCOPY NUMBER,
                                X_CONTACT_POINT_ID        OUT NOCOPY NUMBER,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2)
IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name              CONSTANT VARCHAR2(30) := 'GET_ACCT_DUNNING_DATA';
    l_order                 NUMBER;
    l_per_party_id          NUMBER;
    l_rel_party_id          NUMBER;
    l_contact_point_id      NUMBER;
    l_count                 NUMBER;
    l_responsibility_type   VARCHAR2(30);
    l_org_party_id          NUMBER;
    l_bill_to_count         NUMBER;
    l_display_order         NUMBER;
    l_site_use_code         VARCHAR2(30);
    l_location_id           NUMBER;
    l_dun_contact_level     VARCHAR2(30); --Added for bug 6500750 gnramasa 13-Nov-07

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- get contacts for a cust account order by responsibility type
    cursor get_data_crs(P_CUST_ACCOUNT_ID number) is
        select
            decode(role_resp.responsibility_type,
                'DUN', decode(role_resp.primary_flag, 'Y', 1, 2),
                'BILL_TO', decode(role_resp.primary_flag, 'Y', 3, 4),
                'INV', decode(role_resp.primary_flag, 'Y', 5, 6),
                'SHIP_TO', decode(role_resp.primary_flag, 'Y', 7, 8), 9
            ) Display_Order,
            role_resp.responsibility_type,
            party.party_id,
            sub_party.party_id,
            rel.object_id
        from
            HZ_CUST_ACCOUNT_ROLES acct_role,
            HZ_ROLE_RESPONSIBILITY role_resp,
            HZ_RELATIONSHIPS rel,
            hz_parties party,
            hz_parties sub_party
        where
            acct_role.cust_account_id = P_CUST_ACCOUNT_ID and
            acct_role.cust_acct_site_id is null and
            acct_role.status = 'A' and
            acct_role.cust_account_role_id = role_resp.cust_account_role_id and
            acct_role.party_id = party.party_id and
            party.status = 'A' and
            rel.party_id = party.party_id and
            rel.subject_type = 'PERSON' and
            rel.status = 'A' and
            decode(rel.object_type, 'PERSON', rel.directional_flag, 1) = decode(rel.object_type, 'PERSON', 'F', 1) and
            sub_party.party_id = rel.subject_id and
            sub_party.status = 'A'
        order by Display_Order, sub_party.party_name;

    -- get CONTACT_POINT_ID for specified CONTACT_POINT_TYPE and party_id
    cursor get_data_crs1(P_PARTY_ID number, P_CONTACT_POINT_TYPE varchar2) is
        select
            decode(cont_point.contact_point_purpose,
                'DUNNING', decode(cont_point.primary_flag, 'Y', 1, decode(cont_point.primary_by_purpose, 'Y', 2, 3)),
                'COLLECTIONS', decode(cont_point.primary_flag, 'Y', 4, decode(cont_point.primary_by_purpose, 'Y', 5, 6)),
                'BUSINESS', decode(cont_point.primary_flag, 'Y', 7, decode(cont_point.primary_by_purpose, 'Y', 8, 9)),
                null, decode(cont_point.primary_flag, 'Y', 10, decode(cont_point.primary_by_purpose, 'Y', 11, 12))
            ) Display_Order
            ,cont_point.CONTACT_POINT_ID
        from hz_contact_points cont_point
        where
            cont_point.owner_table_id = P_PARTY_ID and
            cont_point.owner_table_name = 'HZ_PARTIES' and
            cont_point.contact_point_type = decode(P_CONTACT_POINT_TYPE, 'EMAIL', 'EMAIL', 'PHONE', 'PHONE', 'FAX', 'PHONE') and
            nvl(cont_point.phone_line_type, 'EMAIL') = decode(P_CONTACT_POINT_TYPE, 'EMAIL', 'EMAIL', 'PHONE', 'GEN', 'FAX', 'FAX') and
            NVL(cont_point.do_not_use_flag, 'N') = 'N' and
            (cont_point.status = 'A' OR cont_point.status <> 'I')
        order by Display_Order;

    -- get party_id from cust_account_id
    cursor get_party_crs(P_CUST_ACCOUNT_ID number) is
        select party_id from hz_cust_accounts where cust_account_id = P_CUST_ACCOUNT_ID;

    -- get LOCATION_ID for specified cust_account_id
    cursor get_data_crs2(P_CUST_ACCOUNT_ID number) is
        select
            decode(site_use.site_use_code,
                'DUN', 1,
                'BILL_TO', decode(site_use.primary_flag, 'Y', 2, 3)) display_order,
            site_use.site_use_code,
            par_site.location_id
        from
            hz_party_sites par_site,
            HZ_CUST_ACCT_SITES_ALL acct_site,
            HZ_CUST_SITE_USES_ALL site_use
        where
            acct_site.cust_account_id = P_CUST_ACCOUNT_ID and
            acct_site.status = 'A' and
            acct_site.cust_acct_site_id = site_use.cust_acct_site_id and
            site_use.status = 'A' and
            par_site.party_site_id = acct_site.party_site_id and
            par_site.status in ('A', 'I')
        order by display_order;

    -- get count on not primary bill-to locations
    cursor get_data_crs3(P_CUST_ACCOUNT_ID number) is
        select count(1)
        from
            hz_party_sites par_site,
            HZ_CUST_ACCT_SITES_ALL acct_site,
            HZ_CUST_SITE_USES_ALL site_use
        where
            acct_site.cust_account_id = P_CUST_ACCOUNT_ID and
            acct_site.status = 'A' and
            acct_site.cust_acct_site_id = site_use.cust_acct_site_id and
            site_use.status = 'A' and
            par_site.party_site_id = acct_site.party_site_id and
            par_site.status in ('A', 'I') and
            site_use.site_use_code = 'BILL_TO' and
            site_use.primary_flag <> 'Y';

    -- Start for bug 6500750 gnramasa 13-Nov-07

     cursor get_old_loc_crs1(P_ORG_PARTY_ID number) is
        select location_id
        from ast_locations_v
        where party_id = P_ORG_PARTY_ID and
            primary_flag = 'Y';

    -- End for bug 6500750 gnramasa 13-Nov-07

BEGIN

    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_dun_contact_level := nvl(fnd_profile.value('IEX_DUNNING_CONTACT_SELECTION_METHOD'), 'ALL');  --Added for bug 6500750 gnramasa 13-Nov-07

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    WriteLog('----------' || l_api_name || '----------');
    WriteLog(l_api_name || ': input parameters:');
    WriteLog(l_api_name || ': P_CUST_ACCT_ID: ' || P_CUST_ACCT_ID);
    WriteLog(l_api_name || ': P_CONTACT_POINT_TYPE: ' || P_CONTACT_POINT_TYPE);

    X_LOCATION_ID := null;
    X_CONTACT_ID := null;
    X_CONTACT_POINT_ID := null;

    -- verify input parameters and if they are not set return immediately
    if P_CUST_ACCT_ID is null or P_CONTACT_POINT_TYPE is null then
        WriteLog(l_api_name || ': Not all input parameters have value');
        return;
    end if;

    -- Start for bug 6500750 gnramasa 13-Nov-07
    IF l_dun_contact_level = 'ALL' OR l_dun_contact_level IS NULL then

	    WriteLog(l_api_name || ': l_dun_contact_level : ' || l_dun_contact_level);
	    WriteLog(l_api_name || ': Searching for ACCOUNT location...');
	    OPEN get_data_crs2(P_CUST_ACCT_ID);
	    LOOP
		FETCH get_data_crs2 INTO l_display_order,
					 l_site_use_code,
					 l_location_id;
		exit when (get_data_crs2%NOTFOUND or l_display_order is null);

		WriteLog(l_api_name || ': Found location:');
		WriteLog(l_api_name || ': l_display_order: ' || l_display_order);
		WriteLog(l_api_name || ': l_site_use_code: ' || l_site_use_code);
		WriteLog(l_api_name || ': l_location_id: ' || l_location_id);

		if l_display_order = 1 or l_display_order = 2 then  -- dunning or primary bill-to

		    X_LOCATION_ID := l_location_id;
		    exit;

		elsif l_display_order = 3 then    -- regular bill-to

		    OPEN get_data_crs3(P_CUST_ACCT_ID);
		    FETCH get_data_crs3 INTO l_bill_to_count;
		    CLOSE get_data_crs3;

		    -- if more then 1 regular bill-to then set error
		    if l_bill_to_count > 1 then
			X_LOCATION_ID := null;
			WriteLog(l_api_name || ': ERROR: Multiple Bill-To locations found');
			FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_MULT_LOC');
			FND_MESSAGE.Set_Token('USAGE', 'bill-to', FALSE);
			FND_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_ERROR;
		    else
			X_LOCATION_ID := l_location_id;
		    end if;
		    exit;

		end if;

	    END LOOP;
	    CLOSE get_data_crs2;

	    WriteLog(l_api_name || ': X_LOCATION_ID = ' || X_LOCATION_ID);
        end if;

    WriteLog(l_api_name || ': Searching for ACCOUNT level contacts with ' || P_CONTACT_POINT_TYPE || ' contact point...');

    l_count := 0;
    OPEN get_data_crs(P_CUST_ACCT_ID);
    LOOP

        l_contact_point_id := null;
        fetch get_data_crs into
            l_order,
            l_responsibility_type,
            l_rel_party_id,
            l_per_party_id,
            l_org_party_id;
        exit when get_data_crs%NOTFOUND;

	IF l_dun_contact_level = 'ALL' OR l_dun_contact_level IS NULL then
	        WriteLog(l_api_name || ': l_dun_contact_level : ' || l_dun_contact_level);

		l_count := l_count + 1;
		WriteLog(l_api_name || ': Found #' || l_count || ' contact = ' || l_per_party_id);
		WriteLog(l_api_name || ': l_rel_party_id = ' || l_rel_party_id);
		WriteLog(l_api_name || ': l_responsibility_type = ' || l_responsibility_type);

		if P_CONTACT_POINT_TYPE = 'PRINTER' then

		    WriteLog(l_api_name || ': For contact point PRINTER return first found contact');
		    X_CONTACT_ID := l_per_party_id;
		    X_CONTACT_POINT_ID := null;
		    WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
		    WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);
		    return;

		else

		    OPEN get_data_crs1(l_rel_party_id, P_CONTACT_POINT_TYPE);
		    FETCH get_data_crs1 INTO l_order, l_contact_point_id;
		    CLOSE get_data_crs1;

		    if l_contact_point_id is not null then

			WriteLog(l_api_name || ': Found contact_point_id = ' || l_contact_point_id);
			X_CONTACT_ID := l_per_party_id;
			X_CONTACT_POINT_ID := l_contact_point_id;
			WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
			WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);
			return;

		    else

			WriteLog(l_api_name || ': No contact points found for this contact');

		    end if;

		end if;
	ELSIF l_dun_contact_level='DUNNING' then

	 WriteLog(l_api_name || ': l_dun_contact_level : ' || l_dun_contact_level);
	 if l_order in (1,2) then

		l_count := l_count + 1;
		WriteLog(l_api_name || ': Found #' || l_count || ' contact = ' || l_per_party_id);
		WriteLog(l_api_name || ': l_rel_party_id = ' || l_rel_party_id);
		WriteLog(l_api_name || ': l_responsibility_type = ' || l_responsibility_type);

		if P_CONTACT_POINT_TYPE = 'PRINTER' then

		    WriteLog(l_api_name || ': For contact point PRINTER return first found contact');
		    X_CONTACT_ID := l_per_party_id;
		    X_CONTACT_POINT_ID := null;
		    WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
		    WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);
		    --return;
		    exit;

		else

		    OPEN get_data_crs1(l_rel_party_id, P_CONTACT_POINT_TYPE);
		    FETCH get_data_crs1 INTO l_order, l_contact_point_id;
		    CLOSE get_data_crs1;

		    if l_contact_point_id is not null then

			WriteLog(l_api_name || ': Found contact_point_id = ' || l_contact_point_id);
			X_CONTACT_ID := l_per_party_id;
			X_CONTACT_POINT_ID := l_contact_point_id;
			WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
			WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);
			--return;
			exit;

		    else

			WriteLog(l_api_name || ': No contact points found for this contact');

		    end if;

		end if;
	    end if;

	END IF; --l_dun_contact_level
    --End for bug 6500750 gnramasa 13-Nov-07

    END LOOP;
    CLOSE get_data_crs;

    if l_count = 0 then
        WriteLog(l_api_name || ': No ACCOUNT level contacts found');
    end if;

    -- if no ACCOUNT contacts with contact point found - search for ACCOUNT SITE level contact points
    if X_CONTACT_ID is null and X_CONTACT_POINT_ID is null then

        WriteLog(l_api_name || ': Searching for ACCOUNT level ' || P_CONTACT_POINT_TYPE || ' contact point...');

        OPEN get_party_crs(P_CUST_ACCT_ID);
        FETCH get_party_crs INTO l_org_party_id;
        CLOSE get_party_crs;

        WriteLog(l_api_name || ': l_org_party_id = ' || l_org_party_id);

        OPEN get_data_crs1(l_org_party_id, P_CONTACT_POINT_TYPE);
        FETCH get_data_crs1 INTO l_order, l_contact_point_id;
        CLOSE get_data_crs1;

        if l_contact_point_id is not null then

            WriteLog(l_api_name || ': Found contact_point_id = ' || l_contact_point_id);
            X_CONTACT_ID := null;
            X_CONTACT_POINT_ID := l_contact_point_id;
            WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
            WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);
            --return;

        else

            WriteLog(l_api_name || ': No contact points found');

        end if;

    end if;

        -- Start for bug 6500750 gnramasa 13-Nov-07
    if l_dun_contact_level = 'DUNNING' then
	WriteLog(l_api_name || ': l_dun_contact_level : ' || l_dun_contact_level);
	WriteLog(l_api_name || ': Searching for ACCOUNT location...');
	    OPEN get_data_crs2(P_CUST_ACCT_ID);
	    LOOP
		FETCH get_data_crs2 INTO l_display_order,
					         l_site_use_code,
					         l_location_id;
		exit when (get_data_crs2%NOTFOUND or l_display_order is null);

		WriteLog(l_api_name || ': Found location:');
		WriteLog(l_api_name || ': l_display_order: ' || l_display_order);
		WriteLog(l_api_name || ': l_site_use_code: ' || l_site_use_code);
		WriteLog(l_api_name || ': l_location_id: ' || l_location_id);

		if l_display_order = 1 then  -- dunning

		    X_LOCATION_ID := l_location_id;
		    exit;

		else  -- no dunning purpose address found, so send it to identifying address.
		    WriteLog(l_api_name || ' no dunning purpose address found, so send it to Identifying address');
		    -- get relationship location_id
		    OPEN get_party_crs(P_CUST_ACCT_ID);
		    FETCH get_party_crs INTO l_org_party_id;
		    CLOSE get_party_crs;

		    OPEN get_old_loc_crs1(l_org_party_id);
		    fetch get_old_loc_crs1 into l_location_id;
		    CLOSE get_old_loc_crs1;

		    if l_location_id is not null then
			WriteLog(l_api_name || ': Found organization location: ' || l_location_id);
		    else
			WriteLog(l_api_name || ': No organization location found');
		    end if;

		    X_LOCATION_ID := l_location_id;
		    exit;

	        end if;

          END LOOP;
    CLOSE get_data_crs2;

    WriteLog(l_api_name || ': X_LOCATION_ID = ' || X_LOCATION_ID);

    end if;
    --End for bug 6500750 gnramasa 13-Nov-07

    WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
    WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);

    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception error='||SQLERRM);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception error='||SQLERRM);

  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception error='||SQLERRM);
END;



/*
    Returns CUSTOMER location_id, contact party_id and contact_pont_id for specified cust_account_id and contact_point_type
*/
Procedure GET_CUST_DUNNING_DATA(p_api_version             IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2 ,
                                p_commit                  IN VARCHAR2 ,
                                P_PARTY_ID                IN NUMBER,
                                P_CONTACT_POINT_TYPE      IN VARCHAR2,
                                X_LOCATION_ID             OUT NOCOPY NUMBER,
                                X_CONTACT_ID              OUT NOCOPY NUMBER,
                                X_CONTACT_POINT_ID        OUT NOCOPY NUMBER,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2)
IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name                  CONSTANT VARCHAR2(30) := 'GET_CUST_DUNNING_DATA';
    l_cust_account_id           NUMBER;
    l_display_order             NUMBER;
    l_site_use_code             VARCHAR2(30);
    l_identifying_address_flag  VARCHAR2(1);
    l_primary_flag              VARCHAR2(1);
    l_count                     NUMBER;
    l_purpose_flag              varchar2(1);
    l_rel_party_id              NUMBER;
    l_contact_id                NUMBER;
    l_contact_point_id          NUMBER;
    l_location_id               NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- get cust_account_id for the party identifying address
    cursor get_data_crs(P_PARTY_ID number) is
        select
            decode(site_use.site_use_code,
                'DUN', decode(par_site.identifying_address_flag, 'Y', 1, 'N', 4),
                'BILL_TO', decode(par_site.identifying_address_flag,
                              'Y', decode(site_use.primary_flag, 'Y', 2, 3),
                              'N', decode(site_use.primary_flag, 'Y', 5, 6))) Display_Order ,
            acct_site.cust_account_id,
            site_use.site_use_code,
            par_site.identifying_address_flag,
            site_use.primary_flag
        from  HZ_CUST_SITE_USES_ALL site_use,
            HZ_CUST_ACCT_SITES_ALL acct_site,
            hz_party_sites par_site
        where  par_site.party_id = P_PARTY_ID and
            par_site.status in ('A', 'I') and
            par_site.party_site_id = acct_site.party_site_id and
            acct_site.status = 'A' and
            acct_site.cust_acct_site_id = site_use.cust_acct_site_id and
            site_use.status = 'A'
        order by Display_Order;

    -- get count on locations
    cursor get_data_crs1(P_PARTY_ID number,
                         P_SITE_USE_CODE varchar2,
                         P_IDENT_FLAG varchar2,
                         P_PRIMARY_FLAG varchar2) is
        select count(1)
        from  HZ_CUST_SITE_USES_ALL site_use,
            HZ_CUST_ACCT_SITES_ALL acct_site,
            hz_party_sites par_site
        where  par_site.party_id = P_PARTY_ID and
            par_site.status in ('A', 'I') and
            par_site.party_site_id = acct_site.party_site_id and
            acct_site.status = 'A' and
            acct_site.cust_acct_site_id = site_use.cust_acct_site_id and
            site_use.status = 'A' and
            site_use.site_use_code = P_SITE_USE_CODE and
            par_site.identifying_address_flag = P_IDENT_FLAG and
            site_use.primary_flag = P_PRIMARY_FLAG;
BEGIN

    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    WriteLog('----------' || l_api_name || '----------');
    WriteLog(l_api_name || ': input parameters:');
    WriteLog(l_api_name || ': P_PARTY_ID: ' || P_PARTY_ID);
    WriteLog(l_api_name || ': P_CONTACT_POINT_TYPE: ' || P_CONTACT_POINT_TYPE);

    X_LOCATION_ID := null;
    X_CONTACT_ID := null;
    X_CONTACT_POINT_ID := null;

    -- verify input parameters and if they are not set return immediately
    if P_PARTY_ID is null or P_CONTACT_POINT_TYPE is null then
        WriteLog(l_api_name || ': Not all input parameters have value');
        return;
    end if;

    WriteLog(l_api_name || ': Searching for account...');

    -- searching for account
    OPEN get_data_crs(P_PARTY_ID);
    fetch get_data_crs into l_display_order,
                            l_cust_account_id,
                            l_site_use_code,
                            l_identifying_address_flag,
                            l_primary_flag;
    CLOSE get_data_crs;

    if l_cust_account_id is null then
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_ACCOUNT');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    WriteLog(l_api_name || ': Found account:');
    WriteLog(l_api_name || ': l_display_order: ' || l_display_order);
    WriteLog(l_api_name || ': l_cust_account_id = ' || l_cust_account_id);
    WriteLog(l_api_name || ': l_site_use_code: ' || l_site_use_code);
    WriteLog(l_api_name || ': l_identifying_address_flag: ' || l_identifying_address_flag);
    WriteLog(l_api_name || ': l_primary_flag: ' || l_primary_flag);

    OPEN get_data_crs1(P_PARTY_ID, l_site_use_code, l_identifying_address_flag, l_primary_flag);
    FETCH get_data_crs1 INTO l_count;
    CLOSE get_data_crs1;

    WriteLog(l_api_name || ': Locations count = ' || l_count);

    -- if more then 1 regular bill-to then set error
    if l_count > 1 then
        WriteLog(l_api_name || ': ERROR: Multiple locations found');
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_MULT_LOC');
        FND_MESSAGE.Set_Token('USAGE', l_site_use_code, FALSE);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
    end if;

    -- call GET_ACCT_DUNNING_DATA for found account
    WriteLog(l_api_name || ': Calling GET_ACCT_DUNNING_DATA for account ' || l_cust_account_id);
    GET_ACCT_DUNNING_DATA(p_api_version => 1.0,
                          p_init_msg_list => FND_API.G_FALSE,
                          p_commit => FND_API.G_FALSE,
                          P_CUST_ACCT_ID => l_cust_account_id,
                          P_CONTACT_POINT_TYPE => P_CONTACT_POINT_TYPE,
                          X_LOCATION_ID => X_LOCATION_ID,
                          X_CONTACT_ID => X_CONTACT_ID,
                          X_CONTACT_POINT_ID => X_CONTACT_POINT_ID,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data);

    WriteLog('---------- continue ' || l_api_name || '----------');
    WriteLog(l_api_name || ': x_return_status: ' || x_return_status);
    WriteLog(l_api_name || ': x_msg_count: ' || x_msg_count);

    WriteLog(l_api_name || ': X_LOCATION_ID = ' || X_LOCATION_ID);
    WriteLog(l_api_name || ': X_CONTACT_ID = ' || X_CONTACT_ID);
    WriteLog(l_api_name || ': X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);

    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception error='||SQLERRM);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception error='||SQLERRM);

  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception error='||SQLERRM);
END;



-- get dafault dunning destination
procedure GET_DEFAULT_DUN_DEST(p_api_version              IN NUMBER := 1.0,
                             p_init_msg_list            IN VARCHAR2,
                             p_commit                   IN VARCHAR2,
                             p_level                    in varchar2,
                             p_source_id                in number,
                             p_send_method              in varchar2,
                             X_LOCATION_ID              OUT NOCOPY NUMBER,
                             X_CONTACT_ID               OUT NOCOPY NUMBER,
                             X_CONTACT_POINT_ID         OUT NOCOPY NUMBER,
                             x_return_status            OUT NOCOPY VARCHAR2,
                             x_msg_count                OUT NOCOPY NUMBER,
                             x_msg_data                 OUT NOCOPY VARCHAR2)
is

    l_api_name                constant varchar2(25) := 'GET_DEFAULT_DUN_DEST';
    l_temp_site_use_id        number;
    l_party_id                number;

    cursor c_get_party_from_acc(p_cust_account_id number) is
        select party_id
        from hz_cust_accounts
        where cust_account_id = p_cust_account_id;

    cursor c_get_party_from_site(p_site_use_id number) is
        select cust.party_id
        from hz_cust_accounts cust,
        hz_cust_acct_sites_all acc_site,
        hz_cust_site_uses_all site_use
        where site_use.site_use_id = p_site_use_id and
        site_use.cust_acct_site_id = acc_site.cust_acct_site_id and
        acc_site.cust_account_id = cust.cust_account_id;

    cursor c_get_party_from_del(p_delinquency_id number) is
        select party_cust_id, customer_site_use_id
        from iex_delinquencies_all
        where delinquency_id = p_delinquency_id;

begin

    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    WriteLog('----------' || l_api_name || '----------');
    WriteLog(l_api_name || ': input parameters:');
    WriteLog(l_api_name || ': p_level: ' || p_level);
    WriteLog(l_api_name || ': p_source_id: ' || p_source_id);
    WriteLog(l_api_name || ': p_send_method: ' || p_send_method);

    if p_level = 'CUSTOMER' then
        l_party_id := p_source_id;
    elsif p_level = 'ACCOUNT' then
        WriteLog(l_api_name || ': getting party from account...');
        open c_get_party_from_acc(p_source_id);
        fetch c_get_party_from_acc into l_party_id;
        close c_get_party_from_acc;
    elsif p_level = 'BILL_TO' then
        WriteLog(l_api_name || ': getting party from site...');
        open c_get_party_from_site(p_source_id);
        fetch c_get_party_from_site into l_party_id;
        close c_get_party_from_site;
    elsif p_level = 'DELINQUENCY' then
        WriteLog(l_api_name || ': getting party from delinquency...');
        open c_get_party_from_del(p_source_id);
        fetch c_get_party_from_del into l_party_id, l_temp_site_use_id;
        close c_get_party_from_del;
    end if;
    WriteLog(l_api_name || ': party_id = ' || l_party_id);

    WriteLog(l_api_name || ': Calling GET_CUST_DUNNING_DATA_OW...');
    GET_CUST_DUNNING_DATA_OW(p_api_version => 1.0,
                          p_init_msg_list => FND_API.G_TRUE,
                          p_commit => FND_API.G_FALSE,
                          P_PARTY_ID => l_party_id,
                          P_CONTACT_POINT_TYPE => p_send_method,
                          X_LOCATION_ID => X_LOCATION_ID,
                          X_CONTACT_ID => X_CONTACT_ID,
                          X_CONTACT_POINT_ID => X_CONTACT_POINT_ID,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data);

    if (p_send_method = 'PRINTER' and (X_LOCATION_ID is null or X_CONTACT_ID is null)) or
       (p_send_method <> 'PRINTER' and (X_LOCATION_ID is null or X_CONTACT_ID is null or X_CONTACT_POINT_ID is null)) then

        WriteLog('---------- continue ' || l_api_name || '----------');
        X_LOCATION_ID := null;
        X_CONTACT_ID := null;
        X_CONTACT_POINT_ID := null;

        WriteLog(l_api_name || ': Did not find data the old way. Continue with new way');
        if p_level = 'CUSTOMER' then

            WriteLog(l_api_name || ': Calling GET_CUST_DUNNING_DATA...');
            GET_CUST_DUNNING_DATA(p_api_version => 1.0,
                                  p_init_msg_list => FND_API.G_TRUE,
                                  p_commit => FND_API.G_FALSE,
                                  P_PARTY_ID => p_source_id,
                                  P_CONTACT_POINT_TYPE => p_send_method,
                                  X_LOCATION_ID => X_LOCATION_ID,
                                  X_CONTACT_ID => X_CONTACT_ID,
                                  X_CONTACT_POINT_ID => X_CONTACT_POINT_ID,
                                  x_return_status => x_return_status,
                                  x_msg_count => x_msg_count,
                                  x_msg_data => x_msg_data);

        elsif p_level = 'ACCOUNT' then

            WriteLog(l_api_name || ': Calling GET_ACCT_DUNNING_DATA...');
            GET_ACCT_DUNNING_DATA(p_api_version => 1.0,
                                  p_init_msg_list => FND_API.G_TRUE,
                                  p_commit => FND_API.G_FALSE,
                                  P_CUST_ACCT_ID => p_source_id,
                                  P_CONTACT_POINT_TYPE => p_send_method,
                                  X_LOCATION_ID => X_LOCATION_ID,
                                  X_CONTACT_ID => X_CONTACT_ID,
                                  X_CONTACT_POINT_ID => X_CONTACT_POINT_ID,
                                  x_return_status => x_return_status,
                                  x_msg_count => x_msg_count,
                                  x_msg_data => x_msg_data);

        elsif p_level = 'BILL_TO' then

            WriteLog(l_api_name || ': Calling GET_SITE_DUNNING_DATA...');
            GET_SITE_DUNNING_DATA(p_api_version => 1.0,
                                  p_init_msg_list => FND_API.G_TRUE,
                                  p_commit => FND_API.G_FALSE,
                                  P_SITE_USE_ID => p_source_id,
                                  P_CONTACT_POINT_TYPE => p_send_method,
                                  X_LOCATION_ID => X_LOCATION_ID,
                                  X_CONTACT_ID => X_CONTACT_ID,
                                  X_CONTACT_POINT_ID => X_CONTACT_POINT_ID,
                                  x_return_status => x_return_status,
                                  x_msg_count => x_msg_count,
                                  x_msg_data => x_msg_data);

        elsif p_level = 'DELINQUENCY' then

            WriteLog(l_api_name || ': site_use_id = ' || l_temp_site_use_id);
            WriteLog(l_api_name || ': Calling GET_SITE_DUNNING_DATA...');
            GET_SITE_DUNNING_DATA(p_api_version => 1.0,
                                  p_init_msg_list => FND_API.G_TRUE,
                                  p_commit => FND_API.G_FALSE,
                                  P_SITE_USE_ID => l_temp_site_use_id,
                                  P_CONTACT_POINT_TYPE => p_send_method,
                                  X_LOCATION_ID => X_LOCATION_ID,
                                  X_CONTACT_ID => X_CONTACT_ID,
                                  X_CONTACT_POINT_ID => X_CONTACT_POINT_ID,
                                  x_return_status => x_return_status,
                                  x_msg_count => x_msg_count,
                                  x_msg_data => x_msg_data);

        end if;

    end if;

    WriteLog('---------- continue ' || l_api_name || '----------');
    WriteLog(l_api_name || ': LOCATION_ID: ' || X_LOCATION_ID);
    WriteLog(l_api_name || ': CONTACT_ID: ' || X_CONTACT_ID);
    WriteLog(l_api_name || ': CONTACT_POINT_ID: ' || X_CONTACT_POINT_ID);

    WriteLog(l_api_name || ': x_return_status: ' || x_return_status);
    WriteLog(l_api_name || ': x_msg_count: ' || x_msg_count);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception error='||SQLERRM);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception error='||SQLERRM);

  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception error='||SQLERRM);
END;



-- get dafault dunning data
procedure GET_DEFAULT_DUN_DATA(p_api_version              IN NUMBER := 1.0,
                             p_init_msg_list            IN VARCHAR2,
                             p_commit                   IN VARCHAR2,
                             p_level                    in varchar2,
                             p_source_id                in number,
                             p_send_method              in varchar2,
                             p_resend                   IN VARCHAR2 ,
                             p_object_code              IN VARCHAR2 ,
                             p_object_id                IN NUMBER,
                             p_fulfillment_bind_tbl     in out nocopy IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL,
                             x_return_status            OUT NOCOPY VARCHAR2,
                             x_msg_count                OUT NOCOPY NUMBER,
                             x_msg_data                 OUT NOCOPY VARCHAR2)

is

    l_fulfillment_bind_tbl    IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
    l_bind_count              number;
    l_del_index               number;
    l_location_index          number;
    l_contact_index           number;
    l_site_use_index          number;
    l_cust_account_index      number;
    l_party_index             number;
    l_delinquency_id          number;
    l_customer_site_use_id    number;
    l_cust_account_id         number;
    l_party_id                number;
    l_location_id             number;
    l_contact_id              number;
    l_display                 number; --placeholder for display order
    l_api_name                constant varchar2(25) := 'GET_DEFAULT_DUN_DATA';
    Type refCur               is Ref Cursor;
    sql_cur                   refCur;
    vPLSQL                    VARCHAR2(2000);
    l_temp_site_use_id        number;
    l_contact_point_id        number;
    l_receipt_index           number;
    l_payment_index           number;
    l_promise_index           number;
    l_invoice_index           number;
    l_dispute_index           number;
    l_cm_request_index        number;
    l_adjustment_index        number;
    l_contact_point_index     number;
    l_temp_party_id           number;
    l_temp_acct_id            number;
    l_dispute_id              number;

    cursor c_get_del_info(p_delinquency_id number) is
        select party_cust_id, cust_account_id, customer_site_use_id
        from iex_delinquencies_all
        where delinquency_id = p_delinquency_id;

    cursor c_get_acct_info(p_cust_account_id number) is
        select party_id
        from hz_cust_accounts
        where cust_account_id = p_cust_account_id;

    cursor c_get_site_info(p_site_use_id number) is
        select cust.party_id, cust.cust_account_id
        from hz_cust_accounts cust,
        hz_cust_acct_sites_all acc_site,
        hz_cust_site_uses_all site_use
        where site_use.site_use_id = p_site_use_id and
        site_use.cust_acct_site_id = acc_site.cust_acct_site_id and
        acc_site.cust_account_id = cust.cust_account_id;

    cursor c_get_dispute(p_cm_request_id number) is
        select dispute_id
        from IEX_DISPUTES
        where cm_request_id = p_cm_request_id;

    --Added for bug 9550221 gnramasa 20th Apr 2010
    cursor c_get_acc_info_from_inv(p_cust_trx_id number) is
        select customer_id
        from ar_payment_schedules_all
        where customer_trx_id = p_cust_trx_id;

begin

    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    WriteLog('----------' || l_api_name || '----------');
    WriteLog(l_api_name || ': input parameters:');
    WriteLog(l_api_name || ': p_level: ' || p_level);
    WriteLog(l_api_name || ': p_source_id: ' || p_source_id);

    l_fulfillment_bind_tbl    := p_fulfillment_bind_tbl;
    l_del_index               := 0;
    l_site_use_index          := 0;
    l_cust_account_index      := 0;
    l_party_index             := 0;
    l_location_id             := 0;
    l_contact_id              := 0;
    l_location_index          := 0;
    l_contact_index           := 0;
    l_receipt_index           := 0;
    l_payment_index           := 0;
    l_promise_index           := 0;
    l_invoice_index           := 0;
    l_dispute_index           := 0;
    l_cm_request_index        := 0;
    l_adjustment_index        := 0;
    l_contact_point_index     := 0;

    WriteLog(l_api_name || ': input bind table:');
    -- index all bind variables
    l_bind_count := l_fulfillment_bind_tbl.count;
    for k in 1..l_bind_count loop

      l_fulfillment_bind_tbl(k).key_name := upper(l_fulfillment_bind_tbl(k).key_name);

      WriteLog(l_api_name || ' - #' || k || ' - ' ||
          l_fulfillment_bind_tbl(k).key_name || ' = ' || l_fulfillment_bind_tbl(k).key_value);

    end loop;

    -- Adding and filling missing bind vars
    WriteLog(l_api_name || ': Adding and filling missing bind vars...');

    if p_resend = 'Y' then

        l_bind_count := l_bind_count + 1;
        if p_object_code = 'IEX_INVOICES' then

            l_fulfillment_bind_tbl(l_bind_count).key_name := 'INVOICE_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := p_object_id;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');

        elsif p_object_code = 'IEX_PAYMENT' then

            l_fulfillment_bind_tbl(l_bind_count).key_name := 'PAYMENT_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := p_object_id;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');

        elsif p_object_code = 'IEX_ADJUSTMENT' then

            l_fulfillment_bind_tbl(l_bind_count).key_name := 'ADJUSTMENT_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := p_object_id;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');

        elsif p_object_code = 'IEX_PROMISE' then

            l_fulfillment_bind_tbl(l_bind_count).key_name := 'PROMISE_DETAIL_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := p_object_id;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');

        elsif p_object_code = 'IEX_REVERSAL' then

            l_fulfillment_bind_tbl(l_bind_count).key_name := 'RECEIPT_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := p_object_id;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');

        elsif p_object_code = 'IEX_DISPUTE' then

            -- this case for resend of dispute corespondance
            open c_get_dispute(p_object_id);
            fetch c_get_dispute into l_dispute_id;
            close c_get_dispute;

            if l_dispute_id is not null then
                l_fulfillment_bind_tbl(l_bind_count).key_name := 'DISPUTE_ID';
                l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
                l_fulfillment_bind_tbl(l_bind_count).key_value := l_dispute_id;
                WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
            end if;

        elsif p_object_code = 'IEX_ACCOUNT' then

            l_fulfillment_bind_tbl(l_bind_count).key_name := 'ACCOUNT_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := p_object_id;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');

        elsif p_object_code = 'IEX_BILLTO' then

            l_fulfillment_bind_tbl(l_bind_count).key_name := 'CUSTOMER_SITE_USE_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := p_object_id;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');

        elsif p_object_code = 'IEX_DELINQUENCY' then

            l_fulfillment_bind_tbl(l_bind_count).key_name := 'DELINQUENCY_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := p_object_id;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');

        elsif p_object_code = 'IEX_STRATEGY' then

            IF (p_level = 'CUSTOMER') then
                l_fulfillment_bind_tbl(l_bind_count).key_name := 'PARTY_ID';
                l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
                l_fulfillment_bind_tbl(l_bind_count).key_value := p_source_id;
                WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
            ELSIF (p_level = 'ACCOUNT') then
                l_fulfillment_bind_tbl(l_bind_count).key_name := 'ACCOUNT_ID';
                l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
                l_fulfillment_bind_tbl(l_bind_count).key_value := p_source_id;
                WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
            ELSIF (p_level = 'BILL_TO') then
                l_fulfillment_bind_tbl(l_bind_count).key_name := 'CUSTOMER_SITE_USE_ID';
                l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
                l_fulfillment_bind_tbl(l_bind_count).key_value := p_source_id;
                WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
            ELSIF (p_level = 'DELINQUENCY') then
                l_fulfillment_bind_tbl(l_bind_count).key_name := 'DELINQUENCY_ID';
                l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
                l_fulfillment_bind_tbl(l_bind_count).key_value := p_source_id;
                WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
            END IF;

        end if;

    end if;

    -- index all bind variables
    l_bind_count := l_fulfillment_bind_tbl.count;
    for k in 1..l_bind_count loop

      if l_fulfillment_bind_tbl(k).key_name = 'DELINQUENCY_ID' then
            l_del_index          := k;
      elsif l_fulfillment_bind_tbl(k).key_name = 'CUSTOMER_SITE_USE_ID' then
            l_site_use_index     := k;
      elsif l_fulfillment_bind_tbl(k).key_name = 'ACCOUNT_ID' or l_fulfillment_bind_tbl(k).key_name = 'CUST_ACCOUNT_ID' then
            l_fulfillment_bind_tbl(k).key_name := 'ACCOUNT_ID';
            l_cust_account_index := k;
      elsif l_fulfillment_bind_tbl(k).key_name = 'PARTY_ID' then
            l_party_index        := k;
      elsif l_fulfillment_bind_tbl(k).key_name = 'LOCATION_ID' then
            l_location_index     := k;
      elsif l_fulfillment_bind_tbl(k).key_name = 'CONTACT_ID' then
            l_contact_index      := k;
      elsif l_fulfillment_bind_tbl(k).key_name = 'CONTACT_POINT_ID' then
            l_contact_point_index      := k;
      elsif l_fulfillment_bind_tbl(k).key_name = 'RECEIPT_ID' then
            l_receipt_index      := k;
      elsif l_fulfillment_bind_tbl(k).key_name = 'PAYMENT_ID' then
            l_payment_index      := k;
      elsif l_fulfillment_bind_tbl(k).key_name = 'PROMISE_DETAIL_ID' then
            l_promise_index      := k;
      elsif l_fulfillment_bind_tbl(k).key_name = 'INVOICE_ID' then
            l_invoice_index      := k;
      elsif l_fulfillment_bind_tbl(k).key_name = 'DISPUTE_ID' then
            l_dispute_index      := k;
      elsif l_fulfillment_bind_tbl(k).key_name = 'ADJUSTMENT_ID' then
            l_adjustment_index   := k;
      end if;

    end loop;

    -- filling missing but required bind vars
    if p_level = 'CUSTOMER' then

        if l_party_index = 0 then
            l_bind_count := l_bind_count + 1;
            l_fulfillment_bind_tbl(l_bind_count).key_name  := 'PARTY_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := p_source_id;
            l_party_index := l_bind_count;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
        elsif l_party_index > 0 and l_fulfillment_bind_tbl(l_party_index).key_value is null then
            l_fulfillment_bind_tbl(l_party_index).key_value := p_source_id;
            WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_party_index).key_name || ' value in bind table');
        end if;

        WriteLog(l_api_name || ': PARTY_ID: ' || l_fulfillment_bind_tbl(l_party_index).key_value);

	--Start bug 9550221 gnramasa 20th Apr 2010
	--Invoice letter query id: 39 need cust_account_id. Add this incase collections business level is CUSTOMER.
	if p_object_code = 'IEX_INVOICES' then
	    open c_get_acc_info_from_inv (p_object_id);
	    fetch c_get_acc_info_from_inv into l_temp_acct_id;
	    close c_get_acc_info_from_inv;

	    l_bind_count := l_bind_count + 1;
	    l_fulfillment_bind_tbl(l_bind_count).key_name  := 'ACCOUNT_ID';
	    l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
	    l_fulfillment_bind_tbl(l_bind_count).key_value := l_temp_acct_id;
	    WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
	end if;
	--End bug 9550221 gnramasa 20th Apr 2010


    elsif p_level = 'ACCOUNT' then

        if l_cust_account_index = 0 then
            l_bind_count := l_bind_count + 1;
            l_fulfillment_bind_tbl(l_bind_count).key_name  := 'ACCOUNT_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := p_source_id;
            l_cust_account_index := l_bind_count;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
        elsif l_cust_account_index > 0 and l_fulfillment_bind_tbl(l_cust_account_index).key_value is null then
            l_fulfillment_bind_tbl(l_cust_account_index).key_value := p_source_id;
            WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_cust_account_index).key_name || ' value in bind table');
        end if;

        open c_get_acct_info(l_fulfillment_bind_tbl(l_cust_account_index).key_value);
        fetch c_get_acct_info into l_temp_party_id;
        close c_get_acct_info;

        if l_party_index = 0 then
            l_bind_count := l_bind_count + 1;
            l_fulfillment_bind_tbl(l_bind_count).key_name  := 'PARTY_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := l_temp_party_id;
            l_party_index := l_bind_count;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
        elsif l_party_index > 0 and l_fulfillment_bind_tbl(l_party_index).key_value is null then
            l_fulfillment_bind_tbl(l_party_index).key_value := l_temp_party_id;
            WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_party_index).key_name || ' value in bind table');
        end if;

        WriteLog(l_api_name || ': PARTY_ID: ' || l_fulfillment_bind_tbl(l_party_index).key_value);
        WriteLog(l_api_name || ': ACCOUNT_ID: ' || l_fulfillment_bind_tbl(l_cust_account_index).key_value);

    elsif p_level = 'BILL_TO' then

        if l_site_use_index = 0 then
            l_bind_count := l_bind_count + 1;
            l_fulfillment_bind_tbl(l_bind_count).key_name  := 'CUSTOMER_SITE_USE_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := p_source_id;
            l_site_use_index := l_bind_count;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
        elsif l_site_use_index > 0 and l_fulfillment_bind_tbl(l_site_use_index).key_value is null then
            l_fulfillment_bind_tbl(l_site_use_index).key_value := p_source_id;
            WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_site_use_index).key_name || ' value in bind table');
        end if;

        open c_get_site_info(l_fulfillment_bind_tbl(l_site_use_index).key_value);
        fetch c_get_site_info into l_temp_party_id, l_temp_acct_id;
        close c_get_site_info;

        if l_party_index = 0 then
            l_bind_count := l_bind_count + 1;
            l_fulfillment_bind_tbl(l_bind_count).key_name  := 'PARTY_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := l_temp_party_id;
            l_party_index := l_bind_count;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
        elsif l_party_index > 0 and l_fulfillment_bind_tbl(l_party_index).key_value is null then
            l_fulfillment_bind_tbl(l_party_index).key_value := l_temp_party_id;
            WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_party_index).key_name || ' value in bind table');
        end if;

        if l_cust_account_index = 0 then
            l_bind_count := l_bind_count + 1;
            l_fulfillment_bind_tbl(l_bind_count).key_name  := 'ACCOUNT_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := l_temp_acct_id;
            l_cust_account_index := l_bind_count;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
        elsif l_cust_account_index > 0 and l_fulfillment_bind_tbl(l_cust_account_index).key_value is null then
            l_fulfillment_bind_tbl(l_cust_account_index).key_value := l_temp_acct_id;
            WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_cust_account_index).key_name || ' value in bind table');
        end if;

        WriteLog(l_api_name || ': PARTY_ID: ' || l_fulfillment_bind_tbl(l_party_index).key_value);
        WriteLog(l_api_name || ': ACCOUNT_ID: ' || l_fulfillment_bind_tbl(l_cust_account_index).key_value);
        WriteLog(l_api_name || ': CUSTOMER_SITE_USE_ID: ' || l_fulfillment_bind_tbl(l_site_use_index).key_value);

    elsif p_level = 'DELINQUENCY' then

        if l_del_index = 0 then
            l_bind_count := l_bind_count + 1;
            l_fulfillment_bind_tbl(l_bind_count).key_name  := 'DELINQUENCY_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := p_source_id;
            l_del_index := l_bind_count;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
        elsif l_del_index > 0 and l_fulfillment_bind_tbl(l_del_index).key_value is null then
            l_fulfillment_bind_tbl(l_del_index).key_value := p_source_id;
            WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_del_index).key_name || ' value in bind table');
        end if;

        open c_get_del_info(l_fulfillment_bind_tbl(l_del_index).key_value);
        fetch c_get_del_info into l_temp_party_id, l_temp_acct_id, l_temp_site_use_id;
        close c_get_del_info;

        if l_party_index = 0 then
            l_bind_count := l_bind_count + 1;
            l_fulfillment_bind_tbl(l_bind_count).key_name  := 'PARTY_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := l_temp_party_id;
            l_party_index := l_bind_count;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
        elsif l_party_index > 0 and l_fulfillment_bind_tbl(l_party_index).key_value is null then
            l_fulfillment_bind_tbl(l_party_index).key_value := l_temp_party_id;
            WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_party_index).key_name || ' value in bind table');
        end if;

        if l_cust_account_index = 0 then
            l_bind_count := l_bind_count + 1;
            l_fulfillment_bind_tbl(l_bind_count).key_name  := 'ACCOUNT_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := l_temp_acct_id;
            l_cust_account_index := l_bind_count;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
        elsif l_cust_account_index > 0 and l_fulfillment_bind_tbl(l_cust_account_index).key_value is null then
            l_fulfillment_bind_tbl(l_cust_account_index).key_value := l_temp_acct_id;
            WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_cust_account_index).key_name || ' value in bind table');
        end if;

        if l_site_use_index = 0 then
            l_bind_count := l_bind_count + 1;
            l_fulfillment_bind_tbl(l_bind_count).key_name  := 'CUSTOMER_SITE_USE_ID';
            l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
            l_fulfillment_bind_tbl(l_bind_count).key_value := l_temp_site_use_id;
            l_site_use_index := l_bind_count;
            WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
        elsif l_site_use_index > 0 and l_fulfillment_bind_tbl(l_site_use_index).key_value is null then
            l_fulfillment_bind_tbl(l_site_use_index).key_value := l_temp_site_use_id;
            WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_site_use_index).key_name || ' value in bind table');
        end if;

        WriteLog(l_api_name || ': PARTY_ID: ' || l_fulfillment_bind_tbl(l_party_index).key_value);
        WriteLog(l_api_name || ': ACCOUNT_ID: ' || l_fulfillment_bind_tbl(l_cust_account_index).key_value);
        WriteLog(l_api_name || ': CUSTOMER_SITE_USE_ID: ' || l_fulfillment_bind_tbl(l_site_use_index).key_value);
        WriteLog(l_api_name || ': DELINQUENCY_ID: ' || l_fulfillment_bind_tbl(l_del_index).key_value);

    end if;

    WriteLog(l_api_name || ': Calling GET_DEFAULT_DUN_DEST...');
    GET_DEFAULT_DUN_DEST(p_api_version => 1.0,
                         p_init_msg_list => FND_API.G_TRUE,
                         p_commit => FND_API.G_FALSE,
                         p_level => p_level,
                         p_source_id => p_source_id,
                         p_send_method => p_send_method,
                         X_LOCATION_ID => l_location_id,
                         X_CONTACT_ID => l_contact_id,
                         X_CONTACT_POINT_ID => l_contact_point_id,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);

    WriteLog('---------- continue ' || l_api_name || '----------');
    WriteLog(l_api_name || ': LOCATION_ID: ' || l_location_id);
    WriteLog(l_api_name || ': CONTACT_ID: ' || l_contact_id);
    WriteLog(l_api_name || ': CONTACT_POINT_ID: ' || l_contact_point_id);

    if l_location_index = 0 then
         l_bind_count := l_bind_count + 1;
         l_fulfillment_bind_tbl(l_bind_count).key_name  := 'LOCATION_ID';
         l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
         l_fulfillment_bind_tbl(l_bind_count).key_value := l_location_id;
         l_location_index := l_bind_count;
         WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
    elsif l_location_index > 0 and l_fulfillment_bind_tbl(l_location_index).key_value is null then
         l_fulfillment_bind_tbl(l_location_index).key_value := l_location_id;
         WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_location_index).key_name || ' value in bind table');
    end if;

    if l_contact_index = 0 then
         l_bind_count := l_bind_count + 1;
         l_fulfillment_bind_tbl(l_bind_count).key_name  := 'CONTACT_ID';
         l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
         l_fulfillment_bind_tbl(l_bind_count).key_value := l_contact_id;
         l_contact_index := l_bind_count;
         WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
    elsif l_contact_index > 0 and l_fulfillment_bind_tbl(l_contact_index).key_value is null then
         l_fulfillment_bind_tbl(l_contact_index).key_value := l_contact_id;
         WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_contact_index).key_name || ' value in bind table');
    end if;

    if l_contact_point_index = 0 then
         l_bind_count := l_bind_count + 1;
         l_fulfillment_bind_tbl(l_bind_count).key_name  := 'CONTACT_POINT_ID';
         l_fulfillment_bind_tbl(l_bind_count).key_type  := 'NUMBER';
         l_fulfillment_bind_tbl(l_bind_count).key_value := l_contact_point_id;
         l_contact_point_index := l_bind_count;
         WriteLog(l_api_name || ': Added ' || l_fulfillment_bind_tbl(l_bind_count).key_name || ' to bind table');
    elsif l_contact_point_index > 0 and l_fulfillment_bind_tbl(l_contact_point_index).key_value is null then
         l_fulfillment_bind_tbl(l_contact_point_index).key_value := l_contact_point_id;
         WriteLog(l_api_name || ': Updated ' || l_fulfillment_bind_tbl(l_contact_point_index).key_name || ' value in bind table');
    end if;

    -- print out output bind table
    WriteLog(l_api_name || ': output bind table:');
    l_bind_count := l_fulfillment_bind_tbl.count;
    for k in 1..l_bind_count loop
        WriteLog(l_api_name || ' - #' || k || ' - ' ||
          l_fulfillment_bind_tbl(k).key_name || ' = ' || l_fulfillment_bind_tbl(k).key_value);
    end loop;

    p_fulfillment_bind_tbl := l_fulfillment_bind_tbl;

    WriteLog(l_api_name || ': x_return_status: ' || x_return_status);
    WriteLog(l_api_name || ': x_msg_count: ' || x_msg_count);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception error='||SQLERRM);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception error='||SQLERRM);

  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception error='||SQLERRM);
end;



Procedure Validate_Delinquency(
    P_Init_Msg_List              IN   VARCHAR2     ,
    P_Delinquency_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_GET_Del (IN_del_ID NUMBER) IS
    SELECT delinquency_id
      FROM iex_delinquencies
     WHERE delinquency_ID = IN_del_ID;
  --
  l_delinquency_id NUMBER;

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF P_delinquency_ID is NULL
         or  P_delinquency_ID = FND_API.G_MISS_NUM
      THEN
                FND_MESSAGE.Set_Name('IEX', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'delinquency_ID', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_delinquency_id, FALSE);
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;

      ELSE

          OPEN C_Get_Del (p_delinquency_id);
          FETCH C_Get_Del INTO l_delinquency_ID;

          IF (C_Get_Del%NOTFOUND)
          THEN
            IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.Set_Name('IEX', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'delinquency_ID', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_delinquency_id, FALSE);
                FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_GET_Del;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Delinquency;



Procedure Create_AG_DN_XREF
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_AG_DN_XREF_REC          IN IEX_DUNNING_PUB.AG_DN_XREF_REC_TYPE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_AG_DN_XREF_ID           OUT NOCOPY NUMBER)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_AG_DN';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_AG_DN_XREF_REC              IEX_DUNNING_PUB.AG_DN_XREF_REC_TYPE ;
    errmsg                        VARCHAR2(32767);


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_AG_DN_PVT;

      l_ag_dn_xref_rec := p_ag_dn_xref_rec;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      WriteLog(l_api_name || G_PKG_NAME || ' ' || l_api_name || ' - Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      WriteLog(l_api_name || G_PKG_NAME || ' ' || l_api_name || ' - CreateAgDn:Calling Validation');

      -- Invoke validation procedures
      -- Validate Data
      -- Validate Aging_Bucket_line
      -- Validate Template
      -- Validate Score Range (for the same bucket_line_id, don't overlap)
      WriteLog(l_api_name || G_PKG_NAME || ' ' || l_api_name || ' -CreateAgDn:InsertRow');

      -- Create AG_DN_XREF
      IEX_AG_DN_PKG.insert_row(
          px_rowid                         => l_rowid
        , px_AG_DN_XREF_id                 => x_AG_DN_XREF_id
        , p_last_update_date               => sysdate
        , p_last_updated_by                => FND_GLOBAL.USER_ID
        , p_creation_date                  => sysdate
        , p_created_by                     => FND_GLOBAL.USER_ID
        , p_last_update_login              => FND_GLOBAL.USER_ID
        , p_aging_bucket_id                => l_AG_DN_XREF_rec.aging_bucket_id
        , p_aging_bucket_line_id           => l_AG_DN_XREF_rec.aging_bucket_line_id
        , p_callback_flag                  => l_AG_DN_XREF_rec.callback_flag
        , p_callback_days                  => l_AG_DN_XREF_rec.callback_days
        , p_fm_method                      => l_AG_DN_XREF_rec.fm_method
        , p_dunning_level                  => l_AG_DN_XREF_rec.dunning_level
        , p_template_id                    => l_AG_DN_XREF_rec.template_id
        , p_xdo_template_id                => l_AG_DN_XREF_rec.xdo_template_id
        , p_score_range_low                => l_AG_DN_XREF_rec.score_range_low
        , p_score_range_high               => l_AG_DN_XREF_rec.score_range_high
        , p_object_version_number          => l_AG_DN_XREF_rec.object_version_number
     );

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      WriteLog(l_api_name || G_PKG_NAME || ' ' || l_api_name || ' - End');



      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO CREATE_AG_DN_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO CREATE_AG_DN_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO CREATE_AG_DN_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);

END CREATE_AG_DN_XREF;


Procedure Update_AG_DN_XREF
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_AG_DN_XREF_REC          IN IEX_DUNNING_PUB.AG_DN_XREF_REC_TYPE,
            p_AG_DN_XREF_ID           IN NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_get_AG_DN_XREF_Rec (IN_AG_DN_XREF_ID NUMBER) is
       select  ROWID,
               AG_DN_XREF_ID,
               AGING_BUCKET_ID,
               AGING_BUCKET_LINE_ID,
               CALLBACK_FLAG,
               CALLBACK_DAYS,
               FM_METHOD,
               TEMPLATE_ID,
               XDO_TEMPLATE_ID,
               SCORE_RANGE_LOW,
               SCORE_RANGE_HIGH,
               DUNNING_LEVEL,
               OBJECT_VERSION_NUMBER ,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY ,
               LAST_UPDATE_LOGIN
         from iex_AG_DN_XREF
        where AG_DN_XREF_id = in_AG_DN_XREF_id
        FOR UPDATE NOWAIT;
    --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Update_AG_DN';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_AG_DN_XREF_REC              IEX_DUNNING_PUB.AG_DN_XREF_REC_TYPE ;
    l_AG_DN_XREF_id               NUMBER ;
    l_AG_DN_XREF_REF_REC          IEX_DUNNING_PUB.AG_DN_XREF_REC_TYPE;
    errmsg                        VARCHAR2(32767);


BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_AG_DN_PVT;

      l_AG_DN_XREF_REC       := p_AG_DN_XREF_rec;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- Api body
      --
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Open C_GET_AGDN_XREF_REC');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - agdnxrefid='||l_ag_dn_xref_rec.ag_dn_xref_id);


      Open C_Get_AG_DN_XREF_Rec(l_AG_DN_XREF_rec.AG_DN_XREF_ID);
      Fetch C_Get_AG_DN_XREF_Rec into
         l_rowid,
         l_AG_DN_XREF_ref_rec.AG_DN_XREF_ID,
         l_AG_DN_XREF_ref_rec.AGING_BUCKET_ID,
         l_AG_DN_XREF_ref_rec.aging_bucket_line_id,
         l_AG_DN_XREF_ref_rec.callback_FLAG,
         l_AG_DN_XREF_ref_rec.callback_DAYS,
         l_AG_DN_XREF_ref_rec.fm_method,
         l_AG_DN_XREF_ref_rec.template_id,
         l_AG_DN_XREF_ref_rec.xdo_template_id,
         l_AG_DN_XREF_ref_rec.score_range_low,
         l_AG_DN_XREF_ref_rec.score_range_high,
         l_AG_DN_XREF_ref_rec.dunning_level,
         l_AG_DN_XREF_ref_rec.object_version_number,
         l_AG_DN_XREF_ref_rec.LAST_UPDATE_DATE,
         l_AG_DN_XREF_ref_rec.LAST_UPDATED_BY,
         l_AG_DN_XREF_ref_rec.CREATION_DATE,
         l_AG_DN_XREF_ref_rec.CREATED_BY,
         l_AG_DN_XREF_ref_rec.LAST_UPDATE_LOGIN;

      If ( C_Get_AG_DN_XREF_REC%NOTFOUND) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'IEX_AG_DN_XREF', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Close C_GET_AGDN_XREF_REC');
      Close C_Get_AG_DN_XREF_Rec;

      If (l_ag_Dn_xref_rec.last_update_date is NULL or
         l_ag_Dn_xref_rec.last_update_date = FND_API.G_MISS_Date )
      Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Transfer Data into target rec');

      -- Transfer Data into target record
      l_ag_dn_xref_rec.CREATION_DATE := l_ag_dn_xref_ref_rec.CREATION_DATE;
      l_ag_dn_xref_rec.CREATED_BY := l_ag_dn_xref_ref_rec.CREATED_BY;

      -- dont update aging_bucket_id and aging_bucket_line_id
      -- dont update dunning_level

      IF (l_ag_dn_xref_rec.callback_flag = FND_API.G_MISS_CHAR or
          l_ag_dn_xref_rec.callback_flag is null ) Then
         l_ag_dn_xref_rec.callback_flag := l_ag_dn_xref_REF_rec.callback_flag;
      END IF;
      IF (l_ag_dn_xref_rec.callback_days = FND_API.G_MISS_NUM or
          l_ag_dn_xref_rec.callback_days is null ) Then
         l_ag_dn_xref_rec.callback_days := l_ag_dn_xref_REF_rec.callback_days;
      END IF;
      IF (l_ag_dn_xref_rec.fm_method = FND_API.G_MISS_CHAR or
          l_ag_dn_xref_rec.fm_method is null) Then
         l_ag_dn_xref_rec.fm_method := l_ag_dn_xref_REF_rec.fm_method;
      END IF;
      IF (l_ag_dn_xref_rec.template_ID = FND_API.G_MISS_NUM or
          l_ag_dn_xref_rec.template_id is null ) Then
         l_ag_dn_xref_rec.template_ID := l_ag_dn_xref_ref_rec.template_ID;
      END IF;
      IF (l_ag_dn_xref_rec.xdo_template_ID = FND_API.G_MISS_NUM or
          l_ag_dn_xref_rec.xdo_template_id is null ) Then
         l_ag_dn_xref_rec.xdo_template_ID := l_ag_dn_xref_ref_rec.xdo_template_ID;
      END IF;
      IF (l_ag_dn_xref_rec.score_range_low = FND_API.G_MISS_NUM or
          l_ag_dn_xref_rec.score_range_low is null ) Then
         l_ag_dn_xref_rec.score_range_low := l_ag_dn_xref_ref_rec.score_range_low;
      END IF;
      IF (l_ag_dn_xref_rec.score_range_high = FND_API.G_MISS_NUM or
          l_ag_dn_xref_rec.score_range_high is null ) Then
         l_ag_dn_xref_rec.score_range_high := l_ag_dn_xref_ref_rec.score_range_high;
      END IF;
      IF (l_ag_dn_xref_rec.object_version_number = FND_API.G_MISS_NUM or
          l_ag_dn_xref_rec.object_version_number is null ) Then
         l_ag_dn_xref_rec.object_version_number := l_ag_dn_xref_ref_rec.object_version_number;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateRow ');

      IEX_AG_DN_PKG.update_row(
          p_rowid                          => l_rowid
        , p_AG_DN_XREF_id                  => p_AG_DN_XREF_id
        , p_last_update_date               => sysdate
        , p_last_updated_by                => FND_GLOBAL.USER_ID
        , p_creation_date                  => l_AG_DN_XREF_rec.creation_date
        , p_created_by                     => l_AG_DN_XREF_rec.created_by
        , p_last_update_login              => FND_GLOBAL.USER_ID
        , p_aging_bucket_id                => l_AG_DN_XREF_rec.aging_bucket_id
        , p_aging_bucket_line_id           => l_AG_DN_XREF_rec.aging_bucket_line_id
        , p_callback_flag                  => l_AG_DN_XREF_rec.callback_flag
        , p_callback_days                  => l_AG_DN_XREF_rec.callback_days
        , p_fm_method                      => l_AG_DN_XREF_rec.fm_method
        , p_template_id                    => l_AG_DN_XREF_rec.template_id
        , p_xdo_template_id                => l_AG_DN_XREF_rec.xdo_template_id
        , p_score_range_low                => l_AG_DN_XREF_rec.score_range_low
        , p_score_range_high               => l_AG_DN_XREF_rec.score_range_high
        , p_dunning_level                  => l_AG_DN_XREF_rec.dunning_level
        , p_object_version_number          => l_ag_dn_xref_rec.object_version_number
     );

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateAgDn:End ');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO UPDATE_AG_DN_PVT;
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO UPDATE_AG_DN_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO UPDATE_AG_DN_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);

END Update_AG_DN_XREF;


Procedure Delete_AG_DN_XREF
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_AG_DN_XREF_ID           IN NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_GET_AG_DN_XREF (IN_AG_DN_XREF_ID NUMBER) IS
      SELECT AG_DN_XREF_ID
        FROM IEX_AG_DN_XREF
       WHERE AG_DN_XREF_ID = IN_AG_DN_XREF_ID;
    --
    l_AG_DN_XREF_id         NUMBER;
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_AG_DN';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_rowid                 Varchar2(50);
    errmsg                  VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_AG_DN_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- Api body
      --
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Open Cursor');

      Open C_Get_AG_DN_XREF(p_AG_DN_XREF_id);
      Fetch C_Get_AG_DN_XREF into
         l_AG_DN_XREF_ID;

      If ( C_Get_AG_DN_XREF%NOTFOUND) Then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - NotFound');


        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'IEX_AG_DN_XREF', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - agdnxerfid='||l_ag_dn_xref_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Close Cursor');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Delete Row');
      Close C_Get_AG_DN_XREF;

      -- Invoke table handler
      IEX_AG_DN_PKG.Delete_Row(
             p_AG_DN_XREF_ID  => l_AG_DN_XREF_ID);

      IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO DELETE_AG_DN_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DeleteAgDn:error='||SQLERRM);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO DELETE_AG_DN_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DeleteAgDn:error='||SQLERRM);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO DELETE_AG_DN_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DeleteAgDn:error='||SQLERRM);

END Delete_AG_DN_XREF;


Procedure Create_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_Dunning_REC             IN IEX_DUNNING_PUB.DUNNING_REC_TYPE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_Dunning_ID              OUT NOCOPY NUMBER)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Dunning';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_Dunning_REC                 IEX_DUNNING_PUB.Dunning_REC_TYPE ;
    errmsg                        VARCHAR2(32767);


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_DUNNING_PVT;

      l_dunning_rec := p_dunning_rec;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - START');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');
      --Start adding for bug 8489610 by gnramasa 14-May-09
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_rec.dunning_mode :'||l_dunning_rec.dunning_mode);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_rec.confirmation_mode : '||l_dunning_rec.confirmation_mode);

      -- Create Dunning
      IEX_Dunnings_PKG.insert_row(
          px_rowid                         => l_rowid
        , px_dunning_id                    => x_dunning_id
        , p_last_update_date               => sysdate
        , p_last_updated_by                => FND_GLOBAL.USER_ID
        , p_creation_date                  => sysdate
        , p_created_by                     => FND_GLOBAL.USER_ID
        , p_last_update_login              => FND_GLOBAL.USER_ID
	--			, p_request_id                     => FND_GLOBAL.CONC_REQUEST_ID
	, p_request_id                     => l_dunning_rec.request_id
        , p_template_id                    => l_dunning_rec.template_id
        , p_callback_yn                    => l_dunning_rec.callback_yn
        , p_callback_date                  => l_dunning_rec.callback_date
        , p_campaign_sched_id              => l_dunning_rec.campaign_sched_id
        , p_status                         => l_dunning_rec.status
        , p_delinquency_id                 => l_dunning_rec.delinquency_id
        , p_ffm_request_id                 => l_dunning_rec.ffm_request_id
        , p_xml_request_id                 => l_dunning_rec.xml_request_id
        , p_xml_template_id                => l_dunning_rec.xml_template_id
        , p_object_id                      => l_dunning_rec.object_id
        , p_object_type                    => l_dunning_rec.object_type
        , p_dunning_object_id              => l_dunning_rec.dunning_object_id
        , p_dunning_level                  => l_dunning_rec.dunning_level
        , p_dunning_method                 => l_dunning_rec.dunning_method
        , p_amount_due_remaining           => l_dunning_rec.amount_due_remaining
        , p_currency_code                  => l_dunning_rec.currency_code
        , p_delivery_status                => l_dunning_rec.delivery_status
        , p_parent_dunning_id              => l_dunning_rec.PARENT_DUNNING_ID
        , p_dunning_plan_id                => l_dunning_rec.dunning_plan_id
        , p_contact_destination            => l_dunning_rec.contact_destination
        , p_contact_party_id               => l_dunning_rec.contact_party_id
	, p_dunning_mode		   => l_dunning_rec.dunning_mode
	, p_confirmation_mode              => l_dunning_rec.confirmation_mode
	, p_org_id                         => l_dunning_rec.org_id
	, p_ag_dn_xref_id                  => l_dunning_rec.ag_dn_xref_id
	, p_correspondence_date            => nvl(l_dunning_rec.correspondence_date,trunc(sysdate))
      );
      --End adding for bug 8489610 by gnramasa 14-May-09


      IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END');
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO CREATE_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || 'exception ' || SQLERRM);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO CREATE_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || 'error ' || SQLERRM);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO CREATE_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || 'error ' || SQLERRM);

END CREATE_DUNNING;

Procedure Create_Staged_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
	    p_dunning_id	      IN NUMBER,
	    p_correspondence_date     IN DATE,
	    p_ag_dn_xref_id           IN NUMBER,
            p_running_level           IN VARCHAR2,
	    p_grace_days              IN NUMBER,
	    p_include_dispute_items   IN VARCHAR2,
	    p_dunning_mode            IN VARCHAR2,
	    p_inc_inv_curr            IN IEX_UTILITIES.INC_INV_CURR_TBL,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Staged_Dunning';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_Dunning_REC                 IEX_DUNNING_PUB.Dunning_REC_TYPE ;
    errmsg                        VARCHAR2(32767);

    cursor c_dunning_plan_lines(p_ag_dn_xref_id number) is
    select ag_dn_xref_id,
           range_of_dunning_level_from,
	   range_of_dunning_level_to,
	   min_days_between_dunning
    from iex_ag_dn_xref
    where AG_DN_XREF_ID = p_ag_dn_xref_id
    order by AG_DN_XREF_ID;

    l_dunning_plan_lines	c_dunning_plan_lines%rowtype;
    Type refCur			is Ref Cursor;
    sql_cur			refCur;
    sql_cur1			refCur;
    sql_cur2			refCur;
    sql_cur3			refCur;
    vPLSQL			VARCHAR2(2000);
    vPLSQL1			VARCHAR2(2000);
    vPLSQL2			VARCHAR2(2000);
    vPLSQL3			VARCHAR2(2000);
    l_delinquency_id		number;
    l_transaction_id		number;
    l_customer_trx_id		number;
    l_payment_schedule_id	number;
    l_object_id			number;

    /*
    cursor c_acc_dunning_trx_null_dunn (p_party_id number, p_cust_acct_id number, p_min_days_bw_dun number,
                                        p_corr_date date, p_gra_days number, p_include_dis_items varchar, p_inv_curr varchar) is
    select del.delinquency_id,
           del.transaction_id,
           del.payment_schedule_id
    from iex_delinquencies del,
         ar_payment_schedules arp
    where del.payment_schedule_id = arp.payment_schedule_id
    and del.status in ('DELINQUENT','PREDELINQUENT')
    and del.party_cust_id = p_party_id
    and del.cust_account_id = p_cust_acct_id
    and del.staged_dunning_level is NULL
    and arp.invoice_currency_code = p_inv_curr
    and (trunc(arp.due_date) + p_min_days_bw_dun) <= p_corr_date
    and (trunc(arp.due_date) + p_gra_days) <= p_corr_date
    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
    order by del.payment_schedule_id;

    cursor c_acc_dunning_ful_disp_null (p_party_id number, p_cust_acct_id number, p_min_days_bw_dun number,
                                        p_corr_date date, p_gra_days number, p_include_dis_items varchar, p_inv_curr varchar) is
    select del.delinquency_id,
           del.transaction_id,
           del.payment_schedule_id
    from iex_delinquencies del,
         ar_payment_schedules arp
    where del.payment_schedule_id = arp.payment_schedule_id
    and del.status = 'CURRENT'
    and del.party_cust_id = p_party_id
    and del.cust_account_id = p_cust_acct_id
    and del.staged_dunning_level is NULL
    and arp.status = 'OP'
    and arp.class = 'INV'
    and arp.invoice_currency_code = p_inv_curr
    and (trunc(arp.due_date) + p_min_days_bw_dun) <= p_corr_date
    and (trunc(arp.due_date) + p_gra_days) <= p_corr_date
    and arp.amount_in_dispute >= decode(p_include_dis_items, 'Y', arp.amount_due_remaining, (arp.amount_due_original + 1))
    order by del.payment_schedule_id;

    cursor c_acc_dunning_trx (p_party_id number, p_cust_acct_id number, p_stage_no number,
                              p_min_days_bw_dun number, p_corr_date date, p_include_dis_items varchar, p_inv_curr varchar) is
    select del.delinquency_id,
           del.transaction_id,
           del.payment_schedule_id
    from iex_delinquencies del
         ,ar_payment_schedules arp
    where
    del.payment_schedule_id = arp.payment_schedule_id and
    del.status in ('DELINQUENT','PREDELINQUENT')
    and del.party_cust_id = p_party_id
    and del.cust_account_id = p_cust_acct_id
    and del.staged_dunning_level = p_stage_no
    and arp.invoice_currency_code = p_inv_curr
    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
    and nvl(
        (
	 (select trunc(correspondence_date) from iex_dunnings
          where dunning_id =
           (select distinct DUNNING_ID from iex_dunning_transactions
            where PAYMENT_SCHEDULE_ID = del.payment_schedule_id
            and STAGE_NUMBER = p_stage_no))
	    + p_min_days_bw_dun )
	    , p_corr_date )
	    <= p_corr_date
    order by del.payment_schedule_id;

    cursor c_acc_dunning_full_disp (p_party_id number, p_cust_acct_id number, p_stage_no number,
                              p_min_days_bw_dun number, p_corr_date date, p_include_dis_items varchar, p_inv_curr varchar) is
    select del.delinquency_id,
           del.transaction_id,
           del.payment_schedule_id
    from iex_delinquencies del
         ,ar_payment_schedules arp
    where
    del.payment_schedule_id = arp.payment_schedule_id and
    del.status = 'CURRENT'
    and del.party_cust_id = p_party_id
    and del.cust_account_id = p_cust_acct_id
    and del.staged_dunning_level = p_stage_no
    and arp.status = 'OP'
    and arp.class = 'INV'
    and arp.invoice_currency_code = p_inv_curr
    and arp.amount_in_dispute >= decode(p_include_dis_items, 'Y', arp.amount_due_remaining, (arp.amount_due_original + 1))
    and nvl(
        (
	 (select trunc(correspondence_date) from iex_dunnings
          where dunning_id =
           (select distinct DUNNING_ID from iex_dunning_transactions
            where PAYMENT_SCHEDULE_ID = del.payment_schedule_id
            and STAGE_NUMBER = p_stage_no))
	    + p_min_days_bw_dun )
	    , p_corr_date )
	    <= p_corr_date
    order by del.payment_schedule_id;

    cursor c_acc_dunning_trx_curr_inv (p_cust_acct_id number, p_corr_date date, p_include_dis_items varchar) is
    select arp.customer_trx_id,
           arp.payment_schedule_id
    from ar_payment_schedules arp
    where CUSTOMER_ID = p_cust_acct_id
    and trunc(arp.due_date) > trunc(p_corr_date)
    and arp.status = 'OP'
    and arp.amount_due_remaining > 0
    and arp.class = 'INV'
    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
    and not exists (select 1 from iex_delinquencies del where del.payment_schedule_id = arp.payment_schedule_id)
    order by arp.payment_schedule_id;

    cursor c_acc_dunning_unapp_rec (p_cust_acct_id number) is
    select
           --to_number(null) customer_trx_id,
           arp.payment_schedule_id
    from ar_payment_schedules arp
    where CUSTOMER_ID = p_cust_acct_id
    --and trunc(arp.due_date) > trunc(p_corr_date)
    and arp.status = 'OP'
    and arp.amount_due_remaining <> 0
    and arp.class = 'PMT'
    order by arp.payment_schedule_id;

    cursor c_acc_dunning_onacc_cm (p_cust_acct_id number) is
    select
	ar.customer_trx_id customer_trx_id,
	ar.payment_schedule_id payment_schedule_id
     from
	ar_payment_schedules ar
     where
     ar.customer_id = p_cust_acct_id
     and ar.amount_due_remaining <> 0
     and ar.class ='CM'
     and ar.status='OP';
     */

    cursor c_dunn_plan_line_dtls (p_ag_dn_xref_id number) is
    select nvl(dunn.include_current ,'N'),
           nvl(dunn.include_unused_payments_flag,'N')
    from iex_ag_dn_xref xref,
         iex_dunning_plans_b dunn
    where AG_DN_XREF_ID = p_ag_dn_xref_id
    and xref.dunning_plan_id = dunn.dunning_plan_id;

    x_dunning_trx_id	number;
    l_stage	        number;
    l_include_curr_inv  varchar2(10);
    l_include_unapp_rec varchar2(10);
    l_curr_count        number := 0;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_STAGED_DUNNING_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      l_curr_count := p_inc_inv_curr.count;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - START');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_dunning_id :'|| p_dunning_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_grace_days :'|| p_grace_days);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_include_dispute_items :'|| p_include_dispute_items);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_curr_count :'|| l_curr_count);

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --

      OPEN c_dunning_plan_lines (p_ag_dn_xref_id);
      fetch c_dunning_plan_lines into l_dunning_plan_lines;
      close c_dunning_plan_lines;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.ag_dn_xref_id='||l_dunning_plan_lines.ag_dn_xref_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_plan_lines.range_of_dunning_level_from='||l_dunning_plan_lines.range_of_dunning_level_from);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_plan_lines.range_of_dunning_level_to='||l_dunning_plan_lines.range_of_dunning_level_to);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_plan_lines.min_days_between_dunning='||l_dunning_plan_lines.min_days_between_dunning);

        if (p_running_level = 'CUSTOMER') then
		l_object_id	:= p_delinquencies_tbl(1).party_cust_id;
	elsif  (p_running_level = 'ACCOUNT') then
		l_object_id	:= p_delinquencies_tbl(1).cust_account_id;
	elsif  (p_running_level = 'BILL_TO') then
		l_object_id	:= p_delinquencies_tbl(1).customer_site_use_id;
	end if;

	for i in l_dunning_plan_lines.range_of_dunning_level_from..l_dunning_plan_lines.range_of_dunning_level_to
	loop
		l_stage	:= i-1;
		if i = 1 then
			for j in 1..l_curr_count loop
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_inc_inv_curr(' || j || ') : '|| p_inc_inv_curr(j));

				vPLSQL := 'select  del.delinquency_id, ' ||
				        '          del.transaction_id, ' ||
					'	   del.payment_schedule_id ' ||
					'    from iex_delinquencies del, ' ||
					'	 ar_payment_schedules arp ' ||
					'    where del.payment_schedule_id = arp.payment_schedule_id ' ||
					'    and del.status in (''DELINQUENT'',''PREDELINQUENT'') ' ||
					'    and del.staged_dunning_level is NULL ' ||
					'    and arp.invoice_currency_code = :p_inv_curr ' ||
					'    and (trunc(arp.due_date) + :p_min_days_bw_dun) <= :p_corr_date ' ||
					'    and (trunc(arp.due_date) + :p_gra_days) <= :p_corr_date ' ||
					'    and nvl(arp.amount_in_dispute,0) = decode(:p_include_dis_items, ''Y'', nvl(arp.amount_in_dispute,0), 0) ';
				if (p_running_level = 'CUSTOMER') then
				      vPLSQL3		:= '    and del.party_cust_id = :p_party_id ' ||
							   '    order by del.payment_schedule_id';
				elsif  (p_running_level = 'ACCOUNT') then
				      vPLSQL3		:= '    and del.cust_account_id = :p_cust_acct_id ' ||
				                           '    order by del.payment_schedule_id';
				elsif  (p_running_level = 'BILL_TO') then
				      vPLSQL3		:= '    and del.customer_site_use_id = :p_site_use_id ' ||
				                           '    order by del.payment_schedule_id';
				end if;
				vPLSQL	:= vPLSQL || vPLSQL3;

				open sql_cur for vPLSQL using p_inc_inv_curr(j),
							    l_dunning_plan_lines.min_days_between_dunning,
							    p_correspondence_date,
							    p_grace_days,
							    p_correspondence_date,
							    p_include_dispute_items,
							    l_object_id;
				loop
				      fetch sql_cur into l_delinquency_id, l_transaction_id, l_payment_schedule_id;
				      exit when sql_cur%notfound;

				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');
				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur.l_delinquency_id :'||l_delinquency_id);
				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur.l_transaction_id :'||l_transaction_id);
				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur.l_payment_schedule_id : '||l_payment_schedule_id);

				      IEX_Dunnings_PKG.insert_staged_dunning_row(
					  px_rowid                          => l_rowid
					, px_dunning_trx_id                 => x_dunning_trx_id
					, p_dunning_id                      => p_dunning_id
					, p_cust_trx_id                     => l_transaction_id
					, p_payment_schedule_id             => l_payment_schedule_id
					, p_ag_dn_xref_id                   => p_ag_dn_xref_id
					, p_stage_number                    => i
					, p_created_by                      => FND_GLOBAL.USER_ID
					, p_creation_date                   => sysdate
					, p_last_updated_by                 => FND_GLOBAL.USER_ID
					, p_last_update_date                => sysdate
					, p_last_update_login               => FND_GLOBAL.USER_ID
					, p_object_version_number	    => 1.0
				      );

				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_dunning_trx_id :'|| x_dunning_trx_id);

				      IF x_return_status = FND_API.G_RET_STS_ERROR then
						raise FND_API.G_EXC_ERROR;
				      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
					       raise FND_API.G_EXC_UNEXPECTED_ERROR;
				      END IF;

				      /*
				      if p_dunning_mode <> 'DRAFT' then
					      update iex_delinquencies_all
					      set staged_dunning_level = i
					      where delinquency_id = l_delinquency_id;
				      end if;
				      */

				      --reset the x_dunning_trx_id, so that will get new no when inserting 2nd record.
				      x_dunning_trx_id	:= null;
				end loop;
				close sql_cur;

				--Include past due fully disputed invoices
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start Include past due fully disputed invoices');
				vPLSQL1 := 'select del.delinquency_id, ' ||
					   ' del.transaction_id, ' ||
					   ' del.payment_schedule_id  ' ||
				'    from iex_delinquencies del, ' ||
				'	 ar_payment_schedules arp ' ||
				'    where del.payment_schedule_id = arp.payment_schedule_id ' ||
				'    and del.status = ''CURRENT'' ' ||
				'    and del.staged_dunning_level is NULL ' ||
				'    and arp.status = ''OP'' ' ||
				'    and arp.class = ''INV'' ' ||
				'    and arp.invoice_currency_code = :p_inv_curr ' ||
				'    and (trunc(arp.due_date) + :p_min_days_bw_dun) <= :p_corr_date ' ||
				'    and (trunc(arp.due_date) + :p_gra_days) <= :p_corr_date ' ||
				'    and arp.amount_in_dispute >= decode(:p_include_dis_items, ''Y'', arp.amount_due_remaining, (arp.amount_due_original + 1)) ';

				vPLSQL1	:= vPLSQL1 || vPLSQL3;

				open sql_cur1 for vPLSQL1 using p_inc_inv_curr(j),
							    l_dunning_plan_lines.min_days_between_dunning,
							    p_correspondence_date,
							    p_grace_days,
							    p_correspondence_date,
							    p_include_dispute_items,
							    l_object_id;
				loop
				      fetch sql_cur1 into l_delinquency_id, l_transaction_id, l_payment_schedule_id;
				      exit when sql_cur1%notfound;

				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');
				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur1.l_delinquency_id :'||l_delinquency_id);
				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur1.l_transaction_id :'||l_transaction_id);
				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur1.l_payment_schedule_id : '||l_payment_schedule_id);

				      IEX_Dunnings_PKG.insert_staged_dunning_row(
					  px_rowid                          => l_rowid
					, px_dunning_trx_id                 => x_dunning_trx_id
					, p_dunning_id                      => p_dunning_id
					, p_cust_trx_id                     => l_transaction_id
					, p_payment_schedule_id             => l_payment_schedule_id
					, p_ag_dn_xref_id                   => p_ag_dn_xref_id
					, p_stage_number                    => i
					, p_created_by                      => FND_GLOBAL.USER_ID
					, p_creation_date                   => sysdate
					, p_last_updated_by                 => FND_GLOBAL.USER_ID
					, p_last_update_date                => sysdate
					, p_last_update_login               => FND_GLOBAL.USER_ID
					, p_object_version_number	    => 1.0
				      );

				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_dunning_trx_id :'|| x_dunning_trx_id);

				      IF x_return_status = FND_API.G_RET_STS_ERROR then
						raise FND_API.G_EXC_ERROR;
				      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
					       raise FND_API.G_EXC_UNEXPECTED_ERROR;
				      END IF;

				      /*
				      if p_dunning_mode <> 'DRAFT' then
					      update iex_delinquencies_all
					      set staged_dunning_level = i
					      where delinquency_id = l_delinquency_id;
				      end if;
				      */

				      --reset the x_dunning_trx_id, so that will get new no when inserting 2nd record.
				      x_dunning_trx_id	:= null;

				end loop;
				close sql_cur1;
			end loop;
			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End Include past due fully disputed invoices');
		else
			for k in 1..l_curr_count loop
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_inc_inv_curr(' || k || ') : '|| p_inc_inv_curr(k));

				vPLSQL := 'select del.delinquency_id, ' ||
				'	   del.transaction_id, ' ||
				'	   del.payment_schedule_id ' ||
				'    from iex_delinquencies del ' ||
				'	 ,ar_payment_schedules arp ' ||
				'    where ' ||
				'    del.payment_schedule_id = arp.payment_schedule_id and ' ||
				'    del.status in (''DELINQUENT'',''PREDELINQUENT'') ' ||
				'    and del.staged_dunning_level = :p_stage_no ' ||
				'    and arp.invoice_currency_code = :p_inv_curr ' ||
				'    and nvl(arp.amount_in_dispute,0) = decode(:p_include_dis_items, ''Y'', nvl(arp.amount_in_dispute,0), 0) ' ||
				'    and nvl( ' ||
				'	( ' ||
				'	 (select trunc(correspondence_date) from iex_dunnings  ' ||
				'	  where dunning_id = ' ||
				'	   (select max(iet.DUNNING_ID) from iex_dunning_transactions iet, ' ||
				'                                               iex_dunnings dunn ' ||
				'	    where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id ' ||
				'                    and dunn.dunning_id = iet.dunning_id ' ||
				'                    and ((dunn.dunning_mode = ''DRAFT'' and dunn.confirmation_mode = ''CONFIRMED'') ' ||
				'                            OR (dunn.dunning_mode = ''FINAL'')) ' ||
				'	    and iet.STAGE_NUMBER = :p_stage_no and dunn.delivery_status is null)) ' ||
				'	    + :p_min_days_bw_dun ) ' ||
				'	    , :p_corr_date ) ' ||
				'	    <= :p_corr_date ';

				if (p_running_level = 'CUSTOMER') then
				      vPLSQL3		:= '    and del.party_cust_id = :p_party_id ' ||
							   '    order by del.payment_schedule_id';
				elsif  (p_running_level = 'ACCOUNT') then
				      vPLSQL3		:= '    and del.cust_account_id = :p_cust_acct_id ' ||
				                           '    order by del.payment_schedule_id';
				elsif  (p_running_level = 'BILL_TO') then
				      vPLSQL3		:= '    and del.customer_site_use_id = :p_site_use_id ' ||
				                           '    order by del.payment_schedule_id';
				end if;
				vPLSQL	:= vPLSQL || vPLSQL3;

				open sql_cur for vPLSQL using l_stage,
				                            p_inc_inv_curr(k),
							    p_include_dispute_items,
							    l_stage,
							    l_dunning_plan_lines.min_days_between_dunning,
							    p_correspondence_date,
							    p_correspondence_date,
							    l_object_id;
				loop
				      fetch sql_cur into l_delinquency_id, l_transaction_id, l_payment_schedule_id;
				      exit when sql_cur%notfound;

				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');
				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur.l_delinquency_id :'||l_delinquency_id);
				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur.l_transaction_id :'||l_transaction_id);
				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur.l_payment_schedule_id : '||l_payment_schedule_id);

				      IEX_Dunnings_PKG.insert_staged_dunning_row(
					  px_rowid                          => l_rowid
					, px_dunning_trx_id                 => x_dunning_trx_id
					, p_dunning_id                      => p_dunning_id
					, p_cust_trx_id                     => l_transaction_id
					, p_payment_schedule_id             => l_payment_schedule_id
					, p_ag_dn_xref_id                   => p_ag_dn_xref_id
					, p_stage_number                    => i
					, p_created_by                      => FND_GLOBAL.USER_ID
					, p_creation_date                   => sysdate
					, p_last_updated_by                 => FND_GLOBAL.USER_ID
					, p_last_update_date                => sysdate
					, p_last_update_login               => FND_GLOBAL.USER_ID
					, p_object_version_number	    => 1.0
				      );

				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_dunning_trx_id :'|| x_dunning_trx_id);

				      IF x_return_status = FND_API.G_RET_STS_ERROR then
						raise FND_API.G_EXC_ERROR;
				      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
					       raise FND_API.G_EXC_UNEXPECTED_ERROR;
				      END IF;

				      /*
				      if p_dunning_mode <> 'DRAFT' then
					      update iex_delinquencies_all
					      set staged_dunning_level = i
					      where delinquency_id = l_delinquency_id;
				      end if;
				      */

				      --reset the x_dunning_trx_id, so that will get new no when inserting 2nd record.
				      x_dunning_trx_id	:= null;

				end loop;
				close sql_cur;


				--Include past due fully disputed invoices
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start Include past due fully disputed invoices');
				vPLSQL1 := 'select del.delinquency_id, ' ||
					'	   del.transaction_id, ' ||
					'	   del.payment_schedule_id ' ||
					'    from iex_delinquencies del ' ||
					'	 ,ar_payment_schedules arp ' ||
					'    where  ' ||
					'    del.payment_schedule_id = arp.payment_schedule_id and ' ||
					'    del.status = ''CURRENT'' ' ||
					'    and del.staged_dunning_level = :p_stage_no ' ||
					'    and arp.status = ''OP'' ' ||
					'    and arp.class = ''INV'' ' ||
					'    and arp.invoice_currency_code = :p_inv_curr ' ||
					'    and arp.amount_in_dispute >= decode(:p_include_dis_items, ''Y'', arp.amount_due_remaining, (arp.amount_due_original + 1)) ' ||
					'    and nvl( ' ||
					'	( ' ||
					'	 (select trunc(correspondence_date) from iex_dunnings  ' ||
					'	  where dunning_id = ' ||
					'	   (select max(iet.DUNNING_ID) from iex_dunning_transactions iet, ' ||
					'                                           iex_dunnings dunn ' ||
					'	    where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id ' ||
					'                    and dunn.dunning_id = iet.dunning_id ' ||
					'                    and ((dunn.dunning_mode = ''DRAFT'' and dunn.confirmation_mode = ''CONFIRMED'') ' ||
					'                            OR (dunn.dunning_mode = ''FINAL'')) ' ||
					'	    and iet.STAGE_NUMBER = :p_stage_no and dunn.delivery_status is null)) ' ||
					'	    + :p_min_days_bw_dun ) ' ||
					'	    , :p_corr_date ) ' ||
					'	    <= :p_corr_date';

				vPLSQL1	:= vPLSQL1 || vPLSQL3;

				open sql_cur1 for vPLSQL1 using l_stage,
								p_inc_inv_curr(k),
								p_include_dispute_items,
								l_stage,
								l_dunning_plan_lines.min_days_between_dunning,
								p_correspondence_date,
								p_correspondence_date,
							        l_object_id;
				loop
				      fetch sql_cur1 into l_delinquency_id, l_transaction_id, l_payment_schedule_id;
				      exit when sql_cur1%notfound;

				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');
				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur1.l_delinquency_id :'||l_delinquency_id);
				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur1.l_transaction_id :'||l_transaction_id);
				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur1.l_payment_schedule_id : '||l_payment_schedule_id);

				      IEX_Dunnings_PKG.insert_staged_dunning_row(
					  px_rowid                          => l_rowid
					, px_dunning_trx_id                 => x_dunning_trx_id
					, p_dunning_id                      => p_dunning_id
					, p_cust_trx_id                     => l_transaction_id
					, p_payment_schedule_id             => l_payment_schedule_id
					, p_ag_dn_xref_id                   => p_ag_dn_xref_id
					, p_stage_number                    => i
					, p_created_by                      => FND_GLOBAL.USER_ID
					, p_creation_date                   => sysdate
					, p_last_updated_by                 => FND_GLOBAL.USER_ID
					, p_last_update_date                => sysdate
					, p_last_update_login               => FND_GLOBAL.USER_ID
					, p_object_version_number	    => 1.0
				      );

				      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_dunning_trx_id :'|| x_dunning_trx_id);

				      IF x_return_status = FND_API.G_RET_STS_ERROR then
						raise FND_API.G_EXC_ERROR;
				      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
					       raise FND_API.G_EXC_UNEXPECTED_ERROR;
				      END IF;

				      /*
				      if p_dunning_mode <> 'DRAFT' then
					      update iex_delinquencies_all
					      set staged_dunning_level = i
					      where delinquency_id = l_delinquency_id;
				      end if;
				      */

				      --reset the x_dunning_trx_id, so that will get new no when inserting 2nd record.
				      x_dunning_trx_id	:= null;

				end loop;
				close sql_cur1;

			end loop;
			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End Include past due fully disputed invoices');
		end if;

      end loop;

      open c_dunn_plan_line_dtls (p_ag_dn_xref_id);
      fetch c_dunn_plan_line_dtls into l_include_curr_inv, l_include_unapp_rec;
      close c_dunn_plan_line_dtls;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Insert current invoices');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - g_included_current_invs: '|| g_included_current_invs);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_include_curr_inv: '|| l_include_curr_inv);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_include_unapp_rec: '|| l_include_unapp_rec);

      if (g_included_current_invs = 'N') and (l_include_curr_inv = 'Y') then
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start insert current invoices');

		if (p_running_level = 'CUSTOMER') then
			vPLSQL2 := 'select arp.customer_trx_id, ' ||
				'	   arp.payment_schedule_id ' ||
				'    from ar_payment_schedules arp, ' ||
				'         hz_cust_accounts hca ' ||
				'    where arp.customer_id = hca.cust_account_id ' ||
				'    and hca.party_id = :p_party_id ' ||
				'    and trunc(arp.due_date) > trunc(:p_corr_date) ' ||
				'    and arp.status = ''OP'' ' ||
				'    and arp.amount_due_remaining > 0 ' ||
				'    and arp.class = ''INV'' ' ||
				'    and nvl(arp.amount_in_dispute,0) = decode(:p_include_dis_items, ''Y'', nvl(arp.amount_in_dispute,0), 0) ' ||
				'    and not exists (select 1 from iex_delinquencies del where del.payment_schedule_id = arp.payment_schedule_id) ' ||
				'    order by arp.payment_schedule_id';
		elsif  (p_running_level = 'ACCOUNT') then
		      vPLSQL2 := 'select arp.customer_trx_id, ' ||
				'	   arp.payment_schedule_id ' ||
				'    from ar_payment_schedules arp ' ||
				'    where arp.customer_id = :p_cust_acct_id ' ||
				'    and trunc(arp.due_date) > trunc(:p_corr_date) ' ||
				'    and arp.status = ''OP'' ' ||
				'    and arp.amount_due_remaining > 0 ' ||
				'    and arp.class = ''INV'' ' ||
				'    and nvl(arp.amount_in_dispute,0) = decode(:p_include_dis_items, ''Y'', nvl(arp.amount_in_dispute,0), 0) ' ||
				'    and not exists (select 1 from iex_delinquencies del where del.payment_schedule_id = arp.payment_schedule_id) ' ||
				'    order by arp.payment_schedule_id';
		elsif  (p_running_level = 'BILL_TO') then
		      vPLSQL2 := 'select arp.customer_trx_id, ' ||
				'	   arp.payment_schedule_id ' ||
				'    from ar_payment_schedules arp ' ||
				'    where arp.customer_site_use_id = :p_site_use_id ' ||
				'    and trunc(arp.due_date) > trunc(:p_corr_date) ' ||
				'    and arp.status = ''OP'' ' ||
				'    and arp.amount_due_remaining > 0 ' ||
				'    and arp.class = ''INV'' ' ||
				'    and nvl(arp.amount_in_dispute,0) = decode(:p_include_dis_items, ''Y'', nvl(arp.amount_in_dispute,0), 0) ' ||
				'    and not exists (select 1 from iex_delinquencies del where del.payment_schedule_id = arp.payment_schedule_id) ' ||
				'    order by arp.payment_schedule_id';
		end if;

		open sql_cur2 for vPLSQL2 using l_object_id,
					    p_correspondence_date,
					    p_include_dispute_items;
		loop
		      fetch sql_cur2 into l_customer_trx_id, l_payment_schedule_id;
		      exit when sql_cur2%notfound;

		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur2.l_customer_trx_id :'||l_customer_trx_id);
		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur2.l_payment_schedule_id : '||l_payment_schedule_id);

		      IEX_Dunnings_PKG.insert_staged_dunning_row(
			  px_rowid                          => l_rowid
			, px_dunning_trx_id                 => x_dunning_trx_id
			, p_dunning_id                      => p_dunning_id
			, p_cust_trx_id                     => l_customer_trx_id
			, p_payment_schedule_id             => l_payment_schedule_id
			, p_ag_dn_xref_id                   => p_ag_dn_xref_id
			, p_stage_number                    => null
			, p_created_by                      => FND_GLOBAL.USER_ID
			, p_creation_date                   => sysdate
			, p_last_updated_by                 => FND_GLOBAL.USER_ID
			, p_last_update_date                => sysdate
			, p_last_update_login               => FND_GLOBAL.USER_ID
			, p_object_version_number	    => 1.0
		      );

		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_dunning_trx_id :'|| x_dunning_trx_id);

		      IF x_return_status = FND_API.G_RET_STS_ERROR then
				raise FND_API.G_EXC_ERROR;
		      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
			       raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      END IF;

		      --reset the x_dunning_trx_id, so that will get new no when inserting 2nd record.
		      x_dunning_trx_id	:= null;
		end loop;
		close sql_cur2;

	--Setting the variable to 'Y', so that current invoices won't be include in further stage letters for this
	--customer/account/Bill to/Delinquency
	g_included_current_invs:= 'Y';
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End insert current invoices');
      end if;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Insert unapplied receipts and On Account Credit memos');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - g_included_unapplied_rec: '|| g_included_unapplied_rec);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_include_unapp_rec: '|| l_include_unapp_rec);

      if (g_included_unapplied_rec = 'N') and (l_include_unapp_rec = 'Y') then
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start insert unapplied receipts');

		if (p_running_level = 'CUSTOMER') then
			vPLSQL2 := 'select arp.payment_schedule_id ' ||
				'    from ar_payment_schedules arp, ' ||
				'         hz_cust_accounts hca ' ||
				'    where arp.customer_id = hca.cust_account_id ' ||
				'    and hca.party_id = :p_party_id ' ||
				'    and arp.status = ''OP'' ' ||
			        '    and arp.amount_due_remaining <> 0 ' ||
			        '    and arp.class = ''PMT'' ' ||
			        '    order by arp.payment_schedule_id';
		elsif  (p_running_level = 'ACCOUNT') then
		      vPLSQL2 := 'select arp.payment_schedule_id ' ||
				    ' from ar_payment_schedules arp ' ||
				    ' where arp.customer_id = :p_cust_acct_id ' ||
				    ' and arp.status = ''OP'' ' ||
				    ' and arp.amount_due_remaining <> 0 ' ||
				    ' and arp.class = ''PMT'' ' ||
				    ' order by arp.payment_schedule_id';
		elsif  (p_running_level = 'BILL_TO') then
		      vPLSQL2 := 'select arp.payment_schedule_id ' ||
				    ' from ar_payment_schedules arp ' ||
				    ' where arp.customer_site_use_id = :p_site_use_id ' ||
				    ' and arp.status = ''OP'' ' ||
				    ' and arp.amount_due_remaining <> 0 ' ||
				    ' and arp.class = ''PMT'' ' ||
				    ' order by arp.payment_schedule_id';
		end if;

		open sql_cur2 for vPLSQL2 using l_object_id;
		loop
		      fetch sql_cur2 into l_payment_schedule_id;
		      exit when sql_cur2%notfound;

		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur2.l_payment_schedule_id : '||l_payment_schedule_id);

		      IEX_Dunnings_PKG.insert_staged_dunning_row(
			  px_rowid                          => l_rowid
			, px_dunning_trx_id                 => x_dunning_trx_id
			, p_dunning_id                      => p_dunning_id
			--, p_cust_trx_id                     => l_customer_trx_id
			, p_payment_schedule_id             => l_payment_schedule_id
			, p_ag_dn_xref_id                   => p_ag_dn_xref_id
			, p_stage_number                    => null
			, p_created_by                      => FND_GLOBAL.USER_ID
			, p_creation_date                   => sysdate
			, p_last_updated_by                 => FND_GLOBAL.USER_ID
			, p_last_update_date                => sysdate
			, p_last_update_login               => FND_GLOBAL.USER_ID
			, p_object_version_number	    => 1.0
		      );

		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_dunning_trx_id :'|| x_dunning_trx_id);

		      IF x_return_status = FND_API.G_RET_STS_ERROR then
				raise FND_API.G_EXC_ERROR;
		      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
			       raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      END IF;

		      --reset the x_dunning_trx_id, so that will get new no when inserting 2nd record.
		      x_dunning_trx_id	:= null;

		end loop;
		close sql_cur2;

	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End insert unapplied receipts');

	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start insert On Account Credit memos');

	if (p_running_level = 'CUSTOMER') then
			vPLSQL2 := 'select arp.customer_trx_id customer_trx_id, ' ||
			        '          arp.payment_schedule_id ' ||
				'    from ar_payment_schedules arp, ' ||
				'         hz_cust_accounts hca ' ||
				'    where arp.customer_id = hca.cust_account_id ' ||
				'    and hca.party_id = :p_party_id ' ||
				'    and arp.amount_due_remaining <> 0 ' ||
				'    and arp.class =''CM'' ' ||
				'    and arp.status=''OP'' ';
		elsif  (p_running_level = 'ACCOUNT') then
		      vPLSQL2 := 'select arp.customer_trx_id customer_trx_id, ' ||
			            '    arp.payment_schedule_id ' ||
				    ' from ar_payment_schedules arp ' ||
				    ' where arp.customer_id = :p_cust_acct_id ' ||
				    '    and arp.amount_due_remaining <> 0 ' ||
				    '    and arp.class =''CM'' ' ||
				    '    and arp.status=''OP'' ';
		elsif  (p_running_level = 'BILL_TO') then
		      vPLSQL2 := 'select arp.customer_trx_id customer_trx_id, ' ||
			            '    arp.payment_schedule_id ' ||
				    ' from ar_payment_schedules arp ' ||
				    ' where arp.customer_site_use_id = :p_site_use_id ' ||
				    '    and arp.amount_due_remaining <> 0 ' ||
				    '    and arp.class =''CM'' ' ||
				    '    and arp.status=''OP'' ';
		end if;

		open sql_cur2 for vPLSQL2 using l_object_id;
		loop
		      fetch sql_cur2 into l_customer_trx_id, l_payment_schedule_id;
		      exit when sql_cur2%notfound;

		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur2.l_customer_trx_id :'||l_customer_trx_id);
		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - sql_cur2.l_payment_schedule_id : '||l_payment_schedule_id);

		      IEX_Dunnings_PKG.insert_staged_dunning_row(
			  px_rowid                          => l_rowid
			, px_dunning_trx_id                 => x_dunning_trx_id
			, p_dunning_id                      => p_dunning_id
			, p_cust_trx_id                     => l_customer_trx_id
			, p_payment_schedule_id             => l_payment_schedule_id
			, p_ag_dn_xref_id                   => p_ag_dn_xref_id
			, p_stage_number                    => null
			, p_created_by                      => FND_GLOBAL.USER_ID
			, p_creation_date                   => sysdate
			, p_last_updated_by                 => FND_GLOBAL.USER_ID
			, p_last_update_date                => sysdate
			, p_last_update_login               => FND_GLOBAL.USER_ID
			, p_object_version_number	    => 1.0
		      );

		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_dunning_trx_id :'|| x_dunning_trx_id);

		      IF x_return_status = FND_API.G_RET_STS_ERROR then
				raise FND_API.G_EXC_ERROR;
		      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
			       raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      END IF;

		      --reset the x_dunning_trx_id, so that will get new no when inserting 2nd record.
		      x_dunning_trx_id	:= null;
	      end loop;
	      close sql_cur2;


	--Setting the variable to 'Y', so that current invoices won't be include in further stage letters for this
	--customer/account/Bill to/Delinquency
	g_included_unapplied_rec:= 'Y';
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End insert On Account Credit memos');
      end if;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END');
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO CREATE_STAGED_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || 'exception ' || SQLERRM);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO CREATE_STAGED_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || 'error ' || SQLERRM);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO CREATE_STAGED_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || 'error ' || SQLERRM);

END CREATE_STAGED_DUNNING;

Procedure Update_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_Dunning_REC             IN IEX_DUNNING_PUB.DUNNING_REC_TYPE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS
    --Start adding for bug 8489610 by gnramasa 14-May-09
    CURSOR C_get_DUNNING_Rec (IN_DUNNING_ID NUMBER) is
       select  ROWID,
               DUNNING_ID,
               TEMPLATE_ID,
               CALLBACK_YN,
               CALLBACK_DATE,
               CAMPAIGN_SCHED_ID,
               STATUS,
               DELINQUENCY_ID,
               FFM_REQUEST_ID,
               XML_REQUEST_ID,
               XML_TEMPLATE_ID,
               OBJECT_ID,
               OBJECT_TYPE,
               DUNNING_OBJECT_ID,
               DUNNING_LEVEL,
               DUNNING_METHOD,
               AMOUNT_DUE_REMAINING,
               CURRENCY_CODE,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY ,
               LAST_UPDATE_LOGIN,
               delivery_status,
               PARENT_DUNNING_ID,
               financial_charge,   -- bug 3955222
               letter_name,   -- bug 3955222
               interest_amt,   -- bug 3955222
               dunning_plan_id,   -- bug 3955222
               contact_destination,   -- bug 3955222
               contact_party_id,   -- bug 3955222
	       dunning_mode,
	       confirmation_mode,
	       request_id,
	       ag_dn_xref_id,
	       correspondence_date
         from iex_DUNNINGS
        where dunning_id = in_dunning_id
        FOR UPDATE NOWAIT;
    --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Update_DUNNING';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_DUNNING_REC                 IEX_DUNNING_PUB.DUNNING_REC_TYPE ;
    l_dunning_id                  NUMBER ;
    l_DUNNING_REF_REC             IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    errmsg                        VARCHAR2(32767);


BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_dunning_PVT;

      l_dunning_rec := p_dunning_rec;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - START');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- Api body
      --
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Open C_GET_DUNNING_REC');
      WriteLog('l_dunning_rec.dunning_ID: '||l_dunning_rec.dunning_ID);


      Open C_Get_DUNNING_Rec(l_dunning_rec.dunning_ID);
      Fetch C_Get_DUNNING_Rec into
         l_rowid,
         l_DUNNING_REF_REC.DUNNING_ID,
         l_DUNNING_REF_REC.template_id,
         l_DUNNING_REF_REC.callback_YN,
         l_DUNNING_REF_REC.callback_Date,
         l_DUNNING_REF_REC.campaign_sched_id,
         l_DUNNING_REF_REC.status,
         l_DUNNING_REF_REC.delinquency_id,
         l_DUNNING_REF_REC.ffm_request_id,
         l_DUNNING_REF_REC.xml_request_id,
         l_DUNNING_REF_REC.xml_template_id,
         l_DUNNING_REF_REC.object_id,
         l_DUNNING_REF_REC.object_type,
         l_DUNNING_REF_REC.dunning_object_id,
         l_DUNNING_REF_REC.dunning_level,
         l_DUNNING_REF_REC.dunning_method,
         l_DUNNING_REF_REC.amount_due_remaining,
         l_DUNNING_REF_REC.currency_code,
         l_DUNNING_REF_REC.LAST_UPDATE_DATE,
         l_DUNNING_REF_REC.LAST_UPDATED_BY,
         l_DUNNING_REF_REC.CREATION_DATE,
         l_DUNNING_REF_REC.CREATED_BY,
         l_DUNNING_REF_REC.LAST_UPDATE_LOGIN,
         l_DUNNING_REF_REC.delivery_status,
         l_DUNNING_REF_REC.parent_dunning_id,
         l_DUNNING_REF_REC.financial_charge,  -- bug 3955222
         l_DUNNING_REF_REC.letter_name,  -- bug 3955222
         l_DUNNING_REF_REC.interest_amt,  -- bug 3955222
         l_DUNNING_REF_REC.dunning_plan_id,  -- bug 3955222
         l_DUNNING_REF_REC.contact_destination,  -- bug 3955222
         l_DUNNING_REF_REC.contact_party_id,  -- bug 3955222
	 l_DUNNING_REF_REC.dunning_mode,
	 l_DUNNING_REF_REC.confirmation_mode,
	 l_DUNNING_REF_REC.request_id,
	 l_DUNNING_REF_REC.ag_dn_xref_id,
	 l_DUNNING_REF_REC.correspondence_date;

      If ( C_GET_DUNNING_REC%NOTFOUND) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_DUNNINGs', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CLOSE C_GET_DUNNING_REC');
      Close C_Get_DUNNING_REC;
-- Start bug 5924158 05/06/07 by gnramasa
   /*
      If (l_dunning_rec.last_update_date is NULL or
         l_dunning_rec.last_update_date = FND_API.G_MISS_Date )
      Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
*/
-- End bug 5924158 05/06/07 by gnramasa
      -- Transfer Data into target record
      l_dunning_rec.CREATION_DATE       := l_dunning_ref_rec.CREATION_DATE;
      l_dunning_rec.CREATED_BY          := l_dunning_ref_rec.CREATED_BY;
      l_dunning_rec.delinquency_id      := l_dunning_ref_rec.delinquency_id;
      --l_dunning_rec.ffm_request_id := l_dunning_ref_rec.ffm_request_id;
      l_dunning_rec.dunning_method      := l_dunning_ref_rec.dunning_method;

      --Start bug 9503251 gnramasa 22nd Apr 2010
      IF (l_dunning_rec.amount_due_remaining = FND_API.G_MISS_NUM OR
          l_dunning_rec.amount_due_remaining is null) Then
         l_dunning_rec.amount_due_remaining := l_dunning_ref_rec.amount_due_remaining;
      END IF;
      IF (l_dunning_rec.currency_code = FND_API.G_MISS_CHAR OR
          l_dunning_rec.currency_code is null) Then
         l_dunning_rec.currency_code := l_dunning_ref_rec.currency_code;
      END IF;
      --End bug 9503251 gnramasa 22nd Apr 2010

      l_dunning_rec.dunning_object_id 	 := l_dunning_ref_rec.dunning_object_id;
      l_dunning_rec.dunning_level 			 := l_dunning_ref_rec.dunning_level;
      l_dunning_rec.financial_charge 		 := l_dunning_ref_rec.financial_charge;  -- bug 3955222
      l_dunning_rec.letter_name 				 := l_dunning_ref_rec.letter_name;  -- bug 3955222
      l_dunning_rec.interest_amt 				 := l_dunning_ref_rec.interest_amt;  -- bug 3955222
      l_dunning_rec.dunning_plan_id 		 := l_dunning_ref_rec.dunning_plan_id;  -- bug 3955222
      --l_dunning_rec.delivery_status   	 := l_dunning_ref_rec.delivery_status;
      --l_dunning_rec.parent_dunning_id    := l_dunning_ref_rec.parent_dunning_id;

      -- dont update dunning_id and delinquency_id
      -- dont update dunning_method
      -- dont update dunning_object_id and dunning_level

      IF (l_dunning_rec.xml_request_id = FND_API.G_MISS_NUM OR
          l_dunning_rec.xml_request_id is null) Then
         l_dunning_rec.xml_request_id := l_dunning_ref_rec.xml_request_id;
      END IF;
      IF (l_dunning_rec.xml_template_id = FND_API.G_MISS_NUM OR
          l_dunning_rec.xml_template_id is null) Then
         l_dunning_rec.xml_template_id := l_dunning_ref_rec.xml_template_id;
      END IF;
      IF (l_dunning_rec.ffm_request_id = FND_API.G_MISS_NUM OR
          l_dunning_rec.ffm_request_id is null) Then
         l_dunning_rec.ffm_request_id := l_dunning_ref_rec.ffm_request_id;
      END IF;
      IF (l_dunning_rec.callback_YN = FND_API.G_MISS_CHAR or
          l_dunning_rec.callback_YN is null ) Then
         l_dunning_rec.callback_YN := l_dunning_ref_rec.callback_YN;
      END IF;
      IF (l_dunning_rec.callback_date = FND_API.G_MISS_DATE or
          l_dunning_rec.callback_date is null ) Then
         l_dunning_rec.callback_date := l_dunning_ref_rec.callback_date;
      END IF;
      IF (l_dunning_rec.status = FND_API.G_MISS_CHAR or
          l_dunning_rec.status is null ) Then
         l_dunning_rec.status := l_dunning_ref_rec.status;
      END IF;
      IF (l_dunning_rec.template_ID = FND_API.G_MISS_NUM or
          l_dunning_rec.template_id is null ) Then
         l_dunning_rec.template_ID := l_dunning_ref_rec.template_ID;
      END IF;
      IF (l_dunning_rec.campaign_sched_id = FND_API.G_MISS_NUM or
          l_dunning_rec.campaign_sched_id is null ) Then
         l_dunning_rec.campaign_sched_id := l_dunning_ref_rec.campaign_sched_id;
      END IF;
       IF (l_dunning_rec.object_ID = FND_API.G_MISS_NUM or
          l_dunning_rec.object_id is null ) Then
         l_dunning_rec.object_ID := l_dunning_ref_rec.object_ID;
      END IF;
      IF (l_dunning_rec.object_type = FND_API.G_MISS_CHAR or
          l_dunning_rec.object_type is null ) Then
         l_dunning_rec.object_type := l_dunning_ref_rec.object_type;
      END IF;
      IF (l_dunning_rec.delivery_status = FND_API.G_MISS_CHAR or
          l_dunning_rec.delivery_status is null ) Then
         l_dunning_rec.delivery_status := l_dunning_ref_rec.delivery_status;
      END IF;
      IF (l_dunning_rec.PARENT_DUNNING_ID = FND_API.G_MISS_NUM or
          l_dunning_rec.PARENT_DUNNING_ID is null ) Then
         l_dunning_rec.PARENT_DUNNING_ID := l_dunning_ref_rec.PARENT_DUNNING_ID;
      END IF;

      -- begin bug 3955222 ctlee 10/05/2005
      IF (l_dunning_rec.contact_destination = FND_API.G_MISS_CHAR or
          l_dunning_rec.contact_destination is null ) Then
         l_dunning_rec.contact_destination := l_dunning_ref_rec.contact_destination;
      END IF;

      IF (l_dunning_rec.contact_party_id = FND_API.G_MISS_NUM or
          l_dunning_rec.contact_party_id is null ) Then
         l_dunning_rec.contact_party_id := l_dunning_ref_rec.contact_party_id;
      END IF;

      IF (l_dunning_rec.dunning_mode = FND_API.G_MISS_CHAR or
          l_dunning_rec.dunning_mode is null ) Then
         l_dunning_rec.dunning_mode := l_dunning_ref_rec.dunning_mode;
      END IF;

      IF (l_dunning_rec.confirmation_mode = FND_API.G_MISS_CHAR or
          l_dunning_rec.confirmation_mode is null ) Then
         l_dunning_rec.confirmation_mode := l_dunning_ref_rec.confirmation_mode;
      END IF;

      IF (l_dunning_rec.request_id = FND_API.G_MISS_NUM or
          l_dunning_rec.request_id is null ) Then
         l_dunning_rec.request_id := l_dunning_ref_rec.request_id;
      END IF;

      IF (l_dunning_rec.ag_dn_xref_id = FND_API.G_MISS_NUM or
          l_dunning_rec.ag_dn_xref_id is null ) Then
         l_dunning_rec.ag_dn_xref_id := l_dunning_ref_rec.ag_dn_xref_id;
      END IF;

      IF (l_dunning_rec.correspondence_date = FND_API.G_MISS_DATE or
          l_dunning_rec.correspondence_date is null ) Then
         l_dunning_rec.correspondence_date := l_dunning_ref_rec.correspondence_date;
      END IF;

      -- end bug 3955222 ctlee 10/05/2005
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Update Row');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunningid='||l_dunning_rec.dunning_id );
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delivery_status= ' || l_dunning_rec.delivery_status);

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_rec.dunning_mode= ' || l_dunning_rec.dunning_mode);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_rec.confirmation_mode= ' || l_dunning_rec.confirmation_mode);

          -- Invoke table handler
          IEX_DUNNINGS_PKG.Update_Row(
             p_rowid                          => l_rowid
           , p_dunning_id                     => l_dunning_rec.dunning_id
           , p_last_update_date               => sysdate
           , p_last_updated_by                => FND_GLOBAL.USER_ID
           , p_creation_date                  => l_dunning_rec.creation_date
           , p_created_by                     => l_dunning_rec.created_by
           , p_last_update_login              => FND_GLOBAL.USER_ID
					 --, p_request_id                     => FND_GLOBAL.CONC_REQUEST_ID
	   , p_request_id                     => l_dunning_rec.request_id
           , p_template_id                    => l_dunning_rec.template_id
           , p_callback_yn                    => l_dunning_rec.callback_yn
           , p_callback_date                  => l_dunning_rec.callback_date
           , p_campaign_sched_id              => l_dunning_rec.campaign_sched_id
           , p_status                         => l_dunning_rec.status
           , p_delinquency_id                 => l_dunning_rec.delinquency_id
           , p_ffm_request_id                 => l_dunning_rec.ffm_request_id
           , p_xml_request_id                 => l_dunning_rec.xml_request_id
           , p_xml_template_id                => l_dunning_rec.xml_template_id
           , p_object_id                      => l_dunning_rec.object_id
           , p_object_type                    => l_dunning_rec.object_type
           , p_dunning_object_id              => l_dunning_rec.dunning_object_id
           , p_dunning_level                  => l_dunning_rec.dunning_level
           , p_dunning_method                 => l_dunning_rec.dunning_method
           , p_amount_due_remaining           => l_dunning_rec.amount_due_remaining
           , p_currency_code                  => l_dunning_rec.currency_code
           , p_delivery_status                => l_dunning_rec.delivery_status
           , p_parent_dunning_id              => l_dunning_rec.PARENT_DUNNING_ID
           , p_financial_charge               => l_dunning_rec.financial_charge   -- bug 3955222
           , p_letter_name                    => l_dunning_rec.letter_name   -- bug 3955222
           , p_interest_amt                   => l_dunning_rec.interest_amt   -- bug 3955222
           , p_dunning_plan_id                => l_dunning_rec.dunning_plan_id   -- bug 3955222
           , p_contact_destination            => l_dunning_rec.contact_destination   -- bug 3955222
           , p_contact_party_id               => l_dunning_rec.contact_party_id   -- bug 3955222
	   , p_dunning_mode		      => l_dunning_rec.dunning_mode
	   , p_confirmation_mode              => l_dunning_rec.confirmation_mode
	   , p_ag_dn_xref_id                  => l_dunning_rec.ag_dn_xref_id
	   , p_correspondence_date            => l_dunning_rec.correspondence_date

          );
	  --End adding for bug 8489610 by gnramasa 14-May-09

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO UPDATE_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception error='||SQLERRM);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO UPDATE_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception error='||SQLERRM);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO UPDATE_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception error='||SQLERRM);

END Update_DUNNING;




/*=========================================================================
   clchang update 10/16/2002 -
    Send Dunning can be in Customer, Account and Delinquency levels in 11.5.9;
    Send_Level_Dunning is for Customer and Account level;
    Send_Dunning keeps the same, and is for Delinquency Level;
   clchang update 04/21/2003 -
    new level 'BILL_TO' in 11.5.10.
*=========================================================================*/
Procedure Send_Level_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_running_level           IN VARCHAR2,
            p_dunning_plan_id         in number,
            p_resend_flag             IN VARCHAR2,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_parent_request_id       IN NUMBER,
	    p_dunning_mode	      IN VARCHAR2,     -- added by gnramasa for bug 8489610 14-May-09
	    p_confirmation_mode	      IN   VARCHAR2,   -- added by gnramasa for bug 8489610 14-May-09
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_GET_DEL (IN_del_ID NUMBER) IS
      SELECT delinquency_ID
        FROM IEX_DELINQUENCIES
       WHERE delinquency_ID = in_del_ID;
    --
    -- begin bug 4914799 ctlee 12/30/2005 add p_dunning_plan_id
    CURSOR C_GET_SCORE (IN_ID NUMBER, IN_CODE VARCHAR2, p_dunning_plan_id number) IS
      SELECT a.score_value
        FROM IEX_SCORE_HISTORIES a
             , IEX_DUNNING_PLANS_VL c  -- bug 4914799 ctlee 12/30/2005
       WHERE a.score_object_ID = in_ID
         AND a.score_object_code = IN_CODE
         and c.score_id = a.score_id   -- bug 4914799 ctlee 12/30/2005
         and c.dunning_plan_id = p_dunning_plan_id -- bug 4914799 ctlee 12/30/2005
         AND a.creation_date = (select max(b.creation_date)
                                  from iex_score_histories b
                                 where b.score_object_id = in_id
                                   AND b.score_object_code = IN_CODE
				   AND b.score_id = a.score_id );
    -- end bug 4914799 ctlee 12/30/2005 add p_dunning_plan_id

    CURSOR C_GET_TEMPLATE (l_line_id NUMBER,
                           l_score NUMBER, in_LEVEL VARCHAR2, p_dunning_plan_id number) IS
      SELECT x.template_id,
             x.xdo_template_id,
             x.fm_method,
             upper(x.callback_flag),
             x.callback_days
        FROM IEX_AG_DN_XREF x,
             ar_aging_buckets ar,
             iex_dunning_plans_vl d
       WHERE x.aging_bucket_line_ID = l_line_ID
         and x.dunning_plan_id = p_dunning_plan_id
         AND l_score between x.score_range_low and x.score_range_high
         AND x.aging_bucket_id = ar.aging_bucket_id
         and ar.aging_bucket_id = d.aging_bucket_id
         AND ar.status = 'A'
         AND x.dunning_level = IN_LEVEL ;

    --Start bug 7197038 gnramasa 8th july 08
     -- cursor for checking if the number of delinquencies NOT disputed
    /*
    CURSOR C_DISPUTED_AMOUNT(P_PARTY_ID NUMBER, P_CUST_ACCOUNT_ID NUMBER, P_SITE_USE_ID NUMBER ) IS
     select sum(a.amount_in_dispute) - sum(a.amount_due_remaining)
      from iex_delinquencies d
          ,ar_payment_schedules a
     where a.payment_schedule_id  = d.payment_schedule_id
       and d.party_cust_id        = nvl(p_party_id, d.party_cust_id)
       and d.cust_account_id      = nvl(P_CUST_ACCOUNT_ID, d.cust_account_id )
       and d.customer_site_use_id = nvl(p_site_use_id, d.customer_site_use_id )
       and d.status IN ('DELINQUENT', 'PREDELINQUENT');
     */
     CURSOR C_DISPUTED_AMOUNT_PARTY(P_PARTY_ID NUMBER) IS
     select sum(a.amount_in_dispute) - sum(a.amount_due_remaining)
      from iex_delinquencies d
          ,ar_payment_schedules a
     where a.payment_schedule_id  = d.payment_schedule_id
       and d.party_cust_id        = p_party_id
       and d.status IN ('DELINQUENT', 'PREDELINQUENT');

    CURSOR C_DISPUTED_AMOUNT_ACCOUNT(P_CUST_ACCOUNT_ID NUMBER) IS
     select sum(a.amount_in_dispute) - sum(a.amount_due_remaining)
      from iex_delinquencies d
          ,ar_payment_schedules a
     where a.payment_schedule_id  = d.payment_schedule_id
       and d.cust_account_id      = P_CUST_ACCOUNT_ID
       and d.status IN ('DELINQUENT', 'PREDELINQUENT');

    CURSOR C_DISPUTED_AMOUNT_BILLTO(P_SITE_USE_ID NUMBER ) IS
     select sum(a.amount_in_dispute) - sum(a.amount_due_remaining)
      from iex_delinquencies d
          ,ar_payment_schedules a
     where a.payment_schedule_id  = d.payment_schedule_id
       and d.customer_site_use_id = p_site_use_id
       and d.status IN ('DELINQUENT', 'PREDELINQUENT');

    --End bug 7197038 gnramasa 8th july 08

    -- Start for the bug#8408162 by PNAVEENK on 7-4-2009
    cursor c_fully_promised_party(p_party_id number) is
    SELECT count(1)
		FROM ar_payment_schedules_all ps, iex_delinquencies_all del
		WHERE del.party_cust_id=p_party_id
	        AND ps.payment_schedule_id = del.payment_schedule_id
	        AND ps.status = 'OP'
	        AND del.status IN ('DELINQUENT', 'PREDELINQUENT')
		and not exists(select 1
	        from iex_promise_details pd where pd.delinquency_id=del.delinquency_id
		and pd.status='COLLECTABLE'
		and pd.state='PROMISE'
	        group by pd.delinquency_id
		having sum(nvl(pd.promise_amount,0))>=ps.amount_due_remaining);
   cursor c_fully_promised_account(p_cust_account_id number) is
   SELECT count(1)
		FROM ar_payment_schedules_all ps, iex_delinquencies_all del
		WHERE del.cust_account_id=p_cust_account_id
	        AND ps.payment_schedule_id = del.payment_schedule_id
	        AND ps.status = 'OP'
	        AND del.status IN ('DELINQUENT', 'PREDELINQUENT')
		and not exists(select 1
	        from iex_promise_details pd where pd.delinquency_id=del.delinquency_id
		and pd.status='COLLECTABLE'
		and pd.state='PROMISE'
	        group by pd.delinquency_id
		having sum(nvl(pd.promise_amount,0))>=ps.amount_due_remaining);
   cursor c_fully_promised_billto(p_site_use_id number) is
   SELECT count(1)
		FROM ar_payment_schedules_all ps, iex_delinquencies_all del
		WHERE del.customer_site_use_id= p_site_use_id
	        AND ps.payment_schedule_id = del.payment_schedule_id
	        AND ps.status = 'OP'
	        AND del.status IN ('DELINQUENT', 'PREDELINQUENT')
		and not exists(select 1
	        from iex_promise_details pd where pd.delinquency_id=del.delinquency_id
		and pd.status='COLLECTABLE'
		and pd.state='PROMISE'
	        group by pd.delinquency_id
		having sum(nvl(pd.promise_amount,0))>=ps.amount_due_remaining);

    -- End for the bug#8408162 by PNAVEENK on 7-4-2009
    l_DUNNING_id            NUMBER;
    l_delinquency_id        NUMBER;
    l_party_cust_id         NUMBER;
    l_account_id            NUMBER;
    l_customer_site_use_id  NUMBER;
    l_noskip                NUMBER := 0;
    l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_DUNNING_tbl           IEX_DUNNING_PUB.DUNNING_TBL_TYPE;
    l_dunning_rec_upd       IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_score                 NUMBER;
    l_bucket_line_id        NUMBER;
    l_campaign_sched_id     NUMBER;
    l_template_id           NUMBER;
    l_xdo_template_id       NUMBER;
    l_method                VARCHAR2(10);
    l_callback_flag         VARCHAR2(1);
    l_callback_days         NUMBER;
    l_callback_date         DATE;
    l_request_id            NUMBER;
    l_outcome_code          varchar2(20);
    l_api_name              CONSTANT VARCHAR2(30) := 'Send_Level_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);
    --
    nIdx                    NUMBER := 0;
    TYPE Del_ID_TBL_type is Table of IEX_DELINQUENCIES_ALL.DELINQUENCY_ID%TYPE
                            INDEX BY BINARY_INTEGER;
    Del_Tbl                 Del_ID_TBL_TYPE;
    l_bind_tbl              IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
    l_bind_rec              IEX_DUNNING_PVT.FULFILLMENT_BIND_REC;
    l_org_id                NUMBER ;
    l_object_Code           VARCHAR2(25);
    l_object_id             NUMBER;
    --l_delid_tbl             IEX_DUNNING_PUB.DelId_NumList;
    l_del_tbl               IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE;
    l_curr_code             VARCHAR2(15);
    l_amount                NUMBER;
    l_write                 NUMBER;
    l_ffm_cnt               NUMBER := 0;
    l_dunn_cnt              NUMBER := 0;
    l_curr_dmethod          VARCHAR2(10);
    -- begin raverma 03/09/06 add contact point selection
    l_location_id           number;
    l_amount_disputed       number;
    l_contact_id            number;
    l_warning_flag          varchar2(1);
    l_contact_point_id      number;

    l_delinquency_id_check        NUMBER;
    l_party_cust_id_check         NUMBER;
    l_account_id_check            NUMBER;
    l_customer_site_use_id_check  NUMBER;
    l_contact_destination         varchar2(240);  -- bug 3955222
    l_contact_party_id            number; -- bug 3955222
    l_fully_promised              number := 1; -- bug# 8408162
    l_allow_send                  varchar2(1) := 'Y';  -- bug#8408162
    l_status                      varchar2(10);
    --Start adding for bug 9156833 gnramasa 27th Nov 09
    l_validation_level		  NUMBER ;
    l_resource_tab		  iex_utilities.resource_tab_type;
    l_resource_id		  NUMBER;
    --End adding for bug 9156833 gnramasa 27th Nov 09
    l_turnoff_coll_on_bankru	  varchar2(10);
    l_no_of_bankruptcy		  number;

    cursor c_no_of_bankruptcy (p_par_id number)
    is
    select nvl(count(*),0)
    from iex_bankruptcies
    where party_id = p_par_id
    and (disposition_code in ('GRANTED','NEGOTIATION')
         OR (disposition_code is NULL));

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Send_Level_DUNNING_PVT;

      --Bug#4679639 schekuri 20-OCT-2005
      --Value of profile ORG_ID shouldn't be used for getting ORG_ID after MOAC implementation
      --l_org_id := fnd_profile.value('ORG_ID');
      l_org_id:= mo_global.get_current_org_id;
      WriteLog(' org_id in send_level_dunning ' || l_org_id);

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      if (p_resend_flag = 'Y') then
          -- don't write into FILE
          l_write := 0;
      else
          l_write := 1;
      end if;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - running_level = ' || p_running_level);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - resend_flag =   ' || p_resend_flag);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_parent_request_id ' || p_parent_request_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delcnt= ' || p_delinquencies_tbl.count);

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- Api body
      --
      l_turnoff_coll_on_bankru	:= nvl(fnd_profile.value('IEX_TURNOFF_COLLECT_BANKRUPTCY'),'N');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_turnoff_coll_on_bankru: ' || l_turnoff_coll_on_bankru);

      l_party_cust_id := p_delinquencies_tbl(1).party_cust_id;
      l_account_id := p_delinquencies_tbl(1).cust_account_id;
      l_customer_site_use_id := p_delinquencies_tbl(1).customer_site_use_id;

      if (p_running_level = 'CUSTOMER') then
          l_object_Code                     := 'PARTY';
          l_object_id                       := p_delinquencies_tbl(1).party_cust_id;
          l_del_tbl(1).party_cust_id        := p_delinquencies_tbl(1).party_cust_id;
          l_del_tbl(1).cust_account_id      := 0;
          l_del_tbl(1).customer_site_use_id := 0;
          l_amount                          := party_amount_due_remaining(l_object_id);
          l_curr_code                       := party_currency_code(l_object_id);
          --Start bug 7197038 gnramasa 8th july 08
	  /*
	  open C_DISPUTED_AMOUNT(P_PARTY_ID          => p_delinquencies_tbl(1).party_cust_id
                                ,P_CUST_ACCOUNT_ID   => null
                                ,P_SITE_USE_ID       => null);
	  */
	  open C_DISPUTED_AMOUNT_PARTY(p_delinquencies_tbl(1).party_cust_id);
          open c_fully_promised_party (p_delinquencies_tbl(1).party_cust_id);  -- Added for bug# 8408162
      elsif (p_running_level = 'ACCOUNT') then
          l_object_Code                     := 'IEX_ACCOUNT';
          l_object_id                       := p_delinquencies_tbl(1).cust_account_id;
          l_del_tbl(1).party_cust_id        := p_delinquencies_tbl(1).party_cust_id;
          l_del_tbl(1).cust_account_id      := p_delinquencies_tbl(1).cust_account_id;
          l_del_tbl(1).customer_site_use_id := 0;
          l_amount                          := acct_amount_due_remaining(l_object_id);
          l_curr_code                       := acct_currency_code(l_object_id);
          /*
	  open C_DISPUTED_AMOUNT(P_PARTY_ID          => null
                                ,P_CUST_ACCOUNT_ID   => p_delinquencies_tbl(1).party_cust_id
                                ,P_SITE_USE_ID       => null);
	  */
	  open C_DISPUTED_AMOUNT_ACCOUNT(p_delinquencies_tbl(1).cust_account_id);
          open c_fully_promised_account (p_delinquencies_tbl(1).cust_account_id); -- Added for bug#8408162
      elsif (p_running_level = 'BILL_TO') then
          l_object_Code                     := 'IEX_BILLTO';
          l_object_id                       := p_delinquencies_tbl(1).customer_site_use_id;
          l_del_tbl(1).party_cust_id        := p_delinquencies_tbl(1).party_cust_id;
          l_del_tbl(1).cust_account_id      := p_delinquencies_tbl(1).cust_account_id;
          l_del_tbl(1).customer_site_use_id := p_delinquencies_tbl(1).customer_site_use_id;
          l_amount                          := site_amount_due_remaining(l_object_id);
          l_curr_code                       := site_currency_code(l_object_id);
          /*
	  open C_DISPUTED_AMOUNT(P_PARTY_ID          => null
                                ,P_CUST_ACCOUNT_ID   => p_delinquencies_tbl(1).customer_site_use_id
                                ,P_SITE_USE_ID       => null);
	  */
	  open C_DISPUTED_AMOUNT_BILLTO(p_delinquencies_tbl(1).customer_site_use_id);
          open c_fully_promised_billto (p_delinquencies_tbl(1).customer_site_use_id); -- Added for bug#8408162
      end if;


      /*==================================================================
       * l_noskip is used to trace the del data is all disputed or not;
       * if any one del not disputed, then l_noskip=1;
       * if l_noskip=0, then means all del are disputed,
       *    => for this customer/account, skip it;
       * if l_fully_promised =0 and l_allow_send = 'N' then l_noskip=0
       *==================================================================*/
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - counting disputed delinquencies ');
      --fetch C_DISPUTED_AMOUNT into l_amount_disputed;
      --    close C_DISPUTED_AMOUNT;
      if (p_running_level = 'CUSTOMER') then
		fetch C_DISPUTED_AMOUNT_PARTY into l_amount_disputed;
		close C_DISPUTED_AMOUNT_PARTY;
		fetch c_fully_promised_party into l_fully_promised;  -- Added for bug# 8408162
		close c_fully_promised_party;
      elsif (p_running_level = 'ACCOUNT') then
		fetch C_DISPUTED_AMOUNT_ACCOUNT into l_amount_disputed;
		close C_DISPUTED_AMOUNT_ACCOUNT;
		fetch c_fully_promised_account into l_fully_promised; -- Added for bug# 8408162
		close c_fully_promised_account;
      elsif (p_running_level = 'BILL_TO') then
		fetch C_DISPUTED_AMOUNT_BILLTO into l_amount_disputed;
		close C_DISPUTED_AMOUNT_BILLTO;
		fetch c_fully_promised_billto into l_fully_promised; -- Added for bug# 8408162
		close c_fully_promised_billto;
      end if;

      --End bug 7197038 gnramasa 8th july 08
      select fnd_profile.value(nvl('IEX_ALLOW_DUN_FULL_PROMISE','N')) into l_allow_send from dual; -- Added for bug#8408162

      if l_turnoff_coll_on_bankru = 'Y' then
	open c_no_of_bankruptcy (p_delinquencies_tbl(1).party_cust_id);
	fetch c_no_of_bankruptcy into l_no_of_bankruptcy;
	close c_no_of_bankruptcy;
      end if;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_no_of_bankruptcy: ' || l_no_of_bankruptcy);

      if (l_amount_disputed >= 0) OR (p_resend_flag = 'Y' ) or (l_fully_promised = 0 and l_allow_send = 'Y')
          OR (l_turnoff_coll_on_bankru = 'Y' and l_no_of_bankruptcy >0 ) then  -- bug#8408162
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - setting no skip = 0 ');
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_amount_disputed ' || l_amount_disputed);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_resend_flag = ' || p_resend_flag);
           l_noskip := 0;
      ELSE
           l_noskip := 1;
      end if;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - amount disputed less delinquency amount = ' || l_amount_disputed);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_code='||l_object_code);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_id='||l_object_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - party_id='||l_party_cust_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - amount_due_remaining='||l_amount);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - currency_code='||l_curr_code);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_noskip='||l_noskip);

      IF (l_noskip > 0) THEN

         -- init the msg (not including the msg from dispute api)
         FND_MSG_PUB.initialize;


          /*===========================================
           * Get Score From IEX_SCORE_HISTORIES
           * If NotFound => Call API to getScore;
           *===========================================*/
	         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get Score');
	         Open C_Get_SCORE(l_object_id, l_object_Code, p_dunning_plan_id);
	         Fetch C_Get_SCORE into l_score;

	         If ( C_GET_SCORE%NOTFOUND) Then
	              FND_MESSAGE.Set_Name('IEX', 'IEX_NO_SCORE');
	              FND_MSG_PUB.Add;
	              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Missing Score');
	              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  Missing Score');
	              Close C_Get_SCORE;
	              RAISE FND_API.G_EXC_ERROR;
	         END IF;
	         Close C_Get_SCORE;
	         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get Score='||l_score);

          /*===================================================
           * in 11.5.11, support aging bucket line for all level;
           * clchang added 11/20/04.
           * Get Aging_Bucket_Line_id for each party/acct/site
           *===================================================*/

           WriteLog('iexvdunb:SendLevelDunn:GetAgingBucketLineId');

                AGING_DEL(
                  p_api_version              => p_api_version
                , p_init_msg_list            => p_init_msg_list
                , p_commit                   => p_commit
                , p_delinquency_id           => null
                , p_dunning_plan_id          => p_dunning_plan_id
                , p_bucket                   => null
                , p_object_code              => l_object_code
                , p_object_id                => l_object_id
                , x_return_status            => x_return_status
                , x_msg_count                => x_msg_count
                , x_msg_data                 => x_msg_data
                , x_aging_bucket_line_id     => l_bucket_line_id);

         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - AgingDel status='||x_return_status);
         If ( x_return_status <> FND_API.G_RET_STS_SUCCESS) Then
              FND_MESSAGE.Set_Name('IEX', 'IEX_NO_AGINGBUCKETLINE');
              FND_MSG_PUB.Add;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - AgingBucketLineId notfound');
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'AgingBucketLineId NotFound');
              RAISE FND_API.G_EXC_ERROR;
         END IF;
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - lineid='||l_bucket_line_id);

          /*===========================================
           * Get Template_ID From iex_ag_dn_xref
           *===========================================*/

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GET Template');
           Open C_Get_TEMPLATE(l_bucket_line_id, l_score, p_running_level, p_dunning_plan_id);
           Fetch C_Get_TEMPLATE into
                       l_template_id,
                       l_xdo_template_id,
                       l_method,
                       l_callback_flag,
                       l_callback_days;

           If ( C_GET_TEMPLATE%NOTFOUND) Then
                --FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
                --FND_MESSAGE.Set_Token ('INFO', 'Template_ID', FALSE);
                FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Missing corresponding template');
	              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Missing corresponding template');
	              RAISE FND_API.G_EXC_ERROR;
         END IF;

           --WriteLog('iexvdunb:SendLevelDunn:close C_GET_TEMPLATE');
           Close C_Get_TEMPLATE;

        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get ffm_template_id='||l_template_id);
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get xdo_template_id='||l_xdo_template_id);


         /*===========================================
          * Check template
          *  in 11.5.11, IEX supports fulfillment and xml publisher.
          *  if the current setup for delivery id FFM,
          *  then template_id is necessary;
          *  if XML, xdo_template_id is necessary;
          *===========================================*/

         l_curr_dmethod := IEX_SEND_XML_PVT.getCurrDeliveryMethod;
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - curr d_method='||l_curr_dmethod);
         if ( (l_curr_dmethod is null or l_curr_dmethod = '') or
              (l_curr_dmethod = 'FFM' and l_template_id is null)  or
              (l_curr_dmethod = 'XML' and l_xdo_template_id is null ) ) then
              FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
              FND_MSG_PUB.Add;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Missing corresponding template');
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Missing corresponding template');
              RAISE FND_API.G_EXC_ERROR;

         end if;

	       /*===========================================
          * Check profile before send dunning
          *===========================================*/
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  begin check customer profile');

          -- ctlee - check the hz_customer_profiles.dunning_letter
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_party_cust_id = ' || l_party_cust_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_account_id = ' || l_account_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_customer_site_use_id = ' || l_customer_site_use_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_delinquency_id = ' || l_delinquency_id);
            -- ctlee - check the hz_customer_profiles.dunning_letter
            l_party_cust_id_check := l_party_cust_id;
            l_account_id_check := l_account_id;
            l_customer_site_use_id_check := l_customer_site_use_id;
            l_delinquency_id_check := l_delinquency_id;
           if (p_running_level = 'CUSTOMER') then
              l_account_id_check := null;
              l_customer_site_use_id_check := null;
              l_delinquency_id_check := null;
           elsif  (p_running_level = 'ACCOUNT') then
              l_customer_site_use_id_check := null;
              l_delinquency_id_check := null;
           elsif  (p_running_level = 'BILL_TO') then
              l_delinquency_id_check := null;
           end if;
           if ( iex_utilities.DunningProfileCheck (
                   p_party_id => l_party_cust_id_check
                   , p_cust_account_id => l_account_id_check
                   , p_site_use_id => l_customer_site_use_id_check
                   , p_delinquency_id => l_delinquency_id_check     ) = 'N'
              ) then
                FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_PROFILE_NO');
                FND_MSG_PUB.Add;
	              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  Send dunning in customer profile set to no ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Send dunning in customer profile set to no ');
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           end if;


           -- ctlee - check the hz_customer_profiles_amt min_dunning_invoice_amount and min_dunning_amount
           if ( iex_utilities.DunningMinAmountCheck (
                    p_cust_account_id => l_account_id_check
                    , p_site_use_id => l_customer_site_use_id_check)  = 'N'
              ) then
                FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_AMOUNT_MIN');
                FND_MSG_PUB.Add;
	              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  Required min Dunning amount in customer profile ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Required min Dunning amount in customer profile ');
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           end if;

         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  end check customer profile');

	 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  p_dunning_mode :'|| p_dunning_mode);
	 --If dunning mode is draft then don't close the previous duning records.

	 --Start adding for bug 8489610 by gnramasa 14-May-09
	 if p_dunning_mode <> 'DRAFT' then
		  /*===========================================
		   * Close OPEN Dunnings for each party/account
		   *===========================================*/
		  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning');

		 /* if p_dunning_mode = 'DRAFT' then
			l_status := 'CLOSE';
		  else
			l_status := 'OPEN';
		  end if;
                 */
		  Close_DUNNING(
			p_api_version              => p_api_version
		      , p_init_msg_list            => p_init_msg_list
		      , p_commit                   => p_commit
		      , p_delinquencies_tbl        => l_del_tbl
		      , p_running_level            => p_running_level
		      --, p_status                   => l_status
		      , x_return_status            => x_return_status
		      , x_msg_count                => x_msg_count
		      , x_msg_data                 => x_msg_data);

		  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning status='|| x_return_status);

		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Close Dunning');
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Close Dunning');
			x_return_status := FND_API.G_RET_STS_ERROR;
			GOTO end_api;
		  END IF;
		  --WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EndCloseDunn');
	 end if;



          /*===========================================
           * Create Dunning Record
           *===========================================*/
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get CallbackDate');
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag='||l_callback_flag);
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDays='||l_callback_days);

            /*===================================================
             * clchang updated 02/13/2003
             * callback_days could be null if callback_yn = 'N';
             * and if callback_yn = 'N', not get callback_date;
             *==================================================*/
             IF (l_callback_flag = 'Y') THEN

		             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is Y: GetCallbackDate');
		             Get_Callback_Date(p_init_msg_list          => FND_API.G_FALSE
		                              ,p_callback_days          => l_callback_days
		                              ,x_callback_date          => l_callback_date
		                              ,x_return_status          => x_return_status
		                              ,x_msg_count              => x_msg_count
		                              ,x_msg_data               => x_msg_data);

		             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetCallbackDate status='|| x_return_status);

		             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		               FND_MESSAGE.Set_Name('IEX', 'IEX_NO_CALLBACKDATE');
		               FND_MSG_PUB.Add;
		               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot find callback date');
		               FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot find callback date');
		               x_return_status := FND_API.G_RET_STS_ERROR;
		               GOTO end_api;
		             END IF;

             ELSE
                 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is N: NOTGetCallbackDate');

             END IF;


             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDate='||l_callback_date);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Create Dunning');
             l_dunning_rec.dunning_level := p_running_level;
             l_dunning_rec.dunning_object_id := l_object_id;
             l_dunning_rec.callback_yn := l_callback_flag;
             l_dunning_rec.callback_date := l_callback_date;

	     if p_dunning_mode = 'DRAFT' then
		l_dunning_rec.status := 'CLOSE';
	     else
		l_dunning_rec.status := 'OPEN';
	     end if;

             l_dunning_rec.dunning_method := l_method;

             if (l_curr_dmethod = 'FFM') then
                 l_dunning_rec.template_id:= l_template_id;
                 l_dunning_rec.ffm_request_id := l_request_id;
             else
                 l_dunning_rec.xml_template_id:= l_xdo_template_id;
                 l_dunning_rec.xml_request_id := l_request_id;
             end if;
             l_dunning_rec.object_type := l_object_code;
             l_dunning_rec.object_id := l_object_id;
             l_dunning_rec.amount_due_remaining := l_amount;
             l_dunning_rec.currency_code := l_curr_code;
             l_dunning_rec.dunning_plan_id := p_dunning_plan_id;
             l_dunning_rec.contact_destination := l_contact_destination;  -- bug 3955222
             l_dunning_rec.contact_party_id := l_contact_party_id;  -- bug 3955222

	     if p_parent_request_id is not null then
		l_dunning_rec.request_id := p_parent_request_id;
	     else
		l_dunning_rec.request_id := FND_GLOBAL.Conc_Request_Id;
	     end if;

	     --l_dunning_rec.request_id           := FND_GLOBAL.Conc_Request_Id;
	     l_dunning_rec.dunning_mode := p_dunning_mode;
	     l_dunning_rec.confirmation_mode := p_confirmation_mode;
             l_dunning_rec.org_id := l_org_id;  -- added for bug 9151851

             WriteLog( ' before create dunning org_id ' || l_org_id);
             CREATE_DUNNING(
                   p_api_version              => p_api_version
                 , p_init_msg_list            => p_init_msg_list
                 , p_commit                   => p_commit
                 , p_dunning_rec              => l_dunning_rec
                 , x_dunning_id               => l_dunning_id
                 , x_return_status            => x_return_status
                 , x_msg_count                => x_msg_count
                 , x_msg_data                 => x_msg_data);

              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning status='|| x_return_status);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Dunning');
                   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Create Dunning');
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   GOTO end_api;
              END IF;

              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunningId='||l_dunning_id);
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Create Dunning Id='|| l_dunning_id);
              l_dunn_cnt := l_dunn_cnt + 1;

          /*===========================================
           * Send letter thru fulfillment
           *===========================================*/
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SEND_FFM');
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - org_id='||l_org_id);
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - party_id='||l_party_cust_id);
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - method='||l_method);

         l_bind_tbl(1).key_name := 'party_id';
         l_bind_tbl(1).key_type := 'NUMBER';
         l_bind_tbl(1).key_value := l_party_cust_id;
         l_bind_tbl(2).key_name := 'org_id';
         l_bind_tbl(2).key_type := 'NUMBER';
         l_bind_tbl(2).key_value := l_org_id;
         l_bind_tbl(3).key_name := 'account_id';
         l_bind_tbl(3).key_type := 'NUMBER';
         l_bind_tbl(3).key_value := l_account_id;
         -- new bind rec since 11.5.10 (for BILL_TO)
         l_bind_tbl(4).key_name := 'customer_site_use_id';
         l_bind_tbl(4).key_type := 'NUMBER';
         l_bind_tbl(4).key_value := l_customer_site_use_id;
         l_bind_tbl(5).key_name := 'DUNNING_ID';
         l_bind_tbl(5).key_type := 'NUMBER';
         l_bind_tbl(5).key_value := l_dunning_id;

	 --Start adding for bug 9156833 gnramasa 27th Nov 09
	 l_validation_level := FND_API.G_VALID_LEVEL_FULL;

	 if (p_running_level = 'BILL_TO') then
		iex_utilities.get_dunning_resource(p_api_version => p_api_version,
				       p_init_msg_list     => FND_API.G_TRUE,
				       p_commit            => FND_API.G_FALSE,
				       p_validation_level  => l_validation_level,
				       p_level             => 'DUNNING_BILLTO',
				       p_level_id          => l_customer_site_use_id,
				       x_msg_count         => l_msg_count,
				       x_msg_data          => l_msg_data,
				       x_return_status     => l_return_status,
				       x_resource_tab      => l_resource_tab);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     GOTO end_get_resource;
		END IF;
	  end if;

	  if l_resource_tab.count<1 and (p_running_level = 'ACCOUNT') then
		  iex_utilities.get_dunning_resource(p_api_version => p_api_version,
				       p_init_msg_list     => FND_API.G_TRUE,
				       p_commit            => FND_API.G_FALSE,
				       p_validation_level  => l_validation_level,
				       p_level             => 'DUNNING_ACCOUNT',
				       p_level_id          => l_account_id,
				       x_msg_count         => l_msg_count,
				       x_msg_data          => l_msg_data,
				       x_return_status     => l_return_status,
				       x_resource_tab      => l_resource_tab);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     GOTO end_get_resource;
		END IF;
	  end if;

	  if l_resource_tab.count<1 and (p_running_level = 'CUSTOMER') then
		iex_utilities.get_dunning_resource(p_api_version => p_api_version,
				       p_init_msg_list     => FND_API.G_TRUE,
				       p_commit            => FND_API.G_FALSE,
				       p_validation_level  => l_validation_level,
				       p_level             => 'DUNNING_PARTY',
				       p_level_id          => l_party_cust_id,
				       x_msg_count         => l_msg_count,
				       x_msg_data          => l_msg_data,
				       x_return_status     => l_return_status,
				       x_resource_tab      => l_resource_tab);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     GOTO end_get_resource;
		END IF;

		if l_resource_tab.count<1 and (p_running_level = 'CUSTOMER') then
			iex_utilities.get_dunning_resource(p_api_version => p_api_version,
						         p_init_msg_list     => FND_API.G_TRUE,
							 p_commit            => FND_API.G_FALSE,
							 p_validation_level  => l_validation_level,
							 p_level             => 'DUNNING_PARTY_ACCOUNT',
							 p_level_id          => l_party_cust_id,
							 x_msg_count         => l_msg_count,
							 x_msg_data          => l_msg_data,
							 x_return_status     => l_return_status,
							 x_resource_tab      => l_resource_tab);
			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
			     x_return_status := FND_API.G_RET_STS_ERROR;
			     GOTO end_get_resource;
			END IF;
		end if;
	  end if;

	  <<end_get_resource>>
	  if l_resource_tab.count>0 then
	    l_resource_id := l_resource_tab(1).resource_id;
	  end if;
	  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_resource_id: ' || l_resource_id);
	  --End adding for bug 9156833 gnramasa 27th Nov 09
          WriteLog( ' before send_xml org_id ' || l_org_id);
        /**
         * in 11.5.11, IEX supports fulfillment and xml publisher.
         * it depends on the set up in IEX ADMIN/SETUP.
         */
         if (l_curr_dmethod = 'FFM') then

          Send_Fulfillment(p_api_version              => p_api_version
                          ,p_init_msg_list            => FND_API.G_FALSE
                          ,p_commit                   => FND_API.G_TRUE
                          ,p_fulfillment_bind_tbl     => l_bind_tbl
                          ,p_template_id              => l_template_id
                          ,p_method                   => l_method
                          ,p_party_id                 => l_party_cust_id
                          ,x_request_id               => l_request_id
                          ,x_return_status            => x_return_status
                          ,x_msg_count                => x_msg_count
                          ,x_msg_data                 => x_msg_data
                          ,x_contact_destination      => l_contact_destination
                          ,x_contact_party_id         => l_contact_party_id
													);
         else

          Send_XML(p_api_version              => p_api_version
                  ,p_init_msg_list            => FND_API.G_FALSE
                  ,p_commit                   => FND_API.G_TRUE
                  ,p_resend                   => 'N'
                  ,p_request_id               => null
                  ,p_fulfillment_bind_tbl     => l_bind_tbl
                  ,p_template_id              => l_xdo_template_id
                  ,p_method                   => l_method
                  ,p_party_id                 => l_party_cust_id
                  ,p_level                    => p_running_level
                  ,p_source_id                => l_object_id
                  ,p_object_code              => l_object_code
                  ,p_object_id                => l_object_id
		  ,p_resource_id              => l_resource_id --Added for bug 9156833 gnramasa 27th Nov 09
		  ,p_dunning_mode             => p_dunning_mode
		  ,p_parent_request_id        => p_parent_request_id
                  ,p_org_id                   => l_org_id
		  ,x_request_id               => l_request_id
                  ,x_return_status            => x_return_status
                  ,x_msg_count                => x_msg_count
                  ,x_msg_data                 => x_msg_data
                  ,x_contact_destination      => l_contact_destination
                  ,x_contact_party_id         => l_contact_party_id);
         end if;

         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SEND status='|| x_return_status);
	 --End adding for bug 8489610 by gnramasa 14-May-09

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS and x_return_status <> 'W'  THEN
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  Sending process failed');
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sending process failed ');
             x_return_status := FND_API.G_RET_STS_ERROR;
             GOTO end_api;
         elsif x_return_status = 'W' then
             l_warning_flag := 'W';
         END IF;

          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id = ' ||l_request_id);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Request Id = ' || l_request_id);
          l_ffm_cnt := l_ffm_cnt + 1;

            l_dunning_rec_upd.dunning_id := l_dunning_id;
            if (l_curr_dmethod = 'FFM') then
                l_dunning_rec_upd.ffm_request_id := l_request_id;
            else
                l_dunning_rec_upd.xml_request_id := l_request_id;
            end if;

            IEX_DUNNING_PVT.Update_DUNNING(
                p_api_version              => 1.0
                , p_init_msg_list            => FND_API.G_FALSE
                , p_commit                   => FND_API.G_TRUE
                , p_dunning_rec              => l_dunning_rec_upd
                , x_return_status            => l_return_status
                , x_msg_count                => l_msg_count
                , x_msg_data                 => l_msg_data
            );

          <<end_api>>

          if (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              for i in 1..x_msg_count loop
                errmsg := FND_MSG_PUB.Get(p_msg_index => i,
                                          p_encoded => 'F');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error:'||errmsg);
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  errmsg=' || errmsg);
              end loop;
          end if;
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_api');

     ELSE -- l_noskip = 0
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - all del disputed');
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - skip this party/accnt/site');
	  if (l_turnoff_coll_on_bankru = 'Y' and l_no_of_bankruptcy >0 ) then
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'Profile IEX: Turn Off Collections Activity for Bankruptcy is Yes and bankruptcy record is exist, so will skip send dunning' );
	  else
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'all delinquencies disputed' );
	  end if;
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'skip this party/account/site' );
          FND_MSG_PUB.Count_And_Get(  p_count          =>   x_msg_count,
                                      p_data           =>   x_msg_data );
          x_return_status := 'SKIP'; --FND_API.G_EXC_ERROR;

     end if; -- end of if (l_noskip>0)

     if l_warning_flag = 'W' then
      x_return_status := 'W';
     end if;

     --
     -- End of API body
     --

     COMMIT WORK;

     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END');

     FND_MSG_PUB.Count_And_Get
     (  p_count          =>   x_msg_count,
        p_data           =>   x_msg_data );

     EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             COMMIT WORK;
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'expect exception' );
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);


         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             COMMIT WORK;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception');
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'unexpect exception' );
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);


         WHEN OTHERS THEN
             COMMIT WORK;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception');
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'unexpect exception' );
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);

END Send_Level_Dunning;

/*=========================================================================
   gnramasa create 12th Nov 09
    Send Staged Dunning can be in Customer, Account, Bill to and Delinquency levels in R12;
    Send_Level_Staged_Dunning is for Customer, Account level and Bill to level;
    Send_Staged_Dunning keeps the same, and is for Delinquency Level;
*=========================================================================*/
Procedure Send_Level_Staged_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_running_level           IN VARCHAR2,
            p_dunning_plan_id         in number,
	    p_correspondence_date     IN DATE,
            p_resend_flag             IN VARCHAR2,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_parent_request_id       IN NUMBER,
	    p_dunning_mode	      IN VARCHAR2,
	    p_single_staged_letter    IN VARCHAR2 DEFAULT 'N',    -- added by gnramasa for bug stageddunning 28-Dec-09
	    p_confirmation_mode	      IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_GET_DEL (IN_del_ID NUMBER) IS
      SELECT delinquency_ID
        FROM IEX_DELINQUENCIES_ALL
       WHERE delinquency_ID = in_del_ID;
    --
    -- begin bug 4914799 ctlee 12/30/2005 add p_dunning_plan_id
    CURSOR C_GET_SCORE (IN_ID NUMBER, IN_CODE VARCHAR2, p_dunning_plan_id number) IS
      SELECT a.score_value
        FROM IEX_SCORE_HISTORIES a
             , IEX_DUNNING_PLANS_VL c  -- bug 4914799 ctlee 12/30/2005
       WHERE a.score_object_ID = in_ID
         AND a.score_object_code = IN_CODE
         and c.score_id = a.score_id   -- bug 4914799 ctlee 12/30/2005
         and c.dunning_plan_id = p_dunning_plan_id -- bug 4914799 ctlee 12/30/2005
         AND a.creation_date = (select max(b.creation_date)
                                  from iex_score_histories b
                                 where b.score_object_id = in_id
                                   AND b.score_object_code = IN_CODE
				   AND b.score_id = a.score_id );
    -- end bug 4914799 ctlee 12/30/2005 add p_dunning_plan_id

    CURSOR C_GET_TEMPLATE (l_line_id NUMBER,
                           l_score NUMBER, in_LEVEL VARCHAR2, p_dunning_plan_id number) IS
      SELECT x.template_id,
             x.xdo_template_id,
             x.fm_method,
             upper(x.callback_flag),
             x.callback_days
        FROM IEX_AG_DN_XREF x,
             ar_aging_buckets ar,
             iex_dunning_plans_vl d
       WHERE x.aging_bucket_line_ID = l_line_ID
         and x.dunning_plan_id = p_dunning_plan_id
         AND l_score between x.score_range_low and x.score_range_high
         AND x.aging_bucket_id = ar.aging_bucket_id
         and ar.aging_bucket_id = d.aging_bucket_id
         AND ar.status = 'A'
         AND x.dunning_level = IN_LEVEL ;

    --Start bug 7197038 gnramasa 8th july 08
     -- cursor for checking if the number of delinquencies NOT disputed
    /*
    CURSOR C_DISPUTED_AMOUNT(P_PARTY_ID NUMBER, P_CUST_ACCOUNT_ID NUMBER, P_SITE_USE_ID NUMBER ) IS
     select sum(a.amount_in_dispute) - sum(a.amount_due_remaining)
      from iex_delinquencies d
          ,ar_payment_schedules a
     where a.payment_schedule_id  = d.payment_schedule_id
       and d.party_cust_id        = nvl(p_party_id, d.party_cust_id)
       and d.cust_account_id      = nvl(P_CUST_ACCOUNT_ID, d.cust_account_id )
       and d.customer_site_use_id = nvl(p_site_use_id, d.customer_site_use_id )
       and d.status IN ('DELINQUENT', 'PREDELINQUENT');

     CURSOR C_DISPUTED_AMOUNT_PARTY(P_PARTY_ID NUMBER) IS
     select sum(a.amount_in_dispute) - sum(a.amount_due_remaining)
      from iex_delinquencies d
          ,ar_payment_schedules a
     where a.payment_schedule_id  = d.payment_schedule_id
       and d.party_cust_id        = p_party_id
       and d.status IN ('DELINQUENT', 'PREDELINQUENT');

    CURSOR C_DISPUTED_AMOUNT_ACCOUNT(P_CUST_ACCOUNT_ID NUMBER) IS
     select sum(a.amount_in_dispute) - sum(a.amount_due_remaining)
      from iex_delinquencies d
          ,ar_payment_schedules a
     where a.payment_schedule_id  = d.payment_schedule_id
       and d.cust_account_id      = P_CUST_ACCOUNT_ID
       and d.status IN ('DELINQUENT', 'PREDELINQUENT');

    CURSOR C_DISPUTED_AMOUNT_BILLTO(P_SITE_USE_ID NUMBER ) IS
     select sum(a.amount_in_dispute) - sum(a.amount_due_remaining)
      from iex_delinquencies d
          ,ar_payment_schedules a
     where a.payment_schedule_id  = d.payment_schedule_id
       and d.customer_site_use_id = p_site_use_id
       and d.status IN ('DELINQUENT', 'PREDELINQUENT');

    --End bug 7197038 gnramasa 8th july 08

    -- Start for the bug#8408162 by PNAVEENK on 7-4-2009
    cursor c_fully_promised_party(p_party_id number) is
    SELECT count(1)
		FROM ar_payment_schedules ps, iex_delinquencies del
		WHERE del.party_cust_id=p_party_id
	        AND ps.payment_schedule_id = del.payment_schedule_id
	        AND ps.status = 'OP'
	        AND del.status IN ('DELINQUENT', 'PREDELINQUENT')
		and not exists(select 1
	        from iex_promise_details pd where pd.delinquency_id=del.delinquency_id
		and pd.status='COLLECTABLE'
		and pd.state='PROMISE'
	        group by pd.delinquency_id
		having sum(nvl(pd.promise_amount,0))>=ps.amount_due_remaining);
   cursor c_fully_promised_account(p_cust_account_id number) is
   SELECT count(1)
		FROM ar_payment_schedules ps, iex_delinquencies del
		WHERE del.cust_account_id=p_cust_account_id
	        AND ps.payment_schedule_id = del.payment_schedule_id
	        AND ps.status = 'OP'
	        AND del.status IN ('DELINQUENT', 'PREDELINQUENT')
		and not exists(select 1
	        from iex_promise_details pd where pd.delinquency_id=del.delinquency_id
		and pd.status='COLLECTABLE'
		and pd.state='PROMISE'
	        group by pd.delinquency_id
		having sum(nvl(pd.promise_amount,0))>=ps.amount_due_remaining);
   cursor c_fully_promised_billto(p_site_use_id number) is
   SELECT count(1)
		FROM ar_payment_schedules ps, iex_delinquencies del
		WHERE del.customer_site_use_id= p_site_use_id
	        AND ps.payment_schedule_id = del.payment_schedule_id
	        AND ps.status = 'OP'
	        AND del.status IN ('DELINQUENT', 'PREDELINQUENT')
		and not exists(select 1
	        from iex_promise_details pd where pd.delinquency_id=del.delinquency_id
		and pd.status='COLLECTABLE'
		and pd.state='PROMISE'
	        group by pd.delinquency_id
		having sum(nvl(pd.promise_amount,0))>=ps.amount_due_remaining);

    -- End for the bug#8408162 by PNAVEENK on 7-4-2009
    */

    cursor c_dunningplan_lines(p_dunn_plan_id number, p_orderby varchar2) is
    select ag_dn_xref_id,
           dunning_level,
           template_id,
           xdo_template_id,
           fm_method,
           upper(callback_flag) callback_flag,
           callback_days,
	   range_of_dunning_level_from,
	   range_of_dunning_level_to,
	   min_days_between_dunning
    from iex_ag_dn_xref
    where dunning_plan_id = p_dunn_plan_id
    order by AG_DN_XREF_ID ;

    Type refCur             is Ref Cursor;
    sql_cur                 refCur;
    sql_cur1                refCur;
    sql_cur2                refCur;
    sql_cur3                refCur;
    vPLSQL                  VARCHAR2(4000);
    vPLSQL1                 VARCHAR2(4000);
    vPLSQL2                 VARCHAR2(4000);
    vPLSQL3                 VARCHAR2(4000);
    l_orderby		    varchar2(20);
    l_no_of_rows            number;

    cursor c_dunning_plan_dtl (p_dunn_plan_id number) is
    select nvl(dunn.grace_days ,'N'),
           nvl(dunn.dun_disputed_items, 'N')
    from iex_dunning_plans_b dunn
    where dunning_plan_id = p_dunn_plan_id;

    /*
    cursor c_acc_dunning_trx_null_dun_ct (p_party_id number, p_cust_acct_id number, p_min_days_bw_dun number,
                                          p_corr_date date, p_grace_days number, p_include_dis_items varchar) is
    select count(*) from (
    select del.delinquency_id,
           del.transaction_id,
           del.payment_schedule_id
    from iex_delinquencies del,
         ar_payment_schedules arp
    where del.payment_schedule_id = arp.payment_schedule_id
    and del.status in ('DELINQUENT','PREDELINQUENT')
    and del.party_cust_id = p_party_id
    and del.cust_account_id = p_cust_acct_id
    and del.staged_dunning_level is NULL
    and (trunc(arp.due_date) + p_min_days_bw_dun) <= p_corr_date
    and (trunc(arp.due_date) + p_grace_days) <= p_corr_date
    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
    union
    select del.delinquency_id,
           del.transaction_id,
           del.payment_schedule_id
    from iex_delinquencies del,
         ar_payment_schedules arp
    where del.payment_schedule_id = arp.payment_schedule_id
    and del.status = 'CURRENT'
    and del.party_cust_id = p_party_id
    and del.cust_account_id = p_cust_acct_id
    and del.staged_dunning_level is NULL
    and arp.status = 'OP'
    and arp.class = 'INV'
    and (trunc(arp.due_date) + p_min_days_bw_dun) <= p_corr_date
    and (trunc(arp.due_date) + p_grace_days) <= p_corr_date
    and arp.amount_in_dispute >= decode(p_include_dis_items, 'Y', arp.amount_due_remaining, (arp.amount_due_original + 1))
    );

    cursor c_acc_dunning_trx_ct (p_party_id number, p_cust_acct_id number, p_stage_no number,
                                 p_min_days_bw_dun number, p_corr_date date, p_include_dis_items varchar) is
    select count(*) from (
    select del.delinquency_id,
           del.transaction_id,
           del.payment_schedule_id
    from iex_delinquencies del
         ,ar_payment_schedules arp
    where
    del.payment_schedule_id = arp.payment_schedule_id and
    del.status in ('DELINQUENT','PREDELINQUENT')
    and del.party_cust_id = p_party_id
    and del.cust_account_id = p_cust_acct_id
    and del.staged_dunning_level = p_stage_no
    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
    and nvl(
             (
	        (select trunc(correspondence_date) from iex_dunnings
                 where dunning_id =
                    (select distinct DUNNING_ID from iex_dunning_transactions
                     where PAYMENT_SCHEDULE_ID = del.payment_schedule_id
                     and STAGE_NUMBER = p_stage_no
		    )
		 )
	       + p_min_days_bw_dun
	      )
	     , p_corr_date
	    )
	    <= p_corr_date
    union
    select del.delinquency_id,
           del.transaction_id,
           del.payment_schedule_id
    from iex_delinquencies del
         ,ar_payment_schedules arp
    where
    del.payment_schedule_id = arp.payment_schedule_id and
    del.status = 'CURRENT'
    and del.party_cust_id = p_party_id
    and del.cust_account_id = p_cust_acct_id
    and del.staged_dunning_level = p_stage_no
    and arp.status = 'OP'
    and arp.class = 'INV'
    and arp.amount_in_dispute >= decode(p_include_dis_items, 'Y', arp.amount_due_remaining, (arp.amount_due_original + 1))
    and nvl(
        (
	 (select trunc(correspondence_date) from iex_dunnings
          where dunning_id =
           (select distinct DUNNING_ID from iex_dunning_transactions
            where PAYMENT_SCHEDULE_ID = del.payment_schedule_id
            and STAGE_NUMBER = p_stage_no))
	    + p_min_days_bw_dun )
	    , p_corr_date )
	    <= p_corr_date
     );
     */

    l_dunningplan_lines	    c_dunningplan_lines%rowtype;


    l_DUNNING_id            NUMBER;
    l_delinquency_id        NUMBER;
    l_party_cust_id         NUMBER;
    l_account_id            NUMBER;
    l_customer_site_use_id  NUMBER;
    l_noskip                NUMBER := 0;
    l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_DUNNING_tbl           IEX_DUNNING_PUB.DUNNING_TBL_TYPE;
    l_dunning_rec_upd       IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_score                 NUMBER;
    l_bucket_line_id        NUMBER;
    l_campaign_sched_id     NUMBER;
    l_template_id           NUMBER;
    l_xdo_template_id       NUMBER;
    l_method                VARCHAR2(10);
    l_callback_flag         VARCHAR2(1);
    l_callback_days         NUMBER;
    l_callback_date         DATE;
    l_request_id            NUMBER;
    l_outcome_code          varchar2(20);
    l_api_name              CONSTANT VARCHAR2(30) := 'Send_Level_Staged_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);
    --
    nIdx                    NUMBER := 0;
    TYPE Del_ID_TBL_type is Table of IEX_DELINQUENCIES_ALL.DELINQUENCY_ID%TYPE
                            INDEX BY BINARY_INTEGER;
    Del_Tbl                 Del_ID_TBL_TYPE;
    l_bind_tbl              IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
    l_bind_rec              IEX_DUNNING_PVT.FULFILLMENT_BIND_REC;
    l_org_id                NUMBER ;
    l_object_Code           VARCHAR2(25);
    l_object_id             NUMBER;
    --l_delid_tbl             IEX_DUNNING_PUB.DelId_NumList;
    l_del_tbl               IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE;
    l_curr_code             VARCHAR2(15);
    l_amount                NUMBER;
    l_write                 NUMBER;
    l_ffm_cnt               NUMBER := 0;
    l_dunn_cnt              NUMBER := 0;
    l_curr_dmethod          VARCHAR2(10);
    -- begin raverma 03/09/06 add contact point selection
    l_location_id           number;
    l_amount_disputed       number;
    l_contact_id            number;
    l_warning_flag          varchar2(1);
    l_contact_point_id      number;

    l_delinquency_id_check        NUMBER;
    l_party_cust_id_check         NUMBER;
    l_account_id_check            NUMBER;
    l_customer_site_use_id_check  NUMBER;
    l_contact_destination         varchar2(240);  -- bug 3955222
    l_contact_party_id            number; -- bug 3955222
    l_fully_promised              number := 1; -- bug# 8408162
    l_allow_send                  varchar2(1) := 'Y';  -- bug#8408162
    l_status                      varchar2(10);
    l_ag_dn_xref_id	          number;
    l_atleast_one_trx		  varchar2(10);
    l_stage			  number;
    l_acc_dunning_trx_null_dun_ct number;
    l_acc_dunning_trx_ct	  number;
    l_skip_this_dunn_planlineid   number;
    l_first_satified_dunnplanid   number;
    l_grace_days                  number := 0;
    l_use_grace_days              varchar2(10);
    l_dun_disputed_items          varchar2(10);
    l_inc_inv_curr                IEX_UTILITIES.INC_INV_CURR_TBL;
    l_dunn_letters                varchar2(10);

    --Start adding for bug 9156833 gnramasa 27th Nov 09
    l_validation_level		  NUMBER ;
    l_resource_tab		  iex_utilities.resource_tab_type;
    l_resource_id		  NUMBER;
    --End adding for bug 9156833 gnramasa 27th Nov 09
    l_turnoff_coll_on_bankru	  varchar2(10);
    l_no_of_bankruptcy		  number;
    l_min_days_between_dunn_99	  number;

    cursor c_no_of_bankruptcy (p_par_id number)
    is
    select nvl(count(*),0)
    from iex_bankruptcies
    where party_id = p_par_id
    and (disposition_code in ('GRANTED','NEGOTIATION')
         OR (disposition_code is NULL));

    cursor c_min_days_between_dunn_99 (p_dunn_plan_id number, p_stage_no number, p_score_val number)
    is
    select min_days_between_dunning
    from iex_ag_dn_xref
    where dunning_plan_id = p_dunn_plan_id
    and p_stage_no between range_of_dunning_level_from and range_of_dunning_level_to
    and p_score_val between score_range_low and score_range_high;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Send_Level_Staged_Dunning_PVT;

      --Bug#4679639 schekuri 20-OCT-2005
      --Value of profile ORG_ID shouldn't be used for getting ORG_ID after MOAC implementation
      --l_org_id := fnd_profile.value('ORG_ID');
      l_org_id:= mo_global.get_current_org_id;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_org_id = ' || l_org_id);


      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      if (p_resend_flag = 'Y') then
          -- don't write into FILE
          l_write := 0;
      else
          l_write := 1;
      end if;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - running_level = ' || p_running_level);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - resend_flag =   ' || p_resend_flag);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_parent_request_id ' || p_parent_request_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delcnt= ' || p_delinquencies_tbl.count);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_single_staged_letter= ' || p_single_staged_letter);

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- Api body
      --
      l_turnoff_coll_on_bankru	:= nvl(fnd_profile.value('IEX_TURNOFF_COLLECT_BANKRUPTCY'),'N');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_turnoff_coll_on_bankru: ' || l_turnoff_coll_on_bankru);

      l_party_cust_id := p_delinquencies_tbl(1).party_cust_id;
      l_account_id := p_delinquencies_tbl(1).cust_account_id;
      l_customer_site_use_id := p_delinquencies_tbl(1).customer_site_use_id;

      --Initialize the variable to N
      g_included_current_invs	:= 'N';
      g_included_unapplied_rec  := 'N';

      if (p_running_level = 'CUSTOMER') then
          l_object_Code                     := 'PARTY';
          l_object_id                       := p_delinquencies_tbl(1).party_cust_id;
          l_del_tbl(1).party_cust_id        := p_delinquencies_tbl(1).party_cust_id;
          l_del_tbl(1).cust_account_id      := 0;
          l_del_tbl(1).customer_site_use_id := 0;
          --l_amount                          := party_amount_due_remaining(l_object_id);
          --l_curr_code                       := party_currency_code(l_object_id);
          --Start bug 7197038 gnramasa 8th july 08
	  /*
	  open C_DISPUTED_AMOUNT(P_PARTY_ID          => p_delinquencies_tbl(1).party_cust_id
                                ,P_CUST_ACCOUNT_ID   => null
                                ,P_SITE_USE_ID       => null);
	  */
	  --open C_DISPUTED_AMOUNT_PARTY(p_delinquencies_tbl(1).party_cust_id);
          --open c_fully_promised_party (p_delinquencies_tbl(1).party_cust_id);  -- Added for bug# 8408162
      elsif (p_running_level = 'ACCOUNT') then
          l_object_Code                     := 'IEX_ACCOUNT';
          l_object_id                       := p_delinquencies_tbl(1).cust_account_id;
          l_del_tbl(1).party_cust_id        := p_delinquencies_tbl(1).party_cust_id;
          l_del_tbl(1).cust_account_id      := p_delinquencies_tbl(1).cust_account_id;
          l_del_tbl(1).customer_site_use_id := 0;
          --l_amount                          := acct_amount_due_remaining(l_object_id);
          --l_curr_code                       := acct_currency_code(l_object_id);
          /*
	  open C_DISPUTED_AMOUNT(P_PARTY_ID          => null
                                ,P_CUST_ACCOUNT_ID   => p_delinquencies_tbl(1).party_cust_id
                                ,P_SITE_USE_ID       => null);
	  */
	  --open C_DISPUTED_AMOUNT_ACCOUNT(p_delinquencies_tbl(1).cust_account_id);
          --open c_fully_promised_account (p_delinquencies_tbl(1).cust_account_id); -- Added for bug#8408162
      elsif (p_running_level = 'BILL_TO') then
          l_object_Code                     := 'IEX_BILLTO';
          l_object_id                       := p_delinquencies_tbl(1).customer_site_use_id;
          l_del_tbl(1).party_cust_id        := p_delinquencies_tbl(1).party_cust_id;
          l_del_tbl(1).cust_account_id      := p_delinquencies_tbl(1).cust_account_id;
          l_del_tbl(1).customer_site_use_id := p_delinquencies_tbl(1).customer_site_use_id;
          --l_amount                          := site_amount_due_remaining(l_object_id);
          --l_curr_code                       := site_currency_code(l_object_id);
          /*
	  open C_DISPUTED_AMOUNT(P_PARTY_ID          => null
                                ,P_CUST_ACCOUNT_ID   => p_delinquencies_tbl(1).customer_site_use_id
                                ,P_SITE_USE_ID       => null);
	  */
	  --open C_DISPUTED_AMOUNT_BILLTO(p_delinquencies_tbl(1).customer_site_use_id);
          --open c_fully_promised_billto (p_delinquencies_tbl(1).customer_site_use_id); -- Added for bug#8408162
      end if;


      /*==================================================================
       * l_noskip is used to trace the del data is all disputed or not;
       * if any one del not disputed, then l_noskip=1;
       * if l_noskip=0, then means all del are disputed,
       *    => for this customer/account, skip it;
       * if l_fully_promised =0 and l_allow_send = 'N' then l_noskip=0
       *==================================================================*/
      /*
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - counting disputed delinquencies ');
      --fetch C_DISPUTED_AMOUNT into l_amount_disputed;
      --    close C_DISPUTED_AMOUNT;
      if (p_running_level = 'CUSTOMER') then
		fetch C_DISPUTED_AMOUNT_PARTY into l_amount_disputed;
		close C_DISPUTED_AMOUNT_PARTY;
		fetch c_fully_promised_party into l_fully_promised;  -- Added for bug# 8408162
		close c_fully_promised_party;
      elsif (p_running_level = 'ACCOUNT') then
		fetch C_DISPUTED_AMOUNT_ACCOUNT into l_amount_disputed;
		close C_DISPUTED_AMOUNT_ACCOUNT;
		fetch c_fully_promised_account into l_fully_promised; -- Added for bug# 8408162
		close c_fully_promised_account;
      elsif (p_running_level = 'BILL_TO') then
		fetch C_DISPUTED_AMOUNT_BILLTO into l_amount_disputed;
		close C_DISPUTED_AMOUNT_BILLTO;
		fetch c_fully_promised_billto into l_fully_promised; -- Added for bug# 8408162
		close c_fully_promised_billto;
      end if;

      --End bug 7197038 gnramasa 8th july 08
      select fnd_profile.value(nvl('IEX_ALLOW_DUN_FULL_PROMISE','N')) into l_allow_send from dual; -- Added for bug#8408162
      */

      if l_turnoff_coll_on_bankru = 'Y' then
	open c_no_of_bankruptcy (p_delinquencies_tbl(1).party_cust_id);
	fetch c_no_of_bankruptcy into l_no_of_bankruptcy;
	close c_no_of_bankruptcy;
      end if;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_no_of_bankruptcy: ' || l_no_of_bankruptcy);

      --if (l_amount_disputed >= 0) OR (p_resend_flag = 'Y' ) or (l_fully_promised = 0 and l_allow_send = 'Y') then  -- bug#8408162
      if (p_resend_flag = 'Y' OR (l_turnoff_coll_on_bankru = 'Y' and l_no_of_bankruptcy >0 ) ) then
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - setting no skip = 0 ');
           --WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_amount_disputed ' || l_amount_disputed);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_resend_flag = ' || p_resend_flag);
           l_noskip := 0;
			ELSE
           l_noskip := 1;
      end if;

      --WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - amount disputed less delinquency amount = ' || l_amount_disputed);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_code='||l_object_code);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_id='||l_object_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - party_id='||l_party_cust_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - amount_due_remaining='||l_amount);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - currency_code='||l_curr_code);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_noskip='||l_noskip);

      IF (l_noskip > 0) THEN

         -- init the msg (not including the msg from dispute api)
         FND_MSG_PUB.initialize;


          /*===========================================
           * Get Score From IEX_SCORE_HISTORIES
           * If NotFound => Call API to getScore;
           *===========================================*/
	         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get Score');
	         Open C_Get_SCORE(l_object_id, l_object_Code, p_dunning_plan_id);
	         Fetch C_Get_SCORE into l_score;

	         If ( C_GET_SCORE%NOTFOUND) Then
	              FND_MESSAGE.Set_Name('IEX', 'IEX_NO_SCORE');
	              FND_MSG_PUB.Add;
	              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Missing Score');
	              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  Missing Score');
	              Close C_Get_SCORE;
	              RAISE FND_API.G_EXC_ERROR;
	         END IF;
	         Close C_Get_SCORE;
	         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get Score='||l_score);

          /*===================================================
           * in 11.5.11, support aging bucket line for all level;
           * clchang added 11/20/04.
           * Get Aging_Bucket_Line_id for each party/acct/site
           *===================================================*/
 /*--gnramasa
           WriteLog('iexvdunb:SendLevelDunn:GetAgingBucketLineId');

                AGING_DEL(
                  p_api_version              => p_api_version
                , p_init_msg_list            => p_init_msg_list
                , p_commit                   => p_commit
                , p_delinquency_id           => null
                , p_dunning_plan_id          => p_dunning_plan_id
                , p_bucket                   => null
                , p_object_code              => l_object_code
                , p_object_id                => l_object_id
                , x_return_status            => x_return_status
                , x_msg_count                => x_msg_count
                , x_msg_data                 => x_msg_data
                , x_aging_bucket_line_id     => l_bucket_line_id);

         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - AgingDel status='||x_return_status);
         If ( x_return_status <> FND_API.G_RET_STS_SUCCESS) Then
              FND_MESSAGE.Set_Name('IEX', 'IEX_NO_AGINGBUCKETLINE');
              FND_MSG_PUB.Add;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - AgingBucketLineId notfound');
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'AgingBucketLineId NotFound');
              RAISE FND_API.G_EXC_ERROR;
         END IF;
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - lineid='||l_bucket_line_id);
	 */

		l_validation_level := FND_API.G_VALID_LEVEL_FULL;

		 open c_dunning_plan_dtl (p_dunning_plan_id);
		 fetch c_dunning_plan_dtl into l_use_grace_days, l_dun_disputed_items;
		 close c_dunning_plan_dtl;
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_use_grace_days :'|| l_use_grace_days);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_dun_disputed_items :'|| l_dun_disputed_items);

		 if l_use_grace_days = 'Y' then
			 iex_utilities.get_grace_days(p_api_version => p_api_version,
					       p_init_msg_list     => FND_API.G_TRUE,
					       p_commit            => FND_API.G_FALSE,
					       p_validation_level  => l_validation_level,
					       p_level             => p_running_level,
					       p_party_id          => l_del_tbl(1).party_cust_id,
					       p_account_id        => l_del_tbl(1).cust_account_id,
					       p_site_use_id       => l_del_tbl(1).customer_site_use_id,
					       x_msg_count         => l_msg_count,
					       x_msg_data          => l_msg_data,
					       x_return_status     => l_return_status,
					       x_grace_days        => l_grace_days);
			 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get grace days');
			     x_return_status := FND_API.G_RET_STS_ERROR;
			 END IF;
		 end if;
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_grace_days :'|| l_grace_days);

	    --Start bug 9696806 gnramasa 27th May 10
		open c_min_days_between_dunn_99 (p_dunning_plan_id, 99, l_score);
		fetch c_min_days_between_dunn_99 into l_min_days_between_dunn_99;
		close c_min_days_between_dunn_99;
		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_min_days_between_dunn_99 :'|| l_min_days_between_dunn_99);

		if (p_running_level = 'CUSTOMER') then
		        update iex_delinquencies del
			set staged_dunning_level = 98
			where del.party_cust_id = l_object_id
			and staged_dunning_level = 99
			and status in ('DELINQUENT','PREDELINQUENT')
			and nvl(
				 (
				    (select trunc(correspondence_date) from iex_dunnings
				     where dunning_id =
					(select max(iet.DUNNING_ID)
					from iex_dunning_transactions iet,
					     iex_dunnings dunn
					 where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
						    and dunn.dunning_id = iet.dunning_id
						    and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
							    OR (dunn.dunning_mode = 'FINAL'))
					 and iet.STAGE_NUMBER = 99
					 and dunn.delivery_status is null
					)
				     )
				   + l_min_days_between_dunn_99
				  )
				     , p_correspondence_date
			      )
			      <= p_correspondence_date ;

		elsif  (p_running_level = 'ACCOUNT') then
		        update iex_delinquencies del
			set staged_dunning_level = 98
			where del.cust_account_id = l_object_id
			and staged_dunning_level = 99
			and status in ('DELINQUENT','PREDELINQUENT')
			and nvl(
				 (
				    (select trunc(correspondence_date) from iex_dunnings
				     where dunning_id =
					(select max(iet.DUNNING_ID)
					from iex_dunning_transactions iet,
					     iex_dunnings dunn
					 where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
						    and dunn.dunning_id = iet.dunning_id
						    and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
							    OR (dunn.dunning_mode = 'FINAL'))
					 and iet.STAGE_NUMBER = 99
					 and dunn.delivery_status is null
					)
				     )
				   + l_min_days_between_dunn_99
				  )
				     , p_correspondence_date
			      )
			      <= p_correspondence_date ;

		elsif  (p_running_level = 'BILL_TO') then
			update iex_delinquencies del
			set staged_dunning_level = 98
			where del.customer_site_use_id = l_object_id
			and staged_dunning_level = 99
			and status in ('DELINQUENT','PREDELINQUENT')
			and nvl(
				 (
				    (select trunc(correspondence_date) from iex_dunnings
				     where dunning_id =
					(select max(iet.DUNNING_ID)
					from iex_dunning_transactions iet,
					     iex_dunnings dunn
					 where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
						    and dunn.dunning_id = iet.dunning_id
						    and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
							    OR (dunn.dunning_mode = 'FINAL'))
					 and iet.STAGE_NUMBER = 99
					 and dunn.delivery_status is null
					)
				     )
				   + l_min_days_between_dunn_99
				  )
				     , p_correspondence_date
			      )
			      <= p_correspondence_date ;
		end if;

	    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Updated : ' || SQL%ROWCOUNT || ' number of row''s staged_dunning_level from 99 to 98');
	    commit;
	    --End bug 9696806 gnramasa 27th May 10

	    l_account_id_check := l_account_id;
	    l_customer_site_use_id_check := l_customer_site_use_id;
	   if (p_running_level = 'CUSTOMER') or (p_running_level = 'ACCOUNT') then
	      l_customer_site_use_id_check := null;
	   end if;
		   -- check the hz_customer_profiles_amt min_dunning_invoice_amount and min_dunning_amount

		   iex_utilities.StagedDunningMinAmountCheck (
			    p_cust_account_id => l_account_id_check
			    , p_site_use_id => l_customer_site_use_id_check
			    , p_party_id => l_party_cust_id
			    , p_dunning_plan_id => p_dunning_plan_id
			    , p_grace_days => l_grace_days
			    , p_dun_disputed_items => l_dun_disputed_items
			    , p_correspondence_date => p_correspondence_date
			    , p_running_level => p_running_level
			    , p_inc_inv_curr => l_inc_inv_curr
			    , p_dunning_letters => l_dunn_letters);

		   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_dunn_letters: ' || l_dunn_letters);

		   if l_dunn_letters = 'N' then
			FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_AMOUNT_MIN');
			FND_MSG_PUB.Add;
			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  Required min Dunning amount in customer profile ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Required min Dunning amount in customer profile ');
			x_return_status := FND_API.G_RET_STS_ERROR;
			GOTO end_api;
		   end if;

		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  end check customer profile');

	 if upper(p_single_staged_letter) = 'N' then
		l_orderby	:= 'ASC';
	 else
		l_orderby	:= 'DESC';
	 end if;

	 vPLSQL := '  select ag_dn_xref_id, ' ||
		' dunning_level, ' ||
	        ' template_id, ' ||
		' xdo_template_id, ' ||
		' fm_method, ' ||
		' upper(callback_flag) callback_flag, ' ||
		' callback_days, ' ||
		' range_of_dunning_level_from, ' ||
		' range_of_dunning_level_to, ' ||
		' min_days_between_dunning ' ||
		' from iex_ag_dn_xref ' ||
		' where dunning_plan_id = :p_dunning_plan_id ' ||
		' AND :p_score between score_range_low and score_range_high ' ||
		' order by range_of_dunning_level_from ' || l_orderby;

	open sql_cur for vPLSQL using p_dunning_plan_id, l_score;

	 loop
		 fetch sql_cur into l_dunningplan_lines;
		 exit when sql_cur%notfound;

		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.ag_dn_xref_id='||l_dunningplan_lines.ag_dn_xref_id);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.dunning_level='||l_dunningplan_lines.dunning_level);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.template_id='||l_dunningplan_lines.template_id);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.xdo_template_id='||l_dunningplan_lines.xdo_template_id);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.fm_method='||l_dunningplan_lines.fm_method);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.callback_flag='||l_dunningplan_lines.callback_flag);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.callback_days='||l_dunningplan_lines.callback_days);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.range_of_dunning_level_from='||l_dunningplan_lines.range_of_dunning_level_from);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.range_of_dunning_level_to='||l_dunningplan_lines.range_of_dunning_level_to);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.min_days_between_dunning='||l_dunningplan_lines.min_days_between_dunning);

		 l_ag_dn_xref_id			:= l_dunningplan_lines.ag_dn_xref_id;
		 l_template_id				:= l_dunningplan_lines.template_id;
		 l_xdo_template_id			:= l_dunningplan_lines.xdo_template_id;
		 l_method				:= l_dunningplan_lines.fm_method;
		 l_callback_flag			:= l_dunningplan_lines.callback_flag;
		 l_callback_days			:= l_dunningplan_lines.callback_days;


		  /*===========================================
		   * Get Template_ID From iex_ag_dn_xref
		   *===========================================*/
/*--gnramasa
		   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GET Template');
		   Open C_Get_TEMPLATE(l_bucket_line_id, l_score, p_running_level, p_dunning_plan_id);
		   Fetch C_Get_TEMPLATE into
			       l_template_id,
			       l_xdo_template_id,
			       l_method,
			       l_callback_flag,
			       l_callback_days;

		   If ( C_GET_TEMPLATE%NOTFOUND) Then
			--FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
			--FND_MESSAGE.Set_Token ('INFO', 'Template_ID', FALSE);
			FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
			FND_MSG_PUB.Add;
			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Missing corresponding template');
			      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Missing corresponding template');
			      RAISE FND_API.G_EXC_ERROR;
		 END IF;

		   --WriteLog('iexvdunb:SendLevelDunn:close C_GET_TEMPLATE');
		   Close C_Get_TEMPLATE;

		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get ffm_template_id='||l_template_id);
		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get xdo_template_id='||l_xdo_template_id);
*/

		 /*===========================================
		  * Check template
		  *  in 11.5.11, IEX supports fulfillment and xml publisher.
		  *  if the current setup for delivery id FFM,
		  *  then template_id is necessary;
		  *  if XML, xdo_template_id is necessary;
		  *===========================================*/

		 l_curr_dmethod := IEX_SEND_XML_PVT.getCurrDeliveryMethod;
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - curr d_method='||l_curr_dmethod);
		 if ( (l_curr_dmethod is null or l_curr_dmethod = '') or
		      (l_curr_dmethod = 'FFM' and l_template_id is null)  or
		      (l_curr_dmethod = 'XML' and l_xdo_template_id is null ) ) then
		      FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
		      FND_MSG_PUB.Add;
		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Missing corresponding template');
		      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Missing corresponding template');
		      RAISE FND_API.G_EXC_ERROR;

		 end if;

		       /*===========================================
		  * Check profile before send dunning
		  *===========================================*/
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  begin check customer profile');

		  -- ctlee - check the hz_customer_profiles.dunning_letter
		   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_party_cust_id = ' || l_party_cust_id);
		   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_account_id = ' || l_account_id);
		   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_customer_site_use_id = ' || l_customer_site_use_id);
		   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_delinquency_id = ' || l_delinquency_id);
		    -- ctlee - check the hz_customer_profiles.dunning_letter
		    l_party_cust_id_check := l_party_cust_id;
		    l_account_id_check := l_account_id;
		    l_customer_site_use_id_check := l_customer_site_use_id;
		    l_delinquency_id_check := l_delinquency_id;
		   if (p_running_level = 'CUSTOMER') then
		      l_account_id_check := null;
		      l_customer_site_use_id_check := null;
		      l_delinquency_id_check := null;
		   elsif  (p_running_level = 'ACCOUNT') then
		      l_customer_site_use_id_check := null;
		      l_delinquency_id_check := null;
		   elsif  (p_running_level = 'BILL_TO') then
		      l_delinquency_id_check := null;
		   end if;
		   if ( iex_utilities.DunningProfileCheck (
			   p_party_id => l_party_cust_id_check
			   , p_cust_account_id => l_account_id_check
			   , p_site_use_id => l_customer_site_use_id_check
			   , p_delinquency_id => l_delinquency_id_check     ) = 'N'
		      ) then
			FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_PROFILE_NO');
			FND_MSG_PUB.Add;
			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  Send dunning in customer profile set to no ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Send dunning in customer profile set to no ');
			x_return_status := FND_API.G_RET_STS_ERROR;
			GOTO end_api;
		   end if;

		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  p_dunning_mode :'|| p_dunning_mode);
		 --If dunning mode is draft then don't close the previous duning records.

		 for i in l_dunningplan_lines.range_of_dunning_level_from..l_dunningplan_lines.range_of_dunning_level_to
		      loop
				l_stage	:= i-1;
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_stage :'||l_stage);
				l_skip_this_dunn_planlineid := 1;

				if i = 1 then

					 vPLSQL1 := 'select count(*) from ( ' ||
							'    select del.delinquency_id, ' ||
							'	   del.transaction_id, ' ||
							'	   del.payment_schedule_id  ' ||
							'    from iex_delinquencies del, ' ||
							'	 ar_payment_schedules arp ' ||
							'    where del.payment_schedule_id = arp.payment_schedule_id ' ||
							'    and del.status in (''DELINQUENT'',''PREDELINQUENT'') ' ||
							'    and del.staged_dunning_level is NULL ' ||
							'    and (trunc(arp.due_date) + :p_min_days_bw_dun) <= :p_corr_date ' ||
							'    and (trunc(arp.due_date) + :p_grace_days) <= :p_corr_date ' ||
							'    and nvl(arp.amount_in_dispute,0) = decode(:p_include_dis_items, ''Y'', nvl(arp.amount_in_dispute,0), 0) ';

					vPLSQL2 := '    union ' ||
							'    select del.delinquency_id, ' ||
							'	   del.transaction_id, ' ||
							'	   del.payment_schedule_id ' ||
							'    from iex_delinquencies del, ' ||
							'	 ar_payment_schedules arp ' ||
							'    where del.payment_schedule_id = arp.payment_schedule_id ' ||
							'    and del.status = ''CURRENT'' ' ||
							'    and del.staged_dunning_level is NULL ' ||
							'    and arp.status = ''OP'' ' ||
							'    and arp.class = ''INV'' ' ||
							'    and (trunc(arp.due_date) + :p_min_days_bw_dun) <= :p_corr_date ' ||
							'    and (trunc(arp.due_date) + :p_grace_days) <= :p_corr_date ' ||
							'    and arp.amount_in_dispute >= decode(:p_include_dis_items, ''Y'', arp.amount_due_remaining, (arp.amount_due_original + 1)) ' ;

					if (p_running_level = 'CUSTOMER') then
					      vPLSQL3		:= vPLSQL1 || '    and del.party_cust_id = :p_party_id ' || vPLSQL2 ||
								   '    and del.party_cust_id = :p_party_id )';
					elsif  (p_running_level = 'ACCOUNT') then
					      vPLSQL3		:= vPLSQL1 || '    and del.cust_account_id = :p_cust_acct_id ' || vPLSQL2 ||
								   '    and del.cust_account_id = :p_cust_acct_id )';
					elsif  (p_running_level = 'BILL_TO') then
					      vPLSQL3		:= vPLSQL1 || '    and del.customer_site_use_id = :p_site_use_id ' || vPLSQL2 ||
								   '    and del.customer_site_use_id = :p_site_use_id )';
					end if;

					open sql_cur3 for vPLSQL3 using l_dunningplan_lines.min_days_between_dunning,
								    p_correspondence_date,
								    l_grace_days,
								    p_correspondence_date,
								    l_dun_disputed_items,
								    l_object_id,
								    l_dunningplan_lines.min_days_between_dunning,
								    p_correspondence_date,
								    l_grace_days,
								    p_correspondence_date,
								    l_dun_disputed_items,
								    l_object_id;
					fetch sql_cur3 into l_acc_dunning_trx_null_dun_ct;
					close sql_cur3;

					WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_acc_dunning_trx_null_dun_ct :'||l_acc_dunning_trx_null_dun_ct);
					if l_acc_dunning_trx_null_dun_ct <> 0 then
						WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Transaction exist for this stage, so will continue...');
						l_skip_this_dunn_planlineid := 0;
						if l_first_satified_dunnplanid is null then
							l_first_satified_dunnplanid := 1;
						else
							l_first_satified_dunnplanid := 0;
						end if;
						goto STAGE_DUNN;
					 end if;

				else

					 vPLSQL1 := 'select count(*) from ( ' ||
							'    select del.delinquency_id, ' ||
							'	   del.transaction_id, ' ||
							'	   del.payment_schedule_id ' ||
							'   from iex_delinquencies del ' ||
							'	 ,ar_payment_schedules arp ' ||
							'    where ' ||
							'    del.payment_schedule_id = arp.payment_schedule_id and ' ||
							'    del.status in (''DELINQUENT'',''PREDELINQUENT'') ' ||
							'    and del.staged_dunning_level = :p_stage_no ' ||
							'    and nvl(arp.amount_in_dispute,0) = decode(:p_include_dis_items, ''Y'', nvl(arp.amount_in_dispute,0), 0) ' ||
							'    and nvl( ' ||
							'	     ( ' ||
							'		(select trunc(correspondence_date) from iex_dunnings ' ||
							'		 where dunning_id = ' ||
							'		    (select max(iet.DUNNING_ID) from iex_dunning_transactions iet, ' ||
							'                                                    iex_dunnings dunn ' ||
							'		     where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id ' ||
							'                    and dunn.dunning_id = iet.dunning_id ' ||
							'                    and ((dunn.dunning_mode = ''DRAFT'' and dunn.confirmation_mode = ''CONFIRMED'') ' ||
							'                            OR (dunn.dunning_mode = ''FINAL'')) ' ||
							'		     and iet.STAGE_NUMBER = :p_stage_no ' ||
							'                    and dunn.delivery_status is null' ||
							'		    ) ' ||
							'		 ) ' ||
							'	       + :p_min_days_bw_dun ' ||
							'	      ) ' ||
							'	     , :p_corr_date ' ||
							'	    ) ' ||
							'	    <= :p_corr_date ';
					--WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - vPLSQL1 :'||vPLSQL1);

					vPLSQL2 := '    union ' ||
							'    select del.delinquency_id, ' ||
							'	   del.transaction_id, ' ||
							'	   del.payment_schedule_id ' ||
							'    from iex_delinquencies del ' ||
							'	 ,ar_payment_schedules arp ' ||
							'    where ' ||
							'    del.payment_schedule_id = arp.payment_schedule_id and ' ||
							'    del.status = ''CURRENT'' ' ||
							'    and del.staged_dunning_level = :p_stage_no ' ||
							'    and arp.status = ''OP'' ' ||
							'    and arp.class = ''INV'' ' ||
							'    and arp.amount_in_dispute >= decode(:p_include_dis_items, ''Y'', arp.amount_due_remaining, (arp.amount_due_original + 1)) ' ||
							'    and nvl( ' ||
							'	( ' ||
							'	 (select trunc(correspondence_date) from iex_dunnings ' ||
							'	  where dunning_id = ' ||
							'	   (select max(iet.DUNNING_ID) from iex_dunning_transactions iet, ' ||
							'                                           iex_dunnings dunn ' ||
							'	    where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id ' ||
							'                    and dunn.dunning_id = iet.dunning_id ' ||
							'                    and ((dunn.dunning_mode = ''DRAFT'' and dunn.confirmation_mode = ''CONFIRMED'') ' ||
							'                            OR (dunn.dunning_mode = ''FINAL'')) ' ||
							'	    and iet.STAGE_NUMBER = :p_stage_no and dunn.delivery_status is null)) ' ||
							'	    + :p_min_days_bw_dun ) ' ||
							'	    , :p_corr_date ) ' ||
							'	    <= :p_corr_date ';
					--WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - vPLSQL2 :'||vPLSQL2);

					if (p_running_level = 'CUSTOMER') then
					      vPLSQL3		:= vPLSQL1 || '    and del.party_cust_id = :p_party_id ' || vPLSQL2 ||
								   '    and del.party_cust_id = :p_party_id )';
					elsif  (p_running_level = 'ACCOUNT') then
					      vPLSQL3		:= vPLSQL1 || '    and del.cust_account_id = :p_cust_acct_id ' || vPLSQL2 ||
								   '    and del.cust_account_id = :p_cust_acct_id )';
					elsif  (p_running_level = 'BILL_TO') then
					      vPLSQL3		:= vPLSQL1 || '    and del.customer_site_use_id = :p_site_use_id ' || vPLSQL2 ||
								   '    and del.customer_site_use_id = :p_site_use_id )';
					end if;
					--WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - vPLSQL3 :'||vPLSQL3);

					open sql_cur3 for vPLSQL3 using l_stage,
								    l_dun_disputed_items,
								    l_stage,
								    l_dunningplan_lines.min_days_between_dunning,
								    p_correspondence_date,
								    p_correspondence_date,
								    l_object_id,
								    l_stage,
								    l_dun_disputed_items,
								    l_stage,
								    l_dunningplan_lines.min_days_between_dunning,
								    p_correspondence_date,
								    p_correspondence_date,
								    l_object_id;
					fetch sql_cur3 into l_acc_dunning_trx_ct;
					close sql_cur3;

					 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_acc_dunning_trx_ct :'||l_acc_dunning_trx_ct);
					 if l_acc_dunning_trx_ct <> 0 then
						WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Transaction exist for this stage, so will continue...');
						l_skip_this_dunn_planlineid := 0;
						if l_first_satified_dunnplanid is null then
							l_first_satified_dunnplanid := 1;
						else
							l_first_satified_dunnplanid := 0;
						end if;
						goto STAGE_DUNN;
					 end if;

				end if;

		      end loop;
		  <<STAGE_DUNN>>
		  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_skip_this_dunn_planlineid: '|| l_skip_this_dunn_planlineid);
		  if l_skip_this_dunn_planlineid = 1 then
			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Transaction doesn''t exist for this stage, so skipping...');
			goto c_dunning_plan_lines;
		  end if;

		 if ((upper(p_single_staged_letter) = 'N') OR (upper(p_single_staged_letter) = 'Y' and (l_first_satified_dunnplanid = 1)) ) then
			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_single_staged_letter is N or p_single_staged_letter is Y and dunning_id NULL');
			 --Start adding for bug 8489610 by gnramasa 14-May-09
			 if p_dunning_mode <> 'DRAFT' then
				  /*===========================================
				   * Close OPEN Dunnings for each party/account
				   *===========================================*/
				  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning');

				 /* if p_dunning_mode = 'DRAFT' then
					l_status := 'CLOSE';
				  else
					l_status := 'OPEN';
				  end if;
				 */
				  Close_Staged_Dunning(
					p_api_version              => p_api_version
				      , p_init_msg_list            => p_init_msg_list
				      , p_commit                   => p_commit
				      , p_delinquencies_tbl        => l_del_tbl
				      , p_ag_dn_xref_id	           => l_ag_dn_xref_id
				      , p_running_level            => p_running_level
				      --, p_status                   => l_status
				      , x_return_status            => x_return_status
				      , x_msg_count                => x_msg_count
				      , x_msg_data                 => x_msg_data);

				  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning status='|| x_return_status);

				  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Close Dunning');
					FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Close Dunning');
					x_return_status := FND_API.G_RET_STS_ERROR;
					GOTO end_api;
				  END IF;
				  --WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EndCloseDunn');
			 end if;



			  /*===========================================
			   * Create Dunning Record
			   *===========================================*/
			  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get CallbackDate');
			  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag='||l_callback_flag);
			  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDays='||l_callback_days);

			    /*===================================================
			     * clchang updated 02/13/2003
			     * callback_days could be null if callback_yn = 'N';
			     * and if callback_yn = 'N', not get callback_date;
			     *==================================================*/
			     IF (l_callback_flag = 'Y') THEN

					     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is Y: GetCallbackDate');
					     Get_Callback_Date(p_init_msg_list          => FND_API.G_FALSE
							      ,p_callback_days          => l_callback_days
							      , p_correspondence_date   => p_correspondence_date
							      ,x_callback_date          => l_callback_date
							      ,x_return_status          => x_return_status
							      ,x_msg_count              => x_msg_count
							      ,x_msg_data               => x_msg_data);

					     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetCallbackDate status='|| x_return_status);

					     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					       FND_MESSAGE.Set_Name('IEX', 'IEX_NO_CALLBACKDATE');
					       FND_MSG_PUB.Add;
					       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot find callback date');
					       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot find callback date');
					       x_return_status := FND_API.G_RET_STS_ERROR;
					       GOTO end_api;
					     END IF;

			     ELSE
				 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is N: NOTGetCallbackDate');

			     END IF;


			     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDate='||l_callback_date);
			     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Create Dunning');
			     l_dunning_rec.dunning_level := p_running_level;
			     l_dunning_rec.dunning_object_id := l_object_id;
			     l_dunning_rec.callback_yn := l_callback_flag;
			     l_dunning_rec.callback_date := l_callback_date;

			     if p_dunning_mode = 'DRAFT' then
				l_dunning_rec.status := 'CLOSE';
			     else
				l_dunning_rec.status := 'OPEN';
			     end if;

			     l_dunning_rec.dunning_method := l_method;

			     if (l_curr_dmethod = 'FFM') then
				 l_dunning_rec.template_id:= l_template_id;
				 l_dunning_rec.ffm_request_id := l_request_id;
			     else
				 l_dunning_rec.xml_template_id:= l_xdo_template_id;
				 l_dunning_rec.xml_request_id := l_request_id;
			     end if;
			     l_dunning_rec.object_type := l_object_code;
			     l_dunning_rec.object_id := l_object_id;
			     l_dunning_rec.amount_due_remaining := l_amount;
			     l_dunning_rec.currency_code := l_curr_code;
			     l_dunning_rec.dunning_plan_id := p_dunning_plan_id;
			     l_dunning_rec.contact_destination := l_contact_destination;  -- bug 3955222
			     l_dunning_rec.contact_party_id := l_contact_party_id;  -- bug 3955222

			     if p_parent_request_id is not null then
				l_dunning_rec.request_id := p_parent_request_id;
			     else
				l_dunning_rec.request_id := FND_GLOBAL.Conc_Request_Id;
			     end if;

			     --l_dunning_rec.request_id           := FND_GLOBAL.Conc_Request_Id;
			     l_dunning_rec.dunning_mode := p_dunning_mode;
			     l_dunning_rec.confirmation_mode := p_confirmation_mode;
			     l_dunning_rec.ag_dn_xref_id	:= l_dunningplan_lines.ag_dn_xref_id;
			     l_dunning_rec.correspondence_date	:= p_correspondence_date;
			     l_dunning_rec.org_id := l_org_id;

			     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' before create dunning org_id ' || l_org_id);

			     CREATE_DUNNING(
				   p_api_version              => p_api_version
				 , p_init_msg_list            => p_init_msg_list
				 , p_commit                   => p_commit
				 , p_dunning_rec              => l_dunning_rec
				 , x_dunning_id               => l_dunning_id
				 , x_return_status            => x_return_status
				 , x_msg_count                => x_msg_count
				 , x_msg_data                 => x_msg_data);

			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning status='|| x_return_status);

			      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Dunning');
				   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Create Dunning');
				   x_return_status := FND_API.G_RET_STS_ERROR;
				   GOTO end_api;
			      END IF;

			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunningId='||l_dunning_id);
			      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Create Dunning Id='|| l_dunning_id);
			      l_dunn_cnt := l_dunn_cnt + 1;
		 end if; --if ((upper(p_single_staged_letter) = 'N') OR (upper(p_single_staged_letter) = 'Y' and (l_first_satified_dunnplanid = 1)) ) then

		  Create_Staged_Dunning(
				p_api_version              => p_api_version
			      , p_init_msg_list            => p_init_msg_list
			      , p_commit                   => p_commit
			      , p_delinquencies_tbl        => l_del_tbl
			      , p_ag_dn_xref_id	           => l_ag_dn_xref_id
			      , p_dunning_id               => l_dunning_id
			      , p_correspondence_date      => p_correspondence_date
			      , p_running_level            => p_running_level
			      , p_grace_days               => l_grace_days
			      , p_include_dispute_items    => l_dun_disputed_items
			      , p_dunning_mode		   => p_dunning_mode
			      , p_inc_inv_curr             => l_inc_inv_curr
			      , x_return_status            => x_return_status
			      , x_msg_count                => x_msg_count
			      , x_msg_data                 => x_msg_data);

		  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Create Stage Dunning transactions status='|| x_return_status);

		      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Stage Dunning transactions');
			   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Create Stage Dunning transactions');
			   x_return_status := FND_API.G_RET_STS_ERROR;
			   GOTO end_api;
		      END IF;

		 if (upper(p_single_staged_letter) = 'N') then

			  /*===========================================
			   * Send letter thru fulfillment
			   *===========================================*/
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SEND_FFM');
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - org_id='||l_org_id);
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - party_id='||l_party_cust_id);
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - method='||l_method);

			 l_bind_tbl(1).key_name := 'party_id';
			 l_bind_tbl(1).key_type := 'NUMBER';
			 l_bind_tbl(1).key_value := l_party_cust_id;
			 l_bind_tbl(2).key_name := 'org_id';
			 l_bind_tbl(2).key_type := 'NUMBER';
			 l_bind_tbl(2).key_value := l_org_id;
			 l_bind_tbl(3).key_name := 'account_id';
			 l_bind_tbl(3).key_type := 'NUMBER';
			 l_bind_tbl(3).key_value := l_account_id;
			 -- new bind rec since 11.5.10 (for BILL_TO)
			 l_bind_tbl(4).key_name := 'customer_site_use_id';
			 l_bind_tbl(4).key_type := 'NUMBER';
			 l_bind_tbl(4).key_value := l_customer_site_use_id;
			 l_bind_tbl(5).key_name := 'DUNNING_ID';
			 l_bind_tbl(5).key_type := 'NUMBER';
			 l_bind_tbl(5).key_value := l_dunning_id;

			 --Start adding for bug 9156833 gnramasa 27th Nov 09
			 l_validation_level := FND_API.G_VALID_LEVEL_FULL;

			 if (p_running_level = 'BILL_TO') then
				iex_utilities.get_dunning_resource(p_api_version => p_api_version,
						       p_init_msg_list     => FND_API.G_TRUE,
						       p_commit            => FND_API.G_FALSE,
						       p_validation_level  => l_validation_level,
						       p_level             => 'DUNNING_BILLTO',
						       p_level_id          => l_customer_site_use_id,
						       x_msg_count         => l_msg_count,
						       x_msg_data          => l_msg_data,
						       x_return_status     => l_return_status,
						       x_resource_tab      => l_resource_tab);
				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
				     x_return_status := FND_API.G_RET_STS_ERROR;
				     GOTO end_get_resource;
				END IF;
			  end if;

			  if l_resource_tab.count<1 and (p_running_level = 'ACCOUNT') then
				  iex_utilities.get_dunning_resource(p_api_version => p_api_version,
						       p_init_msg_list     => FND_API.G_TRUE,
						       p_commit            => FND_API.G_FALSE,
						       p_validation_level  => l_validation_level,
						       p_level             => 'DUNNING_ACCOUNT',
						       p_level_id          => l_account_id,
						       x_msg_count         => l_msg_count,
						       x_msg_data          => l_msg_data,
						       x_return_status     => l_return_status,
						       x_resource_tab      => l_resource_tab);
				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
				     x_return_status := FND_API.G_RET_STS_ERROR;
				     GOTO end_get_resource;
				END IF;
			  end if;

			  if l_resource_tab.count<1 and (p_running_level = 'CUSTOMER') then
				iex_utilities.get_dunning_resource(p_api_version => p_api_version,
						       p_init_msg_list     => FND_API.G_TRUE,
						       p_commit            => FND_API.G_FALSE,
						       p_validation_level  => l_validation_level,
						       p_level             => 'DUNNING_PARTY',
						       p_level_id          => l_party_cust_id,
						       x_msg_count         => l_msg_count,
						       x_msg_data          => l_msg_data,
						       x_return_status     => l_return_status,
						       x_resource_tab      => l_resource_tab);
				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
				     x_return_status := FND_API.G_RET_STS_ERROR;
				     GOTO end_get_resource;
				END IF;

				if l_resource_tab.count<1 and (p_running_level = 'CUSTOMER') then
					iex_utilities.get_dunning_resource(p_api_version => p_api_version,
									 p_init_msg_list     => FND_API.G_TRUE,
									 p_commit            => FND_API.G_FALSE,
									 p_validation_level  => l_validation_level,
									 p_level             => 'DUNNING_PARTY_ACCOUNT',
									 p_level_id          => l_party_cust_id,
									 x_msg_count         => l_msg_count,
									 x_msg_data          => l_msg_data,
									 x_return_status     => l_return_status,
									 x_resource_tab      => l_resource_tab);
					IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
					     x_return_status := FND_API.G_RET_STS_ERROR;
					     GOTO end_get_resource;
					END IF;
				end if;
			  end if;

			  <<end_get_resource>>
			  if l_resource_tab.count>0 then
			    l_resource_id := l_resource_tab(1).resource_id;
			  end if;
			  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_resource_id: ' || l_resource_id);
			  --End adding for bug 9156833 gnramasa 27th Nov 09

			 WriteLog( G_PKG_NAME || ' ' || l_api_name ||' before send_xml org_id ' || l_org_id);

			/**
			 * in 11.5.11, IEX supports fulfillment and xml publisher.
			 * it depends on the set up in IEX ADMIN/SETUP.
			 */
			 if (l_curr_dmethod = 'FFM') then

			  Send_Fulfillment(p_api_version              => p_api_version
					  ,p_init_msg_list            => FND_API.G_FALSE
					  ,p_commit                   => FND_API.G_TRUE
					  ,p_fulfillment_bind_tbl     => l_bind_tbl
					  ,p_template_id              => l_template_id
					  ,p_method                   => l_method
					  ,p_party_id                 => l_party_cust_id
					  ,x_request_id               => l_request_id
					  ,x_return_status            => x_return_status
					  ,x_msg_count                => x_msg_count
					  ,x_msg_data                 => x_msg_data
					  ,x_contact_destination      => l_contact_destination
					  ,x_contact_party_id         => l_contact_party_id
															);
			 else

			  Send_XML(p_api_version              => p_api_version
				  ,p_init_msg_list            => FND_API.G_FALSE
				  ,p_commit                   => FND_API.G_TRUE
				  ,p_resend                   => 'N'
				  ,p_request_id               => null
				  ,p_fulfillment_bind_tbl     => l_bind_tbl
				  ,p_template_id              => l_xdo_template_id
				  ,p_method                   => l_method
				  ,p_party_id                 => l_party_cust_id
				  ,p_level                    => p_running_level
				  ,p_source_id                => l_object_id
				  ,p_object_code              => l_object_code
				  ,p_object_id                => l_object_id
				  ,p_resource_id              => l_resource_id --Added for bug 9156833 gnramasa 27th Nov 09
				  ,p_dunning_mode             => p_dunning_mode
				  ,p_parent_request_id        => p_parent_request_id
				  ,p_org_id                   => l_org_id
				  ,x_request_id               => l_request_id
				  ,x_return_status            => x_return_status
				  ,x_msg_count                => x_msg_count
				  ,x_msg_data                 => x_msg_data
				  ,x_contact_destination      => l_contact_destination
				  ,x_contact_party_id         => l_contact_party_id);
			 end if;

			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SEND status='|| x_return_status);
			 --End adding for bug 8489610 by gnramasa 14-May-09

			 IF x_return_status <> FND_API.G_RET_STS_SUCCESS and x_return_status <> 'W'  THEN
			     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  Sending process failed');
			     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sending process failed ');
			     x_return_status := FND_API.G_RET_STS_ERROR;
			     GOTO end_api;
			 elsif x_return_status = 'W' then
			     l_warning_flag := 'W';
			 END IF;

			  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id = ' ||l_request_id);
			  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Request Id = ' || l_request_id);
			  l_ffm_cnt := l_ffm_cnt + 1;

			    l_dunning_rec_upd.dunning_id := l_dunning_id;
			    if (l_curr_dmethod = 'FFM') then
				l_dunning_rec_upd.ffm_request_id := l_request_id;
			    else
				l_dunning_rec_upd.xml_request_id := l_request_id;
			    end if;

			    l_amount	:= staged_dunn_amt_due_remaining(l_dunning_id);
			    if (p_running_level = 'CUSTOMER') then
				  l_curr_code                       := party_currency_code(l_object_id);
			      elsif (p_running_level = 'ACCOUNT') then
				  l_curr_code                       := acct_currency_code(l_object_id);
			      elsif (p_running_level = 'BILL_TO') then
				  l_curr_code                       := site_currency_code(l_object_id);
			      end if;

			      l_dunning_rec_upd.amount_due_remaining := l_amount;
			      l_dunning_rec_upd.currency_code := l_curr_code;
			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_rec_upd.amount_due_remaining = ' ||l_dunning_rec_upd.amount_due_remaining);
			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_rec_upd.currency_code = ' ||l_dunning_rec_upd.currency_code);

			    IEX_DUNNING_PVT.Update_DUNNING(
				p_api_version              => 1.0
				, p_init_msg_list            => FND_API.G_FALSE
				, p_commit                   => FND_API.G_TRUE
				, p_dunning_rec              => l_dunning_rec_upd
				, x_return_status            => l_return_status
				, x_msg_count                => l_msg_count
				, x_msg_data                 => l_msg_data
			    );
		 end if; --if (upper(p_single_staged_letter) = 'N') then

	<<c_dunning_plan_lines>>
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - c_dunning_plan_lines');
	end loop;
	close sql_cur;

	 if ( (upper(p_single_staged_letter) = 'Y') and (l_dunning_id is not null) ) then

		  /*===========================================
		   * Send letter thru fulfillment
		   *===========================================*/
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SEND_FFM');
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - org_id='||l_org_id);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - party_id='||l_party_cust_id);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - method='||l_method);

		 if (l_curr_dmethod = 'FFM') then
			 select template_id
			 into l_xdo_template_id
			 from iex_dunnings
			 where dunning_id = l_dunning_id;
		else
			select xml_template_id
			 into l_xdo_template_id
			 from iex_dunnings
			 where dunning_id = l_dunning_id;
		end if;
		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_xdo_template_id='||l_xdo_template_id);

		 l_bind_tbl(1).key_name := 'party_id';
		 l_bind_tbl(1).key_type := 'NUMBER';
		 l_bind_tbl(1).key_value := l_party_cust_id;
		 l_bind_tbl(2).key_name := 'org_id';
		 l_bind_tbl(2).key_type := 'NUMBER';
		 l_bind_tbl(2).key_value := l_org_id;
		 l_bind_tbl(3).key_name := 'account_id';
		 l_bind_tbl(3).key_type := 'NUMBER';
		 l_bind_tbl(3).key_value := l_account_id;
		 -- new bind rec since 11.5.10 (for BILL_TO)
		 l_bind_tbl(4).key_name := 'customer_site_use_id';
		 l_bind_tbl(4).key_type := 'NUMBER';
		 l_bind_tbl(4).key_value := l_customer_site_use_id;
		 l_bind_tbl(5).key_name := 'DUNNING_ID';
		 l_bind_tbl(5).key_type := 'NUMBER';
		 l_bind_tbl(5).key_value := l_dunning_id;

		/**
		 * in 11.5.11, IEX supports fulfillment and xml publisher.
		 * it depends on the set up in IEX ADMIN/SETUP.
		 */
		 if (l_curr_dmethod = 'FFM') then

		  Send_Fulfillment(p_api_version              => p_api_version
				  ,p_init_msg_list            => FND_API.G_FALSE
				  ,p_commit                   => FND_API.G_TRUE
				  ,p_fulfillment_bind_tbl     => l_bind_tbl
				  ,p_template_id              => l_template_id
				  ,p_method                   => l_method
				  ,p_party_id                 => l_party_cust_id
				  ,x_request_id               => l_request_id
				  ,x_return_status            => x_return_status
				  ,x_msg_count                => x_msg_count
				  ,x_msg_data                 => x_msg_data
				  ,x_contact_destination      => l_contact_destination
				  ,x_contact_party_id         => l_contact_party_id
														);
		 else

		  Send_XML(p_api_version              => p_api_version
			  ,p_init_msg_list            => FND_API.G_FALSE
			  ,p_commit                   => FND_API.G_TRUE
			  ,p_resend                   => 'N'
			  ,p_request_id               => null
			  ,p_fulfillment_bind_tbl     => l_bind_tbl
			  ,p_template_id              => l_xdo_template_id
			  ,p_method                   => l_method
			  ,p_party_id                 => l_party_cust_id
			  ,p_level                    => p_running_level
			  ,p_source_id                => l_object_id
			  ,p_object_code              => l_object_code
			  ,p_object_id                => l_object_id
			  ,p_dunning_mode             => p_dunning_mode
			  ,p_parent_request_id        => p_parent_request_id
			  ,x_request_id               => l_request_id
			  ,x_return_status            => x_return_status
			  ,x_msg_count                => x_msg_count
			  ,x_msg_data                 => x_msg_data
			  ,x_contact_destination      => l_contact_destination
			  ,x_contact_party_id         => l_contact_party_id);
		 end if;

		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SEND status='|| x_return_status);
		 --End adding for bug 8489610 by gnramasa 14-May-09

		 IF x_return_status <> FND_API.G_RET_STS_SUCCESS and x_return_status <> 'W'  THEN
		     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  Sending process failed');
		     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sending process failed ');
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     GOTO end_api;
		 elsif x_return_status = 'W' then
		     l_warning_flag := 'W';
		 END IF;

		  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id = ' ||l_request_id);
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Request Id = ' || l_request_id);
		  l_ffm_cnt := l_ffm_cnt + 1;

		    l_dunning_rec_upd.dunning_id := l_dunning_id;
		    if (l_curr_dmethod = 'FFM') then
			l_dunning_rec_upd.ffm_request_id := l_request_id;
		    else
			l_dunning_rec_upd.xml_request_id := l_request_id;
		    end if;

		    IEX_DUNNING_PVT.Update_DUNNING(
			p_api_version              => 1.0
			, p_init_msg_list            => FND_API.G_FALSE
			, p_commit                   => FND_API.G_TRUE
			, p_dunning_rec              => l_dunning_rec_upd
			, x_return_status            => l_return_status
			, x_msg_count                => l_msg_count
			, x_msg_data                 => l_msg_data
		    );
	 end if; --if ( (upper(p_single_staged_letter) = 'Y') and (l_dunning_id is not null) ) then

          <<end_api>>

	  --Start bug 9696806 gnramasa 27th May 10
		if p_dunning_mode = 'DRAFT'  then
			if (p_running_level = 'CUSTOMER') then
				update iex_delinquencies del
				set staged_dunning_level = 99
				where del.party_cust_id = l_object_id
				and staged_dunning_level = 98
				and status in ('DELINQUENT','PREDELINQUENT')
				and exists (select count(iet.DUNNING_ID)
						from iex_dunning_transactions iet,
						     iex_dunnings dunn
						 where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
							    and dunn.dunning_id = iet.dunning_id
							    and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
								    OR (dunn.dunning_mode = 'FINAL'))
						 and iet.STAGE_NUMBER = 99
						 and dunn.delivery_status is null
					    );

			elsif  (p_running_level = 'ACCOUNT') then
				update iex_delinquencies del
				set staged_dunning_level = 99
				where del.cust_account_id = l_object_id
				and staged_dunning_level = 98
				and status in ('DELINQUENT','PREDELINQUENT')
				and exists (select count(iet.DUNNING_ID)
						from iex_dunning_transactions iet,
						     iex_dunnings dunn
						 where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
							    and dunn.dunning_id = iet.dunning_id
							    and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
								    OR (dunn.dunning_mode = 'FINAL'))
						 and iet.STAGE_NUMBER = 99
						 and dunn.delivery_status is null
					    );

			elsif  (p_running_level = 'BILL_TO') then
				update iex_delinquencies del
				set staged_dunning_level = 99
				where del.customer_site_use_id = l_object_id
				and staged_dunning_level = 98
				and status in ('DELINQUENT','PREDELINQUENT')
				and exists (select count(iet.DUNNING_ID)
						from iex_dunning_transactions iet,
						     iex_dunnings dunn
						 where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
							    and dunn.dunning_id = iet.dunning_id
							    and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
								    OR (dunn.dunning_mode = 'FINAL'))
						 and iet.STAGE_NUMBER = 99
						 and dunn.delivery_status is null
					    );
			end if;

		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Updated : ' || SQL%ROWCOUNT || ' number of row''s staged_dunning_level from 98 to 99');
		    commit;
		end if;

	  --End bug 9696806 gnramasa 27th May 10

          if (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              for i in 1..x_msg_count loop
                errmsg := FND_MSG_PUB.Get(p_msg_index => i,
                                          p_encoded => 'F');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error:'||errmsg);
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  errmsg=' || errmsg);
              end loop;
          end if;
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_api');

     ELSE -- l_noskip = 0
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - all del disputed');
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - skip this party/accnt/site');
          if (l_turnoff_coll_on_bankru = 'Y' and l_no_of_bankruptcy >0 ) then
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'Profile IEX: Turn Off Collections Activity for Bankruptcy is Yes and bankruptcy record is exist, so will skip send dunning' );
	  else
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'all delinquencies disputed' );
	  end if;
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'skip this party/account/site' );
          FND_MSG_PUB.Count_And_Get(  p_count          =>   x_msg_count,
                                      p_data           =>   x_msg_data );
          x_return_status := 'SKIP'; --FND_API.G_EXC_ERROR;

     end if; -- end of if (l_noskip>0)

     if l_warning_flag = 'W' then
      x_return_status := 'W';
     end if;

     --
     -- End of API body
     --

     COMMIT WORK;

     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END');

     FND_MSG_PUB.Count_And_Get
     (  p_count          =>   x_msg_count,
        p_data           =>   x_msg_data );

     EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             COMMIT WORK;
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'expect exception' );
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);


         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             COMMIT WORK;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception');
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'unexpect exception' );
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);


         WHEN OTHERS THEN
             COMMIT WORK;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception');
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'unexpect exception' );
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);

END Send_Level_Staged_Dunning;

/*==========================================================================
 * clchang updated 09/19/2002 -
 *     insert ffm_request_id into iex_dunnings after CALL_FFM successfully;
 *     Create_Dunning and Update_Dunning also updated;
 *
 *==========================================================================*/
Procedure Send_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_dunning_plan_id         in number,
            p_resend_flag             IN VARCHAR2,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_parent_request_id       IN NUMBER,
	    p_dunning_mode	      IN VARCHAR2,     -- added by gnramasa for bug 8489610 14-May-09
	    p_confirmation_mode	      IN   VARCHAR2,   -- added by gnramasa for bug 8489610 14-May-09
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
    CURSOR C_GET_DEL (IN_del_ID NUMBER) IS
      SELECT delinquency_ID,
             party_cust_id,
             cust_account_id,
             customer_site_use_id,
             score_value
        FROM IEX_DELINQUENCIES
       WHERE delinquency_ID = in_del_ID;
    --
    CURSOR C_GET_SCORE (IN_ID NUMBER) IS
      SELECT a.score_value
        FROM IEX_SCORE_HISTORIES a
       WHERE a.score_object_ID = in_ID
         AND a.score_object_code = 'IEX_DELINQUENCY'
         AND a.creation_date = (select max(b.creation_date)
                                  from iex_score_histories b
                                 where b.score_object_id = in_id
                                   AND b.score_object_code = 'IEX_DELINQUENCY');
    --
    CURSOR C_GET_TEMPLATE (l_line_id NUMBER,
                           l_score NUMBER, p_dunning_plan_id number) IS
      SELECT x.template_id,
             x.xdo_template_id,
             x.fm_method,
             upper(x.callback_flag),
             x.callback_days,
             ar.bucket_name
        FROM IEX_AG_DN_XREF x,
             ar_aging_buckets ar,
             iex_dunning_plans_vl d
       WHERE x.aging_bucket_line_ID = l_line_ID
         and x.dunning_plan_id = p_dunning_plan_id
         AND l_score between x.score_range_low and x.score_range_high
         AND x.aging_bucket_id = ar.aging_bucket_id
         and ar.aging_bucket_id = d.aging_bucket_id
         AND ar.status = 'A'
         AND x.dunning_level = 'DELINQUENCY' ;
    --
    cursor c_amount (IN_ID number) is
     select ps.amount_due_remaining,
            ps.invoice_currency_code
       from ar_payment_schedules_all ps,
            --iex_delinquencies_all del
            iex_delinquencies del
      where ps.payment_schedule_id (+)= del.payment_schedule_id
        and del.delinquency_id = in_id;
    --

    l_AMOUNT                NUMBER;
    l_CURR_CODE             VARCHAR2(15);
    l_DUNNING_id            NUMBER;
    l_delinquency_id        NUMBER;
    l_party_cust_id         NUMBER;
    l_account_id            NUMBER;
    l_customer_site_use_id  NUMBER;
    l_location_id           number;
    l_dunning_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_dunning_rec_upd       IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_score                 NUMBER;
    l_bucket_line_id        NUMBER;
    l_campaign_sched_id     NUMBER;
    l_template_id           NUMBER;
    l_xdo_template_id       NUMBER;
    l_method                VARCHAR2(10);
    l_callback_flag         VARCHAR2(1);
    l_callback_days         NUMBER;
    l_callback_date         DATE;
    l_request_id            NUMBER;
    l_outcome_code          varchar2(20);
    l_api_name              CONSTANT VARCHAR2(30) := 'Send_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);
    --
    nIdx                    NUMBER := 0;
    TYPE Del_ID_TBL_type is Table of IEX_DELINQUENCIES_ALL.DELINQUENCY_ID%TYPE
                            INDEX BY BINARY_INTEGER;
    Del_Tbl                 Del_ID_TBL_TYPE;
    l_bind_tbl              IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
    l_bind_rec              IEX_DUNNING_PVT.FULFILLMENT_BIND_REC;
    l_org_id                NUMBER ;
    --l_delid_tbl             IEX_DUNNING_PUB.DelId_NumList;
    l_del_tbl               IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE;
    l_ffm_cnt               NUMBER := 0;
    l_dunn_cnt              NUMBER := 0;
    l_bucket                VARCHAR2(100);

    l_running_level         VARCHAR2(25);
    l_object_Code           VARCHAR2(25);
    l_object_id             NUMBER;

    l_curr_dmethod          VARCHAR2(10);
    l_contact_destination   varchar2(240);  -- bug 3955222
    l_contact_party_id      number; -- bug 3955222
    l_contact_id            number;
    l_warning_flag          varchar2(1);
    l_contact_point_id      number;
    l_fully_promised        number := 1;  -- Added for bug#8408162
    l_allow_send            varchar2(1) :='Y'; -- Added for bug#8408162
    l_status                varchar2(10);
    --Start adding for bug 9156833 gnramasa 27th Nov 09
    l_validation_level		  NUMBER ;
    l_resource_tab		  iex_utilities.resource_tab_type;
    l_resource_id		  NUMBER;
    --End adding for bug 9156833 gnramasa 27th Nov 09
    l_turnoff_coll_on_bankru	  varchar2(10);
    l_no_of_bankruptcy		  number;

    cursor c_no_of_bankruptcy (p_par_id number)
    is
    select nvl(count(*),0)
    from iex_bankruptcies
    where party_id = p_par_id
    and (disposition_code in ('GRANTED','NEGOTIATION')
         OR (disposition_code is NULL));

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Send_DUNNING_PVT;

      --Bug#4679639 schekuri 20-OCT-2005
      --Value of profile ORG_ID shouldn't be used for getting ORG_ID after MOAC implementation
      --l_org_id        := fnd_profile.value('ORG_ID');
      l_org_id:= mo_global.get_current_org_id;
      WriteLog(' org_id in send dunning '|| l_org_id);
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ' || p_resend_flag);
      l_turnoff_coll_on_bankru	:= nvl(fnd_profile.value('IEX_TURNOFF_COLLECT_BANKRUPTCY'),'N');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_turnoff_coll_on_bankru: ' || l_turnoff_coll_on_bankru);

      FOR i in 1..p_delinquencies_tbl.count
      LOOP
          l_delinquency_id := p_delinquencies_tbl(i).delinquency_id;
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==================');
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ' || l_delinquency_Id);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'delinquency_id='||l_delinquency_id );

          -- Validate Data

         /*=============================================================
          *  For each Delinquency,
          *=============================================================*/

         l_party_cust_id := p_delinquencies_tbl(i).party_cust_id;
         l_account_id := p_delinquencies_tbl(i).cust_account_id;
         l_customer_site_use_id := p_delinquencies_tbl(i).customer_site_use_id;
         l_score := p_delinquencies_tbl(i).score_value;


          --WriteLog('iexvdunb.pls:SendDunn:open del='||l_delinquency_Id);
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - '||l_party_cust_id);
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - '||l_account_id);
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - '||l_customer_site_use_id);
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - '||l_score);
          -- Start for the bug#8408162 by PNAVEENK
	  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Start Fully Promise Check');
	  SELECT count(1)
		into l_fully_promised
	       FROM ar_payment_schedules_all ps, iex_delinquencies_all del
		WHERE del.delinquency_id= l_delinquency_id
	        AND ps.payment_schedule_id = del.payment_schedule_id
	        AND ps.status = 'OP'
	        AND del.status IN ('DELINQUENT', 'PREDELINQUENT')
		and not exists(select 1
	        from iex_promise_details pd where pd.delinquency_id=del.delinquency_id
		and pd.status='COLLECTABLE'
		and pd.state='PROMISE'
	        group by pd.delinquency_id
		having sum(nvl(pd.promise_amount,0))>=ps.amount_due_remaining);
	  select fnd_profile.value(nvl('IEX_ALLOW_DUN_FULL_PROMISE','N')) into l_allow_send from dual;

	  if l_turnoff_coll_on_bankru = 'Y' then
		open c_no_of_bankruptcy (l_party_cust_id);
		fetch c_no_of_bankruptcy into l_no_of_bankruptcy;
		close c_no_of_bankruptcy;
	  end if;
	  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_no_of_bankruptcy: ' || l_no_of_bankruptcy);

	  IF ( l_fully_promised = 0 and l_allow_send = 'Y' OR (l_turnoff_coll_on_bankru = 'Y' and l_no_of_bankruptcy >0)) then
	   goto end_loop;
	  END IF;

	   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' End Fully Promise Check');

	   -- End for the bug#8408162 by PNAVEENK
          /*================================================================
           * IsDispute ?
           * If yes => stop (exit);
           * else continue;
           *
           * it returns values :
           * 1) it returns 'F' if no dispute exists for the delinquency
           * 2) it returns 'T' if dispute exists and is pending
           * 3) it returns 'F' if dispute exists and its staus is "COMPLETE"
           *================================================================*/

          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Chk IsDispute');

            IEX_DISPUTE_PVT.Is_Delinquency_Dispute(
              p_api_version              => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_delinquency_id           => l_delinquency_id
            , x_return_status            => x_return_status
            , x_msg_count                => x_msg_count
            , x_msg_data                 => x_msg_data);

            IF x_return_status = 'T' THEN
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Dispute exists and is pending');
               FND_FILE.PUT_LINE(FND_FILE.LOG, 'Dispute exists and is pending' );
               GOTO end_loop;
            elsif x_return_status = 'F' THEN
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No Dispute or status is COMPLETE');
            END IF;

           /*===========================================
            * Get Score From IEX_SCORE_HISTORIES
            * If NotFound => Call API to getScore;
            *===========================================*/

           /*===========================================
            * get Aging_Bucket_Line_Id for each Del
            *===========================================*/

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetAgingBucketLineId');
            --WriteLog('iexvdunb:SendDunn:delid='||l_delinquency_id);

              AGING_DEL(p_api_version              => p_api_version
				               , p_init_msg_list            => p_init_msg_list
				               , p_commit                   => p_commit
				               , p_delinquency_id           => l_delinquency_id
				               , p_dunning_plan_id          => p_dunning_plan_id
				               , p_bucket                   => l_bucket
				               , x_return_status            => x_return_status
				               , x_msg_count                => x_msg_count
				               , x_msg_data                 => x_msg_data
				               , x_aging_bucket_line_id     => l_bucket_line_id);

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - AgingDel status='||x_return_status);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               --FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
               --FND_MESSAGE.Set_Token ('INFO', 'iex:AginBucketLineId', FALSE);
                FND_MESSAGE.Set_Name('IEX', 'IEX_NO_AGINGBUCKETLINE');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Get AgingBucketLineId');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot AgingBucketLineId' );
                --msg
                FND_MSG_PUB.Count_And_Get
                (  p_count          =>   x_msg_count,
                   p_data           =>   x_msg_data );
                for i in 1..x_msg_count loop
                    errmsg := FND_MSG_PUB.Get(p_msg_index => i,
                                              p_encoded => 'F');
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error:'||errmsg);
                    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errmsg=' || errmsg);
                end loop;

                GOTO end_loop;
              END IF;

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - lineid='||l_bucket_line_id);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EndAgingDel');


           /*===========================================
            * Get Template_ID From iex_ag_dn_xref
            *===========================================*/

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GET Template');

           Open C_Get_TEMPLATE(l_bucket_line_ID, l_score, p_dunning_plan_id);
           Fetch C_Get_TEMPLATE into
                 l_template_id,
                 l_xdo_template_id,
                 l_method,
                 l_callback_flag,
                 l_callback_days,
                 l_bucket;

           If ( C_GET_TEMPLATE%NOTFOUND) Then
               FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
               FND_MSG_PUB.Add;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Missing corresponding template');
               FND_FILE.PUT_LINE(FND_FILE.LOG, 'Missing corresponding template' );
               Close C_Get_TEMPLATE;
               GOTO end_loop;
           END IF;

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - close C_GET_TEMPLATE');
           Close C_Get_TEMPLATE;

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get ffm_template_id='||l_template_id);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get xdo_template_id='||l_xdo_template_id);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get bucket='||l_bucket);

          /*===========================================
           * Check template
           *  in 11.5.11, IEX supports fulfillment and xml publisher.
           *  if the current setup for delivery id FFM,
           *  then template_id is necessary;
           *  if XML, xdo_template_id is necessary;
           *===========================================*/

           l_curr_dmethod := IEX_SEND_XML_PVT.getCurrDeliveryMethod;
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - curr d_method='||l_curr_dmethod);
           if ( (l_curr_dmethod is null or l_curr_dmethod = '') or
                (l_curr_dmethod = 'FFM' and l_template_id is null)  or
                (l_curr_dmethod = 'XML' and l_xdo_template_id is null ) ) then
                --FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
                --FND_MESSAGE.Set_Token ('INFO', 'Template_ID', FALSE);
                FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Missing corresponding template');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Missing corresponding template' );
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_loop;
           end if;

          /*===========================================
           * Check profile before send dunning
           *===========================================*/

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - begin check customer profile');
            -- ctlee - check the hz_customer_profiles.dunning_letter
           if ( iex_utilities.DunningProfileCheck (
                   p_party_id => l_party_cust_id
                   , p_cust_account_id => l_account_id
                   , p_site_use_id => l_customer_site_use_id
                   , p_delinquency_id => l_delinquency_id     ) = 'N'
              ) then
                FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_PROFILE_NO');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Send dunning in customer profile set to no ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Send dunning in customer profile set to no ');
                GOTO end_loop;
           end if;


           -- ctlee - check the hz_customer_profiles_amt min_dunning_invoice_amount and min_dunning_amount
           if ( iex_utilities.DunningMinAmountCheck (
                    p_cust_account_id => l_account_id
                    , p_site_use_id => l_customer_site_use_id)  = 'N'
              ) then
                FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_AMOUNT_MIN');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Required min Dunning amount in customer profile ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Required min Dunning amount in customer profile ');
                GOTO end_loop;
           end if;

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end check customer profile');

           --Start adding for bug 8489610 by gnramasa 14-May-09
	 if p_dunning_mode <> 'DRAFT' then
		   /*===========================================
		    * Close OPEN Dunnings for each Del
		    *===========================================*/

		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning');
		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - runninglevel=DELINQUENCY');
		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_id);
		      l_del_tbl(1).delinquency_id := l_delinquency_id;

		      /*if p_dunning_mode = 'DRAFT' then
			l_status := 'CLOSE';
		      else
			l_status := 'OPEN';
		      end if;
		      */

		      Close_DUNNING(p_api_version              => p_api_version
								, p_init_msg_list            => p_init_msg_list
								, p_commit                   => p_commit
								, p_delinquencies_tbl        => l_del_tbl
								, p_running_level            => 'DELINQUENCY'
								--, p_status                   => l_status
								, x_return_status            => x_return_status
								, x_msg_count                => x_msg_count
								, x_msg_data                 => x_msg_data);

		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning status='|| x_return_status);

		      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Close Dunning');
			 --msg
			 GOTO end_loop;
		      END IF;
		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EndCloseDunn');
	 end if;

           /*===========================================
            * Create Dunning Record
            *===========================================*/

              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get CallbackDate');
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag='||l_callback_flag);
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDays='||l_callback_days);

           /*===================================================
            * clchang updated 02/13/2003
            * callback_days could be null if callback_yn = 'N';
            * and if callback_yn = 'N', not get callback_date;
            *==================================================*/
            IF (l_callback_flag = 'Y') THEN
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is Y: NOTGetCallbackDate');
               Get_Callback_Date(p_init_msg_list        => p_init_msg_list
		                           , p_callback_days        => l_callback_days
		                           , x_callback_date        => l_callback_date
		                           , x_return_status        => x_return_status
		                           , x_msg_count            => x_msg_count
		                           , x_msg_data             => x_msg_data);

               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetCallbackDate status='|| x_return_status);
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDate='||l_callback_date);

               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Not Get CallbackDate');
                 GOTO end_loop;
               END IF;

            ELSE
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is N: NOTGetCallbackDate');
            END IF;


            /* get the current amount_due_remaining and currency_code */
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GET AMOUNT');

            Open C_AMOUNT(l_delinquency_id);
            Fetch C_AMOUNT into
                l_amount,
                l_curr_code;

            If ( C_AMOUNT%NOTFOUND) Then
               FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'iex:amount', FALSE);
               FND_MSG_PUB.Add;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - amount notfound');
            END IF;

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - close C_AMOUNT');
            Close C_AMOUNT;

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get amount='||l_amount);
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get currcode='||l_curr_code);
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning');
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_id);
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_id='||l_delinquency_id);

            l_dunning_rec.delinquency_id := l_delinquency_id;
            l_dunning_rec.callback_yn := l_callback_flag;
            l_dunning_rec.callback_date := l_callback_date;

	     if p_dunning_mode = 'DRAFT' then
		l_dunning_rec.status := 'CLOSE';
	     else
		l_dunning_rec.status := 'OPEN';
	     end if;

            l_dunning_rec.dunning_method:= l_method;
            l_dunning_rec.template_id:= l_template_id;
            l_dunning_rec.xml_template_id:= l_xdo_template_id;
            l_dunning_rec.campaign_sched_id := l_campaign_sched_id;
            l_dunning_rec.xml_request_id := l_request_id;
            l_dunning_rec.dunning_object_id := l_delinquency_id;
            l_dunning_rec.dunning_level := 'DELINQUENCY';
            l_dunning_rec.object_type := 'IEX_DELINQUENCY';
            l_dunning_rec.object_id := l_delinquency_id;
            l_dunning_rec.amount_due_remaining := l_amount;
            l_dunning_rec.currency_code := l_curr_code;
            l_dunning_rec.dunning_plan_id := p_dunning_plan_id;
            l_dunning_rec.contact_destination := l_contact_destination;  -- bug 3955222
            l_dunning_rec.contact_party_id := l_contact_party_id;  -- bug 3955222
	    --Start adding for bug 8489610 by gnramasa 14-May-09
	    l_dunning_rec.dunning_mode := p_dunning_mode;
	    l_dunning_rec.confirmation_mode := p_confirmation_mode;

	    l_dunning_rec.org_id := l_org_id; -- added for bug 9151851

	     if p_parent_request_id is not null then
		l_dunning_rec.request_id := p_parent_request_id;
	     else
		l_dunning_rec.request_id := FND_GLOBAL.Conc_Request_Id;
	     end if;
             WriteLog(' Before creating dunning org_id '|| l_org_id);
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');

            CREATE_DUNNING(p_api_version              => p_api_version
							            , p_init_msg_list            => p_init_msg_list
							            , p_commit                   => p_commit
							            , p_dunning_rec              => l_dunning_rec
							            , x_dunning_id               => l_dunning_id
							            , x_return_status            => x_return_status
							            , x_msg_count                => x_msg_count
							            , x_msg_data                 => x_msg_data);

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning status='|| x_return_status);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Dunning');
              GOTO end_loop;
            END IF;

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunningId='||l_dunning_id);
            --FND_FILE.PUT_LINE(FND_FILE.LOG, 'Create Dunning Id=' ||l_dunning_id);
            l_dunn_cnt := l_dunn_cnt + 1;

           /*===========================================
            * Send Letter through Fulfillment
            *===========================================*/
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Send_Ffm');
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - org_id = '|| l_org_id);
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - party_id = '|| l_party_cust_id);
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - acct_id = '|| l_account_id);
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - site_use_id = '|| l_customer_site_use_id);
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bucket_line_id = '|| l_bucket_line_id);
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delinquency_id = '|| l_delinquency_id);

            l_bind_tbl(1).key_name := 'party_id';
            l_bind_tbl(1).key_type := 'NUMBER';
            l_bind_tbl(1).key_value := l_party_cust_id;
            l_bind_tbl(2).key_name := 'org_id';
            l_bind_tbl(2).key_type := 'NUMBER';
            l_bind_tbl(2).key_value := l_org_id;
            l_bind_tbl(3).key_name := 'bucket_line_id';
            l_bind_tbl(3).key_type := 'NUMBER';
            l_bind_tbl(3).key_value := l_bucket_line_id;
            l_bind_tbl(4).key_name := 'account_id';
            l_bind_tbl(4).key_type := 'NUMBER';
            l_bind_tbl(4).key_value := l_account_id;
            l_bind_tbl(5).key_name := 'delinquency_id';
            l_bind_tbl(5).key_type := 'NUMBER';
            l_bind_tbl(5).key_value := l_delinquency_id;
            -- added for BILL_TO in 11.5.10.
            l_bind_tbl(6).key_name := 'customer_site_use_id';
            l_bind_tbl(6).key_type := 'NUMBER';
            l_bind_tbl(6).key_value := l_customer_site_use_id;
            l_bind_tbl(7).key_name := 'DUNNING_ID';
            l_bind_tbl(7).key_type := 'NUMBER';
            l_bind_tbl(7).key_value := l_dunning_id;

	 --Start adding for bug 9156833 gnramasa 27th Nov 09
	 l_validation_level := FND_API.G_VALID_LEVEL_FULL;

	 iex_utilities.get_dunning_resource(p_api_version => p_api_version,
			       p_init_msg_list     => FND_API.G_TRUE,
			       p_commit            => FND_API.G_FALSE,
			       p_validation_level  => l_validation_level,
			       p_level             => 'DUNNING_BILLTO',
			       p_level_id          => l_customer_site_use_id,
			       x_msg_count         => l_msg_count,
			       x_msg_data          => l_msg_data,
			       x_return_status     => l_return_status,
			       x_resource_tab      => l_resource_tab);
	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
	     x_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;

	  if l_resource_tab.count>0 then
	    l_resource_id := l_resource_tab(1).resource_id;
	  end if;
	  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_resource_id: ' || l_resource_id);
	  --End adding for bug 9156833 gnramasa 27th Nov 09

            if (l_curr_dmethod = 'FFM') then
               Send_Fulfillment(p_api_version              => p_api_version
                               ,p_init_msg_list            => FND_API.G_TRUE
                               ,p_commit                   => FND_API.G_TRUE
                               ,p_fulfillment_bind_tbl     => l_bind_tbl
                               ,p_template_id              => l_template_id
                               ,p_method                   => l_method
                               ,p_party_id                 => l_party_cust_id
                               ,x_request_id               => l_request_id
                               ,x_return_status            => x_return_status
                               ,x_msg_count                => x_msg_count
						                   ,x_msg_data                 => x_msg_data
							                 ,x_contact_destination      => l_contact_destination
							                 ,x_contact_party_id         => l_contact_party_id );
            else
               l_running_level := 'DELINQUENCY';
               l_object_code := 'IEX_DELINQUENCY';
               l_object_id := l_delinquency_id;

               Send_XML(p_api_version              => p_api_version
                       ,p_init_msg_list            => FND_API.G_TRUE
                       ,p_commit                   => FND_API.G_TRUE
                       ,p_resend                   => 'N'
                       ,p_request_id               => null
                       ,p_fulfillment_bind_tbl     => l_bind_tbl
                       ,p_template_id              => l_xdo_template_id
                       ,p_method                   => l_method
                       ,p_party_id                 => l_party_cust_id
                       ,p_level                    => l_running_level
                       ,p_source_id                => l_object_id
                       ,p_object_code              => l_object_code
                       ,p_object_id                => l_object_id
		       ,p_resource_id              => l_resource_id --Added for bug 9156833 gnramasa 27th Nov 09
		       ,p_dunning_mode             => p_dunning_mode
		       ,p_parent_request_id        => p_parent_request_id
                       ,p_org_id                   => l_org_id
		       ,x_request_id               => l_request_id
                       ,x_return_status            => x_return_status
                       ,x_msg_count                => x_msg_count
 		                   ,x_msg_data                 => x_msg_data
		                   ,x_contact_destination      => l_contact_destination
		                   ,x_contact_party_id         => l_contact_party_id);

            end if;

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Send status = ' || x_return_status);
	    --End adding for bug 8489610 by gnramasa 14-May-09

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS and x_return_status <> 'W' THEN
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Not Sending Letters');
               FND_MSG_PUB.Count_And_Get(p_count          =>   x_msg_count,
                                         p_data           =>   x_msg_data );
               for i in 1..x_msg_count loop
                  errmsg := FND_MSG_PUB.Get(p_msg_index => i,
                                            p_encoded => 'F');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error:'||errmsg);
                  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errmsg=' || errmsg);
               end loop;
               GOTO end_loop;
            elsif x_return_status = 'W' then
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - setting warning flag');
              l_warning_flag := 'W';
            end if;

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id='||l_request_id);

            l_dunning_rec_upd.dunning_id := l_dunning_id;
            if (l_curr_dmethod = 'FFM') then
                l_dunning_rec_upd.ffm_request_id := l_request_id;
            else
                l_dunning_rec_upd.xml_request_id := l_request_id;
            end if;

            IEX_DUNNING_PVT.Update_DUNNING(p_api_version              => 1.0
													                , p_init_msg_list            => FND_API.G_TRUE
													                , p_commit                   => FND_API.G_TRUE
													                , p_dunning_rec              => l_dunning_rec_upd
													                , x_return_status            => l_return_status
													                , x_msg_count                => l_msg_count
													                , x_msg_data                 => l_msg_data);

            l_ffm_cnt := l_ffm_cnt + 1;

           /*===========================================
            * Update Delinquency
            * Set DUNN_YN = 'N'
            *===========================================*/
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateDel');

              nIdx := nIdx + 1;
              del_tbl(nIdx) := l_delinquency_id;

            <<end_loop>>
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_loop');
            NULL;

      END LOOP; -- end of DELINQUENCIES_TBL loop

     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========Summarty==========');
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SendFFM Cnt='||l_ffm_cnt);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunn Cnt='||l_dunn_cnt);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========End Summarty==========');

      --
      -- End of API body
      --
      if l_warning_flag = 'W' then
        x_return_status := 'W';
      end if;

      COMMIT WORK;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return status = ' || x_return_status);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              COMMIT WORK;
              x_return_status := FND_API.G_RET_STS_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              COMMIT WORK;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              COMMIT WORK;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

END Send_Dunning;

/*==========================================================================
 * gnramasa created 30th Dec 2009 -
 * Single Stage Letter is not menaingful option at delinquency level
 * Include current invoices, Unapplied receipts also not valid.
 *==========================================================================*/
Procedure Send_Staged_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_dunning_plan_id         in number,
	    p_correspondence_date     IN DATE,
            p_resend_flag             IN VARCHAR2,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_parent_request_id       IN NUMBER,
	    p_dunning_mode	      IN VARCHAR2,     -- added by gnramasa for bug 8489610 14-May-09
	    p_single_staged_letter    IN VARCHAR2 DEFAULT 'N',    -- added by gnramasa for bug stageddunning 30-Dec-09
	    p_confirmation_mode	      IN   VARCHAR2,   -- added by gnramasa for bug 8489610 14-May-09
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
    CURSOR C_GET_DEL (IN_del_ID NUMBER) IS
      SELECT delinquency_ID,
             party_cust_id,
             cust_account_id,
             customer_site_use_id,
             score_value
        FROM IEX_DELINQUENCIES
       WHERE delinquency_ID = in_del_ID;
    --
    CURSOR C_GET_SCORE (IN_ID NUMBER) IS
      SELECT a.score_value
        FROM IEX_SCORE_HISTORIES a
       WHERE a.score_object_ID = in_ID
         AND a.score_object_code = 'IEX_DELINQUENCY'
         AND a.creation_date = (select max(b.creation_date)
                                  from iex_score_histories b
                                 where b.score_object_id = in_id
                                   AND b.score_object_code = 'IEX_DELINQUENCY');
    --
    CURSOR C_GET_TEMPLATE (l_line_id NUMBER,
                           l_score NUMBER, p_dunning_plan_id number) IS
      SELECT x.template_id,
             x.xdo_template_id,
             x.fm_method,
             upper(x.callback_flag),
             x.callback_days,
             ar.bucket_name
        FROM IEX_AG_DN_XREF x,
             ar_aging_buckets ar,
             iex_dunning_plans_vl d
       WHERE x.aging_bucket_line_ID = l_line_ID
         and x.dunning_plan_id = p_dunning_plan_id
         AND l_score between x.score_range_low and x.score_range_high
         AND x.aging_bucket_id = ar.aging_bucket_id
         and ar.aging_bucket_id = d.aging_bucket_id
         AND ar.status = 'A'
         AND x.dunning_level = 'DELINQUENCY' ;
    --
    cursor c_amount (IN_ID number) is
     select ps.amount_due_remaining,
            ps.invoice_currency_code
       from ar_payment_schedules_all ps,
            --iex_delinquencies_all del
            iex_delinquencies del
      where ps.payment_schedule_id (+)= del.payment_schedule_id
        and del.delinquency_id = in_id;
    --

    l_AMOUNT                NUMBER;
    l_CURR_CODE             VARCHAR2(15);
    l_DUNNING_id            NUMBER;
    l_delinquency_id        NUMBER;
    l_party_cust_id         NUMBER;
    l_account_id            NUMBER;
    l_customer_site_use_id  NUMBER;
    l_location_id           number;
    l_dunning_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_dunning_rec_upd       IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_score                 NUMBER;
    l_bucket_line_id        NUMBER;
    l_campaign_sched_id     NUMBER;
    l_template_id           NUMBER;
    l_xdo_template_id       NUMBER;
    l_method                VARCHAR2(10);
    l_callback_flag         VARCHAR2(1);
    l_callback_days         NUMBER;
    l_callback_date         DATE;
    l_request_id            NUMBER;
    l_outcome_code          varchar2(20);
    l_api_name              CONSTANT VARCHAR2(30) := 'Send_Staged_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);
    --
    nIdx                    NUMBER := 0;
    TYPE Del_ID_TBL_type is Table of IEX_DELINQUENCIES_ALL.DELINQUENCY_ID%TYPE
                            INDEX BY BINARY_INTEGER;
    Del_Tbl                 Del_ID_TBL_TYPE;
    l_bind_tbl              IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
    l_bind_rec              IEX_DUNNING_PVT.FULFILLMENT_BIND_REC;
    l_org_id                NUMBER ;
    --l_delid_tbl             IEX_DUNNING_PUB.DelId_NumList;
    l_del_tbl               IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE;
    l_ffm_cnt               NUMBER := 0;
    l_dunn_cnt              NUMBER := 0;
    l_bucket                VARCHAR2(100);

    l_running_level         VARCHAR2(25);
    l_object_Code           VARCHAR2(25);
    l_object_id             NUMBER;

    l_curr_dmethod          VARCHAR2(10);
    l_contact_destination   varchar2(240);  -- bug 3955222
    l_contact_party_id      number; -- bug 3955222
    l_contact_id            number;
    l_warning_flag          varchar2(1);
    l_contact_point_id      number;
    l_fully_promised        number := 1;  -- Added for bug#8408162
    l_allow_send            varchar2(1) :='Y'; -- Added for bug#8408162
    l_status                varchar2(10);

    Type refCur			  is Ref Cursor;
    sql_cur			  refCur;
    sql_cur1			  refCur;
    sql_cur2			  refCur;
    sql_cur3			  refCur;
    vPLSQL			  VARCHAR2(2000);
    vPLSQL1			  VARCHAR2(2000);
    vPLSQL2			  VARCHAR2(2000);
    vPLSQL3			  VARCHAR2(2000);
    l_orderby			  varchar2(20);
    l_no_of_rows		  number;
    l_ag_dn_xref_id	          number;
    l_atleast_one_trx		  varchar2(10);
    l_stage			  number;
    l_acc_dunning_trx_null_dun_ct number;
    l_acc_dunning_trx_ct	  number;
    l_skip_this_dunn_planlineid   number;
    l_first_satified_dunnplanid   number;
    l_grace_days                  number := 0;
    l_use_grace_days              varchar2(10);
    l_dun_disputed_items          varchar2(10);
    --l_inc_inv_curr                IEX_UTILITIES.INC_INV_CURR_TBL;
    l_dunn_letters                varchar2(10);
    l_inv_curr			  varchar2(20);
    l_amt_due_remaining		  number;
    l_profile_dunn_amt		  number;
    l_profile_dunn_inv_amt	  number;
    l_staged_dunning_level        number;
    l_transaction_id              number;
    l_payment_schedule_id         number;
    l_rowid                       Varchar2(50);
    X_DUNNING_TRX_ID              number;

    cursor c_dunning_plan_dtl (p_dunn_plan_id number) is
    select nvl(dunn.grace_days ,'N'),
           nvl(dunn.dun_disputed_items, 'N')
    from iex_dunning_plans_b dunn
    where dunning_plan_id = p_dunn_plan_id;

    cursor c_billto_min_dunn_amt (p_site_use_id number, p_currency_code varchar) is
	select nvl(min_dunning_amount,0), nvl(min_dunning_invoice_amount,0)
	from hz_cust_profile_amts
	where site_use_id = p_site_use_id
	and currency_code = p_currency_code;

    cursor c_inv_details (p_delinquency_id number) is
        select arp.invoice_currency_code,
	       arp.amount_due_remaining,
	       del.staged_dunning_level,
	       del.transaction_id,
	       del.payment_schedule_id
	from iex_delinquencies del,
	     ar_payment_schedules arp
	where del.delinquency_id = p_delinquency_id
	and del.payment_schedule_id = arp.payment_schedule_id;

    cursor c_dunningplan_lines (p_dunning_plan_id number, p_stage number, p_score number) is
	select ag_dn_xref_id,
	 dunning_level,
	 template_id,
	 xdo_template_id,
	 fm_method,
	 upper(callback_flag) callback_flag,
	 callback_days,
	 range_of_dunning_level_from,
	 range_of_dunning_level_to,
	 min_days_between_dunning
	 from iex_ag_dn_xref
	 where dunning_plan_id = p_dunning_plan_id
	 --and range_of_dunning_level_from >= p_stage
	 --and range_of_dunning_level_to <= p_stage
	 and p_stage between range_of_dunning_level_from and range_of_dunning_level_to
	 and p_score between score_range_low and score_range_high;

    cursor c_acc_dunning_trx_null_dun_ct (p_del_id number, p_min_days_bw_dun number,
                                          p_corr_date date, p_grace_days number, p_include_dis_items varchar) is
    select count(*) from (
    select del.delinquency_id,
           del.transaction_id,
           del.payment_schedule_id
    from iex_delinquencies del,
         ar_payment_schedules arp
    where del.payment_schedule_id = arp.payment_schedule_id
    and del.status in ('DELINQUENT','PREDELINQUENT')
    and del.delinquency_id = p_del_id
    and del.staged_dunning_level is NULL
    and (trunc(arp.due_date) + p_min_days_bw_dun) <= p_corr_date
    and (trunc(arp.due_date) + p_grace_days) <= p_corr_date
    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
    /*
    union
    select del.delinquency_id,
           del.transaction_id,
           del.payment_schedule_id
    from iex_delinquencies del,
         ar_payment_schedules arp
    where del.payment_schedule_id = arp.payment_schedule_id
    and del.status = 'CURRENT'
    and del.delinquency_id = p_del_id
    and del.staged_dunning_level is NULL
    and arp.status = 'OP'
    and arp.class = 'INV'
    and (trunc(arp.due_date) + p_min_days_bw_dun) <= p_corr_date
    and (trunc(arp.due_date) + p_grace_days) <= p_corr_date
    and arp.amount_in_dispute >= decode(p_include_dis_items, 'Y', arp.amount_due_remaining, (arp.amount_due_original + 1))
    */
    );

    cursor c_acc_dunning_trx_ct (p_del_id number, p_stage_no number,
                                 p_min_days_bw_dun number, p_corr_date date, p_include_dis_items varchar) is
    select count(*) from (
    select del.delinquency_id,
           del.transaction_id,
           del.payment_schedule_id
    from iex_delinquencies del
         ,ar_payment_schedules arp
    where
    del.payment_schedule_id = arp.payment_schedule_id and
    del.status in ('DELINQUENT','PREDELINQUENT')
    and del.delinquency_id = p_del_id
    and del.staged_dunning_level = p_stage_no
    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
    and nvl(
             (
	        (select trunc(correspondence_date) from iex_dunnings
                 where dunning_id =
                    (select max(iet.DUNNING_ID) from iex_dunning_transactions iet,
		                                     iex_dunnings dunn
                     where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
                     and dunn.dunning_id = iet.dunning_id
		     and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
					OR (dunn.dunning_mode = 'FINAL'))
		     and iet.STAGE_NUMBER = p_stage_no
		     and dunn.delivery_status is null
		     --group by iet.dunning_id
		    )
		 )
	       + p_min_days_bw_dun
	      )
	     , p_corr_date
	    )
	    <= p_corr_date
    /*
    union
    select del.delinquency_id,
           del.transaction_id,
           del.payment_schedule_id
    from iex_delinquencies del
         ,ar_payment_schedules arp
    where
    del.payment_schedule_id = arp.payment_schedule_id and
    del.status = 'CURRENT'
    and del.party_cust_id = p_party_id
    and del.cust_account_id = p_cust_acct_id
    and del.staged_dunning_level = p_stage_no
    and arp.status = 'OP'
    and arp.class = 'INV'
    and arp.amount_in_dispute >= decode(p_include_dis_items, 'Y', arp.amount_due_remaining, (arp.amount_due_original + 1))
    and nvl(
        (
	 (select trunc(correspondence_date) from iex_dunnings
          where dunning_id =
           (select distinct DUNNING_ID from iex_dunning_transactions
            where PAYMENT_SCHEDULE_ID = del.payment_schedule_id
            and STAGE_NUMBER = p_stage_no))
	    + p_min_days_bw_dun )
	    , p_corr_date )
	    <= p_corr_date
     */
     );

    l_dunningplan_lines	c_dunningplan_lines%rowtype;

    --Start adding for bug 9156833 gnramasa 27th Nov 09
    l_validation_level		  NUMBER ;
    l_resource_tab		  iex_utilities.resource_tab_type;
    l_resource_id		  NUMBER;
    --End adding for bug 9156833 gnramasa 27th Nov 09
    l_turnoff_coll_on_bankru	  varchar2(10);
    l_no_of_bankruptcy		  number;
    l_min_days_between_dunn_99	  number;

    cursor c_no_of_bankruptcy (p_par_id number)
    is
    select nvl(count(*),0)
    from iex_bankruptcies
    where party_id = p_par_id
    and (disposition_code in ('GRANTED','NEGOTIATION')
         OR (disposition_code is NULL));

    cursor c_min_days_between_dunn_99 (p_dunn_plan_id number, p_stage_no number, p_score_val number)
    is
    select min_days_between_dunning
    from iex_ag_dn_xref
    where dunning_plan_id = p_dunn_plan_id
    and p_stage_no between range_of_dunning_level_from and range_of_dunning_level_to
    and p_score_val between score_range_low and score_range_high;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Send_Staged_Dunning_PVT;

      --Bug#4679639 schekuri 20-OCT-2005
      --Value of profile ORG_ID shouldn't be used for getting ORG_ID after MOAC implementation
      --l_org_id        := fnd_profile.value('ORG_ID');
      l_org_id:= mo_global.get_current_org_id;
      WriteLog(G_PKG_NAME || ' ' || l_api_name ||' org_id in send dunning '|| l_org_id);

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ' || p_resend_flag);
      l_turnoff_coll_on_bankru	:= nvl(fnd_profile.value('IEX_TURNOFF_COLLECT_BANKRUPTCY'),'N');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_turnoff_coll_on_bankru: ' || l_turnoff_coll_on_bankru);

	l_validation_level := FND_API.G_VALID_LEVEL_FULL;

	 open c_dunning_plan_dtl (p_dunning_plan_id);
	 fetch c_dunning_plan_dtl into l_use_grace_days, l_dun_disputed_items;
	 close c_dunning_plan_dtl;
	 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_use_grace_days :'|| l_use_grace_days);
	 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_dun_disputed_items :'|| l_dun_disputed_items);

	 FOR i in 1..p_delinquencies_tbl.count
	      LOOP
		  l_delinquency_id := p_delinquencies_tbl(i).delinquency_id;
		  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==================');
		  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ' || l_delinquency_Id);
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'delinquency_id='||l_delinquency_id );

		  -- Validate Data

		 /*=============================================================
		  *  For each Delinquency,
		  *=============================================================*/

		 l_party_cust_id := p_delinquencies_tbl(i).party_cust_id;
		 l_account_id := p_delinquencies_tbl(i).cust_account_id;
		 l_customer_site_use_id := p_delinquencies_tbl(i).customer_site_use_id;
		 l_score := p_delinquencies_tbl(i).score_value;


		  --WriteLog('iexvdunb.pls:SendDunn:open del='||l_delinquency_Id);
		  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - '||l_party_cust_id);
		  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - '||l_account_id);
		  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - '||l_customer_site_use_id);
		  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - '||l_score);

		  if l_turnoff_coll_on_bankru = 'Y' then
			open c_no_of_bankruptcy (l_party_cust_id);
			fetch c_no_of_bankruptcy into l_no_of_bankruptcy;
			close c_no_of_bankruptcy;
		  end if;
		  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_no_of_bankruptcy: ' || l_no_of_bankruptcy);

		  IF (l_turnoff_coll_on_bankru = 'Y' and l_no_of_bankruptcy >0) then
		   goto end_loop;
		  END IF;

		 if l_use_grace_days = 'Y' then
			 iex_utilities.get_grace_days(p_api_version => p_api_version,
					       p_init_msg_list     => FND_API.G_TRUE,
					       p_commit            => FND_API.G_FALSE,
					       p_validation_level  => l_validation_level,
					       p_level             => 'BILL_TO',  --get the grace days from the site level profile
					       p_party_id          => l_party_cust_id,
					       p_account_id        => l_account_id,
					       p_site_use_id       => l_customer_site_use_id,
					       x_msg_count         => l_msg_count,
					       x_msg_data          => l_msg_data,
					       x_return_status     => l_return_status,
					       x_grace_days        => l_grace_days);
			 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get grace days');
			     x_return_status := FND_API.G_RET_STS_ERROR;
			 END IF;
		 end if;
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_grace_days :'|| l_grace_days);

		 open c_inv_details (l_delinquency_id);
		 fetch c_inv_details into l_inv_curr, l_amt_due_remaining, l_staged_dunning_level, l_transaction_id, l_payment_schedule_id;
		 close c_inv_details;
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_inv_curr :'|| l_inv_curr);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_amt_due_remaining :'|| l_amt_due_remaining);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_staged_dunning_level :'|| l_staged_dunning_level);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_transaction_id :'|| l_transaction_id);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_payment_schedule_id :'|| l_payment_schedule_id);

		 if l_staged_dunning_level is null then
			l_stage := 1;
		 else
			l_stage := l_staged_dunning_level + 1;
		 end if;
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_stage :'||l_stage);

		 --Start bug 9696806 gnramasa 27th May 10
		 open c_min_days_between_dunn_99 (p_dunning_plan_id, 99, l_score);
		 fetch c_min_days_between_dunn_99 into l_min_days_between_dunn_99;
		 close c_min_days_between_dunn_99;
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_min_days_between_dunn_99 :'|| l_min_days_between_dunn_99);

		 update iex_delinquencies del
		 set staged_dunning_level = 98
		 where delinquency_id = l_delinquency_id
		 and staged_dunning_level = 99
		 and status in ('DELINQUENT','PREDELINQUENT')
		 and nvl(
			 (
			    (select trunc(correspondence_date) from iex_dunnings
			     where dunning_id =
				(select max(iet.DUNNING_ID)
				from iex_dunning_transactions iet,
				     iex_dunnings dunn
				 where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
					    and dunn.dunning_id = iet.dunning_id
					    and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
						    OR (dunn.dunning_mode = 'FINAL'))
				 and iet.STAGE_NUMBER = 99
				 and dunn.delivery_status is null
				)
			     )
			   + l_min_days_between_dunn_99
			  )
			     , p_correspondence_date
		      )
		      <= p_correspondence_date ;

		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Updated : ' || SQL%ROWCOUNT || ' number of row''s staged_dunning_level from 99 to 98');
	        commit;
	        --End bug 9696806 gnramasa 27th May 10

		 open c_billto_min_dunn_amt (l_customer_site_use_id, l_inv_curr);
		 fetch c_billto_min_dunn_amt into l_profile_dunn_amt, l_profile_dunn_inv_amt;
		 close c_billto_min_dunn_amt;
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_profile_dunn_amt :'|| l_profile_dunn_amt);
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_profile_dunn_inv_amt :'|| l_profile_dunn_inv_amt);

		 if (l_amt_due_remaining < l_profile_dunn_amt ) or (l_amt_due_remaining < l_profile_dunn_inv_amt ) then
			l_dunn_letters := 'N';
		 end if;

		   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_dunn_letters: ' || l_dunn_letters);

		   if l_dunn_letters = 'N' then
			FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_AMOUNT_MIN');
			FND_MSG_PUB.Add;
			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  Required min Dunning amount in customer profile ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Required min Dunning amount in customer profile ');
			x_return_status := FND_API.G_RET_STS_ERROR;
			GOTO end_api;
		   end if;

		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  end check customer profile');


		open c_dunningplan_lines (p_dunning_plan_id, l_stage, l_score);

		 loop
			 fetch c_dunningplan_lines into l_dunningplan_lines;
			 exit when c_dunningplan_lines%notfound;

			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.ag_dn_xref_id='||l_dunningplan_lines.ag_dn_xref_id);
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.dunning_level='||l_dunningplan_lines.dunning_level);
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.template_id='||l_dunningplan_lines.template_id);
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.xdo_template_id='||l_dunningplan_lines.xdo_template_id);
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.fm_method='||l_dunningplan_lines.fm_method);
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.callback_flag='||l_dunningplan_lines.callback_flag);
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.callback_days='||l_dunningplan_lines.callback_days);
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.range_of_dunning_level_from='||l_dunningplan_lines.range_of_dunning_level_from);
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.range_of_dunning_level_to='||l_dunningplan_lines.range_of_dunning_level_to);
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunningplan_lines.min_days_between_dunning='||l_dunningplan_lines.min_days_between_dunning);

			 l_ag_dn_xref_id			:= l_dunningplan_lines.ag_dn_xref_id;
			 l_template_id				:= l_dunningplan_lines.template_id;
			 l_xdo_template_id			:= l_dunningplan_lines.xdo_template_id;
			 l_method				:= l_dunningplan_lines.fm_method;
			 l_callback_flag			:= l_dunningplan_lines.callback_flag;
			 l_callback_days			:= l_dunningplan_lines.callback_days;

			for i in l_dunningplan_lines.range_of_dunning_level_from..l_dunningplan_lines.range_of_dunning_level_to
			      loop

					l_skip_this_dunn_planlineid := 1;

					if l_stage = 1 then

						 open c_acc_dunning_trx_null_dun_ct (l_delinquency_id,
									    l_dunningplan_lines.min_days_between_dunning,
									    p_correspondence_date,
									    l_grace_days,
									    l_dun_disputed_items);
						 fetch c_acc_dunning_trx_null_dun_ct into l_acc_dunning_trx_null_dun_ct;
						 close c_acc_dunning_trx_null_dun_ct;

						 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_acc_dunning_trx_null_dun_ct :'||l_acc_dunning_trx_null_dun_ct);
						 if l_acc_dunning_trx_null_dun_ct <> 0 then
							WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Delinquency exist for this stage, so will continue...');
							l_skip_this_dunn_planlineid := 0;
							goto STAGE_DUNN;
						 end if;

					else

						 open c_acc_dunning_trx_ct (l_delinquency_id,
									   l_staged_dunning_level,
									   l_dunningplan_lines.min_days_between_dunning,
									   p_correspondence_date,
									   l_dun_disputed_items);
						 fetch c_acc_dunning_trx_ct into l_acc_dunning_trx_ct;
						 close c_acc_dunning_trx_ct;

						 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_acc_dunning_trx_ct :'||l_acc_dunning_trx_ct);
						 if l_acc_dunning_trx_ct <> 0 then
							WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Delinquency exist for this stage, so will continue...');
							l_skip_this_dunn_planlineid := 0;
							goto STAGE_DUNN;
						 end if;

					end if;

			      end loop;
			  <<STAGE_DUNN>>
			  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_skip_this_dunn_planlineid: '|| l_skip_this_dunn_planlineid);
			  if l_skip_this_dunn_planlineid = 1 then
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Delinquency doesn''t exist for this stage, so skipping...');
				goto c_dunning_plan_lines;
			  end if;


		   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get ffm_template_id='||l_template_id);
		   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get xdo_template_id='||l_xdo_template_id);
		   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get bucket='||l_bucket);

		  /*===========================================
		   * Check template
		   *  in 11.5.11, IEX supports fulfillment and xml publisher.
		   *  if the current setup for delivery id FFM,
		   *  then template_id is necessary;
		   *  if XML, xdo_template_id is necessary;
		   *===========================================*/

		   l_curr_dmethod := IEX_SEND_XML_PVT.getCurrDeliveryMethod;
		   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - curr d_method='||l_curr_dmethod);
		   if ( (l_curr_dmethod is null or l_curr_dmethod = '') or
			(l_curr_dmethod = 'FFM' and l_template_id is null)  or
			(l_curr_dmethod = 'XML' and l_xdo_template_id is null ) ) then
			--FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
			--FND_MESSAGE.Set_Token ('INFO', 'Template_ID', FALSE);
			FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
			FND_MSG_PUB.Add;
			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Missing corresponding template');
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Missing corresponding template' );
			x_return_status := FND_API.G_RET_STS_ERROR;
			GOTO end_loop;
		   end if;

		  /*===========================================
		   * Check profile before send dunning
		   *===========================================*/

		   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - begin check customer profile');
		    -- ctlee - check the hz_customer_profiles.dunning_letter
		   if ( iex_utilities.DunningProfileCheck (
			   p_party_id => l_party_cust_id
			   , p_cust_account_id => l_account_id
			   , p_site_use_id => l_customer_site_use_id
			   , p_delinquency_id => l_delinquency_id     ) = 'N'
		      ) then
			FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_PROFILE_NO');
			FND_MSG_PUB.Add;
			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Send dunning in customer profile set to no ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Send dunning in customer profile set to no ');
			GOTO end_loop;
		   end if;


		 --Start adding for bug 8489610 by gnramasa 14-May-09
		 if p_dunning_mode <> 'DRAFT' then
			   /*===========================================
			    * Close OPEN Dunnings for each Del
			    *===========================================*/

			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning');
			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - runninglevel=DELINQUENCY');
			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_id);
			      l_del_tbl(1).delinquency_id := l_delinquency_id;


			      Close_Staged_Dunning(p_api_version             => p_api_version
						, p_init_msg_list            => p_init_msg_list
						, p_commit                   => p_commit
						, p_delinquencies_tbl        => l_del_tbl
						, p_ag_dn_xref_id	     => l_ag_dn_xref_id
						, p_running_level            => 'DELINQUENCY'
						--, p_status                   => l_status
						, x_return_status            => x_return_status
						, x_msg_count                => x_msg_count
						, x_msg_data                 => x_msg_data);

			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning status='|| x_return_status);

			      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Close Dunning');
				 --msg
				 GOTO end_loop;
			      END IF;
			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EndCloseDunn');
		 end if;

		   /*===========================================
		    * Create Dunning Record
		    *===========================================*/

		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get CallbackDate');
		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag='||l_callback_flag);
		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDays='||l_callback_days);

		   /*===================================================
		    * clchang updated 02/13/2003
		    * callback_days could be null if callback_yn = 'N';
		    * and if callback_yn = 'N', not get callback_date;
		    *==================================================*/
		    IF (l_callback_flag = 'Y') THEN
		       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is Y: NOTGetCallbackDate');
		       Get_Callback_Date(p_init_msg_list        => p_init_msg_list
						   , p_callback_days        => l_callback_days
						   , p_correspondence_date  => p_correspondence_date
						   , x_callback_date        => l_callback_date
						   , x_return_status        => x_return_status
						   , x_msg_count            => x_msg_count
						   , x_msg_data             => x_msg_data);

		       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetCallbackDate status='|| x_return_status);
		       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDate='||l_callback_date);

		       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Not Get CallbackDate');
			 GOTO end_loop;
		       END IF;

		    ELSE
		       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is N: NOTGetCallbackDate');
		    END IF;


		    /* get the current amount_due_remaining and currency_code */
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GET AMOUNT');

		    Open C_AMOUNT(l_delinquency_id);
		    Fetch C_AMOUNT into
			l_amount,
			l_curr_code;

		    If ( C_AMOUNT%NOTFOUND) Then
		       FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
		       FND_MESSAGE.Set_Token ('INFO', 'iex:amount', FALSE);
		       FND_MSG_PUB.Add;
		       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - amount notfound');
		    END IF;

		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - close C_AMOUNT');
		    Close C_AMOUNT;

		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get amount='||l_amount);
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get currcode='||l_curr_code);
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning');
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_id);
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_id='||l_delinquency_id);

		    l_dunning_rec.delinquency_id := l_delinquency_id;
		    l_dunning_rec.callback_yn := l_callback_flag;
		    l_dunning_rec.callback_date := l_callback_date;

		     if p_dunning_mode = 'DRAFT' then
			l_dunning_rec.status := 'CLOSE';
		     else
			l_dunning_rec.status := 'OPEN';
		     end if;

		    l_dunning_rec.dunning_method:= l_method;
		    l_dunning_rec.template_id:= l_template_id;
		    l_dunning_rec.xml_template_id:= l_xdo_template_id;
		    l_dunning_rec.campaign_sched_id := l_campaign_sched_id;
		    l_dunning_rec.xml_request_id := l_request_id;
		    l_dunning_rec.dunning_object_id := l_delinquency_id;
		    l_dunning_rec.dunning_level := 'DELINQUENCY';
		    l_dunning_rec.object_type := 'IEX_DELINQUENCY';
		    l_dunning_rec.object_id := l_delinquency_id;
		    l_dunning_rec.amount_due_remaining := l_amount;
		    l_dunning_rec.currency_code := l_curr_code;
		    l_dunning_rec.dunning_plan_id := p_dunning_plan_id;
		    l_dunning_rec.contact_destination := l_contact_destination;  -- bug 3955222
		    l_dunning_rec.contact_party_id := l_contact_party_id;  -- bug 3955222
		    --Start adding for bug 8489610 by gnramasa 14-May-09
		    l_dunning_rec.dunning_mode := p_dunning_mode;
		    l_dunning_rec.confirmation_mode := p_confirmation_mode;
		    l_dunning_rec.ag_dn_xref_id	:= l_ag_dn_xref_id;
		    l_dunning_rec.correspondence_date	:= p_correspondence_date;

		     if p_parent_request_id is not null then
			l_dunning_rec.request_id := p_parent_request_id;
		     else
			l_dunning_rec.request_id := FND_GLOBAL.Conc_Request_Id;
		     end if;

		     l_dunning_rec.org_id := l_org_id;
		     WriteLog(G_PKG_NAME || ' ' || l_api_name ||' Before creating dunning org_id '|| l_org_id);

		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');

		    CREATE_DUNNING(p_api_version                 => p_api_version
				    , p_init_msg_list            => p_init_msg_list
				    , p_commit                   => p_commit
				    , p_dunning_rec              => l_dunning_rec
				    , x_dunning_id               => l_dunning_id
				    , x_return_status            => x_return_status
				    , x_msg_count                => x_msg_count
				    , x_msg_data                 => x_msg_data);

		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning status='|| x_return_status);

		    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Dunning');
		      GOTO end_loop;
		    END IF;

		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunningId='||l_dunning_id);
		    --FND_FILE.PUT_LINE(FND_FILE.LOG, 'Create Dunning Id=' ||l_dunning_id);
		    l_dunn_cnt := l_dunn_cnt + 1;

		    begin
			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');
			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_delinquency_id :'||l_delinquency_id);
			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_transaction_id :'||l_transaction_id);
			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_payment_schedule_id : '||l_payment_schedule_id);

			      IEX_Dunnings_PKG.insert_staged_dunning_row(
				  px_rowid                          => l_rowid
				, px_dunning_trx_id                 => x_dunning_trx_id
				, p_dunning_id                      => l_dunning_id
				, p_cust_trx_id                     => l_transaction_id
				, p_payment_schedule_id             => l_payment_schedule_id
				, p_ag_dn_xref_id                   => l_ag_dn_xref_id
				, p_stage_number                    => l_stage
				, p_created_by                      => FND_GLOBAL.USER_ID
				, p_creation_date                   => sysdate
				, p_last_updated_by                 => FND_GLOBAL.USER_ID
				, p_last_update_date                => sysdate
				, p_last_update_login               => FND_GLOBAL.USER_ID
				, p_object_version_number	    => 1.0
			      );

			      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_dunning_trx_id :'|| x_dunning_trx_id);

			      IF x_return_status = FND_API.G_RET_STS_ERROR then
					raise FND_API.G_EXC_ERROR;
			      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
				       raise FND_API.G_EXC_UNEXPECTED_ERROR;
			      END IF;

			      /*
			      if p_dunning_mode <> 'DRAFT' then
				      update iex_delinquencies_all
				      set staged_dunning_level = l_stage
				      where delinquency_id = l_delinquency_id;
			      end if;
			      */

			      --reset the x_dunning_trx_id, so that will get new no when inserting 2nd record.
			      x_dunning_trx_id	:= null;
		    end;

		   /*===========================================
		    * Send Letter through Fulfillment
		    *===========================================*/
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Send_Ffm');
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - org_id = '|| l_org_id);
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - party_id = '|| l_party_cust_id);
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - acct_id = '|| l_account_id);
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - site_use_id = '|| l_customer_site_use_id);
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bucket_line_id = '|| l_bucket_line_id);
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delinquency_id = '|| l_delinquency_id);

		    l_bind_tbl(1).key_name := 'party_id';
		    l_bind_tbl(1).key_type := 'NUMBER';
		    l_bind_tbl(1).key_value := l_party_cust_id;
		    l_bind_tbl(2).key_name := 'org_id';
		    l_bind_tbl(2).key_type := 'NUMBER';
		    l_bind_tbl(2).key_value := l_org_id;
		    l_bind_tbl(3).key_name := 'bucket_line_id';
		    l_bind_tbl(3).key_type := 'NUMBER';
		    l_bind_tbl(3).key_value := l_bucket_line_id;
		    l_bind_tbl(4).key_name := 'account_id';
		    l_bind_tbl(4).key_type := 'NUMBER';
		    l_bind_tbl(4).key_value := l_account_id;
		    l_bind_tbl(5).key_name := 'delinquency_id';
		    l_bind_tbl(5).key_type := 'NUMBER';
		    l_bind_tbl(5).key_value := l_delinquency_id;
		    -- added for BILL_TO in 11.5.10.
		    l_bind_tbl(6).key_name := 'customer_site_use_id';
		    l_bind_tbl(6).key_type := 'NUMBER';
		    l_bind_tbl(6).key_value := l_customer_site_use_id;
		    l_bind_tbl(7).key_name := 'DUNNING_ID';
		    l_bind_tbl(7).key_type := 'NUMBER';
		    l_bind_tbl(7).key_value := l_dunning_id;

		    --Start adding for bug 9156833 gnramasa 27th Nov 09
		    l_validation_level := FND_API.G_VALID_LEVEL_FULL;

		    iex_utilities.get_dunning_resource(p_api_version => p_api_version,
				       p_init_msg_list     => FND_API.G_TRUE,
				       p_commit            => FND_API.G_FALSE,
				       p_validation_level  => l_validation_level,
				       p_level             => 'DUNNING_BILLTO',
				       p_level_id          => l_customer_site_use_id,
				       x_msg_count         => l_msg_count,
				       x_msg_data          => l_msg_data,
				       x_return_status     => l_return_status,
				       x_resource_tab      => l_resource_tab);
		   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
		     x_return_status := FND_API.G_RET_STS_ERROR;
		   END IF;

		   if l_resource_tab.count>0 then
		    l_resource_id := l_resource_tab(1).resource_id;
		   end if;
		   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_resource_id: ' || l_resource_id);
		   --End adding for bug 9156833 gnramasa 27th Nov 09

		    if (l_curr_dmethod = 'FFM') then
		       Send_Fulfillment(p_api_version              => p_api_version
				       ,p_init_msg_list            => FND_API.G_TRUE
				       ,p_commit                   => FND_API.G_TRUE
				       ,p_fulfillment_bind_tbl     => l_bind_tbl
				       ,p_template_id              => l_template_id
				       ,p_method                   => l_method
				       ,p_party_id                 => l_party_cust_id
				       ,x_request_id               => l_request_id
				       ,x_return_status            => x_return_status
				       ,x_msg_count                => x_msg_count
				       ,x_msg_data                 => x_msg_data
				       ,x_contact_destination      => l_contact_destination
				       ,x_contact_party_id         => l_contact_party_id );
		    else
		       l_running_level := 'DELINQUENCY';
		       l_object_code := 'IEX_DELINQUENCY';
		       l_object_id := l_delinquency_id;

		       Send_XML(p_api_version              => p_api_version
			       ,p_init_msg_list            => FND_API.G_TRUE
			       ,p_commit                   => FND_API.G_TRUE
			       ,p_resend                   => 'N'
			       ,p_request_id               => null
			       ,p_fulfillment_bind_tbl     => l_bind_tbl
			       ,p_template_id              => l_xdo_template_id
			       ,p_method                   => l_method
			       ,p_party_id                 => l_party_cust_id
			       ,p_level                    => l_running_level
			       ,p_source_id                => l_object_id
			       ,p_object_code              => l_object_code
			       ,p_object_id                => l_object_id
			       ,p_resource_id              => l_resource_id --Added for bug 9156833 gnramasa 27th Nov 09
			       ,p_dunning_mode             => p_dunning_mode
			       ,p_parent_request_id        => p_parent_request_id
			       ,p_org_id                   => l_org_id
			       ,x_request_id               => l_request_id
			       ,x_return_status            => x_return_status
			       ,x_msg_count                => x_msg_count
			       ,x_msg_data                 => x_msg_data
			       ,x_contact_destination      => l_contact_destination
			       ,x_contact_party_id         => l_contact_party_id);

		    end if;

		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Send status = ' || x_return_status);
		    --End adding for bug 8489610 by gnramasa 14-May-09

		    IF x_return_status <> FND_API.G_RET_STS_SUCCESS and x_return_status <> 'W' THEN
		       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Not Sending Letters');
		       FND_MSG_PUB.Count_And_Get(p_count          =>   x_msg_count,
						 p_data           =>   x_msg_data );
		       for i in 1..x_msg_count loop
			  errmsg := FND_MSG_PUB.Get(p_msg_index => i,
						    p_encoded => 'F');
			  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error:'||errmsg);
			  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errmsg=' || errmsg);
		       end loop;
		       GOTO end_loop;
		    elsif x_return_status = 'W' then
		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - setting warning flag');
		      l_warning_flag := 'W';
		    end if;

		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id='||l_request_id);

		    l_dunning_rec_upd.dunning_id := l_dunning_id;
		    if (l_curr_dmethod = 'FFM') then
			l_dunning_rec_upd.ffm_request_id := l_request_id;
		    else
			l_dunning_rec_upd.xml_request_id := l_request_id;
		    end if;

		    IEX_DUNNING_PVT.Update_DUNNING(p_api_version              => 1.0
						, p_init_msg_list            => FND_API.G_TRUE
						, p_commit                   => FND_API.G_TRUE
						, p_dunning_rec              => l_dunning_rec_upd
						, x_return_status            => l_return_status
						, x_msg_count                => l_msg_count
						, x_msg_data                 => l_msg_data);

		    l_ffm_cnt := l_ffm_cnt + 1;

		   /*===========================================
		    * Update Delinquency
		    * Set DUNN_YN = 'N'
		    *===========================================*/
		      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateDel');

		      nIdx := nIdx + 1;
		      del_tbl(nIdx) := l_delinquency_id;

		    <<c_dunning_plan_lines>>
		    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - c_dunning_plan_lines');

	      END LOOP; -- end of DELINQUENCIES_TBL loop
	      close c_dunningplan_lines;
	      <<end_loop>>
	      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_loop');
	end loop;

     --Start bug 9696806 gnramasa 27th May 10
	if p_dunning_mode = 'DRAFT'  then
		update iex_delinquencies del
		set staged_dunning_level = 99
		where delinquency_id = l_delinquency_id
		and staged_dunning_level = 98
		and status in ('DELINQUENT','PREDELINQUENT')
		and exists (select count(iet.DUNNING_ID)
				from iex_dunning_transactions iet,
				     iex_dunnings dunn
				 where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
					    and dunn.dunning_id = iet.dunning_id
					    and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
						    OR (dunn.dunning_mode = 'FINAL'))
				 and iet.STAGE_NUMBER = 99
				 and dunn.delivery_status is null
			    );

	    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Updated : ' || SQL%ROWCOUNT || ' number of row''s staged_dunning_level from 98 to 99');
	    commit;
	end if;

    --End bug 9696806 gnramasa 27th May 10

     <<end_api>>
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========Summarty==========');
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SendFFM Cnt='||l_ffm_cnt);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunn Cnt='||l_dunn_cnt);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========End Summarty==========');

      --
      -- End of API body
      --
      if l_warning_flag = 'W' then
        x_return_status := 'W';
      end if;

      COMMIT WORK;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return status = ' || x_return_status);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              COMMIT WORK;
              x_return_status := FND_API.G_RET_STS_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              COMMIT WORK;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              COMMIT WORK;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

END Send_Staged_Dunning;

/*=========================================================================
   clchang added 03/04/2003 -
     Resend_Level_Dunning and Resend_Dunning are called by FORM,
     and just for resend;
     Only one record once, not loop;
   clchang updated 04/21/2003 -
     added one new level 'BILL_TO' in 11.5.10.
*=========================================================================*/
Procedure Resend_Level_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_dunning_plan_id         in number,
            p_running_level           IN VARCHAR2,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_org_id                  in number,
	    x_request_id              OUT NOCOPY NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_GET_DEL (IN_del_ID NUMBER) IS
      SELECT delinquency_ID
        FROM IEX_DELINQUENCIES
       WHERE delinquency_ID = in_del_ID;
    --
    -- begin bug 4914799 ctlee 12/30/2005 add p_dunning_plan_id
    CURSOR C_GET_SCORE (IN_ID NUMBER, IN_CODE VARCHAR2, p_dunning_plan_id number) IS
      SELECT a.score_value
        FROM IEX_SCORE_HISTORIES a
             , IEX_DUNNING_PLANS_VL c  -- bug 4914799 ctlee 12/30/2005
       WHERE a.score_object_ID = in_ID
         AND a.score_object_code = IN_CODE
         and c.score_id = a.score_id   -- bug 4914799 ctlee 12/30/2005
         and c.dunning_plan_id = p_dunning_plan_id -- bug 4914799 ctlee 12/30/2005
         AND a.creation_date = (select max(b.creation_date)
                                  from iex_score_histories b
                                 where b.score_object_id = in_id
                                   AND b.score_object_code = IN_CODE);
    -- end bug 4914799 ctlee 12/30/2005 add p_dunning_plan_id
    --
    CURSOR C_GET_TEMPLATE (l_line_id NUMBER,
                           l_score NUMBER, in_LEVEL VARCHAR2, p_dunning_plan_id number) IS
      SELECT x.template_id,
             x.xdo_template_id,
             x.fm_method,
             upper(x.callback_flag),
             x.callback_days
        FROM IEX_AG_DN_XREF x,
             ar_aging_buckets ar,
             iex_dunning_plans_vl d
       WHERE x.aging_bucket_line_ID = l_line_ID
         and x.dunning_plan_id = p_dunning_plan_id
         AND l_score between x.score_range_low and x.score_range_high
         AND x.aging_bucket_id = ar.aging_bucket_id
         and ar.aging_bucket_id = d.aging_bucket_id
         AND ar.status = 'A'
         AND x.dunning_level = IN_LEVEL ;
    --

    l_DUNNING_id            NUMBER;
    l_delinquency_id        NUMBER;
    l_party_cust_id         NUMBER;
    l_account_id            NUMBER;
    l_customer_site_use_id  NUMBER;
    l_noskip                NUMBER := 0;
    l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_DUNNING_tbl           IEX_DUNNING_PUB.DUNNING_TBL_TYPE;
    l_score                 NUMBER;
    l_bucket_line_id        NUMBER;
    l_campaign_sched_id     NUMBER;
    l_template_id           NUMBER;
    l_xdo_template_id       NUMBER;
    l_method                VARCHAR2(10);
    l_callback_flag         VARCHAR2(1);
    l_callback_days         NUMBER;
    l_callback_date         DATE;
    l_request_id            NUMBER;
    l_outcome_code          varchar2(20);
    l_api_name              CONSTANT VARCHAR2(30) := 'Resend_Level_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);
    --
    nIdx                    NUMBER := 0;
    TYPE Del_ID_TBL_type is Table of IEX_DELINQUENCIES_ALL.DELINQUENCY_ID%TYPE
                            INDEX BY BINARY_INTEGER;
    Del_Tbl                 Del_ID_TBL_TYPE;
    l_bind_tbl              IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
    l_bind_rec              IEX_DUNNING_PVT.FULFILLMENT_BIND_REC;
    l_org_id                NUMBER ;
    l_running_level         VARCHAR2(25);
    l_object_Code           VARCHAR2(25);
    l_object_id             NUMBER;
    --l_delid_tbl             IEX_DUNNING_PUB.DelId_NumList;
    l_del_tbl               IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE;
    l_curr_code             VARCHAR2(15);
    l_amount                NUMBER;
    l_write                 NUMBER;
    l_ffm_cnt               NUMBER := 0;
    l_dunn_cnt              NUMBER := 0;
    l_curr_dmethod          VARCHAR2(10);

    l_delinquency_id_check        NUMBER;
    l_party_cust_id_check         NUMBER;
    l_account_id_check            NUMBER;
    l_customer_site_use_id_check  NUMBER;
    l_contact_destination         varchar2(240);  -- bug 3955222
    l_contact_party_id            number; -- bug 3955222
    --Start adding for bug 9156833 gnramasa 27th Nov 09
    l_validation_level		  NUMBER ;
    l_resource_tab		  iex_utilities.resource_tab_type;
    l_resource_id		  NUMBER;
    --End adding for bug 9156833 gnramasa 27th Nov 09
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Resend_Level_DUNNING_PVT;

      --Bug#4679639 schekuri 20-OCT-2005
      --Value of profile ORG_ID shouldn't be used for getting ORG_ID after MOAC implementation
      l_org_id:= mo_global.get_current_org_id;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- don't write into FILE
      l_write := 0;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - running_level='||p_running_level);

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      l_party_cust_id := p_delinquencies_tbl(1).party_cust_id;
      l_account_id := p_delinquencies_tbl(1).cust_account_id;
      l_customer_site_use_id := p_delinquencies_tbl(1).customer_site_use_id;

      if (p_running_level = 'CUSTOMER') then
          l_object_Code := 'PARTY';
          l_object_id := p_delinquencies_tbl(1).party_cust_id;
          l_del_tbl(1).party_cust_id := p_delinquencies_tbl(1).party_cust_id;
          l_amount := party_amount_due_remaining(l_object_id);
          l_curr_code := party_currency_code(l_object_id);
      --
      elsif (p_running_level = 'ACCOUNT') then
          l_object_Code := 'IEX_ACCOUNT';
          l_object_id := p_delinquencies_tbl(1).cust_account_id;
          l_del_tbl(1).cust_account_id := p_delinquencies_tbl(1).cust_account_id;
          l_amount := acct_amount_due_remaining(l_object_id);
          l_curr_code := acct_currency_code(l_object_id);
      --
      elsif (p_running_level = 'BILL_TO') then
          l_object_Code := 'IEX_BILLTO';
          l_object_id := p_delinquencies_tbl(1).customer_site_use_id;
          l_del_tbl(1).customer_site_use_id := p_delinquencies_tbl(1).customer_site_use_id;
          l_amount := site_amount_due_remaining(l_object_id);
          l_curr_code := site_currency_code(l_object_id);
      end if;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_code='||l_object_code);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_id='||l_object_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - party_id='||l_party_cust_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - amount_due_remaining='||l_amount);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - currency_code='||l_curr_code);

      /*==================================================================
       * l_noskip is used to trace the del data is all disputed or not;
       * if any one del not disputed, then l_noskip=1;
       * if l_noskip=0, then means all del are disputed,
       *    => for this customer/account, skip it;
       *==================================================================*/
      l_noskip := 0;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delcnt='||p_delinquencies_tbl.count);

        FOR i in 1..p_delinquencies_tbl.count
        LOOP

          l_delinquency_id := p_delinquencies_tbl(i).delinquency_id;

         /*=============================================================
          *  For each Delinquency,
          *=============================================================*/

          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - open del='||l_delinquency_Id);

         /*=============================================================
          * IsDispute ?
          * If yes => stop (exit);
          * else continue;
          *
          * it returns values :
          * 1) it returns 'F' if no dispute exists for the delinquency
          * 2) it returns 'T' if dispute exists and is pending
          * 3) it returns 'F' if dispute exists and its staus is "COMPLETE"
          *===========================================================*/

          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ResendLevelDunn:Chk IsDispute');

           IEX_DISPUTE_PVT.Is_Delinquency_Dispute(p_api_version              => p_api_version
					   , p_init_msg_list            => p_init_msg_list
					   , p_delinquency_id           => l_delinquency_id
					   , x_return_status            => x_return_status
					   , x_msg_count                => x_msg_count
					   , x_msg_data                 => x_msg_data);

           IF x_return_status = 'T' THEN
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Dispute exists and is pending for del '|| l_delinquency_id);
             GOTO end_del;
           elsif x_return_status = 'F' THEN
              -- if one del is not disputed, then l_noskip=1;
              l_noskip := 1;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No Dispute or status is COMPLETE');
           END IF;

           nIdx := nIdx + 1;
           del_tbl(nIdx) := l_delinquency_id; --in order to update del)

          <<end_del>>
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Close C_GET_DEL');

       END LOOP; -- end of DELINQUENCIES_TBL loop
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END LOOP');

      IF (l_noskip > 0) THEN

         -- init the msg (not including the msg from dispute api)
         FND_MSG_PUB.initialize;

          /*===========================================
           * Get Score From IEX_SCORE_HISTORIES
           * If NotFound => Call API to getScore;
           *===========================================*/
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get Score');
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - objectCode='||l_object_Code);

           Open C_Get_SCORE(l_object_id, l_object_Code, p_dunning_plan_id);
           Fetch C_Get_SCORE into l_score;

           If ( C_GET_SCORE%NOTFOUND) Then
                --FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
                --FND_MESSAGE.Set_Token ('INFO', 'Score', FALSE);
                FND_MESSAGE.Set_Name('IEX', 'IEX_NO_SCORE');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Score NotFound');
                Close C_Get_SCORE;
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           END IF;

           --WriteLog('iexvdunb:ResendLevelDunn:CLOSE C_GET_SCORE', l_write);
           Close C_Get_SCORE;

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get Score='||l_score);


          /*===================================================
           * in 11.5.11, support aging bucket line for all level;
           * clchang added 11/20/04.
           * Get Aging_Bucket_Line_id for each party/acct/site
           *===================================================*/

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetAgingBucketLineId');

           AGING_DEL(p_api_version              => p_api_version
		                , p_init_msg_list            => p_init_msg_list
		                , p_commit                   => p_commit
		                , p_delinquency_id           => null
		                , p_dunning_plan_id          => p_dunning_plan_id
		                , p_bucket                   => null
		                , p_object_code              => l_object_code
		                , p_object_id                => l_object_id
		                , x_return_status            => x_return_status
		                , x_msg_count                => x_msg_count
		                , x_msg_data                 => x_msg_data
		                , x_aging_bucket_line_id     => l_bucket_line_id);

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - AgingDel status='||x_return_status);

           If ( x_return_status <> FND_API.G_RET_STS_SUCCESS) Then
                --FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
                --FND_MESSAGE.Set_Token ('INFO', 'AgingBucketLineId', FALSE);
                FND_MESSAGE.Set_Name('IEX', 'IEX_NO_AGINGBUCKETLINE');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - AgingBucketLineId notfound');
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           END IF;

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - lineid='||l_bucket_line_id);

          /*===========================================
           * Get Template_ID From iex_ag_dn_xref
           *===========================================*/

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GET Template');

           Open C_Get_TEMPLATE(l_bucket_line_id, l_score, p_running_level, p_dunning_plan_id);
           Fetch C_Get_TEMPLATE into
                       l_template_id,
                       l_xdo_template_id,
                       l_method,
                       l_callback_flag,
                       l_callback_days;

           If ( C_GET_TEMPLATE%NOTFOUND) Then
                FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - template notfound');
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           END IF;

           Close C_Get_TEMPLATE;

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get template_id='||l_template_id);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get xdo_template_id='||l_xdo_template_id, l_write);

          /*===========================================
           * Check template
           *  in 11.5.11, IEX supports fulfillment and xml publisher.
           *  if the current setup for delivery id FFM,
           *  then template_id is necessary;
           *  if XML, xdo_template_id is necessary;
           *===========================================*/

           l_curr_dmethod := IEX_SEND_XML_PVT.getCurrDeliveryMethod;
           WriteLog('iexvdunb:ResendLevelDunn:curr d_method='||l_curr_dmethod);
           if ( (l_curr_dmethod is null or l_curr_dmethod = '') or
                (l_curr_dmethod = 'FFM' and l_template_id is null)  or
                (l_curr_dmethod = 'XML' and l_xdo_template_id is null ) ) then
                --FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
                --FND_MESSAGE.Set_Token ('INFO', 'Template_ID', FALSE);
                FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Template notfound');
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           end if;

          /*===========================================
           * Check profile before send dunning
           *===========================================*/

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - begin check customer profile');
            -- ctlee - check the hz_customer_profiles.dunning_letter
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_party_cust_id = ' || l_party_cust_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_account_id = ' || l_account_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_customer_site_use_id = ' || l_customer_site_use_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_delinquency_id = ' || l_delinquency_id);
            -- ctlee - check the hz_customer_profiles.dunning_letter
            l_party_cust_id_check := l_party_cust_id;
            l_account_id_check := l_account_id;
            l_customer_site_use_id_check := l_customer_site_use_id;
            l_delinquency_id_check := l_delinquency_id;
           if (p_running_level = 'CUSTOMER') then
              l_account_id_check := null;
              l_customer_site_use_id_check := null;
              l_delinquency_id_check := null;
           elsif  (p_running_level = 'ACCOUNT') then
              l_customer_site_use_id_check := null;
              l_delinquency_id_check := null;
           elsif  (p_running_level = 'BILL_TO') then
              l_delinquency_id_check := null;
           end if;

           if ( iex_utilities.DunningProfileCheck (
                   p_party_id => l_party_cust_id_check
                   , p_cust_account_id => l_account_id_check
                   , p_site_use_id => l_customer_site_use_id_check
                   , p_delinquency_id => l_delinquency_id_check     ) = 'N'
              ) then
                FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_PROFILE_NO');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Send dunning in customer profile set to no ');
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           end if;


           -- ctlee - check the hz_customer_profiles_amt min_dunning_invoice_amount and min_dunning_amount
           if ( iex_utilities.DunningMinAmountCheck (
                    p_cust_account_id => l_account_id_check
                    , p_site_use_id => l_customer_site_use_id_check)  = 'N'
              ) then
                FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_AMOUNT_MIN');
                FND_MSG_PUB.Add;
                WriteLog('iexvdunb:ResendLevelDunn: Required min Dunning amount in customer profile ');
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           end if;

           WriteLog('iexvdunb:ResendLevelDunn: end check customer profile');


          /*===========================================
           * Send Letter through Fulfillment
           *===========================================*/

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SEND_FFM');
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - org_id='||l_org_id);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - party_id='||l_party_cust_id);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - method='||l_method);

           l_bind_rec.key_name := 'party_id';
           l_bind_rec.key_type := 'NUMBER';
           l_bind_rec.key_value := l_party_cust_id;
           l_bind_tbl(1) := l_bind_rec;
           l_bind_rec.key_name := 'org_id';
           l_bind_rec.key_type := 'NUMBER';
           l_bind_rec.key_value := l_org_id;
           l_bind_tbl(2) := l_bind_rec;
           l_bind_rec.key_name := 'account_id';
           l_bind_rec.key_type := 'NUMBER';
           l_bind_rec.key_value := l_account_id;
           l_bind_tbl(3) := l_bind_rec;
           -- added for new level 'BILL_TO' since 11.5.10.
           l_bind_rec.key_name := 'customer_site_use_id';
           l_bind_rec.key_type := 'NUMBER';
           l_bind_rec.key_value := l_customer_site_use_id;
           l_bind_tbl(4) := l_bind_rec;

	   --Start adding for bug 9156833 gnramasa 27th Nov 09
	 l_validation_level := FND_API.G_VALID_LEVEL_FULL;

	 if (p_running_level = 'BILL_TO') then
		iex_utilities.get_dunning_resource(p_api_version => p_api_version,
				       p_init_msg_list     => FND_API.G_TRUE,
				       p_commit            => FND_API.G_FALSE,
				       p_validation_level  => l_validation_level,
				       p_level             => 'DUNNING_BILLTO',
				       p_level_id          => l_customer_site_use_id,
				       x_msg_count         => l_msg_count,
				       x_msg_data          => l_msg_data,
				       x_return_status     => l_return_status,
				       x_resource_tab      => l_resource_tab);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     GOTO end_get_resource;
		END IF;
	  end if;

	  if l_resource_tab.count<1 and (p_running_level = 'ACCOUNT') then
		  iex_utilities.get_dunning_resource(p_api_version => p_api_version,
				       p_init_msg_list     => FND_API.G_TRUE,
				       p_commit            => FND_API.G_FALSE,
				       p_validation_level  => l_validation_level,
				       p_level             => 'DUNNING_ACCOUNT',
				       p_level_id          => l_account_id,
				       x_msg_count         => l_msg_count,
				       x_msg_data          => l_msg_data,
				       x_return_status     => l_return_status,
				       x_resource_tab      => l_resource_tab);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     GOTO end_get_resource;
		END IF;
	  end if;

	  if l_resource_tab.count<1 and (p_running_level = 'CUSTOMER') then
		iex_utilities.get_dunning_resource(p_api_version => p_api_version,
				       p_init_msg_list     => FND_API.G_TRUE,
				       p_commit            => FND_API.G_FALSE,
				       p_validation_level  => l_validation_level,
				       p_level             => 'DUNNING_PARTY',
				       p_level_id          => l_party_cust_id,
				       x_msg_count         => l_msg_count,
				       x_msg_data          => l_msg_data,
				       x_return_status     => l_return_status,
				       x_resource_tab      => l_resource_tab);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     GOTO end_get_resource;
		END IF;

		if l_resource_tab.count<1 and (p_running_level = 'CUSTOMER') then
			iex_utilities.get_dunning_resource(p_api_version => p_api_version,
						         p_init_msg_list     => FND_API.G_TRUE,
							 p_commit            => FND_API.G_FALSE,
							 p_validation_level  => l_validation_level,
							 p_level             => 'DUNNING_PARTY_ACCOUNT',
							 p_level_id          => l_party_cust_id,
							 x_msg_count         => l_msg_count,
							 x_msg_data          => l_msg_data,
							 x_return_status     => l_return_status,
							 x_resource_tab      => l_resource_tab);
			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
			     x_return_status := FND_API.G_RET_STS_ERROR;
			     GOTO end_get_resource;
			END IF;
		end if;
	  end if;

	  <<end_get_resource>>
	  if l_resource_tab.count>0 then
	    l_resource_id := l_resource_tab(1).resource_id;
	  end if;
	  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_resource_id: ' || l_resource_id);
	  --End adding for bug 9156833 gnramasa 27th Nov 09
          WriteLog(' before send_xml org_id ' || p_org_id);
         /**
          * in 11.5.11, IEX supports fulfillment and xml publisher.
          * it depends on the set up in IEX ADMIN/SETUP.
          */
          if (l_curr_dmethod = 'FFM') then

           Send_Fulfillment(
                   p_api_version              => p_api_version
                 , p_init_msg_list            => p_init_msg_list
                 , p_commit                   => p_commit
                 , p_fulfillment_bind_tbl     => l_bind_tbl
                 , p_template_id              => l_template_id
                 , p_method                   => l_method
                 , p_party_id                 => l_party_cust_id
                 , x_request_id               => l_request_id
                 , x_return_status            => x_return_status
                 , x_msg_count                => x_msg_count
                 , x_msg_data                 => x_msg_data
                 , x_contact_destination      => l_contact_destination  -- bug 3955222
                 , x_contact_party_id         => l_contact_party_id  -- bug 3955222
                 );
          else

           Send_XML(
                   p_api_version              => p_api_version
                   , p_init_msg_list            => p_init_msg_list
                   , p_commit                   => FND_API.G_FALSE  --p_commit --bug 8567312
                   , p_resend                   => 'N'
                   , p_request_id               => null
                   , p_fulfillment_bind_tbl     => l_bind_tbl
                   , p_template_id              => l_xdo_template_id
                   , p_method                   => l_method
                   , p_party_id                 => l_party_cust_id
                   , p_level                    => p_running_level
                   , p_source_id                => l_object_id
                   , p_object_code              => l_object_code
                   , p_object_id                => l_object_id
		   , p_resource_id              => l_resource_id --Added for bug 9156833 gnramasa 27th Nov 09
                   , p_org_id                   => p_org_id      -- added for bug 9151851
		   , x_request_id               => l_request_id
                   , x_return_status            => x_return_status
                   , x_msg_count                => x_msg_count
                   , x_msg_data                 => x_msg_data
                   , x_contact_destination      => l_contact_destination  -- bug 3955222
                   , x_contact_party_id         => l_contact_party_id  -- bug 3955222
                   );

          end if;

          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SEND status='|| x_return_status);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Not Sending Letters', l_write);
              x_return_status := FND_API.G_RET_STS_ERROR;
              GOTO end_api;
           END IF;


           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id='||l_request_id, l_write);
           l_ffm_cnt := l_ffm_cnt + 1;

          /*===========================================
           * Close OPEN Dunnings for each party/account
           *===========================================*/

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning', l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - runninglevel='||p_running_level, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - del cnt='||l_del_tbl.count, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - partyid='||l_del_tbl(1).party_cust_id, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - accntid='||l_del_tbl(1).cust_account_id, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - siteid='||l_del_tbl(1).customer_site_use_id, l_write);

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallCloseDunning', l_write);

             Close_DUNNING(p_api_version              => p_api_version
				                 , p_init_msg_list            => p_init_msg_list
				                 , p_commit                   => p_commit
				                 , p_delinquencies_tbl        => l_del_tbl
				                 , p_running_level            => p_running_level
				                 , x_return_status            => x_return_status
				                 , x_msg_count                => x_msg_count
				                 , x_msg_data                 => x_msg_data);

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning status='|| x_return_status, l_write);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Close Dunning', l_write);
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
             END IF;
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EndCloseDunn', l_write);

          /*===========================================
           * Create Dunning Record
           *===========================================*/

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get CallbackDate', l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag='||l_callback_flag, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDays='||l_callback_days, l_write);

            /*===================================================
             * clchang updated 02/13/2003
             * callback_days could be null if callback_yn = 'N';
             * and if callback_yn = 'N', not get callback_date;
             *==================================================*/
             IF (l_callback_flag = 'Y') THEN

                 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is Y: GetCallbackDate',l_write);
                 Get_Callback_Date( p_init_msg_list          => p_init_msg_list
                            , p_callback_days          => l_callback_days
                            , x_callback_date          => l_callback_date
                            , x_return_status          => x_return_status
                            , x_msg_count              => x_msg_count
                            , x_msg_data               => x_msg_data);

                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetCallbackDate status='|| x_return_status, l_write);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  FND_MESSAGE.Set_Name('IEX', 'IEX_NO_CALLBACKDATE');
                  FND_MSG_PUB.Add;
                  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Not Get CallbackDate', l_write);
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  GOTO end_api;
                END IF;

             ELSE
                 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is N: NOTGetCallbackDate',l_write);

             END IF;


             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDate='||l_callback_date, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunningRec', l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - objectid='||l_object_id, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - objecttype='||p_running_level, l_write);
             l_dunning_rec.dunning_level := p_running_level;
             l_dunning_rec.dunning_object_id := l_object_id;
             l_dunning_rec.callback_yn := l_callback_flag;
             l_dunning_rec.callback_date := l_callback_date;
             l_dunning_rec.status := 'OPEN';
             l_dunning_rec.dunning_method := l_method;
             if (l_curr_dmethod = 'FFM') then
               l_dunning_rec.template_id:= l_template_id;
               l_dunning_rec.ffm_request_id := l_request_id;
             else
               l_dunning_rec.xml_template_id:= l_xdo_template_id;
               l_dunning_rec.xml_request_id := l_request_id;
             end if;
             l_dunning_rec.amount_due_remaining := l_amount;
             l_dunning_rec.currency_code := l_curr_code;
             l_dunning_rec.object_type := l_object_code;
             l_dunning_rec.object_id := l_object_id;
             l_dunning_rec.dunning_plan_id := p_dunning_plan_id;
             l_dunning_rec.contact_destination := l_contact_destination;  -- bug 3955222
             l_dunning_rec.contact_party_id := l_contact_party_id;  -- bug 3955222

             l_dunning_rec.org_id := p_org_id;
	     WriteLog(' before creating dunning org_id ' || p_org_id);
	     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Insert Row', l_write);

             CREATE_DUNNING(
                   p_api_version              => p_api_version
                 , p_init_msg_list            => p_init_msg_list
                 , p_commit                   => p_commit
                 , p_dunning_rec              => l_dunning_rec
                 , x_dunning_id               => l_dunning_id
                 , x_return_status            => x_return_status
                 , x_msg_count                => x_msg_count
                 , x_msg_data                 => x_msg_data);

              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning status='|| x_return_status, l_write);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Dunning', l_write);
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   GOTO end_api;
              END IF;

              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunningId='||l_dunning_id, l_write);
              l_dunn_cnt := l_dunn_cnt + 1;



          /*===========================================
           * Update Delinquency
           * Set DUNN_YN = 'N'
           *===========================================*/

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========Summary===========');
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - For RunningLevel='||p_running_level);
             --WriteLog('iexvdunb:ResendLevelDunn:Resend - UpdateDel', l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Resend - object_id='||l_object_id, l_write);

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SendFFM Cnt='|| l_ffm_cnt, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunn Cnt='|| l_dunn_cnt, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========End Summary===========');


           <<end_api>>
           if (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
               ROLLBACK TO Resend_Level_DUNNING_PVT;
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data );
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_api:error on this party/accnt/site', l_write);
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_api:status='||x_return_status, l_write);
               --Resend need return the exact status
               --x_return_status := 'SKIP'; --FND_API.G_EXC_ERROR;
           end if;
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_api', l_write);

      ELSE -- l_noskip = 0
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - all del disputed', l_write);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - skip this party/accnt/site', l_write);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_api:status='||x_return_status, l_write);
           FND_MSG_PUB.Count_And_Get
           (  p_count          =>   x_msg_count,
              p_data           =>   x_msg_data );
           --Resend need return the exact status
           --x_return_status := 'SKIP'; --FND_API.G_EXC_ERROR;

      end if; -- end of if (l_noskip>0)
      --
      -- End of API body
      --

      x_request_id := l_request_id;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id='||x_request_id, l_write);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - status='||x_return_status, l_write);

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      WriteLog('iexvdunb:ResendLevelDunn:END', l_write);

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO Resend_Level_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM, l_write);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO Resend_Level_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM, l_write);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO Resend_Level_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM, l_write);

END Resend_Level_Dunning;

/*=========================================================================
   gnramasa added 12th Jan 2010 -
     Resend_Level_Staged_Dunning and Resend_Staged_Dunning are called by FORM,
     and just for resend;
     Only one record once, not loop;
*=========================================================================*/
Procedure Resend_Level_Staged_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_dunning_plan_id         in number,
	    p_dunning_id              in number,
            p_running_level           IN VARCHAR2,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
	    p_org_id                  in number default null,
            x_request_id              OUT NOCOPY NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS
/*
    CURSOR C_GET_DEL (IN_del_ID NUMBER) IS
      SELECT delinquency_ID
        FROM IEX_DELINQUENCIES
       WHERE delinquency_ID = in_del_ID;
    --
    -- begin bug 4914799 ctlee 12/30/2005 add p_dunning_plan_id
    CURSOR C_GET_SCORE (IN_ID NUMBER, IN_CODE VARCHAR2, p_dunning_plan_id number) IS
      SELECT a.score_value
        FROM IEX_SCORE_HISTORIES a
             , IEX_DUNNING_PLANS_VL c  -- bug 4914799 ctlee 12/30/2005
       WHERE a.score_object_ID = in_ID
         AND a.score_object_code = IN_CODE
         and c.score_id = a.score_id   -- bug 4914799 ctlee 12/30/2005
         and c.dunning_plan_id = p_dunning_plan_id -- bug 4914799 ctlee 12/30/2005
         AND a.creation_date = (select max(b.creation_date)
                                  from iex_score_histories b
                                 where b.score_object_id = in_id
                                   AND b.score_object_code = IN_CODE);
    -- end bug 4914799 ctlee 12/30/2005 add p_dunning_plan_id
    --
    CURSOR C_GET_TEMPLATE (l_line_id NUMBER,
                           l_score NUMBER, in_LEVEL VARCHAR2, p_dunning_plan_id number) IS
      SELECT x.template_id,
             x.xdo_template_id,
             x.fm_method,
             upper(x.callback_flag),
             x.callback_days
        FROM IEX_AG_DN_XREF x,
             ar_aging_buckets ar,
             iex_dunning_plans_vl d
       WHERE x.aging_bucket_line_ID = l_line_ID
         and x.dunning_plan_id = p_dunning_plan_id
         AND l_score between x.score_range_low and x.score_range_high
         AND x.aging_bucket_id = ar.aging_bucket_id
         and ar.aging_bucket_id = d.aging_bucket_id
         AND ar.status = 'A'
         AND x.dunning_level = IN_LEVEL ;
*/
    --

    l_DUNNING_id            NUMBER;
    l_delinquency_id        NUMBER;
    l_party_cust_id         NUMBER;
    l_account_id            NUMBER;
    l_customer_site_use_id  NUMBER;
    l_noskip                NUMBER := 0;
    l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_DUNNING_tbl           IEX_DUNNING_PUB.DUNNING_TBL_TYPE;
    l_score                 NUMBER;
    l_bucket_line_id        NUMBER;
    l_campaign_sched_id     NUMBER;
    l_template_id           NUMBER;
    l_xdo_template_id       NUMBER;
    l_method                VARCHAR2(10);
    l_callback_flag         VARCHAR2(1);
    l_callback_days         NUMBER;
    l_callback_date         DATE;
    l_request_id            NUMBER;
    l_outcome_code          varchar2(20);
    l_api_name              CONSTANT VARCHAR2(30) := 'Resend_Level_Staged_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);
    --
    nIdx                    NUMBER := 0;
    TYPE Del_ID_TBL_type is Table of IEX_DELINQUENCIES_ALL.DELINQUENCY_ID%TYPE
                            INDEX BY BINARY_INTEGER;
    Del_Tbl                 Del_ID_TBL_TYPE;
    l_bind_tbl              IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
    l_bind_rec              IEX_DUNNING_PVT.FULFILLMENT_BIND_REC;
    l_org_id                NUMBER ;
    l_running_level         VARCHAR2(25);
    l_object_Code           VARCHAR2(25);
    l_object_id             NUMBER;
    --l_delid_tbl             IEX_DUNNING_PUB.DelId_NumList;
    l_del_tbl               IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE;
    l_curr_code             VARCHAR2(15);
    l_amount                NUMBER;
    l_write                 NUMBER;
    l_ffm_cnt               NUMBER := 0;
    l_dunn_cnt              NUMBER := 0;
    l_curr_dmethod          VARCHAR2(10);

    l_delinquency_id_check        NUMBER;
    l_party_cust_id_check         NUMBER;
    l_account_id_check            NUMBER;
    l_customer_site_use_id_check  NUMBER;
    l_contact_destination         varchar2(240);  -- bug 3955222
    l_contact_party_id            number; -- bug 3955222

    CURSOR C_GET_DUNNING (in_dunning_id NUMBER) IS
    SELECT dunning_object_id,
          delinquency_id,
          dunning_level,
	  xml_template_id,
	  ag_dn_xref_id,
	  xml_request_id
     FROM iex_dunnings
    WHERE dunning_id = in_dunning_id;

    CURSOR C_CALLBACK_DETAILS (p_ag_dn_xref_id number) IS
      SELECT x.fm_method,
	     upper(x.callback_flag),
             x.callback_days
        FROM IEX_AG_DN_XREF x
       WHERE x.ag_dn_xref_id = p_ag_dn_xref_id;

    l_dunning_object_id       number;
    l_del_id                  number;
    l_dunning_level	      varchar2(20);
    l_ag_dn_xref_id	      number;
    l_xml_request_id	      number;

    --Start adding for bug 9156833 gnramasa 27th Nov 09
    l_validation_level		  NUMBER ;
    l_resource_tab		  iex_utilities.resource_tab_type;
    l_resource_id		  NUMBER;
    --End adding for bug 9156833 gnramasa 27th Nov 09

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Resend_Level_Stg_Dunn_PVT;

      --Bug#4679639 schekuri 20-OCT-2005
      --Value of profile ORG_ID shouldn't be used for getting ORG_ID after MOAC implementation
      l_org_id:= mo_global.get_current_org_id;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- don't write into FILE
      l_write := 0;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - running_level='||p_running_level);

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      l_party_cust_id := p_delinquencies_tbl(1).party_cust_id;
      l_account_id := p_delinquencies_tbl(1).cust_account_id;
      l_customer_site_use_id := p_delinquencies_tbl(1).customer_site_use_id;

      if (p_running_level = 'CUSTOMER') then
          l_object_Code := 'PARTY';
          l_object_id := p_delinquencies_tbl(1).party_cust_id;
          l_del_tbl(1).party_cust_id := p_delinquencies_tbl(1).party_cust_id;
          l_amount := staged_dunn_amt_due_remaining(p_dunning_id); --Changed for bug 9503251 gnramasa 22nd apr 2010
          l_curr_code := party_currency_code(l_object_id);
      --
      elsif (p_running_level = 'ACCOUNT') then
          l_object_Code := 'IEX_ACCOUNT';
          l_object_id := p_delinquencies_tbl(1).cust_account_id;
          l_del_tbl(1).cust_account_id := p_delinquencies_tbl(1).cust_account_id;
          l_amount := staged_dunn_amt_due_remaining(p_dunning_id); --Changed for bug 9503251 gnramasa 22nd apr 2010
          l_curr_code := acct_currency_code(l_object_id);
      --
      elsif (p_running_level = 'BILL_TO') then
          l_object_Code := 'IEX_BILLTO';
          l_object_id := p_delinquencies_tbl(1).customer_site_use_id;
          l_del_tbl(1).customer_site_use_id := p_delinquencies_tbl(1).customer_site_use_id;
          l_amount := staged_dunn_amt_due_remaining(p_dunning_id); --Changed for bug 9503251 gnramasa 22nd apr 2010
          l_curr_code := site_currency_code(l_object_id);
      end if;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_code='||l_object_code);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_id='||l_object_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - party_id='||l_party_cust_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - amount_due_remaining='||l_amount);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - currency_code='||l_curr_code);

      open C_GET_DUNNING (p_dunning_id);
      fetch C_GET_DUNNING into l_dunning_object_id, l_del_id, l_dunning_level, l_xdo_template_id, l_ag_dn_xref_id, l_xml_request_id;
      close C_GET_DUNNING;

      open C_CALLBACK_DETAILS (l_ag_dn_xref_id);
      fetch C_CALLBACK_DETAILS into l_method, l_callback_flag, l_callback_days;
      close C_CALLBACK_DETAILS;

      /*==================================================================
       * l_noskip is used to trace the del data is all disputed or not;
       * if any one del not disputed, then l_noskip=1;
       * if l_noskip=0, then means all del are disputed,
       *    => for this customer/account, skip it;
       *==================================================================*/
      l_noskip := 1;

/*
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delcnt='||p_delinquencies_tbl.count);

        FOR i in 1..p_delinquencies_tbl.count
        LOOP

          l_delinquency_id := p_delinquencies_tbl(i).delinquency_id;
*/
         /*=============================================================
          *  For each Delinquency,
          *=============================================================*/

--          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - open del='||l_delinquency_Id);

         /*=============================================================
          * IsDispute ?
          * If yes => stop (exit);
          * else continue;
          *
          * it returns values :
          * 1) it returns 'F' if no dispute exists for the delinquency
          * 2) it returns 'T' if dispute exists and is pending
          * 3) it returns 'F' if dispute exists and its staus is "COMPLETE"
          *===========================================================*/

/*          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ResendLevelDunn:Chk IsDispute');

           IEX_DISPUTE_PVT.Is_Delinquency_Dispute(p_api_version              => p_api_version
																			           , p_init_msg_list            => p_init_msg_list
																			           , p_delinquency_id           => l_delinquency_id
																			           , x_return_status            => x_return_status
																			           , x_msg_count                => x_msg_count
																			           , x_msg_data                 => x_msg_data);

           IF x_return_status = 'T' THEN
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Dispute exists and is pending for del '|| l_delinquency_id);
             GOTO end_del;
           elsif x_return_status = 'F' THEN
              -- if one del is not disputed, then l_noskip=1;
              l_noskip := 1;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No Dispute or status is COMPLETE');
           END IF;

           nIdx := nIdx + 1;
           del_tbl(nIdx) := l_delinquency_id; --in order to update del)

          <<end_del>>
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Close C_GET_DEL');

       END LOOP; -- end of DELINQUENCIES_TBL loop
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END LOOP');
*/
      IF (l_noskip > 0) THEN

         -- init the msg (not including the msg from dispute api)
         --FND_MSG_PUB.initialize;

          /*===========================================
           * Get Score From IEX_SCORE_HISTORIES
           * If NotFound => Call API to getScore;
           *===========================================*/
/*
	   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get Score');
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - objectCode='||l_object_Code);

           Open C_Get_SCORE(l_object_id, l_object_Code, p_dunning_plan_id);
           Fetch C_Get_SCORE into l_score;

           If ( C_GET_SCORE%NOTFOUND) Then
                --FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
                --FND_MESSAGE.Set_Token ('INFO', 'Score', FALSE);
                FND_MESSAGE.Set_Name('IEX', 'IEX_NO_SCORE');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Score NotFound');
                Close C_Get_SCORE;
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           END IF;

           --WriteLog('iexvdunb:ResendLevelDunn:CLOSE C_GET_SCORE', l_write);
           Close C_Get_SCORE;

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get Score='||l_score);
*/

          /*===================================================
           * in 11.5.11, support aging bucket line for all level;
           * clchang added 11/20/04.
           * Get Aging_Bucket_Line_id for each party/acct/site
           *===================================================*/
/*
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetAgingBucketLineId');

           AGING_DEL(p_api_version              => p_api_version
		                , p_init_msg_list            => p_init_msg_list
		                , p_commit                   => p_commit
		                , p_delinquency_id           => null
		                , p_dunning_plan_id          => p_dunning_plan_id
		                , p_bucket                   => null
		                , p_object_code              => l_object_code
		                , p_object_id                => l_object_id
		                , x_return_status            => x_return_status
		                , x_msg_count                => x_msg_count
		                , x_msg_data                 => x_msg_data
		                , x_aging_bucket_line_id     => l_bucket_line_id);

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - AgingDel status='||x_return_status);

           If ( x_return_status <> FND_API.G_RET_STS_SUCCESS) Then
                --FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
                --FND_MESSAGE.Set_Token ('INFO', 'AgingBucketLineId', FALSE);
                FND_MESSAGE.Set_Name('IEX', 'IEX_NO_AGINGBUCKETLINE');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - AgingBucketLineId notfound');
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           END IF;

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - lineid='||l_bucket_line_id);
*/
          /*===========================================
           * Get Template_ID From iex_ag_dn_xref
           *===========================================*/
/*
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GET Template');

           Open C_Get_TEMPLATE(l_bucket_line_id, l_score, p_running_level, p_dunning_plan_id);
           Fetch C_Get_TEMPLATE into
                       l_template_id,
                       l_xdo_template_id,
                       l_method,
                       l_callback_flag,
                       l_callback_days;

           If ( C_GET_TEMPLATE%NOTFOUND) Then
                FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - template notfound');
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           END IF;

           Close C_Get_TEMPLATE;

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get template_id='||l_template_id);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get xdo_template_id='||l_xdo_template_id, l_write);
*/
          /*===========================================
           * Check template
           *  in 11.5.11, IEX supports fulfillment and xml publisher.
           *  if the current setup for delivery id FFM,
           *  then template_id is necessary;
           *  if XML, xdo_template_id is necessary;
           *===========================================*/

           l_curr_dmethod := IEX_SEND_XML_PVT.getCurrDeliveryMethod;
           WriteLog('iexvdunb:ResendLevelDunn:curr d_method='||l_curr_dmethod);
           if ( (l_curr_dmethod is null or l_curr_dmethod = '') or
	      (l_curr_dmethod = 'FFM' and l_template_id is null)  or
	      (l_curr_dmethod = 'XML' and l_xdo_template_id is null ) ) then
                --FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
                --FND_MESSAGE.Set_Token ('INFO', 'Template_ID', FALSE);
                FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Template notfound');
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           end if;

          /*===========================================
           * Check profile before send dunning
           *===========================================*/

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - begin check customer profile');
            -- ctlee - check the hz_customer_profiles.dunning_letter
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_party_cust_id = ' || l_party_cust_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_account_id = ' || l_account_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_customer_site_use_id = ' || l_customer_site_use_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_delinquency_id = ' || l_delinquency_id);
            -- ctlee - check the hz_customer_profiles.dunning_letter
            l_party_cust_id_check := l_party_cust_id;
            l_account_id_check := l_account_id;
            l_customer_site_use_id_check := l_customer_site_use_id;
            l_delinquency_id_check := l_delinquency_id;
           if (p_running_level = 'CUSTOMER') then
              l_account_id_check := null;
              l_customer_site_use_id_check := null;
              l_delinquency_id_check := null;
           elsif  (p_running_level = 'ACCOUNT') then
              l_customer_site_use_id_check := null;
              l_delinquency_id_check := null;
           elsif  (p_running_level = 'BILL_TO') then
              l_delinquency_id_check := null;
           end if;

           if ( iex_utilities.DunningProfileCheck (
                   p_party_id => l_party_cust_id_check
                   , p_cust_account_id => l_account_id_check
                   , p_site_use_id => l_customer_site_use_id_check
                   , p_delinquency_id => l_delinquency_id_check     ) = 'N'
              ) then
                FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_PROFILE_NO');
                FND_MSG_PUB.Add;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Send dunning in customer profile set to no ');
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           end if;

/*
           -- ctlee - check the hz_customer_profiles_amt min_dunning_invoice_amount and min_dunning_amount
           if ( iex_utilities.DunningMinAmountCheck (
                    p_cust_account_id => l_account_id_check
                    , p_site_use_id => l_customer_site_use_id_check)  = 'N'
              ) then
                FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_AMOUNT_MIN');
                FND_MSG_PUB.Add;
                WriteLog('iexvdunb:ResendLevelDunn: Required min Dunning amount in customer profile ');
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
           end if;

           WriteLog('iexvdunb:ResendLevelDunn: end check customer profile');

*/
          /*===========================================
           * Send Letter through Fulfillment
           *===========================================*/

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SEND_FFM');
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - org_id='||l_org_id);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - party_id='||l_party_cust_id);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - method='||l_method);

           l_bind_rec.key_name := 'party_id';
           l_bind_rec.key_type := 'NUMBER';
           l_bind_rec.key_value := l_party_cust_id;
           l_bind_tbl(1) := l_bind_rec;
           l_bind_rec.key_name := 'org_id';
           l_bind_rec.key_type := 'NUMBER';
           l_bind_rec.key_value := l_org_id;
           l_bind_tbl(2) := l_bind_rec;
           l_bind_rec.key_name := 'account_id';
           l_bind_rec.key_type := 'NUMBER';
           l_bind_rec.key_value := l_account_id;
           l_bind_tbl(3) := l_bind_rec;
           -- added for new level 'BILL_TO' since 11.5.10.
           l_bind_rec.key_name := 'customer_site_use_id';
           l_bind_rec.key_type := 'NUMBER';
           l_bind_rec.key_value := l_customer_site_use_id;
           l_bind_tbl(4) := l_bind_rec;
	   l_bind_rec.key_name := 'DUNNING_ID';
           l_bind_rec.key_type := 'NUMBER';
           l_bind_rec.key_value := p_dunning_id;
           l_bind_tbl(5) := l_bind_rec;

	   --Start adding for bug 9156833 gnramasa 27th Nov 09
	 l_validation_level := FND_API.G_VALID_LEVEL_FULL;

	 if (p_running_level = 'BILL_TO') then
		iex_utilities.get_dunning_resource(p_api_version => p_api_version,
				       p_init_msg_list     => FND_API.G_TRUE,
				       p_commit            => FND_API.G_FALSE,
				       p_validation_level  => l_validation_level,
				       p_level             => 'DUNNING_BILLTO',
				       p_level_id          => l_customer_site_use_id,
				       x_msg_count         => l_msg_count,
				       x_msg_data          => l_msg_data,
				       x_return_status     => l_return_status,
				       x_resource_tab      => l_resource_tab);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     GOTO end_get_resource;
		END IF;
	  end if;

	  if l_resource_tab.count<1 and (p_running_level = 'ACCOUNT') then
		  iex_utilities.get_dunning_resource(p_api_version => p_api_version,
				       p_init_msg_list     => FND_API.G_TRUE,
				       p_commit            => FND_API.G_FALSE,
				       p_validation_level  => l_validation_level,
				       p_level             => 'DUNNING_ACCOUNT',
				       p_level_id          => l_account_id,
				       x_msg_count         => l_msg_count,
				       x_msg_data          => l_msg_data,
				       x_return_status     => l_return_status,
				       x_resource_tab      => l_resource_tab);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     GOTO end_get_resource;
		END IF;
	  end if;

	  if l_resource_tab.count<1 and (p_running_level = 'CUSTOMER') then
		iex_utilities.get_dunning_resource(p_api_version => p_api_version,
				       p_init_msg_list     => FND_API.G_TRUE,
				       p_commit            => FND_API.G_FALSE,
				       p_validation_level  => l_validation_level,
				       p_level             => 'DUNNING_PARTY',
				       p_level_id          => l_party_cust_id,
				       x_msg_count         => l_msg_count,
				       x_msg_data          => l_msg_data,
				       x_return_status     => l_return_status,
				       x_resource_tab      => l_resource_tab);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     GOTO end_get_resource;
		END IF;

		if l_resource_tab.count<1 and (p_running_level = 'CUSTOMER') then
			iex_utilities.get_dunning_resource(p_api_version => p_api_version,
						         p_init_msg_list     => FND_API.G_TRUE,
							 p_commit            => FND_API.G_FALSE,
							 p_validation_level  => l_validation_level,
							 p_level             => 'DUNNING_PARTY_ACCOUNT',
							 p_level_id          => l_party_cust_id,
							 x_msg_count         => l_msg_count,
							 x_msg_data          => l_msg_data,
							 x_return_status     => l_return_status,
							 x_resource_tab      => l_resource_tab);
			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
			     x_return_status := FND_API.G_RET_STS_ERROR;
			     GOTO end_get_resource;
			END IF;
		end if;
	  end if;

	  <<end_get_resource>>
	  if l_resource_tab.count>0 then
	    l_resource_id := l_resource_tab(1).resource_id;
	  end if;
	  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_resource_id: ' || l_resource_id);
	  --End adding for bug 9156833 gnramasa 27th Nov 09

	   WriteLog(G_PKG_NAME || ' ' || l_api_name ||' before send_xml org_id ' || p_org_id);

         /**
          * in 11.5.11, IEX supports fulfillment and xml publisher.
          * it depends on the set up in IEX ADMIN/SETUP.
          */
          if (l_curr_dmethod = 'FFM') then

           Send_Fulfillment(
                   p_api_version              => p_api_version
                 , p_init_msg_list            => p_init_msg_list
                 , p_commit                   => p_commit
                 , p_fulfillment_bind_tbl     => l_bind_tbl
                 , p_template_id              => l_template_id
                 , p_method                   => l_method
                 , p_party_id                 => l_party_cust_id
                 , x_request_id               => l_request_id
                 , x_return_status            => x_return_status
                 , x_msg_count                => x_msg_count
                 , x_msg_data                 => x_msg_data
                 , x_contact_destination      => l_contact_destination  -- bug 3955222
                 , x_contact_party_id         => l_contact_party_id  -- bug 3955222
                 );
          else

           Send_XML(
                   p_api_version              => p_api_version
                   , p_init_msg_list            => p_init_msg_list
                   , p_commit                   => FND_API.G_FALSE  --p_commit --bug 8567312
                   , p_resend                   => 'Y'
                   , p_request_id               => l_xml_request_id
                   , p_fulfillment_bind_tbl     => l_bind_tbl
                   , p_template_id              => l_xdo_template_id
                   , p_method                   => l_method
                   , p_party_id                 => l_party_cust_id
                   , p_level                    => p_running_level
                   , p_source_id                => l_object_id
                   , p_object_code              => l_object_code
                   , p_object_id                => l_object_id
		   , p_resource_id              => l_resource_id --Added for bug 9156833 gnramasa 27th Nov 09
		   , p_org_id                   => p_org_id
                   , x_request_id               => l_request_id
                   , x_return_status            => x_return_status
                   , x_msg_count                => x_msg_count
                   , x_msg_data                 => x_msg_data
                   , x_contact_destination      => l_contact_destination  -- bug 3955222
                   , x_contact_party_id         => l_contact_party_id  -- bug 3955222
                   );

          end if;

          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SEND status='|| x_return_status);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Not Sending Letters', l_write);
              x_return_status := FND_API.G_RET_STS_ERROR;
              GOTO end_api;
           END IF;


           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id='||l_request_id, l_write);
           l_ffm_cnt := l_ffm_cnt + 1;

          /*===========================================
           * Close OPEN Dunnings for each party/account
           *===========================================*/

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning', l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - runninglevel='||p_running_level, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - del cnt='||l_del_tbl.count, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - partyid='||l_del_tbl(1).party_cust_id, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - accntid='||l_del_tbl(1).cust_account_id, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - siteid='||l_del_tbl(1).customer_site_use_id, l_write);

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Call Close_Staged_Dunning', l_write);

             Close_Staged_Dunning(p_api_version              => p_api_version
				 , p_init_msg_list            => p_init_msg_list
				 , p_commit                   => p_commit
				 , p_delinquencies_tbl        => l_del_tbl
				 , p_ag_dn_xref_id	      => l_ag_dn_xref_id
				 , p_running_level            => p_running_level
				 , x_return_status            => x_return_status
				 , x_msg_count                => x_msg_count
				 , x_msg_data                 => x_msg_data);

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Close_Staged_Dunning status='|| x_return_status, l_write);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Close Dunning', l_write);
                x_return_status := FND_API.G_RET_STS_ERROR;
                GOTO end_api;
             END IF;
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End Close_Staged_Dunning', l_write);

          /*===========================================
           * Create Dunning Record
           *===========================================*/

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get CallbackDate', l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag='||l_callback_flag, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDays='||l_callback_days, l_write);

            /*===================================================
             * clchang updated 02/13/2003
             * callback_days could be null if callback_yn = 'N';
             * and if callback_yn = 'N', not get callback_date;
             *==================================================*/
             IF (l_callback_flag = 'Y') THEN

                 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is Y: GetCallbackDate',l_write);
                 Get_Callback_Date( p_init_msg_list          => p_init_msg_list
                            , p_callback_days          => l_callback_days
                            , x_callback_date          => l_callback_date
                            , x_return_status          => x_return_status
                            , x_msg_count              => x_msg_count
                            , x_msg_data               => x_msg_data);

                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetCallbackDate status='|| x_return_status, l_write);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  FND_MESSAGE.Set_Name('IEX', 'IEX_NO_CALLBACKDATE');
                  FND_MSG_PUB.Add;
                  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Not Get CallbackDate', l_write);
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  GOTO end_api;
                END IF;

             ELSE
                 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is N: NOTGetCallbackDate',l_write);

             END IF;


             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDate='||l_callback_date, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunningRec', l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - objectid='||l_object_id, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - objecttype='||p_running_level, l_write);
             l_dunning_rec.dunning_level := p_running_level;
             l_dunning_rec.dunning_object_id := l_object_id;
             l_dunning_rec.callback_yn := l_callback_flag;
             l_dunning_rec.callback_date := l_callback_date;
             l_dunning_rec.status := 'OPEN';
             l_dunning_rec.dunning_method := l_method;
             if (l_curr_dmethod = 'FFM') then
               l_dunning_rec.template_id:= l_template_id;
               l_dunning_rec.ffm_request_id := l_request_id;
             else
               l_dunning_rec.xml_template_id:= l_xdo_template_id;
               l_dunning_rec.xml_request_id := l_request_id;
             end if;
             l_dunning_rec.amount_due_remaining := l_amount;
             l_dunning_rec.currency_code := l_curr_code;
             l_dunning_rec.object_type := l_object_code;
             l_dunning_rec.object_id := l_object_id;
             l_dunning_rec.dunning_plan_id := p_dunning_plan_id;
             l_dunning_rec.contact_destination := l_contact_destination;  -- bug 3955222
             l_dunning_rec.contact_party_id := l_contact_party_id;  -- bug 3955222
	     l_dunning_rec.ag_dn_xref_id    := l_ag_dn_xref_id;
	     l_dunning_rec.org_id := p_org_id;
	     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' before creating dunning org_id ' || p_org_id);

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Insert Row', l_write);

             CREATE_DUNNING(
                   p_api_version              => p_api_version
                 , p_init_msg_list            => p_init_msg_list
                 , p_commit                   => p_commit
                 , p_dunning_rec              => l_dunning_rec
                 , x_dunning_id               => l_dunning_id
                 , x_return_status            => x_return_status
                 , x_msg_count                => x_msg_count
                 , x_msg_data                 => x_msg_data);

              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning status='|| x_return_status, l_write);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Dunning', l_write);
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   GOTO end_api;
              END IF;

              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunningId='||l_dunning_id, l_write);
              l_dunn_cnt := l_dunn_cnt + 1;



          /*===========================================
           * Update Delinquency
           * Set DUNN_YN = 'N'
           *===========================================*/

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========Summary===========');
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - For RunningLevel='||p_running_level);
             --WriteLog('iexvdunb:ResendLevelDunn:Resend - UpdateDel', l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Resend - object_id='||l_object_id, l_write);

             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SendFFM Cnt='|| l_ffm_cnt, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunn Cnt='|| l_dunn_cnt, l_write);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========End Summary===========');


           <<end_api>>
           if (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
               ROLLBACK TO Resend_Level_Stg_Dunn_PVT;
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data );
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_api:error on this party/accnt/site', l_write);
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_api:status='||x_return_status, l_write);
               --Resend need return the exact status
               --x_return_status := 'SKIP'; --FND_API.G_EXC_ERROR;
           end if;
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_api', l_write);

      ELSE -- l_noskip = 0
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - all del disputed', l_write);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - skip this party/accnt/site', l_write);
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_api:status='||x_return_status, l_write);
           FND_MSG_PUB.Count_And_Get
           (  p_count          =>   x_msg_count,
              p_data           =>   x_msg_data );
           --Resend need return the exact status
           --x_return_status := 'SKIP'; --FND_API.G_EXC_ERROR;

      end if; -- end of if (l_noskip>0)
      --
      -- End of API body
      --

      x_request_id := l_request_id;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id='||x_request_id, l_write);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - status='||x_return_status, l_write);

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      WriteLog('iexvdunb:ResendLevelDunn:END', l_write);

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO Resend_Level_Stg_Dunn_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM, l_write);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO Resend_Level_Stg_Dunn_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM, l_write);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              ROLLBACK TO Resend_Level_Stg_Dunn_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM, l_write);

END Resend_Level_Staged_Dunning;

Procedure Resend_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_dunning_plan_id         in number,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_org_id                  in number,
	    x_request_id              OUT NOCOPY NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
    CURSOR C_GET_DEL (IN_del_ID NUMBER) IS
      SELECT delinquency_ID,
             party_cust_id,
             cust_account_id,
             customer_site_use_id,
             score_value
        FROM IEX_DELINQUENCIES
       WHERE delinquency_ID = in_del_ID;
    --
    CURSOR C_GET_SCORE (IN_ID NUMBER) IS
      SELECT a.score_value
        FROM IEX_SCORE_HISTORIES a
       WHERE a.score_object_ID = in_ID
         AND a.score_object_code = 'IEX_DELINQUENCY'
         AND a.creation_date = (select max(b.creation_date)
                                  from iex_score_histories b
                                 where b.score_object_id = in_id
                                   AND b.score_object_code = 'IEX_DELINQUENCY');
    --
    --
    CURSOR C_GET_TEMPLATE (l_line_id NUMBER,
                           l_score NUMBER, p_dunning_plan_id number) IS
      SELECT x.template_id,
             x.xdo_template_id,
             x.fm_method,
             upper(x.callback_flag),
             x.callback_days,
             ar.bucket_name
        FROM IEX_AG_DN_XREF x,
             ar_aging_buckets ar,
             iex_dunning_plans_vl d
       WHERE x.aging_bucket_line_ID = l_line_ID
         and x.dunning_plan_id = p_dunning_plan_id
         AND l_score between x.score_range_low and x.score_range_high
         AND x.aging_bucket_id = ar.aging_bucket_id
         and ar.aging_bucket_id = d.aging_bucket_id
         AND ar.status = 'A'
         AND x.dunning_level = 'DELINQUENCY' ;
    --
    cursor c_amount (IN_ID number) is
     select ps.amount_due_remaining,
            ps.invoice_currency_code
       from ar_payment_schedules_all ps,
            --iex_delinquencies_all del
            iex_delinquencies del
      where ps.payment_schedule_id (+)= del.payment_schedule_id
        and del.delinquency_id = in_id;
    --

    l_AMOUNT                NUMBER;
    l_CURR_CODE             VARCHAR2(15);
    l_DUNNING_id            NUMBER;
    l_delinquency_id        NUMBER;
    l_party_cust_id         NUMBER;
    l_account_id            NUMBER;
    l_customer_site_use_id  NUMBER;
    l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_score                 NUMBER;
    l_bucket_line_id        NUMBER;
    l_campaign_sched_id     NUMBER;
    l_template_id           NUMBER;
    l_xdo_template_id       NUMBER;
    l_method                VARCHAR2(10);
    l_callback_flag         VARCHAR2(1);
    l_callback_days         NUMBER;
    l_callback_date         DATE;
    l_request_id            NUMBER;
    l_outcome_code          varchar2(20);
    l_api_name              CONSTANT VARCHAR2(30) := 'Resend_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);
    --
    nIdx                    NUMBER := 0;
    TYPE Del_ID_TBL_type is Table of IEX_DELINQUENCIES_ALL.DELINQUENCY_ID%TYPE
                            INDEX BY BINARY_INTEGER;
    Del_Tbl                 Del_ID_TBL_TYPE;
    l_bind_tbl              IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
    l_bind_rec              IEX_DUNNING_PVT.FULFILLMENT_BIND_REC;
    l_org_id                NUMBER ;
    --l_delid_tbl             IEX_DUNNING_PUB.DelId_NumList;
    l_del_tbl               IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE;
    l_ffm_cnt               NUMBER := 0;
    l_dunn_cnt              NUMBER := 0;
    l_bucket                VARCHAR2(100);
    i                       NUMBER := 0;
    l_running_level         VARCHAR2(25);
    l_object_Code           VARCHAR2(25);
    l_object_id             NUMBER;
    l_curr_dmethod          VARCHAR2(10);
    l_contact_destination         varchar2(240);  -- bug 3955222
    l_contact_party_id            number; -- bug 3955222
    --Start adding for bug 9156833 gnramasa 27th Nov 09
    l_validation_level		  NUMBER ;
    l_resource_tab		  iex_utilities.resource_tab_type;
    l_resource_id		  NUMBER;
    --End adding for bug 9156833 gnramasa 27th Nov 09

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Resend_DUNNING_PVT;

      --Bug#4679639 schekuri 20-OCT-2005
      --Value of profile ORG_ID shouldn't be used for getting ORG_ID after MOAC implementation
      --l_org_id := fnd_profile.value('ORG_ID');
      l_org_id:= mo_global.get_current_org_id;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --dont write into FND_FILE
      --l_write := 0;

      --
      -- Api body
      --

      -- only one del record
      i := 1;

      l_delinquency_id := p_delinquencies_tbl(i).delinquency_id;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==================');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_Id);

      -- Validate Data

     /*=============================================================
      *  For each Delinquency,
      *=============================================================*/

      Open C_Get_DEL(l_delinquency_id);
      Fetch C_Get_DEL into
               l_delinquency_id,
               l_party_cust_id,
               l_account_id,
               l_customer_site_use_id,
               l_score;

      If ( C_GET_DEL%NOTFOUND) Then
           WriteLog('iexvdunb.pls:ResendDunn:No Open Del');

      else

        WriteLog('iexvdunb.pls:ResendDunn:open del='||l_delinquency_Id);

        /*===============================================================
         * IsDispute ?
         * If yes => stop (exit);
         * else continue;
         *
         * it returns values :
         * 1) it returns 'F' if no dispute exists for the delinquency
         * 2) it returns 'T' if dispute exists and is pending
         * 3) it returns 'F' if dispute exists and its staus is "COMPLETE"
         *==============================================================*/

        WriteLog('iexvdunb.pls:ResendDunn:Chk IsDispute');

        IEX_DISPUTE_PVT.Is_Delinquency_Dispute(p_api_version              => p_api_version
			 														            , p_init_msg_list            => p_init_msg_list
			 														            , p_delinquency_id           => l_delinquency_id
			 														            , x_return_status            => x_return_status
			 														            , x_msg_count                => x_msg_count
			 														            , x_msg_data                 => x_msg_data);

        IF x_return_status = 'T' THEN
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Dispute exists and is pending');
           GOTO end_loop;
        elsif x_return_status = 'F' THEN
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No Dispute or status is COMPLETE');
        END IF;

        -- init msg (not from dispute api)
        FND_MSG_PUB.initialize;

       /*===========================================
        * Get Score From IEX_SCORE_HISTORIES
        * If NotFound => Call API to getScore;
        *===========================================*/
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Score='|| l_score);
       /*===========================================
        * get Aging_Bucket_Line_Id for each Del
        *===========================================*/

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetAgingBucketLineId');
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_id);

          AGING_DEL(p_api_version              => p_api_version
			              , p_init_msg_list            => p_init_msg_list
			              , p_commit                   => p_commit
			              , p_delinquency_id           => l_delinquency_id
			              , p_dunning_plan_id          => p_dunning_plan_id
			              , p_bucket                   => l_bucket
			              , x_return_status            => x_return_status
			              , x_msg_count                => x_msg_count
			              , x_msg_data                 => x_msg_data
			              , x_aging_bucket_line_id     => l_bucket_line_id);

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - AgingDel status='||x_return_status);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         FND_MESSAGE.Set_Name('IEX', 'IEX_NO_AGINGBUCKETLINE');
         FND_MSG_PUB.Add;
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Get AgingBucketLineId');
         GOTO end_loop;
       END IF;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - lineid='||l_bucket_line_id);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EndAgingDel');

       /*==========================================
       * Get Template_ID From iex_ag_dn_xref
       *===========================================*/

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GET Template');

       Open C_Get_TEMPLATE(l_bucket_line_ID, l_score, p_dunning_plan_id);
       Fetch C_Get_TEMPLATE into
             l_template_id,
             l_xdo_template_id,
             l_method,
             l_callback_flag,
             l_callback_days,
             l_bucket;

       If ( C_GET_TEMPLATE%NOTFOUND) Then
           FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
           FND_MSG_PUB.Add;
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - template notfound');
           Close C_Get_TEMPLATE;
           GOTO end_loop;
       END IF;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - close C_GET_TEMPLATE');
       Close C_Get_TEMPLATE;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get template_id='||l_template_id);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get xdo_template_id='||l_xdo_template_id);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get bucket='||l_bucket);


      /*===========================================
       * Check template
       *  in 11.5.11, IEX supports fulfillment and xml publisher.
       *  if the current setup for delivery id FFM,
       *  then template_id is necessary;
       *  if XML, xdo_template_id is necessary;
       *===========================================*/

       l_curr_dmethod := IEX_SEND_XML_PVT.getCurrDeliveryMethod;
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - curr d_method='||l_curr_dmethod);
       if ( (l_curr_dmethod is null or l_curr_dmethod = '') or
            (l_curr_dmethod = 'FFM' and l_template_id is null)  or
            (l_curr_dmethod = 'XML' and l_xdo_template_id is null ) ) then
            FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
            FND_MSG_PUB.Add;
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Template notfound');
            x_return_status := FND_API.G_RET_STS_ERROR;
            GOTO end_loop;
       end if;

      /*===========================================
       * Check profile before send dunning
       *===========================================*/

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - begin check customer profile');
        -- ctlee - check the hz_customer_profiles.dunning_letter
       if ( iex_utilities.DunningProfileCheck (
               p_party_id => l_party_cust_id
               , p_cust_account_id => l_account_id
               , p_site_use_id => l_customer_site_use_id
               , p_delinquency_id => l_delinquency_id     ) = 'N'
          ) then
            FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_PROFILE_NO');
            FND_MSG_PUB.Add;
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Send dunning in customer profile set to no ');
            GOTO end_loop;
       end if;


       -- ctlee - check the hz_customer_profiles_amt min_dunning_invoice_amount and min_dunning_amount
       if ( iex_utilities.DunningMinAmountCheck (
                p_cust_account_id => l_account_id
                , p_site_use_id => l_customer_site_use_id)  = 'N'
          ) then
            FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_AMOUNT_MIN');
            FND_MSG_PUB.Add;
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Required min Dunning amount in customer profile ');
            GOTO end_loop;
       end if;

       WriteLog('iexvdunb:ResendDunn: end check customer profile');


       /*===========================================
        * Send Letter through Fulfillment
        *===========================================*/

        WriteLog('iexvdunb.pls:ResendDunn:Send_Ffm');
        WriteLog('iexvdunb.pls:ResendDunn:orgid='||l_org_id);
        WriteLog('iexvdunb.pls:ResendDunn:partyid='||l_party_cust_id);
        WriteLog('iexvdunb.pls:ResendDunn:acctid='||l_account_id);
        WriteLog('iexvdunb.pls:ResendDunn:lineid='||l_bucket_line_id);
        WriteLog('iexvdunb.pls:ResendDunn:delid='||l_delinquency_id);

        l_bind_rec.key_name := 'party_id';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := l_party_cust_id;
        l_bind_tbl(1) := l_bind_rec;
        l_bind_rec.key_name := 'org_id';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := l_org_id;
        l_bind_tbl(2) := l_bind_rec;
        l_bind_rec.key_name := 'bucket_line_id';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := l_bucket_line_id;
        l_bind_tbl(3) := l_bind_rec;
        l_bind_rec.key_name := 'account_id';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := l_account_id;
        l_bind_tbl(4) := l_bind_rec;
        l_bind_rec.key_name := 'delinquency_id';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := l_delinquency_id;
        l_bind_tbl(5) := l_bind_rec;
        -- added for BILL_TO in 11.5.10
        l_bind_rec.key_name := 'customer_site_use_id';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := l_customer_site_use_id;
        l_bind_tbl(6) := l_bind_rec;

	 --Start adding for bug 9156833 gnramasa 27th Nov 09
	 l_validation_level := FND_API.G_VALID_LEVEL_FULL;

	 iex_utilities.get_dunning_resource(p_api_version => p_api_version,
			       p_init_msg_list     => FND_API.G_TRUE,
			       p_commit            => FND_API.G_FALSE,
			       p_validation_level  => l_validation_level,
			       p_level             => 'DUNNING_BILLTO',
			       p_level_id          => l_customer_site_use_id,
			       x_msg_count         => l_msg_count,
			       x_msg_data          => l_msg_data,
			       x_return_status     => l_return_status,
			       x_resource_tab      => l_resource_tab);
	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
	     x_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;

	  if l_resource_tab.count>0 then
	    l_resource_id := l_resource_tab(1).resource_id;
	  end if;
	  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_resource_id: ' || l_resource_id);
	  --End adding for bug 9156833 gnramasa 27th Nov 09
          WriteLog( ' before send_xml org_id '|| p_org_id);
        /**
         * in 11.5.11, IEX supports fulfillment and xml publisher.
         * it depends on the set up in IEX ADMIN/SETUP.
         */

        if (l_curr_dmethod = 'FFM') then

          Send_Fulfillment(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_fulfillment_bind_tbl     => l_bind_tbl
          , p_template_id              => l_template_id
          , p_method                   => l_method
          , p_party_id                 => l_party_cust_id
          , x_request_id               => l_request_id
          , x_return_status            => x_return_status
          , x_msg_count                => x_msg_count
          , x_msg_data                 => x_msg_data
          , x_contact_destination      => l_contact_destination  -- bug 3955222
          , x_contact_party_id         => l_contact_party_id  -- bug 3955222
          );

        else
          l_running_level := 'DELINQUENCY';
          l_object_code := 'IEX_DELINQUENCY';
          l_object_id := l_delinquency_id;

          Send_XML(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_resend                   => 'N'
          , p_request_id               => null
          , p_fulfillment_bind_tbl     => l_bind_tbl
          , p_template_id              => l_xdo_template_id
          , p_method                   => l_method
          , p_party_id                 => l_party_cust_id
          , p_level                    => l_running_level
          , p_source_id                => l_object_id
          , p_object_code              => l_object_code
          , p_object_id                => l_object_id
	  , p_resource_id              => l_resource_id --Added for bug 9156833 gnramasa 27th Nov 09
          , p_org_id                   => p_org_id   -- added for bug 9151851
	  , x_request_id               => l_request_id
          , x_return_status            => x_return_status
          , x_msg_count                => x_msg_count
          , x_msg_data                 => x_msg_data
          , x_contact_destination      => l_contact_destination  -- bug 3955222
          , x_contact_party_id         => l_contact_party_id  -- bug 3955222
          );
       end if;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - send status='|| x_return_status);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Sending process failed');
         GOTO end_loop;
       END IF;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id='||l_request_id);
       l_ffm_cnt := l_ffm_cnt + 1;

       /*===========================================
        * Close OPEN Dunnings for each Del
        *===========================================*/

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning');
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - runninglevel=DELINQUENCY');
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_id);
       l_del_tbl(1).delinquency_id := l_delinquency_id;

       Close_DUNNING(
           p_api_version              => p_api_version
         , p_init_msg_list            => p_init_msg_list
         , p_commit                   => p_commit
         , p_delinquencies_tbl        => l_del_tbl
         , p_running_level            => 'DELINQUENCY'
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning status='|| x_return_status);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Close Dunning');
          GOTO end_loop;
       END IF;
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EndCloseDunn');

       /*===========================================
        * Create Dunning Record
        *===========================================*/

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get CallbackDate');
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag='||l_callback_flag);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDays='||l_callback_days);

      /*===================================================
       * clchang updated 02/13/2003
       * callback_days could be null if callback_yn = 'N';
       * and if callback_yn = 'N', not get callback_date;
       *==================================================*/
       IF (l_callback_flag = 'Y') THEN
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is Y: NOTGetCallbackDate');
          Get_Callback_Date( p_init_msg_list          => p_init_msg_list
                      , p_callback_days          => l_callback_days
                      , x_callback_date          => l_callback_date
                      , x_return_status          => x_return_status
                      , x_msg_count              => x_msg_count
                      , x_msg_data               => x_msg_data);

          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetCallbackDate status='|| x_return_status);
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDate='||l_callback_date);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Not Get CallbackDate');
            GOTO end_loop;
          END IF;

       ELSE
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is N: NOTGetCallbackDate');
       END IF;


       /* get the current amount_due_remaining and currency_code */
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GET AMOUNT');

       Open C_AMOUNT(l_delinquency_id);
       Fetch C_AMOUNT into
           l_amount,
           l_curr_code;

       If ( C_AMOUNT%NOTFOUND) Then
          FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
          FND_MESSAGE.Set_Token ('INFO', 'amount', FALSE);
          FND_MSG_PUB.Add;
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - amount notfound');
       END IF;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - close C_AMOUNT');
       Close C_AMOUNT;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get amount='||l_amount);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get currcode='||l_curr_code);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning');
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_id);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_id='||l_delinquency_id);

       l_dunning_rec.delinquency_id := l_delinquency_id;
       l_dunning_rec.callback_yn := l_callback_flag;
       l_dunning_rec.callback_date := l_callback_date;
       l_dunning_rec.status := 'OPEN';
       l_dunning_rec.dunning_method:= l_method;
       if (l_curr_dmethod = 'FFM') then
         l_dunning_rec.template_id:= l_template_id;
         l_dunning_rec.ffm_request_id := l_request_id;
       else
         l_dunning_rec.xml_template_id:= l_xdo_template_id;
         l_dunning_rec.xml_request_id := l_request_id;
       end if;
       l_dunning_rec.campaign_sched_id := l_campaign_sched_id;
       l_dunning_rec.dunning_object_id := l_delinquency_id;
       l_dunning_rec.dunning_level := 'DELINQUENCY';
       l_dunning_rec.amount_due_remaining := l_amount;
       l_dunning_rec.currency_code := l_curr_code;
       l_dunning_rec.object_type := 'IEX_DELINQUENCY';
       l_dunning_rec.object_id := l_delinquency_id;
       l_dunning_rec.dunning_plan_id := p_dunning_plan_id;
       l_dunning_rec.contact_destination := l_contact_destination;  -- bug 3955222
       l_dunning_rec.contact_party_id := l_contact_party_id;  -- bug 3955222

       l_dunning_rec.org_id := p_org_id;
       WriteLog(' before creating dunning org_id ' || p_org_id);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');

       CREATE_DUNNING(
         p_api_version              => p_api_version
       , p_init_msg_list            => p_init_msg_list
       , p_commit                   => p_commit
       , p_dunning_rec              => l_dunning_rec
       , x_dunning_id               => l_dunning_id
       , x_return_status            => x_return_status
       , x_msg_count                => x_msg_count
       , x_msg_data                 => x_msg_data);

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning status='|| x_return_status);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Dunning');
         GOTO end_loop;
       END IF;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunningId='||l_dunning_id);
       l_dunn_cnt := l_dunn_cnt + 1;


       /*===========================================
        * Update Delinquency
        * Set DUNN_YN = 'N'
        *===========================================*/

         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateDel');

         nIdx := nIdx + 1;
         del_tbl(nIdx) := l_delinquency_id;


       <<end_loop>>
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_loop');
       NULL;

     END IF;

     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Close C_GET_DEL');

     Close C_Get_DEL;

     x_request_id := l_request_id;

     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========Summarty==========');
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SendFFM Cnt='||l_ffm_cnt);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunn Cnt='||l_dunn_cnt);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id='||x_request_id);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========End Summarty==========');

      --
      -- End of API body
      --

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return status='||x_return_status);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return status='||x_return_status);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );


      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||errmsg);
              ROLLBACK TO Resend_DUNNING_PVT;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception');
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||errmsg);
              ROLLBACK TO Resend_DUNNING_PVT;

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception');
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||errmsg);
              ROLLBACK TO Resend_DUNNING_PVT;

END Resend_Dunning;

Procedure Resend_Staged_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_dunning_plan_id         in number,
	    p_dunning_id              in number,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
	    p_org_id                  in number,
            x_request_id              OUT NOCOPY NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS

    CURSOR C_GET_DEL (IN_del_ID NUMBER) IS
      SELECT delinquency_ID,
             party_cust_id,
             cust_account_id,
             customer_site_use_id,
             score_value
        FROM IEX_DELINQUENCIES
       WHERE delinquency_ID = in_del_ID;
/*
    --
    CURSOR C_GET_SCORE (IN_ID NUMBER) IS
      SELECT a.score_value
        FROM IEX_SCORE_HISTORIES a
       WHERE a.score_object_ID = in_ID
         AND a.score_object_code = 'IEX_DELINQUENCY'
         AND a.creation_date = (select max(b.creation_date)
                                  from iex_score_histories b
                                 where b.score_object_id = in_id
                                   AND b.score_object_code = 'IEX_DELINQUENCY');
    --
    --
    CURSOR C_GET_TEMPLATE (l_line_id NUMBER,
                           l_score NUMBER, p_dunning_plan_id number) IS
      SELECT x.template_id,
             x.xdo_template_id,
             x.fm_method,
             upper(x.callback_flag),
             x.callback_days,
             ar.bucket_name
        FROM IEX_AG_DN_XREF x,
             ar_aging_buckets ar,
             iex_dunning_plans_vl d
       WHERE x.aging_bucket_line_ID = l_line_ID
         and x.dunning_plan_id = p_dunning_plan_id
         AND l_score between x.score_range_low and x.score_range_high
         AND x.aging_bucket_id = ar.aging_bucket_id
         and ar.aging_bucket_id = d.aging_bucket_id
         AND ar.status = 'A'
         AND x.dunning_level = 'DELINQUENCY' ;
*/
    --
    cursor c_amount (IN_ID number) is
     select ps.amount_due_remaining,
            ps.invoice_currency_code
       from ar_payment_schedules_all ps,
            --iex_delinquencies_all del
            iex_delinquencies del
      where ps.payment_schedule_id (+)= del.payment_schedule_id
        and del.delinquency_id = in_id;
    --

    l_AMOUNT                NUMBER;
    l_CURR_CODE             VARCHAR2(15);
    l_DUNNING_id            NUMBER;
    l_delinquency_id        NUMBER;
    l_party_cust_id         NUMBER;
    l_account_id            NUMBER;
    l_customer_site_use_id  NUMBER;
    l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_score                 NUMBER;
    l_bucket_line_id        NUMBER;
    l_campaign_sched_id     NUMBER;
    l_template_id           NUMBER;
    l_xdo_template_id       NUMBER;
    l_method                VARCHAR2(10);
    l_callback_flag         VARCHAR2(1);
    l_callback_days         NUMBER;
    l_callback_date         DATE;
    l_request_id            NUMBER;
    l_outcome_code          varchar2(20);
    l_api_name              CONSTANT VARCHAR2(30) := 'Resend_Staged_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);
    --
    nIdx                    NUMBER := 0;
    TYPE Del_ID_TBL_type is Table of IEX_DELINQUENCIES_ALL.DELINQUENCY_ID%TYPE
                            INDEX BY BINARY_INTEGER;
    Del_Tbl                 Del_ID_TBL_TYPE;
    l_bind_tbl              IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
    l_bind_rec              IEX_DUNNING_PVT.FULFILLMENT_BIND_REC;
    l_org_id                NUMBER ;
    --l_delid_tbl             IEX_DUNNING_PUB.DelId_NumList;
    l_del_tbl               IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE;
    l_ffm_cnt               NUMBER := 0;
    l_dunn_cnt              NUMBER := 0;
    l_bucket                VARCHAR2(100);
    i                       NUMBER := 0;
    l_running_level         VARCHAR2(25);
    l_object_Code           VARCHAR2(25);
    l_object_id             NUMBER;
    l_curr_dmethod          VARCHAR2(10);
    l_contact_destination         varchar2(240);  -- bug 3955222
    l_contact_party_id            number; -- bug 3955222

    CURSOR C_GET_DUNNING (in_dunning_id NUMBER) IS
    SELECT dunning_object_id,
          delinquency_id,
          dunning_level,
	  xml_template_id,
	  ag_dn_xref_id,
	  xml_request_id
     FROM iex_dunnings
    WHERE dunning_id = in_dunning_id;

    CURSOR C_CALLBACK_DETAILS (p_ag_dn_xref_id number) IS
      SELECT x.fm_method,
	     upper(x.callback_flag),
             x.callback_days
        FROM IEX_AG_DN_XREF x
       WHERE x.ag_dn_xref_id = p_ag_dn_xref_id;

    l_dunning_object_id       number;
    l_del_id                  number;
    l_dunning_level	      varchar2(20);
    l_ag_dn_xref_id	      number;
    l_xml_request_id	      number;

    --Start adding for bug 9156833 gnramasa 27th Nov 09
    l_validation_level		  NUMBER ;
    l_resource_tab		  iex_utilities.resource_tab_type;
    l_resource_id		  NUMBER;
    --End adding for bug 9156833 gnramasa 27th Nov 09

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Resend_Staged_Dunning_PVT;

      --Bug#4679639 schekuri 20-OCT-2005
      --Value of profile ORG_ID shouldn't be used for getting ORG_ID after MOAC implementation
      --l_org_id := fnd_profile.value('ORG_ID');
      l_org_id:= mo_global.get_current_org_id;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --dont write into FND_FILE
      --l_write := 0;

      --
      -- Api body
      --
      open C_GET_DUNNING (p_dunning_id);
      fetch C_GET_DUNNING into l_dunning_object_id, l_del_id, l_dunning_level, l_xdo_template_id, l_ag_dn_xref_id, l_xml_request_id;
      close C_GET_DUNNING;

      open C_CALLBACK_DETAILS (l_ag_dn_xref_id);
      fetch C_CALLBACK_DETAILS into l_method, l_callback_flag, l_callback_days;
      close C_CALLBACK_DETAILS;

      -- only one del record
      i := 1;

      l_delinquency_id := p_delinquencies_tbl(i).delinquency_id;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==================');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_Id);

      -- Validate Data

     /*=============================================================
      *  For each Delinquency,
      *=============================================================*/

      Open C_Get_DEL(l_delinquency_id);
      Fetch C_Get_DEL into
               l_delinquency_id,
               l_party_cust_id,
               l_account_id,
               l_customer_site_use_id,
               l_score;

      If ( C_GET_DEL%NOTFOUND) Then
           WriteLog('iexvdunb.pls:ResendDunn:No Open Del');

      else

        WriteLog('iexvdunb.pls:ResendDunn:open del='||l_delinquency_Id);

        /*===============================================================
         * IsDispute ?
         * If yes => stop (exit);
         * else continue;
         *
         * it returns values :
         * 1) it returns 'F' if no dispute exists for the delinquency
         * 2) it returns 'T' if dispute exists and is pending
         * 3) it returns 'F' if dispute exists and its staus is "COMPLETE"
         *==============================================================*/

/*
        WriteLog('iexvdunb.pls:ResendDunn:Chk IsDispute');

        IEX_DISPUTE_PVT.Is_Delinquency_Dispute(p_api_version              => p_api_version
			 														            , p_init_msg_list            => p_init_msg_list
			 														            , p_delinquency_id           => l_delinquency_id
			 														            , x_return_status            => x_return_status
			 														            , x_msg_count                => x_msg_count
			 														            , x_msg_data                 => x_msg_data);

        IF x_return_status = 'T' THEN
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Dispute exists and is pending');
           GOTO end_loop;
        elsif x_return_status = 'F' THEN
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No Dispute or status is COMPLETE');
        END IF;

        -- init msg (not from dispute api)
        FND_MSG_PUB.initialize;
*/
       /*===========================================
        * Get Score From IEX_SCORE_HISTORIES
        * If NotFound => Call API to getScore;
        *===========================================*/
--        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Score='|| l_score);
       /*===========================================
        * get Aging_Bucket_Line_Id for each Del
        *===========================================*/
/*
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetAgingBucketLineId');
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_id);

          AGING_DEL(p_api_version              => p_api_version
			              , p_init_msg_list            => p_init_msg_list
			              , p_commit                   => p_commit
			              , p_delinquency_id           => l_delinquency_id
			              , p_dunning_plan_id          => p_dunning_plan_id
			              , p_bucket                   => l_bucket
			              , x_return_status            => x_return_status
			              , x_msg_count                => x_msg_count
			              , x_msg_data                 => x_msg_data
			              , x_aging_bucket_line_id     => l_bucket_line_id);

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - AgingDel status='||x_return_status);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         FND_MESSAGE.Set_Name('IEX', 'IEX_NO_AGINGBUCKETLINE');
         FND_MSG_PUB.Add;
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Get AgingBucketLineId');
         GOTO end_loop;
       END IF;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - lineid='||l_bucket_line_id);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EndAgingDel');
*/
       /*==========================================
       * Get Template_ID From iex_ag_dn_xref
       *===========================================*/
/*
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GET Template');

       Open C_Get_TEMPLATE(l_bucket_line_ID, l_score, p_dunning_plan_id);
       Fetch C_Get_TEMPLATE into
             l_template_id,
             l_xdo_template_id,
             l_method,
             l_callback_flag,
             l_callback_days,
             l_bucket;

       If ( C_GET_TEMPLATE%NOTFOUND) Then
           FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
           FND_MSG_PUB.Add;
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - template notfound');
           Close C_Get_TEMPLATE;
           GOTO end_loop;
       END IF;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - close C_GET_TEMPLATE');
       Close C_Get_TEMPLATE;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get template_id='||l_template_id);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get xdo_template_id='||l_xdo_template_id);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get bucket='||l_bucket);

*/
      /*===========================================
       * Check template
       *  in 11.5.11, IEX supports fulfillment and xml publisher.
       *  if the current setup for delivery id FFM,
       *  then template_id is necessary;
       *  if XML, xdo_template_id is necessary;
       *===========================================*/

       l_curr_dmethod := IEX_SEND_XML_PVT.getCurrDeliveryMethod;
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - curr d_method='||l_curr_dmethod);
       if ( (l_curr_dmethod is null or l_curr_dmethod = '') or
            (l_curr_dmethod = 'FFM' and l_template_id is null)  or
            (l_curr_dmethod = 'XML' and l_xdo_template_id is null ) ) then
            FND_MESSAGE.Set_Name('IEX', 'IEX_NO_TEMPLATE');
            FND_MSG_PUB.Add;
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Template notfound');
            x_return_status := FND_API.G_RET_STS_ERROR;
            GOTO end_loop;
       end if;

      /*===========================================
       * Check profile before send dunning
       *===========================================*/

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - begin check customer profile');
        -- ctlee - check the hz_customer_profiles.dunning_letter
       if ( iex_utilities.DunningProfileCheck (
               p_party_id => l_party_cust_id
               , p_cust_account_id => l_account_id
               , p_site_use_id => l_customer_site_use_id
               , p_delinquency_id => l_delinquency_id     ) = 'N'
          ) then
            FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_PROFILE_NO');
            FND_MSG_PUB.Add;
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Send dunning in customer profile set to no ');
            GOTO end_loop;
       end if;

/*
       -- ctlee - check the hz_customer_profiles_amt min_dunning_invoice_amount and min_dunning_amount
       if ( iex_utilities.DunningMinAmountCheck (
                p_cust_account_id => l_account_id
                , p_site_use_id => l_customer_site_use_id)  = 'N'
          ) then
            FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_DUNNING_AMOUNT_MIN');
            FND_MSG_PUB.Add;
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Required min Dunning amount in customer profile ');
            GOTO end_loop;
       end if;

       WriteLog('iexvdunb:ResendDunn: end check customer profile');
*/

       /*===========================================
        * Send Letter through Fulfillment
        *===========================================*/

        WriteLog('iexvdunb.pls:ResendDunn:Send_Ffm');
        WriteLog('iexvdunb.pls:ResendDunn:orgid='||l_org_id);
        WriteLog('iexvdunb.pls:ResendDunn:partyid='||l_party_cust_id);
        WriteLog('iexvdunb.pls:ResendDunn:acctid='||l_account_id);
        --WriteLog('iexvdunb.pls:ResendDunn:lineid='||l_bucket_line_id);
        WriteLog('iexvdunb.pls:ResendDunn:delid='||l_delinquency_id);

        l_bind_rec.key_name := 'party_id';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := l_party_cust_id;
        l_bind_tbl(1) := l_bind_rec;
        l_bind_rec.key_name := 'org_id';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := l_org_id;
        l_bind_tbl(2) := l_bind_rec;
        /*
	l_bind_rec.key_name := 'bucket_line_id';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := l_bucket_line_id;
        l_bind_tbl(3) := l_bind_rec;
	*/
        l_bind_rec.key_name := 'account_id';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := l_account_id;
        l_bind_tbl(3) := l_bind_rec;
        l_bind_rec.key_name := 'delinquency_id';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := l_delinquency_id;
        l_bind_tbl(4) := l_bind_rec;
        -- added for BILL_TO in 11.5.10
        l_bind_rec.key_name := 'customer_site_use_id';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := l_customer_site_use_id;
        l_bind_tbl(5) := l_bind_rec;
	l_bind_rec.key_name := 'DUNNING_ID';
        l_bind_rec.key_type := 'NUMBER';
        l_bind_rec.key_value := p_dunning_id;
        l_bind_tbl(6) := l_bind_rec;

	--Start adding for bug 9156833 gnramasa 27th Nov 09
	 l_validation_level := FND_API.G_VALID_LEVEL_FULL;

	 iex_utilities.get_dunning_resource(p_api_version => p_api_version,
			       p_init_msg_list     => FND_API.G_TRUE,
			       p_commit            => FND_API.G_FALSE,
			       p_validation_level  => l_validation_level,
			       p_level             => 'DUNNING_BILLTO',
			       p_level_id          => l_customer_site_use_id,
			       x_msg_count         => l_msg_count,
			       x_msg_data          => l_msg_data,
			       x_return_status     => l_return_status,
			       x_resource_tab      => l_resource_tab);
	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
	     x_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;

	  if l_resource_tab.count>0 then
	    l_resource_id := l_resource_tab(1).resource_id;
	  end if;
	  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_resource_id: ' || l_resource_id);
	  --End adding for bug 9156833 gnramasa 27th Nov 09

	WriteLog( G_PKG_NAME || ' ' || l_api_name || ' before send_xml org_id '|| p_org_id);

        /**
         * in 11.5.11, IEX supports fulfillment and xml publisher.
         * it depends on the set up in IEX ADMIN/SETUP.
         */

        if (l_curr_dmethod = 'FFM') then

          Send_Fulfillment(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_fulfillment_bind_tbl     => l_bind_tbl
          , p_template_id              => l_template_id
          , p_method                   => l_method
          , p_party_id                 => l_party_cust_id
          , x_request_id               => l_request_id
          , x_return_status            => x_return_status
          , x_msg_count                => x_msg_count
          , x_msg_data                 => x_msg_data
          , x_contact_destination      => l_contact_destination  -- bug 3955222
          , x_contact_party_id         => l_contact_party_id  -- bug 3955222
          );

        else
          l_running_level := 'DELINQUENCY';
          l_object_code := 'IEX_DELINQUENCY';
          l_object_id := l_delinquency_id;

          Send_XML(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_resend                   => 'Y'
          , p_request_id               => l_xml_request_id
          , p_fulfillment_bind_tbl     => l_bind_tbl
          , p_template_id              => l_xdo_template_id
          , p_method                   => l_method
          , p_party_id                 => l_party_cust_id
          , p_level                    => l_running_level
          , p_source_id                => l_object_id
          , p_object_code              => l_object_code
          , p_object_id                => l_object_id
	  , p_resource_id              => l_resource_id --Added for bug 9156833 gnramasa 27th Nov 09
	  , p_org_id                   => p_org_id
          , x_request_id               => l_request_id
          , x_return_status            => x_return_status
          , x_msg_count                => x_msg_count
          , x_msg_data                 => x_msg_data
          , x_contact_destination      => l_contact_destination  -- bug 3955222
          , x_contact_party_id         => l_contact_party_id  -- bug 3955222
          );
       end if;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - send status='|| x_return_status);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Sending process failed');
         GOTO end_loop;
       END IF;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id='||l_request_id);
       l_ffm_cnt := l_ffm_cnt + 1;

       /*===========================================
        * Close OPEN Dunnings for each Del
        *===========================================*/

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning');
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - runninglevel=DELINQUENCY');
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_id);
       l_del_tbl(1).delinquency_id := l_delinquency_id;

       Close_Staged_Dunning(
           p_api_version              => p_api_version
         , p_init_msg_list            => p_init_msg_list
         , p_commit                   => p_commit
         , p_delinquencies_tbl        => l_del_tbl
	 , p_ag_dn_xref_id	     => l_ag_dn_xref_id
         , p_running_level            => 'DELINQUENCY'
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning status='|| x_return_status);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Close Dunning');
          GOTO end_loop;
       END IF;
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EndCloseDunn');

       /*===========================================
        * Create Dunning Record
        *===========================================*/

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get CallbackDate');
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag='||l_callback_flag);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDays='||l_callback_days);

      /*===================================================
       * clchang updated 02/13/2003
       * callback_days could be null if callback_yn = 'N';
       * and if callback_yn = 'N', not get callback_date;
       *==================================================*/
       IF (l_callback_flag = 'Y') THEN
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is Y: NOTGetCallbackDate');
          Get_Callback_Date( p_init_msg_list          => p_init_msg_list
                      , p_callback_days          => l_callback_days
                      , x_callback_date          => l_callback_date
                      , x_return_status          => x_return_status
                      , x_msg_count              => x_msg_count
                      , x_msg_data               => x_msg_data);

          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetCallbackDate status='|| x_return_status);
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackDate='||l_callback_date);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Not Get CallbackDate');
            GOTO end_loop;
          END IF;

       ELSE
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CallbackFlag is N: NOTGetCallbackDate');
       END IF;


       /* get the current amount_due_remaining and currency_code */
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GET AMOUNT');

       Open C_AMOUNT(l_delinquency_id);
       Fetch C_AMOUNT into
           l_amount,
           l_curr_code;

       If ( C_AMOUNT%NOTFOUND) Then
          FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
          FND_MESSAGE.Set_Token ('INFO', 'amount', FALSE);
          FND_MSG_PUB.Add;
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - amount notfound');
       END IF;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - close C_AMOUNT');
       Close C_AMOUNT;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get amount='||l_amount);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get currcode='||l_curr_code);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning');
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_id);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_id='||l_delinquency_id);

       l_dunning_rec.delinquency_id := l_delinquency_id;
       l_dunning_rec.callback_yn := l_callback_flag;
       l_dunning_rec.callback_date := l_callback_date;
       l_dunning_rec.status := 'OPEN';
       l_dunning_rec.dunning_method:= l_method;
       if (l_curr_dmethod = 'FFM') then
         l_dunning_rec.template_id:= l_template_id;
         l_dunning_rec.ffm_request_id := l_request_id;
       else
         l_dunning_rec.xml_template_id:= l_xdo_template_id;
         l_dunning_rec.xml_request_id := l_request_id;
       end if;
       l_dunning_rec.campaign_sched_id := l_campaign_sched_id;
       l_dunning_rec.dunning_object_id := l_delinquency_id;
       l_dunning_rec.dunning_level := 'DELINQUENCY';
       l_dunning_rec.amount_due_remaining := l_amount;
       l_dunning_rec.currency_code := l_curr_code;
       l_dunning_rec.object_type := 'IEX_DELINQUENCY';
       l_dunning_rec.object_id := l_delinquency_id;
       l_dunning_rec.dunning_plan_id := p_dunning_plan_id;
       l_dunning_rec.contact_destination := l_contact_destination;  -- bug 3955222
       l_dunning_rec.contact_party_id := l_contact_party_id;  -- bug 3955222
       l_dunning_rec.ag_dn_xref_id	:= l_ag_dn_xref_id;
       l_dunning_rec.org_id := p_org_id;
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' before creating dunning org_id ' || p_org_id);

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');

       CREATE_DUNNING(
         p_api_version              => p_api_version
       , p_init_msg_list            => p_init_msg_list
       , p_commit                   => p_commit
       , p_dunning_rec              => l_dunning_rec
       , x_dunning_id               => l_dunning_id
       , x_return_status            => x_return_status
       , x_msg_count                => x_msg_count
       , x_msg_data                 => x_msg_data);

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning status='|| x_return_status);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Dunning');
         GOTO end_loop;
       END IF;

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunningId='||l_dunning_id);
       l_dunn_cnt := l_dunn_cnt + 1;


       /*===========================================
        * Update Delinquency
        * Set DUNN_YN = 'N'
        *===========================================*/

         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateDel');

         nIdx := nIdx + 1;
         del_tbl(nIdx) := l_delinquency_id;


       <<end_loop>>
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_loop');
       NULL;

     END IF;

     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Close C_GET_DEL');

     Close C_Get_DEL;

     x_request_id := l_request_id;

     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========Summarty==========');
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SendFFM Cnt='||l_ffm_cnt);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunn Cnt='||l_dunn_cnt);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - request_id='||x_request_id);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========End Summarty==========');

      --
      -- End of API body
      --

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return status='||x_return_status);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return status='||x_return_status);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );


      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||errmsg);
              ROLLBACK TO Resend_Staged_Dunning_PVT;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception');
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||errmsg);
              ROLLBACK TO Resend_Staged_Dunning_PVT;

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception');
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||errmsg);
              ROLLBACK TO Resend_Staged_Dunning_PVT;

END Resend_Staged_Dunning;

/* clchang added (for 11.5.9)
   no iex aging in 11.5.9;
   in send_dunning, aging_bucket_line_id is not from iex_delinquencies;
   we need to get by ourselves;

   updated for 11.5.11  - 11/22/04
   dunning support aging in 11.5.11 at all levels.
   added 2 more parameters: p_object_code, and p_object_id.
   so this procedure can age not just del level, but all levels.
 */
Procedure AGING_DEL(
            p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_delinquency_id          IN NUMBER,
            p_dunning_plan_id         in number,
            p_bucket                  IN VARCHAR2,
            p_object_code             IN VARCHAR2,
            p_object_id               IN NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_AGING_Bucket_line_ID    OUT NOCOPY NUMBER)

IS
-- begin bug 4914799, add max function and check del status
-- begin bug 9393778 gnramasa 19th Feb 10, add trunc function
    CURSOR C_GET_PARTY_DAYS (in_party_id number) IS
      --SELECT max(sysdate - ar.due_date) days
      SELECT max(trunc(sysdate) - trunc(ar.due_date)) days
        FROM iex_delinquencies del,
             ar_payment_schedules ar
       WHERE del.party_cust_id = in_party_id
         AND del.payment_schedule_id = ar.payment_schedule_id
         and del.status in ('DELINQUENT', 'PREDELINQUENT');
    --
    CURSOR C_GET_ACCT_DAYS (in_acct_id number) IS
      --SELECT max(sysdate - ar.due_date) days
      SELECT max(trunc(sysdate) - trunc(ar.due_date)) days
        FROM iex_delinquencies del,
             ar_payment_schedules ar
       WHERE del.cust_account_id = in_acct_id
         AND del.payment_schedule_id = ar.payment_schedule_id
         and del.status in ('DELINQUENT', 'PREDELINQUENT');
    --
    CURSOR C_GET_SITE_DAYS (in_site_id number) IS
      --SELECT max(sysdate - ar.due_date) days
      SELECT max(trunc(sysdate) - trunc(ar.due_date)) days
        FROM iex_delinquencies del,
             ar_payment_schedules ar
       WHERE del.customer_site_use_id = in_site_id
         AND del.payment_schedule_id = ar.payment_schedule_id
         and del.status in ('DELINQUENT', 'PREDELINQUENT');
    --
    CURSOR C_GET_DAYS (IN_DEL_ID NUMBER) IS
      --SELECT (sysdate - ar.due_date) days
      SELECT (trunc(sysdate) - trunc(ar.due_date)) days
        FROM iex_delinquencies del,
             ar_payment_schedules ar
       WHERE delinquency_ID = in_DEL_ID
         AND del.payment_schedule_id = ar.payment_schedule_id
         and del.status in ('DELINQUENT', 'PREDELINQUENT');
-- end bug 4914799, add max function and check del status
    --

    CURSOR C_GET_BUCKET_LINE (IN_DAYS NUMBER, p_dunning_plan_id  number) IS
       SELECT l.aging_bucket_line_id
         FROM ar_aging_bucket_lines l,
              ar_aging_buckets b,
              iex_dunning_plans_vl d
         WHERE d.dunning_plan_id = p_dunning_plan_id
            and  d.aging_bucket_id = b.aging_bucket_id
            and  b.aging_bucket_id = l.aging_bucket_id
            --AND round(IN_DAYS) between l.days_start and l.days_to
	    AND IN_DAYS between l.days_start and l.days_to
            and exists (select 1 from iex_ag_dn_xref x
                         where d.dunning_plan_id = x.dunning_plan_id
                         and d.aging_bucket_id = x.aging_bucket_id
                         and x.aging_bucket_line_id = l.aging_bucket_line_id);
    -- end bug 9393778 gnramasa 19th Feb 10, add trunc function
    --
l_api_name          CONSTANT VARCHAR2(30) := 'AGING_DEL';
l_api_version       NUMBER := 1.0;
l_commit            VARCHAR2(5) ;
--
l_days              NUMBER;
l_bucket_line_id    NUMBER;
--
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(1000);
l_return_status     VARCHAR2(1000);
--
nIdx                NUMBER := 0;

errmsg                        VARCHAR2(32767);

BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT AGING_DEL_PVT;

     l_commit  := FND_API.G_TRUE;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_object_code='||p_object_code);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_object_id='||p_object_id);

    IF ( p_object_Code = 'PARTY') then
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Party Level');
      Open C_Get_PARTY_DAYS(p_object_id);
      Fetch C_Get_PARTY_DAYS into l_days;
      If ( C_GET_PARTY_DAYS%NOTFOUND) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - PaymentSchedId NotFound');
            FND_MESSAGE.Set_Name('IEX', 'IEX_NO_PAYMENTSCHEDULE');
            FND_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_PARTY_DAYS;
            GOTO end_get_line;
      end if;
      --
    ELSIF ( p_object_Code = 'IEX_ACCOUNT') then
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Acct Level');
      Open C_Get_ACCT_DAYS(p_object_id);
      Fetch C_Get_ACCT_DAYS into l_days;
      If ( C_GET_ACCT_DAYS%NOTFOUND) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - PaymentSchedId NotFound');
            FND_MESSAGE.Set_Name('IEX', 'IEX_NO_PAYMENTSCHEDULE');
            FND_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_ACCT_DAYS;
            GOTO end_get_line;
      end if;
      --
    ELSIF ( p_object_Code = 'IEX_BILLTO') then
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - BillTO Level');
      Open C_Get_SITE_DAYS(p_object_id);
      Fetch C_Get_SITE_DAYS into l_days;
      If ( C_GET_SITE_DAYS%NOTFOUND) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - PaymentSchedId NotFound');
            FND_MESSAGE.Set_Name('IEX', 'IEX_NO_PAYMENTSCHEDULE');
            FND_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_SITE_DAYS;
            GOTO end_get_line;
      end if;
      --
    ELSE
      -- delinquency level

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||p_delinquency_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bucket='||p_bucket);

      Open C_Get_DAYS(p_delinquency_id);
      Fetch C_Get_DAYS into l_days;
      If ( C_GET_DAYS%NOTFOUND) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - PaymentSchedId NotFound');
            FND_MESSAGE.Set_Name('IEX', 'IEX_NO_PAYMENTSCHEDULE');
            FND_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_DAYS;
            GOTO end_get_line;
      end if;
      --
    END IF;
      --
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - days='||l_days);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_days = ' || l_days);

           Open C_Get_BUCKET_LINE(l_days, p_dunning_plan_id);
           Fetch C_Get_BUCKET_LINE into l_bucket_line_id;
           If ( C_GET_BUCKET_LINE%NOTFOUND) Then
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - BucketLine NotFound');
              FND_MESSAGE.Set_Name('IEX', 'IEX_NO_BUCKET_LINE');
              FND_MSG_PUB.Add;
              l_return_status := FND_API.G_RET_STS_ERROR;
              Close C_Get_BUCKET_LINE;
              GOTO end_get_line;
           else
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bucketlineid='||l_bucket_line_id);
           end if;
      --

    <<end_get_line>>
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_get_line');
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - status=' || l_return_status);

    x_return_status := l_return_status;
    if (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_bucket_line_id := 0;
    END IF;
    x_aging_bucket_line_id := l_bucket_line_id;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return_status:'||x_return_status);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - lineId:'||x_aging_bucket_line_id);

    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );

    EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||errmsg);
              ROLLBACK TO AGING_DEL_PVT;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||errmsg);
              ROLLBACK TO AGING_DEL_PVT;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||errmsg);
              ROLLBACK TO AGING_DEL_PVT;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

END AGING_DEL;

/* begin raverma 10222001
   changed spec to work with delinquencies, receipts, promises, disputes,
  added:
  p_key_name (should be like 'delinquency_id')
  p_key_id   (should be like 10001)
 */
Procedure Call_FFM(
            p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_key_name                IN VARCHAR2,
            p_key_id                  IN NUMBER,
            p_template_id             IN NUMBER,
            p_method                  IN VARCHAR2,
            p_party_id                IN NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_REQUEST_ID              OUT NOCOPY NUMBER)

IS
    CURSOR C_GET_CONTENTS (IN_TEMPLATE_ID NUMBER) IS
      SELECT  --content_NUMBER,
             upper(substr(content_name,instr(content_name,'.')+1,length(content_name)-instr(content_name,'.'))) DocType,
             mes_doc_ID
        FROM JTF_FM_TEMPLATE_CONTENTS
       WHERE template_ID = in_template_ID
         AND nvl(upper(f_deletedflag),'0') <>'D'
       --bug 3090268
       --ORDER BY content_number;
       ORDER BY creation_date;
    --
    CURSOR C_GET_ORG_EMAIL (IN_PARTY_ID NUMBER) IS
      SELECT email_address
        FROM HZ_PARTIES
       WHERE party_ID = in_party_ID;
    --
    CURSOR C_GET_CONTACT_EMAIL (IN_PARTY_ID NUMBER) IS
      SELECT email_address
        FROM HZ_CONTACT_POINTS
       WHERE owner_table_ID = in_party_ID
         AND Contact_point_type = 'EMAIL'
         AND primary_flag = 'Y';
    --
    CURSOR C_GET_CONTENT_TYPE (IN_MES_DOC_ID NUMBER) IS
      SELECT mes.query_id
        FROM jtf_FM_query_mes mes,
             jtf_FM_query q
       WHERE mes.MES_DOC_ID = in_mes_doc_id
         AND mes.query_id = q.query_id;
    --
l_api_name          CONSTANT VARCHAR2(30) := 'Call_FFM';
l_api_version       NUMBER := 1.0;
l_commit            VARCHAR2(5) ;
--
l_Content_tbl       IEX_SEND_FFM_PVT.CONTENT_TBL_TYPE;
l_Content_rec       IEX_SEND_FFM_PVT.CONTENT_REC_TYPE;
l_content_id        NUMBER;
l_doc_type          VARCHAR2(50);
l_bind_var          JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_bind_var_type     JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_bind_val          JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
--
l_content_nm        VARCHAR2(100);
l_party_id          NUMBER;
l_user_id           NUMBER;
l_server_id         NUMBER;
l_request_id        NUMBER;
l_subject           VARCHAR2(100);
--
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(1000);
l_return_status     VARCHAR2(1000);
--
l_content_xml1      VARCHAR2(1000);
l_content_xml       VARCHAR2(10000);
--
l_email             VARCHAR2(2000);
l_printer       VARCHAR2(2000);
l_request_type      VARCHAR2(10);
l_query_id          NUMBER;
G_MISS_NUM          CONSTANT NUMBER := 9.99E125;
nIdx                NUMBER := 0;

errmsg                        VARCHAR2(32767);

BEGIN

    SAVEPOINT CALL_FFM_PVT;

    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - start');
    if (p_template_id is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No TEMPLATE_ID');
        FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
        FND_MESSAGE.Set_Token ('INFO', 'No Template_ID');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;
    if (p_party_id is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No PARTY_ID');
        FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
        FND_MESSAGE.Set_Token ('INFO', 'No Party_Id');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;
    if (p_method is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No METHOD');
        FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
        FND_MESSAGE.Set_Token ('INFO', 'No Method');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - TEMPLATE_ID='||p_template_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - PARTY_ID='||p_party_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - METHOD='||p_method);

   /*=======================================
    * get the primary contact email first;
    * if not found, get org email address;
    =======================================*/
    -- clchang added 06/13/2002 for bug 2344867 (FM support EMAIL and PRINT)
    if (upper(p_method) = 'EMAIL') then
    --
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get Email');


      Open C_Get_CONTACT_EMAIL(p_party_id);
      Fetch C_Get_CONTACT_EMAIL into l_email;
      If ( C_GET_CONTACT_EMAIL%NOTFOUND) Then
         Open C_Get_ORG_EMAIL(p_party_id);
         Fetch C_Get_ORG_EMAIL into l_email;
         If ( C_GET_ORG_EMAIL%NOTFOUND) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Customer NotFound');
            FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
            FND_MESSAGE.Set_Token ('INFO', 'Customer NotFound');
            FND_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_ORG_EMAIL;
            Close C_Get_CONTACT_EMAIL;
            GOTO end_call_ffm;
         end if;
         --
         If ( l_email is null ) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No Email');
            FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
            FND_MESSAGE.Set_Token ('INFO', 'No Email_Address');
            FND_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_ORG_EMAIL;
            Close C_Get_CONTACT_EMAIL;
            GOTO end_call_ffm;
         end if;
         --
         Close C_Get_ORG_EMAIL;
      end if;

      If ( l_email is null ) Then
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No Email');
         FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
         FND_MESSAGE.Set_Token ('INFO', 'No Email_Address');
         FND_MSG_PUB.Add;
         l_return_status := FND_API.G_RET_STS_ERROR;
         Close C_Get_CONTACT_EMAIL;
         GOTO end_call_ffm;
      END if;

      Close C_Get_CONTACT_EMAIL;

    elsif (upper(p_method) = 'PRINTER' or upper(p_method)='PRINT' ) then
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get Printer');
      l_printer := NVL(fnd_profile.value('IEX_FFM_PRINTER'), '');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Printer:'||l_printer);
      if (l_printer = '' or l_printer is null) then
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - No Printer');
         END IF;
         FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
         FND_MESSAGE.Set_Token ('INFO', 'No Printer');
         FND_MSG_PUB.Add;
         l_return_status := FND_API.G_RET_STS_ERROR;
         GOTO end_call_ffm;
      end if;
    END IF; -- end of p_method=EMAIL


    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - Get Contents');
    END IF;

    Open C_Get_CONTENTS(p_template_id);
    LOOP
         Fetch C_Get_CONTENTS into l_doc_type, l_content_id;

         If ( C_GET_CONTENTS%NOTFOUND ) Then
              if (nIdx = 0) then
                  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No Contents');
                  FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
                  FND_MESSAGE.Set_Token ('INFO', 'No Contents for selected template ');
                  FND_MSG_PUB.Add;
                  l_return_status := FND_API.G_RET_STS_ERROR;
              end if;
              exit;
         else
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Content_Id='||l_content_id);

              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - Get Content Type');
              END IF;

              nIdx := nIdx + 1;

              Open C_Get_CONTENT_TYPE(l_content_id);
              Fetch C_Get_CONTENT_TYPE into l_query_id;
              If ( C_GET_CONTENT_TYPE%NOTFOUND) Then
                  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Content Type:DATA');
                  l_request_type := 'DATA';
              else   -- l_query_id is not null
                  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Content Type:QUERY');


                  l_request_type := 'QUERY';
              end if;
              Close C_Get_CONTENT_TYPE;

              l_content_rec.content_id :=  l_content_id;
              l_content_rec.request_type := l_request_type; -- 'DATA' or 'QUERY'
              l_content_rec.media_type := p_method;         --'EMAIL', 'FAX'
              l_content_rec.document_type := l_doc_type; --'HTML';  -- 'WORD';
              l_content_rec.user_note := ' ';
              l_content_rec.email  := l_email;
              l_content_rec.printer  := l_printer;
              l_content_rec.file_path := NULL;
              l_content_rec.fax  := '9999999999';
              ------------------------------------

              -- raverma 10222001 change this to work for any NUMBER id passed
              l_bind_var(nIdx)      := p_key_name;
              l_bind_var_type(nIdx) := 'NUMBER'; -- 'VARCHAR2'
              l_bind_val(nIdx)      := p_key_id;
              l_content_tbl(nIdx) := l_content_rec;

         end if;

    END LOOP;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Close C_GET_CONTENTS');
    Close C_Get_CONTENTS;
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - TotalContents='||nIdx);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CurrUser='||FND_GLOBAL.USER_ID);
    l_content_nm := nIdx; -- Num of Contents you want send out NOCOPY
    l_user_id    := FND_GLOBAL.USER_ID; --1001247; -- IEXTEST
    l_server_id  := NULL;  -- Using Default Server
    l_subject    := NVL(FND_PROFILE.value('IEX_FULFILL_SUBJECT'), '');

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - subject=;||l_subject');
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CAll SEND_FFM');

    IEX_SEND_FFM_PVT.Send_FFM(p_api_version_number  => l_api_version,
                              p_init_msg_list       => p_init_msg_list,
                              p_commit              => l_commit,
                              p_content_nm          => l_content_nm,
                              p_user_id             => l_user_id,
                              p_server_id           => l_server_id,
                              p_party_id            => p_party_id,
                              p_subject             => l_subject,
                              p_content_tbl         => l_content_tbl,
                              p_bind_var            => l_bind_var,
                              p_bind_val            => l_bind_val,
                              p_bind_var_type       => l_bind_var_type,
                              x_request_id          => l_request_id,
                              x_return_status       => l_return_status,
                              x_msg_count           => l_msg_count,
                              x_msg_data            => l_msg_data);

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - after send_ffm:'||l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
	   x_msg_count := l_msg_count;
	   x_msg_data := l_msg_data;
        --handle error_msg in main procedure (send_dunning)
    END IF;

    <<end_call_ffm>>
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_call_ffm');
    x_request_id := l_request_id;
    x_return_status := l_return_status;
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return_status:'||x_return_status);

    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );

    EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              ROLLBACK TO CALL_FFM_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception');
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              ROLLBACK TO CALL_FFM_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN OTHERS THEN
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception');
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              ROLLBACK TO CALL_FFM_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

END Call_FFM;



Procedure Get_Callback_Date(
            p_init_msg_list           IN VARCHAR2 ,
            p_callback_days              IN   NUMBER,
	    p_correspondence_date	 IN DATE default null,
            x_callback_date              OUT NOCOPY  DATE,
            X_Return_Status              OUT NOCOPY  VARCHAR2,
            X_Msg_Count                  OUT NOCOPY  NUMBER,
            X_Msg_Data                   OUT NOCOPY  VARCHAR2)
IS
   l_result         DATE;
   l_result2        NUMBER;
   v_cursor         NUMBER;
   v_create_string  varchar2(1000);
   v_numrows        NUMBER;
   l_callback_days  NUMBER ;
   errmsg           varchar2(32767);
	 l_api_name       varchar2(30);

   -- fixed for sql bind var 05/07/2003
   vstr1            varchar2(100) ;
   vstr2            varchar2(100)  ;
   vstr3            varchar2(100) ;

   vstr4            varchar2(100) ;
   vstr5            varchar2(100) ;
   l_correspondence_date	date;

BEGIN

   l_callback_days   := p_callback_days;
   l_correspondence_date := nvl(p_correspondence_date, sysdate);

   l_api_name     := 'get_callback_date';
   ----vstr1          := 'SELECT SYSDATE + ';
   vstr1          := 'SELECT  to_date('' ';
   ----vstr2          := ' , TO_NUMBER(TO_CHAR(SYSDATE + ' ;
   vstr2          := ' , TO_NUMBER(TO_CHAR(to_date('' ' ;
   vstr3          := ' ,' || '''D''' || ')) FROM DUAL ';

   ----vstr4          := 'SELECT SYSDATE + ' ;
   vstr4          := 'SELECT to_date('' ' ;
   vstr5          := ' FROM DUAL ';

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');


  v_cursor := DBMS_SQL.OPEN_CURSOR;

  -- clchang updated for sql bind var 05/07/2003
  ----v_create_string := vstr1 || l_callback_days || vstr2 || l_callback_days ||
  ----                   vstr3;

  v_create_string := vstr1 || l_correspondence_date || ''',''DD-MON-RR'') + ' || l_callback_days || vstr2
                    || l_correspondence_date || ''',''DD-MON-RR'') + ' || l_callback_days || vstr3;
 /*
  v_create_string := 'SELECT SYSDATE + ' || l_callback_days ||
                     ', TO_NUMBER(TO_CHAR(SYSDATE + ' || l_callback_days || ',' || '''D''' || ')) FROM DUAL ';
 */
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - string='||v_create_string);

  DBMS_SQL.parse(v_cursor, v_create_string, 1);
  DBMS_SQL.DEFINE_COLUMN(v_cursor, 1, l_result);
  DBMS_SQL.DEFINE_COLUMN(v_cursor, 2, l_result2);

  v_numrows := DBMS_SQL.EXECUTE(v_cursor);
  v_numrows := DBMS_SQL.FETCH_ROWS(v_cursor);
  DBMS_SQL.COLUMN_VALUE(v_cursor, 1, l_result);
  DBMS_SQL.COLUMN_VALUE(v_cursor, 2, l_result2);
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_result='||l_result);
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_result2='||l_result2);

  DBMS_SQL.CLOSE_CURSOR(v_cursor);

  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Close Cursor');

  -- If Weekend => Monday
  -- 6 => Firday
  -- 1 => Sunday

  if (l_result2 = 7) then
      l_callback_days := l_callback_days + 2;
  elsif (l_result2 = 1) then
      l_callback_days := l_callback_days + 1;
  end if;

  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - callbackdays='||l_callback_days);

  v_cursor := DBMS_SQL.OPEN_CURSOR;
  -- clchang updated for sql bind var 05/07/2003
  ----v_create_string := vstr4 || l_callback_days || vstr5;
  v_create_string := vstr4 || l_correspondence_date || ''',''DD-MON-RR'') + ' || l_callback_days || vstr5;
  --v_create_string := 'SELECT SYSDATE + ' || l_callback_days || ' FROM DUAL ';

  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - createstring='||v_create_string);

  DBMS_SQL.parse(v_cursor, v_create_string, 1);
  DBMS_SQL.DEFINE_COLUMN(v_cursor, 1, l_result);

  v_numrows := DBMS_SQL.EXECUTE(v_cursor);
  v_numrows := DBMS_SQL.FETCH_ROWS(v_cursor);
  DBMS_SQL.COLUMN_VALUE(v_cursor, 1, l_result);
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - result='||l_result);

  DBMS_SQL.CLOSE_CURSOR(v_cursor);
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Close Cursor2');

  x_callback_date := l_result;
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - callback_date='||x_callback_date);

  -- Standard call to get message count and IF count is 1, get message info.

 FND_MSG_PUB.Count_And_Get
 (  p_count          =>   x_msg_count,
    p_data           =>   x_msg_data );

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - exception');
    errmsg := SQLERRM;
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errmsg='||errmsg);

END GET_CALLBACK_DATE;


/*
|| Overview:  This procedure is an extension of Call_FFM. Call_FFM only allows one bind variable/value
||            This will allow you to pass in unlimited bind variables in a name/value pair structure
||
|| Parameter: p_FULFILLMENT_BIND_TBL = name/value pairs for bind variables
||            p_template_id   = fulfillment template
||            p_method = Fulfillment Type, currently only 'EMAIL' is supported
||            p_party_id  = pk to hz_parties
||
|| Source Tables:  JTF_FM_TEMPLATE_CONTENTS, HZ_PARTIES, HZ_CONTACT_POINTS,
||                 jtf_FM_query_mes
||                 jtf_FM_query
||
|| Target Tables:
||
|| Creation date:       03/07/02 11:36:AM
||
|| Major Modifications: when               who                   what
||                      03/07/02 11:36:AM  raverma               created
||                      08/06/02           pjgomes               added parameter p_email
||                      08/19/02 02:00:PM  pjgomes               Changed default value of p_email to NULL
||   07/10/03 clchang    p_email could be email/fax
||   05/06/03 clchang    added 4 parameters p_object_code,p_object_id,
||                                          p_level,p_source_id
||                       if p_object_code is null, work as before.
||                       if null, create dunning after sending ffm;
||                       p_level could be CUSTOMER,ACCOUNT,BILL_TO,DELINQUENCY.
*/
Procedure Send_Fulfillment(p_api_version             IN NUMBER := 1.0,
                           p_init_msg_list           IN VARCHAR2 ,
                           p_commit                  IN VARCHAR2 ,
                           p_FULFILLMENT_BIND_TBL    IN IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL,
                           p_template_id             IN NUMBER,
                           p_method                  IN VARCHAR2,
                           p_party_id                IN NUMBER,
                           p_user_id                 IN NUMBER ,
                           p_email                   IN VARCHAR2 ,
                           p_level                   IN VARCHAR2 ,
                           p_source_id               IN NUMBER,
                           p_object_code             IN VARCHAR2 ,
                           p_object_id               IN NUMBER,
                           x_return_status           OUT NOCOPY VARCHAR2,
                           x_msg_count               OUT NOCOPY NUMBER,
                           x_msg_data                OUT NOCOPY VARCHAR2,
                           x_REQUEST_ID              OUT NOCOPY NUMBER,
                           x_contact_destination     OUT NOCOPY varchar2,  -- bug 3955222
                           x_contact_party_id        OUT NOCOPY NUMBER)  -- bug 3955222
IS
    CURSOR C_GET_CONTENTS (IN_TEMPLATE_ID NUMBER) IS
      SELECT  --content_NUMBER,
         upper(substr(content_name,instr(content_name,'.')+1,length(content_name)-instr(content_name,'.'))) DocType,
             mes_doc_ID
        FROM JTF_FM_TEMPLATE_CONTENTS
       WHERE template_ID = in_template_ID
         AND nvl(upper(f_deletedflag),'0') <>'D'
       --bug 3090268
       --ORDER BY content_number;
       ORDER BY creation_date;
    --
    CURSOR C_GET_ORG_EMAIL (IN_PARTY_ID NUMBER) IS
      SELECT email_address
        FROM HZ_PARTIES
       WHERE party_ID = in_party_ID;
    --
    CURSOR C_GET_CONTACT_EMAIL (IN_PARTY_ID NUMBER) IS
      SELECT email_address
        FROM HZ_CONTACT_POINTS
       WHERE owner_table_ID = in_party_ID
         AND Contact_point_type = 'EMAIL'
         AND primary_flag = 'Y';
    --
    CURSOR C_GET_CONTENT_TYPE (IN_MES_DOC_ID NUMBER) IS
      SELECT mes.query_id
        FROM jtf_FM_query_mes mes,
             jtf_FM_query q
       WHERE mes.MES_DOC_ID = in_mes_doc_id
         AND mes.query_id = q.query_id;
    --
l_api_name          CONSTANT VARCHAR2(30) := 'Send_Fulfillment';
l_api_version       NUMBER := 1.0;
l_commit            VARCHAR2(5) ;
--
l_Content_tbl       IEX_SEND_FFM_PVT.CONTENT_TBL_TYPE;
l_Content_rec       IEX_SEND_FFM_PVT.CONTENT_REC_TYPE;
l_content_id        NUMBER;
l_doc_type          VARCHAR2(50);
l_bind_var          JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_bind_var_type     JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_bind_val          JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_bind_cnt_tbl      NUMBER;
--
l_content_nm    VARCHAR2(100);
l_party_id      NUMBER;
l_user_id       NUMBER;
l_server_id     NUMBER;
l_request_id    NUMBER;
l_subject       VARCHAR2(100);
--
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(1000);
l_return_status VARCHAR2(1000);
--
l_content_xml1  VARCHAR2(1000);
l_content_xml   VARCHAR2(10000);
--
l_email         VARCHAR2(2000);
l_printer       VARCHAR2(2000);
l_fax           VARCHAR2(2000);
l_contact       VARCHAR2(2000);
l_request_type  VARCHAR2(10);
l_query_id      NUMBER;
l_keep_content  NUMBER;

--G_MISS_NUM     CONSTANT    NUMBER       := 9.99E125;

nIdx           NUMBER := 0;
nOrgIdx        NUMBER := 0;
errmsg         VARCHAR2(30000);

nOrgFound      NUMBER := 0;
l_org_id       NUMBER ;


 l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
 l_dunning_id            NUMBER;

 l_contact_party_id    number;  --#bug 3955222

BEGIN

     SAVEPOINT Send_Fulfillment_PVT;

    l_commit := p_commit;

    --Bug#4679639 schekuri 20-OCT-2005
    --Value of profile ORG_ID shouldn't be used for getting ORG_ID after MOAC implementation
    l_org_id:= mo_global.get_current_org_id;

    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SEND_FFM:');
    if (p_template_id is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No TEMPLATE_ID');
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_TEMPLATE');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;
    if (p_party_id is null AND (p_email IS NULL OR p_email = FND_API.G_MISS_CHAR)) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No PARTY_ID or EMAIL');
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_PARTY');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;
    if (p_method is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No METHOD');
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_METHOD');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;

    --clchang updated 07/18/2003 subject cannot be hardcoded
    -- bug 3058620
    l_subject    := NVL(FND_PROFILE.value('IEX_FULFILL_SUBJECT'), '');
    if (l_subject is null or l_subject = '') then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No FFM Subject',0);
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_SUBJECT');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - TEMPLATE_ID='||p_template_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - PARTY_ID='||p_party_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EMAIL='||p_email);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - METHOD='||p_method);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - SUBJECT='||l_subject);

   /*=======================================
    * get the primary contact email first;
    * if not found, get org email address;
    =======================================*/

    if(p_email IS NULL OR p_email = FND_API.G_MISS_CHAR) THEN

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Call GetContactInfo');

       GetContactInfo(
                   p_api_version              => p_api_version
                 , p_init_msg_list            => p_init_msg_list
                 , p_commit                   => p_commit
                 , p_method                   => p_method
                 , p_party_id                 => p_party_id
                 , p_dunning_level            => p_level
                 , p_cust_site_use_id         => null
                 , x_return_status            => l_return_status
                 , x_msg_count                => l_msg_count
                 , x_msg_data                 => l_msg_data
                 , x_contact                  => l_contact
                 , x_contact_party_id         => l_contact_party_id  -- bug 3955222
       );

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  status='||l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         l_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := l_msg_count;
         x_msg_data := l_msg_data;
         --handle error_msg in main procedure
         GOTO end_call_ffm;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ContactInfo:'||l_contact);

    END IF;

    -- user could pass fax/email by p_email parameter,
    -- then dont call GetContactInfo
    --
    IF (p_method = 'EMAIL') THEN
      if(p_email IS NULL OR p_email = FND_API.G_MISS_CHAR) THEN
        l_email := l_contact;
      else
        l_email := p_email;
      end if;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EMAIL:'||l_email);
        l_printer := 'DEVPRT';
        l_fax := '99999999';
    --
    ELSIF (p_method = 'PRINTER' or p_method = 'PRINT') THEN
      -- p_email could be fax or email
      if(p_email IS NULL OR p_email = FND_API.G_MISS_CHAR) THEN
        l_printer := l_contact;
      else
        l_printer := p_email;
      end if;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - PRINTER:'||l_printer);
        l_email := '';
        l_fax := '99999999';
    --
    ELSIF (p_method = 'FAX') THEN
      -- clchang 07/09/03 updated
      -- p_email could be fax or email
      if(p_email IS NULL OR p_email = FND_API.G_MISS_CHAR) THEN
        l_fax := l_contact;
      else
        l_fax := p_email;
      end if;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - FAX:'||l_fax);
        --l_fax := l_contact;
        l_printer := 'DEVPRT';
        l_email := '';
    END IF;



    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - template_id=' || p_template_id);

    Open C_Get_CONTENTS(p_template_id);
    LOOP
         Fetch C_Get_CONTENTS into l_doc_type, l_content_id;

         If ( C_GET_CONTENTS%NOTFOUND ) Then
              if (nIdx = 0) then
                  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Contents NotFound');
                  FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_FFMCONTENT');
                  FND_MSG_PUB.Add;
                  l_return_status := FND_API.G_RET_STS_ERROR;
              end if;
              GOTO end_call_ffm;
              --exit;
         else
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Content_id='||l_content_id);
              nIdx := nIdx + 1;
              l_keep_content := 1;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - nIdx='||nIdx);

              Open C_Get_CONTENT_TYPE(l_content_id);
              Fetch C_Get_CONTENT_TYPE into l_query_id;
              If ( C_GET_CONTENT_TYPE%NOTFOUND) Then
                  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ContentType=DATA');
                  l_request_type := 'DATA';

              else   -- l_query_id is not null
                  WriteLog('iexvdunb.pls:SEND_FFM:ContentType=QUERY');
                 /*=================================================================
                  * the following part is special for IEXFmAcctDelQuery and IEXFmAcctPreDelQuery;
                  * if IEXFmAcctDelQuery (query_id 2002),
                  *    if no rows selected based on the bind data,
                  *    skip IEXFmAcctDel.htm content;
                  * if IEXFmAcctPreDelQuery (query_id 2003),
                  *    if no rows selected based on the bind data,
                  *    skip IEXFmPart2.htm and IEXFmAcctPreDel.htm contents;
                  * the reason we handle it is because
                  *    FFM engine set status FAILURE if no rows selected for one content.
                  *    then our template will be FAILURE
                  *    just because one content has no table data;
                  *===========================================================*/

                  --check skip or not only if our sample doc and sample queries
                  --if (l_query_id = 2002 or l_query_id = 2003) then
                  if ( (l_content_id = 2002 and l_query_id = 2002 ) or
                       (l_content_id = 2004 and l_query_id = 2003 ))
                  then
                      CHK_QUERY_DATA( l_query_id, p_FULFILLMENT_BIND_TBL, l_keep_content);
                      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_keep_content='||l_keep_content);
                      if (l_keep_content = 0 ) then
                          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - skip this content');
                          Close C_Get_CONTENT_TYPE;
                          GOTO end_content;
                      end if;
                  end if;
                  -- end of checking

                  l_request_type := 'QUERY';
              end if;
              Close C_Get_CONTENT_TYPE;

              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CLOSE ContentType');

              l_content_rec.content_id    := l_content_id;
              l_content_rec.request_type  := l_request_type; -- 'DATA' or 'QUERY'
              l_content_rec.media_type    := p_method;         --'EMAIL', 'FAX'
              l_content_rec.document_type := l_doc_type; --'HTML';  -- 'WORD';
              l_content_rec.user_note     := ' ';
              l_content_rec.email         := l_email;
              l_content_rec.printer       := l_printer;
              l_content_rec.file_path     := NULL;
              l_content_rec.fax           := l_fax;
              ------------------------------------

              -- this is dumb because i am assuming all binds for 1 content, not mutliple contents
              l_bind_cnt_tbl := p_FULFILLMENT_BIND_TBL.count;
              WriteLog('iexvdunb.pls:SEND_FFM:bind_tbl_cnt'||l_bind_cnt_tbl);
              nOrgFound := 0;
              for j in 1..l_bind_cnt_tbl
              loop
                l_bind_var(j)      := p_FULFILLMENT_BIND_TBL(j).Key_name;
                l_bind_var_type(j) := p_FULFILLMENT_BIND_TBL(j).Key_Type;
                l_bind_val(j)      := p_FULFILLMENT_BIND_TBL(j).Key_Value;

                -- clchang updated 07/08/2003 for bug 3026860
                if (upper(l_bind_var(j)) = 'ORG_ID') then
                    nOrgFound := 1;
                end if;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bind_var:found org_id? '||nOrgFound);

                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bind_var='||l_bind_var(j));
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bind_var_type='||l_bind_var_type(j));
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bind_val='||l_bind_val(j));
              end loop;

              -- clchang updated 07/08/2003 for bug 3026860
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - after loop of bind_var:found org_id? '||nOrgFound);
              if (nOrgFound = 0) then
                nOrgIdx := l_bind_cnt_tbl + 1;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bind_var:add org_id at index '||nOrgIdx);
                l_bind_var(nOrgIdx)      := 'org_id';
                l_bind_var_type(nOrgIdx) := 'NUMBER';
                l_bind_val(nOrgIdx)      := l_org_id;
              end if;

              l_content_tbl(nIdx) := l_content_rec;

              <<end_content>>
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_content');
              if (l_content_id = 2002 and l_keep_content = 0 and l_query_id = 2002 ) then
                  nIdx := nIdx - 1;
                  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - skip this content');
              elsif (l_content_id = 2004 and l_keep_content = 0 and l_query_id = 2003 ) then
                  nIdx := nIdx - 2;
                  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - skip this content and IEXFmPart2.htm');
              end if;
         end if;

    END LOOP;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - total contents='||nIdx);

    Close C_Get_CONTENTS;

    l_content_nm := nIdx; -- Num of Contents you want send out NOCOPY
    if  (p_user_id is null) then
         l_user_id    := FND_GLOBAL.USER_ID; --1001247; -- IEXTEST
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_user_id is null');
    else
         l_user_id := p_user_id;
    end if;
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - curruser='||l_user_id);

    l_server_id  := NULL;  -- Using Default Server

    --
    -- If any errors(like template no contents), dont call send_ffm;
    --
    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Call SEND_FFM');
        IEX_SEND_FFM_PVT.Send_FFM(
                              p_api_version_number => l_api_version,
                              p_init_msg_list   => p_init_msg_list,
                              p_commit          => l_commit,
                              p_content_nm      => l_content_nm,
                              p_user_id         => l_user_id,
                              p_server_id       => l_server_id,
                              p_party_id        => p_party_id,
                              p_subject         => l_subject,
                              p_content_tbl     => l_content_tbl,
                              p_bind_var        => l_bind_var,
                              p_bind_val        => l_bind_val,
                              p_bind_var_type   => l_bind_var_type,
                              x_request_id      => l_request_id,
                              x_return_status   => l_return_status,
                              x_msg_count       => l_msg_count,
                              x_msg_data        => l_msg_data);

       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - After SEND_FFM:'||l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         l_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := l_msg_count;
         x_msg_data := l_msg_data;
         --handle error_msg in main procedure (send_dunning)
         GOTO end_call_ffm;
       END IF;

    END IF;
    --
    -- updated by clchang 05/06/04 for bug 3088968
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - level='||p_level);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - source_id='||p_source_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object='||p_object_code);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_id='||p_object_id);
    IF( p_object_code is null ) THEN
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - no object');
        x_contact_destination := l_contact; -- bug 3955222
        x_contact_party_id := l_contact_party_id; -- bug 3955222
    ELSIF( p_object_code = 'PARTY' or p_object_code = 'IEX_ACCOUNT' or
           p_object_code = 'IEX_BILLTO' or
           p_object_code = 'IEX_DELINQUENCY' or
           p_object_code = 'IEX_STRATEGY') THEN
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunning rec=> dont create rec');
        x_contact_destination := l_contact; -- bug 3955222
        x_contact_party_id := l_contact_party_id; -- bug 3955222
    ELSE
        l_dunning_rec.dunning_level := p_level;
        l_dunning_rec.dunning_object_id := p_source_id;
        l_dunning_rec.callback_yn := 'N';
        l_dunning_rec.status := 'OPEN';
        l_dunning_rec.dunning_method:= p_method;
        l_dunning_rec.template_id:= p_template_id;
        l_dunning_rec.ffm_request_id := l_request_id;
        l_dunning_rec.object_type := p_object_code;
        l_dunning_rec.object_id := p_object_id;
        l_dunning_rec.contact_destination := l_contact;   -- bug 3955222
        l_dunning_rec.contact_party_id := l_contact_party_id;   -- bug 3955222

        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');
        CREATE_DUNNING(
                   p_api_version              => p_api_version
                 , p_init_msg_list            => p_init_msg_list
                 , p_commit                   => p_commit
                 , p_dunning_rec              => l_dunning_rec
                 , x_dunning_id               => l_dunning_id
                 , x_return_status            => x_return_status
                 , x_msg_count                => x_msg_count
                 , x_msg_data                 => x_msg_data);

        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning status='|| x_return_status);
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunning_id='||l_dunning_id);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Dunning');
           l_return_status := FND_API.G_RET_STS_ERROR;
           x_msg_count := l_msg_count;
           x_msg_data := l_msg_data;
        END IF;
    END IF; -- end of p_object

    <<end_call_ffm>>
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_call_ffm');
    x_request_id := l_request_id;
    x_return_status := l_return_status;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return_status:'||x_return_status);

    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );

    EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
               errmsg := SQLERRM;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
               ROLLBACK TO SEND_FULFILLMENT_PVT;
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data
               );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception');
               errmsg := SQLERRM;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
               ROLLBACK TO SEND_FULFILLMENT_PVT;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data
               );

          WHEN OTHERS THEN
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception');
               errmsg := SQLERRM;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
               ROLLBACK TO SEND_FULFILLMENT_PVT;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data
               );

END Send_Fulfillment;


/*
|| Overview:  This procedure is new for 11.5.11. To replace Fulfillment
||            with XML Publisher.
||            similar as Send_Fulfillment.
||
||   11/08/04 clchang    added for 11.5.11.
||
*/
Procedure Send_XML(p_api_version             IN NUMBER := 1.0,
                   p_init_msg_list           IN VARCHAR2 ,
                   p_commit                  IN VARCHAR2 ,
                   p_resend                  IN VARCHAR2 ,
                   p_request_id              IN NUMBER,
                   p_FULFILLMENT_BIND_TBL    IN IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL,
                   p_template_id             IN NUMBER,
                   p_method                  IN VARCHAR2,
                   p_party_id                IN NUMBER,
                   p_user_id                 IN NUMBER ,
                   p_email                   IN VARCHAR2 ,
                   p_level                   IN VARCHAR2 ,
                   p_source_id               IN NUMBER,
                   p_object_code             IN VARCHAR2 ,
                   p_object_id               IN NUMBER,
                   p_resource_id             IN NUMBER,
		   p_dunning_mode            IN VARCHAR2 DEFAULT NULL,  -- added by gnramasa for bug 8489610 14-May-09
		   p_parent_request_id       IN NUMBER DEFAULT NULL,
                   p_org_id                  IN NUMBER DEFAULT NULL, -- added for bug 9151851
		   p_correspondence_date     IN DATE DEFAULT NULL,
		   x_return_status           OUT NOCOPY VARCHAR2,
                   x_msg_count               OUT NOCOPY NUMBER,
                   x_msg_data                OUT NOCOPY VARCHAR2,
                   x_REQUEST_ID              OUT NOCOPY NUMBER,
                   x_contact_destination     OUT NOCOPY varchar2,  -- bug 3955222
                   x_contact_party_id        OUT NOCOPY NUMBER)  -- bug 3955222

IS
    -- new cursor to get tmp query for xml publisher design 11.5.11
    CURSOR C_GET_QUERY (IN_TEMPLATE_ID NUMBER, IN_LEVEL VARCHAR2) IS
      SELECT q.query_id
        FROM iex_query_temp_xref xref,
             iex_xml_queries q
       WHERE xref.template_id = IN_TEMPLATE_ID
         AND xref.query_id = q.query_id
         AND q.query_level = IN_LEVEL;
    --
    -- new cursor to get tmp query for xml publisher design 11.5.11
    CURSOR C_GET_RS (IN_USER_ID NUMBER) IS
      SELECT j.resource_id
        FROM jtf_rs_resource_extns j
       WHERE j.user_id = in_user_id;
    --
    CURSOR C_GET_ORG_EMAIL (IN_PARTY_ID NUMBER) IS
      SELECT email_address
        FROM HZ_PARTIES
       WHERE party_ID = in_party_ID;
    --
    CURSOR C_GET_CONTACT_EMAIL (IN_PARTY_ID NUMBER) IS
      SELECT email_address
        FROM HZ_CONTACT_POINTS
       WHERE owner_table_ID = in_party_ID
         AND Contact_point_type = 'EMAIL'
         AND primary_flag = 'Y';

    cursor c_get_contact_point(p_contact_point_id number, p_contact_type varchar2) is
    select decode(p_contact_type , 'EMAIL', c.email_address,
                                   'PHONE', c.phone_country_code || c.phone_area_code || c.phone_number,
                                     'FAX', c.phone_country_code || c.phone_area_code || c.phone_number, null)
     from hz_contact_points c
    where contact_point_id = p_contact_point_id;

    cursor c_get_resend_data(p_request_id number) is
        select QUERY_TEMP_ID, DESTINATION
        from IEX_XML_REQUEST_HISTORIES
        where XML_REQUEST_ID = p_request_id;

   --Bug5233002. Fix by LKKUMAR on 31-May-2006. Start.
   CURSOR C_GET_RES_USER_ID  IS
      SELECT j.user_id
        FROM jtf_rs_resource_extns j
       WHERE j.resource_id = p_resource_id;
   l_resource_user_id NUMBER;
   --Bug5233002. Fix by LKKUMAR on 31-May-2006. End.

    l_fulfillment_bind_tbl  IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
    --
		l_api_name          CONSTANT VARCHAR2(30) := 'Send_XML';
		l_api_version       NUMBER := 1.0;
		l_commit            VARCHAR2(5) ;
		--
		--
		l_party_id      NUMBER;
		l_user_id       NUMBER;
		l_server_id     NUMBER;
		l_request_id    NUMBER;
		l_subject       VARCHAR2(100);
		--
		l_msg_count     NUMBER;
		l_msg_data      VARCHAR2(1000);
		l_return_status VARCHAR2(10);
		--
		l_content_xml1  VARCHAR2(1000);
		l_content_xml   VARCHAR2(10000);
		--
		l_email         VARCHAR2(2000);
		l_printer       VARCHAR2(2000);
		l_fax           VARCHAR2(2000);
		l_contact       VARCHAR2(2000);
		l_request_type  VARCHAR2(10);
		l_query_id      NUMBER;
		l_keep_content  NUMBER;

		nIdx           NUMBER := 0;
		nOrgIdx        NUMBER := 0;
		errmsg         VARCHAR2(30000);
		nOrgFound      NUMBER := 0;
		l_org_id       NUMBER ;
		l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
		l_dunning_id            NUMBER;

		l_level        VARCHAR2(20);
		l_temp_level   VARCHAR2(20);
		l_dest         VARCHAR2(2000);
		l_resource_id  NUMBER;
		l_resend       VARCHAR2(5);
		l_contact_party_id number;   --#bug 39555222
    l_customer_site_use_id  number;
    l_contact_point_id      number;
    l_info                  varchar2(500);
    l_location_id           number;
    l_cust_account_id       number;
    l_delinquency_id        number;
    Type refCur             is Ref Cursor;
    sql_cur                 refCur;
    vSQL                    VARCHAR2(2000);
    l_contact_id            number;

    l_msg_count1            NUMBER;
    l_msg_data1             VARCHAR2(1000);
    l_return_status1        VARCHAR2(10);
    l_msg                   varchar2(32000);
    l_app                   varchar2(50);
    l_msg_name              varchar2(30);
    l_count                 number;
    k                       number;
    -- start for bug 8916424 PNAVEENK
    b_user_id              NUMBER;
    l_defined              boolean;

    cursor c_user_level_profile(p_resource_id number) is
    select user_id
    from jtf_rs_resource_extns
    where resource_id = p_resource_id;
    -- end for bug 8916424

    l_dunning_type	varchar2(20);

BEGIN

    SAVEPOINT Send_XML_PVT;
    WriteLog('----------' || l_api_name || '----------');
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Input parameters:');
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - LEVEL = '|| p_level);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - RESEND = '|| p_resend);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - TEMPLATE_ID = '|| p_template_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - PARTY_ID = '|| p_party_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EMAIL = ' ||p_email);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - METHOD = ' ||p_method);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - source_id ='||p_source_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object ='||p_object_code);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - object_id ='||p_object_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bind values count = ' || p_fulfillment_bind_tbl.count);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' org_id = ' || p_org_id);
    l_commit := p_commit;

    --Bug#4679639 schekuri 20-OCT-2005
    --Value of profile ORG_ID shouldn't be used for getting ORG_ID after MOAC implementation
    --l_org_id        := fnd_profile.value('ORG_ID');
    l_org_id:= mo_global.get_current_org_id;

    -- clchang added 11/08/04 for 11.5.11
    l_level := p_level;
    l_resource_id := p_resource_id;
    l_resend      := p_resend;
    IF (l_level is null) then
        l_level := 'CUSTOMER';
    END IF;
    l_resend := p_resend;
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - level=' || l_level);
    IF (l_resend is null) then
        l_resend := 'N';
    END IF;
    -- end clchang added 11/08/04 for 11.5.11

    FND_MSG_PUB.initialize;

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    if (p_object_code is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No OBJECT_ID',0);
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_OBJECT');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;

    if (p_template_id is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No TEMPLATE_ID',0);
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_TEMPLATE');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;

    if (p_party_id is null AND (p_email IS NULL OR p_email = FND_API.G_MISS_CHAR)) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No PARTY_ID or EMAIL',0);
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_PARTY');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;

    if (p_method is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No METHOD',0);
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_METHOD');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;

    --clchang updated 07/18/2003 subject cannot be hardcoded
    -- bug 3058620
    -- start for bug 8916424 PNAVEENK

       open c_user_level_profile(l_resource_id);
       fetch c_user_level_profile into b_user_id;
       close c_user_level_profile;

       fnd_profile.get_specific(
                       NAME_Z => 'IEX_FULFILL_SUBJECT',
                       USER_ID_Z   => b_user_id,
                       RESPONSIBILITY_ID_Z=>NULL,
                       APPLICATION_ID_Z =>NULL,
                       VAL_Z   => l_subject,
                       DEFINED_Z  => l_defined,
                       ORG_ID_Z=>NULL,
                       SERVER_ID_Z=>NULL);
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' User level Fulfillment Subject Profile value' || l_subject);

       if l_subject is null then
                l_subject := NVL(FND_PROFILE.value('IEX_FULFILL_SUBJECT'), '');
       end if;


    -- end for bug 8916424

    if (l_subject is null or l_subject = '') then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No XML Subject');
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_SUBJECT');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;

    if  (p_user_id is null) then
         l_user_id    := FND_GLOBAL.USER_ID;
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_user_id is null');
    else
         l_user_id := p_user_id;
    end if;
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_user_id = '||l_user_id);

    -- chk resource_id
    if (l_resource_id is null) then
      Open C_Get_RS(l_user_id);
      Fetch C_Get_RS into l_resource_id;
      Close C_Get_RS;
    end if;
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - resource_id = ' || l_resource_id);

    if (l_resource_id is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No Resource for user '||l_user_id);
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_RESOURCE');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_call_ffm;
    end if;
    l_fulfillment_bind_tbl := p_fulfillment_bind_tbl;

    -- for resend=Y look for dunning_id and assign it to PARENT_DUNNING_ID
    if l_resend = 'Y' then
        for k in 1..l_fulfillment_bind_tbl.count loop
            if upper(l_fulfillment_bind_tbl(k).key_name) = 'DUNNING_ID' then
                l_dunning_rec.PARENT_DUNNING_ID := l_fulfillment_bind_tbl(k).key_value;
		exit;
            end if;
        end loop;
    end if;
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - PARENT_DUNNING_ID = ' || l_dunning_rec.PARENT_DUNNING_ID);

    if p_request_id is not null then
	select nvl(plan.dunning_type,'DAYS_OVERDUE')
	into l_dunning_type
	from IEX_DUNNING_PLANS_B plan, iex_dunnings dunn
	where dunn.xml_request_id = p_request_id
	and plan.dunning_plan_id = dunn.dunning_plan_id;
    end if;

    if l_resend = 'Y' and p_request_id is not null then

        Open c_get_resend_data(p_request_id);
        Fetch c_get_resend_data into l_query_id, l_dest;
        Close c_get_resend_data;

        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_query_id = ' || l_query_id);
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dest = ' || l_dest);

        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Call SEND_COPY');
        WriteLog(' before send_copy org_id ' || p_org_id);
        BEGIN
            IEX_SEND_XML_PVT.Send_COPY(p_api_version_number => l_api_version
                                  ,p_init_msg_list   => FND_API.G_FALSE
                                  ,p_commit          => FND_API.G_TRUE
                                  ,p_resend          => l_resend
                                  ,p_request_id      => p_request_id
                                  ,p_user_id         => l_user_id
                                  ,p_party_id        => p_party_id
                                  ,p_subject         => l_subject
                                  ,p_template_id     => p_template_id
                                  ,p_resource_id     => l_resource_id
                                  ,p_query_id        => l_query_id
                                  ,p_method          => p_method
                                  ,p_dest            => l_dest
                                  ,p_bind_tbl        => l_fulfillment_bind_tbl
                                  ,p_level           => l_level
                                  ,p_source_id       => p_source_id
                                  ,p_object_type     => p_object_code
                                  ,p_object_id       => p_object_id
				  ,p_dunning_mode    => p_dunning_mode  -- added by gnramasa for bug 8489610 14-May-09
				  ,p_parent_request_id => p_parent_request_id  -- added by gnramasa for bug 8489610 14-May-09
                                  ,p_org_id          => p_org_id -- added for bug 9151851
				  ,x_request_id      => l_request_id
                                  ,x_return_status   => l_return_status
                                  ,x_msg_count       => l_msg_count
                                  ,x_msg_data        => l_msg_data);

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - After SEND_COPY:'||l_return_status);

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS or l_request_id is null THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;
           END IF;

        EXCEPTION
            WHEN OTHERS THEN
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' throws exception');
                l_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_DELIVERY');
                FND_MSG_PUB.Add;
        END;

    else    -- either resending after error or sending for the first time

        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Calling GET_DEFAULT_DUN_DATA...');

        GET_DEFAULT_DUN_DATA(p_api_version => 1.0,
                           p_init_msg_list => FND_API.G_TRUE,
                           p_commit => FND_API.G_FALSE,
                           p_level => l_level,
                           p_source_id => p_source_id,
                           p_send_method => p_method,
                           p_resend => l_resend,
                           p_object_code => p_object_code,
                           p_object_id => p_object_id,
                           p_fulfillment_bind_tbl => l_fulfillment_bind_tbl,
                           x_return_status => l_return_status,
                           x_msg_count => l_msg_count,
                           x_msg_data => l_msg_data);

        WriteLog('---------- continue ' || l_api_name || '----------');
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ': l_return_status: ' || l_return_status);
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ': l_msg_count: ' || l_msg_count);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
            GOTO end_call_ffm;
        end if;

        --reviewing default dunning data
        for k in 1..l_fulfillment_bind_tbl.count loop
            if l_fulfillment_bind_tbl(k).key_name  = 'CONTACT_POINT_ID' then
                l_contact_point_id := l_fulfillment_bind_tbl(k).key_value;
            elsif l_fulfillment_bind_tbl(k).key_name  = 'LOCATION_ID' then
                l_location_id := l_fulfillment_bind_tbl(k).key_value;
            end if;
        end loop;

        -- checking for location
        IF l_location_id is null then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ': No location found');
            FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_ADDRESS');
            FND_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
            GOTO end_call_ffm;
        end if;

        -- setting destination
        IF (p_method = 'PRINTER' or p_method = 'PRINT') THEN


           if(p_email IS NULL OR p_email = FND_API.G_MISS_CHAR) THEN
           --Bug5233002. Fix by LKKUMAR on 31-May-2006. Start.
           OPEN  C_GET_RES_USER_ID;
				   FETCH C_GET_RES_USER_ID into l_resource_user_id;
				   CLOSE C_GET_RES_USER_ID;
           l_printer := NVL(fnd_profile.value_specific(NAME => 'IEX_PRT_IPP_PRINTER_NAME',USER_ID => l_resource_user_id),Null);
            --Bug5233002. Fix by LKKUMAR on 31-May-2006. End.
	   IF (l_printer is null) then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ': Setting printer from profile');
            l_printer := NVL(fnd_profile.value('IEX_PRT_IPP_PRINTER_NAME'), '');
	   END IF;

               IF (l_printer = '' or l_printer is null)  THEN
                   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No Printer',0);
                   FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_PRINTER');
                   FND_MSG_PUB.Add;
                   l_return_status := FND_API.G_RET_STS_ERROR;
                   GOTO end_call_ffm;
                END IF;

            else
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ': Setting printer as passed');
                l_printer := p_email;
            end if;

            l_dest := l_printer;
            l_email := '';
            l_fax := '';
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ': Will use printer: ' || l_dest);

        ELSE -- method is not PRINTER

            if(p_email IS NULL OR p_email = FND_API.G_MISS_CHAR) THEN

                if l_contact_point_id is null then
                   if p_method = 'EMAIL' then
                       WriteLog(G_PKG_NAME || ' ' || l_api_name || ': No email found');
                       FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_EMAIL');
                       FND_MSG_PUB.Add;
                   ELSIF p_method = 'FAX' THEN
                       WriteLog(G_PKG_NAME || ' ' || l_api_name || ': No fax found');
                       FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_FAX');
                       FND_MSG_PUB.Add;
                   end if;

                   l_return_status := FND_API.G_RET_STS_ERROR;
                   GOTO end_call_ffm;
                end if;

                WriteLog(G_PKG_NAME || ' ' || l_api_name || ': Setting destination from defaulting data');
                open c_get_contact_point(l_contact_point_id, p_method);
                fetch c_get_contact_point into l_contact;
                close c_get_contact_point;

                l_dest := l_contact;
            else
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ': Setting destination as passed');
                l_dest := p_email;
            end if;

            l_printer := '';
            l_fax := '';

            if p_method = 'EMAIL' then
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ': Will use email: ' || l_dest);
            ELSIF p_method = 'FAX' THEN
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ': Will use fax: ' || l_dest);
            end if;
        END IF;
        -- for the following object,
        -- create dunning with ACCOUNT level, but xml template is CUSTOMER level;
        --
        l_temp_level := l_level;
        IF( p_object_code = 'IEX_REVERSAL' or
          p_object_code = 'IEX_ADJUSTMENT' or
          p_object_code = 'IEX_PROMISE' or
          p_object_code = 'IEX_PAYMENT' or
          p_object_code = 'IEX_CNSLD' or
          p_object_code = 'IEX_INVOICES' or
          p_object_code = 'IEX_DISPUTE' ) then
            l_temp_level := 'CUSTOMER';
        end if;

        -- get query_id
        Open C_Get_QUERY(p_template_id, l_temp_level);
        LOOP
         Fetch C_Get_QUERY into l_query_id;
         If ( C_GET_QUERY%NOTFOUND ) Then
              if (nIdx = 0) then
                  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Query NotFound');
                  FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_QUERY');
                  FND_MSG_PUB.Add;
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  GOTO end_call_ffm;
              end if;
              exit;
         else
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - query_id='||l_query_id);
              nIdx := nIdx + 1;
         end if;
        END LOOP;
        --------------------------------------------

        l_server_id  := NULL;  -- Using Default Server
        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Call SEND_COPY');
            WriteLog( ' before send_copy org_id ' || p_org_id);
            BEGIN
                IEX_SEND_XML_PVT.Send_COPY(p_api_version_number => l_api_version
                                      ,p_init_msg_list   => FND_API.G_FALSE
                                      ,p_commit          => FND_API.G_TRUE
                                      ,p_resend          => l_resend
                                      ,p_request_id      => p_request_id
                                      ,p_user_id         => l_user_id
                                      ,p_party_id        => p_party_id
                                      ,p_subject         => l_subject
                                      ,p_template_id     => p_template_id
                                      ,p_resource_id     => l_resource_id
                                      ,p_query_id        => l_query_id
                                      ,p_method          => p_method
                                      ,p_dest            => l_dest
                                      ,p_bind_tbl        => l_fulfillment_bind_tbl
                                      ,p_level           => l_level
                                      ,p_source_id       => p_source_id
                                      ,p_object_type     => p_object_code
                                      ,p_object_id       => p_object_id
				      ,p_dunning_mode    => p_dunning_mode  -- added by gnramasa for bug 8489610 14-May-09
				      ,p_parent_request_id => p_parent_request_id  -- added by gnramasa for bug 8489610 14-May-09
                                      ,p_org_id          => p_org_id  -- added for bug 9151851
				      ,x_request_id      => l_request_id
                                      ,x_return_status   => l_return_status
                                      ,x_msg_count       => l_msg_count
                                      ,x_msg_data        => l_msg_data);

                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - After SEND_COPY:'||l_return_status);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS or l_request_id is null THEN
                 l_return_status := FND_API.G_RET_STS_ERROR;
                 x_msg_count := l_msg_count;
                 x_msg_data := l_msg_data;
               END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' throws exception');
                    l_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_DELIVERY');
                    FND_MSG_PUB.Add;
            END;

        END IF;

    end if;

    <<end_call_ffm>>

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_return_status='||l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        l_msg := FND_MSG_PUB.Get(p_msg_index => 1, p_encoded => 'T');
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  l_msg: ' || l_msg);
        FND_MESSAGE.PARSE_ENCODED(l_msg, l_app, l_msg_name);
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  Error name: ' || l_msg_name);

        l_dunning_rec.DELIVERY_STATUS := l_msg_name;

    end if;

    if l_resend = 'N' then

        IF(p_object_code = 'PARTY' or
           p_object_code = 'IEX_ACCOUNT' or
           p_object_code = 'IEX_BILLTO' or
           p_object_code = 'IEX_DELINQUENCY' or
           p_object_code = 'IEX_STRATEGY') THEN

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' -  dunning rec=> dont create rec');

            if l_dunning_rec.DELIVERY_STATUS is not null then

                for i in 1..l_fulfillment_bind_tbl.count loop
                    if l_fulfillment_bind_tbl(i).key_name = 'DUNNING_ID' then
                        l_dunning_rec.DUNNING_ID := to_number(l_fulfillment_bind_tbl(i).KEY_VALUE);
                        exit;
                    end if;
                end loop;

                if l_dunning_rec.DUNNING_ID is not null then
                    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateRow');

                    IEX_DUNNING_PVT.Update_DUNNING(
                           p_api_version              => 1.0
                         , p_init_msg_list            => FND_API.G_FALSE
                         , p_commit                   => FND_API.G_TRUE
                         , p_dunning_rec              => l_dunning_rec
                         , x_return_status            => l_return_status1
                         , x_msg_count                => l_msg_count1
                         , x_msg_data                 => l_msg_data1);

                    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateDunning status='|| l_return_status1);
                end if;

            end if;

        ELSE  -- always create dunning record

            --l_dunning_rec.dunning_level := p_level;
            l_dunning_rec.dunning_level := l_level;
	    --Added for bug 9547105 gnramasa 20th Apr 2010
	    if l_level = 'DELINQUENCY' then
		l_dunning_rec.delinquency_id := p_source_id;
	    end if;
            l_dunning_rec.dunning_object_id := p_source_id;
            l_dunning_rec.callback_yn := 'N';
            l_dunning_rec.status := 'OPEN';
            l_dunning_rec.dunning_method:= p_method;
            l_dunning_rec.xml_template_id:= p_template_id;
            l_dunning_rec.xml_request_id := l_request_id;
            l_dunning_rec.object_type := p_object_code;
            l_dunning_rec.object_id := p_object_id;
	    l_dunning_rec.contact_destination := l_contact;   -- bug 3955222
	    l_dunning_rec.contact_party_id := l_contact_party_id;   -- bug 3955222
	    l_dunning_rec.org_id := p_org_id;  -- added for bug 9151851

	    if p_parent_request_id is not null then
		l_dunning_rec.request_id := p_parent_request_id;
	    else
		l_dunning_rec.request_id := FND_GLOBAL.Conc_Request_Id;
	    end if;

	    l_dunning_rec.dunning_mode := p_dunning_mode;
	    l_dunning_rec.correspondence_date	:= p_correspondence_date;

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');
            WriteLog(' before create dunning org_id ' || p_org_id);
            CREATE_DUNNING(p_api_version              => 1.0
                          ,p_init_msg_list            => FND_API.G_FALSE
                          ,p_commit                   => FND_API.G_TRUE
                          ,p_dunning_rec              => l_dunning_rec
                          ,x_dunning_id               => l_dunning_id
                          ,x_return_status            => l_return_status1
                          ,x_msg_count                => l_msg_count1
                          ,x_msg_data                 => l_msg_data1);

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning status='|| l_return_status1);
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunning_id='||l_dunning_id);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Dunning');
            END IF;

        END IF; -- end of p_object


    else  -- if resend - always create new dunning record

        --Don't create dunning record for resend from here. It will be created in from calling proc.
	if l_dunning_type <> 'STAGED_DUNNING' then
		l_dunning_rec.dunning_level := l_level;
		--Added for bug 9547105 gnramasa 20th Apr 2010
		if l_level = 'DELINQUENCY' then
			l_dunning_rec.delinquency_id := p_source_id;
		end if;
		l_dunning_rec.dunning_object_id := p_source_id;
		l_dunning_rec.callback_yn := 'N';
		l_dunning_rec.status := 'OPEN';
		l_dunning_rec.dunning_method:= p_method;
		l_dunning_rec.xml_template_id:= p_template_id;
		l_dunning_rec.xml_request_id := l_request_id;
		l_dunning_rec.object_type := p_object_code;
		l_dunning_rec.object_id := p_object_id;
		l_dunning_rec.contact_destination := l_contact;   -- bug 3955222
		l_dunning_rec.contact_party_id := l_contact_party_id;   -- bug 3955222

		l_dunning_rec.org_id := p_org_id; -- added for bug 9151851

		if p_parent_request_id is not null then
			l_dunning_rec.request_id := p_parent_request_id;
		else
			l_dunning_rec.request_id := FND_GLOBAL.Conc_Request_Id;
		end if;

		l_dunning_rec.dunning_mode := p_dunning_mode;
		l_dunning_rec.correspondence_date	:= p_correspondence_date;

		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - InsertRow');
		WriteLog('before create dunning org_id ' || p_org_id);
		CREATE_DUNNING(p_api_version              => 1.0
			      ,p_init_msg_list            => FND_API.G_FALSE
			      ,p_commit                   => FND_API.G_TRUE
			      ,p_dunning_rec              => l_dunning_rec
			      ,x_dunning_id               => l_dunning_id
			      ,x_return_status            => l_return_status1
			      ,x_msg_count                => l_msg_count1
			      ,x_msg_data                 => l_msg_data1);

		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateDunning status='|| l_return_status1);
		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunning_id='||l_dunning_id);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Dunning');
		END IF;
	end if; --if l_dunning_type <> 'STAGED_DUNNING' then

    end if;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_call_ffm');

    --bug 8567312
    --commit work;
    IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

    x_request_id    := l_request_id;
    x_return_status := l_return_status;



    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_return_status: '||x_return_status);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_msg_count: '||x_msg_count);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_msg_data: '||x_msg_data);

    EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
               errmsg := SQLERRM;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
--               ROLLBACK TO SEND_XML_PVT;
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception');
               errmsg := SQLERRM;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
--               ROLLBACK TO SEND_XML_PVT;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception');
               errmsg := SQLERRM;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
--               ROLLBACK TO SEND_XML_PVT;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Send_XML;



/*========================================================================
 * clchang updated 07/08/2003
 *                 for the new design of using 'Contact Purpose'.
 *                 - contact point is based on purpose, primary,
 *                   type, status;
 *                   Get the contact point for contact_point_purpose is
 *                   'DUNNING';
 *                   If null, get the contact point for all type;
 *                 - get contact point for one specific party,
 *                   if null, get relation party_id of relationship_type
 *                   is 'DUNNING', and get contact point by the relationship
 *                   org id;
 *
 * clchang updated 01/17/2004
 *                 - the party_id could be rel_party_id, person_party_id, or
 *                   org_party_id.
 *                   1. chk the party_type by chk_party_type;
 *                   2. if rel_party_id, call GetContactPoint first;
 *                      if null, (if null, same as #3)
 *                      => get org_party_id for this rel
 *                      => get org_party_id with DUNNING relationship_type
 *                      => call GetContactPoint
 *                      if null => get org_party_id directly
 *                   3. if org_party_id,
 *                      => get org_party_id with DUNNING relationship_type
 *                      => call GetContactPoint
 *                      if null => get org_party_id directly
 *                              => call GetContactPoint
 *                   4. if person_party_id,
 *                      => call GetContactPoint (person has no dunning rel)
 *
 *=======================================================================*/

Procedure GetContactInfo ( p_api_version             IN NUMBER := 1.0,
                           p_init_msg_list           IN VARCHAR2 ,
                           p_commit                  IN VARCHAR2 ,
                           p_method                  IN VARCHAR2,
                           p_party_id                IN NUMBER,
                           p_dunning_level           IN VARCHAR2,
                           p_cust_site_use_id        IN VARCHAR2,
                           x_return_status           OUT NOCOPY VARCHAR2,
                           x_msg_count               OUT NOCOPY NUMBER,
                           x_msg_data                OUT NOCOPY VARCHAR2,
                           x_contact                 OUT NOCOPY VARCHAR2,
                           x_contact_party_id        OUT NOCOPY number)

IS
    --
    CURSOR C_GET_ORG_EMAIL (IN_PARTY_ID NUMBER) IS
      SELECT email_address
        FROM HZ_PARTIES
       WHERE party_ID = in_party_ID;
    --
    CURSOR C_GET_DUNNING_ORG (IN_PARTY_ID NUMBER) IS
      SELECT party_id
        FROM HZ_RELATIONSHIPS
       WHERE object_id = in_party_ID
         AND relationship_type = 'DUNNING'
         AND status = 'A';
    --
    CURSOR C_GET_ORG_PARTY (IN_REL_PARTY_ID NUMBER) IS
      SELECT r.object_id --org party id
        FROM HZ_PARTIES p, HZ_RELATIONSHIPS r
       WHERE r.party_id = in_rel_party_ID
         AND p.party_id = r.object_id
         AND p.party_type = 'ORGANIZATION';
    --
    CURSOR C_GET_PARTY_TYPE (IN_PARTY_ID NUMBER) IS
      SELECT p.party_type
        FROM HZ_PARTIES p
       WHERE p.party_id = in_party_ID;
    --
		l_api_name          CONSTANT VARCHAR2(30) := 'GetContactInfo';
		l_api_version       NUMBER := 1.0;
		l_commit            VARCHAR2(5);
		l_party_id      NUMBER;
		l_dunning_party_id  NUMBER;
		l_party_type    VARCHAR2(30);
		nIdx            NUMBER;
		l_msg_count     NUMBER;
		l_msg_data      VARCHAR2(1000);
		errmsg          VARCHAR2(32767);
		l_return_status VARCHAR2(1000);
		l_email         VARCHAR2(2000);
		l_printer       VARCHAR2(2000);
		l_fax           VARCHAR2(2000);
		l_primary       VARCHAR2(10);

BEGIN

     -- Standard Start of API savepoint
     SAVEPOINT GetContactInfo_PVT;

     l_commit     := p_commit;
     x_contact_party_id := p_party_id; -- default to origal party_id until updated #3955222

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');

    if (p_party_id is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No PARTY_ID');
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_PARTY');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_getcontact;
    end if;
    if (p_method is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No METHOD');
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_METHOD');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_getcontact;
    end if;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Party_id='||p_party_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - method='||p_method);

   /*=======================================
    * get the primary contact email first;
    * if not found, get org email address;
    =======================================*/
    if instr( p_method, 'PRINT' ) > 0 then
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get Printer');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - userid= '||FND_GLOBAL.USER_ID);
      l_printer := NVL(fnd_profile.value('IEX_FFM_PRINTER'), '');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Printer:'||l_printer);
      if (l_printer = '' or l_printer is null) then
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No Printer');
         FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_PRINTER');
         FND_MSG_PUB.Add;
         l_return_status := FND_API.G_RET_STS_ERROR;
         GOTO end_getcontact;
      end if;
      x_contact := l_printer;

    else
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get party type');
      Open C_Get_PARTY_TYPE(p_party_id);
      Fetch C_Get_PARTY_TYPE into l_party_type;
      If ( C_GET_PARTY_TYPE%NOTFOUND ) Then
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - cannot find party type');
         FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_PARTYTYPE');
         FND_MSG_PUB.Add;
         l_return_status := FND_API.G_RET_STS_ERROR;
         Close C_Get_PARTY_TYPE;
         GOTO end_getcontact;
      END IF;
      Close C_Get_PARTY_TYPE;
      --
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - party_type=' ||l_party_type);
      --
      -- if organization, need to get the org party id  with dunning type first.
      --
      IF (l_party_type = 'PERSON' or l_party_type = 'PARTY_RELATIONSHIP') then
        GetContactPoint(
                   p_api_version              => p_api_version
                 , p_init_msg_list            => p_init_msg_list
                 , p_commit                   => p_commit
                 , p_method                   => p_method
                 , p_party_id                 => p_party_id
                 , x_return_status            => l_return_status
                 , x_msg_count                => l_msg_count
                 , x_msg_data                 => l_msg_data
                 , x_contact                  => x_contact
        );

        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - status='||l_return_status);
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - contact='||x_contact);
      END IF;

      -- person doesnt have dunning type
      -- so, we only check person contact point by GetContactPoint.
      IF (l_party_type = 'PERSON' and
          (x_contact is null or l_return_status <> FND_API.G_RET_STS_SUCCESS))
      then
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - person contact NotFound');
          FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_CONTACTINFO');
          FND_MSG_PUB.Add;
          l_return_status := FND_API.G_RET_STS_ERROR;
          GOTO end_getcontact;
      end if;
      --
      -- if relationship or organization,
      -- get the org_party_id with relationship type DUNNING first,
      --
      -- one party_is could have more than one rel party id with type DUNNING.
      -- using LOOP to fetch data until Contact Point is found.
      --
      nIdx := 0;
      if (l_party_type = 'ORGANIZATION') then
          l_party_id := p_party_id;
      else
          -- get org_party_id
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get_org_party');
          Open C_Get_ORG_PARTY(p_party_id);
          Fetch C_Get_ORG_PARTY into l_party_id;
          If ( C_GET_ORG_PARTY%NOTFOUND ) Then
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - cannot find org party');
             FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_ORG');
             FND_MSG_PUB.Add;
             l_return_status := FND_API.G_RET_STS_ERROR;
             Close C_Get_ORG_PARTY;
             GOTO end_getcontact;
          end if;
          x_contact_party_id := l_party_id; -- default to org party_id until updated #3955222
          Close C_Get_ORG_PARTY;
      end if;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - org_party_id='||l_party_id);
      --
      if (l_party_type <> 'PERSON' and
          (x_contact is null or l_return_status <> FND_API.G_RET_STS_SUCCESS))
      THEN

          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get dunning party_id');
          Open C_Get_DUNNING_ORG(l_party_id);

            Fetch C_Get_DUNNING_ORG into l_dunning_party_id;

            If ( C_GET_DUNNING_ORG%NOTFOUND or l_dunning_party_id is null) Then
              if (nIdx = 0 ) then
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No Dunning PartyId');
                l_return_status := FND_API.G_RET_STS_ERROR;
              end if;

            ELSE
              nIdx := nIdx + 1;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - rel party_id = '||l_dunning_party_id );
              l_return_status := FND_API.G_RET_STS_SUCCESS;
              GetContactPoint(
                   p_api_version              => p_api_version
                 , p_init_msg_list            => p_init_msg_list
                 , p_commit                   => p_commit
                 , p_method                   => p_method
                 , p_party_id                 => l_dunning_party_id
                 , x_return_status            => l_return_status
                 , x_msg_count                => l_msg_count
                 , x_msg_data                 => l_msg_data
                 , x_contact                  => x_contact
              );
              x_contact_party_id := l_dunning_party_id; -- default to dunning party_id until updated #3955222

              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - status='||l_return_status);
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - contact='||x_contact);

              if (x_contact is not null and
                  l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Found ContactPint!');
              end if;

           end if;

          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_contact='||x_contact);
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - close c_get_dunning_org');
          Close C_Get_DUNNING_ORG;


          -- if cannot find the contact point for dunning party id,
          -- try to get the contact point by the org party id (no dunning type).
          --
          if (x_contact is null or
              l_return_status <> FND_API.G_RET_STS_SUCCESS)
          THEN
          --
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No ContactPoint for Duning Party');
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get party_id contactpoint');
              -- get ContactPoint by org_party_id directyly (no Dunning type)
              GetContactPoint(
                   p_api_version              => p_api_version
                 , p_init_msg_list            => p_init_msg_list
                 , p_commit                   => p_commit
                 , p_method                   => p_method
                 , p_party_id                 => l_party_id
                 , x_return_status            => l_return_status
                 , x_msg_count                => l_msg_count
                 , x_msg_data                 => l_msg_data
                 , x_contact                  => x_contact
                 );
             x_contact_party_id := l_party_id; -- default to origal party_id until updated #3955222
           end if;
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_contact='||x_contact);


      end if; -- ( end of if x_contact of original party_id is null)
    --
    END IF;  -- ( end of method <> printer)


    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - x_contact:'||x_contact);


    <<end_getcontact>>
    x_return_status := l_return_status;
    if (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_contact := '';
    END IF;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return_status:'||x_return_status);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ContactInfo:'||x_contact);

    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );

    EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO GetContactInfo_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exp Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO GetContactInfo_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExp Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception');
              ROLLBACK TO GetContactInfo_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END GetContactInfo;

-- new procedure clchang added 07/08/2003 in 11.5.10
-- only for Fax and Email method
Procedure GetContactPoint ( p_api_version             IN NUMBER := 1.0,
                           p_init_msg_list           IN VARCHAR2 ,
                           p_commit                  IN VARCHAR2 ,
                           p_method                  IN VARCHAR2,
                           p_party_id                IN NUMBER,
                           x_return_status           OUT NOCOPY VARCHAR2,
                           x_msg_count               OUT NOCOPY NUMBER,
                           x_msg_data                OUT NOCOPY VARCHAR2,
                           x_contact                 OUT NOCOPY VARCHAR2)
IS
    --
    -- clchang updated 07/08/2003 to get fax and email on the new design
    -- of using 'Contact Purpose'
    -- (since 11.5.10)
    --
    CURSOR C_GET_CONTACT_EMAIL (IN_PARTY_ID NUMBER, IN_TYPE VARCHAR2) IS
      SELECT email_address,
             decode(primary_by_purpose, 'Y',1,2) purpose,
             decode(primary_flag, 'Y',1,2) primary
        FROM HZ_CONTACT_POINTS
       WHERE owner_table_ID = in_party_ID
         AND owner_table_name = 'HZ_PARTIES'
         --AND Contact_point_type = 'EMAIL'
         AND upper(Contact_point_type) = IN_TYPE
         AND Contact_point_purpose = 'DUNNING'
         AND NVL(do_not_use_flag, 'N') = 'N'
         AND (status = 'A' OR status <> 'I')
       order by purpose, primary;
    --
    CURSOR C_GET_CONTACT_EMAIL2 (IN_PARTY_ID NUMBER, IN_TYPE VARCHAR2) IS
      SELECT email_address,
             decode(primary_flag, 'Y',1,2) primary
        FROM HZ_CONTACT_POINTS
       WHERE owner_table_ID = in_party_ID
         AND owner_table_name = 'HZ_PARTIES'
         --AND Contact_point_type = 'EMAIL'
         AND upper(Contact_point_type) = IN_TYPE
         AND NVL(do_not_use_flag, 'N') = 'N'
         AND (status = 'A' OR status <> 'I')
       order by primary;
    --
    CURSOR C_GET_CONTACT_FAX (IN_PARTY_ID NUMBER) IS
      SELECT phone_country_code || phone_area_code||phone_number faxnum,
             decode(primary_by_purpose, 'Y',1,2) purpose,
             decode(primary_flag, 'Y', 1, 2) primary
        FROM HZ_CONTACT_POINTS
       WHERE owner_table_ID = in_party_ID
         AND owner_table_name = 'HZ_PARTIES'
         AND upper(Contact_point_type) = 'PHONE'
         AND upper(phone_line_type) = 'FAX'
         AND Contact_point_purpose = 'DUNNING'
         AND NVL(do_not_use_flag, 'N') = 'N'
         AND (status = 'A' OR status <> 'I')
       order by purpose, primary;
    --
    CURSOR C_GET_CONTACT_FAX2 (IN_PARTY_ID NUMBER) IS
      SELECT phone_country_code || phone_area_code||phone_number faxnum,
             decode(primary_flag, 'Y', 1, 2) primary
        FROM HZ_CONTACT_POINTS
       WHERE owner_table_ID = in_party_ID
         AND owner_table_name = 'HZ_PARTIES'
         AND upper(Contact_point_type) = 'PHONE'
         AND upper(phone_line_type) = 'FAX'
         AND NVL(do_not_use_flag, 'N') = 'N'
         AND (status = 'A' OR status <> 'I')
       order by primary;
    --
    --
l_api_name          CONSTANT VARCHAR2(30) := 'GetContactPoint';
l_api_version       NUMBER := 1.0;
l_commit            VARCHAR2(5) ;
--
l_party_id      NUMBER;
--
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(1000);
errmsg          VARCHAR2(32767);
l_return_status VARCHAR2(1000);
--
--
l_email         VARCHAR2(2000);
l_printer       VARCHAR2(2000);
l_fax           VARCHAR2(2000);
l_primary       VARCHAR2(10);
l_purpose       VARCHAR2(10);
--

BEGIN

     -- Standard Start of API savepoint
     SAVEPOINT GetContactPoint_PVT;

     l_commit    := p_commit;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');

    if (p_party_id is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No PARTY_ID');
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_PARTY');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_getcontact;
    end if;
    if (p_method is null) then
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No METHOD');
        FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_METHOD');
        FND_MSG_PUB.Add;
        l_return_status := FND_API.G_RET_STS_ERROR;
        GOTO end_getcontact;
    end if;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Party_id='||p_party_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - method='||p_method);
   /*=======================================
    * get the primary contact email first;
    * if not found, get org email address;
    =======================================*/
    if (upper(p_method) = 'EMAIL') then
    --
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - get Email');
      Open C_Get_CONTACT_EMAIL(p_party_id, 'EMAIL');
      Fetch C_Get_CONTACT_EMAIL into l_email, l_purpose, l_primary;

      -- 1. there's record in contact table with type = EMAIL,
      --    but the email is null;
      -- 2. or no record in contact table with type = EMAIL;

      If ( C_GET_CONTACT_EMAIL%NOTFOUND OR l_email is null) Then

         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Email NotFound in C_GET_CONTACT_EMAIL');
         Open C_Get_CONTACT_EMAIL2(p_party_id, 'EMAIL');
         Fetch C_Get_CONTACT_EMAIL2 into l_email, l_primary;

         If ( C_GET_CONTACT_EMAIL2%NOTFOUND) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Customer NotFound');
            FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_EMAIL');
            FND_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_CONTACT_EMAIL2;
            Close C_Get_CONTACT_EMAIL;
            GOTO end_getcontact;
         end if;
         --
         If ( l_email is null ) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EmailAddress NotFound in C_GET_ORG_EMAIL');
            FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_EMAIL');
            FND_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_CONTACT_EMAIL2;
            Close C_Get_CONTACT_EMAIL;
            GOTO end_getcontact;
         end if;
         --
         Close C_Get_CONTACT_EMAIL2;
      end if;

      If ( l_email is null ) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - EmailAddress is null');
            FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_EMAIL');
            FND_MSG_PUB.Add;
         l_return_status := FND_API.G_RET_STS_ERROR;
         Close C_Get_CONTACT_EMAIL;
         GOTO end_getcontact;
      end if;

      x_contact := l_email;

      Close C_Get_CONTACT_EMAIL;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - email='||l_email);

    --
    --
    elsif (upper(p_method) = 'FAX') then
    --
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get Fax');
      Open C_Get_CONTACT_FAX(p_party_id);
      Fetch C_Get_CONTACT_FAX into l_fax, l_purpose, l_primary;

     If ( C_GET_CONTACT_FAX%NOTFOUND OR l_fax is null) Then

         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Fax NotFound in C_GET_CONTACT_FAX');
         Open C_Get_CONTACT_FAX2(p_party_id);
         Fetch C_Get_CONTACT_FAX2 into l_fax, l_primary;

         If ( C_GET_CONTACT_FAX2%NOTFOUND) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Customer NotFound');
            FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_FAX');
            FND_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_CONTACT_FAX2;
            Close C_Get_CONTACT_FAX;
            GOTO end_getcontact;
         end if;
         --
         If ( l_fax is null ) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Fax NotFound in C_GET_CONTACT_FAX');
            FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_FAX');
            FND_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_CONTACT_FAX2;
            Close C_Get_CONTACT_FAX;
            GOTO end_getcontact;
         end if;
         --
         Close C_Get_CONTACT_FAX2;
      end if;

      If ( l_fax is null ) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - FAX NotFound');
            FND_MESSAGE.Set_Name('IEX', 'IEX_SEND_FAILED_NO_FAX');
            FND_MSG_PUB.Add;
         l_return_status := FND_API.G_RET_STS_ERROR;
         Close C_Get_CONTACT_FAX;
         GOTO end_getcontact;
      end if;

      x_contact := l_fax;

      Close C_Get_CONTACT_FAX;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - fax= '||l_fax);

    --
    END IF; -- end of p_method=EMAIL


    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - email:'||l_email);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - fax:'||l_fax);

    <<end_getcontact>>
    x_return_status := l_return_status;
    if (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_contact := '';
    END IF;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return_status:'||x_return_status);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ContactInfo:'||x_contact);

    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );

    EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO GetContactPoint_PVT;
             x_return_status := FND_API.G_RET_STS_ERROR;
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exp Exception');
             errmsg := SQLERRM;
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
             FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data
             );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO GetContactPoint_PVT;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExp Exception');
             errmsg := SQLERRM;
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
             FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data
             );

          WHEN OTHERS THEN
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception');
             ROLLBACK TO GetContactPoint_PVT;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             errmsg := SQLERRM;
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
             FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data
             );
END GetContactPoint;


Procedure CHK_QUERY_DATA(  p_query_id                IN NUMBER,
                           p_FULFILLMENT_BIND_TBL    IN IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL,
                           x_keep_flag               OUT NOCOPY NUMBER)
IS
    CURSOR C_GET_QUERY (IN_ID NUMBER) IS
      SELECT upper(query_string)
        FROM jtf_fm_queries_all
       WHERE query_id = IN_ID
         AND nvl(upper(f_deletedflag),'0') <>'D';
   --

		l_bind_var          JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
		l_bind_var_type     JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
		l_bind_val          JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
		l_bind_cnt_tbl      NUMBER;
		l_keep_flag         NUMBER := 1;
		l_query             VARCHAR2(4000);
		l_part_query        VARCHAR2(4000);
		l_party_id          NUMBER;
		l_org_id            NUMBER;
		l_account_id        NUMBER;
		l_del_id            NUMBER;
		l_result            NUMBER;
		v_cursor            NUMBER;
		v_create_string     varchar2(1000);
		v_numrows           NUMBER;
		errmsg              varchar2(32767);
		l_found             NUMBER;
		l_len               NUMBER;

		-- clchang updated for sql bind var 05/07/2003
		vstr1               VARCHAR2(100) ;
		l_api_name          CONSTANT VARCHAR2(30) := 'CHK_QUERY_DATA';


BEGIN

  WriteLog (G_PKG_NAME || ' ' || l_api_name || ' - start');
  WriteLog (G_PKG_NAME || ' ' || l_api_name || ' - queryid='||p_query_id);
  vstr1           := 'SELECT COUNT(*) ';

  l_bind_cnt_tbl := p_FULFILLMENT_BIND_TBL.count;
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bind_tbl_cnt'||l_bind_cnt_tbl);

  for j in 1..l_bind_cnt_tbl
  loop
      l_bind_var(j)      := p_FULFILLMENT_BIND_TBL(j).Key_name;
      l_bind_var_type(j) := p_FULFILLMENT_BIND_TBL(j).Key_Type;
      l_bind_val(j)      := p_FULFILLMENT_BIND_TBL(j).Key_Value;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bind_var='||l_bind_var(j));
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bind_var_type='||l_bind_var_type(j));
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - bind_val='||l_bind_val(j));
      if (l_bind_var(j) = 'party_id' ) then
          l_party_id := l_bind_val(j);
      elsif (l_bind_var(j) = 'org_id' ) then
          l_org_id := l_bind_val(j);
      elsif (l_bind_var(j) = 'account_id' ) then
          l_account_id := l_bind_val(j);
      elsif (l_bind_var(j) = 'delinquency_id' ) then
          l_del_id := l_bind_val(j);
      end if;
  end loop;

  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - partyid='||l_party_id);
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - orgid='||l_org_id);
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - acctid='||l_account_id);
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_del_id);

  OPEN C_GET_QUERY (p_query_id);
  FETCH C_GET_QUERY INTO l_query;
  If ( C_GET_QUERY%NOTFOUND ) Then
       WriteLog (G_PKG_NAME || ' ' || l_api_name || ' - NoQUERY');
       l_keep_flag := 1;
       GOTO end_query;
  else
       WriteLog (G_PKG_NAME || ' ' || l_api_name || ' - string='||l_query);
       l_len := LENGTH(l_query);
       l_found := INSTR(l_query, 'FROM');
       l_part_query := SUBSTR(l_query, l_found, (l_len-l_found+1));
       -- clchang updated for sql bind var 05/07/2003
       --l_query := 'SELECT COUNT(*) ' || l_part_query;
       l_query := vstr1 || l_part_query;
       WriteLog (G_PKG_NAME || ' ' || l_api_name || ' - new string='||l_query);

       l_query := replace(l_query, ':PARTY_ID', to_char(l_party_id) );
       WriteLog (G_PKG_NAME || ' ' || l_api_name || ' - string1='||l_query);
       l_query := replace(l_query, ':ORG_ID', to_char(l_org_id) );
       WriteLog (G_PKG_NAME || ' ' || l_api_name || ' - string2='||l_query);
       l_query := replace(l_query, ':DELINQUENCY_ID', to_char(l_del_id) );
       WriteLog (G_PKG_NAME || ' ' || l_api_name || ' - string3='||l_query);
       l_query := replace(l_query, ':ACCOUNT_ID', to_Char(l_account_id) );
       WriteLog (G_PKG_NAME || ' ' || l_api_name || ' - final string='||l_query);
  end if;
  CLOSE C_GET_QUERY;

  v_cursor := DBMS_SQL.OPEN_CURSOR;
  v_create_string := l_query;
  DBMS_SQL.parse(v_cursor, v_create_string, 1);
  DBMS_SQL.DEFINE_COLUMN(v_cursor, 1, l_result);
  v_numrows := DBMS_SQL.EXECUTE(v_cursor);
  v_numrows := DBMS_SQL.FETCH_ROWS(v_cursor);
  DBMS_SQL.COLUMN_VALUE(v_cursor, 1, l_result);
  WriteLog (G_PKG_NAME || ' ' || l_api_name || ' - result='||l_result);

  DBMS_SQL.CLOSE_CURSOR(v_cursor);

  if (l_result > 0) then
      l_keep_flag := 1;
  else
      l_keep_flag := 0;
  end if;

  <<end_query>>
  x_keep_flag := l_keep_flag;
  WriteLog (G_PKG_NAME || ' ' || l_api_name || ' - x_keep_flag='||l_keep_flag);
  WriteLog (G_PKG_NAME || ' ' || l_api_name || ' - end');

    EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
              x_keep_flag := 1;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
              x_keep_flag := 1;

          WHEN OTHERS THEN
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
              x_keep_flag := 1;

END CHK_QUERY_DATA;



PROCEDURE Close_Dunning
           (p_api_version             IN NUMBER,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
            p_running_level           IN VARCHAR2,
	    --p_dunning_id              IN NUMBER default NULL,   -- added by gnramasa for bug 8489610 14-May-09
	    --p_status                  IN VARCHAR2 , -- added by gnramasa for bug 8489610 14-May-09
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS
  --Start adding for bug 8489610 by gnramasa 14-May-09
    CURSOR C_GET_DUNNING (IN_ID NUMBER, IN_TYPE VARCHAR2) IS
      SELECT dunning_ID
        FROM IEX_DUNNINGS
       WHERE
         STATUS = 'OPEN'
         AND dunning_level = IN_TYPE
         AND dunning_object_id = IN_ID;
--	 AND decode(nvl(dunning_mode,'FINAL'), 'DRAFT',confirmation_mode, 'FINAL','CONFIRMED')='CONFIRMED'
--	 AND dunning_id <> nvl(p_dunning_id,-1) ;
  --End adding for bug 8489610 by gnramasa 14-May-09
    --
    l_DUNNING_id            NUMBER;
    l_delinquency_id        NUMBER;
    l_dunning_object_id     NUMBER;
    l_dunning_level         VARCHAR2(30);
    l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_api_name              CONSTANT VARCHAR2(30) := 'Close_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);
    nIdx                    NUMBER := 0;
    nCnt                    NUMBER := 0;
    --
    TYPE Dunning_ID_TBL_type is Table of IEX_DUNNINGS.DUNNING_ID%TYPE
				        INDEX BY BINARY_INTEGER;
    dunning_tbl             Dunning_ID_TBL_TYPE;
    --
BEGIN
      SAVEPOINT CLOSE_DUNNING_PVT;

      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - start');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - running_level='||p_running_level);

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_dunning_level := p_running_level;

      if (p_running_level = 'CUSTOMER') then
          l_dunning_object_id := p_delinquencies_tbl(1).party_cust_id;
      elsif (p_running_level = 'ACCOUNT') THEN
          l_dunning_object_id := p_delinquencies_tbl(1).cust_account_id;
      elsif (p_running_level = 'BILL_TO') THEN
          l_dunning_object_id := p_delinquencies_tbl(1).customer_site_use_id;
      else
          l_dunning_object_id := p_delinquencies_tbl(1).delinquency_id;
      end if;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunning_level='||l_dunning_level);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunning_object_id='||l_dunning_object_id);

         --=============================================================
         --  Suppose one del has at most one open dunning.
         --  If we find out NOCOPY more than one open dunning, close all.
         --=============================================================
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetDunning');

          nIdx := 1;
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - del cnt=' ||p_delinquencies_tbl.count);

          FOR i in 1..p_delinquencies_tbl.count
          LOOP
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Loop:i=' ||i);

             nCnt := 0;
             OPEN C_GET_DUNNING (l_dunning_object_id, l_dunning_level);
             LOOP
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - nCnt='||nCnt);
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - nIdx='||nIdx);
                FETCH C_GET_DUNNING INTO l_dunning_id;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunningId='||l_dunning_id);
                dunning_tbl(nIdx) := l_dunning_id;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunn='||dunning_tbl(nIdx));

                If ( C_GET_DUNNING%NOTFOUND ) Then
                    if (nCnt = 0) then
                      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - NoOpenDunning');
                    end if;
                    GOTO end_dunning_loop;
                else
                    nCnt := nCnt + 1;
                    nIdx := nIdx+1;
                end if;
              END LOOP;

              <<end_dunning_loop>>
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End_Dunning_Loop');

          CLOSE C_GET_DUNNING;
          END LOOP;

          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunnCnt='||nIdx||';'||dunning_tbl.count);

	  FORALL i in 1..dunning_tbl.count
				  UPDATE IEX_DUNNINGS
				     SET CALLBACK_YN = 'N',
	                STATUS = 'CLOSE',
	                LAST_UPDATE_DATE = sysdate
            WHERE Dunning_id = dunning_tbl(i);
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End');

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO CLOSE_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
					   x_return_status := FND_API.G_RET_STS_ERROR;
					   FND_MSG_PUB.Count_And_Get
					   (  p_count          =>   x_msg_count,
					      p_data           =>   x_msg_data
					    );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO CLOSE_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
					   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
					   FND_MSG_PUB.Count_And_Get
					   (  p_count          =>   x_msg_count,
					      p_data           =>   x_msg_data
					    );

          WHEN OTHERS THEN
             ROLLBACK TO CLOSE_DUNNING_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
					   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
					   FND_MSG_PUB.Count_And_Get
					   (  p_count          =>   x_msg_count,
					      p_data           =>   x_msg_data
					    );

END Close_Dunning;

PROCEDURE Close_Staged_Dunning
           (p_api_version             IN NUMBER,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE,
	    p_ag_dn_xref_id           IN NUMBER,
            p_running_level           IN VARCHAR2,
	    --p_dunning_id              IN NUMBER default NULL,   -- added by gnramasa for bug 8489610 14-May-09
	    --p_status                  IN VARCHAR2 , -- added by gnramasa for bug 8489610 14-May-09
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS
  --Start adding for bug 8489610 by gnramasa 14-May-09
    CURSOR C_GET_DUNNING (IN_ID NUMBER, IN_TYPE VARCHAR2, IN_DUNN_PLAN_LINE_ID NUMBER) IS
      SELECT dunning_ID
        FROM IEX_DUNNINGS
       WHERE
         STATUS = 'OPEN'
         AND dunning_level = IN_TYPE
         AND dunning_object_id = IN_ID
	 AND (ag_dn_xref_id = IN_DUNN_PLAN_LINE_ID OR
	      ag_dn_xref_id IS NULL);
  --End adding for bug 8489610 by gnramasa 14-May-09

    l_DUNNING_id            NUMBER;
    l_delinquency_id        NUMBER;
    l_dunning_object_id     NUMBER;
    l_dunning_level         VARCHAR2(30);
    l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_api_name              CONSTANT VARCHAR2(30) := 'Close_Staged_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);
    nIdx                    NUMBER := 0;
    nCnt                    NUMBER := 0;
    --
    TYPE Dunning_ID_TBL_type is Table of IEX_DUNNINGS.DUNNING_ID%TYPE
				        INDEX BY BINARY_INTEGER;
    dunning_tbl             Dunning_ID_TBL_TYPE;
    --
BEGIN
      SAVEPOINT Close_Staged_Dunning_PVT;

      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - start');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - running_level='||p_running_level);

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_dunning_level := p_running_level;

      if (p_running_level = 'CUSTOMER') then
          l_dunning_object_id := p_delinquencies_tbl(1).party_cust_id;
      elsif (p_running_level = 'ACCOUNT') THEN
          l_dunning_object_id := p_delinquencies_tbl(1).cust_account_id;
      elsif (p_running_level = 'BILL_TO') THEN
          l_dunning_object_id := p_delinquencies_tbl(1).customer_site_use_id;
      else
          l_dunning_object_id := p_delinquencies_tbl(1).delinquency_id;
      end if;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunning_level='||l_dunning_level);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunning_object_id='||l_dunning_object_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_ag_dn_xref_id='||p_ag_dn_xref_id);

         --=============================================================
         --  Suppose one del has at most one open dunning.
         --  If we find out NOCOPY more than one open dunning, close all.
         --=============================================================
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - GetDunning');

          nIdx := 1;
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - del cnt=' ||p_delinquencies_tbl.count);

          FOR i in 1..p_delinquencies_tbl.count
          LOOP
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Loop:i=' ||i);

             nCnt := 0;
             OPEN C_GET_DUNNING (l_dunning_object_id, l_dunning_level, p_ag_dn_xref_id);
             LOOP
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - nCnt='||nCnt);
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - nIdx='||nIdx);
                FETCH C_GET_DUNNING INTO l_dunning_id;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunningId='||l_dunning_id);
                dunning_tbl(nIdx) := l_dunning_id;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunn='||dunning_tbl(nIdx));

                If ( C_GET_DUNNING%NOTFOUND ) Then
                    if (nCnt = 0) then
                      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - NoOpenDunning');
                    end if;
                    GOTO end_dunning_loop;
                else
                    nCnt := nCnt + 1;
                    nIdx := nIdx+1;
                end if;
              END LOOP;

              <<end_dunning_loop>>
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End_Dunning_Loop');

          CLOSE C_GET_DUNNING;
          END LOOP;

          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunnCnt='||nIdx||';'||dunning_tbl.count);

	  FORALL i in 1..dunning_tbl.count
				  UPDATE IEX_DUNNINGS
				     SET CALLBACK_YN = 'N',
	                STATUS = 'CLOSE',
	                LAST_UPDATE_DATE = sysdate
            WHERE Dunning_id = dunning_tbl(i);
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End');

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO Close_Staged_Dunning_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
					   x_return_status := FND_API.G_RET_STS_ERROR;
					   FND_MSG_PUB.Count_And_Get
					   (  p_count          =>   x_msg_count,
					      p_data           =>   x_msg_data
					    );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO Close_Staged_Dunning_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
					   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
					   FND_MSG_PUB.Count_And_Get
					   (  p_count          =>   x_msg_count,
					      p_data           =>   x_msg_data
					    );

          WHEN OTHERS THEN
             ROLLBACK TO Close_Staged_Dunning_PVT;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
					   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
					   FND_MSG_PUB.Count_And_Get
					   (  p_count          =>   x_msg_count,
					      p_data           =>   x_msg_data
					    );

END Close_Staged_Dunning;

Procedure Daily_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_running_level           IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
    --Start adding for bug 8489610 by gnramasa 14-May-09
    CURSOR C_GET_DUNNING (IN_LEVEL VARCHAR2) IS
      SELECT dunning_ID,
             delinquency_id,
             dunning_object_id,
             to_char(callback_date, 'YYYYMMDD')
        FROM IEX_DUNNINGS
       WHERE STATUS = 'OPEN'
        AND CALLBACK_YN = 'Y'
        AND dunning_level = IN_LEVEL
        AND to_char(callback_date, 'YYYYMMDD') <= to_char(sysdate,'YYYYMMDD');
	--AND decode(nvl(dunning_mode,'FINAL'), 'DRAFT',confirmation_mode, 'FINAL','CONFIRMED')='CONFIRMED';
    --End adding for bug 8489610 by gnramasa 14-May-09
    --
    CURSOR C_CHK_DEL (IN_del_ID NUMBER) IS
      SELECT 1
        FROM IEX_DELINQUENCIES d
       WHERE d.delinquency_ID = in_del_ID
         AND STATUS in ('DELINQUENT', 'PREDELINQUENT');
    --
    CURSOR C_CHK_ACCOUNT (IN_ACCT_ID NUMBER) IS
      SELECT 1
        FROM IEX_DELINQUENCIES d
       WHERE d.cust_account_ID = in_ACCT_ID
         AND STATUS in ('DELINQUENT', 'PREDELINQUENT');
    --
    CURSOR C_CHK_CUSTOMER (IN_PARTY_ID NUMBER) IS
      SELECT 1
        FROM IEX_DELINQUENCIES d
       WHERE d.party_cust_id = in_party_id
         AND STATUS in ('DELINQUENT', 'PREDELINQUENT');
    --
    CURSOR C_CHK_SITE (IN_SITE_ID NUMBER) IS
      SELECT 1
        FROM IEX_DELINQUENCIES d
       WHERE d.customer_site_use_id = in_SITE_ID
         AND STATUS in ('DELINQUENT', 'PREDELINQUENT');
    --
    l_DUNNING_id            NUMBER;
    l_delinquency_id        NUMBER;
    l_callback_date         varchar2(10);
    l_DUNNING_rec           IEX_DUNNING_PUB.DUNNING_REC_TYPE;
    l_curr_date             varchar2(10);
    l_task_id               NUMBER;
    l_api_name              CONSTANT VARCHAR2(30) := 'Daily_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);
    nIdx                    NUMBER := 0;
    nCnt                    NUMBER := 0;
    l_chk                   NUMBER := 0;
    l_task_cnt              NUMBER := 0;
    l_skip                  NUMBER := 0;
    --
    TYPE Dunning_ID_TBL_type is Table of IEX_DUNNINGS.DUNNING_ID%TYPE
				        INDEX BY BINARY_INTEGER;
    dunning_tbl             Dunning_ID_TBL_TYPE;
    l_dunning_object_id     NUMBER;

--Begin bug 7317666 21-Nov-2008 barathsr
    l_task_query varchar2(4000);
    TYPE c_cur_type IS REF CURSOR;
    c_invalid_tasks c_cur_type;
    l_inv_task_id JTF_TASKS_B.TASK_ID%TYPE;
    l_object_version_number JTF_TASKS_B.OBJECT_VERSION_NUMBER%TYPE;
--End bug 7317666 21-Nov-2008 barathsr

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DAILY_DUNNING_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start') ;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - running_level='||p_running_level) ;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_curr_date := to_char(sysdate, 'YYYYMMDD');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CurrDate='||l_curr_date) ;
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'current date=' || l_curr_date);
      --
      -- Api body
      --

      nIdx := 0;
      Open C_Get_DUNNING (p_running_level);
      LOOP

         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ================') ;
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Open C_Get_Dunning');

           Fetch C_Get_DUNNING into
                   l_dunning_id,
                   l_delinquency_id,
                   l_dunning_object_id,
                   l_callback_date;

           If ( C_GET_DUNNING%NOTFOUND ) Then
                if (nIdx = 0) then
                    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - NoOpenDunning with callback_yn=Y');
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'NoOpenDunning with callback_yn=Y');

                end if;
                exit;
           ELSE

                l_skip := 0;
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunningID='||l_dunning_id) ;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunningObjectID='||l_dunning_object_id) ;
                WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Callback_Date='||l_callback_date) ;
                FND_FILE.PUT_LINE(FND_FILE.LOG, '*****dunning_id='||l_dunning_id||'*****');

                /*=========================================
                 * bug 2816550 - clchan updatd 02/21/2003
                 * for this current dunning,
                 * if the associated delinquenty is closed, no callback;
                 *=======================================================*/
                 IF (p_running_level = 'CUSTOMER') THEN
                     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Chk Customer:'||l_dunning_object_id) ;
                     Open C_CHK_CUSTOMER(l_dunning_object_id);
                     Fetch C_CHK_CUSTOMER into l_chk;

                     If ( C_CHK_CUSTOMER%NOTFOUND) Then
                          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - All Del Closed for this customer');
                          FND_FILE.PUT_LINE(FND_FILE.LOG, 'All Delinquencies Closed for this customer');
                          Close C_CHK_CUSTOMER;
                          l_skip := 1;
                    else
                        l_skip := 0;
                        Close C_CHK_CUSTOMER;
                        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - can continue') ;
                    end if;
                 --
                 ELSIF (p_running_level = 'ACCOUNT') THEN
                     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Chk Account:'||l_dunning_object_id) ;
                     Open C_CHK_Account(l_dunning_object_id);
                     Fetch C_CHK_Account into l_chk;

                     If ( C_CHK_Account%NOTFOUND) Then
                          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - All Del Closed for this Account');
                          FND_FILE.PUT_LINE(FND_FILE.LOG, 'All Delinquencies Closed for this account');
                          Close C_CHK_Account;
                          --GOTO end_dunning_if;
                          l_skip := 1;
                    else
                        l_skip := 0;
                        Close C_CHK_Account;
                        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - can continue') ;
                    end if;
                 --
                 ELSIF (p_running_level = 'BILL_TO') THEN
                     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Chk Bill To:'||l_dunning_object_id) ;
                     Open C_CHK_Site(l_dunning_object_id);
                     Fetch C_CHK_Site into l_chk;

                     If ( C_CHK_Site%NOTFOUND) Then
                          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - All Del Closed for this site');
                          FND_FILE.PUT_LINE(FND_FILE.LOG, 'All Delinquencies Closed for this site');
                          Close C_CHK_Site;
                          --GOTO end_dunning_if;
                          l_skip := 1;
                    else
                        l_skip := 0;
                        Close C_CHK_Site;
                        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - can continue') ;
                    end if;
                 --
                 ELSIF (p_running_level = 'DELINQUENCY') THEN
                     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Chk DEL:'||l_delinquency_id) ;
                     Open C_CHK_DEL(l_delinquency_id);
                     Fetch C_CHK_DEL into l_chk;

                     If ( C_CHK_DEL%NOTFOUND) Then
                          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Del Closed for this del');
                          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Delinquency Closed');
                          Close C_CHK_DEL;
                          --GOTO end_dunning_if;
                          l_skip := 1;
                    else
                        l_skip := 0;
                        Close C_CHK_DEL;
                        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - can continue') ;
                    end if;
                 END IF; -- end of chk running_level


              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_skip='||l_skip) ;
              IF (l_skip = 0) THEN

                 nIdx := nIdx + 1;
                 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - OPEN DUNNING:Num'||nIdx||'=========') ;
                 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - New_Task');

                 New_Task(
                   p_api_version              => p_api_version
                 , p_init_msg_list            => p_init_msg_list
                 , p_commit                   => p_commit
                 , p_delinquency_id           => l_delinquency_id
                 , p_dunning_id               => l_dunning_id
                 , p_dunning_object_id        => l_dunning_object_id
                 , p_dunning_level            => p_running_level
                 , x_task_id                  => l_task_id
                 , x_return_status            => x_return_status
                 , x_msg_count                => x_msg_count
                 , x_msg_data                 => x_msg_data
                 );


                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot create new Task');
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot create new task');
                    FND_MSG_PUB.Count_And_Get
                    (  p_count          =>   x_msg_count,
                       p_data           =>   x_msg_data );
                    for i in 1..x_msg_count loop
                        errmsg := FND_MSG_PUB.Get(p_msg_index => i,
                                                  p_encoded => 'F');
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error:'||errmsg);
                        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errmsg=' || errmsg);
                    end loop;
                    l_skip := 1;
                 else
                   l_skip := 0;
                   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - taskid='||l_task_id);
                   --FND_FILE.PUT_LINE(FND_FILE.LOG, 'task_id='||l_task_id);
                   l_task_cnt := l_task_cnt + 1;
                 END IF;  -- end of create_task

             /*======================
              * Update Dunning
              *=====================*/
               IF (l_skip = 0) THEN
                   nCnt := nCnt + 1;
                   dunning_tbl(nCnt) := l_dunning_id;
               END IF;

            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_if (l_skip)');
            END IF; -- end of (l_skip)

           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_if (FoundDunningData)');
           END IF; -- end of (FoundDunningData)

           <<end_dunning_loop>>
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end_dunning_loop');
           NULL;

      end loop;  -- end of CURSOR loop


      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - update_dunnings cnt='||nCnt);

      IF (nCnt > 0) THEN

         FORALL i in 1..dunning_tbl.count
			   UPDATE IEX_DUNNINGS
            SET CALLBACK_YN = 'N',
                LAST_UPDATE_DATE = sysdate
          WHERE Dunning_id = dunning_tbl(i);

      END IF;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Close C_GET_DUNNING');
      Close C_Get_DUNNING;

      --
      -- End of API body
      --

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========SUMMARY=========');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - TotalOpenDunn='||nIdx);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - TaskCreatedNum='||l_task_cnt);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunnUpdatedNum='||nCnt);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - DunnUpdatedNum='||dunning_tbl.count);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ==========END SUMMARY=========');

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      --Begin bug 7317666 21-Nov-2008 barathsr
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Cancelling the Dunning callback tasks correpsonding to current objects...');
      l_task_query := 'select tsk.task_id,'
               ||'tsk.object_version_number'
               ||' from jtf_tasks_b tsk,'
               ||' jtf_task_types_tl typ,'
               ||' jtf_task_statuses_b st,'
               ||' jtf_task_references_b ref,'
               ||' iex_dunnings dun'
               ||' where tsk.task_type_id=typ.task_type_id'
               ||' and typ.name=''Callback'''
               ||' and tsk.task_status_id=st.task_status_id'
               ||' and  nvl(st.closed_flag,   ''N'') <>''Y'''
               ||' and  nvl(st.cancelled_flag,   ''N'')<>''Y'''
               ||' and  nvl(st.completed_flag,   ''N'')<>''Y'''
               ||' and tsk.task_id=ref.task_id'
               ||' and ref.object_type_code=''IEX_DUNNING'''
               ||' and ref.object_id=dun.dunning_id'
               ||' and dun.dunning_level='''||p_running_level||'''';

      IF (p_running_level = 'CUSTOMER') THEN
      l_task_query:=l_task_query||' and not exists(select 1 from iex_delinquencies_all del '
                  ||' where  del.status in (''DELINQUENT'',''PREDELINQUENT'') '
                  ||' and dun.dunning_object_id=del.party_cust_id)';
      ELSIF(p_running_level = 'ACCOUNT') THEN
      l_task_query:=l_task_query||' and not exists(select 1 from iex_delinquencies_all del '
                  ||' where  del.status in (''DELINQUENT'',''PREDELINQUENT'') '
                  ||' and dun.dunning_object_id=del.cust_account_id)';
      ELSIF(p_running_level = 'BILL_TO') THEN
      l_task_query:=l_task_query||' and not exists(select 1 from iex_delinquencies_all del '
                  ||' where  del.status in (''DELINQUENT'',''PREDELINQUENT'') '
                  ||' and dun.dunning_object_id=del.customer_site_use_id)';
      ELSE
      l_task_query:=l_task_query||' and not exists(select 1 from iex_delinquencies_all del '
                  ||' where  del.status in (''DELINQUENT'',''PREDELINQUENT'') '
                  ||' and dun.dunning_object_id=del.delinquency_id)';
      END IF;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || 'Query: '||l_task_query);

	OPEN c_invalid_tasks for l_task_query;
	LOOP
		FETCH c_invalid_tasks INTO l_inv_task_id,l_object_version_number;
		EXIT WHEN c_invalid_tasks%NOTFOUND;
		WriteLog(G_PKG_NAME || ' ' || l_api_name || 'Cancelling callback Task Id:'||l_inv_task_id);
                IF l_inv_task_id IS NOT NULL THEN
			JTF_TASKS_PUB.UPDATE_TASK(
			P_API_VERSION           	=> p_api_version,
		        P_INIT_MSG_LIST         	=> p_init_msg_list,
		        P_COMMIT                	=> p_commit,
			P_OBJECT_VERSION_NUMBER	=> l_object_version_number,
			P_TASK_ID 			=> l_inv_task_id,
			P_TASK_STATUS_NAME		=> 'Cancelled',
			x_return_status		        => x_return_status,
			x_msg_count			=> x_msg_count,
			x_msg_data			=> x_msg_data);
			WriteLog(G_PKG_NAME || ' ' || l_api_name || 'Cancelling callback Task return status:'||x_return_status);
		END IF;

	END LOOP;
	WriteLog(G_PKG_NAME || ' ' || l_api_name || 'Completed cancelling Dunning callback tasks correpsonding to current objects...');

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
      --End bug 7317666 21-Nov-2008 barathsr

      -- clchang added 08/15/2003
      -- make return_status = 'S';
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return status='||x_return_status);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
               errmsg := SQLERRM;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
               ROLLBACK TO DAILY_DUNNING_PVT;
	       x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data
                );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               ROLLBACK TO DAILY_DUNNING_PVT;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception');
               errmsg := SQLERRM;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data
                );

          WHEN OTHERS THEN
              ROLLBACK TO DAILY_DUNNING_PVT;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Others Exception');
               errmsg := SQLERRM;
               WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception errmsg='||errmsg);
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data
                );

END Daily_Dunning;



Procedure NEW_TASK(
            p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_delinquency_id          IN NUMBER,
            p_dunning_id              IN NUMBER,
            p_dunning_object_id       IN NUMBER,
            p_dunning_level           IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_TASK_ID                 OUT NOCOPY NUMBER)
IS
    CURSOR C_GET_DEL (IN_del_ID NUMBER) IS
      SELECT d.delinquency_ID,
             d.party_cust_id,
             d.cust_account_id,
             a.account_number,
             d.customer_site_use_id,
             ar.trx_number,
             ar.payment_schedule_id,
             h.party_name
        FROM IEX_DELINQUENCIES d,
             HZ_PARTIES h,
             HZ_CUST_ACCOUNTS a,
             AR_PAYMENT_SCHEDULES ar
       WHERE d.delinquency_ID = in_del_ID
         AND h.party_id = d.party_cust_id
         AND d.cust_account_id = a.cust_account_id
         AND ar.payment_schedule_id = d.payment_schedule_id
         AND ar.class = 'INV';
    --
    CURSOR C_GET_SITE (IN_SITE_ID NUMBER) IS
      SELECT d.party_cust_id,
             d.cust_account_id,
             a.account_number,
             d.customer_site_use_id,
             h.party_name
        FROM IEX_DELINQUENCIES d,
             HZ_PARTIES h,
             HZ_CUST_ACCOUNTS a
       WHERE d.customer_site_use_id = in_SITE_ID
	 AND h.party_id = d.party_cust_id
         AND d.cust_account_id = a.cust_account_id;
    --
    CURSOR C_GET_ACCOUNT (IN_ACCT_ID NUMBER) IS
      SELECT d.party_cust_id,
             d.cust_account_id,
             a.account_number,
             h.party_name
        FROM IEX_DELINQUENCIES d,
             HZ_PARTIES h,
             HZ_CUST_ACCOUNTS a
       WHERE d.cust_account_ID = in_ACCT_ID
	 AND h.party_id = d.party_cust_id
         AND d.cust_account_id = a.cust_account_id;
    --
    CURSOR C_GET_CUSTOMER (IN_PARTY_ID NUMBER) IS
      SELECT d.party_cust_id,
             h.party_name
        FROM IEX_DELINQUENCIES d,
             HZ_PARTIES h
       WHERE d.party_cust_id = in_party_id
         AND h.party_id = d.party_cust_id;
    --
    l_delinquency_id        NUMBER;
    l_dunning_id            NUMBER ;
    l_party_cust_id         NUMBER;
    l_account_id            NUMBER;
    l_account_num           VARCHAR2(30); --NUMBER;
    l_customer_site_use_id  NUMBER;
    l_payment_schedule_id   NUMBER;
    l_trx_number            varchar2(30);
    l_resource_id           NUMBER;
    l_party_name            varchar2(360);
    --
    l_task_name             varchar2(80) ;
    l_task_type             varchar2(30) ;
    l_task_status           varchar2(30) ;
    l_description           varchar2(4000);
    l_task_priority_name    varchar2(30) ;
    l_task_priority_id      number;
    l_owner_id              number;
    l_owner                 varchar2(4000);
    l_owner_type_code       varchar2(4000);
    l_customer_id           number;
    l_address_id            number;
    l_source_object_type_code  varchar2(30);
    l_source_object_id         number;
    l_source_object_name       varchar2(80);
    --
    l_task_notes_tbl           JTF_TASKS_PUB.TASK_NOTES_TBL;
    l_miss_task_assign_tbl     JTF_TASKS_PUB.TASK_ASSIGN_TBL;
    l_miss_task_depends_tbl    JTF_TASKS_PUB.TASK_DEPENDS_TBL;
    l_miss_task_rsrc_req_tbl   JTF_TASKS_PUB.TASK_RSRC_REQ_TBL;
    l_task_refer_rec           JTF_TASKS_PUB.TASK_REFER_REC;
    l_task_refer_tbl           JTF_TASKS_PUB.TASK_REFER_TBL;
    l_miss_task_dates_tbl      JTF_TASKS_PUB.TASK_DATES_TBL;
    l_miss_task_recur_rec      JTF_TASKS_PUB.TASK_RECUR_REC;
    l_miss_task_contacts_tbl   JTF_TASKS_PUB.TASK_CONTACTS_TBL;
    --
    errmsg                 varchar2(30000);

    --Added for bug#5229763 schekuri 27-Jul-2006
    l_resource_tab iex_utilities.resource_tab_type;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);
    l_validation_level NUMBER ;
    l_default_rs_id  NUMBER := fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE');
    l_api_version   NUMBER       := 1.0;
		l_api_name varchar2(25) := 'NEW_TASK';

  BEGIN

    -- Initialize API return status to SUCCESS
    l_validation_level := FND_API.G_VALID_LEVEL_FULL;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_dunning_id := p_dunning_id;

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||p_delinquency_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunningobjectid='||p_dunning_object_id);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunningLevel='||p_dunning_level);

    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - OPEN CURSOR');

    IF (p_dunning_level = 'ACCOUNT')
    THEN
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - OPEN ACCOUNT CURSOR');
        Open C_Get_ACCOUNT(p_dunning_object_id);
        Fetch C_Get_ACCOUNT into
           l_party_cust_id,
           l_account_id,
           l_account_num,
           l_party_name;

        If ( C_GET_ACCOUNT%NOTFOUND) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ACCOUNT NotFound');
            x_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_ACCOUNT;
            GOTO end_new_task;
        end if;
        Close C_Get_ACCOUNT;
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get ACCNT Data');
    --
    ELSIF (p_dunning_level = 'CUSTOMER')
    THEN
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - OPEN CUSTOMER CURSOR');
        Open C_Get_CUSTOMER(p_dunning_object_id);
        Fetch C_Get_CUSTOMER into
           l_party_cust_id,
           l_party_name;

        If ( C_GET_CUSTOMER%NOTFOUND) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CUSTOMER NotFound');
            x_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_CUSTOMER;
            GOTO end_new_task;
        end if;
        Close C_Get_CUSTOMER;
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get CUSTOMER Data');
    --
    -- added for new level 'BILL_TO' in 11.5.10
    ELSIF (p_dunning_level = 'BILL_TO')
    THEN
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - OPEN BILL_TO CURSOR');
        Open C_Get_SITE(p_dunning_object_id);
        Fetch C_Get_SITE into
           l_party_cust_id,
           l_account_id,
           l_account_num,
           l_customer_site_use_id,
           l_party_name;

        If ( C_GET_SITE%NOTFOUND) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ACCOUNT NotFound');
            x_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_SITE;
            GOTO end_new_task;
        end if;
        Close C_Get_SITE;
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get SITE Data');
    --
    ELSIF (p_dunning_level = 'DELINQUENCY')
    THEN
        Open C_Get_DEL(p_delinquency_id);
        Fetch C_Get_DEL into
           l_delinquency_id,
           l_party_cust_id,
           l_account_id,
           l_account_num,
           l_customer_site_use_id,
           l_trx_number,
           l_payment_schedule_id,
           l_party_name;

        If ( C_GET_DEL%NOTFOUND) Then
            WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Del NotFound');
            x_return_status := FND_API.G_RET_STS_ERROR;
            Close C_Get_DEL;
            GOTO end_new_task;
        end if;
        Close C_Get_DEL;
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Get Del Data');
   END IF;


    If ( l_party_cust_id is null ) Then
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - PartyCustId NotFound');
         x_return_status := FND_API.G_RET_STS_ERROR;
         GOTO end_new_task;
    end if;

  -- clchang updated 09/20/2002 for bug 2242346
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Call GET_RESOURCE');
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - partyid='||l_party_cust_id);
  --Begin Bug#5229763 schekuri 27-Jul-2006
  --Called iex_utilities.get_assigned_collector to get the resource from hz_customer_profiles table
  --instead of as_accesses. Removed the call to "get_resource".
  if l_customer_site_use_id is not null then
	iex_utilities.get_assigned_collector(p_api_version => l_api_version,
                               p_init_msg_list     => FND_API.G_TRUE,
                               p_commit            => FND_API.G_FALSE,
                               p_validation_level  => l_validation_level,
                               p_level             => 'DUNNING_BILLTO',
                               p_level_id          => l_customer_site_use_id,
                               x_msg_count         => l_msg_count,
                               x_msg_data          => l_msg_data,
                               x_return_status     => l_return_status,
                               x_resource_tab      => l_resource_tab);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     GOTO end_new_task;
	END IF;
  end if;

  if l_resource_tab.count<1 and l_account_id is not null then
	  iex_utilities.get_assigned_collector(p_api_version => l_api_version,
                               p_init_msg_list     => FND_API.G_TRUE,
                               p_commit            => FND_API.G_FALSE,
                               p_validation_level  => l_validation_level,
                               p_level             => 'DUNNING_ACCOUNT',
                               p_level_id          => l_account_id,
                               x_msg_count         => l_msg_count,
                               x_msg_data          => l_msg_data,
                               x_return_status     => l_return_status,
                               x_resource_tab      => l_resource_tab);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     GOTO end_new_task;
	END IF;
  end if;

  if l_resource_tab.count<1 and l_party_cust_id is not null then
	iex_utilities.get_assigned_collector(p_api_version => l_api_version,
                               p_init_msg_list     => FND_API.G_TRUE,
                               p_commit            => FND_API.G_FALSE,
                               p_validation_level  => l_validation_level,
                               p_level             => 'DUNNING_PARTY',
                               p_level_id          => l_party_cust_id,
                               x_msg_count         => l_msg_count,
                               x_msg_data          => l_msg_data,
                               x_return_status     => l_return_status,
                               x_resource_tab      => l_resource_tab);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     GOTO end_new_task;
	END IF;

	if l_resource_tab.count<1 and p_dunning_level = 'CUSTOMER' then
		iex_utilities.get_assigned_collector(p_api_version => l_api_version,
													               p_init_msg_list     => FND_API.G_TRUE,
																				 p_commit            => FND_API.G_FALSE,
																				 p_validation_level  => l_validation_level,
																				 p_level             => 'DUNNING_PARTY_ACCOUNT',
																				 p_level_id          => l_party_cust_id,
																				 x_msg_count         => l_msg_count,
																				 x_msg_data          => l_msg_data,
																				 x_return_status     => l_return_status,
																				 x_resource_tab      => l_resource_tab);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource');
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     GOTO end_new_task;
		END IF;
	end if;
  end if;

  if l_resource_tab.count>0 then
    l_resource_id := l_resource_tab(1).resource_id;
  else
    if l_default_rs_id is not null then
       l_resource_id := l_default_rs_id;
    else
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot get resource from customer profile and there is no default resource set');
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'No collector has been assigned to this customer '||l_party_name);
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'No default collector available to assign to callback.  Please update default collector.');
       GOTO end_new_task;
    end if;
  end if;
  --End Bug#5229763 schekuri 27-Jul-2006

  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - resource_id='||l_resource_id);
  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunning_id='||l_dunning_id);

         l_task_name   := 'Dunning Callback';
         l_task_status := 'Open';
         --l_task_type   := 'Approval'; --'Callback';
         l_task_type   := 'Callback';
         l_description := 'Oracle Collections Daily Dunnings';
         --l_task_priority_name := ;
         --l_task_priority_id := ;
         l_owner_type_code := 'RS_EMPLOYEE';
         l_owner_id := l_resource_id;
         l_customer_id := l_party_cust_id;

         -- clchang updated 04/09/2003 bug 2872385
         -- source object code should be based on the dunning level;
         -- ( in order to be seen in Collections Task tab )
         -- p.s. Collectons Task tab is based on the ViewBy;
         --      ViewBy is PARTY => only see tasks with source_object_code PARTY
         --      ViewBy is ACCOUNT => see tasks with source_object_code ACCOUNT
         --      ViewBy is DELINQUENCY => only see tasks with source_object_code DELINQUENCY

         --
         -- clchang updated 04/21/2003 for BILL_TO
         --
         --
         --
         IF (p_dunning_level = 'CUSTOMER') THEN
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - partyid='||l_party_cust_id);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - partyname='||l_party_name);
             --
             l_source_object_type_code := 'PARTY';
             l_source_object_id := l_party_cust_id;
             l_source_object_name := l_party_name;
             --
             l_task_refer_rec.object_id := l_dunning_id;
             l_task_refer_rec.object_name := l_dunning_id;
             l_task_refer_rec.object_type_code := 'IEX_DUNNING';
             l_task_refer_tbl(1) := l_task_refer_rec;

         ELSIF (p_dunning_level = 'ACCOUNT') THEN
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - partyid='||l_party_cust_id);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - partyname='||l_party_name);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - accntnum='||l_account_num);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - accntid='||l_account_id);
             --
             l_source_object_type_code := 'IEX_ACCOUNT';
             l_source_object_id := l_account_id;
             l_source_object_name := l_account_num;
             --
             l_task_refer_rec.object_id := l_party_cust_id;
             l_task_refer_rec.object_name := l_party_name;
             l_task_refer_rec.object_type_code := 'PARTY';
             l_task_refer_tbl(1) := l_task_refer_rec;
             l_task_refer_rec.object_id := l_dunning_id;
             l_task_refer_rec.object_name := l_dunning_id;
             l_task_refer_rec.object_type_code := 'IEX_DUNNING';
             l_task_refer_tbl(2) := l_task_refer_rec;

         ELSIF (p_dunning_level = 'BILL_TO') THEN
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - partyid='||l_party_cust_id);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - partyname='||l_party_name);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - accntnum='||l_account_num);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - accntid='||l_account_id);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - customer_site_use_id='||l_customer_site_use_id);
             --
             l_source_object_type_code := 'IEX_BILLTO';
             l_source_object_id := l_customer_site_use_id;
             l_source_object_name := l_customer_site_use_id;
             --
             l_task_refer_rec.object_id := l_party_cust_id;
             l_task_refer_rec.object_name := l_party_name;
             l_task_refer_rec.object_type_code := 'PARTY';
             l_task_refer_tbl(1) := l_task_refer_rec;
             l_task_refer_rec.object_id := l_account_id;
             l_task_refer_rec.object_name := l_account_num;
             l_task_refer_rec.object_type_code := 'IEX_ACCOUNT';
             l_task_refer_tbl(2) := l_task_refer_rec;
             l_task_refer_rec.object_id := l_dunning_id;
             l_task_refer_rec.object_name := l_dunning_id;
             l_task_refer_rec.object_type_code := 'IEX_DUNNING';
             l_task_refer_tbl(3) := l_task_refer_rec;

         ELSE
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - partyid='||l_party_cust_id);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - partyname='||l_party_name);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - accntnum='||l_account_num);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - accntid='||l_account_id);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - customer_site_use_id='||l_customer_site_use_id);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - delid='||l_delinquency_id);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - trxnum='||l_trx_number);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - paymentshcheid='||l_payment_schedule_id);
             --
             l_source_object_type_code := 'IEX_DELINQUENCY';
             l_source_object_id := l_delinquency_id;
             l_source_object_name := l_delinquency_id;
             --
             l_task_refer_rec.object_id := l_party_cust_id;
             l_task_refer_rec.object_name := l_party_name;
             l_task_refer_rec.object_type_code := 'PARTY';
             l_task_refer_tbl(1) := l_task_refer_rec;
             l_task_refer_rec.object_id := l_account_id;
             l_task_refer_rec.object_name := l_account_num;
             l_task_refer_rec.object_type_code := 'IEX_ACCOUNT';
             l_task_refer_tbl(2) := l_task_refer_rec;
             l_task_refer_rec.object_id := l_customer_site_use_id;
             l_task_refer_rec.object_name := l_customer_site_use_id;
             l_task_refer_rec.object_type_code := 'IEX_BILLTO';
             l_task_refer_tbl(3) := l_task_refer_rec;
             l_task_refer_rec.object_id := l_payment_schedule_id;
             l_task_refer_rec.object_name := l_trx_number;
             l_task_refer_rec.object_type_code := 'IEX_INVOICES';
             l_task_refer_tbl(4) := l_task_refer_rec;
             l_task_refer_rec.object_id := l_dunning_id;
             l_task_refer_rec.object_name := l_dunning_id;
             l_task_refer_rec.object_type_code := 'IEX_DUNNING';
             l_task_refer_tbl(5) := l_task_refer_rec;

         END IF;

         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - refer_tbl_cnt='||l_task_refer_tbl.count);
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Create Task');

         JTF_TASKS_PUB.CREATE_TASK(
            p_api_version           => p_api_version,
            p_init_msg_list         => p_init_msg_list,
            p_commit                => p_commit,
            p_task_name             => l_task_name,
            p_task_type_name        => l_task_type,
            p_task_status_name      => l_task_status,
            p_owner_type_code       => l_owner_type_code,
            p_owner_id              => l_owner_id,
            p_description           => l_description,
            p_customer_id           => l_customer_id,
            p_source_object_type_code => l_source_object_type_code,
            p_source_object_id      => l_source_object_id,
            p_source_object_name    => l_source_object_name,
            p_task_assign_tbl       => l_miss_task_assign_tbl,
            p_task_depends_tbl      => l_miss_task_depends_tbl,
            p_task_rsrc_req_tbl     => l_miss_task_rsrc_req_tbl,
            p_task_refer_tbl        => l_task_refer_tbl,
            p_task_dates_tbl        => l_miss_task_dates_tbl,
            p_task_notes_tbl        => l_task_notes_tbl,
            p_task_recur_rec        => l_miss_task_recur_rec,
            p_task_contacts_tbl     => l_miss_task_contacts_tbl,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            x_task_id               => x_task_id );


     <<end_new_task>>
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Create Task');
        FND_MSG_PUB.Count_And_Get
        (  p_count          =>   x_msg_count,
           p_data           =>   x_msg_data
        );
        for i in 1..x_msg_count loop
           errmsg := FND_MSG_PUB.Get(p_msg_index => i,
                                     p_encoded => 'F');
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errmsg='||errmsg);
        end loop;

     ELSE
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Task-taskid='||x_task_id);

     END IF;

  END NEW_TASK;



/*========================================================================
 * Clchang updated 09/19/2002 for Bug 2242346
 *   to create a callback,
 *      we got resource_id from iex_delinquencyies before;
 *      now, we get resource_id based on which agent owns the least tasks
 *           in PARTY level;
 *
 *      Based on the party_id:
 *      1. taskcount:
 *         get the count(task) for the existing resources in jtf_tasks_vl;
 *      2. notaskcount:
 *         get all available resource_id for this party,
 *         and put count as 0 for each resource;
 *      3. if taskcount = 0,
 *            if notaskcount > 0,
 *               task the first resource_id based on notask_cursor;
 *            if notaskcount = 0,
 *               get the default resource_id;
 *      4. if taskcount > 0,
 *            get the resource_id which has the least tasks;
 *
 *========================================================================*/
--Removed all the code to replace the usage of this procedure with iex_utilities.get_assigned_collector
--for bug#5229763 schekuri 27-Jul-2006
--iex_utilities.get_assigned_collector uses hz_customer_profiles to get resource instead of as_accesses
PROCEDURE Get_Resource(p_api_version   IN  NUMBER,
                       p_commit        IN  VARCHAR2,
                       p_init_msg_list           IN VARCHAR2 ,
                       p_party_id      IN  NUMBER,
                       x_resource_id   OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count     OUT NOCOPY NUMBER,
                       x_msg_data      OUT NOCOPY VARCHAR2)
IS
 /* l_api_name                    VARCHAR2(50) ;
  l_RETURN_STATUS               VARCHAR2(30) ;
  l_MSG_COUNT                   NUMBER      ;
  l_MSG_DATA                    VARCHAR2(100) ;
  l_api_version                 NUMBER := 1.0;

  l_default_rs_id  number ;
  l_login  number;
  l_user   NUMBER ;

  CURSOR c_chk_party (p_party_id NUMBER) IS
      SELECT customer_id
        FROM jtf_tasks_vl
       WHERE customer_id = p_party_id;*/

  /*===================================================
  --  from iexvutlb.pls -  get_assign_resources procedure
  --  the resources should include manager;
  --------------------------------------------------------

  CURSOR c_get_person IS
    SELECT DISTINCT person_id, salesforce_id
    FROM  as_accesses acc, jtf_rs_resource_extns rs
    WHERE acc.customer_id = p_party_id and rs.resource_id = acc.salesforce_id
      and rs.user_id is not null;

  -- clchang 02/26/2003 updated
  -- updated the following cursors based on the above cursor;
  ----------------------------------------------------------------

  CURSOR c_party_resource_OLD(p_party_id NUMBER) IS
      SELECT DISTINCT rs.resource_id, 0
        FROM as_rpt_managers_v m, as_accesses acc, jtf_rs_resource_extns rs
       WHERE m.person_id = acc.person_id
         AND m.manager_person_id = rs.source_id
         AND acc.customer_id = p_party_id
         AND nvl(rs.end_date_active,sysdate) >= trunc(sysdate);

  CURSOR c_resource_task_count_OLD(p_party_id NUMBER) IS
      SELECT t.owner_id, count(t.owner_id)
        FROM jtf_tasks_vl t, jtf_task_statuses_vl s
       WHERE t.customer_id = p_party_id
         AND upper(t.owner_type_code) = 'RS_EMPLOYEE'
         AND t.task_name = 'Dunning Callback'
         AND t.task_status_id = s.task_status_id
         AND upper(s.name) = 'OPEN'
         AND t.owner_id in ( select DISTINCT rs.resource_id
                             from as_rpt_managers_v m, as_accesses acc,
                                  jtf_rs_resource_extns rs
                            where m.person_id = acc.person_id
                              and m.manager_person_id = rs.source_id
                              and acc.customer_id = p_party_id
                              AND nvl(rs.end_date_active,sysdate) >= trunc(sysdate) )
       GROUP BY t.owner_id;

  CURSOR c_resource_notask_count_OLD(p_party_id NUMBER) IS
      SELECT DISTINCT rs.resource_id, 0
        FROM as_rpt_managers_v m, as_accesses acc, jtf_rs_resource_extns rs
       WHERE m.person_id = acc.person_id
         AND m.manager_person_id = rs.source_id
         AND acc.customer_id = p_party_id
         AND nvl(rs.end_date_active,sysdate) >= trunc(sysdate)
         AND rs.resource_id not in ( select distinct t2.owner_id
                                       from jtf_tasks_vl t2,
                                            jtf_task_statuses_vl s2
                                      where t2.customer_id = p_party_id
                                       and upper(t2.owner_type_code) = 'RS_EMPLOYEE'
                                       AND t2.task_status_id = s2.task_status_id
                                       AND upper(s2.name) = 'OPEN'
                                       and t2.task_name = 'Dunning Callback');


  CURSOR c_resource_mintask(p_party_id NUMBER) IS
      SELECT t.owner_id  --, count(t.owner_id)
        FROM jtf_tasks_vl t, jtf_task_statuses_vl s
       WHERE t.customer_id = p_party_id
         AND upper(t.owner_type_code) = 'RS_EMPLOYEE'
         AND t.task_name = 'Dunning Callback'
         AND t.task_status_id = s.task_status_id
         AND upper(s.name) = 'OPEN'
       GROUP BY t.owner_id
      HAVING COUNT(t.owner_id) = (select min(count(t2.owner_id))
                                  from jtf_tasks_vl t2, jtf_task_statuses_vl s2
                                 WHERE t2.customer_id = p_party_id
                                   AND upper(t2.owner_type_code) = 'RS_EMPLOYEE'
                                   AND t2.task_name = 'Dunning Callback'
                                   AND t2.task_status_id = s2.task_status_id
                                   AND upper(s2.name) = 'OPEN'
                                 group by t2.owner_id );
  *=================================================== */

  /*CURSOR c_resource_mintask(p_party_id NUMBER) IS
      SELECT t.owner_id  --, count(t.owner_id)
        FROM jtf_tasks_vl t, jtf_task_statuses_vl s
       WHERE t.customer_id = p_party_id
         AND upper(t.owner_type_code) = 'RS_EMPLOYEE'
         AND t.task_name = 'Dunning Callback'
         AND t.task_status_id = s.task_status_id
         AND upper(s.name) = 'OPEN'
         AND t.owner_id in ( select DISTINCT rs.resource_id
                             from as_accesses acc,
                                  jtf_rs_resource_extns rs
                            where acc.customer_id = p_party_id
                              and rs.resource_id = acc.salesforce_id
                              and rs.category = 'EMPLOYEE'
                              and rs.user_id is not null
                              AND nvl(rs.end_date_active,sysdate) >= trunc(sysdate) )
       GROUP BY t.owner_id
      HAVING COUNT(t.owner_id) = (select min(count(t2.owner_id))
                                  from jtf_tasks_vl t2, jtf_task_statuses_vl s2
                                 WHERE t2.customer_id = p_party_id
                                   AND upper(t2.owner_type_code) = 'RS_EMPLOYEE'
                                   AND t2.task_name = 'Dunning Callback'
                                   AND t2.task_status_id = s2.task_status_id
                                   AND upper(s2.name) = 'OPEN'
                                   AND t2.owner_id in ( select DISTINCT rs.resource_id
                                       from as_accesses acc,
                                            jtf_rs_resource_extns rs
                                      where acc.customer_id = p_party_id
                                        and rs.resource_id = acc.salesforce_id
                                        and rs.category = 'EMPLOYEE'
                                        and rs.user_id is not null
                                        AND nvl(rs.end_date_active,sysdate) >= trunc(sysdate) )
                                 group by t2.owner_id );
  --
  --
  CURSOR c_resource_task_count(p_party_id NUMBER) IS
      SELECT t.owner_id,  count(t.owner_id)
        FROM jtf_tasks_vl t, jtf_task_statuses_vl s
       WHERE t.customer_id = p_party_id
         AND upper(t.owner_type_code) = 'RS_EMPLOYEE'
         AND t.task_name = 'Dunning Callback'
         AND t.task_status_id = s.task_status_id
         AND upper(s.name) = 'OPEN'
         AND t.owner_id in ( select DISTINCT rs.resource_id
                             from as_accesses acc,
                                  jtf_rs_resource_extns rs
                            where acc.customer_id = p_party_id
                              and rs.resource_id = acc.salesforce_id
                              and rs.category = 'EMPLOYEE'
                              and rs.user_id is not null
                              AND nvl(rs.end_date_active,sysdate) >= trunc(sysdate) )
       GROUP BY t.owner_id;
  --
  CURSOR c_resource_notask_count(p_party_id NUMBER) IS
      SELECT DISTINCT rs.resource_id, 0
        FROM as_accesses acc, jtf_rs_resource_extns rs
       WHERE acc.customer_id = p_party_id
         AND nvl(rs.end_date_active,sysdate) >= trunc(sysdate)
         AND rs.resource_id = acc.salesforce_id
         and rs.category = 'EMPLOYEE'
         AND rs.user_id is not null
         AND rs.resource_id not in ( select distinct t2.owner_id
                                       from jtf_tasks_vl t2,
                                            jtf_task_statuses_vl s2
                                      where t2.customer_id = p_party_id
                                       and upper(t2.owner_type_code) = 'RS_EMPLOYEE'
                                       AND t2.task_status_id = s2.task_status_id
                                       AND upper(s2.name) = 'OPEN'
                                       and t2.task_name = 'Dunning Callback');

  --
  TYPE number_tab_type IS TABLE OF NUMBER;
  l_p_rs_task_id_tab number_tab_type;
  l_p_rs_task_cnt_tab number_tab_type;
  l_p_rs_notask_id_tab number_tab_type;
  l_p_rs_notask_cnt_tab number_tab_type;

  l_errmsg varchar2(1000);
  i number := 0;
  l_party_id number := 0;
  l_task_count number := 0;
  l_notask_count number := 0;
  l_resource_id number := 0;*/

BEGIN

  /*l_api_name   := 'Get_Resource';
  l_default_rs_id  := fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE');
  l_login  := fnd_global.login_id;
  l_user   := FND_GLOBAL.USER_ID;

--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.LogMessage ('Get_Resource: ' || 'iexvdunb.pls:GetRS:starting');
  END IF;


  -- Standard Start of API savepoint
  SAVEPOINT GET_RESOURCE_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Api body
  --

  WriteLog('iexvdunb.pls:GetRS:party_id='||p_party_id);

  -- get all resources which have tasks for this party
  WriteLog('iexvdunb.pls:GetRS:Get Resources with tasks');
  OPEN c_resource_task_count(p_party_id);
  FETCH c_resource_task_count
   BULK COLLECT INTO l_p_rs_task_id_tab, l_p_rs_task_cnt_tab;
  CLOSE c_resource_task_count;
  WriteLog('iexvdunb.pls:GetRS:Close GetRs Task count');

  l_task_count := l_p_rs_task_id_tab.count;
  WriteLog('iexvdunb.pls:GetRS:RsTaskCount='||l_task_count);
   if (l_task_count > 0) then
       for i in 1..l_task_count loop
           WriteLog('iexvdunb.pls:GetRS:rs_task-i='||i);
           WriteLog('iexvdunb.pls:GetRS:id='||l_p_rs_task_id_tab(i));
           WriteLog('iexvdunb.pls:GetRS:id='||l_p_rs_task_cnt_tab(i));
       end loop;
   end if;

  --
  -- get all resources which have no task for this party
  WriteLog('iexvdunb.pls:GetRS:Get Resources withnot task');
  OPEN c_resource_notask_count(p_party_id);
  FETCH c_resource_notask_count
   BULK COLLECT INTO l_p_rs_notask_id_tab, l_p_rs_notask_cnt_tab;
  CLOSE c_resource_notask_count;
  WriteLog('iexvdunb.pls:GetRS:Close Get ResourceNoTask count');

  l_notask_count := l_p_rs_notask_id_tab.count;
  WriteLog('iexvdunb.pls:GetRS:RsNoTaskCount='||l_notask_count);

  --

  if (l_notask_count > 0 )  then
      -- it means there're some resources haven't been assigned tasks yet
      l_resource_id := l_p_rs_notask_id_tab(1);
      WriteLog('iexvdunb.pls:GetRS:resource_id='||l_resource_id);
      for i in 1..l_notask_count loop
         WriteLog('iexvdunb.pls:GetRS:rs_notask-i='||i);
         WriteLog('iexvdunb.pls:GetRS:id='||l_p_rs_notask_id_tab(i));
         WriteLog('iexvdunb.pls:GetRS:cnt='||l_p_rs_notask_cnt_tab(i));
      end loop;
  else
      -- l_notask_count = 0
      if (l_task_count > 0) then
          -- all resources have tasks
          -- get resource_id which has the least tasks based on query
          OPEN c_resource_mintask(p_party_id);
          FETCH c_resource_mintask into l_resource_id;
          CLOSE c_resource_mintask;
      else
          -- l_task_count = 0 and l_notask_count = 0
          -- no available resource based on party_resource relationship
          -- get the default resource
          l_resource_id := l_default_rs_id;
      end if;
      WriteLog('iexvdunb.pls:GetRS:resource_id='||l_resource_id);
  end if;

  --
  WriteLog('iexvdunb.pls:GetRS:END_RESOURCE');
  x_resource_id := l_resource_id;
  WriteLog('iexvdunb.pls:GetRS:x_resource_id='||x_resource_id);

  --
  -- End of API body
  --

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
     COMMIT WORK;
  END IF;

  WriteLog('iexvdunb.pls:GetRS:END');

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO GET_RESOURCE_PVT;
             x_return_status := FND_API.G_RET_STS_ERROR;
             l_errmsg := SQLERRM;
             WriteLog('iexvdunb:GetRs-G_EXC_EXCEPTION::' || l_errmsg);
             FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data
             );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO GET_RESOURCE_PVT;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             l_errmsg := SQLERRM;
             WriteLog('iexvdunb:GetRs-G_EXC_UNEXP_EXCEPTION:OTHERS:' || l_errmsg);
             FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data
             );

          WHEN OTHERS THEN
             ROLLBACK TO GET_RESOURCE_PVT;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             l_errmsg := SQLERRM;
             WriteLog('iexvdunb:GetRs-EXCEPTION:OTHERS:' || l_errmsg);
             FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data
             );*/
NULL;


END GET_RESOURCE;


FUNCTION Party_currency_code(p_party_id NUMBER) RETURN VARCHAR2
IS
  cursor c_amount (IN_ID number) is
     select ps.invoice_currency_code
       from ar_payment_schedules_all ps,
            iex_delinquencies del
      where ps.payment_schedule_id (+)= del.payment_schedule_id
        and del.party_cust_id = in_id;
  l_code VARCHAR2(15);
BEGIN
  WriteLog ('Party_currency_code: ' || 'currency_code');
  WriteLog ('Party_currency_code: ' || 'party_id='||p_party_id);
  open c_amount(p_party_id);
  fetch c_amount into l_code;
  if c_amount%found then
     WriteLog('Party_currency_code: ' || 'code='||l_code);
  else
     WriteLog ('Party_currency_code: ' || 'notfound');
    l_code := '';
  END if;
  close c_amount;

  RETURN l_code;

END party_currency_code;


FUNCTION acct_currency_code(p_account_id NUMBER) RETURN VARCHAR2
IS
  cursor c_amount (IN_ID number) is
     select ps.invoice_currency_code
       from ar_payment_schedules_all ps,
            --iex_delinquencies_all del
            iex_delinquencies del
      where ps.payment_schedule_id (+)= del.payment_schedule_id
        and del.cust_account_id = in_id;
  l_code VARCHAR2(15);
BEGIN
  WriteLog('acct_currency_code: ' || 'currency_code');
  WriteLog('acct_currency_code: ' || 'account_id='||p_account_id);
  open c_amount(p_account_id);
  fetch c_amount into l_code;
  if c_amount%found then
    WriteLog('acct_currency_code: ' || 'code='||l_code);
  else
    WriteLog ('acct_currency_code: ' || 'notfound');
    l_code := '';
  END if;
  close c_amount;

  RETURN l_code;

END acct_currency_code;


FUNCTION site_currency_code(p_customer_site_use_id NUMBER) RETURN VARCHAR2
IS
  cursor c_amount (IN_ID number) is
     select ps.invoice_currency_code
       from ar_payment_schedules_all ps,
            iex_delinquencies del
      where ps.payment_schedule_id (+)= del.payment_schedule_id
        and del.customer_site_use_id = in_id;

  l_code VARCHAR2(15);

BEGIN
  WriteLog ('site_currency_code: ' || 'currency_code');
  WriteLog ('site_currency_code: ' || 'customer_site_use_id='||p_customer_site_use_id);
  open c_amount(p_customer_site_use_id);
  fetch c_amount into l_code;
  if c_amount%found then
     WriteLog ('site_currency_code: ' || 'code='||l_code);
  else
     WriteLog('site_currency_code: ' || 'notfound');
     l_code := '';
  END if;
  close c_amount;

  RETURN l_code;

END site_currency_code;


FUNCTION party_amount_due_remaining(p_party_id NUMBER) RETURN NUMBER
IS
  cursor c_amount (IN_ID number) is
     select sum(ps.acctd_amount_due_remaining)
       from ar_payment_schedules_all ps,
            iex_delinquencies del
      where ps.payment_schedule_id (+)= del.payment_schedule_id
        and del.party_cust_id = in_id;
  l_sum number;
BEGIN
  WriteLog('party_amount_due_remaining: ' || 'party_amount_due_remainging');
  WriteLog('party_amount_due_remaining: ' || 'party_id='||p_party_id);
  open c_amount(p_party_id);
  fetch c_amount into l_sum;
  if c_amount%found then
    WriteLog('party_amount_due_remaining: ' || 'sum='||l_sum);
  else
    WriteLog('party_amount_due_remaining: ' || 'notfound');
    l_sum := 0;
  END if;
  close c_amount;

  RETURN l_sum;

END party_amount_due_remaining;


FUNCTION acct_amount_due_remaining(p_account_id NUMBER) RETURN NUMBER
IS
  cursor c_amount (IN_ID number) is
     select sum(ps.acctd_amount_due_remaining)
       from ar_payment_schedules_all ps,
            --iex_delinquencies_all del
            iex_delinquencies del
      where ps.payment_schedule_id (+)= del.payment_schedule_id
        and del.cust_account_id = in_id;
  l_sum number;
BEGIN
  WriteLog('acct_amount_due_remaining: ' || 'acct_amount_due_remainging');
  WriteLog('acct_amount_due_remaining: ' || 'account_id='||p_account_id);
  open c_amount(p_account_id);
  fetch c_amount into l_sum;
  if c_amount%found then
     WriteLog ('acct_amount_due_remaining: ' || 'sum='||l_sum);
  else
     WriteLog ('acct_amount_due_remaining: ' || 'notfound');
    l_sum := 0;
  END if;
  close c_amount;

  RETURN l_sum;

END acct_amount_due_remaining;


FUNCTION site_amount_due_remaining(p_customer_site_use_id NUMBER) RETURN NUMBER
IS
  cursor c_amount (IN_ID number) is
     select sum(ps.acctd_amount_due_remaining)
       from ar_payment_schedules_all ps,
            iex_delinquencies del
      where ps.payment_schedule_id (+)= del.payment_schedule_id
        and del.customer_site_use_id = in_id;
  l_sum number;
--
BEGIN
  --
  WriteLog ('site_amount_due_remaining: ' || 'site_amount_due_remainging');
  WriteLog('site_amount_due_remaining: ' || 'customer_site_use_id='||p_customer_site_use_id);
  --
  open c_amount(p_customer_site_use_id);
  fetch c_amount into l_sum;
  if c_amount%found then
     WriteLog ('site_amount_due_remaining: ' || 'sum='||l_sum);
  else
     WriteLog ('site_amount_due_remaining: ' || 'notfound');
     l_sum := 0;
  END if;
  close c_amount;
  --
  RETURN l_sum;

END site_amount_due_remaining;

--Start adding for bug 9503251 gnramasa 2nd Apr 2010
FUNCTION staged_dunn_amt_due_remaining(p_dunning_id number) RETURN NUMBER
IS
  cursor c_amount (dunn_id number) is
     select sum(ps.acctd_amount_due_remaining)
       from ar_payment_schedules_all ps,
            iex_dunning_transactions dtrx
      where ps.payment_schedule_id = dtrx.payment_schedule_id
        and dtrx.dunning_id = dunn_id;
  l_sum number;
BEGIN
  WriteLog('staged_dunn_amt_due_remaining: Start');
  WriteLog('staged_dunn_amt_due_remaining: p_dunning_id='||p_dunning_id);
  open c_amount(p_dunning_id);
  fetch c_amount into l_sum;
  if c_amount%found then
    WriteLog('acct_amount_due_remaining: sum='||l_sum);
  else
    WriteLog('acct_amount_due_remaining: notfound');
    l_sum := 0;
  END if;
  close c_amount;

  RETURN l_sum;

END staged_dunn_amt_due_remaining;
--End adding for bug 9503251 gnramasa 2nd Apr 2010

FUNCTION get_party_id(p_account_id NUMBER) RETURN NUMBER
IS
  cursor c_party (IN_ID number) is
     select del.party_cust_id
       from iex_delinquencies del
      where del.cust_account_id = in_id;
  l_party number;
BEGIN
  WriteLog('get_party_id');
  WriteLog('get_party_id: ' || 'account_id='||p_account_id);
  open c_party(p_account_id);
  fetch c_party into l_party;
  if c_party%found then
     WriteLog ('get_party_id: ' || 'party='||l_party);
  else
     WriteLog ('get_party_id: ' || 'notfound');
    l_party := 0;
  END if;
  close c_party;

  RETURN l_party;

END get_party_id;

--Start adding for bug 8489610 by gnramasa 14-May-09
PROCEDURE PRINT_CLOB
  (
    lob_loc IN CLOB)
            IS
  /*-----------------------------------------------------------------------+
  | Local Variable Declarations and initializations                       |
  +-----------------------------------------------------------------------*/
  l_api_name    CONSTANT VARCHAR2(30) := 'PRINT_CLOB';
  l_api_version CONSTANT NUMBER       := 1.0;
  c_endline     CONSTANT VARCHAR2 (1) := '
';
  c_endline_len CONSTANT NUMBER       := LENGTH (c_endline);
  l_start       NUMBER                := 1;
  l_end         NUMBER;
  l_one_line    VARCHAR2 (7000);
  l_charset     VARCHAR2(100);
  /*-----------------------------------------------------------------------+
  | Cursor Declarations                                                   |
  +-----------------------------------------------------------------------*/
BEGIN
  -- LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
  LOOP
    l_end := DBMS_LOB.INSTR (lob_loc => lob_loc, pattern => c_endline, offset => l_start, nth => 1 );
    --FND_FILE.put_line( FND_FILE.LOG,'l_end-->'||l_end);
    IF (NVL (l_end, 0) < 1) THEN
      EXIT;
    END IF;
    l_one_line := DBMS_LOB.SUBSTR (lob_loc => lob_loc, amount => l_end - l_start, offset => l_start );
    --FND_FILE.put_line( FND_FILE.LOG,'l_one_line-->'||l_one_line);
    --FND_FILE.put_line( FND_FILE.LOG,'c_endline_len-->'||c_endline_len);
    l_start := l_end + c_endline_len;
    --FND_FILE.put_line( FND_FILE.LOG,'l_start-->'||l_start);
    --FND_FILE.put_line( FND_FILE.LOG,'32');
    Fnd_File.PUT_line(Fnd_File.OUTPUT,l_one_line);
  END LOOP;
END PRINT_CLOB;

/*========================================================================+
   Function which replaces the special characters in the strings to form
   a valid XML string
 +========================================================================*/
FUNCTION format_string(p_string varchar2) return varchar2 IS

  l_string varchar2(2000);
BEGIN

    l_string := replace(p_string,'&','&'||'amp;');
    l_string := replace(l_string,'<','&'||'lt;');
    l_string := replace(l_string,'>','&'||'gt;');

    RETURN l_string;

END format_string;

Procedure gen_xml_data_dunning (p_request_id			IN  NUMBER,
                                p_running_level			IN  VARCHAR2,
				p_dunning_plan_id		IN  NUMBER,
				p_dunning_mode			IN  VARCHAR2,     -- added by gnramasa for bug 8489610 28-May-09
	                        p_confirmation_mode		IN  VARCHAR2,     -- added by gnramasa for bug 8489610 28-May-09
				p_process_err_rec_only          IN  VARCHAR2,
				p_no_of_rec_prc_bylastrun	IN  NUMBER,
				p_no_of_succ_rec_bylastrun	IN  NUMBER,
				p_no_of_fail_rec_bylastrun	IN  NUMBER,
				x_no_of_rec_prc			OUT NOCOPY NUMBER,
				x_no_of_succ_rec		OUT NOCOPY NUMBER,
				x_no_of_fail_rec		OUT NOCOPY NUMBER)
is
   l_api_version           CONSTANT NUMBER := 1.0;
   ctx                     DBMS_XMLQUERY.ctxType;
   result                  CLOB;
   qryCtx                  DBMS_XMLGEN.ctxHandle;
   l_result                CLOB;
   tempResult              CLOB;
   l_version               varchar2(20);
   l_compatibility         varchar2(20);
   l_suffix                varchar2(2);
   l_majorVersion          number;
   l_resultOffset          number;
   l_xml_header            varchar2(4000);
   l_xml_header_length     number;
   l_errNo                 NUMBER;
   l_errMsg                VARCHAR2(200);
   queryCtx                DBMS_XMLquery.ctxType;
   l_xml_query             VARCHAR2(32767);
   TYPE ref_cur IS REF CURSOR;
   l_xml_stmt              ref_cur;
   l_rows_processed        NUMBER;
   l_new_line              VARCHAR2(1);
   l_close_tag             VARCHAR2(100);
   l_no_of_rec_prc	   number;
   l_no_of_succ_rec        number;
   l_no_of_fail_rec        number;

   cursor c_calculate_no_rec (p_req_id number) is
   SELECT
	count(*) no_of_rec_processed,
	sum(decode(delivery_status,NULL,1,0)) no_of_success_records,
	sum(decode(delivery_status,NULL,0,1)) no_of_failure_records
   FROM iex_dunnings id
   WHERE id.request_id = p_req_id
        AND id.object_type <> 'IEX_INVOICES'
	AND id.dunning_id =  (SELECT MAX(dunning_id)
			      FROM iex_dunnings d
			      WHERE d.dunning_object_id = id.dunning_object_id
				   AND d.dunning_level = id.dunning_level
				   AND d.request_id = id.request_id
				   AND d.object_type <> 'IEX_INVOICES');

 l_query_party varchar2(11000) :=
'select ' ||
'id.dunning_object_id PARTY_ID, ' ||
'p.party_name PARTY_NAME, ' ||
'id.dunning_object_id DUNNING_OBJECT_ID, ' ||
'id.xml_template_id TEMPLATE_ID,  ' ||
'xtvl.template_name TEMPLATE_NAME, ' ||
'id.delivery_status ERROR, ' ||
'fnd_message.get_string(''IEX'',id.delivery_status) ERROR_DESC, ' ||
'iex_utilities.get_lookup_meaning(''IEX_FULFILLMENT_SEND_METHOD'',id.dunning_method) DUNNING_METHOD, '||
'ixr.destination DESTINATION, ' ||
'decode(id.DUNNING_MODE, ''DRAFT'', iex_utilities.get_lookup_meaning(''IEX_CONFIRMATION_MODE'', nvl(id.CONFIRMATION_MODE,''DRAFT'')),iex_utilities.get_lookup_meaning(''IEX_CONFIRMATION_MODE'',''CONFIRMED'')) CONFIRMATION_STATUS '||
--'ixr.xml_request_id REQUEST_ID ' ||
--' ''http://techcm.us.oracle.com:8000/OA_HTML/IEXDUNCPRRedirect.jsp?RequestId=''  || ixr.xml_request_id DOWNLOAD_URL ' ||
'from iex_xml_request_histories ixr, ' ||
'hz_parties p, ' ||
'iex_dunnings id, ' ||
'XDO_TEMPLATES_B xtb, ' ||
'XDO_TEMPLATES_TL xtvl ' ||
'where id.dunning_object_id = p.party_id ' ||
'and ixr.xml_request_id (+) = id.xml_request_id ' ||
'and id.request_id = :l_request_id ' ||
'and xtb.template_code=xtvl.template_code ' ||
'and xtb.template_id = id.xml_template_id ' ||
'and xtvl.language=userenv(''LANG'') ' ||
'AND id.object_type <> ''IEX_INVOICES'' ' ||
'and id.dunning_id = (select max(dunning_id) from iex_dunnings d ' ||
                     ' where d.dunning_object_id = id.dunning_object_id and d.dunning_level=id.dunning_level and d.request_id = id.request_id ' ||
		     ' AND d.object_type <> ''IEX_INVOICES'' ) ' ||
'order by p.party_name' ;

l_query_account varchar2(11000) :=
'select ' ||
'p.party_id PARTY_ID, ' ||
'p.party_name PARTY_NAME, ' ||
'hcu.account_number ACCOUNT_NUMBER, ' ||
'id.dunning_object_id DUNNING_OBJECT_ID, ' ||
'id.xml_template_id TEMPLATE_ID,  ' ||
'xtvl.template_name TEMPLATE_NAME,  ' ||
'id.delivery_status ERROR, ' ||
'fnd_message.get_string(''IEX'',id.delivery_status) ERROR_DESC, ' ||
'iex_utilities.get_lookup_meaning(''IEX_FULFILLMENT_SEND_METHOD'',id.dunning_method) DUNNING_METHOD, '||
'ixr.destination DESTINATION, ' ||
'decode(id.DUNNING_MODE, ''DRAFT'', iex_utilities.get_lookup_meaning(''IEX_CONFIRMATION_MODE'', nvl(id.CONFIRMATION_MODE,''DRAFT'')),iex_utilities.get_lookup_meaning(''IEX_CONFIRMATION_MODE'',''CONFIRMED'')) CONFIRMATION_STATUS '||
--'ixr.xml_request_id REQUEST_ID ' ||
--' ''http://techcm.us.oracle.com:8000/OA_HTML/IEXDUNCPRRedirect.jsp?RequestId=''  || ixr.xml_request_id DOWNLOAD_URL ' ||
'from iex_xml_request_histories ixr, ' ||
'hz_parties p, ' ||
'hz_cust_accounts hcu, ' ||
'iex_dunnings id, ' ||
'XDO_TEMPLATES_B xtb, ' ||
'XDO_TEMPLATES_TL xtvl ' ||
'where id.dunning_object_id = hcu.cust_account_id ' ||
'and hcu.party_id = p.party_id ' ||
'and ixr.xml_request_id (+) = id.xml_request_id  ' ||
'and id.request_id = :l_request_id ' ||
'and xtb.template_code=xtvl.template_code ' ||
'and xtb.template_id = id.xml_template_id ' ||
'and xtvl.language=userenv(''LANG'') ' ||
'AND id.object_type <> ''IEX_INVOICES'' ' ||
'and id.dunning_id = (select max(dunning_id) from iex_dunnings d ' ||
                     ' where d.dunning_object_id = id.dunning_object_id and d.dunning_level=id.dunning_level and d.request_id = id.request_id ' ||
		     ' AND d.object_type <> ''IEX_INVOICES'' ) ' ||
'order by p.party_name' ;

l_query_bill_to varchar2(11000) :=
'select ' ||
'p.party_id PARTY_ID, ' ||
'p.party_name PARTY_NAME, ' ||
'hcu.account_number ACCOUNT_NUMBER, ' ||
'site_uses.location LOCATION, ' ||
'id.dunning_object_id DUNNING_OBJECT_ID, ' ||
'id.xml_template_id TEMPLATE_ID,  ' ||
'xtvl.template_name TEMPLATE_NAME,  ' ||
'id.delivery_status ERROR, ' ||
'fnd_message.get_string(''IEX'',id.delivery_status) ERROR_DESC, ' ||
'iex_utilities.get_lookup_meaning(''IEX_FULFILLMENT_SEND_METHOD'',id.dunning_method) DUNNING_METHOD, '||
'ixr.destination DESTINATION, ' ||
'decode(id.DUNNING_MODE, ''DRAFT'', iex_utilities.get_lookup_meaning(''IEX_CONFIRMATION_MODE'', nvl(id.CONFIRMATION_MODE,''DRAFT'')),iex_utilities.get_lookup_meaning(''IEX_CONFIRMATION_MODE'',''CONFIRMED'')) CONFIRMATION_STATUS '||
--'ixr.xml_request_id REQUEST_ID ' ||
--' ''http://techcm.us.oracle.com:8000/OA_HTML/IEXDUNCPRRedirect.jsp?RequestId=''  || ixr.xml_request_id DOWNLOAD_URL ' ||
'from iex_xml_request_histories ixr, ' ||
'hz_parties p, ' ||
'hz_cust_accounts hcu,' ||
'hz_cust_acct_sites_all acct_sites, ' ||
'hz_cust_site_uses_all site_uses, ' ||
'iex_dunnings id, ' ||
'XDO_TEMPLATES_B xtb, ' ||
'XDO_TEMPLATES_TL xtvl ' ||
'where id.dunning_object_id = site_uses.site_use_id ' ||
'and acct_sites.cust_acct_site_id = site_uses.cust_acct_site_id ' ||
'and hcu.cust_account_id = acct_sites.cust_account_id ' ||
'and p.party_id = hcu.party_id ' ||
'and ixr.xml_request_id (+) = id.xml_request_id ' ||
'and id.request_id = :l_request_id ' ||
'and xtb.template_code=xtvl.template_code ' ||
'and xtb.template_id = id.xml_template_id ' ||
'and xtvl.language=userenv(''LANG'') ' ||
'AND id.object_type <> ''IEX_INVOICES'' ' ||
--'and nvl(id.confirmation_mode,''CONFIRMED'') <> ''REJECTED'' ' ||
'and id.dunning_id = (select max(dunning_id) from iex_dunnings d ' ||
                     ' where d.dunning_object_id = id.dunning_object_id and d.dunning_level=id.dunning_level and d.request_id = id.request_id ' ||
		     ' AND d.object_type <> ''IEX_INVOICES'' ) ' ||
'order by p.party_name' ;

l_query_delinquency varchar2(11000) :=
'select ' ||
'id.dunning_object_id PARTY_ID, ' ||
'p.party_name PARTY_NAME, ' ||
'aps.trx_number TRANSACTION_NUMBER, ' ||
'id.dunning_object_id DUNNING_OBJECT_ID, ' ||
'id.xml_template_id TEMPLATE_ID,  ' ||
'xtvl.template_name TEMPLATE_NAME,  ' ||
'id.delivery_status ERROR, ' ||
'fnd_message.get_string(''IEX'',id.delivery_status) ERROR_DESC, ' ||
'iex_utilities.get_lookup_meaning(''IEX_FULFILLMENT_SEND_METHOD'',id.dunning_method) DUNNING_METHOD, '||
'ixr.destination DESTINATION, ' ||
'decode(id.DUNNING_MODE, ''DRAFT'', iex_utilities.get_lookup_meaning(''IEX_CONFIRMATION_MODE'', nvl(id.CONFIRMATION_MODE,''DRAFT'')),iex_utilities.get_lookup_meaning(''IEX_CONFIRMATION_MODE'',''CONFIRMED'')) CONFIRMATION_STATUS '||
--'ixr.xml_request_id REQUEST_ID ' ||
--' ''http://techcm.us.oracle.com:8000/OA_HTML/IEXDUNCPRRedirect.jsp?RequestId=''  || ixr.xml_request_id DOWNLOAD_URL ' ||
'from iex_xml_request_histories ixr, ' ||
'hz_parties p, ' ||
'iex_dunnings id, ' ||
'XDO_TEMPLATES_B xtb, ' ||
'XDO_TEMPLATES_TL xtvl, ' ||
'iex_delinquencies_all del, ' ||
'ar_payment_schedules_all aps ' ||
'where id.dunning_object_id = del.delinquency_id ' ||
'and del.payment_Schedule_id = aps.payment_Schedule_id ' ||
'and del.party_cust_id = p.party_id ' ||
'and ixr.xml_request_id (+) = id.xml_request_id  ' ||
'and id.request_id = :l_request_id ' ||
'and xtb.template_code=xtvl.template_code ' ||
'and xtb.template_id = id.xml_template_id ' ||
'and xtvl.language=userenv(''LANG'') ' ||
'AND id.object_type <> ''IEX_INVOICES'' ' ||
'and id.dunning_id = (select max(dunning_id) from iex_dunnings d ' ||
                     ' where d.dunning_object_id = id.dunning_object_id and d.dunning_level=id.dunning_level and d.request_id = id.request_id ' ||
		     ' AND d.object_type <> ''IEX_INVOICES'' ) ' ||
'order by p.party_name' ;

l_report_date   varchar2(30);
l_dunning_plan  iex_dunning_plans_vl.name%type;
l_req_id	number;

begin
FND_FILE.put_line( FND_FILE.LOG,'XML generation starts');
l_req_id := p_request_id;

select to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS')
into l_report_date
from dual;

select name
into l_dunning_plan
from iex_dunning_plans_vl
where dunning_plan_id= p_dunning_plan_id;

open c_calculate_no_rec (l_req_id);
fetch c_calculate_no_rec into l_no_of_rec_prc, l_no_of_succ_rec, l_no_of_fail_rec;
close c_calculate_no_rec;


   if p_running_level = 'PARTY' then
	ctx := DBMS_XMLQUERY.newContext(l_query_party);
	FND_FILE.put_line( FND_FILE.LOG,'l_query_party ==> ' || l_query_party);
   elsif p_running_level = 'ACCOUNT' then
	ctx := DBMS_XMLQUERY.newContext(l_query_account);
	FND_FILE.put_line( FND_FILE.LOG,'l_query_party ==> ' || l_query_account);
   elsif p_running_level = 'BILL_TO' then
	ctx := DBMS_XMLQUERY.newContext(l_query_bill_to);
	FND_FILE.put_line( FND_FILE.LOG,'l_query_party ==> ' || l_query_bill_to);
   elsif p_running_level = 'DELINQUENCY' then
	ctx := DBMS_XMLQUERY.newContext(l_query_delinquency);
	FND_FILE.put_line( FND_FILE.LOG,'l_query_party ==> ' || l_query_delinquency);
   else
	ctx := DBMS_XMLQUERY.newContext(l_query_party);
	FND_FILE.put_line( FND_FILE.LOG,'l_query_party ==> ' || l_query_party);
   end if;



   DBMS_XMLQuery.setRaiseNoRowsException(ctx,TRUE);
   -- Bind Mandatory Variables
   DBMS_XMLQuery.setBindValue(ctx, 'l_request_id', l_req_id);

   --get the result

    BEGIN
        l_result := DBMS_XMLQUERY.getXML(ctx);
	DBMS_XMLQuery.closeContext(ctx);
	l_rows_processed := 1;
     EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.put_line( FND_FILE.LOG,'In excepition, Error is: '||sqlerrm);
        DBMS_XMLQuery.getExceptionContent(ctx,l_errNo,l_errMsg);
        IF l_errNo = 1403 THEN
	   FND_FILE.put_line( FND_FILE.LOG,'Query not returned any rows');
           l_rows_processed := 0;
        END IF;
        DBMS_XMLQuery.closeContext(ctx);
     END;

    IF l_rows_processed <> 0 THEN
         l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
    ELSE
         l_resultOffset   := 0;
    END IF;



      FND_FILE.put_line( FND_FILE.LOG,'Start constructing the XML Header');
      l_new_line := '
';
      /*Get the special characters replaced */
      l_report_date      := format_string(l_report_date);
      l_dunning_plan      := format_string(l_dunning_plan);

      /* Prepare the tag for the report heading */
   l_xml_header     := '<?xml version="1.0" encoding="UTF-8"?>';
   l_xml_header     := l_xml_header ||l_new_line||'<DUNNINGSET>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORT_DATE>'||l_report_date||'</REPORT_DATE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <DUNNING_LEVEL>'||p_running_level||'</DUNNING_LEVEL>';
   l_xml_header     := l_xml_header ||l_new_line||'        <DUNNING_PLAN>' ||l_dunning_plan ||'</DUNNING_PLAN>';
   l_xml_header     := l_xml_header ||l_new_line||'        <DUNNING_MODE>' ||iex_utilities.get_lookup_meaning('IEX_DUNNING_MODE',p_dunning_mode) ||'</DUNNING_MODE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CONC_REQUEST_ID>' || p_request_id ||'</CONC_REQUEST_ID>';
   l_xml_header     := l_xml_header ||l_new_line||'        <NO_OF_REC_PROCESSED>' || l_no_of_rec_prc ||'</NO_OF_REC_PROCESSED>';
   l_xml_header     := l_xml_header ||l_new_line||'        <NO_OF_SUCCESS_REC>' || l_no_of_succ_rec ||'</NO_OF_SUCCESS_REC>';
   l_xml_header     := l_xml_header ||l_new_line||'        <NO_OF_FAILURE_REC>' || l_no_of_fail_rec ||'</NO_OF_FAILURE_REC>';
   l_xml_header     := l_xml_header ||l_new_line||'        <IN_ERROR_MODE>' || p_process_err_rec_only ||'</IN_ERROR_MODE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <NO_OF_ERRORED_REC_PROCESSED>' || p_no_of_rec_prc_bylastrun ||'</NO_OF_ERRORED_REC_PROCESSED>';
   l_xml_header     := l_xml_header ||l_new_line||'        <NO_OF_SUCCESS_REC_BY_LASTRUN>' || p_no_of_succ_rec_bylastrun ||'</NO_OF_SUCCESS_REC_BY_LASTRUN>';
   l_xml_header     := l_xml_header ||l_new_line||'        <NO_OF_FAILURE_REC_BY_LASTRUN>' || p_no_of_fail_rec_bylastrun ||'</NO_OF_FAILURE_REC_BY_LASTRUN>';
   l_close_tag      := l_new_line||'</DUNNINGSET>'||l_new_line;
   l_xml_header_length := length(l_xml_header);
   tempResult := l_xml_header;
   FND_FILE.put_line( FND_FILE.LOG,'Constructing the XML Header is success');

   IF l_rows_processed <> 0 THEN
      FND_FILE.put_line( FND_FILE.LOG,'Start constructing the XML body');
      dbms_lob.copy(tempResult,l_result
                  ,dbms_lob.getlength(l_result)-l_resultOffset
                   ,l_xml_header_length,l_resultOffset);
   ELSE
      dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
      dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
      dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
   END IF;

  FND_FILE.put_line( FND_FILE.LOG,'Constructing the XML Body is success');
  dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);
  FND_FILE.put_line( FND_FILE.LOG,'Appended close tag to XML data');
 -- Fnd_File.PUT_line(Fnd_File.OUTPUT,tempResult);
  print_clob(lob_loc => tempResult);
  FND_FILE.put_line( FND_FILE.LOG,'XML generation is success');

  x_no_of_rec_prc := l_no_of_rec_prc;
  x_no_of_succ_rec := l_no_of_succ_rec;
  x_no_of_fail_rec := l_no_of_fail_rec;

EXCEPTION
   WHEN OTHERS THEN
   FND_FILE.put_line( FND_FILE.LOG,'err'||sqlerrm);
   RAISE;
END gen_xml_data_dunning;
--End adding for bug 8489610 by gnramasa 14-May-09

Procedure stage_dunning_inv_copy
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_no_of_workers           IN NUMBER,
	    p_process_err_rec_only    IN VARCHAR2,
            p_request_id	      IN NUMBER,
	    p_dunning_mode	      IN VARCHAR2,
	    p_confirmation_mode	      IN VARCHAR2,
	    p_running_level           IN VARCHAR2,
	    p_correspondence_date     IN DATE,
	    p_max_dunning_trx_id      IN NUMBER,
	    x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
l_object_type		varchar2(20);
l_object_id		number;
l_send_method		varchar2(10);
l_fulfillment_bind_tbl	IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;
l_request_id		number := 0;
l_source_id		number;
l_template_id		number;
l_cust_trx_id		number;
l_party_type		varchar2(20);
l_party_id		number;
l_contact_destination	varchar2(240);
l_contact_party_id	number;
l_location_id		number;
l_msg_count		number;
l_msg_data		varchar2(200);
l_return_status		varchar2(10);
l_key_id		number;
l_bind_var		varchar2(50);
n_key_id		varchar2(2000);
l_trx_type		varchar2(20);
n_bind_var		varchar2(50);
l_api_name		varchar2(50) := 'stage_dunning_inv_copy';
Type refCur             is Ref Cursor;
sql_cur1                refCur;
vPLSQL1                 VARCHAR2(2000);

/*
cursor c_get_invoice_ct (p_conc_req_id number) is
      select idt.cust_trx_id,
             dunn.object_id,
             dunn.object_type
      from iex_dunning_transactions idt,
           iex_dunnings dunn,
	   iex_ag_dn_xref xref
      where idt.dunning_id = dunn.dunning_id
      and dunn.request_id = p_conc_req_id
      and dunn.ag_dn_xref_id = xref.ag_dn_xref_id
      and xref.invoice_copies = 'Y'
      and idt.cust_trx_id is not null;
      --and not exists (select 1 from iex_xml_request_histories xml
      --               where xml.xml_request_id = dunn.xml_request_id);
*/

begin
WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');
l_template_id := fnd_profile.value('IEX_INVOICE_FULFILLMENT_TEMPLATE');
--l_send_method  := NVL(fnd_profile.value('IEX_FULFILLMENT_SEND_METHOD'),'EMAIL');
WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Template ID for Invoice : '||l_template_id);
--WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Send method : '||l_send_method);

vPLSQL1 := 'select idt.cust_trx_id, ' ||
    '         dunn.object_id, ' ||
    '         dunn.object_type, ' ||
    '         dunn.dunning_method ' ||
    '  from iex_dunning_transactions idt,  ' ||
    '       iex_dunnings dunn, ' ||
    '	   iex_ag_dn_xref xref,  ' ||
    '      ra_customer_trx trx ' ||
    '  where idt.dunning_id = dunn.dunning_id ' ||
    '  and dunn.request_id = :p_conc_req_id  ' ||
    '  and dunn.ag_dn_xref_id = xref.ag_dn_xref_id  ' ||
    '  and xref.invoice_copies = ''Y''  ' ||
    '  and idt.cust_trx_id is not null ' ||
    '  and trx.customer_trx_id = idt.cust_trx_id ' ||
    '  and trx.printing_option = ''PRI'' ' ;

if p_process_err_rec_only = 'Y' then
	vPLSQL1 := vPLSQL1 || ' and idt.dunning_trx_id > :p_max_dunn_trx_id ' ;
end if;

WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - vPLSQL1 ' || vPLSQL1);
if p_process_err_rec_only = 'Y' then
	open sql_cur1 for vPLSQL1 using p_request_id, p_max_dunning_trx_id;
else
	open sql_cur1 for vPLSQL1 using p_request_id;
end if;

LOOP
	fetch sql_cur1 into l_cust_trx_id,l_object_id,l_object_type,l_send_method;
	exit when sql_cur1%NOTFOUND;

	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_cust_trx_id : '||l_cust_trx_id);
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_object_id : '||l_object_id);
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_object_type : '||l_object_type);
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Send method : '||l_send_method);

	if(l_cust_trx_id is not null ) then

		l_key_id     := l_cust_trx_id;
		l_party_type := l_object_type;

		If l_object_type = 'IEX_BILLTO' then
			l_source_id := l_object_id;
			SELECT  ca.party_id into l_party_id
			FROM hz_cust_site_uses site_uses,
			     hz_cust_acct_sites acct_sites,
			     hz_cust_accounts ca
			WHERE site_uses.site_use_id = l_object_id
			AND acct_sites.cust_acct_site_id = site_uses.cust_acct_site_id
			AND ca.cust_account_id = acct_sites.cust_account_id;

		Elsif l_object_type = 'IEX_DELINQUENCY' then
			l_source_id := l_object_id;
			SELECT  ca.PARTY_CUST_ID into l_party_id
			FROM IEX_DELINQUENCIES ca
			WHERE ca.DELINQUENCY_ID = l_object_id;

		Elsif l_object_type = 'IEX_ACCOUNT' then
			l_source_id := l_object_id;
			SELECT ca.party_id into l_party_id
			FROM hz_cust_accounts ca
			WHERE ca.cust_account_id = l_object_id;

		Elsif l_object_type = 'PARTY' then
			l_party_id := l_object_id;
			l_source_id := l_object_id;
		End if;
		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_party_id : '||l_party_id);
		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_key IDs for Invoice....'||l_key_id);
		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_party IDss for Invoice....'||l_party_id);

		n_key_id        := l_key_id||','||l_party_id;
		l_bind_var      := 'invoice_id';
		n_bind_var      := 'invoice_id,party_id';
		l_object_type   := 'IEX_INVOICES';
		l_trx_type      := 'INVOICES';

		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' n_key IDss for Invoice....'||n_key_id);

		l_fulfillment_bind_tbl(1).key_name  := l_bind_var;
		l_fulfillment_bind_tbl(1).key_type  := 'NUMBER';
		l_fulfillment_bind_tbl(1).key_value := to_char(l_key_id);

		l_fulfillment_bind_tbl(2).key_name  := 'party_id';
		l_fulfillment_bind_tbl(2).key_type  := 'NUMBER';
		l_fulfillment_bind_tbl(2).key_value := to_char(l_party_id);

		begin
			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' getting primary address');
			select location_id into l_location_id
			from ast_locations_v
			where party_id = l_party_id
			AND primary_flag = 'Y';

			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' primart address location ID: ' || l_location_id);

			-- check if location exists and add it to bind table
			if l_location_id is not null then
			  l_fulfillment_bind_tbl(3).key_value := l_location_id;
			  l_fulfillment_bind_tbl(3).key_name  := 'location_id';
			  l_fulfillment_bind_tbl(3).key_type  := 'NUMBER';
			end if;
		exception
			when no_data_found then
				WriteLog(G_PKG_NAME || ' ' || l_api_name || sqlerrm);
			when others then
				WriteLog(G_PKG_NAME || ' ' || l_api_name || sqlerrm);
		end;

		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' calling iex_dunning_pvt.send_xml');

		send_xml(
		p_api_version             => 1.0,
		p_init_msg_list           => 'T',
		p_commit                  => 'T',
		p_resend                  => 'N',
		p_request_id              => null,
		p_FULFILLMENT_BIND_TBL    => l_fulfillment_bind_tbl,
		p_template_id             => l_template_id,
		p_method                  => l_send_method,
		p_user_id                 => NULL,
		p_email                   => NULL,
		p_party_id                => l_party_id,
		p_level                   => p_running_level,
		p_source_id               => l_source_id,
		p_object_code             => l_object_type,
		p_object_id               => l_key_id,
		p_parent_request_id       => p_request_id,
		p_dunning_mode		  => p_dunning_mode,
		p_correspondence_date     => p_correspondence_date,
		x_return_status           => l_return_status,
		x_msg_count               => l_msg_count,
		x_msg_data                => l_msg_data,
		x_contact_destination     => l_contact_destination,
		x_contact_party_id        => l_contact_party_id,
		x_REQUEST_ID              => l_request_id);
	end if;
end loop;
close sql_cur1;

IF FND_API.to_Boolean( p_commit )
THEN
  COMMIT WORK;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;
WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END');

FND_MSG_PUB.Count_And_Get
(  p_count          =>   x_msg_count,
p_data           =>   x_msg_data );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     COMMIT WORK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get
     (  p_count          =>   x_msg_count,
	p_data           =>   x_msg_data );
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exc Exception');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'expect exception' );
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     COMMIT WORK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     (  p_count          =>   x_msg_count,
	p_data           =>   x_msg_data );
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UnExc Exception');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'unexpect exception' );
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);


 WHEN OTHERS THEN
     COMMIT WORK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     (  p_count          =>   x_msg_count,
	p_data           =>   x_msg_data );
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Other Exception');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'unexpect exception' );
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);

END stage_dunning_inv_copy;

BEGIN
  PG_DEBUG  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

END IEX_DUNNING_PVT;

/
