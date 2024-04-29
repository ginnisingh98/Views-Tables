--------------------------------------------------------
--  DDL for Package AD_AW_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_AW_LOADER" AUTHID CURRENT_USER as
/* $Header: adawld9is.pls 120.0 2005/05/25 11:50:15 appldev noship $ */

type DIM_VALUES is table of VARCHAR2(32) index by BINARY_INTEGER;
type PROP_VALUES is table of VARCHAR2(32) index by VARCHAR2(32);

procedure ATTACH_AW(p_schema in varchar2,
                    p_aw     in varchar2);

procedure CREATE_OBJECT(p_object_name       in varchar2,
                        p_object_type       in varchar2,
                        p_object_attributes in varchar2,
                        p_object_ld         in varchar2);

procedure DELETE_OBJECT(p_object_name	in varchar2);

procedure LOAD_DIMENSION_INT(p_dimension_size in number);

procedure LOAD_DIMENSION_VALUES(p_dimension_values in DIM_VALUES);

procedure LOAD_FORMULA(p_formula in varchar2);

procedure LOAD_MODEL(p_model in varchar2);

procedure LOAD_PROGRAM(p_program in CLOB);

procedure LOAD_PROPERTIES(p_properties in PROP_VALUES);

procedure LOAD_VALUESET(p_dimension_values in DIM_VALUES);

procedure UPDATE_AW;

end AD_AW_LOADER;

/
