--------------------------------------------------------
--  DDL for Package Body FTE_FREIGHT_PRICING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_FREIGHT_PRICING_UTIL" AS
/* $Header: FTEFRUTB.pls 120.2 2005/10/25 14:52:41 susurend noship $ */

   -- package global variables
   g_utl_file_name    VARCHAR2(255);
   g_utl_file_dir     VARCHAR2(255);
   g_file_ptr         utl_file.file_type;
   g_log_level        NUMBER := G_LOG;
   g_msg_count        NUMBER := 0; -- this variable keeps track of how many messages we added to the
                                   -- fnd message stack


   PROCEDURE reset_dbg_vars IS
   BEGIN
      g_method   := NULL;
      g_location := NULL;
      g_exception := NULL;
   END;

   PROCEDURE set_debug_on IS
   BEGIN
      g_debug := true;
   END;

   PROCEDURE set_debug_off IS
   BEGIN
      g_debug := false;
   END;

   PROCEDURE set_method(p_log_level IN NUMBER DEFAULT G_LOG,
                        p_met IN VARCHAR2,
                        p_loc IN VARCHAR2 DEFAULT NULL)
   IS
   BEGIN

     IF (g_log_level >= p_log_level) THEN
      g_method      := p_met;
      g_location    := p_loc;
      --print_msg('<Method '||p_met||' >');
      --print_tag(p_msg => '<Method '||p_met||' >');
      print_tag(p_msg => '<'||p_met||' >');
      print_msg(G_DBG,'Method = '||p_met||' loc = '||'Start');
    END IF;
   END;

   PROCEDURE unset_method(p_log_level IN NUMBER DEFAULT G_LOG,
                          p_met IN VARCHAR2)
   IS
   BEGIN
     IF (g_log_level >= p_log_level) THEN
      g_method      := p_met;
      print_msg(G_DBG,'Method = '||p_met||' loc = '||'End');
      --print_tag(p_msg => '</Method '||p_met||' >');
      print_tag(p_msg => '</'||p_met||' >');
      --print_msg('</Method '||p_met||' >');
     END IF;
   END;

   PROCEDURE set_location(p_log_level IN NUMBER DEFAULT G_DBG, p_loc IN VARCHAR2)
   IS
   BEGIN
    IF (g_log_level >= p_log_level) THEN
      g_location   := p_loc;
      print_msg(p_log_level,p_loc);
    END IF;
   END;

   PROCEDURE set_exit_exception(p_met IN VARCHAR2, p_exc IN VARCHAR2)
   IS
      l_message_name      VARCHAR2(1000);
   BEGIN
      set_exception(p_met=>p_met,p_exc=>p_exc);
      l_message_name := get_log_file_name;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('LOGFILE',l_message_name);
      FND_MSG_PUB.ADD;
      g_msg_count := g_msg_count + 1;
   END set_exit_exception;

   -- TODO  handle token runtime
   PROCEDURE set_exception(p_met IN VARCHAR2,
                           p_log_level IN NUMBER DEFAULT G_LOG,
                           p_exc IN VARCHAR2)
   IS
      l_message_name      VARCHAR2(255);
   BEGIN
    IF (g_log_level >= p_log_level) THEN
      print_tag(G_ERR,'<EXCEPTION>');
      print_tag(G_ERR,'<METHOD>'||p_met||'</METHOD>');
      print_msg(G_ERR,p_exc);
      print_tag(G_ERR,'</EXCEPTION>');
    END IF;
/* not put message on fnd error stack, outer wrapper decide what to put on message stack
      g_exception   := p_exc;
      l_message_name := 'FTE'||UPPER(SUBSTR(p_exc,2,LENGTH(p_exc)));
      IF p_exc <> 'g_others' THEN
         IF p_exc IN ('g_no_currency_found','g_no_price_list_on_lane','g_qp_price_request_failed',
                      'g_category_not_found','g_no_segment_service_type','g_empty_delivery',
                      'g_pricing_not_required','g_not_on_pricelist',
                      'g_invalid_basis','g_loose_item_wrong_basis','g_invalid_fc_type',
                      'g_invalid_line_quantity','g_def_wt_break_not_found',
                      'g_invalid_uom_conversion',
                      -- new exceptions for pack I
                      'g_freight_costs_int_fail', 'g_freight_costs_int_fail', 'g_ln_no_lane_found',
                      'g_ln_too_many_found', 'g_lane_search_failed', 'g_no_ship_method',
                      'g_invalid_ship_method', 'g_get_cost_type_failed',
                      -- new exceptions for pack J
                      --SUSUREND 2-Oct-2003 only exceptions with no tokens listed here
                      'g_invalid_parameters','g_unsupported_action',
                      'g_tl_no_pallet_item_type','g_tl_fetch_alloc_param_fail'

           )  THEN
            FND_MESSAGE.SET_NAME('FTE',l_message_name);
            FND_MSG_PUB.ADD;
            g_msg_count := g_msg_count + 1;
         END IF;
      ELSE
         FND_MESSAGE.SET_NAME('FTE','FTE_UNEXPECTED_ERROR');
         FND_MSG_PUB.ADD;
         g_msg_count := g_msg_count + 1;
      END IF;
*/
   END;

   PROCEDURE printf(p_msg IN VARCHAR2) IS
   BEGIN
      IF (utl_file.is_open(g_file_ptr)) THEN
          utl_file.put_line(g_file_ptr,p_msg);
          --utl_file.put_line(g_file_ptr,'<L>'||p_msg||'</L>');
          utl_file.fflush(g_file_ptr);
      END IF;
   END printf;

   PROCEDURE print_msg( p_log_level IN NUMBER DEFAULT G_LOG, p_msg IN VARCHAR2 )
   IS
   BEGIN
     IF (g_debug) THEN
       IF (g_log_level >= p_log_level) THEN
        IF (g_debug_mode = 'CONC') THEN
          FND_FILE.put_line(FND_FILE.LOG,p_msg);
        ELSIF (g_debug_mode = 'FILE') THEN
          --printf(p_msg);
          printf('<L>'||p_msg||'</L>');
        ELSE
          --dbms_output.put_line(p_msg);
          null;
        END IF;
       END IF;
     END IF;
   END;

   PROCEDURE print_tag( p_log_level IN NUMBER DEFAULT G_LOG, p_msg IN VARCHAR2 )
   IS
   BEGIN
     IF (g_debug) THEN
       IF (g_log_level >= p_log_level) THEN
        IF (g_debug_mode = 'CONC') THEN
          FND_FILE.put_line(FND_FILE.LOG,p_msg);
        ELSIF (g_debug_mode = 'FILE') THEN
          printf(p_msg);
        ELSE
          --dbms_output.put_line(p_msg);
          null;
        END IF;
       END IF;
     END IF;
   END;

   -- flushes the log buffers
   PROCEDURE flush_logs IS
   BEGIN
        IF (g_debug_mode = 'FILE') THEN
          utl_file.fflush(g_file_ptr);
        END IF;
   END flush_logs;


   -- flushes the log files. Should be called at all exit points
   PROCEDURE close_logs  IS
   BEGIN
        -- IF NOT G_OE_DEBUG THEN
        --    OE_DEBUG_PUB.Debug_off;
        -- END IF;
        printf('<L>PROGRAM END TIME '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||'</L>');
        print_tag(p_msg => '</PROGRAM_FTE_FREIGHT_PRICING>');
        IF (g_debug_mode = 'FILE') THEN
            IF (utl_file.is_open(g_file_ptr)) THEN
               utl_file.fclose(g_file_ptr);
            END IF;
            g_utl_file_name := NULL;
        ELSIF (g_debug_mode = 'CONC') THEN
          -- FND_FILE.close;
             null;
        ELSE
            null;
        END IF;
   EXCEPTION
    WHEN OTHERS THEN
       null;
   END close_logs;


   -- This procedure checks the profile options to:
      --  check if debuging is turned on for the user
      --  get the location of the debug trace directory
   -- It initializes the debug trace file if debug is on
   -- It should be called at the beginning of each entry point

   PROCEDURE initialize_logging (p_debug_mode IN VARCHAR2 DEFAULT NULL,
                                 p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                 x_return_status OUT NOCOPY  VARCHAR2)
   IS
        l_debug_prof_val        VARCHAR2(1);
        l_qp_debug_prof_val     VARCHAR2(1);
        l_log_level_prof_val    VARCHAR2(10);
   BEGIN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       -- Initialize message list if p_init_msg_list is set to TRUE.
      g_msg_count := 0;
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

      IF (p_debug_mode IS NOT NULL) THEN
         g_debug_mode := p_debug_mode;
      END IF;

      l_debug_prof_val  := nvl(FND_PROFILE.value('FTE_PRC_DEBUG_FLAG'),'N');
      IF (l_debug_prof_val = 'Y') THEN
          g_debug := true;
      END IF;

      l_log_level_prof_val  := nvl(FND_PROFILE.value('FTE_PRC_LOG_LEVEL'),'1');
      g_log_level := TO_NUMBER(l_log_level_prof_val);

      IF (g_debug_mode = 'FILE' AND g_debug = true AND g_utl_file_name IS NULL) THEN


            --g_utl_file_dir      := nvl(FND_PROFILE.value('FTE_PRC_DEBUG_LOG_DIR'),'/sqlcom/log/ftewshg');
            g_utl_file_dir      := FND_PROFILE.value('FTE_PRC_DEBUG_LOG_DIR');
            IF g_utl_file_dir IS NULL THEN

               --set_exception(p_met=>p_met,p_exc=>p_exc);
               FND_MESSAGE.SET_NAME('FTE','FTE_PRC_MISSING_LOG_DIR');
               FND_MSG_PUB.ADD;
               g_msg_count := g_msg_count + 1;
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               RETURN;

            END IF;
            SELECT 'prc_'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||fte_prc_debug_s.nextval|| '.dbg'
            INTO   g_utl_file_name
            FROM   dual;
            g_file_ptr := utl_file.fopen(g_utl_file_dir, g_utl_file_name, 'w');

            print_tag(p_msg => '<PROGRAM_FTE_FREIGHT_PRICING>');
            printf('<L>PROGRAM START TIME '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')||'</L>');

            -- IF nvl(FND_PROFILE.value('QP_DEBUG'),'N') = 'Y' THEN
            --    IF NOT OE_DEBUG_PUB.ISDebugOn THEN
            --       G_OE_DEBUG := FALSE;
            --       OE_DEBUG_PUB.Debug_On;
            --       OE_DEBUG_PUB.Initialize;
            --    ELSE
            --       G_OE_DEBUG := TRUE;
            --    END IF;
            --    printf('<L>The QP Debug File is '|| OE_DEBUG_PUB.Set_Debug_Mode('FILE')||'</L>');
            -- ELSE
            --    printf('<L>QP Debug is Off</L>');
            -- END IF;

      END IF;

   EXCEPTION
      WHEN others THEN
           -- x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           g_debug := false;
           -- dbms_output.put_line ('Unexpected error '||SQLCODE||'-'||SQLERRM);
   END initialize_logging;

   FUNCTION get_log_file_name RETURN VARCHAR2
   IS
      l_ret_val   VARCHAR2(255);
   BEGIN
       IF (g_utl_file_name is NOT NULL) THEN
             l_ret_val := g_utl_file_dir||'/'||g_utl_file_name;
       END IF;
       RETURN l_ret_val;
   END get_log_file_name;

   FUNCTION get_lookup_meaning (p_lookup_type IN VARCHAR2,
                                p_lookup_code IN VARCHAR2)
   RETURN VARCHAR2
   IS

      CURSOR  c_meaning IS
      SELECT flv.meaning
      FROM   fnd_lookup_values flv, fnd_lookup_types flt
      WHERE  flv.lookup_type = flt.lookup_type
      AND    flv.lookup_code = p_lookup_code
      AND    flt.lookup_type = p_lookup_type
      AND    flv.language   = USERENV('LANG')
      AND    nvl(flv.start_date_active,sysdate)<=sysdate
      AND    nvl(flv.end_date_active,sysdate)>=sysdate
      AND    flv.enabled_flag = 'Y';

    l_meaning    VARCHAR2(240) := NULL;

   BEGIN

     IF (p_lookup_code  IS NULL) THEN
        RETURN NULL;
     END IF;

     OPEN c_meaning;
     LOOP
         FETCH c_meaning  INTO l_meaning;
         EXIT WHEN c_meaning%NOTFOUND;
     END LOOP;
    RETURN l_meaning;

    EXCEPTION
    WHEN others THEN
       RETURN null;

  END get_lookup_meaning;

PROCEDURE comma_to_table (
     p_list       IN     VARCHAR2,
     x_tab        OUT NOCOPY     dbms_utility.uncl_array )
IS

      l_temp VARCHAR2(4000);
      idx   NUMBER :=0;

BEGIN
   print_msg(G_DBG,'Input String : '||p_list);
   l_temp := p_list;
   LOOP
      idx := idx +1;
      IF (instr(l_temp,',',1,1) <> 0) THEN
              x_tab(idx) := substr(l_temp,0,instr(l_temp,',',1,1)-1);
              l_temp  := substr(l_temp,instr(l_temp,',',1,1)+1,length(l_temp));
              print_msg(G_DBG,'Resulting element at index : '||idx||' is : '||x_tab(idx));
              print_msg(G_DBG,'Now the string looks like : '||l_temp);
      ELSE
              x_tab(idx) := l_temp;
              print_msg(G_DBG,'Resulting element at index : '||idx||' is : '||x_tab(idx));
              EXIT;
      END IF;

   END LOOP;
    EXCEPTION
    WHEN others THEN
       RETURN;
END comma_to_table;

PROCEDURE comma_to_number_table (
     p_list       IN     VARCHAR2,
     x_num_tab    OUT NOCOPY  WSH_UTIL_CORE.id_tab_type )
IS
     l_arr  dbms_utility.uncl_array;
     i      NUMBER :=0;
BEGIN

     comma_to_table (
       p_list       => p_list,
       x_tab        => l_arr );

     IF (l_arr.COUNT >0) THEN
      i := l_arr.FIRST;
      LOOP
        x_num_tab(i) := to_number(NVL(l_arr(i),'0'));
      EXIT WHEN i = l_arr.LAST;
        i := l_arr.NEXT(i);
      END LOOP;
     END IF;

    EXCEPTION
    WHEN others THEN
       RETURN;
END comma_to_number_table;

PROCEDURE table_to_comma (
     p_tab        IN     dbms_utility.uncl_array,
     x_list       OUT NOCOPY     VARCHAR2 )
IS

      idx   NUMBER :=0;
      l_str VARCHAR2(4000):=NULL;

BEGIN
   idx := p_tab.FIRST;
   IF idx IS NOT NULL THEN
   LOOP
      IF (idx = p_tab.FIRST) THEN
          l_str := p_tab(idx);
      ELSE
          l_str := l_str||','||p_tab(idx);
      END IF;
      EXIT WHEN idx = p_tab.LAST;
      idx := p_tab.NEXT(idx);
   END LOOP;
   END IF;
   print_msg(G_DBG,'Converted String : '||l_str);
   x_list := l_str;
    EXCEPTION
    WHEN others THEN
       RETURN;
END table_to_comma;

PROCEDURE number_table_to_comma (
     p_num_tab        IN     wsh_util_core.id_tab_type,
     x_list           OUT NOCOPY     VARCHAR2 )
IS
     l_tab        dbms_utility.uncl_array;
     i            NUMBER :=0;

BEGIN

   IF (p_num_tab.COUNT > 0) THEN
      i := p_num_tab.FIRST;
      LOOP
         l_tab(i) := to_char(p_num_tab(i));
      EXIT WHEN i = p_num_tab.LAST;
         i := p_num_tab.NEXT(i);
      END LOOP;

      table_to_comma (
       p_tab        => l_tab,
       x_list       => x_list);

   END IF;

    EXCEPTION
    WHEN others THEN
       RETURN;

END number_table_to_comma;

FUNCTION get_msg_count RETURN NUMBER
IS
BEGIN
  RETURN g_msg_count;
END get_msg_count;

-- bug 2762257
PROCEDURE set_price_comp_exit_warn
IS
    l_message_name      VARCHAR2(1000);
BEGIN
      set_exception(p_met=>'shipment_price_compare',p_exc=>'g_dummy');
      l_message_name := get_log_file_name;
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_EST_WRN');
      FND_MESSAGE.SET_TOKEN('LOGFILE',l_message_name);
      FND_MSG_PUB.ADD;
      g_msg_count := g_msg_count + 1;
END set_price_comp_exit_warn;

PROCEDURE set_trip_prc_comp_exit_warn
IS
    l_message_name      VARCHAR2(1000);
BEGIN
      set_exception(p_met=>'Compare_Trip_Rates',p_exc=>'g_dummy');
      l_message_name := get_log_file_name;
      FND_MESSAGE.SET_NAME('FTE','FTE_TRP_PRC_EST_WRN');
      FND_MESSAGE.SET_TOKEN('LOGFILE',l_message_name);
      FND_MSG_PUB.ADD;
      g_msg_count := g_msg_count + 1;
END set_trip_prc_comp_exit_warn;


PROCEDURE get_trip_name(
	p_trip_id	IN NUMBER,
	x_trip_name 	IN OUT NOCOPY VARCHAR2)

IS

CURSOR get_name(c_trip_id IN NUMBER) IS
	SELECT name
	FROM wsh_trips
	WHERE trip_id = c_trip_id;

BEGIN

	OPEN get_name(p_trip_id);
	FETCH get_name INTO x_trip_name;
	CLOSE get_name;

END get_trip_name;


PROCEDURE get_lane_number(
	p_lane_id	IN NUMBER,
	x_lane_number 	IN OUT NOCOPY VARCHAR2)

IS

CURSOR get_name(c_lane_id IN NUMBER) IS

	SELECT lane_number
	FROM fte_lanes
	WHERE lane_id = c_lane_id;

BEGIN

	OPEN get_name(p_lane_id);
	FETCH get_name INTO x_lane_number;
	CLOSE get_name;

END get_lane_number;



PROCEDURE get_carrier_name(
	p_carrier_id	IN NUMBER,
	x_carrier_name 	IN OUT NOCOPY VARCHAR2)

IS

CURSOR get_name(c_carrier_id IN NUMBER) IS

	SELECT hz.party_name
	FROM 	hz_parties hz,
		wsh_carriers wc
	WHERE hz.party_id = wc.carrier_id
	 AND	wc.carrier_id = c_carrier_id;

BEGIN

	OPEN get_name(p_carrier_id);
	FETCH get_name INTO x_carrier_name;
	CLOSE get_name;

END get_carrier_name;


PROCEDURE get_list_header_name(
	p_list_id	IN NUMBER,
	x_list_name 	IN OUT NOCOPY VARCHAR2)

IS

CURSOR get_name(c_list_id IN NUMBER) IS

	SELECT name
	FROM qp_list_headers
	WHERE list_header_id = c_list_id;

BEGIN

	OPEN get_name(p_list_id);
	FETCH get_name INTO x_list_name;
	CLOSE get_name;

END get_list_header_name;

PROCEDURE get_delivery_name(
	p_id	IN NUMBER,
	x_name 	IN OUT NOCOPY VARCHAR2)

IS

CURSOR get_name(c_id IN NUMBER) IS

	SELECT name
	FROM wsh_new_deliveries
	WHERE delivery_id = c_id;

BEGIN

	OPEN get_name(p_id);
	FETCH get_name INTO x_name;
	CLOSE get_name;

END get_delivery_name;



--
-- Procedure setmsg
--  Used to add a message to the message stack
--     p_api -> calling program name
--     p_exc -> exception name (form g_... )
--     p_msg_type -> 'E' - Error (default), 'W'-Warning, 'U'- unexpected error
--     p_trip_id, ... -> tokens
--

   PROCEDURE setmsg (p_api                IN VARCHAR2,
                     p_exc                IN VARCHAR2,
                     p_msg_name           IN VARCHAR2 DEFAULT NULL,
                     p_msg_type           IN VARCHAR2 DEFAULT 'E',
                     p_trip_id            IN NUMBER DEFAULT NULL,
                     p_stop_id            IN NUMBER DEFAULT NULL,
                     p_delivery_id        IN NUMBER DEFAULT NULL,
                     p_delivery_leg_id    IN NUMBER DEFAULT NULL,
                     p_delivery_detail_id IN NUMBER DEFAULT NULL,
                     p_carrier_id         IN NUMBER DEFAULT NULL,
                     p_location_id        IN NUMBER DEFAULT NULL,
                     p_list_header_id     IN NUMBER DEFAULT NULL,
                     p_lane_id		  IN NUMBER DEFAULT NULL,
                     p_schedule_id	  IN NUMBER DEFAULT NULL,
                     p_move_id 		  IN NUMBER DEFAULT NULL)
   IS
      l_message_name      VARCHAR2(255);
      l_name 	VARCHAR2(30);
   BEGIN
      IF p_msg_name is NULL THEN
        l_message_name := 'FTE'||UPPER(SUBSTR(p_exc,2,LENGTH(p_exc)));
      ELSE
 	l_message_name := p_msg_name;
      END IF;

      FND_MESSAGE.SET_NAME('FTE',l_message_name);
      --SUJITH 2-Oct-2003 not showing PROGRAM_UNIT
      --IF (p_api IS NOT NULL) THEN
      --  FND_MESSAGE.SET_TOKEN('PROGRAM_UNIT_NAME', p_api);
      --END IF;
      -- FND_MSG_PUB.ADD;
      g_msg_count := g_msg_count + 1;

      l_name:=NULL;

      IF p_trip_id IS NOT NULL
      THEN
	    get_trip_name(p_trip_id=>p_trip_id,
	    		  x_trip_name=> l_name);
	    IF (l_name IS NULL)
	    THEN
            	FND_MESSAGE.SET_TOKEN('TRIP_ID', p_trip_id);
            ELSE
            	FND_MESSAGE.SET_TOKEN('TRIP_ID', l_name);
            END IF;
      END IF;
      IF p_stop_id IS NOT NULL
      THEN
            FND_MESSAGE.SET_TOKEN('STOP_ID', p_stop_id);
      END IF;
      IF p_delivery_id IS NOT NULL
      THEN
	    get_delivery_name(p_id=>p_delivery_id,
	    		  x_name=> l_name);
	    IF (l_name IS NULL)
	    THEN
            	FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_delivery_id);
            ELSE
            	FND_MESSAGE.SET_TOKEN('DELIVERY_ID', l_name);
            END IF;
      END IF;
      IF p_delivery_detail_id IS NOT NULL
      THEN
            FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL_ID', p_delivery_detail_id);
      END IF;
      IF p_delivery_leg_id IS NOT NULL
      THEN
            FND_MESSAGE.SET_TOKEN('DELIVERY_LEG_ID', p_delivery_leg_id);
      END IF;
      IF p_carrier_id IS NOT NULL
      THEN

	    get_carrier_name(p_carrier_id=>p_carrier_id,
	    		  x_carrier_name=> l_name);
	    IF (l_name IS NULL)
	    THEN
            	FND_MESSAGE.SET_TOKEN('CARRIER_ID', p_carrier_id);
            ELSE
            	FND_MESSAGE.SET_TOKEN('CARRIER_ID', l_name);
            END IF;



      END IF;
      IF p_location_id IS NOT NULL
      THEN
            FND_MESSAGE.SET_TOKEN('LOCATION_ID', p_location_id);
      END IF;


      IF p_list_header_id IS NOT NULL
      THEN

	    get_list_header_name(p_list_id=>p_list_header_id,
	    		  x_list_name=> l_name);
	    IF (l_name IS NULL)
	    THEN
            	FND_MESSAGE.SET_TOKEN('LIST_HEADER_ID', p_list_header_id);
            ELSE
            	FND_MESSAGE.SET_TOKEN('LIST_HEADER_ID', l_name);
            END IF;


      END IF;


      IF p_lane_id IS NOT NULL
      THEN

	    get_lane_number(p_lane_id=>p_lane_id,
	    		  x_lane_number=> l_name);
	    IF (l_name IS NULL)
	    THEN
            	FND_MESSAGE.SET_TOKEN('LANE_ID', p_lane_id);
            ELSE
            	FND_MESSAGE.SET_TOKEN('LANE_ID', l_name);
            END IF;


      END IF;
      IF p_schedule_id IS NOT NULL
      THEN
            FND_MESSAGE.SET_TOKEN('SCHEDULE_ID', p_schedule_id);
      END IF;

      IF p_move_id IS NOT NULL
      THEN
            FND_MESSAGE.SET_TOKEN('MOVE_ID', p_move_id);
      END IF;

      FND_MSG_PUB.ADD;

      --IF (p_msg_type = 'E') THEN
        --WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
      --ELSIF (p_msg_type = 'W') THEN
	--WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
      --ELSIF (p_msg_type = 'U') THEN
        --WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR);
      --END IF;


   EXCEPTION
     WHEN others THEN
       null;
   END setmsg;



   /*Given a combination of input parameters, this API can be called from
  anywhere in rating engine. For example some of the combinations are:
  P_delivery_id+ p_carrier_id 	- In case of Delivery Rating
  P_trip_id                     - In case of Trip rating , carrier_id can be ontained from trip
  P_location_id + p_carrier_id	- In case of OM.
*/

PROCEDURE get_currency_code(
            p_delivery_id   IN NUMBER DEFAULT NULL,
            p_trip_id       IN NUMBER DEFAULT NULL,
            p_location_id   IN NUMBER DEFAULT NULL,
            p_carrier_id    IN NUMBER DEFAULT NULL,
            x_currency_code OUT NOCOPY VARCHAR2 ,
            x_return_status OUT NOCOPY VARCHAR2 )

IS
    l_init_msg_list     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(32767);
    l_log_level NUMBER := G_DBG;
    l_method_name VARCHAR2(50) := 'fte_freight_pricing_util.get_currency_code';
    l_entity_type       VARCHAR2(20);
    l_entity_id         NUMBER;

BEGIN

    l_init_msg_list := fnd_api.g_true;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    reset_dbg_vars;
    set_method(l_log_level,l_method_name);

    --R12 Hiding Project
    FTE_FREIGHT_PRICING.get_currency_code (
          p_carrier_id=>p_carrier_id,
          x_currency_code=>x_currency_code,
          x_return_status=>x_return_status);
    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS and
        x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
    THEN

        print_msg(l_log_level,'get currency code failed');
        print_msg(l_log_level,'x_return_status '|| x_return_status);
        raise FND_API.G_EXC_ERROR;
    END IF;


    --R12 Hiding Project
    /*
    IF p_delivery_id IS NOT NULL THEN
        l_entity_type := 'Delivery';
        l_entity_id   := p_delivery_id;
    ELSIF p_trip_id IS NOT NULL THEN
        l_entity_type := 'Trip';
        l_entity_id   := p_trip_id;
    ELSIF p_location_id IS NOT NULL THEN
        l_entity_type := 'Location';
        l_entity_id   := p_location_id;
    END IF;

   FTE_MLS_UTIL.GET_CURRENCY_CODE( p_init_msg_list  => l_init_msg_list,
                                   x_return_status  => x_return_status,
                                   x_msg_count      => l_msg_count,
                                   x_msg_data       => l_msg_data,
                                   x_currency_code  => x_currency_code,
                                   p_entity_type    => l_entity_type,
                                   p_entity_id      => l_entity_id,
                                   p_carrier_id     => p_carrier_id
                                 );


  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS and
        x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
  THEN

        print_msg(l_log_level,'get currency code failed');
        print_msg(l_log_level,'l_msg_data '|| l_msg_data);
        print_msg(l_log_level,'l_msg_count '|| l_msg_count);
        raise FND_API.G_EXC_ERROR;
  END IF;
*/
  print_msg(l_log_level,' l_currency_code '|| x_currency_code);

  unset_method(l_log_level,l_method_name);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        set_exception(l_method_name,l_log_level,'FND_API.G_EXC_ERROR');
        unset_method(l_log_level,l_method_name);
   WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        set_exception(l_method_name,G_ERR,'g_others');
        print_msg(G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        unset_method(l_log_level,l_method_name);

END get_currency_code;



   FUNCTION convert_uom(from_uom IN VARCHAR2,
                          to_uom IN VARCHAR2,
                        quantity IN NUMBER,
                         item_id IN NUMBER DEFAULT NULL)

   RETURN NUMBER
IS

  result        NUMBER;

BEGIN

  IF from_uom = to_uom THEN
     result := quantity;
  ELSIF ( (from_uom IS NULL)
        OR (to_uom   IS NULL))
  THEN

     result := NULL;

  ELSIF (quantity = 0)
  THEN
--This will not be valid for all UOMs (Farenheit to Centigrade)
--but should work for UOMs in the context of freight rating
  	result:=0;
  ELSE

     result := WSH_WV_UTILS.convert_uom(
					from_uom,
					to_uom,
					quantity,
					0);

     IF result = 0 THEN
        result := NULL;

     END IF;
   END IF;

  RETURN result;

END convert_uom;


END FTE_FREIGHT_PRICING_UTIL;

/
