--------------------------------------------------------
--  DDL for Package Body XNP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_UTILS" AS
/* $Header: XNPUTILB.pls 120.1 2005/06/17 03:44:45 appldev  $ */

g_new_line CONSTANT VARCHAR2(10) := convert(fnd_global.local_chr(10),
        substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'),'.') +1),
        'WE8ISO8859P1')  ;
 ----------------------------------------------------------------------
----***  Procedure:    MSG_TO_ORDER()
----***  Purpose:      Retrieves order parameters from a flat XML message.
----------------------------------------------------------------------

PROCEDURE MSG_TO_ORDER
 (P_MSG_TEXT IN VARCHAR2
 ,P_WI_NAME IN VARCHAR2
 ,X_LINE_PARAM_LIST OUT NOCOPY XDP_TYPES.LINE_PARAM_LIST
 ,X_ORDER_LINE_LIST  OUT NOCOPY XDP_TYPES.ORDER_LINE_LIST
 ,X_ERROR_CODE OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 )
IS
    l_value                  VARCHAR2(16000) ;
    l_index                  NUMBER ;
    l_starting_number        VARCHAR2(80) := null;
    l_ending_number        VARCHAR2(80) := null;
    e_MISSING_MANDATORY_DATA EXCEPTION ;

    CURSOR get_wi_params IS
      SELECT wip.parameter_name name,
        wip.required_flag mandatory_flag
      FROM xdp_workitems wis,
           xdp_wi_parameters wip
      WHERE wis.workitem_name = p_wi_name
      AND wis.workitem_id = wip.workitem_id;


BEGIN

  x_order_line_list(1).line_number := 1 ;
  x_order_line_list(1).line_item_name := p_wi_name ;
  x_order_line_list(1).action := NULL ;
  x_order_line_list(1).IS_WORKITEM_FLAG := 'Y';
  x_order_line_list(1).provisioning_required_flag := 'Y';

  XNP_XML_UTILS.DECODE(p_msg_text, 'STARTING_NUMBER', l_starting_number) ;
  x_order_line_list(1).starting_number := l_starting_number ;

  XNP_XML_UTILS.DECODE(p_msg_text, 'ENDING_NUMBER', l_ending_number) ;
  x_order_line_list(1).ending_number := l_ending_number ;

  l_index := 1 ;

  -- First swap the reference id and opposite refernce id

  XNP_XML_UTILS.DECODE(p_msg_text, 'REFERENCE_ID', l_value) ;
  x_line_param_list(l_index).line_number := 1;
  x_line_param_list(l_index).parameter_name := 'OPP_REFERENCE_ID';
  x_line_param_list(l_index).parameter_value := l_value ;
  l_index := l_index + 1;

  XNP_XML_UTILS.DECODE(p_msg_text, 'OPP_REFERENCE_ID', l_value) ;
  x_line_param_list(l_index).line_number := 1;
  x_line_param_list(l_index).parameter_name := 'REFERENCE_ID';
  x_line_param_list(l_index).parameter_value := l_value ;
  l_index := l_index + 1;


  -- Set the SP_NAME same as the RECIPIENT_NAME

  XNP_XML_UTILS.DECODE(p_msg_text, 'RECIPIENT_NAME', l_value) ;
  x_line_param_list(l_index).line_number := 1;
  x_line_param_list(l_index).parameter_name := 'SP_NAME';
  x_line_param_list(l_index).parameter_value := l_value ;

  l_index := l_index + 1;

  FOR wi_param IN get_wi_params LOOP

    IF ( (wi_param.name <> 'REFERENCE_ID')
      AND (wi_param.name <> 'OPP_REFERENCE_ID')
      AND (wi_param.name <> 'SP_NAME') )
    THEN
     XNP_XML_UTILS.DECODE(p_msg_text, wi_param.name, l_value) ;

     IF (wi_param.mandatory_flag = 'Y') THEN
      IF (l_value IS NULL) THEN
         x_error_message := 'Missing Mandatory Parameter - ' ||
           wi_param.name ;
         RAISE e_MISSING_MANDATORY_DATA ;
      END IF ;
     END IF ;

     x_line_param_list(l_index).line_number := 1;
     x_line_param_list(l_index).parameter_name := wi_param.name ;
     x_line_param_list(l_index).parameter_value := l_value ;

     l_index := l_index + 1 ;
    END IF; -- check for reference and opp reference id

  END LOOP ;

  EXCEPTION
    WHEN e_MISSING_MANDATORY_DATA THEN
      x_error_code := XNP_ERRORS.G_MISSING_MANDATORY_DATA ;
    WHEN OTHERS THEN
      x_error_code := SQLCODE ;
      x_error_message := SQLERRM ;

END MSG_TO_ORDER ;

 ----------------------------------------------------------------------
----***  Function:    GET_GEO_INFO ()
----***  Purpose:      gets the geographic name for the given porting ID
----------------------------------------------------------------------

FUNCTION GET_GEO_INFO ( P_PORTING_ID IN VARCHAR2 )
  RETURN VARCHAR2
IS
  l_subscription_tn   VARCHAR2(10) ;
  l_geo_area_name     XNP_GEO_AREAS_B.CODE%TYPE ;

  CURSOR get_geo_area (subscription_tn IN VARCHAR2) IS
  SELECT geo.code FROM xnp_geo_areas_b geo
  WHERE geo.geo_area_id IN (SELECT nre.geo_area_id
                            FROM xnp_number_ranges nre
                            WHERE subscription_tn BETWEEN
                            starting_number AND ending_number );
  CURSOR get_tn is
    SELECT subscription_tn
    FROM XNP_SV_SOA
    WHERE object_reference = p_porting_id ;

BEGIN

  OPEN get_tn;
  FETCH get_tn INTO l_subscription_tn;
  CLOSE get_tn;

  OPEN   get_geo_area(l_subscription_tn) ;
  FETCH  get_geo_area INTO l_geo_area_name ;
  CLOSE get_geo_area;

  RETURN (l_geo_area_name) ;

END ;

 ----------------------------------------------------------------------
----***  Function:     SEND_ACK_MSG ()
----***  Purpose:      Wrapper for creating an ACK message
----------------------------------------------------------------------

PROCEDURE SEND_ACK_MSG (P_MSG_TO_ACK IN NUMBER
 ,P_CODE IN NUMBER
 ,P_DESCRIPTION IN VARCHAR2
 ,X_ERROR_CODE OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 )
IS

  l_msg_header  XNP_MESSAGE.MSG_HEADER_REC_TYPE ;
  l_tmp_header  XNP_MESSAGE.MSG_HEADER_REC_TYPE ;

  l_msg_text    VARCHAR2(32767) ;

BEGIN

  l_msg_text := NULL ;
  XNP_MESSAGE.GET_HEADER(p_msg_to_ack, l_tmp_header) ;

  XNP_ACK_U.create_msg (XNP$CODE=>p_code,
                  XNP$DESCRIPTION=>p_description,
                  x_msg_header=>l_msg_header,
                  x_msg_text=>l_msg_text,
                  x_error_code=>x_error_code,
                  x_error_message=>x_error_message,
		  p_reference_id=>TO_CHAR(p_msg_to_ack),
		  p_opp_reference_id=>l_tmp_header.reference_id) ;

  IF (x_error_code = 0) THEN

    l_msg_header.direction_indr := 'I' ;

    XNP_MESSAGE.PUSH(p_msg_header=>l_msg_header,
      p_body_text=>l_msg_text,
      p_queue_name=>'XNP_IN_MSG_Q',
      p_correlation_id=>TO_CHAR(p_msg_to_ack)) ;

  END IF ;

END SEND_ACK_MSG ;


 --------------------------------------------------------------------
 -- Procedure to get the fe_name of the donor for this
 -- transaction.
 ------------------------------------------------------------------
PROCEDURE GET_DONOR_FE
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_FE_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  )
IS
 l_PORTING_ID VARCHAR2(40);
 l_DONOR_SP_ID NUMBER := 0;
 l_DONOR_SP_CODE VARCHAR2(40) := NULL;
 l_error_desc varchar2(4000) := NULL;
BEGIN

  x_RETURN_CODE := 0;
  x_ERROR_DESCRIPTION := NULL;

   ------------------------------------------------------------------ Get the donor sp id from the workitem params
   -- directly. If not found there then get it from
   -- the SOA table
   ------------------------------------------------------------------
  l_DONOR_SP_CODE :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'DONOR_SP_ID'
   );

  IF l_DONOR_SP_CODE = NULL
  THEN

    -- Get the Porting ID from the WI params table
    l_PORTING_ID :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (p_WI_INSTANCE_ID
     ,'PORTING_ID'
     );

    -- Get the donor sp id from the SOA table
    SELECT DONOR_SP_ID INTO l_DONOR_SP_ID
     FROM XNP_SV_SOA
     WHERE OBJECT_REFERENCE = l_PORTING_ID;

  ELSE

    XNP_CORE.GET_SP_ID
     (p_SP_NAME=>l_DONOR_SP_CODE
     ,x_SP_ID=>l_DONOR_SP_ID
     ,x_ERROR_CODE=>x_RETURN_CODE
     ,x_ERROR_MESSAGE=>x_ERROR_DESCRIPTION
     );
    IF x_RETURN_CODE <> 0
    THEN
     RETURN;
    END IF;

  END IF;

/* BUG 1500177
  --  get the Adapter name
*/
  --  get the fe name
  XNP_UTILS.GET_FE_NAME_FOR_SP
   (p_SP_ID=>l_DONOR_SP_ID
   ,x_FE_NAME=>x_FE_NAME
   ,x_ERROR_CODE=>x_RETURN_CODE
   ,x_ERROR_MESSAGE=>x_ERROR_DESCRIPTION
   );
  IF x_RETURN_CODE <> 0
  THEN
    RETURN;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    -- Grab the error message and error no.
    fnd_message.set_name('XNP','GET_DONOR_FE_ERR_REASON');
    fnd_message.set_token('PORTING_ID',l_porting_id);
    l_error_desc := fnd_message.get;


    x_RETURN_CODE := SQLCODE;
    x_ERROR_DESCRIPTION := SQLERRM||l_error_desc;

END GET_DONOR_FE;

 --------------------------------------------------------------------
 -- Procedure to get the fe_name of the initial donor for this
 -- transaction.
 ------------------------------------------------------------------
PROCEDURE GET_ORIG_DONOR_FE
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_FE_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  )
IS
 l_STARTING_NUMBER VARCHAR2(40);
 l_ENDING_NUMBER VARCHAR2(40);
 l_ORIGINAL_DONOR_SP_ID NUMBER := 0;
 l_DONOR_SP_CODE VARCHAR2(40) := NULL;
 l_error_description varchar2(2000) := NULL;
BEGIN

  x_RETURN_CODE := 0;
  x_ERROR_DESCRIPTION := NULL;

  l_STARTING_NUMBER :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ENDING_NUMBER :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  XNP_CORE.GET_ASSIGNED_SP_ID
   (p_STARTING_NUMBER=>l_STARTING_NUMBER
   ,p_ENDING_NUMBER=>l_ENDING_NUMBER
   ,x_ASSIGNED_SP_ID=>l_ORIGINAL_DONOR_SP_ID
   ,x_ERROR_CODE=>x_RETURN_CODE
   ,x_ERROR_MESSAGE=>x_ERROR_DESCRIPTION
   );

  IF x_RETURN_CODE <> 0
  THEN
   RETURN;
  END IF;


/* BUG 1500177
  --  get the fe name
*/
  --  get the fe name
  XNP_UTILS.GET_FE_NAME_FOR_SP
   (p_SP_ID=>l_ORIGINAL_DONOR_SP_ID
   ,x_FE_NAME=>x_FE_NAME
   ,x_ERROR_CODE=>x_RETURN_CODE
   ,x_ERROR_MESSAGE=>x_ERROR_DESCRIPTION
   );
  IF x_RETURN_CODE <> 0
  THEN
    RETURN;
  END IF;


  EXCEPTION
    WHEN OTHERS THEN
    -- Grab the error message and error no.
    fnd_message.set_name('XNP','GET_ORIG_DONOR_FE_ERR_REASON');
    l_error_description := fnd_message.get;

    x_RETURN_CODE := SQLCODE;
    x_ERROR_DESCRIPTION := SQLERRM||l_error_description;

END GET_ORIG_DONOR_FE;

 --------------------------------------------------------------------
 -- Procedure to get the fe_name of the NRC for this
 -- transaction.
 ------------------------------------------------------------------
PROCEDURE GET_NRC_FE
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_FE_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  )
IS
 l_STARTING_NUMBER VARCHAR2(40);
 l_ENDING_NUMBER VARCHAR2(40);
 l_NRC_SP_ID NUMBER;
 l_error_description varchar2(2000) := NULL;
BEGIN

  x_RETURN_CODE := 0;
  x_ERROR_DESCRIPTION := NULL;

  -- Get the NRC id for this range
  l_STARTING_NUMBER :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ENDING_NUMBER :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  XNP_CORE.GET_NRC_ID
   (p_STARTING_NUMBER=>l_STARTING_NUMBER
   ,p_ENDING_NUMBER=>l_ENDING_NUMBER
   ,x_NRC_ID=>l_NRC_SP_ID
   ,x_ERROR_CODE=>x_RETURN_CODE
   ,x_ERROR_MESSAGE=>x_ERROR_DESCRIPTION
   );
  IF x_RETURN_CODE <> 0
  THEN
    RETURN;
  END IF;

/* BUG 1500177
  --  get the fe name
*/
  --  get the fe name
  XNP_UTILS.GET_FE_NAME_FOR_SP
   (p_SP_ID=>l_NRC_SP_ID
   ,x_FE_NAME=>x_FE_NAME
   ,x_ERROR_CODE=>x_RETURN_CODE
   ,x_ERROR_MESSAGE=>x_ERROR_DESCRIPTION
   );
  IF x_RETURN_CODE <> 0
  THEN
    RETURN;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    -- Grab the error message and error no.
    fnd_message.set_name('XNP','GET_NRC_FE_ERR_REASON');
    l_error_description := fnd_message.get;

    x_RETURN_CODE := SQLCODE;
    x_ERROR_DESCRIPTION := SQLERRM||l_error_description;

END GET_NRC_FE;

 --------------------------------------------------------------------
 -- Procedure to get the fe_name of the Recipient for this
 -- transaction.
 ------------------------------------------------------------------
PROCEDURE GET_RECIPIENT_FE
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_FE_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  )
IS
 l_PORTING_ID VARCHAR2(40);
 l_RECIPIENT_SP_ID NUMBER;
 l_RECIPIENT_SP_CODE VARCHAR2(40);
 l_error_description varchar2(2000) := NULL;
BEGIN

  x_RETURN_CODE := 0;
  x_ERROR_DESCRIPTION := NULL;

   ------------------------------------------------------------------ Get the recipient sp id from the workitem params
   -- directly. If not found there then get it from
   -- the SOA table
   ------------------------------------------------------------------
  l_RECIPIENT_SP_CODE :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'RECIPIENT_SP_ID'
   );

  IF l_RECIPIENT_SP_CODE = NULL
  THEN
    -- Get the Porting ID from the WI params table
    l_PORTING_ID :=
     XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
     (p_WI_INSTANCE_ID
     ,'PORTING_ID'
     );

    -- Get the donor sp id from the SOA table
    SELECT RECIPIENT_SP_ID INTO l_RECIPIENT_SP_ID
     FROM XNP_SV_SOA
     WHERE OBJECT_REFERENCE = l_PORTING_ID;
  ELSE

    XNP_CORE.GET_SP_ID
     (p_SP_NAME=>l_RECIPIENT_SP_CODE
     ,x_SP_ID=>l_RECIPIENT_SP_ID
     ,x_ERROR_CODE=>x_RETURN_CODE
     ,x_ERROR_MESSAGE=>x_ERROR_DESCRIPTION
     );
    IF x_RETURN_CODE <> 0
    THEN
     RETURN;
    END IF;

  END IF;

/* BUG 1500177
  --  get the fe name
*/
  --  get the fe name
  XNP_UTILS.GET_FE_NAME_FOR_SP
   (p_SP_ID=>l_RECIPIENT_SP_ID
   ,x_FE_NAME=>x_FE_NAME
   ,x_ERROR_CODE=>x_RETURN_CODE
   ,x_ERROR_MESSAGE=>x_ERROR_DESCRIPTION
   );
  IF x_RETURN_CODE <> 0
  THEN
    RETURN;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    -- Grab the error message and error no.
    fnd_message.set_name('XNP','GET_RECIPIENT_FE_ERR_REASON');
    fnd_message.set_token('PORTING_ID',l_porting_id);
    l_error_description := fnd_message.get;

    x_RETURN_CODE := SQLCODE;
    x_ERROR_DESCRIPTION := SQLERRM||l_error_description;

END GET_RECIPIENT_FE;

PROCEDURE GET_SENDER_FE
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_FE_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  )
IS
 l_SENDER_SP_ID NUMBER;
 l_SENDER_SP_CODE VARCHAR2(40);
 l_error_description varchar2(2000) := NULL;
BEGIN

  x_RETURN_CODE := 0;
  x_ERROR_DESCRIPTION := NULL;

   ------------------------------------------------------------------ Get the recipient sp id from the workitem params
   -- directly. If not found there then get it from
   -- the SOA table
   ------------------------------------------------------------------
  l_SENDER_SP_CODE :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'SENDER_NAME'
   );

  XNP_CORE.GET_SP_ID
     (p_SP_NAME=>l_SENDER_SP_CODE
     ,x_SP_ID=>l_SENDER_SP_ID
     ,x_ERROR_CODE=>x_RETURN_CODE
     ,x_ERROR_MESSAGE=>x_ERROR_DESCRIPTION
     );
  IF x_RETURN_CODE <> 0
  THEN
     RETURN;
  END IF;

/* BUG 1500177
  --  get the fe name
*/
  --  get the fe name
  XNP_UTILS.GET_FE_NAME_FOR_SP
   (p_SP_ID=>l_SENDER_SP_ID
   ,x_FE_NAME=>x_FE_NAME
   ,x_ERROR_CODE=>x_RETURN_CODE
   ,x_ERROR_MESSAGE=>x_ERROR_DESCRIPTION
   );
  IF x_RETURN_CODE <> 0
  THEN
    RETURN;
  END IF;

 EXCEPTION
 when others then
   x_return_code := SQLCODE;
   fnd_message.set_name('XNP','GET_NAME_ERR_REASON');
   fnd_message.set_token('PARAM_NAME','Get_Sender_Fe:SENDER_NAME');

   x_error_description := SQLERRM||' : '||fnd_message.get;

END GET_SENDER_FE;


 ----------------------------------------------------------------------
----***  Function:     LOG_MSG ()
----***  Purpose:
----------------------------------------------------------------------

PROCEDURE LOG_MSG (P_SEVERITY_LEVEL IN NUMBER
 ,P_CONTEXT IN VARCHAR2
 ,P_DESCRIPTION IN VARCHAR2
 )
IS
	l_debug_level VARCHAR2(40) ;
        l_debug_id NUMBER := null;
BEGIN
	FND_PROFILE.GET( NAME => 'XNP_DEBUG_LEVEL',
		VAL => l_debug_level ) ;
	G_DEBUG_LEVEL := TO_NUMBER(l_debug_level) ;
  IF (P_SEVERITY_LEVEL <= G_DEBUG_LEVEL) THEN
    INSERT INTO XNP_DEBUG (DEBUG_ID
                          ,DEBUG_LEVEL
                          , CONTEXT
                          , DESCRIPTION
                          , created_by
                          , creation_date
                          ,last_updated_by
                          ,last_update_date)
      VALUES( xnp_debug_s.nextval, P_SEVERITY_LEVEL, P_CONTEXT, P_DESCRIPTION
            ,fnd_global.user_id,sysdate,fnd_global.user_id,sysdate) ;
  END IF ;
END LOG_MSG ;

 ------------------------------------------------------------------
 -- This function converts dates to the canonical format
 ------------------------------------------------------------------
FUNCTION CANONICAL_TO_DATE
  (p_DATE_AS_CHAR  VARCHAR2
  )
RETURN DATE
IS

 l_CANONICAL_MASK VARCHAR2(15) := 'YYYY/MM/DD';
 l_CANONICAL_DT_MASK VARCHAR2(26) := 'YYYY/MM/DD HH24:MI:SS';

 e_invalid_date_format exception;
 l_return_date DATE := null;

BEGIN

 l_return_date := fnd_date.canonical_to_date(p_date_as_char);

 if ( l_return_date IS null) then
   raise e_invalid_date_format;
 else
   return l_return_date;
 end if;

 EXCEPTION
   WHEN OTHERS THEN
     --wf_core.context( 'XNP_UTILS'
     --           , 'CANONICAL_TO_DATE'
     --           , 'String format of given date is invalid hence returning NULL: Allowed format is :'||l_CANONICAL_DT_MASK
     --           , null
      --          , null
       --         , null
       --         , null
       --         );
     RETURN NULL;

END CANONICAL_TO_DATE;

 ------------------------------------------------------------------
 -- This function converts dates to chars in canonical format
 ------------------------------------------------------------------
FUNCTION DATE_TO_CANONICAL
  (p_DATE DATE
  ,p_MASK_TYPE VARCHAR2 DEFAULT 'DATETIME'
  )
RETURN VARCHAR2

IS


 l_CANONICAL_MASK VARCHAR2(15) := 'YYYY/MM/DD';
 l_CANONICAL_DT_MASK VARCHAR2(26) := 'YYYY/MM/DD HH24:MI:SS';
 l_return_date VARCHAR2(26) := null;
 e_wrong_date_format exception;

BEGIN

 l_return_date := fnd_date.date_to_canonical(p_date);
 if (l_return_date IS null) then
   raise e_wrong_date_format;
 else
   return l_return_date;
 end if;

 EXCEPTION
   WHEN OTHERS THEN
     --wf_core.context( 'XNP_UTILS'
      --          , 'DATE_TO_CANONICAL'
       --         , 'Date format of given date is invalid hence returning NULL: Preferred format is :'||l_CANONICAL_DT_MASK
        --        , null
         --       , null
          --      , null
           --     , null
            --    );
     RETURN NULL;
END DATE_TO_CANONICAL;

 --------------------------------------------------------------------
 -- Procedure to get the fe_name of the donor for this
 -- transaction.
 ------------------------------------------------------------------
PROCEDURE GET_DONOR_NAME
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_RECIPIENT_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  )
IS
BEGIN

 x_RECIPIENT_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'DONOR_SP_ID'
   );

 exception
 when others then
   x_return_code := SQLCODE;
   fnd_message.set_name('XNP','GET_NAME_ERR_REASON');
   fnd_message.set_token('PARAM_NAME','DONOR_SP_ID');

   x_error_description := SQLERRM||' : '||fnd_message.get;

END GET_DONOR_NAME;

 --------------------------------------------------------------------
 -- Procedure to get the of the sender of the
 -- earlier message
 ------------------------------------------------------------------
PROCEDURE GET_SENDER_NAME
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_RECIPIENT_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  )
IS
BEGIN

 x_RECIPIENT_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'SENDER_NAME'
   );

 exception
 when others then
   x_return_code := SQLCODE;
   fnd_message.set_name('XNP','GET_NAME_ERR_REASON');
   fnd_message.set_token('PARAM_NAME','SENDER_NAME');

   x_error_description := SQLERRM||' : '||fnd_message.get;


END GET_SENDER_NAME;

 --------------------------------------------------------------------
 -- Procedure to get the fe_name of the initial donor for this
 -- transaction.
 ------------------------------------------------------------------
PROCEDURE GET_ORIG_DONOR_NAME
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_RECIPIENT_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  )
IS
l_STARTING_NUMBER VARCHAR2(40);
l_ENDING_NUMBER VARCHAR2(40);
l_ORIGINAL_DONOR_SP_ID NUMBER := 0;
BEGIN
 x_RETURN_CODE := 0;

  l_STARTING_NUMBER :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ENDING_NUMBER :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  XNP_CORE.GET_ASSIGNED_SP_ID
   (p_STARTING_NUMBER=>l_STARTING_NUMBER
   ,p_ENDING_NUMBER=>l_ENDING_NUMBER
   ,x_ASSIGNED_SP_ID=>l_ORIGINAL_DONOR_SP_ID
   ,x_ERROR_CODE=>x_RETURN_CODE
   ,x_ERROR_MESSAGE=>x_ERROR_DESCRIPTION
   );
  IF x_RETURN_CODE <> 0
  THEN
   RETURN;
  END IF;

  XNP_CORE.GET_SP_NAME
   (l_ORIGINAL_DONOR_SP_ID
   ,x_RECIPIENT_NAME
   ,x_RETURN_CODE
   ,x_ERROR_DESCRIPTION
   );
 exception
 when others then
   x_return_code := SQLCODE;
   fnd_message.set_name('XNP','GET_NAME_ERR_REASON');
   fnd_message.set_token('PARAM_NAME','STARTING_NUMBER/ENDING_NUMBER');

   x_error_description := SQLERRM||' : '||fnd_message.get;

END GET_ORIG_DONOR_NAME;

 --------------------------------------------------------------------
 -- Procedure to get the fe_name of the NRC for this
 -- transaction.
 ------------------------------------------------------------------
PROCEDURE GET_NRC_NAME
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_RECIPIENT_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  )
IS
l_starting_number VARCHAR2(40);
l_ending_number VARCHAR2(40);
l_GEO_ID NUMBER := 0;
l_NRC_ID NUMBER := 0;
BEGIN
  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  -- Get the NRC id

  XNP_CORE.GET_NRC_ID
   (l_STARTING_NUMBER
   ,l_ENDING_NUMBER
   ,l_NRC_ID
   ,x_RETURN_CODE
   ,x_ERROR_DESCRIPTION
   );
  if x_return_code <> 0 then
   return;
  end if;

  XNP_CORE.GET_SP_NAME
   (l_NRC_ID
   ,x_RECIPIENT_NAME
   ,x_RETURN_CODE
   ,x_ERROR_DESCRIPTION
   );
  if x_return_code <> 0 then
   return;
  end if;

 exception
 when others then
   x_return_code := SQLCODE;
   fnd_message.set_name('XNP','GET_NAME_ERR_REASON');
   fnd_message.set_token('PARAM_NAME','STARTING_NUMBER/ENDING_NUMBER');

   x_error_description := SQLERRM||' : '||fnd_message.get;

END GET_NRC_NAME;


 --------------------------------------------------------------------
 -- Procedure to get the fe_name of the NRC for this
 -- transaction.
 ------------------------------------------------------------------
PROCEDURE GET_RECIPIENT_NAME
  (p_ORDER_ID IN NUMBER
  ,p_WI_INSTANCE_ID IN NUMBER
  ,p_FA_INSTANCE_ID IN NUMBER
  ,x_RECIPIENT_NAME OUT NOCOPY VARCHAR2
  ,x_RETURN_CODE OUT NOCOPY NUMBER
  ,x_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
  )
IS
BEGIN
   x_RECIPIENT_NAME :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (p_WI_INSTANCE_ID
   ,'RECIPIENT_SP_ID'
   );
 exception
 when others then
   x_return_code := SQLCODE;
   fnd_message.set_name('XNP','GET_NAME_ERR_REASON');
   fnd_message.set_token('PARAM_NAME','RECIPIENT_SP_ID');
   x_error_description := SQLERRM||' : '||fnd_message.get;


END GET_RECIPIENT_NAME;

 ------------------------------------------------------------------
 -- Get the FE Name for the given FE ID
 ------------------------------------------------------------------
PROCEDURE GET_FE_NAME
   (p_FE_ID NUMBER
   ,x_FE_NAME OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
   )
IS
CURSOR get_fe_name_for_fe_id IS
   SELECT fulfillment_element_name
   FROM xdp_fes FET
   WHERE FET.fe_id = p_fe_id;
BEGIN

    --  get the fe name
   OPEN get_fe_name_for_fe_id ;
   FETCH get_fe_name_for_fe_id INTO x_FE_NAME ;
   close get_fe_name_for_fe_id ;

   EXCEPTION
    WHEN OTHERS THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','GET_DONOR_FE_ERR_REASON');
      fnd_message.set_token('FE_ID',to_char(p_fe_id));

      x_error_message := SQLERRM||':'|| fnd_message.get;

      IF get_fe_name_for_fe_id%ISOPEN THEN
        close get_fe_name_for_fe_id ;
      END IF ;

END GET_FE_NAME;


PROCEDURE GET_FE_NAME
   (p_SP_ID NUMBER
   ,x_FE_NAME OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
   )
IS



/****** declared at package level as it was used
        in differenc procedures.. skilaru 03/26/2001

CURSOR get_fe_name_for_sp IS
   SELECT fulfillment_element_name
   FROM xdp_fes FET,
	xnp_sp_adapters SPA,
	xdp_fe_generic_config SWG
   WHERE FET.fe_id = SPA.fe_id
    AND SPA.fe_id = SWG.fe_id
    AND SPA.sp_id = p_sp_id
    AND (sysdate BETWEEN SWG.start_date
    AND NVL(SWG.end_date, sysdate))
    ORDER BY preferred_flag desc, sequence asc ;

****/

BEGIN
    --  get the fe name

   OPEN g_get_fe_name_for_sp_csr(p_sp_id);
   FETCH g_get_fe_name_for_sp_csr INTO x_FE_NAME ;


   IF g_get_fe_name_for_sp_csr%NOTFOUND THEN
        x_error_code := xnp_errors.g_no_fe_for_sp;
        fnd_message.set_name('XNP','NO_FE_FOR_SP');
        fnd_message.set_token('NAME', TO_CHAR(p_sp_id));
        x_error_message := fnd_message.get;
        CLOSE g_get_fe_name_for_sp_csr ;
        RETURN ;

   END IF;

   EXCEPTION
    WHEN OTHERS THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','GET_FE_NAME_FOR_SP_ERR_REASON');
      fnd_message.set_token('SP_ID',p_sp_id);

      x_error_message := SQLERRM||':'||fnd_message.get;

      IF g_get_fe_name_for_sp_csr%ISOPEN THEN
        close g_get_fe_name_for_sp_csr ;
      END IF ;

END GET_FE_NAME;

PROCEDURE GET_FE_NAME_FOR_SP
   (p_SP_ID NUMBER
   ,x_FE_NAME OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
   )
IS
/**** declared at package level as it is used in
      several procedures. -- skilaru 03/25/2001

CURSOR get_fe_name_for_sp IS
   SELECT fulfillment_element_name
   FROM xdp_fes FET,
	xnp_sp_adapters SPA,
	xdp_fe_generic_config SWG
   WHERE FET.fe_id = SPA.fe_id
    AND SPA.fe_id = SWG.fe_id
    AND SPA.sp_id = p_sp_id
    AND (sysdate BETWEEN SWG.start_date
    AND NVL(SWG.end_date, sysdate))
    ORDER BY preferred_flag desc, sequence asc ;
*****/

BEGIN
    --  get the fe name

   OPEN g_get_fe_name_for_sp_csr( p_sp_id) ;
   FETCH g_get_fe_name_for_sp_csr INTO x_FE_NAME ;

   IF g_get_fe_name_for_sp_csr%NOTFOUND THEN
        x_error_code := xnp_errors.g_no_fe_for_sp;
        fnd_message.set_name('XNP','NO_FE_FOR_SP');
        fnd_message.set_token('NAME', TO_CHAR(p_sp_id));
        x_error_message := fnd_message.get;
        CLOSE g_get_fe_name_for_sp_csr ;
        RETURN ;

   END IF;

   close g_get_fe_name_for_sp_csr ;

EXCEPTION
    WHEN OTHERS THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','GET_FE_NAME_FOR_SP_ERR_REASON');
      fnd_message.set_token('SP_ID',p_sp_id);

      x_error_message := SQLERRM||':'||fnd_message.get;

      IF g_get_fe_name_for_sp_csr%ISOPEN THEN
        close g_get_fe_name_for_sp_csr ;
      END IF ;

END GET_FE_NAME_FOR_SP;
 ----------------------------------------------------------------------
----***  Procedure:    EXEC_DYNAMIC_CREATE_MSG()
----***  Purpose:      Execute dynamic SQL for message create.
----------------------------------------------------------------------

PROCEDURE EXEC_DYNAMIC_CREATE_MSG
 (P_DYNAMIC_MSG_TEXT IN VARCHAR2
 ,X_MSG_TEXT OUT NOCOPY VARCHAR2
 ,X_ERROR_CODE OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 )
IS
 ----------------------------------------------------------------------
----*** local variables
----------------------------------------------------------------------

  l_cursor        NUMBER ;
  l_sql           VARCHAR2(16000) ;
  l_num_rows      NUMBER ;
  l_msg_header    XNP_MESSAGE.MSG_HEADER_REC_TYPE;
BEGIN

 ----------------------------------------------------------------------
--  open cursor for dynamic SQL
----------------------------------------------------------------------

  l_cursor := DBMS_SQL.OPEN_CURSOR;
  x_error_code := 0 ;
  x_error_message := NULL ;

 ----------------------------------------------------------------------
 -- parse the SQL statement
----------------------------------------------------------------------

  DBMS_SQL.PARSE ( l_cursor, P_DYNAMIC_MSG_TEXT, DBMS_SQL.V7 ) ;

 ------------------------------------------------------------------
-- bind all input and output variables
------------------------------------------------------------------
  DBMS_SQL.BIND_VARIABLE ( l_cursor, ':msg_text', x_msg_text ) ;
  DBMS_SQL.BIND_VARIABLE ( l_cursor, ':error_code', x_error_code ) ;
  DBMS_SQL.BIND_VARIABLE ( l_cursor, ':error_message', x_error_message, 1024 ) ;

 ----------------------------------------------------------------------
--  execute the procedure call
----------------------------------------------------------------------

  l_num_rows := DBMS_SQL.EXECUTE ( l_cursor ) ;

 ----------------------------------------------------------------------
 -- retrieve the return values
----------------------------------------------------------------------

  DBMS_SQL.VARIABLE_VALUE ( l_cursor, ':msg_text',  x_msg_text ) ;
  DBMS_SQL.VARIABLE_VALUE ( l_cursor, ':error_code', x_error_code ) ;
  DBMS_SQL.VARIABLE_VALUE ( l_cursor, ':error_message',  x_error_message ) ;

 ----------------------------------------------------------------------
 -- not processing the error message, an exception will be raised
----------------------------------------------------------------------

  DBMS_SQL.CLOSE_CURSOR ( l_cursor ) ;

END EXEC_DYNAMIC_CREATE_MSG ;

 ----------------------------------------------------------------------
----***  Procedure:    EXEC_DYNAMIC_SEND_PUBLISH()
----***  Purpose:      Execute dynamic SQL for message send and publish.
----------------------------------------------------------------------

PROCEDURE EXEC_DYNAMIC_SEND_PUBLISH
 (P_DYNAMIC_MSG_TEXT IN VARCHAR2
 ,X_MSG_ID OUT NOCOPY NUMBER
 ,X_ERROR_CODE OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 )
IS
 ----------------------------------------------------------------------
----* local variables
----------------------------------------------------------------------

  l_cursor        NUMBER ;
  l_sql           VARCHAR2(16000) ;
  l_num_rows      NUMBER ;
BEGIN

 ----------------------------------------------------------------------
  -- open cursor for dynamic SQL
----------------------------------------------------------------------

  l_cursor := DBMS_SQL.OPEN_CURSOR;
  x_error_code := 0 ;
  x_error_message := NULL ;

 ----------------------------------------------------------------------
  -- parse the SQL statement
----------------------------------------------------------------------

  DBMS_SQL.PARSE ( l_cursor, P_DYNAMIC_MSG_TEXT, DBMS_SQL.V7 ) ;

 ------------------------------------------------------------------
-- bind all input and output variables
------------------------------------------------------------------
  DBMS_SQL.BIND_VARIABLE ( l_cursor, ':msg_id', x_msg_id ) ;
  DBMS_SQL.BIND_VARIABLE ( l_cursor, ':error_code', x_error_code ) ;
  DBMS_SQL.BIND_VARIABLE ( l_cursor, ':error_message', x_error_message, 1024 ) ;

 ----------------------------------------------------------------------
--  execute the procedure call
----------------------------------------------------------------------

  l_num_rows := DBMS_SQL.EXECUTE ( l_cursor ) ;

 ----------------------------------------------------------------------
 -- retrieve the return values
----------------------------------------------------------------------

  DBMS_SQL.VARIABLE_VALUE ( l_cursor, ':msg_id', x_msg_id ) ;
  DBMS_SQL.VARIABLE_VALUE ( l_cursor, ':error_code', x_error_code ) ;
  DBMS_SQL.VARIABLE_VALUE ( l_cursor, ':error_message',  x_error_message ) ;

 ----------------------------------------------------------------------
  -- not processing the error message, an exception will be raised
----------------------------------------------------------------------

  DBMS_SQL.CLOSE_CURSOR ( l_cursor ) ;

END EXEC_DYNAMIC_SEND_PUBLISH ;

 ------------------------------------------------------------------
 -- Procedure to notify errors in the workflow activities
 ------------------------------------------------------------------
PROCEDURE NOTIFY_ERROR
 (P_PKG_NAME VARCHAR2
 ,P_PROC_NAME VARCHAR2
 ,P_MSG_NAME VARCHAR2
 ,P_WORKITEM_INSTANCE_ID NUMBER
 ,P_TOK1 VARCHAR2 DEFAULT NULL
 ,P_VAL1 VARCHAR2 DEFAULT NULL
 ,P_TOK2 VARCHAR2 DEFAULT NULL
 ,P_VAL2 VARCHAR2 DEFAULT NULL
 ,P_TOK3 VARCHAR2 DEFAULT NULL
 ,P_VAL3 VARCHAR2 DEFAULT NULL
 )
IS
 l_progress VARCHAR2(4000) := NULL;
 l_STARTING_NUMBER VARCHAR2(40) := NULL;
 l_ENDING_NUMBER VARCHAR2(40) := NULL;
BEGIN
 fnd_message.set_name('XNP',p_msg_name);

 l_STARTING_NUMBER :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (P_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

 l_ENDING_NUMBER :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (P_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );
 fnd_message.set_token('NUMRANGE'
    , l_STARTING_NUMBER||' to ' || l_ENDING_NUMBER);

 if (p_tok1 IS NOT NULL) then
   fnd_message.set_token(p_tok1, p_val1);
 end if;

 if (p_tok2 IS NOT NULL) then
   fnd_message.set_token(p_tok2, p_val2);
 end if;

 if (p_tok3 IS NOT NULL) then
   fnd_message.set_token(p_tok3, p_val3);
 end if;


 l_progress := '$' || fnd_message.get;

 wf_core.context( p_pkg_name
                , p_proc_name
                , l_progress
                , null
                , null
                , null
                , null
                );

END NOTIFY_ERROR;

 ----------------------------------------------------------------------
----***  Procedure:    GET_WF_INSTANCE()
----***  Purpose:      Returns the workflow type, key and activity.
----------------------------------------------------------------------


PROCEDURE GET_WF_INSTANCE (
P_PROCESS_REFERENCE IN VARCHAR2
,X_WF_TYPE     OUT NOCOPY VARCHAR2
,X_WF_KEY      OUT NOCOPY VARCHAR2
,X_WF_ACTIVITY OUT NOCOPY VARCHAR2
)
IS
    l_str          VARCHAR2(256) ;
    l_start_pos    NUMBER  := 0;
    l_end_pos      NUMBER := 0;

BEGIN

    x_wf_type := NULL ;
    x_wf_key := NULL ;
    x_wf_activity := NULL ;
    l_str := p_process_reference;

    l_start_pos := l_end_pos+1;
    l_end_pos := INSTR(l_str, ':',l_start_pos,1);
    x_wf_type := SUBSTR(l_str, l_start_pos, (l_end_pos - l_start_pos));


    l_start_pos := l_end_pos+1;
    l_end_pos := INSTR(l_str, ':', l_start_pos, 1);
    x_wf_key := SUBSTR(l_str,l_start_pos, (l_end_pos - l_start_pos));

    l_start_pos := l_end_pos+1;
    l_end_pos := LENGTH(p_process_reference)+1;

    x_wf_activity := SUBSTR(l_str,l_start_pos, (l_end_pos - l_start_pos));

END GET_WF_INSTANCE ;

 ------------------------------------------------------------------
 -- Gets the process referenc against the reference_id
 -- from xnp_callback_events. Then looks up the WF to
 -- get the item attribute WORKITEM_INSTANCE_ID
 ------------------------------------------------------------------

PROCEDURE GET_WORKITEM_INSTANCE_ID
(p_reference_id VARCHAR2
,x_workitem_instance_id OUT NOCOPY NUMBER
,x_error_code OUT NOCOPY NUMBER
,x_error_message OUT NOCOPY VARCHAR2
)
IS
  l_process_reference VARCHAR2(512) := NULL;
  l_wf_type VARCHAR2(40) := NULL;
  l_wf_key VARCHAR2(240) := NULL;
  l_wf_activity VARCHAR2(240) := NULL;

  CURSOR c_get_process_reference IS
    SELECT process_reference
    FROM xnp_callback_events
    WHERE reference_id = p_reference_id;

BEGIN

   x_error_code := 0;

   -- Get the first of the available rows returned by the cursor
   OPEN c_get_process_reference;
   FETCH c_get_process_reference INTO l_process_reference;

   IF c_get_process_reference%NOTFOUND THEN
      raise NO_DATA_FOUND;
   END IF;

   CLOSE c_get_process_reference;

   XNP_UTILS.GET_WF_INSTANCE
    (P_PROCESS_REFERENCE => l_process_reference
    ,X_WF_TYPE => l_wf_type
    ,X_WF_KEY  => l_wf_key
    ,X_WF_ACTIVITY => l_wf_activity
    );

   x_workitem_instance_id := wf_engine.GetItemAttrNumber
                             (itemtype=>l_wf_type
                             ,itemkey=>l_wf_key
                             ,aname=>'WORKITEM_INSTANCE_ID'
                             );

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_error_code := SQLCODE;
       fnd_message.set_name('XNP','STD_GET_FAILED');
       fnd_message.set_token('FAILED_PROC','XNP_UTILS.GET_WORKITEM_INSTANCE_ID');
       fnd_message.set_token('ATTRNAME','PROCESS_REFERENCE');
       fnd_message.set_token('KEY','REFERENCE_ID');
       fnd_message.set_token('VALUE',p_reference_id);
       x_error_message := fnd_message.get||':'||SQLERRM;

       IF c_get_process_reference%ISOPEN THEN
          close c_get_process_reference;
       END IF;

     WHEN OTHERS THEN
       x_error_code := SQLCODE;
       fnd_message.set_name('XNP','STD_ERROR');
       fnd_message.set_token('ERROR_LOCN','XNP_UTILS.GET_WORKITEM_INSTANCE_ID');
       fnd_message.set_token('ERROR_TEXT',SQLERRM);
       x_error_message := fnd_message.get;

       IF c_get_process_reference%ISOPEN THEN
          close c_get_process_reference;
       END IF;

END GET_WORKITEM_INSTANCE_ID;

 ------------------------------------------------------------------
 -- Procedure Get the PORTING_ID from the body text
 -- of the message and overwrites the REFERENCE_ID
 -- with this value
 -- For the subsequent transactions, the PORITNG_ID's
 -- value will be the REFERENCE_ID for this transaction
 --
 ------------------------------------------------------------------
PROCEDURE RESET_REFERENCE_ID (
p_msg_header IN OUT NOCOPY XNP_MESSAGE.MSG_HEADER_REC_TYPE,
p_msg_text IN VARCHAR2,
x_error_code OUT NOCOPY  NUMBER,
x_error_message  OUT NOCOPY VARCHAR2 )
IS
l_PORTING_ID VARCHAR2(80) := NULL;
BEGIN
 XNP_XML_UTILS.DECODE(p_msg_text, 'PORTING_ID', l_PORTING_ID);

 if (l_PORTING_ID IS NOT NULL) then
   p_msg_header.reference_id := l_PORTING_ID;
 end if;
END RESET_REFERENCE_ID;

 ------------------------------------------------------------------
 -- Gets the value in CALLBACK_REF_ID_NAME activity attribute
 -- if the value is not CUSTOM
 --   then it refers to a WI param name so the value is
 --   got from there
 -- if the value IS CUSTOM
 --   then the actual value is got from the CUSTOM_CALLBACK_REFERENCE_ID
 --   activity attrbute and directly returned.
 ------------------------------------------------------------------
PROCEDURE CHECK_TO_GET_REF_ID
 (p_itemtype        in varchar2
 ,p_itemkey         in varchar2
 ,p_actid           in number
 ,p_workitem_instance_id in number
 ,x_reference_id  OUT NOCOPY varchar2
 )
IS

 l_activity_name         VARCHAR2(256);
 l_atype                 VARCHAR2(256);
 l_asubtype              VARCHAR2(256);
 l_aformat               VARCHAR2(256);
 l_number_value        NUMBER;
 l_date_value          DATE;
 l_wi_param_name       VARCHAR2(80) := NULL;
 l_callback_ref_id_name  VARCHAR2(80) := 'CALLBACK_REFERENCE_ID_NAME';
 l_custom_callback_ref_id  VARCHAR2(80) := 'CUSTOM_CALLBACK_REFERENCE_ID';

BEGIN

   l_wi_param_name := wf_engine.GetActivityAttrText
                     (itemtype => p_itemtype
                     ,itemkey  => p_itemkey
                     ,actid  => p_actid
                     ,aname   => l_callback_ref_id_name
                     );

   if (l_wi_param_name = 'CUSTOM') then
      -- get the value from the activity attribute CUSTOM_CALLBACK_REFERENCE_ID
        x_reference_id := wf_engine.GetActivityAttrText
                     (itemtype => p_itemtype
                     ,itemkey  => p_itemkey
                     ,actid  => p_actid
                     ,aname   => l_custom_callback_ref_id
                     );
   else
      -- get the reference id value from the workitem parameter value
      x_reference_id := xnp_standard.get_mandatory_wi_param_value
                            (p_workitem_instance_id
                            ,l_wi_param_name
                            );

   end if;

END CHECK_TO_GET_REF_ID;

 ------------------------------------------------------------------
 -- Copies the workitem parameter value from the
 -- source workitem to the destination workitem
 ------------------------------------------------------------------
PROCEDURE COPY_WI_PARAM_VALUE
 (p_src_wi_id number
 ,p_dest_wi_id number
 ,p_param_name varchar2
 )
IS
l_param_value varchar2(200) := null;
BEGIN
  l_param_value := xnp_standard.get_workitem_param_value
                    (p_workitem_instance_id => p_src_wi_id
                    ,p_parameter_name => p_param_name
                    );

  -- Set the value in the destination workitem
  xnp_standard.set_workitem_param_value
   (p_workitem_instance_id=>p_dest_wi_id
   ,p_parameter_name=>p_param_name
   ,p_parameter_value=>l_param_value
   );

END COPY_WI_PARAM_VALUE;

 ------------------------------------------------------------------
 -- Copies the all workitem parameter values from the
 -- source workitem to the destination workitem
 ------------------------------------------------------------------
PROCEDURE COPY_ALL_WI_PARAMS
 (p_src_wi_id number
 ,p_dest_wi_id number
 )
IS
    CURSOR c_wi_params IS

     SELECT wip.parameter_name name
      FROM xdp_wi_parameters wip
      WHERE wip.workitem_id =
	(SELECT fwl.workitem_id
         FROM xdp_fulfill_worklist fwl
	 WHERE fwl.workitem_instance_id = p_src_wi_id
	);
BEGIN

  -- Copy all the workitem parameters one by one
  FOR wi_param IN c_wi_params LOOP
    XNP_UTILS.COPY_WI_PARAM_VALUE
     (p_src_wi_id => p_src_wi_id
     ,p_dest_wi_id => p_dest_wi_id
     ,p_param_name => wi_param.name
     );
  END LOOP;

END COPY_ALL_WI_PARAMS;

 ------------------------------------------------------------------
 -- The MLS message is got. All the tokens are replace by
 -- the values as in the workitem parameters
 --
 -- Note:
 --  1. Ensure that each workitem paramter (token) has
 --   atleast 1 space after it
 --  2. The subject will be the character after the first new line
 ------------------------------------------------------------------
PROCEDURE GET_INTERPRETED_NOTIFICATION
 (p_workitem_instance_id number
 ,p_mls_message_name varchar2
 ,x_subject OUT NOCOPY varchar2
 ,x_body OUT NOCOPY varchar2
 ,x_error_code OUT NOCOPY number
 ,x_error_message OUT NOCOPY varchar2
 )
IS
  token varchar2(2000) := null;
  l_length number := 0;
  l_string varchar2(4000) := null;
  l_new_string varchar2(4000) := null;
  l_body varchar2(4000) := null;

  l_value varchar2(200):= null;
  l_posn number := 0;
  l_appln_name varchar2(4) := null;
BEGIN
  x_error_code := 0;
  x_error_message := null;

  -- Get the string to be parsed and decoded
  l_appln_name := substr(p_mls_message_name,1,3);
  l_string := fnd_message.get_string(l_appln_name,p_mls_message_name);

  fnd_message.set_name(l_appln_name,p_mls_message_name);

  -- ensure that there is a space before each '&'
  -- and space after the message string
  l_string := replace(l_string,'&',' &');
  l_string := l_string || ' ';

  -- get the lenght of the final string
  l_length := LENGTH(l_string);


  -- Loop through and interpret each token
  LOOP

    -- Check if there are any more uninterpreted tags
    if (l_string = replace(l_string,'&','%'))
    then
      exit;
    end if;

    token := substr
             (substr(l_string, instr(l_string,'&')+1)
             ,1
             ,instr(substr(l_string,instr(l_string,'&')+1),' ')
             );

    l_posn := instr(token, xnp_utils.g_new_line);
    if(l_posn > 0) then
      token := substr(token,1,l_posn-1);
    end if;
    l_posn := 0;

    token := replace(token,' ','');

    l_value :=  xnp_standard.get_workitem_param_value
       (p_workitem_instance_id
       ,token
       );

    fnd_message.set_token(token,nvl(l_value,'<null>'));

    l_string := substr(l_string,instr(l_string,token),l_length);

  EXIT WHEN ((length(l_string) = 0) OR (l_string is null ));
  END LOOP;

  l_body := fnd_message.get;
  x_body := l_body;
  x_subject := substr(l_body,1,instr(l_body,xnp_utils.g_new_line));
  return;

END GET_INTERPRETED_NOTIFICATION;


PROCEDURE get_adapter_name(
	p_sp_id NUMBER
	,x_adapter_name OUT NOCOPY VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)

IS
	CURSOR get_fe_name_for_sp1 IS
		SELECT fulfillment_element_name, FET.fe_id
		FROM xdp_fes FET,
			xnp_sp_adapters SPA,
			xdp_fe_generic_config SWG
		WHERE FET.fe_id = SPA.fe_id
		AND SPA.fe_id = SWG.fe_id
		AND SPA.sp_id = p_sp_id
		AND (sysdate BETWEEN SWG.start_date
		AND NVL(SWG.end_date, sysdate))
		ORDER BY preferred_flag desc, sequence asc ;
        l_fe_id NUMBER;
	l_fe_name VARCHAR2(1024) ;

BEGIN
	--  get the fe name

	OPEN get_fe_name_for_sp1;

	FETCH get_fe_name_for_sp1 INTO l_fe_name , l_fe_id;

	IF get_fe_name_for_sp1%NOTFOUND THEN

		x_error_code := xnp_errors.g_no_fe_for_sp;
		fnd_message.set_name('XNP','NO_FE_FOR_SP');
		fnd_message.set_token('NAME', TO_CHAR(p_sp_id));
		x_error_message := fnd_message.get;
		CLOSE get_fe_name_for_sp1 ;
		RETURN ;

	END IF;

	CLOSE get_fe_name_for_sp1 ;

	-- get adapter given the FE ID
	x_adapter_name := XDP_ADAPTER_CORE_DB.Is_Message_Adapter_Available(l_fe_id);

   EXCEPTION
    WHEN OTHERS THEN

      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','GET_FE_NAME_FOR_SP_ERR_REASON');
      fnd_message.set_token('SP_ID',p_sp_id);
      x_error_message := SQLERRM||':'||fnd_message.get;

      IF get_fe_name_for_sp1%ISOPEN THEN
        close get_fe_name_for_sp1 ;
      END IF ;

END GET_ADAPTER_NAME;


FUNCTION get_adapter_using_fe(
	p_fe_name IN VARCHAR2 )
RETURN VARCHAR2
IS
	--
	-- NOTE: This method should always be exactly the same as
	-- XDP_ADAPTER_CORE_DB.Is_Message_Adapter_Available(p_fe_name).
	-- We were not able to call this method directly because of the
	-- PRAGMA restrictions
	--
 l_adapter_name varchar2(80) := NULL;

 cursor c_getadapter IS
	SELECT xad.adapter_name
	FROM xdp_adapter_reg xad, xdp_adapter_types_b t,xdp_fes XFE
	WHERE XAD.fe_id = XFE.fe_id
          AND XFE.fulfillment_element_name = p_fe_name
	  AND xad.adapter_type = t.adapter_type
	  AND application_mode='QUEUE'
	  AND xad.adapter_status not in ('NOT_AVAILABLE')
 	ORDER BY
	  DECODE(adapter_status, 'IDLE', 1,
                 'SUSPENDED', 2,
                 'DISCONNECTED', 3,
                 'SHUTDOWN', 4, 5)
          ASC ;

BEGIN

   if c_getadapter%ISOPEN then
      close c_getadapter;
   end if;

   open c_getadapter;

   fetch c_getadapter into l_adapter_name;

   if c_getadapter%NOTFOUND then
	l_adapter_name := NULL;
   end if;

   return l_adapter_name;
exception
when others then
    if c_getadapter%ISOPEN then
      close c_getadapter;
   end if;
   raise;


END get_adapter_using_fe ;

--
-- Checks if the number range exists
--
PROCEDURE CHECK_IF_NUM_RANGE_EXISTS
  (p_STARTING_NUMBER IN VARCHAR2
  ,p_ENDING_NUMBER IN VARCHAR2
  ,p_NUMBER_RANGE_ID IN NUMBER
  )
IS

 l_number_range_id NUMBER := null;
---  4 cases to be considered to check if new number
----  is overlapping with existing number ranges
---             |-----------------|
--- 1.    <----------->
--- 2.             <----------->
--- 3.                      <----------->
--- 4.       <--------------------------->

CURSOR c_num_range_exists IS
SELECT number_range_id
  FROM xnp_number_ranges
 WHERE
       -- Case 1
       (    (to_number(starting_number) >= to_number(p_starting_number))
        AND (to_number(starting_number) <= to_number(p_ending_number))
        AND (to_number(ending_number)   >= to_number(p_ending_number)))
       -- Case 2
    OR (    (to_number(starting_number) <= to_number(p_starting_number))
        AND (to_number(ending_number)   >= to_number(p_ending_number)))
       -- Case 3
    OR (    (to_number(starting_number) <= to_number(p_starting_number))
        AND (to_number(ending_number)   >= to_number(p_starting_number))
        AND (to_number(ending_number)   <= to_number(p_ending_number)))
       -- Case 4
    OR (    (to_number(starting_number) >= to_number(p_starting_number))
        AND (to_number(ending_number)   <= to_number(p_ending_number)));

BEGIN

 OPEN c_num_range_exists;
 FETCH c_num_range_exists INTO l_number_range_id;

 IF (    (l_number_range_id is not null)
    AND (l_number_range_id <> nvl(p_number_range_id,-1)) )
 THEN
   fnd_message.set_name('XNP','XNP_NUM_RANGE_EXISTS');
   fnd_message.set_token('STARTING_NUMBER',p_STARTING_NUMBER);
   fnd_message.set_token('ENDING_NUMBER',p_ENDING_NUMBER);
   app_exception.raise_exception;
 END IF;

END CHECK_IF_NUM_RANGE_EXISTS;

END XNP_UTILS;

/
