--------------------------------------------------------
--  DDL for Package Body CN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_API" as
/* $Header: cnputilb.pls 120.11.12010000.12 2009/10/15 10:25:32 ramchint ship $ */



  TYPE salesrep_cache_rec_type IS RECORD(
    salesrep_id       NUMBER
  , period_id         NUMBER
  , role_name         VARCHAR2(2000)
  );


  /**
   * PLSQL Index By Table Type to contain information about many Resources
   * where each element is of type RESOURCE_CACHE_REC_TYPE.
   */
  TYPE salesrep_cache_tbl_type IS TABLE OF salesrep_cache_rec_type
    INDEX BY BINARY_INTEGER;

  g_salesrep_info_cache           salesrep_cache_tbl_type;



   g_user_tab jtf_number_table;

--| ----------------------------------------------------------------------+
--|   Procedure Name :  get_fnd_message
--| ----------------------------------------------------------------------+
PROCEDURE get_fnd_message( p_msg_count NUMBER,
                           p_msg_data  VARCHAR2)  IS

     l_msg_count         NUMBER;
     l_msg_data          VARCHAR2(2000);

BEGIN
   IF (p_msg_count IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  l_msg_count ,
   p_data    =>  l_msg_data   ,
   p_encoded =>  FND_API.G_FALSE
   );
    ELSE
      l_msg_count := p_msg_count;
      l_msg_data  := p_msg_data;
   END IF;

   IF l_msg_count = 1 THEN
      cn_message_pkg.debug(substrb(l_msg_data,1,240));
    ELSIF l_msg_count = 0 THEN
      cn_message_pkg.debug('No Message');
    ELSE
      FOR ctr IN 1..l_msg_count LOOP
         cn_message_pkg.debug
     (substrb((FND_MSG_PUB.get
         (p_msg_index => ctr, p_encoded   => FND_API.G_FALSE)),
        1,
        240)
      );
      END LOOP ;
   END IF;

   cn_message_pkg.flush;

   FND_MSG_PUB.initialize;

END get_fnd_message;

--| ----------------------------------------------------------------------+
--|   Function Name :  get_rate_table_name
--| ----------------------------------------------------------------------+
FUNCTION  get_rate_table_name( p_rate_table_id  NUMBER)
  RETURN cn_rate_schedules.name%TYPE IS

   l_rs_name      cn_rate_schedules.name%TYPE;

BEGIN
   SELECT name INTO l_rs_name
     FROM cn_rate_schedules_all
     WHERE rate_schedule_id = p_rate_table_id;

   RETURN l_rs_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_rate_table_name;

--| ----------------------------------------------------------------------+
--|   Function Name :  get_rate_table_id
--| ----------------------------------------------------------------------+
FUNCTION  get_rate_table_id( p_rate_table_name  VARCHAR2,
                             p_org_id NUMBER)
  RETURN cn_rate_schedules.rate_schedule_id%TYPE IS

   l_rs_id      cn_rate_schedules.rate_schedule_id%TYPE;

BEGIN
   SELECT rate_schedule_id INTO l_rs_id
     FROM cn_rate_schedules_all
     WHERE name = p_rate_table_name
       AND org_id = p_org_id;

   RETURN l_rs_id;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_rate_table_id;


--| ----------------------------------------------------------------------+
--|   Function Name :  get_period_name  -- only get active periods
--| ----------------------------------------------------------------------+
FUNCTION  get_period_name( p_period_id  NUMBER, p_org_id NUMBER)
  RETURN cn_periods.period_name%TYPE IS

  l_period_name cn_periods.period_name%TYPE;

BEGIN
   SELECT period_name
     INTO l_period_name
     FROM cn_period_statuses_all
     WHERE period_id = p_period_id
     AND org_id = p_org_id
     AND period_status IN ('F', 'O');

   RETURN l_period_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_period_name;

--| ----------------------------------------------------------------------+
--|   Function Name :  get_period_id -- only get active periods
--| ----------------------------------------------------------------------+
FUNCTION  get_period_id( p_period_name  VARCHAR2, p_org_id NUMBER)
  RETURN cn_periods.period_id%TYPE IS

  l_period_id cn_periods.period_id%TYPE;

BEGIN
   SELECT period_id
     INTO l_period_id
     FROM cn_period_statuses_all
     WHERE Upper(period_name) = Upper(p_period_name)
     AND org_id = p_org_id
     AND period_status IN ('F', 'O');

   RETURN l_period_id;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_period_id;

--| ---------------------------------------------------------------------+
--| Function Name :  get_rev_class_id
--| Desc : Pass in revenue class name then return revenue class id
--| ---------------------------------------------------------------------+
FUNCTION  get_rev_class_id( p_rev_class_name  VARCHAR2, p_org_id NUMBER)
  RETURN cn_revenue_classes.revenue_class_id%TYPE IS

     l_rev_class_id cn_revenue_classes.revenue_class_id%TYPE;

BEGIN
   SELECT revenue_class_id
     INTO l_rev_class_id
     FROM cn_revenue_classes_all
     WHERE name = p_rev_class_name
     AND org_id = p_org_id
     ;
   RETURN l_rev_class_id;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_rev_class_id;

--| -----------------------------------------------------------------------+
--| Function Name :  get_rev_class_name
--| Desc : Pass in revenue class name then return revenue class id
--| ---------------------------------------------------------------------+
FUNCTION  get_rev_class_name( p_rev_class_id  NUMBER)
  RETURN cn_revenue_classes.name%TYPE IS

     l_rev_class_name cn_revenue_classes.name%TYPE;

BEGIN
   SELECT name
     INTO l_rev_class_name
     FROM cn_revenue_classes_all
     WHERE revenue_class_id = p_rev_class_id
     ;
   RETURN l_rev_class_name;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_rev_class_name;

--| ---------------------------------------------------------------------+
--|   Function Name :  get_lkup_meaning
--| ---------------------------------------------------------------------+
FUNCTION  get_lkup_meaning( p_lkup_code VARCHAR2,
          p_lkup_type VARCHAR2 )
  RETURN cn_lookups.meaning%TYPE IS

  l_meaning cn_lookups.meaning%TYPE;

BEGIN
     SELECT meaning
       INTO l_meaning
       FROM cn_lookups
       WHERE lookup_type = p_lkup_type
       AND   lookup_code = p_lkup_code
       ;

     RETURN l_meaning;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_lkup_meaning;

--| ---------------------------------------------------------------------+
--|   Procedure Name :  chk_miss_char_para
--|   Desc : Check for missing parameters -- Char type
--| ---------------------------------------------------------------------+
FUNCTION chk_miss_char_para
  ( p_char_para  IN VARCHAR2 ,
    p_para_name  IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS

     l_return_code VARCHAR2(1);

BEGIN
   l_return_code := FND_API.G_FALSE;
   x_loading_status := p_loading_status;
   IF (p_char_para = FND_API.G_MISS_CHAR) THEN
     FND_MESSAGE.SET_NAME ('CN' , 'CN_MISS_PARAMETER');
     FND_MESSAGE.SET_TOKEN('PARA_NAME',p_para_name);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.chk_miss_char_para.error',
	       		       true);
     end if;

     -- Error, check the msg level and add an error message to the
     -- API message list
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_MISS_PARAMETER');
       FND_MESSAGE.SET_TOKEN('PARA_NAME',p_para_name);
       FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_MISS_PARAMETER';
     l_return_code := FND_API.G_TRUE;
   END IF;

   RETURN l_return_code;

END chk_miss_char_para;

--| ---------------------------------------------------------------------+
--|   Function Name :  chk_miss_num_para
--|   Desc : Check for missing parameters -- Number type
--| ---------------------------------------------------------------------+
FUNCTION chk_miss_num_para
  ( p_num_para  IN NUMBER ,
    p_para_name  IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS
     l_return_code VARCHAR2(1);
BEGIN
   l_return_code := FND_API.G_FALSE;
   x_loading_status := p_loading_status;
   IF (p_num_para = FND_API.G_MISS_NUM) THEN
     FND_MESSAGE.SET_NAME ('CN' , 'CN_MISS_PARAMETER');
     FND_MESSAGE.SET_TOKEN('PARA_NAME',p_para_name);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.chk_miss_num_para.error',
	       		       true);
     end if;

     -- Error, check the msg level and add an error message to the
     -- API message list
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_MISS_PARAMETER');
       FND_MESSAGE.SET_TOKEN('PARA_NAME',p_para_name);
       FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_MISS_PARAMETER';
     l_return_code := FND_API.G_TRUE;
   END IF;
   RETURN l_return_code;
END chk_miss_num_para;

--| ---------------------------------------------------------------------+
--|   Procedure Name :  chk_miss_date_para
--|   Desc : Check for missing parameters -- Date type
--| ---------------------------------------------------------------------+
FUNCTION chk_miss_date_para
  ( p_date_para  IN DATE ,
    p_para_name  IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS

     l_return_code VARCHAR2(1);

BEGIN
   l_return_code := FND_API.G_FALSE;
   x_loading_status := p_loading_status;
   IF (p_date_para = FND_API.G_MISS_DATE) THEN
     FND_MESSAGE.SET_NAME ('CN' , 'CN_MISS_PARAMETER');
     FND_MESSAGE.SET_TOKEN('PARA_NAME',p_para_name);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.chk_miss_date_para.error',
	       		       true);
     end if;

     -- Error, check the msg level and add an error message to the
     -- API message list
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_MISS_PARAMETER');
       FND_MESSAGE.SET_TOKEN('PARA_NAME',p_para_name);
       FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_MISS_PARAMETER';
     l_return_code := FND_API.G_TRUE;
   END IF;

   RETURN l_return_code;

END chk_miss_date_para;

--| ---------------------------------------------------------------------+
--|   Function Name :  chk_null_num_para
--|   Desc : Check for Null parameters -- Number type
--| ---------------------------------------------------------------------+
FUNCTION chk_null_num_para
  ( p_num_para  IN NUMBER ,
    p_obj_name IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS
     l_return_code VARCHAR2(1);
BEGIN
   l_return_code := FND_API.G_FALSE;
   x_loading_status := p_loading_status;
   IF (p_num_para IS NULL ) THEN
     FND_MESSAGE.SET_NAME ('CN' , 'CN_CANNOT_NULL');
     FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.chk_null_num_para.error',
	       		       true);
     end if;

     -- Error, check the msg level and add an error message to the
     -- API message list
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_CANNOT_NULL');
       FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
       FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_CANNOT_NULL';
     l_return_code := FND_API.G_TRUE;
   END IF;
   RETURN l_return_code;
END chk_null_num_para;

--| ---------------------------------------------------------------------+
--|   Function Name :  chk_null_char_para
--|   Desc : Check for Null parameters -- Character type
--| ---------------------------------------------------------------------+
FUNCTION chk_null_char_para
  ( p_char_para  IN VARCHAR2 ,
    p_obj_name  IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS
     l_return_code VARCHAR2(1);
BEGIN
   l_return_code := FND_API.G_FALSE;
   x_loading_status := p_loading_status;
   IF (p_char_para IS NULL ) THEN
     Fnd_message.SET_NAME ('CN' , 'CN_CANNOT_NULL');
     FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.chk_null_char_para.error',
	       		       true);
     end if;

     -- Error, check the msg level and add an error message to the
     -- API message list
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       Fnd_message.SET_NAME ('CN' , 'CN_CANNOT_NULL');
       FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
       FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_CANNOT_NULL';
     l_return_code := FND_API.G_TRUE;
   END IF;
   RETURN l_return_code;
END chk_null_char_para;

--| ---------------------------------------------------------------------+
--|   Function Name :  chk_null_date_para
--|   Desc : Check for Null parameters -- Date type
--| ---------------------------------------------------------------------+
FUNCTION chk_null_date_para
  ( p_date_para IN DATE ,
    p_obj_name  IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS
     l_return_code VARCHAR2(1);
BEGIN
   l_return_code := FND_API.G_FALSE;
   x_loading_status := p_loading_status;
   IF (p_date_para IS NULL ) THEN
     FND_MESSAGE.SET_NAME ('CN' , 'CN_CANNOT_NULL');
     FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.chk_null_date_para.error',
	       		       true);
     end if;

     -- Error, check the msg level and add an error message to the
     -- API message list
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_CANNOT_NULL');
       FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
       FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_CANNOT_NULL';
     l_return_code := FND_API.G_TRUE;
   END IF;
   RETURN l_return_code;
END chk_null_date_para;

--| ---------------------------------------------------------------------+
--|   Function Name :  chk_miss_null_num_para
--|   Desc : Check for Missing or Null parameters -- Number type
--| ---------------------------------------------------------------------+
FUNCTION chk_miss_null_num_para
  ( p_num_para  IN NUMBER ,
    p_obj_name IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS
     l_return_code VARCHAR2(1);
BEGIN
   l_return_code := FND_API.G_FALSE;
   x_loading_status := p_loading_status;
   IF ((p_num_para IS NULL) OR (p_num_para = FND_API.G_MISS_NUM)) THEN
     FND_MESSAGE.SET_NAME ('CN' , 'CN_CANNOT_MISS_OR_NULL');
     FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.chk_miss_null_num_para.error',
	       		       true);
     end if;

     -- Error, check the msg level and add an error message to the
     -- API message list
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_CANNOT_MISS_OR_NULL');
       FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
       FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_CANNOT_MISS_OR_NULL';
     l_return_code := FND_API.G_TRUE;
   END IF;
   RETURN l_return_code;
END chk_miss_null_num_para;

--| ---------------------------------------------------------------------+
--|   Function Name :  chk_miss_null_char_para
--|   Desc : Check for Missing or Null parameters -- Character type
--| ---------------------------------------------------------------------+
FUNCTION chk_miss_null_char_para
  ( p_char_para  IN VARCHAR2 ,
    p_obj_name  IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS
     l_return_code VARCHAR2(1);
BEGIN
   l_return_code := FND_API.G_FALSE;
   x_loading_status := p_loading_status;
   IF ((p_char_para IS NULL ) OR (p_char_para = FND_API.G_MISS_CHAR)) THEN
     FND_MESSAGE.SET_NAME ('CN' , 'CN_CANNOT_MISS_OR_NULL');
     FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.chk_miss_null_char_para.error',
	       		       true);
     end if;

     -- Error, check the msg level and add an error message to the
     -- API message list
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_CANNOT_MISS_OR_NULL');
       FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
       FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_CANNOT_MISS_OR_NULL';
     l_return_code := FND_API.G_TRUE;
   END IF;
   RETURN l_return_code;
END chk_miss_null_char_para;

--| ---------------------------------------------------------------------+
--|   Function Name :  chk_miss_null_date_para
--|   Desc : Check for Missing or Null parameters -- Date type
--| ---------------------------------------------------------------------+
FUNCTION chk_miss_null_date_para
  ( p_date_para IN DATE ,
    p_obj_name  IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS
     l_return_code VARCHAR2(1);
BEGIN
   l_return_code := FND_API.G_FALSE;
   x_loading_status := p_loading_status;
   IF ((p_date_para IS NULL ) OR (p_date_para = FND_API.G_MISS_DATE)) THEN
     FND_MESSAGE.SET_NAME ('CN' , 'CN_CANNOT_MISS_OR_NULL');
     FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.chk_miss_null_date_para.error',
	       		       true);
     end if;

      -- Error, check the msg level and add an error message to the
      -- API message list
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_CANNOT_MISS_OR_NULL');
         FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_CANNOT_MISS_OR_NULL';
      l_return_code := FND_API.G_TRUE;
   END IF;
   RETURN l_return_code;
END chk_miss_null_date_para;

--| ---------------------------------------------------------------------+
--|   Function Name :  pe_num_field_must_null
--|   Desc : Check for Field (Number Type) must be Null
--| ---------------------------------------------------------------------+
FUNCTION pe_num_field_must_null
  ( p_num_field  IN NUMBER  ,
    p_pe_type IN VARCHAR2 ,
    p_obj_name  IN VARCHAR2 ,
    p_token1    IN VARCHAR2 ,
    p_token2    IN VARCHAR2 ,
    p_token3    IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS
     l_return_code VARCHAR2(1);
BEGIN
   l_return_code := FND_API.G_TRUE;
   x_loading_status := p_loading_status;
   IF (p_num_field IS NOT NULL ) THEN
     FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_FIELD_MUST_NULL');
     FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
     FND_MESSAGE.SET_TOKEN('PLAN_TYPE',
                           get_lkup_meaning(p_pe_type,'QUOTA_TYPE'));
     FND_MESSAGE.SET_TOKEN('TOKEN1',p_token1);
     FND_MESSAGE.SET_TOKEN('TOKEN2',p_token2);
     FND_MESSAGE.SET_TOKEN('TOKEN3',p_token3);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.pe_num_field_must_null.error',
	       		       true);
     end if;

      -- Error, check the msg level and add an error message to the
      -- API message list
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_FIELD_MUST_NULL');
         FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
   FND_MESSAGE.SET_TOKEN('PLAN_TYPE',
             get_lkup_meaning(p_pe_type,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN('TOKEN1',p_token1);
   FND_MESSAGE.SET_TOKEN('TOKEN2',p_token2);
   FND_MESSAGE.SET_TOKEN('TOKEN3',p_token3);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PE_FIELD_MUST_NULL';
      l_return_code := FND_API.G_FALSE;
   END IF;
   RETURN l_return_code;
END pe_num_field_must_null;

--| ---------------------------------------------------------------------+
--|   Function Name :  pe_char_field_must_null
--|   Desc : Check for Field (Char Type) must be Null
--| ---------------------------------------------------------------------+
FUNCTION pe_char_field_must_null
  ( p_char_field  IN VARCHAR2 ,
    p_pe_type IN VARCHAR2 ,
    p_obj_name  IN VARCHAR2 ,
    p_token1    IN VARCHAR2 ,
    p_token2    IN VARCHAR2 ,
    p_token3    IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS
     l_return_code VARCHAR2(1);
BEGIN
   l_return_code := FND_API.G_TRUE;
   x_loading_status := p_loading_status;
   IF (p_char_field IS NOT NULL ) THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_FIELD_MUST_NULL');
         FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
   FND_MESSAGE.SET_TOKEN('PLAN_TYPE',
             get_lkup_meaning(p_pe_type,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN('TOKEN1',p_token1);
   FND_MESSAGE.SET_TOKEN('TOKEN2',p_token2);
   FND_MESSAGE.SET_TOKEN('TOKEN3',p_token3);

     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.pe_char_field_must_null.error',
	       		       true);
     end if;

      -- Error, check the msg level and add an error message to the
      -- API message list
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_FIELD_MUST_NULL');
         FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
   FND_MESSAGE.SET_TOKEN('PLAN_TYPE',
             get_lkup_meaning(p_pe_type,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN('TOKEN1',p_token1);
   FND_MESSAGE.SET_TOKEN('TOKEN2',p_token2);
   FND_MESSAGE.SET_TOKEN('TOKEN3',p_token3);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PE_FIELD_MUST_NULL';
      l_return_code := FND_API.G_FALSE;
   END IF;
   RETURN l_return_code;
END pe_char_field_must_null;

--| ---------------------------------------------------------------------+
--|   Function Name :  pe_num_field_cannot_null
--|   Desc : Check for Field (Number Type) can not be Null
--| ---------------------------------------------------------------------+
FUNCTION pe_num_field_cannot_null
  ( p_num_field  IN NUMBER ,
    p_pe_type IN VARCHAR2 ,
    p_obj_name  IN VARCHAR2 ,
    p_token1    IN VARCHAR2 ,
    p_token2    IN VARCHAR2 ,
    p_token3    IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS
     l_return_code VARCHAR2(1);
BEGIN
   l_return_code := FND_API.G_TRUE;
   x_loading_status := p_loading_status;
   IF (p_num_field IS NULL ) THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_FIELD_CANNOT_NULL');
         FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
   FND_MESSAGE.SET_TOKEN('PLAN_TYPE',
             get_lkup_meaning(p_pe_type,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN('TOKEN1',p_token1);
   FND_MESSAGE.SET_TOKEN('TOKEN2',p_token2);
   FND_MESSAGE.SET_TOKEN('TOKEN3',p_token3);

     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.pe_num_field_cannot_null.error',
	       		       true);
     end if;

      -- Error, check the msg level and add an error message to the
      -- API message list
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_FIELD_CANNOT_NULL');
         FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
   FND_MESSAGE.SET_TOKEN('PLAN_TYPE',
             get_lkup_meaning(p_pe_type,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN('TOKEN1',p_token1);
   FND_MESSAGE.SET_TOKEN('TOKEN2',p_token2);
   FND_MESSAGE.SET_TOKEN('TOKEN3',p_token3);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PE_FIELD_CANNOT_NULL';
      l_return_code := FND_API.G_FALSE;
   END IF;
   RETURN l_return_code;
END pe_num_field_cannot_null;

--| ---------------------------------------------------------------------+
--|   Function Name :  pe_char_field_cannot_null
--|   Desc : Check for Field (Char Type) can not be Null
--| ---------------------------------------------------------------------+
FUNCTION pe_char_field_cannot_null
  ( p_char_field  IN VARCHAR2 ,
    p_pe_type IN VARCHAR2 ,
    p_obj_name  IN VARCHAR2 ,
    p_token1    IN VARCHAR2 ,
    p_token2    IN VARCHAR2 ,
    p_token3    IN VARCHAR2 ,
    p_loading_status IN VARCHAR2 ,
    x_loading_status OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS
     l_return_code VARCHAR2(1);
BEGIN
   l_return_code := FND_API.G_TRUE;
   x_loading_status := p_loading_status;
   IF (p_char_field IS NULL ) THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_FIELD_CANNOT_NULL');
         FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
   FND_MESSAGE.SET_TOKEN('PLAN_TYPE',
             get_lkup_meaning(p_pe_type,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN('TOKEN1',p_token1);
   FND_MESSAGE.SET_TOKEN('TOKEN2',p_token2);
   FND_MESSAGE.SET_TOKEN('TOKEN3',p_token3);

     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_api.pe_char_field_cannot_null.error',
	       		       true);
     end if;

      -- Error, check the msg level and add an error message to the
      -- API message list
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PE_FIELD_CANNOT_NULL');
         FND_MESSAGE.SET_TOKEN('OBJ_NAME',p_obj_name);
   FND_MESSAGE.SET_TOKEN('PLAN_TYPE',
             get_lkup_meaning(p_pe_type,'QUOTA_TYPE'));
         FND_MESSAGE.SET_TOKEN('TOKEN1',p_token1);
   FND_MESSAGE.SET_TOKEN('TOKEN2',p_token2);
   FND_MESSAGE.SET_TOKEN('TOKEN3',p_token3);
   FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_PE_FIELD_CANNOT_NULL';
      l_return_code := FND_API.G_FALSE;
   END IF;
   RETURN l_return_code;
END pe_char_field_cannot_null;
--| ---------------------------------------------------------------------+
--| Function Name :  get_cp_name
--| Desc : Pass in comp plan id then return comp plan name
--| ---------------------------------------------------------------------+
FUNCTION  get_cp_name( p_comp_plan_id  NUMBER)
  RETURN cn_comp_plans.name%TYPE IS

  l_comp_plan_name cn_comp_plans.name%TYPE;

BEGIN
   SELECT name
     INTO l_comp_plan_name
     FROM cn_comp_plans_all
     WHERE comp_plan_id = p_comp_plan_id;

   RETURN l_comp_plan_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_cp_name;

--| ---------------------------------------------------------------------+
--| Function Name :  get_cp_id
--| Desc : Pass in comp plan name then return comp plan id
--| ---------------------------------------------------------------------+
FUNCTION  get_cp_id( p_comp_plan_name  VARCHAR2, p_org_id NUMBER)
  RETURN cn_comp_plans.comp_plan_id%TYPE IS

  l_comp_plan_id cn_comp_plans.comp_plan_id%TYPE;

BEGIN
   SELECT comp_plan_id
     INTO l_comp_plan_id
     FROM cn_comp_plans_all
     WHERE name = p_comp_plan_name
       AND org_id = p_org_id;

   RETURN l_comp_plan_id;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_cp_id;

--| ---------------------------------------------------------------------+
--| Function Name :  get_pp_name
--| Desc : Pass in payment plan id then return payment plan name
--| ---------------------------------------------------------------------+
FUNCTION  get_pp_name( p_pmt_plan_id  NUMBER)
  RETURN cn_pmt_plans.name%TYPE IS

  l_pmt_plan_name cn_pmt_plans.name%TYPE;

BEGIN
   SELECT name
     INTO l_pmt_plan_name
     FROM cn_pmt_plans_all
     WHERE pmt_plan_id = p_pmt_plan_id;

   RETURN l_pmt_plan_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_pp_name;

--| ---------------------------------------------------------------------+
--| Function Name :  get_pp_id
--| Desc : Pass in payment plan name then return payment plan id
--| ---------------------------------------------------------------------+
FUNCTION  get_pp_id( p_pmt_plan_name  VARCHAR2, p_org_id NUMBER)
  RETURN cn_pmt_plans.pmt_plan_id%TYPE IS

  l_pmt_plan_id cn_pmt_plans.pmt_plan_id%TYPE;

BEGIN
   SELECT pmt_plan_id
     INTO l_pmt_plan_id
     FROM cn_pmt_plans_all
     WHERE name = p_pmt_plan_name
       AND org_id = p_org_id;

   RETURN l_pmt_plan_id;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_pp_id;

--| ---------------------------------------------------------------------+
--| Function Name :  get_salesrep_name
--| Desc : Pass in salesrep id then return salesrep name
--| ---------------------------------------------------------------------+
FUNCTION  get_salesrep_name( p_salesrep_id  NUMBER, p_org_id NUMBER)
  RETURN cn_salesreps.name%TYPE IS

  l_salesrep_name cn_salesreps.name%TYPE;

BEGIN
   SELECT name
     INTO l_salesrep_name
     FROM cn_salesreps
     WHERE salesrep_id = p_salesrep_id
       AND org_id = p_org_id;

   RETURN l_salesrep_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_salesrep_name;

--| -----------------------------------------------------------------------+
--| Function Name :  chk_and get_salesrep_id
--| Desc : Based on the employee number and salesrep type passed in,
--|        Check if only one rec retrieve, if yes get the salesrep_id
--| ---------------------------------------------------------------------+
PROCEDURE  chk_and_get_salesrep_id
  ( p_emp_num         IN VARCHAR2,
    p_type            IN VARCHAR2,
    p_org_id          IN NUMBER,
    x_salesrep_id     OUT NOCOPY cn_salesreps.salesrep_id%TYPE,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_loading_status  OUT NOCOPY VARCHAR2,
    p_show_message    IN VARCHAR2) IS

       l_salesrep_id cn_salesreps.salesrep_id%TYPE;
       l_emp_num  cn_salesreps.employee_number%TYPE;

BEGIN
   -- change for performance. Force to hit index on employee_number
   -- Bug 1508614
   -- Fixed  l_emp_num

   -- employee number or type cannot be null - fixed for bug 5075017

   l_emp_num := upper(p_emp_num);

/*   IF p_emp_num IS NULL THEN
      SELECT salesrep_id
	INTO l_salesrep_id
	FROM cn_salesreps
	WHERE employee_number IS NULL
	  AND org_id = p_org_id
	  AND ((type = p_type) OR (type IS NULL AND p_type IS NULL));
     ELSE
*/
      SELECT /*+ first_rows */ salesrep_id
	INTO l_salesrep_id
	FROM cn_salesreps
	WHERE upper(employee_number) = l_emp_num
	AND org_id = p_org_id
	AND type = p_type;
--   END IF;
   x_salesrep_id := l_salesrep_id;
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_SALESREP_FOUND';

EXCEPTION
   WHEN no_data_found THEN
      x_salesrep_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_loading_status := 'CN_SALESREP_NOT_FOUND';
      IF (p_show_message = FND_API.G_TRUE) THEN
   -- Error, check the msg level and add an error message to the
   -- API message list
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN',x_loading_status);
      FND_MSG_PUB.Add;
   END IF;
      END IF;
   WHEN too_many_rows THEN
      x_salesrep_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_loading_status := 'CN_SALESREP_TOO_MANY_ROWS';
      IF (p_show_message = FND_API.G_TRUE) THEN
   -- Error, check the msg level and add an error message to the
   -- API message list
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
      FND_MESSAGE.SET_NAME ('CN',x_loading_status);
      FND_MSG_PUB.Add;
   END IF;
      END IF;
END chk_and_get_salesrep_id;


--| -----------------------------------------------------------------------+
--| Function Name :  get_salesrep_id
--| Desc : Pass in salesrep name and employee number then return salesrep id
--| ---------------------------------------------------------------------+
FUNCTION  get_salesrep_id( p_salesrep_name  VARCHAR2, p_emp_num VARCHAR2, p_org_id NUMBER)
  RETURN cn_salesreps.salesrep_id%TYPE IS

  l_salesrep_id cn_salesreps.salesrep_id%TYPE;

BEGIN
   SELECT salesrep_id
     INTO l_salesrep_id
     FROM cn_salesreps
     WHERE name = p_salesrep_name AND employee_number = p_emp_num
     AND org_id = p_org_id;

   RETURN l_salesrep_id;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_salesrep_id;


-- --------------------------------------------------------------------------+
-- Function : date_range_overlap
-- Desc     : Check if two set of dates (a_start_date,a_end_date) and
--            (b_start_date, b_end_date) are overlap or not.
--            Assuming
--            1. a_start_date is not null and a_start_date > a_end_date
--            2. b_start_date is not null and b_start_date > b_end_date
--            3. both end_date can be open (null)
-- --------------------------------------------------------------------------+
FUNCTION date_range_overlap
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE
   ) RETURN BOOLEAN IS

BEGIN

   IF (a_end_date IS NOT NULL) THEN
      IF (b_end_date IS NOT NULL) THEN
   IF ((b_start_date BETWEEN a_start_date AND a_end_date) OR
       (b_end_date BETWEEN a_start_date AND a_end_date) OR
       (a_start_date BETWEEN b_start_date AND b_end_date) OR
       (a_end_date BETWEEN b_start_date AND b_end_date)) THEN
      RETURN TRUE; -- overlap
   END IF;
       ELSE
   IF (b_start_date <= a_end_date) THEN
      RETURN TRUE; -- overlap
   END IF;
      END IF;
    ELSE
      IF (b_end_date IS NOT NULL) THEN
   IF (b_end_date >= a_start_date) THEN
      RETURN TRUE; -- overlap
   END IF;
       ELSE
   RETURN TRUE; -- overlap
      END IF;
   END IF;

   RETURN FALSE;  -- not overlap

END date_range_overlap;

-- ---------------------------------------------------------------------------+
-- PROCEDURE : get_date_range_diff_action
-- Desc     : get the difference portion of the two date ranges
--            Assuming
--            1. start_date_new is not null and start_date_new < end_date_new
--            2. start_date_old is not null and start_date_old < end_date_old
--            3. both end_date can be open (null)
-- ---------------------------------------------------------------------------+
PROCEDURE get_date_range_diff_action
  (
   start_date_new   DATE,
   end_date_new     DATE,
   start_date_old   DATE,
   end_date_old     DATE,
   x_date_range_action_tbl OUT NOCOPY date_range_action_tbl_type ) IS

   l_counter NUMBER :=0;

BEGIN

   IF cn_api.date_range_overlap
     (start_date_new,
      end_date_new,
      start_date_old,
      end_date_old) THEN

      -- overlap exists

      IF start_date_new > start_date_old THEN

	 l_counter := l_counter + 1;
	 x_date_range_action_tbl(l_counter).start_date := start_date_old;
	 x_date_range_action_tbl(l_counter).end_date   := start_date_new - 1;
	 x_date_range_action_tbl(l_counter).action_flag:= 'D';

	 -- clku, fixed compaison
       ELSIF start_date_new < start_date_old THEN

	 l_counter := l_counter + 1;
	 x_date_range_action_tbl(l_counter).start_date := start_date_new;
	 x_date_range_action_tbl(l_counter).end_date   := start_date_old - 1;
	 x_date_range_action_tbl(l_counter).action_flag:= 'I';

      END IF;

      IF end_date_new IS NULL AND end_date_old IS NULL THEN

	 NULL;

       ELSIF end_date_new IS NULL AND end_date_old IS NOT NULL THEN

	 l_counter := l_counter + 1;
	 x_date_range_action_tbl(l_counter).start_date := end_date_old + 1;
	 x_date_range_action_tbl(l_counter).end_date   := NULL;
	 x_date_range_action_tbl(l_counter).action_flag:= 'I';

       ELSIF end_date_new IS NOT NULL AND end_date_old IS NULL THEN

	 l_counter := l_counter + 1;
	 x_date_range_action_tbl(l_counter).start_date := end_date_new + 1;
	 x_date_range_action_tbl(l_counter).end_date   := NULL;
	 x_date_range_action_tbl(l_counter).action_flag:= 'D';

       ELSE

	 IF end_date_new > end_date_old THEN

	    l_counter := l_counter + 1;
	    x_date_range_action_tbl(l_counter).start_date := end_date_old + 1;
	    x_date_range_action_tbl(l_counter).end_date   := end_date_new;
	    x_date_range_action_tbl(l_counter).action_flag:= 'I';

	  ELSIF end_date_new < end_date_old THEN

	    l_counter := l_counter + 1;
	    x_date_range_action_tbl(l_counter).start_date := end_date_new + 1;
	    x_date_range_action_tbl(l_counter).end_date   := end_date_old;
            -- clku, fixed action
	    x_date_range_action_tbl(l_counter).action_flag:= 'D';

	 END IF;

      END IF;

    ELSE

      -- no overlap
      l_counter := l_counter + 1;
      x_date_range_action_tbl(l_counter).start_date := start_date_new ;
      x_date_range_action_tbl(l_counter).end_date   := end_date_new;
      x_date_range_action_tbl(l_counter).action_flag:= 'I';

      l_counter := l_counter + 1;
      x_date_range_action_tbl(l_counter).start_date := start_date_old;
      x_date_range_action_tbl(l_counter).end_date   := end_date_old;
      x_date_range_action_tbl(l_counter).action_flag:= 'D';

   END IF;

END get_date_range_diff_action;

-- ---------------------------------------------------------------------------+
-- Function : date_range_within
-- Desc     : Check if (a_start_date,a_end_date) is within (b_start_date, b_end_date)
--            Assuming
--            1. a_start_date is not null and a_start_date > a_end_date
--            2. b_start_date is not null and b_start_date > b_end_date
--            3. both end_date can be open (null)
-- ---------------------------------------------------------------------------+
FUNCTION date_range_within
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE
   ) RETURN BOOLEAN IS

BEGIN
   IF (b_end_date IS NOT NULL) THEN
      IF (a_end_date IS NOT NULL) THEN
   IF ((a_start_date BETWEEN b_start_date AND b_end_date) AND
       (a_end_date BETWEEN b_start_date AND b_end_date)) THEN
      RETURN TRUE; -- within
   END IF;
       ELSE
   RETURN FALSE; -- not within
      END IF;
    ELSE
      IF (a_start_date >= b_start_date) THEN
   RETURN TRUE; -- within
      END IF;
   END IF;

   RETURN FALSE;  -- not within

END date_range_within;

--| ---------------------------------------------------------------------=
--|   Procedure Name :  invalid_date_range
--|   Desc : Check if date range is invalid
--| ---------------------------------------------------------------------=
FUNCTION invalid_date_range
  ( p_start_date  IN DATE ,
    p_end_date    IN DATE ,
    p_end_date_nullable IN VARCHAR2,
    p_loading_status IN VARCHAR2,
    x_loading_status OUT NOCOPY VARCHAR2,
    p_show_message IN VARCHAR2)
  RETURN VARCHAR2 IS

     l_return_code VARCHAR2(1);

BEGIN
   l_return_code := FND_API.G_FALSE;
   x_loading_status := p_loading_status;
   IF p_start_date IS NULL THEN
      x_loading_status := 'CN_START_DATE_CANNOT_NULL';
      l_return_code := FND_API.G_TRUE;
    ELSIF p_start_date = FND_API.G_MISS_DATE THEN
      x_loading_status := 'CN_START_DATE_CANNOT_MISSING';
      l_return_code := FND_API.G_TRUE;
    ELSIF p_end_date IS NULL AND p_end_date_nullable <> FND_API.G_TRUE THEN
      x_loading_status := 'CN_END_DATE_CANNOT_NULL';
      l_return_code := FND_API.G_TRUE;
    ELSIF p_end_date = FND_API.G_MISS_DATE
      AND p_end_date_nullable <> FND_API.G_TRUE THEN
      x_loading_status := 'CN_END_DATE_CANNOT_MISSING';
      l_return_code := FND_API.G_TRUE;
    ELSIF p_end_date IS NOT NULL AND p_start_date > p_end_date THEN
      x_loading_status := 'CN_INVALID_DATE_RANGE';
      l_return_code := FND_API.G_TRUE;
    ELSE
      l_return_code := FND_API.G_FALSE;
   END IF;
   IF (l_return_code =  FND_API.g_true AND p_show_message = fnd_api.G_TRUE) THEN
      -- Error, check the msg level and add an error message to the
      -- API message list
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN',x_loading_status);
   FND_MSG_PUB.Add;
      END IF;
   END IF;

   RETURN l_return_code;

END invalid_date_range;
--| ---------------------------------------------------------------------=
--| Function Name :  get_role_id
--| Desc : Get the  role id using the role name
--| ---------------------------------------------------------------------=
FUNCTION  get_role_id ( p_role_name     VARCHAR2 )
  RETURN cn_roles.role_id%TYPE IS

     l_role_id cn_roles.role_id%TYPE;

BEGIN
   -- added uppers to avoid FTS for bug 5075017
   SELECT role_id
     INTO l_role_id
     FROM cn_roles
     WHERE Upper(name) = Upper(p_role_name) ;

   RETURN l_role_id;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;

END get_role_id;
--| ---------------------------------------------------------------------=
--| Function Name :  get_role_name
--| Desc : Get the  role name using the role id
--| ---------------------------------------------------------------------=
FUNCTION  get_role_name ( p_role_id     VARCHAR2 )
  RETURN cn_roles.name%TYPE IS

     l_role_name cn_roles.name%TYPE;

BEGIN
   SELECT name
     INTO l_role_name
     FROM cn_roles
     WHERE  role_id = p_role_id ;

   RETURN l_role_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;

END get_role_name;

-- --------------------------------------------------------------------------=
-- Function : get_srp_role_id
-- Desc     : get the srp_role_id if it exists in cn_srp_roles
-- --------------------------------------------------------------------------=
FUNCTION get_srp_role_id
  (p_emp_num    IN cn_salesreps.employee_number%type,
   p_type       IN cn_salesreps.TYPE%type,
   p_role_name  IN cn_roles.name%type,
   p_start_date IN cn_srp_roles.start_date%type,
   p_end_date   IN cn_srp_roles.end_date%TYPE,
   p_org_id     IN cn_salesreps.org_id%type
   ) RETURN cn_srp_roles.srp_role_id%TYPE IS

      CURSOR l_cur(l_salesrep_id  cn_srp_roles.salesrep_id%TYPE,
		   l_role_id      cn_srp_roles.role_id%TYPE,
		   l_start_date   cn_srp_roles.start_date%TYPE,
		   l_end_date     cn_srp_roles.end_date%TYPE) IS
   SELECT srp_role_id
     FROM cn_srp_roles
     WHERE role_id = l_role_id AND
     salesrep_id = l_salesrep_id AND
     start_date = l_start_date AND
     org_id = p_org_id AND
     ((end_date = l_end_date) OR
      (end_date IS NULL AND l_end_date IS NULL));

      l_rec              l_cur%ROWTYPE;
      l_role_id          cn_srp_roles.role_id%TYPE;
      l_salesrep_id      cn_srp_roles.salesrep_id%TYPE;
      l_return_status    VARCHAR2(2000);
      l_loading_status   VARCHAR2(2000);

BEGIN

   l_role_id     := cn_api.get_role_id(p_role_name);
   chk_and_get_salesrep_id
     (p_emp_num ,
      p_type,
      p_org_id,
      l_salesrep_id,
      l_return_status,
      l_loading_status,
      fnd_api.g_false);

   OPEN l_cur(l_salesrep_id, l_role_id, p_start_date, p_end_date);
   FETCH l_cur INTO l_rec;
   IF (l_cur%notfound) THEN
      CLOSE l_cur;
      RETURN NULL;
    ELSE
      CLOSE l_cur;
      RETURN l_rec.srp_role_id;
   END IF;

END get_srp_role_id;

-- --------------------------------------------------------------------------=
-- Function : get_role_plan_id
-- Desc     : get the role_plan_id if it exists in cn_roles
-- --------------------------------------------------------------------------=
FUNCTION get_role_plan_id
  (
   p_role_name              IN  VARCHAR2,
   p_comp_plan_name         IN  VARCHAR2,
   p_start_date             IN  DATE,
   p_end_date               IN  DATE,
   p_org_id                 IN NUMBER
   ) RETURN cn_role_plans.role_plan_id%TYPE IS

      CURSOR l_cur(l_role_id      cn_role_plans.role_id%TYPE,
       l_comp_plan_id cn_role_plans.comp_plan_id%TYPE,
       l_start_date   cn_role_plans.start_date%TYPE,
       l_end_date     cn_role_plans.end_date%TYPE) IS
   SELECT role_plan_id
     FROM cn_role_plans
     WHERE role_id = l_role_id AND
     comp_plan_id = l_comp_plan_id AND
     start_date = l_start_date AND
     ((end_date = l_end_date) OR
      (end_date IS NULL AND l_end_date IS NULL));

      l_rec              l_cur%ROWTYPE;
      l_role_id          cn_role_plans.role_id%TYPE;
      l_comp_plan_id     cn_role_plans.comp_plan_id%TYPE;

BEGIN

   l_role_id      := cn_api.get_role_id(p_role_name);
   l_comp_plan_id := cn_api.get_cp_id(p_comp_plan_name, p_org_id);

   OPEN l_cur(l_role_id, l_comp_plan_id, p_start_date, p_end_date);
   FETCH l_cur INTO l_rec;
   IF (l_cur%notfound) THEN
      CLOSE l_cur;
      RETURN NULL;
    ELSE
      CLOSE l_cur;
      RETURN l_rec.role_plan_id;
   END IF;

END get_role_plan_id;

-- --------------------------------------------------------------------------=
-- Function : get_role_pmt_plan_id
-- Desc     : get the role_pmt_plan_id if it exists in cn_roles_pmt_plans
-- --------------------------------------------------------------------------=
FUNCTION get_role_pmt_plan_id
  (
   p_role_name              IN  VARCHAR2,
   p_pmt_plan_name          IN  VARCHAR2,
   p_start_date             IN  DATE,
   p_end_date               IN  DATE,
   p_org_id                 IN NUMBER
   ) RETURN cn_role_pmt_plans.role_pmt_plan_id%TYPE IS

      CURSOR l_cur(l_role_id      cn_role_pmt_plans.role_id%TYPE,
       l_pmt_plan_id  cn_role_pmt_plans.pmt_plan_id%TYPE,
       l_start_date   cn_role_pmt_plans.start_date%TYPE,
       l_end_date     cn_role_pmt_plans.end_date%TYPE) IS
   SELECT role_pmt_plan_id
     FROM cn_role_pmt_plans
     WHERE role_id = l_role_id AND
     pmt_plan_id = l_pmt_plan_id AND
     start_date = l_start_date AND
     ((end_date = l_end_date) OR
      (end_date IS NULL AND l_end_date IS NULL));

      l_rec              l_cur%ROWTYPE;
      l_role_id          cn_role_pmt_plans.role_id%TYPE;
      l_pmt_plan_id      cn_role_pmt_plans.pmt_plan_id%TYPE;

BEGIN

   l_role_id      := cn_api.get_role_id(p_role_name);
   l_pmt_plan_id  := cn_api.get_pp_id(p_pmt_plan_name, p_org_id);

   OPEN l_cur(l_role_id, l_pmt_plan_id, p_start_date, p_end_date);
   FETCH l_cur INTO l_rec;
   IF (l_cur%notfound) THEN
      CLOSE l_cur;
      RETURN NULL;
    ELSE
      CLOSE l_cur;
      RETURN l_rec.role_pmt_plan_id;
   END IF;

END get_role_pmt_plan_id;


--| -----------------------------------------------------------------------=
--| Function Name :  get_srp_payee_assign_id
--| Desc : Get the  srp_payee_assign_id using the
--| payee_id, salesrep_id, quota_id, start_date, end_date
--| ---------------------------------------------------------------------=
FUNCTION  get_srp_payee_assign_id ( p_payee_id     NUMBER,
				    p_salesrep_id  NUMBER,
				    p_quota_id     NUMBER,
				    p_start_date   DATE,
				    p_end_date     DATE,
				    p_org_id       NUMBER)
  RETURN cn_srp_payee_assigns.srp_payee_assign_id%TYPE IS

     CURSOR get_srp_payee_assign_id_curs IS
	SELECT srp_payee_assign_id
	  FROM cn_srp_payee_assigns
	  WHERE payee_id     = p_payee_id
	  AND salesrep_id  = p_salesrep_id
	  AND org_id       = p_org_id
	  AND quota_id     = p_quota_id
	  AND start_date   = p_start_date
    AND end_date     = p_end_date ;

     CURSOR get_srp_payee_assign_id_curs1 IS
	SELECT srp_payee_assign_id
	  FROM cn_srp_payee_assigns
	  WHERE payee_id     = p_payee_id
	  AND salesrep_id  = p_salesrep_id
	  AND org_id       = p_org_id
	  AND quota_id     = p_quota_id
	  AND start_date   = p_start_date
	  AND end_date     IS NULL ;

    l_srp_payee_assign_id cn_srp_payee_assigns.srp_payee_assign_id%TYPE;

BEGIN

   IF p_end_date IS NOT NULL THEN

      OPEN  get_srp_payee_assign_id_curs;
      FETCH get_srp_payee_assign_id_curs INTO l_srp_payee_assign_id;
      CLOSE get_srp_payee_assign_id_curs;
    ELSE
      OPEN  get_srp_payee_assign_id_curs1;
      FETCH get_srp_payee_assign_id_curs1 INTO l_srp_payee_assign_id;
      CLOSE get_srp_payee_assign_id_curs1;
   END IF;

   RETURN l_srp_payee_assign_id;

END get_srp_payee_assign_id;
--| ---------------------------------------------------------------------=
--| Function Name :  next_period
--| ---------------------------------------------------------------------=
FUNCTION next_period (p_end_date DATE, p_org_id NUMBER)
   RETURN cn_acc_period_statuses_v.end_date%TYPE IS

      l_next_end_date cn_acc_period_statuses_v.end_date%TYPE;

   BEGIN

      SELECT MAX(end_date)
        INTO l_next_end_date
        FROM cn_acc_period_statuses_v
       WHERE period_status IN ('F', 'O')
         AND org_id = p_org_id;

     IF trunc(l_next_end_date) > trunc(p_end_date) THEN

        SELECT MIN(end_date)
          INTO l_next_end_date
          FROM cn_acc_period_statuses_v
         WHERE trunc(end_date) >= trunc(p_end_date)
           AND period_status IN ('F', 'O')
           AND org_id = p_org_id;

     END IF;

     RETURN l_next_end_date;

   EXCEPTION
      WHEN no_data_found THEN
         RETURN NULL;
END next_period;

FUNCTION get_pay_period(p_salesrep_id NUMBER,
                        p_date        DATE,
                        p_org_id      NUMBER )
  RETURN cn_commission_lines.pay_period_id%TYPE IS

     l_pay_period_id  cn_commission_lines.pay_period_id%TYPE;

BEGIN

   SELECT a.period_id
     INTO l_pay_period_id
     FROM cn_period_statuses_all a, cn_srp_pay_groups_all b, cn_pay_groups_all c
     WHERE a.period_set_id = c.period_set_id
     AND a.org_id = p_org_id
     AND a.period_type_id = c.period_type_id
     AND b.pay_group_id = c.pay_group_id
     AND b.org_id = p_org_id
     AND c.org_id = p_org_id
     AND p_date BETWEEN a.start_date AND least(a.end_date, nvl(b.end_date,a.end_date))
     AND p_salesrep_id = b.salesrep_id
     AND p_date BETWEEN b.start_date AND nvl(b.end_date, p_date);

   RETURN l_pay_period_id;

END get_pay_period;


--| ---------------------------------------------------------------------=
--| Function Name :  Get Itd Flag
--| ---------------------------------------------------------------------=
FUNCTION get_itd_flag(p_calc_formula_id NUMBER)
  RETURN cn_calc_formulas.itd_flag%TYPE IS

     l_itd_flag cn_calc_formulas.itd_flag%TYPE;

BEGIN

   SELECT itd_flag
     INTO l_itd_flag
     FROM cn_calc_formulas_all
     WHERE calc_formula_id = p_calc_formula_id ;

   RETURN l_itd_flag;
 EXCEPTION
    WHEN no_data_found THEN
   RETURN  NULL;

END get_itd_flag;

--| -----------------------------------------------------------------------=
--|   Function Name :  get_acc_period_id -- only get active periods
--| ---------------------------------------------------------------------=
FUNCTION  get_acc_period_id( p_period_name  VARCHAR2, p_org_id NUMBER)
  RETURN cn_periods.period_id%TYPE IS

  l_period_id cn_periods.period_id%TYPE;

BEGIN
   SELECT period_id
     INTO l_period_id
     FROM cn_acc_period_statuses_v
     WHERE period_name = p_period_name
     AND org_id = p_org_id;

   RETURN l_period_id;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_acc_period_id;

--| -----------------------------------------------------------------------=
--|   Function Name :  get_acc_period_name -- only get active periods
--| ---------------------------------------------------------------------=
FUNCTION  get_acc_period_name( p_period_id  NUMBER, p_org_id NUMBER)
  RETURN cn_periods.period_name%TYPE IS

  l_period_name cn_periods.period_name%TYPE;

BEGIN
   SELECT period_name
     INTO l_period_name
     FROM cn_acc_period_statuses_v
     WHERE period_id = p_period_id
     AND org_id = p_org_id;

   RETURN l_period_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_acc_period_name;
--| -----------------------------------------------------------------------=
--|   Function Name :  get_quota_assign_id
--| ---------------------------------------------------------------------=
FUNCTION  get_quota_assign_id( p_quota_id NUMBER,
             p_comp_plan_id NUMBER )
  RETURN cn_quota_assigns.quota_assign_id%TYPE IS

   l_quota_assign_id      cn_quota_assigns.quota_assign_id%TYPE;

BEGIN
   SELECT quota_assign_id INTO l_quota_assign_id
     FROM cn_quota_assigns_all
     WHERE quota_id = p_quota_id
   AND  comp_plan_id = p_comp_plan_id;

   RETURN l_quota_assign_id;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_quota_assign_id ;

-- ---------------------------------------------------------------------------=
-- PROCEDURE : get_date_range_diff
-- Desc     : get the difference portion of the two date ranges
--            Assuming
--            1. a_start_date is not null and a_start_date < a_end_date
--            2. b_start_date is not null and b_start_date < b_end_date
--            3. both end_date can be open (null)
-- --------------------------------------------------------------------------=
PROCEDURE get_date_range_diff    ( a_start_date   DATE,
           a_end_date     DATE,
           b_start_date   DATE,
           b_end_date     DATE,
           x_date_range_tbl OUT NOCOPY date_range_tbl_type ) IS

   l_counter  NUMBER := 0;
BEGIN

   IF cn_api.date_range_overlap( a_start_date, a_end_date,
				 b_start_date, b_end_date )
     THEN  -- there is overlap
      -- first, check the start dates
      IF a_start_date> b_start_date THEN
	 l_counter := l_counter + 1;
	 x_date_range_tbl(l_counter).start_date := b_start_date;
	 x_date_range_tbl(l_counter).end_date   := a_start_date-1;
       ELSIF a_start_date< b_start_date THEN
	 l_counter := l_counter + 1;
	 x_date_range_tbl(l_counter).start_date := a_start_date;
	 x_date_range_tbl(l_counter).end_date   := b_start_date-1;
      END IF;

      -- second, check end dates
      IF a_end_date IS NULL AND b_end_date IS NULL THEN
	 NULL;
       ELSIF (a_end_date IS NULL AND b_end_date IS NOT NULL ) THEN
	 l_counter := l_counter + 1;
	 x_date_range_tbl(l_counter).start_date := b_end_date + 1;
	 x_date_range_tbl(l_counter).end_date   := NULL;
       ELSIF (a_end_date IS NOT NULL AND b_end_date IS NULL ) THEN
	 l_counter := l_counter + 1;
	 x_date_range_tbl(l_counter).start_date := a_end_date + 1;
	 x_date_range_tbl(l_counter).end_date   := NULL;
       ELSE -- a_end_date IS NOT NULL AND b_end_date IS NOT NULL
	 IF a_end_date > b_end_date THEN
	    l_counter := l_counter + 1;
	    x_date_range_tbl(l_counter).start_date := b_end_date + 1;
	    x_date_range_tbl(l_counter).end_date   := a_end_date;
	  ELSIF a_end_date < b_end_date THEN
	    l_counter := l_counter + 1;
	    x_date_range_tbl(l_counter).start_date := a_end_date + 1;
	    x_date_range_tbl(l_counter).end_date   := b_end_date;
	 END IF;
      END IF;
    ELSE -- there is no overlap
      l_counter := l_counter + 1;
      x_date_range_tbl(l_counter).start_date := a_start_date;
      x_date_range_tbl(l_counter).end_date   := a_end_date;

      l_counter := l_counter + 1;
      x_date_range_tbl(l_counter).start_date := b_start_date;
      x_date_range_tbl(l_counter).end_date   := b_end_date;
   END IF;
END get_date_range_diff   ;

-- -------------------------------------------------------------------------+
-- PROCEDURE : get_date_range_intersect
-- Desc     : get the intersection of two date ranges
--            Assuming
--            1. a_start_date is not null and a_start_date < a_end_date
--            2. b_start_date is not null and b_start_date < b_end_date
--            3. both end_date can be open (null)
--            4. the two date ranges overlap
-- -------------------------------------------------------------------------+
PROCEDURE get_date_range_intersect
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE,
   x_start_date   OUT NOCOPY DATE,
   x_end_date     OUT NOCOPY DATE) IS

BEGIN

      IF a_start_date> b_start_date THEN
   x_start_date := a_start_date;
       ELSIF a_start_date<= b_start_date THEN
   x_start_date := b_start_date;
      END IF;

      IF a_end_date IS NULL AND b_end_date IS NULL THEN
   x_end_date := NULL;

      ELSIF (a_end_date IS NULL AND b_end_date IS NOT NULL ) THEN
   x_end_date := b_end_date;

      ELSIF (a_end_date IS NOT NULL AND b_end_date IS NULL ) THEN
   x_end_date := a_end_date;

      ELSE
   IF a_end_date > b_end_date THEN
      x_end_date := b_end_date;
    ELSIF a_end_date <= b_end_date THEN
      x_end_date := a_end_date;
   END IF;
      END IF;

END get_date_range_intersect;

-- ---------------------------------------------------------------------------=
-- PROCEDURE : get_date_range_overlap
-- Desc     : get the overlap portion of the two date ranges
--            Assuming
--            1. a_start_date is not null and a_start_date < a_end_date
--            2. b_start_date is not null and b_start_date < b_end_date
--            3. both end_date can be open (null)
-- ---------------------------------------------------------------------------=
PROCEDURE get_date_range_overlap (a_start_date   DATE,
          a_end_date     DATE,
          b_start_date   DATE,
	  b_end_date     DATE,
	  p_org_id       NUMBER,
          x_date_range_tbl OUT NOCOPY date_range_tbl_type ) IS

   l_start_date   DATE;
   l_end_date     DATE;

   CURSOR l_last_date_cr IS

      -- fixed query for bug 5075017
      SELECT MAX(end_date)
	FROM cn_acc_period_statuses_v
       WHERE period_status IN ('F', 'O')
         AND org_id = p_org_id;

BEGIN
   IF cn_api.date_range_overlap( a_start_date, a_end_date,
         b_start_date, b_end_date )
     THEN  -- there is overlap
      -- first, check the start dates
      IF a_start_date> b_start_date THEN
   l_start_date := a_start_date;
       ELSIF a_start_date<= b_start_date THEN
   l_start_date := b_start_date;
      END IF;

      -- second, check end dates
      IF a_end_date IS NULL AND b_end_date IS NULL THEN

   OPEN l_last_date_cr;
   FETCH l_last_date_cr INTO l_end_date;

   IF (l_last_date_cr%notfound) THEN

      l_end_date := NULL;

   END IF;

       ELSIF (a_end_date IS NULL AND b_end_date IS NOT NULL ) THEN
   l_end_date := b_end_date;
       ELSIF (a_end_date IS NOT NULL AND b_end_date IS NULL ) THEN
   l_end_date := a_end_date;
       ELSE -- a_end_date IS NOT NULL AND b_end_date IS NOT NULL
   IF a_end_date > b_end_date THEN
      l_end_date := b_end_date;
    ELSIF a_end_date <= b_end_date THEN
      l_end_date := a_end_date;
   END IF;
      END IF;

      x_date_range_tbl(1).start_date := l_start_date;
      x_date_range_tbl(1).end_date := l_end_date;
   END IF;
END get_date_range_overlap;

-- ---------------------------------------------------------------------------=
-- FUNCTION: get_acc_period_id
-- Desc     : get the accumulation period_id given the date
--            If the date is null, will return the latest accumulation period
--            with period_status = 'O'
-- --------------------------------------------------------------------------=
FUNCTION get_acc_period_id (p_date   DATE, p_org_id NUMBER) RETURN NUMBER IS
   CURSOR l_date_period_csr IS
      SELECT period_id
  FROM cn_acc_period_statuses_v
  WHERE p_date BETWEEN start_date AND end_date
  AND org_id = p_org_id;

   CURSOR l_null_date_period_csr IS
      SELECT MAX(period_id)
  FROM cn_acc_period_statuses_v
    WHERE period_status = 'O'
    AND org_id = p_org_id;

   l_period_id  NUMBER(15);

BEGIN
   IF p_date IS NOT NULL THEN
      OPEN l_date_period_csr;
      FETCH l_date_period_csr INTO l_period_id;
      CLOSE l_date_period_csr;
   END IF;

   IF (l_period_id IS NULL) THEN
      OPEN l_null_date_period_csr;
      FETCH l_null_date_period_csr INTO l_period_id;
      CLOSE l_null_date_period_csr;
   END IF;

      RETURN l_period_id;
EXCEPTION WHEN OTHERS THEN
   IF l_date_period_csr%isopen THEN
      CLOSE l_date_period_csr;
   END IF;

   IF l_null_date_period_csr%isopen THEN
      CLOSE l_null_date_period_csr;
   END IF;

   RAISE;

END get_acc_period_id;


-- ---------------------------------------------------------------------------=
-- FUNCTION: get_acc_period_id_fo
-- Desc     : get the accumulation period_id given the date
--            If the date is null, will return the first accumulation period
--            with period_status = 'O'
-- --------------------------------------------------------------------------=
FUNCTION get_acc_period_id_fo (p_date   DATE, p_org_id NUMBER) RETURN NUMBER IS

   CURSOR l_date_period_csr IS
      SELECT period_id
  FROM cn_acc_period_statuses_v
  WHERE p_date BETWEEN start_date AND end_date
  AND org_id = p_org_id;

   CURSOR l_null_date_period_csr IS
      SELECT MIN(period_id)
  FROM cn_acc_period_statuses_v
    WHERE period_status = 'O'
    AND org_id = p_org_id;

   l_period_id  NUMBER(15);

BEGIN
   IF p_date IS NOT NULL THEN
      OPEN l_date_period_csr;
      FETCH l_date_period_csr INTO l_period_id;
      CLOSE l_date_period_csr;
   END IF;

   IF (l_period_id IS NULL) THEN
      OPEN l_null_date_period_csr;
      FETCH l_null_date_period_csr INTO l_period_id;
      CLOSE l_null_date_period_csr;
   END IF;

      RETURN l_period_id;
EXCEPTION WHEN OTHERS THEN
   IF l_date_period_csr%isopen THEN
      CLOSE l_date_period_csr;
   END IF;

   IF l_null_date_period_csr%isopen THEN
      CLOSE l_null_date_period_csr;
   END IF;

   RAISE;

END get_acc_period_id_fo;

--| -----------------------------------------------------------------------=
--| Procedure Name : check_revenue_class_overlap
--| Desc : Pass in Comp  Plan ID
--|        pass in Comp Plan Name
--| Note:  Comented out the overlap check
--| ---------------------------------------------------------------------=
PROCEDURE  check_revenue_class_overlap
  (
   p_comp_plan_id  IN NUMBER,
   p_rc_overlap    IN VARCHAR2,
   p_loading_status IN VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2 ) IS

   l_rev_class_total        NUMBER := 0;
   l_rev_class_total_unique NUMBER := 0;
   l_comp_plan_name         cn_comp_plans.name%TYPE;
   l_rc_overlap             VARCHAR2(03);
   l_sum_trx_flag           VARCHAR2(03); -- commented for bug 7655423 / uncommented for f port of 7330382

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   BEGIN
      SELECT name, Nvl(p_rc_overlap,allow_rev_class_overlap),sum_trx_flag  -- commented for bug 7655423
  INTO l_comp_plan_name,l_rc_overlap,l_sum_trx_flag
  FROM cn_comp_plans_all
  WHERE comp_plan_id = p_comp_plan_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_COMP_PLAN');
      FND_MSG_PUB.Add;
   END IF;
   x_loading_status := 'CN_INVALID_COMP_PLAN';
   x_return_status  :=  FND_API.G_RET_STS_ERROR;
   END ;

   IF l_rc_overlap = 'N' THEN
      -- The function below adds the message
      IF CN_COMP_PLANS_PKG.check_unique_rev_class
	(p_comp_plan_id,l_comp_plan_name,l_rc_overlap,l_sum_trx_flag) = FALSE THEN
          x_loading_status := 'PLN_PLAN_DUP_REV_CLASS';
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF ;
   END IF;

END check_revenue_class_overlap;
--| -----------------------------------------------------------------------=
--| Function Name :  get_comp_group_name
--| Desc : Pass in comp_group id then return comp_group name
--| ---------------------------------------------------------------------=
FUNCTION  get_comp_group_name( p_comp_group_id  NUMBER)
  RETURN cn_comp_groups.name%TYPE IS

  l_comp_group_name cn_comp_groups.name%TYPE;

BEGIN
   SELECT name
     INTO l_comp_group_name
     FROM cn_comp_groups
     WHERE comp_group_id = p_comp_group_id;

   RETURN l_comp_group_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_comp_group_name;

--| -----------------------------------------------------------------------=
--| Function Name :  get_order_booked_date
--| Desc : Pass in order header_id then return date order was booked (or NULL)
--| ---------------------------------------------------------------------=
/* See comment in  file header (DEC-20-99)
FUNCTION  get_order_booked_date(p_order_header_id  NUMBER) RETURN DATE IS
   l_booked_flag VARCHAR2(1);
   l_booked_date DATE;
BEGIN
-- This is what we need to call, but we can't - it violates the function pragma
-- Because of this , I have copied in the code out of this procedure
--   oe_header_status_pub.get_booked_status(p_order_header_id,
--                                        l_booked_flag,
--                                        l_booked_date);
   SELECT nvl(booked_flag, 'N')
   INTO l_booked_flag
   FROM aso_i_oe_order_headers_v
   WHERE header_id = p_order_header_id;

   IF l_booked_flag = 'Y' THEN
      SELECT end_date
      INTO l_booked_date
      FROM wf_item_activity_statuses
      WHERE item_type = OE_GLOBALS.G_WFI_HDR
         AND item_key = p_order_header_id
         AND process_activity IN (SELECT wpa.instance_id
                                 FROM  wf_process_activities wpa
                                 WHERE wpa.activity_item_type = OE_GLOBALS.G_WFI_HDR
                                       AND wpa.activity_name = 'BOOK_ORDER');
   ELSE
  l_booked_date := NULL;
   END IF;
   RETURN l_booked_date;
END get_order_booked_date;
*/


--| -----------------------------------------------------------------------=
--| Function Name :  get_site_address_id
--| Desc : Pass in order site_use_id then return address_id of 'use site'
--|        (gets address_id out of RA_SITE_USES)
--| ---------------------------------------------------------------------=
FUNCTION  get_site_address_id(p_site_use_id  NUMBER, p_org_id NUMBER ) RETURN NUMBER IS

   CURSOR l_address_id_csr IS
      SELECT cust_acct_site_id
      FROM hz_cust_site_uses
   WHERE site_use_id = p_site_use_id
   AND org_id = p_org_id;
   l_address_id NUMBER;

BEGIN

   IF p_site_use_id IS NOT NULL THEN

      OPEN l_address_id_csr;
      FETCH l_address_id_csr INTO l_address_id;
      CLOSE l_address_id_csr;
      RETURN l_address_id;


   ELSE
      RETURN NULL;
   END IF;

EXCEPTION WHEN OTHERS THEN

   IF l_address_id_csr%isopen THEN
      CLOSE l_address_id_csr;
   END IF;

   RAISE;

END get_site_address_id;

--| -----------------------------------------------------------------------=
--| Function Name :  get_order_revenue_type
--| Desc : Derives the Revenue Type of an order, in the format required by
--|        CN
--| ---------------------------------------------------------------------=
FUNCTION  get_order_revenue_type(p_sales_credit_type_id  NUMBER) RETURN VARCHAR2 IS

   CURSOR l_qu_flag_csr IS
      SELECT quota_flag
      FROM   aso_i_sales_credit_types_v
   WHERE  sales_credit_type_id = p_sales_credit_type_id;
   l_qu_flag VARCHAR2(1);

BEGIN
   IF p_sales_credit_type_id IS NOT NULL THEN
       OPEN l_qu_flag_csr;
       FETCH l_qu_flag_csr INTO l_qu_flag;
       CLOSE l_qu_flag_csr;
       IF l_qu_flag = 'Y' THEN
           RETURN 'REVENUE';
       ELSE
           RETURN 'NONREVENUE';
       END IF;
   ELSE
       RETURN NULL;
   END IF;

EXCEPTION WHEN OTHERS THEN
   IF l_qu_flag_csr%isopen THEN
      CLOSE l_qu_flag_csr;
   END IF;
   RAISE;

END get_order_revenue_type;


-- |------------------------------------------------------------------------=
-- | Function Name : get_credit_info
-- |
-- | Description   : Procedure to return precision and extended precision for credit
-- |                 types
-- |-------------------------------------------------------------------------=
PROCEDURE get_credit_info
  (p_credit_type_name IN  cn_credit_types.name%TYPE, /* credit type name */
   x_precision      OUT NOCOPY NUMBER, /* number of digits to right of decimal*/
   x_ext_precision  OUT NOCOPY NUMBER, /* precision where more precision is needed*/
   p_org_id   NUMBER
   )  IS

BEGIN

   SELECT PRECISION, EXTENDED_PRECISION
     INTO x_precision, x_ext_precision
     FROM cn_credit_types
     WHERE name = p_credit_type_name
     AND org_id = p_org_id;

   /* Precision should never be NULL; this is just so it works w/ bad data*/
   IF (x_precision IS NULL)
     THEN /* Default precision to two if necessary. */
      x_precision := 2;
   END IF;

   /* Ext Precision should never be NULL; this is so it works w/ bad data*/
   IF (x_ext_precision IS NULL)
     THEN /* Default ext_precision if necc. */
      x_ext_precision := 5;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_precision := 0;
      x_ext_precision := 0;
END;


--| -----------------------------------------------------------------------=
--| Function Name :  convert_to_repcurr
--| Desc : Convert from credit unit into salesrep currency amount
--| ---------------------------------------------------------------------=
FUNCTION  convert_to_repcurr
  (p_credit_unit         IN NUMBER,
   p_conv_date           IN DATE ,
   p_conv_type           IN VARCHAR2,
   p_from_credit_type_id IN NUMBER,
   p_funcurr_code        IN VARCHAR2,
   p_repcurr_code        IN VARCHAR2,
   p_org_id              IN NUMBER
  ) RETURN NUMBER IS

     l_monetary_flag  cn_credit_types.monetary_flag%TYPE;
     l_conv_date      DATE;
     l_conv_amount    NUMBER;
     l_repcurr_amount NUMBER;

     CURSOR get_closest_date IS
  SELECT start_date
    FROM cn_credit_conv_fcts_all
    WHERE from_credit_type_id = p_from_credit_type_id
    AND   to_credit_type_id = -1000
    AND   start_date <= p_conv_date
    AND org_id = p_org_id
    ORDER BY start_date DESC ;

     l_date DATE;

BEGIN

   SELECT monetary_flag into l_monetary_flag
     FROM cn_credit_types_all
     WHERE credit_type_id = p_from_credit_type_id
     AND org_id = p_org_id;

   IF (l_monetary_flag = 'N') THEN
      BEGIN
   SELECT conversion_factor * Nvl(p_credit_unit,0)
     INTO l_conv_amount
     FROM cn_credit_conv_fcts_all
     WHERE from_credit_type_id = p_from_credit_type_id
     AND   to_credit_type_id = -1000
     AND org_id = p_org_id
     AND   p_conv_date between start_date and nvl(end_date, p_conv_date)
     ;
      EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- if no conv_factor defined for p_conv_date, trace back to
      -- closest defined date before p_conv_date
      OPEN  get_closest_date;
      FETCH get_closest_date INTO l_date;
      IF NOT get_closest_date%FOUND THEN
         CLOSE get_closest_date;
         RAISE NO_DATA_FOUND;
       ELSE
         SELECT conversion_factor * Nvl(p_credit_unit,0)
     INTO l_conv_amount
     FROM cn_credit_conv_fcts_all
     WHERE from_credit_type_id = p_from_credit_type_id
     AND   to_credit_type_id = -1000
     AND org_id = p_org_id
     AND   l_date between start_date and nvl(end_date, l_date)
     ;
      END IF;
      CLOSE get_closest_date;
      END;
    ELSE
      SELECT Nvl(p_credit_unit,0) INTO l_conv_amount
  FROM sys.dual;
   END IF;

   l_repcurr_amount :=
     gl_currency_api.convert_amount
     (x_from_currency => p_funcurr_code,
      x_to_currency   => p_repcurr_code,
      x_conversion_date => p_conv_date,
      x_conversion_type => p_conv_type,
      x_amount        => l_conv_amount
      );

   RETURN l_repcurr_amount;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('CN','CN_CRCVFT_NOT_EXIST');
      FND_MSG_PUB.Add;
      APP_EXCEPTION.raise_exception;
END convert_to_repcurr;



--| -----------------------------------------------------------------------=
--| PROCEDURE Name :  convert_to_repcurr_report
--| Desc : Convert from credit unit into salesrep currency amount
--|        Called by reports.
--| ---------------------------------------------------------------------=
PROCEDURE  convert_to_repcurr_report
  (p_credit_unit         IN NUMBER,
   p_conv_date           IN DATE ,
   p_conv_type           IN VARCHAR2,
   p_from_credit_type_id IN NUMBER,
   p_funcurr_code        IN VARCHAR2,
   p_repcurr_code        IN VARCHAR2,
   x_repcurr_amount      OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   p_org_id              IN NUMBER
  ) IS

     l_monetary_flag  cn_credit_types.monetary_flag%TYPE;
     l_conv_date      DATE;
     l_conv_amount    NUMBER;

     CURSOR get_closest_date IS
  SELECT start_date
    FROM cn_credit_conv_fcts_all
    WHERE from_credit_type_id = p_from_credit_type_id
    AND   to_credit_type_id = -1000
    AND   Trunc(start_date) <= Trunc(p_conv_date)
    AND org_id = p_org_id
    ORDER BY start_date DESC ;

     l_date DATE;

BEGIN

   x_return_status := 'S';
--   dbms_output.put_line('p_conv_date = ' || p_conv_date);
--   dbms_output.put_line('p_conv_type = ' || p_conv_type);
--   dbms_output.put_line('p_from_credit_type_id = ' || p_from_credit_type_id);
--   dbms_output.put_line('p_funcurr_code = '|| p_funcurr_code);
--   dbms_output.put_line('p_repcurr_code = ' ||  p_repcurr_code);

   SELECT monetary_flag into l_monetary_flag
     FROM cn_credit_types_all
     WHERE credit_type_id = p_from_credit_type_id
     AND org_id = p_org_id;

--   dbms_output.put_line('l_monetary_flag = ' || l_monetary_flag);

   IF (l_monetary_flag = 'N') THEN
      BEGIN
   SELECT conversion_factor * Nvl(p_credit_unit,0)
     INTO l_conv_amount
     FROM cn_credit_conv_fcts_all
     WHERE from_credit_type_id = p_from_credit_type_id
     AND   to_credit_type_id = -1000
     AND org_id = p_org_id
     AND   p_conv_date between start_date and nvl(end_date, p_conv_date)
     ;
--   dbms_output.put_line('l_conv_amount = ' || l_conv_amount);

      EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- if no conv_factor defined for p_conv_date, trace back to
      -- closest defined date before p_conv_date
--      dbms_output.put_line('no data found -- 1');
      OPEN  get_closest_date;
      FETCH get_closest_date INTO l_date;
--      dbms_output.put_line('l_date = ' || l_date);
      IF NOT get_closest_date%FOUND THEN
         CLOSE get_closest_date;
         RAISE NO_DATA_FOUND;
       ELSE
         SELECT conversion_factor * Nvl(p_credit_unit,0)
     INTO l_conv_amount
     FROM cn_credit_conv_fcts_all
     WHERE from_credit_type_id = p_from_credit_type_id
     AND   to_credit_type_id = -1000
     AND org_id = p_org_id
     AND   l_date between start_date and nvl(end_date, l_date);
--    dbms_output.put_line('l_conv_amount = ' || l_conv_amount);
      END IF;
      CLOSE get_closest_date;
      END;
    ELSE
      SELECT Nvl(p_credit_unit,0) INTO l_conv_amount
  FROM sys.dual;
   END IF;

--   dbms_output.put_line('p_conv_date = ' || p_conv_date);
--   dbms_output.put_line('p_conv_type = ' || p_conv_type);
--   dbms_output.put_line('l_conv_amount = ' || l_conv_amount);
--   dbms_output.put_line('p_funcurr_code = '|| p_funcurr_code);
--   dbms_output.put_line('p_repcurr_code = ' ||  p_repcurr_code);

   x_repcurr_amount :=
     gl_currency_api.convert_amount
     (x_from_currency => p_funcurr_code,
      x_to_currency   => p_repcurr_code,
      x_conversion_date => p_conv_date,
      x_conversion_type => p_conv_type,
      x_amount        => l_conv_amount
      );


EXCEPTION
   WHEN NO_DATA_FOUND THEN
--      dbms_output.put_line('no data found --2 ');
      FND_MESSAGE.SET_NAME('CN','CN_CRCVFT_NOT_EXIST');
      FND_MSG_PUB.Add;
      x_return_status := 'E';
END convert_to_repcurr_report;



--| -----------------------------------------------------------------------=
--| Function Name :  g_miss_char
--| Desc : function to return FND_API.g_miss_char
--| ---------------------------------------------------------------------=
FUNCTION g_miss_char RETURN VARCHAR2 IS
BEGIN
   RETURN fnd_api.g_miss_char;
END g_miss_char;

--| -----------------------------------------------------------------------=
--| Function Name :  g_miss_date
--| Desc : function to return FND_API.g_miss_date
--| ---------------------------------------------------------------------=
FUNCTION g_miss_date RETURN DATE IS
BEGIN
   RETURN fnd_api.g_miss_date;
END g_miss_date;

--| -----------------------------------------------------------------------=
--| Function Name :  g_miss_num
--| Desc : function to return FND_API.g_miss_num
--| ---------------------------------------------------------------------=
FUNCTION g_miss_num RETURN NUMBER IS
BEGIN
   RETURN fnd_api.g_miss_num;
END g_miss_num;

--| -----------------------------------------------------------------------=
--| Function Name :  g_miss_id
--| Desc : function to return -99999999999999
--| ---------------------------------------------------------------------=
FUNCTION g_miss_id RETURN NUMBER IS
BEGIN
   RETURN -99999999999999;
END g_miss_id;

--| -----------------------------------------------------------------------=
--| Function Name :  g_false
--| Desc : function to return FND_API.g_false
--| ---------------------------------------------------------------------=
FUNCTION g_false RETURN VARCHAR2 IS
BEGIN
   RETURN fnd_api.g_false;
END g_false;

--| -----------------------------------------------------------------------=
--| Function Name :  g_true
--| Desc : function to return FND_API.g_true
--| ---------------------------------------------------------------------=
FUNCTION g_true RETURN VARCHAR2 IS
BEGIN
   RETURN fnd_api.g_true;
END g_true;

--| -----------------------------------------------------------------------=
--| Function Name :  g_valid_level_none
--| Desc : function to return FND_API.G_VALID_LEVEL_NONE
--| ---------------------------------------------------------------------=
FUNCTION g_valid_level_none RETURN NUMBER IS
BEGIN
   RETURN fnd_api.g_valid_level_none;
END g_valid_level_none;

--| -----------------------------------------------------------------------=
--| Function Name :  g_valid_level_full
--| Desc : function to return FND_API.G_VALID_LEVEL_FULL
--| ---------------------------------------------------------------------=
FUNCTION g_valid_level_full RETURN NUMBER IS
BEGIN
   RETURN fnd_api.g_valid_level_full;
END g_valid_level_full;




--| -----------------------------------------------------------------------=
--| Function Name :  generate code combinations
--| Desc :
--| ---------------------------------------------------------------------=
PROCEDURE get_ccids
  (p_account_type IN varchar2,
   p_org_id       IN NUMBER,
   x_account_structure OUT NOCOPY varchar2,
   x_code_combinations OUT NOCOPY code_combination_tbl) IS

   kff        fnd_flex_key_api.flexfield_type;
   str        fnd_flex_key_api.structure_type;
   seg        fnd_flex_key_api.segment_type;
   seg_list   fnd_flex_key_api.segment_list;
   j          number;
   i          number;
   nsegs      number;
   segment_descr varchar2(2000);
   sql_stmt   varchar2(2000);
   l_chart_of_accounts_id gl_sets_of_books.chart_of_accounts_id%TYPE;

   l_counter NUMBER := 0;
   ccid     NUMBER;
   ccid_value VARCHAR2(2000);
   l_account_type    gl_code_combinations.account_type%type;

   TYPE curtype IS ref CURSOR;
   ccid_cur curtype;

BEGIN

   SELECT chart_of_accounts_id
     INTO l_chart_of_accounts_id
     FROM gl_sets_of_books gsb,
     cn_repositories_all cr
     WHERE cr.set_of_books_id = gsb.set_of_books_id
     AND cr.org_id = p_org_id;

   fnd_flex_key_api.set_session_mode('customer_data');
   kff := fnd_flex_key_api.find_flexfield('SQLGL','GL#');
   str := fnd_flex_key_api.find_structure(kff, l_chart_of_accounts_id);
   fnd_flex_key_api.get_segments(kff, str, TRUE, nsegs, seg_list);

   -- The segments in the seg_list array are sorted in display order.
   -- i.e. sorted by segment number.
   sql_stmt := 'SELECT ';
   for i in 1..nsegs loop
    seg := fnd_flex_key_api.find_segment(kff, str, seg_list(i));
    segment_descr := segment_descr || seg.segment_name;
    sql_stmt := sql_stmt || seg.column_name;
    If i <> nsegs
    then
      segment_descr := segment_descr || str.segment_separator;
      sql_stmt := sql_stmt || '||'''||str.segment_separator||'''||';
    end if;
   end loop;
   x_account_structure := segment_descr;
   sql_stmt := sql_stmt ||
     ', code_combination_id, account_type '||
     ' FROM gl_code_combinations '||
     ' WHERE chart_of_accounts_id = :B1' ||
     ' AND enabled_flag = ''Y''';

-- commented out by KS.
-- Using Bind Variables
-- ||l_chart_of_accounts_id||

   OPEN ccid_cur FOR sql_stmt using l_chart_of_accounts_id;
     LOOP

     ccid_value := null;
     ccid := null;
     l_account_type := null;

  FETCH ccid_cur INTO
         ccid_value, ccid,
         l_account_type;
  EXIT WHEN ccid_cur%notfound;

      IF l_account_type = p_account_type
       THEN
       x_code_combinations(l_counter).ccid   := ccid;
       x_code_combinations(l_counter).code_combination   :=  ccid_value;
         l_counter := l_counter + 1;
       END IF;

     END LOOP;
     CLOSE ccid_cur;
END get_ccids;

--| -----------------------------------------------------------------------=
--| Function Name :  get code combination in display format
--| Desc :
--| ---------------------------------------------------------------------=
PROCEDURE get_ccid_disp
  (p_ccid IN varchar2,
   p_org_id IN NUMBER,
   x_code_combination OUT NOCOPY varchar2) IS

   kff        fnd_flex_key_api.flexfield_type;
   str        fnd_flex_key_api.structure_type;
   seg        fnd_flex_key_api.segment_type;
   seg_list   fnd_flex_key_api.segment_list;
   j          number;
   i          number;
   nsegs      number;
   segment_descr varchar2(2000);
   sql_stmt   varchar2(2000);
   l_chart_of_accounts_id gl_sets_of_books.chart_of_accounts_id%TYPE;

   l_counter NUMBER := 0;
   ccid     NUMBER;
   ccid_value VARCHAR2(2000);
   l_account_type    gl_code_combinations.account_type%type;

   TYPE curtype IS ref CURSOR;
   ccid_cur curtype;

BEGIN

   SELECT chart_of_accounts_id
     INTO l_chart_of_accounts_id
     FROM gl_sets_of_books gsb,
     cn_repositories_all cr
     WHERE cr.set_of_books_id = gsb.set_of_books_id
     AND org_id = p_org_id;

   fnd_flex_key_api.set_session_mode('customer_data');
   kff := fnd_flex_key_api.find_flexfield('SQLGL','GL#');
   str := fnd_flex_key_api.find_structure(kff, l_chart_of_accounts_id);
   fnd_flex_key_api.get_segments(kff, str, TRUE, nsegs, seg_list);

   -- The segments in the seg_list array are sorted in display order.
   -- i.e. sorted by segment number.
   sql_stmt := 'SELECT ';
   for i in 1..nsegs loop
    seg := fnd_flex_key_api.find_segment(kff, str, seg_list(i));
    segment_descr := segment_descr || seg.segment_name;
    sql_stmt := sql_stmt || seg.column_name;
    If i <> nsegs
    then
      segment_descr := segment_descr || str.segment_separator;
      sql_stmt := sql_stmt || '||'''||str.segment_separator||'''||';
    end if;
   end loop;
   sql_stmt := sql_stmt ||
     ', code_combination_id, account_type '||
     ' FROM gl_code_combinations '||
     ' WHERE code_combination_id = :B1';

-- commented out by KS
-- 09/28/01
-- ||p_ccid;

   OPEN ccid_cur FOR sql_stmt using p_ccid;
     LOOP

     ccid_value := null;
     ccid := null;
     l_account_type := null;

  FETCH ccid_cur INTO
         ccid_value, ccid,
         l_account_type;
  EXIT WHEN ccid_cur%notfound;

       x_code_combination  :=  ccid_value;
         l_counter := l_counter + 1;
     END LOOP;
     CLOSE ccid_cur;
END get_ccid_disp;


--| -----------------------------------------------------------------------=
--| Function Name :  get code combination in display format
--| Desc :
--| ---------------------------------------------------------------------=
FUNCTION get_ccid_disp_func
  (p_ccid IN varchar2, p_org_id IN NUMBER ) RETURN VARCHAR2 IS

   kff        fnd_flex_key_api.flexfield_type;
   str        fnd_flex_key_api.structure_type;
   seg        fnd_flex_key_api.segment_type;
   seg_list   fnd_flex_key_api.segment_list;
   j          number;
   i          number;
   nsegs      number;
   segment_descr varchar2(2000);
   sql_stmt   varchar2(2000);

   l_code    Varchar2(4000);


   l_chart_of_accounts_id gl_sets_of_books.chart_of_accounts_id%TYPE;

   l_counter NUMBER := 0;
   ccid     NUMBER;
   ccid_value VARCHAR2(2000);
   l_account_type    gl_code_combinations.account_type%type;

   TYPE curtype IS ref CURSOR;
   ccid_cur curtype;

BEGIN

   SELECT chart_of_accounts_id
     INTO l_chart_of_accounts_id
     FROM gl_sets_of_books gsb,
     cn_repositories_all cr
     WHERE cr.set_of_books_id = gsb.set_of_books_id
     AND org_id = p_org_id;

   fnd_flex_key_api.set_session_mode('customer_data');
   kff := fnd_flex_key_api.find_flexfield('SQLGL','GL#');
   str := fnd_flex_key_api.find_structure(kff, l_chart_of_accounts_id);
   fnd_flex_key_api.get_segments(kff, str, TRUE, nsegs, seg_list);

   -- The segments in the seg_list array are sorted in display order.
   -- i.e. sorted by segment number.
   sql_stmt := 'SELECT ';
   for i in 1..nsegs loop
    seg := fnd_flex_key_api.find_segment(kff, str, seg_list(i));
    segment_descr := segment_descr || seg.segment_name;
    sql_stmt := sql_stmt || seg.column_name;
    If i <> nsegs
    then
      segment_descr := segment_descr || str.segment_separator;
      sql_stmt := sql_stmt || '||'''||str.segment_separator||'''||';
    end if;
   end loop;
   sql_stmt := sql_stmt ||
     ', code_combination_id, account_type '||
     ' FROM gl_code_combinations '||
     ' WHERE code_combination_id =  :B1' ;

-- commented out by KS
-- 09/28/01
-- ||p_ccid;


   OPEN ccid_cur FOR sql_stmt using p_ccid;
     LOOP

     ccid_value := null;
     ccid := null;
     l_account_type := null;

  FETCH ccid_cur INTO
         ccid_value, ccid,
         l_account_type;
  EXIT WHEN ccid_cur%notfound;

       l_code  :=  ccid_value;
         l_counter := l_counter + 1;
     END LOOP;
     CLOSE ccid_cur;

     return l_code;

END get_ccid_disp_func;


--| ---------------------------------------------------------------------+
--| Function Name :  attribute_desc
--| Desc : Pass in rule_id, rule_attribute_id
--| ---------------------------------------------------------------------+
FUNCTION  get_attribute_desc( p_rule_id NUMBER,
                            p_attribute_id NUMBER )
  RETURN VARCHAR2 IS

  l_desc  cn_rule_attributes_desc_v.descriptive_rule_attribute%TYPE;

BEGIN
     SELECT descriptive_rule_attribute
       INTO l_desc
       FROM cn_rule_attributes_desc_v
       WHERE rule_id = p_rule_id
       AND   attribute_rule_id  = p_attribute_id ;

     RETURN l_desc;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
END get_attribute_desc;


--| ---------------------------------------------------------------------+
--| Function Name :  rule_count
--| Desc : Pass in rule_id
--| ---------------------------------------------------------------------+
FUNCTION  get_rule_count( p_rule_id NUMBER)

  RETURN NUMBER IS

  l_count  NUMBER := 1;

BEGIN
     SELECT count(*)
       INTO l_count
       FROM cn_attribute_rules
       WHERE rule_id = p_rule_id;

     if l_count = 0 then
        l_count := 1;
    end if;

    RETURN l_count;

EXCEPTION
   WHEN no_data_found THEN
      RETURN 1;
END get_rule_count;

-- ===========================================================================
--   Function   : chk_Payrun_status_paid
--   Description : Check for valid payrun_id, Status must be unpaid
-- ===========================================================================
FUNCTION chk_payrun_status_paid
  ( p_payrun_id             IN  NUMBER,
    p_loading_status         IN  VARCHAR2,
    x_loading_status         OUT NOCOPY VARCHAR2
    ) RETURN VARCHAR2 IS

       CURSOR get_payrun_status IS
          SELECT status, payrun_id
            FROM cn_payruns
            WHERE payrun_id = p_payrun_id;

       l_status cn_payruns.status%TYPE;
       l_payrun_id cn_payruns.payrun_id%TYPE;

BEGIN
   --  Initialize API return status to success
   x_loading_status := p_loading_status ;

   -- Get Payrun Status
   OPEN get_payrun_status;
   FETCH get_payrun_status INTO l_status, l_payrun_id;
   CLOSE get_payrun_status;

   -- check payrun status, No operation can be done for PAID
   IF l_status <>  'UNPAID'  THEN
     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_CANNOT_UPD_PAID_F_PAYRUN');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_CANNOT_UPD_PAID_F_PAYRUN';
      RETURN fnd_api.g_true;
   END IF;

   -- check payrun exists
   IF l_payrun_id  IS NULL THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_PAYRUN_DOES_NOT_EXIST');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_PAYRUN_DOES_NOT_EXIST';
      RETURN fnd_api.g_true;
   END IF;

   RETURN fnd_api.g_false;

END chk_payrun_status_paid;
-- ===========================================================================
--   Procedure   : Chk_hold_status
--   Description : This procedure is used to check if the salesrep is on hold
--         and valid salesrep ID is passed
-- ===========================================================================
FUNCTION chk_hold_status
  (
   p_salesrep_id            IN  NUMBER,
   p_org_id                 IN  NUMBER,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2 IS

      CURSOR get_hold_status IS
         SELECT hold_payment, salesrep_id
           FROM cn_salesreps
           WHERE salesrep_id = p_salesrep_id
	     AND org_id      = p_org_id;

      l_status cn_payruns.status%TYPE;
      l_salesrep_id cn_salesreps.salesrep_id%TYPE;

BEGIN

   x_loading_status := p_loading_status ;

   OPEN get_hold_status;
   FETCH get_hold_status INTO l_status,l_salesrep_id;
   CLOSE get_hold_status;

   IF l_status = 'Y' THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         fnd_message.set_name('CN', 'CN_SRP_ON_HOLD');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_SRP_ON_HOLD';
      RETURN fnd_api.g_true;
   END IF;

   IF l_salesrep_id IS NULL THEN
      x_loading_status := 'CN_SRP_NOT_EXISTS';
     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_SRP_NOT_EXISTS');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_SRP_NOT_EXISTS';
      RETURN fnd_api.g_true;
   END IF;

   RETURN fnd_api.g_false;
END chk_hold_status;

-- ===========================================================================
--   Procedure   : Chk_srp_hold_status
--   Description : This procedure is used to check if the salesrep is on hold
--         and valid salesrep ID is passed
-- ===========================================================================
FUNCTION chk_srp_hold_status
  (
   p_salesrep_id            IN  NUMBER,
   p_org_id                 IN  NUMBER,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2 IS

      CURSOR get_hold_status IS
         SELECT hold_payment, salesrep_id
           FROM cn_salesreps
           WHERE salesrep_id = p_salesrep_id
	     AND org_id = p_org_id;

      l_status cn_payruns.status%TYPE;
      l_salesrep_id cn_salesreps.salesrep_id%TYPE;

BEGIN

   x_loading_status := p_loading_status ;

   OPEN get_hold_status;
   FETCH get_hold_status INTO l_status,l_salesrep_id;
   CLOSE get_hold_status;

   IF l_status = 'Y' THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         fnd_message.set_name('CN', 'CN_SRP_ON_HOLD');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_SRP_ON_HOLD';
      RETURN fnd_api.g_true;
   END IF;

   IF l_salesrep_id IS NULL THEN
      x_loading_status := 'CN_SRP_NOT_EXISTS';
     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_SRP_NOT_EXISTS');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_SRP_NOT_EXISTS';
      RETURN fnd_api.g_true;
   END IF;

   RETURN fnd_api.g_false;
END chk_srp_hold_status;
--| ---------------------------------------------------------------------+
--   Function   : Get_pay_Element_ID(P_quota_id, p_salesrep_id, p_date)
--| ---------------------------------------------------------------------+
FUNCTION Get_pay_Element_ID
  (
   p_quota_id            IN  NUMBER,
   p_Salesrep_id         IN  cn_rs_salesreps.salesrep_id%TYPE,
   p_org_id              IN  NUMBER,
   p_date                IN  DATE
   ) RETURN NUMBER IS

-- Bug 2875120 3/27/03
 CURSOR  /*+ ordered */ get_pay_element IS
      SELECT pay_element_type_id
  FROM cn_quota_pay_elements p,
	cn_rs_salesreps s
	WHERE p.quota_id    = p_quota_id
	AND p_date between p.start_date and p.end_date
	AND s.salesrep_id = p_salesrep_id
	AND s.org_id      = p_org_id
	AND nvl(s.status,'A') =  p.status;

  l_pay_element_type_id NUMBER;
  l_payroll_flag  Varchar2(01);


 BEGIN
    select nvl(payroll_flag,'N')
     into  l_payroll_flag
      from cn_repositories
     WHERE org_id = p_org_id;

    if l_payroll_flag = 'Y' THEN
      open  get_pay_element;
      fetch get_pay_element into l_pay_element_type_id;
      close get_pay_element;
    end if;

    RETURN l_pay_element_type_id;

 END;
-- ===========================================================================
-- Procedure   : check_duplicate_worksheet
-- Description : Check Duplicate Work sheet for salesrep and role in payrun
-- ===========================================================================
FUNCTION chk_duplicate_worksheet
  ( p_payrun_id       IN  NUMBER,
    p_salesrep_id           IN  NUMBER,
    p_org_id                IN  NUMBER,
    p_loading_status         IN  VARCHAR2,
    x_loading_status         OUT NOCOPY VARCHAR2
    ) RETURN VARCHAR2  IS

 CURSOR get_worksheet IS
    SELECT 1
      FROM cn_payment_worksheets
      WHERE payrun_id = p_payrun_id
      AND salesrep_id = p_salesrep_id
      AND org_id      = p_org_id;

   l_found number;

BEGIN

   x_loading_status := p_loading_status ;
   OPEN get_worksheet;
   FETCH get_worksheet INTO l_found;
   CLOSE get_worksheet;
   IF l_found = 1
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_DUPLICATE_WORKSHEET');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_DUPLICATE_WORKSHEET';
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   RETURN fnd_api.g_false;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;
END chk_duplicate_worksheet;

-- ===========================================================================
-- Procedure   : check_worksheet_status
-- Description : Check Worksheet Status
-- ===========================================================================
FUNCTION chk_worksheet_status
  ( p_payrun_id       IN  NUMBER,
    p_salesrep_id           IN  NUMBER,
    p_org_id                IN  NUMBER,
    p_loading_status         IN  VARCHAR2,
    x_loading_status         OUT NOCOPY VARCHAR2
    ) RETURN VARCHAR2  IS

 CURSOR get_worksheet IS
    SELECT worksheet_status
      FROM cn_payment_worksheets
      WHERE payrun_id = p_payrun_id
      AND salesrep_id = p_salesrep_id
      AND org_id      = p_org_id
      AND quota_id   iS NULL;


   l_status Varchar2(30);

BEGIN

   x_loading_status := p_loading_status ;
   OPEN get_worksheet;
   FETCH get_worksheet INTO l_status;
   CLOSE get_worksheet;
   IF l_status NOT IN ( 'UNPAID','PROCESSING' )
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_WKSHT_CANNOT_BE_MODIFIED');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_WKSHT_CANNOT_BE_MODIFIED';
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   RETURN fnd_api.g_false;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;
END chk_worksheet_status;

--| ---------------------------------------------------------------------+
--   Function   : Get_pay_Element_Name(P_element_type_id)
--| ---------------------------------------------------------------------+
FUNCTION Get_pay_Element_Name
  (
   p_element_type_id     IN  NUMBER
   ) RETURN VARCHAR2 IS

  Cursor get_element_name IS
   SELECT element_name
          FROM pay_element_types_f
   WHERE element_type_id = p_element_type_id;

   l_element_name pay_element_types_f.element_name%TYPE;

  BEGIN

    OPEN get_element_name;
    FETCH get_element_name into l_element_name;
    CLOSE get_element_name;

   RETURN l_element_name;

EXCEPTION
   WHEN OTHERS THEN
   RETURN l_element_name;
END get_pay_element_name;

--| -----------------------------------------------------------------------+
--| Function Name :  can_user_view_page()
--| Desc : procedure to test if a HTML page is accessible to a user
--| Return true if yes, else return false
--| -----------------------------------------------------------------------+
procedure can_user_view_page(p_page_name IN varchar2,
			     x_return_status OUT NOCOPY varchar2) IS
   l_result boolean := false;
   funcName fnd_form_functions.function_name%TYPE ;  --varchar2(100);

   CURSOR l_function_csr  (p_name VARCHAR2)IS
     SELECT function_name
       FROM fnd_form_functions
       WHERE UPPER(web_html_call) like p_name;
BEGIN
   x_return_status := 'N';

   IF p_page_name IS NULL THEN
    x_return_status := 'N';
   ELSE
    OPEN l_function_csr ((UPPER(p_page_name) || '%'));
    LOOP
      FETCH l_function_csr INTO funcName;
      EXIT WHEN l_function_csr%NOTFOUND;

      l_result := FND_FUNCTION.TEST (funcName, 'Y');
    IF (l_result = true) THEN
     x_return_status := 'Y';
     EXIT;
    ELSE
     x_return_status := 'N';
    END IF;
  END LOOP;
    CLOSE l_function_csr;

   END IF;
END can_user_view_page;

--| ---------------------------------------------------------------------+
--|   Function   : Is_Payee(p_salesrep_id)
--| Desc : Check if passed in salesrep is a Payee
--| Return 1 if the passed in salesrep_id is a Payee; otherwise return 0
--| ---------------------------------------------------------------------+

FUNCTION Is_Payee( p_salesrep_id    IN     NUMBER,
		   p_period_id      IN     NUMBER,
		   p_org_id         IN     NUMBER) RETURN NUMBER IS
   l_exist NUMBER := 0;
BEGIN
   l_exist := 0;
   BEGIN
      -- isPayee if assigned to srp in this period
      SELECT 1 INTO l_exist  FROM dual WHERE EXISTS
	(SELECT 1
	 FROM cn_srp_payee_assigns cnspay, cn_period_statuses cnps
	 WHERE cnspay.payee_id = p_salesrep_id
	 AND cnps.period_id = p_period_id
	 AND cnps.org_id    = p_org_id
	 AND cnspay.org_id  = p_org_id
	 AND ((cnspay.start_date <= cnps.end_date)
	      AND (cnps.start_date <= Nvl(cnspay.end_date,cnps.start_date)))
	 );

      RETURN l_exist;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
   l_exist := 0;
         BEGIN
      -- isPayee if have Payee role in this period
      SELECT 1 INTO l_exist  FROM dual WHERE EXISTS
        (SELECT 1 FROM cn_srp_roles sr, cn_period_statuses cnps
         WHERE sr.salesrep_id = p_salesrep_id
         AND sr.role_id = 54
	 AND sr.org_id = p_org_id
	 AND cnps.org_id = p_org_id
         AND cnps.period_id = p_period_id
         AND ((sr.start_date <= cnps.end_date)
        AND (cnps.start_date <= Nvl(sr.end_date,cnps.start_date)))
         );

      RETURN l_exist;
   EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	       RETURN 0;
	 END;
   END;

END Is_Payee;

--| ---------------------------------------------------------------------+
--|   Function   : Test_Function(p_function_name)
--| Desc : Check if passed in function is allowed
--| Return 1 if it is allowed; otherwise return 0
--| ---------------------------------------------------------------------+

FUNCTION Test_Function( p_function_name    IN     VARCHAR2) RETURN NUMBER IS
BEGIN
   if fnd_function.test(p_function_name) THEN
      return 1;
    else return 0;
   end if;
END test_function;



FUNCTION  get_role_name_2 (period_id NUMBER,
                          -- payrun_id NUMBER,
                           salesrep_id NUMBER)
RETURN cn_roles.name%TYPE IS
     l_role_name cn_roles.name%TYPE;
     l_role_str VARCHAR2(1000):= '';
     l_start_date DATE;
     CURSOR get_role_cursor(l_period_id NUMBER,
                            l_salesrep_id IN NUMBER)
   IS
    SELECT distinct r.name role_name,assign.start_date
    FROM   cn_srp_periods srp,
       cn_srp_plan_assigns assign,
       cn_roles r
    WHERE assign.srp_plan_assign_id(+)= srp.srp_plan_assign_id
      AND srp.period_id	  = l_period_id
      AND assign.role_id  = r.role_id(+)
      AND srp.salesrep_id = l_salesrep_id
     -- AND srp.credit_type_id = -1000
      AND srp.quota_id <> -1000
    ORDER BY assign.start_date;
    --variable added for bug 6685748
    l_html_text varchar2(2000);
BEGIN
 --Code added for bug 6685748
-- l_html_text :='<HTML>';

 OPEN get_role_cursor(period_id,salesrep_id) ;
 LOOP
      FETCH get_role_cursor into l_role_name,l_start_date;
      EXIT WHEN get_role_cursor%NOTFOUND;
      l_role_str := l_role_str || l_role_name;
	  --Code line added for bug 6685748
	  l_role_str := l_role_str ||'<br>';

 END LOOP;
 --Code line added for bug 6685748
l_html_text :='<HTML>'||l_role_str||'<\HTML>';
RETURN l_html_text;

EXCEPTION
   WHEN others THEN
      RETURN 'Error';
END get_role_name_2;


FUNCTION  get_role_name_3 (p_period_id NUMBER DEFAULT NULL,
                           p_salesrep_id NUMBER DEFAULT NULL,
                           p_payrun_id NUMBER DEFAULT NULL,
                           p_ORG_ID   NUMBER DEFAULT NULL,
                           populate NUMBER DEFAULT NULL)
	RETURN  VARCHAR2 IS



	  CURSOR C_GET_SALESREP_ID
	  IS
		SELECT salesrep_id
		FROM cn_payment_worksheets cnw
		WHERE cnw.payrun_id 	  = p_payrun_id
		  AND cnw.org_id          = p_ORG_ID
		  AND cnw.quota_id       IS NULL ;

	  l_cnw_salesrep_id JTF_NUMBER_TABLE;

	  CURSOR C_SRP_ASSIGN_ID
	  IS
	    SELECT DISTINCT srp.salesrep_id
	      ||'-'
	      ||srp_plan_assign_id
	      ||'-'
	      ||srp.period_id
	    FROM cn_srp_periods srp,
	      (SELECT column_value SALESREP_ID FROM TABLE(CAST(l_cnw_salesrep_id AS JTF_NUMBER_TABLE))
	      ) cnw
	    WHERE srp.period_id       = p_period_id
	      AND srp.quota_id       <> -1000
	      AND srp.org_id          = p_ORG_ID
	      AND srp.salesrep_id     = cnw.SALESREP_ID;

	  l_cnw_srp_salrep_id JTF_VARCHAR2_TABLE_2000;

	  CURSOR get_role_cursor
	  IS
	    SELECT DISTINCT  cnw_srp.SALESREP_ID,
						 cnw_srp.PERIOD_ID,
						 RL.ROLE_NAME,
						 ASSIGN.START_DATE
	    FROM CN_SRP_PLAN_ASSIGNS assign ,
			 JTF_RS_ROLES_VL rl ,
	        (SELECT  TO_NUMBER(SUBSTR(column_value , 1 , INSTR(column_value, '-', 1, 1) - 1 ) ) SALESREP_ID,
	                 TO_NUMBER(SUBSTR(column_value ,
					       INSTR(column_value, '-', 1, 1) + 1,
						   (INSTR(column_value, '-', 1, 2) - INSTR(column_value, '-', 1, 1))-1)
						   ) PLANASSIGNID,
				     TO_NUMBER(SUBSTR(column_value , INSTR(column_value, '-', 1, 2) + 1 ,LENGTH(column_value) )
				            ) PERIOD_ID
	         FROM TABLE(CAST(l_cnw_srp_salrep_id AS JTF_VARCHAR2_TABLE_2000))
			 ) cnw_srp
	    WHERE assign.ORG_ID                = p_ORG_ID
	      AND assign.srp_plan_assign_id(+) = cnw_srp.PLANASSIGNID
	      AND assign.salesrep_id(+)        = cnw_srp.SALESREP_ID
	      AND rl.role_id(+)                = assign.ROLE_ID
	      AND rl.role_type_code            = 'SALES_COMP'
	      ORDER BY assign.start_date;


		l_salesrep_id_tbl 	JTF_NUMBER_TABLE;
	    l_period_tbl 		JTF_NUMBER_TABLE;
	    l_role_name_tbl 	JTF_VARCHAR2_TABLE_2000;
	    l_start_date_tbl 	JTF_DATE_TABLE;
	    l_sales_id_tbl 		JTF_NUMBER_TABLE;

	    l_role_name_cache 	VARCHAR2(2000);
	    l_html_text       	VARCHAR2(2000);
	    l_role_str 		  	VARCHAR2(2000):= '';
		l_sales_temp_num 	NUMBER;
	    l_sales_perio_id 	NUMBER;
		l_salrep_tmp  		NUMBER;
	    l_rec_count 		PLS_INTEGER;
	    l_start_date 		DATE;
		l_found 			BOOLEAN;
		l_salesrep_cache_info salesrep_cache_rec_type;

	BEGIN

	    IF populate IS NULL THEN
	      IF g_salesrep_info_cache.EXISTS(p_salesrep_id) THEN
	        l_salesrep_cache_info := g_salesrep_info_cache(p_salesrep_id);
	        l_found               := l_salesrep_cache_info.period_id = p_period_id;
			IF l_found
			THEN
				l_role_name_cache     := l_salesrep_cache_info.ROLE_NAME;
			END IF;
	      END IF;
	    END IF;


	    IF populate            =1
		THEN
	      l_salesrep_id_tbl   :=JTF_NUMBER_TABLE();
	      l_period_tbl        :=JTF_NUMBER_TABLE();
	      l_role_name_tbl     :=JTF_VARCHAR2_TABLE_2000();
	      l_start_date_tbl    :=JTF_DATE_TABLE();
	      l_sales_id_tbl      :=JTF_NUMBER_TABLE();
	      l_cnw_salesrep_id   := JTF_NUMBER_TABLE();
	      l_cnw_srp_salrep_id :=JTF_VARCHAR2_TABLE_2000();

  		  OPEN C_GET_SALESREP_ID;
	      FETCH C_GET_SALESREP_ID BULK COLLECT INTO l_cnw_salesrep_id;
	      CLOSE C_GET_SALESREP_ID;


	      OPEN C_SRP_ASSIGN_ID;
	      FETCH C_SRP_ASSIGN_ID BULK COLLECT INTO l_cnw_srp_salrep_id;
	      CLOSE C_SRP_ASSIGN_ID;

	      OPEN get_role_cursor;
	      FETCH get_role_cursor BULK COLLECT
	      INTO l_salesrep_id_tbl,
			   l_period_tbl     ,
	           l_role_name_tbl  ,
	           l_start_date_tbl;
	      CLOSE get_role_cursor;

	      g_salesrep_info_cache.DELETE;
	      l_sales_temp_num := -1;
	      l_sales_perio_id := -1;
	      l_rec_count      := l_salesrep_id_tbl.COUNT;

	      if l_rec_count > 0
        then

	      FOR i IN l_salesrep_id_tbl.FIRST..l_salesrep_id_tbl.LAST
	      LOOP
	        IF l_sales_temp_num  <>l_salesrep_id_tbl(i) THEN
	          IF l_sales_temp_num = -1 OR l_sales_perio_id = -1 THEN
	            l_sales_temp_num :=l_salesrep_id_tbl(i);
	            l_sales_perio_id :=l_period_tbl(i);
	          ELSE
	            l_salesrep_cache_info.salesrep_id             :=l_salesrep_id_tbl(i-1);
	            l_salesrep_cache_info.period_id               :=l_period_tbl(i-1);
	            l_salesrep_cache_info.role_name               :=substr(l_role_str,1,length(l_role_str)-1);
	            g_salesrep_info_cache(l_salesrep_id_tbl(i-1)) :=l_salesrep_cache_info;
	            l_role_str                                    :=NULL;
				l_sales_temp_num :=l_salesrep_id_tbl(i);
	            l_sales_perio_id :=l_period_tbl(i);
	          END IF;
	        END IF;
	        l_role_str                                    := l_role_str || l_role_name_tbl(i)||',';
	        IF (i= l_rec_count) THEN
	          l_salesrep_cache_info.salesrep_id           :=l_salesrep_id_tbl(i);
	          l_salesrep_cache_info.period_id             :=l_period_tbl(i);
	          l_salesrep_cache_info.role_name             :=substr(l_role_str,1,length(l_role_str)-1);
	          g_salesrep_info_cache(l_salesrep_id_tbl(i)) :=l_salesrep_cache_info;
	          l_role_str                                  :=NULL;
	        END IF;
	      END LOOP;
	     END IF;
	      l_role_name_cache := l_role_str;
	    END IF; --if populate =1
  RETURN l_role_name_cache;
END get_role_name_3;



FUNCTION get_user(p_user_id NUMBER DEFAULT NULL,p_payrun_id NUMBER DEFAULT NULL)
    RETURN jtf_number_table IS

    CURSOR C_USER(l_user_id number,l_payrun_id number)
    is
     SELECT DISTINCT re2.user_id
      FROM jtf_rs_group_usages u2,
           jtf_rs_rep_managers m2,
           jtf_rs_resource_extns_vl re2,
           (SELECT DISTINCT m1.resource_id,
                            greatest(pr.start_date, m1.start_date_active) start_date,
                            least(pr.end_date, nvl(m1.end_date_active, pr.end_date)) end_date
              FROM jtf_rs_resource_extns re1,
                   cn_period_statuses    pr,
                   jtf_rs_group_usages   u1,
                   jtf_rs_rep_managers   m1
             WHERE re1.user_id = l_user_id --129941
               AND (pr.period_id, pr.org_id) =
                   (SELECT p.pay_period_id,
                           p.org_id
                      FROM cn_payruns p
                     WHERE p.payrun_id = l_payrun_id ) -- 852986
               AND u1.usage = 'COMP_PAYMENT'
               AND ((m1.start_date_active <= pr.end_date) AND
                   (pr.start_date <= nvl(m1.end_date_active, pr.start_date)))
               AND u1.group_id = m1.group_id
               AND m1.resource_id = re1.resource_id
               AND m1.parent_resource_id = m1.resource_id
               AND m1.hierarchy_type IN ('MGR_TO_MGR', 'REP_TO_REP')
               AND m1.category <> 'TBH') v3
     WHERE u2.usage = 'COMP_PAYMENT'
       AND u2.group_id = m2.group_id
       AND m2.parent_resource_id = v3.resource_id
       AND ((m2.start_date_active <= v3.end_date) AND
           (v3.start_date <= nvl(m2.end_date_active, v3.start_date)))
       AND m2.category <> 'TBH'
       AND m2.hierarchy_type IN ('MGR_TO_MGR', 'MGR_TO_REP', 'REP_TO_REP')
       AND m2.resource_id = re2.resource_id;


       l_user_tab jtf_number_table;
       l_user_id number;
       l_payrun_id number;
       l_found boolean;

Begin

--G_USER_TAB := jtf_number_table();

l_found := FALSE;

IF g_user_tab.COUNT > 0 THEN
      --dbms_output.put_line('Returning from cache');
	     RETURN G_USER_TAB;
	END IF;

IF NOT l_found
	THEN
 l_user_tab := jtf_number_table();

OPEN c_user(p_user_id,p_payrun_id);
      FETCH c_user BULK COLLECT INTO l_user_tab;
      CLOSE c_user;
      G_USER_TAB:=L_USER_TAB;

      return l_user_tab;
END IF;

End;

PROCEDURE get_user_info(p_user_id NUMBER DEFAULT NULL,p_payrun_id NUMBER DEFAULT NULL)
   is
    CURSOR C_USER(l_user_id number,l_payrun_id number)
    is
     SELECT DISTINCT re2.user_id
      FROM jtf_rs_group_usages u2,
           jtf_rs_rep_managers m2,
           jtf_rs_resource_extns_vl re2,
           (SELECT DISTINCT m1.resource_id,
                            greatest(pr.start_date, m1.start_date_active) start_date,
                            least(pr.end_date, nvl(m1.end_date_active, pr.end_date)) end_date
              FROM jtf_rs_resource_extns re1,
                   cn_period_statuses    pr,
                   jtf_rs_group_usages   u1,
                   jtf_rs_rep_managers   m1
             WHERE re1.user_id = l_user_id --129941
               AND (pr.period_id, pr.org_id) =
                   (SELECT p.pay_period_id,
                           p.org_id
                      FROM cn_payruns p
                     WHERE p.payrun_id = l_payrun_id ) -- 852986
               AND u1.usage = 'COMP_PAYMENT'
               AND ((m1.start_date_active <= pr.end_date) AND
                   (pr.start_date <= nvl(m1.end_date_active, pr.start_date)))
               AND u1.group_id = m1.group_id
               AND m1.resource_id = re1.resource_id
               AND m1.parent_resource_id = m1.resource_id
               AND m1.hierarchy_type IN ('MGR_TO_MGR', 'REP_TO_REP')
               AND m1.category <> 'TBH') v3
     WHERE u2.usage = 'COMP_PAYMENT'
       AND u2.group_id = m2.group_id
       AND m2.parent_resource_id = v3.resource_id
       AND ((m2.start_date_active <= v3.end_date) AND
           (v3.start_date <= nvl(m2.end_date_active, v3.start_date)))
       AND m2.category <> 'TBH'
       AND m2.hierarchy_type IN ('MGR_TO_MGR', 'MGR_TO_REP', 'REP_TO_REP')
       AND m2.resource_id = re2.resource_id;

       l_user_tab jtf_number_table;

begin

 l_user_tab := jtf_number_table();
 G_USER_TAB := jtf_number_table();

      OPEN c_user(p_user_id,p_payrun_id);
      FETCH c_user BULK COLLECT INTO l_user_tab;
      CLOSE c_user;
  G_USER_TAB:=L_USER_TAB;
 -- dbms_output.put_line('Putting Inside  cache');

end;


END CN_API;

/
