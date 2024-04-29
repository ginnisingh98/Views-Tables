--------------------------------------------------------
--  DDL for Package CZ_IMP_ALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IMP_ALL" AUTHID CURRENT_USER AS
/*	$Header: czialls.pls 120.2 2007/11/26 07:59:23 kdande ship $		*/

CONCURRENT_SUCCESS   CONSTANT  NUMBER := 0;
CONCURRENT_WARNING   CONSTANT  NUMBER := 1;
CONCURRENT_ERROR     CONSTANT  NUMBER := 2;

get_time             BOOLEAN := FALSE;
RP_ROOT_FOLDER      CONSTANT PLS_INTEGER:=0; -- sselahi rpf
------------------------------------------------------------------------------------------
PROCEDURE setReturnCode(retcode IN NUMBER, errbuf IN VARCHAR2);
------------------------------------------------------------------------------------------
PROCEDURE go_cp(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER);
------------------------------------------------------------------------------------------
PROCEDURE go(errbuf IN OUT NOCOPY VARCHAR2,retcode IN OUT NOCOPY NUMBER);
------------------------------------------------------------------------------------------
PROCEDURE go_generic(outRun_ID IN OUT NOCOPY PLS_INTEGER,
                     inRun_ID IN PLS_INTEGER DEFAULT NULL, p_rp_folder_id NUMBER); -- sselahi
------------------------------------------------------------------------------------------
PROCEDURE populate_table(inRun_ID    IN PLS_INTEGER,
                         table_name  IN VARCHAR2,
                         commit_size IN PLS_INTEGER,
                         max_err     IN PLS_INTEGER,
                         inXFR_GROUP IN VARCHAR2,
                         p_rp_folder_id IN NUMBER,
                         x_failed       IN OUT NOCOPY NUMBER);
------------------------------------------------------------------------------------------
PROCEDURE import_before_start;
------------------------------------------------------------------------------------------
PROCEDURE import_after_complete(inRUN_ID IN PLS_INTEGER);
------------------------------------------------------------------------------------------
PROCEDURE goSingleBill(nOrg_ID IN NUMBER,nTop_ID IN NUMBER,
                       COPY_CHILD_MODELS IN VARCHAR2,
                       REFRESH_MODEL_ID  IN NUMBER,
                       COPY_ROOT_MODEL   IN VARCHAR2,
                       x_run_id OUT NOCOPY NUMBER); -- sselahi: added x_run_id
------------------------------------------------------------------------------------------
PROCEDURE AddBillToImport(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER,nOrg_ID IN NUMBER,nTop_ID IN NUMBER,
                       COPY_CHILD_MODELS IN VARCHAR2);
------------------------------------------------------------------------------------------
PROCEDURE SetSingleBillState(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER,nOrg_ID IN NUMBER,nTop_ID IN NUMBER,sState IN VARCHAR2);
------------------------------------------------------------------------------------------
PROCEDURE goSingleBill_cp
(errbuf IN OUT NOCOPY VARCHAR2,retcode IN OUT NOCOPY NUMBER,nORG_ID IN NUMBER,nTOP_ID IN NUMBER,
 COPY_CHILD_MODELS IN VARCHAR2 DEFAULT '0',
 REFRESH_MODEL_ID  IN NUMBER DEFAULT -1,
 COPY_ROOT_MODEL   IN VARCHAR2 DEFAULT '0');
------------------------------------------------------------------------------------------
PROCEDURE RemoveModel(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER,sOrg_ID IN VARCHAR2,
                      dsOrg_ID IN VARCHAR2,sTop_ID IN VARCHAR2);
------------------------------------------------------------------------------------------
PROCEDURE PopulateModels_cp(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER,
                         sOrg_ID IN VARCHAR2,dsOrg_ID IN VARCHAR2,
                         sFrom IN VARCHAR2,sTo IN VARCHAR,
                         COPY_CHILD_MODELS IN VARCHAR2 DEFAULT '0');
------------------------------------------------------------------------------------------
PROCEDURE RefreshModels(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER);
------------------------------------------------------------------------------------------
PROCEDURE setRunID(inRun_ID IN PLS_INTEGER,table_name IN VARCHAR2);
------------------------------------------------------------------------------------------
PROCEDURE setRecStatus(inRun_ID IN PLS_INTEGER,table_name IN VARCHAR2);
------------------------------------------------------------------------------------------
PROCEDURE check_for_common_bill
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY NUMBER,
 nORG_ID 		  IN NUMBER,
 nTOP_ID 		  IN NUMBER);
------------------------------------------------------------------------------------------
FUNCTION REPORT (Msg in VARCHAR2, Urgency in NUMBER, ByCaller in VARCHAR2,
	StatusCode in NUMBER) RETURN BOOLEAN;
------------------------------------------------------------------------------------------
PROCEDURE go_generic_cp(errbuf OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY NUMBER,
                        inRun_ID IN PLS_INTEGER,
                        p_rp_folder_id NUMBER); -- sselahi: added new procedure rpf
------------------------------------------------------------------------------------------
END CZ_IMP_ALL;

/
