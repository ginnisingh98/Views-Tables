--------------------------------------------------------
--  DDL for Package BIS_RSS_PORTLETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RSS_PORTLETS_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPRSSS.pls 120.1 2005/10/27 04:28:44 ugodavar noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPRSSS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Public package for populating the RSS Portlets tables     |
REM |             - BIS_RSS_PORTLETS                                        |
REM |             - BIS_RSS_PORTLETS_TL                                     |
REM | NOTES                                                                 |
REM | 01/20/05  nbarik   Initial Creation.                                  |
REM | 10/27/05  ugodavar Bug.Fix.4700227 - Procedure Add_Language           |
REM |                                                                       |
REM +=======================================================================+
*/


TYPE Rss_Portlet_Type IS RECORD
(
    Portlet_Short_Name     VARCHAR2(255)
  , Name                   VARCHAR2(255)
  , Description            VARCHAR2(2000)
  , Xml_Url                VARCHAR2(2000)
  , Xsl_Url                VARCHAR2(2000)
  , Created_By             NUMBER(15)
  , Creation_Date          DATE
  , Last_Updated_By        NUMBER(15)
  , Last_Update_Date       DATE
  , Last_Update_login      NUMBER(15)
);


PROCEDURE Load_Row(
  p_Commit              IN          VARCHAR2
 ,p_Rss_Portlet_Rec     IN          BIS_RSS_PORTLETS_PUB.Rss_Portlet_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);

PROCEDURE Translate_Row (
 p_Commit               IN          VARCHAR2
,p_Rss_Portlet_Rec      IN          BIS_RSS_PORTLETS_PUB.Rss_Portlet_Type
,x_return_status        OUT NOCOPY  VARCHAR2
,x_msg_count            OUT NOCOPY  NUMBER
,x_msg_data             OUT NOCOPY  VARCHAR2
);

PROCEDURE Add_Language;

END BIS_RSS_PORTLETS_PUB;

 

/
