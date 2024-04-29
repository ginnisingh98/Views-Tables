--------------------------------------------------------
--  DDL for Package QP_UPDATE_MOBILE_DOWNLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_UPDATE_MOBILE_DOWNLOAD" AUTHID CURRENT_USER AS
/* $Header: QPXMOBDS.pls 120.1 2005/06/10 02:35:58 appldev  $ */

  PROCEDURE update_mobile_download
  (err_buff                out NOCOPY /* file.sql.39 change */ VARCHAR2,
   retcode                 out NOCOPY /* file.sql.39 change */ NUMBER,
   x_list_header_id        in  NUMBER,
   x_update_value          in  VARCHAR2);

END QP_Update_Mobile_Download;

 

/
