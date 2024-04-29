--------------------------------------------------------
--  DDL for Package Body FND_ADG_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ADG_OBJECT" as
/* $Header: AFDGOBJB.pls 120.0.12010000.7 2010/09/17 16:07:20 rsanders noship $ */

C_FORCE_PUBLIC_DBLINK	constant        boolean	     := true;

	-- use real returm for LF to get passed arcs.

LF      		 constant varchar2(20) := '
';

C_PARSE_PIECE_SIZE	 constant        number      := 32000;
C_SLAVE_PREFIX		 constant        varchar2(10):= 'SV_';

C_COMPILE_DIRECTIVE_PACKAGE constant        varchar2(30) :=
				upper('fnd_adg_compile_directive');

type remapMethodTokenRec is record
     ( method_name	varchar2(30),
       auto_tx_wrapper  varchar2(10),
       use_commit_wait_on_autotx varchar2(10)
     );

type remapMethodTokenArray is table of remapMethodTokenRec;
type tokenArray is table of varchar2(50);

C_COMPILE_DIRECTIVE_ON       constant varchar2(32000) :=
-- *** COMPILE UNIT START OF INLINE ***
q'[
create or replace package fnd_adg_compile_directive as
/* $Header: AFDGOBJB.pls 120.0.12010000.7 2010/09/17 16:07:20 rsanders noship $ * */

enable_rpc              constant        boolean := true;

end fnd_adg_compile_directive;
]'  ;
-- *** COMPILE UNIT END OF INLINE ***

C_COMPILE_DIRECTIVE_OFF       constant varchar2(32000) :=
-- *** COMPILE UNIT START OF INLINE ***
q'[
create or replace package fnd_adg_compile_directive
as
/* $Header: AFDGOBJB.pls 120.0.12010000.7 2010/09/17 16:07:20 rsanders noship $ * */

enable_rpc              constant        boolean := false;

end fnd_adg_compile_directive;
]'  ;
-- *** COMPILE UNIT END OF INLINE ***

type charArray is table of varchar2(30);

/*==========================================================================*/

function is_valid_ret_type_for_autotx(p_datatype number) return boolean
as
begin

  case p_datatype
     when 2  then return true;
     when 12 then return true;
     when 252 then return true;
     else return false;
  end case;

  return false;

end;

/*==========================================================================*/

function get_type_string(p_datatype number,
                         p_rpcDescriptor fnd_adg_manage.rpcDescriptor)
                                    return varchar2
as
begin

  case p_datatype
     when 1  then return ' varchar2 ';
     when 2  then return ' number ';
     when 12 then return ' date ';
     when 252 then return ' boolean ';

     else fnd_adg_exception.raise_error
                     (fnd_adg_exception.C_OBJERR_UNSUPPORTD_DATA_TY,
                         p_rpcDescriptor.package_name||'.'||
                                      p_rpcDescriptor.method_name ||
                                      ':Type=' || p_datatype );
  end case;

  return null;

end;

/*==========================================================================*/

function is_supported_type(p_datatype number,
                           p_rpcDescriptor fnd_adg_manage.rpcDescriptor)
                                   return boolean
as
l_type_string   varchar2(255);
begin

  l_type_string := get_type_string(p_datatype,p_rpcDescriptor);

  return true;

exception
  when others then

	-- We will eventually use dba_arguments to do this properly
	-- but for now we just ignore methods with pl/sql tables as
	-- none are required.

    if ( p_datatype = 251 )
    then
       return false;
    end if;

    raise;

end;

/*==========================================================================*/

function get_inout_mode(p_inout number,
                        p_rpcDescriptor fnd_adg_manage.rpcDescriptor)
                                   return varchar2
as
begin

  case p_inout
     when 0 then return ' in ';
     when 1 then return ' out ';
     when 2 then return ' in out ';
     else fnd_adg_exception.raise_error
                        (fnd_adg_exception.C_OBJERR_UNSUPPORTD_IO_MODE,
                         p_rpcDescriptor.package_name||'.'||
                                      p_rpcDescriptor.method_name ||
                                      ':Mode=' || p_inout);
  end case;

  return null;

end;

/*==========================================================================*/

procedure string_to_tokens(p_string varchar2,p_token in out nocopy tokenArray,
                           p_separator varchar2)
as
l_idx number;
l_offset number;
l_strlen number;
l_piece  varchar2(255);
l_piece_trimmed varchar2(255);

begin

  if ( p_string is null or p_separator is null or p_token is null )
  then
     return;
  end if;

  l_offset := 1;
  l_strlen := length(p_string);

  loop

    exit when l_offset > l_strlen ;

    l_idx:= instr(p_string,p_separator,l_offset,1);

    if ( l_idx = 0 )
    then
       l_piece := substr(p_string,l_offset);
    else
       l_piece := substr(p_string,l_offset,l_idx-l_offset);
    end if;

    l_piece_trimmed := ltrim(rtrim(l_piece));

    if ( l_piece_trimmed is not null )
    then
       if ( length(l_piece_trimmed) > 0 )
       then
          p_token.extend;
          p_token(p_token.last) := l_piece_trimmed;
       end if;
    end if;

    if ( l_piece is not null )
    then
       l_offset := l_offset + length(l_piece);
    end if;

    if ( l_idx > 0 )
    then
       l_offset := l_offset + 1;
    end if;

  end loop;

end;

/*==========================================================================*/

procedure parse_remap_method_entry(p_methods varchar2,
                                   p_remapMethodTokenTable
                                       in out nocopy remapMethodTokenArray)
as
l_idx number;
l_tokenMethod tokenArray;
l_tokenOption  tokenArray;

begin
  if ( p_methods is null )
  then
     return;
  end if;

  l_tokenMethod := tokenArray();

  string_to_tokens(p_methods,l_tokenMethod,',');

  if ( l_tokenMethod.count > 0 )
  then
     for i in 1..l_tokenMethod.count loop

       l_tokenOption := tokenArray();

       string_to_tokens(l_tokenMethod(i),l_tokenOption,':');

       if ( l_tokenOption.count > 0 )
       then
          p_remapMethodTokenTable.extend;

          l_idx := p_remapMethodTokenTable.last;

          p_remapMethodTokenTable(l_idx).auto_tx_wrapper := 'N';
          p_remapMethodTokenTable(l_idx).use_commit_wait_on_autotx := 'N';

          for j in 1..l_tokenOption.count loop

            case j

              when 1 then p_remapMethodTokenTable(l_idx).method_name
                                                      := l_tokenOption(j);

              when 2 then
                          if ( upper(l_tokenOption(j)) = 'Y' or
                               upper(l_tokenOption(j)) = 'N'
                             )
                          then
                             p_remapMethodTokenTable(l_idx).auto_tx_wrapper
                                                      := l_tokenOption(j);
                          end if;
              when 3 then
                          if ( upper(l_tokenOption(j)) = 'Y' or
                               upper(l_tokenOption(j)) = 'N'
                             )
                          then
                             p_remapMethodTokenTable(l_idx).
                                  use_commit_wait_on_autotx:= l_tokenOption(j);
                          end if;
              else   null;
            end case;
          end loop;
       end if;
     end loop;
  end if;

end;

/*==========================================================================*/

function is_reserved_package(p_package_name varchar2,
                             p_synonym_only varchar2) return boolean
as
begin

  if ( upper(p_package_name) = upper(C_ADG_MANAGE_PACKAGE) or
       upper(p_package_name) = upper(C_COMPILE_DIRECTIVE_PACKAGE) or
       upper(p_synonym_only) = 'Y' )
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

procedure insert_adg_package  ( owner varchar2 default user,
                                package_name varchar2,
                                rpc_package_name varchar2,
                                rpc_synonym_name varchar2,
                                methods varchar2 default null,
                                synonym_only varchar2 default 'N'
                              )
as
l_adg_package_rec	fnd_adg_package%rowtype;

begin

  l_adg_package_rec.owner	       := upper(owner);
  l_adg_package_rec.package_name       := upper(package_name);
  l_adg_package_rec.rpc_package_name   := upper(rpc_package_name);
  l_adg_package_rec.rpc_synonym_name   := upper(rpc_synonym_name);
  l_adg_package_rec.synonym_only       := upper(synonym_only);
  l_adg_package_rec.methods            := upper(methods);
  l_adg_package_rec.spec_code	       := empty_clob();
  l_adg_package_rec.body_code          := empty_clob();

  if ( l_adg_package_rec.package_name = C_COMPILE_DIRECTIVE_PACKAGE )
  then
     l_adg_package_rec.spec_code       := C_COMPILE_DIRECTIVE_ON;
     l_adg_package_rec.body_code       := C_COMPILE_DIRECTIVE_OFF;
  end if;

  insert into fnd_adg_package values l_adg_package_rec;

end;

/*==========================================================================*/

procedure generate_support_objects(p_body_code in out nocopy clob)
as
begin

  dbms_lob.append
    (p_body_code,
-- *** RPC START OF INLINE ***
q'[
  G_IS_VALID_SYNONYM  boolean := null;
  G_IS_VALID_TIMESTAMP boolean := null;
  G_IS_VALID_STANDBY_TO_PRIMARY boolean := null;

  G_COMMIT_WAIT_SEQUENCE number := null;

  procedure validate_standby(p_rpcDescriptor fnd_adg_manage.rpcDescriptor) as
  l_err	number;
  l_msg varchar2(255);

  begin

    if ( not fnd_adg_support.is_standby )
    then
       fnd_adg_manage.raise_rpc_exec_error(p_rpcDescriptor,
                                            'VALIDATE_IS_STANDBY');
    end if;

    fnd_adg_manage.validate_standby_to_primary(l_err,l_msg,true);

    if ( l_err <> 0 )
    then
       fnd_adg_manage.raise_rpc_exec_error(p_rpcDescriptor,
                                           'VALIDATE_STANDBY_TO_PRIMARY',
                                           l_msg);
    end if;

  end;

  procedure validate_synonym(p_rpcDescriptor fnd_adg_manage.rpcDescriptor) as
  begin

    if ( G_IS_VALID_SYNONYM is null )
    then
       G_IS_VALID_SYNONYM :=
            fnd_adg_manage.validate_rpc_synonym(p_rpcDescriptor);
    end if;

    if ( G_IS_VALID_SYNONYM )
    then
       return;
    else
       fnd_adg_manage.raise_rpc_exec_error(p_rpcDescriptor,'VALIDATE_SYNONYM');
    end if;
  end;

  procedure validate_timestamp(p_rpcDescriptor fnd_adg_manage.rpcDescriptor) as
  begin

    if ( G_IS_VALID_TIMESTAMP is null )
    then
       G_IS_VALID_TIMESTAMP :=
            fnd_adg_manage.validate_rpc_timestamp(p_rpcDescriptor);
    end if;

    if ( G_IS_VALID_TIMESTAMP )
    then
       return;
    else
       fnd_adg_manage.raise_rpc_exec_error(p_rpcDescriptor,'VALIDATE_TIMESTAMP');
    end if;
  end;

  procedure validate_slave_rpc(p_rpcDescriptor fnd_adg_manage.rpcDescriptor)
  as
  begin

    if ( not fnd_adg_support.is_primary )
    then
       fnd_adg_manage.raise_rpc_exec_error(p_rpcDescriptor,
                                           'VALIDATE_SLAVE_RPC',
                                           'Slave is not on primary');
    end if;

    if ( not fnd_adg_support.is_rpc_from_standby )
    then
       fnd_adg_manage.raise_rpc_exec_error(p_rpcDescriptor,
                                           'VALIDATE_SLAVE_RPC',
                                           'Slave is not running as RPC');
    end if;

    fnd_adg_manage.handle_slave_rpc_debug;

  end;

  procedure wait_for_commit_from_slave(p_rpcDescriptor
                                            fnd_adg_manage.rpcDescriptor)
  as
  begin

	-- procedure only generated [used] when method commit_wait is true.

    if ( fnd_adg_utility.is_commit_wait_enabled )
    then
       if ( not fnd_adg_manage.wait_for_commit_count
                         (p_rpcDescriptor,G_COMMIT_WAIT_SEQUENCE) )
       then
          fnd_adg_manage.raise_rpc_exec_error(p_rpcDescriptor,
                                              'HANDLE_COMMIT_WAIT_SLAVE_RPC',
                                              'Timeout waiting for data');
       end if;
    end if;

  end;

  procedure handle_commit_wait_on_slave(p_rpcDescriptor
                                            fnd_adg_manage.rpcDescriptor)
  as
  begin

	-- procedure only generated [used] when method commit_wait is true.

    if (  fnd_adg_utility.is_commit_wait_enabled )
    then
       fnd_adg_manage.increment_commit_count(p_rpcDescriptor);
    end if;

  end;

  procedure validate_rpc(p_rpcDescriptor fnd_adg_manage.rpcDescriptor,
                         p_use_commit_wait boolean default false)
  as
  begin
    validate_standby(p_rpcDescriptor);
    validate_synonym(p_rpcDescriptor);
    validate_timestamp(p_rpcDescriptor);

    fnd_adg_manage.handle_rpc_debug;

    if ( p_use_commit_wait and fnd_adg_utility.is_commit_wait_enabled )
    then
       G_COMMIT_WAIT_SEQUENCE := fnd_adg_manage.get_commit_wait_seq
                                                      (p_rpcDescriptor);
    end if;

  end;

]'
-- *** RPC END OF INLINE ***
  );

end;

/*==========================================================================*/

procedure  generate_method_body(p_rpcDescriptor fnd_adg_manage.rpcDescriptor,
                                p_body_code in out nocopy clob,
                                p_arg_table charArray,p_is_function boolean,
                                p_function_return_type number,
                                p_is_slave boolean)
as
l_slave_prefix varchar2(10);
l_use_autonomous_tx boolean := false;
l_use_commit_wait boolean := false;

begin

  if ( p_rpcDescriptor.auto_tx_wrapper = 'Y'
       and ( not p_is_function or
               ( p_is_function and
                 is_valid_ret_type_for_autotx(p_function_return_type)
               )
            )
     )
  then
     l_use_autonomous_tx := true;

     if ( p_rpcDescriptor.use_commit_wait_on_autotx = 'Y' )
     then
        l_use_commit_wait := true;
     end if;
  end if;

  if ( p_is_slave and l_use_autonomous_tx )
  then
     dbms_lob.append(p_body_code,'PRAGMA AUTONOMOUS_TRANSACTION;'||LF);
  end if;

  if ( l_use_autonomous_tx and p_is_function )
  then
     dbms_lob.append(p_body_code,
             'l_rc '||
             get_type_string(p_function_return_type,p_rpcDescriptor) ||
             ';'||LF);
  end if;

  dbms_lob.append(p_body_code,
                  'l_rpcDescriptor fnd_adg_manage.rpcDescriptor;'||LF);

  dbms_lob.append(p_body_code,'begin'||LF);

  dbms_lob.append(p_body_code,
                  '  l_rpcDescriptor.owner        := ''' ||
                          p_rpcDescriptor.owner        || ''';' ||  LF);

  dbms_lob.append(p_body_code,
                  '  l_rpcDescriptor.package_name := ''' ||
                          p_rpcDescriptor.package_name || ''';' ||  LF);

  dbms_lob.append(p_body_code,
                  '  l_rpcDescriptor.rpc_package_name := ''' ||
                          p_rpcDescriptor.rpc_package_name || ''';' ||  LF);

  dbms_lob.append(p_body_code,
                  '  l_rpcDescriptor.rpc_synonym_name := ''' ||
                          p_rpcDescriptor.rpc_synonym_name || ''';' ||  LF);

  dbms_lob.append(p_body_code,
                  '  l_rpcDescriptor.method_name      := ''' ||
                          p_rpcDescriptor.method_name      || ''';' ||  LF);

  if ( p_is_slave )
  then
     dbms_lob.append(p_body_code,
                     '  validate_slave_rpc(l_rpcDescriptor); ' || LF);
  else
     if ( l_use_commit_wait )
     then
        dbms_lob.append(p_body_code,
                        '  validate_rpc(l_rpcDescriptor,true); ' || LF);
     else
        dbms_lob.append(p_body_code,
                        '  validate_rpc(l_rpcDescriptor); ' || LF);
     end if;
  end if;

  if ( p_is_function )
  then
     if ( l_use_autonomous_tx )
     then
        dbms_lob.append(p_body_code,' l_rc := ');
     else
        dbms_lob.append(p_body_code,'return ');
     end if;
  end if;

  if ( p_is_slave )
  then
     dbms_lob.append(p_body_code,
                     p_rpcDescriptor.package_name || '.' ||
                                  p_rpcDescriptor.method_name);
  else
     dbms_lob.append(p_body_code,
                     p_rpcDescriptor.rpc_synonym_name || '.' ||
                               C_SLAVE_PREFIX||p_rpcDescriptor.method_name);
  end if;

  if ( p_arg_table.count > 0 )
  then
     dbms_lob.append(p_body_code,'('||LF);

     for i in 1..p_arg_table.count loop

       if ( i > 1 )
       then
          dbms_lob.append(p_body_code,','||LF);
       end if;

       dbms_lob.append(p_body_code,p_arg_table(i));

     end loop;

     dbms_lob.append(p_body_code,')');

  end if;

  dbms_lob.append(p_body_code,';'||LF);

  if ( l_use_autonomous_tx )
  then
     if ( p_is_slave )
     then
        if ( l_use_commit_wait )
        then
           dbms_lob.append(p_body_code,
                         ' handle_commit_wait_on_slave(l_rpcDescriptor);'||LF);
        end if;

        dbms_lob.append(p_body_code,' commit;'||LF);

        if ( p_is_function )
        then
           dbms_lob.append(p_body_code,' return l_rc;'||LF);
        end if;

        dbms_lob.append(p_body_code,' exception when others then '||LF);
        dbms_lob.append(p_body_code,'     rollback;'||LF);
        dbms_lob.append(p_body_code,'     raise   ;'||LF);

     else

        if ( l_use_commit_wait )
        then
           dbms_lob.append(p_body_code,
                          ' wait_for_commit_from_slave(l_rpcDescriptor);'||LF);
        end if;

        if ( p_is_function )
        then
           dbms_lob.append(p_body_code,' return l_rc;'||LF);
        end if;

     end if;
  end if;

  dbms_lob.append(p_body_code,'end;'||LF);

end;

/*==========================================================================*/

procedure generate_method_definition(p_rpcDescriptor
                                              fnd_adg_manage.rpcDescriptor,
                                     p_overload number,
                                     p_method_definition in out nocopy varchar2,
                                     p_arg_table in out nocopy charArray,
                                     p_is_function in out nocopy boolean,
                                     p_function_return_type in out nocopy number,
                                     p_is_spec_mode boolean,
                                     p_slave boolean)
as
t_overload     DBMS_DESCRIBE.NUMBER_TABLE;
t_position     DBMS_DESCRIBE.NUMBER_TABLE;
t_level        DBMS_DESCRIBE.NUMBER_TABLE;
t_arg_name     DBMS_DESCRIBE.VARCHAR2_TABLE;
t_data_type    DBMS_DESCRIBE.NUMBER_TABLE;
t_default_val  DBMS_DESCRIBE.NUMBER_TABLE;
t_in_out_mode  DBMS_DESCRIBE.NUMBER_TABLE;
t_length       DBMS_DESCRIBE.NUMBER_TABLE;
t_precision    DBMS_DESCRIBE.NUMBER_TABLE;
t_scale        DBMS_DESCRIBE.NUMBER_TABLE;
t_radix        DBMS_DESCRIBE.NUMBER_TABLE;
t_spare        DBMS_DESCRIBE.NUMBER_TABLE;

l_code_method_type varchar2(30);
l_code_method_return varchar2(255) := null;

l_has_args     boolean := false;

l_slave_prefix varchar2(10);

begin

  if ( p_slave )
  then
     l_slave_prefix := C_SLAVE_PREFIX;
  else
     l_slave_prefix := '';
  end if;

  p_method_definition := null;

  dbms_describe.describe_procedure(p_rpcDescriptor.owner||'.'||
                                      p_rpcDescriptor.package_name||'.'||
                                      p_rpcDescriptor.method_name,
                                   null,
                                   null,
                                   t_overload,
                                   t_position,
                                   t_level   ,
                                   t_arg_name,
                                   t_data_type,
                                   t_default_val,
                                   t_in_out_mode,
                                   t_length,
                                   t_precision,
                                   t_scale,
                                   t_radix,
                                   t_spare
                                  );

  l_code_method_type := ' procedure ';
  p_is_function := false;

  for i in 1..t_overload.count loop

    if ( t_overload(i) = p_overload )
    then
       if ( t_position(i) = 0 )
       then
          l_code_method_type := ' function ';
          p_is_function := true;
          p_function_return_type := null;

          if ( not is_supported_type(t_data_type(i),p_rpcDescriptor) )
          then
             p_method_definition := null;
             exit;
          end if;

          l_code_method_return :=
                ' return ' || get_type_string(t_data_type(i),p_rpcDescriptor);

          p_function_return_type := t_data_type(i);
       end if;

       if ( l_code_method_type is not null )
       then
          p_method_definition := p_method_definition || l_code_method_type||
                                  l_slave_prefix || p_rpcDescriptor.method_name;
          l_code_method_type := null;
       end if;

       if ( t_position(i) > 0 and t_arg_name(i) is null )
       then
          exit;  -- null arg procedure;
       end if;

       if ( t_position(i) > 0 and not l_has_args )
       then
          l_has_args := true;
          p_method_definition := p_method_definition || '(';
       end if;

       if ( t_position(i) > 1 )
       then
          p_method_definition := p_method_definition || ','||LF;
       end if;

       if ( t_position(i) > 0 )
       then
          p_method_definition := p_method_definition || t_arg_name(i)||' ';
          p_method_definition := p_method_definition ||
                    get_inout_mode(t_in_out_mode(i),p_rpcDescriptor)||' ';

          if ( not is_supported_type(t_data_type(i),p_rpcDescriptor) )
          then
             p_method_definition := null;
             exit;
          end if;

          p_method_definition := p_method_definition ||
                      get_type_string(t_data_type(i),p_rpcDescriptor);

          p_arg_table.extend;
          p_arg_table(p_arg_table.last) := t_arg_name(i);

       end if;

    end if;

  end loop;

  if ( p_method_definition is null )
  then
     return ;
  end if;

  if ( l_has_args )
  then
     p_method_definition := p_method_definition || ')';
  end if;

  if ( l_code_method_return is not null )
  then
     p_method_definition := p_method_definition || l_code_method_return;
  end if;

  if ( p_is_spec_mode )
  then
     p_method_definition := p_method_definition || ';'||LF;
  else
     p_method_definition := p_method_definition || ' is '||LF;
  end if;

end;

/*==========================================================================*/

procedure generate_code_spec(p_rpcDescriptor
                                  in out nocopy fnd_adg_manage.rpcDescriptor,
                             p_spec_code in out nocopy clob)
as
cursor c1(c_owner varchar2, c_package_name varchar2)
          is select a.authid
               from dba_procedures a
              where a.owner = c_owner
                and a.object_name = c_package_name
                and a.object_type = 'PACKAGE';

cursor c2(c_owner varchar2, c_package_name varchar2)
          is select a.rpc_synonym_name,a.package_name,a.owner,
                    a.rpc_package_name,a.methods
               from fnd_adg_package a
              where a.package_name = c_package_name
                and a.owner        = c_owner
              order by a.owner,a.package_name;

cursor c3(c_owner varchar2, c_package_name varchar2, c_method_name varchar2)
          is select nvl(a.overload,0) overload
               from dba_procedures a
              where a.owner = c_owner
                and a.object_name = c_package_name
                and a.procedure_name = c_method_name
                and a.object_type = 'PACKAGE'
                and not (   a.aggregate = 'YES'
                         or a.pipelined = 'YES'
                         or a.parallel = 'YES'
                         or a.interface = 'YES'
                         or a.deterministic = 'YES'
                         or a.IMPLTYPEOWNER is not null
                         or a.IMPLTYPENAME is not null
                        );

l_authid varchar2(128);
l_arg_table  charArray := charArray();
l_slave_arg_table  charArray := charArray();
l_overload	number;
l_is_function   boolean ;
l_method_definition  varchar2(32000); -- we can change to clob if we ever hit
                                      -- this limit! Unlikely though.
l_function_return_type number;

l_remapMethodTokenTable remapMethodTokenArray ;

begin

  dbms_lob.trim(p_spec_code,0);

  for f_rec in c1(p_rpcDescriptor.owner,p_rpcDescriptor.package_name) loop

    if ( f_rec.authid = 'DEFINER' )
    then
       l_authid := ' AUTHID DEFINER ';
    else
       l_authid := ' AUTHID CURRENT_USER ';
    end if;

  end loop;

  dbms_lob.append
     (p_spec_code,
      'create or replace package ' || p_rpcDescriptor.rpc_package_name ||
                          l_authid || ' as ' || LF
     );

  dbms_lob.append
     (p_spec_code, ' C_TIMESTAMP 	constant varchar2(30) := ''' ||
                            to_char(sysdate,'J SSSSS') || ''';' || LF
     );

  for f_rec in c2(p_rpcDescriptor.owner,p_rpcDescriptor.package_name) loop

    l_remapMethodTokenTable := remapMethodTokenArray();

    parse_remap_method_entry(f_rec.methods,l_remapMethodTokenTable);

    if ( l_remapMethodTokenTable.count > 0 )
    then
       for i in 1..l_remapMethodTokenTable.count loop

         p_rpcDescriptor.method_name := l_remapMethodTokenTable(i).method_name;
         p_rpcDescriptor.auto_tx_wrapper :=
                         l_remapMethodTokenTable(i).auto_tx_wrapper;
         p_rpcDescriptor.use_commit_wait_on_autotx :=
                         l_remapMethodTokenTable(i).use_commit_wait_on_autotx;

         for f_overload in c3(f_rec.owner,f_rec.package_name,
                              p_rpcDescriptor.method_name) loop

           l_overload := f_overload.overload;

           l_arg_table := charArray();
           l_slave_arg_table := charArray();

           generate_method_definition(p_rpcDescriptor,l_overload,
                                      l_method_definition,
                                      l_arg_table, l_is_function,
                                      l_function_return_type,true,false);

           if ( l_method_definition is not null )
           then
              dbms_lob.append(p_spec_code,l_method_definition);
           end if;

           generate_method_definition(p_rpcDescriptor,l_overload,
                                      l_method_definition,
                                      l_slave_arg_table, l_is_function,
                                      l_function_return_type,true,true);

           if ( l_method_definition is not null )
           then
              dbms_lob.append(p_spec_code,l_method_definition);
           end if;

         end loop;
       end loop;
    end if;
  end loop;

  dbms_lob.append
     (p_spec_code, 'end ' || p_rpcDescriptor.rpc_package_name || ';' || LF );

end;

/*==========================================================================*/

procedure generate_code_body(p_rpcDescriptor
                                  in out nocopy fnd_adg_manage.rpcDescriptor,
                             p_body_code in out nocopy clob)
as
cursor c2(c_owner varchar2, c_package_name varchar2)
          is select a.rpc_synonym_name,a.package_name,a.owner,
                    a.rpc_package_name,a.methods
               from fnd_adg_package a
              where a.package_name = c_package_name
                and a.owner        = c_owner
              order by a.owner,a.package_name;

cursor c3(c_owner varchar2, c_package_name varchar2, c_method_name varchar2)
          is select nvl(a.overload,0) overload
               from dba_procedures a
              where a.owner = c_owner
                and a.object_name = c_package_name
                and a.procedure_name = c_method_name
                and a.object_type = 'PACKAGE'
                and not (   a.aggregate = 'YES'
                         or a.pipelined = 'YES'
                         or a.parallel = 'YES'
                         or a.interface = 'YES'
                         or a.deterministic = 'YES'
                         or a.IMPLTYPEOWNER is not null
                         or a.IMPLTYPENAME is not null
                        );

l_arg_table  charArray := charArray();
l_slave_arg_table  charArray := charArray();
l_overload	number;
l_is_function   boolean ;
l_method_definition  varchar2(32000); -- we can change to clob if we ever hit
                                      -- this limit! Unlikely though.
l_function_return_type number;

l_remapMethodTokenTable remapMethodTokenArray ;

begin

  dbms_lob.trim(p_body_code,0);

  dbms_lob.append
     (p_body_code,
      'create or replace package body ' || p_rpcDescriptor.rpc_package_name ||
                                                ' as ' || LF
     );

  generate_support_objects(p_body_code);

  for f_rec in c2(p_rpcDescriptor.owner,p_rpcDescriptor.package_name) loop

    l_remapMethodTokenTable := remapMethodTokenArray();

    parse_remap_method_entry(f_rec.methods,l_remapMethodTokenTable);

    if ( l_remapMethodTokenTable.count > 0 )
    then
       for i in 1..l_remapMethodTokenTable.count loop

         p_rpcDescriptor.method_name := l_remapMethodTokenTable(i).method_name;
         p_rpcDescriptor.auto_tx_wrapper :=
                         l_remapMethodTokenTable(i).auto_tx_wrapper;
         p_rpcDescriptor.use_commit_wait_on_autotx :=
                         l_remapMethodTokenTable(i).use_commit_wait_on_autotx;

         for f_overload in c3(f_rec.owner,f_rec.package_name,
                              p_rpcDescriptor.method_name) loop

           l_overload := f_overload.overload;

           l_arg_table := charArray();
           l_slave_arg_table := charArray();

           generate_method_definition(p_rpcDescriptor,l_overload,
                                      l_method_definition,
                                      l_arg_table, l_is_function,
                                      l_function_return_type, false,false );

           if ( l_method_definition is not null )
           then
              dbms_lob.append(p_body_code,l_method_definition);

              generate_method_body(p_rpcDescriptor,p_body_code,l_arg_table,
                                   l_is_function,l_function_return_type,false);
           end if;

           generate_method_definition(p_rpcDescriptor,l_overload,
                                      l_method_definition,
                                      l_slave_arg_table, l_is_function,
                                      l_function_return_type, false,true );

           if ( l_method_definition is not null )
           then
              dbms_lob.append(p_body_code,l_method_definition);

              generate_method_body(p_rpcDescriptor,p_body_code,
                                   l_slave_arg_table,
                                   l_is_function,l_function_return_type,true);
           end if;
         end loop;
       end loop;
    end if;
  end loop;

  dbms_lob.append
     (p_body_code, ' begin null; end; ' || LF );

end;

/*==========================================================================*/

procedure validate_method_supported(p_owner varchar2,
                                    p_package varchar2,p_method varchar2)
as
l_count1 number;
begin

  select count(*)
    into l_count1
    from dba_procedures a
   where a.owner = p_owner
     and a.object_name = p_package
     and a.procedure_name = p_method
     and a.object_type = 'PACKAGE'
     and not (   a.aggregate = 'YES'
              or a.pipelined = 'YES'
              or a.parallel = 'YES'
              or a.interface = 'YES'
              or a.deterministic = 'YES'
              or a.IMPLTYPEOWNER is not null
              or a.IMPLTYPENAME is not null
             );

  if ( l_count1 = 0 )
  then
     fnd_adg_exception.raise_error(fnd_adg_exception.C_OBJERR_GEN_MISSING_METHOD,
                                p_package || '.' || p_method );
  end if;

end;


/*==========================================================================*/

procedure compile_package_unit(p_owner varchar2,
                               p_package_name varchar2,
                               p_rpc_package_name varchar2,
                               p_code clob,
                               p_is_spec_unit boolean)
as
success_with_compilation exception;
pragma exception_init(success_with_compilation,-24344);

l_compile_spec varchar2(10) := 'N' ;
l_compile_body varchar2(10) := 'N' ;

l_compile_status number := -2;
l_err_msg	varchar2(2048);

l_stmt  dbms_sql.varchar2a;
l_clob_len number;
l_no_chunks number;

l_csr   integer;
l_amount number;
l_buffer varchar2(32767);

begin

  if ( p_is_spec_unit )
  then
     l_compile_spec := 'Y';
  else
     l_compile_body := 'Y';
  end if;

	/* We're using varchar2a rather than clob because of 10gR2
	   dependencies. However, varchar2a doesn't raise -24344 - it
	   just sets invalid status! Ah well, just check dictionary.
	*/

  l_clob_len := dbms_lob.getlength(p_code);
  l_no_chunks := trunc(l_clob_len/C_PARSE_PIECE_SIZE);

	/* We use dbms_lob.read as substr has limit of 32767/4 for
	   utf8 so we lose chars!*/

  for i in 1..l_no_chunks loop
    l_amount := C_PARSE_PIECE_SIZE;
    dbms_lob.read(p_code,l_amount,1+(C_PARSE_PIECE_SIZE*(i-1)),l_buffer);
    l_stmt(i) := l_buffer;
  end loop;

  if ( mod(l_clob_len,C_PARSE_PIECE_SIZE) > 0 )
  then
     l_amount := mod(l_clob_len,C_PARSE_PIECE_SIZE);

     dbms_lob.read(p_code,l_amount,1+(C_PARSE_PIECE_SIZE*l_no_chunks),l_buffer);
     l_stmt(l_no_chunks+1) := l_buffer;
  end if;

/*
 sys.dbms_output.put_line('l_clob_len='||l_clob_len||' l_no_chunks='||l_no_chunks||' count='||l_stmt.count);

  for i in 1..l_stmt.count loop
    sys.dbms_output.put_line(l_stmt(i));
  end loop;
*/

  l_csr := dbms_sql.open_cursor;

  begin

    dbms_sql.parse(l_csr,l_stmt,1,l_stmt.count,false,1);

    l_compile_status := 0;

  exception
    when success_with_compilation then
         l_compile_status := 1;

    when others then

      if ( dbms_sql.is_open(l_csr) )
      then
         dbms_sql.close_cursor(l_csr);
      end if;

      raise;
  end;

  if ( dbms_sql.is_open(l_csr) )
  then
     dbms_sql.close_cursor(l_csr);
  end if;

	/* dbms_sql.parse with varchar2a doesn't raise -24344 ! */

  if ( p_package_name = C_COMPILE_DIRECTIVE_PACKAGE )
  then
     select count(*)
       into l_compile_status
       from dba_objects a
      where a.owner = p_owner
        and a.object_name = p_package_name
        and a.object_type = 'PACKAGE'
        and a.status = 'INVALID';
  else
     select count(*)
       into l_compile_status
       from dba_objects a
      where a.owner = p_owner
        and a.object_name = p_rpc_package_name
        and a.object_type = decode(l_compile_spec,'Y','PACKAGE','PACKAGE BODY')
        and a.status = 'INVALID';
  end if;

  if ( l_compile_status <> 0 )
  then
     l_err_msg :=  p_owner || '.' ||p_rpc_package_name
                   ||' Spec='||l_compile_spec
                   ||' Body='||l_compile_body||' Status='||l_compile_status;

     if ( p_package_name = C_COMPILE_DIRECTIVE_PACKAGE )
     then
        raise_application_error(-20001,'Directive package failed to compile!');
     else
        fnd_adg_exception.raise_error(fnd_adg_exception.C_OBJERR_COMPILE_ERROR,l_err_msg);
     end if;
  end if;

end;

/*==========================================================================*/

procedure compile_package_spec(p_owner varchar2,
                               p_package_name varchar2,
                               p_rpc_package_name varchar2,
                               p_code clob)
as
begin

  compile_package_unit(p_owner,p_package_name,p_rpc_package_name,p_code,true);

end;

/*==========================================================================*/

procedure compile_package_body(p_owner varchar2,
                               p_package_name varchar2,
                               p_rpc_package_name varchar2,
                               p_code clob)
as
begin

  compile_package_unit(p_owner,p_package_name,p_rpc_package_name,p_code,false);

end;

/*==========================================================================*/
/*==================Start of public methods ================================*/
/*==========================================================================*/

/*==========================================================================*/

procedure build_synonym(p_owner varchar2 default user,
                        p_package_name varchar2)
as
cursor c1 is select a.owner,a.rpc_synonym_name,a.package_name,a.synonym_only,
                    a.rpc_package_name
               from fnd_adg_package a
              where a.owner = p_owner
                and a.package_name = p_package_name
              order by 1,2,3;

l_dblink	varchar2(255);

l_rpc_synonym_name	varchar2(30);
l_rpc_synonym_target    varchar2(30);

l_cmd_string		varchar2(2048);
l_ok			number;

begin

  l_dblink := fnd_adg_utility.get_standby_to_primary_dblink;

  for f_rec in c1 loop

    if ( is_reserved_package(f_rec.package_name,f_rec.synonym_only) )
    then
       if ( upper(f_rec.package_name) = upper(C_COMPILE_DIRECTIVE_PACKAGE) )
       then
          return;
       end if;
    end if;

    l_rpc_synonym_name := f_rec.rpc_synonym_name;
    l_rpc_synonym_target:=f_rec.rpc_package_name;

    if ( f_rec.package_name = C_ADG_MANAGE_PACKAGE )
    then
       l_rpc_synonym_name := C_ADG_MANAGE_NAME_REMOTE;
       l_rpc_synonym_target:= f_rec.package_name;
    end if;

    select count(*)
      into l_ok
      from dba_synonyms a
     where a.owner = f_rec.owner
       and a.synonym_name = l_rpc_synonym_name
       and a.table_owner = f_rec.owner
       and a.table_name  = l_rpc_synonym_target
       and (  ( a.db_link is null and l_dblink is null )
            or( a.db_link = l_dblink )
           );

    if ( l_ok <> 1 )
    then

       if ( l_dblink is null )
       then
          l_cmd_string :=
            ' create or replace synonym ' || l_rpc_synonym_name ||
            ' for ' || l_rpc_synonym_target;
       else
          l_cmd_string :=
            ' create or replace synonym ' || l_rpc_synonym_name ||
            ' for ' || l_rpc_synonym_target ||
            '@' || l_dblink ;
       end if;

       -- sys.dbms_output.put_line(l_cmd_string);

       execute immediate l_cmd_string;

   end if;

  end loop;

end;

/*==========================================================================*/

procedure build_all_synonyms
as
cursor c1 is select a.owner,a.package_name,a.rpc_package_name,a.synonym_only
               from fnd_adg_package a
              order by a.owner,a.package_name;
begin

  for f_rec in c1 loop

    if ( not is_reserved_package(f_rec.package_name,f_rec.synonym_only) or
         ( is_reserved_package(f_rec.package_name,f_rec.synonym_only) and
            upper(f_rec.package_name) <> upper(C_COMPILE_DIRECTIVE_PACKAGE) ) )
    then
       build_synonym(f_rec.owner,f_rec.package_name);
    end if;

  end loop;

end;

/*==========================================================================*/

procedure compile_package(p_owner varchar2 default user,
                          p_package_name varchar2,
                          p_compile_spec boolean default true,
                          p_compile_body boolean default true)
as
cursor c1 is select a.owner,a.package_name,a.rpc_package_name,a.synonym_only,
                    a.spec_code,a.body_code,
                    dbms_lob.getlength(a.spec_code) spec_len,
                    dbms_lob.getlength(a.body_code) body_len
               from fnd_adg_package a
              where a.owner = p_owner
                and a.package_name = p_package_name
              order by a.owner,a.package_name;

l_package_error boolean;
spec_is_empty   boolean;
body_is_empty   boolean;
l_rpc_package_name varchar2(30);

begin

  l_package_error := true;
  spec_is_empty   := false;
  body_is_empty   := false;

  for f_rec in c1 loop

    if ( is_reserved_package(f_rec.package_name,f_rec.synonym_only) )
    then
       return;
    end if;

    l_package_error := false;

    l_rpc_package_name := f_rec.rpc_package_name;

    if ( p_compile_spec )
    then
       if ( f_rec.spec_len = 0 )
       then
          spec_is_empty := true;
       else
          compile_package_spec(p_owner,p_package_name,l_rpc_package_name,
                               f_rec.spec_code);
       end if;
    end if;

    if ( p_compile_body )
    then
       if ( f_rec.body_len = 0 )
       then
          body_is_empty := true;
       else
          compile_package_body(p_owner,p_package_name,l_rpc_package_name,
                               f_rec.body_code);
       end if;
    end if;

    exit;

  end loop;

  if ( l_package_error )
  then
     fnd_adg_exception.raise_error(fnd_adg_exception.C_OBJERR_COMPILE_NOT_DEFINED,
                                p_owner || '.' ||l_rpc_package_name
                               );
  end if;

  if ( spec_is_empty or body_is_empty )
  then
     fnd_adg_exception.raise_error(fnd_adg_exception.C_OBJERR_COMPILE_NO_CODE,
                                p_owner || '.' ||l_rpc_package_name
                               );
  end if;

end;

/*==========================================================================*/

procedure compile_all_packages
as
cursor c1 is select a.owner,a.package_name,a.rpc_package_name,a.synonym_only
               from fnd_adg_package a
              order by a.owner,a.package_name;
begin

  for f_rec in c1 loop

    if ( not is_reserved_package(f_rec.package_name,f_rec.synonym_only) )
    then
       compile_package(f_rec.owner,f_rec.package_name);
    end if;

  end loop;

end;

/*==========================================================================*/

procedure build_package(p_owner varchar2 default user,
                        p_package_name varchar2,
                        p_build_spec boolean default true,
                        p_build_body boolean default true)
as
l_fnd_adg_package_rec fnd_adg_package%rowtype;
l_spec_code	clob;
l_body_code	clob;
l_rpcDescriptor fnd_adg_manage.rpcDescriptor;

l_remapMethodTokenTable remapMethodTokenArray ;

begin

  select a.*
    into l_fnd_adg_package_rec
    from fnd_adg_package a
   where a.owner = p_owner
     and a.package_name = p_package_name;

  if ( is_reserved_package(l_fnd_adg_package_rec.package_name,
                           l_fnd_adg_package_rec.synonym_only) )
  then
     return;
  end if;

  l_remapMethodTokenTable := remapMethodTokenArray();

  parse_remap_method_entry(l_fnd_adg_package_rec.methods,
                           l_remapMethodTokenTable);

  if ( l_remapMethodTokenTable.count > 0 )
  then
     for i in 1..l_remapMethodTokenTable.count loop

       validate_method_supported(p_owner,p_package_name,
                                 l_remapMethodTokenTable(i).method_name);
     end loop;
  end if;

  select a.spec_code,a.body_code
    into l_spec_code,l_body_code
    from fnd_adg_package a
   where a.owner = p_owner
     and a.package_name = p_package_name
     for update ;

  l_rpcDescriptor.owner        := p_owner;
  l_rpcDescriptor.package_name := p_package_name;
  l_rpcDescriptor.rpc_package_name := l_fnd_adg_package_rec.rpc_package_name;
  l_rpcDescriptor.rpc_synonym_name := l_fnd_adg_package_rec.rpc_synonym_name;

  if ( p_build_spec )
  then
     generate_code_spec(l_rpcDescriptor,l_spec_code);
  end if;

  if ( p_build_body )
  then
     generate_code_body(l_rpcDescriptor,l_body_code);
  end if;

end;

/*==========================================================================*/

procedure build_all_packages
as
cursor c1 is select a.owner,a.package_name,a.synonym_only
               from fnd_adg_package a
              order by a.owner,a.package_name;
begin

  for f_rec in c1 loop

    if ( not is_reserved_package(f_rec.package_name,f_rec.synonym_only) )
    then
       build_package(f_rec.owner,f_rec.package_name);
    end if;

  end loop;

end;

/*==========================================================================*/

procedure compile_directive(p_enable boolean default null)
as
l_spec_code     clob;
l_body_code     clob;
begin

  if ( p_enable is null )
  then
     return;
  end if;

  select a.spec_code,a.body_code
    into l_spec_code,l_body_code
    from fnd_adg_package a
   where a.owner = user
     and a.package_name = C_COMPILE_DIRECTIVE_PACKAGE;

  if ( p_enable )
  then
     compile_package_unit(user,C_COMPILE_DIRECTIVE_PACKAGE,
                          C_COMPILE_DIRECTIVE_PACKAGE,l_spec_code,true);
  else
     compile_package_unit(user,C_COMPILE_DIRECTIVE_PACKAGE,
                          C_COMPILE_DIRECTIVE_PACKAGE,l_body_code,false);
  end if;

end;

/*==========================================================================*/

procedure compile_rpc_dependents
as
cursor c1 is select a.owner,a.package_name,a.rpc_package_name,a.synonym_only
               from fnd_adg_package a
              order by a.owner,a.package_name;
begin

  for f_rec in c1 loop

    if ( not is_reserved_package(f_rec.package_name,f_rec.synonym_only) )
    then
       execute immediate
             'alter package ' || f_rec.owner || '.' || f_rec.rpc_package_name ||
                   ' compile body';

       execute immediate
             'alter package ' || f_rec.owner || '.' || f_rec.package_name ||
                   ' compile body';
    else

       if ( is_reserved_package(f_rec.package_name,f_rec.synonym_only) and
            upper(f_rec.package_name) = upper(C_ADG_MANAGE_PACKAGE) )
       then
          execute immediate
                 'alter package ' || f_rec.owner || '.' || f_rec.package_name ||
                       ' compile body';
       end if;
    end if;

  end loop;

end;

/*==========================================================================*/

procedure validate_package_usage(p_use_rpc_dependency boolean)
as
cursor c1 is select a.owner,a.package_name,a.rpc_package_name,a.methods,
                    a.synonym_only
               from fnd_adg_package a
              order by a.owner,a.package_name;

l_package_count number := 0;
l_valid_count number;
l_referenced_name varchar2(255);
begin

  for f_rec in c1 loop

    if ( not is_reserved_package(f_rec.package_name,f_rec.synonym_only) )
    then
       l_package_count := l_package_count + 1;

		-- We only need to check valid count when doing
		-- rpc dependency checking. Compile directive
		-- is just to check that the correct packages have been
		-- installed.

       if ( p_use_rpc_dependency )
       then

          select count(*)
            into l_valid_count
            from dba_objects a
           where a.owner = f_rec.owner
             and a.object_name = f_rec.package_name
             and a.object_type in ('PACKAGE','PACKAGE BODY')
             and a.status = 'VALID';

          if ( l_valid_count <> 2 )
          then
             fnd_adg_exception.raise_error(
                          fnd_adg_exception.C_OBJERR_USAGE_NOT_VALID,
                          f_rec.package_name
                                          );
          end if;

          select count(*)
            into l_valid_count
            from dba_objects a
           where a.owner = f_rec.owner
             and a.object_name = f_rec.rpc_package_name
             and a.object_type in ('PACKAGE','PACKAGE BODY')
             and a.status = 'VALID';

          if ( l_valid_count <> 2 )
          then
             fnd_adg_exception.raise_error(
                          fnd_adg_exception.C_OBJERR_USAGE_RPC_NOT_VALID,
                          f_rec.rpc_package_name
                                          );
          end if;

       end if;

       if ( p_use_rpc_dependency )
       then
		-- If methods is null then there will be no RPC
		-- dependents. Best we can do is check for compile directive.

          if ( f_rec.methods is null )
          then
             l_referenced_name := C_COMPILE_DIRECTIVE_PACKAGE;
          else
             l_referenced_name := f_rec.rpc_package_name;
          end if;
       else
		-- compile directive only.

          l_referenced_name := C_COMPILE_DIRECTIVE_PACKAGE;

       end if;

       select count(*)
         into l_valid_count
         from dba_dependencies a
        where a.owner  = f_rec.owner
          and a.NAME   = f_rec.package_name
          and a.type   = 'PACKAGE BODY'
          and a.REFERENCED_OWNER = f_rec.owner
          and a.REFERENCED_NAME  = l_referenced_name
          and a.referenced_type  = 'PACKAGE';

       if ( l_valid_count = 0 )
       then
          fnd_adg_exception.raise_error(
                       fnd_adg_exception.C_OBJERR_USAGE_NO_DEP,
                       f_rec.package_name
                                       );
       end if;

    end if;

  end loop;

  if ( l_package_count = 0 )
  then
     fnd_adg_exception.raise_error(
                   fnd_adg_exception.C_OBJERR_USAGE_LIST_IS_EMPTY);
  end if;

end;

/*==========================================================================*/

procedure init_package_list
as
begin

   delete from fnd_adg_package;

   insert_adg_package( package_name => C_ADG_MANAGE_PACKAGE,
                       rpc_package_name => C_ADG_MANAGE_PACKAGE,
                       rpc_synonym_name => C_ADG_MANAGE_NAME_REMOTE
                     );

   insert_adg_package( package_name     => C_COMPILE_DIRECTIVE_PACKAGE,
                       rpc_package_name => C_COMPILE_DIRECTIVE_PACKAGE,
                       rpc_synonym_name => C_COMPILE_DIRECTIVE_PACKAGE||'_NULL'
                     );

/*
   insert_adg_package( package_name     => 'FND_GLOBAL',
                       rpc_package_name => 'FND_GLOBAL_RPC',
                       rpc_synonym_name => 'FND_GLOBAL_REMOTE',
                       methods => 'bless_next_init,initialize'
                     );
*/

   insert_adg_package( package_name     => 'MO_GLOBAL',
                       rpc_package_name => 'MO_GLOBAL_RPC',
                       rpc_synonym_name => 'MO_GLOBAL_REMOTE',
                       methods => null
                     );

   insert_adg_package( package_name     => 'FND_CONCURRENT_REQUESTS',
                       rpc_package_name => 'FND_CONCURRENT_REQUESTS',
                       rpc_synonym_name => 'FND_CONCURRENT_REQUESTS_REMOTE',
                       methods => null,
                       synonym_only => 'Y'
                     );

   insert_adg_package( package_name     => 'FND_MO_SP_PREFERENCES',
                       rpc_package_name => 'FND_MO_SP_PREFERENCES',
                       rpc_synonym_name => 'FND_MO_SP_PREFERENCES_REMOTE',
                       methods => null,
                       synonym_only => 'Y'
                     );

   insert_adg_package( package_name     => 'MO_GLOB_ORG_ACCESS_TMP',
                       rpc_package_name => 'MO_GLOB_ORG_ACCESS_TMP',
                       rpc_synonym_name => 'MO_GLOB_ORG_ACCESS_TMP_REMOTE',
                       methods => null,
                       synonym_only => 'Y'
                     );

/*
   insert_adg_package( package_name     => 'FND_PROFILE',
                       rpc_package_name => 'FND_PROFILE_RPC',
                       rpc_synonym_name => 'FND_PROFILE_REMOTE',
                       methods => 'put'
                     );
*/

   insert_adg_package( package_name     => 'FND_CONCURRENT',
                       rpc_package_name => 'FND_CONCURRENT_RPC',
                       rpc_synonym_name => 'FND_CONCURRENT_REMOTE',
                       -- methods =>'init_request:Y:Y,set_interim_status:Y:Y,'||
                       --           'set_preferred_rbs:Y'
                       methods => null
                     );

end;

/*==========================================================================*/

begin
  null;
end fnd_adg_object;

/
