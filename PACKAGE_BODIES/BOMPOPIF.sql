--------------------------------------------------------
--  DDL for Package Body BOMPOPIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPOPIF" as
/*  $Header: BOMOPIFB.pls 120.3 2006/05/25 05:38:15 bbpatel ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMOPIFB.pls                                               |
| DESCRIPTION  : This is the main package used to validate and process      |
| 		 open interface Bill and Routing data.                      |
| Parameters:	org_id		organization_id                             |
|		all_org		process all orgs or just current org        |
|				1 - all orgs                                |
|				2 - only org_id                             |
|		val_rtg_flag	validate routings                           |
|		val_bom_flag	validate boms                               |
|		pro_rtg_flag	process routings                            |
|		pro_bom_flag	process boms                                |
|		del_rec_flag	delete processed rows                       |
|    		prog_appid      program application_id                      |
|    		prog_id  	program id                                  |
|    		request_id      request_id                                  |
|    		user_id		user id                                     |
|    		login_id	login id                                    |
| Return:	1 if success                                                |
|		SQLCODE if failure                                          |
| History:	                                                            |
|    09/26/93   Shreyas Shah	creation date                               |
|    03/27/97   Julie Maeyama	Modified to call new packages               |
|    01/15/05   Bhavnesh Patel  Added Batch Id                              |
|                                                                           |
+==========================================================================*/

/*--------------------------bmopinp_open_interface_process-------------------

NAME
   bmopinp_open_interface_process
DESCRIPTION
    Open Interface Import for null batch id .
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmopinp_open_interface_process (
    org_id		NUMBER,
    all_org		NUMBER		:= 1,
    val_rtg_flag	NUMBER		:= 1,
    val_bom_flag	NUMBER		:= 1,
    pro_rtg_flag	NUMBER		:= 1,
    pro_bom_flag	NUMBER		:= 1,
    del_rec_flag	NUMBER		:= 1,
    prog_appid		NUMBER		:= -1,
    prog_id		NUMBER		:= -1,
    request_id		NUMBER		:= -1,
    user_id		NUMBER		:= -1,
    login_id		NUMBER		:= -1,
    err_text     IN OUT NOCOPY 	VARCHAR2
)
    return INTEGER
IS
  l_return_status INTEGER := 0;
BEGIN
  l_return_status := bmopinp_open_interface_process (
                        org_id => org_id,
                        all_org => all_org,
                        val_rtg_flag => val_rtg_flag,
                        val_bom_flag => val_bom_flag,
                        pro_rtg_flag => pro_rtg_flag,
                        pro_bom_flag => pro_bom_flag,
                        del_rec_flag => del_rec_flag,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        request_id => request_id,
                        user_id => user_id,
                        login_id => login_id,
                        err_text => err_text,
                        p_batch_id => NULL
                     );

  RETURN l_return_status;
END;

/*--------------------------bmopinp_open_interface_process-------------------

NAME
   bmopinp_open_interface_process
DESCRIPTION
    Open Interface Import for given batch id .
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmopinp_open_interface_process (
    org_id		NUMBER,
    all_org		NUMBER		:= 1,
    val_rtg_flag	NUMBER		:= 1,
    val_bom_flag	NUMBER		:= 1,
    pro_rtg_flag	NUMBER		:= 1,
    pro_bom_flag	NUMBER		:= 1,
    del_rec_flag	NUMBER		:= 1,
    prog_appid		NUMBER		:= -1,
    prog_id		NUMBER		:= -1,
    request_id		NUMBER		:= -1,
    user_id		NUMBER		:= -1,
    login_id		NUMBER		:= -1,
    err_text     IN OUT NOCOPY 	VARCHAR2,
    p_batch_id   IN NUMBER
)
    return INTEGER
IS
    err_msg	      	VARCHAR2(2000);
    ret_code	   	NUMBER := 1;
    l_func_return_code  NUMBER;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_all_org		VARCHAR2(1); -- boolean value
    l_delete_rows	VARCHAR2(1); -- boolean value
    l_RoutingError	exception;
    l_BillError		exception;
    -- To collect stats for INTERFACE tables. Bug#3537226
    l_schema            VARCHAR2(30);
    l_industry          VARCHAR2(1);
    l_status            VARCHAR2(1);
BEGIN
/*
** Import Routings
*/
   l_func_return_code := 0;

   IF (val_rtg_flag = 1) THEN
/*
     If all_org	= 1 then
       l_all_org := FND_API.G_TRUE;
     Else
       l_all_org := FND_API.G_FALSE;
     End if;
     If del_rec_flag = 1 then
       l_delete_rows := FND_API.G_TRUE;
     Else
       l_delete_rows := FND_API.G_FALSE;
     End if;
*/
     -- Collect the stats INTERFACE tables before procesing anything.
      /* IF NVL(prog_id,-1) <> -1 THEN
          IF FND_INSTALLATION.GET_APP_INFO('BOM',l_status, l_industry, l_schema) THEN
             IF l_schema IS NOT NULL THEN
                 FND_STATS.GATHER_TABLE_STATS(l_schema,'BOM_OP_ROUTINGS_INTERFACE');
                 FND_STATS.GATHER_TABLE_STATS(l_schema,'BOM_OP_SEQUENCES_INTERFACE');
                 FND_STATS.GATHER_TABLE_STATS(l_schema,'BOM_OP_NETWORKS_INTERFACE');
                 FND_STATS.GATHER_TABLE_STATS(l_schema,'BOM_OP_RESOURCES_INTERFACE');
                 FND_STATS.GATHER_TABLE_STATS(l_schema,'BOM_SUB_OP_RESOURCES_INTERFACE');
             END IF;
          END IF;
          IF FND_INSTALLATION.GET_APP_INFO('INV',l_status, l_industry, l_schema) THEN
             IF l_schema IS NOT NULL THEN
                 FND_STATS.GATHER_TABLE_STATS(l_schema,'MTL_RTG_ITEM_REVS_INTERFACE');
             END IF;
          END IF;
       END IF;
       commented for bug 4350033 for performance issue */

     ret_code := BOM_RTG_OPEN_INTERFACE.IMPORT_RTG
		 ( p_organization_id => org_id
		 , p_all_org	 => all_org
		 , p_delete_rows => del_rec_flag
		 , x_err_text	 => err_msg
     , p_batch_id => p_batch_id
		 );
     --bug:5235742 Success = 0, Warning if any entity's import failed with error = 1.
     If ( ret_code NOT IN (0,1) ) Then
        Raise l_RoutingError;
     ELSIF ( ret_code = 1 ) THEN
       l_func_return_code := 1;
     End if;

/*  Replaced the following call with API calling RBO
     BOM_RoutingInterface_PUB.ImportRouting(
       p_api_version         =>      1.0,
       p_init_msg_list       =>      FND_API.G_TRUE,
       p_commit              =>      FND_API.G_TRUE,
       p_validation_level    =>      FND_API.G_VALID_LEVEL_FULL,
       x_return_status       =>      l_return_status,
       x_msg_count           =>      l_msg_count,
       x_msg_data            =>      l_msg_data,
       p_organization_id     =>      org_id,
       p_all_organizations   =>      l_all_org,
       p_commit_rows         =>      500,
       p_delete_rows         =>      l_delete_rows
     );

     If l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
       Raise l_RoutingError;
     End if;
*/
   End if; -- Routing specified

/*
** Import Bills
*/

   IF (val_bom_flag = 1) THEN
      -- Collect the stats INTERFACE tables before procesing anything.
     /* IF NVL(prog_id,-1) <> -1 THEN
        IF FND_INSTALLATION.GET_APP_INFO('BOM',l_status, l_industry, l_schema) THEN
           IF l_schema IS NOT NULL THEN
               FND_STATS.GATHER_TABLE_STATS(l_schema,'BOM_BILL_OF_MTLS_INTERFACE');
               FND_STATS.GATHER_TABLE_STATS(l_schema,'BOM_INVENTORY_COMPS_INTERFACE');
               FND_STATS.GATHER_TABLE_STATS(l_schema,'BOM_COMPONENT_OPS_INTERFACE');
               FND_STATS.GATHER_TABLE_STATS(l_schema,'BOM_REF_DESGS_INTERFACE');
               FND_STATS.GATHER_TABLE_STATS(l_schema,'BOM_SUB_COMPS_INTERFACE');
           END IF;
        END IF;
        IF FND_INSTALLATION.GET_APP_INFO('INV',l_status, l_industry, l_schema) THEN
           IF l_schema IS NOT NULL THEN
               FND_STATS.GATHER_TABLE_STATS(l_schema,'MTL_ITEM_REVISIONS_INTERFACE');
           END IF;
        END IF;
      END IF;
      commented for bug 4350033 for performance issue */
      ret_code := Bom_Open_Interface_Api.Import_BOM (
    		org_id	 	=> org_id,
    		all_org		=> all_org,
    		user_id		=> user_id,
    		login_id	=> login_id,
    		prog_appid	=> prog_appid,
    		prog_id		=> prog_id,
    		req_id		=> request_id,
		del_rec_flag    => del_rec_flag,
    		err_text	=> err_msg,
        p_batch_id => p_batch_id);
      IF (ret_code NOT IN (0,1) ) THEN
         Raise l_BillError;
      ELSIF ( ret_code = 1 ) THEN
        l_func_return_code := 1;
      END IF;
/*
      ret_code := Bom_Revision_Api.Import_Item_Revision (
    		org_id	 	=> org_id,
    		all_org		=> all_org,
    		user_id		=> user_id,
    		login_id	=> login_id,
    		prog_appid	=> prog_appid,
    		prog_id		=> prog_id,
    		req_id		=> request_id,
		del_rec_flag    => del_rec_flag,
    		err_text	=> err_msg);
      IF (ret_code <> 0) THEN
         Raise l_BillError;
      END IF;

-- ASSEMBLY COMMENTS ????

      ret_code := Bom_Component_Api.Import_Component (
    		org_id	 	=> org_id,
    		all_org		=> all_org,
    		user_id		=> user_id,
    		login_id	=> login_id,
    		prog_appid	=> prog_appid,
    		prog_id		=> prog_id,
    		req_id		=> request_id,
		del_rec_flag    => del_rec_flag,
    		err_text	=> err_msg);
      IF (ret_code <> 0) THEN
         Raise l_BillError;
      END IF;

      ret_code := Bom_Reference_Designator_Api.Import_Reference_Designator (
    		org_id	 	=> org_id,
    		all_org		=> all_org,
    		user_id		=> user_id,
    		login_id	=> login_id,
    		prog_appid	=> prog_appid,
    		prog_id		=> prog_id,
    		req_id		=> request_id,
		del_rec_flag    => del_rec_flag,
    		err_text	=> err_msg);
      IF (ret_code <> 0) THEN
         Raise l_BillError;
      END IF;

      ret_code := Bom_Substitute_Component_Api.Import_Substitute_Component (
    		org_id	 	=> org_id,
    		all_org		=> all_org,
    		user_id		=> user_id,
    		login_id	=> login_id,
    		prog_appid	=> prog_appid,
    		prog_id		=> prog_id,
    		req_id		=> request_id,
		del_rec_flag    => del_rec_flag,
    		err_text	=> err_msg);
      IF (ret_code <> 0) THEN
         Raise l_BillError;
      END IF;
*/
   END IF;

   RETURN(l_func_return_code);

EXCEPTION
   When l_RoutingError then
     err_text := 'BOMPOPIF(bmopinp) ' || substrb(err_msg,1,1500);
     RETURN(ret_code);
/*
     err_text := Fnd_Msg_Pub.Get(p_msg_index => Fnd_Msg_Pub.G_First,
       p_encoded => FND_API.G_FALSE);
     return(-1);
*/
   When l_BillError then
     err_text := 'BOMPOPIF(bmopinp) ' || substrb(err_msg,1,1500);
     RETURN(ret_code);
   WHEN others THEN
      err_text := 'BOMPOPIF(bmopinp) ' || substrb(SQLERRM,1,240);
      RETURN(SQLCODE);
END bmopinp_open_interface_process;

END BOMPOPIF;

/
