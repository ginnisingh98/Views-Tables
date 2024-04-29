--------------------------------------------------------
--  DDL for Package IEO_SVR_TYPES_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_SVR_TYPES_SEED_PKG" AUTHID CURRENT_USER AS
/* $Header: IEOSEEDS.pls 115.7 2003/01/02 17:07:34 dolee ship $ */

TYPE uwq_svr_types_rec_type IS RECORD (
          type_id NUMBER(15),
          type_uuid VARCHAR2(40),
          rt_refresh_rate NUMBER(5),
          max_major_load_factor NUMBER(15),
          max_minor_load_factor NUMBER(15),
          type_name VARCHAR2(1996),
          type_description VARCHAR2(1996),
          type_extra VARCHAR2(1996),
          created_by NUMBER(15),
          creation_date DATE,
          last_updated_by NUMBER(15),
          last_update_date DATE,
          last_update_login NUMBER(15),
          owner VARCHAR2(1996),
          application_short_name VARCHAR2(40));

PROCEDURE Insert_Row (p_svr_types_rec IN uwq_svr_types_rec_type);
PROCEDURE Update_Row (p_svr_types_rec IN uwq_svr_types_rec_type);

PROCEDURE Load_Row (
          p_type_id IN NUMBER,
          p_type_uuid IN VARCHAR2,
          p_rt_refresh_rate  IN NUMBER,
          p_max_major_load_factor IN NUMBER,
          p_max_minor_load_factor IN NUMBER,
          p_type_name IN VARCHAR2,
          p_type_description IN VARCHAR2,
          p_type_extra IN VARCHAR2,
          p_owner IN VARCHAR2,
          p_application_short_name IN VARCHAR2);

  PROCEDURE translate_row (
    p_type_id IN NUMBER,
    p_type_name IN VARCHAR2,
    p_type_description IN VARCHAR2,
    p_type_extra IN VARCHAR2,
    p_owner IN VARCHAR2);

PROCEDURE ADD_LANGUAGE;

END IEO_SVR_TYPES_SEED_PKG;

 

/
