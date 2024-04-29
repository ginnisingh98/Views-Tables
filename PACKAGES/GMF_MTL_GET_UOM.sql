--------------------------------------------------------
--  DDL for Package GMF_MTL_GET_UOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_MTL_GET_UOM" AUTHID CURRENT_USER AS
/* $Header: gmfgtums.pls 115.1 2002/10/29 22:07:11 jdiiorio ship $ */
  PROCEDURE MTL_GET_UOM (
        uomcode in out nocopy varchar2,
        uomname in out nocopy varchar2,
        descr out nocopy varchar2,
        error_status out nocopy number);
END GMF_MTL_GET_UOM;

 

/
