--------------------------------------------------------
--  DDL for Package INV_SQL_BINDING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SQL_BINDING_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVSQBS.pls 120.1 2005/06/11 07:36:57 appldev  $ */
--
-- File        : INVVSQBS.pls
-- Content     : INV_SQL_BINDING_PVT package spec
-- Description : Procedures and functions used for sql binding.
--               This package gives you a way to manage your bind
--               variables by registering them with the package
--               and get a indentifier which you can use in
--               your dynamic sql, and call the procedure bindvars
--               to bind all variables to the cursor passed in.
--
-- Notes       :
-- Modified    : 10/22/1999 bitang created
--
--
-- API name    : InitBindTables
-- Type        : Private
-- Function    : Initializes internal tables of bind variable names and their
--               values. Needed for dynamic SQL.
-- Pre-reqs    : none
-- Parameters  : none
-- Version     : not tracked
-- Notes       :
PROCEDURE InitBindTables;
--
-- API name    : SaveBindPointers
-- Type        : Private
-- Function    : Saves pointers to current bind variable tables rows.
--               Needed to distinguish between 'static' and 'dynamic'
--               entry sections according to implemented algorithm??
-- Pre-reqs    : none
-- Parameters  : none
-- Version     : not tracked
-- Notes       :
--
PROCEDURE SaveBindPointers;
--
-- API name    : RestoreBindPointers
-- Type        : Private
-- Function    : Restores pointers to specific bind variable tables rows.
--               Needed to reuse 'static' and overwrite 'dynamic'
--               entry sections according to implemented algorithm.
-- Pre-reqs    : none
-- Parameters  : none
-- Version     : not tracked
-- Notes       :
--
PROCEDURE RestoreBindPointers;
--
-- API name    : InitBindVar
-- Type        : Private
-- Function    : Adds an entry to the corresponding bind variable table
--               and stores created name as well as value, returns name.
-- Pre-reqs    : none
-- Parameters  :
--  p_value                in  number   required
--                  OR
--  p_value                in  varchar2 required
--                  OR
--  p_value                in  date     required
--  return value           OUT NOCOPY /* file.sql.39 change */ varchar2(10)
-- Version     : not tracked
-- Notes       : Overlayed functions for each supported data type
--
FUNCTION InitBindVar ( p_value IN NUMBER ) RETURN VARCHAR2;
--
FUNCTION InitBindVar ( p_value IN VARCHAR2 ) RETURN VARCHAR2;
--
FUNCTION InitBindVar ( p_value IN DATE ) RETURN VARCHAR2;
--
-- API name    : BindVars
-- Type        : Private
-- Function    : Binds all variables stored in the internal bind variable
--               tables to the given dynamic SQL cursor.
-- Pre-reqs    : refer to dbms_sql package spec
-- Parameters  :
--  p_cursor               in  integer  required
-- Version     : not tracked
-- Notes       :
PROCEDURE BindVars ( p_cursor IN INTEGER );
--
-- API name    : GetConversionString
-- Type        : Private
-- Function    : Returns SQL conversion function syntax corresponding to the
--               given data types to convert.
-- Pre-reqs    : none
-- Parameters  :
--  p_data_type_code        in  number   required
--  p_parent_data_type_code in  number   required
--  x_left_part_conv_fct    OUT NOCOPY /* file.sql.39 change */ varchar2(20)
--  x_right_part_conv_fct   OUT NOCOPY /* file.sql.39 change */ varchar2(20)
-- Version     : not tracked
-- Notes       : needed to be verified
PROCEDURE GetConversionString
  ( p_data_type_code               IN   NUMBER
   ,p_parent_data_type_code        IN   NUMBER
   ,x_left_part_conv_fct           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
   ,x_right_part_conv_fct          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
   );
--
-- API name    : ShowSQL
-- Type        : Private
-- Function    : Shows the text of the dynamically built SQL statement using
--               dbms_output. Needed for debugging.
-- Pre-reqs    : none
-- Parameters  :
--  p_sql_text             in  long     required
-- Version     : not tracked
-- Notes       :
PROCEDURE ShowSql( p_sql_text IN long) ;
--
-- API name    : ShowBindVars
-- Type        : Private
-- Function    : Shows all entries of the internal bind variable tables using
--               dbms_output. Needed for debugging.
-- Pre-reqs    : none
-- Parameters  : none
-- Version     : not tracked
-- Notes       :
PROCEDURE ShowBindVars;
END inv_sql_binding_pvt;

 

/
