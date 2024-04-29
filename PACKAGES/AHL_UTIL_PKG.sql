--------------------------------------------------------
--  DDL for Package AHL_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLUTILS.pls 120.0.12010000.3 2009/06/12 09:37:32 jkjain ship $ */

------------------------------
-- Define Error Record Type --
------------------------------
TYPE Err_Rec_Type IS RECORD (
    msg_index      NUMBER,
    msg_data       VARCHAR2(2000)
);

------------------------------
-- Define Error Table Type --
------------------------------
TYPE Err_Tbl_Type IS TABLE OF Err_Rec_Type INDEX BY BINARY_INTEGER;

----------------------------------------------------------
-- Procedure to convert Error messages into a pl/sql table
----------------------------------------------------------
Procedure ERR_MESG_TO_TABLE (
    x_err_table  OUT NOCOPY  Err_Tbl_Type );


FUNCTION is_pm_installed RETURN VARCHAR2;


PROCEDURE  Get_Appln_Usage
            (
                x_appln_code OUT NOCOPY VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2
            );

FUNCTION Get_User_Role (
         p_function_key   IN    VARCHAR2 := NULL
         ) RETURN VARCHAR2;

FUNCTION Get_Wip_Eam_Class_Type RETURN NUMBER;

END AHL_UTIL_PKG;

/
