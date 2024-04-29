--------------------------------------------------------
--  DDL for Package IPA_ASSET_MECH_APIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IPA_ASSET_MECH_APIS_PKG" AUTHID CURRENT_USER AS
/* $Header: IPAAMAPS.pls 120.1 2005/08/16 15:36:07 dlanka noship $ */
/* Original Header: IPAFAXS.pls 41.2 98/01/02 16:21:57 porting ship */

   -- Standard who
   x_last_updated_by         NUMBER(15) := nvl(FND_GLOBAL.USER_ID,-1);
   x_last_update_date        NUMBER(15) := nvl(FND_GLOBAL.USER_ID,-1);
   x_created_by              NUMBER(15) := nvl(FND_GLOBAL.USER_ID,-1);
   x_last_update_login       NUMBER(15) := nvl(FND_GLOBAL.LOGIN_ID,-1);
   x_request_id              NUMBER(15) := nvl(FND_GLOBAL.CONC_REQUEST_ID,-1);
   x_program_application_id  NUMBER(15) := nvl(FND_GLOBAL.PROG_APPL_ID,-1);
   x_program_id              NUMBER(15) := nvl(FND_GLOBAL.CONC_PROGRAM_ID,-1);

   -- Globals added for CRL3.1

/* Changed the initialization for g_nl_installed 3817786*/
      g_nl_installed         VARCHAR2(1):=PA_NL_INSTALLED.is_nl_installed;
      g_number_of_units      NUMBER:=null;
      g_expenditure_item_id  NUMBER:=null;
   -- Variable used by the set_ and get_inservice_thru_date functions.
   x_in_service_thru_date	DATE;

Procedure IPA_AUTO_ASSET_CREATION (
			  x_project_num_from        IN  VARCHAR2,
			  x_project_num_to          IN  VARCHAR2,
           		  x_pa_date                 IN  OUT NOCOPY  DATE,
			  x_err_code   IN OUT NOCOPY varchar2,
			  x_err_stack  IN OUT NOCOPY varchar2,
			  x_err_stage  IN OUT NOCOPY varchar2,
                          x_conc_request_id IN OUT NOCOPY NUMBER
			) ;

Function check_auto_asset (x_project_id in number,
                           x_task_id in number) return boolean ;
END IPA_ASSET_MECH_APIS_PKG;

 

/
