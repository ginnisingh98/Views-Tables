--------------------------------------------------------
--  DDL for Package Body EDR_INDEXED_XML_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_INDEXED_XML_UTIL" as
/* $Header: EDRGIXEB.pls 120.0.12000000.1 2007/01/18 05:53:31 appldev ship $ */

-- Bug 3196897: new site-level no-user-access profile name
G_PROFILE_SYNC_TIME  CONSTANT varchar2(100) := 'EDR_INDEX_SYNC_TIME';

procedure CREATE_INDEX(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2)
IS

cursor c1 is
select index_section_name, index_tag, status
from edr_idx_xml_element_vl;

l_section_name varchar2(30);
l_tag varchar2(64);
l_status char(1);
l_str varchar2(1000);
l_time_str    varchar2(30);

no_ctx_object EXCEPTION;
PRAGMA EXCEPTION_INIT(no_ctx_object, -20000);

no_index EXCEPTION;
PRAGMA EXCEPTION_INIT(no_index, -01418);

begin
	begin
		l_str:= 'drop index edr_psig_textindex';
	      execute immediate l_str;
		fnd_file.put_line(FND_FILE.LOG,'Index dropped for refresh');
	exception
	when no_index then
		fnd_file.put_line(FND_FILE.LOG,'Index does not exist. Creating index for the first time.');
	end;

	begin
		Ctx_Ddl.Drop_Section_Group
		  ( group_name => 'edr_section_group'
		  );
		fnd_file.put_line(FND_FILE.LOG,'Section group dropped for refresh');
	exception
	when no_ctx_object then
		fnd_file.put_line(FND_FILE.LOG,'Section group does not exist');
	end;

	begin
		ctx_ddl.drop_preference('edrlex');
		fnd_file.put_line(FND_FILE.LOG,'Lexer preference dropped');
	exception
	when no_ctx_object then
		fnd_file.put_line(FND_FILE.LOG,'Lexer preference does not exist.');
	end;

	Ctx_Ddl.Create_Section_Group
	  (group_name => 'edr_section_group',
	   group_type => 'xml_section_group');
	fnd_file.put_line(FND_FILE.LOG,'Section group created ');

	ctx_ddl.create_preference('edrlex','BASIC_LEXER');

	--Bug 2783886: Start
	--added .?_! as printjoin attributes
	ctx_ddl.set_attribute('edrlex','printjoins','{},&?\()[]-;~|$!>*=.?_!');
	--ctx_ddl.set_attribute('edrlex','printjoins','{},&?\()[]-;~|$!>*=');

        --add the prefix index attribute to the basic wordlist so that
        --performance of the right wild card % queries improves
        --FYI we are now putting a wild card at the end of ALL queries

	begin
		ctx_ddl.drop_preference('edrwordlist');
		fnd_file.put_line(FND_FILE.LOG,'Wordlist preference dropped');
	exception
	when no_ctx_object then
		fnd_file.put_line(FND_FILE.LOG,'Wordlist preference does not exist.');
	end;

        ctx_ddl.create_preference('edrwordlist', 'BASIC_WORDLIST');
        ctx_ddl.set_attribute('edrwordlist','PREFIX_INDEX','YES');
        ctx_ddl.set_attribute('edrwordlist','PREFIX_MIN_LENGTH',1);
        ctx_ddl.set_attribute('edrwordlist','PREFIX_MAX_LENGTH', 64);

	--Bug 2783886: End

	fnd_file.put_line(FND_FILE.LOG,'Lexer preference created');
	open c1;
	loop
		fetch c1 into l_section_name, l_tag, l_status;
		exit when c1%notfound;
		if (l_status = 'N') then
			update edr_idx_xml_element_b set status = 'I' where index_tag = l_tag;
			fnd_file.put_line(FND_FILE.LOG,'Activated section: '||l_section_name);
		end if;
		Ctx_Ddl.Add_zone_Section
		(group_name   =>'edr_section_group',
		 section_name =>l_section_name,
		 tag          =>l_tag
		);
		fnd_file.put_line(FND_FILE.LOG,'Created section: '||l_section_name);
	end loop;
	close c1;

	fnd_file.put_line(FND_FILE.LOG,'Sections created for indexed xml elements');

	l_str:= 'create index edr_psig_textindex on edr_psig_documents(psig_xml) '||
	'indextype is ctxsys.context parameters '||
	'(''LEXER edrlex FILTER ctxsys.null_filter SECTION GROUP edr_section_group'')';

      execute immediate l_str;
	fnd_file.put_line(FND_FILE.LOG,'Index created successfully');

       commit;

       -- Bug 3196897: start:
        l_time_str := fnd_date.Date_To_DisplayDT(sysdate, fnd_timezones.Get_Server_Timezone_Code);
        fnd_message.set_name( 'EDR', 'EDR_PLS_IXE_BUILD_END' );
        fnd_message.set_token( 'FINISH_TIME', l_time_str );
        fnd_file.put_line( FND_FILE.LOG, fnd_message.get );

        -- note: fnd_profile.defined( NAME ) return false if profile exist with no value
        -- note: if profile not exist, fnd_profile.Save() will fail and return false
        IF  fnd_profile.Save( G_PROFILE_SYNC_TIME, l_time_str, 'SITE' )  THEN
          commit;          -- need commit for the profile to take immediate effect
        ELSE
          fnd_message.set_name( 'EDR', 'EDR_GENERAL_UPDATE_FAIL' );
          fnd_message.set_token( 'OBJECT_NAME', G_PROFILE_SYNC_TIME );
          fnd_file.put_line( FND_FILE.LOG, fnd_message.get );
        END IF;
        -- Bug 3196897: end:

exception
	when OTHERS then
		rollback;
    		fnd_file.put_line(FND_FILE.LOG,'An error occured with the following error message. '||
					   'Please rerun the job after correcting the cause of error');
    		fnd_file.put_line(FND_FILE.LOG,SQLERRM(SQLCODE));

END CREATE_INDEX;


-- 2979172 start: need new procedures to sync/optimize index
-- Procedure: Synchronize_Index
-- In Param :
-- Function : use ctx_ddl.sync_index to do the work scheduled by concurrent manager

PROCEDURE Synchronize_Index (
	ERRBUF		OUT 	NOCOPY VARCHAR2,
	RETCODE		OUT 	NOCOPY NUMBER	)
IS
  l_syn_id   NUMBER;
  l_time_str    varchar2(30);

BEGIN

  fnd_message.set_name('EDR', 'EDR_PLS_IXE_SYNC_START');
  fnd_message.set_token('XML_INDEX', 'EDR_PSIG_TEXTINDEX');
  fnd_file.put_line( FND_FILE.LOG, fnd_message.get );

  ctx_ddl.sync_index ( 'EDR_PSIG_TEXTINDEX' );

  -- Bug 3196897: start:
  l_time_str := fnd_date.Date_To_DisplayDT(sysdate, fnd_timezones.Get_Server_Timezone_Code);
  fnd_message.set_name( 'EDR', 'EDR_PLS_IXE_SYNC_END' );
  fnd_message.set_token( 'FINISH_TIME', l_time_str );
  fnd_file.put_line( FND_FILE.LOG, fnd_message.get );

  -- note: fnd_profile.defined( NAME ) return false if profile exist with no value
  -- note: if profile not exist, fnd_profile.Save() will fail and return false
  IF  fnd_profile.Save( G_PROFILE_SYNC_TIME, l_time_str, 'SITE' )  THEN
    commit;    -- need commit to take immediate effect
  ELSE
    fnd_message.set_name( 'EDR', 'EDR_GENERAL_UPDATE_FAIL' );
    fnd_message.set_token( 'OBJECT_NAME', G_PROFILE_SYNC_TIME );
    fnd_file.put_line( FND_FILE.LOG, fnd_message.get );
  END IF;
  -- Bug 3196897: end:

EXCEPTION
when others then
 	errbuf := substr(sqlerrm, 1, 240);
 	retcode := 2;
END Synchronize_Index;


-- Procedure: Optimize_Index    the Concurrent Program defines/uses value set for p_optimize_level
-- In Param : p_optimize_level	'FAST' for defragmentation only
--				'FULL' does both defragmentation and garbage collection
--	      p_duration	number of minutes for the duration of running one optimization
--				next time the optimization will continue what's left last time
-- Function : use ctx_ddl.sync_index to do the work scheduled by concurrent manager

PROCEDURE Optimize_Index (
	ERRBUF		OUT 	NOCOPY VARCHAR2,
	RETCODE		OUT 	NOCOPY NUMBER,
	p_optimize_level IN  	VARCHAR2,
       	p_duration 	IN  	NUMBER     	)
IS
  l_opt_level	VARCHAR2(20);
  l_maxtime  NUMBER;

BEGIN
  -- check the valid parameter for optimization level
  IF p_optimize_level is null THEN
	l_opt_level := ctx_ddl.optlevel_full;
  ELSIF upper(p_optimize_level) not in ('FAST','FULL') then
      	fnd_message.set_name( 'EDR', 'EDR_PLS_PARAM_INVALID' );
      	fnd_message.set_token( 'PLSPROC', 'EDR_INDEXED_XML_UTIL.Optimize_Index' );
      	fnd_message.set_token( 'PARAM', 'p_optimize_level' );
      	fnd_message.set_token( 'VALUE', p_optimize_level );
    	raise_application_error(-20000, fnd_message.get);
  ELSE  l_opt_level := p_optimize_level;
  END IF;
  fnd_message.set_name('EDR', 'EDR_PLS_IXE_OPTIM_LEVEL');
  fnd_message.set_token('XML_INDEX', 'EDR_PSIG_TEXTINDEX');
  fnd_message.set_token('IXE_OPT_LEVEL', l_opt_level );
  fnd_file.put_line( FND_FILE.LOG, fnd_message.get );

  -- check the valid parameter for the time spent in each running of optimization
  IF p_duration is null THEN
	l_maxtime := ctx_ddl.maxtime_unlimited;
  ELSE
    	IF trunc(p_duration) <> p_duration  or  p_duration < 0
          or p_duration > ctx_ddl.maxtime_unlimited  THEN
      		fnd_message.set_name( 'EDR', 'EDR_PLS_PARAM_INVALID' );
      		fnd_message.set_token( 'PLSPROC', 'EDR_INDEXED_XML_UTIL.Optimize_Index' );
      		fnd_message.set_token( 'PARAM', 'p_duration' );
      		fnd_message.set_token( 'VALUE', p_duration );
      		Raise_application_error(-20000, fnd_message.get);
    	END IF;
  END IF;

  IF p_optimize_level = 'FAST' THEN
    	l_maxtime := null;
  ELSE
   	IF p_duration IS NULL  THEN
    		l_maxtime := ctx_ddl.maxtime_unlimited;
   	ELSE
        	l_maxtime := trunc( p_duration );
   	END IF;
  END IF;
  IF l_maxtime is not null THEN
    fnd_message.set_name('EDR', 'EDR_PLS_IXE_OPTIM_TIME');
    fnd_message.set_token('XML_INDEX', 'EDR_PSIG_TEXTINDEX');
    fnd_message.set_token('IXE_OPT_TIME', l_maxtime );
    fnd_file.put_line( FND_FILE.LOG, fnd_message.get );
  END IF;

  ctx_ddl.optimize_index( 'EDR_PSIG_TEXTINDEX', l_opt_level, l_maxtime );
  fnd_message.set_name('EDR', 'EDR_PLS_IXE_OPTIM_END');
  fnd_message.set_token('XML_INDEX', 'EDR_PSIG_TEXTINDEX');
  fnd_file.put_line( FND_FILE.LOG, fnd_message.get );

EXCEPTION
  when others then
 	errbuf := substr(sqlerrm, 1, 240);
 	retcode := 2;
END Optimize_Index;
-- 2979172 end: these procedures are used in concurrent program


FUNCTION GET_WF_PARAMS(p_param_name IN varchar2, p_event_guid IN RAW) return varchar2 as
     l_str varchar2(4000);
     l_param_value varchar2(320);
BEGIN
     l_param_value := wf_event_functions_pkg.SUBSCRIPTIONPARAMETERS(l_str,p_param_name,p_event_guid);
     return l_param_value;
END GET_WF_PARAMS;

end EDR_INDEXED_XML_UTIL;

/
