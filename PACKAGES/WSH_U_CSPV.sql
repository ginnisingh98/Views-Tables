--------------------------------------------------------
--  DDL for Package WSH_U_CSPV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_U_CSPV" AUTHID CURRENT_USER AS
/* $Header: WSHUCSPS.pls 115.5 2002/11/12 01:59:47 nparikh ship $ */

TYPE CSPValidateInRec IS RECORD (
				City				VARCHAR2(30),
				StateProv		VARCHAR2(5),
				PostalCode		VARCHAR2(16));


TYPE CSPValidateOutRec IS RECORD (
				UPSOnLine		VARCHAR2(9),
				AppVersion		VARCHAR2(20),
				ReturnCode		NUMBER,
				MessageNumber	NUMBER,
				MessageText		VARCHAR2(500),
				Rank				NUMBER,
				Quality			NUMBER,
				City				VARCHAR2(30),
				StateProv		VARCHAR2(5),
				PostalCodeLow	VARCHAR2(16),
				PostalCodeHigh VARCHAR2(16));


TYPE CSPValidateOutTblTyp IS TABLE OF CSPValidateOutRec
				INDEX BY BINARY_INTEGER;

PROCEDURE CSP_Validate(
				p_api_version            IN   NUMBER,
				p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
				x_return_status         OUT NOCOPY    VARCHAR2,
				x_msg_count             OUT NOCOPY    NUMBER,
				x_msg_data              OUT NOCOPY    VARCHAR2,
				p_AppVersion				 IN	VARCHAR2,
				p_AcceptLicenseAgreement IN   VARCHAR2,
				p_ResponseType				 IN	VARCHAR2,
				p_Request_in				 IN	CSPValidateInRec,
				x_CSPValidate_out			OUT NOCOPY 	CSPValidateOutTblTyp
				);



END WSH_U_CSPV;

 

/
