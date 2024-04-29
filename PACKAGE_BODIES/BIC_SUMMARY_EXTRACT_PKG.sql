--------------------------------------------------------
--  DDL for Package Body BIC_SUMMARY_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIC_SUMMARY_EXTRACT_PKG" as
/* $Header: bicsummb.pls 120.8 2006/08/17 07:18:24 vsegu ship $ */

  -- following two variable are used for debugging purpose.
  -- g_proc_name is set to procedure name in a procedure and g_srl_no
  -- gives serial number of measure_code being processed. In this way
  -- person debugging this program can group all the messages related to
  -- processing of a measure and find the place of error.


  g_proc_name_old        varchar2(50);
  g_srl_no               number;
  g_dup_record_error     varchar2(10);
  g_tot_recs_added       number;
  g_delete_flag		 varchar2(1); -- added by kalyan for delete flag

  -- Global variables for who columns
  g_last_updated_by        number ;
  g_created_by             number ;
  g_last_update_login      number ;
  g_request_id             number ;
  g_program_application_id number ;
  g_program_id             number ;

  -- global variables for program parameters
  --  g_period_start_date        date;
  g_period_end_date          date;
  --g_measure_code             bic_measures_all.measure_code % type;
  g_org_id                   bic_measures_all.org_id       % type;

  -- Global value for Activation and attrition periods
  g_attrition_period   bic_profile_values_all.attrition_period  % type;
  g_activation_period  bic_profile_values_all.activation_period % type;

  -- Global variables for measure codes
  g_measure_id_for_retn bic_measures_all.measure_id % type;
  g_measure_id_for_acqu bic_measures_all.measure_id % type;
  g_measure_id_for_acti bic_measures_all.measure_id % type;


  -- Global variable for debug option
  g_debug varchar2(10);

  -- global variable for insert scheme
  g_insert_scheme varchar2(30) := null;

procedure insert_order_measures;
procedure insert_order_delivery_measures;
procedure process_sql_type_measures;
-------------------------------------------------------------------
PROCEDURE debug( debug_str VARCHAR2) IS
  BEGIN
  g_debug := fnd_profile.value('BIC_DEBUG');
  FND_LOG.G_CURRENT_RUNTIME_LEVEL := 1;
  FND_GLOBAL.APPS_INITIALIZE (fnd_global.user_id,fnd_global.resp_id,fnd_global.prog_appl_id);
   if g_debug = 'Y' then
       --This is to meet 11.5.10 logging standards
   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
           FND_PROFILE.value('AFLOG_MODULE')||'_'||g_proc_name, debug_str);
   end if;
    end if;
  END debug;
procedure extract_calendar(errbuf    out NOCOPY varchar2,
			   retcode   out NOCOPY number  ) is
begin
  -- refresh bic_periods table
  delete from bic_periods;
  insert into bic_periods
       ( ACT_PERIOD_NAME          ,
         LAST_UPDATE_DATE         ,
         CREATION_DATE            ,
         LAST_UPDATED_BY          ,
         CREATED_BY               ,
         START_DATE               ,
         ACT_PERIOD_START_DATE    ,
         ACT_PERIOD_END_DATE      ,
         ACT_YEAR                 ,
         ACT_PERIOD_NUM           ,
         ACT_QUARTER              ,
         ACT_YEAR_START_DATE      ,
         ACT_QUARTER_START_DATE   ,
         ACT_HALF_YEAR            )
     SELECT period_name act_period_name
           , sysdate
	      , sysdate
	      , 0
	      , 0
           , start_date
           , start_date         act_period_start_date
           , end_date           act_period_end_date
           , period_year        act_year
           , period_num         act_period_num
           , quarter_num        act_quarter
           , year_start_date    act_year_start_date
           , quarter_start_date act_quarter_start_date
           , decode(quarter_num,1,1,2,1,3,2,4,2,null) act_half_year
        from gl_periods                gprd
     WHERE
       PERIOD_SET_NAME=FND_PROFILE.VALUE('CRMBIS:PERIOD_SET_NAME')
       AND ADJUSTMENT_PERIOD_FLAG <>'Y'
       AND PERIOD_TYPE=FND_PROFILE.VALUE('CRMBIS:PERIOD_TYPE')
	;
	commit;

  --------- Bic_periods table refreshed.
end;

--------------- functions / procedures new addition-------------
procedure generate_error(p_measure_code varchar2 default null, msg varchar2) is
status varchar2(10);
measure_code varchar2(50);
begin
if p_measure_code is null then
measure_code := 'MAIN';
else
measure_code := p_measure_code;
end if;
if measure_code is not null or measure_code = 'MAIN' then
status := 'ERROR';
else
status := 'WARNING';
end if;
   if (FND_CONCURRENT.SET_COMPLETION_STATUS (status,msg)) = true then
          null;
          else
          write_log(' setting the status failed');
          end if;
end generate_error;

function if_exists ( p_date	date ) return boolean is
cnt	number;
begin
	cnt := 0;
	select	count(*) into cnt
	from	bic_dimv_time
	where	--act_period_start_date =  trunc(p_date,'MONTH');
	trunc(p_date) between trunc(act_period_start_date) and trunc(act_period_end_date); --bug 4308058
	if cnt = 1	then
		return 	true;
	else
		return	false;
	end if;
exception when others then
       write_log(' The date ' || p_date || ' does not exist in bic_dimv_time ');
	   return false;
end;

function set_periods_exist (	p_start_date	varchar2,
				p_end_date	varchar2
				) return boolean is
x_date date;
begin
	write_log('set_periods_exist entered');
	if g_measure_code is null then
		if p_start_date is not null then
			g_period_start_date := fnd_date.canonical_to_date(p_start_date);
		else
			select fnd_profile.value('BIC_SMRY_EXTRACTION_DATE') into x_date
		       	from dual;
		    if x_date is null then
			   write_log('Error: Start Date not Specified and Profile Option' ||
		                      ' BIC_SMRY_EXTRACTION_DATE is not set');
               generate_error('Main',' Profile Option BIC_SMRY_EXTRACTION_DATE is not set' );
			   return false;
		    end if;
		    select  act_period_end_date +1 into g_period_start_date
	        from    bic_dimv_time
		    where   trunc(act_period_start_date) = trunc(x_date);
			write_log('Start Date as obtained from Profile Value:'||
				to_char(g_period_start_date,'dd-mm-yyyy'));
  		end if;
  		if p_end_date is not null then
			g_period_end_date := fnd_date.canonical_to_date(p_end_date);
		else
			select max(act_period_start_date) into g_period_end_date
			from bic_dimv_time
			where trunc(act_period_end_date) < trunc(sysdate);
			write_log('End Date set as:'||to_char(g_period_end_date,'dd-mm-yyyy'));
		end if;
	else
		if ( (p_start_date is null) OR (p_end_date is null) ) then
			write_log('Error: Start Date or End Date should not be null
				   while extracting only for a measure_code ');
            generate_error('Main',' Error: Start Date or End Date should not be null
				   while extracting only for a measure_code ' );
			return false;
		else
			g_period_start_date := fnd_date.canonical_to_date(p_start_date);
			g_period_end_date := fnd_date.canonical_to_date(p_end_date);
		end if;
    end if;
    if (	if_exists(g_period_start_date) AND
		if_exists(g_period_end_date) ) then
		null;
	else
        generate_error('Main',' Start Date or End Date doesnot exist in bic_dimv_time ' );
		return false;
	end if;
    return true;
exception when others then
	   write_log(' Exception occurred in set_periods_exist function ');
       generate_error('Main',' Exception occurred in set_periods_exist function ' );
	   return false;
end;

procedure	extract_periods(	p_start_date	date,
				p_end_date	date,
				p_measure_code	varchar2,
				p_org_flag	varchar2,
				p_delete_flag	varchar2,
				p_org_id	number ) IS

 TYPE curTyp IS REF CURSOR;
 per_cur	curTyp;
 org_str	varchar2(3000);
 n_org_str	varchar2(3000);
 rec_temp		bic_temp_periods%ROWTYPE;
 rec		bic_dimv_time%ROWTYPE;
 i number;
 errcode    number;
 errmesg    varchar2(200);
begin
org_str := ' select distinct bdt.* , hou.organization_id
             from   hr_operating_units hou,
                    fnd_product_groups ,
                    bic_party_summ db ,
                    bic_dimv_time bdt
	        where product_group_id = 1
	        and multi_org_flag = ''Y''
            and	ACT_PERIOD_START_DATE	between :p_start_date
					                    and	:p_end_date
            and    hou.organization_id = db.org_id (+)
            and    hou.organization_id = nvl ( :p_org_id , hou.organization_id)
            and    not exists (
                    select 1
                    from   bic_party_summ bps
                    where  bdt.ACT_PERIOD_START_DATE =  bps.PERIOD_START_DATE
                    and    bps.org_id =  hou.organization_id
            and	'||rtrim(ltrim(p_measure_code))||' is not null ) ' ;

	n_org_str:= '	select	*
		from	bic_dimv_time bdt
		where	ACT_PERIOD_START_DATE	between :p_start_date
						and	:p_end_date
	    and	not  exists (
					select	1
					from	bic_party_status_summ bps
					where	bdt.ACT_PERIOD_START_DATE = bps.PERIOD_START_DATE
				    and	'||rtrim(ltrim(p_measure_code))||' is not null ) ' ;
     if (p_delete_flag = 'Y' )	then
            write_log('Exiting from fill_dates as delete flag is Y');
			return ;
	end if;
    delete from	bic_temp_periods;
    if ( p_org_flag = 'Y' )	then
	    OPEN	per_cur	FOR org_str
				USING	p_start_date,
					    p_end_date,
					    p_org_id;
            LOOP
            FETCH per_cur INTO rec_temp ;
            EXIT WHEN per_cur%NOTFOUND;
			insert into bic_temp_periods
		( ACT_PERIOD_NAME, START_DATE, ACT_PERIOD_START_DATE, ACT_PERIOD_END_DATE, ACT_YEAR,
		  ACT_PERIOD_NUM, ACT_QUARTER, ACT_YEAR_START_DATE, ACT_QUARTER_START_DATE, ACT_HALF_YEAR , ORG_ID ) values
		( rec_temp.ACT_PERIOD_NAME, rec_temp.START_DATE, rec_temp.ACT_PERIOD_START_DATE, rec_temp.ACT_PERIOD_END_DATE, rec_temp.ACT_YEAR,
		  rec_temp.ACT_PERIOD_NUM, rec_temp.ACT_QUARTER, rec_temp.ACT_YEAR_START_DATE, rec_temp.ACT_QUARTER_START_DATE, rec_temp.ACT_HALF_YEAR, rec_temp.ORG_ID ) ;
        END LOOP;
	    CLOSE per_cur;
    else
	    OPEN	per_cur	FOR n_org_str
			    USING	p_start_date,
					    p_end_date ;
			LOOP
			FETCH per_cur INTO rec ;
            EXIT WHEN per_cur%NOTFOUND;
			insert into bic_temp_periods
		( ACT_PERIOD_NAME, START_DATE, ACT_PERIOD_START_DATE, ACT_PERIOD_END_DATE, ACT_YEAR,
		  ACT_PERIOD_NUM, ACT_QUARTER, ACT_YEAR_START_DATE, ACT_QUARTER_START_DATE, ACT_HALF_YEAR  ) values
		( rec.ACT_PERIOD_NAME, rec.START_DATE, rec.ACT_PERIOD_START_DATE, rec.ACT_PERIOD_END_DATE, rec.ACT_YEAR,
		rec.ACT_PERIOD_NUM, rec.ACT_QUARTER, rec.ACT_YEAR_START_DATE, rec.ACT_QUARTER_START_DATE, rec.ACT_HALF_YEAR ) ;
			END LOOP;
		CLOSE per_cur;
		end if;
        commit;
end;

procedure extract_all_periods (	p_start_date	date,
				p_end_date	date ) IS
begin
    delete from bic_temp_periods;
	insert into bic_temp_periods (
			SELECT	bdt.act_period_name , bdt.start_date , bdt.act_period_start_date ,
                    bdt.act_period_end_date , bdt.act_year , bdt.act_period_num ,
                    bdt.act_quarter , bdt.act_year_start_date , bdt.act_quarter_start_date ,
                    bdt.act_half_year , null
			FROM	bic_dimv_time bdt
			where	ACT_PERIOD_START_DATE	between p_start_date
							and	p_end_date );
		commit;
end;

---------------new functions / procedures end	-------------

function get_measure_id(p_measure_code varchar2) return number is
  x_measure_id bic_measures_all.measure_id % type;
  cursor measure_id_cur is
    select measure_id
      from bic_measures_all
     where org_id is null
	  and measure_code = p_measure_code;
begin
  open measure_id_cur;
  fetch measure_id_cur into x_measure_id;
  if measure_id_cur % notfound then
	close measure_id_cur;
	return(0);
  end if;
  close measure_id_cur;
  return(x_measure_id);
end;
function convert_amt(p_from_currency_code varchar2,
				 p_date               date,
				 p_amt                number) return number is
  x_converted_amt number;
begin
g_to_currency_code  := FND_PROFILE.VALUE('CRMBIS:CURRENCY_CODE');
g_conversion_type   := FND_PROFILE.VALUE('CRMBIS:GL_CONVERSION_TYPE');
  if p_from_currency_code is null then return p_amt;
  end if;
  x_converted_amt := gl_currency_api.convert_amount_sql(
				   x_from_currency => p_from_currency_code,
				   x_to_currency   => g_to_currency_code,
				   x_conversion_date   => p_date,
				   x_conversion_type   => g_conversion_type,
				   x_amount            => p_amt);
  return(x_converted_amt);
end;

-- This procedure checks value of profile option, BIC_DEBUG and if  its value
-- is 'Y' then it sets g_log_output variable and message are inserted into
-- bic_debug table.
procedure set_debug is
begin
  g_debug := fnd_profile.value('BIC_DEBUG');
  exception
    when others then null;
end set_debug;
--
--This procedure writes debug messages
procedure write_debug_msg(p_msg varchar2) is
begin
  if g_debug = 'Y' then
	insert into bic_debug ( report_id,message,creation_date)
			     values ('BICCSUMM' || to_char(g_srl_no,'999'),
	                       to_char(g_srl_no,'99') || '-'|| p_msg || ': ' ||
					   g_proc_name || ': ' ||
					   to_char(sysdate,'HH24:mi:ss'),
					   sysdate
				    );
     commit;
  end if;
  exception
    when others then null;
end write_debug_msg;
--
-- This procedure log errors and information messages
-- The variable g_log_output is set to null by default. In this way when
-- program is executed by concurrent manager, output is printed using
-- fnd_file.put_line procedure. When this procedure is being executed from SQL
-- prompt, user(mainly programmer) can set g_log_output to any not null value
-- in this way log output will be printed via dbms_output.put_line because
-- fnd_file.put_line does not work from SQL prompt.
function measure_disabled(p_measure_code varchar2) return varchar2 is
  x_disable_flag bic_measure_attribs.disable_flag % type;
begin
   select disable_flag into x_disable_flag
     from bic_measure_attribs
    where measure_code = p_measure_code;

   return(nvl(x_disable_flag,'N'));

   exception
	 when others then
	   -- write_log(sqlerrm);
	   return('Y');
end; -- measure_disabled
--
-- This procedure gets activation and attrition period. These values are
-- applicable to all org_ids

function get_activation_period return boolean is
   cursor profile_cur is
	 select	nvl(activation_period,90)
	   from	bic_profile_values_all;
begin
   g_proc_name := 'Get_Profile_values';
   open profile_cur;
   fetch profile_cur into g_activation_period;
   if profile_cur % notfound then
	  --write_log('Bic_profile_values_all does not have any records.' ||
	        --    'Contact Your System Administrator.');
       close profile_cur;
	  return(false);
   end if;
   close profile_cur;
   return(true);
end;

function get_attrition_period return boolean is
   cursor profile_cur is
	 select	nvl(ATTRITION_PERIOD,2)
	   from	bic_profile_values_all;
begin
   g_proc_name_old := g_proc_name;
   g_proc_name := 'Get_attrition_period';
   write_log('get_attrition_period entered');
   open profile_cur;
   fetch profile_cur into g_attrition_period;
   if profile_cur % notfound then
	 -- write_log('Bic_profile_values_all does not have any records.' ||
	          --  'Contact Your System Administrator.');
       close profile_cur;
        g_proc_name := g_proc_name_old;
	  return(false);
   end if;
   close profile_cur;
 g_proc_name := g_proc_name_old;
   return(true);
end;

--
-- This procedure gives the value of a given measure_id for a given customer
-- and period_start_date.
procedure get_measure_value (p_period_start_date     date,
					    p_customer_id           number,
					    p_measure_id            number,
					    p_value        in out NOCOPY   number) as
begin
    g_proc_name_old := g_proc_name;
    g_proc_name     := 'get_measure_value';
        debug('entered +');
    select value into p_value
	 from bic_customer_summary_all
     where period_start_date = p_period_start_date
	  and customer_id       = p_customer_id
	  and measure_id        = p_measure_id;
         debug('entered +');
    g_proc_name := g_proc_name_old;
    exception
	 when no_data_found then
	   p_value := 0;
	   -- the error message is not being generated because it possible that
	   -- a measure does not exist for a customer. For example a customer may
	   -- not have logger any service request in a given period and in that
	   -- case return of zero is the right value.
    /*   when others then
       write_log('exception occurred for this measure_id : '||p_measure_id);*/
end get_measure_value;

-- This procedure gives measure_id for a given measure code and org
procedure get_measure_id(p_measure_code         varchar2,
					p_org_id               number,
					p_measure_id in out NOCOPY    number) as
begin
    g_proc_name_old := g_proc_name;
    g_proc_name := 'get_measure_id';
    select measure_id into p_measure_id
	 from bic_measures_all
	where measure_code   = p_measure_code
	  and nvl(org_id,-1) = nvl(p_org_id,-1);

    g_proc_name := g_proc_name_old;
    exception
	 when no_data_found then
	  write_log('Measure id not found in bic_measures_all for measure ' ||
			 'Code:' ||p_measure_code || ' & Org Id:'||to_char(p_org_id));
            null;

end get_measure_id;

-- This procedure finds the weight of a given measure_id.
procedure get_weight  (p_measure_id           number,
				   p_weight        in out NOCOPY number,
				   p_measure_code  in out NOCOPY varchar2) as
begin
    g_proc_name_old := g_proc_name;
	g_proc_name := 'get_weight';
        debug('entered +');
	-- Key to this table is measure id, so org_id is not needed
	-- in where condition
    debug('get_weight entered for measure_id : '||p_measure_id);
	select nvl(weight,0)  , measure_code
	  into p_weight, p_measure_code
	  from bic_measures_all
      where measure_id = p_measure_id;
    debug('weight : '||p_weight || ' for measure_code : '||p_measure_code);
    debug('entered +');
    g_proc_name := g_proc_name_old;
    exception
	 when no_data_found then
	   p_weight := 0;
	   --write_log('Measure Id:'|| to_char(p_measure_id) || '
			 --   does not exits in bic_measures_all table');

end get_weight;

-- This procedure finds bucket id, bucket points for a given measure id and
-- value.
procedure get_bucket  (p_measure_id           number,
				   p_value                number,
				   p_bucket_id     in out NOCOPY number,
				   p_bucket_points in out NOCOPY number) as
	cursor bucket_cur is
	select bucket_id, bucket_points --into p_bucket_id, p_bucket_points
	  from bic_measure_buckets
      where nvl(p_value,0) >= nvl(low_value,0)
	   and nvl(p_value,0) <  nvl(high_value,p_value+2)
	   and measure_id = p_measure_id
	   order by low_value;
begin
     g_proc_name_old := g_proc_name;
	g_proc_name := 'get_bucket';
	-- nvl of null high value is set to p_value +2 so that
	-- p_value less than high_value condition is true.
	open bucket_cur;
	fetch bucket_cur into p_bucket_id, p_bucket_points;
	if bucket_cur % notfound then
	   p_bucket_id     := null;
	   p_bucket_points := 0;
	end if;
	close bucket_cur;

     g_proc_name := g_proc_name_old;
	exception
	  when no_data_found then
	    -- If no bucket data is found then return bucket points as 0
	    -- and bucket id as null.
	    p_bucket_id := null;
	    p_bucket_points := 0;

end get_bucket;

-- This procedure updates score and bucket id fields of
-- bic_customer_summary_all table. For selected records from
-- bic_customer_summary_all table, it finds the weight of the measure,
-- bucket points and bucket id and updates score as weight*bucket_points.
procedure update_score is
   cursor cust_summary_recs is
	select measure_id, value, org_id
	  from bic_customer_summary_all
      where bucket_id = -1
	   and trunc(period_start_date)
		  between trunc(g_period_start_date) and trunc(g_period_end_date)
	   and (g_org_id is null or g_org_id = org_id)
	   for update of score, bucket_id;
   x_value         bic_customer_summary_all.value      % type;
   x_org_id        bic_customer_summary_all.org_id     % type;
   x_measure_id    bic_customer_summary_all.measure_id % type;
   x_bucket_points bic_measure_buckets.bucket_points   % type;
   x_bucket_id     bic_measure_buckets.bucket_id       % type;
   x_weight        bic_measures_all.weight             % type;
   x_measure_code  bic_measures_all.measure_code       % type;
begin
   g_proc_name_old := g_proc_name;
   g_proc_name := 'Update_score';

   open cust_summary_recs;
   loop
	 fetch cust_summary_recs into x_measure_id, x_value, x_org_id;
	 if cust_summary_recs % notfound then exit; end if;
      get_weight(x_measure_id,x_weight,x_measure_code);
      get_bucket(x_measure_id,x_value,x_bucket_id,x_bucket_points);
	 --write_log('Weight:'||to_char(x_weight) ||
      --          ' Bucket Point:'||to_char(x_bucket_points));
	 update bic_customer_summary_all
	    set bucket_id = x_bucket_id,
		   measure_code = x_measure_code,
		   score     = nvl(x_weight * x_bucket_points,0)
       where current of cust_summary_recs;
   end loop;

   g_proc_name := g_proc_name_old;

end update_score;

-- This procedure gets neasure_id,  score, bucket id for a given measure_code
-- and inserts into bic_customer_summary_all table.
procedure insert_record(p_measure_code varchar2,
				    p_period_start_date date,
				    p_customer_id  number,
				    p_value        number,
				    p_org_id       number,
				    p_index        varchar2 default null) as
    x_measure_id    bic_measures_all.measure_id        % type;
    x_bucket_id     bic_customer_summary_all.bucket_id % type;
    x_weight        bic_measures_all.weight            % type;
    x_bucket_points bic_measure_buckets.bucket_points  % type;
    x_score         bic_customer_summary_all.score     % type;
    x_dummy         bic_measures_all.measure_code      % type;
begin
    -- do not insert ant record if value is null.
/*    if p_value is null or p_value = 0 then return; end if;*/
if p_value is null then return; end if;

    g_proc_name_old := g_proc_name;
    g_proc_name := 'insert_record';
     debug(' entered +');
    g_dup_record_error := null;
    get_measure_id(p_measure_code,p_org_id, x_measure_id);
    if p_index is null or p_index <> 'MIX' then
       get_weight(x_measure_id,x_weight,x_dummy);
	  -- If weight = 0 then it's score will be zero and it will
	  -- have no impact on parent measures' value. So do not insert
	  -- such records.
	  if x_weight = 0 then return; end if;
    end if;
    if p_index is null then
       get_bucket(x_measure_id,p_value,x_bucket_id,x_bucket_points);
    end if;
    if p_index is null then
       x_score := x_bucket_points * x_weight;
    elsif p_index = 'SIX' then
	  x_score := p_value * x_weight;
    else
	  x_score := null;
    end if;
    insert into bic_customer_summary_all (
			 MEASURE_ID             ,
                PERIOD_START_DATE      ,
                CUSTOMER_ID            ,
                BUCKET_ID              ,
                VALUE                  ,
                LAST_UPDATE_DATE       ,
                LAST_UPDATED_BY        ,
                CREATION_DATE          ,
                CREATED_BY             ,
                ORG_ID                 ,
                LAST_UPDATE_LOGIN      ,
                REQUEST_ID             ,
                PROGRAM_APPLICATION_ID ,
                PROGRAM_ID             ,
                PROGRAM_UPDATE_DATE    ,
                SCORE                  ,
			 MEASURE_CODE           )
       values ( x_measure_id                , --MEASURE_ID
                p_period_start_date         , --PERIOD_START_DATE
                p_customer_id               , --CUSTOMER_ID
                x_bucket_id                 , --BUCKET_ID
                p_value                     , --VALUE
                sysdate                     ,
                g_last_updated_by           ,
                sysdate                     ,
                g_created_by                ,
			 p_org_id                    , -- ORG_ID
                g_last_update_login         ,
                g_request_id                ,
                g_program_application_id    ,
                g_program_id                ,
                sysdate                     ,
                x_score                     , -- SCORE
			 p_measure_code
		     );
      debug(' exited +');
    g_proc_name := g_proc_name_old;
    exception
	 when dup_val_on_index then
	   g_dup_record_error := 'Yes';
	   write_log('Duplicate records in bic_customer_summary_all:'
                  ||sqlerrm);
	/* when others then
      write_log('exception occurred for this measure_id : '||x_measure_id); */
end insert_record;

-- This procedure executes SQL statement
procedure run_sql    (p_sttmnt       varchar2) is
    x_insert_str varchar2(2000);
    x_bucket_id  bic_customer_summary_all.bucket_id % type;
    x_score      bic_customer_summary_all.score     % type;
    x_from_pos   number;
    x_where_end  number;
    x_extra_cond varchar2(500);

    type t_cursor is REF CURSOR;
    x_cur  t_cursor;
    x_sql_sttmnt  varchar2(32000);
    x_measure_id        bic_customer_summary_all.measure_id        % type;
    x_customer_id       bic_customer_summary_all.customer_id       % type;
    x_period_start_date bic_customer_summary_all.period_start_date % type;
    x_value             bic_customer_summary_all.value             % type;
    x_org_id            bic_customer_summary_all.org_id            % type;
    x_bucket_points     bic_measure_buckets.bucket_points          % type;
    x_weight            bic_measures_all.weight                    % type;
    x_measure_code      bic_measures_all.measure_code              % type;

    x_num               number;
begin

	x_num := 0;
     g_proc_name_old := g_proc_name;
     g_proc_name := 'run_sql';
  --   write_log('sql statement :'||p_sttmnt);
     if p_sttmnt is null then
	   write_log('Null or disabled SQL statement........');
	   return;
	end if;
    --write_log('  procedure '||g_proc_name || ' entered at : '||sysdate);
    debug(g_proc_name || ' entered at + ');

	-- Location of FROM in SQL statement is needed so that some other fields
	-- such as login_id, update_date etc can be inserted into SQL statement
	x_from_pos  := instr(upper(p_sttmnt),'FROM' );

	-- Location of end of WHERE word in SQL statement is needed so that extra
	-- condition can be inserted into SQL statement. The extra condition may
	-- be needed if org_id is not null.
	x_where_end := instr(upper(p_sttmnt),'WHERE') + 6;

	x_score     := 0;
	--Bucket id is set to -1 so that all bic_customery_summary_all records can
     --be selected easily for update of scores and bucket ids in update_score
     --procedure.
	x_bucket_id := -1;

        x_extra_cond := 'exists (select 1 from bic_temp_periods btp where btp.start_date = bdt.start_date) and';

        if g_delete_flag = 'N' then

        x_extra_cond := 'exists (select 1 from bic_temp_periods btp where btp.start_date = bdt.start_date and btp.org_id = bma.org_id) and ';
        end if;

	if g_org_id is not null then
        x_extra_cond := x_extra_cond || ':p_org_id = bma.org_id and ';
	else
	   x_extra_cond:= x_extra_cond || ' ' ;
      -- write_log('extra condition : '||x_extra_cond);
	end if;
    x_insert_str := substr(p_sttmnt,1,x_where_end -1) ||
				x_extra_cond ||
                    substr(p_sttmnt,x_where_end)
				;
    debug('sql query : '|| x_insert_str);
     if g_org_id is null then
	   open x_cur for x_insert_str using g_period_start_date,
								  g_period_end_date;

     else
	   open x_cur for x_insert_str using g_org_id,
								  g_period_start_date,
								  g_period_end_date;

	end if;
--    write_log('cursor opened in run_sql');
	loop
	   fetch x_cur into x_measure_id, x_customer_id, x_period_start_date,
			  				    x_org_id, x_value;

        if x_cur%notfound then
		 exit;
	   end if;
     debug('calling get_weight for measure_id : '||x_measure_id);
   --     write_log('calling get_weight for measure_id : '||x_measure_id);
      get_weight(x_measure_id,x_weight,x_measure_code);
    debug('got weight for measure id : '||x_measure_id);
      debug('got weight for measure id : '|| x_measure_id);
--	   if nvl(x_value,0) <> 0 and x_weight <> 0 then
/* calculate measure even if the weight is zero as only the direct sub measures of a measure are shown in the setup
Ex: in the setup page of BILLING only the measure 'ON_TIME_PAYMENT_RATE' is shown*/
       	   if nvl(x_value,0) <> 0 then
       debug('calling get_bucket for measure_id : '||x_measure_id);
          get_bucket(x_measure_id,x_value,x_bucket_id,x_bucket_points);
       /*    write_log('got bucket for measure id : '||x_measure_id);
           write_log('x_measure_id :'||x_measure_id);
           write_log('x_customer_id :'||x_customer_id);
           write_log('x_period_start_date :'||x_period_start_date);
           write_log('x_org_id :'||x_org_id);
           write_log('x_value :'||x_value);
           write_log('g_last_updated_by :'||g_last_updated_by);
           write_log('x_bucket_points : '||x_bucket_points);
           write_log('g_created_by : '||g_created_by);*/

           insert into bic_customer_summary_all (
               MEASURE_ID
              ,CUSTOMER_ID
              ,PERIOD_START_DATE
              ,ORG_ID
              ,VALUE
              ,BUCKET_ID
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_LOGIN
              ,REQUEST_ID
              ,PROGRAM_APPLICATION_ID
              ,PROGRAM_ID
              ,PROGRAM_UPDATE_DATE
             ,SCORE
		    ,MEASURE_CODE)
            values (
		    x_measure_id
		    ,x_customer_id
		    ,x_period_start_date
		    ,x_org_id
		    ,x_value
		    ,x_bucket_id
              ,sysdate
              ,g_last_updated_by
              ,sysdate
              ,g_created_by
              ,g_last_update_login
              ,g_request_id
              ,g_program_application_id
              ,g_program_id
              ,sysdate
              ,x_bucket_points*x_weight
		    ,x_measure_code)
              ;

        end if;

	end loop;
--	write_log('No of Records Inserted='||to_char(x_num));
--write_log (sysdate);
     debug('exited - ');
     g_proc_name := g_proc_name_old;
     exception
     when dup_val_on_index then
	   debug('duplicate record entered');

end run_sql;

-- This procedure finds out NOCOPY if summary records are already created for a
-- given period and measure code.

-- This procedure insert record into bic_customer_summary_all for measure_codes
-- of type 'formula'
procedure run_fml (p_measure_code  varchar2,
			    p_mult_factor   number  ) is
	cursor cust_and_dates is
	   select distinct period_start_date, customer_id, bma.org_id
		from bic_customer_summary_all bcs,
			bic_measure_hierarchy    bmh,
			bic_measures_all         bma
         where bcs.measure_id          = bma.measure_id
		 and bmh.measure_code        = bma.measure_code
		 and bmh.parent_measure_code = p_measure_code
	      and trunc(bcs.period_start_date)
	  between trunc(g_period_start_date) and trunc(g_period_end_date)
		 and (g_org_id is null or g_org_id = bma.org_id);

	x_value             bic_customer_summary_all.value       % type;
	x_value1            bic_customer_summary_all.value       % type;
	x_value2            bic_customer_summary_all.value       % type;
	x_measure_id1       bic_measures_all.measure_id          % type;
	x_measure_id2       bic_measures_all.measure_id          % type;
	x_measure_code1     bic_measures_all.measure_code        % type;
	x_measure_code2     bic_measures_all.measure_code        % type;
	x_operation_code1   bic_measure_hierarchy.operation_code % type;
	x_operation_code2   bic_measure_hierarchy.operation_code % type;
	x_customer_id       bic_customer_summary_all.customer_id % type;
	x_org_id            bic_measures_all.org_id              % type;
	x_period_start_date date;

	cursor childs_cur (cp_parent_measure_code varchar2) is
	select measure_code, operation_code
	  from bic_measure_hierarchy
	 where parent_measure_code = cp_parent_measure_code
	 order by sequence_number     ;
begin
     g_proc_name_old := g_proc_name;
     g_proc_name := 'run_fml';
     --write_log('  procedure '||g_proc_name || ' entered at : '||sysdate);
     debug(' entered + ');

	open childs_cur(p_measure_code);
     -- Get first child
	fetch childs_cur into x_measure_code1, x_operation_code1;
	if childs_cur % notfound then
	   bic_summary_extract_pkg.write_log('First child of '|| p_measure_code || ' Not found...');
        close childs_cur;
	   return;
     end if;
     -- Get second child
	fetch childs_cur into x_measure_code2, x_operation_code2;
	if childs_cur % notfound then
	   bic_summary_extract_pkg.write_log('Second child of '|| p_measure_code || ' Not found...');
        close childs_cur;
	   return;
     end if;
     close childs_cur;

	open cust_and_dates;
	loop
	   fetch cust_and_dates into x_period_start_date, x_customer_id,
						    x_org_id;
        if cust_and_dates%notfound then
		 exit;
	   end if;

	   get_measure_id(x_measure_code1,
				   x_org_id,
				   x_measure_id1);
	   get_measure_id(x_measure_code2,
				   x_org_id,
				   x_measure_id2);
	   get_measure_value (x_period_start_date,
			            x_customer_id,
			            x_measure_id1,
			            x_value1);
	   get_measure_value (x_period_start_date,
			            x_customer_id,
			            x_measure_id2,
			            x_value2);
	   if x_value2 = 0 then
		 bic_summary_extract_pkg.write_log('Value of second measure is 0:');
	   elsif x_operation_code1 = '/' then
		 x_value := x_value1*p_mult_factor/x_value2;
	   else
		 bic_summary_extract_pkg.write_log('No procedure to handle operation_code:'||
                     x_operation_code1);
   	   end if;
        insert_record(p_measure_code      ,
			 	  x_period_start_date ,
				  x_customer_id       ,
				  x_value             ,
				  x_org_id            ,
				  null               );
--commented as the exception is caught in insert_record
/*	   if g_dup_record_error is not null then
		 rollback;
		 exit;
        end if;*/
	end loop;
	bic_summary_extract_pkg.write_log('No of Recrods Inserted='||to_char(cust_and_dates%rowcount));
	close cust_and_dates;
    --write_log('  procedure '||g_proc_name || ' exited at : '||sysdate);
     debug(' exited  -');

    g_proc_name := g_proc_name_old;


end run_fml;

-- This procedure inserts records into bic_customer_summary_all for measure
-- codes which are of type 'Formula with dates'. for example measure code
-- Average Service Requests Per Day is calculated as SRS logged divided by
-- days in a given period
procedure run_fmd (p_measure_code  varchar2) is
	cursor cust_and_dates is
	   select period_start_date, customer_id, bma.org_id,
			bcs.measure_id, bcs.value, bmh.operation_code
		from bic_customer_summary_all bcs,
			bic_measure_hierarchy    bmh,
			bic_measures_all         bma
         where bcs.measure_id          = bma.measure_id
		 and trunc(bcs.period_start_date)
	  between trunc(g_period_start_date) and trunc(g_period_end_date)
		 and bmh.measure_code        = bma.measure_code
		 and bmh.parent_measure_code = p_measure_code
		 and (g_org_id is null or g_org_id = bma.org_id);
	x_value             bic_customer_summary_all.value       % type;
	x_value1            bic_customer_summary_all.value       % type;
	x_value2            bic_customer_summary_all.value       % type;
	x_measure_id1       bic_measures_all.measure_id          % type;
	x_measure_id2       bic_measures_all.measure_id          % type;
	x_measure_code1     bic_measures_all.measure_code        % type;
	x_measure_code2     bic_measures_all.measure_code        % type;
	x_operation_code1   bic_measure_hierarchy.operation_code % type;
	x_operation_code2   bic_measure_hierarchy.operation_code % type;
	x_period_start_date date;
	x_customer_id       bic_customer_summary_all.customer_id % type;
	x_org_id            bic_measures_all.org_id              % type;
	x_days              number;

begin
     g_proc_name_old := g_proc_name;
	g_proc_name := 'run_fmd';
    --write_log('  procedure '||g_proc_name || ' entered at : '||sysdate);
     debug(' entered + ');

	open cust_and_dates;
	loop
	   fetch cust_and_dates into x_period_start_date, x_customer_id,
						    x_org_id, x_measure_id1, x_value1,
						    x_operation_code1;
        if cust_and_dates%notfound then
		 exit;
	   end if;

        -- 1 is added in following query so that 1/31/99 - 1/1/99 gives 31
	   -- not 30
        select act_period_end_date - act_period_start_date +1 into x_days
	     from bic_temp_periods
	    where trunc(start_date) = trunc(x_period_start_date)
        and nvl(org_id,x_org_id) = x_org_id;

	   x_value := x_value1/x_days;
        insert_record(p_measure_code      ,
	 		 	  x_period_start_date ,
				  x_customer_id       ,
				  x_value             ,
				  x_org_id            ) ;
--commented as the exception is caught in insert_record
/*	   if g_dup_record_error is not null then
		 rollback;
		 exit;
        end if;*/
	end loop;
	bic_summary_extract_pkg.write_log('No of Recrods Inserted='||to_char(cust_and_dates%rowcount));
	close cust_and_dates;
    --write_log('  procedure '||g_proc_name || ' entered at : '||sysdate);
     bic_summary_extract_pkg.debug('exited - ');

     g_proc_name := g_proc_name_old;

end run_fmd;

-- This procedure insert records into bic_customer_summary_all for measure
-- codes which are sub indexes or main index
procedure run_index (p_measure_code  varchar2,
				 p_index         varchar2) is
	cursor index_recs is
	select bcs.customer_id, bcs.org_id, bcs.period_start_date,
		  sum(nvl(bcs.score,0)), sum(nvl(bma.weight,0)),count(1)
	  from bic_measure_hierarchy  bmh,
		  bic_measures_all       bma,
		  bic_customer_summary_all bcs
      where bmh.parent_measure_code = p_measure_code
	   and bmh.measure_code        = bma.measure_code
	   and (bma.org_id = g_org_id or g_org_id is null)
	   and bma.measure_id = bcs.measure_id
	   and trunc(bcs.period_start_date)
    between trunc(g_period_start_date) and trunc(g_period_end_date)
      group by bcs.customer_id, bcs.org_id,bcs.period_start_date;

	x_period_start_date   bic_customer_summary_all.period_start_date % type;
	x_customer_id         bic_customer_summary_all.customer_id       % type;
	x_total_weight        bic_measures_all.weight                    % type;
	x_total_score         bic_customer_summary_all.score             % type;
	x_value               bic_customer_summary_all.value             % type;
	x_org_id              bic_customer_summary_all.org_id            % type;
	x_cnt number;
	x_msr_cd  varchar2(50);
begin
     g_proc_name_old := g_proc_name;
	g_proc_name := 'run_index';
 --write_log('  procedure '||g_proc_name || ' entered at : '||sysdate);
     bic_summary_extract_pkg.debug(' entered + ');

	open index_recs;
	loop
	   fetch index_recs into x_customer_id, x_org_id, x_period_start_date,
						x_total_score, x_total_weight, x_cnt;
        if index_recs % notfound then exit; end if;
	   if x_total_weight <> 0 then
		 x_value := x_total_score/ x_total_weight;
		 --There is no need to insert record with value=0 as it will
		 -- not contribute to main index. main index is sub index value times
		 -- weight and main index with 0 value is of no use.
	      insert_record(p_measure_code,
				     x_period_start_date,
				     x_customer_id,
                         x_value,
				     x_org_id,
				     p_index);
	   --else
		 --x_value := 0;
        end if;
--commented as the exception is caught in insert_record
/*	   if g_dup_record_error is not null then
		 rollback;
		 exit;
        end if;*/
	end loop;
	bic_summary_extract_pkg.write_log('No of Recrods Inserted='||to_char(index_recs%rowcount));
	close index_recs;
     g_proc_name := g_proc_name_old;
     --write_log('  procedure '||g_proc_name || ' exited at : '||sysdate);
     bic_summary_extract_pkg.debug(g_proc_name || ' exited at : '|| sysdate);

-- if any exception occurs entire satisfaction should not be calculated
/*     exception
     when others then
       write_log('exception occurred for this customer_id : '||x_customer_id); */
end run_index;

-- This procedure returns SQL statement, operation type and multiplication
-- factor associated with a measure code.
procedure get_sql_sttmnt(p_measure_code          varchar2,
					p_sttmnt         in out NOCOPY varchar2,
					p_operation_type in out NOCOPY varchar2,
					p_mult_factor    in out NOCOPY number) as
begin
     g_proc_name_old := g_proc_name;
	g_proc_name := 'Get_SQL_Sttmnt';
    debug('entered +');
     select sql_statement, operation_type, nvl(mult_factor,1)
	  into p_sttmnt, p_operation_type, p_mult_factor
       from bic_measure_attribs
      where measure_code = p_measure_code
      	   and nvl(disable_flag,'N') <> 'Y';
          debug('exited +');
     g_proc_name := g_proc_name_old;
	exception
	  when no_data_found then
		bic_summary_extract_pkg.write_log(' Measure Code:'|| p_measure_code || 'might be disabled or there is no entry in Bic_measure_attribs for');
        g_proc_name := g_proc_name_old;
end;
-- This procedure extracts data for SATISFACTION and/or LOYALTY measure codes
procedure extract_proc(p_measure_code varchar2) is


  x_measure_code   bic_measures_all.measure_code      % type;
  x_mult_factor    bic_measure_attribs.mult_factor    % type;
  x_operation_type bic_measure_attribs.operation_type % type;
  x_level          number(5);
  x_sttmnt         varchar2(2000);


  -- Purpose of this query is get measure code which are at lowest level first.
  -- At lowest level, you will always have measure codes with SQL statements.
  -- In this way when a measure cd calculation is done using other measure code
  -- those measure codes are already calculated.
  -- cursor gives measures in the order of their level. Highest level first..

  cursor measure_cur is
  select measure_code, max(level)
    from bic_measure_hierarchy
    where measure_code not in ('REFERALS','INTERAC_CUML')
   start with parent_measure_code = p_measure_code
   connect by prior measure_code  = parent_measure_code
   group by measure_code
   order by 2 desc, 1;
begin
  g_proc_name_old := g_proc_name;
  g_proc_name     := 'Extract_Proc';

  g_srl_no    := 0;


  open measure_cur;
  loop

	g_srl_no    := g_srl_no + 1;
     g_proc_name := 'extract_proc';
       debug('entered +');
	fetch measure_cur into x_measure_code, x_level;
	if measure_cur % notfound then
        exit;
     end if;
       x_operation_type := null;

     get_sql_sttmnt(x_measure_code, x_sttmnt, x_operation_type, x_mult_factor);

     debug('Measure Code being processed:'||x_measure_code ||':'||
                x_operation_type);
     -- Operation Types:
     --   SQL: It means value of measure code is calculated using a SQL
     --        statement
     --   FML: It means value of measure code is calculated using a formula
     --        involving two other measures and it is caluclated as
     --        measure code1 operator measure code2 * multiplication factor
     --        multiplication factor is 100 in case of percentages
     --   FMD: It means the value of a measure is calculated using another
     --        measure and no of days in a certain period. It is calculated as
     --        measure code1 / no of days in a period
     if x_operation_type = 'SQL' then
	   --if x_sttmnt is null then
		 -- Because all measures of SQL type are already processed using
		 -- process_sql_type_measures. The procedure below just report
		 -- the errors. If there are not errors, then part can be removed.
	      run_sql(x_sttmnt);
	   --end if;
	elsif x_operation_type = 'FML' then
	   run_fml(x_measure_code,
                x_mult_factor);
     elsif x_operation_type = 'FMD' then
	   run_fmd(x_measure_code);
	elsif x_operation_type = 'SIX' or x_operation_type = 'MIX' then
	  run_index(x_measure_code, x_operation_type);
	else
	  -- Fix made for Bug 2397179 ByteMobile/IKON issue
	  -- This is only a temporary solution. Long term we should
	  -- define a SQL for the three sub-measures
	  -- SR_CLOSED_INT, FIRST_CALL_CL_RATE, NO_OF_COMPLAINTS

	  If x_measure_code NOT IN
	     ('SR_CLOSED_INT','FIRST_CALL_CL_RATE','NO_OF_COMPLAINTS') Then

	     write_log('Invalid Operation Type:'|| x_operation_type ||
                 ':Valid Operation Types are SQL, FML, FMD, SIX, MIX');
       End If;

     end if;
	-- commit;
  end loop;
  close measure_cur;

  debug('Measure code Being Processed:'||p_measure_code);

	  run_index(p_measure_code, 'MIX');

  write_log('Processing of Measures Completed....');
  debug('exited -');
  g_proc_name := g_proc_name_old;

end extract_proc;

procedure extract_satisfaction is
rec_count number;
begin
   g_proc_name_old := g_proc_name;
   g_proc_name := 'Extract_satisfaction_data';
     write_log('Before satisfaction Extraction...');

         extract_periods(	g_period_start_date,
				g_period_end_date	,
				'SATISFACTION',
				'Y',
                        g_delete_flag,
				g_org_id);

        write_log('Extracted Periods Successfully In Extract_satisfaction...');

 select count(*) into rec_count
     from	 bic_temp_periods;

     if rec_count = 0 then
        write_log('data already exists');
     	return;
  end if;

        extract_proc('SATISFACTION');


	bic_consolidate_cust_data_pkg.populate_party_data (g_period_start_date,g_period_end_date);
      bic_consolidate_cust_data_pkg.purge_customer_summary_data;


            Commit;

   write_log('Total Records Added for satisfaction:'|| to_char(sql%rowcount));
   g_proc_name := 'Extract_Main';

    Exception
        when others then
        write_log('Satisfaction data is not extracted due to : '||sqlerrm);
        generate_error(g_measure_code,'Satisfaction data is not extracted due to : '||sqlerrm);
              Rollback;
end;

procedure extract_Loyalty is
rec_count number;
begin
   g_proc_name_old := g_proc_name;
   g_proc_name := 'Extract_Loyalty_data';

        extract_periods(	g_period_start_date,
				g_period_end_date	,
				'LOYALTY',
				'Y',
                g_delete_flag,
				g_org_id);

   write_log('Extracted Periods Successfully In Extract_Loyalty...');

 select count(*) into rec_count
     from	 bic_temp_periods;

     if rec_count = 0 then
        write_log('Data already extracted');
     	return;
  end if;
        extract_proc('LOYALTY');


	bic_consolidate_cust_data_pkg.populate_party_data (g_period_start_date,g_period_end_date);

   bic_consolidate_cust_data_pkg.purge_customer_summary_data;


            Commit;
     write_log('Loyalty extraction completed');
--   write_log('Total Records Added for Loyalty:'|| to_char(sql%rowcount));
   g_proc_name := 'Extract_Main';

    Exception
        when others then
  write_log('Loyalty data is not extracted due to : '||sqlerrm);
        generate_error(g_measure_code,'Loyalty data is not extracted due to : '||sqlerrm);

              Rollback;
end;

-- for customer retention records, 'VALUE' column of bic_customer_summary_all
-- table stores customer retention status. The mapping between value of
-- 'VALUE' column and status is given in SRS documnet but are reporduced here
-- too for the convenience of reading.
-- value = 1 means New
-- value = 2 means Reactivated
-- value = 3 means Retained
-- value = 4 means Churned
---------------------------------

procedure retention_churned is
  cursor party_cur is
    select party_id, min(nvl(account_established_date,creation_date))
	 from hz_cust_accounts
	group by party_id;
  x_party_id                 hz_cust_accounts.party_id                 % type;
  x_account_established_date hz_cust_accounts.account_established_date % type;
begin
  g_proc_name_old := g_proc_name;
  g_proc_name := 'Retention_churned';
 debug(' entered +');
  --g_tot_recs_added := 0;
  insert into bic_party_summary (
       MEASURE_ID
      ,PARTY_ID --CUSTOMER_ID
      ,PERIOD_START_DATE
      ,VALUE
      ,BUCKET_ID
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,REQUEST_ID
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_ID
      ,PROGRAM_UPDATE_DATE
      ,SCORE
	 ,measure_code)
  select distinct
	  g_measure_id_for_retn
      ,party_id --hca.cust_account_id
      ,add_months(period_start_date,g_attrition_period*1)
      ,4
      ,null
      ,sysdate
      ,g_last_updated_by
      ,sysdate
      ,g_created_by
      ,g_last_update_login
      ,g_request_id
      ,g_program_application_id
      ,g_program_id
      ,sysdate
      ,null
	 ,'RETENTION'
  from bic_party_summary psum
 where psum.period_start_date
		      between add_months(g_period_start_date,g_attrition_period*-1)
			     and add_months(g_period_end_date,g_attrition_period*-1)

   and measure_id = g_measure_id_for_retn
   and not exists ( select 1 from bic_party_summary psum_in
				where psum_in.measure_id = g_measure_id_for_retn
				  and psum_in.party_id   = psum.party_id
				  and psum_in.period_start_date =
					 add_months(psum.period_start_date,g_attrition_period)
                  );


  g_tot_recs_added := g_tot_recs_added + sql%rowcount;
   debug(' exited - ');
   write_log('Total Records Added for Retention Churned:'||to_char(g_tot_recs_added));
   g_proc_name := g_proc_name_old;

end retention_churned;

procedure retention_retained is
  cursor party_cur is
    select party_id, min(nvl(account_established_date,creation_date))
	 from hz_cust_accounts
	group by party_id;
  x_party_id                 hz_cust_accounts.party_id                 % type;
  x_account_established_date hz_cust_accounts.account_established_date % type;
begin
  g_proc_name_old := g_proc_name;
  g_proc_name := 'retention_retained';

 -- g_tot_recs_added := 0;
 --write_log('  procedure '||g_proc_name || ' entered at : '||sysdate);
     bic_summary_extract_pkg.debug(' entered + ');

  open party_cur;
  loop
    fetch party_cur into x_party_id, x_account_established_date;
    if party_cur % notfound then
	  exit;
    end if;
  insert into bic_party_summary (
       MEASURE_ID
      ,PARTY_ID
      ,PERIOD_START_DATE
      ,VALUE
      ,BUCKET_ID
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,REQUEST_ID
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_ID
      ,PROGRAM_UPDATE_DATE
      ,SCORE
	 ,measure_code)
select g_measure_id_for_retn
      ,x_party_id --hca.cust_account_id
      ,bdt.act_period_start_date
      ,3
      ,null
      ,sysdate
      ,g_last_updated_by
      ,sysdate
      ,g_created_by
      ,g_last_update_login
      ,g_request_id
      ,g_program_application_id
      ,g_program_id
      ,sysdate
      ,null
	 ,'RETENTION'
  from bic_temp_periods          bdt
  where   trunc(bdt.start_date)
   --Ex: if the start date is 1-mar-2003 and the attrition period is 2 months then calculate retention retained from
   --1-jan-2003 inorder to calculate retention_churned
  between trunc(add_months(g_period_start_date,g_attrition_period*-1)) and trunc(g_period_end_date)
   and x_account_established_date
		  <= add_months(bdt.act_period_end_date, g_attrition_period*-1)
   and exists (select 'x' from oe_order_headers_all oeh,
						 hz_cust_accounts     hca
			 where oeh.sold_to_org_id = hca.cust_account_id
			   and hca.party_id       = x_party_id
			   and ordered_date between add_months(bdt.act_period_end_date,
										    g_attrition_period*-1)+1
				  			    and bdt.act_period_end_date
              )
   and (exists
		    (select 'x' from oe_order_headers_all oeh,
						 hz_cust_accounts     hca
			 where oeh.sold_to_org_id = hca.cust_account_id
			   and hca.party_id       = x_party_id
			   and ordered_date between add_months(bdt.act_period_end_date,
								              g_attrition_period*-2)+1
							    and add_months(bdt.act_period_end_date,
										    g_attrition_period*-1)
		    )
           or x_account_established_date
				between add_months(bdt.act_period_end_date,
					       	    g_attrition_period * -2) +1
			         and add_months(bdt.act_period_end_date,
						         g_attrition_period * -1)
       )
;
      g_tot_recs_added := g_tot_recs_added + sql%rowcount;
  end loop;
  close party_cur;
   write_log('Total Records Added for Retention Retained:'||
									    to_char(g_tot_recs_added));
--write_log('  procedure '||g_proc_name || ' exited at : '||sysdate);
     bic_summary_extract_pkg.debug(' exited - ');

   g_proc_name := g_proc_name_old;

end retention_retained;

-- This procedure inserts reactivated customers
procedure retention_reactivated is
  cursor party_cur is
    select party_id, min(nvl(account_established_date,creation_date))
	 from hz_cust_accounts
	group by party_id;
  x_party_id                 hz_cust_accounts.party_id                 % type;
  x_account_established_date hz_cust_accounts.account_established_date % type;
begin
  g_proc_name_old := g_proc_name;
  g_proc_name := 'retention_reactivated';
  write_log('retention_reactivated entered');
  --write_log('  procedure '||g_proc_name || ' entered at : '||sysdate);
     bic_summary_extract_pkg.debug(' entered +');

 -- g_tot_recs_added := 0;
  open party_cur;
  loop
    fetch party_cur into x_party_id, x_account_established_date;
    if party_cur % notfound then
	  exit;
    end if;
  --  raise no_data_found;
    insert into bic_party_summary (
       MEASURE_ID
      ,PARTY_ID
      ,PERIOD_START_DATE
      ,VALUE
      ,BUCKET_ID
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,REQUEST_ID
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_ID
      ,PROGRAM_UPDATE_DATE
      ,SCORE
	 ,measure_code)
    select g_measure_id_for_retn
      ,x_party_id
      ,bdt.act_period_start_date
      ,2
      ,null
      ,sysdate
      ,g_last_updated_by
      ,sysdate
      ,g_created_by
      ,g_last_update_login
      ,g_request_id
      ,g_program_application_id
      ,g_program_id
      ,sysdate
      ,null
	 ,'RETENTION'
  from bic_temp_periods          bdt
 where trunc(bdt.start_date)
  --Ex: if the start date is 1-mar-2003 and the attrition period is 2 months then
  --calculate retention reactivated from
   --1-jan-2003 inorder to calculate retention_churned
	  between trunc(add_months(g_period_start_date,g_attrition_period*-1))and trunc(g_period_end_date)
   and x_account_established_date
		    <=add_months(bdt.act_period_end_date, g_attrition_period*-2)
   -- above line means acquired before previous attrition period
   -- <= sign is used because you want to account_established date between
   --  1-apr-99 and 30-jun-99 and not between 31-mar-99 and 30-jun-99.
   -- 30-jun-99 minus 3 months will return 31-mar-99
   --
   -- for same reasons 1 is added while comparing ordered_date
   and exists (select 'x' from oe_order_headers_all oeh,
						 hz_cust_accounts     hca
			 where oeh.sold_to_org_id = hca.cust_account_id
			   and hca.party_id       = x_party_id
			   and ordered_date between add_months(bdt.act_period_end_date,
										    g_attrition_period*-1)+1
				  			    and bdt.act_period_end_date
              )
   and not exists
		    (select 'x' from oe_order_headers_all oeh,
						 hz_cust_accounts     hca
			 where oeh.sold_to_org_id = hca.cust_account_id
			   and hca.party_id       = x_party_id
			   and ordered_date between add_months(bdt.act_period_end_date,
								              g_attrition_period*-2)+1
							    and add_months(bdt.act_period_end_date,
										    g_attrition_period*-1)
		    )
;
      g_tot_recs_added := g_tot_recs_added + sql%rowcount;
  end loop;
  close party_cur;
--   write_log('Total Records Added for Retention Reactivated:'||to_char(g_tot_recs_added));
--write_log('  procedure '||g_proc_name || ' exited at : '||sysdate);
     bic_summary_extract_pkg.debug( ' exited - ');

   g_proc_name := g_proc_name_old;

end retention_reactivated;

-- This procedure inserts New customers for Retention measure code
procedure retention_new is
  cursor party_cur is
    select party_id, min(nvl(account_established_date,creation_date))
	 from hz_cust_accounts
	group by party_id
    having min(nvl(account_established_date,creation_date)) >=
		  add_months(g_period_start_date,g_attrition_period*-1+1)
   -- 1 month is added so that you can compare with
   -- first period end date. Ex: g_period_start_date=1-aug-98, attrition
   -- period = 3 month and above expression will return you 1-jun-98.
   -- You want to know who was NEW on 31-aug-98
		;
  x_party_id                 hz_cust_accounts.party_id                 % type;
  x_account_established_date hz_cust_accounts.account_established_date % type;
begin
  g_proc_name_old := g_proc_name;
  g_proc_name := 'Retention_new';
   debug(' entered +');
  g_tot_recs_added := 0;
  write_log('retention_new entered');
  --write_log('  procedure '||g_proc_name || ' entered at : '||sysdate);
     bic_summary_extract_pkg.debug(g_proc_name || ' entered at : '|| sysdate);

  open party_cur;
  loop
    fetch party_cur into x_party_id, x_account_established_date;
    if party_cur % notfound then
	  exit;
    end if;

  insert into bic_party_summary (
       MEASURE_ID
      ,PARTY_ID
      ,PERIOD_START_DATE
      ,VALUE
      ,BUCKET_ID
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,REQUEST_ID
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_ID
      ,PROGRAM_UPDATE_DATE
      ,SCORE
	 ,measure_code)
  select
	  g_measure_id_for_retn
      ,x_party_id
      ,bdt.act_period_start_date
      ,1
      ,null
      ,sysdate
      ,g_last_updated_by
      ,sysdate
      ,g_created_by
      ,g_last_update_login
      ,g_request_id
      ,g_program_application_id
      ,g_program_id
      ,sysdate
      ,null
	 ,'RETENTION'
  from bic_temp_periods   bdt
 where trunc(bdt.start_date)
   --Ex: if the start date is 1-mar-2003 and the attrition period is 2 months
   --then calculate retention new from
   --1-jan-2003 inorder to calculate retention_churned
	  between trunc(add_months(g_period_start_date,g_attrition_period*-1))and trunc(g_period_end_date)
   and x_account_established_date
		between add_months(bdt.act_period_end_date,g_attrition_period*-1)+1
		    and bdt.act_period_end_date
;
      g_tot_recs_added := g_tot_recs_added + sql%rowcount;
  end loop;
  close party_cur;
   write_log('retention new extracted');
   write_log('Total Records Added for Retention New:'|| to_char(g_tot_recs_added));
   --write_log('  procedure '||g_proc_name || ' exited at : '||sysdate);
     bic_summary_extract_pkg.debug(' exited - ');

   g_proc_name := g_proc_name_old;

end retention_new;

procedure extract_retention is
  rec_count	   number;
   measure_id_not_found Exception;
   attrition_period_not_found Exception;
begin
   g_proc_name_old := g_proc_name;
   g_proc_name := 'Extract_retention_data';
   g_proc_name := 'Extract_Retention';
   write_log('Before Retention Extraction...');
    --write_log('  procedure '||g_proc_name || ' entered at : '||sysdate);
     bic_summary_extract_pkg.debug(' entered + : ');

   bic_consolidate_cust_data_pkg.purge_party_summary_data;
   g_measure_id_for_retn := get_measure_id('RETENTION');
   if g_measure_id_for_retn = 0 then
   raise measure_id_not_found;
   write_log('Error: Measure_id not found for RETENTION');
   end if;
   if get_attrition_period = false then
   raise  attrition_period_not_found;
   end if;

   if g_delete_flag = 'N' then

        extract_periods(	add_months(g_period_start_date,g_attrition_period*-1),
				g_period_end_date	,
				'RETENTION'	,
				'N',
				g_delete_flag,
				null);
   else
        extract_all_periods(add_months(g_period_start_date,g_attrition_period*-1),
				g_period_end_date);
   end if;

  debug('Extracted Periods Successfully In Extract_Retention...');

    select count(*) into rec_count
     from	 bic_temp_periods;

    if rec_count = 0 then
    write_log('Data already extracted for these periods');
     	return;
  end if;
   debug('calling retention new In Extract_Retention...');

        retention_new        ;
   debug('calling retention reactivated In Extract_Retention...');
        retention_reactivated;
   debug('calling retention retained In Extract_Retention...');
        retention_retained   ;
   debug('calling retention churned In Extract_Retention...');
        retention_churned    ;


	bic_consolidate_cust_data_pkg.populate_status_data (g_period_start_date,g_period_end_date);

  bic_consolidate_cust_data_pkg.purge_party_summary_data;

            Commit;

   write_log('Total Records Added for retention:'||to_char(g_tot_recs_added) );
    --write_log('  procedure '||g_proc_name || ' exited at : '||sysdate);
     bic_summary_extract_pkg.debug(' exited - ');

   g_proc_name := 'Extract_Main';

    Exception
    when measure_id_not_found then
          generate_error(g_measure_code,'Measure_id not found for RETENTION in the table BIC_MEASURES_ALL');
          Rollback;
    when attrition_period_not_found then
          generate_error(g_measure_code,'No records in BIC_PROFILE_VALUES_ALL');
          Rollback;
    when others then
          write_log(' Retention data is not extracted due to exception : '||sqlerrm);
          generate_error(g_measure_code,'Retention data is not extracted : '||sqlerrm);
          Rollback;
end;

procedure extract_sales(p_period_start_date date,p_period_end_date date,p_org_id number,p_lf_flag varchar2 default null)
 is
rec_count number;
lf_flag varchar2(2);
begin
if lf_flag is null then
lf_flag := 'N';
else
lf_flag := p_lf_flag;
end if;
bic_consolidate_cust_data_pkg.purge_customer_summary_data;
   g_proc_name_old := g_proc_name;
   g_proc_name := 'Extract_sales_data';

   bic_summary_extract_pkg.debug(g_proc_name||' entered + ');
   write_log('Before Sales/Revenue Extraction...');

   write_log('Before Extracting Periods In Extract_Sales...');
   write_log('g_delete_flag : ' || g_delete_flag);
   write_log('g_org_id : '||g_org_id);
    if(lf_flag = 'N') then
         extract_periods(	g_period_start_date,
				g_period_end_date	,
				'SALES'	,
				'Y',
                        g_delete_flag,
				g_org_id);
     end if;
   write_log('Extracted Periods Successfully In Extract_Sales...');
    select count(*) into rec_count
     from	 bic_temp_periods;

     if rec_count = 0 then
        write_log('sales data already extracted');
     	return;
  end if;

   insert into bic_customer_summary_all (
	     measure_id,
	     customer_id,
	     period_start_date,
	     org_id,
	     value,
	     last_update_date,
	     creation_date,
	     program_update_date,
	     last_updated_by,
	     created_by,
	     request_id,
	     program_application_id,
	     program_id,
	     last_update_login,
		measure_code)
        select bma.measure_id,
             hca.party_id,
	     bdt.act_period_start_date,
	     bma.org_id,
          sum( bic_summary_extract_pkg.convert_amt( gsb.currency_code, gl.gl_date, gl.acctd_amount) ) ,
	     sysdate,
	     sysdate,
	     sysdate,
	     g_last_updated_by,
	     g_created_by,
	     g_request_id,
	     g_program_application_id,
	     g_program_id,
	     g_last_update_login,
		'SALES'
       from hz_cust_accounts     hca,
          bic_temp_periods    bdt,
          bic_measures_all     bma,
		ra_customer_trx_all  trx,
		ra_customer_trx_lines_all lines,
		ra_cust_trx_line_gl_dist_all gl,
		gl_sets_of_books     gsb
     where nvl(bma.org_id,-99) = nvl(trx.org_id,-99)
	 and trx.bill_to_customer_id = hca.cust_account_id
     and bma.measure_code = 'SALES'
     and gl.gl_date between bdt.act_period_start_date and bdt.act_period_end_date
     and trunc(bdt.start_date)
	     between trunc(p_period_start_date) and trunc(p_period_end_date)
     and bma.org_id = decode(g_delete_flag,'N',bdt.org_id,nvl(p_org_id,bma.org_id))
	 and trx.customer_trx_id        = lines.customer_trx_id
	 and lines.customer_trx_line_id = gl.customer_trx_line_id
	 and account_Set_flag           = 'N'
	 and complete_flag              = 'Y'
	 and account_class              = 'REV'
	 and lines.line_type            = 'LINE'
	 and trx.previous_customer_trx_id IS NULL    -- modified for 2992478
	 and trx.set_of_books_id = gsb.set_of_books_id (+)
     group by bma.measure_id,
               hca.party_id,
               bdt.act_period_start_date,
	           bma.org_id;
write_log('transferring data to summary tables');
   rec_count := 0;
rec_count := sql%rowcount;
  if lf_flag = 'N' then
	bic_consolidate_cust_data_pkg.populate_party_data (g_period_start_date,g_period_end_date);

   bic_consolidate_cust_data_pkg.purge_customer_summary_data;


            Commit;
            end if;
bic_summary_extract_pkg.debug(g_proc_name||' exited - ');
g_proc_name := g_proc_name_old;
   write_log('Total Records Added for Sales:'|| rec_count);
   g_proc_name := 'Extract_Main';

    Exception
        when others then
        write_log('Sales data is not extracted : '||sqlerrm);
        generate_error(g_measure_code,'Sales data is not extracted : '||sqlerrm);
              Rollback;
end;----------------------------------------------------------------------

procedure extract_cogs is
rec_count	   number;
begin
   g_proc_name_old := g_proc_name;
   g_proc_name := 'Extract_cogs_data';
   --g_proc_name := 'Extract_Main';
   write_log('Before Cogs Extraction...');
bic_consolidate_cust_data_pkg.purge_customer_summary_data;
bic_summary_extract_pkg.debug(g_proc_name||' entered + ');
if( fnd_log.test(1,g_proc_name) = false ) then
  write_log('logging not enabled');
  end if;

        extract_periods(	g_period_start_date,
				g_period_end_date,
				'COGS'	,
				'Y',
                        g_delete_flag,
				g_org_id);


        select count(*) into rec_count
     from	 bic_temp_periods;

     if rec_count = 0 then
     write_log('COGS data already extracted');
     	return;
  end if;

   insert into bic_customer_summary_all (
		measure_id,
	     customer_id,
	     period_start_date,
	     org_id,
	     value,
	     last_update_date,
	     creation_date,
	     program_update_date,
	     last_updated_by,
	     created_by,
	     request_id,
	     program_application_id,
	     program_id,
	     last_update_login,
		measure_code)
   select bma.measure_id,
         hca.party_id,
	     bdt.act_period_start_date,
	     bma.org_id,
	     sum(bic_summary_extract_pkg.convert_amt(gsb.currency_code,
										cmt.gl_date,
										cogs_amount)
             ),
	     sysdate,
	     sysdate,
	     sysdate,
	     g_last_updated_by,
	     g_created_by,
	     g_request_id,
	     g_program_application_id,
	     g_program_id,
	     g_last_update_login,
		'COGS'
     from  hz_cust_accounts hca,
          bic_temp_periods        bdt,
          bic_measures_all     bma,
          cst_bis_margin_summary      cmt,
          hr_organization_information hoi,
	  gl_sets_of_books            gsb

      where nvl(bma.org_id,-99) = nvl(cmt.org_id,-99)
      and bma.measure_code = 'COGS'
      and cmt.gl_date between bdt.act_period_start_date and
                                               bdt.act_period_end_date
      and trunc(bdt.start_date)
	     between trunc(g_period_start_date)and trunc(g_period_end_date)
     and bma.org_id = decode(g_delete_flag,'N',bdt.org_id,nvl(g_org_id,bma.org_id))
	 and cmt.legal_entity_id         = hoi.organization_id (+)
	 and hoi.org_information_context  (+)= 'Legal Entity Accounting'
	 and hoi.org_information1        = gsb.set_of_books_id (+)
     and cmt.customer_id = hca.cust_account_id
     and cmt.source = 'COGS' -- added by vsegu
    group by bma.measure_id,
	 hca.party_id,
	 bdt.act_period_start_date,
	 bma.org_id;

   bic_consolidate_cust_data_pkg.populate_party_data (g_period_start_date,g_period_end_date);
   bic_consolidate_cust_data_pkg.purge_customer_summary_data;
   rec_count := sql%rowcount;

            Commit;

   write_log('Total Records Added for COGS:'|| rec_count);
   bic_summary_extract_pkg.debug(g_proc_name||' exited -');
   g_proc_name := 'Extract_Main';

    Exception
        when others then
        write_log('COGS data is not extracted : '||sqlerrm);
        generate_error(g_measure_code,'COGS data is not extracted : '||sqlerrm);
              Rollback;
end;

-- VSEGU CODE CHANGES END HERE


procedure extract_acquisition_data
is
  cursor	party_cur is
    		select party_id, min(nvl(account_established_date,creation_date))
	 	from hz_cust_accounts
		group by party_id;
  x_party_id                 hz_cust_accounts.party_id                 % type;
  x_account_established_date hz_cust_accounts.account_established_date % type;
  rec_count	   number;
  activation_id_not_found Exception;
  acquisition_not_found Exception;
  activation_period_not_found Exception;
begin
   g_proc_name_old := g_proc_name;
   g_proc_name := 'Extract_acquisition_data';
   g_tot_recs_added := 0;
   rec_count      := 0;

   debug('entered +');
   bic_consolidate_cust_data_pkg.purge_party_summary_data;

   if	(get_activation_period = false) then
    write_log('Error: activation_period for ACQUISITION not defined');
   RAISE   activation_period_not_found;
--   	return;
   end if;

   g_measure_id_for_acti := get_measure_id('ACTIVATION');
   g_measure_id_for_acqu := get_measure_id('ACQUISITION');
   if g_measure_id_for_acti = 0 then
   	write_log('Error: Measure_id not found for ACTIVATION');
    RAISE activation_id_not_found;
   	--return;
   end if;

   if g_measure_id_for_acqu = 0 then
      	write_log('Error: Measure_id not found for ACQUISITION');
     RAISE acquisition_not_found;
--      	return;
   end if;

   -- write_log ( 'values of passed params for acquistion ' || g_period_start_date ||
   -- g_delete_flag || g_org_id );
   bic_summary_extract_pkg.extract_periods (
     				g_period_start_date - g_activation_period,
   				g_period_end_date,
   				'ACQUISITION',
   				'N',
   				g_delete_flag,
   				g_org_id);

     select count(*) into rec_count
     from	 bic_temp_periods;

     if rec_count = 0 then
     write_log('acquitistion data  already extracted');
     	return;
  end if;

   open party_cur;
   loop
     fetch party_cur into x_party_id, x_account_established_date;
     if party_cur % notfound then
	   exit;
     end if;
    -- BEGIN
       -- SAVEPOINT start_transaction;
   	insert into bic_party_summary ( --bic_customer_summary_all (
		measure_id,
	     	party_id, --customer_id,
		period_start_date,
	     	value,
	     	last_update_date,
	     	creation_date,
	     	program_update_date,
	     	last_updated_by,
	     	created_by,
	     	request_id,
	     	program_application_id,
	     	program_id,
	     	last_update_login,
		measure_code)
   	select 	distinct
		g_measure_id_for_acqu, --bma.measure_id,
		x_party_id,
	     	bdt.start_date,
	     /*to_number(to_char(nvl(hca.account_established_date,hca.creation_date)
			             ,'J')
			    ),*/ to_number(to_char(x_account_established_date,'J')),
	     	sysdate,
	     	sysdate,
	     	sysdate,
	     	g_last_updated_by,
	     	g_created_by,
	     	g_request_id,
	     	g_program_application_id,
	     	g_program_id,
	     	g_last_update_login,
		'ACQUISITION'
     from 	bic_temp_periods        bdt
    where 	x_account_established_date
		between bdt.act_period_start_date and
                bdt.act_period_end_date ;
   /*   and 	trunc(bdt.start_date)
	  between (trunc(g_period_start_date) - g_activation_period +1) and
	     	trunc(g_period_end_date); */
     --  EXCEPTION WHEN OTHERS THEN
      --      ROLLBACK   TO start_transaction;
    --  END;
    --  COMMIT;
      g_tot_recs_added := g_tot_recs_added + sql%rowcount;
   end loop;
   close party_cur;

   write_log('Total Records Added for Acquisition:'||
									    to_char(g_tot_recs_added));
-- Now  insert activated customers. Here sequence is important. Activation
-- data can be inserted only after acquisition data has been extracted because
-- activation data is dependent on acquistion data.

write_log('Before Activation Extraction...');
-- A acquired customer can be considered activated
-- only in the month in which the first order is made and the first order should
-- be within the activation period and also within the start and end dates of extraction
insert into bic_party_summary (measure_id      ,
						 party_id              ,
						 period_start_date     ,
						 value                 ,
						 last_update_date      ,
						 creation_date         ,
						 program_update_date   ,
						 last_updated_by       ,
						 created_by            ,
						 request_id            ,
						 program_application_id,
						 program_id            ,
						 last_update_login     ,
					      measure_code)
	  select
	  g_measure_id_for_acti,
	  bcs.party_id,
	  trunc(min(aoh.ordered_date), 'MONTH'),
	  1,
	  sysdate,
	  sysdate,
	  sysdate,
	  g_last_updated_by,
	  g_created_by,
	  g_request_id,
	  g_program_application_id,
	  g_program_id,
	  g_last_update_login,
	  'ACTIVATION'
  from oe_order_headers_all aoh,             --4434468 replaced aso_i_oe_order_headers_v with oe_order_headers_all
       bic_party_summary        bcs,
	  hz_cust_accounts         acct
 where bcs.measure_id   = g_measure_id_for_acqu

   --and to_date(bcs.value + g_activation_period  ,'J') >= g_period_start_date

   --and to_date(bcs.value ,'J') <= g_period_end_date
   and bcs.party_id            = acct.party_id
   and acct.cust_account_id    = aoh.sold_to_org_id
   and aoh.ordered_date between to_date(bcs.value,'J') and
						  to_date(bcs.value+g_activation_period,'J')
   group by
   g_measure_id_for_acti,
   bcs.party_id,
   sysdate,
   sysdate,
   sysdate,
   g_last_updated_by,
   g_created_by,
   g_request_id,
   g_program_application_id,
   g_program_id,
   g_last_update_login
   having  min(aoh.ordered_date) between g_period_start_date
                                 and     g_period_end_date;
   write_log('Total Records Added for Activation:'||
									    to_char(sql%rowcount));
   g_proc_name := g_proc_name_old;

   bic_consolidate_cust_data_pkg.populate_status_data(g_period_start_date,g_period_end_date);
   bic_consolidate_cust_data_pkg.purge_party_summary_data;

   commit;
   debug('exited -');

   EXCEPTION
    when activation_period_not_found then
        generate_error('ACTIVATION','No records in BIC_PROFILE_VALUES_ALL');
        rollback;
    when acquisition_not_found then
        generate_error('ACQUISITION','Measure_id not found for ACQUISITION in the table BIC_MEASURES_ALL');
        rollback;
    when activation_id_not_found then
        generate_error('ACTIVATION','Measure_id not found for ACTIVATION in the table BIC_MEASURES_ALL');
        rollback;
	when others then
	    write_log(' Activation data is not extracted due to exception : '||sqlerrm);
        generate_error(g_measure_code,'Activation data is not extracted : '||sqlerrm);
        rollback;
end extract_acquisition_data;

-- This procedure is called by concurrent program to extract customer
-- summary data. This procedure take date range for extraction. If start
-- date is null then profile value of 'BIC_SMRY_EXTRACTION_DATE is taken as
-- start date. If end date is null then it is set to start date of the period
-- which ends before system date.
-- If delete flag is 'Y' then data is deleted before extraction. Default
-- value of delete flag is 'N'.
-- If measure code is null then data for all measures i.e. 'SATISFACTION',
-- 'LOYALTY', 'RETENTION', 'ACQUISTION', 'LIFECYCLE' is extracted.
-- if org id is null then dat for all orgs is extracted.
procedure extract_main (
			errbuf    out NOCOPY varchar2,
			retcode   out NOCOPY number ,
			p_start_date    varchar2	default null,
			p_end_date      varchar2	default null,
			p_delete_flag   varchar2	default null,
			p_measure_code  varchar2	default null,
			p_org_id        number		default null) as
   x_start_date date;
   x_end_date   date;
   x_date       date;
   x_sql_string varchar2(500);
   x_cnt        number;
begin
    set_debug;
    g_proc_name     := 'Extract_main';
    g_proc_name_old :=  g_proc_name;
    g_srl_no        := 1;

  -- start global variables initialization
  g_measure_code := p_measure_code;
  g_org_id       := p_org_id;
  if p_delete_flag is null then
  g_delete_flag := 'N';
  else
  g_delete_flag  := p_delete_flag;
  end if;

  write_log('Parameters Passed to Extraction Program');
  write_log('---------------------------------------');
  write_log('   Start Date:'||p_start_date);
  write_log('     End Date:'||p_end_date  );
  write_log('  Delete Flag:'||p_delete_flag);
  write_log(' Measure Code:'||nvl(g_measure_code,'Null'));
  write_log('       Org Id:'||nvl(to_char(p_org_id),'Null'));
  write_log('---------------------------------------');
 -- write_log('calling set_period_exist');
  if (set_periods_exist (	p_start_date,
  				p_end_date
				 	) = false ) then
    write_log('All Periods do not exist in the table bic_dimv_time , Plz. run the "Extract Calendar"');
    generate_error('Main','Periods should be extracted before running this program');
    return;
  end if;
  write_log('after set_periods_exist ' || g_period_start_date || ' ' || g_period_end_date );
  ----------------------------------------------------------------------------
  -- initialize global variables for who columns
  g_last_updated_by        := fnd_global.user_id        ;
  g_created_by             := fnd_global.user_id        ;
  g_last_update_login      := fnd_global.login_id       ;
  g_request_id             := fnd_global.conc_request_id;
  g_program_application_id := fnd_global.prog_appl_id   ;
  g_program_id             := fnd_global.conc_program_id;
  -- global variables initialization complete
  g_proc_name := 'Extract_Main';
  -- extracting periods for all measures
  if nvl(g_delete_flag,'N') = 'Y' then
    extract_all_periods(g_period_start_date , g_period_end_date );
  end if;
  -- extract retention
       if g_measure_code is null or g_measure_code = 'RETENTION' then
          if measure_disabled('RETENTION') <> 'Y' then
            g_proc_name := 'Extract_Main';
            write_log('Before Retention Extraction...');
            extract_retention;
           end if;
        end if;
  -- extract sales. This is same as Revenue
        if g_measure_code is null or g_measure_code = 'SALES' then
          if measure_disabled('SALES') <> 'Y' then
          g_proc_name := 'Extract_Main';
          write_log('Before Sales/Revenue Extraction...');
  	      extract_sales(g_period_start_date,g_period_end_date,g_org_id);
          end if;
    end if;
  -- extract  Cost Of Goods data
        if g_measure_code is null or g_measure_code = 'COGS' then
          if measure_disabled('COGS') <> 'Y' then
          g_proc_name := 'Extract_Main';
          write_log('Before Cost Of Goods Extraction...');
  	      extract_cogs;
       end if;
    end if;
  -- extract Satisfaction
      if g_measure_code is null or g_measure_code = 'SATISFACTION' then
          g_proc_name := 'Extract_Main';
          write_log('Before SATISFACTION Extraction...');
  	      extract_satisfaction;
      end if;
  -- extract Loyalty
     if g_measure_code is null or g_measure_code in ('LOYALTY') then
            g_proc_name := 'Extract_Main';
  	        write_log('Before Loyalty Extraction...');
  		    extract_loyalty;
    end if;
  -- extract Acquisition
  if g_measure_code is null or g_measure_code = 'ACQUISITION' then
       if measure_disabled('ACQUISITION') <> 'Y' then
          g_proc_name := 'Extract_Main';
          write_log('Before Acquisition Extraction....');
            extract_acquisition_data;
       end if;
  end if;
 -- extract LifeCycle
 if g_measure_code is null or g_measure_code = 'LIFE_CYCLE' then
     	if measure_disabled('LIFE_CYCLE') <> 'Y' then
        g_proc_name := 'Extract_Main';
        write_log('Before Life Cycle Extraction....');
	   bic_lifecycle_extract_pkg.extract_lifecycle_data( g_period_start_date,
							     g_period_end_date,
							     g_delete_flag,
							     g_org_id
							     );
     end if;
  end if;
  -- calling the update market segment procedure
  bic_consolidate_cust_data_pkg.update_market_segment;
  -- set profile value of BIC_SMRY_EXTRACTION_DATE iff start and end dates
  -- passed to the procedure are null.
  if p_start_date is null and p_end_date is null then
	fnd_profile.put('BIC_SMRY_EXTRACTION_DATE',
						to_char(g_period_end_date,'dd-mm-yyyy'));
     write_log('BIC_SMRY_EXTRACTION_DATE profile option is set to ' ||
			 to_char(g_period_end_date,'dd-mm-yyyy'));
   end if;
   g_proc_name := g_proc_name_old;

   exception when others then
   generate_error(null,'Exception occured inside extract_main :'||sqlerrm);
end extract_main;
--
-- This procedure inserts some of the order measures
procedure insert_order_measures is
  cursor c_orders is
    SELECT hca.party_id         customer_id,
           bdt.start_date       period_start_date,
           ooh.org_id,
           count(distinct decode(ool.line_category_code,'ORDER',ooh.header_id,
												    null
                )) orders,
           count(distinct decode(ool.line_category_code,'RETURN',ooh.header_id,
												     null
                )) returns,
           sum((decode(ool.line_category_code,'ORDER',
				ool.ordered_quantity - nvl(ool.cancelled_quantity,0)) *
	                 bic_summary_extract_pkg.convert_amt(
							ooh.transactional_curr_code,
							ooh.ordered_date,
							ool.unit_selling_price))
 	         ) order_amt,
           sum((decode(ool.line_category_code,'RETURN',
				ool.ordered_quantity - nvl(ool.cancelled_quantity,0)) *
	                 bic_summary_extract_pkg.convert_amt(
							ooh.transactional_curr_code,
							ooh.ordered_date,
							ool.unit_selling_price))
 	         ) return_amt,
          sum(decode(ool.line_category_code,'ORDER',
				  ool.ordered_quantity - nvl(ool.cancelled_quantity,0),
				  null)) order_qty,
          sum(decode(ool.line_category_code,'RETURN',
				  ool.ordered_quantity - nvl(ool.cancelled_quantity,0),
				  null)) return_qty
     FROM aso_i_oe_order_lines_v   ool,
          aso_i_oe_order_headers_v ooh,
          bic_dimv_time        bdt,
	     hz_cust_accounts     hca
    WHERE ooh.header_id          = ool.header_id
      AND ooh.sold_to_org_id is not null
      AND ooh.ordered_date between bdt.start_date and act_period_end_date
      AND trunc(bdt.start_date)
		BETWEEN trunc(g_period_start_date)AND trunc(g_period_end_date)
      and hca.cust_account_id = ooh.sold_to_org_id
    group by hca.party_id      , bdt.start_date, ooh.org_id
    ;
  x_orders     number;
  x_order_qty  oe_order_lines_all.ordered_quantity   % type;
  x_order_amt  oe_order_lines_all.unit_selling_price % type;
  x_returns    number;
  x_return_qty oe_order_lines_all.ordered_quantity   % type;
  x_return_amt oe_order_lines_all.unit_selling_price % type;
  x_party_id   hz_parties.party_id                   % type;
  x_org_id     oe_order_headers_all.org_id           % type;
  x_start_date date;
begin
  --dbms_output.put_line(to_char(sysdate,'dd-mm-yyyy hh24:mi:ss'));
  open c_orders;
  loop
	fetch c_orders into x_party_id, x_start_date, x_org_id,
					x_orders, x_returns, x_order_amt, x_return_amt,
					x_order_qty, x_return_qty;
     if c_orders % notfound then
	   exit;
     end if;
     insert_record('ORDER_NUM', x_start_date, x_party_id,
										   x_orders, x_org_id);
     insert_record('ORDER_QTY', x_start_date, x_party_id,
										   x_order_qty, x_org_id);
     insert_record('ORDER_AMT', x_start_date, x_party_id,
										   x_order_amt, x_org_id);
     insert_record('RETURNS', x_start_date, x_party_id,
										   x_returns, x_org_id);
     insert_record('RETURN_QTY', x_start_date, x_party_id,
										   x_return_qty, x_org_id);
     insert_record('RETURN_BY_VALUE', x_start_date, x_party_id,
										   x_return_amt, x_org_id);
	/***********************************************************************
	***********************************************************************/
  end loop;
  close c_orders;
  --dbms_output.put_line(to_char(sysdate,'dd-mm-yyyy hh24:mi:ss'));
end insert_order_measures;

procedure insert_order_delivery_measures is
  cursor c_orders is
    select
       hca.party_id   customer_id,
       bdt.start_date       period_start_date,
       ooh.org_id,
       count(decode(ool.line_category_code,'ORDER', ool.line_id,null)) line_dl,
       count(decode(sign(ool.request_date-ool.actual_shipment_date),
				 	        1,null, 1)) line_ot,
       sum(ool.shipped_quantity *
		    bic_summary_extract_pkg.convert_amt(ooh.transactional_curr_code,
									     ooh.ordered_date,
									     ool.unit_selling_price)
	     ) del_val,
       sum(decode(sign(ool.request_date-ool.actual_shipment_date),
	        1,0,
             ool.shipped_quantity *
		    bic_summary_extract_pkg.convert_amt(ooh.transactional_curr_code,
									     ooh.ordered_date,
									     ool.unit_selling_price)
	     )) ontime_val
    from
       aso_i_oe_order_headers_v ooh,
       aso_i_oe_order_lines_v   ool,
       hz_cust_accounts         hca,
       bic_dimv_time            bdt
    where
       trunc(bdt.start_date)
	  BETWEEN trunc(g_period_start_date)AND trunc(g_period_end_date)
       and ooh.sold_to_org_id is not null
       and ool.header_id = ooh.header_id
       and ool.actual_shipment_date between bdt.start_date
							    and bdt.act_period_end_date
       and hca.cust_account_id = ooh.sold_to_org_id
    group by
       hca.party_id,
       bdt.start_date,
       ooh.org_id;

  x_line_ontime  number;
  x_line_del     number;
  x_ontime_val   oe_order_lines_all.unit_selling_price % type;
  x_del_val      oe_order_lines_all.unit_selling_price % type;

  x_party_id   hz_parties.party_id                   % type;
  x_org_id     oe_order_headers_all.org_id           % type;
  x_start_date date;
begin
  --dbms_output.put_line(to_char(sysdate,'dd-mm-yyyy hh24:mi:ss'));
  open c_orders;
  loop
	fetch c_orders into x_party_id, x_start_date, x_org_id,
					x_line_del, x_line_ontime, x_del_val, x_ontime_val
					;
     if c_orders % notfound then
	   exit;
     end if;
     insert_record('ORDER_LINES_DELIVERED', x_start_date, x_party_id,
										   x_line_del, x_org_id);
     insert_record('ORDER_LINES_ONTIME', x_start_date, x_party_id,
										   x_line_ontime, x_org_id);
     insert_record('OL_DEL_VALUE', x_start_date, x_party_id,
										   x_del_val, x_org_id);
     insert_record('OL_ONTIME_VALUE', x_start_date, x_party_id,
										   x_ontime_val, x_org_id);
	/***********************************************************************
	***********************************************************************/
  end loop;
  close c_orders;
  --dbms_output.put_line(to_char(sysdate,'dd-mm-yyyy hh24:mi:ss'));
end insert_order_delivery_measures;
----------------------------------------------------------------------------
procedure write_log (p_msg varchar2) is
begin
   if g_log_output is null then
	 fnd_file.put_line(fnd_file.log,substr(to_char(g_srl_no,'99') || '-'||
                                     p_msg || ': ' || g_proc_name,1,250) ||
							  to_char(sysdate,'dd-mm-yy hh24:mi:ss')
		             );
   end if;
   write_debug_msg(p_msg);
end write_log;

 procedure bulk_insert_sql_measures (p_stmnt  varchar2) is
   x_err varchar2(250);
 begin
	if g_org_id is null then
	   execute immediate p_stmnt using g_period_start_date,
								g_period_end_date;
	else
	   execute immediate p_stmnt using g_org_id,
								g_period_start_date,
								g_period_end_date;
	end if;
	commit;

	exception
	   when others then
	      x_err := substr(sqlerrm,1,240);
	      --dbms_output.put_line(to_char(g_srl_no) || x_err);
	  insert into bic_debug(report_id,message) values ('BICSUMMB',x_err);
 end;
 procedure process_sql_type_measures is
   x_str    varchar2(5000);
   x_stmnt1 varchar2(2000);
   x_stmnt2 varchar2(2000);
   cursor c_sql_measures is
	select sql_statement, measure_code
	  from bic_measure_attribs
      where sql_statement is not null
	   and nvl(disable_flag,'N') = 'N'
	  ;

   x_end_date   date;
   x_start_date date;

   x_whr_pos    number;
   x_from_pos   number;
   x_extra_cond varchar2(60);
   x_err        varchar2(251);
   x_msr_code   bic_measure_attribs.measure_code % type;
 begin
   --x_start_date := to_date('01-jan-2000','dd-mm-yyyy');
   --x_end_date   := to_date('31-jan-2000','dd-mm-yyyy');
   --delete from bic_debug where report_id like 'BIC%SUMM%';
   open  c_sql_measures;
   loop
     fetch c_sql_measures into x_stmnt1, x_msr_code;
	if c_sql_measures % notfound then exit; end if;
	g_srl_no   := g_srl_no + 1;
	x_from_pos := instr(upper(x_stmnt1),'FROM');
	x_whr_pos  := instr(upper(x_stmnt1),'WHERE');
	if (g_org_id is not null) then
	   x_extra_cond := ' bma.org_id = :x_org_id and ';
     else
	   x_extra_cond := ' ';
     end if;
	x_stmnt2 := substr(x_stmnt1,1,x_from_pos-1) || ',weight ' ||
			  substr(x_stmnt1,x_from_pos,x_whr_pos-x_from_pos+5) ||
			  x_extra_cond ||
			  substr(x_stmnt1,x_whr_pos+5) || ',weight ';
     x_str :=' insert into bic_customer_summary_all (
                          measure_id
					,customer_id
					,period_start_date
					,org_id
					,value
					,bucket_id
					,score
					,measure_code
					,last_update_date
					,creation_date
					,last_updated_by
					,created_by)
		        select  a.measure_id
			          ,a.customer_id
			          ,a.period_start_date
			          ,a.org_id
			          ,a.value
			          ,b.bucket_id
			          ,nvl(a.weight * b.bucket_points,0) score
					,' || '''' || x_msr_code || '''' ||
			          ',sysdate
			          ,sysdate
					,' || to_char(g_created_by) || ',' ||
					to_char(g_last_updated_by) || '
				from bic_measure_buckets b, ('  || x_stmnt2 || ') a
			    where a.measure_id = b.measure_id(+)
				 and nvl(a.value,0) >= nvl(b.low_value  (+),0)
				 and nvl(a.value,0) <  nvl(b.high_value (+),
										   nvl(a.value,0)+2) ';
	  insert into bic_debug(report_id,message) values ('BICSUMMB',x_str);
	  write_log('Measure Code being processed-'||x_msr_code);
	  bulk_insert_sql_measures(x_str);
   end loop;
   close c_sql_measures;
 end process_sql_type_measures;
end bic_summary_extract_pkg; -- package body

/
