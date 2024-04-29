--------------------------------------------------------
--  DDL for Package DOM_DOC_TEXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_DOC_TEXT_PVT" AUTHID CURRENT_USER AS
/* $Header: DOMVIDXS.pls 120.0 2006/04/05 06:04:22 dedatta noship $ */

-- -----------------------------------------------------------------------------
--  				Public Globals
-- -----------------------------------------------------------------------------

G_FILE_NAME	CONSTANT  VARCHAR2(12)  :=  'DOMVIDXS.pls';

G_RETCODE_SUCCESS	CONSTANT  NUMBER  :=  0;
G_RETCODE_WARNING	CONSTANT  NUMBER  :=  1;
G_RETCODE_ERROR		CONSTANT  NUMBER  :=  2;

G_MISS_NUM		CONSTANT  NUMBER       :=  9.99E125;
G_MISS_CHAR		CONSTANT  VARCHAR2(1)  :=  CHR(0);
G_MISS_DATE		CONSTANT  DATE         :=  TO_DATE('1','J');

G_STATUS_SUCCESS	CONSTANT  VARCHAR2(1)  :=  'S';
G_STATUS_WARNING	CONSTANT  VARCHAR2(1)  :=  'W';
G_STATUS_ERROR		CONSTANT  VARCHAR2(1)  :=  'E';
G_STATUS_UNEXP_ERROR	CONSTANT  VARCHAR2(1)  :=  'U';

G_EXC_ERROR		EXCEPTION;
G_EXC_UNEXPECTED_ERROR	EXCEPTION;

-- -----------------------------------------------------------------------------
--				  set_Log_Mode
-- -----------------------------------------------------------------------------

FUNCTION set_Log_Mode ( p_Mode  IN  VARCHAR2 )
RETURN VARCHAR2;

PROCEDURE set_Log_Mode ( p_Mode  IN  VARCHAR2 );

PROCEDURE Log_Line ( p_Buffer  IN  VARCHAR2 );

-- -----------------------------------------------------------------------------
--			     Build_Document_Text_Index
-- -----------------------------------------------------------------------------

PROCEDURE Build_Doc_Text_Index
(
   ERRBUF		OUT  NOCOPY  VARCHAR2
,  RETCODE		OUT  NOCOPY  NUMBER
,  p_Action		IN           VARCHAR2
);

-- -----------------------------------------------------------------------------
--				  get_Msg_Text
-- -----------------------------------------------------------------------------

FUNCTION get_Msg_Text
RETURN VARCHAR2;

END DOM_DOC_TEXT_PVT;

 

/
