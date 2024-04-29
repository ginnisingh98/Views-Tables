--------------------------------------------------------
--  DDL for Package OKC_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_WF" authid current_user as
/*$Header: OKCRWFSS.pls 120.0.12010000.2 2008/10/24 08:02:52 ssreekum ship $*/

subtype p_outcomerec_type is okc_outcome_init_pvt.p_outcomerec_type;
subtype p_outcometbl_type is okc_outcome_init_pvt.p_outcometbl_type;
-- we use the above table as outcome's parameters table for building the
-- formatted string with the parameters for sending to workflow process

/* definitions for the above subtypes as it is defined in okc code
just for info
 TYPE p_outcomerec_type IS RECORD(
    name        okc_process_def_parameters_v.name%TYPE,
    data_type   okc_process_def_parameters_v.data_type%TYPE,
    value       okc_process_def_parameters_v.default_value%TYPE);
 TYPE p_outcometbl_type IS TABLE OF p_outcomerec_type
 INDEX BY BINARY_INTEGER;
*/

procedure init_wf_string;  -- clean the string
-- set the string if you know it's format (know what are you doing)
procedure init_wf_string(p_wf in varchar2);

-- builds the string from outcome name and outcome parameters table
-- (see above the table definition)
-- it's exactly like it has been used in okc code
function build_wf_string(   p_outcome_name in varchar2,
                            p_outcome_tbl in p_outcometbl_type
                            )   return varchar2;

-- call the below two procedures if you want to build the formatted string
-- yourself

-- set the string header (it's outcome name setting)
procedure init_wf_header(p_head in varchar2);

-- call the procedure in loop after the previous one if you want build the
-- formatted string without outcome parameters table usage (it's parameters
-- settings)
-- only valid parameter types are ('DATE','CHAR','NUMBER') - skips all others
procedure append_wf_string( p_dnum in number,
                            p_dname in varchar2,
                            p_dtype in varchar2,
                            p_dvalue in varchar2
                            );
/*
the formatted string looks like (for example):

\h=OKC_TEST.UPD_COMMENTS
\#=1\t=N\n=P_API_VERSION\l=3\v=1.0
\#=2\t=C\n=P_COMMENTS\l=28\v=the contract has been signed
\#=3\t=C\n=P_NEW_K_MODIFIER\l=19\v=OKC_API.G_MISS_CHAR
\#=4\t=C\n=P_NEW_K_NUMBER\l=5\v=mar11
\#=5\t=N\n=P_OLD_KID\l=39\v=267689698479967951429302244026754724781

structure of the formatted string:
\h - outcome name
\# - parameter number
\t - parameter type (only valid C/N/D (CHAR/NUMBER/DATE))
\n - parameter name
\l - parameter's value length
\v - parameter's value
*/

function get_wf_string return varchar2;   -- get the string

-- gets p_num'th parameter from the string returns it as number
function Nvalue(p_num in number) return number;

-- gets p_num'th parameter from the string returns it as date
function Dvalue(p_num in number) return date;

-- gets p_num'th parameter from the string returns it as varchar2
function Cvalue(p_num in number) return varchar2;

-- pre-builds the plsql procedure call (pre-build means - there is no standard
-- trail for the call)
function prebuild_wf_plsql  return varchar2;
function prebuild_wf_plsql(p_wf in varchar2)   return varchar2;

-- builds and returns the plsql call - uses prebuild_wf_plsql output as input
-- parameter and adds standard trail and 'begin' ... 'end'
function build_wf_plsql(p_prebuilt_wf_plsql in varchar2)   return varchar2;

-- executes the built plsql call (only for testing and debugging)
function exec_wf_plsql(p_proc in varchar2)   return varchar2;

End okc_wf;

/
