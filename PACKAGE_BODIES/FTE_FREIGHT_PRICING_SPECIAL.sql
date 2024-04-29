--------------------------------------------------------
--  DDL for Package Body FTE_FREIGHT_PRICING_SPECIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_FREIGHT_PRICING_SPECIAL" AS
/* $Header: FTEFRPSB.pls 120.6 2005/11/04 16:30:56 susurend noship $ */

-- Private Package level Variables
g_hash_base NUMBER := 1;
g_hash_size NUMBER := power(2, 25);

G_CONTAINER_BASIS    NUMBER := 1;
G_VOLUME_BASIS       NUMBER := 2;
G_WEIGHT_BASIS       NUMBER := 3;

   g_finished_success		EXCEPTION;
   g_finished_warning		EXCEPTION;

  TYPE rule_value_rec_type IS RECORD
       ( name                    VARCHAR2(40),
         value                   VARCHAR2(40),
         def_value               VARCHAR2(40));

  TYPE rule_value_tab_type IS TABLE OF rule_value_rec_type INDEX BY BINARY_INTEGER;

  TYPE bumped_rolledup_line_rec_type IS RECORD
        (line_quantity                          NUMBER);

  TYPE bumped_rolledup_line_tab_type IS TABLE OF bumped_rolledup_line_rec_type INDEX BY BINARY_INTEGER;

  -- bug2803178 for parcel hundred wt loose item only
  g_bumped_rolledup_lines         bumped_rolledup_line_tab_type;

CURSOR get_uom_for_each
IS
SELECT uom_for_num_of_units
FROM wsh_global_parameters;

-- prints contents of the global parameter table
PROCEDURE print_params IS
 i    NUMBER;
l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
l_method_name VARCHAR2(50) := 'print_params';
 BEGIN
   i := g_lane_parameters.FIRST;
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'g_lane_parameters ====> ');
   IF (i IS NOT NULL) THEN
   LOOP
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'lane_id               = '||g_lane_parameters(i).lane_id);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  parameter_instance_id = '||g_lane_parameters(i).parameter_instance_id);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  lane_function         = '||g_lane_parameters(i).lane_function);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  parameter_sub_type    = '||g_lane_parameters(i).parameter_sub_type);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  parameter_name        = '||g_lane_parameters(i).parameter_name);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  value_from            = '||g_lane_parameters(i).value_from);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  value_to              = '||g_lane_parameters(i).value_to);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  uom_class             = '||g_lane_parameters(i).uom_class);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  uom_code              = '||g_lane_parameters(i).uom_code);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  currency_code         = '||g_lane_parameters(i).currency_code);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  ');
   EXIT WHEN (i >= g_lane_parameters.LAST );
       i := g_lane_parameters.NEXT(i);
   END LOOP;
   END IF;

END print_params;

PROCEDURE print_special_flags IS
 i    NUMBER;
l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
l_method_name VARCHAR2(50) := 'print_special_flags';
 BEGIN

   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'g_special_flags  ===>');
   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'dim_wt_flag           = '||g_special_flags.dim_wt_flag);
   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'lane_function         = '||g_special_flags.lane_function);
   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'minimum_charge_flag   = '||g_special_flags.minimum_charge_flag);
   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'parcel_hundredwt_flag = '||g_special_flags.parcel_hundredwt_flag);
   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'deficit_wt_flag       = '||g_special_flags.deficit_wt_flag);
   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'flat_containerwt_flag       = '||g_special_flags.flat_containerwt_flag);

END print_special_flags;

PROCEDURE print_rules IS
 i    NUMBER;
l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
l_method_name VARCHAR2(50) := 'print_rules';
 BEGIN
   i := g_lane_rules_tab.FIRST;
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'g_lane_rules_tab ====> ');
   IF (i IS NOT NULL) THEN
   LOOP
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  lane_function         = '||g_lane_rules_tab(i).lane_function);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  pattern_name          = '||g_lane_rules_tab(i).pattern_name);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  grouping_level        = '||g_lane_rules_tab(i).grouping_level);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  commodity_aggregation = '||g_lane_rules_tab(i).commodity_aggregation);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'  pricing_objective     = '||g_lane_rules_tab(i).pricing_objective);
   EXIT WHEN (i >= g_lane_rules_tab.LAST );
       i := g_lane_rules_tab.NEXT(i);
   END LOOP;
   END IF;

END print_rules;

PROCEDURE load_rules(p_lane_id         IN NUMBER,
                     p_lane_function   IN VARCHAR2,
                     x_return_status   OUT NOCOPY  VARCHAR2)
IS

    CURSOR     c_lane_rules(c_lane_id IN NUMBER, c_lane_function IN VARCHAR2, c_pattern_name IN VARCHAR2) IS
    SELECT     fpp.lane_id,
               fppd.lane_function,
               fppd.parameter_sub_type,
               fppd.parameter_name,
               fpp.value_from,
               fppd.default_value_from
    FROM       fte_prc_parameter_defaults fppd, fte_prc_parameters fpp
    WHERE      fppd.parameter_id = fpp.parameter_id (+)
    AND        fpp.lane_id (+) = c_lane_id
    AND        fppd.lane_function = c_lane_function
    AND        fppd.parameter_type = 'RULE'
    AND        fppd.parameter_sub_type = c_pattern_name
    ORDER BY   fppd.parameter_sub_type, fppd.parameter_name;

   CURSOR      c_patterns(c_lane_function IN VARCHAR2) IS
   SELECT      DISTINCT fppd.parameter_sub_type pattern_name
   FROM        fte_prc_parameter_defaults fppd
   WHERE       fppd.lane_function = c_lane_function
     AND       fppd.parameter_type = 'RULE'
   ORDER BY    1;

    l_lane_rule_rec          c_lane_rules%rowtype;
    l_def_values             rule_value_tab_type;
    l_pattern_name           VARCHAR2(30);
    l_return_status          VARCHAR2(1);
    i                        NUMBER :=1;
    j                        NUMBER :=1;
    k                        NUMBER :=1;
    l_counter                NUMBER :=0;


l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
l_method_name VARCHAR2(50) := 'load_rules';
 BEGIN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   fte_freight_pricing_util.reset_dbg_vars;
   fte_freight_pricing_util.set_method(l_log_level,'load_rules');

   g_lane_rules_tab.DELETE;

  OPEN c_patterns(p_lane_function);
  LOOP
    FETCH c_patterns INTO l_pattern_name;
    EXIT WHEN c_patterns%NOTFOUND;
    l_counter := 0;
    i := 1;
    l_def_values.delete;

       OPEN c_lane_rules(p_lane_id,p_lane_function,l_pattern_name);
       LOOP
          FETCH  c_lane_rules INTO l_lane_rule_rec;
          EXIT WHEN c_lane_rules%NOTFOUND;

          IF l_lane_rule_rec.value_from IS NOT NULL THEN
             l_counter := l_counter + 1;
          END IF;

          l_def_values(i).name := l_lane_rule_rec.parameter_name;
          l_def_values(i).def_value := l_lane_rule_rec.default_value_from;
          l_def_values(i).value := l_lane_rule_rec.value_from;
          i := i+1;

       END LOOP;
       CLOSE c_lane_rules;

       IF l_pattern_name = FTE_FREIGHT_PRICING.G_PATTERN_1_NAME THEN
          k := FTE_FREIGHT_PRICING.G_PATTERN_1;
       ELSIF l_pattern_name = FTE_FREIGHT_PRICING.G_PATTERN_2_NAME THEN
          k := FTE_FREIGHT_PRICING.G_PATTERN_2;
       ELSIF l_pattern_name = FTE_FREIGHT_PRICING.G_PATTERN_3_NAME THEN
          k := FTE_FREIGHT_PRICING.G_PATTERN_3;
       ELSIF l_pattern_name = FTE_FREIGHT_PRICING.G_PATTERN_4_NAME THEN
          k := FTE_FREIGHT_PRICING.G_PATTERN_4;
       ELSIF l_pattern_name = FTE_FREIGHT_PRICING.G_PATTERN_5_NAME THEN
          k := FTE_FREIGHT_PRICING.G_PATTERN_5;
       ELSIF l_pattern_name = FTE_FREIGHT_PRICING.G_PATTERN_5_NAME THEN
          k := FTE_FREIGHT_PRICING.G_PATTERN_5;
       ELSIF l_pattern_name = FTE_FREIGHT_PRICING.G_PATTERN_6_NAME THEN
          k := FTE_FREIGHT_PRICING.G_PATTERN_6;
       ELSIF l_pattern_name = FTE_FREIGHT_PRICING.G_PATTERN_7_NAME THEN
          k := FTE_FREIGHT_PRICING.G_PATTERN_7;
       ELSIF l_pattern_name = FTE_FREIGHT_PRICING.G_PATTERN_8_NAME THEN
          k := FTE_FREIGHT_PRICING.G_PATTERN_8;
       ELSIF l_pattern_name = FTE_FREIGHT_PRICING.G_PATTERN_9_NAME THEN
          k := FTE_FREIGHT_PRICING.G_PATTERN_9;
       ELSIF l_pattern_name = FTE_FREIGHT_PRICING.G_PATTERN_10_NAME THEN
          k := FTE_FREIGHT_PRICING.G_PATTERN_10;
       END IF;

      IF (l_def_values.COUNT > 0) THEN
       g_lane_rules_tab(k).lane_function := p_lane_function;
       g_lane_rules_tab(k).pattern_name  := l_pattern_name;

       j := l_def_values.FIRST;
       IF (j IS NOT NULL) THEN
       LOOP
          IF l_def_values(j).name = 'GROUPING_LEVEL' THEN
             IF l_counter > 0 THEN
               g_lane_rules_tab(k).grouping_level := l_def_values(j).value;
             ELSE
               g_lane_rules_tab(k).grouping_level := l_def_values(j).def_value;
             END IF;
          ELSIF l_def_values(j).name = 'COMMODITY_AGGREGATION' THEN
             IF l_counter > 0 THEN
               g_lane_rules_tab(k).commodity_aggregation := l_def_values(j).value;
             ELSE
               g_lane_rules_tab(k).commodity_aggregation := l_def_values(j).def_value;
             END IF;
          ELSIF l_def_values(j).name = 'PRICING_OBJECTIVE' THEN
             IF l_counter > 0 THEN
               g_lane_rules_tab(k).pricing_objective := l_def_values(j).value;
             ELSE
               g_lane_rules_tab(k).pricing_objective := l_def_values(j).def_value;
             END IF;
          END IF;

	  IF p_lane_function = 'LTL' and
	    (g_lane_rules_tab(k).grouping_level <> 'SHIPMENT'
	     or g_lane_rules_tab(k).commodity_aggregation <> 'WITHIN') THEN

	    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Invalid parttern for LTL');
	    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'grouping_level='||g_lane_rules_tab(k).grouping_level);
	    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'commodity_aggregation='||g_lane_rules_tab(k).commodity_aggregation);
  	    l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

	  END IF;

          EXIT WHEN j = l_def_values.LAST;
          j := l_def_values.NEXT(j);

       END LOOP;
       END IF;
      END IF;
  END LOOP;
  CLOSE c_patterns;

  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

 fte_freight_pricing_util.unset_method(l_log_level,'load_rules');
 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'FND_API.G_EXC_ERROR');
        fte_freight_pricing_util.unset_method(l_log_level,'load_rules');
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        fte_freight_pricing_util.unset_method(l_log_level,'load_rules');
END load_rules;

-- This procedure initializes global data for use by special pricing.
-- Currently, this procedure loads parameters for the lane into the global plsql table.
PROCEDURE initialize(p_lane_id         IN NUMBER,
                     x_lane_function   OUT NOCOPY  VARCHAR2,
                     x_return_status   OUT NOCOPY  VARCHAR2)
IS

    CURSOR     c_lane_param(c_lane_id IN NUMBER ) IS
    SELECT     fpp.parameter_instance_id,fpp.lane_id,
               fppd.lane_function,fppd.parameter_sub_type, fppd.parameter_name,
               nvl(fpp.value_from,fppd.default_value_from),
               nvl(fpp.value_to,fppd.default_value_to),
               fpp.uom_class, fpp.uom_code, fpp.currency_code
    FROM       fte_prc_parameter_defaults fppd, fte_prc_parameters fpp
    WHERE      fppd.parameter_id = fpp.parameter_id (+)
    AND        fpp.lane_id (+) = c_lane_id
    AND        fppd.parameter_type = 'PARAMETER'
    ORDER BY   fppd.parameter_type, fppd.parameter_sub_type, fppd.parameter_name;

    l_lane_param_rec         lane_parameter_rec_type;
    l_return_status          VARCHAR2(1);
    i                        NUMBER :=1;
    l_log_level  NUMBER := fte_freight_pricing_util.G_LOG;
    l_method_name VARCHAR2(50) := 'initialize';

/*
   ---- Local Module ----
   -- This procedure checks for any applicable conditions within the loaded parameters,
   -- and sets flags in a global record.
   -- This global record is checked later (at various points) to decide on the course of action.

   PROCEDURE check_for_special_conditions(p_param_rec IN lane_parameter_rec_type) IS
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'check_for_special_conditions';
 BEGIN
      fte_freight_pricing_util.set_method(l_log_level,'check_for_special_conditions');
        g_special_flags.lane_id := p_param_rec.lane_id;
        IF (p_param_rec.lane_function = 'NONE' AND p_param_rec.parameter_name = 'LANE_FUNCTION') THEN
               g_special_flags.lane_function := nvl(p_param_rec.value_from,'NONE');
        END IF;
        --IF (p_param_rec.lane_function = 'NONE' AND p_param_rec.parameter_sub_type = 'DIM_WT'
        --    AND p_param_rec.parameter_name = 'ENABLED') THEN
        --       g_special_flags.dim_wt_flag := nvl(p_param_rec.value_from,'N');
        --END IF;

        IF (p_param_rec.lane_function = 'NONE' and p_param_rec.parameter_sub_type = 'MIN_CHARGE' AND
            p_param_rec.parameter_name = 'MIN_CHARGE_AMT') THEN
               --g_special_flags.minimum_charge_flag := decode(nvl(p_param_rec.value_from,0),0,'N','Y');
               IF (nvl(fnd_number.canonical_to_number(p_param_rec.value_from),0) = 0
                    OR p_param_rec.currency_code IS NULL) THEN
                   g_special_flags.minimum_charge_flag := 'N';
               ELSE
                   g_special_flags.minimum_charge_flag := 'Y';
               END IF;
        END IF;
        IF (p_param_rec.lane_function = 'LTL' AND p_param_rec.parameter_sub_type = 'DEFICIT_WT'
            AND p_param_rec.parameter_name = 'ENABLED') THEN
               g_special_flags.deficit_wt_flag := nvl(p_param_rec.value_from,'N');
        END IF;
        IF (p_param_rec.lane_function = 'PARCEL' AND p_param_rec.parameter_sub_type = 'HUNDREDWT'
            AND p_param_rec.parameter_name = 'ENABLED') THEN
               g_special_flags.parcel_hundredwt_flag := nvl(p_param_rec.value_from,'N');
        END IF;
      fte_freight_pricing_util.unset_method(l_log_level,'check_for_special_conditions');
   END check_for_special_conditions;
 ---- End Local Module ---
*/
 ---- Local Module ----
  -- validate lane parameters and set special flags
  PROCEDURE validate_parameters(x_return_status OUT NOCOPY  VARCHAR2) IS
    i  NUMBER;
    l_wt_break_cnt       NUMBER := 0;
    l_last_df_wt_uom     VARCHAR2(30);
    l_invalid_df_wt_break_found BOOLEAN := false;
    l_dim_wt_factor_ok   BOOLEAN := false;
    l_dim_wt_wt_uom_ok   BOOLEAN := false;
    l_dim_wt_vol_uom_ok   BOOLEAN := false;
    l_dim_wt_dim_uom_ok   BOOLEAN := false;
    l_return_status   VARCHAR2(1);
  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'validate_parameters';
 BEGIN
      fte_freight_pricing_util.set_method(l_log_level,'validate_parameters');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
/*
      --validate deficit wt params
      IF (g_special_flags.deficit_wt_flag = 'Y') THEN
         --check if weight breaks have been defined.
         i := g_lane_parameters.FIRST;
         IF (i is NOT NULL) THEN
            LOOP
               IF (g_lane_parameters(i).parameter_name = 'WT_BREAK_POINT') THEN

                      IF ( g_lane_parameters(i).value_from IS NULL
                           OR g_lane_parameters(i).uom_code IS NULL) THEN
                             raise fte_freight_pricing_util.g_invalid_wt_break;
                      END IF;

                      IF (l_last_df_wt_uom IS NULL) THEN
                          l_last_df_wt_uom := g_lane_parameters(i).uom_code;
                      ELSE
                          IF (l_last_df_wt_uom <> g_lane_parameters(i).uom_code ) THEN
                             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'All deficit weight break points are not in the same uom');
                             raise fte_freight_pricing_util.g_invalid_wt_break;
                          END IF;
                      END IF;

                    l_wt_break_cnt := l_wt_break_cnt + 1;
               END IF;
            EXIT WHEN i >=g_lane_parameters.LAST;
            i := g_lane_parameters.NEXT(i);
            END LOOP;
         END IF;
         IF (l_wt_break_cnt = 0) THEN
            raise fte_freight_pricing_util.g_weight_break_not_found;
         END IF;

      END IF;  --validate deficit wt params
*/

      fte_freight_pricing_util.print_msg(l_log_level,'before loop --1');
      i := g_lane_parameters.FIRST;
      IF (i is NOT NULL) THEN
         LOOP
             fte_freight_pricing_util.print_msg(l_log_level,'in loop i='||i);
	     IF (g_lane_parameters(i).lane_function = 'NONE'
                 AND g_lane_parameters(i).parameter_sub_type = 'LANE'
                 AND g_lane_parameters(i).parameter_name = 'LANE_FUNCTION') THEN
               IF (g_lane_parameters(i).value_from is null) THEN
                 g_special_flags.lane_function := 'NONE';
               ELSIF (g_lane_parameters(i).value_from = 'PARCEL'
		      OR g_lane_parameters(i).value_from = 'FLAT'
		      OR g_lane_parameters(i).value_from = 'LTL') THEN
                 g_special_flags.lane_function := g_lane_parameters(i).value_from;
	       ELSE
                 g_special_flags.lane_function := 'NONE';
               END IF;
             END IF;

	     IF (g_lane_parameters(i).lane_function = 'FLAT'
                 AND g_lane_parameters(i).parameter_sub_type = 'INCLUDE_CONTAINER_WEIGHT'
                 AND g_lane_parameters(i).parameter_name = 'ENABLED') THEN
               IF (g_lane_parameters(i).value_from is null) THEN
                 g_special_flags.flat_containerwt_flag := 'Y';
               ELSIF (g_lane_parameters(i).value_from = 'N') THEN
                 g_special_flags.flat_containerwt_flag := 'N';
	       ELSE
                 g_special_flags.flat_containerwt_flag := 'Y';
               END IF;
             END IF;

	     IF (g_lane_parameters(i).lane_function = 'LTL'
                 AND g_lane_parameters(i).parameter_sub_type = 'DEFICIT_WT'
                 AND g_lane_parameters(i).parameter_name = 'ENABLED') THEN
               IF (g_lane_parameters(i).value_from is null) THEN
                 g_special_flags.deficit_wt_flag := 'N';
               ELSIF (g_lane_parameters(i).value_from = 'Y') THEN
                 g_special_flags.deficit_wt_flag := 'Y';
	       ELSE
                 g_special_flags.deficit_wt_flag := 'N';
               END IF;
             END IF;

	     IF (g_lane_parameters(i).lane_function = 'LTL'
                 AND g_lane_parameters(i).parameter_sub_type = 'DEFICIT_WT'
                 AND g_lane_parameters(i).parameter_name = 'WT_BREAK_POINT') THEN
	       IF (g_lane_parameters(i).value_from is null) THEN
                 fte_freight_pricing_util.print_msg(l_log_level,'deficit wt break point null');
		 l_invalid_df_wt_break_found := true;
                 --raise fte_freight_pricing_util.g_invalid_wt_break;
	       ELSIF (fnd_number.canonical_to_number(g_lane_parameters(i).value_from) < 0) THEN
                 fte_freight_pricing_util.print_msg(l_log_level,'deficit wt break point '||g_lane_parameters(i).value_from);
		 l_invalid_df_wt_break_found := true;
                 --raise fte_freight_pricing_util.g_invalid_wt_break;
               ELSE
		 IF (g_lane_parameters(i).uom_code is null) THEN
                   fte_freight_pricing_util.print_msg(l_log_level,'deficit wt break point uom null');
  		   l_invalid_df_wt_break_found := true;
                   --raise fte_freight_pricing_util.g_invalid_wt_break;
 		 ELSE
                   IF (l_last_df_wt_uom IS NULL) THEN
                     l_last_df_wt_uom := g_lane_parameters(i).uom_code;
                   ELSE
                     IF (l_last_df_wt_uom <> g_lane_parameters(i).uom_code ) THEN
                       fte_freight_pricing_util.print_msg(l_log_level,'All deficit weight break points are not in the same uom');
		       l_invalid_df_wt_break_found := true;
                       --raise fte_freight_pricing_util.g_invalid_wt_break;
                     END IF;
                   END IF;
                   l_wt_break_cnt := l_wt_break_cnt + 1;
		 END IF;
               END IF;
             END IF;

	     IF (g_lane_parameters(i).lane_function = 'PARCEL'
                 AND g_lane_parameters(i).parameter_sub_type = 'HUNDREDWT'
                 AND g_lane_parameters(i).parameter_name = 'ENABLED') THEN
               IF (g_lane_parameters(i).value_from is null) THEN
                 g_special_flags.parcel_hundredwt_flag := 'N';
               ELSIF (g_lane_parameters(i).value_from = 'Y') THEN
                 g_special_flags.parcel_hundredwt_flag := 'Y';
	       ELSE
                 g_special_flags.parcel_hundredwt_flag := 'N';
               END IF;
             END IF;

	     IF (g_lane_parameters(i).lane_function = 'PARCEL'
                 AND g_lane_parameters(i).parameter_sub_type = 'HUNDREDWT'
                 AND g_lane_parameters(i).parameter_name = 'MIN_PACKAGE_WT') THEN
                   IF (g_lane_parameters(i).value_from IS NULL) THEN
		     g_lane_parameters(i).value_from := 0;
                   ELSIF (fnd_number.canonical_to_number(g_lane_parameters(i).value_from) <= 0) THEN
                     fte_freight_pricing_util.print_msg(l_log_level,'parcel hundredwt min_package_wt '||g_lane_parameters(i).value_from||' set to 0');
		     g_lane_parameters(i).value_from := 0;
                   ELSE
		     IF (g_lane_parameters(i).uom_code is null) THEN
                        fte_freight_pricing_util.print_msg(l_log_level,'parcel hundredwt min_package_wt uom_code null');
                        raise fte_freight_pricing_util.g_invalid_uom_code;
                     END IF;
                   END IF;
             END IF;

	     IF (g_lane_parameters(i).lane_function = 'NONE'
                 AND g_lane_parameters(i).parameter_sub_type = 'MIN_CHARGE'
                 AND g_lane_parameters(i).parameter_name = 'MIN_CHARGE_AMT') THEN
               IF (g_lane_parameters(i).value_from is not null) THEN
                 IF (fnd_number.canonical_to_number(g_lane_parameters(i).value_from) > 0 AND g_lane_parameters(i).currency_code is not null) THEN
                   g_special_flags.minimum_charge_flag := 'Y';
                 END IF;
               END IF;
             END IF;

             IF (g_lane_parameters(i).parameter_sub_type = 'DIM_WT'
                 AND g_lane_parameters(i).parameter_name = 'FACTOR'
                 AND g_lane_parameters(i).value_from IS NOT NULL) THEN
                   IF (fnd_number.canonical_to_number(g_lane_parameters(i).value_from) > 0) THEN
                      l_dim_wt_factor_ok := true;
                   END IF;
             END IF;

             IF (g_lane_parameters(i).parameter_sub_type = 'DIM_WT'
                 AND g_lane_parameters(i).parameter_name = 'WT_UOM'
                 AND g_lane_parameters(i).value_from IS NOT NULL) THEN
                      l_dim_wt_wt_uom_ok := true;
             END IF;

             IF (g_lane_parameters(i).parameter_sub_type = 'DIM_WT'
                 AND g_lane_parameters(i).parameter_name = 'VOL_UOM'
                 AND g_lane_parameters(i).value_from IS NOT NULL) THEN
                      l_dim_wt_vol_uom_ok := true;
             END IF;

             IF (g_lane_parameters(i).parameter_sub_type = 'DIM_WT'
                 AND g_lane_parameters(i).parameter_name = 'DIM_UOM'
                 AND g_lane_parameters(i).value_from IS NOT NULL) THEN
                      l_dim_wt_dim_uom_ok := true;
             END IF;

             IF (g_lane_parameters(i).parameter_sub_type = 'DIM_WT'
                 AND g_lane_parameters(i).parameter_name = 'MIN_PACKAGE_VOLUME') THEN
                   IF (g_lane_parameters(i).value_from IS NULL) THEN
		     g_lane_parameters(i).value_from := '0';
                   ELSIF (fnd_number.canonical_to_number(g_lane_parameters(i).value_from) <= 0) THEN
                     fte_freight_pricing_util.print_msg(l_log_level,'dim_wt min_package_volume '||g_lane_parameters(i).value_from||' set to 0');
		     g_lane_parameters(i).value_from := '0';
                   ELSE
		     IF (g_lane_parameters(i).uom_code is null) THEN
                        fte_freight_pricing_util.print_msg(l_log_level,'dim_wt min_package_volume uom_code null');
                        raise fte_freight_pricing_util.g_invalid_uom_code;
                     END IF;
                   END IF;
             END IF;

            fte_freight_pricing_util.print_msg(l_log_level,'end loop i='||i);
            EXIT WHEN i >=g_lane_parameters.LAST;
            i := g_lane_parameters.NEXT(i);
         END LOOP;
      END IF;
      fte_freight_pricing_util.print_msg(l_log_level,'after loop --2 ');

      IF (l_dim_wt_factor_ok AND l_dim_wt_wt_uom_ok AND l_dim_wt_vol_uom_ok AND l_dim_wt_dim_uom_ok ) THEN
          g_special_flags.dim_wt_flag :='Y';
     -- ELSE
--          load_carrier_dim_weight_params(p_lane_id => l_lane_id ,
--                                         p_service_code => p_service_code,
--                                         x_carrier_dim_weight_rec => l_carrier_dim_weight_rec ,
--                                         x_return_status => l_return_status
--                                         );
--
      END IF;

      fte_freight_pricing_util.print_msg(l_log_level,'after loop --3 ');

      IF (g_special_flags.deficit_wt_flag = 'Y') THEN
         IF (l_wt_break_cnt = 0) THEN
            raise fte_freight_pricing_util.g_weight_break_not_found;
         END IF;
         IF (l_invalid_df_wt_break_found) THEN
           raise fte_freight_pricing_util.g_invalid_wt_break;
	 END IF;
      END IF;

      fte_freight_pricing_util.print_msg(l_log_level,'after loop --4 ');

      fte_freight_pricing_util.unset_method(l_log_level,'validate_parameters');
   EXCEPTION
      WHEN fte_freight_pricing_util.g_invalid_uom_code THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_invalid_uom_code');
           fte_freight_pricing_util.unset_method(l_log_level,'validate_parameters');
      WHEN fte_freight_pricing_util.g_weight_break_not_found THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_weight_break_not_found');
           fte_freight_pricing_util.unset_method(l_log_level,'validate_parameters');
      WHEN fte_freight_pricing_util.g_invalid_wt_break THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_invalid_wt_break');
           fte_freight_pricing_util.unset_method(l_log_level,'validate_parameters');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'validate_parameters');
  END validate_parameters;

 -- End local module --

 BEGIN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   fte_freight_pricing_util.reset_dbg_vars;
   fte_freight_pricing_util.set_method(l_log_level,'initialize');
   fte_freight_pricing_util.print_msg(l_log_level,'p_lane_id: '||p_lane_id);

   fte_freight_pricing_util.set_location(p_loc=>'load_parameters');

   g_lane_parameters.DELETE;

   OPEN c_lane_param(p_lane_id);
   LOOP
     FETCH  c_lane_param INTO l_lane_param_rec;
     EXIT WHEN c_lane_param%NOTFOUND;
     --g_lane_parameters(l_lane_param_rec.parameter_instance_id) := l_lane_param_rec;
     g_lane_parameters(i) := l_lane_param_rec;
     --check_for_special_conditions(l_lane_param_rec);
     i := i +1;
   END LOOP;
   CLOSE c_lane_param;

   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'parameters before validation');
   print_params;
   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'===>g_lane_parameters.COUNT = '||g_lane_parameters.COUNT);

   g_special_flags.lane_id               := p_lane_id;
   g_special_flags.lane_function         := 'NONE';
   g_special_flags.dim_wt_flag           := 'N';
   g_special_flags.minimum_charge_flag   := 'N';
   g_special_flags.parcel_hundredwt_flag := 'N';
   g_special_flags.flat_containerwt_flag := 'Y';
   g_special_flags.deficit_wt_flag       := 'N';

   validate_parameters(x_return_status => l_return_status);

   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
       l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
               raise fte_freight_pricing_util.g_param_validation_failed;
   END IF;

   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'parameters after validation');
   print_params;
   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'===>g_lane_parameters.COUNT = '||g_lane_parameters.COUNT);
   print_special_flags;

   fte_freight_pricing_util.set_location(p_loc=>'load_rules');
   load_rules(
          p_lane_id    =>  p_lane_id,
          p_lane_function  =>  g_special_flags.lane_function,
          x_return_status  =>  l_return_status);

          IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                       raise fte_freight_pricing_util.g_load_rules_failed;
          END IF;

   print_rules;

   x_lane_function   := g_special_flags.lane_function;

   FTE_QP_ENGINE.clear_qp_input(x_return_status => l_return_status);
   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
       l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
               raise fte_freight_pricing_util.g_clear_qp_input_failed;
   END IF;

   fte_freight_pricing_util.unset_method(l_log_level,'initialize');
  EXCEPTION
    WHEN fte_freight_pricing_util.g_clear_qp_input_failed THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_clear_qp_input_failed');
         fte_freight_pricing_util.unset_method(l_log_level,'initialize');
    WHEN fte_freight_pricing_util.g_param_validation_failed THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_param_validation_failed');
         fte_freight_pricing_util.unset_method(l_log_level,'initialize');
    WHEN fte_freight_pricing_util.g_load_rules_failed THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_load_rules_failed');
         fte_freight_pricing_util.unset_method(l_log_level,'initialize');
    WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        fte_freight_pricing_util.unset_method(l_log_level,'initialize');

END initialize;


PROCEDURE calc_gross_weight (p_top_level_rec  IN fte_freight_pricing.shpmnt_content_rec_type,
                            p_target_uom   IN  VARCHAR2  DEFAULT NULL,
                            x_gross_wt     OUT NOCOPY  NUMBER,
                            x_rolledup_wt  OUT NOCOPY  NUMBER,
                            x_cont_tare_wt OUT NOCOPY  NUMBER,
                            x_uom          OUT NOCOPY  VARCHAR2,
                            x_return_status   OUT NOCOPY  VARCHAR2)
  IS
    j                NUMBER;
    l_target_uom     VARCHAR2(30);
    l_temp_wt        NUMBER :=0;
    l_temp_tare_wt   NUMBER :=0;
    l_temp_uom       VARCHAR2(30);
    l_gross_wt       NUMBER;
    l_gross_wt_uom   VARCHAR2(30);
    l_return_status  VARCHAR2(1);
  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'calc_gross_weight';
 BEGIN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   fte_freight_pricing_util.reset_dbg_vars;
   fte_freight_pricing_util.set_method(l_log_level,'calc_gross_weight');

        l_target_uom  := p_target_uom;

        IF (p_top_level_rec.container_flag = 'N') THEN
          IF (l_target_uom IS NOT NULL) THEN
               l_temp_wt  := WSH_WV_UTILS.convert_uom( p_top_level_rec.wdd_weight_uom_code,
                                                      l_target_uom,
                                                      p_top_level_rec.wdd_gross_weight,
                                                      0);  -- Within same UOM class
               --l_temp_wt  := WSH_WV_UTILS.convert_uom( p_top_level_rec.weight_uom,
                 --                                     l_target_uom,
                   --                                   p_top_level_rec.gross_weight,
                     --                                 0);  -- Within same UOM class
               l_temp_uom := l_target_uom;

          ELSE
               l_temp_wt  := p_top_level_rec.wdd_gross_weight;
               --l_temp_wt  := p_top_level_rec.gross_weight;
               l_temp_uom := p_top_level_rec.weight_uom;
          END IF;
               x_rolledup_wt  := null;
               x_gross_wt     := l_temp_wt;
               x_uom          := l_temp_uom;
        ELSE
            --  This is a container item
            j := FTE_FREIGHT_PRICING.g_rolledup_lines.FIRST;
            IF (j IS NOT NULL) THEN
            LOOP
                IF (FTE_FREIGHT_PRICING.g_rolledup_lines(j).master_container_id
                                    = p_top_level_rec.content_id) THEN

                     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'j ='||j);
                      IF (l_target_uom IS NULL) THEN
                           l_target_uom  := FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_uom;
                      END IF;

                      IF (FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_uom <> l_target_uom ) THEN
                          l_temp_wt   :=  l_temp_wt + WSH_WV_UTILS.convert_uom(FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_uom,
                                                                               l_target_uom,
                                                                               FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_quantity,
                                                                               0);  -- Within same UOM class
                      ELSE
                          l_temp_wt   := l_temp_wt + FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_quantity;
                      END IF;
                      l_temp_uom := l_target_uom;
                END IF;
            EXIT WHEN j >= FTE_FREIGHT_PRICING.g_rolledup_lines.LAST;
                      j := FTE_FREIGHT_PRICING.g_rolledup_lines.NEXT(j);
            END LOOP;
            END IF;

            x_rolledup_wt  := l_temp_wt;
            x_uom          := l_temp_uom;

            -- Now calculate the gross weight for the container

            l_gross_wt      := p_top_level_rec.wdd_gross_weight;
            l_gross_wt_uom  := p_top_level_rec.wdd_weight_uom_code;
            --l_gross_wt      := fte_freight_pricing.g_shipment_line_rows(p_top_level_rec.content_id).gross_weight;
            --l_gross_wt_uom  := fte_freight_pricing.g_shipment_line_rows(p_top_level_rec.content_id).weight_uom_code;

                IF ( l_temp_uom <> p_top_level_rec.weight_uom ) THEN
                     l_temp_tare_wt     := WSH_WV_UTILS.convert_uom( p_top_level_rec.weight_uom,
                                                                      l_temp_uom,
                                                                      p_top_level_rec.gross_weight,
                                                                      0);  -- Within same UOM class
                ELSE
                     l_temp_tare_wt     := p_top_level_rec.gross_weight;
                END IF;

            IF (l_gross_wt IS NOT NULL) THEN
                IF (l_gross_wt_uom <> l_temp_uom) THEN
                      x_gross_wt     := WSH_WV_UTILS.convert_uom(l_gross_wt_uom,
                                                                 l_temp_uom,
                                                                 l_gross_wt,
                                                                 0);  -- Within same UOM class
                ELSE
                      x_gross_wt    := l_gross_wt;
                END IF;

            ELSE

                /*
                IF ( l_temp_uom <> p_top_level_rec.weight_uom ) THEN
                     x_gross_wt     := l_temp_wt + WSH_WV_UTILS.convert_uom( p_top_level_rec.weight_uom,
                                                                      l_temp_uom,
                                                                      p_top_level_rec.gross_weight,
                                                                      0);  -- Within same UOM class
                ELSE
                     x_gross_wt     := l_temp_wt + p_top_level_rec.gross_weight;
                END IF;
                */
                x_gross_wt     := l_temp_wt + l_temp_tare_wt;

            END IF;
            x_cont_tare_wt := l_temp_tare_wt;

        END IF;

       fte_freight_pricing_util.unset_method(l_log_level,'calc_gross_weight');

      EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'calc_gross_weight');
  END calc_gross_weight;



-- This function is used while pattern processing to check if certain unsupported patterns exist
-- for the selected lane function.
-- This function checks the pattern number and the special flags. It returns 'OK' or 'NOT_OK'.
-- TODO : throw a standard error code which can be translated to a message.
-- FUNCTION detect_function_ineligible (pattern  IN NUMBER,
--                                     x_return_status OUT VARCHAR2 ) RETURN VARCHAR2;

-- Used to check for and calculate dimensional wt. for a given top level row.
-- If dimensional wt is greater than gross wt of top level row, replace gross wt with dimensional wt.
-- Also prorate new gross wt. across rollup lines (ie. bump up line wt. appropriately)
-- NOTE : dimensional wt calc. is not supported for loose items.


PROCEDURE apply_dimensional_weight (
          p_lane_id              IN NUMBER,
          p_carrier_id           IN NUMBER,
          p_service_code         IN VARCHAR2,
          p_top_level_rec        IN OUT NOCOPY   fte_freight_pricing.shpmnt_content_rec_type,
          p_rolledup_rows        IN OUT NOCOPY   fte_freight_pricing.rolledup_line_tab_type,
          x_return_status        OUT NOCOPY              VARCHAR2 )
IS
    i  NUMBER;
    j  NUMBER;

    dim_wt_enabled  VARCHAR2(1) := NULL;
    dim_wt_factor   NUMBER :=0;
    wt_uom_param    VARCHAR2(30);
    vol_uom_param   VARCHAR2(30);
    dim_uom_param   VARCHAR2(30);
    min_vol_param   NUMBER ;
    min_vol_uom     VARCHAR2(30);
    dim_wt          NUMBER :=0;
    converted_wt    NUMBER :=0;
    converted_vol   NUMBER :=0;
    original_gross_wt  NUMBER :=0;
    converted_length  NUMBER :=0;
    converted_width NUMBER :=0;
    converted_height NUMBER :=0;
    l_return_status   VARCHAR2(1);
    l_gross_wt       NUMBER :=0;
    l_rolledup_wt    NUMBER :=0;
    l_cont_tare_wt   NUMBER :=0;
    l_cont_volume    NUMBER :=0;
    l_wt_uom         VARCHAR2(30);
    l_parcel_flag    VARCHAR2(1) := 'N';
    l_lane_id    NUMBER;
    l_carrier_dim_weight_rec carrier_dim_weight_rec_type;
    l_log_level  NUMBER := fte_freight_pricing_util.G_LOG;
    l_method_name VARCHAR2(50) := 'apply_dimensional_weight';

  -- local module --
  PROCEDURE prorate_rolledup_weights(p_content_id    IN  NUMBER,
                                     --p_ratio         IN  NUMBER,
                                     p_ratio_num     IN  NUMBER,
                                     p_ratio_denom   IN  NUMBER,
                                     x_rolledup_rows IN OUT NOCOPY   fte_freight_pricing.rolledup_line_tab_type,
                                     x_return_status        OUT NOCOPY   VARCHAR2 )
  IS
     i NUMBER;

  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_return_status VARCHAR2(1);

 BEGIN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   fte_freight_pricing_util.reset_dbg_vars;
   fte_freight_pricing_util.set_method(l_log_level,'prorate_rolledup_weights');
        i := x_rolledup_rows.FIRST;
        IF (i IS NOT NULL) THEN
          LOOP
             IF (x_rolledup_rows(i).master_container_id = p_content_id
                  AND x_rolledup_rows(i).rate_basis = fte_freight_pricing.G_WEIGHT_BASIS ) THEN
                 --x_rolledup_rows(i).line_quantity := x_rolledup_rows(i).line_quantity * p_ratio;
                 x_rolledup_rows(i).line_quantity := (x_rolledup_rows(i).line_quantity * p_ratio_num)/p_ratio_denom;
             END IF;
          EXIT WHEN i >= x_rolledup_rows.LAST;
           i := x_rolledup_rows.NEXT(i);
          END LOOP;
        END IF;


        i := fte_freight_pricing.g_rolledup_lines.FIRST;
        IF (i IS NOT NULL) THEN
          LOOP
             IF (fte_freight_pricing.g_rolledup_lines(i).master_container_id = p_content_id
                  AND x_rolledup_rows(i).rate_basis = fte_freight_pricing.G_WEIGHT_BASIS ) THEN
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Old wt ='||fte_freight_pricing.g_rolledup_lines(i).line_quantity);
                 --fte_freight_pricing.g_rolledup_lines(i).line_quantity := fte_freight_pricing.g_rolledup_lines(i).line_quantity * p_ratio;
                 fte_freight_pricing.g_rolledup_lines(i).line_quantity := (fte_freight_pricing.g_rolledup_lines(i).line_quantity * p_ratio_num)/p_ratio_denom;
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'New wt ='||fte_freight_pricing.g_rolledup_lines(i).line_quantity);
             END IF;
          EXIT WHEN i >= fte_freight_pricing.g_rolledup_lines.LAST;
           i := fte_freight_pricing.g_rolledup_lines.NEXT(i);
          END LOOP;
        END IF;
   fte_freight_pricing_util.unset_method(l_log_level,'prorate_rolledup_weights');

   EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'prorate_rolledup_weights');

  END prorate_rolledup_weights;
  -- end local module --


 BEGIN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   fte_freight_pricing_util.reset_dbg_vars;
   fte_freight_pricing_util.set_method(l_log_level,'apply_dimensional_weight');

     --exception point : NO_PARAMS_FOUND
     IF (g_lane_parameters.COUNT = 0) THEN
        raise fte_freight_pricing_util.g_no_params_found;
     END IF;

    --Need to remove this check as part of R12.
    --Lane parameters can be defined at Carrier or Carrier service level
    --So this check, which verifies flag set at Lane Parameters level stops
    --from loading those carrier/service level parameters
    /*IF (g_special_flags.dim_wt_flag <> 'Y') THEN
         dim_wt_enabled := 'N';
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'dimensional weight is NOT enabled ');
         fte_freight_pricing_util.unset_method(l_log_level,'apply_dimensional_weight');
         RETURN;
     ELSE*/
         dim_wt_enabled := 'Y';
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'dimensional weight is enabled ');
     --END IF;

     -- get dimensional wt specific parameters
     IF (g_special_flags.dim_wt_flag = 'Y') THEN
         i := g_lane_parameters.FIRST;
         IF (i IS NOT NULL) THEN
         LOOP
             l_lane_id := g_lane_parameters(i).lane_id;
             IF (g_lane_parameters(i).parameter_sub_type = 'DIM_WT'
                 AND g_lane_parameters(i).parameter_name = 'FACTOR') THEN
                 dim_wt_factor := nvl(fnd_number.canonical_to_number(g_lane_parameters(i).value_from),194);
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'dim_wt_factor = '||dim_wt_factor);
             END IF;
             IF (g_lane_parameters(i).parameter_sub_type = 'DIM_WT'
                 AND g_lane_parameters(i).parameter_name = 'WT_UOM') THEN
                 wt_uom_param := g_lane_parameters(i).value_from;
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'wt_uom_param = '||wt_uom_param);
             END IF;
             IF (g_lane_parameters(i).parameter_sub_type = 'DIM_WT'
                 AND g_lane_parameters(i).parameter_name = 'VOL_UOM') THEN
                 vol_uom_param := g_lane_parameters(i).value_from;
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'vol_uom_param = '||vol_uom_param);
             END IF;
             IF (g_lane_parameters(i).parameter_sub_type = 'DIM_WT'
                 AND g_lane_parameters(i).parameter_name = 'DIM_UOM') THEN
                 dim_uom_param := g_lane_parameters(i).value_from;
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'dim_uom_param = '||dim_uom_param);
             END IF;
             IF (g_lane_parameters(i).parameter_sub_type = 'DIM_WT'
                 AND g_lane_parameters(i).parameter_name = 'MIN_PACKAGE_VOLUME') THEN
                 min_vol_param := fnd_number.canonical_to_number(g_lane_parameters(i).value_from);
                 min_vol_uom   := g_lane_parameters(i).uom_code;
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'min_vol_param = '||min_vol_param);
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'min_vol_uom = '||min_vol_uom);
             END IF;
             min_vol_uom   := g_lane_parameters(i).uom_code;
         EXIT WHEN (i >= g_lane_parameters.LAST );
             i := g_lane_parameters.NEXT(i);
         END LOOP;
         END IF;
    END IF;
     -- Added for 12i. Check if any of the dim params is null at lane level then load the params
     -- from carrier/carrier service levels.
     IF ( (dim_wt_factor IS NULL) OR (wt_uom_param IS NULL) OR (vol_uom_param IS NULL) OR
         (dim_uom_param IS NULL)  ) THEN

          --  OR (min_vol_uom IS NULL)

	--R12 Hiding Project
	dim_wt_enabled := 'N';

	--R12 Hiding Project
	/*
          load_carrier_dim_weight_params(p_lane_id => l_lane_id ,
                                         p_carrier_id => p_carrier_id,
                                         p_service_code => p_service_code,
                                         x_carrier_dim_weight_rec => l_carrier_dim_weight_rec ,
                                         x_return_status => l_return_status
                                         );
          IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
             l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
             raise fte_freight_pricing_util.g_no_params_found;
          END IF;

          IF ( (l_carrier_dim_weight_rec.dim_factor IS NOT NULL) AND
              (l_carrier_dim_weight_rec.dim_weight_uom IS NOT NULL) AND
              (l_carrier_dim_weight_rec.dim_volume_uom IS NOT NULL) AND
              (l_carrier_dim_weight_rec.dim_dimension_uom IS NOT NULL)
               ) THEN
                dim_wt_factor := nvl(l_carrier_dim_weight_rec.dim_factor,194);
                wt_uom_param  := l_carrier_dim_weight_rec.dim_weight_uom;
                vol_uom_param := l_carrier_dim_weight_rec.dim_volume_uom;
                dim_uom_param := l_carrier_dim_weight_rec.dim_dimension_uom;
                min_vol_param := l_carrier_dim_weight_rec.dim_min_volume;
                dim_wt_enabled := 'Y';
          ELSE
               dim_wt_enabled := 'N';
          END IF;
	  */
      END IF ;


      fte_freight_pricing_util.print_msg(l_log_level,'After loading . dim_wt_enabled='||dim_wt_enabled);
      fte_freight_pricing_util.print_msg(l_log_level,'p_top_level_rec.length='||p_top_level_rec.length);
      fte_freight_pricing_util.print_msg(l_log_level,'p_top_level_rec.width ='||p_top_level_rec.width );
      fte_freight_pricing_util.print_msg(l_log_level,'p_top_level_rec.height='||p_top_level_rec.height);
      fte_freight_pricing_util.print_msg(l_log_level,'min_vol_param='||min_vol_param);

     --check if container/loose item volume is greater than min package volume parameter.
     --if volume is null and length-width-height are not null
     --then L*W*H should be used instead AG 5/29

     --IF (dim_wt_enabled = 'Y' AND p_top_level_rec.volume IS NOT NULL
      --      AND nvl(min_vol_param,0) >0 AND min_vol_uom IS NOT NULL ) THEN
     --IF (dim_wt_enabled = 'Y' AND nvl(min_vol_param,0) >0 AND min_vol_uom IS NOT NULL ) THEN

     IF (dim_wt_enabled = 'Y' AND  nvl(min_vol_param,0) >= 0  ) THEN

     fte_freight_pricing_util.print_msg(l_log_level,'dim_wt_enabled and min_vol_param is='||min_vol_param||' and min_vol_uom is='||min_vol_uom);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'p_top_level_rec.volume = '||p_top_level_rec.volume);

      IF p_top_level_rec.volume IS NOT NULL THEN
     fte_freight_pricing_util.print_msg(l_log_level,'use volume');
        -- Use volume
           IF (p_top_level_rec.volume_uom <> min_vol_uom ) THEN
              --convert input vol uom to param vol uom
               converted_vol := WSH_WV_UTILS.convert_uom(p_top_level_rec.volume_uom,
                                                       min_vol_uom,
                                                       p_top_level_rec.volume,
                                                       0);  -- Within same UOM class
           ELSE
                converted_vol := p_top_level_rec.volume;
           END IF;

      ELSIF (p_top_level_rec.length IS NOT NULL AND p_top_level_rec.width IS NOT NULL AND p_top_level_rec.height IS NOT NULL) THEN
     fte_freight_pricing_util.print_msg(l_log_level,'use L*W*H');
        -- use L*W*H
           IF (p_top_level_rec.dim_uom <> dim_uom_param ) THEN
              --convert input wt uom to param wt uom
               converted_length := WSH_WV_UTILS.convert_uom(p_top_level_rec.dim_uom,
                                                       dim_uom_param,
                                                       nvl(p_top_level_rec.length,0),
                                                       0);  -- Within same UOM class
               converted_width := WSH_WV_UTILS.convert_uom(p_top_level_rec.dim_uom,
                                                       dim_uom_param,
                                                       nvl(p_top_level_rec.width,0),
                                                       0);  -- Within same UOM class

               converted_height := WSH_WV_UTILS.convert_uom(p_top_level_rec.dim_uom,
                                                       dim_uom_param,
                                                       nvl(p_top_level_rec.height,0),
                                                       0);  -- Within same UOM class
           ELSE
               converted_length := p_top_level_rec.length;
               converted_width  := p_top_level_rec.width;
               converted_height := p_top_level_rec.height;

           END IF;
           l_cont_volume := converted_length*converted_width*converted_height;

           -- The assumption here is that dim_uom and vol_uom parameter for dim_wt are in synch.

           IF ( vol_uom_param <> min_vol_uom ) THEN
                --convert input vol uom to param vol uom
                converted_vol := WSH_WV_UTILS.convert_uom(vol_uom_param,
                                              min_vol_uom,
                                              l_cont_volume,
                                              --converted_length*converted_width*converted_height,
                                              0);  -- Within same UOM class
           ELSE
                --converted_vol := converted_length*converted_width*converted_height;
                converted_vol := l_cont_volume;
           END IF;

      END IF;
     END IF;

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'converted_vol = '||converted_vol);

      IF (converted_vol <= min_vol_param) THEN
         --fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'dimensional weight is less than min package wt ');
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Package volume is less than minimum package volume parameter for dimensional wt ');
         fte_freight_pricing_util.unset_method(l_log_level,'apply_dimensional_weight');
         RETURN;
      END IF;

IF (dim_wt_enabled = 'Y' ) THEN

     --calculate gross_wt and rolledup wt converted to wt_uom_param
     calc_gross_weight (p_top_level_rec   => p_top_level_rec,
                        p_target_uom      => wt_uom_param,
                        x_gross_wt        => l_gross_wt,
                        x_rolledup_wt     => l_rolledup_wt,
                        x_cont_tare_wt    => l_cont_tare_wt,
                        x_uom             => l_wt_uom,
                        x_return_status   => l_return_status);

     fte_freight_pricing_util.set_location(p_loc=>'after calc_gross_weight ');
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_calc_gross_wt_failed;
           ELSE
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_gross_wt = '||l_gross_wt);
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_rolledup_wt = '||l_rolledup_wt);
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_wt_uom = '||l_wt_uom);
           END IF;

     -- Now calculate the dimensional wt from the lane parameters

     IF (p_top_level_rec.volume IS NOT NULL) THEN
        -- Use volume
           IF (p_top_level_rec.volume_uom <> vol_uom_param ) THEN
              --convert input vol uom to param vol uom
               converted_vol := WSH_WV_UTILS.convert_uom(p_top_level_rec.volume_uom,
                                                       vol_uom_param,
                                                       p_top_level_rec.volume,
                                                       0);  -- Within same UOM class
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'converted_vol = '||converted_vol);
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'vol_uom_param = '||vol_uom_param);
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'dim_wt_factor = '||dim_wt_factor);
               dim_wt := (converted_vol)/dim_wt_factor;
           ELSE
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'vol = '||p_top_level_rec.volume);
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'vol_uom_param = '||vol_uom_param);
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'dim_wt_factor = '||dim_wt_factor);
               dim_wt := (p_top_level_rec.volume)/dim_wt_factor;
           END IF;
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'dim_wt = '||dim_wt);
     ELSIF (p_top_level_rec.length IS NOT NULL AND p_top_level_rec.width IS NOT NULL AND p_top_level_rec.height IS NOT NULL) THEN
        -- use L*W*H
           IF (p_top_level_rec.dim_uom <> dim_uom_param ) THEN
              --convert input wt uom to param wt uom
               converted_length := WSH_WV_UTILS.convert_uom(p_top_level_rec.dim_uom,
                                                       dim_uom_param,
                                                       nvl(p_top_level_rec.length,0),
                                                       0);  -- Within same UOM class
               converted_width := WSH_WV_UTILS.convert_uom(p_top_level_rec.dim_uom,
                                                       dim_uom_param,
                                                       nvl(p_top_level_rec.width,0),
                                                       0);  -- Within same UOM class

               converted_height := WSH_WV_UTILS.convert_uom(p_top_level_rec.dim_uom,
                                                       dim_uom_param,
                                                       nvl(p_top_level_rec.height,0),
                                                       0);  -- Within same UOM class

               dim_wt := (converted_length*converted_width*converted_height)/dim_wt_factor;
           ELSE
               dim_wt := (p_top_level_rec.length * p_top_level_rec.width * p_top_level_rec.height)/dim_wt_factor;
           END IF;

     ELSE
        -- Can't process. No volume or L-W-H found.
        raise fte_freight_pricing_util.g_no_volume_found;
     END IF;

     IF (p_top_level_rec.container_flag = 'N') THEN
        --the gross wt is the original wt
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'content_id = '||p_top_level_rec.content_id);
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'dim_wt = '||dim_wt);
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_gross_wt = '||l_gross_wt);

         IF ( dim_wt > l_gross_wt) THEN
            -- increase the top level gross wt by the ratio of dim_wt to l_gross_wt (original weight)
            -- dim_wt and l_gross_wt should already be in the same uom
            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Applying dimensional wt');
            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Old wt ='||p_top_level_rec.gross_weight);
            p_top_level_rec.gross_weight := (p_top_level_rec.gross_weight * dim_wt)/l_gross_wt;
            p_top_level_rec.wdd_gross_weight := (p_top_level_rec.wdd_gross_weight * dim_wt)/l_gross_wt;
            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'New wt ='||p_top_level_rec.gross_weight);

         ELSE
            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'No need to apply dimensional wt ');
         END IF;

    ELSE
         -- this is a container

         l_parcel_flag := isParcel;
         IF (l_parcel_flag = 'Y') THEN
             --for parcel we need to consider the gross weight calculated above
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'this is a parcel case');
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'content_id = '||p_top_level_rec.content_id);
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'dim_wt = '||dim_wt);
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_gross_wt = '||l_gross_wt);
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_rolledup_wt = '||l_rolledup_wt);

             IF ( dim_wt > l_gross_wt) THEN
                fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Applying dimensional wt');
                -- increase the rolled up lines and the top level gross wt by the ratio
                -- l_rolledup_wt and dim_wt should already be in the same uom

                fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Old wt ='||p_top_level_rec.gross_weight);
                p_top_level_rec.gross_weight := (p_top_level_rec.gross_weight * dim_wt)/l_gross_wt;
         	p_top_level_rec.wdd_gross_weight := (p_top_level_rec.wdd_gross_weight * dim_wt)/l_gross_wt;
                fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'New wt ='||p_top_level_rec.gross_weight);

                --loop over the rolled up lines and prorate
                prorate_rolledup_weights(p_content_id    => p_top_level_rec.content_id,
                                     --p_ratio             => (dim_wt/l_gross_wt),
                                     p_ratio_num         => dim_wt,
                                     p_ratio_denom       => l_gross_wt,
                                     x_rolledup_rows     => p_rolledup_rows,
                                     x_return_status     => l_return_status);

                IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                     l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_prorate_failed;
                END IF;

             ELSE
                fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'No need to apply dimensional wt ');
             END IF;

         ELSE
             --for other than parcel we need to consider the rolled up wt only
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'this is not a parcel case');
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'content_id = '||p_top_level_rec.content_id);
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'dim_wt = '||dim_wt);
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_gross_wt = '||l_gross_wt);

             --IF ( dim_wt > l_rolledup_wt) THEN
             IF ( dim_wt > l_gross_wt) THEN
                fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Applying dimensional wt');
                -- increase the rolled up lines by the ration
                -- l_rolledup_wt and dim_wt should already be in the same uom

         	p_top_level_rec.wdd_gross_weight := (p_top_level_rec.wdd_gross_weight * dim_wt)/l_gross_wt;

                --loop over the rolled up lines and prorate
                prorate_rolledup_weights(p_content_id    => p_top_level_rec.content_id,
                                     --p_ratio             => (dim_wt/l_rolledup_wt),
                                     --p_ratio             => (dim_wt/l_gross_wt),
                                     p_ratio_num         => dim_wt,
                                     p_ratio_denom       => l_gross_wt,
                                     --p_ratio             => (dim_wt/l_cont_tare_wt),
                                     x_rolledup_rows     => p_rolledup_rows,
                                     x_return_status     => l_return_status);

                IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                     l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_prorate_failed;
                END IF;

             ELSE
                fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'No need to apply dimensional wt ');
             END IF;

         END IF;
   END IF;
ELSE
   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,' dim_wt_enabled is N .No need to apply dimensional wt ');
END IF;

   fte_freight_pricing_util.unset_method(l_log_level,'apply_dimensional_weight');

   EXCEPTION
      WHEN fte_freight_pricing_util.g_no_params_found THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'no_parameters found');
           fte_freight_pricing_util.unset_method(l_log_level,'apply_dimensional_weight');
      WHEN fte_freight_pricing_util.g_no_weights_found THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_no_weights_found ');
           fte_freight_pricing_util.unset_method(l_log_level,'apply_dimensional_weight');
      WHEN fte_freight_pricing_util.g_no_volume_found THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_no_volume_found ');
           fte_freight_pricing_util.unset_method(l_log_level,'apply_dimensional_weight');
      WHEN fte_freight_pricing_util.g_calc_gross_wt_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_calc_gross_wt_failed ');
           fte_freight_pricing_util.unset_method(l_log_level,'apply_dimensional_weight');
      WHEN fte_freight_pricing_util.g_prorate_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_no_volume_found ');
           fte_freight_pricing_util.unset_method(l_log_level,'apply_dimensional_weight');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'apply_dimensional_weight');


END apply_dimensional_weight;


FUNCTION isLTL RETURN VARCHAR2 IS
l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
 BEGIN
     IF (g_special_flags.lane_function = 'LTL') THEN
        RETURN 'Y';
     ELSE
        RETURN 'N';
     END IF;
END;

FUNCTION isParcel RETURN VARCHAR2 IS
l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
 BEGIN
     IF (g_special_flags.lane_function = 'PARCEL') THEN
        RETURN 'Y';
     ELSE
        RETURN 'N';
     END IF;
END;

--Added for 12i to support dim weights are carrier service and carrier level
PROCEDURE load_carrier_dim_weight_params(p_lane_id                IN  NUMBER ,
                                         p_carrier_id             IN  NUMBER,
                                         p_service_code           IN  VARCHAR2,
                                         x_carrier_dim_weight_rec OUT NOCOPY carrier_dim_weight_rec_type ,
                                         x_return_status          OUT NOCOPY VARCHAR2
                                         )
IS
  CURSOR c_carrier_dim_params(c_carrier_id IN NUMBER)  IS
  SELECT
  wc.dim_dimensional_factor,
  wc.dim_weight_uom,
  wc.dim_volume_uom,
  wc.dim_dimension_uom,
  wc.dim_min_pack_vol
  FROM
    wsh_carriers wc
  WHERE
   wc.carrier_id=p_carrier_id;

  CURSOR c_carrier_service_dim_params(c_carrier_id IN NUMBER, c_service_code IN VARCHAR2 ) IS
  SELECT
  wcs.dim_dimensional_factor,
  wcs.dim_weight_uom,
  wcs.dim_volume_uom,
  wcs.dim_dimension_uom,
  wcs.dim_min_pack_vol
  FROM
    wsh_carrier_services wcs
  WHERE
      wcs.carrier_id = p_carrier_id
  AND wcs.service_level = p_service_code;

  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'load_carrier_dim_weight_params';
  l_carrier_dim_factors carrier_dim_weight_rec_type;

BEGIN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    fte_freight_pricing_util.set_method(l_log_level,l_method_name);

    fte_freight_pricing_util.print_msg(l_log_level,'p_carrier_id='||p_carrier_id);
    fte_freight_pricing_util.print_msg(l_log_level,'p_service_code='||p_service_code);

    IF ( (p_carrier_id IS NOT NULL) AND (p_service_code IS NOT NULL) ) THEN
      OPEN c_carrier_service_dim_params (p_carrier_id , p_service_code);
      FETCH c_carrier_service_dim_params INTO l_carrier_dim_factors;
      -- IF Parameters not found, load them from carrier
      IF( ( c_carrier_service_dim_params%NOTFOUND ) OR
          (l_carrier_dim_factors.dim_factor IS NULL) OR (l_carrier_dim_factors.dim_weight_uom IS NULL) OR
          (l_carrier_dim_factors.dim_volume_uom IS NULL) OR (l_carrier_dim_factors.dim_dimension_uom IS NULL)

         ) THEN
             fte_freight_pricing_util.print_msg(l_log_level,'Service Level params not found. Loading from Carrier Level');

             OPEN c_carrier_dim_params (p_carrier_id);
             FETCH c_carrier_dim_params INTO l_carrier_dim_factors;
             IF c_carrier_dim_params%NOTFOUND THEN
               raise fte_freight_pricing_util.g_no_params_found;
             END IF;
             CLOSE c_carrier_dim_params;
      END IF;
      CLOSE c_carrier_service_dim_params;
    END IF;

    fte_freight_pricing_util.print_msg(l_log_level,'l_carrier_dim_factors.dim_factor ='||l_carrier_dim_factors.dim_factor);
    fte_freight_pricing_util.print_msg(l_log_level,'l_carrier_dim_factors.dim_weight_uom ='||l_carrier_dim_factors.dim_weight_uom);
    fte_freight_pricing_util.print_msg(l_log_level,'l_carrier_dim_factors.dim_dimension_uom ='||l_carrier_dim_factors.dim_dimension_uom);
    fte_freight_pricing_util.print_msg(l_log_level,'l_carrier_dim_factors.dim_volume_uom ='||l_carrier_dim_factors.dim_volume_uom);
    fte_freight_pricing_util.print_msg(l_log_level,'l_carrier_dim_factors.dim_min_volume ='||l_carrier_dim_factors.dim_min_volume);

    x_carrier_dim_weight_rec := l_carrier_dim_factors;


   fte_freight_pricing_util.unset_method(l_log_level,'load_carrier_dim_weight_params');

  EXCEPTION
      WHEN fte_freight_pricing_util.g_no_params_found THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'no_dim_parameters found');
           fte_freight_pricing_util.unset_method(l_log_level,'load_carrier_dim_weight_params');

END load_carrier_dim_weight_params;

-- This procedure is used to calculate the total wt of the top level rows
-- get total shipment wt. Should take care of conversions.
-- Considers the wt. of the rollup lines instead of the gross wt of the container.
-- used for LTL
PROCEDURE  get_total_shipment_weight(p_top_level_rows    IN   fte_freight_pricing.shpmnt_content_tab_type,
                                         x_total_wt          OUT NOCOPY   NUMBER,
                                         x_wt_uom            OUT NOCOPY   VARCHAR2,
                                         x_return_status     OUT NOCOPY   VARCHAR2)
IS
  i                    NUMBER;
  j                    NUMBER;
  l_temp_wt            NUMBER :=0;
  l_target_uom         VARCHAR2(30) := NULL;
  l_cnt                NUMBER :=0;
  l_content_id         NUMBER;
  l_return_status      VARCHAR2(1);
l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'get_total_shipment_weight';
 BEGIN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    fte_freight_pricing_util.reset_dbg_vars;
    fte_freight_pricing_util.set_method(l_log_level,'get_total_shipment_weight');

    -- loop over all top level rows
    -- get the top level row
    --     for the top level row, loop through all rollup lines and add up line_quantities
    --      convert the uoms if lines have different uoms
    --      the first wt uom encountered becomes the source uom for conversions


    -- first figure out the target uom
    l_target_uom := NULL;
    i := p_top_level_rows.FIRST;
    --j := FTE_FREIGHT_PRICING.g_rolledup_lines.FIRST;
    l_temp_wt :=0;
    IF (i IS NOT NULL) THEN
    LOOP
        l_content_id := p_top_level_rows(i).content_id;
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Top level Id : '||l_content_id);

        -- if top level row is not a container, use its gross wt
        IF (p_top_level_rows(i).container_flag = 'N') THEN

             IF (l_target_uom IS NULL) THEN
                 l_target_uom  := p_top_level_rows(i).weight_uom;
             END IF;

             IF (p_top_level_rows(i).weight_uom <> l_target_uom) THEN
                 l_temp_wt   :=  l_temp_wt + WSH_WV_UTILS.convert_uom(p_top_level_rows(i).weight_uom,
                                                                      l_target_uom,
                                                                      p_top_level_rows(i).gross_weight,
                                                                      0);  -- Within same UOM class
             ELSE
                 l_temp_wt := l_temp_wt + p_top_level_rows(i).gross_weight;
             END IF;
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Gross wt in loose item : '||p_top_level_rows(i).gross_weight);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Temp wt in loose item : '||l_temp_wt);


        ELSE
             -- top level row is a container, so get its rolledup lines

            j := FTE_FREIGHT_PRICING.g_rolledup_lines.FIRST;
            IF (j IS NOT NULL) THEN
            LOOP
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'g_rolledup_line id : '||FTE_FREIGHT_PRICING.g_rolledup_lines(j).delivery_detail_id);
                 IF (FTE_FREIGHT_PRICING.g_rolledup_lines(j).master_container_id = l_content_id) THEN

                      IF (l_target_uom IS NULL) THEN
                           l_target_uom  := FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_uom;
                      END IF;

                      IF (FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_uom <> l_target_uom ) THEN
                          l_temp_wt   :=  l_temp_wt + WSH_WV_UTILS.convert_uom(FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_uom,
                                                                               l_target_uom,
                                                                               FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_quantity,
                                                                               0);  -- Within same UOM class
                      ELSE
                          l_temp_wt   := l_temp_wt + FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_quantity;
                      END IF;
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Gross wt in container item : '||FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_quantity);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Temp wt in container item : '||l_temp_wt);
                 END IF;
            EXIT WHEN j >= FTE_FREIGHT_PRICING.g_rolledup_lines.LAST;
                j := FTE_FREIGHT_PRICING.g_rolledup_lines.NEXT(j);
           END LOOP;
           END IF;
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Temp wt afterloop container item : '||l_temp_wt);

       END IF;  -- container_flag

    EXIT WHEN i >= p_top_level_rows.LAST;
        i := p_top_level_rows.NEXT(i);
    END LOOP;
    END IF;

        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Temp wt afterloop : '||l_temp_wt);

    IF (l_target_uom IS NULL ) THEN
        raise fte_freight_pricing_util.g_weight_uom_not_found;
    END IF;

    IF (l_temp_wt = 0) THEN
          -- something wrong
          raise fte_freight_pricing_util.g_total_shipment_weight_failed;
    END IF;

    x_total_wt := l_temp_wt;
    x_wt_uom   := l_target_uom;

 fte_freight_pricing_util.unset_method(l_log_level,'get_total_shipment_weight');
 EXCEPTION
      WHEN fte_freight_pricing_util.g_weight_uom_not_found THEN
           x_return_status :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_weight_uom_not_found');
           fte_freight_pricing_util.unset_method(l_log_level,'get_total_shipment_weight');
      WHEN fte_freight_pricing_util.g_total_shipment_weight_failed THEN
           x_return_status :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_total_shipment_weight_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'get_total_shipment_weight');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'get_total_shipment_weight');

END get_total_shipment_weight;

-- This procedure is used to calculate the total wt of the top level rows
-- get total shipment wt. Should take care of conversions. This overloaded method bumps up individual
-- package wts to the min. package wt before getting the total.
-- used for parcel hundred wt.

PROCEDURE  get_total_shipment_weight  (p_top_level_rows    IN   fte_freight_pricing.shpmnt_content_tab_type,
                                       p_min_package_wt    IN   NUMBER,
                                       p_min_wt_uom        IN   VARCHAR2,
                                       x_total_wt          OUT NOCOPY   NUMBER,
                                       x_wt_uom            OUT NOCOPY   VARCHAR2,
                                       x_return_status     OUT NOCOPY   VARCHAR2)
 IS

   l_rolledup_wt      NUMBER;
   l_rolledup_uom     VARCHAR2(30);
   l_curr_wt          NUMBER;
   l_curr_uom         VARCHAR2(30);
   l_highest_wt          NUMBER;
   l_highest_uom         VARCHAR2(30);
   l_cum_wt           NUMBER;
   l_cum_uom          VARCHAR2(30);
   l_content_id         NUMBER;
   i     NUMBER;
   l_return_status  VARCHAR2(1);

   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'get_total_shipment_weight';
   -- Local module
   PROCEDURE add_weights ( p_orig_wt      IN NUMBER,
                           p_orig_uom     IN VARCHAR2,
                           p_add_wt       IN NUMBER,
                           p_add_uom      IN VARCHAR2,
                           p_target_uom   IN VARCHAR2 DEFAULT NULL,
                           x_new_wt       OUT NOCOPY  NUMBER,
                           x_new_uom      OUT NOCOPY  VARCHAR2)
  IS
      l_temp_wt NUMBER :=0;
      l_new_wt   NUMBER;
      l_new_uom  VARCHAR2(30);

  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'add_weights';
 BEGIN

      fte_freight_pricing_util.set_method(l_log_level,'add_weights');
      IF (p_orig_uom = p_add_uom) THEN
         l_new_wt  := p_orig_wt + p_add_wt;
         l_new_uom := p_orig_uom;
      ELSE
         l_new_wt  := p_orig_wt + WSH_WV_UTILS.convert_uom(p_add_uom,  --from
                                                           p_orig_uom, --to
                                                           p_add_wt,
                                                           0);  -- Within same UOM class
         l_new_uom := p_orig_uom;
      END IF;

      IF (p_target_uom IS NOT NULL AND p_target_uom <> l_new_uom) THEN
         x_new_wt  := WSH_WV_UTILS.convert_uom(l_new_uom,  --from
                                               p_target_uom, --to
                                               l_new_wt,
                                               0);  -- Within same UOM class
         x_new_uom := p_target_uom;
      ELSE
         x_new_wt := l_new_wt;
         x_new_uom := l_new_uom;
      END IF;

      fte_freight_pricing_util.unset_method(l_log_level,'add_weights');
  END ;

  PROCEDURE highest_of  (p_wt_1           IN NUMBER,
                         p_uom_1          IN VARCHAR2,
                         p_wt_2           IN NUMBER,
                         p_uom_2          IN VARCHAR2,
                         p_target_uom     IN VARCHAR2,
                         x_wt             OUT NOCOPY  NUMBER,
                         x_uom            OUT NOCOPY  VARCHAR2)
  IS
      l_new_wt_2    NUMBER :=0;
  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'highest_of';
 BEGIN
      fte_freight_pricing_util.set_method(l_log_level,'highest_of');
      IF (p_uom_1 = p_uom_2) THEN
            x_wt  := GREATEST(p_wt_1,p_wt_2);
            x_uom := p_uom_1;
      ELSE
           l_new_wt_2   :=  WSH_WV_UTILS.convert_uom(p_uom_2,
                                                     p_uom_1,
                                                     p_wt_2,
                                                     0);  -- Within same UOM class
           IF (p_wt_1 >= l_new_wt_2 ) THEN
                x_wt  := p_wt_1;
                x_uom := p_uom_1;
           ELSE
                x_wt  := p_wt_2;
                x_uom := p_uom_2;
           END IF;

      END IF;

      IF (p_target_uom IS NOT NULL AND p_target_uom <> x_uom) THEN
           x_wt     :=  WSH_WV_UTILS.convert_uom(x_uom,
                                                 p_target_uom,
                                                 x_wt,
                                                 0);  -- Within same UOM class
           x_uom    := p_target_uom;

      END IF;

      fte_freight_pricing_util.unset_method(l_log_level,'highest_of');
  END highest_of;


  PROCEDURE get_rolledup_wts (p_content_id   IN NUMBER,
                              p_target_uom  IN  VARCHAR2  DEFAULT NULL,
                              x_wt          OUT NOCOPY  NUMBER,
                              x_uom         OUT NOCOPY  VARCHAR2)
  IS
    j                NUMBER;
    l_target_uom     VARCHAR2(30);
    l_temp_wt        NUMBER :=0;
    l_temp_uom       VARCHAR2(30);
  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'get_rolledup_wts';
 BEGIN
        fte_freight_pricing_util.set_method(l_log_level,'get_rolledup_wts');
        l_target_uom  := p_target_uom;
        j := FTE_FREIGHT_PRICING.g_rolledup_lines.FIRST;
        IF ( j IS NOT NULL) THEN
        LOOP
            IF (FTE_FREIGHT_PRICING.g_rolledup_lines(j).master_container_id = p_content_id) THEN

                    fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'j ='||j);
                      IF (l_target_uom IS NULL) THEN
                           l_target_uom  := FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_uom;
                      END IF;

                      IF (FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_uom <> l_target_uom ) THEN
                          l_temp_wt   :=  l_temp_wt + WSH_WV_UTILS.convert_uom(FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_uom,
                                                                               l_target_uom,
                                                                               FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_quantity,
                                                                               0);  -- Within same UOM class
                      ELSE
                          l_temp_wt   := l_temp_wt + FTE_FREIGHT_PRICING.g_rolledup_lines(j).line_quantity;
                      END IF;
            END IF;
       EXIT WHEN j >= FTE_FREIGHT_PRICING.g_rolledup_lines.LAST;
                 j := FTE_FREIGHT_PRICING.g_rolledup_lines.NEXT(j);
       END LOOP;
       END IF;

       fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_temp_wt ='||l_temp_wt);
       fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_target_uom = '||l_target_uom);
       x_wt  := l_temp_wt;
       x_uom := l_target_uom;

       fte_freight_pricing_util.unset_method(l_log_level,'get_rolledup_wts');
  EXCEPTION
    WHEN others THEN
      fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
      fte_freight_pricing_util.unset_method(l_log_level, l_method_name);
  END get_rolledup_wts;


 BEGIN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    fte_freight_pricing_util.reset_dbg_vars;
    fte_freight_pricing_util.set_method(l_log_level,'get_total_shipment_weight-2');

   -- TODO :  if this is a container  -->
   --         if g_shipment_line_rows(toplevel content_id).gross_wt is null
   --         total_wt  = total wt + sum of rolledup lines net wt + top level row.grosswt   --(1)
   --        end if
   --       if g_shipment_line_rows(toplevel content_id).gross_wt is not null
   --            choose highest of this gross_wt and the total calculated from the rollup line as in (1)
   --       end if
   --       if this is a loose item -->
   --          total_wt = total_wt + top level row.gross wt
   --       end if
   --       take care of uom conversions at all points
   --   IMP NOTE : top_level_row.grosswt is always the actual wt of the detail. So for container, this is actually
   --          the item wt from msi.
   --          The user changeable gross weight of the container has to be obtained from the g_shipment_line_rows.
   --  This will make the total wt calculation consistent with engine row creation.


    i := p_top_level_rows.FIRST;

    IF (p_min_wt_uom IS NULL) THEN
       l_cum_uom   := p_top_level_rows(i).weight_uom;
    ELSE
       l_cum_uom   := p_min_wt_uom;
    END IF;


    IF (l_cum_uom IS NULL) THEN
        raise fte_freight_pricing_util.g_weight_uom_not_found;
    END IF;

    i          := p_top_level_rows.FIRST;
    l_curr_wt  := 0;
    l_cum_wt   := 0;
    LOOP
        l_content_id := p_top_level_rows(i).content_id;
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_content_id = '||l_content_id);

        IF (p_top_level_rows(i).container_flag = 'N') THEN
            IF (l_cum_uom <> p_top_level_rows(i).weight_uom ) THEN
               l_curr_wt  := WSH_WV_UTILS.convert_uom(p_top_level_rows(i).weight_uom,
                                                      l_cum_uom,
                                                      p_top_level_rows(i).gross_weight,
                                                      0);  -- Within same UOM class
               l_curr_uom := l_cum_uom;
            ELSE
               l_curr_wt  := p_top_level_rows(i).gross_weight;
               l_curr_uom := l_cum_uom;
            END IF;

        ELSE
             -- get rolledup wt converted to l_cum_uom
             get_rolledup_wts(l_content_id,
                              l_cum_uom,
                              l_rolledup_wt, l_rolledup_uom);
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'       l_rolledup_wt = '||l_rolledup_wt);

             --  add weights : l_curr_wt := l_rolledup_wt + p_top_level_rows(i).gross_weight;
             add_weights(p_orig_wt=>l_rolledup_wt,p_orig_uom=>l_cum_uom,
                         p_add_wt=>p_top_level_rows(i).gross_weight, p_add_uom=>p_top_level_rows(i).weight_uom,
                         x_new_wt=>l_curr_wt,x_new_uom=>l_curr_uom);

             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'       l_curr_wt = '||l_curr_wt);

            IF (FTE_FREIGHT_PRICING.g_shipment_line_rows(l_content_id).gross_weight IS NOT NULL) THEN

              -- choose the higher of the g_shipment_row.gross_wt and the above wt.
                 highest_of (FTE_FREIGHT_PRICING.g_shipment_line_rows(l_content_id).gross_weight,
                             FTE_FREIGHT_PRICING.g_shipment_line_rows(l_content_id).weight_uom_code,
                             l_curr_wt,
                             l_cum_uom,
                             l_cum_uom,  --target uom
                             l_highest_wt,
                             l_highest_uom);
                             --l_curr_wt,
                             --l_curr_uom);

		l_curr_wt := l_highest_wt;
		l_curr_uom := l_highest_uom;
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'       highest :l_curr_wt = '||l_curr_wt);

            END IF;
        END IF;

        --bump up wt if less than p_min_package_wt (take highest of curr wt and min package wt )
         IF (p_min_package_wt IS NOT NULL AND p_min_package_wt > 0) THEN
                 highest_of (l_curr_wt,
                             l_cum_uom,
                             p_min_package_wt,
                             p_min_wt_uom,
                             l_cum_uom,  --target uom
                             l_highest_wt,
                             l_highest_uom);
                             --l_curr_wt,
                             --l_curr_uom);

		l_curr_wt := l_highest_wt;
		l_curr_uom := l_highest_uom;
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'       highest :l_curr_wt = '||l_curr_wt);
        END IF;

        l_cum_wt := l_cum_wt + l_curr_wt;

    EXIT WHEN i >= p_top_level_rows.LAST;
       i := p_top_level_rows.NEXT(i);
    END LOOP;


    IF (l_cum_wt = 0) THEN
          -- something wrong
          raise fte_freight_pricing_util.g_total_shipment_weight_failed;
    END IF;

    x_total_wt := l_cum_wt;
    x_wt_uom   := l_cum_uom;

 fte_freight_pricing_util.unset_method(l_log_level,'get_total_shipment_weight-2');
 EXCEPTION
      WHEN fte_freight_pricing_util.g_weight_uom_not_found THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_weight_uom_not_found');
           fte_freight_pricing_util.unset_method(l_log_level,'get_total_shipment_weight-2');
      WHEN fte_freight_pricing_util.g_total_shipment_weight_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_total_shipment_weight_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'get_total_shipment_weight-2');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'get_total_shipment_weight-2');
END get_total_shipment_weight;


PROCEDURE  get_bumped_up_package_weight  (p_wt                IN   NUMBER,
                                          p_wt_uom            IN   VARCHAR2,
                                          p_min_package_wt    IN   NUMBER,
                                          p_min_wt_uom        IN   VARCHAR2,
                                          x_new_wt            OUT NOCOPY   NUMBER,
                                          x_new_wt_uom        OUT NOCOPY   VARCHAR2,
                                          x_bump              OUT NOCOPY   VARCHAR2,
                                          x_return_status     OUT NOCOPY   VARCHAR2)
IS
  i     NUMBER;
  l_temp_min_wt   NUMBER;
  l_temp_min_uom  VARCHAR2(30);
  l_return_status  VARCHAR2(1);

l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'get_bumped_up_package_weight';
 BEGIN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    fte_freight_pricing_util.reset_dbg_vars;
    fte_freight_pricing_util.set_method(l_log_level,'get_bumped_up_package_weight');

    IF (p_min_wt_uom IS NULL OR p_wt_uom IS NULL) THEN
        --raise fte_freight_pricing_util.g_weight_uom_not_found;

	-- since it's been decided later on that hundredwt enabling is not controled
	-- by the parameter, instead is controled by whether top level row count is
	-- is greater than 1, we cannot always assume that p_min_package_wt and
	-- p_min_wt_uom is set
	-- if the parameter is not setup, we just assume that the min_package weight is 0
	-- and min_wt_uom is the same as line wt uom
	-- so the new wt is the same as line wt
	x_new_wt := p_wt;
	x_new_wt_uom := p_wt_uom;

	fte_freight_pricing_util.unset_method(l_log_level,'get_bumped_up_package_weight');

	return;
    END IF;

    if (p_wt_uom <> p_min_wt_uom) THEN
      --convert min wt uom to current uom
                l_temp_min_wt   :=  WSH_WV_UTILS.convert_uom(p_min_wt_uom,
                                                         p_wt_uom,
                                                         p_min_package_wt,
                                                         0);  -- Within same UOM class
                l_temp_min_uom  := p_wt_uom;
    else
                l_temp_min_wt   := p_min_package_wt;
                l_temp_min_uom  := p_wt_uom;
    end if;

    if (p_wt < l_temp_min_wt) then
                x_new_wt        := l_temp_min_wt;
                x_new_wt_uom    := l_temp_min_uom;
                x_bump          := 'Y';
    else
                x_new_wt        := p_wt;
                x_new_wt_uom    := p_wt_uom;
                x_bump          := 'N';
    end if;

 fte_freight_pricing_util.unset_method(l_log_level,'get_bumped_up_package_weight');
 EXCEPTION
      WHEN fte_freight_pricing_util.g_weight_uom_not_found THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_weight_uom_not_found');
           fte_freight_pricing_util.unset_method(l_log_level,'get_bumped_up_package_weight');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'get_bumped_up_package_weight');
END get_bumped_up_package_weight;


-- Get the next higher wt. break. The wt. break is converted to the uom on the total wt.
PROCEDURE get_next_weight_break       (p_total_wt                IN NUMBER,
                                       p_total_wt_uom            IN VARCHAR2,
                                       x_next_weight_break       OUT NOCOPY  NUMBER,
                                       x_weight_break_uom        OUT NOCOPY  VARCHAR2,
                                       x_return_status           OUT NOCOPY  VARCHAR2)
IS
i              NUMBER;
l_curr_break   NUMBER;
l_curr_diff    NUMBER := 99999999999 ;
l_least_diff   NUMBER := 99999999999 ;
l_best_break   NUMBER := 0;
l_return_status  VARCHAR2(1);
l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'get_next_weight_break';
 BEGIN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     fte_freight_pricing_util.reset_dbg_vars;
     fte_freight_pricing_util.set_method(l_log_level,'get_next_weight_break');

     -- in the loop the wt break points may not be in any particular order
     -- so we have to get the weight break point which gives the smallest positive difference
     -- from the total wt
     -- all wt break points are first converted to the uom of the total wt
     i := g_lane_parameters.FIRST;
     IF (i IS NOT NULL) THEN
     LOOP
         IF (g_lane_parameters(i).parameter_sub_type = 'DEFICIT_WT'
             AND g_lane_parameters(i).parameter_name = 'WT_BREAK_POINT') THEN
               IF (p_total_wt_uom <> g_lane_parameters(i).uom_code) THEN

                    l_curr_break   :=    INV_CONVERT.inv_um_convert(
                                          --item_id,
                                          0,-- Within same UOM class
                                          --5,
                                          nvl(FND_PROFILE.Value ('QP_INV_DECIMAL_PRECISION'),10),
                                          -- Bug 2360273 : precision same as QP's precision
                                          fnd_number.canonical_to_number(g_lane_parameters(i).value_from),
                                          g_lane_parameters(i).uom_code,
                                          p_total_wt_uom,
                                          NULL,
                                          NULL);

                    IF l_curr_break = -99999 then
                       fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,' Undefined UOM conversion for def. wt. break from '||g_lane_parameters(i).uom_code||' to uom '||p_total_wt_uom);
                       --raise others;
                       raise fte_freight_pricing_util.g_invalid_uom_conversion;
                    END IF;

                                         /*
                                         WSH_WV_UTILS.convert_uom(g_lane_parameters(i).uom_code,
                                                                p_total_wt_uom,
                                                                g_lane_parameters(i).value_from,
                                                                0);  -- Within same UOM class
                                         */
               ELSE
                    l_curr_break   := fnd_number.canonical_to_number(g_lane_parameters(i).value_from);
               END IF;

               l_curr_diff := l_curr_break - p_total_wt;
               IF (l_curr_diff < l_least_diff AND l_curr_diff >= 0) THEN
                   l_least_diff  := l_curr_diff;
                   l_best_break  := l_curr_break;
               END IF;
         END IF;
     EXIT WHEN (i >= g_lane_parameters.LAST );
         i := g_lane_parameters.NEXT(i);
     END LOOP;
     END IF;

     -- Should not error out
     -- If next break point is not found should ideally proceed with one set as standard LTL
     -- For this release will throw error and a descriptive message AG 05/08
     /*
     -- if next break point is not found, the calling procedure will just send one set to QP
     IF (l_best_break <= 0) THEN
          --raise fte_freight_pricing_util.g_weight_break_not_found;
          raise fte_freight_pricing_util.g_def_wt_break_not_found;
     END IF;
     */
     -- This will never happen as the calling procedure handles this
     /*
     IF (p_total_wt_uom IS NULL ) THEN
          raise fte_freight_pricing_util.g_weight_uom_not_found;
     END IF;
     */

     -- There is a potential problem here in case of uom conversion
     -- because of the decimal discontinuity
     -- on a pricebreak line which can give us an IPL
     -- for the line which is going with the next break value as Total_Item_quantity  AG  05/09
     x_next_weight_break := l_best_break;
     x_weight_break_uom  := p_total_wt_uom;

 fte_freight_pricing_util.unset_method(l_log_level,'get_next_weight_break');
 EXCEPTION
      /*
      --WHEN fte_freight_pricing_util.g_weight_break_not_found THEN
      WHEN fte_freight_pricing_util.g_def_wt_break_not_found THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           --x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_def_wt_break_not_found');
           fte_freight_pricing_util.unset_method(l_log_level,'get_next_weight_break');
      */
      WHEN fte_freight_pricing_util.g_invalid_uom_conversion THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_invalid_uom_conversion');
           fte_freight_pricing_util.unset_method(l_log_level,'get_next_weight_break');
      /*
      WHEN fte_freight_pricing_util.g_total_shipment_weight_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_total_shipment_weight_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'get_next_weight_break');
      */
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'get_next_weight_break');
END get_next_weight_break;


-- This function is used to calculate the deficit wt for the given shipment
-- The total wt and wt break are assumed to be in the same uom
FUNCTION get_deficit_weight  ( p_total_wt      IN NUMBER,
                               p_next_wt_break IN NUMBER)
RETURN NUMBER IS
l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
 BEGIN
        RETURN (p_next_wt_break - p_total_wt);
END;



-- call after a qp call
-- can be called only after pricing objective has been resolved
-- in parameters include processed rows from qp call
-- out parameters include massaged qp processed rows.
-- analyses engine output to verify if min. charge should apply. If shipment qualifies for min. charge, then
-- prorate the min. charge across all lines.
PROCEDURE apply_min_charge (p_event_num        IN  NUMBER,
                            p_set_num          IN  NUMBER DEFAULT 1,
                            p_comp_with_price  IN  NUMBER DEFAULT NULL,
                            x_charge_applied   OUT NOCOPY  VARCHAR2,  -- Y/N
                            x_return_status    OUT NOCOPY  VARCHAR2)
IS

  l_total_base_price       NUMBER;
  l_priced_curr            VARCHAR2(30);
  l_return_status          VARCHAR2(1);
  l_min_charge_amt         NUMBER;
  l_min_charge_curr        VARCHAR2(30);
  l_log_level  NUMBER := fte_freight_pricing_util.G_LOG;
  l_method_name VARCHAR2(50) := 'apply_min_charge';

  -- local module --
  PROCEDURE get_min_charge_parameter (x_min_charge_amt  OUT NOCOPY  NUMBER,
                                      x_currency        OUT NOCOPY  VARCHAR2)
  IS
       i                NUMBER;
       min_charge_amt   NUMBER := 0;
       currency         VARCHAR2(30) := NULL;
  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'apply_min_charge';
 BEGIN
     fte_freight_pricing_util.set_method(l_log_level,'get_min_charge_parameter');
       i := g_lane_parameters.FIRST;
     IF (i IS NOT NULL) THEN
     LOOP
         IF (g_lane_parameters(i).parameter_sub_type = 'MIN_CHARGE'
             AND g_lane_parameters(i).parameter_name = 'MIN_CHARGE_AMT') THEN
                min_charge_amt  := fnd_number.canonical_to_number(g_lane_parameters(i).value_from);
                currency        := g_lane_parameters(i).currency_code;
         END IF;

     EXIT WHEN (i >= g_lane_parameters.LAST);
         i := g_lane_parameters.NEXT(i);
     END LOOP;
     END IF;
     x_min_charge_amt := min_charge_amt;
     x_currency       := currency;
     fte_freight_pricing_util.unset_method(l_log_level,'get_min_charge_parameter');
  EXCEPTION
    WHEN others THEN
      fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
      fte_freight_pricing_util.unset_method(l_log_level, l_method_name);
  END  get_min_charge_parameter;
  -- end local module --

 BEGIN

     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     fte_freight_pricing_util.reset_dbg_vars;
     fte_freight_pricing_util.set_method(l_log_level,'apply_min_charge');
     x_charge_applied := 'N';

    IF (g_special_flags.minimum_charge_flag <> 'Y') THEN
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'minimum charge is disabled ');
        fte_freight_pricing_util.unset_method(l_log_level,'apply_min_charge');
        RETURN;
    END IF;

    IF p_comp_with_price IS NULL THEN
    -- now calculate the total base price of the shipment (for the given set)
    fte_qp_engine.get_total_base_price(p_set_num          => p_set_num, -- Have to pass set number as otherwise
                                                                        -- the correct remaining set
                                                                        -- would not be picked up eg. deficit wt.
                                                                        -- with min. charge or hundred wt
                                                                        -- with min. charge would not work
                                                                        -- AG 5/10
                                       --p_set_num          => p_set_num,
                                       --x_priced_currency  => l_priced_curr,
                                       x_price            => l_total_base_price,
                                       x_return_status    => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after get_total_base_price ');
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_total_base_price_failed;
           /*
           ELSE
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_total_base_price = '||l_total_base_price);
           */
           END IF;

    ELSE
      l_total_base_price := p_comp_with_price;
    END IF;
    fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_total_base_price = '||l_total_base_price);
    -- call the local module
    get_min_charge_parameter (l_min_charge_amt, l_min_charge_curr);

     -- TODO : implement x_priced_currency in fte_qp_engine.get_total_base_price. the following lines
     --        are commented out for now
    --IF (l_min_charge_curr <> l_priced_curr ) THEN
       -- error
     --  RETURN;
    -- END IF;

    -- For deficit wt. there is a third component here which should be part of the comparison
    -- AG 5/10

    IF (l_min_charge_amt > l_total_base_price ) THEN
       -- should apply min. charge
       -- prorate min. charge across all engine output lines by wt.
       fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'min charge will be applied');
       fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'min charge amount : '||l_min_charge_amt);
       fte_qp_engine.apply_new_base_price(--p_set_num         => p_set_num,
                                          p_set_num         => p_set_num,   -- AG 5/10
                                          p_new_total_price => l_min_charge_amt,
                                          x_return_status   => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after apply_new_base_price ');
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_apply_new_base_price_failed;
           ELSE
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'applied min charge amt = '||l_min_charge_amt);
           END IF;

       x_charge_applied := 'Y';

    ELSE
       -- do nothing
       fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'No need to apply min charge ');
       fte_freight_pricing_util.unset_method(l_log_level,'apply_min_charge');
       RETURN;
    END IF;

 fte_freight_pricing_util.unset_method(l_log_level,'apply_min_charge');
 EXCEPTION
      WHEN fte_freight_pricing_util.g_total_base_price_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'total_base_price_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'apply_min_charge');
      WHEN fte_freight_pricing_util.g_apply_new_base_price_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_apply_new_base_price_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'apply_min_charge');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'apply_min_charge');


END  apply_min_charge;




PROCEDURE  process_LTL_with_deficit_wt (
        p_pricing_control_rec     IN               fte_freight_pricing.pricing_control_input_rec_type,
        p_top_level_rows          IN               fte_freight_pricing.shpmnt_content_tab_type,
        p_pricing_engine_rows     IN OUT NOCOPY    fte_freight_pricing.pricing_engine_input_tab_type,
        p_pricing_dual_instances  IN               fte_freight_pricing.pricing_dual_instance_tab_type,
        p_pattern_rows            IN               fte_freight_pricing.top_level_pattern_tab_type,
        p_pricing_attribute_rows  IN OUT NOCOPY    fte_freight_pricing.pricing_attribute_tab_type,
        x_deficit_wt_applied      OUT NOCOPY               VARCHAR2,    -- Added AG 5/10
        x_min_charge_comp_price   OUT NOCOPY               NUMBER,      -- AG 5/10
        x_qp_output_line_rows     OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        x_qp_output_detail_rows   OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_return_status           OUT NOCOPY     VARCHAR2 )
IS
   l_return_status         VARCHAR2(1);
   l_total_wt              NUMBER;
   l_total_wt_uom          VARCHAR2(30);
   l_event_num             NUMBER;
   l_set_num               NUMBER;
   i                       NUMBER;
   j                       NUMBER;
   l_attr_rec              fte_freight_pricing.pricing_attribute_rec_type;
   l_temp_wt               NUMBER;
   l_charge_applied        VARCHAR2(1);
   l_next_weight_break     NUMBER;
   l_next_weight_break_uom VARCHAR2(30);
   l_curr_last_idx         NUMBER;
   l_curr_input_idx        NUMBER;
   l_set_one_max_input_idx NUMBER;
   l_engine_input_rec      fte_freight_pricing.pricing_engine_input_rec_type;
   l_attr_row              fte_freight_pricing.pricing_attribute_rec_type;
   l_new_index             NUMBER;

   l_deficit_wt                 NUMBER:=0;
   l_converted_def_wt           NUMBER:=0;
   l_deficit_wt_uom             VARCHAR2(30);

   l_comm_price_rec        fte_qp_engine.commodity_price_rec_type;
   l_comm_price_rows_set1  fte_qp_engine.commodity_price_tbl_type;
   l_comm_price_rows_set2  fte_qp_engine.commodity_price_tbl_type;

   x_price                 NUMBER;
   y_price                 NUMBER;
   l_lowest_unit_price     NUMBER;
   l_lowest_unit_price_cat NUMBER;
   l_lowest_up_line_index  NUMBER:=0;
   l_lowest_up_priced_uom       VARCHAR2(30);
   l_lowest_up_tot_qty          NUMBER:=0;
   l_lowest_up_line_priced_qty    NUMBER:=0;
   l_adjustment_amount     NUMBER;
   l_qp_output_dfw_detail_row   QP_PREQ_GRP.LINE_DETAIL_REC_TYPE;

   l_deficit_wt_enabled   BOOLEAN;

l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'process_LTL_with_deficit_wt';
 BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   x_deficit_wt_applied  :=  'N';
   x_min_charge_comp_price := 0;  -- AG 5/10 required for minimum charge with deficit wt

   l_deficit_wt_enabled := false;

   fte_freight_pricing_util.reset_dbg_vars;
   fte_freight_pricing_util.set_method(l_log_level,'process_LTL_with_deficit_wt');
       -- process deficit wt.
       -- prepare engine input  (also make appropriate additions to original engine input rows)
            -- 1st Set (for y): send total_item_quantity = actual total
            -- 2nd Set (for x): send total_item_quantity = next wt. break
       -- call qp api
       -- (how does min charge mix with deficit wt.?)
       -- do deficit wt. calc and comparision
       -- delete unused set from engine rows and from qp input and output tables

       -- get total shipment wt. Should take care of conversions.
       get_total_shipment_weight (p_top_level_rows => p_top_level_rows,
                                  x_total_wt       => l_total_wt,
                                  x_wt_uom         => l_total_wt_uom,
                                  x_return_status  => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after get_total_shipment_weight ');
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_total_shipment_weight_failed;
           ELSE
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_total_wt = '||l_total_wt);
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_total_wt_uom = '||l_total_wt_uom);
           END IF;

       l_event_num := fte_qp_engine.G_LINE_EVENT_NUM;
       fte_qp_engine.create_control_record(p_event_num => l_event_num,
                                           x_return_status => l_return_status );

           fte_freight_pricing_util.set_location(p_loc=>'after create_control_record ');
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_control_record_failed;
           END IF;

       ---- set I : actual total wt. ----
       l_set_num   := 1;
       fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'In set = '||l_set_num);
       i := p_pricing_engine_rows.FIRST;
       IF (i IS NOT NULL) THEN
       LOOP
            fte_qp_engine.create_line_record (p_pricing_control_rec       => p_pricing_control_rec,
                                              p_pricing_engine_input_rec  => p_pricing_engine_rows(i),
                                              x_return_status             => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create_line_record. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_line_record_failed;
           END IF;

            fte_qp_engine.prepare_qp_line_qualifiers(
                                              p_event_num               => l_event_num,
                                              p_pricing_control_rec       => p_pricing_control_rec,
                                              p_input_index             => p_pricing_engine_rows(i).input_index,
                                              x_return_status           => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create qp line qualifiers. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_qualifiers_failed;
           END IF;

            fte_qp_engine.prepare_qp_line_attributes (
                                              p_event_num               => l_event_num,
                                              p_input_index             => p_pricing_engine_rows(i).input_index,
                                              p_attr_rows               => p_pricing_attribute_rows,
                                              x_return_status           => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create qp line attributes. i='||i);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;
           -- Now create additional attributes

            l_attr_rec.attribute_index  := p_pricing_attribute_rows.LAST + 1;
            l_attr_rec.input_index      := p_pricing_engine_rows(i).input_index;
            l_attr_rec.attribute_name   := 'TOTAL_ITEM_QUANTITY';

            IF (p_pricing_engine_rows(i).line_uom <> l_total_wt_uom ) THEN
                l_temp_wt   :=  WSH_WV_UTILS.convert_uom(l_total_wt_uom,
                                                         p_pricing_engine_rows(i).line_uom,
                                                         l_total_wt,
                                                         0);  -- Within same UOM class
                l_attr_rec.attribute_value  := to_char(l_temp_wt);
            ELSE
                l_attr_rec.attribute_value  := to_char(l_total_wt);
            END IF;

            fte_qp_engine.create_attr_record         (p_event_num               => l_event_num,
                                                      p_attr_rec                => l_attr_rec,
                                                      x_return_status           => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create qp line attributes. i='||i);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;

          -- Also add it to the original pricing attribute rows;
          -- p_pricing_attribute_rows(p_pricing_attribute_rows.LAST + 1) := l_attr_rec;

       EXIT WHEN i >= p_pricing_engine_rows.LAST;
       i := p_pricing_engine_rows.NEXT(i);
       END LOOP;
       END IF;

       ---- set II : next break weight ----
       -- get the next weight break converted to the total wt uom
       l_set_num   := 2;
       fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'In set = '||l_set_num);
       fte_freight_pricing_util.print_msg(l_log_level,'get the next weight break for total_wt: '||l_total_wt||' uom: '||l_total_wt_uom);
       get_next_weight_break (p_total_wt                => l_total_wt,
                              p_total_wt_uom            => l_total_wt_uom,
                              x_next_weight_break       => l_next_weight_break,
                              x_weight_break_uom        => l_next_weight_break_uom,
                              x_return_status           => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after get_next_weight_break ');

           --IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
           --      l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise fte_freight_pricing_util.g_get_next_weight_break_failed;
                 END IF;
           ELSE
	     IF (l_next_weight_break is null OR l_next_weight_break <= 0) THEN
               fte_freight_pricing_util.print_msg(l_log_level,'not able to find next weight break, so do not use deficit weight pricing, continue as standard LTL.');
             ELSE
              fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Found applicable weight break : '||l_next_weight_break||' '||l_next_weight_break_uom);
               l_deficit_wt_enabled := true;
             END IF;
           END IF;

           -- Should never happen AG 05/08
           /*
           IF (l_next_weight_break = 0 OR l_next_weight_break_uom = null ) THEN
                        raise fte_freight_pricing_util.g_weight_break_not_found;
           END IF;
           */

       IF l_deficit_wt_enabled THEN
       -- {
       -- get the deficit wt.
       -- uom conversion taken care in get_next_weight_break to
       -- convert deficit wt breaks to the total wt uom
       l_deficit_wt     := get_deficit_weight(p_total_wt         => l_total_wt,
                                              p_next_wt_break    => l_next_weight_break);
       --l_deficit_wt_uom := l_total_wt_uom;
       l_deficit_wt_uom := l_next_weight_break_uom;


       --l_set_num   := 2;
       --fte_qp_engine.get_max_input_index(p_event_num      => fte_qp_engine.G_LINE_EVENT_NUM,
       --                                  p_set_num        => 1,
       --                                  p_max_line_index => l_set_one_max_input_idx,
       --                                  x_return_status  => l_return_status);

       i := p_pricing_engine_rows.FIRST; -- counter for set 1 engine rows
       l_curr_last_idx  := p_pricing_engine_rows.LAST;
       l_new_index := l_curr_last_idx + 1;
       IF (i IS NOT NULL) THEN
       LOOP
            l_curr_input_idx                     := p_pricing_engine_rows(i).input_index; --should be the same as i

            -- copy current row to new row with set = 2 and line index as max line index + 1
            l_engine_input_rec                   := p_pricing_engine_rows(i);
            l_engine_input_rec.input_index       := l_new_index;
            l_engine_input_rec.input_set_number  := l_set_num;

            p_pricing_engine_rows(l_new_index)   := l_engine_input_rec;


            -- prepare line rec
            fte_qp_engine.create_line_record (p_pricing_control_rec       => p_pricing_control_rec,
                                              p_pricing_engine_input_rec  => l_engine_input_rec,
                                              x_return_status             => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create_line_record. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_line_record_failed;
           END IF;

            --prepare qualifiers
            fte_qp_engine.prepare_qp_line_qualifiers(
                                              p_event_num               => l_event_num,
                                              p_pricing_control_rec       => p_pricing_control_rec,
                                              p_input_index             => l_new_index,
                                              x_return_status           => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create qp line qualifiers. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_qualifiers_failed;
           END IF;

            -- prepare attributes from the attr rows. line indexes need to be changed
            j := p_pricing_attribute_rows.FIRST;
            IF (j IS NOT NULL) THEN
            LOOP
                IF (p_pricing_attribute_rows(j).input_index = l_curr_input_idx ) THEN
                    l_attr_rec                 := p_pricing_attribute_rows(j);
                    l_attr_rec.input_index     := l_new_index;
                    l_attr_rec.attribute_index := p_pricing_attribute_rows(p_pricing_attribute_rows.COUNT).attribute_index + 1;

                    p_pricing_attribute_rows(p_pricing_attribute_rows.COUNT + 1) := l_attr_rec;

                    fte_qp_engine.create_attr_record (     p_event_num              => l_event_num,
                                             p_attr_rec               => l_attr_rec,
                                             x_return_status          => l_return_status);

                    fte_freight_pricing_util.set_location(p_loc=>'after create attr record . i='||i);
                    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                          l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                                 raise fte_freight_pricing_util.g_create_attr_failed;
                    END IF;
                END IF;
            EXIT WHEN j = p_pricing_attribute_rows.LAST;
            j := p_pricing_attribute_rows.NEXT(j);
            END LOOP;
            END IF;

            -- add other default attributes
            l_attr_rec.attribute_index  := p_pricing_attribute_rows(p_pricing_attribute_rows.COUNT).attribute_index + 1;
            l_attr_rec.input_index      := l_new_index;
            l_attr_rec.attribute_name   := 'ITEM_ALL';
            l_attr_rec.attribute_value  := 'ALL';

            fte_qp_engine.create_attr_record(  p_event_num              => l_event_num,
                                               p_attr_rec               => l_attr_rec,
                                               x_return_status          => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create attr record . i='||i);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;

            -- add other new attributes
            l_attr_rec.attribute_index  := p_pricing_attribute_rows.LAST + 1;
            l_attr_rec.input_index      := l_new_index;
            l_attr_rec.attribute_name   := 'TOTAL_ITEM_QUANTITY';

            IF (p_pricing_engine_rows(i).line_uom <> l_next_weight_break_uom ) THEN
                l_temp_wt   :=  WSH_WV_UTILS.convert_uom(l_next_weight_break_uom,
                                                         p_pricing_engine_rows(i).line_uom,
                                                         l_next_weight_break,
                                                         0);  -- Within same UOM class
                l_attr_rec.attribute_value  := to_char(l_temp_wt);
            ELSE
                l_attr_rec.attribute_value  := to_char(l_next_weight_break);
            END IF;

            fte_qp_engine.create_attr_record(p_event_num               => l_event_num,
                                             p_attr_rec                => l_attr_rec,
                                             x_return_status           => l_return_status);
            fte_freight_pricing_util.set_location(p_loc=>'after create attr record . i='||i);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;

       EXIT WHEN i >= l_curr_last_idx;
       i := p_pricing_engine_rows.NEXT(i);
       l_new_index := l_new_index + 1;
       END LOOP;  -- engine rows
       END IF;

       -- }
       END IF; --l_deficit_wt_enabled

       -- call qp api
       fte_qp_engine.call_qp_api    ( x_qp_output_line_rows    => x_qp_output_line_rows,
                                      x_qp_output_detail_rows  => x_qp_output_detail_rows,
                                      x_return_status          => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after call_qp_api: Event 1');
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise fte_freight_pricing_util.g_qp_price_request_failed_2;
                 END IF;
           END IF;

       --check for errors in the output
           fte_qp_engine.check_qp_output_errors (x_return_status   => l_return_status);
           fte_freight_pricing_util.set_location(p_loc=>'after check_qp_output_errors: Event '||l_event_num);
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise fte_freight_pricing_util.g_qp_price_request_failed_2;
                 END IF;
           END IF;


       -- now analyse output
         -- find total price per set  (do we need this?)
         -- find deficit wt.
         -- find commodity with lowest unit price in set 2.

      -- get me unit price for each individual commodity for each set
      -- get me total wt. for each individual commodity
      -- give me all weights in the deficit wt uom
       l_set_num := 1;  -- set 1 uses original total weight
       fte_qp_engine.analyse_output_for_deficit_wt (p_set_num     => l_set_num,
                                                    p_wt_uom      => l_deficit_wt_uom,
                                                    x_commodity_price_rows  => l_comm_price_rows_set1,
                                                    x_return_status   => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after analyse_output_for_deficit_wt. set= '||l_set_num);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_analyse_deficit_failed;
            END IF;

       IF l_deficit_wt_enabled THEN
       -- {
       l_set_num := 2;  -- set 2 uses next higher break weight
       fte_qp_engine.analyse_output_for_deficit_wt (
                                      p_set_num     => l_set_num,
                                      p_wt_uom      => l_deficit_wt_uom,
                                      x_commodity_price_rows  => l_comm_price_rows_set2,
                                      x_return_status   => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after analyse_output_for_deficit_wt. set= '||l_set_num);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_analyse_deficit_failed;
            END IF;
       -- }
       END IF; --l_deficit_wt_enabled


      -- y (set 1) = A*rwb-a + B*rwb-b
      -- x (set 2) = A*r-a + B*r-b + DFW*r-a  (assuming a=lowest rate )
      -- compare x and y
      y_price := 0;
      i := l_comm_price_rows_set1.FIRST;
      IF (i IS NOT NULL) THEN
      LOOP
            y_price := y_price + (l_comm_price_rows_set1(i).total_wt * l_comm_price_rows_set1(i).unit_price);
      EXIT WHEN  i >= l_comm_price_rows_set1.LAST;
      i := l_comm_price_rows_set1.NEXT(i);
      END LOOP;
      END IF;

      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'y_price = '||y_price);

       IF l_deficit_wt_enabled THEN
       -- {
      x_price := 0;
      l_lowest_unit_price := 0;  -- to find lowest unit price across commodities
      i := l_comm_price_rows_set2.FIRST;
      IF (i IS NOT NULL) THEN
      LOOP
            --l_lowest_up             := FALSE;  --  Keep track of whether the current row is lowest
            x_price := x_price + (l_comm_price_rows_set2(i).total_wt * l_comm_price_rows_set2(i).unit_price);
            IF ( i = l_comm_price_rows_set2.FIRST) THEN
               l_lowest_unit_price     := l_comm_price_rows_set2(i).unit_price;
               l_lowest_unit_price_cat := l_comm_price_rows_set2(i).category_id;
               l_lowest_up_priced_uom  := l_comm_price_rows_set2(i).priced_uom;
               --l_lowest_up             := TRUE;
               l_lowest_up_tot_qty     := l_comm_price_rows_set2(i).total_wt;  --  This assumes that
                                       -- there is only one commodity row with lowest up
                                       -- and if there were multiple qp output lines resulting from
                                       -- QP engine for that commodity, that was taken into account
                                       -- when commodity rows were created   AG 5/13
                                       -- It will be in def wt uom
               l_lowest_up_line_index  := l_comm_price_rows_set2(i).output_line_index;
               l_lowest_up_line_priced_qty := l_comm_price_rows_set2(i).output_line_priced_quantity;  --  xizhang 11/22/02
            ELSE
               --l_lowest_unit_price := LEAST(l_comm_price_rows_set2(i).unit_price,l_lowest_unit_price);
               -- This is a problem AG 5/10
               -- Should do a comparison and then choose l_lowest_unit_price_cat
               IF l_comm_price_rows_set2(i).unit_price < l_lowest_unit_price THEN
               --IF l_lowest_unit_price = l_comm_price_rows_set2(i).unit_price THEN
                  l_lowest_unit_price     := l_comm_price_rows_set2(i).unit_price;
                  l_lowest_unit_price_cat := l_comm_price_rows_set2(i).category_id;
                  l_lowest_up_priced_uom  := l_comm_price_rows_set2(i).priced_uom;
                  --l_lowest_up             := TRUE;
                  l_lowest_up_tot_qty     := l_comm_price_rows_set2(i).total_wt;
                  l_lowest_up_line_index  := l_comm_price_rows_set2(i).output_line_index;
                  l_lowest_up_line_priced_qty := l_comm_price_rows_set2(i).output_line_priced_quantity;  --  xizhang 11/22/02
               END IF;
            END IF;
            /*
            IF l_lowest_up THEN
               l_lowest_up_tot_qty := l_lowest_up_tot_qty + l_comm_price_rows_set2(i).total_wt;
            END IF;
            */
      EXIT WHEN  i >= l_comm_price_rows_set1.LAST;
      i := l_comm_price_rows_set1.NEXT(i);
      END LOOP;
      END IF;

      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_deficit_wt = '||l_deficit_wt);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_lowest_unit_price = '||l_lowest_unit_price);

      x_price := x_price + (l_deficit_wt * l_lowest_unit_price );

      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'x_price = '||x_price);

       -- }
       END IF; --l_deficit_wt_enabled

      -- now compare x_price and y_price
     -- TO DO : this needs to be '<' ******
      IF (l_deficit_wt_enabled AND x_price < y_price ) THEN
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,' deficit wt got applied ');
             x_deficit_wt_applied  :=  'Y';
             x_min_charge_comp_price := x_price;  -- AG 5/10 required for minimum charge with deficit wt
             -- deficit wt got applied
             -- select set 2, delete set 1
             l_set_num :=1; --set to delete
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Deleting set ='||l_set_num);
             fte_qp_engine.delete_set_from_line_event( p_set_num       => l_set_num,
                                                      x_return_status => l_return_status);
            fte_freight_pricing_util.set_location(p_loc=>'after delete_set_from_line_event. set= '||l_set_num);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_delete_set_failed;
            END IF;
      ELSE
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,' deficit wt did not get applied ');
             x_deficit_wt_applied  :=  'N';
             x_min_charge_comp_price := y_price;  -- AG 5/10 required for minimum charge with deficit wt
       IF l_deficit_wt_enabled THEN
       -- {
            -- select set 1, delete set 2
            -- no deficit wt applied
             l_set_num :=2; --set to delete
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Deleting set ='||l_set_num);
             fte_qp_engine.delete_set_from_line_event( p_set_num       => l_set_num,
                                                      x_return_status => l_return_status);
            fte_freight_pricing_util.set_location(p_loc=>'after delete_set_from_line_event. set= '||l_set_num);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_delete_set_failed;
            END IF;

       -- }
       END IF; --l_deficit_wt_enabled
      END IF;

   IF x_deficit_wt_applied = 'Y' THEN

      -- Need to take care of the third component of side x_price ie. DFW
      -- As per the requirement it was part of the calculation to make the choice and
      -- the carrier should display that to the shipper AG 5/10

      -- We will be using the deficit wt. amount in the line qty uom as the qty of this record
      -- As the deficit wt qty gets the lowest rate among the output lines, we have to put that rate
      -- in adjustment amount
      -- As we also assume that the line detail records (all of them) have the same
      -- quantity as the parent line's line quantity, we will have to make the necessary proration
      -- to the adjustment amount eg. if line qty of lowest unit price line is 300 Lbs
      -- and the unit price is 30 / Lbs, and the deficit wt. for the shipment is 100 Lbs
      -- then the adjustment amount becomes 30 * (100/300) / Lbs
      -- Also adjustment amount should be in priced_uom

      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'deficit wt uom : '||l_deficit_wt_uom);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'lowest priced uom : '||l_lowest_up_priced_uom);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'lowest priced qty : '||l_lowest_up_tot_qty);

      IF l_deficit_wt_uom <> l_lowest_up_priced_uom THEN
        l_converted_def_wt := WSH_WV_UTILS.convert_uom(l_deficit_wt_uom,
                                                       l_lowest_up_priced_uom,
                                                       l_deficit_wt,
                                                       0);  -- Within same UOM class
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'converted def wt : '||l_converted_def_wt);
        --l_adjustment_amount    := l_lowest_unit_price*(l_deficit_wt/l_lowest_up_tot_qty)*(l_deficit_wt/l_converted_def_wt);
        l_adjustment_amount    := l_lowest_unit_price*(l_deficit_wt/l_lowest_up_line_priced_qty)*(l_deficit_wt/l_converted_def_wt); -- xizhang 11/22/02

      ELSE
        --l_adjustment_amount    := l_lowest_unit_price*(l_deficit_wt/l_lowest_up_tot_qty);
        l_adjustment_amount    := l_lowest_unit_price*(l_deficit_wt/l_lowest_up_line_priced_qty); -- xizhang 11/22/02

      END IF;
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'def wt adjustment_amount : '||l_adjustment_amount);


      FTE_QP_ENGINE.add_qp_output_detail(
	p_line_index 		=> l_lowest_up_line_index,
	p_list_line_type_code	=> 'SUR',
	p_charge_subtype_code	=> 'DEFICIT WEIGHT SURCHARGE',
	p_adjustment_amount	=> l_adjustment_amount,
	x_return_status		=> l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
          l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
             raise fte_freight_pricing_util.g_add_qp_output_detail_failed;
      END IF;
   END IF;

   -- TO DO : check that we are assigning x_ at the end everywhere
   FTE_QP_ENGINE.get_qp_output(
     x_qp_output_line_rows    	=> x_qp_output_line_rows,
     x_qp_output_detail_rows  	=> x_qp_output_detail_rows,
     x_return_status		=> l_return_status);

   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
       l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
         raise fte_freight_pricing_util.g_get_qp_output_failed;
   END IF;

 fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');
 EXCEPTION
      WHEN fte_freight_pricing_util.g_add_qp_output_detail_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_add_qp_output_detail_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');
      WHEN fte_freight_pricing_util.g_get_qp_output_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_get_qp_output_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');
      WHEN fte_freight_pricing_util.g_create_control_record_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_control_record_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');
      WHEN fte_freight_pricing_util.g_create_line_record_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_line_record_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');
      WHEN fte_freight_pricing_util.g_create_qualifiers_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_qualifiers_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');
      WHEN fte_freight_pricing_util.g_create_attr_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_attr_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');
      WHEN fte_freight_pricing_util.g_delete_set_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_delete_set_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');
      WHEN fte_freight_pricing_util.g_analyse_deficit_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_analyse_deficit_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');
      WHEN fte_freight_pricing_util.g_weight_break_not_found THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_weight_break_not_found');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');
      WHEN fte_freight_pricing_util.g_total_shipment_weight_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_total_shipment_weight_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');
      WHEN fte_freight_pricing_util.g_qp_price_request_failed_2 THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_qp_price_request_failed_2');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL_with_deficit_wt');

END process_LTL_with_deficit_wt;

-- post process for LTL, parcel and others
--   resolve pricing objective
--   apply minimum charges
--     prepare second qp call
--     call qp (second call)
PROCEDURE post_process(
  p_event_num               IN NUMBER,
  p_set_num                 IN NUMBER,
  p_comp_with_price         IN  NUMBER DEFAULT NULL,
  p_pricing_engine_rows     IN OUT NOCOPY     fte_freight_pricing.pricing_engine_input_tab_type,
  p_pricing_dual_instances  IN                fte_freight_pricing.pricing_dual_instance_tab_type,
  x_qp_output_line_rows     IN OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
  x_qp_output_detail_rows   IN OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
  x_return_status           OUT NOCOPY                VARCHAR2 )
IS
   l_event_num NUMBER;
   l_charge_applied        VARCHAR2(1);
   l_return_status    VARCHAR2(1);
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'post_process';
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

  --call resolve pricing objective here --
  fte_freight_pricing.resolve_pricing_objective(
    p_pricing_dual_instances   =>p_pricing_dual_instances,
    x_pricing_engine_input     =>p_pricing_engine_rows,
    x_qp_output_line_rows      =>x_qp_output_line_rows,
    x_qp_output_line_details   =>x_qp_output_detail_rows,
    x_return_status            =>l_return_status);

  fte_freight_pricing_util.set_location(p_loc=>'after resolve_pricing_objective');
  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
      l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
        raise fte_freight_pricing_util.g_resolve_pricing_objective;
  END IF;

  -- apply min charge
    -- prepare second qp call
    -- call qp (second call)

  -- min charge can be called only after pricing objective has been resolved
  IF (g_special_flags.minimum_charge_flag = 'Y') THEN

    apply_min_charge(
	p_event_num      => p_event_num,
        p_set_num        => p_set_num,  -- try to get rid of this
        p_comp_with_price => p_comp_with_price,
        x_charge_applied => l_charge_applied,
        x_return_status  => l_return_status);

    fte_freight_pricing_util.set_location(p_loc=>'after apply_min_charge ');
    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
        l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
          raise fte_freight_pricing_util.g_apply_min_charge;
    END IF;
  END IF;

  -- create request lines for the next event and call qp engine
  IF (l_charge_applied = 'Y') THEN
       l_event_num := fte_qp_engine.G_CHARGE_EVENT_NUM;
       fte_qp_engine.prepare_next_event_request ( x_return_status           => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after prepare_next_event_request');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_prepare_next_event_failed;
            END IF;

       fte_qp_engine.call_qp_api    ( x_qp_output_line_rows    => x_qp_output_line_rows,
                                      x_qp_output_detail_rows  => x_qp_output_detail_rows,
                                      x_return_status          => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after call_qp_api: Event 2');
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise fte_freight_pricing_util.g_qp_price_request_failed_2;
                 END IF;
           END IF;

       --check for errors in the output
           fte_qp_engine.check_qp_output_errors (x_return_status   => l_return_status);
           fte_freight_pricing_util.set_location(p_loc=>'after check_qp_output_errors: Event '||l_event_num);
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise fte_freight_pricing_util.g_qp_price_request_failed_2;
                 END IF;
           END IF;

  END IF;

  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
EXCEPTION
      WHEN fte_freight_pricing_util.g_resolve_pricing_objective THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_resolve_pricing_objective');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN fte_freight_pricing_util.g_apply_min_charge THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_apply_min_charge');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN fte_freight_pricing_util.g_prepare_next_event_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_prepare_next_event_failed');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN fte_freight_pricing_util.g_qp_price_request_failed_2 THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_qp_price_request_failed_2');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END post_process;

-- This is called for LTL
PROCEDURE process_LTL (
        p_pricing_control_rec     IN               fte_freight_pricing.pricing_control_input_rec_type,
        p_top_level_rows          IN               fte_freight_pricing.shpmnt_content_tab_type,
        p_pricing_engine_rows     IN OUT NOCOPY    fte_freight_pricing.pricing_engine_input_tab_type,
        p_pricing_dual_instances  IN               fte_freight_pricing.pricing_dual_instance_tab_type,
        p_pattern_rows            IN               fte_freight_pricing.top_level_pattern_tab_type,
        p_pricing_attribute_rows  IN OUT NOCOPY    fte_freight_pricing.pricing_attribute_tab_type,
        x_qp_output_line_rows     OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        x_qp_output_detail_rows   OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_return_status           OUT NOCOPY               VARCHAR2 )
 IS
l_return_status         VARCHAR2(1);
l_total_wt              NUMBER;
l_total_wt_uom          VARCHAR2(30);
l_event_num             NUMBER;
l_set_num               NUMBER;
i                       NUMBER;
l_attr_rec              fte_freight_pricing.pricing_attribute_rec_type;
l_temp_wt               NUMBER;
l_charge_applied        VARCHAR2(1);
l_deficit_wt_applied    VARCHAR2(1);
l_min_charge_comp_price NUMBER := NULL;
l_log_level  NUMBER := fte_freight_pricing_util.G_LOG;
  l_method_name VARCHAR2(50) := 'process_LTL';

--- Local Module ----
-- This procedure is to be called by process_LTL to check if we shipment satisfies conditions for LTL
FUNCTION check_LTL_eligible        (p_pattern_rows  IN fte_freight_pricing.top_level_pattern_tab_type)
RETURN VARCHAR2
IS
 i NUMBER;
 ret_value VARCHAR2(30);
l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
 BEGIN
    fte_freight_pricing_util.set_method(l_log_level,'check_LTL_eligible');
    ret_value := 'Y';  -- Y = OK, N = NO OK
    i := p_pattern_rows.FIRST;
    IF (i IS NOT NULL) THEN
    LOOP
      --only SC_WB and MC_WB are ok for LTL
      --IF NOT (p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_2
      --    OR p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_5 ) THEN
      -- loose items now have patterns too
      IF NOT (p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_2
          OR p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_5
          OR p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_9
          OR p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_10 ) THEN
           ret_value := 'N';
      END IF;
    EXIT WHEN ( i >= p_pattern_rows.LAST OR ret_value = 'N');
    i := p_pattern_rows.NEXT(i);
    END LOOP;
    END IF;
    fte_freight_pricing_util.unset_method(l_log_level,'check_LTL_eligible');
    RETURN ret_value;
END check_LTL_eligible;

--- End Local Module --

 BEGIN
    -- check if only patterns : SC_WB and MC_WB are present. Throw error if not.
    -- calculate the total wt. of the shipment by summing up wts. of top level items
    -- call deficit wt billing logic
    -- prepare request (lines, attributes and qualifiers)
    -- Attribute Total Item Quantity  uom for a line rec should match with that
    -- of the line ordered uom -- AG 05/05
    -- call qp engine
    -- call min charge logic
    -- prepare for second qp call
    -- call qp engine
    -- any post processing
    -- return control to main code
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   fte_freight_pricing_util.reset_dbg_vars;
   fte_freight_pricing_util.set_method(l_log_level,'process_LTL');

    -- Its ok for loose items not to have pattern rows. And loose items should always be eligible for LTL
    IF (p_pattern_rows.COUNT >0) THEN
       IF ( check_LTL_eligible (p_pattern_rows) = 'N') THEN
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'LTL Not eligible');
           raise fte_freight_pricing_util.g_not_eligible_for_LTL;
       END IF;
    END IF;


    IF (g_special_flags.deficit_wt_flag = 'Y') THEN
       -- process deficit wt.
       -- prepare engine input  (also make appropriate additions to original engine input rows)
            -- 1st Set (for y): send total_item_quantity = actual total
            -- 2nd Set (for x): send total_item_quantity = next wt. break
       -- call qp api
       -- (how does min charge mix with deficit wt.?)
       -- do deficit wt. calc and comparision
       -- delete unused set from engine rows and from qp input and output tables
       l_event_num := fte_qp_engine.G_LINE_EVENT_NUM;
       l_set_num   := 1;

       process_LTL_with_deficit_wt(
                  p_pricing_control_rec     => p_pricing_control_rec,
                  p_top_level_rows          => p_top_level_rows,
                  p_pricing_engine_rows     => p_pricing_engine_rows,
                  p_pricing_dual_instances  => p_pricing_dual_instances,
                  p_pattern_rows            => p_pattern_rows,
                  p_pricing_attribute_rows  => p_pricing_attribute_rows,
                  x_deficit_wt_applied      => l_deficit_wt_applied,    -- Added AG 5/10
                  x_min_charge_comp_price   => l_min_charge_comp_price, -- AG 5/10
                  x_qp_output_line_rows     => x_qp_output_line_rows,
                  x_qp_output_detail_rows   => x_qp_output_detail_rows,
                  x_return_status           => l_return_status);


            fte_freight_pricing_util.set_location(p_loc=>'after process_LTL_with_deficit_wt ');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_process_LTL_deficit_failed;
            END IF;
            IF nvl(l_deficit_wt_applied,'N') = 'Y' THEN
               l_set_num   := 2;
            END IF;

    ELSE

        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'===> Running Standard LTL ');

       -- get total shipment wt. Should take care of conversions.
       get_total_shipment_weight (p_top_level_rows => p_top_level_rows,
                               x_total_wt       => l_total_wt,
                               x_wt_uom         => l_total_wt_uom,
                               x_return_status  => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after get_total_shipment_weight ');
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_total_shipment_weight_failed;
           ELSE
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_total_wt = '||l_total_wt);
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_total_wt_uom = '||l_total_wt_uom);
           END IF;


       -- standard LTL
       -- prepare engine input
       -- add Total_Item_Quantity attributes
       -- call qp
       l_event_num := fte_qp_engine.G_LINE_EVENT_NUM;
       l_set_num   := 1;
       fte_qp_engine.create_control_record(p_event_num => l_event_num,
                                           x_return_status => l_return_status );
       i := p_pricing_engine_rows.FIRST;
       IF (i IS NOT NULL) THEN
       LOOP

            fte_qp_engine.create_line_record (p_pricing_control_rec       => p_pricing_control_rec,
                                              p_pricing_engine_input_rec  => p_pricing_engine_rows(i),
                                              x_return_status             => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create_control_record ');
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_control_record_failed;
           END IF;


            fte_qp_engine.prepare_qp_line_qualifiers(
                                              p_event_num               => l_event_num,
                                              p_pricing_control_rec       => p_pricing_control_rec,
                                              p_input_index             => p_pricing_engine_rows(i).input_index,
                                              x_return_status           => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create qp line qualifiers. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_qualifiers_failed;
           END IF;

            fte_qp_engine.prepare_qp_line_attributes (
                                              p_event_num               => l_event_num,
                                              p_input_index             => p_pricing_engine_rows(i).input_index,
                                              p_attr_rows               => p_pricing_attribute_rows,
                                              x_return_status           => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create qp line attributes. i='||i);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;

           -- Now create additional attributes

            l_attr_rec.attribute_index  := p_pricing_attribute_rows.LAST + 1;
            l_attr_rec.input_index      := p_pricing_engine_rows(i).input_index;
            l_attr_rec.attribute_name   := 'TOTAL_ITEM_QUANTITY';

            IF (p_pricing_engine_rows(i).line_uom <> l_total_wt_uom ) THEN
                l_temp_wt   :=  WSH_WV_UTILS.convert_uom(l_total_wt_uom,
                                                         p_pricing_engine_rows(i).line_uom,
                                                         l_total_wt,
                                                         0);  -- Within same UOM class
                l_attr_rec.attribute_value  := to_char(l_temp_wt);
            ELSE
                l_attr_rec.attribute_value  := to_char(l_total_wt);
            END IF;

            fte_qp_engine.create_attr_record(p_event_num               => l_event_num,
                                             p_attr_rec                => l_attr_rec,
                                             x_return_status           => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create attr record i='||i);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;

          -- Also add it to the original pricing attribute rows;
            p_pricing_attribute_rows(p_pricing_attribute_rows.LAST + 1) := l_attr_rec;


       EXIT WHEN i >= p_pricing_engine_rows.LAST;
       i := p_pricing_engine_rows.NEXT(i);
       END LOOP;
       END IF;

       -- call qp api
       fte_qp_engine.call_qp_api    ( x_qp_output_line_rows    => x_qp_output_line_rows,
                                      x_qp_output_detail_rows  => x_qp_output_detail_rows,
                                      x_return_status          => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after call_qp_api: Event 1');
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise fte_freight_pricing_util.g_qp_price_request_failed_2;
                 END IF;
           END IF;

       --check for errors in the output
           fte_qp_engine.check_qp_output_errors (x_return_status   => l_return_status);
           fte_freight_pricing_util.set_location(p_loc=>'after check_qp_output_errors: Event '||l_event_num);
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise fte_freight_pricing_util.g_qp_price_request_failed_2;
                 END IF;
           END IF;

    END IF; -- standard LTL

    post_process(
      p_event_num		=> l_event_num,
      p_set_num			=> l_set_num,
      p_comp_with_price		=> l_min_charge_comp_price,
      p_pricing_engine_rows	=> p_pricing_engine_rows,
      p_pricing_dual_instances	=> p_pricing_dual_instances,
      x_qp_output_line_rows	=> x_qp_output_line_rows,
      x_qp_output_detail_rows	=> x_qp_output_detail_rows,
      x_return_status		=> l_return_status);

    fte_freight_pricing_util.set_location(p_loc=>'after post_process');
    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
        l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
      raise fte_freight_pricing_util.g_post_process_failed;
    END IF;

 fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');
 EXCEPTION
      WHEN fte_freight_pricing_util.g_post_process_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_post_process_failed');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN fte_freight_pricing_util.g_not_eligible_for_LTL THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_not_eligible_for_LTL') ;
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');
      WHEN fte_freight_pricing_util.g_create_control_record_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_control_record_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');
      WHEN fte_freight_pricing_util.g_create_line_record_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_line_record_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');
      WHEN fte_freight_pricing_util.g_create_qualifiers_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_qualifiers_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');
      WHEN fte_freight_pricing_util.g_create_attr_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_attr_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');
      WHEN fte_freight_pricing_util.g_process_LTL_deficit_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_process_LTL_deficit_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');
      WHEN fte_freight_pricing_util.g_resolve_pricing_objective THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_resolve_pricing_objective');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');
      WHEN fte_freight_pricing_util.g_apply_min_charge THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_apply_min_charge');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');
      WHEN fte_freight_pricing_util.g_total_shipment_weight_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_total_shipment_weight_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');
      WHEN fte_freight_pricing_util.g_qp_price_request_failed_2 THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_qp_price_request_failed_2');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');
      WHEN fte_freight_pricing_util.g_prepare_next_event_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_prepare_next_event_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'process_LTL');

END process_LTL;

PROCEDURE print_rolledup_lines (
        p_rolledup_lines          IN    fte_freight_pricing.rolledup_line_tab_type,
        x_return_status           OUT NOCOPY    VARCHAR2 )
IS

       i     NUMBER:=0;

BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_rolledup_lines.COUNT > 0 THEN
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '<ROLLEDUP_LINES>');
   i := p_rolledup_lines.FIRST;
   LOOP

      FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'delivery_detail_id : '||p_rolledup_lines(i).delivery_detail_id||' category_id : '||p_rolledup_lines(i).category_id||' rate_basis : '||
   p_rolledup_lines(i).rate_basis||'container_id : '||p_rolledup_lines(i).container_id||' master_container_id : '||p_rolledup_lines(i).master_container_id||'line_quantity : '||
   p_rolledup_lines(i).line_quantity||' line_uom : '||p_rolledup_lines(i).line_uom);

      EXIT WHEN i=p_rolledup_lines.LAST;
      i := p_rolledup_lines.NEXT(i);
   END LOOP;
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '</ROLLEDUP_LINES>');
   END IF;

   IF g_bumped_rolledup_lines.COUNT > 0 THEN
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '<BUMPED_ROLLEDUP_LINES>');
   i := g_bumped_rolledup_lines.FIRST;
   LOOP

      FTE_FREIGHT_PRICING_UTIL.print_msg(p_msg => 'index : '||i||' line_quantity : '||g_bumped_rolledup_lines(i).line_quantity);

      EXIT WHEN i=g_bumped_rolledup_lines.LAST;
      i := g_bumped_rolledup_lines.NEXT(i);
   END LOOP;
   FTE_FREIGHT_PRICING_UTIL.print_tag(p_msg => '</BUMPED_ROLLEDUP_LINES>');
   END IF;

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('print_rolledup_lines',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
END print_rolledup_lines;

-- new for loose items
PROCEDURE bumpup_rolledup_lines (
        p_pricing_engine_input_rec  IN              fte_freight_pricing.pricing_engine_input_rec_type,
        p_pricing_dual_instances  IN                fte_freight_pricing.pricing_dual_instance_tab_type,
        p_pattern_rows            IN                fte_freight_pricing.top_level_pattern_tab_type,
        p_orig_line_qty           IN                NUMBER,
        p_orig_uom                IN                VARCHAR2,
        p_new_line_qty            IN                NUMBER,
        p_new_uom                 IN                VARCHAR2,
        x_return_status           OUT NOCOPY                VARCHAR2 )
IS
   i                     NUMBER;
   l_content_id          NUMBER;
   l_instance_idx        NUMBER;
   l_temp_qty            NUMBER;
   l_temp_uom            VARCHAR2(10);
   l_ratio_num           NUMBER;
   l_ratio_den           NUMBER;
   l_aggregation         VARCHAR2(30);

   l_return_status         VARCHAR2(1);
   l_engine_input_rec      fte_freight_pricing.pricing_engine_input_rec_type;
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'bumpup_rolledup_lines';
BEGIN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   fte_freight_pricing_util.reset_dbg_vars;
   -- find ratio of new qty to orig qty for pricing engine input row
   -- make sure we are dealing with loose item only
   -- get instance id from engine row
   -- find pattern rows for engine row
   -- for each pattern row, get content_id
   -- for each content id get rolledup rows (same as content id for loose items)
   -- only get rollup lines which match category and basis on engine row
   -- bump up each rolledup row

   IF (p_new_uom <> p_orig_uom) THEN
      l_temp_qty    :=  WSH_WV_UTILS.convert_uom(p_new_uom,
                                              p_orig_uom,
                                              p_new_line_qty,
                                              0);  -- Within same UOM class

      l_temp_uom    := p_orig_uom;
   ELSE
      l_temp_qty    := p_new_line_qty;
      l_temp_uom    := p_new_uom;
   END IF;

   l_ratio_num   := l_temp_qty;       -- converted new line qty
   l_ratio_den   := p_orig_line_qty;  -- original line qty


   IF (p_pricing_engine_input_rec.loose_item_flag = 'Y') THEN
      l_instance_idx := p_pricing_engine_input_rec.instance_index;
      l_aggregation := p_pricing_dual_instances(l_instance_idx).aggregation;
      i := p_pattern_rows.FIRST;
      IF (i IS NOT NULL) THEN
      LOOP
        IF (p_pattern_rows(i).instance_index = l_instance_idx ) THEN
          l_content_id := p_pattern_rows(i).content_id;

	  IF (l_aggregation = 'ACROSS') THEN

          IF  (nvl(fte_freight_pricing.g_rolledup_lines(l_content_id).rate_basis,-1)
                      = nvl(p_pricing_engine_input_rec.basis,-1) ) THEN
              fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_content_id='||l_content_id);
              fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'orig->'||fte_freight_pricing.g_rolledup_lines(l_content_id).line_quantity);

              --fte_freight_pricing.g_rolledup_lines(l_content_id).line_quantity :=
                     --(fte_freight_pricing.g_rolledup_lines(l_content_id).line_quantity * l_ratio_num) / l_ratio_den;
              --bug2803178 keep both the original and  bumped rolledup line quantity
              -- if hundred wt rate is chosed, bumped rolledup line quantity is used later
              -- if standard rate is chosed, original rolledup line quantity is used later
              g_bumped_rolledup_lines(l_content_id).line_quantity :=
                     (fte_freight_pricing.g_rolledup_lines(l_content_id).line_quantity * l_ratio_num) / l_ratio_den;

              fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'bumpedup->'||g_bumped_rolledup_lines(l_content_id).line_quantity);
          END IF;

	  ELSE -- 'WITHIN'

          IF ( nvl(fte_freight_pricing.g_rolledup_lines(l_content_id).category_id,-1)
                      = nvl(p_pricing_engine_input_rec.category_id,-1)
            AND nvl(fte_freight_pricing.g_rolledup_lines(l_content_id).rate_basis,-1)
                      = nvl(p_pricing_engine_input_rec.basis,-1) ) THEN
              fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_content_id='||l_content_id);
              fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'orig->'||fte_freight_pricing.g_rolledup_lines(l_content_id).line_quantity);

              --fte_freight_pricing.g_rolledup_lines(l_content_id).line_quantity :=
                     --(fte_freight_pricing.g_rolledup_lines(l_content_id).line_quantity * l_ratio_num) / l_ratio_den;
              --bug2803178 keep both the original and  bumped rolledup line quantity
              -- if hundred wt rate is chosed, bumped rolledup line quantity is used later
              -- if standard rate is chosed, original rolledup line quantity is used later
              g_bumped_rolledup_lines(l_content_id).line_quantity :=
                     (fte_freight_pricing.g_rolledup_lines(l_content_id).line_quantity * l_ratio_num) / l_ratio_den;

              fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'bumpedup->'||g_bumped_rolledup_lines(l_content_id).line_quantity);
          END IF;

	  END IF; -- aggregation

        END IF;
      EXIT WHEN ( i >= p_pattern_rows.LAST );
      i := p_pattern_rows.NEXT(i);
      END LOOP;
      END IF;

   END IF;

 EXCEPTION
 WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'bumpup_rolledup_lines');
END bumpup_rolledup_lines;


-- This is called for Parcel
PROCEDURE process_Parcel (
        p_pricing_control_rec     IN                fte_freight_pricing.pricing_control_input_rec_type,
        p_top_level_rows          IN                fte_freight_pricing.shpmnt_content_tab_type,
        p_pricing_engine_rows     IN OUT NOCOPY     fte_freight_pricing.pricing_engine_input_tab_type,
        p_pricing_dual_instances  IN                fte_freight_pricing.pricing_dual_instance_tab_type,
        p_pattern_rows            IN                fte_freight_pricing.top_level_pattern_tab_type,
        p_pricing_attribute_rows  IN OUT NOCOPY     fte_freight_pricing.pricing_attribute_tab_type,
        --p_pricing_qualifier       IN                fte_qual_rec_type,
        --x_qp_output_line_rows     IN OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        --x_qp_output_detail_rows   IN OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_qp_output_line_rows     OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        x_qp_output_detail_rows   OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_return_status           OUT NOCOPY                VARCHAR2 )
IS

   l_return_status         VARCHAR2(1);
   l_total_wt              NUMBER;
   l_total_wt_uom          VARCHAR2(30);
   l_min_package_wt        NUMBER;
   l_min_wt_uom            VARCHAR2(30);
   l_event_num             NUMBER;
   l_set_num               NUMBER;
   i                       NUMBER;
   j                       NUMBER;
   l_attr_rec              fte_freight_pricing.pricing_attribute_rec_type;
   l_temp_wt               NUMBER;
   l_charge_applied        VARCHAR2(1);
   l_next_weight_break     NUMBER;
   l_next_weight_break_uom VARCHAR2(30);
   l_curr_last_idx         NUMBER;
   l_curr_input_idx        NUMBER;
   l_set_one_max_input_idx NUMBER;
   l_engine_input_rec      fte_freight_pricing.pricing_engine_input_rec_type;
   l_attr_row              fte_freight_pricing.pricing_attribute_rec_type;
   l_new_index             NUMBER;

   l_standard_price        NUMBER;
   l_hundredwt_price       NUMBER;
   l_bumped_up_wt          NUMBER;
   l_bumped_up_wt_uom      VARCHAR2(30);
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'process_Parcel';
   l_op_ret_code           NUMBER;
   l_letter_flag           VARCHAR2(1) := 'N';
   l_parcel_elig_flag      VARCHAR2(1);
   l_bump                  VARCHAR2(1);
--- Local Module ----
-- This procedure is to be called by process_Parcel to check if we shipment satisfies conditions for Parcel
FUNCTION check_parcel_eligible        (p_pattern_rows  IN fte_freight_pricing.top_level_pattern_tab_type)
RETURN VARCHAR2
IS
 i NUMBER;
 ret_value VARCHAR2(30);
l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'check_parcel_eligible';
 BEGIN
   fte_freight_pricing_util.set_method(l_log_level,'check_parcel_eligible');
    ret_value := 'Y';  -- Y = OK, N = NOT OK, L = Letter
    i := p_pattern_rows.FIRST;
    IF (i IS NOT NULL) THEN
    LOOP
      --only SC_WB and MC_WB are ok for Parcel (except Letter - SC_CB or MC_CB )
      -- currently you cannot have a mix of Letter and standard parcel because they are
      -- separate service types. A parcel lane can have only one service type.
      -- fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'i='||i||' pattern='||p_pattern_rows(i).pattern_no);
      -- IF NOT (p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_2
      --    OR p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_5
      -- Loose items now have patterns
      IF NOT (p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_2
          OR p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_5
          OR p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_9
          OR p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_10 ) THEN
              IF (p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_1
                 OR p_pattern_rows(i).pattern_no = FTE_FREIGHT_PRICING.G_PATTERN_4 ) THEN
                    ret_value := 'L';
              ELSE
                    ret_value := 'N';
              END IF;
      END IF;
      -- fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'i='||i||' ret_value ='||ret_value);
    EXIT WHEN ( i >= p_pattern_rows.LAST OR ret_value = 'N');
    i := p_pattern_rows.NEXT(i);
    END LOOP;
    END IF;
   fte_freight_pricing_util.unset_method(l_log_level,'check_parcel_eligible');
    RETURN ret_value;
END check_parcel_eligible;

--- End Local Module --

  -- local module --
  -- get the min package wt parameter
  PROCEDURE get_min_package_wt (x_min_package_wt  OUT NOCOPY  NUMBER,
                                x_min_wt_uom      OUT NOCOPY  VARCHAR2)
  IS
       i                NUMBER;
       min_package_wt   NUMBER := 0;
       min_wt_uom       VARCHAR2(30) := NULL;
  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'get_min_package_wt';
 BEGIN
     fte_freight_pricing_util.set_method(l_log_level,'get_min_package_wt');
     i := g_lane_parameters.FIRST;
     IF (i IS NOT NULL) THEN
     LOOP
         IF (g_lane_parameters(i).parameter_sub_type = 'HUNDREDWT'
             AND g_lane_parameters(i).lane_function = 'PARCEL'
             AND g_lane_parameters(i).parameter_name = 'MIN_PACKAGE_WT') THEN
                min_package_wt  := fnd_number.canonical_to_number(g_lane_parameters(i).value_from);
                min_wt_uom      := g_lane_parameters(i).uom_code;
         END IF;

     EXIT WHEN (i >= g_lane_parameters.LAST);
         i := g_lane_parameters.NEXT(i);
     END LOOP;
     END IF;
     x_min_package_wt   := min_package_wt;
     x_min_wt_uom       := min_wt_uom;
     fte_freight_pricing_util.unset_method(l_log_level,'get_min_package_wt');
  EXCEPTION
    WHEN others THEN
      fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
      fte_freight_pricing_util.unset_method(l_log_level, l_method_name);
  END  get_min_package_wt;
  -- end local module --


 BEGIN

    -- check if only patterns : SC_WB and MC_WB are present. Throw error if not.
    -- calculate the total wt. of the shipment by summing up wts. of top level items in the same uom.
    -- we need to check for multi-piece only if shipment has more than 1 container
    -- create set 1 : for standard parcel rates
            -- create standard lines
            -- create standard pricing attributes and qualifiers
    -- calculate total shipment wt (here the individual packages are bumped up to the min package wts. if required )
    -- create set 2 (if needed) : for hundred wt
            -- create standard lines
            -- need to bump up individual package wt to min wt.***
            -- create standard pricing attributes and qualifiers
            -- create attributes for total shipment wt (with bump ups)
    -- call qp engine
    -- calculate total price of set. Choose the least price i.e. delete the set which has higher price.
    -- call pricing objective resolution if needed
    -- call min charge logic if needed
    -- prepare for second qp call
    -- call qp engine
    -- any post processing
    -- return control to main code

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   fte_freight_pricing_util.reset_dbg_vars;
   fte_freight_pricing_util.set_method(l_log_level,'process_Parcel');

    -- Its ok for loose items not to have pattern rows. And loose items should always be eligible for LTL
    IF (p_pattern_rows.COUNT >0) THEN
       l_parcel_elig_flag := check_parcel_eligible (p_pattern_rows);
       IF ( l_parcel_elig_flag  = 'N') THEN
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Parcel Not eligible');
           raise fte_freight_pricing_util.g_parcel_not_eligible;
       END IF;

       IF ( l_parcel_elig_flag  = 'L') THEN
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Parcel Letter eligible');
                 process_others(p_pricing_control_rec     => p_pricing_control_rec,
                                p_pricing_engine_rows     => p_pricing_engine_rows,
                                p_top_level_rows          => p_top_level_rows,
                                p_pricing_dual_instances  => p_pricing_dual_instances,
                                p_pattern_rows            => p_pattern_rows,
                                p_pricing_attribute_rows  => p_pricing_attribute_rows,
                                --p_pricing_qualifier     => p_pricing_qualifier,
                                x_qp_output_line_rows     => x_qp_output_line_rows,
                                x_qp_output_detail_rows   => x_qp_output_detail_rows,
                                x_return_status           => l_return_status );
            fte_freight_pricing_util.set_location(p_loc=>'after process_others ');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_process_others_failed;
            END IF;
            fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
            RETURN;
       END IF;

    END IF;

/*
    -- get total shipment wt (with package wts bumped up to a min. wt)
    get_total_shipment_weight(         p_top_level_rows    =>   p_top_level_rows,
                                       p_min_package_wt    =>   l_min_package_wt,
                                       p_min_wt_uom        =>   l_min_wt_uom,
                                       x_total_wt          =>   l_total_wt,
                                       x_wt_uom            =>   l_total_wt_uom,
                                       x_return_status     =>   l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after get_total_shipment_weight ');
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_total_shipment_weight_failed;
           ELSE
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_total_wt = '||l_total_wt);
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_total_wt_uom = '||l_total_wt_uom);
           END IF;
*/
       l_event_num := fte_qp_engine.G_LINE_EVENT_NUM;
       fte_qp_engine.create_control_record(p_event_num => l_event_num,
                                           x_return_status => l_return_status );

           fte_freight_pricing_util.set_location(p_loc=>'after create_control_record ');
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_control_record_failed;
           END IF;

     -- create set I ( for standard rate checking ) --
       l_set_num   := 1;
       i := p_pricing_engine_rows.FIRST;
       IF (i IS NOT NULL) THEN
       LOOP
            -- The original package quantity (wt) is ceil-ed to the next higher integer
            -- eg. 10.2 Lbs becomes 11 Lbs

	    --4720306
            --p_pricing_engine_rows(i).line_quantity  := ceil(p_pricing_engine_rows(i).line_quantity);

            fte_qp_engine.create_line_record (p_pricing_control_rec       => p_pricing_control_rec,
                                              p_pricing_engine_input_rec  => p_pricing_engine_rows(i),
                                              x_return_status             => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create_line_record. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_line_record_failed;
           END IF;

            fte_qp_engine.prepare_qp_line_qualifiers(
                                              p_event_num               => l_event_num,
                                              p_pricing_control_rec       => p_pricing_control_rec,
                                              p_input_index             => p_pricing_engine_rows(i).input_index,
                                              x_return_status           => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create qp line qualifiers. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_qualifiers_failed;
           END IF;

            fte_qp_engine.prepare_qp_line_attributes (
                                              p_event_num               => l_event_num,
                                              p_input_index             => p_pricing_engine_rows(i).input_index,
                                              p_attr_rows               => p_pricing_attribute_rows,
                                              x_return_status           => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create qp line attributes. i='||i);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;


           /* TEST MULTIPIECE FLAG  --BEGIN*/

            l_attr_rec.attribute_index  := p_pricing_attribute_rows(p_pricing_attribute_rows.COUNT).attribute_index + 1;
            l_attr_rec.input_index      := i;
            l_attr_rec.attribute_name   := 'MULTIPIECE_FLAG';
            l_attr_rec.attribute_value  := 'N';

            fte_qp_engine.create_attr_record(  p_event_num              => l_event_num,
                                               p_attr_rec               => l_attr_rec,
                                               x_return_status          => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create_attr_record ');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;

           /* TEST MULTIPIECE FLAG  --END*/


       EXIT WHEN i >= p_pricing_engine_rows.LAST;
       i := p_pricing_engine_rows.NEXT(i);
       END LOOP;
       END IF;


    IF g_special_flags.parcel_hundredwt_flag = 'Y' THEN

      -- create set II ( for hundred wt rate checking ) --
      -- only if multipiece

    -- get min. package wt. parameter
    get_min_package_wt(l_min_package_wt, l_min_wt_uom);
   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_min_package_wt '||l_min_package_wt);
   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_min_wt_uom '||l_min_wt_uom);

       l_set_num   := 2;
       i := p_pricing_engine_rows.FIRST; -- counter for set 1 engine rows
       l_curr_last_idx  := p_pricing_engine_rows.LAST; --last set 1 engine row (because only set1 should exist now)
       l_new_index := l_curr_last_idx + 1;
       IF (i IS NOT NULL) THEN
       LOOP
            l_curr_input_idx                     := p_pricing_engine_rows(i).input_index; --should be the same as i

            -- copy current row to new row with set = 2 starting with line index as max line index + 1
            l_engine_input_rec                   := p_pricing_engine_rows(i);
            l_engine_input_rec.input_index       := l_new_index;
            l_engine_input_rec.input_set_number  := l_set_num;


            --bump up ind. package wts to min package wt.
            get_bumped_up_package_weight  (p_wt                =>  l_engine_input_rec.line_quantity,
                                          p_wt_uom             =>  l_engine_input_rec.line_uom,
                                          p_min_package_wt     =>  l_min_package_wt,
                                          p_min_wt_uom         =>  l_min_wt_uom,
                                          x_new_wt             =>  l_bumped_up_wt,
                                          x_new_wt_uom         =>  l_bumped_up_wt_uom,
                                          x_bump               =>  l_bump,
                                          x_return_status      =>  l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after get_bumped_up_package_weight');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_get_bumped_up_wt_failed;
            END IF;

	    -- calculate the total shipment weight
	    IF (l_total_wt is null OR l_total_wt <= 0) THEN
		l_total_wt     := l_bumped_up_wt;
	   	l_total_wt_uom := l_bumped_up_wt_uom;
	    ELSE

              IF (l_bumped_up_wt_uom <> l_total_wt_uom ) THEN
                l_temp_wt   :=  WSH_WV_UTILS.convert_uom(l_bumped_up_wt_uom,
							 l_total_wt_uom,
                                                         l_bumped_up_wt,
                                                         0);  -- Within same UOM class
		l_total_wt := l_total_wt + l_temp_wt;
              ELSE
		l_total_wt := l_total_wt + l_bumped_up_wt;
              END IF;

	    END IF; -- calculate total shipment weight

            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_engine_input_rec.loose_item_flag='||l_engine_input_rec.loose_item_flag);
            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_bump='||l_bump);

            -- new for loose item
            -- bump up rolled up lines - prorate
            IF (l_engine_input_rec.loose_item_flag = 'Y' AND l_bump = 'Y') THEN
              --bump up
              fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'bump up rolled up');
              bumpup_rolledup_lines (
                 p_pricing_engine_input_rec  =>l_engine_input_rec,
                 p_pricing_dual_instances    =>p_pricing_dual_instances,
                 p_pattern_rows              => p_pattern_rows,
                 p_orig_line_qty             => l_engine_input_rec.line_quantity,
                 p_orig_uom                  => l_engine_input_rec.line_uom,
                 p_new_line_qty              => l_bumped_up_wt,
                 p_new_uom                   => l_bumped_up_wt_uom,
                 x_return_status             => l_return_status);

                 fte_freight_pricing_util.set_location(p_loc=>'after bumpup_rolledup_lines');
                 IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                      l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                             raise fte_freight_pricing_util.g_get_bumped_up_wt_failed;
                 END IF;

		print_rolledup_lines(
		  p_rolledup_lines => fte_freight_pricing.g_rolledup_lines,
		  x_return_status  => l_return_status);
            END IF;

            l_engine_input_rec.line_quantity      := l_bumped_up_wt;
            l_engine_input_rec.line_uom           := l_bumped_up_wt_uom;

            p_pricing_engine_rows(l_new_index)   := l_engine_input_rec;

            -- prepare line rec
            fte_qp_engine.create_line_record (p_pricing_control_rec       => p_pricing_control_rec,
                                              p_pricing_engine_input_rec  => l_engine_input_rec,
                                              x_return_status             => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create_line_record. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_line_record_failed;
           END IF;

            --prepare qualifiers
            fte_qp_engine.prepare_qp_line_qualifiers(
                                              p_event_num               => l_event_num,
                                              p_pricing_control_rec     => p_pricing_control_rec,
                                              p_input_index             => l_new_index,
                                              x_return_status           => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create qp line qualifiers. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_qualifiers_failed;
           END IF;

            -- prepare attributes from the attr rows. line indexes need to be changed
            j := p_pricing_attribute_rows.FIRST;
            IF (j IS NOT NULL) THEN
            LOOP
                IF (p_pricing_attribute_rows(j).input_index = l_curr_input_idx ) THEN
                    l_attr_rec                 := p_pricing_attribute_rows(j);
                    l_attr_rec.input_index     := l_new_index;
                    l_attr_rec.attribute_index := p_pricing_attribute_rows(p_pricing_attribute_rows.COUNT).attribute_index + 1;

                    p_pricing_attribute_rows(l_attr_rec.attribute_index) := l_attr_rec;

                    fte_qp_engine.create_attr_record (     p_event_num              => l_event_num,
                                                           p_attr_rec               => l_attr_rec,
                                                           x_return_status          => l_return_status);

                    fte_freight_pricing_util.set_location(p_loc=>'after create_attr_record');
                    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                          l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                                 raise fte_freight_pricing_util.g_create_attr_failed;
                    END IF;

                END IF;
            EXIT WHEN j = p_pricing_attribute_rows.LAST;
            j := p_pricing_attribute_rows.NEXT(j);
            END LOOP;
            END IF;

            -- add other default attributes --
            l_attr_rec.attribute_index  := p_pricing_attribute_rows(p_pricing_attribute_rows.COUNT).attribute_index + 1;
            l_attr_rec.input_index      := l_new_index;
            l_attr_rec.attribute_name   := 'ITEM_ALL';
            l_attr_rec.attribute_value  := 'ALL';

            fte_qp_engine.create_attr_record(  p_event_num              => l_event_num,
                                               p_attr_rec               => l_attr_rec,
                                               x_return_status          => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create_attr_record ');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;
	    /*
            -- add other new attributes --
            -- VOLUME:TOTAL_ITEM_QUANTITY
            l_attr_rec.attribute_index  := p_pricing_attribute_rows.LAST + 1;
            l_attr_rec.input_index      := l_new_index;
            l_attr_rec.attribute_name   := 'TOTAL_ITEM_QUANTITY';

            IF (p_pricing_engine_rows(i).line_uom <> l_total_wt_uom ) THEN
                l_temp_wt   :=  WSH_WV_UTILS.convert_uom(l_total_wt_uom,
                                                         p_pricing_engine_rows(i).line_uom,
                                                         l_total_wt,
                                                         0);  -- Within same UOM class
                l_attr_rec.attribute_value  := to_char(l_temp_wt);
            ELSE
                l_attr_rec.attribute_value  := to_char(l_total_wt);
            END IF;

            fte_qp_engine.create_attr_record(p_event_num               => l_event_num,
                                             p_attr_rec                => l_attr_rec,
                                             x_return_status           => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create_attr_record ');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;
            */
           /* TEST MULTIPIECE FLAG  --BEGIN*/

            l_attr_rec.attribute_index  :=  p_pricing_attribute_rows.LAST + 1;
            l_attr_rec.input_index      := l_new_index;
            l_attr_rec.attribute_name   := 'MULTIPIECE_FLAG';
            l_attr_rec.attribute_value  := 'Y';

            fte_qp_engine.create_attr_record(  p_event_num              => l_event_num,
                                               p_attr_rec               => l_attr_rec,
                                               x_return_status          => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create_attr_record ');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;

           /* TEST MULTIPIECE FLAG  --END*/

           /*
            -- LOGISTICS:TOTAL_SHIPMENT_QUANTITY
            l_attr_rec.attribute_index  := p_pricing_attribute_rows.LAST + 1;
            l_attr_rec.input_index      := l_new_index;
            l_attr_rec.attribute_name   := 'TOTAL_SHIPMENT_QUANTITY';

            IF (p_pricing_engine_rows(i).line_uom <> l_total_wt_uom ) THEN
                l_attr_rec.attribute_value  := to_char(l_temp_wt);
            ELSE
                l_attr_rec.attribute_value  := to_char(l_total_wt);
            END IF;

            fte_qp_engine.create_attr_record(p_event_num               => l_event_num,
                                             p_attr_rec                => l_attr_rec,
                                             x_return_status           => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create_attr_record ');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;
           */


       EXIT WHEN i >= l_curr_last_idx;
       i := p_pricing_engine_rows.NEXT(i);
       l_new_index := l_new_index + 1;
       END LOOP;  -- engine rows
       END IF;

       fte_freight_pricing_util.print_msg(l_log_level,'l_total_wt: '||l_total_wt);
       fte_freight_pricing_util.print_msg(l_log_level,'l_total_wt_uom: '||l_total_wt_uom);

       -- add TOTAL_ITEM_QUANTITY attribute for second set
       i := l_curr_last_idx;
       IF (i IS NOT NULL) THEN
	 i := i + 1;
       LOOP

            -- add other new attributes --
            -- VOLUME:TOTAL_ITEM_QUANTITY
            l_attr_rec.attribute_index  := p_pricing_attribute_rows.LAST + 1;
            l_attr_rec.input_index      := p_pricing_engine_rows(i).input_index;
            l_attr_rec.attribute_name   := 'TOTAL_ITEM_QUANTITY';

            IF (p_pricing_engine_rows(i).line_uom <> l_total_wt_uom ) THEN
                l_temp_wt   :=  WSH_WV_UTILS.convert_uom(l_total_wt_uom,
                                                         p_pricing_engine_rows(i).line_uom,
                                                         l_total_wt,
                                                         0);  -- Within same UOM class
                l_attr_rec.attribute_value  := to_char(l_temp_wt);
            ELSE
                l_attr_rec.attribute_value  := to_char(l_total_wt);
            END IF;

            fte_qp_engine.create_attr_record(p_event_num               => l_event_num,
                                             p_attr_rec                => l_attr_rec,
                                             x_return_status           => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create_attr_record ');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;

       EXIT WHEN i >= p_pricing_engine_rows.LAST;
       i := p_pricing_engine_rows.NEXT(i);
       END LOOP;  -- engine rows
       END IF;

    END IF;  -- g_special_flags.parcel_hundredwt_flag
       -- call qp api
       fte_qp_engine.call_qp_api    ( x_qp_output_line_rows    => x_qp_output_line_rows,
                                      x_qp_output_detail_rows  => x_qp_output_detail_rows,
                                      x_return_status          => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after call_qp_api');
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise fte_freight_pricing_util.g_qp_price_request_failed_2;
                 END IF;
           END IF;

       --check for errors in the output
           --fte_qp_engine.check_qp_output_errors (x_return_status   => l_return_status);

             fte_qp_engine.check_parcel_output_errors (p_event_num   => l_event_num,
                                                       x_return_code => l_op_ret_code,
                                                       x_return_status  => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after check_parcel_output_errors: Event '||l_event_num);
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_return_status = '||l_return_status);
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_op_ret_code = '||l_op_ret_code);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise fte_freight_pricing_util.g_qp_price_request_failed_2;
                 END IF;
           END IF;

     IF g_special_flags.parcel_hundredwt_flag = 'Y' THEN

       IF (l_op_ret_code = fte_qp_engine.G_PAR_NO_MP_PRICE) THEN
          --multipiece prices not found.
          --standard rates apply
          --delete any set=2 lines that may exist
                l_set_num :=2; --set to delete
                fte_qp_engine.delete_set_from_line_event( p_set_num       => l_set_num,
                                                          x_return_status => l_return_status);

                fte_freight_pricing_util.set_location(p_loc=>'after delete_set_from_line_event. set= '||l_set_num);
                IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                      l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                             raise fte_freight_pricing_util.g_delete_set_failed;
                END IF;

                --bug2803178
		g_bumped_rolledup_lines.DELETE;

                l_set_num :=1; -- remaining set apply_min_charge to be called with this
       ELSIF (l_op_ret_code = fte_qp_engine.G_PAR_NO_SP_PRICE) THEN
          --singlepiece prices not found.
          --use hundred wt rates
          --delete any set=1 lines that may exist
                l_set_num :=1; --set to delete
                fte_qp_engine.delete_set_from_line_event( p_set_num       => l_set_num,
                                                          x_return_status => l_return_status);

                fte_freight_pricing_util.set_location(p_loc=>'after delete_set_from_line_event. set= '||l_set_num);
                IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                      l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                             raise fte_freight_pricing_util.g_delete_set_failed;
                END IF;

                --bug2803178
                i := g_bumped_rolledup_lines.FIRST;
		IF (i is not null) THEN
		LOOP
		  fte_freight_pricing.g_rolledup_lines(i).line_quantity
		    := g_bumped_rolledup_lines(i).line_quantity;
		EXIT WHEN i>= g_bumped_rolledup_lines.LAST;
		i := g_bumped_rolledup_lines.NEXT(i);
		END LOOP; -- g_bumped_rolledup_lines
		END IF;
		g_bumped_rolledup_lines.DELETE;

                l_set_num :=2; -- remaining set apply_min_charge to be called with this
       ELSE -- l_op_ret_code = 0
         -- singlepiece and multipiece rates are both found
         -- compare the rates and use the lower rates
           l_set_num :=1;
           fte_qp_engine.get_total_base_price(p_set_num           => l_set_num,
                                          x_price  => l_standard_price ,
                                          x_return_status  => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after get_total_base_price for set='||l_set_num);
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise FTE_FREIGHT_PRICING_UTIL.g_total_base_price_failed;
                 END IF;
           ELSE
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_standard_price = '||l_standard_price);
           END IF;

           l_set_num :=2;
           fte_qp_engine.get_total_base_price(p_set_num           => l_set_num,
                                              x_price  => l_hundredwt_price,
                                              x_return_status  => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after get_total_base_price for set='||l_set_num);
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                            raise fte_freight_pricing_util.g_total_base_price_failed;
                     END IF;
           ELSE
                     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_hundredwt_price= '||l_hundredwt_price);
           END IF;

           IF (l_standard_price <= l_hundredwt_price) THEN
              -- standard rates apply. delete set 2
                 l_set_num :=2; --set to delete
                 fte_qp_engine.delete_set_from_line_event( p_set_num       => l_set_num,
                                                          x_return_status => l_return_status);

                fte_freight_pricing_util.set_location(p_loc=>'after delete_set_from_line_event. set= '||l_set_num);
                IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                      l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                             raise fte_freight_pricing_util.g_delete_set_failed;
                END IF;

                --bug2803178
		g_bumped_rolledup_lines.DELETE;

                l_set_num :=1; -- remaining set apply_min_charge to be called with this
           ELSE
              -- hundredwt rates apply. delete set 1
                 l_set_num :=1; --set to delete
                 fte_qp_engine.delete_set_from_line_event( p_set_num       => l_set_num,
                                                          x_return_status => l_return_status);

                fte_freight_pricing_util.set_location(p_loc=>'after delete_set_from_line_event. set= '||l_set_num);
                IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                      l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                             raise fte_freight_pricing_util.g_delete_set_failed;
                END IF;

                --bug2803178
                i := g_bumped_rolledup_lines.FIRST;
		IF (i is not null) THEN
		LOOP
		  fte_freight_pricing.g_rolledup_lines(i).line_quantity
		    := g_bumped_rolledup_lines(i).line_quantity;
		EXIT WHEN i>= g_bumped_rolledup_lines.LAST;
		i := g_bumped_rolledup_lines.NEXT(i);
		END LOOP; -- g_bumped_rolledup_lines
		END IF;
		g_bumped_rolledup_lines.DELETE;

                l_set_num :=2; -- remaining set apply_min_charge to be called with this
           END IF;
       END IF; -- l_op_ret_code

     END IF;  -- g_special_flags.parcel_hundredwt_flag

     print_rolledup_lines(
	p_rolledup_lines => fte_freight_pricing.g_rolledup_lines,
	x_return_status  => l_return_status);

     --*** IMP ---
   FTE_QP_ENGINE.get_qp_output(
     x_qp_output_line_rows    	=> x_qp_output_line_rows,
     x_qp_output_detail_rows  	=> x_qp_output_detail_rows,
     x_return_status		=> l_return_status);

   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
       l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
         raise fte_freight_pricing_util.g_get_qp_output_failed;
   END IF;

    post_process(
      p_event_num		=> l_event_num,
      p_set_num			=> l_set_num,
      p_pricing_engine_rows	=> p_pricing_engine_rows,
      p_pricing_dual_instances	=> p_pricing_dual_instances,
      x_qp_output_line_rows	=> x_qp_output_line_rows,
      x_qp_output_detail_rows	=> x_qp_output_detail_rows,
      x_return_status		=> l_return_status);

    fte_freight_pricing_util.set_location(p_loc=>'after resolve_pricing_objective');
    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
        l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
      raise fte_freight_pricing_util.g_post_process_failed;
    END IF;

   fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
 EXCEPTION
      WHEN fte_freight_pricing_util.g_post_process_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_post_process_failed');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN fte_freight_pricing_util.g_get_qp_output_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_get_qp_output_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_total_base_price_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'total_base_price_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_apply_new_base_price_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_apply_new_base_price_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_delete_set_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_delete_set_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_resolve_pricing_objective THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_resolve_pricing_objective');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_apply_min_charge THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_apply_min_charge');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_total_shipment_weight_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_total_shipment_weight_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_qp_price_request_failed_2 THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_qp_price_request_failed_2');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_prepare_next_event_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_prepare_next_event_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_get_bumped_up_wt_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_get_bumped_up_wt_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_parcel_not_eligible THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_parcel_not_eligible');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_create_control_record_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_control_record_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_create_line_record_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_line_record_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_create_qualifiers_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_qualifiers_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_create_attr_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_attr_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');
      WHEN fte_freight_pricing_util.g_process_others_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_process_others_failed');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'process_Parcel');


END process_parcel;


-- This is called if neither parcel nor LTL
-- create engine lines
-- call qp engine
-- check for min. charge logic
-- make second qp call
PROCEDURE process_others (
        p_pricing_control_rec     IN                fte_freight_pricing.pricing_control_input_rec_type,
        p_top_level_rows          IN                fte_freight_pricing.shpmnt_content_tab_type,
        p_pricing_engine_rows     IN OUT NOCOPY     fte_freight_pricing.pricing_engine_input_tab_type,
        p_pricing_dual_instances  IN                fte_freight_pricing.pricing_dual_instance_tab_type,
        p_pattern_rows            IN                fte_freight_pricing.top_level_pattern_tab_type,
        p_pricing_attribute_rows  IN OUT NOCOPY     fte_freight_pricing.pricing_attribute_tab_type,
        --p_pricing_qualifier       IN                fte_qual_rec_type,
        x_qp_output_line_rows     OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        x_qp_output_detail_rows   OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_return_status           OUT NOCOPY                VARCHAR2 )
 IS

   l_return_status         VARCHAR2(1);
   l_event_num             NUMBER;
   l_set_num               NUMBER;
   i                       NUMBER;
   j                       NUMBER;
   l_attr_rec              fte_freight_pricing.pricing_attribute_rec_type;
   l_engine_input_rec      fte_freight_pricing.pricing_engine_input_rec_type;
   l_attr_row              fte_freight_pricing.pricing_attribute_rec_type;
   l_charge_applied        VARCHAR2(1);

 l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'process_others';
 BEGIN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   fte_freight_pricing_util.reset_dbg_vars;
   fte_freight_pricing_util.set_method(l_log_level,'process_others');

       -- create standard engine line and attributes (default stuff created by pattern matching)
       l_event_num := fte_qp_engine.G_LINE_EVENT_NUM;
       fte_qp_engine.create_control_record(p_event_num => l_event_num,
                                           x_return_status => l_return_status );

           fte_freight_pricing_util.set_location(p_loc=>'after create_control_record ');
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_control_record_failed;
           END IF;

       l_set_num   := 1;
       i := p_pricing_engine_rows.FIRST;
       IF (i IS NOT NULL) THEN
       LOOP
            fte_qp_engine.create_line_record (p_pricing_control_rec       => p_pricing_control_rec,
                                              p_pricing_engine_input_rec  => p_pricing_engine_rows(i),
                                              x_return_status             => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create_line_record. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_line_record_failed;
           END IF;

            fte_qp_engine.prepare_qp_line_qualifiers(
                                              p_event_num               => l_event_num,
                                              p_pricing_control_rec       => p_pricing_control_rec,
                                              p_input_index             => p_pricing_engine_rows(i).input_index,
                                              x_return_status           => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create qp line qualifiers. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        raise fte_freight_pricing_util.g_create_qualifiers_failed;
           END IF;

            fte_qp_engine.prepare_qp_line_attributes (
                                              p_event_num               => l_event_num,
                                              p_input_index             => p_pricing_engine_rows(i).input_index,
                                              p_attr_rows               => p_pricing_attribute_rows,
                                              x_return_status           => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create qp line attributes. i='||i);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_create_attr_failed;
            END IF;

       EXIT WHEN i >= p_pricing_engine_rows.LAST;
       i := p_pricing_engine_rows.NEXT(i);
       END LOOP;
       END IF;


       -- fte_qp_engine.print_qp_input_lines(1);

       -- call qp api
       fte_qp_engine.call_qp_api    ( x_qp_output_line_rows    => x_qp_output_line_rows,
                                      x_qp_output_detail_rows  => x_qp_output_detail_rows,
                                      x_return_status          => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after call_qp_api: Event 1');
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise fte_freight_pricing_util.g_qp_price_request_failed_2;
                 END IF;
           END IF;

       --check for errors in the output
           fte_qp_engine.check_qp_output_errors (x_return_status   => l_return_status);
           fte_freight_pricing_util.set_location(p_loc=>'after check_qp_output_errors: Event '||l_event_num);
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise fte_freight_pricing_util.g_qp_price_request_failed_2;
                 END IF;
           END IF;

       fte_qp_engine.print_qp_output();

    post_process(
      p_event_num		=> l_event_num,
      p_set_num			=> l_set_num,
      p_pricing_engine_rows	=> p_pricing_engine_rows,
      p_pricing_dual_instances	=> p_pricing_dual_instances,
      x_qp_output_line_rows	=> x_qp_output_line_rows,
      x_qp_output_detail_rows	=> x_qp_output_detail_rows,
      x_return_status		=> l_return_status);

    fte_freight_pricing_util.set_location(p_loc=>'after resolve_pricing_objective');
    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
        l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
      raise fte_freight_pricing_util.g_post_process_failed;
    END IF;

   fte_freight_pricing_util.unset_method(l_log_level,'process_others');
 EXCEPTION
      WHEN fte_freight_pricing_util.g_post_process_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_post_process_failed');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN fte_freight_pricing_util.g_create_control_record_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_control_record_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_others');
      WHEN fte_freight_pricing_util.g_create_line_record_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_line_record_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_others');
      WHEN fte_freight_pricing_util.g_create_qualifiers_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_qualifiers_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_others');
      WHEN fte_freight_pricing_util.g_create_attr_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_attr_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_others');
      WHEN fte_freight_pricing_util.g_resolve_pricing_objective THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_resolve_pricing_objective');
           fte_freight_pricing_util.unset_method(l_log_level,'process_others');
      WHEN fte_freight_pricing_util.g_apply_min_charge THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_apply_min_charge');
           fte_freight_pricing_util.unset_method(l_log_level,'process_others');
      WHEN fte_freight_pricing_util.g_total_shipment_weight_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_total_shipment_weight_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_others');
      WHEN fte_freight_pricing_util.g_qp_price_request_failed_2 THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_qp_price_request_failed_2');
           fte_freight_pricing_util.unset_method(l_log_level,'process_others');
      WHEN fte_freight_pricing_util.g_prepare_next_event_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_prepare_next_event_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'process_others');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'process_others');

 END process_others;



-- Is called by the main code after searching for patterns and creating standard engine rows and attributes
-- Checks process flags.
-- Depending upon the mix of conditions it calls other internal procedures to process the input lines.
-- If no special conditions apply, standard code is executed (process_others). It still needs to check for min. charges
-- if enabled.

PROCEDURE process_special_conditions(
        p_pricing_control_rec     IN                fte_freight_pricing.pricing_control_input_rec_type,
        p_top_level_rows          IN                fte_freight_pricing.shpmnt_content_tab_type,
        p_pattern_rows            IN                fte_freight_pricing.top_level_pattern_tab_type,
        p_pricing_dual_instances  IN                fte_freight_pricing.pricing_dual_instance_tab_type,
        x_pricing_engine_rows     IN OUT NOCOPY     fte_freight_pricing.pricing_engine_input_tab_type,
        x_pricing_attribute_rows  IN OUT NOCOPY     fte_freight_pricing.pricing_attribute_tab_type,
        x_qp_output_line_rows     OUT NOCOPY     QP_PREQ_GRP.LINE_TBL_TYPE,
        x_qp_output_detail_rows   OUT NOCOPY     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_return_status           OUT NOCOPY                VARCHAR2 )
IS

l_return_status                      VARCHAR2(1);

l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
l_method_name VARCHAR2(50) := 'process_special_conditions';
 BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   fte_freight_pricing_util.reset_dbg_vars;
   fte_freight_pricing_util.set_method(l_log_level,l_method_name);
     -- check if lane function is LTL or PARCEL.

   fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'p_pricing_control_rec.currency_code = '||p_pricing_control_rec.currency_code);

   IF (p_pricing_control_rec.currency_code IS NULL) THEN
       raise fte_freight_pricing_util.g_no_currency_found;
   END IF;

   IF (p_pricing_control_rec.lane_id IS NULL) THEN
       raise fte_freight_pricing_util.g_no_lane_found;
   END IF;

   --IF (p_pricing_control_rec.lane_id IS NULL) THEN
   IF (p_pricing_control_rec.price_list_id IS NULL) THEN
       raise fte_freight_pricing_util.g_no_price_list_on_lane;
   END IF;

   IF (p_pricing_control_rec.party_id IS NULL) THEN
       raise fte_freight_pricing_util.g_no_party_id_found;
   END IF;



     IF ( isLTL = 'Y') THEN
        process_LTL(p_pricing_control_rec     => p_pricing_control_rec,
                   p_top_level_rows           => p_top_level_rows,
                   p_pricing_engine_rows     => x_pricing_engine_rows,
                   p_pricing_dual_instances  => p_pricing_dual_instances,
                   p_pattern_rows            => p_pattern_rows,
                   p_pricing_attribute_rows  => x_pricing_attribute_rows,
                   x_qp_output_line_rows     => x_qp_output_line_rows,
                   x_qp_output_detail_rows   => x_qp_output_detail_rows,
                   x_return_status           => l_return_status );

            fte_freight_pricing_util.set_location(p_loc=>'after process_LTL ');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_process_LTL_failed;
            END IF;

     ELSIF ( isParcel = 'Y') THEN
         process_Parcel(p_pricing_control_rec     => p_pricing_control_rec,
                   p_pricing_engine_rows     => x_pricing_engine_rows,
                   p_top_level_rows           => p_top_level_rows,
                   p_pricing_dual_instances  => p_pricing_dual_instances,
                   p_pattern_rows            => p_pattern_rows,
                   p_pricing_attribute_rows  => x_pricing_attribute_rows,
                   x_qp_output_line_rows     => x_qp_output_line_rows,
                   x_qp_output_detail_rows   => x_qp_output_detail_rows,
                   x_return_status           => l_return_status );

            fte_freight_pricing_util.set_location(p_loc=>'after process_Parcel ');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_process_Parcel_failed;
            END IF;
     ELSE
        --
        -- 03/08/02 : None : need to call standard qp call + chekc for min. charge + new call if applicable
                 process_others(p_pricing_control_rec     => p_pricing_control_rec,
                                p_pricing_engine_rows     => x_pricing_engine_rows,
                                p_top_level_rows          => p_top_level_rows,
                                p_pricing_dual_instances  => p_pricing_dual_instances,
                                p_pattern_rows            => p_pattern_rows,
                                p_pricing_attribute_rows  => x_pricing_attribute_rows,
                                x_qp_output_line_rows     => x_qp_output_line_rows,
                                x_qp_output_detail_rows   => x_qp_output_detail_rows,
                                x_return_status           => l_return_status );

            fte_freight_pricing_util.set_location(p_loc=>'after process_others ');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                         raise fte_freight_pricing_util.g_process_others_failed;
            END IF;

     END IF;

 fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
 EXCEPTION
      WHEN fte_freight_pricing_util.g_no_party_id_found THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_no_party_id_found');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN fte_freight_pricing_util.g_no_price_list_on_lane THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_no_price_list_on_lane');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN fte_freight_pricing_util.g_no_lane_found THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_no_lane_found');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN fte_freight_pricing_util.g_no_currency_found THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_no_currency_found');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN fte_freight_pricing_util.g_process_LTL_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_process_LTL_failed');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN fte_freight_pricing_util.g_process_Parcel_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_process_Parcel_failed');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN fte_freight_pricing_util.g_process_others_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_create_attr_failed');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

END process_special_conditions;

-- J+ enhancement for container_all rate basis
-- this procedure is called by shipment_pricing to rate container_all basis
PROCEDURE rate_container_all(
        p_lane_info		     	IN fte_freight_pricing.lane_info_rec_type,
        p_top_level_rows          	IN fte_freight_pricing.shpmnt_content_tab_type,
        p_save_flag               	IN VARCHAR2,
        p_currency_code			IN VARCHAR2 ,
        x_freight_cost_main_price  	OUT NOCOPY fte_freight_pricing.Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_price  	OUT NOCOPY fte_freight_pricing.Freight_Cost_Temp_Tab_Type,
        x_freight_cost_main_charge 	OUT NOCOPY fte_freight_pricing.Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_charge 	OUT NOCOPY fte_freight_pricing.Freight_Cost_Temp_Tab_Type,
        x_fc_main_update_rows     	OUT NOCOPY fte_freight_pricing.Freight_Cost_Main_Tab_Type,
        x_summary_lanesched_price      	OUT NOCOPY NUMBER,
        x_summary_lanesched_price_uom  	OUT NOCOPY VARCHAR2,
        x_return_status           	OUT NOCOPY VARCHAR2 )
IS
  l_log_level NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'rate_container_all';
  l_return_status VARCHAR2(1);

  l_pricing_control_rec fte_freight_pricing.pricing_control_input_rec_type;
  l_pricing_engine_rows fte_freight_pricing.pricing_engine_input_tab_type;
  l_engine_row_count NUMBER;
  l_pricing_attribute_rows fte_freight_pricing.pricing_attribute_tab_type;

  l_qp_output_line_rows QP_PREQ_GRP.LINE_TBL_TYPE;
  l_qp_output_detail_rows QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;

  l_uom_ea VARCHAR2(30);
  i NUMBER;
  j NUMBER;
  l_event_num NUMBER;
  l_currency_code VARCHAR2(30);
  l_lane_function VARCHAR2(30);
  l_charge_applied VARCHAR2(1);

  l_fc_rec                      fte_freight_pricing.top_level_fc_rec_type;
  l_fc_charge_rec               fte_freight_pricing.top_level_fc_rec_type;
  n NUMBER;
  l_line_price_amount NUMBER;
  l_line_charge_amount NUMBER;
  l_line_discount_amount NUMBER;
  l_summary_amount NUMBER;
  l_price_count            NUMBER;
  l_charge_count           NUMBER;

  l_leg_id NUMBER;
  l_delivery_id NUMBER;

  l_leg_id_array dbms_utility.number_array;
  l_delivery_id_array  dbms_utility.number_array;
  l_delivery_summary dbms_utility.number_array;

  l_freight_cost_type_id NUMBER;

BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_method_name);

  -- group top level containers into pricing engine input lines by container_type
  -- set up the pricing attributes for each input line
  -- call QP
  -- check min charge parameter
  -- if need to apply minimum charge
  --    prepare second call to qp
  -- process qp output
  --   distribute qp output back to top level containers

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_top_level_rows.COUNT='||p_top_level_rows.COUNT);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_save_flag='||p_save_flag);

  OPEN get_uom_for_each;
  FETCH get_uom_for_each INTO l_uom_ea;
  CLOSE get_uom_for_each;

  IF l_uom_ea is null THEN
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'uom for each is null');
    raise FND_API.G_EXC_ERROR;
  END IF;

  -- Modified for 12i for Multi currency support.
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_currency_code '|| p_currency_code);

  IF p_currency_code IS NOT NULL THEN
        l_currency_code := p_currency_code;
  ELSE
     fte_freight_pricing.get_currency_code(
       p_carrier_id      =>   p_lane_info.carrier_id,
       x_currency_code   =>   l_currency_code,
       x_return_status   =>   l_return_status );
  END IF;

  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS and
        l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'get currency code failed');
      raise FND_API.G_EXC_ERROR;
  END IF;

  -- group top level rows by container type into pricing engine rows
  l_engine_row_count := 0;

  i := p_top_level_rows.FIRST;
  IF (i is not null) THEN
  LOOP
    IF ((p_top_level_rows(i).container_flag IS NULL) OR (p_top_level_rows(i).container_flag = 'N')) THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'top level loose item cannot be rated in rate basis CONTAINER_ALL');
      raise FND_API.G_EXC_ERROR;
    END IF;
    IF p_top_level_rows(i).container_type_code is null THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'top level container type code is null, cannot be rated in rate basis CONTAINER_ALL');
      raise FND_API.G_EXC_ERROR;
    END IF;

    IF l_engine_row_count = 0 THEN
      l_engine_row_count := 1;
      l_pricing_engine_rows(l_engine_row_count).input_index := 1;
      l_pricing_engine_rows(l_engine_row_count).line_quantity  := 1;
      l_pricing_engine_rows(l_engine_row_count).line_uom := l_uom_ea;
      l_pricing_engine_rows(l_engine_row_count).container_type_code := p_top_level_rows(i).container_type_code;
    ELSE

      j := 1;
      LOOP
	IF p_top_level_rows(i).container_type_code = l_pricing_engine_rows(j).container_type_code THEN
      	  l_pricing_engine_rows(j).line_quantity  := l_pricing_engine_rows(j).line_quantity + 1;
	  EXIT;
	END IF;

	j := j + 1;

	IF j > l_engine_row_count THEN
      	  l_engine_row_count := j;
      	  l_pricing_engine_rows(j).input_index := j;
      	  l_pricing_engine_rows(j).line_quantity  := 1;
      	  l_pricing_engine_rows(j).line_uom := l_uom_ea;
      	  l_pricing_engine_rows(j).container_type_code := p_top_level_rows(i).container_type_code;
	  EXIT;
	END IF;

      END LOOP; -- l_pricing_engine_rows(j)

    END IF; -- l_engine_row_count > 0

  EXIT WHEN (i >= p_top_level_rows.LAST);
  i := p_top_level_rows.NEXT(i);
  END LOOP;
  END IF;

  fte_freight_pricing.print_engine_rows (
        p_engine_rows             =>    l_pricing_engine_rows,
        x_return_status           =>    l_return_status );

  initialize(
    p_lane_id         => p_lane_info.lane_id,
    x_lane_function   => l_lane_function,
    x_return_status   => l_return_status);

  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
     l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

  -- set up data structure to call QP
  -- call QP
  -- check qp output for any errors

  l_pricing_control_rec.pricing_event_num := fte_qp_engine.G_LINE_EVENT_NUM;
  l_pricing_control_rec.currency_code     := l_currency_code;
  l_pricing_control_rec.lane_id           := p_lane_info.lane_id;
  l_pricing_control_rec.price_list_id     := p_lane_info.pricelist_id;
  l_pricing_control_rec.party_id          := p_lane_info.carrier_id;

  i := l_pricing_engine_rows.FIRST;
  j := l_pricing_attribute_rows.COUNT;
  LOOP

      j := j + 1;
         l_pricing_attribute_rows(j).attribute_index := j;
         l_pricing_attribute_rows(j).input_index     := i;
         l_pricing_attribute_rows(j).attribute_name  := 'ORIGIN_ZONE';
         l_pricing_attribute_rows(j).attribute_value := TO_CHAR(p_lane_info.origin_id);
      j := j + 1;
         l_pricing_attribute_rows(j).attribute_index := j;
         l_pricing_attribute_rows(j).input_index     := i;
         l_pricing_attribute_rows(j).attribute_name  := 'DESTINATION_ZONE';
         l_pricing_attribute_rows(j).attribute_value := TO_CHAR(p_lane_info.destination_id);
      j := j + 1;
         l_pricing_attribute_rows(j).attribute_index := j;
         l_pricing_attribute_rows(j).input_index     := i;
         l_pricing_attribute_rows(j).attribute_name  := 'CONTAINER_TYPE';
         l_pricing_attribute_rows(j).attribute_value := l_pricing_engine_rows(i).container_type_code;

      IF p_lane_info.service_type_code IS NOT NULL THEN

      j := j + 1;
         l_pricing_attribute_rows(j).attribute_index := j;
         l_pricing_attribute_rows(j).input_index     := i;
         l_pricing_attribute_rows(j).attribute_name  := 'SERVICE_TYPE';  --  Is it required always
         l_pricing_attribute_rows(j).attribute_value := p_lane_info.service_type_code;

      END IF;


      EXIT WHEN i = l_pricing_engine_rows.LAST;
      i := l_pricing_engine_rows.NEXT(i);

  END LOOP;

       -- create standard engine line and attributes (default stuff created by pattern matching)
       l_event_num := fte_qp_engine.G_LINE_EVENT_NUM;
       fte_qp_engine.create_control_record(p_event_num => l_event_num,
                                           x_return_status => l_return_status );

           fte_freight_pricing_util.set_location(p_loc=>'after create_control_record ');
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
      		raise FND_API.G_EXC_ERROR;
           END IF;

       --l_set_num   := 1;
       i := l_pricing_engine_rows.FIRST;
       IF (i IS NOT NULL) THEN
       LOOP
            fte_qp_engine.create_line_record (p_pricing_control_rec       => l_pricing_control_rec,
                                              p_pricing_engine_input_rec  => l_pricing_engine_rows(i),
                                              x_return_status             => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create_line_record. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
      		raise FND_API.G_EXC_ERROR;
           END IF;

            fte_qp_engine.prepare_qp_line_qualifiers(
                                              p_event_num               => l_event_num,
                                              p_pricing_control_rec       => l_pricing_control_rec,
                                              p_input_index             => l_pricing_engine_rows(i).input_index,
                                              x_return_status           => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after create qp line qualifiers. i='||i);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
      		raise FND_API.G_EXC_ERROR;
           END IF;

            fte_qp_engine.prepare_qp_line_attributes (
                                              p_event_num               => l_event_num,
                                              p_input_index             => l_pricing_engine_rows(i).input_index,
                                              p_attr_rows               => l_pricing_attribute_rows,
                                              x_return_status           => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after create qp line attributes. i='||i);
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
      		raise FND_API.G_EXC_ERROR;
            END IF;

       EXIT WHEN i >= l_pricing_engine_rows.LAST;
       i := l_pricing_engine_rows.NEXT(i);
       END LOOP;
       END IF;

       -- call qp api
       fte_qp_engine.call_qp_api    ( x_qp_output_line_rows    => l_qp_output_line_rows,
                                      x_qp_output_detail_rows  => l_qp_output_detail_rows,
                                      x_return_status          => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after call_qp_api: Event 1');
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
              l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      		raise FND_API.G_EXC_ERROR;
           END IF;

       --check for errors in the output
           fte_qp_engine.check_qp_output_errors (x_return_status   => l_return_status);
           fte_freight_pricing_util.set_location(p_loc=>'after check_qp_output_errors: Event '||l_event_num);
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
              l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      		raise FND_API.G_EXC_ERROR;
           END IF;

       fte_qp_engine.print_qp_output();

  IF (g_special_flags.minimum_charge_flag = 'Y') THEN

    apply_min_charge(
	p_event_num      => l_event_num,
        x_charge_applied => l_charge_applied,
        x_return_status  => l_return_status);

    fte_freight_pricing_util.set_location(p_loc=>'after apply_min_charge ');
    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
        l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
      raise FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- create request lines for the next event and call qp engine
  IF (l_charge_applied = 'Y') THEN
       l_event_num := fte_qp_engine.G_CHARGE_EVENT_NUM;
       fte_qp_engine.prepare_next_event_request ( x_return_status           => l_return_status);

            fte_freight_pricing_util.set_location(p_loc=>'after prepare_next_event_request');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
                  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
      		raise FND_API.G_EXC_ERROR;
            END IF;

       fte_qp_engine.call_qp_api    ( x_qp_output_line_rows    => l_qp_output_line_rows,
                                      x_qp_output_detail_rows  => l_qp_output_detail_rows,
                                      x_return_status          => l_return_status);

           fte_freight_pricing_util.set_location(p_loc=>'after call_qp_api: Event 2');
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
               l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      		raise FND_API.G_EXC_ERROR;
           END IF;

       --check for errors in the output
           fte_qp_engine.check_qp_output_errors (x_return_status   => l_return_status);
           fte_freight_pricing_util.set_location(p_loc=>'after check_qp_output_errors: Event '||l_event_num);
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
              l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      		raise FND_API.G_EXC_ERROR;
           END IF;

       fte_qp_engine.print_qp_output();

  END IF; -- l_charge_applied = 'Y'

  -- process qp output

  l_price_count := 0;
  l_charge_count := 0;
  l_summary_amount := 0;

  i := l_qp_output_line_rows.FIRST;
  IF (i is not null) THEN
  LOOP

    l_fc_rec.quantity := l_pricing_engine_rows(l_qp_output_line_rows(i).line_index).line_quantity;
    l_fc_rec.uom := l_pricing_engine_rows(l_qp_output_line_rows(i).line_index).line_uom;
    l_fc_rec.currency_code := l_currency_code;

    l_line_charge_amount := 0;
    l_line_discount_amount := 0;

    j := l_qp_output_detail_rows.FIRST;
    IF (j is not null) THEN
    LOOP

      IF (l_qp_output_detail_rows(j).list_line_type_code = 'SUR' OR
     	 l_qp_output_detail_rows(j).list_line_type_code = 'DIS' )
	AND (l_qp_output_line_rows(i).line_index =
	     l_qp_output_detail_rows(j).line_index ) THEN

	l_fc_charge_rec.total_amount :=
	  ABS( l_qp_output_detail_rows(j).adjustment_amount )
	  * l_qp_output_line_rows(i).priced_quantity;
	l_fc_charge_rec.charge_unit_value:= l_fc_charge_rec.total_amount / l_fc_rec.quantity;

	IF l_qp_output_detail_rows(j).list_line_type_code = 'SUR' THEN
	  l_line_charge_amount := l_line_charge_amount + l_fc_charge_rec.total_amount;
	  l_fc_charge_rec.unit_amount := l_fc_charge_rec.total_amount;

	  l_fc_charge_rec.line_type_code := 'CHARGE';

          fte_freight_pricing.get_fc_type_id(
                      p_line_type_code => 'FTECHARGE',
                      p_charge_subtype_code  => l_qp_output_detail_rows(j).charge_subtype_code,
                      x_freight_cost_type_id  => l_fc_charge_rec.freight_cost_type_id,
                      x_return_status  =>  l_return_status);
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
               l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      		raise FND_API.G_EXC_ERROR;
          END IF;
	ELSE -- l_qp_output_detail_rows(j).list_line_type_code = 'DIS'
	  l_line_discount_amount := l_line_discount_amount + l_fc_charge_rec.total_amount;

	  l_fc_charge_rec.line_type_code := 'DISCOUNT';

          fte_freight_pricing.get_fc_type_id(
                      p_line_type_code => 'FTEDISCOUNT',
                      p_charge_subtype_code  => 'DISCOUNT',
                      x_freight_cost_type_id  => l_fc_charge_rec.freight_cost_type_id,
                      x_return_status  =>  l_return_status);
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
               l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      		raise FND_API.G_EXC_ERROR;
          END IF;
	END IF;

    	--distribute SUR/DIS into top level containers
	n := p_top_level_rows.FIRST;
    	IF (n is not null) THEN
    	LOOP

	 IF p_top_level_rows(n).container_type_code =
	  l_pricing_engine_rows(l_qp_output_line_rows(i).line_index).container_type_code THEN

	  l_charge_count := l_charge_count + 1;
	  IF p_save_flag = 'M' THEN
	    x_freight_cost_main_charge(l_charge_count).delivery_detail_id := p_top_level_rows(n).content_id;
	    x_freight_cost_main_charge(l_charge_count).delivery_leg_id := p_top_level_rows(n).delivery_leg_id;
	    x_freight_cost_main_charge(l_charge_count).delivery_id :=
		fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).delivery_id;
	    x_freight_cost_main_charge(l_charge_count).uom := l_fc_rec.uom;
	    x_freight_cost_main_charge(l_charge_count).quantity := 1;
	    x_freight_cost_main_charge(l_charge_count).line_type_code := l_fc_charge_rec.line_type_code;
	    x_freight_cost_main_charge(l_charge_count).freight_cost_type_id := l_fc_charge_rec.freight_cost_type_id;
	    x_freight_cost_main_charge(l_charge_count).charge_unit_value :=
		l_fc_charge_rec.charge_unit_value;
	    IF l_fc_charge_rec.unit_amount > 0 THEN
	      x_freight_cost_main_charge(l_charge_count).unit_amount :=
		round(l_fc_charge_rec.unit_amount / l_fc_rec.quantity, 2);
	    END IF;
	    x_freight_cost_main_charge(l_charge_count).total_amount :=
		round(l_fc_charge_rec.total_amount / l_fc_rec.quantity, 2);
	    x_freight_cost_main_charge(l_charge_count).currency_code := l_currency_code;
	    x_freight_cost_main_charge(l_charge_count).charge_source_code := 'PRICING_ENGINE';
	    x_freight_cost_main_charge(l_charge_count).estimated_flag := 'Y';
	  ELSE
	    x_freight_cost_temp_charge(l_charge_count).delivery_detail_id := p_top_level_rows(n).content_id;
	    x_freight_cost_temp_charge(l_charge_count).delivery_id :=
		fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).delivery_id;
	    x_freight_cost_temp_charge(l_charge_count).uom := l_fc_rec.uom;
	    x_freight_cost_temp_charge(l_charge_count).quantity := 1;
	    x_freight_cost_temp_charge(l_charge_count).line_type_code := l_fc_charge_rec.line_type_code;
	    x_freight_cost_temp_charge(l_charge_count).freight_cost_type_id := l_fc_charge_rec.freight_cost_type_id;
	    x_freight_cost_temp_charge(l_charge_count).charge_unit_value :=
		l_fc_charge_rec.charge_unit_value;
	    IF l_fc_charge_rec.unit_amount > 0 THEN
	      x_freight_cost_temp_charge(l_charge_count).unit_amount :=
		round(l_fc_charge_rec.unit_amount / l_fc_rec.quantity, 2);
	    END IF;
	    x_freight_cost_temp_charge(l_charge_count).total_amount :=
		round(l_fc_charge_rec.total_amount / l_fc_rec.quantity, 2);
	    x_freight_cost_temp_charge(l_charge_count).currency_code := l_currency_code;
	    x_freight_cost_temp_charge(l_charge_count).charge_source_code := 'PRICING_ENGINE';
	    x_freight_cost_temp_charge(l_charge_count).estimated_flag := 'Y';
	  END IF;

	 END IF; -- container_type compare

    	EXIT WHEN (n >= p_top_level_rows.LAST);
    	n := p_top_level_rows.NEXT(n);
    	END LOOP;
    	END IF;

      END IF; -- l_qp_output_detail_rows(j).list_line_type_code = 'SUR' or 'DIS'

    EXIT WHEN (j >= l_qp_output_detail_rows.LAST);
    j := l_qp_output_detail_rows.NEXT(j);
    END LOOP;
    END IF;

    l_line_price_amount := l_qp_output_line_rows(i).unit_price *
	l_qp_output_line_rows(i).priced_quantity;
    l_fc_rec.charge_unit_value := l_line_price_amount / l_fc_rec.quantity;
    l_fc_rec.unit_amount := l_line_price_amount - l_line_discount_amount;
    l_fc_rec.total_amount := l_fc_rec.unit_amount + l_line_charge_amount;
    l_fc_rec.line_type_code := 'PRICE';

    fte_freight_pricing.get_fc_type_id(
                      p_line_type_code => 'FTEPRICE',
                      p_charge_subtype_code  => 'PRICE',
                      x_freight_cost_type_id  => l_fc_rec.freight_cost_type_id,
                      x_return_status  =>  l_return_status);
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
               l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      		raise FND_API.G_EXC_ERROR;
    END IF;

    l_summary_amount := l_summary_amount + l_fc_rec.total_amount;

    --distribute PRICE into top level containers
    n := p_top_level_rows.FIRST;
    IF (n is not null) THEN
    LOOP

	 IF p_top_level_rows(n).container_type_code =
	  l_pricing_engine_rows(l_qp_output_line_rows(i).line_index).container_type_code THEN

	  l_price_count := l_price_count + 1;

	  --4294663
	  l_delivery_id :=
	      fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).delivery_id;

	  IF (NOT(l_delivery_id_array.EXISTS(l_delivery_id)))
	  THEN
	  	l_delivery_id_array(l_delivery_id):=l_delivery_id;
	  	l_leg_id_array(l_delivery_id):=p_top_level_rows(n).delivery_leg_id;
	  END IF;

	  IF (l_delivery_summary.EXISTS(l_delivery_id))
	  THEN
	 	l_delivery_summary(l_delivery_id):=l_delivery_summary(l_delivery_id)+round(l_fc_rec.total_amount / l_fc_rec.quantity, 2);
	  ELSE
		l_delivery_summary(l_delivery_id):=round(l_fc_rec.total_amount / l_fc_rec.quantity, 2);
	  END IF;




	  IF p_save_flag = 'M' THEN
	    x_freight_cost_main_price(l_price_count).delivery_detail_id := p_top_level_rows(n).content_id;
	    x_freight_cost_main_price(l_price_count).delivery_leg_id := p_top_level_rows(n).delivery_leg_id;
	    x_freight_cost_main_price(l_price_count).delivery_id :=
	      	fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).delivery_id;
	    x_freight_cost_main_price(l_price_count).uom := l_fc_rec.uom;
	    x_freight_cost_main_price(l_price_count).quantity := 1;
	    x_freight_cost_main_price(l_price_count).line_type_code := l_fc_rec.line_type_code;
	    x_freight_cost_main_price(l_price_count).freight_cost_type_id := l_fc_rec.freight_cost_type_id;
	    x_freight_cost_main_price(l_price_count).charge_unit_value :=
		l_fc_rec.charge_unit_value;
	    x_freight_cost_main_price(l_price_count).unit_amount :=
		round(l_fc_rec.unit_amount / l_fc_rec.quantity, 2);
	    x_freight_cost_main_price(l_price_count).total_amount :=
		round(l_fc_rec.total_amount / l_fc_rec.quantity, 2);
	    x_freight_cost_main_price(l_price_count).currency_code := l_currency_code;
	    x_freight_cost_main_price(l_price_count).charge_source_code := 'PRICING_ENGINE';
	    x_freight_cost_main_price(l_price_count).estimated_flag := 'Y';
	  ELSE
	    x_freight_cost_temp_price(l_price_count).delivery_detail_id := p_top_level_rows(n).content_id;
	    --x_freight_cost_temp_price(l_price_count).delivery_leg_id := p_top_level_rows(n).delivery_leg_id;
	    x_freight_cost_temp_price(l_price_count).delivery_id :=
	      	fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).delivery_id;
	    x_freight_cost_temp_price(l_price_count).uom := l_fc_rec.uom;
	    x_freight_cost_temp_price(l_price_count).quantity := 1;
	    x_freight_cost_temp_price(l_price_count).line_type_code := l_fc_rec.line_type_code;
	    x_freight_cost_temp_price(l_price_count).freight_cost_type_id := l_fc_rec.freight_cost_type_id;
	    x_freight_cost_temp_price(l_price_count).charge_unit_value :=
		l_fc_rec.charge_unit_value;
	    x_freight_cost_temp_price(l_price_count).unit_amount :=
		round(l_fc_rec.unit_amount / l_fc_rec.quantity, 2);
	    x_freight_cost_temp_price(l_price_count).total_amount :=
		round(l_fc_rec.total_amount / l_fc_rec.quantity, 2);
	    x_freight_cost_temp_price(l_price_count).currency_code := l_currency_code;
	    x_freight_cost_temp_price(l_price_count).charge_source_code := 'PRICING_ENGINE';
	    x_freight_cost_temp_price(l_price_count).estimated_flag := 'Y';
	  END IF;

	 END IF; -- container_type compare

    EXIT WHEN (n >= p_top_level_rows.LAST);
    n := p_top_level_rows.NEXT(n);
    END LOOP;
    END IF;

  EXIT WHEN (i >= l_qp_output_line_rows.LAST);
  i := l_qp_output_line_rows.NEXT(i);
  END LOOP;
  END IF;

  -- create the summary record

  fte_freight_pricing.get_fc_type_id(
           p_line_type_code => 'FTESUMMARY',
           p_charge_subtype_code  => 'SUMMARY',
           x_freight_cost_type_id  =>  l_freight_cost_type_id,
           x_return_status  =>  l_return_status);
  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
               l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      		raise FND_API.G_EXC_ERROR;
  END IF;

  IF p_save_flag = 'M' THEN

    --4294663
    i:=l_delivery_id_array.FIRST;
    j:=1;
    WHILE(i IS NOT NULL)
    LOOP

	    x_fc_main_update_rows(j).delivery_leg_id := l_leg_id_array(i);
	    x_fc_main_update_rows(j).delivery_id := l_delivery_id_array(i);
	    x_fc_main_update_rows(j).freight_cost_id := fte_freight_pricing.get_fc_id_from_dleg(l_leg_id_array(i));
	    x_fc_main_update_rows(j).line_type_code := 'SUMMARY';
	    x_fc_main_update_rows(j).freight_cost_type_id := l_freight_cost_type_id;
	    x_fc_main_update_rows(j).unit_amount := round(l_delivery_summary(l_delivery_id_array(i)),2);
	    x_fc_main_update_rows(j).total_amount := round(l_delivery_summary(l_delivery_id_array(i)),2);
	    x_fc_main_update_rows(j).currency_code := l_currency_code;
	    x_fc_main_update_rows(j).charge_source_code := 'PRICING_ENGINE';
	    x_fc_main_update_rows(j).estimated_flag := 'Y';




	j:=j+1;
	i:=l_delivery_id_array.NEXT(i);
    END LOOP;

  ELSE

    i:=l_delivery_id_array.FIRST;

    WHILE(i IS NOT NULL)
    LOOP
	    --4294663
	    l_price_count := l_price_count + 1;
	    x_freight_cost_temp_price(l_price_count).delivery_id := l_delivery_id_array(i);
	    x_freight_cost_temp_price(l_price_count).line_type_code := 'SUMMARY';
	    x_freight_cost_temp_price(l_price_count).freight_cost_type_id :=  l_freight_cost_type_id;
	    x_freight_cost_temp_price(l_price_count).unit_amount := round(l_delivery_summary(l_delivery_id_array(i)),2);
	    x_freight_cost_temp_price(l_price_count).total_amount := round(l_delivery_summary(l_delivery_id_array(i)),2);
	    x_freight_cost_temp_price(l_price_count).currency_code := l_currency_code;
	    x_freight_cost_temp_price(l_price_count).charge_source_code := 'PRICING_ENGINE';
	    x_freight_cost_temp_price(l_price_count).estimated_flag := 'Y';
	i:=l_delivery_id_array.NEXT(i);
    END LOOP;


  END IF;

  x_summary_lanesched_price := round(l_summary_amount,2);
  x_summary_lanesched_price_uom := l_currency_code;

  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'FND_API.G_EXC_ERROR');
        fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END;

-- J+ enhancement for LTL rating to include container weight
-- this procedure is called by distribute_LTL_container_wt to get the LTL container weight
-- container weight to be included in LTL rating is the top level container's tare weight
PROCEDURE get_LTL_container_weight(
        p_top_level_rows          	IN fte_freight_pricing.shpmnt_content_tab_type,
	x_total_container_weight	OUT NOCOPY NUMBER,
	x_weight_uom			OUT NOCOPY VARCHAR2,
        x_return_status           	OUT NOCOPY VARCHAR2 )
IS
  l_log_level NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'get_LTL_container_weight';
  l_return_status VARCHAR2(1);
  i NUMBER;
  l_tmp		NUMBER;
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_method_name);

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_top_level_rows.COUNT='||p_top_level_rows.COUNT);

  x_total_container_weight := 0;
  x_weight_uom := null;

  i := p_top_level_rows.FIRST;
  IF (i is not null) THEN
  LOOP
    IF (((p_top_level_rows(i).container_flag = 'Y') OR (p_top_level_rows(i).container_flag = 'C')) and (p_top_level_rows(i).wdd_tare_weight > 0)) THEN

      IF p_top_level_rows(i).wdd_weight_uom_code is null THEN
  	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'top level container tare weight > 0 and weight uom is null');
    	raise FND_API.G_EXC_ERROR;
      END IF;

      IF x_weight_uom is NULL THEN
	x_weight_uom := p_top_level_rows(i).wdd_weight_uom_code;
      END IF;

      IF x_weight_uom = p_top_level_rows(i).wdd_weight_uom_code THEN
	x_total_container_weight := x_total_container_weight + p_top_level_rows(i).wdd_tare_weight;
      ELSE
   	l_tmp := WSH_WV_UTILS.convert_uom(
					p_top_level_rows(i).wdd_weight_uom_code,
					x_weight_uom,
					p_top_level_rows(i).wdd_tare_weight,
					NULL,0);
	IF l_tmp <= 0 THEN
  	  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'WSH_WV_UTILS.convert_uom return 0');
    	  raise FND_API.G_EXC_ERROR;
	ELSE
	  x_total_container_weight := x_total_container_weight + l_tmp;
	END IF;
      END IF;

    END IF;

  EXIT WHEN (i >= p_top_level_rows.LAST);
  i := p_top_level_rows.NEXT(i);
  END LOOP;
  END IF;

  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'FND_API.G_EXC_ERROR');
        fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END;

-- J+ enhancement for LTL rating to include container weight
-- this procedure is called by process_shipment_patterns to distribute LTL container weight to
-- pricing_engine_rows and g_rolledup_lines
PROCEDURE distribute_LTL_container_wt(
        p_top_level_rows        IN fte_freight_pricing.shpmnt_content_tab_type,
        x_pricing_engine_rows	IN OUT NOCOPY fte_freight_pricing.pricing_engine_input_tab_type,
        x_return_status         OUT NOCOPY VARCHAR2 )
IS
  l_log_level NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'distribute_LTL_container_wt';
  l_return_status VARCHAR2(1);

  l_total_container_weight NUMBER;
  l_container_weight_uom VARCHAR2(3);

  l_segment2 NUMBER;
  l_lowest_fc_segment2 NUMBER;
  l_lowest_fc_category_id NUMBER;
  l_lowest_fc_input_index1 NUMBER;
  l_lowest_fc_input_index2 NUMBER;
  l_lowest_fc_old_line_quantity NUMBER;
  l_bumpup_ratio NUMBER;

  i NUMBER;

  CURSOR get_category_segment2(c_category_id NUMBER)
  IS
  SELECT TO_NUMBER(segment2)
  FROM mtl_categories
  WHERE category_id = c_category_id;

BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_method_name);

  -- get the LTL container weight
  -- calculate the bumpup ratio
  -- bumpup pricing engine rows
  -- bumpup g_rolledup_lines

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_top_level_rows.COUNT='||p_top_level_rows.COUNT);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_pricing_engine_rows.COUNT='||x_pricing_engine_rows.COUNT);

  get_LTL_container_weight(
    p_top_level_rows => p_top_level_rows,
    x_total_container_weight => l_total_container_weight,
    x_weight_uom => l_container_weight_uom,
    x_return_status => l_return_status);

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_total_container_weight='||l_total_container_weight);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_container_weight_uom='||l_container_weight_uom);

  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

  IF l_total_container_weight <= 0 THEN
    raise g_finished_success;
  END IF;

  -- after process shipment patterns for LTL, it could come up with two pricing engine lines
  -- for the same commodity. one from items inside container, one from loose items
  -- this code can handle all the scinerio
  -- commodity from only loose item
  -- commodity from only container items
  -- commodity from both loose item and container items
  l_lowest_fc_segment2 := -1;
  l_lowest_fc_category_id := -1;
  l_lowest_fc_input_index1 := -1;
  l_lowest_fc_input_index2 := -1;

  i := x_pricing_engine_rows.FIRST;
  IF (i is not null) THEN
  LOOP

    IF l_lowest_fc_category_id <> -1 and
	l_lowest_fc_category_id = x_pricing_engine_rows(i).category_id THEN
      	l_lowest_fc_input_index2 := i;
    ELSE
      l_segment2 := -1;
      OPEN get_category_segment2(x_pricing_engine_rows(i).category_id);
      FETCH get_category_segment2 INTO l_segment2;
      CLOSE get_category_segment2;

      IF l_segment2 is null or l_segment2 < 0 THEN
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'cannot get valid numeric segment2 from category id '
	||x_pricing_engine_rows(i).category_id);
        raise FND_API.G_EXC_ERROR;
      END IF;

      IF l_lowest_fc_segment2 = -1 THEN
        l_lowest_fc_segment2 := l_segment2;
        l_lowest_fc_category_id := x_pricing_engine_rows(i).category_id;
        l_lowest_fc_input_index1 := i;
      ELSE
        IF l_lowest_fc_segment2 > l_segment2 THEN
      	  l_lowest_fc_segment2 := l_segment2;
      	  l_lowest_fc_category_id := x_pricing_engine_rows(i).category_id;
      	  l_lowest_fc_input_index1 := i;
      	  l_lowest_fc_input_index2 := -1;
        ELSIF l_lowest_fc_segment2 = l_segment2 THEN
      	  l_lowest_fc_input_index2 := i;
        END IF;
      END IF;
    END IF;

  EXIT WHEN (i >= x_pricing_engine_rows.LAST);
  i := x_pricing_engine_rows.NEXT(i);
  END LOOP;
  END IF;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_fc_segment2='||l_lowest_fc_segment2);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_fc_category_id='||l_lowest_fc_category_id);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_fc_input_index1='||l_lowest_fc_input_index1);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_fc_input_index2='||l_lowest_fc_input_index2);

  IF l_lowest_fc_input_index1 = -1 and l_lowest_fc_input_index2 = -1 THEN
    raise g_finished_success;
  END IF;

  IF l_container_weight_uom = x_pricing_engine_rows(l_lowest_fc_input_index1).line_uom THEN
      l_lowest_fc_old_line_quantity := x_pricing_engine_rows(l_lowest_fc_input_index1).line_quantity;
  ELSE
      l_lowest_fc_old_line_quantity := WSH_WV_UTILS.convert_uom(
					x_pricing_engine_rows(l_lowest_fc_input_index1).line_uom,
					l_container_weight_uom,
					x_pricing_engine_rows(l_lowest_fc_input_index1).line_quantity,
					NULL,0);
  END IF;

  IF l_lowest_fc_input_index2 <> -1 THEN
    IF l_container_weight_uom = x_pricing_engine_rows(l_lowest_fc_input_index2).line_uom THEN
      l_lowest_fc_old_line_quantity := l_lowest_fc_old_line_quantity
					+ x_pricing_engine_rows(l_lowest_fc_input_index2).line_quantity;
    ELSE
      l_lowest_fc_old_line_quantity := l_lowest_fc_old_line_quantity
					+ WSH_WV_UTILS.convert_uom(
					x_pricing_engine_rows(l_lowest_fc_input_index2).line_uom,
					l_container_weight_uom,
					x_pricing_engine_rows(l_lowest_fc_input_index2).line_quantity,
					NULL,0);
    END IF;
  END IF;
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_fc_old_line_quantity='||l_lowest_fc_old_line_quantity);

  l_bumpup_ratio := ( l_lowest_fc_old_line_quantity + l_total_container_weight )
		     / l_lowest_fc_old_line_quantity;
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_bumpup_ratio='||l_bumpup_ratio);

  -- bumpup pricing engine rows
  x_pricing_engine_rows(l_lowest_fc_input_index1).line_quantity :=
    x_pricing_engine_rows(l_lowest_fc_input_index1).line_quantity * l_bumpup_ratio;

  IF l_lowest_fc_input_index2 <> -1 THEN
    x_pricing_engine_rows(l_lowest_fc_input_index2).line_quantity :=
      x_pricing_engine_rows(l_lowest_fc_input_index2).line_quantity * l_bumpup_ratio;
  END IF;

  -- bumpup g_rolledup_lines
  i := FTE_FREIGHT_PRICING.g_rolledup_lines.FIRST;
  IF (i is not null) THEN
  LOOP
    IF FTE_FREIGHT_PRICING.g_rolledup_lines(i).category_id = l_lowest_fc_category_id THEN
      FTE_FREIGHT_PRICING.g_rolledup_lines(i).line_quantity :=
	FTE_FREIGHT_PRICING.g_rolledup_lines(i).line_quantity * l_bumpup_ratio;
    END IF;
  EXIT WHEN (i >= FTE_FREIGHT_PRICING.g_rolledup_lines.LAST);
  i := FTE_FREIGHT_PRICING.g_rolledup_lines.NEXT(i);
  END LOOP;
  END IF;

  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

EXCEPTION
   WHEN g_finished_success THEN
        fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'FND_API.G_EXC_ERROR');
        fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END;

PROCEDURE process_shipment_flatrate(
        p_lane_info		     	IN fte_freight_pricing.lane_info_rec_type,
        p_top_level_rows          	IN fte_freight_pricing.shpmnt_content_tab_type,
        p_save_flag               	IN VARCHAR2,
        p_currency_code             IN VARCHAR2,
        x_freight_cost_main_price  	OUT NOCOPY fte_freight_pricing.Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_price  	OUT NOCOPY fte_freight_pricing.Freight_Cost_Temp_Tab_Type,
        x_freight_cost_main_charge 	OUT NOCOPY fte_freight_pricing.Freight_Cost_Main_Tab_Type,
        x_freight_cost_temp_charge 	OUT NOCOPY fte_freight_pricing.Freight_Cost_Temp_Tab_Type,
        x_fc_main_update_rows     	OUT NOCOPY fte_freight_pricing.Freight_Cost_Main_Tab_Type,
        x_summary_lanesched_price      	OUT NOCOPY NUMBER,
        x_summary_lanesched_price_uom  	OUT NOCOPY VARCHAR2,
        x_return_status           	OUT NOCOPY VARCHAR2 )
IS
  l_log_level NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'process_shipment_flatrate';
  l_return_status VARCHAR2(1);

  l_pricing_control_rec fte_freight_pricing.pricing_control_input_rec_type;
  l_pricing_engine_rows fte_freight_pricing.pricing_engine_input_tab_type;
  l_engine_row_count NUMBER;
  l_pricing_attribute_rows fte_freight_pricing.pricing_attribute_tab_type;

  l_qp_output_line_rows QP_PREQ_GRP.LINE_TBL_TYPE;
  l_qp_output_detail_rows QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;

  l_uom_ea VARCHAR2(30);
  i NUMBER;
  j NUMBER;
  k NUMBER;
  l_event_num NUMBER;
  l_currency_code VARCHAR2(30);
  l_lane_function VARCHAR2(30);
  l_charge_applied VARCHAR2(1);

  l_fc_rec                      fte_freight_pricing.top_level_fc_rec_type;
  l_fc_charge_rec               fte_freight_pricing.top_level_fc_rec_type;
  n NUMBER;
  l_line_price_amount NUMBER;
  l_line_charge_amount NUMBER;
  l_line_discount_amount NUMBER;
  l_summary_amount NUMBER;
  l_price_count            NUMBER;
  l_charge_count           NUMBER;

  l_leg_id NUMBER;
  l_delivery_id NUMBER;--indexed by delivery id/parent delivery id
  l_freight_cost_type_id NUMBER;
  l_tmp		NUMBER;
  l_delivery_id_array  dbms_utility.number_array;
  l_temp_delivery_id NUMBER;
  l_temp_parent_delivery_id NUMBER;
  l_trip_summary_amount NUMBER;
  l_leg_id_array dbms_utility.number_array;



  l_delivery_summary dbms_utility.number_array;

  l_main_update_count NUMBER;

BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_method_name);

  -- sum up top level rows quantity and generate one pricing engine input line
  -- set up the pricing attributes for input line
  -- call QP
  -- check min charge parameter
  -- if need to apply minimum charge
  --    prepare second call to qp
  -- process qp output
  --   distribute qp output back to top level rows

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_top_level_rows.COUNT='||p_top_level_rows.COUNT);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_save_flag='||p_save_flag);

  FTE_FREIGHT_PRICING.print_top_level_detail (
        p_first_level_rows        =>    p_top_level_rows,
        x_return_status           =>    l_return_status );

    -- Added for 12i for multi currency support
    IF p_currency_code IS NOT NULL THEN
        l_currency_code := p_currency_code;
    ELSE
      fte_freight_pricing.get_currency_code(
      p_carrier_id      =>   p_lane_info.carrier_id,
      x_currency_code   =>   l_currency_code,
      x_return_status   =>   l_return_status );
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS and
          l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'get currency code failed');
          raise FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  --4294663

  l_price_count := 0;
  l_charge_count := 0;
  l_main_update_count:=0;
  l_trip_summary_amount:=0;

  k:= p_top_level_rows.FIRST;
  WHILE (k is not null)
  LOOP

  	l_temp_delivery_id:=fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(k).content_id).delivery_id;

	--MDC
	l_temp_parent_delivery_id:=fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(k).content_id).parent_delivery_id;
  	IF(l_temp_parent_delivery_id IS NOT NULL)
  	THEN
  		l_delivery_id_array(l_temp_parent_delivery_id):=l_temp_parent_delivery_id;

	ELSE
  		l_delivery_id_array(l_temp_delivery_id):=l_temp_delivery_id;
  	END IF;





  	k:= p_top_level_rows.NEXT(k);
  END LOOP;

  k:=l_delivery_id_array.FIRST;
  WHILE(k is not null)
  LOOP


	 FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,' Delivery:'||l_delivery_id_array(k));




	  -- sum up top level rows line quantity and generate one pricing engine input line
	  l_pricing_engine_rows.DELETE;
	  FTE_FREIGHT_PRICING.g_rolledup_lines.DELETE;

	  l_pricing_engine_rows(1).input_index := 1;
	  l_pricing_engine_rows(1).line_quantity  := 0;
	  l_pricing_engine_rows(1).line_uom := null;

	  i := p_top_level_rows.FIRST;
	  IF (i is not null) THEN
	  LOOP
	     IF((fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(i).content_id).parent_delivery_id = l_delivery_id_array(k)) OR (fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(i).content_id).delivery_id = l_delivery_id_array(k)))
	     THEN

		     IF p_top_level_rows(i).wdd_gross_weight is null
			OR p_top_level_rows(i).wdd_gross_weight <= 0
			OR p_top_level_rows(i).wdd_weight_uom_code is null THEN
		      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
			'top level detail id: '||p_top_level_rows(i).content_id
			||' wdd_gross_weight: '||p_top_level_rows(i).wdd_gross_weight
			||' '||p_top_level_rows(i).wdd_weight_uom_code);
		      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'top level detail gross weight invalid');
		      raise FND_API.G_EXC_ERROR;
		    END IF;

		    FTE_FREIGHT_PRICING.g_rolledup_lines(i).delivery_detail_id := p_top_level_rows(i).content_id;
		    FTE_FREIGHT_PRICING.g_rolledup_lines(i).line_quantity := p_top_level_rows(i).wdd_gross_weight;
		    FTE_FREIGHT_PRICING.g_rolledup_lines(i).line_uom := p_top_level_rows(i).wdd_weight_uom_code;

		    IF l_pricing_engine_rows(1).line_quantity = 0 THEN
		      l_pricing_engine_rows(1).line_quantity  := FTE_FREIGHT_PRICING.g_rolledup_lines(i).line_quantity;
		      l_pricing_engine_rows(1).line_uom := FTE_FREIGHT_PRICING.g_rolledup_lines(i).line_uom;
		    ELSE
		      IF l_pricing_engine_rows(1).line_uom = FTE_FREIGHT_PRICING.g_rolledup_lines(i).line_uom THEN
			l_pricing_engine_rows(1).line_quantity  := l_pricing_engine_rows(1).line_quantity
			  + FTE_FREIGHT_PRICING.g_rolledup_lines(i).line_quantity;
		      ELSE
			l_tmp := WSH_WV_UTILS.convert_uom(
							FTE_FREIGHT_PRICING.g_rolledup_lines(i).line_uom,
							l_pricing_engine_rows(1).line_uom,
							FTE_FREIGHT_PRICING.g_rolledup_lines(i).line_quantity,
							NULL,0);
			IF l_tmp <= 0 THEN
			  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'WSH_WV_UTILS.convert_uom return 0');
			  raise FND_API.G_EXC_ERROR;
			ELSE
			  FTE_FREIGHT_PRICING.g_rolledup_lines(i).line_quantity := l_tmp;
			  FTE_FREIGHT_PRICING.g_rolledup_lines(i).line_uom := l_pricing_engine_rows(1).line_uom;
			  l_pricing_engine_rows(1).line_quantity  :=
			    l_pricing_engine_rows(1).line_quantity + l_tmp;
			END IF;
		      END IF;
		    END IF; -- l_pricing_engine_rows(1).line_quantity > 0

	       END IF;

	  EXIT WHEN (i >= p_top_level_rows.LAST);
	  i := p_top_level_rows.NEXT(i);
	  END LOOP;
	  END IF;

	  fte_freight_pricing.print_rolledup_lines (
		p_rolledup_lines          =>   FTE_FREIGHT_PRICING.g_rolledup_lines,
		x_return_status           =>   l_return_status );

	  fte_freight_pricing.print_engine_rows (
		p_engine_rows             =>    l_pricing_engine_rows,
		x_return_status           =>    l_return_status );

	  -- set up data structure to call QP
	  -- call QP
	  -- check qp output for any errors

	  l_pricing_control_rec.pricing_event_num := fte_qp_engine.G_LINE_EVENT_NUM;
	  l_pricing_control_rec.currency_code     := l_currency_code;
	  l_pricing_control_rec.lane_id           := p_lane_info.lane_id;
	  l_pricing_control_rec.price_list_id     := p_lane_info.pricelist_id;
	  l_pricing_control_rec.party_id          := p_lane_info.carrier_id;

	  i := 1;
	  j := 0;
	  l_pricing_attribute_rows.DELETE;

	      j := j + 1;
		 l_pricing_attribute_rows(j).attribute_index := j;
		 l_pricing_attribute_rows(j).input_index     := i;
		 l_pricing_attribute_rows(j).attribute_name  := 'ORIGIN_ZONE';
		 l_pricing_attribute_rows(j).attribute_value := TO_CHAR(p_lane_info.origin_id);
	      j := j + 1;
		 l_pricing_attribute_rows(j).attribute_index := j;
		 l_pricing_attribute_rows(j).input_index     := i;
		 l_pricing_attribute_rows(j).attribute_name  := 'DESTINATION_ZONE';
		 l_pricing_attribute_rows(j).attribute_value := TO_CHAR(p_lane_info.destination_id);

	      IF p_lane_info.service_type_code IS NOT NULL THEN

	      j := j + 1;
		 l_pricing_attribute_rows(j).attribute_index := j;
		 l_pricing_attribute_rows(j).input_index     := i;
		 l_pricing_attribute_rows(j).attribute_name  := 'SERVICE_TYPE';  --  Is it required always
		 l_pricing_attribute_rows(j).attribute_value := p_lane_info.service_type_code;

	      END IF;



	       -- create standard engine line and attributes (default stuff created by pattern matching)
	       l_event_num := fte_qp_engine.G_LINE_EVENT_NUM;
	       fte_qp_engine.create_control_record(p_event_num => l_event_num,
						   x_return_status => l_return_status );

		   fte_freight_pricing_util.set_location(p_loc=>'after create_control_record ');
		   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
			 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
			raise FND_API.G_EXC_ERROR;
		   END IF;

	       --l_set_num   := 1;
	       i := l_pricing_engine_rows.FIRST;
	       IF (i IS NOT NULL) THEN
	       LOOP
		    fte_qp_engine.create_line_record (p_pricing_control_rec       => l_pricing_control_rec,
						      p_pricing_engine_input_rec  => l_pricing_engine_rows(i),
						      x_return_status             => l_return_status);

		   fte_freight_pricing_util.set_location(p_loc=>'after create_line_record. i='||i);
		   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
			 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
			raise FND_API.G_EXC_ERROR;
		   END IF;

		    fte_qp_engine.prepare_qp_line_qualifiers(
						      p_event_num               => l_event_num,
						      p_pricing_control_rec       => l_pricing_control_rec,
						      p_input_index             => l_pricing_engine_rows(i).input_index,
						      x_return_status           => l_return_status);

		   fte_freight_pricing_util.set_location(p_loc=>'after create qp line qualifiers. i='||i);
		   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
			 l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
			raise FND_API.G_EXC_ERROR;
		   END IF;

		    fte_qp_engine.prepare_qp_line_attributes (
						      p_event_num               => l_event_num,
						      p_input_index             => l_pricing_engine_rows(i).input_index,
						      p_attr_rows               => l_pricing_attribute_rows,
						      x_return_status           => l_return_status);

		    fte_freight_pricing_util.set_location(p_loc=>'after create qp line attributes. i='||i);
		    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
			  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
			raise FND_API.G_EXC_ERROR;
		    END IF;

	       EXIT WHEN i >= l_pricing_engine_rows.LAST;
	       i := l_pricing_engine_rows.NEXT(i);
	       END LOOP;
	       END IF;

	       -- call qp api
	       fte_qp_engine.call_qp_api    ( x_qp_output_line_rows    => l_qp_output_line_rows,
					      x_qp_output_detail_rows  => l_qp_output_detail_rows,
					      x_return_status          => l_return_status);

		   fte_freight_pricing_util.set_location(p_loc=>'after call_qp_api: Event 1');
		   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
		      l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			raise FND_API.G_EXC_ERROR;
		   END IF;

	       --check for errors in the output
		   fte_qp_engine.check_qp_output_errors (x_return_status   => l_return_status);
		   fte_freight_pricing_util.set_location(p_loc=>'after check_qp_output_errors: Event '||l_event_num);
		   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
		      l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			raise FND_API.G_EXC_ERROR;
		   END IF;

	       fte_qp_engine.print_qp_output();

	  IF (g_special_flags.minimum_charge_flag = 'Y') THEN

	    apply_min_charge(
		p_event_num      => l_event_num,
		x_charge_applied => l_charge_applied,
		x_return_status  => l_return_status);

	    fte_freight_pricing_util.set_location(p_loc=>'after apply_min_charge ');
	    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
		l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
	      raise FND_API.G_EXC_ERROR;
	    END IF;
	  END IF;

	  -- create request lines for the next event and call qp engine
	  IF (l_charge_applied = 'Y') THEN
	       l_event_num := fte_qp_engine.G_CHARGE_EVENT_NUM;
	       fte_qp_engine.prepare_next_event_request ( x_return_status           => l_return_status);

		    fte_freight_pricing_util.set_location(p_loc=>'after prepare_next_event_request');
		    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
			  l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
			raise FND_API.G_EXC_ERROR;
		    END IF;

	       fte_qp_engine.call_qp_api    ( x_qp_output_line_rows    => l_qp_output_line_rows,
					      x_qp_output_detail_rows  => l_qp_output_detail_rows,
					      x_return_status          => l_return_status);

		   fte_freight_pricing_util.set_location(p_loc=>'after call_qp_api: Event 2');
		   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
		       l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			raise FND_API.G_EXC_ERROR;
		   END IF;

	       --check for errors in the output
		   fte_qp_engine.check_qp_output_errors (x_return_status   => l_return_status);
		   fte_freight_pricing_util.set_location(p_loc=>'after check_qp_output_errors: Event '||l_event_num);
		   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
		      l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			raise FND_API.G_EXC_ERROR;
		   END IF;

	       fte_qp_engine.print_qp_output();

	  END IF; -- l_charge_applied = 'Y'

	  -- process qp output
	  --4294663
	  l_summary_amount := 0;

	  i := l_qp_output_line_rows.FIRST;
	  IF (i is not null) THEN
	  LOOP

	    l_fc_rec.quantity := l_pricing_engine_rows(l_qp_output_line_rows(i).line_index).line_quantity;
	    l_fc_rec.uom := l_pricing_engine_rows(l_qp_output_line_rows(i).line_index).line_uom;
	    l_fc_rec.currency_code := l_currency_code;

	    l_line_charge_amount := 0;
	    l_line_discount_amount := 0;

	    j := l_qp_output_detail_rows.FIRST;
	    IF (j is not null) THEN
	    LOOP

	      IF (l_qp_output_detail_rows(j).list_line_type_code = 'SUR' OR
		 l_qp_output_detail_rows(j).list_line_type_code = 'DIS' )
		AND (l_qp_output_line_rows(i).line_index =
		     l_qp_output_detail_rows(j).line_index ) THEN

		l_fc_charge_rec.total_amount :=
		  ABS( l_qp_output_detail_rows(j).adjustment_amount )
		  * l_qp_output_line_rows(i).priced_quantity;
		l_fc_charge_rec.charge_unit_value:= l_fc_charge_rec.total_amount / l_fc_rec.quantity;

		IF l_qp_output_detail_rows(j).list_line_type_code = 'SUR' THEN
		  l_line_charge_amount := l_line_charge_amount + l_fc_charge_rec.total_amount;
		  l_fc_charge_rec.unit_amount := l_fc_charge_rec.total_amount;

		  l_fc_charge_rec.line_type_code := 'CHARGE';

		  fte_freight_pricing.get_fc_type_id(
			      p_line_type_code => 'FTECHARGE',
			      p_charge_subtype_code  => l_qp_output_detail_rows(j).charge_subtype_code,
			      x_freight_cost_type_id  => l_fc_charge_rec.freight_cost_type_id,
			      x_return_status  =>  l_return_status);
		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
		       l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			raise FND_API.G_EXC_ERROR;
		  END IF;
		ELSE -- l_qp_output_detail_rows(j).list_line_type_code = 'DIS'
		  l_line_discount_amount := l_line_discount_amount + l_fc_charge_rec.total_amount;

		  l_fc_charge_rec.line_type_code := 'DISCOUNT';

		  fte_freight_pricing.get_fc_type_id(
			      p_line_type_code => 'FTEDISCOUNT',
			      p_charge_subtype_code  => 'DISCOUNT',
			      x_freight_cost_type_id  => l_fc_charge_rec.freight_cost_type_id,
			      x_return_status  =>  l_return_status);
		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
		       l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			raise FND_API.G_EXC_ERROR;
		  END IF;
		END IF;

		--distribute SUR/DIS into top level details
		n := FTE_FREIGHT_PRICING.g_rolledup_lines.FIRST;
		IF (n is not null) THEN
		LOOP

		  l_charge_count := l_charge_count + 1;
		  IF p_save_flag = 'M' THEN
		    x_freight_cost_main_charge(l_charge_count).delivery_detail_id := FTE_FREIGHT_PRICING.g_rolledup_lines(n).delivery_detail_id;
		    x_freight_cost_main_charge(l_charge_count).delivery_leg_id := p_top_level_rows(n).delivery_leg_id;
		    x_freight_cost_main_charge(l_charge_count).delivery_id :=
			fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).delivery_id;
		    x_freight_cost_main_charge(l_charge_count).uom := l_fc_rec.uom;
		    x_freight_cost_main_charge(l_charge_count).quantity := FTE_FREIGHT_PRICING.g_rolledup_lines(n).line_quantity;
		    x_freight_cost_main_charge(l_charge_count).line_type_code := l_fc_charge_rec.line_type_code;
		    x_freight_cost_main_charge(l_charge_count).freight_cost_type_id := l_fc_charge_rec.freight_cost_type_id;
		    x_freight_cost_main_charge(l_charge_count).charge_unit_value :=
			l_fc_charge_rec.charge_unit_value;
		    IF l_fc_charge_rec.unit_amount > 0 THEN
		      x_freight_cost_main_charge(l_charge_count).unit_amount :=
			round(l_fc_charge_rec.unit_amount * FTE_FREIGHT_PRICING.g_rolledup_lines(n).line_quantity / l_fc_rec.quantity, 2);
		    END IF;
		    x_freight_cost_main_charge(l_charge_count).total_amount :=
			round(l_fc_charge_rec.total_amount * FTE_FREIGHT_PRICING.g_rolledup_lines(n).line_quantity / l_fc_rec.quantity, 2);
		    x_freight_cost_main_charge(l_charge_count).currency_code := l_currency_code;
		    x_freight_cost_main_charge(l_charge_count).charge_source_code := 'PRICING_ENGINE';
		    x_freight_cost_main_charge(l_charge_count).estimated_flag := 'Y';
		  ELSE
		    x_freight_cost_temp_charge(l_charge_count).delivery_detail_id := p_top_level_rows(n).content_id;
		    x_freight_cost_temp_charge(l_charge_count).delivery_id :=
			fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).delivery_id;
		    x_freight_cost_temp_charge(l_charge_count).uom := l_fc_rec.uom;
		    x_freight_cost_temp_charge(l_charge_count).quantity := FTE_FREIGHT_PRICING.g_rolledup_lines(n).line_quantity;
		    x_freight_cost_temp_charge(l_charge_count).line_type_code := l_fc_charge_rec.line_type_code;
		    x_freight_cost_temp_charge(l_charge_count).freight_cost_type_id := l_fc_charge_rec.freight_cost_type_id;
		    x_freight_cost_temp_charge(l_charge_count).charge_unit_value :=
			l_fc_charge_rec.charge_unit_value;
		    IF l_fc_charge_rec.unit_amount > 0 THEN
		      x_freight_cost_temp_charge(l_charge_count).unit_amount :=
			round(l_fc_charge_rec.unit_amount * FTE_FREIGHT_PRICING.g_rolledup_lines(n).line_quantity / l_fc_rec.quantity, 2);
		    END IF;
		    x_freight_cost_temp_charge(l_charge_count).total_amount :=
			round(l_fc_charge_rec.total_amount * FTE_FREIGHT_PRICING.g_rolledup_lines(n).line_quantity / l_fc_rec.quantity, 2);
		    x_freight_cost_temp_charge(l_charge_count).currency_code := l_currency_code;
		    x_freight_cost_temp_charge(l_charge_count).charge_source_code := 'PRICING_ENGINE';
		    x_freight_cost_temp_charge(l_charge_count).estimated_flag := 'Y';
		  END IF;

		EXIT WHEN (n >= FTE_FREIGHT_PRICING.g_rolledup_lines.LAST);
		n := FTE_FREIGHT_PRICING.g_rolledup_lines.NEXT(n);
		END LOOP;
		END IF;

	      END IF; -- l_qp_output_detail_rows(j).list_line_type_code = 'SUR' or 'DIS'

	    EXIT WHEN (j >= l_qp_output_detail_rows.LAST);
	    j := l_qp_output_detail_rows.NEXT(j);
	    END LOOP;
	    END IF;

	    l_line_price_amount := l_qp_output_line_rows(i).unit_price *
		l_qp_output_line_rows(i).priced_quantity;
	    l_fc_rec.charge_unit_value := l_line_price_amount / l_fc_rec.quantity;
	    l_fc_rec.unit_amount := l_line_price_amount - l_line_discount_amount;
	    l_fc_rec.total_amount := l_fc_rec.unit_amount + l_line_charge_amount;
	    l_fc_rec.line_type_code := 'PRICE';

	    fte_freight_pricing.get_fc_type_id(
			      p_line_type_code => 'FTEPRICE',
			      p_charge_subtype_code  => 'PRICE',
			      x_freight_cost_type_id  => l_fc_rec.freight_cost_type_id,
			      x_return_status  =>  l_return_status);
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
		       l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			raise FND_API.G_EXC_ERROR;
	    END IF;

	    l_summary_amount := l_summary_amount + l_fc_rec.total_amount;

	    --distribute PRICE into top level containers

	    --4294663
	    l_leg_id:=NULL;

	    n := FTE_FREIGHT_PRICING.g_rolledup_lines.FIRST;
	    IF (n is not null) THEN
	    LOOP

		  l_price_count := l_price_count + 1;
		  IF l_leg_id is null THEN

		    IF(fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).parent_delivery_id IS NULL)
		    THEN

			    l_leg_id := p_top_level_rows(n).delivery_leg_id;
			    l_delivery_id :=
			      fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).delivery_id;
		    ELSE
		    --MDC if there are parent deliveries then
		    -- quantities for all the children are summed and sent to QP. The amounts are stored at the parent delivery level.
		    --The parent delivery id, dleg are captured
			    l_delivery_id :=
			      fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).parent_delivery_id;
			    l_leg_id :=fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).parent_delivery_leg_id;

		    END IF;

		  END IF;

		  IF p_save_flag = 'M' THEN
		    x_freight_cost_main_price(l_price_count).delivery_detail_id := p_top_level_rows(n).content_id;
		    x_freight_cost_main_price(l_price_count).delivery_leg_id := p_top_level_rows(n).delivery_leg_id;
		    x_freight_cost_main_price(l_price_count).delivery_id :=
			fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).delivery_id;
		    x_freight_cost_main_price(l_price_count).uom := l_fc_rec.uom;
		    x_freight_cost_main_price(l_price_count).quantity := FTE_FREIGHT_PRICING.g_rolledup_lines(n).line_quantity;
		    x_freight_cost_main_price(l_price_count).line_type_code := l_fc_rec.line_type_code;
		    x_freight_cost_main_price(l_price_count).freight_cost_type_id := l_fc_rec.freight_cost_type_id;
		    x_freight_cost_main_price(l_price_count).charge_unit_value :=
			l_fc_rec.charge_unit_value;
		    x_freight_cost_main_price(l_price_count).unit_amount :=
			round(l_fc_rec.unit_amount * FTE_FREIGHT_PRICING.g_rolledup_lines(n).line_quantity / l_fc_rec.quantity, 2);
		    x_freight_cost_main_price(l_price_count).total_amount :=
			round(l_fc_rec.total_amount * FTE_FREIGHT_PRICING.g_rolledup_lines(n).line_quantity / l_fc_rec.quantity, 2);
		    x_freight_cost_main_price(l_price_count).currency_code := l_currency_code;
		    x_freight_cost_main_price(l_price_count).charge_source_code := 'PRICING_ENGINE';
		    x_freight_cost_main_price(l_price_count).estimated_flag := 'Y';
		  ELSE
		    x_freight_cost_temp_price(l_price_count).delivery_detail_id := p_top_level_rows(n).content_id;
		    --x_freight_cost_temp_price(l_price_count).delivery_leg_id := p_top_level_rows(n).delivery_leg_id;
		    x_freight_cost_temp_price(l_price_count).delivery_id :=
			fte_freight_pricing.g_shipment_line_rows(p_top_level_rows(n).content_id).delivery_id;
		    x_freight_cost_temp_price(l_price_count).uom := l_fc_rec.uom;
		    x_freight_cost_temp_price(l_price_count).quantity := FTE_FREIGHT_PRICING.g_rolledup_lines(n).line_quantity;
		    x_freight_cost_temp_price(l_price_count).line_type_code := l_fc_rec.line_type_code;
		    x_freight_cost_temp_price(l_price_count).freight_cost_type_id := l_fc_rec.freight_cost_type_id;
		    x_freight_cost_temp_price(l_price_count).charge_unit_value :=
			l_fc_rec.charge_unit_value;
		    x_freight_cost_temp_price(l_price_count).unit_amount :=
			round(l_fc_rec.unit_amount * FTE_FREIGHT_PRICING.g_rolledup_lines(n).line_quantity / l_fc_rec.quantity, 2);
		    x_freight_cost_temp_price(l_price_count).total_amount :=
			round(l_fc_rec.total_amount * FTE_FREIGHT_PRICING.g_rolledup_lines(n).line_quantity / l_fc_rec.quantity, 2);
		    x_freight_cost_temp_price(l_price_count).currency_code := l_currency_code;
		    x_freight_cost_temp_price(l_price_count).charge_source_code := 'PRICING_ENGINE';
		    x_freight_cost_temp_price(l_price_count).estimated_flag := 'Y';
		  END IF;

	    EXIT WHEN (n >= FTE_FREIGHT_PRICING.g_rolledup_lines.LAST);
	    n := FTE_FREIGHT_PRICING.g_rolledup_lines.NEXT(n);
	    END LOOP;
	    END IF;

	  EXIT WHEN (i >= l_qp_output_line_rows.LAST);
	  i := l_qp_output_line_rows.NEXT(i);
	  END LOOP;
	  END IF;

	  -- create the summary record

	  fte_freight_pricing.get_fc_type_id(
		   p_line_type_code => 'FTESUMMARY',
		   p_charge_subtype_code  => 'SUMMARY',
		   x_freight_cost_type_id  =>  l_freight_cost_type_id,
		   x_return_status  =>  l_return_status);
	  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
		       l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			raise FND_API.G_EXC_ERROR;
	  END IF;


	l_leg_id_array(l_delivery_id):=l_leg_id;
	l_delivery_summary(l_delivery_id):=l_summary_amount;

	l_trip_summary_amount:=l_trip_summary_amount+l_summary_amount;
  	k:= l_delivery_id_array.NEXT(k);


  END LOOP;



  -- Add the summary rows at the end

  IF p_save_flag = 'M' THEN

    --4294663
    i:=l_delivery_id_array.FIRST;
    j:=1;
    WHILE(i IS NOT NULL)
    LOOP

	    x_fc_main_update_rows(j).delivery_leg_id := l_leg_id_array(i);
	    x_fc_main_update_rows(j).delivery_id := l_delivery_id_array(i);
	    x_fc_main_update_rows(j).freight_cost_id := fte_freight_pricing.get_fc_id_from_dleg(l_leg_id_array(i));
	    x_fc_main_update_rows(j).line_type_code := 'SUMMARY';
	    x_fc_main_update_rows(j).freight_cost_type_id := l_freight_cost_type_id;
	    x_fc_main_update_rows(j).unit_amount := round(l_delivery_summary(l_delivery_id_array(i)),2);
	    x_fc_main_update_rows(j).total_amount := round(l_delivery_summary(l_delivery_id_array(i)),2);
	    x_fc_main_update_rows(j).currency_code := l_currency_code;
	    x_fc_main_update_rows(j).charge_source_code := 'PRICING_ENGINE';
	    x_fc_main_update_rows(j).estimated_flag := 'Y';




	j:=j+1;
	i:=l_delivery_id_array.NEXT(i);
    END LOOP;

  ELSE

    i:=l_delivery_id_array.FIRST;

    WHILE(i IS NOT NULL)
    LOOP

	    --4294663
	    l_price_count := l_price_count + 1;
	    x_freight_cost_temp_price(l_price_count).delivery_id := l_delivery_id_array(i);
	    x_freight_cost_temp_price(l_price_count).line_type_code := 'SUMMARY';
	    x_freight_cost_temp_price(l_price_count).freight_cost_type_id :=  l_freight_cost_type_id;
	    x_freight_cost_temp_price(l_price_count).unit_amount := round(l_delivery_summary(l_delivery_id_array(i)),2);
	    x_freight_cost_temp_price(l_price_count).total_amount := round(l_delivery_summary(l_delivery_id_array(i)),2);
	    x_freight_cost_temp_price(l_price_count).currency_code := l_currency_code;
	    x_freight_cost_temp_price(l_price_count).charge_source_code := 'PRICING_ENGINE';
	    x_freight_cost_temp_price(l_price_count).estimated_flag := 'Y';



	i:=l_delivery_id_array.NEXT(i);
    END LOOP;


  END IF;


  x_summary_lanesched_price := round(l_trip_summary_amount,2);
  x_summary_lanesched_price_uom := l_currency_code;

  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'FND_API.G_EXC_ERROR');
        fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END;

END FTE_FREIGHT_PRICING_SPECIAL;

/
