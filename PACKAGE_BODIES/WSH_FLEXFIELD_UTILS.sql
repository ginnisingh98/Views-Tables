--------------------------------------------------------
--  DDL for Package Body WSH_FLEXFIELD_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FLEXFIELD_UTILS" as
/* $Header: WSHFFUTB.pls 120.1.12000000.3 2007/03/30 09:36:11 nchellam ship $ */

-- Private Type Definintions

TYPE Default_DFF_Attributes_Rec IS RECORD (table_name  		Varchar2(30),
                                       default_context 	Varchar2(150),
                                       first_segment         	Number,
                                       last_segment         	Number,
                                       update_flag    	Varchar2(1));

TYPE DFF_Check_Req_Rec IS RECORD (table_name 		Varchar2(30),
                                  context_req_flag 	Varchar2(1),
                                  seg_req_flag		Varchar2(1));


TYPE Context_Check_Req_Rec IS RECORD (table_name 	Varchar2(30),
                                      context 		Varchar2(30),
                                      first_segment    	Number,
                                      last_segment  	Number);

TYPE Attribute_Rec IS RECORD(segment_value  Varchar2(150),
                                 attribute_index Number);


TYPE Attribute_Rec_Tab IS TABLE OF Attribute_Rec INDEX BY BINARY_INTEGER;

TYPE Context_Check_Req_Tab IS TABLE OF Context_Check_Req_Rec INDEX BY BINARY_INTEGER;

TYPE DFF_Check_Req_Tab IS TABLE OF DFF_Check_Req_Rec INDEX BY BINARY_INTEGER;

TYPE Def_DFF_Attr_Rec_Tab IS TABLE OF Default_DFF_Attributes_Rec INDEX BY BINARY_INTEGER;

-- Global Variables

g_def_attribute_values Attribute_Rec_Tab;
g_req_attribute_values Attribute_Rec_Tab;
g_validate_context Context_Check_Req_Tab;
g_check_req DFF_Check_Req_Tab;
g_def_attributes Def_DFF_Attr_Rec_Tab;


/****
PROCEDURE get_flexfield has been copied from
AFFFDDUB.pls 115.2 2001/05/23 00:57:34 golgun ship
and has been modified to include the
context_required_flag in the flexfield info
record - dflex_dr
*****/


--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_FLEXFIELD_UTILS';
--
PROCEDURE get_flexfield(appl_short_name  IN  fnd_application.application_short_name%TYPE,
                        flexfield_name   IN  fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
                        flexfield        OUT NOCOPY  fnd_dflex.dflex_r,
                        flexinfo         OUT NOCOPY  wsh_flexfield_utils.dflex_dr)
  IS
     ffld fnd_dflex.dflex_r;
     dflex wsh_flexfield_utils.dflex_dr;

     CURSOR c_get_flexname IS
     SELECT /* $Header: WSHFFUTB.pls 120.1.12000000.3 2007/03/30 09:36:11 nchellam ship $ */
          a.application_id, df.descriptive_flexfield_name
     FROM fnd_application_vl a, fnd_descriptive_flexs_vl df
     WHERE a.application_short_name = appl_short_name
     AND a.application_id = df.application_id
     AND df.descriptive_flexfield_name = flexfield_name;


     CURSOR c_get_flex_properties IS
     SELECT /* $Header: WSHFFUTB.pls 120.1.12000000.3 2007/03/30 09:36:11 nchellam ship $ */
          df.title, df.application_table_name, a.application_short_name,
     df.description, df.concatenated_segment_delimiter,
     df.default_context_field_name, df.default_context_value,
     protected_flag,
     form_context_prompt, context_column_name, df.context_required_flag
     FROM fnd_application_vl a, fnd_descriptive_flexs_vl df
     WHERE df.application_id = ffld.application_id
     AND df.descriptive_flexfield_name = ffld.flexfield_name
     AND a.application_id = df.table_application_id;



--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_FLEXFIELD';
--
  BEGIN

   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'APPL_SHORT_NAME',appl_short_name);
       WSH_DEBUG_SV.log(l_module_name,'FLEXFIELD_NAME',flexfield_name);

   END IF;
   --
   OPEN c_get_flexname;
   FETCH c_get_flexname
   INTO ffld;
   IF c_get_flexname%ISOPEN THEN
      CLOSE c_get_flexname;
   END IF;

   OPEN c_get_flex_properties;
   FETCH c_get_flex_properties
   INTO dflex;
   IF c_get_flex_properties%ISOPEN THEN
     CLOSE c_get_flex_properties;
   END IF;

   flexfield := ffld;
   flexinfo := dflex;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
 END get_flexfield;


FUNCTION Cache_DFF_Segments(p_table_name IN VARCHAR2,
                             x_return_status OUT NOCOPY  VARCHAR2)
                             RETURN BINARY_INTEGER IS
   l_table_name Varchar2(30);
   l_flexfield fnd_dflex.dflex_r;
   l_flexinfo  dflex_dr;
   l_contexts  fnd_dflex.contexts_dr;
   l_segments  fnd_dflex.segments_dr;
   l_glbl_segments  fnd_dflex.segments_dr;
   i BINARY_INTEGER;
   j BINARY_INTEGER;
   k BINARY_INTEGER;
   n NUMBER;
   l_found BOOLEAN := FALSE;

   Invalid_Table EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CACHE_DFF_SEGMENTS';
--
BEGIN

    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TABLE_NAME',P_TABLE_NAME);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    l_table_name := UPPER(p_table_name);

-- 2530743 : Commenting this as this Fn./Proc. will be needed for other DFFs too
--    IF l_table_name <> 'WSH_NEW_DELIVERIES' THEN
--     RAISE Invalid_Table;
--    END IF;

    IF g_def_attributes.count <> 0 THEN

      -- Check if parameters have already been fetched
      FOR i IN g_def_attributes.FIRST..g_def_attributes.LAST LOOP
        IF g_def_attributes(i).table_name = l_table_name THEN
          l_found := TRUE;
          j := i;
          EXIT;
        END IF;
      END LOOP;

      IF l_found THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN j;
      END IF;

    END IF;


    get_flexfield(appl_short_name => 'WSH',
                  flexfield_name => l_table_name,
                  flexfield => l_flexfield,
                  flexinfo => l_flexinfo);

    fnd_dflex.get_contexts(flexfield  => l_flexfield,
                           contexts => l_contexts);

    fnd_dflex.get_segments(context => fnd_dflex.make_context(flexfield => l_flexfield,
                                                             context_code => l_flexinfo.default_context_value),
                           segments => l_segments,
                           enabled_only => TRUE);

    fnd_dflex.get_segments(context => fnd_dflex.make_context(flexfield => l_flexfield,
                                                             context_code => l_contexts.context_code(l_contexts.global_context)),
                           segments => l_glbl_segments,
                           enabled_only => TRUE);


    IF g_def_attributes.count = 0 THEN
      j := 1;
      g_def_attributes(j).first_segment := 1;

    ELSE
      j := g_def_attributes.LAST + 1;
      g_def_attributes(j).first_segment := g_def_attributes(j-1).last_segment + 1;
    END IF;

    g_def_attributes(j).table_name := l_table_name;
    g_def_attributes(j).default_context := l_flexinfo.default_context_value;

    k := 0;
    FOR i IN 1..l_segments.nsegments  LOOP
      IF l_segments.default_value(i) IS NOT NULL  THEN
       k := k + 1;
       g_def_attribute_values(g_def_attributes(j).first_segment + k - 1).attribute_index := (to_number(substr(l_segments.application_column_name(i),10)));
       g_def_attribute_values(g_def_attributes(j).first_segment + k - 1).segment_value := l_segments.default_value(i);
      END IF;
    END LOOP;

    -- Added for bug 2353335
   --BugFix 4995455 replaced global context with default
    FND_FLEX_DESCVAL.set_context_value(l_flexinfo.default_context_value);

    FOR i IN 1..l_glbl_segments.nsegments  LOOP
         fnd_flex_descval.set_column_value(l_glbl_segments.application_column_name(i),'');
    END LOOP;

     --BugFix 4995455 added for loop to populate the default segement
    FOR i IN 1..l_segments.nsegments  LOOP
      fnd_flex_descval.set_column_value(l_segments.application_column_name(i),'');
    END  LOOP;

   -- Bug# 5603974: Considering Automotive TP DFF attributes also.
   --Before call to validate');
   IF  FND_FLEX_DESCVAL.validate_desccols( 'WSH', l_table_name, 'D', SYSDATE) then
   --{
       n := fnd_flex_descval.segment_count;
       FOR i in 1..n LOOP
       --{
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'fnd_flex_descval.segment_column_name(i))',fnd_flex_descval.segment_column_name(i));
          END if;
          IF( upper(substr(fnd_flex_descval.segment_column_name(i), 1, 2)) = 'TP' ) THEN
          --{
               IF( upper(substr(fnd_flex_descval.segment_column_name(i), 1, 12))
             		 =  'TP_ATTRIBUTE' AND upper(fnd_flex_descval.segment_column_name(i))
			     <> 'TP_ATTRIBUTE_CATEGORY') Then
                   k := k + 1;
         	       g_def_attribute_values(g_def_attributes(j).first_segment + k - 1).attribute_index := (to_number(substr(fnd_flex_descval.segment_column_name(i),13)));
         	       -- bug 5948562, segment value - used for display, segment id - should be stored in db to prevent any format issues.
		       g_def_attribute_values(g_def_attributes(j).first_segment + k - 1).segment_value := fnd_flex_descval.segment_id(i);
               END IF;

     	  ELSE
               IF( upper(substr(fnd_flex_descval.segment_column_name(i), 1, 9))
             		 =  'ATTRIBUTE' AND upper(fnd_flex_descval.segment_column_name(i))
			         <> 'ATTRIBUTE_CATEGORY') Then

                     k := k + 1;
         	         g_def_attribute_values(g_def_attributes(j).first_segment + k - 1).attribute_index := (to_number(substr(fnd_flex_descval.segment_column_name(i),10)));
			  IF l_debug_on THEN
			        WSH_DEBUG_SV.log(l_module_name,'The segments value is',fnd_flex_descval.segment_value(i));
                                WSH_DEBUG_SV.log(l_module_name,'The segment id is',fnd_flex_descval.segment_id(i));
                	  END IF;
			  -- bug 5948562, segment value - used for display, segment id - should be stored in db to prevent any format issues.
			 g_def_attribute_values(g_def_attributes(j).first_segment + k - 1).segment_value := fnd_flex_descval.segment_id(i);
               END IF;
          --}TP check
          END IF;
       --}
       END LOOP;
   ELSE
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'ERROR_SEGMENT',fnd_flex_descval.error_segment);
         WSH_DEBUG_SV.log(l_module_name,'ERROR_MESSAGE',fnd_flex_descval.error_message);
      END IF;
   --} validate_desccols
   END IF;
    -- End of fix for bug 2353335

    g_def_attributes(j).last_segment :=  g_def_attributes(j).first_segment + k  - 1;

    IF  g_def_attributes(j).default_context IS NOT NULL THEN
        g_def_attributes(j).update_flag := 'Y';
    ELSE
        IF g_def_attributes(j).last_segment >= g_def_attributes(j).first_segment THEN
             g_def_attributes(j).update_flag := 'Y';
        END IF;
    END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN j;
    EXCEPTION

      WHEN Invalid_Table THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_TABLE');
         FND_MESSAGE.Set_Token('TABLE', p_table_name);
         WSH_UTIL_CORE.Add_Message(x_return_status);
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_TABLE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_TABLE');
         END IF;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN NULL;
         --
     WHEN Others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status);
         WSH_UTIL_CORE.default_handler('WSH_FLEXFIELD_UTILS.e_DFF_Segments');
         --
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN NULL;

END Cache_DFF_Segments;



PROCEDURE Get_DFF_Defaults
          (p_flexfield_name IN VARCHAR2,
           p_default_values  OUT NOCOPY  FlexfieldAttributeTabType,
           p_default_context OUT NOCOPY  VARCHAR2,
           p_update_flag OUT NOCOPY  VARCHAR2,
           x_return_status OUT NOCOPY  VARCHAR2) IS


   j BINARY_INTEGER;
   i BINARY_INTEGER;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DFF_DEFAULTS';
--
BEGIN
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_FLEXFIELD_NAME',P_FLEXFIELD_NAME);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  For i in 1..15 LOOP
      p_default_values(i) := NULL;
  End LOOP;
  j := Cache_DFF_Segments(p_table_name => p_flexfield_name,
                          x_return_status => x_return_status);

  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
  END IF;


  p_default_context := g_def_attributes(j).default_context;
  p_update_flag := g_def_attributes(j).update_flag;

  FOR i IN g_def_attributes(j).first_segment.. g_def_attributes(j).last_segment LOOP
     p_default_values(g_def_attribute_values(i).attribute_index):=  g_def_attribute_values(i).segment_value;
  END LOOP;


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
  EXCEPTION
     WHEN Others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status);
         WSH_UTIL_CORE.default_handler('WSH_FLEXFIELD_UTILS.Get_DFF_Defaults');


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_DFF_Defaults;


PROCEDURE Write_DFF_Attributes(p_table_name IN VARCHAR2,
                               p_primary_id IN NUMBER,
                               x_return_status OUT NOCOPY  VARCHAR2) IS

   context VARCHAR2(150);
   update_flag VARCHAR2(1);
   attributes FlexfieldAttributeTabType;
   flexfield_name VARCHAR2(30);
   delivery_name  VARCHAR(30);
   j BINARY_INTEGER;
   i BINARY_INTEGER;

Invalid_Table EXCEPTION;


                                     --
l_debug_on BOOLEAN;
                                     --
                                     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'WRITE_DFF_ATTRIBUTES';
                                     --
BEGIN
     --
     -- Debug Statements
     --
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.push(l_module_name);
         --
         WSH_DEBUG_SV.log(l_module_name,'P_TABLE_NAME',P_TABLE_NAME);
         WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_ID',P_PRIMARY_ID);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     flexfield_name  := p_table_name;

     Get_DFF_Defaults(p_flexfield_name => flexfield_name,
                      p_default_values => attributes,
                      p_default_context => context,
                      p_update_flag => update_flag,
                      x_return_status => x_return_status);

     IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
     END IF;

     IF update_flag = 'Y' THEN

       IF (UPPER(p_table_name) = 'WSH_NEW_DELIVERIES')  THEN
         UPDATE wsh_new_deliveries
         SET Attribute_Category = context,
            Attribute1 = attributes(1),
            Attribute2 = attributes(2),
            Attribute3 = attributes(3),
            Attribute4 = attributes(4),
            Attribute5 = attributes(5),
            Attribute6 = attributes(6),
            Attribute7 = attributes(7),
            Attribute8 = attributes(8),
            Attribute9 = attributes(9),
            Attribute10 = attributes(10),
            Attribute11 = attributes(11),
            Attribute12 = attributes(12),
            Attribute13 = attributes(13),
            Attribute14 = attributes(14),
            Attribute15 = attributes(15),
	    last_update_date             = SYSDATE,
	    last_updated_by              = FND_GLOBAL.USER_ID,
	    last_update_login            = FND_GLOBAL.LOGIN_ID
         WHERE delivery_id = p_primary_id;
       ELSIF (UPPER(p_table_name) = 'WSH_TRIPS')  THEN -- bug 5948562, for additional trip information DFF

	 UPDATE wsh_trips
         SET Attribute_Category = context,
            Attribute1 = attributes(1),
            Attribute2 = attributes(2),
            Attribute3 = attributes(3),
            Attribute4 = attributes(4),
            Attribute5 = attributes(5),
            Attribute6 = attributes(6),
            Attribute7 = attributes(7),
            Attribute8 = attributes(8),
            Attribute9 = attributes(9),
            Attribute10 = attributes(10),
            Attribute11 = attributes(11),
            Attribute12 = attributes(12),
            Attribute13 = attributes(13),
            Attribute14 = attributes(14),
            Attribute15 = attributes(15),
	    last_update_date             = SYSDATE,
	    last_updated_by              = FND_GLOBAL.USER_ID,
	    last_update_login            = FND_GLOBAL.LOGIN_ID
         WHERE trip_id = p_primary_id;
       ELSE
        RAISE Invalid_Table;
       END IF;

    END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
    EXCEPTION
     WHEN Invalid_Table THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_TABLE');
         FND_MESSAGE.Set_Token('TABLE', p_table_name);
         WSH_UTIL_CORE.Add_Message(x_return_status);
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_TABLE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_TABLE');
         END IF;
         --
     WHEN Others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status);
         WSH_UTIL_CORE.default_handler('WSH_FLEXFIELD_UTILS.Write_DFF_Attributes');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Write_DFF_Attributes;


PROCEDURE Read_Table_Attributes(p_table_name IN VARCHAR2,
                               p_primary_id IN NUMBER,
                               p_attributes OUT NOCOPY  FlexfieldAttributeTabType,
                               p_context OUT NOCOPY  VARCHAR2,
                               x_return_status OUT NOCOPY  VARCHAR2) IS

   l_attribute1 VARCHAR2(150);
   l_attribute2 VARCHAR2(150);
   l_attribute3 VARCHAR2(150);
   l_attribute4 VARCHAR2(150);
   l_attribute5 VARCHAR2(150);
   l_attribute6 VARCHAR2(150);
   l_attribute7 VARCHAR2(150);
   l_attribute8 VARCHAR2(150);
   l_attribute9 VARCHAR2(150);
   l_attribute10 VARCHAR2(150);
   l_attribute11 VARCHAR2(150);
   l_attribute12 VARCHAR2(150);
   l_attribute13 VARCHAR2(150);
   l_attribute14 VARCHAR2(150);
   l_attribute15 VARCHAR2(150);
   l_context VARCHAR2(150);

   cursor c_wnd_attributes(c_delivery_id NUMBER) is
   select attribute_category, attribute1, attribute2, attribute3, attribute4, attribute5, attribute6, attribute7,
       attribute8, attribute9, attribute10, attribute11, attribute12, attribute13, attribute14, attribute15
   from   wsh_new_deliveries
   where delivery_id = c_delivery_id;

   -- Cussor added for Bug 3118519
   cursor c_wdd_attributes(c_delivery_detail_id NUMBER) is
      SELECT attribute_category,
             attribute1,  attribute2,  attribute3,  attribute4,  attribute5,
             attribute6,  attribute7,  attribute8,  attribute9,  attribute10,
             attribute11, attribute12, attribute13, attribute14, attribute15
      FROM wsh_delivery_details
      WHERE delivery_detail_id = c_delivery_detail_id;

   Invalid_Table EXCEPTION;
   Invalid_Delivery EXCEPTION;

   -- Exception added for Bug 3118519
   Invalid_Del_Detail EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'READ_TABLE_ATTRIBUTES';
--
   BEGIN

   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_TABLE_NAME',P_TABLE_NAME);
       WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_ID',P_PRIMARY_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (UPPER(p_table_name) = 'WSH_NEW_DELIVERIES') THEN

      open c_wnd_attributes(p_primary_id);
      fetch c_wnd_attributes into
      l_context, l_attribute1, l_attribute2, l_attribute3, l_attribute4, l_attribute5,
      l_attribute6, l_attribute7, l_attribute8, l_attribute9, l_attribute10,
      l_attribute11, l_attribute12, l_attribute13, l_attribute14, l_attribute15;

      IF c_wnd_attributes%NOTFOUND THEN
        RAISE Invalid_Delivery;
      END IF;

      IF c_wnd_attributes%ISOPEN THEN
        CLOSE c_wnd_attributes;
      END IF;

      p_context := l_context;
      p_attributes(1) := l_attribute1;
      p_attributes(2) := l_attribute2;
      p_attributes(3) := l_attribute3;
      p_attributes(4) := l_attribute4;
      p_attributes(5) := l_attribute5;
      p_attributes(6) := l_attribute6;
      p_attributes(7) := l_attribute7;
      p_attributes(8) := l_attribute8;
      p_attributes(9) := l_attribute9;
      p_attributes(10) := l_attribute10;
      p_attributes(11) := l_attribute11;
      p_attributes(12) := l_attribute12;
      p_attributes(13) := l_attribute13;
      p_attributes(14) := l_attribute14;
      p_attributes(15) := l_attribute15;

   -- ELSE Condition added for Bug 3118519.
   ELSIF ( UPPER(p_table_name) = 'WSH_DELIVERY_DETAILS' ) THEN

      open  c_wdd_attributes(p_primary_id);
      fetch c_wdd_attributes into
            l_context,
            l_attribute1,  l_attribute2,  l_attribute3,  l_attribute4,  l_attribute5,
            l_attribute6,  l_attribute7,  l_attribute8,  l_attribute9,  l_attribute10,
            l_attribute11, l_attribute12, l_attribute13, l_attribute14, l_attribute15;

      IF c_wdd_attributes%NOTFOUND THEN
        RAISE Invalid_Del_Detail;
      END IF;

      IF c_wdd_attributes%ISOPEN THEN
        CLOSE c_wdd_attributes;
      END IF;

      p_context := l_context;
      p_attributes(1)  :=  l_attribute1;
      p_attributes(2)  :=  l_attribute2;
      p_attributes(3)  :=  l_attribute3;
      p_attributes(4)  :=  l_attribute4;
      p_attributes(5)  :=  l_attribute5;
      p_attributes(6)  :=  l_attribute6;
      p_attributes(7)  :=  l_attribute7;
      p_attributes(8)  :=  l_attribute8;
      p_attributes(9)  :=  l_attribute9;
      p_attributes(10) :=  l_attribute10;
      p_attributes(11) :=  l_attribute11;
      p_attributes(12) :=  l_attribute12;
      p_attributes(13) :=  l_attribute13;
      p_attributes(14) :=  l_attribute14;
      p_attributes(15) :=  l_attribute15;

   ELSE

      RAISE Invalid_Table;

   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
    WHEN Invalid_Delivery THEN
         IF c_wnd_attributes%ISOPEN THEN
           CLOSE c_wnd_attributes;
         END IF;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_DELIVERY');
         FND_MESSAGE.Set_Token('DELIVERY', p_primary_id);
         WSH_UTIL_CORE.Add_Message(x_return_status);
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_DELIVERY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_DELIVERY');
         END IF;
         --
    -- Exception Handling added for Bug 3118519.
    WHEN Invalid_Del_Detail THEN
         IF c_wdd_attributes%ISOPEN THEN
           CLOSE c_wdd_attributes;
         END IF;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('WSH', 'WSH_DET_INVALID_DETAIL');
         FND_MESSAGE.Set_Token('DETAIL_ID', p_primary_id);
         WSH_UTIL_CORE.Add_Message(x_return_status);
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_DEL_DETAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_DEL_DETAIL');
         END IF;
         --
    WHEN Invalid_Table THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_TABLE');
         FND_MESSAGE.Set_Token('TABLE', p_table_name);
         WSH_UTIL_CORE.Add_Message(x_return_status);
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_TABLE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_TABLE');
         END IF;
         --
    WHEN Others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status);
         WSH_UTIL_CORE.default_handler('WSH_FLEXFIELD_UTILS.Get_Attribute_Values');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Read_Table_Attributes;


FUNCTION Check_DFF_Req (p_table_name IN VARCHAR2,
                         x_return_status OUT NOCOPY  VARCHAR2)
                         RETURN BINARY_INTEGER IS
   l_table_name Varchar2(30);
   l_flexfield fnd_dflex.dflex_r;
   l_flexinfo  dflex_dr;
   l_contexts  fnd_dflex.contexts_dr;
   l_segments  fnd_dflex.segments_dr;
   l_glbl_segments  fnd_dflex.segments_dr;
   i BINARY_INTEGER;
   j BINARY_INTEGER;
   l_found BOOLEAN := FALSE;

   Invalid_Table EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_DFF_REQ';
--
BEGIN

    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TABLE_NAME',P_TABLE_NAME);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    l_table_name := UPPER(p_table_name);

-- 2530743 : Commenting this as this Fn./Proc. will be needed for other DFFs too
--    IF l_table_name <> 'WSH_NEW_DELIVERIES' THEN
--      RAISE Invalid_Table;
--    END IF;

    IF g_check_req.count <> 0 THEN

      -- Check if parameters have already been fetched
      FOR i IN g_check_req.FIRST..g_check_req.LAST LOOP
        IF g_check_req(i).table_name = l_table_name THEN
          l_found := TRUE;
          j := i;
          EXIT;
        END IF;
      END LOOP;

      IF l_found THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN j;
      END IF;

    END IF;

    IF g_check_req.count = 0 THEN
      j := 1;
    ELSE
      j := g_check_req.last + 1;
    END IF;

        g_check_req(j).table_name := l_table_name;

    get_flexfield(appl_short_name => 'WSH',
                  flexfield_name => l_table_name,
                  flexfield => l_flexfield,
                  flexinfo => l_flexinfo);

    fnd_dflex.get_contexts(flexfield  => l_flexfield,
                           contexts => l_contexts);

    IF l_flexinfo.context_required = 'Y' THEN
     g_check_req(j).context_req_flag := 'Y';
    END IF;
    <<outer_loop>>
    FOR i IN 1..l_contexts.ncontexts LOOP
       IF l_contexts.is_enabled(i) THEN

            fnd_dflex.get_segments(context => fnd_dflex.make_context(flexfield => l_flexfield,
                                                                     context_code => l_contexts.context_code(i)),
                           segments => l_segments,
                           enabled_only => TRUE);

            FOR i IN 1..l_segments.nsegments LOOP
                IF l_segments.is_required(i) THEN
                      g_check_req(j).seg_req_flag := 'Y';
                      EXIT outer_loop;
                END IF;
            END LOOP;
        END IF;
     END LOOP;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN j;

EXCEPTION

 WHEN Invalid_Table THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_TABLE');
         FND_MESSAGE.Set_Token('TABLE', p_table_name);
         WSH_UTIL_CORE.Add_Message(x_return_status);
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN NULL;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_TABLE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_TABLE');
END IF;
--
 WHEN Others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status);
         WSH_UTIL_CORE.default_handler('WSH_FLEXFIELD_UTILS.Check_DFF_Req');
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN NULL;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END  Check_DFF_Req;


FUNCTION Cache_Context_Req (p_table_name IN VARCHAR2,
                             p_context IN VARCHAR2,
                             x_return_status OUT NOCOPY  VARCHAR2)
                             RETURN BINARY_INTEGER IS
   l_table_name Varchar2(30);
   l_flexfield fnd_dflex.dflex_r;
   l_flexinfo  dflex_dr;
   l_contexts  fnd_dflex.contexts_dr;
   l_segments  fnd_dflex.segments_dr;
   l_glbl_segments  fnd_dflex.segments_dr;
   i BINARY_INTEGER;
   j BINARY_INTEGER;
   k BINARY_INTEGER;
   l_found BOOLEAN := FALSE;

   Invalid_Table EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CACHE_CONTEXT_REQ';
--
BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_TABLE_NAME',P_TABLE_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_CONTEXT',P_CONTEXT);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_table_name := UPPER(p_table_name);

-- 2530743 : Commenting this as this Fn./Proc. will be needed for other DFFs too
--  IF l_table_name <> 'WSH_NEW_DELIVERIES' THEN
--   RAISE Invalid_Table;
--  END IF;

  IF g_validate_context.count <> 0 THEN

      -- Check if parameters have already been fetched
      FOR i IN g_validate_context.FIRST..g_validate_context.LAST LOOP
        IF g_validate_context(i).table_name = l_table_name AND g_validate_context(i).context =  NVL(p_context,'GLOBAL') THEN
          l_found := TRUE;
          j := i;
          EXIT;
        END IF;
      END LOOP;

      IF l_found THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN j;
      END IF;

    END IF;

    get_flexfield(appl_short_name => 'WSH',
                  flexfield_name => l_table_name,
                  flexfield => l_flexfield,
                  flexinfo => l_flexinfo);

    fnd_dflex.get_contexts(flexfield  => l_flexfield,
                           contexts => l_contexts);


    fnd_dflex.get_segments(context => fnd_dflex.make_context(flexfield => l_flexfield,
                                                             context_code => p_context),
                           segments => l_segments,
                           enabled_only => TRUE);

    fnd_dflex.get_segments(context => fnd_dflex.make_context(flexfield => l_flexfield,
                                                             context_code => l_contexts.context_code(l_contexts.global_context)),
                           segments => l_glbl_segments,
                           enabled_only => TRUE);

    IF g_validate_context.count = 0 THEN
      j := 1;
      g_validate_context(1).first_segment := 1;

    ELSE
      j := g_validate_context.LAST + 1;
      g_validate_context(j).first_segment := g_validate_context(j-1).last_segment + 1;
    END IF;

    g_validate_context(j).table_name := l_table_name;
    g_validate_context(j).context := NVL(p_context,'GLOBAL');

    k := 0;
    IF NVL(p_context,'GLOBAL') <> 'GLOBAL' THEN
     FOR i IN 1..l_segments.nsegments  LOOP
      IF l_segments.is_required(i) THEN
       k := k + 1;
       g_req_attribute_values(g_validate_context(j).first_segment + k - 1).attribute_index := (to_number(substr(l_segments.application_column_name(i),10)));
       g_req_attribute_values(g_validate_context(j).first_segment + k - 1).segment_value := 'Y';
      END IF;
     END LOOP;
    END IF;

    FOR i IN 1..l_glbl_segments.nsegments  LOOP
     IF l_glbl_segments.is_required(i) THEN
       k := k + 1;
       g_req_attribute_values(g_validate_context(j).first_segment + k - 1).attribute_index := (to_number(substr(l_glbl_segments.application_column_name(i),10)));
       g_req_attribute_values(g_validate_context(j).first_segment + k - 1).segment_value :=  'Y';
     END IF;
    END LOOP;

    g_validate_context(j).last_segment :=  g_validate_context(j).first_segment + k - 1;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN j;

EXCEPTION
 WHEN Invalid_Table THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_TABLE');
         FND_MESSAGE.Set_Token('TABLE', p_table_name);
         WSH_UTIL_CORE.Add_Message(x_return_status);
         --
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_TABLE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_TABLE');
END IF;
--
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN NULL;

 WHEN Others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status);
         WSH_UTIL_CORE.default_handler('WSH_FLEXFIELD_UTILS.Cache_Context_Req');
         --
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN NULL;


END Cache_Context_Req;

PROCEDURE Validate_DFF(
                       p_table_name IN VARCHAR2,
                       p_primary_id IN NUMBER,
         	       x_return_status OUT NOCOPY  VARCHAR2
                      ) IS

   i BINARY_INTEGER;
   j BINARY_INTEGER;
   k BINARY_INTEGER;
   attributes FlexfieldAttributeTabType;
   l_token  VARCHAR2(2000);
   context  VARCHAR2(150);

   Required_Attributes_Empty EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DFF';
--
BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_TABLE_NAME',P_TABLE_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_ID',P_PRIMARY_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  IF (p_table_name = 'WSH_NEW_DELIVERIES') THEN
      l_token := FND_MESSAGE.Get_String('WSH', 'WSH_DELIVERY_DFF_TITLE');
  END IF;

  j :=  Check_DFF_Req(p_table_name => p_table_name,
                      x_return_status => x_return_status);

  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
  END IF;


   IF g_check_req(j).seg_req_flag = 'Y' OR g_check_req(j).context_req_flag = 'Y' THEN


    Read_Table_Attributes(p_table_name => p_table_name,
                          p_primary_id => p_primary_id,
                          p_attributes => attributes,
                          p_context    => context,
                          x_return_status => x_return_status);

    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       return;
    END IF;


    IF context IS NULL THEN
         IF g_check_req(j).context_req_flag = 'Y' THEN
         RAISE Required_Attributes_Empty;
      END IF;
    END IF;

    IF g_check_req(j).seg_req_flag = 'Y' THEN
     k := Cache_Context_Req(p_table_name => p_table_name ,
                            p_context => context,
                            x_return_status => x_return_status);



     FOR i IN g_validate_context(k).first_segment .. g_validate_context(k).last_segment LOOP

         IF attributes(g_req_attribute_values(i).attribute_index) IS NULL THEN
            RAISE Required_Attributes_Empty;
         END IF;
     END LOOP;
    END IF;

   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
    WHEN Required_Attributes_Empty THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         -- IF condition Added for Bug 3118519
         IF ( UPPER(p_table_name) = 'WSH_NEW_DELIVERIES' ) THEN
            FND_MESSAGE.Set_Name('WSH', 'WSH_DFF_ATTRIBUTE_EMPTY');
            FND_MESSAGE.Set_Token('DFF_TITLE', l_token);
            WSH_UTIL_CORE.Add_Message(x_return_status);
         END IF;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'REQUIRED_ATTRIBUTES_EMPTY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:REQUIRED_ATTRIBUTES_EMPTY');
         END IF;
         --
    WHEN Others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status);
         WSH_UTIL_CORE.default_handler('WSH_FLEXFIELD_UTILS.Validate_DFF');
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Validate_DFF;

END WSH_FLEXFIELD_UTILS;

/
