--------------------------------------------------------
--  DDL for Package Body HR_DU_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DU_MASTER" AS
/* $Header: perdumas.pkb 115.13 2002/11/28 16:01:15 apholt noship $ */


/*-------------------------- PRIVATE ROUTINES ----------------------------*/


-- -------------------------- create_upload -------------------------------
-- Description: Create the entry in hr_du_uploads for the migration
--
--
--
--  Input Parameters
--        r_upload_data        - upload record
--
--
--  Output Parameters
--        r_upload_data        - upload record
--
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE create_upload(r_upload_data IN OUT NOCOPY r_upload_rec) IS
--

CURSOR csr_module IS
  SELECT module_id
    FROM hr_du_modules
    WHERE module_name = 'Spreadsheet-to-lines';

CURSOR csr_upload IS
  SELECT hr_du_uploads_s.currval
    FROM dual;

l_module_id NUMBER;

--
BEGIN
--

hr_du_utility.message('ROUT','entry:hr_du_master.create_upload', 5);
hr_du_utility.message('PARA','(r_upload_data - record)', 10);

-- get the module id for the spreedsheet input module
OPEN csr_module;
FETCH csr_module INTO l_module_id;
CLOSE csr_module;

hr_du_utility.message('INFO','performing insert', 15);

INSERT INTO hr_du_uploads (
  UPLOAD_ID,
  MODULE_ID,
  BATCH_ID,
  SOURCE,
  STATUS,
  DATA_INPUT_STATUS,
  DATA_REFERENCE_COMPLETE,
  BUSINESS_GROUP_NAME,
  DO_REQUEST_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  CREATED_BY,
  CREATION_DATE
  )
  SELECT
  hr_du_uploads_s.nextval,
  l_module_id,
  null,
  r_upload_data.filename,
  'NS',
  'NS',
  null,
  null,
  FND_GLOBAL.CONC_REQUEST_ID,
  sysdate,
  1,
  1,
  1,
  sysdate
  FROM sys.dual;

COMMIT;


-- get the upload id
OPEN csr_upload;
FETCH csr_upload INTO r_upload_data.upload_id;
CLOSE csr_upload;


hr_du_utility.message('INFO','created upload', 15);
hr_du_utility.message('SUMM','created upload', 20);
hr_du_utility.message('ROUT','exit:hr_du_master.create_upload', 25);
hr_du_utility.message('PARA','(none)', 30);


-- error handling
EXCEPTION
WHEN OTHERS THEN
-- update status to error
  hr_du_utility.update_uploads(p_new_status => 'E',
                               p_id => r_upload_data.upload_id);
  hr_du_utility.error(SQLCODE,'hr_du_master.create_upload','(none)','R');
  RAISE;

--
END create_upload;
--



/*---------------------------- PUBLIC ROUTINES --------------------------*/

-- ------------------------------- main -----------------------------------
-- Description: This is the main controller code which is called from the
-- UI. It in turn calls the uploader module required.
--
--
--
--  Input Parameters
--        p_filename        - of current upload
--
--
--  Output Parameters
--        errbuf  - buffer for output message (for CM manager)
--
--        retcode - program return code (for CM manager)
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE main(errbuf OUT  NOCOPY VARCHAR2,
               retcode OUT NOCOPY NUMBER,
               p_filename IN VARCHAR2,
	       p_login	VARCHAR2 DEFAULT 'Y') IS
--

e_fatal_error EXCEPTION;
l_process VARCHAR2(1000) := 'initialization';
r_upload_data r_upload_rec;


--
BEGIN
--

IF p_login = 'Y' THEN
  -- initialize messaging
  hr_du_utility.message_init;
END IF;

hr_du_utility.message('ROUT','entry:hr_du_master.main', 5);
hr_du_utility.message('PARA','(p_filename - ' ||
                      p_filename || ')', 10);


-- update record with filename
r_upload_data.filename := p_filename;

-- create the entry in hr_du_uploads
create_upload(r_upload_data);


--From the spread sheet to the HR_DU_UPLOAD_LINES
l_process  := 'spreadsheet input - rollback';
hr_du_utility.message('INFO',l_process, 15);
hr_du_di_insert.rollback(r_upload_data.upload_id);

l_process  := 'spreadsheet input - process';
hr_du_utility.message('INFO',l_process, 15);
hr_du_di_insert.ordered_sequence(r_upload_data.upload_id);



-- For the PC to CP conversion
l_process  := 'PC to CP conversion - rollback';
hr_du_utility.message('INFO',l_process, 15);
hr_du_dp_pc_conversion.ROLLBACK(r_upload_data.upload_id);

l_process  := 'PC to CP conversion - validate';
hr_du_utility.message('INFO',l_process, 15);
hr_du_dp_pc_conversion.VALIDATE(r_upload_data.upload_id);

l_process  := 'PC to CP conversion - process';
hr_du_utility.message('INFO',l_process, 15);
hr_du_dp_pc_conversion.INSERT_API_MODULE_IDS(r_upload_data.upload_id);




-- To Data Pump HR_PUMP_BATCH_LINES
l_process  := 'transfer to datapump tables - rollback';
hr_du_utility.message('INFO',l_process, 15);
hr_du_do_datapump.ROLLBACK(r_upload_data.upload_id);

l_process  := 'transfer to datapump tables - validate';
hr_du_utility.message('INFO',l_process, 15);
hr_du_do_datapump.VALIDATE(r_upload_data.upload_id);

l_process  := 'transfer to datapump tables - process';
hr_du_utility.message('INFO',l_process, 15);
hr_du_do_datapump.MAIN(r_upload_data.upload_id);



-- set up return values to concurrent manager
retcode := 0;
errbuf := 'No errors - examine logfiles for detailed reports.';


hr_du_utility.message('INFO','Main controller', 15);
hr_du_utility.message('SUMM','Main controller', 20);
hr_du_utility.message('ROUT','exit:hr_du_master.main', 25);
hr_du_utility.message('PARA','(retcode - ' || retcode ||
                             ')(errbuf - ' || errbuf || ')', 30);


-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  retcode := 2;
  errbuf := 'An error occurred during the upload - examine logfiles' ||
            ' for detailed reports. Current process is ' ||
            l_process || '.';
  hr_du_utility.error(SQLCODE,'hr_du_master.main',
                      l_process,'R');
  hr_du_utility.update_uploads(p_new_status => 'E',p_id => r_upload_data.upload_id);
WHEN OTHERS THEN
  retcode := 2;
  errbuf := 'An error occurred during the upload - examine logfiles' ||
            ' for detailed reports. Current process is ' ||
            l_process || '.';
  hr_du_utility.error(SQLCODE,'hr_du_master.main','(none)','R');
  hr_du_utility.update_uploads(p_new_status => 'E',p_id => r_upload_data.upload_id);

--
END main;
--



end hr_du_master;

/
