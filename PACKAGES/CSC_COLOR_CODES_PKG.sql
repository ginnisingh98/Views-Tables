--------------------------------------------------------
--  DDL for Package CSC_COLOR_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_COLOR_CODES_PKG" AUTHID CURRENT_USER as
/* $Header: csctpccs.pls 115.6 2002/12/03 19:30:03 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_COLOR_CODES_PKG
-- Purpose          :
-- History          :
--	03 Nov 00	axsubram	Added Load_row for NLS (#1487340)
-- 27 Nov 02   jamose For Fnd_Api_G_Miss* and NOCOPY changes
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_COLOR_CODE   IN OUT NOCOPY VARCHAR2,
          p_RATING_CODE          VARCHAR2,
          p_LAST_UPDATE_DATE     DATE,
          p_LAST_UPDATED_BY      NUMBER,
          p_CREATION_DATE        DATE,
          p_CREATED_BY           NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER);

PROCEDURE Update_Row(
          p_COLOR_CODE         VARCHAR2,
          p_RATING_CODE        VARCHAR2,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN  NUMBER);

PROCEDURE Lock_Row(
          p_COLOR_CODE         VARCHAR2,
          p_RATING_CODE        VARCHAR2,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE      DATE,
          p_CREATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN  NUMBER);

PROCEDURE Delete_Row(
    p_COLOR_CODE  VARCHAR2);

PROCEDURE Load_Row(
          p_COLOR_CODE         VARCHAR2,
          p_RATING_CODE        VARCHAR2,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN  NUMBER,
		p_Owner			 VARCHAR2);
End CSC_COLOR_CODES_PKG;

 

/
