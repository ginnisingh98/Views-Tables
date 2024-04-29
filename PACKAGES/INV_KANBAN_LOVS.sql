--------------------------------------------------------
--  DDL for Package INV_KANBAN_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_KANBAN_LOVS" AUTHID CURRENT_USER AS
/* $Header: INVKBLVS.pls 120.2 2005/09/01 02:36:46 rsagar noship $ */

TYPE t_genref IS REF CURSOR;

--      Name: GET_KANBAN_NUMBER
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_kanban_number which restricts LOV SQL to the user input text
--                                e.g.  10%
--
--      Output parameters:
--       x_Revs      returns LOV rows as reference cursor
--
--      Functions: This procedure returns LOV rows for a given org,and
--                 user input text
--

PROCEDURE GET_KANBAN_NUMBER(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_Organization_Id IN NUMBER,
                           p_Kanban_number IN VARCHAR2);

PROCEDURE GET_KANBAN_NUMBER_FOR_INQ(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_Organization_Id IN NUMBER,
                           p_Kanban_number IN VARCHAR2);

PROCEDURE GET_KANBAN_TYPE(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref);

PROCEDURE GET_SUPPLIER(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_supplier_name IN VARCHAR2);

PROCEDURE GET_SUPPLIER_SITE(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref,
                                p_Organization_Id IN NUMBER,
                                p_supplier_id IN NUMBER);

PROCEDURE GET_WIP_LINE(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_Organization_Id IN NUMBER,
                           p_line_code IN VARCHAR2);

END inv_KANBAN_LOVS;

 

/
