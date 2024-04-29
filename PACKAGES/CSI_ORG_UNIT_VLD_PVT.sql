--------------------------------------------------------
--  DDL for Package CSI_ORG_UNIT_VLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ORG_UNIT_VLD_PVT" AUTHID CURRENT_USER AS
/* $Header: csivouvs.pls 120.0.12000000.1 2007/01/16 15:40:21 appldev ship $ */

/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_instance_id                    */
/*                                                          */
/* Description  :  This function checks if  instance        */
/*                 ids are valid                            */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_instance_id
     (p_instance_id   IN      NUMBER
     ,p_event         IN      VARCHAR2
     ,p_stack_err_msg IN      BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;





/*----------------------------------------------------------*/
/* Function Name :  Val_inst_id_for_update                   */
/*                                                          */
/* Description  :  This function checks if  instance        */
/*                 ids can be updated                       */
/*----------------------------------------------------------*/

FUNCTION Val_inst_id_for_update
              ( p_instance_id_new   IN      NUMBER
               ,p_instance_id_old   IN      NUMBER
               ,p_stack_err_msg     IN      BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;





/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_operating_unit_id              */
/*                                                          */
/* Description  :  This function checks if operating        */
/*                 unit ids are valid                       */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_operating_unit_id
         (p_operating_unit_id   IN      NUMBER
         ,p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;





/*----------------------------------------------------------*/
/* Function Name :  Is_StartDate_Valid                      */
/*                                                          */
/* Description  :  This function checks if start date       */
/*                 is valid                                 */
/*----------------------------------------------------------*/

FUNCTION Is_StartDate_Valid
      ( p_start_date            IN   OUT NOCOPY DATE,
        p_end_date              IN       DATE,
        p_instance_id           IN       NUMBER,
        p_stack_err_msg         IN       BOOLEAN DEFAULT TRUE
       )
RETURN BOOLEAN;





/*----------------------------------------------------------*/
/* Function Name :  Is_EndDate_Valid                        */
/*                                                          */
/* Description  :  This function checks if end date         */
/*                 is valid                                 */
/*----------------------------------------------------------*/
FUNCTION Is_EndDate_Valid
     ( p_start_date             IN      DATE,
       p_end_date               IN      DATE,
       p_instance_id            IN      NUMBER,
       p_instance_ou_id         IN      NUMBER,
	  p_txn_id                 IN      NUMBER,
       p_stack_err_msg          IN      BOOLEAN DEFAULT TRUE
      )
RETURN BOOLEAN;





/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_rel_type_code                  */
/*                                                          */
/* Description  :  This function checks if                  */
/*                 relationship_type_code is valid          */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_rel_type_code
             (p_relationship_type_code  IN   VARCHAR2
             ,p_stack_err_msg           IN   BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;





/*----------------------------------------------------------*/
/* Function Name :  Alternate_PK_exists                     */
/*                                                          */
/* Description  :  This function checks if                  */
/*                 alternate PKs are valid                  */
/*----------------------------------------------------------*/

FUNCTION Alternate_PK_exists
         (p_instance_id              IN   NUMBER
         ,p_operating_unit_id        IN   NUMBER
         ,p_relationship_type_code   IN   VARCHAR2
         ,p_instance_ou_id           IN   NUMBER DEFAULT -9999
         ,p_stack_err_msg            IN   BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;





/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_instance_ou_id                 */
/*                                                          */
/* Description  :  This function checks if                  */
/*                 instance_ou_id is valid                  */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_instance_ou_id
            ( p_instance_ou_id IN      NUMBER
             ,p_stack_err_msg  IN      BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;




/*----------------------------------------------------------*/
/* Function Name :  Val_and_get_inst_ou_id                 */
/*                                                          */
/* Description  :  This function checks if                  */
/*                 instance_ou_id is valid                  */
/*----------------------------------------------------------*/

FUNCTION Val_and_get_inst_ou_id
         ( p_instance_ou_id  IN      NUMBER
          ,p_org_unit_rec    OUT NOCOPY csi_datastructures_pub.organization_units_rec
          ,p_stack_err_msg   IN      BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;




/*----------------------------------------------------------*/
/* Function Name :  Is_Expire_Op                            */
/*                                                          */
/* Description  :  This function checks if it is a          */
/*                 ids are valid and returns values         */
/*----------------------------------------------------------*/

FUNCTION Is_Expire_Op
      ( p_org_unit_rec    IN  csi_datastructures_pub.organization_units_rec
       ,p_stack_err_msg   IN  BOOLEAN DEFAULT TRUE
       )
RETURN BOOLEAN;




/*----------------------------------------------------------*/
/* Function Name :  Is_Updatable                            */
/*                                                          */
/* Description  :  This function checks if this is a        */
/*                 an updatable record                      */
/*----------------------------------------------------------*/

FUNCTION Is_Updatable
       (p_old_date          IN  DATE
       ,p_new_date          IN  DATE
       ,p_stack_err_msg     IN  BOOLEAN DEFAULT TRUE
       )
RETURN BOOLEAN;





/*----------------------------------------------------------*/
/* Function Name :  Get_instance_ou_id                      */
/*                                                          */
/* Description  :  This function generates                  */
/*                 instance_ou_ids using a sequence         */
/*----------------------------------------------------------*/
FUNCTION Get_instance_ou_id
       ( p_stack_err_msg IN      BOOLEAN DEFAULT TRUE)
RETURN NUMBER;




/*----------------------------------------------------------*/
/* Function Name :  get_cis_i_org_assign_h_id               */
/*                                                          */
/* Description  :  This function generates                  */
/*                 cis_i_org_assign_h_id using a sequence   */
/*----------------------------------------------------------*/
FUNCTION get_cis_i_org_assign_h_id
       ( p_stack_err_msg IN      BOOLEAN DEFAULT TRUE)
RETURN NUMBER;




/*-------------------------------------------------------------- */
/* Function Name :  get_object_version_number                    */
/*                                                               */
/* Description  :  This function generates object_version_number */
/*                 using previous version_numbers                */
/*---------------------------------------------------------------*/
FUNCTION get_object_version_number
       ( p_object_version_number IN      NUMBER
        ,p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
       )
RETURN NUMBER;




/*-------------------------------------------------------------- */
/* Function Name :  Is_valid_obj_ver_num                         */
/*                                                               */
/* Description  :  This function validate object_version_number  */
/*                 using previous version numbers                */
/*---------------------------------------------------------------*/
FUNCTION Is_valid_obj_ver_num
        ( p_obj_ver_numb_new IN  NUMBER
         ,p_obj_ver_numb_old IN  NUMBER
         ,p_stack_err_msg    IN  BOOLEAN DEFAULT TRUE
         )
RETURN BOOLEAN;




/*-------------------------------------------------------------- */
/* Function Name :  get_full_dump_frequency                      */
/*                                                               */
/* Description  :  This function gets the dump frequency         */
/*                                                               */
/*---------------------------------------------------------------*/

FUNCTION get_full_dump_frequency
    (p_stack_err_msg IN  BOOLEAN DEFAULT TRUE
     )
RETURN NUMBER;

END csi_org_unit_vld_pvt;

 

/
