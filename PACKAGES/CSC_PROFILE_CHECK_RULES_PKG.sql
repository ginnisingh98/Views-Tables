--------------------------------------------------------
--  DDL for Package CSC_PROFILE_CHECK_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROFILE_CHECK_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: csctpcrs.pls 115.15 2002/12/03 17:56:06 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_PROFILE_CHECK_RULES_PKG
-- Purpose          :
-- History          :26 Nov 02 jamose made changes for the NOCOPY and FND_API.G_MISS*
-- 08-NOV-00  madhavan Added procedures translate_row and load_row. Fix to
--                     bug # 1491205
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          p_CHECK_ID   IN NUMBER,
          p_SEQUENCE    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LOGICAL_OPERATOR    VARCHAR2,
          p_LEFT_PAREN    VARCHAR2,
          p_BLOCK_ID    NUMBER,
          p_COMPARISON_OPERATOR    VARCHAR2,
          p_EXPRESSION    VARCHAR2,
          p_EXPR_TO_BLOCK_ID    NUMBER,
          p_RIGHT_PAREN    VARCHAR2,
          p_SEEDED_FLAG    VARCHAR2,
          X_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER);

PROCEDURE Update_Row(
          p_CHECK_ID    NUMBER,
          p_SEQUENCE    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LOGICAL_OPERATOR    VARCHAR2,
          p_LEFT_PAREN    VARCHAR2,
          p_BLOCK_ID    NUMBER,
          p_COMPARISON_OPERATOR    VARCHAR2,
          p_EXPRESSION    VARCHAR2,
          p_EXPR_TO_BLOCK_ID    NUMBER,
          p_RIGHT_PAREN    VARCHAR2,
          p_SEEDED_FLAG    VARCHAR2,
          px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER );

procedure LOCK_ROW (
  P_CHECK_ID in NUMBER,
  P_SEQUENCE IN NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER );

procedure DELETE_ROW (
  P_CHECK_ID    NUMBER,
  P_SEQUENCE    NUMBER,
  P_OBJECT_VERSION_NUMBER NUMBER  );

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  p_check_id      IN    NUMBER,
  p_sequence      IN    NUMBER,
  p_expression    IN    VARCHAR2,
  p_owner         IN    VARCHAR2);

PROCEDURE LOAD_ROW (
            p_CHECK_ID                IN NUMBER,
            p_SEQUENCE                IN NUMBER,
            p_LAST_UPDATED_BY         IN NUMBER,
            p_LAST_UPDATE_DATE        IN DATE,
            p_LAST_UPDATE_LOGIN       IN NUMBER,
            p_LOGICAL_OPERATOR        IN VARCHAR2,
            p_LEFT_PAREN              IN VARCHAR2,
            p_BLOCK_ID                IN NUMBER,
            p_COMPARISON_OPERATOR     IN VARCHAR2,
            p_EXPRESSION              IN VARCHAR2,
            p_EXPR_TO_BLOCK_ID        IN NUMBER,
            p_RIGHT_PAREN             IN VARCHAR2,
            p_SEEDED_FLAG             IN VARCHAR2,
            px_OBJECT_VERSION_NUMBER  IN OUT NOCOPY NUMBER,
            p_OWNER                   IN VARCHAR2);

End CSC_PROFILE_CHECK_RULES_PKG;

 

/
