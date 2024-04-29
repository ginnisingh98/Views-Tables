--------------------------------------------------------
--  DDL for Package PAY_US_TAX_ETU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAX_ETU_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusetug.pkh 120.3.12010000.1 2008/07/27 23:50:59 appldev ship $ */

/*****************************************************************************
 Name      : create_vertex_etu
 Purpose   : Procedure create element type usages for VERTEX.
*****************************************************************************/
PROCEDURE create_vertex_etu(p_effective_date        IN     DATE
                           ,p_element_type_id       IN     NUMBER
                           ,p_business_group_id     IN     NUMBER
                           ,p_costable_type         IN     VARCHAR2
			    );


END pay_us_tax_etu_pkg;

/
