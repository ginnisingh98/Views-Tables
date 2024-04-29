--------------------------------------------------------
--  DDL for Package JTF_UM_ROLE_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_ROLE_RESP_PKG" AUTHID CURRENT_USER as
/* $Header: JTFUMRRS.pls 120.3 2005/11/28 08:50:54 vimohan ship $ */

procedure INSERT_USERTYPE_ROLE_ROW (
    x_usertype_id            IN	NUMBER,
    x_principal_name  	     IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_creation_date          IN DATE,
    x_created_by             IN NUMBER,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER);

procedure UPDATE_USERTYPE_ROLE_ROW (
    x_usertype_id            IN	NUMBER,
    x_principal_name  	     IN VARCHAR2,
    x_effective_end_date     IN	DATE,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER);

procedure LOAD_USERTYPE_ROLE_ROW (
    x_usertype_id            IN	NUMBER,
    x_principal_name  	     IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_owner 		     IN VARCHAR2,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
    );

procedure INSERT_USERTYPE_RESP_ROW (
    x_usertype_id            IN	NUMBER,
    x_responsibility_key     IN VARCHAR2,
    x_is_default_flag	     IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_creation_date          IN DATE,
    x_created_by             IN NUMBER,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER,
    x_application_id         IN NUMBER);

procedure UPDATE_USERTYPE_RESP_ROW (
    x_usertype_id            IN	NUMBER,
    x_responsibility_key     IN VARCHAR2,
    x_is_default_flag	     IN VARCHAR2,
    x_effective_end_date     IN	DATE,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER,
    x_application_id         IN NUMBER);

procedure LOAD_USERTYPE_RESP_ROW (
    x_usertype_id            IN	NUMBER,
    x_responsibility_key     IN VARCHAR2,
    x_is_default_flag	     IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_owner 		     IN VARCHAR2,
    x_application_id         IN NUMBER,
    x_last_update_date       in varchar2 default NULL,
    x_custom_mode            in varchar2 default NULL
    );

procedure INSERT_SUBSCRIPTION_ROLE_ROW (
    x_subscription_id        IN	NUMBER,
    x_principal_name  	     IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_creation_date          IN DATE,
    x_created_by             IN NUMBER,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER);

procedure UPDATE_SUBSCRIPTION_ROLE_ROW (
    x_subscription_id        IN	NUMBER,
    x_principal_name  	     IN VARCHAR2,
    x_effective_end_date     IN	DATE,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER);

procedure LOAD_SUBSCRIPTION_ROLE_ROW (
    x_subscription_id       IN	NUMBER,
    x_principal_name         IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_owner 		     IN VARCHAR2,
    x_last_update_date       in varchar2 default NULL,
    x_custom_mode            in varchar2 default NULL
    );

procedure INSERT_SUBSCRIPTION_RESP_ROW (
    x_subscription_id        IN	NUMBER,
    x_responsibility_key     IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_creation_date          IN DATE,
    x_created_by             IN NUMBER,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER,
    x_application_id         IN NUMBER);

procedure UPDATE_SUBSCRIPTION_RESP_ROW (
    x_subscription_id        IN	NUMBER,
    x_responsibility_key     IN VARCHAR2,
    x_effective_end_date     IN	DATE,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER,
    x_application_id         IN NUMBER);

procedure LOAD_SUBSCRIPTION_RESP_ROW (
    x_subscription_id        IN	NUMBER,
    x_responsibility_key     IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_owner 		     IN VARCHAR2,
    x_application_id         IN NUMBER,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
    );

end JTF_UM_ROLE_RESP_PKG;

 

/
