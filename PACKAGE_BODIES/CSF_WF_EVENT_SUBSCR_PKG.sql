--------------------------------------------------------
--  DDL for Package Body CSF_WF_EVENT_SUBSCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_WF_EVENT_SUBSCR_PKG" as
/* $Header: csfwfevb.pls 120.2 2005/08/30 14:06:58 rhungund noship $ */
-- Start of Comments
-- Package name     : CSF_WF_EVENT_SUBSCR_PKG
-- Purpose          : Preventive Maintenace WF Business Event Subscription API.
-- History          : Initial version for release 11.5.9
-- NOTE             :
-- End of Comments

G_PKG_NAME     CONSTANT VARCHAR2(30):= 'CSF_WF_EVENT_SUBSCR_PKG';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'csfwfevb.pls';
g_retcode               number := 0;


  FUNCTION CSF_VERIFY_PM_SR(p_subscription_guid in raw,
                            p_event in out nocopy WF_EVENT_T) RETURN varchar2 is

-- Generic Event Parameters and Cursors
    l_event_name 	VARCHAR2(240) := p_event.getEventName( );

    l_resp_appl_id NUMBER := NULL;
    l_login_id NUMBER := NULL;
    l_user_id		NUMBER := NULL;

    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

    l_request_number    	VARCHAR2(64);


BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (l_event_name = 'oracle.apps.cs.sr.ServiceRequest.statuschanged') THEN

/* The event payload only passes REQUEST_NUMBER. Hence getting that parameter ... */
      l_request_number := p_event.getvalueforparameter('REQUEST_NUMBER');

	  IF (VALIDATE_SR_FOR_DEBRIEF(l_request_number) <> 'S') THEN
	  	raise FND_API.G_EXC_ERROR;
	  END IF;

    END IF;

    return 'SUCCESS';

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MESSAGE.SET_NAME('CSF','CSF_PRIOR_PM_SRS_EXIST');
      APP_EXCEPTION.RAISE_EXCEPTION;
      return 'ERROR';

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MESSAGE.SET_NAME('CSF','CSF_PRIOR_PM_SRS_EXIST');
      APP_EXCEPTION.RAISE_EXCEPTION;
      return 'ERROR';

    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('CSF','CSF_PRIOR_PM_SRS_EXIST');
      APP_EXCEPTION.RAISE_EXCEPTION;
      return 'ERROR';

END CSF_VERIFY_PM_SR;



  FUNCTION VALIDATE_SR_FOR_DEBRIEF(
               p_service_request_number IN         VARCHAR2
	      ) RETURN VARCHAR2 IS

-- UMP and SR Event Parameters and Cursors
    l_forecast_sequence	NUMBER;
    l_mr_header_id NUMBER;

    l_customer_product_id NUMBER;
    l_request_number    	VARCHAR2(64);
    l_request_id		NUMBER;


   CURSOR c_get_ue_details_csr IS
    SELECT csi.incident_id, csi.customer_product_id,
           aueb.forecast_sequence, aueb.mr_header_id
    FROM
        cs_incidents_all_b csi,
        ahl_unit_effectivities_vl aueb,
        cs_incident_links cil
    WHERE
        cil.object_id = aueb.unit_effectivity_id
        and   cil.object_type = 'AHL_UMP_EFF'
        and   cil.link_type_id = 6
        and   csi.incident_id = cil.subject_id
        and   csi.incident_number = l_request_number;


   CURSOR c_check_for_pm_sr_csr IS
    SELECT csi.incident_id,aueb.unit_effectivity_id  from
    cs_incidents_all_b csi,
    ahl_unit_effectivities_vl aueb,
    cs_incident_links cil
    WHERE
    (aueb.status_code is NULL
	 or aueb.status_code = 'INIT-DUE')
    and   cil.object_id = aueb.unit_effectivity_id
    and   cil.object_type = 'AHL_UMP_EFF'
    and   cil.link_type_id = 6
    and   csi.incident_id = cil.subject_id
    and   nvl(csi.status_flag, 'O') <> 'C' and
    nvl(aueb.forecast_sequence, -1) < l_forecast_sequence and
    aueb.csi_item_instance_id = l_customer_product_id and
    nvl(aueb.mr_header_id, 0) = l_mr_header_id and
    csi.incident_id <> l_request_id;

   c_check_for_pm_sr_rec c_check_for_pm_sr_csr%ROWTYPE;


  BEGIN

		l_request_number := p_service_request_number;
        OPEN c_get_ue_details_csr;
        FETCH c_get_ue_details_csr INTO l_request_id, l_customer_product_id, l_forecast_sequence, l_mr_header_id;


/* For PM Srs the following 2 fields will not be null. Just to be on the safer side ... */
        IF (l_forecast_sequence is null) THEN
            l_forecast_sequence := 0;
        END IF;

        IF(l_mr_header_id is null) THEN
           l_mr_header_id := 0;
        END IF;


        IF(c_get_ue_details_csr%FOUND)THEN
            OPEN c_check_for_pm_sr_csr;
            FETCH c_check_for_pm_sr_csr INTO c_check_for_pm_sr_rec;

            IF (c_check_for_pm_sr_csr%FOUND) THEN
                return 'U';
            END IF;

            CLOSE c_check_for_pm_sr_csr;
        END IF;

        CLOSE c_get_ue_details_csr;
    	return 'S';

  END VALIDATE_SR_FOR_DEBRIEF;


   -- Enter further code below as specified in the Package spec.
END CSF_WF_EVENT_SUBSCR_PKG;


/
