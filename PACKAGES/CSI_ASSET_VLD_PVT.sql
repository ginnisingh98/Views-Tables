--------------------------------------------------------
--  DDL for Package CSI_ASSET_VLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ASSET_VLD_PVT" AUTHID CURRENT_USER AS
/* $Header: csivavs.pls 115.15 2003/09/04 00:39:22 sguthiva ship $ */

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param
(
	p_number        IN      NUMBER,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
);

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param
(
	p_variable      IN      VARCHAR2,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
);

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param
(
	p_date          IN      DATE,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
);

/*-----------------------------------------------------------*/
/* Procedure name: Is_InstanceID_Valid                       */
/* Description : Check if the Instance Id exists             */
/*-----------------------------------------------------------*/


FUNCTION Is_InstanceID_Valid
(	p_instance_id           IN      NUMBER,
        p_check_for_instance_expiry IN  VARCHAR2,
	p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name:   generate_inst_asset_id                  */
/* Description : Generate instance asset id   from           */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION  gen_inst_asset_id
  RETURN NUMBER;

/*-----------------------------------------------------------*/
/* Procedure name:  Is_Inst_assetID_exists                   */
/* Description : Check if the instance asset id              */
/*               exists in csi_i_assets                      */
/*-----------------------------------------------------------*/

FUNCTION  Is_Inst_assetID_exists

(	p_instance_asset_id     IN      NUMBER,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN ;

/*-----------------------------------------------------------*/
/* Procedure name:  Is_Inst_asset_id_valid                   */
/* Description : Check if the instance asset id              */
/*               exists in csi_i_assets                      */
/*-----------------------------------------------------------*/

FUNCTION  Is_Inst_asset_id_valid

(	p_instance_asset_id     IN      NUMBER,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
  ) RETURN BOOLEAN ;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Update_Status_Exists                   */
/* Description : Check if the update status  is              */
/*              defined in fnd_lookups                       */
/*-----------------------------------------------------------*/

FUNCTION Is_Update_Status_Exists
(
    p_update_status         IN      VARCHAR2,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Quantity_Valid                         */
/* Description : Check if the asset quantity > 0             */
/*-----------------------------------------------------------*/

FUNCTION Is_Quantity_Valid
(
    p_asset_quantity        IN      NUMBER,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;


/*-----------------------------------------------------------*/
/* Procedure name:   generate_inst_asset_hist_id             */
/* Description : Generate instance asset id   from           */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION  gen_inst_asset_hist_id
  RETURN NUMBER;
/*-----------------------------------------------------------*/
/* Procedure name:  Is_Asset_Comb_Valid                      */
/* Description : Check if the instance asset id and location */
/*               id exists in fa_books                       */
/*-----------------------------------------------------------*/

FUNCTION  Is_Asset_Comb_Valid

(	p_asset_id        IN      NUMBER,
    p_book_type_code  IN      VARCHAR2,
    p_stack_err_msg   IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN ;

/*-----------------------------------------------------------*/
/* Procedure name:  Is_Asset_Location_Valid                  */
/* Description : Check if the instance location id           */
/*                exists in csi_a_locations                  */
/*-----------------------------------------------------------*/

FUNCTION  Is_Asset_Location_Valid
(	p_location_id     IN      NUMBER,
    p_stack_err_msg   IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN ;

/*-----------------------------------------------------------*/
/* Procedure name: Is_StartDate_Valid                        */
/* Description : Check if instance assets active start       */
/*    date is valid                                          */
/*-----------------------------------------------------------*/

FUNCTION Is_StartDate_Valid
(   p_start_date                IN   DATE,
    p_end_date                  IN   DATE,
    p_instance_id               IN   NUMBER,
    p_check_for_instance_expiry IN   VARCHAR2, -- Added for cse on 14-feb-03
    p_stack_err_msg             IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*----------------------------------------------------------*/
/* Function Name :  Is_EndDate_Valid                        */
/*                                                          */
/* Description  :  This function checks if end date         */
/*                 is valid                                 */
/*----------------------------------------------------------*/

FUNCTION Is_EndDate_Valid
(
    p_start_date                IN   DATE,
    p_end_date                  IN   DATE,
    p_instance_id               IN   NUMBER,
    p_inst_asset_id             IN   NUMBER,
    p_txn_id                    IN   NUMBER,
    p_check_for_instance_expiry IN   VARCHAR2, -- Added for cse on 14-feb-03
    p_stack_err_msg             IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;


END CSI_Asset_vld_pvt  ;


 

/
