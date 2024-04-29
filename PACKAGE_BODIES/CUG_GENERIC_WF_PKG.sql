--------------------------------------------------------
--  DDL for Package Body CUG_GENERIC_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_GENERIC_WF_PKG" AS
/* $Header: CUGGNWFB.pls 115.29 2003/03/28 19:56:55 rhungund noship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

    PROCEDURE GET_OTHER_SR_ATTRIBUTES(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 )
    IS

    l_install_site_use_id NUMBER;
    l_incident_location_id NUMBER;
    l_request_id	NUMBER;
    l_incident_type_id  NUMBER;
    l_tsk_type_id NUMBER;

    l_return_status	VARCHAR2(1);
    l_incident_address VARCHAR2(1000);
    l_result VARCHAR2(1);

    l_API_ERROR		EXCEPTION;

-- Start of change by ANEEMUCH date 09-May-2002
-- Capturing of incident address done in SR Tab
/*
    CURSOR l_ServiceRequest_csr IS
      SELECT INSTALL_SITE_USE_ID
        FROM CS_INCIDENTS_ALL_VL
       WHERE INCIDENT_ID = l_request_id;

    CURSOR l_IncidentAddress_csr IS
      SELECT ADDRESS1, ADDRESS2, CITY, STATE, COUNTRY, POSTAL_CODE
        FROM HZ_LOCATIONS WHERE LOCATION_ID = l_install_site_use_id;
    l_IncidentAddress_rec    l_IncidentAddress_csr%ROWTYPE;
*/

   CURSOR l_ServiceRequest_csr IS
     SELECT incident_location_id, incident_address, incident_city, incident_state,
            incident_postal_code, incident_country
     FROM    cs_incidents_all_b
     WHERE  incident_id = l_request_id;
    l_ServiceRequest_rec l_ServiceRequest_csr%ROWTYPE;

   CURSOR l_IncidentAddress_csr IS
      SELECT address, city, state, postal_code, country
      FROM   cs_sr_incident_address_v
      WHERE  location_id = l_incident_location_id;
   l_IncidentAddress_rec l_IncidentAddress_csr%ROWTYPE;

-- End of changes by ANEEMUCH date 09-May-2002

    CURSOR l_CheckIfSRHdrInfoPresent_csr IS
       select INCIDENT_TYPE_ID, SR_DUP_CHECK_FLAG from CUG_SR_TYPE_DUP_CHK_INFO
        WHERE INCIDENT_TYPE_ID = l_incident_type_id;
    l_CheckIfSRHdrInfoPresent_rec l_CheckIfSRHdrInfoPresent_csr%ROWTYPE;

    CURSOR l_CheckIfSRAttrPresent_csr IS
        SELECT incidnt_attr_val_id from CUG_INCIDNT_ATTR_VALS_VL
            WHERE INCIDENT_ID = l_request_id;
    l_CheckIfSRAttrPresent_rec  l_CheckIfSRAttrPresent_csr%ROWTYPE;

    CURSOR l_CheckIfTaskPresent_csr IS
        SELECT tsk_typ_attr_dep_id FROM CUG_TSK_TYP_ATTR_DEPS_B
            WHERE incident_type_id = l_incident_type_id;

    BEGIN

        IF (funmode = 'RUN') THEN
          l_request_id := WF_Engine.GetItemAttrNumber(itemtype => itemtype,
                                                      itemkey => itemkey,
                                                      aname => 'REQUEST_ID');

          OPEN l_CheckIfSRAttrPresent_csr;
          FETCH l_CheckIfSRAttrPresent_csr INTO l_CheckIfSRAttrPresent_rec;
          IF (l_CheckIfSRAttrPresent_csr%NOTFOUND) THEN
                SELECT incident_type_id into l_incident_type_id FROM CS_INCIDENTS_ALL_B WHERE
                    incident_id = l_request_id;

                l_result := 'Y';
                OPEN l_CheckIfSRHdrInfoPresent_csr;
                FETCH l_CheckIfSRHdrInfoPresent_csr into l_CheckIfSRHdrInfoPresent_rec;
                IF (l_CheckIfSRHdrInfoPresent_csr%NOTFOUND) THEN
                    l_result :=  'N' ;
                ELSE
                    l_result := 'Y';
                END IF;
                CLOSE l_CheckIfSRHdrInfoPresent_csr;


                OPEN l_CheckIfTaskPresent_csr;
                FETCH l_CheckIfTaskPresent_csr into l_tsk_type_id;
                IF (l_CheckIfTaskPresent_csr%NOTFOUND) THEN
                    IF (l_result = 'N') THEN
                        result :=  'N' ;
                     ELSE
                        result := 'Y';
                     END IF;
                ELSE
                    result := 'Y';
                END IF;
                CLOSE l_CheckIfTaskPresent_csr;
                return;
          ELSE
                result :=   'Y';
          END IF;

-- Start of changes by ANEEMUCH date 09-May-2002
/*
          OPEN l_ServiceRequest_csr;
          FETCH l_ServiceRequest_csr INTO l_install_site_use_id;

          IF (l_ServiceRequest_csr%NOTFOUND OR
              l_install_site_use_id is NULL) THEN
                  l_incident_address := '      ';
          ELSE
              OPEN l_IncidentAddress_csr;
              FETCH l_IncidentAddress_csr INTO l_IncidentAddress_rec;
              IF (l_IncidentAddress_csr%NOTFOUND) THEN
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              l_incident_address := l_IncidentAddress_rec.address1 || ',' ||
                                    l_IncidentAddress_rec.address2 || ',' ||
                                    l_IncidentAddress_rec.city || ',' ||
                                    l_IncidentAddress_rec.state || ' - '||
                                    l_IncidentAddress_rec.postal_code || ',' ||
                                    l_IncidentAddress_rec.country;
          END IF;
*/

         OPEN l_ServiceRequest_csr;
         FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;

         IF (l_ServiceRequest_rec.incident_location_id IS NULL) THEN

              l_incident_address := l_ServiceRequest_rec.incident_address || ',' ||
                                    l_ServiceRequest_rec.incident_city || ',' ||
                                    l_ServiceRequest_rec.incident_state || ' - '||
                                    l_ServiceRequest_rec.incident_postal_code || ',' ||
                                    l_ServiceRequest_rec.incident_country;
         ELSE
/* the following line added to fix bug # 2744139 */
             l_incident_location_id := l_ServiceRequest_rec.incident_location_id;
             OPEN l_IncidentAddress_csr;
             FETCH l_IncidentAddress_csr INTO l_IncidentAddress_rec;
             IF (l_IncidentAddress_csr%FOUND) THEN

              l_incident_address := l_IncidentAddress_rec.address || ',' ||
                                    l_IncidentAddress_rec.city || ',' ||
                                    l_IncidentAddress_rec.state || ' - '||
                                    l_IncidentAddress_rec.postal_code || ',' ||
                                    l_IncidentAddress_rec.country;
             ELSE
                l_incident_address := ' ';
             END IF;
             CLOSE l_IncidentAddress_csr;
         END IF;
         CLOSE l_ServiceRequest_csr;

-- End of changes by ANEEMUCH date 09-May-2002

          WF_ENGINE.SetItemAttrText(
	                   	itemtype	=> 'SERVEREQ',
                		itemkey		=> itemkey,
                		aname		=> 'CUG_INCIDENT_ADDRESS',
                		avalue		=> l_incident_address );

        END IF;
       result := 'Y';

  EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'GET_OTHER_SR_ATTRIBUTES',
                      itemtype, itemkey, actid, funmode);
      RAISE;
    WHEN OTHERS THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'GET_OTHER_SR_ATTRIBUTES',
		      itemtype, itemkey, actid, funmode);
      RAISE;

    END GET_OTHER_SR_ATTRIBUTES;




    PROCEDURE REPLACE_SR_OWNER(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 )
    IS

    l_request_id NUMBER;
    l_incident_type_id NUMBER;
    l_default_owner_id NUMBER := 0;
    l_msg_count NUMBER;
    l_interaction_id NUMBER;
    l_object_version_number NUMBER;


l_owner_id NUMBER;

    l_errmsg_name	VARCHAR2(30);
    l_resource_type VARCHAR2(11);
    l_msg_data      VARCHAR2(64);
    l_return_status VARCHAR2(64);

    CURSOR l_GetResourceID_csr IS
        select resource_id  FROM CUG_SR_TYPE_DUP_CHK_INFO
                    WHERE incident_type_id = l_incident_type_id;
    l_GetResourceID_rec l_GetResourceID_csr%ROWTYPE;



/* 2576759 - BEGIN - Added resource_type check in the where clause */
    CURSOR l_GetResourceName_csr IS
        select resource_name, resource_type from cs_sr_owners_v where
            resource_id = l_default_owner_id and
	    resource_type = 'RS_EMPLOYEE';
/* 2576759 - END - Added resource_type check in the where clause */
    l_GetResourceName_rec l_GetResourceName_csr%ROWTYPE;


/* begin - to fix bug # 2576759 - added the following cursors and variables */
    CURSOR l_GetResourceInfo_csr IS
        select incident_owner_id, owner_group_id, org_id from
         cs_incidents_all_b where
         incident_id = l_request_id;
    l_GetResourceInfo_rec l_GetResourceInfo_csr%ROWTYPE;

    CURSOR l_GetSourceId_csr IS
        select source_id from jtf_rs_resource_extns where
        resource_id = l_default_owner_id;
/* end - to fix bug # 2576759*/




/* bug fix : 1964270 */

    CURSOR l_GetPerson_Id_csr IS
        SELECT person_id FROM per_people_x
	   WHERE full_name = l_GetResourceName_rec.resource_name AND employee_number IS NOT NULL;

    l_person_id NUMBER;
/* bug fix : 1964270 */


/* Roopa - bug fix 2312069 */
    l_resource_id NUMBER;
    l_source_id NUMBER;

    l_owner_role	VARCHAR2(100);
    l_owner_name  	VARCHAR2(240);
    l_API_ERROR		  	EXCEPTION;

     CURSOR l_GetGroupResourceId_csr IS
        select resource_id from jtf_rs_group_members_vl where
            group_id = l_default_owner_id;

    CURSOR l_GetTeamResourceId_csr IS
        select team_resource_id from jtf_rs_team_members_vl where
            team_id = l_default_owner_id;
/* Roopa - bug fix 2312069 */

   BEGIN
        IF (funmode = 'RUN') THEN

          l_request_id := WF_Engine.GetItemAttrNumber(itemtype => itemtype,
                                                      itemkey => itemkey,
                                                      aname => 'REQUEST_ID');

          select INCIDENT_TYPE_ID into l_incident_type_id FROM
                CS_INCIDENTS_ALL_VL WHERE INCIDENT_ID = l_request_id;

          OPEN l_GetResourceID_csr;
          FETCH l_GetResourceID_csr INTO l_GetResourceID_rec;

           IF (l_GetResourceID_csr%NOTFOUND OR
                l_GetResourceID_rec.resource_id is null) THEN
            result := 'N';
          ELSE
            l_default_owner_id := l_GetResourceID_rec.resource_id;


            OPEN l_GetResourceName_csr;
            FETCH l_GetResourceName_csr INTO l_GetResourceName_rec;

            IF (l_GetResourceName_csr%NOTFOUND) THEN
                result := 'N';
            ELSE

/* begin - to fix bug # 2576759 -
   *)  if the current sr already has the group_id filled, do NOT update the inci
dent_owner id
   *)  if the current sr does not have the gorup is filled , but individual owne
r id filled - do not update the incident_owner id
   *)  if the current sr has no group and no current sr - update the incident_ow
ner id col with resp party id
*/

                OPEN l_GetResourceInfo_csr;
                FETCH l_GetResourceInfo_csr INTO l_GetResourceInfo_rec;
                IF (l_GetResourceInfo_csr%NOTFOUND) THEN
                      result := 'N';
                ELSE
                    l_resource_id := l_default_owner_id;
                    OPEN l_GetSourceId_csr;
                        LOOP
                        FETCH l_GetSourceId_csr INTO l_source_id;
                        EXIT ;
                        END LOOP;
                    IF (l_GetSourceId_csr%NOTFOUND) THEN
                        result := 'N';
                    ELSE
-- Retrieve the role name for the request owner
                        CS_WORKFLOW_PUB.Get_Employee_Role (
                        		p_api_version		=>  1.0,
                        		p_return_status		=>  l_return_status,
                        		p_msg_count		=>  l_msg_count,
                        		p_msg_data		=>  l_msg_data,
                        		p_employee_id  		=>  l_source_id,
                        		p_role_name		=>  l_owner_role,
                        		p_role_display_name	=>  l_owner_name );

                          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) OR
                             (l_owner_role is NULL) THEN
                               IF(FND_PROFILE.Value('CUG_DEFAULT_SR_WF_ROLE') is null) THEN
                                        wf_core.context( pkg_name	=>  'CUG_GENERIC_WKFLW_PKG',
			                                             proc_name	=>  'Replace_SR_Owner',
                                            			 arg1		=>  'p_owner_id=>'||
                                    					    to_char(l_source_id));
                                    	l_errmsg_name := 'CUG_INCIDENT_OWNER_NOT_VALID';
                                    	raise l_API_ERROR;
                                ELSE
                                    l_owner_role := FND_PROFILE.Value('CUG_DEFAULT_SR_WF_ROLE');
                                END IF; -- End of fnd_profile check
                          END IF; -- End of l_return_status check

		       END IF; -- If source id != null

                     END IF; -- End of resource_type check
/*
                  ELSE
                        l_owner_role := FND_PROFILE.Value('CUG_DEFAULT_SR_WF_ROLE');
                  END IF; --end of the entire if-then-else block
*/


               WF_ENGINE.SetItemAttrText(
                                itemtype        => 'SERVEREQ',
                                itemkey         => itemkey,
                                aname           => 'OWNER_NAME',
                                avalue          => l_owner_role );

/*
               WF_ENGINE.SetItemAttrText(
	                      	itemtype	=> 'SERVEREQ',
                     		itemkey		=> itemkey,
                    		aname		=> 'OWNER_NAME',
                    		avalue		=> l_GetResourceName_rec.resource_name );


               WF_ENGINE.SetItemAttrText(
	                      	itemtype	=> 'SERVEREQ',
                     		itemkey		=> itemkey,
                    		aname		=> 'OWNER_ROLE',
                    		avalue		=> l_owner_role );
*/

                result := 'Y';

             END IF;
          END IF;
      END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'REPLACE_SR_OWNER',
		      itemtype, itemkey, actid, funmode);
      RAISE;
 END REPLACE_SR_OWNER;



   PROCEDURE ALLOW_ADDRESS_OVERWRITE(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 )
    IS

    l_request_id NUMBER;
    l_incident_type_id NUMBER;
    l_default_owner_id NUMBER;
    l_msg_count NUMBER;

    l_address_overwrite_flag VARCHAR2(1) := NULL;
    l_errmsg_name	VARCHAR2(30);
    l_resource_type VARCHAR2(11);
    l_msg_data      VARCHAR2(64);
    l_return_status VARCHAR2(64);

    l_API_ERROR		  	EXCEPTION;

    CURSOR c_GetOverrideFlag_csr IS
         SELECT DISTINCT OVERRIDE_ADDR_VALID_FLAG FROM CUG_INCIDNT_ATTR_VALS_B
          WHERE INCIDENT_ID = l_request_id;


    BEGIN

        IF (funmode = 'RUN') THEN

          l_request_id := WF_Engine.GetItemAttrNumber(itemtype => itemtype,
                                                      itemkey => itemkey,
                                                      aname => 'REQUEST_ID');

            OPEN c_GetOverrideFlag_csr;
            FETCH c_GetOverrideFlag_csr into l_address_overwrite_flag;

            IF(c_GetOverrideFlag_csr%NOTFOUND OR
               l_address_overwrite_flag = 'N') THEN
                result := 'N';
            ELSE
                result := 'Y';
            END IF;
            CLOSE c_GetOverrideFlag_csr;
        END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'ALLOW_ADDRESS_OVERWRITE',
                      itemtype, itemkey, actid, funmode);
      RAISE;
    WHEN OTHERS THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'ALLOW_ADDRESS_OVERWRITE',
		      itemtype, itemkey, actid, funmode);
      RAISE;

    END ALLOW_ADDRESS_OVERWRITE;



    PROCEDURE DUPLICATE_CHECKING_REQUIRED(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 )
    IS
    l_request_id NUMBER;
    l_request_type_id NUMBER;
    l_msg_count NUMBER;
    l_address_overwrite_flag NUMBER;

    l_duplicate_check_flag VARCHAR2(1);
    l_errmsg_name	VARCHAR2(30);
    l_resource_type VARCHAR2(11);
    l_msg_data      VARCHAR2(64);
    l_return_status VARCHAR2(64);

    l_API_ERROR		  	EXCEPTION;

    CURSOR c_CheckIfDupCheckOn_csr IS
       select SR_DUP_CHECK_FLAG from CUG_SR_TYPE_DUP_CHK_INFO
        WHERE INCIDENT_TYPE_ID = l_request_type_id;


    BEGIN
        IF (funmode = 'RUN') THEN

          l_request_id := WF_Engine.GetItemAttrNumber(itemtype => itemtype,
                                                      itemkey => itemkey,
                                                      aname => 'REQUEST_ID');

          select INCIDENT_TYPE_ID into l_request_type_id from CS_INCIDENTS_ALL_VL
                WHERE INCIDENT_ID = l_request_id;

          OPEN c_CheckIfDupCheckOn_csr;
          FETCH c_CheckIfDupCheckOn_csr into l_duplicate_check_flag;
          IF (c_CheckIfDupCheckOn_csr%NOTFOUND) THEN
            l_duplicate_check_flag := 'N';
          END IF;
          CLOSE c_CheckIfDupCheckOn_csr;

          IF (l_duplicate_check_flag = 'Y') THEN
            result := 'Y';
          ELSE
            result := 'N';
          END IF;

        END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'DUPLICATE_CHECKING_REQUIRED',
                      itemtype, itemkey, actid, funmode);
      RAISE;
    WHEN OTHERS THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'DUPLICATE_CHECKING_REQUIRED',
		      itemtype, itemkey, actid, funmode);
      RAISE;
   END DUPLICATE_CHECKING_REQUIRED;



   PROCEDURE SR_A_DUPLICATE(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 )
   IS
    l_request_id NUMBER;
    l_request_type_id NUMBER;
    l_msg_count NUMBER;
    l_install_at_site_id NUMBER;
    l_match_found NUMBER;

    l_incident_location_id NUMBER;
    l_incident_address     VARCHAR2(960);
    l_incident_city        VARCHAR2(60);
    l_incident_state       VARCHAR2(60);
    l_incident_postal_code VARCHAR2(60);
    l_incident_country     VARCHAR2(60);

    l_counter NUMBER;
    l_attr_counter NUMBER;
    l_incident_counter NUMBER;

    l_errmsg_name	VARCHAR2(30);
    l_resource_type VARCHAR2(11);
    l_msg_data      VARCHAR2(64);
    l_return_status VARCHAR2(64);

    l_SRAttribute_value_new VARCHAR2(1997);
    l_SRAttribute_value_old VARCHAR2(1997);
    l_sql_stmt VARCHAR2(2000);
    l_sql_stmt1 VARCHAR2(2000);

    l_owner_name VARCHAR2(240);

    l_duplicate_date DATE;

    l_API_ERROR		  	EXCEPTION;

-- Begin of changes by ANEEMUCH date 10-May-2002
/*
    CURSOR l_IncidentAddress_csr IS
        select ADDRESS1, ADDRESS2, CITY, STATE, POSTAL_CODE, COUNTRY FROM
            HZ_LOCATIONS where LOCATION_ID = l_install_at_site_id;
    l_IncidentAddress_rec    l_IncidentAddress_csr%ROWTYPE;

    CURSOR l_IncidentId_csr IS
        SELECT CS_INCIDENTS_ALL_VL.INCIDENT_ID,CS_INCIDENTS_ALL_VL.INCIDENT_NUMBER
            FROM CS_INCIDENTS_ALL_VL, HZ_LOCATIONS
            WHERE HZ_LOCATIONS.LOCATION_ID = CS_INCIDENTS_ALL_VL.INSTALL_SITE_USE_ID AND
                  HZ_LOCATIONS.ADDRESS1 = l_IncidentAddress_rec.Address1 AND
                  nvl(HZ_LOCATIONS.ADDRESS2, 'Not Filled') = nvl(l_IncidentAddress_rec.Address2, 'Not Filled') AND
                  nvl(HZ_LOCATIONS.CITY, 'Not Filled') = nvl(l_IncidentAddress_rec.City, 'Not Filled') AND
                  nvl(HZ_LOCATIONS.STATE, 'Not Filled') = nvl(l_IncidentAddress_rec.State, 'Not Filled') AND
                  nvl(HZ_LOCATIONS.POSTAL_CODE, 'Not Filled') =  nvl(l_IncidentAddress_rec.Postal_Code, 'Not Filled') AND
--                  HZ_LOCATIONS.COUNTRY =  l_IncidentAddress_rec.Country AND
                  CS_INCIDENTS_ALL_VL.LAST_UPDATE_DATE > l_duplicate_date AND
                  CS_INCIDENTS_ALL_VL.INCIDENT_TYPE_ID = l_request_type_id AND
                  CS_INCIDENTS_ALL_VL.INCIDENT_ID <> l_request_id;
    l_IncidentId_rec    l_IncidentId_csr%ROWTYPE;
*/

   CURSOR l_ServiceRequest_csr IS
     SELECT incident_location_id, incident_address, incident_city, incident_state,
            incident_postal_code, incident_country
     FROM    cs_incidents_all_b
     WHERE  incident_id = l_request_id;
    l_ServiceRequest_rec l_ServiceRequest_csr%ROWTYPE;

   CURSOR l_IncidentAddress_csr IS
      SELECT address, city, state, postal_code, country
      FROM   cs_sr_incident_address_v
      WHERE  location_id = l_incident_location_id;
   l_IncidentAddress_rec l_IncidentAddress_csr%ROWTYPE;

    CURSOR l_IncidentId_csr IS
        SELECT CS_INCIDENTS_ALL_VL.INCIDENT_ID,CS_INCIDENTS_ALL_VL.INCIDENT_NUMBER
            FROM CS_INCIDENTS_ALL_VL, HZ_LOCATIONS
            WHERE HZ_LOCATIONS.LOCATION_ID = CS_INCIDENTS_ALL_VL.INCIDENT_LOCATION_ID AND
                  nvl(HZ_LOCATIONS.ADDRESS1, 'Not Filled') = nvl(l_incident_address, 'Not Filled') AND
                  nvl(HZ_LOCATIONS.CITY, 'Not Filled') = nvl(l_incident_city, 'Not Filled') AND
                  nvl(HZ_LOCATIONS.STATE, 'Not Filled') = nvl(l_incident_state, 'Not Filled') AND
                  nvl(HZ_LOCATIONS.POSTAL_CODE, 'Not Filled') =  nvl(l_incident_postal_Code, 'Not Filled') AND
                  nvl(HZ_LOCATIONS.COUNTRY, 'Not Filled') =  nvl(l_incident_country, 'Not Filled') AND
                  CS_INCIDENTS_ALL_VL.LAST_UPDATE_DATE > l_duplicate_date AND
                  CS_INCIDENTS_ALL_VL.INCIDENT_TYPE_ID = l_request_type_id AND
                  CS_INCIDENTS_ALL_VL.INCIDENT_ID <> l_request_id
        UNION
        SELECT CS_INCIDENTS_ALL_VL.INCIDENT_ID,CS_INCIDENTS_ALL_VL.INCIDENT_NUMBER
            FROM CS_INCIDENTS_ALL_VL
            WHERE nvl(incident_ADDRESS, 'Not Filled') = nvl(l_incident_address, 'Not Filled') AND
                  nvl(incident_CITY, 'Not Filled') = nvl(l_incident_city, 'Not Filled') AND
                  nvl(incident_STATE, 'Not Filled') = nvl(l_incident_state, 'Not Filled') AND
                  nvl(incident_POSTAL_CODE, 'Not Filled') =  nvl(l_incident_postal_Code, 'Not Filled') AND
                  nvl(incident_COUNTRY, 'Not Filled') =  nvl(l_incident_country, 'Not Filled') AND
                  LAST_UPDATE_DATE > l_duplicate_date AND
                  INCIDENT_TYPE_ID = l_request_type_id AND
                  INCIDENT_ID <> l_request_id;
        l_IncidentId_rec    l_IncidentId_csr%ROWTYPE;

-- End of changes by ANEEMUCH date 10-May-2002
--

-- Changed the where condition to fix bug # 2471602
    CURSOR l_IncidentId_noLoc_csr IS
        SELECT CS_INCIDENTS_ALL_VL.INCIDENT_ID,CS_INCIDENTS_ALL_VL.INCIDENT_NUMBER
            FROM CS_INCIDENTS_ALL_VL
            WHERE CS_INCIDENTS_ALL_VL.LAST_UPDATE_DATE > l_duplicate_date AND
                  CS_INCIDENTS_ALL_VL.INCIDENT_TYPE_ID = l_request_type_id AND
                  CS_INCIDENTS_ALL_VL.INCIDENT_ID <> l_request_id AND
                  CS_INCIDENTS_ALL_VL.INCIDENT_LOCATION_ID is NULL AND
                  CS_INCIDENTS_ALL_VL.incident_ADDRESS is NULL AND
                  CS_INCIDENTS_ALL_VL.incident_CITY is NULL AND
                  CS_INCIDENTS_ALL_VL.incident_STATE is NULL AND
                  CS_INCIDENTS_ALL_VL.incident_POSTAL_CODE is NULL AND
                  CS_INCIDENTS_ALL_VL.incident_COUNTRY is NULL;
    l_IncidentId_noLoc_rec    l_IncidentId_noLoc_csr%ROWTYPE;


   CURSOR l_DuplicateCheckAttrs_csr IS
        select SR_ATTRIBUTE_CODE from CUG_SR_TYPE_ATTR_MAPS_VL
             where INCIDENT_TYPE_ID = l_request_type_id AND
                    SR_ATTR_DUP_CHECK_FLAG = 'Y' AND
                   ( END_DATE_ACTIVE IS NULL OR
                     to_number(to_char(END_DATE_ACTIVE, 'YYYYMMDD')) >= to_number(to_char(sysdate, 'YYYYMMDD')) );
   l_DuplicateCheckAttrs_rec l_DuplicateCheckAttrs_csr%ROWTYPE;


  CURSOR l_NewDupAttrValue_csr IS
       SELECT sr_attribute_value FROM cug_incidnt_attr_vals_vl WHERE
              sr_attribute_code = l_DuplicateCheckAttrs_rec.sr_attribute_code AND
              incident_id = l_request_id;

  CURSOR l_OldDupAttrValue_csr IS
       SELECT sr_attribute_value FROM cug_incidnt_attr_vals_vl WHERE
              sr_attribute_code = l_DuplicateCheckAttrs_rec.sr_attribute_code AND
              incident_id = l_IncidentId_rec.Incident_Id;

  CURSOR l_OldDupAttrValue_noLoc_csr IS
       SELECT sr_attribute_value FROM cug_incidnt_attr_vals_vl WHERE
              sr_attribute_code = l_DuplicateCheckAttrs_rec.sr_attribute_code AND
              incident_id = l_IncidentId_noLoc_rec.Incident_Id;


    TYPE IncidentList IS VARRAY(400) OF CS_INCIDENTS_ALL_VL.incident_id%TYPE;
   l_IncidentList IncidentList := IncidentList();


   TYPE SRAttrDupCheck IS REF CURSOR;
   l_SRAttrDupCheck_str  SRAttrDupCheck;
   l_SRAttrDupCheck_rec  CS_INCIDENTS_ALL_VL.incident_id%TYPE;


   BEGIN
        IF (funmode = 'RUN') THEN

          l_attr_counter := 0;
          l_incident_counter := 1;

          l_request_id := WF_Engine.GetItemAttrNumber(itemtype => itemtype,
                                                      itemkey => itemkey,
                                                      aname => 'REQUEST_ID');

          l_owner_name  := WF_Engine.GetItemAttrText(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'OWNER_NAME');

-- Beging of changes by ANEEMUCH date 10-May-2002
/*
           select INSTALL_SITE_USE_ID into l_install_at_site_id
            from CS_INCIDENTS_ALL_VL where INCIDENT_ID = l_request_id;
*/

          OPEN l_ServiceRequest_csr;
          FETCH l_ServiceRequest_csr into l_ServiceRequest_rec;
          IF (l_ServiceRequest_rec.incident_location_id IS NOT NULL) THEN

	      -- Fix for bug# 2500202. Initialize l_incident_location_id used for
	      -- cursor l_IncidentAddress_csr. rmanabat 08/07/02.
	      l_incident_location_id := l_ServiceRequest_rec.incident_location_id;

              OPEN l_IncidentAddress_csr;
              FETCH l_IncidentAddress_csr INTO l_IncidentAddress_rec;
              IF (l_IncidentAddress_csr%FOUND) THEN
                 l_incident_address         := l_IncidentAddress_rec.address;
                 l_incident_city            := l_IncidentAddress_rec.city;
                 l_incident_state           := l_IncidentAddress_rec.state;
                 l_incident_postal_code     := l_IncidentAddress_rec.postal_code;
                 l_incident_country         := l_IncidentAddress_rec.country;
              END IF;
              CLOSE l_IncidentAddress_csr;
          ELSE
              l_incident_address         := l_ServiceRequest_rec.incident_address;
              l_incident_city            := l_ServiceRequest_rec.incident_city;
              l_incident_state           := l_ServiceRequest_rec.incident_state;
              l_incident_postal_code     := l_ServiceRequest_rec.incident_postal_code;
              l_incident_country         := l_ServiceRequest_rec.incident_country;
          END IF;
          CLOSE l_ServiceRequest_csr;
-- End of changes by ANEEMUCH date 10-May-2002

          select INCIDENT_TYPE_ID into l_request_type_id
            from CS_INCIDENTS_ALL_VL where INCIDENT_ID = l_request_id;

-- Begin changes by ANEEMUCH 10-May-2002
--          IF ( l_install_at_site_id IS NOT NULL) THEN
         IF (l_incident_address IS NOT NULL OR l_incident_city IS NOT NULL OR
             l_incident_state IS NOT NULL OR l_incident_postal_code IS NOT NULL OR
             l_incident_country IS NOT NULL) Then

             CALCULATE_DUPLICATE_TIME_FRAME(p_service_request_id => l_request_id,
                                            p_request_type_id => l_request_type_id,
                                            p_duplicate_time_frame => l_duplicate_date);


             IF (l_duplicate_date IS NULL) THEN
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;

-- Begin changes by ANEEMUCH 13-May-2002
/*
             OPEN l_IncidentAddress_csr;
             FETCH l_IncidentAddress_csr into l_IncidentAddress_rec;
             IF (l_IncidentAddress_csr%NOTFOUND) THEN
                 RAISE fnd_api.g_exc_unexpected_error;
             END IF;
*/
-- End of changes by ANEEMUCH 13-May-2002

             l_match_found := 1;
             OPEN l_IncidentId_csr;
             LOOP

                FETCH l_IncidentId_csr into l_IncidentId_rec;
                EXIT WHEN l_IncidentId_csr%NOTFOUND;


                OPEN l_DuplicateCheckAttrs_csr;
                 LOOP
                     FETCH l_DuplicateCheckAttrs_csr into l_DuplicateCheckAttrs_rec;
                     EXIT WHEN l_DuplicateCheckAttrs_csr%NOTFOUND;

                        l_sql_stmt := 'select sr_attribute_value from cug_incidnt_attr_vals_vl where sr_attribute_code = '
                                    || l_DuplicateCheckAttrs_rec.sr_attribute_code ||  ' and incident_id = :incident_id';

                  OPEN l_NewDupAttrValue_csr;
                  FETCH l_NewDupAttrValue_csr into  l_SRAttribute_value_new;
                  IF(l_NewDupAttrValue_csr%NOTFOUND) THEN
                     l_SRAttribute_value_new := ' ';
                  END IF;
                  CLOSE l_NewDupAttrValue_csr;

                  OPEN l_OldDupAttrValue_csr;
                  FETCH l_OldDupAttrValue_csr into  l_SRAttribute_value_old;
                  IF(l_OldDupAttrValue_csr%NOTFOUND) THEN
                     l_SRAttribute_value_old := ' ';
                  END IF;
                  CLOSE l_OldDupAttrValue_csr;

                        IF (l_SRAttribute_value_new <> l_SRAttribute_value_old) THEN
                            l_match_found := 0;
                            exit;
                        ELSIF (l_SRAttribute_value_new = l_SRAttribute_value_old) THEN
                            l_match_found := 1;
                        END IF;
                 END LOOP;
                 CLOSE l_DuplicateCheckAttrs_csr;

                 IF (l_match_found = 1) THEN
                        result := 'Y';
                        Wf_Engine.SetItemAttrNumber(itemtype => itemtype,
                                                    itemkey => itemkey,
                                                    aname => 'CUG_PARENT_REQUEST_ID',
                                                    avalue => l_IncidentId_rec.Incident_Id);
                        Wf_Engine.SetItemAttrText(itemtype => itemtype,
                                                    itemkey => itemkey,
                                                    aname => 'CUG_PARENT_REQUEST_NUMBER',
                                                    avalue => l_IncidentId_rec.Incident_Number);
                        return;
                 END IF;

             END LOOP;
             CLOSE l_IncidentId_csr;
         ELSE

             CALCULATE_DUPLICATE_TIME_FRAME(p_service_request_id => l_request_id,
                                            p_request_type_id => l_request_type_id,
                                            p_duplicate_time_frame => l_duplicate_date);


             IF (l_duplicate_date IS NULL) THEN
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;


             l_match_found := 1;
             OPEN l_IncidentId_noLoc_csr;
             LOOP

                FETCH l_IncidentId_noLoc_csr into l_IncidentId_noLoc_rec;
                EXIT WHEN l_IncidentId_noLoc_csr%NOTFOUND;


                OPEN l_DuplicateCheckAttrs_csr;
                LOOP
                     FETCH l_DuplicateCheckAttrs_csr into l_DuplicateCheckAttrs_rec;
                     EXIT WHEN l_DuplicateCheckAttrs_csr%NOTFOUND;

                        l_sql_stmt := 'select sr_attribute_value from cug_incidnt_attr_vals_vl where sr_attribute_code = '
                                    || l_DuplicateCheckAttrs_rec.sr_attribute_code ||  ' and incident_id = :incident_id';

                  OPEN l_NewDupAttrValue_csr;
                  FETCH l_NewDupAttrValue_csr into  l_SRAttribute_value_new;
                  IF(l_NewDupAttrValue_csr%NOTFOUND) THEN
                     l_SRAttribute_value_new := ' ';
                  END IF;
                  CLOSE l_NewDupAttrValue_csr;

                  OPEN l_OldDupAttrValue_noLoc_csr;
                  FETCH l_OldDupAttrValue_noLoc_csr into  l_SRAttribute_value_old;
                  IF(l_OldDupAttrValue_noLoc_csr%NOTFOUND) THEN
                     l_SRAttribute_value_old := ' ';
                  END IF;
                  CLOSE l_OldDupAttrValue_noLoc_csr;

                        IF (l_SRAttribute_value_new <> l_SRAttribute_value_old) THEN
                            l_match_found := 0;
                            exit;
                        ELSIF (l_SRAttribute_value_new = l_SRAttribute_value_old) THEN
                            l_match_found := 1;
                        END IF;
                 END LOOP;
                 CLOSE l_DuplicateCheckAttrs_csr;

                 IF (l_match_found = 1) THEN
                        result := 'Y';
                        Wf_Engine.SetItemAttrNumber(itemtype => itemtype,
                                                    itemkey => itemkey,
                                                    aname => 'CUG_PARENT_REQUEST_ID',
                                                    avalue => l_IncidentId_noLoc_rec.Incident_Id);
                        Wf_Engine.SetItemAttrText(itemtype => itemtype,
                                                    itemkey => itemkey,
                                                    aname => 'CUG_PARENT_REQUEST_NUMBER',
                                                    avalue => l_IncidentId_noLoc_rec.Incident_Number);
                        return;
                 END IF;

             END LOOP;
             CLOSE l_IncidentId_noLoc_csr;

      END IF;

        result := 'N';
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'SR_A_DUPLICATE',
              itemtype, itemkey, actid, funmode);
      RAISE;
    WHEN l_API_ERROR THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'SR_A_DUPLICATE',
                      itemtype, itemkey, actid, funmode);
      RAISE;
    WHEN OTHERS THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'SR_A_DUPLICATE',
		      itemtype, itemkey, actid, funmode);
      RAISE;


   END SR_A_DUPLICATE;



   PROCEDURE UPDATE_DUPLICATE_INFO(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 )
   IS
        l_request_id        NUMBER;
        l_request_type_id   NUMBER;
        l_default_owner_id  NUMBER;
        l_note_id           NUMBER;
        l_note_context_id   NUMBER;
        l_note_context_type_id NUMBER;
        l_last_updated_by NUMBER(15):= FND_GLOBAL.USER_ID;
        l_created_by NUMBER(15) := FND_GLOBAL.USER_ID;
        l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;

        l_msg_count		NUMBER;

        l_return_status	VARCHAR2(1);
        l_msg_data		VARCHAR2(2000);
       	l_note_context_type VARCHAR2(240);

        l_API_ERROR		  	EXCEPTION;

        CURSOR c_SR_Attr_Note_csr IS
            SELECT jtf_note_id from JTF_NOTES_B WHERE
                note_type = 'CUG_SR_ATTR_DETAILS' AND
                source_object_code = 'SR' AND
                source_object_id = l_request_id;
        l_SR_Attr_Note_rec c_SR_Attr_Note_csr%ROWTYPE;

    BEGIN

        IF (funmode = 'RUN') THEN

          l_request_id := WF_Engine.GetItemAttrNumber(itemtype => itemtype,
                                                      itemkey => itemkey,
                                                      aname => 'REQUEST_ID');

          select INCIDENT_TYPE_ID into l_request_type_id FROM
                CS_INCIDENTS_ALL_VL WHERE INCIDENT_ID = l_request_id;

          select RESOURCE_ID into l_default_owner_id FROM CUG_SR_TYPE_DUP_CHK_INFO
                WHERE Incident_Type_ID = l_request_type_id;


          IF (l_default_owner_id is not null ) THEN

/*
             JTF_NOTES_PUB.Create_note
              ( p_api_version	=> 	1.0,
                x_return_status	=>  l_return_status,
                x_msg_count		=>  l_msg_count,
                x_msg_data		=>  l_msg_data,
                p_source_object_id		=>  l_request_id,
                p_source_object_code	=>  'SR',
                p_notes			=> 'This Service Request is a duplicate.',
                p_entered_by	=> l_default_owner_id,
                p_entered_date  => sysdate,
                x_jtf_note_id	=> l_note_id,
                p_last_update_date	=> sysdate,
                p_last_updated_by	=> l_default_owner_id,
     	      	p_creation_date     => sysdate,
                p_note_type         => 'Duplicate Service Request'
              );

              IF NOT (l_return_status = fnd_api.g_ret_sts_success)
              THEN
                    l_return_status := fnd_api.g_ret_sts_unexp_error;
                    RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              JTF_NOTES_PUB.Create_note_context (
                    x_return_status => l_return_status,
	               	p_jtf_note_id	=>  l_note_id,
                    p_last_update_date => sysdate,
               	  	p_last_updated_by  => l_default_owner_id,
             		p_creation_date => sysdate,
                    p_note_context_type_id => l_note_context_id,
                    p_note_context_type => 'Duplicate',
                    x_note_context_id   => l_note_context_id);


              IF NOT (l_return_status = fnd_api.g_ret_sts_success)
              THEN
                    l_return_status := fnd_api.g_ret_sts_unexp_error;
                    RAISE fnd_api.g_exc_unexpected_error;
              END IF;
*/

   	SELECT jtf_notes_s.NEXTVAL INTO l_note_context_id  FROM dual;

    OPEN c_SR_Attr_Note_csr;
    FETCH c_SR_Attr_Note_csr into l_note_id;

    l_note_context_type_id := WF_Engine.GetItemAttrNumber(itemtype => itemtype,
                                                          itemkey => itemkey,
                                                          aname => 'CUG_PARENT_REQUEST_ID');


           INSERT INTO JTF_NOTE_CONTEXTS(
               NOTE_CONTEXT_ID,
               JTF_NOTE_ID,
               NOTE_CONTEXT_TYPE_ID,
               NOTE_CONTEXT_TYPE,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_LOGIN)
        	 VALUES
               (l_note_context_id,
                l_note_id,
                l_note_context_type_id,
            	'CUG_DUPLICATE_SR',
                sysdate,
                l_last_updated_by,
                sysdate,
                l_created_by,
                l_last_update_login);

            ELSE
                RAISE fnd_api.g_exc_unexpected_error;
           END IF;
        END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'UPDATE_DUPLICATE_INFO',
                      itemtype, itemkey, actid, funmode);
      RAISE;
    WHEN OTHERS THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'UPDATE_DUPLICATE_INFO',
		      itemtype, itemkey, actid, funmode);
      RAISE;


   END UPDATE_DUPLICATE_INFO;



  PROCEDURE CREATE_ALL_SR_TASKS(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 )
  IS

          l_request_id NUMBER;
          l_request_type_id NUMBER;
          l_msg_count NUMBER;
          l_create_task NUMBER;
          l_task_id NUMBER;
          l_tsk_typ_attr_dep_id NUMBER;
          l_task_type_id NUMBER;
/* To fix bug # - 1966258 - Start */
          l_task_assignment_id NUMBER;
          l_user_id NUMBER;
/* To fix bug # - 1966258 - Start */

          l_return_status VARCHAR2(30);
          l_msg_data VARCHAR2(300);
          l_sr_attribute_value VARCHAR2(1997);
          l_workflow_name VARCHAR2(30);
          l_sr_attribute_code VARCHAR2(30);
/* Begin - 09/24/2001 - change made to accomodate Rahul's problem with update_task API */
/*  added the following parameter */
          l_request_number VARCHAR2(64);
/* End - 09/24/2001 - change made to accomodate Rahul's problem with update_task API */

          l_planned_start_date date;
          l_planned_end_date date;
          l_scheduled_start_date date;
          l_scheduled_end_date date;

        l_API_ERROR		  	EXCEPTION;

          CURSOR c_SRTasks_csr
          IS
            SELECT * FROM CUG_TSK_TYP_ATTR_DEPS_VL WHERE INCIDENT_TYPE_ID = l_request_type_id AND
            (START_DATE_ACTIVE IS NULL OR
             to_number(to_char(START_DATE_ACTIVE, 'YYYYMMDD')) <= to_number(to_char(sysdate, 'YYYYMMDD')) ) AND
             (END_DATE_ACTIVE is NULL OR
              to_number(to_char(END_DATE_ACTIVE, 'YYYYMMDD')) >= to_number(to_char(sysdate, 'YYYYMMDD')) );
          l_SRTasks_rec c_SRTasks_csr%ROWTYPE;

          CURSOR c_SRTasks_Details_csr
          IS
            SELECT * FROM CUG_SR_TASK_TYPE_DETS_VL WHERE
                TSK_TYP_ATTR_DEP_ID = l_tsk_typ_attr_dep_id;
          l_SRTasks_Details_rec  c_SRTasks_Details_csr%ROWTYPE;


          CURSOR c_SRAttr_Value_csr
          IS
            SELECT SR_ATTRIBUTE_VALUE FROM CUG_INCIDNT_ATTR_VALS_VL WHERE
                INCIDENT_ID = l_request_id AND
                SR_ATTRIBUTE_CODE = l_sr_attribute_code;
          l_SRAttr_Value_rec  c_SRAttr_Value_csr%ROWTYPE;


           CURSOR c_Workflow_Check_csr
           IS
             SELECT workflow  FROM JTF_TASK_TYPES_B
                WHERE task_type_id = l_task_type_id;
           l_Workflow_Check_rec c_Workflow_Check_csr%ROWTYPE;

           CURSOR c_LookupCode_Check_csr
           IS
            SELECT lookup_code from FND_LOOKUP_VALUES where
                description = l_sr_attribute_value;
           l_LookupCode_Check_rec c_LookupCode_Check_csr%ROWTYPE;


    BEGIN


-- Get the list of tasks for the given SR type
-- For each task, see if it is dependent on a SR attribute
-- If yes, get teh value it is dependent on.
-- Also, get the runtime value for the attribute
-- Compare the 2. If they match, then, create the task
-- Else, skip the task creation for that particular task


   IF (funmode = 'RUN') THEN

        l_request_id := WF_Engine.GetItemAttrNumber(itemtype => itemtype,
                                                    itemkey => itemkey,
                                                    aname => 'REQUEST_ID');
/* Begin - 09/24/2001 - change made to accomodate Rahul's problem with update_task API */
        l_request_number := WF_Engine.GetItemAttrText(itemtype => itemtype,
                                                    itemkey => itemkey,
                                                    aname => 'REQUEST_NUMBER');
/* End - 09/24/2001 - change made to accomodate Rahul's problem with update_task API */

        SELECT INCIDENT_TYPE_ID into l_request_type_id FROM CS_INCIDENTS_ALL_VL WHERE
                    INCIDENT_ID = l_request_id;

        l_create_task := 1;

/* 08/30 -- to begin bug# 1964265 */
                result := 'Y';
/* 08/30 -- to end bug# 1964265 */

--          FOR l_SRTasks_rec IN c_SRTasks_csr LOOP

          OPEN c_SRTasks_csr;
          LOOP

            FETCH c_SRTasks_csr into l_SRTasks_rec;
             EXIT WHEN c_SRTasks_csr%NOTFOUND;

             l_tsk_typ_attr_dep_id  := l_SRTasks_rec.tsk_typ_attr_dep_id;
             l_sr_attribute_code := l_SRTasks_rec.sr_attribute_code;


             IF (l_SRTasks_rec.sr_attribute_code IS NOT NULL) THEN
                OPEN c_SRAttr_Value_csr;
                FETCH c_SRAttr_Value_csr into l_SRAttr_Value_rec;
                IF (c_SRAttr_Value_csr%NOTFOUND) THEN
                    RAISE fnd_api.g_exc_unexpected_error;
                ELSIF (l_SRAttr_Value_rec.sr_attribute_value IS NULL) THEN
                    null;
                ELSE
                    l_sr_attribute_value := l_SRAttr_Value_rec.sr_attribute_value;
                    OPEN c_LookupCode_Check_csr;
                    LOOP
                        FETCH c_LookupCode_Check_csr into l_LookupCode_Check_rec;
                        EXIT WHEN c_LookupCode_Check_csr%NOTFOUND;

                        IF ( l_LookupCode_Check_rec.lookup_code =  l_SRTasks_rec.sr_attribute_value) THEN
                               l_create_task := 1;
															 exit;
                        ELSE
                                l_create_task := 0;
                        END IF;

                    END LOOP;
                    CLOSE c_LookupCode_Check_csr;
/*
                    IF (l_SRTasks_rec.sr_attribute_value = l_SRAttr_Value_rec.sr_attribute_value) THEN
                        l_create_task := 1;
                    ELSE
                        l_create_task := 0;
                    END IF;
*/
                END IF;
                CLOSE c_SRAttr_Value_csr;
            END IF;

            IF (l_SRTasks_rec.sr_attribute_code IS NULL) THEN
                l_create_task := 1;
            END IF;

            IF (l_create_task > 0) THEN
                OPEN c_SRTasks_Details_csr;
                FETCH c_SRTasks_Details_csr INTO l_SRTasks_Details_rec;

            CALCULATE_DATE(p_uom => l_SRTasks_Details_rec.planned_start_uom,
                           p_offset => l_SRTasks_Details_rec.planned_start_offset,
                           x_date => l_planned_start_date);

            CALCULATE_DATE(p_uom => l_SRTasks_Details_rec.planned_end_uom,
                           p_offset => l_SRTasks_Details_rec.planned_end_offset,
                           x_date => l_planned_end_date);

            CALCULATE_DATE(p_uom => l_SRTasks_Details_rec.scheduled_start_uom,
                           p_offset => l_SRTasks_Details_rec.scheduled_start_offset,
                           x_date => l_scheduled_start_date);

            CALCULATE_DATE(p_uom => l_SRTasks_Details_rec.scheduled_end_uom,
                           p_offset => l_SRTasks_Details_rec.scheduled_end_offset,
                           x_date => l_scheduled_end_date);

/* 08/30 -- begin - to fix bug# 1964265 */
       VALIDATE_TASK_DETAILS(p_task_type_id => l_SRTasks_rec.task_type_id,
                             p_task_status_id => l_SRTasks_Details_rec.task_status_id,
                             p_task_priority_id => l_SRTasks_Details_rec.task_priority_id,
                             p_itemkey => itemkey,
                             p_return_status => l_return_status);
       IF NOT (l_return_status = 'S') THEN
           result := 'N';
       ELSE
/* 08/30 -- begin - to fix bug# 1964265 */

                  FND_PROFILE.Get('USER_ID', l_user_id);

                  JTF_TASKS_PUB.create_task (
                  p_api_version  => 1.0,
                  p_task_name  => l_SRTasks_Details_rec.task_name,
                  p_task_type_id  => l_SRTasks_rec.task_type_id,
/* 08/30 -- begin - to fix bug# 1966258 - made the status to point to the config caprured value*/
                  p_task_status_id  => l_SRTasks_Details_rec.task_status_id,
/* 08/30 -- begin - to fix bug# 1966258 */
                  p_task_priority_id  => l_SRTasks_Details_rec.task_priority_id,
                  p_owner_type_code  => l_SRTasks_Details_rec.owner_type_code,
                  p_owner_id  => l_SRTasks_Details_rec.owner_id,
/* 08/30 -- begin - to fix bug# 1966258 - uncomment the following line*/
                  p_assigned_by_id  => l_user_id,
/* 08/30 -- end - to fix bug# 1966258 */
                  p_planned_start_date => sysdate,
                  p_planned_end_date => sysdate,
/* Begin - 09/24/2001 - change made to accomodate Rahul's problem with update_task API */
/* Uncommented the following 3 lines */
                  p_source_object_type_code => 'SR',
                  p_source_object_id => l_request_id,
                  p_source_object_name => l_request_number,
/* End - 09/24/2001 - change made to accomodate Rahul's problem with update_task API */
                  p_scheduled_start_date => sysdate,
                  p_scheduled_end_date => sysdate,
                  p_private_flag => l_SRTasks_Details_rec.private_flag,
                  p_publish_flag => l_SRTasks_Details_rec.publish_flag,
                  x_return_status  => l_return_status,
                  x_msg_count => l_msg_count,
                  x_msg_data => l_msg_data,
                  x_task_id  => l_task_id
               );

/* 08/30 -- begin - to fix bug# 1964265 */
               IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
                    result := 'N';
               ELSE
/* 08/30 -- end - to fix bug# 1964265 */

/* To fix bug # - 1966258 - Start */
     IF(l_SRTasks_Details_rec.assignee_type_code is not null  AND
       l_SRTasks_Details_rec.assigned_by_id is not null) THEN
        jtf_task_assignments_pub.create_task_assignment(
          p_api_version               => 1.0,
          p_init_msg_list             => cs_core_util.get_g_true,
          p_commit                    => cs_core_util.get_g_true,
          p_task_id                   => l_task_id,
          p_resource_type_code        => l_SRTasks_Details_rec.assignee_type_code,
          p_resource_id               => l_SRTasks_Details_rec.assigned_by_id,
          p_assignment_status_id      => l_SRTasks_Details_rec.task_status_id,
          x_return_status             => l_return_status,
          x_msg_count                 => l_msg_count,
          x_msg_data                  => l_msg_data,
          x_task_assignment_id        => l_task_assignment_id);
    END IF;
/* To fix bug # - 1966258 - End */

/* Begin - 09/24/2001 - change made to accomodate Rahul's problem with update_task API */
/* commenting out the following section */
/*
                update jtf_tasks_b set
                source_object_id = l_request_id,
                source_object_type_code = 'SR' where
                task_id = l_task_id;
*/
/* End - 09/24/2001 - change made to accomodate Rahul's problem with update_task API */

               l_task_type_id := l_SRTasks_rec.task_type_id;
               OPEN c_Workflow_Check_csr;
               FETCH c_Workflow_Check_csr into l_workflow_name;

               IF (l_workflow_name is not null) THEN
                 start_task_workflow (
                          p_api_version => 1.0,
                          p_commit => 'T',
                          p_task_id => l_task_id,
                          p_old_assignee_code => l_SRTasks_Details_rec.assignee_type_code,
                          p_old_assignee_id => l_SRTasks_Details_rec.assigned_by_id,
                          p_tsk_typ_attr_dep_id => l_tsk_typ_attr_dep_id,
                          p_wf_process => l_workflow_name,
                          p_wf_item_type => 'JTFTASK',
                          x_return_status => l_return_status,
                          x_msg_count => l_msg_count,
                          x_msg_data => l_msg_data
                   );

                   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;

                END IF;
               CLOSE c_Workflow_Check_csr;
/* 08/30 -- to begin bug# 1964265 */
              END IF;    -- If l_return_status <> success
             END IF; /* If validate_task_details <> 's' */
/* 08/30 -- to end bug# 1964265 */
             CLOSE c_SRTasks_Details_csr;
          END IF;   -- If l_create_task > 0
        END LOOP;

    END IF;   -- If funmode = 'run'

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'CREATE_ALL_SR_TASKS',
              itemtype, itemkey, actid, funmode);
      RAISE;
    WHEN l_API_ERROR THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'CREATE_ALL_SR_TASKS',
                      itemtype, itemkey, actid, funmode);
      RAISE;
    WHEN OTHERS THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'CREATE_ALL_SR_TASKS',
		      itemtype, itemkey, actid, funmode);
      RAISE;
 END  CREATE_ALL_SR_TASKS;



   PROCEDURE CHECK_ON_TASK_STATUS(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 )
    IS

    l_request_id    NUMBER;
    l_tasks_pending NUMBER;
    l_task_owner_id NUMBER;
    l_task_type_id NUMBER;
    l_request_type_id NUMBER;
    l_loop_counter NUMBER := 0;

    l_resource_name VARCHAR2(360);
    l_resource_type VARCHAR2(30);
    l_resource_id   NUMBER;
    l_role_name     VARCHAR2(60);
    l_task_number VARCHAR2(30);

    l_API_ERROR		  	EXCEPTION;

    CURSOR c_SRTasks_csr IS
        SELECT tsk.task_number, tsk.task_id, tsk.task_type_id, sts.name FROM JTF_TASKS_VL tsk, JTF_TASK_STATUSES_VL sts WHERE
            tsk.task_status_id = sts.task_status_id and
            tsk.SOURCE_OBJECT_ID = l_request_id and
            tsk.source_object_type_code = 'SR';
    l_SRTasks_rec c_SRTasks_csr%ROWTYPE;

-- Begin of changes by ANEEMUCH date 23-May-2002
-- Bug# 2347600
/*
   CURSOR c_GetTaskOwnerId_csr IS
        SELECT cst.owner_id from CUG_SR_TASK_TYPE_DETS_B cst, CUG_TSK_TYP_ATTR_DEPS_B cta WHERE
            cst.tsk_typ_attr_dep_id = cta.tsk_typ_attr_dep_id AND
            cta.task_type_id = l_task_type_id AND
            cta.incident_type_id = l_request_type_id;

   CURSOR c_GetResourceName_csr is
        SELECT source_name from JTF_RS_RESOURCE_EXTNS WHERE
            resource_id = l_task_owner_id;
*/

   CURSOR c_GetTaskOwnerId_csr IS
        SELECT cst.owner_id, cst.owner_type_code
            from CUG_SR_TASK_TYPE_DETS_B cst, CUG_TSK_TYP_ATTR_DEPS_B cta
            WHERE cst.tsk_typ_attr_dep_id = cta.tsk_typ_attr_dep_id AND
            cta.task_type_id = l_task_type_id AND
            cta.incident_type_id = l_request_type_id;

   CURSOR c_GetResourceName_csr is
        SELECT resource_id from JTF_RS_RESOURCE_EXTNS WHERE
            resource_id = l_task_owner_id;

--
-- End of changes by ANEEMUCH date 23-May-2002

    BEGIN

-- For the given incident_id, check on the task status of all it's tasks
-- If the task status has changed to success status continue to check the next task
-- Else, if the task status has changed to failed, set error_type item attribute = 'failed task'
-- set result = 'failed task status' and return

    IF (funmode = 'RUN') THEN

        l_request_id := WF_Engine.GetItemAttrNumber(itemtype => itemtype,
                                                    itemkey => itemkey,
                                                    aname => 'REQUEST_ID');

        SELECT incident_type_id into l_request_type_id from CS_INCIDENTS_ALL_B where incident_id = l_request_id;

        l_tasks_pending := 0;

        OPEN c_SRTasks_csr;
        LOOP

            FETCH c_SRTasks_csr into l_SRTasks_rec;
            EXIT WHEN c_SRTasks_csr%NOTFOUND;

--        FOR l_SRTasks_rec IN c_SRTasks_csr LOOP
            l_task_type_id := l_SRTasks_rec.task_type_id;

            IF  (l_SRTasks_rec.name = FND_PROFILE.Value('CUG_TASK_FAILED_STATUS')) THEN
               WF_Engine.SetItemAttrText(itemtype => itemtype,
                                         itemkey => itemkey,
                                         aname => 'CUG_ERROR_TYPE',
                                         avalue => 'failed task');

               WF_Engine.SetItemAttrText(itemtype => itemtype,
                                         itemkey => itemkey,
                                         aname => 'CUG_TASK_NUMBER',
                                         avalue => l_SRTasks_rec.task_number);

-- Begin of changes by ANEEMUCH date 23-May-2002
-- Bug# 2347600
/*
               OPEN c_GetTaskOwnerId_csr;
               FETCH c_GetTaskOwnerId_csr into l_task_owner_id;
               CLOSE c_GetTaskOwnerId_csr;

               OPEN c_GetResourceName_csr;
               FETCH c_GetResourceName_csr into l_resource_name;
               CLOSE c_GetResourceName_csr;
*/

               OPEN c_GetTaskOwnerId_csr;
               FETCH c_GetTaskOwnerId_csr into l_task_owner_id, l_resource_type;
               CLOSE c_GetTaskOwnerId_csr;

               OPEN c_GetResourceName_csr;
               FETCH c_GetResourceName_csr into l_resource_id;
               CLOSE c_GetResourceName_csr;

               IF (l_resource_type = 'RS_EMPLOYEE') THEN
                   l_role_name := JTF_RS_RESOURCE_PUB.get_wf_role(l_resource_id);
                   IF (l_role_name IS NULL) THEN
                       l_resource_name := FND_PROFILE.VALUE('CUG_DEFAULT_TASK_WF_ROLE');
                   ELSE
                       l_resource_name := l_role_name;
                   END IF;
               ELSE
                   l_role_name := FND_PROFILE.VALUE('CUG_DEFAULT_TASK_WF_ROLE');
               END IF;
--
-- End of changes by ANEEMUCH date 23-May-2002

               WF_Engine.SetItemAttrText(itemtype => itemtype,
                                         itemkey => itemkey,
                                         aname => 'CUG_TASK_OWNER_NAME',
                                         avalue => l_resource_name);

               WF_Engine.SetItemAttrNumber(itemtype => itemtype,
                                         itemkey => itemkey,
                                         aname => 'CUG_TASK_ID',
                                         avalue => l_SRTasks_rec.task_id);


                result := 'CUGCIC_A_TASK_FAILED';
               return;
            ELSIF (l_SRTasks_rec.name = FND_PROFILE.Value('CUG_TASK_SUCCESS_STATUS')) THEN
                l_tasks_pending := 1;
            ELSE
                l_tasks_pending := 0;
                result := 'CUGCIC_WAITING_FOR_COMPLETION';
                return;
            END IF;
            l_loop_counter := l_loop_counter + 1;
        END LOOP;

        CLOSE c_SRTasks_csr;

        IF (l_tasks_pending = 0) THEN
            result := 'CUGCIC_WAITING_FOR_COMPLETION';
        ELSIF (l_tasks_pending = 1) THEN
            result := 'CUGCIC_TASKS_COMPLETED';
        END IF;

        IF (l_loop_counter = 0) THEN
            result := 'CUGCIC_TASKS_COMPLETED';


        END IF;

    END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'CHECK_ON_TASK_STATUS',
                      itemtype, itemkey, actid, funmode);
      RAISE;
    WHEN OTHERS THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'CHECK_ON_TASK_STATUS',
		      itemtype, itemkey, actid, funmode);
      RAISE;

    END CHECK_ON_TASK_STATUS;



 PROCEDURE  CALCULATE_DATE(p_uom IN VARCHAR2,
                           p_offset IN NUMBER,
                           x_date OUT NOCOPY DATE)
   IS
    l_offset NUMBER;
    l_multiple_by NUMBER;
    l_uom VARCHAR2(30);

   BEGIN
        l_offset := p_offset;
        l_uom := p_uom;

    IF ( l_uom = 'Weeks') THEN
        l_multiple_by := 7;
    ELSE
        l_multiple_by := 1;
    END IF;

    l_multiple_by := l_multiple_by * l_offset;

    x_date := sysdate + l_multiple_by;

   END CALCULATE_DATE;



   PROCEDURE CALCULATE_DUPLICATE_TIME_FRAME(p_service_request_id NUMBER,
                                             p_request_type_id NUMBER,
                                             p_duplicate_time_frame OUT NOCOPY DATE)
    IS
    l_request_id    NUMBER;
    l_request_type_id   NUMBER;
    l_multiple_by NUMBER;

    l_duplicate_uom VARCHAR2(30);

    CURSOR c_SRTypeID_csr IS
        SELECT incident_type_id FROM CS_INCIDENTS_ALL_VL
            WHERE INCIDENT_ID = l_request_id;


    CURSOR c_DuplicateTimeInfo_csr IS
        SELECT duplicate_offset, duplicate_uom FROM CUG_SR_TYPE_DUP_CHK_INFO
            WHERE INCIDENT_TYPE_ID = l_request_type_id;
    l_DuplicateTimeInfo_rec c_DuplicateTimeInfo_csr%ROWTYPE;

    CURSOR c_UOM_Conversion_Rate_csr IS
        SELECT conversion_rate FROM MTL_UOM_CONVERSIONS
            WHERE UNIT_OF_MEASURE = l_duplicate_uom;
    l_UOM_Conversion_Rate_rec   c_UOM_Conversion_Rate_csr%ROWTYPE;

     BEGIN



    l_request_id := p_service_request_id;

    OPEN c_SRTypeID_csr;
    FETCH c_SRTypeID_csr INTO l_request_type_id;

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
        l_multiple_by := 1;
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

--    l_multiple_by := l_multiple_by * l_DuplicateTimeInfo_rec.duplicate_offset;

    p_duplicate_time_frame := sysdate - l_multiple_by;

    END CALCULATE_DUPLICATE_TIME_FRAME;



   PROCEDURE start_task_workflow (
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2,
      p_commit              IN       VARCHAR2,
      p_task_id             IN       NUMBER,
      p_old_assignee_code   IN       VARCHAR2,
      p_old_assignee_id     IN       NUMBER,
      p_new_assignee_code   IN       VARCHAR2,
      p_new_assignee_id     IN       NUMBER,
      p_old_owner_code      IN       VARCHAR2,
      p_old_owner_id        IN       NUMBER,
      p_new_owner_code      IN       VARCHAR2,
      p_new_owner_id        IN       NUMBER,
      p_wf_display_name     IN       VARCHAR2,
      p_tsk_typ_attr_dep_id IN       NUMBER,
      p_wf_process          IN       VARCHAR2,
      p_wf_item_type        IN       VARCHAR2,
      x_return_status       OUT      NOCOPY VARCHAR2,
      x_msg_count           OUT      NOCOPY NUMBER,
      x_msg_data            OUT      NOCOPY VARCHAR2
   )
   IS
      l_api_version     CONSTANT NUMBER
               := 1.0;
      l_api_name        CONSTANT VARCHAR2(30)
               := 'START_TASK_WORKFLOW';
      l_wf_process_id            NUMBER;
      l_itemkey                  wf_item_activity_statuses.item_key%TYPE;
      l_old_assigned_user_name   fnd_user.user_name%TYPE;
      l_new_assigned_user_name   fnd_user.user_name%TYPE;
      l_owner_user_name          fnd_user.user_name%TYPE;
      l_task_name                jtf_tasks_tl.task_name%TYPE;
      l_description              jtf_tasks_tl.description%TYPE;
      l_owner_code               jtf_tasks_b.owner_type_code%TYPE;
      l_owner_id                 jtf_tasks_b.owner_id%TYPE;
      l_task_number              jtf_tasks_b.task_number%TYPE;
      l_task_status_name         jtf_tasks_v.task_status%type ;
      l_task_type_name         jtf_tasks_v.task_type%type ;
      l_task_priority_name         jtf_tasks_v.task_priority%type ;
      current_record             NUMBER;
      source_text                VARCHAR2(200);
      l_errname varchar2(60);
      l_errmsg varchar2(2000);
      l_errstack varchar2(4000);
      l_task_dep_id  NUMBER;

      CURSOR c_wf_processs_id
      IS
         SELECT jtf_task_workflow_process_s.nextval
           FROM dual;

      CURSOR c_task_details
      IS
         SELECT task_name, description, owner_type_code owner_code, owner_id, task_number

           FROM jtf_tasks_v
          WHERE task_id = p_task_id;
   BEGIN



      SAVEPOINT start_task_workflow;
      x_return_status := fnd_api.g_ret_sts_success;
      l_task_dep_id := p_tsk_typ_attr_dep_id;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;


      OPEN c_wf_processs_id;
      FETCH c_wf_processs_id INTO l_wf_process_id;
      CLOSE c_wf_processs_id;
      l_itemkey := TO_CHAR (p_task_id) || '-' || TO_CHAR (l_wf_process_id);
      OPEN c_task_details;
      FETCH c_task_details INTO l_task_name,
                                l_description,
                                l_owner_code,
                                l_owner_id,
                                l_task_number;

      IF c_task_details%NOTFOUND
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_ID');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE c_task_details;


      wf_engine.createprocess (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         process => p_wf_process
      );


       wf_engine.setitemuserkey (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         userkey => l_task_name
      );

      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_NAME',
         avalue => l_task_name
      );


       wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_DESC',
         avalue => l_description
      );

      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_NUMBER',
         avalue => l_task_number
      );

      select task_status, task_priority , task_type
      into l_task_status_name, l_task_priority_name  , l_task_type_name
      from jtf_tasks_v where task_id = p_task_id ;


      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_STATUS_NAME',
         avalue => l_task_status_name
      );

      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_PRIORITY_NAME',
         avalue => l_task_priority_name
      );

      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_TYPE_NAME',
         avalue => l_task_type_name
      );

      ----
      ----  Task Owner
      ----

/* Roopa
      l_owner_user_name := jtf_rs_resource_pub.get_wf_role( l_owner_id );

     if l_owner_user_name  is null then
      		raise fnd_api.g_exc_unexpected_error;
      end if ;
End Roopa */


      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'OWNER_ID',
         avalue => l_owner_user_name
      );


/* Roopa
      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'OWNER_NAME',
--        avalue =>  wf_directory.getroledisplayname (l_owner_user_name)
         avalue => jtf_task_utl.get_owner(l_owner_code, l_owner_id)
      );
End Roopa */

      wf_engine.setitemattrtext (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'TASK_DESC',
         avalue => l_description
      );


      wf_engine.setitemattrnumber (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey,
         aname => 'CUG_TASK_DEP_ID',
         avalue => l_task_dep_id
      );

     wf_engine.startprocess (
         itemtype => 'JTFTASK',
         itemkey => l_itemkey
      );

       IF fnd_api.to_boolean (p_commit)
        THEN
--            COMMIT WORK;
            return;
        END IF;


        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO start_task_workflow;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN

            ROLLBACK TO start_task_workflow ;

            wf_core.get_error(l_errname, l_errmsg, l_errstack);
           if (l_errname is not null) then
         	  fnd_message.set_name('FND', 'WF_ERROR');
         	  fnd_message.set_token('ERROR_MESSAGE', l_errmsg);
  	  		fnd_message.set_token('ERROR_STACK', l_errstack);
  	  		fnd_msg_pub.add;
    	end if;

             x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;


   PROCEDURE VALIDATE_TASK_DETAILS(p_task_type_id NUMBER,
                                   p_task_status_id NUMBER,
                                   p_task_priority_id NUMBER,
                                   p_itemkey VARCHAR2,
                                   p_return_status OUT NOCOPY VARCHAR2)
   IS
      CURSOR csr_task_type_id
      IS
         SELECT task_type_id
           FROM jtf_task_types_vl
          WHERE task_type_id = p_task_type_id
            AND (START_DATE_ACTIVE IS NULL OR
             to_number(to_char(START_DATE_ACTIVE, 'YYYYMMDD')) <= to_number(to_char(sysdate, 'YYYYMMDD')) ) AND
             (END_DATE_ACTIVE is NULL OR
              to_number(to_char(END_DATE_ACTIVE, 'YYYYMMDD')) >= to_number(to_char(sysdate, 'YYYYMMDD')) );


      CURSOR csr_task_priority_id
      IS
         SELECT task_priority_id
           FROM jtf_task_priorities_b
          WHERE task_priority_id = p_task_priority_id
            AND (START_DATE_ACTIVE IS NULL OR
             to_number(to_char(START_DATE_ACTIVE, 'YYYYMMDD')) <= to_number(to_char(sysdate, 'YYYYMMDD')) ) AND
             (END_DATE_ACTIVE is NULL OR
              to_number(to_char(END_DATE_ACTIVE, 'YYYYMMDD')) >= to_number(to_char(sysdate, 'YYYYMMDD')) );


      CURSOR csr_task_status_id
      IS
         SELECT task_status_id
           FROM jtf_task_statuses_b
          WHERE task_status_id = p_task_status_id
            AND (START_DATE_ACTIVE IS NULL OR
             to_number(to_char(START_DATE_ACTIVE, 'YYYYMMDD')) <= to_number(to_char(sysdate, 'YYYYMMDD')) ) AND
             (END_DATE_ACTIVE is NULL OR
              to_number(to_char(END_DATE_ACTIVE, 'YYYYMMDD')) >= to_number(to_char(sysdate, 'YYYYMMDD')) );



    l_task_type_id NUMBER;
    l_task_status_id NUMBER;
    l_task_priority_id NUMBER;
    l_task_name VARCHAR2(30);

   BEGIN

   p_return_status := 'S';
   SELECT name into l_task_name
      FROM jtf_task_types_vl
      WHERE task_type_id = p_task_type_id;
   WF_ENGINE.SetItemAttrText(
               	itemtype	=> 'SERVEREQ',
           		itemkey		=> p_itemkey,
           		aname		=> 'CUG_TASK_TYPE',
           		avalue		=> l_task_name);


   OPEN csr_task_type_id;
   FETCH csr_task_type_id into l_task_type_id;
   IF (csr_task_type_id%NOTFOUND) THEN
    p_return_status := 'U';
   END IF;
   CLOSE csr_task_type_id;

   OPEN csr_task_status_id;
   FETCH csr_task_status_id into l_task_status_id;
   IF (csr_task_status_id%NOTFOUND) THEN
    p_return_status := 'U';
   END IF;
   CLOSE csr_task_status_id;

   OPEN csr_task_priority_id;
   FETCH csr_task_priority_id into l_task_priority_id;
   IF (csr_task_priority_id%NOTFOUND) THEN
    p_return_status := 'U';
   END IF;
   CLOSE csr_task_priority_id;

   EXCEPTION
      WHEN OTHERS THEN
            p_return_status := 'U';

   END  VALIDATE_TASK_DETAILS;


-- -----------------------------------------------------------------------
-- Update_CIC_Request_Info
--   Refresh the item attributes with the latest values in the database.
-- -----------------------------------------------------------------------

-- Roopa - This procedure is added to fix bug # 2576759
-- This proc is a copy of CS_WF_ACTIVITIES_PKG.UPDATE_REQUEST_INFO procedure
-- The only difference here is that the validation of the incident owner as well as
-- setting the owner attributes is skipped if the incident owner id is null for the current SR

  PROCEDURE Update_CIC_Request_Info ( itemtype	VARCHAR2,
				  itemkey	VARCHAR2,
				  actid		NUMBER,
				  funmode	VARCHAR2,
				  result	OUT NOCOPY VARCHAR2 ) IS

    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_request_id	NUMBER;
    l_owner_role	VARCHAR2(100);
    l_owner_name  	VARCHAR2(240);
    l_errmsg_name	VARCHAR2(30);
    l_API_ERROR		  	EXCEPTION;

    CURSOR l_ServiceRequest_csr IS
      SELECT inc.customer_product_id, inc.expected_resolution_date,inc.inventory_item_id,inc.summary, emp.source_id incident_owner_id
        FROM cs_incidents_all_vl inc ,cs_sr_owners_v owner, jtf_rs_resource_extns emp
        WHERE inc.INCIDENT_OWNER_ID = owner.resource_id(+) AND
              emp.resource_id = owner.resource_id AND
              incident_id = l_request_id;

    l_ServiceRequest_rec 	l_ServiceRequest_csr%ROWTYPE;

  BEGIN

    IF (funmode = 'RUN') THEN

      -- Get the service request ID
      l_request_id := WF_ENGINE.GetItemAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'REQUEST_ID' );

      -- Extract the service request record
      OPEN l_ServiceRequest_csr;
      FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;


-- fix for bug 2576759. Added the following if condition - Roopa

  IF(l_ServiceRequest_rec.incident_owner_id is not null) THEN
       -- Retrieve the role name for the request owner
      CS_WORKFLOW_PUB.Get_Employee_Role (
		p_api_version		=>  1.0,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_employee_id  		=>  l_ServiceRequest_rec.incident_owner_id,
		p_role_name		=>  l_owner_role,
		p_role_display_name	=>  l_owner_name );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) OR
         (l_owner_role is NULL) THEN
        wf_core.context( pkg_name	=>  'CS_WORKFLOW_PUB',
			 proc_name	=>  'Get_Employee_Role',
			 arg1		=>  'p_employee_id=>'||
					    to_char(l_ServiceRequest_rec.incident_owner_id));
    	l_errmsg_name := 'CS_WF_SR_CANT_FIND_OWNER';
	     raise l_API_ERROR;
      END IF;

      -- Update service request item attributes
      WF_ENGINE.SetItemAttrNumber(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'OWNER_ID',
		avalue		=> l_ServiceRequest_rec.incident_owner_id );

      WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'OWNER_ROLE',
		avalue		=> l_owner_role );

      WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'OWNER_NAME',
		avalue		=> l_owner_name );
  END IF; -- fix for bug 2576759


      WF_ENGINE.SetItemAttrNumber(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'CUSTOMER_PRODUCT_ID',
		avalue		=> l_ServiceRequest_rec.customer_product_id );

      WF_ENGINE.SetItemAttrDate(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'EXPECTED_RESOLUTION_DATE',
		avalue		=> l_ServiceRequest_rec.expected_resolution_date );

      WF_ENGINE.SetItemAttrNumber(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'INVENTORY_ITEM_ID',
		avalue		=> l_ServiceRequest_rec.inventory_item_id );

      WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'REQUEST_SUMMARY',
		avalue		=> l_ServiceRequest_rec.summary );

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

    CLOSE l_ServiceRequest_csr;

  EXCEPTION
    WHEN l_API_ERROR THEN
      IF (l_ServiceRequest_csr%ISOPEN) THEN
        CLOSE l_ServiceRequest_csr;
      END IF;
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'Update_CIC_Request_Info',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Update_CIC_Request_Info;

  -- ---------------------------------------------------------------------------
-- Initialize_Request
--   This procedure initializes the item attributes that will remain constant
--   over the duration of the Workflow.  These attributes include REQUEST_ID,
--   REQUEST_NUMBER, REQUEST_DATE, and REQUEST_TYPE.  In addition, the
--   ESCALATION_HISTORY item attribute is initialized with the assignment
--   information of the current owner.
-- ---------------------------------------------------------------------------

  PROCEDURE CIC_Initialize_Request(	itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 ) IS

    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_request_number	VARCHAR2(64);
    l_dummy		NUMBER;
    l_return_status	VARCHAR2(1);
    l_API_ERROR		EXCEPTION;

    CURSOR l_ServiceRequest_csr IS
      SELECT *
        FROM CS_INCIDENTS_ALL_VL
       WHERE INCIDENT_NUMBER = l_request_number;

    l_ServiceRequest_rec 	l_ServiceRequest_csr%ROWTYPE;
    l_errmsg_name		VARCHAR2(30);

  BEGIN

    IF (funmode = 'RUN') THEN

      -- Decode the item key to get the service request number
      CS_WORKFLOW_PUB.Decode_Servereq_Itemkey(
		p_api_version		=>  1.0,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_itemkey		=>  itemkey,
		p_request_number	=>  l_request_number,
		p_wf_process_id		=>  l_dummy );

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        wf_core.context( pkg_name	=>  'CS_WORKFLOW_PUB',
			 proc_name	=>  'Decode_Servereq_Itemkey',
			 arg1		=>  'p_itemkey=>'||itemkey );
	   l_errmsg_name := 'CS_WF_SR_CANT_DECODE_ITEMKEY';
	    raise l_API_ERROR;
      END IF;

      -- Extract the service request record
      OPEN l_ServiceRequest_csr;
      FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;

      -- Initialize item attributes that will remain constant
      WF_ENGINE.SetItemAttrDate(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'REQUEST_DATE',
		avalue		=> l_ServiceRequest_rec.incident_date );

      WF_ENGINE.SetItemAttrNumber(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'REQUEST_ID',
		avalue		=> l_ServiceRequest_rec.incident_id );

      WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'REQUEST_NUMBER',
		avalue		=> l_ServiceRequest_rec.incident_number );

/*
      WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'REQUEST_TYPE',
		avalue		=> l_ServiceRequest_rec.incident_type );
*/
      CLOSE l_ServiceRequest_csr;

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('CUG_GENERIC_WF_PKG', 'CIC_Initialize_Request',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END CIC_Initialize_Request;

 -- Enter further code below as specified in the Package spec.
END;

/
