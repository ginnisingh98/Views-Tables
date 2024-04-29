--------------------------------------------------------
--  DDL for Package Body MTL_MOVEMENT_STATISTICS4_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_MOVEMENT_STATISTICS4_PKG" as
/* $Header: INVTTM4B.pls 120.1 2005/07/01 13:35:38 appldev ship $ */

PROCEDURE MTL_MVE_COMMIT(movement_id number) is

BEGIN
    if (movement_id is not NULL) then
          commit;
    end if;

END MTL_MVE_COMMIT;

END MTL_MOVEMENT_STATISTICS4_PKG;

/
