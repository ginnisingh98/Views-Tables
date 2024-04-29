--------------------------------------------------------
--  DDL for Package Body WF_BES_FUNCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_BES_FUNCS" as
/* $Header: WFBESFNB.pls 120.3 2006/07/21 14:35:44 nravindr noship $ */

   --Directory where the generated files will be stored
   utl_dir  varchar2(512);
   g_amp varchar2(1):='&';

   --Function to get the list of items from a comma separated string
   FUNCTION Tokenize(cslist VARCHAR2) return varchar_array;

   --
   -- Procedure : GenerateStatic
   --
   -- Purpose   : Main Procedure which will be called by the admin script/
   --             concurrent program. Depending on the value in p_key,
   --             the files for the corresponding packages are generated
   --
   -- Parameters: retcode - used by the concurrent program
   --             errbuf  - used by the concurrent program
   --             p_object_type  - used by the concurrent program
   --             p_key  -  comma separated string of the
   --                       correlationid/agent name
   --
   Procedure GenerateStatic(retcode out nocopy varchar2,
	                    errbuf   out nocopy varchar2,
                            p_object_type in varchar2,
	 		    p_key    in varchar2) AS

     l_var_list varchar_array;

     l_key varchar2(512);

     begin
        --Get the directory where the output file is to be generated
        select value
	into utl_dir
	from v$parameter
	where name = 'utl_file_dir';

        --The value can be a comma separeated list, So take the first location and
        --use that as the output directory.
        if(instr(utl_dir, ',') <> 0) then
            utl_dir:=trim(substr(utl_dir,1,instr(utl_dir,',')-1));
        else
            utl_dir:=trim(utl_dir);
        end if;

        l_key:=upper(trim(p_key));
        if(upper(p_object_type)='EVENTS') then

           --check if the default wf and fnd packages are included
           --if it is not there, then add it.
           if(instr(l_key,'ORACLE.APPS.WF.')=0) then
              l_key:=l_key||',ORACLE.APPS.WF.';
           end if;
           if(instr(l_key,'ORACLE.APPS.FND.')=0) then
              l_key:=l_key||',ORACLE.APPS.FND.';
           end if;
           WF_BES_FUNCS.StaticGenerateRule(Tokenize(l_key));

        elsif(upper(p_object_type)='AGENTS') then

           WF_BES_FUNCS.StaticQH(Tokenize(l_key));

	end if;
      end;

   --
   -- Procedure : StaticQH
   --
   -- Purpose   : Procedure to generate the static Enqueue/Dequeue
   --             procedures
   --
   Procedure StaticQH(p_agent_names in varchar_array) AS

     fh            utl_file.file_type;
     l_generated   boolean := FALSE;
     l_atleast_one boolean;
     l_first       boolean;

     l_mesg        varchar2(4000);
     l_timestamp varchar2(20);

     cursor all_Queue_handlers(p_agent_name in varchar2) is
     select distinct upper(trim(v.queue_handler)) qhandler
     from (
           select queue_handler
           from  wf_agents
           where  queue_handler is not null and
           instr(upper(name),p_agent_name)=1
      )v, user_objects uo
     where uo.object_name = v.queue_handler
     and   uo.object_type = 'PACKAGE BODY'
     and   uo.status = 'VALID';

     l_filename  varchar2(100);

   Begin

     select to_char(sysdate,'DDMONYYYYHH24MISS')
     into l_timestamp
     from dual;

     l_filename := 'WFAGTDFNB'||l_timestamp||'.pls';

     fh := utl_file.fopen(utl_dir, l_filename, 'w', 32767);

     utl_file.put_line(fh, 'REM dbdrv: sql ~PROD ~PATH ~FILE none none none package '||g_amp||'phase=plb \');
     utl_file.put_line(fh, 'REM dbdrv: checkfile(115.2=120.3):~PROD:~PATH:~FILE');
     utl_file.put_line(fh, '/*=======================================================================*');
     utl_file.put_line(fh, '| Copyright (c) 2005, Oracle. All Rights Reserved                        |');
     utl_file.put_line(fh, '+========================================================================+');
     utl_file.put_line(fh, '| NAME                                                                   |');
     utl_file.put_line(fh, '|   WFAGTDFNB'||l_timestamp||'.pls                                       |');
     utl_file.put_line(fh, '|                                                                        |');
     utl_file.put_line(fh, '| DESCRIPTION                                                            |');
     utl_file.put_line(fh, '|   This is a generated file to provide static calls for                 |');
     utl_file.put_line(fh, '|   Enqueue/Dequeue functions.                                           |');
     utl_file.put_line(fh, '|                                                                        |');
     utl_file.put_line(fh, '*========================================================================*/ ');
     utl_file.put_line(fh,'SET VERIFY OFF;');
     utl_file.put_line(fh,'WHENEVER SQLERROR EXIT FAILURE ROLLBACK;');
     utl_file.put_line(fh,'WHENEVER OSERROR EXIT FAILURE ROLLBACK;');

     utl_file.put_line(fh,'create or replace package body WF_AGT_DYN_FUNCS as');

     utl_file.put_line(fh,'');
     utl_file.put_line(fh,'--');
     utl_file.put_line(fh,'-- Static enqueue procedure calls ');
     utl_file.put_line(fh,'--');
     utl_file.put_line(fh,'PROCEDURE StaticEnqueue(p_qh_name    in  varchar2,');
     utl_file.put_line(fh,'                        p_event      in wf_event_t,');
     utl_file.put_line(fh,'                        p_out_agent_override in  wf_agent_t,');
     utl_file.put_line(fh,'                        p_executed   out nocopy boolean)');
     utl_file.put_line(fh,'as');
     utl_file.put_line(fh,'  l_qh_name varchar2(240);');
     utl_file.put_line(fh,'begin');
     utl_file.put_line(fh,'  p_executed := FALSE;');
     utl_file.put_line(fh,'  l_qh_name := upper(trim(p_qh_name));');

     if (p_agent_names is not null) then
        for i in p_agent_names.FIRST..p_agent_names.LAST loop
           l_first := TRUE;
           l_atleast_one := FALSE;
           for qhandler_rec in all_Queue_handlers(upper(p_agent_names(i))) loop
              l_atleast_one := TRUE;
              l_generated := TRUE;
              utl_file.put_line(fh,'     if (l_qh_name = '''
                               || qhandler_rec.qhandler || ''') then');
              utl_file.put_line(fh,'         '||qhandler_rec.qhandler
                               || '.Enqueue(p_event, p_out_agent_override);');
              utl_file.put_line(fh,'         p_executed := TRUE;');
              utl_file.put_line(fh,'         return;');
              utl_file.put_line(fh,'     end if; ');
           end loop;
        end loop; -- p_agent_names
     end if; -- p_agent_names

     -- give a message within the generated file regarding the failure
     if (not l_generated) then
        utl_file.put_line(fh, '');
        utl_file.put_line(fh, '  -- Package body could not be generated for the agent names given.');
        utl_file.put_line(fh, '  -- The reason could be because the procedure(s) referred to by the');
        utl_file.put_line(fh, '  -- agent name(s) was invalid or the agent name(s) specified do not exist');
        utl_file.put_line(fh, '');
     end if;

     utl_file.put_line(fh,'end StaticEnqueue;');

     utl_file.put_line(fh,'');
     utl_file.put_line(fh,'--');
     utl_file.put_line(fh,'-- Static dequeue procedure calls ');
     utl_file.put_line(fh,'--');

     utl_file.put_line(fh,'PROCEDURE StaticDequeue(p_qh_name    in  varchar2,');
     utl_file.put_line(fh,'	                    p_agent_guid in  raw,');
     utl_file.put_line(fh,'	                    p_event      in out nocopy wf_event_t,');
     utl_file.put_line(fh,'                  	    p_wait       in  binary_integer,');
     utl_file.put_line(fh,'	                    p_executed   out nocopy boolean)');

     utl_file.put_line(fh,'as');
     utl_file.put_line(fh,'  l_qh_name varchar2(240);');
     utl_file.put_line(fh,'begin');
     utl_file.put_line(fh,'  p_executed := FALSE;');
     utl_file.put_line(fh,'  l_qh_name := upper(trim(p_qh_name));');

     if (p_agent_names is not null) then
        for i in p_agent_names.FIRST..p_agent_names.LAST loop
           l_first := TRUE;
           l_atleast_one := FALSE;
           for qhandler_rec in all_Queue_handlers(upper(p_agent_names(i))) loop
              l_atleast_one := TRUE;
              l_generated := TRUE;
              utl_file.put_line(fh,'     if (l_qh_name = '''
                               || qhandler_rec.qhandler || ''') then');
              utl_file.put_line(fh,'         '||qhandler_rec.qhandler
                               || '.Dequeue(p_agent_guid, p_event, p_wait);');
              utl_file.put_line(fh,'         p_executed := TRUE;');
              utl_file.put_line(fh,'         return;');
              utl_file.put_line(fh,'     end if; ');
           end loop;
        end loop; -- p_agent_names
     end if; -- p_agent_names

     -- give a message within the generated file regarding the failure
     if (not l_generated) then
        utl_file.put_line(fh, '');
        utl_file.put_line(fh, '  -- Package body could not be generated for the agent name given.');
        utl_file.put_line(fh, '  -- The reason could be because the procedure(s) referred to by the');
        utl_file.put_line(fh, '  -- agent name(s) was invalid or the agent name(s) specified do not exist');
        utl_file.put_line(fh, '');
     end if;

     utl_file.put_line(fh,'end StaticDequeue;');
     utl_file.put_line(fh,' ');
     utl_file.put_line(fh,'end WF_AGT_DYN_FUNCS;');
     utl_file.put_line(fh,'/');
     utl_file.put_line(fh,'commit;');
     utl_file.put_line(fh,'exit;');
     utl_file.put_line(fh,' ');
     utl_file.fclose(fh);

     dbms_output.put_line('File generated is '||utl_dir||'/'||l_filename);
   exception
    when others then
      if (utl_file.is_open(fh)) then
       utl_file.fclose(fh);
      end if;
      raise;

   end StaticQH;

   --
   -- Procedure : StaticGenerateRule
   --
   -- Purpose   : Procedure to create the generate and rule functions
   --
   --

   Procedure StaticGenerateRule(p_correlation_ids in varchar_array) AS

     fh            utl_file.file_type;
     l_generated   boolean := FALSE;
     l_atleast_one boolean;
     l_first       boolean;

     l_generated_r   boolean := FALSE;
     l_atleast_one_r boolean;
     l_first_r       boolean;

     l_mesg        varchar2(4000);
     l_timestamp varchar2(20);

     cursor all_generate_funcs(p_corrid in varchar2) is
       select distinct upper(trim(v.function)) function
       from (
            select upper(substr(we.generate_function,1,instr(we.generate_function, '.')-1)) package_name,
                   we.generate_function function
            from  wf_events we
            where we.generate_function is not null and
                  instr(upper(we.name),p_corrid)=1
           ) v, user_objects uo
        where uo.object_name = nvl(v.package_name,v.function) and
              uo.object_type = decode(v.package_name,null,'FUNCTION','PACKAGE BODY') and
              uo.status = 'VALID';

     cursor all_rule_funcs(p_corrid in varchar2) is
       select distinct upper(trim(v.function)) function
       from (
            select upper(substr(wes.rule_function,1,instr(wes.rule_function, '.')-1)) package_name,
                   wes.rule_function function
            from  wf_events we,wf_event_subscriptions wes
            where we.guid = wes.event_filter_guid and
                  instr(upper(we.name),p_corrid)=1 and
                  wes.rule_function is not null and
                  upper(wes.rule_function) not like 'WF_RULE%' and
                  upper(wes.rule_function) not like 'WF_XML%'
            ) v, user_objects uo
        where uo.object_name = nvl(v.package_name,v.function)  and
	      uo.object_type = decode(v.package_name,null,'FUNCTION','PACKAGE BODY') and
	      uo.status = 'VALID';

     cursor seeded_rule_funcs is
       select distinct upper(trim(v.function)) function
       from (
            select upper(substr(wes.rule_function,1,instr(wes.rule_function, '.')-1)) package_name,
                   wes.rule_function function
            from  wf_events we,wf_event_subscriptions wes
            where we.guid = wes.event_filter_guid and
                  wes.rule_function is not null and
                  (
                   upper(wes.rule_function) like 'WF_RULE%' or
                   upper(wes.rule_function) like 'WF_XML%'
                  )
            ) v, user_objects uo
        where uo.object_name = nvl(v.package_name,v.function)  and
	      uo.object_type = decode(v.package_name,null,'FUNCTION','PACKAGE BODY') and
	      uo.status = 'VALID';

      l_filename varchar2(100);
      Begin

        select to_char(sysdate,'DDMONYYYYHH24MISS')
        into l_timestamp
        from dual;

        l_filename := 'WFBESDFNB'||l_timestamp||'.pls';

        fh := utl_file.fopen(utl_dir, l_filename, 'w', 32767);

        utl_file.put_line(fh, 'REM dbdrv: sql ~PROD ~PATH ~FILE none none none package '||g_amp||'phase=plb \');
        utl_file.put_line(fh, 'REM dbdrv: checkfile(115.2=120.3):~PROD:~PATH:~FILE');
        utl_file.put_line(fh, '/*=======================================================================*');
        utl_file.put_line(fh, '| Copyright (c) 2005, Oracle. All Rights Reserved                        |');
        utl_file.put_line(fh, '+========================================================================+');
        utl_file.put_line(fh, '| NAME                                                                   |');
        utl_file.put_line(fh, '|   WFBESDFNB'||l_timestamp||'.pls                                       |');
        utl_file.put_line(fh, '|                                                                        |');
        utl_file.put_line(fh, '| DESCRIPTION                                                            |');
        utl_file.put_line(fh, '|   PL/SQL body for package WF_BES_DYN_FUNCS                             |');
        utl_file.put_line(fh, '|   This is a generated file to provide static calls for                 |');
        utl_file.put_line(fh, '|   generate and rule functions                                          |');
        utl_file.put_line(fh, '|                                                                        |');
        utl_file.put_line(fh, '| NOTES                                                                  |');
        utl_file.put_line(fh, '|   This package body has static function calls for following event      |');
        utl_file.put_line(fh, '|   names or corrlation ids                                              |');
        utl_file.put_line(fh, '|   oracle.apps.wf.%                                                     |');
        utl_file.put_line(fh, '|   oracle.apps.fnd.%                                                    |');
        utl_file.put_line(fh, '|                                                                        |');
        utl_file.put_line(fh, '*========================================================================*/ ');
        utl_file.put_line(fh,'SET VERIFY OFF;');
        utl_file.put_line(fh,'WHENEVER SQLERROR EXIT FAILURE ROLLBACK;');
        utl_file.put_line(fh,'WHENEVER OSERROR EXIT FAILURE ROLLBACK;');

        utl_file.put_line(fh,'create or replace package body WF_BES_DYN_FUNCS as');

        utl_file.put_line(fh,'--');
        utl_file.put_line(fh,'-- Generate functions');
        utl_file.put_line(fh,'--');

        utl_file.put_line(fh,'PROCEDURE Generate(p_func_name in varchar2,');
        utl_file.put_line(fh,'                   p_event_name in varchar2,');
        utl_file.put_line(fh,'                   p_event_key in varchar2,');
        utl_file.put_line(fh,'                   p_parameter_list in wf_parameter_list_t,');
        utl_file.put_line(fh,'                   x_msg      in out nocopy clob,');
        utl_file.put_line(fh,'                   x_executed  out nocopy boolean)');
        utl_file.put_line(fh,'as');
        utl_file.put_line(fh,'  l_funcname varchar2(240);');
        utl_file.put_line(fh,'begin');
        utl_file.put_line(fh,'  x_executed := FALSE;');
        utl_file.put_line(fh,'  x_msg := null;');
        utl_file.put_line(fh,'  l_funcname := upper(trim(p_func_name));');

        if (p_correlation_ids is not null) then
           for i in p_correlation_ids.FIRST..p_correlation_ids.LAST loop
              l_first := TRUE;
              l_atleast_one := FALSE;
              for genfunc_rec in all_generate_funcs(p_correlation_ids(i)) loop

                 l_atleast_one := TRUE;
                 l_generated := TRUE;
                 if (l_first) then
                    utl_file.put_line(fh, '');
                    utl_file.put_line(fh, '  -- Function calls for corrid ' || p_correlation_ids(i) || '%');
                    utl_file.put_line(fh, '  if (upper(p_event_name) like '''
                                     || p_correlation_ids(i) || '%'') then ');
                    l_first := FALSE;
                 end if;

                 utl_file.put_line(fh,'     if (l_funcname = '''
                                  || genfunc_rec.function || ''') then');
                 utl_file.put_line(fh,'         ' || 'x_msg := '||genfunc_rec.function
                                  || '(p_event_name, p_event_key,p_parameter_list);');
                 utl_file.put_line(fh,'         x_executed := TRUE;');
                 utl_file.put_line(fh,'         return;');
                 utl_file.put_line(fh,'     end if; ');

	      end loop;--for loop

              if (l_atleast_one) then
                 utl_file.put_line(fh, '  end if;');
              end if;

           end loop; --for loop

        end if;

        -- give a message within the generated file regarding the failure
        if (not l_generated) then
           utl_file.put_line(fh, '');
           utl_file.put_line(fh, '  -- Package body could not be generated for the corrids given.');
           utl_file.put_line(fh, '  -- The reason could be because the procedure(s) referred to by the');
           utl_file.put_line(fh, '  -- corrid(s) was invalid or the corrid(s) specified do not exist');
           utl_file.put_line(fh, '');
        end if;

        utl_file.put_line(fh,'end Generate;');
	utl_file.put_line(fh, '');
        utl_file.put_line(fh,'--');
        utl_file.put_line(fh,'-- Rule functions');
        utl_file.put_line(fh,'--');

        utl_file.put_line(fh,'PROCEDURE RuleFunction(p_func_name in varchar2,');
        utl_file.put_line(fh,'                   p_subscription_guid in raw,');
        utl_file.put_line(fh,'                   p_event             in out nocopy wf_event_t,');
        utl_file.put_line(fh,'                   x_result            in out nocopy varchar2,');
        utl_file.put_line(fh,'                   x_executed  out nocopy boolean)');
        utl_file.put_line(fh,'as');
        utl_file.put_line(fh,'  l_funcname varchar2(240);');
        utl_file.put_line(fh,'  l_event_name varchar2(240);');
        utl_file.put_line(fh,'begin');
        utl_file.put_line(fh,'  x_executed := FALSE;');
        utl_file.put_line(fh,'  l_funcname := upper(trim(p_func_name));');
        utl_file.put_line(fh,'  l_event_name := upper(p_event.event_name);');


        l_first_r := TRUE;
        for seeded_rulefunc_rec in seeded_rule_funcs() loop
             if (l_first_r) then
               utl_file.put_line(fh, '');
               utl_file.put_line(fh, '  -- Seeded Rule Functions');
               l_first_r := FALSE;
             end if;

             utl_file.put_line(fh,'  if (l_funcname = '''
                                  || seeded_rulefunc_rec.function || ''') then');
             utl_file.put_line(fh,'     ' || 'x_result := '||seeded_rulefunc_rec.function
                                  || '(p_subscription_guid, p_event);');
             utl_file.put_line(fh,'     x_executed := TRUE;');
             utl_file.put_line(fh,'     return;');
             utl_file.put_line(fh,'  end if; ');
         end loop;


        if (p_correlation_ids is not null) then
           for i in p_correlation_ids.FIRST..p_correlation_ids.LAST loop

              l_first_r := TRUE;
              l_atleast_one_r := FALSE;
              for rulefunc_rec in all_rule_funcs(p_correlation_ids(i)) loop
                 l_atleast_one_r := TRUE;
                 l_generated_r := TRUE;
                 if (l_first_r) then
                    utl_file.put_line(fh, '');
                    utl_file.put_line(fh, '  -- Function calls for correlation id ' || p_correlation_ids(i) ||'%');
                    utl_file.put_line(fh, '  if (l_event_name like '''
                                     || p_correlation_ids(i) || '%'') then ');
                    l_first_r := FALSE;
                 end if;

                 utl_file.put_line(fh,'     if (l_funcname = '''
                                  || rulefunc_rec.function || ''') then');
                 utl_file.put_line(fh,'         ' || 'x_result := '||rulefunc_rec.function
                                  || '(p_subscription_guid, p_event);');
                 utl_file.put_line(fh,'         x_executed := TRUE;');
                 utl_file.put_line(fh,'         return;');
                 utl_file.put_line(fh,'     end if; ');
              end loop;
              if (l_atleast_one_r) then
                 utl_file.put_line(fh, '  end if;');
              end if;
           end loop; -- p_correlation_ids
        end if; -- p_correlation_ids

        -- give a message within the generated file regarding the failure
        if (not l_generated_r) then
           utl_file.put_line(fh, '');
           utl_file.put_line(fh, '  -- Package body could not be generated for the corrid given.');
           utl_file.put_line(fh, '  -- The reason could be because the procedure(s) referred to by the');
           utl_file.put_line(fh, '  -- corrid(s) was invalid or the corrid(s) specified do not exist');
           utl_file.put_line(fh, '');
        end if;

        utl_file.put_line(fh,'end RuleFunction;');


        utl_file.put_line(fh,'end WF_BES_DYN_FUNCS;');
        utl_file.put_line(fh,'/');
        utl_file.put_line(fh,'commit;');
        utl_file.put_line(fh,'exit;');
        utl_file.put_line(fh,' ');
        utl_file.fclose(fh);

        dbms_output.put_line('File generated is '||utl_dir||'/'||l_filename);
      exception
       when others then
         if (utl_file.is_open(fh)) then
          utl_file.fclose(fh);
         end if;
         raise;
   end StaticGenerateRule;


   --
   -- Procedure : Tokenize
   --
   -- Purpose   : Process the comma separated string into tokens
   --             and put the value in the varray
   --
   -- Return    : Varray containing the tokens
   --

   FUNCTION Tokenize(cslist VARCHAR2) return varchar_array AS

      -- pointer where to start the search for comma
      l_ptr int;

      --count to keep track of tokens added to varray
      l_count int :=1;

      --the token separated from the input
      l_token varchar2(100);

      --position of comma
      l_pos int;

      -- the array of tokens to be returned
      l_var_list varchar_array:=varchar_array();

      begin

         l_ptr := 1;
         --loop till no more commas are found
         loop
            l_pos := instr(cslist,',',l_ptr,1);

            --if no comma is found, then the next token
            --is the last token. add it to the array and exit
            if(l_pos=0) then

              l_token := substr(cslist,l_ptr,length(cslist));
              l_var_list.extend;
              --Remove any % character found
              l_var_list(l_count):=replace(trim(l_token),'%','');
              exit;
            end if;
            --if a comma is found, get the substring till the index
            --and add it to varray
            l_token:= substr(cslist,l_ptr,(l_pos-l_ptr));
            l_var_list.extend;
            --Remove any % character found
            l_var_list(l_count):=replace(trim(l_token),'%','');

            l_ptr:=l_pos+1;
            l_count:=l_count+1;

         end loop;
         return l_var_list;
   end;

end WF_BES_FUNCS;

/
