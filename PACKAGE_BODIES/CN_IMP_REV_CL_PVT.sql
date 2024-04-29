--------------------------------------------------------
--  DDL for Package Body CN_IMP_REV_CL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_IMP_REV_CL_PVT" AS
-- $Header: cnvimrcb.pls 120.1 2005/08/07 23:04:02 vensrini noship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'CN_IMP_REV_CL_PVT';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvimrcb.pls';

-- Start of comments
--    API name        : RevCl_Import
--    Type            : Private.
--    Function        : programtransfer data from staging table into
--                      cn_revenue_classes_all
--    Pre-reqs        : None.
--    Parameters      :
--    IN                  p_imp_header_id           IN    NUMBER,
--    OUT              : errbuf         OUT VARCHAR2       Required
--                      retcode        OUTVARCHAR2     Optional
--    Version :         Current version       1.0
--
--
--
--    Notes           : The import process will terminated when error occurs.
--       Cannot partially import data because if error happens and re-run
--       SQL*Loader to stage fixed data,the old one will be deleted first.
--       Because SQL*Loader run in APPEND mode.
-- End of comments

PROCEDURE RevCl_Import
  (errbuf                    OUT NOCOPY   VARCHAR2,
   retcode                   OUT NOCOPY   VARCHAR2,
   p_imp_header_id           IN    NUMBER,
   p_org_id		     IN    NUMBER
   ) IS

      l_status_code cn_imp_lines.status_code%TYPE := 'STAGE';

      CURSOR c_rev_cl_imp_csr IS
	 SELECT
	   imp_line_id,
	   imp_header_id,
	   status_code,
	   error_code,
	   name,
       description

	   FROM CN_REVENUE_CLASSES_IMP_V
	   WHERE imp_header_id = p_imp_header_id
	   AND status_code = l_status_code
	   ;

     Cursor get_rev_cls( p_revenue_class_name cn_revenue_classes.name%TYPE )  IS
      select  count(1)
        from cn_revenue_classes
        where name = p_revenue_class_name and org_id=p_org_id;

      l_api_name     CONSTANT VARCHAR2(30) := 'RevCl_Import';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_rev_cl_imp c_rev_cl_imp_csr%ROWTYPE;
      l_rev_class_name cn_revenue_classes.name%TYPE;

      l_return_status   VARCHAR2(1);
--      l_msg_count   NUMBER;
      l_msg_data    VARCHAR2(2000);
      l_loading_status  VARCHAR2(30);
      l_revenue_class_id    NUMBER;

      l_processed_row NUMBER := 0;
      l_failed_row    NUMBER := 0;
      l_message       VARCHAR2(2000);
      l_error_code    VARCHAR2(30);
      l_revenue_classes_id NUMBER(15);
      l_header_list       VARCHAR2(2000);
      l_sql_stmt          VARCHAR2(2000);
      l_count             NUMBER;
      err_num         NUMBER;
      l_msg_count     NUMBER := 0;
      l_imp_header      cn_imp_headers_pvt.imp_headers_rec_type := cn_imp_headers_pvt.G_MISS_IMP_HEADERS_REC;
      l_rev_class_rec   cn_revenue_class_pvt.revenue_class_rec_type;
      l_process_audit_id cn_process_audits.process_audit_id%TYPE;

BEGIN
   retcode := 0 ;

   -- Get imp_header info
   SELECT name, status_code,server_flag,imp_map_id, source_column_num,
     import_type_code
     INTO l_imp_header.name ,l_imp_header.status_code ,
     l_imp_header.server_flag, l_imp_header.imp_map_id,
     l_imp_header.source_column_num,l_imp_header.import_type_code
     FROM cn_imp_headers
     WHERE imp_header_id = p_imp_header_id;

   -- open process audit batch
   cn_message_pkg.begin_batch
     ( x_process_type	=> l_imp_header.import_type_code,
       x_parent_proc_audit_id  => p_imp_header_id ,
       x_process_audit_id	=>  l_process_audit_id,
       x_request_id		=> null,
       p_org_id			=> p_org_id);

   cn_message_pkg.write
     (p_message_text    => 'REVCL: Start Transfer Data. imp_header_id = ' || To_char(p_imp_header_id),
      p_message_type    => 'MILESTONE');

   -- Get source column name list and target column dynamic sql statement
   CN_IMPORT_PVT.build_error_rec
     (p_imp_header_id => p_imp_header_id,
      x_header_list => l_header_list,
      x_sql_stmt => l_sql_stmt);

   OPEN c_rev_cl_imp_csr;
   LOOP
      FETCH c_rev_cl_imp_csr INTO l_rev_cl_imp;
      EXIT WHEN c_rev_cl_imp_csr%notfound;

      l_processed_row := l_processed_row + 1;

      cn_message_pkg.debug('REVCL:Record ' || To_char(l_processed_row) || ' imp_line_id = ' || To_char(l_rev_cl_imp.imp_line_id));
      -- -------- Checking for all required fields ----------------- --
      -- Check required field

      -- insert into cn_comm_lines_api
      l_rev_class_rec.revenue_class_id      := l_revenue_class_id;
      l_rev_class_rec.name                  := l_rev_cl_imp.name;
      l_rev_class_rec.description           := l_rev_cl_imp.description;
      l_rev_class_rec.liability_account_id  := NULL;
      l_rev_class_rec.expense_account_id    := NULL;
      l_rev_class_rec.object_version_number := NULL;

      CN_REVENUE_CLASS_PVT.Create_Revenue_Class
      ( p_api_version           =>  1.0,
        x_return_status         =>  l_return_status,
        p_init_msg_list         =>  FND_API.G_TRUE,
        x_msg_count             =>  l_msg_count,
        x_msg_data              =>  l_msg_data,
        x_loading_status        =>  l_loading_status,
        x_revenue_class_id      =>  l_revenue_class_id,
        p_revenue_class_rec     =>  l_rev_class_rec,
        p_org_id		=>  p_org_id);

    if (l_return_status = FND_API.G_RET_STS_ERROR) then
    begin

      l_failed_row := l_failed_row + 1;
      CN_IMPORT_PVT.update_imp_lines
	       (p_imp_line_id => l_rev_cl_imp.imp_line_id,
	       p_status_code => 'FAIL',
	       p_error_code  => l_loading_status);
	   CN_IMPORT_PVT.update_imp_headers
	       (p_imp_header_id => p_imp_header_id,
	       p_status_code => 'IMPORT_FAIL',
               p_processed_row => l_processed_row,
	       p_failed_row => l_failed_row);
       cn_message_pkg.write
	       (p_message_text    => l_msg_data,
	       p_message_type    => 'ERROR');
       CN_IMPORT_PVT.write_error_rec
    	   (p_imp_header_id => p_imp_header_id,
	        p_imp_line_id => l_rev_cl_imp.imp_line_id,
	        p_header_list => l_header_list,
	        p_sql_stmt => l_sql_stmt);

	   retcode := 2;
	   errbuf := l_msg_data;
       GOTO end_loop;
     end;

    else

    begin
        l_error_code := '';
        CN_IMPORT_PVT.update_imp_lines
	       (p_imp_line_id => l_rev_cl_imp.imp_line_id,
	        p_status_code => 'COMPLETE',
	        p_error_code  => l_error_code);
            cn_message_pkg.debug('REVCL:Import completed. revenue_classes_id = ' || To_char(l_revenue_class_id));
     end;
    end if;
      << end_loop>>
	NULL;
   END LOOP; -- c_rev_cl_imp_csr
   IF c_rev_cl_imp_csr%ROWCOUNT = 0 THEN
      l_processed_row := 0;
   END IF;
   CLOSE c_rev_cl_imp_csr;
   IF l_failed_row = 0 AND retcode = 0 THEN
      -- update update_imp_headers
      CN_IMPORT_PVT.update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'COMPLETE',
	 p_processed_row => l_processed_row,
	 p_failed_row => l_failed_row);
   END IF;

   cn_message_pkg.write
     (p_message_text    => 'REVCL: End Transfer Data. imp_header_id = ' || To_char(p_imp_header_id),
      p_message_type    => 'MILESTONE');

   -- close process batch
   cn_message_pkg.end_batch(l_process_audit_id);

  -- Commit all imports
   COMMIT;


END RevCL_Import;
END CN_IMP_REV_CL_PVT;

/
