--------------------------------------------------------
--  DDL for Package ZPB_AW_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_AW_LOADER_PVT" AUTHID CURRENT_USER as
/* $Header: zpbawloader.pls 120.0.12010.2 2005/12/23 06:16:11 appldev noship $ */

type DIM_VALUES is table of VARCHAR2(32) index by BINARY_INTEGER;
type PROP_VALUES is table of VARCHAR2(32) index by VARCHAR2(32);

-------------------------------------------------------------------------------
-- ATTACH_AW: Attaches the AW rw
--
-- IN: p_app_name (varchar2) - The application short name
--     p_aw       (varchar2) - Name of the AW
-------------------------------------------------------------------------------
procedure ATTACH_AW(p_app_name in varchar2,
                    p_aw       in varchar2);

-------------------------------------------------------------------------------
-- CREATE_OBJECT - Creates the object of specified name, type and attribute
--
-- IN: p_object_name       (varchar2) - Name of the object to create
--     p_object_type       (varchar2) - Type of the object (ie. VARIABLE)
--     p_object_attributes (varchar2) - Attributes of object (ie. <DIM1, DIM2>)
--     p_object_ld         (varchar2) - The LD (description) of the object
--
-------------------------------------------------------------------------------
procedure CREATE_OBJECT(p_object_name       in varchar2,
                        p_object_type       in varchar2,
                        p_object_attributes in varchar2,
                        p_object_ld         in varchar2);

-------------------------------------------------------------------------------
-- DELETE_OBJECT - Deletes the object of specified name
--
-- IN: p_object_name       (varchar2) - Name of the object to delete
--
-------------------------------------------------------------------------------
procedure DELETE_OBJECT(p_object_name   in varchar2);

-------------------------------------------------------------------------------
-- LOAD_DIMENSION_INT
--
-- IN: p_dimension_size (number) - The size of the integer dimension
-------------------------------------------------------------------------------
procedure LOAD_DIMENSION_INT(p_dimension_size in number);

-------------------------------------------------------------------------------
-- LOAD_DIMENSION_VALUES - Loads values of a text dimension
--
-- IN: p_dimension_values - Hash of index/value pairs
--
-------------------------------------------------------------------------------
procedure LOAD_DIMENSION_VALUES(p_dimension_values in DIM_VALUES);

-------------------------------------------------------------------------------
-- LOAD_FORMULA - Builds a formula
--
-- IN: p_formula - The formula body
--
-------------------------------------------------------------------------------
procedure LOAD_FORMULA(p_formula in varchar2);

-------------------------------------------------------------------------------
-- LOAD_MODEL - Builds a model
--
-- IN: p_model - The model body
--
-------------------------------------------------------------------------------
procedure LOAD_MODEL(p_model in varchar2);

-------------------------------------------------------------------------------
-- LOAD_PROGRAM - Builds a program
--
-- IN: p_program - The program body
--
-------------------------------------------------------------------------------
procedure LOAD_PROGRAM(p_program in CLOB);

-------------------------------------------------------------------------------
-- LOAD_PROPERTIES - Loads the properties of an object
--
-- IN: p_properties - Hash of property index/value pairs
--
-------------------------------------------------------------------------------
procedure LOAD_PROPERTIES(p_properties in PROP_VALUES);

-------------------------------------------------------------------------------
-- LOAD_VALUESET - Loads the values of a valueset object
--
-- IN: p_dim_values - Hash of dimension values
--
-------------------------------------------------------------------------------
procedure LOAD_VALUESET(p_dimension_values in DIM_VALUES);

-------------------------------------------------------------------------------
-- UPDATE_AW - Updates the AW
--
-------------------------------------------------------------------------------
procedure UPDATE_AW;

end ZPB_AW_LOADER_PVT;

 

/
