--------------------------------------------------------
--  DDL for Package Body XDP_CANCEL_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_CANCEL_ORDER" AS
/* $Header: XDPPCNLB.pls 115.1 2003/12/15 09:07:45 mboyat noship $ */

--
-- Private API which will check if all FAs are ready for cancel
-- for the given order
--
FUNCTION IS_PROCESSING_STARTED
            ( p_order_id  IN NUMBER
            ) RETURN BOOLEAN ;

PROCEDURE CANCEL_SFM_ORDER
(
    p_application_id                    in NUMBER,
    p_entity_short_name                 in VARCHAR2,
    p_validation_entity_short_name      in VARCHAR2,
    p_validation_tmplt_short_name       in VARCHAR2,
    p_record_set_short_name             in VARCHAR2,
    p_scope                             in VARCHAR2,
    x_result                            out NOCOPY NUMBER
)
IS
   l_api_name       CONSTANT VARCHAR2(30) := 'CANCEL_SFM_ORDER';
   l_api_version	CONSTANT NUMBER       := 11.5;
   l_order_number            NUMBER;
   l_order_version           NUMBER;
   lv_sfm_order_id           NUMBER;
   lv_state                  VARCHAR2(40);
   lv_order_type             VARCHAR2(40);
   lv_msg_id                 RAW(16);
   l_return_status           VARCHAR2(1);
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(800);
   l_item_key                VARCHAR2(40);
   l_user_key                VARCHAR2(40);
   l_err_name                VARCHAR2(40);
   l_err_message             VARCHAR2(100);
   l_err_stack               VARCHAR2(1000);
   error_message             VARCHAR2(1000);

Begin

   ----------------------------------------------------------------------
   -- Get the value of the Order Id and Order Version from the global
   -- record variable in the entity's constraint API package.
   ----------------------------------------------------------------------


   -- Set the x_result to 0 i.e. as success and handle it later
   x_result := 0;

   IF p_validation_entity_short_name = 'HEADER' THEN
      l_order_number  := oe_header_security.g_record.order_number;
      l_order_version := oe_header_security.g_record.version_number;
   END IF;

   ---------------------------------------------------------------------
   -- Check whether the Order Id is null.
   -- If the Order Id is null then return 1
   ----------------------------------------------------------------------
   IF l_order_number IS NULL OR
      l_order_number = FND_API.G_MISS_NUM
   THEN
      x_result := 1;
      return;
   END IF;

   ----------------------------------------------------------------------
   -- Get the SFM Order Id from the XDP_ORDER_HEADERS table
   ----------------------------------------------------------------------
   BEGIN
      IF l_order_version IS NOT NULL THEN
         SELECT order_id
         INTO   lv_sfm_order_id
         FROM   xdp_order_headers
         WHERE  external_order_number     = to_char(l_order_number) and
	            external_order_version    = to_char(l_order_version);
      ELSE
         SELECT order_id
         INTO   lv_sfm_order_id
         FROM   xdp_order_headers
         WHERE  external_order_number     = (l_order_number) and
    	        external_order_version    IS NULL;
      END IF;
   EXCEPTION
   ---------------------------------------------------------------------
   -- If no data found then return 0 as there is no SFM order that needs
   -- to be cancelled for this OM Ordre Id => Success
   ----------------------------------------------------------------------
      WHEN no_data_found THEN
	     x_result := 0;
         return;
   END;

   ----------------------------------------------------------------------
   -- Get the status code for the order for furthur processing
   ----------------------------------------------------------------------
   SELECT   status_code,
            msgid,
            order_type
   INTO     lv_state,
            lv_msg_id,
            lv_order_type
   FROM     xdp_order_headers
   WHERE    order_id = lv_sfm_order_id;

   ----------------------------------------------------------------------
   -- If the state is as listed below then return a success
   -- 1. Cancelled
   -- 2. Aborted
   ----------------------------------------------------------------------
   IF  lv_state IN ('CANCELED','ABORTED') THEN
       x_result := 0;
       return;

   ----------------------------------------------------------------------
   -- If the state is as listed below then call the SFM cancel API
   -- 1. Ready
   -- 2. Standby
   ----------------------------------------------------------------------

   ELSIF lv_state IN ('READY','STANDBY') THEN
        XDP_INTERFACES_PUB.Cancel_Order(
	           p_api_version 	    => l_api_version,
               p_init_msg_list	    => FND_API.G_FALSE,
               p_commit		        => FND_API.G_FALSE,
	           p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
           	   x_return_status 	    => l_return_status,
	           x_msg_count			=> l_msg_count,
	           x_msg_data			=> l_msg_data,
   	           P_SDP_ORDER_ID 		=> lv_sfm_order_id,
	           p_caller_name 		=> FND_GLOBAL.user_name);

          if l_return_status =  FND_API.G_RET_STS_SUCCESS THEN

          ---------------------------------------------------------------
          -- spawn the SFM_Rollback Workflow before returning a
          -- status of 1
          ---------------------------------------------------------------

          BEGIN
              -- Generate an Item Key with the help of OM Order Numebr
              l_item_key := 'XDPCNCL-' || 'SFM_ROLLBACK-' || l_order_number;

              -- Call The Create Process
              wf_engine.CreateProcess( itemtype => 'XDPCNCL',
                                       itemkey  => l_item_key,
                                       process  => 'SFM_ROLLBACK');

              -- Generate a User Key with the help of OM Order Numebr
              l_user_key := 'USER_KEY-' || 'XDPCNCL-' || 'SFM_ROLLBACK-' || l_order_number;

              -- Set the User Key for the process which uniquely identifies it
              wf_engine.setItemUserKey(itemtype => 'XDPCNCL',
                                       itemkey  => l_item_key,
                                       userkey  => l_user_key);

              -- Set the Value of OM Order Id  for the process
              wf_engine.SetItemAttrNumber(itemtype => 'XDPCNCL',
                                       itemkey  => l_item_key,
                                       aname    => 'ORDER_ID',
                                       avalue   => l_order_number);

              -- Set the process owner user name
              wf_engine.SetItemOwner(itemtype   => 'XDPCNCL',
                                     itemkey    => l_item_key,
                                     owner      =>  FND_GLOBAL.user_name);

              -- Start the process
              wf_engine.StartProcess(itemtype   => 'XDPCNCL',
                                     itemkey    => l_item_key);

          EXCEPTION
              WHEN OTHERS THEN
                  -- Get the error and push it to the OE_MSG_PUB
                  wf_core.GET_ERROR(err_name           => l_err_name,
                                    err_message        => l_err_message,
                                    err_stack          => l_err_stack,
                                    maxErrStackLength  => 900);

                  FND_MESSAGE.SET_NAME('XDP', 'XDP_INTFACE_PROCESS_FAIL');
        		  FND_MESSAGE.SET_TOKEN('ERROR_MSG',l_err_name || ' : ' || l_err_message);
        		  OE_MSG_PUB.Add;

                  -- Return with Failure
                  x_result := 1;
                  return;
          END;

          -- Return the Success
          x_result := 0;
          return;
       ELSE
          ---------------------------------------------------------------
          -- Push a message in the OE_MSG_PUB Stack
          ---------------------------------------------------------------
          error_message := FND_MSG_PUB.get(p_encoded => FND_API.g_false);
          while (error_message is not null) loop
              FND_MESSAGE.SET_NAME('XDP', 'XDP_INTFACE_PROCESS_FAIL');
        	  FND_MESSAGE.SET_TOKEN('ERROR_MSG', error_message);
              OE_MSG_PUB.Add;
              error_message := FND_MSG_PUB.get(p_encoded => FND_API.g_false);
          end loop;

          ---------------------------------------------------------------
          -- Return a value of one for a failure
          ---------------------------------------------------------------
           x_result := 1;
           return;
       END IF;

   ----------------------------------------------------------------------
   -- If the state is as listed below then check if any FA associated with
   -- it has started. If Not then cancel the order
   -- 1. Error
   -- 2. Progress
   ----------------------------------------------------------------------
   ELSIF lv_state IN ('ERROR','IN PROGRESS') THEN
       BEGIN
           IF IS_PROCESSING_STARTED(lv_sfm_order_id) THEN
               XDP_INTERFACES_PUB.Cancel_Order(
    	           p_api_version 	    => l_api_version,
                   p_init_msg_list	    => FND_API.G_FALSE,
                   p_commit		        => FND_API.G_FALSE,
                   p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
               	   x_return_status 	    => l_return_status,
	               x_msg_count			=> l_msg_count,
	               x_msg_data			=> l_msg_data,
   	               P_SDP_ORDER_ID 		=> lv_sfm_order_id,
    	           p_caller_name 		=> FND_GLOBAL.user_name);

               if l_return_status = FND_API.G_RET_STS_SUCCESS THEN

               ---------------------------------------------------------------
               -- spawn the SFM_Rollback Workflow before returning a
               -- status of 1
               ---------------------------------------------------------------

               BEGIN
                  -- Generate an Item Key with the help of OM Order Numebr
                  l_item_key := 'XDPCNCL' || 'SFM_ROLLBACK' || l_order_number;

                  -- Call The Create Process
                  wf_engine.CreateProcess( itemtype => 'XDPCNCL',
                                           itemkey  => l_item_key,
                                           process  => 'SFM_ROLLBACK');

                  -- Generate a User Key with the help of OM Order Numebr
                  l_user_key := 'USER_KEY' || 'XDPCNCL' || 'SFM_ROLLBACK' || l_order_number;

                  -- Set the User Key for the process which uniquely identifies it
                  wf_engine.setItemUserKey(itemtype => 'XDPCNCL',
                                           itemkey  => l_item_key,
                                           userkey  => l_user_key);

                  -- Set the Value of OM Order Id  for the process
                  wf_engine.SetItemAttrNumber(itemtype => 'XDPCNCL',
                                           itemkey  => l_item_key,
                                           aname    => 'ORDER_ID',
                                           avalue   => l_order_number);

                  -- Set the process owner user name
                  wf_engine.SetItemOwner(itemtype   => 'XDPCNCL',
                                         itemkey    => l_item_key,
                                         owner      =>  FND_GLOBAL.user_name);

                  -- Start the process
                  wf_engine.StartProcess(itemtype   => 'XDPCNCL',
                                         itemkey    => l_item_key);

               EXCEPTION
                   WHEN no_data_found THEN
                      -- Get the error and push it to the OE_MSG_PUB
                      wf_core.GET_ERROR(err_name           => l_err_name,
                                        err_message        => l_err_message,
                                        err_stack          => l_err_stack,
                                        maxErrStackLength  => 900);

                      FND_MESSAGE.SET_NAME('XDP', 'XDP_INTFACE_PROCESS_FAIL');
               		  FND_MESSAGE.SET_TOKEN('ERROR_MSG',l_err_name || ' : ' || l_err_message);
        		      OE_MSG_PUB.Add;
                      -- Return with Failure
                      x_result := 1;
                      return;
               END;

               -- Return the Success
               x_result := 0;
               return;
               ELSE
                   ---------------------------------------------------------------
                   -- Push a message in the OE_MSG_PUB Stack
                   ---------------------------------------------------------------
                   error_message := FND_MSG_PUB.get(p_encoded => FND_API.g_false);
                   while (error_message is not null) loop
                       FND_MESSAGE.SET_NAME('XDP', 'XDP_INTFACE_PROCESS_FAIL');
                	   FND_MESSAGE.SET_TOKEN('ERROR_MSG', error_message);
                       OE_MSG_PUB.Add;
                       error_message := FND_MSG_PUB.get(p_encoded => FND_API.g_false);
                   end loop;

                   ---------------------------------------------------------------
                   -- Return a value of one for a failure
                   ---------------------------------------------------------------
                   x_result := 1;
                   return;
               END IF;
           ELSE
               -- Return the failure as there are FA's running/success/error
               x_result := 1;
               return;
           END IF;
       EXCEPTION
            when OTHERS THEN
                      -- Return with Failure
                      x_result := 1;
                      return;

       END;

   ----------------------------------------------------------------------
   -- Or else if the state is as listed below then return a failure
   -- 1. Unknown
   -- 2. Success
   -- 3. Success With Override
   ----------------------------------------------------------------------
   ELSE
       -- Return with Failure
       x_result := 1;
       return;

   END IF;
   ----------------------------------------------------------------------
   ---- We always need to return a failure with '1' as the return_status
   ----------------------------------------------------------------------
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_result := 1;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_result := 1 ;

	WHEN OTHERS THEN
		x_result := 1;

--End of the Procedure
END CANCEL_SFM_ORDER;

-------------------------------------------------------------------------
-- Private API check if all FAs  are ready for cancel for the given order
-------------------------------------------------------------------------

FUNCTION IS_PROCESSING_STARTED( p_order_id  IN NUMBER)
  RETURN BOOLEAN IS
  l_error_progress_state  BOOLEAN := TRUE ;
  CURSOR  CheckIfCancellable IS
       SELECT  'Y'
       FROM    XDP_FULFILL_WORKLIST FulfillWorklist,
               XDP_FA_RUNTIME_LIST  FARuntimeList
       WHERE   FulfillWorklist.order_id             = p_order_id
         AND   FulfillWorklist.workitem_instance_id = FARuntimeList.workitem_instance_id
         AND   FARuntimeList.status_code            IN ('IN PROGRESS', 'ERROR', 'SUCCESS',
                                                       'SUCCESS_WITH_OVERRIDE', 'CANCELED', 'ABORTED');

  BEGIN
       FOR CheckIfCancellableRecord IN CheckIfCancellable
       LOOP
           l_error_progress_state := FALSE ;
       END LOOP ;

   RETURN l_error_progress_state ;

-- End of the function
END IS_PROCESSING_STARTED;



--End of the package
END XDP_CANCEL_ORDER;

/
