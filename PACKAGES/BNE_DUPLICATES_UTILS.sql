--------------------------------------------------------
--  DDL for Package BNE_DUPLICATES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_DUPLICATES_UTILS" AUTHID CURRENT_USER AS
/* $Header: bneduputilss.pls 120.2 2005/06/29 03:39:55 dvayro noship $ */

PROCEDURE ENABLE_DUPLICATE_DETECT
                  (p_application_id   IN NUMBER,
                   p_interface_code   IN VARCHAR2,
                   p_user_id          IN NUMBER,
                   p_key_class        IN VARCHAR2 default 'oracle.apps.bne.integrator.upload.BneTableInterfaceKey'
                  );

PROCEDURE ADD_COLUMN_TO_DUPLICATE_KEY
                  (p_application_id          IN NUMBER,
                   p_interface_code          IN VARCHAR2,
                   p_interface_col_name      IN VARCHAR2,
                   p_user_id                 IN NUMBER
                  );

PROCEDURE CREATE_DUPLICATE_PROFILE
                  (p_integrator_app_id          IN NUMBER,
                   p_integrator_code            IN VARCHAR2,
                   p_dup_profile_app_id         IN NUMBER,
                   p_dup_profile_code           IN VARCHAR2,
                   p_user_name                  IN VARCHAR2,
                   p_dup_handling_code          IN VARCHAR2,
                   p_default_resolver_classname IN VARCHAR2,
                   p_user_id                    IN NUMBER
                  );

PROCEDURE SET_DUPLICATE_RESOLVER
           (p_interface_app_id      IN NUMBER,
            p_interface_code        IN VARCHAR2,
            p_interface_col_name    IN VARCHAR2,
            p_dup_profile_app_id    IN NUMBER,
            p_dup_profile_code      IN VARCHAR2,
            p_resolver_classname    IN VARCHAR2,
            p_user_id               IN NUMBER
           );

PROCEDURE DELETE_DUPLICATE_PROFILE
           (p_dup_profile_app_id    IN NUMBER,
            p_dup_profile_code      IN VARCHAR2
           );

PROCEDURE REMOVE_DUPLICATE_DETECT
           (p_interface_app_id      IN NUMBER,
            p_interface_code        IN VARCHAR2
           );

END BNE_DUPLICATES_UTILS;

 

/
