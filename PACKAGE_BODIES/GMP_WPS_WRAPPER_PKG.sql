--------------------------------------------------------
--  DDL for Package Body GMP_WPS_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_WPS_WRAPPER_PKG" as
/* $Header: GMPWSCHB.pls 120.2 2005/10/26 10:56:56 asatpute noship $ */

        G_log_text              VARCHAR2(1000) := NULL;

/*=========================================================================
| PROCEDURE NAME                                                           |
|    gmp_wps_sched_exec                                                    |
|                                                                          |
| TYPE                                                                     |
|    public                                                                |
|                                                                          |
| DESCRIPTION                                                              |
|    The following procedure is used to execute the scheduler engine       |
| Output Parameters                                                        |
|    None                                                                  |
|                                                                          |
| HISTORY     Rajesh Patangya    on 17 Aug'2002                            |
| Rajesh Patangya  on 18th Nov'2003 B2696452 Addition of firm window       |
|                                                                          |
 ==========================================================================*/

PROCEDURE gmp_wps_sched_exec(
errbuf			OUT NOCOPY VARCHAR2,
retcode			OUT NOCOPY NUMBER,
P_ORGANIZATION_ID	IN  VARCHAR2,
P_SCHEDULING_MODE	IN  VARCHAR2,
P_WIP_ENTITY_ID		IN  NUMBER,
P_SCHEDULING_DIR	IN  VARCHAR2,
P_MIDPT_OPERATION	IN  NUMBER,
P_START_DATE		IN  NUMBER,
P_END_DATE		IN  NUMBER,
P_HORIZON_START		IN  VARCHAR2,
P_HORIZON_LENGTH	IN  NUMBER,
P_USE_RESOURCE_CONS	IN  NUMBER,
P_USE_MATERIAL_CONS	IN  NUMBER,
P_CONNECT_TO_COMM	IN  NUMBER,
P_IP_ADDRESS		IN  NUMBER,
P_PORT_NUMBER		IN  NUMBER,
P_USER_ID		IN  NUMBER,
P_IDENT			IN  VARCHAR2,
P_USE_SUBSTITUTE_RES	IN  VARCHAR2,
P_CHOSEN_OPERATION	IN  NUMBER,
P_CHOSEN_SUBST_GROUP	IN  NUMBER,
P_ENTITY_TYPE		IN  NUMBER,
P_MIDPT_OPERATION_RES	IN  NUMBER,
P_INSTANCE_ID		IN  NUMBER,
P_SERIAL_NUMBER		IN  VARCHAR2,
P_FIRM_WINDOW_CUTOFF    IN  NUMBER   ) IS

 X_conc_id  NUMBER;
 X_status   BOOLEAN;
 X_ri_where 	  VARCHAR2(1000);
 X_horizon_start  VARCHAR2(35);
 DIFF             NUMBER;
 l_matl_cons NUMBER ;

BEGIN

 X_horizon_start   := NULL;

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Organization_id '|| P_ORGANIZATION_ID);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Scheduling Mode '||P_SCHEDULING_MODE);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Batches '||P_SCHEDULING_DIR);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Batch id '||to_char(P_WIP_ENTITY_ID));
        FND_FILE.PUT_LINE(FND_FILE.LOG,P_SCHEDULING_DIR );
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Horizone Date ' ||P_HORIZON_START);

        DIFF := trunc(SYSDATE) -
           to_date(substr(P_HORIZON_START,1,10),'YYYY/MM/DD');
	BEGIN
	 SELECT decode(material_constrained,1,1,-1)
	 INTO l_matl_cons
	 FROM wip_parameters
	 WHERE organization_id = P_ORGANIZATION_ID ;
	EXCEPTION
	 WHEN OTHERS THEN
 	  FND_FILE.PUT_LINE(FND_FILE.LOG,'Could Not get Matl Cons Indicator for ' ||P_ORGANIZATION_ID );
	END ;
     IF DIFF > 0 THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Horizon Date must be grater than system Date');
       retcode:=2;
     ELSE
         /* Used fnd_number to for NLS issue B3732806 Rajesh Patangya 03-AUG-04 */
         X_horizon_start := fnd_number.number_to_canonical(
                            wip_datetimes.DT_to_float (
           to_date(P_HORIZON_START,'YYYY/MM/DD HH24:MI:SS')
                                  )) ;

         -- request is submitted to the concurrent manager
         X_conc_id := FND_REQUEST.SUBMIT_REQUEST('WPS','WPCWFS',
         '',  -- description
         TO_CHAR(sysdate,'YYYY/MM/DD HH24:MI:SS'), -- start date
         FALSE,
         P_ORGANIZATION_ID,
         P_SCHEDULING_MODE,
         to_char(P_WIP_ENTITY_ID)		,
         P_SCHEDULING_DIR,
         to_char(P_MIDPT_OPERATION)	,
         to_char(P_START_DATE)	,
         to_char(P_END_DATE)	,
         X_HORIZON_START,
         to_char(P_HORIZON_LENGTH),
         to_char(P_USE_RESOURCE_CONS),
         to_char(l_matl_cons),
         to_char(P_CONNECT_TO_COMM),
         to_char(P_IP_ADDRESS),
         to_char(P_PORT_NUMBER)	,
         to_char(P_USER_ID),
         P_IDENT,
         P_USE_SUBSTITUTE_RES,
         to_char(P_CHOSEN_OPERATION),
         to_char(P_CHOSEN_SUBST_GROUP),
         to_char(P_ENTITY_TYPE)	,
         to_char(P_MIDPT_OPERATION_RES),
         to_char(P_INSTANCE_ID),
         P_SERIAL_NUMBER,
         to_char(P_FIRM_WINDOW_CUTOFF),   /* B2696452 Addition of firm window */
         chr(0),
         '','','','','',
         '','','','','','','','','','',
         '','','','','','','','','','',
         '','','','','','','','','','',
         '','','','','','','','','','',
         '','','','','','','','','','',
         '','','','','','','','','','',
         '','','','','','','','','','');

         IF X_conc_id = 0 THEN
           G_log_text := FND_MESSAGE.GET;
           FND_FILE.PUT_LINE ( FND_FILE.LOG,G_log_text);
           retcode:=2;
         ELSE
           COMMIT ;
         END IF;
     END IF ;
EXCEPTION
    WHEN no_data_found THEN
    errbuf := 'No Data Found Sql Error:' ||to_char(sqlcode);
    retcode := 1;  /* Warning */

    WHEN others THEN
    errbuf := 'Execution failed Sql Error:' ||to_char(sqlcode);
    retcode := 1;  /* Warning */
    NULL ;
END gmp_wps_sched_exec;

END gmp_wps_wrapper_pkg;

/
