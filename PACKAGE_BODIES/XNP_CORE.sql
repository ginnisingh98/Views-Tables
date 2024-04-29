--------------------------------------------------------
--  DDL for Package Body XNP_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_CORE" AS
/* $Header: XNPCOREB.pls 120.2 2006/02/13 07:42:29 dputhiye ship $ */


PROCEDURE GET_ASSIGNED_SP_ID
 (p_STARTING_NUMBER IN VARCHAR2
 ,p_ENDING_NUMBER   IN VARCHAR2
 ,x_ASSIGNED_SP_ID  OUT NOCOPY NUMBER
 ,x_ERROR_CODE      OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
 )
IS
  CURSOR c_ASSIGNED_SP_ID IS
  SELECT assigned_sp_id
    FROM xnp_number_ranges
   WHERE starting_number <= p_starting_number
     AND ending_number   >= p_ending_number
     AND active_flag = 'Y';

BEGIN
  x_error_code := 0;
  x_assigned_sp_id := 0;

  -- Get the ASSIGNED_SP_ID corresponding to
  -- this number range

   OPEN c_assigned_sp_id;
   FETCH c_assigned_sp_id INTO x_assigned_sp_id;

  IF c_assigned_sp_id%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_assigned_sp_id;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
            x_error_code := SQLCODE;

            fnd_message.set_name('XNP','STD_GET_FAILED');
            fnd_message.set_token('FAILED_PROC','XNP_CORE.GET_ASSIGNED_SP_ID');
            fnd_message.set_token('ATTRNAME','ASSIGNED_SP_ID');
            fnd_message.set_token('KEY','STARTING_NUMBER:ENDING_NUMBER');
            fnd_message.set_token('VALUE',p_STARTING_NUMBER||':'||p_ENDING_NUMBER);
            x_error_message := fnd_message.get;
            x_error_message := x_error_message||':'||SQLERRM;

            fnd_message.set_name('XNP','GET_ASSIGNED_SP_ID_ERR');
            fnd_message.set_token('ERROR_TEXT',x_error_message);
            x_error_message := fnd_message.get;

      IF c_ASSIGNED_SP_ID%ISOPEN THEN
         CLOSE c_assigned_sp_id;
      END IF;

       WHEN OTHERS THEN
            x_error_code := SQLCODE;

            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','XNP_CORE.GET_ASSIGNED_SP_ID');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

      IF c_assigned_sp_id%ISOPEN THEN
         CLOSE c_assigned_sp_id;
      END IF;

END GET_ASSIGNED_SP_ID;

PROCEDURE GET_SP_ID
 (p_SP_NAME        IN VARCHAR2
 ,x_SP_ID         OUT NOCOPY NUMBER
 ,x_ERROR_CODE    OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 )
IS

  CURSOR c_sp_id IS
  SELECT sp_id
    FROM xnp_service_providers
   WHERE code        = p_sp_name
     AND active_flag = 'Y';


BEGIN
  x_error_code := 0;
  x_sp_id := 0;

  -- Get the SP_ID corresponding to
  -- this name
   OPEN c_sp_id;
  FETCH c_sp_id INTO x_sp_id;

  IF c_sp_id%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_sp_id;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
            x_error_code := SQLCODE;

            fnd_message.set_name('XNP','STD_GET_FAILED');
            fnd_message.set_token('FAILED_PROC','XNP_CORE.GET_SP_ID');
            fnd_message.set_token('ATTRNAME','SP_ID');
            fnd_message.set_token('KEY','CODE');
            fnd_message.set_token('VALUE',p_SP_NAME);
            x_error_message := fnd_message.get;
            x_error_message := x_error_message||':'||SQLERRM;

            fnd_message.set_name('XNP','GET_SP_ID_ERR');
            fnd_message.set_token('ERROR_TEXT',x_error_message);
            x_error_message := fnd_message.get;

      IF c_sp_id%ISOPEN THEN
       CLOSE c_sp_id;
      END IF;

       WHEN OTHERS THEN
            x_error_code := SQLCODE;

            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','XNP_CORE.GET_SP_ID');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

      IF c_SP_ID%ISOPEN THEN
       CLOSE c_sp_id;
      END IF;

END GET_SP_ID;

PROCEDURE GET_SP_NAME
 (p_SP_ID          IN NUMBER
 ,x_SP_NAME       OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE    OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 )
IS

  CURSOR c_sp_name IS
  SELECT code
    FROM xnp_service_providers
   WHERE sp_id = p_sp_id;

BEGIN

  x_error_code := 0;
  x_sp_name := NULL;

  -- get the name for this id
   OPEN c_sp_name;
  FETCH c_sp_name INTO x_sp_name;

  IF c_sp_name%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_sp_name;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
            x_error_code := SQLCODE;

            fnd_message.set_name('XNP','STD_GET_FAILED');
            fnd_message.set_token('FAILED_PROC','XNP_CORE.GET_SP_NAME_ID');
            fnd_message.set_token('ATTRNAME','CODE');
            fnd_message.set_token('KEY','SP_ID');
            fnd_message.set_token('VALUE',to_char(p_SP_ID));
            x_error_message := fnd_message.get;
            x_error_message := x_error_message||':'||SQLERRM;


            fnd_message.set_name('XNP','GET_SP_NAME_ERR');
            fnd_message.set_token('ERROR_TEXT',x_error_message);
            x_error_message := fnd_message.get;

      IF c_sp_name%ISOPEN THEN
       CLOSE c_sp_name;
      END IF;

       WHEN OTHERS THEN
            x_error_code := SQLCODE;

            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','XNP_CORE.GET_SP_NAME');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

      IF c_sp_name%ISOPEN THEN
       CLOSE c_sp_name;
      END IF;

END GET_SP_NAME;

PROCEDURE GET_ROUTING_NUMBER_ID
 (p_ROUTING_NUMBER     IN VARCHAR2
 ,x_ROUTING_NUMBER_ID OUT NOCOPY NUMBER
 ,x_ERROR_CODE        OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE     OUT NOCOPY VARCHAR2
 )
IS
  CURSOR c_routing_number_id IS
  SELECT routing_number_id
    FROM xnp_routing_numbers
   WHERE routing_number = p_routing_number
     AND active_flag    = 'Y';

BEGIN
  x_error_code := 0;
  x_routing_number_id := 0;

  -- Get the ROUTING_NUMBER_ID corresponding to
  -- this
  OPEN c_routing_number_id;
  FETCH c_routing_number_id INTO x_routing_number_id;

  IF c_routing_number_id%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_routing_number_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token('FAILED_PROC','XNP_CORE.GET_ROUTING_NUMBER_ID');
      fnd_message.set_token('ATTRNAME','ROUTING_NUMBER_ID');
      fnd_message.set_token('KEY','ROUTING_NUMBER');
      fnd_message.set_token('VALUE',p_ROUTING_NUMBER);
      x_error_message := fnd_message.get;
      x_error_message := x_error_message||':'||SQLERRM;


      fnd_message.set_name('XNP','GET_ROUTING_NUMBER_ID_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

      IF c_routing_number_id%ISOPEN THEN
       CLOSE c_routing_number_id;
      END IF;

    WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.GET_ROUTING_NUMBER_ID');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_routing_number_id%ISOPEN THEN
       CLOSE c_routing_number_id;
      END IF;

END GET_ROUTING_NUMBER_ID;

PROCEDURE GET_NRC_ID
 (p_STARTING_NUMBER  IN VARCHAR2
 ,p_ENDING_NUMBER    IN VARCHAR2
 ,x_NRC_ID          OUT NOCOPY NUMBER
 ,x_ERROR_CODE      OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
 )
IS

 l_enable_nrc_flag VARCHAR2(1) := 'Y';
 l_geo_id          NUMBER := null;
 l_starting_geo_id NUMBER := null;

   CURSOR c_starting_geo_id IS
	SELECT geo_area_id
	  FROM xnp_number_ranges
	 WHERE starting_number <= p_starting_number
	   AND ending_number   >= p_ending_number
	   AND sysdate         >= effective_date;

   CURSOR c_geo_id (l_starting_geo_id IN NUMBER) IS
            SELECT child_geo_area_id
            FROM xnp_geo_hierarchy
      START WITH child_geo_area_id = l_starting_geo_id
CONNECT BY PRIOR parent_geo_area_id = child_geo_area_id;

   CURSOR c_nrc_id(l_geo_id IN NUMBER) IS
     SELECT sp.sp_id
       FROM xnp_service_providers sp
            ,xnp_service_areas sa
      WHERE sp.sp_id       = sa.sp_id
        AND sp.sp_type     = 'NRC'
        AND sa.geo_area_id = l_geo_id;
BEGIN

   x_error_code := 0;
   x_nrc_id := null;

l_enable_nrc_flag := g_enable_nrc_flag;

/**
  fnd_profile.get
  (name => 'ENABLE_NRC'
  ,val => l_enable_nrc_flag
  ) ;
**/

  IF( (l_enable_nrc_flag IS NULL) OR (l_enable_nrc_flag <> 'Y') ) THEN
    x_nrc_id := null;
    RETURN;
  END IF;

  OPEN c_starting_geo_id;
  FETCH c_starting_geo_id INTO l_starting_geo_id;

  IF c_starting_geo_id%NOTFOUND THEN
    IF c_starting_geo_id%ISOPEN THEN
      CLOSE c_starting_geo_id;
    END IF;
    raise NO_DATA_FOUND;
  END IF;

  IF c_starting_geo_id%ISOPEN THEN
    CLOSE c_starting_geo_id;
  END IF;


  -- Check for NRC in the geo hierarchy tree
  -- starting with the children
  OPEN c_geo_id(l_starting_geo_id);
  LOOP
   x_nrc_id := null;
   l_geo_id := null;
   FETCH c_geo_id INTO l_geo_id;
   EXIT WHEN c_geo_id%NOTFOUND;

   BEGIN

     OPEN c_nrc_id(l_geo_id);
     FETCH c_nrc_id INTO x_nrc_id;

     IF c_nrc_id%NOTFOUND THEN
       IF c_nrc_id%ISOPEN THEN
         CLOSE c_nrc_id;
       END IF;
       raise NO_DATA_FOUND;
     END IF;

     IF c_nrc_id%ISOPEN THEN
       CLOSE c_nrc_id;
     END IF;

     IF (x_nrc_id is not null) THEN
       IF c_geo_id%ISOPEN THEN
         CLOSE c_geo_id;
       END IF;
       RETURN;
     END IF;

   EXCEPTION WHEN NO_DATA_FOUND THEN
     null; -- Ignore and move to the next parent geo area id
   END;

  END LOOP;

  IF c_geo_id%ISOPEN THEN
    CLOSE c_geo_id;
  END IF;

  -- If no NRC found after tracing through all the geo areas
  -- then at this point raise a nodatafound exception
  RAISE NO_DATA_FOUND;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token('FAILED_PROC','XNP_CORE.GET_NRC_ID');
      fnd_message.set_token('ATTRNAME','NRC_ID');
      fnd_message.set_token('KEY','STARTING_NUMBER:ENDING_NUMBER');
      fnd_message.set_token('VALUE',p_STARTING_NUMBER||':'||p_ENDING_NUMBER);
      x_error_message := fnd_message.get;
      x_error_message := x_error_message||':'||SQLERRM;

      fnd_message.set_name('XNP','GET_NRC_ID_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

      IF c_geo_id%ISOPEN THEN
       CLOSE c_geo_id;
      END IF;

      IF c_starting_geo_id%ISOPEN THEN
       CLOSE c_starting_geo_id;
      END IF;

      IF c_nrc_id%ISOPEN THEN
       CLOSE c_nrc_id;
      END IF;

    WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.GET_NRC_ID');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_geo_id%ISOPEN THEN
       CLOSE c_geo_id;
      END IF;

      IF c_starting_geo_id%ISOPEN THEN
       CLOSE c_starting_geo_id;
      END IF;

      IF c_nrc_id%ISOPEN THEN
       CLOSE c_nrc_id;
      END IF;

END GET_NRC_ID;


PROCEDURE GET_SOA_SV_ID
 (p_PHASE_INDICATOR     VARCHAR2
 ,p_SUBSCRIPTION_TN     VARCHAR2
 ,p_LOCAL_SP_ID         NUMBER DEFAULT NULL
 ,x_SV_ID           OUT NOCOPY NUMBER
 ,x_ERROR_CODE      OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
 )
IS

   CURSOR c_sv_id IS
   SELECT sv_soa_id
     FROM xnp_sv_soa SOA , xnp_sv_status_types_b STA
    WHERE SOA.subscription_tn = p_subscription_tn
      AND STA.phase_indicator = p_phase_indicator
      AND STA.status_type_code = SOA.status_type_code;

BEGIN
   x_error_code := 0;
   x_error_message := NULL;
   x_sv_id := 0;

  OPEN c_sv_id;
  FETCH c_sv_id INTO x_sv_id;

  IF c_sv_id%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_sv_id;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token('FAILED_PROC','XNP_CORE.GET_SOA_SV_ID');
      fnd_message.set_token('ATTRNAME','SV');
      fnd_message.set_token('KEY','TN:SPID:PHASE');
      fnd_message.set_token
       ('VALUE'
       ,p_subscription_tn
        ||':'||to_char(p_local_sp_id)
        ||':'||p_phase_indicator
       );
      x_error_message := fnd_message.get;
      x_error_message := x_error_message||':'||SQLERRM;


      fnd_message.set_name('XNP','GET_SOA_SV_ID_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

      IF c_SV_ID%ISOPEN THEN
       CLOSE c_sv_id;
      END IF;

   WHEN OTHERS THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.GET_SOA_SV_ID');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_sv_id%ISOPEN THEN
       CLOSE c_sv_id;
      END IF;

END GET_SOA_SV_ID;

PROCEDURE GET_PHASE_FOR_STATUS
 (p_CUR_STATUS_TYPE_CODE     VARCHAR2
 ,x_PHASE_INDICATOR      OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE           OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 )
IS
   CURSOR c_phase_indicator IS
   SELECT phase_indicator
     FROM xnp_sv_status_types_b
    WHERE status_type_code = p_cur_status_type_code;


BEGIN

  x_error_code := 0;
  x_error_message := NULL;
  x_phase_indicator := NULL;

   OPEN c_phase_indicator;
  FETCH c_phase_indicator INTO x_phase_indicator;

  IF c_phase_indicator%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_phase_indicator;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token('FAILED_PROC','XNP_CORE.GET_PHASE_FOR_STATUS');
      fnd_message.set_token('ATTRNAME','PHASE_INDICATOR');
      fnd_message.set_token('KEY','STATUS_TYPE_CODE');
      fnd_message.set_token('VALUE',p_CUR_STATUS_TYPE_CODE);
      x_error_message := fnd_message.get;
      x_error_message := x_error_message||':'||SQLERRM;


      fnd_message.set_name('XNP','GET_PHASE_FOR_STATUS_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

      IF c_phase_indicator%ISOPEN THEN
        CLOSE c_phase_indicator;
      END IF;

    WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.GET_PHASE_FOR_STATUS');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_phase_indicator%ISOPEN THEN
        CLOSE c_phase_indicator;
      END IF;

END GET_PHASE_FOR_STATUS;

PROCEDURE GET_NUMBER_RANGE_ID
 (p_STARTING_NUMBER     VARCHAR2
 ,p_ENDING_NUMBER       VARCHAR2
 ,x_NUMBER_RANGE_ID OUT NOCOPY NUMBER
 ,x_ERROR_CODE      OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
 )
IS

   CURSOR c_number_range_id IS
   SELECT number_range_id
     FROM xnp_number_ranges
    WHERE starting_number <= p_starting_number
      AND ending_number   >= p_ending_number
      AND sysdate         >= effective_date
      AND active_flag='Y';

BEGIN

   OPEN c_number_range_id;
  FETCH c_number_range_id INTO x_number_range_id;

     IF c_number_range_id%NOTFOUND THEN
        raise NO_DATA_FOUND;
     END IF;

  CLOSE c_number_range_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token('FAILED_PROC','XNP_CORE.GET_NUMBER_RANGE_ID');
      fnd_message.set_token('ATTRNAME','NUMBER_RANGE_ID');
      fnd_message.set_token('KEY','STARTING_NUMBER:ENDING_NUMBER');
      fnd_message.set_token
       ('VALUE'
       ,p_starting_number||':'||p_ending_number
       );
      x_error_message := fnd_message.get;
      x_error_message := x_error_message||':'||SQLERRM;

      fnd_message.set_name('XNP','GET_NUMBER_RANGE_ID_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

      IF c_number_range_id%ISOPEN THEN
       CLOSE c_number_range_id;
      END IF;
  WHEN OTHERS THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.GET_NUMBER_RANGE_ID');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;
      IF c_number_range_id%ISOPEN THEN
       CLOSE c_number_range_id;
      END IF;

END GET_NUMBER_RANGE_ID;


PROCEDURE GET_SMS_SV_ID
 (p_SUBSCRIPTION_TN    VARCHAR2
 ,x_SV_ID          OUT NOCOPY NUMBER
 ,x_ERROR_CODE     OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
 )
IS
 CURSOR c_sms_id IS
  SELECT sv_sms_id
  FROM xnp_sv_sms
  WHERE subscription_tn = p_subscription_tn ;

BEGIN

 x_sv_id         := 0;
 x_error_code    := 0;
 x_error_message := NULL;

 OPEN c_sms_id;
 FETCH c_sms_id INTO x_sv_id;

 IF c_sms_id%NOTFOUND THEN
  raise NO_DATA_FOUND;
 END IF;

 CLOSE c_sms_id;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token('FAILED_PROC','XNP_CORE.GET_SMS_SV_ID');
      fnd_message.set_token('ATTRNAME','SMS SV');
      fnd_message.set_token('KEY','SUBSCRIPTION_TN');
      fnd_message.set_token('VALUE',p_SUBSCRIPTION_TN);
      x_error_message := fnd_message.get;
      x_error_message := x_error_message||':'||SQLERRM;


      fnd_message.set_name('XNP','GET_SMS_SV_ID_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

      IF c_sms_id%ISOPEN THEN
        CLOSE c_sms_id;
      END IF;

  WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.GET_SMS_SV_ID');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_sms_id%ISOPEN THEN
        CLOSE c_sms_id;
      END IF;

END GET_SMS_SV_ID;


PROCEDURE SMS_CREATE_PORTED_NUMBER
 (p_PORTING_ID           IN VARCHAR2
 ,p_STARTING_NUMBER      IN NUMBER
 ,p_ENDING_NUMBER        IN NUMBER
 ,p_SUBSCRIPTION_TYPE    IN VARCHAR2
 ,p_ROUTING_NUMBER_ID    IN NUMBER
 ,p_PORTING_TIME         IN DATE
 ,p_CNAM_ADDRESS            VARCHAR2
 ,p_CNAM_SUBSYSTEM          VARCHAR2
 ,p_ISVM_ADDRESS            VARCHAR2
 ,p_ISVM_SUBSYSTEM          VARCHAR2
 ,p_LIDB_ADDRESS            VARCHAR2
 ,p_LIDB_SUBSYSTEM          VARCHAR2
 ,p_CLASS_ADDRESS           VARCHAR2
 ,p_CLASS_SUBSYSTEM         VARCHAR2
 ,p_WSMSC_ADDRESS           VARCHAR2
 ,p_WSMSC_SUBSYSTEM         VARCHAR2
 ,p_RN_ADDRESS              VARCHAR2
 ,p_RN_SUBSYSTEM            VARCHAR2
 ,p_ORDER_ID             IN NUMBER
 ,p_LINEITEM_ID          IN NUMBER
 ,p_WORKITEM_INSTANCE_ID IN NUMBER
 ,p_FA_INSTANCE_ID       IN NUMBER
 ,x_ERROR_CODE OUT NOCOPY          NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY       VARCHAR2
 )
IS
l_counter   BINARY_INTEGER := 0;
l_diff      NUMBER := (p_ending_number - p_starting_number);
l_init      NUMBER := p_starting_number;
l_geo_id    NUMBER := 0;
l_nrc_id    NUMBER := 0;
l_sv_sms_id NUMBER := null;

  CURSOR c_check_sms_sv_exists (l_ph_no IN VARCHAR2) IS
  SELECT sv_sms_id
    FROM xnp_sv_sms
   WHERE subscription_tn = l_ph_no
     AND subscription_type = p_subscription_type;

BEGIN
  x_error_code := 0;

  -- Get the NRC for the given GEO id

  xnp_core.get_nrc_id
   (p_starting_number
   ,p_ending_number
   ,l_nrc_id
   ,x_error_code
   ,x_error_message
   );

IF x_error_code <> 0 THEN
    RETURN;
END IF;

-- Insert a row into XNP_SV_SMS for each TN in the range
FOR l_counter IN 0..l_diff
  LOOP

   l_sv_sms_id := NULL;

   OPEN c_check_sms_sv_exists(to_char(l_init+l_counter));
   FETCH c_check_sms_sv_exists INTO l_sv_sms_id;

   IF c_check_sms_sv_exists%NOTFOUND THEN

/**
    SELECT xnp_sv_sms_s.nextval
      INTO l_sv_sms_id
      FROM dual;
**/

    INSERT into xnp_sv_sms
    (sv_sms_id ,
     object_reference ,
     routing_number_id ,
     subscription_tn ,
     subscription_type ,
     mediator_sp_id ,
     provision_sent_date ,
     cnam_address ,
     cnam_subsystem ,
     isvm_address ,
     isvm_subsystem ,
     lidb_address ,
     lidb_subsystem ,
     class_address ,
     class_subsystem ,
     wsmsc_address ,
     wsmsc_subsystem ,
     rn_address ,
     rn_subsystem ,
     created_by ,
     creation_date ,
     last_updated_by ,
     last_update_date
    )
    VALUES
    (xnp_sv_sms_s.nextval ,
     p_porting_id ,
     p_routing_number_id ,
     to_char((l_init+l_counter)) ,
     p_subscription_type ,
     l_nrc_id ,
     p_porting_time ,
     p_cnam_address ,
     p_cnam_subsystem ,
     p_isvm_address ,
     p_isvm_subsystem ,
     p_lidb_address ,
     p_lidb_subsystem ,
     p_class_address ,
     p_class_subsystem ,
     p_wsmsc_address ,
     p_wsmsc_subsystem ,
     p_rn_address ,
     p_rn_subsystem ,
     fnd_global.
     user_id ,
     sysdate ,
     fnd_global.user_id ,
     sysdate
    ) RETURNING sv_sms_id INTO l_sv_sms_id ;

   ELSE
    UPDATE xnp_sv_sms
       SET object_reference     = p_porting_id
           ,provision_sent_date = p_porting_time
           ,routing_number_id   = p_routing_number_id
           ,cnam_address        = p_cnam_address
           ,cnam_subsystem      = p_cnam_subsystem
           ,isvm_address        = p_isvm_address
           ,isvm_subsystem      = p_isvm_subsystem
           ,lidb_address        = p_lidb_address
           ,lidb_subsystem      = p_lidb_subsystem
           ,class_address       = p_class_address
           ,class_subsystem     = p_class_subsystem
           ,wsmsc_address       = p_wsmsc_address
           ,wsmsc_subsystem     = p_wsmsc_subsystem
           ,rn_address          = p_rn_address
           ,rn_subsystem        = p_rn_subsystem
           ,last_updated_by     = fnd_global.user_id
           ,last_update_date    = sysdate
     WHERE sv_sms_id            = l_sv_sms_id ;

   END IF;

   -- Call To CREATE_ORDER_MAPPING to create order mapping for the order in xnp_sv_order_mappnings table

   CREATE_ORDER_MAPPING
    (p_ORDER_ID            ,
     p_LINEITEM_ID         ,
     p_WORKITEM_INSTANCE_ID,
     p_FA_INSTANCE_ID      ,
     NULL                  ,
     l_sv_sms_id           ,
     x_ERROR_CODE          ,
     x_ERROR_MESSAGE
    );

   CLOSE c_check_sms_sv_exists;

  END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.SMS_CREATE_PORTED_NUMBER');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_check_sms_sv_exists%ISOPEN THEN
       CLOSE c_check_sms_sv_exists;
      END IF;

END SMS_CREATE_PORTED_NUMBER;


PROCEDURE SOA_UPDATE_CUTOFF_DATE
 (p_STARTING_NUMBER            VARCHAR2
 ,p_ENDING_NUMBER              VARCHAR2
 ,p_CUR_STATUS_TYPE_CODE       VARCHAR2
 ,p_LOCAL_SP_ID                NUMBER DEFAULT NULL
 ,p_OLD_SP_CUTOFF_DUE_DATE     DATE
 ,p_ORDER_ID               IN  NUMBER
 ,p_LINEITEM_ID            IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID   IN  NUMBER
 ,p_FA_INSTANCE_ID         IN  NUMBER
 ,x_ERROR_CODE             OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 )
IS
  l_counter 		BINARY_INTEGER := 0;
  l_sv_id 		NUMBER := 0;
  l_phase_indicator 	VARCHAR2(200) := null;
  l_starting_number 	VARCHAR2(80) := null;
  l_ending_number 	VARCHAR2(80) := null;

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN
  x_error_code := 0;

  l_starting_number := to_char(to_number(p_starting_number));
  l_ending_number   := to_char(to_number(p_ending_number));

  -- Get the phase corresponding to this 'p_cur_status_type_code'

  xnp_core.get_phase_for_status
   (p_cur_status_type_code
   ,l_phase_indicator
   ,x_error_code
   ,x_error_message
   );

  IF x_error_code <> 0  THEN
     RETURN;
  END IF;

   -- For each TN Get the SVid which is in this phase
   -- and update the cutoff date to the
   -- given value

    x_error_code := 0;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa,
                  xnp_sv_status_types_b sta
            WHERE soa.subscription_tn
          BETWEEN l_starting_number AND l_ending_number
              AND sta.phase_indicator  = l_phase_indicator
              AND sta.status_type_code = soa.status_type_code;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.old_sp_cutoff_due_date = p_old_sp_cutoff_due_date,
                         soa.modified_date          = sysdate,
                         soa.last_updated_by        = fnd_global.user_id,
                         soa.last_update_date       = sysdate
                   WHERE soa.sv_soa_id              = l_sv_soa_id(i);

                   -- Call CREATE_ORDER_MAPPING Procedure to create record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)        ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

EXCEPTION

    WHEN OTHERS THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
        ,'XNP_CORE.SOA_UPDATE_CUTOFF_DATE');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

END SOA_UPDATE_CUTOFF_DATE;

PROCEDURE SOA_UPDATE_SV_STATUS
   (p_STARTING_NUMBER          VARCHAR2
   ,p_ENDING_NUMBER            VARCHAR2
   ,p_CUR_STATUS_TYPE_CODE     VARCHAR2
   ,p_LOCAL_SP_ID              NUMBER DEFAULT NULL
   ,p_NEW_STATUS_TYPE_CODE     VARCHAR2
   ,p_STATUS_CHANGE_CAUSE_CODE VARCHAR2
   ,p_ORDER_ID               IN  NUMBER
   ,p_LINEITEM_ID            IN  NUMBER
   ,p_WORKITEM_INSTANCE_ID   IN  NUMBER
   ,p_FA_INSTANCE_ID         IN  NUMBER
   ,x_ERROR_CODE           OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
   )
IS
  l_counter             BINARY_INTEGER := 0;
  l_sv_id               NUMBER :=0;
  l_phase_indicator     VARCHAR2(200) := null;
  l_starting_number     VARCHAR2(80) := null;
  l_ending_number       VARCHAR2(80) := null;

  TYPE sv_soa_id_tab          IS TABLE OF NUMBER;
  TYPE sv_soa_status_tab      IS TABLE OF VARCHAR2(40);
  l_sv_event_code             SV_SOA_STATUS_TAB ;
  l_sv_soa_id                 SV_SOA_ID_TAB;
  i                           BINARY_INTEGER;

BEGIN

  x_error_code := 0;

  l_starting_number := to_char(to_number(p_starting_number));
  l_ending_number   := to_char(to_number(p_ending_number));

  -- Get the phase corresponding to this 'p_cur_status_type_code'

  xnp_core.get_phase_for_status
   (p_cur_status_type_code
   ,l_phase_indicator
   ,x_error_code
   ,x_error_message
   );
  IF x_error_code <> 0 THEN
    RETURN;
  END IF;


   -- For each TN Get the SVid which is in this phase
   -- and update the status  cutoff date to the
   -- given values
   --

            SELECT soa.sv_soa_id,
                   soa.status_type_code  BULK COLLECT
              INTO l_sv_soa_id,
                   l_sv_event_code
              FROM xnp_sv_soa soa,
                   xnp_sv_status_types_b sta
             WHERE SOA.subscription_tn BETWEEN l_starting_number AND l_ending_number
               AND STA.phase_indicator = l_phase_indicator
               AND STA.status_type_code = SOA.status_type_code;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.status_type_code         = p_new_status_type_code  ,
                         soa.status_change_cause_code = p_status_change_cause_code  ,
                         soa.prev_status_type_code    = soa.status_type_code,
                         soa.modified_date            = sysdate,
                         soa.last_updated_by          = fnd_global.user_id,
                         soa.last_update_date         = sysdate
                   WHERE soa.sv_soa_id                = l_sv_soa_id(i)
                     AND soa.status_type_code        <> p_new_status_type_code;

                  -- Create  a history record for the status event change  XNP_SV_EVENT_HISTORY table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  INSERT INTO XNP_SV_EVENT_HISTORY
                         (sv_event_history_id  ,
                          sv_soa_id            ,
                          event_code           ,
                          event_type            ,
                          event_timestamp      ,
                          event_cause_code     ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_EVENT_HISTORY_S.nextval,
                          l_sv_soa_id(i)         ,
                          l_sv_event_code(i)     ,
                          'STATUS_CHANGE'        ,
                          sysdate                ,
                          p_status_change_cause_code,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

                  -- Call CREATE_ORDER_MAPPING Procedure to create record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)         ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );
  EXCEPTION
    WHEN dup_val_on_index THEN
         null;
    WHEN OTHERS THEN
                x_error_code := SQLCODE;
                fnd_message.set_name('XNP','STD_ERROR');
                fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_SV_STATUS');
                fnd_message.set_token('ERROR_TEXT',SQLERRM);
                x_error_message := fnd_message.get;

END SOA_UPDATE_SV_STATUS;

PROCEDURE SOA_CREATE_REC_PORT_ORDER
 (p_PORTING_ID                   VARCHAR2
 ,p_STARTING_NUMBER              NUMBER
 ,p_ENDING_NUMBER                NUMBER
 ,p_SUBSCRIPTION_TYPE            VARCHAR2
 ,p_DONOR_SP_ID                  NUMBER
 ,p_RECIPIENT_SP_ID              NUMBER
 ,p_ROUTING_NUMBER               VARCHAR2
 ,p_NEW_SP_DUE_DATE              DATE
 ,p_OLD_SP_CUTOFF_DUE_DATE       DATE
 ,p_CUSTOMER_ID                  VARCHAR2
 ,p_CUSTOMER_NAME                VARCHAR2
 ,p_CUSTOMER_TYPE                VARCHAR2
 ,p_ADDRESS_LINE1                VARCHAR2
 ,p_ADDRESS_LINE2                VARCHAR2
 ,p_CITY                         VARCHAR2
 ,p_PHONE                        VARCHAR2
 ,p_FAX                          VARCHAR2
 ,p_EMAIL                        VARCHAR2
 ,p_PAGER                        VARCHAR2
 ,p_PAGER_PIN                    VARCHAR2
 ,p_INTERNET_ADDRESS             VARCHAR2
 ,p_ZIP_CODE                     VARCHAR2
 ,p_COUNTRY                      VARCHAR2
 ,p_CUSTOMER_CONTACT_REQ_FLAG    VARCHAR2
 ,p_CONTACT_NAME                 VARCHAR2
 ,p_RETAIN_TN_FLAG               VARCHAR2
 ,p_RETAIN_DIR_INFO_FLAG         VARCHAR2
 ,p_CNAM_ADDRESS                 VARCHAR2
 ,p_CNAM_SUBSYSTEM               VARCHAR2
 ,p_ISVM_ADDRESS                 VARCHAR2
 ,p_ISVM_SUBSYSTEM               VARCHAR2
 ,p_LIDB_ADDRESS                 VARCHAR2
 ,p_LIDB_SUBSYSTEM               VARCHAR2
 ,p_CLASS_ADDRESS                VARCHAR2
 ,p_CLASS_SUBSYSTEM              VARCHAR2
 ,p_WSMSC_ADDRESS                VARCHAR2
 ,p_WSMSC_SUBSYSTEM              VARCHAR2
 ,p_RN_ADDRESS                   VARCHAR2
 ,p_RN_SUBSYSTEM                 VARCHAR2
 ,p_PREORDER_AUTHORIZATION_CODE  VARCHAR2
 ,p_ACTIVATION_DUE_DATE          DATE
 ,p_ORDER_PRIORITY               VARCHAR2
 ,p_SUBSEQUENT_PORT_FLAG         VARCHAR2
 ,p_COMMENTS                     VARCHAR2
 ,p_NOTES                        VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS
  l_counter 	BINARY_INTEGER := 0;
  l_SP_ID 	NUMBER;
  l_diff 	NUMBER := (p_ending_number - p_starting_number);
  l_init 	NUMBER := p_starting_number;
  l_new_status_type_code xnp_sv_status_types_b.STATUS_TYPE_CODE%TYPE;
  l_nrc_id 	NUMBER := 0;
  l_assigned_sp_id NUMBER := 0;
  l_mediator_sp_id NUMBER := 0;
  l_pto_flag 	VARCHAR2(1);
  l_geo_id 	NUMBER := 0;

  l_subscription_tn VARCHAR2(20) := NULL;
  l_sv_soa_id 	    NUMBER := null;
  l_porting_id      VARCHAR2(80) := NULL;
  l_number_range_id NUMBER := null;
  l_routing_number_id NUMBER;

BEGIN
  x_error_code := 0;

   -- verify if its a valid number range
   -- Removed this validation call from XNP_STANDARD.CREATE_PORTING_ORDER and added here spusegao 04/11/2001

  get_number_range_id( p_starting_number => p_starting_number,
                                p_ending_number   => p_ending_number,
                                x_number_range_id => l_number_range_id,
                                x_error_code      => x_error_code,
                                x_error_message   => x_error_message
                                );
  IF (x_error_code <> 0) THEN
        return;
  END IF;

   -- Get the routing_number_id corresponding to the code
   -- Moved this validation call from XNP_STANDARD.CREATE_PORTING_ORDER and added here -- spusegao 04/11/2001

   IF (p_ROUTING_NUMBER IS NOT NULL) THEN

     GET_ROUTING_NUMBER_ID
      (p_routing_number
      ,l_ROUTING_NUMBER_ID
      ,x_ERROR_CODE
      ,x_ERROR_MESSAGE
      );

     IF x_ERROR_CODE <> 0  THEN
       RETURN;
     END IF;

   END IF;

  --
   -- First get the ASSIGNED_SP_ID for that TN Range
   -- Then check if the owning sp id is the same as
   -- the recipient
   --
  l_pto_flag := 'N';  -- Default is 'not PTO'

  xnp_core.get_assigned_sp_id
   (to_char(p_starting_number)
   ,to_char(p_ending_number)
   ,l_assigned_sp_id
   ,x_error_code
   ,x_error_message
   );

  IF x_error_code <> 0  THEN
   RETURN;
  END IF;

  IF l_assigned_sp_id = p_recipient_sp_id  THEN
     l_pto_flag := 'Y';
  END IF;

  -- Get the NRC id

  xnp_core.get_nrc_id
   (to_char(p_starting_number)
   ,to_char(p_ending_number)
   ,l_mediator_sp_id
   ,x_error_code
   ,x_error_message  );

  IF x_error_code <> 0  THEN
   RETURN;
  END IF;


  IF (p_subsequent_port_flag = 'N') AND (l_pto_flag = 'N') THEN
     IF (p_donor_sp_id <> l_assigned_sp_id) THEN
         x_error_code := XNP_ERRORS.G_DONOR_NOT_ASSIGNED_TN;
         fnd_message.set_name('XNP','NUMRANGE_NOT_BELONGING_TO_DON');
         fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_CREATE_REC_PORT_ORDER');
         fnd_message.set_token('SN',to_char(p_STARTING_NUMBER));
         fnd_message.set_token('EN',to_char(p_ENDING_NUMBER));
         fnd_message.set_token('DON',to_char(p_DONOR_SP_ID));
         x_error_message := fnd_message.get;
         RETURN;
     END IF;
  END IF;

  -- Get the initial porting status from the profiles

  l_new_status_type_code := g_default_porting_status;

--  fnd_profile.get
--  (name => 'DEFAULT_PORTING_STATUS'
--  ,val => l_new_status_type_code) ;

  IF (l_new_status_type_code IS null) THEN
      x_error_code := xnp_errors.g_invalid_sv_status;
      fnd_message.set_name('XNP','XNP_CVU_INITIAL_STATUS_OF_SV');
      x_error_message := fnd_message.get;
  END IF;

  FOR l_counter IN   0..l_diff

    LOOP

    l_subscription_tn := to_char(l_init+l_counter);

--    SELECT xnp_sv_soa_s.nextval
--      INTO l_sv_soa_id
--      FROM dual;

     INSERT INTO xnp_sv_soa
      (sv_soa_id
      ,object_reference
      ,subscription_tn
      ,subscription_type
      ,donor_sp_id
      ,recipient_sp_id
      ,routing_number_id
      ,status_type_code
      ,pto_flag
      ,created_by_sp_id
      ,changed_by_sp_id
      ,mediator_sp_id
      ,old_sp_cutoff_due_date
      ,customer_id
      ,customer_name
      ,customer_type
      ,address_line1
      ,address_line2
      ,city
      ,phone
      ,fax
      ,email
      ,zip_code
      ,country
      ,new_sp_due_date
      ,old_sp_due_date
      ,customer_contact_req_flag
      ,contact_name
      ,retain_tn_flag
      ,retain_dir_info_flag
      ,pager
      ,pager_pin
      ,internet_address
      ,cnam_address
      ,cnam_subsystem
      ,isvm_address
      ,isvm_subsystem
      ,lidb_address
      ,lidb_subsystem
      ,class_address
      ,class_subsystem
      ,wsmsc_address
      ,wsmsc_subsystem
      ,rn_address
      ,rn_subsystem
      ,preorder_authorization_code
      ,activation_due_date
      ,order_priority
      ,comments
      ,notes
      ,created_date
      ,modified_date
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      )
      VALUES
      (xnp_sv_soa_s.nextval
      ,p_porting_id -- obj ref
      ,l_subscription_tn           -- subs TN
      ,'NP'			   -- subs type
      ,p_donor_sp_id
      ,p_recipient_sp_id
      ,l_routing_number_id
      ,l_new_status_type_code
      ,l_pto_flag
      ,p_recipient_sp_id
      ,p_recipient_sp_id
      ,l_mediator_sp_id
      ,p_old_sp_cutoff_due_date
      ,p_customer_id
      ,p_customer_name
      ,p_customer_type
      ,p_address_line1
      ,p_address_line2
      ,p_city
      ,p_phone
      ,p_fax
      ,p_email
      ,p_zip_code
      ,p_country
      ,p_new_sp_due_date
      ,p_new_sp_due_date
      ,p_customer_contact_req_flag
      ,p_contact_name
      ,p_retain_tn_flag
      ,p_retain_dir_info_flag
      ,p_pager
      ,p_pager_pin
      ,p_internet_address
      ,p_cnam_address
      ,p_cnam_subsystem
      ,p_isvm_address
      ,p_isvm_subsystem
      ,p_lidb_address
      ,p_lidb_subsystem
      ,p_class_address
      ,p_class_subsystem
      ,p_wsmsc_address
      ,p_wsmsc_subsystem
      ,p_rn_address
      ,p_rn_subsystem
      ,p_preorder_authorization_code
      ,p_activation_due_date
      ,p_order_priority
      ,p_comments
      ,p_notes
      ,sysdate
      ,sysdate
      ,fnd_global.user_id
      ,sysdate
      ,fnd_global.user_id
      ,sysdate
      ) RETURNING sv_soa_id INTO l_sv_soa_id;

      -- Call CREATE_ORDER_MAPPING Procedure to create record in XNP_SV_ORDER_MAPPINGS table

         CREATE_ORDER_MAPPING
          (p_ORDER_ID            ,
           p_LINEITEM_ID         ,
           p_WORKITEM_INSTANCE_ID,
           p_FA_INSTANCE_ID      ,
           l_sv_soa_id           ,
           null                  ,
           x_ERROR_CODE          ,
           x_ERROR_MESSAGE
          );

  END LOOP; -- case of new sp

  EXCEPTION
    WHEN OTHERS THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
        ,'XNP_CORE.SOA_CREATE_REC_PORT_ORDER');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

END SOA_CREATE_REC_PORT_ORDER;

PROCEDURE SOA_CREATE_NRC_PORT_ORDER
(p_PORTING_ID                    VARCHAR2
 ,p_STARTING_NUMBER              NUMBER
 ,p_ENDING_NUMBER                NUMBER
 ,p_SUBSCRIPTION_TYPE            VARCHAR2
 ,p_DONOR_SP_ID                  NUMBER
 ,p_RECIPIENT_SP_ID              NUMBER
 ,p_ROUTING_NUMBER               VARCHAR2
 ,p_NEW_SP_DUE_DATE              DATE
 ,p_OLD_SP_CUTOFF_DUE_DATE       DATE
 ,p_CUSTOMER_ID                  VARCHAR2
 ,p_CUSTOMER_NAME                VARCHAR2
 ,p_CUSTOMER_TYPE                VARCHAR2
 ,p_ADDRESS_LINE1                VARCHAR2
 ,p_ADDRESS_LINE2                VARCHAR2
 ,p_CITY                         VARCHAR2
 ,p_PHONE                        VARCHAR2
 ,p_FAX                          VARCHAR2
 ,p_EMAIL                        VARCHAR2
 ,p_PAGER                        VARCHAR2
 ,p_PAGER_PIN                    VARCHAR2
 ,p_INTERNET_ADDRESS             VARCHAR2
 ,p_ZIP_CODE                     VARCHAR2
 ,p_COUNTRY                      VARCHAR2
 ,p_CUSTOMER_CONTACT_REQ_FLAG    VARCHAR2
 ,p_CONTACT_NAME                 VARCHAR2
 ,p_RETAIN_TN_FLAG               VARCHAR2
 ,p_RETAIN_DIR_INFO_FLAG         VARCHAR2
 ,p_CNAM_ADDRESS                 VARCHAR2
 ,p_CNAM_SUBSYSTEM               VARCHAR2
 ,p_ISVM_ADDRESS                 VARCHAR2
 ,p_ISVM_SUBSYSTEM               VARCHAR2
 ,p_LIDB_ADDRESS                 VARCHAR2
 ,p_LIDB_SUBSYSTEM               VARCHAR2
 ,p_CLASS_ADDRESS                VARCHAR2
 ,p_CLASS_SUBSYSTEM              VARCHAR2
 ,p_WSMSC_ADDRESS                VARCHAR2
 ,p_WSMSC_SUBSYSTEM              VARCHAR2
 ,p_RN_ADDRESS                   VARCHAR2
 ,p_RN_SUBSYSTEM                 VARCHAR2
 ,p_PREORDER_AUTHORIZATION_CODE  VARCHAR2
 ,p_ACTIVATION_DUE_DATE          DATE
 ,p_ORDER_PRIORITY               VARCHAR2
 ,p_SUBSEQUENT_PORT_FLAG         VARCHAR2
 ,p_COMMENTS                     VARCHAR2
 ,p_NOTES                        VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,p_VALIDATION_FLAG          IN  VARCHAR2
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS
  l_counter 	          BINARY_INTEGER := 0;
  l_sp_id 	          NUMBER;
  l_diff 	          NUMBER := (p_ending_number - p_starting_number);
  l_init 	          NUMBER := p_starting_number;
  l_new_status_type_code xnp_sv_status_types_b.STATUS_TYPE_CODE%TYPE;
  l_nrc_id 	          NUMBER := 0;
  l_assigned_sp_id        NUMBER := 0;
  l_mediator_sp_id        NUMBER := 0;
  l_pto_flag 	          VARCHAR2(1);
  l_geo_id	          NUMBER := 0;

  l_subscription_tn   VARCHAR2(20) := null;
  l_sv_soa_id 	      NUMBER := null;
  l_porting_id 	      VARCHAR2(80) := null;
  l_number_range_id   NUMBER  := null;
  l_routing_number_id NUMBER;

  CURSOR c_routing_id_exists (l_routing_number IN NUMBER,
                              l_sp_id          IN NUMBER) IS
    SELECT  routing_number_id
      FROM  xnp_routing_numbers
     WHERE  routing_number    = l_routing_number
       AND  sp_id             = l_sp_id
       AND  interconnect_type = 'LRN' ;

BEGIN

  x_error_code := 0;

  IF p_VALIDATION_FLAG = 'Y' THEN


        -- verify if its a valid number range
        -- Moved this validation call from XNP_STANDARD.CREATE_PORTING_ORDER and added here spusegao 04/11/2001

       get_number_range_id( p_starting_number => p_starting_number,
                            p_ending_number   => p_ending_number,
                            x_number_range_id => l_number_range_id,
                            x_error_code      => x_error_code,
                            x_error_message   => x_error_message
                           );

       IF (x_error_code <> 0) THEN
             return;
       END IF;

        -- Get the routing_number_id corresponding to the code
        -- Moved this validation call from XNP_STANDARD.CREATE_PORTING_ORDER and added here -- spusegao 04/11/2001

        IF (p_ROUTING_NUMBER IS NOT NULL) THEN

          GET_ROUTING_NUMBER_ID
           (p_ROUTING_NUMBER
           ,l_ROUTING_NUMBER_ID
           ,x_ERROR_CODE
           ,x_ERROR_MESSAGE
           );

          IF x_ERROR_CODE <> 0  THEN
            RETURN;
          END IF;

        END IF;

        --
        -- First get the ASSIGNED_SP_ID for that TN Range
        -- Then check if the owning sp id is the same as
        -- the recipient
        --
       l_pto_flag := 'N';  -- Default is 'not PTO'

       xnp_core.get_assigned_sp_id
        (to_char(p_starting_number)
        ,to_char(p_ending_number)
        ,l_assigned_sp_id
        ,x_error_code
        ,x_error_message
        );

       IF x_error_code <> 0  THEN
          RETURN;
       END IF;

       IF l_assigned_sp_id = p_recipient_sp_id  THEN
          l_pto_flag := 'Y';
       END IF;

       -- Get the NRC id

       xnp_core.get_nrc_id
        (to_char(p_starting_number)
        ,to_char(p_ending_number)
        ,l_mediator_sp_id
        ,x_error_code
        ,x_error_message
        );

       IF x_error_code <> 0  THEN
          RETURN;
       END IF;



       IF (p_subsequent_port_flag = 'N') AND (l_pto_flag = 'N') THEN

          IF (p_donor_sp_id <> l_assigned_sp_id) THEN
             x_error_code := XNP_ERRORS.G_DONOR_NOT_ASSIGNED_TN;
             fnd_message.set_name('XNP','NUMRANGE_NOT_BELONGING_TO_DON');
             fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_CREATE_NRC_PORT_ORDER');
             fnd_message.set_token('SN',to_char(p_STARTING_NUMBER));
             fnd_message.set_token('EN',to_char(p_ENDING_NUMBER));
             fnd_message.set_token('DON',to_char(p_DONOR_SP_ID));

             x_error_message := fnd_message.get;
             RETURN;
          END IF;
       END IF;

  ELSE

       l_pto_flag := 'N';  -- Default is 'not PTO'

        IF (p_ROUTING_NUMBER IS NOT NULL) THEN

           OPEN c_routing_id_exists (p_routing_number , p_recipient_sp_id )  ;
           FETCH c_routing_id_exists INTO l_routing_number_id ;

            IF c_routing_id_exists%NOTFOUND THEN

              -- Create a routing record in the XNP_ROUTING_NUMBERS table

                  INSERT INTO XNP_ROUTING_NUMBERS
                        (
                         ROUTING_NUMBER_ID ,
                         OBJECT_REFERENCE  ,
                         INTERCONNECT_TYPE ,
                         SP_ID             ,
                         ROUTING_NUMBER    ,
                         ACTIVE_FLAG       ,
                         STATUS            ,
                         CREATED_BY        ,
                         CREATION_DATE     ,
                         LAST_UPDATED_BY   ,
                         LAST_UPDATE_DATE  ,
                         LAST_UPDATE_LOGIN
                        )
                        VALUES
                        (
                         XNP_ROUTING_NUMBERS_S.nextval ,
                         p_RECIPIENT_SP_ID||'-'||p_ROUTING_NUMBER||'-'||'LRN',
                         'LRN' ,
                         p_RECIPIENT_SP_ID ,
                         p_ROUTING_NUMBER    ,
                         'Y'       ,
                         null            ,
                         fnd_global.user_id        ,
                         sysdate     ,
                         fnd_global.user_id   ,
                         sysdate  ,
                         fnd_global.user_id
                        ) RETURNING routing_number_id INTO l_routing_number_id ;
            END IF;

           CLOSE c_routing_id_exists ;

        END IF;

  END IF;

  -- Get the initial porting status from the profiles

  l_new_status_type_code := g_default_porting_status;

---  fnd_profile.get
---  (name => 'DEFAULT_PORTING_STATUS'
---  ,val => l_new_status_type_code) ;

  IF (l_new_status_type_code IS null) THEN
      x_error_code := xnp_errors.g_invalid_sv_status;
      fnd_message.set_name('XNP','XNP_CVU_INITIAL_STATUS_OF_SV');
      x_error_message := fnd_message.get;
  END IF;


  FOR l_counter IN   0..l_diff
    LOOP

    l_subscription_tn := to_char(l_init+l_counter);

---    SELECT xnp_sv_soa_s.nextval
---      INTO l_sv_soa_id
---      FROM dual;

     INSERT INTO XNP_SV_SOA
      (sv_soa_id
      ,object_reference
      ,subscription_tn
      ,subscription_type
      ,donor_sp_id
      ,recipient_sp_id
      ,routing_number_id
      ,status_type_code
      ,pto_flag
      ,created_by_sp_id
      ,changed_by_sp_id
      ,mediator_sp_id
      ,old_sp_cutoff_due_date
      ,customer_id
      ,customer_name
      ,customer_type
      ,address_line1
      ,address_line2
      ,city
      ,phone
      ,fax
      ,email
      ,zip_code
      ,country
      ,new_sp_due_date
      ,old_sp_due_date
      ,customer_contact_req_flag
      ,contact_name
      ,retain_tn_flag
      ,retain_dir_info_flag
      ,pager
      ,pager_pin
      ,internet_address
      ,cnam_address
      ,cnam_subsystem
      ,isvm_address
      ,isvm_subsystem
      ,lidb_address
      ,lidb_subsystem
      ,class_address
      ,class_subsystem
      ,wsmsc_address
      ,wsmsc_subsystem
      ,rn_address
      ,rn_subsystem
      ,preorder_authorization_code
      ,activation_due_date
      ,order_priority
      ,comments
      ,notes
      ,created_date
      ,modified_date
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      )
      VALUES
      (xnp_sv_soa_s.nextval
      ,p_porting_id -- obj ref
      ,l_subscription_tn           -- subs TN
      ,'NP'			   -- subs type
      ,p_donor_sp_id
      ,p_recipient_sp_id
      ,l_routing_number_id
      ,l_new_status_type_code
      ,l_pto_flag
      ,l_mediator_sp_id
      ,p_recipient_sp_id
      ,l_mediator_sp_id
      ,p_old_sp_cutoff_due_date
      ,p_customer_id
      ,p_customer_name
      ,p_customer_type
      ,p_address_line1
      ,p_address_line2
      ,p_city
      ,p_phone
      ,p_fax
      ,p_email
      ,p_zip_code
      ,p_country
      ,p_new_sp_due_date
      ,p_new_sp_due_date
      ,p_customer_contact_req_flag
      ,p_contact_name
      ,p_retain_tn_flag
      ,p_retain_dir_info_flag
      ,p_pager
      ,p_pager_pin
      ,p_internet_address
      ,p_cnam_address
      ,p_cnam_subsystem
      ,p_isvm_address
      ,p_isvm_subsystem
      ,p_lidb_address
      ,p_lidb_subsystem
      ,p_class_address
      ,p_class_subsystem
      ,p_wsmsc_address
      ,p_wsmsc_subsystem
      ,p_rn_address
      ,p_rn_subsystem
      ,p_preorder_authorization_code
      ,p_activation_due_date
      ,p_order_priority
      ,p_comments
      ,p_notes
      ,sysdate
      ,sysdate
      ,fnd_global.user_id
      ,sysdate
      ,fnd_global.user_id
      ,sysdate
      ) RETURNING sv_soa_id INTO l_sv_soa_id;


      -- Call CREATE_ORDER_MAPPING Procedure to create record in XNP_SV_ORDER_MAPPINGS table

         CREATE_ORDER_MAPPING
          (p_ORDER_ID            ,
           p_LINEITEM_ID         ,
           p_WORKITEM_INSTANCE_ID,
           p_FA_INSTANCE_ID      ,
           l_sv_soa_id           ,
           null                  ,
           x_ERROR_CODE          ,
           x_ERROR_MESSAGE
          );

  END LOOP; -- case of new sp

  EXCEPTION
    WHEN OTHERS THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
        ,'XNP_CORE.SOA_CREATE_NRC_PORT_ORDER');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

END SOA_CREATE_NRC_PORT_ORDER;

PROCEDURE SOA_CREATE_DON_PORT_ORDER
 (p_PORTING_ID                   VARCHAR2
 ,p_STARTING_NUMBER              NUMBER
 ,p_ENDING_NUMBER                NUMBER
 ,p_SUBSCRIPTION_TYPE            VARCHAR2
 ,p_DONOR_SP_ID                  NUMBER
 ,p_RECIPIENT_SP_ID              NUMBER
 ,p_ROUTING_NUMBER               VARCHAR2
 ,p_NEW_SP_DUE_DATE              DATE
 ,p_OLD_SP_CUTOFF_DUE_DATE       DATE
 ,p_CUSTOMER_ID                  VARCHAR2
 ,p_CUSTOMER_NAME                VARCHAR2
 ,p_CUSTOMER_TYPE                VARCHAR2
 ,p_ADDRESS_LINE1                VARCHAR2
 ,p_ADDRESS_LINE2                VARCHAR2
 ,p_CITY                         VARCHAR2
 ,p_PHONE                        VARCHAR2
 ,p_FAX                          VARCHAR2
 ,p_EMAIL                        VARCHAR2
 ,p_PAGER                        VARCHAR2
 ,p_PAGER_PIN                    VARCHAR2
 ,p_INTERNET_ADDRESS             VARCHAR2
 ,p_ZIP_CODE                     VARCHAR2
 ,p_COUNTRY                      VARCHAR2
 ,p_CUSTOMER_CONTACT_REQ_FLAG    VARCHAR2
 ,p_CONTACT_NAME                 VARCHAR2
 ,p_RETAIN_TN_FLAG               VARCHAR2
 ,p_RETAIN_DIR_INFO_FLAG         VARCHAR2
 ,p_CNAM_ADDRESS                 VARCHAR2
 ,p_CNAM_SUBSYSTEM               VARCHAR2
 ,p_ISVM_ADDRESS                 VARCHAR2
 ,p_ISVM_SUBSYSTEM               VARCHAR2
 ,p_LIDB_ADDRESS                 VARCHAR2
 ,p_LIDB_SUBSYSTEM               VARCHAR2
 ,p_CLASS_ADDRESS                VARCHAR2
 ,p_CLASS_SUBSYSTEM              VARCHAR2
 ,p_WSMSC_ADDRESS                VARCHAR2
 ,p_WSMSC_SUBSYSTEM              VARCHAR2
 ,p_RN_ADDRESS                   VARCHAR2
 ,p_RN_SUBSYSTEM                 VARCHAR2
 ,p_PREORDER_AUTHORIZATION_CODE  VARCHAR2
 ,p_ACTIVATION_DUE_DATE          DATE
 ,p_ORDER_PRIORITY               VARCHAR2
 ,p_SUBSEQUENT_PORT_FLAG         VARCHAR2
 ,p_COMMENTS                     VARCHAR2
 ,p_NOTES                        VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE OUT NOCOPY               NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY            VARCHAR2
 )
IS
  l_counter         BINARY_INTEGER;
  l_SP_ID           NUMBER;
  l_diff            NUMBER := (p_ENDING_NUMBER - p_STARTING_NUMBER);
  l_init            NUMBER := p_STARTING_NUMBER;
  l_NEW_STATUS_TYPE_CODE xnp_sv_status_types_b.STATUS_TYPE_CODE%TYPE;
  l_NRC_ID          NUMBER := 0;
  l_ASSIGNED_SP_ID  NUMBER := 0;
  l_MEDIATOR_SP_ID  NUMBER := 0;
  l_PTO_FLAG        VARCHAR2(1);
  l_GEO_ID          NUMBER := 0;

  l_PORTING_ID      VARCHAR2(80) := NULL;
  l_SUBSCRIPTION_TN VARCHAR2(20) := NULL;
  l_sv_soa_id       NUMBER := null;
  l_number_range_id   NUMBER := null;
  l_routing_number_id NUMBER;

BEGIN

  x_ERROR_CODE := 0;


   -- verify if its a valid number range
   -- Moved this validation call from XNP_STANDARD.CREATE_PORTING_ORDER and added here -- spusegao 04/11/2001

  get_number_range_id( p_starting_number => p_starting_number,
                                p_ending_number   => p_ending_number,
                                x_number_range_id => l_number_range_id,
                                x_error_code      => x_error_code,
                                x_error_message   => x_error_message
                                );
  IF (x_error_code <> 0) THEN
        return;
  END IF;

   -- Get the routing_number_id corresponding to the code
   -- Moved this validation call from XNP_STANDARD.CREATE_PORTING_ORDER and added here -- spusegao 04/11/2001

   IF (p_ROUTING_NUMBER IS NOT NULL) THEN

     GET_ROUTING_NUMBER_ID
      (p_routing_number
      ,l_ROUTING_NUMBER_ID
      ,x_ERROR_CODE
      ,x_ERROR_MESSAGE
      );

     IF x_ERROR_CODE <> 0  THEN
       RETURN;
     END IF;

   END IF;


  -- Get the initial porting status from the profiles

l_new_status_type_code  := g_default_porting_status;

/***
  FND_PROFILE.GET
  (NAME => 'DEFAULT_PORTING_STATUS'
  ,VAL => l_new_status_type_code) ;
***/

  IF (l_new_status_type_code IS null) THEN
      x_error_code := xnp_errors.g_invalid_sv_status;
      fnd_message.set_name('XNP','XNP_CVU_INITIAL_STATUS_OF_SV');
      x_error_message := fnd_message.get;
  END IF;


  --
   -- First get the ASSIGNED_SP_ID for that TN Range
   -- Then check if the owning sp id is the same as
   -- the recipient
   --
  l_PTO_FLAG := 'N';  -- Default is 'not PTO'

  XNP_CORE.GET_ASSIGNED_SP_ID
   (to_char(p_starting_number)
   ,to_char(p_ending_number)
   ,l_ASSIGNED_SP_ID
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );
  IF x_ERROR_CODE <> 0
  THEN
   RETURN;
  END IF;

  IF l_ASSIGNED_SP_ID = p_RECIPIENT_SP_ID
  THEN
     l_PTO_FLAG := 'Y';
  END IF;

  -- Get the NRC id

  XNP_CORE.GET_NRC_ID
   (to_char(p_STARTING_NUMBER)
   ,to_char(p_ENDING_NUMBER)
   ,l_MEDIATOR_SP_ID
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );
  IF x_ERROR_CODE <> 0
  THEN
   RETURN;
  END IF;


  IF (p_SUBSEQUENT_PORT_FLAG = 'N') AND (l_PTO_FLAG = 'N') THEN
     IF (p_DONOR_SP_ID <> l_ASSIGNED_SP_ID) THEN
      x_ERROR_CODE := XNP_ERRORS.G_DONOR_NOT_ASSIGNED_TN;

      fnd_message.set_name('XNP','NUMRANGE_NOT_BELONGING_TO_DON');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.SOA_CREATE_DON_PORT_ORDER');
      fnd_message.set_token('SN',to_char(p_STARTING_NUMBER));
      fnd_message.set_token('EN',to_char(p_ENDING_NUMBER));
      fnd_message.set_token('DON',to_char(p_DONOR_SP_ID));

      x_error_message := fnd_message.get;
      RETURN;
     END IF;
  END IF;

  FOR l_counter IN
      0..l_diff
    LOOP

    l_SUBSCRIPTION_TN := to_char(l_init+l_counter);

/***
    SELECT xnp_sv_soa_s.nextval
      INTO l_sv_soa_id
      FROM dual;
***/

     INSERT INTO XNP_SV_SOA
      (SV_SOA_ID
      ,OBJECT_REFERENCE
      ,SUBSCRIPTION_TN
      ,SUBSCRIPTION_TYPE
      ,DONOR_SP_ID
      ,RECIPIENT_SP_ID
      ,ROUTING_NUMBER_ID
      ,STATUS_TYPE_CODE
      ,PTO_FLAG
      ,CREATED_BY_SP_ID
      ,CHANGED_BY_SP_ID
      ,MEDIATOR_SP_ID
      ,NEW_SP_DUE_DATE
      ,OLD_SP_DUE_DATE
      ,OLD_SP_CUTOFF_DUE_DATE
      ,CUSTOMER_ID
      ,CUSTOMER_NAME
      ,CUSTOMER_TYPE
      ,ADDRESS_LINE1
      ,ADDRESS_LINE2
      ,CITY
      ,PHONE
      ,FAX
      ,EMAIL
      ,ZIP_CODE
      ,COUNTRY
      ,CUSTOMER_CONTACT_REQ_FLAG
      ,CONTACT_NAME
      ,RETAIN_TN_FLAG
      ,RETAIN_DIR_INFO_FLAG
      ,PAGER
      ,PAGER_PIN
      ,INTERNET_ADDRESS
      ,CNAM_ADDRESS
      ,CNAM_SUBSYSTEM
      ,ISVM_ADDRESS
      ,ISVM_SUBSYSTEM
      ,LIDB_ADDRESS
      ,LIDB_SUBSYSTEM
      ,CLASS_ADDRESS
      ,CLASS_SUBSYSTEM
      ,WSMSC_ADDRESS
      ,WSMSC_SUBSYSTEM
      ,RN_ADDRESS
      ,RN_SUBSYSTEM
      ,PREORDER_AUTHORIZATION_CODE
      ,ACTIVATION_DUE_DATE
      ,ORDER_PRIORITY
      ,COMMENTS
      ,NOTES
      ,CREATED_DATE
      ,MODIFIED_DATE
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
      )
      VALUES
      (xnp_sv_soa_s.nextval
      ,p_PORTING_ID
      ,l_SUBSCRIPTION_TN   -- telephone number
      ,'NP'	           -- subs type
      ,p_DONOR_SP_ID
      ,p_RECIPIENT_SP_ID
      ,l_ROUTING_NUMBER_ID
      ,l_NEW_STATUS_TYPE_CODE
      ,l_PTO_FLAG
      ,p_DONOR_SP_ID
      ,p_DONOR_SP_ID
      ,l_MEDIATOR_SP_ID
      ,p_NEW_SP_DUE_DATE
      ,p_NEW_SP_DUE_DATE
      ,p_OLD_SP_CUTOFF_DUE_DATE
      ,p_CUSTOMER_ID
      ,p_CUSTOMER_NAME
      ,p_CUSTOMER_TYPE
      ,p_ADDRESS_LINE1
      ,p_ADDRESS_LINE2
      ,p_CITY
      ,p_PHONE
      ,p_FAX
      ,p_EMAIL
      ,p_ZIP_CODE
      ,p_COUNTRY
      ,p_CUSTOMER_CONTACT_REQ_FLAG
      ,p_CONTACT_NAME
      ,p_RETAIN_TN_FLAG
      ,p_RETAIN_DIR_INFO_FLAG
      ,p_PAGER
      ,p_PAGER_PIN
      ,p_INTERNET_ADDRESS
      ,p_CNAM_ADDRESS
      ,p_CNAM_SUBSYSTEM
      ,p_ISVM_ADDRESS
      ,p_ISVM_SUBSYSTEM
      ,p_LIDB_ADDRESS
      ,p_LIDB_SUBSYSTEM
      ,p_CLASS_ADDRESS
      ,p_CLASS_SUBSYSTEM
      ,p_WSMSC_ADDRESS
      ,p_WSMSC_SUBSYSTEM
      ,p_RN_ADDRESS
      ,p_RN_SUBSYSTEM
      ,p_PREORDER_AUTHORIZATION_CODE
      ,p_ACTIVATION_DUE_DATE
      ,p_ORDER_PRIORITY
      ,p_COMMENTS
      ,p_NOTES
      ,SYSDATE
      ,SYSDATE
      ,FND_GLOBAL.USER_ID
      ,SYSDATE
      ,FND_GLOBAL.USER_ID
      ,SYSDATE
      ) RETURNING sv_soa_id INTO l_sv_soa_id;


      -- Call CREATE_ORDER_MAPPING Procedure to create record in XNP_SV_ORDER_MAPPINGS table

         CREATE_ORDER_MAPPING
          (p_ORDER_ID            ,
           p_LINEITEM_ID         ,
           p_WORKITEM_INSTANCE_ID,
           p_FA_INSTANCE_ID      ,
           l_sv_soa_id           ,
           null                  ,
           x_ERROR_CODE          ,
           x_ERROR_MESSAGE
          );

  END LOOP; -- case of new sp

  EXCEPTION
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.SOA_CREATE_DON_PORT_ORDER');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

END SOA_CREATE_DON_PORT_ORDER;

PROCEDURE SOA_CHECK_NOTIFY_DIR_SVS
 (p_PORTING_ID        VARCHAR2
 ,p_LOCAL_SP_ID       NUMBER DEFAULT NULL
 ,x_CHECK_STATUS  OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE    OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 )
IS

l_RETAIN_DIR_INFO VARCHAR2(1);

CURSOR c_CHECK_STATUS IS
  SELECT retain_dir_info_flag
  FROM xnp_sv_soa
  WHERE object_reference=p_porting_id;

BEGIN
  x_ERROR_CODE := 0;

 OPEN c_CHECK_STATUS;
 FETCH c_CHECK_STATUS INTO x_CHECK_STATUS;

 IF c_CHECK_STATUS%NOTFOUND THEN
  raise NO_DATA_FOUND;
 END IF;

 CLOSE c_CHECK_STATUS;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token('FAILED_PROC','XNP_CORE.SOA_CHECK_NOTIFY_DIR_SVS');
      fnd_message.set_token('ATTRNAME','RETAIN_DIR_INFO_FLAG');
      fnd_message.set_token('KEY','PORTING_ID');
      fnd_message.set_token('VALUE',p_PORTING_ID);
      x_error_message :=
       fnd_message.get;
      x_ERROR_MESSAGE := x_error_message||':'||SQLERRM;

      fnd_message.set_name('XNP','NOTIFY_DIR_SVS_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

      IF c_CHECK_STATUS%ISOPEN THEN
        CLOSE c_CHECK_STATUS;
      END IF;

    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
        ,'XNP_CORE.SOA_CHECK_NOTIFY_DIR_SVS');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_CHECK_STATUS%ISOPEN THEN
        CLOSE c_CHECK_STATUS;
      END IF;

END SOA_CHECK_NOTIFY_DIR_SVS ;


PROCEDURE SOA_CHECK_IF_INITIAL_DONOR
 (p_DONOR_SP_ID        NUMBER
 ,p_STARTING_NUMBER    VARCHAR2
 ,p_ENDING_NUMBER      VARCHAR2
 ,x_CHECK_STATUS   OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE     OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
 )
IS
l_SERVING_SP_ID NUMBER;
BEGIN
  x_ERROR_CODE    := 0;
  x_ERROR_MESSAGE := NULL;
  x_CHECK_STATUS  := 'N';


  XNP_CORE.GET_ASSIGNED_SP_ID
   (p_STARTING_NUMBER
   ,p_ENDING_NUMBER
   ,l_SERVING_SP_ID
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );

  IF x_ERROR_CODE <> 0  THEN
    RETURN;
  END IF;

  IF l_SERVING_SP_ID = p_DONOR_SP_ID  THEN
    x_CHECK_STATUS := 'Y';
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.SOA_CHECK_IF_INITIAL_DONOR');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

END SOA_CHECK_IF_INITIAL_DONOR;

PROCEDURE SOA_UPDATE_CHARGING_INFO
 (p_STARTING_NUMBER           VARCHAR2
 ,p_ENDING_NUMBER             VARCHAR2
 ,p_CUR_STATUS_TYPE_CODE      VARCHAR2
 ,p_LOCAL_SP_ID               NUMBER DEFAULT NULL
 ,p_INVOICE_DUE_DATE          DATE
 ,p_CHARGING_INFO             VARCHAR2
 ,p_BILLING_ID                NUMBER
 ,p_USER_LOCTN_VALUE          VARCHAR2
 ,p_USER_LOCTN_TYPE           VARCHAR2
 ,p_ORDER_ID              IN  NUMBER
 ,p_LINEITEM_ID           IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID  IN  NUMBER
 ,p_FA_INSTANCE_ID        IN  NUMBER
 ,x_ERROR_CODE            OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE         OUT NOCOPY VARCHAR2
 )
IS
  l_counter           BINARY_INTEGER := 0;
  l_SV_ID             XNP_SV_SOA.SV_SOA_ID%TYPE;
  l_PHASE_INDICATOR   XNP_SV_STATUS_TYPES_B.PHASE_INDICATOR%TYPE;
  l_STARTING_NUMBER   VARCHAR2(80) := null;
  l_ENDING_NUMBER     VARCHAR2(80) := null;

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN

  x_ERROR_CODE := 0;


  l_starting_number := to_char(to_number(p_starting_number));
  l_ending_number   := to_char(to_number(p_ending_number));

  -- Get the phase corresponding to this 'p_CUR_STATUS_TYPE_CODE'

  XNP_CORE.GET_PHASE_FOR_STATUS
   (p_CUR_STATUS_TYPE_CODE
   ,l_PHASE_INDICATOR
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );

  IF x_ERROR_CODE <> 0  THEN
     RETURN;
  END IF;

  --
   -- For each TN Get the SVid which is in this phase
   -- and update the invoice info to the
   -- given value
   --

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa,
                  xnp_sv_status_types_b sta
            WHERE soa.subscription_tn   BETWEEN l_starting_number AND l_ending_number
              AND sta.phase_indicator  = l_phase_indicator
              AND sta.status_type_code = soa.status_type_code;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.invoice_due_date = p_invoice_due_date,
                         soa.charging_info    = p_charging_info,
                         soa.user_loctn_type  = p_user_loctn_type,
                         soa.user_loctn_value = p_user_loctn_value,
                         soa.modified_date    = sysdate,
                         soa.last_updated_by  = fnd_global.user_id,
                         soa.last_update_date = sysdate
                   WHERE soa.sv_soa_id        = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
    WHEN dup_val_on_index THEN
         null;
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_CHARGING_INFO');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','UPD_CHARGING_INFO_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

END SOA_UPDATE_CHARGING_INFO;

PROCEDURE SMS_INSERT_FE_MAP
 (p_STARTING_NUMBER          NUMBER
 ,p_ENDING_NUMBER            NUMBER
 ,p_FE_ID                    NUMBER
 ,p_FEATURE_TYPE             VARCHAR2
 ,p_ORDER_ID             IN  NUMBER
 ,p_LINEITEM_ID          IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID IN  NUMBER
 ,p_FA_INSTANCE_ID       IN  NUMBER
 ,x_ERROR_CODE           OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 )
IS
  l_SV_ID         NUMBER := 0;
  l_counter       NUMBER := 0;
  l_diff          NUMBER := (p_ENDING_NUMBER - p_STARTING_NUMBER);
  l_init          NUMBER := p_STARTING_NUMBER;
  l_sms_fe_map_id NUMBER := null;

 CURSOR c_CHECK_IF_MAP_EXISTS (l_cur_sv_id IN NUMBER) IS
  SELECT sms_fe_map_id
    FROM xnp_sv_sms_fe_maps
   WHERE sv_sms_id    = l_cur_sv_id
     AND fe_id        = p_fe_id
     AND feature_type = p_feature_type;

BEGIN
  x_ERROR_CODE := 0;

  -- For each TN Get the SVid in the SMS table

  FOR l_counter IN
    0..l_diff
   LOOP

     XNP_CORE.GET_SMS_SV_ID
      (to_char(l_init+l_counter)
      ,l_SV_ID
      ,x_ERROR_CODE
      ,x_ERROR_MESSAGE
      );

     IF x_ERROR_CODE <> 0 THEN
       RETURN;
     END IF;

     IF l_sv_id IS NOT NULL  THEN

      -- Call CREATE_ORDER_MAPPING Procedure to create record in XNP_SV_ORDER_MAPPINGS table

         CREATE_ORDER_MAPPING
          (p_ORDER_ID            ,
           p_LINEITEM_ID         ,
           p_WORKITEM_INSTANCE_ID,
           p_FA_INSTANCE_ID      ,
           null                  ,
           l_sv_id               ,
           x_ERROR_CODE          ,
           x_ERROR_MESSAGE
          );

     END IF;

     l_sms_fe_map_id := NULL;

     OPEN c_CHECK_IF_MAP_EXISTS(l_sv_id);
     FETCH c_CHECK_IF_MAP_EXISTS INTO l_sms_fe_map_id;

     IF c_CHECK_IF_MAP_EXISTS%NOTFOUND THEN
/***
       SELECT xnp_sv_sms_fe_maps_s.nextval
         INTO l_sms_fe_map_id
         FROM dual;
***/

       INSERT INTO xnp_sv_sms_fe_maps
        (SMS_FE_MAP_ID
        ,SV_SMS_ID
        ,FE_ID
        ,FEATURE_TYPE
        ,PROVISION_STATUS
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        )
       VALUES (
        xnp_sv_sms_fe_maps_s.nextval
        ,l_SV_ID
        ,p_FE_ID
        ,p_FEATURE_TYPE
        ,'NOT_PROVISIONED'
        ,fnd_global.user_id
        ,sysdate
        ,fnd_global.user_id
        ,sysdate
        );

     ELSE

        UPDATE xnp_sv_sms_fe_maps
           SET provision_status = 'NOT_PROVISIONED' ,
               last_updated_by  = fnd_global.user_id ,
               last_update_date = sysdate
         WHERE sms_fe_map_id    = l_sms_fe_map_id;

     END IF;

     CLOSE c_CHECK_IF_MAP_EXISTS;

   END LOOP;

  EXCEPTION
       WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.SMS_INSERT_FE_MAP');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_CHECK_IF_MAP_EXISTS%ISOPEN THEN
       CLOSE c_CHECK_IF_MAP_EXISTS;
      END IF;

END SMS_INSERT_FE_MAP;

PROCEDURE SOA_UPDATE_SV_STATUS
   (p_PORTING_ID                   VARCHAR2
   ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
   ,p_NEW_STATUS_TYPE_CODE         VARCHAR2
   ,p_STATUS_CHANGE_CAUSE_CODE     VARCHAR2
   ,p_ORDER_ID                 IN  NUMBER
   ,p_LINEITEM_ID              IN  NUMBER
   ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
   ,p_FA_INSTANCE_ID           IN  NUMBER
   ,x_ERROR_CODE               OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
   )
IS

  TYPE sv_soa_id_tab IS       TABLE OF NUMBER;
  TYPE sv_soa_status_tab      IS TABLE OF VARCHAR2(40);
  l_sv_event_code             SV_SOA_STATUS_TAB ;
  l_sv_soa_id                 SV_SOA_ID_TAB;
  i                           BINARY_INTEGER;

BEGIN
  x_ERROR_CODE := 0;

  -- Get the current status of the SOA and
   -- call SOA_UPDATE_SV_STATUS with that value
   --
           SELECT soa.sv_soa_id,
                  soa.status_type_code  BULK COLLECT
             INTO l_sv_soa_id,
                  l_sv_event_code
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id ;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.status_type_code         = p_new_status_type_code  ,
                         soa.status_change_cause_code = p_status_change_cause_code  ,
                         soa.prev_status_type_code    = soa.status_type_code,
                         soa.modified_date            = sysdate,
                         soa.last_updated_by          = fnd_global.user_id,
                         soa.last_update_date         = sysdate
                   WHERE soa.sv_soa_id                = l_sv_soa_id(i)
                     AND soa.status_type_code        <> p_new_status_type_code;

                  -- Create a history  record for the status change event  in XNP_SV_EVENT_HISTORY table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  INSERT INTO XNP_SV_EVENT_HISTORY
                         (sv_event_history_id  ,
                          sv_soa_id            ,
                          event_code           ,
                          event_type            ,
                          event_timestamp      ,
                          event_cause_code     ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_EVENT_HISTORY_S.nextval,
                          l_sv_soa_id(i)         ,
                          l_sv_event_code(i)     ,
                          'STATUS_CHANGE'        ,
                          sysdate                ,
                          p_status_change_cause_code,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
       WHEN dup_val_on_index THEN
            null;
       WHEN NO_DATA_FOUND THEN
            x_ERROR_CODE := SQLCODE;
            fnd_message.set_name('XNP','STD_GET_FAILED');
            fnd_message.set_token ('FAILED_PROC','XNP_CORE.SOA_UPDATE_SV_STATUS');
            fnd_message.set_token('KEY','OBJECT_REFERENCE');
            fnd_message.set_token('VALUE',p_PORTING_ID);
            fnd_message.set_token('ATTRNAME','STATUS_TYPE_CODE');
            x_error_message := fnd_message.get;
            x_ERROR_MESSAGE := x_error_message||':'||SQLERRM;

            fnd_message.set_name('XNP','UPD_SV_STATUS_ERR');
            fnd_message.set_token('ERROR_TEXT',x_error_message);
            x_error_message := fnd_message.get;

            RETURN;

       WHEN OTHERS THEN
            x_ERROR_CODE := SQLCODE;
            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_SV_STATUS');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

END SOA_UPDATE_SV_STATUS;

PROCEDURE CHECK_SOA_STATUS_EXISTS
   (p_STARTING_NUMBER     VARCHAR2
   ,p_ENDING_NUMBER       VARCHAR2
   ,p_STATUS_TYPE_CODE    VARCHAR2
   ,p_LOCAL_SP_ID         NUMBER DEFAULT NULL
   ,x_CHECK_STATUS    OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE      OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
   )
IS
 l_SOA_SV_ID NUMBER := 0;

 CURSOR c_SOA_SV_ID IS
  SELECT sv_soa_id
   FROM xnp_sv_soa SOA
   WHERE SOA.status_type_code = p_status_type_code
   AND TO_NUMBER(SOA.subscription_tn) BETWEEN TO_NUMBER(p_starting_number)  AND TO_NUMBER(p_ending_number) ;

BEGIN
  x_ERROR_CODE   := 0;
  x_CHECK_STATUS := 'Y';

  -- see if there exists atleast one

  OPEN c_SOA_SV_ID;
  FETCH c_SOA_SV_ID INTO l_SOA_SV_ID;

  -- If exits then return 'Y'

  IF c_SOA_SV_ID%FOUND THEN
    x_CHECK_STATUS := 'Y';
  ELSE
    x_CHECK_STATUS := 'N';
  END IF;

  CLOSE c_SOA_SV_ID;

  EXCEPTION
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.CHECK_SOA_STATUS_EXISTS');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;
      IF c_SOA_SV_ID%ISOPEN THEN
        CLOSE c_SOA_SV_ID;
      END IF;


END CHECK_SOA_STATUS_EXISTS;


PROCEDURE SMS_DELETE_FE_MAP
 (p_STARTING_NUMBER     VARCHAR2
 ,p_ENDING_NUMBER       VARCHAR2
 ,p_FE_ID               NUMBER
 ,p_FEATURE_TYPE        VARCHAR2
 ,x_ERROR_CODE      OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
 )
IS
l_STARTING_NUMBER VARCHAR2(80) := null;
l_ENDING_NUMBER   VARCHAR2(80) := null;

BEGIN

  x_ERROR_CODE := 0;


  l_starting_number := to_char(to_number(p_starting_number));
  l_ending_number   := to_char(to_number(p_ending_number));

  DELETE
    FROM xnp_sv_sms_fe_maps
   WHERE fe_id        = p_fe_id
     AND feature_type = p_feature_type
     AND sv_sms_id IN
              (SELECT sv_sms_id
                 FROM xnp_sv_sms
                WHERE subscription_tn BETWEEN l_starting_number AND l_ending_number) ;

  EXCEPTION
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.SMS_DELETE_FE_MAP');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;


END SMS_DELETE_FE_MAP;

PROCEDURE CHECK_DONOR_PHASE
 (p_STARTING_NUMBER  IN VARCHAR2
 ,p_ENDING_NUMBER    IN VARCHAR2
 ,p_SP_ID IN            NUMBER
 ,p_PHASE_INDICATOR  IN VARCHAR2
 ,x_CHECK_EXISTS    OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE      OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
 )
IS
 l_STARTING_NUMBER VARCHAR2(80) := null;
 l_ENDING_NUMBER   VARCHAR2(80) := null;
 l_SOA_SV_ID       NUMBER := 0;

 CURSOR c_SOA_SV_ID IS
  SELECT sv_soa_id
    FROM xnp_sv_soa SOA , xnp_sv_status_types_b STA
   WHERE SOA.subscription_tn  = l_starting_number
     AND SOA.donor_sp_id      = p_sp_id
     AND SOA.status_type_code = STA.status_type_code
     AND STA.phase_indicator  = p_phase_indicator ;

BEGIN

  x_ERROR_CODE   := 0;
  x_CHECK_EXISTS := 'Y';

  l_starting_number := to_char(to_number(p_starting_number));
  l_ending_number   := to_char(to_number(p_ending_number));

  OPEN c_SOA_SV_ID;
  FETCH c_SOA_SV_ID INTO l_SOA_SV_ID;

  -- If exits then return 'Y'
  IF c_SOA_SV_ID%FOUND THEN
    x_CHECK_EXISTS := 'Y';
  ELSE
    x_CHECK_EXISTS := 'N';
  END IF;

  CLOSE c_SOA_SV_ID;


  EXCEPTION
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.CHECK_DONOR_PHASE');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_SOA_SV_ID%ISOPEN THEN
        CLOSE c_SOA_SV_ID;
      END IF;

END CHECK_DONOR_PHASE;

PROCEDURE CHECK_RECIPIENT_PHASE
 (p_STARTING_NUMBER IN VARCHAR2
 ,p_ENDING_NUMBER   IN VARCHAR2
 ,p_SP_ID IN           NUMBER
 ,p_PHASE_INDICATOR IN VARCHAR2
 ,x_CHECK_EXISTS   OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE     OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
 )
IS
 l_SOA_SV_ID       NUMBER := 0;
 l_STARTING_NUMBER VARCHAR2(80) := null;
 l_ENDING_NUMBER   VARCHAR2(80) := null;

 CURSOR c_SOA_SV_ID IS
  SELECT sv_soa_id
    FROM xnp_sv_soa SOA ,
         xnp_sv_status_types_b STA
   WHERE SOA.subscription_tn  = p_starting_number
     AND SOA.recipient_sp_id  = p_sp_id
     AND SOA.status_type_code = STA.status_type_code
     AND STA.phase_indicator  = p_phase_indicator ;

BEGIN
  x_ERROR_CODE   := 0;
  x_CHECK_EXISTS := 'Y';

  l_starting_number := to_char(to_number(p_starting_number));
  l_ending_number   := to_char(to_number(p_ending_number));

  OPEN c_SOA_SV_ID;
  FETCH c_SOA_SV_ID INTO l_SOA_SV_ID;

  -- If exits then return 'Y'
  IF c_SOA_SV_ID%FOUND THEN
    x_CHECK_EXISTS := 'Y';
  ELSE
    x_CHECK_EXISTS := 'N';
  END IF;

  CLOSE c_SOA_SV_ID;


  EXCEPTION
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.CHECK_RECIPIENT_PHASE');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_SOA_SV_ID%ISOPEN THEN
        CLOSE c_SOA_SV_ID;
      END IF;

END CHECK_RECIPIENT_PHASE;

PROCEDURE SOA_RESET_SV_STATUS
   (p_STARTING_NUMBER              VARCHAR2
   ,p_ENDING_NUMBER                VARCHAR2
   ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
   ,p_CUR_PHASE_INDICATOR          VARCHAR2
   ,p_RESET_PHASE_INDICATOR        VARCHAR2
   ,p_OMIT_STATUS                  VARCHAR2
   ,p_STATUS_CHANGE_CAUSE_CODE     VARCHAR2
   ,p_ORDER_ID                 IN  NUMBER
   ,p_LINEITEM_ID              IN  NUMBER
   ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
   ,p_FA_INSTANCE_ID           IN  NUMBER
   ,x_ERROR_CODE               OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
   )
IS
  l_counter                BINARY_INTEGER := 0;
  l_SV_ID                  NUMBER         :=0;
  l_RESET_STATUS_TYPE_CODE VARCHAR2(40)   := NULL;
  l_STARTING_NUMBER        VARCHAR2(80)   := null;
  l_ENDING_NUMBER          VARCHAR2(80)   := null;

  TYPE sv_soa_id_tab          IS TABLE OF NUMBER;
  TYPE sv_soa_status_tab      IS TABLE OF VARCHAR2(40);
  l_sv_event_code             SV_SOA_STATUS_TAB ;
  l_sv_soa_id                 SV_SOA_ID_TAB;
  l_sv_reset_status           SV_SOA_STATUS_TAB ;
  i                           BINARY_INTEGER;

BEGIN

  x_ERROR_CODE := 0;


  l_starting_number := p_starting_number;
  l_ending_number   := p_ending_number;


   -- For each TN Get the SVid which is in this phase
   -- and reset the status status to the reset status
   --

    -- Reset Status for each SV in the given phase

           SELECT sv_soa_id BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.subscription_tn BETWEEN l_starting_number AND l_ending_number
              AND soa.status_type_code IN
                       (SELECT sta.status_type_code
                          FROM xnp_sv_status_types_b sta
                         WHERE sta.phase_indicator = p_cur_phase_indicator
                           AND sta.status_type_code <> p_omit_status);

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.status_type_code = (SELECT min(sta.status_type_code)
                                                   FROM xnp_sv_status_types_b sta
                                                  WHERE sta.phase_indicator = p_reset_phase_indicator)   ,
                         soa.status_change_cause_code = p_status_change_cause_code  ,
                         soa.prev_status_type_code    = soa.status_type_code,
                         soa.modified_date            = sysdate,
                         soa.last_updated_by          = fnd_global.user_id,
                         soa.last_update_date         = sysdate
                   WHERE soa.sv_soa_id                = l_sv_soa_id(i)
                   RETURNING soa.status_type_code BULK COLLECT INTO l_sv_event_code;

                  -- Create a history  record for the status change event  in XNP_SV_EVENT_HISTORY table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  INSERT INTO XNP_SV_EVENT_HISTORY
                         (sv_event_history_id  ,
                          sv_soa_id            ,
                          event_code           ,
                          event_type            ,
                          event_timestamp      ,
                          event_cause_code     ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_EVENT_HISTORY_S.nextval,
                          l_sv_soa_id(i)         ,
                          l_sv_event_code(i)     ,
                          'STATUS_CHANGE'        ,
                          sysdate                ,
                          p_status_change_cause_code,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
         null;
    WHEN OTHERS THEN
         x_ERROR_CODE := SQLCODE;
         fnd_message.set_name('XNP','STD_ERROR');
         fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_RESET_SV_STATUS');
         fnd_message.set_token('ERROR_TEXT',SQLERRM);
         x_error_message := fnd_message.get;

         fnd_message.set_name('XNP','RESET_SV_STATUS');
         fnd_message.set_token('ERROR_TEXT',x_error_message);
         x_error_message := fnd_message.get;


END SOA_RESET_SV_STATUS;

PROCEDURE SOA_UPDATE_OLD_SP_DUE_DATE
 (p_STARTING_NUMBER              VARCHAR2
 ,p_ENDING_NUMBER                VARCHAR2
 ,p_CUR_STATUS_TYPE_CODE         VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,p_OLD_SP_DUE_DATE              DATE
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )

IS
  l_counter         BINARY_INTEGER := 0;
  l_SV_ID           XNP_SV_SOA.SV_SOA_ID%TYPE;
  l_PHASE_INDICATOR XNP_SV_STATUS_TYPES_B.PHASE_INDICATOR%TYPE;
  l_STARTING_NUMBER VARCHAR2(80) := null;
  l_ENDING_NUMBER   VARCHAR2(80) := null;

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN

  x_ERROR_CODE := 0;

  l_starting_number := p_starting_number;
  l_ending_number   := p_ending_number;

  -- Get the phase corresponding to this 'p_CUR_STATUS_TYPE_CODE'

  XNP_CORE.GET_PHASE_FOR_STATUS
   (p_CUR_STATUS_TYPE_CODE
   ,l_PHASE_INDICATOR
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );

  IF x_ERROR_CODE <> 0  THEN
     RETURN;
  END IF;

  --
   -- For each TN Get the SVid which is in this phase
   -- and update the cutoff date to the
   -- given value
   --

    x_ERROR_CODE := 0;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa,
                  xnp_sv_status_types_b sta
            WHERE soa.subscription_tn   BETWEEN l_starting_number AND l_ending_number
              AND sta.phase_indicator  = l_phase_indicator
              AND sta.status_type_code = soa.status_type_code;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.old_sp_due_date  = p_old_sp_due_date,
                         soa.modified_date    = sysdate,
                         soa.last_updated_by  = fnd_global.user_id,
                         soa.last_update_date = sysdate
                   WHERE soa.sv_soa_id        = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
     WHEN dup_val_on_index THEN
          null;

       WHEN OTHERS THEN
            x_ERROR_CODE := SQLCODE;
            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_OLD_SP_DUE_DATE');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

            fnd_message.set_name('XNP','UPD_FOR_SV_ERR');
            fnd_message.set_token('ERROR_TEXT',x_error_message);
            x_error_message := fnd_message.get;


END SOA_UPDATE_OLD_SP_DUE_DATE;

PROCEDURE SMS_DELETE_PORTED_NUMBER
 (p_STARTING_NUMBER  IN VARCHAR2
 ,p_ENDING_NUMBER    IN VARCHAR2
 ,x_ERROR_CODE      OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
 )
IS
  l_sms_map_id      NUMBER       := 0;
  l_STARTING_NUMBER VARCHAR2(80) := null;
  l_ENDING_NUMBER   VARCHAR2(80) := null;

  CURSOR c_sv_map_id is
   SELECT sms_fe_map_id
     FROM xnp_sv_sms_fe_maps
    WHERE sv_sms_id in
             (SELECT sv_sms_id
                FROM xnp_sv_sms
               WHERE subscription_tn BETWEEN l_starting_number AND l_ending_number
             );

BEGIN
  x_ERROR_CODE := 0;

  l_starting_number := p_starting_number;
  l_ending_number   := p_ending_number;

  OPEN c_sv_map_id;
  FETCH c_sv_map_id INTO l_sms_map_id;

  -- If no sms fe map exists for this TN range
  -- the delete the sv order mappings and sms records
  IF (c_sv_map_id%NOTFOUND) THEN

    -- Delete from order mappings

    DELETE
      FROM xnp_sv_order_mappings
     WHERE sv_sms_id IN
              (SELECT sv_sms_id
                 FROM xnp_sv_sms
                WHERE subscription_tn BETWEEN l_starting_number
                                          AND l_ending_number);

    DELETE
      FROM xnp_sv_sms
     WHERE subscription_tn BETWEEN l_starting_number
                               AND l_ending_number ;

  END IF;

  CLOSE c_sv_map_id;

  EXCEPTION
    WHEN OTHERS THEN
      x_ERROR_CODE    := SQLCODE;
      x_ERROR_MESSAGE := SQLERRM;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.SMS_DELETE_PORTED_NUMBER');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','DEL_PORTED_NUM_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;


      fnd_message.set_name('XNP','DEL_PORTED_NUM_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

      IF c_sv_map_id%ISOPEN THEN
       CLOSE c_sv_map_id;
      END IF;
END SMS_DELETE_PORTED_NUMBER;


PROCEDURE SMS_UPDATE_FE_MAP_STATUS
 (p_STARTING_NUMBER          VARCHAR2
 ,p_ENDING_NUMBER            VARCHAR2
 ,p_FE_ID                    NUMBER
 ,p_FEATURE_TYPE             VARCHAR2
 ,p_PROV_STATUS              VARCHAR2
 ,p_ORDER_ID             IN  NUMBER
 ,p_LINEITEM_ID          IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID IN  NUMBER
 ,p_FA_INSTANCE_ID       IN  NUMBER
 ,x_ERROR_CODE           OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 )
IS

 l_STARTING_NUMBER VARCHAR2(80) := null;
 l_ENDING_NUMBER   VARCHAR2(80) := null;

 TYPE sv_sms_id_tab IS TABLE OF NUMBER;
 l_sv_sms_id           SV_SMS_ID_TAB;
 i                     BINARY_INTEGER;

BEGIN

  l_starting_number := p_starting_number;
  l_ending_number   := p_ending_number;

           SELECT sv_sms_id  BULK COLLECT
             INTO l_sv_sms_id
             FROM xnp_sv_sms sms
            WHERE subscription_tn   BETWEEN l_starting_number AND l_ending_number  ;

           FORALL i IN l_sv_sms_id.first..l_sv_sms_id.last

                  UPDATE xnp_sv_sms_fe_maps
                     SET provision_status = p_prov_status  ,
                         last_updated_by = fnd_global.user_id ,
                         last_update_date = sysdate
                   WHERE sv_sms_id    = l_sv_sms_id(i)
                     AND fe_id = p_fe_id
                     AND feature_type = p_feature_type;

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_sms_id.first..l_sv_sms_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_sms_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_sms_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );
  EXCEPTION
    WHEN dup_val_on_index THEN
         null;
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.SMS_UPDATE_FE_MAP_STATUS');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','UPD_FE_MAP_STATUS_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;


END SMS_UPDATE_FE_MAP_STATUS;


PROCEDURE SOA_UPDATE_REC_PORT_ORDER
 (p_PORTING_ID                   VARCHAR2
 ,p_STARTING_NUMBER              NUMBER
 ,p_ENDING_NUMBER                NUMBER
 ,p_DONOR_SP_ID                  NUMBER
 ,p_RECIPIENT_SP_ID              NUMBER DEFAULT NULL
 ,p_ROUTING_NUMBER_ID            NUMBER
 ,p_NEW_SP_DUE_DATE              DATE
 ,p_OLD_SP_CUTOFF_DUE_DATE       DATE
 ,p_CUSTOMER_ID                  VARCHAR2
 ,p_CUSTOMER_NAME                VARCHAR2
 ,p_CUSTOMER_TYPE                VARCHAR2
 ,p_ADDRESS_LINE1                VARCHAR2
 ,p_ADDRESS_LINE2                VARCHAR2
 ,p_CITY                         VARCHAR2
 ,p_PHONE                        VARCHAR2
 ,p_FAX                          VARCHAR2
 ,p_EMAIL                        VARCHAR2
 ,p_PAGER                        VARCHAR2
 ,p_PAGER_PIN                    VARCHAR2
 ,p_INTERNET_ADDRESS             VARCHAR2
 ,p_ZIP_CODE                     VARCHAR2
 ,p_COUNTRY                      VARCHAR2
 ,p_CUSTOMER_CONTACT_REQ_FLAG    VARCHAR2
 ,p_CONTACT_NAME                 VARCHAR2
 ,p_RETAIN_TN_FLAG               VARCHAR2
 ,p_RETAIN_DIR_INFO_FLAG         VARCHAR2
 ,p_CNAM_ADDRESS                 VARCHAR2
 ,p_CNAM_SUBSYSTEM               VARCHAR2
 ,p_ISVM_ADDRESS                 VARCHAR2
 ,p_ISVM_SUBSYSTEM               VARCHAR2
 ,p_LIDB_ADDRESS                 VARCHAR2
 ,p_LIDB_SUBSYSTEM               VARCHAR2
 ,p_CLASS_ADDRESS                VARCHAR2
 ,p_CLASS_SUBSYSTEM              VARCHAR2
 ,p_WSMSC_ADDRESS                VARCHAR2
 ,p_WSMSC_SUBSYSTEM              VARCHAR2
 ,p_RN_ADDRESS                   VARCHAR2
 ,p_RN_SUBSYSTEM                 VARCHAR2
 ,p_PREORDER_AUTHORIZATION_CODE  VARCHAR2
 ,p_ACTIVATION_DUE_DATE          DATE
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id ;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET SOA.CHANGED_BY_SP_ID            = p_RECIPIENT_SP_ID           ,
                         SOA.OLD_SP_CUTOFF_DUE_DATE      = p_OLD_SP_CUTOFF_DUE_DATE    ,
                         SOA.CUSTOMER_ID                 = p_CUSTOMER_ID               ,
                         SOA.CUSTOMER_NAME               = p_CUSTOMER_NAME             ,
                         SOA.CUSTOMER_TYPE               = p_CUSTOMER_TYPE             ,
                         SOA.ADDRESS_LINE1               = p_ADDRESS_LINE1              ,
                         SOA.ADDRESS_LINE2               = p_ADDRESS_LINE2              ,
                         SOA.CITY                        = p_CITY                      ,
                         SOA.PHONE                       = p_PHONE                     ,
                         SOA.FAX                         = p_FAX                       ,
                         SOA.EMAIL                       = p_EMAIL                     ,
                         SOA.ZIP_CODE                    = p_ZIP_CODE                  ,
                         SOA.COUNTRY                     = p_COUNTRY                   ,
                         SOA.NEW_SP_DUE_DATE             = p_NEW_SP_DUE_DATE           ,
                         SOA.CUSTOMER_CONTACT_REQ_FLAG   = p_CUSTOMER_CONTACT_REQ_FLAG ,
                         SOA.CONTACT_NAME                = p_CONTACT_NAME              ,
                         SOA.RETAIN_TN_FLAG              = p_RETAIN_TN_FLAG            ,
                         SOA.RETAIN_DIR_INFO_FLAG        = p_RETAIN_DIR_INFO_FLAG      ,
                         SOA.PAGER                       = p_PAGER                     ,
                         SOA.PAGER_PIN                   = p_PAGER_PIN                 ,
                         SOA.INTERNET_ADDRESS            = p_INTERNET_ADDRESS          ,
                         SOA.CNAM_ADDRESS                = p_CNAM_ADDRESS              ,
                         SOA.CNAM_SUBSYSTEM              = p_CNAM_SUBSYSTEM            ,
                         SOA.ISVM_ADDRESS                = p_ISVM_ADDRESS              ,
                         SOA.ISVM_SUBSYSTEM              = p_ISVM_SUBSYSTEM            ,
                         SOA.LIDB_ADDRESS                = p_LIDB_ADDRESS              ,
                         SOA.LIDB_SUBSYSTEM              = p_LIDB_SUBSYSTEM            ,
                         SOA.CLASS_ADDRESS               = p_CLASS_ADDRESS             ,
                         SOA.CLASS_SUBSYSTEM             = p_CLASS_SUBSYSTEM           ,
                         SOA.WSMSC_ADDRESS               = p_WSMSC_ADDRESS             ,
                         SOA.WSMSC_SUBSYSTEM             = p_WSMSC_SUBSYSTEM           ,
                         SOA.RN_ADDRESS                  = p_RN_ADDRESS                ,
                         SOA.RN_SUBSYSTEM                = p_RN_SUBSYSTEM              ,
                         SOA.PREORDER_AUTHORIZATION_CODE = p_PREORDER_AUTHORIZATION_CODE     ,
                         SOA.ACTIVATION_DUE_DATE         = p_ACTIVATION_DUE_DATE       ,
                         SOA.LAST_UPDATED_BY             = FND_GLOBAL.USER_ID          ,
                         SOA.LAST_UPDATE_DATE            = SYSDATE                     ,
                         SOA.MODIFIED_DATE               = SYSDATE
                   WHERE soa.sv_soa_id    = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
       WHEN dup_val_on_index THEN
            null;
       WHEN OTHERS THEN
            x_ERROR_CODE := SQLCODE;
            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_REC_PORT_ORDER');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

            fnd_message.set_name('XNP','UPD_PORT_ORDER_ERR');
            fnd_message.set_token('ERROR_TEXT',x_error_message);
            x_error_message := fnd_message.get;

END SOA_UPDATE_REC_PORT_ORDER;

PROCEDURE SOA_UPDATE_DON_PORT_ORDER
 (p_PORTING_ID                   VARCHAR2
 ,p_STARTING_NUMBER              NUMBER
 ,p_ENDING_NUMBER                NUMBER
 ,p_DONOR_SP_ID                  NUMBER DEFAULT NULL
 ,p_RECIPIENT_SP_ID              NUMBER
 ,p_OLD_SP_DUE_DATE              DATE
 ,p_OLD_SP_CUTOFF_DUE_DATE       DATE
 ,p_CUSTOMER_ID                  VARCHAR2
 ,p_CUSTOMER_NAME                VARCHAR2
 ,p_CUSTOMER_TYPE                VARCHAR2
 ,p_ADDRESS_LINE1                VARCHAR2
 ,p_ADDRESS_LINE2                VARCHAR2
 ,p_CITY                         VARCHAR2
 ,p_PHONE                        VARCHAR2
 ,p_FAX                          VARCHAR2
 ,p_EMAIL                        VARCHAR2
 ,p_PAGER                        VARCHAR2
 ,p_PAGER_PIN                    VARCHAR2
 ,p_INTERNET_ADDRESS             VARCHAR2
 ,p_ZIP_CODE                     VARCHAR2
 ,p_COUNTRY                      VARCHAR2
 ,p_CUSTOMER_CONTACT_REQ_FLAG    VARCHAR2
 ,p_CONTACT_NAME                 VARCHAR2
 ,p_RETAIN_TN_FLAG               VARCHAR2
 ,p_RETAIN_DIR_INFO_FLAG         VARCHAR2
 ,p_CNAM_ADDRESS                 VARCHAR2
 ,p_CNAM_SUBSYSTEM               VARCHAR2
 ,p_ISVM_ADDRESS                 VARCHAR2
 ,p_ISVM_SUBSYSTEM               VARCHAR2
 ,p_LIDB_ADDRESS                 VARCHAR2
 ,p_LIDB_SUBSYSTEM               VARCHAR2
 ,p_CLASS_ADDRESS                VARCHAR2
 ,p_CLASS_SUBSYSTEM              VARCHAR2
 ,p_WSMSC_ADDRESS                VARCHAR2
 ,p_WSMSC_SUBSYSTEM              VARCHAR2
 ,p_RN_ADDRESS                   VARCHAR2
 ,p_RN_SUBSYSTEM                 VARCHAR2
 ,p_PREORDER_AUTHORIZATION_CODE  VARCHAR2
 ,p_ACTIVATION_DUE_DATE          DATE
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET SOA.CHANGED_BY_SP_ID            = p_DONOR_SP_ID    ,
                         SOA.OLD_SP_CUTOFF_DUE_DATE      = p_OLD_SP_CUTOFF_DUE_DATE    ,
                         SOA.CUSTOMER_ID                 = p_CUSTOMER_ID    ,
                         SOA.CUSTOMER_NAME               = p_CUSTOMER_NAME    ,
                         SOA.CUSTOMER_TYPE               = p_CUSTOMER_TYPE    ,
                         SOA.ADDRESS_LINE1               = p_ADDRESS_LINE1    ,
                         SOA.ADDRESS_LINE2               = p_ADDRESS_LINE2    ,
                         SOA.CITY                        = p_CITY    ,
                         SOA.PHONE                       = p_PHONE    ,
                         SOA.FAX                         = p_FAX    ,
                         SOA.EMAIL                       = p_EMAIL    ,
                         SOA.ZIP_CODE                    = p_ZIP_CODE    ,
                         SOA.COUNTRY                     = p_COUNTRY    ,
                         SOA.OLD_SP_DUE_DATE             = p_OLD_SP_DUE_DATE    ,
                         SOA.CUSTOMER_CONTACT_REQ_FLAG   = p_CUSTOMER_CONTACT_REQ_FLAG    ,
                         SOA.CONTACT_NAME                = p_CONTACT_NAME    ,
                         SOA.RETAIN_TN_FLAG              = p_RETAIN_TN_FLAG    ,
                         SOA.RETAIN_DIR_INFO_FLAG        = p_RETAIN_DIR_INFO_FLAG    ,
                         SOA.PAGER                       = p_PAGER    ,
                         SOA.PAGER_PIN                   = p_PAGER_PIN    ,
                         SOA.INTERNET_ADDRESS            = p_INTERNET_ADDRESS    ,
                         SOA.CNAM_ADDRESS                = p_CNAM_ADDRESS     ,
                         SOA.CNAM_SUBSYSTEM              = p_CNAM_SUBSYSTEM     ,
                         SOA.ISVM_ADDRESS                = p_ISVM_ADDRESS     ,
                         SOA.ISVM_SUBSYSTEM              = p_ISVM_SUBSYSTEM      ,
                         SOA.LIDB_ADDRESS                = p_LIDB_ADDRESS     ,
                         SOA.LIDB_SUBSYSTEM              = p_LIDB_SUBSYSTEM     ,
                         SOA.CLASS_ADDRESS               = p_CLASS_ADDRESS     ,
                         SOA.CLASS_SUBSYSTEM             = p_CLASS_SUBSYSTEM     ,
                         SOA.WSMSC_ADDRESS               = p_WSMSC_ADDRESS     ,
                         SOA.WSMSC_SUBSYSTEM             = p_WSMSC_SUBSYSTEM     ,
                         SOA.RN_ADDRESS                  = p_RN_ADDRESS     ,
                         SOA.RN_SUBSYSTEM                = p_RN_SUBSYSTEM    ,
                         SOA.PREORDER_AUTHORIZATION_CODE = p_PREORDER_AUTHORIZATION_CODE     ,
                         SOA.ACTIVATION_DUE_DATE         = p_ACTIVATION_DUE_DATE     ,
                         SOA.LAST_UPDATED_BY             = FND_GLOBAL.USER_ID ,
                         SOA.LAST_UPDATE_DATE            = SYSDATE,
                         SOA.MODIFIED_DATE               = SYSDATE
                   WHERE SOA.SV_SOA_ID                   = L_SV_SOA_ID(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
       WHEN dup_val_on_index THEN
            null;
       WHEN OTHERS THEN
            x_ERROR_CODE := SQLCODE;
            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_DON_PORT_ORDER');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

            fnd_message.set_name('XNP','UPD_PORT_ORDER_ERR');
            fnd_message.set_token('ERROR_TEXT',x_error_message);
            x_error_message := fnd_message.get;

END SOA_UPDATE_DON_PORT_ORDER;

PROCEDURE SMS_MODIFY_PORTED_NUMBER
 (p_PORTING_ID               IN  VARCHAR2
 ,p_STARTING_NUMBER          IN  NUMBER
 ,p_ENDING_NUMBER            IN  NUMBER
 ,p_ROUTING_NUMBER_ID        IN  NUMBER
 ,p_PORTING_TIME             IN  DATE
 ,p_CNAM_ADDRESS                 VARCHAR2
 ,p_CNAM_SUBSYSTEM               VARCHAR2
 ,p_ISVM_ADDRESS                 VARCHAR2
 ,p_ISVM_SUBSYSTEM               VARCHAR2
 ,p_LIDB_ADDRESS                 VARCHAR2
 ,p_LIDB_SUBSYSTEM               VARCHAR2
 ,p_CLASS_ADDRESS                VARCHAR2
 ,p_CLASS_SUBSYSTEM              VARCHAR2
 ,p_WSMSC_ADDRESS                VARCHAR2
 ,p_WSMSC_SUBSYSTEM              VARCHAR2
 ,p_RN_ADDRESS                   VARCHAR2
 ,p_RN_SUBSYSTEM                 VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_sms_id_tab IS TABLE OF NUMBER;
  l_sv_sms_id           SV_SMS_ID_TAB;
  i                     BINARY_INTEGER;


BEGIN


           SELECT sv_sms_id  BULK COLLECT
             INTO l_sv_sms_id
             FROM xnp_sv_sms sms
            WHERE object_reference = p_porting_id ;

           FORALL i IN l_sv_sms_id.first..l_sv_sms_id.last

                  UPDATE XNP_SV_SMS SMS
                     SET SMS.PROVISION_SENT_DATE = P_PORTING_TIME  ,
                         SMS.ROUTING_NUMBER_ID  = p_ROUTING_NUMBER_ID    ,
                         SMS.CNAM_ADDRESS       = p_CNAM_ADDRESS     ,
                         SMS.CNAM_SUBSYSTEM     = p_CNAM_SUBSYSTEM    ,
                         SMS.ISVM_ADDRESS       = p_ISVM_ADDRESS     ,
                         SMS.ISVM_SUBSYSTEM     = p_ISVM_SUBSYSTEM     ,
                         SMS.LIDB_ADDRESS       = p_LIDB_ADDRESS     ,
                         SMS.LIDB_SUBSYSTEM     = p_LIDB_SUBSYSTEM     ,
                         SMS.CLASS_ADDRESS      = p_CLASS_ADDRESS     ,
                         SMS.CLASS_SUBSYSTEM    = p_CLASS_SUBSYSTEM     ,
                         SMS.WSMSC_ADDRESS      = p_WSMSC_ADDRESS     ,
                         SMS.WSMSC_SUBSYSTEM    = p_WSMSC_SUBSYSTEM     ,
                         SMS.RN_ADDRESS         = p_RN_ADDRESS     ,
                         SMS.RN_SUBSYSTEM       = p_RN_SUBSYSTEM     ,
                         SMS.LAST_UPDATED_BY    = FND_GLOBAL.USER_ID ,
                         SMS.LAST_UPDATE_DATE   = SYSDATE
                   WHERE SMS.SV_SMS_ID       = L_SV_SMS_ID(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_sms_id.first..l_sv_sms_id.last

                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_sms_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_sms_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
       WHEN dup_val_on_index THEN
            null;
       WHEN OTHERS THEN
            x_ERROR_CODE := SQLCODE;
            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN'  ,'XNP_CORE.SMS_MODIFY_PORTED_NUMBER');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

            fnd_message.set_name('XNP','UPD_PORT_ORDER_ERR');
            fnd_message.set_token('ERROR_TEXT',x_error_message);
            x_error_message := fnd_message.get;

END SMS_MODIFY_PORTED_NUMBER;

PROCEDURE CHECK_IF_PORTABLE_RANGE
 (p_STARTING_NUMBER    VARCHAR2
 ,p_ENDING_NUMBER      VARCHAR2
 ,x_CHECK_STATUS   OUT NOCOPY NUMBER
 ,x_ERROR_CODE     OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
 )
IS

 l_PORTED_INDICATOR VARCHAR2(40) := NULL;

 CURSOR c_PORTED_INDICATOR IS
   SELECT ported_indicator
     FROM xnp_number_ranges
    WHERE starting_number <= p_starting_number
      AND ending_number   >= p_ending_number;

BEGIN

  x_CHECK_STATUS := 'N';
  OPEN c_PORTED_INDICATOR;
  FETCH c_PORTED_INDICATOR INTO l_PORTED_INDICATOR;

  IF c_PORTED_INDICATOR%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_PORTED_INDICATOR;

  x_CHECK_STATUS := 'N';

  if ( (l_PORTED_INDICATOR = 'PORTED_IN_USE')
       OR (l_PORTED_INDICATOR = 'PORTED_UNUSED') )
  then
    x_CHECK_STATUS := 'Y';
  end if;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token
        ('FAILED_PROC','XNP_CORE.CHECK_IF_PORTED_NUMBER_RANGE');
      fnd_message.set_token('ATTRNAME','PORTED_INDICATOR');
      fnd_message.set_token('KEY','STARTING_NUMBER:ENDING_NUMBER');
      fnd_message.set_token
       ('VALUE'
       ,p_STARTING_NUMBER||':'||p_ENDING_NUMBER
       );
      x_error_message :=
       fnd_message.get;
      x_ERROR_MESSAGE := x_error_message||':'||SQLERRM;

      fnd_message.set_name('XNP','CHECK_IF_PORTABLE_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

      IF c_PORTED_INDICATOR%ISOPEN THEN
       CLOSE c_PORTED_INDICATOR;
      END IF;

  WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token
       ('ERROR_LOCN','XNP_CORE.CHECK_IF_PORTED_NUMBER_RANGE');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;
      IF c_PORTED_INDICATOR%ISOPEN THEN
       CLOSE c_PORTED_INDICATOR;
      END IF;

END CHECK_IF_PORTABLE_RANGE;


PROCEDURE SOA_UPDATE_OLD_SP_DUE_DATE
 (p_PORTING_ID                   VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,p_OLD_SP_DUE_DATE              DATE
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

e_SOA_UPDATE_OLD_SP_DUE_DATE exception;

BEGIN

 if(p_old_sp_due_date = null) then
   raise e_SOA_UPDATE_OLD_SP_DUE_DATE;
 end if;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.old_sp_due_date  = p_old_sp_due_date  ,
                         soa.modified_date    = sysdate,
                         soa.last_updated_by  = fnd_global.user_id,
                         soa.last_update_date = sysdate
                   WHERE soa.sv_soa_id        = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

 EXCEPTION
    WHEN dup_val_on_index THEN
         null;

    WHEN e_SOA_UPDATE_OLD_SP_DUE_DATE THEN
         x_error_code := XNP_ERRORS.G_INVALID_DATE_FORMAT;
         fnd_message.set_name('XNP','INVALID_DATE_FORMAT_ERR');
         fnd_message.set_token('PORTING_ID',p_porting_id);

    WHEN OTHERS THEN
         x_ERROR_CODE := SQLCODE;
         fnd_message.set_name('XNP','STD_ERROR');
         fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_OLD_SP_DUE_DATE');
         fnd_message.set_token('ERROR_TEXT',SQLERRM);
         x_error_message := fnd_message.get;

END SOA_UPDATE_OLD_SP_DUE_DATE;

PROCEDURE SOA_UPDATE_NEW_SP_DUE_DATE
 (p_PORTING_ID                   VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,p_NEW_SP_DUE_DATE              DATE
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

e_SOA_UPDATE_NEW_SP_DUE_DATE exception;

BEGIN

 if(p_new_sp_due_date = null) then
   raise e_SOA_UPDATE_NEW_SP_DUE_DATE;
 end if;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.new_sp_due_date  = p_new_sp_due_date,
                         soa.modified_date    = sysdate,
                         soa.last_updated_by  = fnd_global.user_id,
                         soa.last_update_date = sysdate
                   WHERE soa.sv_soa_id        = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

 EXCEPTION
      WHEN dup_val_on_index THEN
            null;
      WHEN e_SOA_UPDATE_NEW_SP_DUE_DATE THEN
           x_error_code := XNP_ERRORS.G_INVALID_DATE_FORMAT;
           fnd_message.set_name('XNP','INVALID_DATE_FORMAT_ERR');
           fnd_message.set_token('PORTING_ID',p_porting_id);
      WHEN OTHERS THEN
           x_ERROR_CODE := SQLCODE;
           fnd_message.set_name('XNP','STD_ERROR');
           fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_NEW_SP_DUE_DATE');
           fnd_message.set_token('ERROR_TEXT',SQLERRM);
           x_error_message := fnd_message.get;

END SOA_UPDATE_NEW_SP_DUE_DATE;


PROCEDURE CHECK_DONOR_STATUS_EXISTS
   (p_STARTING_NUMBER     VARCHAR2
   ,p_ENDING_NUMBER       VARCHAR2
   ,p_STATUS_TYPE_CODE    VARCHAR2
   ,p_DONOR_SP_ID         NUMBER
   ,x_CHECK_STATUS    OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE      OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
   )
IS
 l_SOA_SV_ID NUMBER := 0;

 CURSOR c_SOA_SV_ID IS
  SELECT sv_soa_id
    FROM xnp_sv_soa SOA
   WHERE status_type_code = p_status_type_code
     AND SOA.donor_sp_id  = p_donor_sp_id
     AND ( (to_number(subscription_tn) >= to_number(p_starting_number))
        AND (to_number(subscription_tn) <= to_number(p_ending_number)) ) ;

BEGIN
  x_ERROR_CODE   := 0;
  x_CHECK_STATUS := 'Y';

  -- see if there exists atleast one

  OPEN c_SOA_SV_ID;
  FETCH c_SOA_SV_ID INTO l_SOA_SV_ID;

  -- If exits then return 'Y'
  IF c_SOA_SV_ID%FOUND THEN
    x_CHECK_STATUS := 'Y';
  ELSE
    x_CHECK_STATUS := 'N';
  END IF;

  CLOSE c_SOA_SV_ID;

  EXCEPTION
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.CHECK_DONOR_STATUS_EXISTS');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;
      IF c_SOA_SV_ID%ISOPEN THEN
        CLOSE c_SOA_SV_ID;
      END IF;


END CHECK_DONOR_STATUS_EXISTS;



PROCEDURE CHECK_RECIPIENT_STATUS_EXISTS
   (p_STARTING_NUMBER      VARCHAR2
   ,p_ENDING_NUMBER        VARCHAR2
   ,p_STATUS_TYPE_CODE     VARCHAR2
   ,p_RECIPIENT_SP_ID      NUMBER
   ,x_CHECK_STATUS OUT NOCOPY     VARCHAR2
   ,x_ERROR_CODE       OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE    OUT NOCOPY VARCHAR2
   )
IS
 l_SOA_SV_ID NUMBER := 0;

 CURSOR c_SOA_SV_ID IS
  SELECT sv_soa_id
    FROM xnp_sv_soa XSO
   WHERE status_type_code    = p_status_type_code
     AND XSO.recipient_sp_id = p_recipient_sp_id
     AND to_number(subscription_tn) BETWEEN to_number(p_starting_number)  AND to_number(p_ending_number);

BEGIN
  x_ERROR_CODE   := 0;
  x_CHECK_STATUS := 'Y';

  -- see if there exists atleast one

  OPEN c_SOA_SV_ID;
  FETCH c_SOA_SV_ID INTO l_SOA_SV_ID;

  -- If exits then return 'Y'
  IF c_SOA_SV_ID%FOUND THEN
    x_CHECK_STATUS := 'Y';
  ELSE
    x_CHECK_STATUS := 'N';
  END IF;

  CLOSE c_SOA_SV_ID;

  EXCEPTION
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.CHECK_RECIPIENT_STATUS_EXISTS');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;
      IF c_SOA_SV_ID%ISOPEN THEN
        CLOSE c_SOA_SV_ID;
      END IF;


END CHECK_RECIPIENT_STATUS_EXISTS;

PROCEDURE SOA_UPDATE_CUTOFF_DATE
 (p_PORTING_ID                   VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,p_OLD_SP_CUTOFF_DUE_DATE       DATE
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;


BEGIN
  x_ERROR_CODE := 0;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.old_sp_cutoff_due_date = XNP_UTILS.CANONICAL_TO_DATE(p_old_sp_cutoff_due_date)  ,
                         soa.modified_date          = sysdate,
                         soa.last_updated_by        = fnd_global.user_id,
                         soa.last_update_date       = sysdate
                   WHERE soa.sv_soa_id              = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
       WHEN dup_val_on_index THEN
            null;
       WHEN OTHERS THEN
            x_ERROR_CODE := SQLCODE;
            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_CUTOFF_DATE');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

END SOA_UPDATE_CUTOFF_DATE;

PROCEDURE SOA_UPDATE_CHARGING_INFO
 (p_PORTING_ID                   VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,p_INVOICE_DUE_DATE             DATE
 ,p_CHARGING_INFO                VARCHAR2
 ,p_BILLING_ID                   NUMBER
 ,p_USER_LOCTN_VALUE             VARCHAR2
 ,p_USER_LOCTN_TYPE              VARCHAR2
 ,p_PRICE_CODE                   VARCHAR2
 ,p_PRICE_PER_CALL               VARCHAR2
 ,p_PRICE_PER_MINUTE             VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

  l_counter BINARY_INTEGER := 0;

BEGIN

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference=p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.invoice_due_date = p_invoice_due_date,
                         soa.charging_info    = p_charging_info  ,
                         soa.user_loctn_type  = p_user_loctn_type,
                         soa.user_loctn_value = p_user_loctn_value,
                         soa.price_code       = p_price_code,
                         soa.price_per_call   = p_price_per_call,
                         soa.price_per_minute = p_price_per_minute,
                         soa.modified_date    = sysdate,
                         soa.last_updated_by  = fnd_global.user_id,
                         soa.last_update_date = sysdate
                   WHERE soa.sv_soa_id        = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
       WHEN dup_val_on_index THEN
            null;
       WHEN OTHERS THEN
            x_ERROR_CODE := SQLCODE;
            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_CHARGING_INFO');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

            fnd_message.set_name('XNP','UPD_CHARGING_INFO_ERR');
            fnd_message.set_token('ERROR_TEXT',x_error_message);
            x_error_message := fnd_message.get;

END SOA_UPDATE_CHARGING_INFO;

PROCEDURE CHECK_SOA_STATUS_EXISTS
   (p_PORTING_ID           VARCHAR2
   ,p_STATUS_TYPE_CODE     VARCHAR2
   ,p_LOCAL_SP_ID          NUMBER DEFAULT NULL
   ,x_CHECK_STATUS     OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE       OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE    OUT NOCOPY VARCHAR2
   )
IS

 l_SOA_SV_ID NUMBER := 0;

 CURSOR c_SOA_SV_ID IS
  SELECT sv_soa_id
    FROM xnp_sv_soa SOA
   WHERE SOA.object_reference = p_porting_id
     AND SOA.status_type_code = p_status_type_code;

BEGIN
  x_ERROR_CODE   := 0;
  x_CHECK_STATUS := 'Y';

  -- see if there exists atleast one --

  OPEN c_SOA_SV_ID;
  FETCH c_SOA_SV_ID INTO l_SOA_SV_ID;

  -- If exits then return 'Y'
  IF c_SOA_SV_ID%FOUND THEN
    x_CHECK_STATUS := 'Y';
  ELSE
    x_CHECK_STATUS := 'N';
  END IF;

  CLOSE c_SOA_SV_ID;

  EXCEPTION
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.CHECK_SOA_STATUS_EXISTS');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;
      IF c_SOA_SV_ID%ISOPEN THEN
        CLOSE c_SOA_SV_ID;
      END IF;
END CHECK_SOA_STATUS_EXISTS;

PROCEDURE SOA_UPDATE_OLD_SP_AUTH_FLAG
 (p_PORTING_ID                   VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,p_OLD_SP_AUTHORIZATION_FLAG    VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN

  x_ERROR_CODE := 0;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.old_sp_authorization_flag = p_old_sp_authorization_flag,
                         soa.modified_date             = sysdate,
                         soa.last_updated_by           = fnd_global.user_id,
                         soa.last_update_date          = sysdate
                   WHERE soa.sv_soa_id                 = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
    WHEN dup_val_on_index THEN
         null;
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_OLD_SP_AUTH_FLAG');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','UPD_FOR_SV_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

END SOA_UPDATE_OLD_SP_AUTH_FLAG;

PROCEDURE SOA_UPDATE_NEW_SP_AUTH_FLAG
 (p_PORTING_ID                   VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,p_NEW_SP_AUTHORIZATION_FLAG    VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )

IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;


BEGIN

  x_ERROR_CODE := 0;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.new_sp_authorization_flag = p_new_sp_authorization_flag  ,
                         soa.modified_date             = sysdate,
                         soa.last_updated_by           = fnd_global.user_id,
                         soa.last_update_date          = sysdate
                   WHERE soa.sv_soa_id                 = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
       WHEN dup_val_on_index THEN
            null;
       WHEN OTHERS THEN
            x_ERROR_CODE := SQLCODE;
            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_NEW_SP_AUTH_FLAG');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

            fnd_message.set_name('XNP','UPD_FOR_SV_ERR');
            fnd_message.set_token('ERROR_TEXT',x_error_message);
            x_error_message := fnd_message.get;

END SOA_UPDATE_NEW_SP_AUTH_FLAG;

PROCEDURE SMS_MARK_FES_TO_PROVISION
   (p_STARTING_NUMBER      VARCHAR2
   ,p_ENDING_NUMBER        VARCHAR2
   ,p_FEATURE_TYPE         VARCHAR2
   ,p_ORDER_ID             NUMBER
   ,p_LINEITEM_ID          NUMBER
   ,p_WORKITEM_INSTANCE_ID NUMBER
   ,p_FA_INSTANCE_ID       NUMBER
   ,x_ERROR_CODE       OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE    OUT NOCOPY VARCHAR2
   )
IS
l_NUMBER_RANGE_ID NUMBER := 0;

CURSOR c_ALL_FEs IS
    SELECT SNR.fe_id
      FROM XNP_SERVED_NUM_RANGES SNR, XDP_FES FES
    WHERE SNR.feature_type    = p_feature_type
      AND SNR.number_range_id = l_number_range_id
      AND SNR.fe_id           = FES.fe_id
      AND (sysdate BETWEEN FES.valid_date AND NVL(FES.invalid_date, sysdate));

BEGIN
  x_error_code := 0;

  -- Determine the number range id

    XNP_CORE.GET_NUMBER_RANGE_ID
    (p_STARTING_NUMBER
    ,p_ENDING_NUMBER
    ,l_NUMBER_RANGE_ID
    ,x_ERROR_CODE
    ,x_ERROR_MESSAGE
    );

    IF x_error_code <> 0  THEN
      return;
    END IF;

    -- get the fe list to provision
    FOR l_tmp_fe IN c_ALL_FEs LOOP

      -- Insert the FE MAP for the FE to be provisioned
      XNP_CORE.SMS_INSERT_FE_MAP
      (p_ORDER_ID,
       p_LINEITEM_ID,
       p_WORKITEM_INSTANCE_ID,
       p_FA_INSTANCE_ID,
       to_number(p_STARTING_NUMBER),
       to_number(p_ENDING_NUMBER),
       l_TMP_FE.FE_ID,
       p_FEATURE_TYPE,
       x_ERROR_CODE,
       x_ERROR_MESSAGE
      );

      IF (x_error_code <> 0) THEN
         return;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN dup_val_on_index THEN
         null;
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.SMS_MARK_FES_TO_PROVISION');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','UPD_FOR_SV_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

END SMS_MARK_FES_TO_PROVISION;

PROCEDURE SMS_MARK_FES_TO_DEPROVISION
   (p_STARTING_NUMBER          VARCHAR2
   ,p_ENDING_NUMBER            VARCHAR2
   ,p_FEATURE_TYPE             VARCHAR2
   ,p_DEPROVISION_STATUS       VARCHAR2
   ,p_ORDER_ID             IN  NUMBER
   ,p_LINEITEM_ID          IN  NUMBER
   ,p_WORKITEM_INSTANCE_ID IN  NUMBER
   ,p_FA_INSTANCE_ID       IN  NUMBER
   ,x_ERROR_CODE           OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
   )
IS

  l_STARTING_NUMBER VARCHAR2(80) := null;
  l_ENDING_NUMBER VARCHAR2(80)   := null;

  TYPE sv_sms_id_tab IS TABLE OF NUMBER;
  l_sv_sms_id           SV_SMS_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN

 x_error_code := 0;

 l_starting_number := p_starting_number;
 l_ending_number   := p_ending_number;

           SELECT sv_sms_id  BULK COLLECT
             INTO l_sv_sms_id
             FROM xnp_sv_sms
            WHERE subscription_tn BETWEEN l_starting_number AND l_ending_number;

           FORALL i IN l_sv_sms_id.first..l_sv_sms_id.last

           UPDATE xnp_sv_sms_fe_maps
              SET provision_status = p_deprovision_status  ,
                  last_updated_by  = fnd_global.user_id ,
                  last_update_date = sysdate
            WHERE feature_type     = p_feature_type
              AND sv_sms_id        = l_sv_sms_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_sms_id.first..l_sv_sms_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_sms_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_sms_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

 EXCEPTION
    WHEN dup_val_on_index THEN
         null;
    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.SMS_MARK_FES_TO_DEPROVISION');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','UPD_FOR_SV_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

END SMS_MARK_FES_TO_DEPROVISION;

PROCEDURE SOA_SET_LOCKED_FLAG
 (P_PORTING_ID                   VARCHAR2
 ,P_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,P_LOCKED_FLAG                  VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,X_ERROR_CODE               OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN
 x_error_code := 0;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.locked_flag      = p_locked_flag,
                         soa.modified_date    = sysdate,
                         soa.last_updated_by  = fnd_global.user_id,
                         soa.last_update_date = sysdate
                   WHERE soa.sv_soa_id        = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );
EXCEPTION
     WHEN dup_val_on_index THEN
          null;
     WHEN NO_DATA_FOUND THEN
          x_error_code := SQLCODE;
          fnd_message.set_name('XNP','STD_ERROR');
          fnd_message.set_token('ERROR_LOCN','xnp_core.soa_set_locked_flag');
          fnd_message.set_token('ERROR_TEXT',SQLERRM);
          x_error_message := fnd_message.get;

          fnd_message.set_name('XNP','UPD_FOR_PORTING_ID_ERR');
          fnd_message.set_token('ERROR_TEXT',x_error_message);
          fnd_message.set_token('PORTING_ID',p_porting_id);
          x_error_message := fnd_message.get;

    WHEN OTHERS THEN
          x_error_code := SQLCODE;

          fnd_message.set_name('XNP','STD_ERROR');
          fnd_message.set_token('ERROR_LOCN','xnp_core.soa_set_locked_flag');
          fnd_message.set_token('ERROR_TEXT',SQLERRM);
          x_error_message := fnd_message.get;


END SOA_SET_LOCKED_FLAG;

PROCEDURE SOA_GET_LOCKED_FLAG
 (P_PORTING_ID        VARCHAR2
 ,P_LOCAL_SP_ID       NUMBER DEFAUlT NULL
 ,X_LOCKED_FLAG   OUT NOCOPY VARCHAR2
 ,X_ERROR_CODE    OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 )
IS

 CURSOR c_locked_flag IS
  SELECT locked_flag
    FROM xnp_sv_soa soa
   WHERE soa.object_reference = p_porting_id;

BEGIN
  x_error_code  := 0;
  x_locked_flag := 'Y';  -- intialized value

  -- Get the locked_flag corresponding to
  -- this porting_id

  OPEN c_locked_flag;
  FETCH c_locked_flag INTO x_locked_flag;

  IF c_locked_flag%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_locked_flag;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'xnp_core.soa_get_locked_flag');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','UPD_FOR_PORTING_ID_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      fnd_message.set_token('PORTING_ID',p_porting_id);
      x_error_message := fnd_message.get;

      IF c_locked_flag%ISOPEN THEN
       CLOSE c_locked_flag;
      END IF;

  WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','xnp_core.soa_get_locked_flag');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_locked_flag%ISOPEN THEN
       CLOSE c_locked_flag;
      END IF;


END SOA_GET_LOCKED_FLAG;

PROCEDURE SOA_GET_SV_STATUS
 (p_PORTING_ID                   VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,x_SV_STATUS OUT NOCOPY                VARCHAR2
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

CURSOR c_SV_STATUS IS
  SELECT status_type_code
    FROM xnp_sv_soa soa
   WHERE soa.object_reference=p_porting_id;

BEGIN
  x_error_code := 0;
  x_sv_status := NULL;

 OPEN c_sv_status;
 FETCH c_sv_status INTO x_sv_status;

 IF c_sv_status%NOTFOUND THEN
  raise NO_DATA_FOUND;
 END IF;

 CLOSE c_sv_status;

  EXCEPTION

  WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;
      x_sv_status := NULL;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'xnp_core.soa_get_sv_status');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','UPD_FOR_PORTING_ID_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      fnd_message.set_token('PORTING_ID',p_porting_id);
      x_error_message := fnd_message.get;

      IF c_sv_status%ISOPEN THEN
       CLOSE c_sv_status;
      END IF;

  WHEN OTHERS THEN
      x_error_code := SQLCODE;
      x_sv_status := NULL;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','xnp_core.soa_get_sv_status');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_sv_status%ISOPEN THEN
       CLOSE c_sv_status;
      END IF;

END SOA_GET_SV_STATUS ;

PROCEDURE SOA_CHECK_SV_STATUS
 (p_PORTING_ID                   VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,p_STATUS_TYPE_CODE             VARCHAR2
 ,x_STATUS_MATCHED_FLAG      OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

l_sv_status varchar2(40) := NULL;

BEGIN

  x_status_matched_flag := 'F'; -- default flag

  xnp_core.soa_get_sv_status
   (p_porting_id    => p_porting_id
   ,p_local_sp_id   => p_local_sp_id
   ,x_sv_status     => l_sv_status
   ,x_error_code    => x_error_code
   ,x_error_message => x_error_message
   );

   if ((x_error_code <> 0) OR (l_sv_status IS NULL)) then
     return;
   end if;

   if (l_sv_status = p_status_type_code) then
     x_status_matched_flag := 'T';
   end if;

END SOA_CHECK_SV_STATUS;

PROCEDURE SOA_SET_BLOCKED_FLAG
 (P_PORTING_ID                   VARCHAR2
 ,P_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,P_BLOCKED_FLAG                 VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,X_ERROR_CODE               OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN
 x_error_code := 0;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.blocked_flag     = p_blocked_flag,
                         soa.modified_date    = sysdate,
                         soa.last_updated_by  = fnd_global.user_id,
                         soa.last_update_date = sysdate
                   WHERE soa.sv_soa_id        = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                       (sv_order_mapping_id  ,
                        sv_soa_id            ,
                        order_id             ,
                        workitem_instance_id ,
                        created_by           ,
                        creation_date        ,
                        last_updated_by      ,
                        last_update_date
                       )
                       VALUES
                       (XNP_SV_ORDER_MAPPINGS_S.nextval,
                        l_sv_soa_id(i)            ,
                        p_order_id             ,
                        p_workitem_instance_id ,
                        fnd_global.user_id     ,
                        sysdate                ,
                        fnd_global.user_id     ,
                        sysdate
                       );

EXCEPTION
     WHEN dup_val_on_index THEN
          null;
     WHEN NO_DATA_FOUND THEN
          x_error_code := SQLCODE;
          fnd_message.set_name('XNP','STD_ERROR');
          fnd_message.set_token('ERROR_LOCN','xnp_core.soa_set_blocked_flag');
          fnd_message.set_token('ERROR_TEXT',SQLERRM);
          x_error_message := fnd_message.get;

          fnd_message.set_name('XNP','UPD_FOR_PORTING_ID_ERR');
          fnd_message.set_token('ERROR_TEXT',x_error_message);
          fnd_message.set_token('PORTING_ID',p_porting_id);
          x_error_message := fnd_message.get;

     WHEN OTHERS THEN
          x_error_code := SQLCODE;

          fnd_message.set_name('XNP','STD_ERROR');
          fnd_message.set_token('ERROR_LOCN','xnp_core.soa_set_blocked_flag');
          fnd_message.set_token('ERROR_TEXT',SQLERRM);
          x_error_message := fnd_message.get;

END SOA_SET_BLOCKED_FLAG;

PROCEDURE SOA_GET_BLOCKED_FLAG
 (p_porting_id        VARCHAR2
 ,p_local_sp_id       NUMBER DEFAULT NULL
 ,x_blocked_flag  OUT NOCOPY VARCHAR2
 ,x_error_code    OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
 )
IS

 CURSOR c_blocked_flag IS
  SELECT blocked_flag
    FROM xnp_sv_soa
   WHERE object_reference = p_porting_id;

BEGIN
  x_error_code   := 0;
  x_blocked_flag := 'Y';  -- intialized value

  -- Get the blocked_flag corresponding to
  -- this porting_id
  OPEN c_blocked_flag;
  FETCH c_blocked_flag INTO x_blocked_flag;

  IF c_blocked_flag%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_blocked_flag;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'xnp_core.soa_get_blocked_flag');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','UPD_FOR_PORTING_ID_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      fnd_message.set_token('PORTING_ID',p_porting_id);
      x_error_message := fnd_message.get;

      IF c_blocked_flag%ISOPEN THEN
       CLOSE c_blocked_flag;
      END IF;

  WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','xnp_core.soa_get_blocked_flag');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_blocked_flag%ISOPEN THEN
       CLOSE c_blocked_flag;
      END IF;


END SOA_GET_BLOCKED_FLAG;

PROCEDURE SOA_GET_NEW_SP_AUTH_FLAG
 (p_porting_id           VARCHAR2
 ,p_local_sp_id          NUMBER DEFAULT NULL
 ,x_new_sp_auth_flag OUT NOCOPY VARCHAR2
 ,x_error_code       OUT NOCOPY NUMBER
 ,x_error_message    OUT NOCOPY VARCHAR2
 )

IS
 CURSOR c_new_sp_auth_flag IS
  SELECT new_sp_authorization_flag
    FROM xnp_sv_soa
   WHERE object_reference = p_porting_id;

BEGIN
  x_error_code := 0;
  x_new_sp_auth_flag := 'Y';  -- intialized value

  -- Get the new_sp_auth_flag corresponding to
  -- this porting_id
  OPEN c_new_sp_auth_flag;
  FETCH c_new_sp_auth_flag INTO x_new_sp_auth_flag;

  IF c_new_sp_auth_flag%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_new_sp_auth_flag;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'xnp_core.soa_get_new_sp_auth_flag');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','UPD_FOR_PORTING_ID_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      fnd_message.set_token('PORTING_ID',p_porting_id);
      x_error_message := fnd_message.get;

      IF c_new_sp_auth_flag%ISOPEN THEN
       CLOSE c_new_sp_auth_flag;
      END IF;

  WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','xnp_core.soa_get_new_sp_auth_flag');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_new_sp_auth_flag%ISOPEN THEN
       CLOSE c_new_sp_auth_flag;
      END IF;

END SOA_GET_NEW_SP_AUTH_FLAG;

PROCEDURE SOA_GET_OLD_SP_AUTH_FLAG
 (p_porting_id           VARCHAR2
 ,p_local_sp_id          NUMBER DEFAULT NULL
 ,x_old_sp_auth_flag OUT NOCOPY VARCHAR2
 ,x_error_code       OUT NOCOPY NUMBER
 ,x_error_message    OUT NOCOPY VARCHAR2
 )

IS
 CURSOR c_old_sp_auth_flag IS
  SELECT old_sp_authorization_flag
    FROM xnp_sv_soa
   WHERE object_reference = p_porting_id;

BEGIN
  x_error_code := 0;
  x_old_sp_auth_flag := 'Y';  -- intialized value

  -- Get the old_sp_auth_flag corresponding to
  -- this porting_id
  OPEN c_old_sp_auth_flag;
  FETCH c_old_sp_auth_flag INTO x_old_sp_auth_flag;

  IF c_old_sp_auth_flag%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_old_sp_auth_flag;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'xnp_core.soa_get_old_sp_auth_flag');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','UPD_FOR_PORTING_ID_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      fnd_message.set_token('PORTING_ID',p_porting_id);
      x_error_message := fnd_message.get;

      IF c_old_sp_auth_flag%ISOPEN THEN
       CLOSE c_old_sp_auth_flag;
      END IF;

  WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','xnp_core.soa_get_old_sp_auth_flag');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_old_sp_auth_flag%ISOPEN THEN
       CLOSE c_old_sp_auth_flag;
      END IF;

END SOA_GET_OLD_SP_AUTH_FLAG;

PROCEDURE SOA_UPDATE_ACTIVATION_DUE_DATE
 (p_PORTING_ID                   VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,p_ACTIVATION_DUE_DATE          DATE
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

e_SOA_UPD_ACTIVATION_DUE_DATE exception;

BEGIN

 if(p_ACTIVATION_DUE_DATE = null) then
   raise e_SOA_UPD_ACTIVATION_DUE_DATE;
 end if;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.activation_due_date = p_activation_due_date  ,
                         soa.modified_date       = sysdate,
                         soa.last_updated_by     = fnd_global.user_id,
                         soa.last_update_date    = sysdate
                   WHERE soa.sv_soa_id           = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

 EXCEPTION
    WHEN dup_val_on_index THEN
         null;

    WHEN e_SOA_UPD_ACTIVATION_DUE_DATE THEN
      x_error_code := XNP_ERRORS.G_INVALID_DATE_FORMAT;
      fnd_message.set_name('XNP','INVALID_DATE_FORMAT_ERR');
      fnd_message.set_token('PORTING_ID',p_porting_id);

    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_ACTIVATION_DUE_DATE');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

END SOA_UPDATE_ACTIVATION_DUE_DATE;


PROCEDURE CHECK_IF_SP_ASSIGNED
 (p_STARTING_NUMBER IN    VARCHAR2
 ,p_ENDING_NUMBER IN      VARCHAR2
 ,p_SP_ID              IN NUMBER
 ,x_CHECK_IF_ASSIGNED OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE        OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE     OUT NOCOPY VARCHAR2
 )
IS
l_STARTING_NUMBER   VARCHAR2(80) := null;
l_ENDING_NUMBER     VARCHAR2(80) := null;
l_first_owner_sp    NUMBER := 0;
l_second_owner_sp   NUMBER := 0;
l_assigned_sp_id    NUMBER := 0;
l_rownum            NUMBER := 0;

 CURSOR c_RN_OWNER IS
 SELECT DISTINCT sp_id, rownum
   FROM xnp_routing_numbers rn ,
        xnp_sv_sms sms
  WHERE rn.routing_number_id = sms.routing_number_id
    AND sms.subscription_tn BETWEEN l_starting_number AND l_ending_number;

BEGIN
 x_error_code := 0;
 x_check_if_assigned := 'N';

 l_starting_number := p_starting_number;
 l_ending_number   := p_ending_number;

 -- The cursor must have just one row returned
  -- else it implies that more than one SPs have
  -- provisioned this number range
  -- So the second fetch should fail
  --
  OPEN c_rn_owner;
  FETCH c_rn_owner INTO l_first_owner_sp, l_rownum;
  IF c_rn_owner%NOTFOUND THEN

    -- If no entries in SV_SMS table
    -- The check if the local sp is the assigned sp

    XNP_CORE.GET_ASSIGNED_SP_ID
     (l_starting_number
     ,l_ending_number
     ,l_assigned_sp_id
     ,x_error_code
     ,x_error_message
     );

    IF x_error_code <> 0  THEN
       close c_rn_owner;
       return;
    END IF;

    IF (p_sp_id = l_assigned_sp_id) THEN
      x_check_if_assigned := 'Y';
    ELSE
      x_check_if_assigned := 'N';
    END IF;

    close c_rn_owner;
    return;

  END IF;

  -- Check if there is a more than 1 SP which has provisioned
  -- the number range
  IF (l_rownum < 2) THEN
    -- then Only 1 SP has provisioned the entire range
    -- Check if this only owner (first) is the local SP

    IF (l_first_owner_sp = p_sp_id) THEN
      x_check_if_assigned := 'Y';
    ELSE
      x_check_if_assigned := 'N';
    END IF;
  ELSE
    -- More than one SPs have provisioned this TN range
    -- So the local SP can't port out the entire range
    x_check_if_assigned := 'N';
  END IF;

  IF c_rn_owner%ISOPEN THEN
    CLOSE c_rn_owner;
  END IF;
  return;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_ERROR_CODE := SQLCODE;

      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token('FAILED_PROC','XNP_CORE.CHECK_IF_SP_ASSIGNED');
      fnd_message.set_token('ATTRNAME','SP_ID');
      fnd_message.set_token('KEY','SP_ID');
      fnd_message.set_token('VALUE',to_char(p_SP_ID));
      x_error_message := fnd_message.get;
      x_ERROR_MESSAGE := x_error_message||':'||SQLERRM;

      fnd_message.set_name('XNP','CHECK_IF_SP_ASSIGNED_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;

      IF c_rn_owner%ISOPEN THEN
       CLOSE c_rn_owner;
      END IF;

    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.CHECK_IF_SP_ASSIGNED');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_rn_owner%ISOPEN THEN
       CLOSE c_rn_owner;
      END IF;

END CHECK_IF_SP_ASSIGNED;

PROCEDURE SOA_UPDATE_NOTES_INFO
 (p_PORTING_ID                   VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,p_COMMENTS                     VARCHAR2
 ,p_NOTES                        VARCHAR2
 ,p_PREORDER_AUTHORIZATION_CODE  VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;


BEGIN

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.comments                    = p_comments ,
                         soa.notes                       = p_notes ,
                         soa.preorder_authorization_code = p_preorder_authorization_code,
                         soa.modified_date               = sysdate,
                         last_updated_by                 = fnd_global.user_id,
                         last_update_date                = sysdate
                   WHERE soa.sv_soa_id                   = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );
  EXCEPTION
       WHEN dup_val_on_index THEN
            null;
       WHEN NO_DATA_FOUND THEN
            x_error_code := SQLCODE;
            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','xnp_core.soa_update_notes_info');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

            fnd_message.set_name('XNP','UPD_FOR_PORTING_ID_ERR');
            fnd_message.set_token('ERROR_TEXT',x_error_message);
            fnd_message.set_token('PORTING_ID',p_porting_id);
            x_error_message := fnd_message.get;

        WHEN OTHERS THEN
            x_error_code := SQLCODE;

            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','xnp_core.soa_update_notes_info');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get      ;

END SOA_UPDATE_NOTES_INFO;

PROCEDURE SOA_UPDATE_NETWORK_INFO
 (p_PORTING_ID                   VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,p_ROUTING_NUMBER_ID            NUMBER
 ,p_CNAM_ADDRESS                 VARCHAR2
 ,p_CNAM_SUBSYSTEM               VARCHAR2
 ,p_ISVM_ADDRESS                 VARCHAR2
 ,p_ISVM_SUBSYSTEM               VARCHAR2
 ,p_LIDB_ADDRESS                 VARCHAR2
 ,p_LIDB_SUBSYSTEM               VARCHAR2
 ,p_CLASS_ADDRESS                VARCHAR2
 ,p_CLASS_SUBSYSTEM              VARCHAR2
 ,p_WSMSC_ADDRESS                VARCHAR2
 ,p_WSMSC_SUBSYSTEM              VARCHAR2
 ,p_RN_ADDRESS                   VARCHAR2
 ,p_RN_SUBSYSTEM                 VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.routing_number_id = p_routing_number_id ,
                         soa.cnam_address      = p_cnam_address     ,
                         soa.cnam_subsystem    = p_cnam_subsystem   ,
                         soa.isvm_address      = p_isvm_address     ,
                         soa.isvm_subsystem    = p_isvm_subsystem   ,
                         soa.lidb_address      = p_lidb_address     ,
                         soa.lidb_subsystem    = p_lidb_subsystem   ,
                         soa.class_address     = p_class_address    ,
                         soa.class_subsystem   = p_class_subsystem  ,
                         soa.wsmsc_address     = p_wsmsc_address    ,
                         soa.wsmsc_subsystem   = p_wsmsc_subsystem  ,
                         soa.rn_address        = p_rn_address       ,
                         soa.rn_subsystem      = p_rn_subsystem     ,
                         soa.modified_date     = sysdate            ,
                         soa.last_updated_by   = fnd_global.user_id ,
                         soa.last_update_date  = sysdate
                   WHERE soa.sv_soa_id         = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
     WHEN dup_val_on_index THEN
          null;
       WHEN NO_DATA_FOUND THEN
            x_error_code := SQLCODE;
            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','xnp_core.soa_update_network_info');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

            fnd_message.set_name('XNP','UPD_FOR_PORTING_ID_ERR');
            fnd_message.set_token('ERROR_TEXT',x_error_message);
            fnd_message.set_token('PORTING_ID',p_porting_id);
            x_error_message := fnd_message.get;

        WHEN OTHERS THEN
            x_error_code := SQLCODE;

            fnd_message.set_name('XNP','STD_ERROR');
            fnd_message.set_token('ERROR_LOCN','xnp_core.soa_update_network_info');
            fnd_message.set_token('ERROR_TEXT',SQLERRM);
            x_error_message := fnd_message.get;

END SOA_UPDATE_NETWORK_INFO;

PROCEDURE SOA_UPDATE_CUSTOMER_INFO
 (p_PORTING_ID                   VARCHAR2
 ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,p_CUSTOMER_ID                  VARCHAR2
 ,p_CUSTOMER_NAME                VARCHAR2
 ,p_CUSTOMER_TYPE                VARCHAR2
 ,p_ADDRESS_LINE1                VARCHAR2
 ,p_ADDRESS_LINE2                VARCHAR2
 ,p_CITY                         VARCHAR2
 ,p_PHONE                        VARCHAR2
 ,p_FAX                          VARCHAR2
 ,p_EMAIL                        VARCHAR2
 ,p_PAGER                        VARCHAR2
 ,p_PAGER_PIN                    VARCHAR2
 ,p_INTERNET_ADDRESS             VARCHAR2
 ,p_ZIP_CODE                     VARCHAR2
 ,p_COUNTRY                      VARCHAR2
 ,p_CUSTOMER_CONTACT_REQ_FLAG    VARCHAR2
 ,p_CONTACT_NAME                 VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;


BEGIN

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.customer_id               = p_customer_id ,
                         soa.customer_name             = p_customer_name ,
                         soa.customer_type             = p_customer_type ,
                         soa.address_line1             = p_address_line1 ,
                         soa.address_line2             = p_address_line2 ,
                         soa.city                      = p_city ,
                         soa.phone                     = p_phone ,
                         soa.fax                       = p_fax ,
                         soa.email                     = p_email ,
                         soa.zip_code                  = p_zip_code ,
                         soa.country                   = p_country ,
                         soa.customer_contact_req_flag = p_customer_contact_req_flag ,
                         soa.contact_name              = p_contact_name ,
                         soa.pager                     = p_pager ,
                         soa.pager_pin                 = p_pager_pin ,
                         soa.internet_address          = p_internet_address ,
                         soa.modified_date             = sysdate,
                         soa.last_updated_by           = fnd_global.user_id,
                         soa.last_update_date          = sysdate
                   WHERE soa.sv_soa_id                 = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

  EXCEPTION
     WHEN dup_val_on_index THEN
          null;
  WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'xnp_core.soa_update_customer_info');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','UPD_FOR_PORTING_ID_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      fnd_message.set_token('PORTING_ID',p_porting_id);
      x_error_message := fnd_message.get;

  WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','xnp_core.soa_update_customer_info');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

END SOA_UPDATE_CUSTOMER_INFO;


PROCEDURE SOA_UPDATE_PORTING_ID
   (p_STARTING_NUMBER              VARCHAR2
   ,p_ENDING_NUMBER                VARCHAR2
   ,p_CUR_STATUS_TYPE_CODE         VARCHAR2
   ,p_LOCAL_SP_ID                  NUMBER DEFAULT NULL
   ,p_PORTING_ID                   VARCHAR2
   ,p_ORDER_ID                     NUMBER
   ,p_LINEITEM_ID              IN  NUMBER
   ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
   ,p_FA_INSTANCE_ID           IN  NUMBER
   ,x_ERROR_CODE               OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
   )
IS

  l_SV_ID number :=0;
  l_PHASE_INDICATOR varchar2(200) := null;
  l_STARTING_NUMBER VARCHAR2(80) := null;
  l_ENDING_NUMBER VARCHAR2(80) := null;
  e_UPDATE_PORTING_ID exception;

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN
  x_ERROR_CODE := 0;

  l_starting_number := p_starting_number;
  l_ending_number   := p_ending_number;

  -- Get the phase corresponding to this 'p_CUR_STATUS_TYPE_CODE'

  XNP_CORE.GET_PHASE_FOR_STATUS
   (p_CUR_STATUS_TYPE_CODE
   ,l_PHASE_INDICATOR
   ,x_ERROR_CODE
   ,x_ERROR_MESSAGE
   );
  IF x_ERROR_CODE <> 0
  THEN
    RETURN;
  END IF;

  --
   -- For each TN Get the SVid which is in this phase
   -- and update the porting id
   --
           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa,
                  xnp_sv_status_types_b sta
            WHERE soa.subscription_tn   BETWEEN l_starting_number AND l_ending_number
              AND sta.phase_indicator  = l_phase_indicator
              AND sta.status_type_code = soa.status_type_code;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.object_reference = p_porting_id,
                         soa.modified_date    = sysdate,
                         soa.last_updated_by  = fnd_global.user_id,
                         soa.last_update_date = sysdate
                   WHERE soa.sv_soa_id        = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

    -- Update the order header with the porting id

    xdp_engine.set_order_reference
	(p_order_id		=>p_order_id
	,p_order_ref_name	=>'PORTING_ID'
	,p_order_ref_value	=>p_porting_id
	,x_return_code		=>x_error_code
	,x_error_description	=>x_error_message
	);

    IF (x_error_code <> 0) THEN
	RAISE e_UPDATE_PORTING_ID;
    END IF;


  EXCEPTION
     WHEN dup_val_on_index THEN
          null;
    WHEN NO_DATA_FOUND THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token('FAILED_PROC','XNP_CORE.SOA_UPDATE_PORTING_ID');
      fnd_message.set_token('ATTRNAME','PORTING_ID:ORDER_ID');
      fnd_message.set_token('KEY','ORDER_ID:PORTING_ID');
      fnd_message.set_token('VALUE',to_char(p_order_id)||':'||p_porting_id);
      x_error_message := fnd_message.get;
      x_ERROR_MESSAGE := x_error_message||':'||SQLERRM;

    WHEN OTHERS THEN
      x_ERROR_CODE := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'XNP_CORE.SOA_UPDATE_PORTING_ID');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

END SOA_UPDATE_PORTING_ID;

PROCEDURE SMS_UPDATE_PROV_DONE_DATE
   (p_STARTING_NUMBER              VARCHAR2
   ,p_ENDING_NUMBER                VARCHAR2
   ,p_ORDER_ID                 IN  NUMBER
   ,p_LINEITEM_ID              IN  NUMBER
   ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
   ,p_FA_INSTANCE_ID           IN  NUMBER
   ,x_ERROR_CODE               OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_sms_id_tab IS TABLE OF NUMBER;
  l_sv_sms_id           SV_SMS_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN

           SELECT sv_sms_id  BULK COLLECT
             INTO l_sv_sms_id
             FROM xnp_sv_sms sms
            WHERE sms.subscription_tn   BETWEEN p_starting_number AND p_ending_number  ;

           FORALL i IN l_sv_sms_id.first..l_sv_sms_id.last

                  UPDATE xnp_sv_sms sms
	             SET sms.provision_done_date = sysdate,
                         sms.last_updated_by     = fnd_global.user_id,
                         sms.last_update_date    = sysdate
                   WHERE sms.sv_sms_id           = l_sv_sms_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_sms_id.first..l_sv_sms_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_sms_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_sms_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

EXCEPTION
    WHEN dup_val_on_index THEN
         null;
    WHEN OTHERS THEN

   x_error_code := SQLCODE;
   x_error_message := SQLERRM;

END SMS_UPDATE_PROV_DONE_DATE;

-- Check whether Routing Number belongs to Recipient SP

PROCEDURE CHECK_RN_FOR_RECIPIENT
 (p_RECIPIENT_SP_ID IN NUMBER
 ,p_ROUTING_NUMBER_ID IN NUMBER
 ,x_ERROR_CODE OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 )
IS
   l_dummy VARCHAR2(1):=Null;

CURSOR c_rn_for_recipient IS
   SELECT '1'
     FROM XNP_ROUTING_NUMBERS
    WHERE routing_number_id = p_ROUTING_NUMBER_ID
      AND sp_id = p_RECIPIENT_SP_ID
      AND active_flag='Y';


BEGIN
 x_ERROR_CODE:=0;


   OPEN c_rn_for_recipient;
  FETCH c_rn_for_recipient INTO l_dummy;

  IF c_rn_for_recipient%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_rn_for_recipient;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_GET_FAILED');
      fnd_message.set_token('FAILED_PROC','XNP_CORE.CHECK_RN_FOR_RECIPIENT');
      fnd_message.set_token('ATTRNAME','ROUTING_NUMBER_ID');
      fnd_message.set_token('KEY','ROUTING_NUMBER_ID');
      fnd_message.set_token('VALUE' ,to_char(p_ROUTING_NUMBER_ID));
      x_error_message := fnd_message.get;
      x_error_message := x_error_message||':'||SQLERRM;

      fnd_message.set_name('XNP','CHECK_RN_FOR_RECIPIENT');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      x_error_message := fnd_message.get;


      IF c_rn_for_recipient%ISOPEN THEN
       CLOSE c_rn_for_recipient;
      END IF;

    WHEN OTHERS THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.CHECK_RN_FOR_RECIPIENT');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_rn_for_recipient%ISOPEN THEN
       CLOSE c_rn_for_recipient;
      END IF;

END CHECK_RN_FOR_RECIPIENT;

-- Runtime Validation Check for Np Work Item

PROCEDURE RUNTIME_VALIDATION
( p_ORDER_ID             IN NUMBER
 ,p_LINE_ITEM_ID         IN NUMBER
 ,p_WORKITEM_INSTANCE_ID IN NUMBER
 ,p_STARTING_NUMBER      IN NUMBER
 ,p_ENDING_NUMBER        IN NUMBER
 ,p_ROUTING_NUMBER       IN VARCHAR2
 ,p_DONOR_SP_CODE        IN VARCHAR2
 ,p_RECIPIENT_SP_CODE    IN VARCHAR2
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 )
 IS
    l_ERROR_MESSAGE     VARCHAR2(2000) := NULL;
    l_NUMBER_RANGE_ID   NUMBER :=0;
    l_ROUTING_NUMBER_ID NUMBER :=0;
    l_RECIPIENT_SP_ID   NUMBER :=0;
    l_DONOR_SP_ID       NUMBER := 0;

BEGIN
--   Get the routing_number_id corresponding to the code

     GET_ROUTING_NUMBER_ID
      (p_ROUTING_NUMBER   =>p_ROUTING_NUMBER
      ,x_ROUTING_NUMBER_ID=>l_ROUTING_NUMBER_ID
      ,x_ERROR_CODE       =>x_ERROR_CODE
      ,x_ERROR_MESSAGE    =>x_ERROR_MESSAGE
      );

  IF (x_error_code <> 0) THEN
     l_error_message:= FND_GLOBAL.NEWLINE|| l_error_message||x_error_message;

  END IF;

-- Get the SP id for this recipient code
   GET_SP_ID
   (p_SP_NAME       => p_RECIPIENT_SP_CODE
   ,x_SP_ID         => l_RECIPIENT_SP_ID
   ,x_ERROR_CODE    => x_ERROR_CODE
   ,x_ERROR_MESSAGE => x_ERROR_MESSAGE
   );

  IF x_ERROR_CODE <> 0  THEN
     l_error_message:=FND_GLOBAL.NEWLINE||l_error_message||x_error_message;
  END IF;

--Check for RN belongs to Recipient
  IF l_ROUTING_NUMBER_ID<>0 AND l_RECIPIENT_SP_ID <>0 THEN
      CHECK_RN_FOR_RECIPIENT( p_RECIPIENT_SP_ID   =>l_RECIPIENT_SP_ID
			     ,p_ROUTING_NUMBER_ID =>l_ROUTING_NUMBER_ID
 			     ,x_ERROR_CODE        =>x_ERROR_CODE
                             ,x_ERROR_MESSAGE     =>x_ERROR_MESSAGE
                             );


    IF x_ERROR_CODE <> 0  THEN
      l_error_message:= FND_GLOBAL.NEWLINE||l_error_message||x_error_message;
    END IF;
  END IF;


-- Verify if its a valid number range

               get_number_range_id(p_STARTING_NUMBER => p_STARTING_NUMBER,
				   p_ENDING_NUMBER   => p_ENDING_NUMBER,
				   x_NUMBER_RANGE_ID => l_NUMBER_RANGE_ID,
				   x_error_code      => x_error_code,
				   x_error_message   => x_error_message
				);
  IF (x_error_code <> 0) THEN
      l_error_message:=FND_GLOBAL.NEWLINE|| l_error_message||x_error_message;

  END IF;


  -- Get the SP id for this SP code
   GET_SP_ID
     (p_SP_NAME     =>p_DONOR_SP_CODE
     ,x_SP_ID  =>l_DONOR_SP_ID
     ,x_ERROR_CODE=>x_ERROR_CODE
     ,x_ERROR_MESSAGE=>x_ERROR_MESSAGE
    );

  IF x_ERROR_CODE <> 0  THEN

   l_error_message:= FND_GLOBAL.NEWLINE|| l_error_message||x_error_message;
 END IF;


-- Return x_error code and x_error_message
  IF l_error_message is NOT NULL THEN
   FND_MESSAGE.SET_NAME('XNP','XNP_RVU_VALIDATION_FAILED');
   FND_MESSAGE.SET_TOKEN('ORDER_ID',xdp_order.G_external_order_reference);
   FND_MESSAGE.SET_TOKEN('WORKITEM_NAME',XDP_OA_UTIL.g_Workitem_Name);
   FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_error_message);
   x_error_message:= SUBSTR(FND_MESSAGE.GET,1,4000); -- rnyberg 01/26/2001. Added substr since max 4000 chars can be handled in parameter. To fix bug 1580568.
   X_ERROR_CODE:= -( FND_MESSAGE.GET_NUMBER('XNP',
                                             'XNP_RVU_VALIDATION_FAILED'));
  END IF;

EXCEPTION
 WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','XNP_CORE.RUNTIME_VALIDATION');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;


End RUNTIME_VALIDATION;

-- Procedure to create record in XNP_SV_ORDER_MAPPING

PROCEDURE CREATE_ORDER_MAPPING
          (p_ORDER_ID             IN NUMBER,
           p_LINEITEM_ID          IN NUMBER,
           p_WORKITEM_INSTANCE_ID IN NUMBER,
           p_FA_INSTANCE_ID       IN NUMBER,
           p_SV_SOA_ID            IN NUMBER,
           p_SV_SMS_ID            IN NUMBER,
           x_ERROR_CODE           OUT NOCOPY NUMBER,
           x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
          ) IS

l_error_message         VARCHAR2(2000) := NULL;
l_sv_order_mapping_id   NUMBER;

BEGIN

 INSERT INTO XNP_SV_ORDER_MAPPINGS
        (sv_order_mapping_id  ,
         sv_soa_id            ,
         sv_sms_id            ,
         order_id             ,
         workitem_instance_id ,
         created_by           ,
         creation_date        ,
         last_updated_by      ,
         last_update_date
        )
        VALUES
        (XNP_SV_ORDER_MAPPINGS_S.nextval,
         p_sv_soa_id            ,
         p_sv_sms_id            ,
         p_order_id             ,
         p_workitem_instance_id ,
         fnd_global.user_id     ,
         sysdate                ,
         fnd_global.user_id     ,
         sysdate
        );

EXCEPTION
     WHEN dup_val_on_index THEN
          null;
     WHEN others THEN
          x_error_code := sqlcode;
          fnd_message.set_name('XNP','STD ERROR');
          fnd_message.set_token('ERROR_LOCN','XNP_CORE.CREATE_ORDER_MAPPING');
          fnd_message.set_token('ERROR_TEXT',SQLERRM);
          x_error_message := fnd_message.get;

END CREATE_ORDER_MAPPING;

PROCEDURE SOA_UPDATE_DISCONN_DUE_DATE
 (p_PORTING_ID                   VARCHAR2
 ,p_DISCONNECT_DUE_DATE          DATE
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

e_SOA_UPDATE_DISCON_DUE_DATE exception;

BEGIN

 if(p_disconnect_due_date = null) then
   raise e_SOA_UPDATE_DISCON_DUE_DATE;
 end if;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.disconnect_due_date  = p_disconnect_due_date,
                         soa.modified_date        = sysdate,
                         soa.last_updated_by      = fnd_global.user_id,
                         soa.last_update_date     = sysdate
                   WHERE soa.sv_soa_id            = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

 EXCEPTION
      WHEN dup_val_on_index THEN
            null;
      WHEN e_SOA_UPDATE_DISCON_DUE_DATE THEN
           x_error_code := XNP_ERRORS.G_INVALID_DATE_FORMAT;
           fnd_message.set_name('XNP','INVALID_DATE_FORMAT_ERR');
           fnd_message.set_token('PORTING_ID',p_porting_id);
      WHEN OTHERS THEN
           x_ERROR_CODE := SQLCODE;
           fnd_message.set_name('XNP','STD_ERROR');
           fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_DISCONNECT_DUE_DATE');
           fnd_message.set_token('ERROR_TEXT',SQLERRM);
           x_error_message := fnd_message.get;

END SOA_UPDATE_DISCONN_DUE_DATE;


PROCEDURE SOA_UPDATE_EFFECT_REL_DUE_DATE
 (p_PORTING_ID                   VARCHAR2
 ,p_EFFECTIVE_RELEASE_DUE_DATE   DATE
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

e_SOA_UPDATE_EFF_REL_DUE_DATE exception;

BEGIN

 if(p_EFFECTIVE_RELEASE_DUE_DATE = null) then
   raise e_SOA_UPDATE_EFF_REL_DUE_DATE;
 end if;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.effective_release_due_date  = p_effective_release_due_date,
                         soa.modified_date               = sysdate,
                         soa.last_updated_by             = fnd_global.user_id,
                         soa.last_update_date            = sysdate
                   WHERE soa.sv_soa_id                   = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

 EXCEPTION
      WHEN dup_val_on_index THEN
            null;
      WHEN e_SOA_UPDATE_EFF_REL_DUE_DATE THEN
           x_error_code := XNP_ERRORS.G_INVALID_DATE_FORMAT;
           fnd_message.set_name('XNP','INVALID_DATE_FORMAT_ERR');
           fnd_message.set_token('PORTING_ID',p_porting_id);
      WHEN OTHERS THEN
           x_ERROR_CODE := SQLCODE;
           fnd_message.set_name('XNP','STD_ERROR');
           fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_UPDATE_EFFECT_REL_DUE_DATE');
           fnd_message.set_token('ERROR_TEXT',SQLERRM);
           x_error_message := fnd_message.get;

END SOA_UPDATE_EFFECT_REL_DUE_DATE;

PROCEDURE SOA_UPDATE_NUM_RETURN_DUE_DATE
 (p_PORTING_ID                   VARCHAR2
 ,p_NUMBER_RETURNED_DUE_DATE     DATE
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,x_ERROR_CODE               OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

e_SOA_UPDATE_NUM_RET_DUE_DATE exception;

BEGIN

 if(p_NUMBER_RETURNED_DUE_DATE = null) then
   raise e_SOA_UPDATE_NUM_RET_DUE_DATE;
 end if;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.NUMBER_RETURNED_DUE_DATE  = p_NUMBER_RETURNED_DUE_DATE,
                         soa.modified_date               = sysdate,
                         soa.last_updated_by             = fnd_global.user_id,
                         soa.last_update_date            = sysdate
                   WHERE soa.sv_soa_id                   = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );

 EXCEPTION
      WHEN dup_val_on_index THEN
            null;
      WHEN e_SOA_UPDATE_NUM_RET_DUE_DATE THEN
           x_error_code := XNP_ERRORS.G_INVALID_DATE_FORMAT;
           fnd_message.set_name('XNP','INVALID_DATE_FORMAT_ERR');
           fnd_message.set_token('PORTING_ID',p_porting_id);
      WHEN OTHERS THEN
           x_ERROR_CODE := SQLCODE;
           fnd_message.set_name('XNP','STD_ERROR');
           fnd_message.set_token('ERROR_LOCN','XNP_CORE.SOA_NUM_RETURN_DUE_DATE');
           fnd_message.set_token('ERROR_TEXT',SQLERRM);
           x_error_message := fnd_message.get;

END SOA_UPDATE_NUM_RETURN_DUE_DATE;

PROCEDURE SOA_SET_CONCURRENCE_FLAG
 (P_PORTING_ID                   VARCHAR2
 ,P_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,P_CONCURRENCE_FLAG             VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,X_ERROR_CODE               OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 )
IS

  TYPE sv_soa_id_tab IS TABLE OF NUMBER;
  l_sv_soa_id           SV_SOA_ID_TAB;
  i                     BINARY_INTEGER;

BEGIN
 x_error_code := 0;

           SELECT sv_soa_id  BULK COLLECT
             INTO l_sv_soa_id
             FROM xnp_sv_soa soa
            WHERE soa.object_reference = p_porting_id;

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last

                  UPDATE xnp_sv_soa soa
                     SET soa.concurrence_flag = p_concurrence_flag,
                         soa.modified_date    = sysdate,
                         soa.last_updated_by  = fnd_global.user_id,
                         soa.last_update_date = sysdate
                   WHERE soa.sv_soa_id        = l_sv_soa_id(i);

                  -- Create a mapping record in XNP_SV_ORDER_MAPPINGS table

           FORALL i IN l_sv_soa_id.first..l_sv_soa_id.last


                  INSERT INTO XNP_SV_ORDER_MAPPINGS
                         (sv_order_mapping_id  ,
                          sv_soa_id            ,
                          order_id             ,
                          workitem_instance_id ,
                          created_by           ,
                          creation_date        ,
                          last_updated_by      ,
                          last_update_date
                         )
                         VALUES
                         (XNP_SV_ORDER_MAPPINGS_S.nextval,
                          l_sv_soa_id(i)            ,
                          p_order_id             ,
                          p_workitem_instance_id ,
                          fnd_global.user_id     ,
                          sysdate                ,
                          fnd_global.user_id     ,
                          sysdate
                         );
EXCEPTION
     WHEN dup_val_on_index THEN
          null;
     WHEN NO_DATA_FOUND THEN
          x_error_code := SQLCODE;
          fnd_message.set_name('XNP','STD_ERROR');
          fnd_message.set_token('ERROR_LOCN','xnp_core.soa_set_concurrence_flag');
          fnd_message.set_token('ERROR_TEXT',SQLERRM);
          x_error_message := fnd_message.get;

          fnd_message.set_name('XNP','UPD_FOR_PORTING_ID_ERR');
          fnd_message.set_token('ERROR_TEXT',x_error_message);
          fnd_message.set_token('PORTING_ID',p_porting_id);
          x_error_message := fnd_message.get;

    WHEN OTHERS THEN
          x_error_code := SQLCODE;

          fnd_message.set_name('XNP','STD_ERROR');
          fnd_message.set_token('ERROR_LOCN','xnp_core.soa_set_concurrence_flag');
          fnd_message.set_token('ERROR_TEXT',SQLERRM);
          x_error_message := fnd_message.get;

END SOA_SET_CONCURRENCE_FLAG;

PROCEDURE SOA_GET_CONCURRENCE_FLAG
 (P_PORTING_ID        VARCHAR2
 ,P_LOCAL_SP_ID       NUMBER DEFAUlT NULL
 ,X_CONCURRENCE_FLAG   OUT NOCOPY VARCHAR2
 ,X_ERROR_CODE    OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 )
IS

 CURSOR c_concurrence_flag IS
  SELECT concurrence_flag
    FROM xnp_sv_soa soa
   WHERE soa.object_reference = p_porting_id;

BEGIN
  x_error_code  := 0;
  x_concurrence_flag := 'Y';  -- intialized value

  -- Get the concurrence_flag corresponding to
  -- this porting_id

  OPEN c_concurrence_flag;
  FETCH c_concurrence_flag INTO x_concurrence_flag;

  IF c_concurrence_flag%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;

  CLOSE c_concurrence_flag;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      x_error_code := SQLCODE;
      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN'
       ,'xnp_core.soa_get_concurrence_flag');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      fnd_message.set_name('XNP','UPD_FOR_PORTING_ID_ERR');
      fnd_message.set_token('ERROR_TEXT',x_error_message);
      fnd_message.set_token('PORTING_ID',p_porting_id);
      x_error_message := fnd_message.get;

      IF c_concurrence_flag%ISOPEN THEN
       CLOSE c_concurrence_flag;
      END IF;

  WHEN OTHERS THEN
      x_error_code := SQLCODE;

      fnd_message.set_name('XNP','STD_ERROR');
      fnd_message.set_token('ERROR_LOCN','xnp_core.soa_get_concurrence_flag');
      fnd_message.set_token('ERROR_TEXT',SQLERRM);
      x_error_message := fnd_message.get;

      IF c_concurrence_flag%ISOPEN THEN
       CLOSE c_concurrence_flag;
      END IF;

END SOA_GET_CONCURRENCE_FLAG;

BEGIN
BEGIN

FND_PROFILE.GET(name => 'ENABLE_NRC',
                 val => g_enable_nrc_flag);

FND_PROFILE.GET(name => 'DEFAULT_PORTING_STATUS',
                 val => g_default_porting_status);

END;

END XNP_CORE;

/
