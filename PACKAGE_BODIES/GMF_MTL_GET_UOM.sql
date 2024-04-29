--------------------------------------------------------
--  DDL for Package Body GMF_MTL_GET_UOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_MTL_GET_UOM" AS
/* $Header: gmfgtumb.pls 115.2 2002/10/29 22:07:28 jdiiorio ship $ */
/** MC BUG# 1554483 **/
/* don't select unit_of_measure in select since because of uom changes
uomname is now um_code and selecting in the select would change um_code
to unit_of_measure which is wrong**/
/** add sy_uoms_mst in the from clause **/
  PROCEDURE MTL_GET_UOM (
        uomcode in out nocopy varchar2,
        uomname in out nocopy varchar2,
        descr out nocopy varchar2,
        error_status out nocopy number) AS
  BEGIN
        select  --unit_of_measure,
                b.uom_code,
                b.description
        into
                --uomname,
                uomcode,
                descr
        from sy_uoms_mst a, mtl_units_of_measure b
        where a.um_code = uomname
        and   a.unit_of_measure = b.unit_of_measure;
  EXCEPTION
    when no_data_found then
    /* This tells calling routing that no more data */
         error_status := 100;
     when others then
         error_status := SQLCODE;
  END MTL_GET_UOM;
END GMF_MTL_GET_UOM;

/
