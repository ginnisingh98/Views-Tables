--------------------------------------------------------
--  DDL for Package Body OE_SYS_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SYS_PARAMETERS_PVT" AS
/* $Header: OEXVSPMB.pls 120.5 2005/10/23 21:15:36 jisingh noship $ */


--Global variables to cache the Generic parameter information.

   /* MOAC_SQL_CHANGE */
   type VAL_TAB_TYPE    is table of varchar2(240) index by VARCHAR2(90);
   /*
   ** define the internal table that will cache the parameter values
   ** val_tab(x) is associated with name_tab(x)
   */
   VAL_TAB       VAL_TAB_TYPE;    /* the table of values */

   g_org_id	       NUMBER:= 0;


   g_freight_rating_flag       VARCHAR2(1);
   g_ship_method_flag          VARCHAR2(1);

   -- Global variables to cache the Scheduling parameter information
   g_lad_flag                  VARCHAR2(1);
   g_request_date_flag         VARCHAR2(1);
   g_shipping_method_flag          VARCHAR2(1);
   g_promise_date_flag         VARCHAR2(2);
   g_partial_reservation_flag  VARCHAR2(1);

   --retro{
   -- Global variables to cache the Retrobilling parameter information
   g_enable_retrobilling       VARCHAR2(1);
   --retro}

   -- Global variables to cache the Approval parameter information
   g_no_response_from_approver VARCHAR2(30);
   --recurring charges
   g_recurring_charges         VARCHAR2(1);

   -- Forward declaration --

   /* R12.MOAC */
   FUNCTION find (p_parameter_code IN VARCHAR2,
                  p_org_id IN NUMBER) RETURN VARCHAR2;

-- Start of comments
-- API name         : Get_Value_From_Db
-- Type             : Private
-- Description      : This function will get the parameter value of a system parameter
--                    from oe_sys_parameters_all
-- Parameters       :
-- IN               : p_parameter_Code    IN  VARCHAR2    Required
--
--                    P_org_id            IN NUMBER
--
-- End of Comments
FUNCTION Get_Value_From_Db
	(p_parameter_Code  IN VARCHAR2,
	 p_org_id IN NUMBER DEFAULT NULL)
RETURN VARCHAR2
IS
   /* MOAC_SQL_CHANGE */
   CURSOR parameter_value IS
      SELECT parameter_value
      FROM  oe_sys_parameters_all
      WHERE parameter_code = p_parameter_code
      AND   org_id = p_org_id;
     /*
      AND  NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB
          (USERENV ('CLIENT_INFO'),1 ,1),' ', NULL,
          SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(p_org_id, NVL(TO_NUMBER(DECODE(SUBSTRB
          (USERENV('CLIENT_INFO'),1,1),' ', NULL,
          SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99));
    */
   l_parameter_val   VARCHAR2(240);


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   OPEN parameter_value;
   FETCH parameter_value INTO l_parameter_val;
   IF parameter_value%NOTFOUND THEN
      CLOSE parameter_value;
      RETURN NULL;
   END IF;
   CLOSE Parameter_value;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'VALUE FROM DB'||l_parameter_val , 1 ) ;
   END IF;
   RETURN l_parameter_val;

END Get_Value_From_Db;


-- Start of comments
-- API name         : Value
-- Type             : Private
-- Description      : This function will return parameter value of a given system parameter
--                    Will check from global variables, if not available will call api Get_Value_From_Db
-- Parameters       :
-- IN               : p_param_Code    IN  VARCHAR2    Required
--
--                    P_org_id            IN NUMBER
--
-- End of Comments

FUNCTION VALUE
	(p_param_code 	IN VARCHAR2,
	 p_org_id IN NUMBER DEFAULT NULL)
RETURN VARCHAR2
IS
  l_org_id                 NUMBER:= 0;
  l_sob_id                 NUMBER := 0;
  l_parameter_value        VARCHAR2(240);
  l_tot_count              NUMBER;
  l_chk_clt_info           NUMBER;
  l_param_code             varchar2(60);
 -- R12.MOAC
  l_freight_rating_flag       VARCHAR2(1) := NULL;
  l_ship_method_flag          VARCHAR2(1) := NULL;

/* -- MOAC_SQL_CHANGE
  CURSOR organization_id IS
     SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
                NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
     FROM DUAL;
*/
  l_AR_Sys_Param_Rec       AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;
  l_table_index  BINARY_INTEGER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SYS_PARAMETERS_PVT.VALUE '||p_org_id , 1 ) ;
   END IF;

   IF p_org_id IS NULL THEN

      /*
      OPEN organization_id;
      FETCH organization_id INTO l_org_id;
      CLOSE organization_id;
      */


      /*As per the bug #3381576.
        To derive the ORG_ID based on the PL/sQL block rather then SQL.
      */

      /* Start MOAC_SQL_CHANGE */
      --l_chk_clt_info := to_number(rtrim(SUBSTRB(USERENV('CLIENT_INFO'),1,10),' '));
      l_org_id :=  mo_global.get_current_org_id;
      IF  l_org_id IS NULL THEN
         Fnd_Message.set_name('ONT','ONT_OU_REQUIRED_FOR_SYS_PARAM');
         Oe_Msg_Pub.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      /*
      if l_chk_clt_info is not null
      then
         l_org_id := l_chk_clt_info;
      else
         l_org_id := -99;
      end if;
      */
      /* End MOAC_SQL_CHANGE */
   ELSE
      l_org_id := p_org_id;
   END IF;
  l_param_code := p_param_code;


  IF l_param_code = 'SET_OF_BOOKS_ID' THEN

     l_AR_Sys_Param_Rec := Get_AR_Sys_Params(l_org_id);

       RETURN(TO_CHAR(l_AR_Sys_Param_Rec.SET_OF_BOOKS_ID));

     --freight rating and carrier selection
  ELSIF l_param_code = 'FTE_INTEGRATION' THEN

     /* MOAC_SQL_CHANGE */
     l_freight_rating_flag := nvl(find('FREIGHT_RATING_ENABLED_FLAG',l_org_id), 'N');
     l_ship_method_flag := nvl(find('FTE_SHIP_METHOD_ENABLED_FLAG',l_org_id), 'N');

     IF l_freight_rating_flag is not null
        AND l_ship_method_flag is not null THEN
        IF l_freight_rating_flag = 'Y'
          AND l_ship_method_flag = 'Y' THEN
           RETURN 'Y';
        ELSIF l_freight_rating_flag = 'Y' THEN
           RETURN 'F';
        ELSIF l_ship_method_flag = 'Y' THEN
           RETURN 'S';
        ELSE
           RETURN 'N';
        END IF;
     END IF;
     /*
     ELSE
        l_parameter_value := get_value_from_db('FREIGHT_RATING_ENABLED_FLAG',l_org_id);
        IF g_org_id <> l_org_id THEN
           g_org_id := l_org_id;
        END IF;
        g_freight_rating_flag := l_parameter_value;
        l_parameter_value := NULL;
        l_parameter_value := get_value_from_db('FTE_SHIP_METHOD_ENABLED_FLAG',l_org_id);
        g_ship_method_flag := l_parameter_value;

        IF g_freight_rating_flag = 'Y' AND
           g_ship_method_flag = 'Y' THEN
           RETURN 'Y';
        ELSIF g_freight_rating_flag = 'Y' THEN
           RETURN 'F';
        ELSIF g_ship_method_flag = 'Y' THEN
           RETURN 'S';
        ELSE
           RETURN 'N';
        END IF;

     END IF;
     */
  ---------- Scheduling parameters---------------------------------
  ELSIF l_param_code = 'LATEST_ACCEPTABLE_DATE_FLAG' THEN
     -- R12.MOAC
     l_parameter_value := NVL(find(l_param_code,l_org_id),'O');
     RETURN(l_parameter_value);
     /*
     IF l_org_id = g_org_id AND g_lad_flag is not null THEN
        RETURN(g_lad_flag);
     ELSE
        l_parameter_value := NVL(get_value_from_db('LATEST_ACCEPTABLE_DATE_FLAG',l_org_id),'O');
        g_org_id := l_org_id;
        g_lad_flag := l_parameter_value;
        RETURN(g_lad_flag);
     END IF;
     */
  ELSIF l_param_code = 'RESCHEDULE_REQUEST_DATE_FLAG' THEN
     -- R12.MOAC
     l_parameter_value := NVL(find(l_param_code,l_org_id),'Y');
     RETURN(l_parameter_value);
     /*
     IF l_org_id = g_org_id AND g_request_date_flag is not null THEN
        RETURN(g_request_date_flag);
     ELSE
        l_parameter_value := NVL(get_value_from_db('RESCHEDULE_REQUEST_DATE_FLAG',l_org_id),'Y');
        g_org_id := l_org_id;
        g_request_date_flag := l_parameter_value;
        RETURN(g_request_date_flag);
     END IF;
     */
  ELSIF l_param_code = 'RESCHEDULE_SHIP_METHOD_FLAG' THEN
     -- R12.MOAC
     l_parameter_value := NVL(find(l_param_code,l_org_id),'Y');
     RETURN(l_parameter_value);
     /*
     IF l_org_id = g_org_id AND g_shipping_method_flag is not null THEN
        RETURN(g_shipping_method_flag);
     ELSE
        l_parameter_value := NVL(get_value_from_db('RESCHEDULE_SHIP_METHOD_FLAG',l_org_id),'Y');
        g_org_id := l_org_id;
        g_shipping_method_flag := l_parameter_value;
        RETURN(g_shipping_method_flag);
     END IF;
     */
  ELSIF l_param_code = 'PROMISE_DATE_FLAG' THEN
     -- R12.MOAC
     l_parameter_value := NVL(find(l_param_code,l_org_id),'M');
     RETURN(l_parameter_value);
     /*
     IF l_org_id = g_org_id AND g_promise_date_flag is not null THEN
        RETURN(g_promise_date_flag);
     ELSE
        l_parameter_value := NVL(get_value_from_db('PROMISE_DATE_FLAG',l_org_id),'M');
        g_org_id := l_org_id;
        g_promise_date_flag := l_parameter_value;
        RETURN(g_promise_date_flag);
     END IF;
     */
  ELSIF l_param_code = 'PARTIAL_RESERVATION_FLAG' THEN
     -- R12.MOAC
     l_parameter_value := NVL(find(l_param_code,l_org_id),'N');
     RETURN(l_parameter_value);
     /*
     IF l_org_id = g_org_id AND g_partial_reservation_flag is not null THEN
        RETURN(g_partial_reservation_flag);
     ELSE
        l_parameter_value := NVL(get_value_from_db('PARTIAL_RESERVATION_FLAG',l_org_id),'N');
        g_org_id := l_org_id;
        g_partial_reservation_flag := l_parameter_value;
        RETURN(g_partial_reservation_flag);
     END IF;
     */
  --recurring charges parameters --------------------------------------
  ELSIF l_param_code = 'RECURRING_CHARGES' THEN
    oe_debug_pub.add('Inside RCAPPS');
     -- R12.MOAC
     l_parameter_value := NVL(find(l_param_code,l_org_id),'N');
     RETURN(l_parameter_value);
     /*
    IF l_org_id = g_org_id AND g_recurring_charges IS NOT NULL THEN
       oe_debug_pub.add('Recur Enabled1:'||g_recurring_charges);
       RETURN (g_recurring_charges);
    ELSE
       l_parameter_value:=NVL(Get_Value_From_DB('RECURRING_CHARGES',l_org_id),'N');
       g_org_id := l_org_id;
       g_recurring_charges := l_parameter_value;
       oe_debug_pub.add('Recur Enabled2:'||g_recurring_charges);
       RETURN (g_recurring_charges);
    END IF;
    */
  -- recurring charges paramaters END ---------------------------------

 --retro{Retrobilling parameters
 ELSIF l_param_code = 'ENABLE_RETROBILLING' THEN
     -- R12.MOAC
     l_parameter_value := NVL(find(l_param_code,l_org_id),'N');
     RETURN(l_parameter_value);
     /*
     IF l_org_id = g_org_id AND g_enable_retrobilling is not null THEN
        RETURN(g_enable_retrobilling);
     ELSE
        l_parameter_value := NVL(get_value_from_db('ENABLE_RETROBILLING',l_org_id),'N');
        g_org_id := l_org_id;
        g_enable_retrobilling := l_parameter_value;
        RETURN(g_enable_retrobilling);
     END IF;
     */
 ELSIF l_param_code = 'NO_RESPONSE_FROM_APPROVER' THEN
     -- R12.MOAC
     l_parameter_value := NVL(find(l_param_code,l_org_id),'N');
     RETURN(l_parameter_value);
     /*
     IF l_org_id = g_org_id AND g_no_response_from_approver is not null THEN
        RETURN(g_no_response_from_approver);
     ELSE
        l_parameter_value := NVL(get_value_from_db('NO_RESPONSE_FROM_APPROVER',l_org_id),'N');
        g_org_id := l_org_id;
        g_no_response_from_approver := l_parameter_value;
        RETURN(g_no_response_from_approver);
     END IF;
     */
  ELSE -- For all parameters having no extra processing
     l_parameter_value := find(l_param_code,l_org_id);

     /*
     IF l_org_id = g_org_id THEN
        l_table_index := find(l_param_code);
        IF l_table_index < TABLE_SIZE THEN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  ' 1 Parameter Value: '||Val_Tab(l_table_index),1);
           END IF;
           RETURN (Val_Tab(l_table_index));
        ELSE
           put(l_param_code,l_org_id,l_parameter_value);
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  '2 PARAMETER VALUE: '||l_parameter_value,1);
           END IF;
           RETURN (l_parameter_value);
        END IF;
     ELSE -- org id changed
        put(l_param_code,l_org_id,l_parameter_value);
        g_org_id := l_org_id;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  '3 PARAMETER VALUE: '||l_parameter_value,1);
        END IF;
        RETURN (l_parameter_value);
     END IF;
     */
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' PARAMETER VALUE: '||l_parameter_value,1);
     END IF;
     RETURN (l_parameter_value);
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'EXITING OE_SYS_PARAMETERS_PVT.VALUE' , 1 ) ;
  END IF;
  RETURN(NULL);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXPECTED ERROR IN VALUE FUNCTION' ,1);
      END IF;
      RAISE FND_API.G_EXC_ERROR;

   WHEN NO_DATA_FOUND THEN

      RETURN(NULL);

   WHEN OTHERS THEN

      RETURN(NULL);

END VALUE;

-- Start of comments
-- API name         : Find
-- Type             : Private
-- Description      : This function will get the index  of a system parameter
--                    from cache
-- Parameters       :
-- IN               : p_parameter_Code    IN  VARCHAR2    Required
-- IN               : p_org_id            IN  NUMBER    Required
--
--
-- End of Comments
FUNCTION find (p_parameter_code IN VARCHAR2,
               p_org_id         IN NUMBER)
RETURN VARCHAR2
IS
   l_tab_index  BINARY_INTEGER;
   l_found      BOOLEAN;
   l_hash_value NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   /*R12.MOAC*/
   IF val_tab.EXISTS(p_parameter_code||'ORG'||to_char(p_org_id)) THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Parameter value exists.  ' , 1 ) ;
      END IF;
      RETURN val_tab(p_parameter_code||'ORG'||to_char(p_org_id));
   ELSE
     val_tab(p_parameter_code||'ORG'||to_char(p_org_id)) :=
            get_value_from_db(p_parameter_code,p_org_id);
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Parameter value fetched from table.  ' , 1 ) ;
     END IF;
     RETURN val_tab(p_parameter_code||'ORG'||to_char(p_org_id));
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END find;


 /* A global table of records for ar_system_parameters is maintained to get
    all the information need from ar_system_parameters. Any procedure needing
    information from ar_system_parameters should call this API to get this
   information
 */

FUNCTION Get_AR_Sys_Params
   (p_org_id IN NUMBER DEFAULT NULL)
RETURN AR_SYSTEM_PARAMETERS_ALL%ROWTYPE
IS
l_AR_Sys_Param_Rec       AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;
l_org_id                 NUMBER;
l_chk_clt_info           NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SYS_PARAMETERS_PVT.GET_AR_SYS_PARAMS ... ' , 1 ) ;
  END IF;

  IF p_org_id IS NULL THEN

     IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Org Id is null .. Querying for Org Id ..  ' , 1 ) ;
     END IF;

     /*

     SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
            NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
     INTO l_org_id FROM DUAL;
     */

     /*As per the bug #3381576.
       To derive the ORG_ID based on the PL/sQL block rather then SQL.
     */
     /* Start MOAC_SQL_CHANGE */
     /*
     l_chk_clt_info := to_number(rtrim(SUBSTRB(USERENV('CLIENT_INFO'),1,10),' '));
     if l_chk_clt_info is not null
     then
        l_org_id := l_chk_clt_info;
     else
        l_org_id := -99;
     end if;
     */
     l_org_id :=  mo_global.get_current_org_id;
     IF  l_org_id IS NULL THEN
        Fnd_Message.set_name('ONT','ONT_OU_REQUIRED_FOR_SYS_PARAM');
        Oe_Msg_Pub.Add;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     /* End MOAC_SQL_CHANGE */
  ELSE
     l_org_id := p_org_id;
  END IF;
  IF G_AR_Sys_Param_Tbl.exists(l_org_id) THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Getting the AR details from the cache ..  ' , 1 ) ;
     END IF;
     RETURN G_AR_Sys_Param_Tbl(l_org_id);
  ELSE
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Querying the table for the AR details ..  ' , 1 ) ;
     END IF;
     /* MOAC_SQL_CHANGE */
     SELECT  *
     INTO
     l_AR_Sys_Param_Rec
     FROM AR_SYSTEM_PARAMETERS_ALL
     WHERE org_id = l_org_id;
     /*
     WHERE NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1 ,1),' ',
	        NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
               NVL(l_org_id, NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
			NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99));
     */
     G_AR_Sys_Param_Tbl(l_org_id) := l_AR_Sys_Param_Rec;
     RETURN G_AR_Sys_Param_Tbl(l_org_id);
  END IF;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
       oe_debug_pub.add(  'In No Data Found Exception ..  ' , 1 ) ;
       RETURN(NULL);

    WHEN OTHERS THEN
       oe_debug_pub.add(  'In Others Exception ..  ' , 1 ) ;
       RETURN(NULL);

END Get_AR_Sys_Params;


END OE_Sys_Parameters_Pvt;

/
