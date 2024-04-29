--------------------------------------------------------
--  DDL for Package Body ECX_CONDITIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_CONDITIONS" as
-- $Header: ECXCONDB.pls 120.3 2006/05/24 16:07:11 susaha ship $

l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;

function check_type_condition
	(
	type		in	varchar2,
	variable	in	varchar2,
	vartype		in	pls_integer,
	value		in	varchar2,
	valtype		in	pls_integer
	) return boolean
is

i_method_name   varchar2(2000) := 'ecx_conditions.check_type_condition';
i_rnum		number;
i_lnum		number;
i_rdate		date;
i_ldate		date;

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'type',type,i_method_name);
  ecx_debug.log(l_statement,'variable',variable,i_method_name);
  ecx_debug.log(l_statement,'vartype',vartype,i_method_name);
  ecx_debug.log(l_statement,'value',value,i_method_name);
  ecx_debug.log(l_statement,'valtype',valtype,i_method_name);
end if;
	if type not in ('0','1','2','3','4','5','6','7')
	then
		ecx_debug.setErrorInfo(1, 30, 'ECX_UNSUPPORTED_CONDITION_TYPE', 'TYPE', type);
                if(l_statementEnabled) then
                   ecx_debug.log(l_statement, 'ECX', 'ECX_UNSUPPORTED_CONDITION_TYPE', i_method_name,
		                'TYPE', type);
		end if;
		if (l_procedureEnabled) then
                    ecx_debug.pop(i_method_name);
                end if;
		return false;
	end if;

	-- null
	if type = '6'
	then
		if variable is NULL
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return false;
		end if;
	-- Not null
	elsif type = '7'
	then
		if variable is not null
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return false;
		end if;
	end if;

/** String Comparisons **/
if ( vartype = 1 or valtype = 1)
then
	-- Equal
	if type = '0'
	then
		if variable = value
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;

	-- Not Equal
	elsif type = '1'
	then
		if ( ( variable is null) or ( value is null)  or (variable <> value ) )
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;

	-- Grater Than
	elsif type = '2'
	then
		if variable > value
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;
	-- Less Than
	elsif type = '3'
	then
		if variable < value
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;

	-- Greater than or Equal To
	elsif type = '4'
	then
		if variable >= value
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;

	-- Less than or Equal To
	elsif type = '5'
	then
		if variable <= value
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;
	else
			ecx_debug.setErrorInfo(1, 30, 'ECX_UNSUPPORTED_STRING_CONDITION');
			if(l_statementEnabled) then
                             ecx_debug.log(l_statement, 'ECX', 'ECX_UNSUPPORTED_STRING_CONDITION',i_method_name);
			end if;
			raise ecx_utils.program_exit;
	end if;

/** Number Comparisons **/
elsif ( vartype = 2 and valtype = 2)
then
	begin
		i_rnum := variable;
		i_lnum := value;
	exception
	when others then
		ecx_debug.setErrorInfo(1, 30, 'ECX_CANNOT_CONVERT_TO_NUMBER');
		if(l_unexpectedEnabled) then
                    ecx_debug.log(l_unexpected, 'ECX', 'ECX_CANNOT_CONVERT_TO_NUMBER', i_method_name);
	        end if;
		raise ecx_utils.program_exit;
	end;

	-- Equal
	if type = '0'
	then
		if i_rnum = i_lnum
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		end if;

	-- Not Equal
	elsif type = '1'
	then
		if ( i_rnum is null) or ( i_lnum is null ) or (i_rnum <> i_lnum)
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;

	-- Grater Than
	elsif type = '2'
	then
		if i_rnum > i_lnum
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;
	-- Less Than
	elsif type = '3'
	then
		if i_rnum < i_lnum
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;

	-- Greater than or Equal To
	elsif type = '4'
	then
		if i_rnum >= i_lnum
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;

	-- Less than or Equal To
	elsif type = '5'
	then
		if i_rnum <= i_lnum
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;
	else
			ecx_debug.setErrorInfo (1, 30, 'ECX_UNSUPPORTED_NUMBER_CONDITION');
			if(l_statementEnabled) then
                              ecx_debug.log(l_statement,'ECX', 'ECX_UNSUPPORTED_NUMBER_CONDITION', i_method_name);
			end if;
			raise ecx_utils.program_exit;
	end if;

/** Date Comparisons **/
elsif ( vartype = 12 and valtype = 12 )
then
	begin
		i_rdate := to_date(variable,'YYYYMMDD HH24MISS');
		i_ldate := to_date(value,'YYYYMMDD HH24MISS');
	exception
	when others then
		ecx_debug.setErrorInfo(1, 30, 'ECX_CANNOT_CONVERT_TO_DATE');
		if(l_unexpectedEnabled) then
                       ecx_debug.log(l_unexpected, 'ECX', 'ECX_CANNOT_CONVERT_TO_DATE', i_method_name);
		end if;
		raise ecx_utils.program_exit;
	end;

	-- Equal
	if type = '0'
	then
		if i_rdate = i_ldate
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;

	-- Not Equal
	elsif type = '1'
	then
		if (i_rdate is null ) or (i_ldate is null ) or (i_rdate <> i_ldate)
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;

	-- Grater Than
	elsif type = '2'
	then
		if i_rdate > i_ldate
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;
	-- Less Than
	elsif type = '3'
	then
		if i_rdate < i_ldate
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;

	-- Greater than or Equal To
	elsif type = '4'
	then
		if i_rdate >= i_ldate
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;

	-- Less than or Equal To
	elsif type = '5'
	then
		if i_rdate <= i_ldate
		then
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','TRUE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
                        end if;
			return true;
		else
			if(l_statementEnabled) then
                            ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
			end if;
			if (l_procedureEnabled) then
                            ecx_debug.pop(i_method_name);
			end if;
			return false;
		end if;
	else
			ecx_debug.setErrorInfo(1, 30, 'ECX_UNSUPPORTED_DATE_CONDITION');
			if(l_statementEnabled) then
                           ecx_debug.log(l_statement, 'ECX', 'ECX_UNSUPPORTED_DATE_CONDITION', i_method_name);
			end if;
			raise ecx_utils.program_exit;
	end if;

end if; --- end for the datatype comparisons

if(l_statementEnabled) then
   ecx_debug.log(l_statement, 'Condition','FALSE', i_method_name);
end if;
if (l_procedureEnabled) then
   ecx_debug.pop(i_method_name);
end if;
return false;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
exception
when ecx_utils.program_exit then
	if (l_procedureEnabled) then
             ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when others then
        ecx_debug.setErrorInfo(2, 30, SQLERRM);
	if (l_procedureEnabled) then
             ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end check_type_condition;

function check_condition
	(
	type		in	varchar2,  -- AND,OR
	type1		in	varchar2, --- =,!=,>,<,>=,<=,null,not null
	variable1	in	varchar2,
	vartype1	in	pls_integer,
	value1		in	varchar2,
	valtype1	in	pls_integer,
	type2		in	varchar2,
	variable2	in	varchar2,
	vartype2	in	pls_integer,
	value2		in	varchar2,
	valtype2	in	pls_integer
	) return boolean
is


i_method_name   varchar2(2000) := 'ecx_conditions.check_condition';

i_condition	boolean :=false;
i_condition1	boolean :=false;
i_condition2	boolean :=false;
begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'type',type,i_method_name);
  ecx_debug.log(l_statement,'type1',type1,i_method_name);
  ecx_debug.log(l_statement,'variable1',variable1,i_method_name);
  ecx_debug.log(l_statement,'vartype1',vartype1,i_method_name);
  ecx_debug.log(l_statement,'value1',value1,i_method_name);
  ecx_debug.log(l_statement,'valtype1',valtype1,i_method_name);
  ecx_debug.log(l_statement,'type2',type2,i_method_name);
  ecx_debug.log(l_statement,'variable2',variable2,i_method_name);
  ecx_debug.log(l_statement,'vartype2',vartype2,i_method_name);
  ecx_debug.log(l_statement,'value2',value2,i_method_name);
  ecx_debug.log(l_statement,'valtype2',valtype2,i_method_name);
end if;

if type1 is null
then
	if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
       end if;
	return false;
end if;

if type1 is not null
then
	i_condition1 := check_type_condition(type1,variable1,vartype1,value1,valtype1);
end if;

if type is not null
then

	if type not in ('AND','OR')
	then
		ecx_debug.setErrorInfo(1, 30, 'ECX_UNSUPPORTED_CONDITION_TYPE', 'TYPE', type);
		if(l_statementEnabled) then
                  ecx_debug.log(l_statement,'ECX', 'ECX_UNSUPPORTED_CONDITION_TYPE',i_method_name,
		              'TYPE', type);
	        end if;
		if (l_procedureEnabled) then
                  ecx_debug.pop(i_method_name);
                end if;
		return false;
	end if;

	if ( type2 is null )
	then
                ecx_debug.setErrorInfo(1, 30, 'ECX_CONDITION_NOT_DEFINED', 'TYPE', type2);
                if(l_statementEnabled) then
                    ecx_debug.log(l_statement,'ECX', 'ECX_CONDITION_NOT_DEFINED',i_method_name,
		                'TYPE', type2);
		end if;
		if (l_procedureEnabled) then
                   ecx_debug.pop(i_method_name);
               end if;
		return false;
	end if;

	i_condition2 := check_type_condition(type2,variable2,vartype2,value2,valtype2);

	if type = 'AND'
	then
		if ( i_condition1 and i_condition2 )
		then
			if (l_procedureEnabled) then
                           ecx_debug.pop(i_method_name);
                        end if;
			return true;
		end if;
	elsif type = 'OR'
	then
		if ( i_condition1 or i_condition2 )
		then
			if (l_procedureEnabled) then
                          ecx_debug.pop(i_method_name);
                        end if;
			return true;
		end if;
	else
		if (l_procedureEnabled) then
                   ecx_debug.pop(i_method_name);
               end if;
		return false;
	end if;

elsif type1 is not null
then
	if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
	return i_condition1;
end if;

exception
when ecx_utils.program_exit then
	if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when others then
        ecx_debug.setErrorInfo(2, 30, SQLERRM);
        if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected, 'ECX', SQLERRM,i_method_name);
	end if;
	if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
end if;
end check_condition;

function math_functions
	(
	type	in	varchar2,
	x	in	number,
	y	in	number
	)
	return number
is

i_method_name   varchar2(2000) := 'ecx_conditions.math_functions';

divide_by_zero	exception;
pragma		exception_init(divide_by_zero,-1476);
begin

if (l_procedureEnabled) then
   ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'type',type,i_method_name);
  ecx_debug.log(l_statement,'x',x,i_method_name);
  ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
if type is null
then
	ecx_debug.setErrorInfo(1, 30, 'ECX_MATH_FUNC_NOT_NULL');
	if (l_procedureEnabled) then
              ecx_debug.pop(i_method_name);
        end if;

	raise ecx_utils.program_exit;
end if;

if type not in ('+','-','/','*')
then
	ecx_debug.setErrorInfo(1, 30, 'ECX_UNSUPPORTED_MATH_FUNC');
	if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end if;

if type = '+'
then
	if(l_statementEnabled) then
            ecx_debug.log(l_statement,'x+y',x+y,i_method_name);
	end if;
	if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
        end if;
	return x+y;
elsif type = '-'
then
	if(l_statementEnabled) then
            ecx_debug.log(l_statement,'x-y',x-y,i_method_name);
	end if;
	if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
        end if;
	return x-y;
elsif type = '*'
then
	if(l_statementEnabled) then
            ecx_debug.log(l_statement,'x*y',x*y,i_method_name);
	end if;
	if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
        end if;
	return x*y;
elsif type = '/'
then
	if(l_statementEnabled) then
            ecx_debug.log(l_statement,'x/y',x/y,i_method_name);
	end if;
	if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
        end if;
	return x/y;
end if;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
exception
when divide_by_zero then
        ecx_debug.setErrorInfo(2, 30, SQLERRM);
        if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected, 'ECX', SQLERRM,i_method_name);
	end if;
	if (l_procedureEnabled) then
              ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when others then
        ecx_debug.setErrorInfo(2, 30, SQLERRM);
	if (l_procedureEnabled) then
              ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end math_functions;

procedure getLengthForString
	(
	i_string        in      varchar2,
	i_length        OUT     NOCOPY pls_integer
	)
is


i_method_name   varchar2(2000) := 'ecx_conditions.getLengthForString';

begin
	if (l_procedureEnabled) then
          ecx_debug.push(i_method_name);
        end if;
	if(l_statementEnabled) then
          ecx_debug.log(l_statement,'i_string',i_string,i_method_name);
	end if;
		i_length := lengthb(i_string);
	if(l_statementEnabled) then
          ecx_debug.log(l_statement,'i_length',i_length,i_method_name);
	end if;
	if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;

exception
when others then
        ecx_debug.setErrorInfo(2, 30, substr(SQLERRM, 1, 200));
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', substr(SQLERRM, 1, 200),i_method_name);
	end if;
	if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end getLengthForString;

procedure getPositionInString
	(
	i_string                in      varchar2,
	i_search_string         in      varchar2,
	i_start_position        in      pls_integer,
	i_occurrence            in      pls_integer,
	i_position              OUT     NOCOPY pls_integer
	)
is
i_method_name   varchar2(2000) := 'ecx_conditions.getPositionInString';
begin
	if (l_procedureEnabled) then
           ecx_debug.push(i_method_name);
        end if;
	if(l_statementEnabled) then
           ecx_debug.log(l_statement,'i_string',i_string,i_method_name);
	   ecx_debug.log(l_statement,'i_search_string',i_search_string,i_method_name);
	   ecx_debug.log(l_statement,'i_start_position',i_start_position,i_method_name);
	   ecx_debug.log(l_statement,'i_occurrence',i_occurrence,i_method_name);
	end if;
		i_position := instrb(i_string,i_search_string,i_start_position,i_occurrence);
	if(l_statementEnabled) then
           ecx_debug.log(l_statement,'i_position',i_position,i_method_name);
	end if;
	if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
        end if;
exception
when others then
        ecx_debug.setErrorInfo(2, 30, substr(SQLERRM, 1, 200));
	if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end getPositionInString;

procedure getSubString
	(
	i_string                in      varchar2,
	i_start_position        in      pls_integer,
	i_length            	in      pls_integer,
	i_substr              	OUT     NOCOPY varchar2
	)
is
i_method_name   varchar2(2000) := 'ecx_conditions.getSubString';
begin
	 if (l_procedureEnabled) then
            ecx_debug.push(i_method_name);
        end if;
	if(l_statementEnabled) then
           ecx_debug.log(l_statement,'i_string',i_string,i_method_name);
	   ecx_debug.log(l_statement,'i_start_position',i_start_position,i_method_name);
	   ecx_debug.log(l_statement,'i_length',i_length,i_method_name);
	end if;
		i_substr := substrb(i_string,i_start_position,i_length);
	if(l_statementEnabled) then
           ecx_debug.log(l_statement,'i_substr',i_substr,i_method_name);
	end if;
	if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
exception
when others then
        ecx_debug.setErrorInfo(2, 30, substr(SQLERRM,1,200));
	if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end getSubString;

procedure test
is
i_method_name   varchar2(2000) := 'ecx_conditions.test';
i	number;
y	boolean;
i_date1	varchar2(200) := '20010101';
i_date2	varchar2(200) := '20010102';

i_dtd_path	varchar2(200);
begin
ecx_utils.i_errbuf :=null;
ecx_utils.i_ret_code :=null;

ecx_utils.getLogDirectory;

ecx_debug.enable_debug_new(3,ecx_utils.g_logdir,'test_conditions.txt', 'test_conditions.txt');

if(l_statementEnabled) then
	ecx_debug.log(l_statement,'testing conditions ',i_method_name);
	ecx_debug.log(l_statement,'String conditions ',i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'0','veshaal',1,'veshaal',1,null,null,1,null,1);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'1','veshaal',1,'1veshaal',1,null,null,1,null,1);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'6','3',1,'4',1,null,null,1,null,1);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'7','3',1,'4',1,null,null,1,null,1);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;

if(l_statementEnabled) then
	ecx_debug.log(l_statement,'Number conditions ',i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'0','-10.555',2,'-10.555',2,null,null,2,null,2);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'1','-10.555',2,'-10.555',2,null,null,2,null,2);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'2','-10.555',2,'-10.555',2,null,null,2,null,2);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'3','-.002',2,'-.001',2,null,null,2,null,2);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'4','-100',2,'-120',2,null,null,2,null,2);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'5','-100',2,'-110.5',2,null,null,2,null,2);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'6','3',2,'4',2,null,null,2,null,2);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'7','3',2,'4',2,null,null,2,null,2);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;

if(l_statementEnabled) then
	ecx_debug.log(l_statement,'Date conditions ',i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'0',i_date1,12,i_date2,12,null,null,12,null,12);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'1',i_date1,12,i_date2,12,null,null,12,null,12);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'2',i_date1,12,i_date2,12,null,null,12,null,12);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'3',i_date1,12,i_date2,12,null,null,12,null,12);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'4',i_date1,12,i_date2,12,null,null,12,null,12);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'5',i_date1,12,i_date2,12,null,null,12,null,12);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'6',i_date1,12,i_date2,12,null,null,12,null,12);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;
	y := ecx_conditions.check_condition(null,'7',i_date1,12,i_date2,12,null,null,12,null,12);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'y',y,i_method_name);
end if;

if(l_statementEnabled) then
	ecx_debug.log(l_statement,'testing length procedure',i_method_name);
end if;
	ecx_conditions.getlengthforString('htihgoitrhogirtoigtroighoirhgoitirgoitrh',i);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i',i,i_method_name);
end if;

	ecx_conditions.getlengthforString(null,i);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i',i,i_method_name);
end if;

if(l_statementEnabled) then
	ecx_debug.log(l_statement,'testing instrb procedure',i_method_name);
end if;
	ecx_conditions.getpositioninString('htihgoitrhogirtoigtroighoirhgoitirgoitrh','hg',1,1,i);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i',i,i_method_name);
end if;
	ecx_conditions.getpositioninString('htihgoitrhogirtoigtroighoirhgoitirgoitrh','hg',1,2,i);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i',i,i_method_name);
end if;
	ecx_conditions.getpositioninString('htihgoitrhogirtoigtroighoirhgoitirgoitrh',null,1,2,i);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i',i,i_method_name);
end if;

if(l_statementEnabled) then
	ecx_debug.log(l_statement,'testing substrb procedure',i_method_name);
end if;
	ecx_conditions.getsubstring('htihgoitrhogirtoigtroighoirhgoitirgoitrh',1,20,i_date1);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i_date1',i_date1,i_method_name);
end if;
	ecx_conditions.getsubstring('htihgoitrhogirtoigtroighoirhgoitirgoitrh',1,null,i_date1);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i_date1',i_date1,i_method_name);
end if;
	ecx_conditions.getsubstring('htihgoitrhogirtoigtroighoirhgoitirgoitrh',null,null,i_date1);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i_date1',i_date1,i_method_name);
end if;

if(l_statementEnabled) then
	ecx_debug.log(l_statement,'testing math functions',i_method_name);
end if;
	i := ecx_conditions.math_functions('+',1,null);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i',i,i_method_name);
end if;
	i := ecx_conditions.math_functions('-',1,2);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i',i,i_method_name);
end if;
	i := ecx_conditions.math_functions('*',1,2);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i',i,i_method_name);
end if;
	i := ecx_conditions.math_functions('/',1,0);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i',i,i_method_name);
end if;
	i := ecx_conditions.math_functions('6',1,2);
if(l_statementEnabled) then
	ecx_debug.log(l_statement,'i',i,i_method_name);
end if;

ecx_debug.print_log;
ecx_debug.disable_debug;
exception
when others then
if(l_unexpectedEnabled) then
	ecx_debug.log(l_unexpected,'i_errbuf',ecx_utils.i_errbuf,i_method_name);
	ecx_debug.log(l_unexpected,'i_retcode',ecx_utils.i_ret_code,i_method_name);
end if;
	ecx_debug.print_log;
	ecx_debug.disable_debug;
end test;

end ecx_conditions;

/
