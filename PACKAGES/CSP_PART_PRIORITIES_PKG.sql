--------------------------------------------------------
--  DDL for Package CSP_PART_PRIORITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PART_PRIORITIES_PKG" AUTHID CURRENT_USER as
/* $Header: csptpaps.pls 115.0 2003/06/10 19:48:13 ajosephg noship $ */
-- Start of Comments
-- Package name     : CSP_PART_PRIORITIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_PART_PRIORITY_ID   IN OUT NOCOPY NUMBER,
          p_PRIORITY       VARCHAR2,
          p_LOWER_RANGE    NUMBER,
          p_UPPER_RANGE    NUMBER,
          p_CREATED_BY     NUMBER,
          p_CREATION_DATE  DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER);

PROCEDURE Update_Row(
          p_PART_PRIORITY_ID  NUMBER,
          p_PRIORITY       VARCHAR2,
          p_LOWER_RANGE    NUMBER,
          p_UPPER_RANGE    NUMBER,
          p_CREATED_BY     NUMBER,
          p_CREATION_DATE  DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER);

PROCEDURE Lock_Row(
          p_PART_PRIORITY_ID  NUMBER,
          p_PRIORITY       VARCHAR2,
          p_LOWER_RANGE    NUMBER,
          p_UPPER_RANGE    NUMBER,
          p_CREATED_BY     NUMBER,
          p_CREATION_DATE  DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER);

PROCEDURE Delete_Row(
          p_PART_PRIORITY_ID  NUMBER);
End CSP_PART_PRIORITIES_PKG;

 

/
