--------------------------------------------------------
--  DDL for Package Body CS_SR_DUP_CHK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_DUP_CHK_PVT" 
/* $Header: csdpchkb.pls 120.4.12010000.2 2009/07/22 15:28:49 gasankar ship $ */
AS

/*
	This is the main procedure that will be called to do duplicate check.
	Based on the parameter passed this procedure will perform duplicate checking. Calling application
	will determine and pass parameters accordingly for performing duplicate check.
	For example:
	If profile is to do 'Instance/Customer, product, serial number'
	p_customer_prodct_id (Instance), p_customer_id, p_inventory_item_id, and either of the value for
	serial number will be passed in:
		p_instance_serial_number (for search in IB) or
		p_item_serial_number (for search in Item Serial master) or
		p_current_serial_number (for free form serial number search)
	If Instance is passed, duplicate check api will perform dup check on instance info only and will ignore
	other parameters, i.e., p_customer_id, p_inventory_item_id etc.

	If profile is to do 'All with serial'
	p_cs_extended_attr (extended attributes), p_incident_address (incident address), including above
	mentioned parameters

	In case when the duplicate api is called from update, p_incident_id must be passed.

	In return this procedure will return:
	x_duplicate_flag	=> Values Y/N, indicating if duplicate was found
	x_sr_dupl_rec		=> List of Incident Id and Reason for which duplicate was found
	x_dup_found_at		=> Values 'EA', 'SR', 'BOTH', 'NONE', for what duplicate was found (used in iSupport workflow)

*/

PROCEDURE Duplicate_Check
       (
       	p_api_version			IN 	NUMBER,
       	p_init_msg_list			IN	VARCHAR2	DEFAULT fnd_api.g_false,
       	p_commit			IN	VARCHAR2	DEFAULT fnd_api.g_false,
       	p_validation_level		IN	NUMBER	DEFAULT fnd_api.g_valid_level_full,
       	p_incident_id			IN	NUMBER,
       	p_incident_type_id		IN	NUMBER,
       	p_customer_product_ID 		IN	NUMBER,
    	p_instance_serial_number 	IN 	VARCHAR2,
       	p_current_serial_number	 	IN	VARCHAR2,
    	p_inv_item_serial_number 	IN 	VARCHAR2,
       	p_customer_id			IN 	NUMBER,
       	p_inventory_item_id		IN	NUMBER,
       	p_cs_extended_attr		IN	cs_extended_attr_tbl,
       	p_incident_address		IN	cs_incident_address_rec,
       	x_duplicate_flag		OUT NOCOPY 	varchar2,
       	x_sr_dupl_rec			OUT NOCOPY	Sr_Dupl_Tbl,
        x_dup_found_at			OUT NOCOPY  VARCHAR2,
       	x_return_status			OUT NOCOPY	VARCHAR2,
       	x_msg_count			OUT NOCOPY	NUMBER,
       	x_msg_data			OUT NOCOPY	VARCHAR2
       )
IS
	l_ea_attr_dup_flag  VARCHAR2(1) := FND_API.g_false;
	l_cs_sr_dup_flag	VARCHAR2(1) := FND_API.g_false;

    l_api_name			CONSTANT VARCHAR2(30)	:= 'SR_DUPLICATE_CHECK_API';
    l_api_version       CONSTANT NUMBER 		:= 1.0;
	l_return_status 	VARCHAR2(1);

    l_cs_ea_dup_rec Sr_Dupl_tbl;
	l_cs_sr_dup_rec sr_dupl_tbl;

	l_dup_from 		NUMBER;
	l_ea_ia_dup		VARCHAR2(1);
	l_ea_ea_dup		VARCHAR2(1);

BEGIN

    IF NOT FND_API.Compatible_API_Call
       (l_api_version, p_api_version , l_api_name, G_PKG_NAME )
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	   FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF (p_cs_extended_attr.count > 0 or
	(   p_incident_address.incident_address is not NULL
	 or p_incident_address.incident_city is not NULL
	 or p_incident_address.incident_state is not NULL
	 or p_incident_address.incident_country is not NULL
	 or p_incident_address.incident_postal_code is not NULL)
	or p_incident_id is not NULL ) then

           Check_EA_Duplicate_Setup
           ( p_incident_id      => p_incident_id,
             p_incident_type_id => p_incident_type_id,
             p_cs_extended_attr => p_cs_extended_attr,
             p_incident_address => p_incident_address,
             p_ea_attr_dup_flag => l_ea_attr_dup_flag,
             p_cs_ea_dup_rec    => l_cs_ea_dup_rec,
	     p_ea_ia_dup	   => l_ea_ia_dup,
	     p_ea_ea_dup	   => l_ea_ea_dup,
	     p_return_status    => l_return_status
          );
	END IF;

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF ( (   p_customer_product_id is not NULL
		  or p_current_serial_number is not NULL
		  or p_instance_serial_number is not NULL
		  or p_inv_item_serial_number is not NULL
		  or p_customer_id is not NULL
		  or p_inventory_item_id is not NULL )
	   ) then

	    Perform_Dup_on_SR_field
             ( p_customer_product_id   => p_customer_product_id,
               p_customer_id           => p_customer_id,
               p_inventory_item_id     => p_inventory_item_id,
               p_instance_serial_number=> p_instance_serial_number,
               p_current_serial_number => p_current_serial_number,
               p_inv_item_serial_number=> p_inv_item_serial_number,
               p_incident_id           => p_incident_id,
               p_cs_sr_dup_rec         => l_cs_sr_dup_rec,
               p_cs_sr_dup_flag        => l_cs_sr_dup_flag,
               p_dup_from		  => l_dup_from,
               p_return_status    => l_return_status
             );
	END IF;

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_ea_attr_dup_flag = fnd_api.g_true and l_cs_sr_dup_flag = fnd_api.g_true THEN
           x_dup_found_at := 'BOTH';
           Construct_Unique_List_Dup_SR(
          p_cs_ea_dup_rec    => l_cs_ea_dup_rec,
          p_ea_attr_dup_flag => l_ea_attr_dup_flag,
          p_cs_sr_dup_rec    => l_cs_sr_dup_rec,
          p_cs_sr_dup_flag   => l_cs_sr_dup_flag,
          p_dup_from         => l_dup_from,
          p_ea_ea_dup   	 => l_ea_ea_dup,
          p_ea_ia_dup   	 => l_ea_ia_dup,
          p_sr_dup_rec       => x_sr_dupl_rec,
          p_duplicate_flag   => x_duplicate_flag,
	  p_return_status    => l_return_status
		 );

	   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
	   END IF;

	ELSIF l_ea_attr_dup_flag = fnd_api.g_true and l_cs_sr_dup_flag = fnd_api.g_false THEN
           x_dup_found_at := 'EA';
           x_sr_dupl_rec := l_cs_ea_dup_rec;
           x_duplicate_flag := fnd_api.g_true;

	ELSIF l_cs_sr_dup_flag = fnd_api.g_true and l_ea_attr_dup_flag = fnd_api.g_false THEN
           x_dup_found_at := 'SR';
           x_sr_dupl_rec := l_cs_sr_dup_rec;
           x_duplicate_flag := fnd_api.g_true;

	ELSE
           x_dup_found_at := 'NONE';
	END IF;
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
    		x_return_status := FND_API.G_RET_STS_ERROR ;
    		FND_MSG_PUB.Count_And_Get
            	(p_count  => x_msg_count,
               	 p_data   => x_msg_data);
    	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    		FND_MSG_PUB.Count_And_Get
            	(p_count  => x_msg_count,
	       	 p_data   => x_msg_data);
    	WHEN OTHERS THEN
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      		IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    		THEN
        		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
	        	    			l_api_name );
    		END IF;
    		FND_MSG_PUB.Count_And_Get
        	(p_count  => x_msg_count,
           	 p_data   => x_msg_data);
END Duplicate_Check;


/*
	This procedure checks if duplicate check needs to be performed on extended attributes and
	calls Perform_EA_Duplicate accordingly.

*/

PROCEDURE Check_EA_Duplicate_Setup
(
  p_incident_id		IN	NUMBER,
  p_incident_type_id	IN 	NUMBER,
  p_cs_extended_attr	IN	cs_extended_attr_tbl,
  p_incident_address	IN	cs_incident_address_rec,
  p_ea_attr_dup_flag 	IN OUT NOCOPY varchar2,
  p_cs_ea_dup_rec		OUT NOCOPY sr_dupl_tbl,
  p_ea_ia_dup			OUT NOCOPY VARCHAR2,
  p_ea_ea_dup			OUT NOCOPY VARCHAR2,
  p_return_status		OUT NOCOPY VARCHAR2
)
IS

   CURSOR c_CheckIfDupCheckOn_csr IS
         select SR_DUP_CHECK_FLAG from CUG_SR_TYPE_DUP_CHK_INFO
          WHERE INCIDENT_TYPE_ID = p_incident_type_id;
   c_CheckIfDupCheckOn_rec c_CheckIfDupCheckOn_csr%ROWTYPE;

   l_incident_type_id NUMBER := p_incident_type_id;
   cs_ea_dup_rec	sr_dupl_tbl;
   cs_dup_prof_value    varchar2(100);

BEGIN
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   OPEN c_CheckIfDupCheckOn_Csr;
   FETCH c_CheckIfDupCheckOn_Csr INTO c_CheckIfDupCheckOn_rec;

   IF (c_CheckIfDupCheckOn_csr%NOTFOUND) THEN
      p_ea_attr_dup_flag := fnd_api.g_false;
      return;
   END IF;
   CLOSE c_CheckIfDupCheckOn_csr;

   IF c_CheckIfDupCheckOn_rec.sr_dup_check_flag <> 'Y' THEN
      p_ea_attr_dup_flag := fnd_api.g_false;
      return;
   END IF;

   cs_dup_prof_value := fnd_profile.value('CS_SR_DUP_CHK_CRITERIA');

   IF p_incident_id is not null and
     (cs_dup_prof_value NOT IN ('CS_DUP_CRIT_EA_ADDR', 'CS_DUP_CRIT_WITHNO_SERIAL', 'CS_DUP_CRIT_WITH_SERIAL')  or cs_dup_prof_value is null)
   THEN
      p_ea_attr_dup_flag := fnd_api.g_false;
      return;
   END IF;

   Perform_EA_Duplicate(
      p_incident_id      => p_incident_id,
      p_incident_type_id => p_incident_type_id,
      p_cs_extended_attr => p_cs_extended_attr,
      p_incident_address => p_incident_address,
      p_ea_attr_dup_flag => p_ea_attr_dup_flag,
      p_cs_ea_dup_rec    => cs_ea_dup_rec,
      p_ea_ia_dup		 => p_ea_ia_dup,
      p_ea_ea_dup		 => p_ea_ea_dup,
      p_return_status    => p_return_status
	);

    IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       return;
    ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
       p_return_status := FND_API.G_RET_STS_ERROR;
       return;
    END IF;
    p_cs_ea_dup_rec := cs_ea_dup_rec;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
END Check_EA_Duplicate_Setup;


/*
	This procedure performs duplicate check on extended attributes.
*/

PROCEDURE Perform_EA_Duplicate
(
  p_incident_id		IN	NUMBER,
  p_incident_type_id	IN 	NUMBER,
  p_cs_extended_attr	IN	cs_extended_attr_tbl,
  p_incident_address	IN	cs_incident_address_rec,
  p_ea_attr_dup_flag 	IN OUT NOCOPY	varchar2,
  p_cs_ea_dup_rec		OUT NOCOPY	sr_dupl_tbl,
  p_ea_ia_dup			OUT NOCOPY VARCHAR2,
  p_ea_ea_dup			OUT NOCOPY VARCHAR2,
  p_return_status 	OUT NOCOPY VARCHAR2
)
IS

	l_duplicate_date 	date;
	l_incident_type_id 	NUMBER := p_incident_type_id;
	l_incident_id		NUMBER := p_incident_id;

	l_ea_dup_found_tbl 	SR_Dupl_Link_Tbl;
	l_ea_dup_sr_rec		SR_Dupl_Tbl;

	l_incident_address 	CS_Incident_Address_Rec;

    match_found NUMBER := 0;
    cnt         NUMBER := 0;
    l_SRAttribute_value_old varchar2(80);
    l_SRAttribute_value_new varchar2(80);

    CURSOR c_DuplicateTimeInfo_csr IS
     	SELECT duplicate_offset, duplicate_uom, dup_chk_incident_addr_flag
       	FROM CUG_SR_TYPE_DUP_CHK_INFO
       	WHERE INCIDENT_TYPE_ID = l_incident_type_id;
    l_DuplicateTimeInfo_rec c_DuplicateTimeInfo_csr%ROWTYPE;

    CURSOR l_IncidentId_NoAddr_csr IS
        SELECT sr.incident_id, sr.incident_number, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
          FROM cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
         WHERE sr.INCIDENT_TYPE_ID = l_incident_type_id and
               sr.incident_id = sr_link.subject_id(+) and
               sr_link.subject_type(+) = 'SR' and
               sr_link.link_type(+) = 'DUP' and
               sr_link.end_date_active(+) is null and
               sr.LAST_UPDATE_DATE > l_duplicate_date and
	       sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
               sr_stat.DUP_CHK_FLAG = 'Y' and  -- 12.1.2 - DUP CHECK
               sr_link.LAST_UPDATE_DATE(+) > l_duplicate_date
        ORDER BY sr.incident_id DESC;

    l_IncidentId_NoAddr_rec    l_IncidentId_NoAddr_csr%ROWTYPE;


-- Fixed bug 3509580, added UNION for party_site_id stored in incident_location_id where incident_location_type is 'HZ_PARTY_SITE'
    CURSOR l_IncidentId_withAddr_csr IS
        SELECT sr.INCIDENT_ID, sr.INCIDENT_NUMBER, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
          FROM cs_incidents_b_sec sr, HZ_LOCATIONS loc, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
         WHERE sr.INCIDENT_LOCATION_ID = loc.LOCATION_ID AND
               sr.incident_location_type = 'HZ_LOCATION' AND
               nvl(upper(loc.ADDRESS1||decode(loc.address2,null,null,';'||loc.address2) ||decode(loc.address3,null,null,';'||loc.address3)||decode(loc.address4,null,null,';'||loc.address4)), 'Not Filled') =
               nvl(upper(l_incident_address.incident_address), 'Not Filled') AND
               nvl(upper(loc.CITY), 'Not Filled') = nvl(upper(l_incident_address.incident_city), 'Not Filled') AND
               nvl(upper(loc.STATE), 'Not Filled') = nvl(upper(l_incident_address.incident_state), 'Not Filled') AND
               nvl(upper(loc.POSTAL_CODE), 'Not Filled') = nvl(upper(l_incident_address.incident_postal_Code), 'Not Filled') AND
               nvl(upper(loc.COUNTRY), 'Not Filled') = nvl(upper(l_incident_address.INCIDENT_COUNTRY), 'Not Filled') AND
               sr.LAST_UPDATE_DATE > l_duplicate_date AND
               sr.INCIDENT_TYPE_ID = l_incident_type_id AND
               sr.incident_id = sr_link.subject_id(+) and
               sr_link.subject_type(+) = 'SR' and
               sr_link.link_type(+) = 'DUP' and
               sr_link.end_date_active(+) is null and
	       sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
               sr_stat.DUP_CHK_FLAG = 'Y' and  -- 12.1.2 - DUP CHECK
               sr_link.LAST_UPDATE_DATE(+) > l_duplicate_date
        UNION
        SELECT sr.INCIDENT_ID, sr.INCIDENT_NUMBER, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
          FROM cs_incidents_b_sec sr, HZ_LOCATIONS loc, cs_incident_links sr_link, hz_party_sites sites , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
         WHERE sr.INCIDENT_LOCATION_ID = sites.party_site_id AND
               sr.incident_location_type = 'HZ_PARTY_SITE' AND
               sites.location_id = loc.location_id AND
               nvl(upper(loc.ADDRESS1||decode(loc.address2,null,null,';'||loc.address2) ||decode(loc.address3,null,null,';'||loc.address3)||decode(loc.address4,null,null,';'||loc.address4)), 'Not Filled') =
               nvl(upper(l_incident_address.incident_address), 'Not Filled') AND
               nvl(upper(loc.CITY), 'Not Filled') = nvl(upper(l_incident_address.incident_city), 'Not Filled') AND
               nvl(upper(loc.STATE), 'Not Filled') = nvl(upper(l_incident_address.incident_state), 'Not Filled') AND
               nvl(upper(loc.POSTAL_CODE), 'Not Filled') = nvl(upper(l_incident_address.incident_postal_Code), 'Not Filled') AND
               nvl(upper(loc.COUNTRY), 'Not Filled') = nvl(upper(l_incident_address.INCIDENT_COUNTRY), 'Not Filled') AND
               sr.LAST_UPDATE_DATE > l_duplicate_date AND
               sr.INCIDENT_TYPE_ID = l_incident_type_id AND
               sr.incident_id = sr_link.subject_id(+) and
               sr_link.subject_type(+) = 'SR' and
               sr_link.link_type(+) = 'DUP' and
               sr_link.end_date_active(+) is null and
	       sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
               sr_stat.DUP_CHK_FLAG = 'Y' and  -- 12.1.2 - DUP CHECK
               sr_link.LAST_UPDATE_DATE(+) > l_duplicate_date
        UNION
        SELECT sr.INCIDENT_ID, sr.INCIDENT_NUMBER, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
          FROM cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
         WHERE nvl(upper(incident_ADDRESS), 'Not Filled') = nvl(upper(l_incident_address.incident_address), 'Not Filled') AND
               nvl(upper(incident_CITY), 'Not Filled') = nvl(upper(l_incident_address.incident_city), 'Not Filled') AND
               nvl(upper(incident_STATE), 'Not Filled') = nvl(upper(l_incident_address.incident_state), 'Not Filled') AND
               nvl(upper(incident_POSTAL_CODE), 'Not Filled') =  nvl(upper(l_incident_address.incident_postal_Code), 'Not Filled') AND
               nvl(upper(incident_COUNTRY), 'Not Filled') =  nvl(upper(l_incident_address.incident_country), 'Not Filled') AND
               sr.LAST_UPDATE_DATE > l_duplicate_date AND
               sr.INCIDENT_TYPE_ID = l_incident_type_id AND
               sr.incident_id = sr_link.subject_id(+) and
               sr_link.subject_type(+) = 'SR' and
               sr_link.link_type(+) = 'DUP' and
               sr_link.end_date_active(+) is null and
	       sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
               sr_stat.DUP_CHK_FLAG = 'Y' and  -- 12.1.2 - DUP CHECK
               sr_link.LAST_UPDATE_DATE(+) > l_duplicate_date
        ORDER BY incident_id desc;

-- end of bug fix 3509580, by aneemuch

        L_INCIDENTID_WITHADDR_REC L_INCIDENTID_WITHADDR_csr%rowtype;

-- Cursor to find SR when called from iSupport
    CURSOR l_IncidentId_NoAddrUpd_csr IS
        SELECT sr.INCIDENT_ID, sr.INCIDENT_NUMBER, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
          FROM cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
         WHERE sr.INCIDENT_TYPE_ID = l_incident_type_id and
               sr.incident_id <> l_incident_id and
               sr.LAST_UPDATE_DATE > l_duplicate_date and
               sr.incident_id = sr_link.subject_id(+) and
               sr_link.subject_type(+) = 'SR' and
               sr_link.link_type(+) = 'DUP' and
               sr_link.end_date_active(+) is null and
	       sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
               sr_stat.DUP_CHK_FLAG = 'Y' and  -- 12.1.2 - DUP CHECK
               sr_link.LAST_UPDATE_DATE(+) > l_duplicate_date
        ORDER BY sr.incident_id desc;

    l_IncidentId_NoAddrUpd_rec    l_IncidentId_NoAddrUpd_csr%ROWTYPE;

-- Fixed bug 3509580, added UNION for party_site_id stored in incident_location_id where incident_location_type is 'HZ_PARTY_SITE'
    CURSOR l_IncidentId_withAddrUpd_csr IS
        SELECT sr.INCIDENT_ID, sr.INCIDENT_NUMBER, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
          FROM cs_incidents_b_sec sr, HZ_LOCATIONS loc, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
         WHERE sr.INCIDENT_LOCATION_ID = loc.LOCATION_ID AND
               sr.incident_location_type = 'HZ_LOCATION' AND
               nvl(upper(loc.ADDRESS1||decode(loc.address2,null,null,';'||loc.address2) ||decode(loc.address3,null,null,';'||loc.address3)||decode(loc.address4,null,null,';'||loc.address4)), 'Not Filled') =
               nvl(upper(l_incident_address.incident_address), 'Not Filled') AND
               nvl(upper(loc.CITY), 'Not Filled') = nvl(upper(l_incident_address.incident_city), 'Not Filled') AND
               nvl(upper(loc.STATE), 'Not Filled') = nvl(upper(l_incident_address.incident_state), 'Not Filled') AND
               nvl(upper(loc.POSTAL_CODE), 'Not Filled') = nvl(upper(l_incident_address.incident_postal_Code), 'Not Filled') AND
               nvl(upper(loc.COUNTRY), 'Not Filled') = nvl(upper(l_incident_address.incident_country), 'Not Filled') AND
               sr.LAST_UPDATE_DATE > l_duplicate_date AND
               sr.incident_id <> l_incident_id and
               sr.INCIDENT_TYPE_ID = l_incident_type_id AND
               sr.incident_id = sr_link.subject_id(+) and
               sr_link.subject_type(+) = 'SR' and
               sr_link.link_type(+) = 'DUP' and
               sr_link.end_date_active(+) is null and
	       sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
               sr_stat.DUP_CHK_FLAG = 'Y' and  -- 12.1.2 - DUP CHECK
               sr_link.LAST_UPDATE_DATE(+) > l_duplicate_date
        UNION
        SELECT sr.INCIDENT_ID, sr.INCIDENT_NUMBER, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
          FROM cs_incidents_b_sec sr, HZ_LOCATIONS loc, cs_incident_links sr_link, hz_party_sites sites , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
         WHERE sr.INCIDENT_LOCATION_ID = sites.party_site_id AND
               sr.incident_location_type = 'HZ_PARTY_SITE' AND
               sites.location_id = loc.location_id AND
               nvl(upper(loc.ADDRESS1||decode(loc.address2,null,null,';'||loc.address2) ||decode(loc.address3,null,null,';'||loc.address3)||decode(loc.address4,null,null,';'||loc.address4)), 'Not Filled') =
               nvl(upper(l_incident_address.incident_address), 'Not Filled') AND
               nvl(upper(loc.CITY), 'Not Filled') = nvl(upper(l_incident_address.incident_city), 'Not Filled') AND
               nvl(upper(loc.STATE), 'Not Filled') = nvl(upper(l_incident_address.incident_state), 'Not Filled') AND
               nvl(upper(loc.POSTAL_CODE), 'Not Filled') = nvl(upper(l_incident_address.incident_postal_Code), 'Not Filled') AND
               nvl(upper(loc.COUNTRY), 'Not Filled') = nvl(upper(l_incident_address.incident_country), 'Not Filled') AND
               sr.LAST_UPDATE_DATE > l_duplicate_date AND
               sr.incident_id <> l_incident_id and
               sr.INCIDENT_TYPE_ID = l_incident_type_id AND
               sr.incident_id = sr_link.subject_id(+) and
               sr_link.subject_type(+) = 'SR' and
               sr_link.link_type(+) = 'DUP' and
               sr_link.end_date_active(+) is null and
	       sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
               sr_stat.DUP_CHK_FLAG = 'Y' and  -- 12.1.2 - DUP CHECK
               sr_link.LAST_UPDATE_DATE(+) > l_duplicate_date
        UNION
        SELECT sr.INCIDENT_ID, sr.INCIDENT_NUMBER, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
          FROM cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
         WHERE nvl(upper(incident_ADDRESS), 'Not Filled') = nvl(upper(l_incident_address.incident_address), 'Not Filled') AND
               nvl(upper(incident_CITY), 'Not Filled') = nvl(upper(l_incident_address.incident_city), 'Not Filled') AND
               nvl(upper(incident_STATE), 'Not Filled') = nvl(upper(l_incident_address.incident_state), 'Not Filled') AND
               nvl(upper(incident_POSTAL_CODE), 'Not Filled') =  nvl(upper(l_incident_address.incident_postal_Code), 'Not Filled') AND
               nvl(upper(incident_COUNTRY), 'Not Filled') =  nvl(upper(l_incident_address.incident_country), 'Not Filled') AND
               sr.LAST_UPDATE_DATE > l_duplicate_date AND
               sr.incident_id <> l_incident_id and
               INCIDENT_TYPE_ID = l_incident_type_id AND
               sr.incident_id = sr_link.subject_id(+) and
               sr_link.subject_type(+) = 'SR' and
               sr_link.link_type(+) = 'DUP' and
               sr_link.end_date_active(+) is null and
	       sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
               sr_stat.DUP_CHK_FLAG = 'Y' and  -- 12.1.2 - DUP CHECK
               sr_link.LAST_UPDATE_DATE(+) > l_duplicate_date
        ORDER BY incident_id desc;

-- End of bug fix 3509580, by aneemuch

    l_IncidentId_withAddrUpd_rec    l_IncidentId_withAddrUpd_csr%ROWTYPE;

    CURSOR l_DuplicateCheckAttrs_csr IS
      	select SR_ATTRIBUTE_CODE from CUG_SR_TYPE_ATTR_MAPS_VL
         where INCIDENT_TYPE_ID = l_incident_type_id AND
               SR_ATTR_DUP_CHECK_FLAG = 'Y' AND
               ( END_DATE_ACTIVE IS NULL OR
                  to_number(to_char(END_DATE_ACTIVE, 'YYYYMMDD')) >= to_number(to_char(sysdate, 'YYYYMMDD')) );

    l_DuplicateCheckAttrs_rec l_DuplicateCheckAttrs_csr%ROWTYPE;

    CURSOR l_OldDupAttrValue_csr (p_inc_id NUMBER) IS
        SELECT sr_attribute_value FROM cug_incidnt_attr_vals_vl
         WHERE sr_attribute_code = l_DuplicateCheckAttrs_rec.sr_attribute_code AND
               incident_id = p_inc_Id;

    CURSOR l_DupAttrValueUpd_csr IS
      	SELECT sr_attribute_value FROM cug_incidnt_attr_vals_vl
         WHERE sr_attribute_code = l_DuplicateCheckAttrs_rec.sr_attribute_code AND
               incident_id = l_incident_Id;

BEGIN

   p_return_status := FND_API.G_RET_STS_SUCCESS;
   OPEN c_DuplicateTimeInfo_csr;
   FETCH c_DuplicateTimeInfo_csr INTO l_DuplicateTimeInfo_rec;

   CALCULATE_DUPLICATE_TIME_FRAME( p_incident_type_id => l_incident_type_id,
						p_duplicate_time_frame => l_duplicate_date);

   IF l_incident_id is NULL THEN
      IF l_DuplicateTimeInfo_rec.dup_chk_incident_addr_flag = 'Y' THEN
         p_ea_ia_dup := 'Y';
         l_incident_address := p_incident_address;
         OPEN l_IncidentId_withAddr_csr;
         LOOP
            FETCH l_IncidentId_withAddr_csr INTO l_IncidentId_withAddr_rec;
            EXIT WHEN l_IncidentId_withAddr_csr%NOTFOUND;

            match_found := 1;
            OPEN l_DuplicateCheckAttrs_csr;
            LOOP
               FETCH l_DuplicateCheckAttrs_csr into l_DuplicateCheckAttrs_rec;
               EXIT WHEN l_DuplicateCheckAttrs_csr%NOTFOUND;

               OPEN l_OldDupAttrValue_csr (l_IncidentId_withAddr_rec.incident_id);
               FETCH l_OldDupAttrValue_csr into  l_SRAttribute_value_old;
               IF(l_OldDupAttrValue_csr%NOTFOUND) THEN
                  l_SRAttribute_value_old := ' ';
               END IF;
               CLOSE l_OldDupAttrValue_csr;

               IF p_cs_extended_attr.count > 0 THEN
               FOR i in p_cs_extended_Attr.first..p_cs_extended_attr.last loop
		  IF p_cs_extended_attr(i).sr_attribute_code = l_DuplicateCheckAttrs_rec.sr_attribute_code THEN
                     l_SRAttribute_value_new := p_cs_extended_attr(i).sr_attribute_value;
                     exit;
                  END IF;
               END LOOP;
               END IF;

               IF upper(l_SRAttribute_value_old) = upper(l_SRAttribute_value_new) THEN
                  match_found := 1;
               ELSE
                  match_found := 0;
               END IF;
            END LOOP;

            IF match_found <> 0 OR l_DuplicateCheckAttrs_csr%ROWCOUNT = 0 THEN
               p_ea_attr_dup_flag := fnd_api.g_true;
               cnt := cnt + 1;
               l_ea_dup_found_tbl(cnt).incident_id := l_IncidentId_withAddr_rec.incident_id;
               l_ea_dup_found_tbl(cnt).incident_link_id := l_IncidentId_withAddr_rec.incident_link_id;
               l_ea_dup_found_tbl(cnt).incident_link_number := l_IncidentId_withAddr_rec.incident_link_number;

               IF l_DuplicateCheckAttrs_csr%ROWCOUNT = 0 THEN
                  p_ea_ea_dup := 'N';
                  l_ea_dup_found_tbl(cnt).reason_desc := Get_Dup_Message('CS_EA_INCIDENT_ADDR_MCH');
               ELSE
                  p_ea_ea_dup := 'Y';
                  l_ea_dup_found_tbl(cnt).reason_desc := Get_Dup_Message('CS_EA_EA_ADDR_MCH');
               END IF;
            END IF;
            CLOSE l_DuplicateCheckAttrs_csr;

         END LOOP;
		 CLOSE l_IncidentId_WithAddr_csr;
      ELSE
         p_ea_ia_dup := 'N';
         OPEN l_IncidentId_NoAddr_csr;
         LOOP
            FETCH l_IncidentId_NoAddr_csr INTO l_IncidentId_NoAddr_rec;
            EXIT WHEN l_IncidentId_NoAddr_csr%NOTFOUND;

            match_found := 1;
            OPEN l_DuplicateCheckAttrs_csr;
            LOOP
               FETCH l_DuplicateCheckAttrs_csr into l_DuplicateCheckAttrs_rec;
               EXIT WHEN l_DuplicateCheckAttrs_csr%NOTFOUND;

               OPEN l_OldDupAttrValue_csr(l_IncidentId_NoAddr_rec.incident_id);
               FETCH l_OldDupAttrValue_csr into  l_SRAttribute_value_old;
               IF(l_OldDupAttrValue_csr%NOTFOUND) THEN
                  l_SRAttribute_value_old := ' ';
               END IF;
               CLOSE l_OldDupAttrValue_csr;

               IF p_cs_extended_attr.count > 0 THEN
               FOR i in p_cs_extended_Attr.first..p_cs_extended_attr.last loop
                  IF p_cs_extended_attr(i).SR_ATTRIBUTE_CODE = l_DuplicateCheckAttrs_rec.sr_attribute_code THEN
                     l_SRAttribute_value_new := p_cs_extended_attr(i).sr_attribute_value;
                     exit ;
                  END IF;
               END LOOP;
               END IF;

               IF upper(l_SRAttribute_value_old) = upper(l_SRAttribute_value_new) THEN
                  match_found := 1;
               ELSE
                  match_found := 0;
               END IF;
            END LOOP;

            IF match_found <> 0 OR l_DuplicateCheckAttrs_csr%ROWCOUNT = 0 THEN
               p_ea_attr_dup_flag := fnd_api.g_true;
               cnt := cnt + 1;
               p_ea_ea_dup := 'Y';
               l_ea_dup_found_tbl(cnt).incident_id := l_IncidentId_NoAddr_rec.incident_id;
               l_ea_dup_found_tbl(cnt).incident_link_id := l_IncidentId_NoAddr_rec.incident_link_id;
               l_ea_dup_found_tbl(cnt).incident_link_number := l_IncidentId_NoAddr_rec.incident_link_number;
--			l_ea_dup_found_tbl(cnt).reason_desc := Get_Dup_Message('CS_EA_EA_MCH');
               IF l_DuplicateCheckAttrs_csr%ROWCOUNT = 0 THEN
--				p_ea_ea_dup := 'N';
                  l_ea_dup_found_tbl(cnt).reason_desc := Get_Dup_Message('CS_EA_INCIDENT_ADDR_MCH');
               ELSE
                  p_ea_ea_dup := 'Y';
                  l_ea_dup_found_tbl(cnt).reason_desc := Get_Dup_Message('CS_EA_EA_MCH');
               END IF;

            END IF;
            CLOSE l_DuplicateCheckAttrs_csr;

         END LOOP;
         CLOSE l_IncidentId_NoAddr_csr;
       END IF;
    ELSE
    -- Provide same logic in update mode for SR created through iSupport and Email...
       IF l_DuplicateTimeInfo_rec.dup_chk_incident_addr_flag = 'Y' THEN
          p_ea_ia_dup := 'Y';
          l_incident_address := p_incident_address;
          OPEN l_IncidentId_withAddrUpd_csr;
          LOOP
             FETCH l_IncidentId_withAddrUpd_csr INTO l_IncidentId_withAddrUpd_rec;
             EXIT WHEN l_IncidentId_withAddrUpd_csr%NOTFOUND;

             OPEN l_DuplicateCheckAttrs_csr;
             LOOP
                FETCH l_DuplicateCheckAttrs_csr into l_DuplicateCheckAttrs_rec;
                EXIT WHEN l_DuplicateCheckAttrs_csr%NOTFOUND;

                OPEN l_OldDupAttrValue_csr (l_IncidentId_withAddrUpd_rec.incident_id);
                FETCH l_OldDupAttrValue_csr into  l_SRAttribute_value_old;
                IF(l_OldDupAttrValue_csr%NOTFOUND) THEN
                   l_SRAttribute_value_old := 'XXX';
                END IF;
                CLOSE l_OldDupAttrValue_csr;

                OPEN l_DupAttrValueUpd_csr;
                FETCH l_DupAttrValueUpd_csr into  l_SRAttribute_value_new;
                IF(l_DupAttrValueUpd_csr%NOTFOUND) THEN
                   l_SRAttribute_value_new := 'YYY';
                END IF;
                CLOSE l_DupAttrValueUpd_csr;

                IF upper(l_SRAttribute_value_old) = upper(l_SRAttribute_value_new) THEN
                   match_found := 1;
                ELSE
                   match_found := 0;
                END IF;
             END LOOP;

             IF match_found <> 0 OR l_DuplicateCheckAttrs_csr%ROWCOUNT = 0 THEN
                p_ea_attr_dup_flag := fnd_api.g_true;
                cnt := cnt + 1;
                l_ea_dup_found_tbl(cnt).incident_id := l_IncidentId_withAddrUpd_rec.incident_id;
                l_ea_dup_found_tbl(cnt).incident_link_id := l_IncidentId_withAddrUpd_rec.incident_link_id;
                l_ea_dup_found_tbl(cnt).incident_link_number := l_IncidentId_withAddrUpd_rec.incident_link_number;

                IF l_DuplicateCheckAttrs_csr%ROWCOUNT = 0 THEN
                   p_ea_ea_dup := 'N';
                   l_ea_dup_found_tbl(cnt).reason_desc := Get_Dup_Message('CS_EA_INCIDENT_ADDR_MCH');
                ELSE
                   p_ea_ea_dup := 'Y';
                   l_ea_dup_found_tbl(cnt).reason_desc := Get_Dup_Message('CS_EA_EA_ADDR_MCH');
                END IF;
             END IF;
             CLOSE l_DuplicateCheckAttrs_csr;
          END LOOP;
          CLOSE l_IncidentId_withAddrUpd_csr;
       ELSE
          p_ea_ia_dup := 'N';
          OPEN l_IncidentId_NoAddrUpd_csr;
          LOOP
             match_found := 1;
             FETCH l_IncidentId_NoAddrUpd_csr INTO l_IncidentId_NoAddrUpd_rec;
             EXIT WHEN l_IncidentId_NoAddrUpd_csr%NOTFOUND;
--				match_found := 1;
                OPEN l_DuplicateCheckAttrs_csr;
                LOOP
                   FETCH l_DuplicateCheckAttrs_csr into l_DuplicateCheckAttrs_rec;
                   EXIT WHEN l_DuplicateCheckAttrs_csr%NOTFOUND;

                   OPEN l_OldDupAttrValue_csr(l_IncidentId_NoAddrUpd_rec.incident_id);
                   FETCH l_OldDupAttrValue_csr into  l_SRAttribute_value_old;
                   IF(l_OldDupAttrValue_csr%NOTFOUND) THEN
                      l_SRAttribute_value_old := ' ';
                   END IF;
                   CLOSE l_OldDupAttrValue_csr;

                   OPEN l_DupAttrValueUpd_csr;
                   FETCH l_DupAttrValueUpd_csr into  l_SRAttribute_value_new;
                   IF(l_DupAttrValueUpd_csr%NOTFOUND) THEN
                      l_SRAttribute_value_new := ' ';
                   END IF;
                   CLOSE l_DupAttrValueUpd_csr;

                   IF upper(l_SRAttribute_value_old) = upper(l_SRAttribute_value_new) THEN
                      match_found := 1;
                   ELSE
                      match_found := 0;
                   END IF;
                END LOOP;

                IF match_found <> 0 THEN
                   p_ea_attr_dup_flag := fnd_api.g_true;
                   cnt := cnt + 1;
                   p_ea_ea_dup := 'Y';
                   l_ea_dup_found_tbl(cnt).incident_id := l_IncidentId_NoAddrUpd_rec.incident_id;
                   l_ea_dup_found_tbl(cnt).incident_link_id := l_IncidentId_NoAddrUpd_rec.incident_link_id;
                   l_ea_dup_found_tbl(cnt).incident_link_number := l_IncidentId_NoAddrUpd_rec.incident_link_number;
--                   l_ea_dup_found_tbl(cnt).reason_desc := Get_Dup_Message('CS_EA_EA_MCH');
                   IF l_DuplicateCheckAttrs_csr%ROWCOUNT = 0 THEN
--                      p_ea_ea_dup := 'N';
                      l_ea_dup_found_tbl(cnt).reason_desc := Get_Dup_Message('CS_EA_INCIDENT_ADDR_MCH');
                   ELSE
--                      p_ea_ea_dup := 'Y';
                      l_ea_dup_found_tbl(cnt).reason_desc := Get_Dup_Message('CS_EA_EA_MCH');
                   END IF;
                END IF;
                CLOSE l_DuplicateCheckAttrs_csr;

             END LOOP;
             CLOSE l_IncidentId_NoAddrUpd_csr;

          END IF;
       END IF;

       IF l_ea_dup_found_tbl.count > 0 THEN
          Check_Dup_SR_Link
          ( p_dup_found_tbl => l_ea_dup_found_tbl,
            p_dup_tbl => p_cs_ea_dup_rec,
            p_return_status    => p_return_status
          );

          IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             return;
          ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
             p_return_status := FND_API.G_RET_STS_ERROR;
             return;
          END IF;

          p_ea_attr_dup_flag := FND_API.g_true;
          p_cs_ea_dup_rec	:= p_cs_ea_dup_rec;
       ELSE
          p_ea_attr_dup_flag := FND_API.g_false;
       END IF;
EXCEPTION
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;

END Perform_EA_Duplicate;


/*
This procedure is to varifies parameter passed for duplicate checking on Instance/Customer, Product, Serial number
and calls respective procedure to do duplicate check .
*/

PROCEDURE Perform_Dup_on_SR_field
(  p_customer_product_id   	IN NUMBER,
   p_customer_id           	IN NUMBER,
   p_inventory_item_id		IN NUMBER,
   p_instance_serial_number 	IN VARCHAR2,
   p_current_serial_number	IN VARCHAR2,
   p_inv_item_serial_number 	IN VARCHAR2,
   p_incident_id			  	IN NUMBER,
   p_cs_sr_dup_rec         	IN OUT NOCOPY SR_DUPL_TBL,
   p_cs_sr_dup_flag        	IN OUT NOCOPY VARCHAR2,
   p_dup_from			  	IN OUT NOCOPY NUMBER,
   p_return_status		  	OUT NOCOPY VARCHAR2
)
IS
   l_cs_sr_dup_link_rec		SR_Dupl_Link_Tbl;
BEGIN

   p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_customer_product_id is not NULL THEN
      p_dup_from := 1;
      Check_SR_Instance_Dup
      ( p_customer_product_id => p_customer_product_id,
        p_incident_id         => p_incident_id,
        p_cs_sr_dup_link_rec  => l_cs_sr_dup_link_rec,
        p_cs_sr_dup_flag      => p_cs_sr_dup_flag,
        p_return_status    => p_return_status
      );
   ELSIF (p_current_serial_number is not NULL
          or p_instance_serial_number is not NULL
          or p_inv_item_serial_number is not NULL)
        and p_customer_id IS NULL and p_inventory_item_id is NULL THEN
      p_dup_from := 2;
      Check_SR_SerialNum_Dup
        ( p_instance_serial_number=> p_instance_serial_number,
          p_current_serial_number => p_current_serial_number,
          p_inv_item_serial_number=> p_inv_item_serial_number,
          p_incident_id           => p_incident_id,
          p_cs_sr_dup_link_rec    => l_cs_sr_dup_link_rec,
          p_cs_sr_dup_flag        => p_cs_sr_dup_flag,
          p_return_status    	  => p_return_status
        );
   ELSIF p_customer_id is not  NULL
         and p_inventory_item_id is not  NULL
         and (p_current_serial_number is NULL
              and p_instance_serial_number is NULL
              and p_inv_item_serial_number is NULL
         )THEN
      p_dup_from := 3;
      Check_SR_CustProd_Dup
        ( p_customer_id         => p_customer_id,
          p_inventory_item_id     => p_inventory_item_id,
          p_incident_id           => p_incident_id,
          p_cs_sr_dup_link_rec    => l_cs_sr_dup_link_rec,
          p_cs_sr_dup_flag        => p_cs_sr_dup_flag,
          p_return_status    	 => p_return_status
        );
   ELSIF (p_current_serial_number is not NULL
          or p_instance_serial_number is not NULL
          or p_inv_item_serial_number is not NULL)
         and p_inventory_item_id is not NULL
         and p_customer_id is not NULL THEN
      p_dup_from := 4;
      Check_SR_CustProdSerial_Dup
        ( p_customer_id           => p_customer_id,
          p_inventory_item_id     => p_inventory_item_id,
          p_instance_serial_number=> p_instance_serial_number,
          p_current_serial_number => p_current_serial_number,
          p_inv_item_serial_number=> p_inv_item_serial_number,
          p_incident_id           => p_incident_id,
          p_cs_sr_dup_link_rec    => l_cs_sr_dup_link_rec,
          p_cs_sr_dup_flag        => p_cs_sr_dup_flag,
          p_return_status         => p_return_status
        );
   END IF;

   IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
   ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      return;
   END IF;

   IF p_cs_sr_dup_flag = FND_API.g_true THEN
      Check_Dup_SR_Link
        ( p_dup_found_tbl => l_cs_sr_dup_link_rec,
          p_dup_tbl       => p_cs_sr_dup_rec,
          p_return_status => p_return_status
        );

      IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         return;
      ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
         p_return_status := FND_API.G_RET_STS_ERROR;
         return;
      END IF;
      p_cs_sr_dup_flag := FND_API.g_true;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;

END Perform_Dup_on_SR_Field;


PROCEDURE Check_SR_SerialNum_Dup
(
   p_instance_serial_number 	IN VARCHAR2,
   p_current_serial_number		IN VARCHAR2,
   p_inv_item_serial_number 	IN VARCHAR2,
   p_incident_id           	IN NUMBER,
   p_cs_sr_dup_link_rec		IN OUT NOCOPY SR_Dupl_Link_Tbl,
   p_cs_sr_dup_flag			IN OUT NOCOPY VARCHAR2,
   p_return_status				OUT NOCOPY VARCHAR2
)
IS

   l_duplicate_date 			date;
   l_incident_id 				number;
   l_current_serial_number 	CS_INCIDENTS_ALL_B.current_serial_number%type;
   l_inv_item_serial_number 	CS_INCIDENTS_ALL_B.item_serial_number%type;
   l_instance_serial_number 	CS_INCIDENTS_ALL_B.current_serial_number%type;
   l_cs_sr_dup_link_rec		sr_dupl_link_tbl;

   Cursor l_dup_sr_serialnum_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
             sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             upper(sr.current_serial_number) = upper(l_current_serial_number)
      order by sr.incident_id desc;

   l_dup_sr_serialnum_rec 	l_dup_sr_serialnum_csr%rowtype;

   Cursor l_dup_sr_serialnumUpd_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.incident_id <> l_incident_id and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
             sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             upper(sr.current_serial_number) = upper(l_current_serial_number)
      order by sr.incident_id desc;
   l_dup_sr_serialnumUpd_rec 	l_dup_sr_serialnumUpd_csr%rowtype;


   Cursor l_dup_sr_InstSerNum_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link, csi_item_instances inst , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
             inst.instance_id = sr.customer_product_id and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
             sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             inst.serial_number = l_instance_serial_number
      order by sr.incident_id desc;

   l_dup_sr_InstSerNum_rec 	l_dup_sr_InstSerNum_csr%rowtype;

   Cursor l_dup_sr_InstSerNumUpd_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link, csi_item_instances inst ,cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.incident_id <> l_incident_id and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
             sr.customer_product_id = inst.instance_id and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
             sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             inst.serial_number = l_instance_serial_number
      order by sr.incident_id desc ;
   l_dup_sr_InstSerNumUpd_rec 	l_dup_sr_InstSerNumUpd_csr%rowtype;

   Cursor l_dup_sr_ItemSerNum_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
             sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             sr.item_serial_number = l_inv_item_serial_number
     order by sr.incident_id desc;
   l_dup_sr_ItemSerNum_rec 	l_dup_sr_ItemSerNum_csr%rowtype;

   Cursor l_dup_sr_ItemSerNumUpd_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.incident_id <> l_incident_id and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
             sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             sr.item_serial_number = l_inv_item_serial_number
      order by sr.incident_id desc;

   l_dup_sr_ItemSerNumUpd_rec 	l_dup_sr_ItemSerNumUpd_csr%rowtype;

   l_dup_counter 	number := 0;

BEGIN


   p_return_status := FND_API.G_RET_STS_SUCCESS;

   CALCULATE_DUPLICATE_TIME_FRAME( p_duplicate_time_frame => l_duplicate_date);

   l_incident_id := p_incident_id;
   l_current_serial_number := p_current_serial_number;
   l_inv_item_serial_number := p_inv_item_serial_number;
   l_instance_serial_number := p_instance_serial_number;

   IF p_current_serial_number IS NOT NULL THEN
      IF l_incident_id is not NULL THEN

         Open l_dup_sr_serialnumUpd_csr;
         LOOP
            FETCH l_dup_sr_serialnumUpd_csr into l_dup_sr_serialnumUpd_rec;
            EXIT WHEN l_dup_sr_serialnumUpd_csr%NOTFOUND;

            l_dup_counter := l_dup_counter + 1;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_serialnumUpd_rec.incident_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id  := l_dup_sr_serialnumUpd_rec.incident_link_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number  := l_dup_sr_serialnumUpd_rec.incident_link_number;
            l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := 'Serial number match found';
         END LOOP;
      ELSE
         Open l_dup_sr_serialnum_csr;
         LOOP
            FETCH l_dup_sr_serialnum_csr into l_dup_sr_serialnum_rec;
            EXIT WHEN l_dup_sr_serialnum_csr%NOTFOUND;

            l_dup_counter := l_dup_counter + 1;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_serialnum_rec.incident_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id := l_dup_sr_serialnum_rec.incident_link_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number  := l_dup_sr_serialnum_rec.incident_link_number;
            l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := 'Serial number match found';
         END LOOP;
      END IF;
   ELSIF p_instance_serial_number IS NOT NULL THEN
      IF l_incident_id is not NULL THEN

         Open l_dup_sr_InstSerNumUpd_csr;
         LOOP
            FETCH l_dup_sr_InstSerNumUpd_csr into l_dup_sr_InstSerNumUpd_rec;
            EXIT WHEN l_dup_sr_InstSerNumUpd_csr%NOTFOUND;

            l_dup_counter := l_dup_counter + 1;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_InstSerNumUpd_rec.incident_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id  := l_dup_sr_InstSerNumUpd_rec.incident_link_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number  := l_dup_sr_InstSerNumUpd_rec.incident_link_number;
            l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := 'Serial number match found';
         END LOOP;
      ELSE
         Open l_dup_sr_InstSerNum_csr;
         LOOP
            FETCH l_dup_sr_InstSerNum_csr into l_dup_sr_InstSerNum_rec;
            EXIT WHEN l_dup_sr_InstSerNum_csr%NOTFOUND;

            l_dup_counter := l_dup_counter + 1;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_InstSerNum_rec.incident_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id := l_dup_sr_InstSerNum_rec.incident_link_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number  := l_dup_sr_InstSerNum_rec.incident_link_number;
            l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := 'Serial number match found';
         END LOOP;
      END IF;
   ELSIF p_inv_item_serial_number IS NOT NULL THEN
      IF l_incident_id is not NULL THEN

         Open l_dup_sr_ItemSerNumUpd_csr;
         LOOP
            FETCH l_dup_sr_ItemSerNumUpd_csr into l_dup_sr_ItemSerNumUpd_rec;
            EXIT WHEN l_dup_sr_ItemSerNumUpd_csr%NOTFOUND;

            l_dup_counter := l_dup_counter + 1;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_ItemSerNumUpd_rec.incident_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id  := l_dup_sr_ItemSerNumUpd_rec.incident_link_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number  := l_dup_sr_ItemSerNumUpd_rec.incident_link_number;
            l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := 'Serial number match found';
         END LOOP;
      ELSE
         Open l_dup_sr_ItemSerNum_csr;
         LOOP
            FETCH l_dup_sr_ItemSerNum_csr into l_dup_sr_ItemSerNum_rec;
            EXIT WHEN l_dup_sr_ItemSerNum_csr%NOTFOUND;

            l_dup_counter := l_dup_counter + 1;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_ItemSerNum_rec.incident_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id := l_dup_sr_ItemSerNum_rec.incident_link_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number  := l_dup_sr_ItemSerNum_rec.incident_link_number;
            l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := 'Serial number match found';
         END LOOP;
      END IF;
   END IF;

   IF l_dup_counter > 0 THEN
      p_cs_sr_dup_flag := fnd_api.g_true;
   ELSE
      p_cs_sr_dup_flag := fnd_api.g_false;
   END IF;
   p_cs_sr_dup_link_rec := l_cs_sr_dup_link_rec;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
END Check_SR_SerialNum_Dup;


PROCEDURE Check_SR_Instance_Dup
(
   p_customer_product_id	IN NUMBER,
   p_incident_id 			IN NUMBER,
   p_cs_sr_dup_link_rec	IN OUT NOCOPY SR_Dupl_Link_Tbl,
   p_cs_sr_dup_flag		IN OUT NOCOPY VARCHAR2,
   p_return_status			OUT NOCOPY VARCHAR2
)
IS
   l_duplicate_date 		date;
   l_incident_id 			number;
   l_customer_product_id	number;
   l_cs_sr_dup_link_rec	sr_dupl_link_tbl;

   Cursor l_dup_sr_instance_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.link_type(+) = 'DUP' and
             sr_link.subject_type(+) = 'SR' and
             sr_link.end_date_active(+) is null and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
	     sr_stat.DUP_CHK_FLAG = 'Y' and -- 12.1.2 - DUP CHECK
             sr.customer_product_id = l_customer_product_id
      order by sr.incident_id desc;


   l_dup_sr_instance_rec 	l_dup_sr_instance_csr%rowtype;

   Cursor l_dup_sr_instanceUpd_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.incident_id <> l_incident_id and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
	     sr_stat.DUP_CHK_FLAG = 'Y' and -- 12.1.2 - DUP CHECK
             sr.customer_product_id = l_customer_product_id
      order by sr.incident_id desc;

   l_dup_sr_instanceupd_rec 	l_dup_sr_instanceUpd_csr%rowtype;
   l_dup_counter 	number := 0;

BEGIN


   p_return_status := FND_API.G_RET_STS_SUCCESS;

   CALCULATE_DUPLICATE_TIME_FRAME( p_duplicate_time_frame => l_duplicate_date);

   l_incident_id := p_incident_id;
   l_customer_product_id := p_customer_product_id;



   IF l_incident_id is not NULL THEN

      Open l_dup_sr_instanceUpd_csr;
      LOOP
         FETCH l_dup_sr_instanceUpd_csr into l_dup_sr_instanceUpd_rec;
         EXIT WHEN l_dup_sr_instanceUpd_csr%NOTFOUND;

         l_dup_counter := l_dup_counter + 1;
         l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_instanceUpd_rec.incident_id;
         l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id  := l_dup_sr_instanceUpd_rec.incident_link_id;
         l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number  := l_dup_sr_instanceUpd_rec.incident_link_number;
         l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := Get_Dup_Message('CS_INSTANCE_MCH');
      END LOOP;
   ELSE

      Open l_dup_sr_instance_csr;
      LOOP
         FETCH l_dup_sr_instance_csr into l_dup_sr_instance_rec;
         EXIT WHEN l_dup_sr_instance_csr%NOTFOUND;

         l_dup_counter := l_dup_counter + 1;
         l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_instance_rec.incident_id;
         l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id := l_dup_sr_instance_rec.incident_link_id;
         l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number  := l_dup_sr_instance_rec.incident_link_number;
         l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := Get_Dup_Message('CS_INSTANCE_MCH');
      END LOOP;
   END IF;

   if l_dup_counter > 0 then
      p_cs_sr_dup_flag := fnd_api.g_true;
   else
      p_cs_sr_dup_flag := fnd_api.g_false;
   end if;
   p_cs_sr_dup_link_rec := l_cs_sr_dup_link_rec;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
END Check_SR_Instance_Dup;


PROCEDURE Check_SR_CustProd_Dup
( p_customer_id           IN Number,
  p_inventory_item_id     IN Number,
  p_incident_id           IN Number,
  p_cs_sr_dup_link_rec    IN OUT NOCOPY SR_Dupl_Link_Tbl,
  p_cs_sr_dup_flag        IN OUT NOCOPY Varchar2,
  p_return_status		 OUT NOCOPY VARCHAR2
)
IS
   l_duplicate_date 		date;
   l_incident_id 			number;
   l_customer_id			number;
   l_inventory_item_id		number;
   l_cs_sr_dup_link_rec	sr_dupl_link_tbl;
   l_dup_counter 	number := 0;

   Cursor l_dup_sr_custprod_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
             sr.customer_id = l_customer_id and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
	     sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             sr.inventory_item_id = l_inventory_item_id
      order by sr.incident_id desc;

   l_dup_sr_custprod_rec 	l_dup_sr_custprod_csr%rowtype;

   Cursor l_dup_sr_custprodUpd_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.incident_id <> l_incident_id and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
             sr.customer_id = l_customer_id and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
	     sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             sr.inventory_item_id = l_inventory_item_id
      order by sr.incident_id desc;

   l_dup_sr_custprodupd_rec 	l_dup_sr_custprodUpd_csr%rowtype;

BEGIN

   p_return_status := FND_API.G_RET_STS_SUCCESS;
   CALCULATE_DUPLICATE_TIME_FRAME( p_duplicate_time_frame => l_duplicate_date);

   l_incident_id := p_incident_id;
   l_customer_id := p_customer_id;
   l_inventory_item_id := p_inventory_item_id;

   IF l_incident_id is not NULL THEN

      Open l_dup_sr_custprodUpd_csr;
      LOOP
         FETCH l_dup_sr_custprodUpd_csr into l_dup_sr_custprodUpd_rec;
         EXIT WHEN l_dup_sr_custprodUpd_csr%NOTFOUND;

         l_dup_counter := l_dup_counter + 1;
         l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_custprodUpd_rec.incident_id;
         l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id  := l_dup_sr_custprodUpd_rec.incident_link_id;
         l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number  := l_dup_sr_custprodUpd_rec.incident_link_number;
         l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := Get_Dup_Message('CS_INSTANCE_OR_CUST_PROD_MCH');
      END LOOP;
   ELSE

      Open l_dup_sr_custprod_csr;
      LOOP
         FETCH l_dup_sr_custprod_csr into l_dup_sr_custprod_rec;
         EXIT WHEN l_dup_sr_custprod_csr%NOTFOUND;

         l_dup_counter := l_dup_counter + 1;
         l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_custprod_rec.incident_id;
         l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id := l_dup_sr_custprod_rec.incident_link_id;
         l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number := l_dup_sr_custprod_rec.incident_link_number;
         l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := Get_Dup_Message('CS_INSTANCE_OR_CUST_PROD_MCH');
      END LOOP;
   END IF;

   if l_dup_counter > 0 then
      p_cs_sr_dup_flag := fnd_api.g_true;
   else
      p_cs_sr_dup_flag := fnd_api.g_false;
   end if;
   p_cs_sr_dup_link_rec := l_cs_sr_dup_link_rec;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
END Check_SR_CustProd_Dup;


PROCEDURE Check_SR_CustProdSerial_Dup
(  p_customer_id           	IN Number,
   p_inventory_item_id     	IN Number,
   p_instance_serial_number 	IN VARCHAR2,
   p_current_serial_number	IN VARCHAR2,
   p_inv_item_serial_number 	IN VARCHAR2,
   p_incident_id           	IN Number,
   p_cs_sr_dup_link_rec    	IN OUT NOCOPY SR_Dupl_Link_Tbl,
   p_cs_sr_dup_flag        	IN OUT NOCOPY Varchar2,
   p_return_status		 	OUT NOCOPY VARCHAR2
)
IS
   l_duplicate_date 		date;
   l_incident_id 			number;
   l_customer_id			number;
   l_inventory_item_id		number;
   l_current_serial_number CS_INCIDENTS_ALL_B.current_serial_number%type;
   l_instance_serial_number CS_INCIDENTS_ALL_B.current_serial_number%type;
   l_inv_item_serial_number CS_INCIDENTS_ALL_B.current_serial_number%type;
   l_cs_sr_dup_link_rec	sr_dupl_link_tbl;
   l_dup_counter 	number := 0;

   Cursor l_dup_sr_custprodsr_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link, cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
             sr.customer_id = l_customer_id and
             sr.inventory_item_id = l_inventory_item_id and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
	     sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             upper(sr.current_serial_number) = upper(l_current_serial_number)
      order by sr.incident_id desc;

   l_dup_sr_custprodsr_rec 	l_dup_sr_custprodsr_csr%rowtype;

   Cursor l_dup_sr_custprodsrUpd_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.incident_id <> l_incident_id and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
             sr.customer_id = l_customer_id and
             sr.inventory_item_id = l_inventory_item_id and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
	     sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             upper(sr.current_serial_number) = upper(l_current_serial_number)
     order by sr.incident_id desc;

   l_dup_sr_custprodsrupd_rec 	l_dup_sr_custprodsrUpd_csr%rowtype;

   Cursor l_dup_sr_CustProdInsSer_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link, csi_item_instances inst , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
             sr.customer_id = l_customer_id and
             sr.inventory_item_id = l_inventory_item_id and
             inst.instance_id = sr.customer_product_id and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
	     sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             inst.serial_number = l_instance_serial_number
      order by sr.incident_id desc;

   l_dup_sr_CustProdInsSer_rec 	l_dup_sr_CustProdInsSer_csr%rowtype;

   Cursor l_dup_sr_CustProdInsSerUpd_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link, csi_item_instances inst , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.incident_id <> l_incident_id and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
             sr.customer_id = l_customer_id and
             sr.inventory_item_id = l_inventory_item_id and
             sr.customer_product_id = inst.instance_id and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
	     sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             inst.serial_number = l_instance_serial_number
      order by sr.incident_id desc;

   l_dup_sr_CustProdInsSerUpd_rec 	l_dup_sr_CustProdInsSerUpd_csr%rowtype;

   Cursor l_dup_sr_CustProdItmSer_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
             sr.customer_id = l_customer_id and
             sr.inventory_item_id = l_inventory_item_id and
	     sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
	     sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             sr.item_serial_number = l_inv_item_serial_number
      order by sr.incident_id desc;
   l_dup_sr_CustProdItmSer_rec 	l_dup_sr_CustProdItmSer_csr%rowtype;

   Cursor l_dup_sr_CustProdItmSerUpd_csr is
      select sr.incident_id, sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
        from cs_incidents_b_sec sr, cs_incident_links sr_link , cs_incident_statuses_vl sr_stat -- 12.1.2 - DUP CHECK
       where sr.incident_id = sr_link.subject_id(+) and
             sr_link.subject_type(+) = 'SR' and
             sr_link.link_type(+) = 'DUP' and
             sr_link.end_date_active(+) is null and
             sr.incident_id <> l_incident_id and
             sr.last_update_date > l_duplicate_date and
             sr_link.last_update_date(+) > l_duplicate_date and
             sr.customer_id = l_customer_id and
             sr.inventory_item_id = l_inventory_item_id and
             sr_stat.incident_status_id = sr.incident_status_id and  -- 12.1.2 - DUP CHECK
	     sr_stat.DUP_CHK_FLAG = 'Y'  and -- 12.1.2 - DUP CHECK
             sr.item_serial_number = l_inv_item_serial_number
      order by sr.incident_id desc;
   l_dup_sr_CustProdItmSerUpd_rec 	l_dup_sr_CustProdItmSerUpd_csr%rowtype;

BEGIN


   p_return_status := FND_API.G_RET_STS_SUCCESS;
   CALCULATE_DUPLICATE_TIME_FRAME( p_duplicate_time_frame => l_duplicate_date);

   l_incident_id := p_incident_id;
   l_customer_id := p_customer_id;
   l_inventory_item_id := p_inventory_item_id;
   l_current_serial_number := p_current_serial_number;
   l_inv_item_serial_number := p_inv_item_serial_number;
   l_instance_serial_number := p_instance_serial_number;

   IF l_current_serial_number IS NOT NULL THEN

      IF l_incident_id is not NULL THEN
         Open l_dup_sr_custprodsrUpd_csr;
         LOOP
            FETCH l_dup_sr_custprodsrUpd_csr into l_dup_sr_custprodsrUpd_rec;
            EXIT WHEN l_dup_sr_custprodsrUpd_csr%NOTFOUND;

            l_dup_counter := l_dup_counter + 1;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_custprodsrUpd_rec.incident_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id  := l_dup_sr_custprodsrUpd_rec.incident_link_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number  := l_dup_sr_custprodsrUpd_rec.incident_link_number;
            l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := Get_Dup_Message('CS_CUST_PROD_SERIAL_MCH');
         END LOOP;
      ELSE
         Open l_dup_sr_custprodsr_csr;
         LOOP
            FETCH l_dup_sr_custprodsr_csr into l_dup_sr_custprodsr_rec;
            EXIT WHEN l_dup_sr_custprodsr_csr%NOTFOUND;

            l_dup_counter := l_dup_counter + 1;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_custprodsr_rec.incident_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id := l_dup_sr_custprodsr_rec.incident_link_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number := l_dup_sr_custprodsr_rec.incident_link_number;
            l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := Get_Dup_Message('CS_CUST_PROD_SERIAL_MCH');
         END LOOP;
      END IF;
   ELSIF l_instance_serial_number IS NOT NULL THEN
      IF l_incident_id is not NULL THEN
         Open l_dup_sr_CustProdInsSerUpd_csr;
         LOOP
            FETCH l_dup_sr_CustProdInsSerUpd_csr into l_dup_sr_CustProdInsSerUpd_rec;
            EXIT WHEN l_dup_sr_CustProdInsSerUpd_csr%NOTFOUND;

            l_dup_counter := l_dup_counter + 1;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_CustProdInsSerUpd_rec.incident_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id  := l_dup_sr_CustProdInsSerUpd_rec.incident_link_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number  := l_dup_sr_CustProdInsSerUpd_rec.incident_link_number;
            l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := Get_Dup_Message('CS_CUST_PROD_SERIAL_MCH');
         END LOOP;
      ELSE
         Open l_dup_sr_CustProdInsSer_csr;
         LOOP
            FETCH l_dup_sr_CustProdInsSer_csr into l_dup_sr_CustProdInsSer_rec;
            EXIT WHEN l_dup_sr_CustProdInsSer_csr%NOTFOUND;

            l_dup_counter := l_dup_counter + 1;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_CustProdInsSer_rec.incident_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id := l_dup_sr_CustProdInsSer_rec.incident_link_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number := l_dup_sr_CustProdInsSer_rec.incident_link_number;
            l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := Get_Dup_Message('CS_CUST_PROD_SERIAL_MCH');
         END LOOP;
      END IF;

   ELSIF l_inv_item_serial_number IS NOT NULL THEN
      IF l_incident_id is not NULL THEN
         Open l_dup_sr_CustProdItmSerUpd_csr;
         LOOP
            FETCH l_dup_sr_CustProdItmSerUpd_csr into l_dup_sr_CustProdItmSerUpd_rec;
            EXIT WHEN l_dup_sr_CustProdItmSerUpd_csr%NOTFOUND;

            l_dup_counter := l_dup_counter + 1;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_CustProdItmSerUpd_rec.incident_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id  := l_dup_sr_CustProdItmSerUpd_rec.incident_link_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number  := l_dup_sr_CustProdItmSerUpd_rec.incident_link_number;
            l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := Get_Dup_Message('CS_CUST_PROD_SERIAL_MCH');
         END LOOP;
      ELSE
         Open l_dup_sr_CustProdItmSer_csr;
         LOOP
            FETCH l_dup_sr_CustProdItmSer_csr into l_dup_sr_CustProdItmSer_rec;
            EXIT WHEN l_dup_sr_CustProdItmSer_csr%NOTFOUND;

            l_dup_counter := l_dup_counter + 1;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_id := l_dup_sr_CustProdItmSer_rec.incident_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_id := l_dup_sr_CustProdItmSer_rec.incident_link_id;
            l_cs_sr_dup_link_rec(l_dup_counter).incident_link_number := l_dup_sr_CustProdItmSer_rec.incident_link_number;
            l_cs_sr_dup_link_rec(l_dup_counter).reason_desc := Get_Dup_Message('CS_CUST_PROD_SERIAL_MCH');
         END LOOP;
      END IF;

   END IF;

   if l_dup_counter > 0 then
      p_cs_sr_dup_flag := fnd_api.g_true;
   else
      p_cs_sr_dup_flag := fnd_api.g_false;
   end if;
   p_cs_sr_dup_link_rec := l_cs_sr_dup_link_rec;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
END Check_SR_CustProdSerial_Dup;


PROCEDURE Check_Dup_SR_Link
(
  p_dup_found_tbl 	IN	Sr_Dupl_Link_Tbl,
  p_dup_tbl 			IN OUT NOCOPY Sr_Dupl_Tbl,
  p_return_status		OUT NOCOPY VARCHAR2
)
AS
   l_loop_dup_rec_tbl 	Sr_Dupl_Link_Tbl;
   l_link_in_rec        VARCHAR2(1) := 'N';
   l_already_added 	VARCHAR2(1) := 'N';
   l_dup_tbl_cnt        NUMBER := 0;
   l_dup_tbl            sr_dupl_tbl;
   l_rec_count          number := 0;
   l_dup_rec_id         number;
   l_message            varchar2(2000);

-- Changed to fix bug 3332447
   Cursor l_all_dup_for_original_csr (p_original_id number) is
   select sr_link.object_id incident_link_id, sr_link.object_number incident_link_number
     from cs_incident_links sr_link
    where sr_link.subject_id = p_original_id and
          sr_link.subject_type = 'SR' and
          sr_link.link_type_id = 4 and
          sr_link.end_date_active is null
   order by sr_link.object_id desc;

   l_all_dup_for_original_rec l_all_dup_for_original_csr%rowtype;
-- end of bug fix 3332447

BEGIN

   p_return_status := FND_API.G_RET_STS_SUCCESS;
   l_loop_dup_rec_tbl := p_dup_found_tbl;

   FOR i IN l_loop_dup_rec_tbl.first..l_loop_dup_rec_tbl.last loop
      IF l_loop_dup_rec_tbl(i).incident_link_id is not null THEN
         l_link_in_rec := 'N';
         if p_dup_tbl.count > 0 then
            FOR x in p_dup_tbl.first..p_dup_tbl.last loop
               IF p_dup_tbl(x).incident_id = l_loop_dup_rec_tbl(i).incident_link_id THEN
                  l_link_in_rec := 'Y';
                  exit;
               END IF;
            END LOOP;
         end if;

         IF l_link_in_rec = 'N' THEN
            l_dup_tbl_cnt := l_dup_tbl_cnt + 1;
            p_dup_tbl(l_dup_tbl_cnt).incident_id := l_loop_dup_rec_tbl(i).incident_link_id;
            p_dup_tbl(l_dup_tbl_cnt).reason_desc := l_loop_dup_rec_tbl(i).reason_desc;
         END IF;

-----
-- To Fix bug 3332447
-----
--         l_loop_dup_rec_tbl(i).reason_desc := Get_Dup_Message('CS_ORIGINAL_OF_DUP_SR') || ' ' || to_char(l_loop_dup_rec_tbl(i).incident_link_number);

         IF l_link_in_rec = 'N' THEN
            l_dup_rec_id := l_loop_dup_rec_tbl(i).incident_link_id;
         ELSE
            l_dup_rec_id := l_loop_dup_rec_tbl(i).incident_id;
         END IF;

         l_message := NULL;
         l_rec_count := 0;

         OPEN l_all_dup_for_original_csr (l_dup_rec_id);
         LOOP
            FETCH l_all_dup_for_original_csr into l_all_dup_for_original_rec;
            EXIT WHEN l_all_dup_for_original_csr%NOTFOUND;
            l_rec_count := l_rec_count + 1;
            if l_rec_count = 1 then
               l_message := Get_Dup_Message('CS_ORIGINAL_OF_DUP_SR') || ' ' || l_all_dup_for_original_rec.incident_link_number ;
            else
               l_message := l_message  || ' , ' || l_all_dup_for_original_rec.incident_link_number;
            end if;
         END LOOP;
         close l_all_dup_for_original_csr;

         IF l_link_in_rec = 'N' and l_message is not null then
            p_dup_tbl(l_dup_tbl_cnt).reason_desc := l_message;
         ELSE
            l_loop_dup_rec_tbl(i).reason_desc := l_message;
         END IF;

      END IF;

------
-- End of bug fix 3332447
------

      if p_dup_tbl.count > 0 THEN
--		l_already_added := Check_if_already_in_list(p_dup_tbl => p_dup_tbl,
--								p_sr_link_id => l_loop_dup_rec_tbl(i).incident_link_id);
         l_already_added := Check_if_already_in_list(p_dup_tbl => p_dup_tbl,
                                                     p_sr_link_id => l_loop_dup_rec_tbl(i).incident_id);
      else
         l_already_added := 'N';
      End if;
      IF l_already_added = 'N' THEN
         l_dup_tbl_cnt := l_dup_tbl_cnt + 1;
         p_dup_tbl(l_dup_tbl_cnt).incident_id := l_loop_dup_rec_tbl(i).incident_id;
         p_dup_tbl(l_dup_tbl_cnt).reason_desc := l_loop_dup_rec_tbl(i).reason_desc;
      end if;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
END Check_Dup_SR_Link;


PROCEDURE Construct_Unique_list_dup_sr
(
  p_cs_ea_dup_rec     IN Sr_Dupl_Tbl,
  p_ea_attr_dup_flag  IN VARCHAR2,
  p_cs_sr_dup_rec     IN Sr_Dupl_Tbl,
  p_cs_sr_dup_flag    IN VARCHAR2,
  p_dup_from          IN NUMBER,
  p_ea_ea_dup         IN VARCHAR2,
  p_ea_ia_dup         IN VARCHAR2,
  p_sr_dup_rec        IN OUT NOCOPY Sr_Dupl_Tbl,
  p_duplicate_flag    IN OUT NOCOPY VARCHAR2,
  p_return_status     OUT NOCOPY VARCHAR2
)
AS
   l_counter            NUMBER := 0;
   l_included_inList    VARCHAR2(1) := 'N';
   l_sr_dup_rec         Sr_Dupl_Tbl;
   l_found_incident_id  number;

BEGIN
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_ea_attr_dup_flag = fnd_api.g_true THEN

      FOR i in p_cs_ea_dup_rec.first..p_cs_ea_dup_rec.last LOOP
         l_counter := l_counter + 1;
         l_sr_dup_rec(l_counter).incident_id := p_cs_ea_dup_rec(i).incident_id;
         l_sr_dup_rec(l_counter).reason_desc := p_cs_ea_dup_rec(i).reason_desc;
      END LOOP;

   END IF;

   IF p_cs_sr_dup_flag = fnd_api.g_true THEN
      FOR i in p_cs_sr_dup_rec.first..p_cs_sr_dup_rec.last LOOP

         l_included_inList := 'N';
         FOR x in p_cs_ea_dup_rec.first..p_cs_ea_dup_Rec.last LOOP
            IF p_cs_sr_dup_rec(i).incident_id = p_cs_ea_dup_rec(x).incident_id THEN
               l_included_inList := 'Y';
               exit;
            END IF;
         END LOOP;
         IF l_included_inList = 'N' THEN
            l_counter := l_counter + 1;
            l_sr_dup_rec(l_counter).incident_id := p_cs_sr_dup_rec(i).incident_id;
            l_sr_dup_rec(l_counter).reason_desc := p_cs_sr_dup_rec(i).reason_desc;
         ELSE
            for y in l_sr_dup_rec.first..l_sr_dup_rec.last loop
               IF l_sr_dup_rec(y).incident_id = p_cs_sr_dup_rec(i).incident_id THEN
/*
                  CASE
                  WHEN p_dup_from = 1 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'N' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_INSTANCE_EA_MCH');
                  WHEN p_dup_from = 2 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'N' THEN
-- Need to get new message info
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_INSTANCE_EA_MCH');
                  WHEN p_dup_from = 3 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'N' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_CUST_PROD_EA_MCH');
                  WHEN p_dup_from = 4 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'N' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_CUST_PROD_SER_EA_MCH');
                  WHEN p_dup_from = 1 and p_ea_ea_dup = 'N' and p_ea_ia_dup = 'Y' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_INSTANCE_EA_INC_ADDR_MCH');
                  WHEN p_dup_from = 2 and p_ea_ea_dup = 'N' and p_ea_ia_dup = 'Y' THEN
-- Need to get new message info
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_INSTANCE_EA_MCH');
                  WHEN p_dup_from = 3 and p_ea_ea_dup = 'N' and p_ea_ia_dup = 'Y' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_CUST_PROD_EA_ADDR_MCH');
                  WHEN p_dup_from = 4 and p_ea_ea_dup = 'N' and p_ea_ia_dup = 'Y' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_CUST_PROD_SER_EA_ADD_MCH');
                  WHEN p_dup_from = 1 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'Y' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_INSTANCE_EA_EA_ADDR_MCH');
                  WHEN p_dup_from = 2 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'Y' THEN
-- Need to get new message info
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_INSTANCE_EA_MCH');
                  WHEN p_dup_from = 3 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'Y' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_CUST_PROD_EA_EA_ADDR_MCH');
                  WHEN p_dup_from = 4 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'Y' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_CUST_PROD_SER_EA_EA_ADD_MCH');
                  END CASE;
*/
                  IF p_dup_from = 1 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'N' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_INSTANCE_EA_MCH');
                  ELSIF p_dup_from = 2 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'N' THEN
-- Need to get new message info
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_INSTANCE_EA_MCH');
                  ELSIF p_dup_from = 3 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'N' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_CUST_PROD_EA_MCH');
                  ELSIF p_dup_from = 4 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'N' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_CUST_PROD_SER_EA_MCH');
                  ELSIF p_dup_from = 1 and p_ea_ea_dup = 'N' and p_ea_ia_dup = 'Y' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_INSTANCE_EA_INC_ADDR_MCH');
                  ELSIF p_dup_from = 2 and p_ea_ea_dup = 'N' and p_ea_ia_dup = 'Y' THEN
-- Need to get new message info
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_INSTANCE_EA_MCH');
                  ELSIF p_dup_from = 3 and p_ea_ea_dup = 'N' and p_ea_ia_dup = 'Y' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_CUST_PROD_EA_ADDR_MCH');
                  ELSIF p_dup_from = 4 and p_ea_ea_dup = 'N' and p_ea_ia_dup = 'Y' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_CUST_PROD_SER_EA_ADD_MCH');
                  ELSIF p_dup_from = 1 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'Y' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_INSTANCE_EA_EA_ADDR_MCH');
                  ELSIF p_dup_from = 2 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'Y' THEN
-- Need to get new message info
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_INSTANCE_EA_MCH');
                  ELSIF p_dup_from = 3 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'Y' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_CUST_PROD_EA_EA_ADDR_MCH');
                  ELSIF p_dup_from = 4 and p_ea_ea_dup = 'Y' and p_ea_ia_dup = 'Y' THEN
                     l_sr_dup_rec(y).reason_desc := Get_Dup_Message('CS_CUST_PROD_SER_EA_EA_ADD_MCH');
                  END IF;
                  exit;
               END If;
            END LOOP;
         END IF;
      END LOOP;
   END IF;

   IF l_counter > 0 THEN
      p_duplicate_flag := fnd_api.g_true;
   ELSE
      p_duplicate_flag := fnd_api.g_false;
   END IF;
   p_sr_dup_rec := l_sr_dup_rec;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
END Construct_Unique_List_Dup_Sr;


	FUNCTION Get_Dup_Message
	(
		p_lookup_code		IN VARCHAR2
	) return varchar2
	AS
		Cursor l_sr_dup_mesg_csr is
			SELECT lookup_code, description from cs_lookups
				WHERE lookup_type = 'CS_SR_DUPLICATE_REASON_CODE'
				  and lookup_code = p_lookup_code;
		l_sr_dup_mesg_rec 	l_sr_dup_mesg_csr%ROWTYPE;
	BEGIN
		OPEN l_sr_dup_mesg_csr;
		FETCH l_sr_dup_mesg_csr into l_sr_dup_mesg_rec;
		IF (l_sr_dup_mesg_csr%FOUND) THEN
			return l_sr_dup_mesg_rec.description;
		ELSE
			return 'Exception_found';
		END If;
	END Get_Dup_Message;


	FUNCTION Check_if_already_in_list
				(p_dup_tbl IN Sr_Dupl_Tbl,
				 p_sr_link_id IN NUMBER
				) return varchar2
	AS
		l_dup_tbl Sr_Dupl_Tbl;
	BEGIN
		l_dup_tbl := p_dup_tbl;

		FOR i IN l_dup_tbl.first..l_dup_tbl.last loop
			IF l_dup_tbl(i).incident_id = p_sr_link_id THEN
				return 'Y';
			END IF;
		END LOOP;
		return 'N';
	END Check_if_already_in_list;


	PROCEDURE CALCULATE_DUPLICATE_TIME_FRAME
        		(p_incident_type_id NUMBER,
        		 p_duplicate_time_frame OUT NOCOPY DATE)
	IS

        l_duplicate_uom VARCHAR2(30);
        l_incident_type_id	NUMBER;
        l_multiple_by 	NUMBER;

        CURSOR c_DuplicateTimeInfo_csr IS
            SELECT duplicate_offset, duplicate_uom FROM CUG_SR_TYPE_DUP_CHK_INFO
                WHERE INCIDENT_TYPE_ID = l_incident_type_id;
        l_DuplicateTimeInfo_rec c_DuplicateTimeInfo_csr%ROWTYPE;

        CURSOR c_UOM_Conversion_Rate_csr IS
            SELECT conversion_rate FROM MTL_UOM_CONVERSIONS
                WHERE UNIT_OF_MEASURE = l_duplicate_uom
				and inventory_item_id = 0;
        l_UOM_Conversion_Rate_rec   c_UOM_Conversion_Rate_csr%ROWTYPE;

	BEGIN

        l_incident_type_id := p_incident_type_id;

        OPEN   c_DuplicateTimeInfo_csr;
        FETCH c_DuplicateTimeInfo_csr INTO  l_DuplicateTimeInfo_rec;
        IF (c_DuplicateTimeInfo_csr%NOTFOUND) THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        l_duplicate_uom := l_DuplicateTimeInfo_rec.duplicate_uom;

        OPEN c_UOM_Conversion_Rate_csr;
        FETCH c_UOM_Conversion_Rate_csr into l_UOM_Conversion_Rate_rec;
        IF (c_UOM_Conversion_Rate_csr%NOTFOUND) THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF ( l_DuplicateTimeInfo_rec.duplicate_uom = 'Day') THEN
            l_multiple_by := l_DuplicateTimeInfo_rec.duplicate_offset;
        ELSIF (l_DuplicateTimeInfo_rec.duplicate_uom = 'Hour') THEN
            l_multiple_by := l_DuplicateTimeInfo_rec.duplicate_offset/24;
        ELSIF (l_DuplicateTimeInfo_rec.duplicate_uom = 'Month') THEN
            l_multiple_by := (l_DuplicateTimeInfo_rec.duplicate_offset * 720)/24;
        ELSIF (l_DuplicateTimeInfo_rec.duplicate_uom = 'Week') THEN
            l_multiple_by := (l_DuplicateTimeInfo_rec.duplicate_offset*168)/24;
        ELSIF (l_DuplicateTimeInfo_rec.duplicate_uom = 'Year') THEN
            l_multiple_by := (l_DuplicateTimeInfo_rec.duplicate_offset*8760)/24;
        ELSIF (l_DuplicateTimeInfo_rec.duplicate_uom = 'Minute') THEN
            l_multiple_by := (l_DuplicateTimeInfo_rec.duplicate_offset*0.016667)/24;
        ELSIF (l_DuplicateTimeInfo_rec.duplicate_uom = 'Jal') THEN
            l_multiple_by := (l_DuplicateTimeInfo_rec.duplicate_offset*0.016667)/24;
        ELSE
             l_multiple_by := (l_DuplicateTimeInfo_rec.duplicate_offset*l_UOM_Conversion_Rate_rec.conversion_rate)/24;
        END IF;
        p_duplicate_time_frame := sysdate - l_multiple_by;

	END CALCULATE_DUPLICATE_TIME_FRAME;

------------------------------------------------------------
-- Procedure name : CALCULATE_DUPLICATE_TIME_FRAME
--
-- Parameters
-- IN
--   NONE
-- OUT
--   p_duplicate_time_frame : Duplicate Time Frame
--
--
-- Description    : This procedure calculates upto date value based on
--                  the profile set for CS
--
-- Modification History :
-- Date        Name       Desc
-- ----------  ---------  ----------------------------------
-- 09/01/2005  ANEEMUCH   Fixed FP bug 4352458, removed time calculation
--                        from hard coded Time.
-- 09/08/2007  VPREMACH   Bug 6356257. Added upper clause when getting
--                        UOM value from profile.
-- ------------------------------------------------------------

PROCEDURE CALCULATE_DUPLICATE_TIME_FRAME
 (p_duplicate_time_frame OUT NOCOPY DATE)
IS
  l_duplicate_uom VARCHAR2(30);
  l_duplicate_offset	NUMBER;
  l_multiple_by 	NUMBER;

  CURSOR c_UOM_Conversion_Rate_csr IS
         SELECT conversion_rate FROM MTL_UOM_CONVERSIONS
          WHERE uom_code = l_duplicate_uom;

  l_UOM_Conversion_Rate_rec   c_UOM_Conversion_Rate_csr%ROWTYPE;

BEGIN

       /* Start : 5686752 */
        /*l_duplicate_uom := fnd_profile.value('CS_SR_DUP_TIME_FRAME_UOM');
        l_duplicate_offset := fnd_profile.value('CS_SR_DUP_TIME_FRAME');

        OPEN c_UOM_Conversion_Rate_csr;
        FETCH c_UOM_Conversion_Rate_csr into l_UOM_Conversion_Rate_rec;
        IF (c_UOM_Conversion_Rate_csr%NOTFOUND) THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        l_multiple_by := (l_duplicate_offset*l_UOM_Conversion_Rate_rec.conversion_rate)/24;

        p_duplicate_time_frame := sysdate - l_multiple_by;

	END CALCULATE_DUPLICATE_TIME_FRAME;*/

       l_duplicate_uom := UPPER(fnd_profile.value('CS_SR_DUP_TIME_FRAME_UOM'));
       l_duplicate_offset := fnd_profile.value('CS_SR_DUP_TIME_FRAME');

       If l_duplicate_uom = 'HR' Then
          p_duplicate_time_frame := sysdate - (l_duplicate_offset * 1/24);
       ElsIf l_duplicate_uom = 'DAY' Then
          p_duplicate_time_frame := sysdate - (l_duplicate_offset * 1);
       ElsIf l_duplicate_uom = 'MTH' Then
          p_duplicate_time_frame := sysdate - (l_duplicate_offset * 30);
       ElsIf l_duplicate_uom = 'WK' Then
          p_duplicate_time_frame := sysdate - (l_duplicate_offset * 7);
       ElsIf l_duplicate_uom = 'YR' Then
          p_duplicate_time_frame := sysdate - (l_duplicate_offset * 365);
       ElsIf l_duplicate_uom = 'MIN' Then
          p_duplicate_time_frame := sysdate - (l_duplicate_offset * 1/(24 * 60));
       ElsIf l_duplicate_uom = 'QRT' Then
          p_duplicate_time_frame := sysdate - (l_duplicate_offset * 30 * 3);
       ElsIf l_duplicate_uom = 'SEC' Then
          p_duplicate_time_frame := sysdate - (l_duplicate_offset * 1/(24 * 60 * 60));
       End If;

       /* End : 5686752 */

END CALCULATE_DUPLICATE_TIME_FRAME;


END CS_SR_DUP_CHK_PVT;

/
