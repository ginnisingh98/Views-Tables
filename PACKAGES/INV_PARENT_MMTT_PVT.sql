--------------------------------------------------------
--  DDL for Package INV_PARENT_MMTT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PARENT_MMTT_PVT" AUTHID CURRENT_USER AS
  /* $Header: INVVPMTS.pls 115.0 2004/05/19 00:56:44 stdavid noship $ */

  g_pkg_spec_ver  CONSTANT VARCHAR2(100) := '$Header: INVVPMTS.pls 115.0 2004/05/19 00:56:44 stdavid noship $';
  g_pkg_name      CONSTANT VARCHAR2(30)  := 'INV_PARENT_MMTT_PVT';


  PROCEDURE process_parent
  ( x_return_status   OUT NOCOPY  VARCHAR2
  , p_parent_temp_id  IN          NUMBER
  );


END inv_parent_mmtt_pvt;

 

/
