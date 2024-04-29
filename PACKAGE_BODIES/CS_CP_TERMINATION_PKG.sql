--------------------------------------------------------
--  DDL for Package Body CS_CP_TERMINATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CP_TERMINATION_PKG" AS
/* $Header: csxcpstb.pls 115.0 2000/02/01 16:34:22 pkm ship    $ */

--
-- Constant values
G_DEBUG	CONSTANT BOOLEAN := FALSE;	-- Run engine in debug or normal mode

--
-- Global variables
g_default_term_status_id	NUMBER;

/*******************************
 * Public program units *
 *******************************/

--This is the main procedure that will be called as a conc program
PROCEDURE Update_CP_Term_Status
(
	errbuf	OUT	VARCHAR2,
	retcode	OUT	NUMBER
) IS
	CURSOR cp_term_cur IS
	SELECT customer_product_id
	FROM   cs_customer_products
	WHERE  trunc(sysdate) >= trunc(nvl(end_date_active, sysdate+1));

	--
BEGIN
	fnd_file.put_line(fnd_file.log, 'Executing pkg body ('||
				to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')||')');
	--
	IF (G_DEBUG) THEN
		fnd_file.put_names('status.log', 'status.out',
							'/home/sadiga/work/11i/bapi');
	END IF;
	--
	--
	FOR cp_term_cur_rec IN cp_term_cur LOOP
		fnd_file.put_line(fnd_file.log, 'Fetched cp_id to terminate '||
						to_char(cp_term_cur_rec.customer_product_id));

		-- later on, see if we can get the status name instead of printing out
		-- the status_id.

		fnd_file.put_line(fnd_file.log, 'Updating the status of this product to '||g_default_term_status_id);

		-- see if we call use the Update APis instead.

		UPDATE cs_customer_products
		SET    CUSTOMER_PRODUCT_STATUS_ID = g_default_term_status_id,
			  object_version_number = object_version_number + 1
		WHERE  customer_product_id = cp_term_cur_rec.customer_product_id;

		commit;
	END LOOP;
	--
	--
	fnd_file.put_line(fnd_file.log, 'Finished execution. Exiting... ('||
				to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss')||')');
	--
	-- Return 0 for successful completion, 1 for warnings, 2 for error
	errbuf := '';
	retcode := 0;
	--
	IF (G_DEBUG) THEN
		fnd_file.close;
	END IF;
	--
	--
	--
EXCEPTION
WHEN OTHERS THEN
	ROLLBACK;
	IF (G_DEBUG) THEN
		fnd_file.close;
	END IF;

	-- Retrieve error message into errbuf
	errbuf := sqlerrm;
	retcode := 2;
END Update_CP_Term_Status;
--
--
-- Package initialization code. This executes the first time (in a session) any
-- thing in the package is referenced.
BEGIN
	g_default_term_status_id := FND_PROFILE.VALUE('CS_IB_DEFAULT_TERMINATED_STATUS');
	IF g_default_term_status_id IS NULL THEN
		FND_MESSAGE.SET_NAME('FND', 'PROFILES-CANNOT READ');
		FND_MESSAGE.SET_TOKEN('OPTION', 'CS_IB_DEFAULT_TERMINATED_STATUS');
		FND_MESSAGE.SET_TOKEN('ROUTINE',
						'CS_CP_Termination_PKG.Update_CP_Term_Status');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

END CS_CP_Termination_PKG;

/
