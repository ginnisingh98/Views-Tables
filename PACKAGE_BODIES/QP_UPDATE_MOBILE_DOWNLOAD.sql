--------------------------------------------------------
--  DDL for Package Body QP_UPDATE_MOBILE_DOWNLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_UPDATE_MOBILE_DOWNLOAD" AS
/* $Header: QPXMOBDB.pls 120.1 2005/06/10 02:35:31 appldev  $ */

  PROCEDURE update_mobile_download
   (err_buff                 out NOCOPY /* file.sql.39 change */ VARCHAR2,
    retcode                  out NOCOPY /* file.sql.39 change */ NUMBER,
    x_list_header_id         in  NUMBER,
    x_update_value           in  VARCHAR2) IS

  BEGIN

  IF upper(x_update_value) = 'Y' THEN
     UPDATE QP_LIST_HEADERS_B
     SET MOBILE_DOWNLOAD = 'Y'
     WHERE LIST_HEADER_ID = x_list_header_id;

  ELSIF upper(x_update_value) = 'N' THEN
     UPDATE QP_LIST_HEADERS_B
     SET MOBILE_DOWNLOAD = 'N'
     WHERE LIST_HEADER_ID = x_list_header_id;
  END IF;

  COMMIT;
  fnd_file.put_line(FND_FILE.LOG,'Mobile Download Flag Updated Successfully');
  retcode := 0;


  EXCEPTION
     WHEN OTHERS THEN
          retcode := 2;
          fnd_file.put_line(FND_FILE.LOG,substr(sqlerrm,1,300));
          fnd_file.put_line(FND_FILE.LOG,sqlcode);
          RAISE;

  END update_mobile_download;

END QP_Update_Mobile_Download;

/
