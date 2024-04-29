--------------------------------------------------------
--  DDL for Package Body MSD_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_PURGE" AS
/* $Header: msdpurgb.pls 115.17 2004/06/30 16:58:10 jarora ship $ */


/* The following are helper cursors and procedures for deleting
 * information in the headers table for custom streams. There are
 * two important cases:
 *
 *  1. When the date is specified: In this case it is not known
 *     which information is deleted from the msd_cs_data table.
 *     Therfore, each header needs to be checked if a row
 *     exists in the msd_cs_data table that refers to it.
 *
 *  2. When no date is specified the data from msd_cs_data_headers
 *     can immediately be deleted.
 */

/* If given the name of a stream this provides the definition id.
 * This is useful when on the UI, there is no option to select
 * the custom stream, but represented in a hard-coded label.
 */

CURSOR get_cs_definition_id(p_cs_name in VARCHAR2) IS
SELECT cs_definition_id
  FROM msd_cs_definitions
 WHERE name = p_cs_name;

CURSOR get_cs_system_flag(p_cs_iden in VARCHAR2) IS
SELECT system_flag
  FROM msd_cs_definitions
 WHERE cs_definition_id = p_cs_iden;


/* Helper Functions */


/* Helper procedure for deleting data from custom stream tables.
 */

procedure delete_cs_data ( p_instance_id      IN varchar2,
                           p_cs_definition_id IN number,
                           p_cs_designator    IN varchar2,
                           p_from_date        IN date,
                           p_to_date          IN date ) IS

 TYPE cs_data_id_tab is table of msd_cs_data.cs_data_id%TYPE;

 t_cs_data_id   cs_data_id_tab;


cursor get_cs_data is
 select cs_data_id
   from msd_cs_data
  where cs_definition_id in (select cs_definition_id
                               from msd_cs_definitions
                              where cs_definition_id =  nvl(p_cs_definition_id , cs_definition_id)
                                and ((p_cs_definition_id is not null) or
                                     (system_flag = 'C')))
    and nvl(cs_name, '#$#$^&&&!!!!!!$%$%$%$%090@@') = nvl(p_cs_designator, nvl(cs_name, '#$#$^&&&!!!!!!$%$%$%$%090@@'))
    and nvl(attribute_43, '0001/01/01') between nvl(to_char(p_from_date, 'YYYY/MM/DD'), '0001/01/01')
    and nvl(to_char(p_to_date, 'YYYY/MM/DD'), '4317/12/31')
    and nvl(attribute_1, '-999') = nvl(p_instance_id, nvl(attribute_1, '-999'));

C_NUM_DELETE_ROWS number := 1000;

begin

  open get_cs_data;

  loop

    fetch get_cs_data bulk collect into t_cs_data_id LIMIT C_NUM_DELETE_ROWS;

    if (t_cs_data_id.exists(1)) then

      FORALL i IN t_cs_data_id.FIRST..t_cs_data_id.LAST
        DELETE FROM msd_cs_data
        WHERE cs_data_id = t_cs_data_id(i);

      FORALL i IN t_cs_data_id.FIRST..t_cs_data_id.LAST
        DELETE FROM msd_cs_data_ds
        WHERE cs_data_id = t_cs_data_id(i);
    else
      exit;
    end if;

    end loop;

  close get_cs_data;

  /* Analyze Custom Stream Tables */
  MSD_ANALYZE_TABLES.analyze_table(null, 5);
  /* End Analyze */

end delete_cs_data;

/* Table handler for the cs_data_header table. */
procedure delete_cs_headers    (p_instance_id IN NUMBER,
                                p_cs_def_id   IN NUMBER,
                                p_cs_name     IN VARCHAR2) IS

begin

    delete from msd_cs_data_headers
    where instance = nvl(p_instance_id, instance)
    and cs_definition_id = nvl(p_cs_def_id, cs_definition_id)
    and cs_name = nvl(p_cs_name, cs_name);



end delete_cs_headers;


/* Check for each header whether it contains a child row in msd_cs_data.
 * This procedure is called when date parameters are entered in purge.
 */
procedure check_cs_headers     (p_instance_id IN NUMBER,
                                p_cs_def_id   IN NUMBER,
                                p_cs_name     IN VARCHAR2) IS

x_num_rows number := 1;

cursor check_cs_data(p_instance_id in NUMBER, p_cs_id in number, p_cs_name in VARCHAR2) is
select 1
from msd_cs_data
where attribute_1 = p_instance_id
and cs_definition_id = p_cs_id
and cs_name = p_cs_name
and rownum = x_num_rows;

cursor check_cs_data_headers is
select *
from msd_cs_data_headers
where instance = nvl(p_instance_id, instance)
and cs_definition_id = nvl(p_cs_def_id, cs_definition_id)
and cs_name = nvl(p_cs_name, cs_name)
and exists ( select 1
                   from msd_cs_definitions csd
                  where csd.cs_definition_id = msd_cs_data_headers.cs_definition_id
                    and csd.system_flag = 'C' );

x_count number := 0;

begin

    /* Loop through all headers */

    for cs_rec in check_cs_data_headers loop

        open check_cs_data(cs_rec.instance, cs_rec.cs_definition_id, cs_rec.cs_name);
        fetch check_cs_data into x_count;
        if (check_cs_data%NOTFOUND) then
          delete_cs_headers(cs_rec.instance, cs_rec.cs_definition_id, cs_rec.cs_name);
        end if;
        close check_cs_data;

        x_count := 0;

    end loop;

end check_cs_headers;


/* This procedure is called after data is deleted from msd_cs_data.
 * It will determine whether dates are defined and determine
 * whether headers need to check for children in msd_cs_data
 */

procedure purge_cs_data_headers(p_instance_id IN NUMBER,
				p_from_date   IN VARCHAR2,
				p_to_date     IN VARCHAR2,
                                p_cs_def_id   IN NUMBER,
                                p_cs_name     IN VARCHAR2) IS

begin

  /* Date is included so the msd_cs_data needs to be checked for rows
   * that are deleted.
   */

  if (p_from_date is not null) or (p_to_date is not null) then

    /* Deletes data in headers checking date-filtered deletes in msd_cs_data */
    check_cs_headers (p_instance_id, p_cs_def_id, p_cs_name);

  else

    /* Deletes directly from headers since no date filtering done. */

    delete from msd_cs_data_headers
    where instance = nvl(p_instance_id, instance)
    and cs_definition_id = nvl(p_cs_def_id, cs_definition_id)
    and cs_name = nvl(p_cs_name, cs_name)
    and exists ( select 1
                   from msd_cs_definitions csd
                  where csd.cs_definition_id = msd_cs_data_headers.cs_definition_id
                    and csd.system_flag = 'C' );

  end if;

end purge_cs_data_headers;

/* Check for each header whether it contains a child row in msd_cs_data.
 * This procedure is called when date parameters are entered in purge.
 */
procedure check_mfg_headers     (p_instance_id IN NUMBER,
                                 p_cs_def_id   IN NUMBER,
                                 p_cs_name     IN VARCHAR2) IS

x_num_rows number := 1;

cursor check_mfg_data(p_instance_id in NUMBER, p_cs_id in number, p_cs_name in VARCHAR2) is
select 1
from msd_mfg_forecast
where instance = p_instance_id
and forecast_designator = p_cs_name
and rownum = x_num_rows;

cursor check_cs_data_headers is
select *
from msd_cs_data_headers
where instance = nvl(p_instance_id, instance)
and cs_definition_id = nvl(p_cs_def_id, cs_definition_id)
and cs_name = nvl(p_cs_name, cs_name);

x_count number := 0;

begin

    /* Loop through all headers */

    for cs_rec in check_cs_data_headers loop

        open check_mfg_data(cs_rec.instance, cs_rec.cs_definition_id, cs_rec.cs_name);
        fetch check_mfg_data into x_count;
        if (check_mfg_data%NOTFOUND) then
          delete_cs_headers(cs_rec.instance, cs_rec.cs_definition_id, cs_rec.cs_name);
        end if;
        close check_mfg_data;

        x_count := 0;

    end loop;

end check_mfg_headers;


/* This procedure is called after data is deleted from msd_mfg_forecast.
 * It will determine whether dates are defined and determine
 * whether headers need to check for children in msd_mfg_forecast
 */

procedure purge_mfg_data_headers(p_instance_id IN NUMBER,
                                 p_cs_def_id   IN NUMBER,
				 p_l_date      IN NUMBER,
                                 p_cs_name     IN VARCHAR2) IS

begin

  /* Date is included so the msd_cs_data needs to be checked for rows
   * that are deleted.
   */

  if (p_l_date <> 0) then

    /* Deletes data in headers checking date-filtered deletes in msd_cs_data */
    check_mfg_headers (p_instance_id, p_cs_def_id, p_cs_name);

  else

    /* Deletes directly from headers since no date filtering done. */
    delete_cs_headers(p_instance_id, p_cs_def_id, p_cs_name);

  end if;

end purge_mfg_data_headers;

/* Check for each header whether it contains a child row in msd_cs_data.
 * This procedure is called when date parameters are entered in purge.
 */
procedure check_int_headers     (p_instance_id IN NUMBER,
                                 p_cs_def_id   IN NUMBER,
                                 p_cs_name     IN VARCHAR2) IS

x_num_rows number := 1;

cursor check_int_data(p_instance_id in NUMBER, p_cs_id in number, p_cs_name in VARCHAR2) is
select 1
from msd_cs_data
where attribute_1 = p_instance_id
and cs_definition_id = p_cs_id
and cs_name = p_cs_name
and rownum = x_num_rows;

cursor check_cs_data_headers is
select *
from msd_cs_data_headers
where instance = nvl(p_instance_id, instance)
and cs_definition_id = p_cs_def_id
and cs_name = nvl(p_cs_name, cs_name);

x_count number := 0;

begin

    /* Loop through all headers */

    for cs_rec in check_cs_data_headers loop

        open check_int_data(cs_rec.instance, cs_rec.cs_definition_id, cs_rec.cs_name);
        fetch check_int_data into x_count;
        if (check_int_data%NOTFOUND) then
          delete_cs_headers(cs_rec.instance, cs_rec.cs_definition_id, cs_rec.cs_name);
        end if;
        close check_int_data;

        x_count := 0;

    end loop;

end check_int_headers;


/* This procedure is called after data is deleted from msd_cs_data.
 * It will determine whether dates are defined and determine
 * whether headers need to check for children in msd_cs_data
 */

procedure purge_int_data_headers(p_instance_id IN NUMBER,
				p_from_date   IN VARCHAR2,
				p_to_date     IN VARCHAR2,
                                p_cs_def_id   IN NUMBER,
                                p_cs_name     IN VARCHAR2) IS

begin

  /* Date is included so the msd_cs_data needs to be checked for rows
   * that are deleted.
   */

  if (p_from_date is not null) or (p_to_date is not null) then

    /* Deletes data in headers checking date-filtered deletes in msd_cs_data */
    check_int_headers (p_instance_id, p_cs_def_id, p_cs_name);

  else

    /* Deletes directly from headers since no date filtering done. */

    delete from msd_cs_data_headers
    where instance = nvl(p_instance_id, instance)
    and cs_definition_id = p_cs_def_id
    and cs_name = nvl(p_cs_name, cs_name);

  end if;

end purge_int_data_headers;



/* Public Procedures */

procedure purge_facts(
                      errbuf                OUT NOCOPY VARCHAR2,
                      retcode               OUT NOCOPY VARCHAR2,
                      p_instance_id         IN  NUMBER,
                      p_from_date           IN  VARCHAR2,
                      p_to_date             IN  VARCHAR2,
                      p_shipment_yes_no     IN  NUMBER,
                      p_booking_yes_no      IN  NUMBER,
                      p_mfg_fcst_yes_no     IN  NUMBER,
                      p_mfg_fcst_desg       IN  VARCHAR2,
                      p_sales_opp_yes_no    IN  NUMBER,
                      p_cust_order_yes_no   IN  NUMBER,
                      p_cust_sales_yes_no   IN  NUMBER,
                      p_cs_data_yes_no      IN  NUMBER,
                      p_cs_definition_id    IN  NUMBER,
                      p_cs_designator       IN  VARCHAR2,
                      p_curr_yes_no         IN  NUMBER,
                      p_uom_yes_no          IN  NUMBER,
                      p_time_yes_no         IN  NUMBER,
                      p_calendar_code       IN  VARCHAR2,
                      p_pricing_yes_no      IN  NUMBER,
                      p_price_list          IN  VARCHAR2,
                      p_scn_ent_yes_no      IN  NUMBER,
                      p_demand_plan_id      IN  NUMBER,
                      p_scenario_id         IN  NUMBER,
                      p_revision            IN  VARCHAR2,
                      p_level_values_yes_no IN  NUMBER
                      ) IS

x_from_date DATE;
x_to_date DATE;
l_delete_from varchar2(500);
l_date_where varchar2(500);
l_where varchar2(500);
l_final_str varchar2(4000);
l_date_used number;
x_cs_id number;
x_sys_flag varchar2(100);

l_latest_revision number;
b_delete_denorm   boolean := false;

begin
        l_date_used := 0;
        x_from_date := FND_DATE.canonical_to_date(p_from_date);
        x_to_date := FND_DATE.canonical_to_date(p_to_date);

             /* Build the date filter where-clause */

                 if x_from_date is not null and x_to_date is not null then
                        l_date_where := l_date_where ||
                        ' between to_date(''' ||
                        to_char(x_from_date, 'dd-mon-yyyy') || ''',''DD-MON-RRRR'') AND to_date(''' ||
                        to_char(x_to_date, 'dd-mon-yyyy') || ''',''DD-MON-RRRR'') ' ;
                        l_date_used := 1;
                elsif x_to_date is not null then
                        l_date_where := l_date_where ||
                        '  <= to_date(''' ||
                        to_char(x_to_date, 'dd-mon-yyyy') || ''',''DD-MON-RRRR'') ' ;
                        l_date_used := 1;
                elsif x_from_date is not null then
                        l_date_where := l_date_where ||
                        '  >= to_date(''' ||
                        to_char(x_from_date, 'dd-mon-yyyy') || ''',''DD-MON-RRRR'') ' ;
                        l_date_used := 1;
                end if ;

-- Delete Shipment data
if (p_shipment_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG) then
      	l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.SHIPMENT_FACT_TABLE;
      	l_where := ' where instance = nvl('''  ||  p_instance_id || ''',instance)' ;
      	if(l_date_used = 1) then
        	l_where := l_where || ' and shipped_date ' || l_date_where;
      	end if;
      	l_final_str := l_delete_from || l_where;
      	EXECUTE IMMEDIATE l_final_str;

        /* Analyze Shipment Fact Tables */
        MSD_ANALYZE_TABLES.analyze_table(MSD_COMMON_UTILITIES.SHIPMENT_FACT_TABLE,null);
        /* End Analyze Shipment Fact Tables */

end if;

-- Delete Booking data
if (p_booking_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG) then
      	l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.BOOKING_FACT_TABLE;
      	l_where := ' where instance = nvl('''  ||  p_instance_id || ''',instance)' ;
      	if(l_date_used = 1) then
        	l_where := l_where || ' and booked_date ' || l_date_where;
      	end if;
      	l_final_str := l_delete_from || l_where;
      	EXECUTE IMMEDIATE l_final_str;

        /* Analyze Booking Fact Tables */
        MSD_ANALYZE_TABLES.analyze_table(MSD_COMMON_UTILITIES.BOOKING_FACT_TABLE,null);
        /* End Analyze Booking Fact Tables */

end if;



-- Delete Manufacturing Forecast data
if (p_mfg_fcst_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG) then
      	l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.MFG_FCST_FACT_TABLE;
      	l_where := ' where instance = nvl('''  ||  p_instance_id || ''',instance)' ;
      	if(l_date_used = 1) then
        	l_where := l_where || ' and forecast_date ' || l_date_where;
      	end if;
      	l_where := l_where || ' and forecast_designator = nvl(:p_mfg_fcst_desg, forecast_designator)' ;
      	l_final_str := l_delete_from || l_where;
      	EXECUTE IMMEDIATE l_final_str using p_mfg_fcst_desg;

        open get_cs_definition_id('MSD_MANUFACTURING_FORECAST');
        fetch get_cs_definition_id into x_cs_id;
        close get_cs_definition_id;

        /* Remove header information. If necesary.*/
        purge_mfg_data_headers(
                          p_instance_id,
                          x_cs_id,
                          l_date_used,
                          p_mfg_fcst_desg);

        /* End Remove headers */

        /* Analyze Manufacturing Forecast Fact Tables */
        MSD_ANALYZE_TABLES.analyze_table(MSD_COMMON_UTILITIES.MFG_FCST_FACT_TABLE, null);
        /* End Analyze Manufacturing Forecast Fact Tables */


end if;

-- Delete Sales Opportunity data
if (p_sales_opp_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG) then

    open get_cs_definition_id('MSD_SALES_OPPORTUNITY');
    fetch get_cs_definition_id into x_cs_id;
    close get_cs_definition_id;

    delete_cs_data (   p_instance_id,
                       x_cs_id,
                       null,
                           x_from_date,
                           x_to_date );

    purge_int_data_headers(
                          p_instance_id,
                          p_from_date,
                          p_to_date,
                          x_cs_id,
                          null);
end if;


/** Added for Bug 2488293 - PURGE CUSTOM STREAM DATA GOT FROM DP-CP INTEGRATION **/
-- Delete Customer Orders Forecast data
if (p_cust_order_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG) then

    open get_cs_definition_id('MSD_CUSTOMER_ORDER_FORECAST');
    fetch get_cs_definition_id into x_cs_id;
    close get_cs_definition_id;

    delete_cs_data (   p_instance_id,
                           x_cs_id,
                           null,
                           x_from_date,
                           x_to_date );

    purge_int_data_headers(
                          p_instance_id,
                          p_from_date,
                          p_to_date,
                          x_cs_id,
                          null);

end if;

-- Delete Customer Sales Forecast data
if (p_cust_sales_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG) then

    open get_cs_definition_id('MSD_CUSTOMER_SALES_FORECAST');
    fetch get_cs_definition_id into x_cs_id;
    close get_cs_definition_id;


    delete_cs_data (   p_instance_id,
                           x_cs_id,
                           null,
                           x_from_date,
                           x_to_date );

    purge_int_data_headers(p_instance_id,
                          p_from_date,
                          p_to_date,
                          x_cs_id,
                          null);
end if;


/** Delete Custom Data **/
if p_cs_data_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG then

    if (p_cs_definition_id is not null) then
      open get_cs_system_flag(p_cs_definition_id);
      fetch get_cs_system_flag into x_sys_flag;
      close get_cs_system_flag;
    end if;

    if (x_sys_flag = 'I') then

      /* Seeded custom stream can only be deleted one at a time.
       * Therefore the user must have specified the id of the
       * stream.
       */

      if(p_cs_definition_id is not null) then

        delete_cs_data (   p_instance_id,
                           p_cs_definition_id,
                           p_cs_designator,
                           x_from_date,
                           x_to_date );

         purge_int_data_headers(p_instance_id,
	     		        p_from_date,
			        p_to_date,
                                p_cs_definition_id,
                                p_cs_designator);

       end if;

    else

       delete_cs_data (   p_instance_id,
                          p_cs_definition_id,
                          p_cs_designator,
                          x_from_date,
                          x_to_date );

       purge_cs_data_headers(p_instance_id,
	   		     p_from_date,
			     p_to_date,
                             p_cs_definition_id,
                             p_cs_designator);

    end if;

end if;

/**  Delete Currency data **/
if (p_curr_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG) then
      	l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.CURRENCY_FACT_TABLE;
      	l_final_str := l_delete_from;
      	EXECUTE IMMEDIATE l_final_str;

        /* Analyze Currency Code Fact Tables */
        MSD_ANALYZE_TABLES.analyze_table(MSD_COMMON_UTILITIES.CURRENCY_FACT_TABLE, null);
        /* End Analyze Currency Code Fact Tables */

end if;

-- Delete UOM data
if (p_uom_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG) then
      	l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.UOM_FACT_TABLE;
      	l_where := ' where nvl(instance,1) = nvl('''  ||  p_instance_id || ''',nvl(instance,1))' ;
      	l_final_str := l_delete_from || l_where;
      	EXECUTE IMMEDIATE l_final_str;

        /* Analyze Uom Conversion Fact Tables */
        MSD_ANALYZE_TABLES.analyze_table(MSD_COMMON_UTILITIES.UOM_FACT_TABLE, null);
        /* End Analyze Uom Conversion Fact Tables */

end if;

-- Delete Time data
if (p_time_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG) then

     l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.TIME_FACT_TABLE;

     if (p_calendar_code = 'GREGORIAN') then

      	l_where := ' where calendar_type = ' || MSD_COMMON_UTILITIES.GREGORIAN_CALENDAR;
      	if(l_date_used = 1) then
            l_where := l_where || ' and day ' || l_date_where;
	end if;
	l_final_str := l_delete_from || l_where;
	EXECUTE IMMEDIATE l_final_str;

      else

      	l_where := ' where instance = nvl('''  ||  p_instance_id || ''',instance)' ;
      	l_where := l_where || ' and calendar_code = nvl(:p_calendar_code,calendar_code)' ;
      	if(l_date_used = 1) then
            l_where := l_where || ' and day ' || l_date_where;
	end if;
	l_final_str := l_delete_from || l_where;
	EXECUTE IMMEDIATE l_final_str using p_calendar_code;

      end if;

      /* Analyze Time Fact Tables */
      MSD_ANALYZE_TABLES.analyze_table(MSD_COMMON_UTILITIES.TIME_FACT_TABLE, null);
      /* End Analyze Time Fact Tables */

end if;


-- Delete Pricing data
if (p_pricing_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG) then
	l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.PRICING_FACT_TABLE;
	l_where := ' where instance = nvl('''  ||  p_instance_id || ''',instance)' ;
	l_where := l_where || ' and price_list_name = nvl(:p_price_list, price_list_name)' ;
	l_final_str := l_delete_from || l_where;
	EXECUTE IMMEDIATE l_final_str using p_price_list;

        /* Analyze Pricing Fact Tables */
        MSD_ANALYZE_TABLES.analyze_table(MSD_COMMON_UTILITIES.PRICING_FACT_TABLE, null);
        /* End Analyze Pricing Fact Tables */

end if;


-- Delete Scenario entries data
if (p_scn_ent_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG) then

        IF p_revision is not null THEN

           SELECt nvl(max(revision), -999) into l_latest_revision
           from   msd_dp_scenario_revisions
           where  demand_plan_id = p_demand_plan_id and
                  scenario_id  = p_scenario_id;

           IF (p_revision = l_latest_revision) THEN
              b_delete_denorm := TRUE;
           ELSE
              b_delete_denorm := FALSE;
           END IF;
        END IF;

	l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.SCENARIO_ENTRIES_TABLE;
	l_where := ' where nvl(instance,-999) = nvl('''  ||  p_instance_id || ''', nvl(instance,-999))' ;
	l_where := l_where || ' and demand_plan_id = nvl('''  ||  p_demand_plan_id || ''',demand_plan_id)' ;
	l_where := l_where || ' and scenario_id = nvl('''  ||  p_scenario_id || ''',scenario_id)' ;
	l_where := l_where || ' and revision = nvl('''  ||  p_revision || ''',revision)' ;
	l_final_str := l_delete_from || l_where;
	EXECUTE IMMEDIATE l_final_str;

        l_delete_from := 'delete from msd_dp_scenario_revisions';
	l_where := ' where demand_plan_id = nvl('''  ||  p_demand_plan_id || ''',demand_plan_id)' ;
	l_where := l_where || ' and scenario_id = nvl('''  ||  p_scenario_id || ''',scenario_id)' ;
	l_where := l_where || ' and revision = nvl('''  ||  p_revision || ''',revision)' ;
        l_final_str := l_delete_from || l_where;
	EXECUTE IMMEDIATE l_final_str;

        l_delete_from := 'delete from msd_dp_planning_percentages';
	l_where := ' where demand_plan_id = nvl('''  ||  p_demand_plan_id || ''',demand_plan_id)' ;
	l_where := l_where || ' and dp_scenario_id = nvl('''  ||  p_scenario_id || ''', dp_scenario_id)' ;
	l_where := l_where || ' and revision = nvl('''  ||  p_revision || ''',revision)' ;
	l_where := l_where || ' and nvl(instance,-999) = nvl('''  || p_instance_id || ''', nvl(instance,-999)) ';
        l_final_str := l_delete_from || l_where;
	EXECUTE IMMEDIATE l_final_str;

        IF (  p_revision is null or
              b_delete_denorm = TRUE ) THEN

    	      l_delete_from := 'delete from msd_dp_scn_entries_denorm ';
	      l_where := ' where nvl(sr_instance_id,-999) = nvl('''  ||  p_instance_id || ''', nvl(sr_instance_id,-999))' ;
	      l_where := l_where || ' and demand_plan_id = nvl('''  ||  p_demand_plan_id || ''',demand_plan_id)' ;
	      l_where := l_where || ' and scenario_id = nvl('''  ||  p_scenario_id ||	''',scenario_id) ' ;
	      l_final_str := l_delete_from || l_where;
	      EXECUTE IMMEDIATE l_final_str;

    	      l_delete_from := 'delete from msd_dp_planning_pct_denorm ';
	      l_where := ' where nvl(sr_instance_id,-999) = nvl('''  || p_instance_id || ''', nvl(sr_instance_id,-999))' ;
	      l_where := l_where || ' and demand_plan_id = nvl('''  ||  p_demand_plan_id || ''',demand_plan_id)' ;
	      l_where := l_where || ' and dp_scenario_id = nvl('''  ||	p_scenario_id || ''', dp_scenario_id) ' ;
	      l_final_str := l_delete_from || l_where;
	      EXECUTE IMMEDIATE l_final_str;

        END IF;

        /* Analyze Scenario Entry Fact Tables */
        MSD_ANALYZE_TABLES.analyze_table(MSD_COMMON_UTILITIES.SCENARIO_ENTRIES_TABLE, null);
        /* End Analyze Scenario Entry Fact Tables */


end if;

-- Delete Level value, associations and item attributes data
if (p_level_values_yes_no = MSD_COMMON_UTILITIES.MSD_YES_FLAG) then
	l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.LEVEL_VALUES_FACT_TABLE;
	l_where := ' where instance = nvl('''  ||  p_instance_id || ''',instance)' ;
	l_final_str := l_delete_from || l_where;
	EXECUTE IMMEDIATE l_final_str;

	l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.LEVEL_ASSOC_FACT_TABLE;
	l_where := ' where instance = nvl('''  ||  p_instance_id || ''',instance)' ;
	l_final_str := l_delete_from || l_where;
	EXECUTE IMMEDIATE l_final_str;

	l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.ITEM_INFO_FACT_TABLE;
	l_where := ' where instance = nvl('''  ||  p_instance_id || ''',instance)' ;
	l_final_str := l_delete_from || l_where;
	EXECUTE IMMEDIATE l_final_str;

	l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.MSD_LOCAL_ID_SETUP_TABLE;
	l_where := ' where instance_id = nvl('''  ||  p_instance_id || ''',instance_id)' ;
	l_final_str := l_delete_from || l_where;
	EXECUTE IMMEDIATE l_final_str;

	l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.LEVEL_ORG_ASSCNS_FACT_TABLE;
	l_where := ' where instance = nvl('''  ||  p_instance_id || ''',instance)' ;
	l_final_str := l_delete_from || l_where;
	EXECUTE IMMEDIATE l_final_str;

        l_delete_from := 'delete from ' || MSD_COMMON_UTILITIES.ITEM_RELATIONSHIPS_FACT_TABLE;
	l_where := ' where instance_id = nvl('''  ||  p_instance_id || ''',instance_id)' ;
	l_final_str := l_delete_from || l_where;
	EXECUTE IMMEDIATE l_final_str;


        /* Added for Deleting Stripes Data */
        delete from msd_level_values_ds;

        delete from msd_dp_parameters_ds;

        delete from msd_cs_data_ds;

        update msd_demand_plans
        set build_stripe_level_pk = null,
            build_stripe_stream_name = null,
            build_stripe_stream_desig = null,
            build_stripe_stream_ref_num = null;

        /* End Deleting Stripes Data */

        /* Analyze Level Value Fact Tables */
        MSD_ANALYZE_TABLES.analyze_table(null,2);
        /* End Analyze Level Value Fact Tables */

end if;

commit;


exception
  when others then
      errbuf := substr(SQLERRM,1,150);
      retcode := -1 ;

end purge_facts;

END MSD_PURGE ;


/
