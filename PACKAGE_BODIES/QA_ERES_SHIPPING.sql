--------------------------------------------------------
--  DDL for Package Body QA_ERES_SHIPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_ERES_SHIPPING" AS
/* $Header: qaerwshb.pls 115.2 2004/07/23 01:35:35 isivakum noship $ */



  PROCEDURE wrapper (ERRBUF    OUT NOCOPY VARCHAR2,
                     RETCODE   OUT NOCOPY NUMBER,
                     ARGUMENT1 IN         VARCHAR2,
                     ARGUMENT2 IN         VARCHAR2) IS

   from_pickup_dt DATE;
   to_pickup_dt DATE;
   out_status VARCHAR2(50) := FND_API.G_RET_STS_SUCCESS;
   edr_profile VARCHAR2(20) := 'N';
  BEGIN

    -- ARGUMENT1 --> From Date
    -- ARGUMENT2 --> To Date
	fnd_file.put_line(fnd_file.log, 'qa_eres_shipping.wrapper entered');

    edr_profile := FND_PROFILE.VALUE('EDR_ERES_ENABLED');
    fnd_file.put_line (fnd_file.log, 'ERES Profile is set to:'||edr_profile);

    IF (edr_profile is not null AND edr_profile = 'Y' and
		ARGUMENT1 IS NOT NULL AND ARGUMENT2 IS NOT NULL) THEN

	from_pickup_dt := fnd_date.canonical_to_date(argument1);
	to_pickup_dt   := fnd_date.canonical_to_date(argument2);

        fnd_file.put_line (fnd_file.log, 'dates fetched');

       --BUG 3352407 - Date validation needed
       IF (from_pickup_dt >= to_pickup_dt) THEN
         fnd_file.put_line (fnd_file.log, 'ERROR: From date must be less than To date');
	 RETCODE := 2; -- return code for error
         ERRBUF  := 'ERROR: From date must be less than To date';
	 RETURN;
       END IF;

       IF ( to_pickup_dt - from_pickup_dt > 5) THEN
         fnd_file.put_line (fnd_file.log, 'ERROR: Date Range should be within 5 days');
	 RETCODE := 2; -- return code for error
         ERRBUF  := 'ERROR: Date Range should be within 5 days';
	 RETURN;
       END IF;


        --default value for out_status is SUCCESS
       delivery_erecord(from_pickup_dt, to_pickup_dt, out_status);
    END IF;

      if (out_status = FND_API.G_RET_STS_ERROR
                or out_status = FND_API.G_RET_STS_UNEXP_ERROR)
      then
            RETCODE := 1;
            ERRBUF  := 'Warning: Some eRecords may have resulted in error';
      else
            RETCODE := 0;
            ERRBUF  := '';
      end if;
      fnd_file.put_line(fnd_file.log, 'qa_eres_shipping.wrapper exiting');
  END wrapper;

-----------------------------------------------------------------------------

  PROCEDURE delivery_erecord(p_from_date  IN  DATE,
                             p_to_date    IN  DATE,
                             x_status OUT NOCOPY VARCHAR2) IS


  --BUG 3763874 : shipment direction needs to be taken into account
  -- we only support outbound sales order shipments direction 'O'

    CURSOR wsh_delivery_cur(c_from_date DATE, c_to_date DATE,
			    c_evt_name VARCHAR2) IS
	SELECT wnd.delivery_id, wnd.name
	FROM wsh_new_deliveries wnd
	WHERE wnd.initial_pickup_date >= c_from_date
	AND wnd.initial_pickup_date <= c_to_date
	AND (wnd.status_code = 'IT' OR wnd.status_code = 'CL')
        AND nvl(wnd.shipment_direction, 'O') in ('O') --BUG 3763874
	AND NOT EXISTS
		(SELECT 1
		 FROM EDR_PSIG_DOCUMENTS epd
		 WHERE epd.event_name = c_evt_name
		 AND epd.event_key = wnd.delivery_id
		 AND epd.psig_status = 'COMPLETE');
	--following indexes exist on wsh_new_deliveries table
	--WSH_NEW_DELIVERIES_N1 - on wnd.status_code column
	--WSH_NEW_DELIVERIES_N7 - on initial_pickup_date column
	--following indexes exist on EDR table
	--EDR_PSIG_DOCUMENTS_N1 - on event_name and event_key

  out_erecord_id NUMBER;
  out_status VARCHAR2(50) := FND_API.G_RET_STS_SUCCESS;

  BEGIN

    FOR wsh_rec IN wsh_delivery_cur (p_from_date, p_to_date, g_event_name_const)
    LOOP
      --get the delivery id and call the edr raise event
      raise_delivery_event(wsh_rec.delivery_id, wsh_rec.name,
			   out_erecord_id, out_status);

      --even if one of the events gives an error, mark it so
      --Warning can be raised for Concurrent program completion
      --if everything fine, default value will be success
      if (out_status = FND_API.G_RET_STS_ERROR
                or out_status = FND_API.G_RET_STS_UNEXP_ERROR)
      then
            x_status := out_status;
      end if;
    END LOOP;

	NULL;

  END delivery_erecord;
-------------------------------------------------------------------

  PROCEDURE raise_delivery_event(p_delivery_id  IN  NUMBER,
                                 p_delivery_name   IN  VARCHAR2,
				 p_erecord_id OUT NOCOPY NUMBER,
				 x_status OUT NOCOPY VARCHAR2)
  IS

    l_child_erecords qa_edr_standard.ERECORD_ID_TBL_TYPE;
    l_event qa_edr_standard.ERES_EVENT_REC_TYPE;


    o_return_status VARCHAR2(50);
    o_msg_count NUMBER;
    o_msg_data VARCHAR2(2000);
    o_erecord_id NUMBER;

--BUG 3763874 : along with the shipment direction bug
--a minor improvement was made to print out the error message if any
--in the LOG file output - this is mainly to aid any trouble-shooting

    o_msg_index NUMBER; --BUG 3763874
    f_msg_data VARCHAR2(2000); --BUG 3763874

  BEGIN

            l_event.param_name_1  := 'DEFERRED';
            l_event.param_value_1 := 'Y';

            l_event.param_name_2  := 'POST_OPERATION_API';
            l_event.param_value_2 := 'NONE';

            l_event.param_name_3  := 'PSIG_USER_KEY_LABEL';
            l_event.param_value_3 := qa_eres_util.get_mfg_lookups_meaning
                                          ('QA_ERES_KEY_LABEL',60);

            l_event.param_name_4  := 'PSIG_USER_KEY_VALUE';
            l_event.param_value_4 := p_delivery_name;

            l_event.param_name_5  := 'PSIG_TRANSACTION_AUDIT_ID';
            l_event.param_value_5 := '-1';

            l_event.param_name_6  := '#WF_SOURCE_APPLICATION_TYPE';
            l_event.param_value_6 := 'DB';

            l_event.param_name_7  := '#WF_SIGN_REQUESTER';
            l_event.param_value_7 := FND_GLOBAL.USER_NAME;

            l_event.event_name := g_event_name_const;
            l_event.event_key :=  p_delivery_id;
            --l_event.payload :=    l_payload;

   --BUG 3763874: p_init_msg_list should be TRUE
   --to clear the error buffer for each delivery erecord call

    	  QA_EDR_STANDARD.RAISE_ERES_EVENT
	      (
	       p_api_version => 1.0,
	       p_init_msg_list => FND_API.G_TRUE, --BUG 3763874
	       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	       x_return_status => o_return_status,
	       x_msg_count  => o_msg_count,
	       x_msg_data => o_msg_data,
	       p_child_erecords => l_child_erecords,
	       x_event => l_event);
	    commit; -- this commit is needed becos of EDR bug. Remove later.

	  fnd_file.put_line(fnd_file.log, 'Delivery id:'||p_delivery_id || '('
				||p_delivery_name|| ')'
				|| ' eRec status: ' || l_event.event_status
				|| ' eRec ID:' || l_event.erecord_id);

        --BUG 3763874: if any error messages, print them to the LOG
	--minor improvement done as part of fixing above bug
	if ( o_msg_count > 1) then
          FOR m IN 1..o_msg_count LOOP
		fnd_msg_pub.get ( p_data => f_msg_data,
				  p_encoded => 'F',
				  p_msg_index_out => o_msg_index);

		fnd_file.put_line (fnd_file.log, 'MSG'|| m ||' :'|| f_msg_data);
	 END LOOP;
	end if; --END BUG 3763874

           o_erecord_id := l_event.erecord_id;
	   p_erecord_id := l_event.erecord_id;
	   x_status 	:= o_return_status;

          IF (o_erecord_id IS NOT NULL AND o_erecord_id > 0)
          THEN
             QA_EDR_STANDARD.SEND_ACKN
                   ( p_api_version       => 1.0
                   , p_init_msg_list     => FND_API.G_TRUE
                   , x_return_status     => o_return_status
                   , x_msg_count         => o_msg_count
                   , x_msg_data          => o_msg_data
                   , p_event_name        => l_event.event_name
                   , p_event_key         => l_event.event_key
                   , p_erecord_id        => o_erecord_id
                   , p_trans_status      => 'SUCCESS'
                   , p_ackn_by           => 'Shipment Delivery eRecord Program'
                   , p_ackn_note         => ''
                   , p_autonomous_commit => FND_API.G_TRUE);
                    --english ok here for p_ackn_by, since internal
                    --program name
         END IF;
END raise_delivery_event;

END qa_eres_shipping;


/
