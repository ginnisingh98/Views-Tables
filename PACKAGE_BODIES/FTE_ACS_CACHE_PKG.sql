--------------------------------------------------------
--  DDL for Package Body FTE_ACS_CACHE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_ACS_CACHE_PKG" AS
/* $Header: FTEACSCB.pls 120.5 2005/09/19 05:27:22 alksharm noship $ */

-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:        FTE_ACS_CACHE_PKG                                             --
-- TYPE:        PACKAGE BODY                                                  --
-- DESCRIPTION: Contains core procedures for searching the rule in the cache  --
--              In this package processing is done for a single entity.       --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
--                                                                            --
-- -------------------------------------------------------------------------- --

--
--  Used to get rule data from the database for a particular group id
--
TYPE rules_record_type IS RECORD( rule_id			FTE_SEL_RULE_RESTRICTIONS.rule_id%type,
				  attribute_name		FTE_SEL_RULE_RESTRICTIONS.attribute_name%type,
				  attribute_value_from		FTE_SEL_RULE_RESTRICTIONS.attribute_value_from%type,
				  attribute_value_to		FTE_SEL_RULE_RESTRICTIONS.attribute_value_to%type,
				  attribute_value_from_number	FTE_SEL_RULE_RESTRICTIONS.attribute_value_from_number%type,
				  attribute_value_to_number	FTE_SEL_RULE_RESTRICTIONS.attribute_value_to_number%type,
				  overlap_flag			FTE_SEL_RULE_RESTRICTIONS.range_overlap_flag%type);

TYPE rules_tab_type IS TABLE OF rules_record_type INDEX BY BINARY_INTEGER;

--
--Limit is  a) 'L'  - Lower limit.
--          b) 'U'  - Upper limit
--	    c) 'N'  - Null (Added when range is not there)

TYPE range_match_rule_rec IS RECORD( rule_id		FTE_SEL_RULE_RESTRICTIONS.rule_id%type,
				     overlap_flag	FTE_SEL_RULE_RESTRICTIONS.range_overlap_flag%type,
				     limit		VARCHAR2(1));

TYPE range_match_tab   IS TABLE OF range_match_rule_rec INDEX BY BINARY_INTEGER;

TYPE range_match_cache IS TABLE OF range_match_tab INDEX BY VARCHAR2(32767);

--
-- To be used for FOB and Regions
--

TYPE exact_match_tab   IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE exact_match_cache IS TABLE OF exact_match_tab INDEX BY VARCHAR2(32767);

TYPE priority_tab_type IS TABLE OF NUMBER;

TYPE rule_match_tab    IS TABLE OF NUMBER;

TYPE group_cache_rec   IS RECORD( attribute_tab		wsh_util_core.id_tab_type,
				  priority_tab		priority_tab_type,
				  weight_uom_code	VARCHAR2(30),
				  volume_uom_code	VARCHAR2(30));

TYPE groups_cache_type IS TABLE OF group_cache_rec INDEX BY BINARY_INTEGER;

TYPE from_to_region_cache_type	IS TABLE OF NUMBER INDEX BY VARCHAR2(32767);

--
-- The data structure is used for storing RULE-RESULT association.
-- 1 rule can be associated with multiple results.
-- The results are indexed by rule_id.
--
TYPE result_id_tab	IS TABLE OF NUMBER		INDEX BY BINARY_INTEGER;

TYPE rule_result_tab	IS TABLE OF result_id_tab	INDEX BY BINARY_INTEGER;

--
-- Local data structure for querying the result attributes.
--
TYPE fte_attr_code_val_rec_type IS RECORD( attr_code VARCHAR2(30),
				           attr_val  VARCHAR2(240));

TYPE fte_attr_code_val_tab_type IS TABLE OF fte_attr_code_val_rec_type INDEX BY BINARY_INTEGER;

-- -------------------------------------------------------------------------- --
-- Global Package Constants                                                   --
-- ------------------------                                                   --
--                                                                            --
-- -------------------------------------------------------------------------- --

	--
	G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_ACS_CACHE_PKG';
	--
    g_session_id        NUMBER;
	g_num_absent		NUMBER      := -9999 ;
	g_val_absent		VARCHAR2(25):= 'NULL';
    g_max_cache_size	NUMBER      := 10;
	g_null_tab		WSH_UTIL_CORE.ID_TAB_TYPE;

--
--	2^10 = 2 147 483 648 ,
--      Taking 11 characters in the index
--      g_int_mask is used for Integer Fields, Include Sign always otherwise negative length will be more
--      g__num_mask  is used for decimals
--
--	The three masks are different
--      Valid Combinations are - 1) g_int_mask - g_num_mask
--                               2) g_int_mask - char_mask
--
	g_int_mask		VARCHAR2(12) := 'S00000000000';
	g_num_mask		VARCHAR2(20) := '00000000000D00000000';
    g_lpad_char		VARCHAR2(1)  := '0';
	g_lpad_length		NUMBER       := 25;

	g_low_range_break	VARCHAR2(1)  := 'L';
	g_high_range_break	VARCHAR2(1)  := 'H';
	g_null_range		VARCHAR2(1)  := 'N';
	g_value_present		NUMBER	     := 1;

	g_wt_idx		NUMBER	     := 0;
	g_vol_idx		NUMBER	     := 1;
	g_fr_reg_idx		NUMBER	     := 2;
	g_to_reg_idx		NUMBER	     := 3;
	g_fr_post_idx		NUMBER	     := 4;
	g_to_post_idx		NUMBER	     := 5;
	g_transit_time_idx	NUMBER	     := 6;
	g_fob_code_idx		NUMBER	     := 7;


-- -------------------------------------------------------------------------- --
-- Global Priority Tables                                                     --
-- ------------------------                                                   --
--                                                                            --
-- -------------------------------------------------------------------------- --
	g_to_postal_priority	priority_tab_type;
    g_from_postal_priority	priority_tab_type;
    g_to_region_priority	priority_tab_type;
    g_from_region_priority	priority_tab_type;
    g_all_priority		priority_tab_type;
	g_from_pzone_priority	priority_tab_type;
	g_to_pzone_priority	priority_tab_type;

	g_table_initialized	BOOLEAN	     := FALSE;


-- -------------------------------------------------------------------------- --
-- Global Caches	                                                      --
-- ------------------------                                                   --
--                                                                            --
-- -------------------------------------------------------------------------- --

	--
	--  Global Range Caches Used
	--

	g_weight_cache		range_match_cache;
	g_volume_cache		range_match_cache;
	g_transit_cache		range_match_cache;
	g_from_postal_cache	range_match_cache;
	g_to_postal_cache	range_match_cache;

	--
	--  Global Exact Caches Used
	--

	g_fob_cache		exact_match_cache;

	--
	-- Other caches
	--
	g_groups_cache		groups_cache_type;
	g_from_to_region_cache	from_to_region_cache_type;

	-- Global caches for storing results for a particular rule.
	--
	-- Results are indexed by rule_id
	-- The order in which results are stored in cache is determined by rank or leg sequence
	-- For eg :
	--	 Rank(Index)	        Result
	--	  1			 501
	--	  2  			 509
	--        3 			 513
	--	Leg Destination(Index) Result
	--	 1			 539
	--	 2		         532
	g_rule_result_cache		rule_result_tab;
	g_result_attribute_cache	fte_cs_result_attr_tab;

-- -------------------------------------------------------------------------- --
-- Procedures Definitions		                                      --
-- ------------------------                                                   --
--                                                                            --
-- -------------------------------------------------------------------------- --


--***************************************************************************--
--========================================================================
-- FUNCTION  : get_fixed_key      PRIVATE
--
-- PARAMETERS: p_group_id		Group id
--	       p_from_region_id         From Region Id
--  	       p_to_region_id           To Region Id
--
-- COMMENT   : Returns appended p_group_id, p_from_region_id, p_to_region_id after
--	       formatting them
--
--***************************************************************************--
FUNCTION get_fixed_key ( p_group_id          IN NUMBER,
			 p_from_region_id    IN NUMBER,
			 p_to_region_id      IN NUMBER) RETURN VARCHAR2
IS

    l_key		VARCHAR2(32767);
    l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_fixed_key';

BEGIN

        IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	END IF;

	l_key :=  TO_CHAR(p_group_id,      g_int_mask) || '-' ||
	          TO_CHAR(p_from_region_id,g_int_mask) || '-' ||
		  TO_CHAR(p_to_region_id  ,  g_int_mask);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Fixed Key ',l_key);
          WSH_DEBUG_SV.POP (l_module_name);
	END IF;

	RETURN (l_key);
EXCEPTION

      WHEN others THEN
      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.get_fixed_key');

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_fixed_key;


--***************************************************************************--
--========================================================================
-- FUNCTION  : get_key_for_num      PRIVATE
--
-- PARAMETERS: p_fixed_key		Fixed  Key
--	       p_number			Number key
--
-- COMMENT   : Returns p_fixed_key appended with formated number key
--
--***************************************************************************--
FUNCTION get_key_for_num(  p_fixed_key  IN  VARCHAR2,
			   p_number     IN  NUMBER) RETURN VARCHAR2
IS
     l_key		VARCHAR2(32767);
     l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
     l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_key_for_num';

BEGIN

	IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	END IF;


	l_key  :=    p_fixed_key|| '-' ||
	             TO_CHAR(p_number,g_num_mask);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Number Key ',l_key);
          WSH_DEBUG_SV.POP (l_module_name);
	END IF;

	RETURN l_key;

EXCEPTION
      WHEN others THEN
      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.get_key_for_num');

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_key_for_num;

--***************************************************************************--
--========================================================================
-- FUNCTION  : get_key_for_char         PRIVATE
--
-- PARAMETERS: p_fixed_key		Fixed Key
--	       p_char			Char key
--
-- COMMENT   : Returns p_fixed_key appended with padded p_char key
--
--***************************************************************************--
FUNCTION get_key_for_char(  p_fixed_key  IN VARCHAR2,
                            p_char	 IN VARCHAR2) RETURN VARCHAR2
IS
     l_key		 VARCHAR2(32767);
     l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
     l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_key_for_char';
BEGIN

	IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	END IF;

	l_key :=  p_fixed_key||'-' ||
	          LPAD(p_char,g_lpad_length,g_lpad_char);

	IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Char Key ',l_key);
          WSH_DEBUG_SV.POP (l_module_name);
	END IF;

	RETURN l_key;
EXCEPTION
      WHEN others THEN
      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.get_key_for_char');

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END  get_key_for_char;


--***************************************************************************--
--========================================================================
-- FUNCTION  : get_key_for_null         PRIVATE
--
-- PARAMETERS: p_fixed_key		Fixed Key
--
--
-- COMMENT   : Returns p_fixed_key appended with padded g_val_absent
--
--***************************************************************************--
FUNCTION get_key_for_null(  p_fixed_key	  IN VARCHAR2) RETURN VARCHAR2
IS
     l_key		VARCHAR2(32767);
     l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
     l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_key_for_null';
BEGIN
	IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	END IF;

	l_key := p_fixed_key||'-'||LPAD(g_val_absent,g_lpad_length,g_lpad_char);

	IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'NULL Key',l_key);
          WSH_DEBUG_SV.POP (l_module_name);
	END IF;

	RETURN l_key;
EXCEPTION
      WHEN others THEN
      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.get_key_for_null');
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

END get_key_for_null;

--***************************************************************************--
--========================================================================
-- PROCEDURE : initialize_tables          PRIVATE
--
-- PARAMETERS:  x_return_status		  Return Status
--
-- COMMENT   : The API initializes priority tables .Following is priority list is followed.
--
--PRIORITY ATTRIBUTE TYPE	ATTRIBUTE TYPE		ATTRIBUTE TYPE	ATTRIBUTE TYPE
----------------------------------------------------------------------------------
-- 1.	 TO_POSTAL	TO_REGION/ZONE_ID	FROM_POSTAL	FROM_REGION/ZONE_ID
-- 2.    TO_POSTAL	TO_REGION/ZONE_ID	FROM_POSTAL		-
-- 3.	 TO_POSTAL	TO_REGION_ID		FROM POSTAL ZONE	-
-- 4.	 TO_POSTAL	TO_REGION_ID		FROM_REGION_ID		-
-- 5.	 TO_POSTAL	TO_REGION_ID			-		-
-- 6.    TO_POSTAL		-		FROM_POSTAL	FROM_REGION_ID
-- 7.	 TO POSTAL ZONE	   	-		FROM_POSTAL	FROM_REGION_ID
-- 8.    TO_POSTAL		-		FROM_POSTAL		-
-- 9.	 TO_POSTAL		-		FROM_POSTAL_ZONE	-
-- 10.	 TO POSTAL ZONE	    	-		FROM POSTAL		-
-- 11.	 TO POSTAL ZONE	    	-		FROM POSTAL_ZONE	-
-- 12.   TO_POSTAL		-			-	FROM_REGION_ID
-- 13.   TO POSTAL ZONE		-			-	FROM_REGION_ID
-- 14.   TO_POSTAL		-			-		-
-- 15	 TO POSTAL ZONE	    	-			-		-
-- 16.	 TO_REGION_ID		-		FROM_POSTAL	FROM_REGION_ID
-- 17.   TO_REGION_ID		-		FROM_POSTAL		-
-- 18.	 TO_REGION_ID		-		FROM POSTAL ZONE	-
-- 19.	 TO_REGION_ID		-		FROM_REGION_ID		-
-- 20.	 TO_REGION_ID		-			-		-
-- 21.		-		-		FROM_POSTAL	FROM_REGION_ID
-- 22.		-		-		FROM_POSTAL		-
-- 23.		-		-		FROM POSTAL ZONE	-
-- 24.		-		-		FROM_REGION_ID		-
-- 25.		-		-			-		-
--***************************************************************************--
PROCEDURE initialize_tables (x_return_status OUT NOCOPY VARCHAR2)  IS

l_debug_on     CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'initialize_tables';

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF l_debug_on THEN
	   wsh_debug_sv.push (l_module_name);
        END IF;

	--All the priorites
        g_all_priority		:= priority_tab_type(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25);
	--Priorities where to postal code has to be evaluated.
	g_to_postal_priority	:= priority_tab_type(1,2,3,4,5,6,8,9,12,14);
        --Priorities where from postal code has to be evaluated.
	g_from_postal_priority	:= priority_tab_type(1,2,6,7,8,10,16,17,21,22);
	--Priorities where to region has to be evaluated.
	g_to_region_priority	:= priority_tab_type(1,2,3,4,5,16,17,18,19,20);
        --Priorities where from region has to be evaluated.
	g_from_region_priority	:= priority_tab_type(1,4,6,7,12,13,16,19,21,24);
        --Priorities where to postal zone has to be evaluated.
	g_to_pzone_priority	:= priority_tab_type(7,10,11,13,15);
        --Priorities where from postal zone has to be evaluated
	g_from_pzone_priority	:= priority_tab_type(3,9,11,18,23);

	--Used for NULL representation of region/zone.
	g_null_tab(1) := g_num_absent;

	g_table_initialized	:= TRUE;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.POP(l_module_name);
        END IF;
EXCEPTION
WHEN others THEN
      g_table_initialized := FALSE;
      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.INITIALIZE_TABLES');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END initialize_tables;


--***************************************************************************--
--========================================================================
-- PROCEDURE : Delete_Rule_Caches         PRIVATE
--
-- PARAMETERS: x_return_status		  Return Status
--
-- COMMENT   : Delete all the rule caches
--***************************************************************************--

PROCEDURE delete_rule_caches( x_return_status OUT NOCOPY VARCHAR2)
IS

   l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
   l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'delete_rule_caches';

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
   END IF;

   g_groups_cache.DELETE;
   g_weight_cache.DELETE;
   g_volume_cache.DELETE;
   g_transit_cache.DELETE;
   g_from_postal_cache.DELETE;
   g_to_postal_cache.DELETE;
   g_fob_cache.DELETE;

   IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'CACHES DELETED');
        WSH_DEBUG_SV.POP (l_module_name);
   END IF;

EXCEPTION
      WHEN others THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.DELETE_RULE_CACHES');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END delete_rule_caches;


--========================================================================
-- PROCEDURE :  refresh_cache            PRIVATE
--
-- PARAMETERS: x_return_status           Return Status
-- COMMENT   :
--             Refreshes rules database caches
--             if middletier session (ICX session) is changed
--========================================================================

PROCEDURE refresh_cache (
             x_return_status    OUT  NOCOPY  VARCHAR2 )
IS

    l_session_id        NUMBER  := 0;
    l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'refresh_cache';

BEGIN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
    END IF;
    --

    l_session_id := icx_sec.g_session_id;

    IF l_debug_on THEN
       wsh_debug_sv.logmsg(l_module_name,'g_session_id : '||g_session_id||' Current session id : '||l_session_id);
    END IF;

    IF g_session_id IS NULL OR l_session_id <> g_session_id THEN
       delete_rule_caches(x_return_status => x_return_status);

       g_session_id := l_session_id;

       IF l_debug_on THEN
	   wsh_debug_sv.logmsg(l_module_name,'Rules Cache cleared');
       END IF;

    END IF;

    --
    IF l_debug_on THEN
      wsh_debug_sv.pop (l_module_name);
    END IF;
    --

EXCEPTION
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.refresh_cache');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END refresh_cache;


--***************************************************************************--
--========================================================================
-- PROCEDURE : sort_priority_tab     PRIVATE
--
-- PARAMETERS: p_priority_tab	     Priority tab to be sorted,
--	       x_return_status	     Return Status
--
-- COMMENT   : Sorts the priority table.
--
--***************************************************************************--
PROCEDURE sort_priority_tab(p_priority_tab  IN	OUT NOCOPY PRIORITY_TAB_TYPE,
			    x_return_status OUT NOCOPY	VARCHAR2)
IS

 i			NUMBER;
 j			NUMBER;
 temp			NUMBER;
 more_sort		BOOLEAN := TRUE;

 l_debug_on     CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
 l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'sort_priority_tab';

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF l_debug_on THEN
	     wsh_debug_sv.push (l_module_name);
	END IF;

	IF (p_priority_tab.COUNT<>1) THEN

	   i:= p_priority_tab.FIRST;

	   IF i IS NOT NULL THEN
	      LOOP
		  more_sort := FALSE;
                  j := p_priority_tab.NEXT(i);
		  IF  j is NOT NULL THEN
		     LOOP
			IF (p_priority_tab(j) < p_priority_tab(i)) THEN
			    temp := p_priority_tab(j);
			    p_priority_tab(j) := p_priority_tab(i);
			    p_priority_tab(i) := temp;
			    more_sort := TRUE;
			END IF;

			EXIT when j = p_priority_tab.LAST;
			j:= p_priority_tab.NEXT(j);
 		     END LOOP;
		  END IF;
		  EXIT when NOT(more_sort) OR (i = p_priority_tab.LAST);
		  i:= p_priority_tab.NEXT(i);
	       END LOOP;
	   END IF;

	END IF;

	IF l_debug_on THEN
	        WSH_DEBUG_SV.POP (l_module_name);
	END IF;
EXCEPTION
  WHEN others THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.SORT_PRIORITY_TAB');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END sort_priority_tab;


--***************************************************************************--
--========================================================================
-- PROCEDURE : get_sorted_priority_tab     PRIVATE
--
-- PARAMETERS: p_attribute_tab		Attributes present in the group.
--	       x_priority_tab		Table of priorities that should be validated for group.
--	       x_return_status		Return Status
--
-- COMMENT   : Returns sorted priority tab.
--
--
-- ALGORITHM :
--	       Uses except SET operation to find the priorities that need to be
--	       evaluated. The procees is not an additive process it is a subtractive process.
--             Remove all that need not be evaluated
--***************************************************************************--

PROCEDURE get_sorted_priority_tab( p_attribute_tab      IN	   WSH_UTIL_CORE.ID_TAB_TYPE,
				   x_priority_tab	OUT NOCOPY PRIORITY_TAB_TYPE,
				   x_return_status	OUT NOCOPY VARCHAR2)
IS

 l_sort		BOOLEAN := FALSE;
 l_priority_tab	PRIORITY_TAB_TYPE;

 l_debug_on	CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
 l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'get_sorted_priority_tab';

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF l_debug_on THEN
	     wsh_debug_sv.push (l_module_name);
	END IF;

	l_priority_tab := g_all_priority;

	IF NOT(p_attribute_tab.EXISTS(g_fr_post_idx)) THEN
		l_priority_tab := l_priority_tab MULTISET EXCEPT g_from_postal_priority;
		l_sort := TRUE;
	END IF;

	IF NOT(p_attribute_tab.EXISTS(g_to_post_idx)) THEN
		l_priority_tab := l_priority_tab MULTISET EXCEPT g_to_postal_priority;
		l_sort := TRUE;
	END IF;

        -- We need to remove from pzone also.
	IF NOT(p_attribute_tab.EXISTS(g_fr_reg_idx)) THEN
		l_priority_tab := l_priority_tab MULTISET EXCEPT g_from_region_priority;
		l_priority_tab := l_priority_tab MULTISET EXCEPT g_from_pzone_priority;
		l_sort := TRUE;
	END IF;

	IF NOT(p_attribute_tab.EXISTS(g_to_reg_idx)) THEN
		l_priority_tab := l_priority_tab MULTISET EXCEPT g_to_region_priority;
		l_priority_tab := l_priority_tab MULTISET EXCEPT g_to_pzone_priority;
		l_sort := TRUE;
	END IF;

	-- Results of operations may not be sorted fashion
	-- Sort the priority tab
	-- Writing boolean sort

	IF (l_priority_tab.COUNT<>1 and l_sort ) THEN

		sort_priority_tab( p_priority_tab   => l_priority_tab,
				   x_return_status  => x_return_status);

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		       IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		           raise FND_API.G_EXC_UNEXPECTED_ERROR;
		       END IF;
		END IF;
    	END IF;

	x_priority_tab := l_priority_tab;

	IF l_debug_on THEN
	        WSH_DEBUG_SV.POP (l_module_name);
	END IF;
EXCEPTION
  WHEN others THEN
      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.GET_SORTED_PRIORITY_TAB');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_sorted_priority_tab;


--***************************************************************************--
--========================================================================
-- PROCEDURE : add_group_to_group_cache         PRIVATE
--
-- PARAMETERS: p_group_id		  Group id to be used
--	       x_return_status		  Return Status
--
-- COMMENT   : Adds a group and its attribute to the global cache.
--
--
-- ALGORITHM :
--	      1) Query for all group attributes.
--	      2) Add the group attributes and priority_tab to the cache
--***************************************************************************--
PROCEDURE add_group_to_group_cache( p_group_id      IN  NUMBER,
			            x_return_status OUT NOCOPY VARCHAR2)
IS

--
--Check this query
--
CURSOR c_get_group_attributes IS
SELECT attribute_name,attribute_uom_code
FROM   fte_sel_group_attributes
WHERE  group_id = p_group_id;

itr			NUMBER;

l_attr_tab		FTE_ATTR_CODE_VAL_TAB_TYPE;
l_group_attr		WSH_UTIL_CORE.ID_TAB_TYPE;

l_group_cache_rec	GROUP_CACHE_REC;
l_priority_tab		PRIORITY_TAB_TYPE;
l_priority_str		VARCHAR2(600);

l_debug_on     CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'add_group_to_group_cache';

BEGIN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'Adding group to Group Cache ',p_group_id);
       WSH_DEBUG_SV.logmsg(l_module_name,'Attribtues to be checked ');
    END IF;

    OPEN  c_get_group_attributes;
    FETCH c_get_group_attributes BULK COLLECT INTO l_attr_tab;
    CLOSE c_get_group_attributes;

    itr := l_attr_tab.FIRST;

    IF (itr IS NOT NULL) THEN
	LOOP

	     IF ( l_attr_tab(itr).attr_code = 'WEIGHT') THEN
		l_group_attr(g_wt_idx) := g_value_present;
		l_group_cache_rec.weight_uom_code := l_attr_tab(itr).attr_val;

		IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'Weight');
		END IF;

	     ELSIF (l_attr_tab(itr).attr_code = 'VOLUME') THEN
		l_group_attr(g_vol_idx) := g_value_present;
		l_group_cache_rec.volume_uom_code := l_attr_tab(itr).attr_val;

		IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'Volume');
		END IF;

 	     ELSIF (l_attr_tab(itr).attr_code = 'TRANSIT_TIME') THEN
		l_group_attr(g_transit_time_idx) := g_value_present;

		IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'Transit Time');
		END IF;

	     --
	     -- FTE_SEL_RULE_RESTICTIONS has FROM_REGION_ID
	     -- FTE_SEL_GROUP_ATTRIBUTES has 'FROM_REGION_COUNTRY'
	     --
	     ELSIF (l_attr_tab(itr).attr_code IN ('FROM_REGION_COUNTRY','FROM_REGION_STATE','FROM_REGION_CITY','FROM_ZONE','FROM_REGION')) THEN

		 -- R12 UI enters 'FROM_REGION' for postal codes also.
		l_group_attr(g_fr_reg_idx) := g_value_present;
		IF (l_attr_tab(itr).attr_code = 'FROM_REGION') THEN
			l_group_attr(g_fr_post_idx) := g_value_present;
			IF l_debug_on THEN
			   WSH_DEBUG_SV.logmsg(l_module_name,'From Region Postal Code');
			END IF;
		END IF;

		IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'From Region');
		END IF;

	     --
	     -- FTE_SEL_RULE_RESTRICTIONS has TO_REGION_ID
	     -- FTE_SEL_GROUP_ATTRIBUTES has 'TO_REGION_COUNTRY'
	     --
	     ELSIF (l_attr_tab(itr).attr_code IN ('TO_REGION_COUNTRY','TO_REGION_STATE','TO_REGION_CITY','TO_ZONE','TO_REGION')) THEN
		l_group_attr(g_to_reg_idx) := g_value_present;

	         -- R12 UI enters 'TO_REGION' for postal codes also.
		IF (l_attr_tab(itr).attr_code = 'TO_REGION') THEN
			l_group_attr(g_to_post_idx) := g_value_present;
			IF l_debug_on THEN
			   WSH_DEBUG_SV.logmsg(l_module_name,'To Region Postal Code');
			END IF;
		END IF;

		IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'To Region');
		END IF;

	     -- Prior to R12 , UI stores 'FROM_REGION_POSTAL_CODE' for from postal code.
	     ELSIF (l_attr_tab(itr).attr_code IN('FROM_REGION_POSTAL_CODE')) THEN
		l_group_attr(g_fr_post_idx) := g_value_present;

		IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'From Region Postal Code');
		END IF;

  	     -- Prior to R12 , UI stores  'TO_REGION_POSTAL_CODE' for To postal codes.
	     ELSIF (l_attr_tab(itr).attr_code IN ('TO_REGION_POSTAL_CODE')) THEN
  	        l_group_attr(g_to_post_idx) := g_value_present;

		IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'To Region Postal Code');
		END IF;

	     ELSIF (l_attr_tab(itr).attr_code = 'FOB_CODE') THEN
		l_group_attr(g_fob_code_idx) := g_value_present;

		IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'Fob Code');
		END IF;

	     END IF;

	     EXIT WHEN itr = l_attr_tab.LAST;
	     itr := l_attr_tab.NEXT(itr);
	END LOOP;
    END IF;

    get_sorted_priority_tab( p_attribute_tab   => l_group_attr,
			     x_priority_tab    => l_priority_tab,
			     x_return_status   => x_return_status);

    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    l_group_cache_rec.attribute_tab := l_group_attr;
    l_group_cache_rec.priority_tab  := l_priority_tab;

    g_groups_cache(p_group_id):=l_group_cache_rec;

    IF l_debug_on THEN

	    itr := l_priority_tab.FIRST;
	    l_priority_str := l_priority_tab(itr);

	    IF NOT (itr = l_priority_tab.LAST) THEN
            LOOP
	    	itr := l_priority_tab.NEXT(itr);
		l_priority_str := l_priority_str ||'-'||l_priority_tab(itr);
		EXIT WHEN itr = l_priority_tab.LAST;
            END LOOP;
            END IF;

            WSH_DEBUG_SV.log(l_module_name,'Priorities To be checked',l_priority_str);
            WSH_DEBUG_SV.POP (l_module_name);
    END IF;

EXCEPTION
WHEN OTHERS THEN

      IF c_get_group_attributes%ISOPEN THEN
 	 CLOSE c_get_group_attributes;
      END IF;

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.add_group_to_cache');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END add_group_to_group_cache;


--***************************************************************************--
--========================================================================
-- PROCEDURE : add_to_non_range_cache         PRIVATE
--
-- PARAMETERS: p_cache			  Global cache to be modified
--             p_fixed_key                Key for the attribute value
--	       p_null_key		  Key used if attribute value is null.
--	       p_rule_id	          Rule id to be added
--	       x_return_status		  Return Status
--
-- COMMENT   : Adds a rule to Non Range Cache
--
--
-- ALGORITHM :
--	       1. IF NULL_KEY THEN index is NULL_KEY ELSE index is FIXED_KEY
--	       2. Insert the record at proper index
--***************************************************************************--
PROCEDURE add_to_non_range_cache ( p_cache		IN OUT NOCOPY EXACT_MATCH_CACHE,
			           p_fixed_key		IN VARCHAR2 DEFAULT NULL,
				   p_null_key		IN VARCHAR2 DEFAULT NULL,
				   p_rule_id		IN NUMBER,
				   x_return_status OUT NOCOPY VARCHAR2)
IS

  l_rule_tab 	exact_match_tab;
  l_key		VARCHAR2(32767);

  l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
  l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'add_to_non_range_cache';

BEGIN

     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'p_fixed_key',p_fixed_key);
       WSH_DEBUG_SV.log(l_module_name,'p_null_key ', p_null_key);
       WSH_DEBUG_SV.log(l_module_name,'p_rule_id  ',p_rule_id);
     END IF;

     IF (p_fixed_key IS NOT NULL) THEN
	l_key := p_fixed_key;
     ELSE
	l_key := p_null_key;
     END IF;

     IF (p_cache.EXISTS(l_key)) THEN
	        -- Add new rule to table present
		l_rule_tab := p_cache(l_key);
		l_rule_tab(l_rule_tab.COUNT) := p_rule_id;
     ELSE
	-- Add new table
	l_rule_tab(0) := p_rule_id;
     END IF;

     p_cache(l_key) := l_rule_tab;

     IF l_debug_on THEN
        WSH_DEBUG_SV.POP (l_module_name);
     END IF;

EXCEPTION
WHEN others THEN
      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.ADD_TO_NON_RANGE_CACHE');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
     --
END add_to_non_range_cache;

--***************************************************************************--
--========================================================================
-- PROCEDURE : add_to_range_cache         PRIVATE
--
-- PARAMETERS: p_cache			  Global cache to be modified
--             p_key_low                  Lower range break
--	       p_key_high                 Higher range break
--	       p_null_key		  Key used if attribute value is null.
--	       p_overlap_flag            Indicates whether there is overlap in the range or not
--	       p_rule_id	          Rule id to be added
--	       x_return_status		  Return Status
--
-- COMMENT   : Adds a rule to Range Cache
--
--
-- ALGORITHM :
--	      1. If NULL_KEY then create null_key Records else Low/High Records.
--	      2. Insert the record at proper index
--***************************************************************************--
PROCEDURE add_to_range_cache( p_cache	      IN OUT NOCOPY RANGE_MATCH_CACHE,
			      p_key_low       IN VARCHAR2 DEFAULT NULL,
			      p_key_high      IN VARCHAR2 DEFAULT NULL,
			      p_null_key      IN VARCHAR2 DEFAULT NULL,
			      p_overlap_flag  IN VARCHAR2 DEFAULT 'Y',
			      p_rule_id	      IN NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2)
IS

l_rule_rec_low		range_match_rule_rec;
l_rule_rec_high		range_match_rule_rec;
l_rule_rec_null		range_match_rule_rec;

l_rule_tab_low		range_match_tab;
l_rule_tab_high		range_match_tab;
l_rule_tab_null		range_match_tab;

l_debug_on              CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||G_PKG_NAME ||'.'||'add_to_range_cache';

BEGIN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF l_debug_on THEN

	     WSH_DEBUG_SV.push(l_module_name);
             WSH_DEBUG_SV.log(l_module_name,'p_key_low   ',p_key_low);
             WSH_DEBUG_SV.log(l_module_name,'p_key_high  ',p_key_high);
             WSH_DEBUG_SV.log(l_module_name,'p_null_key  ',p_null_key);
             WSH_DEBUG_SV.log(l_module_name,'p_overlap_flag',p_overlap_flag);
	     WSH_DEBUG_SV.log(l_module_name,'p_rule_id    ',p_rule_id);

        END IF;

	IF (p_null_key IS NULL) THEN

	    --
	    -- Create the records
	    --

	    l_rule_rec_low.rule_id       := p_rule_id;
	    l_rule_rec_low.overlap_flag  := p_overlap_flag;
	    l_rule_rec_low.limit         := g_low_range_break;

	    l_rule_rec_high.rule_id      := p_rule_id;
	    l_rule_rec_high.overlap_flag := p_overlap_flag;
	    l_rule_rec_high.limit        := g_high_range_break;

    	    --
	    -- Add the records to the cache
	    --

	    IF (p_cache.EXISTS(p_key_low)) THEN
		l_rule_tab_low := p_cache(p_key_low);
		l_rule_tab_low(l_rule_tab_low.COUNT) := l_rule_rec_low;
	    ELSE
	 	l_rule_tab_low(0) := l_rule_rec_low;
	    END IF;

	    p_cache(p_key_low) := l_rule_tab_low;

	    IF (p_cache.EXISTS(p_key_high)) THEN
		l_rule_tab_high := p_cache(p_key_high);
		l_rule_tab_high(l_rule_tab_high.COUNT) := l_rule_rec_high;
	    ELSE
		l_rule_tab_high(0) := l_rule_rec_high;
	    END IF;
	    p_cache(p_key_high) := l_rule_tab_high;

	 ELSE

	    l_rule_rec_null.rule_id       := p_rule_id;
	    l_rule_rec_null.overlap_flag  := p_overlap_flag;
	    l_rule_rec_null.limit         := g_null_range;

	    IF (p_cache.EXISTS(p_null_key)) THEN
		l_rule_tab_null := p_cache(p_null_key);
		l_rule_tab_null(l_rule_tab_null.COUNT) := l_rule_rec_null;
   	    ELSE
		l_rule_tab_null(0) := l_rule_rec_null;
	    END IF;

	    p_cache(p_null_key) := l_rule_tab_null;

         END IF;

         IF l_debug_on THEN
            WSH_DEBUG_SV.POP (l_module_name);
         END IF;

EXCEPTION
WHEN others THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.ADD_TO_RANGE_CACHE');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
END add_to_range_cache;


--***************************************************************************--
--========================================================================
-- PROCEDURE : build_cache                PRIVATE
--
-- PARAMETERS: p_group_id		  Group id to be used
--	       x_return_status		  Return Status
--
-- COMMENT   : For a given group id creates the cache.
--
--
-- ALGORITHM :
--	      1, Drop the cache if number of groups is more than the limit.
--	      2. Query for all the rules within a group.
--            3. Check if overlap flag is set for a sample rule.
--                 If flag is not set then call FTE_ACS_RULE_UTIL_PKG.SET_overlap_FLAG
--	      4. For all Rules
--			Get all the attributes for a rule.
--			Put the respective attributes in respective caches.
--
--***************************************************************************--
PROCEDURE build_cache(p_group_id	IN  NUMBER,
		      x_return_status	OUT NOCOPY VARCHAR)

IS

CURSOR  C_GET_RULE_RESTRICTIONS IS
SELECT  rule_id,
        attribute_name,
        attribute_value_From,
        attribute_value_to,
        attribute_value_from_number,
        attribute_value_to_number,
	range_overlap_flag
FROM    fte_sel_rule_restrictions
WHERE   group_id = p_group_id
ORDER BY rule_id;


curr_rule_id        NUMBER;
prev_rule_id	    NUMBER;

from_weight		    NUMBER;
to_weight		    NUMBER;
weight_overlap	    VARCHAR2(1);

from_volume		    NUMBER;
to_volume		    NUMBER;
volume_overlap      VARCHAR2(1);

from_transit_time	NUMBER;
to_transit_time 	NUMBER;
transit_overlap     VARCHAR2(1);

from_region		    NUMBER;
to_region		    NUMBER;

from_postal_low		VARCHAR2(240);
from_postal_high	VARCHAR2(240);
from_postal_overlap	VARCHAR2(1);

to_postal_low		VARCHAR2(240);
to_postal_high		VARCHAR2(240);
to_postal_overlap	VARCHAR2(1);

fob_code		    VARCHAR2(240);

rule_tab		    RULES_TAB_TYPE;

fixed_key		    VARCHAR2(32767);
null_key		    VARCHAR2(32767);
key_low			    VARCHAR2(32767);
key_high		    VARCHAR2(32767);

itr			        NUMBER;
next_itr		    NUMBER;
next_rule_id		NUMBER;

l_group_attr		WSH_UTIL_CORE.ID_TAB_TYPE;

l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'build_cache';

--
--Exceptions
--
FTE_CS_ERROR_INVALID_RANGE  EXCEPTION;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'p_group_id   ',p_group_id);
    END IF;

    refresh_cache(x_return_status);

    -- We will not have greater than, because it means we first add and then drop
    -- the cache.
    IF ( g_groups_cache.COUNT = g_max_cache_size ) THEN
	  DELETE_RULE_CACHES(x_return_status => x_return_status);
    END IF;

    --
    -- Add group to the group cache.
    --
    add_group_to_group_cache( p_group_id      => p_group_id,
   	                      x_return_status => x_return_status);

    l_group_attr:=  g_groups_cache(p_group_id).attribute_tab;


    OPEN  c_get_rule_restrictions;
    FETCH c_get_rule_restrictions BULK COLLECT INTO rule_tab;
    CLOSE c_get_rule_restrictions;

    itr := rule_tab.FIRST;

    IF (itr IS NOT NULL) THEN

	--
	-- overlap flag has to be either 'Y' or 'N'
	--
	IF (rule_tab(itr).overlap_flag IS NULL) THEN

		--
		-- overlap flag needs to be set
		--

		FTE_ACS_RULE_UTIL_PKG.SET_RANGE_OVERLAP_FLAG(p_group_id	 => p_group_id);

		--
		-- Delete Rule Tab and query again.
		--
		rule_tab.DELETE;

		OPEN  c_get_rule_restrictions;
		FETCH c_get_rule_restrictions BULK COLLECT INTO rule_tab;
		CLOSE c_get_rule_restrictions;
		itr := rule_tab.FIRST;
	END IF;
    END IF;


    IF (itr IS NOT NULL) THEN
    LOOP
	 --
	 --Initialize the default Values;
	 --
	 curr_rule_id      := rule_tab(itr).rule_id;
     from_region       := g_num_absent;
  	 to_region         := g_num_absent;
	 from_postal_low   := g_val_absent;
	 from_postal_high  := g_val_absent;
	 to_postal_low     := g_val_absent;
	 to_postal_high    := g_val_absent;
	 from_weight       := g_num_absent;
	 to_weight         := g_num_absent;
	 from_volume       := g_num_absent;
	 to_volume         := g_num_absent;
	 from_transit_time := g_num_absent;
	 to_transit_time   := g_num_absent;
	 fob_code          := g_val_absent;

  	 --
	 -- Get the values for a rule.
	 --
	 LOOP

	    -- For Weight Volume Conversions we use display weight and volume.
	    IF ( rule_tab(itr).attribute_name = 'DISPLAY_WEIGHT') THEN

		 from_weight     := rule_tab(itr).attribute_value_from_number;
		 to_weight       := rule_tab(itr).attribute_value_to_number;
	     weight_overlap  := rule_tab(itr).overlap_flag;

	    ELSIF (rule_tab(itr).attribute_name = 'DISPLAY_VOLUME') THEN

		 from_volume    := rule_tab(itr).attribute_value_from_number;
		 to_volume      := rule_tab(itr).attribute_value_to_number;
         volume_overlap := rule_tab(itr).overlap_flag;

	    ELSIF (rule_tab(itr).attribute_name = 'TRANSIT_TIME') THEN

		 from_transit_time    := rule_tab(itr).attribute_value_from_number;
	     to_transit_time      := rule_tab(itr).attribute_value_to_number;
		 transit_overlap      := rule_tab(itr).overlap_flag;

   	    ELSIF (rule_tab(itr).attribute_name = 'FROM_REGION_POSTAL_CODE') THEN

	 	 from_postal_low	 := rule_tab(itr).attribute_value_from;
    	 from_postal_high := rule_tab(itr).attribute_value_to;

  	    ELSIF (rule_tab(itr).attribute_name = 'TO_REGION_POSTAL_CODE') THEN

	  	 to_postal_low	:= rule_tab(itr).attribute_value_from;
		 to_postal_high := rule_tab(itr).attribute_value_to;

	    ELSIF (rule_tab(itr).attribute_name = 'FROM_REGION_ID') THEN

		 from_region  := rule_tab(itr).attribute_value_from_number;

  	    ELSIF (rule_tab(itr).attribute_name = 'TO_REGION_ID') THEN

	 	 to_region    := rule_tab(itr).attribute_value_from_number;

  	    ELSIF (rule_tab(itr).attribute_name = 'FOB_CODE') THEN

	 	 fob_code     := rule_tab(itr).attribute_value_from;

	    END IF;

	    IF ( itr = rule_tab.LAST ) THEN
	         EXIT;
	    ELSE
	        next_itr     := rule_tab.NEXT(itr);
	        next_rule_id := rule_tab(next_itr).rule_id;
	        EXIT WHEN next_rule_id <> curr_rule_id;
	        itr := next_itr;
	    END IF;

        END LOOP;

	    IF l_debug_on THEN

            WSH_DEBUG_SV.log(l_module_name,' Rule ID           ', curr_rule_id );
            WSH_DEBUG_SV.log(l_module_name,' From_region       ', from_region );
            WSH_DEBUG_SV.log(l_module_name,' To_region         ', to_region);
            WSH_DEBUG_SV.log(l_module_name,' From_postal_low   ', from_postal_low);
            WSH_DEBUG_SV.log(l_module_name,' From_postal_high  ', from_postal_high);
            WSH_DEBUG_SV.log(l_module_name,' To_postal_low     ', to_postal_low);
            WSH_DEBUG_SV.log(l_module_name,' To_postal_high    ', to_postal_high);
            WSH_DEBUG_SV.log(l_module_name,' From_weight       ', from_weight);
            WSH_DEBUG_SV.log(l_module_name,' To_weight         ', to_weight);
            WSH_DEBUG_SV.log(l_module_name,' From_volume       ', from_volume);
            WSH_DEBUG_SV.log(l_module_name,' To_volume         ', to_volume);
            WSH_DEBUG_SV.log(l_module_name,' From_transit_time ', from_transit_time);
            WSH_DEBUG_SV.log(l_module_name,' To_transit_time   ', to_transit_time);
            WSH_DEBUG_SV.log(l_module_name,' Fob_code          ', fob_code);

        END IF;

        fixed_key  := get_fixed_key(p_group_id        => p_group_id,
			                        p_from_region_id  => from_region,
	   			                    p_to_region_id    => to_region);


	    null_key   := get_key_for_null(p_fixed_key    => fixed_key);

        --
        --Register From-To-Region combination in the  From-To-Region-Cache
        --Register using dummy value
        --
        g_from_to_region_cache(fixed_key) := g_value_present;

        --
        -- In range attributes either both from and to will be present
        -- or none will be present
        -- Only add value to the cache if the attribute is present in the group.

 	IF (l_group_attr.EXISTS(g_wt_idx)) THEN

	   IF l_debug_on THEN
 		   WSH_DEBUG_SV.logmsg(l_module_name,'Adding to Weight Cache');
	   END IF;

	   IF (from_weight <> g_num_absent) AND (to_weight <> g_num_absent) THEN

       	    key_low  := get_key_for_num( p_fixed_key => fixed_key,
		  		             p_number    => from_weight);

	        key_high := get_key_for_num( p_fixed_key => fixed_key,
		  		             p_number   => to_weight);


		    add_to_range_cache( p_cache         => g_weight_cache,
				    p_key_low       => key_low,
				    p_key_high      => key_high,
				    p_overlap_flag => weight_overlap,
				    p_rule_id	    => curr_rule_id,
				    x_return_status => x_return_status);

		    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		     IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		         raise FND_API.G_EXC_UNEXPECTED_ERROR;
		     END IF;
	        END IF;

	    ELSIF (from_weight = g_num_absent) AND (to_weight = g_num_absent) THEN


		    add_to_range_cache( p_cache         => g_weight_cache,
		   		    p_null_key      => null_key,
				    p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status);

		    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
		    END IF;
	    ELSE
		    RAISE FTE_CS_ERROR_INVALID_RANGE;
	    END IF;
	END IF;

	IF (l_group_attr.EXISTS(g_vol_idx)) THEN


	  IF l_debug_on THEN
 		   WSH_DEBUG_SV.logmsg(l_module_name,'Adding to Volume Cache');
	  END IF;

	  IF (from_volume <> g_num_absent) AND (to_volume <> g_num_absent) THEN

		key_low  := get_key_for_num( p_fixed_key  => fixed_key,
		 	 		      p_number    => from_volume);

		key_high := get_key_for_num( p_fixed_key => fixed_key,
			 		      p_number   => to_volume);

		add_to_range_cache( p_cache         => g_volume_cache,
				    p_key_low       => key_low,
				    p_key_high      => key_high,
				    p_overlap_flag  => volume_overlap,
				    p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status);

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

           ELSIF (from_volume = g_num_absent) AND (to_volume = g_num_absent) THEN

		add_to_range_cache( p_cache         => g_volume_cache,
		                    p_null_key      => null_key,
			 	    p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status);

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
	  ELSE
		 RAISE FTE_CS_ERROR_INVALID_RANGE;
	  END IF;

	END IF;

	IF (l_group_attr.EXISTS(g_transit_time_idx)) THEN

 	  IF l_debug_on THEN
 		   WSH_DEBUG_SV.logmsg(l_module_name,'Adding to Transit Time Cache');
	  END IF;


	  IF (from_transit_time <> g_num_absent) AND (to_transit_time <> g_num_absent) THEN

		key_low  := get_key_for_num( p_fixed_key => fixed_key,
		 	 		     p_number    => from_transit_time);

		key_high := get_key_for_num( p_fixed_key => fixed_key,
			 		     p_number    => to_transit_time);

		add_to_range_cache( p_cache         => g_transit_cache,
				    p_key_low       => key_low,
				    p_key_high      => key_high,
				    p_overlap_flag  => transit_overlap,
				    p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status );

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

	  ELSIF (from_transit_time = g_num_absent) AND (to_transit_time = g_num_absent) THEN

		add_to_range_cache( p_cache        => g_transit_cache,
		                    p_null_key      => null_key,
				    p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status);

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

	  ELSE
		RAISE FTE_CS_ERROR_INVALID_RANGE;
	  END IF;

	END IF;

	IF (l_group_attr.EXISTS(g_to_post_idx)) THEN

	   IF l_debug_on THEN
 		   WSH_DEBUG_SV.logmsg(l_module_name,'Adding to To Postal Code Cache');
	   END IF;

	   IF (to_postal_low <> g_val_absent) AND (to_postal_high <> g_val_absent) THEN

 		key_low  := get_key_for_char(  p_fixed_key => fixed_key,
			                       p_char      => to_postal_low);

		key_high := get_key_for_char(  p_fixed_key => fixed_key,
			                       p_char      => to_postal_high);


		add_to_range_cache( p_cache         => g_to_postal_cache,
				    p_key_low       => key_low,
				    p_key_high      => key_high,
				    p_overlap_flag  => to_postal_overlap,
	       			    p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status );

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

	  ELSIF (to_postal_low = g_val_absent) AND (to_postal_high = g_val_absent) THEN

		add_to_range_cache( p_cache         => g_to_postal_cache,
				    p_null_key      => null_key,
	 		            p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status);

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

	  --
	  -- In case of postal code one limit can be null
          --

	  ELSIF (to_postal_low = g_val_absent) AND (to_postal_high <> g_val_absent) THEN

		IF l_debug_on THEN
 		   WSH_DEBUG_SV.logmsg(l_module_name,'Lower postal code is NULL');
		END IF;

		key_high := get_key_for_char(  p_fixed_key => fixed_key,
 					       p_char      => to_postal_high);

		add_to_range_cache( p_cache         => g_to_postal_cache,
				    p_key_low       => key_high,
				    p_key_high      => key_high,
				    p_overlap_flag  => to_postal_overlap,
	       			    p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status );

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

	  ELSE

		IF l_debug_on THEN
 		   WSH_DEBUG_SV.logmsg(l_module_name,'Upper postal code is NULL');
		END IF;

		key_low := get_key_for_char(  p_fixed_key => fixed_key,
 					      p_char      => to_postal_low);

		add_to_range_cache( p_cache         => g_to_postal_cache,
				    p_key_low       => key_low,
				    p_key_high      => key_low,
				    p_overlap_flag  => to_postal_overlap,
	       			    p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status );

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
	    END IF;
	END IF;

	IF (l_group_attr.EXISTS(g_fr_post_idx)) THEN

 	    IF l_debug_on THEN
 		   WSH_DEBUG_SV.logmsg(l_module_name,'Adding to From Postal Code Cache');
    	    END IF;

	    IF (from_postal_low <> g_val_absent) AND (from_postal_high <> g_val_absent) THEN

		key_low  := get_key_for_char(  p_fixed_key => fixed_key,
			                       p_char      => from_postal_low);

		key_high := get_key_for_char(  p_fixed_key => fixed_key,
 					       p_char      => from_postal_high);

		add_to_range_cache( p_cache         => g_from_postal_cache,
				    p_key_low       => key_low,
				    p_key_high      => key_high,
				    p_overlap_flag  => from_postal_overlap,
	       			    p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status );

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

	    ELSIF (from_postal_low = g_val_absent) AND (from_postal_high = g_val_absent) THEN

	        IF l_debug_on THEN
 		   WSH_DEBUG_SV.logmsg(l_module_name,'Both from and to Postal Codes are NULL');
		END IF;

		add_to_range_cache( p_cache         => g_from_postal_cache,
		 		    p_null_key      => null_key,
				    p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status);

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

	    ELSIF (from_postal_low = g_val_absent) AND (from_postal_high <> g_val_absent) THEN

		IF l_debug_on THEN
 		   WSH_DEBUG_SV.logmsg(l_module_name,'Lower postal code is NULL');
		END IF;

		key_high := get_key_for_char(  p_fixed_key => fixed_key,
 					       p_char      => from_postal_high);

		add_to_range_cache( p_cache         => g_from_postal_cache,
				    p_key_low       => key_high,
				    p_key_high      => key_high,
				    p_overlap_flag  => from_postal_overlap,
	       			    p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status );

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

	    ELSE

		IF l_debug_on THEN
 		   WSH_DEBUG_SV.logmsg(l_module_name,'Upper postal code is NULL');
		END IF;

		key_low := get_key_for_char(  p_fixed_key => fixed_key,
 					      p_char      => from_postal_low);

		add_to_range_cache( p_cache         => g_from_postal_cache,
				    p_key_low       => key_low,
				    p_key_high      => key_low,
				    p_overlap_flag  => from_postal_overlap,
	       			    p_rule_id       => curr_rule_id,
				    x_return_status => x_return_status );

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

	    END IF;

	END IF;

	IF (l_group_attr.EXISTS(g_fob_code_idx)) THEN

            IF l_debug_on THEN
 		   WSH_DEBUG_SV.logmsg(l_module_name,'Adding to FOB Cache');
   	    END IF;

	    IF ( fob_code <> g_val_absent) THEN

		key_low  := get_key_for_char(  p_fixed_key => fixed_key,
			                       p_char      => fob_code);

		add_to_non_range_cache( p_cache         => g_fob_cache,
	  			        p_fixed_key     => key_low,
	       			        p_rule_id       => curr_rule_id,
				        x_return_status => x_return_status );

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

	    ELSE
		add_to_non_range_cache( p_cache         => g_fob_cache,
			 	        p_null_key      => null_key,
 					p_rule_id       => curr_rule_id,
				        x_return_status => x_return_status);

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
	    END IF;
	END IF;

	EXIT WHEN itr = rule_tab.LAST;
        itr := rule_tab.NEXT(itr);
   END LOOP;

   IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	   raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.POP (l_module_name);
   END IF;

EXCEPTION
    WHEN FTE_CS_ERROR_INVALID_RANGE THEN

      IF c_get_rule_restrictions%ISOPEN THEN
         CLOSE c_get_rule_restrictions;
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'Attribute Range has either FROM or TO Only (Range is Invalid');
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF c_get_rule_restrictions%ISOPEN THEN
         CLOSE c_get_rule_restrictions;
      END IF;

      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

    WHEN others THEN

      IF c_get_rule_restrictions%ISOPEN THEN
         CLOSE c_get_rule_restrictions;
      END IF;

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.ADD_TO_RANGE_CACHE');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

END build_cache;


--***************************************************************************--
--========================================================================
-- PROCEDURE  : search_exact_cache_for_null     PRIVATE
--
-- PARAMETERS:  p_cache			EXACT_MATCH_CACHE to be searched
--	        p_fixed_key		Fixed key to be used.
--		x_result_tab		Matching Rules.
--		x_return_status		Return Status
--
-- COMMENT   : This API returns all the rules which have null as matching attributes
--
--***************************************************************************--
PROCEDURE search_exact_cache_for_null(	p_cache			IN		EXACT_MATCH_CACHE,
					p_fixed_key		IN		VARCHAR2,
					x_result_tab		OUT NOCOPY 	rule_match_tab,
					x_return_status		OUT NOCOPY	VARCHAR2)
IS
	l_null_key	VARCHAR2(32767);
	l_rule_tab      exact_match_tab;
	itr		NUMBER;

	l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'search_exact_cache_for_null';

BEGIN

	IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_null_key := get_key_for_null ( p_fixed_key) ;

	IF (p_cache.EXISTS(l_null_key)) THEN
		l_rule_tab := p_cache(l_null_key);
		itr := l_rule_tab.FIRST;

		IF (itr IS NOT NULL) THEN
		  LOOP
			IF (x_result_tab IS NULL) THEN
			    x_result_tab:= rule_match_tab(l_rule_tab(itr));
			ELSE
			    x_result_tab.EXTEND;
			    x_result_tab(x_result_tab.COUNT):= l_rule_tab(itr);
			END IF;
			EXIT WHEN itr = l_rule_tab.LAST;
			itr := l_rule_tab.NEXT(itr);
		  END LOOP;
		END IF;
	END IF;

	IF l_debug_on THEN
                  WSH_DEBUG_SV.POP (l_module_name);
	END IF;

EXCEPTION
      WHEN others THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.search_exact_cache_for_null');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END search_exact_cache_for_null;


--***************************************************************************--
--========================================================================
-- PROCEDURE  : search_range_cache_for_null     PRIVATE
--
-- PARAMETERS:  p_cache			RANGE_MATCH_CACHE to be searched
--	        p_fixed_key		Fixed key to be used.
--		x_result_tab		Matching Rules (This will be a non index by variable)
--		x_return_status		Return Status
--
-- COMMENT   : This API returns all the rules which have null as matching attributes
--
--***************************************************************************--
PROCEDURE search_range_cache_for_null( p_cache		IN		RANGE_MATCH_CACHE,
				       p_fixed_key	IN		VARCHAR2,
				       x_result_tab	OUT NOCOPY 	rule_match_tab,
				       x_return_status	OUT NOCOPY	VARCHAR2)
IS

	l_null_key	VARCHAR2(32767);
	l_rule_tab      range_match_tab;
	itr		NUMBER;

	l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'search_range_cache_for_null';

BEGIN

	IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_null_key := get_key_for_null(p_fixed_key);

	IF (p_cache.EXISTS(l_null_key)) THEN

		l_rule_tab := p_cache(l_null_key);

		itr := l_rule_tab.FIRST;

		IF (itr IS NOT NULL) THEN
		  LOOP
			-- Type casting needs to be done.
			IF (x_result_tab IS NULL) THEN

			    x_result_tab:= rule_match_tab(l_rule_tab(itr).rule_id);

			ELSE
			    x_result_tab.EXTEND;
			    x_result_tab(x_result_tab.COUNT):= l_rule_tab(itr).rule_id;

			END IF;
			EXIT WHEN itr = l_rule_tab.LAST;
			itr := l_rule_tab.NEXT(itr);
		  END LOOP;
		END IF;
	END IF;

	IF l_debug_on THEN
           WSH_DEBUG_SV.POP (l_module_name);
	END IF;

EXCEPTION
WHEN others THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.search_range_cache_for_null');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END search_range_cache_for_null;


--***************************************************************************--
--========================================================================
-- PROCEDURE  : get_higher_breaks     PRIVATE
--
-- PARAMETERS:  p_cache			Range Cache to be searched
--		p_start_idx		Starting index for search.
--	        p_fixed_key		Fixed key to be used.
--		p_null_key		Null key.
--		x_rule_tab		Rules having higher breaks.
--		x_return_status		Return Status
--
-- COMMENT   : This API returns all the rules with have upper range break  more
--	       than the attribute value.
--***************************************************************************--
PROCEDURE get_higher_breaks( p_cache		IN	RANGE_MATCH_CACHE,
			     p_start_idx	IN	VARCHAR2,
			     p_fixed_key	IN	VARCHAR2,
			     p_null_key		IN	VARCHAR2,
			     x_rule_tab		OUT NOCOPY RULE_MATCH_TAB,
			     x_return_status    OUT NOCOPY VARCHAR2)
IS
	l_curr_idx	VARCHAR2(32767);
	l_rule_tab	range_match_tab;
	itr		NUMBER;
	l_debug_on      CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'GET_HIGHER_BREAKS';
BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF l_debug_on THEN
 	   wsh_debug_sv.push(l_module_name);
	END IF;

	l_curr_idx := p_cache.NEXT(p_start_idx);

	--
	-- All the rules to be searched should have the same fixed key.
	-- Null key attributes should not be considered.
	--

	WHILE (l_curr_idx IS NOT NULL AND l_curr_idx <> p_null_key AND INSTR(l_curr_idx,p_fixed_key,1,1) = 1)
	LOOP

	     l_rule_tab := p_cache(l_curr_idx);
	     itr := l_rule_tab.FIRST;

	     IF (itr IS NOT NULL) THEN
		LOOP
		IF (l_rule_tab(itr).limit=g_high_range_break) THEN

		     IF (x_rule_tab IS NULL) THEN
		 	 x_rule_tab := rule_match_tab(l_rule_tab(itr).rule_id);
		     ELSE
			 x_rule_tab.EXTEND;
			 x_rule_tab(x_rule_tab.COUNT) := l_rule_tab(itr).rule_id;
		     END IF;
		END IF;

		EXIT WHEN itr = l_rule_tab.LAST;
		itr := l_rule_tab.NEXT(itr);
		END LOOP;

	      END IF;

	      l_curr_idx := p_cache.NEXT(l_curr_idx);
	 END LOOP;

	 IF l_debug_on THEN
             WSH_DEBUG_SV.POP(l_module_name);
	 END IF;

EXCEPTION
WHEN others THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.get_higher_breaks');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_higher_breaks;


--***************************************************************************--
--========================================================================
-- PROCEDURE  : get_lower_breaks     PRIVATE
--
-- PARAMETERS:  p_cache			Range Cache to be searched
--		p_start_idx		Starting index for search.
--	        p_fixed_key		Fixed key to be used.
--		p_null_key		Null key.
--		x_rule_tab		Rules with lower breaks.
--		x_return_status		Return Status
--
-- COMMENT   : This API returns all the rules with have lower break less
--	       than the attribute value.
--
--***************************************************************************--
PROCEDURE get_lower_breaks( p_cache		IN	   RANGE_MATCH_CACHE,
			    p_start_idx		IN	   VARCHAR2,
			    p_null_key		IN	   VARCHAR2,
			    p_fixed_key		IN	   VARCHAR2,
			    x_rule_tab		OUT NOCOPY RULE_MATCH_TAB,
			    x_return_status	OUT NOCOPY VARCHAR2)
IS

  l_curr_idx	VARCHAR2(32767);
  l_rule_tab	range_match_tab;
  itr		NUMBER;

  l_debug_on     CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
  l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'GET_LOWER_BREAKS';

BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF l_debug_on THEN
 	   wsh_debug_sv.push (l_module_name);
	END IF;

	l_curr_idx := p_cache.PRIOR(p_start_idx);

	WHILE (l_curr_idx IS NOT NULL AND l_curr_idx <> p_null_key AND INSTR(l_curr_idx,p_fixed_key,1,1) = 1)
	LOOP
	     l_rule_tab := p_cache(l_curr_idx);
	     itr := l_rule_tab.FIRST;

	     IF (itr IS NOT NULL) THEN
 	     LOOP

		IF (l_rule_tab(itr).limit=g_low_range_break) THEN
		     IF (x_rule_tab IS NULL) THEN
			 x_rule_tab := rule_match_tab(l_rule_tab(itr).rule_id);
		     ELSE
			 x_rule_tab.EXTEND;
			 x_rule_tab(x_rule_tab.COUNT) := l_rule_tab(itr).rule_id;
		     END IF;
		END IF;

		EXIT WHEN itr = l_rule_tab.LAST;
		itr := l_rule_tab.NEXT(itr);
		END LOOP;
	     END IF;

	     -- Check this condition.
	     l_curr_idx := p_cache.PRIOR(l_curr_idx);
	END LOOP;

        IF l_debug_on THEN
            WSH_DEBUG_SV.POP (l_module_name);
	END IF;
EXCEPTION
WHEN others THEN
      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.get_lower_breaks');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

END get_lower_breaks;

--***************************************************************************--
--========================================================================
-- PROCEDURE  : search_exact_cache     PRIVATE
--
-- PARAMETERS:  p_cache			Exact Cache to be searched
--	        p_fixed_key		Fixed key to be used.
--		p_attribute		Attribute value
--		p_search_null		This flag determines whether
--					NULL values should be searched or not
--		x_result_tab		Matching Rules
--		x_return_status		Return Status
--
-- COMMENT   : This API returns all the rules which exactly match the attribute
--
--***************************************************************************--
PROCEDURE search_exact_cache(	p_cache			IN		EXACT_MATCH_CACHE,
				p_fixed_key		IN		VARCHAR2,
				p_attribute_key		IN		VARCHAR2,
				p_search_null		IN		BOOLEAN,
				x_result_tab		OUT NOCOPY 	rule_match_tab,
				x_return_status		OUT NOCOPY	VARCHAR2)

IS
	l_rule_tab	 EXACT_MATCH_TAB;
	itr		 NUMBER;

	l_debug_on       CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name    CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'search_exact_cache';
BEGIN

	IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (p_search_null) THEN

		search_exact_cache_for_null( p_cache	    => p_cache,
					     p_fixed_key    => p_fixed_key,
					     x_result_tab   => x_result_tab,
					     x_return_status=> x_return_status);

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
	END IF;

	IF (p_cache.EXISTS(p_attribute_key)) THEN
	      l_rule_tab := p_cache(p_attribute_key);
	      itr := l_rule_tab.FIRST;
	      IF (itr is NOT NULL) THEN
	         LOOP
			IF (x_result_tab IS NULL) THEN
			       x_result_tab:= rule_match_tab(l_rule_tab(itr));
			ELSE
			       x_result_tab.EXTEND;
			       x_result_tab(x_result_tab.COUNT) :=l_rule_tab(itr);
			END IF;
			EXIT when itr = l_rule_tab.LAST;
			itr := l_rule_tab.NEXT(itr);
		 END LOOP;
	      END IF;
	 END IF;

	 IF l_debug_on THEN
            WSH_DEBUG_SV.POP (l_module_name);
	 END IF;

EXCEPTION
WHEN others THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.search_exact_cache');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END search_exact_cache;

--***************************************************************************--
--========================================================================
-- PROCEDURE  : search_range_cache     PRIVATE
--
-- PARAMETERS:  p_cache			Range Cache to be searched
--	        p_fixed_key		Fixed key to be used.
--		p_attribute		Attribute value
--		p_search_null		This flag determines whether
--					NULL values should be searched or not
--		x_result_tab		Matching Rules
--		x_return_status		Return Status
--
-- COMMENT   : This API returns all the rules which match the attribute in the range
--	       cache.
--***************************************************************************--
PROCEDURE search_range_cache(  p_cache			IN		RANGE_MATCH_CACHE,
			       p_fixed_key		IN		VARCHAR2,
			       p_attribute_key		IN		VARCHAR2,
			       p_match_upper_limit	IN		BOOLEAN,
			       p_search_null		IN		BOOLEAN,
			       x_result_tab		OUT NOCOPY 	rule_match_tab,
			       x_return_status		OUT NOCOPY	VARCHAR2)
IS

	check_overlap	        BOOLEAN := FALSE;

	l_prev_idx		VARCHAR2(32767);
	l_next_idx		VARCHAR2(32767);
    l_unique_rule   BOOLEAN;
    l_rule_id       FTE_SEL_RULE_RESTRICTIONS.rule_id%type;
	l_rule_tab		range_match_tab;
	l_prev_tab		range_match_tab;
	l_next_tab		range_match_tab;
	l_prev_rec		range_match_rule_rec;
	l_next_rec		range_match_rule_rec;

	itr			NUMBER;
    results_itr NUMBER;
	l_null_key		VARCHAR2(32767);

	lower_breaks		rule_match_tab;
	higher_breaks		rule_match_tab;
	match_rules		rule_match_tab;

	l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'search_range_cache';

BEGIN

	IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_unique_rule := true;
	IF (p_search_null) THEN

	     search_range_cache_for_null( p_cache	=> p_cache,
	  			          p_fixed_key	=> p_fixed_key,
					  x_result_tab	=> x_result_tab,
					  x_return_status=> x_return_status);

	     --Done with search range cache for null

	     IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		   raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	     END IF;
	END IF;

	--
	-- Checking the exact match. The exact match. In case of rules we have
	-- Range defined >= and <
	-- In case of exact match we should check for only >= . ie lower range.
	--
	-- For postal codes and transit time the range is defined as <= .
	-- In case of .EXISTS we should check for higher range break.
	--

	IF (p_cache.EXISTS(p_attribute_key)) THEN
	      l_rule_tab := p_cache(p_attribute_key);
	      itr := l_rule_tab.FIRST;

	      IF (itr is NOT NULL) THEN
	        LOOP
			IF (l_rule_tab(itr).limit = g_low_range_break)  OR
			   (l_rule_tab(itr).limit = g_high_range_break AND p_match_upper_limit)
			THEN
                l_rule_id := l_rule_tab(itr).rule_id;
				IF (x_result_tab IS NULL) THEN
                    x_result_tab:= rule_match_tab(l_rule_id);
				ELSE
                    results_itr := x_result_tab.FIRST;
                    IF results_itr IS NOT NULL THEN
                       LOOP
                            IF x_result_tab(results_itr) = l_rule_id THEN
                                l_unique_rule := false;
                                EXIT;
                            END IF;
                            EXIT WHEN results_itr = x_result_tab.LAST;
                            results_itr := x_result_tab.NEXT(results_itr);
                       END LOOP;
                    END IF;
                    IF l_unique_rule THEN
                        x_result_tab.EXTEND;
                        x_result_tab(x_result_tab.COUNT) :=l_rule_tab(itr).rule_id;
                    END IF;
				END IF;
				--
				--Even if for 1 record in table overlap flag is 'Y'.
				--We need to check for overlaps
			        IF (l_rule_tab(itr).overlap_flag = 'Y') THEN
					check_overlap:= TRUE;
				END IF;
			END IF;
			EXIT when itr = l_rule_tab.LAST;
			itr := l_rule_tab.NEXT(itr);
		    END LOOP;

		    --
		    -- If we are here,then above code has been executed atleast once.
		    -- If check overlap flag is FALSE,we can return.
		    -- Attributes exists and none of them has overlap.
		    --

		    IF (NOT check_overlap) THEN

			IF l_debug_on THEN
			   WSH_DEBUG_SV.POP (l_module_name);
			END IF;
			RETURN;

		    END IF;
	      END IF;
	END IF;

	l_prev_idx :=  p_cache.prior(p_attribute_key);
	l_next_idx :=  p_cache.next(p_attribute_key);
	l_null_key :=  get_key_for_null(p_fixed_key) ;

	--
	-- Previous and Next Index will be null
	--

	IF  l_prev_idx IS NULL OR  l_next_idx IS NULL
	   OR (INSTR(l_prev_idx,p_fixed_key,1,1) <> 1) OR  (l_prev_idx = l_null_key)
	   OR (INSTR(l_next_idx,p_fixed_key,1,1) <> 1) OR (l_next_idx = l_null_key)
	THEN
		IF l_debug_on THEN
		   WSH_DEBUG_SV.POP (l_module_name);
		END IF;
		RETURN;
	END IF;


        --
	-- Get the previous and next tabs, We are sure that both of them are valid.
	--  a) Null entries will not be made
	--  b) The indexes are valid.
	--
	-- Here handle the likely case when
	--  a) The prev tab has 1 record.
	--  b) Next tab has 1 record.
	--  c) Both are closed and overlap flag is 'N'
	--     If such a case is found return back.

	l_prev_tab  :=  p_cache(l_prev_idx);
	l_next_tab  :=  p_cache(l_next_idx);

	IF (l_prev_tab.COUNT = 1) AND (l_next_tab.COUNT = 1) THEN

		l_prev_rec := l_prev_tab(l_prev_tab.FIRST);
		l_next_rec := l_next_tab(l_next_tab.FIRST);

		IF (l_prev_rec.rule_id = l_next_rec.rule_id) AND
		   (l_prev_rec.limit = g_low_range_break) AND
		   (l_next_rec.limit = g_high_range_break) THEN

				IF (x_result_tab IS NULL) THEN
				    x_result_tab:= rule_match_tab(l_prev_rec.rule_id);
				ELSE
				    x_result_tab.EXTEND;
				    x_result_tab(x_result_tab.COUNT):=l_prev_rec.rule_id;
				END IF;

				--
				-- If overlap flag at the next rec and the previous record is
				-- 'N' we can exit.
				--

				IF (l_prev_rec.overlap_flag='N' AND l_next_rec.overlap_flag = 'N') THEN
				  IF l_debug_on THEN
				     WSH_DEBUG_SV.POP (l_module_name);
				  END IF;
				  RETURN;
				END IF;
		END IF;
	 END IF;
	 --
	 -- If we reach here then it means that match has not been found or overlap flag is Y;
	 --
	 --
	 -- Algorithm here is -
	 --	1. Get all previous rules with limit = L
	 --     2. Get all next rules with limit = U.
	 --     3. Take intersection of rules returned in above tables.
	 --     4. All the rules returned have to be sent back.
	 --
	 get_lower_breaks( p_cache		=> p_cache,
			   p_start_idx		=> p_attribute_key,
			   p_fixed_key		=> p_fixed_key,
			   p_null_key		=> l_null_key,
			   x_rule_tab		=> lower_breaks,
			   x_return_status	=> x_return_status);

 	 IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		   raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	 END IF;

	 IF (lower_breaks IS NULL) THEN
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.POP (l_module_name);
		 END IF;
		 RETURN;
	 END IF;

	 get_higher_breaks( p_cache		=> p_cache,
			   p_start_idx		=> p_attribute_key,
			   p_fixed_key		=> p_fixed_key,
			   p_null_key		=> l_null_key,
			   x_rule_tab		=> higher_breaks,
			   x_return_status	=> x_return_status);

	 IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		   raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	 END IF;

	 IF (higher_breaks IS NULL) THEN
		IF l_debug_on THEN
		     WSH_DEBUG_SV.POP (l_module_name);
		END IF;
		RETURN;
	 END IF;

 	 match_rules := lower_breaks MULTISET INTERSECT higher_breaks;

	 IF (match_rules IS NOT NULL) THEN

		IF (x_result_tab IS NULL ) THEN
		     x_result_tab := match_rules;
		ELSE
		     x_result_tab := x_result_tab MULTISET UNION DISTINCT match_rules;
	 	END IF;
	 END IF;

	 IF l_debug_on THEN
            WSH_DEBUG_SV.POP (l_module_name);
	 END IF;

EXCEPTION
WHEN others THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.search_range_cache');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END search_range_cache;

--***************************************************************************--
--========================================================================
-- PROCEDURE  : get_all_rules_in_cache     PRIVATE
--
-- PARAMETERS:  p_cache			Range Cache to be searched
--		x_result_tab		Matching Rules
--		x_return_status		Return Status
--
-- COMMENT   : This API returns all the rules which match the attribute in the range
--	       cache.
--***************************************************************************--
PROCEDURE get_all_rules_in_cache(  p_cache			IN		RANGE_MATCH_CACHE,
			       x_result_tab		OUT NOCOPY 	rule_match_tab,
			       x_return_status		OUT NOCOPY	VARCHAR2)
IS

	l_rule_tab		range_match_tab;
	itr			    NUMBER;
    l_rule_tab_itr  VARCHAR2(32767);
	match_rules		rule_match_tab;

	l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_all_rules_in_cache';

BEGIN

	IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    l_rule_tab_itr := p_cache.FIRST;

    IF p_cache.FIRST IS NOT NULL THEN
        LOOP
            l_rule_tab := p_cache(l_rule_tab_itr);
            itr := l_rule_tab.FIRST;

            IF (itr is NOT NULL) THEN
                LOOP
                    IF (x_result_tab IS NULL) THEN
                        x_result_tab:= rule_match_tab(l_rule_tab(itr).rule_id);
                    ELSE
                        x_result_tab.EXTEND;
                        x_result_tab(x_result_tab.COUNT) :=l_rule_tab(itr).rule_id;
                    END IF;

                    EXIT when itr = l_rule_tab.LAST;
                    itr := l_rule_tab.NEXT(itr);
                END LOOP;
            END IF;

            EXIT when l_rule_tab_itr = p_cache.LAST;
            l_rule_tab_itr := p_cache.NEXT(l_rule_tab_itr);

        END LOOP;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.POP (l_module_name);
    END IF;

EXCEPTION
WHEN others THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.get_all_rules_in_cache');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_all_rules_in_cache;

--***************************************************************************--
--========================================================================
-- PROCEDURE  : search_min_high_transit_time     PRIVATE
--
-- PARAMETERS:  p_result_tab		Rules to be evaluated to find the rule with minimum
--					high transit time.
--		x_rule_id		Rule with minimum maximum transit time
--		x_return_status		Return Status
--
-- COMMENT   : This API returns the rule with the minimum high transit time from
--	       a given set of rules
--
--***************************************************************************--
PROCEDURE search_min_high_transit_time( p_result_tab	IN		RULE_MATCH_TAB,
					x_rule_id	OUT NOCOPY	NUMBER,
					x_return_status	OUT NOCOPY	VARCHAR2)
IS
	l_rule_str	 VARCHAR2(4000);
	sql_string	 VARCHAR2(4000);
	itr		 NUMBER;

	l_debug_on       CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name    CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'search_min_high_transit_time';

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	itr := p_result_tab.FIRST;

	IF (itr IS NOT NULL) THEN
		LOOP
			IF (l_rule_str IS NULL) THEN
				l_rule_str   := TO_CHAR(p_result_tab(itr));
			ELSE
				l_rule_str   := l_rule_str ||','||TO_CHAR(p_result_tab(itr));
			END IF;

			EXIT WHEN itr = p_result_tab.LAST;
			itr := p_result_tab.NEXT(itr);
		END LOOP;
	END IF;

	sql_string := 'SELECT rule_id FROM '
              || ' (SELECT rule_id'
		      || ' FROM FTE_SEL_RULE_RESTRICTIONS '
		      || ' WHERE attribute_name=''TRANSIT_TIME'' '--AND ROWNUM=1'
		      || ' AND rule_id IN ('
		      || l_rule_str
		      || ')'
		      || ' ORDER BY attribute_value_to_number)'
              || ' WHERE ROWNUM=1';

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Rule String is '||l_rule_str);
		WSH_DEBUG_SV.logmsg(l_module_name,'SQL String is  '||sql_string);
	END IF;

	EXECUTE IMMEDIATE sql_string INTO x_rule_id;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Rule Id is '||x_rule_id);
	      wsh_debug_sv.pop(l_module_name);
	END IF;

EXCEPTION
WHEN others THEN
      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.search_min_high_transit_time');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
END search_min_high_transit_time;


--***************************************************************************--
--========================================================================
-- PROCEDURE  : find_rule_for_key       PRIVATE
--
-- PARAMETERS:  p_fixed_key		Fixed key to be used for search
--					Group_id-FromRegion-ToRegion Combination
--
--		p_group_id	        Group id
--		p_from_postal_flag	From postal flag is true,if from postal code
--					has to be searched
--		p_to_postal_flag	To postal flag is true , if to postal code has to
--					be searched.
--		p_from_postal_code	From postal code of the entity.
--		p_to_postal_code	To postal code of the entity
--		p_weight		Weight of the entity.
--		p_volume		Volume of the entity.
--		p_transit_time		Transit time associated with the entity
--		p_fob_code		FOB code
--		x_rule_id		Matching rule id.
--		x_return_status		Return status
--
-- COMMENT   : The API finds the rule that matches the attributes.
--             g_rule_not_found is returned if no match is found.
--***************************************************************************--
PROCEDURE find_rule_for_key(	p_fixed_key		IN 		VARCHAR2,
				p_group_id		IN		NUMBER,
				p_from_postal_flag	IN 		BOOLEAN,
				p_to_postal_flag	IN		BOOLEAN,
				p_from_postal_code	IN		VARCHAR2,
				p_to_postal_code	IN		VARCHAR2,
				p_weight		IN		NUMBER,
				p_volume		IN		NUMBER,
				p_transit_time		IN		NUMBER,
				p_fob_code		IN		VARCHAR2,
				x_rule_id		OUT NOCOPY	NUMBER,
				x_return_status		OUT NOCOPY	VARCHAR2)
IS


	CURSOR c_get_group_name IS
	SELECT name
	FROM   FTE_SEL_GROUPS
	WHERE  group_id = p_group_id;

	l_result_set		RULE_MATCH_TAB ;
	l_temp_set		RULE_MATCH_TAB ;
	l_attribute_tab		WSH_UTIL_CORE.ID_TAB_TYPE;
	l_attribute_key		VARCHAR2(32767);
	itr			NUMBER;

	l_group_name		VARCHAR2(32767);

 	l_debug_on      CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'FIND_RULE_FOR_KEY';

	OVERLAPPING_RULES_EXIST	EXCEPTION;
BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF l_debug_on THEN
 	   wsh_debug_sv.push(l_module_name);
	END IF;

	x_rule_id := g_rule_not_found;

	l_attribute_tab	  := g_groups_cache(p_group_id).attribute_tab;
	--
	--  Method     : Even if attribute is null,we need to get all the rules where the attribute is null.
	--  Exceptions : Postal codes.In postal codes we need to check whether they are present or not.
	--               Check for postal codes as Null has been taken care of before.
	--
        IF (l_attribute_tab.EXISTS(g_fob_code_idx)) THEN

	     IF (p_fob_code IS NOT NULL) THEN

		--
		--Compare with the old engine.
		--

		IF l_debug_on THEN
 		   wsh_debug_sv.logmsg(l_module_name,'Searching FOB (Not null) ');
		END IF;


		l_attribute_key := get_key_for_char(  p_fixed_key => p_fixed_key ,
						      p_char	  => p_fob_code);

		search_exact_cache( p_cache		=> g_fob_cache,
				    p_fixed_key		=> p_fixed_key,
				    p_attribute_key	=> l_attribute_key,
				    p_search_null	=> TRUE,
				    x_result_tab	=> l_temp_set,
				    x_return_status	=> x_return_status);

		    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			        raise FND_API.G_EXC_UNEXPECTED_ERROR;
		    	END IF;
		    END IF;
	     ELSE

            IF l_debug_on THEN
     		   wsh_debug_sv.logmsg(l_module_name,'Searching FOB (Null) ');
	    	END IF;

		    search_exact_cache_for_null( p_cache		=> g_fob_cache,
					     p_fixed_key	=> p_fixed_key,
					     x_result_tab	=> l_temp_set,
					     x_return_status	=> x_return_status);

		    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			         raise FND_API.G_EXC_UNEXPECTED_ERROR;
			    END IF;
		    END IF;
	    END IF;

	    IF l_debug_on THEN
 		   IF l_temp_set IS NOT NULL THEN
			itr := l_temp_set.FIRST;
			LOOP
			   wsh_debug_sv.log(l_module_name,'Temp Set Rule Matched',l_temp_set(itr));
			   EXIT WHEN itr = l_temp_set.LAST;
			   itr := l_temp_set.NEXT(itr);
			END LOOP;
		   END IF;
	     END IF;

	     IF (l_temp_set IS NULL) THEN
		--No valid rule found
		IF l_debug_on THEN
 			wsh_debug_sv.pop(l_module_name);
		END IF;
		RETURN;
	     ELSE
		-- This is the first attribute. Here no need to use intersect.
		l_result_set := l_temp_set;
	     END IF;

	     IF l_debug_on THEN
 		   IF l_result_set IS NOT NULL THEN
			itr := l_result_set.FIRST;
			LOOP
			   wsh_debug_sv.log(l_module_name,'Result Set Rule Matched',l_result_set(itr));
			   EXIT WHEN itr = l_result_set.LAST;
			   itr := l_result_set.NEXT(itr);
			END LOOP;
		   END IF;
	     END IF;

	END IF; -- IF (l_attribute_tab.EXISTS(g_fob_code_idx)) THEN

	--
	-- Only if weight exists in the group,we will be searching in the
	-- cache.
	--
	IF (l_attribute_tab.EXISTS(g_wt_idx)) THEN

		IF (p_weight IS NOT NULL) THEN


			IF l_debug_on THEN
	 		   wsh_debug_sv.logmsg(l_module_name,'Searching Weight (Not Null) ');
			END IF;

			l_attribute_key := get_key_for_num( p_fixed_key => p_fixed_key ,
							    p_number	=> p_weight);

			search_range_cache( p_cache		=> g_weight_cache,
					    p_fixed_key		=> p_fixed_key,
					    p_attribute_key	=> l_attribute_key,
					    p_search_null	=> TRUE,
					    p_match_upper_limit => FALSE,
					    x_result_tab	=> l_temp_set,
					    x_return_status	=> x_return_status);

			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
				IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				   raise FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

		ELSE

			IF l_debug_on THEN
	 		   wsh_debug_sv.logmsg(l_module_name,'Searching Weight (Null) ');
			END IF;

			search_range_cache_for_null( p_cache		=> g_weight_cache,
						     p_fixed_key	=> p_fixed_key,
						     x_result_tab	=> l_temp_set,
						     x_return_status	=> x_return_status);

			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
				IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				   raise FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

		END IF;

		IF l_debug_on THEN
 		   IF l_temp_set IS NOT NULL THEN
			itr := l_temp_set.FIRST;
			LOOP
			   wsh_debug_sv.log(l_module_name,'Temp Set Rule Matched',l_temp_set(itr));
			   EXIT WHEN itr = l_temp_set.LAST;
			   itr := l_temp_set.NEXT(itr);
			END LOOP;
		   END IF;
	    END IF;

		IF (l_temp_set IS NULL) THEN
			-- No valid rule is found.
			IF l_debug_on THEN
 				wsh_debug_sv.pop(l_module_name);
			END IF;
			RETURN;
		ELSE
			IF (l_result_set IS NULL) THEN
				l_result_set := l_temp_set;
			ELSE
				l_result_set := l_result_set MULTISET INTERSECT l_temp_set;

				IF (l_result_set.COUNT = 0) THEN
				     IF l_debug_on THEN
					wsh_debug_sv.pop(l_module_name);
				     END IF;
				     RETURN;
				END IF;
			END IF;
		END IF;

		IF l_debug_on THEN
 		   IF l_result_set IS NOT NULL THEN
			itr := l_result_set.FIRST;
			LOOP
			   wsh_debug_sv.log(l_module_name,'Result Set Rule Matched',l_result_set(itr));
			   EXIT WHEN itr = l_result_set.LAST;
			   itr := l_result_set.NEXT(itr);
			END LOOP;
		   END IF;
	         END IF;

        END IF; -- IF (l_attribute_tab.EXISTS(g_wt_idx)) THEN

	--
        -- Only if volume exists in the group we will be searching for it.
        --
        IF (l_attribute_tab.EXISTS(g_vol_idx)) THEN

	       IF (p_volume IS NOT NULL) THEN

			IF l_debug_on THEN
	 		   wsh_debug_sv.logmsg(l_module_name,'Searching Volume (Not Null) ');
			END IF;

			l_attribute_key := get_key_for_num( p_fixed_key => p_fixed_key ,
							    p_number	=> p_volume);

			search_range_cache( p_cache		=> g_volume_cache,
					    p_fixed_key		=> p_fixed_key,
					    p_attribute_key	=> l_attribute_key,
					    p_match_upper_limit => FALSE,
					    p_search_null	=> TRUE,
					    x_result_tab	=> l_temp_set,
					    x_return_status	=> x_return_status);

			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
				IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				   raise FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;
	       ELSE

			IF l_debug_on THEN
	 		   wsh_debug_sv.logmsg(l_module_name,'Searching Volume (Null) ');
			END IF;

			search_range_cache_for_null( p_cache		=> g_volume_cache,
						     p_fixed_key	=> p_fixed_key,
						     x_result_tab	=> l_temp_set,
						     x_return_status	=> x_return_status);

			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
				IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				   raise FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;
	       END IF;

	       IF l_debug_on THEN
 		   IF l_temp_set IS NOT NULL THEN
			itr := l_temp_set.FIRST;
			LOOP
			   wsh_debug_sv.log(l_module_name,'Temp Set Rule Matched',l_temp_set(itr));
			   EXIT WHEN itr = l_temp_set.LAST;
			   itr := l_temp_set.NEXT(itr);
			END LOOP;
		   END IF;
	       END IF;

	       IF (l_temp_set IS NULL) THEN
			-- No valid rule is found.
			IF l_debug_on THEN
				wsh_debug_sv.pop(l_module_name);
			END IF;
			RETURN;
	       ELSE
			IF (l_result_set IS NULL) THEN
				l_result_set := l_temp_set;
			ELSE
				l_result_set := l_result_set MULTISET INTERSECT l_temp_set;

				IF (l_result_set.COUNT = 0 ) THEN
					IF l_debug_on THEN
						wsh_debug_sv.pop(l_module_name);
					END IF;
					RETURN;
				END IF;
			END IF;
	       END IF;

	       IF l_debug_on THEN
 		   IF l_result_set IS NOT NULL THEN
			itr := l_result_set.FIRST;
			LOOP
			   wsh_debug_sv.log(l_module_name,'Result Set Rule Matched',l_result_set(itr));
			   EXIT WHEN itr = l_result_set.LAST;
			   itr := l_result_set.NEXT(itr);
			END LOOP;
		   END IF;
	         END IF;

	END IF; -- IF (l_attribute_tab.EXISTS(g_vol_idx)) THEN

	IF (l_attribute_tab.EXISTS(g_fr_post_idx)) THEN

		IF (p_from_postal_flag) AND (p_from_postal_code IS NOT NULL) THEN
   		--
		-- Do not search for NULL postal codes as that is handled in a
		-- different priority.
		--
			IF l_debug_on THEN
	 		   wsh_debug_sv.logmsg(l_module_name,'Searching From Postal Code ');
			END IF;


			l_attribute_key := get_key_for_char( p_fixed_key => p_fixed_key,
							     p_char	 => p_from_postal_code);

			search_range_cache(  p_cache		=> g_from_postal_cache,
					     p_fixed_key	=> p_fixed_key,
					     p_attribute_key	=> l_attribute_key,
	  				     p_match_upper_limit=> TRUE,
					     p_search_null	=> FALSE,
					     x_result_tab	=> l_temp_set,
					     x_return_status	=> x_return_status);

			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				  raise FND_API.G_EXC_UNEXPECTED_ERROR;
			    END IF;
			END IF;

		ELSE
		--
		-- If postal code is null or flag is false then we will search the
		-- cache only for null values.
		--

			IF l_debug_on THEN
	 		   wsh_debug_sv.logmsg(l_module_name,'Searching From Postal Code(null) ');
			END IF;


			search_range_cache_for_null(p_cache	=> g_from_postal_cache,
					     p_fixed_key	=> p_fixed_key,
					     x_result_tab	=> l_temp_set,
					     x_return_status	=> x_return_status);

			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				  raise FND_API.G_EXC_UNEXPECTED_ERROR;
			    END IF;
			END IF;
		END IF;

		IF l_debug_on THEN
 		   IF l_temp_set IS NOT NULL THEN
			itr := l_temp_set.FIRST;
			LOOP
			   wsh_debug_sv.log(l_module_name,'Temp Set Rule Matched',l_temp_set(itr));
			   EXIT WHEN itr = l_temp_set.LAST;
			   itr := l_temp_set.NEXT(itr);
			END LOOP;
		   END IF;
	        END IF;
		--
		-- If no valid result set is retrieved we return back.
		--
		IF (l_temp_set IS NULL) THEN
			--No valid rule found
			IF l_debug_on THEN
 				wsh_debug_sv.pop (l_module_name);
			END IF;
			RETURN;
		ELSE
			IF (l_result_set IS NULL) THEN
			   l_result_set := l_temp_set;
			ELSE

			   l_result_set := l_result_set MULTISET INTERSECT l_temp_set;
			   IF (l_result_set.COUNT=0) THEN
			      IF l_debug_on THEN
	 			wsh_debug_sv.pop (l_module_name);
		 	      END IF;
			      RETURN;
			   END IF;
			END IF;
		END IF;

		IF l_debug_on THEN
 		   IF l_result_set IS NOT NULL THEN
			itr := l_result_set.FIRST;
			LOOP
			   wsh_debug_sv.log(l_module_name,'Result Set Rule Matched',l_result_set(itr));
			   EXIT WHEN itr = l_result_set.LAST;
			   itr := l_result_set.NEXT(itr);
			END LOOP;
		   END IF;
	         END IF;

	 END IF;

	 --
	 --Checking for to postal Code
	 --
	 IF (l_attribute_tab.EXISTS(g_to_post_idx)) THEN

		 IF (p_to_postal_flag) AND (p_to_postal_code IS NOT NULL) THEN

			IF l_debug_on THEN
	 		   wsh_debug_sv.logmsg(l_module_name,'Searching to Postal Code ');
			END IF;


			--
			-- Do not search for NULL postal codes as that is handled in a
			-- different priority.
			--
			l_attribute_key := get_key_for_char( p_fixed_key => p_fixed_key,
							     p_char	 => p_to_postal_code);

			search_range_cache(p_cache	=> g_to_postal_cache,
				     p_fixed_key	=> p_fixed_key,
				     p_attribute_key	=> l_attribute_key,
	  			     p_match_upper_limit=> TRUE,
				     p_search_null	=> FALSE,
				     x_result_tab	=> l_temp_set,
				     x_return_status	=> x_return_status);

			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				  raise FND_API.G_EXC_UNEXPECTED_ERROR;
			    END IF;
			END IF;
		 ELSE
			--
			-- If postal code is null or flag is false then we will search the
			-- cache only for null values.
			--
			IF l_debug_on THEN
	 		   wsh_debug_sv.logmsg(l_module_name,'Searching to Postal Code(null) ');
			END IF;

			search_range_cache_for_null( p_cache	=> g_to_postal_cache,
					     p_fixed_key	=> p_fixed_key,
					     x_result_tab	=> l_temp_set,
					     x_return_status	=> x_return_status);

			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				  raise FND_API.G_EXC_UNEXPECTED_ERROR;
			    END IF;
			END IF;
		END IF;

		IF l_debug_on THEN
 		   IF l_temp_set IS NOT NULL THEN
			itr := l_temp_set.FIRST;
			LOOP
			   wsh_debug_sv.log(l_module_name,'Temp Set Rule Matched',l_temp_set(itr));
			   EXIT WHEN itr = l_temp_set.LAST;
			   itr := l_temp_set.NEXT(itr);
			END LOOP;
		   END IF;
	        END IF;
		 --
		 -- If no valid result set is retrieved we return back.
		 --
		 IF (l_temp_set IS NULL) THEN
			--No valid rule found
			IF l_debug_on THEN
 				wsh_debug_sv.pop (l_module_name);
			END IF;
			RETURN;
		 ELSE

			IF (l_result_set IS NULL) THEN
			   l_result_set := l_temp_set;
			ELSE
			   l_result_set := l_result_set MULTISET INTERSECT l_temp_set;
			   IF (l_result_set.COUNT = 0) THEN
			      IF l_debug_on THEN
	 			wsh_debug_sv.pop (l_module_name);
	 		      END IF;
			      RETURN;
			   END IF;
			END IF;
		 END IF;

		 IF l_debug_on THEN
 		   IF l_result_set IS NOT NULL THEN
			itr := l_result_set.FIRST;
			LOOP
			   wsh_debug_sv.log(l_module_name,'Result Set Rule Matched',l_result_set(itr));
			   EXIT WHEN itr = l_result_set.LAST;
			   itr := l_result_set.NEXT(itr);
			END LOOP;
		   END IF;
	         END IF;

	 END IF;
	 --
	 --  Search for transit time:
	 --  If transit time is 0, null or less than 1, get the rule which has
	 --  the minimum maximum transit time.
	 --
	 IF (l_attribute_tab.EXISTS(g_transit_time_idx)) THEN

		IF (p_transit_time IS NOT NULL AND (p_transit_time >= 1)) THEN


			IF l_debug_on THEN
	 		   wsh_debug_sv.logmsg(l_module_name,'Searching Transit Time (Not Null)');
			END IF;

			l_attribute_key := get_key_for_num(  p_fixed_key => p_fixed_key,
							     p_number    => p_transit_time);

		        -- When we store 0-4, in database it actually stores (0-5).
			-- Upper range break should be taken as < instead of <=.

			search_range_cache( p_cache		=> g_transit_cache,
					    p_fixed_key		=> p_fixed_key,
					    p_attribute_key	=> l_attribute_key,
					    -- Upper limit will NOT be seached
					    p_match_upper_limit => FALSE,
					    p_search_null	=> TRUE,
					    x_result_tab	=> l_temp_set,
					    x_return_status	=> x_return_status);


			IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				  raise FND_API.G_EXC_UNEXPECTED_ERROR;
			    END IF;
			END IF;

			IF l_debug_on THEN
	 		   IF l_temp_set IS NOT NULL THEN
			   itr := l_temp_set.FIRST;
			   LOOP
			       wsh_debug_sv.log(l_module_name,'Temp Set Rule Matched',l_temp_set(itr));
			       EXIT WHEN itr = l_temp_set.LAST;
			       itr := l_temp_set.NEXT(itr);
 			   END LOOP;
			   END IF;
		        END IF;

			IF (l_temp_set IS NULL) THEN
				-- No valid rule is found.
				IF l_debug_on THEN
		 		   wsh_debug_sv.pop (l_module_name);
				END IF;
				RETURN;
			ELSE
				IF (l_result_set IS NULL) THEN
					l_result_set := l_temp_set;
				ELSE
					l_result_set := l_result_set MULTISET INTERSECT l_temp_set;
					IF (l_result_set.COUNT = 0 ) THEN
						IF l_debug_on THEN
		 				   wsh_debug_sv.pop (l_module_name);
						END IF;
						RETURN;
					END IF;
				END IF;
			END IF;

			IF l_debug_on THEN
	 		   IF l_result_set IS NOT NULL THEN
				itr := l_result_set.FIRST;
				LOOP
				   wsh_debug_sv.log(l_module_name,'Result Set Rule Matched',l_result_set(itr));
				   EXIT WHEN itr = l_result_set.LAST;
				   itr := l_result_set.NEXT(itr);
				END LOOP;
			   END IF;
		        END IF;
		ELSE
            IF (l_result_set IS NULL) THEN
                get_all_rules_in_cache(p_cache		=> g_transit_cache,
                x_result_tab	=> l_result_set,
                x_return_status	=> x_return_status);
            END IF;

			IF (l_result_set IS NOT NULL AND l_result_set.COUNT>1) THEN
				--
				-- In all the selected rules, find the rule that has minimum maximum transit time
				-- (If only 1 rule then do nothing)
				--

				IF l_debug_on THEN
		 		   wsh_debug_sv.logmsg(l_module_name,'Searching min high transit time ');
				END IF;

				search_min_high_Transit_Time( p_result_tab	=> l_result_set,
							      x_rule_id		=> x_rule_id,
							      x_return_status	=> x_return_status);

				IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
				    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
					  raise FND_API.G_EXC_UNEXPECTED_ERROR;
				    END IF;
				END IF;

				IF l_debug_on THEN
		 			wsh_debug_sv.pop (l_module_name);
				END IF;
				RETURN;
			END IF;
		END IF;
	END IF;

	--
	--if result_set is NOT NULL then get the value
	--

	IF (l_result_set IS NOT NULL) THEN

		IF (l_result_set.COUNT=1) THEN
			x_rule_id := l_result_set(l_result_set.FIRST);
		ELSE
			RAISE OVERLAPPING_RULES_EXIST;
		END IF;
	END IF;

EXCEPTION

WHEN OVERLAPPING_RULES_EXIST THEN

	OPEN  c_get_group_name;
	FETCH c_get_group_name INTO l_group_name;
	CLOSE c_get_group_name;

	FND_MESSAGE.SET_NAME('FTE','FTE_POSTAL_CODE_OVERLAP');
	FND_MESSAGE.SET_TOKEN('RULE_NAME',l_group_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.add_message(x_return_status);

	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_module_name,'Overlapping Rules Exist for Group'||l_group_name);
	   WSH_DEBUG_SV.pop(l_module_name);
        END IF;

WHEN others THEN
      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.find_rule_for_key');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

END find_rule_for_key;


--***************************************************************************--
--========================================================================
-- PROCEDURE : get_matching_rule            PRIVATE
--
-- PARAMETERS: p_info		          Attributes of the entity to be searched for
--	       x_rule_id		  Matching Rule
--	       x_return_status		  Return Status
--
-- COMMENT   : The API returns the rule which matches attribute values passed in p_info.
--	       If no rule is found matching it returns  g_rule_not_found
--
--***************************************************************************--
PROCEDURE get_matching_rule(  p_info		IN  FTE_ACS_CACHE_PKG.fte_cs_entity_attr_rec,
			      x_rule_id		OUT NOCOPY NUMBER,
			      x_return_status	OUT NOCOPY VARCHAR2)

IS

l_group_cache_rec		GROUP_CACHE_REC;
l_attribute_tab			WSH_UTIL_CORE.ID_TAB_TYPE;
l_priority_tab			PRIORITY_TAB_TYPE;

from_pregion_tab		WSH_UTIL_CORE.ID_TAB_TYPE;
from_all_region_tab		WSH_UTIL_CORE.ID_TAB_TYPE;
from_postal_zone_tab		WSH_UTIL_CORE.ID_TAB_TYPE;


to_pregion_tab			WSH_UTIL_CORE.ID_TAB_TYPE;
to_all_region_tab		WSH_UTIL_CORE.ID_TAB_TYPE;
to_postal_zone_tab		WSH_UTIL_CORE.ID_TAB_TYPE;

from_postal_code		WSH_LOCATIONS.POSTAL_CODE%TYPE;
to_postal_code			WSH_LOCATIONS.POSTAL_CODE%TYPE;

p_itr				NUMBER;
priority			NUMBER;

l_fixed_key			VARCHAR2(32767);

from_tab			WSH_UTIL_CORE.ID_TAB_TYPE;
to_tab				WSH_UTIL_CORE.ID_TAB_TYPE;
from_postal_flag		BOOLEAN;
to_postal_flag			BOOLEAN;

from_itr			NUMBER;
to_itr				NUMBER;

from_region			NUMBER;
to_region			NUMBER;

l_sort_flag			BOOLEAN := FALSE;

l_rule_id			NUMBER;
l_weight_val			NUMBER;
l_volume_val			NUMBER;

l_return_status			VARCHAR2(1);

FTE_CS_WGHT_CONV_ERR		EXCEPTION;
FTE_CS_VOL_CONV_ERR		EXCEPTION;

l_debug_on     CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'get_matching_rule';


BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF l_debug_on THEN
	   wsh_debug_sv.push (l_module_name);
	   WSH_DEBUG_SV.log(l_module_name,'Group Id     ',p_info.group_id);
	   WSH_DEBUG_SV.log(l_module_name,'Delivery Id  ',p_info.delivery_id);
	   WSH_DEBUG_SV.log(l_module_name,'Trip Id      ',p_info.trip_id);
	   WSH_DEBUG_SV.log(l_module_name,'Weight       ',p_info.weight);
	   WSH_DEBUG_SV.log(l_module_name,'Weight UOM   ',p_info.weight_uom_code);
   	   WSH_DEBUG_SV.log(l_module_name,'Volume       ',p_info.volume);
	   WSH_DEBUG_SV.log(l_module_name,'Volume UOM   ',p_info.volume_uom_code);
	   WSH_DEBUG_SV.log(l_module_name,'Transit Time ',p_info.transit_time);
	   WSH_DEBUG_SV.log(l_module_name,'Ship From Id ',p_info.ship_from_location_id);
   	   WSH_DEBUG_SV.log(l_module_name,'Ship To Id   ',p_info.ship_to_location_id);
	   WSH_DEBUG_SV.log(l_module_name,'Fob Code     ',p_info.fob_code);
	END IF;

	IF NOT (g_table_initialized) THEN

        initialize_tables(x_return_status => l_return_status);

		IF l_debug_on THEN
		      WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
	        END IF;

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
	END IF;

	IF NOT(g_groups_cache.EXISTS(p_info.group_id)) THEN

		build_cache( p_group_id      => p_info.group_id,
			     x_return_status => l_return_status);

		IF l_debug_on THEN
		      WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
	        END IF;

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

	END IF;

	l_group_cache_rec := g_groups_cache(p_info.group_id);

	l_attribute_tab	  := l_group_cache_rec.attribute_tab;
	l_priority_tab    := l_group_cache_rec.priority_tab;

	--
	-- Do weight-volume Conversions;
	--
	IF (l_attribute_tab.EXISTS(g_wt_idx)) THEN
		-- Change weight
		IF (l_group_cache_rec.weight_uom_code <> p_info.weight_uom_code) THEN

			 IF l_debug_on THEN
			        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_ACS_RULE_UTIL_PKG.CONV_TO_BASE_UOM');
		         END IF;
			  --
		         l_weight_val:=FTE_ACS_RULE_UTIL_PKG.CONV_TO_BASE_UOM(p_input_value => p_info.weight,
                                                        p_from_uom    => p_info.weight_uom_code,
                                                        p_to_uom      => l_group_cache_rec.weight_uom_code);

			 IF (l_weight_val < 0 ) THEN
				  RAISE FTE_CS_WGHT_CONV_ERR;
			 END IF;
		ELSE
			l_weight_val :=  p_info.weight;
		END IF;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Weight  '||l_weight_val||'Weight UOM '||l_group_cache_rec.weight_uom_code);
		END IF;

	END IF;



	IF (l_attribute_tab.EXISTS(g_vol_idx)) THEN
		-- Change volume
		IF (l_group_cache_rec.volume_uom_code <> p_info.volume_uom_code) THEN

			 IF l_debug_on THEN
			        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_ACS_RULE_UTIL_PKG.CONV_TO_BASE_UOM');
		         END IF;
			  --
		         l_volume_val:=FTE_ACS_RULE_UTIL_PKG.CONV_TO_BASE_UOM(p_input_value => p_info.volume,
									      p_from_uom    => p_info.volume_uom_code,
					                                      p_to_uom      => l_group_cache_rec.volume_uom_code);

			 IF (l_volume_val < 0 ) THEN
				  RAISE FTE_CS_VOL_CONV_ERR;
			 END IF;
		ELSE
			l_volume_val :=  p_info.volume;
		END IF;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Volume '||l_volume_val||'Volume UOM '||l_group_cache_rec.volume_uom_code);
		END IF;
	END IF;

	IF (l_attribute_tab.EXISTS(g_fr_reg_idx)) THEN

	      -- We encapsulate region type 3 as
	      -- pregion(Region type 2,1,0) + postal code

	        FTE_ACS_RULE_UTIL_PKG.get_formated_regions(
				  p_location_id		=> p_info.ship_from_location_id,
				  x_region_tab		=> from_pregion_tab,
			          x_all_region_tab	=> from_all_region_tab,
				  x_postal_zone_tab	=> from_postal_zone_tab,
				  x_return_status	=> l_return_status);

		IF l_debug_on THEN
		      WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
	        END IF;

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
		--
		-- Depending on results obtained above we can remove certain priorities from the list.
		-- There is always a possibility that the location is not associated with some regions.

		IF (from_all_region_tab.count = 0 ) THEN

			IF l_debug_on THEN
			   WSH_DEBUG_SV.logmsg(l_module_name,'No From Region Associated with the entity');
			END IF;

			l_priority_tab		  := l_priority_tab MULTISET EXCEPT g_from_region_priority;
			l_sort_flag		  := TRUE;

		END IF;

		--
		-- IF (from_pregion_tab.count=0) is NOT NEEDED here.We will check it after checking postal codes.
		-- Above check is not needed because because all the regions of type 2,1,0 are already present
		-- in from_all_region_tab.
		--
		-- Following can never happen
		--  a) Location is associated to a zones and not to a region
		--  b) Location is associated to a region of type 3 and not to a region of type 0
		--

		IF (from_postal_zone_tab.count = 0) THEN

			IF l_debug_on THEN
			   WSH_DEBUG_SV.logmsg(l_module_name,'No From Postal Zone Associated with the entity');
			END IF;

			l_priority_tab := l_priority_tab MULTISET EXCEPT g_from_pzone_priority;
			l_sort_flag    := TRUE;
		END IF;
	END IF;


	IF (l_attribute_tab.EXISTS(g_to_reg_idx)) THEN

	        FTE_ACS_RULE_UTIL_PKG.get_formated_regions(
				  p_location_id		=> p_info.ship_to_location_id,
				  x_region_tab		=> to_pregion_tab,
			          x_all_region_tab	=> to_all_region_tab,
				  x_postal_zone_tab	=> to_postal_zone_tab,
				  x_return_status	=> l_return_status);

		IF l_debug_on THEN
		      WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
	        END IF;

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

		--
		-- Depending on results obtained above we can remove certain priorities from the list.
		-- There is always a possibility that the location is not associated with some regions.
		--

		IF (to_all_region_tab.count = 0 ) THEN

			IF l_debug_on THEN
			   WSH_DEBUG_SV.logmsg(l_module_name,'No To Region Associated with the entity');
			END IF;
			l_priority_tab		  := l_priority_tab MULTISET EXCEPT g_to_region_priority;
			l_sort_flag		  := TRUE;
		END IF;

		IF (to_postal_zone_tab.count = 0) THEN

			IF l_debug_on THEN
			   WSH_DEBUG_SV.logmsg(l_module_name,'No To Postal Zone Associated with the entity');
			END IF;
			l_priority_tab := l_priority_tab MULTISET EXCEPT g_to_pzone_priority;
			l_sort_flag    := TRUE;
		END IF;
	END IF;


	IF (l_attribute_tab.EXISTS(g_fr_post_idx)) THEN

	       FTE_ACS_RULE_UTIL_PKG.get_postal_code(p_location_id   => p_info.ship_from_location_id,
			 x_postal_code   => from_postal_code,
			 x_return_status => l_return_status);

		IF l_debug_on THEN
		      WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
	        END IF;

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

		    --
		    -- We cannot remove postal codes from the prioirity logic here.
		    -- If postal code is null then we will search only the null cache.
		    -- If postal code is present then we will search the cache without null.
		    -- The case of prioirty checking with and without postal codes has been taken
		    -- care in  priority logic.
		    --
		    -- Input has   	Group		What to do		How do we handle
		    -- Postal code	Attribute
		    --   Yes		Yes		Search			None of the priorites are removed.
		    --   Yes		No		Do not search		Priorities are removed
		    --    No		Yes		Search for null match	If parameter is null then check only for null cache.
		    --    No.		No		Do not search		The priority will be removed.
		    --
	END IF;


	IF (l_attribute_tab.EXISTS(g_to_post_idx)) THEN

	   FTE_ACS_RULE_UTIL_PKG.get_postal_code(p_location_id   => p_info.ship_to_location_id,
			    x_postal_code   => to_postal_code,
			    x_return_status => l_return_status);

	    IF l_debug_on THEN
	         WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
	    END IF;

	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		   raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	    END IF;
	END IF;

	IF (l_priority_tab.COUNT <> 1 and l_sort_flag) THEN

		sort_priority_tab( p_priority_tab   => l_priority_tab,
				   x_return_status  => l_return_status);

		IF l_debug_on THEN
	                WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
	        END IF;

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		           raise FND_API.G_EXC_UNEXPECTED_ERROR;
		       END IF;
		END IF;
	END IF;

	p_itr := l_priority_tab.FIRST;

	IF (p_itr) IS NOT NULL THEN
	LOOP
		priority := l_priority_tab(p_itr);

		IF l_debug_on THEN
	                WSH_DEBUG_SV.log(l_module_name,'Current Priority ',priority);
	        END IF;


		IF (priority = 1 ) THEN
  			-- * TO_POSTAL * TO_REGION/ZONE_ID * FROM_POSTAL * FROM_REGION/ZONE_ID *
			to_postal_flag   := TRUE;
			from_postal_flag := TRUE;
			to_tab		 := to_pregion_tab;
			from_tab	 := from_pregion_tab;

		ELSIF (priority = 2) THEN
			--*  TO_POSTAL * TO_REGION/ZONE_ID * FROM_POSTAL * - *
			to_postal_flag   := TRUE;
			from_postal_flag := TRUE;
			to_tab		 := to_pregion_tab;
			from_tab	 := g_null_tab;

		ELSIF (priority = 3 ) THEN
			-- * TO_POSTAL * TO_REGION_ID  * FROM POSTAL ZONE * -  *
 			to_postal_flag   := TRUE;
			from_postal_flag := FALSE;
			to_tab		 := to_pregion_tab;
			from_tab	 := from_postal_zone_tab;

		ELSIF (priority = 4 ) THEN
			-- * TO_POSTAL *TO_REGION_ID *	FROM_REGION_ID	* - *
			to_postal_flag   := TRUE;
 			from_postal_flag := FALSE;
			to_tab		 := to_pregion_tab;
			from_tab	 := from_all_region_tab;

		ELSIF (priority = 5 ) THEN
			-- * TO_POSTAL * TO_REGION_ID *  -  *  -  *
			to_postal_flag   := TRUE;
			from_postal_flag := FALSE;
			to_tab		 := to_pregion_tab;
			from_tab	 := g_null_tab;

		ELSIF (priority = 6 ) THEN
			-- * TO_POSTAL * - * FROM_POSTAL * FROM_REGION_ID *
			to_postal_flag   := TRUE;
			from_postal_flag := TRUE;
			to_tab		 := g_null_tab;
			from_tab	 := to_pregion_tab;

		ELSIF (priority = 7 ) THEN
			-- * TO POSTAL ZONE * - *  FROM_POSTAL * FROM_REGION_ID *
			to_postal_flag   := FALSE;
			from_postal_flag := TRUE;
			to_tab		 := to_postal_zone_tab;
			from_tab	 := from_pregion_tab;

		ELSIF (priority = 8 ) THEN
			-- * TO_POSTAL * - * FROM_POSTAL * - *
			to_postal_flag   := TRUE;
			from_postal_flag := TRUE;
			to_tab		 := g_null_tab;
			from_tab	 := g_null_tab;

		ELSIF (priority = 9 ) THEN
			-- * TO_POSTAL * - * FROM_POSTAL_ZONE *	- *
			to_postal_flag   := TRUE;
			from_postal_flag := FALSE;
			to_tab		 := g_null_tab;
			from_tab	 := from_postal_zone_tab;

		ELSIF (priority = 10 ) THEN
			-- * TO_POSTAL_ZONE * - * FROM_POSTAL *	- *
			to_postal_flag   := FALSE;
			from_postal_flag := TRUE;
			to_tab		 := to_postal_zone_tab;
			from_tab	 := g_null_tab;

		ELSIF (priority = 11 ) THEN
			-- * TO POSTAL ZONE * - *	FROM POSTAL ZONE * -  *
			to_postal_flag   := FALSE;
			from_postal_flag := FALSE;
			to_tab		 := to_postal_zone_tab;
			from_tab	 := from_postal_zone_tab;

		ELSIF (priority = 12) THEN
			-- * TO POSTAL  * - *	FROM REGION * -  *
			to_postal_flag   := TRUE;
			from_postal_flag := FALSE;
			to_tab		 := g_null_tab;
			from_tab	 := from_all_region_tab;

		ELSIF (priority = 13 ) THEN
			-- * TO POSTAL ZONE * - *	FROM_REGION_ID	* -  *
			to_postal_flag   := FALSE;
			from_postal_flag := FALSE;
			to_tab		 := to_postal_zone_tab;
			from_tab	 := from_all_region_tab;

		ELSIF (priority = 14 ) THEN
			-- * TO POSTAL  * - *	- * -  *
			to_postal_flag   := TRUE;
			from_postal_flag := FALSE;
			to_tab		 := g_null_tab;
			from_tab	 := g_null_tab;

		ELSIF (priority = 15 ) THEN
			-- * TO POSTAL ZONE * - *  - * - *
			to_postal_flag   := FALSE;
			from_postal_flag := FALSE;
			to_tab		 := to_postal_zone_tab;
			from_tab	 := g_null_tab;

		ELSIF (priority = 16 ) THEN
			-- * TO_REGION_ID  * - * FROM_POSTAL * FROM_REGION_ID *
			to_postal_flag   := FALSE;
			from_postal_flag := TRUE;
			to_tab		 := to_all_region_tab;
			from_tab	 := from_pregion_tab;

		ELSIF (priority = 17 ) THEN
			-- * TO_REGION_ID  * - * FROM_POSTAL * - *
			to_postal_flag   := FALSE;
			from_postal_flag := TRUE;
			to_tab		 := to_all_region_tab;
			from_tab	 := g_null_tab;

		ELSIF (priority = 18 ) THEN
			-- * TO_REGION_ID * - *  FROM POSTAL ZONE * -  *
			to_postal_flag   := FALSE;
			from_postal_flag := FALSE;
			to_tab		 := to_all_region_tab;
			from_tab	 := from_postal_zone_tab;

		ELSIF (priority = 19 ) THEN
			-- * TO_REGION_ID * -  *  FROM_REGION_ID *  -  *
			to_postal_flag   := FALSE;
			from_postal_flag := FALSE;
			to_tab		 := to_all_region_tab;
			from_tab	 := from_all_region_tab;

		ELSIF (priority = 20 ) THEN
			-- * TO_REGION_ID * -  *  -  *  - *
			to_postal_flag   := FALSE;
			from_postal_flag := FALSE;
			to_tab		 := to_all_region_tab;
			from_tab	 := g_null_tab;

		ELSIF (priority = 21 ) THEN
			-- * - *  -  * FROM_POSTAL *  FROM_REGION_ID *
			to_postal_flag   := FALSE;
			from_postal_flag := TRUE;
			to_tab		 := g_null_tab;
			from_tab	 := from_pregion_tab;

		ELSIF (priority = 22 ) THEN
			-- * - *  -  * FROM_POSTAL * - *
			to_postal_flag   := FALSE;
			from_postal_flag := TRUE;
			to_tab		 := g_null_tab;
			from_tab	 := g_null_tab;

		ELSIF (priority = 23 ) THEN
			--* - * - * - * FROM POSTAL ZONE *
			to_postal_flag   := FALSE;
			from_postal_flag := FALSE;
			to_tab		 := g_null_tab;
			from_tab	 := from_postal_zone_tab;

		ELSIF (priority = 24 ) THEN
			--* - *  - * FROM_REGION_ID * -  *
			to_postal_flag   := FALSE;
			from_postal_flag := FALSE;
			to_tab		 := g_null_tab;
			from_tab	 := from_all_region_tab;

		ELSIF (priority = 25) THEN
			--* - * - *  - * - *
			to_postal_flag   := FALSE;
			from_postal_flag := FALSE;
			to_tab		 := g_null_tab;
			from_tab	 := g_null_tab;

		END IF;

		--
		-- Here we should be sure that from table and to table are not empty table.
		-- In case they are null we have some extra priorities in our table.
		-- These should have not been evaluated;
                --
		-- In cases where from and to table is null we are using table g_null_tab.
		-- g_null_tab has 1 entry ie g_num_absent
		--

		IF (from_tab.COUNT<>0 AND to_tab.COUNT<>0) THEN

			IF l_debug_on THEN
				WSH_DEBUG_SV.log(l_module_name,'Calling Find Rule for key for Priority',priority);
		        END IF;

			-- Loop over the tables here only.

			to_itr := to_tab.FIRST;
			IF (to_itr IS NOT NULL) THEN
			LOOP

			    to_region := to_tab(to_itr);
			    from_itr  := from_tab.FIRST;

			    IF (from_itr IS NOT NULL) THEN
			    LOOP

				from_region := from_tab(from_itr);
				l_fixed_key := get_fixed_key ( p_group_id	=> p_info.group_id,
							       p_from_region_id => from_region,
							       p_to_region_id   => to_region);

				--
				-- If we put a from_region - to_region cache here we can
				-- control when we should call the API and when we should not.
				--
				--
				-- Only if From To region has rules registered we will proceed for search
				--

			        IF (g_from_to_region_cache.EXISTS(l_fixed_key)) THEN

					find_rule_for_key( p_fixed_key		=> l_fixed_key,
							   p_group_id		=> p_info.group_id,
							   p_from_postal_flag	=> from_postal_flag,
							   p_to_postal_flag	=> to_postal_flag,
                               p_from_postal_code	=> from_postal_code,
                               p_to_postal_code	=> to_postal_code,
							   p_weight		=> l_weight_val,
							   p_volume		=> l_volume_val,
							   p_transit_time	=> p_info.transit_time,
							   p_fob_code		=> p_info.fob_code,
							   x_rule_id		=> l_rule_id,
							   x_return_status	=> l_return_status);

					IF l_debug_on THEN
					      WSH_DEBUG_SV.log(l_module_name,'l_rule_id ', l_rule_id);
						  WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
					END IF;

					IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
						IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
						   raise FND_API.G_EXC_UNEXPECTED_ERROR;
						END IF;
					END IF;

					IF (l_rule_id <> g_rule_not_found) THEN

						x_rule_id := l_rule_id ;

						IF l_debug_on THEN
							  WSH_DEBUG_SV.log(l_module_name,'x_rule_id',x_rule_id);
							  WSH_DEBUG_SV.POP (l_module_name);
						END IF;
						RETURN;
					END IF;
				END IF;

				EXIT WHEN from_itr = from_tab.LAST;
				from_itr := from_tab.NEXT(from_itr);

			     END LOOP;
			     END IF;

			     EXIT WHEN to_itr = to_tab.LAST;
			     to_itr := to_tab.NEXT(to_itr);

			END LOOP;
			END IF;

		END IF;
		EXIT WHEN p_itr = l_priority_tab.LAST;
		p_itr := l_priority_tab.NEXT(p_itr);

	END LOOP;
	END IF;

	-- If we reach here then no rule was found for the delivery
	x_rule_id := g_rule_not_found;

	IF l_debug_on THEN
	     WSH_DEBUG_SV.POP (l_module_name);
	END IF;

EXCEPTION

WHEN FTE_CS_VOL_CONV_ERR THEN

      FND_MESSAGE.SET_NAME('FTE','FTE_CS_VOL_CONV_ERR');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.add_message(x_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'Volume UOM Conversion Error');
      END IF;

WHEN FTE_CS_WGHT_CONV_ERR THEN

      FND_MESSAGE.SET_NAME('FTE','FTE_CS_WGHT_CONV_ERR');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.add_message(x_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'Volume UOM Conversion Error');
      END IF;

WHEN others THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.get_matching_rule');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END  get_matching_rule;

--***************************************************************************
--===========================================================================
-- PROCEDURE : build_rule_result_cache    RRIVATE
--
-- PARAMETERS: p_rule_id	          Rule Id
--	       x_return_status		  Return Status
--
-- COMMENT   : The API builds Rules Result Cache.
--             a) The Rule Result store the results associated with a rule in order of
--		  increasing leg sequence/ rank .
--             b) Result Attribute Cache stores the result attributites and there values.
--***************************************************************************--

PROCEDURE build_rule_result_cache( p_rule_id		IN NUMBER,
				   x_return_status 	OUT NOCOPY VARCHAR2)

IS

-- -----------------------------------------------------------------
-- get results for a rule
-- -----------------------------------------------------------------
cursor c_get_result_id  IS
select fsras.result_id
from   fte_sel_result_assignments fsras
where  fsras.rule_id = p_rule_id;

-- -----------------------------------------------------------------
-- get result attributes names and values
-- -----------------------------------------------------------------
cursor c_get_result_attributes(p_result_id NUMBER) IS
select fsra.attribute_code,
       fsra.attribute_value
from   fte_sel_result_attributes fsra
where  fsra.result_id = p_result_id;


l_result_id_tab		result_id_tab;
l_attr_tab		fte_attr_code_val_tab_type;
l_cs_result_rec		fte_cs_result_attr_rec;
l_sorted_result_tab	result_id_tab;

l_result_id			NUMBER;

itr				NUMBER;
l_itr				NUMBER;
l_seq				NUMBER;

INVALID_RESULT_ATTRIBUTE	EXCEPTION;
NO_RESULTS_FOR_RULE		EXCEPTION;

l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name		CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'build_rule_result_cache';

BEGIN

	--
	-- Values are not in cache.
	-- Query the database tables to return results;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF l_debug_on THEN
	       WSH_DEBUG_SV.push(l_module_name);
	       WSH_DEBUG_SV.log(l_module_name,'p_rule_id',p_rule_id);
        END IF;


	OPEN  c_get_result_id;
	FETCH c_get_result_id BULK COLLECT INTO l_result_id_tab;
	CLOSE c_get_result_id;

	itr := l_result_id_tab.FIRST;

	IF (itr IS NOT NULL) THEN
	LOOP
		l_result_id := l_result_id_tab(itr);

		IF l_debug_on THEN
		       WSH_DEBUG_SV.log(l_module_name,'Result id to be queried',l_result_id);
		END IF;

		IF NOT(g_result_attribute_cache.EXISTS(l_result_id)) THEN

			l_attr_tab.DELETE;
			l_cs_result_rec	:= NULL;

			OPEN  c_get_result_attributes(l_result_id);
			FETCH c_get_result_attributes BULK COLLECT INTO l_attr_tab;
			CLOSE c_get_result_attributes;

			l_itr :=l_attr_tab.FIRST;

			IF (l_itr IS NOT NULL) THEN

			--
			-- Setting the default values(If Rank is NULL , it should be considered 1)
			-- Defaulting it to 1, otherwise it will be overwritten
			-- Converting the attribute values to record type.
			-- Default type is 'RANK'

			l_cs_result_rec.rank		:= 1;
			l_cs_result_rec.result_type	:= 'RANK';

			LOOP

				IF (l_attr_tab(l_itr).attr_code = 'RANK') THEN
					l_cs_result_rec.rank := l_attr_tab(l_itr).attr_val;
					l_cs_result_rec.result_type	:= 'RANK';

				ELSIF (l_attr_tab(l_itr).attr_code = 'LEG_SEQUENCE') THEN
-- LEG_SEQUENCE attribute code INDICATES we result_type is MULTILEG
					l_cs_result_rec.leg_sequence := l_attr_tab(l_itr).attr_val;
					l_cs_result_rec.result_type  := 'MULTILEG';

				ELSIF (l_attr_tab(l_itr).attr_code = 'LEG_DESTINATION') THEN
					l_cs_result_rec.leg_destination	   := l_attr_tab(l_itr).attr_val;

--				ELSIF (l_attr_tab(l_itr).attr_code = 'ITINERARY') THEN
--					l_cs_result_rec.itinerary_id := l_attr_tab(l_itr).attr_val;

				ELSIF (l_attr_tab(l_itr).attr_code = 'CARRIER') THEN
					l_cs_result_rec.carrier_id := l_attr_tab(l_itr).attr_val;

				ELSIF (l_attr_tab(l_itr).attr_code = 'MODE_OF_TRANSPORT') THEN
					l_cs_result_rec.mode_of_transport:= l_attr_tab(l_itr).attr_val;

				ELSIF (l_attr_tab(l_itr).attr_code = 'SERVICE_LEVEL') THEN
					l_cs_result_rec.service_level := l_attr_tab(l_itr).attr_val;

				ELSIF (l_attr_tab(l_itr).attr_code = 'FREIGHT_TERMS') THEN
					l_cs_result_rec.freight_terms_code := l_attr_tab(l_itr).attr_val;

				ELSIF (l_attr_tab(l_itr).attr_code = 'CONSIGNEE_CAR_ACNO') THEN
					l_cs_result_rec.consignee_carrier_ac_no := l_attr_tab(l_itr).attr_val;

--				ELSIF (l_attr_tab(l_itr).attr_code = 'TRACK_ONLY_FLAG') THEN
--					l_cs_result_rec.track_only_flag	:= l_attr_tab(l_itr).attr_val;
				ELSE
						RAISE INVALID_RESULT_ATTRIBUTE;
				END IF;

				EXIT WHEN l_itr = l_attr_tab.LAST;
				l_itr := l_attr_tab.NEXT(l_itr);

			END LOOP;

			END IF;

			--
			-- Now store the result attributes in the cache;
			--
			g_result_attribute_cache(l_result_id) := l_cs_result_rec;
	       END IF;

		--
		-- Either we will have multileg or Rank : Calculate the temp sequence
		-- At this stage we have result attributes stored in the cache.
		--

		IF (g_result_attribute_cache(l_result_id).result_type = 'MULTILEG') THEN
			l_seq	:= g_result_attribute_cache(l_result_id).leg_sequence;
		ELSIF (g_result_attribute_cache(l_result_id).result_type = 'RANK')  THEN
			l_seq   := g_result_attribute_cache(l_result_id).rank;
		END IF;

		--
		l_sorted_result_tab(l_seq) := l_result_id;
		--

		EXIT WHEN itr = l_result_id_tab.LAST;
		itr := l_result_id_tab.NEXT(itr);

	END LOOP;

	g_rule_result_cache(p_rule_id) := l_sorted_result_tab;

	ELSE
		RAISE NO_RESULTS_FOR_RULE;
	END IF;

	IF l_debug_on THEN
	     WSH_DEBUG_SV.POP(l_module_name);
	END IF;


EXCEPTION
WHEN INVALID_RESULT_ATTRIBUTE THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'Invalid Attribute associated with Rule'||p_rule_id);
      END IF;

WHEN NO_RESULTS_FOR_RULE THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'No Results Associated with Rule'||p_rule_id);
      END IF;

WHEN OTHERS THEN
      --
      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.BUILD_RULE_RESULT_CACHE');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

END build_rule_result_cache;


--***************************************************************************--
--===========================================================================
-- PROCEDURE : get_results_for_rule      PRIVATE
--
-- PARAMETERS: p_rule_id		 Rule Id.
--	       x_result_tab		 Results Attributes associated with the rule.
--	       x_return_status		 Return Status
--
-- COMMENT   : For a given rule id queries FTE_SEL_RESULT_ASSIGNMENTS and FTE_SEL_RESULT_ATTRIBUTES
--             to return the result.Caching is used in this procedure.
--
--
-- ALGORITHM :
--	      1. Check global cache to see if associated results exist.
--	      2. If NOT , build the cache .
--            3. Return attributes from the cache.
--***************************************************************************--
PROCEDURE get_results_for_rule( p_rule_id	 IN		NUMBER,
		 	        x_result_tab	 OUT NOCOPY	FTE_ACS_CACHE_PKG.fte_cs_result_attr_tab,
				x_return_status  OUT NOCOPY     VARCHAR2)

IS

	l_tab			RESULT_ID_TAB;
	itr			NUMBER;
	l_cnt			NUMBER := 0;
        l_return_status         VARCHAR2(1);
	l_itr			NUMBER;

	l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name		CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'get_results_for_rule';

	NO_RESULTS_FOR_RULE	EXCEPTION;

BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF l_debug_on THEN
	       WSH_DEBUG_SV.push(l_module_name);
	       WSH_DEBUG_SV.log(l_module_name,'p_rule_id',p_rule_id);
        END IF;

	IF NOT(g_rule_result_cache.EXISTS(p_rule_id)) THEN

		BUILD_RULE_RESULT_CACHE( p_rule_id	  => p_rule_id,
					 x_return_status  => l_return_status);

		IF l_debug_on THEN
	            WSH_DEBUG_SV.log(l_module_name,'l_return Status ',l_return_status);
		END IF;

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		         raise FND_API.G_EXC_UNEXPECTED_ERROR;
		     END IF;
	        END IF;
	END IF;

	l_tab := g_rule_result_cache(p_rule_id);

	IF l_debug_on THEN

		IF (l_tab.COUNT>0) THEN
			itr := l_tab.FIRST;
			LOOP
			    WSH_DEBUG_SV.log(l_module_name,'Result id',l_tab(itr));
			    EXIT WHEN itr = l_tab.LAST;
			    itr := l_tab.NEXT(itr);
			END LOOP;
		END IF;
	END IF;

	itr   := l_tab.FIRST;
	IF (itr IS NOT NULL) THEN
	LOOP
		x_result_tab(l_cnt) := g_result_attribute_cache(l_tab(itr));
		EXIT WHEN itr = l_tab.LAST;
		itr := l_tab.NEXT(itr);
		l_cnt:= l_cnt+1;
		END LOOP;
	ELSE
		RAISE NO_RESULTS_FOR_RULE;
	END IF;

	IF l_debug_on THEN

	      l_itr := x_result_tab.FIRST;

	      IF (l_itr IS NOT NULL) THEN
	      LOOP
		  	 WSH_DEBUG_SV.logmsg(l_module_name,'Output Record for result');
			 WSH_DEBUG_SV.logmsg(l_module_name,'result_type '||x_result_tab(l_itr).result_type);
			 WSH_DEBUG_SV.logmsg(l_module_name,'rank '||x_result_tab(l_itr).rank);
			 WSH_DEBUG_SV.logmsg(l_module_name,'leg_destination '||x_result_tab(l_itr).leg_destination);
			 WSH_DEBUG_SV.logmsg(l_module_name,'leg_sequence '||x_result_tab(l_itr).leg_sequence);
			 WSH_DEBUG_SV.logmsg(l_module_name,'carrier_id '||x_result_tab(l_itr).carrier_id);
			 WSH_DEBUG_SV.logmsg(l_module_name,'mode_of_transport '||x_result_tab(l_itr).mode_of_transport);
			 WSH_DEBUG_SV.logmsg(l_module_name,'service_level '||x_result_tab(l_itr).service_level);
			 WSH_DEBUG_SV.logmsg(l_module_name,'freight_terms_code '||x_result_tab(l_itr).freight_terms_code);
			 WSH_DEBUG_SV.logmsg(l_module_name,'consignee_carrier_ac_no '||x_result_tab(l_itr).consignee_carrier_ac_no);
			 WSH_DEBUG_SV.logmsg(l_module_name,'result_level '||x_result_tab(l_itr).result_level);

			 EXIT WHEN l_itr = x_result_tab.LAST;
			 l_itr := x_result_tab.NEXT(l_itr);
		END LOOP;
	      END IF;
	      WSH_DEBUG_SV.POP (l_module_name);
	END IF;

EXCEPTION

 WHEN NO_RESULTS_FOR_RULE THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'No Results Associated with Rule'||p_rule_id);
      END IF;

 WHEN OTHERS THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_CACHE_PKG.GET_RESULTS_FOR_RULE');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

END get_results_for_rule;

END FTE_ACS_CACHE_PKG;

/
