--------------------------------------------------------
--  DDL for Package XDP_PROCEDURE_BUILDER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_PROCEDURE_BUILDER_UTIL" AUTHID CURRENT_USER AS
/* $Header: XDPPRBUS.pls 120.1 2005/06/16 02:24:52 appldev  $ */


Procedure ReplaceOrderParameters(p_OrderID in number,
				 p_LineItemID in  number,
				 p_WIInstanceID in number,
				 p_FAInstanceID in number,
				 p_CmdString in varchar2,
				 x_CmdStringReplaced OUT NOCOPY varchar2,
				 x_CmdStringLog OUT NOCOPY varchar2,
			      	 x_ErrorCode OUT NOCOPY number,
			      	 x_ErrorString OUT NOCOPY varchar2);

Procedure ValidateFPParameters( p_ID in number,
				p_ProcBody in varchar2,
			      	x_ErrorCode OUT NOCOPY number,
			      	x_ErrorString OUT NOCOPY varchar2);

Procedure ReplaceFEAttributes(  p_FeName in varchar2,
				p_CmdString in varchar2,
				x_CmdStringReplaced OUT NOCOPY varchar2,
			      	x_ErrorCode OUT NOCOPY number,
			      	x_ErrorString OUT NOCOPY varchar2);

Procedure ValidateFEAttributes( p_FeTypeID in number,
				p_ProcBody in varchar2,
			      	x_ErrorCode OUT NOCOPY number,
			      	x_ErrorString OUT NOCOPY varchar2);

Procedure TranslateDefMacros (ProcName   in  varchar2,
                              ProcStr         in  varchar2,
                              CompiledProc OUT NOCOPY varchar2);

Procedure TranslateFPMacros (ProcName   in  varchar2,
                             ProcStr         in  varchar2,
                             CompiledProc OUT NOCOPY varchar2);

Procedure TranslateConnMacros (ProcName   in  varchar2,
                               ProcBody in  varchar2,
                               CompiledProc OUT NOCOPY varchar2);

Procedure TranslateDisconnMacros (ProcName   in  varchar2,
                                 ProcBody in  varchar2,
                                 CompiledProc OUT NOCOPY varchar2);

end XDP_PROCEDURE_BUILDER_UTIL;

 

/
