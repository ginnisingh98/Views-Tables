--------------------------------------------------------
--  DDL for Package Body OE_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PROFILE" AS
/* $Header: OEXPROFB.pls 120.2 2005/12/20 11:34:10 zbutt noship $ */


G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Profile';

-- LOCAL PROCEDURES
-------------------------------------------------------------------
FUNCTION Get_Active_Profile_Name
	(NAME		IN VARCHAR2
	)
RETURN VARCHAR2
IS
OE_INVALID_INTEROP_PROFILE	EXCEPTION;
BEGIN

	-- for each profile option name (OE or ONT), return the ONT profile
	-- option name if active product is ONT and return the OE profile
	-- option name if active product is OE
/*	IF ( NAME = 'SO_ORGANIZATION_ID'
	     OR NAME = 'OE_ORGANIZATION_ID') THEN

	  IF OE_INSTALL.Get_Active_Product = 'ONT' THEN
		RETURN('OE_ORGANIZATION_ID');
	  ELSE
		RETURN('SO_ORGANIZATION_ID');
	  END IF;

	ELSIF ( NAME = 'SO_SET_OF_BOOKS_ID'
                OR NAME = 'OE_SET_OF_BOOKS_ID') THEN

          IF OE_INSTALL.Get_Active_Product = 'ONT' THEN
                RETURN('OE_SET_OF_BOOKS_ID');
          ELSE
                RETURN('SO_SET_OF_BOOKS_ID');
          END IF;
*/

	IF ( NAME = 'SO_ID_FLEX_CODE'
                OR NAME = 'OE_ID_FLEX_CODE') THEN

          IF OE_INSTALL.Get_Active_Product = 'ONT' THEN
                RETURN('OE_ID_FLEX_CODE');
          ELSE
                RETURN('SO_ID_FLEX_CODE');
          END IF;

	ELSIF ( NAME = 'SO_SOURCE_CODE'
                OR NAME = 'OE_SOURCE_CODE') THEN

          IF OE_INSTALL.Get_Active_Product = 'ONT' THEN
                RETURN('OE_SOURCE_CODE');
          ELSE
                RETURN('SO_SOURCE_CODE');
          END IF;

	ELSIF ( NAME = 'SO_INVENTORY_ITEM_FOR_FREIGHT'
                OR NAME = 'OE_INVENTORY_ITEM_FOR_FREIGHT') THEN

          IF OE_INSTALL.Get_Active_Product = 'ONT' THEN
                RETURN('OE_INVENTORY_ITEM_FOR_FREIGHT');
          ELSE
                RETURN('SO_INVENTORY_ITEM_FOR_FREIGHT');
          END IF;

	ELSE

	  RAISE OE_INVALID_INTEROP_PROFILE;

	END IF;

END Get_Active_Profile_Name;


-- PUBLIC PROCEDURES
-------------------------------------------------------------------
PROCEDURE GET
	(NAME		IN VARCHAR2
	,VAL		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	)
IS
l_active_profile 			VARCHAR2(80);
BEGIN

	IF UPPER(NAME) = 'SO_ORGANIZATION_ID' or UPPER(NAME) = 'OE_ORGANIZATION_ID'     THEN

	    VAL := OE_Sys_Parameters.VALUE(param_name => 'MASTER_ORGANIZATION_ID');

	ELSIF UPPER(NAME) = 'SO_SET_OF_BOOKS_ID' OR UPPER(NAME) = 'OE_SET_OF_BOOKS_ID' THEN

	    VAL := OE_Sys_Parameters.VALUE(param_name => 'SET_OF_BOOKS_ID');

	ELSE

		l_active_profile := Get_Active_Profile_Name(NAME);

		FND_PROFILE.GET(l_active_profile,VAL);
	END IF;
END GET;


-------------------------------------------------------------------
FUNCTION VALUE
	(NAME 		IN VARCHAR2,
	 ORG_ID		IN NUMBER DEFAULT NULL
	)
RETURN VARCHAR2
IS
l_active_profile 			VARCHAR2(80);
l_profile_value				VARCHAR2(255);
BEGIN

	IF UPPER(NAME) = 'SO_ORGANIZATION_ID' or UPPER(NAME) = 'OE_ORGANIZATION_ID'     THEN

	    l_profile_value := OE_Sys_Parameters.VALUE(param_name => 'MASTER_ORGANIZATION_ID', p_org_id => ORG_ID);

	ELSIF UPPER(NAME) = 'SO_SET_OF_BOOKS_ID' OR UPPER(NAME) = 'OE_SET_OF_BOOKS_ID' THEN
	    l_profile_value := OE_Sys_Parameters.VALUE(param_name => 'SET_OF_BOOKS_ID', p_org_id => ORG_ID);

	ELSE

		l_active_profile := Get_Active_Profile_Name(NAME);

		l_profile_value := FND_PROFILE.VALUE(l_active_profile);

	END IF;
	RETURN(l_profile_value);

END VALUE;


-------------------------------------------------------------------
FUNCTION VALUE_WNPS
	(NAME 		IN VARCHAR2,
	 ORG_ID		IN NUMBER DEFAULT NULL
	)
RETURN VARCHAR2
IS
l_active_profile 			VARCHAR2(80);
l_profile_value				VARCHAR2(255);
BEGIN

	IF UPPER(NAME) = 'SO_ORGANIZATION_ID' or UPPER(NAME) = 'OE_ORGANIZATION_ID'     THEN

	    l_profile_value := OE_Sys_Parameters.VALUE_WNPS(param_name => 'MASTER_ORGANIZATION_ID', p_org_id => ORG_ID);

	ELSIF UPPER(NAME) = 'SO_SET_OF_BOOKS_ID' OR UPPER(NAME) = 'OE_SET_OF_BOOKS_ID' THEN
	    l_profile_value := OE_Sys_Parameters.VALUE_WNPS(param_name => 'SET_OF_BOOKS_ID', p_org_id => ORG_ID);

	ELSE
		l_active_profile := Get_Active_Profile_Name(NAME);

		l_profile_value := FND_PROFILE.VALUE_WNPS(l_active_profile);
	END IF;

	RETURN(l_profile_value);

END VALUE_WNPS;


-------------------------------------------------------------------
FUNCTION VALUE_SPECIFIC
	(NAME		IN VARCHAR2
	,USER_ID	IN NUMBER DEFAULT NULL
	,RESPONSIBILITY_ID	IN NUMBER DEFAULT NULL
	,APPLICATION_ID		IN NUMBER DEFAULT NULL
	)
RETURN VARCHAR2
IS
-- l_org_id 					NUMBER;
l_active_profile 			VARCHAR2(80);
l_profile_value				VARCHAR2(255);
BEGIN

	IF UPPER(NAME) = 'SO_ORGANIZATION_ID' or UPPER(NAME) = 'OE_ORGANIZATION_ID'     THEN
        IF (USER_ID IS NULL AND RESPONSIBILITY_ID IS NULL AND APPLICATION_ID IS NULL) THEN
	      l_profile_value := OE_Sys_Parameters.VALUE(
	      param_name => 'MASTER_ORGANIZATION_ID');
-- removing ELSE clause as part of MOAC project as we should not be looking at the ORG_ID profile.
-- this can be taken out NOCOPY /* file.sql.39 change */ completely as no caller is populating the user/app/resp when calling this procedure
/*
	ELSE
           l_org_id := TO_NUMBER(FND_PROFILE.Value_Specific('ORG_ID',
	      USER_ID, RESPONSIBILITY_ID, APPLICATION_ID));
	      l_profile_value := OE_Sys_Parameters.VALUE(
	      param_name => 'MASTER_ORGANIZATION_ID',
	      p_org_id => l_org_id);
*/
        END IF;

	ELSIF UPPER(NAME) = 'SO_SET_OF_BOOKS_ID' OR UPPER(NAME) = 'OE_SET_OF_BOOKS_ID' THEN
        IF (USER_ID IS NULL AND RESPONSIBILITY_ID IS NULL AND APPLICATION_ID IS NULL) THEN
	      l_profile_value := OE_Sys_Parameters.VALUE(
	      param_name => 'SET_OF_BOOKS_ID');
-- removing ELSE clause as part of MOAC project as we should not be looking at the ORG_ID profile.
-- this can be taken out NOCOPY /* file.sql.39 change */ completely as no caller is populating the user/app/resp when calling this procedure
/*
        ELSE
           l_org_id := TO_NUMBER(FND_PROFILE.Value_Specific('ORG_ID',
	      USER_ID, RESPONSIBILITY_ID, APPLICATION_ID));
	      l_profile_value := OE_Sys_Parameters.VALUE(
	      param_name => 'SET_OF_BOOKS_ID',
	      p_org_id => l_org_id);
*/
        END IF;

	ELSE


	l_active_profile := Get_Active_Profile_Name(NAME);

	l_profile_value := FND_PROFILE.VALUE_SPECIFIC(l_active_profile
				, USER_ID
				, RESPONSIBILITY_ID
				, APPLICATION_ID);
     END IF;
	RETURN(l_profile_value);

END VALUE_SPECIFIC;


/* Overloaded Value function to return profile retrieved in created_by context */
FUNCTION VALUE (p_header_id                           IN NUMBER     DEFAULT  NULL,
		p_line_id                           IN NUMBER    DEFAULT NULL,
		p_profile_option_name    IN VARCHAR2)

RETURN VARCHAR2

IS
  l_cached_resp_appl_id    NUMBER  := Null;
  l_cached_user_id   NUMBER  := Null;
  l_cached_resp_id   NUMBER   := Null;
  l_cached_org_id    NUMBER   := Null;
  l_get_cache_triplet_result     VARCHAR2(1)  := 'F';
  l_get_cache_profile_result     VARCHAR2(1)  := 'F';
  l_profile_option_value         VARCHAR2(260) := Null;
  l_wf_entity                          VARCHAR2(8)  := Null;
  l_id_passed                         VARCHAR2(1)  := 'N';
  p_entity_id                         NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level > 0 THEN
    oe_debug_pub.add('ENTERING OE_PROFILE.VALUE');
    oe_debug_pub.add('header_id: ' || p_header_id);
    oe_debug_pub.add('line_id: ' || p_line_id);
    oe_debug_pub.add('profile option: '|| p_profile_option_name);
  END IF;
    IF OE_GLOBALS.G_FLOW_RESTARTED AND (l_debug_level > 0) THEN
    oe_debug_pub.add('FLOW_RESTARTED GLOBAL set to TRUE');
    ELSE
    oe_debug_pub.add('FLOW_RESTARTED GLOBAL set to FALSE');
    END IF;

    IF OE_GLOBALS.G_USE_CREATED_BY_CONTEXT AND (l_debug_level > 0) THEN
    oe_debug_pub.add('USE CREATED_BY GLOBAL set to TRUE');
    ELSE
    oe_debug_pub.add('USE CREATED_BY GLOBAL set to FALSE');
    END IF;




  IF OE_GLOBALS.G_FLOW_RESTARTED
  OR OE_GLOBALS.G_USE_CREATED_BY_CONTEXT
  -- Bug 4884429, added following OR condition
  OR (p_profile_option_name = 'OE_NOTIFICATION_APPROVER') THEN
    --this profile is being accessed as part of a restarted flow or in a flow which should used the created by context


    IF p_header_id IS NOT NULL THEN
      l_wf_entity := OE_GLOBALS.G_WFI_HDR;
      p_entity_id := p_header_id;
      l_id_passed := 'Y';
    ELSIF p_line_id IS NOT NULL THEN
      l_wf_entity := OE_GLOBALS.G_WFI_LIN;
      p_entity_id  := p_line_id;
      l_id_passed := 'Y';
    END IF;

    IF l_id_passed = 'Y' THEN
      --check to see if the context triplet has already been cached for this entity
      GET_CACHED_CONTEXT(   p_entity => l_wf_entity,
	                                         p_entity_id  => p_entity_id,
	                                         x_application_id => l_cached_resp_appl_id,
	                                         x_user_id =>  l_cached_user_id,
                                                 x_responsibility_id => l_cached_resp_id,
				                 x_org_id => l_cached_org_id,
	                                         x_result => l_get_cache_triplet_result);

      IF l_get_cache_triplet_result <> 'S' THEN
	--triplet was not found in the cache
	--retrieve triplet values

	IF l_debug_level > 0 THEN
   	   oe_debug_pub.add('context not found in cache');
 	END IF;


	BEGIN
	    IF l_debug_level > 0 THEN
    	      oe_debug_pub.add('getting user and org from base tables');
      	    END IF;
          IF l_wf_entity = OE_GLOBALS.G_WFI_HDR THEN

	    SELECT created_by, org_id
	    INTO l_cached_user_id, l_cached_org_id
	    FROM oe_order_headers_all
	    WHERE header_id = p_header_id;

          ELSE

	    SELECT created_by, org_id
	    INTO l_cached_user_id, l_cached_org_id
	    FROM oe_order_lines_all
	    WHERE line_id = p_line_id;

	  END IF;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	    IF l_debug_level > 0 THEN
    	      oe_debug_pub.add('IN NO_DATA_FOUND when retrieving user and org');
      	    END IF;
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
              OE_MSG_PUB.Add_Exc_Msg
              (   G_PKG_NAME
              ,   'Value'
              );
            END IF;
	    Null;
	    WHEN OTHERS THEN
	    IF l_debug_level > 0 THEN
    	      oe_debug_pub.add('IN OTHERS when retrieving user and org' || SQLERRM);
      	    END IF;
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
              OE_MSG_PUB.Add_Exc_Msg
              (   G_PKG_NAME
              ,   'Value'
              );
        END IF;
	    Null;
	END;

	l_cached_resp_appl_id := wf_engine.GetItemAttrNumber(l_wf_entity
	                             , p_entity_id
	                             , 'APPLICATION_ID'
	                             );


	l_cached_resp_id := wf_engine.GetItemAttrNumber(l_wf_entity
	                             , p_entity_id
	                             , 'RESPONSIBILITY_ID'
	                            );


	IF l_debug_level > 0 THEN
   	   oe_debug_pub.add('before caching the retrieved context');
 	END IF;
	--Store retrieved triplet values in cache
	PUT_CACHED_CONTEXT(   p_entity => l_wf_entity,
	                                           p_entity_id  => p_entity_id,
	                                           p_application_id => l_cached_resp_appl_id,
	                                           p_user_id =>  l_cached_user_id,
	                                           p_responsibility_id => l_cached_resp_id,
					           p_org_id => l_cached_org_id);
	IF l_debug_level > 0 THEN
   	   oe_debug_pub.add('after caching the retrieved context');
 	END IF;

      END IF;
	-- end of l_get_cache_triplet_result <> 'S'
	-- at this point we should have the context triplet
	IF l_debug_level > 0 THEN
   	   oe_debug_pub.add('before attempting to get the cached profile option value');
 	END IF;
	GET_CACHED_PROFILE_FOR_CONTEXT(   p_profile_option_name => p_profile_option_name,
	                                             p_application_id => l_cached_resp_appl_id,
	                                             p_user_id =>  l_cached_user_id,
	                                             p_responsibility_id => l_cached_resp_id,
				                     p_org_id => l_cached_org_id,
	                                             x_profile_option_value => l_profile_option_value,
	                                             x_result => l_get_cache_profile_result);
	IF l_debug_level > 0 THEN
   	   oe_debug_pub.add('after attempting to get the cached profile option value');
 	END IF;

      IF l_get_cache_profile_result <> 'S' THEN
	-- profile option value was not found in cache.
	-- call FND_PROFILE.Value_Specific to retrieve context-based profile option value
	IF l_debug_level > 0 THEN
   	   oe_debug_pub.add('profile value was not found in the cache...calling FND_PROFILE.value_specific');
 	END IF;
	l_profile_option_value := FND_PROFILE.Value_Specific(p_profile_option_name, l_cached_user_id,
                                                             l_cached_resp_id, l_cached_resp_appl_id,
                                                             l_cached_org_id);

        IF l_debug_level > 0 THEN
   	  oe_debug_pub.add('profile option value from value_specific: ' || l_profile_option_value);
   	END IF;

	IF l_profile_option_value IS NULL THEN
	  --make original call to FND_PROFILE.Value
	  IF l_debug_level > 0 THEN
   	   oe_debug_pub.add('got NULL...calling FND_PROFILE.value');
   	  END IF;
	  l_profile_option_value := FND_PROFILE.Value(p_profile_option_name);

          IF l_debug_level > 0 THEN
       	    oe_debug_pub.add('profile option value from value: ' || l_profile_option_value);
   	  END IF;

        ELSE
	  -- FND_PROFILE.Value_Specfic returned a value, so cache it for later use
	  IF l_debug_level > 0 THEN
   	    oe_debug_pub.add('before caching the retrieved profile option value');
    	  END IF;
	  PUT_CACHED_PROFILE_FOR_CONTEXT(   p_profile_option_name => p_profile_option_name,
	                                                         p_application_id => l_cached_resp_appl_id,
	                                                         p_user_id =>  l_cached_user_id,
	                                                         p_responsibility_id => l_cached_resp_id,
					           	         p_org_id => l_cached_org_id,
	                                                         p_profile_option_value => l_profile_option_value);

          IF l_debug_level > 0 THEN
   	    oe_debug_pub.add('after caching the retrieved profile option value');
    	  END IF;
	END IF;
	--end of l_profile_option_value IS NULL
      END IF;
      -- end of l_get_cache_profile_result <> 'S'
    ELSE
      -- no id was passed so call should use session context so use FND_PROFILE.value
      IF l_debug_level > 0 THEN
        oe_debug_pub.add('no id was passed, calling FND_PROFILE.value');
      END IF;
      l_profile_option_value := FND_PROFILE.Value(p_profile_option_name);
      IF l_debug_level > 0 THEN
        oe_debug_pub.add('profile option value from value: ' || l_profile_option_value);
      END IF;
    END IF;
    -- end of l_id_passed = 'Y'
  ELSE
    --neither flag was set so call should use session context so use FND_PROFILE.value
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('neither global was set, calling FND_PROFILE.value');
    END IF;
    l_profile_option_value := FND_PROFILE.Value(p_profile_option_name);
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('profile option value from value: ' || l_profile_option_value);
    END IF;
  END IF;
  -- end of OE_GLOBALS.G_FLOW_RESTARTED OR
  -- OE_GLOBALS.G_USE_CREATED_BY_CONTEXT
  -- at this point we should have the profile option value
  IF l_debug_level > 0 THEN
    oe_debug_pub.add('profile option value being returned: ' || l_profile_option_value);
    oe_debug_pub.add('EXITING OE_PROFILE.VALUE');
  END IF;
  Return l_profile_option_value;

EXCEPTION
  WHEN OTHERS THEN
  IF l_debug_level > 0 THEN
    oe_debug_pub.add('IN OTHERS IN OE_PROFILE.VALUE:' || SQLERRM);
  END IF;
  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    OE_MSG_PUB.Add_Exc_Msg
    (   G_PKG_NAME
    ,   'Value'
    );
  END IF;
  return null;
END VALUE;



PROCEDURE GET_CACHED_CONTEXT(   p_entity     IN   VARCHAR2,
			        p_entity_id   IN NUMBER,
				x_application_id OUT NOCOPY   NUMBER,
				x_user_id   OUT NOCOPY     NUMBER,
				x_responsibility_id  OUT NOCOPY   NUMBER,
				x_org_id  OUT NOCOPY NUMBER,
				x_result  OUT NOCOPY  VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level > 0 THEN
    oe_debug_pub.add('ENTERING OE_PROFILE.GET_CACHED_CONTEXT');
    oe_debug_pub.add('entity: ' || p_entity);
    oe_debug_pub.add('entity_id: ' || p_entity_id);
  END IF;


IF (p_entity = OE_GLOBALS.G_WFI_HDR) THEN
  IF Header_Context_Tbl.EXISTS(p_entity_id) THEN
  IF l_debug_level > 0 THEN
    oe_debug_pub.add('Context was found in cache');
  END IF;
    --triplet values have already been cached for this line_id
    x_application_id := Header_Context_Tbl(p_entity_id).resp_appl_id;
    x_user_id := Header_Context_Tbl(p_entity_id).user_id;
    x_responsibility_id := Header_Context_Tbl(p_entity_id).resp_id;
    x_org_id := Header_Context_Tbl(p_entity_id).org_id;
    x_result := 'S';

  ELSE
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('Context was NOT found in cache');
    END IF;
    --triplet values have not been cached for this line_id
    x_application_id := null;
    x_user_id := null;
    x_responsibility_id :=null;
    x_org_id := null;
    x_result := 'F';
  END IF;
  --end of Header_Context_Tbl.EXISTS(p_entity_id)
ELSIF (p_entity = OE_GLOBALS.G_WFI_LIN) THEN
  IF Line_Context_Tbl.EXISTS(p_entity_id) THEN
  IF l_debug_level > 0 THEN
    oe_debug_pub.add('Context was found in cache');
  END IF;
    --triplet values have already been cached for this line_id
    x_application_id := Line_Context_Tbl(p_entity_id).resp_appl_id;
    x_user_id := Line_Context_Tbl(p_entity_id).user_id;
    x_responsibility_id := Line_Context_Tbl(p_entity_id).resp_id;
    x_org_id := Line_Context_Tbl(p_entity_id).org_id;
    x_result := 'S';

  ELSE
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('Context was NOT found in cache');
    END IF;
    --triplet values have not been cached for this line_id
    x_application_id := null;
    x_user_id := null;
    x_responsibility_id :=null;
    x_org_id := null;
    x_result := 'F';
  END IF;
  --end of Line_Context_Tbl.EXISTS(p_entity_id)
END IF;
--end of p_entity = OE_GLOBALS.G_WFI_HDR

   IF l_debug_level > 0 THEN
    oe_debug_pub.add('application from cache: ' || x_application_id);
    oe_debug_pub.add('user from cache: ' || x_user_id);
    oe_debug_pub.add('responsibility from cache: ' || x_responsibility_id);
    oe_debug_pub.add('org from cache: ' || x_org_id);
    oe_debug_pub.add('EXITING OE_PROFILE.GET_CACHED_CONTEXT');
   END IF;


EXCEPTION
  WHEN OTHERS THEN
  IF l_debug_level > 0 THEN
    oe_debug_pub.add('OTHERS IN OE_PROFILE.GET_CACHED_CONTEXT: ' || SQLERRM);
  END IF;
x_result := 'E';
  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    OE_MSG_PUB.Add_Exc_Msg
    (   G_PKG_NAME
    ,   'Get_Cached_Context'
    );
  END IF;
END GET_CACHED_CONTEXT;


PROCEDURE PUT_CACHED_CONTEXT(   p_entity     IN   VARCHAR2,
			        p_entity_id   IN NUMBER,
	                        p_application_id IN   NUMBER,
				p_user_id   IN     NUMBER,
				p_responsibility_id  IN   NUMBER,
				p_org_id  IN NUMBER)
IS
I                           varchar2(30);
l_new_line_position                number;
l_new_header_position         number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF l_debug_level > 0 THEN
    oe_debug_pub.add('ENTERING OE_PROFILE.PUT_CACHED_CONTEXT');
    oe_debug_pub.add('entity: ' || p_entity);
    oe_debug_pub.add('entity_id: ' || p_entity_id);
    oe_debug_pub.add('application: '|| p_application_id);
    oe_debug_pub.add('user: ' || p_user_id);
    oe_debug_pub.add('responsibility: ' || p_responsibility_id);
    oe_debug_pub.add('org: ' || p_org_id);
END IF;



IF (p_entity = OE_GLOBALS.G_WFI_HDR) THEN
  IF l_debug_level > 0 THEN
    oe_debug_pub.add('the cache is currently holding ' || Header_Context_Tbl.count || ' records.');
  END IF;

  -- triplet values need to be cached for this header_id
  --first check to see if there is space in the cache
  IF Header_Context_Tbl.count < MAX_CONTEXT_CACHE_SIZE THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('there is space in the cache');
    END IF;
    --there is space in the cache so simply add the data
    -- set new position
    l_new_header_position := Header_Context_Tbl.count + 1;

    Header_Context_Tbl(p_entity_id).position   := l_new_header_position;
    Header_Context_Tbl(p_entity_id).resp_appl_id := p_application_id;
    Header_Context_Tbl(p_entity_id).user_id      := p_user_id;
    Header_Context_Tbl(p_entity_id).resp_id      := p_responsibility_id;
    Header_Context_Tbl(p_entity_id).org_id      := p_org_id;


    IF l_debug_level > 0 THEN
      oe_debug_pub.add('added new record at position: ' || Header_Context_Tbl(p_entity_id).position);
      oe_debug_pub.add('now there are ' || Header_Context_Tbl.count || ' records in the cache after adding the new record');
    END IF;

  ELSE
    --the cache is full, so a record needs to be removed
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('cache is full.  removing a record...');
    END IF;
    I := Header_Context_Tbl.First;
    While I is NOT NULL
      LOOP
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('position: ' || Header_Context_Tbl(I).position || ' I: '  || I);
          END IF;
        IF Header_Context_Tbl(I).position = 1 THEN
          --if the record is in position 1, remove it
          Header_Context_Tbl.Delete(I);
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('deleted the record at position 1 with index: ' || I);
            oe_debug_pub.add('now there are ' || Header_Context_Tbl.count || ' header records in the cache');
          END IF;
        ELSE
          --record position needs to be shifted down
          Header_Context_Tbl(I).position :=      Header_Context_Tbl(I).position - 1;
        END IF;
        --end of Header_Context_Tbl(I).position = 1
        I := Header_Context_Tbl.NEXT(I);
      END LOOP;
    -- set new position

    l_new_header_position := Header_Context_Tbl.count + 1;
    Header_Context_Tbl(p_entity_id).position   := l_new_header_position;
    -- now add new header to cache
    Header_Context_Tbl(p_entity_id).resp_appl_id := p_application_id;
    Header_Context_Tbl(p_entity_id).user_id      := p_user_id;
    Header_Context_Tbl(p_entity_id).resp_id      := p_responsibility_id;
    Header_Context_Tbl(p_entity_id).org_id      := p_org_id;

    IF l_debug_level > 0 THEN
      oe_debug_pub.add('added new record at position: ' || Header_Context_Tbl(p_entity_id).position);
      oe_debug_pub.add('now there are ' || Header_Context_Tbl.count || ' records in the cache after adding the new record');
    END IF;

  END IF;
  -- end of Header_Context_Tbl.count < MAX_CONTEXT_CACHE_SIZE


ELSIF (p_entity = OE_GLOBALS.G_WFI_LIN) THEN
  IF l_debug_level > 0 THEN
    oe_debug_pub.add('the cache is currently holding ' || Line_Context_Tbl.count || ' records.');
  END IF;

  -- triplet values need to be cached for this line_id
  --first check to see if there is space in the cache
  IF Line_Context_Tbl.count < MAX_CONTEXT_CACHE_SIZE THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('there is space in the cache.');
    END IF;
    --there is space in the cache so simply add the data
    -- set new position
    l_new_line_position := Line_Context_Tbl.count + 1;
    Line_Context_Tbl(p_entity_id).position   := l_new_line_position;
    Line_Context_Tbl(p_entity_id).resp_appl_id := p_application_id;
    Line_Context_Tbl(p_entity_id).user_id      := p_user_id;
    Line_Context_Tbl(p_entity_id).resp_id      := p_responsibility_id;
    Line_Context_Tbl(p_entity_id).org_id      := p_org_id;

    IF l_debug_level > 0 THEN
      oe_debug_pub.add('added new record at position: ' || Line_Context_Tbl(p_entity_id).position);
      oe_debug_pub.add('now there are ' || Line_Context_Tbl.count || ' records in the cache after adding the new record');
    END IF;


  ELSE
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('cache is full.  removing a record...');
    END IF;
    --the cache is full, so a record needs to be removed
    I := Line_Context_Tbl.First;
    While I is NOT NULL
      LOOP
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('position: ' || Line_Context_Tbl(I).position || ' I: '  || I);
          END IF;
        IF Line_Context_Tbl(I).position = 1 THEN
          --if the record is in position 1, remove it
          Line_Context_Tbl.Delete(I);
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('deleted the record at position 1 with index: ' || I);
            oe_debug_pub.add('now there are ' || Line_Context_Tbl.count || ' line records in the cache');
          END IF;
        ELSE
          --record position needs to be shifted down
          Line_Context_Tbl(I).position :=      Line_Context_Tbl(I).position - 1;
        END IF;
        --end of Line_Context_Tbl(I).position = 1
        I := Line_Context_Tbl.NEXT(I);
      END LOOP;
    -- set new position
    l_new_line_position := Line_Context_Tbl.count + 1;
    Line_Context_Tbl(p_entity_id).position   := l_new_line_position;
    -- now add new line to cache
    Line_Context_Tbl(p_entity_id).resp_appl_id := p_application_id;
    Line_Context_Tbl(p_entity_id).user_id      := p_user_id;
    Line_Context_Tbl(p_entity_id).resp_id      := p_responsibility_id;
    Line_Context_Tbl(p_entity_id).org_id      := p_org_id;

    IF l_debug_level > 0 THEN
      oe_debug_pub.add('added new record at position: ' || Line_Context_Tbl(p_entity_id).position);
      oe_debug_pub.add('now there are ' || Line_Context_Tbl.count || ' records in the cache after adding the new record');
    END IF;


  END IF;
  -- end of Line_Context_Tbl.count < MAX_CONTEXT_CACHE_SIZE

  END IF;
  -- End of p_entity = OE_GLOBALS.G_WFI_HDR


EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('OTHERS IN OE_PROFILE.PUT_CACHED_CONTEXT: ' || SQLERRM);
    END IF;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Put_Cached_Context'
      );
  END IF;
END PUT_CACHED_CONTEXT;



PROCEDURE GET_CACHED_PROFILE_FOR_CONTEXT(   p_profile_option_name     IN   VARCHAR2,
                                            p_application_id  IN  NUMBER,
                                            p_user_id   IN     NUMBER,
                                            p_responsibility_id  IN  NUMBER,
           		  	            p_org_id  IN NUMBER,
	                                    x_profile_option_value OUT NOCOPY VARCHAR2,
	                                    x_result OUT NOCOPY  VARCHAR2)
IS

l_concat_segment VARCHAR2(100);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

IF l_debug_level > 0 THEN
    oe_debug_pub.add('ENTERING OE_PROFILE.GET_CACHED_PROFILE_FOR_CONTEXT');
    oe_debug_pub.add('profile: ' || p_profile_option_name);
    oe_debug_pub.add('application: '|| p_application_id);
    oe_debug_pub.add('user: ' || p_user_id);
    oe_debug_pub.add('responsibility: ' || p_responsibility_id);
    oe_debug_pub.add('org: ' || p_org_id);
END IF;


l_concat_segment := 'u'||p_user_id||'r'||p_responsibility_id||'a'||p_application_id ||'o'||
	             p_org_id|| 'p' || p_profile_option_name;

IF Prf_Tbl.EXISTS(l_concat_segment) THEN
  IF l_debug_level > 0 THEN
    oe_debug_pub.add('index already exists in profile cache.');
  END IF;

  x_profile_option_value := Prf_Tbl(l_concat_segment).prf_value;
  x_result := 'S';

ELSE
  x_profile_option_value := null;
  x_result := 'F';
  IF l_debug_level > 0 THEN
    oe_debug_pub.add('index does not exist in profile cache.');
  END IF;
  Return;
END IF;
-- end of Prf_Tbl.EXISTS(l_concat_segment)

IF l_debug_level > 0 THEN
    oe_debug_pub.add('EXITING OE_PROFILE.GET_CACHED_PROFILE_FOR_CONTEXT');
END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_profile_option_value := null;
    x_result := 'E';
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('OTHERS IN OE_PROFILE.GET_CACHED_PROFILE_FOR_CONTEXT: ' || SQLERRM);
    END IF;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Get_Cached_Profile_For_Context'
      );
    END IF;
END GET_CACHED_PROFILE_FOR_CONTEXT;



PROCEDURE PUT_CACHED_PROFILE_FOR_CONTEXT(    p_profile_option_name     IN   VARCHAR2,
	                                     p_application_id    IN   NUMBER,
	                                     p_user_id   IN     NUMBER,
	                                     p_responsibility_id IN   NUMBER,
		       		             p_org_id  IN NUMBER,
	                                     p_profile_option_value  IN VARCHAR2)
IS
I                           Varchar2(100);
l_new_prf_position          number;
l_concat_segment VARCHAR2(100);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF l_debug_level > 0 THEN
    oe_debug_pub.add('ENTERING OE_PROFILE.PUT_CACHED_PROFILE_FOR_CONTEXT');
    oe_debug_pub.add('Records currently stored in profile cache: ' || Prf_Tbl.count);
    oe_debug_pub.add('profile: ' || p_profile_option_name);
    oe_debug_pub.add('application: '|| p_application_id);
    oe_debug_pub.add('user: ' || p_user_id);
    oe_debug_pub.add('responsibility: ' || p_responsibility_id);
    oe_debug_pub.add('org: ' || p_org_id);
    oe_debug_pub.add('profile value:' || p_profile_option_value);
END IF;


  l_concat_segment := 'u'||p_user_id||'r'||p_responsibility_id||'a'||p_application_id ||'o'||
  p_org_id|| 'p' || p_profile_option_name;


  -- see if there is space in the cache
  IF Prf_Tbl.count < MAX_PROFILE_CACHE_SIZE THEN

    IF l_debug_level > 0 THEN
      oe_debug_pub.add('space is available in the cache so adding the record at position: ' ||  (Prf_Tbl.count + 1));
    END IF;
    --there is space in the cache so simply add the data
    --get new position
    l_new_prf_position :=  Prf_Tbl.count + 1;
    Prf_Tbl(l_concat_segment).position := l_new_prf_position;
    Prf_Tbl(l_concat_segment).prf_value := p_profile_option_value;


    IF l_debug_level > 0 THEN
      oe_debug_pub.add('now there are ' || Prf_Tbl.count || ' records in the cache after adding the new record');
    END IF;


  ELSE
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('cache is full so remove a record');
    END IF;

    -- the cache is full, so a record needs to be removed
    I := Prf_Tbl.First;
    While I is NOT NULL
      LOOP
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('position: ' || Prf_Tbl(I).position || ' I: '  || I);
          END IF;
        IF Prf_Tbl(I).position = 1 THEN
	  -- if the record is in position 1, remove it
	  Prf_Tbl.Delete(I);
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('deleted the record at position 1 with index: ' || I);
            oe_debug_pub.add('now there are ' || Prf_Tbl.count || ' profile records in the cache');
          END IF;
        ELSE
	  --record position needs to be shifted down
	  Prf_Tbl(I).position :=      Prf_Tbl(I).position - 1;
        END IF;
        --end of Prf_Tbl(I).position = 1
        I := Prf_Tbl.NEXT(I);
      END LOOP;
     -- get new position
    l_new_prf_position :=  Prf_Tbl.count + 1;
    Prf_Tbl(l_concat_segment).position := l_new_prf_position;
    -- now add new record to cache
    Prf_Tbl(l_concat_segment).prf_value := p_profile_option_value;

    IF l_debug_level > 0 THEN
      oe_debug_pub.add('added the new record at position: ' ||  Prf_Tbl(l_concat_segment).position);
      oe_debug_pub.add('now there are ' || Prf_Tbl.count || ' records in the cache after adding the new record');
    END IF;

  END IF;  -- end of Prf_Tbl.count < MAX_PROFILE_CACHE_SIZE

IF l_debug_level > 0 THEN
  oe_debug_pub.add('EXITING OE_PROFILE.PUT_CACHED_PROFILE_FOR_CONTEXT');
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('OTHERS IN OE_PROFILE.PUT_CACHED_PROFILE_FOR_CONTEXT: ' || SQLERRM);
    END IF;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Put_Cached_Profile_For_Context'
      );
    END IF;
END PUT_CACHED_PROFILE_FOR_CONTEXT;



END OE_PROFILE;

/
