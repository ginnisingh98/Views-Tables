--------------------------------------------------------
--  DDL for Package CZ_MODEL_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_MODEL_USAGES_PKG" AUTHID CURRENT_USER AS
  /* $Header: czmdlugs.pls 120.1 2007/05/29 19:06:40 skudryav ship $ */

PROCEDURE INSERT_ROW(x_ROWID             IN OUT NOCOPY VARCHAR2,
                     p_model_usage_id    IN NUMBER,
                     p_name              IN VARCHAR2,
                     p_description       IN VARCHAR2,
                     p_note              IN VARCHAR2,
                     p_in_use            IN VARCHAR2,
                     p_created_by        IN NUMBER,
                     p_creation_date     IN DATE,
                     p_last_updated_by   IN NUMBER,
                     p_last_update_date  IN DATE,
                     p_last_update_login IN NUMBER);

PROCEDURE UPDATE_ROW(p_model_usage_id   IN NUMBER,
                     p_name              IN VARCHAR2,
                     p_description       IN VARCHAR2,
                     p_note              IN VARCHAR2,
                     p_last_updated_by   IN NUMBER,
                     p_last_update_date  IN DATE,
                     p_last_update_login IN NUMBER);

PROCEDURE DELETE_ROW(p_model_usage_id IN NUMBER);

PROCEDURE ADD_LANGUAGE;

-- PROCEDURE LOCK_ROW(p_model_usage_id IN NUMBER);

PROCEDURE TRANSLATE_ROW(p_model_usage_id   IN NUMBER,
                        p_description      IN VARCHAR2);

PROCEDURE LOAD_ROW
(
 p_model_usage_id    IN NUMBER,
 p_name              IN VARCHAR2,
 p_description       IN VARCHAR2,
 p_note              IN VARCHAR2,
 p_in_use            IN VARCHAR2,
 p_owner             IN VARCHAR2,
 p_last_update_date  IN VARCHAR2);

END CZ_MODEL_USAGES_PKG;

/
