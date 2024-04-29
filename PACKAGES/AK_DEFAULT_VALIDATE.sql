--------------------------------------------------------
--  DDL for Package AK_DEFAULT_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_DEFAULT_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: akdefvls.pls 120.2 2005/09/29 13:59:40 tshort ship $ */
  PROCEDURE create_packages(
    P_package_type IN VARCHAR2,
    P_database_object_name IN VARCHAR2,
    P_region_application_id IN NUMBER,
    P_region_code IN VARCHAR2);
  PROCEDURE create_record_package(
    P_package_type IN VARCHAR2,
    P_database_object_name IN VARCHAR2,
    P_region_application_id IN NUMBER,
    P_region_code IN VARCHAR2);
  PROCEDURE api_shell (
    p_source_type           IN VARCHAR2,
    p_cur_attribute_appl_id IN NUMBER,
    p_cur_attribute_code    IN VARCHAR2,
    p_object_validation_api IN VARCHAR2,
    p_object_defaulting_api IN VARCHAR2,
    p_object_name           IN VARCHAR2,
    p_region_validation_api IN VARCHAR2,
    p_region_defaulting_api IN VARCHAR2,
    p_region_appl_id        IN NUMBER,
    p_region_code           IN VARCHAR2,
    p_structure             IN OUT NOCOPY VARCHAR2,
    p_data                  IN OUT NOCOPY VARCHAR2,
    p_attr_num              IN NUMBER,
    p_status                OUT NOCOPY VARCHAR2,
    p_message               OUT NOCOPY VARCHAR2);
  FUNCTION trunc_name (
    p_name                  IN VARCHAR2,
    p_id                    IN NUMBER,
    p_include_number        IN VARCHAR2)
    RETURN VARCHAR2;
END ak_default_validate;

 

/
