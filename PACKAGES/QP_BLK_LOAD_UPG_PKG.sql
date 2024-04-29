--------------------------------------------------------
--  DDL for Package QP_BLK_LOAD_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_BLK_LOAD_UPG_PKG" AUTHID CURRENT_USER AS
/* $Header: QPXBLKUS.pls 120.5.12000000.1 2007/01/17 22:19:36 appldev ship $ */

   PROCEDURE Blk_Load_Upg_Hdr_MGR(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Num_Workers in number);

   PROCEDURE Blk_Load_Upg_Hdr_WKR(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Worker_Id   in number,
                  X_Num_Workers in number);
END QP_BLK_LOAD_UPG_PKG;

/
