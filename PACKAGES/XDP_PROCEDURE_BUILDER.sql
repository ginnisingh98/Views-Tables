--------------------------------------------------------
--  DDL for Package XDP_PROCEDURE_BUILDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_PROCEDURE_BUILDER" AUTHID CURRENT_USER AS
/* $Header: XDPPRBDS.pls 120.1 2005/06/16 02:24:07 appldev  $ */

 g_SvcWIMapType varchar2(80) := 'DYNAMIC_WI_MAPPING';
 g_WIFAMapType varchar2(80) := 'DYNAMIC_FA_MAPPING';
 g_WIWFStartType varchar2(80) := 'EXEC_WI_WORKFLOW';

 g_WIParamEvalType varchar2(80) := 'WI_PARAM_EVAL_PROC';
 g_FAParamEvalType varchar2(80) := 'FA_PARAM_EVAL_PROC';
 g_EvalAllFAParamType varchar2(80) := 'FA_PARAM_EVAL_ALL_PROC';

 g_LocateFEType varchar2(80) := 'LOCATE_FE';
 g_FPType varchar2(80) := 'PROVISIONING';

 g_ConnectType varchar2(80) := 'CONNECT';
 g_DisconnectType varchar2(80) := 'DISCONNECT';

 g_MacroSend varchar2(30) 	:= 'SEND';
 g_MacroSendHttp varchar2(30) 	:= 'SEND_HTTP';
 g_MacroLogin varchar2(30) 	:= 'LOGIN';
 g_MacroGetResp varchar2(30) 	:= 'GET_RESPONSE';
 g_MacroGetParam varchar2(30) 	:= 'GET_PARAM_VALUE';
 g_MacroNotifError varchar2(30) := 'NOTIFY_ERROR';
 g_MacroResponseContains varchar2(30) := 'RESPONSE_CONTAINS';

-- New for 11.5.6++
 g_MacroAudit varchar2(30) 	:= 'AUDIT';
 g_MacroGetLongResp varchar2(30):= 'GET_LONG_RESPONSE';

 g_SvcWIMapSpec varchar2(2000);
 g_SvcWIMapComments varchar2(2000);
 g_WIFAMapSpec varchar2(2000);
 g_WIFAMapComments varchar2(2000);
 g_WIWFStartSpec varchar2(2000);
 g_WIWFStartComments varchar2(2000);

 g_WIParamEvalSpec varchar2(2000);
 g_WIParamEvalComments varchar2(2000);
 g_FAParamEvalSpec varchar2(2000);
 g_FAParamEvalComments varchar2(2000);
 g_EvalAllFAParamSpec varchar2(2000);
 g_EvalAllFAParamComments varchar2(2000);

 g_LocateFESpec varchar2(2000);
 g_LocateFEComments varchar2(2000);
 g_FPSpec varchar2(2000);
 g_FPComments varchar2(2000);

 g_ConnectSpec varchar2(2000);
 g_ConnectComments varchar2(2000);
 g_DisconnectSpec varchar2(2000);
 g_DisconnectComments varchar2(2000);

 g_SvcWIMapDefBody varchar2(2000);
 g_WIFAMapDefBody varchar2(2000);
 g_WIWFStartDefBody varchar2(2000);

 g_WIParamEvalDefBody varchar2(2000);
 g_FAParamEvalDefBody varchar2(2000);
 g_EvalAllFAParamDefBody varchar2(2000);

 g_LocateFEDefBody varchar2(2000);
 g_FPDefBody varchar2(2000);

 g_ConnectDefBody varchar2(2000);
 g_DisconnectDefBody varchar2(2000);


 g_PackageSuffix varchar2(10) := '_U';
 g_PackagePrefix varchar2(10) := 'XDP_';
-- g_MaxProcLength number := 23;
 g_MaxProcLength number := 15;

-- For Getting Display Names
-- Also used by XDP_PROCEDURE_BUILDER_UTIL package
 pv_ParamWI varchar2(80) := 'WI';
 pv_ParamWIDisp varchar2(80) := 'WI';

 pv_ParamFA varchar2(80) := 'FA';
 pv_ParamFADisp varchar2(80) := 'FA';

 pv_ParamLine varchar2(80) := 'LINE';
 pv_ParamLineDisp varchar2(80) := 'LINE';

 pv_ParamOrder varchar2(80) := 'ORDER';
 pv_ParamOrderDisp varchar2(80) := 'ORDER';

 pv_ParamFE varchar2(80) := 'FE';
 pv_ParamFEDisp varchar2(80) := 'FE';

-- Used which checking and generating the Procedure

 pv_WIParamUsed boolean := false;
 pv_OrderParamUsed boolean := false;
 pv_LineParamUsed boolean := false;
 pv_FAParamUsed boolean := false;

 Procedure GeneratePackageName ( p_ProcType in varchar2,
				 p_ProcName in varchar2,
				 p_Validate in boolean default false,
				 x_PackageName OUT NOCOPY varchar2,
				 x_ErrorCode OUT NOCOPY number,
				 x_ErrorString OUT NOCOPY varchar2);

 Function DecodeProcName (p_PackageName in varchar2) return varchar2;

 Procedure GenerateProcSpec(p_ProcType in varchar2,
			   p_ProcName in varchar2);

 Function GenerateProcDefBody(p_ProcType in varchar2) return varchar2;

 Procedure GenerateProcHeader(p_ProcType in VARCHAR2,
			      p_ProcName in varchar2);

 Procedure GenerateProcFooter(p_ProcType in VARCHAR2,
                             p_ProcName in varchar2);

 Procedure GenerateProcBody(p_ProcType in VARCHAR2,
                            p_ProcName in varchar2,
			    p_ProcBody in varchar2 default null);

 Procedure GeneratePackageSpec(p_ProcType in varchar2,
			       p_ProcName in varchar2,
			       x_ErrorCode OUT NOCOPY number,
                               x_ErrorString OUT NOCOPY varchar2);

 Procedure GeneratePackageSpec(p_PackageName in VARCHAR2,
			      p_ProcType in varchar2,
			      p_ProcName in varchar2,
			      x_ErrorCode OUT NOCOPY number,
                              x_ErrorString OUT NOCOPY varchar2);

 Procedure GeneratePackageBody(p_ProcType in varchar2,
			      p_ProcName in varchar2,
			      p_ProcBody in varchar2 default null,
			      x_ErrorCode OUT NOCOPY number,
                              x_ErrorString OUT NOCOPY varchar2);

 Procedure GeneratePackageBody(p_PackageName in VARCHAR2,
			      p_ProcType in varchar2,
			      p_ProcName in varchar2,
			      p_ProcBody in varchar2 default null,
			      x_ErrorCode OUT NOCOPY number,
                              x_ErrorString OUT NOCOPY varchar2);

 Procedure GeneratePackageHeader(p_PackageName in VARCHAR2,
				 p_SpecOrBody in VARCHAR2 default 'SPEC');

 Procedure GeneratePackageFooter(p_PackageName in VARCHAR2);


 Procedure PrecompileProcedure(p_ProcType in varchar2,
			       p_ProcBody in varchar2,
			       p_ID     in number default null,
			       p_AdapterType in varchar2 default null,
			       p_ValidateParams in boolean default true,
			       x_ErrorCode OUT NOCOPY number,
			       x_ErrorString OUT NOCOPY varchar2);

end XDP_PROCEDURE_BUILDER;

 

/
