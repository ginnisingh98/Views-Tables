--------------------------------------------------------
--  DDL for Package Body XDP_PROCEDURE_BUILDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_PROCEDURE_BUILDER" AS
/* $Header: XDPPRBDB.pls 120.1 2005/06/24 17:29:52 appldev ship $ */

g_new_line CONSTANT VARCHAR2(10) := convert(FND_GLOBAL.LOCAL_CHR(10),
        substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'),'.') +1),
        'WE8ISO8859P1')  ;

g_StartComment varchar2(200) := '/*****************************************************************************';
g_EndComment varchar2(200) := '*****************************************************************************/';


g_ProcStart varchar2(20) := 'Procedure ';
g_ProcEnd varchar2(20) := '; ';
g_ProcBlockBegin varchar2(20) := 'begin' || g_new_line ;
g_ProcBlockDeclare varchar2(20) := 'declare ' || g_new_line;
g_ProcBlockEnd varchar2(500) :=
		g_new_line || g_new_line || 'exception ' || g_new_line ||
		'when others then ' || g_new_line ||
		'    xdp_macros.HandleProcErrors(p_return_code,p_error_description); ' ||
		g_new_line || 'end ';

g_ProcSpec varchar2(2000);
g_ProcHeader varchar2(2000);
g_ProcFooter varchar2(2000);

g_ProcBody varchar2(32767);

g_PkgCreateStmtStartSpec varchar2(80) := 'CREATE OR REPLACE PACKAGE ';
g_PkgCreateStmtEndSpec varchar2(80) := ' AUTHID CURRENT_USER AS';
g_PkgCreateStmtStartBody varchar2(80) := 'CREATE OR REPLACE PACKAGE BODY ';
g_PkgCreateStmtEndBody varchar2(80) := ' AS';

g_PackageSpec varchar2(32767);
g_PackageHeader varchar2(2000);
g_PackageFooter varchar2(2000) := 'END ';

g_PackageBody varchar2(32767);

g_SvcWIMapTypeDisp varchar2(80) := 'DYNAMIC_WI_MAPPING';
g_WIFAMapTypeDisp varchar2(80) := 'DYNAMIC_FA_MAPPING';
g_WIWFStartTypeDisp varchar2(80) := 'EXEC_WI_WORKFLOW';

g_WIParamEvalTypeDisp varchar2(80) := 'WI_PARAM_EVAL_PROC';
g_FAParamEvalTypeDisp varchar2(80) := 'FA_PARAM_EVAL_PROC';
g_EvalAllFAParamTypeDisp varchar2(80) := 'FA_PARAM_EVAL_ALL_PROC';

g_LocateFETypeDisp varchar2(80) := 'LOCATE_FE';
g_FPTypeDisp varchar2(80) := 'PROVISIONING';

g_ConnectTypeDisp varchar2(80) := 'CONNECT';
g_DisconnectTypeDisp varchar2(80) := 'DISCONNECT';

g_ProcType varchar2(80) := 'XDP_PROCEDURE_TYPE';
g_ParamType varchar2(80) := 'XDP_OBJECTS';

g_Sync varchar2(30) := 'PIPE';
g_ASync varchar2(30) := 'QUEUE';
g_None varchar2(30) := 'NONE';

g_SelectStmt varchar2(20) := 'SELECT';
g_InsertStmt varchar2(20) := 'INSERT';
g_DeleteStmt varchar2(20) := 'DELETE';
g_UpdateStmt varchar2(20) := 'UPDATE';

g_ApplMode varchar2(40) := ' ';
g_AdapterType varchar2(40);
g_AdapterTypeDisp varchar2(240);

cursor c_getProcLookupMeaning(code varchar2) is
select meaning
from fnd_lookups
where lookup_type = 'XDP_PROCEDURE_TYPE'
and lookup_code = code;

cursor c_getParamLookupMeaning(code varchar2) is
select meaning
from fnd_lookups
where lookup_type = 'XDP_OBJECTS'
and lookup_code = code;

cursor c_getAdapterApplMode is
select application_mode, display_name
from xdp_adapter_types_vl
where adapter_type = g_AdapterType;

Procedure InitGlobals;
Procedure InitDisplayNames;
Function FetchLookupMeaning(p_LookupType in varchar2,
			  p_LookupCode in varchar2) return varchar2;
Function GetProcDispName(p_ProcType in varchar2) return varchar2;
Function GetParamDispName(p_OrderParam in boolean default false,
			  p_LineParam in boolean default false,
			  p_WIParam in boolean default false,
			  p_FAParam in boolean default false) return varchar2;
Procedure FetchAdapterApplMode( p_AdapterType in varchar2,
				x_ErrorCode OUT NOCOPY number,
				x_ErrorString OUT NOCOPY varchar2);

Procedure Init;
Function getProcSpec(p_ProcType in varchar2) return varchar2;
Function getComments(p_ProcType in varchar2) return varchar2;
Function getAdditionalStuff(p_ProcType in varchar2) return varchar2;
Function getInitialization(p_ProcType in varchar2,
			   p_ProcName in varchar2) return varchar2;
Function getFinilization(p_ProcType in varchar2,
			 p_ProcName in varchar2) return varchar2;

Procedure ValidateParameters(p_ProcType in varchar2,
			     p_ProcBody in varchar2,
			     p_ID     in number,
	                     x_ErrorCode OUT NOCOPY number,
			     x_ErrorString OUT NOCOPY varchar2);

Procedure CheckForSQL(  p_ProcBody in varchar2,
			x_ErrorString OUT NOCOPY varchar2);

Procedure ValidateMacros(p_ProcType in varchar2,
			 p_ProcBody in varchar2,
			 x_ErrorCode OUT NOCOPY number,
			 x_ErrorString OUT NOCOPY varchar2);

Function CheckForMacros(p_ProcBody in varchar2,
			p_MacroSend in boolean default false,
			p_MacroSendHttp in boolean default false,
			p_MacroLogin in boolean default false,
			p_MacroGetResp in boolean default false,
			p_MacroGetParam in boolean default false,
			p_MacroNotifError in boolean default false,
			p_MacroGetLongResp in boolean default false,
			p_MacroRespContains in boolean default false,
			p_MacroAudit in boolean default false) return boolean;

Procedure ProcessMacros(p_ProcType in varchar2,
                        p_ProcName in varchar2,
			p_ProcBody in varchar2);

Function IsMacroUsed(p_Macro in varchar2,
		     p_ProcBody in varchar2) return boolean;


Procedure FindParamUsage(ProcBody in varchar2);

Procedure CheckIfDuplicate(p_ProcName IN VARCHAR2,
                           p_ProcType IN VARCHAR2,
                           p_Duplicate OUT NOCOPY BOOLEAN,
                           p_DuplicateType OUT NOCOPY VARCHAR2);

Function GetPackageName (p_ProcName in varchar2) return varchar2;

------

-- Given the Package.Procedure Name get the Procedure name
Function DecodeProcName (p_PackageName in varchar2) return varchar2
is

begin

  return (substr(p_PackageName,
		(instr(p_PackageName,'.',1) + 1), length(p_PackageName)));

end DecodeProcName;

--
-- Generate the Package Name from the Procedure Name which the user
-- has given. Optionally you can check the validity of the Procedure name
-- specified. Validity include: Length, Duplicate
Procedure GeneratePackageName ( p_ProcType in varchar2,
				p_ProcName in varchar2,
				p_Validate in boolean default false,
				x_PackageName OUT NOCOPY varchar2,
				x_ErrorCode OUT NOCOPY number,
				x_ErrorString OUT NOCOPY varchar2)
is
 l_IsDup boolean := false;
 l_DupType varchar2(80);
begin
	x_ErrorCode := 0;

	x_PackageName := GetPackageName(p_ProcName);

	if not p_Validate then
		return;
	end if;

	if length(p_ProcName) > g_MaxProcLength then
		x_ErrorCode := -191332;
     		FND_MESSAGE.SET_NAME('XDP', 'XDP_PROC_NAME_TOO_LONG');
		x_ErrorString := FND_MESSAGE.GET;
		return;
	end if;

	CheckIfDuplicate(p_ProcName => x_PackageName || '.' || p_ProcName,
			 p_ProcType => p_ProcType,
			 p_Duplicate => l_IsDup,
			 p_DuplicateType => l_DupType);

	if l_IsDup then
		x_ErrorCode := -191226;
     		FND_MESSAGE.SET_NAME('XDP', 'XDP_PROC_NAME_EXISTS');
		x_ErrorString := FND_MESSAGE.GET;
                return;
        end if;

end GeneratePackageName;

--
-- Get the Package Name
Function GetPackageName (p_ProcName in varchar2) return varchar2
is

begin

  return (g_PackagePrefix || p_ProcName || g_PackageSuffix);

end GetPackageName;

--
-- Check if there are any other procedures of a different type with
-- the same name
Procedure CheckIfDuplicate(p_ProcName IN VARCHAR2,
                           p_ProcType IN VARCHAR2,
                           p_Duplicate OUT NOCOPY BOOLEAN,
                           p_DuplicateType OUT NOCOPY VARCHAR2)
is

  CURSOR c_CheckDup is
    select proc_type
    from xdp_proc_body
    where proc_name = p_ProcName
      and proc_type <> p_ProcType;
begin

  p_Duplicate := FALSE;
  p_DuplicateType := NULL;

   for v_CheckDup in c_CheckDup loop
        p_Duplicate := TRUE;
        p_DuplicateType := v_CheckDup.proc_type;
        exit;
   end loop;

end CheckIfDuplicate;

--
-- This routine is used to generate the Specification of the PROCEDURE
Procedure GenerateProcSpec (p_ProcType in varchar2,
			   p_ProcName in varchar2)
is

begin
	g_ProcSpec := g_ProcStart || p_ProcName || '( ' || g_new_line ||
		     getProcSpec(p_ProcType) || g_new_line;

end GenerateProcSpec;

--
-- Return the Default Procedure Body which needs to be generated.
-- The usual PL/SQL default body is "null;" !!
Function GenerateProcDefBody(p_ProcType in varchar2) return varchar2
is
begin
	return ('null;' || g_new_line) ;

end GenerateProcDefBody;

--
-- Generate any code which needs to be created as part of the Procedure
-- Header. These could include any PL/SQL variables, exceptions etc
-- This is also used to generate all the necessary variables which needs
-- to be generated for backward compatibility of variable names
-- Also any Procedure type specific Initialization needs to ebe generated
Procedure GenerateProcHeader(p_ProcType in VARCHAR2,
			     p_ProcName in varchar2)
is
begin
	g_ProcHeader := 'is ' || g_new_line ||
			getAdditionalStuff(p_ProcType) || g_new_line ||
			g_ProcBlockBegin || g_new_line ||
			getComments(p_ProcType) || g_new_line ||
			getInitialization(p_ProcType, p_ProcName)||g_ProcBlockDeclare;

end GenerateProcHeader;

-- Generate the Proceduer Footer
-- These could include exception blocks, cleanup code etc
Procedure GenerateProcFooter(p_ProcType in VARCHAR2,
                            p_ProcName in varchar2)
is
begin
	g_procFooter := getFinilization(p_ProcType, p_ProcName) ||
			g_ProcBlockEnd || p_ProcName || ' ;';

end GenerateProcFooter;

--
-- This routine is used to generate the complete Procedure Body
-- This is essentially Proc Spec + Proc Header + Proc Body + Proc Footer
-- When generating the Procedure Body this is also the place where all the
-- Macros are translated
Procedure GenerateProcBody(p_ProcType in VARCHAR2,
                           p_ProcName in varchar2,
			   p_ProcBody in varchar2 default null)
is
begin
	GenerateProcSpec(p_ProcType, p_ProcName);
	GenerateProcHeader(p_ProcType, p_ProcName);
	GenerateProcFooter(p_ProcType, p_ProcName);

	g_ProcBody := g_ProcSpec || g_ProcHeader ;

	if p_ProcBody is null then
		g_ProcBody := g_ProcBody || GenerateProcDefBody(p_ProcType);
	else
		ProcessMacros(p_ProcType, p_ProcName, p_ProcBody);
	end if;

	g_ProcBody := g_ProcBody || g_procFooter;

end GenerateProcBody;

--
-- Translate all the Macros used by the user in the procedure.
-- Translation of macros can depend on the type of procedures
Procedure ProcessMacros(p_ProcType in varchar2,
                        p_ProcName in varchar2,
			p_ProcBody in varchar2)
is
 l_TempProcBody varchar2(32767);
begin

 if p_ProcType = g_FPType then
      xdp_procedure_builder_util.TranslateFPMacros(ProcName => p_ProcName,
                                 ProcStr => p_ProcBody,
                                 CompiledProc => l_TempProcBody);
 elsif p_ProcType = g_ConnectType then
      xdp_procedure_builder_util.TranslateConnMacros(ProcName => p_ProcName,
                                 ProcBody => p_ProcBody,
                                 CompiledProc => l_TempProcBody);
 elsif p_ProcType = g_DisconnectType then
      xdp_procedure_builder_util.TranslateDisconnMacros(ProcName => p_ProcName,
                                 ProcBody => p_ProcBody,
                                 CompiledProc => l_TempProcBody);
 else
      xdp_procedure_builder_util.TranslateDefMacros(ProcName => p_ProcName,
                                 ProcStr => p_ProcBody,
                                 CompiledProc => l_TempProcBody);
 end if;

	g_ProcBody := g_ProcBody || g_new_line || l_TempProcBody;

end ProcessMacros;

--
-- This routine is used to generate the Header information for the
-- Package Spec or Package Body
-- This typically is the "CREATE" statement for the package
Procedure GeneratePackageHeader(p_PackageName in VARCHAR2,
				p_SpecOrBody in VARCHAR2 default 'SPEC')
is
begin
	if p_SpecOrBody = 'SPEC' then
		g_PackageHeader :=
			g_PkgCreateStmtStartSpec || ' ' || p_PackageName || ' ' ||
			g_PkgCreateStmtEndSpec || g_new_line;
	elsif p_SpecOrBody = 'BODY' then
		g_PackageHeader :=
			g_PkgCreateStmtStartBody || ' ' || p_PackageName || ' ' ||
			 g_PkgCreateStmtEndBody || g_new_line;
	end if;

end  GeneratePackageHeader;

--
-- This routine is used to generate the footer information for the Package
Procedure GeneratePackageFooter(p_PackageName in VARCHAR2)
is
begin
	g_PackageFooter := g_PackageFooter || ' ' || p_PackageName || ';';

end GeneratePackageFooter;

--
-- Create the Package Specification
-- This includes the Package Create Statement and the Procedure name and
-- Specification to be created within the package
-- This version of the routine also generates the Package name from the
-- Procedure Name passed
-- The actual Package Specification is generated and any errors is given
-- to the user
Procedure GeneratePackageSpec(p_ProcType in varchar2,
			      p_ProcName in varchar2,
			      x_ErrorCode OUT NOCOPY number,
                              x_ErrorString OUT NOCOPY varchar2)
is

 l_PackageName varchar2(80);
begin

	l_PackageName := GetPackageName(p_ProcName);

	GeneratePackageSpec(p_PackageName => l_PackageName,
			    p_ProcType => p_ProcType,
			    p_ProcName=> p_ProcName,
			    x_ErrorCode => x_ErrorCode,
			    x_ErrorString => x_ErrorString);
end GeneratePackageSpec;

--
-- Create the Package Specification (Over Loaded)
-- This includes the Package Create Statement and the Procedure name and
-- Specification to be created within the package
-- This version of the routine takes the package Name to be created as a
-- parameter
-- The actual Package Specification is generated and any errors is given
-- to the user
Procedure GeneratePackageSpec(p_PackageName in VARCHAR2,
			      p_ProcType in varchar2,
			      p_ProcName in varchar2,
			      x_ErrorCode OUT NOCOPY number,
                              x_ErrorString OUT NOCOPY varchar2)
is
begin
	Init;

	GeneratePackageHeader(p_PackageName);

	GenerateProcSpec(p_ProcType, p_ProcName);

	g_PackageSpec :=  g_PackageSpec || g_new_line || g_new_line ||
			  g_ProcSpec || g_ProcEnd;

	GeneratePackageFooter(p_PackageName);

	g_PackageSpec := g_PackageHeader || g_PackageSpec || g_new_line ||
			 g_PackageFooter;

        xdp_utilities.Create_Pkg_Spec (
                                  P_PKG_NAME => p_PackageName,
                                  P_PKG_SPEC => g_PackageSpec,
                                  P_APPLICATION_SHORT_NAME => 'XDP',
                                  X_RETURN_CODE => x_ErrorCode,
                                  X_ERROR_STRING => x_ErrorString);

    	if x_ErrorCode <> 0 then
		x_ErrorCode := -197018;
     		FND_MESSAGE.SET_NAME('XDP', 'XDP_PROC_COMPILE_ERROR');
		FND_MESSAGE.SET_TOKEN('PROC_TYPE', GetProcDispName(p_ProcType));
		FND_MESSAGE.SET_TOKEN('PROC_NAME', p_ProcName);
		FND_MESSAGE.SET_TOKEN('ERR_CODE', x_ErrorCode);
		FND_MESSAGE.SET_TOKEN('ERR_STR', x_ErrorString);

		x_ErrorString := FND_MESSAGE.GET;
    	end if;
end GeneratePackageSpec;

--
-- Create the Package Body (Over Loaded)
-- This includes the Package Create Statement and the Procedure name and
-- Body to be created within the package
-- This version of the routine generates the package Name to be created using
-- the Procedure Name passed
-- The actual Package Body is generated and any errors is given
-- to the user
Procedure GeneratePackageBody(p_ProcType in varchar2,
			      p_ProcName in varchar2,
			      p_ProcBody in varchar2 default null,
			      x_ErrorCode OUT NOCOPY number,
                              x_ErrorString OUT NOCOPY varchar2)
is

 l_PackageName varchar2(80);
begin

	l_PackageName := GetPackageName(p_ProcName);
	GeneratePackageBody(p_PackageName => l_PackageName,
			    p_ProcType => p_ProcType,
			    p_ProcName=> p_ProcName,
			    p_ProcBody => p_ProcBody,
			    x_ErrorCode => x_ErrorCode,
			    x_ErrorString => x_ErrorString);

end GeneratePackageBody;

--
-- Create the Package Body (Over Loaded)
-- This includes the Package Create Statement and the Procedure name and
-- Body to be created within the package
-- This version of the routine takes the package Name to be created as a
-- parameter
-- The actual Package Body is generated and any errors is given
-- to the user
Procedure GeneratePackageBody(p_PackageName in VARCHAR2,
			      p_ProcType in varchar2,
			      p_ProcName in varchar2,
			      p_ProcBody in varchar2 default null,
			      x_ErrorCode OUT NOCOPY number,
                              x_ErrorString OUT NOCOPY varchar2)
is

begin
	Init;

	GeneratePackageHeader(p_PackageName, 'BODY');

	GenerateProcBody(p_ProcType, p_ProcName, p_ProcBody);

	g_PackageBody :=  g_PackageBody || g_new_line || g_new_line ||
			  g_ProcBody;

	GeneratePackageFooter(p_PackageName);

	g_PackageBody := g_PackageHeader || g_PackageBody || g_new_line ||
			 g_PackageFooter;


        xdp_utilities.Create_Pkg_Body (
                                  P_PKG_NAME => p_PackageName,
                                  P_PKG_BODY => g_PackageBody,
                                  P_APPLICATION_SHORT_NAME => 'XDP',
                                  X_RETURN_CODE => x_ErrorCode,
                                  X_ERROR_STRING => x_ErrorString);

    	if x_ErrorCode <> 0 then
		x_ErrorCode := -197018;
     		FND_MESSAGE.SET_NAME('XDP', 'XDP_PROC_COMPILE_ERROR');
		FND_MESSAGE.SET_TOKEN('PROC_TYPE', GetProcDispName(p_ProcType));
		FND_MESSAGE.SET_TOKEN('PROC_NAME', p_ProcName);
		FND_MESSAGE.SET_TOKEN('ERR_CODE', x_ErrorCode);
		FND_MESSAGE.SET_TOKEN('ERR_STR', x_ErrorString);

		x_ErrorString := FND_MESSAGE.GET;
	end if;
end GeneratePackageBody;

--
-- This routine is used to pre-compile the Users Procedures
-- Mandaroty pre-compilation checks are: Macro Checks and PL/SQL logic checks
-- Optional check is Parameter Validation
-- Any errors are given to the user
Procedure PrecompileProcedure(p_ProcType in varchar2,
			      p_ProcBody in varchar2,
			      p_ID     in number default null,
			      p_AdapterType in varchar2 default null,
			      p_ValidateParams in boolean default true,
			      x_ErrorCode OUT NOCOPY number,
			      x_ErrorString OUT NOCOPY varchar2)
is
begin
	if p_ProcType = g_FPType then
		FetchAdapterApplMode(p_AdapterType => p_AdapterType,
				     x_ErrorCode => x_ErrorCode,
				     x_ErrorString => x_ErrorString);
		if x_ErrorCode <> 0 then
			return;
		end if;
	end if;

	ValidateMacros(p_ProcType, p_ProcBody, x_ErrorCode, x_ErrorString);
	if x_ErrorCode <> 0 then
		return;
	end if;
	if p_ValidateParams then
		ValidateParameters(p_ProcType, p_ProcBody, p_ID, x_ErrorCode, x_ErrorString);
		if x_ErrorCode <> 0 then
			return;
		end if;
	end if;

	x_ErrorCode := 0;
	CheckForSQL(p_ProcBody, x_ErrorString);

end PrecompileProcedure;

--
-- This routine check the Validity of Paramter Usage within a Procedure
-- The types of paramterse which can be used depends on the Procedure Type
-- For example: ORDER related paramters CANNOT be used in a Connect/Disconnect Procedure
-- FA Paramters CANNOT be used in a Svc-WI Mapping Procedure etc
-- Once the usages of the paramters is validated the actual parameter names are
-- Checked against the configuration
Procedure ValidateParameters(p_ProcType in varchar2,
			     p_ProcBody in varchar2,
			     p_ID     in number,
		             x_ErrorCode OUT NOCOPY number,
			     x_ErrorString OUT NOCOPY varchar2)
is
begin
	-- Find the Paramter Usages
	FindParamUsage(p_ProcBody);
	if p_ProcType in (g_ConnectType, g_DisconnectType) then
		-- Order related Parameters cannot be used in a
		-- Connect/Disconnect Procedure
		if pv_WIParamUsed or  pv_FAParamUsed or
		   pv_OrderParamUsed or pv_LineParamUsed then
			x_ErrorCode := -197019;
     			FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_PARAM_USAGE');
			FND_MESSAGE.SET_TOKEN('INVALID_PARAM_LIST',
					GetParamDispName(p_OrderParam => true,
							 p_LineParam => true,
							 p_WIParam => true,
							 p_FAParam => true));
			FND_MESSAGE.SET_TOKEN('PROCEDURE_TYPE',
						GetProcDispName(p_ProcType));

			x_ErrorString := FND_MESSAGE.GET;
			return;
		else
			-- Check the actual FE Attribute name's validity for the
			-- FE Type
			xdp_procedure_builder_util.ValidateFEAttributes(
				p_ID, p_ProcBody,x_ErrorCode,x_ErrorString);
			x_ErrorString := x_ErrorString || 'FE: ' || p_ID;
			return;
		end if;

	elsif p_ProcType = g_SvcWIMapType then
		-- WI or FA Paramters cannot be used in a Svc-WI Mapping procedure
		if pv_WIParamUsed or  pv_FAParamUsed then
			x_ErrorCode := -197019;
     			FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_PARAM_USAGE');
			FND_MESSAGE.SET_TOKEN('INVALID_PARAM_LIST',
					GetParamDispName(p_WIParam => true,
							 p_FAParam => true));
			FND_MESSAGE.SET_TOKEN('PROCEDURE_TYPE',
						GetProcDispName(p_ProcType));

			x_ErrorString := FND_MESSAGE.GET;
			return;
		end if;
	elsif p_ProcType = g_WIFAMapType then
		-- FA Paramters cannot be used in a WI-FA Mapping procedure
		if pv_FAParamUsed then
			x_ErrorCode := -197019;
     			FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_PARAM_USAGE');
			FND_MESSAGE.SET_TOKEN('INVALID_PARAM_LIST',
                                        GetParamDispName(p_FAParam => true));
			FND_MESSAGE.SET_TOKEN('PROCEDURE_TYPE',
						GetProcDispName(p_ProcType));

			x_ErrorString := FND_MESSAGE.GET;
			return;
		end if;
	elsif p_ProcType = g_WIWFStartType then
		-- FA Paramters cannot be used in a WI Workflow Start Procedure
		if pv_FAParamUsed then
			x_ErrorCode := -197019;
     			FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_PARAM_USAGE');
			FND_MESSAGE.SET_TOKEN('INVALID_PARAM_LIST',
                                        GetParamDispName(p_FAParam => true));
			FND_MESSAGE.SET_TOKEN('PROCEDURE_TYPE',
						GetProcDispName(p_ProcType));

			x_ErrorString := FND_MESSAGE.GET;
			return;
		end if;
	elsif p_ProcType = g_WIParamEvalType then
		-- FA Paramters cannot be used in a WI Parameter Evaluation Procedure
		if pv_FAParamUsed then
			x_ErrorCode := -197019;
     			FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_PARAM_USAGE');
			FND_MESSAGE.SET_TOKEN('INVALID_PARAM_LIST',
                                        GetParamDispName(p_FAParam => true));
			FND_MESSAGE.SET_TOKEN('PROCEDURE_TYPE',
						GetProcDispName(p_ProcType));

			x_ErrorString := FND_MESSAGE.GET;
			return;
		end if;
	elsif p_ProcType =  g_FAParamEvalType then
		-- No specific Macro usage limitations
		-- Can use $ORDER, $LINE, $WI, $FA
				null;
	elsif p_ProcType =  g_LocateFEType then
		-- No specific Macro usage limitations
		-- Can use $ORDER, $LINE, $WI, $FA
				null;
	end if;

-- OK so far
-- Now check the validity of parameter usage for each procedure type
	if p_ProcType not in (g_ConnectType, g_DisconnectType, g_SvcWIMapType) then

		xdp_procedure_builder_util.ValidateFPParameters(
					p_ID => p_ID,
					p_ProcBody => p_ProcBody,
			      		x_ErrorCode => x_ErrorCode,
			      		x_ErrorString => x_ErrorString);
	end if;

end ValidateParameters;


--
-- Validate the Macro Usage.
-- The types of macros which can be used depends on the type of the Procedure
-- for e.g. SEND cannot be used in a Work Item Paramter Evaluation Procedure
Procedure ValidateMacros(p_ProcType in varchar2,
			 p_ProcBody in varchar2,
			 x_ErrorCode OUT NOCOPY number,
			 x_ErrorString OUT NOCOPY varchar2)
is
begin
	if p_ProcType not in (g_FPType, g_ConnectType, g_DisconnectType) then
		-- GET_PARAM_VALUE is pretty much the only macro which can
		-- be used in any procedure
		if not CheckForMacros(p_MacroSend => true,
				      p_MacroSendHttp => true,
				      p_MacroGetResp => true,
				      p_MacroLogin => true,
				      p_MacroNotifError => true,
				      p_MacroGetLongResp => true,
				      p_MacroRespContains => true,
				      p_MacroAudit => true,
				      p_ProcBody => ValidateMacros.p_ProcBody) then
			x_ErrorCode := 0;
			return;
		else
			x_ErrorCode := -197017;
     			FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_MACRO_USAGE');
			FND_MESSAGE.SET_TOKEN('INVALID_MACRO_LIST',
			       'SEND, SEND_HTTP, GET_RESPONSE, GET_LONG_RESPONSE, ' ||
			       'LOGIN, NOTIFY_ERROR, AUDIT');
			FND_MESSAGE.SET_TOKEN('PROCEDURE_TYPE',
					      GetProcDispName(p_ProcType));
			FND_MESSAGE.SET_TOKEN('VALID_MACRO_LIST',
					      'GET_PARAM_VALUE');

			x_ErrorString := FND_MESSAGE.GET;
			return;
		end if;
	elsif p_ProcType = g_DisconnectType then
		-- FP related mactos - SEND_HTTP, GET_RESPONSE, NOTIFY_ERROR, AUDIT
		-- and the Connect Procedure's LOGIN cannot be used in a
		-- Disconnect Procedure
		if CheckForMacros (p_MacroSendHttp => true,
				   p_MacroGetResp => true,
				   p_MacroLogin => true,
				   p_MacroNotifError => true,
				   p_MacroGetLongResp => true,
				   p_MacroRespContains => true,
				   p_MacroAudit => true,
				   p_ProcBody => ValidateMacros.p_ProcBody) then
			x_ErrorCode := -197017;
     			FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_MACRO_USAGE');
			FND_MESSAGE.SET_TOKEN('INVALID_MACRO_LIST',
				     'SEND_HTTP, GET_RESPONSE, GET_LONG_RESPONSE, ' ||
				     'LOGIN, NOTIFY_ERROR, AUDIT');
			FND_MESSAGE.SET_TOKEN('PROCEDURE_TYPE',
					      GetProcDispName(p_ProcType));
			FND_MESSAGE.SET_TOKEN('VALID_MACRO_LIST',
					      'SEND, GET_PARAM_VALUE');

			x_ErrorString := FND_MESSAGE.GET;
			return;
		else
			x_ErrorCode := 0;
			return;
		end if;
	elsif p_ProcType = g_ConnectType then
		-- FP related mactos - SEND_HTTP, GET_RESPONSE, NOTIFY_ERROR, AUDIT
		-- cannot be used in a Connect Procedure
		if CheckForMacros (p_MacroSendHttp => true,
				   p_MacroGetResp => true,
				   p_MacroNotifError => true,
				   p_MacroGetLongResp => true,
				   p_MacroRespContains => true,
				   p_MacroAudit => true,
				   p_ProcBody => ValidateMacros.p_ProcBody) then

			x_ErrorCode := -197017;
     			FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_MACRO_USAGE');
			FND_MESSAGE.SET_TOKEN('INVALID_MACRO_LIST',
				     'SEND_HTTP, GET_RESPONSE, GET_LONG_RESPONSE, ' ||
				     'NOTIFY_ERROR, AUDIT');
			FND_MESSAGE.SET_TOKEN('PROCEDURE_TYPE',
					      GetProcDispName(p_ProcType));
			FND_MESSAGE.SET_TOKEN('VALID_MACRO_LIST',
					      'SEND, LOGIN, GET_PARAM_VALUE');

			x_ErrorString := FND_MESSAGE.GET;
			return;
		else
			x_ErrorCode := 0;
			return;
		end if;
	elsif p_ProcType = g_FPType then
		-- the Connect Procedure's LOGIN cannot be used in a
		-- Fulfillment Procedure
		if CheckForMacros (p_MacroLogin => true,
				   p_ProcBody => ValidateMacros.p_ProcBody) then

			x_ErrorCode := -197017;
     			FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_MACRO_USAGE');
			FND_MESSAGE.SET_TOKEN('INVALID_MACRO_LIST', 'LOGIN');
			FND_MESSAGE.SET_TOKEN('PROCEDURE_TYPE',
					      GetProcDispName(p_ProcType));
			FND_MESSAGE.SET_TOKEN('VALID_MACRO_LIST',
			     'SEND, SEND_HTTP, GET_PARAM_VALUE, GET_RESPONSE ' ||
		 	     'GET_LONG_RESPONSE, NOTIFY_ERROR, AUDIT');

			x_ErrorString := FND_MESSAGE.GET;
			return;

		end if;

		-- Check Adapter Type Specific Macros
		-- Only certain macros can be used and this depends upon
		-- the Adapter Type
		-- for e.g SEND_HTTP cannot be used with an INTERACTIVE Adapter
		if g_ApplMode = g_Sync then
			-- Check for Interactive Adapter
			-- SEND_HTTP cannot be used
			if CheckForMacros(
					p_MacroSendHttp => true,
					p_ProcBody => ValidateMacros.p_ProcBody) then
				x_ErrorCode := -197017;
     				FND_MESSAGE.SET_NAME('XDP',
					'XDP_INVALID_MACRO_FOR_ADAPTER');
                                FND_MESSAGE.SET_TOKEN('ADAPTER_TYPE',
					nvl(g_AdapterTypeDisp, g_AdapterType));
				FND_MESSAGE.SET_TOKEN('INVALID_MACRO_LIST',
					'SEND_HTTP');
				x_ErrorString := FND_MESSAGE.GET;
				return;
			else
				x_ErrorCode := 0;
				return;
			end if;
		elsif g_ApplMode = g_ASync then
			-- Check for File Adapter and other "ASYNC" adapter
			-- SEND, SEND_HTTP, GET_RESPONSE and GET_LONG_RESPONSE
			-- cannot be used
                        if CheckForMacros(
                                        p_MacroSend => true,
                                        p_MacroSendHttp => true,
                                        p_MacroGetResp => true,
                                        p_MacroGetLongResp => true,
                                        p_ProcBody => ValidateMacros.p_ProcBody) then
                                x_ErrorCode := -197017;
     				FND_MESSAGE.SET_NAME('XDP',
					'XDP_INVALID_MACRO_FOR_ADAPTER');
                                FND_MESSAGE.SET_TOKEN('ADAPTER_TYPE',
					nvl(g_AdapterTypeDisp, g_AdapterType));
                                FND_MESSAGE.SET_TOKEN('INVALID_MACRO_LIST',
				'SEND_HTTP, SEND, GET_RESPONSE, GET_LONG_RESPONSE');

                                x_ErrorString := FND_MESSAGE.GET;
                                return;
			else
                                x_ErrorCode := 0;
                                return;
                        end if;
		elsif g_ApplMode = g_None then
			-- HTTP adapter. SEND cannot be used.
			if g_AdapterType = 'HTTP' then
                        	if CheckForMacros(
                                        p_MacroSend => true,
                                        p_ProcBody => ValidateMacros.p_ProcBody) then

                                	x_ErrorCode := -197017;
                                	FND_MESSAGE.SET_NAME('XDP',
						'XDP_INVALID_MACRO_FOR_ADAPTER');
                                	FND_MESSAGE.SET_TOKEN('ADAPTER_TYPE',
					nvl(g_AdapterTypeDisp, g_AdapterType));
					FND_MESSAGE.SET_TOKEN('INVALID_MACRO_LIST',
						'SEND');

					x_ErrorString := FND_MESSAGE.GET;
					return;
				else
					x_ErrorCode := 0;
					return;
				end if;
			else
			-- Check for other "Non-Implemented" adapter
			-- SEND, SEND_HTTP, GET_RESPONSE and GET_LONG_RESPONSE
			-- cannot be used
                        	if CheckForMacros(
                                        p_MacroSend => true,
                                        p_MacroSendHttp => true,
                                        p_MacroGetResp => true,
                                        p_MacroGetLongResp => true,
                                        p_ProcBody => ValidateMacros.p_ProcBody) then

                                	x_ErrorCode := -197017;
                                	FND_MESSAGE.SET_NAME('XDP',
						'XDP_INVALID_MACRO_FOR_ADAPTER');
                                	FND_MESSAGE.SET_TOKEN('ADAPTER_TYPE',
					    nvl(g_AdapterTypeDisp, g_AdapterType));
					FND_MESSAGE.SET_TOKEN('INVALID_MACRO_LIST',
						'SEND_HTTP, SEND, GET_RESPONSE,' ||
						' GET_LONG_RESPONSE');

					x_ErrorString := FND_MESSAGE.GET;
					return;
				else
					x_ErrorCode := 0;
					return;
				end if;
			end if;
		end if;

	else
		x_ErrorCode := 0;
		return;
	end if;
end ValidateMacros;

--
-- Warn the user if any native SQL logic is found.
-- This is not an error but just a warning
Procedure CheckForSQL( p_ProcBody in varchar2,
			 x_ErrorString OUT NOCOPY varchar2)
is
 l_SQLStmt varchar2(80) := null;
begin

 x_ErrorString := null;
 if instr(upper(p_ProcBody), 'SELECT ', 1, 1) > 0 then
	l_SQLStmt := g_SelectStmt;
 end if;
 if instr(upper(p_ProcBody), 'INSERT ', 1, 1) > 0 then
	if l_SQLStmt is null then
		l_SQLStmt := g_InsertStmt;
	else
		l_SQLStmt := l_SQLStmt || ',' || g_InsertStmt;
	end if;
 end if;
 if instr(upper(p_ProcBody), 'UPDATE ', 1, 1) > 0 then
	if l_SQLStmt is null then
		l_SQLStmt := g_UpdateStmt;
	else
		l_SQLStmt := l_SQLStmt || ',' || g_UpdateStmt;
	end if;
 end if;
 if instr(upper(p_ProcBody), 'DELETE ', 1, 1) > 0 then
	if l_SQLStmt is null then
		l_SQLStmt := g_DeleteStmt;
	else
		l_SQLStmt := l_SQLStmt || ',' || g_DeleteStmt;
	end if;
 end if;

 if l_SQLStmt is not null then
	FND_MESSAGE.SET_NAME('XDP','XDP_SQL_IN_PROC');
	FND_MESSAGE.SET_TOKEN('SQLSTMT',l_SQLStmt);
	x_ErrorString := FND_MESSAGE.GET;
 end if;

end CheckForSQL;

--
-- Check for Macro usages within the procedure
Function CheckForMacros(p_ProcBody in varchar2,
			p_MacroSend in boolean default false,
			p_MacroSendHttp in boolean default false,
			p_MacroLogin in boolean default false,
			p_MacroGetResp in boolean default false,
			p_MacroGetParam in boolean default false,
			p_MacroNotifError in boolean default false,
			p_MacroGetLongResp in boolean default false,
			p_MacroRespContains in boolean default false,
			p_MacroAudit in boolean default false) return boolean
is
 l_UnionFlag boolean := FALSE;
 l_TempFlag boolean := FALSE;

 l_Found number := 0;

 l_tempBody varchar2(32767) := p_ProcBody;
 l_Clash_str1 varchar2(80) := g_MacroSendHttp;
 l_Clash_str_replace1 varchar2(80) := 'XXXX_HTTP';
 l_Clash_str2 varchar2(80) := '.SEND';
 l_Clash_str_replace2 varchar2(80) := '.XXXX';
begin

 if p_MacroSend then
	l_tempBody := replace(l_tempBody, l_Clash_str1, l_Clash_str_replace1);
	l_tempBody := replace(l_tempBody, l_Clash_str2, l_Clash_str_replace2);
	l_UnionFlag := isMacroUsed(g_MacroSend, l_tempBody);
	l_Found := l_Found + 1;
	l_tempBody := replace(p_ProcBody, l_Clash_str_replace1, l_Clash_str1);
	l_tempBody := replace(p_ProcBody, l_Clash_str_replace2, l_Clash_str2);
 end if;

 if p_MacroSendHttp then
	l_TempFlag := isMacroUsed(g_MacroSendHttp, l_tempBody);
	l_Found := l_Found + 1;
 	l_UnionFlag := l_UnionFlag OR l_TempFlag;
 end if;


 if p_MacroLogin then
	l_TempFlag := isMacroUsed(g_MacroLogin, l_tempBody);
	l_Found := l_Found + 1;
	l_UnionFlag := l_UnionFlag OR l_TempFlag;
 end if;


 if p_MacroGetResp then
	l_TempFlag := isMacroUsed(g_MacroGetResp, l_tempBody);
	l_Found := l_Found + 1;
	l_UnionFlag := l_UnionFlag OR l_TempFlag;
 end if;


 if p_MacroGetParam then
	l_TempFlag := isMacroUsed(g_MacroGetParam, l_tempBody);
	l_UnionFlag := l_UnionFlag OR l_TempFlag;
	l_Found := l_Found + 1;
 end if;

 if p_MacroNotifError then
	l_TempFlag := isMacroUsed(g_MacroNotifError, l_tempBody);
	l_Found := l_Found + 1;
	l_UnionFlag := l_UnionFlag OR l_TempFlag;
 end if;

 if p_MacroRespContains then
	l_TempFlag := isMacroUsed(g_MacroResponseContains, l_tempBody);
	l_Found := l_Found + 1;
	l_UnionFlag := l_UnionFlag OR l_TempFlag;
 end if;

 if p_MacroGetLongResp then
	l_TempFlag := isMacroUsed(g_MacroGetLongResp, l_tempBody);
	l_Found := l_Found + 1;
	l_UnionFlag := l_UnionFlag OR l_TempFlag;
 end if;

 if p_MacroAudit then
	l_TempFlag := isMacroUsed(g_MacroAudit, l_tempBody);
	l_Found := l_Found + 1;
	l_UnionFlag := l_UnionFlag OR l_TempFlag;
 end if;

 if l_Found = 0 then
	-- No Macros to be validated. Return TRUE
	l_UnionFlag := TRUE;
 end if;

 return (l_UnionFlag);
end CheckForMacros;


--
-- Scan the Procedure for a particular Macro
Function IsMacroUsed(p_Macro in varchar2,
		     p_ProcBody in varchar2) return boolean
is
 l_UnionFlag boolean;
 l_Found number := 0;

begin
	l_Found := INSTR(p_ProcBody, p_Macro, 1 , 1);
	if l_Found > 0 then
		l_UnionFlag := true;
	else
		l_UnionFlag := false;
	end if;

	return (l_UnionFlag);
end IsMacroUsed;

--
-- Find the Paramter usages within the Procedure
Procedure FindParamUsage(ProcBody in varchar2)
is

begin
 	pv_WIParamUsed := false;
 	pv_OrderParamUsed := false;
 	pv_LineParamUsed := false;
 	pv_FAParamUsed := false;

	if instr(upper(ProcBody), '$WI.') > 1 then
 		pv_WIParamUsed := true;
	elsif instr(upper(ProcBody), '$LINE.') > 1 then
 		pv_LineParamUsed := true;
	elsif instr(upper(ProcBody), '$ORDER.') > 1 then
 		pv_OrderParamUsed := true;
	elsif instr(upper(ProcBody), '$FA.') > 1 then
 		pv_FaParamUsed := true;
	end if;

end FindParamUsage;

-- Meta-Data for Procedure Specifications
-- Package Initializations
Function getProcSpec(p_ProcType in varchar2) return varchar2
is
begin
 if p_ProcType = g_SvcWIMapType then
	return (g_SvcWIMapSpec);
 elsif p_ProcType = g_WIFAMapType then
	return (g_WIFAMapSpec);
 elsif p_ProcType = g_WIWFStartType then
	return (g_WIWFStartSpec);
 elsif p_ProcType = g_WIParamEvalType then
	return (g_WIParamEvalSpec);
 elsif p_ProcType = g_FAParamEvalType then
	return (g_FAParamEvalSpec);
 elsif p_ProcType = g_EvalAllFAParamType then
	return (g_EvalAllFAParamSpec);
 elsif p_ProcType = g_LocateFEType then
	return (g_LocateFESpec);
 elsif p_ProcType = g_FPType then
	return (g_FPSpec);
 elsif p_ProcType = g_ConnectType then
	return (g_ConnectSpec);
 elsif p_ProcType = g_DisconnectType then
	return (g_DisconnectSpec);
 end if;

end getProcSpec;

-- Meta-Data for any comments to be generated
Function getComments(p_ProcType in varchar2) return varchar2
is
begin
 if p_ProcType = g_SvcWIMapType then
	return (g_SvcWIMapComments);
 elsif p_ProcType = g_WIFAMapType then
	return (g_WIFAMapComments);
 elsif p_ProcType = g_WIWFStartType then
	return (g_WIWFStartComments);
 elsif p_ProcType = g_WIParamEvalType then
	return (g_WIParamEvalComments);
 elsif p_ProcType = g_FAParamEvalType then
	return (g_FAParamEvalComments);
 elsif p_ProcType = g_EvalAllFAParamType then
	return (g_EvalAllFAParamComments);
 elsif p_ProcType = g_LocateFEType then
	return (g_LocateFEComments);
 elsif p_ProcType = g_FPType then
	return (g_FPComments);
 elsif p_ProcType = g_ConnectType then
	return (g_ConnectComments);
 elsif p_ProcType = g_DisconnectType then
	return (g_DisconnectComments);
 end if;

end getComments;


-- Meta-Data for any backward compatibility code to be generated
-- For example: The Specification for the Fulfillment procedure is now
-- changed to have the paramters named as "p_xxx" instead of just "xxx"
-- p_channel_name instead of channel_name
-- To allow backward compatibility to earlier procedures new PL/SQL variables
-- channel_name is created so that the old procedures compile successfully
Function getAdditionalStuff(p_ProcType in varchar2) return varchar2
is
 l_AdditionalStuff varchar2(2000);
begin
 if  p_ProcType = g_FPType then
	l_AdditionalStuff :=
		'order_id NUMBER := p_order_id;' || g_new_line ||
		'line_item_id NUMBER := p_line_item_id;' || g_new_line ||
		'workitem_instance_id NUMBER := p_wi_instance_id;' || g_new_line ||
		'fa_instance_id NUMBER := p_fa_instance_id;' || g_new_line ||
		'db_channel_name VARCHAR2(40) := p_channel_name;' || g_new_line ||
		'fe_name VARCHAR2(80) := p_fe_name;' || g_new_line ||
		'fa_item_type VARCHAR2(8) := p_fa_item_type;' || g_new_line ||
		'fa_item_key VARCHAR2(240) := p_fa_item_key;' || g_new_line ||
		'LOG VARCHAR2(1) := ''N'';' || g_new_line ||
		'NOLOG VARCHAR2(1) := ''Y'';' || g_new_line ||
		'RETRY number := 1;' || g_new_line ||
		'NORETRY number := 0;' || g_new_line ||
		'fa_item_key VARCHAR2(240) := p_fa_item_key;' || g_new_line ||
		'sdp_internal_response VARCHAR2(32767);' || g_new_line ||
		'sdp_internal_err_code VARCHAR2(40) := p_return_code;' || g_new_line ||
		'sdp_internal_err_str VARCHAR2(40) := p_error_description;' || g_new_line;

	return (l_AdditionalStuff);
 elsif p_ProcType in (g_ConnectType, g_DisconnectType) then
	l_AdditionalStuff :=
		'fe_name VARCHAR2(80) := p_fe_name;' || g_new_line ||
		'channel_name VARCHAR2(40) := p_channel_name;' || g_new_line ||
		'sdp_internal_response VARCHAR2(32767);' || g_new_line ||
		'sdp_internal_err_code VARCHAR2(40) := p_return_code;' || g_new_line ||
		'sdp_internal_err_str VARCHAR2(40) := p_error_description;' || g_new_line;
	return (l_AdditionalStuff);
 else
	return (null);
 end if;

end getAdditionalStuff;

--
-- Meta-Data for Procedure Initializations to be done
-- For e.g. The Fulfillment Procedures requires the Parameter Cache to be initialized
-- the SYNC message to be sent etc. All this is wrapped in an "initfp" routine
-- and it is registared in this routine to be generated
-- A Default Initialization routine "initdefault" is generated
-- All these initialzation routines are in XDP_MACROS package
Function getInitialization(p_ProcType in varchar2,
			   p_ProcName in varchar2) return varchar2
is
 l_InitStuff varchar2(2000);
begin
 if  p_ProcType = g_FPType then
	-- Initialization for a Fulfillment Procedure
	-- Initialize the Cache etc..
	l_InitStuff := 'xdp_macros.initfp(p_order_id, p_line_item_id, p_wi_instance_id, ' ||
					  'p_fa_instance_id, p_channel_name, p_fe_name, ''' ||
					  p_ProcName || ''');' ||
					  g_new_line;
 elsif p_ProcType in (g_ConnectType, g_DisconnectType) then
	-- Initialization for a Connect/DisconnectProcedure
	-- Cleanup buffers etc...
	l_InitStuff := 'xdp_macros.initconnection(p_channel_name, p_fe_name);' || g_new_line;
 elsif p_ProcType = g_SvcWIMapType then
	-- Default Initialization
	l_InitStuff := 'xdp_macros.initdefault(p_order_id, p_line_item_id, null, '||
					      'null);' ||g_new_line;
 elsif p_ProcType in (g_WIFAMapType, g_WIWFStartType, g_WIParamEvalType) then
	l_InitStuff := 'xdp_macros.initdefault(p_order_id, p_line_item_id, p_wi_instance_id, '||
					      'null);' ||g_new_line;
 else
	l_InitStuff := 'xdp_macros.initdefault(p_order_id, p_line_item_id, p_wi_instance_id, '||
					      'p_fa_instance_id);' ||g_new_line;
 end if;

 return (l_InitStuff);

end getInitialization;

--
-- Meta-Data for Procedure exit to be done
-- For e.g. The Fulfillment Procedures requires the Parameter Cache to be cleared
-- All this is wrapped in an "EndProc" routine and it is registared in this routine
-- to be generated
-- All these finilization routines are in XDP_MACROS package
Function getFinilization(p_ProcType in varchar2,
			 p_ProcName in varchar2) return varchar2
is
 l_finalStuff varchar2(500);
begin
	l_finalStuff := g_new_line || g_new_line ||
			'xdp_macros.EndProc(p_return_code, p_error_description);' || g_new_line;
   return (l_finalStuff);

end getFinilization;

--
-- Initilization to clean up package variables
Procedure Init
is

begin
	g_ProcSpec := null;
	g_ProcHeader := null;
	g_ProcFooter  := null;

	g_ProcBody  := null;

	g_PackageSpec  := null;
	g_PackageHeader  := null;
	g_PackageFooter  := ' END ';

	g_PackageBody  := null;

end Init;

--
-- Meta-Data for Procedure Specifications, Procedure Comments
Procedure InitGlobals
is
 l_temp varchar2(10) := ')' || g_new_line;

begin
--  Svc - WI mapping
 g_SvcWIMapSpec :=
 		    'p_order_id       IN  NUMBER,' || g_new_line  ||
		    'p_line_item_id   IN  NUMBER,' || g_new_line  ||
		    'p_return_code    OUT NUMBER,' || g_new_line  ||
		    'p_error_description OUT VARCHAR2';

 g_SvcWIMapComments :=  g_StartComment || g_new_line ||
			g_SvcWIMapSpec || g_new_line ||
			g_EndComment || g_new_line;

 g_SvcWIMapSpec := g_SvcWIMapSpec || l_temp;


-- WI - FA Mapping
 g_WIFAMapSpec :=
 		    'p_order_id       IN  NUMBER,' || g_new_line  ||
		    'p_line_item_id   IN  NUMBER,' || g_new_line  ||
		    'p_wi_instance_id IN  NUMBER,' || g_new_line  ||
		    'p_return_code    OUT NUMBER,' || g_new_line  ||
		    'p_error_description OUT VARCHAR2';

 g_WIFAMapComments :=   g_StartComment || g_new_line ||
			g_WIFAMapSpec || g_new_line ||
			g_EndComment || g_new_line;

 g_WIFAMapSpec := g_WIFAMapSpec || l_temp;


-- WI WF Start
 g_WIWFStartSpec :=
 		    'p_order_id       IN  NUMBER,' || g_new_line  ||
		    'p_line_item_id   IN  NUMBER,' || g_new_line  ||
		    'p_wi_instance_id IN  NUMBER,' || g_new_line  ||
		    'p_wf_item_type     OUT  VARCHAR2,' || g_new_line  ||
		    'p_wf_item_key      OUT  VARCHAR2,' || g_new_line  ||
		    'p_wf_process_name  OUT  VARCHAR2,' || g_new_line  ||
		    'p_return_code    OUT NUMBER,' || g_new_line  ||
		    'p_error_description OUT VARCHAR2';

 g_WIWFStartComments :=	g_StartComment || g_new_line ||
			g_WIWFStartSpec || g_new_line ||
			g_EndComment || g_new_line;

 g_WIWFStartSpec := g_WIWFStartSpec || l_temp;


-- WI Param Eval
 g_WIParamEvalSpec :=
 		    'p_order_id       IN  NUMBER,' || g_new_line  ||
		    'p_line_item_id   IN  NUMBER,' || g_new_line  ||
		    'p_wi_instance_id IN  NUMBER,' || g_new_line  ||
		    'p_param_val      IN  VARCHAR2,' || g_new_line  ||
		    'p_param_ref_val  IN  VARCHAR2,' || g_new_line  ||
		    'p_param_eval_val      OUT  VARCHAR2,' || g_new_line  ||
		    'p_param_eval_ref_val  OUT  VARCHAR2,' || g_new_line  ||
		    'p_return_code    OUT NUMBER,' || g_new_line  ||
		    'p_error_description OUT VARCHAR2';

 g_WIParamEvalComments :=	g_StartComment || g_new_line ||
				g_WIParamEvalSpec || g_new_line ||
				g_EndComment || g_new_line;

 g_WIParamEvalSpec := g_WIParamEvalSpec || l_temp;


-- FA Param Eval
 g_FAParamEvalSpec :=
 		    'p_order_id       IN  NUMBER,' || g_new_line  ||
		    'p_line_item_id   IN  NUMBER,' || g_new_line  ||
		    'p_wi_instance_id IN  NUMBER,' || g_new_line  ||
		    'p_fa_instance_id IN  NUMBER,' || g_new_line  ||
		    'p_param_val      IN  VARCHAR2,' || g_new_line  ||
		    'p_param_ref_val  IN  VARCHAR2,' || g_new_line  ||
		    'p_param_eval_val      OUT  VARCHAR2,' || g_new_line  ||
		    'p_param_eval_ref_val  OUT  VARCHAR2,' || g_new_line  ||
		    'p_return_code    OUT NUMBER,' || g_new_line  ||
		    'p_error_description OUT VARCHAR2';

 g_FAParamEvalComments :=	g_StartComment || g_new_line ||
				g_FAParamEvalSpec || g_new_line ||
				g_EndComment || g_new_line;

 g_FAParamEvalSpec := g_FAParamEvalSpec || l_temp;


-- FA Eval All Param
 g_EvalAllFAParamSpec :=
 		    'p_order_id       IN  NUMBER,' || g_new_line  ||
		    'p_line_item_id   IN  NUMBER,' || g_new_line  ||
		    'p_wi_instance_id IN  NUMBER,' || g_new_line  ||
		    'p_fa_instance_id IN  NUMBER,' || g_new_line  ||
		    'p_return_code    OUT NUMBER,' || g_new_line  ||
		    'p_error_description OUT VARCHAR2';

 g_EvalAllFAParamComments :=	g_StartComment || g_new_line ||
				g_EvalAllFAParamSpec || g_new_line ||
				g_EndComment || g_new_line;

 g_EvalAllFAParamSpec := g_EvalAllFAParamSpec || l_temp;


-- Locate FE
 g_LocateFESpec :=  'p_order_id       IN  NUMBER,' || g_new_line  ||
		    'p_line_item_id   IN  NUMBER,' || g_new_line  ||
		    'p_wi_instance_id IN  NUMBER,' || g_new_line  ||
		    'p_fa_instance_id IN  NUMBER,' || g_new_line  ||
		    'p_fe_name        OUT VARCHAR2,' || g_new_line  ||
		    'p_return_code    OUT NUMBER,' || g_new_line  ||
		    'p_error_description OUT VARCHAR2';

 g_LocateFEComments :=	g_StartComment || g_new_line ||
			g_LocateFESpec || g_new_line ||
			g_EndComment || g_new_line;

 g_LocateFESpec := g_LocateFESpec || l_temp;


-- FP
 g_FPSpec :=  	    'p_order_id       IN  NUMBER,' || g_new_line  ||
		    'p_line_item_id   IN  NUMBER,' || g_new_line  ||
		    'p_wi_instance_id IN  NUMBER,' || g_new_line  ||
		    'p_fa_instance_id IN  NUMBER,' || g_new_line  ||
		    'p_channel_name   IN  VARCHAR2,' || g_new_line  ||
		    'p_fe_name        IN VARCHAR2,' || g_new_line  ||
		    'p_fa_item_type   IN VARCHAR2,' || g_new_line  ||
		    'p_fa_item_key    IN VARCHAR2,' || g_new_line  ||
		    'p_return_code    OUT NUMBER,' || g_new_line ||
		    'p_error_description OUT VARCHAR2';

 g_FPComments :=	g_StartComment || g_new_line ||
			g_FPSpec || g_new_line ||
			g_EndComment || g_new_line;

 g_FPSpec := g_FPSpec || l_temp;


-- Connect
 g_ConnectSpec :=   'p_fe_name        IN VARCHAR2,' || g_new_line  ||
		    'p_channel_name   IN  VARCHAR2,' || g_new_line  ||
		    'p_return_code    OUT NUMBER,' || g_new_line ||
		    'p_error_description OUT VARCHAR2';

 g_ConnectComments :=	g_StartComment || g_new_line ||
			g_ConnectSpec || g_new_line ||
			g_EndComment || g_new_line;

 g_ConnectSpec := g_ConnectSpec || l_temp;


-- Disconnect
 g_DisconnectSpec :='p_fe_name        IN VARCHAR2,' || g_new_line  ||
		    'p_channel_name   IN  VARCHAR2,' || g_new_line  ||
		    'p_return_code    OUT NUMBER,' || g_new_line ||
		    'p_error_description OUT VARCHAR2';

 g_DisconnectComments :=	g_StartComment || g_new_line ||
				g_DisconnectSpec || g_new_line ||
				g_EndComment || g_new_line;

 g_DisconnectSpec := g_DisconnectSpec || l_temp;

 InitDisplayNames;
end InitGlobals;

--
-- Meta-Data for Display Names. In case of errors the error message
-- must contain translated messages. This  routine sets it up once
Procedure InitDisplayNames
is

begin

 g_SvcWIMapTypeDisp := FetchLookupMeaning(g_ProcType,'DYNAMIC_WI_MAPPING');
 g_WIFAMapTypeDisp := FetchLookupMeaning(g_ProcType,'DYNAMIC_FA_MAPPING');
 g_WIWFStartTypeDisp := FetchLookupMeaning(g_ProcType,'EXEC_WI_WORKFLOW');

 g_WIParamEvalTypeDisp := FetchLookupMeaning(g_ProcType,'WI_PARAM_EVAL_PROC');
 g_FAParamEvalTypeDisp := FetchLookupMeaning(g_ProcType,'FA_PARAM_EVAL_PROC');
 g_EvalAllFAParamTypeDisp := FetchLookupMeaning(g_ProcType,'FA_PARAM_EVAL_ALL_PROC');

 g_LocateFETypeDisp := FetchLookupMeaning(g_ProcType,'LOCATE_FE');
 g_FPTypeDisp := FetchLookupMeaning(g_ProcType,'PROVISIONING');

 g_ConnectTypeDisp := FetchLookupMeaning(g_ProcType,'CONNECT');
 g_DisconnectTypeDisp := FetchLookupMeaning(g_ProcType,'DISCONNECT');

 pv_ParamWIDisp := FetchLookupMeaning(g_ParamType, 'WORKITEM_PARAM');
 pv_ParamFADisp := FetchLookupMeaning(g_ParamType, 'FA_PARAM');
 pv_ParamLineDisp := FetchLookupMeaning(g_ParamType, 'LINE_PARAM');
 pv_ParamOrderDisp := FetchLookupMeaning(g_ParamType, 'ORDER_PARAM');
 pv_ParamFEDisp := FetchLookupMeaning(g_ParamType, 'FE_ATTR');

end InitDisplayNames;


--
-- Meta-data for Procedure Name Display names
-- Return the display for a procedure type
Function GetProcDispName(p_ProcType in varchar2) return varchar2
is

begin
	if  p_ProcType = g_FPType then
		return(g_FPTypeDisp);
	elsif p_ProcType = g_ConnectType then
		return (g_ConnectTypeDisp);
	elsif p_ProcType = g_DisconnectType then
		return (g_DisconnectTypeDisp);
	elsif p_ProcType = g_SvcWIMapType then
		return (g_SvcWIMapTypeDisp);
	elsif p_ProcType = g_WIFAMapType then
		return (g_WIFAMapTypeDisp);
	elsif p_ProcType = g_WIWFStartType then
		return (g_WIWFStartTypeDisp);
	elsif p_ProcType = g_WIParamEvalType then
		return (g_WIParamEvalTypeDisp);
	elsif p_ProcType = g_FAParamEvalType then
		return (g_FAParamEvalTypeDisp);
	elsif p_ProcType = g_EvalAllFAParamType then
		return (g_EvalAllFAParamTypeDisp);
	elsif p_ProcType = g_LocateFEType then
		return (g_LocateFETypeDisp);
	else
		return (p_ProcType);
 	end if;


end GetProcDispName;

--
-- Meta-data for Parameter Name Display names
-- Return the display for Parameter type(s) in a "," separated  string
-- This is used when setting the token for a list of paramter types
Function GetParamDispName(p_OrderParam in boolean default false,
			  p_LineParam in boolean default false,
			  p_WIParam in boolean default false,
			  p_FAParam in boolean default false) return varchar2
is
 l_Token varchar2(500);
 l_prepend boolean := false;
begin
	if p_OrderParam then
		l_Token := pv_ParamOrderDisp;
		l_prepend := true;
	end if;
	if p_LineParam then
		if l_prepend then
			l_Token := l_Token || ', ';
		end if;
		l_Token := l_Token || pv_ParamLineDisp ;
		l_prepend := true;
	end if;
	if p_WIParam then
		if l_prepend then
			l_Token := l_Token || ', ';
		end if;
		l_Token := l_Token || pv_ParamWIDisp ;
		l_prepend := true;
	end if;
	if p_FAParam then
		if l_prepend then
			l_Token := l_Token || ', ';
		end if;
		l_Token := l_Token || pv_ParamFADisp ;
		l_prepend := true;
	end if;

	return (l_Token);

end GetParamDispName;

--
-- Routine for getting Display Names.
-- Get the display names for Different Procedure Types and Paramter Dispay Names
Function FetchLookupMeaning(p_LookupType in varchar2,
			  p_LookupCode in varchar2) return varchar2
is
 l_Meaning varchar2(80) := p_LookupCode;
begin

 if p_LookupType = g_ProcType then
	for v_getProcLookupMeaning in c_getProcLookupMeaning(p_LookupCode) loop
		l_Meaning := v_getProcLookupMeaning.meaning;
	end loop;
 elsif  p_LookupType = g_ParamType then
	for v_getParamLookupMeaning in c_getParamLookupMeaning(p_LookupCode) loop
		l_Meaning := v_getParamLookupMeaning.meaning;
	end loop;
 end if;

 return (l_Meaning);

end FetchLookupMeaning;

Procedure FetchAdapterApplMode( p_AdapterType in varchar2,
				x_ErrorCode OUT NOCOPY number,
                             	x_ErrorString OUT NOCOPY varchar2)
is
begin
 g_AdapterType := p_AdapterType;

 for v_getAdapterApplMode in c_getAdapterApplMode loop
	g_ApplMode := v_getAdapterApplMode.application_mode;
	g_AdapterTypeDisp := v_getAdapterApplMode.display_name;
 end loop;

end FetchAdapterApplMode;


begin

 InitGlobals;
end XDP_PROCEDURE_BUILDER;

/
