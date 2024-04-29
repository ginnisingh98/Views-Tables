--------------------------------------------------------
--  DDL for Package Body FA_RX_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RX_REPORTS_PKG" as
/* $Header: faxrxdmb.pls 120.7.12010000.2 2009/07/19 13:12:02 glchen ship $ */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Report_Id                      NUMBER   default null,
                       X_Application_Id                 NUMBER   default null,
                       X_Responsibility_Id		NUMBER   default null,
                       X_Concurrent_Program_Id          NUMBER   default null,
		       X_Concurrent_Program_Name	VARCHAR2 default null,
                       X_Interface_Table		VARCHAR2 default null,
                       X_Concurrent_Program_Flag	VARCHAR2 default null,
                       X_Select_Program_Name		VARCHAR2 default null,
                       X_Last_Update_Date               DATE     default null,
                       X_Last_Updated_By                NUMBER   default null,
                       X_Created_By                     NUMBER   default null,
                       X_Creation_Date                  DATE     default null,
                       X_Last_Update_Login              NUMBER   default null,
                       X_Where_Clause_API		VARCHAR2 default null,
                       X_Purge_API			VARCHAR2 default null,
		       X_Calling_Fn			VARCHAR2
  ) IS
temp_var   varchar2(1);
ver_num	   number := 1;  /* default value */
x_max_report_id number;
x_curr_report_id_s number;
dummy number;

 CURSOR C IS SELECT rowid FROM fa_rx_reports
                 WHERE report_id = X_Report_Id;

   BEGIN

       INSERT INTO fa_rx_reports(
	report_id,
	application_id,
	responsibility_id,
	concurrent_program_id,
        concurrent_program_name,
	concurrent_program_flag,
	interface_table,
	select_program_name,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        last_update_login,
	where_clause_api,
	purge_api,
	version_number
             ) VALUES (
	X_report_id,
	X_application_id,
	X_responsibility_id,
	X_concurrent_program_id,
        X_concurrent_program_name,
	X_concurrent_program_flag,
	X_interface_table,
	decode(X_concurrent_program_flag,'N',X_select_program_name,null),
        X_Last_Update_Date,
        X_Last_Updated_By,
        X_Created_By,
        X_Creation_Date,
        X_Last_Update_Login,
	X_Where_Clause_API,
	X_Purge_API,
        ver_num
             );

   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
     CLOSE C;
     Raise NO_DATA_FOUND;
   end if;
   CLOSE C;

   select max(report_id) into x_max_report_id from fa_rx_reports;
   declare
     seq_no_curr exception;
     pragma exception_init(seq_no_curr, -8002);
   begin
     select fa_rx_reports_s.currval into x_curr_report_id_s from dual;
   exception
   when seq_no_curr then
     select fa_rx_reports_s.nextval into x_curr_report_id_s from dual;
   end;
   for i in x_curr_report_id_s .. x_max_report_id loop
	select fa_rx_reports_s.nextval into dummy from dual;
   end loop;

--  EXCEPTION
--	WHEN Others THEN
--		FA_STANDARD_PKG.RAISE_ERROR
--			(Called_Fn	=> 'FA_RX_REPORTS_PKG.Insert_Row',
-- 			Calling_Fn	=> X_Calling_Fn);
  END Insert_Row;
  --
PROCEDURE Lock_Row(X_Rowid			IN OUT NOCOPY  VARCHAR2,
                   X_Report_Id                          NUMBER   default null,
                   X_Application_Id                     NUMBER   default null,
		   X_Responsibility_Id		        NUMBER   default null,
                   X_Concurrent_Program_Id              NUMBER   default null,
		   X_Concurrent_Program_Flag		VARCHAR2 default null,
		   X_Select_Program_Name		VARCHAR2 default null,
                   X_Interface_Table                    VARCHAR2 default null,
                   X_Where_Clause_API		        VARCHAR2 default null,
                   X_Purge_API                          VARCHAR2 default null,
	           X_Calling_Fn			        VARCHAR2
  ) IS
 cursor c_reports is
 SELECT *
 FROM FA_RX_REPORTS
 WHERE ROWID = X_ROWID
 FOR UPDATE OF REPORT_ID NOWAIT;
 Recinfo c_reports%rowtype;

Begin
 Open c_reports;
 Fetch c_reports into recinfo;
 IF (c_reports%notfound) then
   close c_reports;
   fnd_message.set_name('FND','FORM_RECORD_DELETED');
   app_exception.raise_exception;

 End if;
 Close c_reports;
--
    if (
       (recinfo.report_id = X_report_id)
   AND (recinfo.application_id = X_application_id)
   AND (nvl(recinfo.concurrent_program_id,nvl(X_concurrent_program_id,-9999))
		 = nvl(X_concurrent_program_id,-9999))
   AND (recinfo.interface_table = X_interface_table)
   AND (recinfo.concurrent_program_flag = X_concurrent_program_flag)
   AND (nvl(recinfo.select_program_name,
		nvl(X_select_program_name,'-9999'))
		= nvl(X_select_program_name,'-9999'))
   AND (nvl(recinfo.responsibility_id,nvl(X_responsibility_id,-9999))
		= nvl(X_responsibility_id,-9999))
   AND (nvl(recinfo.where_clause_api,
                nvl(X_Where_Clause_API,'-9999'))
                = nvl(X_Where_Clause_API,'-9999'))
   AND (nvl(recinfo.purge_api,
                nvl(X_Purge_API,'-9999'))
                = nvl(X_Purge_API,'-9999'))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
	  	       X_Report_Id                      NUMBER   default null,
                       X_Application_Id                 NUMBER   default null,
                       X_Responsibility_Id		NUMBER   default null,
                       X_Concurrent_Program_Id          NUMBER   default null,
		       X_Concurrent_Program_Name	VARCHAR2 default null,
                       X_Interface_Table                VARCHAR2 default null,
                       X_Concurrent_Program_Flag	VARCHAR2 default null,
                       X_Select_Program_Name		VARCHAR2 default null,
                       X_Last_Update_Date               DATE     default null,
                       X_Last_Updated_By                NUMBER   default null,
                       X_Last_Update_Login              NUMBER   default null,
                       X_Where_Clause_API		VARCHAR2 default null,
                       X_Purge_API                      VARCHAR2 default null,
		       X_Calling_Fn			VARCHAR2
  ) IS

  h_sel_program_name   varchar2(240);
  BEGIN


   if (X_concurrent_program_flag = 'N') then
	h_sel_program_name := X_select_program_name;
   else h_sel_program_name := null;
   end if;


    if X_Rowid is not null then

     UPDATE fa_rx_reports
     SET
	Application_Id          = X_Application_Id,
	Responsibility_Id       = X_Responsibility_Id,
        Concurrent_Program_Id   = X_Concurrent_Program_Id,
	Concurrent_Program_Name = X_Concurrent_Program_Name,
	Interface_Table         = X_Interface_Table ,
	Concurrent_Program_Flag = X_Concurrent_Program_Flag,
	Select_Program_Name     = h_sel_program_name,
	Last_Update_Date        = X_Last_Update_Date ,
        Last_Updated_By	        = X_Last_Updated_By,
	Last_Update_Login       = X_Last_Update_Login,
	Where_Clause_API        = X_Where_Clause_API,
	Purge_API               = X_Purge_API
     WHERE rowid = X_Rowid;
    else

     UPDATE fa_rx_reports
     SET
	Application_Id          = X_Application_Id,
	Responsibility_Id       = X_Responsibility_Id,
        Concurrent_Program_Id   = X_Concurrent_Program_Id,
	Concurrent_Program_Name = X_Concurrent_Program_Name,
	Interface_Table         = X_Interface_Table ,
	Concurrent_Program_Flag = X_Concurrent_Program_Flag,
	Select_Program_Name     = h_sel_program_name,
	Last_Update_Date        = X_Last_Update_Date ,
        Last_Updated_By	        = X_Last_Updated_By,
	Last_Update_Login       = X_Last_Update_Login,
	Where_Clause_API        = X_Where_Clause_API,
	Purge_API		= X_Purge_API
     WHERE report_id = x_report_id;
    end if;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
--  EXCEPTION
--	WHEN Others THEN
--		FA_STANDARD_PKG.RAISE_ERROR
--			(Called_Fn	=> 'FA_RX_REPORTS_PKG.Update_Row',
--			Calling_Fn	=> X_Calling_Fn);
  END Update_Row;
  --
  PROCEDURE Delete_Row(X_Rowid 		VARCHAR2 default null,
		       X_Report_id	NUMBER,
                       X_Calling_Fn	VARCHAR2) IS
  BEGIN
    if X_Rowid is not null then
    	DELETE FROM fa_rx_reports
    	WHERE rowid = X_Rowid;
    elsif X_Report_Id is not null then
	DELETE FROM fa_rx_reports
	WHERE report_id = X_report_id;
    else
	-- error
	null;
    end if;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
	WHEN Others THEN
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn	=> 'FA_RX_REPORTS_PKG.Delete_Row',
			Calling_Fn	=> X_Calling_Fn);
  END Delete_Row;

  PROCEDURE Load_Row(
                   X_Report_Id                          NUMBER   default null,
                   X_Application_Name                   VARCHAR2 default null,
		   X_Responsibility_Id			NUMBER   default null,
                   X_Concurrent_Program_Name            VARCHAR2 default null,
		   X_Concurrent_Program_Flag		VARCHAR2 default null,
		   X_Select_Program_Name		VARCHAR2 default null,
                   X_Interface_Table                    VARCHAR2 default null,
                   X_Where_Clause_API			VARCHAR2 default null,
                   X_Purge_API                          VARCHAR2 default null,
		   X_Owner                              VARCHAR2 default 'SEED')
  is
  Begin
          Load_Row(X_Report_Id               ,
                   X_Application_Name        ,
		   X_Responsibility_Id	,
                   X_Concurrent_Program_Name ,
		   X_Concurrent_Program_Flag,
		   X_Select_Program_Name	,
                   X_Interface_Table             ,
                   X_Where_Clause_API		,
                   X_Purge_API                   ,
		   X_Owner                        ,
		   Null,
		   Null);
  End;

  PROCEDURE Load_Row(
                   X_Report_Id                          NUMBER   default null,
                   X_Application_Name                   VARCHAR2 default null,
		   X_Responsibility_Id			NUMBER   default null,
                   X_Concurrent_Program_Name            VARCHAR2 default null,
		   X_Concurrent_Program_Flag		VARCHAR2 default null,
		   X_Select_Program_Name		VARCHAR2 default null,
                   X_Interface_Table                    VARCHAR2 default null,
                   X_Where_Clause_API			VARCHAR2 default null,
                   X_Purge_API                          VARCHAR2 default null,
		   X_Owner                              VARCHAR2 default 'SEED',
		   X_Last_Update_Date                   VARCHAR2,
		   X_CUSTOM_MODE in VARCHAR2
		   )
  Is
		x_userid number;
		x_rowid varchar2(64);
		x_concurrent_program_id number;
		x_application_id number;

--* Bug#5102292, rravunny
--* Begin
--*
		f_luby number;  -- entity owner in file
		f_ludate date;  -- entity update date in file
		db_luby number; -- entity owner in db
		db_ludate date; -- entity update date in db
--* End
--*

  Begin
	select application_id into x_application_id
	from fnd_application
	where application_short_name = X_Application_Name;

	if x_concurrent_program_flag = 'N' then
		x_concurrent_program_id := null;
	else
		begin
		   select concurrent_program_id
		   into   x_concurrent_program_id
		   from   fnd_concurrent_programs
		   where  application_id = x_application_id
		   and    concurrent_program_name = x_concurrent_program_name;
		exception
		   when no_data_found then
		      x_concurrent_program_id := NULL;
		end;
	end if;

--* Bug#5102292, rravunny
--* Begin
--*
	f_luby := fnd_load_util.owner_id(X_Owner);

	-- Translate char last_update_date to date
	f_ludate := nvl(to_date(X_Last_Update_Date, 'YYYY/MM/DD HH24:MI:SS'), sysdate);

	select	LAST_UPDATED_BY, LAST_UPDATE_DATE
	into	db_luby, db_ludate
	from	fa_rx_reports
	where	report_id = X_Report_Id;
--* End
--*

	x_userid := f_luby;

	If (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE)) Then
		update_row(
			X_Rowid                   =>	null,
			X_Report_Id               =>	X_Report_Id,
			X_Application_Id          =>	X_Application_Id,
			X_Responsibility_Id       =>	X_Responsibility_Id,
			X_Concurrent_Program_Id   =>	X_Concurrent_Program_Id,
			X_Concurrent_Program_Name =>	X_Concurrent_Program_Name,
			X_Interface_Table         =>	X_Interface_Table,
			X_Concurrent_Program_Flag =>	X_Concurrent_Program_Flag,
			X_Select_Program_Name     =>    X_Select_Program_Name,
			X_Last_Update_Date        =>	f_ludate,
			X_Last_Updated_By         =>	f_luby,
			X_Last_Update_Login       =>	0,
			X_Where_Clause_API        =>	X_Where_Clause_API,
			X_Purge_API               =>	X_Purge_API,
			X_Calling_Fn =>			'Load_Row');
	End If;
    exception
    when NO_DATA_FOUND then
	insert_row(
		X_Rowid                   =>	X_Rowid,
		X_Report_Id               =>	X_Report_Id,
		X_Application_Id          =>	X_Application_Id,
		X_Responsibility_Id       =>	X_Responsibility_Id,
		X_Concurrent_Program_Id   =>	X_Concurrent_Program_Id,
		X_Concurrent_Program_Name =>	X_Concurrent_Program_Name,
		X_Interface_Table         =>	X_Interface_Table,
		X_Concurrent_Program_Flag =>	X_Concurrent_Program_Flag,
		X_Select_Program_Name     =>	X_Select_Program_Name,
		X_Last_Update_Date        =>	f_ludate,
		X_Last_Updated_By         =>	f_luby,
		X_Created_By              =>	f_luby,
		X_Creation_Date           =>	f_ludate,
		X_Last_Update_Login       =>	0,
		X_Where_Clause_API        =>	X_Where_Clause_API,
		X_Purge_API               =>	X_Purge_API,
		X_Calling_Fn              =>	'Load_Row');

  end Load_Row;

  FUNCTION validate_plsql_block(p_plsql IN VARCHAR2) return BOOLEAN is
  l_cursor	integer;
  dummy		varchar2(80);
  plsql_block   varchar2(200);

  Begin
  --
  if (g_print_debug) then
     arp_util_tax.debug('fa_rx_reports_pkg.validate_plsql_block(+)');
  end if;
  --
  IF p_plsql IS not null THEN
     if (g_print_debug) then
        arp_util_tax.debug(p_plsql);
     end if;

     BEGIN
        plsql_block := 'BEGIN :dummy := ' || p_plsql ||'(0); end;';
        execute immediate plsql_block using out dummy;

  EXCEPTION
      WHEN OTHERS THEN
        if (g_print_debug) then
           arp_util_tax.debug('Invalid Where Clause API/Purge API.');
        end if;

  	return FALSE;
  END;
  end if;

  if (g_print_debug) then
     arp_util_tax.debug('fa_rx_reports_pkg.validate_plsql_block(-)');
  end if;

  return TRUE;
  End;

END FA_RX_REPORTS_PKG;

/
