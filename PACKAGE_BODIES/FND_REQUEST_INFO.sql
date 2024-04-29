--------------------------------------------------------
--  DDL for Package Body FND_REQUEST_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_REQUEST_INFO" as
/* $Header: AFCPRINB.pls 120.2 2005/08/19 20:47:22 jtoruno ship $ */



  -- PRIVATE VARIABLES
  --

        P_nargs			number		:= null;
	P_ProgName		varchar2(30)    := null;
        P_ProgAppName		varchar2(30)    := null;
        P_ReqStartDate		date		:= null;
        P_reqid			number		:= null;
        P_count			integer         := null;
        P_increment_flag	varchar2(1)     :='N';
	P_nls_territory		varchar2(30)	:= null;
        P_errbuf		varchar2(240)	:= null;
	P_arg1			varchar2(240)    := CHR(0);
	P_arg2			varchar2(240)    := CHR(0);
	P_arg3			varchar2(240)    := CHR(0);
	P_arg4			varchar2(240)    := CHR(0);
	P_arg5			varchar2(240)    := CHR(0);
	P_arg6			varchar2(240)    := CHR(0);
	P_arg7			varchar2(240)    := CHR(0);
	P_arg8			varchar2(240)    := CHR(0);
	P_arg9			varchar2(240)    := CHR(0);
	P_arg10			varchar2(240)    := CHR(0);
	P_arg11			varchar2(240)    := CHR(0);
	P_arg12			varchar2(240)    := CHR(0);
	P_arg13			varchar2(240)    := CHR(0);
	P_arg14			varchar2(240)    := CHR(0);
	P_arg15			varchar2(240)    := CHR(0);
	P_arg16			varchar2(240)    := CHR(0);
	P_arg17			varchar2(240)    := CHR(0);
	P_arg18			varchar2(240)    := CHR(0);
	P_arg19			varchar2(240)    := CHR(0);
	P_arg20			varchar2(240)    := CHR(0);
	P_arg21			varchar2(240)    := CHR(0);
	P_arg22			varchar2(240)    := CHR(0);
	P_arg23			varchar2(240)    := CHR(0);
	P_arg24			varchar2(240)    := CHR(0);
	P_arg25			varchar2(240)    := CHR(0);
	P_arg26			varchar2(240)    := CHR(0);
	P_arg27			varchar2(240)    := CHR(0);
	P_arg28			varchar2(240)    := CHR(0);
	P_arg29			varchar2(240)    := CHR(0);
	P_arg30			varchar2(240)    := CHR(0);
	P_arg31			varchar2(240)    := CHR(0);
	P_arg32			varchar2(240)    := CHR(0);
	P_arg33			varchar2(240)    := CHR(0);
	P_arg34			varchar2(240)    := CHR(0);
	P_arg35			varchar2(240)    := CHR(0);
	P_arg36			varchar2(240)    := CHR(0);
	P_arg37			varchar2(240)    := CHR(0);
	P_arg38			varchar2(240)    := CHR(0);
	P_arg39			varchar2(240)    := CHR(0);
	P_arg40			varchar2(240)    := CHR(0);
	P_arg41			varchar2(240)    := CHR(0);
	P_arg42			varchar2(240)    := CHR(0);
	P_arg43			varchar2(240)    := CHR(0);
	P_arg44			varchar2(240)    := CHR(0);
	P_arg45			varchar2(240)    := CHR(0);
	P_arg46			varchar2(240)    := CHR(0);
	P_arg47			varchar2(240)    := CHR(0);
	P_arg48			varchar2(240)    := CHR(0);
	P_arg49			varchar2(240)    := CHR(0);
	P_arg50			varchar2(240)    := CHR(0);
	P_arg51			varchar2(240)    := CHR(0);
	P_arg52			varchar2(240)    := CHR(0);
	P_arg53			varchar2(240)    := CHR(0);
	P_arg54			varchar2(240)    := CHR(0);
	P_arg55			varchar2(240)    := CHR(0);
	P_arg56			varchar2(240)    := CHR(0);
	P_arg57			varchar2(240)    := CHR(0);
	P_arg58			varchar2(240)    := CHR(0);
	P_arg59			varchar2(240)    := CHR(0);
	P_arg60			varchar2(240)    := CHR(0);
	P_arg61			varchar2(240)    := CHR(0);
	P_arg62			varchar2(240)    := CHR(0);
	P_arg63			varchar2(240)    := CHR(0);
	P_arg64			varchar2(240)    := CHR(0);
	P_arg65			varchar2(240)    := CHR(0);
	P_arg66			varchar2(240)    := CHR(0);
	P_arg67			varchar2(240)    := CHR(0);
	P_arg68			varchar2(240)    := CHR(0);
	P_arg69			varchar2(240)    := CHR(0);
	P_arg70			varchar2(240)    := CHR(0);
	P_arg71			varchar2(240)    := CHR(0);
	P_arg72			varchar2(240)    := CHR(0);
	P_arg73			varchar2(240)    := CHR(0);
	P_arg74			varchar2(240)    := CHR(0);
	P_arg75			varchar2(240)    := CHR(0);
	P_arg76			varchar2(240)    := CHR(0);
	P_arg77			varchar2(240)    := CHR(0);
	P_arg78			varchar2(240)    := CHR(0);
	P_arg79			varchar2(240)    := CHR(0);
	P_arg80			varchar2(240)    := CHR(0);
	P_arg81			varchar2(240)    := CHR(0);
	P_arg82			varchar2(240)    := CHR(0);
	P_arg83			varchar2(240)    := CHR(0);
	P_arg84			varchar2(240)    := CHR(0);
	P_arg85			varchar2(240)    := CHR(0);
	P_arg86			varchar2(240)    := CHR(0);
	P_arg87			varchar2(240)    := CHR(0);
	P_arg88			varchar2(240)    := CHR(0);
	P_arg89			varchar2(240)    := CHR(0);
	P_arg90			varchar2(240)    := CHR(0);
	P_arg91			varchar2(240)    := CHR(0);
	P_arg92			varchar2(240)    := CHR(0);
	P_arg93			varchar2(240)    := CHR(0);
	P_arg94			varchar2(240)    := CHR(0);
	P_arg95			varchar2(240)    := CHR(0);
	P_arg96			varchar2(240)    := CHR(0);
	P_arg97			varchar2(240)    := CHR(0);
	P_arg98			varchar2(240)    := CHR(0);
	P_arg99			varchar2(240)    := CHR(0);
	P_arg100		varchar2(240)    := CHR(0);


        P_errnum		number		:= 0;
        P_fsegs			fnd_dflex.segments_dr;


procedure initialize is

flexi fnd_dflex.dflex_dr;
fcontexts fnd_dflex.contexts_dr;
fcontext fnd_dflex.context_r;
prog_app_name varchar2(30);
prog_name varchar2(30);

begin

   P_reqid  := fnd_global.conc_request_id;

   select
   		ARGUMENT1, ARGUMENT2, ARGUMENT3, ARGUMENT4, ARGUMENT5,
   		ARGUMENT6, ARGUMENT7, ARGUMENT8, ARGUMENT9, ARGUMENT10,
   		ARGUMENT11, ARGUMENT12, ARGUMENT13, ARGUMENT14, ARGUMENT15,
   		ARGUMENT16, ARGUMENT17, ARGUMENT18, ARGUMENT19, ARGUMENT20,
   		ARGUMENT21, ARGUMENT22, ARGUMENT23, ARGUMENT24, ARGUMENT25,
	 	 Argument26, Argument27, Argument28, Argument29, Argument30,
                 Argument31, Argument32, Argument33, Argument34, Argument35,
                 Argument36, Argument37, Argument38, Argument39, Argument40,
                 Argument41, Argument42, Argument43, Argument44, Argument45,
                 Argument46, Argument47, Argument48, Argument49, Argument50,
                 Argument51, Argument52, Argument53, Argument54, Argument55,
                 Argument56, Argument57, Argument58, Argument59, Argument60,
                 Argument61, Argument62, Argument63, Argument64, Argument65,
                 Argument66, Argument67, Argument68, Argument69, Argument70,
                 Argument71, Argument72, Argument73, Argument74, Argument75,
                 Argument76, Argument77, Argument78, Argument79, Argument80,
                 Argument81, Argument82, Argument83, Argument84, Argument85,
                 Argument86, Argument87, Argument88, Argument89, Argument90,
                 Argument91, Argument92, Argument93, Argument94, Argument95,
                 Argument96, Argument97, Argument98, Argument99, Argument100,
   		 CONCURRENT_PROGRAM_NAME, APPLICATION_SHORT_NAME, NLS_TERRITORY
   into
   		P_arg1,  P_arg2,  P_arg3,  P_arg4,  P_arg5,  P_arg6, P_arg7,
   		P_arg8,  P_arg9,  P_arg10, P_arg11, P_arg12, P_arg13, P_arg14,
   		P_arg15, P_arg16, P_arg17, P_arg18, P_arg19, P_arg20,
   		P_arg21, P_arg22, P_arg23, P_arg24, P_arg25,
                P_arg26, P_arg27, P_arg28, P_arg29, P_arg30,
		P_arg31, P_arg32, P_arg33, P_arg34, P_arg35,
		P_arg36, P_arg37, P_arg38, P_arg39, P_arg40,
		P_arg41, P_arg42, P_arg43, P_arg44, P_arg45,
		P_arg46, P_arg47, P_arg48, P_arg49, P_arg50,
		P_arg51, P_arg52, P_arg53, P_arg54, P_arg55,
		P_arg56, P_arg57, P_arg58, P_arg59, P_arg60,
		P_arg61, P_arg62, P_arg63, P_arg64, P_arg65,
		P_arg66, P_arg67, P_arg68, P_arg69, P_arg70,
		P_arg71, P_arg72, P_arg73, P_arg74, P_arg75,
		P_arg76, P_arg77, P_arg78, P_arg79, P_arg80,
		P_arg81, P_arg82, P_arg83, P_arg84, P_arg85,
		P_arg86, P_arg87, P_arg88, P_arg89, P_arg90,
		P_arg91, P_arg92, P_arg93, P_arg94, P_arg95,
		P_arg96, P_arg97, P_arg98, P_arg99, P_arg100,
   		prog_name, prog_app_name, P_nls_territory
   from  fnd_run_requests r,
         fnd_concurrent_programs p,
         fnd_application a
   where r.parent_request_id      = fnd_global.conc_request_id
     and r.concurrent_program_id  = p.concurrent_program_id
     and r.application_id         = p.application_id
     and r.application_id 	  = a.application_id;



   fnd_dflex.get_flexfield(prog_app_name, '$SRS$.' || prog_name,
	fcontext.flexfield, flexi);
   fnd_dflex.get_contexts(fcontext.flexfield, fcontexts);
   fcontext.context_code := fcontexts.context_code(fcontexts.global_context);
   fnd_dflex.get_segments(fcontext,P_fsegs, TRUE);

   P_ProgName := prog_name;
   P_ProgAppName := prog_app_name;

end;


FUNCTION GET_REQUEST_ID return number is
begin

   if (P_reqid is null) then
      return (0);
   else
      return ( P_reqid );
   end if;

end;


FUNCTION GET_PARAM_INFO(Param_num in number,
                        Name out nocopy varchar2)
return number is
begin

  if (Param_num>P_fsegs.nsegments) then
    return (-1);
  end if;

  Name := P_fsegs.segment_name(Param_num);

  return(0);
end;


FUNCTION GET_PARAM_NUMBER(name in varchar2,
                          Param_num out nocopy number)
return number is

counter number;

begin
  if (P_fsegs.nsegments < 1) then
     return (-1);
  end if;

  counter := 1;
  while ((counter < P_fsegs.nsegments) and
         (Name <> P_fsegs.segment_name(counter))) loop
              counter := counter + 1;
  end loop;

  IF (Name <> P_fsegs.segment_name(counter)) then
     return (-1);
  end if;

  Param_num := counter;

  return(0);

end;



PROCEDURE GET_PROGRAM(PROG_NAME out nocopy VARCHAR2,
                      PROG_APP_NAME out nocopy varchar2) is

begin
   PROG_NAME := P_ProgName;
   PROG_APP_NAME := P_ProgAppName;
end;


FUNCTION GET_PARAMETER(param_num in number) return varchar2 is

begin
--	if (param_num > P_nargs) then return(NULL); end if;

	if (param_num = 1) then return(P_arg1); end if;
	if (param_num = 2) then return(P_arg2); end if;
	if (param_num = 3) then return(P_arg3); end if;
	if (param_num = 4) then return(P_arg4); end if;
	if (param_num = 5) then return(P_arg5); end if;
	if (param_num = 6) then return(P_arg6); end if;
	if (param_num = 7) then return(P_arg7); end if;
	if (param_num = 8) then return(P_arg8); end if;
	if (param_num = 9) then return(P_arg9); end if;
	if (param_num = 10) then return(P_arg10); end if;
	if (param_num = 11) then return(P_arg11); end if;
	if (param_num = 12) then return(P_arg12); end if;
	if (param_num = 13) then return(P_arg13); end if;
	if (param_num = 14) then return(P_arg14); end if;
	if (param_num = 15) then return(P_arg15); end if;
	if (param_num = 16) then return(P_arg16); end if;
	if (param_num = 17) then return(P_arg17); end if;
	if (param_num = 18) then return(P_arg18); end if;
	if (param_num = 19) then return(P_arg19); end if;
	if (param_num = 20) then return(P_arg20); end if;
	if (param_num = 21) then return(P_arg21); end if;
	if (param_num = 22) then return(P_arg22); end if;
	if (param_num = 23) then return(P_arg23); end if;
	if (param_num = 24) then return(P_arg24); end if;
	if (param_num = 25) then return(P_arg25); end if;
	if (param_num = 26) then return(P_arg26); end if;
	if (param_num = 27) then return(P_arg27); end if;
	if (param_num = 28) then return(P_arg28); end if;
	if (param_num = 29) then return(P_arg29); end if;
	if (param_num = 30) then return(P_arg30); end if;
	if (param_num = 31) then return(P_arg31); end if;
	if (param_num = 32) then return(P_arg32); end if;
	if (param_num = 33) then return(P_arg33); end if;
	if (param_num = 34) then return(P_arg34); end if;
	if (param_num = 35) then return(P_arg35); end if;
	if (param_num = 36) then return(P_arg36); end if;
	if (param_num = 37) then return(P_arg37); end if;
	if (param_num = 38) then return(P_arg38); end if;
	if (param_num = 39) then return(P_arg39); end if;
	if (param_num = 40) then return(P_arg40); end if;
	if (param_num = 41) then return(P_arg41); end if;
	if (param_num = 42) then return(P_arg42); end if;
	if (param_num = 43) then return(P_arg43); end if;
	if (param_num = 44) then return(P_arg44); end if;
	if (param_num = 45) then return(P_arg45); end if;
	if (param_num = 46) then return(P_arg46); end if;
	if (param_num = 47) then return(P_arg47); end if;
	if (param_num = 48) then return(P_arg48); end if;
	if (param_num = 49) then return(P_arg49); end if;
	if (param_num = 50) then return(P_arg50); end if;
	if (param_num = 51) then return(P_arg51); end if;
	if (param_num = 52) then return(P_arg52); end if;
	if (param_num = 53) then return(P_arg53); end if;
	if (param_num = 54) then return(P_arg54); end if;
	if (param_num = 55) then return(P_arg55); end if;
	if (param_num = 56) then return(P_arg56); end if;
	if (param_num = 57) then return(P_arg57); end if;
	if (param_num = 58) then return(P_arg58); end if;
	if (param_num = 59) then return(P_arg59); end if;
	if (param_num = 60) then return(P_arg60); end if;
	if (param_num = 61) then return(P_arg61); end if;
	if (param_num = 62) then return(P_arg62); end if;
	if (param_num = 63) then return(P_arg63); end if;
	if (param_num = 64) then return(P_arg64); end if;
	if (param_num = 65) then return(P_arg65); end if;
	if (param_num = 66) then return(P_arg66); end if;
	if (param_num = 67) then return(P_arg67); end if;
	if (param_num = 68) then return(P_arg68); end if;
	if (param_num = 69) then return(P_arg69); end if;
	if (param_num = 70) then return(P_arg70); end if;
	if (param_num = 71) then return(P_arg71); end if;
	if (param_num = 72) then return(P_arg72); end if;
	if (param_num = 73) then return(P_arg73); end if;
	if (param_num = 74) then return(P_arg74); end if;
	if (param_num = 75) then return(P_arg75); end if;
	if (param_num = 76) then return(P_arg76); end if;
	if (param_num = 77) then return(P_arg77); end if;
	if (param_num = 78) then return(P_arg78); end if;
	if (param_num = 79) then return(P_arg79); end if;
	if (param_num = 80) then return(P_arg80); end if;
	if (param_num = 81) then return(P_arg81); end if;
	if (param_num = 82) then return(P_arg82); end if;
	if (param_num = 83) then return(P_arg83); end if;
	if (param_num = 84) then return(P_arg84); end if;
	if (param_num = 85) then return(P_arg85); end if;
	if (param_num = 86) then return(P_arg86); end if;
	if (param_num = 87) then return(P_arg87); end if;
	if (param_num = 88) then return(P_arg88); end if;
	if (param_num = 89) then return(P_arg89); end if;
	if (param_num = 90) then return(P_arg90); end if;
	if (param_num = 91) then return(P_arg91); end if;
	if (param_num = 92) then return(P_arg92); end if;
	if (param_num = 93) then return(P_arg93); end if;
	if (param_num = 94) then return(P_arg94); end if;
	if (param_num = 95) then return(P_arg95); end if;
	if (param_num = 96) then return(P_arg96); end if;
	if (param_num = 97) then return(P_arg97); end if;
	if (param_num = 98) then return(P_arg98); end if;
	if (param_num = 99) then return(P_arg99); end if;
	if (param_num = 100) then return(P_arg100); end if;
end;


FUNCTION GET_PARAMETER(name in varchar2) return varchar2 is
   param_num number;
   ret_val   number;
begin
   ret_val := get_param_number( name, param_num );
   if ( ret_val < 0 ) then
	return null;
   end if;
   return get_parameter(param_num);
end;

FUNCTION get_territory return varchar2 is
Begin
   return(P_nls_territory);
end;

end;

/
