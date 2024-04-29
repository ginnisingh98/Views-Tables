--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: INVMVTDRTS.pls 120.0.12010000.5 2018/03/27 16:10:45 abhissri noship $ */

    PROCEDURE gbl_tca_drc(person_id     IN NUMBER,
                          result_tbl    OUT NOCOPY PER_DRT_PKG.result_tbl_type);

END INV_MGD_MVT_DRT_PKG;

/
