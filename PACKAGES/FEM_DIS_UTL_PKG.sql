--------------------------------------------------------
--  DDL for Package FEM_DIS_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIS_UTL_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_dis_utl.pls 120.1 2005/10/27 05:29:54 appldev noship $ */

  FUNCTION Visual_Trace_URL(
    p_function_name IN VARCHAR2,
    p_other_params  IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  PROCEDURE get_exchange_rate(
    p_from_cur IN VARCHAR2,
    p_to_cur IN VARCHAR2,
    p_cal_period IN NUMBER,
    p_from_val IN NUMBER,
    x_to_val OUT NOCOPY NUMBER,
    x_dtor OUT NOCOPY NUMBER,
    x_ntor OUT NOCOPY NUMBER
  );

  FUNCTION get_converted_amount(
    p_from_currency IN VARCHAR2,
    p_to_currency   IN VARCHAR2,
    p_cal_period_id IN NUMBER,
    p_from_value    IN NUMBER
  ) RETURN NUMBER;

  FUNCTION Get_Dim_Attribute_Value(
   p_dimension_varchar_label     IN VARCHAR2,
   p_attribute_varchar_label     IN VARCHAR2,
   p_member_id                   IN NUMBER,
   p_value_set_id                IN NUMBER     DEFAULT NULL,
   p_attr_version_display_code   IN VARCHAR2   DEFAULT NULL,
   p_return_attr_assign_mbr_id   IN VARCHAR2   DEFAULT NULL
  ) RETURN VARCHAR2;

  FUNCTION Get_Relative_cal_period_name(p_base_cal_period_id NUMBER,
                                        p_offset NUMBER)
  RETURN VARCHAR2;

END FEM_DIS_UTL_PKG;


 

/
