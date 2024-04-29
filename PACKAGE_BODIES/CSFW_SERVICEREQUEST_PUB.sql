--------------------------------------------------------
--  DDL for Package Body CSFW_SERVICEREQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSFW_SERVICEREQUEST_PUB" AS
/*  $Header: csfwpsrb.pls 120.3.12010000.3 2009/07/29 11:52:24 syenduri ship $ */
/*===========================================================================+
 |  PROCEDURE NAME                                                           |
 |    update_request_resolution                                              |
 |                                                                           |
 |  DESCRIPTION                                                              |
 |    To update the resolution of a service request (=Incident)              |
 |                                                                           |
 |  NOTES                                                                    |
 |    Error handling is not yet implemented!!!                               |
 |                                                                           |
 |  DEPENDENCIES                                                             |
 |                                                                           |
 |  HISTORY                                                                  |
 |    18-JAN-2001  M. Raap  Created.                                         |
 |                                                                           |
 |    11-JUN-2001  P. Giri edited for an extra )  at line 269                |
 |    30-AUG-2004  pgiri     Added parameters for spares to use this API     |
 |                           API update_request_resolution                   |
 |                                                                           |
 |    23-oct-2004  pgiri   Added new parameter to update_request_resolution  |
 |    29-Jul-2009  syenduri Added new parameter p_incident_severity_id       |
 +===========================================================================*/
PROCEDURE update_request_resolution
  ( p_incident_id     IN  NUMBER
  , p_resolution_code IN  VARCHAR2
  , P_RESOLUTION_SUMMARY IN  VARCHAR2
  , p_problem_code IN varchar2
  , p_cust_po_number   IN varchar2
  , p_commit       IN Boolean
  , p_init_msg_list  IN BOOLEAN
  , X_RETURN_STATUS   OUT NOCOPY VARCHAR2
  , X_MSG_COUNT       OUT NOCOPY INTEGER
  , X_MSG_DATA        OUT NOCOPY VARCHAR2
  , p_object_version_number IN NUMBER default null
  , p_incident_severity_id IN  NUMBER default null -- For enhancement in FSTP 12.1.2 Project
  )
IS

  l_return_status        VARCHAR2(10);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);

  l_counter              NUMBER(3);
  l_data                 VARCHAR2(2000);
  l_msg_index_out        NUMBER;

  lr_service_request_rec cs_servicerequest_pub.service_request_rec_type;
  lt_notes_tab           cs_servicerequest_pub.notes_table;
  lt_contacts_tab        cs_servicerequest_pub.contacts_table;

  l_workflow_process_id  NUMBER;
  l_interaction_id       NUMBER;

  l_user_id	NUMBER;
  l_object_version_number NUMBER;
  l_incident_number varchar2(30);
  l_type_id number;
  L_LAST_UPDATE_PROGRAM_CODE VARCHAR2(30);
  l_msg varchar2(250);
  r_msg varchar2(250);

cursor c_version(v_incident_id number) is
select object_version_number from cs_incidents_all_vl where incident_id = v_incident_id;

cursor c_incident_type_id (v_incident_id number) is
select INCIDENT_TYPE_ID,
       incident_number,
       LAST_UPDATE_PROGRAM_CODE
  from cs_incidents_all_b where incident_id = v_incident_id;

r_incident_type_id           c_incident_type_id%ROWTYPE;

BEGIN
  l_user_id := FND_GLOBAL.user_id ;

    if p_init_msg_list then
        fnd_msg_pub.initialize;
    end if;

IF p_object_version_number IS NULL THEN
  open c_version(p_incident_id);
  fetch c_version into l_object_version_number;
  close c_version ;
ELSE
 l_object_version_number := p_object_version_number ;
END IF;

  cs_servicerequest_pub.initialize_rec
    ( p_sr_record => lr_service_request_rec
    );


  open c_incident_type_id(p_incident_id);
  fetch c_incident_type_id into r_incident_type_id ;
  close c_incident_type_id ;

  l_type_id := r_incident_type_id.INCIDENT_TYPE_ID;
--  l_incident_number := r_incident_type_id.incident_number;
  L_LAST_UPDATE_PROGRAM_CODE:= r_incident_type_id.LAST_UPDATE_PROGRAM_CODE;

--dbms_output.put_line(' in csfw pub statring with incident '||p_incident_id);

  lr_service_request_rec.resolution_code := p_resolution_code;

  if P_RESOLUTION_SUMMARY IS NOT NULL THEN
	lr_service_request_rec.resolution_summary := P_RESOLUTION_SUMMARY;
  END IF;

  IF  p_problem_code IS NOT NULL THEN
    lr_service_request_rec.problem_code := p_problem_code;
  END IF;

  IF  p_cust_po_number IS NOT NULL THEN
    lr_service_request_rec.cust_po_number := p_cust_po_number;
  END IF;

  -- For enhancement in FSTP 12.1.3 Project
   IF p_incident_severity_id IS NOT NULL THEN
      lr_service_request_rec.severity_id := p_incident_severity_id;
   END IF;

  lr_service_request_rec.type_id          := l_type_id;
  lr_service_request_rec.last_update_program_code :=L_LAST_UPDATE_PROGRAM_CODE;

  cs_servicerequest_pub.update_servicerequest
    (
  p_api_version            => 3.0 ,
  p_init_msg_list          => FND_API.G_FALSE,
  p_commit                 => FND_API.G_TRUE,
  x_return_status          => l_return_status,
  x_msg_count              => l_msg_count,
  x_msg_data               => l_msg_data,
  p_request_id             => p_incident_id,
  p_request_number         => null,--l_incident_number,
  p_audit_comments         => NULL,
  p_object_version_number  => l_object_version_number,
  p_resp_appl_id           => NULL,
  p_resp_id                => NULL,
  p_last_updated_by        => l_user_id ,
  p_last_update_login      => NULL,
  p_last_update_date       => sysdate ,
  p_service_request_rec    => lr_service_request_rec,
  p_notes                  => lt_notes_tab,
  p_contacts               => lt_contacts_tab,
  p_called_by_workflow     => FND_API.G_FALSE,
  p_workflow_process_id    => NULL,
  x_workflow_process_id    => l_workflow_process_id,
  x_interaction_id         => l_interaction_id
    );


--dbms_output.put_line(' in csfw pub , cs_pub returned status =  '||l_return_status);

    X_RETURN_STATUS         := l_return_status;       -- output-parameter
    X_MSG_COUNT             := l_msg_count;           -- output-parameter

    --dbms_output.put_line('return_status: '||l_return_status);
  IF l_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
     if p_commit then
      commit;
     end if;
  ELSE
      FOR l_counter IN 1 .. l_msg_count
      LOOP
        fnd_msg_pub.get
          ( p_msg_index     => l_counter
          , p_encoded       => FND_API.G_FALSE
          , p_data          => l_data
          , p_msg_index_out => l_msg_index_out
          );
        --dbms_output.put_line( 'Message: '||l_data );
      END LOOP ;
      X_MSG_DATA := l_data;
  END IF;

EXCEPTION
  WHEN OTHERS
  THEN
    --dbms_output.put_line('Exception');
    --dbms_output.put_line(SQLERRM);
    X_MSG_DATA := SQLERRM;
END update_request_resolution;

/*===========================================================================+
 |  PROCEDURE NAME                                                           |
 |    get_reaction_time                                                      |
 |                                                                           |
 |  DESCRIPTION                                                              |
 |    To retrieve the reaction time, specified in a contract, of a service   |
 |    request (=Incident)                                                    |
 |                                                                           |
 |  NOTES                                                                    |
 |    Error handling is not yet implemented!!!                               |
 |                                                                           |
 |  DEPENDENCIES                                                             |
 |                                                                           |
 |  HISTORY                                                                  |
 |    23-JAN-2001  M. Raap  Created.
 |    01-MAY-2001  mmerchan  Contract Number added for reaction time
 |    14-NOV-2001  mmerchan  contract service id returned
 |                                                                           |
 +===========================================================================*/
PROCEDURE get_reaction_time
  ( p_incident_id   IN  NUMBER
  , p_task_id       IN  NUMBER
  , p_resource_id   IN  NUMBER
  , p_error_type    OUT NOCOPY NUMBER
  , p_error         OUT NOCOPY VARCHAR2
  , x_react_within  OUT NOCOPY NUMBER
  , x_react_tuom    OUT NOCOPY VARCHAR2
  , x_react_by_date OUT NOCOPY VARCHAR2
  , x_contract_service_id OUT NOCOPY NUMBER
  , x_contract_number OUT NOCOPY VARCHAR2
  , x_txn_group_id OUT NOCOPY NUMBER
  )
IS


  CURSOR c_incident
    ( b_incident_id cs_incidents_all_b.incident_id%TYPE
    )
  IS
    SELECT ci_all_b.incident_date   incident_date    -- bug # 4337147
    ,      ci_all_b.incident_severity_id incident_severity_id
    ,      ci_all_b.contract_service_id  contract_service_id
    ,      cit.business_process_id       business_process_id
    ,	   ci_all_b.contract_number	 contract_number
    FROM   cs_incidents_all_b ci_all_b
    ,      cs_incident_types  cit
    WHERE  ci_all_b.incident_type_id = cit.incident_type_id
    AND    ci_all_b.incident_id      = b_incident_id;

  -- cursor is modified
  -- bug # 4337147
  CURSOR C_TXN_GROUP_ID(v_business_process_id NUMBER,
	v_contract_service_id NUMBER)
  IS
   SELECT BPL.Id
   FROM OKS_K_Lines_B KSL,
        OKC_K_LINES_B BPL
  WHERE KSL.Cle_ID = v_contract_service_id
    AND BPL.Cle_ID = KSL.COVERAGE_ID
    AND BPL.Lse_Id IN (3,16,21)
    AND EXISTS (SELECT 'x'
                   FROM OKC_K_Items BIT
                  WHERE BIT.Cle_id = BPL.Id
                    AND Object1_Id1 = v_business_process_id
                    AND Jtot_Object1_Code = 'OKX_BUSIPROC');
   /*
  Select a.id
  from okc_k_lines_b a
  where a.lse_id in (3,16,21)
  and exists (select 'x'
   	      from okc_k_items
              where cle_id = a.id and
              object1_id1 = v_business_process_id and
              jtot_object1_code = 'OKX_BUSIPROC')
  connect by a.cle_id = prior(a.id)
  start with a.id = v_contract_service_id;
  */

  r_incident           c_incident%ROWTYPE;

  --l_server_timezone_id VARCHAR2(200);
  l_server_timezone_id NUMBER;
  l_server_timezone_name VARCHAR2(200);

  l_counter            NUMBER(3);
  l_data               VARCHAR2(2000);
  l_msg_index_out      NUMBER;
  l_return_status      VARCHAR2(10);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_react_by_date DATE;
  l_date_format        varchar(30);
  p_inp_rec     oks_entitlements_pub.grt_inp_rec_type;
  x_resolve_rec oks_entitlements_pub.rcn_rsn_rec_type;
  x_react_rec   oks_entitlements_pub.rcn_rsn_rec_type;
  l_client_tz_id number;
  l_server_tz_id number;
  l_client_date date;


BEGIN

  p_error_type := 0; -- Assume success


  OPEN c_incident
    ( b_incident_id => p_incident_id
    );
  FETCH c_incident
  INTO r_incident;
  CLOSE c_incident;

  --dbms_output.put_line('INCIDENT_DATE: '||r_incident.incident_date);
  --dbms_output.put_line('INCIDENT_SEVERITY_ID: '||r_incident.incident_severity_id);
  --dbms_output.put_line('CONTRACT_SERVICE_ID: '||r_incident.contract_service_id);
  --dbms_output.put_line('CONTRACT_NUMBER: '||r_incident.contract_number);
  --dbms_output.put_line('BUSINESS_PROCESS_ID: '||r_incident.business_process_id);

  /*
  FND_PROFILE.Get
    ( name => 'SERVER_TIMEZONE_ID'
    , val  => l_server_timezone_id
    );
  */
  -- bug # 4337147
  -- Get timezone using SR API
  CS_TZ_GET_DETAILS_PVT.CUSTOMER_PREFERRED_TIME_ZONE
  ( p_incident_id             => p_incident_id
  , p_task_id                 => p_task_id
  , p_resource_id             => p_resource_id
  , p_cont_pref_time_zone_id  => NULL
  , p_incident_location_id    => NULL
  , p_incident_location_type  => NULL
  , p_contact_party_id        => NULL
  , p_contact_phone_id        => NULL
  , p_contact_address_id      => NULL
  , p_customer_id             => NULL
  , p_customer_phone_id       => NULL
  , p_customer_address_id     => NULL
  , x_timezone_id             => l_server_timezone_id
  , x_timezone_name           => l_server_timezone_name
  );

  --dbms_output.put_line('SERVER_TIMEZONE_ID: '||l_server_timezone_id);

  IF r_incident.contract_service_id IS NULL
  THEN
    /* There is no contract attached to incident */
    --dbms_output.put_line('No contract for this service request');
    p_error_type := 2; -- No Contract
    --- not translated message. JSP should translate
    p_error := 'No contract for this service request';
  ELSE

    x_contract_service_id := r_incident.contract_service_id;
    x_contract_number := r_incident.contract_number;

    p_inp_rec.contract_line_id     := r_incident.contract_service_id;
    p_inp_rec.business_process_id  := r_incident.business_process_id;
    p_inp_rec.severity_id          := r_incident.incident_severity_id;
    p_inp_rec.request_date         := r_incident.incident_date;
    p_inp_rec.time_zone_id         := l_server_timezone_id;
    p_inp_rec.category_rcn_rsn     := oks_entitlements_pub.G_RESOLUTION;
    p_inp_rec.compute_option       := oks_entitlements_pub.G_FIRST;

    /* There is a contract attached to the incident. Retrieve reaction time. */
     oks_entitlements_pub.get_react_resolve_by_time
    (p_api_version		=> 1.0
    ,p_init_msg_list		=> FND_API.G_TRUE
    ,p_inp_rec                  => p_inp_rec
    ,x_return_status 		=> l_return_status
    ,x_msg_count		=> l_msg_count
    ,x_msg_data			=> l_msg_data
    ,x_react_rec                => x_react_rec
    ,x_resolve_rec              => x_resolve_rec);


     /* Find the contract line id / txn group id associated with the business
	process for the contract related to the service request */
     x_txn_group_id := -1;
     OPEN C_TXN_GROUP_ID(r_incident.business_process_id,
	r_incident.contract_service_id);
     FETCH C_TXN_GROUP_ID
     INTO x_txn_group_id;
     CLOSE C_TXN_GROUP_ID;

/*
    oks_entitlements_pub.check_reaction_times
      ( p_api_version         => 1.0
      , p_init_msg_list       => FND_API.G_TRUE
      , p_business_process_id => r_incident.business_process_id
      , p_request_date        => r_incident.incident_date
      , p_sr_severity         => r_incident.incident_severity_id
      , p_time_zone_id        => l_server_timezone_id
      , p_contract_line_id    => r_incident.contract_service_id
      , x_return_status       => l_return_status
      , x_msg_count           => l_msg_count
      , x_msg_data            => l_msg_data
      , x_react_within        => x_react_within
      , x_react_tuom          => x_react_tuom
      , x_react_by_date       => l_react_by_date
      );
  */

    IF l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
        /* API-call was successfull */
        --dbms_output.put_line('duration: '||x_resolve_rec.duration);
        --dbms_output.put_line('uom: '||x_resolve_rec.uom);
        --dbms_output.put_line('by_date_end: '||to_char(x_resolve_rec.by_date_end, 'MM/DD/YYYY HH24:MI:SS'));

        -- Lets get the Resolution record's values;
        -- l_react_by_date is actually the resolve by date.
        -- We used to use it for React time which is now obsolete
        x_react_within        := x_resolve_rec.duration;
        x_react_tuom          := x_resolve_rec.uom;
        l_react_by_date := x_resolve_rec.by_date_end;

        -- bug 3035563 l_react_by_date to Convert to timezone of the client(found in 11.5.8)
        l_react_by_date := CSFW_TIMEZONE_PUB.GET_CLIENT_TIME(l_react_by_date);

        -- Now get the profile option to get the data
        FND_PROFILE.GET('ICX_DATE_FORMAT_MASK', l_date_format);

        -- Bug 2862796. Modfication for using ICX: Date Format Mask in place of CSFW: Date Format
        IF l_date_format IS NULL
        THEN
            l_date_format := 'DD/MM/YYYY';
        END IF;

        l_date_format := l_date_format || ' HH24:MI:SS';
        x_react_by_date := to_char(l_react_by_date, l_date_format);

        /*
        IF l_date_format = 'DD-MM-YYYY'
        THEN
            x_react_by_date := to_char(l_react_by_date, 'DD-MM-YYYY HH24:MI:SS');
        ELSIF l_date_format = 'DD/MM/YYYY'
        THEN
            x_react_by_date := to_char(l_react_by_date, 'DD/MM/YYYY HH24:MI:SS');
        ELSIF l_date_format = 'MM-DD-YYYY'
        THEN
            x_react_by_date := to_char(l_react_by_date, 'MM-DD-YYYY HH24:MI:SS');
        ELSIF l_date_format = 'MM/DD/YYYY'
        THEN
            x_react_by_date := to_char(l_react_by_date, 'MM/DD/YYYY HH24:MI:SS');
        ELSIF l_date_format = 'YYYY-MM-DD'
        THEN
            x_react_by_date := to_char(l_react_by_date, 'YYYY-MM-DD HH24:MI:SS');
        ELSIF l_date_format = 'YYYY/MM/DD'
        THEN
            x_react_by_date := to_char(l_react_by_date, 'YYYY/MM/DD HH24:MI:SS');

        ELSIF l_date_format = 'DD-MM-YY'
        THEN
            x_react_by_date := to_char(l_react_by_date, 'DD-MM-YY HH24:MI:SS');
        ELSIF l_date_format = 'DD/MM/YY'
        THEN
            x_react_by_date := to_char(l_react_by_date, 'DD/MM/YY HH24:MI:SS');
        ELSIF l_date_format = 'MM-DD-YY'
        THEN
            x_react_by_date := to_char(l_react_by_date, 'MM-DD-YY HH24:MI:SS');
        ELSIF l_date_format = 'MM/DD/YY'
        THEN
            x_react_by_date := to_char(l_react_by_date, 'MM/DD/YY HH24:MI:SS');
        ELSIF l_date_format = 'YY-MM-DD'
        THEN
            x_react_by_date := to_char(l_react_by_date, 'YY-MM-DD HH24:MI:SS');
        ELSIF l_date_format = 'YY/MM/DD'
        THEN
            x_react_by_date := to_char(l_react_by_date, 'YY/MM/DD HH24:MI:SS');
        ELSE
            x_react_by_date := to_char(l_react_by_date, 'DD/MM/YYYY HH24:MI:SS');
        END IF;
        */
    ELSE
      /* API-call was unsuccessfull */
         --dbms_output.put_line('Error retrieving reaction time through API');
         --dbms_output.put_line('return_status: '||l_return_status);
         --dbms_output.put_line('msg_count: '||l_msg_count);
         --dbms_output.put_line('msg_data: '||l_msg_data);
      /* To display the error-messages */
    BEGIN
      FOR l_counter IN 1 .. l_msg_count
      LOOP
        fnd_msg_pub.get
          ( p_msg_index     => l_counter
          , p_encoded       => FND_API.G_FALSE
          , p_data          => l_data
          , p_msg_index_out => l_msg_index_out
          );
        --dbms_output.put_line( 'Message: '||l_data );
      END LOOP ;
        p_error_type := 1; -- Failure
        p_error := l_data;
     EXCEPTION
	WHEN OTHERS THEN
		p_error_type := 1; -- Failure
        	p_error := 'Cant get FND msg';
     END;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS
  THEN
       --dbms_output.put_line('Exception');
       --dbms_output.put_line(SQLERRM);
        p_error_type := -1;-- Failure
        p_error := SQLERRM;
END get_reaction_time;

/* Get Billing Types
PROCEDURE get_billing_types

    SELECT billing_type, name, to_char(txn_group_id)
    from OKS_ENT_BILL_TYPES_V
    where txn_group_id = b_contract_service_id;

    SELECT covered_amount, covered_percent
    from OKS_ENT_BILL_TYPES_V
    where txn_group_id = b_contract_service_id
    and billing_type = b_billing_type;



END get_billing_types;
*/



/*===========================================================================+
 |  PROCEDURE NAME                                                           |
 |    update_request_flex						     |
 |                                                                           |
 |  DESCRIPTION                                                              |
 |    Wrapper on update_servicerequest for updating task fled field	     |
 |                                                                           |
 |  DEPENDENCIES                                                             |
 |                                                                           |
 |  HISTORY                                                                  |
 |  20-Apr-2005 hgotur	Created                                              |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_request_flex
  ( p_incident_id	IN  NUMBER
  , p_attribute_1	IN VARCHAR2
  , p_attribute_2	IN VARCHAR2
  , p_attribute_3	IN VARCHAR2
  , p_attribute_4	IN VARCHAR2
  , p_attribute_5	IN VARCHAR2
  , p_attribute_6	IN VARCHAR2
  , p_attribute_7	IN VARCHAR2
  , p_attribute_8	IN VARCHAR2
  , p_attribute_9	IN VARCHAR2
  , p_attribute_10	IN VARCHAR2
  , p_attribute_11	IN VARCHAR2
  , p_attribute_12	IN VARCHAR2
  , p_attribute_13	IN VARCHAR2
  , p_attribute_14	IN VARCHAR2
  , p_attribute_15	IN VARCHAR2
  , p_context		IN VARCHAR2
  , X_RETURN_STATUS   OUT NOCOPY VARCHAR2
  , X_MSG_COUNT		OUT NOCOPY INTEGER
  , X_MSG_DATA		OUT NOCOPY VARCHAR2
  )
IS

  l_return_status        VARCHAR2(10);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);

  l_counter              NUMBER(3);
  l_data                 VARCHAR2(2000);
  l_msg_index_out        NUMBER;

  lr_service_request_rec cs_servicerequest_pub.service_request_rec_type;
  lt_notes_tab           cs_servicerequest_pub.notes_table;
  lt_contacts_tab        cs_servicerequest_pub.contacts_table;

  l_workflow_process_id  NUMBER;
  l_interaction_id       NUMBER;

  l_user_id	NUMBER;
  l_object_version_number NUMBER;
  l_incident_number varchar2(30);
  l_type_id number;
  L_LAST_UPDATE_PROGRAM_CODE VARCHAR2(30);

cursor c_version(v_incident_id number) is
select object_version_number from cs_incidents_all_vl where incident_id = v_incident_id;

cursor c_incident_type_id (v_incident_id number) is
select INCIDENT_TYPE_ID,
       incident_number,
       LAST_UPDATE_PROGRAM_CODE
  from cs_incidents_all_b where incident_id = v_incident_id;

r_incident_type_id           c_incident_type_id%ROWTYPE;

BEGIN
  l_user_id := FND_GLOBAL.user_id ;

  open c_version(p_incident_id);
  fetch c_version into l_object_version_number;
  close c_version ;

  cs_servicerequest_pub.initialize_rec
    ( p_sr_record => lr_service_request_rec
    );


  open c_incident_type_id(p_incident_id);
  fetch c_incident_type_id into r_incident_type_id ;
  close c_incident_type_id ;

  l_type_id := r_incident_type_id.INCIDENT_TYPE_ID;
  L_LAST_UPDATE_PROGRAM_CODE:= r_incident_type_id.LAST_UPDATE_PROGRAM_CODE;


  -- setting the values of Sr record which are to be updated
  lr_service_request_rec.request_attribute_1	:= p_attribute_1 ;
  lr_service_request_rec.request_attribute_2	:= p_attribute_2 ;
  lr_service_request_rec.request_attribute_3	:= p_attribute_3 ;
  lr_service_request_rec.request_attribute_4	:= p_attribute_4 ;
  lr_service_request_rec.request_attribute_5	:= p_attribute_5 ;
  lr_service_request_rec.request_attribute_6	:= p_attribute_6 ;
  lr_service_request_rec.request_attribute_7	:= p_attribute_7 ;
  lr_service_request_rec.request_attribute_8	:= p_attribute_8 ;
  lr_service_request_rec.request_attribute_9	:= p_attribute_9 ;
  lr_service_request_rec.request_attribute_10	:= p_attribute_10 ;
  lr_service_request_rec.request_attribute_11	:= p_attribute_11 ;
  lr_service_request_rec.request_attribute_12	:= p_attribute_12 ;
  lr_service_request_rec.request_attribute_13	:= p_attribute_13 ;
  lr_service_request_rec.request_attribute_14	:= p_attribute_14 ;
  lr_service_request_rec.request_attribute_15	:= p_attribute_15 ;
  lr_service_request_rec.request_context	:= p_context ;

  lr_service_request_rec.type_id          := l_type_id;
  lr_service_request_rec.last_update_program_code :=L_LAST_UPDATE_PROGRAM_CODE;
  cs_servicerequest_pub.update_servicerequest
    (
  p_api_version            => 3.0 ,
  p_init_msg_list          => FND_API.G_FALSE,
  p_commit                 => FND_API.G_TRUE,
  x_return_status          => l_return_status,
  x_msg_count              => l_msg_count,
  x_msg_data               => l_msg_data,
  p_request_id             => p_incident_id,
  p_request_number         => null,--l_incident_number,
  p_audit_comments         => NULL,
  p_object_version_number  => l_object_version_number,
  p_resp_appl_id           => NULL,
  p_resp_id                => NULL,
  p_last_updated_by        => l_user_id ,
  p_last_update_login      => NULL,
  p_last_update_date       => sysdate ,
  p_service_request_rec    => lr_service_request_rec,
  p_notes                  => lt_notes_tab,
  p_contacts               => lt_contacts_tab,
  p_called_by_workflow     => FND_API.G_FALSE,
  p_workflow_process_id    => NULL,
  x_workflow_process_id    => l_workflow_process_id,
  x_interaction_id         => l_interaction_id
    );

    X_RETURN_STATUS         := l_return_status;       -- output-parameter
    X_MSG_COUNT             := l_msg_count;           -- output-parameter

    --dbms_output.put_line('return_status: '||l_return_status);
  IF l_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    /* API-call was successfull */
      null;
      commit;
  ELSE
      FOR l_counter IN 1 .. l_msg_count
      LOOP
        fnd_msg_pub.get
          ( p_msg_index     => l_counter
          , p_encoded       => FND_API.G_FALSE
          , p_data          => l_data
          , p_msg_index_out => l_msg_index_out
          );
        --dbms_output.put_line( 'Message: '||l_data );
      END LOOP ;
      X_MSG_DATA := l_data;
  END IF;

EXCEPTION
  WHEN OTHERS
  THEN
    --dbms_output.put_line('Exception');
    --dbms_output.put_line(SQLERRM);
    X_MSG_DATA := SQLERRM;
END update_request_flex;



END csfw_servicerequest_pub;


/
