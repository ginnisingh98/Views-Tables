--------------------------------------------------------
--  DDL for Package Body XNP_FA_CB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_FA_CB" AS
/* $Header: XNPFACBB.pls 120.2 2006/02/13 07:48:01 dputhiye ship $ */


 ------------------------------------------------------------------
 -- Gets the FE_ID,FEATURE_TYPE for which the provisioning
 -- system has responded to. Gets the number range
 -- and updates the XNP_SV_SMS_FE_MAPS to the
 -- provisioning status returned in the FA_DONE message
 -- The correct provisioning operation is derived and
 -- the right function is invoked to take it from there
 ------------------------------------------------------------------
PROCEDURE PROCESS_FA_DONE
 (p_MESSAGE_ID           IN NUMBER
 ,p_PROCESS_REFERENCE    IN VARCHAR2
 ,x_ERROR_CODE       OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE    OUT NOCOPY VARCHAR2
 )
IS
  l_feature_type_n_fe_id      VARCHAR2(256) ;
  l_wf_type                   VARCHAR2(256) ;
  l_wf_key                    VARCHAR2(256) ;
  l_fnd_message               VARCHAR2(4000) ;
  l_reference_id              VARCHAR2(512) := null;
  l_fa_instance_id            NUMBER := 0;
  l_fe_id                     NUMBER := 0;
  l_feature_type              VARCHAR2(40) := NULL;
  l_tmp_fe_id                 VARCHAR2(40) := NULL;
  l_provisioning_operation    VARCHAR2(240) := NULL;
  l_workitem_instance_id      NUMBER := 0;
  l_order_id                  NUMBER ;
  l_lineitem_id               NUMBER ;

  l_starting_number           VARCHAR2(80) := null;
  l_ending_number             VARCHAR2(80) := null;

  -- Should change to CLOB later

  l_msg_text        VARCHAR2(32767) ;

  l_msg_header      XNP_MESSAGE.MSG_HEADER_REC_TYPE ;
  l_sdp_result_code VARCHAR2(20) := NULL;

  e_workflow_parameters_invalid EXCEPTION ;
  e_NO_FE_FOUND EXCEPTION ;

  CURSOR c_FE_ID is
   select FE_ID
   from XDP_FA_RUNTIME_LIST
   where FA_INSTANCE_ID = l_fa_instance_id;

BEGIN

  x_error_code := 0 ;
  x_error_message := NULL ;

   ------------------------------------------------------------------
   -- Derive the workflow itemtype, itemkey and activity
   ------------------------------------------------------------------

  xnp_utils.get_wf_instance
   ( p_process_reference
   , l_wf_type
   , l_wf_key
   , l_feature_type_n_fe_id
   ) ;


  IF( (l_wf_key IS NULL) OR (l_wf_type IS NULL) OR (l_feature_type_n_fe_id IS NULL) )
  THEN
    raise e_workflow_parameters_invalid;
  END IF;

   ------------------------------------------------------------------
   -- Set the MESSAGE_BODY item attribute
   ------------------------------------------------------------------
  XNP_MESSAGE.GET(p_msg_id     => p_message_id,
                  x_msg_header => l_msg_header,
                  x_msg_text   => l_msg_text);

  -- Get the result code

  XNP_XML_UTILS.DECODE (l_msg_text,
    'SDP_RESULT_CODE',
    l_sdp_result_code) ;

  -- Get the reference id
  l_reference_id := l_msg_header.reference_id;

  -- Get the FA Instance Id
  l_fa_instance_id := to_number(l_reference_id);

  -- Get the workitem instance id

  xnp_utils.get_workitem_instance_id
    (p_reference_id         =>l_reference_id
    ,x_workitem_instance_id =>l_workitem_instance_id
    ,x_error_code           =>x_error_code
    ,x_error_message        =>x_error_message
    );


  if(x_error_code <> 0) then
    return;
  end if;

    SELECT order_id
      INTO l_order_id
      FROM xdp_fulfill_worklist
     WHERE workitem_instance_id = l_workitem_instance_id ;

  BEGIN
    l_starting_number :=
    xnp_standard.get_mandatory_wi_param_value
     (p_WORKITEM_INSTANCE_ID=>l_workitem_instance_id
     ,p_PARAMETER_NAME=>'STARTING_NUMBER'
     );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;
      FND_MESSAGE.set_name  ('XNP', 'GET_MANDATORY_WI_PARAM_ERR') ;
      FND_MESSAGE.set_token ('WIID', l_workitem_instance_id) ;
      FND_MESSAGE.set_token ('PARAM_NAME', 'STARTING_NUMBER') ;
      FND_MESSAGE.set_token ('ERRTEXT', SQLERRM) ;
      x_error_message := FND_MESSAGE.get ;
      return;
    WHEN OTHERS THEN
      x_error_code := SQLCODE;
      x_error_message := SQLERRM;
      return;
  END;

  BEGIN
    l_ending_number :=
    xnp_standard.get_mandatory_wi_param_value
     (p_WORKITEM_INSTANCE_ID=>l_workitem_instance_id
     ,p_PARAMETER_NAME=>'ENDING_NUMBER'
     );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;
      FND_MESSAGE.set_name  ('XNP', 'GET_MANDATORY_WI_PARAM_ERR') ;
      FND_MESSAGE.set_token ('WIID', l_workitem_instance_id) ;
      FND_MESSAGE.set_token ('PARAM_NAME', 'ENDING_NUMBER') ;
      FND_MESSAGE.set_token ('ERRTEXT', SQLERRM) ;
      x_error_message := FND_MESSAGE.get ;
      return;
    WHEN OTHERS THEN
      x_error_code := SQLCODE;
      x_error_message := SQLERRM;
      return;
  END;

  xnp_utils.get_wf_instance
   ( l_feature_type_n_fe_id
   , l_provisioning_operation
   , l_feature_type
   , l_tmp_fe_id
   ) ;
  l_fe_id := to_number(l_tmp_fe_id);

  if ( l_provisioning_operation = 'PROV')
  then
    xnp_fa_cb.provision_fe
     (p_STARTING_NUMBER       =>l_STARTING_NUMBER
     ,p_ENDING_NUMBER         =>l_ENDING_NUMBER
     ,p_FE_ID                 =>l_FE_ID
     ,p_FEATURE_TYPE          =>l_FEATURE_TYPE
     ,p_PROV_STATUS           =>l_SDP_RESULT_CODE
     ,p_ORDER_ID              =>l_ORDER_ID
     ,p_LINEITEM_ID           =>l_LINEITEM_ID
     ,p_WORKITEM_INSTANCE_ID  =>l_WORKITEM_INSTANCE_ID
     ,p_FA_INSTANCE_ID        =>l_FA_INSTANCE_ID
     ,x_ERROR_CODE            =>x_ERROR_CODE
     ,x_ERROR_MESSAGE         =>x_ERROR_MESSAGE
     );
  elsif ( l_provisioning_operation = 'MOD') then
    xnp_fa_cb.modify_fe
     (p_STARTING_NUMBER       =>l_STARTING_NUMBER
     ,p_ENDING_NUMBER         =>l_ENDING_NUMBER
     ,p_FE_ID                 =>l_FE_ID
     ,p_FEATURE_TYPE          =>l_FEATURE_TYPE
     ,p_PROV_STATUS           =>l_SDP_RESULT_CODE
     ,p_ORDER_ID              =>l_ORDER_ID
     ,p_LINEITEM_ID           =>l_LINEITEM_ID
     ,p_WORKITEM_INSTANCE_ID  =>l_WORKITEM_INSTANCE_ID
     ,p_FA_INSTANCE_ID        =>l_FA_INSTANCE_ID
     ,x_ERROR_CODE            =>x_ERROR_CODE
     ,x_ERROR_MESSAGE         =>x_ERROR_MESSAGE
     );
  elsif ( l_provisioning_operation = 'DEPROV') then
    xnp_fa_cb.deprovision_fe
     (p_STARTING_NUMBER       =>l_STARTING_NUMBER
     ,p_ENDING_NUMBER         =>l_ENDING_NUMBER
     ,p_FE_ID                 =>l_FE_ID
     ,p_FEATURE_TYPE          =>l_FEATURE_TYPE
     ,p_PROV_STATUS           =>l_SDP_RESULT_CODE
     ,p_ORDER_ID              =>l_ORDER_ID
     ,p_LINEITEM_ID           =>l_LINEITEM_ID
     ,p_WORKITEM_INSTANCE_ID  =>l_WORKITEM_INSTANCE_ID
     ,p_FA_INSTANCE_ID        =>l_FA_INSTANCE_ID
     ,x_ERROR_CODE            =>x_ERROR_CODE
     ,x_ERROR_MESSAGE         =>x_ERROR_MESSAGE
     );
   else
     null; -- ingnore it
   end if;
EXCEPTION
    WHEN e_workflow_parameters_invalid THEN
      FND_MESSAGE.set_name  ('XNP', 'INVALID_WF_SPECIFIED') ;
      FND_MESSAGE.set_token ('MSG_ID', l_msg_header.message_id) ;
      FND_MESSAGE.set_token ('p_REFERENCE', p_process_reference) ;
      l_fnd_message := FND_MESSAGE.get ;

      XNP_MESSAGE.UPDATE_STATUS
         (p_message_id
	   ,'FAILED'
	   ,l_fnd_message
         ) ;

      x_error_code := XNP_ERRORS.G_INVALID_WORKFLOW ;
      x_error_message := l_fnd_message ;

      if (c_fe_id%ISOPEN) then
        close c_fe_id;
      end if;
      return;

    WHEN e_NO_FE_FOUND THEN
      FND_MESSAGE.set_name  ('XNP', 'XNP_NO_FE_FOUND_ERR') ;
      FND_MESSAGE.set_token ('FA_INSTANCE_ID', l_reference_id) ;
      x_error_message := FND_MESSAGE.get ;
      x_error_code := SQLCODE;
      XNP_MESSAGE.UPDATE_STATUS
         (p_message_id
	   ,'FAILED'
	   ,x_error_message
         ) ;

      if (c_fe_id%ISOPEN) then
        close c_fe_id;
      end if;
      return;

    WHEN OTHERS THEN
      x_error_code := SQLCODE ;
      x_error_message := SQLERRM ;
      XNP_MESSAGE.UPDATE_STATUS
         (p_message_id
	   ,'FAILED'
	   ,x_error_message
         ) ;

      if (c_fe_id%ISOPEN) then
        close c_fe_id;
      end if;
      return;

END PROCESS_FA_DONE ;

PROCEDURE PROVISION_FE
   (p_STARTING_NUMBER         VARCHAR2
   ,p_ENDING_NUMBER           VARCHAR2
   ,p_FE_ID                   NUMBER
   ,p_FEATURE_TYPE            VARCHAR2
   ,p_PROV_STATUS             VARCHAR2
   ,p_ORDER_ID             IN NUMBER
   ,p_LINEITEM_ID          IN NUMBER
   ,p_WORKITEM_INSTANCE_ID IN NUMBER
   ,p_FA_INSTANCE_ID       IN NUMBER
   ,x_ERROR_CODE          OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
   )
IS
BEGIN

  XNP_CORE.SMS_UPDATE_FE_MAP_STATUS
   (p_STARTING_NUMBER       =>p_STARTING_NUMBER
   ,p_ENDING_NUMBER         =>p_ENDING_NUMBER
   ,p_FE_ID                 =>p_FE_ID
   ,p_FEATURE_TYPE          =>p_FEATURE_TYPE
   ,p_PROV_STATUS           =>p_PROV_STATUS
   ,p_ORDER_ID              =>p_ORDER_ID
   ,p_LINEITEM_ID           =>p_LINEITEM_ID
   ,p_WORKITEM_INSTANCE_ID  =>p_WORKITEM_INSTANCE_ID
   ,p_FA_INSTANCE_ID        =>p_FA_INSTANCE_ID
   ,x_ERROR_CODE            =>x_ERROR_CODE
   ,x_ERROR_MESSAGE         =>x_ERROR_MESSAGE
   );

END PROVISION_FE;

PROCEDURE MODIFY_FE
   (p_STARTING_NUMBER         VARCHAR2
   ,p_ENDING_NUMBER           VARCHAR2
   ,p_FE_ID                   NUMBER
   ,p_FEATURE_TYPE            VARCHAR2
   ,p_PROV_STATUS             VARCHAR2
   ,p_ORDER_ID             IN NUMBER
   ,p_LINEITEM_ID          IN NUMBER
   ,p_WORKITEM_INSTANCE_ID IN NUMBER
   ,p_FA_INSTANCE_ID       IN NUMBER
   ,x_ERROR_CODE          OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
   )
IS
BEGIN

  if((p_prov_status = 'ERROR') or (p_prov_status = 'SUCCESS')) then

    XNP_CORE.SMS_UPDATE_FE_MAP_STATUS
     (P_STARTING_NUMBER       =>P_STARTING_NUMBER
     ,p_ENDING_NUMBER         =>P_ENDING_NUMBER
     ,p_FE_ID                 =>p_FE_ID
     ,p_FEATURE_TYPE          =>p_FEATURE_TYPE
     ,p_PROV_STATUS           =>p_PROV_STATUS
     ,p_ORDER_ID              =>p_ORDER_ID
     ,p_LINEITEM_ID           =>p_LINEITEM_ID
     ,p_WORKITEM_INSTANCE_ID  =>p_WORKITEM_INSTANCE_ID
     ,p_FA_INSTANCE_ID        =>p_FA_INSTANCE_ID
     ,x_ERROR_CODE            =>x_ERROR_CODE
     ,x_ERROR_MESSAGE         =>x_ERROR_MESSAGE
     );

  end if;

END MODIFY_FE;

PROCEDURE DEPROVISION_FE
   (p_STARTING_NUMBER         VARCHAR2
   ,p_ENDING_NUMBER           VARCHAR2
   ,p_FE_ID                   NUMBER
   ,p_FEATURE_TYPE            VARCHAR2
   ,p_PROV_STATUS             VARCHAR2
   ,p_ORDER_ID             IN NUMBER
   ,p_LINEITEM_ID          IN NUMBER
   ,p_WORKITEM_INSTANCE_ID IN NUMBER
   ,p_FA_INSTANCE_ID       IN NUMBER
   ,x_ERROR_CODE          OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
   )
IS
BEGIN

  -- Delete the fe map entries for this FE_ID

  XNP_CORE.SMS_DELETE_FE_MAP
     (p_STARTING_NUMBER => p_starting_number
     ,p_ENDING_NUMBER => p_ending_number
     ,p_FE_ID => p_fe_id
     ,p_FEATURE_TYPE => p_feature_type
     ,x_ERROR_CODE => x_error_code
     ,x_ERROR_MESSAGE => x_error_message
     );

  XNP_CORE.SMS_DELETE_PORTED_NUMBER
     (p_STARTING_NUMBER => p_starting_number
     ,p_ENDING_NUMBER => p_ending_number
     ,x_ERROR_CODE => x_error_code
     ,x_ERROR_MESSAGE => x_error_message
     );

END DEPROVISION_FE;

END XNP_FA_CB;

/
