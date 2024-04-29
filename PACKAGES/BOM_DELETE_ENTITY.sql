--------------------------------------------------------
--  DDL for Package BOM_DELETE_ENTITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DELETE_ENTITY" AUTHID CURRENT_USER AS
/* $Header: BOMDELMS.pls 120.1 2005/06/21 04:00:54 appldev ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDELMS.pls
--
--  DESCRIPTION
--
--      Spec of package BOMDELMS
--
--  NOTES
--
--  HISTORY
--  15-Sep-2000 Janaki B    Initial Creation
--
****************************************************************************/

FUNCTION Get_delorg_type(group_id in NUMBER)
RETURN NUMBER;

FUNCTION Get_delete_type(group_id in NUMBER)
RETURN NUMBER;

FUNCTION Get_delorg_hrchy(group_id in NUMBER)
RETURN VARCHAR2;

FUNCTION Get_common_flag(group_id in NUMBER)
RETURN NUMBER;

FUNCTION Get_delorg_id(group_id in NUMBER)
RETURN NUMBER;

FUNCTION Get_delorg_name(org_id IN NUMBER)
RETURN varchar2;

PROCEDURE get_delorg_list(org_type         in      number,
                          org_hrchy        in      varchar2,
                          current_org_id   in      number,
                          current_org_name in      varchar2,
                          org_list         in out nocopy /* file.sql.39 change */     inv_orghierarchy_pvt.orgid_tbl_type);

FUNCTION Get_bill_seq(assembly_id    in NUMBER,
                      org_id         in NUMBER,
                      alternate_bom  in VARCHAR2)
RETURN NUMBER;

FUNCTION Get_rtg_seq(assembly_id    in NUMBER,
                     org_id         in NUMBER,
                     alternate_desg in VARCHAR2
                     )
RETURN NUMBER;

FUNCTION Get_comp_seq(bill_seq     in NUMBER,
                      component_id in NUMBER,
                     oper_seq_num   in NUMBER,
                     effective_date in DATE)
RETURN NUMBER;

FUNCTION Get_oper_seq(rtg_seq       in NUMBER,
                     oper_seq_num   in NUMBER,
                     effective_date in DATE,
                     dept_code      in VARCHAR2,
                     org_id         in NUMBER)
RETURN NUMBER;

FUNCTION Get_dept_code(
                      dept_code       in VARCHAR2,
                      org_id          in NUMBER)
RETURN VARCHAR2;


FUNCTION Get_item_descr(assembly_id    in NUMBER,
                        org_id         in NUMBER)
RETURN VARCHAR2;

FUNCTION Get_concat_segs(assembly_id    in NUMBER,
                         org_id         in NUMBER)
RETURN VARCHAR2;

FUNCTION get_item_id(assembly_id    in NUMBER,
                     current_org    in NUMBER)
RETURN NUMBER;

PROCEDURE process_delete_entities(delete_type     in    NUMBER,
                                  group_id        in    NUMBER,
                                  original_org    in    NUMBER,
                                  org_list        in    inv_orghierarchy_pvt.orgid_tbl_type);

PROCEDURE modify_original_bills( group_id          in   NUMBER,
                                 common_flag       in   NUMBER);

PROCEDURE process_original_sub_entities(
                             delete_type     in    NUMBER,
                             group_id        in    NUMBER,
                             original_org    in    NUMBER,
                             common_flag     in    NUMBER,
                             org_list        in    inv_orghierarchy_pvt.orgid_tbl_type);

PROCEDURE insert_common_bills(group_id      IN NUMBER,
                              delete_type   IN NUMBER);

PROCEDURE insert_original_bills(group_id      IN NUMBER,
                                delete_type   IN NUMBER);


END bom_delete_entity;

 

/
