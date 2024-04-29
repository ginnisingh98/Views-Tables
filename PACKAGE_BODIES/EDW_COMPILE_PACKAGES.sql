--------------------------------------------------------
--  DDL for Package Body EDW_COMPILE_PACKAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_COMPILE_PACKAGES" AS
/* $Header: EDWCMPLB.pls 115.5 2003/09/16 07:22:37 smulye noship $ */

newline varchar2(10) := '
';

Procedure compile_packages(errbuf in varchar2, retcode in number,
	p_expr in varchar2 default null) IS

l_package varchar2(50);
l_stmt varchar2(100):= ' ALTER PACKAGE :S1 COMPILE';
l_dir varchar2(100);
l_expr varchar2(100);
cursor c_packages(p_type varchar2) is
SELECT distinct object_name from user_objects
where object_type = p_type and status = 'INVALID'
and object_name like l_expr;

BEGIN

   execute immediate 'alter session set global_names=false';

   IF (p_expr is null) THEN
	l_expr := '%';
   ELSE
	l_expr := p_expr;
   END IF;

   /*l_dir:=fnd_profile.value('EDW_LOGFILE_DIR');
   IF l_dir is null THEN
     l_dir:='/sqlcom/log';
   END IF;*/

   l_dir := fnd_profile.value('UTL_FILE_LOG');
	if l_dir is  null  then
	   l_dir := fnd_profile.value('EDW_LOGFILE_DIR');
	     if l_dir is  null  then
	         l_dir:='/sqlcom/log';
	     end if;
	 end if;

	edw_log.put_names('validate.log', 'validate.out',l_dir);
	edw_log.put_line( 'Checking for invalid package specifications...');


	OPEN c_packages('PACKAGE');
	LOOP


		fetch c_packages into l_package;
		EXIT WHEN c_packages%NOTFOUND;

		edw_log.put_line( newline||'Package spec '||l_package||' is invalid');
		BEGIN
		execute immediate 'alter package '||l_package||' compile ';
		edw_log.put_line( '   Recompiled package spec '||l_package);

		EXCEPTION WHEN OTHERS THEN
			edw_log.put_line( 'Error occurred while recompiling spec for '||l_package );
			edw_log.put_line('Error is : '||sqlerrm);
			null;
		END;

	END LOOP;
	CLOSE c_packages;

	edw_log.put_line(  '');edw_log.put_line(  '');
	edw_log.put_line( 'Checking for invalid package bodies...'||newline||newline);


	OPEN c_packages('PACKAGE BODY');
	LOOP

		fetch c_packages into l_package;
		EXIT WHEN c_packages%NOTFOUND;
		edw_log.put_line( newline||'Package body '||l_package||' is invalid');
		BEGIN
		execute immediate 'ALTER PACKAGE '||l_package||' COMPILE BODY';
		edw_log.put_line( '    Recompiled package body '||l_package);
		EXCEPTION WHEN OTHERS THEN
			edw_log.put_line( 'Error occurred while recompiling body for '||l_package );
			edw_log.put_line('Error is : '||sqlerrm);
			null;
		END;
	END LOOP;

	CLOSE c_packages;


END;

end edw_compile_packages;

/
