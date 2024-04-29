--------------------------------------------------------
--  DDL for Package Body JAI_CMN_DEBUG_CONTEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_DEBUG_CONTEXTS_PKG" AS
/*$Header: jai_cmn_dbg_ctx.plb 120.3.12000000.3 2007/10/25 02:12:53 rallamse noship $*/

  /** Stack Declaration */
  jai_debug_stack_overflow        exception;
  t_call_stack                    tab_log_manager_typ;
  ln_stack_top	                  number	      := 0;

  /** Buffers */

  t_context_cache                 tab_log_manager_typ;
  ln_context_idx                  number  := 0;

  last_file_name                  varchar2(250);
  last_file_handle                utl_file.file_type;
  last_utl_dir                    varchar2(2000);
  ln_user_id                      fnd_user.user_id%type;
  lv_default_log_file             varchar2 (512);
  lv_file_suffix                  varchar2 (250);
  r_temp_rec                      jai_cmn_debug_contexts%rowtype;

  /** Debuging Setting */
  ln_stack_max_cnt                number        := 200000;
  lv_each_file_open_mode          varchar2(1)   := 'a';
  lv_default_log_file_prefix varchar2 (240)     := 'jai_cmn_debug_contexts';
  lv_default_log_file_suffix varchar2 (10)      := '.log';
  lv_exception_propagation   varchar2 (2)       := jai_constants.No;
  ln_context_cache_size      number             :=  20;
  lv_debug                   varchar2(2)        := jai_constants.no; -- internal debug  --modified by csahoo for bug#6401388
  ln_print_each_context      varchar2(2)        := jai_constants.yes; -- Prints each context when registered
  lv_internal_log_file       varchar2 (100)     := 'JaiDebugLogInternal.log';

/***************************************************************************************************
-- #
-- # Change History -


1.   02/02/2007   Bgowrava for bug#5631784. File Version 120.0
									Forward Porting of 11i BUG#4742259 (TCS Enhancement)
                  lv_exception_propagation is initialised to jai_constants.No instead of jai_constants.Yes
2.  12/06/2007   Kunkumar made changes for bug#5915101
                 replaced the write log with debug .
3.  11/09/2007    CSahoo for bug#6401388, File Version 120.3.12000000.2
									Initially lv_debug was assigned to jai_constants.yes. Changes that to jai_constants.no
********************************************************************************************************/


  procedure init;

  /*------------------------------------------------------------------------------------------------------------*/
  procedure when_stack_empty
  is
  begin
    /** Perfom cleanup */
    debug ('Cleanup');
    last_file_name := null;

    if utl_file.is_open (last_file_handle) then
      begin
        utl_file.fclose (last_file_handle);
      exception
        when others then
        if sqlcode = -29282 then
          /** no such file is open, Do nothing */
          null;
        end if;
      end;
    end if;

    ln_stack_top := 0;
    t_call_stack.delete;
    debug ('Stack Flushed, count is' ||t_call_stack.count);
  exception
    when others then
    debug('when_stack_empty->'||sqlerrm);
    if lv_exception_propagation = jai_constants.yes then
      raise;
    end if;

  end when_stack_empty;
  /*------------------------------------------------------------------------------------------------------------*/
  function get_log_file_handle (pv_file_name varchar2) return utl_file.file_type
  is
  begin
    if last_file_name is null or (last_file_name <> pv_file_name) then

      if utl_file.is_open (last_file_handle) then
        begin
          utl_file.fclose (last_file_handle);
        exception
          when others then
          if sqlcode = -29282 then
            /** no such file is open, Do nothing */
            null;
          end if;
        end;
      end if;

      if last_utl_dir is null then
        select	decode(substr (value,1,instr(value,',') -1)	,null,	value,substr (value,1,instr(value,',') -1))
        into last_utl_dir
        from	v$parameter
        where	name = 'utl_file_dir';
      end if;

      last_file_handle:= utl_file.fopen
                            ( last_utl_dir
                            , pv_file_name
                            , lv_each_file_open_mode
                            );
      last_file_name := pv_file_name;
    end if;
    return last_file_handle;

  exception
  when others then
    debug('get_log_file_handle->'||sqlerrm);
    if lv_exception_propagation = jai_constants.yes then
      raise;
    end if;

  end get_log_file_handle ;

  /*---------------------------------------------------------------------------------------------------*/
   procedure parse_and_print_stack (pn_reg_id  number default null)
   is
    ln_print_upto number;
    ln_stack_ptr number;
    ln_reg_id   number;
  begin
    debug ('Begin - PARSE_AND_PRINT_STACK');
    debug ('pn_reg_id ='||pn_reg_id);
    ln_reg_id := nvl(pn_reg_id, ln_stack_top);

    if pn_reg_id is not null then
      ln_print_upto := pn_reg_id;
    else
      ln_print_upto := 0;
      print  (ln_reg_id
             ,'--------------------------------------------------------------------------------------------------- '
             ,summary
             );
      print  (ln_reg_id
             , 'WARNING:  Call stack was holding following methods when trying to de-register: '||t_call_stack(ln_reg_id).registered_name
             , summary
             );
      print  (ln_reg_id
             ,'---------------------------------------------------------------------------------------------------- '
             ,summary
             );
    end if;
    debug ('t_call_stack.count='||t_call_stack.count);
    if t_call_stack.count > 0 then

      print (ln_reg_id, 'Call Stack:');
      print (ln_reg_id, rpad('Registered Name',100,' ') ||lpad(' ',5,' ')||lpad('Stack position',15,' ')
            ,summary
            );
      print (ln_reg_id, rpad('---------------',100,'-') ||lpad(' ',5,' ')||lpad('--------------',15,'-')
            );
    end if;


    ln_stack_ptr := t_call_stack.last;
    debug ('ln_stack_ptr='||ln_stack_ptr  ||', ln_print_upto='||ln_print_upto);
    while (ln_stack_ptr > ln_print_upto)
    loop
      print (ln_reg_id,rpad(t_call_stack(ln_stack_ptr).registered_name,100,' ')||lpad(' ',5,' ')||lpad(ln_stack_ptr,15,' '));
      ln_stack_ptr := ln_stack_ptr - 1;
    end loop;

  exception
  when others then
    debug('parse_and_print_stack->'||sqlerrm);
    if lv_exception_propagation = jai_constants.yes then
      raise;
    end if;

  end parse_and_print_stack;
  /*---------------------------------------------------------------------------------------------------*/
  procedure pop_stack (pn_reg_id number default null)
  is
    ln_new_stack_top number;
  begin
    debug ('Begin -> POP_STACK');
    debug ('pn_reg_id='|| pn_reg_id);
    if pn_reg_id is null then
      if t_call_stack.exists(ln_stack_top) then
        t_call_stack.delete(pn_reg_id);
        ln_stack_top := ln_stack_top - 1;
      end if;
    else
        parse_and_print_stack(pn_reg_id);
        t_call_stack.delete(pn_reg_id,ln_stack_top);
        ln_stack_top := pn_reg_id-1;
    end if;
    debug ('Stack count= '||ln_stack_top);
    if ln_stack_top = 0 then
      when_stack_empty;
    end if;

  exception
  when others then
    debug('pop_stack->'||sqlerrm);
    if lv_exception_propagation = jai_constants.yes then
      raise;
    end if;
  end pop_stack;

 /*---------------------------------------------------------------------------------------------------*/

  procedure write_log ( pn_reg_id   in number default null
                      , pv_log_msg  in varchar2
                      , pn_statement_level in number default jai_cmn_debug_contexts_pkg.off
                      , pv_new_line_flag  in varchar2 default jai_constants.yes
                      )
  is
    f_handle  utl_file.file_type;
  begin

    if pn_reg_id is null AND NVL(lv_debug,jai_constants.no)=jai_constants.yes then --Added the second condition by kunkumar in if statement for bug#5915101
      /** Internal calll to write in the default log file */
      f_handle := get_log_file_handle (lv_internal_log_file);
      utl_file.put_line (f_handle, pv_log_msg);
      return;
    end if;

    if t_call_stack(pn_reg_id).row.log_status >= pn_statement_level then
      f_handle := get_log_file_handle (nvl(t_call_stack(pn_reg_id).log_file_name,lv_default_log_file));
      if pv_new_line_flag = jai_constants.no then
        utl_file.put (f_handle, pv_log_msg);
      else
        utl_file.put_line (f_handle, pv_log_msg);
      end if;
    end if;

  exception

  when others then
    if lv_exception_propagation = jai_constants.yes then
      raise;
    end if;

  end write_log;
  /*---------------------------------------------------------------------------------------------------*/
  procedure debug (lv_msg varchar2)
  is
  begin
    if lv_debug=jai_constants.yes then
      write_log (pv_log_msg => '(#):'|| lv_msg);
      --dbms_output.put_line (lv_msg);
    end if;
  end debug;

 /*------------------------------------------------------------------------------------------------------------*/
  procedure register ( pv_context in  varchar2
                     , pn_reg_id OUT NOCOPY number
                     )
  is
    cursor c_check_context
    is
    select  debug_log_id
           ,log_context
           ,nvl(log_status,0)    log_status
           ,log_file_prefix
           ,debug_user_id
           ,OBJECT_VERSION_NUMBER      -- added by bgowrava for forward porting bug #5631784
    from   jai_cmn_debug_contexts dlog
    where  pv_context like dlog.log_context || '%'
    and    debug_user_id  = ln_user_id
    order by (length(pv_context)-length(dlog.log_context))
	          , dlog.debug_log_id ;

  begin

    if ln_user_id is null then
      init;
    end if;

    debug ('ln_user_id='||ln_user_id);
    debug ('pv_context='||pv_context);

    r_temp_rec.log_context := null;
    for i in 1 .. ln_context_cache_size
    loop
      if  t_context_cache.exists(i)
      and t_context_cache (i).registered_name = pv_context then

        r_temp_rec := t_context_cache(i).row;
        exit;

      end if;
    end loop;
    debug('r_temp_rec.log_context='||r_temp_rec.log_context);
    if r_temp_rec.log_context is null then
      open  c_check_context;
      fetch c_check_context into r_temp_rec;
      close c_check_context;
    end if;
        debug('After Fetch : r_temp_rec.log_context='||r_temp_rec.log_context);
    if r_temp_rec.log_context is not null then
      debug ('context found in the setup');

      ln_stack_top := ln_stack_top + 1 ;

      if ln_stack_top > ln_stack_max_cnt then
        raise jai_debug_stack_overflow;
      end if;

      t_call_stack(ln_stack_top).row := r_temp_rec;
      t_call_stack(ln_stack_top).registered_name := pv_context;
      if t_call_stack (ln_stack_top).row.log_status = 0 then
        pn_reg_id := -1 * ln_stack_top;
      else
        if t_call_stack (ln_stack_top).row.log_file_prefix is not null then
          t_call_stack (ln_stack_top).log_file_name := t_call_stack (ln_stack_top).row.log_file_prefix || lv_file_suffix;
        end if;

      pn_reg_id :=  ln_stack_top;

      if ln_context_idx = ln_context_cache_size then
        ln_context_idx := 1;
      else
        ln_context_idx := ln_context_idx + 1;
      end if;
      debug ('ln_context_idx='||ln_context_idx);
      t_context_cache (ln_context_idx) := t_call_stack(ln_stack_top);

      end if;
      debug ('PN_REG_ID='||PN_REG_ID);
    else
      debug ('Context='||pv_context ||' not registered' );
      pn_reg_id := 0;
      debug ('pn_reg_id='||pn_reg_id);
    end if; /**r_temp_rec is not null */

    if ln_print_each_context = jai_constants.yes then
      print (pn_reg_id, lpad('-',100,'-'),summary);
      print (pn_reg_id, lpad('BEGIN -> '|| pv_context,240,' '),summary);
      print (pn_reg_id, lpad('-',100,'-'),summary);
    end if;
    debug ('End -> Register');

  exception

  when jai_debug_stack_overflow then

      print_stack;
      debug('Stack overflow error in jai_cmn_debug_contexts_pkg');--kunkumar replaced write_log with debug for bug#5915101

      if lv_exception_propagation = jai_constants.yes then
        raise_application_error (-20275, 'Stack overflow error in jai_cmn_debug_contexts_pkg');
      end if;
  when others then
    debug('register->'||sqlerrm);
    if lv_exception_propagation = jai_constants.yes then
      raise;
    end if;

  end register;
  /*------------------------------------------------------------------------------------------------------------*/
  procedure print  ( pn_reg_id   in number
                   , pv_log_msg  in varchar2
                   , pn_statement_level in number default jai_cmn_debug_contexts_pkg.detail
                   )
  is
  begin
    debug ('Begin -> PRINT');
    debug ('pn_reg_id  ='||pn_reg_id);
    debug ('pv_log_msg ='||pv_log_msg);

    if pn_reg_id <= 0  or pn_reg_id is null then
      return;
    end if;
    if t_call_stack.exists(pn_reg_id) then
      write_log (pn_reg_id, pv_log_msg, pn_statement_level);
      debug ('WRITE_LOG successful');
    else
      raise_application_error (-20275, 'REGISTER method must be called before calling PRINT method');
    end if;
    debug ('End -> PRINT');
  exception
    when others then
    debug('print->'||sqlerrm);
    if lv_exception_propagation = jai_constants.yes then
      raise;
    end if;

  end print;
  /*------------------------------------------------------------------------------------------------------------*/
   procedure print_stack
   is
   begin
      debug ('Begin -> PRINT_STACK');
      parse_and_print_stack ;
      debug ('End  -> PRINT_STACK');
   exception
    when others then
    debug('print_stack->'||sqlerrm);
    if lv_exception_propagation = jai_constants.yes then
      raise;
    end if;

   end print_stack;
  /*------------------------------------------------------------------------------------------------------------*/
  procedure deregister(pn_reg_id in number)
  is
   ln_reg_id number;
  begin
    debug ('Begin -> DEREGISTER');
    debug ('pn_reg_id ='||pn_reg_id);

    if pn_reg_id = 0 then
      return ;
    end if;

    ln_reg_id := abs(pn_reg_id);

    if ln_print_each_context = jai_constants.yes then
      print (ln_reg_id, lpad('-',100,'-'),summary);
      print (ln_reg_id, lpad('End -> '|| t_call_stack(ln_reg_id).registered_name,240,' '),summary);
      print (ln_reg_id, lpad('-',100,'-'),summary);
    end if;

    debug ('ln_stack_top='||ln_stack_top);
    if ln_reg_id < ln_stack_top then
      pop_stack (ln_reg_id );
    elsif ln_reg_id  = ln_stack_top then
      pop_stack;
    end if;
    debug ('End -> DEREGISTER');
  exception
    when others then
    debug('deregister->'||sqlerrm);
    if lv_exception_propagation = jai_constants.yes then
     print_stack;
      raise;
    end if;
  end deregister;

/*---------------------------------------PACKAGE CONSTRUCTOR ------------------------------------*/
  procedure init
  is
  ln_audsid number;
  begin

      debug ('Begin -> INIT');
      if ln_user_id is null then
        when_stack_empty;
        select fnd_global.user_id into ln_user_id from dual;
        select sys_context('USERENV','SESSIONID') into ln_audsid from dual;
      end if;
      debug ('ln_user_id='||ln_user_id||', ln_audsid='||ln_audsid );


      if lv_file_suffix is null then -- Only once when package is loaded
        lv_file_suffix := '_'||to_char(sysdate,'DDMM_HH24MI')
                             ||'_'||replace(ln_user_id, -1, 'DB')
                             ||'_'||ln_audsid
                             ||lv_default_log_file_suffix;

        lv_default_log_file := lv_default_log_file_prefix || lv_file_suffix;
      end if;
--write log replaced with debug  by kunkumar for bug#5915101
      debug( 'JAI Debug Settings:'
                   ||fnd_global.local_chr(10)||'--------------------------------------------------------------------------'
                   ||fnd_global.local_chr(10)||'Maximum Stack Size='||ln_stack_max_cnt
                   ||fnd_global.local_chr(10)||'Each Log File Open Mode='||lv_each_file_open_mode
                   ||fnd_global.local_chr(10)||'Default Log File Prefix='||lv_default_log_file_prefix
                   ||fnd_global.local_chr(10)||'Default Log File Suffix='||lv_default_log_file_suffix
                   ||fnd_global.local_chr(10)||'Internal Exception Propagation='||  lv_exception_propagation
                   ||fnd_global.local_chr(10)||'Context Cache Size (max)='||ln_context_cache_size
                   ||fnd_global.local_chr(10)||'Internal Debug Logging='||lv_debug
                   ||fnd_global.local_chr(10)||'Context Printing='||ln_print_each_context
                   ||fnd_global.local_chr(10)||'--------------------------------------------------------------------------'
                );
      if lv_debug = jai_constants.yes then
        write_log(pv_log_msg=>'NOTE: Internal logging is enabled.  Lines marked with "(#)" are internal log messages.  To disable internal logging
                    set private variable jai_cmn_debug_contexts_pkg.lv_debug=''N'''
                  );
      end if;
      debug ('End -> INIT');
   exception
   when others then
    debug('INIT ->'||sqlerrm);
    if lv_exception_propagation = jai_constants.yes then
      raise;
    end if;
  end init;

end jai_cmn_debug_contexts_pkg;

/
