--------------------------------------------------------
--  DDL for Package Body BIS_COLLECTION_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_COLLECTION_UTILITIES" AS
/*$Header: BISDBUTB.pls 120.4 2006/09/07 14:38:26 amitgupt noship $*/

PROCEDURE UPDATE_DATE IS
l_count number;
BEGIN

	SELECT count(1) INTO l_count from BIS_SYSTEM_DATE;

	IF (l_count = 0) THEN /* INSERT DATE */

		INSERT INTO BIS_SYSTEM_DATE(current_date_id)
		values (trunc(sysdate));

	ELSIF (l_count = 1) THEN /* Exists, update if needed */

		UPDATE  BIS_SYSTEM_DATE
		set current_date_id = trunc(sysdate)
		WHERE trunc(sysdate) <> trunc(current_date_id);

	END IF;

END;


/*---------------------------------------------------------------------

 In case the log directory isnt passed and the EDW_LOGFILE_DIR profile
 option has also not been set, where do I write the log file ?

 Doing so by parsing the 'utl_file_dir' init.ora parameter and scanning
 for the word log and getting that string out.

---------------------------------------------------------------------*/


Function getUtlFileDir return VARCHAR2 IS
	l_dir VARCHAR2(1000);
	l_utl_dir VARCHAR2(100);
	l_count	  NUMBER := 0;
	l_log_begin	  NUMBER := 0;
	l_log_end	  NUMBER := 0;
	l_comma_pos	  NUMBER := 0;
	stmt		 VARCHAR2(200);
	cid		 NUMBER;
	l_dummy		 NUMBER;

BEGIN
	SELECT value into l_dir
	FROM v$parameter where upper(name) = 'UTL_FILE_DIR';

	l_log_begin := INSTR(l_dir, ',');

    IF (l_log_begin = 0) THEN /* then get the first string */
        l_utl_dir := l_dir;
    ELSE
	l_utl_dir := substr(l_dir, 1, INSTR(l_dir, ',') - 1);
    END IF;

   RETURN l_utl_dir;

END;

Procedure enableParallelDML IS
BEGIN

	execute immediate 'alter session enable parallel dml';
END;

Procedure disableParallelDML IS
BEGIN

	execute immediate 'alter session disable parallel dml';
END;


FUNCTION SETUP(	p_object_name        	IN VARCHAR2,
		p_parallel		IN NUMBER) RETURN BOOLEAN IS

l_dir		VARCHAR2 (400);
l_bis       VARCHAR2(20) := 'BIS';
BEGIN

	commit; /* commit open txns so that alter session works regardless*/

     -- Bug#5400214 :: This API is not required as FND takes care of the Log/Output file
     -- names on its own; plus these apis causes the same name to be re-used
     -- l_dir := getUtlFileDir;
     --
     -- IF l_dir IS NULL
     --       THEN
     --          l_dir := '/sqlcom/log';
     -- END IF;
     --       put_names (
     --             p_object_name
     --          || '.log',
     --             p_object_name
     --          || '.out',
     --          l_dir
     --       );

    --if fnd_profile.value('EDW_DEBUG') = 'Y' or
    --   FND_LOG.G_CURRENT_RUNTIME_LEVEL=FND_LOG.LEVEL_STATEMENT then
    if FND_LOG.TEST( FND_LOG.LEVEL_STATEMENT , l_bis || '.' || p_object_name  ) then
        g_debug := true;
    else
        g_debug := false;
    end if;

    g_object_name:= p_object_name;
    g_start_date:=sysdate;

    g_parallel := floor(p_parallel);

    IF (g_parallel is null) THEN
	BEGIN
	    g_parallel := fnd_profile.value('EDW_PARALLEL_SRC');
	EXCEPTION when others then
		g_parallel := 1;
	END;
    END IF;


    IF (g_parallel IS NULL OR g_parallel <1) THEN
	g_parallel := 1;
    END IF;


    if g_parallel > 1 then /* removed as per performance team's suggestion */
	null;
	--execute immediate 'alter session enable parallel dml';
	--execute immediate 'alter session force parallel dml parallel '|| g_parallel;
    end if;

	enableParallelDML;

    /* Update the System Date table if necessary */

    UPDATE_DATE ;

    commit;

    g_concurrent_id:=FND_GLOBAL.conc_request_id;
    return true;
Exception when others then
  g_status_message:=sqlerrm;
  log('Exception in  SETUP '||sqlerrm,0);
	raise;
  return false;
END SETUP;

/*
 *  Added for enhancement 3428371
 */
PROCEDURE WRITE_BIS_REFRESH_LOG(
        p_status            IN   BOOLEAN,
        p_count             IN   NUMBER ,
        p_message           IN   VARCHAR2  ,
        p_period_from       IN   DATE ,
        p_period_to         IN   DATE ,
        p_attribute1        IN   VARCHAR2 ,
        p_attribute2        IN   VARCHAR2 ,
        p_attribute3        IN   VARCHAR2 ,
        p_attribute4        IN   VARCHAR2 ,
        p_attribute5        IN   VARCHAR2 ,
        p_attribute6        IN   VARCHAR2 ,
        p_attribute7        IN   VARCHAR2 ,
        p_attribute8        IN   VARCHAR2 ,
        p_attribute9        IN   VARCHAR2 ,
        p_attribute10       IN   VARCHAR2 ) IS   --??? para type
      l_stmt          VARCHAR2 (5000);
      l_object_type   VARCHAR2 (30);
      l_status        VARCHAR2 (40);
      TYPE curtyp IS REF CURSOR;
      cv              curtyp;
BEGIN

	g_concurrent_id:=FND_GLOBAL.conc_program_id;
	g_request_id:=FND_GLOBAL.conc_request_id;
      	g_user_id := fnd_global.user_id;
      	g_login_id := fnd_global.login_id;
        if p_status then l_status:='SUCCESS';
         else l_status:='FAILURE';
        end if;

insert into bis_refresh_log(
Request_id,
Concurrent_id,
Object_name,
Status,
Start_date,
Period_from,
Period_to,
Number_processed_record,
Exception_message,
Creation_date,
Created_by,
Last_update_date,
Last_update_login,
Last_updated_by,
Attribute1, Attribute2, Attribute3, Attribute4,
Attribute5, Attribute6, Attribute7, Attribute8,
Attribute9, Attribute10 )
values
(g_request_id,
g_concurrent_id,
g_object_name,
l_status,
g_start_date,
p_period_from,
p_period_to,
p_count,
p_message,
sysdate,
g_user_id,
sysdate,
g_login_id,
g_user_id,
p_attribute1, p_attribute2, p_attribute3, p_attribute4,
p_attribute5, p_attribute6, p_attribute7, p_attribute8,
p_attribute9, p_attribute10 );
commit;
Exception when others then
  g_status_message:=sqlerrm;
  log('Exception in  WRITE_BIS_REFRESH_LOG '||sqlerrm,0);
END WRITE_BIS_REFRESH_LOG;

----This function checks if the program exists or not
function program_exist(p_program_short_name in varchar2, p_program_application_id in number) return varchar2 is
 l_exist_flag varchar2(1);
begin
  l_exist_flag:='N';
  select 'Y'
  into l_exist_flag
  from fnd_concurrent_programs
  where concurrent_program_name=p_program_short_name
  and application_id=p_program_application_id;
  return l_exist_flag;
exception
  when no_data_found then
    l_exist_flag:='N';
    return l_exist_flag;
  when others then
    raise;
end;

PROCEDURE WRAPUP(
        p_status            IN   BOOLEAN,
        p_count             IN   NUMBER ,
        p_message           IN   VARCHAR2  ,
        p_period_from       IN   DATE ,
        p_period_to         IN   DATE ,
        p_attribute1        IN   VARCHAR2 ,
        p_attribute2        IN   VARCHAR2 ,
        p_attribute3        IN   VARCHAR2 ,
        p_attribute4        IN   VARCHAR2 ,
        p_attribute5        IN   VARCHAR2 ,
        p_attribute6        IN   VARCHAR2 ,
        p_attribute7        IN   VARCHAR2 ,
        p_attribute8        IN   VARCHAR2 ,
        p_attribute9        IN   VARCHAR2 ,
        p_attribute10       IN   VARCHAR2 ) IS   --??? para type
      l_stmt          VARCHAR2 (5000);
      l_object_type   VARCHAR2 (30);
      l_status        VARCHAR2 (40);
      errbuf varchar2(2000);
      retcode number;
      l_option_string varchar2(30);
      l_cursor_id       integer;
     l_rows            integer:=0;
      TYPE curtyp IS REF CURSOR;
      cv              curtyp;
      l_temp   boolean;
BEGIN
  commit;
  disableParallelDML;

  WRITE_BIS_REFRESH_LOG(
        p_status,
        p_count,
        p_message,
        p_period_from,
        p_period_to,
        p_attribute1,
        p_attribute2,
        p_attribute3,
        p_attribute4,
        p_attribute5,
        p_attribute6,
        p_attribute7,
        p_attribute8,
        p_attribute9,
        p_attribute10);
  -- Bug#5400214 :: This API is not required as FND takes care of the Log/Output file
  -- names on its own; plus these apis causes the same name to be re-used
  -- FND_FILE.RELEASE_NAMES(g_object_name||'.log', g_object_name||'.out');
commit;


---The following code is added for KPI end to end support
---call "Import BIS Time Dimension into BSC" so that whenever time dimension
---is updated, this program is also being called to make data consistent
if g_object_name='FII_DBI_TIME_M' and program_exist('BSC_IMP_BIS_TIME_BSC',271)='Y' then
   begin
     BIS_COLLECTION_UTILITIES.put_line('calling "Import BIS Time Dimension into BSC program"');
     if g_debug then
        l_option_string:='DEBUG LOG';
     else
    	 l_option_string:=null;
     end if;
   /**
     l_stmt := 'BEGIN BSC_DBI_CALENDAR.load_dbi_cal_into_bsc(:errbuf, :retcode,:option_string); END;';
     l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.parse(l_cursor_id,l_stmt,DBMS_SQL.V7);
     DBMS_SQL.bind_variable(l_cursor_id,'errbuf',errbuf, 32767);
     DBMS_SQL.bind_variable(l_cursor_id,'retcode',retcode, 200);
     DBMS_SQL.bind_variable(l_cursor_id,'option_string',l_option_string, 32767);
     l_rows:=DBMS_SQL.execute(l_cursor_id);
     DBMS_SQL.close_cursor(l_cursor_id);
     **/
     l_stmt := 'BEGIN BSC_DBI_CALENDAR.load_dbi_cal_into_bsc(:1, :2,:3); END;';
     execute immediate l_stmt using OUT errbuf,OUT retcode,IN l_option_string;
     BIS_COLLECTION_UTILITIES.put_line('Done ' || 'BSC_DBI_CALENDAR.load_dbi_cal_into_bsc');
     BIS_COLLECTION_UTILITIES.put_line('********************************************************');
   exception
     when others then
        BIS_COLLECTION_UTILITIES.put_line('Exception happens in BSC_DBI_CALENDAR.load_dbi_cal_into_bsc '||sqlerrm);
        l_temp:=fnd_concurrent.set_completion_status('WARNING' ,NULL);
   end;
end if;

Exception when others then
  g_status_message:=sqlerrm;
  log('Exception in  WRAPUP '||sqlerrm,0);
END WRAPUP;

function get_last_refresh_period(p_object_name in varchar2) return varchar2 is
l_date   date;
l_date_disp varchar2(100);
begin
	/* will NOT raise a no_data_found because of MAX */

    SELECT MAX(period_to) INTO l_date
    FROM bis_refresh_log
    WHERE   object_name = p_object_name AND
	    status='SUCCESS' AND
	    last_update_date =
		(SELECT MAX(last_update_date)
		 FROM bis_refresh_log
		 WHERE object_name= p_object_name AND
		       status='SUCCESS' ) ;

    IF (l_date IS NULL) THEN
	l_date:= to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'), 'mm/dd/yyyy');
    END IF;

    l_date_disp := fnd_date.date_to_displaydt (l_date);
    return l_date_disp;

    Exception
	WHEN OTHERS THEN
  	g_status_message:=sqlerrm;
  	log('Exception in  GET_LAST_REFRESH_PERIOD '||sqlerrm,0);
end get_last_refresh_period;

procedure get_last_refresh_dates(
p_object_name IN VARCHAR2,
p_start_date OUT NOCOPY DATE,
p_end_date OUT NOCOPY DATE,
p_period_from OUT NOCOPY DATE,
p_period_to OUT NOCOPY DATE
) is
cursor last_refresh_date_cursor(p_obj_name varchar2) is
    select start_date, last_update_date, period_from, period_to
	from bis_refresh_log
	where object_name = p_obj_name and status='SUCCESS'
	and last_update_date =( select max(last_update_date)
     	from bis_refresh_log
          where object_name= p_obj_name and  status='SUCCESS' ) ;
begin
    open last_refresh_date_cursor(p_object_name);
    fetch last_refresh_date_cursor into p_start_date, p_end_date, p_period_from, p_period_to;
    if(last_refresh_date_cursor%ROWCOUNT < 1) then
        p_start_date:=null;
        p_end_date:=null;
        p_period_from:=null;
        p_period_to:=null;
    end if;
    close last_refresh_date_cursor;

     Exception
        WHEN NO_DATA_FOUND THEN
            p_start_date:=null;
            p_end_date:=null;
            p_period_from:=null;
            p_period_to:=null;
	WHEN OTHERS THEN
  	g_status_message:=sqlerrm;
  	log('Exception in  GET_LAST_REFRESH_DATES '||sqlerrm,0);
end get_last_refresh_dates;

procedure get_last_user_attributes(
 p_object_name          IN VARCHAR2,
 p_attribute_table	OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE,
 p_count		OUT NOCOPY NUMBER ) is
l_allattribute varchar2(2400);
begin
 p_count:=0;

 select attribute1, attribute2,  attribute3, attribute4, attribute5,
   attribute6,attribute7, attribute8, attribute9, attribute10,
   attribute1||attribute2||attribute3||attribute4||attribute5||
   attribute6||attribute7||attribute8||attribute9||attribute10
 into p_attribute_table(1), p_attribute_table(2), p_attribute_table(3),
	p_attribute_table(4), p_attribute_table(5), p_attribute_table(6),
	p_attribute_table(7), p_attribute_table(8), p_attribute_table(9),
	p_attribute_table(10), l_allattribute
 from bis_refresh_log
	where object_name = p_object_name and status='SUCCESS'
	and last_update_date =( select max(last_update_date)
     	from bis_refresh_log
          where object_name= p_object_name and  status='SUCCESS' ) ;

 if (l_allattribute is null) then p_count:=0;
 else p_count:=10;
 end if;

 Exception
        WHEN NO_DATA_FOUND THEN
            p_count:=0;
	    p_attribute_table.delete;
	WHEN OTHERS THEN
	 p_count:=0;
	    p_attribute_table.delete;
  	g_status_message:=sqlerrm;
  	log('Exception in  GET_LAST_USER_ATTRIBUTES '||sqlerrm,0);

end get_last_user_attributes;

procedure log(
p_message	IN VARCHAR2,
p_indenting	IN NUMBER) is
l_message       varchar2(2000):=null;
begin
    for i in 1..p_indenting loop
		l_message:='   '||l_message;
	end loop;
	l_message:=l_message||p_message;
	put_line (l_message);
end log;

/*
 * Added for FND_LOG uptaking
 */
procedure log(
p_message	IN VARCHAR2,
p_indenting	IN NUMBER,
p_severity NUMBER) is
l_message       varchar2(2000):=null;
begin
    for i in 1..p_indenting loop
		l_message:='   '||l_message;
	end loop;
	l_message:=l_message||p_message;
	put_line (l_message, p_severity);
end log;

procedure debug(
p_message	IN VARCHAR2,
p_indenting	IN NUMBER) is
l_message       varchar2(2000):=null;
begin
    IF g_debug then
      for i in 1..p_indenting loop
		l_message:='   '||l_message;
	  end loop;
	  l_message:=l_message||p_message;
	  put_line (l_message, FND_LOG.LEVEL_STATEMENT);
    END IF;
end debug;


/*
 * Added for FND_LOG uptaking
 */
procedure debug(
p_message	IN VARCHAR2,
p_indenting	IN NUMBER,
p_severity NUMBER) is
l_message       varchar2(2000):=null;
begin
    IF g_debug then
      for i in 1..p_indenting loop
		l_message:='   '||l_message;
	  end loop;
	  l_message:=l_message||p_message;
	  put_line (l_message ,p_severity);
    END IF;
end debug;

procedure out(
p_message	IN VARCHAR2,
p_indenting	IN NUMBER) is
l_message       varchar2(2000):=null;
begin
        for i in 1..p_indenting loop
		l_message:='   '||l_message;
	end loop;
	l_message:=l_message||p_message;
	put_line_out (l_message);
end out;

PROCEDURE put_names(
	p_log_file		VARCHAR2,
	p_out_file		VARCHAR2,
	p_directory		VARCHAR2 /* Obsoleted */) IS
l_dir VARCHAR2(100) := null;

BEGIN

-- Need to add a call to getUtlFileDir as this is a public API and
-- teams may call this directly with invalid directories

	l_dir := getUtlFileDir;
	FND_FILE.PUT_NAMES(p_log_file, p_out_file, l_dir);

END put_names;

/*
 * Added for FND_LOG uptaking
 */
PROCEDURE put_line(
p_text			VARCHAR2,
p_severity NUMBER) IS
BEGIN
  put_conc_log(p_text);
  put_fnd_log(p_text , p_severity);
END put_line;



PROCEDURE put_line(p_text VARCHAR2) IS
BEGIN
  put_conc_log(p_text);
  put_fnd_log(p_text , FND_LOG.LEVEL_EXCEPTION);
END put_line;


/*
 * Added for FND_LOG uptaking
 */
PROCEDURE put_conc_log(p_text VARCHAR2) IS
 l_len number;
 l_start number:=1;
 l_end number:=1;
 last_reached boolean:=false;
BEGIN
 if p_text is null or p_text='' then
   return;
 end if;
 l_len:=nvl(length(p_text),0);
 if l_len <=0 then
   return;
 end if;
 while true loop
  l_end:=l_start+250;
  if l_end >= l_len then
   l_end:=l_len;
   last_reached:=true;
  end if;
  FND_FILE.PUT_LINE(FND_FILE.LOG,substr(p_text, l_start, 250));
  l_start:=l_start+250;
  if last_reached then
   exit;
  end if;
 end loop;
END put_conc_log;

/*
 * Added for FND_LOG uptaking
 */
PROCEDURE put_fnd_log(p_text VARCHAR2, p_severity NUMBER) IS
 l_len number;
 l_start number:=1;
 l_end number:=1;
 last_reached boolean:=false;
 l_bis       VARCHAR2(20) := 'BIS';

BEGIN
 if p_text is null or
    p_text='' or
    FND_LOG.G_CURRENT_RUNTIME_LEVEL<FND_LOG.LEVEL_STATEMENT
 then
   return;
 end if;

 l_len:=nvl(length(p_text),0);
 if l_len <=0 then
   return;
 end if;
 while true loop
  l_end:=l_start+250;
  if l_end >= l_len then
   l_end:=l_len;
   last_reached:=true;
  end if;
  if p_severity>=FND_LOG.G_CURRENT_RUNTIME_LEVEL then
    FND_LOG.STRING(p_severity, l_bis || '.' || g_object_name ,substr(p_text, l_start, 250));
  end if;
  l_start:=l_start+250;
  if last_reached then
   exit;
  end if;
 end loop;
END put_fnd_log;

PROCEDURE put_line_out(p_text VARCHAR2) IS
 l_len number;
 l_start number:=1;
 l_end number:=1;
 last_reached boolean:=false;
BEGIN
  if p_text is null or p_text='' then
   return;
 end if;
 l_len:=nvl(length(p_text),0);
 if l_len <=0 then
   return;
 end if;
 while true loop
  l_end:=l_start+250;
  if l_end >= l_len then
   l_end:=l_len;
   last_reached:=true;
  end if;
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,substr(p_text, l_start, 250));
  l_start:=l_start+250;
  if last_reached then
   exit;
  end if;
 end loop;
END put_line_out;


----the following code is for fixing bug 3326023
function get_user_rate_type(p_rate_type in varchar2) return varchar2 is
cursor c_user_rate_type is
SELECT user_conversion_type
FROM gl_daily_conversion_types
WHERE conversion_type = p_rate_type;

l_user_rate_type varchar2(30);

BEGIN
 open c_user_rate_type;
 fetch c_user_rate_type into l_user_rate_type;
 if c_user_rate_type%notfound then
   l_user_rate_type:=p_rate_type;
 end if;
 close c_user_rate_type;
 return l_user_rate_type;
END;

FUNCTION  getMissingRateHeader return VARCHAR2 IS
l_msg varchar2(3000) := null;
l_newline varchar2(10) := '
';
l_temp varchar2(1000) := null;
BEGIN


fnd_message.set_name('BIS','BIS_DBI_CURR_OUTPUT_HDR');
l_msg := fnd_message.get || l_newline;


fnd_message.set_name('BIS','BIS_DBI_COL_RATE_TYPE');
l_temp:=substr(fnd_message.get, 1,g_length_rate_type );
l_temp := l_temp|| substr(g_space, 1, g_length_rate_type - length(l_temp))||g_indenting;
l_msg := l_msg || l_temp;



fnd_message.set_name('BIS','BIS_DBI_COL_FROM_CURRENCY');
l_temp := substr(fnd_message.get, 1, g_length_from_currency);
l_temp := l_temp || substr(g_space, 1, g_length_from_currency - length(l_temp)) || g_indenting;
l_msg := l_msg || l_temp;

fnd_message.set_name('BIS','BIS_DBI_COL_TO_CURRENCY');
l_temp:=substr(fnd_message.get, 1,g_length_to_currency );
l_temp := l_temp || substr(g_space, 1, g_length_to_currency - length(l_temp)) || g_indenting;
l_msg := l_msg || l_temp;

fnd_message.set_name('BIS','BIS_DBI_COL_DATE');
l_temp:=substr(fnd_message.get, 1,g_length_date );
l_temp := l_temp || substr(g_space, 1, g_length_date - length(l_temp));
l_msg := l_msg || l_temp || l_newline;

l_temp :=  substr(g_line, 1, g_length_rate_type)||g_indenting||
	substr(g_line, 1, g_length_from_currency)||g_indenting||
	substr(g_line, 1, g_length_to_currency)||g_indenting||
	substr(g_line, 1, g_length_date);

/*'------------'||g_indenting ||'-----------------'||g_indenting||
'---------------'||g_indenting||'-------------';*/
l_msg := l_msg || l_temp||l_newline;

return l_msg;
END;


FUNCTION getMissingRateText(
p_rate_type IN VARCHAR2,      /* Rate type */
p_from_currency IN VARCHAR2,  /* From Currency */
p_to_currency in VARCHAR2,    /* To Currency */
p_date IN DATE,               /* Date in default format */
p_date_override IN VARCHAR2) return VARCHAR2 /* Formatted date, will output this instead of p_date */
IS

l_msg varchar2(1000) := null;
l_temp varchar2(1000) := null;
l_user_rate_type varchar2(30):=null;

BEGIN
l_user_rate_type:=get_user_rate_type(p_rate_type);

---l_msg:=substr(p_rate_type, 1,g_length_rate_type );
l_msg:=substr(l_user_rate_type, 1,g_length_rate_type );

l_msg := l_msg || substr(g_space, 1, g_length_rate_type - length(l_msg))|| g_indenting;


l_temp:=substr(p_from_currency, 1, g_length_from_currency);
l_temp := l_temp || substr(g_space, 1, g_length_from_currency - length(l_temp)) || g_indenting;
l_msg := l_msg||l_temp;


l_temp:=substr(p_to_currency, 1,g_length_to_currency );
l_temp := l_temp || substr(g_space, 1, g_length_to_currency - length(l_temp)) || g_indenting;
l_msg := l_msg ||l_temp;


IF (p_date_override IS NULL) THEN
	l_temp:=substr(fnd_date.date_to_displayDT(p_date), 1,g_length_date );
ELSE
	l_temp := substr(p_date_override, 1,g_length_date );
END IF;

l_temp := l_temp || substr(g_space, 1, g_length_date - length(l_temp)) || g_indenting;
l_msg := l_msg||l_temp;

return l_msg;

END;


Procedure writeMissingRateHeader
IS
l_msg varchar2(3000):=null;

BEGIN


fnd_message.set_name('BIS','BIS_DBI_CURR_OUTPUT_HDR');
l_msg := fnd_message.get;
fnd_file.put_line(FND_FILE.OUTPUT, l_msg);
fnd_file.put_line(FND_FILE.OUTPUT, '');


fnd_message.set_name('BIS','BIS_DBI_COL_RATE_TYPE');
l_msg:=substr(fnd_message.get, 1,g_length_rate_type );
l_msg := l_msg|| substr(g_space, 1, g_length_rate_type - length(l_msg))||g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);



fnd_message.set_name('BIS','BIS_DBI_COL_FROM_CURRENCY');
l_msg:=substr(fnd_message.get, 1, g_length_from_currency);
l_msg := l_msg || substr(g_space, 1, g_length_from_currency - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);


fnd_message.set_name('BIS','BIS_DBI_COL_TO_CURRENCY');
l_msg:=substr(fnd_message.get, 1,g_length_to_currency );
l_msg := l_msg || substr(g_space, 1, g_length_to_currency - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);


fnd_message.set_name('BIS','BIS_DBI_COL_DATE');
l_msg:=substr(fnd_message.get, 1,g_length_date );
l_msg := l_msg || substr(g_space, 1, g_length_date - length(l_msg));
fnd_file.put_line(FND_FILE.OUTPUT, l_msg);


/*fnd_file.put_line(FND_FILE.OUTPUT,
'------------'||g_indenting ||'-----------------'||g_indenting||
'---------------'||g_indenting||'-------------');
*/
l_msg :=  substr(g_line, 1, g_length_rate_type)||g_indenting||
	substr(g_line, 1, g_length_from_currency)||g_indenting||
	substr(g_line, 1, g_length_to_currency)||g_indenting||
	substr(g_line, 1, g_length_date);

fnd_file.put_line(FND_FILE.OUTPUT, l_msg);


END;

/*
 Rate Type      From Currency       To Currency       Date
 ------------   -----------------   ---------------   -------------
*/



Procedure writeMissingRate(p_rate_type IN VARCHAR2, p_from_currency IN VARCHAR2, p_to_currency in VARCHAR2, p_date IN DATE, p_date_override IN VARCHAR2)
IS
l_msg varchar2(1000) := null;
l_user_rate_type varchar2(30);

BEGIN
----the following code is for fixing bug 3326023
l_user_rate_type:=get_user_rate_type(p_rate_type);
----l_msg:=substr(p_rate_type, 1,g_length_rate_type );
l_msg:=substr(l_user_rate_type, 1,g_length_rate_type );
l_msg := l_msg || substr(g_space, 1, g_length_rate_type - length(l_msg))|| g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);


l_msg:=substr(p_from_currency, 1, g_length_from_currency);
l_msg := l_msg || substr(g_space, 1, g_length_from_currency - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);


l_msg:=substr(p_to_currency, 1,g_length_to_currency );
l_msg := l_msg || substr(g_space, 1, g_length_to_currency - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);


IF (p_date_override IS NULL) THEN
	l_msg:=substr(fnd_date.date_to_displayDT(p_date), 1,g_length_date );
ELSE
	l_msg := substr(p_date_override, 1,g_length_date );
END IF;

l_msg := l_msg || substr(g_space, 1, g_length_date - length(l_msg)) || g_indenting;
fnd_file.put_line(FND_FILE.OUTPUT, l_msg);


END;






Procedure deleteLogForObject(p_object_name varchar2) IS

BEGIN
	EXECUTE IMMEDIATE 'delete from bis_refresh_log where upper(object_name)=upper(:1) and error_type is null' using p_object_name;

END;

FUNCTION getAppsSchema return VARCHAR2 IS

l_schema varchar2(100);
TYPE curtyp IS REF CURSOR;
cv              curtyp;

BEGIN

	OPEN cv for  'SELECT ORACLE_USERNAME from fnd_oracle_userid where oracle_id=900';
	FETCH cv into l_schema;
	CLOSE cv;

	return l_schema;

END;




/* Missing UOM header */

Procedure writeMissingUOMHeader
IS
l_msg varchar2(3000):=null;
BEGIN

fnd_message.set_name('BIS','BIS_DBI_UOM_OUTPUT_HDR');
l_msg := fnd_message.get;
fnd_file.put_line(FND_FILE.OUTPUT, l_msg);
fnd_file.put_line(FND_FILE.OUTPUT, '');

fnd_message.set_name('BIS','BIS_DBI_COL_FROM_UOM');
l_msg:=substr(fnd_message.get, 1, g_length_from_to_uom);
l_msg := l_msg || substr(g_space, 1, g_length_from_to_uom - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);

fnd_message.set_name('BIS','BIS_DBI_COL_TO_UOM');
l_msg:=substr(fnd_message.get, 1,g_length_from_to_uom);
l_msg := l_msg || substr(g_space, 1, g_length_from_to_uom - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);

fnd_message.set_name('BIS','BIS_DBI_COL_INVENTORY_ITEM');
l_msg:=substr(fnd_message.get, 1, g_length_inventory_item );
l_msg := l_msg || substr(g_space, 1, g_length_inventory_item - length(l_msg));
fnd_file.put_line(FND_FILE.OUTPUT, l_msg);

l_msg := substr(g_line, 1, g_length_from_to_uom)||g_indenting||
	substr(g_line, 1, g_length_from_to_uom)||g_indenting||
	substr(g_line, 1, g_length_inventory_item);

fnd_file.put_line(FND_FILE.OUTPUT, l_msg);
END;

/*
 From UOM          To UOM            Inventory Item
 ---------------   ---------------   -------------------
*/


/* Write the actual Missing UOM values */

Procedure writeMissingUOM(
		p_from_uom IN VARCHAR2,
		p_to_uom in VARCHAR2,
		p_inventory_item IN VARCHAR2)
IS
l_msg varchar2(1000) := null;
BEGIN
l_msg:=substr(p_from_uom, 1, g_length_from_to_uom);
l_msg := l_msg || substr(g_space, 1, g_length_from_to_uom - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);

l_msg:=substr(p_to_uom, 1,g_length_from_to_uom );
l_msg := l_msg || substr(g_space, 1, g_length_from_to_uom - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);

l_msg := substr(p_inventory_item, 1,g_length_inventory_item);
l_msg := l_msg || substr(g_space, 1, g_length_inventory_item - length(l_msg)) || g_indenting;
fnd_file.put_line(FND_FILE.OUTPUT, l_msg);
END;


/* Missing UOM header */

Procedure writeMissingContractHeader
IS
l_msg varchar2(3000):=null;
l_tmp varchar2(300):= null;
BEGIN

fnd_message.set_name('BIS','BIS_DBI_CONTRACT_OUTPUT_HDR');
l_msg := fnd_message.get;
fnd_file.put_line(FND_FILE.OUTPUT, l_msg);
fnd_file.put_line(FND_FILE.OUTPUT, '');

l_msg := '';
fnd_message.set_name('BIS','BIS_DBI_COL_CONTRACT_NO');
l_tmp:=substr(fnd_message.get, 1, g_length_contract_no);
l_msg := l_msg ||l_tmp|| substr(g_space, 1, g_length_contract_no - length(l_tmp)) || g_indenting;

fnd_message.set_name('BIS','BIS_DBI_COL_STATUS');
l_tmp:=substr(fnd_message.get, 1, g_length_status);
l_msg := l_msg || l_tmp||substr(g_space, 1, g_length_status - length(l_tmp)) || g_indenting;

fnd_message.set_name('BIS','BIS_DBI_COL_RATE_TYPE');
l_tmp:=substr(fnd_message.get, 1,g_length_rate_type );
l_msg := l_msg|| l_tmp||substr(g_space, 1, g_length_rate_type - length(l_tmp))||g_indenting;


fnd_message.set_name('BIS','BIS_DBI_COL_FROM_CURRENCY');
l_tmp:=substr(fnd_message.get, 1, g_length_from_currency);
l_msg := l_msg || l_tmp||substr(g_space, 1, g_length_from_currency - length(l_tmp)) || g_indenting;

fnd_message.set_name('BIS','BIS_DBI_COL_TO_CURRENCY');
l_tmp:=substr(fnd_message.get, 1,g_length_to_currency );
l_msg := l_msg ||l_tmp|| substr(g_space, 1, g_length_to_currency - length(l_tmp)) || g_indenting;

fnd_message.set_name('BIS','BIS_DBI_COL_DATE');
l_tmp:=substr(fnd_message.get, 1,g_length_date );
l_msg := l_msg ||l_tmp|| substr(g_space, 1, g_length_date - length(l_tmp)) || g_indenting;

fnd_message.set_name('BIS','BIS_DBI_COL_CONTRACT_ID');
l_tmp:=substr(fnd_message.get, 1,g_length_contract_id );
l_msg := l_msg ||l_tmp|| substr(g_space, 1, g_length_contract_id - length(l_tmp));

---fnd_file.put_line(fnd_file.LOG, 'L_MSG IS : '||l_msg);
fnd_file.put_line(FND_FILE.OUTPUT, l_msg);


l_msg := substr(g_line, 1, g_length_contract_no)||g_indenting||
	substr(g_line, 1, g_length_status)||g_indenting||
	substr(g_line, 1, g_length_rate_type)||g_indenting||
	substr(g_line, 1, g_length_from_currency)||g_indenting||
	substr(g_line, 1, g_length_to_currency)||g_indenting||
	substr(g_line, 1, g_length_date)||g_indenting||
	substr(g_line, 1, g_length_contract_id);

fnd_file.put_line(FND_FILE.OUTPUT, l_msg);
END;

/*
 From UOM          To UOM            Inventory Item
 ---------------   ---------------   -------------------
*/


/* Write the actual Missing UOM values */

Procedure writeMissingContract(
P_contract_no IN VARCHAR2,	   /* Contract Number*/
P_contract_status IN VARCHAR2,/* Contract Status*/
p_contract_id IN VARCHAR2,    /* Contract ID */
p_rate_type IN VARCHAR2,      /* Rate type */
p_from_currency IN VARCHAR2,  /* From Currency */
p_to_currency in VARCHAR2,    /* To Currency */
p_date IN DATE,               /* Date in default format */
p_date_override IN VARCHAR2)  /* Formatted date, will output this instead of p_date */
IS
l_msg varchar2(1000) := null;
l_user_rate_type varchar2(30);

BEGIN

l_msg:=substr(p_contract_no, 1, g_length_contract_no);
l_msg := l_msg || substr(g_space, 1, g_length_contract_no  - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);

l_msg:=substr(p_contract_status, 1,g_length_status );
l_msg := l_msg || substr(g_space, 1, g_length_status - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);

----the following code is for bug 4260678
l_user_rate_type:=get_user_rate_type(p_rate_type);
--l_msg:=substr(p_rate_type, 1,g_length_rate_type );
l_msg:=substr(l_user_rate_type, 1,g_length_rate_type );

l_msg := l_msg || substr(g_space, 1, g_length_rate_type - length(l_msg))|| g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);


l_msg:=substr(p_from_currency, 1, g_length_from_currency);
l_msg := l_msg || substr(g_space, 1, g_length_from_currency - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);


l_msg:=substr(p_to_currency, 1,g_length_to_currency );
l_msg := l_msg || substr(g_space, 1, g_length_to_currency - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);


IF (p_date_override IS NULL) THEN
	l_msg:=substr(fnd_date.date_to_displayDT(p_date), 1,g_length_date );
ELSE
	l_msg := substr(p_date_override, 1,g_length_date );
END IF;

l_msg := l_msg || substr(g_space, 1, g_length_date - length(l_msg)) || g_indenting;
fnd_file.put(FND_FILE.OUTPUT, l_msg);


l_msg := substr(p_contract_id, 1,g_length_contract_id);
l_msg := l_msg || substr(g_space, 1, g_length_contract_id - length(l_msg)) || g_indenting;
fnd_file.put_line(FND_FILE.OUTPUT, l_msg);
END;

/*
 *  Added for enhancement 3183157
 */
function get_last_failure_period(p_object_name in varchar2) return varchar2 is
l_date  date;
l_date_disp varchar2(100);
l_proc VARCHAR2(100) := 'BIS.BIS_COLLECTION_UTILITIES.get_last_failure_period';
begin
    SELECT MAX(period_to) INTO l_date
    FROM bis_refresh_log
    WHERE  object_name = p_object_name AND
           status='FAILURE' AND
           last_update_date = (
             SELECT MAX(last_update_date)
             FROM bis_refresh_log
             WHERE object_name= p_object_name AND
                   status='FAILURE' ) ;
    IF (l_date IS NULL) THEN
      l_date:= to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'), 'mm/dd/yyyy');
    END IF;
    l_date_disp := fnd_date.date_to_displaydt (l_date);
    return l_date_disp;
    Exception WHEN OTHERS THEN
      /*Generic Exception Handling block.*/
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      fnd_message.set_token('ROUTINE', l_proc);
      put_line(fnd_message.get, fnd_log.LEVEL_UNEXPECTED);
RAISE;
end get_last_failure_period;

/*
 *  Overloaded get_last_failure_period for bug#4365064 to have 2 OUT params
 *  1. p_period_from
 *  2. p_period_to
 */
PROCEDURE get_last_failure_period(
  p_object_name in varchar2,
  p_period_from OUT NOCOPY varchar2,
  p_period_to   OUT NOCOPY varchar2
  ) is
l_date_from  date;
l_date_to  date;

l_proc VARCHAR2(100) := 'BIS.BIS_COLLECTION_UTILITIES.get_last_failure_period';
begin
    SELECT period_to, period_from INTO l_date_to,l_date_from
    FROM bis_refresh_log
    WHERE  object_name = p_object_name AND
           status='FAILURE' AND
           last_update_date = (
             SELECT MAX(last_update_date)
             FROM bis_refresh_log
             WHERE object_name= p_object_name AND
                   status='FAILURE' )AND
		rownum = 1
    ORDER BY period_to desc ;
    IF (l_date_to IS NULL) THEN
      l_date_to:= to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'), 'mm/dd/yyyy');
    END IF;
    IF (l_date_from IS NULL) THEN
      l_date_from:= to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'), 'mm/dd/yyyy');
    END IF;
    p_period_to := fnd_date.date_to_displaydt (l_date_to);
    p_period_from := fnd_date.date_to_displaydt (l_date_from);
    Exception WHEN OTHERS THEN
      /*Generic Exception Handling block.*/
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      fnd_message.set_token('ROUTINE', l_proc);
      put_line(fnd_message.get, fnd_log.LEVEL_UNEXPECTED);
      RAISE;
end get_last_failure_period;

END BIS_COLLECTION_UTILITIES;

/
